/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAConjFull
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregatePointMergeK1
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNavPastK1
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNavFutK1
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregateHookDischarge

/-! # Off-diagonal k=1 aggregate: zone classifier + per-qnf dispatcher `C(qnf)`

The integration point over all channels of the k=1 population existential
`∃ w, NfEvalNf M 1 3 [w, x, t] qnf` at the off-diagonal pin pair `x < t`
(env `[w, x, t]`: position 0 = the population witness `w`, positions 1, 2 = the
pins `x`, `t` — the Phase-16a dispatcher convention fixed by ExteriorNavFutK1).

## Rabinovich anchor

**Cor 5.4 "all order patterns"** (chunks 0014-0015): the population match ranges over
every order pattern of the witness `w` against the pins. Given the ambient `x < t`, the
consistent patterns are exactly `w<x`, `w=x`, `x<w<t`, `w=t`, `t<w`; every other
order-bit row of `qnf.1` is unrealizable (the 3-bot channel). The interior channel's
`endInterval_correct`-style consumer is the delivered UZ/SZ-relativized rung
`bracketEndChar_kv_correct_one_prior` (PriorInterface.lean:95; see also the recursion
consumer `endIntervalPrior_correct_le_one`, EndIntervalConsumerK.lean).

## Structure

1. **Zone-classifier rows** (past arm, ambient `x < t`): the six-bit order rows of
   `qnf.1` for the five consistent witness positions — `navDOrderRow` (w<x<t, delivered),
   `aggOdRowPtX` (w=x), `aggOdRowInt` (x<w<t), `aggOdRowPtT` (w=t), `navROrderRow`
   (x<t<w, delivered) — plus the eval-forcing lemmas (any realizer forces the row of its
   witness position) and the routing totality `aggOdZone3_route_of_eval`.
2. **Classifier** `aggOdClassify : NormalForm sig 1 3 → AggOdZone3` (6 constructors;
   total by construction) + the row → constructor lemmas (each uses the pairwise one-bit
   clashes, so every qnf routes to EXACTLY one channel) + the 3-bot falsity
   `aggOdZone3_bot_eval_false`.
3. **Mirror classification for the future arm** (ambient `t < x`): mirror rows
   `aggOdRow*F`, mirror classifier `aggOdClassifyF`, mirror routing
   `aggOdZone3F_route_of_eval`. (The mirror DISPATCHER/carrier is Phase 16b's
   record-decision territory; only the classification lands here, per the plan.)
4. **Two-pin reading of the delivered `agg2Past` carrier**: `agg2Past_holds_pin_iff` —
   the pointwise 2-pin semantics `(agg2Past sub_nf).holds M atomMap x t ↔
   NfEvalNf M 1 2 [x, t] sub_nf` under the ambient `x < t` (the fixed-endpoint
   companion of the delivered `agg2Past_holdsRight_iff`; same fiber algebra, pins fixed).
5. **Point-channel carriers** `CAggPtX`/`CAggPtT`: the Phase-12a/12b gated collapses
   (`aggPm01ClauseK1`/`aggPm02ClauseK1` shapes) realized as `VVecEA2` via `agg2Past` on
   the collapsed arity-2 NF; non-fixpoint qnf gate to the empty disjunction.
6. **Interior channel** `CAggInt`: the delivered carrier `bracketEndCharKv` at depth 1
   with `charF 0 := nfDepth0CharFormula atomMap h_surj` (`h0 := rfl`), consumed
   through `bracketEndChar_kv_correct_one_prior`.
7. **Dispatcher** `CAggOd (qnf) : VVecEA2` casing on the classifier rows, and the master
   **clause iff** `CAggOd_clause_iff`: under `x < t` and the Prior hypotheses,
   `(CAggOd qnf).holds M atomMap x t ↔ ∃ w, NfEvalNf M 1 3 [w, x, t] qnf` — every
   channel discharged by its delivered carrier iff (exteriors via
   `CExtPast_correct`/`CExtFut_correct`; 3-bot via the routing + falsity lemmas).

## Guards

G1 — the population obligation stays arity-3; each channel's collapse/fold is the
delivered lossless one. G2/G4 — anchors exactly `{x, t}` (+ the bracket witness `w`).
G5 — every bridge is a manual `constructor`/`intro`/`exact` step. FORBIDDEN
`nf_char3_deeper_split` is not referenced. No frozen file is touched.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Cor 5.4 (chunks 0014-0015); Lemma 3.2(2)
  coincident-witness collapse (chunk_0009); Lemma 7.6 gluing (chunk_0021).
- The negfix-refactor design for the exterior carriers, Phase 16a: the dispatcher convention
  and channel split restated in the Structure section above.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

section AggregateOffDiag

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
variable (atomMap : Formula → sig.preds)
variable (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)

/-! ## 1. Zone-classifier rows (past arm, ambient `x < t`)

Order-bit rows of `qnf.1` at env `[w, x, t]`. The exterior rows are the delivered
`navDOrderRow` (`w < x < t`, ExteriorNavPastK1.lean:841) and `navROrderRow`
(`x < t < w`, ExteriorNavFutK1.lean:1246). The three new rows below cover the point
and interior positions. Conjunct ORDER is load-bearing: `aggOdRowInt`'s conjuncts are
exactly the six hypotheses of `bracketEndChar_kv_correct_one_prior` in order. -/

/-- **The `w = x` point row** (`w = x < t`): the six order bits of `qnf.1` forced by a
    coincident witness at the left pin. Conjunct order: (0,1)F, (1,0)F, (0,2)T, (2,0)F,
    (1,2)T, (2,1)F. -/
def aggOdRowPtX (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false

/-- **The interior row** (`x < w < t`): the six order bits of `qnf.1` forced by an
    interior witness. Conjunct order matches the six hypotheses of
    `bracketEndChar_kv_correct_one_prior` VERBATIM: h_xy=(1,0)T, h_yt=(0,2)T,
    h_xt=(1,2)T, h_yx=(0,1)F, h_ty=(2,0)F, h_tx=(2,1)F. -/
def aggOdRowInt (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false

/-- **The `w = t` point row** (`x < t = w`): the six order bits of `qnf.1` forced by a
    coincident witness at the right pin. Conjunct order: (0,2)F, (2,0)F, (1,0)T, (0,1)F,
    (1,2)T, (2,1)F. -/
def aggOdRowPtT (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false

/-- A refuted atom reading forces the bit false (the `navD_atomBit_false` shape,
    re-derived locally per the established idiom — the delivered one is private). -/
private theorem aggOd_bit_false {P : Prop} {b : Bool}
    (h : P ↔ b = true) (hnp : ¬P) : b = false := by
  cases b with
  | false => rfl
  | true => exact absurd (h.mpr rfl) hnp

/-- A Bool cannot be both true and false (row-clash discharge). -/
private theorem aggOd_row_clash {b : Bool} (h1 : b = true) (h2 : b = false) : False := by
  rw [h1] at h2
  exact Bool.noConfusion h2

/-! ### Eval-forcing lemmas: any realizer forces the row of its witness position

Each extracts the atom layer via the delivered fold engine `nf_eval_depth1_fold_iff`
(CarrierKv.lean:466) and reads the six order atoms (`AtomEval M env (.order i j _) =
env i < env j`, definitionally). -/

/-- A past-exterior realizer (`w < x`, ambient `x < t`) forces `navDOrderRow`. -/
theorem aggOd_navDRow_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w x t : M.carrier) (hwx : w < x) (hxt : x < t)
    (h : NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
    navDOrderRow σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold navDOrderRow
  exact ⟨(hlayer _).mp hwx, (hlayer _).mp (hwx.trans hxt), (hlayer _).mp hxt,
    aggOd_bit_false (hlayer _) (lt_asymm hwx),
    aggOd_bit_false (hlayer _) (lt_asymm (hwx.trans hxt)),
    aggOd_bit_false (hlayer _) (lt_asymm hxt)⟩

/-- A coincident-left realizer (`w = x`, env `[x, x, t]`, ambient `x < t`) forces
    `aggOdRowPtX`. -/
theorem aggOd_rowPtX_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) (hxt : x < t)
    (h : NfEvalNf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) σ) :
    aggOdRowPtX σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold aggOdRowPtX
  exact ⟨aggOd_bit_false (hlayer _) (lt_irrefl x),
    aggOd_bit_false (hlayer _) (lt_irrefl x),
    (hlayer _).mp hxt,
    aggOd_bit_false (hlayer _) (lt_asymm hxt),
    (hlayer _).mp hxt,
    aggOd_bit_false (hlayer _) (lt_asymm hxt)⟩

/-- An interior realizer (`x < w < t`) forces `aggOdRowInt`. -/
theorem aggOd_rowInt_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
    aggOdRowInt σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold aggOdRowInt
  exact ⟨(hlayer _).mp hxw, (hlayer _).mp hwt, (hlayer _).mp (hxw.trans hwt),
    aggOd_bit_false (hlayer _) (lt_asymm hxw),
    aggOd_bit_false (hlayer _) (lt_asymm hwt),
    aggOd_bit_false (hlayer _) (lt_asymm (hxw.trans hwt))⟩

/-- A coincident-right realizer (`w = t`, env `[t, x, t]`, ambient `x < t`) forces
    `aggOdRowPtT`. -/
theorem aggOd_rowPtT_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) (hxt : x < t)
    (h : NfEvalNf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) σ) :
    aggOdRowPtT σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold aggOdRowPtT
  exact ⟨aggOd_bit_false (hlayer _) (lt_irrefl t),
    aggOd_bit_false (hlayer _) (lt_irrefl t),
    (hlayer _).mp hxt,
    aggOd_bit_false (hlayer _) (lt_asymm hxt),
    (hlayer _).mp hxt,
    aggOd_bit_false (hlayer _) (lt_asymm hxt)⟩

