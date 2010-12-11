include_recipe "mongodb::source"

directory node[:mongodb][:shard_datadir] do
  owner "mongodb"
  group "mongodb"
  mode 0755
  recursive true
end

file node[:mongodb][:shard_logfile] do
  owner "mongodb"
  group "mongodb"
  mode 0644
  action :create_if_missing
  backup false
end

template node[:mongodb][:shard_config] do
  source "mongodb_shard.conf.erb"
  owner "mongodb"
  group "mongodb"
  mode 0644
  backup false
end

template "/etc/init.d/mongodb_shard" do
  source "mongodb_shard.init.erb"
  mode 0755
  backup false
end

service "mongodb_shard" do
  supports :start => true, :stop => true, "force-stop" => true, :restart => true, "force-reload" => true, :status => true
  action [:enable, :start]
  #subscribes :restart, resources(:template => node[:mongodb][:shard_config])
  subscribes :restart, resources(:template => "/etc/init.d/mongodb_shard")
end