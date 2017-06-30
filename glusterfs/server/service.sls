{% from "glusterfs/map.jinja" import server with context %}

{%- if server.enabled %}

glusterfs_packages:
  pkg.installed:
    - names: {{ server.pkgs }}

{%- if not grains.get('noservices', False) %}

glusterfs_service:
  service.running:
    - name: {{ server.service }}
    - require:
      - pkg: glusterfs_packages

{%- endif %}

{%- if server.volumes is defined %}
{%- for name, volume in server.volumes.iteritems() %}

{{ volume.storage }}:
  file.directory:
    - makedirs: true

{%- endfor %}
{%- endif %}

{%- endif %}
