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

include:
- glusterfs.server.service

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
{%- for name, volume in server.volumes.items() %}

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
  {%- if grains['saltversioninfo'][0] < 2017 or
        (grains['saltversioninfo'][0] == 2017 and grains['saltversioninfo'][1] < 7) %}
  {# glusterfs.created is renamed to glusterfs.volume_present in salt 2017.7
     so maintain backward compatibility #}
  glusterfs.created:
  {%- else %}
  glusterfs.volume_present:
  {%- endif %}
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

{%- if server.recover_peers is defined %}
{%- for vol_name, vol_data in server.volumes.iteritems() %}
{%- for brick in vol_data.bricks %}

add_gluster_bricks_{{ vol_name }}_{{ brick }}:
  cmd.run:
    - name: "gluster volume add-brick {{ vol_name }} replica {{ vol_data.replica }} {{ brick }} force"
    - unless: "gluster volume info {{ vol_name }} | grep {{ brick }}"
    - require:
      {%- if force_compatibility %}
      - cmd: glusterfs_vol_{{ vol_name }}
      {%- else %}
      - glusterfs: glusterfs_vol_{{ vol_name }}
      {%- endif %}

{%- endfor %}
{%- endfor %}
{%- endif %}

{%- endif %}
