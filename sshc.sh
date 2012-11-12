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

Usage:

  $ sshc --add server_name development me@server.com
  $ sshc --add my_awesome_server global now@127.0.0.1
  $ sshc --add server_name test \"test@test -p 3001\"

  $ sshc server_name test  #=> ssh me@server.com
  $ sshc server_name test  #=> ssh test@test -p 3001
  $ sshc my_awesome_server  #=> ssh now@127.0.0.1

  $ cd ~/projects/my_awesome_server
  $ sshc => sshc my_awesome_server global

  $ sshc -l

  my_awesome_server:
      global=now@127.0.0.1
  server_name:
      development=me@server.com
      test=test@test

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
        for file in $(find $SSHC_PATH/ -mindepth 1 -maxdepth 1 -type d) ; do
            echo $(basename $file)":"
            for line in $(find $file -maxdepth 1 -type f \! -name "*.*") ; do
                echo "  "$(basename $line)": "$(cat $line)
            done
        done
        exit 0
        ;;

    --update)
        echo "Updating sshc from git..."
        cd $(dirname $0)
        git pull
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
                if [ $1 ] ; then
                    echo "sshc shortcut $touching_name $touching_env was not found"
                else
                    echo "sshc shortcut $project_touching_name $default_touching_env was not found"
                fi
                exit 1
            fi
        fi
        exit 0
        ;;
esac
