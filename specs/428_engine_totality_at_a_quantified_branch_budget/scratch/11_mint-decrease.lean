/-
SCRATCH — Phase 11 tasks 3-4: the mint decrease at the pick. NOT part of the library build.
-/
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace Scratch428Dec

open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

theorem mintPotential_lt_of_pick_linear {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {sf₀ sf : SignedFormula}
    {fs : List SignedFormula} {o : TimeOrdering}
    (hpick : findApplicableRule sf₀ b ord fc = some (r, RuleResult.linear fs, o))
    (hfresh : ruleMintsFreshLabel r = true) (hsfU : sf ∈ U) (hσ : σ sf = sf₀) :
    mintPotential U σ (fs ++ b) o < mintPotential U σ b ord := by
  have hpair : applyRule r sf₀ b ord = (RuleResult.linear fs, o) :=
    findApplicableRule_applyRule_pair hpick
  have hbefore : witnessPresent r (σ sf) b ord = false := by
    rw [hσ]; exact findApplicableRule_guard_linear hpick hfresh
  have hafter : witnessPresent r (σ sf) (fs ++ b) o = true := by
    rw [hσ]
    have := applyRule_fresh_witness_nonbranching (rule := r) (sf := sf₀) (b := b) (ord := ord)
      hfresh (fs ++ b) (by rw [hpair]; simp [nonBranchingResultBranch])
    rwa [hpair] at this
  have hord : ∀ q ∈ ord.constraints, q ∈ o.constraints := by
    have := applyRule_ord_mono r sf₀ b ord
    rwa [hpair] at this
  exact mintPotential_lt_of_mint (fun _ hx => List.mem_append_right fs hx) hord
    (mem_freshLabelRules.mpr hfresh) hsfU hbefore hafter

theorem mintPotential_lt_of_pick_branching {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {sf₀ sf : SignedFormula}
    {bss : List (List SignedFormula)} {o : TimeOrdering}
    (hpick : findApplicableRule sf₀ b ord fc = some (r, RuleResult.branching bss, o))
    (hfresh : ruleMintsFreshLabel r = true) (hsfU : sf ∈ U) (hσ : σ sf = sf₀) :
    ∀ arm ∈ bss, mintPotential U σ (arm ++ b) o < mintPotential U σ b ord := by
  have hpair : applyRule r sf₀ b ord = (RuleResult.branching bss, o) :=
    findApplicableRule_applyRule_pair hpick
  have hbefore : witnessPresent r (σ sf) b ord = false := by
    rw [hσ]; exact findApplicableRule_guard_branching hpick hfresh
  have hord : ∀ q ∈ ord.constraints, q ∈ o.constraints := by
    have := applyRule_ord_mono r sf₀ b ord
    rwa [hpair] at this
  intro arm harm
  have hafter : witnessPresent r (σ sf) (arm ++ b) o = true := by
    rw [hσ]
    have := applyRule_fresh_witness_branching (rule := r) (sf := sf₀) (b := b) (ord := ord)
      hfresh (arm ++ b) (by rw [hpair]; exact List.mem_map_of_mem harm)
    rwa [hpair] at this
  exact mintPotential_lt_of_mint (fun _ hx => List.mem_append_right arm hx) hord
    (mem_freshLabelRules.mpr hfresh) hsfU hbefore hafter

end Scratch428Dec

#print axioms Scratch428Dec.mintPotential_lt_of_pick_linear
#print axioms Scratch428Dec.mintPotential_lt_of_pick_branching
