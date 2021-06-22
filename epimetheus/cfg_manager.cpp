
#include <vector>
#include <utility>
#include <fstream>
#include <optional>

#include "cfg_manager.hpp"




cfg_manager::cfg_manager()
{
    options.insert(option{"background_path", "~/.epimetheus/background.jpg"});
}















std::optional<std::string> cfg_manager::read_conf(const std::string &configfile)
{
    std::ifstream cfgfile {configfile.c_str()};
    if (!cfgfile) {
	return "cannot read configuration file: " + configfile;
    }
    
    for (std::string line, next; getline(cfgfile, line); ) {
	if (auto pos = line.find('\\'); pos != std::string::npos) {
	    if (line.length() == pos + 1) {
		line.replace(pos, 1, " ");
		next = next + line;
		continue;
	    }
	    else {
		line.replace(pos, line.length() - pos, " ");
	    }
	}

	if (!next.empty()) {
	    line = next + line;
	    next.clear();
	}

	for (auto it = options.begin(); it != options.end(); ++it) {
	    const std::string& op = it->first;
	    int n = line.find(op);
	    if (n == 0)
		options[op] = __parse_option(line, op);
	}
    }
    cfgfile.close();

    return std::nullopt;
}

/* Returns the option value, trimmed */
std::string cfg_manager::__parse_option(const std::string& line, const std::string& option)
{
    return __trim(line.substr(option.size(), line.size() - option.size()));
}

/* return a trimmed string */
std::string cfg_manager::__trim(const std::string& s)
{
    if (s.empty()) {
	return s;
    }
    int pos = 0;
    std::string line = s;
    int len = line.length();
    while (pos < len && isspace( line[pos] )) {
	++pos;
    }
    line.erase( 0, pos );
    pos = line.length()-1;
    while (pos > -1 && isspace( line[pos] )) {
	--pos;
    }
    if (pos != -1) {
	line.erase(pos+1);
    }
    return line;
}

const std::string& cfg_manager::get(const std::string option)
{
    return options[option];
}


cfg_manager::~cfg_manager()
{

}

//#include<iostream>
//int main()
//{
//    cfg_manager cfg;
//    if (auto err = cfg.read_conf("/home/shibinglanya/slim.conf")) {
//	std::cout << err.value() << std::endl;
//	return 1;
//    }
//    std::cout << cfg.get("background_path") << std::endl;
//}
