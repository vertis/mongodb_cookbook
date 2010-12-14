include_recipe "mongodb::source"

config_servers = search(:node, 'recipes:mongodb\:\:config')

template "/etc/init.d/mongodb_router" do
  source "mongodb_router.init.erb"
  mode 0755
  backup false
  variables({ :config_server_list => config_servers.collect { |x| x.ec2.local_hostname }.join(',')
              })
end

service "mongodb_router" do
  supports :start => true, :stop => true, "force-stop" => true, :restart => true, "force-reload" => true, :status => true
  action [:enable, :start]
  subscribes :restart, resources(:template => "/etc/init.d/mongodb_router")
end