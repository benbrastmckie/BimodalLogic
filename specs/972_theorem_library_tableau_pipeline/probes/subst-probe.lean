import FormalSystem
import BimodalLib.Registry

set_option autoImplicit false
set_option maxHeartbeats 1000000

namespace SubstProbe

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass Axiom DerivationTree)

/-- L-level uniform substitution on formulas: the `Formula → Formula` mirror of `substPlus`. -/
def substF (σ : Atom → Formula) : Formula → Formula
  | .atom p => σ p
  | .bot => .bot
  | .imp φ ψ => .imp (substF σ φ) (substF σ ψ)
  | .box φ => .box (substF σ φ)
  | .untl ψ φ => .untl (substF σ ψ) (substF σ φ)
  | .snce ψ φ => .snce (substF σ ψ) (substF σ φ)

theorem substF_atom (φ : Formula) : substF Formula.atom φ = φ := by
  induction φ with
  | atom p => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [substF, ih1, ih2]
  | box _ ih => simp only [substF, ih]
  | untl _ _ ih1 ih2 => simp only [substF, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [substF, ih1, ih2]

theorem substF_reflectTime (σ : Atom → Formula) (φ : Formula) :
    substF σ φ.reflectTime = (substF (fun p => (σ p).reflectTime) φ).reflectTime := by
  induction φ with
  | atom p => exact (Formula.reflect_time_involution (σ p)).symm
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [Formula.reflectTime, substF, ih1, ih2]
  | box _ ih => simp only [Formula.reflectTime, substF, ih]
  | untl _ _ ih1 ih2 => simp only [Formula.reflectTime, substF, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [Formula.reflectTime, substF, ih1, ih2]

/-- Every TM axiom instance is a TM axiom instance under `substF σ`. -/
def Axiom.ofSubst (σ : Atom → Formula) : {φ : Formula} → Axiom φ → Axiom (substF σ φ)
  | _, .prop_k φ ψ χ => .prop_k (substF σ φ) (substF σ ψ) (substF σ χ)
  | _, .prop_s φ ψ => .prop_s (substF σ φ) (substF σ ψ)
  | _, .ex_falso φ => .ex_falso (substF σ φ)
  | _, .peirce φ ψ => .peirce (substF σ φ) (substF σ ψ)
  | _, .modal_t φ => .modal_t (substF σ φ)
  | _, .modal_5_collapse φ => .modal_5_collapse (substF σ φ)
  | _, .modal_k_dist φ ψ => .modal_k_dist (substF σ φ) (substF σ ψ)
  | _, .serial_future => .serial_future
  | _, .left_mono_until_G φ χ ψ => .left_mono_until_G (substF σ φ) (substF σ χ) (substF σ ψ)
  | _, .right_mono_until φ ψ χ => .right_mono_until (substF σ φ) (substF σ ψ) (substF σ χ)
  | _, .enrichment_until φ ψ p => .enrichment_until (substF σ φ) (substF σ ψ) (substF σ p)
  | _, .self_accum_until φ ψ => .self_accum_until (substF σ φ) (substF σ ψ)
  | _, .absorb_until φ ψ => .absorb_until (substF σ φ) (substF σ ψ)
  | _, .linear_until φ ψ χ θ =>
      .linear_until (substF σ φ) (substF σ ψ) (substF σ χ) (substF σ θ)
  | _, .modal_future φ => .modal_future (substF σ φ)
  | _, .discrete_box_necessity => .discrete_box_necessity
  | _, .prior_UZ φ => .prior_UZ (substF σ φ)
  | _, .dense_indicator => .dense_indicator
  | _, .prior_U_gap φ => .prior_U_gap (substF σ φ)
  | _, .sep φ => .sep (substF σ φ)

theorem Axiom.minFrameClass_ofSubst (σ : Atom → Formula) {φ : Formula} (ax : Axiom φ) :
    (Axiom.ofSubst σ ax).minFrameClass = ax.minFrameClass := by
  cases ax <;> rfl

/-- **Uniform substitution as data.** The `Formula → Formula` mirror of
`PlusDerivationTree.ofTMSubst`. -/
def DerivationTree.subst {fc : FrameClass} (σ : Atom → Formula) :
    {Γ : Context} → {φ : Formula} → DerivationTree fc Γ φ →
      DerivationTree fc (Γ.map (substF σ)) (substF σ φ)
  | _, _, .axiom _ _ h h_fc =>
      .axiom _ _ (Axiom.ofSubst σ h)
        (by rw [Axiom.minFrameClass_ofSubst]; exact h_fc)
  | _, _, .assumption _ _ h => .assumption _ _ (List.mem_map_of_mem h)
  | _, _, .modus_ponens _ φ ψ d1 d2 =>
      .modus_ponens _ (substF σ φ) (substF σ ψ) (subst σ d1) (subst σ d2)
  | _, _, .necessitation φ d => .necessitation (substF σ φ) (subst σ d)
  | _, _, .temporal_necessitation φ d => .temporal_necessitation (substF σ φ) (subst σ d)
  | _, _, .time_reflection φ d =>
      (substF_reflectTime σ φ).symm ▸
        DerivationTree.time_reflection (substF (fun p => (σ p).reflectTime) φ)
          (subst (fun p => (σ p).reflectTime) d)
  | _, _, .weakening _ _ _ d h =>
      .weakening _ _ _ (subst σ d)
        (by
          intro x hx
          obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx
          exact List.mem_map_of_mem (h hy))

/-- The empty-context form: a TM theorem over concrete atoms becomes a TM theorem at
arbitrary L arguments. -/
def DerivationTree.substNil {fc : FrameClass} {φ : Formula} (σ : Atom → Formula)
    (d : DerivationTree fc [] φ) : DerivationTree fc [] (substF σ φ) :=
  DerivationTree.subst σ d

end SubstProbe

/-! ### End-to-end: a concrete extracted-shape derivation, generalized, then registered -/

namespace SubstProbe.Enumerated

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass Axiom DerivationTree)

/-- The canonical first enumerated atom, as `AtomCanonicalization` produces it. -/
def pAtom : Atom := ⟨"p", none⟩

/-- A CONCRETE derivation over the concrete atom `p`, standing for what the tableau extracts:
`□p → p`, i.e. the T axiom at `p`. -/
def concreteT : DerivationTree FrameClass.Base []
    ((Formula.atom pAtom).box.imp (Formula.atom pAtom)) :=
  .axiom _ _ (.modal_t (Formula.atom pAtom)) (by decide)

/-- The substitution that sends the one canonical atom to a schema argument. -/
def σOf (A : Formula) : Atom → Formula := fun q => if q = pAtom then A else Formula.atom q

/-- The GENERALIZED statement, obtained from the concrete derivation by uniform substitution.
This is the shape `register_theorem` requires: a closed derivation schematic in its arguments. -/
def modalT_generalized (A : Formula) : DerivationTree FrameClass.Base [] (A.box.imp A) := by
  have h := DerivationTree.substNil (σOf A) concreteT
  simpa [SubstProbe.substF, σOf] using h

end SubstProbe.Enumerated

-- THE GATE: does `register_theorem` accept the generalized, substitution-derived entry?
register_theorem SubstProbe.Enumerated.modalT_generalized

#print axioms SubstProbe.Enumerated.modalT_generalized
#eval (BimodalLib.Registry.SubstProbe.Enumerated.modalT_generalized.profile,
       BimodalLib.Registry.SubstProbe.Enumerated.modalT_generalized.arity,
       BimodalLib.Registry.SubstProbe.Enumerated.modalT_generalized.fragment.name)
