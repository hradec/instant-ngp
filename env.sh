#!/bin/bash
CD=$(dirname $(readlink -f $BASH_SOURCE))
#echo $CD
cd $CD

CORES=$(lscpu | egrep '^CPU.s' | awk '{print $(NF)}')

# the max cuda GPU architecture to build for
# export TCNN_CUDA_ARCHITECTURES=86
export TCNN_CUDA_ARCHITECTURES=61


# set expra as display, if no display
if [ "$DISPLAY" == "" ] ; then
	export DISPLAY=:40
fi
echo -e "DISPLAY=$DISPLAY\n"

# check if we're running remotely, and if we need to use virtualgl
if [ "$DISPLAY" != ":0" ] ; then
	export vglrun=vglrun
fi

# a simple version backward compatibility, for older linux installs
if [ ! -e /usr/lib/libtinfo.so.5 ] ; then
	sudo ln -s /usr/lib/libtinfo.so.6 /usr/lib/libtinfo.so.5
fi

# check if we can build with vulkan support
# set nvidia vulkan icd driver
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
export VULKAN_SDK_INSTALL=$(readlink -f $CD/dependencies/downloads/vulkan/*/x86_64/)
vulkaninfo=$VULKAN_SDK_INSTALL/bin/vulkaninfo
if [ -e $vulkaninfo ] ; then
	vulkanVersion=$($vglrun $vulkaninfo 2>/dev/null | egrep 'Vulkan Instance Version' | awk -F':' '{print $2}' | awk -F'.' '{print $1"."$2}')
fi
# if [ "$vulkanVersion" != "" ] ; then
# 	source $VULKAN_SDK_INSTALL/../setup-env.sh
# fi

# the location of pipevfx (gcc)
export PIPE=/atomo/pipeline/libs/linux/x86_64/pipevfx.5.0.0/

export OPENSSL_TARGET_FOLDER=$PIPE/openssl/1.0.2s/
export TBB_TARGET_FOLDER=$PIPE/tbb/2020_U3/
export BLOSC_TARGET_FOLDER=$PIPE/blosc/1.5.0/
export JEMALLOC_TARGET_FOLDER=$PIPE/jemalloc/5.2.1/
export GLEW_TARGET_FOLDER=$PIPE/glew/2.1.0/

# the custom python install
export PYTHON_ROOT=$(readlink -f $CD/build/python/*/)
export PYTHON_ROOT_INCLUDE=$(readlink -f $CD/build/python/*/include/python*)
export PYTHON_ROOT_LIB=$(readlink -f $CD/build/python/*/lib/python*)
export PYTHON_ROOT_LIBRARY=$(readlink -f $CD/build/python/*/lib/libpython*.*.so)
export OPENSSL_ROOT=$OPENSSL_TARGET_FOLDER
export TBB_ROOT=$TBB_TARGET_FOLDER
export BLOSC_ROOT=$BLOSC_TARGET_FOLDER
export JEMALLOC_ROOT=$JEMALLOC_TARGET_FOLDER
export GLEW_ROOT=$GLEW_TARGET_FOLDER


# now we setup pipevfx gcc to build with
export GCC_VERSION=9.3.1
export GCC_TARGET_FOLDER="$PIPE/gcc/$GCC_VERSION/"
export _CXXFLAGS=" -isystem$GCC_TARGET_FOLDER/lib/gcc/x86_64-pc-linux-gnu/$GCC_VERSION/include-fixed/\
                             -I$GCC_TARGET_FOLDER/include/c++/$GCC_VERSION/\
                             -isystem$GCC_TARGET_FOLDER/include/c++/$GCC_VERSION/\
                             -isystem$GCC_TARGET_FOLDER/include/c++/$GCC_VERSION/x86_64-pc-linux-gnu/\
                             -isystem$GCC_TARGET_FOLDER/lib/gcc/x86_64-pc-linux-gnu/$GCC_VERSION/include/\
                             -isystem$GCC_TARGET_FOLDER/lib/gcc/x86_64-pc-linux-gnu/$GCC_VERSION/include/c++\
                             -isystem$GCC_TARGET_FOLDER/lib/gcc/x86_64-pc-linux-gnu/$GCC_VERSION/include/c++/x86_64-pc-linux-gnu/\
                             -isystem/usr/include "


export PATH=$GCC_TARGET_FOLDER/bin:$PATH

# export CC=/bin/gcc
# export CXX=/bin/g++
# export LD_PRELOAD=/usr/lib/libstdc++.so.6:/usr/lib/libgcc_s.so.1
if [ $(/bin/gcc --version | head -1 | awk '{print $(NF)}' | awk -F'.' '{print $1}') -lt 9 ] ; then
	export LD_PRELOAD=$GCC_TARGET_FOLDER/lib/libstdc++.so.6:$GCC_TARGET_FOLDER/lib/libgcc_s.so.1
fi
	export ABI=" -D_GLIBCXX_USE_CXX11_ABI=0 -std=c++14 "
	export CC="$GCC_TARGET_FOLDER/bin/gcc"
	export CXX="$GCC_TARGET_FOLDER/bin/g++"
	export AR="$GCC_TARGET_FOLDER/bin/ar"
	export RANLIB="$GCC_TARGET_FOLDER/bin/ranlib"
	export PATH=$PIPE/llvm/7.1.0/bin/:$PATH
	export PATH=$GCC_TARGET_FOLDER/bin/:$PATH
# export PIPE_CUDACXX="$PIPE/llvm/7.1.0/bin/clang++ -D__CUDACC_VER_MAJOR__=10 -D__CUDACC_VER_MINOR__=2 "
# export PIPE_CUDACXX="$PIPE/llvm/7.1.0/bin/clang++  -D_GLIBCXX_USE_CXX11_ABI=0 -std=c++14  "
# export PIPE_CUDACXX="/bin/g++ $ABI "
export PIPE_CUDACXX="$CXX $ABI "

export PYTHON_VERSION=$(readlink -f $CD/dependencies/downloads/python/* | awk -F'Python-' '{print $2}')
export PYTHON_VERSION_MAJOR=$(echo $PYTHON_VERSION | awk -F'.' '{print $1"."$2}')

export BOOST_ROOT=$CD/dependencies/downloads/boost/install/
export BOOST_TARGET_FOLDER=$BOOST_ROOT
export DBoost_LIBRARY_DIRS=$BOOST_ROOT/lib
export Python_ROOT_DIR=$PYTHON_ROOT

export CMAKE=$(readlink -f $CD/dependencies/downloads/cmake/*/)
export CMAKE_EXTRA=" -DENABLERTTI=1 $CMAKE_EXTRA "
export CMAKE_EXTRA=" -Wno-dev $CMAKE_EXTRA "
export CMAKE_EXTRA=" -D Python_EXECUTABLE=$PYTHON_ROOT/bin/python3 $CMAKE_EXTRA "
export CMAKE_EXTRA=" -D Boost_LIBRARY_DIRS=$DBoost_LIBRARY_DIRS/ $CMAKE_EXTRA "
export CMAKE_EXTRA=" -D Tbb_INCLUDE_DIR=$TBB_TARGET_FOLDER/include $CMAKE_EXTRA "
# export CMAKE_EXTRA=" -D Tbb_LIB_COMPONENTS=$TBB_TARGET_FOLDER/lib/libtbb.so $CMAKE_EXTRA "

