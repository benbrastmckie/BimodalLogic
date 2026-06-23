# Implementation Plan: Task #305

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (all required sorry-free infrastructure exists)
- **Research Inputs**: reports/23_restructure-research.md
- **Artifacts**: plans/24_faithful-restructure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Full restructuring of the Kamp theorem proof to follow Rabinovich's faithful proof chain: Lemma 5.1 -> Prop 4.2 -> Prop 4.3 -> Theorem 4.4. The current codebase uses NF-depth mutual induction via ~5,900 lines of bypass infrastructure (KampBypass, KampMutualInduction, NfCharFormula, PriorComposition sorry stubs) that deviates from Rabinovich and carries 5 sorry sites on the critical path. The restructuring archives bypass files to Boneyard, implements the faithful Rabinovich chain in 4 new files (~800-1200 lines), and updates KampPrior.lean to use the new proof. Net result: ~4,700 fewer lines, 5 fewer sorry sites on the critical path, and a proof that matches the literature step-by-step.

### Research Integration

Key findings from report 23 (restructure-research.md):
- VecEA2 type already has `endpointLeft` field matching Rabinovich's alpha_0 at z_0 -- no type changes needed
- The beta_0(r0) impossibility at BracketFormula level (EANegation.lean:1084) is bypassed entirely by working at VecEA2 level where alpha_0 is at the fixed endpoint
- Rabinovich uses two induction principles: (1) induction on witness count n for Lemma 5.1, and (2) structural induction on FO formulas for Prop 4.3 -- neither involves NF depth
- Prior structures trivially satisfy HasAttainedINF (already proved sorry-free as `prior_hasAttainedINF`)
- The model-dependent negation closure (EANegationClosure.lean) is entirely sorry-free and provides the case-analysis template for the model-independent version

### Prior Plan Reference

Plan v23 (faithful-beta0-fix.md) attempted to fix the beta_0(r0) sorry at the BracketFormula level. After exhaustive analysis of three approaches, it concluded the BracketFormula-level model-independent biconditional is unprovable -- alpha_0 at an interior existential witness creates model-dependent recursion that no finite V-bracket can handle. The plan correctly identified that the fix requires working at the VecEA2 level (endpoint convention). This restructuring plan implements that conclusion as a full chain rather than a targeted fix.

Lessons learned from prior plan:
- Effort calibration: the prior plan estimated 4 hours for a single-file modification but found the beta_0(r0) issue required architectural change. This plan estimates 12 hours for the full restructuring.
- The detailed impossibility analysis in the prior plan confirms that the BracketFormula-level sorry at EANegation.lean:1084 should remain as documented (it is genuinely unprovable at that level and unused downstream).
- Risk: Case 2 of Lemma 5.1 (seg holds everywhere, reducing to Cor 5.4) was identified as the highest-risk step.

### Roadmap Alignment

