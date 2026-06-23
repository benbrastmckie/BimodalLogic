# Implementation Plan: Faithful Rabinovich Chain (Task #305 v3)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (all required sorry-free infrastructure exists)
- **Research Inputs**: reports/24_z-completeness-rabinovich.md
- **Artifacts**: plans/25_faithful-rabinovich-chain.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate the sole critical-path sorry at KampPrior.lean:158 (`nf_characterizable_temporal_prior` succ case) by implementing the full Rabinovich 2014 proof chain faithfully. Research report 24 established that Path A (Rabinovich chain with correct segment-type decomposition) is the ONLY viable path -- Path B (Stavi) is mathematically false and Path C (Z-transfer) has three independent blockers. The prior plan (v24) was blocked because it attempted model-independent VecEA2 negation (EndpointNegation.lean) and structural induction on MonadicFormula (Prop 4.3), both of which require arity >= 3 V-EA infrastructure that does not exist. This plan restructures the approach to use the model-DEPENDENT negation chain (already sorry-free in EANegationClosure.lean) as the backbone, since KampPrior operates on specific Prior structures where model-dependent results suffice. The chain is: fix Cor 5.4 backward -> Prop 4.2 model-independent via finite case enumeration -> Prop 4.3 structural induction -> Theorem 4.4 -> KampPrior sorry elimination. Done when `kamp_prior_expressive_completeness` and `completeness_discrete` are sorry-free through this chain.

### Research Integration

**From report 24 (z-completeness-rabinovich.md) -- definitive analysis**:
- Path B (Stavi, StaviCompleteness.lean:2873) is mathematically false -- confirmed dead
- Path C (Z-transfer) has three independent blockers: atomMap type mismatch, carrier mismatch, transfer circularity
- Path A (Rabinovich chain) is the ONLY viable path
- The EndpointNegation.lean:160 sorry IS fixable via Rabinovich's segment-type decomposition (not point-type splitting)
- Cor 5.4 backward (EANegation.lean:1235) is fixable via bounded F-chain
- Estimated total: 800-1500 lines across 5 phases

**Key infrastructure confirmed sorry-free**:
- `neg_interval_formula` (Lemma 5.1 model-dependent) -- EANegationClosure.lean
- `neg_bounded_exists` -- EANegationClosure.lean
- `neg_vecEA2` (Prop 4.2 single conjunct, model-dependent) -- EANegationClosure.lean
- `neg_2var_vec_ea` (Prop 4.2 full, model-dependent) -- EANegationClosure.lean
- `ExistsForallSpec.translate_correct` (Prop 3.5) -- RabinovichTranslation.lean
- `VVecEA2.translateLeft_correct` -- VecEATranslation.lean
- `VVecEA2.conj_holds_vvecEA2` (conjunction closure) -- VecEAClosure.lean
- `inf_bracket_formula`, `inf_bracket_formula_hasINF` -- EANegationClosure.lean
- `prior_hasAttainedINF` -- PriorDefs.lean

### Prior Plan Reference

The prior plan (plans/24_faithful-restructure.md, v2) was blocked at Phase 2: the model-independent negation approach (`neg_2var_vec_ea_indep`) required enumerating all possible VBracketFormula outputs from `neg_interval_formula` by case-splitting on boolean conditions. Phase 3 (structural induction on MonadicFormula) was blocked because the `ex` case of `MonadicFormula sig 2` introduces `MonadicFormula sig 3`, requiring arity-3 V-EA infrastructure that does not exist. Lessons learned: (1) model-independent negation via finite enumeration is viable in principle but may be infeasible in practice; (2) structural induction on MonadicFormula faces the arity tower problem; (3) the model-dependent chain in EANegationClosure.lean is entirely sorry-free and should be the primary vehicle.

### H3 Reference Grounding Table

