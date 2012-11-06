#ssh + controller = sshc

SSHC is the storage for your SSH connections. You don't need to remember username, host or port number from your SSH credentials anymore.

##Installation


    mkdir -p ~/.oh-my-zsh/custom/plugins
    cd ~/.oh-my-zsh/custom/plugins
    git clone git://github.com/SeTeM/sshc.git

And then enable `sshc` plugin in your `oh-my-zsh` config.


##Usage


    $ sshc --add server_name development me@server.com
    $ sshc --add server_name test test@test -p 3001
    $ sshc --add my_awesome_server global now@127.0.0.1

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

    $ sshc --update => fetch fresh version of sshc from git

If you have ideas on how to make the it better, don’t hesitate to fork and send pull requests!