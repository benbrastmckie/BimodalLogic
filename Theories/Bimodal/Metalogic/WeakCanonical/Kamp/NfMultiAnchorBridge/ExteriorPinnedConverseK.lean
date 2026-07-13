import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterK

/-! # Future pinned fiber-realization converse at m = 0 — endpoint atom-layer pinning (task 360, Phase 2)

The atom-layer half of the pinned fiber-realization converse `kvE_futPinned_of_end_zero`
(Rabinovich Cor 5.4(1) ⇐ one fiber level down, + Cor 5.4(2) re-anchoring), at fiber depth
`m := 0`. Target statement (report
`specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/03_pinned-converse-adjudication.md`
§2.4, quoted verbatim, at `m := 0` — the atom-layer half proved here is the
`nf_eval_nf M 0 4 [x1,w,x,t] σ.1` component of the conclusion):

```
/-- Pinned fiber-realization converse (Rabinovich Cor 5.4(1) ⇐ one fiber level down,
    + Cor 5.4(2) re-anchoring): at a destructor-selected exterior endpoint carrying the
    chain/endpoint truth, under the level-up ambient realization, σ itself is realized
    PINNED at [x1, w, x, t]. -/
theorem kvE_futPinned_of_end {sig : MonadicSignature} {atomMap : Formula → sig.preds}
    {m : Nat} (P : ExistProviders sig atomMap m)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (m + 2) 3) (σ : NormalForm sig (m + 1) 4)
    (hadm : kvE_futAdmissible σ = true)
    (hfib : nf1_dropFresh σ = qnf.1)              -- σ on qnf's fiber (shape per site)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M (m + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)  -- AMBIENT
    (x1 : M.carrier) (htx1 : t < x1)
    (hpos : temporal_truth M atomMap t (kvE_futPos P σ))                     -- chain fires
    (hend : temporal_truth M atomMap x1 (kvE_futEnd P σ))                    -- endpoint
    (hgap : ∀ r : M.carrier, t < r → r < x1 →
      temporal_truth M atomMap r (kvE_futGapD P σ))                          -- destructor
    (hocc : ∀ s ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
      t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P s)) :  -- destructor
    nf_eval_nf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
```

(The report's `nf1_dropFresh` has no in-tree declaration; its faithful in-tree spelling is
`nfk_dropFresh σ = qnf.1` — `nfk_dropFresh` drops the fresh slot from σ's atom layer,
NfEFold.lean:578.)

**This file (Phase 2)** proves the ATOM-LAYER half `kvE_futAtomPinned_zero`: under the §2.4
hypotheses at `m := 0`, the endpoint's complete atomic profile is pinned —
`nf_eval_nf M 0 4 [x1, w, x, t] σ.1`. The atom layer needs only `hadm`/`hfib`/`h`
(ambient)/`hend` from the §2.4 set; the chain-fire `hpos` and destructor walk facts
`hgap`/`hocc` are consumed by Phase 3's fiber-fold identification, which assembles the full
`kvE_futPinned_of_end_zero` from this lemma + `nf_eval_nfk_iff_efold`.

**Proof route** (three-channel factorization `nf_eval_nf0_cons_factor`, NfEFold.lean:283,
machine-validated on the probe model — ExteriorPinnedProbeK.lean, C8 GO):

- **Ordering channel**: admissibility conjunct 1 pins `nf0_zoneSpec σ.1 = kvE2_sep_zFutT3`,
  and the actual anchors render that zone at `x1` (`w, x, t < x1`).
- **Monadic (fresh-profile) channel** — the load-bearing step: `hend`'s self-zone conjunct
  delivers a self-zone fiber element `s0` realized with `x1` at the FRESH slot over a free
  env `env0`; the self-zone head coupling `(false, false)` forces `env0 0 = x1` (coincidence,
  probe ingredient C8(a)), so `s0`'s env-restriction channel — which admissibility
  conjunct 2 identifies with `σ.1` — reads σ.1's `x1`-slot predicates at `x1` itself.
- **Env-restriction channel**: the level-up ambient's atom layer at `[w, x, t]` transports
  through the fiber condition `hfib` (probe ingredient C8(b) marking side not needed at the
  atom layer).

Purely additive NEW leaf module (task 360 Phase 2/3 territory); no existing file is touched. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff)

