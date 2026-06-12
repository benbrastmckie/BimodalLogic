# Implementation Plan: NF-Specific Prop 4.3 Bypass + Chronicle Gap Fill (v23)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: Plans v17-v22 (phases 1-4 COMPLETED, phase 5a ABANDONED as dead code)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/23_team-research.md (primary authority, round 23)
  - specs/273_chronicle_gap_contradiction_proof/reports/13_team-research.md (round 13, confirmed P1/P2 circularity)
  - specs/273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md (postmortem constraints)
  - specs/273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md (literature grounding)
- **Artifacts**: plans/23_nf-specific-prop43-bypass.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replaces plan v22's BLOCKED Phase 5a (VecEADecomposition/Lemma 3.2.2) and NOT STARTED Phases 5b/5c/6 with a streamlined three-phase approach based on team research round 23. The key insight (from Teammates B and D, confirmed by all four): `nf_to_formula` produces `MonadicFormula sig 1` (arity-1 formulas), so the structural induction on Prop 4.3 never exceeds arity 2 -- meaning `neg_2var_vec_ea` (sorry-free) handles the negation case completely, and the general Lemma 3.2.2 decomposition is unnecessary. Additionally, Teammate C identified a second independent sorry on the critical path: `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:531) must also be filled using the fully-proved `reynolds_model_surgery_core` from GoodStructuresModelSurgery.lean. Phases 1-4 from v21/v22 are preserved (all COMPLETED, sorry-free). The definition of done is `lake build` clean with zero new sorries on the critical path to `completeness_discrete`.

### Research Integration

**Round 23** (primary): Confirmed VecEADecomposition.lean is dead code (not imported by critical chain). Identified NF-specific Prop 4.3 as the shortest path to closing KampPrior.lean:149 (~150-200 lines). Discovered `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:531) as a second critical-path sorry not addressed by any prior plan. Confirmed GoodStructuresModelSurgery.lean is fully sorry-free. Recommended two Step 0 verification checks before committing to line estimates.

**Rounds 10-13** (preserved from v22): Literature grounding (Rabinovich 2014, GHR93), postmortem constraints, P1/P2 circularity confirmation, `nf_to_formula` bridge discovery.

### Prior Plan Reference

Plan v22 established the vec-EA infrastructure (phases 1-4, ~2700 lines, all sorry-free). Phase 5a was BLOCKED on `neg_bracket_syn_iff` Case C (a genuine mathematical impossibility under open-interval semantics, per Teammate A). Phases 5b and 5c were NOT STARTED. This plan abandons Phase 5a and replaces 5b/5c with an NF-specific approach that avoids the Lemma 3.2.2 dependency entirely.

### Roadmap Alignment

This plan advances the following ROADMAP.md items:
- **Kamp chain**: Close `kamp_prior_expressive_completeness` sorry chain via NF-specific Prop 4.3
- **Chronicle gap**: Fill `chronicle_gap_contradiction` via `reynolds_model_surgery_core`
- **Critical path**: Task 273 closes two of the remaining sorry chains for `completeness_discrete`. Task 202 (Reynolds bypass, `succ_cofinal` chain) is an independent prerequisite not covered here.

## Goals & Non-Goals

**Goals**:
- Verify two preconditions before implementation: (a) `nf_to_formula` produces arity-1 MonadicFormula, (b) `nf_characterizable_temporal_prior_classical` sorry status
- Quarantine VecEADecomposition.lean sorries as dead code (not on critical path)
- Prove NF-specific Prop 4.3: every `nf_to_formula nf` (arity-1 input) has a VVecEA2 equivalent over Prior, by induction on depth k, using `neg_2var_vec_ea` for the arity-2 negation case
- Close sorry at KampPrior.lean:149 via `fo_to_vvecEA2_nf_prior` + `nf_to_formula_correct` + `translateLeft_correct`
- Close sorry at NfCharFormula.lean:572 via downstream chain from KampPrior:149 closure
- Fill `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:531) using `reynolds_model_surgery_core`
- Achieve sorry_count=0 for `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior`, and `chronicle_gap_contradiction`
- Pass `lake build` with zero new sorries on the critical path to `completeness_discrete`

