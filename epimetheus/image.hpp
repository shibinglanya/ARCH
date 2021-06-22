
#ifndef _IMAGE_H_
#define _IMAGE_H_

#include <string>
#include <optional>

#include <X11/Xlib.h>
#include <X11/Xmu/WinUtil.h>

class image {
public:
    image();
    image(const int w, const int h, const unsigned char *rgb, const unsigned char *alpha);

    ~image();

    const unsigned char *get_png_alpha() const
    {
	return png_alpha_;
    };
    const unsigned char *get_rgb_data() const
    {
	return rgb_data_;
    };

    void get_pixel(double px, double py, unsigned char *pixel) const;
    void get_pixel(double px, double py, unsigned char *pixel, unsigned char *alpha) const;

    int width() const 
    {
	return width_;
    };
    int height() const
    {
	return height_;
    };
    void quality(const int q)
    {
	quality_ = q;
    };

    std::optional<std::string> read(const std::string &filename);

    void reduce(const int factor);
    void resize(const int w, const int h);
    void merge(image& background, const int x, const int y);
    void merge_non_crop(image& background, const int x, const int y);
    void crop(const int x, const int y, const int w, const int h);
    void tile(const int w, const int h);
    void center(const int w, const int h, const char *hex);
    void plain(const int w, const int h, const char *hex);

    static void compute_shift(unsigned long mask, unsigned char &left_shift, unsigned char &right_shift);

    Pixmap create_pixmap(Display *dpy, int scr, Window win);

private:
    int width_, height_, area_;
    unsigned char *rgb_data_;
    unsigned char *png_alpha_;

    int quality_;

    static int read_jpg__(const char *filename, int *width, int *height, unsigned char **rgb);
    static int read_png__(const char *filename, int *width, int *height, unsigned char **rgb, unsigned char **alpha);
};

#endif /* _IMAGE_H_ */
