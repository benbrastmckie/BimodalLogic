# Implementation Plan: Construct D as Translation Group from Syntax

- **Task**: 956 - construct_d_as_translation_group_from_syntax
- **Status**: [PARTIAL]
- **Effort**: 12 hours
- **Dependencies**: None (builds on existing BidirectionalFragment infrastructure)
- **Research Inputs**: specs/956_construct_d_as_translation_group_from_syntax/reports/research-005.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Construct the duration type D as the group of formal differences on the canonical timeline T (BidirectionalFragment), following Strategy C (FMCS-based torsor construction) from research-005.md. The construction uses Mathlib's `AddTorsor` infrastructure to define D from the existing `BidirectionalFragment` linear order, then replaces the trivial `task_rel` with the group action. This eliminates the hardcoded `Int` dependency and provides a mathematically principled D that emerges from pure syntax.

### Research Integration

Key findings from research-005.md integrated into this plan:
- **Strategy C (FMCS-based torsor)**: Define D as formal differences `T × T / ~` rather than constructing Aut+(T) explicitly
- **Mathlib infrastructure**: `AddTorsor`, `Equiv.vaddConst`, `LinearOrder.lift` available
- **Zero assumptions**: No discreteness or density assumptions on T
- **Archival candidates**: DovetailingChain.lean, CanonicalChain.lean, CanonicalConstruction.lean
- **Homogeneity challenge**: Use formal difference construction to sidestep explicit automorphism construction

## Goals & Non-Goals

**Goals**:
- Define `TranslationDiff T` as the formal difference group of the timeline T
- Prove `TranslationDiff T` is a linearly ordered abelian group
- Establish `AddTorsor (TranslationDiff T) T`
- Define canonical `TaskFrame (TranslationDiff T)` with task_rel = group action
- Prove nullity and compositionality from torsor axioms
- Archive files with hardcoded Int that are superseded

**Non-Goals**:
- Proving D is isomorphic to Int (requires discreteness axiom - future task)
- Proving D is isomorphic to Q (requires density axiom - future task)
- Modifying the existing `FMCS D` or `BFMCS D` structures (already generic over D)
- Full completeness theorem update (separate task 955)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Quotient equality proofs complex | M | M | Use Quotient.sound pattern, prove equivalence relation is decidable |
| LinearOrder.lift requires injective eval | M | L | Origin injection follows from torsor freeness (vsub_vadd cancellation) |
| Order compatibility with addition subtle | M | M | Use Mathlib's `IsOrderedAddMonoid` infrastructure, leverage bi-invariance |
| Upstream sorry inheritance | H | L | Existing BidirectionalFragment is sorry-free; new code builds on solid foundation |

## Sorry Characterization

### Pre-existing Sorries
- None in BidirectionalFragment.lean or CanonicalCompleteness.lean (these are sorry-free)
- 2 sorries in DovetailingChain.lean (forward_F, backward_P) - being archived, not inherited

### Expected Resolution
- This implementation introduces NO new sorries
- All proofs build on sorry-free BidirectionalFragment infrastructure
- Quotient and group constructions use standard Mathlib patterns

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 new sorries in new files
- DovetailingChain.lean archived (2 sorries moved to Boneyard)
- No downstream sorry inheritance

## Implementation Phases

### Phase 1: Archive Int-Hardcoded Files and Setup [PARTIAL]

- **Dependencies:** None
- **Goal:** Move obsolete Int-hardcoded files to Boneyard and create new file structure

**Tasks:**
- [ ] Create `Theories/Bimodal/Boneyard/` directory if not exists
- [ ] Move `DovetailingChain.lean` to `Boneyard/DovetailingChain_archived.lean`
- [ ] Move `CanonicalChain.lean` to `Boneyard/CanonicalChain_archived.lean`
- [ ] Move `CanonicalConstruction.lean` to `Boneyard/CanonicalConstruction_archived.lean`
- [ ] Update imports in affected files to remove archived dependencies
- [ ] Create stub `TranslationGroup.lean` with module header
- [ ] Verify `lake build` passes after archival

**Timing:** 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` → Boneyard
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` → Boneyard
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` → Boneyard
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` (new)

**Verification:**
- `lake build` passes
- No imports reference archived files (except Boneyard)
- Module structure compiles

---

### Phase 2: Define TranslationDiff Quotient Type [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** Define D as formal differences `T × T / ~` with group structure

