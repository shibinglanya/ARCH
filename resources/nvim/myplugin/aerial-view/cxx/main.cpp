#include <cstring>
#include <string>

#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include "arg.hpp"

class AerialViewWindow {
public:
  AerialViewWindow(Window embed, const char *config, const char *font, unsigned,
                   unsigned, unsigned, unsigned);

  AerialViewWindow(const AerialViewWindow &) = delete;
  AerialViewWindow(AerialViewWindow &&) = delete;
  AerialViewWindow &operator=(const AerialViewWindow &) = delete;
  AerialViewWindow &operator=(AerialViewWindow &&) = delete;

  void resize(Window win, unsigned int columns, unsigned int lines);
  void move_resize(Window win, int col_x, int row_y, unsigned int columns,
                   unsigned int lines);
  void hide_resize(Window win, int col_x, int row_y, unsigned int columns,
                   unsigned int lines);
  void move(Window win, int col_x, int row_y);
  void show(Window win);
  void hide(Window win);

  void reparent(Window parent, Window win);

  ~AerialViewWindow() { XCloseDisplay(m_display); }

private:
  Display *m_display;

  Window m_parent;
  winsize m_parent_winsize;

  unsigned m_offset_x, m_offset_y;
  unsigned m_offset_width, m_offset_height;

  int m_preview_show_x, m_preview_show_y;
};

static AerialViewWindow get_view_window(int argc, char *argv[]);

int main(int argc, char *argv[]) {
  AerialViewWindow view_window = get_view_window(argc, argv);
  printf("finished\n");
  fflush(stdout);
  do {
    char buffer[32];
    scanf("%s", buffer);
    if (!strcmp(buffer, "move")) {
      int col_x = 0, row_y = 0, winid = 0;
      scanf("%d %d %d", &col_x, &row_y, &winid);
      view_window.move((Window)winid, col_x, row_y);
    } else if (!strcmp(buffer, "show")) {
      int winid = 0;
      scanf("%d", &winid);
      view_window.show((Window)winid);
    } else if (!strcmp(buffer, "hide")) {
      int winid = 0;
      scanf("%d", &winid);
      view_window.hide((Window)winid);
    } else if (!strcmp(buffer, "resize")) {
      int columns = 0, lines = 0, winid = 0;
      scanf("%d %d %d", &columns, &lines, &winid);
      view_window.resize((Window)winid, columns, lines);
    } else if (!strcmp(buffer, "move_resize")) {
      int col_x = 0, row_y = 0, columns = 0, lines = 0, winid = 0;
      scanf("%d %d %d %d %d", &col_x, &row_y, &columns, &lines, &winid);
      view_window.move_resize((Window)winid, col_x, row_y, columns, lines);
    } else if (!strcmp(buffer, "hide_resize")) {
      int col_x = 0, row_y = 0, columns = 0, lines = 0, winid = 0;
      scanf("%d %d %d %d %d", &col_x, &row_y, &columns, &lines, &winid);
      view_window.hide_resize((Window)winid, col_x, row_y, columns, lines);
    } else if (!strcmp(buffer, "reparent")) {
      int parent = 0, winid = 0;
      scanf("%d %d", &parent, &winid);
      view_window.reparent((Window)parent, (Window)winid);
    } else {
    }
  } while (true);
  return 0;
}

static AerialViewWindow get_view_window(int argc, char *argv[]) {
  ARGINTEGER_TYPE opt_embed, opt_offset_x = 0, opt_offset_y = 0,
                             opt_offset_width = 1, opt_offset_height = 1;
  ARGSTRING_TYPE opt_font, opt_config;

  ARGBEGIN
  OPTION("-embed")
  opt_embed = ARGINTEGER;
  OPTION("-offset_x")
  opt_offset_x = ARGINTEGER;
  OPTION("-offset_y")
  opt_offset_y = ARGINTEGER;
  OPTION("-offset_width")
  opt_offset_width = ARGINTEGER;
  OPTION("-offset_height")
  opt_offset_height = ARGINTEGER;
  OPTION("-font")
  opt_font = ARGSTRING;
  OPTION("-config")
  opt_config = ARGSTRING;
  OPTION("--finish")
  return AerialViewWindow{(Window)opt_embed,
                          opt_config,
                          opt_font,
                          (unsigned)opt_offset_x,
                          (unsigned)opt_offset_y,
                          (unsigned)opt_offset_width,
                          (unsigned)opt_offset_height};
  ARGEND

  abort();
}

