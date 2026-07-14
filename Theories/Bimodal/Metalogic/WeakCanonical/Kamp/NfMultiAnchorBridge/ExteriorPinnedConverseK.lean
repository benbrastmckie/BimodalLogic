import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK

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
  (formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
   nf_depth0_char_formula)

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

/-! ## Phase 3 adjudication: the §2.4 pinned converse is REFUTED at m = 0

**Machine-checked refutation (task 360 Phase 3, C8-adjudication defect).** The report-03 §2.4
statement `kvE_futPinned_of_end` (docstring above) is FALSE at `m := 0` — on EVERY Prior
structure with four ordered points `x < w < t < x1` there is an admissible, on-fiber σ′
satisfying the COMPLETE §2.4 hypothesis set (honest ambient, `hpos`, `hend`, `hgap`, `hocc`)
that is NOT pinned-realized at `[x1, w, x, t]` (`kvE_futPinned_of_end_zero_refuted` below).

**Root cause — interior-zone blindness of the hypothesis set.** Every semantic hypothesis of
§2.4 reads σ.2 exclusively through the three EXTERIOR zone buckets
(`kvE_fiberZoneList σ` at `kvE_futGapZone`/`kvE_futRayZone`/`kvE_futSelfZone` — the only
σ.2-dependent ingredients of `kvE_futPos`/`kvE_futEnd`/`kvE_futGapD`) plus the admissibility
Boolean (whose conjuncts 2-4 constrain marked subs to the atom fiber, kill order-impossible
zones, and force self-zone uniqueness — none forces interior marking). On-fiber fiber elements
whose fresh witness sits in one of the six INTERIOR zones (`v ≤ t` region: below-`x`, `= x`,
`(x,w)`, `= w`, `(w,t)`, `= t` — all order-possible, hence admissibility-free) are read by NO
hypothesis; the conclusion's fold biconditional (`nf_eval_nfk_iff_efold`) pins them. Flipping
one realized interior element out of the honest endpoint type τ therefore preserves every
hypothesis VERBATIM (the three zone lists — hence the clause formulas — are unchanged, and
admissibility is monotone under mark-erasure) while destroying realization.

This is precisely the failure mode ExteriorConverterK.lean's header recorded for the BARE
converse ("an unrecorded-but-realizable on-fiber sub would break the fold biconditional while
leaving the recorded gap chain intact"); report 03 §2.3 adjudicated (confidence Medium, NOT
machine-run) that `hend`/`hgap`/`hocc` + ambient close it, but those facts reach only the
exterior zones. The plan's Phase-3 case list has no supplier for its "interior/below-`t`
zones" cases: the cited route ("the ambient `h` + σ-on-fiber — qnf's own fold renders these
zones' population") supplies the REALIZATION side of interior elements but no link from any
hypothesis to σ.2's interior MARKING (σ.2 is never related to `qnf.2`; `hfib` relates atom
layers only).

The four `*_of_realizer` extraction lemmas below are the TRUE (and reusable) half: a genuine
pinned realizer forces all four §2.4 truth antecedents — the exact supply shapes any repaired
converse (and Phase 5) consumes. -/

/-! ### Realizer ⇒ §2.4 antecedents (the reusable supply direction) -/

/-- **Chain-fire from a realizer**: a pinned exterior realizer of `σ` forces the positive
    local-existence form `kvE_futPos P σ` at `t`. Contrapositive of `kvE_extNegFut_sound`. -/
