#ifndef _CFG_MANAGER_H_
#define _CFG_MANAGER_H_

#include <string>
#include <optional>
#include <map>



class cfg_manager
{
public:
    cfg_manager();
    ~cfg_manager();

    std::optional<std::string> read_conf(const std::string &configfile);
    const std::string& get(const std::string option);

private:
    static std::string __parse_option(const std::string& line, const std::string& option);
    static std::string __trim(const std::string& s);

private:
    using option = std::pair<std::string, std::string>;

private:
    std::map<std::string, std::string> options;
};

#endif /* _CFG_MANAGER_H_ */
