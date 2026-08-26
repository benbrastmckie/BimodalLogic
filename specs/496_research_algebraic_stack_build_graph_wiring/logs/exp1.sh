#!/usr/bin/env bash
set -uo pipefail
cd /home/benjamin/Projects/BimodalLogic
LOG=specs/496_research_algebraic_stack_build_graph_wiring/logs/exp1.log
: > "$LOG"

echo "=== STEP 1: baseline lake build (steady state check) ===" >>"$LOG"
S=$(date +%s)
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --no-share -- build >>"$LOG" 2>&1
RC=$?
E=$(date +%s)
echo "baseline rc=$RC elapsed=$((E-S))s" >>"$LOG"

echo "=== STEP 2: evict orphaned-stack oleans ===" >>"$LOG"
B=.lake/build/lib/lean/FormalSystem/Metalogic
for m in Algebraic/BooleanStructure Algebraic/InteriorOperators Algebraic/LindenbaumQuotient Algebraic/UltrafilterMCS Algebraic; do
  rm -f "$B/$m.olean" "$B/$m.ilean" "$B/$m.trace" "$B/$m.olean.hash" "$B/$m.ilean.hash"
  echo "evicted $m" >>"$LOG"
done

echo "=== STEP 3: time lake build FormalSystem.Metalogic.Algebraic (marginal cost) ===" >>"$LOG"
S=$(date +%s)
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --no-share -- build FormalSystem.Metalogic.Algebraic >>"$LOG" 2>&1
RC=$?
E=$(date +%s)
echo "aggregator rc=$RC elapsed=$((E-S))s" >>"$LOG"
echo "=== DONE ===" >>"$LOG"
