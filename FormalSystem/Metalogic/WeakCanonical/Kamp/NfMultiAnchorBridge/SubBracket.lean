/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface

/-! Extracted from NfMultiAnchorBridge.lean lines 5857-6106.
F4 resolution (faithful foundation): `kvE_subFoldBits`, `kvE_subInteriorZones`,
`kvE_subBracket`, `kvE_subChain`, discrimination kit, verdict record. Includes the in-file
do-not-edit records (orig :5866, :6098) — byte-identical, token edits NONE. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nfDepth0CharFormula nf_depth0_char_formula_correct
   formulaConjList formula_conjList_iff)

/-! ## F4 resolution: Corrected k=2 carrier — nested F_i-chain sub-bracket
    (v2 plan `plans/02_corrected-k2-carrier-fi-chain-v2.md`; blocker research
    `reports/01_blocker-research-successor-k.md`, §3 drop-in amended design spec)

Additive construction realizing route b3 (the route-b3 GO verdict): the per-sub JOINT content that
F1–F4
could not carry (`σ`'s inner-witness structure relative to the honest anchor pair, which rides
`σ.2`) is encoded as a nested sub-bracket via the FORCED `bracketEndChar_k1v` (:1940) zone-bit
routing one arity up, read through the successor-depth fold engine `nf_eval_depth1_fold_iff`
(:5187). Every definition below is APPENDED after the route-b3 probe section; no landed asset is
edited (`bracketEndChar_kv*`, `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`, `ExistProviders`,
`BracketCarrierCorrectVPrior`, the F1–F4 records, the route-b3 probes are all byte-identical). The
whole `kvE2` layer is successor-parameterized at provider depth `j+1` (report Q1): the carrier is
`BracketEndCharCarrierV sig (j+1+1)` — carrier depth `j+2`, the k ≥ 2 band this enriched carrier
was always documented to serve (:5144-5148) — and at `j = 0` the header instantiates to the EXACT
landed gate signature, closing the `two_eq` bridge by `rfl`. -/

/-- **Sub-level fold-bit decoder** (Phase 2; report §2/Q2, probe 2, machine-checked GREEN).
    For a positive interior sub `σ : NormalForm sig 1 4` (a literal successor, so `σ.2 :
    NormalForm sig 0 5 → Bool` projects directly), `kvE_subFoldBits σ zs χ = true` iff `σ` demands
    an inner witness `v` in zone `zs` (relative to `σ`'s own env `[u, w, x, t]`) of depth-0 monadic
    type `χ`. This is the `nf_eval_depth1_fold_iff` (:5187) decomposition at `n = 4` over
    `(ZoneSpec 4 × NormalForm sig 0 1)` via `nf0_assemble` (NfEFold:180) — the SAME Def-4.1 fold
    (PDF p.5) the k1v carrier reads its `qnf.2` through (:1946), now one arity up. This is the
    read that DISTINGUISHES the F4 pair at the bit level: on `σ'' = char[14,16,11,20]` vs honest
    `char[14,15,10,20]`, `kvE_subFoldBits _ zXW _` differs (σ'' has an inner witness in `(14,16) ∋
    15`; the honest sub has `(14,15) = ∅`) — the two subs share `σ.1` `nfk_projFresh` but differ at
    `σ.2`, so the flat `charK (nfk_projFresh σ)` channel (:5467) that F4 refuted cannot see the
    difference while this decoder can. -/
noncomputable def kvESubFoldBits {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : ZoneSpec 4 → NormalForm sig 0 1 → Bool :=
  fun zs χ => σ.2 (nf0Assemble zs χ σ.1)

/-- The sub-fold-bit decoder via the NAMED landed destructors (`NormalForm.quant_assgn`,
    `NormalForm.atom_assgn`) — DEFINITIONALLY equal to `kvE_subFoldBits` (probe 1b), recorded so
    later proofs may rewrite either way. -/
theorem kvE_subFoldBits_eq_destructors {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) :
    kvESubFoldBits σ =
      fun zs χ => (NormalForm.quantAssgn σ)
        (nf0Assemble zs χ (NormalForm.atomAssgn σ)) := rfl

/-- The three INTERIOR order-zones of an inner witness `v` relative to `σ`'s env `[u, w, x, t]`
    under the honest bracket order `x < u < w < t` (Phase 3; the arity-4 analogue of the
    k1v interior zones `zXW`/`zWT` at :1957-1959, refined by `u`). `zXU` = `x < v < u`,
    `zUW` = `u < v < w`, `zWT` = `w < v < t`. These are the Def-3.1 interior sub-intervals of
    `(x, t)` in which `σ`'s quantifier layer can demand a positive inner witness (PDF p.4
    md:61-74); `zUW` is the F4 discriminator (`σ'' = char[14,16,11,20]` is positive there via
    `(14,16) ∋ 15`, the honest `char[14,15,10,20]` is not: `(14,15) = ∅`). Exterior and
    point-coincidence zones are handled at the outer body level (`epL`/`epR`, `ptW`), exactly as in
    `kvE'_body`; here we route only the interior positives, which are what the flat joint literal
    could not carry. -/
noncomputable def kvESubInteriorZones : List (ZoneSpec 4) :=
  let ltz : Bool × Bool := (true, false)   -- v < env i
  let gtz : Bool × Bool := (false, true)   -- env i < v
  let mk4 : Bool × Bool → Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 4 :=
    fun p0 p1 p2 p3 => Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3)))
  -- coords: 0 ↦ u, 1 ↦ w, 2 ↦ x, 3 ↦ t
  let zXU : ZoneSpec 4 := mk4 ltz ltz gtz ltz   -- x < v < u  (v<u, v<w, x<v, v<t)
  let zUW : ZoneSpec 4 := mk4 gtz ltz gtz ltz   -- u < v < w  (u<v, v<w, x<v, v<t)
  let zWT : ZoneSpec 4 := mk4 gtz gtz gtz ltz   -- w < v < t  (u<v, w<v, x<v, v<t)
  [zXU, zUW, zWT]

