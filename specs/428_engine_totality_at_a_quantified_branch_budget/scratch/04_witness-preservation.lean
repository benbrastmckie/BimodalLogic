import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel

namespace Scratch428
open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- The renaming induced by identifying `src` into `tgt`. -/
def rho (src tgt t : TimeIndex) : TimeIndex := if t = src then tgt else t

/-- **Edge transport.** A constraint that does not collapse survives, renamed. -/
theorem identifyTime_edge (ord : TimeOrdering) (src tgt a b : TimeIndex)
    (h : (a, b) ∈ ord.constraints)
    (hne : rho src tgt a ≠ rho src tgt b) :
    (rho src tgt a, rho src tgt b) ∈ (ord.identifyTime src tgt).constraints := by
  simp only [TimeOrdering.identifyTime, List.mem_eraseDups, List.mem_filterMap]
  refine ⟨(a, b), h, ?_⟩
  simp only [rho] at hne ⊢
  simp only [beq_iff_eq]
  rw [if_neg (by simpa [rho, beq_iff_eq] using hne)]

end Scratch428

namespace Scratch428
open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax
open TimeOrdering

theorem mem_futureOf_of_mem_constraints (ord : TimeOrdering) (a b : TimeIndex)
    (h : (a, b) ∈ ord.constraints) : b ∈ ord.futureOf a := by
  rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq]
  refine TimeOrdering.bfsClosure_complete _ (n := 1) ⟨b, ?_, rfl⟩ (le_refl 1) (by omega)
  simp only [TimeOrdering.directFutureOf, List.mem_filterMap]
  exact ⟨(a, b), h, by simp⟩

theorem mem_pastOf_of_mem_constraints (ord : TimeOrdering) (a b : TimeIndex)
    (h : (a, b) ∈ ord.constraints) : a ∈ ord.pastOf b := by
  rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq]
  refine TimeOrdering.bfsClosure_complete _ (n := 1) ⟨a, ?_, rfl⟩ (le_refl 1) (by omega)
  simp only [TimeOrdering.directPastOf, List.mem_filterMap]
  exact ⟨(a, b), h, by simp⟩

end Scratch428

namespace Scratch428
open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- **Collapse-freedom.** On an incomparable pair, no constraint collapses. -/
theorem identifyTime_no_collapse (ord : TimeOrdering) (t₁ t₂ : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2)
    (a b : TimeIndex) (h : (a, b) ∈ ord.constraints) :
    rho t₂ t₁ a ≠ rho t₂ t₁ b := by
  simp only [incomparableB, Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true',
    List.contains_eq_mem, decide_eq_false_iff_not] at hinc
  obtain ⟨⟨hne, hf⟩, hp⟩ := hinc
  have hab : a ≠ b := hnsl (a, b) h
  simp only [rho]
  by_cases ha : a = t₂ <;> by_cases hb : b = t₂
  · exact absurd (ha.trans hb.symm) hab
  · rw [if_pos ha, if_neg hb]
    intro hcon
    rw [ha, ← hcon] at h
    exact hp (mem_pastOf_of_mem_constraints ord t₂ t₁ h)
  · rw [if_neg ha, if_pos hb]
    intro hcon
    rw [hcon, hb] at h
    exact hf (mem_futureOf_of_mem_constraints ord t₁ t₂ h)
  · rw [if_neg ha, if_neg hb]; exact hab

end Scratch428

namespace Scratch428
open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

theorem mem_directFutureOf_iff' (ord : TimeOrdering) (a b : TimeIndex) :
    b ∈ ord.directFutureOf a ↔ (a, b) ∈ ord.constraints := by
  simp only [TimeOrdering.directFutureOf, List.mem_filterMap]
  constructor
  · rintro ⟨⟨x, y⟩, hxy, hres⟩
    by_cases hx : x = a
    · subst hx; simp at hres; subst hres; exact hxy
    · simp [hx] at hres
  · intro h; exact ⟨(a, b), h, by simp⟩

theorem mem_directPastOf_iff' (ord : TimeOrdering) (a b : TimeIndex) :
    a ∈ ord.directPastOf b ↔ (a, b) ∈ ord.constraints := by
  simp only [TimeOrdering.directPastOf, List.mem_filterMap]
  constructor
  · rintro ⟨⟨x, y⟩, hxy, hres⟩
    by_cases hy : y = b
    · subst hy; simp at hres; subst hres; exact hxy
    · simp [hy] at hres
  · intro h; exact ⟨(a, b), h, by simp⟩

