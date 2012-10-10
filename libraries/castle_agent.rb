#
# Cookbook Name:: homesick_agent
# Library:: castle_agent
#
# Copyright 2012, Alex Dergachev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module HomesickCastleAgent
  
  # Modified version of HomesickCastle#run to support agent forwarding, by
  # using 'ssh user@localhost COMMAND' instead of 'sudo -u user COMMAND'
  def run_with_agent(command)
    
    #enable ssh agent forwarding
    ssh_options = "-A"

    # Avoid 'Host key verification failed' error related to not having localhost in /root/.ssh/known_hosts
    ssh_options << " -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

    # PATH setting prevents "homesick: command now found" error, possibly related to 
    # a Vagrant path bug: https://github.com/mitchellh/vagrant/issues/1013
    cmd_prefix = 'PATH=$PATH:/opt/vagrant_ruby/bin'

    # command = 'ssh-add -l & false' # really useful for debugging

    remote_command = "ssh #{ssh_options} #{new_resource.user}@localhost '#{cmd_prefix} #{command}'"
    execute remote_command 
  end
end
