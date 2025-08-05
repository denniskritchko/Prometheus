# Prometheus

Prometheus is an AI-powered C++ tool that reads your screen, determines an answer, and dictates it back to you through a low-opacity, transparent overlay. It is designed to be undetectable by screen capture technology.

## Building the Project

### Prerequisites

*   A C++ compiler that supports C++17 (like Clang or GCC)
*   CMake 3.10 or higher
*   On macOS, you'll need Xcode Command Line Tools installed.

### Build Steps

1.  **Create a build directory:**
    ```bash
    mkdir build
    cd build
    ```

2.  **Run CMake to configure the project:**
    ```bash
    cmake ..
    ```

3.  **Build the project:**
    ```bash
    make
    ```

This will create an executable named `Prometheus` in the `build` directory.
