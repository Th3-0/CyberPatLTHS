#!/bin/bash

    echo "================================================================" 
    echo "                     PASSWORDS AND USERS                               "
    echo "     output for this is stored in separate UserChangeLog file"
    echo "================================================================"
    CurrentUser=$(whoami)
   sudo apt install members -yq
    if [ $CurrentUser != "root" ]
    then
        echo "============================================"
        echo "   THIS MUST SCRIPT MUST BE RUN WITH SUDO"
        echo "============================================"
        exit
    fi
    echo "========================================================================================="
    echo "   THIS SCRIPT WILL PERMANANTLY MODIFY USERS. IF YOU DO NOT WISH TO CONTINUE EXIT NOW."
    echo "========================================================================================="

    updateUserDefs() {
    mapfile -t AllCurrentUsers < <(getent passwd {1000..1500} | cut -d: -f1) 
    mapfile -t CurrentAdminUsers < <(members sudo)
    mapfile -t CurrentNormUsers < <(echo ${AllCurrentUsers[@]} ${CurrentAdminUsers[@]} | tr ' ' '\n' | sort | uniq -u)
    }
    updateUserDefs
    CurrentAdminUsers+=("root")

    read -p "Readme Path: " path

    mapfile -t NeededStandard < <(sed -n '/Authorized Users:<\/b>/, /</{ /Authorized Users:<\/b>/! { /</! p } }' $path | xargs)
    mapfile -t NeededUsers < <(sed -n '/Authorized Administrators:/, /</{ /Authorized Administrators:/! { /</! p } }' $path | sed -n '1~2p' |cut -d" " -f1 | xargs)
    if (( ${#NeededStandard[@]} == 0 )); 
    then
        echo "STANDARD USERS NOT DEFINED"
    fi
    if (( ${#NeededUsers[@]} == 0 )); 
    then
        echo "ADMINS NOT DEFINED"
    fi
    NeededUsers+=("root")
    MainUser=${NeededUsers[0]}

    #admin user differences
    mapfile -t AdminDiffs < <(echo ${CurrentAdminUsers[@]} ${NeededUsers[@]} | tr ' ' '\n' | sort | uniq -u)

    for (( i=0; i<${#AdminDiffs[@]}; i++ ));
    do
        if [[ ${NeededUsers[*]} =~ ${AdminDiffs[i]} ]]
        then #if user is on README but not currently admin
            if [[ ${CurrentNormUsers[*]} =~ ${AdminDiffs[i]} ]]
            then # user is a standard user that needs to be upgraded
                usermod -aG sudo ${AdminDiffs[i]}
                usermod -aG adm ${AdminDiffs[i]}
                echo "change standard user ${AdminDiffs[i]} to admin" >> UserChangeLog
            elif [[ ! ${CurrentNormUsers[*]} =~ ${AdminDiffs[i]} ]]
            then # user is not present on system
                useradd -s /bin/bash -m -G sudo ${AdminDiffs[i]}
                echo "add admin user ${AdminDiffs[i]}" >> UserChangeLog
            fi
        elif [[ ! ${NeededUsers[*]} =~ ${AdminDiffs[i]} ]]
        then #user is on system but not readme
            if [[  ${NeededStandard[*]} =~ ${AdminDiffs[i]} ]]
            then
                deluser ${AdminDiffs[i]} sudo
                echo "downgrade Admin ${AdminDiffs[i]} to standard" >> UserChangeLog 
            else
                userdel -rf ${AdminDiffs[i]}
                echo "remove user ${AdminDiffs[i]}" >> UserChangeLog

            fi

        fi
    done
    #==================STANDARD USERS==============
    #update users
    updateUserDefs
    #standard user differences
    mapfile -t StandardDiffs < <(echo ${CurrentNormUsers[@]} ${NeededStandard[@]} | tr ' ' '\n' | sort | uniq -u)

    for (( i=0; i<${#StandardDiffs[@]}; i++ ));
    do
        if [[ ${NeededStandard[*]} =~ ${StandardDiffs[i]} ]]
        then #if user is on README but not currently on system
            if [[ ${CurrentAdminUsers[*]} =~ ${StandardDiffs[i]} ]]
            then #user is admin that needs to be downgraded(shouldnt happen but is here just in case)
                deluser ${StandardDiffs[i]} sudo
                deluser ${StandardDiffs[i]} adm
                echo "change admin ${StandardDiffs[i]} to standard user" >> UserChangeLog
            elif [[ ! ${CurrentAdminUsers[*]} =~ ${StandardDiffs[i]} ]]
            then # user is not present on system
                useradd -s /bin/bash -m ${StandardDiffs[i]}
                echo "add standard user ${StandardDiffs[i]}" >> UserChangeLog
            fi
        elif [[ ! ${NeededStandard[*]} =~ ${StandardDiffs[i]} ]]
        then #user is on system but not Readme
            if [[  ${NeededUsers[*]} =~ ${StandardDiffs[i]} ]]
            then #(again somewhat redundant) user is supposed to be admin
                usermod -aG sudo ${StandardDiffs[i]}
                usermod -aG adm ${StandardDiffs[i]}
                echo "upgrade standard ${StandardDiffs[i]} to admin" >> UserChangeLog
            else #user should not be on machine
                userdel -rf ${StandardDiffs[i]}
                echo "remove user ${StandardDiffs[i]}" >> UserChangeLog
            fi
        fi
    done
    clear
    echo "  check UserChangeLog file to find, troubleshoot or review what was edited"
    echo "============================================================================"
    echo "                                PASSWORDS                                   "
    echo "============================================================================"
    echo "ALL PASSWORDS EXCEPT ROOT AND MAIN USER WILL BE CHANGED TO [Cyb3rPatr!0t$]"
    #=============PASSWORDS============
    updateUserDefs
    #====================================================================================================================
    #FOR THE LOVE OF ALL THAT IS HOLY PLEASE NEVER DO THIS ON SOMETHING THAT ISN'T A CYBERPATRIOTS COMPETITION.
    #IT IS HORRIBLY INSECURE(cyberpatriots doesn't detect or care though). IT IS A STUPID FUCKING WORKAROUND FOR SPEED 
    #BASICALLY MAKES PASSWORD VIEWABLE BY ANYBODY WHO HAS ACCESS TO PS COMMAND.
    #========================================================================================================================
    for (( i=1; i<${#AllCurrentUsers[@]}; i++ ));
    do
        if [[ ${AllCurrentUsers[i]} != "root" ]]
        then
            echo "changing password for ${AllCurrentUsers[i]}"
            echo "${AllCurrentUsers[i]}:Cyb3rPatr!0t$" | chpasswd
        fi
    done