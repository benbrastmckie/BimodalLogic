import FormalSystem.OpenLanguage
import FormalSystem.Metalogic.Deterministic.Erasure
import FormalSystem.PlusLanguage.Substitution
import FormalSystem.PlusLanguage.PlusNonValidities
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.TemporalDerived

/-!
# Probe: `▷/◁`-erasure, the deterministic collapse, and the axiom-discharge table

**Compiled-live** against the repository's own `OpenTruthAt`, `PlusTruthAt`, `PlusAxiom`,
`PlusDerivationTree`, `erasePlus`, `truth_congr_ext` and `states_eq_of_deterministic`; no
mirrored definitions.

What is established here:

1. `eraseOpen : OpenFormula → PlusFormula` deletes `▷` and `◁` and keeps `⊡` primitive. It is a
   retraction of `ofPlus` (`eraseOpen_ofPlus`) and commutes with time reflection
   (`eraseOpen_reflectTime`).
2. **The deterministic collapse** (`openTruthAt_eraseOpen_of_deterministic`): over a
   deterministic frame the deletion is truth-preserving at every history and time. Determinism
   is consumed only in the `ofut`/`opast` cases; the `stab` case is structural, because
   `eraseOpen` keeps `⊡`.
3. **The axiom-discharge table, for the `▷/◁` schemata**: the erasure of each candidate
   `OpenAxiom` constructor is a TM⁺ theorem. Nine arms are below, including the Ockhamist HN
   schema.
4. **The one schema that cannot be an axiom if (3) is to hold**: the `←` half of the
   definability equation `▷◁φ → ⊡φ` erases to *Determined*, which is not even L⁺-valid
   (`refute_determined`). It stays a validity, not a constructor.
-/

namespace Probe856R01

open FormalSystem
open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.Semantics

/-! ## 1. The erasure -/

/-- Deletion of every `▷` and `◁` occurrence; `⊡` and the six L constructors are kept. -/
def eraseOpen : OpenFormula → PlusFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (eraseOpen φ) (eraseOpen ψ)
  | .box φ => .box (eraseOpen φ)
  | .untl ψ φ => .untl (eraseOpen ψ) (eraseOpen φ)
  | .snce ψ φ => .snce (eraseOpen ψ) (eraseOpen φ)
  | .stab φ => .stab (eraseOpen φ)
  | .ofut φ => eraseOpen φ
  | .opast φ => eraseOpen φ

/-- `eraseOpen` is a retraction of the embedding `ofPlus`. -/
@[simp] theorem eraseOpen_ofPlus (φ : PlusFormula) : eraseOpen (ofPlus φ) = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [ofPlus, eraseOpen, ih1, ih2]
  | box _ ih => simp only [ofPlus, eraseOpen, ih]
  | untl _ _ ih1 ih2 => simp only [ofPlus, eraseOpen, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [ofPlus, eraseOpen, ih1, ih2]
  | stab _ ih => simp only [ofPlus, eraseOpen, ih]

/-- Erasure commutes with time reflection: `reflectTime` exchanges `▷` with `◁`, which erasure
deletes, and acts on the six L constructors in the same pattern on both sides. -/
theorem eraseOpen_reflectTime (φ : OpenFormula) :
    eraseOpen φ.reflectTime = (eraseOpen φ).reflectTime := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih1, ih2]
  | box _ ih => simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih]
  | untl _ _ ih1 ih2 =>
    simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih1, ih2]
  | snce _ _ ih1 ih2 =>
    simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih1, ih2]
  | stab _ ih => simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih]
  | ofut _ ih => simp only [OpenFormula.reflectTime, eraseOpen, ih]
  | opast _ ih => simp only [OpenFormula.reflectTime, eraseOpen, ih]

/-- Erasure commutes with the derived operators definitionally. -/
example (φ : OpenFormula) : eraseOpen φ.neg = (eraseOpen φ).neg := rfl
example (φ : OpenFormula) :
    eraseOpen (OpenFormula.somePast φ) = PlusFormula.somePast (eraseOpen φ) := rfl
example (φ : OpenFormula) : eraseOpen (OpenFormula.dofut φ) = (eraseOpen φ).neg.neg := rfl
example (φ : OpenFormula) : eraseOpen (OpenFormula.dstab φ) = PlusFormula.dstab (eraseOpen φ) :=
  rfl

/-! ## 2. The deterministic collapse -/

variable {F : TaskFrame}

/--
**The pointwise collapse.** Over a deterministic frame, `OpenTruthAt` of `φ` and `PlusTruthAt` of
its `▷/◁`-erasure coincide at every world history and time.