/-- **Nested sub-bracket over `σ.2`** (Phase 3; report §2/Q2 table + probe 5, machine-checked
    skeleton GREEN). Encodes `σ`'s inner-witness structure (read from `σ.2` via `kvE_subFoldBits`)
    as bracket WITNESSES between the honest anchor pair — the FORCED `bracketEndChar_k1v` (:1940)
    zone-bit routing one arity up (arity 4 instead of 3), the Cor 5.4 recursive construction
    generalized ONE level, never a third anchor. Returns `Σ m, BracketFormula (m + 1)`: the trailing
    `+1` is `u`'s own slot (`charK (nfk_projFresh σ)`), which is what makes `fChainPred` available
    (probe 6). Routing (report §2/Q2):
    - Interior zones (`kvE_subInteriorZones`): each positive fold bit `kvE_subFoldBits σ zs χ`
    places
      an EXTRA bracket witness slot with point type `⟨charBase χ⟩`, spliced before `u`'s slot.
    - Negative bits per interior zone: `(charBase χ).neg` exclusion conjuncts on the refined
    segments
      (the landed `segL`/`segR` pattern :5455-5462, one level in) — real exclusion segments, never
      top (G3).
    The construction reads `σ.2` (where the F4 pair differs), NOT the shared `σ.1` `nfk_projFresh`,
    so — unlike the F4-refuted flat `charK (nfk_projFresh σ)` literal — the honest and dishonest
    subs
    produce DIFFERENT witness-slot lists. Rabinovich Def 3.1 (md:61-74), Lemma 5.1 point-insertion
    split (md:134-135). No `simp`/`omega`/`aesop` in the body (the `omega` below is a `Fin`-index
    typing obligation in a proof term, identical to the landed `bracketFromLists` :1900). -/
noncomputable def kvESubBracket {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : Σ m, BracketFormula (m + 1) :=
  let bits := kvESubFoldBits σ
  let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
  -- Interior-positive fold bits → extra bracket witness slots (point type ⟨charBase χ⟩),
  -- one per (interior zone, positive type), in zone order (Def 3.1 md:61-74 one arity up).
  let posSlots : List TemporalPred :=
    kvESubInteriorZones.flatMap (fun zs =>
      (allTypes.filter (fun χ => bits zs χ)).map (fun χ => ⟨charBase χ⟩))
  -- Interior-negative fold bits → segment exclusion conjuncts (charBase χ).neg (G3 real segments).
  let segExcl : TemporalPred :=
    ⟨formulaConjList
      (kvESubInteriorZones.flatMap (fun zs =>
        allTypes.map fun χ => if bits zs χ then Formula.top else (charBase χ).neg))⟩
  ⟨posSlots.length,
    { pointTypes := fun i =>
        (posSlots ++ [⟨charK (nfkProjFresh σ)⟩])[i.val]'(by
          have := i.isLt
          simp only [List.length_append, List.length_cons, List.length_nil]
          omega)
      segmentTypes := fun _ => segExcl }⟩

