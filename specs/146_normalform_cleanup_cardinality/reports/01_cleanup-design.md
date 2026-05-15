# Research Report: NormalForm Cleanup and Cardinality Theorem

- **Task**: 146 - NormalForm legacy cleanup and cardinality correspondence proof
- **Started**: 2026-05-15T14:00:00Z
- **Completed**: 2026-05-15T14:30:00Z
- **Effort**: Analysis
- **Dependencies**: 145 (split NEquivalence.lean)
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` (572 lines, 0 sorries)
  - `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (610 lines)
  - Doets 1987 thesis, Chapter 1, Section 1.7 (counting n-characteristics)
  - Task 143 reports
- **Artifacts**: This file
- **Standards**: report.md, status-markers.md, artifact-management.md, tasks.md

## Executive Summary

- After task 145 resolves the circular import, several pieces of dead code remain: the vacuous `nf_eval`, `nf_vector`, the legacy `doets_lemma_1_1` statement using `nf_vector`, and potentially `NormalFormIdx`/`nfCount`/`atomCount` duplicates.
- For publication quality, the cardinality correspondence `Fintype.card (NormalForm sig k n) = nfCount (Fintype.card sig.preds) k n` should be proved, confirming the counting function matches the actual type.
- The `AtomKind` cardinality should also be confirmed: `Fintype.card (AtomKind sig n) = atomCount (Fintype.card sig.preds) n`.
- Several docstring improvements are needed for publication readiness.

## Context & Scope

### Dead Code Inventory

After task 145 redesigns KType to use `NormalForm`, the following become dead code:

**In NormalForm.lean** (lines 412-431):
```lean
-- Legacy vacuous nf_eval (line 418)
noncomputable def nf_eval (sig : MonadicSignature) (k n : Nat)
    (_idx : NormalFormIdx sig k n) (M : OrderedMonadicStructure sig)
    (_env : Fin n → M.carrier) : Prop :=
  let _ := M.carrier
  Classical.choice (inferInstance : Nonempty Prop)

-- Legacy nf_vector (line 427)
noncomputable def nf_vector (sig : MonadicSignature) (k n : Nat)
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier) :
    NormalFormIdx sig k n → Bool :=
  fun idx => @decide (nf_eval sig k n idx M env) (Classical.dec _)
```

**In NormalForm.lean** (line 567-570):
```lean
-- Legacy NormalFormIdx nonempty instance
instance normalFormIdx_nonempty (sig : MonadicSignature) (k n : Nat) :
    Nonempty (NormalFormIdx sig k n) :=
  ⟨⟨0, nfCount_pos _ _ _⟩⟩
```

**Potentially in NEquivalence.lean** (after task 145):
- `nf_rep` -- deleted by task 145
- `NormalFormIdx` -- keep as documentation but no longer the KType domain
- `atomCount`, `nfCount`, `nfCount_pos` -- keep (referenced by cardinality theorem, useful documentation)

### Cardinality Correspondences to Prove

**Theorem 1: AtomKind cardinality**
```lean
theorem atomKind_card (sig : MonadicSignature) (n : Nat) :
    Fintype.card (AtomKind sig n) = atomCount (Fintype.card sig.preds) n
```

The proof uses the `Equiv` to `sig.preds × Fin n ⊕ {p : Fin n × Fin n // p.1 ≠ p.2}` (already defined in `atomKind_fintype`), then:
- `Fintype.card (sig.preds × Fin n) = Fintype.card sig.preds * n` (product cardinality)
- `Fintype.card {p : Fin n × Fin n // p.1 ≠ p.2} = n * n - n = n * (n - 1)` (pairs minus diagonal)
- Sum: `Fintype.card sig.preds * n + n * (n - 1) = atomCount (Fintype.card sig.preds) n`

The diagonal subtraction `Fintype.card {p : Fin n × Fin n // p.1 ≠ p.2} = n * (n - 1)` requires a Mathlib lemma about the cardinality of the off-diagonal. Candidates:
- `Fintype.card_subtype_compl` or similar
- Direct computation via `Finset.filter`

