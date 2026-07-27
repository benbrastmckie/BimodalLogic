/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorZoneTriage

/-! # One-Sided Exterior Complement Clauses — R2 GO/NO-GO Spike (Phase 2)

The future-side (`t < x1`) spike for the model-independent one-sided complement clauses
(Rabinovich 2014, Cor 5.4(1)/(2) exterior analogs, p.9; Lemma 7.10 TL-expressibility, p.15):
ONE concrete `zFutT3`-marked σ-family with BOTH directions (`_sound` + `_complete`) proved
sorry-free, in the signature that becomes BINDING for Phases 3-6.

## The spike σ

`kvE2_futSpikeSigma qnf χmid χfr : NormalForm sig 1 4` — the `zFutT3`-marked depth-1 form
whose realization at env `[x1, w, x, t]` says exactly:

- base atoms of `[w, x, t]` are `qnf.1` (env-compatible by construction);
- `x1` carries the monadic profile `χfr`;
- the gap `(t, x1)` is nonempty and consists EXCLUSIVELY of `χmid`-profile points;
- the ray `(x1, ∞)` is empty (`x1` is a right endpoint of the order);
- every at-or-below-`t` inner zone carries exactly the content qnf's positive layer
  prescribes (`kvE2_futAnyBit`, the depth-0 zone-fact read of `qnf`).

This is NOT a degenerate σ (R3): its inner layer `σ.2` genuinely prescribes depth-1
inner-zone content in all nine zones of `[x1, w, x, t]`, and the correctness proofs
exercise the full `nf_eval_depth1_fold_iff` fold clause (CarrierKv.lean:466) over every
`ZoneSpec 4 × NormalForm sig 0 1` pair.

## The clause

`kvE2_extNegFutSpike atomMap h_surj χmid χfr : Formula` — anchored at `t`,
`Until`-navigated: the negation of the 2-link F-chain
`U(χmid ∧ U(χfr ∧ ¬F⊤, χmid), χmid)` — Lemma 5.3's O_n / F-chain device (the landed
`fChainFrom` shape, EANegation.lean:552) instantiated at chain length 2 over the one-sided
interval `(t, ∞)`, with depth-0 characteristic guards (`nf_depth0_char_formula`). The
formula is a fixed syntactic object in `(atomMap, h_surj, χmid, χfr)` — model-independent
in exactly the sense of the landed gate formulas.

## BINDING SIGNATURE (Phases 3-6; H6 convergence policing applies)

Both directions are stated under the **gate-level pin inventory**:

- `hxw : x < w`, `hwt : w < t` — the binder's order bits;
- `henv : ∀ a : AtomKind sig 3, atom_eval M [w,x,t] a ↔ qnf.1 a = true` — the anchor-base
  pin (at the SW:12788 `hexclExt` site: pred parts from the `EpL`/`EpR`/`ptW` endpoint
  1-type conjuncts, order parts from `hxw`/`hwt` + the six qnf order-bit hypotheses; at
  the Phase-8 ⇐ site: verbatim `hq.1` of realized qnf);
- `hbelow : ∀ zs χ, (zs ⟨2,_⟩).2 = false → ((∃ v, zoneHolds M [w,x,t] zs v ∧
  nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true)` — the at-or-below-`t`
  zone-fact pin, keyed SYNTACTICALLY to qnf (at the Phase-8 ⇐ site this is
  `kvE2_futAnyBit_correct` below, from realized qnf; at the SW:12788 site it is derivable
  from the gate-level inventory: `(x,w)`/`(w,t)` facts from `hexcl` + `hrealI` + Phase-1
  zone determination, below-`x` facts from the `EpL` `zPastX3` literals, at-point facts
  from the endpoint 1-type conjuncts — the Phase-8 derivation obligation recorded in the
  phase handoff).

**Why the pins are irreducible (the R2 finding, machine-grade counterexample shapes)**:
the plan's bare-binder converse `(∀ x1 > t, ¬ realize) → clause` is FALSE as stated, for
EVERY clause expressible at `t`:

1. *Anchor-base escape*: in a model whose `[w,x,t]` base atoms differ from `qnf.1`
   (nothing in the `hexclExt` binder inventory pins the predicate profile of `x`), σ is
   unrealizable for the invisible reason, while the `(t,∞)`-side content of the clause can
   be genuinely satisfied — so `¬∃`-shaped clause content is false while the hypothesis
   holds. `henv` closes exactly this escape.
2. *Below-`t` bit-flip*: for σ' := the realized characteristic of `[x1,w,x,t]` with ONE
   at-or-below-`t` inner-zone bit flipped, σ' is bit-false and `zFutT3`-marked, its
   `(t,∞)`-side content is realized (by the very witness of the characteristic), and its
   defect is invisible from `t` — no `t`-anchored formula separates σ' from the
   characteristic. `hbelow` (+ the syntactic `kvE2_futAnyBit` comparison inside `σ.2`)
   closes this escape.

Per the plan's NO-GO protocol step 2, this conditional-completeness narrowing — the pins
are exactly "the gate-level hypotheses actually available at the sole consumption site" —
is the sanctioned GO-conditional outcome: **verdict GO-conditional**, recorded in the
Phase-2 progress file and handoff.

`_complete` is additionally packaged as `kvE2_extNegFutSpike_complete_of_realized`
(hypotheses: realized qnf + `qnf.2 σ = false` only) — the exact shape Phase 8's ⇐ half
consumes. `HasAttainedINF`/`prior_hasAttainedINF` are NOT needed at this rung: the spike
chain is finite and the ray emptiness is a plain `¬F⊤`; Dedekind-completeness enters only
if/when Phase 3 meets unbounded positive content (recorded for Phase 3's budget).

Purely additive leaf module (H7 territory: this file + additive import wiring only). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-- `ZoneSpec n` equality is decidable (file-local mirror of the private SW:61 bridge). -/
private instance {n : Nat} : DecidableEq (ZoneSpec n) :=
  -- `inferInstanceAs`, not `decidable_of_iff (∀ i, a i = b i) …`: the latter needs
  -- `Decidable (∀ i : Fin n, a i = b i)`, which instance search cannot build without
  -- unfolding the semireducible `ZoneSpec`. Naming the unfolded type sidesteps that.
  inferInstanceAs (DecidableEq (Fin n → Bool × Bool))

/-! ## Depth-0 zone-fact read of qnf (the syntactic below-`t` comparison channel) -/

/-- Whether qnf's positive depth-1 layer prescribes a point of monadic profile `χ` in the
    outer zone `zs` of `[w,x,t]`: some positive σ' sits in zone `zs` with fresh profile
    `χ`. Under realized qnf this Bool IS the depth-0 zone fact
    (`kvE2_futAnyBit_correct`) — the syntactic device that lets `σ.2`'s at-or-below-`t`
    bits be compared against qnf without any semantic hypothesis. -/
noncomputable def kvE2_futAnyBit {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (zs : ZoneSpec 3) (χ : NormalForm sig 0 1) : Bool :=
  (kvE2_sepPos qnf).any fun σ' =>
    decide (nf0_zoneSpec σ'.1 = zs) && decide (nf0_projFresh σ'.1 = χ)

/-- Monadic-profile evaluation unfolds to the per-predicate reading (the `AtomKind sig 1`
    order case is uninhabited). -/
private theorem nf_eval_profile_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v : M.carrier) (χ : NormalForm sig 0 1) :
    nf_eval_nf M 0 1 (fun _ => v) χ ↔
      (∀ p : sig.preds, M.interp p v ↔ χ (.pred p 0) = true) := by
  constructor
  · intro h p
    exact h (.pred p 0)
  · intro h a
    match a with
    | .pred p i =>
      have hi : i = 0 := Subsingleton.elim i 0
      subst hi
      exact h p
    | .order i j hij => exact absurd (Subsingleton.elim i j) hij

/-- Profiles realized by the same point coincide. -/
private theorem nf_profile_unique {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v : M.carrier) (χ χ' : NormalForm sig 0 1)
    (h : nf_eval_nf M 0 1 (fun _ => v) χ) (h' : nf_eval_nf M 0 1 (fun _ => v) χ') :
    χ = χ' := by
  funext a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    have := ((h (.pred p 0)).symm.trans (h' (.pred p 0)))
    cases hχ : χ (.pred p 0) <;> cases hχ' : χ' (.pred p 0) <;> simp_all
  | .order i j hij => exact absurd (Subsingleton.elim i j) hij

/-- Every point realizes its depth-0 monadic characteristic. -/
private theorem nf_profile_exists {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v : M.carrier) :
    ∃ χ : NormalForm sig 0 1, nf_eval_nf M 0 1 (fun _ => v) χ :=
  ⟨nf_characteristic M 0 1 (fun _ => v), nf_characteristic_satisfies M 0 1 (fun _ => v)⟩

/-- **`kvE2_futAnyBit` honesty** (Cor 5.4 zone-fact channel): under realized qnf, the
    syntactic bit reads the actual depth-0 zone fact of `[w,x,t]` — for EVERY `zs`. The
    Phase-8 ⇐ half derives the `hbelow` pin from this; the SW:12788-side derivation from
    `hexcl`/`hrealI`/`EpL` is the recorded Phase-8 obligation. -/
theorem kvE2_futAnyBit_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (qnf : NormalForm sig 2 3)
    (hq : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3) (χ : NormalForm sig 0 1) :
    (∃ v : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) ↔
      kvE2_futAnyBit qnf zs χ = true := by
  obtain ⟨-, hquant⟩ := hq
  constructor
  · rintro ⟨v, hzone, hprof⟩
    -- v realizes its depth-1 characteristic over [w,x,t]; qnf's quant layer makes it
    -- positive; its channels read back zs and χ.
    set σv : NormalForm sig 1 4 :=
      nf_characteristic M 1 4 (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t)))) with hσv
    have hsat := nf_characteristic_satisfies M 1 4
      (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))
    have hpos : qnf.2 σv = true := (hquant σv).mp ⟨v, hσv ▸ hsat⟩
    obtain ⟨hatom, -⟩ := hsat
    have hmem : σv ∈ kvE2_sepPos qnf := by
      simp only [kvE2_sepPos]
      exact List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ σv), hpos⟩
    refine List.any_eq_true.mpr ⟨σv, hmem, ?_⟩
    rw [Bool.and_eq_true]
    refine ⟨decide_eq_true ?_, decide_eq_true ?_⟩
    · -- ordering channel: read the couplings straight from `hatom` (no simp — that would
      -- unfold σv.1 into `decide` and desync). `atom_eval`/`Fin.cons` reductions and
      -- `nf0_zoneSpec`'s definition make the middle terms defeq, so `Iff.trans` unifies.
      funext i
      have hz := hzone i
      have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
      have h2 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
      change (σv.1 (.order 0 i.succ (Fin.succ_ne_zero i).symm),
            σv.1 (.order i.succ 0 (Fin.succ_ne_zero i))) = zs i
      exact Prod.ext (Bool.eq_iff_iff.mpr (h1.symm.trans hz.1))
        (Bool.eq_iff_iff.mpr (h2.symm.trans hz.2))
    · -- point-type channel: σv's fresh profile is v's profile = χ
      refine nf_profile_unique M v _ χ ?_ hprof
      rw [nf_eval_profile_iff]
      intro p
      exact hatom (.pred p 0)
  · intro hbit
    obtain ⟨σ', hmem, hread⟩ := List.any_eq_true.mp hbit
    rw [Bool.and_eq_true] at hread
    obtain ⟨hzsb, hχb⟩ := hread
    have hzs : nf0_zoneSpec σ'.1 = zs := of_decide_eq_true hzsb
    have hχ : nf0_projFresh σ'.1 = χ := of_decide_eq_true hχb
    have hpos : qnf.2 σ' = true := by
      have := List.mem_filter.mp (by simpa only [kvE2_sepPos] using hmem)
      exact this.2
    obtain ⟨u, hu⟩ := (hquant σ').mpr hpos
    obtain ⟨hatom, -⟩ := hu
    refine ⟨u, fun i => ?_, ?_⟩
    · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
      have h2 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
      simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1 h2
      have hzi := congrFun hzs i
      have e1 : σ'.1 (.order 0 i.succ (Fin.succ_ne_zero i).symm) = (zs i).1 :=
        (congrArg Prod.fst hzi)
      have e2 : σ'.1 (.order i.succ 0 (Fin.succ_ne_zero i)) = (zs i).2 :=
        (congrArg Prod.snd hzi)
      exact ⟨h1.trans (by rw [e1]), h2.trans (by rw [e2])⟩
    · rw [← hχ, nf_eval_profile_iff]
      intro p
      have := hatom (.pred p 0)
      simpa only [atom_eval, Fin.cons_zero, nf0_projFresh] using this

/-! ## The spike σ -/

/-- Base layer of the spike σ: `zFutT3` fresh-coupling bits, fresh profile `χfr`, and
    qnf's own base as the `[w,x,t]` restriction (env-compatible by construction — the
    Def 3.1 channel assembly, `NfEFold.lean:180`). -/
