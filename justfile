# Recife development and release tasks.

default: check

check:
    bash -n recife.tmux tests/*.sh
    shellcheck recife.tmux tests/*.sh
    tests/integration.sh
    tests/packaging.sh

release version:
    #!/usr/bin/env bash
    set -euo pipefail
    version="{{version}}"
    version="${version#v}"
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "invalid semver: $version" >&2; exit 1; }
    [[ -z "$(git status --porcelain)" ]] || { echo 'working tree must be clean' >&2; exit 1; }
    git rev-parse "v$version" >/dev/null 2>&1 && { echo "tag v$version already exists" >&2; exit 1; }
    just check
    git tag -a "v$version" -m "v$version"
    git push origin main
    git push origin "v$version"
