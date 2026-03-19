# Implementation Plan: Task #1003 (v3)

- **Task**: 1003 - Implement Sorry-Free Multi-Family Modal Coherence
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (Task #1002 design document is now OUTDATED)
- **Research Inputs**: specs/1003_implement_modal_coherence/reports/04_team-research.md
- **Previous Plans (OBSOLETE)**:
  - plans/01_modal-coherence-plan.md (singleton approach - mathematically impossible)
  - plans/02_multi-family-plan.md (multi-family over CanonicalMCS - blocked by domain type)
- **Artifacts**: plans/03_flagbfmcs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Implement sorry-free modal completeness using **FlagBFMCS**, a new structure that bundles Flags (not FMCS instances) with modal coherence conditions. This abandons the fixed-domain `BFMCS D` approach for modal completeness, which the team research (report 04) proved to be structurally impossible due to the G-T axiom absence and domain type constraints.

The key insight is semantic: a bimodal world is a (Flag, element) pair, where each Flag is a temporal timeline and modal accessibility connects corresponding positions across timelines. The existing `chainFMCS(flag)` provides temporal coherence per Flag, and `closedFlags_closed_under_witnesses` provides modal saturation across Flags.

### Research Integration

Report 04 (team synthesis) established:
1. **Singleton BFMCS impossible**: `Diamond(psi) in t.world` does NOT imply `psi in t.world`
2. **Temporal T-axioms absent**: `G phi -> phi` is NOT a theorem; constant witness families violate `forward_G`
3. **Same-domain multi-family fails**: All families over CanonicalMCS reduce to identity `mcs(t) = t.world`
4. **FlagBFMCS is the correct architecture**: Flag-indexed structure with heterogeneous domains per Flag

## Goals & Non-Goals

**Goals**:
- Define `FlagBFMCS` structure with Flag-indexed semantics
- Construct `canonicalFlagBFMCS` using `closedFlags` infrastructure
- Adapt truth lemma Box/Diamond cases for FlagBFMCS evaluation
- Wire to completeness infrastructure (model existence theorem)
- Pass `lake build` with no new sorries

**Non-Goals**:
- Fixing or extending the obsolete `BFMCS D` structure for modal completeness
- Modifying existing temporal completeness infrastructure (FMCS over CanonicalMCS)
- Implementing Cantor isomorphism to Rat (separate concern for dense completeness)
- Proving modal completeness for arbitrary logics (focus on bimodal S5+temporal)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth lemma adaptation complexity | H | M | Start with Box case skeleton; use existing saturated_modal_backward pattern |
| eval_flag_mem proof difficulty | M | L | closedFlags includes initialFlags; root MCS is in some initialFlag |
| modal_coherent field proof | M | M | MCSBoxContent_subset_of_CanonicalR + S5 axiom structure |
| Import cycles with new module | L | L | Follow existing Bundle/ module organization |
| Integration with existing completeness | M | M | Create parallel FlagBFMCS completeness path; existing BFMCS remains for temporal-only |

## Implementation Phases

### Phase 1: Define FlagBFMCS Structure [COMPLETED]

**Goal**: Create the core `FlagBFMCS` type capturing Flag-indexed bimodal semantics.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean`
- [ ] Import: ClosedFlagBundle, ChainFMCS, ModalSaturation, BFMCS
- [ ] Define `FlagBFMCS` structure:
  ```lean
  structure FlagBFMCS where
    root : CanonicalMCS
    flags : Set (Flag CanonicalMCS)
    flags_nonempty : flags.Nonempty
    /-- Box content propagates uniformly across all flags. -/
    modal_coherent : ∀ f ∈ flags, ∀ M ∈ f.asSet, ∀ φ,
      Formula.box φ ∈ M.world →
      ∀ f' ∈ flags, ∀ M' ∈ f'.asSet,
      MCSBoxContent M.world ⊆ MCSBoxContent M'.world →
      Formula.box φ ∈ M'.world
    /-- Diamond witnesses exist within the flag set. -/
    modally_saturated : ∀ f ∈ flags, ∀ M ∈ f.asSet, ∀ ψ,
      ψ.diamond ∈ M.world →
      ∃ f' ∈ flags, ∃ M' ∈ f'.asSet, ψ ∈ M'.world
    /-- Evaluation flag for completeness proof. -/
    eval_flag : Flag CanonicalMCS
    eval_flag_mem : eval_flag ∈ flags
    eval_element : ChainFMCSDomain eval_flag
  ```
- [ ] Add basic accessors: `FlagBFMCS.chainFMCS_at`, `FlagBFMCS.mcs_at`
- [ ] Prove `FlagBFMCS.eval_world : FlagBFMCS.mcs_at = eval_element.val.world`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean` - NEW (~80 lines)

**Verification**:
- `lake build ProofChecker.Theories.Bimodal.Metalogic.Bundle.FlagBFMCS`
- No sorries in structure definition

---

### Phase 2: Construct canonicalFlagBFMCS [COMPLETED]

**Goal**: Build the canonical FlagBFMCS using closedFlags and prove its fields.

**Tasks**:
- [ ] Define `canonicalFlagBFMCS`:
  ```lean
  noncomputable def canonicalFlagBFMCS (M0 : CanonicalMCS) : FlagBFMCS where
    root := M0
    flags := closedFlags M0
    flags_nonempty := closedFlags_nonempty M0
    modal_coherent := canonicalFlagBFMCS_modal_coherent M0
    modally_saturated := closedFlags_closed_under_witnesses M0
    eval_flag := (root_in_closedFlags M0).choose
    eval_flag_mem := (root_in_closedFlags M0).choose_spec.1
    eval_element := ⟨M0, (root_in_closedFlags M0).choose_spec.2⟩
  ```
- [ ] Prove `canonicalFlagBFMCS_modal_coherent`:
  - For any F, F' in closedFlags, M in F, M' in F'
  - If BoxContent(M.world) ⊆ BoxContent(M'.world) and Box(phi) in M.world
  - Then Box(phi) in M'.world
  - Proof: Box(phi) in M.world means phi in BoxContent(M.world)
  - By subset hypothesis, phi in BoxContent(M'.world)
  - So Box(phi) in M'.world (definition of BoxContent)
- [ ] Prove `canonicalFlagBFMCS_eval_element_valid`: the eval_element is well-formed
- [ ] Add theorem `canonicalFlagBFMCS_root_in_eval_flag`: M0 is in the eval_flag

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean` - UPDATE (~60 lines)

**Verification**:
- `lake build` with no sorries in canonicalFlagBFMCS construction
- Key theorem: `canonicalFlagBFMCS_modal_coherent` compiles without sorry

---

### Phase 3: Truth Lemma Skeleton for FlagBFMCS [COMPLETED]

**Goal**: Define satisfaction relation and prove base cases (atomic, negation, conjunction).

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean`
- [ ] Import: FlagBFMCS, ChainFMCS
- [ ] Define `satisfies_at`:
  ```lean
  def satisfies_at (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
      (x : ChainFMCSDomain F) : Formula → Prop
    | .atom p => .atom p ∈ (chainFMCS F).mcs x
    | .neg φ => ¬satisfies_at B F hF x φ
    | .conj φ ψ => satisfies_at B F hF x φ ∧ satisfies_at B F hF x ψ
    | .box φ => ∀ F' ∈ B.flags, ∀ x' : ChainFMCSDomain F',
        accessible B F x F' x' → satisfies_at B F' (by assumption) x' φ
    | .diamond φ => ∃ F' ∈ B.flags, ∃ x' : ChainFMCSDomain F',
        accessible B F x F' x' ∧ satisfies_at B F' (by assumption) x' φ
    | .all_future φ => ∀ y : ChainFMCSDomain F, x < y → satisfies_at B F hF y φ
    | .all_past φ => ∀ y : ChainFMCSDomain F, y < x → satisfies_at B F hF y φ
    | .some_future φ => ∃ y : ChainFMCSDomain F, x < y ∧ satisfies_at B F hF y φ
    | .some_past φ => ∃ y : ChainFMCSDomain F, y < x ∧ satisfies_at B F hF y φ
  ```
- [ ] Define modal accessibility:
  ```lean
  def accessible (B : FlagBFMCS) (F : Flag CanonicalMCS) (x : ChainFMCSDomain F)
      (F' : Flag CanonicalMCS) (x' : ChainFMCSDomain F') : Prop :=
    MCSBoxContent x.val.world ⊆ MCSBoxContent x'.val.world
  ```
- [ ] Prove truth lemma for atom: `satisfies_at_atom_iff`
- [ ] Prove truth lemma for neg: `satisfies_at_neg_iff` (via MCS negation completeness)
- [ ] Prove truth lemma for conj: `satisfies_at_conj_iff`
- [ ] Prove truth lemma for temporal operators (delegate to chainFMCS coherence):
  - `satisfies_at_all_future_iff`: via `chainFMCS_forward_G`
  - `satisfies_at_all_past_iff`: via `chainFMCS_backward_H`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - NEW (~150 lines)

**Verification**:
- `lake build` passes
- Temporal cases compile without sorry (delegate to existing chainFMCS proofs)

---

### Phase 4: Truth Lemma Modal Cases [COMPLETED]

**Goal**: Prove the crucial Box and Diamond cases of the truth lemma.

**Tasks**:
- [ ] Prove `satisfies_at_box_iff`:
  ```lean
  theorem satisfies_at_box_iff (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
      (x : ChainFMCSDomain F) (φ : Formula) :
      satisfies_at B F hF x (Formula.box φ) ↔ Formula.box φ ∈ (chainFMCS F).mcs x := by
    constructor
    · intro h_sat
      -- If Box φ satisfied (all accessible have φ), need Box φ in mcs
      -- Contrapositive: if neg(Box φ) in mcs, then Diamond(neg φ) in mcs
      -- By B.modally_saturated, ∃ witness F', x' with neg φ in mcs
      -- But that means ¬satisfies_at ... x' φ
      -- And x' is accessible (reflexivity of BoxContent inclusion)
      sorry -- Main proof effort
    · intro h_box
      -- If Box φ in mcs, show satisfies_at for all accessible
      -- By B.modal_coherent and BoxContent propagation
      intro F' hF' x' h_acc
      -- h_acc means BoxContent(x.world) ⊆ BoxContent(x'.world)
      -- Box φ in x.world means φ in BoxContent(x.world)
      -- So φ in BoxContent(x'.world), so Box φ in x'.world
      sorry -- Apply IH
  ```
- [ ] Prove `satisfies_at_diamond_iff`:
  ```lean
  theorem satisfies_at_diamond_iff (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
      (x : ChainFMCSDomain F) (φ : Formula) :
      satisfies_at B F hF x (Formula.diamond φ) ↔ Formula.diamond φ ∈ (chainFMCS F).mcs x := by
    constructor
    · intro ⟨F', hF', x', h_acc, h_sat⟩
      -- Diamond satisfied means some accessible has φ
      -- Need Diamond φ in mcs
      -- If neg(Diamond φ) = Box(neg φ) in mcs, then by modal_forward, neg φ in all accessible
      sorry
    · intro h_diamond
      -- Diamond φ in mcs, need to find accessible with φ
      -- By B.modally_saturated, ∃ F', x' with φ in x'.world
      -- Show this x' is accessible
      obtain ⟨F', hF', M', hM', h_psi⟩ := B.modally_saturated F hF x.val ⟨x.val.1, x.property⟩ φ h_diamond
      sorry -- Construct witness
  ```
- [ ] Handle the induction hypothesis correctly (may need well-founded recursion)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - UPDATE (~100 lines)

**Verification**:
- `satisfies_at_box_iff` and `satisfies_at_diamond_iff` compile without sorry
- `lean_verify` confirms no hidden axioms

---

### Phase 5: Wire to Completeness Infrastructure [COMPLETED]

**Goal**: Connect FlagBFMCS to the completeness theorem (model existence).

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean`
- [ ] Import: FlagBFMCS, FlagBFMCSTruthLemma
- [ ] Define `flagBFMCS_model`:
  ```lean
  def flagBFMCS_model (B : FlagBFMCS) : BimodalModel where
    World := Σ (F : { f // f ∈ B.flags }), ChainFMCSDomain F.val
    modalR := fun ⟨F, x⟩ ⟨F', x'⟩ => accessible B F.val x F'.val x'
    temporalR := fun ⟨F, x⟩ ⟨F', x'⟩ => F = F' ∧ x.val < x'.val
    valuation := fun p ⟨F, x⟩ => .atom p ∈ (chainFMCS F.val).mcs x
  ```
- [ ] Prove `flagBFMCS_model_satisfies`: the model satisfies the evaluation formula
- [ ] Prove completeness theorem:
  ```lean
  theorem flagBFMCS_completeness (Γ : Context) (h_con : SetConsistent Γ.toSet) :
      ∃ M : BimodalModel, ∃ w : M.World, ∀ φ ∈ Γ, M.satisfies w φ := by
    -- Extend Γ to MCS M0 via Lindenbaum
    -- Construct canonicalFlagBFMCS M0
    -- Use truth lemma to show formulas in M0 are satisfied
    sorry
  ```
- [ ] Update `Theories/Bimodal/Metalogic/Bundle.lean` to import new modules

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean` - NEW (~80 lines)
- `Theories/Bimodal/Metalogic/Bundle.lean` - UPDATE (add imports)

**Verification**:
- `lake build` passes with no errors
- Completeness theorem has no sorries (or clearly scoped sorries for follow-up)

---

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean` returns 0
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` returns 0
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean` counts documented
- [ ] `lean_verify canonicalFlagBFMCS` confirms construction is axiom-free
- [ ] `lean_verify satisfies_at_box_iff` confirms no hidden axioms
- [ ] Overall sorry count in Theories/Bimodal/ decreased or stable

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean` - FlagBFMCS structure and construction
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - Truth lemma for FlagBFMCS
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean` - Completeness wiring
- `specs/1003_implement_modal_coherence/summaries/03_flagbfmcs-summary.md` - Completion summary

## Rollback/Contingency

If implementation encounters blockers:

1. **Phase 2 modal_coherent proof difficulty**:
   - Simplify to reflexivity case only (BoxContent self-inclusion)
   - Add full coherence as follow-up task

2. **Phase 4 truth lemma induction issues**:
   - Use fuel-based recursion as workaround
   - Or restructure as mutual induction with accessibility relation

3. **Phase 5 integration complexity**:
   - Keep FlagBFMCS completeness separate from existing BFMCS infrastructure
   - Document as alternative completeness path for modal operators

4. **General fallback**:
   - If full proof is too complex, establish FlagBFMCS as the correct architecture
   - Leave well-documented sorries for specific lemmas
   - Prior approaches (plans v1, v2) are proven mathematically impossible

## Key Mathematical Insights

### Why Previous Approaches Failed

| Approach | Failure Mode | Mathematical Reason |
|----------|--------------|---------------------|
| Singleton BFMCS | Modal saturation impossible | Diamond(psi) in M does NOT imply psi in M |
| Constant witness families | Temporal coherence fails | G-T axiom (G phi -> phi) not in proof system |
| Same-domain multi-family | Reduces to singleton | All families map t -> t.world over CanonicalMCS |

### Why FlagBFMCS Works

1. **Heterogeneous domains**: Each Flag has its own `ChainFMCSDomain`, avoiding the identity trap
2. **Temporal coherence per Flag**: `chainFMCS(flag)` is sorry-free for forward_G, backward_H
3. **Modal saturation across Flags**: `closedFlags_closed_under_witnesses` ensures Diamond witnesses exist
4. **Correct semantics**: Bimodal world = (Flag, position) matches standard temporal-modal bundle semantics

### Existing Sorry-Free Infrastructure

| Component | Location | Status | FlagBFMCS Role |
|-----------|----------|--------|----------------|
| `chainFMCS` | ChainFMCS.lean | Sorry-free | Per-Flag temporal FMCS |
| `closedFlags_closed_under_witnesses` | ClosedFlagBundle.lean | Sorry-free | `modally_saturated` field |
| `closedFlags_nonempty` | ClosedFlagBundle.lean | Sorry-free | `flags_nonempty` field |
| `root_in_closedFlags` | ClosedFlagBundle.lean | Sorry-free | `eval_flag_mem` construction |
| `MCSBoxContent_subset_of_CanonicalR` | ChainFMCS.lean | Sorry-free | `modal_coherent` helper |
| `box_implies_phi_in_mcs` | SaturatedBFMCSConstruction.lean | Sorry-free | T-axiom application |
