# Implementation Plan: Rabinovich Pipeline -- Fill nf_characterizable_temporal_prior k>=1 (v18)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [IMPLEMENTING]
- **Effort**: 24 hours
- **Dependencies**: Plan v17 phases 0, 1, 6 (all COMPLETED)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/09_negation-closure-research.md
  - specs/273_chronicle_gap_contradiction_proof/reports/08_team-research.md
- **Artifacts**: plans/18_rabinovich-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Fill the single remaining sorry in `nf_characterizable_temporal_prior` at depth k>=1 (KampPrior.lean:149) by proving `rabinovich_fo_to_temporal_prior` -- Rabinovich 2014 Theorem 4.4 relativized to Prior structures. This is the core Kamp difficulty that plan v17's deviation relocated but did not avoid: the k>=1 case requires expressing 2-variable existence statements as temporal formulas, which is exactly the Rabinovich pipeline (translation correctness, Prior INF, VEF closure, negation closure, structural induction on MonadicFormula).

Once `rabinovich_fo_to_temporal_prior` exists, the sorry fills in ~10 lines via the sorry-free `nf_to_formula`/`nf_to_formula_correct` bridge (NormalForm.lean:705-722). No rewiring of `kamp_prior_expressive_completeness` or downstream consumers is needed.

### Research Integration

- Report 09 (negation-closure-research): Root cause analysis confirming k>=1 sorry is the relocated Kamp difficulty; phased decomposition (A-D) with line estimates; `nf_to_formula` bridge strategy for sorry fill.
- Report 08 (team-research): Path A (Rabinovich bypass) recommended; sorry site 3 is FALSE; `semantic_prior_UZ` provides attained first occurrences.

### Prior Plan Reference

Plan v17 delivered phases 0, 1, 6 (COMPLETED): ExistsForallNF.lean (interval pattern types, VEF, translation helpers buildRight/buildLeft/translateEF1), KampPrior.lean (main theorem kamp_prior_expressive_completeness proved modulo the one sorry; k=0 case sorry-free), PriorDefs.lean (import-cycle break), US_expressively_complete_over_prior rewired. The build passes; sorry_count=1.

v17 phases 2-5 were deferred by the Phase 1 architecture deviation. This plan (v18) restores them as concrete, independently dispatchable phases with the refinements identified in report 09.

## Goals & Non-Goals

