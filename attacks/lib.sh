# Shared helpers for the attack scripts. Sourced, not run.
#
# RT   : docker, or podman if docker is absent.
# PROJ : the compose project name, which prefixes the network names.
# on <zone> <args...> : run the attacker image on the lab network <zone>
#                       (public, db, logs...), removing the container afterwards.
set -eu
RT=${RT:-$(command -v docker >/dev/null 2>&1 && echo docker || echo podman)}
PROJ=${PROJ:-8inf857projet1}
HERE=$(cd "$(dirname "$0")/.." && pwd)

on() {
    zone=$1; shift
    "$RT" run --rm --network "${PROJ}_${zone}" "${PROJ}-attacker" "$@"
}

# Build the attacker image once if it is missing.
"$RT" image exists "${PROJ}-attacker" 2>/dev/null ||
    "$RT" images --format '{{.Repository}}' | grep -qx "${PROJ}-attacker" ||
    "$RT" build -t "${PROJ}-attacker" "$HERE/attacker"
