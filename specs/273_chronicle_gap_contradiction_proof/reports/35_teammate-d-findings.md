# Teammate D Findings: Horizons/Strategic Direction

**Task**: 273 — Chronicle Gap Contradiction Proof (KampBypass.lean sorry closure)
**Role**: Horizons/Strategic Direction
**Date**: 2026-06-15

---

## Key Findings

### 1. The Since Case (L2308) CAN Be Proved Independently of the Bracket Fix

The Since case (`existPart_succ_n1_bypass_k0_since`, L2285-2308) uses `formula_disjList`
and `enriched_bypass_since` (L515-593) — NOT the VecEA2/BracketFormula infrastructure.
`enriched_bypass_since` constructs its formula using `Formula.snce` (pt_x line 593),
`Formula.and`, `formula_conjList`, and `pre_at_t` — none of which involve `VecEA2`,
`BracketFormula`, or `enriched_vecEA2_until`.

The design of `enriched_bypass_since` is a simpler "disjList over nf_x" pattern
identical in structure to how depth-0 formulas are built. The bracket design flaw is
in `enriched_vecEA2_until` (L444-492) which is ONLY called by `enriched_bypass_until`
(L497-511). The Since direction uses a different code path entirely.

**Conclusion**: The Since case proof is semantically independent of the bracket design
flaw. It can be closed in isolation while the bracket redesign is designed for the
Until direction.

### 2. Full Sorry Chain to completeness_discrete

The sorry propagation chain has TWO independent branches:

**Branch A — Stavi/Kamp chain (task 273):**
```
existPart_succ_n1_bypass_k0_since (L2308, OPEN)
  + existPart_succ_n1_bypass_k0_until (L2081, bracket; L2151, forward)
  -> existPart_succ_n1_bypass_k0 (L2319)
  -> existPart_succ_n1_bypass (k=0 delegates; k>0 sorry at L2396)
  -> RabinovichGeneralized.lean:437 (n=1 case)
  -> kamp_mutual_induction -> kamp_prior_expressive_completeness
  -> US_expressively_complete_over_prior
  -> gap_prior_UZ_contradiction (GoodStructuresModelSurgery.lean)
  -> no_gaps_discrete_model_surgery -> completeness_discrete
```

**Branch B — Reynolds/succ_cofinal chain (task 202):**
```
chronicle_gap_contradiction (ChronicleToCountermodel.lean:537, sorry)
  -> succ_cofinal -> limitDomSubtype_isSuccArchimedean -> succ_embed_surjective
  -> cantor_bfmcs_discrete_restricted_tc + _fuc
  -> countermodel_discrete_enriched -> completeness_discrete
```

Both chains must be closed. Task 273 owns Branch A. Closing all sorries in task 273's
scope removes Branch A's contribution to `sorryAx` in `completeness_discrete`.

**Critical observation**: The k>0 sorry at L2396 in `existPart_succ_n1_bypass` is
explicitly out of scope per the task brief. This means even after closing L2081, L2151,
and L2308, the Branch A chain still has a sorry at L2396 — unless k>0 is also tackled.
The RabinovichGeneralized.lean comment (L434-465) explicitly documents that k>0 at n>=2
also has a sorry (L465). The full Kamp theorem requires BOTH the n=1 sorry chain (task 273)
AND the k>0 sorry to be closed.

### 3. Estimated Scope of Bracket Redesign

The bracket design flaw is localized to:
- `enriched_vecEA2_until` (L444-492, ~50 lines): uses BracketFormula
- `VVecEA2.translateLeft` (called from enriched_bypass_until, via VecEA2 infrastructure)
- The backward proof `backward_nf_eval_of_holdsLeft_aux` (L2078 sorry at bracket case)
- The forward proof `forward_nf_eval_of_holdsLeft` (L2151 sorry)
- `existPart_succ_n1_bypass_k0_until` (L2154-end of until section)

If the redesign replaces `BracketFormula n` with individual existentials (no bracket),
it would change:
1. `enriched_vecEA2_until` definition (replace bracket field with flat list of existentials)
2. The backward direction proof (no longer needs to handle `bracket` case)
3. The forward direction proof (extracts x from existential directly)
4. `enriched_bypass_until` (calls `enriched_vecEA2_until` — may need minor adjustment)

**The eq case (L1383) is sorry-free and does NOT use VecEA2 brackets.** It uses
`enriched_bypass_eq` which is a simple direct construction. The redesign does not
touch the eq case at all — zero blast radius there.

