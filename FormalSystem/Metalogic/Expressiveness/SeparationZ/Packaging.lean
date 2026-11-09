/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.JunctionDepth

/-!
# CNF packaging of a separated formula

`SeparationOver` (`OpenFutureElimination.lean`) asks for a separated **conjunctive normal form**:
a list of clauses `(αᵢ, βᵢ)` with `αᵢ` past-determined and `βᵢ` future-determined, read as
`⋀ᵢ (αᵢ ∨ βᵢ)` by `sepForm`. Theorem 10.2.9 (`JunctionDepth.lean`'s `sep`) delivers a
syntactically separated `USForm`: a Boolean combination, through `imp` and `bot`, of literals
each of which is `untl`-free or `snce`-free. This module packages the one into the other, at the
`USForm` level; `Discharge.lean` carries the result across the `LeafAbstraction.lean` seam.

## The route

A separated formula's Boolean skeleton is put in conjunctive normal form by the mutual recursion
`cnfPos`/`cnfNeg` — the clause lists of the formula and of its negation, with `imp φ ψ` read as
`¬φ ∨ ψ` and distributed clause-by-clause (`cnfPos`), or as `φ ∧ ¬ψ` and concatenated
(`cnfNeg`). Each literal is an atom of the skeleton (a leaf, an `untl` with `snce`-free arguments,
a `snce` with `untl`-free arguments) or its negation, so every literal is `IsUOnly` or `IsSOnly`
(`pureLit_cnf`). `packClause` then splits a clause by `IsSOnly`, which is decidable here through
the landed `IsUOnly` decision and the time reflection: the `snce`-only literals and the leaves go
to the past component, the remaining (`untl`-only) literals to the future component, each side
disjoined by `orList` with `⊥` for an absent side. `sepFormUS` is `sepForm`'s shape on `USForm`,
and `usTruth_sepFormUS_package` is the truth-preservation lemma: the packaged clause list is
equivalent to the separated formula at every leaf valuation and time. This step has no counterpart
in the source — GHR state separation as a Boolean combination and never package it — and is the
module's main obligation.

The CNF truth lemma `cnfTruth_cnf` holds for every `USForm`, separated or not; separatedness is
consumed only by the purity lemma `pureLit_cnf`, which is what makes the two components pure.

## Main Definitions

- `cnfPos`, `cnfNeg`: the clause lists of a formula and of its negation
- `orList`, `packClause`, `package`: a clause as a disjunction, a clause as a (past, future) pair,
  and a separated formula as a clause-pair list
- `sepFormUS`: `⋀ᵢ (αᵢ ∨ βᵢ)` on `USForm`, the shape `toPlus` carries to `sepForm`

## Main Results

- `cnfTruth_cnf`: the CNF is truth-preserving
- `pureLit_cnf`: every literal of a separated formula's CNF is `untl`-free or `snce`-free
- `usTruth_sepFormUS_package`: the packaged clause list is equivalent to the separated formula
- `isSOnly_fst_of_mem_package`, `isUOnly_snd_of_mem_package`: each packaged clause is a
  (`snce`-only, `untl`-only) pair

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Theorem 10.2.9
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## Deciding `snce`-only-ness -/

/-- `IsSOnly` is decidable, through the landed `IsUOnly` decision and the time reflection: `φ` is
`untl`-free exactly when `φ.swap` is `snce`-free. -/
instance : DecidablePred IsSOnly := fun φ =>
  decidable_of_iff (IsUOnly φ.swap) ⟨fun h => by simpa using h.swap, IsSOnly.swap⟩

/-! ## A clause as a disjunction -/

/-- The disjunction of a list of literals, `⊥` when the list is empty. -/
def orList : List USForm → USForm
  | [] => USForm.bot
  | l :: ls => l.or (orList ls)

theorem usTruth_orList (v : ℕ → ℤ → Prop) (t : ℤ) :
    ∀ ls : List USForm, usTruth v t (orList ls) ↔ ∃ l ∈ ls, usTruth v t l
  | [] => by simp [orList]
  | l :: ls => by
      rw [orList, usTruth_or_iff, usTruth_orList v t ls]
      simp

theorem isSOnly_orList : ∀ {ls : List USForm}, (∀ l ∈ ls, IsSOnly l) → IsSOnly (orList ls)
  | [], _ => IsSOnly.bot
  | l :: _, h =>
      IsSOnly.or (h l (List.mem_cons.mpr (Or.inl rfl)))
        (isSOnly_orList fun x hx => h x (List.mem_cons.mpr (Or.inr hx)))

theorem isUOnly_orList : ∀ {ls : List USForm}, (∀ l ∈ ls, IsUOnly l) → IsUOnly (orList ls)
  | [], _ => IsUOnly.bot
  | l :: _, h =>
      IsUOnly.or (h l (List.mem_cons.mpr (Or.inl rfl)))
        (isUOnly_orList fun x hx => h x (List.mem_cons.mpr (Or.inr hx)))

/-! ## Conjunctive normal form of the Boolean skeleton -/

/-- A clause list holds when every clause has a true literal. -/
def cnfTruth (v : ℕ → ℤ → Prop) (t : ℤ) (C : List (List USForm)) : Prop :=
  ∀ c ∈ C, ∃ l ∈ c, usTruth v t l

mutual
/-- The clause list of a formula: an atom is its own single literal, `⊥` is the single empty
clause, and `imp φ ψ` is `¬φ ∨ ψ`, distributed clause-by-clause over the clause lists of `¬φ`
and of `ψ`. -/
def cnfPos : USForm → List (List USForm)
  | .leaf i => [[USForm.leaf i]]
  | .bot => [[]]
  | .imp φ ψ => (cnfNeg φ).flatMap fun c => (cnfPos ψ).map fun d => c ++ d
  | .untl ψ φ => [[USForm.untl ψ φ]]
  | .snce ψ φ => [[USForm.snce ψ φ]]

/-- The clause list of a formula's negation: an atom's negation is its own single literal, `¬⊥`
has no clauses, and `¬(imp φ ψ)` is `φ ∧ ¬ψ`, the concatenation of the clause lists of `φ` and
of `¬ψ`. -/
def cnfNeg : USForm → List (List USForm)
  | .leaf i => [[(USForm.leaf i).neg]]
  | .bot => []
  | .imp φ ψ => cnfPos φ ++ cnfNeg ψ
  | .untl ψ φ => [[(USForm.untl ψ φ).neg]]
  | .snce ψ φ => [[(USForm.snce ψ φ).neg]]
end

theorem cnfPos_leaf (i : ℕ) : cnfPos (USForm.leaf i) = [[USForm.leaf i]] := rfl

theorem cnfPos_bot : cnfPos USForm.bot = [[]] := rfl

theorem cnfPos_imp (φ ψ : USForm) :
    cnfPos (USForm.imp φ ψ) = (cnfNeg φ).flatMap fun c => (cnfPos ψ).map fun d => c ++ d := rfl

theorem cnfPos_untl (ψ φ : USForm) : cnfPos (USForm.untl ψ φ) = [[USForm.untl ψ φ]] := rfl

theorem cnfPos_snce (ψ φ : USForm) : cnfPos (USForm.snce ψ φ) = [[USForm.snce ψ φ]] := rfl

theorem cnfNeg_leaf (i : ℕ) : cnfNeg (USForm.leaf i) = [[(USForm.leaf i).neg]] := rfl

theorem cnfNeg_bot : cnfNeg USForm.bot = [] := rfl

theorem cnfNeg_imp (φ ψ : USForm) : cnfNeg (USForm.imp φ ψ) = cnfPos φ ++ cnfNeg ψ := rfl

theorem cnfNeg_untl (ψ φ : USForm) : cnfNeg (USForm.untl ψ φ) = [[(USForm.untl ψ φ).neg]] := rfl

theorem cnfNeg_snce (ψ φ : USForm) : cnfNeg (USForm.snce ψ φ) = [[(USForm.snce ψ φ).neg]] := rfl

theorem cnfTruth_singleton (v : ℕ → ℤ → Prop) (t : ℤ) (x : USForm) :
    cnfTruth v t [[x]] ↔ usTruth v t x := by
  simp [cnfTruth]

theorem cnfTruth_append (v : ℕ → ℤ → Prop) (t : ℤ) (C D : List (List USForm)) :
    cnfTruth v t (C ++ D) ↔ cnfTruth v t C ∧ cnfTruth v t D := by
  simp only [cnfTruth]
  exact List.forall_mem_append

/-- Clause-by-clause distribution is disjunction: `⋀ᵢ ⋀ⱼ (cᵢ ∨ dⱼ)` holds exactly when
`⋀ᵢ cᵢ` or `⋀ⱼ dⱼ` does. -/
theorem cnfTruth_distrib (v : ℕ → ℤ → Prop) (t : ℤ) (C D : List (List USForm)) :
    cnfTruth v t (C.flatMap fun c => D.map fun d => c ++ d) ↔
      cnfTruth v t C ∨ cnfTruth v t D := by
  simp only [cnfTruth]
  constructor
  · intro h
    by_contra hcon
    rw [not_or] at hcon
    obtain ⟨hC, hD⟩ := hcon
    push Not at hC hD
    obtain ⟨c, hc, hcl⟩ := hC
    obtain ⟨d, hd, hdl⟩ := hD
    obtain ⟨l, hl, hlt⟩ :=
      h (c ++ d) (List.mem_flatMap.mpr ⟨c, hc, List.mem_map.mpr ⟨d, hd, rfl⟩⟩)
    rcases List.mem_append.mp hl with h' | h'
    · exact hcl l h' hlt
    · exact hdl l h' hlt
  · rintro (h | h) e he
    · obtain ⟨c, hc, he'⟩ := List.mem_flatMap.mp he
      obtain ⟨d, _, rfl⟩ := List.mem_map.mp he'
      obtain ⟨l, hl, hlt⟩ := h c hc
      exact ⟨l, List.mem_append.mpr (Or.inl hl), hlt⟩
    · obtain ⟨c, _, he'⟩ := List.mem_flatMap.mp he
      obtain ⟨d, hd, rfl⟩ := List.mem_map.mp he'
      obtain ⟨l, hl, hlt⟩ := h d hd
      exact ⟨l, List.mem_append.mpr (Or.inr hl), hlt⟩

/-- **The CNF is truth-preserving**, for every formula: `cnfPos φ` holds exactly when `φ` does and
`cnfNeg φ` exactly when `φ` fails.

Paper: — (formalization-native; the manuscript states separation as a Boolean combination and
never puts it in conjunctive normal form) -/
theorem cnfTruth_cnf (v : ℕ → ℤ → Prop) (t : ℤ) : ∀ φ : USForm,
    (cnfTruth v t (cnfPos φ) ↔ usTruth v t φ) ∧ (cnfTruth v t (cnfNeg φ) ↔ ¬ usTruth v t φ)
  | .leaf i => by
      rw [cnfPos_leaf, cnfNeg_leaf, cnfTruth_singleton, cnfTruth_singleton, usTruth_neg_iff]
      exact ⟨Iff.rfl, Iff.rfl⟩
  | .bot => by
      refine ⟨?_, ?_⟩
      · rw [cnfPos_bot]; simp [cnfTruth]
      · rw [cnfNeg_bot]; simp [cnfTruth]
  | .imp φ ψ => by
      obtain ⟨h1, h2⟩ := cnfTruth_cnf v t φ
      obtain ⟨h3, h4⟩ := cnfTruth_cnf v t ψ
      refine ⟨?_, ?_⟩
      · rw [cnfPos_imp, cnfTruth_distrib, h2, h3, usTruth_imp_iff]
        exact imp_iff_not_or.symm
      · rw [cnfNeg_imp, cnfTruth_append, h1, h4, usTruth_imp_iff]
        exact Classical.not_imp.symm
  | .untl ψ φ => by
      rw [cnfPos_untl, cnfNeg_untl, cnfTruth_singleton, cnfTruth_singleton, usTruth_neg_iff]
      exact ⟨Iff.rfl, Iff.rfl⟩
  | .snce ψ φ => by
      rw [cnfPos_snce, cnfNeg_snce, cnfTruth_singleton, cnfTruth_singleton, usTruth_neg_iff]
      exact ⟨Iff.rfl, Iff.rfl⟩

theorem forall_lit_singleton {P : USForm → Prop} {x : USForm} (hx : P x) :
    ∀ c ∈ [[x]], ∀ l ∈ c, P l := by
  intro c hc l hl
  rw [List.mem_singleton] at hc
  subst hc
  rw [List.mem_singleton] at hl
  subst hl
  exact hx

/-- **Every literal of a separated formula's CNF is pure**: an atom of a separated skeleton is a
leaf, an `untl` with `snce`-free arguments or a `snce` with `untl`-free arguments, and negation
preserves either purity. -/
theorem pureLit_cnf {S : USForm} (hS : IsSeparated S) :
    (∀ c ∈ cnfPos S, ∀ l ∈ c, IsUOnly l ∨ IsSOnly l) ∧
      ∀ c ∈ cnfNeg S, ∀ l ∈ c, IsUOnly l ∨ IsSOnly l := by
  induction hS with
  | leaf i =>
      refine ⟨?_, ?_⟩
      · rw [cnfPos_leaf]; exact forall_lit_singleton (Or.inl (IsUOnly.leaf i))
      · rw [cnfNeg_leaf]; exact forall_lit_singleton (Or.inl (IsUOnly.leaf i).neg)
  | bot =>
      refine ⟨fun c hc l hl => ?_, fun c hc => ?_⟩
      · rw [cnfPos_bot, List.mem_singleton] at hc
        subst hc
        simp at hl
      · rw [cnfNeg_bot] at hc
        simp at hc
  | imp _ _ ih1 ih2 =>
      refine ⟨fun e he l hl => ?_, fun e he l hl => ?_⟩
      · rw [cnfPos_imp] at he
        obtain ⟨c, hc, he'⟩ := List.mem_flatMap.mp he
        obtain ⟨d, hd, rfl⟩ := List.mem_map.mp he'
        rcases List.mem_append.mp hl with h | h
        · exact ih1.2 c hc l h
        · exact ih2.1 d hd l h
      · rw [cnfNeg_imp] at he
        rcases List.mem_append.mp he with h | h
        · exact ih1.1 e h l hl
        · exact ih2.2 e h l hl
  | untl hψ hφ =>
      refine ⟨?_, ?_⟩
      · rw [cnfPos_untl]; exact forall_lit_singleton (Or.inl (IsUOnly.untl hψ hφ))
      · rw [cnfNeg_untl]; exact forall_lit_singleton (Or.inl (IsUOnly.untl hψ hφ).neg)
  | snce hψ hφ =>
      refine ⟨?_, ?_⟩
      · rw [cnfPos_snce]; exact forall_lit_singleton (Or.inr (IsSOnly.snce hψ hφ))
      · rw [cnfNeg_snce]; exact forall_lit_singleton (Or.inr (IsSOnly.snce hψ hφ).neg)

/-! ## A clause as a (past, future) pair -/

/-- Split a clause by `IsSOnly`: the `snce`-only literals and the leaves to the first component,
the rest to the second, each side disjoined and padded with `⊥` when empty. -/
def packClause (c : List USForm) : USForm × USForm :=
  (orList (c.filter fun l => decide (IsSOnly l)),
    orList (c.filter fun l => !decide (IsSOnly l)))

theorem usTruth_packClause (v : ℕ → ℤ → Prop) (t : ℤ) (c : List USForm) :
    usTruth v t ((packClause c).1.or (packClause c).2) ↔ ∃ l ∈ c, usTruth v t l := by
  simp only [packClause, usTruth_or_iff, usTruth_orList, List.mem_filter]
  constructor
  · rintro (⟨l, ⟨hl, _⟩, hlt⟩ | ⟨l, ⟨hl, _⟩, hlt⟩) <;> exact ⟨l, hl, hlt⟩
  · rintro ⟨l, hl, hlt⟩
    by_cases h : IsSOnly l
    · exact Or.inl ⟨l, ⟨hl, decide_eq_true h⟩, hlt⟩
    · exact Or.inr ⟨l, ⟨hl, by simp [h]⟩, hlt⟩

theorem isSOnly_packClause_fst (c : List USForm) : IsSOnly (packClause c).1 := by
  apply isSOnly_orList
  intro l hl
  rw [List.mem_filter] at hl
  exact of_decide_eq_true hl.2

theorem isUOnly_packClause_snd {c : List USForm} (h : ∀ l ∈ c, IsUOnly l ∨ IsSOnly l) :
    IsUOnly (packClause c).2 := by
  apply isUOnly_orList
  intro l hl
  rw [List.mem_filter] at hl
  have hns : ¬ IsSOnly l := by simpa using hl.2
  exact (h l hl.1).resolve_right hns

/-! ## The packaged form -/

/-- `⋀ᵢ (αᵢ ∨ βᵢ)` on `USForm`: the shape `toPlus` carries to `sepForm`. -/
def sepFormUS : List (USForm × USForm) → USForm
  | [] => USForm.top
  | c :: L => (c.1.or c.2).and (sepFormUS L)

theorem usTruth_sepFormUS (v : ℕ → ℤ → Prop) (t : ℤ) :
    ∀ L : List (USForm × USForm), usTruth v t (sepFormUS L) ↔ ∀ c ∈ L, usTruth v t (c.1.or c.2)
  | [] => by simp [sepFormUS]
  | c :: L => by
      rw [sepFormUS, usTruth_and_iff, usTruth_sepFormUS v t L, List.forall_mem_cons]

/-- A separated formula as a list of (past, future) clause pairs: its CNF, clause by clause. -/
def package (S : USForm) : List (USForm × USForm) := (cnfPos S).map packClause

/--
**The packaging is truth-preserving**: the packaged clause list, read as `⋀ᵢ (αᵢ ∨ βᵢ)`, is
equivalent to the formula at every leaf valuation and time. No separatedness is needed for this
half; it is `cnfTruth_cnf` composed with `usTruth_packClause`.

Paper: — (formalization-native; the manuscript states separation as a Boolean combination and
never packages it into a clause list)
-/
theorem usTruth_sepFormUS_package (v : ℕ → ℤ → Prop) (t : ℤ) (S : USForm) :
    usTruth v t (sepFormUS (package S)) ↔ usTruth v t S := by
  rw [usTruth_sepFormUS, ← (cnfTruth_cnf v t S).1]
  simp only [package, cnfTruth, List.forall_mem_map, usTruth_packClause]

/-- The past component of every packaged clause is `untl`-free. -/
theorem isSOnly_fst_of_mem_package {S : USForm} (c : USForm × USForm) (hc : c ∈ package S) :
    IsSOnly c.1 := by
  obtain ⟨d, _, rfl⟩ := List.mem_map.mp hc
  exact isSOnly_packClause_fst d

/-- The future component of every packaged clause of a separated formula is `snce`-free. This is
the one place separatedness is consumed. -/
theorem isUOnly_snd_of_mem_package {S : USForm} (hS : IsSeparated S) (c : USForm × USForm)
    (hc : c ∈ package S) : IsUOnly c.2 := by
  obtain ⟨d, hd, rfl⟩ := List.mem_map.mp hc
  exact isUOnly_packClause_snd ((pureLit_cnf hS).1 d hd)

end FormalSystem.Metalogic.Expressiveness.SeparationZ
