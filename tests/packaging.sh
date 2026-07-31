#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

[[ -x recife.tmux ]] || { echo 'recife.tmux must be executable' >&2; exit 1; }
[[ -x tests/integration.sh ]] || { echo 'integration test must be executable' >&2; exit 1; }
[[ "$(head -n 1 recife.tmux)" == '#!/usr/bin/env bash' ]] || { echo 'invalid entrypoint shebang' >&2; exit 1; }
bash -n recife.tmux tests/integration.sh tests/packaging.sh
shellcheck recife.tmux tests/integration.sh tests/packaging.sh

[[ -f LICENSE ]] || { echo 'LICENSE is required' >&2; exit 1; }

if git ls-files | grep -Eq '(^|/)(\.superpowers|docs/superpowers|ai_docs)(/|$)'; then
  echo 'planning artifacts must not be committed' >&2
  exit 1
fi

[[ -f README.md ]] || { echo 'README.md is required' >&2; exit 1; }
[[ -f assets/recife.png ]] || { echo 'assets/recife.png is required' >&2; exit 1; }
grep -q 'carlosarraes/tmux-recife' README.md || { echo 'README must contain TPM coordinates' >&2; exit 1; }
grep -q 'zero-runtime tmux theme' README.md || { echo 'README must state the runtime guarantee' >&2; exit 1; }
grep -q '@recife_show_seer' README.md || { echo 'README must document Seer integration' >&2; exit 1; }
grep -q '@recife_seer_accents' README.md || { echo 'README must document Seer accents' >&2; exit 1; }
grep -q '@recife_waiting' README.md || { echo 'README must document the waiting color' >&2; exit 1; }

echo 'packaging checks passed'
