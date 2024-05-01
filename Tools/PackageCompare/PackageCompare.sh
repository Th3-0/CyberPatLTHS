#!/bin/bash
echo "================================================"
echo "        Select Database to Compare"
echo "================================================"
echo "         1. Base Install Packages"
echo "         2. Full Install Packages"
echo "         3. Focal Updates"
echo "         4. Focal All"
echo "         5. Custom"
A=true
echo "=============================================================" >> Package_Differences
dpkg-query -W -f='${binary:Package}\n' > PackageList
read -p "" input
    case $input in
        1) Package="BaseRef";;
        2) Package="FullRef";;
        3) Package="UpdRef";;
        4) Package="FAllRef";;
        5) Custom;;
    esac

Custom() {
    read -p "Please input Reference File Name: "$custom
    diff -u PackageList $custom | sed -n '1,2d;/^[-+]/p' >> Package_Differences
    A=false
}

if [ $A = true ] 
then
    diff -u PackageList $Package | sed -n '1,2d;/^[-+]/p' >> Package_Differences
    echo "Differences are stored in Package_Differences"
fi
rm PackageList