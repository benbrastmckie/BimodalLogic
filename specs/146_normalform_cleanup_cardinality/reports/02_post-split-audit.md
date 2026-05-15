# Research Report: Post-Split Audit and Cardinality Proof Strategies

- **Task**: 146 - NormalForm legacy cleanup and cardinality correspondence proof
- **Started**: 2026-05-15T15:00:00Z
- **Completed**: 2026-05-15T15:45:00Z
- **Effort**: Analysis + proof verification
- **Dependencies**: 145 (completed: split NEquivalence.lean into MonadicFO.lean + NEquivalence.lean)
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` (573 lines, 0 sorries)
  - `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` (406 lines, 0 sorries)
  - `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (263 lines, 1 sorry in sum_preservation)
  - Prior report: `specs/146_normalform_cleanup_cardinality/reports/01_cleanup-design.md`
  - Doets 1987 thesis, Section 1.6-1.7
- **Artifacts**: This file
- **Standards**: report.md, status-markers.md, artifact-management.md, tasks.md

## Executive Summary

- Task 145 is confirmed complete: `nf_rep` deleted, `KType` now uses `NormalForm sig k 0 -> Bool`, `k_equiv_monotone` closed via `nf_agreement_monotone`.
- Dead code audit confirms exactly three definitions to remove from NormalForm.lean: `nf_eval` (lines 419-423), `nf_vector` (lines 428-431), `normalFormIdx_nonempty` (lines 569-571), plus the legacy section header (line 413).
- Both cardinality proofs (`atomKind_card`, `normalForm_card`) have been fully verified via `lean_run_code` -- they compile cleanly with zero sorries and zero new imports.
- The optional `normalForm_equiv_fin` equivalence is a one-liner using `Fintype.equivFinOfCardEq`.
- No downstream breakage: the dead code has zero references outside its own definitions.

## Dead Code Audit (Post-Task-145)

### Confirmed Dead Code in NormalForm.lean

| Definition | Lines | Why Dead | References Outside Self |
|---|---|---|---|
| `nf_eval` | 419-423 | Vacuous legacy evaluator on `NormalFormIdx`; replaced by `nf_eval_nf` which operates on `NormalForm` | None (only called by `nf_vector`) |
| `nf_vector` | 428-431 | Legacy boolean vector built from vacuous `nf_eval`; `KType` now uses `NormalForm sig k 0 -> Bool` directly | None |
| `normalFormIdx_nonempty` | 569-571 | `Nonempty (NormalFormIdx sig k n)` instance; `NormalFormIdx` is no longer the KType domain | None |
| Legacy section header | 413 | `/-! ## Legacy Definitions (to be replaced in Phase 10) -/` | N/A |

### Verification Method

Grep across all `.lean` files in the project confirmed:
- `nf_eval ` (space-delimited, excluding `nf_eval_nf` and `nf_eval_unique`): only appears in its own definition and inside `nf_vector`
- `nf_vector`: only appears in its own definition
- `normalFormIdx_nonempty`: only appears in its own definition
- `nf_rep`: fully deleted by task 145 (zero matches)

### Retained Definitions

| Definition | Location | Why Keep |
|---|---|---|
| `NormalFormIdx` | MonadicFO.lean:403 | Target of `normalForm_equiv_fin`; documents the Fin-based alternative |
| `atomCount` | MonadicFO.lean:380 | Used by `atomKind_card`; mathematical reference |
| `nfCount` | MonadicFO.lean:389 | Used by `normalForm_card`; mathematical reference |
| `nfCount_pos` | MonadicFO.lean:394 | Could be used by `normalFormIdx_nonempty` if kept; also generally useful |

## Cardinality Proof Strategies (Verified)

### Theorem 1: `atomKind_card`

```lean
theorem atomKind_card (sig : MonadicSignature) (n : Nat) :
    Fintype.card (AtomKind sig n) = atomCount (Fintype.card sig.preds) n
```

**Proof strategy** (verified via `lean_run_code`):

1. Use `Fintype.card_congr` with the equivalence `AtomKind sig n ≃ sig.preds × Fin n ⊕ {p : Fin n × Fin n // p.1 ≠ p.2}` (same equiv already constructed in `atomKind_fintype`)
2. Apply `Fintype.card_sum`, `Fintype.card_prod`, `Fintype.card_fin`
3. For the off-diagonal: `Fintype.card_subtype` converts to `Finset.filter`, then equate with `Finset.offDiag` via `ext`, then apply `Finset.offDiag_card`
4. Final arithmetic: `n * n - n = n * (n - 1)` by case split on `n` with `simp [Nat.succ_mul, Nat.mul_succ]`