/-! ## Helper 1: admissibility conjunct-1 reader (zone marking of the atom layer)

The sibling of the conjunct-2 readers `kvE_futAdmissible_onFiber`/`_offFiber`
(ExteriorConverterK.lean:63/:73): a navigation-only read of the already-landed admissibility
Boolean, exposing conjunct 1 — the `zFutT3` zone marking of `σ.1`. -/

/-- **Admissibility ⇒ zone marking**: under `kvE_futAdmissible σ`, the atom base layer `σ.1`
    carries the exterior-future zone marking `kvE2_sep_zFutT3` (`x1` strictly above each of
    `w`, `x`, `t`). The Boolean conjunct-1 read of `kvE_futAdmissible`
    (ExteriorNegationK.lean:86). -/
theorem kvE_futAdmissible_zoneMark {sig : MonadicSignature} {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (hadm : kvE_futAdmissible σ = true) :
    nf0_zoneSpec σ.1 = kvE2_sep_zFutT3 := by
  have hadm' := hadm
  unfold kvE_futAdmissible at hadm'
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hadm'
  exact of_decide_eq_true hadm'.1.1.1

/-! ## Helper 2: self-zone coincidence (general environment)

The production generalization of the probe's `kvE_probe_selfZone_coincide`
(ExteriorPinnedProbeK.lean:181, C8 ingredient (a)): there the env was pinned and the fresh
witness free; here the env is FREE (the shape `kvE_fiberPosOnShift_correct` delivers) and the
fresh witness is the known endpoint — the same index-0 coupling trichotomy pins the env's
`x1`-slot to the witness. -/

/-- **Self-zone coincidence**: the self-zone head coupling `(false, false)`
    (`kvE_futSelfZone`, ExteriorNegationK.lean:70) forces fresh/slot-0 coincidence on any
    linear order — a point `v` in the self zone relative to ANY environment `env` satisfies
    `v = env 0`. Pure `lt_trichotomy` on the index-0 coupling. -/
theorem kvE_futSelfZone_coincide {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {env : Fin 4 → M.carrier} {v : M.carrier}
    (hz : zoneHolds M env kvE_futSelfZone v) :
    v = env 0 := by
  have h0 := hz 0
  rcases lt_trichotomy v (env 0) with h | h | h
  · exact absurd (h0.1.mp h) Bool.false_ne_true
  · exact h
  · exact absurd (h0.2.mp h) Bool.false_ne_true

/-! ## Helper 3: `x1`-slot pinning from the endpoint truth

The load-bearing step of the atom-layer pinning: σ.1's fresh-slot (`x1`-slot) predicate
atoms are pinned to `x1`'s ACTUAL monadic profile. `hend`'s self-zone conjunct delivers an
on-fiber self-zone element realized at the fresh slot `x1` over a FREE env (exactly what the
env-free content channel can say); coincidence (Helper 2) upgrades the free env's `x1`-slot
to `x1` itself, and admissibility conjunct 2 identifies the element's env restriction with
`σ.1` — closing the free-env → pinned gap at the atom layer (the m = 0 mechanism
machine-validated as probe ingredient C8(c)). -/

/-- **Fresh-profile pinning from the endpoint**: under admissibility, the endpoint truth
    `kvE_futEnd P σ` at `x1` pins σ.1's fresh-slot monadic profile to `x1`'s actual
    profile — `nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1)`. -/
theorem kvE_futFreshPinned_of_end {sig : MonadicSignature}
    {atomMap : Formula → sig.preds}
    (P : ExistProviders sig atomMap 0)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig 1 4)
    (hadm : kvE_futAdmissible σ = true)
    (x1 : M.carrier)
    (hend : temporal_truth M atomMap x1 (kvE_futEnd P σ)) :
    nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1) := by
  -- self-zone fiber element realized (free env) with `x1` at the fresh slot
  rw [kvE_futEnd, formula_conjList_iff] at hend
  have hself := hend (kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_futSelfZone)) (by simp)
  rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1] at hself
  obtain ⟨s0, hs0mem, env0, hev0⟩ := hself
  obtain ⟨hbit0, hzone0⟩ := (kvE_fiberZoneList_mem σ kvE_futSelfZone s0).mp hs0mem
  -- on-fiber: `s0`'s env restriction IS `σ.1` (admissibility conjunct 2)
  have hd0 : nf0_dropFresh s0 = σ.1 := kvE_futAdmissible_onFiber σ hadm s0 hbit0
  -- factor `s0`'s realization into the three depth-0 channels
  obtain ⟨hz0, -, hdrop0⟩ := (nf_eval_nf0_cons_factor M env0 x1 s0).mp hev0
  have hzs : nf0_zoneSpec s0 = kvE_futSelfZone := hzone0
  rw [hzs] at hz0
  rw [hd0] at hdrop0
  -- coincidence: the free env's `x1`-slot is `x1` itself
  have hx1e : x1 = env0 0 := kvE_futSelfZone_coincide M hz0
  -- read σ.1's fresh-slot predicates off the realized env restriction at `env0 0 = x1`
  intro a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    have hp := hdrop0 (.pred p (0 : Fin 4))
    simp only [atom_eval] at hp
    rw [← hx1e] at hp
    simpa only [atom_eval, nf0_projFresh] using hp
  | .order i j hne => exact absurd (Subsingleton.elim i j) hne

