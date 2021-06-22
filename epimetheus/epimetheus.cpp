#include <X11/Xlib.h>
#include <X11/extensions/Xrandr.h>

#include <pthread.h>
#include <unistd.h>

#include "./cfg_manager.hpp"
#include "./image.hpp"
#include <iostream>
#include <poll.h>
Display* dpy;
int scr;
Window win;
cfg_manager cfg;


#define DISPLAY	":0.0"

void* RaiseWindow(void *data) {
	while(1) {
		XRaiseWindow(dpy, win);
		sleep(1);
	}

	return (void *)0;
}

struct Rectangle {
	int x;
	int y;
	unsigned int width;
	unsigned int height;

	Rectangle() : x(0), y(0), width(0), height(0) {};
	Rectangle(int x, int y, unsigned int width,
					unsigned int height) :
		x(x), y(y), width(width), height(height) {};
	bool is_empty() const {
		return width == 0 || height == 0;
	}
};
Rectangle GetPrimaryViewport(Display* Dpy, int Scr, Window Win) {
	Rectangle fallback;
	Rectangle result;

	RROutput primary;
	XRROutputInfo *primary_info;
	XRRScreenResources *resources;
	XRRCrtcInfo *crtc_info;

    int crtc;

	fallback.x = 0;
	fallback.y = 0;
	fallback.width = DisplayWidth(Dpy, Scr);
	fallback.height = DisplayHeight(Dpy, Scr);

	primary = XRRGetOutputPrimary(Dpy, Win);
	if (!primary) {
	    return fallback;
	}
	resources = XRRGetScreenResources(Dpy, Win);
	if (!resources)
	    return fallback;

	primary_info = XRRGetOutputInfo(Dpy, resources, primary);
	if (!primary_info) {
	    XRRFreeScreenResources(resources);
	    return fallback;
	}

    // Fixes bug with multiple monitors.  Just pick first monitor if 
    // XRRGetOutputInfo gives returns bad into for crtc.
    if (primary_info->crtc < 1) {
        if (primary_info->ncrtc > 0) {
           crtc = primary_info->crtcs[0];
        } else {
            exit(EXIT_FAILURE);
        }
    } else {
        crtc = primary_info->crtc;
    }

	crtc_info = XRRGetCrtcInfo(Dpy, resources, crtc);

	if (!crtc_info) {
	    XRRFreeOutputInfo(primary_info);
	    XRRFreeScreenResources(resources);
	    return fallback;
	}

	result.x = crtc_info->x;
	result.y = crtc_info->y;
	result.width = crtc_info->width;
	result.height = crtc_info->height;

	XRRFreeCrtcInfo(crtc_info);
	XRRFreeOutputInfo(primary_info);
	XRRFreeScreenResources(resources);

	return result;
}

Pixmap PanelPixmap;
Rectangle viewport;
void ApplyBackground(Rectangle rect, Display *Dpy, Window Win, GC WinGC) {
	int ret = 0;

	if (rect.is_empty()) {
	    rect.x = 0;
	    rect.y = 0;
	    rect.width = viewport.width;
	    rect.height = viewport.height;
	}

	ret = XCopyArea(Dpy, PanelPixmap, Win, WinGC,
		rect.x, rect.y, rect.width, rect.height,
		viewport.x + rect.x, viewport.y + rect.y);
	if (!ret) {
	}
}

int main(int argc, char* argv[])
{

    if (auto err = cfg.read_conf("/home/shibinglanya/slim.conf")) {
	return 1;
    }

	const char *display = getenv("DISPLAY");
	if (!display)
		display = DISPLAY;

	if(!(dpy = XOpenDisplay(display))) {
	}
	scr = DefaultScreen(dpy);

	XSetWindowAttributes wa;
	wa.override_redirect = 1;
	wa.background_pixel = BlackPixel(dpy, scr);

	// Create a full screen window
	Window root = RootWindow(dpy, scr);
	win = XCreateWindow(dpy,
	  root,
	  0,
	  0,
	  DisplayWidth(dpy, scr),
	  DisplayHeight(dpy, scr),
	  0,
	  DefaultDepth(dpy, scr),
	  CopyFromParent,
	  DefaultVisual(dpy, scr),
	  CWOverrideRedirect | CWBackPixel,
	  &wa);
	XMapWindow(dpy, win);

	XFlush(dpy);
	for (int len = 1000; len; len--) {
		if(XGrabKeyboard(dpy, root, True, GrabModeAsync, GrabModeAsync, CurrentTime)
			== GrabSuccess)
			break;
		usleep(1000);
	}
	XSelectInput(dpy, win, KeyPressMask);

	Display* Dpy = dpy;
	int Scr = scr;
	Window Root = root;

	Window Win = win;
	viewport = GetPrimaryViewport(Dpy, Scr, Win);

	/* Init GC */
	unsigned long gcm = GCGraphicsExposures;
	XGCValues gcv;
	gcv.graphics_exposures = False;
	GC WinGC = XCreateGC(Dpy, Win, gcm, &gcv);
	if (WinGC == 0) {
	}



	image background;
	std::string panelpng = cfg.get("background_path");
	if (background.read(panelpng.c_str())) {
	}
	background.resize(viewport.width, viewport.height);

	PanelPixmap = background.create_pixmap(Dpy, Scr, Root);

	ApplyBackground(Rectangle{}, dpy, Win, WinGC);


	pthread_t raise_thread;
	pthread_create(&raise_thread, NULL, RaiseWindow, NULL);

	struct pollfd x11_pfd {};
	x11_pfd.fd = ConnectionNumber(Dpy);
	x11_pfd.events = POLLIN;
	XEvent event;
	// Main loop
	while (true) {
		if (XPending(Dpy) || poll(&x11_pfd, 1, -1) > 0) {
		XNextEvent(dpy, &event);
		if(event.type == KeyPress) {
		    break;
		}
		}
	}

	// kill thread before destroying the window that it's supposed to be raising
	pthread_cancel(raise_thread);

	XFreeGC(Dpy, WinGC);



	XCloseDisplay(dpy);
	return 0;
}
