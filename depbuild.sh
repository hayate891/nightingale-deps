#!/bin/bash

ARCH="$(uname -m)"

# XUL Version
export XUL="9.0.1"

export DIR="$(cd "$(dirname "$0")" && pwd)"
export SB_VENDOR_BINARIES_CO_ROOT=$DIR
export SB_VENDOR_BUILD_ROOT=$DIR


case $OSTYPE in
    linux*)
        if [ ! -d "linux-$(uname -m)" ]; then
            mkdir -p "linux-$(uname -m)"
            mkdir -p "checkout/linux-$(uname -m)"
        fi

        cd "xulrunner"
        # fix for kernels > 3.X on versions of xul without security setup for them
        if [ ! -f mozilla/security/coreconf/Linux$(uname -r|sed -e 's/\-.*//'|grep -o "[0-9]\.[0-9]").mk ]; then
            ln -s $(pwd)/mozilla/security/coreconf/Linux2.6.mk $(pwd)/mozilla/security/coreconf/Linux$(uname -r|sed -e 's/\-.*//'|grep -o "[0-9]\.[0-9]").mk
        fi
        cd ../

        echo -e "Building xulrunner...\n"
        make -C xulrunner xr-all

        echo -e "Building sqlite...\n"
        make -C sqlite -f Makefile.songbird

        echo -e "Building taglib...\n"
        make -C taglib -f Makefile.songbird

        if [ ! -d "linux-$ARCH/mozilla-$XUL/debug" ] ; then 
            cd "linux-$ARCH/mozilla-$XUL"
            mkdir debug
            mv bin frozen idl include lib scripts debug
            cd ../../
        fi

        if [ ! -d "linux-$ARCH/xulrunner-$XUL/debug" ] ; then
            cd "linux-$ARCH/xulrunner-$XUL"
            mkdir debug
            mv xulrunner.tar.bz debug
            cd ../../
        fi
    ;;

    darwin*)
        # on OSX, we want 32 bit builds
        arch_flags="-m32 -arch i386"
        export CFLAGS="$arch_flags"
        export CXXFLAGS="$arch_flags"
        export CPPFLAGS="$arch_flags"
        export LDFLAGS="$arch_flags"
        export OBJCFLAGS="$arch_flags"

        if [ ! -d "macosx-i686" ]; then
            mkdir -p "macosx-i686"
            mkdir -p "checkout/macosx-i686"
        fi

        echo -e "Building sqlite..."
        make CC=gcc CXX=g++ -C sqlite -f Makefile.songbird
        echo -e "Building taglib..."        
        make CC=gcc CXX=g++ -C taglib -f Makefile.songbird

        echo -e "Building xulrunner and crossing our fingers..."
        make CC=gcc-4.2 CXX=g++-4.2 -C xulrunner -f Makefile.songbird xr-all
        echo "Done!"
    ;;
    *)
        echo "Lazy buildscript for your OS coming soon."
    ;;
esac