| Source (Rabinovich 2014) | Lean Identifier | Type Signature | Status |
|--------------------------|-----------------|----------------|--------|
| Cor 5.4 bwd (p.9) | `neg_partialBracketExist_is_vbracket` | `v.holds <-> neg partialBracketExist` | sorry at EANegation.lean:1235 |
| Lemma 5.1 model-indep (pp.7-11) | `neg_vecEA2_is_vvecEA2` (succ) | `exists v, v.holds <-> neg vea.holds` | sorry at EndpointNegation.lean:160 |
| Lemma 5.1 model-dep (pp.7-11) | `neg_interval_formula` | `neg bf.holds -> exists vbf, vbf.holds` | sorry-free |
| Prop 4.2 model-dep (p.6) | `neg_2var_vec_ea` | `neg v.holds -> exists v', v'.holds` | sorry-free |
| Prop 4.2 model-indep (p.6) | (new: `neg_2var_vec_ea_indep`) | `{ v' // forall M ..., v'.holds <-> neg v.holds }` | Phase 2 target |
| Prop 4.3 (p.6) | (new: `fo_to_vvea`) | structural induction MonadicFormula -> VVecEA2 | Phase 3 target |
| Thm 4.4 (p.6) | (new: via Prop 4.3 + Prop 3.5) | `MonadicFormula sig 1 -> Formula` | Phase 4 target |
| Prop 3.5 (p.5) | `ExistsForallSpec.translate_correct` | `temporal_truth t v.translateLeft <-> v.holdsLeft t` | sorry-free |
| HasAttainedINF | `prior_hasAttainedINF` | `Prior -> HasAttainedINF` | sorry-free |

### Roadmap Alignment

This plan advances the sole critical-path item: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free `completeness_discrete`." Completing this chain eliminates the ONLY remaining sorry blocking `completeness_discrete`.

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry at KampPrior.lean:158 (`nf_characterizable_temporal_prior` succ case)
- Fix Cor 5.4 backward direction (EANegation.lean:1235) via bounded F-chain
- Fix VecEA2-level Lemma 5.1 succ case (EndpointNegation.lean:160) via Rabinovich's segment-type decomposition
- Build model-independent Prop 4.2 negation closure via finite case enumeration over model-dependent outputs
- Prove Prop 4.3 structural induction on MonadicFormula (handling arity tower correctly)
- Achieve sorry-free `kamp_prior_expressive_completeness` and downstream `completeness_discrete`
- Maintain `lake build` success after every phase

**Non-Goals**:
- Fixing EANegation.lean:1084 (BracketFormula-level impossibility -- permanent, off critical path)
- Building general V-EA infrastructure for arity >= 3 (the plan avoids this requirement)
- Addressing the Stavi chain (mathematically false, confirmed dead)
- Modifying any existing sorry-free code except to wire in the new chain at KampPrior.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cor 5.4 bounded F-chain approach requires more helper lemmas than estimated | M | M | The forward direction is sorry-free; pattern exists in `neg_partialBracketExist_sufficient`. Budget 50-100 extra lines for bounded Until construction. |
| VecEA2-level Lemma 5.1 segment-type case analysis (Case 3: interval splitting at r_0) has complex index arithmetic | H | M | Use `inf_bracket_formula` and `inf_bracket_formula_hasINF` (both sorry-free) as templates. Break Case 3 into sub-lemmas. |
| Model-independent Prop 4.2 via finite enumeration produces too many disjuncts | M | L | The number of possible VBracketFormula structures from `neg_interval_formula` is bounded by the finite TemporalPred label set. If enumeration is infeasible, fall back to using model-dependent negation directly in the KampPrior bridge (since KampPrior operates on specific Prior structures). |
| Prop 4.3 `ex` case introduces MonadicFormula sig 3, needing arity-3 V-EA | H | H | For 1-free-variable formulas (which is what KampPrior needs), `ex alpha` produces a 2-variable formula. Apply Prop 4.2 for the negation case within 2-variable scope. The critical insight: Rabinovich's Prop 4.3 for sig=1 only ever introduces sig=2 formulas (one existential binds one variable, staying within 2-var scope). |
| Bridging MonadicFormula evaluation to NF evaluation in KampPrior is non-trivial | H | M | `nf_to_formula` and `nf_to_formula_correct` (sorry-free) provide the NF-to-MonadicFormula bridge. Compose: NF -> MonadicFormula -> VVecEA2 -> Formula. |
| Lemma 3.2.2 (reduction to 2-free-variable EA) needed for Prop 4.3 | M | M | Research report 24 flags this. Budget +100 lines. If needed, implement as a preliminary sub-lemma in the FOToVEA file. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Fully sequential: each phase depends on the previous. No parallel execution possible due to the chain structure (each phase builds on the sorry eliminated by the previous phase).

