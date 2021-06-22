#include <cctype>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <fstream>

#include "image.hpp"



image::image() : width_{0}, height_{0}, area_{0}, 
    rgb_data_{nullptr}, png_alpha_{nullptr}, quality_{80}
{

}

image::image(const int w, const int h, const unsigned char *rgb, const unsigned char *alpha) :
    width_{w}, height_{h}, area_{w*h}, quality_{80}
{
    rgb_data_ = new unsigned char[3 * area_];
    memcpy(rgb_data_, rgb, 3 * area_);

    if (alpha == nullptr) {
	png_alpha_ = nullptr;
    }
    else {
	png_alpha_ = new unsigned char[area_];
	memcpy(png_alpha_, alpha, area_);
    }
}

image::~image()
{
    delete rgb_data_;
    delete png_alpha_;
}

std::optional<std::string> image::read(const std::string &filename) {
    std::ifstream file {filename, std::fstream::in | std::fstream::binary};
    if (!file) {
	return "could not load background image for '" + filename + "'";
    }

    /* see what kind of file we have */
    char buf[4];
    unsigned char *ubuf = reinterpret_cast<unsigned char*>(buf);
    file.read(buf, sizeof(buf));
    if (ubuf[0] == 0x89 && !strncmp("PNG", buf+1, 3)) {
	read_png__(filename.c_str(), &width_, &height_, &rgb_data_, &png_alpha_);
    }
    else if(ubuf[0] == 0xff && ubuf[1] == 0xd8) {
	read_jpg__(filename.c_str(), &width_, &height_, &rgb_data_);
    }
    else {
	return "unknown image format '" + filename + "'";
    }
    return std::nullopt;
}


void image::reduce(const int factor)
{
    if (factor < 1) {
	return;
    }

    double scale  = pow(2, factor);
    double scale2 = scale*scale;

    int w = width_ / scale;
    int h = height_ / scale;
    int new_area = w * h;

    unsigned char *new_rgb = new unsigned char[3 * new_area];
    memset(new_rgb, 0, 3 * new_area);

    unsigned char *new_alpha = nullptr;
    if (png_alpha_ != nullptr) {
	new_alpha = new unsigned char[new_area];
	memset(new_alpha, 0, new_area);
    }

    for (int ipos = 0, j = 0; j < h; ++j) {
	int js = j / scale;
	for (int i = 0; i < w; ++i) {
	    int is = i / scale;
	    for (int k = 0; k < 3; ++k) {
		new_rgb[3 * (js * w + is) +k] += static_cast<unsigned char>((rgb_data_[3 * ipos +k] + 0.5) / scale2);
	    }
	    if (png_alpha_ != nullptr) {
		new_alpha[js * w + is] += static_cast<unsigned char>(png_alpha_[ipos] / scale2);
	    }
	    ++ipos;
	}
    }
    delete rgb_data_;
    rgb_data_ = new_rgb;

    delete png_alpha_;
    png_alpha_ = new_alpha;

    width_  = w;
    height_ = h;
    area_   = new_area;
}

void image::resize(const int w, const int h)
{
    if (width_ == w && height_ == h) {
	return;
    }

    int new_area = w * h;

    unsigned char *new_rgb   = new unsigned char[3 * new_area];
    unsigned char *new_alpha = nullptr;
    if (png_alpha_ != nullptr) {
	new_alpha = new unsigned char[new_area];
    }

    const double scale_x = ((double) w) / width_;
    const double scale_y = ((double) h) / height_;

    for (int ipos = 0, j = 0; j < h; ++j) {
	const double y = j / scale_y;
	for (int i = 0; i < w; ++i) {
	    const double x = i / scale_x;
	    if (new_alpha == nullptr) {
		get_pixel(x, y, new_rgb + 3 * ipos);
	    }
	    else {
		get_pixel(x, y, new_rgb + 3 * ipos, new_alpha + ipos);
	    }
	    ipos++;
	}
    }

    delete rgb_data_;
    rgb_data_ = new_rgb;

    delete png_alpha_;
    png_alpha_ = new_alpha;

    width_  = w;
    height_ = h;
    area_   = new_area;
}

