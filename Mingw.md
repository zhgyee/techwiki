# Install Mingw-w64 Toolchain

* Install msys2.
* Open the MSYS2 MinGW 64-bit terminal.
* Type: pacman -Syu --noconfirm and press enter.
* Close and reopen the msys2 terminal.
* Note that pacman may need to update itself before updating other packages, so repeat the above two steps until pacman no longer updates anything.
* Type: pacman -S mingw-w64-x86_64-gcc --noconfirm and press enter.
* Close the msys2 terminal