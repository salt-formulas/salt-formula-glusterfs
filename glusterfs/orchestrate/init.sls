glusterfs_server_service:
  salt.state:
    - tgt: 'roles:glusterfs.server'
    - tgt_type: grain
    - sls: glusterfs.server.service

glusterfs_server_setup:
  salt.state:
    - tgt: 'roles:glusterfs.server'
    - tgt_type: grain
    - batch: 1
    - sls: glusterfs.server.setup
    - require:
      - salt: glusterfs_server_service

glusterfs_client:
  salt.state:
    - tgt: 'roles:glusterfs.client'
    - tgt_type: grain
    - sls: glusterfs.client
    - require:
      - salt: glusterfs_server_setup

