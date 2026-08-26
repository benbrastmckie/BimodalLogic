#!/usr/bin/env bash
set -uo pipefail
cd /home/benjamin/Projects/BimodalLogic
LOG=specs/496_research_algebraic_stack_build_graph_wiring/logs/exp2.log
: > "$LOG"
GUARD=".claude/scripts/lake-build-guard.sh"
COMPL=FormalSystem/Metalogic/BXCanonical/Completeness.lean
META=FormalSystem/Metalogic.lean

cp "$COMPL" /tmp/exp2-completeness.bak
cp "$META"  /tmp/exp2-metalogic.bak

run() { # $1=label
  local S E RC
  S=$(date +%s)
  bash "$GUARD" build --timeout 1800 --no-share -- build >>"$LOG" 2>&1
  RC=$?; E=$(date +%s)
  echo "RESULT $1 rc=$RC elapsed=$((E-S))s" >>"$LOG"
}

echo "########## VARIANT B (ADVERSARIAL): aggregator imported UPSTREAM, into BXCanonical/Completeness.lean ##########" >>"$LOG"
# insert import after the last existing import line
sed -i '0,/^import FormalSystem.Semantics.Validity$/s//import FormalSystem.Semantics.Validity\nimport FormalSystem.Metalogic.Algebraic/' "$COMPL"
grep -n "^import" "$COMPL" >>"$LOG"
run "VARIANT_B"
cp "$COMPL" specs/496_research_algebraic_stack_build_graph_wiring/logs/variantB-completeness-imports.txt
cp /tmp/exp2-completeness.bak "$COMPL"

echo "########## VARIANT A (RECOMMENDED): aggregator imported DOWNSTREAM, into Metalogic.lean ##########" >>"$LOG"
sed -i '0,/^import FormalSystem.Metalogic.Conservativity$/s//import FormalSystem.Metalogic.Conservativity\nimport FormalSystem.Metalogic.Algebraic/' "$META"
grep -n "^import" "$META" >>"$LOG"
run "VARIANT_A"
cp /tmp/exp2-metalogic.bak "$META"

echo "########## REVERT + restore build cache ##########" >>"$LOG"
git status --short FormalSystem/ >>"$LOG" 2>&1
run "REVERTED_BASELINE"
echo "=== DONE ===" >>"$LOG"
