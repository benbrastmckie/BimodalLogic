/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.PlusOmegaChain
import FormalSystem.PlusLanguage.PlusReversal

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

**`LCU` is not an instance of `lcN`, and `lcN 1` is not `LCU`.** The two formulas are:

```
LCU α β  :=  ⊡G≤(⟐α → ⟐(⟐β U ⟐α))  →  (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))
lcN 1 α  :=  ⊡G≤(⟐α₀ → ⟐F⟐α₀)      →  ⟐G≤(⟐α₀ → F⟐α₀)
```

`LCU` takes **two** parameters and its recurrence is an **until**: `⟐β U ⟐α`, with `untl`
primitive. `lcN 1 α` takes **one** parameter, `α₀`, and its recurrence is `F` alone — no `untl`
anywhere. Their consequents differ in shape too: `LCU`'s is an implication `⟐α → ⟐G≤ …` with the
antecedent *outside* the `⟐`, while `lcN`'s consequent is a single `⟐G≤ …` whose body is the
implication. Neither formula is a substitution instance of the other, and setting `β := ⊤` does
not rescue the reading either: `⟐⊤ U ⟐α` is not `F⟐α`, and the consequent shapes still disagree.

**Why this matters, and is not a cosmetic difference.** L⁺ has `untl` and `snce` as *primitives*,
so a Reynolds-style construction over L⁺ must discharge until-commitments as well as
`F`-commitments. An until-commitment `⟐β U ⟐α` is satisfied only by a witness carrying `⟐β`
throughout the interval up to the `⟐α`-point; the `F`-form schema says nothing about any
interval and so does not discharge an until-commitment's guard. The two schemas are therefore
separate ingredients, and a reader who takes `lcN` to cover the until-form has the wrong
inventory: `lcN` is the `F`-form and discharges no segment guard.

**What is declared here, and what is claimed for it.** `lcU` is `LCU`, declared below beside
`lcN`. `lcU_plusValidInt` and `lcU_plusValidZTime` are the results of record for it: `LCU α β`
is valid on every model over a `FrameOver intOrder` frame, and hence at the `.ZTime` frame class,
for arbitrary parameter formulas; `lcU_reflectTime_plusValidZTime` carries the same to the
backward mirror. The route is `PlusOmegaChain.lean`'s `omega_chain`, whose segment-property
parameter `P` (with its stability hypothesis `hP`, the first-marker identity `c 0 = s₀`, and
agreement below `s₀`) is exactly the interval condition `LCU`'s semantic core needs.

**What is not claimed for it.** `.Base` validity of `LCU` is **open and unclaimed**, for the same
cofinality reason `lcN`'s is: `omega_chain`'s cofinality hypothesis has one discharge in this
tree, `intOrder_omega_cofinal`, available over `ℤ` alone. Nor is any derivability or completeness
claim made: nothing here says `lcU` is a TM⁺ theorem, that TM⁺ extended by it is complete, or
that `lcU` follows from `lcN` or `lcN` from `lcU`.

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
- `lcU` — `LCU`, the until-form limit-closure schema, with `untl` primitive and two parameters

## Main Results

- `gle_iff` — `G≤ φ` holds at `t` exactly when `φ` holds at every `s ≥ t`
- `bigAnd_iff` — `bigAnd n g` holds exactly when every `g i` with `i < n` does
- `lcN_plusValidInt` — `LC_n` is valid on every model over a `FrameOver intOrder` frame, for every
  `n ≥ 1` and arbitrary parameters
- `lcN_plusValidZTime` — the same at the `.ZTime` frame class, by
  `plusValidZTime_iff_plusValidInt`
- `lcN_reflectTime_plusValidZTime` — the **backward** limit-closure schema at `.ZTime`, as the
  one-line `plusValidIn_reflectTime` corollary of the forward one; stated at
  `(lcN n α).reflectTime` rather than as an expanded mirror form