/* Find the color of the desired point using bilinear interpolation. */
/* Assume the array indices refer to the denter of the pixel, so each */
/* pixel has corners at (i - 0.5, j - 0.5) and (i + 0.5, j + 0.5) */
void image::get_pixel(double x, double y, unsigned char *pixel) const
{
    get_pixel(x, y, pixel, nullptr);
}

void image::get_pixel(double x, double y, unsigned char *pixel, unsigned char *alpha) const
{
    if (x < -0.5) {
	x = -0.5;
    }
    if (x >= width_ - 0.5) {
	x = width_ - 0.5;
    }

    if (y < -0.5) {
	y = -0.5;
    }
    if (y >= height_ - 0.5) {
	y = height_ - 0.5;
    }

    int ix0 = static_cast<int>(floor(x));
    int ix1 = ix0 + 1;
    if (ix0 < 0) {
	ix0 = width_ - 1;
    }
    if (ix1 >= width_) {
	ix1 = 0;
    }

    int iy0 = static_cast<int>(floor(y));
    int iy1 = iy0 + 1;
    if (iy0 < 0) {
	iy0 = 0;
    }
    if (iy1 >= height_) {
	iy1 = height_ - 1;
    }

    const double t = x - floor(x);
    const double u = 1 - (y - floor(y));

    double weight[4];
    weight[1] = t * u;
    weight[0] = u - weight[1];
    weight[2] = 1 - t - u + weight[1];
    weight[3] = t - weight[1];

    unsigned char *pixels[4];
    pixels[0] = rgb_data_ + 3 * (iy0 * width_ + ix0);
    pixels[1] = rgb_data_ + 3 * (iy0 * width_ + ix1);
    pixels[2] = rgb_data_ + 3 * (iy1 * width_ + ix0);
    pixels[3] = rgb_data_ + 3 * (iy1 * width_ + ix1);

    memset(pixel, 0, 3);
    for (int i = 0; i < 4; i++) {
	for (int j = 0; j < 3; j++) {
	    pixel[j] += static_cast<unsigned char>(weight[i] * pixels[i][j]);
	}
    }

    if (alpha != nullptr) {
	unsigned char pixels[4];
	pixels[0] = png_alpha_[iy0 * width_ + ix0];
	pixels[1] = png_alpha_[iy0 * width_ + ix1];
	pixels[2] = png_alpha_[iy0 * width_ + ix0];
	pixels[3] = png_alpha_[iy1 * width_ + ix1];

	for (int i = 0; i < 4; i++) {
	    *alpha = static_cast<unsigned char>(weight[i] * pixels[i]);
	}
    }
}

/* Merge the image with a background, taking care of the
 * image Alpha transparency. (background alpha is ignored).
 * The images is merged on position (x, y) on the
 * background, the background must contain the image.
 */
void image::merge(image& background, const int x, const int y) {

    if (x + width_ > background.width() || y + height_ > background.height()) {
	return;
    }

    if (background.width() * background.height() != width_*height_) {
	background.crop(x, y, width_, height_);
    }

    unsigned char *new_rgb = new unsigned char[3 * width_ * height_];
    memset(new_rgb, 0, 3 * width_ * height_);
    const unsigned char *bg_rgb = background.get_rgb_data();

    int ipos = 0;
    if (png_alpha_ != nullptr) {
	for (int j = 0; j < height_; ++j) {
	    for (int i = 0; i < width_; ++i) {
		for (int k = 0; k < 3; ++k) {
		    double tmp = rgb_data_[3 * ipos + k] * png_alpha_[ipos] / 255.0 
			+ bg_rgb[3 * ipos + k] * (1 - png_alpha_[ipos]/255.0);
		    new_rgb[3 * ipos + k] = static_cast<unsigned char>(tmp);
		}
		ipos++;
	    }
	}
    }
    else {
	for (int j = 0; j < height_; ++j) {
	    for (int i = 0; i < width_; ++i) {
		for (int k = 0; k < 3; ++k) {
		    double tmp = rgb_data_[3 * ipos + k];
		    new_rgb[3 * ipos + k] = static_cast<unsigned char>(tmp);
		}
		ipos++;
	    }
	}
    }

    delete rgb_data_;
    rgb_data_ = new_rgb;
    delete png_alpha_;
    png_alpha_ = nullptr;
}

