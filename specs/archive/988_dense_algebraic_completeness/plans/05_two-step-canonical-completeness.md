# Implementation Plan: Task #988

**Task**: dense_algebraic_completeness
**Version**: 005
**Created**: 2026-03-17
**Language**: lean4

## Overview

Previous plans (v1-v4) all attempted to directly construct a temporally coherent BFMCS over `D = Rat`. This approach is blocked by a fundamental architectural constraint: `BFMCS.temporally_coherent` requires per-family witnesses, but the staged construction (DenseTimeline.lean) can only include MCSes reachable from the root via CanonicalR. Lindenbaum witnesses for F/P formulas may not be CanonicalR-reachable from the root, creating an unbridgeable gap.

This plan takes the **two-step canonical completeness** route identified in research run 06. Instead of constructing a dense (D = Rat) BFMCS directly, we prove completeness via the canonical model first, then transfer to dense validity semantically. The route is: `valid_dense φ → valid_over_CanonicalMCS φ → ⊢ φ`. The canonical model uses `D = CanonicalMCS` (all MCSes with CanonicalR Preorder), which already has fully proven forward_F and backward_P in `CanonicalFMCS.lean` — no sorries.

The key mathematical insight is that validity over dense models implies validity in the canonical model, because the canonical model (CanonicalMCS with CanonicalR) satisfies the density axiom DN. If F(φ) is in a CanonicalMCS world w, then by `canonicalMCS_forward_F` there exists a world s ≥ w with φ ∈ s. By Lindenbaum we can always interpolate another witness between w and s, giving DN. Thus the canonical model IS a dense model, and dense validity → canonical validity.

## Phases

### Phase 1: Canonical Truth Lemma for CanonicalMCS [NOT STARTED]

**Estimated effort**: 3h

**Objectives**:
1. Prove the truth lemma for the D-parametric canonical model instantiated at `D = CanonicalMCS`
2. This is distinct from the existing `parametric_shifted_truth_lemma` (which requires `AddCommGroup D`); `CanonicalMCS` only has `Preorder`
3. Alternatively, prove the truth lemma by directly using the BFMCS/TemporalCoherentFamily infrastructure over `CanonicalMCS`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` (add truth lemma section)
- OR: new file `Theories/Bimodal/Metalogic/Bundle/CanonicalTruthLemma.lean`

**Key lemmas to prove**:
```lean
-- The main truth lemma for BFMCS over CanonicalMCS
-- Using the existing TemporalCoherentFamily infrastructure
theorem canonical_mcs_truth_lemma
    (B : BFMCS CanonicalMCS) (h_tc : B.temporally_coherent)
    (fam : FMCS CanonicalMCS) (hfam : fam ∈ B.families)
    (w : CanonicalMCS) (φ : Formula) :
    φ ∈ fam.mcs w ↔ truth_at_canonical_mcs fam w φ

-- Or adapt ParametricTruthLemma to Preorder (not AddCommGroup)
```

**Investigation needed**: Check whether `ParametricTruthLemma.lean` can be re-used or if its `AddCommGroup D` constraint needs lifting. Key question: does the truth lemma proof use arithmetic on D, or only the Preorder? Inspect `ParametricTruthLemma.lean` lines 49+ for the `[AddCommGroup D]` usage.

If arithmetic is only used in `ParametricCanonical.lean` (for task_rel), the truth lemma itself may work with just `[Preorder D]`. If not, we may need a direct proof following the structure of `Bundle/CanonicalConstruction.lean`.

**Steps**:
1. Inspect `ParametricTruthLemma.lean` to see which lemmas use `AddCommGroup` vs just `Preorder`
2. If only `Preorder` needed: refactor truth lemma to use `[Preorder D]`
3. If not: build a direct truth lemma for CanonicalMCS following `CanonicalConstruction.lean` pattern
4. Use `canonicalMCSBFMCS` (already proven) to provide F/P coherence
5. Wrap in a BFMCS with modal saturation from `ModalSaturation.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CanonicalTruthLemma` (or modified file) with no errors/sorries
- `lean_goal` at key proof points to confirm state matches expectations

---

### Phase 2: Canonical Algebraic Completeness [NOT STARTED]

**Estimated effort**: 2h

**Objectives**:
1. Prove that validity over all CanonicalMCS-indexed TaskModels implies provability
2. This is the `valid_over_CanonicalMCS φ → ⊢ φ` direction

**Files to create or modify**:
- New: `Theories/Bimodal/Metalogic/Algebraic/CanonicalMCSCompleteness.lean`

**Key theorem to prove**:
```lean
-- Validity in canonical model implies provability
theorem canonical_algebraic_completeness (φ : Formula) :
    valid_over_CanonicalMCS φ → Nonempty (DerivationTree [] φ)