Determinism enters only in the `ofut` and `opast` cases, through
`states_eq_of_deterministic` and the landed `truth_congr_ext`: a history agreeing with `τ` on a
half-line agrees with it at the time of evaluation, hence everywhere.
-/
theorem openTruthAt_eraseOpen_of_deterministic (hD : F.Deterministic) (M : TaskModel F)
    (φ : OpenFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (eraseOpen φ) := by
  induction φ with
  | atom p => intro τ t; exact Iff.rfl
  | bot => intro τ t; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro τ t; exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih => intro τ t; exact forall_congr' fun σ => ih σ t
  | untl ψ φ ihψ ihφ =>
    intro τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | snce ψ φ ihψ ihφ =>
    intro τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | stab φ ih =>
    intro τ t
    exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t
  | ofut φ ih =>
    intro τ t
    constructor
    · intro h; exact (ih τ t).mp (h τ (fun _ _ => rfl))
    · intro h σ hag
      exact (ih σ t).mpr
        ((truth_congr_ext M (eraseOpen φ) τ σ t
          (states_eq_of_deterministic hD (hag t le_rfl))).mp h)
  | opast φ ih =>
    intro τ t
    constructor
    · intro h; exact (ih τ t).mp (h τ (fun _ _ => rfl))
    · intro h σ hag
      exact (ih σ t).mpr
        ((truth_congr_ext M (eraseOpen φ) τ σ t
          (states_eq_of_deterministic hD (hag t le_rfl))).mp h)

/-- The composite collapse all the way down to L: over a deterministic frame an L^▷ formula is
true exactly where the L formula obtained by deleting `▷`, `◁` and `⊡` is. -/
theorem openTruthAt_erasePlus_eraseOpen_of_deterministic (hD : F.Deterministic)
    (M : TaskModel F) (φ : OpenFormula) (τ : WorldHistory F) (t : F.Duration) :
    OpenTruthAt M τ t φ ↔ TruthAt M τ t (Metalogic.Deterministic.erasePlus (eraseOpen φ)) :=
  (openTruthAt_eraseOpen_of_deterministic hD M φ τ t).trans
    (Metalogic.Deterministic.plusTruthAt_erasePlus_of_deterministic hD M (eraseOpen φ) τ t)

/-! ## 3. The axiom-discharge table for the `▷/◁` schemata -/

/-- `⊢⁺[fc] φ → φ`, the identity combinator, from `prop_k` and `prop_s`. -/
def plusIdImp {fc : FrameClass} (φ : PlusFormula) : ⊢⁺[fc] φ.imp φ :=
  .modus_ponens [] _ _
    (.modus_ponens [] _ _
      (.axiom [] _ (PlusAxiom.prop_k φ (φ.imp φ) φ) (FrameClass.base_le fc))
      (.axiom [] _ (PlusAxiom.prop_s φ (φ.imp φ)) (FrameClass.base_le fc)))
    (.axiom [] _ (PlusAxiom.prop_s φ φ) (FrameClass.base_le fc))

section Discharge

variable {fc : FrameClass} (φ ψ : OpenFormula)

/-- `▷`-K erases to an identity. -/
def discharge_ofut_k :
    ⊢⁺[fc] eraseOpen ((OpenFormula.ofut (φ.imp ψ)).imp
      ((OpenFormula.ofut φ).imp (OpenFormula.ofut ψ))) :=
  plusIdImp _

/-- `▷`-T erases to an identity. -/
def discharge_ofut_t : ⊢⁺[fc] eraseOpen ((OpenFormula.ofut φ).imp φ) := plusIdImp _

/-- `▷`-4 erases to an identity. -/
def discharge_ofut_four :
    ⊢⁺[fc] eraseOpen ((OpenFormula.ofut φ).imp (OpenFormula.ofut (OpenFormula.ofut φ))) :=
  plusIdImp _

/-- `▷`-5 erases to an identity. -/
def discharge_ofut_five :
    ⊢⁺[fc] eraseOpen ((OpenFormula.dofut φ).imp (OpenFormula.ofut (OpenFormula.dofut φ))) :=
  plusIdImp _

/-- `◁`-K, -T, -4, -5 erase to identities by the same four lines; the mirror block is cheap for
exactly the reason the `▷` block is. -/
def discharge_opast_t : ⊢⁺[fc] eraseOpen ((OpenFormula.opast φ).imp φ) := plusIdImp _

/-- The bridge `⊡φ → ▷φ` erases to ST (`stab_t`). -/
def discharge_ofut_of_stab :
    ⊢⁺[fc] eraseOpen ((OpenFormula.stab φ).imp (OpenFormula.ofut φ)) :=
  .axiom [] _ (PlusAxiom.stab_t (eraseOpen φ)) (FrameClass.base_le fc)

/-- The bridge `⊡φ → ◁φ` erases to ST as well. -/
def discharge_opast_of_stab :
    ⊢⁺[fc] eraseOpen ((OpenFormula.stab φ).imp (OpenFormula.opast φ)) :=
  .axiom [] _ (PlusAxiom.stab_t (eraseOpen φ)) (FrameClass.base_le fc)

/-- The bridge `□φ → ⊡φ` erases to MS (`box_stab`) verbatim. -/
def discharge_stab_of_box :
    ⊢⁺[fc] eraseOpen ((OpenFormula.box φ).imp (OpenFormula.stab φ)) :=
  .axiom [] _ (PlusAxiom.box_stab (eraseOpen φ)) (FrameClass.base_le fc)

/-- Each half of a rigidity schema (`◁φ⁺ → φ⁺` and `φ⁺ → ◁φ⁺`) erases to an identity — the
reason to state the two rigidity schemata as implication pairs rather than biconditionals. -/
def discharge_rigidity_fwd : ⊢⁺[fc] eraseOpen ((OpenFormula.opast φ).imp φ) := plusIdImp _

/-- The `→` half of the definability equation erases to an identity. -/
def discharge_definability_fwd :
    ⊢⁺[fc] eraseOpen ((OpenFormula.stab φ).imp (OpenFormula.ofut (OpenFormula.opast φ))) :=
  .axiom [] _ (PlusAxiom.stab_t (eraseOpen φ)) (FrameClass.base_le fc)

end Discharge

/-! ### The HN arm, the one arm that is not a one-liner -/

/-- **The Ockhamist HN schema `Pα → ▷P▷̂α` erases to a TM⁺ theorem.** The image is
`Pα° → P¬¬α°`, which is `pMono` (`Theorems/TemporalDerived.lean`) and `impNegImp`
(`Theorems/Propositional/Core.lean`) transported to arbitrary L⁺ arguments by
`plusDerivable_substPlus_nil`. -/
theorem discharge_hnOpen {fc : FrameClass} (α : OpenFormula) :
    PlusDerivable fc [] (eraseOpen (hnOpen α)) := by
  -- the TM theorem `P p → P ¬¬p` at one atom, substituted at `eraseOpen α`
  let p : Atom := ⟨"p", none⟩
  let σ : Atom → PlusFormula := fun _ => eraseOpen α
  have htm : ProofSystem.Derivable fc []
      ((Formula.atom p).somePast.imp ((Formula.atom p).neg.neg).somePast) :=
    ⟨Theorems.TemporalDerived.somePastMono
      (Theorems.Propositional.impNegImp (Formula.atom p) Formula.bot)⟩
  exact plusDerivable_substPlus_nil (fc := fc) σ htm

/-! ## 4. The schema that must stay out of the axiom type -/

/--
**The `←` half of the definability equation erases to *Determined*.** At
`φ := F p` the erasure of `▷◁φ → ⊡φ` is literally `Fp → ⊡Fp`, which `refute_determined`
refutes over `NF`. Since TM⁺ is sound, the image is not a TM⁺ theorem at any frame class — so
adding `▷◁φ → ⊡φ` as an `OpenAxiom` constructor would break the discharge table of §3, and with
it the syntactic route to forward conservativity over TM⁺.
-/
theorem definability_bwd_erasure_eq (p : Atom) :
    eraseOpen ((OpenFormula.ofut (OpenFormula.opast
        (OpenFormula.someFuture (OpenFormula.atom p)))).imp
      (OpenFormula.stab (OpenFormula.someFuture (OpenFormula.atom p)))) =
      PlusFormula.imp (PlusFormula.someFuture (PlusFormula.atom p))
        (PlusFormula.stab (PlusFormula.someFuture (PlusFormula.atom p))) := rfl

/-- The erasure of that instance is not even L⁺-valid. -/
theorem definability_bwd_erasure_not_plusValid (p : Atom) :
    ¬ PlusValid (eraseOpen ((OpenFormula.ofut (OpenFormula.opast
        (OpenFormula.someFuture (OpenFormula.atom p)))).imp
      (OpenFormula.stab (OpenFormula.someFuture (OpenFormula.atom p))))) := by
  rw [definability_bwd_erasure_eq]
  exact refute_determined p

end Probe856R01
