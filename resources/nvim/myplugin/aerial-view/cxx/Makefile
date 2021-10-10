# paths
X11INC = /usr/include/X11
X11LIB = /usr/include/X11

# includes and libs
INCS = -I$(X11INC)
LIBS = -L$(X11LIB) -lX11

CC = g++

install: main.cpp arg.hpp
	$(CC) main.cpp -o main $(INCS) $(LIBS)
