#!/usr/bin/env bash
# Compare two executable-output capture directories produced by run-exes.sh.
#
#   Usage: bash compare-exes.sh <dir-a> <dir-b>
#
# Applies the per-target comparison tier measured in exe/REPRODUCIBILITY.md:
#   Tier 1 (7 targets) - exact comparison after elapsed-time/path masking.
#   Tier 2 (5 targets) - RNG-derived cardinalities additionally masked, because these targets
#                        call unseeded IO.rand and do not reproduce against themselves.
# Exit status is the number of targets that differ.
set -u
A="${1:?usage: compare-exes.sh <dir-a> <dir-b>}"
B="${2:?usage: compare-exes.sh <dir-a> <dir-b>}"
HERE="$(cd "$(dirname "$0")" && pwd)"

TIER2="contrastive_generator dataset_generator enum_benchmark proof_first_generator tableau_proof_steps"

ALL="benchmark_anchors benchmark_oracle contrastive_generator dataset_generator dataset_validator
     enum_benchmark machine_appendix proof_extractor proof_first_generator tableau_bridge
     tableau_proof_steps trace_exporter"

fail=0
for n in $ALL; do
  mode=""
  label="exact"
  case " $TIER2 " in *" $n "*) mode="--structural"; label="structural";; esac

  if [ ! -f "$A/$n.out" ] || [ ! -f "$B/$n.out" ]; then
    echo "MISSING     $n (no capture in one side)"
    fail=$((fail+1)); continue
  fi

  ea=$(cat "$A/$n.exit" 2>/dev/null); eb=$(cat "$B/$n.exit" 2>/dev/null)
  if [ "$ea" != "$eb" ]; then
    echo "EXIT-DIFF   $n ($ea vs $eb)"
    fail=$((fail+1)); continue
  fi

  if diff -q <(bash "$HERE/normalize.sh" $mode "$A/$n.out") \
             <(bash "$HERE/normalize.sh" $mode "$B/$n.out") >/dev/null; then
    echo "MATCH       $n [$label]"
  else
    echo "DIFF        $n [$label]"
    diff <(bash "$HERE/normalize.sh" $mode "$A/$n.out") \
         <(bash "$HERE/normalize.sh" $mode "$B/$n.out") | head -20
    fail=$((fail+1))
  fi
done

echo "---"
echo "$fail target(s) differ"
exit "$fail"
