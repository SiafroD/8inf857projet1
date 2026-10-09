FROM docker.elastic.co/kibana/kibana:9.0.2

USER root

COPY kibana.yml /usr/share/kibana/config/kibana.yml

RUN mkdir -p /usr/share/kibana/logs && \
	chown -R kibana:root /usr/share/kibana/logs

USER kibana