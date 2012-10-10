# homesick_agent

## Description

Extends the homesick cookbook (github.com/fnichol/chef-homesick) to work with
SSH agent forwarding.  Developed and tested for the scenario of running under
Vagrant with a single user referencing a private repository

## Installation

Install dergachev/chef_homesick_agent cookbook as `CHEF-REPO/cookbooks/homesick_agent`:

    git clone git@github.com:dergachev/chef_homesick_agent.git homesick_agent 

### Install homesick cookbook

Install fnichol/chef-homesick cookbook as `CHEF-REPO/cookbooks/homesick` 

    git clone git@github.com:fnichol/homesick.git homesick

This cookbook was developed and tested against v0.3.2 of homesick, see:
* https://github.com/fnichol/chef-homesick/commit/80e558ff921f1c59698f6942214c0224a24392d7
* https://github.com/fnichol/chef-homesick

### Install root_ssh_agent cookbook

Install dergachev/chef_root_ssh_agent cookbook as `CHEF-REPO/cookbooks/root_ssh_agent`:

    git clone git@github.com:dergachev/chef_root_ssh_agent.git root_ssh_agent

Include recipe[root_ssh_agent::ppid].  

If using with Vagrant, enable ssh agent forwarding in your Vagrantfile:

    config.ssh.forward_agent = true

### Install ssh_known_hosts cookbook

Install opscode-cookbooks/ssh_known_hosts into `CHEF-REPO/cookbooks`:
    git clone git://github.com/opscode-cookbooks/ssh_known_hosts.git

Include recipe[ssh_known_hosts] in your Vagrantfile.

As per ssh_known_hosts instructions, provide a data_bag for each git server
that homesick::data_bag will connect to, placed in `CHEF-REPO/data_bags/ssh_known_hosts`.
Here's github.json, which I created after looking at `cat ~/.ssh/known_hosts | grep github`:

```js
{ "id": "github",
   "fqdn": "github.com",
   "rsa": "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84Kez D5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==",
   "ipaddress": "207.97.227.239"}
```

Note that the databag filename can't contain periods, and that ssh_known_hosts
will need to use Resolve::getaddress unless an ip address is explicitly
provided. That means without an internet connection, you're likely to get the error
`FATAL: Resolv::ResolvError: no address for github.com`.

Failing to use `recipe[ssh_known_hosts will result in a `Host key verification failed`
error when homesick tries to connect to the remote git repository.  Note that
this error is hard to debug interactively, as ssh will prompt you to accept
the Host key and store in ~/.ssh/known_hosts. Subsequent chef runs will not
have the error, until a full rebuild occurs, perhaps done by:

    vagrant destroy --force && vagrant up

## Usage

Instead of including `recipe[homesick::data_bag]`, simply include
`recipe[homesick_agent::data_bag]` Assuming everything else works, you
should now be able to use homesick with repositories that require SSH agent
forwarding from your Vagrant workstation.


## Resources

See the following resources
* https://github.com/fnichol/chef-homesick
* https://github.com/dergachev/chef_root_ssh_agent
* https://github.com/dergachev/chef_extend_lwrp

## Debugging

To debug whether this recipe works, open shef on the Vagrant VM:
```bash
vagrant ssh # ssh into your VM
cd /tmp/vagrant-chef-1/ ; sudo shef -s -c ./solo.rb -j ./dna.json # run vagrant
```

Include and execute the homesick::data_bag recipe.:
```ruby 
# the following is in shef:
chef >          recipe                                   #enter recipe mode
chef:recipe >   include_recipe("homesick::data_bag")     # loads up the recipe
chef:recipe >   run_chef
```

Note that it prompts you for a password (because you're running an interactive
shell), then fails with the following:
```
[2012-10-09T20:48:31+00:00] INFO: Processing homesick_castle[dotfiles] action install (homesick::data_bag line 38)
[2012-10-09T20:48:31+00:00] INFO: Processing execute[homesick clone git@git.ewdev.ca:alex/dotfiles.git --force] action run (/tmp/vagrant-chef-1/chef-solo-2/cookbooks/homesick/providers/castle.rb line 71)
  git clone  git@git.ewdev.ca:alex/dotfiles.git to /home/alex/.homesick/repos/dotfiles
  git@git.ewdev.ca's password: 
  git@git.ewdev.ca's password: 
  git@git.ewdev.ca's password: 
[2012-10-09T20:48:36+00:00] INFO: execute[homesick clone git@git.ewdev.ca:alex/dotfiles.git --force] ran successfully
[2012-10-09T20:48:36+00:00] INFO: Processing execute[homesick pull dotfiles --force] action run (/tmp/vagrant-chef-1/chef-solo-2/cookbooks/homesick/providers/castle.rb line 71)
  error  Could not pull dotfiles, expected /home/alex/.homesick/repos/dotfiles/home exist and contain dotfiles
```

FYI although the failure was in the call to `homesick clone`, it seems to
return 0 status code anyways, and chef doesn't fail until the subsequent call
to `homesick pull`. I've filed the following bug about this:
https://github.com/technicalpickles/homesick/issues/25

Restart shef (*mandatory*), and try again while overriding HomesickCastle#run
with a debug message: 
```ruby
chef >          recipe    #enter recipe mode
chef:recipe >   include_recipe("homesick::data_bag")     # loads up the recipe
chef:recipe >   class Chef::Provider::HomesickCastle ; def run(command) ; log("OVERRIDEN run " + command)  ; end ; end
chef:recipe >   run_chef 
```

It should no longer fail, since the overriden orriden the HomesickCastle#run 
method does nothing except logs to console:

```
[2012-10-09T21:05:42+00:00] INFO: Processing homesick_castle[dotfiles] action install (homesick::data_bag line 38)
[2012-10-09T21:05:42+00:00] INFO: Processing log[OVERRIDEN run homesick clone git@git.ewdev.ca:alex/dotfiles.git --force] action write ((irb#1) line 2)
[2012-10-09T21:05:42+00:00] INFO: OVERRIDEN run homesick clone git@git.ewdev.ca:alex/dotfiles.git --force
[2012-10-09T21:05:42+00:00] INFO: Processing log[OVERRIDEN run homesick pull dotfiles --force] action write ((irb#1) line 2)
[2012-10-09T21:05:42+00:00] INFO: OVERRIDEN run homesick pull dotfiles --force
[2012-10-09T21:05:42+00:00] INFO: Processing log[OVERRIDEN run homesick symlink dotfiles --force] action write ((irb#1) line 2)
[2012-10-09T21:05:42+00:00] INFO: OVERRIDEN run homesick symlink dotfiles --force
```

If this worked, hopefully so will the following:
```ruby
chef >          recipe    #enter recipe mode
chef:recipe >   include_recipe("homesick_agent::data_bag")     # loads up the recipe
chef:recipe >   run_chef 
```

## See also 

* See https://github.com/dergachev/chef_extend_lwrp for some shef debugging tips
* Useful shell commands to debug ssh agent forwarding:
```bash
  ssh-add -l #  to see loaded keys if same as on chef VM and workstation
  echo $SSH_AUTH_SOCK  # to see if SSH_AUTH_SOCK variable is preserved when chef-solo runs
```

## FIXME

homesick_agent will attempt to connect via SSH to all users with homesick
castles.  This will probably fail unless your agent has a key that works for
all of them.  An obvious fix (not done) will be to use an attribute to track
which users homesick_auth should workfor.


