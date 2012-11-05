#!/bin/bash

SSHC_PATH=$HOME'/.sshc'
if [ ! -d $SSHC_PATH ] ; then
    mkdir "$SSHC_PATH"
fi

function echo_help {
    echo "= ssh + controller = sshc
* https://github.com/SeTeM/sshc

SSHC is a storage for your SSH connections.
You don't need to remember username, host or port number from your SSH credentials anymore.

Example:

  sshc --add my_awesome_server production app@my_awesome_server.com
  sshc my_awesome_server production  #=> ssh app@my_awesome_server.com

More information:

  sshc --help

If you have ideas on how to make the it better, don’t hesitate to fork and send pull requests!"
}

case "$1" in
    -a | --add)
        touching_name="$2"
        touching_env="$3"
        touching_entrance="$4"
        touching_file=$SSHC_PATH'/'$touching_name'/'$touching_env

        mkdir -p $SSHC_PATH'/'$touching_name

        if [ -f $touching_file ] ; then
            cat /dev/null > $touching_file
            echo "Changed enviroment '$touching_env' to '$touching_name'"
        else
            touch "$touching_file"
            echo "Added new enviroment '$touching_env' to '$touching_name'"
        fi

        echo $touching_entrance >> $touching_file

        exit 0
        ;;

    -l | --list)
        for file in $(find $SSHC_PATH -maxdepth 1 \! -name "*.*") ; do
            echo $(basename $file)":"
            for line in $(find $file -maxdepth 1 -type f \! -name "*.*") ; do
                echo "  "$(basename $line)": "$(cat $line)
            done
        done
        exit 0
        ;;

    -v | --version)
        echo "Version 1.0"
        exit 0
        ;;

    -h | --help)
        echo_help
        exit 0
        ;;

    *)
        touching_name="$1"
        default_touching_env="global"
        if [ $2 ] ; then
            touching_env="$2"
        else
            touching_env=$default_touching_env
        fi
        touching_file=$SSHC_PATH'/'$touching_name'/'$touching_env

        if [ -f $touching_file ] ; then
            touching_text=$(cat $touching_file)
            ssh $touching_text
        else
            # detect touching_name from current directory and try it
            project_touching_name=$(basename $PWD)
            project_touching_file=$SSHC_PATH'/'$project_touching_name'/'$default_touching_env
            if [ -z "$1" -a -z "$2" -a -f $project_touching_file ] ; then
                touching_text=$(cat $project_touching_file)
                ssh $touching_text
            else
                echo "sshc shortcut $touching_name $touching_env was not found"
                exit 1
            fi
        fi
        exit 0
        ;;
esac
