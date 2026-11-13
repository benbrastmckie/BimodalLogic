#!/usr/bin/env bash
# ============================================================================
# typst-machine-appendix.sh
#
# Single-source-of-truth generator for the shipped machine-readable
# axiomatization. Runs the Lean exporter through the Lean
# INTERPRETER (`lake env lean --run`) with git commit stamps and renders
# the committed JSONL artifact into a typst data file. Modeled on
# scripts/typst-status-counts.sh.
#
# Why the interpreter and not `lake exe machine_appendix`: the native
# link with `supportInterpreter := true` recompiles Formula.c.o.export
# under LEAN_EXPORTING at -O3, which exhausts memory on constrained
# machines (clang OOM, exit 137). The interpreter consumes the ordinary
# .oleans (built by `lake build BimodalTools.MachineAppendixMain`)
# and produces byte-identical JSONL in seconds. The `lean_exe
# machine_appendix` stanza remains in lakefile.toml for machines that can
# afford the native build, but this script's default path is the
# interpreter.
#
# Artifacts (BOTH committed; data/ is gitignored, generated/ is not):
#   typst/generated/machine-appendix.jsonl
#   typst/generated/machine-appendix.typ
#
# Usage:
#   scripts/typst-machine-appendix.sh
#       Regenerate both artifacts: build the exporter .olean, run it via
#       `lake env lean --run` with
#       --stamp-commit $(git rev-parse --short HEAD) and
#       --stamp-date $(date -u +%Y-%m-%d), then render the .typ strictly
#       from the fresh JSONL. Deterministic: two runs from the same commit
#       on the same (UTC) day produce byte-identical artifacts.
#       Takes the shared `.lake` build lock (`.lake/build-guard.lock`)
#       once, for both lake calls; see the SHARED `.lake` LOCK block in
#       the default-mode section.
#
#   scripts/typst-machine-appendix.sh --json
#       Emit the committed JSONL metadata line to stdout with the stamp
#       fields normalized (zeroed), mirroring typst-status-counts.sh
#       --json. Consumed by scripts/typst-sync-check.sh Check 3. Does NOT
#       invoke lake and takes no lock.
#
#   scripts/typst-machine-appendix.sh --render-only FILE
#       Render the .typ content for the given JSONL file to stdout (stamps
#       are taken from FILE's metadata line, so re-rendering a committed
#       JSONL reproduces the committed .typ byte-for-byte). Consumed by
#       scripts/typst-sync-check.sh Check 3 (rendering agreement). Does
#       NOT invoke lake and takes no lock.
#
# The two build-free modes exit before the lock block and must keep doing
# so: scripts/typst-sync-check.sh runs them from the pre-commit hook and
# from CI, where waiting on a concurrent build would be wrong.
#
# Fidelity contract: the .typ is rendered ONLY from the JSONL (never from
# Lean source, never hand-edited); the JSONL is produced ONLY by the Lean
# exporter (interpreted), whose schema formulas are extracted from the
# Axiom type index.
# ============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# typst/ lives at the project root; the Lean source root (FormalSystem/) does not move.
GEN_DIR="${REPO_ROOT}/typst/generated"
JSONL="${GEN_DIR}/machine-appendix.jsonl"
OUT_TYP="${GEN_DIR}/machine-appendix.typ"

