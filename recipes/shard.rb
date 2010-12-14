include_recipe "mongodb::source"

(1..node[:mongodb][:shard_count]).each do |index|
  datadir = node[:mongodb][:shard_datadir]+"_#{index}"
  logfile = node[:mongodb][:shard_logfile]+".#{index}"
  pidfile = node[:mongodb][:shard_pidfile]+".#{index}"
  port = node[:mongodb][:shard_port] + (index*10+1)
  configfile = "/etc/mongodb_shard_#{index}.conf"
  setname = "set#{index}"
  
  directory datadir do
    owner "mongodb"
    group "mongodb"
    mode 0755
    recursive true
  end

  file logfile do
    owner "mongodb"
    group "mongodb"
    mode 0644
    action :create_if_missing
    backup false
  end

  template configfile do
    source "mongodb_shard.conf.erb"
    owner "mongodb"
    group "mongodb"
    mode 0644
    backup false
    variables({ :datadir => datadir, :logfile => logfile, :port => port, :setname => setname
                })
  end

  template "/etc/init.d/mongodb_shard_#{index}" do
    source "mongodb_shard.init.erb"
    mode 0755
    backup false
    variables({ :configfile => "/etc/mongodb_shard_#{index}.conf", :pidfile => node[:mongodb][:shard_pidfile]+".#{index}"
                })
  end

  service "mongodb_shard_#{index}" do
    supports :start => true, :stop => true, "force-stop" => true, :restart => true, "force-reload" => true, :status => true
    action [:enable, :start]
    #subscribes :restart, resources(:template => @configfile)
    subscribes :restart, resources(:template => "/etc/init.d/mongodb_shard_#{index}")
  end
end