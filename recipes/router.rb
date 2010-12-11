include_recipe "mongodb::source"

search(:node, 'run_list:"role[mongodb_config]"') do
  
end

template "/etc/init.d/mongodb_router" do
  source "mongodb_router.init.erb"
  mode 0755
  backup false
end

service "mongodb_router" do
  supports :start => true, :stop => true, "force-stop" => true, :restart => true, "force-reload" => true, :status => true
  action [:enable, :start]
  subscribes :restart, resources(:template => "/etc/init.d/mongodb_router")
end