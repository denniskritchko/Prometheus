#ifndef GEMINI_API_H
#define GEMINI_API_H

#include <string>
#include <vector>

class GeminiAPI {
public:
    GeminiAPI(const std::string& apiKey);
    std::string processImage(const std::vector<char>& imageData);

private:
    std::string apiKey;
};

#endif // GEMINI_API_H
