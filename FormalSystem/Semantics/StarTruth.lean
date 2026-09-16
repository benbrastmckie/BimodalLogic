/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusTruth
import FormalSystem.Syntax.StarLanguage.Formula
import FormalSystem.Semantics.TruthClauses

/-!
# `StarTruthAt` — truth for L⋆ over the manuscript's points `(τ, x, v⃗)`

The native truth recursion for `StarFormula` (`FormalSystem/StarLanguage/Formula.lean`). The
seven L⁺ clauses are those of `PlusTruthAt` (`Semantics/PlusTruth.lean`) verbatim, with the
stored-time vector threaded untouched through every one of them, and the two new clauses are
`def:BLstar-semantics`'s time registers:

```
M,τ,x,v⃗ ⊨ ↑ⁱφ   iff   M,τ,x,v⃗[i ↦ x] ⊨ φ
M,τ,x,v⃗ ⊨ ↓ⁱφ   iff   M,τ,vᵢ,v⃗ ⊨ φ
```

`↑ⁱ` writes the current time into register `i` and evaluates on; `↓ⁱ` moves evaluation to the
time register `i` holds. World registers (`↑_M`, `↓_M`) are suppressed, exactly as
`def:BLstar-semantics` suppresses them in the deterministic-frame appendix.

## Main Definitions

- `StarTruthAt M τ x v φ` — the nine-clause truth recursion

## Main Results

- The `StarTruth.*_iff` clause lemmas, mirroring `PlusTruth.*`, plus `timeStore_iff` and
  `timeRecall_iff`
- `starTruthAt_ofPlus` — the **truth transfer** along `ofPlus`: on the image of the embedding
  the stored-time vector is inert, so L⋆ truth is L⁺ truth
- `star_truth_congr_ext` — the L⋆ restatement of `truth_congr_ext`, at a fixed vector
- `update_shift_comm` — the update/shift commutation identity the `timeStore` case consumes
- `starTruthAt_timeShift` — the L⋆ restatement of `plusTruthAt_timeShift`, with the stored-time
  vector **shifted**

## Two design decisions, recorded so neither reads as a defect

**(a) The time-shift lemma carries the vector shifted, never dropped.**
`plusTruthAt_timeShift` (`Semantics/PlusTruth.lean`) reads
`PlusTruthAt M (σ.timeShift Δ) t φ ↔ PlusTruthAt M σ (t + Δ) φ`. Its L⋆ restatement cannot
simply carry `v` across unchanged: `↓ⁱ` evaluates at `vᵢ`, a time in the *unshifted* frame of
reference, so shifting the history must shift the register contents with it. The lemma below is
therefore
`StarTruthAt M (σ.timeShift Δ) t v φ ↔ StarTruthAt M σ (t + Δ) (fun i => v i + Δ) φ`.
This is the restatement recorded as required in the archived
correspondence-record-and-store-recall-recommendation report, §II.3 (which names it against that
report's pre-rename file names — `StarTruth.lean` there is this tree's `PlusTruth.lean`); the L⋆
module it names is this one.

**(b) `stab_state_only`'s *different-times* transfer has no L⋆ analogue; its *same-time*
restriction does, on a fragment.**
`stab_state_only` (`Semantics/PlusTruth.lean`) says `⊡φ`'s truth depends on the world state
alone, **at any two times** — `τ(t) = σ(s)` transfers `⊡φ` from `(τ, t)` to `(σ, s)` — which is
what licenses the atomization route to TM⁺ soundness
(`Metalogic/Conservativity/Plus/Atomization.lean`).

*What fails.* The different-times statement has no L⋆ analogue and must not be sought: `⊡↓ⁱφ`
reaches back to a time the register names, and two points with the same world state but
different register contents disagree on it. Breaking that invariant is exactly what this
language is built to do — it is what lets `sent:det` discriminate frames that no `PlusFormula`
can (`Metalogic/Independence/StarDiscrimination.lean`) — and it is why the **atomization route
must never be extended to `StarFormula`**. That warning stands unchanged.