def kvE2_futSpikeBase {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (χfr : NormalForm sig 0 1) : NormalForm sig 0 4 :=
  nf0_assemble kvE2_sep_zFutT3 χfr qnf.1

/-- The spike σ is `zFutT3`-marked (round-trip 1, `NfEFold.lean:197`). -/
theorem kvE2_futSpikeBase_zone {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (χfr : NormalForm sig 0 1) :
    nf0_zoneSpec (kvE2_futSpikeBase qnf χfr) = kvE2_sep_zFutT3 :=
  nf0_zoneSpec_assemble _ _ _

/-- Inner zone-bit prescription of the spike σ: at-or-below-`t` zones carry qnf's own
    zone facts (`kvE2_futAnyBit`), the gap `(t,x1)` is all-and-only `χmid`, the fresh
    point carries `χfr`, the ray `(x1,∞)` and every other pattern are empty. Zone-4
    coordinates: `0 ↦ x1`, `1 ↦ w`, `2 ↦ x`, `3 ↦ t`; an at-or-below-`t` witness couples
    to `x1` as `(true, false)`.

    The `show ZoneSpec 4 from` ascriptions are load-bearing. Written bare, `Fin.cons p z3` has
    the inferred type `(i : Fin 4) → (fun _ => Bool × Bool) i`, which is only definitionally the
    `ZoneSpec 4` the equation is stated at; `Decidable` synthesis type-checks its goal at
    `instances` transparency, does not unfold the semireducible `ZoneSpec`, and aborts before the
    `DecidableEq (ZoneSpec n)` bridge above is tried. Note that a parenthesised ascription is not
    enough — only `show … from` propagates the expected type far enough. -/
noncomputable def kvE2_futSpikeZoneBit {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (χmid χfr : NormalForm sig 0 1)
    (zs : ZoneSpec 4) (χ : NormalForm sig 0 1) : Bool :=
  if zs = show ZoneSpec 4 from Fin.cons (true, false) kvE2_sep_zPastX3 then kvE2_futAnyBit qnf
      kvE2_sep_zPastX3 χ
  else if zs = show ZoneSpec 4 from Fin.cons (true, false) kvE2_sep_zAtX3 then kvE2_futAnyBit qnf
      kvE2_sep_zAtX3 χ
  else if zs = show ZoneSpec 4 from Fin.cons (true, false) kvE2_sep_zXW3 then kvE2_futAnyBit qnf
      kvE2_sep_zXW3 χ
  else if zs = show ZoneSpec 4 from Fin.cons (true, false) kvE2_sep_zAtW3 then kvE2_futAnyBit qnf
      kvE2_sep_zAtW3 χ
  else if zs = show ZoneSpec 4 from Fin.cons (true, false) kvE2_sep_zWT3 then kvE2_futAnyBit qnf
      kvE2_sep_zWT3 χ
  else if zs = show ZoneSpec 4 from Fin.cons (true, false) kvE2_sep_zAtT3 then kvE2_futAnyBit qnf
      kvE2_sep_zAtT3 χ
  else if zs = show ZoneSpec 4 from Fin.cons (true, false) kvE2_sep_zFutT3 then decide (χ = χmid)
  else if zs = show ZoneSpec 4 from Fin.cons (false, false) kvE2_sep_zFutT3 then decide (χ = χfr)
  else false

/-- **The spike σ** (`NormalForm sig 1 4`): base = `kvE2_futSpikeBase`, quant layer =
    the channel-split read of `kvE2_futSpikeZoneBit` (off-fiber false by construction —
    the `nf0_split_assemble` bijection makes this lossless). -/
noncomputable def kvE2_futSpikeSigma {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (χmid χfr : NormalForm sig 0 1) : NormalForm sig 1 4 :=
  (kvE2_futSpikeBase qnf χfr,
   fun τ => decide (nf0_dropFresh τ = kvE2_futSpikeBase qnf χfr) &&
     kvE2_futSpikeZoneBit qnf χmid χfr (nf0_zoneSpec τ) (nf0_projFresh τ))

/-- The spike σ's fold-bit read computes to the zone-bit prescription (round-trips 1-3). -/
theorem kvE2_futSpikeSigma_bits {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (χmid χfr : NormalForm sig 0 1)
    (zs : ZoneSpec 4) (χ : NormalForm sig 0 1) :
    (kvE2_futSpikeSigma qnf χmid χfr).2
        (nf0_assemble zs χ (kvE2_futSpikeSigma qnf χmid χfr).1) =
      kvE2_futSpikeZoneBit qnf χmid χfr zs χ := by
  change (decide (nf0_dropFresh (nf0_assemble zs χ (kvE2_futSpikeBase qnf χfr)) =
      kvE2_futSpikeBase qnf χfr) &&
    kvE2_futSpikeZoneBit qnf χmid χfr
      (nf0_zoneSpec (nf0_assemble zs χ (kvE2_futSpikeBase qnf χfr)))
      (nf0_projFresh (nf0_assemble zs χ (kvE2_futSpikeBase qnf χfr)))) = _
  rw [nf0_dropFresh_assemble, nf0_zoneSpec_assemble, nf0_projFresh_assemble,
    decide_eq_true rfl, Bool.true_and]

/-! ## The clause (2-link F-chain over `(t, ∞)`, Lemma 5.3 / Lemma 7.10 shape) -/

/-- Fresh-endpoint description: profile `χfr` and an empty future ray (`¬F⊤`). -/
noncomputable def kvE2_futSpikeEnd {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (χfr : NormalForm sig 0 1) : Formula :=
  formula_conjList
    [nf_depth0_char_formula atomMap h_surj χfr,
     (Formula.untl Formula.top Formula.top).neg]

/-- Positive local-existence form: `U(χmid ∧ U(end, χmid), χmid)` at `t` — "some
    `χmid`-point `s` and endpoint `x1 > s` with `(t,x1)` all-`χmid`, `x1` of profile
    `χfr`, and nothing above `x1`". The length-2 instance of the Cor 5.4 O_n / F-chain
    device over `(t, ∞)`. -/
noncomputable def kvE2_futSpikePos {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (χmid χfr : NormalForm sig 0 1) : Formula :=
  Formula.untl
    (formula_conjList
      [nf_depth0_char_formula atomMap h_surj χmid,
       Formula.untl (kvE2_futSpikeEnd atomMap h_surj χfr)
         (nf_depth0_char_formula atomMap h_surj χmid)])
    (nf_depth0_char_formula atomMap h_surj χmid)

/-- **The spike complement clause** (Cor 5.4(2) exterior analog): the negation of the
    positive local-existence form, anchored at `t`. -/
noncomputable def kvE2_extNegFutSpike {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (χmid χfr : NormalForm sig 0 1) : Formula :=
  (kvE2_futSpikePos atomMap h_surj χmid χfr).neg

/-! ## Zone bookkeeping helpers -/

/-- A point strictly above `t` (with `x < w < t`) couples to `[w,x,t]` as `zFutT3` and
    to `x1` by the given pair — the canonical zone-4 spec of each `(t,∞)`-side position. -/
private theorem kvE2_futZone4_of_above {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (htv : t < v)
    (p0 : Bool × Bool)
    (h0a : v < x1 ↔ p0.1 = true) (h0b : x1 < v ↔ p0.2 = true) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      (Fin.cons p0 kvE2_sep_zFutT3) v := by
  intro i
  match i with
  | ⟨0, _⟩ => exact ⟨h0a, h0b⟩
  | ⟨1, _⟩ =>
    exact ⟨iff_of_false (lt_asymm (hwt.trans htv)) Bool.false_ne_true,
           iff_of_true (hwt.trans htv) rfl⟩
  | ⟨2, _⟩ =>
    exact ⟨iff_of_false (lt_asymm ((hxw.trans hwt).trans htv)) Bool.false_ne_true,
           iff_of_true ((hxw.trans hwt).trans htv) rfl⟩
  | ⟨3, _⟩ =>
    exact ⟨iff_of_false (lt_asymm htv) Bool.false_ne_true, iff_of_true htv rfl⟩

/-- An at-or-below-`t` zone-3 witness sits below any `x1 > t`: read `¬(t < v)` off the
    zone-3 spec's third pair. -/
private theorem kvE2_futBelow_le_t {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (zs : ZoneSpec 3) (hz3 : (zs ⟨2, by omega⟩).2 = false) (v : M.carrier)
    (hzone : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v) :
    v ≤ t := by
  have h := (hzone ⟨2, by omega⟩).2
  rw [hz3] at h
  by_contra hc
  exact absurd (h.mp (not_le.mp hc)) Bool.false_ne_true

/-- Lift an at-or-below-`t` zone-3 fact to the corresponding zone-4 fact (coupling
    `(true, false)` to a fresh `x1 > t`), and back. -/
private theorem kvE2_futZone4_below_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier) (htx1 : t < x1)
    (zs : ZoneSpec 3) (hz3 : (zs ⟨2, by omega⟩).2 = false) (v : M.carrier) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (true, false) zs) v ↔
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v := by
  constructor
  · intro h i
    have := h i.succ
    exact this
  · intro h i
    match i with
    | ⟨0, _⟩ =>
      have hle := (kvE2_futBelow_le_t M w x t zs hz3 v h).trans_lt htx1
      exact ⟨iff_of_true hle rfl, iff_of_false (lt_asymm hle) Bool.false_ne_true⟩
    | ⟨1, _⟩ => exact h ⟨0, by omega⟩
    | ⟨2, _⟩ => exact h ⟨1, by omega⟩
    | ⟨3, _⟩ => exact h ⟨2, by omega⟩

/-- The six at-or-below-`t` outer zone-3 constants all have third-pair second component
    `false` (the `kvE2_futBelow_le_t` key). -/
private theorem kvE2_futBelowSpec_zPastX3 : (kvE2_sep_zPastX3 ⟨2, by omega⟩).2 = false := rfl
private theorem kvE2_futBelowSpec_zAtX3 : (kvE2_sep_zAtX3 ⟨2, by omega⟩).2 = false := rfl
private theorem kvE2_futBelowSpec_zXW3 : (kvE2_sep_zXW3 ⟨2, by omega⟩).2 = false := rfl
private theorem kvE2_futBelowSpec_zAtW3 : (kvE2_sep_zAtW3 ⟨2, by omega⟩).2 = false := rfl
private theorem kvE2_futBelowSpec_zWT3 : (kvE2_sep_zWT3 ⟨2, by omega⟩).2 = false := rfl
private theorem kvE2_futBelowSpec_zAtT3 : (kvE2_sep_zAtT3 ⟨2, by omega⟩).2 = false := rfl

/-- Zone-4 characterization: a `zoneHolds` spec is pointwise forced by the witness's
    actual order relations (the ExteriorZoneTriage bit-transfer idiom on `zoneHolds`). -/
private theorem kvE2_futCharZone4 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier) (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v)
    (p0 p1 p2 p3 : Bool × Bool)
    (h0a : v < x1 ↔ p0.1 = true) (h0b : x1 < v ↔ p0.2 = true)
    (h1a : v < w ↔ p1.1 = true) (h1b : w < v ↔ p1.2 = true)
    (h2a : v < x ↔ p2.1 = true) (h2b : x < v ↔ p2.2 = true)
    (h3a : v < t ↔ p3.1 = true) (h3b : t < v ↔ p3.2 = true) :
    zs = Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3))) := by
  funext i
  match i with
  | ⟨0, _⟩ =>
    have hz0 := hz ⟨0, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz0.1.symm.trans h0a))
      (Bool.eq_iff_iff.mpr (hz0.2.symm.trans h0b))
  | ⟨1, _⟩ =>
    have hz1 := hz ⟨1, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz1.1.symm.trans h1a))
      (Bool.eq_iff_iff.mpr (hz1.2.symm.trans h1b))
  | ⟨2, _⟩ =>
    have hz2 := hz ⟨2, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz2.1.symm.trans h2a))
      (Bool.eq_iff_iff.mpr (hz2.2.symm.trans h2b))
  | ⟨3, _⟩ =>
    have hz3 := hz ⟨3, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz3.1.symm.trans h3a))
      (Bool.eq_iff_iff.mpr (hz3.2.symm.trans h3b))

/-- Zone-3 spec construction from an at-or-below-`t` position (used to feed `hbelow`). -/
private theorem kvE2_futCharZone3 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v w x t : M.carrier)
    (p0 p1 p2 : Bool × Bool)
    (h0a : v < w ↔ p0.1 = true) (h0b : w < v ↔ p0.2 = true)
    (h1a : v < x ↔ p1.1 = true) (h1b : x < v ↔ p1.2 = true)
    (h2a : v < t ↔ p2.1 = true) (h2b : t < v ↔ p2.2 = true) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
      (Fin.cons p0 (Fin.cons p1 (fun _ => p2)) : ZoneSpec 3) v := by
  intro i
  match i with
  | ⟨0, _⟩ => exact ⟨h0a, h0b⟩
  | ⟨1, _⟩ => exact ⟨h1a, h1b⟩
  | ⟨2, _⟩ => exact ⟨h2a, h2b⟩

/-! ## Zone-bit computations of the spike σ -/

/-- Depth-0 characteristic-formula correctness in `nf_eval` form (a repackaging of
    `nf_depth0_char_formula_correct` via `nf_eval_profile_iff`). -/
theorem nf_depth0_char_correct' {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  rw [nf_depth0_char_formula_correct]
  exact (nf_eval_profile_iff M u χ).symm

/-- Gap zone `(t, x1)` (coupling `(true,false)` to x1, `zFutT3` to `[w,x,t]`): the spike
    prescribes only `χmid` there. -/