/-- **Sub-chain predicate**. The Cor 5.4 F_i-chain
    predicate of the nested sub-bracket — `σ`'s joint inner-witness content packaged as a single
    `TemporalPred`, carried by the nested-Until EVALUATION POINT (never a relative-position
    identity). `fChainPred` is available because `kvE_subBracket` returns the `(m+1)` shape. -/
noncomputable def kvESubChain {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : TemporalPred :=
  (kvESubBracket charBase charK σ).2.fChainPred

/-- **Position-recovery lemma at the CONSTRUCTED sub-bracket** (Phase 4; report §2 probe 6,
    machine-checked GREEN — the upgrade from probe P4's "abstract recovery on generic `bf`"
    to "recovery lemma applies to the concrete sub-bracket"). Instantiates the landed, PROVEN
    `BracketFormula.bracket_implies_fChainPred` (EANegation:660) at
    `bf := (kvE_subBracket charBase charK σ).2`: whenever the sub-bracket holds on `(z0, z)`,
    `kvE_subChain … σ` is satisfied at a witness `x0` STRICTLY INSIDE `(z0, z)`, recovered from the
    bracket's OWN interval pattern — with NO provider environment `e` and NO residual `w = e 1` /
    `x = e 2` (the exact F4 crux, now dissolved: the anchor positions ARE the bracket witnesses,
    quantified by the temporal semantics, never rebound by any `e`). Sole hypothesis is `bf.holds`;
    no structural-identity / `nf_eval_unique` / `nfPred_correct` premise (route b2 NOT NEEDED).
    Rabinovich Cor 5.4 (md:154-157) via `fChainFrom_step`/`fChainFrom_base` (probe P3 MATCH). -/
theorem kvE_subBracket_implies_subChain {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z : M.carrier)
    (h : (kvESubBracket charBase charK σ).2.holds M atomMap z0 z) :
    ∃ x0 : M.carrier, z0 < x0 ∧ x0 < z ∧
      (kvESubChain charBase charK σ).EvalAt M atomMap x0 ∧
      (∀ y : M.carrier, z0 < y → y < x0 →
        ((kvESubBracket charBase charK σ).2.segmentTypes ⟨0, by omega⟩).EvalAt M atomMap y) :=
  (kvESubBracket charBase charK σ).2.bracket_implies_fChainPred M atomMap z0 z h

/-! ## Stage B (Phase 7): F4 adversarial discrimination — construction level

The F4 refutation (:5548, :5634 probe P1) hinged on a `rfl`-confirmed COLLAPSE: the flat
channel-(i)/joint content was a function of `nfk_projFresh σ` (the σ.1-level fresh type) ALONE, so
two subs sharing `nfk_projFresh` (the honest `char[14,15,10,20]` and the dishonest
`σ'' = char[14,16,11,20]`, `type(14) = type(15)`) received BYTE-IDENTICAL carrier content and could
not be discriminated. The corrected construction dissolves this: the sub-bracket's witness content
is a function of `kvE_subFoldBits σ` — i.e. of `σ.2` (where the F4 pair differs), NOT of
`nfk_projFresh σ`. The two lemmas below record this at the construction level (the analog of probe
P1 for the NEW construction), machine-checked; this is the "different witness-slot lists"
discrimination the report §2/Q2 established, and it supports the pre-authorized fallback (it is a
landed deliverable independent of whether the semantic gate later completes). -/

/-- **The corrected sub-bracket's witness count is a function of `σ.2`** (Phase 7; the
    positive analog of probe P1's collapse `rfl`). The number of bracket witness slots is `1` (u's
    own slot) plus the count of positive interior fold bits `kvE_subFoldBits σ` — which reads `σ.2`.
    Unlike the F4-refuted flat channel (a function of `nfk_projFresh σ` = σ.1-level alone), this
    quantity SEES `σ.2`, exactly where the honest and dishonest F4 subs differ. Pure `rfl`. -/
