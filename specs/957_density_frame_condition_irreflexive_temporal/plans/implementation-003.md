# Implementation Plan: Task #957 - Density Frame Condition via IRR Rule (v3)

- **Task**: 957 - density_frame_condition_irreflexive_temporal
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: Task 956 Phase 5 (BLOCKED, this task unblocks it)
- **Research Inputs**: research-004.md (IRR soundness analysis), research-003.md (Case B analysis), research-002.md (Case B obstruction)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Strategy: Add the Gabbay IRR (Irreflexivity Rule) to the proof system.**

Research-002 and research-003 established that Case B of the density frame condition cannot be resolved using standard Lindenbaum techniques. Research-004 analyzed the IRR rule and confirmed:
1. IRR is sound on irreflexive linear orders (via product frame construction)
2. IRR enables the density proof by providing "naming propositions" that break Case B symmetry
3. Total estimated effort: 330-360 lines across 5 phases

**The IRR Rule**: From `|- (p AND H(neg p)) -> phi` where p does not occur in phi, infer `|- phi`. This rule is sound because at any time t in an irreflexive order, we can find a valuation where p holds only at t, making the antecedent `p AND H(neg p)` satisfiable.

### Research Integration

From research-004.md:
- **Finding 1**: IRR soundness via product frame construction (eliminates state aliasing)
- **Finding 2**: Truth independence lemma enables valuation modification
- **Finding 3**: Required code changes enumerated (5 pattern-match sites)
- **Finding 5**: How IRR enables density proof via naming propositions

### Prior Work (From implementation-001 and implementation-002)

- **COMPLETED**: `density_frame_condition_caseA` handles Case A with double-density trick
- **BLOCKED**: `density_frame_condition` has sorry in Case B (implementations 001-002 confirmed obstruction)
- **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

## Goals & Non-Goals

**Goals**:
- Add `Formula.atoms` function to Formula.lean
- Add `DerivationTree.irr` constructor for IRR rule
- Update downstream pattern-match sites (height, usedFormulas, deduction theorem)
- Prove IRR soundness via truth independence + product frame
- Use IRR to resolve `density_frame_condition` Case B sorry
- Zero sorries, zero new axioms

**Non-Goals**:
- Bulldozing approach (alternative to IRR, not pursued here)
- Lexicographic product (forbidden per task description)
- Selective Lindenbaum (too heavy, IRR is cleaner)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Product frame construction too complex | HIGH | MEDIUM | Research-004 provides full mathematical argument; if blocked, mark [BLOCKED] for user review |
| Truth independence lemma box case subtle | MEDIUM | LOW | Both models use same Omega, so box case is structural induction |
| DeductionTheorem.lean IRR case tricky | MEDIUM | MEDIUM | IRR only applies to empty context, simplifies deduction theorem case |
| TaskFrame lifting for product frame tedious | MEDIUM | MEDIUM | May need 100+ lines of boilerplate; budget time accordingly |
| Case B resolution mechanism unclear | HIGH | MEDIUM | Use naming proposition approach from Gabbay; if unclear, mark [BLOCKED] |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `density_frame_condition` (Case B branch) at DensityFrameCondition.lean

### Expected Resolution
- Phase 5 resolves the Case B sorry using IRR-enabled proof technique
- All other phases introduce no sorries

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in `density_frame_condition`
- Task 956 Phase 5 unblocked (staged_timeline_densely_ordered)

## Implementation Phases

### Phase 1: Formula.atoms Function [NOT STARTED]

- **Dependencies:** None
- **Goal:** Add function to compute the set of propositional atoms appearing in a formula

**Tasks**:
- [ ] Add `Formula.atoms : Formula -> Finset String` function
- [ ] Add `atoms_swap_temporal` lemma: `phi.swap_temporal.atoms = phi.atoms`
- [ ] Add helper lemmas for atoms of compound formulas (union properties)
- [ ] Verify no sorries in new code

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` - add atoms function (~25 lines)

**Verification**:
- `lean_goal` shows "no goals" at end of each proof
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Syntax/Formula.lean` returns empty

---

### Phase 2: DerivationTree.irr Constructor + Downstream Updates [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Add IRR as a meta-rule in the proof system

**Tasks**:
- [ ] Add `irr` constructor to `DerivationTree`:
  ```lean
  | irr (p : String) (phi : Formula)
      (h_fresh : p not_in phi.atoms)
      (d : DerivationTree [] ((p AND H(neg p)).imp phi)) :
      DerivationTree [] phi
  ```