theorem futZoneBit_gap {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (χmid χfr χ : NormalForm sig 0 1) :
    kvE2_futSpikeZoneBit qnf χmid χfr (Fin.cons (true, false) kvE2_sep_zFutT3) χ =
      decide (χ = χmid) := by
  rfl

/-- Fresh-point self-zone `v = x1` (coupling `(false,false)` to x1, `zFutT3` to `[w,x,t]`):
    the spike prescribes profile `χfr`. -/
theorem futZoneBit_selfx1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (χmid χfr χ : NormalForm sig 0 1) :
    kvE2_futSpikeZoneBit qnf χmid χfr (Fin.cons (false, false) kvE2_sep_zFutT3) χ =
      decide (χ = χfr) := by
  rfl

/-- Ray zone `(x1, ∞)` (coupling `(false,true)` to x1): empty — the spike forces `x1`
    to be a maximum. -/
theorem futZoneBit_ray {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (χmid χfr χ : NormalForm sig 0 1) :
    kvE2_futSpikeZoneBit qnf χmid χfr (Fin.cons (false, true) kvE2_sep_zFutT3) χ = false := by
  rfl

/-- An at-or-below-`t` zone (coupling `(true,false)` to x1, zone-3 spec `zs` to `[w,x,t]`
    with `(zs 2).2 = false`): the spike reads qnf's own zone fact `kvE2_futAnyBit`. -/
theorem futZoneBit_below {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (χmid χfr χ : NormalForm sig 0 1) (zs : ZoneSpec 3)
    (hzs : zs = kvE2_sep_zPastX3 ∨ zs = kvE2_sep_zAtX3 ∨ zs = kvE2_sep_zXW3 ∨
      zs = kvE2_sep_zAtW3 ∨ zs = kvE2_sep_zWT3 ∨ zs = kvE2_sep_zAtT3) :
    kvE2_futSpikeZoneBit qnf χmid χfr (Fin.cons (true, false) zs) χ =
      kvE2_futAnyBit qnf zs χ := by
  rcases hzs with h | h | h | h | h | h <;> subst h <;> rfl

/-! ## Soundness of the spike clause -/

/-- **Spike soundness** (Cor 5.4(2) exterior analog, ⇒): if the complement clause holds at
    the right anchor `t`, then no exterior point `x1 > t` realizes the spike σ. Uses only
    the order bits `hxw`/`hwt` (the `hexclExt` binder inventory) — no semantic hypothesis on
    `M`. This direction discharges `hexclExt` for the spike σ. -/
theorem kvE2_extNegFutSpike_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) (χmid χfr : NormalForm sig 0 1)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap t (kvE2_extNegFutSpike atomMap h_surj χmid χfr)) :
    ∀ x1 : M.carrier, t < x1 →
      ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
          (kvE2_futSpikeSigma qnf χmid χfr) := by
  intro x1 htx1 hnf
  obtain ⟨hatomσ, hquantσ, -⟩ :=
    (nf_eval_depth1_fold_iff M _ (kvE2_futSpikeSigma qnf χmid χfr)).mp hnf
  have hbit : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) ↔
      kvE2_futSpikeZoneBit qnf χmid χfr zs χ = true := by
    intro zs χ
    rw [hquantσ zs χ, kvE2_futSpikeSigma_bits]
  -- every strictly-interior gap point (t, x1) carries profile χmid
  have hmidgap : ∀ r : M.carrier, t < r → r < x1 →
      temporal_truth M atomMap r (nf_depth0_char_formula atomMap h_surj χmid) := by
    intro r htr hrx1
    have hzr := kvE2_futZone4_of_above M r x1 w x t hxw hwt htr (true, false)
      (iff_of_true hrx1 rfl) (iff_of_false (lt_asymm hrx1) Bool.false_ne_true)
    obtain ⟨χr, hχr⟩ := nf_profile_exists M r
    have hb := (hbit (Fin.cons (true, false) kvE2_sep_zFutT3) χr).mp ⟨r, hzr, hχr⟩
    rw [futZoneBit_gap] at hb
    have heq : χr = χmid := of_decide_eq_true hb
    rw [heq] at hχr
    exact (nf_depth0_char_correct' M atomMap h_surj χmid r).mpr hχr
  -- the fresh point x1 carries profile χfr
  have hx1fr : nf_eval_nf M 0 1 (fun _ => x1) χfr := by
    rw [nf_eval_profile_iff]; intro p; exact hatomσ (.pred p 0)
  -- x1 is a maximum: no point lies strictly above it
  have hnoabove : ∀ s : M.carrier, ¬ x1 < s := by
    intro s hs
    obtain ⟨χs, hχs⟩ := nf_profile_exists M s
    have hzs := kvE2_futZone4_of_above M s x1 w x t hxw hwt (htx1.trans hs) (false, true)
      (iff_of_false (lt_asymm hs) Bool.false_ne_true) (iff_of_true hs rfl)
    have hb := (hbit (Fin.cons (false, true) kvE2_sep_zFutT3) χs).mp ⟨s, hzs, hχs⟩
    rw [futZoneBit_ray] at hb
    exact Bool.noConfusion hb
  -- a gap χmid witness exists
  obtain ⟨s0, hzs0, hs0mid⟩ :=
    (hbit (Fin.cons (true, false) kvE2_sep_zFutT3) χmid).mpr (by
      rw [futZoneBit_gap]; exact decide_eq_true rfl)
  have hz0 := hzs0 ⟨0, by omega⟩
  have hz3 := hzs0 ⟨3, by omega⟩
  have hts0 : t < s0 := hz3.2.mpr rfl
  have hs0x1 : s0 < x1 := hz0.1.mpr rfl
  -- assemble the positive local-existence witness, contradicting the clause
  refine hcl ?_
  simp only [kvE2_futSpikePos]
  refine ⟨s0, hts0, ?_, fun r htr hrs0 => hmidgap r htr (hrs0.trans hs0x1)⟩
  rw [formula_conjList_iff]
  intro f hf
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
  rcases hf with rfl | rfl
  · exact (nf_depth0_char_correct' M atomMap h_surj χmid s0).mpr hs0mid
  · -- inner Until: x1 is the endpoint witness above s0
    refine ⟨x1, hs0x1, ?_, fun r hs0r hrx1 => hmidgap r (hts0.trans hs0r) hrx1⟩
    simp only [kvE2_futSpikeEnd]
    rw [formula_conjList_iff]
    intro g hg
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hg
    rcases hg with rfl | rfl
    · exact (nf_depth0_char_correct' M atomMap h_surj χfr x1).mpr hx1fr
    · -- ¬ F⊤ at x1 : no future point
      intro hF
      obtain ⟨s, hs, -, -⟩ := hF
      exact hnoabove s hs

/-! ## Completeness of the spike clause (under the gate-level pins) -/

/-- Atom-layer match for a maximal exterior point `x1` of profile `χfr` over an anchor base
    pinned to `qnf.1` (henv). This is the `nf_eval` atom clause of the spike σ. -/
theorem kvE2_futSpikeSigma_atom {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3) (χmid χfr : NormalForm sig 0 1)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hx1fr : nf_eval_nf M 0 1 (fun _ => x1) χfr) :
    ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔
        (kvE2_futSpikeSigma qnf χmid χfr).1 a = true := by
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    change M.interp p x1 ↔ χfr (.pred p 0) = true
    have := hx1fr (.pred p 0)
    simpa only [atom_eval, Fin.cons_zero] using this
  | .pred p ⟨i + 1, hi⟩ =>
    change M.interp p ((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨i, by omega⟩)
      ↔ qnf.1 (.pred p ⟨i, by omega⟩) = true
    have := henv (.pred p ⟨i, by omega⟩)
    simpa only [atom_eval] using this
  | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
  | .order ⟨0, _⟩ ⟨j + 1, hj⟩ h =>
    change (x1 < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨j, by omega⟩)
      ↔ (kvE2_sep_zFutT3 ⟨j, by omega⟩).1 = true
    refine iff_of_false ?_ (by
      show ¬ ((kvE2_sep_zFutT3 ⟨j, by omega⟩).1 = true)
      match j, hj with
      | 0, _ => exact Bool.false_ne_true
      | 1, _ => exact Bool.false_ne_true
      | 2, _ => exact Bool.false_ne_true)
    match j, hj with
    | 0, _ => exact lt_asymm (hwt.trans htx1)
    | 1, _ => exact lt_asymm ((hxw.trans hwt).trans htx1)
    | 2, _ => exact lt_asymm htx1
  | .order ⟨i + 1, hi⟩ ⟨0, _⟩ h =>
    change ((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨i, by omega⟩ < x1)
      ↔ (kvE2_sep_zFutT3 ⟨i, by omega⟩).2 = true
    refine iff_of_true ?_ (by
      show (kvE2_sep_zFutT3 ⟨i, by omega⟩).2 = true
      match i, hi with
      | 0, _ => rfl
      | 1, _ => rfl
      | 2, _ => rfl)
    match i, hi with
    | 0, _ => exact hwt.trans htx1
    | 1, _ => exact (hxw.trans hwt).trans htx1
    | 2, _ => exact htx1
  | .order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h =>
    have hij : i ≠ j := by
      simp only [ne_eq, Fin.mk.injEq] at h; omega
    have hne : (⟨i, by omega⟩ : Fin 3) ≠ ⟨j, by omega⟩ := by
      simp only [ne_eq, Fin.mk.injEq]; exact hij
    change ((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨i, by omega⟩ <
        (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨j, by omega⟩)
      ↔ qnf.1 (.order ⟨i, by omega⟩ ⟨j, by omega⟩ hne) = true
    have := henv (.order ⟨i, by omega⟩ ⟨j, by omega⟩ hne)
    simpa only [atom_eval] using this

/-- Zone-3 spec uniqueness (mirror of `kvE2_futCharZone4`): a witness's `zoneHolds` spec
    over `[w,x,t]` is forced by its actual order relations. -/
private theorem kvE2_futCharZone3' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v w x t : M.carrier) (zs3 : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs3 v)
    (p0 p1 p2 : Bool × Bool)
    (h0a : v < w ↔ p0.1 = true) (h0b : w < v ↔ p0.2 = true)
    (h1a : v < x ↔ p1.1 = true) (h1b : x < v ↔ p1.2 = true)
    (h2a : v < t ↔ p2.1 = true) (h2b : t < v ↔ p2.2 = true) :
    zs3 = Fin.cons p0 (Fin.cons p1 (fun _ => p2)) := by
  funext i
  match i with
  | ⟨0, _⟩ =>
    have hz0 := hz ⟨0, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz0.1.symm.trans h0a))
      (Bool.eq_iff_iff.mpr (hz0.2.symm.trans h0b))
  | ⟨1, _⟩ =>
    have hz1 := hz ⟨1, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz1.1.symm.trans h1a))
      (Bool.eq_iff_iff.mpr (hz1.2.symm.trans h1b))
  | ⟨2, _⟩ =>
    have hz2 := hz ⟨2, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz2.1.symm.trans h2a))
      (Bool.eq_iff_iff.mpr (hz2.2.symm.trans h2b))

/-- **Below-`t` zone classification**: an at-or-below-`t` witness's `[w,x,t]` zone spec is
    one of the six canonical constants. -/
private theorem kvE2_futBelowClass {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hvt : v ≤ t)
    (zs3 : ZoneSpec 3) (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs3 v) :
    zs3 = kvE2_sep_zPastX3 ∨ zs3 = kvE2_sep_zAtX3 ∨ zs3 = kvE2_sep_zXW3 ∨
      zs3 = kvE2_sep_zAtW3 ∨ zs3 = kvE2_sep_zWT3 ∨ zs3 = kvE2_sep_zAtT3 := by
  rcases lt_trichotomy v x with hx | hx | hx
  · exact Or.inl (kvE2_futCharZone3' M v w x t zs3 hz (true, false) (true, false) (true, false)
      (iff_of_true (hx.trans hxw) rfl) (iff_of_false (lt_asymm (hx.trans hxw)) Bool.false_ne_true)
      (iff_of_true hx rfl) (iff_of_false (lt_asymm hx) Bool.false_ne_true)
      (iff_of_true (hx.trans (hxw.trans hwt)) rfl)
      (iff_of_false (lt_asymm (hx.trans (hxw.trans hwt))) Bool.false_ne_true))
  · exact Or.inr (Or.inl (kvE2_futCharZone3' M v w x t zs3 hz (true, false) (false, false)
      (true, false)
      (iff_of_true (by rw [hx]; exact hxw) rfl)
      (iff_of_false (by rw [hx]; exact lt_asymm hxw) Bool.false_ne_true)
      (iff_of_false (by rw [hx]; exact lt_irrefl x) Bool.false_ne_true)
      (iff_of_false (by rw [hx]; exact lt_irrefl x) Bool.false_ne_true)
      (iff_of_true (by rw [hx]; exact hxw.trans hwt) rfl)
      (iff_of_false (by rw [hx]; exact lt_asymm (hxw.trans hwt)) Bool.false_ne_true)))
  · rcases lt_trichotomy v w with hw | hw | hw
    · exact Or.inr (Or.inr (Or.inl
        (kvE2_futCharZone3' M v w x t zs3 hz (true, false) (false, true) (true, false)
          (iff_of_true hw rfl) (iff_of_false (lt_asymm hw) Bool.false_ne_true)
          (iff_of_false (lt_asymm hx) Bool.false_ne_true) (iff_of_true hx rfl)
          (iff_of_true (hw.trans hwt) rfl)
          (iff_of_false (lt_asymm (hw.trans hwt)) Bool.false_ne_true))))
    · exact Or.inr (Or.inr (Or.inr (Or.inl
        (kvE2_futCharZone3' M v w x t zs3 hz (false, false) (false, true) (true, false)
          (iff_of_false (by rw [hw]; exact lt_irrefl w) Bool.false_ne_true)
          (iff_of_false (by rw [hw]; exact lt_irrefl w) Bool.false_ne_true)
          (iff_of_false (lt_asymm hx) Bool.false_ne_true) (iff_of_true hx rfl)
          (iff_of_true (by rw [hw]; exact hwt) rfl)
          (iff_of_false (by rw [hw]; exact lt_asymm hwt) Bool.false_ne_true)))))
    · rcases lt_trichotomy v t with ht | ht | ht
      · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl
          (kvE2_futCharZone3' M v w x t zs3 hz (false, true) (false, true) (true, false)
            (iff_of_false (lt_asymm hw) Bool.false_ne_true) (iff_of_true hw rfl)
            (iff_of_false (lt_asymm hx) Bool.false_ne_true) (iff_of_true hx rfl)
            (iff_of_true ht rfl) (iff_of_false (lt_asymm ht) Bool.false_ne_true))))))
      · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr
          (kvE2_futCharZone3' M v w x t zs3 hz (false, true) (false, true) (false, false)
            (iff_of_false (lt_asymm hw) Bool.false_ne_true) (iff_of_true hw rfl)
            (iff_of_false (lt_asymm hx) Bool.false_ne_true) (iff_of_true hx rfl)
            (iff_of_false (by rw [ht]; exact lt_irrefl t) Bool.false_ne_true)
            (iff_of_false (by rw [ht]; exact lt_irrefl t) Bool.false_ne_true))))))
      · exact absurd hvt (not_le.mpr ht)