# ---------------------------------------------------------------------------
# JSONL -> .typ renderer (pure function of the input file; stamps come from
# the JSONL metadata line, never from the environment).
# ---------------------------------------------------------------------------
render_typ() {
  # $1 = input JSONL path; renders to stdout
  python3 - "$1" << 'PYEOF'
import json, sys

path = sys.argv[1]
meta = None
axioms, rules, ops = [], [], []
with open(path, encoding="utf-8") as fh:
    for line in fh:
        line = line.strip()
        if not line:
            continue
        obj = json.loads(line)
        kind = obj.get("kind")
        if kind == "metadata":
            meta = obj
        elif kind == "axiom":
            axioms.append(obj)
        elif kind == "inference_rule":
            rules.append(obj)
        elif kind == "derived_operator":
            ops.append(obj)

if meta is None:
    print("ERROR: no metadata line in " + path, file=sys.stderr)
    sys.exit(1)

def typ_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'

commit = meta.get("stamp_commit", "unstamped")
date = meta.get("stamp_date", "unstamped")

out = []
out.append("// ============================================================================")
out.append("// generated/machine-appendix.typ")
out.append("//")
out.append("// GENERATED FILE -- never edit by hand. Regenerate via:")
out.append("//   bash scripts/typst-machine-appendix.sh")
out.append("//")
out.append("// Rendered strictly from generated/machine-appendix.jsonl (same script),")
out.append("// which is produced by the Lean exporter (interpreted via `lake env lean")
out.append("// --run`) with schema formulas extracted from the Axiom type index --")
out.append("// never hand-copied.")
out.append(f"// Stamped from live source at commit {commit} ({date}).")
out.append("// ============================================================================")
out.append("")
out.append(f"#let stamp-commit = {typ_str(commit)}")
out.append(f"#let stamp-date = {typ_str(date)}")
out.append("")
out.append(f"#let machine-axiom-count = {len(axioms)}")
out.append(f"#let machine-rule-count = {len(rules)}")
out.append(f"#let machine-derived-op-count = {len(ops)}")
out.append("")

out.append("#let axiom-table = (")
for a in axioms:
    row = (typ_str(a["name"]), typ_str(a["layer"]),
           typ_str(", ".join(a["params"])), typ_str(a["frame_class"]),
           typ_str(a["schema_string"]))
    out.append("  (" + ", ".join(row) + "),")
out.append(")")
out.append("")

out.append("#let rule-table = (")
for r in rules:
    premises = "; ".join(r["premises"]) if r["premises"] else "—"
    side = r["side_condition"] if r["side_condition"] is not None else "—"
    row = (typ_str(r["name"]), typ_str(premises),
           typ_str(r["conclusion"]), typ_str(side))
    out.append("  (" + ", ".join(row) + "),")
out.append(")")
out.append("")

out.append("#let derived-op-table = (")
for o in ops:
    row = (typ_str(o["name"]), typ_str(", ".join(o["params"])),
           typ_str(o["definition_string"]))
    out.append("  (" + ", ".join(row) + "),")
out.append(")")

print("\n".join(out))
PYEOF
}

# ---------------------------------------------------------------------------
# Mode dispatch
# ---------------------------------------------------------------------------
if [[ "${1:-}" == "--render-only" ]]; then
  if [[ -z "${2:-}" ]]; then
    echo "usage: $0 --render-only FILE" >&2
    exit 2
  fi
  render_typ "$2"
  exit 0
fi

if [[ "${1:-}" == "--json" ]]; then
  if [[ ! -f "${JSONL}" ]]; then
    echo "ERROR: ${JSONL} does not exist -- run bash scripts/typst-machine-appendix.sh" >&2
    exit 1
  fi
  python3 - "${JSONL}" << 'PYEOF'
import json, sys
with open(sys.argv[1], encoding="utf-8") as fh:
    meta = json.loads(fh.readline())
meta["stamp_commit"] = "0000000"
meta["stamp_date"] = "0000-00-00"
print(json.dumps(meta))
PYEOF
  exit 0
fi

# ---------------------------------------------------------------------------
# Default mode: regenerate both artifacts with git stamps
# ---------------------------------------------------------------------------
STAMP_COMMIT=$(git -C "${REPO_ROOT}" rev-parse --short HEAD)
STAMP_DATE=$(date -u +%Y-%m-%d)

mkdir -p "${GEN_DIR}"

cd "${REPO_ROOT}"

