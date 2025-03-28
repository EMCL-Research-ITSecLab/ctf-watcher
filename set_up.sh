#!/bin/bash
cat << "EOF"
 __          __             _       _____           _        _ _           
 \ \        / /            | |     |_   _|         | |      | | |          
  \ \  /\  / /_ _ _____   _| |__     | |  _ __  ___| |_ __ _| | | ___ _ __ 
   \ \/  \/ / _` |_  / | | | '_ \    | | | '_ \/ __| __/ _` | | |/ _ \ '__|
    \  /\  / (_| |/ /| |_| | | | |  _| |_| | | \__ \ || (_| | | |  __/ |   
     \/  \/ \__,_/___|\__,_|_| |_| |_____|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                           
                                                                         
EOF
if [ $(id -u) -ne 0 ]
then
    echo "Please run this script as root or using sudo!"
    exit 0
fi

function print_divider () {
    terminal=/dev/pts/1
    columns=$(stty -a <"$terminal" | grep -Po '(?<=columns )\d+')
    printf "%${columns}s\n" | tr " " "-"
}

function section_header () {
    print_divider
    echo "${1}..."
    print_divider
}

function section_footer () {
    echo ""
}