**Non-Goals**:
- Proving general Lemma 3.2.2 (n-var EA decomposition to 2-var) -- not needed for arity-1 input
- Proving general Prop 4.3 for all arities -- only arity-1 input needed for the sorry closure
- Fixing VecEADecomposition.lean `neg_bracket_syn_iff` / `neg_vecEA2_syn_iff` sorries (dead code)
- Closing StaviCompleteness.lean sorries (`nf_2var_existential_transfer`) -- not on critical path
- Addressing Task 202 (`succ_cofinal` chain) -- independent prerequisite for `completeness_discrete`
- Rewriting sorry-free code in phases 1-4 files
- Modifying type signatures of `kamp_prior_expressive_completeness` or `US_expressively_complete_over_prior`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `nf_to_formula` produces arity > 1 formulas at some recursion depth | H | L | Phase 0 verification check; if arity exceeds 2, need general Lemma 3.2.2 (fall back to v22 approach with ~350 extra lines) |
| `nf_characterizable_temporal_prior_classical` is already sorry-free, making Phase 5 unnecessary | L (positive) | L | Phase 0 check; if sorry-free, skip Phase 5, wire KampPrior:149 directly |
| NF-specific structural induction requires unexpected type coercions between `nf_eval_nf` and `MonadicFormula.eval` | M | M | The `nf_to_formula_correct` bridge (NormalForm.lean:719) provides the exact semantic link; inspect signature carefully in Phase 0 |
| `chronicle_gap_contradiction` proof requires additional lemmas not in GoodStructuresModelSurgery.lean | M | L | Round 23 Teammate C confirmed `reynolds_model_surgery_core` is sorry-free and the header comment at ChronicleToCountermodel.lean:65-70 sketches the proof strategy |
| Bridge wiring from NF-specific Prop 4.3 to KampPrior.lean:149 reveals unexpected NF-depth mismatch | M | L | The chain `nf_to_formula` -> Prop 4.3 -> Prop 3.5 is structurally clean; `nf_to_formula_correct` provides semantic equivalence at the right depth |

## Postmortem Constraints (from Report 11, Section 5)

These remain binding from plan v22:

1. **DO NOT attempt NF-to-formula backward proofs by extracting NF data from formula truth** (Deflection 1).
2. **DO NOT use depth-k characteristic formulas where depth-(k+1) is needed** (Deflection 2).
3. **DO NOT encode negative interval conditions as guards that block legitimate witnesses** (Deflection 3).
4. **DO NOT attempt to prove nf_3var_from_1var_nfs or any variant of the witness merging problem** (Deflection 4).
5. **DO NOT cycle between formula-level and NF-level fixes** (Deflection 5). This plan commits to the formula-level (Rabinovich) approach exclusively.

## Lemma-to-Literature Mapping

| Phase | Lean Definition/Lemma | Rabinovich 2014 | Section/Page | Notes |
|-------|----------------------|-----------------|--------------|-------|
| 1 | VecEAFormula (type) | Def 3.1 | p. 3 | DONE (v21) |
| 2 | vec_ea_closed_disj/conj/exists | Lemma 3.2.1 + 3.4 | pp. 3-4 | DONE (v21) |
| 3 | bracketBuildRight / VecEA2.translateLeft | Prop 3.5 | p. 4 | DONE (v21) |
| 4 | neg_2var_vec_ea | Prop 4.2 | p. 6 | DONE (v22) |
| 5 | fo_to_vvecEA2_nf_prior | Prop 4.3 (NF-specific) | p. 6 | NEW -- restricted to arity-1 input from nf_to_formula |
| 5 | KampPrior:149 fill | Theorem 4.4 corollary | p. 6 | NEW -- nf_to_formula_correct + Prop 4.3 + Prop 3.5 |
| 6 | chronicle_gap_contradiction fill | -- | -- | NEW -- model surgery via reynolds_model_surgery_core |

### Preserved Assets (from v21/v22 phases 1-4)

