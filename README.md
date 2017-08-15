Mpath
=========

Install, mount or umount iscsi blockstorages with multipath.
This role are tested and worked fine on softlayer blockstorages, but also
work with other setups with iscsi multipath storages.

Requirements
------------

You need to have a iscsi multipath blockstorage and login and password for the iqn.
This role also will need de full iqn path and the isci mapper id like: /dev/mapper/3600....

Role Variables
--------------

 iscsint is the initiator name
 iscsint: iqn.1994-05.com.redhat:47c98423c167
 initiator can be an array like:
 iscsint:
   - iqn.1994-05.com.redhat:47c98423c167
   - iqn.1994-05.com.redhat:47c98423c167-2
   - iqn.1994-05.com.redhat:47c98423c167-3

 mpathip is the target ipaddress
 mpathip: 10.150.10.20

 filesystem: default setted to ext4 change to whatever you want.
 Check supported filesystems for ansible mount module.

 map: true means all installation and confs task will be run
 if you set to false the device mapper on hosts will be unmounted
 but the config files will remain, less fstab.

 wwid is the alias name for a device
 syntax must be:
 wwid:
   - { id: '360009827346', alias: 'mylun0' }
   - { id: '360782378662', alias: 'mylun1' }
 ...

 packs is the list of the packages to use iscsi multipath on
 centos 7. This role at this moment only will work on centos7+
 with systemd


 credetials must be adjusted on you playbook with your login
 and password e.g.

 credentials:
   - name: "My Credentials"
     login: mylogin
     pass: mypassword

 !WARNING!
 login and password can no be defined with inside quotation marks " or single quotes '


Dependencies
------------

None

Example Playbook
----------------

Here is a sample of playbook to install and mount multipath device:

- name: "Deploy | Running isca0.mpath role"
  hosts: somehost
  become: yes
  remote_user: myuser
  vars:
    mpathip: "10.200.10.100"
    credentials:
      - name: "Multipath"
        login: MyLogin
        pass: Mypassword
    iscsint:
      - "iqn.1994-05.com.redhat:47c98423c167"
    wwid:
      - { id: '3600a0980383888835645961', alias: 'blk' }
  roles:
    - mpath

If you want search a group of devices and umount the multipath before mount
you can set a playbook to umount then run a playbook to mount.

Here is a sample to umount a storage:

- name: "Deploy | Running isca0.mpath role"
  hosts: groupofhosts
  become: yes
  remote_user: myuser
  vars:
    map: false
    wwid:
      - { id: '3600a098038303631a35645961', alias: 'blk' }
  roles:
    - mpath

As you can see just setting map to false the role will only perform the umount
action.

License
-------

GPLv2

Author Information
------------------

This role was create in 2017 by [Igor Brandao](https://isca.space)
