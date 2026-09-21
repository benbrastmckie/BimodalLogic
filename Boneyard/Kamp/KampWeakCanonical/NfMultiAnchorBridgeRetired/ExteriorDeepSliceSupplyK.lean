import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberDeepAnchorK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedConverseK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedConversePastK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# General-`m` rows-8-9 slice supply over the deep-anchored population

The general-`m` supply theorems for the DEEP-anchored rows 8-9 of the obligation ledger
(`_hslicePast`/`_hsliceFut`, `EndIntervalConsumerK.lean:158-171`; gate-match mirrors
`kampPrior_site_rungK_gate_match`, `KampPrior.lean:989-1002`): given σ admissible,
`kvE_deepOnFiber qnf σ = true` (the hereditary deep-anchor guard), chain firing, and
the ambient realized — exhibit a qnf-marked, admissible, slice-equal mate σ'.

## Route (the mate-collapse; the Phase-2 adjudication record,
handoffs/phase-2-v06-handoff-20260714.md)

At σ-depth ≥ 2 (`k = j + 1`), the guard's qnf-marked deep-content mate COLLAPSES to σ
itself — the very mechanism `kvE_probe367_copyPlant_collapses` machine-validated:

1. `kvE_deepOnFiber_iff` (the ONLY sanctioned mate-reading direction) extracts a mate σ'
   with `qnf.2 σ' = true` and `σ'.2 = σ.2`.
2. The realized ambient renders σ' realized at some `x1'` over the ambient's own tail
   (`hqnf.2 σ'` — qnf's quant layer).
3. σ'.2 is NONEMPTY: the depth-`(j+1)` characteristic of any inner point over the realizer
   tuple is a marked fiber element (`nf_characteristic_satisfies` + the realizer's quant
   layer).
4. That common marked element pins BOTH atom rows: `kvE_futAdmissible_onFiber` (admissibility
   conjunct-2 read — never unfolding the guard) pins `σ.1`; `kvE_fiber_dropFresh` (the
   realized σ''s off-fiber clause) pins `σ'.1`. Hence `σ'.1 = σ.1`.
5. `NormalForm sig (k+1) 4` is a product: with `σ'.2 = σ.2`, σ' = σ. The mate IS σ;
   `qnf.2 σ = true`; conclude with σ itself and slice-equality by reflexivity.

At σ-depth 1 (`k = 0`, the m = 0 binder instance) the guard is DEFINITIONALLY the depth-0 row
check (`kvE_deepOnFiber_zero` — the sanctioned m = 0 adapter, never unfolding the guard), and
the FROZEN supply (`kvE_hsliceFut_supply_zero` / `kvE_hslicePast_supply_zero`)
discharges verbatim.

## Countermodel-family adjudication (re-probe discipline)

- The all-honest tail-doppelgänger (`kvE_probe358_tailDG_*`) and its depth-2 hereditary
  variant are guard-REJECTED (`kvE_probe367_tailDG_deep_rejected`,
  `kvE_probe367_depth2DG_deep_rejected`) — they fail this theorem's `kvE_deepOnFiber`
  antecedent and are OUTSIDE the population; nothing here readmits them.
- The content-copying plant collapses to the honest slice
  (`kvE_probe367_copyPlant_collapses`) — this theorem's step 4-5 is precisely that collapse,
  now in the honest direction.
- The 364 plant family (`kvE_probe364_*`) is excluded by the admissibility antecedent
  (fiber-consistency lives inside `kvE_futAdmissible` conjunct 2), unchanged.

## Routing compliance

Guard consumption ONLY via `kvE_deepOnFiber_iff` / `kvE_deepOnFiber_zero`; admissibility read
ONLY via `kvE_futAdmissible_onFiber` / `kvE_pastAdmissible_onFiber`; no `rw`/`unfold`/
`simp only` on any guard body. -/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Slice-equality reflexivity (both sides) -/

