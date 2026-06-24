# Implementation Plan: B.2 Fix and Impossibility Documentation (Task #305 v32)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None (all prerequisite sorry-free infrastructure exists)
- **Research Inputs**: reports/18_rabinovich-restructure-design.md
- **Artifacts**: plans/32_b2-fix-impossibility.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan addresses two concrete, well-scoped improvements to the EA negation closure infrastructure. First, replace the flawed `inf_bracket_formula(alpha_0)` in the B.2 case of `neg_interval_formula_indep` with `neg_b2_bracket_formula(alpha_0, beta_0)`, a 2-witness bracket encoding both alpha_0 occurrence and beta_0 failure. This fixes the B.2 backward direction (disjointness), making it provable for the first time. Second, update the sorry comments at EANegation.lean lines 1084 and 1235 with definitive impossibility analysis from report 18. Done is: `lake build` succeeds, forward proof remains sorry-free, B.2 disjointness theorem added, and sorry comments document the precise structural reason (existential vs universal quantification mismatch).

### Research Integration

**From reports/18_rabinovich-restructure-design.md (primary)**:
- B.2 fix confirmed correct with concrete type signatures (Section 9): `neg_b2_bracket_formula` as `BracketFormula 2` with witnesses (beta_0 failure, first alpha_0)
- Forward proof change is minor (~30 lines): replace `inf_bracket_formula_hasINF` call with `neg_b2_bracket_formula_hasINF`
- Backward proof (disjointness) is ~20 lines: chain alpha_0.neg on (z0, x) forces w_0 >= x > y, placing beta_0 failure y in segment (z0, w_0) for contradiction
- B.1 backward gap confirmed fundamental and unfixable at BracketFormula level (Section 4)
- Corollary 5.4 biconditional confirmed unprovable with interior-witness convention (Section 10)
- De Morgan approach (plan v31) also requires component-level backward direction (Section 7.5)

### Prior Plan Reference

Plan v31 had 4 phases targeting VecEA_m syntactic design. Phase 1 was blocked because `neg_2var_vec_ea_indep_backward` is unprovable (concrete counterexample: `inf_bracket_formula(P)` is not disjoint from the original bracket). Report 18 confirmed this is fundamental: V-bracket formulas are existentially quantified, but backward direction requires universal quantification over model-dependent witness arrangements. Lesson: the biconditional at BracketFormula level cannot be achieved with the interior-witness convention, but the forward-only constructions are sufficient for completeness.

### Roadmap Alignment

- Advances: "Task 303 targets the k>0 closure" -- the B.2 fix improves the negation construction quality and B.2 disjointness theorem is a step toward stronger model-independent results, though the KampPrior.lean:287 sorry remains blocked by different issues (VecEA_m negation)
- This plan does not close any sorry chain but hardens the existing forward-only infrastructure

## Goals & Non-Goals

**Goals**:
- Define `neg_b2_bracket_formula` in EANegationClosure.lean (2-witness bracket for B.2 case)
- Prove `neg_b2_bracket_formula_hasINF` (forward correctness)
- Prove `neg_b2_bracket_formula_disjoint` (backward disjointness -- new capability)
- Replace `inf_bracket_formula` with `neg_b2_bracket_formula` in `neg_interval_formula_indep` Case B2
- Update `neg_interval_formula_indep_correct` Case B2 proof to use new formula
- Update sorry comments at EANegation.lean:1084 and 1235 with definitive impossibility analysis
- Update the NOTE comment at NegationIndep.lean:328-334 to reference report 18 and the B.2 fix
- Maintain `lake build` success throughout

**Non-Goals**:
- Fixing B.1 backward direction (proved fundamental by report 18)
- Fixing Corollary 5.4 backward direction (same structural impossibility)
- Pursuing VecEA_m design or KampPrior sorry elimination (separate planning needed)
- Proving `neg_2var_vec_ea_indep_backward` (cascading impossibility from B.1)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `neg_b2_bracket_formula_hasINF` proof more complex than estimated due to Fin index arithmetic | L | M | Type signature from report 18 Section 9.2 is concrete; existing `inf_bracket_formula_hasINF` pattern is directly analogous. Use `lean_multi_attempt` to explore tactic options. |
| `neg_b2_bracket_formula_disjoint` proof hits unexpected alpha_0/beta_0 interaction | L | L | Report 18 Section 3.2 provides explicit proof sketch with HIGH adversarial confidence. The argument is a 3-step chain of elementary order reasoning. |
| Forward proof modification in `neg_interval_formula_indep_correct` breaks existing B1/A cases | M | L | Only the B2 branch (NegationIndep.lean lines 154-161) changes. B1 and A branches are untouched. Build verification after edit confirms isolation. |
| Fin index arithmetic for BracketFormula 2 vs BracketFormula 1 creates simp difficulties | L | M | Use `omega` for Fin bounds. The BracketFormula 2 has `Fin 2` for pointTypes and `Fin 3` for segmentTypes -- standard patterns already used in existing code. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Define and Prove neg_b2_bracket_formula [COMPLETED]

**Goal**: Add the `neg_b2_bracket_formula` definition and its two correctness theorems to `EANegationClosure.lean`, then replace the B.2 case in `NegationIndep.lean` and update its correctness proof.

