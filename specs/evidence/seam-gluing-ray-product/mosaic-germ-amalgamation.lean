/-
Probe 718 (R2 probe): **germ amalgamation**, and the `⊡`-saturation decidability question fixed
as a machine-readable statement rather than prose.

**Outcome: POSITIVE, as expected.** The amalgamation condition R2's mosaic method needs is
already landed: `FormalSystem/PlusLanguage/PlusPasting.lean`'s `paste` is the paper's `⌢_z` at
the general task frame (binary seam gluing, `app:gluing`'s case), built from
*Compositionality* and the reflection convention alone — no *Saturation*, no extension theorem,
no frame-class assumption. A **mosaic** here is a possible world together with a marked germ
time; its past/future labels are the pure-past / pure-future formulas true there
(`IsPurePast`/`IsPureFuture`, `PlusLanguage/Formula.lean`), kept minimal per the plan ("this
probe is about amalgamation, not a full mosaic calculus"): coherence is built into the
definition rather than assumed as a side condition, so there is no separate coherence proof
obligation to discharge. `amalgamate_pastLabel` / `amalgamate_futLabel` restrict the pasted
mosaic to the first's past label and the second's future label
(`truth_congr_agreeUpTo`/`truth_congr_agreeFrom` through `paste_agreeUpTo`/`paste_agreeFrom`),
and `amalgamate_unique` is the uniqueness clause, by `WorldHistory.ext_state`.

**The `⊡`-saturation question** (`StabSaturated`) is fixed as a `Prop`-valued predicate over a
finite mosaic set at a shared germ: whether every `⊡χ` a mosaic's history makes true is
witnessed by `χ` itself at every other mosaic in the set agreeing at the germ state. It is left
UNDECIDED here, as a definition the next round can attack by name — not as a placeholder
theorem. `stabSaturated_of_sameState` proves the one cheap corner that falls out for free: when
every mosaic in the set shares the same germ state, saturation holds unconditionally, directly
from `stab_state_only` and `PlusTruth.stab_iff`'s reflexive instantiation (the `T`-axiom
direction `⊡χ → χ`). This says nothing about the genuinely `⊡`-FREE-label case the plan
anticipated; that case remains open too.

**Evidence gap, recorded as the plan requires.** The acquired Hodkinson–Reynolds Handbook
chapter has its "Mosaics" and "Monodic fragments" sections in its table of contents only (no
retrieved body text), so R2 cannot be ranked above R1 on textual grounds yet — this probe
establishes only that R2's amalgamation PRECONDITION is free, not that the full mosaic method
succeeds.

What this does NOT do: no mosaic CALCULUS (no finite coherence conditions beyond the two
purity-filtered labels), no completeness-via-mosaics argument, and no decision of
`StabSaturated` beyond the one same-state corner. It does not touch R1 or the keystone.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

namespace Probe718Mosaic

variable {F : TaskFrame} [F.IsRegular] (M : TaskModel F) {t : F.Duration}

/-! ## Mosaics at a shared germ time -/

/-- A **mosaic** at germ time `t`: a possible world, marked at `t`. -/
@[ext]
structure Mosaic (F : TaskFrame) (t : F.Duration) where
  /-- The underlying possible world. -/
  hist : WorldHistory F

/-- The **past label**: the pure-past formulas true at the germ. Coherence is definitional —
there is no separate side condition to discharge. -/
def Mosaic.pastLabel (m : Mosaic F t) : Set PlusFormula :=
  {φ | IsPurePast φ ∧ PlusTruthAt M m.hist t φ}

/-- The **future label**: the pure-future formulas true at the germ. -/
def Mosaic.futLabel (m : Mosaic F t) : Set PlusFormula :=
  {φ | IsPureFuture φ ∧ PlusTruthAt M m.hist t φ}

/-- Two mosaics **agree at the (shared) germ**: the same state at `t`. -/
def Mosaic.Agree (m₁ m₂ : Mosaic F t) : Prop := m₁.hist.state t = m₂.hist.state t

/-! ## Amalgamation -/

/--
**Amalgamation.** Two mosaics agreeing at the germ amalgamate to a single mosaic at that germ,
through `paste` alone: choice-free, needing only *Compositionality* and the reflection
convention (`app:gluing`'s binary case) -- no *Saturation*, no extension theorem.
-/
noncomputable def amalgamate (m₁ m₂ : Mosaic F t) (h : m₁.Agree m₂) : Mosaic F t where
  hist := paste m₁.hist m₂.hist t h

/-- The amalgamated mosaic restricts to the **first** mosaic's past label. -/
theorem amalgamate_pastLabel (m₁ m₂ : Mosaic F t) (h : m₁.Agree m₂) :
    (amalgamate m₁ m₂ h).pastLabel M = m₁.pastLabel M := by
  ext φ
  constructor
  · rintro ⟨hpp, htr⟩
    exact ⟨hpp, (truth_congr_agreeUpTo M hpp (amalgamate m₁ m₂ h).hist m₁.hist t
      (paste_agreeUpTo m₁.hist m₂.hist t h)).mp htr⟩
  · rintro ⟨hpp, htr⟩
    exact ⟨hpp, (truth_congr_agreeUpTo M hpp (amalgamate m₁ m₂ h).hist m₁.hist t
      (paste_agreeUpTo m₁.hist m₂.hist t h)).mpr htr⟩

/-- The amalgamated mosaic restricts to the **second** mosaic's future label. -/
theorem amalgamate_futLabel (m₁ m₂ : Mosaic F t) (h : m₁.Agree m₂) :
    (amalgamate m₁ m₂ h).futLabel M = m₂.futLabel M := by
  ext φ
  constructor
  · rintro ⟨hpf, htr⟩
    exact ⟨hpf, (truth_congr_agreeFrom M hpf (amalgamate m₁ m₂ h).hist m₂.hist t
      (paste_agreeFrom m₁.hist m₂.hist t h)).mp htr⟩
  · rintro ⟨hpf, htr⟩
    exact ⟨hpf, (truth_congr_agreeFrom M hpf (amalgamate m₁ m₂ h).hist m₂.hist t
      (paste_agreeFrom m₁.hist m₂.hist t h)).mpr htr⟩

/-- **Uniqueness.** Any mosaic whose history agrees with the first up to the germ and with the
second from the germ IS the amalgamated mosaic -- `paste` leaves no freedom. -/
theorem amalgamate_unique (m₁ m₂ m' : Mosaic F t) (h : m₁.Agree m₂)
    (hup : AgreeUpTo m'.hist m₁.hist t) (hfr : AgreeFrom m'.hist m₂.hist t) :
    m' = amalgamate m₁ m₂ h := by
  have hstate : ∀ s, m'.hist.state s = (amalgamate m₁ m₂ h).hist.state s := by
    intro s
    by_cases hs : s ≤ t
    · exact (hup s hs).trans (paste_agreeUpTo m₁.hist m₂.hist t h s hs).symm
    · have hs' : t ≤ s := (not_le.mp hs).le
      exact (hfr s hs').trans (paste_agreeFrom m₁.hist m₂.hist t h s hs').symm
  have hheq : m'.hist = (amalgamate m₁ m₂ h).hist := WorldHistory.ext_state hstate
  exact Mosaic.ext hheq

/-! ## The `⊡`-saturation decidability question, fixed as a statement -/

/--
**The `⊡`-saturation question.** Over a finite set of mosaics sharing a germ time: is every
`⊡χ` a mosaic's history makes true witnessed by `χ` itself at every OTHER mosaic in the set that
agrees with it at the germ state? Fixed here as a `Prop` for the next round to attack by name;
NOT decided in general.
-/
def StabSaturated (S : Finset (Mosaic F t)) : Prop :=
  ∀ m ∈ S, ∀ χ : PlusFormula, PlusTruthAt M m.hist t (.stab χ) →
    ∀ m' ∈ S, m'.hist.state t = m.hist.state t → PlusTruthAt M m'.hist t χ

/--
**The one cheap corner.** When every mosaic in the set shares the SAME germ state,
`StabSaturated` holds unconditionally -- directly from `stab_state_only` (transporting `⊡χ`
across the shared state) and `PlusTruth.stab_iff`'s reflexive instantiation (the `T`-axiom
direction `⊡χ → χ`). This is the fragment that "falls out for free"; the genuinely mixed-state
case is left open, by design.
-/
theorem stabSaturated_of_sameState (S : Finset (Mosaic F t))
    (hS : ∀ m ∈ S, ∀ m' ∈ S, m.hist.state t = m'.hist.state t) :
    StabSaturated M S := by
  intro m hm χ hχ m' hm' _
  have hstate : m.hist.state t = m'.hist.state t := hS m hm m' hm'
  have htr : PlusTruthAt M m'.hist t (.stab χ) := (stab_state_only M m.hist m'.hist t t hstate χ).mp hχ
  exact (PlusTruth.stab_iff M m'.hist t χ).mp htr m'.hist rfl

end Probe718Mosaic

/-! ## Axiom record -/

#print axioms Probe718Mosaic.amalgamate_pastLabel
#print axioms Probe718Mosaic.amalgamate_futLabel
#print axioms Probe718Mosaic.amalgamate_unique
#print axioms Probe718Mosaic.stabSaturated_of_sameState
