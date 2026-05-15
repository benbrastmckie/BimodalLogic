# Research Report: Split NEquivalence.lean and Close k_equiv_monotone

- **Task**: 145 - Split NEquivalence.lean, redesign KType to NormalForm, close k_equiv_monotone
- **Started**: 2026-05-15T14:00:00Z
- **Completed**: 2026-05-15T14:30:00Z
- **Effort**: Analysis
- **Dependencies**: 143 (completed)
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (610 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` (572 lines, 0 sorries)
  - Task 143 reports and implementation summary
- **Artifacts**: This file
- **Standards**: report.md, status-markers.md, artifact-management.md, tasks.md

## Executive Summary

- `k_equiv_monotone` in NEquivalence.lean (line 453) is sorry because NEquivalence.lean cannot import NormalForm.lean (circular import). The sorry-free proof `nf_agreement_monotone` exists in NormalForm.lean.
- `KType`, `k_type_of`, `nf_rep` in NEquivalence.lean still use the vacuous `NormalFormIdx`/`Classical.choice` approach, despite the correct `NormalForm`/`nf_eval_nf` being available in NormalForm.lean.
- The fix requires splitting NEquivalence.lean to break the circular import, then rewiring KType to use the concrete NormalForm infrastructure.
- After this task, every definition in the k-equivalence chain will have concrete semantic content, and `k_equiv_monotone` will be sorry-free.

## Context & Scope

### The Circular Import

```
NEquivalence.lean
  imports: ReflexiveCanonical, ChronicleExtraction, Mathlib.Data.Finset.Basic
  defines: MonadicSignature (line 53), MonadicFormula (line 75), eval (line 228),
           atomCount (line 342), nfCount (line 351), NormalFormIdx (line 365),
           KType (line 383), nf_rep (line 400), k_type_of (line 414),
           k_equiv (line 422), k_equiv_monotone (line 450, SORRY),
           KEquivalenceFramework instance (line 477)
  also: MonadicStructure (line 104), OrderedMonadicStructure (line 115),
        insertEnv (line 282), lift_eval (line 306), weaken_eval (line 329)
  sorries: 8 total (4 task 141 insertEnv/lift_eval, 1 k_equiv_monotone,
           2 carrier_order, 1 sum_preservation)

NormalForm.lean
  imports: NEquivalence.lean
  defines: AtomKind (line 48), atom_eval (line 103), NormalForm (line 124),
           nf_eval_nf (line 188), nf_characteristic (line 205),
           nf_exists_unique (line 267), doets_lemma_1_1 (line 443),
           nf_agreement_monotone (line 329)
  sorries: 0
```

NormalForm.lean imports NEquivalence.lean because it needs `MonadicSignature`, `MonadicFormula`, `eval`, `OrderedMonadicStructure`, `atomCount`, `nfCount`, `NormalFormIdx`, and `Fin.cons`. NEquivalence.lean cannot import NormalForm.lean back without creating a cycle.

### What Files Import NEquivalence.lean

- `NormalForm.lean` -- needs MonadicSignature, MonadicFormula, eval, etc.
- `Table.lean` -- needs MonadicFormula, eval
- `OrderedSum.lean` -- needs k_equiv, KEquivalenceFramework
- `WeakCanonical.lean` -- aggregator (imports everything)

### What Files Import NormalForm.lean

- `WeakCanonical.lean` -- aggregator only

## Findings

### Definitions to Extract into MonadicFO.lean

The following definitions in NEquivalence.lean are **pure FO logic** with no dependency on ReflexiveCanonical, ChronicleExtraction, or the canonical model:

| Definition | Line | Dependencies |
|---|---|---|
| `MonadicSignature` | 53 | None (structure) |
| `MonadicSignature.fintypePreds` attribute | 58 | MonadicSignature |
| `MonadicSignature.decEqPreds` attribute | 59 | MonadicSignature |
| `MonadicFormula` | 75 | MonadicSignature |
| `MonadicFormula.quantifier_depth` | 88 | MonadicFormula |
| `MonadicStructure` | 104 | MonadicSignature |
| `OrderedMonadicStructure` | 115 | MonadicStructure |
| `eval` | 228 | OrderedMonadicStructure, MonadicFormula |
| `MonadicFormula.weaken` | ~266 | MonadicFormula |
| `insertEnv` | 282 | None (pure function) |
| `insertEnv_zero_eq_cons` | 292 | insertEnv (sorry -- task 141) |
| `insertEnv_succ_cons` | 296 | insertEnv (sorry -- task 141) |
| `lift_eval` | 306 | eval, insertEnv (sorry -- task 141) |
| `weaken_eval` | 329 | lift_eval, insertEnv_zero_eq_cons |
| `atomCount` | 342 | None (pure function) |
| `nfCount` | 351 | atomCount |
| `nfCount_pos` | 356 | nfCount |
| `NormalFormIdx` | 365 | nfCount, MonadicSignature |

These are all self-contained FO definitions (lines 53-366, ~313 lines). They can be extracted into a new `MonadicFO.lean` file that imports only `Bimodal.Syntax`, `Bimodal.ProofSystem`, and `Mathlib.Data.Finset.Basic`.

### Definitions That Must Stay in NEquivalence.lean

These depend on `ReflexiveCanonical` or `ChronicleExtraction`:

| Definition | Line | Why it stays |
|---|---|---|
| Chronicle-related definitions | ~540+ | Uses ChronicleExtraction types |
| Anything referencing `MCS`, `Canon`, etc. | various | Canonical model infrastructure |

### Definitions That Move Into NEquivalence.lean (from NormalForm.lean)

After the split, NEquivalence.lean can import NormalForm.lean. The KType section should then be rewritten:

| Current (NEquivalence.lean) | New (NEquivalence.lean, importing NormalForm) |
|---|---|
| `KType sig k := NormalFormIdx sig k 0 → Bool` | `KType sig k := NormalForm sig k 0 → Bool` |
| `nf_rep` (Classical.choice, vacuous) | DELETED |
| `k_type_of` (uses nf_rep + eval) | `k_type_of M := fun nf => decide (nf_eval_nf M k 0 Fin.elim0 nf)` |
| `k_equiv` (unchanged API) | `k_equiv M N := k_type_of M = k_type_of N` (same) |
| `k_equiv_monotone` (sorry) | Proved via `nf_agreement_monotone` or direct call |
| `finite_types` (closed) | Remains closed (NormalForm is Fintype) |

### The k_equiv_monotone Proof Strategy

Once NEquivalence.lean can see `NormalForm` and `nf_agreement_monotone`, closing the sorry is straightforward. The proof must bridge between the KType-level equality (`k_type_of sig k M = k_type_of sig k N`) and the NormalForm-level agreement (`∀ nf, nf_eval_nf M k n env_M nf ↔ nf_eval_nf N k n env_N nf`).

With the redesigned `k_type_of`:
```
k_type_of sig k M = fun nf => decide (nf_eval_nf M k 0 Fin.elim0 nf)
```

The hypothesis `k_equiv sig k M N` means:
```
∀ nf : NormalForm sig k 0, decide (nf_eval_nf M k 0 Fin.elim0 nf) = decide (nf_eval_nf N k 0 Fin.elim0 nf)
```

Which is equivalent to:
```
∀ nf : NormalForm sig k 0, nf_eval_nf M k 0 Fin.elim0 nf ↔ nf_eval_nf N k 0 Fin.elim0 nf
```

Then `nf_agreement_monotone` gives:
```
∀ nf : NormalForm sig m 0, nf_eval_nf M m 0 Fin.elim0 nf ↔ nf_eval_nf N m 0 Fin.elim0 nf
```

Which converts back to `k_equiv sig m M N`. The bridge between `decide`-based equality and `↔` is `Bool.decide_eq_decide` or similar.

### Impact on finite_types

The current `finite_types` proof uses `Fintype.ofInjective` to inject the quotient into `KType sig k`. The proof structure is:

```lean
finite_types k := by
  have h_inj : Function.Injective (Quotient.lift (k_type_of sig k) ...) := by ...
  exact Fintype.ofInjective _ h_inj
```

When `KType` changes from `NormalFormIdx sig k 0 → Bool` to `NormalForm sig k 0 → Bool`, the proof structure is identical -- `NormalForm sig k 0 → Bool` is still `Fintype` (since `NormalForm sig k 0` is `Fintype`). The injectivity argument (`Quotient.lift` + `Quotient.sound`) is unchanged since `k_equiv` is still defined as `k_type_of M = k_type_of N`.

### New Import Graph After Split

```
MonadicFO.lean
  imports: Bimodal.Syntax, Bimodal.ProofSystem, Mathlib.Data.Finset.Basic
  defines: MonadicSignature, MonadicFormula, eval, atomCount, nfCount, NormalFormIdx, etc.

NormalForm.lean
  imports: MonadicFO.lean (was: NEquivalence.lean)
  defines: AtomKind, NormalForm, nf_eval_nf, doets_lemma_1_1, nf_agreement_monotone

NEquivalence.lean
  imports: MonadicFO.lean, NormalForm.lean, ReflexiveCanonical, ChronicleExtraction
  defines: KType (NormalForm-based), k_type_of (nf_eval_nf-based), k_equiv,
           k_equiv_monotone (sorry-free), KEquivalenceFramework

Table.lean -- imports: MonadicFO.lean (was: NEquivalence.lean) or NEquivalence.lean
OrderedSum.lean -- imports: NEquivalence.lean (unchanged)
IntegerModel.lean -- imports: OrderedSum.lean, Table.lean (unchanged)
Transfer.lean -- imports: IntegerModel.lean, OrderedSum.lean (unchanged)
```

### Downstream Impact Assessment

- **Table.lean**: Imports NEquivalence.lean for `MonadicFormula`, `eval`. After split, should import `MonadicFO.lean` instead (or transitively via NEquivalence.lean which re-exports).
- **OrderedSum.lean**: Uses `k_equiv`, `KEquivalenceFramework`. These stay in NEquivalence.lean. No change needed.
- **IntegerModel.lean**: Uses `k_equiv` transitively. No change needed.
- **Transfer.lean**: Uses `k_type_of` in comments only. No change needed.
- **NormalForm.lean**: Import changes from `NEquivalence` to `MonadicFO`. This is the key change.

### Verification After KType Redesign

After redefining `KType := NormalForm sig k 0 → Bool`:
1. `Fintype (KType sig k)` -- still `inferInstance` (`NormalForm sig k 0` is `Fintype`)
2. `k_type_of` -- uses `nf_eval_nf` (concrete, meaningful)
3. `k_equiv` -- same definition (equality of k-types)
4. `k_equiv_monotone` -- closed via `nf_agreement_monotone`
5. `finite_types` -- closed (same `Fintype.ofInjective` argument)

## Recommendations

1. **Extract lines 46-366 of NEquivalence.lean** into `MonadicFO.lean` (the namespace, opens, MonadicSignature through NormalFormIdx). Leave the insertEnv/lift_eval/weaken_eval sorries in place (they are task 141).
2. **Change NormalForm.lean import** from `NEquivalence` to `MonadicFO`.
3. **Add NormalForm.lean import** to NEquivalence.lean.
4. **Redefine KType, k_type_of** using NormalForm and nf_eval_nf.
5. **Delete nf_rep** (replaced by nf_eval_nf).
6. **Close k_equiv_monotone** using nf_agreement_monotone.
7. **Verify finite_types** remains closed.
8. **Run `lake build`** at each step.
9. **Verify downstream** (Table, OrderedSum, IntegerModel, Transfer) compile.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Downstream files break from import change | Table.lean may need import adjustment; others are transitive |
| finite_types proof breaks from KType change | Structure is identical; only domain type changes |
| insertEnv/lift_eval sorries complicate the split | These move with the rest of MonadicFO; no interaction with NormalForm |
| `open Bimodal.Syntax` / `open Bimodal.ProofSystem` needed in MonadicFO | Copy the `open` statements to MonadicFO.lean |
| NormalForm.lean references `NormalFormIdx` from NEquivalence | `NormalFormIdx` moves to MonadicFO.lean; NormalForm.lean already imports it |
