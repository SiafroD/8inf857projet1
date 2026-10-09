# Suricata with the ET Open ruleset frozen at a known version (et-open/VERSION).
FROM docker.io/jasonish/suricata:8.0.7

COPY et-open/emerging.rules.tar.gz disable.conf /opt/et-open/

# Installed under /opt, not /var/lib/suricata: that path is a VOLUME in the
# image, and what a build step writes into a volume is thrown away.
RUN suricata-update \
        --url file:///opt/et-open/emerging.rules.tar.gz \
        --disable-conf /opt/et-open/disable.conf \
        --suricata-conf /etc/suricata.dist/suricata.yaml \
        --output /opt/et-open/rules \
        --no-reload && \
    # suricata-update makes the folder root-only (750), and Suricata drops to its
    # own user at start: without this it silently runs with no ET rule at all.
    chmod -R a+rX /opt/et-open/rules
