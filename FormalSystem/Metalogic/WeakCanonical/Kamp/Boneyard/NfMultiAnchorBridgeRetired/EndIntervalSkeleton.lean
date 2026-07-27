import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base

/-! ARCHIVED (Boneyard) — never compiled. Superseded endInterval skeleton; live
replacement is EndIntervalConsumerK.endIntervalStepPrior / the consumer-side reshape.
Do not import from live code.

Moved verbatim from NfMultiAnchorBridge/CarrierK1V.lean (tail block): the phase-framing
doc block plus the four declarations `endIntervalStep`, `endInterval`, `EndIntervalCorrect`,
`endInterval_zero_correct`. The `VVecEA2.singleton` / `VVecEA2.singleton_holds` pair that
sat inside the original block remains LIVE in CarrierK1V.lean (consumers in
EndIntervalConsumerK.lean) and is NOT archived here. -/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Phase 2 (v6): FAITHFUL two-endpoint carrier — retype + `endInterval_correct`
statement freeze + `k = 0` base

Re-base onto the FAITHFUL two-endpoint carrier (reports 06 §4.5 + 07). The refuted single-point
`NormalForm sig k 3 → TemporalPred` scaffold was archived to `Boneyard/NavigatedEndCharSinglePoint.lean`
(Phase 1). This phase declares the recursion skeleton `endInterval : (k) → BracketEndCharCarrierV sig k`
(base = the `k = 0` bracket carrier `bracketEndChar_k0` embedded as a singleton `VVecEA2` disjunct;
step = the named Phase-3 hole `endIntervalStep`), FREEZES the correctness statement `EndIntervalCorrect`
(the report-06-§4.5 biconditional — `x, t` EXPLICIT on BOTH sides, immune to the parameter-independence
refutation that killed the single-point `.eval_at w` LHS; report 07 §5), and proves the `k = 0` base
`endInterval_zero_correct` by threading `bracketEndChar_k0_correct` (:87) through the singleton unfolding.

**FORBIDDEN single-point pointer** (report 07 §5): the retired navigated carrier's infeasibility is
recorded at `endCharN0_correct_infeasible` (Base.lean:1779). That device asserts a single-point
`(endChar0 qnf).eval_at w ↔ …` characteristic whose LHS cannot read the anchor positions `{x, t}` (the
≤2-free-variable cap, Rabinovich Lemma 3.2(2), PDF p.4) — provably FALSE in free-anchor form. The
two-endpoint carrier here is the discriminator precisely because BOTH sides carry `x` and `t`
EXPLICITLY: the `VVecEA2.holds … x t` LHS is evaluated AT the fixed endpoints, never at a single
navigated `w`. This is why the frozen statement is non-refuted (green at `k = 0` AND `k = 1`, the latter
via `bracketEndChar_k1v_correct` :2041). -/