---

### Phase 1: Fix Cor 5.4 Backward Direction [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: Backward direction of `neg_partialBracketExist_is_vbracket` for n+1
- **What was tried**: Analysis of goal state shows need for ¬partialBracketExist → v_suff.holds, but v_suff is constructed from fChainPred whose Until witnesses are unbounded
- **Why stuck**: Structurally unprovable at BracketFormula level (documented in EANegation.lean:1211-1228). Model-independent biconditional cannot be established because Until witnesses may lie outside (z0, z1)
- **What is needed**: N/A - using contingency path (model-dependent negation from EANegationClosure.lean)
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Eliminate the sorry at EANegation.lean:1235 (`neg_partialBracketExist_is_vbracket`, n+1 backward case) by replacing the fChainPred-based approach with a bounded construction that keeps Until witnesses within (z0, z1).

**Tasks**:
- [ ] Read EANegation.lean lines 1100-1235 to understand the current forward direction (`neg_partialBracketExist_sufficient`) and the sorry site
- [ ] Read the fChainPred definition and identify where unbounded Until witnesses cause the obstruction
- [ ] Define a bounded F-chain variant (or modify the backward proof) that constrains witnesses to (z0, z1) using the HasAttainedINF hypothesis
- [ ] Implement the backward direction: if `neg partialBracketExist` holds, then the V-bracket from the forward direction must also hold (via bounded infimum construction)
- [ ] Verify the sorry is eliminated: `lean_verify` on `neg_partialBracketExist_is_vbracket`
- [ ] Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- modify sorry at line 1235

**Verification**:
- `lean_verify` confirms `neg_partialBracketExist_is_vbracket` is sorry-free
- `lake build` succeeds

---

### Phase 2: VecEA2-Level Lemma 5.1 via Segment-Type Decomposition [BLOCKED]

**BLOCKER** (Phase 2):
- **What failed**: Model-independent biconditional for VecEA2 (n+1) negation
- **What was tried**: Depends on Phase 1 (Cor 5.4 backward) which is blocked
- **Why stuck**: Same structural obstruction: interior existential witnesses make case analysis model-dependent (documented in EndpointNegation.lean:129-159)
- **What is needed**: N/A - using contingency path (model-dependent negation from EANegationClosure.lean)
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Eliminate the sorry at EndpointNegation.lean:160 (`neg_vecEA2_is_vvecEA2`, succ case) by implementing Rabinovich's segment-type case analysis. The base case (n=0) is already sorry-free (125 lines). The succ case requires decomposing the negation into three sub-cases based on endpoint predicates and segment-type satisfaction.

**Tasks**:
- [ ] Read EndpointNegation.lean:127-160 to understand the documented obstruction analysis
- [ ] Read Rabinovich 2014 Lemma 5.1 proof structure (pp. 7-11) for the correct segment-type decomposition
- [ ] Implement Case 1: neg endpointLeft(z0) or neg endpointRight(z1) -- trivial V-brackets (reuse base case pattern)
- [ ] Implement Case 2: endpoints hold AND seg_0 holds everywhere in (z0, z1) -- reduce to Cor 5.4 backward (Phase 1) on the tail bracket with fewer witnesses
- [ ] Implement Case 3: endpoints hold AND seg_0 fails at r_0 = inf{x | neg seg_0(x)}:
  - Use `inf_bracket_formula` + `inf_bracket_formula_hasINF` to pin r_0 as a VecEA2 formula
  - For witnesses x_i >= r_0: seg_0 failure at r_0 blocks the bracket (VecEA2 with x_i in [r_0, z1) has seg_0 failing)
  - For witnesses x_i < r_0: seg_0 holds on (z0, x_i), apply Cor 5.4 backward on sub-interval (z0, r_0) with IH (fewer witnesses)
