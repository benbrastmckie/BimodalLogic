# Implementation Summary: Carrier Normalization — the Successor-Archimedean Transfer

- **Task**: 475 - CARRIER NORMALIZATION: THE SUCCESSOR-ARCHIMEDEAN TRANSFER
- **Plan**: `plans/01_carrier-normalization-int-transfer.md`
- **Status**: [COMPLETED] — all six phases
- **Type**: lean4

## What landed

`ValidDiscrete φ ↔ ValidInt φ`. Quantifying over every discrete duration carrier — every
nontrivial successor-Archimedean ordered abelian group — is the same as quantifying over `ℤ`
alone.

### Step 1 — `FormalSystem/Semantics/DurationClassification.lean`

Five declarations closing the successor-Archimedean gap, stated at the **reduced** binder bundle
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [Nontrivial D]` (plus
`[IsSuccArchimedean D]` on the last two). `PredOrder D` and `IsPredArchimedean D` are *not*
present — the research pass measured them unused by `intIso`, and that held.

| Declaration | Role |
|---|---|
| `isLeast_pos_succ_zero` | `IsLeast {y : D \| 0 < y} (Order.succ 0)` — the witness |
| `succ_eq_add_succ_zero` | `succ` is translation by `succ 0` |
| `succ_iterate_zero` | `succ^[n] 0 = n • succ 0` |
| `archimedean_of_succ` | `IsSuccArchimedean ⇒ Archimedean` — the successor-branch companion to `archimedean_of_lub` |
| `intIso` | `D ≃+o ℤ`, with `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` applying |

Placed inside `section SuccessorBranch ... end SuccessorBranch` so the `variable` bundle does not
leak to the rest of the namespace. One new import: `Mathlib.Order.SuccPred.Archimedean`.

### Step 2 — `FormalSystem/Semantics/IntTransfer.lean` (new, 366 lines)

A generic transport of the whole semantic stack along any `e : D ≃+o E`, then its specialization
at `intIso`. Eleven declarations: `TaskFrame.map` (all seven fields), `TaskModel.map`,
`WorldHistory.map`, `Aligned`, `aligned_map`, `isTotal_map`, `WorldHistory.comap`,
`aligned_comap`, `truthAt_map`, `ValidInt`, `validDiscrete_iff_validInt`.

`ValidInt` is defined here, not in `Validity.lean`, per the plan's recorded placement decision:
`Validity.lean`'s import closure is unchanged by this task apart from a docstring.

### Step 3 — aggregator and docstrings

`FormalSystem/Semantics.lean`: one import line, one `## Submodules` bullet — exactly the two
hunks the plan specified. Three docstrings that asserted the successor-based lemma was absent
were repaired in `Validity.lean`, `DurationClassification.lean` (plus its `## Main results`
list), and `IntNormalForm.lean`.

## Design decisions carried from research (all held)

- **`Aligned`, not `Equiv`.** No `WorldHistory F ≃ WorldHistory (F.map e)` exists in the module.
  `Aligned` is `Prop`-valued and `HEq`-free: because `(TaskFrame.map F e).WorldState` is
  *definitionally* `F.WorldState`, `Aligned.st` is a non-dependent equation, and its single
  genuine transport is discharged by the tree's existing `WorldHistory.states_eq_of_time_eq`.
  Verified: zero `HEq` occurrences in any proof term.
- **`≃+o`, never `≃o`.** `orderIsoIntOfLinearSuccPredArch` is never applied. Durations add
  (`TaskRel`'s Compositionality is at `x + y`), so an order-only isomorphism cannot carry a frame
  across. The wrong turn stays *recorded* in all three docstrings — only the "is absent" claims
  changed.
- **Both measured tactic traps avoided.** No `linarith` in `succ_eq_add_succ_zero` (it does not
  fire on a bare `AddCommGroup` + `LinearOrder`); `le_sub_iff_add_le` + `add_comm` instead. No
  `simpa` for `(comap e ρ').domain s` in `truthAt_map`'s `box` case (the equality is definitional
  and `simp` normalizes past it); the bare term `fun s => hρ' (e s)` instead. Both traps are now
  recorded in the new module's docstrings so a future editor does not re-hit them.

## Verification

| Check | Result |
|---|---|
| Full `lake build` | green, 2464 jobs, exit 0 |
| `#print axioms validDiscrete_iff_validInt` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms truthAt_map` / `intIso` / `archimedean_of_succ` | same, all three |
| New `sorry` | none — `grep` over both touched source files returns nothing |
| New `axiom` | none |
| `scripts/check-module-invariants.sh` | ALL CHECKS PASSED (C8, C6, C2 baseline, C3 sole sorry) |
| Phase 6 docstring greps | all six pass (three stale claims → 0; wrong turn survives) |
| `HEq` in proof terms | zero |

C2 confirms the flagship axiom baseline is unchanged and C3 confirms the repository's sole
structural `sorry` is still the pre-existing one in `WeakCanonical/Transfer.lean` — this task
introduced none.

## Plan Deviations

- **Phase 3 verification gate, altered.** The plan's literal gate reads "`grep -n "HEq"
  FormalSystem/Semantics/IntTransfer.lean` returns nothing". It returns four hits — all inside
  doc-comments that this same plan's Phase 2 and Phase 3 task lists explicitly *required*
  ("record the `Aligned`-not-`Equiv` design decision"; "Docstring `Aligned` with the design
  rationale"). The gate's actual purpose — detecting that the forbidden `Equiv` route was taken —
  was checked by re-running it with block comments stripped: **zero** `HEq` in any proof term.
  The two plan clauses are in tension with each other; the substantive one was honored.
- **Phase 1 line count.** `git diff --stat` reported 87 insertions against a ~45-line Scope
  Hypothesis. The excess is entirely docstring prose (the plan required a new docstring for
  `archimedean_of_succ`; `intIso` and `isLeast_pos_succ_zero` got matching ones). Declaration
  count matches the plan exactly: 4 theorems + 1 `noncomputable def`.

No proof body was re-derived; every one was transcribed from `prototype/verified-prototype.lean`.

## Note for the reader

The plan's final validation item asks that `orderIsoIntOfLinearSuccPredArch` appear "only in
wrong-turn prose, never applied in a proof term" across `FormalSystem/`. That holds for every
live module. It does *not* hold for one pre-existing archived file,
`FormalSystem/Boneyard/DeadChronicleGapElimination/TransferDead.lean:79`, which applies it. That
file is dead code, predates this task, and was not touched here.

## Files modified

- `FormalSystem/Semantics/DurationClassification.lean` — 5 new declarations, 1 import, docstring repair
- `FormalSystem/Semantics/IntTransfer.lean` — **new**, 366 lines, 11 declarations
- `FormalSystem/Semantics.lean` — 1 import, 1 Submodules bullet
- `FormalSystem/Semantics/Validity.lean` — docstring repair
- `FormalSystem/Semantics/IntNormalForm.lean` — docstring repair