/* Merge the image with a background, taking care of the
 * image Alpha transparency. (background alpha is ignored).
 * The images is merged on position (x, y) on the
 * background, the background must contain the image.
 */
#define IMG_POS_RGB(p, x) (3 * p + x)
void image::merge_non_crop(image& background, const int x, const int y)
{
    int bg_w = background.width();
    int bg_h = background.height();

    if (x + width_ > bg_w || y + height_ > bg_h) {
	return;
    }

    double tmp;
    unsigned char 	*new_rgb = new unsigned char[3 * bg_w * bg_h];
    const unsigned char *bg_rgb  = background.get_rgb_data();

    int pnl_pos   = 0;
    int bg_pos    = 0;
    int pnl_w_end = x + width_;
    int pnl_h_end = y + height_;

    memcpy(new_rgb, bg_rgb, 3 * bg_w * bg_h);

    for (int j = 0; j < bg_h; ++j) {
	for (int i = 0; i < bg_w; ++i) {
	    if (j >= y && i >= x && j < pnl_h_end && i < pnl_w_end ) {
		for (int k = 0; k < 3; ++k) {
		    if (png_alpha_ != nullptr) {
			tmp = rgb_data_[IMG_POS_RGB(pnl_pos, k)]
				* png_alpha_[pnl_pos] / 255.0
				+ bg_rgb[IMG_POS_RGB(bg_pos, k)]
				* (1 - png_alpha_[pnl_pos]/255.0);
		    }
		    else {
			tmp = rgb_data_[IMG_POS_RGB(pnl_pos, k)];
		    }
		    new_rgb[IMG_POS_RGB(bg_pos, k)] = static_cast<unsigned char>(tmp);
		}
		pnl_pos++;
	    }
	    bg_pos++;
	}
    }

    width_  = bg_w;
    height_ = bg_h;

    delete rgb_data_;
    rgb_data_ = new_rgb;
    delete png_alpha_;
    png_alpha_ = nullptr;
}

/* Tile the image growing its size to the minimum entire
 * multiple of w * h.
 * The new dimensions should be > of the current ones.
 * Note that this flattens image (alpha removed)
 */
void image::tile(const int w, const int h)
{
    if (w < width_ || h < height_) {
	return;
    }

    int nx = w / width_;
    if (w % width_ > 0) {
	nx++;
    }
    int ny = h / height_;
    if (h % height_ > 0) {
	ny++;
    }

    int newwidth  = nx * width_;
    int newheight = ny * height_;

    unsigned char *new_rgb = new unsigned char[3 * newwidth * newheight];
    memset(new_rgb, 0, 3 * width_ * height_ * nx * ny);

    for (int r = 0; r < ny; ++r) {
	for (int c = 0; c < nx; ++c) {
	    for (int j = 0; j < height_; ++j) {
		for (int i = 0; i < width_; ++i) {
		    int opos = j * width_ + i;
		    int ipos = r * width_ * height_ * nx + j * newwidth + c * width_ + i;
		    for (int k = 0; k < 3; ++k) {
			new_rgb[3 * ipos + k] = static_cast<unsigned char>(rgb_data_[3 * opos + k]);
		    }
		}
	    }
	}
    }

    delete rgb_data_;
    rgb_data_ = new_rgb;
    delete png_alpha_;
    png_alpha_ = nullptr;
    width_ = newwidth;
    height_ = newheight;
    area_ = width_ * height_;
    crop(0, 0, w, h);

}

/* Crop the image
 */
