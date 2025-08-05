#include "GeminiAPI.h"
#include <curl/curl.h>
#include <iostream>
#include <sstream>
#include "base64.h"

// Callback function to write response data
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* s) {
    size_t newLength = size * nmemb;
    try {
        s->append((char*)contents, newLength);
    } catch (std::bad_alloc& e) {
        // Handle memory allocation errors
        return 0;
    }
    return newLength;
}

GeminiAPI::GeminiAPI(const std::string& apiKey) : apiKey(apiKey) {}

std::string GeminiAPI::processImage(const std::vector<char>& imageData) {
    CURL* curl;
    CURLcode res;
    std::string response;

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
    if (curl) {
        std::string url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=" + apiKey;
        
        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: application/json");

        std::string base64_image = base64_encode(reinterpret_cast<const unsigned char*>(imageData.data()), imageData.size());

        std::stringstream json_payload;
        json_payload << "{ \"contents\":[ { \"parts\":[ { \"text\": \"What is in this image?\"}, { \"inline_data\": { \"mime_type\":\"image/jpeg\", \"data\": \"" << base64_image << "\" } } ] } ] }";
        std::string json_str = json_payload.str();

        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_str.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);

        res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
        }

        curl_easy_cleanup(curl);
        curl_slist_free_all(headers);
    }
    curl_global_cleanup();

    return response;
}