- [ ] Wire the three cases together using `VVecEA2` disjunction
- [ ] Verify the sorry is eliminated: `lean_verify` on `neg_vecEA2_is_vvecEA2`
- [ ] Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` -- rewrite succ case at line 160

**Verification**:
- `lean_verify` confirms `neg_vecEA2_is_vvecEA2` is sorry-free
- `lake build` succeeds

---

### Phase 3: Model-Independent Prop 4.2 Negation [BLOCKED]

**BLOCKER** (Phase 3):
- **What failed**: Depends on Phase 2 (model-independent VecEA2 negation) which is blocked
- **What was tried**: Phase 2 is prerequisite
- **Why stuck**: Upstream dependency blocked
- **What is needed**: N/A - using contingency path (model-dependent neg_2var_vec_ea from EANegationClosure.lean suffices for KampPrior)
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Build `neg_2var_vec_ea_indep`: a model-independent version of Prop 4.2 that produces a fixed VVecEA2 (before knowing the model) whose holds-predicate is equivalent to the negation of any input VVecEA2 on all structures with HasAttainedINF. This is the bridge from the model-dependent negation closure (EANegationClosure.lean) to the model-independent structural induction (Prop 4.3).

**Strategy**: Phase 2 provides model-independent `neg_vecEA2_is_vvecEA2` for individual VecEA2 conjuncts. To negate a VVecEA2 (disjunction of VecEA2s): neg(d1 or d2 or ... or dk) = neg(d1) and neg(d2) and ... and neg(dk). Each neg(di) is a VVecEA2 by Phase 2. The conjunction of VVecEA2s is a VVecEA2 by `VVecEA2.conj_holds_vvecEA2` (VecEAClosure.lean, sorry-free). The result is model-independent because each neg(di) is model-independent (Phase 2) and conjunction is structural.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ModelIndepNegation.lean`
- [ ] Import EndpointNegation.lean (Phase 2), VecEAClosure.lean
- [ ] Build helper: `neg_vecEA2_conjunct_indep` -- for each VecEA2 in the disjunction, apply `neg_vecEA2_is_vvecEA2` to get a model-independent VVecEA2
- [ ] Build `neg_2var_vec_ea_indep` by taking the conjunction of all negated disjuncts using `VVecEA2.conj_struct` (from VecEAClosure.lean)
- [ ] Prove correctness: for any model M with HasAttainedINF, `v'.holds M atomMap z0 z1 <-> neg v.holds M atomMap z0 z1`
- [ ] Verify `neg_2var_vec_ea_indep` is sorry-free
- [ ] Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: 2

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ModelIndepNegation.lean` -- NEW (~150-250 lines)

**Verification**:
- `lean_verify` confirms `neg_2var_vec_ea_indep` is sorry-free
- `lake build` succeeds

---

### Phase 4: Prop 4.3 Structural Induction (FO -> VVecEA2) [PARTIAL]

*(deviation: altered — restructured as combined Part A/Part B induction on NF depth k. Part A (arity-1 NF to temporal) is sorry-free for all k. Part B (arity-2 existential to temporal) is sorry-free at depth 0 (via nf_2var_exist_depth0_tl) but has sorry at depth k+1 (arity tower: NormalForm sig k 3 requires 3-variable decomposition at depth k). Created NfExistTL.lean (323 lines). Phases 1-3 skipped per contingency — model-independent negation not needed for Part A induction.)*

**Goal**: Prove `fo_to_vvea`: Rabinovich's Prop 4.3, that every `MonadicFormula sig 2` is model-independently equivalent to a VVecEA2 on structures with HasAttainedINF. Uses structural induction on MonadicFormula, which handles all arities simultaneously and avoids the arity tower problem that blocked the prior plan.

**Critical arity analysis**: For the KampPrior application, we need Prop 4.3 for `MonadicFormula sig 1` (1 free variable). The structural induction proceeds:
- `atom p i` (arity n): trivially V-EA at any arity
- `not alpha` (arity n): by IH, alpha maps to VVecEA2, apply `neg_2var_vec_ea_indep` (Phase 3) -- requires arity <= 2
- `and alpha beta` (arity n): by IH, conjunction closure
- `ex alpha` (arity n): alpha has arity n+1, by IH maps to VVecEA2, apply existential closure
- `all alpha`: reduce to `not (ex (not alpha))`

For arity-1 formulas (`MonadicFormula sig 1`), `ex alpha` produces `MonadicFormula sig 2` (arity 2). For arity-2 formulas, `ex alpha` produces arity 3. Rabinovich handles arity >= 3 via Lemma 3.2.2 (reduction to 2-var EA). Since we have VVecEA2 (2-variable), we need to handle the arity-3 case.

**Strategy for arity tower**: Instead of proving Prop 4.3 for all arities, prove it specifically for `MonadicFormula sig 1` with a nested lemma for `MonadicFormula sig 2`. The `ex` case of arity-1 formulas introduces arity-2 formulas, which are directly in VVecEA2 scope. The `ex` case of arity-2 formulas introduces arity-3, but at this point the quantified variable is the THIRD variable -- and the result's free variables are still the original z0, z1 pair. Use Rabinovich's observation: the existential over the third variable, with the first two fixed, reduces to a 2-variable problem by substitution. Specifically, `exists x, psi(z0, z1, x)` is a 2-variable formula in z0, z1.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean`
- [ ] Import ModelIndepNegation.lean, VecEAClosure.lean, MonadicFO.lean, NfToVecEA.lean
- [ ] Implement base VecEA2 constructors for MonadicFormula atoms:
  - `atom p 0` -> VVecEA2 with endpointLeft encoding p at z0
  - `atom p 1` -> VVecEA2 with endpointRight encoding p at z1
  - `lt 0 1` -> trivially-true VVecEA2 (z0 < z1 holds by hypothesis)
  - `lt 1 0` -> empty VVecEA2 (z1 < z0 is false)