/-- **Spike completeness** (Cor 5.4(2) exterior analog, ⇐ — the R2-obstructed direction),
    conditional on the gate-level pins actually available at the sole consumption site:

    * `henv` — the anchor base `[w,x,t]` is pinned to `qnf.1` (at SW:12788 from the endpoint
      1-type conjuncts + order bits; at the Phase-8 ⇐ site from realized qnf's atom layer);
    * `hbelow` — the at-or-below-`t` zone facts are pinned to qnf's positive layer via the
      model-independence bridge `kvE2_futAnyBit` (at the Phase-8 ⇐ site from
      `kvE2_futAnyBit_correct` applied to realized qnf; at SW:12788 derivable from
      `hexcl`/`hrealI`/`EpL`).

    Under these pins the specific one-sided clause EVADES the generic B.1 obstruction: from a
    realized positive-existence form (`¬` of the clause) we reconstruct a full exterior
    realizer, so absence of any exterior realizer forces the clause. This is the GO-conditional
    completeness of the plan's NO-GO protocol step 2 — the binding signature for Phases 3-6. -/
theorem kvE2_extNegFutSpike_complete {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) (χmid χfr : NormalForm sig 0 1)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hnorel : ∀ x1 : M.carrier, t < x1 →
      ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
          (kvE2_futSpikeSigma qnf χmid χfr)) :
    temporal_truth M atomMap t (kvE2_extNegFutSpike atomMap h_surj χmid χfr) := by
  intro hPos
  simp only [kvE2_futSpikePos] at hPos
  obtain ⟨s, hts, hAs, hguard1⟩ := hPos
  rw [formula_conjList_iff] at hAs
  have hchmid_s : temporal_truth M atomMap s (nf_depth0_char_formula atomMap h_surj χmid) :=
    hAs _ (by simp)
  have hinner : temporal_truth M atomMap s
      (Formula.untl (kvE2_futSpikeEnd atomMap h_surj χfr)
        (nf_depth0_char_formula atomMap h_surj χmid)) := hAs _ (by simp)
  obtain ⟨x1, hsx1, hend, hgap2⟩ := hinner
  simp only [kvE2_futSpikeEnd] at hend
  rw [formula_conjList_iff] at hend
  have hchfr : temporal_truth M atomMap x1 (nf_depth0_char_formula atomMap h_surj χfr) :=
    hend _ (by simp)
  have hnoF : temporal_truth M atomMap x1 (Formula.untl Formula.top Formula.top).neg :=
    hend _ (by simp)
  have htx1 : t < x1 := hts.trans hsx1
  have hx1fr : nf_eval_nf M 0 1 (fun _ => x1) χfr :=
    (nf_depth0_char_correct' M atomMap h_surj χfr x1).mp hchfr
  have hts0 : t < s := hts
  have hsx1' : s < x1 := hsx1
  -- gap (t, x1) is uniformly χmid
  have hgapmid : ∀ r : M.carrier, t < r → r < x1 → nf_eval_nf M 0 1 (fun _ => r) χmid := by
    intro r htr hrx1
    rcases lt_trichotomy r s with hrs | hrs | hrs
    · exact (nf_depth0_char_correct' M atomMap h_surj χmid r).mp (hguard1 r htr hrs)
    · exact hrs ▸ (nf_depth0_char_correct' M atomMap h_surj χmid s).mp hchmid_s
    · exact (nf_depth0_char_correct' M atomMap h_surj χmid r).mp (hgap2 r hrs hrx1)
  -- x1 is a maximum
  have hmax : ∀ s' : M.carrier, ¬ x1 < s' := fun s' hs' =>
    hnoF ⟨s', hs', id, fun r _ _ => id⟩
  -- x1 realizes the spike σ, contradicting hnorel
  apply hnorel x1 htx1
  refine (nf_eval_depth1_fold_iff M _ (kvE2_futSpikeSigma qnf χmid χfr)).mpr ⟨?_, ?_, ?_⟩
  · exact kvE2_futSpikeSigma_atom M qnf χmid χfr x1 w x t hxw hwt htx1 henv hx1fr
  · intro zs χ
    rw [kvE2_futSpikeSigma_bits]
    constructor
    · rintro ⟨v, hzv, hvχ⟩
      rcases lt_trichotomy v x1 with hlt | heq | hgt
      · rcases le_or_gt v t with hvt | htv
        · -- below t : reduce to the qnf-pinned zone fact
          have hz3 : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) (Fin.tail zs) v :=
            fun i => hzv i.succ
          have h0 := hzv 0
          have hzeq0 : zs 0 = (true, false) :=
            Prod.ext (h0.1.mp hlt) (by
              cases hb : (zs 0).2 with
              | false => rfl
              | true => exact absurd (h0.2.mpr hb) (lt_asymm hlt))
          have hcls := kvE2_futBelowClass M v w x t hxw hwt hvt (Fin.tail zs) hz3
          rw [← Fin.cons_self_tail zs, hzeq0]
          rcases hcls with h | h | h | h | h | h <;> rw [h] at hz3 ⊢ <;>
            exact (hbelow _ χ rfl).mp ⟨v, hz3, hvχ⟩
        · -- gap (t, x1) : profile forced to χmid
          have hzeq : zs = Fin.cons (true, false) kvE2_sep_zFutT3 :=
            kvE2_futCharZone4 M v x1 w x t zs hzv (true, false) (false, true) (false, true)
              (false, true)
              (iff_of_true hlt rfl) (iff_of_false (lt_asymm hlt) Bool.false_ne_true)
              (iff_of_false (lt_asymm (hwt.trans htv)) Bool.false_ne_true)
              (iff_of_true (hwt.trans htv) rfl)
              (iff_of_false (lt_asymm ((hxw.trans hwt).trans htv)) Bool.false_ne_true)
              (iff_of_true ((hxw.trans hwt).trans htv) rfl)
              (iff_of_false (lt_asymm htv) Bool.false_ne_true) (iff_of_true htv rfl)
          rw [hzeq]
          change decide (χ = χmid) = true
          exact decide_eq_true_eq.mpr (nf_profile_unique M v χ χmid hvχ (hgapmid v htv hlt))
      · -- v = x1 : fresh point, profile χfr
        have hzeq : zs = Fin.cons (false, false) kvE2_sep_zFutT3 :=
          kvE2_futCharZone4 M v x1 w x t zs hzv (false, false) (false, true) (false, true)
            (false, true)
            (iff_of_false (heq ▸ lt_irrefl x1) Bool.false_ne_true)
            (iff_of_false (heq ▸ lt_irrefl x1) Bool.false_ne_true)
            (iff_of_false (heq ▸ lt_asymm (hwt.trans htx1)) Bool.false_ne_true)
            (iff_of_true (heq ▸ hwt.trans htx1) rfl)
            (iff_of_false (heq ▸ lt_asymm ((hxw.trans hwt).trans htx1)) Bool.false_ne_true)
            (iff_of_true (heq ▸ (hxw.trans hwt).trans htx1) rfl)
            (iff_of_false (heq ▸ lt_asymm htx1) Bool.false_ne_true)
            (iff_of_true (heq ▸ htx1) rfl)
        rw [hzeq]
        change decide (χ = χfr) = true
        exact decide_eq_true_eq.mpr (nf_profile_unique M v χ χfr hvχ (heq ▸ hx1fr))
      · exact absurd hgt (hmax v)
    · intro hbitv
      by_cases hpast : zs = Fin.cons (true, false) kvE2_sep_zPastX3
      · subst hpast
        obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zPastX3 χ rfl).mpr hbitv
        exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
      by_cases hatx : zs = Fin.cons (true, false) kvE2_sep_zAtX3
      · subst hatx
        obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zAtX3 χ rfl).mpr hbitv
        exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
      by_cases hxw3 : zs = Fin.cons (true, false) kvE2_sep_zXW3
      · subst hxw3
        obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zXW3 χ rfl).mpr hbitv
        exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
      by_cases hatw : zs = Fin.cons (true, false) kvE2_sep_zAtW3
      · subst hatw
        obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zAtW3 χ rfl).mpr hbitv
        exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
      by_cases hwt3 : zs = Fin.cons (true, false) kvE2_sep_zWT3
      · subst hwt3
        obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zWT3 χ rfl).mpr hbitv
        exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
      by_cases hatt : zs = Fin.cons (true, false) kvE2_sep_zAtT3
      · subst hatt
        obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zAtT3 χ rfl).mpr hbitv
        exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
      by_cases hgap : zs = Fin.cons (true, false) kvE2_sep_zFutT3
      · subst hgap
        have hχmid : χ = χmid := of_decide_eq_true hbitv
        subst hχmid
        exact ⟨s, kvE2_futZone4_of_above M s x1 w x t hxw hwt hts0 (true, false)
            (iff_of_true hsx1' rfl) (iff_of_false (lt_asymm hsx1') Bool.false_ne_true),
          (nf_depth0_char_correct' M atomMap h_surj χ s).mp hchmid_s⟩
      by_cases hself : zs = Fin.cons (false, false) kvE2_sep_zFutT3
      · subst hself
        have hχfr : χ = χfr := of_decide_eq_true hbitv
        subst hχfr
        exact ⟨x1, kvE2_futZone4_of_above M x1 x1 w x t hxw hwt htx1 (false, false)
            (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
            (iff_of_false (lt_irrefl x1) Bool.false_ne_true), hx1fr⟩
      · exfalso
        rw [kvE2_futSpikeZoneBit, if_neg hpast, if_neg hatx, if_neg hxw3, if_neg hatw,
          if_neg hwt3, if_neg hatt, if_neg hgap, if_neg hself] at hbitv
        exact Bool.false_ne_true hbitv
  · intro τ hτ
    change (decide (nf0_dropFresh τ = show NormalForm sig 0 4 from
        (kvE2_futSpikeSigma qnf χmid χfr).1) &&
      kvE2_futSpikeZoneBit qnf χmid χfr (nf0_zoneSpec τ) (nf0_projFresh τ)) = false
    have hτ' : nf0_dropFresh τ ≠ show NormalForm sig 0 4 from
        (kvE2_futSpikeSigma qnf χmid χfr).1 := hτ
    rw [decide_eq_false hτ', Bool.false_and]

/-! ## Phase 3: The future-side clause FAMILY

Generalization of the spike to the full finite alphabet, in the Phase-2 BINDING
signature (H6): for EVERY `σ : NormalForm sig 1 4`,

  `kvE2_extNegFut atomMap h_surj σ = (kvE2_futPos atomMap h_surj σ).neg`

where `kvE2_futPos` is the `Until`-navigated positive local-existence form (Cor 5.4
O_n / Lemma 5.3 F-chain device, Lemma 7.10 TL-expressibility): a disjunction over the
PERMUTATIONS of σ's gap-profile list of `D`-guarded `Until` chains, each terminating
in the endpoint description (fresh profile + exact ray content). The whole construction
is gated on the syntactic order-admissibility Bool `kvE2_futAdmissible` (zone marking,
off-fiber bits, order-impossible zone bits, self-zone bit pattern) — for inadmissible σ
the positive form is `⊥`, so the clause is trivially true; a realizer FORCES
admissibility (`kvE2_futRealizer_admissible`), so soundness is unconditional.

`kvE2_extNegFut_sound` holds under the order bits `(hxw, hwt)` ONLY — the `hexclExt`
binder inventory, no semantic hypothesis on `M`, and (strictly stronger than the plan
statement) no `zFutT3`-marking hypothesis: a σ realized at exterior `t < x1` is FORCED
to be `zFutT3`-marked (`kvE2_exterior_zone_determination_fut`, Phase 1).

The clause takes NO `qnf` parameter (matching the spike clause, which was qnf-free):
qnf enters only through Phase 4's pins (`henv`, `hbelow`) plus the syntactic below-bit
comparison of `σ.2` against `kvE2_futAnyBit qnf` — recorded Phase-4 obligations.
`HasAttainedINF` is NOT needed: all chains are finite (length = |gap profile list|)
and ray emptiness is the `S_ray = ∅` instance of the exact-ray-content form. -/

/-- `ZoneSpec 4` is a finite type (file-local mirror of the pi-instance through the
    `ZoneSpec` def, as for the `DecidableEq` bridge above). -/
private instance : Fintype (ZoneSpec 4) :=
  inferInstanceAs (Fintype (Fin 4 → Bool × Bool))

/-! ### σ's exterior-zone channels -/

/-- Gap-zone bit of σ: does σ prescribe a point of profile `χ` in `(t, x1)`? -/
noncomputable def kvE2_futGapBit {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool :=
  σ.2 (nf0_assemble (Fin.cons (true, false) kvE2_sep_zFutT3) χ σ.1)

/-- Ray-zone bit of σ: does σ prescribe a point of profile `χ` in `(x1, ∞)`? -/
noncomputable def kvE2_futRayBit {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool :=
  σ.2 (nf0_assemble (Fin.cons (false, true) kvE2_sep_zFutT3) χ σ.1)

/-- Self-zone bit of σ: does σ prescribe profile `χ` at the fresh point `x1` itself? -/
noncomputable def kvE2_futSelfBit {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool :=
  σ.2 (nf0_assemble (Fin.cons (false, false) kvE2_sep_zFutT3) χ σ.1)

/-- The (nodup) list of gap profiles σ prescribes for `(t, x1)`. -/
noncomputable def kvE2_futGapList {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : List (NormalForm sig 0 1) :=
  Finset.univ.toList.filter (kvE2_futGapBit σ)

/-- The (nodup) list of ray profiles σ prescribes for `(x1, ∞)`. -/
noncomputable def kvE2_futRayList {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : List (NormalForm sig 0 1) :=
  Finset.univ.toList.filter (kvE2_futRayBit σ)

/-- The nine zone-4 specs an actual point can carry relative to `[x1, w, x, t]` with
    `x < w < t < x1`: the six at-or-below-`t` couplings, the gap, the self point, and
    the ray. Everything else is order-impossible. -/
def kvE2_futPossibleZones : List (ZoneSpec 4) :=
  [Fin.cons (true, false) kvE2_sep_zPastX3,
   Fin.cons (true, false) kvE2_sep_zAtX3,
   Fin.cons (true, false) kvE2_sep_zXW3,
   Fin.cons (true, false) kvE2_sep_zAtW3,
   Fin.cons (true, false) kvE2_sep_zWT3,
   Fin.cons (true, false) kvE2_sep_zAtT3,
   Fin.cons (true, false) kvE2_sep_zFutT3,
   Fin.cons (false, false) kvE2_sep_zFutT3,
   Fin.cons (false, true) kvE2_sep_zFutT3]

/-! #### Membership certificates for `kvE2_futPossibleZones`

`simp`/`decide`/`rcases` cannot be used to traverse `kvE2_futPossibleZones` directly. Its
entries are `Fin.cons p zs3` with `zs3 : ZoneSpec 3`, and `Fin.cons`'s implicit motive is
solved as `fun _ => Bool × Bool`, so the tail's *expected* type is `Fin 3 → Bool × Bool`
while the *actual* type is the (semireducible) `ZoneSpec 3`. Since Lean 4.31 definitional
equality strictly respects transparency levels, the list literal is therefore not
type-correct at `implicit` transparency and `simp` refuses to rewrite inside it
("the target expression is not type-correct under the `implicit` transparency level").

`exact`/`apply` still check at `default` transparency, where `ZoneSpec 3` unfolds and the
term is perfectly well-typed. The four lemmas below package every membership fact this file
needs in that style, so no tactic ever has to look inside the literal. -/

/-- Any of the six at-or-below-`t` couplings, headed by `(true, false)`, is a possible zone. -/
private theorem kvE2_futPossibleZones_mem_below (zs3 : ZoneSpec 3)
    (h : zs3 = kvE2_sep_zPastX3 ∨ zs3 = kvE2_sep_zAtX3 ∨ zs3 = kvE2_sep_zXW3 ∨
      zs3 = kvE2_sep_zAtW3 ∨ zs3 = kvE2_sep_zWT3 ∨ zs3 = kvE2_sep_zAtT3) :
    Fin.cons (true, false) zs3 ∈ kvE2_futPossibleZones := by
  rcases h with rfl | rfl | rfl | rfl | rfl | rfl
  · exact List.Mem.head _
  · exact List.Mem.tail _ (List.Mem.head _)
  · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))
  · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))
  · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))))
  · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _
      (List.Mem.tail _ (List.Mem.head _)))))