static winsize get_terminal_size(Display *display, Window w) {
  unsigned char *prop_pid = 0;
  {
    Atom _1;
    int _2;
    unsigned long _3, _4;
    Atom xa_prop_name = XInternAtom(display, "_NET_WM_PID", False);
    XGetWindowProperty(display, w, xa_prop_name, 0, 1, False, XA_CARDINAL, &_1,
                       &_2, &_3, &_4, &prop_pid);
  }
  char buffer[128];
  sprintf(buffer, "ps --ppid %ld | grep pts | awk '{print $2}'",
          *((unsigned long *)prop_pid));
  FILE *fp = popen(buffer, "r");
  fscanf(fp, "%s", buffer);
  pclose(fp);
  char pts_path[128];
  sprintf(pts_path, "/dev/%s", buffer);
  struct winsize size;
  off_t fd = open(pts_path, O_RDONLY | O_NOCTTY);
  ioctl(fd, TIOCGWINSZ, &size);
  return size;
}

static void run_st_window(Display *display, Window embed, const char *font,
                          const char *config) {
  XWindowAttributes attr;
  XGetWindowAttributes(display, embed, &attr);
  if (fork() == 0) {
    char command[512];
    sprintf(command, "st -w %lu -g +%d+0 -f '%s' -e vi -R -u '%s'", embed,
            attr.width, font, config);
    FILE *fp1 = popen(command, "r");
    /**/
    pclose(fp1);
    exit(0);
  }
}

#define XPIXEL(WINSIZE, VAL) (WINSIZE.ws_xpixel * (VAL) / WINSIZE.ws_col)
#define YPIXEL(WINSIZE, VAL) (WINSIZE.ws_ypixel * (VAL) / WINSIZE.ws_row)

AerialViewWindow::AerialViewWindow(Window embed, const char *config,
                                   const char *font, unsigned offset_x,
                                   unsigned offset_y, unsigned offset_width,
                                   unsigned offset_height)
    : m_display{XOpenDisplay(NULL)}, m_parent{embed} {
  m_parent_winsize = get_terminal_size(m_display, m_parent);
  run_st_window(m_display, embed, font, config);
  m_offset_x = offset_x;
  m_offset_y = offset_y;
  m_offset_width = offset_width;
  m_offset_height = offset_height;
}

void AerialViewWindow::resize(Window win, unsigned int columns,
                              unsigned int lines) {
  auto width = XPIXEL(m_parent_winsize, columns) + m_offset_width;
  auto height = YPIXEL(m_parent_winsize, lines) + m_offset_height;
  XResizeWindow(m_display, win, width, height);
  XFlush(m_display);
}

void AerialViewWindow::move_resize(Window win, int col_x, int row_y,
                                   unsigned int columns, unsigned int lines) {
  auto x = XPIXEL(m_parent_winsize, col_x) + m_offset_x;
  auto y = YPIXEL(m_parent_winsize, row_y) + m_offset_y;
  auto width = XPIXEL(m_parent_winsize, columns) + m_offset_width;
  auto height = YPIXEL(m_parent_winsize, lines) + m_offset_height;
  XMoveResizeWindow(m_display, win, x, y, width, height);
  XFlush(m_display);
  m_preview_show_x = x;
  m_preview_show_y = y;
}

void AerialViewWindow::hide_resize(Window win, int col_x, int row_y,
                                   unsigned int columns, unsigned int lines) {
  resize(win, columns, lines);
  auto x = XPIXEL(m_parent_winsize, col_x) + m_offset_x;
  auto y = YPIXEL(m_parent_winsize, row_y) + m_offset_y;
  m_preview_show_x = x;
  m_preview_show_y = y;
}

void AerialViewWindow::move(Window win, int col_x, int row_y) {
  auto x = XPIXEL(m_parent_winsize, col_x) + m_offset_x;
  auto y = YPIXEL(m_parent_winsize, row_y) + m_offset_y;
  XMoveWindow(m_display, win, x, y);
  XFlush(m_display);
  m_preview_show_x = x;
  m_preview_show_y = y;
}

void AerialViewWindow::show(Window win) {
  XMoveWindow(m_display, win, m_preview_show_x, m_preview_show_y);
  XFlush(m_display);
}

void AerialViewWindow::hide(Window win) {
  XWindowAttributes attr;
  XGetWindowAttributes(m_display, win, &attr);
  //已经被隐藏了
  if (attr.x < 0 || attr.y < 0) {
    return;
  }
  m_preview_show_x = attr.x;
  m_preview_show_y = attr.y;
  XMoveWindow(m_display, win, -attr.width, 0);
  XFlush(m_display);
}

void AerialViewWindow::reparent(Window parent, Window win) {
  XReparentWindow(m_display, win, parent, m_preview_show_x, m_preview_show_y);
  XFlush(m_display);
}

#undef XPIXEL
#undef YPIXEL
