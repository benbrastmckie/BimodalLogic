/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK

/-! # Obligation-carrying EndInterval consumer reshape

The obligation-carrying reshape of the interval consumer. It replaces the unconditional
`EndIntervalCorrect` (`CarrierK1V.lean:2179`, on a dead branch — nothing external consumed it) with
a
depth-cased, obligation-carrying `EndIntervalCorrectPrior`, and fills the recursion step (the
`⟨[]⟩` empty-disjunction placeholder `endIntervalStep`, `CarrierK1V.lean:2144`) with a depth-cased
body built from the two landed discharge lemmas `bracketEndChar_kv_correct_prior`
(`InteriorGateGeneralK.lean`) and `bracketEndChar_kvExt_correct_prior`
(`ExteriorGateAssembleK.lean`).

**Why a new leaf module (Phase 1 cycle decision).** The reshaped step body uses `bracketEndChar_kv`
(`CarrierKv.lean`) and `bracketEndChar_kvExt` (`ExteriorGateAssembleK.lean`), both of which sit
BELOW
`CarrierK1V` in the import order (they transitively import `CarrierK1V`, since
`BracketEndCharCarrierV`
is defined at `CarrierK1V.lean:365`). Filling `endIntervalStep` in place would invert the
`CarrierK1V ↔ ExteriorGateAssembleK` import edge (a cycle). The pre-planned contingency (research
§9.1, plan Risk table) relocates the reshaped defs to this new leaf below `ExteriorGateAssembleK`.

**Depth-casing (step maps `k → k+1`).**
- depth 0 (base): `VVecEA2.singleton (bracketEndChar_k0 …)` — the k=0 two-endpoint bracket carrier.
- depth 1 (`k=0` step): interior-only rung `bracketEndChar_kv atomMap h_surj charF 1` — no exterior
  residue (base rung; depth 1 carries only the depth-0 char agreement `h0`).
- depth `m+2` (`k=m+1` step): the exterior-composed gate `bracketEndChar_kvExt atomMap h_surj charF
  (Pfam m)`, which discharges `hexclExt` internally.

**Obligation discipline (carry, do NOT discharge).** All 11 obligations of the `m+2` arm (7
interior:
`P, hcharK, h_UZ, h_SZ, hreal, hexcl` + the internalized `hexclExt`; 4 exterior SLICE-KEYED
obligations `hslice*`/`hexclSlice*` — slice-keyed replacements for the eliminated exterior
`hbr*`) are THREADED OUTWARD as hypotheses — exactly as the interior gate (`InteriorGateAllK`) and
the exterior gate
(`bracketEndChar_kvExt_correct_prior`) delivered. Actually discharging `hreal`/`hexcl` requires
the un-landed realization recursion (`KampPrior:361/364` sorries); the slice obligations are
discharged at m = 0 by the plan-v2 Phase-5 supply theorems. No `sorry`, no vacuous def is
introduced here.

## References
- Rabinovich 2014, "A Proof of Kamp's Theorem", Cor 5.4 + Lemma 7.6.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

/-! ## Phase 2 — reshaped recursion carriers (`charF` + provider family threaded) -/

/-- **Reshaped depth-`k → k+1` step** (fills the `⟨[]⟩` placeholder
    `endIntervalStep`, `CarrierK1V.lean:2144`). Depth-cased on `{k}`: `k = 0` (→ depth 1) is the
    interior-only rung `bracketEndChar_kv atomMap h_surj charF 1`; `k = m+1` (→ depth `m+2`) is the
    exterior-composed gate `bracketEndChar_kvExt atomMap h_surj charF (Pfam m)`. The
    arity-3 IH `rec` is intentionally NOT threaded (interior-gate finding: interior content is
    realized via the provider family, not the IH). The provider family `Pfam` supplies the depth-`m`
    bracket provider `Pbr := Pfam m` the exterior branch needs. -/
noncomputable def endIntervalStepPrior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pfam : (j : Nat) → ExistProviders sig atomMap j) :
    BracketEndCharCarrierV sig (k + 1) :=
  match k with
  | 0 => bracketEndCharKv atomMap h_surj charF 1
  | (m + 1) => bracketEndCharKvExt atomMap h_surj charF (Pfam m)

