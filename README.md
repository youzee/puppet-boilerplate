Puppet Boilerplate
================

Introduction
------------
This is a basic structure for puppet usage in push mode. In a typical usage, you setup the Puppet master with all your files, 
and every agent runs continuously on client hosts polling for changes in their definitions and applying them. This setup
focuses on giving you the control on when to push a change, to which server(s) and watching the output of the process in 
real time, while they are being applied. Here we assume you use Github for your code, although this is independent of the
VCS and you just have to replace the commands for the equivalent ones.

Puppet Boilerplate has been developed by Matias Surdi at Youzee.com <matias@youzee.com>

Features
--------

  * Automatic setup of new hosts. Just ssh access required.
  * Encryption of sensitive data such as services passwords and private keys
  * Push workflow. Push to one host, a host group or all of them
  * Multiple sites/domains/environments (ie: Development, Production, etc). No conectivity required between them

Some concepts
-------------
  * _Admin_ host: The server where the puppet master is running, and from where you run the apply.sh script to
    make changes actually happen on other hosts. This host's root accounnt also holds the private key for hiera data decryption
  * Puppet _manifests_: Located in the manifests/ directory, these are the mappings that assign puppet modules to hostnames
  * Puppet _modules_: Located in the modules/ directory, these are just puppet .pp files. You are free to modify the provided
    files, but remember they are required for setting up new admin hosts, and initializing new clients. 
  * hiera: Hiera is the system used for encrypting sensitive data, refer to [this](http://puppetlabs.com/blog/first-look-installing-and-using-hiera/)
    for more details

How to use it (for devs/non-root)
---------------------------------
Usually you will have all these scripts and your puppet modules on a version control system such as Git or SVN. Any developer
or non-root/non-ops member will then use it like any other code repo, just tell them the following instructions:

  1. You can use it as any other repo. Fork it, do the changes in your copy, and submit a pull request.
  2. Ask a sysadmin/ops to apply your changes, if you are lucky he will accept your pull request, update his 
     copy of the puppet files in his home directory on the right admin host, and apply them.


How to use it (For sysadmins/ops)
---------------------------------
  1. Ensure you have a proper _admin_ environment/installation to run puppet. Read _install.md_ in the docs directory if you don't.
  2. Using sshfs (or similar), mount your *remote* admin home dir somewhere into your laptop.

     ```
     my-laptop ~$ mkdir mnt
     my-laptop ~$ sshfs <youruser>@<admin>: mnt
     my-laptop ~$ cd mnt
     ```

  3. Clone and config the your puppet repo.

    ```
    my-laptop ~/mnt$ git clone git@github.com:yourusername/puppet.git
    my-laptop ~/mnt$ cd puppet
    my-laptop ~/mnt/puppet$ git remote add upstream git@github.com:yourusername/puppet.git
    my-laptop ~/mnt/puppet$ git config user.email "me@example.com"
    ```

  4. Do any change you wish, usually in  manifests/* or modules/*
  5. Commit your changes locally

    ```
    my-laptop ~/mnt/puppet$ git add modules/my/changed/file
    my-laptop ~/mnt/puppet$ git commit -m 'I fixed this and that'
    ```
  6. Upload your changes to github

    ```
    my-laptop ~/mnt/puppet$ git push origin master
    ```
  7. If the previous command warns you about any conflict, this means that somebody else did other changes and you have
     to pull the changes from github again, and merge your code. Look at github help or ask somebody else if you don't know
     how to do it. The ouput provided by git is usually very helpful, read it.
 
  8. Once you pushed your changes to github (you did right?), ssh to your admin server, and apply/test/debug your changes on 
     the servers you want until you are happy with it

    ```
    my-laptop ~/mnt/puppet$ ssh admin
    admin ~$ cd puppet
    admin ~/puppet$ sudo ./apply.sh web3.example.com web5.example.com
    ```


How the code is organized
------------------------

Usually there is a module for each independent service that can be provided by a host. For example, 
in modules/dns you will find the files and manifests for installing and configuring
bind9 even as a master dns server or as a slave one. There is a Class for every service 
(master/slave), and in init.pp there is a generic class for shared requirements between 
service classes.This is just a suggestion, you are free to adapt this how it fits best your mind.

To create a new module, run:

```
my-laptop ~/puppet$ cd modules
my-laptop ~/puppet/modules$ mkdir -p mymodule/manifests
my-laptop ~/puppet/modules$ vim mymodule/manifests/init.pp
```

To specify which server/configuration should be in what host, associate it in the manifests/site.pp file or
its corresponding manifests/nodes/[host kind].pp file.
It is recommended to "touch" a file in hosts/all/hostname.domainname and on any other group, like for 
example hosts/web/web1.example.com so that later you can run apply like ./apply.sh hosts/web/*


Recommendations for development environment and workflow
------------------------------------------------
  
  1. Always mount your home directory on admin.{example.com,dev,whatever} in your laptop, because you will be running git commands from it
     and also because your laptop can reach github, among other things that some servers can't. This way you can also have an IDE or
     your favourite editor. Also, this way, you never have _puppet code_ in your laptop, if you lose it, it is one thing less to be
     concerned about.
  2. When you run ./apply.sh, never apply it to all hosts unless you are really confident on what you are doing.If something is wrong, 
     you will break everything instead of a single host.
  3. Before applying your changes, be sure to have merged everyone else's changes from the puppet repo. If you are not running the latest
     changes from others, you will be reverting their work on the servers and it is likely that Bad Things(TM) will happen.
  4. Be careful, _a great power comes with a great responsibility_, if you do a chage without testing it and apply to all the platform, you
     can break it all.
  5. When applying changes with ./apply.sh, look carefully at the ouput. Pay special attention to any output in purple color, that is an error, 
     and has to be fixed.
  6. If a ./apply.sh failed at some point, don't run it again without fixing the code, the second run may work, but that means that there is 
     something wrong with the dependencies/order specification in the puppet files.
  7. Follow the workflow indicated in the _How to use it_ section. In particular steps 6,7 and 8 at thats helps preventing overlapping our work/changes.
  8. Remember that any change you do in a _puppetized_ host, is likely to be lost some time in the near future if it is not done with puppet.
  9. Actually it is not required for an existing server to to be 100% built with puppet. If you want to do
     any change in an existing server, the new changes can be done with puppet while the other parts are kept as they are. 

Useful links
------------

  * [Puppet introduction](http://docs.puppetlabs.com/learning/)
  * [Puppet language guide](http://docs.puppetlabs.com/guides/language_guide.html)
  * [Puppet types cheatsheet](http://docs.puppetlabs.com/puppet_core_types_cheatsheet.pdf)
  * [Puppet types reference](http://docs.puppetlabs.com/references/latest/type.html)
  * [Geppetto IDE](http://puppetlabs.com/blog/geppetto-a-puppet-ide/)

