include:
- glusterfs.server.service
{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
- glusterfs.server.setup
{%- endif %}