*What holds.* The **same-time** statement — one `t`, one register vector `v⃗` on both sides —
does hold, and holds of a syntactic fragment rather than only of `⊡`-formulas:
`Semantics/StarStateLocal.lean`'s `isStateLocal_of_stateLocal`, over the fragment
`StarFormula.StateLocal`. On that fragment `φ ↔ ⊡φ` is valid (`stateLocal_starValid_iff_stab`).
The two statements are not in tension: the fragment excludes `↓ⁱ` outright
(`not_isStateLocal_timeRecall` is the countermodel), which is precisely the constructor the
different-times transfer founders on. Nothing there recovers an atomization route; a same-time
congruence does not let a `⊡`-formula be treated as a fresh state-valued atom across times.

## References

* JPL paper `def:BLstar-semantics` — the store/recall clauses and the point `(τ, x, v⃗)`
* `FormalSystem/Semantics/PlusTruth.lean` — the seven L⁺ clauses being mirrored, and the two
  transport lemmas being restated
* `FormalSystem/StarLanguage/Formula.lean` — `StarFormula`, `ofPlus`

## Tags

truth · star-language · store-recall · time-register
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage
open FormalSystem.StarLanguage.StarFormula

variable {F : TaskFrame}

/-! ## The truth recursion -/

/--
Truth of an L⋆ formula at a model, history, time, and **stored-time vector**.

The seven L⁺ clauses are `PlusTruthAt`'s verbatim, with `v` threaded untouched — including
through `box` and `stab`, neither of which disturbs the registers. The two new clauses are
`def:BLstar-semantics`'s: `↑ⁱφ` evaluates `φ` with the current time written into register `i`,
and `↓ⁱφ` evaluates `φ` at the time register `i` holds.
-/
def StarTruthAt (M : TaskModel F) (τ : ConvexHistory F) (t : F.Duration) (v : ℕ → F.Duration) :
    StarFormula → Prop
  | .atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | .bot => False
  | .imp φ ψ => StarTruthAt M τ t v φ → StarTruthAt M τ t v ψ
  | .box φ => ∀ (σ : ConvexHistory F), σ.IsTotal → StarTruthAt M σ t v φ
  | .untl ψ φ => ∃ s : F.Duration, t < s ∧ StarTruthAt M τ s v φ ∧
      ∀ r : F.Duration, t < r → r < s → StarTruthAt M τ r v ψ
  | .snce ψ φ => ∃ s : F.Duration, s < t ∧ StarTruthAt M τ s v φ ∧
      ∀ r : F.Duration, s < r → r < t → StarTruthAt M τ r v ψ
  | .stab φ => ∀ (σ : ConvexHistory F), σ.IsTotal → SameStateAt τ σ t → StarTruthAt M σ t v φ
  | .timeStore i φ => StarTruthAt M τ t (Function.update v i t) φ
  | .timeRecall i φ => StarTruthAt M τ (v i) v φ

/-! ### The abstract clause layer, instantiated

L⋆'s instances of `Semantics/TruthClauses.lean`, and the case the environment parameter exists
for: `Env F` is the **stored-time vector type** rather than `PUnit`, and every shared clause
threads it through unchanged. That inertness is exactly what the six clause fields being
`Iff.rfl` records.

`timeStore` and `timeRecall` are the two constructors that do *not* thread `v` inertly, and
nothing about them is instantiated here — the shared clause layer never mentions them, which is
the honest boundary of the abstraction on this language. -/

/-- L⋆'s pointed truth relation. The environment is the stored-time vector. -/
instance : TruthEnv StarFormula where
  Env F := ℕ → F.Duration
  T M τ t v φ := StarTruthAt M τ t v φ

/-- L⋆'s six **shared** primitive operators and their clauses, identical to L⁺'s with `v`
threaded inert. The two register operators are deliberately absent. -/
instance : StabClauses StarFormula where
  bot := StarFormula.bot
  imp := StarFormula.imp
  box := StarFormula.box
  untl := StarFormula.untl
  snce := StarFormula.snce
  stab := StarFormula.stab
  sameState := SameStateAt
  bot_clause _ _ _ _ := fun h => h
  imp_clause _ _ _ _ _ _ := Iff.rfl
  box_clause _ _ _ _ _ := Iff.rfl
  untl_clause _ _ _ _ _ _ := Iff.rfl
  snce_clause _ _ _ _ _ _ := Iff.rfl
  stab_clause _ _ _ _ _ := Iff.rfl

