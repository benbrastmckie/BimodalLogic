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

/-- `G≤ φ` holds at `t` exactly when `φ` holds at every time at or after `t`.

Paper: — (formalization-native; the manuscript states no limit-closure schema)
-/
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

/-- `bigAnd n g` holds exactly when every `g i` with `i < n` holds.

Paper: — (formalization-native; the manuscript states no limit-closure schema)
-/
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

/-! ## Validity at the `ℤ` fibre, and at `.ZTime` -/

/--
**`LC_n` is valid on every model over a `FrameOver intOrder` frame**, for every `n ≥ 1` and
arbitrary parameter formulas.

The `ℤ` fibre is where the ω-chain's cofinality requirement is discharged, by
`intOrder_omega_cofinal`, and that is the step which fixes the frame class: closing the
consequent's `G≤` means producing, for an arbitrary `s ≥ t` and index `j`, a marker `c k > s`
whose residue class is `j + 1 mod n`, which needs the markers cofinal in the duration order.

The argument splits on whether any `⟐αᵢ`-point is reachable at all. If none is, the evaluation
history itself witnesses the consequent vacuously. If one is, the ω-chain runs at the recurrence
family `A k := ⟐α_{(i₀ + k) mod n}` — the `n` indices cycled forever from the one that was
found — and its limit history carries every member at a strictly increasing marker.

Paper: — (formalization-native; the manuscript states no limit-closure schema)
-/
theorem lcN_plusValidInt (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) :
    PlusValidInt (lcN n α) := by
  classical
  intro F _ M σ t hante
  -- The antecedent, unpacked at every history through `σ`'s state at `t`.
  have hA : ∀ ρ : WorldHistory F.toTaskFrame, ρ.state t = σ.state t → ∀ s, t ≤ s → ∀ i, i < n →
      PlusTruthAt M ρ s (PlusFormula.dstab (α i)) →
      PlusTruthAt M ρ s (PlusFormula.dstab (PlusFormula.someFuture
        (PlusFormula.dstab (α ((i + 1) % n))))) := by
    intro ρ he s hs i hi
    have h1 := hante ρ he.symm
    rw [gle_iff] at h1
    exact (bigAnd_iff M ρ s _ n).1 (h1 s hs) i hi
  simp only [lcCons]
  rw [dstab_iff]
  by_cases hex : ∃ (ρ : WorldHistory F.toTaskFrame) (s : ℤ) (i : ℕ),
      ρ.state t = σ.state t ∧ t ≤ s ∧ i < n ∧ PlusTruthAt M ρ s (PlusFormula.dstab (α i))
  · obtain ⟨ρ₀, s₀, i₀, h0w, h0s, hi₀, h0A⟩ := hex
    -- `⟐α` read as a condition on a time and a world state: this is the shape `omega_chain`
    -- consumes, and `⟐` is exactly what makes it one.
    have hAiff : ∀ (k : ℕ) (ρ : WorldHistory F.toTaskFrame) (s : ℤ),
        (∃ η : WorldHistory F.toTaskFrame, ρ.state s = η.state s ∧
            PlusTruthAt M η s (α ((i₀ + k) % n))) ↔
          PlusTruthAt M ρ s (PlusFormula.dstab (α ((i₀ + k) % n))) :=
      fun k ρ s => (dstab_iff M ρ s (α ((i₀ + k) % n))).symm
    -- `P` is the segment-property slot `omega_chain` carries for the until-form schema; this
    -- `F`-form argument needs nothing from it, so it is instantiated trivially and its three
    -- extra conclusions (`c 0 = s₀`, agreement below `s₀`, the segment property) go unused here.
    obtain ⟨ρ, c, hρt, _, _, hcl, hcA, _⟩ := omega_chain (F := F.toTaskFrame) σ t
      (fun k s v => ∃ η : WorldHistory F.toTaskFrame, v = η.state s ∧
        PlusTruthAt M η s (α ((i₀ + k) % n)))
      (fun _ _ _ _ => True)
      (fun c hc x => intOrder_omega_cofinal c hc x)
      (fun _ _ _ _ _ _ h => h)
      ρ₀ s₀ h0w h0s
      ((hAiff 0 ρ₀ s₀).2 (by rw [Nat.add_zero, Nat.mod_eq_of_lt hi₀]; exact h0A))
      (by
        intro ρ he k s hs hk
        have h1 := hA ρ he s hs ((i₀ + k) % n) (Nat.mod_lt _ hn) ((hAiff k ρ s).1 hk)
        rw [dstab_iff] at h1
        obtain ⟨η, he', h2⟩ := h1
        rw [someFuture_iff] at h2
        obtain ⟨s', hs', h3⟩ := h2
        refine ⟨η, s', he'.symm, hs', (hAiff (k + 1) η s').2 ?_, trivial⟩
        have e : (i₀ + (k + 1)) % n = ((i₀ + k) % n + 1) % n := by
          rw [Nat.mod_add_mod, add_assoc]
        rw [e]
        exact h3)
    refine ⟨ρ, hρt.symm, ?_⟩
    rw [gle_iff]
    intro s hs
    rw [bigAnd_iff]
    intro j hj hdj
    rw [someFuture_iff]
    -- A marker beyond `s` whose residue class is `j + 1` modulo `n`.
    obtain ⟨m, hm⟩ : ∃ m, n = i₀ + m := ⟨n - i₀, by omega⟩
    obtain ⟨k, hk1, hk2⟩ := int_marker_exists_gt hcl n i₀ j m hn hm s
    refine ⟨c k, hk2, ?_⟩
    have hfin := (hAiff k ρ (c k)).1 (hcA k).2
    rwa [hk1] at hfin
  · -- No `⟐αᵢ`-point is reachable: `σ` itself witnesses the consequent vacuously.
    refine ⟨σ, rfl, ?_⟩
    rw [gle_iff]
    intro s hs
    rw [bigAnd_iff]
    intro j hj hdj
    exact absurd ⟨σ, s, j, rfl, hs, hj, hdj⟩ hex

/--
**`LC_n` is valid at the `.ZTime` frame class**, for every `n ≥ 1` and arbitrary parameter
formulas, by carrier normalization from `lcN_plusValidInt`.

`.Base` validity is **open**: a paper argument by Zorn plus the Extension Theorem exists in prose
but is unverified in Lean, and nothing here claims it. See the module docstring for the precise
obstruction — the ω-chain's markers must be cofinal in the duration order, which fails over a
dense order.

Paper: — (formalization-native; the manuscript states no limit-closure schema)
-/
theorem lcN_plusValidZTime (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) :
    PlusValidZTime (lcN n α) :=
  (plusValidZTime_iff_plusValidInt (lcN n α)).mpr (lcN_plusValidInt n hn α)

end FormalSystem.PlusLanguage
