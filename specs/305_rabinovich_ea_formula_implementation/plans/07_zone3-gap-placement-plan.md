# Implementation Plan: Zone-3 Gap-Placement Resolution (Rabinovich Lemma 5.1 Quantifier Step)

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Phases 1-5 [COMPLETED] (EANegationClosure.lean sorry-free, ~570 lines)
- **Research Inputs**:
  - specs/305_rabinovich_ea_formula_implementation/reports/06_zone3-gap-placement.md
  - specs/305_rabinovich_ea_formula_implementation/reports/05_vecEA2-level-lemma51.md
  - specs/305_rabinovich_ea_formula_implementation/reports/04_faithful-lemma51-design.md
  - specs/305_rabinovich_ea_formula_implementation/reports/01_ea-formula-research.md
- **Artifacts**: plans/07_zone3-gap-placement-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan resolves the zone-3 gap-placement blocker that blocked Phase 6 of the v6 plan. All 6 sorries in `PriorComposition.lean` (lines 459, 462, 554, 559, 610, 614) reduce to one fundamental sub-problem: given cross_extend witnesses from adjacent bounds (y1 > env' i_max with type psi, y2 < env' j_min with type psi), show existence of a witness in the bounded interval (env' i_max, env' j_min). Once this existence is established, `HasAttainedINF.first_occ` localizes the witness precisely. The plan decomposes this into four targeted phases, followed by an integration phase.

### Research Integration

