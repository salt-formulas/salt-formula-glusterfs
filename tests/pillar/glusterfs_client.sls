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
 client:
   volumes:
     glance:
       path: /var/lib/glance/images
       server: 192.168.1.21
       user: glance
       group: glance
   enabled: true