**Tasks:**
- [ ] Define `TranslationEquiv` equivalence relation: `(a,b) ~ (c,d) iff CanonicalR a.world c.world ∧ CanonicalR b.world d.world ∧ CanonicalR c.world a.world ∧ CanonicalR d.world b.world` (equivalence via equal displacement)
- [ ] Prove `TranslationEquiv` is an equivalence relation (reflexivity, symmetry, transitivity)
- [ ] Define `TranslationDiff T := Quotient (TranslationEquiv T)`
- [ ] Define `mkDiff : T → T → TranslationDiff T` (quotient constructor)
- [ ] Prove `mkDiff_eq_iff`: `mkDiff a b = mkDiff c d ↔ (displacement a to b = displacement c to d)`
- [ ] Define zero element: `TranslationDiff.zero := mkDiff origin origin` (for any origin)
- [ ] Define addition: `mkDiff a b + mkDiff b c = mkDiff a c` (chain composition)
- [ ] Define negation: `-mkDiff a b = mkDiff b a` (reversal)
- [ ] Prove AddCommGroup axioms (add_assoc, add_zero, zero_add, add_neg, add_comm)

**Timing:** 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean`

**Verification:**
- `lake build` passes
- `#check (inferInstance : AddCommGroup (TranslationDiff T))` succeeds
- `grep -n "\bsorry\b" TranslationGroup.lean` returns empty

**Key Lemmas:**
- `translationEquiv_refl : TranslationEquiv T (a, b) (a, b)`
- `translationEquiv_symm : TranslationEquiv T p q → TranslationEquiv T q p`
- `translationEquiv_trans : TranslationEquiv T p q → TranslationEquiv T q r → TranslationEquiv T p r`
- `add_comm_group_translation_diff : AddCommGroup (TranslationDiff T)`

---

### Phase 3: Establish AddTorsor Structure [BLOCKED]

- **Dependencies:** Phase 2
- **Goal:** Prove T is an AddTorsor for TranslationDiff T, enabling the group action

**Tasks:**
- [ ] Define `vadd : TranslationDiff T → T → T` (apply displacement to point)
- [ ] Define `vsub : T → T → TranslationDiff T` as `vsub a b = mkDiff b a` (point difference)
- [ ] Prove `vsub_vadd' : (a -ᵥ b) +ᵥ b = a` (difference then add recovers target)
- [ ] Prove `vadd_vsub' : (d +ᵥ a) -ᵥ a = d` (add then difference recovers displacement)
- [ ] Instantiate `AddTorsor (TranslationDiff T) T`
- [ ] Prove `Equiv.vaddConst` gives bijection `TranslationDiff T ≃ T` via origin
- [ ] Verify freeness: `d +ᵥ a = a → d = 0` (from vsub/vadd cancellation)
- [ ] Verify transitivity: `∀ a b, ∃ d, d +ᵥ a = b` (existence of displacement)

**Timing:** 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean`

**Verification:**
- `lake build` passes
- `#check (inferInstance : AddTorsor (TranslationDiff T) T)` succeeds
- `#check @Equiv.vaddConst (TranslationDiff T) T _ _` has expected type
- `grep -n "\bsorry\b" TranslationGroup.lean` returns empty

**Key Lemmas:**
- `add_torsor_translation_diff : AddTorsor (TranslationDiff T) T`
- `vadd_assoc : (d₁ + d₂) +ᵥ a = d₁ +ᵥ (d₂ +ᵥ a)`
- `vsub_eq_mkDiff : a -ᵥ b = mkDiff b a`

---

### Phase 4: Linear Order on TranslationDiff [BLOCKED]

- **Dependencies:** Phase 3
- **Goal:** Pull back linear order from T to TranslationDiff T via origin evaluation

