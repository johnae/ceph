#
# Cookbook Name:: ceph
# Recipe:: repo
#
# Copyright 2013, Trice Imaging, Inc.
#
# All rights reserved - Do Not Redistribute
#

apt_repository "ceph" do
  uri "http://ceph.com/debian/"
  distribution node['lsb']['codename']
  components ["main"]
  key "https://raw.github.com/ceph/ceph/master/keys/release.asc"
end