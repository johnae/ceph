ceph Cookbook
=============
Pretty specific cookbook for basic installation on a Vagrant box. It assumes there's a drive
at /dev/sdb so that's something for the Vagrantfile. It makes use of btrfs subvolumes for the
OSDs. This cookbook only concerns itself with the Rados Gateway, Cephs S3 compatible API.

e.g.
This cookbook makes your favorite breakfast sandwhich.

Requirements
------------
Apache2 cookbook
Apt cookbook

Attributes
----------
TODO: List you cookbook attributes here.

node['ceph']['radosgw']['initial_user']
node['ceph']['radosgw']['initial_password']
node['ceph']['radosgw']['socket_path']
node['ceph']['radosgw']['log_file']
node['ceph']['mon_ip]
node['ceph']['num_osds']
node['ceph']['fs_id']


e.g.
#### ceph::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['ceph']['radosgw']['initial_user']</tt></td>
    <td>string</td>
    <td>username of the first user of S3 compatible API</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['ceph']['radosgw']['initial_password']</tt></td>
    <td>string</td>
    <td>password of the first user of S3 compatible API</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['ceph']['radosgw']['socket_path']</tt></td>
    <td>string</td>
    <td>where to store radosgws socket</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['ceph']['radosgw']['socket_path']</tt></td>
    <td>string</td>
    <td>where to store radosgws socket</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['ceph']['radosgw']['log_file_']</tt></td>
    <td>string</td>
    <td>where to store radosgws logs</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['ceph']['mon_ip']</tt></td>
    <td>string</td>
    <td>the ip of the ceph monitor(usually set to the private host_only ip of the vagrant box)</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['ceph']['num_osds']</tt></td>
    <td>string</td>
    <td>where to store radosgws logs</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['ceph']['fs_id']</tt></td>
    <td>the ceph filesystem id(string)</td>
    <td>it's not that important (here) really, it's set to a default value</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### ceph::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `ceph` and possibly `ceph::repo` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[ceph::repo]",
    "recipe[ceph]"
  ]
}