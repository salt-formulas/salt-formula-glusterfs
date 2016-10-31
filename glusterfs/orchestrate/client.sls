glusterfs.client:
  salt.state:
    - tgt: 'glusterfs:client'
    - tgt_type: pillar
    - sls: glusterfs.client
    - require:
      - salt: glusterfs.server.setup

