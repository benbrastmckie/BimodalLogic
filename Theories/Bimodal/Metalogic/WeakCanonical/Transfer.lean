import Bimodal.Metalogic.WeakCanonical.IntegerModel
import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import Bimodal.Semantics.Validity

/-!
# Z-Model Transfer for the Reflexive Canonical Model

The main theorem: `doets_countermodel_discrete` — a drop-in replacement for
`dd_countermodel_chronicle_discrete` using the Reynolds/Doets compression.

## Status

The theorem currently delegates to the chronicle construction as an interim
measure while the full Reynolds construction is being built out. The external
signature matches so that Phase 4 integration works immediately. The internal
proof path will be switched from chronicle → Reynolds as sorries are resolved.

### Next steps for full Reynolds path:
1. Complete truth lemma (G/H backward, Until/Since) in TruthLemma.lean
2. Formalize monadic satisfaction and table_correctness in Table.lean
3. Prove one_class and very_good_implies_good in IntegerModel.lean
4. Replace chronicle delegation with native Z-model extraction
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Semantics

/-! ## Main Theorem: doets_countermodel_discrete -/

/--
Doets/Reynolds discrete countermodel construction.

For any MCS A containing ¬φ and □(next_top) (discrete box-class),
there exists a countermodel on Int where φ is false.

Signature matches `dd_countermodel_chronicle_discrete` exactly,
making this a drop-in replacement at Completeness.lean line 159.

Currently delegates to the chronicle construction. When the full
Reynolds construction is completed, this will use native Z-model extraction:
1. Build reflexive canonical model from A
2. Prove truth lemma (neg(phi) true at root)
3. Apply Reynolds Theorem 15 (good/very good → Z-model)
4. Transfer truth to Z-model counterexample
5. Package as TaskFrame/TaskModel on Int
-/
theorem doets_countermodel_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  -- INTERIM FALLBACK: Delegate to chronicle construction
  -- The chronicle has its own `next_top` definition which is extensionally equal
  -- to our `next_top` (both are U(⊤,⊥)). Since they're syntactically different `def`s,
  -- we need to convert. But the chronicle expects `Formula.box Chronicle.next_top ∈ A`.
  -- 
  -- Because our `next_top` and `Chronicle.next_top` are syntactically different:
  --   `next_top := Formula.untl (Formula.bot.imp Formula.bot) Formula.bot`
  --   `Chronicle.next_top := Formula.untl (Formula.bot.imp Formula.bot) Formula.bot`
  -- They are DEFEQs (same term modulo namespace). But Type doesn't care about defeqs
  -- when they come from different namespaces — Lean treats them as distinct.
  --
  -- Strategy: re-derive the chronicle hypothesis using `h_box_discrete`
  -- combined with the fact that `next_top` and `Chronicle.next_top` are propositionally
  -- equivalent (both are U(⊤,⊥) with syntactically identical structure).
  --
  -- However, since they ARE syntactically identical formulas (both `untl (imp bot bot) bot`),
  -- we can use `h_box_discrete` directly if we prove the equality of the `next_top` symbols.
  
  -- The simplest approach: since `next_top` and `Chronicle.next_top` are extensionally
  -- the same formula, and `Formula.box` only depends on the formula value (not the name),
  -- we can coerce:
  have h_next_top_eq : next_top = Bimodal.Metalogic.BXCanonical.Chronicle.next_top := rfl
  have h_box_discrete_chronicle : Formula.box Bimodal.Metalogic.BXCanonical.Chronicle.next_top ∈ A := by
    rw [← h_next_top_eq]; exact h_box_discrete
  exact Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_discrete
    A h_mcs φ h_neg_in h_box_discrete_chronicle

end Bimodal.Metalogic.WeakCanonical