namespace StarTruth

variable (M : TaskModel F) (τ : ConvexHistory F) (t : F.Duration) (v : ℕ → F.Duration)

theorem atom_iff (p : Atom) :
    StarTruthAt M τ t v (.atom p) ↔ ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p := Iff.rfl

@[simp] theorem bot_false : ¬ StarTruthAt M τ t v .bot := fun h => h

theorem imp_iff (φ ψ : StarFormula) :
    StarTruthAt M τ t v (.imp φ ψ) ↔ (StarTruthAt M τ t v φ → StarTruthAt M τ t v ψ) := Iff.rfl

theorem box_iff (φ : StarFormula) :
    StarTruthAt M τ t v (.box φ) ↔ ∀ σ : ConvexHistory F, σ.IsTotal → StarTruthAt M σ t v φ :=
  Iff.rfl

theorem untl_iff (ψ φ : StarFormula) :
    StarTruthAt M τ t v (.untl ψ φ) ↔ ∃ s, t < s ∧ StarTruthAt M τ s v φ ∧
      ∀ r, t < r → r < s → StarTruthAt M τ r v ψ := Iff.rfl

theorem snce_iff (ψ φ : StarFormula) :
    StarTruthAt M τ t v (.snce ψ φ) ↔ ∃ s, s < t ∧ StarTruthAt M τ s v φ ∧
      ∀ r, s < r → r < t → StarTruthAt M τ r v ψ := Iff.rfl

theorem stab_iff (φ : StarFormula) :
    StarTruthAt M τ t v (.stab φ) ↔
      ∀ σ : ConvexHistory F, σ.IsTotal → SameStateAt τ σ t → StarTruthAt M σ t v φ := Iff.rfl

/-- `(↑ⁱ)` of `def:BLstar-semantics`: store the present time in register `i`. -/
theorem timeStore_iff (i : ℕ) (φ : StarFormula) :
    StarTruthAt M τ t v (.timeStore i φ) ↔ StarTruthAt M τ t (Function.update v i t) φ := Iff.rfl

/-- `(↓ⁱ)` of `def:BLstar-semantics`: evaluate at the time register `i` holds. -/
theorem timeRecall_iff (i : ℕ) (φ : StarFormula) :
    StarTruthAt M τ t v (.timeRecall i φ) ↔ StarTruthAt M τ (v i) v φ := Iff.rfl

theorem top_true : StarTruthAt M τ t v top :=
  TruthClauses.top_true (L := StarFormula) M τ t v

theorem neg_iff (φ : StarFormula) :
    StarTruthAt M τ t v (neg φ) ↔ ¬ StarTruthAt M τ t v φ :=
  TruthClauses.neg_iff (L := StarFormula) M τ t v φ

theorem and_iff (φ ψ : StarFormula) :
    StarTruthAt M τ t v (φ.and ψ) ↔ StarTruthAt M τ t v φ ∧ StarTruthAt M τ t v ψ :=
  TruthClauses.and_iff (L := StarFormula) M τ t v φ ψ

theorem or_iff (φ ψ : StarFormula) :
    StarTruthAt M τ t v (φ.or ψ) ↔ StarTruthAt M τ t v φ ∨ StarTruthAt M τ t v ψ :=
  TruthClauses.or_iff (L := StarFormula) M τ t v φ ψ

theorem someFuture_iff (φ : StarFormula) :
    StarTruthAt M τ t v (someFuture φ) ↔ ∃ s, t < s ∧ StarTruthAt M τ s v φ :=
  TruthClauses.someFuture_iff (L := StarFormula) M τ t v φ