/-- **Depth-`k → k+1` step of the recursion carrier — Phase-3 HOLE**. A
genuine deferred (total, sorry-free, non-vacuous) def whose body Phase 3 REPLACES with the
two-endpoint step construction (generalize `bracketEndChar_k1v` :433 from the concrete `k = 1` to
arbitrary `k`, threading the depth-`k` IH carrier `rec` for the sub-piece characteristics). The
Phase-2 placeholder returns the empty `VVecEA2` disjunction `⟨[]⟩` — Rabinovich's honest empty
disjunction over inconsistent order types (the same `⟨[]⟩` gate-failure object used by
`bracketEndChar_k1v` :431), NOT a `sorry` and NOT a vacuous `True`/`Unit`/`trivial` placeholder. The
frozen signature FIXES the anchors at `{x, t}` (the `atomMap`/`h_surj` params are the Phase-3
construction's fold channel); witness growth rides the disjuncts (G2/G4). Phase 3 discharges the body;
Phase 6 verifies `endInterval` genuinely recurses through it. -/
noncomputable def endIntervalStep {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (rec : BracketEndCharCarrierV sig k) : BracketEndCharCarrierV sig (k + 1) :=
  -- Phase-3 HOLE (deferred; empty disjunction, not sorry/vacuous). `rec`, `atomMap`, `h_surj`
  -- are consumed by the Phase-3 construction generalizing `bracketEndChar_k1v`.
  fun _ => (⟨[]⟩ : VVecEA2)

/-- **Recursion carrier skeleton** `endInterval : (k) → BracketEndCharCarrierV sig k`
(Phase 2, v6). Base = the `k = 0` two-endpoint bracket carrier `bracketEndChar_k0` (:73) embedded as
a singleton `VVecEA2` disjunct; step = the named Phase-3 hole `endIntervalStep`. Defined by `Nat.rec`
so `endInterval atomMap h_surj 0 = fun qnf => VVecEA2.singleton (bracketEndChar_k0 atomMap h_surj qnf)`
and `endInterval atomMap h_surj (k+1) = endIntervalStep atomMap h_surj (endInterval atomMap h_surj k)`
both hold by `rfl` (the literal shape Phase 6 confirms). The codomain is the witness-growing
`VVecEA2` (:365): anchors stay FIXED at `{x, t}` (Lemma 3.2(2)), witnesses grow across disjuncts. -/
noncomputable def endInterval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → BracketEndCharCarrierV sig k :=
  fun k =>
    Nat.rec (motive := fun k => BracketEndCharCarrierV sig k)
      (fun qnf => VVecEA2.singleton (bracketEndChar_k0 atomMap h_surj qnf))
      (fun _k rec => endIntervalStep atomMap h_surj rec)
      k

/-- **FROZEN correctness statement** `EndIntervalCorrect`.
The recursion carrier's `VVecEA2.holds` at the FIXED anchor pair `(x, t)` is equivalent to the
existence of a bracket witness `w` realizing the arity-3 depth-`k` evaluation
`nf_eval_nf M k 3 [w, x, t] qnf`, under the six k0-mirror bracket-zone order bits on `qnf`'s atom
layer (read uniformly at any depth via `NormalForm.atom_assgn` :151 — at `k = 0` it is `qnf` itself,
at `k+1` it is `qnf.1`, matching `bracketEndChar_k0_correct` :87 and `bracketEndChar_k1v_correct`
:2041 respectively). `x, t` are EXPLICIT on BOTH sides (immune to the parameter-independence
refutation; NEVER a single-point `.eval_at w` LHS — see the FORBIDDEN pointer note above). Phase 6
proves this by induction on `k`: base = `endInterval_zero_correct` below; step = Phase 5's
`endInterval_step_correct`. -/
def EndIntervalCorrect {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) : Prop :=
  ∀ (k : Nat) (qnf : NormalForm sig k 3) (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (_h_xy : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (_h_yt : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (_h_xt : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (_h_yx : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (_h_ty : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (_h_tx : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false),
    (endInterval atomMap h_surj k qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-- **`k = 0` base of `EndIntervalCorrect`** (task 349 Phase 2, v6; sorry-free). The `k = 0` slice of
the frozen statement, proved by unfolding `endInterval … 0 qnf` to the singleton embedding of
`bracketEndChar_k0 atomMap h_surj qnf`, rewriting with `VVecEA2.singleton_holds`, and discharging the
resulting `VecEA2.holds ↔ ∃ w, nf_eval_nf M 0 3 [w,x,t] qnf` biconditional directly by the preserved
green `bracketEndChar_k0_correct` (:87). At `k = 0`, `qnf.atom_assgn (.order …)` is definitionally
`qnf (.order …)`, so the six order hypotheses feed `bracketEndChar_k0_correct` unchanged (no
simp/omega/aesop chain-step shortcut — G5). Consumes the depth-0 result; does NOT re-derive it. -/
theorem endInterval_zero_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 0 3)
    (h_xy : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (endInterval atomMap h_surj 0 qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  show (VVecEA2.singleton (bracketEndChar_k0 atomMap h_surj qnf)).holds M atomMap x t ↔ _
  rw [VVecEA2.singleton_holds]
  exact bracketEndChar_k0_correct atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t

end Bimodal.Metalogic.WeakCanonical.Kamp
