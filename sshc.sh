#!/bin/bash

SSHC_PATH=$HOME'/.sshc'
if [ ! -d $SSHC_PATH ] ; then
    mkdir "$SSHC_PATH"
fi

case "$1" in
    -a | --add)
        touching_name="$2"
        touching_env="$3"
        touching_entrance="$4"
        touching_file=$SSHC_PATH'/'$touching_name

        touch "$touching_file"

        if grep -q '^'$touching_env'=' $touching_file ; then
            sed -i.bak '
                /^'$touching_env'=.*/ {
                    c\
                        '$touching_env'='$touching_entrance'
                }' $touching_file
            echo "Change enviroment '$touching_env' to '$touching_name'"
        else
            echo $touching_env'='$touching_entrance >> $touching_file
            echo "Added new enviroment '$touching_env' to '$touching_name'"
        fi

        exit 0
        ;;

    -l | --list)
        for file in $(find $SSHC_PATH -maxdepth 1 -type f \! -name "*.*") ; do
            echo $(basename $file)":"
            for line in $(cat $file ) ; do
                echo "    "$line
            done
        done
        exit 0
        ;;

    -v | --version)
        echo "Version 1.0"
        exit 0
        ;;

    -h | --help)
        # TODO
        echo $0" usage information"
        exit 0
        ;;

    *)
        touching_name="$1"
        touching_file=$SSHC_PATH'/'$touching_name
        if [ -f $touching_file ] ; then
            if [ $2 ] ; then
                touching_env="$2"
            else
                touching_env="global"
            fi
            touching_text=$(cat $touching_file)
            found_entrence=$([[ $touching_text =~ $touching_env=([^[:space:]]*) ]]; echo -n "${BASH_REMATCH[1]}")
            ssh "$found_entrence"
        else
            echo "ERROR"
            exit 1
        fi
        exit 0
        ;;
esac