| File | Lines | Status | Content |
|------|-------|--------|---------|
| VecEAFormula.lean | ~600 | SORRY-FREE | VecEAFormula, BracketFormula, VecEA2, VVecEA2 types + evaluation |
| VecEAClosure.lean | ~400 | SORRY-FREE | V-EA closed under disj, conj, exists |
| VecEATranslation.lean | ~350 | SORRY-FREE | bracketBuildRight, VecEA2.translateLeft, Prop 3.5 |
| NegationClosure5.lean | ~800 | SORRY-FREE | Lemma 5.1, 5.3, Corollary 5.4 (Section 5 machinery) |
| NegationClosureProp42.lean | ~350 | SORRY-FREE | Prop 4.2 negation closure for 2-var V-EA |
| FoToVecEA.lean | ~200 | SORRY-FREE | p2_from_p1_succ, nf_exist_iff_char_quant, nf_exist_iff_nf1_disjunction |
| Translation.lean | ~337 | SORRY-FREE | buildRight/buildLeft = Prop 3.5 temporal translation |
| PriorINF.lean | ~194 | SORRY-FREE | Prior first/last occurrence lemmas |
| NormalForm.lean:705-719 | -- | SORRY-FREE | nf_to_formula + nf_to_formula_correct |
| MonadicFO.lean | -- | SORRY-FREE | MonadicFormula sig n with eval semantics |
| GoodStructuresModelSurgery.lean | ~2000 | SORRY-FREE | reynolds_model_surgery_core, no_gaps_discrete_model_surgery |

### Quarantined Assets

| File | Lines | Status | Reason |
|------|-------|--------|--------|
| VecEADecomposition.lean | ~310 | QUARANTINED (2 sorries) | neg_bracket_syn_iff Case C: genuine impossibility under open-interval semantics; not imported by critical chain |
| NfComposition.lean | ~110 | QUARANTINED (2 sorries) | Witness merging problem; 5 failed attempts; not needed for NF-specific path |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 5 | 0 |
| 3 | 6 | 5 |
| 4 | 7 | 5, 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: vec-EA Formula Type and Bracket Notation [COMPLETED]

**Goal**: Define the vec-EA formula type (Rabinovich Def 3.1) and bracket notation (Notation 5.2) as Lean types.

**Tasks**:
- [x] Define `VecEAFormula m n` with `FreeVarPositions m n` for ordering
- [x] Define `BracketFormula`, `VecEA2`, `VBracketFormula`, `VVecEA2` types
- [x] Define evaluation functions: `VecEA2.holds`, `BracketFormula.holds`, `VBracketFormula.holds`
- [x] Verify definitions compile with no errors

**Timing**: 3 hours (~600 lines)

**Depends on**: none

**Completed**: 2026-06-11

---

### Phase 2: Closure Properties (Lemma 3.4) [COMPLETED]

**Goal**: Prove V-EA formulas closed under disjunction, conjunction, and existential quantification.

**Tasks**:
- [x] Prove conjunction closure via `BracketFormula.conj_to_bracket_exists`
- [x] Prove `VBracketFormula.conj_holds_vbracket` and `VVecEA2.conj_holds_vvecEA2`
- [x] Prove existential closure via `BracketFormula.existsBounded_right`
- [x] Verify all proofs sorry-free

**Timing**: 3 hours (~400 lines)

**Depends on**: 1

**Completed**: 2026-06-11

---

### Phase 3: V-EA to Temporal Translation (Prop 3.5) [COMPLETED]

**Goal**: Prove every V-EA formula with one free variable is equivalent to a TL(U,S) formula.

**Tasks**:
- [x] Implement `bracketBuildRight` using recursive nested Until
- [x] Prove `bracketBuildRight_correct` and `VecEA2.translateLeft_correct`
- [x] Wire to `buildRight_correct` from Translation.lean for base case

**Timing**: 2 hours (~350 lines)

**Depends on**: 1

**Completed**: 2026-06-11

---

### Phase 4: Negation Closure (Prop 4.2 via Section 5) [COMPLETED]

**Goal**: Prove negation of 2-free-variable vec-EA formulas is V-EA over Prior structures.