theorem allFuture_iff (φ : StarFormula) :
    StarTruthAt M τ t v (allFuture φ) ↔ ∀ s, t < s → StarTruthAt M τ s v φ :=
  TruthClauses.allFuture_iff (L := StarFormula) M τ t v φ

theorem somePast_iff (φ : StarFormula) :
    StarTruthAt M τ t v (somePast φ) ↔ ∃ s, s < t ∧ StarTruthAt M τ s v φ :=
  TruthClauses.somePast_iff (L := StarFormula) M τ t v φ

theorem allPast_iff (φ : StarFormula) :
    StarTruthAt M τ t v (allPast φ) ↔ ∀ s, s < t → StarTruthAt M τ s v φ :=
  TruthClauses.allPast_iff (L := StarFormula) M τ t v φ

theorem diamond_iff (φ : StarFormula) :
    StarTruthAt M τ t v (diamond φ) ↔ ∃ σ : ConvexHistory F, σ.IsTotal ∧ StarTruthAt M σ t v φ :=
  TruthClauses.diamond_iff (L := StarFormula) M τ t v φ

theorem dstab_iff (φ : StarFormula) :
    StarTruthAt M τ t v (dstab φ) ↔
      ∃ σ : ConvexHistory F, σ.IsTotal ∧ SameStateAt τ σ t ∧ StarTruthAt M σ t v φ :=
  TruthClauses.dstab_iff (L := StarFormula) M τ t v φ

/-- `△φ` unfolds three ways, exactly as in L⁺: past, present, and future. -/
theorem always_iff (φ : StarFormula) :
    StarTruthAt M τ t v (always φ) ↔
      (∀ s, s < t → StarTruthAt M τ s v φ) ∧ StarTruthAt M τ t v φ ∧
        (∀ s, t < s → StarTruthAt M τ s v φ) :=
  TruthClauses.always_iff_tri (L := StarFormula) M τ t v φ

end StarTruth

open StarTruth

/-! ## Truth transfer along `ofPlus`

On the image of the embedding no register operator occurs, so the stored-time vector is inert
and L⋆ truth is L⁺ truth. -/

/--
**The truth-transfer bridge for L⋆.** An L⁺ formula embedded into L⋆ is true exactly when it is
true in L⁺, at the same model, history and time — at *every* stored-time vector, which is
universally quantified and unused in the conclusion.
-/
theorem starTruthAt_ofPlus (M : TaskModel F) (τ : ConvexHistory F) (x : F.Duration)
    (v : ℕ → F.Duration) (φ : PlusFormula) :
    StarTruthAt M τ x v (ofPlus φ) ↔ PlusTruthAt M τ x φ := by
  induction φ generalizing τ x with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact Iff.imp (ihφ τ x) (ihψ τ x)
  | box φ ih => exact forall_congr' fun σ => imp_congr_right fun _ => ih σ x
  | untl ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | snce ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | stab φ ih =>
    exact forall_congr' fun σ => imp_congr_right fun _ => imp_congr_right fun _ => ih σ x

/-! ## The transport layer

The two lemmas the archived correspondence-record-and-store-recall-recommendation report, §II.3,
flagged as breaking under time registers, restated in
the forms that survive them. -/

/--
Pointwise-equal histories (same domain, same states) satisfy the same L⋆ formulas, at a fixed
stored-time vector.

