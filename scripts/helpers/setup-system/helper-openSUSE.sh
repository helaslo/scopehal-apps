install_build_deps(){
  $COMMAND_EXECUTOR zypper install -y \
                                           rpm-build \
                                           ninja \
                                           cmake \
                                           gcc-c++ \
                                           pkgconf \
                                           cairomm-devel \
                                           gtk3-devel \
                                           libsigc++3-devel \
                                           yaml-cpp-devel \
                                           Catch2-devel \
                                           libhidapi-devel \
                                           libglfw-devel \
                                           lsb-release \
                                           wayland-devel
}

install_extra_ci_convenience_deps(){
  $COMMAND_EXECUTOR zypper install -y \
                                           ccache
}

install_vulkan_deps(){
  $COMMAND_EXECUTOR zypper install -y \
                              vulkan-devel \
                              shaderc \
                              shaderc-devel \
                              glslang-devel \
                              spirv-tools-devel
}

install_test_dependencies(){
  $COMMAND_EXECUTOR zypper install -y \
                                             fftw3-devel
}