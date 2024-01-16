---
layout: post
title: "Orchestration with Fabric  #1"
date: 2015-03-09 15:30:00 +0000
permalink: /en/orchestration-fabric
blog: en
tags: orchestration vagrant
render_with_liquid: false
---

When figuring out how I wanted to deploy my website I had a few things that I
knew I wanted. I wanted to be able to create my server(s), provision them, and
deploy the app all from one tool. This will be the first in a series of posts
about how I used Fabric to achieve that.

Tools like [Vagrant](https://www.vagrantup.com/) can be used to create servers
and provision them, but deploying an app using a provisioning tool like chef,
puppet, or ansible is less than ideal. Vagrant also can only get you so
far, when you need to set up disks and networking so it's not great and,
indeed, not intended for production use.

[Terraform](https://www.terraform.io/) is another tool that does orchestration better,
but it's not obvious to me how to avoid writing config for the servers, disks,
and networking, and then again from scratch for provisioning/deployment
tools. It may be worth investigating whether I can use terraform and apply labels
to VMs that can later be provisioned using something like ansible's dynamic
inventory.

## Fabric

[Fabric](http://www.fabfile.org/) is a well known tool written in python that
makes it really easy to automate running commands on lots of remote machines.
Fabric users use it to run some system administration tasks or deploy
applications on a number of servers.

What's not so well known is that you can use fabric to automate orchestration
tasks as well. For instance, we can actually use fabric to do create, and
provision servers as well as deploy applications to them. Using fabric makes it easy
to have configuration in one place, and script with the power of Python rather than
messing around with a lot of unweildy bash or zsh shell scripts.

## Wagging the Dog

I would eventually be running my website on Google Cloud Platform but I wanted
to have a way to run a VM locally for development/testing. I settled on using
Vagrant to do that.

Vagrant is a tool to start up and provision a VM but what I did was have Fabric
run vagrant, and use it only for starting/stopping the VMs. Afterwards I would
just continue and run [Ansible](http://www.ansible.com/) from Fabric to
provision and use Fabric's native functionality to deploy the app. Usually you
run, fabric from vagrant but I did it the other way around so it's a bit like
the tail wagging the dog but it got the job done. This also allowed me to piggyback
on Vagrant's SSH setup of the VM and use that when running Ansible.

I created a simple Vagrantfile:

```
# -*- mode: ruby -*-
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/trusty64"
    confix.vm.hostname = 'local.virtualbox'
    config.vm.network "private_network", ip: "192.168.33.10"
end
```

And then I created a Fabric task to set up the environment. Here I create a
temporary file that holds the ssh client configuration and I set it to
`env.ssh_config_path` so that Fabric will use it when running remote commands.

```
import tempfile
from fabric.api import task, env, settings

# Used for connecting to vagrant machines. Located here
# so that the file isn't closed and deleted before fabric exits.
_ssh_config = tempfile.NamedTemporaryFile()

@task
def local():
    # Setup the ssh config so that fabric connects to vagrant.
    env.user = 'vagrant'
    env.ssh_config_path = _ssh_config.name
    env.use_ssh_config = True
    env.ssh_key_path = '~/.vagrant.d/insecure_private_key'

    # matches the Vagrantfile
    host = 'local.virtualbox'

    # Only 1 server for now.
    env.roledefs.update({
        'webservers': [host],
        'appservers': [host],
        'dbservers': [host],
        'cacheservers': [host],
    })

    # warn_only because we may not have created any VMs yet.
    _config_ssh(warn_only=True)

def _config_ssh(warn_only=False):
    """
    Set up the ssh configuration.
    """
    # Get the vagrant ssh config
    with settings(warn_only=warn_only):
        localexec("vagrant ssh-config >> %s"
                  % env.ssh_config_path)

    # NOTE: Remove the cached ssh config data.
    if '_ssh_config' in env:
        # NOTE: env is a dict so del env._ssh_config doesn't work
        del env['_ssh_config']
```

Now I create some tasks to start, stop, and delete VMs. After creating
an instance I call the `_config_ssh()` function again so that the VM's
configuration get's added to the SSH config.

```
from fabric.api import task, local
from fabric.decorators import runs_once
from fabric.colors import green

@task
@runs_once
def up():
    """
    Create a vagrant instance.
    """
    print(green("Creating instance."))

    local("vagrant up --no-provision")

    # Need to get the vagrant ssh config after
    # booting the instance.
    _config_ssh()

@task
@runs_once
def halt():
    """
    Halt all vagrant machines.
    """
    print(green("Stopping instance."))
    local("vagrant halt")


@task
@runs_once
def destroy(force=False):
    """
    Destroy all vagrant machines.
    """
    print(green("Deleting instance."))

    options = ""
    if force:
        options = "--force"

    local("vagrant destroy " + options)  # NOTE: Interactive
```

Now that I have those commands written I can run something like the following to start the instance:

```shell
fab local up
```

And to stop it:

```shell
fab local halt
```

## What's next?

Right now I'm not doing anything really interesting that I couldn't do with
just vagrant. Essentially It's just a complicated way of running `vagrant up`
or `vagrant halt`. The key is getting the ssh configuration information from
vagrant that we can use later for other remote commands.

In a future post I'll explain how I go on to provision and deploy an app to
that instance. And subsequent posts will talk about how to use the same
commands with instances on Google Cloud Platform.