/-- **Path transport along an arbitrary renaming.** -/
theorem pathN_along (f g : TimeIndex → List TimeIndex) (φ : TimeIndex → TimeIndex)
    (h : ∀ x y, y ∈ f x → φ y ∈ g (φ x)) :
    ∀ (n : Nat) (a b : TimeIndex), TimeOrdering.PathN f n a b →
      TimeOrdering.PathN g n (φ a) (φ b) := by
  intro n
  induction n with
  | zero => intro a b hp; simp only [TimeOrdering.PathN] at hp ⊢; rw [hp]
  | succ m ih =>
    intro a b hp
    obtain ⟨c, hc, hrest⟩ := hp
    exact ⟨φ c, h a c hc, ih c b hrest⟩

end Scratch428

namespace Scratch428
open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

variable (ord : TimeOrdering) (t₁ t₂ : TimeIndex)

/-- Every forward edge survives identification, renamed. -/
theorem directFutureOf_transport
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2) (a b : TimeIndex)
    (h : b ∈ ord.directFutureOf a) :
    rho t₂ t₁ b ∈ (ord.identifyTime t₂ t₁).directFutureOf (rho t₂ t₁ a) := by
  rw [mem_directFutureOf_iff'] at h ⊢
  exact identifyTime_edge ord t₂ t₁ a b h (identifyTime_no_collapse ord t₁ t₂ hinc hnsl a b h)

/-- Every backward edge survives identification, renamed. -/
theorem directPastOf_transport
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2) (a b : TimeIndex)
    (h : a ∈ ord.directPastOf b) :
    rho t₂ t₁ a ∈ (ord.identifyTime t₂ t₁).directPastOf (rho t₂ t₁ b) := by
  rw [mem_directPastOf_iff'] at h ⊢
  exact identifyTime_edge ord t₂ t₁ a b h (identifyTime_no_collapse ord t₁ t₂ hinc hnsl a b h)

/-- **THE REACHABILITY TRANSPORT, forward.** -/
theorem futureOf_transport
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2) (s t : TimeIndex)
    (h : t ∈ ord.futureOf s) :
    rho t₂ t₁ t ∈ (ord.identifyTime t₂ t₁).futureOf (rho t₂ t₁ s) := by
  rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [s] [] h with hv | ⟨u, hu, n, hn1, hn2, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hu
    subst hu
    rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq]
    exact TimeOrdering.bfsClosure_complete _
      (pathN_along _ _ (rho t₂ t₁) (directFutureOf_transport ord t₁ t₂ hinc hnsl) n u t hp)
      hn1 hn2

/-- **THE REACHABILITY TRANSPORT, backward.** -/
theorem pastOf_transport
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2) (s t : TimeIndex)
    (h : t ∈ ord.pastOf s) :
    rho t₂ t₁ t ∈ (ord.identifyTime t₂ t₁).pastOf (rho t₂ t₁ s) := by
  rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [s] [] h with hv | ⟨u, hu, n, hn1, hn2, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hu
    subst hu
    rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq]
    refine TimeOrdering.bfsClosure_complete _ (pathN_along _ _ (rho t₂ t₁) ?_ n u t hp) hn1 hn2
    intro x y hy
    exact directPastOf_transport ord t₁ t₂ hinc hnsl y x hy

end Scratch428

namespace Scratch428
open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- The signed-formula half of the renaming. -/
def rhoSF (src tgt : TimeIndex) (sf : SignedFormula) : SignedFormula :=
  { sf with label := { sf.label with time := rho src tgt sf.label.time } }

/-- **CLAIM (ii), arm 3.** Identification deletes no formula: every member survives, renamed. -/
theorem mem_identifyTime (b : Branch) (src tgt : TimeIndex) (sf : SignedFormula)
    (h : sf ∈ b) : rhoSF src tgt sf ∈ b.identifyTime src tgt := by
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map]
  refine ⟨sf, h, ?_⟩
  simp only [rhoSF, rho]
  by_cases hc : sf.label.time = src
  · simp [hc]
  · simp [hc]

