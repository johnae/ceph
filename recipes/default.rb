#
# Cookbook Name:: ceph
# Recipe:: default
#
# Copyright 2013, Trice Imaging, Inc.
#
# All rights reserved - Do Not Redistribute
#

### not really very dynamic or anything - just get this going easily

package "btrfs-tools"
include_recipe "apache2"
include_recipe "apache2::mod_fastcgi"
#package "avahi-daemon"

apache_module "rewrite" do
  conf false
end

## we create a btrfs volume of the whole disk at /dev/sdb
## this disk corresponds with the storage.vdi created in the
## Vagrantfile
execute "create_btrfs_fs_for_ceph" do
  command "mkfs.btrfs -l 32k -n 32k /dev/sdb"
  not_if { ::File.directory?("/var/lib/ceph") }
  notifies :create, "directory[/var/lib/ceph]", :immediately
end

## Precreate the directory since we'll be mounting the above
## btrfs volume there
directory "/var/lib/ceph" do
  owner "root"
  group "root"
  mode "0755"
  notifies :mount, "mount[/var/lib/ceph]", :immediately
  notifies :enable, "mount[/var/lib/ceph]", :immediately
end

## Yep - mount that volume! :-)
mount "/var/lib/ceph" do
  device "/dev/sdb"
  fstype "btrfs"
  options "defaults,nobootwait,noatime,nodiratime,compress,space_cache"
  notifies :create, "directory[/var/lib/ceph/osd]", :immediately
end

## We precreate this directory and it should probably
## be done before ceph is installed (so ceph doesn't go
## ahead and create subdirs here etc)
directory "/var/lib/ceph/osd" do
  action :nothing
  owner "root"
  group "root"
  mode "0755"
  notifies :run, "bash[create_ceph_osd_disks]", :immediately
end

## btrfs subvolumes FTW! one for each osd
bash "create_ceph_osd_disks" do
  action :nothing
  user "root"
  cwd "/tmp"
  code <<-EOH
  for ID in #{node['ceph']['num_osds'].times.to_a.join(' ')}; do
    btrfs subvolume create /var/lib/ceph/osd/ceph-$ID
  done
  EOH
  not_if { ::File.directory?("/var/lib/ceph/osd/ceph-0") }
end

## Finally we install this behemoth
package "ceph"
package "radosgw"

## Needs a conf of course
template "/etc/ceph/ceph.conf" do
  source "ceph.conf.erb"
  action :create
  owner "root"
  group "root"
  mode "0600"
end

## Regardless of whether we run without auth (which we do here), the mon needs
## a keyring for some inexplicable reason from outer space - it won't start otherwise
execute "create_mon_keyring" do
  command "ceph-authtool --create-keyring --gen-key -n mon. /etc/ceph/ceph.mon.a.keyring"
  not_if { ::File.exists?("/etc/ceph/ceph.mon.a.keyring") }
end

## The monitor needs a store,
execute "create_mon_store" do
  command "mkdir -p /var/lib/ceph/mon/ceph-a; ceph-mon --mkfs -i a --fsid #{node['ceph']['fs_id']} --conf /etc/ceph/ceph.conf"
  not_if { ::File.directory?("/var/lib/ceph/mon/ceph-a") }
end

execute "preboot_mon" do
  command "/etc/init.d/ceph start mon.a"
end

execute "set_max_osd" do
  command "ceph osd setmaxosd #{node['ceph']['num_osds']}"
end

template "/tmp/crushmap.txt" do
  source "crushmap.txt.erb"
end

execute "set_crushmap" do
  command "crushtool -c /tmp/crushmap.txt -o /etc/ceph/crushmap; ceph osd setcrushmap -i /etc/ceph/crushmap"
  not_if { ::File.exists?("/etc/ceph/crushmap") }
end

bash "create_osd_stores" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  for ID in #{node['ceph']['num_osds'].times.to_a.join(' ')}; do
    ceph-osd --mkfs -i $ID
  done
  EOH
  not_if { ::File.exists?("/var/lib/ceph/osd/ceph-0/ceph_fsid") }
  notifies :restart, "service[ceph]", :immediately
end

service "ceph" do
  action [ :enable, :start ]
end

service "radosgw" do
  action [ :enable, :start ]
end

web_app "rgw" do
  template "rgw.conf.erb"
  server_name node['ceph']['radosgw']['api_fqdn']
  admin_email node['ceph']['radosgw']['admin_email']
  ceph_rgw_addr node['ceph']['radosgw']['rgw_addr']
end

execute "create_initial_rgw_user" do
  command "radosgw-admin user create --uid=dev --key-type=s3 --email=devops@triceimaging.com --display-name=\"Dev Ops\" --access-key=#{node['ceph']['radosgw']['initial_user']} --secret=#{node['ceph']['radosgw']['initial_password']}"
end