#!/bin/bash
LC_ALL=C
PATH=/usr/bin:/bin

# Color codes and symbols
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN_TICK="${GREEN}✔${NC}"
RED_CROSS="${RED}✘${NC}"

bail() { 
    echo -e "${RED_CROSS} FATAL: $1"
    exit 1
}

grep --version > /dev/null 2> /dev/null || bail "grep does not work"
sed '' /dev/null || bail "sed does not work"
sort /dev/null || bail "sort does not work"

ver_check() {
    if ! type -p $2 &>/dev/null; then
        echo -e "${RED_CROSS} ERROR: Cannot find $2 ($1)"
        return 1
    fi
    v=$($2 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
    if printf '%s\n' $3 $v | sort --version-sort --check &>/dev/null; then
        printf "${GREEN_TICK} OK: %-9s %-6s >= %s\n" "$1" "$v" "$3"
        return 0
    else
        printf "${RED_CROSS} ERROR: %-9s is TOO OLD ($3 or later required)\n" "$1"
        return 1
    fi
}

ver_kernel() {
    kver=$(uname -r | grep -E -o '^[0-9\.]+')
    if printf '%s\n' $1 $kver | sort --version-sort --check &>/dev/null; then
        printf "${GREEN_TICK} OK: Linux Kernel %s >= %s\n" "$kver" "$1"
        return 0
    else
        printf "${RED_CROSS} ERROR: Linux Kernel (%s) is TOO OLD (%s or later required)\n" "$kver" "$1"
        return 1
    fi
}

# Coreutils first because --version-sort needs Coreutils >= 7.0
ver_check Coreutils sort 8.1 || bail "Coreutils too old, stop"
ver_check Bash bash 3.2
ver_check Binutils ld 2.13.1
ver_check Bison bison 2.7
ver_check Diffutils diff 2.8.1
ver_check Findutils find 4.2.31
ver_check Gawk gawk 4.0.1
ver_check GCC gcc 5.2
ver_check "GCC (C++)" g++ 5.2
ver_check Grep grep 2.5.1a
ver_check Gzip gzip 1.3.12
ver_check M4 m4 1.4.10
ver_check Make make 4.0
ver_check Patch patch 2.5.4
ver_check Perl perl 5.8.8
ver_check Python python3 3.4
ver_check Sed sed 4.1.5
ver_check Tar tar 1.22
ver_check Texinfo texi2any 5.0
ver_check Xz xz 5.0.0
ver_kernel 4.19

if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]; then
    echo -e "${GREEN_TICK} OK: Linux Kernel supports UNIX 98 PTY"
else
    echo -e "${RED_CROSS} ERROR: Linux Kernel does NOT support UNIX 98 PTY"
fi

alias_check() {
    if $1 --version 2>&1 | grep -qi $2; then
        printf "${GREEN_TICK} OK: %-4s is %s\n" "$1" "$2"
    else
        printf "${RED_CROSS} ERROR: %-4s is NOT %s\n" "$1" "$2"
    fi
}

echo "Aliases:"
alias_check awk GNU
alias_check yacc Bison
alias_check sh Bash

echo "Compiler check:"
if printf "int main(){}" | g++ -x c++ -; then
    echo -e "${GREEN_TICK} OK: g++ works"
else
    echo -e "${RED_CROSS} ERROR: g++ does NOT work"
fi
rm -f a.out

if [ "$(nproc)" = "" ]; then
    echo -e "${RED_CROSS} ERROR: nproc is not available or it produces empty output"
else
    echo -e "${GREEN_TICK} OK: nproc reports $(nproc) logical cores are available"
fi