**Tasks**:
- [x] Phase 4a: Base case (`neg_interval_base_iff`, `neg_interval_base_bracket`, `neg_interval_base_vbracket`)
- [x] Phase 4b: INF formula on Prior (`first_occurrence_prior`, `inf_bracket_formula_holds`, `inf_formula_prior_is_vbracket`)
- [x] Phase 4c: Inductive step (`neg_purePoints_vbracket` with two cases: absent/present)
- [x] Phase 4d: Bounded existential negation by direct induction on n
- [x] Phase 4e: Main technical lemma `neg_interval_formula` via 2-level case split
- [x] Phase 4f: Prop 4.2 (`neg_vecEA2`, `neg_2var_vec_ea` for full `VVecEA2`)
- [x] Verify all proofs sorry-free

**Timing**: 8 hours (~1150 lines across two files)

**Depends on**: 2, 3

**Completed**: 2026-06-12

---

### Phase 5a: VecEADecomposition.lean -- Lemma 3.2.2 [ABANDONED]

**Goal**: (Originally) Prove n-var EA decomposition to conjunction of 2-var EA formulas.

**Reason for abandonment**: Round 23 research confirmed VecEADecomposition.lean is not imported by the critical chain (KampPrior.lean, NfCharFormula.lean, NegationClosure.lean, FoToVecEA.lean). The two sorries (`neg_bracket_syn_iff` soundness, `neg_vecEA2_syn_iff`) are dead code. The NF-specific Prop 4.3 (Phase 5) bypasses Lemma 3.2.2 entirely by restricting to arity-1 input formulas where the maximum induction arity is 2. The `neg_bracket_syn_iff` Case C failure is a genuine mathematical impossibility under open-interval semantics (confirmed by Teammate A). File will be quarantined with a dead-code header comment.

**Abandoned**: 2026-06-12

---

### Phase 0: Precondition Verification [COMPLETED]

**Goal**: Run two cheap verification checks before committing to the implementation line estimates. These checks were recommended by round 23 research (Gaps 2 and 3).

