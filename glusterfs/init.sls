include:
{% if pillar.glusterfs.server is defined %}
- glusterfs.server
{% endif %}
{% if pillar.glusterfs.client is defined %}
- glusterfs.client
{% endif %}
