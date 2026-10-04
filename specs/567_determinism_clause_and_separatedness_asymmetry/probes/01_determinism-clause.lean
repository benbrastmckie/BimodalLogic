import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Presheaf.Ray
import FormalSystem.Semantics.DeterministicBridge
import FormalSystem.Metalogic.Independence.StarDiscrimination

/-!
Research probe: the Determinism clause of `app:presheaf-dictionary` and the separatedness
asymmetry.  Nothing here is library code; it exists to establish feasibility and cost.
-/

namespace Probe567

open FormalSystem FormalSystem.Semantics FormalSystem.Semantics.Presheaf

variable {F : TaskFrame}

/-- **Separatedness of `Beh F`**: every restriction map of the behavior presheaf is injective. -/
def Separated (F : TaskFrame) : Prop :=
  ∀ (l p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l') (hple : p + l' ≤ l),
    Function.Injective (Beh.restrict (l := l) p l' hp hl' hple)

/-! ## Part A — the choice-free direction -/

/-- Section-level singleton bridge: the `Beh`-layer counterpart of
`PlusLanguage.states_eq_of_deterministic`, same three-step proof. -/
theorem states_eq_of_deterministic_sec (hD : F.Deterministic) {l : F.Duration}
    {σ τ : Beh F l} {t : F.Duration} (ht0 : 0 ≤ t) (htl : t ≤ l)
    (h : σ.val.states t (Beh.mem_dom σ ht0 htl) = τ.val.states t (Beh.mem_dom τ ht0 htl))
    (s : F.Duration) (hs0 : 0 ≤ s) (hsl : s ≤ l) :
    σ.val.states s (Beh.mem_dom σ hs0 hsl) = τ.val.states s (Beh.mem_dom τ hs0 hsl) := by
  have hσ := σ.val.respects_task t s (Beh.mem_dom σ ht0 htl) (Beh.mem_dom σ hs0 hsl)
  have hτ := τ.val.respects_task t s (Beh.mem_dom τ ht0 htl) (Beh.mem_dom τ hs0 hsl)
  rw [h] at hσ
  exact hD _ (s - t) hσ hτ

