# This only needs to be run on one of the members of the set

shard_servers = search(:node, 'recipes:mongodb\:\:shard')
(1..node[:mongodb][:shard_count]).each do |index|
  lock_file = "/var/lock/mongdb_shard#{index}Initiated"
  
  setname = "set#{index}"
  port = node[:mongodb][:shard_port] + (index*10+1)
  #{ _id : 0, host : "server1A:27017", priority : 2}
  servers = shard_servers.collect { |x| "#{x.ec2.local_hostname}:#{port}" }.join(",")

  #javascript = "config = { _id : '#{setname}', members : [ #{servers} ] }; rs.initiate(config);"
  javascript = "db.runCommand( { addshard : \"#{setname}/#{servers}\", name : \"shard#{index}\" } );"
  
  file "/tmp/shard#{index}.js" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    content javascript
    not_if "test -f #{lock_file}"
  end
  
  execute "mongo" do
    command "#{node[:mongodb][:dir]}/bin/mongo localhost:27017/admin /tmp/shard#{index}.js"
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