**Tasks:**
- [ ] Fix an arbitrary origin `w₀ : T` (fragment root)
- [ ] Define `evalAtOrigin : TranslationDiff T → T := fun d => d +ᵥ w₀`
- [ ] Prove `evalAtOrigin` is injective (from torsor freeness)
- [ ] Define `TranslationDiff.le : d₁ ≤ d₂ ↔ d₁ +ᵥ w₀ ≤ d₂ +ᵥ w₀` via `LinearOrder.lift`
- [ ] Verify LinearOrder instance compiles
- [ ] Prove order-addition compatibility: `d₁ ≤ d₂ → d₁ + e ≤ d₂ + e` (translation invariance)
- [ ] Prove order-addition compatibility: `d₁ ≤ d₂ → e + d₁ ≤ e + d₂`
- [ ] Instantiate `IsOrderedAddMonoid (TranslationDiff T)`
- [ ] Prove bi-invariance implies commutativity (Holder's theorem application)

**Timing:** 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean`

**Verification:**
- `lake build` passes
- `#check (inferInstance : LinearOrder (TranslationDiff T))` succeeds
- `#check (inferInstance : IsOrderedAddMonoid (TranslationDiff T))` succeeds
- `grep -n "\bsorry\b" TranslationGroup.lean` returns empty

**Key Lemmas:**
- `evalAtOrigin_injective : Function.Injective evalAtOrigin`
- `linear_order_translation_diff : LinearOrder (TranslationDiff T)`
- `ordered_add_comm_monoid_translation_diff : IsOrderedAddMonoid (TranslationDiff T)`
- `translation_diff_add_comm : ∀ d₁ d₂, d₁ + d₂ = d₂ + d₁` (if not already from AddCommGroup)

---

### Phase 5: Canonical TaskFrame with Group Action [PARTIAL]

- **Dependencies:** Phase 4
- **Goal:** Define TaskFrame using TranslationDiff T with task_rel = group action

**Tasks:**
- [ ] Create `CanonicalTaskFrameTorsor.lean` (new file)
- [ ] Define `TorsorWorldState T := T` (fragment elements are world states)
- [ ] Define `torsor_task_rel w d w' := d +ᵥ w = w'` (deterministic group action)
- [ ] Prove nullity: `0 +ᵥ w = w` (from AddTorsor zero action)
- [ ] Prove compositionality: `d₁ +ᵥ w = u → d₂ +ᵥ u = v → (d₁ + d₂) +ᵥ w = v`
- [ ] Define `CanonicalTaskFrameTorsor : TaskFrame (TranslationDiff T)`
- [ ] Define `TorsorTaskModel : TaskModel CanonicalTaskFrameTorsor` with valuation from MCS membership
- [ ] Verify TaskFrame well-typedness constraints are satisfied

**Timing:** 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrameTorsor.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` (imports)

**Verification:**
- `lake build` passes
- `#check (CanonicalTaskFrameTorsor : TaskFrame (TranslationDiff T))` succeeds
- task_rel is NOT trivially True (unlike old canonicalFrame)
- `grep -n "\bsorry\b" CanonicalTaskFrameTorsor.lean` returns empty

**Key Definitions:**
- `CanonicalTaskFrameTorsor : TaskFrame (TranslationDiff T)`
- `torsor_task_rel_nullity : torsor_task_rel w 0 w`
- `torsor_task_rel_compositionality : torsor_task_rel w d₁ u → torsor_task_rel u d₂ v → torsor_task_rel w (d₁ + d₂) v`

---

### Phase 6: Integration and Verification [BLOCKED]

- **Dependencies:** Phase 5
- **Goal:** Integrate new construction with existing completeness infrastructure, verify zero-debt

**Tasks:**
- [ ] Add exports to `Theories/Bimodal/Metalogic/Bundle/FMCS.lean` or metalogic module file
- [ ] Verify `FMCS (TranslationDiff T)` instantiates correctly (already generic)
- [ ] Verify `BFMCS (TranslationDiff T)` instantiates correctly (already generic)
- [ ] Document compatibility with future discrete (D ≅ ℤ) and dense (D ≅ ℚ) extensions
- [ ] Run `lake build` on full project
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrameTorsor.lean`
- [ ] Run `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrameTorsor.lean`
- [ ] Create brief migration guide documenting Int → TranslationDiff T pathway

**Timing:** 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` (documentation)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrameTorsor.lean` (documentation)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (if needed for exports)

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" <new files>` returns empty (zero-debt gate)
- `grep -n "^axiom " <new files>` shows no new axioms
- All proofs verified with `lean_goal` showing "no goals"
- Documentation explains future extension points

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrameTorsor.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrameTorsor.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Typeclass Resolution Tests
- [ ] `#check (inferInstance : AddCommGroup (TranslationDiff T))`
- [ ] `#check (inferInstance : AddTorsor (TranslationDiff T) T)`
- [ ] `#check (inferInstance : LinearOrder (TranslationDiff T))`
- [ ] `#check (inferInstance : IsOrderedAddMonoid (TranslationDiff T))`

### Semantic Tests
- [ ] task_rel is NOT `fun _ _ _ => True` (non-trivial)
- [ ] Nullity uses torsor zero action, not `trivial`
- [ ] Compositionality uses torsor addition, not `trivial`

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` (new, ~400 lines)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrameTorsor.lean` (new, ~150 lines)
- `Theories/Bimodal/Boneyard/DovetailingChain_archived.lean` (moved)
- `Theories/Bimodal/Boneyard/CanonicalChain_archived.lean` (moved)
- `Theories/Bimodal/Boneyard/CanonicalConstruction_archived.lean` (moved)
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If construction proves infeasible:
1. Restore archived files from Boneyard
2. Revert import changes
3. Mark task [BLOCKED] with specific obstacle identified
4. Document which phase failed and why

**Escape Valves:**
- If Phase 2 (quotient group) blocked: May need alternative equivalence relation
- If Phase 3 (AddTorsor) blocked: May need to prove homogeneity explicitly
- If Phase 4 (linear order) blocked: May need alternative order definition

For any phase marked [BLOCKED], include `requires_user_review: true` in metadata and document the specific mathematical obstacle.
