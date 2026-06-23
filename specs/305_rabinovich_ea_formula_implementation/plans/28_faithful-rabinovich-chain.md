# Implementation Plan: Faithful Rabinovich Chain (Task #305 v6)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (Phase 1 completed; sorry-free infrastructure exists for Def 3.1, Lemma 3.2.1, Lemma 3.4, Prop 3.5, Lemma 5.3, Cor 5.4 forward, model-dependent Lemma 5.1/Prop 4.2)
- **Research Inputs**: reports/14_faithfulness-audit.md, reports/24_z-completeness-rabinovich.md
- **Artifacts**: plans/28_faithful-rabinovich-chain.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate all critical-path sorry in the Kamp/Rabinovich chain by restoring faithfulness to Rabinovich 2014's proof architecture. The faithfulness audit (report 14) established that plan v27's "arity tower descent" approach is NOT in Rabinovich -- the arity tower is an artifact of replacing Rabinovich's structural formula induction (Prop 4.3) with NF-depth induction. This plan abandons the NF-depth approach entirely and instead implements Rabinovich's actual chain: fix the segment-type decomposition sorry at EndpointNegation.lean:160, build model-independent Lemma 5.1 and Prop 4.2, implement Prop 4.3 via structural formula induction, and wire the result into KampPrior.lean via Prop 3.5.

Phase 1 (FOToVEA.lean restructuring, completed in plan v26) is preserved as [COMPLETED]. While it narrowed the sorry scope using NF-depth machinery, that machinery is no longer on the critical path -- the faithful Rabinovich chain bypasses NF-depth entirely. The files FOToVEA.lean and NfExistTL.lean remain in the codebase but are superseded by the new chain for the critical path.

### Research Integration

**From reports/14_faithfulness-audit.md**:
- Arity tower is not in Rabinovich; it is an artifact of NF-depth induction
- Three coexisting strategies identified: (A) Rabinovich-faithful in EANegation.lean blocked at beta_0, (B) model-dependent in EANegationClosure.lean sorry-free, (C) NF-depth in FOToVEA.lean with sorry
- Path B (faithful Rabinovich restoration) recommended: fix segment-type decomposition, build model-independent chain, wire into KampPrior
- Key insight: EndpointNegation.lean:160 uses point-type decomposition where Rabinovich uses segment-type decomposition

**From reports/24_z-completeness-rabinovich.md**:
- Path C (Z-transfer) ruled out
- Path A (Rabinovich chain with correct segment-type decomposition) is sole viable route
- 800-1500 lines across 5 sub-tasks estimated

### H3 Reference Grounding Table