**Theorem 2: NormalForm cardinality**
```lean
theorem normalForm_card (sig : MonadicSignature) (k n : Nat) :
    Fintype.card (NormalForm sig k n) = nfCount (Fintype.card sig.preds) k n
```

Proof by induction on `k`:

**Base case (k=0)**:
```
NormalForm sig 0 n = AtomKind sig n → Bool
Fintype.card (AtomKind sig n → Bool) = 2 ^ Fintype.card (AtomKind sig n)
                                     = 2 ^ atomCount p n
                                     = nfCount p 0 n
```

Uses `Fintype.card_fun` (or `Fintype.card_pi` + `Fintype.card_bool`) and `atomKind_card`.

**Inductive step (k → k+1)**:
```
NormalForm sig (k+1) n = (AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)
Fintype.card (...) = Fintype.card (AtomKind sig n → Bool) * Fintype.card (NormalForm sig k (n+1) → Bool)
                   = 2^(atomCount p n) * 2^(Fintype.card (NormalForm sig k (n+1)))
                   = 2^(atomCount p n) * 2^(nfCount p k (n+1))    -- by IH
                   = 2^(atomCount p n + nfCount p k (n+1))
                   = nfCount p (k+1) n
```

Uses `Fintype.card_prod`, `Fintype.card_fun`, `Nat.pow_add`, and the IH.

### Docstring Improvements Needed

1. **NormalForm.lean module docstring** (lines 1-33): Currently accurate but should reference the cardinality correspondence once proved.

2. **nf_eval_nf docstring** (line 188): Good. Could note that this replaces the vacuous `nf_eval`.

3. **doets_lemma_1_1 docstring** (line 443): Good. Could reference Doets 1987 Theorem 1.6.3 (the characterization theorem that this formalizes).

4. **nf_agreement_monotone docstring** (line 329): Good. Could note this is the mathematical content of `k_equiv_monotone`.

5. **NormalForm type docstring** (line 124): Should note the non-positive occurrence workaround (recursive def instead of inductive) and that the type is definitionally equal to its unfolding at each depth.

### Optional: NormalFormIdx Equivalence

For maximum mathematical cleanliness, prove that `NormalForm sig k n` is equivalent to `NormalFormIdx sig k n` (= `Fin (nfCount p k n)`):

```lean
noncomputable def normalForm_equiv_fin (sig : MonadicSignature) (k n : Nat) :
    NormalForm sig k n ≃ NormalFormIdx sig k n
```

This is a consequence of the cardinality theorem + `Fintype.equivFin`, but having it explicit shows the Fin-based and inductive approaches are isomorphic. This is optional but completes the mathematical picture.

## Recommendations

1. **Delete dead code**: Remove vacuous `nf_eval`, `nf_vector`, `normalFormIdx_nonempty` from NormalForm.lean once task 145 ensures nothing references them.
2. **Prove `atomKind_card`**: Confirm `Fintype.card (AtomKind sig n) = atomCount p n`. Medium difficulty (off-diagonal counting).
3. **Prove `normalForm_card`**: Confirm `Fintype.card (NormalForm sig k n) = nfCount p k n`. Medium difficulty (induction with Mathlib cardinality lemmas).
4. **Update docstrings**: Reference cardinality theorems, note historical context (task 143 evolution from Fin-based to inductive).
5. **Consider `NormalFormIdx` retention**: Keep `NormalFormIdx`, `atomCount`, `nfCount` in the codebase as documentation and for the cardinality correspondence, even though they are no longer the primary types.
6. **Optional: `normalForm_equiv_fin`**: Prove the explicit equivalence for completeness.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Off-diagonal cardinality proof is fiddly | Use `Finset.card_filter` + `Finset.card_univ` or search Mathlib for `Fintype.card_subtype_compl` |
| `Fintype.card_fun` not available in exact form | Use `Fintype.card_pi` with `Fintype.card_bool` |
| `normalForm_card` IH needs generalized `n` | The induction already generalizes over `n` (same as `normalForm_fintype`) |
| Removing dead code breaks something | Task 145 must complete first; grep for all references before deletion |
