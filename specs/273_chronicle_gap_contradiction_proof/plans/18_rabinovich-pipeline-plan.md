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

### Phase 2: Abstract INF Hypothesis, Prior Instantiation, and VEF Closure [NOT STARTED]

*(scope change: generalized per user directive for CSLib contribution — the INF layer is now an abstract hypothesis with Prior structures as one instantiation, rather than hard-coding `semantic_prior_UZ/SZ`)*

**Goal**: Define the abstract first/last-occurrence hypotheses `HasDefinableINF`/`HasDefinableSUP`, prove the Prior instantiation, and prove the missing VEF closure properties (`closed_conj`, `closed_ex`). These are the building blocks for negation closure.

**Tasks**:
- [ ] In `Kamp/PriorINF.lean` (create new), import PriorDefs.lean and ExistsForallNF.lean
- [ ] Define `HasDefinableINF M atomMap`: for every TL-definable predicate `P` and points `z0 < z1`, if `P` occurs in `(z0, z1)` then there exists `r0` with `z0 < r0 < z1` (or `r0` at the boundary as appropriate), `not P(y)` for all `y` in `(z0, r0)`, and `P(r0) OR K+(P)(r0)` — where `K+` is the "holds arbitrarily soon after" operator, TL-definable per Rabinovich eq 5.2
- [ ] Define `HasDefinableSUP M atomMap`: dual for last occurrences (Since direction)
- [ ] Prove `prior_hasDefinableINF`: `semantic_prior_UZ → HasDefinableINF`. Docstring must note: Prior structures give ATTAINED first occurrences, so the `P(r0)` disjunct holds outright and the K+ disjunct is vacuous here
- [ ] Prove `prior_hasDefinableSUP`: `semantic_prior_SZ → HasDefinableSUP` (dual)
- [ ] Dedekind-complete instantiation: if achievable in < ~100 lines, prove `dedekind_hasDefinableINF` (completeness gives the infimum; the K+ disjunct covers non-attainment). If NOT cheap, state the intended lemma in a doc comment marked as the canonical-Kamp instantiation point for future CSLib work — do NOT sorry it
- [ ] Prove `inf_point_is_vef`: the INF configuration (witness `r0`, interval type `not P` on `(z0, r0)`, point type `P OR K+(P)` at `r0`) is expressible as a VEF
- [ ] In `Kamp/ExistsForallNF.lean`, prove `VEF.closed_conj` (Lemma 3.2.1): conjunction of two VEFs is VEF. The witnesses of the conjunction are the merged (interleaved) witness sequences from both VEFs. Uses `List.merge` on ordered witnesses
- [ ] In `Kamp/ExistsForallNF.lean`, prove `VEF.closed_ex` (Lemma 3.4): existential quantification of a VEF is VEF. The existentially quantified variable becomes an additional witness point
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF`
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF`

**Timing**: 5 hours (estimated 500-800 lines: 300-400 abstract INF + instantiations, 200-400 VEF closure)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` -- create new
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean` -- add VEF closure lemmas

**Verification**:
- `lake build` succeeds on both files
- `lean_verify` on `prior_first_occurrence` and `VEF.closed_conj` shows no sorryAx

---

### Phase 3: Negation Closure from Abstract INF Hypothesis [NOT STARTED]

*(scope change: generalized per user directive for CSLib contribution — proved from `HasDefinableINF`/`HasDefinableSUP` carrying the K+ disjunct, i.e., Rabinovich's actual general proof; the Prior version follows by instantiation)*

**Goal**: Prove that the negation of a VEF formula is VEF on any structure satisfying `HasDefinableINF`/`HasDefinableSUP`. This is Rabinovich Proposition 4.2 in its general form, via Lemma 5.3, Corollary 5.4, and Lemma 5.1 (the core of the proof). This is the critical phase.

**Tasks**:
- [ ] Create `Kamp/NegationClosure.lean`, import PriorINF.lean, ExistsForallNF.lean, Translation.lean
- [ ] Prove Lemma 5.3 (base case, all beta_i = True) from `HasDefinableINF`:
  - `not (exists x_1 ... x_n in (z_0, z_1) with P_i(x_i))` is VEF given `HasDefinableINF`
  - By induction on n (number of predicates):
    - Base (n=0): trivial (no witnesses to negate)
    - Base (n=1): `not (exists x_1)_{>z_0}^{<z_1} P_1(x_1)` = `(forall y)_{>z_0}^{<z_1} not P_1(y)` -- already VEF (0-witness pattern)
    - Step: if `P_1` occurs in `(z_0, z_1)`, use `HasDefinableINF` to find `r_0`. CARRY BOTH DISJUNCTS: sub-case `P_1(r_0)` (attained) and sub-case `K+(P_1)(r_0)` (non-attained infimum). Reduce to negation with fewer predicates (IH)
- [ ] Prove Corollary 5.4 in abstract form: `not (exists z)_{>z_0}^{<z_1} [alpha_0, ..., alpha_n](z_0, z)` is VEF given `HasDefinableINF`
  - Define `F_n := alpha_n`, `F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)`
  - Apply Lemma 5.3 to the negation
- [ ] Prove Lemma 5.1 (full negation closure) in abstract form:
  - `not [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1)` is VEF given `HasDefinableINF`/`HasDefinableSUP`
  - By induction on n (number of interval segments):
    - 3 cases per Rabinovich pp. 9-11:
      - Case 1: endpoint failure (`not alpha_0(z_0)` or `K+(not beta_1)(z_0)`)
      - Case 2: guard succeeds but no witness (`alpha_0(z_0)` and `beta_1` holds throughout)
      - Case 3: splitting at a definable infimum point, using the abstract INF hypothesis (both disjuncts)
    - For each case, construct VEF formulas using the A_i^-, A_i^+ decomposition
    - The IH gives VEF for negations of shorter formulas
- [ ] Prove `vef_negation_closure`: the main abstract negation closure theorem (hypotheses: `HasDefinableINF`, `HasDefinableSUP`)
- [ ] Prove `vef_negation_closure_prior`: Prior corollary via `prior_hasDefinableINF`/`prior_hasDefinableSUP` -- this is what Phase 4 consumes; downstream wiring unchanged
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure`

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