- [ ] Implement negation case via `neg_2var_vec_ea_indep` (Phase 3)
- [ ] Implement conjunction case via `VVecEA2.conj_struct` / `VVecEA2.conj_holds_vvecEA2`
- [ ] Implement existential case: for `ex alpha : MonadicFormula sig 2` where alpha has arity 3, use `VBracketFormula.existsBounded_right` or build the existential quantification over the third variable using bracket formula witnesses
- [ ] Implement universal case: `all alpha = not (ex (not alpha))`
- [ ] If Lemma 3.2.2 is needed for arity-3 reduction, implement it as a helper (~100 lines)
- [ ] Wire together as `fo_to_vvea` by mutual structural induction on arity-1 and arity-2 formulas
- [ ] Verify `fo_to_vvea` is sorry-free
- [ ] Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 3

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- NEW (~300-400 lines)

**Verification**:
- `lean_verify` confirms `fo_to_vvea` is sorry-free
- `lake build` succeeds

---

### Phase 5: Theorem 4.4 + KampPrior Sorry Elimination [NOT STARTED]

**Goal**: Connect `fo_to_vvea` (Phase 4) to `nf_characterizable_temporal_prior` and eliminate the sorry at KampPrior.lean:158. The bridge composes: NF -> MonadicFormula (via `nf_to_formula`) -> VVecEA2 (via `fo_to_vvea`) -> Formula (via `VVecEA2.translateLeft`). Correctness follows from composing `nf_to_formula_correct`, `fo_to_vvea` correctness, and `VVecEA2.translateLeft_correct`.

**Tasks**:
- [ ] Add imports for FOToVEA.lean and RabinovichTranslation.lean to KampPrior.lean
- [ ] Build the bridge lemma: for each `sub_nf : NormalForm sig k 2` in the quantifier map:
  - Convert sub_nf to MonadicFormula via `nf_to_formula`
  - Express `exists x, nf_eval_nf M k 2 (x::t) sub_nf` as `eval M env (MonadicFormula.ex (nf_to_formula sub_nf))`
  - Apply `fo_to_vvea` to `MonadicFormula.ex (nf_to_formula sub_nf)` to get VVecEA2
  - Apply `VVecEA2.translateLeft` to get temporal Formula
  - Use `VVecEA2.translateLeft_correct` for the biconditional
