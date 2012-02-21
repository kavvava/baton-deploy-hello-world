#
# Cookbook Name:: baton-deploy-hello-world
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require_recipe 'nginx'

base_dir = "/srv/baton-deploy-hello-world"

baton_rails "baton-deploy-hello-world" do
  base base_dir
  vhost "hello-world.dsci.it"
end

route53_rr "hello-world.dsci.it." do
  record_type "CNAME"
  fqdn "hello-world.dsci.it."
  rdata(["#{node[:fqdn]}."])
  accesskey node["route53"]["accesskey"]
  secretkey node["route53"]["secretkey"]
  zoneid node["route53"]["zoneid"]
  action :update
end

# needs support for basic auth stuffs
# monitor_http "baton-deploy-hello-world.dsci.it" do
#   internal_ca true
#   url "https://baton-deploy-hello-world.dsci.it"
# end
