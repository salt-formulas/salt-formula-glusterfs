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

{%- if grains.get('init', None) == 'systemd' %}
{#- We need to give glusterfs-server time to start volumes. This little hacks
ensures that mount will pass on boot when no other servers are available #}
glusterfs_server_systemd_override:
  file.managed:
    - name: /etc/systemd/system/{{ server.service }}.service.d/override.conf
    - makedirs: true
    - contents: |
        [Service]
        ExecStartPost=/bin/sleep 10
{%- endif %}

{%- if server.volumes is defined %}
{%- for name, volume in server.volumes.iteritems() %}

gluster_volume_{{ volume.storage }}:
  file.directory:
  - name: {{ volume.storage }}
  - makedirs: true

{%- endfor %}
{%- endif %}

{%- endif %}
