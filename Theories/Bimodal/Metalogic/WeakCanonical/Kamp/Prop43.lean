import Bimodal.Metalogic.WeakCanonical.Kamp.VecEA_m
import Bimodal.Metalogic.WeakCanonical.Kamp.EAVecNegationClosure
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# Phase 4b/4c: Proposition 4.3 — every monadic FO formula is V-EA equivalent

Rabinovich (2014), Proposition 4.3: every monadic first-order formula over a
linear order is equivalent (on strictly increasing environments) to a
`VVecEA_m` formula. The proof is a *structural* induction on the FO formula
(no NF-depth parameter, no arity tower):

- **atom**: a single endpoint predicate at the relevant free variable, built
  from `atom_literal` (requires `atomMap` surjective on the signature).
- **lt**: decided by the indices alone — under `StrictMono env`,
  `env i < env j ↔ i < j`. So the case is the constant-`⊤` or constant-`⊥`
  `VVecEA_m`.
- **and**: `VVecEA_m.conj` (Lemma 3.2(1)).
- **or** / disjunction: `VVecEA_m.disj`.
- **not**: the arbitrary-arity negation closure `neg_vec_ea_m` (Phase 4a),
  in its model-dependent existential form (Phase 4c).
- **ex**: existential closure (Lemma 3.4). The De Bruijn `.ex` binder prepends
  the witness at index 0 with *no order constraint*, whereas `existClosure`
  absorbs the rightmost free variable. The honest gap between these is Lemma 3.4
  proper (split the witness over the m+1 order positions); see the BLOCKER note
  on `prop43_correct`'s `.ex` case.

This file is **off the live import path** (imported by nothing live), matching
the Phase 4 plan: faithful assets land off-path before the Phase 5 `:391` rewire.

## References
- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 4.3, Lemma 3.2, Lemma 3.4.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct)

/-! ## Constant-true and constant-false VVecEA_m -/

/-- The constant-`⊤` `VVecEA_m m`: a single disjunct with `⊤` at every endpoint
    and a trivial-`⊤` bracket on every interval. Holds on every environment. -/
def VVecEA_m.tt (m : Nat) : VVecEA_m m :=
  { disjuncts := [{ endpointTypes := fun _ => TemporalPred.top
                    intervalBrackets := fun _ =>
                      ⟨0, BracketFormula.trivial TemporalPred.top⟩ }] }

theorem VVecEA_m.tt_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (env : Fin m → M.carrier) :
    (VVecEA_m.tt m).holds M atomMap env := by
  refine ⟨_, List.mem_singleton.mpr rfl, ?_, ?_⟩
  · intro j; exact TemporalPred.eval_at_top M atomMap (env j)
  · intro j
    exact (BracketFormula.trivial_holds M atomMap TemporalPred.top _ _).mpr
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y)

/-- The constant-`⊥` `VVecEA_m m`: the empty disjunction. Holds on no environment. -/
def VVecEA_m.ff (m : Nat) : VVecEA_m m := { disjuncts := [] }

theorem VVecEA_m.ff_not_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (env : Fin m → M.carrier) :
    ¬ (VVecEA_m.ff m).holds M atomMap env := by
  rintro ⟨vea, hmem, _⟩
  simp only [VVecEA_m.ff] at hmem
  exact (List.not_mem_nil) hmem

/-! ## Atom case: single endpoint predicate -/

/-- The atom `VVecEA_m m` for predicate `p` at free variable `i`: a single
    endpoint predicate `atom_literal ... p true` at position `i`, `⊤` elsewhere. -/
noncomputable def VVecEA_m.atomAt {sig : MonadicSignature} {m : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ q : sig.preds, ∃ a : Atom, atomMap (.atom a) = q)
    (p : sig.preds) (i : Fin m) : VVecEA_m m :=
  (VecEA_m.liftEndpoint i ⟨atom_literal atomMap h_surj p true⟩).toVVecEA_m

theorem VVecEA_m.atomAt_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ q : sig.preds, ∃ a : Atom, atomMap (.atom a) = q)
    (p : sig.preds) (i : Fin m) (env : Fin m → M.carrier) :
    (VVecEA_m.atomAt atomMap h_surj p i).holds M atomMap env ↔
    M.interp p (env i) := by
  rw [VVecEA_m.atomAt, VecEA_m.toVVecEA_m_holds, VecEA_m.liftEndpoint_holds]
  simp only [TemporalPred.eval_at]
  rw [atom_literal_correct M atomMap h_surj p true (env i)]
  simp

end Bimodal.Metalogic.WeakCanonical.Kamp