-- where valid_over_CanonicalMCS is:
def valid_over_CanonicalMCS (φ : Formula) : Prop :=
  ∀ (F : TaskFrame CanonicalMCS) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (w : CanonicalMCS),
    truth_at M Omega τ w φ
```

**Alternative**: If `valid_over_CanonicalMCS` is too specific, use the existing `valid φ` (universal) and show the canonical model over CanonicalMCS is already one of those. The key is: if φ is not provable, then neg(φ) extends to MCS M, and by Phase 1's truth lemma, φ is false at M in the canonical BFMCS over CanonicalMCS.

**Concrete proof strategy** (modeled on `AlgebraicBaseCompleteness.lean`):
```lean
theorem canonical_algebraic_completeness (φ : Formula) (h_not_prov : ¬Nonempty (DerivationTree [] φ)) :
    ∃ -- a specific CanonicalMCS-indexed model where φ is false
```

**Steps**:
1. Define `valid_over_CanonicalMCS` (or reuse existing `valid` by instantiation)
2. Use `not_provable_implies_neg_extends_to_mcs` to get MCS M with neg(φ) ∈ M
3. Apply `temporal_coherent_family_exists_CanonicalMCS` to get FMCS and root
4. Build BFMCS with modal saturation over CanonicalMCS
5. Apply canonical truth lemma (Phase 1): neg(φ) ∈ root.mcs ↔ truth_at ... neg(φ)
6. Conclude φ is false at the canonical model
7. Contrapositive: valid φ → provable φ

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.CanonicalMCSCompleteness` with no sorries
- The sorry in `AlgebraicBaseCompleteness.algebraic_base_completeness` should be replaced

---

### Phase 3: Dense Validity Implies Canonical Validity [NOT STARTED]

**Estimated effort**: 3h

**Objectives**:
1. Prove `valid_dense φ → valid_over_CanonicalMCS φ` (or equivalent countermodel transfer)
2. This requires showing the canonical model over CanonicalMCS is a valid dense model

**Mathematical argument**:
The canonical model over CanonicalMCS satisfies the density axiom DN because:
- DN = `F(φ) → F(F(φ))`
- If F(φ) ∈ w, then by `canonicalMCS_forward_F`, ∃ s ≥ w with φ ∈ s
- The CanonicalMCS Preorder allows finding an intermediate witness between w and s
- Specifically: w < s in CanonicalMCS means `g_content(w) ⊆ s` (CanonicalR)
- DN is an AXIOM of the dense proof system, so it is in every MCS of the dense proof system
- Since our MCSes are for the dense proof system (including DN axiom), F(φ) ∈ w implies DN closure

**More precise argument**:
The dense proof system includes DN as an axiom. Therefore every MCS (for the dense system) is closed under DN: `F(φ) ∈ M → F(F(φ)) ∈ M`. This is the standard observation that axioms of the system are in every MCS. Thus the canonical model automatically satisfies DN.

**Key lemma**:
```lean
-- DN axiom is in every MCS of the dense proof system
-- (assuming MCS is over the dense proof system, which includes DN)
lemma dn_axiom_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) :
    Formula.some_future (Formula.some_future φ) ∈ M

-- The canonical CanonicalMCS model satisfies dense validity
theorem canonical_mcs_is_dense_model :
    ∀ (φ : Formula), valid_dense φ →
      ∀ (fam : FMCS CanonicalMCS) (w : CanonicalMCS), φ ∈ fam.mcs w
```

