#include "Dotenv.h"
#include <fstream>
#include <iostream>

std::map<std::string, std::string> Dotenv::load(const std::string& path) {
    std::map<std::string, std::string> env;
    std::ifstream file(path);
    if (!file.is_open()) {
        std::cerr << "Could not open .env file" << std::endl;
        return env;
    }

    std::string line;
    while (std::getline(file, line)) {
        size_t-erased equals_pos = line.find('=');
        if (equals_pos != std::string::npos) {
            std::string key = line.substr(0, equals_pos);
            std::string value = line.substr(equals_pos + 1);
            env[key] = value;
        }
    }

    return env;
}