| Source (Rabinovich 2014) | Lean Identifier | Status | Phase Target |
|--------------------------|-----------------|--------|-------------|
| Def 3.1 (EA formula) | VecEAFormula, BracketFormula, VecEA2 | sorry-free | -- |
| Def 3.3 (V-EA formula) | VBracketFormula, VVecEA2 | sorry-free | -- |
| Lemma 3.2.1 (conj closure) | conj_to_bracket_exists | sorry-free | -- |
| Lemma 3.2.2 (arity reduction) | (needed in existential case of Prop 4.3) | missing/implicit | Phase 3 |
| Lemma 3.4 (V-EA closure) | conj_holds_vvecEA2 + disj | sorry-free | -- |
| Prop 3.5 (V-EA 1-var -> TL) | translate_correct | sorry-free | Phase 4 (wiring) |
| Notation 5.2 | BracketFormula.holds | sorry-free | -- |
| Lemma 5.3 (all-betas-True) | neg_orderedPointsExist_is_vbracket | sorry-free | -- |
| Cor 5.4 forward | neg_partialBracketExist_sufficient | sorry-free | -- |
| Cor 5.4 backward (n+1) | neg_partialBracketExist_is_vbracket:1235 | SORRY | Phase 2 |
| Lemma 5.1 model-dep | neg_interval_formula | sorry-free | -- |
| Lemma 5.1 model-indep | neg_bracket_is_vbracket:1084 | SORRY (beta_0) | Phase 2 |
| Lemma 5.1 VecEA2-level | neg_vecEA2_is_vvecEA2:160 | SORRY | Phase 2 |
| A_i^-/A_i^+ decomposition | leftPart, rightPart, splitAt_combine | sorry-free | -- |
| Prop 4.2 model-dep | neg_2var_vec_ea | sorry-free | -- |
| Prop 4.2 model-indep | (new) | missing | Phase 3 |
| Prop 4.3 (FO -> V-EA) | (new) | missing | Phase 3 |
| Thm 4.4 (Kamp's theorem) | kamp_prior_expressive_completeness | sorryAx via NF-depth | Phase 4 |

### Rabinovich's Chain (Ground Truth)

```
Def 3.1 -> Lemma 3.2 -> Lemma 3.4 -> Prop 3.5
                                        |
Lemma 5.3 -> Cor 5.4 -> Lemma 5.1 -> Prop 4.2 -> Prop 4.3 -> Thm 4.4
```

### Reusable Infrastructure (all sorry-free)

| File | Lines | Key Identifiers | Role |
|------|-------|-----------------|------|
| VecEAFormula.lean | 769 | VecEA2, VVecEA2, bracket formulas | 2-var EA types and semantics |
| VecEAClosure.lean | 387 | conj_holds_vvecEA2, conj_struct | Conjunction/existential closure for 2-var |
| EANegation.lean | ~1235 | neg_orderedPointsExist_is_vbracket, neg_partialBracketExist_sufficient | Lemma 5.3, Cor 5.4 forward |
| EANegationClosure.lean | ~600 | neg_2var_vec_ea, neg_interval_formula | Prop 4.2 / Lemma 5.1 (model-dependent) |
| VecEATranslation.lean | ~300 | translateLeft, translateLeft_correct | VVecEA2 -> temporal Formula |
| RabinovichTranslation.lean | ~200 | translate_correct | Prop 3.5: V-EA 1-var -> TL |
| PriorINF.lean | ~200 | HasAttainedINF | INF formula infrastructure |

## Goals & Non-Goals

**Goals**:
- Eliminate all critical-path sorry blocking `kamp_prior_expressive_completeness`
- Fix EndpointNegation.lean:160 via Rabinovich's segment-type decomposition
- Build model-independent Lemma 5.1 (negation of VecEA2 -> VVecEA2)
- Build model-independent Prop 4.2 (negation of 2-var V-EA -> V-EA)
- Implement Prop 4.3 via structural formula induction on FO formulas
- Rewire KampPrior.lean to use Prop 4.3 + Prop 3.5 instead of NF-depth chain
- Achieve sorry-free `kamp_prior_expressive_completeness`
- Maintain `lake build` success after every phase

**Non-Goals**:
- Maintaining the NF-depth chain (FOToVEA.lean/NfExistTL.lean) as the critical path -- these files remain but are bypassed
- Building generalized arity decomposition (Rabinovich avoids it via Lemma 3.2.2)
- Addressing the Stavi chain (confirmed dead)
- Fixing sorry in files not on the Rabinovich chain critical path

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Segment-type decomposition for beta_0(r0) case is more complex than expected | H | M | The model-dependent version (EANegationClosure.lean) is sorry-free and demonstrates the mathematical pattern. The segment-type approach splits on where the first segment type fails rather than the first point, which avoids the witness-shifting problem. Follow Rabinovich's proof structure exactly. |
| Cor 5.4 backward (n+1) is deeply coupled to the beta_0 fix | M | M | If the EANegation.lean:1235 sorry requires the same segment-type decomposition as EndpointNegation.lean:160, fix them together in Phase 2. The F-chain reduction should be unblocked once the base decomposition is corrected. |
| Lemma 3.2.2 (arity reduction to 2-var) may not exist as a standalone lemma | M | L | Check if VecEADecomp.lean or VecEAClosure.lean already contains this implicitly. If not, build it as part of Phase 3 -- it projects each EA formula onto pairs of variables and forms a conjunction. |
| Structural formula induction on MonadicFormula for Prop 4.3 may require additional closure lemmas | M | L | VecEAClosure.lean already has conjunction closure (Lemma 3.4). The only cases are atomic (trivial), disjunction (Lemma 3.4 disjunction), negation (Prop 4.2), existential (Lemma 3.4 existential + Lemma 3.2.2 arity reduction). All building blocks exist or are built in Phase 3. |
| Rewiring KampPrior.lean requires rethinking the induction structure | M | M | KampPrior currently uses NF -> temporal via nf_characterizable_temporal_prior. The new chain goes MonadicFormula -> V-EA (Prop 4.3) -> temporal (Prop 3.5). The NF detour via doets_lemma_1_1 and nf_exists_unique remains as glue -- NF is used to show completeness of the V-EA characterization. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | -- |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phase 1 is already completed. Phase 2 has no dependencies on Phase 1 (it works on EndpointNegation.lean/EANegation.lean, independent files). Phase 3 depends on Phase 2 (needs model-independent Lemma 5.1). Phase 4 depends on Phase 3.

---

### Phase 1: FOToVEA.lean Core -- Restructure Sorry Scope [COMPLETED]

*(Completed in plan v26. Preserved verbatim. Not on critical path for Path B but useful scaffolding.)*

**Goal**: Restructure FOToVEA.lean to narrow the sorry from `fo_to_temporal_correct` (blanket over all MonadicFormula sig 1) to `nf_exist_to_temporal_aux` (localized to depth-(k+1) arity-2 NF existentials only).

**Tasks**:
- [x] **Task 1.1**: Delete `fo_to_temporal` and `fo_to_temporal_correct`
- [x] **Task 1.2**: Add `nf_exist_to_temporal_aux` with localized sorry for NF existentials
- [x] **Task 1.3**: Restructure `nf_exist_to_temporal` to use `Classical.choose` on aux theorem
- [x] **Task 1.4**: Restructure `nf_exist_to_temporal_correct` as direct `choose_spec`
- [x] **Task 1.5**: Remove 5 unnecessary imports
- [x] **Task 1.6**: Update NfExistTL.lean comments for NF-direct architecture
- [x] **Task 1.7**: Update KampPrior.lean documentation
- [x] **Task 1.8**: Verify `lake build` succeeds (1701 jobs)

**Timing**: 2 hours (actual)

**Depends on**: none

**Completed**: 2026-06-23

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- restructured (149 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfExistTL.lean` -- comments updated
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- documentation updated

---

### Phase 2: Fix Segment-Type Decomposition -- EndpointNegation + EANegation Sorry [BLOCKED]

**Goal**: Fix the three sorry stubs in the Rabinovich-faithful negation chain by replacing the incorrect point-type decomposition with Rabinovich's segment-type decomposition. This completes model-independent Lemma 5.1 at the VecEA2 level and unblocks the Cor 5.4 backward direction.

**BLOCKER** (Phase 2):
- **What failed**: All three sorry (EndpointNegation.lean:160, EANegation.lean:1084, EANegation.lean:1235) share the same structural obstruction documented in the inline code analysis. The segment-type decomposition proposed in this plan encounters the same forward-direction obstruction as the point-type decomposition.
- **What was tried**:
  1. Rabinovich Case 1/2/3 decomposition using segmentTypes[0] (segment-type) instead of pointTypes[0] (point-type) at VecEA2 level. Obstruction: a VVecEA2 disjunct asserting "seg0.neg holds at some y" does not prevent the original bracket from holding with its first witness x_0 < y, because seg0 holds on (z_0, x_0) when x_0 < y.
  2. F-chain reduction for Cor 5.4 backward direction. Obstruction: F_0(x_0) does not guarantee (a) segmentTypes[0] on (z_0, x_0), nor (b) that Until witnesses stay within (z_0, z_1). The contrapositive orderedPointsExist 1 fChainPred -> partialBracketExist fails.
  3. Adding CaseE disjunct (alpha_0 AND beta_0 at first witness). Obstruction: forward direction fails because IH gives neg tail.holds at (r_0, z_1) but different x_0 > r_0 might make tail.holds(x_0, z_1) succeed.
- **Why stuck**: The model-independent biconditional at BracketFormula level requires expressing "for ALL possible witness positions x_0, the bracket fails" as a FINITE V-bracket formula. Different models have different witness positions, and the negation condition at each x_0 yields a different sub-problem. Rabinovich's proof works at the FOMLO level where universal quantification is available. Our bracket/VecEA2 types only have existential structure (exists witnesses). The V-bracket closure theorems cannot express the required universal quantification. This is an inherent expressiveness limitation of BracketFormula/VBracketFormula/VVecEA2.
- **What is needed**: Either (a) extend the formula types with universal quantification capabilities, or (b) reformulate the critical path to bypass model-independent biconditional negation entirely. Option (b) is recommended: build Prop 4.2/4.3 using a different route. The model-dependent versions (neg_2var_vec_ea, neg_vecEA2 in EANegationClosure.lean) are sorry-free. Combined with Classical.choice at the Prop 4.3 level, it may be possible to construct the model-independent V-EA via a non-constructive argument that avoids the bracket-level biconditional.
- **Critical path impact**: These three sorry are NOT on the critical path to kamp_prior_expressive_completeness. The code comments in all three locations explicitly state "Does NOT block completeness." The plan's dependency Phase 3 -> Phase 2 should be reconsidered: Phase 3 may be buildable using model-dependent Prop 4.2 + a non-constructive lifting argument.

**Tasks**:
- [x] **Task 2.1**: Analyze the sorry at EndpointNegation.lean:160 (`neg_vecEA2_is_vvecEA2` succ case) *(deviation: altered -- analysis confirmed the structural obstruction is fundamental, not fixable by segment-type decomposition)*
  - Read the current proof state and understand why the point-type decomposition fails
  - Map to Rabinovich's segment-type approach: split on which segment type (interval between consecutive witnesses) first fails, not on which point first satisfies a predicate
  - The key insight: when negating VecEA2 (n+1), Rabinovich decomposes by finding the first segment A_i where the interval condition fails, splitting into A_i^- (left of failure) and A_i^+ (right of failure), each reducing witness count
  - **Finding**: Segment-type decomposition has the SAME forward-direction obstruction. A VVecEA2 disjunct asserting "seg0 fails at y" cannot prevent the bracket from holding with first witness x_0 < y. The model-independent biconditional requires universal quantification over witness positions, which V-bracket formulas cannot express.
- [ ] **Task 2.2**: Implement segment-type decomposition in EndpointNegation.lean *(deviation: skipped -- obstruction confirmed unfixable with current infrastructure)*
- [ ] **Task 2.3**: Fix EANegation.lean:1084 (`neg_bracket_is_vbracket` beta_0 case) *(deviation: skipped -- same obstruction)*
- [ ] **Task 2.4**: Fix EANegation.lean:1235 (`neg_partialBracketExist_is_vbracket` backward n+1) *(deviation: skipped -- F-chain contrapositive fails: orderedPointsExist 1 fChainPred does not imply partialBracketExist because (a) seg0 on (z_0, x_0) not guaranteed, (b) Until witnesses may escape interval bounds)*
- [ ] **Task 2.5**: Verify all three sorry are eliminated *(deviation: skipped -- sorry remain)*
- [ ] **Task 2.6**: Verify `lake build` succeeds *(deviation: deferred -- no code changes made)*

**Timing**: 3 hours

**Depends on**: none (uses existing EANegation.lean and EndpointNegation.lean infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` -- fix sorry at line 160 (~150-200 lines added)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- fix sorry at lines 1084, 1235 (~160-240 lines added)

**Verification**:
- `neg_vecEA2_is_vvecEA2` sorry-free (`lean_verify`)
- `neg_bracket_is_vbracket` sorry-free (`lean_verify`)
- `neg_partialBracketExist_is_vbracket` sorry-free (`lean_verify`)
- `lake build` succeeds

---

### Phase 3: Model-Independent Prop 4.2 + Prop 4.3 [NOT STARTED]

**Goal**: Build model-independent Prop 4.2 (negation of 2-var V-EA yields V-EA) using the fixed model-independent Lemma 5.1 from Phase 2, then build Prop 4.3 (every FO formula is equivalent to a V-EA formula) via structural formula induction on MonadicFormula. This is the core of Rabinovich's proof that bypasses NF-depth entirely.

**Tasks**:
- [ ] **Task 3.1**: Build model-independent Prop 4.2
  - Create or extend EANegationClosure.lean (or a new file `Prop42ModelIndep.lean`)
  - The model-dependent `neg_2var_vec_ea` already exists and is sorry-free
  - The model-independent version uses the now sorry-free `neg_vecEA2_is_vvecEA2` from Phase 2 instead of model-dependent case analysis
  - Type signature: given `v : VVecEA2` and Prior structure hypotheses, produce `v' : VVecEA2` such that `v'.holds M z0 z1 <-> not (v.holds M z0 z1)` for ALL Prior structures M
  - Target: ~100-150 lines
- [ ] **Task 3.2**: Check if Lemma 3.2.2 (arity reduction to 2-var) exists or needs building
  - Search for existing declarations that reduce m-variable EA formulas to conjunctions of 2-variable EA formulas
  - If implicit in VecEADecomp or VecEAClosure, identify and reference it
  - If missing, build it: an m-variable EA formula can be expressed as a conjunction of (m choose 2) pairwise 2-variable EA conditions
  - Target: ~50-100 lines if needed
- [ ] **Task 3.3**: Implement Prop 4.3 via structural formula induction
  - Create `Prop43.lean` (or extend an existing file)
  - Prove by structural induction on `MonadicFormula sig n`:
    - **Atomic** (`pred p i`): trivially an EA formula -- a single predicate is a VecEA2
    - **Negation** (`neg phi`): by IH, phi is V-EA. Apply Prop 4.2 (Task 3.1) to get negation as V-EA
    - **Disjunction** (`disj phi psi`): by IH, both are V-EA. Apply Lemma 3.4 disjunction closure (exists in VecEAClosure.lean)
    - **Existential** (`ex phi`): by IH, phi at arity (n+1) is V-EA. Apply Lemma 3.2.2 (arity reduction, Task 3.2) to reduce to 2-var, then Lemma 3.4 existential closure
  - Note: The induction is on the formula structure, NOT on NF depth. This is the key difference from the superseded approach.
  - Type signature: `fo_to_vea : MonadicFormula sig n -> VVecEA2` (or appropriate generalization to n variables)
  - Correctness: `fo_to_vea_correct : v.holds M env <-> eval M env phi` for all Prior structures M
  - Target: ~200-300 lines
- [ ] **Task 3.4**: Verify Prop 4.2 and Prop 4.3 are sorry-free
  - `lean_verify` on model-independent Prop 4.2
  - `lean_verify` on Prop 4.3
- [ ] **Task 3.5**: Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 2 (needs sorry-free model-independent Lemma 5.1 for Prop 4.2)

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42ModelIndep.lean` -- NEW or extension of EANegationClosure.lean (~100-150 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` -- NEW (~200-300 lines, structural formula induction)

**Verification**:
- Model-independent Prop 4.2 sorry-free (`lean_verify`)
- Prop 4.3 (`fo_to_vea_correct`) sorry-free (`lean_verify`)
- `lake build` succeeds

---

### Phase 4: Wire into KampPrior.lean + Final Verification [NOT STARTED]

**Goal**: Replace the NF-depth chain in KampPrior.lean with Rabinovich's faithful chain: Prop 4.3 (FO -> V-EA) composed with Prop 3.5 (V-EA 1-var -> TL). This eliminates the sorry at `nf_exist_to_temporal_aux` from the critical path. Verify the full chain from `kamp_prior_expressive_completeness` through `completeness_discrete` is sorry-free. Run full sorry audit.

**Tasks**:
- [ ] **Task 4.1**: Restructure `kamp_prior_expressive_completeness` in KampPrior.lean
  - The current proof goes: MonadicFormula -> NF -> temporal (via nf_characterizable_temporal_prior -> NfExistTL -> FOToVEA)
  - The new proof goes: MonadicFormula -> V-EA (Prop 4.3) -> temporal (Prop 3.5)
  - Specifically: given `psi : MonadicFormula sig 1`, apply `fo_to_vea` to get `v : VVecEA2`, then apply `translate_correct` (Prop 3.5) to get temporal Formula
  - The NF infrastructure (doets_lemma_1_1, nf_exists_unique) may still be used to establish that the V-EA characterization is complete, or can be bypassed entirely
  - Add imports for Prop43.lean and ensure RabinovichTranslation is imported
- [ ] **Task 4.2**: Update `nf_characterizable_temporal_prior` to use Prop 4.3 chain
  - Option A: Replace the sorry-bearing succ case with: convert NF to MonadicFormula (via `nf_to_formula`), apply Prop 4.3, apply Prop 3.5
  - Option B: Bypass `nf_characterizable_temporal_prior` entirely in `kamp_prior_expressive_completeness` and use Prop 4.3 directly on the MonadicFormula
  - Choose whichever is cleaner and requires less restructuring
- [ ] **Task 4.3**: Verify `kamp_prior_expressive_completeness` is sorry-free (`lean_verify`)
- [ ] **Task 4.4**: Verify chain sorry-freedom downstream:
  - `completeness_discrete` or whatever uses `kamp_prior_expressive_completeness`
  - Check for remaining sorry between `kamp_prior_expressive_completeness` and `completeness_discrete`
- [ ] **Task 4.5**: Run `lake build` (full project, ~1700 jobs)
- [ ] **Task 4.6**: Run sorry audit on the Kamp directory:
  ```
  grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry"
  ```
  Expected: ZERO sorry on the critical path. The only remaining sorry should be the FOToVEA.lean:118 sorry which is now off the critical path (NF-depth chain bypassed).
- [ ] **Task 4.7**: Verify external API preserved: type signatures of `kamp_prior_expressive_completeness` and `completeness_discrete` unchanged
- [ ] **Task 4.8**: Document final sorry inventory in orchestrator handoff

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- rewire proof (~50-100 lines changed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- update documentation to note it is no longer on critical path

**Verification**:
- `lake build` succeeds (all ~1700 jobs)
- `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- `completeness_discrete` sorry chain fully resolved or reduced
- Only off-critical-path sorry remain (FOToVEA.lean:118 NF-depth sorry)
- External API unchanged

## Testing & Validation

- [x] Phase 1: atom/conjunction/negation cases sorry-free, existential sorry localized (DONE)
- [ ] Phase 2: `neg_vecEA2_is_vvecEA2` sorry-free (`lean_verify`)
- [ ] Phase 2: `neg_bracket_is_vbracket` sorry-free (`lean_verify`)
- [ ] Phase 2: `neg_partialBracketExist_is_vbracket` sorry-free (`lean_verify`)
- [ ] Phase 2: `lake build` succeeds
- [ ] Phase 3: model-independent Prop 4.2 sorry-free (`lean_verify`)
- [ ] Phase 3: `fo_to_vea_correct` (Prop 4.3) sorry-free (`lean_verify`)
- [ ] Phase 3: `lake build` succeeds
- [ ] Phase 4: `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- [ ] Phase 4: sorry audit shows zero critical-path sorry
- [ ] Phase 4: External API unchanged
- [ ] Phase 4: PriorExpressiveness.lean and Completeness.lean still build correctly

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/28_faithful-rabinovich-chain.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` -- MODIFIED (sorry at line 160 eliminated)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- MODIFIED (sorry at lines 1084, 1235 eliminated)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42ModelIndep.lean` -- NEW (~100-150 lines, model-independent Prop 4.2)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` -- NEW (~200-300 lines, structural formula induction)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFIED (rewired to use Prop 4.3 + Prop 3.5)

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` restores all files. Delete new files `Prop42ModelIndep.lean` and `Prop43.lean`.
- **Phase 2 blocked** (segment-type decomposition harder than expected): The model-dependent chain in EANegationClosure.lean remains sorry-free. If segment-type decomposition cannot be implemented, fall back to lifting the model-dependent Prop 4.2 into a model-independent version via a different route (e.g., constructing the VVecEA2 witness using Classical.choice over models).
- **Phase 3 blocked** (structural induction on MonadicFormula has unexpected cases): MonadicFormula is a simple inductive type with pred, neg, disj, ex constructors. The induction should be straightforward. If the existential case is complex due to arity handling, introduce an intermediate lemma that handles arity reduction separately.
- **Phase 4 blocked** (composition mismatch between Prop 4.3 output and Prop 3.5 input): The types should align since Prop 4.3 produces VVecEA2 and Prop 3.5 translates VVecEA2 to temporal Formula. If there is a mismatch in the number of free variables (Prop 4.3 at arity n vs Prop 3.5 at arity 1), use Lemma 3.2.2 to reduce to 2-var first, then Prop 3.5.
- **Partial value**: Even if only Phase 2 completes, the three sorry in EndpointNegation/EANegation are eliminated, which has independent value for the codebase.
