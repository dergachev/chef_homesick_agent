#
# Cookbook Name:: homesick_agent
# Recipe:: data_bag
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


include_recipe("homesick::data_bag")

# Monkeypatch the homesick castle provider to make ssh agent forwarding work.
# See https://github.com/dergachev/chef_extend_lwrp#ruby-mixins for more info.
class Chef::Provider::HomesickCastle 
  include HomesickCastleAgent   #defined in homesick_agent/libraries/castle_agent.rb

  # overrides Chef::Provider::HomesickCastle#run
  def run(command)
    run_with_agent(command)
  end
end 
