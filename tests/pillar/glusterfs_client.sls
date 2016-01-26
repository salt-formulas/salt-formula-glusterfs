glusterfs:
 client:
   volumes:
     glance:
       path: /var/lib/glance/images
       server: 192.168.1.21
       user: glance
       group: glance
   enabled: true

