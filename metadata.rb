maintainer       "Alex Dergachev"
maintainer_email "alex@evolvingweb.ca"
license          "Apache 2.0"
description      "Extends github.com/fnichol/chef-homesick cookbook to support ssh agent forwarding"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1"

supports "ubuntu"
supports "debian"
supports "mac_os_x"
supports "openbsd"
supports "suse"

depends "homesick"