**Steps**:
1. Verify the proof system in use includes DN (check which Axiom set is active)
2. Prove DN closure: `F(φ) ∈ M → F(F(φ)) ∈ M` for any MCS of the dense system
3. Show CanonicalMCS Preorder is non-trivial (has Nontrivial instance, needed by `valid_dense`)
4. Show the CanonicalMCS FMCS + BFMCS satisfies `DenselyOrdered` frame condition or equivalent
5. Prove `valid_dense φ → valid_in_canonical_mcs_model φ`
6. Connect via Phase 1 truth lemma to get `valid_dense φ → ∀ w, φ ∈ fam.mcs w`

**Potential issue**: `valid_dense` requires `[DenselyOrdered D]` and `[Nontrivial D]`. CanonicalMCS does not directly have these typeclasses. The approach may need to be semantic rather than typeclass-based:
- Instead of instantiating `valid_dense` at `D = CanonicalMCS`, prove the contrapositive
- If φ is not valid_dense, then there exists a dense model where φ is false
- But we need the forward direction: valid_dense → canonical validity

**Preferred approach** (semantic):
```lean
-- Key: if φ is not provable in the dense proof system,
-- then there exists a CanonicalMCS world where φ fails
-- (using the fact that the CanonicalMCS construction works for the dense proof system)
theorem dense_not_provable_implies_canonical_countermodel (φ : Formula)
    (h_not_prov : ¬Nonempty (DerivationTree [] φ)) :  -- using dense proof system
    ∃ (fam : FMCS CanonicalMCS) (w : CanonicalMCS), ¬(φ ∈ fam.mcs w)
```

**Verification**:
- Check that DN axiom is in scope for the MCS construction
- `lean_goal` at the critical implication point
- `lake build` the new file

---

### Phase 4: Wire Dense Algebraic Completeness [NOT STARTED]

**Estimated effort**: 2h

**Objectives**:
1. Combine Phases 2 and 3 to prove `valid_dense φ → ⊢ φ`
2. Update `DenseInstantiation.lean` or create a new top-level file
3. Eliminate the sorry in `dense_representation_conditional`'s caller

**Files to create or modify**:
- New: `Theories/Bimodal/Metalogic/Algebraic/DenseAlgebraicCompleteness.lean`
- Possibly update: `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`
- Possibly update: `Theories/Bimodal/Metalogic/DenseCompleteness.lean`

**Key theorem**:
```lean
/--
Dense Algebraic Completeness Theorem

If a formula is valid over all dense temporal orders,
then it is provable in the dense proof system (base axioms + DN).
-/
theorem dense_algebraic_completeness (φ : Formula) :
    valid_dense φ → Nonempty (DerivationTree [] φ) := by
  -- Step 1: By Phase 3, valid_dense → valid in canonical model
  intro h_dense
  -- Step 2: By Phase 2 (contrapositive), not-provable → not-valid in canonical model
  -- Equivalently: valid in canonical model → provable
  -- Step 3: Combine
  exact canonical_algebraic_completeness φ (dense_implies_canonical φ h_dense)
```

