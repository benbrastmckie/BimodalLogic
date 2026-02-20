# Implementation Plan: Task #912

- **Task**: 912 - review_completeness_proof_metalogic_state
- **Version**: 002
- **Created**: 2026-02-20
- **Status**: [PARTIAL]
- **Effort**: 18-27 hours (revised from 10-14)
- **Dependencies**: None
- **Research Inputs**: research-001.md, research-002.md, research-003.md
- **Previous Plan**: implementation-001.md (Phases 1, 2, 5 completed; Phases 3-4 blocked)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

---

## Overview

This revised plan addresses the two `sorry` placeholders in `Representation.lean` using
**Option B from research-003.md**: parameterize `valid` and `semantic_consequence` over
`Omega` with a `ShiftClosed Omega` condition, rather than attempting to prove that the
canonical model's truth lemma extends to `Set.univ`.

**Key insight from research-003**: The `box_persistent` lemma shows that `Box phi` at any
time `t` implies `Box phi` at ALL times (via TF and its temporal dual H(Box phi)). This
enables a shifted truth lemma for the enlarged `shiftClosedCanonicalOmega B`, which then
matches the `ShiftClosed Omega` requirement in the revised `valid` definition.

**Preserved from v001**:
- Phase 1 archival work (29 sorries eliminated) is complete
- Phase 2 investigation findings documented in research-002.md
- Phase 5 verification confirms build succeeds

**Revised approach**:
- Replace blocked Phases 3-4 with new phases implementing Option B
- Add infrastructure phases for `box_persistent` and `shiftClosedCanonicalOmega`

---

## Mathematical Foundation

### The ShiftClosed Parameterization

The revised `valid` definition will be:

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

This is mathematically equivalent to the standard definition because:
1. `Set.univ` is shift-closed (`Set.univ_shift_closed`)
2. Any history is in `Set.univ`
3. Soundness proofs only use `Set.univ_shift_closed`, which becomes `h_sc`

### The box_persistent Lemma

For any BMCS family `fam` and times `t, s`:
```
Box phi ∈ fam.mcs t → Box phi ∈ fam.mcs s
```

**Proof chain**:
1. From `Box phi ∈ fam.mcs t`, by TF axiom closure: `G(Box phi) ∈ fam.mcs t`
2. By temporal dual of TF (derivable): `H(Box phi) ∈ fam.mcs t`
3. For `s ≥ t`: by `forward_G`, `Box phi ∈ fam.mcs s`
4. For `s < t`: by `backward_H`, `Box phi ∈ fam.mcs s`

### The shiftClosedCanonicalOmega Construction

```lean
def shiftClosedCanonicalOmega (B : BMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
  { σ | ∃ (fam : IndexedMCSFamily Int) (hfam : fam ∈ B.families) (delta : Int),
    σ = WorldHistory.time_shift (canonicalHistory B fam hfam) delta }
```

This set:
- Contains all canonical histories (take `delta = 0`)
- Contains all time-shifts of canonical histories
- Is shift-closed: shifting by `delta'` gives `time_shift ... (delta + delta')`

---

## Implementation Phases

### Phase 1: Archival and Cleanup [COMPLETED - from v001]

Already completed in implementation-001.md. 29 sorries archived to Boneyard.

**Artifacts**:
- RecursiveSeed/, SeedCompletion.lean, SeedBMCS.lean moved to Boneyard/Bundle/
- TruthLemma.lean EvalBMCS section removed
- Documentation fixed in FiniteWorldState.lean, Metalogic.lean

---

### Phase 2: Investigation and Documentation [COMPLETED - from v001]

Already completed in implementation-001.md. Omega-mismatch analyzed in research-002.md.

**Finding**: Three approaches analyzed (coverage, Set.univ truth lemma, Omega-parametric
validity), all blocked. Led to research-003.md which identified Option B.

---

### Phase 3: Canonical Infrastructure [COMPLETED]

- **Dependencies**: None
- **Goal**: Build `shiftClosedCanonicalOmega` and prove `box_persistent`