# ---------------------------------------------------------------------------
# SHARED `.lake` LOCK
#
# Default mode both WRITES and READS `.lake`: the scoped `lake build` below
# rewrites the exporter's import closure, and the interpreter run after it
# reads those oleans back. Each half races a concurrent guarded `lake build`
# on this tree -- the scoped build can leave another reader looking at an
# olean that was removed and not yet rewritten, and the interpreter can be
# that reader itself, failing with `object file '...' of module ... does not
# exist`. One hold of the writers' lock covers both calls, so the interpreter
# reads exactly the snapshot the build just produced.
#
# The lock is `${REPO_ROOT}/.lake/build-guard.lock`, the path
# `.claude/scripts/lake-build-guard.sh` publishes, taken exclusively in the
# same shape as scripts/check-evidence-probes.sh's `SHARED .lake LOCK` block
# and scripts/check-module-invariants.sh's `C1: build` block: a non-blocking
# try, then an announced bounded wait, the fd held until this process exits
# (never `flock -u`), and an audible unserialized run when `flock` is absent.
# The rejected alternatives (probing for the guard and calling it; refusing to
# run under detected concurrency) are recorded at that `C1: build` block.
#
# LEAF-ONLY. The lock is taken here, by the script that invokes lake, and by
# no caller of this script. An flock belongs to the open file description, so
# a parent holding the lock excludes its own child when the child re-opens the
# lock file: a caller that locked and then ran this script would make it wait
# out the whole bound.
#
# AFTER THE BUILD-FREE EXITS. This block sits below the `--render-only` and
# `--json` exits above on purpose; neither reads a `.lake` artifact.
#
# `MACHINE_APPENDIX_LOCK_WAIT_S` overrides the bounded wait. It exists so the
# timeout branch can be exercised deliberately; it is a test affordance, not a
# tuning knob. Default: 600 s.
# ---------------------------------------------------------------------------
MACHINE_APPENDIX_LOCK_WAIT_S="${MACHINE_APPENDIX_LOCK_WAIT_S:-600}"
LOCK_FILE="${REPO_ROOT}/.lake/build-guard.lock"
mkdir -p "${REPO_ROOT}/.lake"
if command -v flock >/dev/null 2>&1; then
  exec {MACHINE_APPENDIX_LOCK_FD}<>"${LOCK_FILE}"
  if ! flock -n "${MACHINE_APPENDIX_LOCK_FD}"; then
    echo "typst-machine-appendix.sh: waiting on the shared build lock (${LOCK_FILE}, up to ${MACHINE_APPENDIX_LOCK_WAIT_S}s)" >&2
    if ! flock -w "${MACHINE_APPENDIX_LOCK_WAIT_S}" "${MACHINE_APPENDIX_LOCK_FD}"; then
      echo "typst-machine-appendix.sh: ENVIRONMENT failure: timed out after ${MACHINE_APPENDIX_LOCK_WAIT_S}s waiting for the shared build lock" >&2
      echo "  ${LOCK_FILE}" >&2
      echo "  Nothing was built, run, or written. Nothing is wrong with the exporter or the artifacts;" >&2
      echo "  re-run once the concurrent build has finished." >&2
      exit 1
    fi
  fi
else
  echo "typst-machine-appendix.sh: flock not found on PATH; building and running the exporter unserialized" >&2
fi

# Ensure the exporter's .olean (and its dependency closure) is fresh.
# This is ordinary elaboration -- it does NOT trigger the native
# LEAN_EXPORTING/clang link that OOMs on constrained machines.
lake build BimodalTools.MachineAppendixMain

# Run the exporter through the Lean interpreter (uses the .oleans;
# no native code generation). See header comment for rationale.
lake env lean --run BimodalTools/MachineAppendixMain.lean -- \
  --output "${JSONL}" \
  --stamp-commit "${STAMP_COMMIT}" \
  --stamp-date "${STAMP_DATE}"

render_typ "${JSONL}" > "${OUT_TYP}"

echo "Wrote ${JSONL}" >&2
echo "Wrote ${OUT_TYP}" >&2
