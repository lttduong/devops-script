# Base image for Exim4
FROM docker.elastic.co/beats/filebeat:8.8.2

# Copy module configuration files
USER root
COPY  --chown=root:filebeat module/exim4 /usr/share/filebeat/module/exim4
COPY  --chown=root:filebeat modules.d/exim4.yml.disabled /usr/share/filebeat/modules.d

USER filebeat
RUN filebeat modules enable exim4
