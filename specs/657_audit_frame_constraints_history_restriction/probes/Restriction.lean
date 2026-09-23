import FormalSystem.Semantics.Extension

/-!
# Probe: the identification "partial histories **are** the restrictions of possible worlds"

The anchor case of the audit, settled in both directions and at the level of the extension
order, not merely pointwise.

## The two directions

* **Easy direction** (`restrict`): every restriction of a possible world to a nonempty set of
  times is a partial history. This costs **nothing** — no frame constraint of any kind, not even
  the ambient `[F.IsRegular]` instance, and no proof obligation beyond re-using the world
  history's own `respects_task`. The claim that it "really is easy" is confirmed: `restrict`'s
  four structure fields are `X`, the hypothesis, the world history's states, and its
  `respects_task`, in that order, with no glue.
* **Hard direction** (`isRestriction`): every partial history *is* such a restriction. That is
  `thm:extension`, and it is where all four constraints (in fact *Seriality*, *Limit* and
  either *Saturation* or *Completion*) are spent.

## The order

`restrict` is monotone in the time set (`restrict_mono`), the restriction of a world history to
the whole of `D` is that world history back (`restrict_univ`), and — the load-bearing order fact —
the extension order on partial histories is **realized** by restriction: whenever `τ ≤ σ`, a
*single* possible world restricts onto both (`exists_worldHistory_restricting_pair`). So the
surjection is not merely pointwise onto; it carries the order.

## The presentation question

`IsRestriction` below is the alternative *definition* of a partial history the audit asks about
("define partial histories as restrictions and derive the current definition"). `isRestriction_iff`
shows the two definitions are extensionally the same class **in a regular frame**, and
`restrict_isPartialHistory` shows one inclusion is free. The asymmetry the probe exhibits — one
inclusion free, the other the whole of `thm:extension` — is the argument recorded in the report
for keeping the coherence definition primitive.
-/

namespace FormalSystem.Semantics

open TaskFrame

namespace PartialHistory

variable {F : TaskFrame}

/-! ## The restriction map -/

/--
The restriction of a possible world `h` to a nonempty set `X` of times.

**No frame constraint is used.** This is the easy direction of the identification, and it is as
easy as it looks: the coherence condition of the restriction is the world history's own
`respects_task`, unchanged.
-/
def restrict (h : WorldHistory F) (X : F.Duration → Prop) (hX : ∃ t, X t) :
    PartialHistory F where
  domain := X
  nonempty_domain := hX
  states := fun t _ => h.state t
  respects_task := fun s t _ _ => h.respects_task s t

@[simp]
theorem restrict_domain (h : WorldHistory F) (X : F.Duration → Prop) (hX : ∃ t, X t)
    (t : F.Duration) : (restrict h X hX).domain t ↔ X t := Iff.rfl

@[simp]
theorem restrict_states (h : WorldHistory F) (X : F.Duration → Prop) (hX : ∃ t, X t)
    (t : F.Duration) (ht : (restrict h X hX).domain t) :
    (restrict h X hX).states t ht = h.state t := rfl

/-- **The easy direction, stated as a claim rather than a construction**: the restriction of a
possible world to any nonempty set of times is a partial history. Constraint-free. -/
theorem restrict_isPartialHistory (h : WorldHistory F) (X : F.Duration → Prop) (hX : ∃ t, X t) :
    ∃ τ : PartialHistory F, τ.domain = X ∧
      ∀ (t : F.Duration) (ht : τ.domain t), τ.states t ht = h.state t :=
  ⟨restrict h X hX, rfl, fun _ _ => rfl⟩

/-- A possible world extends each of its own restrictions. -/
theorem extends_restrict (h : WorldHistory F) (X : F.Duration → Prop) (hX : ∃ t, X t) :
    Extends h.val (restrict h X hX) where
  subset := fun t _ => h.property t
  agree := fun _ _ => rfl

/-- Restriction is monotone in the time set: a larger time set gives a larger partial history in
the extension order. -/
theorem restrict_mono (h : WorldHistory F) {X Y : F.Duration → Prop}
    (hX : ∃ t, X t) (hY : ∃ t, Y t) (hXY : ∀ t, X t → Y t) :
    restrict h X hX ≤ restrict h Y hY :=
  le_def.mpr ⟨hXY, fun _ _ => rfl⟩