void image::crop(const int x, const int y, const int w, const int h)
{

    if (x + w > width_ || y + h > height_) {
	return;
    }

    int x2 = x + w;
    int y2 = y + h;
    unsigned char *new_rgb = new unsigned char[3 * w * h];
    memset(new_rgb, 0, 3 * w * h);
    unsigned char *new_alpha = nullptr;
    if (png_alpha_ != nullptr) {
	new_alpha = new unsigned char[w * h];
	memset(new_alpha, 0, w * h);
    }

    int ipos = 0;
    int opos = 0;

    for (int j = 0; j < height_; ++j) {
	for (int i = 0; i < width_; ++i) {
		if (j >= y && i >= x && j < y2 && i < x2) {
		    for (int k = 0; k < 3; ++k) {
			new_rgb[3 * ipos + k] = static_cast<unsigned char>(rgb_data_[3 * opos + k]);
		    }
		    if (png_alpha_ != nullptr) {
			new_alpha[ipos] = static_cast<unsigned char> (png_alpha_[opos]);
		    }
		    ipos++;
		}
		opos++;
	}
    }

    delete rgb_data_;
    delete png_alpha_;
    rgb_data_ = new_rgb;
    if (png_alpha_ != nullptr) {
	png_alpha_ = new_alpha;
    }
    width_  = w;
    height_ = h;
    area_   = w * h;


}

/* Center the image in a rectangle of given width and height.
 * Fills the remaining space (if any) with the hex color
 */
void image::center(const int w, const int h, const char *hex)
{

    unsigned long packed_rgb;
    sscanf(hex, "%lx", &packed_rgb);

    unsigned long r = packed_rgb >> 16;
    unsigned long g = packed_rgb >> 8 & 0xff;
    unsigned long b = packed_rgb & 0xff;

    unsigned char *new_rgb = new unsigned char[3 * w * h];
    memset(new_rgb, 0, 3 * w * h);

    int x = (w - width_) / 2;
    int y = (h - height_) / 2;

    if (x < 0) {
	crop((width_ - w) / 2, 0, w, height_);
	x = 0;
    }
    if (y < 0) {
	crop(0,(height_ - h) / 2,width_, h);
	y = 0;
    }
    int x2 = x + width_;
    int y2 = y + height_;

    int ipos = 0;
    int opos = 0;
    double tmp;

    area_ = w * h;
    for (int i = 0; i < area_; ++i) {
	new_rgb[3 * i] = r;
	new_rgb[3 * i + 1] = g;
	new_rgb[3 * i + 2] = b;
    }

    if (png_alpha_ != nullptr) {
	for (int j = 0; j < h; j++) {
	    for (int i = 0; i < w; i++) {
		if (j>=y && i>=x && j<y2 && i<x2) {
		    ipos = j*w + i;
		    for (int k = 0; k < 3; k++) {
			tmp = rgb_data_[3*opos + k]*png_alpha_[opos]/255.0
			    + new_rgb[k]*(1-png_alpha_[opos]/255.0);
			new_rgb[3*ipos + k] = static_cast<unsigned char>(tmp);
		    }
		    opos++;
		}

	    }
	}
    } 
    else {
	for (int j = 0; j < h; j++) {
	    for (int i = 0; i < w; i++) {
		if (j>=y && i>=x && j<y2 && i<x2) {
		    ipos = j*w + i;
		    for (int k = 0; k < 3; k++) {
			tmp = rgb_data_[3*opos + k];
			new_rgb[3*ipos + k] = static_cast<unsigned char>(tmp);
		    }
		    opos++;
		}

	    }
	}
    }

    delete rgb_data_;
    rgb_data_ = new_rgb;
    delete png_alpha_;
    png_alpha_ = nullptr;

    width_  = w;
    height_ = h;

}

/* Fill the image with the given color and adjust its dimensions
 * to passed values.
 */
