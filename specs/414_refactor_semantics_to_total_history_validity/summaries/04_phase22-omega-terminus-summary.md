# Phase 22 — Omega-binder sweep D and terminus

## Outcome

The `Omega` carrier is gone from the repository's semantics. `TruthAt` now reads

```lean
def TruthAt (M : TaskModel F) (τ : WorldHistory F) (t : D) : Formula → Prop
```

with no set-valued parameter of any kind, and the box clause takes its quantifier range directly
from `WorldHistory.IsTotal`. `ShiftClosed`, `Set.univ_shift_closed`, and
`truthAt_carrier_irrelevant` are deleted outright rather than deprecated.

`lake build` green at **2331 jobs** — identical to the phase-21 baseline, so the sweep cost the
tree nothing. Live non-Boneyard sorries: **1** (pre-existing `Metalogic/WeakCanonical/Transfer.lean:1084`,
out of scope). Strict `axiom <ident>` declarations outside Boneyard: **0**.

## What was changed

| Change | Scale |
|---|---|
| `TruthAt` application sites losing their carrier argument | 442 across 29 files |
| Explicit carrier binders deleted from theorem signatures | 15 in `Truth.lean`, plus `StrongCompleteness.truthAt_foldr_imp`, `SoundnessLemmas/Core`, `SoundnessLemmas/CoValidity.always_elim` |
| Definitions deleted | `ShiftClosed`, `Set.univ_shift_closed`, `truthAt_carrier_irrelevant` |
| Module docstrings retargeted | 9 files |

The deletion of `truthAt_carrier_irrelevant` was free: a census found it had **zero term
consumers**, only four prose references. This confirms and terminates the unwind that phase 20
began — the carrier-transport surface reached zero rather than the five sites phase 17 predicted
or the one the phase-21 re-census measured.

### Method

The sweep was executed with a paren-aware rewriter rather than line-based `sed`, because the
model argument is frequently a parenthesized application (`TruthAt (intModel ord) Set.univ …`)
that a naive `TruthAt \S+ Set.univ` pattern mis-parses. Argument 2 was deleted only when it
matched an explicit carrier whitelist (`Set.univ`, `Omega`, `_Omega`, `Om₁`, `Om₂`, `Ω`), so a
missed site could only ever become a compile error, never a silent semantic change. Binder
removal was done by hand; only application sites were rewritten mechanically.

## Findings worth carrying forward

**1. The a-priori file list was wrong for the sixth consecutive phase.** Phase 22's "Files to
modify" names `FormalSystem/Semantics/TimeShift.lean`, which **does not exist** — the `TimeShift`
namespace lives inside `Truth.lean` at line 352. It also names
`FormalSystem/Metalogic/Soundness.lean` for "remaining binders", which had **none**; its only
work was one call site and one prose line. The line numbers cited for `ShiftClosed` (`:333-334`)
and `Set.univ_shift_closed` (`:339`) were both stale by ~27 lines. Meanwhile four files carrying
real work appeared in no phase's list.

**2. A red-tree error census is a lower bound — reconfirmed, and quantified.** After the first
build, the compiler reported 5 residual carrier sites across 3 modules. The true count was **19
across 8 files**; the other 14 were invisible behind the failing import chain. Fixing only what
the compiler showed would have produced two more full red/green cycles. Grepping the whole tree
for the *shape* of the defect, rather than iterating on compiler output, found all 19 at once.

**3. Qualified names defeat identifier regexes.** The first rewriting pass silently skipped
`FormalSystem.Semantics.TruthAt` because the identifier boundary excluded a preceding `.`. This
is the same class of error as the plan's lesson 3 (single-token greps), one level up: it is not
enough to cover every *spelling* of a name, one must also cover every *qualification* of it.

**4. `Decidability.lean`'s `SatState` prose was stale and wrong.** It described a structure with
"a shift-closed `Ω`" and "an interpretation … landing inside `Ω`". `SatState` has been a
three-field structure (`histTotal` / `ordResp` / `sat`) with no carrier since an earlier phase.
Corrected here.

## Reasoned exclusions

Two `grep` gates in the plan's Testing & Validation list do not return empty, in both cases for
reasons established before this phase:

- **`grep "Set (WorldHistory"`** — one hit, `BXCanonical/CompletenessDedekind.lean:85`. This is a
  type ascription on the probe `{σ | ∀ t, σ.domain t}`, i.e. the frame's total-history set `H_F`
  itself. It is not a carrier binder and is correct as written.
- **`grep "Omega"`** — five hits in `Chronicle/ChronicleConstruction.lean` (the ω-chain
  construction, unrelated to the carrier) and two in `Semantics/Validity.lean:474-475`, which are
  explicitly historical prose recording how a strategic sorry was discharged. The plan's gate
  admits prose "that explicitly describes the retired architecture as historical".

`Truth.lean:121` retains one `Ω`, in a sentence asserting the quantifier ranges over `H_F` "with
no `Ω`" — a statement of the symbol's absence, not a use of it.

## Verification

| Gate | Result |
|---|---|
| `lake build` (default `FormalSystem` target) | GREEN, 2331 jobs |
| Live non-Boneyard sorries | 1 (pre-existing, out of scope) |
| Strict `axiom <ident>` outside Boneyard | 0 |
| `grep ShiftClosed` | empty |
| `grep -E '\bOm\b\|Ω'` | one statement-of-absence line only |
| `scripts/check-paper-definitions.sh` | exit 0 |
| Converse notation (`\breve` / `\smallsmile`) | none introduced |
