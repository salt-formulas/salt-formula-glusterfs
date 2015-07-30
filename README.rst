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

Setup GlusterFS server

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

Read more
=========

* https://www.gluster.org/