/-- The `contains` form of the same fact. -/
theorem contains_identifyTime (b : Branch) (src tgt : TimeIndex) (sf : SignedFormula)
    (h : b.contains sf = true) :
    (b.identifyTime src tgt).contains (rhoSF src tgt sf) = true := by
  simp only [Branch.contains, List.any_eq_true, beq_iff_eq] at h ⊢
  obtain ⟨x, hx, hxe⟩ := h
  subst hxe
  exact ⟨_, mem_identifyTime b src tgt x hx, rfl⟩

/-- Identification touches no world: `knownWorlds` is preserved. -/
theorem knownWorlds_identifyTime (b : Branch) (src tgt : TimeIndex) (w : WorldIndex)
    (h : w ∈ b.knownWorlds) : w ∈ (b.identifyTime src tgt).knownWorlds := by
  simp only [Branch.knownWorlds, List.mem_eraseDups, List.mem_map] at h ⊢
  obtain ⟨sf, hsf, rfl⟩ := h
  exact ⟨rhoSF src tgt sf, mem_identifyTime b src tgt sf hsf, rfl⟩

end Scratch428

namespace Scratch428
open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

variable (b : Branch) (ord : TimeOrdering) (t₁ t₂ : TimeIndex)

theorem any_knownWorlds_transport (P Q : WorldIndex → Bool)
    (hPQ : ∀ w, P w = true → Q w = true)
    (h : b.knownWorlds.any P = true) :
    (b.identifyTime t₂ t₁).knownWorlds.any Q = true := by
  simp only [List.any_eq_true] at h ⊢
  obtain ⟨w, hw, hPw⟩ := h
  exact ⟨w, knownWorlds_identifyTime b t₂ t₁ w hw, hPQ w hPw⟩

theorem any_futureOf_transport (tm : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2)
    (P Q : TimeIndex → Bool)
    (hPQ : ∀ t, P t = true → Q (rho t₂ t₁ t) = true)
    (h : (ord.futureOf tm).any P = true) :
    ((ord.identifyTime t₂ t₁).futureOf (rho t₂ t₁ tm)).any Q = true := by
  simp only [List.any_eq_true] at h ⊢
  obtain ⟨t, ht, hPt⟩ := h
  exact ⟨rho t₂ t₁ t, futureOf_transport ord t₁ t₂ hinc hnsl tm t ht, hPQ t hPt⟩

theorem any_pastOf_transport (tm : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2)
    (P Q : TimeIndex → Bool)
    (hPQ : ∀ t, P t = true → Q (rho t₂ t₁ t) = true)
    (h : (ord.pastOf tm).any P = true) :
    ((ord.identifyTime t₂ t₁).pastOf (rho t₂ t₁ tm)).any Q = true := by
  simp only [List.any_eq_true] at h ⊢
  obtain ⟨t, ht, hPt⟩ := h
  exact ⟨rho t₂ t₁ t, pastOf_transport ord t₁ t₂ hinc hnsl tm t ht, hPQ t hPt⟩

/-- `contains` at a relabelled point, in the exact shape the witness tests use. -/
theorem contains_at (s : Sign) (psi : Formula) (w : WorldIndex) (t : TimeIndex)
    (h : b.contains ⟨s, psi, ⟨w, t⟩⟩ = true) :
    (b.identifyTime t₂ t₁).contains ⟨s, psi, ⟨w, rho t₂ t₁ t⟩⟩ = true :=
  contains_identifyTime b t₂ t₁ ⟨s, psi, ⟨w, t⟩⟩ h

end Scratch428

