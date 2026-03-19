# Implementation Plan: Task #1003 (v2)

- **Task**: 1003 - Implement Sorry-Free Multi-Family Modal Coherence
- **Status**: [PARTIAL]
- **Effort**: 10 hours
- **Dependencies**: Task #1002 (completed design document, now OUTDATED)
- **Research Inputs**: specs/1003_implement_modal_coherence/reports/03_blocker-analysis.md
- **Previous Plan (OBSOLETE)**: specs/1003_implement_modal_coherence/plans/01_modal-coherence-plan.md
- **Artifacts**: plans/02_multi-family-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Implement sorry-free proofs of `modal_forward` and `modal_backward` for a multi-family BFMCS over CanonicalMCS. The previous plan (v1) was based on the flawed assumption that the singleton bundle `{canonicalMCSBFMCS}` could be modally saturated. The blocker analysis (report 03) proves this is mathematically impossible because `Diamond(psi) in M` does NOT imply `psi in M` for any single MCS.

The correct approach uses **multi-family BFMCS with distinct mcs functions** where witness families place witness MCSes at the appropriate times. The key infrastructure from ChainFMCS.lean (`chainFMCS`, `modal_witness_seed_consistent`, `canonicalMCS_in_some_flag`) is already sorry-free.

### Research Integration

The blocker analysis (report 03) verified:
- Singleton bundle `{canonicalMCSBFMCS}` is NOT modally saturated (proven counterexample)
- Multi-family approach with distinct mcs functions is required
- `saturated_modal_backward` theorem is sorry-free and awaits saturation proof
- Key infrastructure exists: `chainFMCS`, `modal_witness_seed_consistent`, `lindenbaumMCS_set`
- Effort estimate: 9-12 hours

## Goals & Non-Goals

**Goals**:
- Design and implement `WitnessFamilyBundle` structure for tracking obligation-witness pairs
- Implement `closedFlags` closure construction (transfinite or Zorn-based)
- Construct `saturatedBFMCS` from closed flags with built-in saturation proof
- Wire saturated construction to provide sorry-free `modal_forward` and `modal_backward`
- Pass `lake build` with no new sorries