**Key Mathlib lemmas** (all transitively available from existing imports):
- `Fintype.card_congr` -- cardinality under equivalence
- `Fintype.card_sum` -- `card (A ⊕ B) = card A + card B`
- `Fintype.card_prod` -- `card (A × B) = card A * card B`
- `Fintype.card_fin` -- `card (Fin n) = n`
- `Fintype.card_subtype` -- convert subtype card to filter card
- `Finset.offDiag_card` -- `s.offDiag.card = s.card * s.card - s.card`

**Complete verified proof** (23 lines):
```lean
theorem atomKind_card (sig : MonadicSignature) (n : Nat) :
    Fintype.card (AtomKind sig n) = atomCount (Fintype.card sig.preds) n := by
  rw [show Fintype.card (AtomKind sig n) =
    Fintype.card (sig.preds × Fin n ⊕ {p : Fin n × Fin n // p.1 ≠ p.2}) from by
    exact Fintype.card_congr {
      toFun := fun x => match x with
        | .pred p i => .inl ⟨p, i⟩
        | .order i j h => .inr ⟨⟨i, j⟩, h⟩
      invFun := fun x => match x with
        | .inl ⟨p, i⟩ => AtomKind.pred p i
        | .inr ⟨⟨i, j⟩, h⟩ => AtomKind.order i j h
      left_inv := by intro x; cases x with | pred _ _ => rfl | order _ _ _ => rfl
      right_inv := by intro x; cases x with
        | inl p => cases p; rfl
        | inr p => cases p; rename_i v hv; cases v; rfl
    }]
  rw [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]
  rw [Fintype.card_subtype]
  have h1 : (Finset.univ.filter (fun x : Fin n × Fin n => x.1 ≠ x.2)) =
    (Finset.univ : Finset (Fin n)).offDiag := by
    ext ⟨a, b⟩; simp [Finset.mem_offDiag, Finset.mem_filter]
  rw [h1, Finset.offDiag_card, Finset.card_univ, Fintype.card_fin]
  simp [atomCount]
  cases n with
  | zero => simp
  | succ m => simp [Nat.succ_mul, Nat.mul_succ]
```

### Theorem 2: `normalForm_card`

```lean
theorem normalForm_card (sig : MonadicSignature) (k n : Nat) :
    Fintype.card (NormalForm sig k n) = nfCount (Fintype.card sig.preds) k n
```

**Proof strategy** (verified via `lean_run_code`):

Induction on `k`, generalizing `n`:

**Base case (k = 0)**:
- `NormalForm sig 0 n` unfolds to `AtomKind sig n -> Bool`
- `Fintype.card_fun` + `Fintype.card_bool` gives `2 ^ Fintype.card (AtomKind sig n)`
- `atomKind_card` converts to `2 ^ atomCount p n = nfCount p 0 n`

**Inductive step (k + 1)**:
- `NormalForm sig (k+1) n` unfolds to `(AtomKind sig n -> Bool) × (NormalForm sig k (n+1) -> Bool)`
- `Fintype.card_prod` + `Fintype.card_fun` + `Fintype.card_bool` decompose the product
- `atomKind_card` + induction hypothesis convert the pieces
- `Nat.pow_add` combines: `2^a * 2^b = 2^(a+b)`

**Key Mathlib lemmas**:
- `Fintype.card_fun` -- `card (α → β) = card β ^ card α`
- `Fintype.card_bool` -- `card Bool = 2`
- `Fintype.card_prod` -- `card (A × B) = card A * card B`
- `Nat.pow_add` -- `a^(b+c) = a^b * a^c`

**Complete verified proof** (12 lines):
```lean
theorem normalForm_card (sig : MonadicSignature) (k n : Nat) :
    Fintype.card (NormalForm sig k n) = nfCount (Fintype.card sig.preds) k n := by
  induction k generalizing n with
  | zero =>
    simp only [NormalForm, nfCount]
    rw [Fintype.card_fun, Fintype.card_bool, atomKind_card]
  | succ k ih =>
    simp only [NormalForm, nfCount]
    rw [Fintype.card_prod, Fintype.card_fun, Fintype.card_bool,
        Fintype.card_fun, Fintype.card_bool, atomKind_card, ih]
    rw [Nat.pow_add]
```