namespace Scratch428
open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- **CLAIM (i): witness preservation across `.splitOrdered` arm 3.**
Stated for *every* rule; the non-fresh-label rules are covered vacuously because
`witnessPresent` returns `false` on them. -/
theorem witnessPresent_identifyTime (rule : TableauRule) (b : Branch) (ord : TimeOrdering)
    (t₁ t₂ : TimeIndex) (s : Sign) (φ : Formula) (w : WorldIndex) (tm : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2)
    (h : witnessPresent rule ⟨s, φ, ⟨w, tm⟩⟩ b ord = true) :
    witnessPresent rule ⟨s, φ, ⟨w, rho t₂ t₁ tm⟩⟩
      (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁) = true := by
  simp only [witnessPresent] at h ⊢
  split at h
  -- RULE 1 (modal): boxNeg
  case h_1 =>
    exact any_knownWorlds_transport (b := b) (t₁ := t₁) (t₂ := t₂) _ _
      (fun w' hw' => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .neg _ w' tm hw') h
  -- RULE 2 (modal): diamondPos
  case h_2 =>
    split at h
    case h_1 =>
      exact any_knownWorlds_transport (b := b) (t₁ := t₁) (t₂ := t₂) _ _
        (fun w' hw' => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w' tm hw') h
    case h_2 => exact Bool.noConfusion h
  -- RULE 3 (temporal): allFutureNeg
  case h_3 =>
    exact any_futureOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _
      (fun t ht => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .neg _ w t ht) h
  -- RULE 4 (temporal): allPastNeg
  case h_4 =>
    exact any_pastOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _
      (fun t ht => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .neg _ w t ht) h
  -- RULE 5 (temporal): someFuturePos
  case h_5 =>
    split at h
    case h_1 =>
      exact any_futureOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _
        (fun t ht => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht) h
    case h_2 => exact Bool.noConfusion h
  -- RULE 6 (temporal): somePastPos
  case h_6 =>
    split at h
    case h_1 =>
      exact any_pastOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _
        (fun t ht => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht) h
    case h_2 => exact Bool.noConfusion h
  -- RULE 7 (temporal): untlPos
  case h_7 =>
    split at h
    case h_1 =>
      refine any_futureOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _ ?_ h
      intro t ht
      simp only [Bool.or_eq_true, Bool.and_eq_true] at ht ⊢
      rcases ht with ht | ⟨ht1, ht2⟩
      · exact Or.inl (contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht)
      · exact Or.inr ⟨contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht1,
          contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht2⟩
    case h_2 => exact Bool.noConfusion h
  -- RULE 8 (temporal): sncePos
  case h_8 =>
    split at h
    case h_1 =>
      refine any_pastOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _ ?_ h
      intro t ht
      simp only [Bool.or_eq_true, Bool.and_eq_true] at ht ⊢
      rcases ht with ht | ⟨ht1, ht2⟩
      · exact Or.inl (contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht)
      · exact Or.inr ⟨contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht1,
          contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht2⟩
    case h_2 => exact Bool.noConfusion h
  -- every other rule: `witnessPresent` is `false`
  case h_9 => exact Bool.noConfusion h

end Scratch428


namespace Scratch428
open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-! ### The two side conditions -/

/-- `hinc` is free: the trigger's own guarantee, transcribed. -/
theorem incomparableB_of_firstIncomparablePair {b : Branch} {ord : TimeOrdering}
    {t₁ t₂ : TimeIndex} (h : firstIncomparablePair b ord = some (t₁, t₂)) :
    incomparableB ord (t₁, t₂) = true := by
  obtain ⟨-, -, hne, hf, hp⟩ := firstIncomparablePair_spec h
  simp only [incomparableB, Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true',
    List.contains_eq_mem, decide_eq_false_iff_not]
  exact ⟨⟨hne, hf⟩, hp⟩

/-- Irreflexivity of the constraint list: the residual side condition `hnsl`. -/
def IrreflOrd (ord : TimeOrdering) : Prop := ∀ p ∈ ord.constraints, p.1 ≠ p.2

/-- Identification preserves irreflexivity, by construction (collapses are dropped). -/
theorem irreflOrd_identifyTime (ord : TimeOrdering) (src tgt : TimeIndex) :
    IrreflOrd (ord.identifyTime src tgt) := by
  rintro ⟨a, b⟩ hp
  simp only [TimeOrdering.identifyTime, List.mem_eraseDups, List.mem_filterMap] at hp
  obtain ⟨⟨x, y⟩, -, hres⟩ := hp
  by_cases hAB : (if x = src then tgt else x) = (if y = src then tgt else y)
  · rw [if_pos (by simpa using hAB)] at hres
    exact absurd hres (by simp)
  · rw [if_neg (by simpa using hAB)] at hres
    simp only [Option.some.injEq, Prod.mk.injEq] at hres
    obtain ⟨rfl, rfl⟩ := hres
    simpa using hAB

