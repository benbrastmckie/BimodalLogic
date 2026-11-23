#!/usr/bin/env bash
# verify-all.sh
#
# PURPOSE: local aggregator that mirrors .github/workflows/ci.yml's ten-check gate, so a
# contributor can reproduce CI's verdict before pushing instead of discovering a CI-red commit
# only after a long CI run. .github/workflows/ci.yml is the source of record for the check list
# and the reporting shape below -- this script reuses CI's own "Report results" step's logic
# rather than inventing a new one. If the two ever disagree, ci.yml wins and this script is
# stale.
#
# PRECONDITION: a successful `lake build` and `lake test`. ci.yml's `lean-action` and
# `lean_exe` build/test steps are separate hard stops that run BEFORE the ten checks below;
# this script assumes they have already passed locally and does not re-run them.
#
# USAGE: bash scripts/verify-all.sh
#
# EXIT CODE CONTRACT: exits 0 iff all ten checks that ran reported PASS (a SKIPPED check, when
# `lake` is unavailable, does not itself cause a nonzero exit); exits 1 if any check FAILed, or
# if the number of reported outcomes does not match the number of checks this script runs
# (an out-of-sync guard -- see ci.yml's own "Report results" step for the same assertion).
#
# WHY NOT `set -e`: a failing check must not abort the run -- every later check still needs to
# run and report, matching how CI's `continue-on-error: true` steps all run regardless of an
# earlier failure. Each check below is guarded as `rc=0; <invocation> || rc=$?` and the explicit
# `rc` is handed to `report`, rather than relying on `$?` immediately after a bare command.
set -uo pipefail

echo "Precondition reminder: this script assumes 'lake build' and 'lake test' already succeeded."
echo "It does not run them itself -- see ci.yml, whose build/test steps are separate hard stops"
echo "above the ten checks below."
echo
echo "=== Check step outcomes ==="

expected=10
seen=0
passed=0
failed=0
skipped=0

# Same three-way classification as ci.yml's Report results step, adapted from a GitHub Actions
# step `outcome` to a local exit code: 0 -> PASS, the sentinel string "SKIPPED" -> SKIPPED
# (Decision 3: used only when `lake` is unavailable for checks 8 to 10), anything else -> FAIL.
report() {
  seen=$((seen + 1))
  local label="$1" result="$2"
  case "$result" in
    0)
      passed=$((passed + 1))
      printf '  PASS     %s\n' "$label"
      ;;
    SKIPPED)
      skipped=$((skipped + 1))
      printf '  SKIPPED  %s\n' "$label"
      ;;
    *)
      failed=$((failed + 1))
      printf '  FAIL     %s (exit: %s)\n' "$label" "$result"
      ;;
  esac
}

# --- 1. check-evidence-probes.sh ------------------------------------------------------------
# ci.yml step: "check-evidence-probes.sh" (id: evidence-probes)
rc=0
bash scripts/check-evidence-probes.sh || rc=$?
report "check-evidence-probes.sh" "$rc"

# --- 2. check-module-invariants.sh --no-build -----------------------------------------------
# ci.yml step: "Check module invariants (scripts/check-module-invariants.sh --no-build)"
# (id: module-invariants)
rc=0
bash scripts/check-module-invariants.sh --no-build || rc=$?
report "check-module-invariants.sh --no-build" "$rc"

# --- 3. check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib -------------
# ci.yml step: "Check copyright headers (scripts/check-copyright-headers.sh --strict)"
# (id: copyright-headers). BimodalTools and BimodalLib are named explicitly: the script
# defaults to ROOTS=("FormalSystem") and would silently drop both from a bare invocation.
rc=0
bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib || rc=$?
report "check-copyright-headers.sh --strict" "$rc"

# --- 4. readme-lint.sh FormalSystem BimodalTools BimodalLib -----------------------------------
# ci.yml step: "Check README health (scripts/readme-lint.sh)" (id: readme-lint). Same
# ROOTS=("FormalSystem") default hazard as check 3 above.
rc=0
bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib || rc=$?
report "readme-lint.sh" "$rc"

# --- 5. check-metalogic-cycles.sh -------------------------------------------------------------
# ci.yml step: "Check Metalogic directory-level import cycles (scripts/check-metalogic-cycles.sh)"
# (id: metalogic-cycles)
rc=0
bash scripts/check-metalogic-cycles.sh || rc=$?
report "check-metalogic-cycles.sh" "$rc"