/-- **Reshaped recursion carrier**. `Nat.rec` with base = the depth-0 singleton
    bracket carrier (unchanged) and step = the reshaped `endIntervalStepPrior`. Reduces by `rfl`:
    `endIntervalPrior … 0 = fun qnf => VVecEA2.singleton (bracketEndChar_k0 …)`,
    `endIntervalPrior … 1 = bracketEndChar_kv atomMap h_surj charF 1`, and
    `endIntervalPrior … (m+2) = bracketEndChar_kvExt atomMap h_surj charF (Pfam m)`. -/
noncomputable def endIntervalPrior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pfam : (j : Nat) → ExistProviders sig atomMap j) :
    (k : Nat) → BracketEndCharCarrierV sig k :=
  fun k =>
    Nat.rec (motive := fun k => BracketEndCharCarrierV sig k)
      (fun qnf => VVecEA2.singleton (bracketEndCharK0 atomMap h_surj qnf))
      (fun m _rec => endIntervalStepPrior (k := m) atomMap h_surj charF Pfam)
      k

/-! ## Phase 3 — the 3-arm depth-cased obligation-carrying motive -/

/-- **Obligation-carrying correctness motive** `EndIntervalCorrectPrior`. The
    depth-cased `Prop` mirroring `InteriorGateAllK` (`InteriorGateGeneralK.lean:1239`), three arms:
    - `0`: the clean, obligation-free depth-0 biconditional (`BracketCarrierCorrectVPrior` on the
      depth-0 carrier).
    - `1`: the interior-only depth-1 biconditional, carrying only the depth-0 char agreement `h0`
      (base rung; no exterior obligation).
    - `m+2`: the full bundle — the six atom-layer order bits on `qnf.1`, the provider bundle `P` +
      agreement `hcharK`, the UZ/SZ Prior hypotheses, the fiber-consistency population
      antecedent `hfiberCons` (rows 5-6 D7 repair) with the matching per-σ consistency antecedent
      threaded into the interior realization/exclusion obligations
      `hreal`/`hexcl`, and the four SLICE-KEYED exterior obligations `hslice*`/`hexclSlice*`
      (slice-keyed, with `Pbr := Pfam m` supplied by the family). `hexclExt` is NOT an input
      binder — `bracketEndChar_kvExt_correct_prior` discharges it internally (slice-level D1/D2 +
      the carried `hexclSlice*` residue). Binder types copied verbatim from
      `ExteriorGateAssembleK.lean` at depth-index `k := m`. -/