/-- Restricting a possible world to the whole of `D` returns it. -/
theorem restrict_univ (h : WorldHistory F) :
    restrict h (fun _ => True) ⟨0, trivial⟩ = h.val := by
  obtain ⟨⟨d, n, s, r⟩, htot⟩ := h
  obtain rfl : (fun _ : F.Duration => True) = d :=
    funext fun t => propext ⟨fun _ => htot t, fun _ => trivial⟩
  rfl

/-! ## Being a restriction -/

/--
The alternative definition of a partial history: `τ` **is** the restriction of some possible
world to `dom τ`.

Stated as `Extends h.val τ`, which is exactly `τ = restrict h τ.domain τ.nonempty_domain`
(`eq_restrict_of_extends` below).
-/
def IsRestriction (τ : PartialHistory F) : Prop := ∃ h : WorldHistory F, Extends h.val τ

/-- A partial history extended by a possible world **is** that world's restriction to its own
domain, on the nose. -/
theorem eq_restrict_of_extends {τ : PartialHistory F} {h : WorldHistory F}
    (hext : Extends h.val τ) : restrict h τ.domain τ.nonempty_domain = τ := by
  obtain ⟨d, n, s, r⟩ := τ
  obtain rfl : (fun (t : F.Duration) (_ : d t) => h.state t) = s :=
    funext fun t => funext fun ht => hext.agree t ht
  rfl

/-- **The identification, hard direction.** In a regular frame every partial history is the
restriction of a possible world. This is exactly `thm:extension`, and it is where *Seriality*,
*Limit* and *Saturation* (or, per the `Completion` probe, *Completion* in place of *Saturation*)
are spent. -/
theorem isRestriction_of_isRegular [F.IsRegular] (τ : PartialHistory F) : IsRestriction τ :=
  extension F τ

/-- The surjection, spelled out: every partial history is literally `restrict h` for some
possible world `h`. -/
theorem exists_restrict_eq [F.IsRegular] (τ : PartialHistory F) :
    ∃ h : WorldHistory F, restrict h τ.domain τ.nonempty_domain = τ := by
  obtain ⟨h, hext⟩ := extension F τ
  exact ⟨h, eq_restrict_of_extends hext⟩

/-! ## The order-level identification -/

/--
**The surjection carries the order.** Whenever `τ ≤ σ` in the extension order, a *single*
possible world restricts onto both. So the identification is not merely a pointwise surjection
onto the set of partial histories: every instance of the extension relation is realized inside
one possible world.
-/
theorem exists_worldHistory_restricting_pair [F.IsRegular] {τ σ : PartialHistory F}
    (hle : τ ≤ σ) :
    ∃ h : WorldHistory F, restrict h τ.domain τ.nonempty_domain = τ ∧
      restrict h σ.domain σ.nonempty_domain = σ := by
  obtain ⟨h, hext⟩ := extension F σ
  refine ⟨h, eq_restrict_of_extends ?_, eq_restrict_of_extends hext⟩
  exact le_def.mp (le_trans hle (le_def.mpr hext))

/--
The converse half of the order statement, and it is free: two restrictions of the *same* possible
world stand in the extension order exactly as their time sets stand in inclusion. Together with
`exists_worldHistory_restricting_pair` this makes restriction an order-surjection.
-/
theorem restrict_le_restrict_iff (h : WorldHistory F) {X Y : F.Duration → Prop}
    (hX : ∃ t, X t) (hY : ∃ t, Y t) :
    restrict h X hX ≤ restrict h Y hY ↔ ∀ t, X t → Y t := by
  constructor
  · intro hle t ht
    exact (le_def.mp hle).subset t ht
  · intro hXY
    exact restrict_mono h hX hY hXY

end PartialHistory

end FormalSystem.Semantics

section AxiomCheck
open FormalSystem.Semantics.PartialHistory
#print axioms restrict
#print axioms restrict_isPartialHistory
#print axioms eq_restrict_of_extends
#print axioms exists_restrict_eq
#print axioms exists_worldHistory_restricting_pair
#print axioms restrict_le_restrict_iff
end AxiomCheck
