# syntax=docker/dockerfile:1
FROM docker.elastic.co/elasticsearch/elasticsearch:9.0.2

COPY elasticsearch-entrypoint.sh /usr/local/bin/elasticsearch-entrypoint

ENTRYPOINT ["/bin/tini", "--", "/bin/bash", "/usr/local/bin/elasticsearch-entrypoint"]
CMD ["eswrapper"]