- [ ] Add `height` case for IRR: `| .irr _ _ _ d => 1 + d.height`
- [ ] Add `usedFormulas` case for IRR in MaximalConsistent.lean
- [ ] Add IRR cases to `deduction_theorem_core` in DeductionTheorem.lean
- [ ] Add IRR cases to `deduction_theorem_neg` in DeductionTheorem.lean
- [ ] Verify all pattern matches are exhaustive (no missing cases)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Derivation.lean` - add IRR constructor + height (~20 lines)
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - add usedFormulas case (~5 lines)
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - add IRR cases (~20 lines)

**Verification**:
- `lake build` passes with no "missing cases" warnings
- All proofs compile without sorries
- `grep -n "\bsorry\b" <modified files>` returns empty

---

### Phase 3: Truth Independence Lemma [NOT STARTED]

- **Dependencies:** Phase 1 (uses Formula.atoms)
- **Goal:** Prove that truth values are independent of atoms not appearing in the formula

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/IRRSoundness.lean`
- [ ] Prove `truth_independent_of_valuation_change`:
  ```lean
  theorem truth_independent_of_valuation_change
      {F : TaskFrame D} {M1 M2 : TaskModel F}
      {Omega : Set (WorldHistory F)}
      {phi : Formula}
      (h_agree : forall s q, q in phi.atoms -> M1.valuation s q <-> M2.valuation s q)
      (tau : WorldHistory F) (t : D) :
      truth_at M1 Omega tau t phi <-> truth_at M2 Omega tau t phi
  ```
- [ ] Prove by structural induction on phi (6 cases: atom, bot, imp, box, all_past, all_future)
- [ ] Key insight: box case works because both models use same Omega

**Timing**: 1 hour

**Files to create**:
- `Theories/Bimodal/Metalogic/IRRSoundness.lean` - new file (~40 lines for this phase)

**Verification**:
- `lean_goal` shows "no goals" at end of proof
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/IRRSoundness.lean` returns empty

---

### Phase 4: IRR Soundness (Product Frame Construction) [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove IRR is sound on irreflexive dense linear orders

**Tasks**:
- [ ] Define product frame construction: `State_prod = State x D`
- [ ] Define history lifting: `sigma_prod.states s hs = (sigma.states s hs, s)`
- [ ] Prove product frame eliminates state aliasing
- [ ] Define valuation extension for p: `M_prod.valuation (state, time) p = (time = t)`
- [ ] Prove `p AND H(neg p)` holds at (M_prod, tau_prod, t)
- [ ] Prove truth equivalence between M and M_prod for formulas not mentioning p
- [ ] Prove `irr_sound_dense`:
  ```lean
  theorem irr_sound_dense
      {p : String} {phi : Formula}
      (h_fresh : p not_in phi.atoms)
      (h_premise : valid_dense ((p AND H(neg p)).imp phi)) :
      valid_dense phi
  ```

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/IRRSoundness.lean` - add product frame + soundness (~150 lines)

**Verification**:
- `lean_goal` shows "no goals" at end of main theorem
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/IRRSoundness.lean` returns empty

---

### Phase 5: Use IRR to Resolve Density Case B [NOT STARTED]

- **Dependencies:** Phase 2 (IRR in proof system), Phase 4 (IRR soundness)
- **Goal:** Resolve the sorry in `density_frame_condition` using IRR

**Tasks**:
- [ ] Apply IRR approach to Case B in `density_frame_condition`:
  - Under assumption `p AND H(neg p)` with p fresh, construct the intermediate W
  - The naming proposition p distinguishes M from its predecessors
  - Use this to break the Case B symmetry
- [ ] Alternative: If direct IRR application is complex, prove a specialized lemma:
  - `caseB_via_irr`: In Case B, use IRR to show an intermediate exists
- [ ] Remove the sorry in `density_frame_condition`
- [ ] Verify theorem signature matches task 956 Phase 5 requirements
- [ ] Add docstring explaining the IRR-based proof strategy

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - resolve Case B (~50-80 lines)

**Verification**:
- `lean_goal` shows "no goals" at end of proof
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` returns empty (zero-debt gate)
- `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` shows no new axioms

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` returns empty (zero-debt gate)
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/IRRSoundness.lean` returns empty
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Theorem `density_frame_condition` has correct signature for task 956 Phase 5
- [ ] Proof uses only temporal axioms (no external Q or dense order imports)
- [ ] IRR rule properly formalized as meta-rule (not axiom)

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/Formula.lean` - atoms function
- `Theories/Bimodal/ProofSystem/Derivation.lean` - IRR constructor
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - usedFormulas case
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - IRR cases
- `Theories/Bimodal/Metalogic/IRRSoundness.lean` - NEW: truth independence + soundness
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - Case B resolved
- `specs/957_density_frame_condition_irreflexive_temporal/plans/implementation-003.md` - this plan
- `specs/957_density_frame_condition_irreflexive_temporal/summaries/implementation-summary-YYYYMMDD.md` - on completion

## Rollback/Contingency

If Phase 4 (product frame soundness) proves too complex:
1. Add IRR as a rule with a sorry in the soundness proof
2. Resolve density Case B using IRR
3. Create follow-up task to fill in the soundness sorry later
4. This would be technically a sorry but in SOUNDNESS not COMPLETENESS

If Phase 5 (Case B resolution) fails:
1. Document the specific obstruction
2. Consider bulldozing as alternative (different task)
3. Mark [BLOCKED] with requires_user_review: true

If mathematically blocked (IRR approach insufficient):
1. Mark [BLOCKED] with requires_user_review: true
2. Document the obstruction
3. User decides: pursue alternative approaches or revise requirements