/-- A future-exterior realizer (`t < w`, ambient `x < t`) forces `navROrderRow`. -/
theorem aggOd_navRRow_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w x t : M.carrier) (hxt : x < t) (htw : t < w)
    (h : NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
    navROrderRow σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold navROrderRow
  exact ⟨(hlayer _).mp hxt, (hlayer _).mp (hxt.trans htw), (hlayer _).mp htw,
    aggOd_bit_false (hlayer _) (lt_asymm (hxt.trans htw)),
    aggOd_bit_false (hlayer _) (lt_asymm htw),
    aggOd_bit_false (hlayer _) (lt_asymm hxt)⟩

/-- **Routing totality** (Cor 5.4 "all order patterns", past arm): under the ambient
    `x < t`, every realizer of the k=1 population at `[w, x, t]` routes its `qnf` to
    exactly the row of the witness position — the five consistent order patterns of `w`
    against the pins. -/
theorem aggOdZone3_route_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w x t : M.carrier) (hxt : x < t)
    (h : NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
    (w < x ∧ navDOrderRow σ) ∨ (w = x ∧ aggOdRowPtX σ) ∨
    (x < w ∧ w < t ∧ aggOdRowInt σ) ∨ (w = t ∧ aggOdRowPtT σ) ∨
    (t < w ∧ navROrderRow σ) := by
  rcases lt_trichotomy w x with hwx | rfl | hxw
  · exact Or.inl ⟨hwx, aggOd_navDRow_of_eval M σ w x t hwx hxt h⟩
  · exact Or.inr (Or.inl ⟨rfl, aggOd_rowPtX_of_eval M σ w t hxt h⟩)
  · rcases lt_trichotomy w t with hwt | rfl | htw
    · exact Or.inr (Or.inr (Or.inl
        ⟨hxw, hwt, aggOd_rowInt_of_eval M σ w x t hxw hwt h⟩))
    · exact Or.inr (Or.inr (Or.inr (Or.inl
        ⟨rfl, aggOd_rowPtT_of_eval M σ x w hxt h⟩)))
    · exact Or.inr (Or.inr (Or.inr (Or.inr
        ⟨htw, aggOd_navRRow_of_eval M σ w x t hxt htw h⟩)))

/-! ## 2. The classifier and the exactly-one certificate -/

/-- The six dispatcher channels of the arity-3 population at the off-diagonal pin pair
    (past arm, ambient `x < t`). -/
inductive AggOdZone3 where
  /-- `w < x` past-exterior channel (`CExtPast`) -/
  | extPast
  /-- `w = x` point channel (Phase-12a gated collapse) -/
  | ptX
  /-- `x < w < t` interior channel (`bracketEndCharKv` at depth 1) -/
  | int
  /-- `w = t` point channel (Phase-12b gated collapse) -/
  | ptT
  /-- `t < w` future-exterior channel (`CExtFut`) -/
  | extFut
  /-- order-channel inconsistent: the 3-bot channel -/
  | bot
deriving DecidableEq

open Classical in
/-- **The zone classifier** (total by construction): route `qnf` by its order-bit row.
    The five row patterns are pairwise disjoint (one-bit clashes — see the
    `aggOdClassify_*` lemmas), so the if-chain order is semantically irrelevant: every
    `qnf` routes to EXACTLY one channel. -/
noncomputable def aggOdClassify (σ : NormalForm sig 1 3) : AggOdZone3 :=
  if navDOrderRow σ then .extPast
  else if aggOdRowPtX σ then .ptX
  else if aggOdRowInt σ then .int
  else if aggOdRowPtT σ then .ptT
  else if navROrderRow σ then .extFut
  else .bot

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Row → channel: `navDOrderRow` routes to `extPast`. -/
theorem aggOdClassify_extPast (σ : NormalForm sig 1 3) (h : navDOrderRow σ) :
    aggOdClassify σ = .extPast := by
  unfold aggOdClassify
  rw [if_pos h]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Row → channel: `aggOdRowPtX` routes to `ptX` (clash with `navDOrderRow` on bit
    (0,1)). -/
theorem aggOdClassify_ptX (σ : NormalForm sig 1 3) (h : aggOdRowPtX σ) :
    aggOdClassify σ = .ptX := by
  unfold aggOdClassify
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.1), if_pos h]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Row → channel: `aggOdRowInt` routes to `int` (clashes: (0,1) with `navDOrderRow`,
    (1,0) with `aggOdRowPtX`). -/
theorem aggOdClassify_int (σ : NormalForm sig 1 3) (h : aggOdRowInt σ) :
    aggOdClassify σ = .int := by
  unfold aggOdClassify
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash h.1 hp.2.1), if_pos h]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Row → channel: `aggOdRowPtT` routes to `ptT` (clashes: (0,1) with `navDOrderRow`,
    (1,0) with `aggOdRowPtX`, (0,2) with `aggOdRowInt`). -/
theorem aggOdClassify_ptT (σ : NormalForm sig 1 3) (h : aggOdRowPtT σ) :
    aggOdClassify σ = .ptT := by
  unfold aggOdClassify
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash h.2.2.1 hp.2.1),
    if_neg (fun hi => aggOd_row_clash hi.2.1 h.1), if_pos h]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Row → channel: `navROrderRow` routes to `extFut` (clashes: (0,1) with
    `navDOrderRow`, (0,2) with `aggOdRowPtX`/`aggOdRowInt`, (2,0) with `aggOdRowPtT`). -/
theorem aggOdClassify_extFut (σ : NormalForm sig 1 3) (h : navROrderRow σ) :
    aggOdClassify σ = .extFut := by
  unfold aggOdClassify
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash hp.2.2.1 h.2.2.2.2.1),
    if_neg (fun hi => aggOd_row_clash hi.2.1 h.2.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash h.2.2.1 hp.2.1), if_pos h]

/-- **3-bot falsity**: a `qnf` classified `bot` (all five rows refuted) is unrealizable
    at EVERY witness position under the ambient `x < t` — the routing totality forces
    one of the five rows on any realizer. -/
theorem aggOdZone3_bot_eval_false (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3)
    (h1 : ¬ navDOrderRow σ) (h2 : ¬ aggOdRowPtX σ) (h3 : ¬ aggOdRowInt σ)
    (h4 : ¬ aggOdRowPtT σ) (h5 : ¬ navROrderRow σ)
    (x t : M.carrier) (hxt : x < t) (w : M.carrier) :
    ¬ NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ := by
  intro h
  rcases aggOdZone3_route_of_eval M σ w x t hxt h with
    ⟨-, hr⟩ | ⟨-, hr⟩ | ⟨-, -, hr⟩ | ⟨-, hr⟩ | ⟨-, hr⟩
  · exact h1 hr
  · exact h2 hr
  · exact h3 hr
  · exact h4 hr
  · exact h5 hr

/-! ## 3. Mirror classification for the future arm (ambient `t < x`)

The future arm lays its witness pin `x` ABOVE the origin `t` (`t < x`), so the five
consistent witness positions mirror: `w<t`, `w=t`, `t<w<x`, `w=x`, `x<w`. Only the
CLASSIFICATION lands here; the mirror dispatcher/carrier is Phase 16b's
record-decision territory (plan: "Mirror `aggPop1F` … if the classifier mirror requires
a distinct carrier"). -/

/-- Mirror row `w < t < x`: (0,2)T, (0,1)T, (2,1)T, (2,0)F, (1,0)F, (1,2)F. -/
def aggOdRowExtPastF (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false

/-- Mirror row `w = t < x`: (0,2)F, (2,0)F, (0,1)T, (1,0)F, (2,1)T, (1,2)F. -/
def aggOdRowPtTF (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false

/-- Mirror interior row `t < w < x`: (2,0)T, (0,1)T, (2,1)T, (0,2)F, (1,0)F, (1,2)F. -/
def aggOdRowIntF (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false

/-- Mirror row `t < w = x`: (0,1)F, (1,0)F, (2,0)T, (0,2)F, (2,1)T, (1,2)F. -/
def aggOdRowPtXF (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false

/-- Mirror row `t < x < w`: (1,0)T, (2,0)T, (2,1)T, (0,1)F, (0,2)F, (1,2)F. -/
def aggOdRowExtFutF (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false

/-- Mirror eval-forcing: a `w < t` realizer under ambient `t < x` forces
    `aggOdRowExtPastF`. -/
theorem aggOd_rowExtPastF_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w x t : M.carrier) (hwt : w < t) (htx : t < x)
    (h : NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
    aggOdRowExtPastF σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold aggOdRowExtPastF
  exact ⟨(hlayer _).mp hwt, (hlayer _).mp (hwt.trans htx), (hlayer _).mp htx,
    aggOd_bit_false (hlayer _) (lt_asymm hwt),
    aggOd_bit_false (hlayer _) (lt_asymm (hwt.trans htx)),
    aggOd_bit_false (hlayer _) (lt_asymm htx)⟩

/-- Mirror eval-forcing: a `w = t` realizer (env `[t, x, t]`) under ambient `t < x`
    forces `aggOdRowPtTF`. -/
theorem aggOd_rowPtTF_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) (htx : t < x)
    (h : NfEvalNf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) σ) :
    aggOdRowPtTF σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold aggOdRowPtTF
  exact ⟨aggOd_bit_false (hlayer _) (lt_irrefl t),
    aggOd_bit_false (hlayer _) (lt_irrefl t),
    (hlayer _).mp htx,
    aggOd_bit_false (hlayer _) (lt_asymm htx),
    (hlayer _).mp htx,
    aggOd_bit_false (hlayer _) (lt_asymm htx)⟩

/-- Mirror eval-forcing: a `t < w < x` realizer forces `aggOdRowIntF`. -/
theorem aggOd_rowIntF_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w x t : M.carrier) (htw : t < w) (hwx : w < x)
    (h : NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
    aggOdRowIntF σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold aggOdRowIntF
  exact ⟨(hlayer _).mp htw, (hlayer _).mp hwx, (hlayer _).mp (htw.trans hwx),
    aggOd_bit_false (hlayer _) (lt_asymm htw),
    aggOd_bit_false (hlayer _) (lt_asymm hwx),
    aggOd_bit_false (hlayer _) (lt_asymm (htw.trans hwx))⟩

/-- Mirror eval-forcing: a `w = x` realizer (env `[x, x, t]`) under ambient `t < x`
    forces `aggOdRowPtXF`. -/
theorem aggOd_rowPtXF_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) (htx : t < x)
    (h : NfEvalNf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) σ) :
    aggOdRowPtXF σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold aggOdRowPtXF
  exact ⟨aggOd_bit_false (hlayer _) (lt_irrefl x),
    aggOd_bit_false (hlayer _) (lt_irrefl x),
    (hlayer _).mp htx,
    aggOd_bit_false (hlayer _) (lt_asymm htx),
    (hlayer _).mp htx,
    aggOd_bit_false (hlayer _) (lt_asymm htx)⟩

/-- Mirror eval-forcing: a `t < x < w` realizer forces `aggOdRowExtFutF`. -/
theorem aggOd_rowExtFutF_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w x t : M.carrier) (htx : t < x) (hxw : x < w)
    (h : NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
    aggOdRowExtFutF σ := by
  have hlayer := ((nf_eval_depth1_fold_iff M _ σ).mp h).1
  unfold aggOdRowExtFutF
  exact ⟨(hlayer _).mp hxw, (hlayer _).mp (htx.trans hxw), (hlayer _).mp htx,
    aggOd_bit_false (hlayer _) (lt_asymm hxw),
    aggOd_bit_false (hlayer _) (lt_asymm (htx.trans hxw)),
    aggOd_bit_false (hlayer _) (lt_asymm htx)⟩

open Classical in
/-- **The mirror zone classifier** (future arm, ambient `t < x`; total by
    construction). The five mirror rows are pairwise disjoint (one-bit clashes — see
    `aggOdClassifyF_*`). -/
noncomputable def aggOdClassifyF (σ : NormalForm sig 1 3) : AggOdZone3 :=
  if aggOdRowExtPastF σ then .extPast
  else if aggOdRowPtTF σ then .ptT
  else if aggOdRowIntF σ then .int
  else if aggOdRowPtXF σ then .ptX
  else if aggOdRowExtFutF σ then .extFut
  else .bot

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Mirror row → channel: `aggOdRowExtPastF` routes to `extPast`. -/
theorem aggOdClassifyF_extPast (σ : NormalForm sig 1 3) (h : aggOdRowExtPastF σ) :
    aggOdClassifyF σ = .extPast := by
  unfold aggOdClassifyF
  rw [if_pos h]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Mirror row → channel: `aggOdRowPtTF` routes to `ptT` (clash on bit (0,2)). -/
theorem aggOdClassifyF_ptT (σ : NormalForm sig 1 3) (h : aggOdRowPtTF σ) :
    aggOdClassifyF σ = .ptT := by
  unfold aggOdClassifyF
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.1), if_pos h]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Mirror row → channel: `aggOdRowIntF` routes to `int` (clashes: (0,2) with
    `aggOdRowExtPastF`, (2,0) with `aggOdRowPtTF`). -/
