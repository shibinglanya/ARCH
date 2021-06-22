//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"", "~/.config/scripts/dwm.getNetTraf.sh",					1,		10},
	{"", "~/.config/scripts/dwm.getCPU.sh",					1,		11},
	{"", "~/.config/scripts/dwm.getMemory.sh",					1,		12},
	{"", "~/.config/scripts/dwm.getMoonPhase.sh",					18000,		15},
	{"", "~/.config/scripts/dwm.getWeather.sh",					60,		13},
	{"", "~/.config/scripts/dwm.getVolume.sh",					1,		14},
	{"", "~/.config/scripts/dwm.getDate.sh",					1,		16},
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = " ";
static unsigned int delimLen = 1;
