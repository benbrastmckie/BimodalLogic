/-
SCRATCH — Phase 9's run-level `WorldWitness` discharge (R4). NOT part of the library build.
-/
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace Scratch428World

open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- Identification relabels times only, so it never introduces a world. -/
theorem mem_identifyTime_world {b : Branch} {src tgt : TimeIndex} {g : SignedFormula}
    (h : g ∈ b.identifyTime src tgt) : g.label.world ∈ b.worldFinset := by
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map] at h
  obtain ⟨x, hx, rfl⟩ := h
  by_cases hc : x.label.time = src <;> simp only [hc, if_true, if_false, beq_iff_eq] <;>
    exact Branch.mem_worldFinset hx

/-- World-level analogue of `mem_filterMap_sub`. -/
theorem mem_filterMap_world {b : Branch} {P : SignedFormula → Bool}
    {F : SignedFormula → Option SignedFormula} {g : SignedFormula}
    (hF : ∀ x y, F x = some y → y.label.world = x.label.world)
    (h : g ∈ (b.filter P).filterMap F) : g.label.world ∈ b.worldFinset := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  rw [hF x g hxg]
  exact Branch.mem_worldFinset (List.mem_of_mem_filter hx)

set_option maxHeartbeats 4000000 in
theorem applyRule_emitted_world_mem {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (h1 : rule ≠ .boxNeg) (h2 : rule ≠ .diamondPos) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.world ∈ b.worldFinset := by
  have hw : sf.label.world ∈ b.worldFinset := Branch.mem_worldFinset hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;> first
      | exact absurd rfl h1
      | exact absurd rfl h2
      | (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
          (try contradiction) <;>
          intro g hg <;>
          repeat' first
            | exact hw
            | exact Branch.mem_worldFinset hg
            | exact mem_identifyTime_world hg
            | (rw [(mem_boxDiamondPersistence_label hg).1]; exact hw)
            | (obtain ⟨x, hx, rfl⟩ := mem_filterMap_guarded hg
               first
                 | exact hw
                 | exact List.mem_toFinset.mpr hx)
            | (refine mem_filterMap_world ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
                 Branch.allFuturePosFormulas, Branch.allPastPosFormulas,
                 Branch.someFutureNegFormulas, Branch.somePastNegFormulas,
                 Branch.untlNegFormulas, Branch.snceNegFormulas,
                 List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil,
                 List.append_nil, List.mem_cons, List.mem_append, List.not_mem_nil,
                 or_false, List.mem_filter] at hg)
            | (subst hg; exact hw)
            | (rcases hg with hg | hg)
            | (obtain ⟨hg, -⟩ := hg))

/-! ## The two world-minting rules -/

theorem mem_filterMap_const_world {l : List SignedFormula}
    {F : SignedFormula → Option SignedFormula} {w : WorldIndex} {g : SignedFormula}
    (hF : ∀ x y, F x = some y → y.label.world = w) (h : g ∈ l.filterMap F) :
    g.label.world = w := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  exact hF x g hxg

set_option maxHeartbeats 1000000 in
theorem applyRule_boxNeg_emitted_world {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} :
    ∀ g ∈ (applyRule .boxNeg sf b ord).1.emitted, g.label.world = b.nextWorld := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;> (try contradiction) <;>
      intro g hg <;>
      repeat' first
        | rfl
        | (refine mem_filterMap_const_world ?_ hg
           clear hg
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | (subst hy; rfl)
             | (simp only [reduceCtorEq] at hy))
        | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
             List.mem_cons, List.mem_append, List.not_mem_nil, or_false] at hg)
        | (subst hg; rfl)
        | (rcases hg with hg | hg)

