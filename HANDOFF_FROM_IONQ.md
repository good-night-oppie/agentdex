# Handoff from ionq cross-repo session → agentdex MVP work

**From:** ionq cwd (`~/gh/ionq`, simplify-v1 working tree as orchestration base)
**To:** next agentdex session (MVP scoping + Phase 2/3 substrate integration)
**Timestamp:** 2026-05-31 ~11:25 PDT
**Reason:** Cross-repo hook sync + architecture memory + tech direction landed this session; agentdex MVP design is the next discrete arc.

---

## What got done this session

### 1. Anti-reward-hack hook chain — uniform `_<repo>_hooks` (agentdex canonical)

- **Path B decided** (operator 10:14 PDT): uniform `_<repo>_hooks` naming + agentdex as canonical hook source.
- **agentdex/hooks/_agentdex_hooks/** is now canonical. 11 .py modules: orchestrator + 4 detectors + judge proxy chain + test runner + heldout sampler + agent metrics + shadow promoter. Polyglot (Py + Go + JS + Rust suppression patterns, language-agnostic RISK_PATHS).
- **agentdex/scripts/sync-hooks.sh** propagates canonical → bene/helios/oppie with sed-rewrite of `_agentdex_hooks` → `_<repo>_hooks` and `AGENTDEX_HOOKS_BASE_REF` → `<REPO>_HOOKS_BASE_REF`.
- **Repo-neutral source content**: `.claude/agents/judge.md` uses `<pkg>` / `<src>` placeholders + multi-lang examples; `__init__.py` docstring is shared-chain doc not first-person canonical. So sync is a pure overwrite + sed, no per-target hand-edits.
- **Idempotent verified**: second sync run leaves zero git diff.

Commits:
- `agentdex 425a8ed` — repo-neutral judge.md + __init__.py (canonical hook source ready)
- `agentdex 36527ec` — scripts/sync-hooks.sh added
- `agentdex (earlier)` — `_ionq_hooks` → `_agentdex_hooks` rename
- `bene 86df50b` — re-synced to canonical (repo-neutral)
- `bene e4d39c2` — upgrade from older ionq-simplify-v1 baseline to agentdex polyglot
- `bene eb77bf9` — first hook port (was older simplify-v1 snapshot; now replaced)
- helios: local-only (gitignored via `.git/info/exclude`); rename + sync done in-place, no remote update

### 2. Architecture memory across 4 repo project dirs

Memory files at `/home/admin/.claude/projects/-home-admin-gh-<repo>/memory/`:

| Repo | project-role.md | github-noreply-email.md | tech-stack* | deployment-fast-path |
|---|---|---|---|---|
| agentdex | yes | yes | tech-stack.md | yes (ai-coach-MCP / fast-path) |
| bene | yes | yes | tech-stack-callup.md (substrate impl) | — |
| helios | yes | yes | — | — |
| oppie | yes (pre-staged) | yes (pre-staged) | — | — |

Captured architecture intent:
- **agentdex = product** — platform for agent harnesses, hosted on ai-builders.space
- **bene = substrate** — Python LLM agent runtime + persistent skill graph; ionq successor; durable replay backed by postgres or supabase (decision pending)
- **helios = substrate** — Rust CoW + Merkle CAS storage
- **oppie = forked OpenAI Codex** — sample agent-harness consumer; dogfood signal for agentdex design

### 3. Tech stack direction

- **Observability**: langfuse for tracing/eval/prompt-version surface
- **Durable replay**: bene + postgres (self-hosted) OR bene + supabase (managed) — pick pending
- **MVP deployment**: consult **ai-coach-MCP** for fast-path to ai-builders.space; MCP server not yet configured in any `.mcp.json` — set up before MVP scoping

### 4. ARC-AGI-3 marquee + situation engine finding (ionq side)

- 6 games × 3 seeds marquee on ionq + trex; pinned RNG=42 produces byte-identical RHAE 9 decimals → ionq vs trex runtime-equivalent (extends the 96.6% derived-work finding from ionq plan.md §1)
- **Dead-code finding**: `_build_situation_brief()` in ionq's proposer.py defined but never called (trex calls it line 217). ionq's recorded +56% MUTATE lift was measured situation-OFF.
- Memo + experiment plan parked at `bene/.harness/notes.md` for future A/B (situation-ON arm). Implementation handoff captured.

Artifacts: `/tmp/{ionq,trex}-arc-{marquee,noise,pinned}-results.json` (volatile)

---

## State right now (2026-05-31 ~11:25 PDT)

```
agentdex   main @ 425a8ed   pushed   canonical hook source ready + sync script + repo-neutral content
bene       main @ 86df50b   pushed   _bene_hooks synced to canonical; Phase 1 spec extraction complete (docs/spec/**)
helios     local-only       —        synced to canonical; PR work on feat/agent-id-ffi-rust continues
oppie      not cloned       —        memory pre-staged; sync script SKIPs until ~/gh/oppie exists
ionq       simplify-v1      —        decommissioning; bene is successor
```

agentdex's current active spec: PHASE-2 battle engine MVP. Hook sync work this session was operator-authorized scope-creep (disclosed in `.harness/disclosure.md`); the spec file itself is unchanged.

---

## What's next for agentdex (in rough priority order)

1. **Set up ai-coach-MCP**. Add to `~/gh/agentdex/.mcp.json` so it auto-loads when working in agentdex cwd. Without this, "MVP design must consult ai-coach-MCP" memo can't be honored. Source URL: TBD (operator hint, not configured locally).

2. **Pick postgres vs supabase** for bene's durable backing. Tradeoff: build velocity (supabase) vs operational control (self-hosted postgres). Decision should land in bene's `tech-stack-callup.md` memo so Phase 2/3 schema work knows the target.

3. **MVP scoping with ai-coach-MCP** once #1 done. Questions to ask:
   - Minimum agentdex surface ai-builders.space needs to host
   - Vetted Docker / framework / secret store / edge runtime path
   - Substrate consumption pattern (bene vs helios vs direct postgres)
   - Load-test envelope specific to ai-builders.space

4. **Resume PHASE-2 battle engine MVP** (`.harness/spec.md` current active spec). This session left it untouched.

5. **Clone oppie** to `~/gh/oppie`. Once cloned, sync script auto-onboards it (`bash agentdex/scripts/sync-hooks.sh`). Memory at `/home/admin/.claude/projects/-home-admin-gh-oppie/memory/` will auto-load.

6. **Optional**: situation A/B experiment from the parked bene memo. Lower priority — pure research finding, doesn't block agentdex MVP.

---

## References

### Key memory paths
- Agentdex memory: `/home/admin/.claude/projects/-home-admin-gh-agentdex/memory/`
  - `project-role.md`, `tech-stack.md`, `deployment-fast-path.md`, `github-noreply-email.md`, `MEMORY.md` (index)
- bene memory: `/home/admin/.claude/projects/-home-admin-gh-bene/memory/`
- helios memory: `/home/admin/.claude/projects/-home-admin-gh-helios/memory/`
- oppie memory: `/home/admin/.claude/projects/-home-admin-gh-oppie/memory/` (pre-staged)

### Key file paths in agentdex
- `.harness/spec.md` — current active spec (PHASE-2 battle engine MVP)
- `.harness/disclosure.md` — 3 scope: entries from this session (hook rename, sync script, repo-neutral fix)
- `hooks/_agentdex_hooks/` — canonical hook chain
- `scripts/sync-hooks.sh` — agentdex → bene/helios/oppie sync
- `.claude/{settings.json, hooks/, agents/judge.md}` — Claude Code hook config

### Operator-known constraints
- **Github push email**: must use `Eddie Tang <3278807+EdwardTang@users.noreply.github.com>` (GH007 blocks `etang@qumulo.com`). Apply via `git -c user.email=... -c user.name=...` per commit. NOT global git config.
- **bene first 4 commits** used `noreply@oppie.xyz` (different noreply form). Subsequent commits (eb77bf9 onward) use GitHub-style. Don't normalize history this session.
- **ionq is decommissioning**. Don't start new work in `~/gh/ionq`. New runtime work → bene. New product work → agentdex.

### Recent commits worth checking
- agentdex: `git log --oneline | head -10` (top: 425a8ed)
- bene: `git log --oneline | head -10` (top: 86df50b)
- helios: `git log --oneline | head -10` (uncommitted M files on `feat/agent-id-ffi-rust` from prior session)

---

## Pending decisions (operator green-light needed)

1. **postgres vs supabase** for bene durable backing.
2. **ai-coach-MCP source URL** + setup method (add to `~/gh/agentdex/.mcp.json`).
3. **oppie clone**: when, from which fork point, into `~/gh/oppie` or elsewhere?
4. **situation A/B**: launch in bene as separate experiment OR archive the finding without running?

---

## Quick sanity checks before resuming

```bash
# Verify hook sync state
bash ~/gh/agentdex/scripts/sync-hooks.sh --dry-run

# Verify agentdex hook chain runs
CLAUDE_PROJECT_DIR=~/gh/agentdex python3 ~/gh/agentdex/.claude/hooks/stop-integrity-check.py <<< '{}'

# Verify memory loads
cat /home/admin/.claude/projects/-home-admin-gh-agentdex/memory/MEMORY.md
```