**Non-Goals**:
- Fixing the obsolete singleton approach
- Changing `is_modally_saturated` definition
- Modifying existing ChainFMCS infrastructure
- Implementing Cantor isomorphism to Rat (separate concern for dense completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Closure construction requires transfinite methods | H | M | Use Zorn's lemma via Mathlib Flag infrastructure (already available) |
| Witness families may not form chains | M | L | Multi-family bundle allows witnesses in different flags (documented in ChainFMCS.lean:656-658) |
| Modal coherence proof complexity | M | M | Use existing `saturated_modal_backward` directly once saturation is established |
| Import cycles in new module structure | L | L | Follow existing Bundle/ module organization pattern |

## Implementation Phases

### Phase 1: WitnessFamilyBundle Foundation [COMPLETED]

**Goal**: Define the `WitnessFamilyBundle` structure that tracks modal obligations and their witness families.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/WitnessFamilyBundle.lean`
- [ ] Import required modules: ChainFMCS, ModalWitnessData, ModalSaturation, BFMCS
- [ ] Define `WitnessObligation` structure:
  ```lean
  structure WitnessObligation where
    source_flag : Flag CanonicalMCS
    source_element : ChainFMCSDomain source_flag
    inner_formula : Formula
    obligation_mem : inner_formula.diamond ∈ (chainFMCS source_flag).mcs source_element
  ```
- [ ] Define `WitnessRecord` linking obligation to witness:
  ```lean
  structure WitnessRecord extends WitnessObligation where
    witness : CanonicalMCS
    witness_contains_psi : inner_formula ∈ witness.world
  ```
- [ ] Implement `buildWitnessRecord` using `ModalWitnessData` infrastructure
- [ ] Prove `buildWitnessRecord_contains_psi` (delegates to `witnessAsCanonicalMCS_contains_psi`)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessFamilyBundle.lean` - NEW (~80 lines)

**Verification**:
- `lake build ProofChecker.Theories.Bimodal.Metalogic.Bundle.WitnessFamilyBundle`
- No sorries in file

---

### Phase 2: Multi-Flag Closure Construction [COMPLETED]

**Goal**: Build the closure of flags needed to satisfy all modal obligations.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/ClosedFlagBundle.lean`
- [ ] Import WitnessFamilyBundle, ChainFMCS, Mathlib Order.Zorn
- [ ] Define `initialFlags` containing a root CanonicalMCS:
  ```lean
  def initialFlags (M0 : CanonicalMCS) : Set (Flag CanonicalMCS) :=
    { flag | M0 ∈ flag }
  ```
- [ ] Prove `initialFlags_nonempty` using `Flag.exists_mem`
- [ ] Define the closure operator `addWitnessFlags`:
  ```lean
  noncomputable def addWitnessFlags (flags : Set (Flag CanonicalMCS)) : Set (Flag CanonicalMCS) :=
    flags ∪ {flag | ∃ f ∈ flags, ∃ w ∈ f, ∃ psi : Formula,
      psi.diamond ∈ w.world ∧ (witnessAsCanonicalMCS ⟨psi, w.world, w.is_mcs, _⟩) ∈ flag}
  ```
- [ ] Define `closedFlags` as Zorn supremum or transfinite closure
- [ ] Prove `closedFlags_contains_initial : initialFlags M0 ⊆ closedFlags M0`
- [ ] Prove `closedFlags_closed_under_witnesses`: every Diamond obligation in closedFlags has witness in closedFlags

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ClosedFlagBundle.lean` - NEW (~120 lines)

**Verification**:
- `lake build ProofChecker.Theories.Bimodal.Metalogic.Bundle.ClosedFlagBundle`
- Key theorem `closedFlags_closed_under_witnesses` compiles without sorry

---

### Phase 3: Saturated BFMCS Construction [COMPLETED]

**Goal**: Construct a BFMCS from closed flags and prove it is modally saturated.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean`
- [ ] Import ClosedFlagBundle, ModalSaturation, BFMCS
- [ ] Define `closedFlagFamilies`:
  ```lean
  noncomputable def closedFlagFamilies (M0 : CanonicalMCS) : Set (FMCS CanonicalMCS) :=
    -- Must lift each Flag's chainFMCS (over ChainFMCSDomain) to FMCS over CanonicalMCS
    -- This requires a domain embedding/extension
    sorry -- Phase 3a subtask
  ```
- [ ] **Phase 3a**: Implement domain extension - lift `FMCS (ChainFMCSDomain flag)` to `FMCS CanonicalMCS`
  - Option A: Use restriction to flag domain (partial FMCS, may need adjustment)
  - Option B: Extend chainFMCS to full CanonicalMCS domain with default values
  - Option C: Rethink BFMCS structure to allow heterogeneous domains
- [ ] Prove `closedFlagFamilies_nonempty`
- [ ] Define `saturatedBFMCS_from_closedFlags`:
  ```lean
  noncomputable def saturatedBFMCS (M0 : CanonicalMCS) : BFMCS CanonicalMCS where
    families := closedFlagFamilies M0
    nonempty := closedFlagFamilies_nonempty M0
    modal_forward := ...  -- T-axiom application
    modal_backward := saturated_modal_backward ...
    eval_family := ...
    eval_family_mem := ...
  ```
- [ ] Prove `saturatedBFMCS_is_saturated : is_modally_saturated (saturatedBFMCS M0)`

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean` - NEW (~150 lines)

**Verification**:
- `lake build ProofChecker.Theories.Bimodal.Metalogic.Bundle.SaturatedBFMCSConstruction`
- `is_modally_saturated` proof completes without sorry
- `modal_backward` uses `saturated_modal_backward` (no direct sorry)

---

### Phase 4: Modal Forward Proof [COMPLETED]

**Goal**: Prove `modal_forward` for the saturated BFMCS (straightforward from T-axiom).

**Tasks**:
- [ ] In `SaturatedBFMCSConstruction.lean`, implement `saturatedBFMCS_modal_forward`:
  ```lean
  theorem saturatedBFMCS_modal_forward (M0 : CanonicalMCS) (fam : FMCS CanonicalMCS)
      (hfam : fam ∈ (saturatedBFMCS M0).families) (phi : Formula) (t : CanonicalMCS)
      (h_box : Formula.box phi ∈ fam.mcs t) :
      phi ∈ fam.mcs t := by
    -- T-axiom: ⊢ □φ → φ
    -- Apply MCS implication property
    sorry
  ```
- [ ] Use `box_elimination_theorem` (T-axiom) and MCS implication property
- [ ] Verify proof is sorry-free

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean` - UPDATE

**Verification**:
- `modal_forward` field in `saturatedBFMCS` compiles without sorry

---

### Phase 5: Wire to MultiFamilyBFMCS [PARTIAL]

**Goal**: Replace/augment the sorry in MultiFamilyBFMCS.lean with the saturated construction.

**Tasks**:
- [ ] Add import for `SaturatedBFMCSConstruction.lean` to `MultiFamilyBFMCS.lean`
- [ ] Create `singletonCanonicalBFMCS_saturated` using saturatedBFMCS construction
- [ ] Replace the sorry at line 277 with saturated construction proof
- [ ] Alternative: if domain mismatch, add new definition alongside existing
- [ ] Verify sorry count decreased

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - UPDATE

**Verification**:
- `lake build ProofChecker.Theories.Bimodal.Metalogic.Algebraic.MultiFamilyBFMCS`
- Sorry count in MultiFamilyBFMCS.lean decreased by 1

---

### Phase 6: Integration and Final Verification [COMPLETED]

**Goal**: Verify complete build passes and all new infrastructure is sorry-free.

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic/Bundle.lean` to import new modules
- [ ] Run full `lake build`
- [ ] Count sorries: `grep -r "sorry" Theories/Bimodal/ --include="*.lean" | wc -l`
- [ ] Verify no regressions in dependent modules
- [ ] Run `lean_verify` on key theorems:
  - `saturatedBFMCS_is_saturated`
  - `saturatedBFMCS_modal_forward`
  - `closedFlags_closed_under_witnesses`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle.lean` - ADD imports for new files

**Verification**:
- `lake build` passes with no errors
- Sorry count is less than or equal to before implementation
- New files have no sorries

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/WitnessFamilyBundle.lean` returns 0
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/ClosedFlagBundle.lean` returns 0
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean` returns 0
- [ ] `lean_verify saturatedBFMCS_is_saturated` confirms no axioms
- [ ] `lean_verify closedFlags_closed_under_witnesses` confirms no axioms

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/WitnessFamilyBundle.lean` - Witness obligation tracking
- `Theories/Bimodal/Metalogic/Bundle/ClosedFlagBundle.lean` - Multi-flag closure construction
- `Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean` - Saturated BFMCS with modal coherence
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - Updated (sorry potentially eliminated)
- `specs/1003_implement_modal_coherence/summaries/02_multi-family-summary.md` - Completion summary

## Rollback/Contingency

If implementation encounters blockers:

1. **Phase 2 closure complexity**: If Zorn-based closure is too complex, consider:
   - Finite approximation for specific use cases
   - Alternative saturation condition (e.g., sufficient witnesses)

2. **Phase 3 domain mismatch**: If lifting `FMCS (ChainFMCSDomain flag)` to `FMCS CanonicalMCS` fails:
   - Consider BFMCS over heterogeneous domains (parametric family domain)
   - Use partial FMCS with restricted evaluation
   - Rework completeness to use ChainFMCSDomain directly

3. **Phase 5 integration issues**: If wiring fails:
   - Keep new construction separate from MultiFamilyBFMCS
   - Document as alternative completeness path
   - sorries remain but are well-understood

## Key Mathematical Insights

### Why Singleton Fails

The blocker analysis (report 03) proves:
- For singleton bundle `{canonicalMCSBFMCS}` where `mcs t = t.world`
- `is_modally_saturated` requires: `Diamond(psi) in t.world -> psi in t.world`
- This is semantically "possibly-psi implies actually-psi" which is FALSE in modal logic
- Counterexample: `{Diamond(p), neg(p)}` is consistent and extends to MCS

### Why Multi-Family Works

- Different families have different `mcs` functions
- Base family: `mcs t = t.world` (identity)
- Witness families: `mcs t = W` where W is the witness MCS for some Diamond obligation
- Each witness family is constructed via `chainFMCS` on a Flag containing the witness
- Closure ensures every Diamond obligation has a witnessing family

### Key Infrastructure Already Available

| Theorem | Location | Purpose |
|---------|----------|---------|
| `modal_witness_seed_consistent` | ChainFMCS.lean | Witness seed is consistent |
| `canonicalMCS_in_some_flag` | ChainFMCS.lean | Every MCS is in some Flag |
| `chainFMCS` | ChainFMCS.lean | Flag-based FMCS construction |
| `saturated_modal_backward` | ModalSaturation.lean | Saturation implies modal_backward |
| `lindenbaumMCS_set_is_mcs` | Construction.lean | Lindenbaum extension is MCS |
| `witnessAsCanonicalMCS` | ModalWitnessData.lean | Witness as CanonicalMCS element |
