import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- Exclusion 3: `.someFutureNeg` is view-gated. -/
theorem probe_someFutureNeg {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hfree : untlSnceFree sf.formula = true) :
    (applyRule .someFutureNeg sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  simp only at hfree
  have h := asSomeFuture_eq_none_of_untlSnceFree hfree
  cases sign <;> simp [applyRule, h, RuleResult.emitted]

/-- Exclusion 4: `.somePastNeg` is view-gated. -/
theorem probe_somePastNeg {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hfree : untlSnceFree sf.formula = true) :
    (applyRule .somePastNeg sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  simp only at hfree
  have h := asSomePast_eq_none_of_untlSnceFree hfree
  cases sign <;> simp [applyRule, h, RuleResult.emitted]

/-- Exclusion 1: `.allFuturePos` matches the raw `allFuture` shape. -/
theorem probe_allFuturePos {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hfree : untlSnceFree sf.formula = true) :
    (applyRule .allFuturePos sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  simp only at hfree
  cases sign
  case pos =>
    cases φ with
    | imp a c => cases a <;> simp_all [applyRule, untlSnceFree, RuleResult.emitted]
    | _ => simp [applyRule, RuleResult.emitted]
  case neg => simp [applyRule, RuleResult.emitted]

/-- Exclusion 2: `.allPastPos` matches the raw `allPast` shape. -/
theorem probe_allPastPos {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hfree : untlSnceFree sf.formula = true) :
    (applyRule .allPastPos sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  simp only at hfree
  cases sign
  case pos =>
    cases φ with
    | imp a c => cases a <;> simp_all [applyRule, untlSnceFree, RuleResult.emitted]
    | _ => simp [applyRule, RuleResult.emitted]
  case neg => simp [applyRule, RuleResult.emitted]

/-- Helper: an `untl`-headed formula is not carried by an `untl`/`snce`-free branch. -/
theorem probe_untl_not_contains {b : Branch}
    (hbfree : ∀ x ∈ b, untlSnceFree x.formula = true)
    {s : Sign} {x y : Formula} {l : Label} :
    b.contains ⟨s, Formula.untl x y, l⟩ = false := by
  rcases hc : b.contains (⟨s, Formula.untl x y, l⟩ : SignedFormula) with _ | _
  · rfl
  · have hm : (⟨s, Formula.untl x y, l⟩ : SignedFormula) ∈ b :=
      mem_of_branch_contains hc
    have := hbfree _ hm
    simp [untlSnceFree] at this

/-- Exclusion 5: `.orderTrichotomy` is branch-gated. -/
theorem probe_orderTrichotomy {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hbfree : ∀ x ∈ b, untlSnceFree x.formula = true) :
    (applyRule .orderTrichotomy sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  cases sign
  case neg => simp [applyRule, RuleResult.emitted]
  case pos =>
    simp only [applyRule]
    repeat' split
    all_goals (try simp only [RuleResult.emitted])
    rename_i heq
    have hfires := List.find?_some heq
    simp only [Formula.someFuture, SignedFormula.neg, List.any_cons, List.any_nil,
      Bool.and_eq_true, Bool.or_eq_true, probe_untl_not_contains hbfree] at hfires
    simp at hfires

/-- Bridge: an arm that emits nothing satisfies the sweep's conclusion vacuously. -/
theorem probe_nil_elim {b : Branch} {r : RuleResult × TimeOrdering}
    (h : r.1.emitted = []) : ∀ g ∈ r.1.emitted, g.label.time ∈ b.knownTimes := by
  rw [h]; simp

set_option maxHeartbeats 4000000 in
/-- Phase 3: the restricted sweep. -/
theorem probe_restricted {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (hbfree : ∀ x ∈ b, untlSnceFree x.formula = true)
    (hmint : ruleMintsFreshTime rule = false) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.time ∈ b.knownTimes := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
  have hfree : untlSnceFree sf.formula = true := hbfree sf hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;> first
      | exact Bool.noConfusion hmint
      | exact probe_nil_elim (probe_allFuturePos hfree)
      | exact probe_nil_elim (probe_allPastPos hfree)
      | exact probe_nil_elim (probe_someFutureNeg hfree)
      | exact probe_nil_elim (probe_somePastNeg hfree)
      | exact probe_nil_elim (probe_orderTrichotomy hbfree)
      | (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
          (try contradiction) <;>
          intro g hg <;>
          repeat' first
            | exact ht
            | exact mem_knownTimes_of_mem hg
            | (refine mem_identifyTime_time_at_trigger (ord := ord) ?_ hg
               assumption)
            | (refine mem_identifyTime_time_at_trigger_oriented (ord := ord) ?_ hg
               assumption)
            | (refine mem_filterMap_const_time_mem (t := label.time) ht ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (refine mem_filterMap_time ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
                 List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil,
                 List.append_nil, List.mem_cons, List.mem_append, List.not_mem_nil,
                 or_false, List.mem_filter] at hg)
            | (subst hg; exact ht)
            | (rcases hg with hg | hg))

end FormalSystem.Metalogic.Decidability
