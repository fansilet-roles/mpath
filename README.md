Mpath
=========

Install, mount or unmount iscsi blockstorages with multipath.
This have been tested on softlayer blockstorages. But will also
work on other setups, with iscsi multipath storages.

The logic of this role is:

  ##### During installing

  * Install packages dependencies to use multipath and iscsi
  * Configure /etc/multipath.conf
  * Probe dm-multipath kernel module
  * Enable and start multipathd
  * List with (multipath -l) to trigger the multipathd handler
  * Configure /etc/iscsi/initiatorname.iscsi
  * Edit chap authentication on /etc/iscsi/iscsid.conf
  * Try to autologin on portal if fails use normal login
  * Create an alias on /etc/multipath/bindings
  * Mount multipath "/dev/mapper/mydeviceid" on "/mnt/myaliasname"
  * Trigger iscsi and iscsid to start and enable
  * Place the entries on /etc/fstab

  ##### During unmounting

  * Lsof pid's of device "/dev/mapper/mydeviceid"
  * If device are in use, **force** and release the device
  * Unmount device in lazy way _(umount -l device)_
  * Unmount and remove fstab entries
  * Flush multipath with (multipath -f device)
  * Logout from session portal target
  * Trigger handler to stop and disable iscsi,iscsid and multipathd services


Requirements
------------

You will need a iscsi multipath blockstorage, the login and password for the iqn. You will also
need the full initiator iqn path, and the iscsi mapper id. _like: /dev/mapper/3600..._

Role Variables
--------------

This are the variables you will need to adjust on your playbook.

 **iscsint** is the initiator iqn name.
 e.g.:

 ```
 iscsint: iqn.1994-05.com.redhat:47c98423c167
 ```

 you can set multiples initiators as an array:

```
 iscsint:
   - iqn.1994-05.com.redhat:47c98423c167
   - iqn.1994-05.com.redhat:47c98423c167-2
   - iqn.1994-05.com.redhat:47c98423c167-3
```

 **mpathip** is the target ipaddress

```
 mpathip: 10.150.10.20
```

 **filesystem**: is default setted to ext4, change this to whatever you want.  
 _Check supported filesystems on ansible mount module._  
  
 **map**: if setted to true, means all installation and config tasks will run.  
 If you set to false, the device mapper will be unmounted, and follow the unmount flux.  
  
 **wwid** is the alias for multipath device, and will be used to configure bindings file.  
 This variable is **very important**, it also will be used on whole role to mount and unmount device  
 based on **id**.  
  
 syntax must be:
 ```
 wwid:
   - { id: '360009827346', alias: 'mylun0' }
   - { id: '360782378662', alias: 'mylun1' }
 ...
```
 **packs** is the list of packages to install. It will install iscsi, multipath and lsof.
  
 **credetials** must be adjusted on your playbook with your login and password.  
  e.g.  

```
 credentials:
   - name: "My Credentials"
     login: mylogin
     pass: mypassword
```
 **WARNING!**  
 **login** and **password** must be declared without quotation marks " or single quotes '.  


Dependencies
------------

None

Example Playbook
----------------

Here is a playbook sample. This playbook will  install and mount multipath device on somehost:

```
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
```

If you want unmount a device on a group of hosts, and then mount on a exclusive host. You can
run firstly a unmount playbook and then a "install/mount" playbook.  
  
Here is a sample of unmount playbook:

```
- name: "Deploy | Running isca0.mpath role"
  hosts: groupofhosts
  become: yes
  remote_user: myuser
  vars:
    map: false
    mpathip: "10.200.10.100"
    wwid:
      - { id: '3600a098038303631a35645961', alias: 'blk' }
  roles:
    - mpath
```

As you can see, just set **map** to _false_, make the role to perform only the unmount tasks. :wink:

To-do
------

  - [ ] Add support to automount

License
-------

LGPL-3.0

Author Information
------------------

This role was create in 2017 by [isca](https://isca.space)