theorem aggOdClassifyF_int (σ : NormalForm sig 1 3) (h : aggOdRowIntF σ) :
    aggOdClassifyF σ = .int := by
  unfold aggOdClassifyF
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash h.1 hp.2.1), if_pos h]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Mirror row → channel: `aggOdRowPtXF` routes to `ptX` (clashes: (0,1) with
    `aggOdRowExtPastF`/`aggOdRowPtTF`, (0,1) with `aggOdRowIntF`). -/
theorem aggOdClassifyF_ptX (σ : NormalForm sig 1 3) (h : aggOdRowPtXF σ) :
    aggOdClassifyF σ = .ptX := by
  unfold aggOdClassifyF
  rw [if_neg (fun hd => aggOd_row_clash hd.2.1 h.1),
    if_neg (fun hp => aggOd_row_clash hp.2.2.1 h.1),
    if_neg (fun hi => aggOd_row_clash hi.2.1 h.1), if_pos h]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Mirror row → channel: `aggOdRowExtFutF` routes to `extFut` (clashes: (0,1)/(1,0)
    with the four earlier rows). -/
theorem aggOdClassifyF_extFut (σ : NormalForm sig 1 3) (h : aggOdRowExtFutF σ) :
    aggOdClassifyF σ = .extFut := by
  unfold aggOdClassifyF
  rw [if_neg (fun hd => aggOd_row_clash hd.2.1 h.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash hp.2.2.1 h.2.2.2.1),
    if_neg (fun hi => aggOd_row_clash hi.2.1 h.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash h.1 hp.2.1), if_pos h]

/-- **Mirror routing totality** (Cor 5.4, future arm): under the ambient `t < x`,
    every realizer of the k=1 population at `[w, x, t]` routes its `qnf` to exactly the
    mirror row of the witness position. -/