- **Report 06** (06_zone3-gap-placement.md): H4-verified analysis of the root problem. Confirmed all 6 sorries reduce to `nvar_transfer_from_1var_agree` quantifier step (lines 459/462). Established that the proof requires combining two cross_extend witnesses from adjacent bounds with a `HasAttainedINF.first_occ` squeeze. Key finding: the disjunction "y1 < env' j_min OR y2 > env' i_max" is NOT a tautology, but on Prior structures with the tight adjacency constraint (no env' component between env' i_max and env' j_min), existence in the interval follows from combining the two cross_extend witnesses. Estimated 380-620 lines total.
- **Report 05** (05_vecEA2-level-lemma51.md): Established VecEA2-level negation closure sorry-free (Phases 4-5 work).
- **Report 04** (04_faithful-lemma51-design.md): Root cause analysis of beta_0(r_0) blocker.

### Prior Plan Reference

Plan v6 (06_vecEA2-negation-plan.md) completed Phases 1-5 (EANegationClosure.lean sorry-free). Phase 6 was blocked because the ExistPart rewire approach reduces to the same zone-3 gap-placement problem. This plan replaces Phase 6 with a decomposed approach targeting `PriorComposition.lean` sorries directly, then Phase 7 rewires KampBypass.

## Goals & Non-Goals

**Goals**:
- Prove `prior_bounded_type_realization`: on Prior structures, cross_extend witnesses from adjacent bounds guarantee existence in the bounded interval
- Implement gap-classification helper to extract adjacent bounds (i_max, j_min) from finite env tuples
- Complete `nvar_transfer_from_1var_agree` quantifier step (lines 459/462) sorry-free
- Fill downstream consumers `prior_nonconstenv_2var_agree_until/since` (lines 554/559/610/614) sorry-free
- Rewire `KampBypass.lean` to use the sorry-free path, eliminating all critical-path sorrys
- Achieve `lake build` clean on the Kamp module

**Non-Goals**:
- Model-independent biconditional for `neg_bracket_is_vbracket` (future work)
- Removing dead-code sorrys in NfCharFormula.lean (deprecated)
- Optimizing proof terms (correctness first)
- Changes to EANegationClosure.lean (already sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `prior_bounded_type_realization` proof is more complex than estimated (requires mutual induction) | H | M | Research report provides two fallback paths: (a) use quantifier condition encoding directly, (b) restructure as mutual induction on (d, r). Budget 50% extra for Phase 6a. |
| Gap classification Fin arithmetic (finding i_max, j_min in finite env) is tedious | L | H | Use `Finset.max'` / `Finset.min'` on filtered index sets. Well-understood pattern from Phase 4 Boneyard port. |
| Downstream consumers (lines 554/559/610/614) need depth monotonicity beyond what's directly available | M | M | Research confirmed K+1 <= K_dagger+1 from strong induction bound. `nf_agreement_monotone` handles weakening. |
| `nvar_transfer_from_1var_agree` IH shape doesn't match available hypotheses at extended arity | M | L | IH is at depth d (one lower), arity r+1. The gap-placement lemma provides the extended witness at depth d with correct order, enabling direct IH application. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 6a, 6b | -- (completed phases 1-5 prerequisite) |
| 2 | 6c | 6a, 6b |
| 3 | 6d | 6c |
| 4 | 7 | 6d |

Phases within the same wave can execute in parallel.

---

### Phase 1: Interval Splitting Infrastructure [COMPLETED]

**Goal**: Define `BracketFormula.splitAt` and prove semantic correctness.
**Completed**: 2026-06-15

---

### Phase 2: Lemma 5.3 -- All-Betas-True Base Case [COMPLETED]

**Goal**: Prove `neg_orderedPointsExist_is_vbracket` sorry-free.
**Completed**: 2026-06-16

---

### Phase 3: Corollary 5.4 -- Partial Bracket Negation [COMPLETED]

**Goal**: Prove `neg_partialBracketExist_sufficient` sorry-free.
**Completed**: 2026-06-17

---

### Phase 4: Boneyard Port -- EANegationClosure.lean [COMPLETED]

**Goal**: Port helper definitions, bracket_tail_satisfiable, neg_interval_formula, neg_bounded_exists from Boneyard. All sorry-free.
**Completed**: 2026-06-18

---

### Phase 5: Proposition 4.2 -- VecEA2 Negation Closure [COMPLETED]

**Goal**: Port neg_vecEA2, neg_2var_vec_ea from Boneyard. All sorry-free.
**Completed**: 2026-06-19

---

### Phase 6a: Bounded Type Realization Helper [BLOCKED]

**BLOCKER** (Phase 6a):
- **What failed**: The gap-placement problem cannot be solved within the current proof architecture. The theorem `nvar_transfer_from_1var_agree` requires finding a witness x' in N with the same order relative to ALL env' components as x has relative to env components. `cross_extend_bwd_1var` gives witnesses with correct order relative to ONE env component, but different choices give different witnesses with potentially incompatible positions.
- **What was tried**: (1) Direct case-split on y_lo < env' j_min vs y_hi > env' i_max vs both-outside. The "both outside" case is not contradictable with available tools. (2) Using `exist_transfer_from_full_agree` from individual h_1var agreements. This gives depth-K existential transfer at arity 2 from env i, not multi-arity. (3) Using the IH at depth d with extended environments -- this requires order matching, which IS the problem. (4) Using Prior-UZ/SZ `HasAttainedINF.first_occ` -- this requires existence in the bounded interval as precondition, which cannot be established from cross_extend witnesses alone.
- **Why stuck**: Fundamental architectural mismatch. The proof needs multi-arity transfer (depth-d, arity r+1) but the available infrastructure (`cross_extend_bwd_1var`, `exist_transfer_from_full_agree`) only provides arity-2 transfer from individual reference points. The order matching obligation for the IH creates circularity: to apply the IH at arity r+1, you need the order matching; to get the order matching, you need the IH at arity 2 (which itself needs order matching for its extension).
- **What is needed**: A proof restructuring using one of: (a) Mutual induction on (depth, arity) so that depth-d arity-(r+1) can use depth-d arity-r from a parallel IH; (b) A strengthened theorem statement that provides depth-(d+1) r-var agreement as output (enabling `exist_transfer_from_full_agree` to produce the right-depth existential transfer); (c) A bounded-interval realization lemma that encodes the gap constraint into a higher-arity NF quantifier condition and transfers it.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder.

**Goal**: Prove that on Prior structures at sufficient NF depth, when cross_extend witnesses from adjacent bounds exist (y1 > a with char_fn type, y2 < b with char_fn type, no env' component between a and b), at least one witness falls in the bounded interval (a, b), enabling `HasAttainedINF.first_occ` to find the first occurrence.

**Tasks**:
- [ ] Define `prior_bounded_type_realization` in `PriorComposition.lean` (or a new helper section):
  ```lean
  theorem prior_bounded_type_realization {sig : MonadicSignature}
      (atomMap : Formula → sig.preds)
      (N : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ N atomMap)
      (a b : N.carrier) (h_ab : a < b)
      (d : Nat) (nf_x : NormalForm sig d 1)
      (char_fn : ∀ (d' : Nat), NormalForm sig d' 1 → Formula)
      (char_correct : ∀ (d' : Nat) (_ : d' ≤ d) (nf_1 : NormalForm sig d' 1)
          (S : OrderedMonadicStructure sig) (_ : semantic_prior_UZ S atomMap)
          (_ : semantic_prior_SZ S atomMap) (t : S.carrier),
          temporal_truth S atomMap t (char_fn d' nf_1) ↔
          nf_eval_nf S d' 1 (fun _ => t) nf_1)
      (h_y1 : ∃ y1 : N.carrier, a < y1 ∧
        (∀ nf : NormalForm sig d 2,
          nf_eval_nf N d 2 (Fin.cons y1 (fun _ => a)) nf ↔ ...))
      (h_y2 : ∃ y2 : N.carrier, y2 < b ∧
        (∀ nf : NormalForm sig d 2,
          nf_eval_nf N d 2 (Fin.cons y2 (fun _ => b)) nf ↔ ...)) :
      ∃ w : N.carrier, a < w ∧ w < b ∧
        temporal_truth N atomMap w (char_fn d nf_x)
  ```
- [ ] Implement the proof via case split:
  - Case 1: y1 < b (from h_y1). Then y1 is in (a, b). Extract `temporal_truth` from 2-var agreement via `cross_1var_from_2var` and `char_correct`.
  - Case 2: y2 > a (from h_y2). Then y2 is in (a, b). Same extraction.
  - Case 3: y1 >= b AND y2 <= a. Show this is impossible: from 2-var agreement at [y2, b], the atom `y2 < b` matches some original order `x < env j_min`. Since y2 <= a < b, we have y2 < b (consistent). AND y1 >= b > a, so y1 > a (consistent). Both outside interval. For THIS case, use the quantifier condition of the depth-(d+1) 1-var agreement at a (which encodes "there exists a point in (a, ...) with type nf_x bounded by the next env component"). The encoding of "bounded" uses the NF structure at depth d+1 which includes the quantifier step that references adjacent components.
  - Alternative Case 3 handling: If the simple case split is insufficient, use `HasAttainedINF.first_occ` directly with a modified existence argument that leverages the UZ/SZ symmetry: Prior-UZ at a gives first occ > a; if it's >= b, then SZ at b gives last occ < b; if THAT is <= a, contradiction with the structure being infinite between a and b.
- [ ] Verify: proof compiles sorry-free
- [ ] Test via `lean_goal` at the sorry sites to confirm the helper's output type matches the needed hypothesis

**Timing**: 2 hours

**Depends on**: 1-5 (completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- add helper lemma (~60-100 lines)

**Key Insight from Research**: The "y1 >= b AND y2 <= a" case may actually be impossible when a and b are ADJACENT in env' (no env' component between them) because the 2-var atom agreement from cross_extend constrains y1's position relative to a and y2's position relative to b, and the adjacency constraint combined with the depth structure rules out both witnesses being outside the interval simultaneously. If this impossibility proof is too complex, the fallback uses `prior_UZ` with the SZ dual to construct a different witness entirely.

**Verification**:
- `lean_goal` confirms the helper's type signature matches the gap in `nvar_transfer_from_1var_agree`
- Helper compiles sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds with original sorrys still present (helper is additive)

---

### Phase 6b: Gap Classification Helper [NOT STARTED]

**Goal**: Implement helper to extract adjacent bounds (i_max, j_min) from a finite environment tuple, establishing that no env component lies between env i_max and env j_min in the linear order.

**Tasks**:
- [ ] Define `gap_classification` structure/helper:
  ```lean
  /-- For x in a gap of env, find the adjacent bounds. -/
  structure GapBounds {n : Nat} (env : Fin n → α) (x : α) [LinearOrder α] where
    i_max : Option (Fin n)  -- largest index below x (None if x < all)
    j_min : Option (Fin n)  -- smallest index above x (None if x > all)
    h_below : ∀ i, (i_max = some idx → env idx < x)
    h_above : ∀ j, (j_min = some idx → x < env idx)
    h_adjacent : ∀ k, (some idx_lo = i_max → some idx_hi = j_min →
      ¬(env idx_lo < env k ∧ env k < env idx_hi))
  ```
- [ ] Prove `gap_exists`: for any x not equal to any env component, with the order being strict and linear, i_max and j_min exist (handling edge cases where x is below or above all env components)
- [ ] Prove the order transfer property: from `h_order : ∀ i j, env i < env j ↔ env' i < env' j`, derive `env' i_max < env' j_min` and the adjacency property for env'
- [ ] Handle edge cases: x < all env components (j_min is the minimum), x > all env components (i_max is the maximum), x between two adjacent components

**Timing**: 1 hour

**Depends on**: 1-5 (completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- add gap classification (~60-80 lines)

**Verification**:
- Gap classification compiles sorry-free
- Edge cases (x below all, x above all) handled
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds

---

### Phase 6c: Complete `nvar_transfer_from_1var_agree` Quantifier Step [NOT STARTED]

**Goal**: Fill the sorry at lines 459 and 462 in `nvar_transfer_from_1var_agree`, using the helpers from 6a and 6b.

**Tasks**:
- [ ] Implement the forward direction (line 459):
  1. Given x in M with `nf_eval_nf M d (r+1) (Fin.cons x env) sub_nf`
  2. Classify x's gap in M: find i_max, j_min from gap_classification
  3. Apply `cross_extend_bwd_1var` from `h_1var i_max` to get y1 > env' i_max with depth-d 2-var agreement
  4. Apply `cross_extend_bwd_1var` from `h_1var j_min` to get y2 < env' j_min with depth-d 2-var agreement
  5. Apply `prior_bounded_type_realization` to get existence witness in (env' i_max, env' j_min)
  6. Apply `HasAttainedINF.first_occ` (via `prior_hasAttainedINF`) on interval (env' i_max, env' j_min) to get w' with `temporal_truth N atomMap w' (char_fn d nf_x)`
  7. From `char_correct`: w' has depth-d 1-var type nf_x, matching x
  8. From adjacency + gap position: w' has correct order relative to ALL env' components (between i_max and j_min, and no other env' component exists in between)
  9. Apply IH at depth d, arity r+1 with environments `Fin.cons x env` / `Fin.cons w' env'`
- [ ] Implement the backward direction (line 462): symmetric using `cross_extend_fwd_1var` and `semantic_prior_SZ`
- [ ] Handle edge cases: x below all env (no i_max), x above all env (no j_min), x equal to some env component
- [ ] Verify: both directions compile sorry-free
- [ ] Run `lean_goal` at the quantifier step to confirm goals are closed

**Timing**: 2 hours

**Depends on**: 6a, 6b

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- fill lines 459/462 (~120-200 lines)

**Key Type Flow**:
```
h_1var i : depth-(d+1) 1-var at env i / env' i
  -> cross_extend_bwd_1var: depth-d 2-var at [x, env i] / [y_i, env' i]
  -> cross_1var_from_2var: depth-d 1-var at x / y_i
  -> char_correct: temporal_truth N atomMap y_i (char_fn d nf_x)
prior_bounded_type_realization: ∃ w in (env' i_max, env' j_min) with char_fn d nf_x
HasAttainedINF.first_occ: first occurrence w' in (env' i_max, env' j_min)
  -> w' has correct gap position (between i_max and j_min in env')
  -> depth-d 1-var at x / w' (from char_correct + char_fn)
  -> order matching: env' i < w' for all i with env i < x (by gap + adjacency)
  -> IH at depth d, arity r+1: depth-d (r+1)-var agree
  -> extract existence from IH applied to sub_nf
```

**Verification**:
- `nvar_transfer_from_1var_agree` compiles sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds with only lines 554/559/610/614 remaining

---

### Phase 6d: Fill Downstream Consumers [NOT STARTED]

**Goal**: Fill sorries at lines 554, 559, 610, 614 in `prior_nonconstenv_2var_agree_until` and `prior_nonconstenv_2var_agree_since` by delegating to `nvar_transfer_from_1var_agree`.

**Tasks**:
- [ ] Fill line 554 (Until forward): Apply `nvar_transfer_from_1var_agree` at depth K+1, arity 3, with:
  - env = `[w, x, t]` in M, env' = `[w₂, x', t']` in N
  - 1-var agreements: h_1var_w₂ (weaken from K_dagger+1 to K+2), h_x (weaken from K_dagger+2 to K+2), h_t (weaken from K_dagger+2 to K+2)
  - Order: w₂ > t' (from hw₂ 2-var atom), w₂ vs x' (from gap placement via prior_bounded_type_realization), x' > t' (from h_order_N)
  - char_fn and char_correct: thread from parent theorem
- [ ] Fill line 559 (Until backward): Symmetric using `cross_extend_fwd_1var` witnesses
- [ ] Fill line 610 (Since forward): Same pattern as Until but with reversed order (x < t)
- [ ] Fill line 614 (Since backward): Symmetric
- [ ] Verify all four sorries are eliminated
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` -- expect sorry-free

**Timing**: 1.5 hours

**Depends on**: 6c

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- fill lines 554/559/610/614 (~160-240 lines, ~40-60 per sorry)

**Depth Arithmetic**:
- Available: h_1var_w₂ at depth K_dagger+1, h_x at depth K_dagger+2, h_t at depth K_dagger+2
- Need: depth-(K+2) 1-var agreements (for nvar_transfer at depth K+1)
- Since K < K_dagger (from strong induction): K+1 <= K_dagger, so K+2 <= K_dagger+1 <= K_dagger+2
- All weakenings valid via `nf_agreement_monotone`

**Verification**:
- `grep -n sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` returns no results
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds sorry-free

---

### Phase 7: KampBypass Rewire and Integration [NOT STARTED]

**Goal**: Rewire `existPart_succ_n1_bypass` in KampBypass.lean to use the now-sorry-free `prior_2var_transfer_until/since` from PriorComposition.lean, eliminating all critical-path sorrys. Verify full pipeline compiles.

**Tasks**:
- [ ] Verify `prior_2var_transfer_until` and `prior_2var_transfer_since` in PriorComposition.lean compile sorry-free (these delegate to `prior_nonconstenv_2var_agree_until/since`)
- [ ] In KampBypass.lean, confirm `existPart_succ_n1_bypass` already calls `prior_2var_transfer_until/since` -- if so, no rewiring needed (the sorry elimination propagates automatically)
- [ ] If KampBypass.lean has its own sorrys independent of PriorComposition, fill them using the now-available sorry-free theorems
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -- verify `completeness_discrete` sorry-free
- [ ] Run full `lake build` -- verify clean project build
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no axiom leaks
- [ ] Final sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only non-critical code (NfCharFormula.lean deprecated sorrys, optional EANegation.lean aspirational theorems)

**Timing**: 0.5 hours

**Depends on**: 6d

**Files to verify** (no modifications expected if PriorComposition propagation works):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`

**Verification**:
- `lake build` succeeds with no sorry on critical path
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior.completeness_discrete` reports no sorry axiom
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only: NfCharFormula.lean dead-code sorrys, optional EANegation.lean non-critical sorrys

## Testing & Validation

- [ ] Phase 6a: `prior_bounded_type_realization` compiles sorry-free
- [ ] Phase 6b: `gap_classification` helpers compile sorry-free
- [ ] Phase 6c: `nvar_transfer_from_1var_agree` compiles sorry-free (lines 459/462 filled)
- [ ] Phase 6d: `prior_nonconstenv_2var_agree_until/since` compile sorry-free (lines 554/559/610/614 filled)
- [ ] Phase 7: `completeness_discrete` compiles sorry-free
- [ ] Phase 7: Full `lake build` succeeds
- [ ] Phase 7: `lean_verify` confirms no axiom leaks
- [ ] Final sorry audit shows only non-critical-path sorrys

## Artifacts & Outputs

- `plans/07_zone3-gap-placement-plan.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- sorry-free (Phases 6a-6d)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- already sorry-free (Phases 4-5)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- sorry-free critical path (Phase 7)

## Sorry Elimination Roadmap

| Phase | Sorrys Before | Sorrys After | What Changes |
|-------|--------------|-------------|--------------|
| 1-5 (done) | 6 live (PriorComposition) | 6 live | Infrastructure + EANegationClosure sorry-free |
| 6a | 6 live | 6 live | Helper lemma added (additive, no sorry elimination yet) |
| 6b | 6 live | 6 live | Gap classification added (additive) |
| 6c | 6 live | 4 live | nvar_transfer lines 459/462 filled |
| 6d | 4 live | 0 live | Downstream consumers lines 554/559/610/614 filled |
| 7 | 0 live | 0 live | Integration verified, full pipeline sorry-free |

## Rollback/Contingency

- Phases 6a-6b add helper lemmas without modifying existing sorry-marked code. Rollback = delete the helpers.
- Phase 6c modifies `nvar_transfer_from_1var_agree` directly. If it fails, git revert to the sorry state (non-destructive since sorrys are the current state).
- Phase 6d modifies `prior_nonconstenv_2var_agree_until/since`. Same rollback strategy.
- Phase 7 is verification only (no modifications expected). If KampBypass needs changes and fails, revert.
- Git per-phase commits enable rollback to any intermediate state.
- If `prior_bounded_type_realization` proves intractable with the simple case-split approach, the fallback uses mutual induction on (d, r) as identified in research report 06. This would restructure the proof but not change the overall sorry count target.