**Objectives**:
1. Define `shiftClosedCanonicalOmega B` in Representation.lean
2. Prove `shiftClosedCanonicalOmega_is_shift_closed`
3. Prove `canonicalOmega_subset_shiftClosed` (canonical histories are in the enlarged set)
4. Prove `box_persistent`: Box phi persists across all times in any family

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Representation.lean` - Add definitions and lemmas

**Steps**:

1. Add definition of `shiftClosedCanonicalOmega`
2. Prove shift-closure by showing `time_shift (time_shift σ delta) delta' = time_shift σ (delta + delta')`
3. Prove subset relationship (trivial with `delta = 0`)
4. Prove `box_persistent`:
   a. Prove TF axiom is in every MCS: `(Box phi).imp (Box phi).all_future ∈ fam.mcs t`
   b. Prove past-TF is derivable via `temporal_duality`
   c. Prove past-TF is in every MCS
   d. Combine with `forward_G` and `backward_H` to get persistence

**Verification**:
- `lake build` succeeds
- No new sorries introduced
- `#check shiftClosedCanonicalOmega_is_shift_closed` type-checks

**Timing**: 4-6 hours

---

### Phase 4: Shifted Truth Lemma [COMPLETED]

- **Dependencies**: Phase 3
- **Goal**: Prove truth lemma for `shiftClosedCanonicalOmega B`