theorem aggOdZone3F_route_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w x t : M.carrier) (htx : t < x)
    (h : NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
    (w < t ∧ aggOdRowExtPastF σ) ∨ (w = t ∧ aggOdRowPtTF σ) ∨
    (t < w ∧ w < x ∧ aggOdRowIntF σ) ∨ (w = x ∧ aggOdRowPtXF σ) ∨
    (x < w ∧ aggOdRowExtFutF σ) := by
  rcases lt_trichotomy w t with hwt | rfl | htw
  · exact Or.inl ⟨hwt, aggOd_rowExtPastF_of_eval M σ w x t hwt htx h⟩
  · exact Or.inr (Or.inl ⟨rfl, aggOd_rowPtTF_of_eval M σ x w htx h⟩)
  · rcases lt_trichotomy w x with hwx | rfl | hxw
    · exact Or.inr (Or.inr (Or.inl
        ⟨htw, hwx, aggOd_rowIntF_of_eval M σ w x t htw hwx h⟩))
    · exact Or.inr (Or.inr (Or.inr (Or.inl
        ⟨rfl, aggOd_rowPtXF_of_eval M σ w t htw h⟩)))
    · exact Or.inr (Or.inr (Or.inr (Or.inr
        ⟨hxw, aggOd_rowExtFutF_of_eval M σ w x t htx hxw h⟩)))

/-- **Mirror 3-bot falsity**: a `qnf` with all five mirror rows refuted is
    unrealizable at every witness position under the ambient `t < x`. -/
theorem aggOdZone3F_bot_eval_false (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3)
    (h1 : ¬ aggOdRowExtPastF σ) (h2 : ¬ aggOdRowPtTF σ) (h3 : ¬ aggOdRowIntF σ)
    (h4 : ¬ aggOdRowPtXF σ) (h5 : ¬ aggOdRowExtFutF σ)
    (x t : M.carrier) (htx : t < x) (w : M.carrier) :
    ¬ NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ := by
  intro h
  rcases aggOdZone3F_route_of_eval M σ w x t htx h with
    ⟨-, hr⟩ | ⟨-, hr⟩ | ⟨-, -, hr⟩ | ⟨-, hr⟩ | ⟨-, hr⟩
  · exact h1 hr
  · exact h2 hr
  · exact h3 hr
  · exact h4 hr
  · exact h5 hr

/-! ## 4. Two-pin reading of the delivered `agg2Past` carrier

The point channels collapse (Lemma 3.2(2)) to the fixed-anchor arity-2 evaluation
`NfEvalNf M 1 2 [x, t] sub_nf` — a TWO-PIN object. The delivered `agg2Past` carrier
(AggregateHookDischarge.lean:492) already packages exactly the right fiber content
(endpoint packs at `x`/`t` + interior arrangement bracket + gate); the delivered
correctness `agg2Past_holdsRight_iff` reads it ONE-FREE-VARIABLE (`∃ x < t` folded at
`t`). Here we prove the POINTWISE 2-pin reading at the fixed pair `(x, t)` under the
ambient `x < t` — same fiber algebra, pins fixed (the proof is the delivered one with
the outer `∃x` stripped). -/

/-- **Two-pin correctness of `agg2Past`** (the fixed-endpoint companion of
    `agg2Past_holdsRight_iff`): under the ambient `x < t`, the carrier's 2-pin semantics
    at `(x, t)` is exactly the fixed-anchor arity-2 depth-1 evaluation. -/
theorem agg2Past_holds_pin_iff (sub_nf : NormalForm sig 1 2)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) (hxt : x < t) :
    (agg2Past atomMap h_surj sub_nf).holds M atomMap x t ↔
      NfEvalNf M 1 2 (Fin.cons x (fun _ => t)) sub_nf := by
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (nfDepth0CharFormula atomMap h_surj χ') ↔
      NfEvalNf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  constructor
  · -- Soundness (2-pin holds → the fixed-anchor evaluation).
    intro h
    obtain ⟨vea, hmem, hv⟩ := h
    unfold agg2Past at hmem
    split at hmem
    case isFalse hg => simp at hmem
    case isTrue hg =>
    rw [List.mem_map] at hmem
    obtain ⟨l, hlp, hEq⟩ := hmem
    subst hEq
    obtain ⟨hepL, hepR, hbr⟩ := hv
    -- Unfold the two endpoint conjunction lists.
    simp only [agg2EpPastL, agg2EpPastR, TemporalPred.EvalAt] at hepL hepR
    rw [formula_conjList_iff] at hepL hepR
    -- Heads: the off-diagonal atom loci.
    have hendp : TemporalTruth M atomMap x
        (nfChar2AtomOffdiagEndpoint atomMap h_surj
          (sub_nf.1 : NormalForm sig 0 2)).formula :=
      hepL _ (List.mem_append_left _ List.mem_cons_self)
    have horig : TemporalTruth M atomMap t
        (nfChar2AtomOffdiagOrigin atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)) :=
      hepR _ (List.mem_append_left _ List.mem_cons_self)
    -- Fold-bit literal facts at the two anchors.
    have hPastLit : ∀ χ : NormalForm sig 0 1, TemporalTruth M atomMap x
        (agg2Lit (agg2Bit sub_nf agg2ZPastPast χ)
          (Formula.snce Formula.top (nfDepth0CharFormula atomMap h_surj χ))) :=
      fun χ => hepL _ (List.mem_append_left _
        (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
    have hAtXLit : ∀ χ : NormalForm sig 0 1, TemporalTruth M atomMap x
        (agg2Lit (agg2Bit sub_nf agg2ZAtXPast χ)
          (nfDepth0CharFormula atomMap h_surj χ)) :=
      fun χ => hepL _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
    have hAtTLit : ∀ χ : NormalForm sig 0 1, TemporalTruth M atomMap t
        (agg2Lit (agg2Bit sub_nf agg2ZAtTPast χ)
          (nfDepth0CharFormula atomMap h_surj χ)) :=
      fun χ => hepR _ (List.mem_append_left _
        (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
    have hFutLit : ∀ χ : NormalForm sig 0 1, TemporalTruth M atomMap t
        (agg2Lit (agg2Bit sub_nf agg2ZFutFut χ)
          (Formula.untl Formula.top (nfDepth0CharFormula atomMap h_surj χ))) :=
      fun χ => hepR _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
    -- Bracket structure: witnesses + gap classification.
    obtain ⟨hwit, hgap⟩ := aggBracket_extract M atomMap _ _ x t hbr
    rw [nf_eval_depth1_fold_iff]
    refine ⟨?_, ?_, hg.1⟩
    · -- Atom layer at `[x, t]` from the two atom-locus heads (given `x < t`).
      exact (nf_char2_atom_offdiag_correct M atomMap h_surj
        (sub_nf.1 : NormalForm sig 0 2) x t hxt).mp ⟨horig, hendp⟩
    · -- Per-(zone, χ) fiber matching over the five consistent zones + the gate.
      intro zs χ
      change _ ↔ agg2Bit sub_nf zs χ = true
      by_cases hcons : zs = agg2ZPastPast ∨ zs = agg2ZAtXPast ∨ zs = agg2ZIntPast ∨
          zs = agg2ZAtTPast ∨ zs = agg2ZFutFut
      · rcases hcons with rfl | rfl | rfl | rfl | rfl
        · -- Zone `v < x`: the Since literal at `x`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZPastPast, agg2Mk, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hux : u < x := hzu.1.1.mpr rfl
            cases hbb : agg2Bit sub_nf agg2ZPastPast χ with
            | false =>
              have hlit := hPastLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ⟨u, hux, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
            | true => rfl
          · intro hbit
            have hlit := hPastLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            obtain ⟨s, hsx, hsχ, -⟩ := hlit
            have hst : s < t := hsx.trans hxt
            refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
            simp only [agg2ZPastPast, agg2Mk, agg2Ltz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by simp)⟩,
              ⟨iff_of_true hst rfl, iff_of_false (lt_asymm hst) (by simp)⟩⟩
        · -- Zone `v = x`: the characteristic literal at `x`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZAtXPast, agg2Mk, agg2Eqz, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = x := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
            subst hueq
            cases hbb : agg2Bit sub_nf agg2ZAtXPast χ with
            | false =>
              have hlit := hAtXLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ((hchar χ u).mpr hev)).elim
            | true => rfl
          · intro hbit
            have hlit := hAtXLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            refine ⟨x, ?_, (hchar χ x).mp hlit⟩
            simp only [agg2ZAtXPast, agg2Mk, agg2Eqz, agg2Ltz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_irrefl x) (by simp),
              iff_of_false (lt_irrefl x) (by simp)⟩,
              ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
        · -- Bounded interior `x < v < t`: positive fibers ride the witness slots,
          -- negative fibers the uniform exclusion segment.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZIntPast, agg2Mk, agg2Gtz, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hxu : x < u := hzu.1.2.mpr rfl
            have hut : u < t := hzu.2.1.mpr rfl
            cases hbb : agg2Bit sub_nf agg2ZIntPast χ with
            | false =>
              exfalso
              rcases hgap u hxu hut with hseg | ⟨p, hpmem, hpe⟩
              · -- Gap point: the exclusion conjunct for χ refutes the evaluation.
                simp only [agg2SegPast, TemporalPred.EvalAt] at hseg
                rw [formula_conjList_iff] at hseg
                have hexcl := hseg _ (List.mem_map_of_mem (show χ ∈ _ by simp))
                rw [if_neg (by simp [hbb])] at hexcl
                exact hexcl ((hchar χ u).mpr hev)
              · -- Witness slot: distinct complete 1-types exclude each other.
                obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hpmem
                have hev' : NfEvalNf M 0 1 (fun _ => u) χ' := (hchar χ' u).mp hpe
                have hbb' : agg2Bit sub_nf agg2ZIntPast χ' = true :=
                  (List.mem_filter.mp
                    ((List.mem_permutations.mp hlp).mem_iff.mp hχ'mem)).2
                have hEqχ : χ = χ' := nf_eval_unique M 0 1 _ χ χ' hev hev'
                rw [hEqχ] at hbb
                exact absurd hbb' (by simp [hbb])
            | true => rfl
          · intro hbit
            have hχS : χ ∈ l := (List.mem_permutations.mp hlp).mem_iff.mpr
              (List.mem_filter.mpr ⟨by simp, hbit⟩)
            obtain ⟨u, hxu, hut, hpe⟩ := hwit _ (List.mem_map_of_mem hχS)
            refine ⟨u, ?_, (hchar χ u).mp hpe⟩
            simp only [agg2ZIntPast, agg2Mk, agg2Gtz, agg2Ltz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
              ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
        · -- Zone `v = t`: the characteristic literal at `t`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZAtTPast, agg2Mk, agg2Gtz, agg2Eqz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = t := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.2.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.2.1))
            subst hueq
            cases hbb : agg2Bit sub_nf agg2ZAtTPast χ with
            | false =>
              have hlit := hAtTLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ((hchar χ u).mpr hev)).elim
            | true => rfl
          · intro hbit
            have hlit := hAtTLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            refine ⟨t, ?_, (hchar χ t).mp hlit⟩
            simp only [agg2ZAtTPast, agg2Mk, agg2Gtz, agg2Eqz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
              ⟨iff_of_false (lt_irrefl t) (by simp),
                iff_of_false (lt_irrefl t) (by simp)⟩⟩
        · -- Zone `t < v`: the Until literal at `t`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZFutFut, agg2Mk, agg2Gtz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have htu : t < u := hzu.2.2.mpr rfl
            cases hbb : agg2Bit sub_nf agg2ZFutFut χ with
            | false =>
              have hlit := hFutLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ⟨u, htu, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
            | true => rfl
          · intro hbit
            have hlit := hFutLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            obtain ⟨s, hts, hsχ, -⟩ := hlit
            have hxs : x < s := hxt.trans hts
            refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
            simp only [agg2ZFutFut, agg2Mk, agg2Gtz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_asymm hxs) (by simp), iff_of_true hxs rfl⟩,
              ⟨iff_of_false (lt_asymm hts) (by simp), iff_of_true hts rfl⟩⟩
      · -- Inconsistent zone spec: gate conjunct (ii) + the routing lemma.
        constructor
        · rintro ⟨u, hzu, -⟩
          exact absurd (agg2_zone_consistent_lt M x t u hxt zs hzu) hcons
        · intro hbit
          have hfalse := hg.2 zs χ hcons
          rw [hfalse] at hbit
          exact Bool.noConfusion hbit
  · -- Completeness (the fixed-anchor evaluation → 2-pin holds).
    intro heval
    rw [nf_eval_depth1_fold_iff] at heval
    obtain ⟨h_atom_raw, h_fiber, h_off⟩ := heval
    have h_atom : NfEvalNf M 0 2 (Fin.cons x (fun _ => t))
        (sub_nf.1 : NormalForm sig 0 2) := h_atom_raw
    -- Fiber clauses in fold-bit form.
    have hzone' : ∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
        (∃ u : M.carrier,
          zoneHolds M (Fin.cons x (fun _ => t)) zs u ∧
          NfEvalNf M 0 1 (fun _ => u) χ) ↔
        agg2Bit sub_nf zs χ = true :=
      fun zs χ => h_fiber zs χ
    -- The two atom loci from the atom layer (given `x < t`).
    obtain ⟨horig, hendp⟩ := (nf_char2_atom_offdiag_correct M atomMap h_surj
      (sub_nf.1 : NormalForm sig 0 2) x t hxt).mpr h_atom
    -- Zone-membership constructors at the five consistent zones.
    have hzPast : ∀ u, u < x → zoneHolds M (Fin.cons x (fun _ => t)) agg2ZPastPast u := by
      intro u hux
      have hut : u < t := hux.trans hxt
      simp only [agg2ZPastPast, agg2Mk, agg2Ltz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
        ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
    have hzAtX : zoneHolds M (Fin.cons x (fun _ => t)) agg2ZAtXPast x := by
      simp only [agg2ZAtXPast, agg2Mk, agg2Eqz, agg2Ltz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
        ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
    have hzInt : ∀ u, x < u → u < t →
        zoneHolds M (Fin.cons x (fun _ => t)) agg2ZIntPast u := by
      intro u hxu hut
      simp only [agg2ZIntPast, agg2Mk, agg2Gtz, agg2Ltz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
        ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
    have hzAtT : zoneHolds M (Fin.cons x (fun _ => t)) agg2ZAtTPast t := by
      simp only [agg2ZAtTPast, agg2Mk, agg2Gtz, agg2Eqz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
        ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
    have hzFut : ∀ u, t < u → zoneHolds M (Fin.cons x (fun _ => t)) agg2ZFutFut u := by
      intro u htu
      have hxu : x < u := hxt.trans htu
      simp only [agg2ZFutFut, agg2Mk, agg2Gtz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
        ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
    -- The gate: off-fiber honesty + order-conflict falsity.
    have hgate : agg2GatePast sub_nf := by
      refine ⟨h_off, fun zs χ hncons => ?_⟩
      cases hb : agg2Bit sub_nf zs χ with
      | false => rfl
      | true =>
        obtain ⟨u, hzu, -⟩ := (hzone' zs χ).mpr hb
        exact absurd (agg2_zone_consistent_lt M x t u hxt zs hzu) hncons
    -- Interior-positive realization: each positive fiber yields an interior point.
    have hSreal : ∀ χ ∈ agg2SPast sub_nf,
        ∃ u, x < u ∧ u < t ∧ NfEvalNf M 0 1 (fun _ => u) χ := by
      intro χ hχ
      have hbit := (List.mem_filter.mp hχ).2
      obtain ⟨u, hzu, hev⟩ := (hzone' agg2ZIntPast χ).mpr hbit
      simp only [agg2ZIntPast, agg2Mk, agg2Gtz, agg2Ltz] at hzu
      rw [agg2_zoneHolds_cons_iff] at hzu
      exact ⟨u, hzu.1.2.mpr rfl, hzu.2.1.mpr rfl, hev⟩
    -- Sorted arrangement of the interior-positive enumeration (insertion induction).
    obtain ⟨ps, hperm, hsort, hprops⟩ :=
      k1v_sorted_realization M x t (agg2SPast sub_nf)
        ((Finset.nodup_toList _).filter _) hSreal
    -- The uniform exclusion segment holds on ALL of `(x, t)`.
    have hseg_all : ∀ u, x < u → u < t →
        (agg2SegPast atomMap h_surj sub_nf).EvalAt M atomMap u := by
      intro u hxu hut
      simp only [agg2SegPast, TemporalPred.EvalAt]
      rw [formula_conjList_iff]
      intro f hf
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : agg2Bit sub_nf agg2ZIntPast χ with
      | true =>
        rw [if_pos rfl]
        exact fun hfa => hfa
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hzone' agg2ZIntPast χ).mp ⟨u, hzInt u hxu hut, (hchar χ u).mp hch⟩
        rw [hb] at hbit
        exact Bool.noConfusion hbit
    -- Left endpoint predicate at the pin `x`.
    have hepL : (agg2EpPastL atomMap h_surj sub_nf).EvalAt M atomMap x := by
      simp only [agg2EpPastL, TemporalPred.EvalAt]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_append.mp hf with hf | hf
      · rcases List.mem_cons.mp hf with rfl | hf
        · exact hendp
        · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
          simp only [agg2Lit]
          cases hb : agg2Bit sub_nf agg2ZPastPast χ with
          | true =>
            rw [if_pos rfl]
            obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
            simp only [agg2ZPastPast, agg2Mk, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            exact ⟨u, hzu.1.1.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
          | false =>
            rw [if_neg (by simp)]
            rintro ⟨s, hsx, hsχ, -⟩
            have hbit := (hzone' _ χ).mp ⟨s, hzPast s hsx, (hchar χ s).mp hsχ⟩
            rw [hb] at hbit
            exact Bool.noConfusion hbit
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        simp only [agg2Lit]
        cases hb : agg2Bit sub_nf agg2ZAtXPast χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          simp only [agg2ZAtXPast, agg2Mk, agg2Eqz, agg2Ltz] at hzu
          rw [agg2_zoneHolds_cons_iff] at hzu
          have hueq : u = x := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
          exact (hchar χ x).mpr (hueq ▸ hev)
        | false =>
          rw [if_neg (by simp)]
          intro hch
          have hbit := (hzone' _ χ).mp ⟨x, hzAtX, (hchar χ x).mp hch⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    -- Right endpoint predicate at the pin `t`.
    have hepR : (agg2EpPastR atomMap h_surj sub_nf).EvalAt M atomMap t := by
      simp only [agg2EpPastR, TemporalPred.EvalAt]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_append.mp hf with hf | hf
      · rcases List.mem_cons.mp hf with rfl | hf
        · exact horig
        · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
          simp only [agg2Lit]
          cases hb : agg2Bit sub_nf agg2ZAtTPast χ with
          | true =>
            rw [if_pos rfl]
            obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
            simp only [agg2ZAtTPast, agg2Mk, agg2Gtz, agg2Eqz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = t := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.2.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.2.1))
            exact (hchar χ t).mpr (hueq ▸ hev)
          | false =>
            rw [if_neg (by simp)]
            intro hch
            have hbit := (hzone' _ χ).mp ⟨t, hzAtT, (hchar χ t).mp hch⟩
            rw [hb] at hbit
            exact Bool.noConfusion hbit
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        simp only [agg2Lit]
        cases hb : agg2Bit sub_nf agg2ZFutFut χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          simp only [agg2ZFutFut, agg2Mk, agg2Gtz] at hzu
          rw [agg2_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.2.2.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp)]
          rintro ⟨s, hts, hsχ, -⟩
          have hbit := (hzone' _ χ).mp ⟨s, hzFut s hts, (hchar χ s).mp hsχ⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    -- Enter the carrier: gate branch, then the sorted arrangement disjunct.
    unfold agg2Past
    split
    case isFalse hgf => exact absurd hgate hgf
    case isTrue hg =>
    refine ⟨_, List.mem_map.mpr ⟨ps.map Prod.fst,
      List.mem_permutations.mpr hperm, rfl⟩, ?_⟩
    refine ⟨hepL, hepR, ?_⟩
    -- The bracket: assembled by the construction lemma from the sorted realization.
    refine aggBracket_construct M atomMap _ _ x t (ps.map Prod.snd) (by simp) hsort
      ?_ ?_ hseg_all
    · intro u hu
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
      exact (hprops p hp).1
    · intro i hi
      have hi' : i < ps.length := by simpa using hi
      have h1 : (List.map (fun χ =>
          (⟨nfDepth0CharFormula atomMap h_surj χ⟩ : TemporalPred))
          (ps.map Prod.fst))[i]'hi =
          ⟨nfDepth0CharFormula atomMap h_surj ((ps[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (ps.map Prod.snd)[i]'(by simpa using hi') = (ps[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hprops _ (List.getElem_mem _)).2

/-! ## 5. Point-channel carriers `CAggPtX` / `CAggPtT`

The Phase-12a/12b gated collapses realized as `VVecEA2`: on the (0,1)/(0,2)
rename-fixpoint gate, the carrier is `agg2Past` on the collapsed arity-2 NF (read at
the fixed pins by `agg2Past_holds_pin_iff`); off-gate the empty disjunction — the
evaluation FORCES the gate (`aggPm01_gate_of_eval`/`aggPm02_gate_of_eval`), so the
off-gate falsity is honest, exactly the `aggPosDiagK1` pattern. -/

/-- **The `w = x` point-channel carrier** (Phase-12a collapse as a `VVecEA2`). -/
noncomputable def CAggPtX (qnf : NormalForm sig 1 3) : VVecEA2 :=
  @dite _ (aggPm01GateK1 qnf) (Classical.dec _)
    (fun _ => agg2Past atomMap h_surj (aggPm01CollapseK1 qnf))
    (fun _ => { disjuncts := [] })

/-- **Correctness of `CAggPtX`**: under the ambient `x < t`, the carrier's 2-pin
    semantics at `(x, t)` is exactly the duplicated-head evaluation at `[x, x, t]`
    (the Phase-12a clause `aggPm01ClauseK1_iff`, carrier-side). -/
theorem CAggPtX_correct (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (x t : M.carrier) (hxt : x < t) :
    (CAggPtX atomMap h_surj qnf).holds M atomMap x t ↔
      NfEvalNf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) qnf := by
  unfold CAggPtX
  by_cases hg : aggPm01GateK1 qnf
  · rw [dif_pos hg,
      agg2Past_holds_pin_iff atomMap h_surj (aggPm01CollapseK1 qnf) M x t hxt]
    exact (agg_pm01_collapse_k1 M qnf x t hg.1 hg.2).symm
  · rw [dif_neg hg]
    constructor
    · rintro ⟨vea, hmem, -⟩
      exact (List.not_mem_nil hmem).elim
    · intro hw
      exact absurd (aggPm01_gate_of_eval M qnf x t hw) hg

/-- **The `w = x` clause iff**: on the `aggOdRowPtX` row, the carrier realizes the FULL
    population existential — the row's (0,1)/(1,0) bits force any witness onto the left
    pin (Lemma 3.2(2) coincident-witness channel). -/
theorem CAggPtX_clause_iff (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (hrow : aggOdRowPtX qnf)
    (x t : M.carrier) (hxt : x < t) :
    (CAggPtX atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  rw [CAggPtX_correct atomMap h_surj M qnf x t hxt]
  constructor
  · intro h
    exact ⟨x, h⟩
  · rintro ⟨w, hw⟩
    have hlayer := ((nf_eval_depth1_fold_iff M _ qnf).mp hw).1
    have h01 : ¬ (w < x) := by
      intro hlt
      have hb : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true :=
        (hlayer _).mp hlt
      exact aggOd_row_clash hb hrow.1
    have h10 : ¬ (x < w) := by
      intro hlt
      have hb : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true :=
        (hlayer _).mp hlt
      exact aggOd_row_clash hb hrow.2.1
    have hwx : w = x := le_antisymm (not_lt.mp h10) (not_lt.mp h01)
    exact hwx ▸ hw

/-- **The `w = t` point-channel carrier** (Phase-12b collapse as a `VVecEA2`). -/
noncomputable def CAggPtT (qnf : NormalForm sig 1 3) : VVecEA2 :=
  @dite _ (aggPm02GateK1 qnf) (Classical.dec _)
    (fun _ => agg2Past atomMap h_surj (aggPm02CollapseK1 qnf))
    (fun _ => { disjuncts := [] })

/-- **Correctness of `CAggPtT`**: under the ambient `x < t`, the carrier's 2-pin
    semantics at `(x, t)` is exactly the duplicated evaluation at `[t, x, t]`
    (the Phase-12b clause `aggPm02ClauseK1_iff`, carrier-side). -/
theorem CAggPtT_correct (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (x t : M.carrier) (hxt : x < t) :
    (CAggPtT atomMap h_surj qnf).holds M atomMap x t ↔
      NfEvalNf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) qnf := by
  unfold CAggPtT
  by_cases hg : aggPm02GateK1 qnf
  · rw [dif_pos hg,
      agg2Past_holds_pin_iff atomMap h_surj (aggPm02CollapseK1 qnf) M x t hxt]
    exact (agg_pm02_collapse_k1 M qnf x t hg.1 hg.2).symm
  · rw [dif_neg hg]
    constructor
    · rintro ⟨vea, hmem, -⟩
      exact (List.not_mem_nil hmem).elim
    · intro hw
      exact absurd (aggPm02_gate_of_eval M qnf x t hw) hg

/-- **The `w = t` clause iff**: on the `aggOdRowPtT` row, the carrier realizes the FULL
    population existential — the row's (0,2)/(2,0) bits force any witness onto the right
    pin. -/
theorem CAggPtT_clause_iff (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (hrow : aggOdRowPtT qnf)
    (x t : M.carrier) (hxt : x < t) :
    (CAggPtT atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  rw [CAggPtT_correct atomMap h_surj M qnf x t hxt]
  constructor
  · intro h
    exact ⟨t, h⟩
  · rintro ⟨w, hw⟩
    have hlayer := ((nf_eval_depth1_fold_iff M _ qnf).mp hw).1
    have h02 : ¬ (w < t) := by
      intro hlt
      have hb : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true :=
        (hlayer _).mp hlt
      exact aggOd_row_clash hb hrow.1
    have h20 : ¬ (t < w) := by
      intro hlt
      have hb : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true :=
        (hlayer _).mp hlt
      exact aggOd_row_clash hb hrow.2.1
    have hwt : w = t := le_antisymm (not_lt.mp h20) (not_lt.mp h02)
    exact hwt ▸ hw

/-! ## 6. Interior channel `CAggInt`

The delivered depth-1 fixed-endpoint bracket carrier `bracketEndCharKv` with the
depth-0 provider `nfDepth0CharFormula` (`h0 := rfl`), consumed through the
UZ/SZ-relativized rung `bracketEndChar_kv_correct_one_prior` (PriorInterface.lean:95;
the recursion-consumer packaging of the same rung is `endIntervalPrior_correct_le_one`
/ `endInterval_correct` in EndIntervalConsumerK.lean). `aggOdRowInt`'s six conjuncts
are the rung's six order hypotheses VERBATIM. -/

/-- Depth-indexed provider for the interior carrier: `nfDepth0CharFormula` at depth
    0 (the only depth the k=1 correctness constrains — `h0 := rfl`), `⊤` above. -/
noncomputable def aggOdCharF : (j : Nat) → NormalForm sig j 1 → Formula
  | 0 => nfDepth0CharFormula atomMap h_surj
  | _ + 1 => fun _ => Formula.top

/-- **The interior-channel carrier**: `bracketEndCharKv` at depth 1. -/
noncomputable def CAggInt (qnf : NormalForm sig 1 3) : VVecEA2 :=
  bracketEndCharKv atomMap h_surj (aggOdCharF atomMap h_surj) 1 qnf

/-- **The interior clause iff**: on the `aggOdRowInt` row, for every Prior (UZ/SZ)
    structure, the carrier's 2-pin semantics at `(x, t)` is the full population
    existential — the delivered `bracketEndChar_kv_correct_one_prior` applied at the
    row's six order bits. -/
theorem CAggInt_clause_iff (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (hrow : aggOdRowInt qnf)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier) :
    (CAggInt atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  bracketEndChar_kv_correct_one_prior atomMap h_surj (aggOdCharF atomMap h_surj) rfl
    qnf hrow.1 hrow.2.1 hrow.2.2.1 hrow.2.2.2.1 hrow.2.2.2.2.1 hrow.2.2.2.2.2
    M h_UZ h_SZ x t

/-! ## 7. Exterior clause iffs

The delivered carriers `CExtPast`/`CExtFut` read `∃ w < x`/`∃ w > t`; on their rows the
bound is REDUNDANT — the row bit forces any witness into the exterior zone — so the
carriers realize the full unbounded population existential. -/

/-- **The `w < x` clause iff**: on the `navDOrderRow` row, `CExtPast` realizes the full
    population existential (the (0,1) bit forces `w < x` on any realizer). -/
theorem CExtPast_clause_iff (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (hrow : navDOrderRow qnf)
    (x t : M.carrier) (hxt : x < t) :
    (CExtPast atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  rw [CExtPast_correct atomMap h_surj M qnf x t hxt]
  constructor
  · rintro ⟨w, -, hw⟩
    exact ⟨w, hw⟩
  · rintro ⟨w, hw⟩
    have hlayer := ((nf_eval_depth1_fold_iff M _ qnf).mp hw).1
    exact ⟨w, (hlayer _).mpr hrow.1, hw⟩

/-- **The `t < w` clause iff**: on the `navROrderRow` row, `CExtFut` realizes the full
    population existential (the (2,0) bit forces `t < w` on any realizer). -/
theorem CExtFut_clause_iff (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (hrow : navROrderRow qnf)
    (x t : M.carrier) (hxt : x < t) :
    (CExtFut atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  rw [CExtFut_correct atomMap h_surj M qnf x t hxt]
  constructor
  · rintro ⟨w, -, hw⟩
    exact ⟨w, hw⟩
  · rintro ⟨w, hw⟩
    have hlayer := ((nf_eval_depth1_fold_iff M _ qnf).mp hw).1
    exact ⟨w, (hlayer _).mpr hrow.2.2.1, hw⟩

/-! ## 8. The dispatcher `C(qnf)` and the master clause iff -/

open Classical in
/-- **The per-qnf dispatcher `C(qnf)`** (Cor 5.4 "all order patterns"): case on the
    zone-classifier rows and delegate to the channel carrier — `CExtPast` (w<x),
    `CAggPtX` (w=x), `CAggInt` (x<w<t), `CAggPtT` (w=t), `CExtFut` (t<w), and the empty
    disjunction on the 3-bot channel. The if-chain mirrors `aggOdClassify` branch for
    branch (the rows are pairwise disjoint, so the order is semantically irrelevant). -/
noncomputable def CAggOd (qnf : NormalForm sig 1 3) : VVecEA2 :=
  if navDOrderRow qnf then CExtPast atomMap h_surj qnf
  else if aggOdRowPtX qnf then CAggPtX atomMap h_surj qnf
  else if aggOdRowInt qnf then CAggInt atomMap h_surj qnf
  else if aggOdRowPtT qnf then CAggPtT atomMap h_surj qnf
  else if navROrderRow qnf then CExtFut atomMap h_surj qnf
  else { disjuncts := [] }

/-- **The master clause iff** (Phase-16a DoD; the per-qnf clause the Phase-16b
    `aggPop1` fold consumes): under the ambient `x < t`, for every Prior (UZ/SZ)
    structure, the dispatcher's 2-pin semantics at `(x, t)` is exactly the k=1
    population existential `∃ w, NfEvalNf M 1 3 [w, x, t] qnf` — every channel
    discharged by its carrier iff, the 3-bot channel by the routing totality. -/
theorem CAggOd_clause_iff (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier) (hxt : x < t) :
    (CAggOd atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  unfold CAggOd
  split_ifs with h1 h2 h3 h4 h5
  · exact CExtPast_clause_iff atomMap h_surj M qnf h1 x t hxt
  · exact CAggPtX_clause_iff atomMap h_surj M qnf h2 x t hxt
  · exact CAggInt_clause_iff atomMap h_surj M qnf h3 h_UZ h_SZ x t
  · exact CAggPtT_clause_iff atomMap h_surj M qnf h4 x t hxt
  · exact CExtFut_clause_iff atomMap h_surj M qnf h5 x t hxt
  · -- 3-bot channel: both sides are `False`.
    constructor
    · rintro ⟨vea, hmem, -⟩
      exact (List.not_mem_nil hmem).elim
    · rintro ⟨w, hw⟩
      exact (aggOdZone3_bot_eval_false M qnf h1 h2 h3 h4 h5 x t hxt w hw).elim

/-! ## 9. Phase 16b — the k=1 aggregate population fold `aggPop1` (Lemma 3.4 closure)

The Rabinovich Lemma 3.4 closure under ∧ (chunk_0010): the population MATCH
`∀ qnf, ((∃ w, NfEvalNf M 1 3 [w, x, t] qnf) ↔ sub_nf.2 qnf)` is the `conjFull`-fold
over ALL `qnf : NormalForm sig 1 3` (Fintype at NormalForm.lean:167) of the per-qnf
dispatcher `CAggOd qnf` on bit-true qnf and its Prop 4.2/4.3 De Morgan negation
`(CAggOd qnf).negFix` on bit-false qnf, with `VVecEA2.trivialTrue` as the neutral
element. `negFix_iff` is gated on attained INF/SUP; on Prior structures these are
`prior_hasAttainedINF h_UZ` / `prior_hasAttainedSUP h_SZ` (PriorINF.lean:224/:269). -/

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Pin bridge (Since direction): `holdsRight` at the origin `t` is the pointwise
    2-pin semantics quantified through the laid witness `z0 < t`. Pure conjunct
    reassociation (G5 — manual). -/
theorem aggOd_holdsRight_iff_holds (M : OrderedMonadicStructure sig)
    (v : VVecEA2) (t : M.carrier) :
    v.holdsRight M atomMap t ↔ ∃ x : M.carrier, x < t ∧ v.holds M atomMap x t := by
  constructor
  · rintro ⟨vea, hmem, hepR, z0, hz0, hepL, hbr⟩
    exact ⟨z0, hz0, vea, hmem, hepL, hepR, hbr⟩
  · rintro ⟨x, hx, vea, hmem, hepL, hepR, hbr⟩
    exact ⟨vea, hmem, hepR, x, hx, hepL, hbr⟩

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Pin bridge (Until direction): `holdsLeft` at the origin `t` is the pointwise
    2-pin semantics quantified through the laid witness `t < z1` (dual). -/
theorem aggOd_holdsLeft_iff_holds (M : OrderedMonadicStructure sig)
    (v : VVecEA2) (t : M.carrier) :
    v.holdsLeft M atomMap t ↔ ∃ x : M.carrier, t < x ∧ v.holds M atomMap t x := by
  constructor
  · rintro ⟨vea, hmem, hepL, z1, hz1, hepR, hbr⟩
    exact ⟨z1, hz1, vea, hmem, hepL, hepR, hbr⟩
  · rintro ⟨x, hx, vea, hmem, hepL, hepR, hbr⟩
    exact ⟨vea, hmem, hepL, x, hx, hepR, hbr⟩

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The biconditional population fold** (Lemma 3.4 closure under ∧, list form):
    folding `if bit qnf then D qnf else (D qnf).negFix` over a list with `conjFull`
    holds iff EVERY listed qnf's carrier matches its bit — the biconditional
    per-clause reading (`⟺`, not `→`) that the k=1 population match requires.
    Induction over the list; the cons step is `VVecEA2.conjFull_iff` + (on the
    bit-false branch) the gated `VVecEA2.negFix_iff`. -/
theorem aggOdPopFold_iff (M : OrderedMonadicStructure sig)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (D : NormalForm sig 1 3 → VVecEA2) (bit : NormalForm sig 1 3 → Bool)
    (z0 z1 : M.carrier) (h_lt : z0 < z1) (l : List (NormalForm sig 1 3)) :
    ((l.map fun qnf => if bit qnf then D qnf else (D qnf).negFix).foldr
        VVecEA2.conjFull VVecEA2.trivialTrue).holds M atomMap z0 z1 ↔
      ∀ qnf ∈ l, ((D qnf).holds M atomMap z0 z1 ↔ bit qnf = true) := by
  induction l with
  | nil =>
    simp only [List.map_nil, List.foldr_nil]
    constructor
    · intro _ qnf hq
      exact absurd hq (List.not_mem_nil)
    · intro _
      exact VVecEA2.trivialTrue_holds M atomMap z0 z1
  | cons q qs ih =>
    rw [List.map_cons, List.foldr_cons, VVecEA2.conjFull_iff, ih,
        List.forall_mem_cons]
    refine and_congr ?_ Iff.rfl
    by_cases hb : bit q = true
    · rw [if_pos hb, hb]
      constructor
      · intro hp
        exact ⟨fun _ => rfl, fun _ => hp⟩
      · intro hiff
        exact hiff.mpr rfl
    · rw [if_neg hb,
          VVecEA2.negFix_iff M atomMap h_INF h_SUP (D q) z0 z1 h_lt]
      constructor
      · intro hneg
        exact ⟨fun hh => absurd hh hneg, fun hbit => absurd hbit hb⟩
      · intro hiff hh
        exact hb (hiff.mp hh)

/-- **The k=1 aggregate population carrier `aggPop1`** (Phase 16b; plan Design
    section verbatim): the `conjFull`-fold over ALL `qnf : NormalForm sig 1 3` of the
    per-qnf dispatcher `CAggOd qnf` (bit-true) / its De Morgan negation
    `(CAggOd qnf).negFix` (bit-false), read off `sub_nf.2`. -/
noncomputable def aggPop1 (sub_nf : NormalForm sig 2 2) : VVecEA2 :=
  ((Finset.univ : Finset (NormalForm sig 1 3)).toList.map fun qnf =>
      if sub_nf.2 qnf then CAggOd atomMap h_surj qnf
      else (CAggOd atomMap h_surj qnf).negFix).foldr
    VVecEA2.conjFull VVecEA2.trivialTrue

/-- **Correctness of `aggPop1`** (plan Design section verbatim): under the ambient
    `x < t` and the Prior hypotheses, the fold's 2-pin semantics at `(x, t)` is
    exactly the k=1 population MATCH — for EVERY `qnf : NormalForm sig 1 3`, the
    population existential `∃ w, NfEvalNf M 1 3 [w, x, t] qnf` holds iff
    `sub_nf.2 qnf = true`. Fold induction (`aggOdPopFold_iff`) with
    `h_INF := prior_hasAttainedINF … h_UZ`, `h_SUP := prior_hasAttainedSUP … h_SZ`;
    per-qnf clause discharged by the Phase-16a master `CAggOd_clause_iff`. -/
theorem aggPop1_correct (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 2 2)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier) (h_lt : x < t) :
    (aggPop1 atomMap h_surj sub_nf).holds M atomMap x t ↔
      ∀ qnf : NormalForm sig 1 3,
        ((∃ w : M.carrier,
            NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) ↔
          sub_nf.2 qnf = true) := by
  unfold aggPop1
  rw [aggOdPopFold_iff atomMap M
      (prior_hasAttainedINF M atomMap h_UZ) (prior_hasAttainedSUP M atomMap h_SZ)
      (CAggOd atomMap h_surj) sub_nf.2 x t h_lt]
  constructor
  · intro h qnf
    exact (CAggOd_clause_iff atomMap h_surj M qnf h_UZ h_SZ x t h_lt).symm.trans
      (h qnf (Finset.mem_toList.mpr (Finset.mem_univ qnf)))
  · intro h qnf _
    exact (CAggOd_clause_iff atomMap h_surj M qnf h_UZ h_SZ x t h_lt).trans (h qnf)

/-! ## 10. Phase 16b — the future-arm population fold `aggPop1F` (mirror decision)

**16b mirror-carrier decision (RECORDED, per the Phase-16a handoff)**: route
(a)-variant — NO mirror dispatcher `CAggOdF` is built, and the 16a mirror
classification (`aggOdRow*F`/`aggOdClassifyF`) stays unconsumed. The future arm
reuses the SAME `x < t`-keyed dispatcher `CAggOd` through the BIJECTIVE index swap
`aggOdSwap12` (the involution of `Fin 3` fixing the witness slot 0 and swapping the
pin slots 1 ↔ 2), transported by `renameNF_eval_iff` (NfDepth0Generalized.lean:440
— the full bidirectional rename congruence, applicable exactly because the swap is
a bijection, unlike the Phase-12 merge maps): at pins `(z0, z1) = (t, x)` with the
flipped ambient `t < x`, `CAggOd_clause_iff` yields the population existential at
env `[w, t, x]`, and the swap carries it to the required trichotomy env
`[w, x, t]`. A DISTINCT future fold carrier `aggPop1F` is still defined — its
per-qnf carrier is `CAggOd (swap qnf)` with the bit read at the ORIGINAL qnf — but
no mirror channel machinery is needed. -/

/-- The pin swap: the involution of `Fin 3` fixing the population-witness slot `0`
    and swapping the pin slots `1 ↔ 2`. -/
def aggOdSwap12 : Fin 3 → Fin 3 :=
  Fin.cons 0 (Fin.cons 2 (fun _ => 1))

/-- `aggOdSwap12` is an involution. -/
theorem aggOdSwap12_involutive : ∀ i, aggOdSwap12 (aggOdSwap12 i) = i := by
  decide

/-- **The swap transport**: evaluating the swapped qnf on the swapped env
    `[w, t, x]` is evaluating the original qnf on the trichotomy env `[w, x, t]`.
    Instance of the bijective rename congruence `renameNF_eval_iff`. -/
theorem aggOdSwap12_eval_iff (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (w x t : M.carrier) :
    NfEvalNf M 1 3 (Fin.cons w (Fin.cons t (fun _ => x)))
        (renameNF aggOdSwap12 aggOdSwap12 qnf) ↔
      NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  refine renameNF_eval_iff M aggOdSwap12 aggOdSwap12
    (Fin.cons w (Fin.cons x (fun _ => t))) (Fin.cons w (Fin.cons t (fun _ => x)))
    ?_ ?_ aggOdSwap12_involutive aggOdSwap12_involutive qnf
  · intro i
    fin_cases i <;> rfl
  · intro i
    fin_cases i <;> rfl

/-- **The swapped clause iff**: under the FLIPPED ambient `t < x`, the dispatcher at
    the swapped qnf read at pins `(t, x)` is exactly the future-arm population
    existential at the trichotomy env `[w, x, t]`. `CAggOd_clause_iff` at pins
    `(t, x)` + the swap transport. -/
theorem CAggOdSwap_clause_iff (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier) (htx : t < x) :
    (CAggOd atomMap h_surj (renameNF aggOdSwap12 aggOdSwap12 qnf)).holds
        M atomMap t x ↔
      ∃ w : M.carrier,
        NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  (CAggOd_clause_iff atomMap h_surj M (renameNF aggOdSwap12 aggOdSwap12 qnf)
      h_UZ h_SZ t x htx).trans
    (exists_congr fun w => aggOdSwap12_eval_iff M qnf w x t)

/-- **The future-arm k=1 aggregate population carrier `aggPop1F`**: the
    `conjFull`-fold over ALL `qnf : NormalForm sig 1 3` of the SWAPPED dispatcher
    `CAggOd (swap qnf)` (bit-true) / its De Morgan negation (bit-false), the bit
    read at the ORIGINAL qnf. Distinct from `aggPop1` only in the swap — see the
    section-header decision record. -/
noncomputable def aggPop1F (sub_nf : NormalForm sig 2 2) : VVecEA2 :=
  ((Finset.univ : Finset (NormalForm sig 1 3)).toList.map fun qnf =>
      if sub_nf.2 qnf then
        CAggOd atomMap h_surj (renameNF aggOdSwap12 aggOdSwap12 qnf)
      else (CAggOd atomMap h_surj (renameNF aggOdSwap12 aggOdSwap12 qnf)).negFix).foldr
    VVecEA2.conjFull VVecEA2.trivialTrue

/-- **Correctness of `aggPop1F`** (future arm): under the FLIPPED ambient `t < x`
    and the Prior hypotheses, the fold's 2-pin semantics at `(t, x)` is exactly the
    k=1 population MATCH at the trichotomy env `[w, x, t]`. Mirror of
    `aggPop1_correct` through `CAggOdSwap_clause_iff`. -/
theorem aggPop1F_correct (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 2 2)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier) (h_lt : t < x) :
    (aggPop1F atomMap h_surj sub_nf).holds M atomMap t x ↔
      ∀ qnf : NormalForm sig 1 3,
        ((∃ w : M.carrier,
            NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) ↔
          sub_nf.2 qnf = true) := by
  unfold aggPop1F
  rw [aggOdPopFold_iff atomMap M
      (prior_hasAttainedINF M atomMap h_UZ) (prior_hasAttainedSUP M atomMap h_SZ)
      (fun qnf => CAggOd atomMap h_surj (renameNF aggOdSwap12 aggOdSwap12 qnf))
      sub_nf.2 t x h_lt]
  constructor
  · intro h qnf
    exact (CAggOdSwap_clause_iff atomMap h_surj M qnf h_UZ h_SZ x t h_lt).symm.trans
      (h qnf (Finset.mem_toList.mpr (Finset.mem_univ qnf)))
  · intro h qnf _
    exact (CAggOdSwap_clause_iff atomMap h_surj M qnf h_UZ h_SZ x t h_lt).trans
      (h qnf)

/-! ## 11. Phase 16b — atom-layer carriers + the final two DoD arm lemmas

Assembly exactly like delivered Phase 3 (`kampArmPastK0`, AggregateHookDischarge.lean):
`(atom-layer ∧ population).translateRight` for the past arm,
`(atom-layer ∧ population).translateLeft` for the future arm (flipped origin guard as
in `agg2Fut`). The atom layer rides a single-disjunct `VVecEA2` with the delivered
off-diagonal loci at the endpoints and the trivially-true bracket; the ∧ is the
Lemma 3.4 `conjFull`. The depth-(1+1) `NfEvalNf` unfolding is definitional
(structure eta — the same seam `kampPrior_site_perQnf_seam` names, restated locally
because KampPrior imports this module's aggregator, not vice versa). -/

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- The depth-(1+1) evaluation seam (definitional): atom layer + population MATCH. -/
theorem aggOd_eval2_iff (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 2 2) (env : Fin 2 → M.carrier) :
    NfEvalNf M 2 2 env sub_nf ↔
      NfEvalNf M 0 2 env (sub_nf.1 : NormalForm sig 0 2) ∧
      ∀ qnf : NormalForm sig 1 3,
        ((∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w env) qnf) ↔
          sub_nf.2 qnf = true) :=
  Iff.rfl

/-- **Past-arm k=1 atom-layer carrier**: single disjunct, the delivered off-diagonal
    endpoint locus at the laid witness `x` (`z0`), the delivered off-diagonal origin
    locus (with its `x < t` order guard) at the origin `t` (`z1`), trivial bracket. -/
noncomputable def aggAtomK1Past (sub_nf : NormalForm sig 2 2) : VVecEA2 :=
  ⟨[⟨0, { endpointLeft := nfChar2AtomOffdiagEndpoint atomMap h_surj
            (sub_nf.1 : NormalForm sig 0 2)
          endpointRight := ⟨nfChar2AtomOffdiagOrigin atomMap h_surj
            (sub_nf.1 : NormalForm sig 0 2)⟩
          bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩

/-- The past-arm atom carrier reads the atom layer (Phase-2 locus decomposition
    `nf_char2_atom_offdiag_correct`, under the ambient `x < t`). -/
theorem aggAtomK1Past_holds_iff (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 2 2) (x t : M.carrier) (hxt : x < t) :
    (aggAtomK1Past atomMap h_surj sub_nf).holds M atomMap x t ↔
      NfEvalNf M 0 2 (Fin.cons x (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2) := by
  constructor
  · rintro ⟨vea, hmem, hepL, hepR, -⟩
    simp only [aggAtomK1Past, List.mem_singleton] at hmem
    subst hmem
    exact (nf_char2_atom_offdiag_correct M atomMap h_surj
      (sub_nf.1 : NormalForm sig 0 2) x t hxt).mp ⟨hepR, hepL⟩
  · intro h
    have hloc := (nf_char2_atom_offdiag_correct M atomMap h_surj
      (sub_nf.1 : NormalForm sig 0 2) x t hxt).mpr h
    refine ⟨_, List.mem_singleton.mpr rfl, hloc.2, hloc.1, ?_⟩
    rw [BracketFormula.trivial_holds]
    intro y _ _
    exact TemporalPred.eval_at_top M atomMap y

/-- **Future-arm k=1 atom-layer carrier** (flipped origin guard as in `agg2Fut`):
    the FLIPPED off-diagonal origin locus at the origin `t` (`z0`), the
    (direction-independent) endpoint locus at the laid witness `x` (`z1`). -/
noncomputable def aggAtomK1Fut (sub_nf : NormalForm sig 2 2) : VVecEA2 :=
  ⟨[⟨0, { endpointLeft := ⟨nfChar2AtomOffdiagOriginFuture atomMap h_surj
            (sub_nf.1 : NormalForm sig 0 2)⟩
          endpointRight := nfChar2AtomOffdiagEndpoint atomMap h_surj
            (sub_nf.1 : NormalForm sig 0 2)
          bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩

/-- The future-arm atom carrier reads the atom layer (the dual locus decomposition
    `nf_char2_atom_offdiag_correct_future`, under the FLIPPED ambient `t < x`; the
    trichotomy env stays `[x, t]`). -/
theorem aggAtomK1Fut_holds_iff (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 2 2) (x t : M.carrier) (htx : t < x) :
    (aggAtomK1Fut atomMap h_surj sub_nf).holds M atomMap t x ↔
      NfEvalNf M 0 2 (Fin.cons x (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2) := by
  constructor
  · rintro ⟨vea, hmem, hepL, hepR, -⟩
    simp only [aggAtomK1Fut, List.mem_singleton] at hmem
    subst hmem
    exact (nf_char2_atom_offdiag_correct_future M atomMap h_surj
      (sub_nf.1 : NormalForm sig 0 2) x t htx).mp ⟨hepL, hepR⟩
  · intro h
    have hloc := (nf_char2_atom_offdiag_correct_future M atomMap h_surj
      (sub_nf.1 : NormalForm sig 0 2) x t htx).mpr h
    refine ⟨_, List.mem_singleton.mpr rfl, hloc.1, hloc.2, ?_⟩
    rw [BracketFormula.trivial_holds]
    intro y _ _
    exact TemporalPred.eval_at_top M atomMap y

/-- **k=1 past arm formula** (hook-discharge lemma 5/6, carrier): the Since-direction
    translation of `atom-layer ∧ aggPop1` (Lemma 3.4 conjunction). -/
noncomputable def kampArmPastK1 (sub_nf : NormalForm sig 2 2) : Formula :=
  ((aggAtomK1Past atomMap h_surj sub_nf).conjFull
    (aggPop1 atomMap h_surj sub_nf)).translateRight

/-- **k=1 past-arm hook discharge** (hook-discharge lemma 5/6): the past-arm formula
    realizes the past disjunct of `kampPrior_site_trichotomy` at match arm k=1.
    Enters the skeleton via `VVecEA2.translateRight_correct` (NfToVecEA.lean:451,
    Route V — Phase-1 R1 verdict); pins bridged by `aggOd_holdsRight_iff_holds`;
    per-pin content = `conjFull_iff` + atom locus + `aggPop1_correct` + the
    definitional depth-(1+1) seam. Unlike k=0, the Prior hypotheses are USED
    (they gate the De Morgan fold inside `aggPop1`). -/
theorem kampArm_past_k1_correct (sub_nf : NormalForm sig 2 2) :
    ∀ (M : OrderedMonadicStructure sig),
      SemanticPriorUZ M atomMap → SemanticPriorSZ M atomMap →
      ∀ t : M.carrier,
      TemporalTruth M atomMap t (kampArmPastK1 atomMap h_surj sub_nf) ↔
        ∃ x, x < t ∧ NfEvalNf M 2 2 (Fin.cons x (fun _ => t)) sub_nf := by
  intro M h_UZ h_SZ t
  unfold kampArmPastK1
  rw [VVecEA2.translateRight_correct, aggOd_holdsRight_iff_holds]
  refine exists_congr fun x => and_congr_right fun hxt => ?_
  rw [VVecEA2.conjFull_iff,
      aggAtomK1Past_holds_iff atomMap h_surj M sub_nf x t hxt,
      aggPop1_correct atomMap h_surj M sub_nf h_UZ h_SZ x t hxt]
  exact (aggOd_eval2_iff M sub_nf (Fin.cons x (fun _ => t))).symm

/-- **k=1 future arm formula** (hook-discharge lemma 6/6, carrier): the Until-direction
    translation of `atom-layer ∧ aggPop1F` (exact dual; flipped origin guard as in
    `agg2Fut`). -/
noncomputable def kampArmFutureK1 (sub_nf : NormalForm sig 2 2) : Formula :=
  ((aggAtomK1Fut atomMap h_surj sub_nf).conjFull
    (aggPop1F atomMap h_surj sub_nf)).translateLeft

/-- **k=1 future-arm hook discharge** (hook-discharge lemma 6/6): the future-arm
    formula realizes the future disjunct of `kampPrior_site_trichotomy` at match arm
    k=1. Enters the skeleton via `VVecEA2.translateLeft_correct`
    (VecEATranslation.lean:549, Route V — dual); pins bridged by
    `aggOd_holdsLeft_iff_holds`; the population rides `aggPop1F_correct` (the
    `aggOdSwap12` transport of the SAME dispatcher — see the §10 decision record). -/
theorem kampArm_future_k1_correct (sub_nf : NormalForm sig 2 2) :
    ∀ (M : OrderedMonadicStructure sig),
      SemanticPriorUZ M atomMap → SemanticPriorSZ M atomMap →
      ∀ t : M.carrier,
      TemporalTruth M atomMap t (kampArmFutureK1 atomMap h_surj sub_nf) ↔
        ∃ x, t < x ∧ NfEvalNf M 2 2 (Fin.cons x (fun _ => t)) sub_nf := by
  intro M h_UZ h_SZ t
  unfold kampArmFutureK1
  rw [VVecEA2.translateLeft_correct, aggOd_holdsLeft_iff_holds]
  refine exists_congr fun x => and_congr_right fun htx => ?_
  rw [VVecEA2.conjFull_iff,
      aggAtomK1Fut_holds_iff atomMap h_surj M sub_nf x t htx,
      aggPop1F_correct atomMap h_surj M sub_nf h_UZ h_SZ x t htx]
  exact (aggOd_eval2_iff M sub_nf (Fin.cons x (fun _ => t))).symm

/-! ### Phase-16b shape certificates (drop-in citability without importing KampPrior)

Each `_correct` conclusion instantiated at the generic-site index `1 + 1` — the exact
match-arm shape of the `kampPrior_site_trichotomy` disjuncts
(`sub_nf : NormalForm sig (k+1) 2` at `k := 1`). KampPrior imports this module's
aggregator (not vice versa), so the certificates copy the disjunct statements
verbatim rather than applying the skeleton itself (delivered Phase-3/5 technique). -/

section ShapeCertificatesK1

variable (sub_nf1 : NormalForm sig (1 + 1) 2)
  (M : OrderedMonadicStructure sig)
  (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
  (t : M.carrier)

/-- Past disjunct shape at match arm k=1 (verbatim `kampPrior_site_trichotomy`
    disjunct 1). -/
example : TemporalTruth M atomMap t (kampArmPastK1 atomMap h_surj sub_nf1) ↔
    ∃ x, x < t ∧ NfEvalNf M (1 + 1) 2 (Fin.cons x (fun _ => t)) sub_nf1 :=
  kampArm_past_k1_correct atomMap h_surj sub_nf1 M h_UZ h_SZ t

/-- Future disjunct shape at match arm k=1 (verbatim disjunct 3). -/
example : TemporalTruth M atomMap t (kampArmFutureK1 atomMap h_surj sub_nf1) ↔
    ∃ x, t < x ∧ NfEvalNf M (1 + 1) 2 (Fin.cons x (fun _ => t)) sub_nf1 :=
  kampArm_future_k1_correct atomMap h_surj sub_nf1 M h_UZ h_SZ t

end ShapeCertificatesK1

end AggregateOffDiag

end FormalSystem.Metalogic.WeakCanonical.Kamp