void image::plain(const int w, const int h, const char *hex)
{
    unsigned long packed_rgb;
    sscanf(hex, "%lx", &packed_rgb);

    unsigned long r = packed_rgb >> 16;
    unsigned long g = packed_rgb >> 8 & 0xff;
    unsigned long b = packed_rgb & 0xff;

    unsigned char *new_rgb = new unsigned char[3 * w * h];
    memset(new_rgb, 0, 3 * w * h);

    area_ = w * h;
    for (int i = 0; i < area_; ++i) {
	new_rgb[3 * i]     = r;
	new_rgb[3 * i + 1] = g;
	new_rgb[3 * i + 2] = b;
    }

    delete rgb_data_;
    rgb_data_ = new_rgb;
    delete png_alpha_;
    png_alpha_ = nullptr;

    width_  = w;
    height_ = h;
}

void image::compute_shift(unsigned long mask, unsigned char &left_shift, unsigned char &right_shift)
{
    left_shift = 0;
    right_shift = 8;
    if (mask != 0) {
	while ((mask & 0x01) == 0) {
	    ++left_shift;
	    mask >>= 1;
	}
	while ((mask & 0x01) == 1) {
	    --right_shift;
	    mask >>= 1;
	}
    }
}


Pixmap image::create_pixmap(Display* dpy, int scr, Window win)
{
    int i, j;   /* loop variables */

    const int depth   = DefaultDepth(dpy, scr);
    Visual *visual    = DefaultVisual(dpy, scr);
    Colormap colormap = DefaultColormap(dpy, scr);

    Pixmap tmp = XCreatePixmap(dpy, win, width_, height_, depth);

    char *pixmap_data = nullptr;
    switch (depth) {
	case 32:
	case 24:
	    pixmap_data = new char[4 * width_ * height_];
	    break;
	case 16:
	case 15:
	    pixmap_data = new char[2 * width_ * height_];
	    break;
	case 8:
	    pixmap_data = new char[width_ * height_];
	    break;
	default:
	    break;
    }

    XImage *ximage = XCreateImage(dpy, visual, depth, ZPixmap, 0, pixmap_data, width_, height_, 8, 0);

    int entries;
    XVisualInfo v_template;
    v_template.visualid      = XVisualIDFromVisual(visual);
    XVisualInfo *visual_info = XGetVisualInfo(dpy, VisualIDMask, &v_template, &entries);

    unsigned long ipos = 0;
    switch (visual_info->c_class) {
	case PseudoColor: {
	    XColor xc;
	    xc.flags = DoRed | DoGreen | DoBlue;

	    int num_colors = 256;
	    XColor *colors = new XColor[num_colors];
	    for (i = 0; i < num_colors; i++) {
		colors[i].pixel = (unsigned long) i;
	    }
	    XQueryColors(dpy, colormap, colors, num_colors);

	    int *closest_color = new int[num_colors];

	    for (i = 0; i < num_colors; ++i) {
		xc.red   = (i & 0xe0) << 8;		   /* highest 3 bits */
		xc.green = (i & 0x1c) << 11;		/* middle 3 bits */
		xc.blue  = (i & 0x03) << 14;		 /* lowest 2 bits */

		/* find the closest color in the colormap */
		double distance, distance_squared, min_distance = 0;
		for (int ii = 0; ii < num_colors; ++ii) {
		    distance          = colors[ii].red - xc.red;
		    distance_squared  = distance * distance;
		    distance          = colors[ii].green - xc.green;
		    distance_squared += distance * distance;
		    distance          = colors[ii].blue - xc.blue;
		    distance_squared += distance * distance;

		    if ((ii == 0) || (distance_squared <= min_distance)) {
			min_distance     = distance_squared;
			closest_color[i] = ii;
		    }
		}
	    }

	    for (j = 0; j < height_; ++j) {
		for (i = 0; i < width_; ++i) {
		    xc.red   = (unsigned short) (rgb_data_[ipos++] & 0xe0);
		    xc.green = (unsigned short) (rgb_data_[ipos++] & 0xe0);
		    xc.blue  = (unsigned short) (rgb_data_[ipos++] & 0xc0);

		    xc.pixel = xc.red | (xc.green >> 3) | (xc.blue >> 6);
		    XPutPixel(ximage, i, j, colors[closest_color[xc.pixel]].pixel);
		}
	    }
	    delete [] colors;
	    delete [] closest_color;
	}
	break;
    case TrueColor: {
	unsigned char red_left_shift;
	unsigned char red_right_shift;
	unsigned char green_left_shift;
	unsigned char green_right_shift;
	unsigned char blue_left_shift;
	unsigned char blue_right_shift;

	compute_shift(visual_info->red_mask, red_left_shift, red_right_shift);
	compute_shift(visual_info->green_mask, green_left_shift, green_right_shift);
	compute_shift(visual_info->blue_mask, blue_left_shift, blue_right_shift);

	unsigned long pixel;
	unsigned long red, green, blue;
	for (j = 0; j < height_; ++j) {
	    for (i = 0; i < width_; ++i) {
		red = (unsigned long) rgb_data_[ipos++] >> red_right_shift;
		green = (unsigned long) rgb_data_[ipos++] >> green_right_shift;
		blue = (unsigned long) rgb_data_[ipos++] >> blue_right_shift;

		pixel = (((red << red_left_shift) & visual_info->red_mask)
			| ((green << green_left_shift)
			& visual_info->green_mask)
			| ((blue << blue_left_shift)
			& visual_info->blue_mask));

		XPutPixel(ximage, i, j, pixel);
	    }
	}
    }
    break;
    default: {
	return tmp;
    }
    }

    GC gc = XCreateGC(dpy, win, 0, NULL);
    XPutImage(dpy, tmp, gc, ximage, 0, 0, 0, 0, width_, height_);

    XFreeGC(dpy, gc);

    XFree(visual_info);

    delete [] pixmap_data;

    /* Set ximage data to NULL since pixmap data was deallocated above */
    ximage->data = NULL;
    XDestroyImage(ximage);

    return tmp;
}