/-- `kvE_futSliceEq` is reflexive: every σ is slice-equal to itself. -/
theorem kvE_futSliceEq_refl {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) : kvE_futSliceEq σ σ = true := by
  rw [kvE_futSliceEq, decide_eq_true (rfl : σ.1 = σ.1),
    decide_eq_true (rfl : kvE_fiberZoneList σ kvE_futGapZone = kvE_fiberZoneList σ kvE_futGapZone),
    decide_eq_true (rfl : kvE_fiberZoneList σ kvE_futRayZone = kvE_fiberZoneList σ kvE_futRayZone),
    decide_eq_true (rfl : kvE_fiberZoneList σ kvE_futSelfZone = kvE_fiberZoneList σ kvE_futSelfZone)]
  rfl

/-- `kvE_pastSliceEq` is reflexive: every σ is slice-equal to itself. -/
theorem kvE_pastSliceEq_refl {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) : kvE_pastSliceEq σ σ = true := by
  rw [kvE_pastSliceEq, decide_eq_true (rfl : σ.1 = σ.1),
    decide_eq_true (rfl : kvE_fiberZoneList σ kvE_pastGapZone = kvE_fiberZoneList σ kvE_pastGapZone),
    decide_eq_true (rfl : kvE_fiberZoneList σ kvE_pastRayZone = kvE_fiberZoneList σ kvE_pastRayZone),
    decide_eq_true (rfl : kvE_fiberZoneList σ kvE_pastSelfZone = kvE_fiberZoneList σ kvE_pastSelfZone)]
  rfl

/-! ## The mate-collapse kernel (side-shared)

The deep-anchor guard's qnf-marked mate, over a REALIZED ambient and for an ADMISSIBLE-side
σ whose marked subs are pinned to `σ.1`'s fiber, IS σ itself. Stated side-generically through
the on-fiber hypothesis so both `kvE_futAdmissible_onFiber` and `kvE_pastAdmissible_onFiber`
instantiate it. -/

/-- **Mate-collapse kernel**: at σ-depth ≥ 2, over a realized ambient, any deep-content mate
    σ' of an on-fiber-disciplined σ equals σ — so σ itself is qnf-marked. The
    `kvE_probe367_copyPlant_collapses` mechanism in the honest direction. -/
