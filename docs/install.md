Puppet Boilerplate Environment Setup
====================================

Introduction
------------

This document describes how to setup Puppet Boilerplate. There are four main components in
this setup, we will describe them separately to make it easier to understand and then describe how they 
interact together. Then we will finally describe how to install all these components on a new site.


Component 1 - _The git repo_
-----------------------------

The source of authority for systems/servers state is the Git repo. 
For developers, the basic workflow is the same they use with any other repository, they fork it into their account, do any desired
change and then do a pull request to the main Puppet repo where one of the sysadmins will aprove their request and apply it to the
affected systems. For sysadmins/ops, given the nature of their work, this workflow doesn't fit perfectly, so we recommend using a different approach
internally, more similar to the old plain Subversion style. The core reason for this difference is that, when running out of date
puppet code on our servers, you could undo changes somebody else already did. This would for example prevent two different sysadmins
doing changes in parallel. Given that we are talking about production servers among other things, this is pretty critical.For the details
of the proposed workflow, see the main [README.md](../README.md).


Component 2 - _The admin server_
--------------------------------

The 'admin' server is the central point of systems management. It is the front door of our sites. In this sense, for the sake of simplocity
let's assume an example where we have two sites, _example.com_ and _dev_. _example.com_ and is our main datacenter and the one we call _dev_ is 
located in our office and is the development environment. The former hosts the prodction server and the latter the dev host plus any IT server.
As these environments have no knowledge of each other (mainly because of decoupling and security reasons) we currently have two _admin_ 
entrances. For example.com it is a redundant set of servers, _admin1.example.com_ and _admin2.example.com_ where the second is a failover backup for admin1,
in case it has to be shutdown or has any hardware failure. It also allow us to apply changes to admin itself first to one of them, and 
if it doesn't break, apply the change to the other one. This way the risk of kicking out ourselves is reduced.


In the scope of Puppet, our admin servers hosts the following artifacts:

  1. A checkout of the git repo, inside your user HOME directory.
  2. A puppet daemon listening for incoming connections from puppetized servers.
  3. A GPG key able to decrypt the keyring for reading passwords from puppet classes.
  4. puppet.{domain} pointing to it (puppet.example.com or puppet.dev, for example)
 

Component 3 - _The keyring_
-------------------------------

The keyring is basically the same thing you can find on your laptop OS, your browser, etc, where there is a central place for storing 
personal information, and that despite that info is stored in cleartext (because it will be later needed for autocomplete, for example), 
the file is later encrypted with your login password or similar.

In our case, our keyring are files under the _keyrings/_ folder, our personal information are mostly passwords for services, and our
encryption/decryption key is a GPG key stored under the root account, and thus, protected by the root password.

Our keyring supports the concept of _sites_ we described above, in the sense that we have a keyring that can be decrypted only by 
admin servers in the example.com site, and other keyring which can only be decrypted in the dev site. This way we don't need to share passwords, we
don't need to put them in cleartex in the git repo, we have versioning anyway, and once set up the environment, is 100% transparent and easy
to use, which helps in the feature being used in the end.


Component 4 - _The puppetized servers_
---------------------------------------

Once you have the correct admin environment working, adding a new server to puppet management is pretty straightforward. In the repo
root directory, you will see that there are a set of scripts that will help you among other things to setup them. For now, it is enough
to say that for adding a new server to the Puppet workflow the only thing you need is to have it up and running, able to access the 
puppet server at puppet.whatever.site.domain on port tcp/8139 and with ssh enabled for root access.


How it all fits together?
------------------------

Once all the components are in place, the workflow is usually the following:

  1. You mount with sshfs your home directory _from_ an admin server _to_ your laptop.
  2. You checkout from your laptop a copy of the repo from github
  3. You do any changes on the source files, maybe in your laptop with an ide or on admin itself with vim.
  4. You push your changes to the github repo, if there are no conflicts then you are ready to go.
  5. You apply your changes from admin, with the ./apply.sh script to the servers affected by your changes.
     Don't forget to update all the affected servers, otherwise those changes may take by surprise the next one doing changes on it
  6. When you run apply.sh on the host web1.example.com for example, admin will ssh to it, run the puppet agent which will connect back to admin
     on the puppet server port, retrieve the puppet catalog (the instructions) and any required configuration file.
  7. The puppet master daemon running on admin will provide the required catalog and files, reading sensible info from the keyring.
  8. You will see the output of every change done, with a diff of any config change and errors usually highlighted in purple.


Components installation
======================

The admin server and the keyring
--------------------------------
   1. Install a base debian, with just the ssh service and a static IP address.
   2. Setup the right DNS server for the site to point puppet.domain.whatever to this admin IP address, i.e. In example.com we have puppet.example.com
      as a CNAME record to admin.example.com, which is the VIP address of the failover set of admin servers.
   3. Mount via sshfs any directory (/root is ok for now) on your laptop.
   4. Checkout from your laptop the git repo, see [README.md](../README.md) for details.
   5. Edit manifests/nodes/admin.pp and create a new node, whose name matches exactly the hostname of this new host, for example, if setting up
      admin.dev, you will have something like:
      ```
      node 'admin.dev' {
        include puppet::server
      }
      ```
   6. Leave it like that for now, that is, without any other includes or real service on it, so that it is easier to setup the puppet environment,
      later we can add more classes here.
   7. Initialize the gpg key, run as root inside the puppet repo root folder and follow the instructions. 
      Notes:
      * Do not put a password to the key:
      * Set 'Example.com Ops' as the certificate name
      * Set 'ops@example.com' as the email address

      ```
      # gpg --gen-key
      # ./init_gpg dev  #replace dev with the domain name of the site your are installing on.
      ```
      now you should see a new set of files (the keyring!) in keyrings/dev/*

   8. Create the file hiera/dev and add two entries like the following ones:
      ```
      admin_mysql_root_password: <any random string>
      admin_mysql_puppet_password: <any other random string>
      ```

   9. Encrypt the previous file to be decryptable only by this environment
      ```
      $ ./encrypt.sh dev hiera/dev
      ```

   10. Init puppet master daemon. This will copy an initial puppet configuration file set and start the puppet master daemon
      ```
      # ./init_master.sh
      ```

   11. You are ready, now you will install puppet client and apply the current definition of this host as if it were a remote client.
      You will be prompted a couple times for root password.
     
     ```
     # ./agent_install admin.dev
     ```

From now on, if you want to do more changes on the server, do the changes you need on puppet files and then run ./apply.sh admin.dev.


Add a server to the puppet systems
----------------------------------

Adding an external (to admin) server to puppet is pretty straightforward, just ensure the new client can access the puppet daemon on your admin
(puppet.dev,puppet.example.com, etc) on port tcp/8139 and that it has ssh access for root enabled. Then the first time, run it with ./agent_install.sh 
<hostname> and later after a successful first run, with ./apply.sh. The agent install can be run as many times as desired, but it does a lot of
unnecesary things if it is not the first time you are running it.