This plan advances the following ROADMAP.md items:
- **Critical path**: Closing the sorry chain through `existPart_succ_n1_bypass` k>0 case -- by replacing the KampBypass infrastructure entirely with the faithful Rabinovich chain, this eliminates the bypass-rooted sorry chain
- **Discrete completeness**: Moving `kamp_prior_expressive_completeness` to a sorry-free Rabinovich-based proof directly advances sorry-free `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Archive bypass infrastructure (8 files, ~5,900 lines) to Boneyard
- Implement VecEA2-level Lemma 5.1 (`neg_vecEA2_is_vvecEA2`) following Rabinovich pp. 7-11
- Implement model-independent Prop 4.2 (`neg_vvecEA2_model_indep`) using Lemma 5.1
- Implement Prop 4.3 structural induction (`fo_to_vea`) for 1-free-variable FO formulas
- Implement Theorem 4.4 (`kamp_theorem_rabinovich`) combining Prop 4.3 + Prop 3.5
- Update KampPrior.lean to use the Rabinovich chain instead of mutual induction
- Fix Cor 5.4 backward direction sorry (EANegation.lean:1235) using VecEA2-level Lemma 5.1
- Achieve `lake build` success at every phase
- Eliminate 5 of 6 sorry sites from the critical path

**Non-Goals**:
- Changing VecEA2, BracketFormula, or VBracketFormula type definitions (they already match Rabinovich)
- Fixing the BracketFormula-level sorry at EANegation.lean:1084 (proven unprovable)
- Implementing the full Lemma 3.2.2 (general free-variable reduction) -- the 1-free-var case does not need it
- Modifying any sorry-free KEEP files (EANegationClosure, VecEAClosure, PriorINF, etc.)
- Addressing Stavi expressive completeness sorries (separate sorry chain)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 5.1 Case 2 (seg everywhere -> Cor 5.4) requires complex F-chain reduction | H | M | The model-dependent `neg_interval_formula` in EANegationClosure.lean provides a sorry-free template for the case analysis structure. The forward direction of Cor 5.4 is already proved; only the backward direction needs VecEA2-level proof. |
| Lemma 5.1 Case 3 (interval splitting) index arithmetic for combining sub-bracket negations | M | M | leftPart/rightPart/splitAt_combine infrastructure already exists sorry-free in VecEAFormula.lean. Use the existing splitting algebra directly. |
| Prop 4.3 negation case may need free-variable reduction beyond 2-var scope | M | L | For 1-free-variable Kamp theorem, each existential introduces one new variable pairing with the single free variable, staying within the 2-var scope handled by Prop 4.2. The general case (Lemma 3.2.2) is not needed. |
| KampForward.lean imports KampBypass -- archiving KampBypass may break KampForward | H | M | Check whether KampForward actually uses any KampBypass definitions (preliminary grep shows only a comment reference). Remove the import if unused, or move needed definitions to a shared file. |
| GeneralExistPart.lean imports KampBypass with no actual usage | L | H | Remove the unused import during cleanup. |
| Archival breaks `lake build` due to transitive import chains | H | L | Archive incrementally: move files to Boneyard one-at-a-time, remove imports from remaining files, verify `lake build` after each step. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 2 |
| 5 | 4 | 3 |
| 6 | 5 | 4 |

Phases are strictly sequential because each builds on the previous: archival first, then the Rabinovich chain bottom-up, then integration, then cleanup.

---

### Phase 0: Archive Bypass Infrastructure to Boneyard [COMPLETED]

**Goal**: Move the 8 files that will be replaced by the Rabinovich chain to `Boneyard/`, update imports in remaining files so `lake build` passes.

**Tasks**:
- [ ] Move KampBypassCore.lean to Boneyard/KampBypassCore.lean (681 lines)
- [ ] Move KampBypassEqCase.lean to Boneyard/KampBypassEqCase.lean (891 lines)
- [ ] Move KampBypassBridge.lean to Boneyard/KampBypassBridge.lean (545 lines)
- [ ] Move KampBypassUntil.lean to Boneyard/KampBypassUntil.lean (979 lines)
- [ ] Move KampBypassSince.lean to Boneyard/KampBypassSince.lean (1307 lines)
- [ ] Move KampBypass.lean to Boneyard/KampBypass.lean (889 lines)
- [ ] Move KampMutualInduction.lean to Boneyard/KampMutualInduction.lean (446 lines)
- [ ] Move NfCharFormula.lean to Boneyard/NfCharFormula.lean (755 lines)
- [ ] Move PriorComposition.lean sorry stubs to Boneyard/ (keep sorry-free infrastructure if any is used elsewhere; otherwise move entire file)
- [x] **Task 0.10**: Remove KampBypass import from KampForward.lean *(deviation: altered -- KampForward archived to Boneyard since it uses ssn_xt_compatible from KampBypassCore and nothing in new chain imports it)*
- [x] **Task 0.11**: Remove KampBypass import from GeneralExistPart.lean *(deviation: altered -- GeneralExistPart archived to Boneyard since nothing in new chain imports it)*
- [ ] Update KampPrior.lean imports: remove `KampMutualInduction` and `NfCharFormula` imports, replace proof body with `sorry` placeholder (to be filled in Phase 4)
- [ ] Verify `lake build` succeeds after all archival

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` -- destination for archived files
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampForward.lean` -- remove KampBypass import
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- remove KampBypass import
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- replace imports and proof body

**Verification**:
- All 8 files moved to Boneyard/
- `lake build` succeeds
- `grep -rn "KampBypass\|KampMutualInduction\|NfCharFormula" Theories/ --include="*.lean" | grep -v Boneyard` shows only KampPrior.lean (placeholder) and comments

---

### Phase 1: VecEA2-Level Lemma 5.1 (Endpoint Bracket Negation) [NOT STARTED]

**Goal**: Implement `neg_vecEA2_is_vvecEA2` in a new file `EndpointNegation.lean`, proving that the negation of a VecEA2 formula is model-independently equivalent to a VVecEA2. This is the core new theorem following Rabinovich pp. 7-11.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean`
- [ ] Define the theorem signature:
  ```
  theorem neg_vecEA2_is_vvecEA2 (n : Nat) (vea : VecEA2 n) :
      exists (v : VVecEA2),
      forall {sig} (M : ...) (atomMap : ...) (h_INF : HasAttainedINF M atomMap)
        (z0 z1 : M.carrier), z0 < z1 ->
        (v.holds M atomMap z0 z1 <-> not (vea.holds M atomMap z0 z1))
  ```