- [ ] Fill the `succ k _ih` case of `nf_characterizable_temporal_prior`:
  - Build atom predicate formula (conjunction of atom literals at t, using `nf_depth0_char_formula` pattern)
  - For each quantifier component, get temporal formula via the bridge
  - Combine into a single temporal formula
  - Prove biconditional correctness on Prior structures
- [ ] Verify `nf_characterizable_temporal_prior` is sorry-free
- [ ] Verify `kamp_prior_expressive_completeness` is sorry-free
- [ ] Run `lean_verify` on `completeness_discrete` to check sorry chain reduction
- [ ] Verify `lake build` succeeds
- [ ] Run sorry audit: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry"` -- verify only non-critical-path sorrys remain (EANegation.lean:1084 BracketFormula impossibility)

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- fill sorry at line 158, add imports (~100-200 lines)

**Verification**:
- `lean_verify` confirms `nf_characterizable_temporal_prior` is sorry-free
- `lean_verify` confirms `kamp_prior_expressive_completeness` is sorry-free
- `completeness_discrete` sorry chain reduced (only non-critical-path sorrys remain)
- `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds after each phase (incremental verification)
- [ ] Phase 1: `neg_partialBracketExist_is_vbracket` sorry-free (`lean_verify`)
- [ ] Phase 2: `neg_vecEA2_is_vvecEA2` sorry-free (`lean_verify`)
- [ ] Phase 3: `neg_2var_vec_ea_indep` sorry-free (`lean_verify`)
- [ ] Phase 4: `fo_to_vvea` sorry-free (`lean_verify`)
- [ ] Phase 5: `nf_characterizable_temporal_prior` sorry-free (`lean_verify`)
- [ ] Phase 5: `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- [ ] Phase 5: sorry audit shows only non-critical-path sorrys (EANegation.lean:1084, EANegation.lean:1235 if Phase 1 fails, EndpointNegation.lean:160 if Phase 2 fails)
- [ ] External API unchanged: type signature of `kamp_prior_expressive_completeness` preserved
- [ ] PriorExpressiveness.lean and Completeness.lean still build correctly

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/25_faithful-rabinovich-chain.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- MODIFIED (Phase 1, Cor 5.4 backward fix)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` -- MODIFIED (Phase 2, Lemma 5.1 succ case)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ModelIndepNegation.lean` -- NEW (Phase 3, ~150-250 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- NEW (Phase 4, ~300-400 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFIED (Phase 5, sorry eliminated)

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` restores all modified files. New files (ModelIndepNegation.lean, FOToVEA.lean) can be deleted.
- **Phase 1 blocked** (Cor 5.4 backward): If the bounded F-chain approach fails, Phase 2 can still proceed using the model-DEPENDENT `neg_bounded_exists` (EANegationClosure.lean, sorry-free). This weakens the model-independence of Phase 2's result but does not block the downstream chain, since KampPrior operates on specific Prior structures.
- **Phase 2 blocked** (Lemma 5.1 segment-type decomposition): Fall back to using `neg_vecEA2` (model-dependent, sorry-free) directly. Skip Phase 3 and proceed to Phase 4 using model-dependent negation. The structural induction in Phase 4 would then produce a model-dependent VVecEA2, which suffices for KampPrior.
- **Phase 3 blocked** (model-independent Prop 4.2): If conjunction of model-independent VVecEA2s produces too many disjuncts, use model-dependent `neg_2var_vec_ea` directly in Phase 4 (since the structural induction result is consumed by KampPrior on specific models).
- **Phase 4 blocked** (arity tower in structural induction): If arity-3 V-EA cannot be handled without new infrastructure, restrict `fo_to_vvea` to `MonadicFormula sig 1` only (which only needs arity-1 and arity-2 cases). The `ex` case produces `MonadicFormula sig 2`, which can be handled by `neg_2var_vec_ea` (model-dependent) + existential closure.
- **Phase 5 blocked** (NF-to-MonadicFormula bridge): Build `nf_eval_nf_as_monadic_eval` as a separate lemma showing NF evaluation equals MonadicFormula evaluation. As a last resort, restore KampPrior.lean from git.
