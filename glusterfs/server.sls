{% from "glusterfs/map.jinja" import server with context %}

{%- if server.enabled %}

glusterfs_packages:
  pkg.installed:
    - names: {{ server.pkgs }}

glusterfs_service:
  service.running:
    - name: {{ server.service }}
    - require:
      - pkg: glusterfs_packages

{%- if server.peers is defined %}

glusterfs_peers:
    glusterfs.peered:
      - names: {{ server.peers }}
      - require:
        - service: glusterfs_service

{%- endif %}

{%- if server.volumes is defined %}
{%- for name, volume in server.volumes.iteritems() %}

{{ volume.storage }}:
  file.directory:
    - makedirs: true

glusterfs_vol_{{ name }}:
  glusterfs.created:
    - name: {{ name }}
    {%- if volume.replica is defined %}
    - replica: {{ volume.replica }}
    {%- endif %}
    {%- if volume.stripe is defined %}
    - stripe: {{ volume.stripe }}
    {%- endif %}
    - bricks: {{ volume.bricks }}
    - start: true
    {# Parameter force doesn't exist in Salt 2015.5.2 and without it creation
    will fail when brick is on root disk #}
    - force: true
    - require:
      - glusterfs: glusterfs_peers
      - file: {{ volume.storage }}

{%- endfor %}
{%- endif %}

{%- endif %}