theorem kvE_deepMate_collapse {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {j : Nat}
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig (j + 3) 3)
    (w x t : M.carrier)
    (hqnf : nf_eval_nf M (j + 3) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig (j + 2) 4)
    (honFiber : ∀ s : NormalForm sig (j + 1) 5, σ.2 s = true → nfk_dropFresh s = σ.1)
    (hguard : kvE_deepOnFiber qnf σ = true) :
    qnf.2 σ = true := by
  -- 1. extract the qnf-marked deep-content mate (sanctioned reading direction)
  obtain ⟨-, σ', hmk, h2eq⟩ := (kvE_deepOnFiber_iff qnf σ).mp hguard
  -- 2. the realized ambient realizes the mate at some x1' over its own tail
  obtain ⟨x1', hσ'⟩ := (hqnf.2 σ').mpr hmk
  -- 3. σ'.2 is nonempty: the characteristic of an inner point is a marked fiber element
  have hs0 : σ'.2 (nf_characteristic M (j + 1) 5
      (Fin.cons x1' (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))))) = true :=
    (hσ'.2 _).mp ⟨x1', nf_characteristic_satisfies M (j + 1) 5 _⟩
  -- 4. the common marked element pins both atom rows
  have hbitσ : σ.2 (nf_characteristic M (j + 1) 5
      (Fin.cons x1' (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))))) = true := by
    rw [← h2eq]; exact hs0
  have hfibσ : nfk_dropFresh (nf_characteristic M (j + 1) 5
      (Fin.cons x1' (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))))) = σ.1 :=
    honFiber _ hbitσ
  have hfibσ' : nfk_dropFresh (nf_characteristic M (j + 1) 5
      (Fin.cons x1' (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))))) = σ'.1 :=
    kvE_fiber_dropFresh M _ σ' hσ' _ ((kvE_fiber_mem σ' _).mpr hs0)
  -- 5. product extensionality: the mate IS σ
  have hcollapse : σ' = σ := Prod.ext (hfibσ'.symm.trans hfibσ) h2eq
  rw [← hcollapse]
  exact hmk

/-! ## Rows 8-9 general-`m` supplies -/

/-- **General-`m` supply for the carried `hsliceFut` obligation** (row 9 of the 13-row
    ledger; DEEP-anchored binder shape verbatim, `EndIntervalConsumerK.lean:165-171` /
    `kampPrior_site_rungK_gate_match` at generic depth). At `k = 0` the guard is the depth-0
    row check (`kvE_deepOnFiber_zero`) and the FROZEN `_zero` supply discharges; at
    `k = j + 1` the guard's own qnf-marked mate collapses to σ itself
    (`kvE_deepMate_collapse` — on-fiber discipline from `kvE_futAdmissible_onFiber`),
    so σ is marked and slice-equal to itself. -/
theorem kvE_hsliceFut_supply {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} :
    ∀ (k : Nat) (P : ExistProviders sig atomMap k)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
      (qnf : NormalForm sig (k + 2) 3)
      (x t : M.carrier),
      ∀ w : M.carrier, x < w → w < t →
        nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
        ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true →
          kvE_deepOnFiber qnf σ = true →
          temporal_truth M atomMap t (kvE_futPos P σ) →
          ∃ σ' : NormalForm sig (k + 1) 4, kvE_futAdmissible σ' = true ∧
            kvE_futSliceEq σ' σ = true ∧ qnf.2 σ' = true
  | 0, P, M, h_UZ, h_SZ, qnf, x, t => by
      -- m = 0: the guard IS the row check; the frozen `_zero` supply discharges verbatim
      intro w hxw hwt hqnf σ hadm hguard hpos
      exact kvE_hsliceFut_supply_zero P M h_UZ h_SZ qnf x t w hxw hwt hqnf σ hadm
        (of_decide_eq_true ((kvE_deepOnFiber_zero qnf σ).symm.trans hguard)) hpos
  | (j + 1), _P, M, _h_UZ, _h_SZ, qnf, x, t => by
      -- σ-depth ≥ 2: the deep mate collapses to σ itself
      intro w hxw hwt hqnf σ hadm hguard _hpos
      exact ⟨σ, hadm, kvE_futSliceEq_refl σ,
        kvE_deepMate_collapse M qnf w x t hqnf σ
          (fun s hs => kvE_futAdmissible_onFiber σ hadm s hs) hguard⟩

/-- **General-`m` supply for the carried `hslicePast` obligation** (row 8; Past mirror of
    `kvE_hsliceFut_supply`, binder shape verbatim from `EndIntervalConsumerK.lean:158-164`).
    Same two-arm route: the frozen `_zero` supply through the `kvE_deepOnFiber_zero`
    adapter at `k = 0`; mate-collapse via `kvE_pastAdmissible_onFiber` at `k = j + 1`. -/
theorem kvE_hslicePast_supply {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} :
    ∀ (k : Nat) (P : ExistProviders sig atomMap k)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
      (qnf : NormalForm sig (k + 2) 3)
      (x t : M.carrier),
      ∀ w : M.carrier, x < w → w < t →
        nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
        ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true →
          kvE_deepOnFiber qnf σ = true →
          temporal_truth M atomMap x (kvE_pastPos P σ) →
          ∃ σ' : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ' = true ∧
            kvE_pastSliceEq σ' σ = true ∧ qnf.2 σ' = true
  | 0, P, M, h_UZ, h_SZ, qnf, x, t => by
      intro w hxw hwt hqnf σ hadm hguard hpos
      exact kvE_hslicePast_supply_zero P M h_UZ h_SZ qnf x t w hxw hwt hqnf σ hadm
        (of_decide_eq_true ((kvE_deepOnFiber_zero qnf σ).symm.trans hguard)) hpos
  | (j + 1), _P, M, _h_UZ, _h_SZ, qnf, x, t => by
      intro w hxw hwt hqnf σ hadm hguard _hpos
      exact ⟨σ, hadm, kvE_pastSliceEq_refl σ,
        kvE_deepMate_collapse M qnf w x t hqnf σ
          (fun s hs => kvE_pastAdmissible_onFiber σ hadm s hs) hguard⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