def EndIntervalCorrectPrior {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pfam : (j : Nat) → ExistProviders sig atomMap j) :
    (k : Nat) → Prop
  | 0 => BracketCarrierCorrectVPrior atomMap (endIntervalPrior atomMap h_surj charF Pfam 0)
  | 1 => ∀ (_h0 : charF 0 = nfDepth0CharFormula atomMap h_surj),
           BracketCarrierCorrectVPrior atomMap (endIntervalPrior atomMap h_surj charF Pfam 1)
  | (m + 2) =>
      ∀ (qnf : NormalForm sig (m + 2) 3)
        (_h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
        (_h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
        (_h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
        (_h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
        (_h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
        (_h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
        (P : ExistProviders sig atomMap (m + 1))
        (_hcharK : charF (m + 1) = fun χ => P.existF 0 χ)
        (M : OrderedMonadicStructure sig)
        (_h_UZ : SemanticPriorUZ M atomMap) (_h_SZ : SemanticPriorSZ M atomMap)
        (x t : M.carrier)
        -- Interior rows-5-6 antecedent (D7 repair): the qnf population the interior
        -- supply must cover is restricted to fiber-CONSISTENT marked slices. The
        -- doppelgänger-fake ambient (`qnfG1 = m1qnf ⊕ (τ ⊕ s*)`,
        -- `kvE_probeM1_interiorHreal_NOGO`) marks an inconsistent slice, so it fails this
        -- antecedent and is OUTSIDE the obligation population — the countermodel dissolves.
        -- Honest (realized) ambients satisfy it via `kvE_fiberConsistent_of_realized`.
        -- The m = 0 layer is untouched: it discharges through the k ≤ 1 rungs, not this arm.
        (_hfiberCons : ∀ σ : NormalForm sig (m + 1) 4, qnf.2 σ = true →
          kvEFiberConsistent σ = true)
        (_hreal : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
          (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (m + 1)) qnf.1
              (igFoldBit qnf)).EvalAt
            M atomMap w →
          ∀ σ : NormalForm sig (m + 1) 4, qnf.2 σ = true →
            kvEFiberConsistent σ = true →
            ∃ x1 : M.carrier,
              NfEvalNf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
        (_hexcl : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
          (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (m + 1)) qnf.1
              (igFoldBit qnf)).EvalAt
            M atomMap w →
          ∀ σ : NormalForm sig (m + 1) 4, qnf.2 σ = false →
            kvEFiberConsistent σ = true →
            ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
              ¬ NfEvalNf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
        -- SLICE-KEYED exterior interface:
        -- binder types copied verbatim from `ExteriorGateAssembleK.lean` at depth-index
        -- `k := m`, `Pbr := Pfam m`. The four eliminated `hbr*` binders (guarded `hbr*Sat`
        -- machine-refuted, `kvE_futPinned_of_end_zero_refuted`) are replaced by carried
        -- obligations: `_hslice*` (⇐-side slice honesty, ambient-guarded; DEEP-anchored per
        -- the `kvE_deepOnFiber` guard — the antecedent `kvE_deepOnFiber qnf σ = true` REPLACES the
        -- depth-0 row
        -- `nfk_dropFresh σ = qnf.1` and mirrors the re-keyed bracket range; the 358
        -- tail-doppelgänger fails it, `kvE_probe367_tailDG_deep_rejected`; honest realized
        -- σ over the ambient's own tail pass via `kvE_deepOnFiber_of_realized`; at m = 0
        -- the guard IS the row check, `kvE_deepOnFiber_zero`) and `_hexclSlice*`
        -- (⇒-side per-σ exclusion residue for bit-false-but-slice-marked σ, `igPtW`-guarded,
        -- BYTE-STABLE). Discharged at m = 0 via
        -- `kvE_{fut,past}SliceId_of_end_zero` / `kvE_{fut,past}SliceUnique_zero` + `hreal`
        -- through the `kvE_deepOnFiber_zero` adapter (plan v2 Phase 5).
        (_hslicePast : ∀ w : M.carrier, x < w → w < t →
          NfEvalNf M (m + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
          ∀ σ : NormalForm sig (m + 1) 4, kvEPastAdmissible σ = true →
            kvEDeepOnFiber qnf σ = true →
            TemporalTruth M atomMap x (kvEPastPos (Pfam m) σ) →
            ∃ σ' : NormalForm sig (m + 1) 4, kvEPastAdmissible σ' = true ∧
              kvEPastSliceEq σ' σ = true ∧ qnf.2 σ' = true)
        (_hsliceFut : ∀ w : M.carrier, x < w → w < t →
          NfEvalNf M (m + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
          ∀ σ : NormalForm sig (m + 1) 4, kvEFutAdmissible σ = true →
            kvEDeepOnFiber qnf σ = true →
            TemporalTruth M atomMap t (kvEFutPos (Pfam m) σ) →
            ∃ σ' : NormalForm sig (m + 1) 4, kvEFutAdmissible σ' = true ∧
              kvEFutSliceEq σ' σ = true ∧ qnf.2 σ' = true)
        (_hexclSlicePast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
          (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (m + 1)) qnf.1
              (igFoldBit qnf)).EvalAt
            M atomMap w →
          ∀ σ : NormalForm sig (m + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
            kvEPastSliceMarked qnf σ = true →
            ∀ x1 : M.carrier, x1 < x →
              ¬ NfEvalNf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
        (_hexclSliceFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
          (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (m + 1)) qnf.1
              (igFoldBit qnf)).EvalAt
            M atomMap w →
          ∀ σ : NormalForm sig (m + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
            kvEFutSliceMarked qnf σ = true →
            ∀ x1 : M.carrier, t < x1 →
              ¬ NfEvalNf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
        -- DEEP-ANCHOR residue (deep-anchor re-key, rows 12-13): ⇒-side exclusion for ON-ROW
        -- guard-FALSE bit-false σ — with the deep-anchored bracket range such σ carry no
        -- clause, so D1/D2 cannot refute them. m = 0-VACUOUS (guard ≡ row check at fiber
        -- depth 1, `kvE_deepOnFiber_zero`: on-row + guard-false is contradictory);
        -- general-m discharge: the general-m realization recursion.
        (_hexclDeepPast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
          (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (m + 1)) qnf.1
              (igFoldBit qnf)).EvalAt
            M atomMap w →
          ∀ σ : NormalForm sig (m + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
            nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
            ∀ x1 : M.carrier, x1 < x →
              ¬ NfEvalNf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
        (_hexclDeepFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
          (igPtW (nfDepth0CharFormula atomMap h_surj) (charF (m + 1)) qnf.1
              (igFoldBit qnf)).EvalAt
            M atomMap w →
          ∀ σ : NormalForm sig (m + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
            nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
            ∀ x1 : M.carrier, t < x1 →
              ¬ NfEvalNf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ),
      (endIntervalPrior atomMap h_surj charF Pfam (m + 2) qnf).holds M atomMap x t ↔
        ∃ w : M.carrier, NfEvalNf M (m + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-! ## Phase 4 — the obligation-carrying consumer -/

set_option maxHeartbeats 1600000 in
-- `endInterval_step_correct` assembles `EndIntervalCorrectPrior` for every `k` by an
-- explicit three-way case split, each arm discharging a different depth rung, so the
-- default 200000-heartbeat budget is not enough.
/-- **`endInterval_step_correct` — the obligation-carrying interval consumer**.
    Assembles `EndIntervalCorrectPrior` for every `k` by cases:
    - `k = 0`: the depth-0 singleton base via `bracketEndChar_k0_correct` (reuse of the
      `endInterval_zero_correct` argument, `CarrierK1V.lean:2199`).
    - `k = 1`: the interior-only depth-1 rung `bracketEndChar_kv_correct_one_prior`
      (`PriorInterface.lean:95`), carrying only `h0`.
    - `k = m+2`: consumes the exterior-composed discharge `bracketEndChar_kvExt_correct_prior`
      (`ExteriorGateAssembleK.lean`), THREADING the 7 interior + 4 slice-keyed exterior obligations
      outward (not discharging them). `hexclExt` is discharged internally by the consumed lemma.
    Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem endInterval_step_correct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pfam : (j : Nat) → ExistProviders sig atomMap j) :
    ∀ k : Nat, EndIntervalCorrectPrior atomMap h_surj charF Pfam k
  | 0 => by
      change BracketCarrierCorrectVPrior atomMap (endIntervalPrior atomMap h_surj charF Pfam 0)
      intro qnf h_xy h_yt h_xt h_yx h_ty h_tx M _h_UZ _h_SZ x t
      change (VVecEA2.singleton (bracketEndCharK0 atomMap h_surj qnf)).holds M atomMap x t ↔ _
      rw [VVecEA2.singleton_holds]
      exact bracketEndChar_k0_correct atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t
  | 1 => by
      intro h0
      change BracketCarrierCorrectVPrior atomMap (bracketEndCharKv atomMap h_surj charF 1)
      exact bracketEndChar_kv_correct_one_prior atomMap h_surj charF h0
  | (m + 2) => by
      intro qnf h_xy h_yt h_xt h_yx h_ty h_tx P hcharK M h_UZ h_SZ x t
        hfiberCons hreal hexcl hslicePast hsliceFut hexclSlicePast hexclSliceFut
        hexclDeepPast hexclDeepFut
      change (bracketEndCharKvExt atomMap h_surj charF (Pfam m) qnf).holds M atomMap x t ↔ _
      -- Fiber-consistency reconstruction of the unrestricted interior obligations for the
      -- (unchanged)
      -- downstream discharge lemma. `hreal`: the population antecedent `hfiberCons`
      -- discharges the per-σ consistency antecedent by modus ponens. `hexcl`: for a
      -- fiber-consistent σ the restated obligation applies; an INconsistent σ can have no
      -- realization at all (`kvE_fiberConsistent_of_realized`), so the exclusion holds
      -- outright.
      exact bracketEndChar_kvExt_correct_prior atomMap h_surj charF P hcharK (Pfam m) qnf
        h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t
        (fun hAmb w hxw hwt hg σ hσ => hreal hAmb w hxw hwt hg σ hσ (hfiberCons σ hσ))
        (fun hAmb w hxw hwt hg σ hσf x1 hle1 hle2 hnf => by
          by_cases hcons : kvEFiberConsistent σ = true
          · exact hexcl hAmb w hxw hwt hg σ hσf hcons x1 hle1 hle2 hnf
          · exact hcons (kvE_fiberConsistent_of_realized M _ σ hnf))
        hslicePast hsliceFut hexclSlicePast hexclSliceFut hexclDeepPast hexclDeepFut

/-! ## DoD-name alias + recursion-reduction probes (v9 adoption) -/

/-- **`endInterval_correct` — the definition-of-done name.** One-line alias binding the
    definition-of-done name to the delivered obligation-carrying consumer
    `endInterval_step_correct`: for every `k`, the recursion carrier
    `endIntervalPrior atomMap h_surj charF Pfam` satisfies the depth-cased obligation-carrying
    correctness motive `EndIntervalCorrectPrior`. The prose heading `endInterval_correct` at
    `CarrierK1V.lean:2097` refers to this declaration's role; this is its realization on the
    LIVE (relocated-leaf) path. Cross-reference: `endInterval_step_correct` (the proof),
    `endIntervalPrior` (the carrier), `EndIntervalCorrectPrior` (the motive).
    Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem endInterval_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pfam : (j : Nat) → ExistProviders sig atomMap j) :
    ∀ k : Nat, EndIntervalCorrectPrior atomMap h_surj charF Pfam k :=
  endInterval_step_correct atomMap h_surj charF Pfam

/-! ## Obligation-disposition ledger (binding record)

The complete disposition of the 11 obligations of the `m+2` arm of `EndIntervalCorrectPrior`
(binder lines refer to this file). Obligations threaded outward are a DOCUMENTED INTERFACE with
named downstream discharge sites — never debt. Verified row-by-row against source.

| # | Obligation (binder) | Disposition | Discharge site |
|---|---------------------|-------------|----------------|
| 1 | `P : ExistProviders sig atomMap (m+1)` (:114) | hypothesis-side | provider-family
instantiation against `nf_nvar_exist_all_depths` (`KampPrior.lean`) |
| 2 | `hcharK : charF (m+1) = fun χ => P.existF 0 χ` (:115) | hypothesis-side | provider-family
instantiation (with row 1) |
| 3 | `h_UZ : semantic_prior_UZ M atomMap` (:117) | hypothesis-side | Prior-guarded by design —
`KampPrior` supplies at every consumption site |
| 4 | `h_SZ : semantic_prior_SZ M atomMap` (:117) | hypothesis-side | Prior-guarded by design (with
row 3) |
| 5 | `hreal` — interior realization, FULL arity 4, restricted to fiber-CONSISTENT marked σ |
hypothesis-side | the general-m realization recursion at the `KampPrior.lean:361/364` seam (the
in-source `:352-360` fencing note also binds the provider instantiation; the two are complementary
inputs to the same retirement) |
| 6 | `hexcl` — within-`[x,t]` exclusion, arity 4, restricted to fiber-CONSISTENT σ (inconsistent σ
are excluded outright via `kvE_fiberConsistent_of_realized`) | hypothesis-side | the general-m
realization recursion (with row 5) |
| 5a | `hfiberCons` — rows-5-6 population antecedent: every qnf-marked σ is fiber-consistent
(`kvE_fiberConsistent`) | hypothesis-side | the general-m realization recursion (honest/realized
ambients discharge it via `kvE_fiberConsistent_of_realized`; the doppelgänger fake `qnfG1` FAILS it
— the `kvE_probeM1_interiorHreal_NOGO` countermodel is outside the population) |
| 7 | `hexclExt` — exterior adjacency exclusion | **DISCHARGED INTERNALLY** by
`bracketEndChar_kvExt_correct_prior` (`ExteriorGateAssembleK.lean:180`; ⇒-side guard split →
`kvE_extBracket{Past,Fut}_sound`) | n/a — NOT a binder of `EndIntervalCorrectPrior` (verified at
the 16-argument call site, `endInterval_step_correct` m+2 arm) |
| 8 | `hslicePast` — ⇐-side slice honesty, DEEP-anchored (the `kvE_deepOnFiber` re-key:
`kvE_deepOnFiber qnf σ = true` replaces the depth-0 row antecedent) | hypothesis-side; **m = 0
DISCHARGED** by `kvE_hslicePast_supply_zero` (`ExteriorPinnedConversePastK.lean:822`) through the
`kvE_deepOnFiber_zero` adapter | general m: general-m realization recursion (re-keyed) |
| 9 | `hsliceFut` — ⇐-side slice honesty, DEEP-anchored | hypothesis-side; **m = 0 DISCHARGED** by
`kvE_hsliceFut_supply_zero` (`ExteriorPinnedConverseK.lean:1301`) through the
`kvE_deepOnFiber_zero` adapter | general m: general-m realization recursion (re-keyed) |
| 10 | `hexclSlicePast` — ⇒-side per-σ exclusion residue (BYTE-STABLE) | hypothesis-side; **m = 0
DISCHARGED** by `kvE_hexclSlicePast_supply_zero` (`ExteriorPinnedConversePastK.lean:769`) | general
m: general-m realization recursion |
| 11 | `hexclSliceFut` — ⇒-side per-σ exclusion residue (BYTE-STABLE) | hypothesis-side; **m = 0
DISCHARGED** by `kvE_hexclSliceFut_supply_zero` (`ExteriorPinnedConverseK.lean:1242`) | general m:
general-m realization recursion |
| 12 | `hexclDeepPast` — ⇒-side residue for on-row guard-FALSE bit-false σ | hypothesis-side; **m =
0 VACUOUS** (`kvE_deepOnFiber_zero`: on-row + guard-false contradictory) | general m: general-m
realization recursion |
| 13 | `hexclDeepFut` — ⇒-side residue for on-row guard-FALSE bit-false σ | hypothesis-side; **m =
0 VACUOUS** (`kvE_deepOnFiber_zero`) | general m: general-m realization recursion |

AMBIENT-GUARD ANTECEDENT (σ-independent EF-closure guard): rows 5, 6, 10, 11, 12, 13
(`hreal`/`hexcl`/`hexclSlice*`/`hexclDeep*`) each additionally carry the OUTERMOST antecedent
`kvE_ambientDeepAnchor qnf = true` — restricting the ⇒-side obligation population to
guard-passing ambients (the CM-A deep-incomplete and CM-B doppelgänger fakes FAIL the guard and
so leave the population). The guard is CARRIED by the gate formula
(`bracketEndChar_kvExt`, ambient-guard strengthened via `kvE_ambientGuardForm`), so the ⇒-side
reads `kvE_ambientDeepAnchor qnf = true` off `.holds` and the ⇐-side re-establishes it from
realization (`kvE_ambientDeepAnchor_of_realized`). ADJUDICATION: no NEW m = 0-vacuous residue
rows are required — unlike the per-σ `kvE_deepOnFiber` re-key (which split off rows 12-13), the
σ-independent ambient guard is a single added antecedent on the existing rows and is
m = 0-VACUOUS through `kvE_ambientDeepAnchor_zero` (guard ≡ `true` at m = 0, so the antecedent
is trivially dischargeable by the frozen m=0 slice supply). Rows 8-9 (`hslice*`) are
ambient-REALIZATION-guarded and BYTE-STABLE.

RETIRED interfaces (do not resurrect): the v8-era `hreal`/`hsat` EXTERIOR realization interface
and the earlier `hbr*` exterior binders (machine-refuted — `kvE_futPinned_of_end_zero_refuted`)
are RETIRED, replaced by rows 8-11 (the slice-keyed re-key). Live `hbr*` binders of the
eliminated family = 0 repo-wide (slice re-key audit criterion; docstring mentions and unrelated
pre-existing hypothesis names excluded). -/

section RecursionReductionProbes
/- Recursion-reduction verification probes (landed as documented `example`s): the three `rfl`
   reductions of `endIntervalPrior`, confirming the recursion is genuine `Nat.rec` computation
   and the dead `CarrierK1V` placeholder (`endIntervalStep`, `CarrierK1V.lean:2144`) is NOT on
   the live path. -/
variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
  (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
  (charF : (j : Nat) → NormalForm sig j 1 → Formula)
  (Pfam : (j : Nat) → ExistProviders sig atomMap j)

/-- k = 0: singleton depth-0 bracket base. -/
example : endIntervalPrior atomMap h_surj charF Pfam 0 =
    fun qnf => VVecEA2.singleton (bracketEndCharK0 atomMap h_surj qnf) := rfl

/-- k = 1: interior-only rung. -/
example : endIntervalPrior atomMap h_surj charF Pfam 1 =
    bracketEndCharKv atomMap h_surj charF 1 := rfl

/-- k = m+2: exterior-composed gate with provider `Pfam m`. -/
example (m : Nat) : endIntervalPrior atomMap h_surj charF Pfam (m + 2) =
    bracketEndCharKvExt atomMap h_surj charF (Pfam m) := rfl

end RecursionReductionProbes

end FormalSystem.Metalogic.WeakCanonical.Kamp
