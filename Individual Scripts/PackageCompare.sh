#!/bin/bash
echo "================================================"
echo "        Select Database to Compare"
echo "================================================"
echo "         1. Base Install Packages"
echo "         2. Full Install Packages"
echo "         3. Security Packages"
echo "         4. Focal Updates"
echo "         5. Focal All"
echo "         6. Custom"
A=true
echo "=============================================================" >> Package_Differences
dpkg-query -W -f='${binary:Package}\n' > PackageList
read -p "" input
    case $input in
        1) Package="BaseRef";;
        2) Package="FullRef";;
        3) Package="SecRef";;
        4) Package="UpdRef";;
        5) Package="FAllRef";;
        5) Custom;;
    esac
read -p "Filter out Packages not on system(type y or n): " filter
Custom() {
    read -p "Please input Reference File Name: "$custom
    diff -u PackageList $custom | sed -n '1,2d;/^[-+]/p' > temp
    if [ $filter ="n" ]
    then
        sed '/^+/ d' < temp >> Package_Differences
    else
        echo < temp >> Package Differences
    fi
    A=false
}

if [ $A = true ] 
then
    diff -u PackageList $Package | sed -n '1,2d;/^[-+]/p' > temp
    echo "Differences are stored in Package_Differences"
    if [ $filter ="n"]
    then
        sed '/^+/ d' < temp >> Package_Differences
    else
        echo < temp >> Package Differences
    fi
fi
rm PackageList
rm temp