**Objectives**:
1. Prove `shifted_truth_lemma`:
   ```lean
   theorem shifted_truth_lemma (B : BMCS Int) (h_tc : B.temporally_coherent)
       (phi : Formula) (fam : IndexedMCSFamily Int) (hfam : fam ∈ B.families) (t : Int) :
       phi ∈ fam.mcs t ↔
       truth_at (canonicalModel B) (shiftClosedCanonicalOmega B) (canonicalHistory B fam hfam) t phi
   ```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Representation.lean`

**Proof strategy**:
- Induction on formula structure
- Non-box cases: identical to `canonical_truth_lemma_all` (Omega-independent)
- Box forward case:
  1. From `Box phi ∈ fam.mcs t`, use `box_persistent` to get `Box phi ∈ fam.mcs (t + delta)` for all delta
  2. By `modal_forward`: `phi ∈ fam'.mcs (t + delta)` for all families `fam'`
  3. By IH at `(fam', t + delta)`: truth at canonical history at `t + delta`
  4. By `time_shift_preserves_truth`: truth at shifted history at `t`
- Box backward case: same as original (extra histories only strengthen hypothesis)

**Verification**:
- `lake build` succeeds
- `#check shifted_truth_lemma` type-checks
- No new sorries

**Timing**: 4-6 hours

---

### Phase 5: Validity Definition Changes [COMPLETED]

- **Dependencies**: Phase 4
- **Goal**: Parameterize `valid` and `semantic_consequence` over shift-closed Omega

**Objectives**:
1. Modify `valid` to add `Omega`, `h_sc : ShiftClosed Omega`, `h_mem : τ ∈ Omega` parameters
2. Modify `semantic_consequence` similarly
3. Update `satisfiable` to existentially quantify over shift-closed Omega
4. Update namespace lemmas in Validity.lean

**Files to modify**:
- `Theories/Bimodal/Semantics/Validity.lean`

**Backward compatibility**:
- Old usage `valid φ` becomes `valid φ Omega h_sc τ h_mem t`
- Provide `valid_standard` alias using `Set.univ` for backward compatibility if needed

**Verification**:
- File type-checks (may have cascading errors in Soundness.lean)
- Proceed to Phase 6 to fix soundness

**Timing**: 1-2 hours

---

### Phase 6: Soundness Updates [PARTIAL]

- **Dependencies**: Phase 5
- **Goal**: Update soundness proofs to use `ShiftClosed Omega` hypothesis

**Objectives**:
1. Update `modal_future_valid` (MF axiom) to use `h_sc` instead of `Set.univ_shift_closed`
2. Update `temp_future_valid` (TF axiom) similarly
3. Update all other axiom validity lemmas (most don't use shift-closure)
4. Update `soundness` theorem signature
5. Update any helper lemmas in SoundnessLemmas.lean

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean`
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (if exists)

**Key changes**:
- Replace `Set.univ : Set (WorldHistory F)` with `Omega` parameter
- Replace `Set.univ_shift_closed` with `h_sc : ShiftClosed Omega`
- Add `h_mem : τ ∈ Omega` where needed
- Most proofs should be mechanical replacements

**Verification**:
- `lake build` succeeds
- Soundness theorem type-checks with new signature
- No new sorries

**Timing**: 3-4 hours

---

### Phase 7: Representation Sorry Discharge [NOT STARTED]

- **Dependencies**: Phases 4, 5, 6
- **Goal**: Discharge the two sorry placeholders in Representation.lean

**Objectives**:
1. Update `standard_representation` to use `shiftClosedCanonicalOmega B`
2. Replace sorry in `standard_weak_completeness` (line ~425):
   - `valid phi` with `Omega = shiftClosedCanonicalOmega B` gives `truth_at ... phi`
   - `satisfiable [phi.neg]` gives `truth_at ... phi.neg` with SAME Omega
   - Direct contradiction
3. Replace sorry in `standard_strong_completeness` (line ~457) similarly

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Representation.lean`

**Proof structure for weak completeness**:
```lean
theorem standard_weak_completeness (phi : Formula) (h_valid : valid phi) :
    Nonempty (DerivationTree [] phi) := by
  by_contra h_not_deriv
  have h_neg_cons : ContextConsistent [phi.neg] := not_derivable_implies_neg_consistent h_not_deriv
  obtain ⟨F, M, Omega, h_sc, tau, h_mem, t, h_all_true⟩ := standard_representation phi.neg h_neg_cons
  have h_neg_true : truth_at M Omega tau t phi.neg := h_all_true phi.neg (by simp)
  have h_phi_true : truth_at M Omega tau t phi := h_valid F M Omega h_sc tau h_mem t
  exact h_neg_true h_phi_true  -- contradiction: phi.neg and phi both true
```

**Verification**:
- `lake build` succeeds
- `grep -r "sorry" Representation.lean` returns no active sorries
- Type signatures unchanged except for Omega parameterization

**Timing**: 2-3 hours

---

### Phase 8: Final Verification and Documentation [NOT STARTED]

- **Dependencies**: Phase 7
- **Goal**: Verify full codebase, update documentation, update state

**Objectives**:
1. Run `lake build` and verify zero build errors
2. Count remaining sorries and axioms
3. Update module documentation in Metalogic.lean and Representation.lean
4. Update CLAUDE.md if needed (sorry count in repository_health)
5. Write implementation summary

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Update sorry table
- `Theories/Bimodal/Metalogic/Bundle/Representation.lean` - Update docstrings
- `specs/state.json` - Update repository_health

**Expected outcomes**:
- Active Metalogic/ sorry count: ~7 (down from 9, minus 2 discharged sorries)
- Standard completeness theorems are sorry-free
- Soundness theorem is sorry-free

**Timing**: 1-2 hours

---

## Testing and Validation

- [ ] `lake build` succeeds after each phase
- [ ] No new `sorry` or `axiom` declarations in active files
- [ ] `standard_weak_completeness` has no sorry (type: `valid φ → Nonempty (DerivationTree [] φ)`)
- [ ] `standard_strong_completeness` has no sorry (type: `semantic_consequence Γ φ → ContextDerivable Γ φ`)
- [ ] `soundness` theorem type-checks with Omega parameter
- [ ] `valid` definition includes `ShiftClosed Omega` condition

---

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `box_persistent` harder than expected (derivation infrastructure) | Medium | Medium | May need explicit derivation tree for past-TF; have fallback of adding as sorry |
| Shifted truth lemma box case has subtle Omega dependency | High | Low | research-003 provides detailed proof sketch; follow carefully |
| Soundness changes cascade to unexpected files | Medium | Low | Fix incrementally; most axioms don't use shift-closure |
| `time_shift` definition differs from expectation | Low | Low | Verify definitions in Truth.lean before proceeding |

---

## Rollback and Contingency

**If Phase 3 fails** (box_persistent unprovable):
- Investigate derivation infrastructure for past-TF
- Worst case: add past-TF as explicit axiom (mathematically justified by temporal duality)

**If Phase 4 fails** (shifted truth lemma blocked):
- Review proof sketch from research-003 Section 5.4
- Check if Omega dependency in IH is correctly handled

**If Soundness changes break unexpectedly**:
- Keep old `valid_standard` using `Set.univ` for backward compatibility
- Gradually migrate callers

---

## Summary

This revision implements Option B from research-003.md:

1. **New infrastructure** (Phases 3-4): `shiftClosedCanonicalOmega`, `box_persistent`, `shifted_truth_lemma`
2. **Definition changes** (Phases 5-6): Add `ShiftClosed Omega` to `valid`, update soundness mechanically
3. **Sorry discharge** (Phase 7): Both Representation.lean sorries eliminated
4. **Total effort**: 18-27 hours (Phases 3-8 are new work; Phases 1-2 completed in v001)

The approach is mathematically sound: we parameterize validity over shift-closed Omega
(which includes `Set.univ` as a special case), enabling the canonical model construction
to provide a matching shift-closed Omega for the completeness proof.