/-! ## The Phase-2 deliverable: endpoint atom-layer pinning at m = 0 -/

/-- **Endpoint atom-layer pinning** (task 360 Phase 2 — the atom-layer half of the pinned
    fiber-realization converse `kvE_futPinned_of_end_zero`, report 03 §2.4 at `m := 0`):
    under admissibility, σ on `qnf`'s fiber, the level-up ambient realization at `[w, x, t]`,
    and the destructor-endpoint truth `kvE_futEnd P σ` at `x1 > t`, the endpoint's complete
    atomic profile is pinned — `σ.1` is realized at the ACTUAL anchors `[x1, w, x, t]`.

    Of the §2.4 hypothesis set, the atom layer consumes `hadm`/`hfib`/`h`/`hend` only; the
    chain-fire `hpos` and destructor walk facts `hgap`/`hocc` are consumed by Phase 3's
    fiber-fold identification. Assembly is the three-channel factorization
    `nf_eval_nf0_cons_factor` (fresh := `x1`, env := `[w, x, t]`): ordering channel from
    admissibility conjunct 1 (Helper 1) + the actual order facts; fresh-profile channel from
    the endpoint truth (Helper 3, via coincidence Helper 2); env-restriction channel from
    the ambient's atom layer through `hfib`. -/
theorem kvE_futAtomPinned_zero {sig : MonadicSignature}
    {atomMap : Formula → sig.preds}
    (P : ExistProviders sig atomMap 0)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (hadm : kvE_futAdmissible σ = true)
    (hfib : nfk_dropFresh σ = qnf.1)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (x1 : M.carrier) (htx1 : t < x1)
    (hend : temporal_truth M atomMap x1 (kvE_futEnd P σ)) :
    nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 := by
  refine (nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1 σ.1).mpr
    ⟨?_, ?_, ?_⟩
  · -- ordering channel: conjunct-1 zone marking rendered by the actual anchors
    rw [kvE_futAdmissible_zoneMark σ hadm]
    intro i
    match i with
    | ⟨0, _⟩ =>
      exact ⟨iff_of_false (lt_asymm (hwt.trans htx1)) Bool.false_ne_true,
             iff_of_true (hwt.trans htx1) rfl⟩
    | ⟨1, _⟩ =>
      exact ⟨iff_of_false (lt_asymm ((hxw.trans hwt).trans htx1)) Bool.false_ne_true,
             iff_of_true ((hxw.trans hwt).trans htx1) rfl⟩
    | ⟨2, _⟩ =>
      exact ⟨iff_of_false (lt_asymm htx1) Bool.false_ne_true,
             iff_of_true htx1 rfl⟩
  · -- monadic (fresh-profile) channel: pinned by the endpoint truth
    exact kvE_futFreshPinned_of_end P M h_UZ h_SZ σ hadm x1 hend
  · -- env-restriction channel: the ambient's atom layer through the fiber condition
    rw [show nf0_dropFresh σ.1 = qnf.1 from hfib]
    exact nf_eval_nf_atom_layer M _ qnf h

end Bimodal.Metalogic.WeakCanonical.Kamp
