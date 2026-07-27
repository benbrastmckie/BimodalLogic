/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness

/-!
# Outer-Gate Assembly Engine — live `bracketEndCharKvE2` + `k = 2` gate correctness

A new **leaf sibling** of `SharedWitness.lean` inside `NfMultiAnchorBridge/`. It is **purely
additive**: nothing here re-proves or edits the faithful carrier `kvE2SepBody`
(`SharedWitness.lean:806`) or any of its correctness lemmas. Those are treated as **verified
INPUTS**; this file only *applies* them.

## What this file delivers

1. **`bracketEndCharKvE2`** — the first LIVE definition of the outer gate (the only prior `def`s
   lived in the quarantined Boneyard and encoded the superseded two-level "navigated" carrier).
   It delegates to the faithful carrier `kvE2SepBody` at the standard instantiation
   (`charBase = nfDepth0CharFormula atomMap h_surj`, `charK = fun χ => P.existF 0 χ`).
2. **`bracketEndChar_kvE2_two_eq`** — an `rfl` bridge exposing the carrier (the delegation is
   definitional because `kvE2SepBody … : NormalForm sig 2 3 → VVecEA2` is *definitionally*
   `BracketEndCharCarrierV sig 2`, `CarrierK1V.lean:365`).
3. **`bracketEndChar_kvE2_complete_two_prior`** — the ⇐ (completeness) half of
   the k=2 gate, UNCONDITIONAL (no interiority hypothesis); consumes the landed completeness engine
   `kvE2_sepBody_holds_of_honest`. Plus its two char-formula bridges `bracketEndChar_kvE2_hcb`/
   `bracketEndChar_kvE2_hck`.
4. **⇒ soundness (`bracketEndChar_kvE2_sound_two_prior_frag`) — DELIVERED** (Phases B/D,
   interior+boundary-scoped): the ⇒ half over the pin-anchored symmetric-gate fold
   `kvE2_outer_fold_frag` (SW:12665), under `hfrag : KvE2SepFragment qnf` with the provider
   realization obligation RE-SHAPED (Phase D, 347 MUST-CHECK 2) to the interior index
   `kvE2SepPosI` (SW:211), interval-bounded `x < x1 < t` (Rabinovich Cor 5.4 ⇐, p.9 l.263-273),
   plus the boundary remainder `hrealB`, the cone exclusion `hexcl`, and the exterior-marked
   `hexclExt` threaded OUTWARD as the `prop43_exterior_reflatten` provider hand-off —
   never discharged on this bracket (Prop 4.3 re-flatten / Lemma 7.6 adjacency, pp.5/16).
5. **Assembled `bracketEndChar_kvE2_correct_two_prior_frag` — DELIVERED**:
   the fragment-restricted, interior+boundary-scoped `holds ↔ ∃ w` gate combining 3 (⇐,
   unconditional) with 4 (⇒), mirroring `bracketEndChar_kv_correct_one_prior`
   (`PriorInterface.lean:95`). The k=2 interior+boundary GO gate consumed by the KampPrior provider
   instantiation at `KampPrior.lean:351`; exterior arrangements ride the adjacent
   brackets composed at the anchors `x, t`.

## Scope decisions (recorded in the file, resolved in the plan)

- **R-A (⇐ generality) → INTERIOR-RESTRICTED CARRIER.** `kvE2_sepBody_complete`
  is now UNCONDITIONAL: the carrier's arrangements index their owners by the interior-restricted
  list `kvE2SepPosI` (a two-zone order-preserving filter of `kvE2SepPos`), so each owner's
  LEFT/RIGHT interiority is a construction invariant recovered definitionally
  (`kvE2_sepPosI_zone`), never a hypothesis on realized types. The historical `hL`/`hLR`
  interiority hypotheses of the earlier gate versions are GONE — `kvE2_sepHonest_hLR_absurd`
  (`SharedWitness.lean`) machine-certifies that any such hypothesis is inconsistent with every
  honest evaluation, which is why none may return. Non-interior positive owners ride the atomic
  `E[Σ]` endpoint/pivot literals (Rabinovich §5, p.7, via Prop 3.5) rather than the interleaving.
