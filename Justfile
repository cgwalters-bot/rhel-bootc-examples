# Build one example.
# If the example has its own Justfile, delegate to its `build` recipe
# (which may do custom setup e.g. secrets). Otherwise run podman build.
build example:
    #!/bin/bash
    set -euo pipefail
    if [ -f "{{example}}/Justfile" ]; then
        just --justfile "{{example}}/Justfile" --working-directory "{{example}}" build
    else
        podman build -t "localhost/{{example}}:latest" "{{example}}"
    fi

# Build every example that contains a Containerfile. bootc-git isn't an
# example (it compiles bootc, which takes a while); see `just bootc-rpms`.
build-all:
    #!/bin/bash
    set -euo pipefail
    for d in */; do
        [ -f "$d/Containerfile" ] || continue
        [ "${d%/}" = bootc-git ] && continue
        just build "${d%/}"
    done

# Build bootc RPMs from git into an image and print its name (for BOOTC_RPMS)
bootc-rpms:
    @just --justfile bootc-git/Justfile --working-directory bootc-git build

# Pin bootc-git to the current head of bootc and the current buildroot image.
bootc-git-bump:
    @just --justfile bootc-git/Justfile --working-directory bootc-git bump

# Build, lint, make a qcow2 with image-builder, boot, switch and upgrade
# a composefs example (sealed or unsealed); see tests/composefs_e2e.py.
e2e variant:
    tests/composefs_e2e.py {{variant}}