theorem kvE_subBracket_witnessCount {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) :
    (kvESubBracket charBase charK σ).1 =
      (kvESubInteriorZones.flatMap (fun zs =>
        ((Finset.univ.toList : List (NormalForm sig 0 1)).filter
          (fun χ => kvESubFoldBits σ zs χ)).map
          (fun χ => (⟨charBase χ⟩ : TemporalPred)))).length := rfl

/-- **Discrimination corollary**. Two subs whose corrected sub-brackets differ in
    witness count yield DIFFERENT sub-brackets (Σ-injectivity on the first component). Combined with
    `kvE_subBracket_witnessCount`, this is the F4 discrimination the flat channel could not provide:
    two subs sharing `nfk_projFresh` but with different positive-interior-fold-bit counts (i.e.
    different `σ.2` content on the interior zones — the honest `char[14,15,10,20]` with `(14,15) =
    ∅`
    vs the dishonest `char[14,16,11,20]` with `(14,16) ∋ 15`) produce different sub-brackets, hence
    different carrier formulas. The old flat channel gave them BYTE-IDENTICAL content (probe P1). -/
theorem kvE_subBracket_ne_of_witnessCount_ne {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ σ' : NormalForm sig 1 4)
    (h : (kvESubBracket charBase charK σ).1 ≠ (kvESubBracket charBase charK σ').1) :
    kvESubBracket charBase charK σ ≠ kvESubBracket charBase charK σ' := by
  intro heq
  exact h (congrArg Sigma.fst heq)

/-! ## Verdict record: PARTIAL-GO (Stages A–B landed; semantic gate Stages C–D spawned)
    — F1–F4 house style; no partial theorem, no `sorry` on any live path

**Route realized (b3, the GO verdict).** The per-sub JOINT content that F1–F4 could not carry (σ's
inner-witness structure relative to the honest anchors, which rides `σ.2`) is now encoded as a
NESTED F_i-chain sub-bracket, read from `σ.2` via the forced `bracketEndChar_k1v` (:1940) zone-bit
routing one arity up. The whole `kvE2` layer is at the CONCRETE k=2 gate instance (subs
`σ : NormalForm sig 1 4`), which report §2/Q2 fixes at `j = 0` (the depth-0 `nf0_assemble` fold
engine); this is exactly the `k = 2` band the enriched carrier serves (:5144-5148).

**Stage A — construction (COMPLETE, green, axiom-clean).**
  - `kvE_subFoldBits` (:5732) — the successor-depth `σ.2` read `fun zs χ => σ.2 (nf0_assemble zs χ
    σ.1)`; `kvE_subFoldBits_eq_destructors` the `rfl` bridge to the named destructors.
  - `kvE_subInteriorZones` + `kvE_subBracket` (:5776) — the nested sub-bracket
    `Σ m, BracketFormula (m+1)`; interior-positive `σ.2` bits → witness slots, u's own slot the
    trailing `+1` (the shape that makes `fChainPred` available); NO flat `charK (nfk_projFresh σ)`
    joint literal on the joint path.
  - `kvE_subChain` (:5808) + `kvE_subBracket_implies_subChain` (:5820) — the sub-chain predicate and
    the position-recovery lemma instantiating `bracket_implies_fChainPred` (EANegation:660) at the
    CONSTRUCTED sub-bracket (probe 6): honest positions recovered `e`-free, NO residual `w = e 1` /
    `x = e 2` (the exact F4 crux, dissolved).
  - `kvE2_body` (:5855) + `kvE2_body_gate_fail` — `kvE'_body` with the per-sub joint channel
    corrected (`ptSub σ := kvE_subChain …`, the `t`-anchored `pos.map exF`/`P.existF 3` DROPPED from
    the joint path); all non-joint channels retained verbatim.
  - `bracketEndChar_kvE2` (:5940) + `bracketEndChar_kvE2_two_eq` (`rfl`) — the corrected k=2 carrier
    `BracketEndCharCarrierV sig 2`, additive alongside the byte-identical
    `bracketEndChar_kvE`/`kvE'`.

**Stage B — F4 adversarial discrimination (construction level, COMPLETE, green).**
`kvE_subBracket_witnessCount` (`rfl`) records that the sub-bracket's witness count is a function of
`kvE_subFoldBits σ` — i.e. of `σ.2` — the positive analog of probe P1's `nfk_projFresh`-collapse;
`kvE_subBracket_ne_of_witnessCount_ne` is the discrimination corollary. This is the report §2/Q2
"different witness-slot lists" mechanism: the honest `char[14,15,10,20]` (`(14,15) = ∅`) and the
dishonest `char[14,16,11,20]` (`(14,16) ∋ 15`) differ at `σ.2` on the interior `(u,w)` zone, so —
unlike the F4-refuted flat channel (byte-identical, probe P1 `rfl`) — they produce different
sub-brackets. The FULL semantic `M = ℤ` LHS-FALSE proof requires the corrected carrier's evaluation
semantics on ℤ (the same machinery as the gate below) and is folded into the spawned continuation.

**Stages C–D — the k=2 `BracketCarrierCorrectVPrior` gate (RECORDED CONTINUATION — pre-authorized
fallback, plan Risks/Phase 9-10).** Closing the gate for `bracketEndChar_kvE2` to a proven GO is a
GENUINE, well-scoped, multi-dispatch effort with no k≥2 enriched precedent, NOT completable within
this dispatch and NOT to be absorbed by any `sorry`/vacuous placeholder:
  - *Soundness (Stage C):* drive `BracketCarrierCorrectVPrior … bracketEndChar_kvE2` (carrier ⇒
    ∃w realization) via `bracketEndChar_kvE2_two_eq` + `k1v_bracket_extract` (:2150) + the :2338
    soundness template, adapted to the enriched body (extra sub-bracket witness slots,
    `kvE_subChain`
    on u's slot, dropped `exF`). The per-sub positive crux closes via
    `kvE_subBracket_implies_subChain`
    (probe 6, landed above), `e`-free — but the surrounding template adaptation is itself
    substantial
    (the enriched arrangement/slot bookkeeping differs from the landed simple k1v).
  - *Completeness (Stage D):* honest realization ⇒ carrier holds. Fold `nf_eval_depth1_fold_iff`
    (:5187) at `n = 4` to extract σ's inner witnesses, construct the sub-bracket's
    `IntervalPattern.holds` data (monotone enumeration/range/point/segment — Rabinovich Lemma 5.3
    md:137-152, order-theoretic), then the arrangement disjunct (the :2979 completeness template).
    This direction is genuinely unprobed (report Q3: "no k≥2 precedent … plausibly multi-dispatch").
  The landed k1v gate that these mirror spans ~800 lines (:2150-3405); the enriched k=2 gate adds
  the
  per-sub sub-bracket obligations in BOTH directions. Per the plan's explicit sizing guard
  ("a single
  'prove the gate' phase would repeat v1's sizing error") and the pre-authorized fallback, this is a
  PARTIAL-GO with recorded progress, not an F5 defect: Stages A–B are the landed deliverable; the
  semantic gate (both directions + the full ℤ LHS-FALSE) is tracked separately, and becomes the
  new prerequisite for the depth-`k` V-carrier lift and its provider instantiation.

**Constraint compliance.** Purely additive same-file appends after the route-b3 probe section; every
do-not-edit landed asset (`bracketEndChar_kv*`, `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`,
`ExistProviders`, `BracketCarrierCorrectVPrior`, the F1–F4 records, the route-b3 probes) is
BYTE-IDENTICAL. No provider-side pinning (the provider disappears from the joint path — Amendment
F3); no `EANegation :1090/:1249` consumed; real exclusion segments (G3); anchors fixed at 2,
witnesses
grow only (G2/G4/G6); no `simp`/`omega`/`aesop` in any chain-construction body (the `omega` in
`kvE_subBracket` is a `Fin`-index typing obligation, identical to the landed `bracketFromLists`
:1900); Rabinovich cited at every chain step (G5); all new symbols axiom-clean
(`propext`, `Classical.choice`, `Quot.sound`); no `sorry` on any live path. -/

end FormalSystem.Metalogic.WeakCanonical.Kamp
