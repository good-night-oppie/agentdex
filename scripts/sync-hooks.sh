#!/usr/bin/env bash
# sync-hooks.sh — agentdex canonical → bene/helios/oppie downstream sync
#
# agentdex hosts the canonical _agentdex_hooks/ + .claude/{hooks,agents,settings.json}.
# This script copies that content to peer repos and rewrites the package
# name + env var to match the target repo's identity (_<repo>_hooks /
# <REPO>_HOOKS_BASE_REF).
#
# Targets (sibling git checkouts under ~/gh/):
#   - bene    (~/gh/bene)     — tracked (Phase 1 docs/spec/**)
#   - helios  (~/gh/helios)   — local-only (.git/info/exclude hides .claude
#                                + hooks/ + .harness/ + install.sh)
#   - oppie   (~/gh/oppie)    — pre-staged target; copies only if cloned
#
# Usage:
#   ./scripts/sync-hooks.sh                # sync all 3 targets if present
#   ./scripts/sync-hooks.sh bene helios    # subset
#   ./scripts/sync-hooks.sh --dry-run      # show what would change
#
# Side effects on target:
#   - hooks/_<repo>_hooks/{__init__.py,*.py}  REPLACED
#   - .claude/settings.json                    REPLACED (deny rules adapted)
#   - .claude/hooks/stop-integrity-check.py    REPLACED (import path adapted)
#   - .claude/hooks/spec-injector.sh           REPLACED (unchanged content)
#   - .claude/agents/judge.md                  REPLACED (DISAGREE table generic)
#
# Targets MUST already have a `.harness/` dir + their own
# `.claude/settings.json` schema in place — sync only refreshes content,
# does not bootstrap a new project.
#
# Per repo memory file:
#   /home/admin/.claude/projects/-home-admin-gh-<repo>/memory/project-role.md
# documents the sync direction (agentdex → <repo>).

set -euo pipefail

SRC_REPO="${SRC_REPO:-/home/admin/gh/agentdex}"
SRC_HOOK_PKG="_agentdex_hooks"
SRC_ENV_VAR="AGENTDEX_HOOKS_BASE_REF"

DRY_RUN=0
TARGETS=()
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            sed -n '1,/^set -euo/p' "$0" | head -n -2
            exit 0
            ;;
        *) TARGETS+=("$arg") ;;
    esac
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
    TARGETS=("bene" "helios" "oppie")
fi

say() { printf '[sync-hooks] %s\n' "$*"; }

copy_file() {
    local src="$1" dst="$2"
    if [[ "$DRY_RUN" == 1 ]]; then
        say "  would copy: $src → $dst"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
}

rewrite_in_place() {
    local file="$1" tgt_hook_pkg="$2" tgt_env_var="$3"
    if [[ "$DRY_RUN" == 1 ]]; then
        say "  would rewrite: $file ($SRC_HOOK_PKG→$tgt_hook_pkg, $SRC_ENV_VAR→$tgt_env_var)"
        return
    fi
    sed -i \
        -e "s|${SRC_HOOK_PKG}|${tgt_hook_pkg}|g" \
        -e "s|${SRC_ENV_VAR}|${tgt_env_var}|g" \
        "$file"
}

sync_one() {
    local repo="$1"
    local tgt_dir="/home/admin/gh/$repo"
    local tgt_hook_pkg="_${repo}_hooks"
    local tgt_env_var
    tgt_env_var="$(echo "$repo" | tr '[:lower:]' '[:upper:]')_HOOKS_BASE_REF"

    if [[ ! -d "$tgt_dir/.git" ]]; then
        say "SKIP $repo: $tgt_dir not a git checkout"
        return 0
    fi
    if [[ ! -d "$tgt_dir/.harness" ]]; then
        say "SKIP $repo: $tgt_dir/.harness missing (bootstrap manually first)"
        return 0
    fi

    say "SYNC $repo → $tgt_dir (pkg=$tgt_hook_pkg env=$tgt_env_var)"

    # 1. _<repo>_hooks/ package
    local src_pkg_dir="$SRC_REPO/hooks/$SRC_HOOK_PKG"
    local tgt_pkg_dir="$tgt_dir/hooks/$tgt_hook_pkg"
    mkdir -p "$tgt_pkg_dir"
    for f in "$src_pkg_dir"/*.py; do
        local name; name="$(basename "$f")"
        copy_file "$f" "$tgt_pkg_dir/$name"
        rewrite_in_place "$tgt_pkg_dir/$name" "$tgt_hook_pkg" "$tgt_env_var"
    done

    # 2. .claude/settings.json — deny rules adapted
    copy_file "$SRC_REPO/.claude/settings.json" "$tgt_dir/.claude/settings.json"
    rewrite_in_place "$tgt_dir/.claude/settings.json" "$tgt_hook_pkg" "$tgt_env_var"

    # 3. .claude/hooks/*.sh, *.py — shims, only stop-integrity-check.py needs rewrite
    for f in "$SRC_REPO"/.claude/hooks/*.sh "$SRC_REPO"/.claude/hooks/*.py; do
        [[ -f "$f" ]] || continue
        local name; name="$(basename "$f")"
        copy_file "$f" "$tgt_dir/.claude/hooks/$name"
        if [[ "$name" == "stop-integrity-check.py" ]]; then
            rewrite_in_place "$tgt_dir/.claude/hooks/$name" "$tgt_hook_pkg" "$tgt_env_var"
            [[ "$DRY_RUN" == 1 ]] || chmod +x "$tgt_dir/.claude/hooks/$name"
        elif [[ "$name" == *.sh ]]; then
            [[ "$DRY_RUN" == 1 ]] || chmod +x "$tgt_dir/.claude/hooks/$name"
        fi
    done

    # 4. .claude/agents/judge.md — copied as-is (DISAGREE table is repo-neutral after agentdex's edit)
    copy_file "$SRC_REPO/.claude/agents/judge.md" "$tgt_dir/.claude/agents/judge.md"

    say "  done: $repo"
}

main() {
    if [[ ! -d "$SRC_REPO/hooks/$SRC_HOOK_PKG" ]]; then
        echo "ERROR: SRC_REPO=$SRC_REPO is not an agentdex tree (no hooks/$SRC_HOOK_PKG/)" >&2
        exit 1
    fi
    say "canonical source: $SRC_REPO"
    say "targets: ${TARGETS[*]}"
    if [[ "$DRY_RUN" == 1 ]]; then
        say "DRY-RUN mode — no files will be written"
    fi
    for repo in "${TARGETS[@]}"; do
        sync_one "$repo"
    done
    say "all done."
}

main "$@"
