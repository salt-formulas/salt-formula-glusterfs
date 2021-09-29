{% from "glusterfs/map.jinja" import server with context %}

{%- if server.enabled %}

glusterfs_packages:
  pkg.installed:
    - names: {{ server.pkgs }}


{%- if server.recover_peers is defined %}
{%- for peer_name, peer_data in server.recover_peers.items() %}
{%- if peer_data.get('enabled', False) and grains.get('fqdn', 'unknown') == peer_name %}

force_peer_uuid:
  file.managed:
    - source: salt://glusterfs/files/glusterd.info
    - name: /var/lib/glusterd/glusterd.info
    - template: jinja
    - makedirs: True
    - defaults:
        uuid: {{ peer_data.uuid }}

stop_glusterfs_service:
  service.dead:
    - name: {{ server.service }}
    - onchanges:
      - file: force_peer_uuid


glusterfs_sleep:
  cmd.wait:
    - name: sleep 5
    - watch-in:
      - service: stop_glusterfs_service

{%- endif %}
{%- endfor %}
{%- endif %}

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
        ExecStartPost=/bin/sleep 5
{%- endif %}

{%- if server.volumes is defined %}
{%- for name, volume in server.volumes.items() %}

gluster_volume_{{ volume.storage }}:
  file.directory:
  - name: {{ volume.storage }}
  - makedirs: true

{%- endfor %}
{%- endif %}

{%- endif %}