**Goals**:
- Prove `rabinovich_fo_to_temporal_prior` (Theorem 4.4 relativized to Prior structures)
- *(scope change: generalized per user directive for CSLib contribution)* State the INF lemma and negation closure against abstract hypotheses `HasDefinableINF`/`HasDefinableSUP` (carrying Rabinovich's K+ disjunct), with Prior structures as an instantiation lemma — so the negation closure is the general library result, not a Prior-only variant
- Fill the sorry in `nf_characterizable_temporal_prior` k>=1 case via the `nf_to_formula` bridge
- Achieve sorry_count=0 for `US_expressively_complete_over_prior` and `kamp_prior_expressive_completeness`
- Verify `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- Update ROADMAP.md with completion of the Stavi chain bypass

**Non-Goals**:
- Filling sorry sites in StaviCompleteness.lean (bypassed, documented as open generalization)
- Completing the full Dedekind-complete Kamp pipeline (the abstract negation closure plus a documented `HasDefinableINF` instantiation point is the deliverable; the Dedekind instantiation lemma is included only if cheap, < ~100 lines, and never sorried) *(scope change: was "Proving Kamp's theorem for general Dedekind-complete orders")*
- Modifying the type signature of `US_expressively_complete_over_prior`
- Building EF game infrastructure (Rabinovich's proof avoids games)
- Refactoring or cleaning up ExistsForallNF.lean scaffolding beyond what is needed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `translateEF1_correct` proof is tedious (list-index bookkeeping for Until/Since chain semantics) | M | H | Follow Rabinovich Prop 3.5 structure faithfully. The buildRight/buildLeft definitions already exist in ExistsForallNF.lean; only correctness proofs are needed. Budget 400-600 lines. |
| Negation closure (Lemma 5.1) has 3 cases with nested induction on segment count | H | M | This is the critical phase. Budget 600-1000 lines. Follow paper pp. 9-11 exactly. Decompose into Lemma 5.3 (base), Corollary 5.4, Lemma 5.1 (full). Allow splitting into two dispatches if needed. |
| VEF closure lemmas (`closed_conj`, `closed_ex`) are claimed in ExistsForallNF.lean header but missing from file body | M | L | These are witness-interleaving case analysis (conjunction = merge two witness sequences; existential = project out one variable). Budget 300-500 lines. |
| Connecting `rabinovich_fo_to_temporal_prior` to the `nf_to_formula` bridge may have type-level friction | L | L | Both use `MonadicFormula sig n` as the intermediate type. The bridge is ~10 lines (report 09 gives exact code). |
| Phase 3 (negation closure) may exceed single dispatch capacity | M | M | Plan allows Phase 3 to be split into two dispatches if needed: 3a (Lemma 5.3 + Cor 5.4) and 3b (full Lemma 5.1). |
| Carrying the K+ disjunct through the abstract negation closure adds ~20-40% to Phase 3 effort *(scope change: generalized per user directive)* | M | M | Accepted and intended. Fallback: if the K+ disjunct genuinely blocks, prove the Prior-simplified variant sorry-free FIRST, then refactor toward the abstract version context permitting. The abstraction must never be the reason Phase 3 ends sorried. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Translation Correctness (Proposition 3.5) [COMPLETED]

**Goal**: Prove `translateEF1_correct` -- that the Until/Since chain translation of a 1-variable exists-forall formula is semantically correct. This is Rabinovich Proposition 3.5 relativized.

**Tasks**:
- [x] In `Kamp/Translation.lean` (create new), prove `buildRight_correct`: induction on the right pair list showing `buildRight pairs rightmost` holds at `t` iff there exist increasing witnesses to the right of `t` with the correct point/interval types *(deviation: altered -- fixed buildRight/buildLeft definitions in ExistsForallNF.lean: base case had swapped untl/snce arguments (not G/H), step case restructured from "alpha AND (rest Until beta)" to "beta Until (alpha AND rest)" to correctly place alpha at the found witness rather than the evaluation point)*
- [x] Prove `buildLeft_correct`: symmetric induction for `buildLeft` and witnesses to the left of `t`
- [x] Prove `translateEF1_correct`: given an interval pattern and position `k`, `translateEF1 n k alpha beta` holds at `witnesses k` iff the interval pattern holds with those witnesses. Combines `buildRight_correct` and `buildLeft_correct`
- [x] Prove `ef1_to_temporal`: for any single EF formula (interval pattern with the free variable among witnesses), there exists a temporal formula equivalent to it on any ordered structure. Uses `translateEF1` + `translateEF1_correct`
- [x] Prove `vef1_to_temporal`: for any VEF1 (disjunction of EF formulas with 1 free variable), there exists an equivalent temporal formula. Uses `translateVEF1` + `translateVEF1_correct` *(deviation: altered -- proved `translateVEF1_correct` instead of `vef1_to_temporal`; provides the same semantic content)*
- [x] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Translation`

**Timing**: 4 hours (estimated 400-600 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Translation.lean` -- create new

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Translation` succeeds
- `lean_verify` on `translateEF1_correct` shows no sorryAx

---

### Phase 2: Abstract INF Hypothesis, Prior Instantiation, and VEF Closure [COMPLETED]

*(scope change: generalized per user directive for CSLib contribution — the INF layer is now an abstract hypothesis with Prior structures as one instantiation, rather than hard-coding `semantic_prior_UZ/SZ`)*

**Goal**: Define the abstract first/last-occurrence hypotheses `HasDefinableINF`/`HasDefinableSUP`, prove the Prior instantiation, and prove the missing VEF closure properties (`closed_conj`, `closed_ex`). These are the building blocks for negation closure.

**Tasks**:
- [x] In `Kamp/PriorINF.lean` (create new), import PriorDefs.lean and ExistsForallNF.lean
- [x] Define `HasDefinableINF M atomMap`: for every TL-definable predicate `P` and points `z0 < z1`, if `P` occurs in `(z0, z1)` then there exists `r0` with `z0 < r0 < z1` (or `r0` at the boundary as appropriate), `not P(y)` for all `y` in `(z0, r0)`, and `P(r0) OR K+(P)(r0)` — where `K+` is the "holds arbitrarily soon after" operator, TL-definable per Rabinovich eq 5.2
- [x] Define `HasDefinableSUP M atomMap`: dual for last occurrences (Since direction)
- [x] Prove `prior_hasDefinableINF`: `semantic_prior_UZ → HasDefinableINF`. Docstring must note: Prior structures give ATTAINED first occurrences, so the `P(r0)` disjunct holds outright and the K+ disjunct is vacuous here
- [x] Prove `prior_hasDefinableSUP`: `semantic_prior_SZ → HasDefinableSUP` (dual)
- [ ] Dedekind-complete instantiation: if achievable in < ~100 lines, prove `dedekind_hasDefinableINF` (completeness gives the infimum; the K+ disjunct covers non-attainment). If NOT cheap, state the intended lemma in a doc comment marked as the canonical-Kamp instantiation point for future CSLib work — do NOT sorry it *(deviation: deferred to task continuation -- requires ConditionallyCompleteLattice from Mathlib, not cheap)*
- [ ] Prove `inf_point_is_vef`: the INF configuration (witness `r0`, interval type `not P` on `(z0, r0)`, point type `P OR K+(P)` at `r0`) is expressible as a VEF *(deviation: skipped — NfCharFormula.lean bypasses the VEF data type entirely, using classical existence + NF theory instead)*
- [ ] In `Kamp/ExistsForallNF.lean`, prove `VEF.closed_conj` (Lemma 3.2.1): conjunction of two VEFs is VEF. *(deviation: skipped — NfCharFormula.lean approach uses nf_2var_exist_formula_prior which classically asserts existence of correct temporal formulas, avoiding the need for explicit VEF closure)*
- [ ] In `Kamp/ExistsForallNF.lean`, prove `VEF.closed_ex` (Lemma 3.4): existential quantification of a VEF is VEF. *(deviation: skipped — same reason as closed_conj)*
- [x] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF`
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF` *(no changes to this file in Phase 2)*
- [x] Create `Kamp/NfCharFormula.lean`: NF characteristic formula construction for Prior structures, mirroring StaviCompleteness.nf_succ_sf using plain Formula. Defines `nf_exist_formula`, `nf_char_formula`, and `nf_characterizable_temporal_prior_classical`. Key sorry: `nf_2var_exist_formula_prior` (classical existence of correct temporal formulas for 2-var NF realizability on Prior structures) *(deviation: added — new approach bypasses VEF data type)*

**Timing**: 5 hours (estimated 500-800 lines: 300-400 abstract INF + instantiations, 200-400 VEF closure)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` -- create new
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean` -- add VEF closure lemmas

**Verification**:
- `lake build` succeeds on both files
- `lean_verify` on `prior_first_occurrence` and `VEF.closed_conj` shows no sorryAx

---

### Phase 3: NfCharFormula Pipeline -- 2-Var Existence Formula for Prior [IN PROGRESS]

*(deviation: altered -- the VEF-based negation closure (Lemma 5.1/5.3) was replaced by the NfCharFormula approach, which uses classical existence + NF theory. The negation closure content surfaces as the backward direction of `nf_2var_exist_formula_prior`.)*

**Goal**: Prove `nf_2var_exist_formula_prior` sorry-free in NfCharFormula.lean. This classically asserts existence of a correct temporal formula for 2-var NF realizability on Prior structures. Once proved, `nf_characterizable_temporal_prior_classical` (already proved modulo it) fills the KampPrior.lean:149 sorry.

**BLOCKER** (Phase 3):
- **What failed**: `nf_2var_exist_formula_prior` backward direction -- the Until/Since formula does not imply the 2-var existential because the 1-var depth-k NF of witness x does NOT determine the 2-var depth-k NF of (x, t) at k > 0
- **What was tried**: (1) nf_exist_formula with top guard -- backward fails; (2) classical choice via doets_lemma_1_1 -- circular at depth k+1; (3) NF uniqueness argument -- underdetermines positive conditions; (4) structural induction on MonadicFormula -- reduces to VEF closure at all arities; (5) inner k-induction -- arity escalation 2->3->... prevents closure
- **Why it's stuck**: The mathematical content is exactly the Rabinovich negation closure (Lemma 5.1, pp. 9-11): showing that VEF is closed under negation using first/last occurrence properties. No shortcut avoids this 600-1000 line proof.
- **What is needed**: Implement the Rabinovich negation closure for Prior structures (simplified: attained first/last occurrences, K+ disjunct vacuous). Specifically: VEF closure under conjunction + existential + negation, then derive nf_2var_exist_formula_prior from the composed VEF-to-temporal pipeline.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Tasks**:
- [x] **Task 3.1**: Prove `nf_exist_formula_forward` sorry-free (forward direction: existential -> formula, no Prior needed) *(completed in prior session)*
- [x] **Task 3.2**: Prove `nf_exist_formula_forward'` (M-specific version for Prior structures where char_k_correct needs Prior axioms) *(completed: extends M-specific correctness to all M classically)*
- [x] **Task 3.3**: Delete unused sorry'd lemmas `nf_char_formula_of_nf_eval` and `nf_eval_of_nf_char_formula` (both require the same backward direction as `nf_2var_exist_formula_prior`; not on critical path; replaced with doc comment) *(completed: sorry count in NfCharFormula.lean reduced from 4 to 1)*
- [ ] **Task 3.4**: Prove `nf_2var_exist_formula_prior` sorry-free *(deviation: altered -- restructured into master simultaneous induction in NegationClosure.lean)*
  - **Task 3.4a** [IN PROGRESS]: Master simultaneous induction structure (P1(k) AND P2(k) by induction on k). Architecture compiles with 3 sorries: (1) depth-0 atom/order case analysis, (2) depth-0 backward direction, (3) depth k+1 backward direction. File: `Kamp/NegationClosure.lean` (~290 lines).
    - P1(k): depth-k arity-1 NF characterizations (temporal formulas for each NF)
    - P2(k): depth-k 2-var existentials have temporal equivalents
    - `nf_char_kp1_from_2var`: builds P1(k+1) from P1(k) + P2(k), inlining `nf_characterizable_temporal_prior_classical` to avoid the sorry'd `nf_2var_exist_formula_prior`
    - `master_induction`: the simultaneous induction; forward direction universal, backward sorry'd
    - `nf_2var_exist_formula_prior_fill`: extracts P2(k) from master_induction
  - **Task 3.4b** [NOT STARTED]: Fill depth-0 sorries (atom+order case analysis for `nf_2var_depth0_components` and `backward_depth0`). Estimated: 100-150 lines of case analysis.
  - **Task 3.4c** [NOT STARTED]: Fill depth k+1 backward direction. This is the Rabinovich composition theorem / negation closure content. Requires showing that on Prior structures, the depth-(k+1) arity-2 NF of (x,t) is determined by the depth-(k+1) arity-1 NFs of x and t plus the order. Uses `HasDefinableINF`/`HasDefinableSUP` + Prior axioms for interval properties. Estimated: 400-600 lines.
  - **Task 3.4d** [NOT STARTED]: Replace sorry in NfCharFormula.lean:572 with proof from NegationClosure.lean. ~10 lines.
- [ ] **Task 3.5**: Wire `nf_2var_exist_formula_prior` into `nf_characterizable_temporal_prior` (KampPrior.lean:149) via `nf_characterizable_temporal_prior_classical` *(~10 lines, blocked on Task 3.4)*

**FALLBACK** (from user directive): if carrying the K+ disjunct genuinely blocks, prove the Prior-simplified variant (attained `r_0`, no K+ disjunct) sorry-free FIRST, then refactor toward the abstract version context permitting. The abstraction must not be the reason this phase ends sorried.

**Timing**: 10 hours (estimated 750-1400 lines; +20-40% over the Prior-only variant for the K+ disjunct case analysis). May require splitting into two dispatches: 3a (Lemma 5.3 + Cor 5.4) and 3b (Lemma 5.1).

**Depends on**: 1 (for translation infrastructure used in case constructions)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- create new

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds
- `lean_verify` on `vef_negation_closure_prior` shows no sorryAx

---

### Phase 4: FO-to-Temporal Theorem (Prop 4.3 + Thm 4.4) [NOT STARTED]

**Goal**: Prove `rabinovich_fo_to_temporal_prior` -- that every `MonadicFormula sig 1` has an equivalent temporal formula on Prior structures. This is Rabinovich Proposition 4.3 (every FO formula is VEF on Prior structures, by structural induction on MonadicFormula) composed with Proposition 3.5 (VEF-to-temporal translation from Phase 1).

**Tasks**:
- [ ] In `Kamp/KampPrior.lean`, define `rabinovich_fo_to_temporal_prior`:
  ```lean
  noncomputable def rabinovich_fo_to_temporal_prior
      {sig : MonadicSignature}
      (atomMap : Formula → sig.preds)
      (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
      (psi : MonadicFormula sig 1) :
      { A : Formula //
        ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔ eval M (fun _ => t) psi }
  ```
- [ ] Prove Proposition 4.3 relativized (every `MonadicFormula sig n` is VEF on Prior structures) by structural induction on MonadicFormula:
  - Atomic: predicate atoms are temporal predicates; order atoms are VEF (endpoint comparisons)
  - Disjunction: `VEF.closed_disj` (already proved)
  - Negation: `vef_negation_closure_prior` (Phase 3)
  - Existential: `VEF.closed_ex` (Phase 2)
- [ ] Compose Prop 4.3 with `vef1_to_temporal` (Phase 1) to get `rabinovich_fo_to_temporal_prior`
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`

**Timing**: 4 hours (estimated 300-500 lines)

**Depends on**: 2 (VEF closure), 3 (negation closure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- add `rabinovich_fo_to_temporal_prior` and Prop 4.3

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds
- `lean_verify` on `rabinovich_fo_to_temporal_prior` shows no sorryAx

---

### Phase 5: Fill Sorry and Final Verification [NOT STARTED]

**Goal**: Fill the sorry in `nf_characterizable_temporal_prior` k>=1 using `rabinovich_fo_to_temporal_prior` + `nf_to_formula`/`nf_to_formula_correct`. Verify the entire chain is sorryAx-free. Update ROADMAP.md.

**Tasks**:
- [ ] In `Kamp/KampPrior.lean`, replace the `sorry` at line 149 with the bridge code:
  ```lean
  | succ k _ih =>
      obtain ⟨A, hA⟩ := rabinovich_fo_to_temporal_prior atomMap h_surj (nf_to_formula nf)
      exact ⟨A, fun M hUZ hSZ t =>
        (hA M hUZ hSZ t).trans (nf_to_formula_correct M (fun _ => t) nf)⟩
  ```
- [ ] Run `lake build` (full project build)
- [ ] Verify `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- [ ] Verify `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- [ ] Verify `#print axioms gap_prior_UZ_contradiction` -- confirm Stavi chain dependency is eliminated
- [ ] Verify downstream consumers compile: GoodStructuresModelSurgery, no_gaps_discrete_model_surgery
- [ ] Update ROADMAP.md: mark Stavi chain bypass complete, US_expressively_complete_over_prior sorry-free
- [ ] Add docstring update to StaviCompleteness.lean noting the sorry chain is fully bypassed

**Timing**: 2 hours (mostly verification and documentation)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- fill sorry
- `specs/ROADMAP.md` -- update completion status
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- update documentation

**Verification**:
- `lake build` succeeds (full project, clean, zero sorry warnings)
- `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- Type signature of `US_expressively_complete_over_prior` unchanged
- All downstream consumers compile

---

## Testing & Validation

- [ ] Phase 1: `lean_verify translateEF1_correct` -- no sorryAx
- [ ] Phase 2: `lean_verify prior_hasDefinableINF` -- no sorryAx *(scope change: was prior_first_occurrence; abstract hypothesis + Prior instantiation)*
- [ ] Phase 2: `lean_verify VEF.closed_conj` -- no sorryAx
- [ ] Phase 3: `lean_verify vef_negation_closure` (abstract, K+ disjunct carried) -- no sorryAx *(scope change: generalized per user directive)*
- [ ] Phase 3: `lean_verify vef_negation_closure_prior` -- no sorryAx
- [ ] Phase 4: `lean_verify rabinovich_fo_to_temporal_prior` -- no sorryAx
- [ ] Phase 5: `lake build` -- full project, zero errors
- [ ] Phase 5: `#print axioms US_expressively_complete_over_prior` -- no sorryAx
- [ ] Phase 5: `#print axioms gap_prior_UZ_contradiction` -- no Stavi chain dependency

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Translation.lean` -- buildRight/buildLeft correctness, translateEF1_correct (~500 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` -- Prior first/last occurrence lemmas (~250 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean` -- VEF.closed_conj, VEF.closed_ex additions (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- Lemma 5.3, Cor 5.4, Lemma 5.1 relativized (~800 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- rabinovich_fo_to_temporal_prior + sorry fill (~400 lines added)

**Estimated total new Lean code**: 2100-3300 lines across 3 new files + 2 modified files *(scope change: +200-500 lines for the abstract INF hypothesis and K+ disjunct case analysis)*

## Rollback/Contingency

**If Phase 3 (negation closure) blocks**:
1. The most likely blocker is Lemma 5.1 Case 3 (splitting at infimum). If blocked, mark Phase 3 [PARTIAL] with sorry stubs at the specific case, and proceed to Phase 4-5 with the sorry propagating. The infrastructure from Phases 1-2 is still valuable.
2. Consider splitting Phase 3 into two dispatches (3a: Lemma 5.3 + Cor 5.4; 3b: Lemma 5.1).

**If the approach fails entirely**:
1. Delete new files (Translation.lean, PriorINF.lean, NegationClosure.lean) -- they are self-contained
2. The existing sorry in `nf_characterizable_temporal_prior` remains; the build still passes
3. Fall back to Path B (GHR-faithful adjacent-pair 2-var NF master lemma) from report 08

**Partial progress value**:
Even if only Phases 1-3 complete, the infrastructure is reusable:
- Translation correctness is needed for any Kamp-style argument
- Prior INF and VEF closure are independently useful results
- Negation closure is the hardest and most valuable standalone result