**The Since case** uses `enriched_bypass_since` which does NOT use VecEA2 either.
The redesign does not touch the Since case.

**Blast radius**: Approximately 200-400 lines of Until-specific code (the VecEA2
infrastructure, backward proof, forward proof). The eq case (sorry-free), the Since
case, and all code above L434 are unaffected.

### 4. Adjacency to Task 202 (Reynolds bypass)

The ROADMAP explicitly states two independent sorry chains must close. Task 202 addresses
Branch B (Reynolds bypass via k-equivalence). The Kamp work (task 273) addresses Branch A.
They are independent in the sense that completing one does not complete the other — both
must be done. However, closing Branch A (`US_expressively_complete_over_prior`) is the
dependency for `gap_prior_UZ_contradiction` which itself feeds `no_gaps_discrete_model_surgery`
which is an ingredient in `completeness_discrete` via the Reynolds pipeline. The ROADMAP
entry for task 202 indicates it "uses `US_expressively_complete_over_prior`" so task 273
is actually a prerequisite for task 202 to land cleanly.

### 5. Recommended 3-Phase Sequencing Assessment

The proposed 3-phase sequence (Phase A: Since case; Phase B: bracket redesign; Phase C:
backward proof + remaining sorries) is optimal. Reasoning:

- Phase A is genuinely independent (different code path). It provides a sorry count
  reduction from 4 to 3 (L2308 closed) with no risk of breaking eq case or any
  working code.
- Phase B (bracket redesign) scoped tightly to `enriched_vecEA2_until` and associated
  VecEA2 helpers. Does not touch Phase A's work or the eq case.
- Phase C closes the backward and forward direction proofs which depend on the
  redesigned bracket (or its replacement).
- Alternative ordering (Phase B first, then Phase A) would also work but gains nothing:
  the Since case is independent either way.

---

## Recommended Approach

**Immediate action (Phase A)**: Prove `existPart_succ_n1_bypass_k0_since` at L2285-2308.

The proof structure mirrors `existPart_succ_n1_bypass_k0_eq`. The Since case needs
to show that `enriched_bypass_since` semantically characterizes the existential
`∃ x, nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf` when `x < t`.

Recommended proof strategy:
1. Unfold `enriched_bypass_since` — it's `formula_disjList` over compatible `nf_x`
2. Backward direction: if the formula holds at t, extract the Since witness and
   reconstruct the NF evaluation
3. Forward direction: given `∃ x < t`, find the matching `nf_x`, show the Since
   formula holds at t

The main lemma needed is a `since_temporal_iff` analogous to what exists for the
Until direction. Check whether an `above_x_temporal_iff` mirror (a `below_x_temporal_iff`
or `above_t_temporal_iff`) exists or needs to be created.

**Secondary action (Phase B)**: Replace `BracketFormula n` with individual existentials
in `enriched_vecEA2_until`. The key insight is that the between_tx witnesses can each
be expressed as `∃ z, t < z < x ∧ P(z)` without requiring them to be ordered relative
to each other. This removes the need for the `BracketFormula n` type with its indexed
point/segment types, replacing it with a flat conjunction or disjunction of Since/Until
formulas centered at x.

---

## Evidence/Examples

**Evidence that Since is independent** (code path analysis):

`enriched_bypass_since` at L524 uses `formula_disjList` — a plain disjunction,
not `VVecEA2.translateLeft`. The bracket is only in `VVecEA2.translateLeft` which is
called only at L511 (enriched_bypass_until). Since never touches L444-492.

**Evidence of blast radius containment** (eq case is sorry-free):

`existPart_succ_n1_bypass_k0_eq` at L1383 is sorry-free. It uses `enriched_bypass_eq`
(L597+) which has a completely separate code path using `nf_2var_exist_formula_prior_neg`
(not VecEA2). The redesign cannot affect this.

**Sorry count impact of completing Phase A only**: KampBypass.lean drops from 4 sorry
sites to 3 (L2081, L2151, L2308 -> L2081, L2151 remain; L2396 is k>0 out-of-scope).
The chain through `existPart_succ_n1_bypass_k0_since` -> `existPart_succ_n1_bypass_k0`
(L2358-2361) -> upstream would still be blocked by the Until sorries at L2081/L2151.

**Sorry count impact of completing all three in-scope sorries**: All three L2081,
L2151, L2308 closed -> `existPart_succ_n1_bypass_k0` becomes sorry-free -> feeds into
`existPart_succ_n1_bypass` (which STILL has L2396 sorry for k>0). So even after all
three in-scope sorries close, the Kamp chain is blocked at L2396 unless k>0 is also
addressed.

