install_build_deps(){
  $COMMAND_EXECUTOR zypper install -y \
                                           rpm-build \
                                           ccache \
                                           git \
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

install_test_dependencies(){
  $COMMAND_EXECUTOR zypper install -y \
                                             fftw3-devel
}