- [ ] Implement base case (n = 0): neg (alpha_0(z_0) AND forall y in (z_0,z_1), seg_0(y)) -- decompose into two VVecEA2 disjuncts via de Morgan
- [ ] Implement inductive step Case 1: neg alpha_0(z_0) -- trivial VVecEA2 disjunct with endpointLeft = alpha_0.neg
- [ ] Implement inductive step Case 2: alpha_0(z_0) AND seg_0 everywhere -- reduces to Cor 5.4 partial bracket negation on rightPart with n witnesses, apply IH
- [ ] Implement inductive step Case 3: alpha_0(z_0) AND seg_0 fails at some point -- use HasAttainedINF to find first failure, split bracket via leftPart/rightPart, apply IH on each half (fewer witnesses)
- [ ] Prove both directions of the biconditional for each case
- [ ] Also fix Cor 5.4 backward direction (EANegation.lean:1235) using the VecEA2-level result
- [ ] Verify `lake build` succeeds with EndpointNegation.lean

**Timing**: 4 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` -- NEW (~300-400 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- fix Cor 5.4 backward sorry at line 1235

**Verification**:
- `neg_vecEA2_is_vvecEA2` compiles sorry-free
- `lean_verify` on `neg_vecEA2_is_vvecEA2` reports no sorryAx
- `lake build` succeeds
- Cor 5.4 backward sorry (EANegation.lean:1235) eliminated

---

### Phase 2: Model-Independent Prop 4.2 (Negation of V-EA) [NOT STARTED]

**Goal**: Implement `neg_vvecEA2_model_indep` in a new file `ModelIndepNegation.lean`, proving that the negation of a VVecEA2 formula is model-independently equivalent to a VVecEA2. This follows Rabinovich Prop 4.2 via de Morgan + Lemma 5.1 + conjunction closure.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ModelIndepNegation.lean`
- [ ] Import EndpointNegation.lean, VecEAClosure.lean
- [ ] Implement single-conjunct case: neg VecEA2 -> VVecEA2 (directly from Lemma 5.1)
- [ ] Implement de Morgan decomposition: neg (VVecEA2) = neg (disj of VecEA2) = conj of (neg VecEA2) = conj of VVecEA2
- [ ] Use `VVecEA2.conj_holds_vvecEA2` from VecEAClosure.lean for conjunction closure
- [ ] Prove model-independent biconditional
- [ ] Verify `lake build` succeeds

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ModelIndepNegation.lean` -- NEW (~100-150 lines)

**Verification**:
- `neg_vvecEA2_model_indep` compiles sorry-free
- `lean_verify` reports no sorryAx
- `lake build` succeeds

---

### Phase 3: Prop 4.3 Structural Induction (FO to V-EA) [NOT STARTED]

**Goal**: Implement `fo_to_vea` in a new file `FOToVEA.lean`, proving that every 1-free-variable FO formula is equivalent to a V-EA formula over Dedekind complete chains. This follows Rabinovich Prop 4.3 via structural induction on FO formulas.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean`
- [ ] Import ModelIndepNegation.lean, VecEAClosure.lean, NfToVecEA.lean
- [ ] Implement the atomic case: use NfToVecEA bridge (depth-0 NF to VecEA2) -- atomic predicates P(x) and order atoms x < y are trivially EA formulas
- [ ] Implement the disjunction case: if phi equiv VVecEA2 and psi equiv VVecEA2, then (phi OR psi) equiv VVecEA2 by closure under disjunction (Lemma 3.4 / VecEAClosure)
- [ ] Implement the negation case: if phi equiv VVecEA2 (with at most 2 free vars), then neg phi equiv VVecEA2 by Prop 4.2 (ModelIndepNegation)
- [ ] Implement the existential case: if phi equiv VVecEA2, then (exists x, phi) equiv VVecEA2 by Lemma 3.4 closure under existential quantification (VecEAClosure)
- [ ] Handle the free-variable bookkeeping: for the 1-free-variable target, each existential introduces a variable pairing with the single free variable, staying within 2-var scope
- [ ] Prove model-independent equivalence
- [ ] Verify `lake build` succeeds

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- NEW (~200-300 lines)

**Verification**:
- `fo_to_vea` compiles sorry-free
- `lean_verify` reports no sorryAx
- `lake build` succeeds

---

### Phase 4: Theorem 4.4 and KampPrior Update [NOT STARTED]

