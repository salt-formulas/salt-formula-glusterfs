{% from "glusterfs/map.jinja" import server with context %}

{%- if grains['saltversion'] < "2015.8.0" %}
{# Parameter force doesn't exist in Salt 2015.8 and without it volume
creation will fail when brick is on root partition #}
{% set force_compatibility = True %}
{%- else %}
{% set force_compatibility = False %}
{%- endif %}

{%- if server.enabled %}

include:
- glusterfs.server.service

{%- if server.peers is defined %}

glusterfs_peers:
    glusterfs.peered:
      - names: {{ server.peers }}
      - require:
        - service: glusterfs_service

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
      - glusterfs: glusterfs_peers
      - file: {{ volume.storage }}

{%- endif %}

glusterfs_vol_{{ name }}_start:
  glusterfs.started:
    - name: {{ name }}
    - require:
      {%- if force_compatibility %}
      - cmd: glusterfs_vol_{{ name }}
      {%- else %}
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
