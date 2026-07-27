import FormalSystem.Metalogic.WeakCanonical.NormalForm
import FormalSystem.Metalogic.WeakCanonical.PriorDefs
import FormalSystem.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# NF Existential to Temporal Formula (Restructured)

Converts depth-(k+1) arity-2 NF existentials to temporal formulas,
working directly with NormalForm types rather than through MonadicFormula.

## Architecture

The previous `fo_to_temporal` / `fo_to_temporal_correct` are eliminated.
They had a blanket sorry over all `MonadicFormula sig 1`. The new sorry
is strictly narrower: it applies only to depth-(k+1) arity-2 NF
existentials, which is the exact form needed by the combined induction
in NfExistTL.lean.

The sorry at `nf_exist_to_temporal_correct` is now self-contained and
does not depend on any translation of arbitrary MonadicFormula. The
proof obligation decomposes into:

1. **Atom layer** (depth-0 conditions on (x,t)): handled sorry-free
   by VecEA2 zone decomposition (NfToVecEA.lean, VecEADecomp.lean).
2. **Quantifier layer** (depth-k arity-3 existentials): the arity tower
   barrier. At depth 0, these are handled sorry-free by VecEADecomp.lean.
   At depth > 0, they require Rabinovich Lemma 3.2 (arity reduction).

## Future work

To resolve the remaining sorry, implement:
- `nf_3var_exist_depth0_tl`: wire VecEADecomp zone theorems into a
  temporal formula for depth-0 arity-3 existentials (all pieces exist).
- `nf_3var_exist_succ_tl`: generalized arity reduction for depth > 0.
- Compose: atom layer + quantifier layer + outer ∃ x.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 4.3
- Rabinovich 2014, Lemma 3.2 (arity reduction)
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Helper: atom formula for predicate p -/

/-- The temporal formula that captures `M.interp p t` for a predicate p. -/
noncomputable def predFormula {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (p : sig.preds) : Formula :=
  Formula.atom (Classical.choose (h_surj p))

/-- Correctness of `predFormula`. -/
theorem predFormula_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (p : sig.preds) (t : M.carrier) :
    temporal_truth M atomMap t (predFormula atomMap h_surj p) ↔ M.interp p t := by
  simp only [predFormula, temporal_truth]
  rw [Classical.choose_spec (h_surj p)]

/-! ## Bridge: NF existential to temporal formula

Converts a depth-(k+1) arity-2 NF existential to a temporal formula.
Works directly with NormalForm types, bypassing MonadicFormula entirely.

The existential `∃ x, nf_eval_nf M (k+1) 2 (x::t) sub_nf` decomposes into:
- **Atom layer**: `∀ a : AtomKind sig 2, atom_eval M (x::t) a ↔ sub_nf.1 a`
  This determines the order zone (x < t, t < x, x = t) and predicate conditions.
- **Quantifier layer**: `∀ snf3, (∃ y, nf_eval_nf M k 3 (y,x,t) snf3) ↔ sub_nf.2 snf3`
  Each arity-3 existential needs a temporal characterization on the pair (x,t).

The atom layer is handled sorry-free by VecEA2 infrastructure. The quantifier
layer at depth 0 is handled sorry-free by VecEADecomp.lean zone theorems.
At depth > 0, the quantifier layer requires Rabinovich Lemma 3.2. -/

/-- Existence of a temporal formula for the depth-(k+1) arity-2 NF existential.

    This is the localized sorry that replaces the deleted `fo_to_temporal_correct`.
    The scope is strictly narrower:
    - **Old**: all `MonadicFormula sig 1` (atoms, ¬, ∧, <, ∃, ∀)
    - **New**: depth-(k+1) arity-2 NF existentials only

    The proof obligation further decomposes into the atom layer (sorry-free)
    and the quantifier layer (arity-3 existentials, sorry at depth > 0). -/
private theorem nf_exist_to_temporal_aux
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (sub_nf : NormalForm sig (k + 1) 2) :
    ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t A ↔
      ∃ x : M.carrier, nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf := by
  -- The existential ∃ x, nf_eval_nf M (k+1) 2 (x::t) sub_nf unfolds to:
  -- ∃ x, [∀ a, atom_eval M (x::t) a ↔ sub_nf.1 a] ∧
  --      [∀ snf3, (∃ y, nf_eval_nf M k 3 (y,x,t) snf3) ↔ sub_nf.2 snf3]
  --
  -- Decomposition into solvable components:
  -- 1. Atom layer (sub_nf.1): determines zone (x<t, t<x, x=t) and predicates.
  --    Each zone is a VecEA2 condition → sorry-free temporal formula.
  -- 2. Quantifier layer (sub_nf.2): each snf3 gives an arity-3 existential.
  --    At k=0: VecEADecomp zone decomposition (sorry-free).
  --    At k>0: requires Rabinovich Lemma 3.2 (arity reduction).
  -- 3. Composition: combining (1) and (2) under the outer ∃ x requires
  --    showing the combined condition is a VecEA2-like temporal formula.
  --
  -- The sorry here is strictly narrower than `fo_to_temporal_correct`:
  -- it covers only NF existentials of specific depth and arity, not all
  -- first-order formulas.
  sorry

/-- Convert a depth-(k+1) arity-2 NF existential to a temporal formula.

    The formula is built from the NF structure directly, without going
    through MonadicFormula. -/
noncomputable def nf_exist_to_temporal {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (sub_nf : NormalForm sig (k + 1) 2) : Formula :=
  (nf_exist_to_temporal_aux atomMap h_surj sub_nf).choose

/-- Correctness of the NF existential bridge.

    Depends only on `nf_exist_to_temporal_aux` (localized to depth-(k+1)
    arity-2 NF existentials), not on the deleted `fo_to_temporal_correct`
    which covered all `MonadicFormula sig 1`. -/
theorem nf_exist_to_temporal_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (sub_nf : NormalForm sig (k + 1) 2)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (nf_exist_to_temporal atomMap h_surj sub_nf) ↔
    ∃ x : M.carrier, nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf :=
  (nf_exist_to_temporal_aux atomMap h_surj sub_nf).choose_spec M h_UZ h_SZ t

end Bimodal.Metalogic.WeakCanonical.Kamp