**Goal**: Implement `kamp_theorem_rabinovich` in a new file `KampRabinovich.lean` (Prop 4.3 + Prop 3.5), then update KampPrior.lean to use the Rabinovich chain instead of the mutual induction pathway.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampRabinovich.lean`
- [ ] Import FOToVEA.lean, RabinovichTranslation.lean
- [ ] Implement `kamp_theorem_rabinovich`: for any 1-free-variable FO formula phi, (1) apply fo_to_vea to get VVecEA2 equivalent, (2) apply Prop 3.5 (ExistsForallSpec.translate_correct from RabinovichTranslation.lean) to get TL(U,S) equivalent
- [ ] Update KampPrior.lean imports: replace `NfCharFormula` and `KampMutualInduction` with `KampRabinovich`
- [ ] Rewrite `kamp_prior_expressive_completeness` proof body to use `kamp_theorem_rabinovich` instantiated with `prior_hasAttainedINF` (the Prior -> HasAttainedINF proof)
- [ ] Preserve the theorem's type signature exactly (external API unchanged)
- [ ] Verify `lake build` succeeds

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampRabinovich.lean` -- NEW (~50-100 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFY (replace imports and proof body)

**Verification**:
- `kamp_theorem_rabinovich` compiles sorry-free
- `kamp_prior_expressive_completeness` compiles sorry-free via new chain
- `lean_verify` on `kamp_prior_expressive_completeness` reports no sorryAx
- `lake build` succeeds
- PriorExpressiveness.lean (which imports KampPrior) still builds

---

### Phase 5: Cleanup and Final Verification [NOT STARTED]

**Goal**: Comprehensive sorry audit, remove dead imports, verify the complete build, and confirm the sorry reduction from 6 to 1 on the critical path.

**Tasks**:
- [ ] Run `grep -rn "sorry" Theories/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry"` to audit all remaining sorry sites
- [ ] Verify the EANegation.lean:1084 sorry remains with its impossibility documentation (unchanged, unused downstream)
- [ ] Verify the EANegation.lean:1235 sorry was eliminated in Phase 1
- [ ] Verify PriorComposition.lean sorry stubs are in Boneyard (eliminated by archival)
- [ ] Verify NfCharFormula.lean sorry stubs are in Boneyard (eliminated by archival)
- [ ] Remove any unused imports from files that previously depended on bypass infrastructure
- [ ] Run full `lake build` and verify zero errors
- [ ] Run `lean_verify` on `completeness_discrete` to check the sorry chain reduction
- [ ] Verify that the sorry chain from `completeness_discrete` through `kamp_prior_expressive_completeness` no longer includes `existPart_succ_n1_bypass`

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- Various files -- dead import removal
- No new files created

**Verification**:
- `lake build` succeeds with zero errors
- Sorry audit shows 1 sorry in EANegation.lean (documented impossibility, unused downstream)
- `lean_verify` on key theorems reports expected axiom usage
- Net line count: ~800-1200 lines added (4 new files), ~5,900 lines archived

## Testing & Validation

- [ ] `lake build` succeeds after each phase (incremental verification)
- [ ] `neg_vecEA2_is_vvecEA2` (Lemma 5.1) is sorry-free (`lean_verify`)
- [ ] `neg_vvecEA2_model_indep` (Prop 4.2) is sorry-free (`lean_verify`)
- [ ] `fo_to_vea` (Prop 4.3) is sorry-free (`lean_verify`)
- [ ] `kamp_theorem_rabinovich` (Theorem 4.4) is sorry-free (`lean_verify`)
- [ ] `kamp_prior_expressive_completeness` is sorry-free (`lean_verify`)
- [ ] Sorry count on critical path reduced from 6 to 1
- [ ] External API (type signature of `kamp_prior_expressive_completeness`) unchanged
- [ ] PriorExpressiveness.lean and Completeness.lean still build correctly

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/24_faithful-restructure.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` -- NEW (Lemma 5.1)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ModelIndepNegation.lean` -- NEW (Prop 4.2)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- NEW (Prop 4.3)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampRabinovich.lean` -- NEW (Theorem 4.4)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFIED (use Rabinovich chain)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- MODIFIED (Cor 5.4 fix)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` -- 8+ archived files

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` restores all files. Boneyard additions are safe (no code depends on them).
- **Partial rollback after Phase 0**: Restore archived files from Boneyard by moving them back. The archival is a rename operation, fully reversible.
- **Phase 1 blocked**: If Lemma 5.1 VecEA2-level proof encounters an unforeseen obstruction, the model-dependent version (EANegationClosure.lean) remains sorry-free and provides a fallback. Document the obstruction, restore bypass files from Boneyard, and the codebase returns to its prior state with no regression.
- **Phase 3 blocked**: If structural induction on FO formulas requires the full Lemma 3.2.2 (general free-variable reduction), implement a restricted version for the 1-free-variable case or restore the mutual induction pathway from Boneyard.
