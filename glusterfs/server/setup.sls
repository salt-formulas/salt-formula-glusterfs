{% from "glusterfs/map.jinja" import server with context %}

{%- if grains['saltversioninfo'][0] < 2016 or
      (grains['saltversioninfo'][0] == 2016 and grains['saltversioninfo'][1] < 3) %}
  {# Parameter force doesn't exist in Salt 2015.8 and without it volume
  creation will fail when brick is on root partition #}
  {% set force_compatibility = True %}
{%- else %}
  {% set force_compatibility = False %}
{%- endif %}

{%- if server.enabled %}
{%- if not grains.get('noservices', False) %}

include:
- glusterfs.server.service

{%- endif %}
{%- if server.peers is defined %}

glusterfs_peers:
  glusterfs.peered:
    - names: {{ server.peers }}
    - require:
      - service: glusterfs_service

{#-
  `gluster peer probe` seems to be async, we need to give Gluster some time to
  settle, especially on slower deployments. Otherwise later volume creations
  may fail.
#}
glusterfs_peers_wait:
  cmd.wait:
    - name: sleep 5
    - watch_in:
      - glusterfs: glusterfs_peers

{%- endif %}

{%- if server.volumes is defined %}
{%- for name, volume in server.volumes.iteritems() %}

{%- if force_compatibility %}

glusterfs_vol_{{ name }}:
  cmd.run:
    - name: |
        gluster volume create {{ name }}
        {%- if volume.replica is defined %} replica {{ volume.replica }} \{% endif %}
        {%- if volume.stripe is defined %} stripe {{ volume.stripe }} \{% endif %}
        {{ volume.bricks|join(' ') }} force
    - unless: "gluster volume info {{ name }}"
    - require:
      - cmd: glusterfs_peers_wait

{%- else %}

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
    - force: true
    - start: true
    - require:
      - cmd: glusterfs_peers_wait
      - file: {{ volume.storage }}

{%- endif %}

glusterfs_vol_{{ name }}_start:
  {%- if force_compatibility %}
  cmd.run:
    - name: gluster volume start {{ name }}
    - unless: "gluster volume info {{ name }} | grep 'Status: Started'"
    - require:
      - cmd: glusterfs_vol_{{ name }}
  {%- else %}
  glusterfs.started:
    - name: {{ name }}
    - require:
      - glusterfs: glusterfs_vol_{{ name }}
  {%- endif %}

{%- if volume.options is defined %}
{%- for key, value in volume.options.iteritems() %}

glusterfs_vol_{{ name }}_{{ key }}:
  cmd.run:
    - name: "gluster volume set '{{ name }}' '{{ key }}' '{{ value }}'"
    - unless: "gluster volume info '{{ name }}' | grep '{{ key }}: {{ value }}'"
    - require:
      {%- if force_compatibility %}
      - cmd: glusterfs_vol_{{ name }}
      {%- else %}
      - glusterfs: glusterfs_vol_{{ name }}
      {%- endif %}
    - require_in:
      - glusterfs: glusterfs_vol_{{ name }}_start

{%- endfor %}
{%- endif %}

{%- endfor %}
{%- endif %}

{%- endif %}