export CXXFLAGS=" -I$OPENSSL_TARGET_FOLDER/include -I$OPENSSL_TARGET_FOLDER/include/openssl $CXXFLAGS "
export CXXFLAGS=" -I$PYTHON_ROOT_LIB/site-packages/numpy/core/include/numpy/ $CXXFLAGS "
export CXXFLAGS=" -I$PYTHON_ROOT_LIB/site-packages/numpy/core/include/ $CXXFLAGS "
export CXXFLAGS=" -I$PIPE/qt/5.15.2/include $CXXFLAGS "
export CXXFLAGS=" -I$BOOST_ROOT/include $CXXFLAGS "
export CXXFLAGS=" -I$PIPE/blosc/1.15.1/include $CXXFLAGS "
export LDFLAGS=" -L$PYTHON_ROOT/lib $LDFLAGS "
export LDFLAGS=" -L$PIPE/blosc/1.15.1/lib $LDFLAGS "
export LDFLAGS=" -L$PIPE/llvm/7.1.0/lib $LDFLAGS "
export LDFLAGS=" -L$BOOST_ROOT/lib $LDFLAGS "
export LDFLAGS=" -L$OPENSSL_TARGET_FOLDER/lib $LDFLAGS "

# export LD_PRELOAD=$OPENSSL_TARGET_FOLDER/lib/libcrypto.so:$OPENSSL_TARGET_FOLDER/lib/libssl.so:$LD_PRELOAD


