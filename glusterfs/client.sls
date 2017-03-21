{% from "glusterfs/map.jinja" import client with context %}

{%- if client.enabled %}

glusterfs_client_packages:
  pkg.installed:
    - names: {{ client.pkgs }}

{%- if client.volumes is defined %}
{%- for name, volume in client.volumes.iteritems() %}

{%- if grains.get('init', None) == 'systemd' %}
{#- Don't use fstab when on systemd-enabled system,
    workaround for SaltStack bug #39757 #}
{%- set path_escaped = volume.path|replace('/', '', 1)|replace('/', '-') %}

glusterfs_systemd_mount_{{ name }}:
  file.managed:
    - name: /etc/systemd/system/{{ path_escaped }}.mount
    - source: salt://glusterfs/files/glusterfs-client.mount
    - template: jinja
    - defaults:
        path: {{ volume.path }}
        device: {{ volume.server }}:/{{ name }}
        options: {{ volume.get('opts', client.mount_defaults) }}
        timeout: {{ volume.get('timeout', 300) }}

glusterfs_mount_{{ name }}:
  service.running:
    - name: {{ path_escaped }}.mount
    - enable: true
    - watch:
      - file: glusterfs_systemd_mount_{{ name }}

{%- else %}

glusterfs_mount_{{ name }}:
  mount.mounted:
    - name: {{ volume.path }}
    - device: {{ volume.server }}:/{{ name }}
    - fstype: glusterfs
    - mkmnt: true
    - opts: {{ volume.get('opts', client.mount_defaults) }}
    - require:
      - pkg: glusterfs_client_packages

{%- endif %}

{# Fix privileges on mount #}
{%- if volume.user is defined or volume.group is defined %}

glusterfs_dir_{{ name }}:
  file.directory:
    - name: {{ volume.path }}
    - user: {{ volume.get('user', 'root') }}
    - group: {{ volume.get('group', 'root') }}
    - mode: {{ volume.get('mode', '755') }}
    - require:
      {%- if grains.get('init', None) == 'systemd' %}
      - service: glusterfs_mount_{{ name }}
      {%- else %}
      - mount: glusterfs_mount_{{ name }}
      {%- endif %}

{%- endif %}

{%- endfor %}
{%- endif %}

{%- endif %}
