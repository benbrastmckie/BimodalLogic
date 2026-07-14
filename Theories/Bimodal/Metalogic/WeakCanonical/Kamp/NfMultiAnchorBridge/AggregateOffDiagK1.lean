import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAConjFull
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregatePointMergeK1
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNavPastK1
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNavFutK1
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregateHookDischarge

/-! # Off-diagonal k=1 aggregate: zone classifier + per-qnf dispatcher `C(qnf)` (task 350 Phase 16a)

The integration point over all channels of the k=1 population existential
`∃ w, nf_eval_nf M 1 3 [w, x, t] qnf` at the off-diagonal pin pair `x < t`
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
   nf_eval_nf M 1 2 [x, t] sub_nf` under the ambient `x < t` (the fixed-endpoint
   companion of the delivered `agg2Past_holdsRight_iff`; same fiber algebra, pins fixed).
5. **Point-channel carriers** `CAggPtX`/`CAggPtT`: the Phase-12a/12b gated collapses
   (`aggPm01ClauseK1`/`aggPm02ClauseK1` shapes) realized as `VVecEA2` via `agg2Past` on
   the collapsed arity-2 NF; non-fixpoint qnf gate to the empty disjunction.
6. **Interior channel** `CAggInt`: the delivered carrier `bracketEndChar_kv` at depth 1
   with `charF 0 := nf_depth0_char_formula atomMap h_surj` (`h0 := rfl`), consumed
   through `bracketEndChar_kv_correct_one_prior`.
7. **Dispatcher** `CAggOd (qnf) : VVecEA2` casing on the classifier rows, and the master
   **clause iff** `CAggOd_clause_iff`: under `x < t` and the Prior hypotheses,
   `(CAggOd qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M 1 3 [w, x, t] qnf` — every
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
- specs/350_…/plans/03_negfix-refactor-exterior-carriers.md, Phase 16a.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

section AggregateOffDiag

variable {sig : MonadicSignature}
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
(CarrierKv.lean:466) and reads the six order atoms (`atom_eval M env (.order i j _) =
env i < env j`, definitionally). -/

/-- A past-exterior realizer (`w < x`, ambient `x < t`) forces `navDOrderRow`. -/
theorem aggOd_navDRow_of_eval (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w x t : M.carrier) (hwx : w < x) (hxt : x < t)
    (h : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
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
    (h : nf_eval_nf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) σ) :
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
    (h : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
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
    (h : nf_eval_nf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) σ) :
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
    (h : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
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
    (h : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
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
  /-- `x < w < t` interior channel (`bracketEndChar_kv` at depth 1) -/
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

/-- Row → channel: `navDOrderRow` routes to `extPast`. -/
theorem aggOdClassify_extPast (σ : NormalForm sig 1 3) (h : navDOrderRow σ) :
    aggOdClassify σ = .extPast := by
  unfold aggOdClassify
  rw [if_pos h]

/-- Row → channel: `aggOdRowPtX` routes to `ptX` (clash with `navDOrderRow` on bit
    (0,1)). -/
theorem aggOdClassify_ptX (σ : NormalForm sig 1 3) (h : aggOdRowPtX σ) :
    aggOdClassify σ = .ptX := by
  unfold aggOdClassify
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.1), if_pos h]

/-- Row → channel: `aggOdRowInt` routes to `int` (clashes: (0,1) with `navDOrderRow`,
    (1,0) with `aggOdRowPtX`). -/
theorem aggOdClassify_int (σ : NormalForm sig 1 3) (h : aggOdRowInt σ) :
    aggOdClassify σ = .int := by
  unfold aggOdClassify
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash h.1 hp.2.1), if_pos h]

/-- Row → channel: `aggOdRowPtT` routes to `ptT` (clashes: (0,1) with `navDOrderRow`,
    (1,0) with `aggOdRowPtX`, (0,2) with `aggOdRowInt`). -/
theorem aggOdClassify_ptT (σ : NormalForm sig 1 3) (h : aggOdRowPtT σ) :
    aggOdClassify σ = .ptT := by
  unfold aggOdClassify
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash h.2.2.1 hp.2.1),
    if_neg (fun hi => aggOd_row_clash hi.2.1 h.1), if_pos h]

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
    ¬ nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ := by
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
    (h : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
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
    (h : nf_eval_nf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) σ) :
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
    (h : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
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
    (h : nf_eval_nf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) σ) :
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
    (h : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
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

/-- Mirror row → channel: `aggOdRowExtPastF` routes to `extPast`. -/
theorem aggOdClassifyF_extPast (σ : NormalForm sig 1 3) (h : aggOdRowExtPastF σ) :
    aggOdClassifyF σ = .extPast := by
  unfold aggOdClassifyF
  rw [if_pos h]

/-- Mirror row → channel: `aggOdRowPtTF` routes to `ptT` (clash on bit (0,2)). -/
theorem aggOdClassifyF_ptT (σ : NormalForm sig 1 3) (h : aggOdRowPtTF σ) :
    aggOdClassifyF σ = .ptT := by
  unfold aggOdClassifyF
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.1), if_pos h]

/-- Mirror row → channel: `aggOdRowIntF` routes to `int` (clashes: (0,2) with
    `aggOdRowExtPastF`, (2,0) with `aggOdRowPtTF`). -/
theorem aggOdClassifyF_int (σ : NormalForm sig 1 3) (h : aggOdRowIntF σ) :
    aggOdClassifyF σ = .int := by
  unfold aggOdClassifyF
  rw [if_neg (fun hd => aggOd_row_clash hd.1 h.2.2.2.1),
    if_neg (fun hp => aggOd_row_clash h.1 hp.2.1), if_pos h]

/-- Mirror row → channel: `aggOdRowPtXF` routes to `ptX` (clashes: (0,1) with
    `aggOdRowExtPastF`/`aggOdRowPtTF`, (0,1) with `aggOdRowIntF`). -/
theorem aggOdClassifyF_ptX (σ : NormalForm sig 1 3) (h : aggOdRowPtXF σ) :
    aggOdClassifyF σ = .ptX := by
  unfold aggOdClassifyF
  rw [if_neg (fun hd => aggOd_row_clash hd.2.1 h.1),
    if_neg (fun hp => aggOd_row_clash hp.2.2.1 h.1),
    if_neg (fun hi => aggOd_row_clash hi.2.1 h.1), if_pos h]

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
    (h : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) :
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
    ¬ nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ := by
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
`nf_eval_nf M 1 2 [x, t] sub_nf` — a TWO-PIN object. The delivered `agg2Past` carrier
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
      nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf := by
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
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
    simp only [agg2EpPastL, agg2EpPastR, TemporalPred.eval_at] at hepL hepR
    rw [formula_conjList_iff] at hepL hepR
    -- Heads: the off-diagonal atom loci.
    have hendp : temporal_truth M atomMap x
        (nf_char2_atom_offdiag_endpoint atomMap h_surj
          (sub_nf.1 : NormalForm sig 0 2)).formula :=
      hepL _ (List.mem_append_left _ List.mem_cons_self)
    have horig : temporal_truth M atomMap t
        (nf_char2_atom_offdiag_origin atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)) :=
      hepR _ (List.mem_append_left _ List.mem_cons_self)
    -- Fold-bit literal facts at the two anchors.
    have hPastLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap x
        (agg2Lit (agg2Bit sub_nf agg2ZPastPast χ)
          (Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top)) :=
      fun χ => hepL _ (List.mem_append_left _
        (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
    have hAtXLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap x
        (agg2Lit (agg2Bit sub_nf agg2ZAtXPast χ)
          (nf_depth0_char_formula atomMap h_surj χ)) :=
      fun χ => hepL _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
    have hAtTLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap t
        (agg2Lit (agg2Bit sub_nf agg2ZAtTPast χ)
          (nf_depth0_char_formula atomMap h_surj χ)) :=
      fun χ => hepR _ (List.mem_append_left _
        (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
    have hFutLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap t
        (agg2Lit (agg2Bit sub_nf agg2ZFutFut χ)
          (Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top)) :=
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
      show _ ↔ agg2Bit sub_nf zs χ = true
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
                simp only [agg2SegPast, TemporalPred.eval_at] at hseg
                rw [formula_conjList_iff] at hseg
                have hexcl := hseg _ (List.mem_map_of_mem (show χ ∈ _ by simp))
                rw [if_neg (by simp [hbb])] at hexcl
                exact hexcl ((hchar χ u).mpr hev)
              · -- Witness slot: distinct complete 1-types exclude each other.
                obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hpmem
                have hev' : nf_eval_nf M 0 1 (fun _ => u) χ' := (hchar χ' u).mp hpe
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
    have h_atom : nf_eval_nf M 0 2 (Fin.cons x (fun _ => t))
        (sub_nf.1 : NormalForm sig 0 2) := h_atom_raw
    -- Fiber clauses in fold-bit form.
    have hzone' : ∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
        (∃ u : M.carrier,
          zoneHolds M (Fin.cons x (fun _ => t)) zs u ∧
          nf_eval_nf M 0 1 (fun _ => u) χ) ↔
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
        ∃ u, x < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
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
        (agg2SegPast atomMap h_surj sub_nf).eval_at M atomMap u := by
      intro u hxu hut
      simp only [agg2SegPast, TemporalPred.eval_at]
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
    have hepL : (agg2EpPastL atomMap h_surj sub_nf).eval_at M atomMap x := by
      simp only [agg2EpPastL, TemporalPred.eval_at]
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
    have hepR : (agg2EpPastR atomMap h_surj sub_nf).eval_at M atomMap t := by
      simp only [agg2EpPastR, TemporalPred.eval_at]
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
          (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
          (ps.map Prod.fst))[i]'hi =
          ⟨nf_depth0_char_formula atomMap h_surj ((ps[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (ps.map Prod.snd)[i]'(by simpa using hi') = (ps[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hprops _ (List.getElem_mem _)).2

end AggregateOffDiag

end Bimodal.Metalogic.WeakCanonical.Kamp
