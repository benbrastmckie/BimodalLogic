import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness

/-! # One-Sided Exterior Complement Clauses — R2 GO/NO-GO Spike (task 348, Phase 2)

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
  fun a b => decidable_of_iff (∀ i : Fin n, a i = b i) funext_iff.symm

/-! ## Depth-0 zone-fact read of qnf (the syntactic below-`t` comparison channel) -/

/-- Whether qnf's positive depth-1 layer prescribes a point of monadic profile `χ` in the
    outer zone `zs` of `[w,x,t]`: some positive σ' sits in zone `zs` with fresh profile
    `χ`. Under realized qnf this Bool IS the depth-0 zone fact
    (`kvE2_futAnyBit_correct`) — the syntactic device that lets `σ.2`'s at-or-below-`t`
    bits be compared against qnf without any semantic hypothesis. -/
noncomputable def kvE2_futAnyBit {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (zs : ZoneSpec 3) (χ : NormalForm sig 0 1) : Bool :=
  (kvE2_sepPos qnf).any fun σ' =>
    decide (nf0_zoneSpec σ'.1 = zs) && decide (nf0_projFresh σ'.1 = χ)

/-- Monadic-profile evaluation unfolds to the per-predicate reading (the `AtomKind sig 1`
    order case is uninhabited). -/
private theorem nf_eval_profile_iff {sig : MonadicSignature}
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
private theorem nf_profile_unique {sig : MonadicSignature}
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
private theorem nf_profile_exists {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (v : M.carrier) :
    ∃ χ : NormalForm sig 0 1, nf_eval_nf M 0 1 (fun _ => v) χ :=
  ⟨nf_characteristic M 0 1 (fun _ => v), nf_characteristic_satisfies M 0 1 (fun _ => v)⟩

/-- **`kvE2_futAnyBit` honesty** (Cor 5.4 zone-fact channel): under realized qnf, the
    syntactic bit reads the actual depth-0 zone fact of `[w,x,t]` — for EVERY `zs`. The
    Phase-8 ⇐ half derives the `hbelow` pin from this; the SW:12788-side derivation from
    `hexcl`/`hrealI`/`EpL` is the recorded Phase-8 obligation. -/
theorem kvE2_futAnyBit_correct {sig : MonadicSignature}
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
      show (σv.1 (.order 0 i.succ (Fin.succ_ne_zero i).symm),
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
def kvE2_futSpikeBase {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (χfr : NormalForm sig 0 1) : NormalForm sig 0 4 :=
  nf0_assemble kvE2_sep_zFutT3 χfr qnf.1

/-- The spike σ is `zFutT3`-marked (round-trip 1, `NfEFold.lean:197`). -/
theorem kvE2_futSpikeBase_zone {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (χfr : NormalForm sig 0 1) :
    nf0_zoneSpec (kvE2_futSpikeBase qnf χfr) = kvE2_sep_zFutT3 :=
  nf0_zoneSpec_assemble _ _ _

/-- Inner zone-bit prescription of the spike σ: at-or-below-`t` zones carry qnf's own
    zone facts (`kvE2_futAnyBit`), the gap `(t,x1)` is all-and-only `χmid`, the fresh
    point carries `χfr`, the ray `(x1,∞)` and every other pattern are empty. Zone-4
    coordinates: `0 ↦ x1`, `1 ↦ w`, `2 ↦ x`, `3 ↦ t`; an at-or-below-`t` witness couples
    to `x1` as `(true, false)`. -/
noncomputable def kvE2_futSpikeZoneBit {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (χmid χfr : NormalForm sig 0 1)
    (zs : ZoneSpec 4) (χ : NormalForm sig 0 1) : Bool :=
  if zs = Fin.cons (true, false) kvE2_sep_zPastX3 then kvE2_futAnyBit qnf kvE2_sep_zPastX3 χ
  else if zs = Fin.cons (true, false) kvE2_sep_zAtX3 then kvE2_futAnyBit qnf kvE2_sep_zAtX3 χ
  else if zs = Fin.cons (true, false) kvE2_sep_zXW3 then kvE2_futAnyBit qnf kvE2_sep_zXW3 χ
  else if zs = Fin.cons (true, false) kvE2_sep_zAtW3 then kvE2_futAnyBit qnf kvE2_sep_zAtW3 χ
  else if zs = Fin.cons (true, false) kvE2_sep_zWT3 then kvE2_futAnyBit qnf kvE2_sep_zWT3 χ
  else if zs = Fin.cons (true, false) kvE2_sep_zAtT3 then kvE2_futAnyBit qnf kvE2_sep_zAtT3 χ
  else if zs = Fin.cons (true, false) kvE2_sep_zFutT3 then decide (χ = χmid)
  else if zs = Fin.cons (false, false) kvE2_sep_zFutT3 then decide (χ = χfr)
  else false

/-- **The spike σ** (`NormalForm sig 1 4`): base = `kvE2_futSpikeBase`, quant layer =
    the channel-split read of `kvE2_futSpikeZoneBit` (off-fiber false by construction —
    the `nf0_split_assemble` bijection makes this lossless). -/
noncomputable def kvE2_futSpikeSigma {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (χmid χfr : NormalForm sig 0 1) : NormalForm sig 1 4 :=
  (kvE2_futSpikeBase qnf χfr,
   fun τ => decide (nf0_dropFresh τ = kvE2_futSpikeBase qnf χfr) &&
     kvE2_futSpikeZoneBit qnf χmid χfr (nf0_zoneSpec τ) (nf0_projFresh τ))

/-- The spike σ's fold-bit read computes to the zone-bit prescription (round-trips 1-3). -/
theorem kvE2_futSpikeSigma_bits {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (χmid χfr : NormalForm sig 0 1)
    (zs : ZoneSpec 4) (χ : NormalForm sig 0 1) :
    (kvE2_futSpikeSigma qnf χmid χfr).2
        (nf0_assemble zs χ (kvE2_futSpikeSigma qnf χmid χfr).1) =
      kvE2_futSpikeZoneBit qnf χmid χfr zs χ := by
  show (decide (nf0_dropFresh (nf0_assemble zs χ (kvE2_futSpikeBase qnf χfr)) =
      kvE2_futSpikeBase qnf χfr) &&
    kvE2_futSpikeZoneBit qnf χmid χfr
      (nf0_zoneSpec (nf0_assemble zs χ (kvE2_futSpikeBase qnf χfr)))
      (nf0_projFresh (nf0_assemble zs χ (kvE2_futSpikeBase qnf χfr)))) = _
  rw [nf0_dropFresh_assemble, nf0_zoneSpec_assemble, nf0_projFresh_assemble,
    decide_eq_true rfl, Bool.true_and]

/-! ## The clause (2-link F-chain over `(t, ∞)`, Lemma 5.3 / Lemma 7.10 shape) -/

/-- Fresh-endpoint description: profile `χfr` and an empty future ray (`¬F⊤`). -/
noncomputable def kvE2_futSpikeEnd {sig : MonadicSignature}
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
noncomputable def kvE2_futSpikePos {sig : MonadicSignature}
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
noncomputable def kvE2_extNegFutSpike {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (χmid χfr : NormalForm sig 0 1) : Formula :=
  (kvE2_futSpikePos atomMap h_surj χmid χfr).neg

/-! ## Zone bookkeeping helpers -/

/-- A point strictly above `t` (with `x < w < t`) couples to `[w,x,t]` as `zFutT3` and
    to `x1` by the given pair — the canonical zone-4 spec of each `(t,∞)`-side position. -/
private theorem kvE2_futZone4_of_above {sig : MonadicSignature}
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
private theorem kvE2_futBelow_le_t {sig : MonadicSignature}
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
private theorem kvE2_futZone4_below_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier) (htx1 : t < x1)
    (zs : ZoneSpec 3) (hz3 : (zs ⟨2, by omega⟩).2 = false) (v : M.carrier) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (true, false) zs) v ↔
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v := by
  constructor
  · intro h i
    have := h i.succ
    simpa only [Fin.cons_succ] using this
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
private theorem kvE2_futCharZone4 {sig : MonadicSignature}
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
private theorem kvE2_futCharZone3 {sig : MonadicSignature}
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

end Bimodal.Metalogic.WeakCanonical.Kamp
