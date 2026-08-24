import FormalSystem.Boneyard.Kamp.KampWeakCanonical.VecEANormalForm.NegationIndep
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEATranslation
import FormalSystem.Metalogic.WeakCanonical.Kamp.PriorINF
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfToVecEA
import FormalSystem.Metalogic.WeakCanonical.NormalForm
import FormalSystem.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Arity Reduction Infrastructure (Rabinovich 2014, Lemma 3.2(2) and Prop 4.3)

Defines the IsVEA predicate and proves key closure properties, working toward
Rabinovich's Proposition 4.3: every MonadicFormula at any arity is equivalent
to a V-EA formula on Prior structures.

## Status

- `IsVEA` definition: complete
- Existential closure (`isVEA_ex`): complete and sorry-free
- Negation closure at arity 2: requires backward direction of Prop 4.2
  biconditional (neg_2var_vec_ea_indep gives forward only)
- Full `fo_isVEA` (Prop 4.3): blocked on negation closure

## Design

The IsVEA predicate asserts that for each pair (i, j) of free variables with
i < j, there exists a VVecEA2 capturing the formula's behavior projected to
those two variables (other variables existentially quantified):

  v.holds z0 z1 ↔ ∃ env, env i = zi ∧ env j = zj ∧ eval M env phi

### Existential Closure (Proved)

The existential case is trivial: pair (i, j) in `.ex phi` corresponds to pair
(i+1, j+1) in phi (variable 0 is bound). The VVecEA2 from the IH already
existentially quantifies variable 0 in the projection.

### Negation Blocker

At arity 2 (the critical case), the projection is deterministic (env is
determined by z0, z1), so negation requires VVecEA2 negation closure:
  v.holds z0 z1 ↔ eval M ![z0,z1] phi  implies
  neg_v.holds z0 z1 ↔ ¬eval M ![z0,z1] phi

The forward direction (¬eval → neg_v.holds) is `neg_2var_vec_ea_indep_correct`.
The backward direction (neg_v.holds → ¬eval) requires showing that v and neg_v
cannot both hold on the same interval, which is not proved in the current
codebase.

At arity >= 3, the negation is inside the existential projection, making it
a different property from VVecEA2 negation.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 4.3, Lemma 3.2(2)
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## IsVEA Predicate -/

/-- A MonadicFormula at arity m is V-EA on Prior structures if for each pair
    (i, j) with i < j, there exists a VVecEA2 capturing the existential
    projection to that pair. At arities 0 and 1, this is vacuously true
    (no pairs i < j exist). -/
def IsVEA {sig : MonadicSignature} {m : Nat}
    (atomMap : Formula → sig.preds) (phi : MonadicFormula sig m) : Prop :=
  ∀ (i j : Fin m), i < j →
    ∃ (v : VVecEA2),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (zi zj : M.carrier) (h_lt : zi < zj),
        v.holds M atomMap zi zj ↔
        ∃ (env : Fin m → M.carrier),
          env i = zi ∧ env j = zj ∧ eval M env phi

/-! ## Existential Closure (Lemma 3.2(2) core) -/

/-- **Existential closure of IsVEA**: if phi is IsVEA at arity m+1, then
    `.ex phi` is IsVEA at arity m. The VVecEA2 for pair (i, j) in `.ex phi`
    is the same as the VVecEA2 for pair (i+1, j+1) in phi, since the bound
    variable (De Bruijn index 0) is already existentially quantified in
    the pair projection.

    This is the key lemma that prevents the arity tower: quantifier
    introduction does not require building new V-EA infrastructure. -/
theorem isVEA_ex {sig : MonadicSignature} {m : Nat}
    {atomMap : Formula → sig.preds}
    {phi : MonadicFormula sig (m + 1)}
    (h : IsVEA atomMap phi) : IsVEA atomMap (.ex phi) := by
  intro i j h_lt
  have h_lt' : i.succ < j.succ := Fin.succ_lt_succ_iff.mpr h_lt
  obtain ⟨v, hv⟩ := h i.succ j.succ h_lt'
  refine ⟨v, fun M h_UZ h_SZ zi zj h_lt_zizj => ?_⟩
  rw [hv M h_UZ h_SZ zi zj h_lt_zizj]
  simp only [eval]
  constructor
  · -- Forward: ∃env' at arity m+1 → ∃env at arity m with ∃x
    rintro ⟨env', h_ei, h_ej, h_eval⟩
    exact ⟨fun k => env' k.succ, h_ei, h_ej, env' 0, by
      convert h_eval using 2; funext ⟨k, _⟩; cases k <;> rfl⟩
  · -- Reverse: ∃env at arity m with ∃x → ∃env' at arity m+1
    rintro ⟨env, h_ei, h_ej, x, h_eval⟩
    exact ⟨(Fin.cons x env : Fin (m + 1) → M.carrier), h_ei, h_ej, h_eval⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
