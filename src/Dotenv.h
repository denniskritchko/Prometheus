#ifndef DOTENV_H
#define DOTENV_H

#include <string>
#include <map>

class Dotenv {
public:
    static std::map<std::string, std::string> load(const std::string& path);
};

#endif // DOTENV_H