/-- The gap zone `(t, x1)` is a possible zone (entry 7). -/
private theorem kvE2_futPossibleZones_mem_gap :
    Fin.cons (true, false) kvE2_sep_zFutT3 ∈ kvE2_futPossibleZones :=
  List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _
    (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))))))

/-- The self zone `x1` itself is a possible zone (entry 8). -/
private theorem kvE2_futPossibleZones_mem_self :
    Fin.cons (false, false) kvE2_sep_zFutT3 ∈ kvE2_futPossibleZones :=
  List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _
    (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))))))

/-- The ray zone `(x1, ∞)` is a possible zone (entry 9). -/
private theorem kvE2_futPossibleZones_mem_ray :
    Fin.cons (false, true) kvE2_sep_zFutT3 ∈ kvE2_futPossibleZones :=
  List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _
    (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))))))))

/-- Elimination form: membership in `kvE2_futPossibleZones` is the nine-way disjunction.
    Built from `List.mem_cons`/`List.mem_singleton` applied as *terms*, which elaborate at
    `default` transparency — `simp only [kvE2_futPossibleZones, List.mem_cons]` does not
    work here, for the reason given above. -/
private theorem kvE2_futPossibleZones_cases {zs : ZoneSpec 4}
    (h : zs ∈ kvE2_futPossibleZones) :
    zs = Fin.cons (true, false) kvE2_sep_zPastX3 ∨
      zs = Fin.cons (true, false) kvE2_sep_zAtX3 ∨
      zs = Fin.cons (true, false) kvE2_sep_zXW3 ∨
      zs = Fin.cons (true, false) kvE2_sep_zAtW3 ∨
      zs = Fin.cons (true, false) kvE2_sep_zWT3 ∨
      zs = Fin.cons (true, false) kvE2_sep_zAtT3 ∨
      zs = Fin.cons (true, false) kvE2_sep_zFutT3 ∨
      zs = Fin.cons (false, false) kvE2_sep_zFutT3 ∨
      zs = Fin.cons (false, true) kvE2_sep_zFutT3 := by
  rcases List.mem_cons.mp h with h | h
  · exact Or.inl h
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inl h)
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inl h))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inl h)))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h))))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h)))))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h))))))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h)))))))
  exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr
    (List.mem_singleton.mp h))))))))

/-- **Zone-4 classification at exterior `x1`**: any point's `zoneHolds` spec over
    `[x1, w, x, t]` (with `x < w < t < x1`) is one of the nine possible zones. -/
theorem kvE2_futZoneClass {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v) :
    zs ∈ kvE2_futPossibleZones := by
  rcases le_or_gt v t with hvt | htv
  · -- at-or-below t: head coupling (true, false), tail one of the six below constants
    have hz3 : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) (Fin.tail zs) v :=
      fun i => hz i.succ
    have h0 := hz ⟨0, by omega⟩
    have hlt : v < x1 := hvt.trans_lt htx1
    have hzeq0 : zs 0 = (true, false) :=
      Prod.ext (h0.1.mp hlt) (by
        cases hb : (zs 0).2 with
        | false => rfl
        | true => exact absurd (h0.2.mpr hb) (lt_asymm hlt))
    have hcls := kvE2_futBelowClass M v w x t hxw hwt hvt (Fin.tail zs) hz3
    rw [← Fin.cons_self_tail zs, hzeq0]
    exact kvE2_futPossibleZones_mem_below (Fin.tail zs) hcls
  · -- above t: the three (t, ∞)-side zones by trichotomy against x1
    rcases lt_trichotomy v x1 with hvx1 | hvx1 | hvx1
    · have hzeq := kvE2_futCharZone4 M v x1 w x t zs hz
        (true, false) (false, true) (false, true) (false, true)
        (iff_of_true hvx1 rfl) (iff_of_false (lt_asymm hvx1) Bool.false_ne_true)
        (iff_of_false (lt_asymm (hwt.trans htv)) Bool.false_ne_true)
        (iff_of_true (hwt.trans htv) rfl)
        (iff_of_false (lt_asymm ((hxw.trans hwt).trans htv)) Bool.false_ne_true)
        (iff_of_true ((hxw.trans hwt).trans htv) rfl)
        (iff_of_false (lt_asymm htv) Bool.false_ne_true) (iff_of_true htv rfl)
      rw [hzeq]
      exact kvE2_futPossibleZones_mem_gap
    · have hzeq := kvE2_futCharZone4 M v x1 w x t zs hz
        (false, false) (false, true) (false, true) (false, true)
        (iff_of_false (hvx1 ▸ lt_irrefl v) Bool.false_ne_true)
        (iff_of_false (hvx1 ▸ lt_irrefl v) Bool.false_ne_true)
        (iff_of_false (lt_asymm (hwt.trans htv)) Bool.false_ne_true)
        (iff_of_true (hwt.trans htv) rfl)
        (iff_of_false (lt_asymm ((hxw.trans hwt).trans htv)) Bool.false_ne_true)
        (iff_of_true ((hxw.trans hwt).trans htv) rfl)
        (iff_of_false (lt_asymm htv) Bool.false_ne_true) (iff_of_true htv rfl)
      rw [hzeq]
      exact kvE2_futPossibleZones_mem_self
    · have hzeq := kvE2_futCharZone4 M v x1 w x t zs hz
        (false, true) (false, true) (false, true) (false, true)
        (iff_of_false (lt_asymm hvx1) Bool.false_ne_true) (iff_of_true hvx1 rfl)
        (iff_of_false (lt_asymm (hwt.trans htv)) Bool.false_ne_true)
        (iff_of_true (hwt.trans htv) rfl)
        (iff_of_false (lt_asymm ((hxw.trans hwt).trans htv)) Bool.false_ne_true)
        (iff_of_true ((hxw.trans hwt).trans htv) rfl)
        (iff_of_false (lt_asymm htv) Bool.false_ne_true) (iff_of_true htv rfl)
      rw [hzeq]
      exact kvE2_futPossibleZones_mem_ray

/-! ### Syntactic order-admissibility -/

/-- **Order-admissibility of σ** (syntactic, model-independent): the conjunction of the
    conditions a realizer at exterior `x1` FORCES on σ —

    1. `zFutT3` zone marking of the base layer;
    2. off-fiber quant bits false;
    3. quant bits false on every order-impossible zone-4 spec;
    4. self-zone bits carve out exactly the fresh profile `nf0_projFresh σ.1`.

    For inadmissible σ the positive form below is `⊥` (clause trivially true), which is
    sound because such σ has NO exterior realizer (`kvE2_futRealizer_admissible`); for
    Phase 4, truth of the positive form conversely certifies admissibility for free. -/
noncomputable def kvE2_futAdmissible {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : Bool :=
  decide (nf0_zoneSpec σ.1 = kvE2_sep_zFutT3) &&
  ((Finset.univ.toList (α := NormalForm sig 0 5)).all fun τ =>
    decide (nf0_dropFresh τ = show NormalForm sig 0 4 from σ.1) || !(σ.2 τ)) &&
  ((Finset.univ.toList (α := ZoneSpec 4)).all fun zs =>
    (kvE2_futPossibleZones.any fun z => decide (zs = z)) ||
    ((Finset.univ.toList (α := NormalForm sig 0 1)).all fun χ =>
      !(σ.2 (nf0_assemble zs χ σ.1)))) &&
  ((Finset.univ.toList (α := NormalForm sig 0 1)).all fun χ =>
    decide (kvE2_futSelfBit σ χ = decide (χ = nf0_projFresh σ.1)))

/-- A realizer's fresh point carries σ's fresh profile (atom-layer read). -/
theorem kvE2_futFreshProfile {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier)
    (hatomσ : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σ.1 a = true) :
    nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1) := by
  rw [nf_eval_profile_iff]
  intro p
  have := hatomσ (.pred p 0)
  simpa only [atom_eval, Fin.cons_zero, nf0_projFresh] using this

/-- **A realizer forces admissibility**: if some exterior `x1 > t` realizes σ over
    `[x1, w, x, t]` (with `x < w < t`), then σ is order-admissible. Uses only the
    order bits — no semantic hypothesis on `M`. -/