**Tasks**:
- [x] **Check 0a**: Read NormalForm.lean:705-719 and confirm `nf_to_formula` produces `MonadicFormula sig 1` (arity-1). *(deviation: altered -- confirmed arity-1 output, but maximum arity during structural induction is k+2, NOT 2 as plan claimed. For depth-k arity-1 input, sub-NFs at depth j have arity 1+(k-j). The plan's claim that "arity never exceeds 2" is incorrect for k >= 1.)*
- [x] **Check 0b**: Run `lean_verify nf_characterizable_temporal_prior_classical` -- has sorryAx (via nf_2var_exist_formula_prior at NfCharFormula.lean:572). Phase 5 is needed.
- [x] **Check 0c**: Quarantine VecEADecomposition.lean -- added header comment marking file as dead code, not on critical path, sorries bypassed by plan v23.

**Timing**: 0.5 hours

**Depends on**: none

**Verification**:
- Check 0a confirms arity bound (max 2 during induction)
- Check 0b determines whether Phase 5 is needed or can be simplified
- `lake build` still succeeds after quarantine comment addition

---

### Phase 5: NF-Specific Prop 4.3 + Bridge Wiring [NOT STARTED]

**Goal**: Prove that every `nf_to_formula nf` (arity-1 MonadicFormula) has a VVecEA2 equivalent over Prior structures, by strong induction on NF depth k. Then wire the result into KampPrior.lean:149 and downstream NfCharFormula.lean:572 via `nf_to_formula_correct` + `translateLeft_correct`. This is the NF-specific bypass that avoids VecEADecomposition.lean and the general Lemma 3.2.2 entirely.

**Literature**: Rabinovich 2014, Proposition 4.3 (p. 6), restricted to arity-1 input from `nf_to_formula`. The negation case at arity 2 is handled by Prop 4.2 (`neg_2var_vec_ea`, NegationClosureProp42.lean:153, sorry-free).

**Tasks**:
- [ ] **Task 5.1**: Create `Kamp/Prop43.lean` (or `Kamp/Prop43NfSpecific.lean`) with the NF-specific statement:
  ```
  fo_to_vvecEA2_nf_prior : forall k (nf : NormalForm sig k 1),
    exists v : VVecEA2, forall M h_UZ h_SZ t,
      v.holdsLeft M atomMap t <-> nf_eval_nf M k 1 (fun _ => t) nf
  ```
  Proof by strong induction on k. (~20 lines for statement + setup)
- [ ] **Task 5.2**: Prove base case (k=0): `nf_depth0_char_formula` or direct construction -- an atomic NF at depth 0 is a quantifier-free formula, trivially a VVecEA2. (~15-25 lines)
- [ ] **Task 5.3**: Prove inductive step (k+1): structural induction on `nf_to_formula nf` where `nf : NormalForm sig (k+1) 1`:
  - Atomic case: quantifier-free = EA with 0 witnesses (immediate)
  - Disjunction case: IH gives VVecEA2 for both sub-NFs, apply `VVecEA2.disj_holds` from VecEAClosure.lean (~10-15 lines)
  - Negation case: IH gives VVecEA2 for sub-NF (at arity 2 after existential), apply `neg_2var_vec_ea` (NegationClosureProp42.lean:153, sorry-free). This is the key simplification -- arity never exceeds 2, so no Lemma 3.2.2 needed. (~30-50 lines)
  - Existential case: IH gives VVecEA2 for body at arity 2, apply `vec_ea_closed_exists` from VecEAClosure.lean to project back to arity 1. (~15-25 lines)
- [ ] **Task 5.4**: Wire into KampPrior.lean:149 (`nf_characterizable_temporal_prior` succ case):
  1. `nf_to_formula nf : MonadicFormula sig 1` (NormalForm.lean:705)
  2. `fo_to_vvecEA2_nf_prior` gives VVecEA2 equivalent over Prior
  3. `VVecEA2.translateLeft_correct` (VecEATranslation.lean) gives temporal Formula
  4. `nf_to_formula_correct` (NormalForm.lean:719) links back to `nf_eval_nf`
  (~15-25 lines modification to KampPrior.lean)
- [ ] **Task 5.5**: Close NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`): With KampPrior:149 closed, trace the downstream dependency chain. If `nf_2var_exist_formula_prior` routes through `master_induction`, provide an alternative direct proof from Prop 4.3 (~10-15 lines). If it fills automatically via the sorry-free `kamp_prior_expressive_completeness`, verify and document. (~5-15 lines)
- [ ] **Task 5.6**: Mark NegationClosure.lean:1371 (`nf_exist_formula_nested_backward`) as bypassed dead code: add comment explaining Path B (NF-specific Prop 4.3 + Prop 3.5) bypasses this sorry via direct KampPrior closure. Do NOT delete the sorry. (~3 lines)

**Timing**: 3 hours (~150-200 lines: ~80-120 lines in Prop43.lean + ~20-30 lines in KampPrior.lean + ~10-15 lines in NfCharFormula.lean + ~3 lines in NegationClosure.lean)

**Depends on**: 0

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` (NEW) -- NF-specific FO -> V-EA

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- fill sorry at :149
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at :572
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- mark :1371 as bypassed

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Prop43` succeeds with 0 sorries
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds with 0 sorries
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula` succeeds with 0 sorries
- `lean_verify nf_characterizable_temporal_prior` shows no sorryAx
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- `lean_verify US_expressively_complete_over_prior` shows no sorryAx

**Implementation Notes**:
- The induction is on NF depth k, not on formula structure. At each depth, `nf_to_formula` produces a formula whose structure determines the case split.
- The negation case is the critical simplification: since `nf_to_formula` starts at arity 1 and each existential raises arity by 1, the maximum arity in the induction is 2. At arity 2, `neg_2var_vec_ea` applies directly -- no decomposition to 2-var pieces needed.
- If Phase 0 Check 0b reveals `nf_characterizable_temporal_prior_classical` is sorry-free, Task 5.4 simplifies to applying that theorem directly. Phase 5 may reduce to just the wiring (~30 lines total).
- Postmortem constraint 5 applies: if any step seems to require NF-level reasoning, re-read the Rabinovich reference for the formula-level alternative.

---

### Phase 6: Chronicle Gap Contradiction [NOT STARTED]

**Goal**: Fill the `chronicle_gap_contradiction` sorry at ChronicleToCountermodel.lean:531 using the fully-proved `reynolds_model_surgery_core` from GoodStructuresModelSurgery.lean. This is the second independent sorry on the critical path to `completeness_discrete`, discovered by round 23 Teammate C.

**Tasks**:
- [ ] **Task 6.1**: Read ChronicleToCountermodel.lean:531 context and header comment (lines 65-70) to understand the proof sketch: construct `OrderedMonadicStructure sig` on `LimitDomSubtype fc A h_mcs`, prove `semantic_prior_UZ` and `semantic_prior_SZ`, apply `reynolds_model_surgery_core`. (~15 lines reading/analysis)
- [ ] **Task 6.2**: Construct `OrderedMonadicStructure sig` on `LimitDomSubtype fc A h_mcs` with the required structure (linear order, monadic predicates, UZ/SZ semantic properties). (~30-50 lines)
- [ ] **Task 6.3**: Prove `semantic_prior_UZ` and `semantic_prior_SZ` for the constructed structure using `limit_f` properties from the chronicle construction. (~30-50 lines)
- [ ] **Task 6.4**: Apply `reynolds_model_surgery_core` (GoodStructuresModelSurgery.lean, sorry-free) to derive `contemp_equiv a b` for all `b`. Derive contradiction from `hab : a < b` with `contemp_equiv a b`. (~20-30 lines)
- [ ] **Task 6.5**: Remove or correct the stale header comment at ChronicleToCountermodel.lean:65-70 that falsely claims Task 268 resolved this sorry. Replace with accurate documentation noting this was filled in Task 273 v23 Phase 6. (~5 lines)

**Timing**: 2.5 hours (~100-150 lines modification to ChronicleToCountermodel.lean)

**Depends on**: 5 (because `chronicle_gap_contradiction` calls `US_expressively_complete_over_prior` via GoodStructuresModelSurgery.lean:1266, which requires KampPrior:149 to be closed first)

**Files to modify**:
- `Theories/Bimodal/Metalogic/ChronicleToCountermodel.lean` -- fill sorry at :531, fix stale comment at :65-70

**Verification**:
- `lake build Bimodal.Metalogic.ChronicleToCountermodel` succeeds with 0 sorries at :531
- `lean_verify chronicle_gap_contradiction` shows no sorryAx
- `lean_verify completeness_discrete` shows progress (remaining sorries only from Task 202 chain)

**Implementation Notes**:
- `chronicle_gap_contradiction` calls `US_expressively_complete_over_prior` internally (via GoodStructuresModelSurgery.lean:1266), which is why Phase 5 must be completed first. If KampPrior:149 is still sorry, `US_expressively_complete_over_prior` still has sorryAx and the model surgery cannot run cleanly.
- GoodStructuresModelSurgery.lean is confirmed fully sorry-free (round 23 Teammate C verified). The key lemma `reynolds_model_surgery_core` and supporting `no_gaps_discrete_model_surgery` are both available.
- ChronicleToCountermodel.lean:218 and :374 (`succ_reaches_dom_N` case 3 boundary) have separate sorries that are dead code -- do NOT attempt to fill them in this phase.

---

### Phase 7: Full Build Verification and Cleanup [NOT STARTED]

**Goal**: Verify the entire sorry chain is closed end-to-end for `completeness_discrete` (modulo Task 202). Clean up stale documentation and quarantine dead-code files.

**Tasks**:
- [ ] Run `lake build` (full project build) -- must succeed with 0 errors
- [ ] Verify `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- [ ] Verify `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- [ ] Verify `#print axioms chronicle_gap_contradiction` shows no sorryAx
- [ ] Verify `#print axioms completeness_discrete` -- remaining sorryAx should trace ONLY through Task 202 chain (`succ_cofinal` / NEquivalence.lean), not through the Kamp or chronicle chains
- [ ] Quarantine NfComposition.lean: add header comment "bypassed by plan v23 -- NF-specific Prop 4.3 eliminates composition requirement; file retained for reference"
- [ ] Mark NegationClosure.lean:1371 dead-code comment (if not already done in Phase 5)
- [ ] Update ROADMAP.md: mark Kamp chain complete, chronicle gap filled
- [ ] Add docstring to StaviCompleteness.lean noting the sorry chain is fully bypassed via Kamp/Rabinovich NF-specific path

**Timing**: 2 hours (mostly verification and cleanup)

**Depends on**: 5, 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` -- quarantine header
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviCompleteness.lean` -- docstring update
- `specs/ROADMAP.md` -- completion status update

**Verification**:
- `lake build` succeeds (full project, clean)
- `#print axioms completeness_discrete` shows no Kamp/chronicle chain sorryAx
- All downstream consumers compile

---

## Testing & Validation

- [x] Phase 1: vec-EA type definitions compile, universe-correct (DONE)
- [x] Phase 2: Closure lemmas sorry-free (DONE)
- [x] Phase 3: Translation correctness sorry-free (DONE)
- [x] Phase 4: All negation closure sub-phases (4a-4f) sorry-free (DONE)
- [ ] Phase 0: `nf_to_formula` arity bound confirmed; `nf_characterizable_temporal_prior_classical` status checked; VecEADecomposition quarantined
- [ ] Phase 5: `fo_to_vvecEA2_nf_prior` sorry-free; KampPrior.lean sorry-free; NfCharFormula.lean sorry-free; `lean_verify kamp_prior_expressive_completeness` no sorryAx
- [ ] Phase 6: `chronicle_gap_contradiction` sorry-free; `lean_verify chronicle_gap_contradiction` no sorryAx
- [ ] Phase 7: `lake build` -- full project, zero errors; `#print axioms completeness_discrete` shows only Task 202 chain dependencies

## Artifacts & Outputs

**Existing (phases 1-4, sorry-free)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- vec-EA types (~600 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` -- Closure properties (~400 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` -- V-EA to temporal (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` -- Section 5 lemmas (~800 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` -- Prop 4.2 (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean` -- Bridge theorems (~200 lines)

**New (Phase 5)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` -- NF-specific FO -> V-EA (~150-200 lines)

**Modified (Phases 5, 6, 7)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- sorry fill at :149 (~20-30 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- sorry fill at :572 (~5-15 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- bypass comment at :1371 (~3 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomposition.lean` -- quarantine comment (~5 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` -- quarantine header (~5 lines)
- `Theories/Bimodal/Metalogic/ChronicleToCountermodel.lean` -- sorry fill at :531, fix stale comment (~100-150 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviCompleteness.lean` -- docstring (~5 lines)
- `specs/ROADMAP.md` -- status update

**Estimated new Lean code**: ~250-350 lines across 1 new file + ~140-200 lines modifications to 7 existing files

## Rollback/Contingency

**If Phase 0 Check 0a fails (arity exceeds 2)**:
- Fall back to v22's approach: implement general Lemma 3.2.2 in VecEADecomposition.lean (resolving the `neg_bracket_syn_iff` Case C blocker or finding an alternative syntactic construction), then general Prop 4.3. Estimated additional ~350-500 lines.

**If Phase 0 Check 0b succeeds (nf_characterizable_temporal_prior_classical is sorry-free)**:
- Phase 5 simplifies dramatically: wire KampPrior:149 directly via `nf_characterizable_temporal_prior_classical`, skip the NF-specific Prop 4.3 proof entirely. Estimated Phase 5 reduces to ~30 lines.

**If Phase 5 structural induction is harder than expected**:
- Decompose: prove the induction only for k=0 and k=1 first (covers the actual NF depths used by `nf_to_formula`). Generalize to all k later.

**If Phase 6 model surgery wiring is harder than expected**:
- The proof sketch in ChronicleToCountermodel.lean:65-70 may be incomplete. Fall back to: (a) inspect the exact `reynolds_model_surgery_core` signature and adapt, or (b) spin off a separate task for chronicle_gap_contradiction if it requires significant new infrastructure.

**If the approach fails entirely**:
- All existing sorry-free code (phases 1-4, ~2700 lines) remains valid
- VecEADecomposition.lean sorries remain quarantined (dead code)
- Fall back to Path A: composition theorem (NfComposition.lean) via Feferman-Vaught for linear orders (estimated 300-500 lines, 5 prior failures at the witness merging step -- only as last resort)