set_option maxHeartbeats 1000000 in
theorem applyRule_diamondPos_emitted_world {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} :
    ∀ g ∈ (applyRule .diamondPos sf b ord).1.emitted, g.label.world = b.nextWorld := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;> (try contradiction) <;>
      intro g hg <;>
      repeat' first
        | rfl
        | (refine mem_filterMap_const_world ?_ hg
           clear hg
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | (subst hy; rfl)
             | (simp only [reduceCtorEq] at hy))
        | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
             List.mem_cons, List.mem_append, List.not_mem_nil, or_false] at hg)
        | (subst hg; rfl)
        | (rcases hg with hg | hg)


/-! ## Shapes of the two minting rules -/

set_option maxHeartbeats 1000000 in
theorem applyRule_boxNeg_shape {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {g : SignedFormula} (hg : g ∈ (applyRule .boxNeg sf b ord).1.emitted) :
    ∃ ψ, sf.formula = Formula.box ψ ∧ sf.sign = Sign.neg := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] at hg <;> (repeat' split at hg) <;>
      first
        | contradiction
        | exact ⟨_, rfl, rfl⟩
        | (simp only [RuleResult.emitted, List.not_mem_nil] at hg)

set_option maxHeartbeats 1000000 in
theorem applyRule_diamondPos_shape {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {g : SignedFormula} (hg : g ∈ (applyRule .diamondPos sf b ord).1.emitted) :
    ∃ ψ, asDiamond? sf.formula = some ψ ∧ sf.sign = Sign.pos := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] at hg <;> (repeat' split at hg) <;>
      first
        | contradiction
        | exact ⟨_, by assumption, rfl⟩
        | (simp only [RuleResult.emitted, List.not_mem_nil] at hg)

theorem applyRule_boxNeg_witness {sf : SignedFormula} {ψ : Formula} {b : Branch}
    {ord : TimeOrdering} (hf : sf.formula = Formula.box ψ) (hs : sf.sign = Sign.neg) :
    SignedFormula.neg ψ { world := b.nextWorld, time := sf.label.time }
      ∈ (applyRule .boxNeg sf b ord).1.emitted := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hf; subst hs
    simp only [applyRule, RuleResult.emitted]
    exact List.mem_cons_self

theorem applyRule_diamondPos_witness {sf : SignedFormula} {ψ : Formula} {b : Branch}
    {ord : TimeOrdering} (hf : asDiamond? sf.formula = some ψ) (hs : sf.sign = Sign.pos) :
    SignedFormula.pos ψ { world := b.nextWorld, time := sf.label.time }
      ∈ (applyRule .diamondPos sf b ord).1.emitted := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hs
    rw [asDiamond?_eq_iff] at hf
    subst hf
    simp only [applyRule, RuleResult.emitted]
    exact List.mem_cons_self

/-! ## `WorldWitnessKnown` -/

/-- The strengthened fresh-world discipline. -/
def WorldWitnessKnown (C : Finset Formula) (S : Finset WorldIndex) (b : Branch) : Prop :=
  ∃ wit : WorldIndex → SignedFormula,
    (∀ w ∈ b.worldFinset, w ∉ S →
      wit w ∈ b ∧ (wit w).label.world = w ∧ (wit w).formula ∈ C) ∧
    (∀ w₁ ∈ b.worldFinset, w₁ ∉ S → ∀ w₂ ∈ b.worldFinset, w₂ ∉ S →
      witnessSig (wit w₁) = witnessSig (wit w₂) → w₁ = w₂)

theorem worldWitness_of_known {C : Finset Formula} {S : Finset WorldIndex} {b : Branch}
    (h : WorldWitnessKnown C S b) : WorldWitness C S b := by
  obtain ⟨wit, hwit, hinj⟩ := h
  refine ⟨wit, ?_, hinj⟩
  intro w hw hs
  obtain ⟨hmem, -, hC⟩ := hwit w hw hs
  exact ⟨hC, Branch.mem_timeFinset hmem⟩

theorem exists_mem_of_mem_worldFinset {b : Branch} {w : WorldIndex} (h : w ∈ b.worldFinset) :
    ∃ x ∈ b, x.label.world = w := by
  simp only [Branch.worldFinset, List.mem_toFinset, Branch.knownWorlds, List.mem_eraseDups,
    List.mem_map] at h
  obtain ⟨x, hx, hxw⟩ := h
  exact ⟨x, hx, hxw⟩

theorem nextWorld_not_mem_worldFinset (b : Branch) : b.nextWorld ∉ b.worldFinset := by
  intro h
  obtain ⟨x, hx, hxw⟩ := exists_mem_of_mem_worldFinset h
  exact not_mem_of_world_nextWorld hxw hx

theorem contains_of_mem {b : Branch} {x : SignedFormula} (h : x ∈ b) : b.contains x = true := by
  simp only [Branch.contains, List.any_eq_true]
  exact ⟨x, h, beq_self_eq_true x⟩

/-- A step that introduces no world keeps the discipline, with the same witness function. -/
theorem worldWitnessKnown_of_no_new_world {C : Finset Formula} {S : Finset WorldIndex}
    {b nb : Branch} (hww : WorldWitnessKnown C S b) (hsub : ∀ x ∈ b, x ∈ nb)
    (hworlds : ∀ x ∈ nb, x.label.world ∈ b.worldFinset) : WorldWitnessKnown C S nb := by
  obtain ⟨wit, hwit, hinj⟩ := hww
  have key : ∀ w ∈ nb.worldFinset, w ∈ b.worldFinset := by
    intro w hw
    obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
    exact hworlds x hx
  refine ⟨wit, ?_, ?_⟩
  · intro w hw hs
    obtain ⟨hm, hl, hc⟩ := hwit w (key w hw) hs
    exact ⟨hsub _ hm, hl, hc⟩
  · intro w₁ h1 hs1 w₂ h2 hs2 heq
    exact hinj w₁ (key w₁ h1) hs1 w₂ (key w₂ h2) hs2 heq

/-- A step that mints exactly one world keeps the discipline, provided the minted world's own
witness has a signature no branch formula carries — which is exactly what the engine's
`witnessPresent` guard supplies at a fresh-world rule. -/
theorem worldWitnessKnown_mint {C : Finset Formula} {S : Finset WorldIndex}
    {b nb : Branch} {w₀ : WorldIndex} {x₀ : SignedFormula}
    (hww : WorldWitnessKnown C S b) (hsub : ∀ x ∈ b, x ∈ nb)
    (hworlds : ∀ x ∈ nb, x.label.world ∈ b.worldFinset ∨ x.label.world = w₀)
    (hfresh : w₀ ∉ b.worldFinset)
    (hx₀ : x₀ ∈ nb) (hx₀w : x₀.label.world = w₀) (hx₀C : x₀.formula ∈ C)
    (hsig : ∀ y ∈ b, witnessSig y ≠ witnessSig x₀) : WorldWitnessKnown C S nb := by
  classical
  obtain ⟨wit, hwit, hinj⟩ := hww
  refine ⟨Function.update wit w₀ x₀, ?_, ?_⟩
  · intro w hw hs
    by_cases hw0 : w = w₀
    · subst hw0
      simpa [Function.update_self] using ⟨hx₀, hx₀w, hx₀C⟩
    · obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
      have hb : x.label.world ∈ b.worldFinset := (hworlds x hx).resolve_right hw0
      obtain ⟨hm, hl, hc⟩ := hwit _ hb hs
      simpa [Function.update_of_ne hw0] using ⟨hsub _ hm, hl, hc⟩
  · intro w₁ h1 hs1 w₂ h2 hs2 heq
    have hb : ∀ w ∈ nb.worldFinset, w ≠ w₀ → w ∈ b.worldFinset := by
      intro w hw hne
      obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
      exact (hworlds x hx).resolve_right hne
    by_cases e1 : w₁ = w₀ <;> by_cases e2 : w₂ = w₀
    · rw [e1, e2]
    · exfalso
      subst e1
      rw [Function.update_self, Function.update_of_ne e2] at heq
      exact hsig _ (hwit _ (hb _ h2 e2) hs2).1 heq.symm
    · exfalso
      subst e2
      rw [Function.update_self, Function.update_of_ne e1] at heq
      exact hsig _ (hwit _ (hb _ h1 e1) hs1).1 heq
    · rw [Function.update_of_ne e1, Function.update_of_ne e2] at heq
      exact hinj _ (hb _ h1 e1) hs1 _ (hb _ h2 e2) hs2 heq


/-! ## The guard argument and the step lemma -/

theorem applyRule_boxNeg_eq {sf : SignedFormula} {ψ : Formula} {b : Branch} {ord : TimeOrdering}
    (hf : sf.formula = Formula.box ψ) (hs : sf.sign = Sign.neg) :
    ∃ fs, (applyRule .boxNeg sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hf; subst hs
    exact ⟨_, rfl⟩

theorem applyRule_diamondPos_eq {sf : SignedFormula} {ψ : Formula} {b : Branch}
    {ord : TimeOrdering} (hf : asDiamond? sf.formula = some ψ) (hs : sf.sign = Sign.pos) :
    ∃ fs, (applyRule .diamondPos sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hs
    rw [asDiamond?_eq_iff] at hf
    subst hf
    exact ⟨_, rfl⟩

theorem mem_knownWorlds_of_mem {b : Branch} {x : SignedFormula} (h : x ∈ b) :
    x.label.world ∈ b.knownWorlds :=
  List.mem_eraseDups.mpr (List.mem_map_of_mem h)

theorem boxNeg_guard_sig {sf : SignedFormula} {ψ : Formula} {b : Branch} {ord : TimeOrdering}
    (hf : sf.formula = Formula.box ψ) (hs : sf.sign = Sign.neg)
    (hguard : witnessPresent .boxNeg sf b ord = false) :
    ∀ y ∈ b, witnessSig y
      ≠ witnessSig (SignedFormula.neg ψ { world := b.nextWorld, time := sf.label.time }) := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hf; subst hs
    simp only [witnessPresent] at hguard
    intro y hy heq
    have h1 : y.sign = Sign.neg := congrArg SignedFormula.sign heq
    have h2 : y.formula = ψ := congrArg SignedFormula.formula heq
    have h3 : y.label.time = label.time := congrArg (fun z => z.label.time) heq
    have hy' : y = SignedFormula.neg ψ { world := y.label.world, time := label.time } := by
      obtain ⟨ys, yf, yl⟩ := y
      obtain ⟨yw, yt⟩ := yl
      simp_all [SignedFormula.neg]
    have hcontains : b.contains
        (SignedFormula.neg ψ { world := y.label.world, time := label.time }) = true := by
      rw [← hy']; exact contains_of_mem hy
    have : (b.knownWorlds.any fun w =>
        b.contains (SignedFormula.neg ψ { world := w, time := label.time })) = true :=
      List.any_eq_true.mpr ⟨y.label.world, mem_knownWorlds_of_mem hy, hcontains⟩
    rw [this] at hguard
    exact Bool.noConfusion hguard

theorem diamondPos_guard_sig {sf : SignedFormula} {ψ : Formula} {b : Branch} {ord : TimeOrdering}
    (hf : asDiamond? sf.formula = some ψ) (hs : sf.sign = Sign.pos)
    (hguard : witnessPresent .diamondPos sf b ord = false) :
    ∀ y ∈ b, witnessSig y
      ≠ witnessSig (SignedFormula.pos ψ { world := b.nextWorld, time := sf.label.time }) := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hs
    simp only [witnessPresent, hf] at hguard
    intro y hy heq
    have h1 : y.sign = Sign.pos := congrArg SignedFormula.sign heq
    have h2 : y.formula = ψ := congrArg SignedFormula.formula heq
    have h3 : y.label.time = label.time := congrArg (fun z => z.label.time) heq
    have hy' : y = SignedFormula.pos ψ { world := y.label.world, time := label.time } := by
      obtain ⟨ys, yf, yl⟩ := y
      obtain ⟨yw, yt⟩ := yl
      simp_all [SignedFormula.pos]
    have hcontains : b.contains
        (SignedFormula.pos ψ { world := y.label.world, time := label.time }) = true := by
      rw [← hy']; exact contains_of_mem hy
    have : (b.knownWorlds.any fun w =>
        b.contains (SignedFormula.pos ψ { world := w, time := label.time })) = true :=
      List.any_eq_true.mpr ⟨y.label.world, mem_knownWorlds_of_mem hy, hcontains⟩
    rw [this] at hguard
    exact Bool.noConfusion hguard

theorem resultBranch_sub {b nb : Branch} {res : RuleResult}
    (h : nb ∈ (nonBranchingResultBranch b res).toList ++ branchingResultBranches b res) :
    (∀ x ∈ b, x ∈ nb) ∧ (∀ x ∈ nb, x ∈ res.emitted ∨ x ∈ b) := by
  cases res with
  | linear fs =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.mem_append,
      List.mem_cons, List.not_mem_nil, or_false, List.append_nil] at h
    subst h
    exact ⟨fun x hx => List.mem_append_right _ hx,
      fun x hx => (List.mem_append.mp hx).imp id id⟩
  | persistent fs =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.mem_append,
      List.mem_cons, List.not_mem_nil, or_false, List.append_nil] at h
    subst h
    exact ⟨fun x hx => List.mem_append_right _ hx,
      fun x hx => (List.mem_append.mp hx).imp id id⟩
  | branching bss =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.nil_append,
      List.mem_map] at h
    obtain ⟨fs, hfs, rfl⟩ := h
    exact ⟨fun x hx => List.mem_append_right _ hx,
      fun x hx => (List.mem_append.mp hx).imp
        (fun hh => List.mem_flatten.mpr ⟨fs, hfs, hh⟩) id⟩
  | branchingOrdered bs =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.nil_append,
      List.not_mem_nil] at h
  | notApplicable =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.nil_append,
      List.not_mem_nil] at h

set_option maxHeartbeats 1000000 in
theorem applyRule_worldWitnessKnown {C : Finset Formula} {S : Finset WorldIndex}
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hC : TableauClosed C) (hstock : ∀ x ∈ b, x.formula ∈ C) (hsf : sf ∈ b)
    (hguard : witnessPresent rule sf b ord = false)
    (hww : WorldWitnessKnown C S b) :
    ∀ nb ∈ (nonBranchingResultBranch b (applyRule rule sf b ord).1).toList
             ++ branchingResultBranches b (applyRule rule sf b ord).1,
      WorldWitnessKnown C S nb := by
  intro nb hnb
  obtain ⟨hsub, hmem⟩ := resultBranch_sub hnb
  by_cases hbn : rule = .boxNeg
  · subst hbn
    by_cases hnew : b.nextWorld ∈ nb.worldFinset
    · obtain ⟨x, hx, hxw⟩ := exists_mem_of_mem_worldFinset hnew
      have hxe : x ∈ (applyRule .boxNeg sf b ord).1.emitted := by
        rcases hmem x hx with h | h
        · exact h
        · exact absurd (hxw ▸ Branch.mem_worldFinset h) (nextWorld_not_mem_worldFinset b)
      obtain ⟨ψ, hf, hs⟩ := applyRule_boxNeg_shape hxe
      obtain ⟨fs, hres⟩ := applyRule_boxNeg_eq (b := b) (ord := ord) hf hs
      have hnbeq : nb = fs ++ b := by
        rw [hres] at hnb
        simpa [nonBranchingResultBranch, branchingResultBranches] using hnb
      have hWfs : SignedFormula.neg ψ { world := b.nextWorld, time := sf.label.time } ∈ fs := by
        have hW := applyRule_boxNeg_witness (b := b) (ord := ord) hf hs
        rwa [hres, RuleResult.emitted_linear] at hW
      refine worldWitnessKnown_mint hww hsub ?_ (nextWorld_not_mem_worldFinset b)
        (hnbeq ▸ List.mem_append_left _ hWfs) rfl
        (hC.box_inner (hf ▸ hstock sf hsf)) (boxNeg_guard_sig hf hs hguard)
      intro y hy
      rcases hmem y hy with h | h
      · exact Or.inr (applyRule_boxNeg_emitted_world y h)
      · exact Or.inl (Branch.mem_worldFinset h)
    · refine worldWitnessKnown_of_no_new_world hww hsub ?_
      intro y hy
      rcases hmem y hy with h | h
      · exact absurd (applyRule_boxNeg_emitted_world y h ▸ Branch.mem_worldFinset hy) hnew
      · exact Branch.mem_worldFinset h
  · by_cases hdp : rule = .diamondPos
    · subst hdp
      by_cases hnew : b.nextWorld ∈ nb.worldFinset
      · obtain ⟨x, hx, hxw⟩ := exists_mem_of_mem_worldFinset hnew
        have hxe : x ∈ (applyRule .diamondPos sf b ord).1.emitted := by
          rcases hmem x hx with h | h
          · exact h
          · exact absurd (hxw ▸ Branch.mem_worldFinset h) (nextWorld_not_mem_worldFinset b)
        obtain ⟨ψ, hf, hs⟩ := applyRule_diamondPos_shape hxe
        obtain ⟨fs, hres⟩ := applyRule_diamondPos_eq (b := b) (ord := ord) hf hs
        have hnbeq : nb = fs ++ b := by
          rw [hres] at hnb
          simpa [nonBranchingResultBranch, branchingResultBranches] using hnb
        have hWfs : SignedFormula.pos ψ { world := b.nextWorld, time := sf.label.time } ∈ fs := by
          have hW := applyRule_diamondPos_witness (b := b) (ord := ord) hf hs
          rwa [hres, RuleResult.emitted_linear] at hW
        refine worldWitnessKnown_mint hww hsub ?_ (nextWorld_not_mem_worldFinset b)
          (hnbeq ▸ List.mem_append_left _ hWfs) rfl
          (hC.diamond_inner (asDiamond?_eq_iff.mp hf ▸ hstock sf hsf))
          (diamondPos_guard_sig hf hs hguard)
        intro y hy
        rcases hmem y hy with h | h
        · exact Or.inr (applyRule_diamondPos_emitted_world y h)
        · exact Or.inl (Branch.mem_worldFinset h)
      · refine worldWitnessKnown_of_no_new_world hww hsub ?_
        intro y hy
        rcases hmem y hy with h | h
        · exact absurd (applyRule_diamondPos_emitted_world y h ▸ Branch.mem_worldFinset hy) hnew
        · exact Branch.mem_worldFinset h
    · refine worldWitnessKnown_of_no_new_world hww hsub ?_
      intro y hy
      rcases hmem y hy with h | h
      · exact applyRule_emitted_world_mem hsf hbn hdp y h
      · exact Branch.mem_worldFinset h

set_option maxHeartbeats 1000000 in
theorem applyRule_boxNeg_result (sf : SignedFormula) (b : Branch) (ord : TimeOrdering) :
    (applyRule .boxNeg sf b ord).1 = RuleResult.notApplicable ∨
      ∃ fs, (applyRule .boxNeg sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
      first
        | contradiction
        | exact Or.inl rfl
        | exact Or.inl trivial
        | exact Or.inr ⟨_, rfl⟩

set_option maxHeartbeats 1000000 in
theorem applyRule_diamondPos_result (sf : SignedFormula) (b : Branch) (ord : TimeOrdering) :
    (applyRule .diamondPos sf b ord).1 = RuleResult.notApplicable ∨
      ∃ fs, (applyRule .diamondPos sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
      first
        | contradiction
        | exact Or.inl rfl
        | exact Or.inl trivial
        | exact Or.inr ⟨_, rfl⟩

end Scratch428World
