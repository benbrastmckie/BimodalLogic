# Implementation Plan: Task #842

- **Task**: 842 - Formalize Zorn's lemma proof in exists_fullySaturated_extension
- **Status**: [PARTIAL]
- **Effort**: 11-14 hours
- **Dependencies**: None (follows from task #841)
- **Research Inputs**: specs/842_formalize_zorn_lemma_exists_fullySaturated_extension/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fill the sorry at `SaturatedConstruction.lean:482` in `FamilyCollection.exists_fullySaturated_extension` using Mathlib's `zorn_subset_nonempty`. The proof requires: (1) defining the set S of valid family extensions, (2) proving unions of chains preserve `box_coherence`, (3) proving maximality implies full saturation via witness construction. This is a critical sorry blocking downstream completeness theorems.

### Research Integration

From research-001.md:
- Use `zorn_subset_nonempty` from `Mathlib.Order.Zorn` (recommended over `zorn_subset`)
- Chain upper bound proof requires careful handling of `box_coherence` across union members
- Maximality implies saturation is the hardest part - requires witness construction that preserves coherence
- Estimated effort: 11-18 hours based on component complexity analysis

## Goals & Non-Goals

**Goals**:
- Fill the sorry at line 482 in `exists_fullySaturated_extension`
- Prove that family collections ordered by inclusion form valid input for Zorn's lemma
- Prove chains have upper bounds (union preserves `box_coherence`)
- Prove maximality implies `isFullySaturated`
- Eliminate this sorry from the dependency chain blocking completeness

**Non-Goals**:
- Optimizing the proof for minimal imports (use available Mathlib infrastructure)
- Alternative proof strategies (Zorn's lemma approach is already validated)
- Generalizing beyond the specific `FamilyCollection` structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box coherence under union breaks for complex chains | High | Medium | Prove helper lemma first; use chain ordering (s1 ⊆ s2 or s2 ⊆ s1) to propagate coherence |
| Witness construction doesn't preserve box_coherence | High | Medium | Use careful witness construction inheriting all Box formulas from existing families |
| Unforeseen Mathlib API incompatibilities | Medium | Low | Research identified `zorn_subset_nonempty` signature; verify with `lean_hover_info` |
| Proof complexity exceeds estimates | Medium | Medium | Structure as helper lemmas that can be independently verified |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry at `SaturatedConstruction.lean:482` in `exists_fullySaturated_extension`
- This sorry is inherited by `FamilyCollection.saturate`, `constructSaturatedBMCS`, and downstream completeness theorems

### Expected Resolution
- Phase 5 completes the full proof, eliminating the sorry
- All dependent theorems will no longer inherit sorry status

### New Sorries
- None expected. Each phase produces complete, verified code.

### Remaining Debt
After this implementation:
- 0 sorries in `exists_fullySaturated_extension`
- Downstream theorems (`saturate_extends`, `saturate_eval_family`, `saturate_isFullySaturated`, `constructSaturatedBMCS`) will be sorry-free from this dependency

## Implementation Phases

### Phase 1: Define Set S and Prove Membership [COMPLETED]

**Goal**: Define the set S for Zorn's lemma application and prove C.families is a member

**Tasks**:
- [ ] Define `S : Set (Set (IndexedMCSFamily D))` capturing valid extensions:
  - Extends `C.families`
  - Preserves `box_coherence` predicate
  - Contains `C.eval_family`
- [ ] Prove `hC_in_S : C.families ∈ S` using `Subset.rfl`, `C.box_coherence`, and `C.eval_family_mem`
- [ ] Verify with `lean_goal` that the definition is well-formed

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Lines 473-482

**Verification**:
- `lake build` succeeds with partial proof
- `lean_goal` shows expected proof state after S definition

---

### Phase 2: Create Box Coherence Union Lemma [COMPLETED]

**Goal**: Prove that box_coherence is preserved under chain unions

**Tasks**:
- [ ] Create helper lemma `box_coherence_sUnion`:
  ```lean
  lemma box_coherence_sUnion (c : Set (Set (IndexedMCSFamily D)))
      (hchain : IsChain (· ⊆ ·) c)
      (h_coherence : ∀ s ∈ c, box_coherence_pred s) :
      box_coherence_pred (⋃₀ c)
  ```
- [ ] Prove by showing: for `fam ∈ s1` and `fam' ∈ s2` in chain, use larger's coherence
- [ ] Key insight: `IsChain` gives `s1 ⊆ s2 ∨ s2 ⊆ s1`, so both are in larger set

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Add lemma before main theorem

**Verification**:
- Helper lemma compiles without sorry
- `lean_goal` shows correct induction on chain membership

---

### Phase 3: Prove Chain Upper Bound [COMPLETED]

**Goal**: Show that for any chain in S, the union is an upper bound in S

**Tasks**:
- [ ] Prove `⋃₀ c` extends `C.families` (each chain element does, so union does)
- [ ] Prove `C.eval_family ∈ ⋃₀ c` using chain nonemptiness
- [ ] Apply `box_coherence_sUnion` from Phase 2
- [ ] Combine to show `⋃₀ c ∈ S`
- [ ] Prove `∀ s ∈ c, s ⊆ ⋃₀ c` (upper bound property)

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Continue main proof

**Verification**:
- Chain upper bound subgoal completed
- Ready for Zorn's lemma application

---

### Phase 4: Prove Maximality Implies Full Saturation [PARTIAL]

**Goal**: Show that a maximal element M in S is fully saturated

**Tasks**:
- [ ] Prove by contradiction: assume M not fully saturated
- [ ] Extract witness: `∃ psi, fam ∈ M, t` such that `diamondFormula psi ∈ fam.mcs t` but no witness
- [ ] Use `diamond_implies_psi_consistent` to show `{psi}` is consistent
- [ ] Construct witness family via Lindenbaum extension (use existing `constructWitnessFamily` or similar)
- [ ] Show M ∪ {witness} still has box_coherence:
  - For existing → existing: inherited from M
  - For witness → existing / existing → witness: careful construction ensures coherence
- [ ] Derive contradiction: M ∪ {witness} ⊃ M but both in S, contradicting maximality

**Timing**: 4-5 hours (hardest phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Add maximality lemma

**Verification**:
- Maximality implies saturation lemma compiles
- Witness construction preserves all invariants

---

### Phase 5: Apply Zorn's Lemma and Construct Result [COMPLETED]

**Goal**: Complete the main theorem by applying Zorn and constructing the FamilyCollection

**Tasks**:
- [ ] Apply `zorn_subset_nonempty S _ C.families hC_in_S` with chain bound proof
- [ ] Extract maximal element M with `C.families ⊆ M` and `Maximal (· ∈ S) M`
- [ ] Construct `C' : FamilyCollection D phi`:
  - `families := M`
  - `nonempty` from `C.eval_family ∈ M` (M extends C)
  - `eval_family := C.eval_family`
  - `eval_family_mem` from S membership
  - `box_coherence` from S membership
- [ ] Prove three properties: `C.families ⊆ C'.families`, `C'.eval_family = C.eval_family`, `C'.isFullySaturated`
- [ ] Remove final sorry

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Complete theorem at line 482

**Verification**:
- `lake build` succeeds with no sorries in `exists_fullySaturated_extension`
- Dependent theorems (`saturate_extends`, etc.) compile without issues

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] No sorry in `FamilyCollection.exists_fullySaturated_extension`
- [ ] Verify `FamilyCollection.saturate` compiles without sorry inheritance
- [ ] Verify `constructSaturatedBMCS` compiles without sorry inheritance
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` returns no matches for this theorem
- [ ] Check downstream impact on completeness theorems

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Modified with complete proof
- `specs/842_formalize_zorn_lemma_exists_fullySaturated_extension/summaries/implementation-summary-YYYYMMDD.md` - Summary after completion

## Rollback/Contingency

If the proof approach fails:
1. Keep the original sorry in place (no regression)
2. Document the specific failure point in error report
3. Consider alternative approaches:
   - Direct construction without Zorn (enumerate closure formulas, finite induction)
   - Alternative witness construction strategy
   - Weaker result (closure saturation only, if maximality→full saturation too hard)
4. Create follow-up task for alternative approach if needed

If time runs out before completion:
1. Commit completed helper lemmas (Phases 1-3)
2. Mark remaining phases as [PARTIAL] or [NOT STARTED]
3. Next `/implement 842` resumes from incomplete phase