/-- **Determinism ⟹ separatedness**, the choice-free half of the dictionary clause. -/
theorem separated_of_deterministic (hD : F.Deterministic) : Separated F := by
  intro l p l' hp hl' hple σ τ hστ
  have hpl : p ≤ l := le_trans (le_add_of_nonneg_right hl') hple
  have hd0 : (Beh.restrict p l' hp hl' hple σ).val.domain 0 := ⟨le_rfl, hl'⟩
  have hd0' : (Beh.restrict p l' hp hl' hple τ).val.domain 0 := ⟨le_rfl, hl'⟩
  have hp0 : (0 : F.Duration) ≤ p + 0 := by rw [add_zero]; exact hp
  have hpl0 : p + 0 ≤ l := by rw [add_zero]; exact hpl
  have h0 := states_eq_of_eq hστ 0 hd0 hd0'
  rw [Beh.restrict_states p l' hp hl' hple σ 0 hd0 (Beh.mem_dom σ hp0 hpl0),
      Beh.restrict_states p l' hp hl' hple τ 0 hd0' (Beh.mem_dom τ hp0 hpl0)] at h0
  have hσp : σ.val.states p (Beh.mem_dom σ hp hpl) = τ.val.states p (Beh.mem_dom τ hp hpl) := by
    rw [PartialHistory.states_eq_of_time_eq σ.val p (p + 0) (add_zero p).symm
          (Beh.mem_dom σ hp hpl) (Beh.mem_dom σ hp0 hpl0),
        PartialHistory.states_eq_of_time_eq τ.val p (p + 0) (add_zero p).symm
          (Beh.mem_dom τ hp hpl) (Beh.mem_dom τ hp0 hpl0)]
    exact h0
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z; exact propext ((σ.property z).trans (τ.property z).symm)
  · intro r hr _
    have hrr := (σ.property r).mp hr
    exact states_eq_of_deterministic_sec hD hp hpl hσp r hrr.1 hrr.2

/-! ## Part B — the converse, through the repository's own ZFC step -/

/-- A possible world, cut down to the section over `[0, l]` based at the time `m`. -/
noncomputable def secOf (σ : WorldHistory F) (m l : F.Duration) (hl : 0 ≤ l) : Beh F l :=
  (futOf (σ.timeShift m) 0).toBeh l hl

theorem secOf_states (σ : WorldHistory F) (m l : F.Duration) (hl : 0 ≤ l) {z : F.Duration}
    (hz : (secOf σ m l hl).val.domain z) :
    (secOf σ m l hl).val.states z hz = σ.state (z + m) := rfl

/-- **Separatedness ⟹ singleton stability classes.** No choice: it is the world-to-section
bridge plus one injectivity instance. -/
theorem singletonClasses_of_separated (hS : Separated F) : F.SingletonClasses := by
  intro τ σ x h y
  rcases le_total x y with hxy | hyx
  · -- base at `x`, germ at the left endpoint
    have hl : (0 : F.Duration) ≤ y - x := sub_nonneg.mpr hxy
    have hple : (0 : F.Duration) + 0 ≤ y - x := by rw [add_zero]; exact hl
    have hgerm : Beh.restrict 0 0 le_rfl le_rfl hple (secOf τ x (y - x) hl)
        = Beh.restrict 0 0 le_rfl le_rfl hple (secOf σ x (y - x) hl) := by
      refine Beh.ext (partialHistory_ext rfl ?_)
      intro r hr hr'
      obtain rfl : r = 0 := le_antisymm hr.2 hr.1
      show τ.state (0 + 0 + x) = σ.state (0 + 0 + x)
      simpa using h
    have heq := hS (y - x) 0 0 le_rfl le_rfl hple hgerm
    have hdom : (secOf τ x (y - x) hl).val.domain (y - x) := ⟨hl, le_rfl⟩
    have hdom' : (secOf σ x (y - x) hl).val.domain (y - x) := ⟨hl, le_rfl⟩
    have := states_eq_of_eq heq (y - x) hdom hdom'
    rw [secOf_states τ x (y - x) hl hdom, secOf_states σ x (y - x) hl hdom'] at this
    simpa using this
  · -- base at `y`, germ at the right endpoint `x - y`
    have hl : (0 : F.Duration) ≤ x - y := sub_nonneg.mpr hyx
    have hple : x - y + 0 ≤ x - y := by rw [add_zero]
    have hgerm : Beh.restrict (x - y) 0 hl le_rfl hple (secOf τ y (x - y) hl)
        = Beh.restrict (x - y) 0 hl le_rfl hple (secOf σ y (x - y) hl) := by
      refine Beh.ext (partialHistory_ext rfl ?_)
      intro r hr hr'
      obtain rfl : r = 0 := le_antisymm hr.2 hr.1
      show τ.state (x - y + 0 + y) = σ.state (x - y + 0 + y)
      simpa using h
    have heq := hS (x - y) (x - y) 0 hl le_rfl hple hgerm
    have hdom : (secOf τ y (x - y) hl).val.domain 0 := ⟨le_rfl, hl⟩
    have hdom' : (secOf σ y (x - y) hl).val.domain 0 := ⟨le_rfl, hl⟩
    have := states_eq_of_eq heq 0 hdom hdom'
    rw [secOf_states τ y (x - y) hl hdom, secOf_states σ y (x - y) hl hdom'] at this
    simpa using this

/-- **The dictionary clause**, as the biconditional: `F` is deterministic iff every restriction
map of `Beh F` is injective.  The (⇐) half is a theorem of ZFC, through
`deterministic_of_singletonClasses` and hence `thm:extension`. -/
theorem separated_iff_deterministic (F : TaskFrame) [F.IsRegular] :
    Separated F ↔ F.Deterministic :=
  ⟨fun hS => deterministic_of_singletonClasses (singletonClasses_of_separated hS),
   separated_of_deterministic⟩

/-! ## Part C — the asymmetry, at the repository's own drift frame -/

open FormalSystem.Metalogic.Independence in
/-- The affine drift world of rate `a`, cut down to the section over `[0, 1]`. -/
noncomputable def driftSec (a : ℝ) (h1 : 1 ≤ a) (h2 : a ≤ 2) : Beh F0 1 :=
  secOf (driftLinear a h1 h2) 0 1 zero_le_one

open FormalSystem.Metalogic.Independence in
/-- **`Beh F°` is not separated**: the rate-1 and rate-2 drift sections over `[0, 1]` have the
same germ at `0` and different states at `1`.  Choice-free, and the two worlds are the
repository's own (`Independence/StarDiscrimination.lean`). -/
theorem fzero_not_separated : ¬ Separated F0 := by
  intro hS
  have hple : (0 : F0.Duration) + 0 ≤ 1 := by rw [add_zero]; exact zero_le_one
  have hgerm : Beh.restrict 0 0 le_rfl le_rfl hple (driftSec 1 le_rfl one_le_two)
      = Beh.restrict 0 0 le_rfl le_rfl hple (driftSec 2 one_le_two le_rfl) := by
    refine Beh.ext (partialHistory_ext rfl ?_)
    intro r hr hr'
    obtain rfl : r = 0 := le_antisymm hr.2 hr.1
    show (1 : ℝ) * ((0 : ℝ) + 0 + 0) = (2 : ℝ) * ((0 : ℝ) + 0 + 0)
    ring
  have heq := hS 1 0 0 le_rfl le_rfl hple hgerm
  have hdom : (driftSec 1 le_rfl one_le_two).val.domain 1 := ⟨zero_le_one, le_rfl⟩
  have hdom' : (driftSec 2 one_le_two le_rfl).val.domain 1 := ⟨zero_le_one, le_rfl⟩
  have hst := states_eq_of_eq heq 1 hdom hdom'
  have : (1 : ℝ) * ((1 : ℝ) + 0) = (2 : ℝ) * ((1 : ℝ) + 0) := hst
  norm_num at this

open FormalSystem.Metalogic.Independence in
/-- **The theorem pair.**  `F°` validates every instance of *Determined* and `Beh F°` is not
separated: separatedness of the behavior presheaf is strictly stronger than the validity of
*Determined* on the frame. -/
theorem separated_strictly_stronger :
    (∀ φ : PlusLanguage.PlusFormula, F0.PlusValidOn (.imp φ (.stab φ))) ∧ ¬ Separated F0 :=
  ⟨fzero_determined, fzero_not_separated⟩

end Probe567

section AxiomPins
open Probe567
#print axioms Probe567.states_eq_of_deterministic_sec
#print axioms Probe567.separated_of_deterministic
#print axioms Probe567.singletonClasses_of_separated
#print axioms Probe567.separated_iff_deterministic
#print axioms Probe567.fzero_not_separated
#print axioms Probe567.separated_strictly_stronger
end AxiomPins
