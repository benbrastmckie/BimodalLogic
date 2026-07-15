import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior

/-!
# Crux A — the interior `hreal` supply (task 358 Phase 5)

This leaf hosts `kampPrior_hreal_supply`, the general-`m` discharge of the ROW-5 `hreal`
obligation carried by `kampPrior_site_rungK_gate_match` (`KampPrior.lean:964-970`) and its
`EndIntervalConsumerK` mirror. It is the deep `⇐` direction of the deep ambient render and the
ROOT of the crux-first DAG (v09 plan Phase 5).

## Directional discipline (why the render is NOT a hypothesis here)

`hreal` is UPSTREAM of the render: `ExteriorGateAssembleK.lean:337-338` produces
`∃ w, nf_eval_nf M (k+2) 3 [w,x,t] qnf` via `bracketEndChar_kv_step_sound … (hreal hGuard)
(hexcl hGuard)`. So `hreal` must be produced by the model engine BEFORE the render exists —
it may NOT take `nf_eval_nf M (k+2) 3 [w,x,t] qnf` as a premise (that would be circular). This
distinguishes Crux A from the LANDED slice supplies `kvE_hsliceFut_supply` /
`kvE_hslicePast_supply` (`ExteriorDeepSliceSupplyK.lean:131/161`), which are DOWNSTREAM of the
render and take it as an explicit hypothesis.

## Signature shape (row-5 binder, verbatim conclusion)

The conclusion chain matches the row-5 binder byte-for-byte (leading
`kvE_ambientDeepAnchor qnf = true →`, per-`w` `igPtW`-gated, per-`σ` marked + fiber-consistent).
The ambient premises `P`/`h_UZ`/`h_SZ`/`charF` are the engine seam the drivers
(`kampPrior_{fut,past}Realizer_of_pos`, `KampPrior.lean:1662/1721`) consume; `P` bundles the
depth-`k` realization recursion IH via `kampPrior_existProviders_of_ih`. Rows 5-6 signatures are
NOT changed (they are the PRODUCERS); the consumer-side seam that supplies `P`/`h_UZ`/`h_SZ` at
the row-5 site is the Phase-7 binder retrofit, out of scope here.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula)

set_option maxHeartbeats 1600000 in
/-- **Crux A — interior `hreal` supply** (task 358 Phase 5, the deep `⇐` witness selection).
    Discharges the row-5 `hreal` binder of `kampPrior_site_rungK_gate_match`: under the ambient
    deep-anchor guard, for every `igPtW`-selected interior `w` and every `qnf`-marked
    fiber-consistent `σ`, a within-model realizer `x1` with
    `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` exists.

    **Route** (Rabinovich 2014 Cor 5.4(1)⇐): the marked fiber-consistent `σ` fires the positive
    local-existence form `kvE_futPos`/`kvE_pastPos` at the endpoints from the fold content
    `igFoldBit qnf` (global, ALL zones — not only the `igZAtW` slot `igPtW`-at-`w` exposes),
    then the landed drivers `kampPrior_{fut,past}Realizer_of_pos` (exterior zone) /
    `kampPrior_fChain_realize_bracket` (interior zone) select `x1` and fold up the genuine
    realizer, the transfer inputs closing by the depth-`k` recursion IH bundled in `P`.

    **STATUS (task 358 Phase 5, this dispatch): PARTIAL — statement landed, body is a tracked
    strategic sorry.** The intended firing route is machine-confirmed CIRCULAR: the only
    fold-bit → model-realizer bridge, `igFoldBit_realize_iff` (InteriorGateGeneralK.lean:563),
    consumes the deep ambient render that this obligation is upstream of (produced at
    `ExteriorGateAssembleK.lean:337-338`). See the in-body sorry note for the full diagnosis and
    the two sub-obstructions. The signature is nonetheless correct and citeable (rows 12-13
    exclusion supplies and Crux B may name it); closing it requires a firing transducer that does
    NOT route through the render (follow-up below). -/
theorem kampPrior_hreal_supply {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (x t : M.carrier) :
    kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1
        (igFoldBit qnf)).eval_at M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        kvE_fiberConsistent σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro hAmb w hxw hwt hptW σ hmark hcons
  -- STRATEGIC SORRY (task 358 Phase 5, the crux root — the deep ⇐ witness selection).
  --
  -- The genuine model-carrier realizer must come from the landed engine drivers
  --   `kampPrior_futRealizer_of_pos` (KampPrior.lean:1662, exterior zone `t < x1`),
  --   `kampPrior_pastRealizer_of_pos` (:1721, exterior zone `x1 < x`),
  --   `kampPrior_fChain_realize_bracket` (:1549, interior zone `x < x1 < t`).
  -- Each driver requires (i) a per-σ positive firing `temporal_truth M atomMap {t|x}
  -- (kvE_{fut,past}Pos P σ)` and (ii) forward realizability + backward saturation of σ's
  -- depth-k fiber at the SELECTED anchor. Two irreducible sub-obstructions remain, both
  -- machine-confirmed this dispatch:
  --
  --   (a) FIRING IS CIRCULAR (machine-confirmed root obstruction). The ONLY bridge turning
  --       fold content `igFoldBit qnf zs χ = true` into a model realizer is
  --       `igFoldBit_realize_iff` (InteriorGateGeneralK.lean:563-567) — and it REQUIRES the
  --       render `nf_eval_nf M (k+1) 3 [w,x,t] qnf` as an explicit hypothesis `h`. For this
  --       `qnf : NormalForm sig (k+2) 3` that hypothesis is `nf_eval_nf M (k+2) 3 [w,x,t] qnf`,
  --       i.e. EXACTLY the deep ambient render that `hreal` (this lemma, with `hexcl`) PRODUCES
  --       downstream at `ExteriorGateAssembleK.lean:337-338`. So firing the drivers from the
  --       fold bit consumes the very render this obligation is upstream of — circular.
  --       The row-5 binder exposes only `(igPtW … (igFoldBit qnf)).eval_at M w` (igPtW def
  --       InteriorGateGeneralK.lean:243), pinning w's y-type + the `igZAtW`-zone content only;
  --       the fut-T / past-X endpoint firings the exterior drivers consume (`igEpR`@t /
  --       `igEpL`@x) are ABSENT from this binder, and the guard readback
  --       `kvE_ambientDeepAnchor_iff` (ExteriorAmbientDeepAnchorK.lean:131) yields only a
  --       syntactic EF-closure with NO model carrier.
  --
  --   (b) IH TRANSFER. Even granting a firing, the drivers' forward-realizability input is
  --       `∀ x1 (zone) ∀ s bit-true, ∃ v, nf_eval_nf M k 5 [v,x1,w,x,t] s` — a GLOBAL
  --       (all-anchor) depth-k realizability fact. Deriving it pointwise from `P.correct` +
  --       `hcons` again routes through `igFoldBit_realize_iff`'s render hypothesis (same
  --       circularity).
  --
  -- `hcons` (kvE_fiberConsistent σ = true) is the task-363 antecedent that excludes the
  -- projection-invisible doppelgänger fakes (ExteriorPinnedProbeM1K.lean:628-669) — the guard
  -- that makes a TRUE supply possible; it is threaded here for the eventual discharge.
  --
  -- follow-up: task 358 Phase 5 continuation — build the `igFoldBit → kvE_{fut,past}Pos`
  -- firing transducer and the depth-k IH → pointwise-realizer bridge, then wire the drivers
  -- under the two-zone split (5.1 exterior / 5.2 interior).
  sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