theorem kvE_futPos_of_realizer {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t x1 : M.carrier) (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (hσ : nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap t (kvE_futPos P σ) := by
  by_contra hnp
  exact kvE_extNegFut_sound P M h_UZ h_SZ σ w x t hxw hwt
    (by rw [kvE_extNegFut, temporal_truth_neg]; exact hnp) x1 htx1 hσ

/-- **Gap guard from a realizer**: a pinned exterior realizer of `σ` renders the gap
    disjunction `kvE_futGapD P σ` uniformly on `(t, x1)`. The `hD` step of
    `kvE_extNegFut_sound` (ExteriorNegationK.lean:549), exposed as a public supply lemma. -/
theorem kvE_futGapD_of_realizer {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t x1 : M.carrier) (hxw : x < w) (hwt : w < t)
    (hσ : nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∀ r : M.carrier, t < r → r < x1 → temporal_truth M atomMap r (kvE_futGapD P σ) := by
  intro r htr hrx1
  rw [kvE_futGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ r]
  have hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      kvE_futGapZone r :=
    kvE_futZone4_of_above M r x1 w x t hxw hwt htr (true, false)
      (iff_of_true hrx1 rfl) (iff_of_false (lt_asymm hrx1) Bool.false_ne_true)
  obtain ⟨s, hsmem, hsrel⟩ :=
    kvE_fiberZoneList_realized M _ σ hσ kvE_futGapZone r hz
  exact ⟨s, hsmem, _, hsrel⟩

/-- **Endpoint description from a realizer**: a pinned exterior realizer of `σ` forces the
    endpoint truth `kvE_futEnd P σ` at `x1`. The `hend` step of `kvE_extNegFut_sound`
    (ExteriorNegationK.lean:561), exposed as a public supply lemma. -/
theorem kvE_futEnd_of_realizer {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t x1 : M.carrier) (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (hσ : nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap x1 (kvE_futEnd P σ) := by
  obtain ⟨⟨hA, hfib⟩, -⟩ :=
    (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mp hσ
  rw [kvE_futEnd, formula_conjList_iff]
  intro f hf
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
  rcases hf with rfl | rfl
  · -- self-zone content at `x1`
    rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1]
    have hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE_futSelfZone x1 :=
      kvE_futZone4_of_above M x1 x1 w x t hxw hwt htx1 (false, false)
        (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
        (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
    obtain ⟨s, hsmem, hsrel⟩ :=
      kvE_fiberZoneList_realized M _ σ hσ kvE_futSelfZone x1 hz
    exact ⟨s, hsmem, _, hsrel⟩
  · -- exact ray content
    rw [kvE_futRayForm, formula_conjList_iff]
    intro g hg
    rcases List.mem_cons.mp hg with rfl | hg'
    · -- every future point carries a ray sub: `¬F(¬D_ray)`
      intro hF
      obtain ⟨u, hx1u, hnotD, -⟩ := hF
      apply hnotD
      rw [kvE_futRayD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ u]
      have hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
          kvE_futRayZone u :=
        kvE_futZone4_of_above M u x1 w x t hxw hwt (htx1.trans hx1u) (false, true)
          (iff_of_false (lt_asymm hx1u) Bool.false_ne_true) (iff_of_true hx1u rfl)
      obtain ⟨s, hsmem, hsrel⟩ :=
        kvE_fiberZoneList_realized M _ σ hσ kvE_futRayZone u hz
      exact ⟨s, hsmem, _, hsrel⟩
    · -- each ray sub occurs above `x1`
      obtain ⟨s, hsmem, rfl⟩ := List.mem_map.mp hg'
      have hbit : σ.2 s = true := ((kvE_fiberZoneList_mem σ kvE_futRayZone s).mp hsmem).1
      have hzs : nfk_zoneSpec s = kvE_futRayZone :=
        ((kvE_fiberZoneList_mem σ kvE_futRayZone s).mp hsmem).2
      have hd : nfk_dropFresh s = σ.1 :=
        kvE_fiber_dropFresh M _ σ hσ s ((kvE_fiber_mem σ s).mpr hbit)
      obtain ⟨v, hv⟩ := (hfib s hd).mpr hbit
      have hzone := kvE_futZoneHolds_of_atom M _ v s hv
      rw [hzs] at hzone
      have hx1v : x1 < v := (hzone 0).2.mpr rfl
      refine ⟨v, hx1v, ?_, fun r _ _ => id⟩
      rw [kvE_futItemShift_correct P s M h_UZ h_SZ v]
      exact ⟨_, hv⟩

/-- **Per-item pinned gap occurrence from a realizer**: a pinned exterior realizer of `σ`
    places every gap-listed fiber element in `(t, x1)` under the shifted content channel.
    The `hocc` step of `kvE_extNegFut_sound` (ExteriorNegationK.lean:607), rendered through
    `kvE_futItemShift_correct` in exactly the §2.4 `hocc` shape. -/
theorem kvE_futOcc_of_realizer {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t x1 : M.carrier)
    (hσ : nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∀ s ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
      t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P s) := by
  obtain ⟨⟨-, hfib⟩, -⟩ :=
    (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mp hσ
  intro s hsmem
  have hbit : σ.2 s = true := ((kvE_fiberZoneList_mem σ kvE_futGapZone s).mp hsmem).1
  have hzs : nfk_zoneSpec s = kvE_futGapZone :=
    ((kvE_fiberZoneList_mem σ kvE_futGapZone s).mp hsmem).2
  have hd : nfk_dropFresh s = σ.1 :=
    kvE_fiber_dropFresh M _ σ hσ s ((kvE_fiber_mem σ s).mpr hbit)
  obtain ⟨v, hv⟩ := (hfib s hd).mpr hbit
  have hzone := kvE_futZoneHolds_of_atom M _ v s hv
  rw [hzs] at hzone
  have hvx1 : v < x1 := (hzone 0).1.mpr rfl
  have htv : t < v := (hzone ⟨3, by omega⟩).2.mpr rfl
  refine ⟨v, htv, hvx1, ?_⟩
  rw [kvE_futItemShift_correct P s M h_UZ h_SZ v]
  exact ⟨_, hv⟩

/-! ### Hypothesis-set invariance under interior mark-erasure (the defect isolation) -/

/-- **Fiber-existential read monotonicity**: erasing marks (pointwise `σ'.2 ≤ σ.2` with the
    same atom layer) can only lose `kvE_subBit` reads. -/
theorem kvE_subBit_mono {sig : MonadicSignature} {k : Nat}
    (σ σ' : NormalForm sig (k + 1) 4)
    (h1 : σ'.1 = σ.1)
    (h2 : ∀ s : NormalForm sig k 5, σ'.2 s = true → σ.2 s = true)
    (zs4 : ZoneSpec 4) (χ : NormalForm sig k 1)
    (hb : kvE_subBit σ' zs4 χ = true) :
    kvE_subBit σ zs4 χ = true := by
  rw [kvE_subBit] at hb ⊢
  obtain ⟨s, hsmem, hread⟩ := List.any_eq_true.mp hb
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hread
  obtain ⟨⟨⟨hd, hz⟩, hp⟩, hsbit⟩ := hread
  refine List.any_eq_true.mpr ⟨s, hsmem, ?_⟩
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  exact ⟨⟨⟨decide_eq_true (h1 ▸ of_decide_eq_true hd), hz⟩, hp⟩, h2 s hsbit⟩

/-- **Admissibility survives mark-erasure** — given fiber-consistency of the erased marking:
    `kvE_futAdmissible` transports under erasing quant-layer marks (same atom layer).
    Conjunct 1 is atom-only; conjuncts 3-4 constrain only MARKED subs, so losing marks
    preserves them. The task-363 consistency guard inside conjunct 2 is NOT monotone under
    mark-erasure (an erased mark may have been another sub's mate witness), so the surviving
    marks' consistency is supplied by the caller (`hcons`) — trivially dischargeable at
    `k = 0` via `kvE_fiberElemConsistent_zero` (the only current consumer). -/
theorem kvE_futAdmissible_of_subMarking {sig : MonadicSignature} {k : Nat}
    (σ σ' : NormalForm sig (k + 1) 4)
    (h1 : σ'.1 = σ.1)
    (h2 : ∀ s : NormalForm sig k 5, σ'.2 s = true → σ.2 s = true)
    (hcons : ∀ s : NormalForm sig k 5, σ'.2 s = true → kvE_fiberElemConsistent σ' s = true)
    (hadm : kvE_futAdmissible σ = true) :
    kvE_futAdmissible σ' = true := by
  have hadm' := hadm
  unfold kvE_futAdmissible at hadm' ⊢
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hadm'
  obtain ⟨⟨⟨hc1, hc2⟩, hc3⟩, hc4⟩ := hadm'
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- conjunct 1: atom-only, transported along `h1`
    rw [h1]; exact hc1
  · -- conjunct 2: marked ⇒ on-fiber ∧ consistent (consistency from `hcons`)
    rw [List.all_eq_true] at hc2 ⊢
    intro s hs
    rw [Bool.or_eq_true]
    by_cases hb : σ'.2 s = true
    · have hσ2 := hc2 s hs
      rw [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq] at hσ2
      rcases hσ2 with ⟨hfibs, -⟩ | hfalse
      · refine Or.inl ?_
        rw [Bool.and_eq_true]
        exact ⟨decide_eq_true (h1.symm ▸ hfibs), hcons s hb⟩
      · rw [Bool.not_eq_true'] at hfalse
        exact absurd (h2 s hb) (by rw [hfalse]; exact Bool.false_ne_true)
    · rw [Bool.not_eq_true] at hb
      exact Or.inr (by rw [hb]; rfl)
  · -- conjunct 3: no bits on order-impossible zones
    rw [List.all_eq_true] at hc3 ⊢
    intro zs4 hzs
    have h3 := hc3 zs4 hzs
    rw [Bool.or_eq_true] at h3 ⊢
    rcases h3 with hposs | hall
    · exact Or.inl hposs
    · refine Or.inr ?_
      rw [List.all_eq_true] at hall ⊢
      intro χ hχ
      cases hb : kvE_subBit σ' zs4 χ with
      | false => rfl
      | true =>
        have hσb := kvE_subBit_mono σ σ' h1 h2 zs4 χ hb
        have := hall χ hχ
        rw [hσb] at this
        exact absurd this (by decide)
  · -- conjunct 4: self-zone profile uniqueness
    rw [List.all_eq_true] at hc4 ⊢
    intro χ hχ
    rw [List.all_eq_true]
    intro χ' hχ'
    rw [Bool.or_eq_true, Bool.or_eq_true]
    by_cases hbχ : kvE_subBit σ' kvE_futSelfZone χ = true
    · by_cases hbχ' : kvE_subBit σ' kvE_futSelfZone χ' = true
      · have h4 := (List.all_eq_true.mp (hc4 χ hχ)) χ' hχ'
        rw [Bool.or_eq_true, Bool.or_eq_true,
          kvE_subBit_mono σ σ' h1 h2 kvE_futSelfZone χ hbχ,
          kvE_subBit_mono σ σ' h1 h2 kvE_futSelfZone χ' hbχ'] at h4
        rcases h4 with (h4 | h4) | h4
        · exact absurd h4 (by decide)
        · exact absurd h4 (by decide)
        · exact Or.inr h4
      · rw [Bool.not_eq_true] at hbχ'
        exact Or.inl (Or.inr (by rw [hbχ']; rfl))
    · rw [Bool.not_eq_true] at hbχ
      exact Or.inl (Or.inl (by rw [hbχ]; rfl))

/-- **Zone-list congruence**: two σ's whose markings agree on all subs of zone `zs4` (same
    fiber base list) have the SAME zone list at `zs4` — the clause formulas cannot see any
    marking difference outside their own zone bucket. -/
theorem kvE_fiberZoneList_congr {sig : MonadicSignature} {k : Nat}
    (σ σ' : NormalForm sig (k + 1) 4) (zs4 : ZoneSpec 4)
    (h : ∀ s : NormalForm sig k 5, nfk_zoneSpec s = zs4 → σ'.2 s = σ.2 s) :
    kvE_fiberZoneList σ' zs4 = kvE_fiberZoneList σ zs4 := by
  rw [kvE_fiberZoneList, kvE_fiberZoneList, kvE_fiber, kvE_fiber,
    List.filter_filter, List.filter_filter]
  refine List.filter_congr ?_
  intro s _
  by_cases hz : nfk_zoneSpec s = zs4
  · rw [h s hz]
  · rw [decide_eq_false hz, Bool.false_and, Bool.false_and]

/-! ### The refutation theorem -/

/-- **The §2.4 pinned fiber-realization converse is FALSE at `m = 0`** (task 360 Phase 3
    adjudication, C8 defect): on EVERY Prior (UZ/SZ) structure with four ordered points
    `x < w < t < x1` there exist an ambient-realized `qnf` and an admissible on-fiber
    `σ'` satisfying the COMPLETE §2.4 hypothesis set — `hadm`, `hfib`, the honest ambient,
    `hpos`, `hend`, `hgap`, `hocc` — such that σ' is NOT pinned-realized at `[x1, w, x, t]`.

    Construction: `τ := nf_characteristic M 1 4 [x1,w,x,t]` (the honest endpoint type,
    pinned-realized and satisfying all antecedents via the `*_of_realizer` lemmas), and
    `σ' := τ` with the mark of the INTERIOR fiber element
    `e := nf_characteristic M 0 5 [w, x1, w, x, t]` (fresh witness `w`, zone `= w` — an
    interior zone, so `e` is in NO gap/ray/self bucket) erased. Every hypothesis is
    invariant under the erasure (`kvE_fiberZoneList_congr` + admissibility monotonicity),
    but a pinned realizer of σ' would force `σ'.2 e = true` through the fold biconditional
    (`e` is on-fiber and realized at fresh witness `w`) — contradiction.

    Consequence: `kvE_futPinned_of_end_zero` (file-head docstring) is unprovable — its
    hypothesis set must be strengthened with an interior-zone marking supplier before any
    proof attempt; report 03 §2.3 item 3's "identification closes with landed machinery at
    m=0" is refuted for the six interior zones. -/
theorem kvE_futPinned_of_end_zero_refuted {sig : MonadicSignature}
    {atomMap : Formula → sig.preds}
    (P : ExistProviders sig atomMap 0)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (w x t x1 : M.carrier) (hxw : x < w) (hwt : w < t) (htx1 : t < x1) :
    ∃ (qnf : NormalForm sig 2 3) (σ' : NormalForm sig 1 4),
      kvE_futAdmissible σ' = true ∧
      nfk_dropFresh σ' = qnf.1 ∧
      nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf ∧
      temporal_truth M atomMap t (kvE_futPos P σ') ∧
      temporal_truth M atomMap x1 (kvE_futEnd P σ') ∧
      (∀ r : M.carrier, t < r → r < x1 →
        temporal_truth M atomMap r (kvE_futGapD P σ')) ∧
      (∀ s ∈ kvE_fiberZoneList σ' kvE_futGapZone, ∃ r : M.carrier,
        t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P s)) ∧
      ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ' := by
  -- the honest ambient and the honest endpoint type
  have hqnf : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t)))
      (nf_characteristic M 2 3 (Fin.cons w (Fin.cons x (fun _ => t)))) :=
    nf_characteristic_satisfies M 2 3 _
  set qnf : NormalForm sig 2 3 :=
    nf_characteristic M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) with hqnfdef
  have hτ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf_characteristic M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) :=
    nf_characteristic_satisfies M 1 4 _
  set τ : NormalForm sig 1 4 :=
    nf_characteristic M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) with hτdef
  have hτadm : kvE_futAdmissible τ = true :=
    kvE_futRealizer_admissible M τ x1 w x t hxw hwt htx1 hτ
  -- the interior witness element: the complete 5-point atomic type with fresh witness `w`
  have he : nf_eval_nf M 0 5
      (Fin.cons w (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))))
      (nf_characteristic M 0 5
        (Fin.cons w (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))))) :=
    nf_characteristic_satisfies M 0 5 _
  set e : NormalForm sig 0 5 :=
    nf_characteristic M 0 5
      (Fin.cons w (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) with hedef
  -- `e` is on τ's atom fiber
  have hefib : nfk_dropFresh e = τ.1 := by
    have hefac := (nf_eval_nf0_cons_factor M
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) w e).mp he
    exact nf_eval_unique M 0 4 _ _ _ hefac.2.2
      (nf_eval_nf_atom_layer M _ τ hτ)
  -- σ' := τ with `e`'s mark erased (τ itself marks `e`: it is realized at fresh witness
  -- `w`, so τ's own fold records it — which is exactly what the erasure destroys)
  set σ' : NormalForm sig 1 4 :=
    (τ.1, fun s => if s = e then false else τ.2 s) with hσ'def
  have hσ'e : σ'.2 e = false := if_pos rfl
  have hσ'sub : ∀ s : NormalForm sig 0 5, σ'.2 s = true → τ.2 s = true := by
    intro s hs
    by_cases hse : s = e
    · exact absurd hs (by rw [show σ'.2 s = false from hse ▸ hσ'e]; exact Bool.false_ne_true)
    · rwa [show σ'.2 s = τ.2 s from if_neg hse] at hs
  -- `e`'s zone is INTERIOR: its fresh witness `w` coincides with the `w`-anchor, so its
  -- zone differs from every exterior head-cons zone (whose index-1 coupling is `(false,true)`)
  have hez : ∀ p0 : Bool × Bool, nfk_zoneSpec e ≠ Fin.cons p0 kvE2_sep_zFutT3 := by
    intro p0 hcontra
    have hzone := kvE_futZoneHolds_of_atom M
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) w e he
    rw [hcontra] at hzone
    exact absurd ((hzone 1).2.mpr rfl) (lt_irrefl w)
  -- markings agree on every exterior-head zone, hence the zone lists coincide
  have hlists : ∀ p0 : Bool × Bool,
      kvE_fiberZoneList σ' (Fin.cons p0 kvE2_sep_zFutT3) =
        kvE_fiberZoneList τ (Fin.cons p0 kvE2_sep_zFutT3) := by
    intro p0
    refine kvE_fiberZoneList_congr τ σ' _ ?_
    intro s hz
    by_cases hse : s = e
    · exact absurd (hse ▸ hz) (hez p0)
    · exact if_neg hse
  have hgapL : kvE_fiberZoneList σ' kvE_futGapZone = kvE_fiberZoneList τ kvE_futGapZone :=
    hlists (true, false)
  have hrayL : kvE_fiberZoneList σ' kvE_futRayZone = kvE_fiberZoneList τ kvE_futRayZone :=
    hlists (false, true)
  have hselfL : kvE_fiberZoneList σ' kvE_futSelfZone = kvE_fiberZoneList τ kvE_futSelfZone :=
    hlists (false, false)
  -- the clause formulas are therefore IDENTICAL for σ' and τ
  have hGapDeq : kvE_futGapD P σ' = kvE_futGapD P τ := by
    rw [kvE_futGapD, kvE_futGapD, hgapL]
  have hEndEq : kvE_futEnd P σ' = kvE_futEnd P τ := by
    rw [kvE_futEnd, kvE_futEnd, kvE_futRayForm, kvE_futRayForm,
      kvE_futRayD, kvE_futRayD, hselfL, hrayL]
  have hadm' : kvE_futAdmissible σ' = true :=
    kvE_futAdmissible_of_subMarking τ σ' rfl hσ'sub
      (fun s _ => kvE_fiberElemConsistent_zero σ' s) hτadm
  have hPosEq : kvE_futPos P σ' = kvE_futPos P τ := by
    rw [kvE_futPos, kvE_futPos, if_pos hadm', if_pos hτadm, hgapL]
    have : kvE_futChain P σ' = kvE_futChain P τ := by
      funext l
      rw [kvE_futChain, kvE_futChain, hEndEq, hGapDeq]
    rw [this]
  -- σ' is on qnf's fiber (through τ's own fiber fact)
  have hτfib : nfk_dropFresh τ = qnf.1 := by
    have hτ0 : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ.1 :=
      nf_eval_nf_atom_layer M _ τ hτ
    have hfac4 := (nf_eval_nf0_cons_factor M
      (Fin.cons w (Fin.cons x (fun _ => t))) x1 τ.1).mp hτ0
    exact nf_eval_unique M 0 3 _ _ _ hfac4.2.2 (nf_eval_nf_atom_layer M _ qnf hqnf)
  -- assemble the witness
  refine ⟨qnf, σ', hadm', hτfib, hqnf, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hPosEq]
    exact kvE_futPos_of_realizer P M h_UZ h_SZ τ w x t x1 hxw hwt htx1 hτ
  · rw [hEndEq]
    exact kvE_futEnd_of_realizer P M h_UZ h_SZ τ w x t x1 hxw hwt htx1 hτ
  · intro r htr hrx1
    rw [hGapDeq]
    exact kvE_futGapD_of_realizer P M h_UZ h_SZ τ w x t x1 hxw hwt hτ r htr hrx1
  · intro s hs
    rw [hgapL] at hs
    exact kvE_futOcc_of_realizer P M h_UZ h_SZ τ w x t x1 hτ s hs
  · -- σ' is NOT pinned-realized: a realizer would force `σ'.2 e = true` through the fold
    intro hcontra
    obtain ⟨⟨-, hfib'⟩, -⟩ :=
      (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ').mp
        hcontra
    have := (hfib' e hefib).mp ⟨w, he⟩
    rw [hσ'e] at this
    exact Bool.false_ne_true this

/-! ## Phase 3 (plan v2): slice machinery + the exterior-slice identification converse

The faithful repair of the refuted §2.4 converse (report
`specs/360_restate_exterior_hbr_pinned_converse/reports/02_faithful-pinned-converse-repair.md`
§3.3, signatures NORMATIVE — transcribed verbatim). Ground truth: Rabinovich 2014 Def 7.13
(chunk_0023:25) footprint discipline — a multi-anchor formula decomposes as a conjunction of
per-adjacent-segment formulas, and negation applies per SEGMENT bracket (Lemma 5.1/7.8),
never per full type. The clause family `kvE_futPos`/`kvE_futEnd`/`kvE_futGapD`/`kvE_extNegFut`
reads `σ.2` exclusively through the three EXTERIOR zone lists, so the clause KEY must be a
function of the same data:

- `kvE_futSliceEq σ' σ` — same atom layer, same three exterior zone lists (the clause
  family's expressive footprint); report 02 §3.3 first def, verbatim.
- `kvE_futSliceMarked qnf σ` — some admissible slice-mate of σ carries `qnf`'s bit (the
  faithful bracket key; WIRED into the bracket in Phase 3b, defined here); report 02 §3.3
  second def, verbatim.
- `kvE_futClause_sliceConstant` — the clause family is constant on slice classes of
  admissible σ (the `kvE_fiberZoneList_congr`/`hPosEq` pattern of the refutation, C10).
- `kvE_futSliceId_of_end_zero` — the REPLACEMENT converse (report 02 §3.3 restated
  signature): under the unchanged §2.4 antecedent set at m = 0 (minus the unused `hpos`),
  the honest endpoint characteristic σ★ is qnf-marked, pinned-realized at `[x1,w,x,t]`,
  atom-layer-equal to σ, and agrees with σ on every exterior-zone marking.
- `kvE_futSliceUnique_zero` — the reconstruction companion: slice-equal σ's pinned-realized
  at (possibly different) exterior endpoints over the same `[w,x,t]` are EQUAL
  (`nf_eval_unique` + the interior same-witness transfer engine).

Machine-validation record (probe gate Phase 0b, ExteriorPinnedProbeK.lean — verdict GO):
P1 = the refutation's σ′ is qnf-unmarked (C4); P2 = the slice-id composite below,
instantiated at `[25,15,2,18]` (C8); P3 = the interior transfer engine (C9). H4 σ′-witness
check: σ′ SATISFIES `kvE_futSliceId_of_end_zero`'s conclusion (via σ' := τ) and satisfies
`kvE_futSliceUnique_zero` vacuously (σ′ is pinned-unrealizable — the refutation itself);
the refutation theorem above is untouched and remains the standing regression guard.

Deviation note: the P3 engine `kvE_probe_interior_transfer` lives in ExteriorPinnedProbeK,
which IMPORTS this file (Phase-0b deviation record) — consuming it here would create an
import cycle. It is therefore replicated below as the production lemma
`kvE_futInteriorTransfer_zero` (settled decision 5: this file stays a leaf; same
`kvE_minPick`/`p3_projFresh_zero` replication precedent). -/

/-! ### The slice defs (report 02 §3.3, verbatim) -/

/-- **Exterior-slice equality**: same atom layer, same three exterior zone lists.
    The clause family `kvE_futPos`/`kvE_futEnd`/`kvE_futGapD`/`kvE_extNegFut` is constant on
    slice classes of admissible σ (`kvE_futClause_sliceConstant` below — the
    `kvE_fiberZoneList_congr` pattern, landed). Def 7.13 footprint discipline: the slice is
    exactly the clause family's expressive footprint. -/
noncomputable def kvE_futSliceEq {sig : MonadicSignature} {k : Nat}
    (σ' σ : NormalForm sig (k + 1) 4) : Bool :=
  decide (σ'.1 = σ.1) &&
  decide (kvE_fiberZoneList σ' kvE_futGapZone  = kvE_fiberZoneList σ kvE_futGapZone) &&
  decide (kvE_fiberZoneList σ' kvE_futRayZone  = kvE_fiberZoneList σ kvE_futRayZone) &&
  decide (kvE_fiberZoneList σ' kvE_futSelfZone = kvE_fiberZoneList σ kvE_futSelfZone)

/-- **σ's exterior slice is qnf-marked**: some admissible slice-mate carries the bit.
    The faithful bracket key (re-keys `kvE_extBracketFut`'s per-σ if-then-else in Phase 3b):
    a negative clause `¬ kvE_futPos P σ` is asserted iff NO marked type carries σ's segment
    content — the paper's `¬∃z [segment](t, z)` (Cor 5.4's negated object), never "type σ is
    unrealized". Pure decidable syntax over the NF fintype. -/
noncomputable def kvE_futSliceMarked {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) (σ : NormalForm sig (k + 1) 4) : Bool :=
  (Finset.univ.toList (α := NormalForm sig (k + 1) 4)).any
    (fun σ' => kvE_futAdmissible σ' && kvE_futSliceEq σ' σ && qnf.2 σ')

/-! ### Clause slice-constancy -/

/-- **Clause slice-constancy** (report 02 C10; the refutation's `hPosEq`/`hEndEq`/`hGapDeq`
    chain generalized from the interior-erasure instance to arbitrary slice-equal pairs):
    for admissible σ', σ with equal exterior slices, the entire clause family agrees as
    FORMULAS. Slice-mates therefore always receive the SAME clause under the re-keyed
    bracket — killing the `F ∧ ¬F` pair that made the per-σ-keyed bracket unsatisfiable. -/
theorem kvE_futClause_sliceConstant {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (σ' σ : NormalForm sig (k + 1) 4)
    (hadm' : kvE_futAdmissible σ' = true) (hadm : kvE_futAdmissible σ = true)
    (hsl : kvE_futSliceEq σ' σ = true) :
    kvE_futPos P σ' = kvE_futPos P σ ∧
    kvE_futEnd P σ' = kvE_futEnd P σ ∧
    kvE_futGapD P σ' = kvE_futGapD P σ ∧
    kvE_extNegFut P σ' = kvE_extNegFut P σ := by
  unfold kvE_futSliceEq at hsl
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hsl
  obtain ⟨⟨⟨-, hgapL⟩, hrayL⟩, hselfL⟩ := hsl
  have hgapL := of_decide_eq_true hgapL
  have hrayL := of_decide_eq_true hrayL
  have hselfL := of_decide_eq_true hselfL
  have hGapDeq : kvE_futGapD P σ' = kvE_futGapD P σ := by
    rw [kvE_futGapD, kvE_futGapD, hgapL]
  have hEndEq : kvE_futEnd P σ' = kvE_futEnd P σ := by
    rw [kvE_futEnd, kvE_futEnd, kvE_futRayForm, kvE_futRayForm,
      kvE_futRayD, kvE_futRayD, hselfL, hrayL]
  have hPosEq : kvE_futPos P σ' = kvE_futPos P σ := by
    rw [kvE_futPos, kvE_futPos, if_pos hadm', if_pos hadm, hgapL]
    have hchain : kvE_futChain P σ' = kvE_futChain P σ := by
      funext l
      rw [kvE_futChain, kvE_futChain, hEndEq, hGapDeq]
    rw [hchain]
  exact ⟨hPosEq, hEndEq, hGapDeq, by rw [kvE_extNegFut, kvE_extNegFut, hPosEq]⟩

/-! ### The interior same-witness transfer engine (probe P3, production replica) -/

/-- **Depth-0 same-witness interior transfer** (the `kvE_futSliceUnique_zero` engine;
    production replica of the probe-validated `kvE_probe_interior_transfer`, P3/C9 — see
    the section-head deviation note): a depth-0 arity-5 fiber element `s` realized at
    `[v, x1, w, x, t]` with an INTERIOR witness (`¬ t < v`) transfers to `[v, x1', w, x, t]`
    with the SAME witness `v`, provided `t < x1`, `t < x1'`, and `x1'` realizes `x1`'s
    complete depth-0 4-type over `[w, x, t]` (profile-equal endpoints). Three-channel
    rebuild (`nf_eval_nf0_cons_factor`): the fresh profile transports verbatim; the tail
    4-type is pinned to the characteristic (`nf_eval_unique`), which the profile-equal
    endpoint realizes by hypothesis; the zone channel changes only at index 0, where
    `v ≤ t < x1` and `v ≤ t < x1'` render the SAME coupling `(true, false)`. -/
theorem kvE_futInteriorTransfer_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (v x1 x1' w x t : M.carrier)
    (hvt : ¬ t < v) (htx1 : t < x1) (htx1' : t < x1')
    (hchar : nf_eval_nf M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf_characteristic M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))))
    (s : NormalForm sig 0 5)
    (hs : nf_eval_nf M 0 5
      (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) :
    nf_eval_nf M 0 5
      (Fin.cons v (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))) s := by
  obtain ⟨hz, hfr, htl⟩ := (nf_eval_nf0_cons_factor M
    (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) v s).mp hs
  -- tail channel: the env restriction is x1's characteristic, realized at x1' by hypothesis
  have htl' : nf_eval_nf M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf0_dropFresh s) := by
    have huniq : nf0_dropFresh s =
        nf_characteristic M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) :=
      nf_eval_unique M 0 4 _ _ _ htl (nf_characteristic_satisfies M 0 4 _)
    rw [huniq]; exact hchar
  refine (nf_eval_nf0_cons_factor M
    (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) v s).mpr ⟨?_, hfr, htl'⟩
  -- zone channel: only the index-0 coupling changes anchor; interiority renders it equal
  have hvx1 : v < x1 := lt_of_le_of_lt (not_lt.mp hvt) htx1
  have hvx1' : v < x1' := lt_of_le_of_lt (not_lt.mp hvt) htx1'
  intro i
  match i with
  | ⟨0, _⟩ =>
    have h0 := hz ⟨0, by omega⟩
    constructor
    · exact iff_of_true hvx1' (h0.1.mp hvx1)
    · refine iff_of_false (lt_asymm hvx1') ?_
      intro hbit
      exact absurd (h0.2.mpr hbit) (lt_asymm hvx1)
  | ⟨1, _⟩ => exact hz ⟨1, by omega⟩
  | ⟨2, _⟩ => exact hz ⟨2, by omega⟩
  | ⟨3, _⟩ => exact hz ⟨3, by omega⟩

/-! ### Private navigation helpers (replicas + zone bookkeeping) -/

/-- File-local replica of the private `nfk_projFresh_zero` (CarrierKv.lean:89 — `private`,
    replicated per the `kvE_minPick`/`p3_projFresh_zero` precedent, never imported): at
    depth 0 the prefix projection coincides with the split kit's `nf0_projFresh`. -/
private theorem kvE_projFresh_zero {sig : MonadicSignature} {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) :
    nfk_projFresh sub = nf0_projFresh sub := by
  funext a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    rfl
  | .order i j h => exact absurd (Subsingleton.elim i j) h

/-- Free-env → pinned upgrade, GAP case (production abstraction of the probe-validated
    `kvE_probe_gapItem_pinned`, C8(c)): an on-fiber, gap-zoned depth-0 fiber element with a
    free-env occurrence at a walk point `r ∈ (t, x1)` is pinned-realized at
    `[r, x1, w, x, t]`, given the pinned atom layer `α` at `[x1, w, x, t]`. -/
private theorem kvE_futGapItem_pinned_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (r x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (htr : t < r) (hrx1 : r < x1)
    (α : NormalForm sig 0 4)
    (hA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) α)
    (s : NormalForm sig 0 5)
    (hfib : nf0_dropFresh s = α)
    (hzone : nf0_zoneSpec s = kvE_futGapZone)
    (hocc : ∃ env : Fin 4 → M.carrier, nf_eval_nf M 0 5 (Fin.cons r env) s) :
    nf_eval_nf M 0 5
      (Fin.cons r (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s := by
  obtain ⟨env, hev⟩ := hocc
  have hfac := (nf_eval_nf0_cons_factor M env r s).mp hev
  refine (nf_eval_nf0_cons_factor M
    (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) r s).mpr ⟨?_, hfac.2.1, ?_⟩
  · rw [hzone]
    exact kvE_futZone4_of_above M r x1 w x t hxw hwt htr
      (true, false) (iff_of_true hrx1 rfl)
      (iff_of_false (lt_asymm hrx1) Bool.false_ne_true)
  · rw [hfib]
    exact hA

/-- Free-env → pinned upgrade, RAY case (production abstraction of the probe-validated
    `kvE_probe_rayItem_pinned`, C8(c)): the same upgrade for a ray-zoned fiber element at
    `r > x1`. -/
private theorem kvE_futRayItem_pinned_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (r x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (htx1 : t < x1) (hx1r : x1 < r)
    (α : NormalForm sig 0 4)
    (hA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) α)
    (s : NormalForm sig 0 5)
    (hfib : nf0_dropFresh s = α)
    (hzone : nf0_zoneSpec s = kvE_futRayZone)
    (hocc : ∃ env : Fin 4 → M.carrier, nf_eval_nf M 0 5 (Fin.cons r env) s) :
    nf_eval_nf M 0 5
      (Fin.cons r (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s := by
  obtain ⟨env, hev⟩ := hocc
  have hfac := (nf_eval_nf0_cons_factor M env r s).mp hev
  refine (nf_eval_nf0_cons_factor M
    (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) r s).mpr ⟨?_, hfac.2.1, ?_⟩
  · rw [hzone]
    exact kvE_futZone4_of_above M r x1 w x t hxw hwt (htx1.trans hx1r)
      (false, true) (iff_of_false (lt_asymm hx1r) Bool.false_ne_true)
      (iff_of_true hx1r rfl)
  · rw [hfib]
    exact hA

/-- Zone-spec determinacy: two zone specs holding at the same witness over the same
    environment are equal (each coordinate's Bools are pinned by the same order facts). -/
private theorem kvE_zoneHolds_unique {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {n : Nat} (env : Fin n → M.carrier)
    (zs zs' : ZoneSpec n) (v : M.carrier)
    (hz : zoneHolds M env zs v) (hz' : zoneHolds M env zs' v) :
    zs = zs' := by
  funext i
  have h1 := hz i
  have h2 := hz' i
  refine Prod.ext ?_ ?_
  · have hiff := h1.1.symm.trans h2.1
    cases ha : (zs i).1 <;> cases hb : (zs' i).1 <;> simp_all
  · have hiff := h1.2.symm.trans h2.2
    cases ha : (zs i).2 <;> cases hb : (zs' i).2 <;> simp_all

/-- Exterior-zone classification: a witness strictly above `t` (over `[x1, w, x, t]` with
    `x < w < t < x1`) carries one of the three EXTERIOR zone specs — gap, ray, or self.
    (Trichotomy against `x1` + `kvE_futZone4_of_above` + zone-spec determinacy.) -/
private theorem kvE_futZoneSpec_of_above {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (htv : t < v)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v) :
    zs = kvE_futGapZone ∨ zs = kvE_futRayZone ∨ zs = kvE_futSelfZone := by
  rcases lt_trichotomy v x1 with hlt | heq | hgt
  · exact Or.inl (kvE_zoneHolds_unique M _ zs kvE_futGapZone v hz
      (kvE_futZone4_of_above M v x1 w x t hxw hwt htv (true, false)
        (iff_of_true hlt rfl) (iff_of_false (lt_asymm hlt) Bool.false_ne_true)))
  · exact Or.inr (Or.inr (kvE_zoneHolds_unique M _ zs kvE_futSelfZone v hz
      (kvE_futZone4_of_above M v x1 w x t hxw hwt htv (false, false)
        (iff_of_false (by rw [heq]; exact lt_irrefl x1) Bool.false_ne_true)
        (iff_of_false (by rw [heq]; exact lt_irrefl x1) Bool.false_ne_true))))
  · exact Or.inr (Or.inl (kvE_zoneHolds_unique M _ zs kvE_futRayZone v hz
      (kvE_futZone4_of_above M v x1 w x t hxw hwt htv (false, true)
        (iff_of_false (lt_asymm hgt) Bool.false_ne_true) (iff_of_true hgt rfl))))

/-! ### The exterior-slice identification converse at m = 0 -/

/-- **Exterior-slice identification at m = 0** (Rabinovich Cor 5.4(1)⇐ + Cor 5.4(2)
    re-anchoring, under the Def 7.13 segment discipline; report 02 §3.3 restated signature,
    verbatim — REPLACES the refuted `kvE_futPinned_of_end_zero`): at a destructor-selected
    exterior endpoint carrying the endpoint/walk truths, under the level-up ambient, the
    endpoint's HONEST complete type σ★ is qnf-marked, pinned-realized at `[x1,w,x,t]`, and
    agrees with σ on the atom layer and on every exterior-zone marking.
    (σ★ := `nf_characteristic M 1 4 [x1,w,x,t]`; no `hpos` antecedent — the atom layer
    consumes only `hadm`/`hfib`/`h`/`hend`, Phase 2.)

    Proof route (report 02 §3.3 steps 1-5, machine-validated as probe P2 on the concrete
    instance): (1) totality + ambient marking of σ★; (2) atom layer via Phase-2
    `kvE_futAtomPinned_zero` + depth-0 `nf_eval_unique`; (3) gap agreement, both inclusions,
    via `hocc`/`hgap` + the free-env → pinned upgrade + uniqueness; (4) ray agreement via
    `hend`'s per-item and `¬F(¬D_ray)` conjuncts + upgrade + uniqueness; (5) self agreement
    via `hend`'s self conjunct + coincidence + admissibility conjunct 4 +
    `nf0_split_assemble`. -/
theorem kvE_futSliceId_of_end_zero {sig : MonadicSignature}
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
    (hend : temporal_truth M atomMap x1 (kvE_futEnd P σ))
    (hgap : ∀ r : M.carrier, t < r → r < x1 →
      temporal_truth M atomMap r (kvE_futGapD P σ))
    (hocc : ∀ s ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
      t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P s)) :
    ∃ σ' : NormalForm sig 1 4,
      qnf.2 σ' = true ∧
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ' ∧
      σ'.1 = σ.1 ∧
      ∀ s : NormalForm sig 0 5,
        (nfk_zoneSpec s = kvE_futGapZone ∨ nfk_zoneSpec s = kvE_futRayZone ∨
         nfk_zoneSpec s = kvE_futSelfZone) → σ'.2 s = σ.2 s := by
  -- Step 1: σ★ := the honest endpoint characteristic — pinned (totality) + qnf-marked
  set τ : NormalForm sig 1 4 :=
    nf_characteristic M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) with hτdef
  have hτpin : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ :=
    nf_characteristic_satisfies M 1 4 _
  have hτmark : qnf.2 τ = true := (h.2 τ).mp ⟨x1, hτpin⟩
  have hτ2 : ∀ e : NormalForm sig 0 5,
      τ.2 e = @decide (∃ z : M.carrier, nf_eval_nf M 0 5
        (Fin.cons z (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) e)
        (Classical.dec _) := fun e => by rw [hτdef]; rfl
  -- Step 2: atom-layer identification (Phase-2 supplier + depth-0 uniqueness)
  have hτA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ.1 :=
    nf_eval_nf_atom_layer M _ τ hτpin
  have hσA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
    kvE_futAtomPinned_zero P M h_UZ h_SZ qnf σ hadm hfib w x t hxw hwt h x1 htx1 hend
  have h31 : τ.1 = σ.1 := nf_eval_unique M 0 4 _ _ _ hτA hσA
  -- shared: σ-marked elements sit on τ's atom fiber
  have honfib : ∀ s : NormalForm sig 0 5, σ.2 s = true → nf0_dropFresh s = τ.1 := by
    intro s hbit
    have hd := kvE_futAdmissible_onFiber σ hadm s hbit
    rw [h31]; exact hd
  -- endpoint-description components (consumed by the ray and self cases)
  have hendC := hend
  rw [kvE_futEnd, formula_conjList_iff] at hendC
  have hselfC := hendC (kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_futSelfZone))
    (by simp)
  have hrayC := hendC (kvE_futRayForm P σ) (by simp)
  rw [kvE_futRayForm, formula_conjList_iff] at hrayC
  rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1] at hselfC
  obtain ⟨s0, hs0mem, env0, hev0⟩ := hselfC
  obtain ⟨hbit0, hzs0⟩ := (kvE_fiberZoneList_mem σ kvE_futSelfZone s0).mp hs0mem
  -- the delivered self element upgrades to PINNED realization at [x1, w, x, t]
  have hzx1self : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      kvE_futSelfZone x1 :=
    kvE_futZone4_of_above M x1 x1 w x t hxw hwt htx1
      (false, false) (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
      (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
  obtain ⟨-, hfr0, -⟩ := (nf_eval_nf0_cons_factor M env0 x1 s0).mp hev0
  have hs0pin : nf_eval_nf M 0 5
      (Fin.cons x1 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s0 := by
    refine (nf_eval_nf0_cons_factor M
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) x1 s0).mpr ⟨?_, hfr0, ?_⟩
    · have hzs0' : nf0_zoneSpec s0 = kvE_futSelfZone := hzs0
      rw [hzs0']; exact hzx1self
    · have htl0' : nf0_dropFresh s0 = τ.1 := honfib s0 hbit0
      rw [htl0']; exact hτA
  have hτs0 : τ.2 s0 = true := by
    rw [hτ2]
    exact @decide_eq_true _ (Classical.dec _) ⟨x1, hs0pin⟩
  refine ⟨τ, hτmark, hτpin, h31, ?_⟩
  intro s hzcase
  rcases hzcase with hzs | hzs | hzs
  · -- GAP zone (step 3, both inclusions)
    cases hσbit : σ.2 s with
    | true =>
      -- σ ⊆ σ★: hocc places the listed item in (t, x1); the C8(c) upgrade pins it
      have hmem : s ∈ kvE_fiberZoneList σ kvE_futGapZone :=
        (kvE_fiberZoneList_mem σ kvE_futGapZone s).mpr ⟨hσbit, hzs⟩
      obtain ⟨r, hr1, hr2, hshift⟩ := hocc s hmem
      rw [kvE_futItemShift_correct P s M h_UZ h_SZ r] at hshift
      have hpin := kvE_futGapItem_pinned_zero M r x1 w x t hxw hwt hr1 hr2
        τ.1 hτA s (honfib s hσbit) hzs hshift
      rw [hτ2]
      exact @decide_eq_true _ (Classical.dec _) ⟨r, hpin⟩
    | false =>
      -- σ★ ⊆ σ: a pinned witness z ∈ (t, x1) meets hgap's listed item; uniqueness
      cases hτbit : τ.2 s with
      | false => rfl
      | true =>
        exfalso
        rw [hτ2] at hτbit
        obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) hτbit
        have hzone := kvE_futZoneHolds_of_atom M
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) z s hz
        rw [hzs] at hzone
        have hzx1 : z < x1 := (hzone 0).1.mpr rfl
        have htz : t < z := (hzone ⟨3, by omega⟩).2.mpr rfl
        have hD := hgap z htz hzx1
        rw [kvE_futGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ z] at hD
        obtain ⟨s', hmem', env', hev'⟩ := hD
        obtain ⟨hbit', hzs'⟩ := (kvE_fiberZoneList_mem σ kvE_futGapZone s').mp hmem'
        have hpin' := kvE_futGapItem_pinned_zero M z x1 w x t hxw hwt htz hzx1
          τ.1 hτA s' (honfib s' hbit') hzs' ⟨env', hev'⟩
        have hss' : s' = s := nf_eval_unique M 0 5
          (Fin.cons z (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s' s hpin' hz
        rw [hss', hσbit] at hbit'
        exact Bool.noConfusion hbit'
  · -- RAY zone (step 4, both directions)
    cases hσbit : σ.2 s with
    | true =>
      -- σ ⊆ σ★: hend's per-item ray conjunct places s above x1; the C8(c) upgrade pins it
      have hmem : s ∈ kvE_fiberZoneList σ kvE_futRayZone :=
        (kvE_fiberZoneList_mem σ kvE_futRayZone s).mpr ⟨hσbit, hzs⟩
      have hitem := hrayC (Formula.untl (kvE_futItemShift P s) Formula.top)
        (List.mem_cons_of_mem _ (List.mem_map.mpr ⟨s, hmem, rfl⟩))
      obtain ⟨v, hx1v, hsh, -⟩ := hitem
      rw [kvE_futItemShift_correct P s M h_UZ h_SZ v] at hsh
      have hpin := kvE_futRayItem_pinned_zero M v x1 w x t hxw hwt htx1 hx1v
        τ.1 hτA s (honfib s hσbit) hzs hsh
      rw [hτ2]
      exact @decide_eq_true _ (Classical.dec _) ⟨v, hpin⟩
    | false =>
      -- σ★ ⊆ σ: hend's ¬F(¬D_ray) conjunct covers the pinned witness z > x1; uniqueness
      cases hτbit : τ.2 s with
      | false => rfl
      | true =>
        exfalso
        rw [hτ2] at hτbit
        obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) hτbit
        have hzone := kvE_futZoneHolds_of_atom M
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) z s hz
        rw [hzs] at hzone
        have hx1z : x1 < z := (hzone 0).2.mpr rfl
        have hnf := hrayC (Formula.untl (kvE_futRayD P σ).neg Formula.top).neg (by simp)
        rw [temporal_truth_neg] at hnf
        have hDz : temporal_truth M atomMap z (kvE_futRayD P σ) := by
          by_contra hnD
          exact hnf ⟨z, hx1z, (temporal_truth_neg M atomMap z _).mpr hnD,
            fun r _ _ => id⟩
        rw [kvE_futRayD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ z] at hDz
        obtain ⟨s', hmem', env', hev'⟩ := hDz
        obtain ⟨hbit', hzs'⟩ := (kvE_fiberZoneList_mem σ kvE_futRayZone s').mp hmem'
        have hpin' := kvE_futRayItem_pinned_zero M z x1 w x t hxw hwt htx1 hx1z
          τ.1 hτA s' (honfib s' hbit') hzs' ⟨env', hev'⟩
        have hss' : s' = s := nf_eval_unique M 0 5
          (Fin.cons z (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s' s hpin' hz
        rw [hss', hσbit] at hbit'
        exact Bool.noConfusion hbit'
  · -- SELF zone (step 5)
    cases hσbit : σ.2 s with
    | true =>
      -- admissibility conjunct 4: one self profile ⇒ s IS the delivered s0 (lossless split)
      have hdS := kvE_futAdmissible_onFiber σ hadm s hσbit
      have hdS0 := kvE_futAdmissible_onFiber σ hadm s0 hbit0
      have hadm' := hadm
      unfold kvE_futAdmissible at hadm'
      rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hadm'
      have hc4 := hadm'.2
      have hbitS : kvE_subBit σ kvE_futSelfZone (nfk_projFresh s) = true := by
        refine List.any_eq_true.mpr ⟨s, Finset.mem_toList.mpr (Finset.mem_univ s), ?_⟩
        rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
        exact ⟨⟨⟨decide_eq_true hdS, decide_eq_true hzs⟩, decide_eq_true rfl⟩, hσbit⟩
      have hbitS0 : kvE_subBit σ kvE_futSelfZone (nfk_projFresh s0) = true := by
        refine List.any_eq_true.mpr ⟨s0, Finset.mem_toList.mpr (Finset.mem_univ s0), ?_⟩
        rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
        exact ⟨⟨⟨decide_eq_true hdS0, decide_eq_true hzs0⟩, decide_eq_true rfl⟩, hbit0⟩
      have hχ : nfk_projFresh s = nfk_projFresh s0 := by
        have h4 := (List.all_eq_true.mp hc4) (nfk_projFresh s)
          (Finset.mem_toList.mpr (Finset.mem_univ _))
        have h4' := (List.all_eq_true.mp h4) (nfk_projFresh s0)
          (Finset.mem_toList.mpr (Finset.mem_univ _))
        rw [Bool.or_eq_true, Bool.or_eq_true, hbitS, hbitS0] at h4'
        rcases h4' with (h | h) | h
        · exact absurd h (by decide)
        · exact absurd h (by decide)
        · exact of_decide_eq_true h
      have hs_eq : s = s0 := by
        have h1 : nf0_zoneSpec s = nf0_zoneSpec s0 := by
          have ha : nf0_zoneSpec s = kvE_futSelfZone := hzs
          have hb : nf0_zoneSpec s0 = kvE_futSelfZone := hzs0
          rw [ha, hb]
        have h2 : nf0_projFresh s = nf0_projFresh s0 := by
          rw [← kvE_projFresh_zero s, ← kvE_projFresh_zero s0]; exact hχ
        have h3 : nf0_dropFresh s = nf0_dropFresh s0 := by
          rw [honfib s hσbit, honfib s0 hbit0]
        calc s = nf0_assemble (nf0_zoneSpec s) (nf0_projFresh s) (nf0_dropFresh s) :=
              (nf0_split_assemble s).symm
          _ = nf0_assemble (nf0_zoneSpec s0) (nf0_projFresh s0) (nf0_dropFresh s0) := by
              rw [h1, h2, h3]
          _ = s0 := nf0_split_assemble s0
      rw [hs_eq]; exact hτs0
    | false =>
      -- σ★ ⊆ σ: a pinned self witness coincides with x1; uniqueness against s0
      cases hτbit : τ.2 s with
      | false => rfl
      | true =>
        exfalso
        rw [hτ2] at hτbit
        obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) hτbit
        have hzone := kvE_futZoneHolds_of_atom M
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) z s hz
        rw [hzs] at hzone
        have hzx1 : z = x1 := kvE_futSelfZone_coincide M hzone
        rw [hzx1] at hz
        have hss0 : s = s0 := nf_eval_unique M 0 5
          (Fin.cons x1 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s s0 hz hs0pin
        rw [hss0, hbit0] at hσbit
        exact Bool.noConfusion hσbit

/-! ### The reconstruction companion: slice uniqueness at m = 0 -/

/-- **m = 0 slice uniqueness** (report 02 §3.3 second signature; the
    internal-`hexclExt`-style discharge for the soundness direction): two σ's
    pinned-realized at (possibly different) exterior endpoints over the same `[w, x, t]`
    with equal exterior slices are EQUAL. Route: slice-equal atom layers give the two
    endpoints the same complete depth-0 atomic profile (`nf_eval_unique`); exterior-zone
    fiber bits agree by the slice hypothesis; interior fiber elements (witness `¬ t < v` by
    exterior-zone classification) transfer between profile-equal endpoints with the SAME
    witness (`kvE_futInteriorTransfer_zero`, probe P3), so the depth-1 fold biconditionals
    force every remaining bit to coincide. -/
theorem kvE_futSliceUnique_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (σ' σ : NormalForm sig 1 4)
    (w x t x1' x1 : M.carrier) (hxw : x < w) (hwt : w < t)
    (htx1' : t < x1') (htx1 : t < x1)
    (hslice : kvE_futSliceEq σ' σ = true)
    (hσ' : nf_eval_nf M 1 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ')
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    σ' = σ := by
  unfold kvE_futSliceEq at hslice
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hslice
  obtain ⟨⟨⟨h1d, hgapL⟩, hrayL⟩, hselfL⟩ := hslice
  have h1 : σ'.1 = σ.1 := of_decide_eq_true h1d
  have hgapL := of_decide_eq_true hgapL
  have hrayL := of_decide_eq_true hrayL
  have hselfL := of_decide_eq_true hselfL
  -- profile-equal endpoints: each side's atom layer is the other's endpoint characteristic
  have hσA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
    nf_eval_nf_atom_layer M _ σ hσ
  have hσ'A : nf_eval_nf M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ'.1 :=
    nf_eval_nf_atom_layer M _ σ' hσ'
  have hσ1c : σ.1 =
      nf_characteristic M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) :=
    nf_eval_unique M 0 4 _ _ _ hσA (nf_characteristic_satisfies M 0 4 _)
  have hσ'1c : σ'.1 =
      nf_characteristic M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) :=
    nf_eval_unique M 0 4 _ _ _ hσ'A (nf_characteristic_satisfies M 0 4 _)
  have hchar : nf_eval_nf M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf_characteristic M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) := by
    rw [← hσ1c, ← h1]; exact hσ'A
  have hchar' : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf_characteristic M 0 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t))))) := by
    rw [← hσ'1c, h1]; exact hσA
  refine Prod.ext h1 ?_
  funext s
  by_cases hzc : nfk_zoneSpec s = kvE_futGapZone ∨ nfk_zoneSpec s = kvE_futRayZone ∨
      nfk_zoneSpec s = kvE_futSelfZone
  · -- exterior zones: the slice hypothesis decides the bit through zone-list membership
    have key : ∀ z : ZoneSpec 4,
        kvE_fiberZoneList σ' z = kvE_fiberZoneList σ z → nfk_zoneSpec s = z →
        σ'.2 s = σ.2 s := by
      intro z hL hz
      cases hb : σ.2 s with
      | true =>
        have hmem : s ∈ kvE_fiberZoneList σ z := (kvE_fiberZoneList_mem σ z s).mpr ⟨hb, hz⟩
        rw [← hL] at hmem
        exact ((kvE_fiberZoneList_mem σ' z s).mp hmem).1
      | false =>
        cases hb' : σ'.2 s with
        | false => rfl
        | true =>
          have hmem : s ∈ kvE_fiberZoneList σ' z :=
            (kvE_fiberZoneList_mem σ' z s).mpr ⟨hb', hz⟩
          rw [hL] at hmem
          have hbit := ((kvE_fiberZoneList_mem σ z s).mp hmem).1
          rw [hb] at hbit
          exact absurd hbit Bool.false_ne_true
    rcases hzc with hz | hz | hz
    · exact key kvE_futGapZone hgapL hz
    · exact key kvE_futRayZone hrayL hz
    · exact key kvE_futSelfZone hselfL hz
  · -- interior: same-witness transfer between the profile-equal endpoints
    have hfold := hσ.2 s
    have hfold' := hσ'.2 s
    cases hb : σ.2 s with
    | true =>
      obtain ⟨v, hv⟩ := hfold.mpr hb
      have hzone := kvE_futZoneHolds_of_atom M
        (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) v s hv
      have hvt : ¬ t < v := fun htv =>
        hzc (kvE_futZoneSpec_of_above M v x1 w x t hxw hwt htv _ hzone)
      exact hfold'.mp
        ⟨v, kvE_futInteriorTransfer_zero M v x1 x1' w x t hvt htx1 htx1' hchar s hv⟩
    | false =>
      cases hb' : σ'.2 s with
      | false => rfl
      | true =>
        obtain ⟨v, hv'⟩ := hfold'.mpr hb'
        have hzone := kvE_futZoneHolds_of_atom M
          (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) v s hv'
        have hvt : ¬ t < v := fun htv =>
          hzc (kvE_futZoneSpec_of_above M v x1' w x t hxw hwt htv _ hzone)
        have hbit := hfold.mp
          ⟨v, kvE_futInteriorTransfer_zero M v x1' x1 w x t hvt htx1' htx1 hchar' s hv'⟩
        rw [hb] at hbit
        exact absurd hbit Bool.false_ne_true

/-! ### Phase 5 — the m=0 supply theorems for the slice-keyed exterior interface (Future)

The task-360 plan-v2 Phase-5 discharges of the carried exterior obligations that task 358's
`KampPrior.lean:361` arm and task 349 v8 Phase 6 consume through
`EndIntervalCorrectPrior`'s `m + 2` arm (EndIntervalConsumerK.lean:139-164) at `m := 0`.
Statements are the 3b binder types at `k := 0`, signature-locked (copied verbatim from
EndIntervalConsumerK), plus the AMBIENT interior obligation `hreal` — itself a carried binder
of the same consumer arm, available verbatim at every consumption site — which the
`hexclSlice*` route consumes per report 02 §3.4 (last paragraph).

The four v1 `kvE_hbr*_supply_zero` targets are ELIMINATED, not superseded here: the two
guarded Sat-halves are provably FALSE — the (σ′, e) witness satisfies every guard antecedent
verbatim (`kvE_futPinned_of_end_zero_refuted` above) — and the Real halves left with the
per-σ-keyed interface. Do not resurrect them.

**Status note (Phase-5 dispatch, 2026-07-14; RESOLVED by Phase 3c, report 04)**: the two
`hexclSlice*` discharges landed first (binder text UNCHANGED by the Phase-3c fiber re-key —
report 04 §5). The two `hslice*` discharges were initially BLOCKED: the slice-id's fiber
input `nfk_dropFresh σ = qnf.1` was underivable because the Phase-3b bracket range had been
silently WIDENED past the frozen k=2 template's fiber conjunct (ℤ-doppelgänger countermodel,
plan v2 Phase-5 BLOCKER record). The Phase-3c fiber-range re-key
(ExteriorBracketAssembleK/ExteriorGateAssembleK) restored the filter and FIBER-guarded the
`hslice*` binders; `kvE_hsliceFut_supply_zero` below now closes by the originally prescribed
route with `hfib` binder-supplied (the Phase-5 dispatch's Probe A, green end-to-end). -/

/-- **m=0 supply for the carried `hexclSliceFut` obligation** (task 360 plan v2 Phase 5;
    the ⇒-side per-σ exclusion residue of `bracketEndChar_kvExt_correct_prior` /
    `EndIntervalCorrectPrior`, binder text verbatim at `k := 0`): given the interior
    obligation `hreal` ("marked ⇒ realizable", the SAME carried binder of the consumer arm),
    a bit-false-but-slice-MARKED admissible σ has NO strictly-exterior realizer.

    Route (report 02 §3.4 + Phase-3b handoff): the slice marking delivers an admissible
    marked mate σ″; `hreal` realizes σ″ at some endpoint; the endpoint is exterior by the
    admissibility zone marking read back through the realization (the
    `ExteriorGateAssembleK` D3-feed pattern); `kvE_futSliceUnique_zero` collapses σ″ = σ;
    the bit split `qnf.2 σ = false` vs `qnf.2 σ″ = true` is absurd.

    (The `kvE_futSliceMarked` unpacking inlines `kvE_futSliceMarked_iff`'s body — that
    lemma lives in ExteriorBracketAssembleK, DOWNSTREAM of this file; replication
    precedent.) H4: the refutation witness σ′ is pinned-unrealizable (probe P1), so it
    satisfies this statement vacuously — unlike the eliminated `hbrFutSat` shape. -/
theorem kvE_hexclSliceFut_supply_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3)
    (x t : M.carrier)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF 1) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF 1) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
        kvE_futSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, t < x1 →
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro w hxw hwt hptW σ hadm hbit hsm x1 htx1 hnf
  -- unpack the slice marking (kvE_futSliceMarked_iff body inlined; see docstring)
  rw [kvE_futSliceMarked, List.any_eq_true] at hsm
  obtain ⟨σ'', -, htriple⟩ := hsm
  rw [Bool.and_eq_true, Bool.and_eq_true] at htriple
  obtain ⟨⟨hadm'', hslEq⟩, hmark⟩ := htriple
  -- the marked mate is realizable via the interior obligation
  obtain ⟨x1'', hσ''⟩ := hreal w hxw hwt hptW σ'' hmark
  -- its endpoint is exterior: admissibility zone marking read back through the realization
  have hzone : nf0_zoneSpec σ''.1 = kvE2_sep_zFutT3 := by
    have hh := hadm''
    rw [kvE_futAdmissible] at hh
    simp only [Bool.and_eq_true] at hh
    exact of_decide_eq_true hh.1.1.1
  have hb2 : (nf0_zoneSpec σ''.1 ⟨2, by omega⟩).2 = true := by rw [hzone]; rfl
  have h2 := hσ''.1 (.order (Fin.succ ⟨2, by omega⟩) 0 (Fin.succ_ne_zero ⟨2, by omega⟩))
  simp only [atom_eval, Fin.cons] at h2
  have htx1'' : t < x1'' := h2.mpr hb2
  -- uniqueness collapses the mate onto σ — contradicting the bit split
  have heq : σ'' = σ :=
    kvE_futSliceUnique_zero M σ'' σ w x t x1'' x1 hxw hwt htx1'' htx1 hslEq hσ'' hnf
  rw [heq, hbit] at hmark
  exact Bool.noConfusion hmark

/-- **m=0 supply for the carried `hsliceFut` obligation** (task 360 plan v2 Phase 5, under
    the Phase-3c fiber-guarded interface; the ⇐-side slice-honesty input of
    `bracketEndChar_kvExt_correct_prior` / `EndIntervalCorrectPrior`, binder text verbatim at
    `k := 0`): chain-fire truth `kvE_futPos P σ` at `t` for a fiber-compatible admissible σ
    under the honest ambient yields an admissible, slice-equal, qnf-MARKED mate.

    Route (report 02 §3.4 + §5 row 2; the Phase-5 dispatch's Probe A, with `hfib` now
    binder-supplied by the Phase-3c re-key): destruct the Cor 5.4 chain
    (`kvE_futChainDestructG`, the `kvE_extNegFut_complete` destructor pattern at `k := 0`) to
    an exterior endpoint `x1 > t` with `hend`/`hgap`/`hocc`; apply the slice identification
    `kvE_futSliceId_of_end_zero`; the identified σ' is admissible via
    `kvE_futRealizer_admissible` on its pinned realizer and slice-equal via
    `kvE_fiberZoneList_congr` on the three exterior zones. H4: the refutation witness σ′ is
    handled as always (σ' := τ satisfies the conclusion); the ℤ-doppelgänger σ is OFF-fiber,
    hence outside the binder's antecedents. -/
theorem kvE_hsliceFut_supply_zero {sig : MonadicSignature}
    {atomMap : Formula → sig.preds}
    (P : ExistProviders sig atomMap 0)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig 2 3)
    (x t : M.carrier) :
    ∀ w : M.carrier, x < w → w < t →
      nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig 1 4, kvE_futAdmissible σ = true →
        nfk_dropFresh σ = qnf.1 →
        temporal_truth M atomMap t (kvE_futPos P σ) →
        ∃ σ' : NormalForm sig 1 4, kvE_futAdmissible σ' = true ∧
          kvE_futSliceEq σ' σ = true ∧ qnf.2 σ' = true := by
  intro w hxw hwt h σ hadm hfib hposT
  -- destruct the Cor 5.4 chain (the `kvE_extNegFut_complete` destructor pattern at k = 0)
  rw [kvE_futPos, if_pos hadm, formula_disjList_iff] at hposT
  obtain ⟨φ, hφmem, hφ⟩ := hposT
  obtain ⟨l, hlmem, rfl⟩ := List.mem_map.mp hφmem
  have hlperm : l.Perm (kvE_fiberZoneList σ kvE_futGapZone) :=
    List.mem_permutations.mp hlmem
  -- item ⇒ gap guard: each chain item is a gap fiber sub, so it enters the gap disjunction
  have himp : ∀ a ∈ l, ∀ r : M.carrier,
      temporal_truth M atomMap r (kvE_futItemShift P a) →
      temporal_truth M atomMap r (kvE_futGapD P σ) := by
    intro a ha r hr
    have hamem : a ∈ kvE_fiberZoneList σ kvE_futGapZone := hlperm.subset ha
    rw [kvE_futGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ r]
    rw [kvE_futItemShift_correct P a M h_UZ h_SZ r] at hr
    obtain ⟨env, hev⟩ := hr
    exact ⟨a, hamem, env, hev⟩
  obtain ⟨x1, htx1, hend, hgap, hocc⟩ :=
    kvE_futChainDestructG M atomMap (kvE_futItemShift P) (kvE_futEnd P σ)
      (kvE_futGapD P σ) l t himp hφ
  have hoccZ : ∀ a ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
      t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P a) :=
    fun a ha => hocc a (hlperm.mem_iff.mpr ha)
  -- slice identification at the destructor endpoint (hfib is binder-supplied — Phase 3c)
  obtain ⟨σ', hmark, hpin, h1, h2⟩ :=
    kvE_futSliceId_of_end_zero P M h_UZ h_SZ qnf σ hadm hfib w x t hxw hwt h x1 htx1
      hend hgap hoccZ
  -- admissibility from the pinned realizer; slice equality from atom + zone-list congruence
  have hadm' : kvE_futAdmissible σ' = true :=
    kvE_futRealizer_admissible M σ' x1 w x t hxw hwt htx1 hpin
  have hgapL := kvE_fiberZoneList_congr σ σ' kvE_futGapZone
    (fun s hz => h2 s (Or.inl hz))
  have hrayL := kvE_fiberZoneList_congr σ σ' kvE_futRayZone
    (fun s hz => h2 s (Or.inr (Or.inl hz)))
  have hselfL := kvE_fiberZoneList_congr σ σ' kvE_futSelfZone
    (fun s hz => h2 s (Or.inr (Or.inr hz)))
  have hslEq : kvE_futSliceEq σ' σ = true := by
    rw [kvE_futSliceEq, decide_eq_true h1, decide_eq_true hgapL, decide_eq_true hrayL,
      decide_eq_true hselfL]
    rfl
  exact ⟨σ', hadm', hslEq, hmark⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