theorem kvE2_futRealizer_admissible {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (hnf : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    kvE2_futAdmissible σ = true := by
  obtain ⟨hatomσ, hquantσ, hoff⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  have hx1fr := kvE2_futFreshProfile M σ x1 w x t hatomσ
  rw [kvE2_futAdmissible]
  simp only [Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- zone marking (Phase-1 zone determination)
    exact decide_eq_true
      (kvE2_exterior_zone_determination_fut M x1 w x t σ hxw hwt htx1 hnf)
  · -- off-fiber bits false
    rw [List.all_eq_true]
    intro τ _
    by_cases hτ : nf0_dropFresh τ = show NormalForm sig 0 4 from σ.1
    · rw [decide_eq_true hτ, Bool.true_or]
    · rw [hoff τ hτ, Bool.not_false, Bool.or_true]
  · -- order-impossible zone bits false
    rw [List.all_eq_true]
    intro zs _
    by_cases hzp : ∃ z ∈ kvE2_futPossibleZones, zs = z
    · obtain ⟨z, hzmem, hzeq⟩ := hzp
      rw [Bool.or_eq_true]
      exact Or.inl (List.any_eq_true.mpr ⟨z, hzmem, decide_eq_true hzeq⟩)
    · rw [Bool.or_eq_true]
      refine Or.inr ?_
      rw [List.all_eq_true]
      intro χ _
      cases hb : σ.2 (nf0_assemble zs χ σ.1) with
      | false => rfl
      | true =>
        obtain ⟨v, hzv, -⟩ := (hquantσ zs χ).mpr hb
        exact absurd ⟨zs, kvE2_futZoneClass M v x1 w x t hxw hwt htx1 zs hzv, rfl⟩ hzp
  · -- self-zone bit pattern
    rw [List.all_eq_true]
    intro χ _
    refine decide_eq_true ?_
    rw [Bool.eq_iff_iff]
    constructor
    · intro hb
      obtain ⟨v, hzv, hvχ⟩ := (hquantσ (Fin.cons (false, false) kvE2_sep_zFutT3) χ).mpr hb
      have h0 := hzv ⟨0, by omega⟩
      have hvx1 : v = x1 := by
        have hn1 : ¬ v < x1 := fun hltv => absurd (h0.1.mp hltv) Bool.false_ne_true
        have hn2 : ¬ x1 < v := fun hltv => absurd (h0.2.mp hltv) Bool.false_ne_true
        exact le_antisymm (not_lt.mp hn2) (not_lt.mp hn1)
      subst hvx1
      exact decide_eq_true (nf_profile_unique M v χ (nf0_projFresh σ.1) hvχ hx1fr)
    · intro hd
      have hχ : χ = nf0_projFresh σ.1 := of_decide_eq_true hd
      subst hχ
      exact (hquantσ (Fin.cons (false, false) kvE2_sep_zFutT3) _).mp
        ⟨x1, kvE2_futZone4_of_above M x1 x1 w x t hxw hwt htx1 (false, false)
          (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
          (iff_of_false (lt_irrefl x1) Bool.false_ne_true), hx1fr⟩

/-! ### The clause family -/

/-- Gap guard `D`: the disjunction of the characteristic formulas of σ's gap profiles
    (empty gap list gives `⊥` — the "no gap points" guard). -/
noncomputable def kvE2_futGapD {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  formula_disjList ((kvE2_futGapList σ).map (nf_depth0_char_formula atomMap h_surj))

/-- Ray disjunction: the characteristic disjunction of σ's ray profiles. -/
noncomputable def kvE2_futRayD {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  formula_disjList ((kvE2_futRayList σ).map (nf_depth0_char_formula atomMap h_surj))

/-- Exact-ray-content form at the endpoint: every future point carries a ray profile
    (`¬F(¬D_ray)` — for `S_ray = ∅` this is the spike's ray emptiness `¬F⊤` semantics),
    and each ray profile occurs (`F(char χ)` for each `χ ∈ S_ray`). -/
noncomputable def kvE2_futRayForm {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  formula_conjList
    ((Formula.untl (kvE2_futRayD atomMap h_surj σ).neg Formula.top).neg ::
      (kvE2_futRayList σ).map fun χ =>
        Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top)

/-- Endpoint description: fresh profile + exact ray content. -/
noncomputable def kvE2_futEnd {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  formula_conjList
    [nf_depth0_char_formula atomMap h_surj (nf0_projFresh σ.1),
     kvE2_futRayForm atomMap h_surj σ]

/-- `D`-guarded `Until` chain visiting the listed profiles in order and terminating in
    `endF` — the Lemma 5.3 / Cor 5.4 O_n device at chain length `|l|`. -/
noncomputable def kvE2_futChain {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (endF D : Formula) : List (NormalForm sig 0 1) → Formula
  | [] => Formula.untl endF D
  | χ :: rest =>
      Formula.untl
        (formula_conjList
          [nf_depth0_char_formula atomMap h_surj χ,
           kvE2_futChain atomMap h_surj endF D rest])
        D

/-- **Positive local-existence form** for σ (Cor 5.4(2) exterior analog, general form):
    admissibility-gated disjunction over the permutations of σ's gap-profile list of
    `D`-guarded chains ending in the endpoint description. The spike's
    `U(χmid ∧ U(end, χmid), χmid)` is the `S_gap = {χmid}`, `S_ray = ∅` instance. -/
noncomputable def kvE2_futPos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  if kvE2_futAdmissible σ = true then
    formula_disjList ((kvE2_futGapList σ).permutations.map
      (kvE2_futChain atomMap h_surj (kvE2_futEnd atomMap h_surj σ)
        (kvE2_futGapD atomMap h_surj σ)))
  else Formula.bot

/-- **The future-side complement clause family** (Phase-2 BINDING signature): the
    negation of the positive local-existence form, anchored at `t`. -/
noncomputable def kvE2_extNegFut {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  (kvE2_futPos atomMap h_surj σ).neg

/-! ### Soundness of the clause family -/

/-- Minimal-witness selection: from per-element witnesses over a nonempty list, pick an
    element whose witness is ≤ every element's (some) witness. -/
private theorem kvE2_futMinPick {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {α : Type}
    (M : OrderedMonadicStructure sig) (P : α → M.carrier → Prop) :
    ∀ l : List α, l ≠ [] → (∀ a ∈ l, ∃ r, P a r) →
      ∃ a₀, a₀ ∈ l ∧ ∃ r₀, P a₀ r₀ ∧ ∀ a ∈ l, ∃ r, P a r ∧ r₀ ≤ r := by
  intro l
  induction l with
  | nil => intro h; exact absurd rfl h
  | cons a l ih =>
    intro _ hocc
    obtain ⟨r, hr⟩ := hocc a (by simp)
    by_cases hl : l = []
    · subst hl
      refine ⟨a, by simp, r, hr, fun b hb => ?_⟩
      rw [List.mem_singleton] at hb
      subst hb
      exact ⟨r, hr, le_refl r⟩
    · obtain ⟨a', ha'mem, r', hr', hmin⟩ :=
        ih hl (fun c hc => hocc c (List.mem_cons_of_mem a hc))
      rcases le_or_gt r r' with hle | hlt
      · refine ⟨a, by simp, r, hr, fun c hc => ?_⟩
        rcases List.mem_cons.mp hc with rfl | hc'
        · exact ⟨r, hr, le_refl r⟩
        · obtain ⟨r'', hr'', hge⟩ := hmin c hc'
          exact ⟨r'', hr'', hle.trans hge⟩
      · refine ⟨a', List.mem_cons_of_mem a ha'mem, r', hr', fun c hc => ?_⟩
        rcases List.mem_cons.mp hc with rfl | hc'
        · exact ⟨r, hr, hlt.le⟩
        · exact hmin c hc'

/-- **Chain construction**: from a `D`-uniform gap below `x1`, an endpoint description
    at `x1`, and one occurrence in `(s, x1)` for each profile in a nodup list `L`,
    SOME permutation of `L` carries a true `D`-guarded chain at `s` (sort the chosen
    occurrences by minimal-witness extraction; distinct profiles occupy distinct
    points, so the strict order propagates through the recursion). -/
private theorem kvE2_futChainBuild {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (endF D : Formula) (t x1 : M.carrier)
    (hD : ∀ r : M.carrier, t < r → r < x1 → temporal_truth M atomMap r D)
    (hend : temporal_truth M atomMap x1 endF) :
    ∀ (n : Nat) (L : List (NormalForm sig 0 1)), L.length ≤ n → L.Nodup →
      ∀ s : M.carrier, s < x1 → (∀ r : M.carrier, s < r → t < r) →
      (∀ χ ∈ L, ∃ r : M.carrier, s < r ∧ r < x1 ∧ nf_eval_nf M 0 1 (fun _ => r) χ) →
      ∃ l : List (NormalForm sig 0 1), l.Perm L ∧
        temporal_truth M atomMap s (kvE2_futChain atomMap h_surj endF D l) := by
  intro n
  induction n with
  | zero =>
    intro L hlen _ s hsx1 hbound _
    have hL : L = [] := by
      cases L with
      | nil => rfl
      | cons a l => simp at hlen
    subst hL
    refine ⟨[], List.Perm.refl [], ?_⟩
    simp only [kvE2_futChain]
    exact ⟨x1, hsx1, hend, fun r hsr hrx1 => hD r (hbound r hsr) hrx1⟩
  | succ n ih =>
    intro L hlen hnd s hsx1 hbound hocc
    by_cases hL : L = []
    · subst hL
      refine ⟨[], List.Perm.refl [], ?_⟩
      simp only [kvE2_futChain]
      exact ⟨x1, hsx1, hend, fun r hsr hrx1 => hD r (hbound r hsr) hrx1⟩
    · obtain ⟨χ₀, hχ₀mem, r₀, ⟨hsr₀, hr₀x1, hprof₀⟩, hmin⟩ :=
        kvE2_futMinPick M
          (fun χ r => s < r ∧ r < x1 ∧ nf_eval_nf M 0 1 (fun _ => r) χ) L hL hocc
      have htr₀ : t < r₀ := hbound r₀ hsr₀
      have hlen' : (L.erase χ₀).length ≤ n := by
        have h1 := List.length_erase_of_mem hχ₀mem
        have h2 : 0 < L.length := List.length_pos_of_mem hχ₀mem
        omega
      obtain ⟨l', hl'perm, hl'truth⟩ := ih (L.erase χ₀) hlen' (hnd.erase χ₀) r₀ hr₀x1
        (fun r hr => htr₀.trans hr)
        (fun χ hχ => by
          obtain ⟨hne, hχL⟩ := (List.Nodup.mem_erase_iff hnd).mp hχ
          obtain ⟨r, ⟨_, hrx1, hprofr⟩, hger⟩ := hmin χ hχL
          refine ⟨r, lt_of_le_of_ne hger ?_, hrx1, hprofr⟩
          intro he
          exact hne (nf_profile_unique M r χ χ₀ hprofr (he ▸ hprof₀)))
      refine ⟨χ₀ :: l', (hl'perm.cons χ₀).trans (List.perm_cons_erase hχ₀mem).symm, ?_⟩
      simp only [kvE2_futChain]
      refine ⟨r₀, hsr₀, ?_,
        fun r hsr hrr₀ => hD r (hbound r hsr) (hrr₀.trans hr₀x1)⟩
      rw [formula_conjList_iff]
      intro f hf
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl
      · exact (nf_depth0_char_correct' M atomMap h_surj χ₀ r₀).mpr hprof₀
      · exact hl'truth

/-- **Family soundness** (Cor 5.4(2) exterior analog, ⇒ — the Phase-2 BINDING
    signature, side Fut): if the complement clause of σ holds at the right anchor `t`,
    then no exterior point `x1 > t` realizes σ. Uses only the order bits `hxw`/`hwt`
    (the `hexclExt` binder inventory) — no semantic hypothesis on `M`, and no
    zone-marking hypothesis on σ (a realized exterior σ is forced `zFutT3`-marked).
    This direction discharges `hexclExt` for the whole future-side alphabet. -/
theorem kvE2_extNegFut_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap t (kvE2_extNegFut atomMap h_surj σ)) :
    ∀ x1 : M.carrier, t < x1 →
      ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro x1 htx1 hnf
  obtain ⟨hatomσ, hquantσ, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  have hadm : kvE2_futAdmissible σ = true :=
    kvE2_futRealizer_admissible M σ x1 w x t hxw hwt htx1 hnf
  have hx1fr := kvE2_futFreshProfile M σ x1 w x t hatomσ
  -- the gap (t, x1) is uniformly D
  have hD : ∀ r : M.carrier, t < r → r < x1 →
      temporal_truth M atomMap r (kvE2_futGapD atomMap h_surj σ) := by
    intro r htr hrx1
    obtain ⟨χr, hχr⟩ := nf_profile_exists M r
    have hzr := kvE2_futZone4_of_above M r x1 w x t hxw hwt htr (true, false)
      (iff_of_true hrx1 rfl) (iff_of_false (lt_asymm hrx1) Bool.false_ne_true)
    have hb : kvE2_futGapBit σ χr = true :=
      (hquantσ (Fin.cons (true, false) kvE2_sep_zFutT3) χr).mp ⟨r, hzr, hχr⟩
    rw [kvE2_futGapD, formula_disjList_iff]
    exact ⟨_, List.mem_map.mpr
      ⟨χr, List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ χr), hb⟩, rfl⟩,
      (nf_depth0_char_correct' M atomMap h_surj χr r).mpr hχr⟩
  -- endpoint description at x1
  have hend : temporal_truth M atomMap x1 (kvE2_futEnd atomMap h_surj σ) := by
    rw [kvE2_futEnd, formula_conjList_iff]
    intro f hf
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
    rcases hf with rfl | rfl
    · exact (nf_depth0_char_correct' M atomMap h_surj _ x1).mpr hx1fr
    · rw [kvE2_futRayForm, formula_conjList_iff]
      intro g hg
      rcases List.mem_cons.mp hg with rfl | hg'
      · -- every future point carries a ray profile
        intro hF
        obtain ⟨u, hx1u, hnotD, -⟩ := hF
        apply hnotD
        obtain ⟨χu, hχu⟩ := nf_profile_exists M u
        have hzu := kvE2_futZone4_of_above M u x1 w x t hxw hwt (htx1.trans hx1u)
          (false, true)
          (iff_of_false (lt_asymm hx1u) Bool.false_ne_true) (iff_of_true hx1u rfl)
        have hb : kvE2_futRayBit σ χu = true :=
          (hquantσ (Fin.cons (false, true) kvE2_sep_zFutT3) χu).mp ⟨u, hzu, hχu⟩
        rw [kvE2_futRayD, formula_disjList_iff]
        exact ⟨_, List.mem_map.mpr
          ⟨χu, List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ χu), hb⟩, rfl⟩,
          (nf_depth0_char_correct' M atomMap h_surj χu u).mpr hχu⟩
      · -- each ray profile occurs
        obtain ⟨χ, hχmem, rfl⟩ := List.mem_map.mp hg'
        have hb : kvE2_futRayBit σ χ = true := (List.mem_filter.mp hχmem).2
        obtain ⟨v, hzv, hvχ⟩ :=
          (hquantσ (Fin.cons (false, true) kvE2_sep_zFutT3) χ).mpr hb
        have h0 := hzv ⟨0, by omega⟩
        exact ⟨v, h0.2.mpr rfl,
          (nf_depth0_char_correct' M atomMap h_surj χ v).mpr hvχ, fun r _ _ => id⟩
  -- each gap profile occurs in (t, x1)
  have hocc : ∀ χ ∈ kvE2_futGapList σ, ∃ r : M.carrier,
      t < r ∧ r < x1 ∧ nf_eval_nf M 0 1 (fun _ => r) χ := by
    intro χ hχ
    have hb : kvE2_futGapBit σ χ = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hzv, hvχ⟩ :=
      (hquantσ (Fin.cons (true, false) kvE2_sep_zFutT3) χ).mpr hb
    have h0 := hzv ⟨0, by omega⟩
    have h3 := hzv ⟨3, by omega⟩
    exact ⟨v, h3.2.mpr rfl, h0.1.mpr rfl, hvχ⟩
  have hnd : (kvE2_futGapList σ).Nodup :=
    List.Nodup.filter _ (Finset.nodup_toList _)
  obtain ⟨l, hlperm, hltruth⟩ :=
    kvE2_futChainBuild M atomMap h_surj (kvE2_futEnd atomMap h_surj σ)
      (kvE2_futGapD atomMap h_surj σ) t x1 hD hend
      (kvE2_futGapList σ).length (kvE2_futGapList σ) le_rfl hnd t htx1
      (fun r hr => hr) hocc
  refine hcl ?_
  rw [kvE2_futPos, if_pos hadm, formula_disjList_iff]
  exact ⟨_, List.mem_map.mpr ⟨l, List.mem_permutations.mpr hlperm, rfl⟩, hltruth⟩

/-! ## Phase 4: Completeness of the clause family

The ⇐ half at family generality: if NO exterior `x1 > t` realizes σ, the complement
clause holds at `t`. Contrapositive: a true positive form at `t` reconstructs a full
exterior realizer — the spike's 9-zone reconstruction (`kvE2_extNegFutSpike_complete`)
generalized over the finite alphabet via the Phase-3 support kit.

Hypotheses are EXACTLY the recorded Phase-4 obligations (progress/phase3): the Phase-2
gate-level pins `(hxw, hwt, henv, hbelow)` PLUS the two syntactic σ-side hypotheses

* `hbase : nf0_dropFresh σ.1 = qnf.1` (base-restriction match — the spike had this by
  construction, `kvE2_futSpikeBase` + round-trip 3);
* `hbits` : σ's six at-or-below-`t` bits agree with `kvE2_futAnyBit qnf` (the below-bit
  comparison; mismatched bit-false σ are handled at the consumption site by
  fact-pinning — Phase 7/8 restricts the gate conjunction to matched σ).

No `zFutT3`-marking hypothesis is needed: Phase 3's if-gate hands admissibility for
free (a true positive form certifies `kvE2_futAdmissible σ`, since the else-branch is
`⊥`), and admissibility CONTAINS the zone marking. Statement shape confirmed against
the Phase-8 ⇐ consumption site (OuterGate.lean:147 `bracketEndChar_kvE2_complete_two_prior`):
there `henv`/`hbelow` derive from realized qnf's atom layer and `kvE2_futAnyBit_correct`,
`(hxw, hwt)` from qnf's order bits, and `hbase`/`hbits` are decidable σ-side facts. -/

/-- **σ's atom layer holds at a reconstructed endpoint** (generalization of
    `kvE2_futSpikeSigma_atom` to arbitrary σ): under the zone marking
    `nf0_zoneSpec σ.1 = kvE2_sep_zFutT3` (from admissibility), the base-restriction
    match `nf0_dropFresh σ.1 = qnf.1`, the anchor-base pin `henv`, and σ's fresh
    profile at `x1`, every `AtomKind sig 4` atom of `σ.1` is honest over
    `[x1, w, x, t]`. -/
private theorem kvE2_futSigma_atom {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hzs : nf0_zoneSpec σ.1 = kvE2_sep_zFutT3)
    (hbase : nf0_dropFresh σ.1 = qnf.1)
    (hx1fr : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1)) :
    ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔
        σ.1 a = true := by
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    change M.interp p x1 ↔ σ.1 (.pred p 0) = true
    have h := hx1fr (.pred p 0)
    simpa only [atom_eval, nf0_projFresh] using h
  | .pred p ⟨i + 1, hi⟩ =>
    have hb : σ.1 (.pred p ⟨i + 1, hi⟩) = qnf.1 (.pred p ⟨i, by omega⟩) := by
      rw [← hbase]
      simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
      rfl
    change M.interp p ((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨i, by omega⟩)
      ↔ σ.1 (.pred p ⟨i + 1, hi⟩) = true
    rw [hb]
    have h := henv (.pred p ⟨i, by omega⟩)
    simpa only [atom_eval] using h
  | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
  | .order ⟨0, _⟩ ⟨j + 1, hj⟩ h =>
    have e1 : σ.1 (.order ⟨0, by omega⟩ ⟨j + 1, hj⟩ h) =
        (kvE2_sep_zFutT3 ⟨j, by omega⟩).1 :=
      congrArg Prod.fst (congrFun hzs ⟨j, by omega⟩)
    change (x1 < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨j, by omega⟩)
      ↔ σ.1 (.order ⟨0, by omega⟩ ⟨j + 1, hj⟩ h) = true
    rw [e1]
    refine iff_of_false ?_ (by
      show ¬ ((kvE2_sep_zFutT3 ⟨j, by omega⟩).1 = true)
      match j, hj with
      | 0, _ => exact Bool.false_ne_true
      | 1, _ => exact Bool.false_ne_true
      | 2, _ => exact Bool.false_ne_true)
    match j, hj with
    | 0, _ => exact lt_asymm (hwt.trans htx1)
    | 1, _ => exact lt_asymm ((hxw.trans hwt).trans htx1)
    | 2, _ => exact lt_asymm htx1
  | .order ⟨i + 1, hi⟩ ⟨0, _⟩ h =>
    have e2 : σ.1 (.order ⟨i + 1, hi⟩ ⟨0, by omega⟩ h) =
        (kvE2_sep_zFutT3 ⟨i, by omega⟩).2 :=
      congrArg Prod.snd (congrFun hzs ⟨i, by omega⟩)
    change ((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨i, by omega⟩ < x1)
      ↔ σ.1 (.order ⟨i + 1, hi⟩ ⟨0, by omega⟩ h) = true
    rw [e2]
    refine iff_of_true ?_ (by
      show (kvE2_sep_zFutT3 ⟨i, by omega⟩).2 = true
      match i, hi with
      | 0, _ => rfl
      | 1, _ => rfl
      | 2, _ => rfl)
    match i, hi with
    | 0, _ => exact hwt.trans htx1
    | 1, _ => exact (hxw.trans hwt).trans htx1
    | 2, _ => exact htx1
  | .order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h =>
    have hij : i ≠ j := by
      simp only [ne_eq, Fin.mk.injEq] at h; omega
    have hne : (⟨i, by omega⟩ : Fin 3) ≠ ⟨j, by omega⟩ := by
      simp only [ne_eq, Fin.mk.injEq]; exact hij
    have hb : σ.1 (.order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h) =
        qnf.1 (.order ⟨i, by omega⟩ ⟨j, by omega⟩ hne) := by
      rw [← hbase]
      simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
      rfl
    change ((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨i, by omega⟩ <
        (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨j, by omega⟩)
      ↔ σ.1 (.order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h) = true
    rw [hb]
    have hh := henv (.order ⟨i, by omega⟩ ⟨j, by omega⟩ hne)
    simpa only [atom_eval] using hh

/-- **Chain destruction** (converse of `kvE2_futChainBuild`): a true `D`-guarded chain
    at `s` yields an endpoint `x1 > s` satisfying `endF`, a `D`-uniform gap `(s, x1)`
    (given that each visited profile's characteristic pointwise implies `D`), and one
    occurrence in `(s, x1)` for every profile in the chain's list. -/
private theorem kvE2_futChainDestruct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (endF D : Formula) :
    ∀ (l : List (NormalForm sig 0 1)) (s : M.carrier),
      (∀ χ ∈ l, ∀ r : M.carrier,
        temporal_truth M atomMap r (nf_depth0_char_formula atomMap h_surj χ) →
        temporal_truth M atomMap r D) →
      temporal_truth M atomMap s (kvE2_futChain atomMap h_surj endF D l) →
      ∃ x1 : M.carrier, s < x1 ∧ temporal_truth M atomMap x1 endF ∧
        (∀ r : M.carrier, s < r → r < x1 → temporal_truth M atomMap r D) ∧
        (∀ χ ∈ l, ∃ r : M.carrier, s < r ∧ r < x1 ∧
          temporal_truth M atomMap r (nf_depth0_char_formula atomMap h_surj χ)) := by
  intro l
  induction l with
  | nil =>
    intro s _ hch
    simp only [kvE2_futChain] at hch
    obtain ⟨x1, hsx1, hend, hgap⟩ := hch
    exact ⟨x1, hsx1, hend, hgap, by simp⟩
  | cons χ rest ih =>
    intro s himp hch
    simp only [kvE2_futChain] at hch
    obtain ⟨r₀, hsr₀, hconj, hgap1⟩ := hch
    rw [formula_conjList_iff] at hconj
    have hχr₀ : temporal_truth M atomMap r₀ (nf_depth0_char_formula atomMap h_surj χ) :=
      hconj _ (by simp)
    have hrest : temporal_truth M atomMap r₀ (kvE2_futChain atomMap h_surj endF D rest) :=
      hconj _ (by simp)
    obtain ⟨x1, hr₀x1, hend, hgap2, hocc⟩ :=
      ih r₀ (fun χ' hχ' => himp χ' (List.mem_cons_of_mem χ hχ')) hrest
    refine ⟨x1, hsr₀.trans hr₀x1, hend, ?_, ?_⟩
    · intro r hsr hrx1
      rcases lt_trichotomy r r₀ with hlt | heq | hgt
      · exact hgap1 r hsr hlt
      · exact heq ▸ himp χ List.mem_cons_self r₀ hχr₀
      · exact hgap2 r hgt hrx1
    · intro χ' hχ'
      rcases List.mem_cons.mp hχ' with rfl | hmem
      · exact ⟨r₀, hsr₀, hr₀x1, hχr₀⟩
      · obtain ⟨r, hr₀r, hrx1, hprof⟩ := hocc χ' hmem
        exact ⟨r, hsr₀.trans hr₀r, hrx1, hprof⟩

/-- **Family completeness** (Cor 5.4(2) exterior analog, ⇐ — the Phase-2 BINDING
    signature at family generality): if no exterior `x1 > t` realizes σ, the complement
    clause holds at `t`. Conditional on the gate-level pins `henv`/`hbelow` (available at
    both consumption sites) plus the two syntactic σ-side hypotheses `hbase`/`hbits`
    (the recorded Phase-4 obligations). Admissibility is NOT hypothesized — a true
    positive form certifies it (the else-branch is `⊥`). -/
theorem kvE2_extNegFut_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hbase : nf0_dropFresh σ.1 = qnf.1)
    (hbits : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
      (zs = kvE2_sep_zPastX3 ∨ zs = kvE2_sep_zAtX3 ∨ zs = kvE2_sep_zXW3 ∨
        zs = kvE2_sep_zAtW3 ∨ zs = kvE2_sep_zWT3 ∨ zs = kvE2_sep_zAtT3) →
      σ.2 (nf0_assemble (Fin.cons (true, false) zs) χ σ.1) = kvE2_futAnyBit qnf zs χ)
    (hnorel : ∀ x1 : M.carrier, t < x1 →
      ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap t (kvE2_extNegFut atomMap h_surj σ) := by
  intro hPos
  by_cases hadm : kvE2_futAdmissible σ = true
  case neg =>
    rw [kvE2_futPos, if_neg hadm] at hPos
    exact hPos
  case pos =>
  -- unpack admissibility into its four syntactic components
  have hadm' := hadm
  rw [kvE2_futAdmissible] at hadm'
  simp only [Bool.and_eq_true] at hadm'
  obtain ⟨⟨⟨hadm1, hadm2⟩, hadm3⟩, hadm4⟩ := hadm'
  have hzs : nf0_zoneSpec σ.1 = kvE2_sep_zFutT3 := of_decide_eq_true hadm1
  have hoff : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false := by
    intro τ hτ
    rw [List.all_eq_true] at hadm2
    have h2 := hadm2 τ (Finset.mem_toList.mpr (Finset.mem_univ τ))
    rw [Bool.or_eq_true] at h2
    rcases h2 with h2 | h2
    · have h2' : nf0_dropFresh τ = show NormalForm sig 0 4 from σ.1 := of_decide_eq_true h2
      exact absurd h2' hτ
    · simpa using h2
  have himposs : ∀ zs : ZoneSpec 4, zs ∉ kvE2_futPossibleZones →
      ∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble zs χ σ.1) = false := by
    intro zs hzp χ
    rw [List.all_eq_true] at hadm3
    have h2 := hadm3 zs (Finset.mem_toList.mpr (Finset.mem_univ zs))
    rw [Bool.or_eq_true] at h2
    rcases h2 with h2 | h2
    · exfalso
      obtain ⟨z, hzmem, hdec⟩ := List.any_eq_true.mp h2
      exact hzp ((of_decide_eq_true hdec) ▸ hzmem)
    · rw [List.all_eq_true] at h2
      have h3 := h2 χ (Finset.mem_toList.mpr (Finset.mem_univ χ))
      simpa using h3
  have hself : ∀ χ : NormalForm sig 0 1,
      kvE2_futSelfBit σ χ = decide (χ = nf0_projFresh σ.1) := by
    intro χ
    rw [List.all_eq_true] at hadm4
    exact of_decide_eq_true (hadm4 χ (Finset.mem_toList.mpr (Finset.mem_univ χ)))
  -- destructure the true positive form: some permutation chain is true at t
  rw [kvE2_futPos, if_pos hadm, formula_disjList_iff] at hPos
  obtain ⟨f, hfmem, hftruth⟩ := hPos
  obtain ⟨l, hlmem, rfl⟩ := List.mem_map.mp hfmem
  have hlperm : l.Perm (kvE2_futGapList σ) := List.mem_permutations.mp hlmem
  -- a visited gap profile's characteristic implies the gap guard D
  have himpD : ∀ χ ∈ l, ∀ r : M.carrier,
      temporal_truth M atomMap r (nf_depth0_char_formula atomMap h_surj χ) →
      temporal_truth M atomMap r (kvE2_futGapD atomMap h_surj σ) := by
    intro χ hχ r hr
    rw [kvE2_futGapD, formula_disjList_iff]
    exact ⟨_, List.mem_map.mpr ⟨χ, hlperm.mem_iff.mp hχ, rfl⟩, hr⟩
  obtain ⟨x1, htx1, hend, hgapD, hoccl⟩ :=
    kvE2_futChainDestruct M atomMap h_surj (kvE2_futEnd atomMap h_surj σ)
      (kvE2_futGapD atomMap h_surj σ) l t himpD hftruth
  -- endpoint description: fresh profile + exact ray content
  rw [kvE2_futEnd, formula_conjList_iff] at hend
  have hchfr : temporal_truth M atomMap x1
      (nf_depth0_char_formula atomMap h_surj (nf0_projFresh σ.1)) := hend _ (by simp)
  have hrayform : temporal_truth M atomMap x1 (kvE2_futRayForm atomMap h_surj σ) :=
    hend _ (by simp)
  have hx1fr : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1) :=
    (nf_depth0_char_correct' M atomMap h_surj _ x1).mp hchfr
  rw [kvE2_futRayForm, formula_conjList_iff] at hrayform
  have hnoray : temporal_truth M atomMap x1
      (Formula.untl (kvE2_futRayD atomMap h_surj σ).neg Formula.top).neg :=
    hrayform _ (by simp)
  have hray : ∀ u : M.carrier, x1 < u →
      temporal_truth M atomMap u (kvE2_futRayD atomMap h_surj σ) := by
    intro u hu
    by_contra hc
    exact hnoray ⟨u, hu, hc, fun r _ _ => id⟩
  have hrayocc : ∀ χ ∈ kvE2_futRayList σ, ∃ u : M.carrier, x1 < u ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro χ hχ
    have h := hrayform _ (List.mem_cons_of_mem _ (List.mem_map.mpr ⟨χ, hχ, rfl⟩))
    obtain ⟨u, hu, hchu, -⟩ := h
    exact ⟨u, hu, (nf_depth0_char_correct' M atomMap h_surj χ u).mp hchu⟩
  -- gap points carry gap profiles
  have hgapprof : ∀ r : M.carrier, t < r → r < x1 →
      ∃ χ, kvE2_futGapBit σ χ = true ∧ nf_eval_nf M 0 1 (fun _ => r) χ := by
    intro r htr hrx1
    have h := hgapD r htr hrx1
    rw [kvE2_futGapD, formula_disjList_iff] at h
    obtain ⟨g, hg, hgt2⟩ := h
    obtain ⟨χ, hχmem, rfl⟩ := List.mem_map.mp hg
    exact ⟨χ, (List.mem_filter.mp hχmem).2,
      (nf_depth0_char_correct' M atomMap h_surj χ r).mp hgt2⟩
  -- each gap profile occurs in (t, x1)
  have hgapocc : ∀ χ : NormalForm sig 0 1, kvE2_futGapBit σ χ = true →
      ∃ r : M.carrier, t < r ∧ r < x1 ∧ nf_eval_nf M 0 1 (fun _ => r) χ := by
    intro χ hb
    have hχl : χ ∈ l := hlperm.mem_iff.mpr
      (List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ χ), hb⟩)
    obtain ⟨r, htr, hrx1, hchr⟩ := hoccl χ hχl
    exact ⟨r, htr, hrx1, (nf_depth0_char_correct' M atomMap h_surj χ r).mp hchr⟩
  -- x1 realizes σ, contradicting hnorel
  apply hnorel x1 htx1
  refine (nf_eval_depth1_fold_iff M _ σ).mpr ⟨?_, ?_, ?_⟩
  · exact kvE2_futSigma_atom M qnf σ x1 w x t hxw hwt htx1 henv hzs hbase hx1fr
  · intro zs χ
    constructor
    · rintro ⟨v, hzv, hvχ⟩
      rcases lt_trichotomy v x1 with hlt | heq | hgt
      · rcases le_or_gt v t with hvt | htv
        · -- at-or-below t : reduce to the qnf-pinned zone fact via hbits + hbelow
          have hz3 : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) (Fin.tail zs) v :=
            fun i => hzv i.succ
          have h0 := hzv 0
          have hzeq0 : zs 0 = (true, false) :=
            Prod.ext (h0.1.mp hlt) (by
              cases hb : (zs 0).2 with
              | false => rfl
              | true => exact absurd (h0.2.mpr hb) (lt_asymm hlt))
          have hcls := kvE2_futBelowClass M v w x t hxw hwt hvt (Fin.tail zs) hz3
          rw [← Fin.cons_self_tail zs, hzeq0]
          rcases hcls with h | h | h | h | h | h
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inl rfl)]
            exact (hbelow _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inl rfl))]
            exact (hbelow _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inr (Or.inl rfl)))]
            exact (hbelow _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inl rfl))))]
            exact (hbelow _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl rfl)))))]
            exact (hbelow _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr rfl)))))]
            exact (hbelow _ χ rfl).mp ⟨v, hz3, hvχ⟩
        · -- gap (t, x1) : profile forced into the gap alphabet by the D-uniform gap
          have hzeq : zs = Fin.cons (true, false) kvE2_sep_zFutT3 :=
            kvE2_futCharZone4 M v x1 w x t zs hzv (true, false) (false, true) (false, true)
              (false, true)
              (iff_of_true hlt rfl) (iff_of_false (lt_asymm hlt) Bool.false_ne_true)
              (iff_of_false (lt_asymm (hwt.trans htv)) Bool.false_ne_true)
              (iff_of_true (hwt.trans htv) rfl)
              (iff_of_false (lt_asymm ((hxw.trans hwt).trans htv)) Bool.false_ne_true)
              (iff_of_true ((hxw.trans hwt).trans htv) rfl)
              (iff_of_false (lt_asymm htv) Bool.false_ne_true) (iff_of_true htv rfl)
          rw [hzeq]
          obtain ⟨χ', hb', hχ'v⟩ := hgapprof v htv hlt
          have hχeq : χ = χ' := nf_profile_unique M v χ χ' hvχ hχ'v
          change kvE2_futGapBit σ χ = true
          rw [hχeq]
          exact hb'
      · -- v = x1 : the fresh point, profile = σ's fresh profile
        have hzeq : zs = Fin.cons (false, false) kvE2_sep_zFutT3 :=
          kvE2_futCharZone4 M v x1 w x t zs hzv (false, false) (false, true) (false, true)
            (false, true)
            (iff_of_false (heq ▸ lt_irrefl x1) Bool.false_ne_true)
            (iff_of_false (heq ▸ lt_irrefl x1) Bool.false_ne_true)
            (iff_of_false (heq ▸ lt_asymm (hwt.trans htx1)) Bool.false_ne_true)
            (iff_of_true (heq ▸ hwt.trans htx1) rfl)
            (iff_of_false (heq ▸ lt_asymm ((hxw.trans hwt).trans htx1)) Bool.false_ne_true)
            (iff_of_true (heq ▸ (hxw.trans hwt).trans htx1) rfl)
            (iff_of_false (heq ▸ lt_asymm htx1) Bool.false_ne_true)
            (iff_of_true (heq ▸ htx1) rfl)
        rw [hzeq]
        change kvE2_futSelfBit σ χ = true
        rw [hself χ]
        exact decide_eq_true (nf_profile_unique M v χ _ hvχ (heq ▸ hx1fr))
      · -- ray (x1, ∞) : profile forced into the ray alphabet by the exact-ray-content
        have hzeq : zs = Fin.cons (false, true) kvE2_sep_zFutT3 :=
          kvE2_futCharZone4 M v x1 w x t zs hzv (false, true) (false, true) (false, true)
            (false, true)
            (iff_of_false (lt_asymm hgt) Bool.false_ne_true) (iff_of_true hgt rfl)
            (iff_of_false (lt_asymm (hwt.trans (htx1.trans hgt))) Bool.false_ne_true)
            (iff_of_true (hwt.trans (htx1.trans hgt)) rfl)
            (iff_of_false (lt_asymm ((hxw.trans hwt).trans (htx1.trans hgt)))
              Bool.false_ne_true)
            (iff_of_true ((hxw.trans hwt).trans (htx1.trans hgt)) rfl)
            (iff_of_false (lt_asymm (htx1.trans hgt)) Bool.false_ne_true)
            (iff_of_true (htx1.trans hgt) rfl)
        rw [hzeq]
        change kvE2_futRayBit σ χ = true
        have hrD := hray v hgt
        rw [kvE2_futRayD, formula_disjList_iff] at hrD
        obtain ⟨g, hg, hgt2⟩ := hrD
        obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hg
        have hχeq : χ = χ' := nf_profile_unique M v χ χ' hvχ
          ((nf_depth0_char_correct' M atomMap h_surj χ' v).mp hgt2)
        rw [hχeq]
        exact (List.mem_filter.mp hχ'mem).2
    · intro hbitv
      by_cases hzp : zs ∈ kvE2_futPossibleZones
      · rcases kvE2_futPossibleZones_cases hzp with
          rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
        · rw [hbits _ χ (Or.inl rfl)] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zPastX3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inl rfl))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zAtX3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inr (Or.inl rfl)))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zXW3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inl rfl))))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zAtW3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl rfl)))))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zWT3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr rfl)))))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (hbelow kvE2_sep_zAtT3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_futZone4_below_iff M x1 w x t htx1 _ rfl v).mpr hv3, hvχ⟩
        · -- gap
          obtain ⟨r, htr, hrx1, hrχ⟩ := hgapocc χ hbitv
          exact ⟨r, kvE2_futZone4_of_above M r x1 w x t hxw hwt htr (true, false)
              (iff_of_true hrx1 rfl) (iff_of_false (lt_asymm hrx1) Bool.false_ne_true), hrχ⟩
        · -- self
          have hb : kvE2_futSelfBit σ χ = true := hbitv
          rw [hself χ] at hb
          have hχf : χ = nf0_projFresh σ.1 := of_decide_eq_true hb
          subst hχf
          exact ⟨x1, kvE2_futZone4_of_above M x1 x1 w x t hxw hwt htx1 (false, false)
              (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
              (iff_of_false (lt_irrefl x1) Bool.false_ne_true), hx1fr⟩
        · -- ray
          have hb : kvE2_futRayBit σ χ = true := hbitv
          obtain ⟨u, hx1u, huχ⟩ := hrayocc χ
            (List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ χ), hb⟩)
          exact ⟨u, kvE2_futZone4_of_above M u x1 w x t hxw hwt (htx1.trans hx1u)
              (false, true)
              (iff_of_false (lt_asymm hx1u) Bool.false_ne_true) (iff_of_true hx1u rfl), huχ⟩
      · rw [himposs zs hzp χ] at hbitv
        exact absurd hbitv Bool.false_ne_true
  · exact hoff

end Bimodal.Metalogic.WeakCanonical.Kamp