**This is a critical scoping finding**: The task brief marks L2396 (k>0) as "out of
scope," but L2396 is on the critical path to `kamp_prior_expressive_completeness` ->
`US_expressively_complete_over_prior`. Closing L2081+L2151+L2308 makes
`existPart_succ_n1_bypass_k0` sorry-free (the k=0 bypass), but
`existPart_succ_n1_bypass` still has a sorry at the k>0 case, meaning the whole Kamp
chain still has sorryAx until k>0 is handled.

---

## Confidence Level

**High confidence** (direct code analysis, no speculation):
- Since case is independent of bracket design: HIGH
- Blast radius limited to ~200-400 lines of Until-specific code: HIGH
- Eq case unaffected by any bracket redesign: HIGH
- Phase A/B/C sequencing is sound and optimal: HIGH

**Medium confidence** (based on code structure without running the proof):
- Phase A (Since case) proof is feasible without new helper lemmas: MEDIUM
  (depends on whether `below_x_temporal_iff` or similar exists)
- The Since proof can reuse patterns from the eq case proof: MEDIUM

**Lower confidence**:
- Exact line count impact of bracket redesign: LOW (depends on approach chosen)
- Whether the bracket replacement produces clean Lean 4 proofs: MEDIUM

---

## Risk Assessment

### Risk 1: Phase A may require new temporal helper lemmas (MEDIUM)
The Since case needs to show that `Since(char_x, guard)` at t correctly captures
witnesses below t. If no `below_x_temporal_iff` lemma exists, it needs to be proved.
Mitigation: Check existing lemmas in the Until proof for mirror patterns.

### Risk 2: k>0 scope creep (HIGH PRIORITY — NOT a risk but a blocker)
Even after completing all three in-scope sorries (L2081, L2151, L2308), the Kamp
chain has a sorry at `existPart_succ_n1_bypass` L2396 (k>0). This means Branch A
of the `completeness_discrete` sorry chain CANNOT be fully closed within the current
task scope without addressing k>0. This should be explicitly flagged to the user as
a scoping decision: either expand task 273 to include k>0, or plan a task 273b.

### Risk 3: Bracket redesign ripple to VVecEA2 (LOW)
`enriched_bypass_until` calls `enriched_vecEA2_until` and then `vvec.translateLeft`.
If the redesign changes the return type (e.g., from `Σ n, VecEA2 n` to a plain
`Formula`), the `VVecEA2` wrapper and `translateLeft` may need to change too. This is
contained within the Until code path. Mitigation: If the redesign returns `Formula`
directly, `enriched_bypass_until` can call it directly without the VVecEA2 wrapper.

### Risk 4: Forward direction proof (L2151) depends on bracket structure (MEDIUM)
The forward proof at L2151 is blocked because extracting x from `holdsLeft` requires
knowing the VecEA2/bracket structure. Any redesign must still provide the same
extraction mechanism. The redesigned formula must make x extractable from the temporal
truth evaluation. If the redesign uses individual `Since(char_x, guard)` formulas,
the witness x is extracted from the Since truth definition directly.

### Risk 5: No blast radius to currently-passing code (CONFIRMED LOW)
The eq case is sorry-free and uses completely separate definitions. The Since case
also uses different definitions. No currently-passing theorem is at risk from the
bracket redesign.

---

## Summary Recommendation

1. **Close the Since case (L2308) first** — it is independent, lower risk, and provides
   an immediate sorry count reduction. This is a quick win.

2. **Flag the k>0 scoping issue** to the user: the three in-scope sorries (L2081, L2151,
   L2308) feed into `existPart_succ_n1_bypass_k0` (sorry-free after closure), but
   `existPart_succ_n1_bypass` still has a sorry at L2396 (k>0 case). Branch A of
   `completeness_discrete` remains blocked until k>0 is handled. A task 273b or scope
   expansion decision is needed.

3. **Proceed with bracket redesign** for Phase B: replace `BracketFormula n` with
   individual existentials in `enriched_vecEA2_until`. Scope is ~200-400 lines.
   Zero blast radius to eq case or Since case.

4. **Both independent sorry chains** (Branch A: Kamp/task 273; Branch B: Reynolds/task 202)
   must be closed to achieve sorry-free `completeness_discrete`. They are truly independent;
   task 273 is a prerequisite for task 202 to land cleanly (task 202 uses
   `US_expressively_complete_over_prior` which task 273 supplies).
