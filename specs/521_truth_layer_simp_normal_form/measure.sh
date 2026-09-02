#!/usr/bin/env bash
# Task 521 measurement harness. Re-runnable; used for Phase 1 baseline and Phase 10 final.
cd "$(git rev-parse --show-toplevel)" || exit 1
S=FormalSystem/Metalogic/Soundness.lean
NAMED="temp_l_valid temp_linearity_valid discreteness_forward_valid enrichment_until_valid enrichment_since_valid absorb_until_valid absorb_since_valid linear_until_valid linear_since_valid prior_U_gap_valid prior_S_gap_valid"

echo "== (B) per-file 'simp only [...TruthAt...]' counts =="
for f in FormalSystem/Semantics/Truth.lean \
         FormalSystem/Semantics/BLTruth.lean \
         FormalSystem/Metalogic/Soundness.lean \
         FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean \
         FormalSystem/Semantics/Correspondence/DurationFrames.lean \
         FormalSystem/Metalogic/DedekindNonCompactness.lean \
         FormalSystem/Metalogic/Independence/CoNotPriorU.lean \
         FormalSystem/Metalogic/DiscreteNonCompactness.lean; do
  printf "%-62s %s\n" "$f" "$(grep -c 'simp only \[[^]]*TruthAt' "$f")"
done
echo "tree-wide live: $(grep -rn 'simp only \[[^]]*TruthAt' FormalSystem/ --include=*.lean | grep -v Boneyard | wc -l)"

echo
echo "== (A) eleven named declarations: length + TruthAt sites =="
total_sites=0; total_lines=0
for n in $NAMED; do
  start=$(grep -n "^theorem ${n} " "$S" | head -1 | cut -d: -f1)
  [ -z "$start" ] && { echo "MISSING $n"; continue; }
  # end = line before the next top-level decl/section marker after start
  end=$(awk -v s="$start" 'NR>s && /^(theorem|lemma|private theorem|private lemma|def|@\[|\/-|section|end|namespace|noncomputable)/ {print NR-1; exit}' "$S")
  [ -z "$end" ] && end=$(wc -l < "$S")
  len=$((end - start + 1))
  sites=$(sed -n "${start},${end}p" "$S" | grep -c 'simp only \[[^]]*TruthAt')
  printf "%-30s start=%-6s lines=%-5s sites=%s\n" "$n" "$start" "$len" "$sites"
  total_sites=$((total_sites+sites)); total_lines=$((total_lines+len))
done
echo "TOTAL lines=$total_lines sites=$total_sites"

echo
echo "== bare simp/simp_all/aesop audit (files mentioning TruthAt) =="
files=$(grep -rl 'TruthAt' FormalSystem/ --include=*.lean | grep -v Boneyard)
grep -nE '(^|[[:space:]])(simp|simp_all|aesop)([[:space:]]|$|\[)' $files | grep -vE 'simp only|simp_arith|simpa' | tee /dev/stderr | wc -l

echo
echo "== duplicate helpers =="
grep -rn "truth_and_iff\|truth_always_of_forall\|truth_of_always\|always_elim\|and_of_not_imp_not" FormalSystem/ --include=*.lean | grep -v Boneyard