/-- `addFuture` preserves irreflexivity exactly when the two times differ. -/
theorem irreflOrd_addFuture {ord : TimeOrdering} (h : IrreflOrd ord) {t t' : TimeIndex}
    (hne : t ≠ t') : IrreflOrd (ord.addFuture t t') := by
  rintro ⟨a, b⟩ hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with hp | hp
  · simp only [Prod.mk.injEq] at hp; obtain ⟨rfl, rfl⟩ := hp; exact hne
  · exact h _ hp

/-! ### `hnsl` is NECESSARY, not merely convenient.

`TimeOrdering.identifyTime` drops **every** constraint that collapses, including a pre-existing
self-loop `(a, a)` with `a ∉ {src, tgt}` — its two components rename to the same index. So a
witness reachable only around a self-loop is destroyed by arm 3. -/

/-- A self-loop is lost, and with it the reachability that carried the witness. -/
example : (5 : TimeIndex) ∈ (TimeOrdering.mk [(5, 5)]).futureOf 5 := by decide

example : (5 : TimeIndex) ∉ ((TimeOrdering.mk [(5, 5)]).identifyTime 1 0).futureOf 5 := by decide

/-- The incomparability side condition still holds in that configuration, so the failure is
attributable to the self-loop alone. -/
example : incomparableB (TimeOrdering.mk [(5, 5)]) (0, 1) = true := by decide

/-- **Counterexample to the unconditional form of claim (i).** With `hnsl` dropped,
`witnessPresent` for `allFutureNeg` is `true` before the identification and `false` after. -/
example :
    letI p : Formula := .atom ⟨"p", none⟩
    letI sf : SignedFormula := ⟨.neg, Formula.allFuture p, ⟨0, 5⟩⟩
    letI wit : SignedFormula := ⟨.neg, p, ⟨0, 5⟩⟩
    letI b : Branch := [sf, wit]
    letI ord : TimeOrdering := ⟨[(5, 5)]⟩
    witnessPresent .allFutureNeg sf b ord = true ∧
      witnessPresent .allFutureNeg ⟨.neg, Formula.allFuture p, ⟨0, rho 1 0 5⟩⟩
        (b.identifyTime 1 0) (ord.identifyTime 1 0) = false := by
  constructor <;> rfl

/-! ### Claim (ii) at engine level -/

private theorem pick_splitOrdered' {b : Branch} {bs : List (Branch × TimeOrdering)}
    {ord : TimeOrdering} {pick : Option (TableauRule × RuleResult × TimeOrdering)}
    (h : (match pick with
          | none => (ExpansionResult.saturated, ord)
          | some (_, result, newOrd) =>
            match result with
            | .linear fs => (ExpansionResult.extended (fs ++ b), newOrd)
            | .branching bss => (ExpansionResult.split (bss.map fun fs => fs ++ b), newOrd)
            | .branchingOrdered bs' => (ExpansionResult.splitOrdered bs', newOrd)
            | .persistent fs => (ExpansionResult.extended (fs ++ b), newOrd)
            | .notApplicable => (ExpansionResult.saturated, newOrd)).1
         = ExpansionResult.splitOrdered bs) :
    ∃ r o, pick = some (r, RuleResult.branchingOrdered bs, o) := by
  rcases pick with _ | ⟨r, res, o⟩
  · simp at h
  · cases res with
    | notApplicable => simp at h
    | linear fs => simp at h
    | branching bss => simp at h
    | persistent fs => simp at h
    | branchingOrdered bs' => exact ⟨r, o, by simpa using h⟩

