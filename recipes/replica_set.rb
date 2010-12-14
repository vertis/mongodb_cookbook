# This only needs to be run on one of the members of the set

shard_servers = search(:node, 'recipes:mongodb\:\:shard')
(1..node[:mongodb][:shard_count]).each do |index|
  lock_file = node[:mongodb][:shard_datadir]+"_#{index}/repliSetInitiated"
  
  setname = "set#{index}"
  port = node[:mongodb][:shard_port] + (index*10+1)
  #{ _id : 0, host : "server1A:27017", priority : 2}
  servers = shard_servers.enum_for(:each_with_index).collect { |x,i| "{ _id : #{i}, host : \"#{x.ec2.local_hostname}:#{port}\" }" }.join(",\n ")

  #javascript = "config = { _id : '#{setname}', members : [ #{servers} ] }; rs.initiate(config);"
  javascript = "rs.initiate({ _id : '#{setname}',\n members : [\n #{servers}\n ]\n });"
  
  file "/tmp/replica_set.js" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    content javascript
    not_if "test -f #{lock_file}"
  end
  
  execute "mongo" do
    command "#{node[:mongodb][:dir]}/bin/mongo localhost:#{port} /tmp/replica_set.js"
    action :run
    not_if "test -f #{lock_file}"
  end
  
  file lock_file do
    owner "root"
    group "root"
    mode "0755"
    action :create
    not_if "test -f #{lock_file}"
  end
  
end 