**Steps**:
1. Import Phase 1 (CanonicalTruthLemma) and Phase 2 (CanonicalMCSCompleteness) modules
2. Import Phase 3 (DenseImpliesCanonical) module
3. Write the three-line combination proof
4. Update `DenseCompleteness.lean` to reference the new theorem
5. Verify all imports compile cleanly
6. Run `lake build Bimodal` to confirm no regressions

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.DenseAlgebraicCompleteness` with no errors/sorries
- Full `lake build` passes
- `lean_verify` on the final theorem statement

---

## Dependencies

- `canonicalMCSBFMCS` (CanonicalFMCS.lean) — proven, no sorries; provides forward_F and backward_P
- `temporal_coherent_family_exists_CanonicalMCS` (CanonicalFMCS.lean) — proven, no sorries
- `canonicalMCS_forward_F` (CanonicalFMCS.lean) — proven, no sorries
- `canonicalMCS_backward_P` (CanonicalFMCS.lean) — proven, no sorries
- `ParametricTruthLemma.lean` — proven for `[AddCommGroup D]`; Phase 1 investigates whether Preorder suffices
- `ModalSaturation.lean` — needed for BFMCS modal coherence conditions
- `not_provable_implies_neg_extends_to_mcs` (ParametricRepresentation.lean) — proven
- `valid_dense` definition (Validity.lean:159) — quantifies over `[DenselyOrdered D]` and `[Nontrivial D]`
- DN axiom in the dense proof system (Axiom set) — needed for Phase 3

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `ParametricTruthLemma` requires `AddCommGroup D`, not just `Preorder` | High — Phase 1 blocked | Fall back to direct proof following `CanonicalConstruction.lean` pattern; estimated +1h |
| `valid_dense` requires `DenselyOrdered D` typeclass; CanonicalMCS doesn't have it | High — Phase 3 blocked | Use semantic/contrapositive argument: not provable → MCS countermodel exists (via Lindenbaum + dense axioms) |
| CanonicalMCS `Nontrivial` instance may not exist | Medium — Phase 3 typeclass issue | Either prove `Nontrivial CanonicalMCS` or use semantic approach not needing it |
| Modal saturation construction for CanonicalMCS may need new code | Medium | Check `ModalSaturation.lean` for existing infrastructure; may need CanonicalMCS-specific modal saturation |
| DN axiom in MCS requires the right proof system to be in scope | Medium | Verify early in Phase 3 which `Axiom` type is used; confirm DN is included |
| Phase 3 semantic argument may need more sophisticated Lean 4 proof | Low-Medium | Use `by_contra` + countermodel construction as fallback |

## Implementation Notes

### Truth Lemma Architecture Question

The `ParametricTruthLemma` module has `variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. The truth lemma itself (the inductive proof over formula structure) likely only uses the `Preorder` structure from `D`. The `AddCommGroup` constraint comes from the `ParametricCanonicalTaskFrame` construction (which uses arithmetic in `task_rel`).

**Action in Phase 1**: Check if a minimal truth lemma can be stated without TaskFrame/TaskModel (directly as MCS membership ↔ inductive truth predicate), avoiding the `ParametricCanonicalTaskModel` entirely. The `Bundle/CanonicalConstruction.lean` file does exactly this for `D = Int` — use that as a template for `D = CanonicalMCS`.

### Completeness via Contrapositive Pattern

The base completeness proof in `AlgebraicBaseCompleteness.lean` is blocked by a sorry in `construct_bfmcs_from_mcs`. The two-step approach bypasses this entirely:

Instead of constructing BFMCS D → D arbitrary, we use:
1. CanonicalMCS has ready-made F/P witnesses (trivially, since witnesses ARE MCSes)
2. Dense validity holds in the canonical model (since DN ∈ every dense MCS)
3. Thus dense validity → canonical model validity → provable

### MCS System Assumption

Throughout, "MCS" means "maximal consistent set for the DENSE proof system" (base axioms + DN). The existing `SetMaximalConsistent` definition in `MaximalConsistent.lean` should use whatever proof system is currently active. Verify that `lindenbaumMCS` operates on the dense proof system when targeting dense completeness.

## Success Criteria

- [ ] `canonical_mcs_truth_lemma` proved with no sorries (Phase 1)
- [ ] `canonical_algebraic_completeness` proved with no sorries (Phase 2)
- [ ] `dense_implies_canonical` or equivalent proved with no sorries (Phase 3)
- [ ] `dense_algebraic_completeness` proved with no sorries (Phase 4)
- [ ] `lake build Bimodal` passes with no new errors
- [ ] No new axioms introduced
- [ ] `sorry` count in active Theories/ does not increase