extern "C" {
    #include <jpeglib.h>
    #include <png.h>
}
/* max height/width for images */
#define MAX_DIMENSION 10000

int image::read_jpg__(const char *filename, int *width, int *height, unsigned char **rgb)
{
    int ret = 0;
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerr;
    unsigned char *ptr = nullptr;

    FILE *infile = fopen(filename, "rb");
    if (infile == nullptr) {
	return ret;
    }

    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);
    jpeg_stdio_src(&cinfo, infile);
    jpeg_read_header(&cinfo, TRUE);
    jpeg_start_decompress(&cinfo);

    /* Prevent against integer overflow */
    if(cinfo.output_width >= MAX_DIMENSION
       || cinfo.output_height >= MAX_DIMENSION) {
	goto close_file;
    }

    *width = cinfo.output_width;
    *height = cinfo.output_height;

    rgb[0] = (unsigned char*)malloc(3 * cinfo.output_width * cinfo.output_height);
    if (rgb[0] == NULL) {
	goto close_file;
    }

    if (cinfo.output_components == 3) {
	ptr = rgb[0];
	while (cinfo.output_scanline < cinfo.output_height) {
		jpeg_read_scanlines(&cinfo, &ptr, 1);
		ptr += 3 * cinfo.output_width;
	}
    } else if (cinfo.output_components == 1) {
	ptr = (unsigned char*) malloc(cinfo.output_width);
	if (ptr == NULL) {
	    goto rgb_free;
	}

	unsigned int ipos = 0;
	while (cinfo.output_scanline < cinfo.output_height) {
	    jpeg_read_scanlines(&cinfo, &ptr, 1);

	    for (unsigned int i = 0; i < cinfo.output_width; i++) {
		    memset(rgb[0] + ipos, ptr[i], 3);
		    ipos += 3;
	    }
	}

	free(ptr);
    }

    jpeg_finish_decompress(&cinfo);

    ret = 1;
    goto close_file;

rgb_free:
    free(rgb[0]);

close_file:
    jpeg_destroy_decompress(&cinfo);
    fclose(infile);

    return(ret);
}

