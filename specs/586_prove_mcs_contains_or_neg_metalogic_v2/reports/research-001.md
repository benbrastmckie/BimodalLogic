# Research Report: Task #586

**Task**: Prove mcs_contains_or_neg in Metalogic_v2
**Date**: 2026-01-18
**Session ID**: sess_1768777119_8adba8
**Effort**: 3-4 hours
**Priority**: High
**Language**: lean
**Sources/Inputs**: Metalogic_v2 codebase, lean_leansearch, lean_loogle, lean_leanfinder
**Artifacts**: specs/586_prove_mcs_contains_or_neg_metalogic_v2/reports/research-001.md

## Executive Summary

- **ALREADY PROVEN**: The theorem `mcs_contains_or_neg` is already fully implemented in `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` (lines 231-266) with no sorries
- **Task is completed**: The implementation uses maximality + deduction theorem + double negation elimination
- **README needs update**: The README.md incorrectly lists this theorem as having sorries - this should be corrected
- **Downstream dependencies clear**: Tasks 587-590 can proceed since this foundation is solid

## Context & Scope

Task 586 was created to prove `mcs_contains_or_neg` - a theorem stating that for any maximal consistent set S, every formula phi is either in S or its negation is in S. This is a critical property for the representation theorem and truth lemma.

### Original Task Description

> Prove `mcs_contains_or_neg` in Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean (line 192). This theorem establishes that for any maximal consistent set S, every formula phi is either in S or its negation is in S. Use Mathlib's `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem` as proof pattern.

## Findings

### 1. Theorem Already Implemented

The theorem `mcs_contains_or_neg` is located at lines 231-266 in `CanonicalModel.lean` and is **fully proven** (no sorry):

```lean
theorem mcs_contains_or_neg {S : Set Formula} (h_mcs : SetMaximalConsistent S) (phi : Formula) :
    phi ∈ S ∨ Formula.neg phi ∈ S := by
  by_cases hphi : phi ∈ S
  · left; exact hphi
  · right
    by_contra hneg
    -- Both phi ∉ S and ¬phi ∉ S
    -- By maximality, insert phi S and insert ¬phi S are both inconsistent
    have h_incons_phi := h_mcs.2 phi hphi
    have h_incons_neg := h_mcs.2 (Formula.neg phi) hneg
    -- From h_incons_phi, get Gamma_1 ⊆ S with Gamma_1 ⊢ ¬phi
    obtain ⟨Gamma_1, h_Gamma_1_sub, ⟨d_neg_phi⟩⟩ := extract_neg_derivation h_incons_phi h_mcs.1
    -- From h_incons_neg, get Gamma_2 ⊆ S with Gamma_2 ⊢ ¬¬phi
    obtain ⟨Gamma_2, h_Gamma_2_sub, ⟨d_neg_neg_phi⟩⟩ := extract_neg_derivation h_incons_neg h_mcs.1
    -- ... combined to get contradiction
```

### 2. Related Theorem Also Implemented

The theorem `mcs_modus_ponens` (Task 587) is also fully proven at lines 274-308 with no sorry:

```lean
theorem mcs_modus_ponens {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    {phi psi : Formula} (h_imp : Formula.imp phi psi ∈ S) (h_ant : phi ∈ S) : psi ∈ S := by
  -- Uses mcs_contains_or_neg for the proof
```

### 3. File Compiles Successfully

Verified via `lean_diagnostic_messages` - the file compiles with only info messages (from `#check` statements), no errors or warnings.

### 4. README.md Out of Date

The README at `Theories/Bimodal/Metalogic_v2/README.md` incorrectly lists these theorems as having sorries:

```markdown
| `mcs_contains_or_neg` | Representation/CanonicalModel.lean | sorry (MCS property) |
| `mcs_modus_ponens` | Representation/CanonicalModel.lean | sorry (MCS property) |
```

This should be updated to reflect the proven status.

### 5. Remaining Sorries in Metalogic_v2

Actual remaining sorries found:

| File | Line | Declaration | Status |
|------|------|-------------|--------|
| Core/Basic.lean | 56 | `consistent_iff_consistent'` | sorry (ex-falso dependency) |
| Representation/TruthLemma.lean | 160 | `necessitation_lemma` | sorry |

### 6. Related Mathlib Theorems

Found via lean_leansearch - relevant pattern for future reference:

```lean
FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem :
  T.IsMaximal → ∀ (phi : L.Sentence), phi ∈ T ∨ phi.not ∈ T
```

This is the Mathlib analog of the proven theorem.

## Decisions

1. **Task status**: Since the theorem is already proven, Task 586 should be marked as [COMPLETED]
2. **README update needed**: A follow-up to update the README to reflect accurate sorry counts
3. **Task 587 status**: Similarly should be checked - `mcs_modus_ponens` is also proven

## Recommendations

1. **Mark task 586 as COMPLETED** - The theorem `mcs_contains_or_neg` is fully proven
2. **Mark task 587 as COMPLETED** - The theorem `mcs_modus_ponens` is fully proven
3. **Update README.md** - Remove these from the "With Sorries" section and add to "Proven" section
4. **Proceed with tasks 588-590** - These depend on 586/587 which are now confirmed as solid foundations:
   - Task 588: `necessitation_lemma` in TruthLemma.lean (line 160) - still has sorry
   - Task 589: Complete RepresentationTheorem
   - Task 590: Eliminate axiom in ContextProvability

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Task description stale | Low | Verify before each task starts |
| README accuracy | Medium | Update README when tasks complete |
| Dependency chain assumptions | Low | Tasks 588-590 verified to actually depend on these theorems |

## Appendix

### Search Queries Used

1. `lean_leansearch`: "maximal consistent set contains formula or negation"
   - Found: `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem`

2. `lean_leansearch`: "modus ponens in maximal consistent theory"
   - Found related closure properties

3. `lean_leanfinder`: "maximal consistent set closed under modus ponens derivability"
   - Found: `FirstOrder.Language.Theory.IsMaximal` definition

4. `lean_local_search`: "mcs_contains_or_neg"
   - Found: theorem in both Metalogic/ and Metalogic_v2/

### Key Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/README.md`

### Proof Structure of mcs_contains_or_neg

The proven theorem uses this structure:
1. Case split on whether phi ∈ S
2. If yes: done (left disjunct)
3. If no: prove neg phi ∈ S by contradiction
   - Assume neg phi ∉ S
   - By maximality: both insert phi S and insert (neg phi) S are inconsistent
   - Extract derivations: Gamma_1 ⊢ neg phi and Gamma_2 ⊢ neg(neg phi)
   - Weaken both to combined context
   - Apply double negation elimination to get Gamma ⊢ phi
   - Combine with Gamma ⊢ neg phi to derive Gamma ⊢ bot
   - This contradicts SetConsistent S

## Next Steps

Since task 586 is already completed, the recommended next step is to run `/plan 588` to create an implementation plan for the actual remaining sorry (`necessitation_lemma` in TruthLemma.lean).
