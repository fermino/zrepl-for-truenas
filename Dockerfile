FROM ubuntu:resolute

ARG DEBIAN_FRONTEND=noninteractive

RUN <<EOF
    set -euo pipefail

    apt-get update
    apt-get dist-upgrade -y
    apt-get install --no-install-recommends --no-install-suggests -y ca-certificates curl gnupg zfsutils-linux

    # https://zrepl.github.io/installation/apt-repos.html
    curl -fsSL "https://zrepl.cschwarz.com/apt/apt-key.asc" \
        | gpg --dearmor \
        > /usr/share/keyrings/zrepl.gpg
    sed 's/^ *//' <<SOURCES_EOF > /etc/apt/sources.list.d/zrepl.sources
        Types: deb
        URIs: https://zrepl.cschwarz.com/apt/ubuntu
        Suites: resolute
        Components: main
        Signed-By: /usr/share/keyrings/zrepl.gpg
SOURCES_EOF

    apt-get update
    apt-get install --no-install-recommends --no-install-suggests -y zrepl

    apt-get remove --purge -y ca-certificates curl gnupg
    apt-get autoremove --purge -y
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    mkdir /var/run/zrepl
    chmod 700 /var/run/zrepl

    rm -rf /etc/zrepl
EOF

VOLUME /etc/zrepl
ENTRYPOINT ["/usr/bin/zrepl", "daemon"]