# export CUDACXX="nvcc -D__CUDACC_VER_MAJOR__=10 -D__CUDACC_VER_MINOR__=2 "
export CUDACXX="nvcc --cudart shared --cudadevrt shared "

export CUDA_INSTALL_DIR=$(readlink -f $CD/dependencies/downloads/cuda/*_install/)
# export CUDA_INSTALL_DIR=$(readlink -f ~/dev/instant-ngp/cuda/10.2.89_440.33.01/)

export OptiX_INSTALL_DIR=$(readlink -f $CD/dependencies/downloads/optix/*_install/)

export LD_LIBRARY_PATH=$CUDA_INSTALL_DIR/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$CUDA_INSTALL_DIR/lib:$LD_LIBRARY_PATH
# export LD_LIBRARY_PATH=$CUDA_INSTALL_DIR/targets/x86_64-linux/lib/stubs/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PYTHON_ROOT/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PYTHON_ROOT/bin:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PIPE/qt/5.15.2/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$(readlink -f $CD/dependencies/downloads/openjpeg/*/lib):$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$(echo $LDFLAGS | sed 's/ //g' | sed 's/-L/:/g' | sed 's/::/:/g'):$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$(readlink -f $CD/dependencies/downloads/openvdb/install/lib):$LD_LIBRARY_PATH
export PATH=$VULKAN_SDK_INSTALL/bin/:$PATH
export PATH=$PYTHON_ROOT/bin/:$CMAKE/bin/:$CUDA_INSTALL_DIR/bin:$PATH

# create RPATH from LD_LIBRARY_PATH
export RPATH=$LD_LIBRARY_PATH

# create rpath parameters from -L parameters on LDFLAGS
# export CXXFLAGS=" $_CXXFLAGS $CXXFLAGS "
# -D_GLIBCXX_USE_CXX11_ABI=1  -std=c++11 -fno-sized-deallocation "
export LDFLAGS=" $LDFLAGS $(echo $LDFLAGS | sed 's/-L/-Wl,-rpath,/g') $(echo $LDFLAGS | sed 's/-L/-Wl,-rpath-link,/g')"
export CFLAGS=" $CFLAGS $CXXFLAGS "
export CXXFLAGS=" $ABI $CXXFLAGS "
export CC="$CC $CFLAGS"
export CXX="$CXX $CXXFLAGS"
export LD="$CXX $LDFLAGS"


sudo rm -rf /usr/lib64/openjpeg*
export CMAKE_MODULE_PATH=$(readlink -f $CD/dependencies/downloads/openjpeg/*/lib/openjpeg*/)
for each in $(ls -d $(readlink -f $PIPE/qt/5.15.2/lib/cmake/)/*) ; do
	export CMAKE_MODULE_PATH=$each:$CMAKE_MODULE_PATH
done

export PYTHONPATH=$PYTHON_ROOT/../../ #:$PYTHONPATH
export PYTHONPATH=$PYTHONPATH:$(readlink -f $CD/dependencies/downloads/openvdb/install/lib/python3*/site-packages/)
