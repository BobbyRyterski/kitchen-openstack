#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'chef/knife/openstack_base'

class Chef
  class Knife
    class OpenstackServerList < Knife

      include Knife::OpenstackBase

      banner "knife openstack server list (options)"

      def run
        $stdout.sync = true

        validate!

        connection = Fog::Compute.new(
          :provider => 'AWS',
          :aws_access_key_id => Chef::Config[:knife][:openstack_access_key_id],
          :aws_secret_access_key => Chef::Config[:knife][:openstack_secret_access_key],
          :endpoint => Chef::Config[:knife][:openstack_api_endpoint],
          :region => Chef::Config[:knife][:region] || config[:region]
        )

        server_list = [
          ui.color('Instance ID', :bold),
          ui.color('Public IP', :bold),
          ui.color('Private IP', :bold),
          ui.color('Flavor', :bold),
          ui.color('Image', :bold),
          ui.color('Security Groups', :bold),
          ui.color('State', :bold)
        ]
        connection.servers.all.each do |server|
          server_list << server.id.to_s
          # HACK these should all be server.blah.to_s as nil.to_s == ''
          server_list << (server.public_ip_address == nil ? "" : server.public_ip_address)
          server_list << (server.private_ip_address == nil ? "" : server.private_ip_address)
          server_list << (server.flavor_id == nil ? "" : server.flavor_id)
          server_list << (server.image_id == nil ? "" : server.image_id)
          server_list << server.groups.join(", ")
          server_list << server.state
        end
        puts ui.list(server_list, :columns_across, 7)

      end
    end
  end
end