int image::read_png__(const char *filename, int *width, int *height, unsigned char **rgb, unsigned char **alpha)
{
	int ret = 0;

	png_structp png_ptr;
	png_infop info_ptr;
	png_bytepp row_pointers;

	unsigned char *ptr = NULL;
	png_uint_32 w, h;
	int bit_depth, color_type, interlace_type;
	int i;

	FILE *infile = fopen(filename, "rb");
	if (infile == NULL) {
		return ret;
	}

	png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, (png_voidp) NULL, (png_error_ptr) NULL, (png_error_ptr) NULL);
	if (!png_ptr) {
		goto file_close;
	}

	info_ptr = png_create_info_struct(png_ptr);
	if (!info_ptr) {
		png_destroy_read_struct(&png_ptr, (png_infopp) NULL,
								(png_infopp) NULL);
	}

#if PNG_LIBPNG_VER_MAJOR >= 1 && PNG_LIBPNG_VER_MINOR >= 4
		if (setjmp(png_jmpbuf((png_ptr)))) {
#else
	if (setjmp(png_ptr->jmpbuf)) {
#endif
		goto png_destroy;
	}

	png_init_io(png_ptr, infile);
	png_read_info(png_ptr, info_ptr);

	png_get_IHDR(png_ptr, info_ptr, &w, &h, &bit_depth, &color_type,
				 &interlace_type, (int *) NULL, (int *) NULL);

	/* Prevent against integer overflow */
	if(w >= MAX_DIMENSION || h >= MAX_DIMENSION) {
		goto png_destroy;
	}

	*width = (int) w;
	*height = (int) h;

	if (color_type == PNG_COLOR_TYPE_RGB_ALPHA
		|| color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
	{
		alpha[0] = (unsigned char *) malloc(*width * *height);
		if (alpha[0] == NULL) {
			goto png_destroy;
		}
	}

	/* Change a paletted/grayscale image to RGB */
	if (color_type == PNG_COLOR_TYPE_PALETTE && bit_depth <= 8)
	{
		png_set_expand(png_ptr);
	}

	/* Change a grayscale image to RGB */
	if (color_type == PNG_COLOR_TYPE_GRAY
		|| color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
	{
		png_set_gray_to_rgb(png_ptr);
	}

	/* If the PNG file has 16 bits per channel, strip them down to 8 */
	if (bit_depth == 16) {
	  png_set_strip_16(png_ptr);
	}

	/* use 1 byte per pixel */
	png_set_packing(png_ptr);

	row_pointers = (png_byte **) malloc(*height * sizeof(png_bytep));
	if (row_pointers == NULL) {
		goto png_destroy;
	}

	for (i = 0; i < *height; i++) {
		row_pointers[i] = (png_byte*) malloc(4 * *width);
		if (row_pointers == NULL) {
			goto rows_free;
		}
	}

	png_read_image(png_ptr, row_pointers);

	rgb[0] = (unsigned char *) malloc(3 * (*width) * (*height));
	if (rgb[0] == NULL) {
		goto rows_free;
	}

	if (alpha[0] == NULL) {
		ptr = rgb[0];
		for (i = 0; i < *height; i++) {
			memcpy(ptr, row_pointers[i], 3 * (*width));
			ptr += 3 * (*width);
		}
	} else {
		ptr = rgb[0];
		for (i = 0; i < *height; i++) {
			unsigned int ipos = 0;
			for (int j = 0; j < *width; j++) {
				*ptr++ = row_pointers[i][ipos++];
				*ptr++ = row_pointers[i][ipos++];
				*ptr++ = row_pointers[i][ipos++];
				alpha[0][i * (*width) + j] = row_pointers[i][ipos++];
			}
		}
	}

	ret = 1; /* data reading is OK */

rows_free:
	for (i = 0; i < *height; i++) {
		if (row_pointers[i] != NULL ) {
			free(row_pointers[i]);
		}
	}

	free(row_pointers);

png_destroy:
	png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp) NULL);

file_close:
	fclose(infile);
	return(ret);
}

