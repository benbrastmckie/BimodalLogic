/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.PlusOmegaChain

/-!
# `LC_n`: Reynolds' infinite limit-closure schema, transposed to `⊡`

`LC_n` is Reynolds 2003's infinite limit-closure schema, transposed into L⁺ by reading its
path quantifier as the stability modal `⊡` and its "from now on" as `G≤` (now and always in the
future):

```
LC_n α  :=  ⊡ G≤ ⋀_{i<n} (⟐αᵢ → ⟐F⟐α_{i+1 mod n})  →  ⟐ G≤ ⋀_{i<n} (⟐αᵢ → F⟐α_{i+1 mod n})
```

with indices mod `n`. The antecedent supplies the recurrences **one at a time**, each on a
possibly different history through the present state; the consequent asks for **one** history
through that state carrying all of them, cycling through the `n` indices forever.

## What is claimed, and by what argument

`lcN_plusValidInt` and `lcN_plusValidZTime` are the results of record: `LC_n α` is valid on every
model over a `FrameOver intOrder` frame, and hence at the `.ZTime` frame class, for every `n ≥ 1`
and arbitrary parameter formulas `α`.

**The proof of record is the ω-chain transposition, not the paper's own argument.** It is the port
of a compiled, `sorry`-free probe (`specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean`,
Part I), re-expressed here against `TaskFrame`, `WorldHistory` and `PlusTruthAt`. Nothing here
claims anything about the correctness or the reach of Reynolds' own argument; the citation records
where the schema comes from, not where this proof comes from.

**`.Base` validity of `LC_n` is OPEN.** A paper argument for it, by Zorn plus the Extension
Theorem in the pattern `PlusLimitClosure.lean` uses at `n = 1`, is recorded in prose elsewhere
and is **unverified in Lean**. Nothing in this module claims it, and nothing here should be read
as evidence for or against it. The obstruction is precise and is named at the one step that
causes it: closing the consequent's `G≤` requires a marker **beyond an arbitrary later time**,
which needs the ω-chain's markers cofinal in the duration order. That holds over `ℤ`
(`intOrder_omega_cofinal`) and fails over a dense order, where a strictly increasing sequence may
converge. The library's existing Zorn route does not generalize for free either: it works at
`n = 1` because the maximal restriction's own maximum *is* a recurrence point, and with `n`
indices a splice witness realises only `⟐α_{j+1}`, leaving the other `n - 1` obligations
unexcused.

## `LCU`, and the relation to `blc`

**`LCU` is the `n = 1` instance of `lcN`** — which is what the schema specializes to at a single
parameter — and is not given a declaration of its own here.

`PlusLimitClosure.lean`'s `blc` is **not** subsumed by `lcN`, and does not subsume it. `blc` is
the `n = 1` limit-closure formula valid at `.Base`, by Zorn plus the Extension Theorem; `lcN` is
the `n ≥ 1` **cycling** schema valid at `.ZTime`, by the ω-chain. The two differ in frame class,
in route, and in index arity, and neither implies the other: `blc` reaches a strictly larger
frame class, `lcN` reaches a strictly larger family of formulas.

## Main Definitions

- `PlusFormula.gle` — `G≤ φ := φ ∧ Gφ`, now and always in the future
- `bigAnd` — finite conjunction of an `ℕ`-indexed family, with a uniform `top` base case
- `lcAnte`, `lcCons` — `LC_n`'s antecedent and consequent
- `lcN` — the schema itself

## Main Results

- `gle_iff` — `G≤ φ` holds at `t` exactly when `φ` holds at every `s ≥ t`
- `bigAnd_iff` — `bigAnd n g` holds exactly when every `g i` with `i < n` does
- `lcN_plusValidInt` — `LC_n` is valid on every model over a `FrameOver intOrder` frame, for every
  `n ≥ 1` and arbitrary parameters
- `lcN_plusValidZTime` — the same at the `.ZTime` frame class, by
  `plusValidZTime_iff_plusValidInt`

## References

* [M. Reynolds, *An Axiomatization of PCTL\**][reynolds2003] — the source of the schema; the
  transposition to `⊡`/`G≤` and the proof carried here are not Reynolds'
