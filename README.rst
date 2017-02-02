=========
GlusterFS
=========

Install and configure GlusterFS server and client.

Available states
================

.. contents::
    :local:

``glusterfs.server``
--------------------

Setup GlusterFS server (including both service and setup)

``glusterfs.server.service``
----------------------------

Setup and start GlusterFS server service

``glusterfs.server.setup``
----------------------------

Setup GlusterFS peers and volumes

``glusterfs.client``
--------------------

Setup GlusterFS client

Available metadata
==================

.. contents::
    :local:

``metadata.glusterfs.server``
-----------------------------

Setup basic server


``metadata.glusterfs.client``
-----------------------------

Setup client only

Configuration parameters
========================


Example reclass
===============

Example for distributed glance images storage where every control node is
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

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-glusterfs/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-glusterfs

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