# --- 6. typst-sync-check.sh --------------------------------------------------------------------
# ci.yml step: "Typst sync check (scripts/typst-sync-check.sh)" (id: typst-sync)
rc=0
bash scripts/typst-sync-check.sh || rc=$?
report "typst-sync-check.sh" "$rc"

# --- 7. check-paper-definitions.sh --------------------------------------------------------------
# ci.yml step: "Check paper definitions (scripts/check-paper-definitions.sh)"
# (id: paper-definitions). Decision 6: the script's own `SKIP (neutral): ...` exit-0 message
# (when the upstream paper repository is not present) is a script-internal result, not a
# skipped CI step -- it is reported as PASS here, matching ci.yml's own `outcome: success`.
rc=0
bash scripts/check-paper-definitions.sh || rc=$?
report "check-paper-definitions.sh" "$rc"

# --- 8, 9 & 10: lake-dependent checks -----------------------------------------------------------
# Decision 3: if `lake` is not on PATH, checks 8 to 10 are reported SKIPPED rather than FAIL,
# mirroring CI's "the four lake-dependent checks are correctly skipped when the build itself
# broke" semantics (locally: lake is simply unavailable).
if command -v lake >/dev/null 2>&1; then
  # --- 8. lake exe mk_all --lib FormalSystem --check -------------------------------------------
  # ci.yml step: "Check the generated library root (lake exe mk_all --lib FormalSystem --check)"
  # (id: mk-all-check). `--lib FormalSystem` is structural: a bare `mk_all` errors on the two
  # `srcDir = "Tests"` libraries.
  rc=0
  lake exe mk_all --lib FormalSystem --check || rc=$?
  report "mk_all --lib FormalSystem --check" "$rc"

  # --- 9. lint-style + executable-bit scan + case-collision scan (one verdict) ------------------
  # ci.yml step: "Text-based style linters (lake exe lint-style)" (id: lint-style). Decision 1:
  # CI's single `run:` block uses `set -euo pipefail`, so a mid-step failure there stops the
  # later sub-checks; all three sub-checks run here unconditionally (strictly stricter, never
  # laxer), and check 9 reports FAIL if any of the three fails.
  rc9=0
  lake exe lint-style || rc9=$?
  if [ "$rc9" -ne 0 ]; then
    echo "  (lint-style sub-check failed, see output above)"
  fi

  executable_files="$(git ls-files -s -- '*.lean' | awk '$1 == "100755" { print $4 }')"
  if [ -n "$executable_files" ]; then
    echo "  (executable-bit sub-check failed) Lean files with the executable bit set:"
    echo "$executable_files"
    rc9=1
  fi

  case_collisions="$(git ls-files | tr '[:upper:]' '[:lower:]' | sort | uniq -d)"
  if [ -n "$case_collisions" ]; then
    echo "  (case-collision sub-check failed) tracked paths that collide on a case-insensitive filesystem:"
    echo "$case_collisions"
    rc9=1
  fi

  report "lint-style (+ executable-bit + case-collision)" "$rc9"

  # --- 10. library-index.sh --check --------------------------------------------------------------
  # ci.yml step: "Check the library index (scripts/library-index.sh --no-build --check)"
  # (id: library-index). CI passes `--no-build` because its preceding step has just built
  # `BimodalLib`; no step here has, so this invocation builds it first. `BimodalLib` is outside
  # `defaultTargets`, so the `lake build` this script's precondition names does not cover it.
  rc=0
  bash scripts/library-index.sh --check || rc=$?
  report "library-index.sh --check" "$rc"
else
  report "mk_all --lib FormalSystem --check" "SKIPPED"
  report "lint-style (+ executable-bit + case-collision)" "SKIPPED"
  report "library-index.sh --check" "SKIPPED"
fi

echo
if [ "$seen" -ne "$expected" ]; then
  echo "ERROR: reported $seen check outcomes but expected $expected -- the report calls in this script are out of sync with the checks above."
  exit 1
fi
if [ "$failed" -gt 0 ]; then
  echo "ERROR: $failed check(s) failed -- see the FAIL lines above."
  echo "RESULT: FAIL ($failed failed, $passed passed, $skipped skipped)"
  exit 1
fi
if [ "$skipped" -gt 0 ]; then
  echo "RESULT: PASS for all $passed checks that ran, but $skipped were skipped (lake not on PATH)."
  exit 0
fi
echo "RESULT: PASS (all $seen checks ran and passed)"