**Tasks**:
- [x] Add `neg_b2_bracket_formula` definition after `inf_bracket_formula_hasINF` (around line 226) in `EANegationClosure.lean` *(deviation: altered -- pointTypes(0) changed from `beta_0.neg` to `(beta_0.neg).conj (alpha_0.neg)` to close a gap in the disjointness proof where witnesses could coincide)*
- [x] Prove `neg_b2_bracket_formula_hasINF` (~30 lines): given first alpha_0 at `r0` and beta_0 failure on `(z0, r0)`, construct the 2-witness bracket holding on `(z0, z1)`. Witnesses: `y` (beta_0 failure point) and `r0` (first alpha_0).
- [x] Prove `neg_b2_bracket_formula_disjoint` (~20 lines): given `neg_b2_bracket_formula.holds` and `bf.holds` for a bracket with matching alpha_0/beta_0, derive `False`. Proof chain: alpha_0.neg on (z0, x) forces bf's first witness w_0 >= x, so y < x <= w_0 puts beta_0.neg(y) in segment (z0, w_0), contradicting beta_0 on (z0, w_0).
- [x] In `NegationIndep.lean`, replace `neg_interval_formula_indep` Case B2 definition (line 82): change `⟨[⟨1, inf_bracket_formula (bf.pointTypes ⟨0, by omega⟩)⟩]⟩` to `⟨[⟨2, neg_b2_bracket_formula (bf.pointTypes ⟨0, by omega⟩) (bf.segmentTypes ⟨0, by omega⟩)⟩]⟩`
- [x] In `NegationIndep.lean`, update `neg_interval_formula_indep_correct` Case B2 proof (lines 154-161): replace `inf_bracket_formula_hasINF` call with `neg_b2_bracket_formula_hasINF`, passing both `alpha_0` and `beta_0` plus `h_seg` (the beta_0 failure hypothesis already in scope)
- [x] Update the NOTE comment at NegationIndep.lean:328-334 to reference report 18, the B.2 fix, and confirm B.1 remains the sole unfixable gap
- [x] Run `lake build` to verify all changes compile

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- add `neg_b2_bracket_formula` + 2 theorems (~80-100 new lines after line 226)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationIndep.lean` -- replace B2 definition (line 82), update B2 proof (lines 154-161), update NOTE comment (lines 328-334)

**Verification**:
- `lake build` succeeds with zero new errors
- `neg_interval_formula_indep_correct` remains sorry-free
- `neg_b2_bracket_formula_disjoint` is sorry-free (new theorem)
- `lean_verify` on `neg_b2_bracket_formula_disjoint` shows no sorry axioms

---

### Phase 2: Document Impossibility in Sorry Comments [NOT STARTED]

**Goal**: Update the sorry comments at EANegation.lean lines 1084 and 1235 to contain definitive impossibility analysis, referencing report 18 findings and the structural reason.

**Tasks**:
- [ ] Update the sorry comment block at EANegation.lean:1047-1083 (B.1 backward sorry) to add:
  - Reference to report 18 Section 4 confirming the B.1 gap is fundamental
  - Note that the B.2 gap has been fixed by `neg_b2_bracket_formula_disjoint`
  - Precise structural reason: V-bracket formulas are existentially quantified (there exist witnesses); backward direction requires universal quantification over all possible bracket witness arrangements which vary per model; IH gives negation on one specific sub-interval (r0, z1) but bracket witness w_0 could be > r0 giving different sub-interval (w_0, z1)
  - Confirm this sorry does NOT block completeness (model-dependent `neg_interval_formula` in EANegationClosure.lean is sorry-free)
- [ ] Update the sorry comment block at EANegation.lean:1211-1234 (Corollary 5.4 backward sorry) to add:
  - Reference to report 18 Section 10 confirming the Corollary 5.4 biconditional is also unprovable with interior-witness convention
  - Structural reason parallels B.1: bounded existential's witness determines the sub-interval, and different witnesses give different intervals
  - Note that the F-chain Until-unboundedness is a special case of this same existential-vs-universal mismatch
  - Confirm this sorry does NOT block completeness (model-dependent `neg_bounded_exists` in EANegationClosure.lean is sorry-free)
- [ ] Run `lake build` to verify comments do not introduce syntax issues

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- update comment blocks at lines 1047-1083 and 1211-1234 (~20 lines of comment changes total)

**Verification**:
- `lake build` succeeds
- Sorry comments contain report 18 references
- No new sorrys introduced
- Existing sorry-free theorems remain sorry-free

## Testing & Validation

- [ ] `lake build` succeeds after Phase 1
- [ ] `lake build` succeeds after Phase 2
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.neg_b2_bracket_formula_hasINF` -- no sorry axioms
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.neg_b2_bracket_formula_disjoint` -- no sorry axioms
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.neg_interval_formula_indep_correct` -- no sorry axioms (unchanged)
- [ ] Existing sorry count in NegationIndep.lean: 0 (unchanged)
- [ ] Existing sorry count in EANegation.lean: 2 (lines 1084 and 1235, unchanged)

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/32_b2-fix-impossibility.md` (this plan)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` (~80-100 new lines)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationIndep.lean` (~16 modified lines)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` (~20 lines of comment updates)

## Rollback/Contingency

All changes are additive or surgical replacements. If any theorem fails to compile:
- Phase 1: Revert EANegationClosure.lean additions and NegationIndep.lean B2 changes via `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationIndep.lean`
- Phase 2: Comment-only changes; revert EANegation.lean via `git checkout`
- No existing sorry-free code is at risk since Phase 1 only modifies the B2 branch (lines 82, 154-161 in NegationIndep.lean) and adds new definitions/theorems (no existing code deleted)