- `lcU_plusValidInt` — `LCU` is valid on every model over a `FrameOver intOrder` frame, for
  arbitrary parameters, by the ω-chain at the constant family `A k := ⟐α` with the segment
  property carrying `⟐β` across each open marker interval
- `lcU_plusValidZTime` — the same at the `.ZTime` frame class, by
  `plusValidZTime_iff_plusValidInt`
- `lcU_reflectTime_plusValidZTime` — the **backward** until-form schema at `.ZTime`, as the
  one-line `plusValidIn_reflectTime` corollary; stated at `(lcU α β).reflectTime`

## References

* [M. Reynolds, *An Axiomatization of PCTL\**][reynolds2003] — the source of the schema; the
  transposition to `⊡`/`G≤` and the proof carried here are not Reynolds'
* `PlusLanguage/PlusOmegaChain.lean` — `omega_chain` and `intOrder_omega_cofinal`
* `PlusLanguage/PlusLimitClosure.lean` — `blc`, the single-index limit-closure formula at `.Base`
* `PlusLanguage/PlusIntTransfer.lean` — `PlusValidInt`, `plusValidZTime_iff_plusValidInt`
* `PlusLanguage/PlusReversal.lean` — `plusValidIn_reflectTime`, which gives the backward schema

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

`lcU`, the until-form limit-closure schema, is **not** an instance of this one, and `lcN 1` is
not `lcU`: see the module docstring's `LCU` section for the two formulas side by side and for why
the difference is substantive. `lcU` is declared below, with its own validity results
(`lcU_plusValidInt`, `lcU_plusValidZTime`, `lcU_reflectTime_plusValidZTime`). See the module
docstring for what is claimed about `lcN` and what is not — in particular, `.Base` validity is
open and unclaimed.
-/
def lcN (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula := (lcAnte n α).imp (lcCons n α)

/--
**`LCU`**, the until-form limit-closure schema:

```
LCU α β  :=  ⊡G≤(⟐α → ⟐(⟐β U ⟐α))  →  (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))
```

The antecedent supplies, at every later time and on a possibly different history through the
present state, an until-commitment `⟐β U ⟐α` from each `⟐α`-point; the consequent asks for
**one** history through that state on which, from the present time onward, every time is either
an `⟐α`-point or the start of such an until-commitment.

This is **not** an instance of `lcN`, and `lcN 1` is not this formula: see the module docstring's
`LCU` section for the two side by side. The schema is a `def` only — no derivability or
completeness claim is made about it anywhere in this tree. What is claimed is its semantic
validity over the `ℤ` fibre and at `.ZTime`, by `lcU_plusValidInt` and `lcU_plusValidZTime`;
`.Base` validity is **open and unclaimed**.

Paper: — (formalization-native; the manuscript states no limit-closure schema)
-/
def lcU (α β : PlusFormula) : PlusFormula :=
  (PlusFormula.stab ((PlusFormula.dstab α).imp
      (PlusFormula.dstab (PlusFormula.untl (PlusFormula.dstab β)
        (PlusFormula.dstab α)))).gle).imp
    ((PlusFormula.dstab α).imp
      (PlusFormula.dstab ((PlusFormula.dstab α).or
        (PlusFormula.untl (PlusFormula.dstab β) (PlusFormula.dstab α))).gle))

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

/--
**The backward limit-closure schema at `.ZTime`**: `LC_n` read backwards in time is valid there
too, for every `n ≥ 1` and arbitrary parameter formulas.

`reflectTime` fixes `⊡` and exchanges `U` with `S`, hence `F` with `P` and `G` with `H`
(`PlusLanguage/PlusReversal.lean`, `PlusLanguage/Formula.lean`). The reflection of `LC_n` is
therefore the *same* cycling schema with every temporal direction reversed: a past-directed
`H≤`-antecedent supplying the recurrences one at a time, and a past-directed consequent asking
for one history carrying all of them backwards forever. It is valid at `.ZTime` because `ℤ` is
reflection-symmetric — the frame class is closed under `rev`, which is precisely what
`plusValidOnFrames_reflectTime` consumes and what `plusValidIn_reflectTime` discharges at an
arbitrary `ProofSystem.FrameClass`.

**The mirror form is deliberately not expanded.** Stating the reflected schema in syntax, rather
than as `(lcN n α).reflectTime`, would require three new declarations this module does not have
and does not need: an `H≤` definition (this module defines `gle` only, and neither `Formula` nor
`PlusFormula` carries a reflexive-*past* closure), a `reflect_time_gle` push-through lemma, and a
`reflect_time_bigAnd` lemma for the `ℕ`-indexed conjunction. The one-liner below already proves
what all three would be built to state.

Paper: — (formalization-native; the manuscript states no limit-closure schema)
-/
theorem lcN_reflectTime_plusValidZTime (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) :
    PlusValidZTime (lcN n α).reflectTime :=
  plusValidIn_reflectTime (lcN_plusValidZTime n hn α)

/--
**`LCU` is valid on every model over a `FrameOver intOrder` frame**, for arbitrary parameter
formulas.

The route is the same ω-chain as `lcN`'s, instantiated at the until-form's data: the recurrence
family is the *constant* `A k s v := ⟐α` at `v`, `s`, and the segment property is
`P k η s s' := ⟐β` at every `r` strictly between `s` and `s'`. The chain's first marker is the
evaluation time itself (`ρ₀ := σ`, `s₀ := t`, so `c 0 = t`), so no reachability case split is
needed and the `[t, c 0)` gap the `F`-form must argue about is empty. The consequent's left
disjunct `⟐α` is never taken: at an arbitrary `s ≥ t`, `int_marker_bracket` produces the
consecutive marker pair with `c k ≤ s < c (k + 1)`, the right marker carries `⟐α`, and the chain's
segment property carries `⟐β` across `(c k, c (k + 1))` ⊇ `(s, c (k + 1))`, which is exactly the
right disjunct's until-witness.

**The segment property is instantiated on the open interval `(s, s')`, not the half-open
`(s, s']`.** The half-open reading is not derivable from the antecedent: the `untl` clause carries
`⟐α`, not `⟐β`, at the right endpoint. The open content window sits strictly inside the half-open
agreement window that `omega_chain`'s `hP` offers, so `hP` discharges by state-locality of `⟐`;
see `PlusOmegaChain.lean`'s `stg_step` docstring for the endpoint discipline a consumer must
observe.

The `ℤ` fibre is where the ω-chain's cofinality requirement is discharged, by
`intOrder_omega_cofinal`, and that is the step which fixes the frame class.

Paper: — (formalization-native; the manuscript states no limit-closure schema)
-/
theorem lcU_plusValidInt (α β : PlusFormula) : PlusValidInt (lcU α β) := by
  classical
  intro F _ M σ t hante hα
  have hA : ∀ ρ : WorldHistory F.toTaskFrame, ρ.state t = σ.state t → ∀ s, t ≤ s →
      PlusTruthAt M ρ s (PlusFormula.dstab α) →
      PlusTruthAt M ρ s (PlusFormula.dstab (PlusFormula.untl (PlusFormula.dstab β)
        (PlusFormula.dstab α))) := by
    intro ρ he s hs
    have h1 := hante ρ he.symm
    rw [gle_iff] at h1
    exact h1 s hs
  obtain ⟨ρ, c, hρt, _, hc0, hcl, hcA, hcP⟩ := omega_chain (F := F.toTaskFrame) σ t
      (fun _ s v => ∃ η : WorldHistory F.toTaskFrame, v = η.state s ∧ PlusTruthAt M η s α)
      (fun _ η s s' => ∀ r, s < r → r < s' → PlusTruthAt M η r (PlusFormula.dstab β))
      (fun c hc x => intOrder_omega_cofinal c hc x)
      (by
        intro i η η' s s' hag h r h1 h2
        obtain ⟨κ, hκ, hval⟩ := (dstab_iff M η r β).1 (h r h1 h2)
        exact (dstab_iff M η' r β).2 ⟨κ, (hag r h1 h2.le).trans hκ, hval⟩)
      σ t rfl le_rfl ((dstab_iff M σ t α).1 hα)
      (by
        intro ρ' he k s hs hk
        have h1 := hA ρ' he s hs ((dstab_iff M ρ' s α).2 hk)
        rw [dstab_iff] at h1
        obtain ⟨η, he', h2⟩ := h1
        rw [untl_iff] at h2
        obtain ⟨s', hlt, hαs', hβ⟩ := h2
        exact ⟨η, s', he'.symm, hlt, (dstab_iff M η s' α).1 hαs', hβ⟩)
  rw [dstab_iff]
  refine ⟨ρ, hρt.symm, ?_⟩
  rw [gle_iff]
  intro s hs
  rw [or_iff]
  right
  rw [untl_iff]
  obtain ⟨k, hk1, hk2⟩ := int_marker_bracket hcl (s := s) (by rw [hc0]; exact hs)
  refine ⟨c (k + 1), hk2, ?_, ?_⟩
  · exact (dstab_iff M ρ (c (k + 1)) α).2 (hcA (k + 1)).2
  · intro r hr1 hr2
    exact hcP k r (lt_of_le_of_lt hk1 hr1) hr2

/--
**`LCU` is valid at the `.ZTime` frame class**, for arbitrary parameter formulas, by carrier
normalization from `lcU_plusValidInt`.

`.Base` validity is **open and unclaimed**. The obstruction is the same one `lcN` meets and is
not a gap in this proof: `omega_chain`'s cofinality hypothesis has exactly one discharge in this
tree, `intOrder_omega_cofinal`, and that discharge is available over `ℤ` alone. Over a dense
temporal order a strictly increasing marker sequence may converge, leaving an unreached tail.

**No derivability or completeness claim is made.** Nothing here says that `lcU` is a TM⁺ theorem,
that TM⁺ extended by it is complete, or that it follows from `lcN` (or `lcN` from it).

Paper: — (formalization-native; the manuscript states no limit-closure schema)
-/
theorem lcU_plusValidZTime (α β : PlusFormula) : PlusValidZTime (lcU α β) :=
  (plusValidZTime_iff_plusValidInt (lcU α β)).mpr (lcU_plusValidInt α β)

/--
**The backward until-form limit-closure schema at `.ZTime`**: `LCU` read backwards in time is
valid there too, for arbitrary parameter formulas.

`reflectTime` fixes `⊡` and exchanges `U` with `S`, hence `F` with `P` and `G` with `H`
(`PlusLanguage/PlusReversal.lean`, `PlusLanguage/Formula.lean`), so the reflection of `LCU` is
the same schema with the until read as a since and every temporal direction reversed. It is valid
at `.ZTime` because `ℤ` is reflection-symmetric — the frame class is closed under `rev`, which is
what `plusValidIn_reflectTime` discharges at an arbitrary `ProofSystem.FrameClass`.

**The mirror form is deliberately not expanded**, for the reason
`lcN_reflectTime_plusValidZTime`'s docstring gives: stating it in syntax would need an `H≤`
definition and push-through lemmas this module neither has nor needs, and the one-liner below
already proves what they would be built to state.

`.Base` validity is **open and unclaimed**, and no derivability or completeness claim is made.

Paper: — (formalization-native; the manuscript states no limit-closure schema)
-/
theorem lcU_reflectTime_plusValidZTime (α β : PlusFormula) :
    PlusValidZTime (lcU α β).reflectTime :=
  plusValidIn_reflectTime (lcU_plusValidZTime α β)

end FormalSystem.PlusLanguage