* `PlusLanguage/PlusOmegaChain.lean` — `omega_chain` and `intOrder_omega_cofinal`
* `PlusLanguage/PlusLimitClosure.lean` — `blc`, the single-index limit-closure formula at `.Base`
* `PlusLanguage/PlusIntTransfer.lean` — `PlusValidInt`, `plusValidZTime_iff_plusValidInt`

## Tags

plus-language · stability-modal · limit-closure · reynolds · ztime
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics
open PartialHistory
open PlusTruth

variable {F : TaskFrame}

/-! ## `G≤` -/

/--
**`G≤ φ`**: `φ` now and at every later time.

Not available in `PlusLanguage/Formula.lean`, which carries `allFuture` (strictly later) but not
its reflexive closure, so it is defined here where it is used. `Syntax`'s `Formula` layer has no
counterpart either.
-/
def PlusFormula.gle (φ : PlusFormula) : PlusFormula := φ.and φ.allFuture

/-- `G≤ φ` holds at `t` exactly when `φ` holds at every time at or after `t`. -/
theorem gle_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    PlusTruthAt M τ t φ.gle ↔ ∀ s, t ≤ s → PlusTruthAt M τ s φ := by
  rw [PlusFormula.gle, and_iff, allFuture_iff]
  constructor
  · rintro ⟨h0, h1⟩ s hs
    rcases eq_or_lt_of_le hs with rfl | h
    · exact h0
    · exact h1 s h
  · intro h
    exact ⟨h t le_rfl, fun s hs => h s hs.le⟩

/-! ## Finite conjunction of an `ℕ`-indexed family -/

/--
**Finite conjunction `g 0 ∧ … ∧ g (n-1)`** of an `ℕ`-indexed family of L⁺ formulas.

`Syntax.bigconj` is not reusable here on three counts: it consumes a `List Formula` rather than
an `ℕ`-indexed family, its base case is not uniform, and it lives at the L layer rather than L⁺.
The uniform `top` base case is what makes `bigAnd_iff` a clean `∀ i < n`.
-/
def bigAnd : ℕ → (ℕ → PlusFormula) → PlusFormula
  | 0, _ => PlusFormula.top
  | n + 1, g => (bigAnd n g).and (g n)

/-- `bigAnd n g` holds exactly when every `g i` with `i < n` holds. -/
theorem bigAnd_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (g : ℕ → PlusFormula) :
    ∀ n, PlusTruthAt M τ t (bigAnd n g) ↔ ∀ i, i < n → PlusTruthAt M τ t (g i) := by
  intro n
  induction n with
  | zero =>
    exact ⟨fun _ i hi => absurd hi (by omega), fun _ => top_true M τ t⟩
  | succ n ih =>
    rw [bigAnd, and_iff, ih]
    constructor
    · rintro ⟨h1, h2⟩ i hi
      rcases Nat.lt_succ_iff_lt_or_eq.1 hi with h | rfl
      · exact h1 i h
      · exact h2
    · intro h
      exact ⟨fun i hi => h i (by omega), h n (by omega)⟩

/-! ## The schema -/

/-- **`LC_n`'s antecedent**: `⊡ G≤ ⋀_{i<n} (⟐αᵢ → ⟐F⟐α_{i+1 mod n})`. -/
def lcAnte (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula :=
  .stab (bigAnd n fun i =>
    (PlusFormula.dstab (α i)).imp
      (PlusFormula.dstab (PlusFormula.someFuture (PlusFormula.dstab (α ((i + 1) % n)))))).gle

/-- **`LC_n`'s consequent**: `⟐ G≤ ⋀_{i<n} (⟐αᵢ → F⟐α_{i+1 mod n})`. -/
def lcCons (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula :=
  PlusFormula.dstab (bigAnd n fun i =>
    (PlusFormula.dstab (α i)).imp
      (PlusFormula.someFuture (PlusFormula.dstab (α ((i + 1) % n))))).gle

/--
**`LC_n`**: Reynolds 2003's infinite limit-closure schema, transposed to `⊡` with `G≤`.

`LCU` is the `n = 1` instance. See the module docstring for what is claimed about this formula
and what is not — in particular, `.Base` validity is open and unclaimed.
-/
def lcN (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula := (lcAnte n α).imp (lcCons n α)

end FormalSystem.PlusLanguage
