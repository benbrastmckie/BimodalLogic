/-
SCRATCH — blocker research for the Phase 4 repair. NOT part of the library build.

Machine-checks the proposed `OrdTimesKnown` strengthening before the plan is revised around it.
Four checks:
  1. arm-3 preservation
  2. implies the `≤ maxTime` form density consumes
  3. the arm-3 counterexample dies under it
  4. preserved at the mint sites / addFuture / addPast (the check nobody had run)
-/
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace Scratch428Repair

open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- **The proposed strengthening**: every ordering time is a KNOWN BRANCH TIME. -/
def OrdTimesKnown (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes

/-! ## Basic `knownTimes` facts -/

/-- A branch formula's time is a known time. -/
theorem mem_knownTimes_of_mem {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.time ∈ b.knownTimes := by
  simp only [Branch.knownTimes, List.mem_eraseDups, List.mem_map]
  exact ⟨sf, h, rfl⟩

/-- Conversely, a known time is carried by some branch formula. -/
theorem exists_mem_of_mem_knownTimes {b : Branch} {t : TimeIndex} (h : t ∈ b.knownTimes) :
    ∃ sf ∈ b, sf.label.time = t := by
  simp only [Branch.knownTimes, List.mem_eraseDups, List.mem_map] at h
  obtain ⟨sf, hsf, hEq⟩ := h
  exact ⟨sf, hsf, hEq⟩

/-! ## CHECK 2 — `OrdTimesKnown` implies the `≤ maxTime` form

This is what makes the change a *strengthening* rather than the forbidden weakening. -/

/-- A known time is at or below `maxTime`. -/
theorem le_maxTime_of_mem_knownTimes {b : Branch} {t : TimeIndex} (h : t ∈ b.knownTimes) :
    t ≤ b.maxTime := by
  obtain ⟨sf, hsf, rfl⟩ := exists_mem_of_mem_knownTimes h
  exact le_maxTime hsf

/-- **CHECK 2.** The strong invariant implies the weak one, so every Phase 3 consumer keeps
working unchanged. -/
theorem ordTimesLeMaxTime_of_ordTimesKnown {b : Branch} {ord : TimeOrdering}
    (h : OrdTimesKnown b ord) : OrdTimesLeMaxTime b ord := fun p hp =>
  ⟨le_maxTime_of_mem_knownTimes (h p hp).1, le_maxTime_of_mem_knownTimes (h p hp).2⟩

/-! ## CHECK 3 — the counterexample dies under the new invariant -/

/-- **CHECK 3.** The exact configuration that refutes `OrdTimesLeMaxTime` preservation fails
`OrdTimesKnown` at the input, so it is not a counterexample to the strengthened form. -/
theorem counterexample_dies :
    letI p : Formula := .atom ⟨"p", none⟩
    letI q : Formula := .atom ⟨"q", none⟩
    letI b : Branch := [⟨.pos, p, ⟨0, 0⟩⟩, ⟨.pos, q, ⟨0, 5⟩⟩]
    letI ord : TimeOrdering := ⟨[(3, 4)]⟩
    ¬ OrdTimesKnown b ord := by
  unfold OrdTimesKnown; decide

/-! ## CHECK 1 — arm-3 preservation

The crux. `Branch.identifyTime` relabels by `rho src tgt`; `TimeOrdering.identifyTime` relabels
its constraint components by the same function. So the two move together. -/

/-- The branch half of the renaming acts on known times exactly as `rho` does. -/
theorem mem_knownTimes_identifyTime {b : Branch} {src tgt t : TimeIndex}
    (h : t ∈ b.knownTimes) : rho src tgt t ∈ (b.identifyTime src tgt).knownTimes := by
  obtain ⟨sf, hsf, rfl⟩ := exists_mem_of_mem_knownTimes h
  refine mem_knownTimes_of_mem (sf := rhoSF src tgt sf) ?_
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map]
  refine ⟨sf, hsf, ?_⟩
  by_cases hc : sf.label.time = src
  · simp [rhoSF, rho, hc]
  · simp [rhoSF, rho, hc]

/-- **CHECK 1.** `OrdTimesKnown` IS preserved by the ordered split's identification arm.

Note it needs NO trigger hypotheses at all — not `firstIncomparablePair`, not `IrreflOrd`. It is
a pure structural fact about the two `identifyTime`s using the same renaming, which is strictly
better than the weak form (which is false here even WITH both hypotheses). -/
theorem ordTimesKnown_identifyTime {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : OrdTimesKnown b ord) :
    OrdTimesKnown (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁) := by
  rintro ⟨a, c⟩ hp
  simp only [TimeOrdering.identifyTime, List.mem_eraseDups, List.mem_filterMap] at hp
  obtain ⟨⟨x, y⟩, hxy, hres⟩ := hp
  by_cases hAB : (if x == t₂ then t₁ else x) = (if y == t₂ then t₁ else y)
  · rw [if_pos (by simpa using hAB)] at hres
    exact absurd hres (by simp)
  · rw [if_neg (by simpa using hAB)] at hres
    simp only [Option.some.injEq, Prod.mk.injEq] at hres
    obtain ⟨rfl, rfl⟩ := hres
    obtain ⟨hx, hy⟩ := h (x, y) hxy
    constructor
    · have := mem_knownTimes_identifyTime (src := t₂) (tgt := t₁) hx
      simpa only [rho, beq_iff_eq] using this
    · have := mem_knownTimes_identifyTime (src := t₂) (tgt := t₁) hy
      simpa only [rho, beq_iff_eq] using this

/-! ## CHECK 4 — preservation at the OTHER sites

The check nobody had run. It is no use fixing arm 3 if the stronger invariant breaks at a mint
site where the weaker one held. The mint sites state their invariant against the POST-step branch
`g :: rest ++ b`, where `g` is the witness sitting at `b.nextTime`. -/

/-- Known times survive branch growth. -/
theorem knownTimes_mono {b nb : Branch} {t : TimeIndex} (hsub : ∀ x ∈ b, x ∈ nb)
    (h : t ∈ b.knownTimes) : t ∈ nb.knownTimes := by
  obtain ⟨sf, hsf, rfl⟩ := exists_mem_of_mem_knownTimes h
  exact mem_knownTimes_of_mem (hsub sf hsf)

/-- The strong invariant survives branch growth on its own, when the ordering does not change.
The `OrdTimesKnown` analogue of `ordTimes_mono`. -/
theorem ordTimesKnown_mono {b nb : Branch} {ord : TimeOrdering}
    (haux : OrdTimesKnown b ord) (hsub : ∀ x ∈ b, x ∈ nb) : OrdTimesKnown nb ord :=
  fun p hp => ⟨knownTimes_mono hsub (haux p hp).1, knownTimes_mono hsub (haux p hp).2⟩

/-- A mint step's new branch KNOWS the fresh time, because the witness sits there.
The `OrdTimesKnown` analogue of `nextTime_le_maxTime_cons`. -/
theorem nextTime_mem_knownTimes_cons {b : Branch} {g : SignedFormula}
    {rest : List SignedFormula} (hg : g.label.time = b.nextTime) :
    b.nextTime ∈ Branch.knownTimes (g :: rest ++ b) :=
  hg ▸ mem_knownTimes_of_mem (List.mem_append_left b List.mem_cons_self)

/-- Branch growth by prepending any list. Stated for a general `fs` rather than the `g :: rest`
shape, so it also covers the `.linear []` / `.persistent []` arms where the branch is unchanged. -/
private theorem sub_append {b : Branch} {fs : List SignedFormula} :
    ∀ x ∈ b, x ∈ (fs ++ b) := fun _ hx => List.mem_append_right _ hx

/-- **CHECK 4a.** Single-edge `addFuture` mint step preserves the strong invariant. -/
theorem ordTimesKnown_addFuture_cons {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesKnown b ord) (ht : t ∈ b.knownTimes)
    (hg : g.label.time = b.nextTime) :
    OrdTimesKnown (g :: rest ++ b) (ord.addFuture t b.nextTime) := by
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | hp
  · exact ⟨knownTimes_mono sub_append ht, nextTime_mem_knownTimes_cons hg⟩
  · exact ordTimesKnown_mono haux sub_append p hp

/-- **CHECK 4b.** Single-edge `addPast` mint step preserves the strong invariant. -/
theorem ordTimesKnown_addPast_cons {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesKnown b ord) (ht : t ∈ b.knownTimes)
    (hg : g.label.time = b.nextTime) :
    OrdTimesKnown (g :: rest ++ b) (ord.addPast t b.nextTime) := by
  intro p hp
  simp only [TimeOrdering.addPast, List.mem_cons] at hp
  rcases hp with rfl | hp
  · exact ⟨nextTime_mem_knownTimes_cons hg, knownTimes_mono sub_append ht⟩
  · exact ordTimesKnown_mono haux sub_append p hp

/-- **CHECK 4c.** `densityRule`'s two-edge mint step preserves the strong invariant.
The extra obligation is `t' ∈ b.knownTimes`, supplied by the invariant applied to the constraint
that put `t'` in the reach. -/
theorem ordTimesKnown_density_cons {b : Branch} {ord : TimeOrdering} {t t' : TimeIndex}
    {P : TimeIndex → Bool} {tail : List TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesKnown b ord) (ht : t ∈ b.knownTimes)
    (hg : g.label.time = b.nextTime)
    (heq : (ord.futureOf t).filter P = t' :: tail) :
    OrdTimesKnown (g :: rest ++ b) ((ord.addFuture t b.nextTime).addFuture b.nextTime t') := by
  have hmem : t' ∈ ord.futureOf t :=
    List.mem_of_mem_filter (by rw [heq]; exact List.mem_cons_self)
  obtain ⟨x, hx⟩ := exists_constraint_to_of_mem_futureOf ord t t' hmem
  have ht' : t' ∈ b.knownTimes := (haux (x, t') hx).2
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | rfl | hp
  · exact ⟨nextTime_mem_knownTimes_cons hg, knownTimes_mono sub_append ht'⟩
  · exact ⟨knownTimes_mono sub_append ht, nextTime_mem_knownTimes_cons hg⟩
  · exact ordTimesKnown_mono haux sub_append p hp

set_option maxHeartbeats 4000000 in
/-- **CHECK 4, full engine statement.** `applyRule` preserves `OrdTimesKnown` at the
non-branching result shapes — the `OrdTimesKnown` analogue of `applyRule_ordTimes_nonbranching`,
proved by the same tactic skeleton with the four `_cons` lemmas swapped for their strong forms.

This is the load-bearing check: the strong invariant survives every one of the nine mint sites,
so nothing that held under the weak form is lost. -/
theorem applyRule_ordTimesKnown_nonbranching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesKnown b ord) :
    ∀ nb ∈ nonBranchingResultBranch b (applyRule rule sf b ord).1,
      OrdTimesKnown nb (applyRule rule sf b ord).2 := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             simp only [nonBranchingResultBranch, Option.mem_def, Option.some.injEq] at hnb
             first
               | (subst hnb
                  first
                    | exact ordTimesKnown_mono haux sub_append
                    | exact ordTimesKnown_addFuture_cons haux ht rfl
                    | exact ordTimesKnown_addPast_cons haux ht rfl
                    | exact ordTimesKnown_density_cons haux ht rfl (by assumption))
               | exact absurd hnb (by simp)))

/-! ## CHECK 4d — the ordered split's OTHER two arms

Arms 1 and 2 of `.splitOrdered` keep the branch literally and add one ordering edge between the
incomparable pair. The strong invariant needs `t₁, t₂ ∈ b.knownTimes`, and the trigger supplies
exactly that — `firstIncomparablePair` scans `b.knownTimes`, so `firstIncomparablePair_spec`
hands it over directly. This is the last engine-level site, and it is free. -/

/-- **CHECK 4d.** Both non-identification arms of the ordered split preserve the strong
invariant, with the trigger supplying the two membership facts. -/
theorem ordTimesKnown_splitOrdered_arms12 {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (haux : OrdTimesKnown b ord) :
    OrdTimesKnown b (ord.addFuture t₁ t₂) ∧ OrdTimesKnown b (ord.addFuture t₂ t₁) := by
  obtain ⟨h1, h2, -, -, -⟩ := firstIncomparablePair_spec htrig
  constructor <;> (intro p hp
                   simp only [TimeOrdering.addFuture, List.mem_cons] at hp
                   rcases hp with rfl | hp)
  · exact ⟨h1, h2⟩
  · exact haux p hp
  · exact ⟨h2, h1⟩
  · exact haux p hp

/-! ## Shape (b) viability: does the strong form re-derive Phase 3's consumers unchanged? -/

/-- `applyRule_irreflOrd` — the headline Phase 3 result — is reachable from the strong invariant
with NO change to its proof, by composing with CHECK 2. This is the concrete evidence that
shape (b) touches no completed proof. -/
theorem applyRule_irreflOrd_from_known {rule : TableauRule} {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} (hsf : sf ∈ b) (hord : IrreflOrd ord)
    (haux : OrdTimesKnown b ord) : IrreflOrd (applyRule rule sf b ord).2 :=
  applyRule_irreflOrd hsf hord (ordTimesLeMaxTime_of_ordTimesKnown haux)

/-- Likewise the density second-edge fact. -/
theorem ne_nextTime_from_known {b : Branch} {ord : TimeOrdering} {s t : TimeIndex}
    (haux : OrdTimesKnown b ord) (h : t ∈ ord.futureOf s) : b.nextTime ≠ t :=
  ne_nextTime_of_mem_futureOf (ordTimesLeMaxTime_of_ordTimesKnown haux) h

#print axioms ordTimesLeMaxTime_of_ordTimesKnown
#print axioms counterexample_dies
#print axioms ordTimesKnown_identifyTime
#print axioms ordTimesKnown_addFuture_cons
#print axioms ordTimesKnown_addPast_cons
#print axioms ordTimesKnown_density_cons
#print axioms applyRule_ordTimesKnown_nonbranching
#print axioms ordTimesKnown_splitOrdered_arms12
#print axioms applyRule_irreflOrd_from_known

end Scratch428Repair
