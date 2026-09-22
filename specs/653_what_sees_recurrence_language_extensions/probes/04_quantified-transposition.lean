/-
Probe 04 — the quantified transposition sentence defines recurrence-freeness (closes the report's
UNVERIFIED item 6; table cell Transposition × "L + ∀p (standard)").

Research probe only (sorry-free, compiled with `lake env lean`); nothing here is proposed for
`FormalSystem/`. Names live in `Probe653`.

Contents:
* `qTrans` — `∀p ∀q (Atom_r(p) → Atom_r(q) → ¬(E(p ∧ F q) ∧ E(q ∧ F p)))`, the quantified form of
  the hybrid transposition formula `transF` (`HybridLanguage/HybridTransposition.lean`), with
  `Atom(·)` manufacturing the two nominals from two quantified letters
  (`QuantLanguage/QuantRecurrence.lean`, `isAtom_iff`).
* `qTrans_valid` — the sentence holds everywhere on a recurrence-free frame. The two `Atom`
  premises name states `w_p`, `w_q`; the two existentials give histories through `w_p` then
  `w_q` and through `w_q` then `w_p`; `recurrenceFree_not_transposed` is the hybrid frame-level
  core, reused verbatim — which is the content of "state nominals and standard quantifiers see
  the same features" (report §2.1, `HybridRecurrence.lean`'s "minimal resource").
* `qTrans_defines` — validity of the sentence on a frame iff the frame is recurrence-free. `→`
  mirrors `qRec_defines`: both quantifiers are instantiated at the singleton of a recurring
  state, so both named states coincide — a same-state transposition, exactly as
  `transF_refuted_of_recur`.
-/

import FormalSystem.QuantLanguage.QuantRecurrence
import FormalSystem.HybridLanguage.HybridTransposition

namespace Probe653

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.QuantLanguage
open FormalSystem.QuantLanguage.QuantTruth
open FormalSystem.HybridLanguage

/-- `∀p ∀q (Atom_r(p) → Atom_r(q) → ¬(E(p ∧ F q) ∧ E(q ∧ F p)))`: the quantified transposition
sentence, with `r` the fresh letter that `Atom(·)` binds internally. -/
abbrev qTrans (p q r : Atom) : QuantFormula :=
  QuantFormula.all p (QuantFormula.all q
    ((QuantFormula.isAtom p r).imp ((QuantFormula.isAtom q r).imp
      ((QuantFormula.exist ((QuantFormula.atom p).and
          (QuantFormula.someFuture (QuantFormula.atom q)))).and
        (QuantFormula.exist ((QuantFormula.atom q).and
          (QuantFormula.someFuture (QuantFormula.atom p))))).neg)))

/-- The quantified transposition sentence is true everywhere on a recurrence-free frame, at every
instantiation of the two quantifiers. The `p`- and `q`-valuations of the doubly updated model are
read through `updateAtom_valuation_self` / `updateAtom_valuation_of_ne _ hpq`, as `qRec_valid`
does; the conclusion is `recurrenceFree_not_transposed` at the two witnessing histories. -/
theorem qTrans_valid {G : TaskFrame} (hG : G.RecurrenceFree) (M : TaskModel G)
    (τ : WorldHistory G) (t : G.Duration) {p q r : Atom} (hpq : p ≠ q) (hpr : p ≠ r)
    (hqr : q ≠ r) :
    QuantTruthAt M τ t Set.univ (qTrans p q r) := by
  rw [qTrans, all_iff]
  intro S _
  rw [all_iff]
  intro T _
  rw [imp_iff, imp_iff, isAtom_iff _ _ _ hpr, isAtom_iff _ _ _ hqr, neg_iff]
  simp only [exist_iff, and_iff, someFuture_iff, atom_iff, TaskModel.updateAtom_valuation_self,
    TaskModel.updateAtom_valuation_of_ne _ hpq]
  rintro ⟨wp, -, hp⟩ ⟨wq, -, hq⟩ ⟨⟨ρ₁, s₁, h₁p, t₁, hs₁, h₁q⟩, ⟨ρ₂, s₂, h₂q, t₂, hs₂, h₂p⟩⟩
  exact recurrenceFree_not_transposed hG ρ₁ ρ₂ hs₁ hs₂
    ((hp ρ₁ s₁ h₁p).trans (hp ρ₂ t₂ h₂p).symm) ((hq ρ₁ t₁ h₁q).trans (hq ρ₂ s₂ h₂q).symm)

/-- **Definability under standard quantification**: the quantified transposition sentence is
valid on a frame iff the frame is recurrence-free. `←` is `qTrans_valid`. `→`: at a recurrence
`τ(s) = τ(t)`, `s ≠ t`, instantiate both quantifiers at `{τ(s)}` in the model with empty
valuation; both `Atom` premises hold, and the one history `τ` witnesses both existentials at
`min`/`max` of `s, t` — the same-state transposition of `transF_refuted_of_recur`. -/
theorem qTrans_defines (G : TaskFrame) {p q r : Atom} (hpq : p ≠ q) (hpr : p ≠ r)
    (hqr : q ≠ r) :
    (∀ (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration),
      QuantTruthAt M τ t Set.univ (qTrans p q r)) ↔ G.RecurrenceFree := by
  constructor
  · intro h τ s t hst
    by_contra hne
    have h1 := h ⟨fun _ _ => False⟩ τ s
    rw [qTrans, all_iff] at h1
    have h2 := h1 {τ.state s} (Set.mem_univ _)
    rw [all_iff] at h2
    have h3 := h2 {τ.state s} (Set.mem_univ _)
    rw [imp_iff, imp_iff, isAtom_iff _ _ _ hpr, isAtom_iff _ _ _ hqr, neg_iff] at h3
    simp only [exist_iff, and_iff, someFuture_iff, atom_iff, TaskModel.updateAtom_valuation_self,
      TaskModel.updateAtom_valuation_of_ne _ hpq] at h3
    apply h3
    · exact ⟨τ.state s, Set.mem_singleton _, fun ρ u hu => hu⟩
    · exact ⟨τ.state s, Set.mem_singleton _, fun ρ u hu => hu⟩
    · rcases lt_or_gt_of_ne hne with hlt | hgt
      · exact ⟨⟨τ, s, Set.mem_singleton _, t, hlt, hst.symm⟩,
          ⟨τ, s, Set.mem_singleton _, t, hlt, hst.symm⟩⟩
      · exact ⟨⟨τ, t, hst.symm, s, hgt, Set.mem_singleton _⟩,
          ⟨τ, t, hst.symm, s, hgt, Set.mem_singleton _⟩⟩
  · intro hG M τ t; exact qTrans_valid hG M τ t hpq hpr hqr

end Probe653
