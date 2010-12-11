include_recipe "mongodb::source"

directory node[:mongodb][:datadir] do
  owner "mongodb"
  group "mongodb"
  mode 0755
  recursive true
end

file node[:mongodb][:logfile] do
  owner "mongodb"
  group "mongodb"
  mode 0644
  action :create_if_missing
  backup false
end

template node[:mongodb][:config] do
  source "mongodb.conf.erb"
  owner "mongodb"
  group "mongodb"
  mode 0644
  backup false
end

template "/etc/init.d/mongodb" do
  source "mongodb.init.erb"
  mode 0755
  backup false
end

service "mongodb" do
  supports :start => true, :stop => true, "force-stop" => true, :restart => true, "force-reload" => true, :status => true
  action [:enable, :start]
  subscribes :restart, resources(:template => node[:mongodb][:config])
  subscribes :restart, resources(:template => "/etc/init.d/mongodb")
end