### Optional: `normalForm_equiv_fin`

```lean
noncomputable def normalForm_equiv_fin (sig : MonadicSignature) (k n : Nat) :
    NormalForm sig k n ≃ NormalFormIdx sig k n :=
  Fintype.equivFinOfCardEq (normalForm_card sig k n)
```

One-liner using `Fintype.equivFinOfCardEq` which takes `Fintype.card α = n` and returns `α ≃ Fin n`. Since `NormalFormIdx sig k n = Fin (nfCount p k n)` and `normalForm_card` proves `Fintype.card (NormalForm sig k n) = nfCount p k n`, the types align directly.

## Import Analysis

No new imports are required. All Mathlib lemmas used in the cardinality proofs are transitively available through the existing import chain:
- `NormalForm.lean` imports `MonadicFO.lean`
- `MonadicFO.lean` imports `Mathlib.Data.Fintype.Card`, `Mathlib.Data.Finset.Basic`, etc.
- The transitive closure provides: `Fintype.card_fun`, `Fintype.card_bool`, `Fintype.card_prod`, `Fintype.card_sum`, `Fintype.card_fin`, `Fintype.card_subtype`, `Fintype.card_congr`, `Finset.offDiag_card`, `Nat.pow_add`, `Fintype.equivFinOfCardEq`

## Docstring Updates Needed

1. **Module docstring** (lines 1-34): Add `atomKind_card`, `normalForm_card`, and `normalForm_equiv_fin` to the list of provided definitions. Remove references to legacy `nf_eval`/`nf_vector` in the "core definitions" list.

2. **Legacy section header** (line 413): Delete entirely (the legacy definitions below it are being removed).

3. **"Additional Instances" section** (line 566): Delete the section header `/-! ## Additional Instances -/` since `normalFormIdx_nonempty` is the only content and it's being removed. The new cardinality theorems can go in a new section `/-! ## Cardinality Correspondences -/`.

4. **NormalForm type docstring** (lines 112-124): Already good. Could optionally note the cardinality correspondence once proved.

## Downstream Impact

- **NEquivalence.lean**: No impact. `KType` uses `NormalForm sig k 0 -> Bool`, not `NormalFormIdx`. The `k_equiv_monotone` proof uses `nf_agreement_monotone` from NormalForm.lean, which is not affected.
- **WeakCanonical.lean**: Aggregator import only, no code changes needed.
- **MonadicFO.lean**: No changes needed. `NormalFormIdx`, `atomCount`, `nfCount`, `nfCount_pos` all stay.
- **Build**: Confirmed clean build (1648 jobs, 0 errors).

## Placement Strategy

The new theorems should be placed at the end of NormalForm.lean, replacing the deleted dead code and the `normalFormIdx_nonempty` instance:

```
Line 412: end of nf_agreement_monotone proof
---  DELETE lines 413-431 (legacy section + nf_eval + nf_vector)  ---
Line 433-564: doets_lemma_1_1 (KEEP, unchanged)
---  DELETE lines 566-571 (Additional Instances section + normalFormIdx_nonempty)  ---
NEW: /-! ## Cardinality Correspondences -/
NEW: atomKind_card
NEW: normalForm_card
NEW: normalForm_equiv_fin (optional)
Line 573: end namespace
```

## Recommendations

1. **Delete dead code**: Remove `nf_eval`, `nf_vector`, `normalFormIdx_nonempty`, and the legacy section header. Safe -- zero downstream references.

2. **Add `atomKind_card`**: Verified proof, 23 lines. Place after `doets_lemma_1_1`.

3. **Add `normalForm_card`**: Verified proof, 12 lines. Place after `atomKind_card`.

4. **Add `normalForm_equiv_fin`**: 3-line noncomputable def. Place after `normalForm_card`.

5. **Update docstrings**: Module docstring should list the new theorems and remove legacy references.

6. **No new imports needed**: All Mathlib dependencies are transitively available.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Off-diagonal proof fragile to Mathlib changes | Low | Uses stable `Finset.offDiag_card` API |
| `simp only [NormalForm, nfCount]` unfolding breaks | Low | `NormalForm` is a def (not `@[reducible]`), so `simp only` unfolds exactly one level |
| Typeclass inference slowdown from new instances | Very Low | Theorems, not instances -- no inference impact |
| `normalForm_equiv_fin` noncomputability propagates | Low | Already noncomputable; `NormalFormIdx` is only documentation |