-- `linter.unusedTactic` fires on the `exact RuleResult.noConfusion h` inside the second
-- `first` alternative below and calls it dead. It is NOT dead: it is the alternative's
-- *failure* mechanism. In the goals where `simp only [] at h` makes progress but does not
-- close the goal, that `exact` is what makes the whole alternative fail so `first` falls
-- through to `simp_all`, which discharges them from the false rule equation in context.
-- Deleting the `exact` was tried and leaves 12 goals unsolved (`impPos`, `impNeg`, `boxPos`,
-- `boxNeg`, `boxTemporal`, `allFuturePos`, `allFutureNeg`, `allPastPos`, `allPastNeg`,
-- `denseIndicatorClosure`, `densityRule`, `z1Rule`).
set_option linter.unusedTactic false in
set_option maxHeartbeats 4000000 in
/-- `timeLinearity` is the ONLY rule that can produce an ordered split. -/
theorem applyRule_branchingOrdered_rule (rule : TableauRule) (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) (bs : List (Branch × TimeOrdering))
    (h : (applyRule rule sf b ord).1 = RuleResult.branchingOrdered bs) : rule = .timeLinearity := by
  cases sf with
  | mk sign formula label =>
    cases rule
    case timeLinearity => rfl
    all_goals (exfalso; revert h; cases sign <;> simp only [applyRule] <;> intro h <;>
      (repeat' split at h) <;>
      first
        | exact RuleResult.noConfusion h
        | (simp only [] at h; exact RuleResult.noConfusion h)
        | simp_all)

/-- **Engine-level shape of an ordered split.** Whichever of the three pick stages produced it,
an ordered split is `timeLinearity`'s three arms on the very branch and ordering it was called
with. -/
theorem expandOnceUnblocked_splitOrdered_shape {b : Branch} {bs : List (Branch × TimeOrdering)}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∃ t₁ t₂, firstIncomparablePair b ord = some (t₁, t₂) ∧
      bs = [ (b, ord.addFuture t₁ t₂), (b, ord.addFuture t₂ t₁),
             (b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁) ] := by
  unfold expandOnceUnblocked at h
  obtain ⟨r, o, hpick⟩ := pick_splitOrdered' h
  have key : ∃ sf : SignedFormula, (applyRule r sf b ord).1 = RuleResult.branchingOrdered bs := by
    split at hpick
    · exact ⟨_, findApplicableRule_applyRule_eq hpick⟩
    · split at hpick
      · exact ⟨_, findApplicableSerialRule_applyRule_eq hpick⟩
      · split at hpick
        · exact ⟨_, findApplicableLinearityRule_applyRule_eq hpick⟩
        · exact absurd hpick (by simp)
  obtain ⟨sf, hsf⟩ := key
  cases applyRule_branchingOrdered_rule r sf b ord bs hsf
  exact applyRule_timeLinearity_arms_trigger sf b ord bs hsf

/-- **CLAIM (ii), engine level, `.splitOrdered` case.** No formula is deleted by an ordered
split: arms 1-2 keep the branch literally, arm 3 keeps every formula renamed. -/
theorem expandOnceUnblocked_splitOrdered_no_deletion
    {b : Branch} {bs : List (Branch × TimeOrdering)} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∃ t₁ t₂, ∀ p ∈ bs, ∀ x ∈ b,
      x ∈ p.1 ∨ rhoSF t₂ t₁ x ∈ p.1 := by
  obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape h
  refine ⟨t₁, t₂, ?_⟩
  intro p hp x hx
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact Or.inl hx
  · exact Or.inl hx
  · exact Or.inr (mem_identifyTime b t₂ t₁ x hx)

/-- **The full arm-3 preservation package**, in the form the mint bound consumes: the witness
survives and the source formula survives, both under the same renaming. -/
theorem arm3_preserves_witness {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂))
    (hnsl : IrreflOrd ord)
    (rule : TableauRule) (sf : SignedFormula)
    (h : witnessPresent rule sf b ord = true) :
    witnessPresent rule (rhoSF t₂ t₁ sf) (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁)
      = true := by
  cases sf with
  | mk s φ l =>
    cases l with
    | mk w tm =>
      exact witnessPresent_identifyTime rule b ord t₁ t₂ s φ w tm
        (incomparableB_of_firstIncomparablePair htrig) hnsl h

#print axioms witnessPresent_identifyTime
#print axioms arm3_preserves_witness
#print axioms expandOnceUnblocked_splitOrdered_shape
#print axioms expandOnceUnblocked_splitOrdered_no_deletion
#print axioms futureOf_transport
#print axioms pastOf_transport
#print axioms mem_identifyTime
#print axioms identifyTime_no_collapse
#print axioms irreflOrd_identifyTime
#print axioms irreflOrd_addFuture

end Scratch428
