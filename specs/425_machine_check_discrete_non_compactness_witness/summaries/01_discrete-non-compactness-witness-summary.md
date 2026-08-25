# Implementation Summary: Discrete non-compactness witness

- **Task**: 425 — Machine-check the Discrete non-compactness witness
- **Plan**: `specs/425_machine_check_discrete_non_compactness_witness/plans/01_discrete-non-compactness-witness.md`
- **Research**: `specs/425_machine_check_discrete_non_compactness_witness/reports/01_discrete-non-compactness-witness.md`
- **Type**: lean4
- **Outcome**: all six phases COMPLETED; acceptance met in full

## What landed

The informal argument in `FormalSystem/Metalogic/StrongCompleteness.lean`'s module docstring is
now a machine-checked theorem. The premise set

  `archWitness p = {F p} ∪ {¬Xⁿ p : n ∈ ℕ}`,  `X φ = Formula.next φ = Formula.untl Formula.bot φ`

is finitely satisfiable over `ℤ` and unsatisfiable over every Archimedean discrete carrier, which
refutes compactness — and, through `soundness_discrete`, strong completeness — for
`FrameClass.Discrete`.

### New declarations

`FormalSystem/Metalogic/SetConsequence.lean` (vocabulary):
- `SatisfiableDiscreteSet` — `FormulaSatisfiable` at `ValidDiscrete`'s binder list, generalised
  to `∀ ψ ∈ Γ`.
- `CompactDiscrete` — the `CompactDense` shape against `SetSemanticConsequenceDiscrete`.
- `StrongCompletenessDiscrete` — the `StrongCompletenessDense` shape, likewise.

`FormalSystem/Metalogic/DiscreteNonCompactness.lean` (new module):
- `truthAt_next_iff` — the first semantic characterisation of `Formula.next` anywhere in the
  tree: `X φ` at `t` iff `φ` at `Order.succ t`. Deliberately not `@[simp]`.
- `truthAt_next_iterate` — its iterated form.
- `archWitness`, `nextDepth`, `witIdx`, `nextDepth_next_iterate`, `witIdx_neg_next_iterate`.
- `zHistory`, `zModel`, `zHistory_total`, `zTruth_atom`, `succ_iterate_zero_int` — the concrete
  `ℤ` model on `TaskFrame.natFrame`.
- **`archWitness_finitely_satisfiable`** — every finite sublist is satisfiable; threshold
  `(L.map witIdx).sum`, bound by `List.single_le_sum`.
- **`archWitness_not_satisfiable`** — no Archimedean discrete carrier models the whole set;
  reachability by `(Order.succ_le_of_lt hts).exists_succ_iterate`.
- **`discrete_consequence_not_compact`** — `¬ CompactDiscrete`.
- `strongCompletenessDiscrete_refuted` — `¬ StrongCompletenessDiscrete`.

The three bolded names are the task's stated acceptance set.

## Axiom audit (measured)

```
'FormalSystem.Metalogic.truthAt_next_iff'                  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.truthAt_next_iterate'              [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.archWitness_finitely_satisfiable'  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.archWitness_not_satisfiable'       [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.discrete_consequence_not_compact'  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.strongCompletenessDiscrete_refuted'[propext, Classical.choice, Quot.sound]
```

No `sorryAx`. Identical to the set carried by `completeness_dense`, `completeness_discrete` and
`consequence_completeness_dedekind`.

## Verification

| Check | Result |
|---|---|
| `lake build` (whole tree) | exit 0, 2464 jobs |
| `#print axioms` on all six new declarations | exactly the three classical axioms |
| Structural `sorry` in the new module | zero (the only textual hit is the prose ``sorryAx``-free in the audit docstring) |
| New axiom declarations | zero (all seven `^axiom ` grep hits repo-wide are line-wrapped docstring prose, same files as at baseline `1f192f3f8`) |
| Vacuous definitions | zero introduced (the single repo hit, `Examples/TemporalStructures.lean:538`, is pre-existing and untouched) |
| `bash scripts/check-module-invariants.sh` | ALL CHECKS PASSED — C3 (sole structural sorry unchanged), C4, C5, C8, C9 included |
| Out-of-scope guard: `grep Dedekind` in the new module | no match |

## Documentation closure

- `StrongCompleteness.lean` — the `FrameClass.Discrete` docstring bullet (`:56-62`) and the
  reserved section comment (`:411-421`) now cite the theorems by name. The prose was kept, per
  plan; the already-correct `Formula.next φ = Formula.untl Formula.bot φ` rendering was left
  alone (it is the guard-first form; the *task description* and the archived design document
  carry the stale swapped form, not the tree).
- `FormalSystem/Metalogic.lean` — aggregator import, a Publication-Ready Results bullet for
  `discrete_consequence_not_compact`, and a Key Components entry for the new module.
- `SetConsequence.lean` — module docstring widened to name Discrete and to record that the Dense
  compactness statement is an **open obligation** while the Discrete one is **refuted**. The two
  statuses are explicitly told apart so the section cannot be misread.

## Plan Deviations

- Phase 5, `strongCompletenessDiscrete_refuted` — *altered*: `open FormalSystem.ProofSystem` was
  added to the new module's `open` line (`FrameClass`, used by `StrongCompletenessDiscrete`,
  lives there), and `Derivable`'s `Nonempty` wrapper was destructured (`⟨L, hL, ⟨d⟩⟩`) so that
  `soundness_discrete` receives the `DerivationTree` itself rather than the `Nonempty`. Report §5
  marked this proof an uncompiled sketch; these two adjustments are what it needed. The plan's
  `[COMPLETED WITH EXCLUSIONS]` escape path was **not** used — the phase landed in full.

No other deviations. Phases 1-4 and 6 followed the plan as written, and report §3's proof text
transcribed with **zero repair edits** — the transcription hypothesis in the plan's Phase 4 Scope
Hypothesis held exactly.

## Files modified

- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` (new)
- `FormalSystem/Metalogic/SetConsequence.lean`
- `FormalSystem/Metalogic.lean`
- `FormalSystem/Metalogic/StrongCompleteness.lean` (docstring/comment only)

## Out of scope, confirmed untouched

No Dedekind non-compactness witness was introduced. `CompactDense` and `ModelExistenceDense`
remain open and unmodified. `truthAt_next_iff` / `truthAt_next_iterate` were not promoted to
`Semantics/Truth.lean`; the module docstring records that as their eventual home once a second
consumer appears.
