glusterfs.server.service:
  salt.state:
    - tgt: 'glusterfs:server'
    - tgt_type: pillar
    - queue: True
    - sls: glusterfs.server.service
    - batch: 1

glusterfs.server.setup:
  salt.state:
    - tgt: 'glusterfs:server'
    - tgt_type: pillar
    - queue: True
    - sls: glusterfs.server.setup
    - batch: 1
    - require:
      - salt: glusterfs.server.service