The L⋆ restatement of `truth_congr_ext` (`Semantics/PlusTruth.lean`). The two register cases are
where the vector moves: `timeStore` recurses at `Function.update v i x`, `timeRecall` at the
time `v i` — in both cases the *same* vector on both sides of the biconditional, which is why
this lemma needs no shift.
-/
theorem star_truth_congr_ext (M : TaskModel F) (φ : StarFormula) :
    ∀ (τ σ : ConvexHistory F) (x : F.Duration) (v : ℕ → F.Duration),
      (∀ s, τ.domain s ↔ σ.domain s) →
      (∀ s (hτ : τ.domain s) (hσ : σ.domain s), τ.states s hτ = σ.states s hσ) →
      (StarTruthAt M τ x v φ ↔ StarTruthAt M σ x v φ) := by
  induction φ with
  | atom p =>
    intro τ σ x v hd hs
    constructor
    · rintro ⟨h1, hv⟩; exact ⟨(hd x).mp h1, by rw [← hs x h1 ((hd x).mp h1)]; exact hv⟩
    · rintro ⟨h2, hv⟩; exact ⟨(hd x).mpr h2, by rw [hs x ((hd x).mpr h2) h2]; exact hv⟩
  | bot => intros; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
    intro τ σ x v hd hs; exact Iff.imp (ihφ τ σ x v hd hs) (ihψ τ σ x v hd hs)
  | box φ _ => intros; exact Iff.rfl
  | untl ψ φ ihψ ihφ =>
    intro τ σ x v hd hs
    exact exists_congr fun s => and_congr_right fun _ => and_congr (ihφ τ σ s v hd hs)
      (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ σ r v hd hs)
  | snce ψ φ ihψ ihφ =>
    intro τ σ x v hd hs
    exact exists_congr fun s => and_congr_right fun _ => and_congr (ihφ τ σ s v hd hs)
      (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ σ r v hd hs)
  | stab φ _ =>
    intro τ σ x v hd hs
    refine forall_congr' fun ρ => imp_congr_right fun _ => imp_congr_left ⟨?_, ?_⟩
    · intro h hσ' hρ'; rw [← hs x ((hd x).mpr hσ') hσ']; exact h _ _
    · intro h hτ' hρ'; rw [hs x hτ' ((hd x).mp hτ')]; exact h _ _
  | timeStore i φ ih =>
    intro τ σ x v hd hs
    exact ih τ σ x (Function.update v i x) hd hs
  | timeRecall i φ ih =>
    intro τ σ x v hd hs
    exact ih τ σ (v i) v hd hs

/--
**The update/shift commutation identity.** Writing `t` into register `i` and then shifting every
register by `Δ` is writing `t + Δ` into register `i` of the already-shifted vector.

This is the one new rewrite `starTruthAt_timeShift`'s `timeStore` case needs, and the reason the
vector in that lemma is shifted rather than dropped.
-/
theorem update_shift_comm (v : ℕ → F.Duration) (i : ℕ) (t Δ : F.Duration) :
    (fun j => Function.update v i t j + Δ) = Function.update (fun j => v j + Δ) i (t + Δ) := by
  funext j
  by_cases h : j = i
  · subst h; simp
  · simp [h]

/--
**L⋆ truth commutes with time shift, the stored-time vector shifting with it.**

The L⋆ restatement of `plusTruthAt_timeShift` (`Semantics/PlusTruth.lean`), whose proof shape it
follows verbatim: the `box` and `stab` cases need the inverse shift plus `star_truth_congr_ext`,
because `timeShift` is not definitionally involutive. The `timeStore` case consumes
`update_shift_comm`; the `timeRecall` case is the register lookup commuting with the shift.

