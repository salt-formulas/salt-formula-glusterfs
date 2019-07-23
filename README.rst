=====
Usage
=====

Installs and configures GlusterFS server and client.

Available states
================

* ``glusterfs.server``
   Sets up GlusterFS server (including both service and setup)

* ``glusterfs.server.service``
   Sets up and start GlusterFS server service

* ``glusterfs.server.setup``
   Sets up GlusterFS peers and volumes

* ``glusterfs.client``
   Sets up GlusterFS client

Available metadata
==================

* ``metadata.glusterfs.server``
   Sets up basic server

* ``metadata.glusterfs.client``
   Sets up client only

Example Reclass
===============

Example for distributed Glance images storage where every control node is
gluster peer.

.. code-block:: yaml

   classes:
   - service.glusterfs.server
   - service.glusterfs.client

   _param:
     cluster_node01_address: 192.168.1.21
     cluster_node02_address: 192.168.1.22
     cluster_node03_address: 192.168.1.23
   parameters:
     glusterfs:
       server:
         peers:
         - ${_param:cluster_node01_address}
         - ${_param:cluster_node02_address}
         - ${_param:cluster_node03_address}
         volumes:
            glance:
              storage: /srv/glusterfs/glance
              replica: 3
              bricks:
              - ${_param:cluster_node01_address}:/srv/glusterfs/glance
              - ${_param:cluster_node02_address}:/srv/glusterfs/glance
              - ${_param:cluster_node03_address}:/srv/glusterfs/glance
              options:
                cluster.readdir-optimize: On
                nfs.disable: On
                network.remote-dio: On
                diagnostics.client-log-level: WARNING
                diagnostics.brick-log-level: WARNING
       client:
         volumes:
           glance:
             path: /var/lib/glance/images
             server: ${_param:cluster_node01_address}
             user: glance
             group: glance

Example pillar
==============

Server
------

.. code-block:: yaml

   glusterfs:
     server:
       peers:
       - 192.168.1.21
       - 192.168.1.22
       - 192.168.1.23
       volumes:
          glance:
            storage: /srv/glusterfs/glance
            replica: 3
            bricks:
            - 172.168.1.21:/srv/glusterfs/glance
            - 172.168.1.21:/srv/glusterfs/glance
            - 172.168.1.21:/srv/glusterfs/glance
       enabled: true

Server with forced peer UUID (for peer recovery)
------------------------------------------------

.. code-block:: yaml

   glusterfs:
     server:
       recover_peers:
         kvm03.testserver.local:
           enabled: true
           uuid: ab6ac060-68f1-4f0b-8de4-70241dfb2279


Client
------

.. code-block:: yaml

   glusterfs:
     client:
       volumes:
         glance:
           path: /var/lib/glance/images
           server: 192.168.1.21
           user: glance
           group: glance
       enabled: true

Read more
=========

* https://www.gluster.org/

Documentation and Bugs
======================

* http://salt-formulas.readthedocs.io/
   Learn how to install and update salt-formulas

* https://github.com/salt-formulas/salt-formula-glusterfs/issues
   In the unfortunate event that bugs are discovered, report the issue to the
   appropriate issue tracker. Use the Github issue tracker for a specific salt
   formula

* https://launchpad.net/salt-formulas
   For feature requests, bug reports, or blueprints affecting the entire
   ecosystem, use the Launchpad salt-formulas project

* https://launchpad.net/~salt-formulas-users
   Join the salt-formulas-users team and subscribe to mailing list if required

* https://github.com/salt-formulas/salt-formula-glusterfs
   Develop the salt-formulas projects in the master branch and then submit pull
   requests against a specific formula

* #salt-formulas @ irc.freenode.net
   Use this IRC channel in case of any questions or feedback which is always
   welcome

