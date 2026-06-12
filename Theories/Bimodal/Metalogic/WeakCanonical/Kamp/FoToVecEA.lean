import Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosureProp42
import Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure

/-!
# FO-to-VecEA Bridge (Rabinovich 2014, Prop 4.3 + NF correspondence)

Establishes the bridge between NormalForm evaluation and the vec-EA framework.
This is the critical link enabling Phase 6 to replace P2(k+1) backward
direction with the VecEA approach.

## Mathematical Content

The key bridge theorem states: given temporal characterizations of 1-var NFs
(P1(k+1)), the 2-variable NF existence predicate
  `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`
is expressible as a VVecEA2 formula.

Combined with VVecEA2.translateLeft_correct (Prop 3.5), this gives a temporal
formula for each 2-var NF existential, which is P2(k+1).

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 4.3 (p. 6)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## TemporalPred construction from NF characterizations

Build TemporalPred values from NF characterization formulas. These encode
point-type and interval conditions needed for the VecEA construction. -/

/-- Construct a TemporalPred from a characterization formula. -/
def nfCharPred (char_f : Formula) : TemporalPred := ⟨char_f⟩

/-- The nfCharPred evaluates correctly. -/
theorem nfCharPred_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (char_f : Formula) (t : M.carrier) :
    (nfCharPred char_f).eval_at M atomMap t ↔ temporal_truth M atomMap t char_f :=
  Iff.rfl

/-! ## Endpoint TemporalPred from atom assignments

For the 2-var NF existence, the endpoint predicates at the free variable t
are determined by `parent_atoms`. We construct a TemporalPred that tests
whether t satisfies the parent atom assignment. -/

/-- Construct a TemporalPred that tests a conjunction of atom conditions at
    a point. Encodes `∀ p, M.interp p t ↔ pa(.pred p 0) = true` as a single
    TemporalPred using the conjunction of atom literals. -/
noncomputable def atomsPred {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (pa : AtomKind sig 1 → Bool) : TemporalPred :=
  let preds := (Fintype.elems (α := sig.preds)).val.toList
  let conjuncts := preds.map fun p =>
    let atom := Classical.choose (h_surj p)
    if pa (.pred p ⟨0, by omega⟩) then
      Formula.atom atom
    else
      (Formula.atom atom).neg
  ⟨formula_conjList conjuncts⟩

/-! ## Bridge Strategy: NF Existence to VVecEA2

The bridge from NF existence to VVecEA2 follows this structure:

For `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`:

1. **Order case analysis**: nf_order_dir sub_nf determines x < t (Since),
   x > t (Until), or x = t (trivial)

2. **For each compatible nf_x** (1-var NF of witness x):
   - endpointLeft = atomsPred parent_atoms (t's atoms)
   - endpointRight = nfCharPred (char_kp1 nf_x) (x's 1-var NF)
   - bracket witnesses = interval witnesses from sub_nf.2

3. **Interval witnesses**: For each ssn with sub_nf.2(ssn) = true and
   ssn involving a witness y in the interval between t and x:
   - Point type at y = nfCharPred (char_kp1 nf_y) for compatible nf_y
   - The bracket formula existentially quantifies over y's

4. **Disjunction over nf_x**: The VVecEA2 is a disjunction over all
   compatible nf_x values (finitely many)

The key insight: by P1(k+1), all 1-var NF characterizations are temporal
(TemporalPred), so the resulting VVecEA2 can be translated to TL(U,S)
via VVecEA2.translateLeft_correct (Prop 3.5).

### Equivalence proof strategy

Forward (∃ x, nf_eval → VVecEA2.holdsLeft):
- Given x with nf_eval_nf, determine nf_x = nf_characteristic M (k+1) 1 x
- Use char_kp1_correct to show endpointRight holds at x
- Extract interval witnesses from sub_nf.2 quantifier conditions
- Use char_kp1_correct for interval witness point types

Backward (VVecEA2.holdsLeft → ∃ x, nf_eval):
- VVecEA2.holdsLeft gives z1 > t with endpointRight at z1 and bracket witnesses
- endpointRight gives nf_eval_nf for x = z1 (1-var NF)
- Bracket witnesses give interval witnesses for quantifier conditions
- Key: 3-var NF at (y, x, t) follows from 1-var NFs of y, x, t plus
  the ordering constraints (no composition lemma needed because the
  VecEA2 encodes ALL conditions, not just the forward-extractable ones)

### Critical difference from failed approach

The failed nf_exist_formula_nested_backward tried to RECOVER the 3-var NF
from the 1-var NFs via composition. The VecEA2 approach instead ENCODES
the 3-var NF conditions directly as TemporalPreds, so recovery is trivial.
-/

end Bimodal.Metalogic.WeakCanonical.Kamp
