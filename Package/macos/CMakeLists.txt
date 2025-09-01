cmake_minimum_required(VERSION 3.13.2)

include(FetchContent)

# Disable the WebP plugin option
set(BABYLON_NATIVE_PLUGIN_NATIVEENGINE_WEBP OFF CACHE BOOL "Disable Babylon Native WebP Support")

project(ReactNativeBabylon)

# Set macOS deployment target
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15" CACHE STRING "")
set(ENABLE_ARC OFF CACHE STRING "Enables or disables ARC support.")
set(ENABLE_PCH OFF CACHE STRING "Enables or disables precompiled headers.")

include(${CMAKE_CURRENT_SOURCE_DIR}/../../Apps/${BUILD_RNAPP_DIR}/node_modules/@babylonjs/react-native-iosandroid/macos/CMakeLists.txt)

set_property(TARGET BabylonNative PROPERTY XCODE_GENERATE_SCHEME YES)

set(PACKAGED_LIBS
    bimg_encode
    bimg_decode
    bgfx
    bimg
    bx
    Canvas
    GenericCodeGen
    glslang
    glslang-default-resource-limits
    Graphics
    JsRuntime
    OGLCompiler
    OSDependent
    MachineIndependent
    napi
    NativeCamera
    NativeCapture
    NativeEngine
    NativeInput
    NativeOptimizations
    NativeTracing
    NativeXr
    SPIRV
    spirv-cross-core
    spirv-cross-msl
    UrlLib
    Window
    XMLHttpRequest
    Scheduling
    xr
)

foreach(packaged_lib ${PACKAGED_LIBS})
    add_custom_command(TARGET BabylonNative POST_BUILD
        COMMAND cp $<TARGET_FILE:${packaged_lib}> $<TARGET_FILE_DIR:BabylonNative>
        DEPENDS ${packaged_lib}
    )
endforeach()