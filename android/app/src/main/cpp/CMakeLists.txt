cmake_minimum_required(VERSION 3.4.1)

add_library( # Sets the name of the library.
             piano_engine

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             piano_engine.cpp
             android_audio.cpp )

find_library( # Sets the name of the path variable.
              log-lib

              # Specifies the name of the NDK library that
              # you want CMake to locate.
              log )

target_link_libraries( # Specifies the target library.
                       piano_engine
                       android
                       ${log-lib} 
                       OpenSLES )