**Divergence from the plan's pinned Challenge statement, recorded**: that statement carried a
totality hypothesis `hσ : σ.IsTotal`. It is not needed — the `box` and `stab` cases apply
totality to the *quantified* history `ρ`, never to `σ` — so it is dropped here, which
strengthens the lemma rather than weakening it. `plusTruthAt_timeShift`, the lemma this one
restates, likewise takes no totality hypothesis.
-/
theorem starTruthAt_timeShift (M : TaskModel F) (φ : StarFormula) :
    ∀ (σ : ConvexHistory F) (t Δ : F.Duration) (v : ℕ → F.Duration),
      StarTruthAt M (σ.timeShift Δ) t v φ ↔ StarTruthAt M σ (t + Δ) (fun i => v i + Δ) φ := by
  induction φ with
  | atom p => intros; exact Iff.rfl
  | bot => intros; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro σ t Δ v; exact Iff.imp (ihφ σ t Δ v) (ihψ σ t Δ v)
  | box φ ih =>
    intro σ t Δ v
    constructor
    · intro h ρ hρ
      exact (ih ρ t Δ v).mp (h (ρ.timeShift Δ) (timeShift_isTotal' ρ hρ Δ))
    · intro h ρ hρ
      have h1 := (ih (ρ.timeShift (-Δ)) t Δ v).mpr
        (h (ρ.timeShift (-Δ)) (timeShift_isTotal' ρ hρ (-Δ)))
      exact (star_truth_congr_ext M φ _ ρ t v (shift_neg_shift_domain ρ Δ)
        (shift_neg_shift_states ρ Δ)).mp h1
  | untl ψ φ ihψ ihφ =>
    intro σ t Δ v
    constructor
    · rintro ⟨s, hts, hφ, hψ⟩
      refine ⟨s + Δ, (add_lt_add_iff_right Δ).mpr hts, (ihφ σ s Δ v).mp hφ, ?_⟩
      intro r' h1 h2
      have := ihψ σ (r' - Δ) Δ v
      rw [sub_add_cancel] at this
      exact this.mp (hψ (r' - Δ) (lt_sub_iff_add_lt.mpr h1) (sub_lt_iff_lt_add.mpr h2))
    · rintro ⟨s', h, hφ, hψ⟩
      refine ⟨s' - Δ, lt_sub_iff_add_lt.mpr h, ?_, ?_⟩
      · have := ihφ σ (s' - Δ) Δ v
        rw [sub_add_cancel] at this
        exact this.mpr hφ
      · intro r htr hrs
        exact (ihψ σ r Δ v).mpr
          (hψ (r + Δ) ((add_lt_add_iff_right Δ).mpr htr) (lt_sub_iff_add_lt.mp hrs))
  | snce ψ φ ihψ ihφ =>
    intro σ t Δ v
    constructor
    · rintro ⟨s, hst, hφ, hψ⟩
      refine ⟨s + Δ, (add_lt_add_iff_right Δ).mpr hst, (ihφ σ s Δ v).mp hφ, ?_⟩
      intro r' h1 h2
      have := ihψ σ (r' - Δ) Δ v
      rw [sub_add_cancel] at this
      exact this.mp (hψ (r' - Δ) (lt_sub_iff_add_lt.mpr h1) (sub_lt_iff_lt_add.mpr h2))
    · rintro ⟨s', h, hφ, hψ⟩
      refine ⟨s' - Δ, sub_lt_iff_lt_add.mpr h, ?_, ?_⟩
      · have := ihφ σ (s' - Δ) Δ v
        rw [sub_add_cancel] at this
        exact this.mpr hφ
      · intro r hsr hrt
        exact (ihψ σ r Δ v).mpr
          (hψ (r + Δ) (sub_lt_iff_lt_add.mp hsr) ((add_lt_add_iff_right Δ).mpr hrt))
  | stab φ ih =>
    intro σ t Δ v
    constructor
    · intro h ρ hρ hs
      exact (ih ρ t Δ v).mp (h (ρ.timeShift Δ) (timeShift_isTotal' ρ hρ Δ) hs)
    · intro h ρ hρ hs
      have hs' : SameStateAt σ (ρ.timeShift (-Δ)) (t + Δ) := by
        intro hσ' hρ'
        exact (hs hσ' (hρ t)).trans (states_congr ρ (add_neg_cancel_right t Δ).symm (hρ t))
      have h1 := (ih (ρ.timeShift (-Δ)) t Δ v).mpr
        (h (ρ.timeShift (-Δ)) (timeShift_isTotal' ρ hρ (-Δ)) hs')
      exact (star_truth_congr_ext M φ _ ρ t v (shift_neg_shift_domain ρ Δ)
        (shift_neg_shift_states ρ Δ)).mp h1
  | timeStore i φ ih =>
    intro σ t Δ v
    rw [StarTruth.timeStore_iff, StarTruth.timeStore_iff, ih σ t Δ (Function.update v i t),
      update_shift_comm]
  | timeRecall i φ ih =>
    intro σ t Δ v
    rw [StarTruth.timeRecall_iff, StarTruth.timeRecall_iff, ih σ (v i) Δ v]

end FormalSystem.Semantics