- **R-B (KampPrior wiring) → FOLLOW-ON.** The gate is NOT wired into `KampPrior.lean:351`
  (threading `ExistProviders` through `nf_nvar_exist_all_depths`'s `Nat.rec`/`n=1` case) — that
  integration is a distinct downstream task, out of scope here.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (nfDepth0CharFormula)

/-! ## Phase 1 — live wrapper def + `rfl` bridge -/

/-- **The live outer-gate carrier** (first live `def` — supersedes the
    quarantined Boneyard `:918` two-level carrier). At depth-1 providers
    `P : ExistProviders sig atomMap 1` it produces the k=2 carrier `BracketEndCharCarrierV sig 2`,
    delegating to the **faithful** carrier `kvE2SepBody` (`SharedWitness.lean:806`) at
    the standard instantiation `charBase = nfDepth0CharFormula atomMap h_surj`,
    `charK = fun χ => P.existF 0 χ`. The carrier is a verified INPUT — only applied, never
    re-proved. -/
noncomputable def bracketEndCharKvE2 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1) :
    BracketEndCharCarrierV sig 2 :=
  fun qnf => kvE2SepBody (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf

/-- **Definitional bridge**. The live carrier is DEFINITIONALLY the faithful
    body at the standard instantiation — pure `rfl`, because `kvE2SepBody … : NormalForm sig 2 3 →
    VVecEA2` is definitionally `BracketEndCharCarrierV sig 2`. Soundness/completeness lemmas rewrite
    with this to expose `kvE2SepBody`. -/
theorem bracketEndChar_kvE2_two_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3) :
    bracketEndCharKvE2 atomMap h_surj P qnf =
      kvE2SepBody (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf := rfl

/-! ## Phase 2 — ⇐ completeness half: consume `kvE2_sepBody_holds_of_honest`

The reverse (mpr) direction of the k=2 gate: an honest depth-2 evaluation of `qnf` at the bracket
witness `w` (with `x < w < t` recovered from the atom layer) forces the carrier body `.holds`. This
is a **consumption** of the landed completeness engine `kvE2_sepBody_holds_of_honest`
(`SharedWitness.lean:9262`) — no new engine, no interiority hypothesis. The gate `hg` is discharged
by the landed `kvE2_sepGate_holds_of_honest` (`SharedWitness.lean:2666`); the two char-formula
bridges `hcb`/`hck` are built from `nf_depth0_char_formula_correct` (KampTranslation:141) and
`P.correct` (the `ExistProviders` correctness field) with the `Fin 0` env collapse. -/

/-- **⇐ completeness bridge for the char-base layer**: the standard-instantiation
    depth-0 characteristic formula is truth-equivalent to the arity-1 evaluation. Extracted from the
    landed `nf_char2_atom_layer` proof (`Base.lean:58`), specialized to the plain arity-1 iff. -/
theorem bracketEndChar_kvE2_hcb {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (χ : NormalForm sig 0 1) (u : M.carrier) :
    TemporalTruth M atomMap u (nfDepth0CharFormula atomMap h_surj χ) ↔
      NfEvalNf M 0 1 (fun _ => u) χ := by
  rw [Separation.nf_depth0_char_formula_correct]
  simp only [NfEvalNf]
  constructor
  · intro h a
    obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred a
    simp only [AtomEval]
    exact h p
  · intro h p
    have hp := h (.pred p ⟨0, by omega⟩)
    simpa only [AtomEval] using hp

/-- **⇐ completeness bridge for the provider layer**: the depth-1 existential
    provider formula `P.existF 0 χ` is truth-equivalent to the arity-1 depth-1 evaluation, via the
    `ExistProviders.correct` field at `n = 0` and the `Fin 0 → M.carrier` env collapse
    (`insertEnv` on the empty env is `fun _ => u`). -/
theorem bracketEndChar_kvE2_hck {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (P : ExistProviders sig atomMap 1)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (χ : NormalForm sig 1 1) (u : M.carrier) :
    TemporalTruth M atomMap u (P.existF 0 χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ := by
  rw [P.correct 0 χ M h_UZ h_SZ u]
  constructor
  · rintro ⟨env, henv⟩
    have heq : insertEnv env u = (fun _ => u) := by
      funext i
      simp only [insertEnv]
      rw [dif_neg (by omega)]
    rwa [heq] at henv
  · intro h
    exact ⟨Fin.elim0, by rw [insertEnv_zero]; exact h⟩

/-- **⇐ completeness half of the k=2 gate** (UNCONDITIONAL — no `hL`/`hLR`).
    An honest depth-2 evaluation at bracket witness `w` forces the carrier body `.holds`, by
    consuming the landed completeness engine `kvE2_sepBody_holds_of_honest` (SW:9262). The order
    hypotheses are the standard six `BracketCarrierCorrectVPrior` atom-layer conditions; `w`'s
    interval position `x < w < t` is recovered from `qnf`'s own atom layer under those hypotheses
    (bracket range, NOT a chain — LITMUS-clean). -/
theorem bracketEndChar_kvE2_complete_two_prior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (_h_xt : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (_h_yx : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (_h_ty : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (_h_tx : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier) :
    (∃ w : M.carrier, NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) →
      (bracketEndCharKvE2 atomMap h_surj P qnf).holds M atomMap x t := by
  rintro ⟨w, h⟩
  -- Recover `x < w` and `w < t` from `qnf`'s atom layer (env `[w, x, t]`).
  have hxw : x < w := by
    have := (h.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h_xy
    exact this
  have hwt : w < t := by
    have := (h.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mpr h_yt
    exact this
  -- Gate from the landed honest-gate lemma.
  have hg : KvE2SepGate qnf := kvE2_sepGate_holds_of_honest qnf M w x t hxw hwt h
  -- Land on the live carrier and apply the completeness engine.
  rw [bracketEndChar_kvE2_two_eq]
  exact kvE2_sepBody_holds_of_honest (nfDepth0CharFormula atomMap h_surj)
    (fun χ => P.existF 0 χ) qnf hg M atomMap w x t hxw hwt h
    (fun χ u => bracketEndChar_kvE2_hcb atomMap h_surj M χ u)
    (fun χ u => bracketEndChar_kvE2_hck atomMap P M h_UZ h_SZ χ u)

/-! ## Phase A — single-positive-sub fragment predicate + `_frag` statement surgery

The plan-v4 unconditional four-family discharge is REFUTED (report 04): over an arbitrary `qnf`
the fold's FORWARD gate conjunct `(∃ v, zoneHolds … zs v ∧ nf_eval χ) → σ.2 (nf0Assemble zs χ σ.1)
= true` is false in a rich model (`σ.2` need not mark every realizable `(zs, χ)`). The fragment
verdict
N2 re-scopes the 309 Phase 13.4 / `KampPrior.lean:351` deliverable to the **single-positive-sub
fragment**, where the O4 CRUX RECORD (`SharedWitness.lean:6785-6791`) states the cross-σ residue
VANISHES: with one interior positive there are no cross-σ slot points, so every witness is σ0's own
bit-true 1-type or a literal/segment-covered self-zone point.

`KvE2SepFragment qnf` is a pure `qnf`-domain restriction (positivity + interior zone of the sole
positive sub); it depends ONLY on `qnf`, never on `M`/`atomMap`/`P`/a realized type. It is the sole
sanctioned hypothesis beyond the provider shape — NOT a provider-conditional family. -/

/-- **Single-positive-sub fragment predicate**. `qnf`'s positive-sub list is
    exactly the singleton `[σ0]` and `σ0` is interior-zoned (`x < x1 < w` or `w < x1 < t`). This is
    the qnf-domain narrowing the fragment verdict N2 sanctions: it collapses the fold's four
    provider-conditional families to the residue-vanish case (O4 record SW:6785-6791). Depends only
    on `qnf` (its positivity + zone structure), never on a model or provider.

    NON-VACUITY NOTE (2026-07-11 — REPAIRED & REALIZABLE): the earlier VACUITY
    NOTE flagged the GLOBAL singleton demand (`kvE2SepPos qnf = [σ0]`) as unrealizable —
    `nf_exists_unique` (NormalForm.lean:276) forces ≥3 positive bits on every realized `qnf` (335
    report 07 Refutation 1). The interior-restriction repair SWAPPED the carrier list to the
    INTERIOR-restricted
    singleton `kvE2SepPosI` (SW:211, above; the at-point positives zAtX/zAtW/zAtT are excluded by
    the interior filter), and Phase 2 proved the swapped predicate REALIZABLE:
    `kvE2_sepFragment_realizable` (`SharedWitness.lean:10265`) exhibits a concrete `qnf` satisfying
    `KvE2SepFragmentFrag qnf` (byte-identical body via the `rfl` defeq bridge below). This
    predicate
    is therefore satisfiable and safe to build on; the fold `kvE2_outer_fold_frag` (SW:12627) and
    its
    soundness half below are non-vacuous. -/
def KvE2SepFragment {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : Prop :=
  ∃ σ0 : NormalForm sig 1 4,
    kvE2SepPosI qnf = [σ0] ∧
    (nf0ZoneSpec σ0.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ0.1 = kvE2SepZWT3)

/-! ## Phase B — ⇒ soundness half over the pin-anchored fold `kvE2_outer_fold_frag`

The symmetric gate landed (Rabinovich Cor 5.4, clause (v)): the RIGHT inner-consistency is
now a gate consequence, so the former `hInnerR` obligation is dissolved, and the pin-anchored fold
`kvE2_outer_fold_frag` (`SharedWitness.lean:12529`) takes only `hfrag` + `hcorrK` +
`hexcl` beyond the provider shape. This SUPERSEDES the pre-345 four-family blocker: the interior
gates `hgateL`/`hgateR` and the non-interior `hbdry` are now internal to the fold — discharged
inside
`kvE2_sepBody_kit_sound_frag` (SW:12487) under `hfrag`, where the sole interior positive `σ0`
collapses the non-interior class (O4 SW:6785-6791) and each LEFT/RIGHT branch is served by the
pin-anchored gate producers `kvE2_sepGateAtPin_fragL`/`_fragR`.

What remains for 335 to discharge at `charK := fun χ => P.existF 0 χ`:
- `hcorrK` — the provider correctness bridge `(⟨charK (nfkProjFresh σ)⟩).EvalAt M atomMap a →
  NfEvalNf M 1 1 (fun _ => a) (nfkProjFresh σ)`. Discharged HERE inline from the Phase-2 provider
  bridge `bracketEndChar_kvE2_hck` (`.mp`; `TemporalPred.EvalAt` unfolds to `TemporalTruth`).
- `hexcl` — the cone-restricted (`x ≤ x1 ≤ t`) negative-sub exclusion. Threaded as a named
  provider hypothesis through the assembled Phase-D gate (discharged by the 309 Phase-14
  provider); the exterior-marked residue `hexclExt` is the exterior-reflatten hand-off, per the
  Phase C
  v6 disposition (interior slice landed upstream by 347 R1, SW:12627).

The fragment hypothesis `hfrag : KvE2SepFragment qnf` is definitionally the fold's
`KvE2SepFragmentFrag qnf` (identical body, SW:10219); the six order bits unify defeq
`qnf.atomAssgn = qnf.1` at depth 2 (`NormalForm.atomAssgn` `_ + 1` case). No `SharedWitness.lean`
edit — the fold and its kit are verified INPUTS, applied not re-proved (341 frozen-file gate
intact).
Rabinovich cited by PDF page: the symmetric gate is Cor 5.4; the depth-2 assembly follows
Def 3.1 (p.4) and the §5 bracket assembly (pp.7-9). -/

/-- **⇒ soundness half of the k=2 fragment gate** (interior-singleton restatement).
    Consumes the pin-anchored symmetric-gate fold `kvE2_outer_fold_frag` (SW:12627). Under the
    interior-singleton repair the fold no longer threads `hfrag`/`hcorrK`: provider correctness now
    lives inside the per-positive realization channel `hreal`, and the negative-sub exclusion is
    SPLIT
    into the cone-restricted `hexcl` (`x ≤ x1 ≤ t`, dischargeable) plus the strictly-exterior
    residue
    `hexclExt` (the deferred Prop-4.3 obligation). `hfrag : KvE2SepFragment qnf` is retained as the
    fragment-scope premise (the non-vacuity anchor), no longer destructured by the body.

    NON-VACUITY NOTE (2026-07-11 — VACUITY RESOLVED): the earlier VACUITY NOTE
    flagged the GLOBAL-singleton fragment predicate (`kvE2SepPos qnf = [σ0]`) as unrealizable,
    making
    this theorem's premise set unsatisfiable and the theorem vacuous AS STATED. The
    interior-singleton fix
    re-shaped `KvE2SepFragment` to the INTERIOR-singleton predicate (`kvE2SepPosI qnf = [σ0]`,
    OuterGate:200) and Phase 2 proved it realizable: `kvE2_sepFragment_realizable`
    (`SharedWitness.lean:10265`) exhibits a concrete `qnf : NormalForm sig 2 3` with
    `KvE2SepFragmentFrag qnf` — byte-identical to `KvE2SepFragment` via the `rfl` defeq bridge
    (OuterGate:223-224). The `hfrag` premise is therefore SATISFIABLE and this theorem is
    NON-VACUOUS.
    The exclusion obligation is honestly scoped: `hexcl` (cone) is dischargeable now, while
    `hexclExt`
    (strictly-exterior) is the isolated, NAMED residue carried by the caller. The exterior-marked
    narrowing (report 01
    §7) NARROWS `hexclExt` to EXTERIOR-MARKED σ only: the interior-marked slice (`zXW3`/`zWT3`) of
    the
    strictly-exterior case is discharged in-line by the fold via the Phase-1 order-atom lemma
    `kvE2_sepInterior_exterior_notRealizable`, so the deferred residue is the exterior-ARRANGEMENT
    obligation only — its faithful mechanism is the Prop-4.3 re-flatten / Lemma 7.6 adjacency
    successor
    (NOT exterior-exclusion on this bracket; that framing is retired). No sorry on any live path —
    the
    exterior-arrangement gap is quarantined by the narrowed `hexclExt` binder, not a sorry.
    Consumers
    (the KampPrior provider instantiation at `KampPrior.lean:351`, and the Phase-D assembly) supply
    the cone `hexcl` + `hreal`
    and carry the narrowed `hexclExt` as the successor obligation. -/
theorem bracketEndChar_kvE2_sound_two_prior_frag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (_hfrag : KvE2SepFragment qnf)
    -- Phase-D re-shape (interior index): the INTERIOR provider realization
    -- obligation, indexed by `kvE2SepPosI` (SW:211) and interval-BOUNDED `x < x1 < t` —
    -- Rabinovich Cor 5.4 ⇐ (p.9 l.263-273): interior witnesses are bounded `(∃z)^{<z1}_{>z0}`,
    -- never unbounded over the carrier. For the n=1 fragment singleton the joint-order coupling
    -- is vacuous; the shape is recorded interval-bounded so the exterior-reflatten / the `On` lift
    -- consume it
    -- unchanged. This is what the 309 Phase-14 provider discharges.
    (hrealI : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPosI qnf,
        ∃ x1 : M.carrier, (x < x1 ∧ x1 < t) ∧
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- Phase-D remainder: the NON-interior-marked remainder of `kvE2SepPos` (the boundary/at-point
    -- positives `nf_exists_unique` forces, realized AT the anchors by the consumer's endpoint/
    -- pivot literals; plus any exterior-marked positive, whose witness belongs to the
    -- exterior-reflatten's
    -- adjacent brackets). Kept in the landed unbounded fold shape — the interval bound applies
    -- ONLY to the interior index (347 MUST-CHECK 2), never to the boundary remainder.
    (hrealB : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPos qnf,
        ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
        ∃ x1 : M.carrier,
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvE2 atomMap h_surj P qnf).holds M atomMap x t →
      ∃ w : M.carrier, NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  intro h_holds
  rw [bracketEndChar_kvE2_two_eq] at h_holds
  refine kvE2_outer_fold_frag atomMap h_surj (fun χ => P.existF 0 χ) qnf
    h_xy h_yt h_xt h_yx h_ty h_tx M x t h_holds ?_ hexcl hexclExt
  -- Reassemble the fold's global realization channel from the Phase-D split: an interior-marked
  -- positive rides `hrealI` (dropping the interval bound, which the fold does not consume); a
  -- non-interior-marked positive rides `hrealB`. The interiority disjunction is decidable (it is
  -- `kvE2SepPosI`'s own filter condition), and membership transfers via `kvE2_sepPosI_mem`.
  intro w hxw hwt hptW σ hσ
  by_cases hz : nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3
  · obtain ⟨x1, -, hx1⟩ :=
      hrealI w hxw hwt hptW σ ((kvE2_sepPosI_mem qnf σ).mpr ⟨hσ, hz⟩)
    exact ⟨x1, hx1⟩
  · exact hrealB w hxw hwt hptW σ hσ hz

/-! ## Phase D — assembled interior+boundary gate over the `kvE2SepPosI` provider obligation

The fragment-restricted, interior+boundary-scoped instance of the `BracketCarrierCorrectVPrior`
body (`PriorInterface.lean:60`), mirroring the k ≤ 1 assembly `bracketEndChar_kv_correct_one_prior`
(`PriorInterface.lean:95`): the ⇒ direction is the Phase-B/D soundness half over the pin-anchored
fold; the ⇐ direction is the Phase-2 completeness half, UNCONDITIONAL (the fragment/interior
restriction gates only ⇒). Provider conditionality enters exactly as the named hypotheses
`hrealI`/`hrealB`/`hexcl` (discharged by the Phase-14 provider) and `hexclExt` (the
`prop43_exterior_reflatten` hand-off) — the A1 sense recorded at the fold (SW:10033-10037). -/

/-- **Assembled k=2 interior+boundary gate**.
    Fragment-restricted (`hfrag`), interior+boundary-scoped `holds ↔ ∃ w` correctness for the live
    outer gate `bracketEndCharKvE2`, with the provider realization obligation RE-SHAPED to the
    interior index: `hrealI` ranges over `kvE2SepPosI qnf` (SW:211) with the interval bound
    `x < x1 < t` — Rabinovich Cor 5.4 ⇐ (p.9 l.263-273), bounded jointly-ordered interior
    witnesses, NOT the retired global/unbounded `kvE2SepPos` shape (the phantom obligation
    globalized past the bracket; 347 MUST-CHECK 2). `hrealB` carries the non-interior-marked
    positive remainder (boundary/at-point positives realized at the anchors); `hexcl` is the
    interior+boundary cone exclusion; `hexclExt` is the exterior-marked residue threaded OUTWARD
    verbatim as the exterior-reflatten provider hand-off (Prop 4.3 re-flatten / Lemma 7.6 adjacency
    —
    adjacent exterior brackets composed at the anchors, NEVER discharged on this bracket).
    Mirrors `bracketEndChar_kv_correct_one_prior` (PriorInterface.lean:95). Consumed by the
    KampPrior provider
    instantiation at `KampPrior.lean:351` under `KvE2SepFragment qnf`. -/
theorem bracketEndChar_kvE2_correct_two_prior_frag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier)
    (hfrag : KvE2SepFragment qnf)
    (hrealI : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPosI qnf,
        ∃ x1 : M.carrier, (x < x1 ∧ x1 < t) ∧
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hrealB : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPos qnf,
        ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
        ∃ x1 : M.carrier,
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvE2 atomMap h_surj P qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  constructor
  · exact bracketEndChar_kvE2_sound_two_prior_frag atomMap h_surj P qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hfrag hrealI hrealB hexcl hexclExt
  · exact bracketEndChar_kvE2_complete_two_prior atomMap h_surj P qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t

end FormalSystem.Metalogic.WeakCanonical.Kamp
