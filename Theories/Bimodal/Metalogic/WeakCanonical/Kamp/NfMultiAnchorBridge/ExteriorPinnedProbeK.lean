import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK

/-! # Pinned-converse machine-probe gate (task 360, Phase 0 — GO/NO-GO)

Machine-adjudicates the two Medium-confidence claims of report
`specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/03_pinned-converse-adjudication.md`
§6 (rows C3/C8) BEFORE any construction phase of task 360, per the plan's Phase-0 mandate.

**Probe conventions**: `P3M = (ℤ, <)`, `P = {0, 10, 20}` (template copy of the established
`P2M` probe model, ExteriorFiberProbeK.lean:61). Concrete anchor instance
`[x1, w, x, t] = [25, 15, 2, 18]` (so `x < w < t < x1` and the walk gap `(t, x1) = (18, 25)`
contains the `P`-point `20`).

## C8 — positive m=0 route (GATES the plan). VERDICT: **GO**

The three identification ingredients of report 03 §2.3 at `m = 0`
(`σ : NormalForm sig 1 4`, fibers `NormalForm sig 0 5`), each compiled sorry-free:

- **(a)** `kvE_probe_selfZone_coincide` — self-zone coupling `(false, false)`
  (`kvE_futSelfZone`) forces fresh/`x1` COINCIDENCE on any linear order (abstract, any
  `OrderedMonadicStructure`): the endpoint's self content speaks about `x1` itself.
- **(b)** `kvE_probe_endpoint_totality` — the endpoint characteristic
  `τ := nf_characteristic P3M 1 4 [x1,w,x,t]` is pinned-realized
  (`nf_characteristic_satisfies`) AND marked by the honest level-up ambient
  `qnf := nf_characteristic P3M 2 3 [w,x,t]` (the `(h.2 τ).mp` step of the converse).
- **(c)** `kvE_probe_gapItem_pinned` / `kvE_probe_rayItem_pinned` — the depth-0
  identification mechanism: a FREE-env occurrence (exactly what `kvE_futItemShift_correct`
  / `hocc` / the ray conjuncts deliver) of an on-fiber, zone-classified depth-0 fiber
  element at a walk point `r ∈ (t, x1)` (gap) or `r > x1` (ray) UPGRADES to PINNED
  realization at `[r, x1, w, x, t]` — via the lossless three-channel factorization
  `nf_eval_nf0_cons_factor`: the zone spec re-renders against the actual anchors
  (`kvE_futZone4_of_above`), the fresh profile transports verbatim, and the on-fiber
  condition (`nf0_dropFresh s = σ.1`) + the pinned atom layer supply the env-restriction
  channel. At depth 0 the fiber element IS its atom assignment, so this closes the full
  datum — the reason the m=0 instance needs no level descent (report 03 §2.3 item 3).
- **(c′)** `kvE_probe_marking_separated` — separation contrast: the marking variant
  `σ′ := τ` with the `P`-gap fiber element `e* := nf_characteristic P3M 0 5 [20,25,15,2,18]`
  UNMARKED fails the destructor gap fact at the walk point `20` (`kvE_futGapD P σ′` is
  FALSE at `20` under the concrete depth-0 provider): at m=0 the hypothesis set
  `hend`/`hgap`/`hocc` provably separates marking variants on the probe instance — the
  exact separation that FAILS at fiber depth m ≥ 1 (C3 below).

## C3 — m=1 countermodel attempt vs the ambient-free guarded binder (informative).
## VERDICT: **B (unconfirmed at binder level; core ambiguity pair compiled)**

`kvE_probe_c3_pair` compiles the marking-ambiguity CORE at the m=1 fiber type
(`NormalForm sig 1 5`): a pair `s ≠ s′` differing ONLY in a depth-0 marking (`s′` unmarks
the inner element `char [20, 22, 25, 15, 2, 18]`), on which EVERY atom-layer navigation
channel agrees (`s.1 = s′.1`, hence shared `nfk_zoneSpec` and fresh profile), while pinned
realization at `[22, 25, 15, 2, 18]` holds for `s` and FAILS for `s′`. The full
binder-level countermodel (both σ, σ′ passing the guarded `hend` truth semantically)
could not be assembled within the fixed probe budget: stating `kvE_futEnd P σ` at m=1
requires a concrete depth-1 `ExistProviders` instance, and none exists in-tree (that is
task 358's open recursion). Per the plan's settled decision 1, the ambient antecedent is
included REGARDLESS of this verdict; the compiled core documents the mechanism the
ambient is there to close.

Purely additive NEW leaf module; probe-local (`private`) machinery; no production file
touched (Phase 0 makes zero production edits). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Probe signature and model (template copies of the `p2*` conventions,
ExteriorFiberProbeK.lean:48-116) -/

/-- One-predicate signature for the probe (`()` names the single monadic predicate `P`). -/
private abbrev p3sig : MonadicSignature := { preds := Unit }

/-- Trivial atom map into the one-predicate probe signature. -/
private abbrev p3atomMap : Formula → p3sig.preds := fun _ => ()

/-- Surjectivity of the probe atom map (every predicate is hit by an atom). -/
private theorem p3surj : ∀ p : p3sig.preds, ∃ a : Atom, p3atomMap (.atom a) = p :=
  fun _ => ⟨Atom.mk_base "P", rfl⟩

/-- The probe model `M* = (ℤ, <)` with `P = {0, 10, 20}` (template copy of `P2M`). -/
private abbrev P3M : OrderedMonadicStructure p3sig where
  carrier := ℤ
  interp := fun _ z => z = 0 ∨ z = 10 ∨ z = 20
  carrier_order := inferInstance

/-- `ℤ` first-occurrence principle (template copy of `p2_int_first`). -/
private theorem p3_int_first {Q : ℤ → Prop} (t : ℤ) (h : ∃ s, t < s ∧ Q s) :
    ∃ s, t < s ∧ Q s ∧ ∀ r, t < r → r < s → ¬ Q r := by
  classical
  obtain ⟨s, hts, hs⟩ := h
  have hP : ∃ n : ℕ, Q (t + 1 + (n : ℤ)) := by
    refine ⟨(s - t - 1).toNat, ?_⟩
    have hcast : t + 1 + (((s - t - 1).toNat : ℕ) : ℤ) = s := by omega
    rw [hcast]; exact hs
  refine ⟨t + 1 + (Nat.find hP : ℤ), by omega, Nat.find_spec hP, ?_⟩
  intro r htr hrs h_r
  have hm : ∃ m : ℕ, r = t + 1 + (m : ℤ) ∧ m < Nat.find hP :=
    ⟨(r - t - 1).toNat, by omega, by omega⟩
  obtain ⟨m, hmr, hmlt⟩ := hm
  exact Nat.find_min hP hmlt (hmr ▸ h_r)

/-- `ℤ` last-occurrence principle (template copy of `p2_int_last`). -/
private theorem p3_int_last {Q : ℤ → Prop} (t : ℤ) (h : ∃ s, s < t ∧ Q s) :
    ∃ s, s < t ∧ Q s ∧ ∀ r, s < r → r < t → ¬ Q r := by
  classical
  obtain ⟨s, hst, hs⟩ := h
  have hP : ∃ n : ℕ, Q (t - 1 - (n : ℤ)) := by
    refine ⟨(t - s - 1).toNat, ?_⟩
    have hcast : t - 1 - (((t - s - 1).toNat : ℕ) : ℤ) = s := by omega
    rw [hcast]; exact hs
  refine ⟨t - 1 - (Nat.find hP : ℤ), by omega, Nat.find_spec hP, ?_⟩
  intro r hsr hrt h_r
  have hm : ∃ m : ℕ, r = t - 1 - (m : ℤ) ∧ m < Nat.find hP :=
    ⟨(t - r - 1).toNat, by omega, by omega⟩
  obtain ⟨m, hmr, hmlt⟩ := hm
  exact Nat.find_min hP hmlt (hmr ▸ h_r)

/-- `(ℤ, <)` satisfies semantic Prior-UZ (template copy of `p2_UZ`). -/
private theorem p3_UZ : semantic_prior_UZ P3M p3atomMap := by
  intro t ψ h
  obtain ⟨s, hts, hs, hmin⟩ :=
    p3_int_first (Q := fun z => temporal_truth P3M p3atomMap z ψ) t h
  refine ⟨s, hts, hs, ?_⟩
  intro r htr hrs
  simp only [Formula.neg, temporal_truth]
  exact hmin r htr hrs

/-- `(ℤ, <)` satisfies semantic Prior-SZ (template copy of `p2_SZ`). -/
private theorem p3_SZ : semantic_prior_SZ P3M p3atomMap := by
  intro t ψ h
  obtain ⟨s, hst, hs, hmax⟩ :=
    p3_int_last (Q := fun z => temporal_truth P3M p3atomMap z ψ) t h
  refine ⟨s, hst, hs, ?_⟩
  intro r hsr hrt
  simp only [Formula.neg, temporal_truth]
  exact hmax r hsr hrt

/-! ## Concrete anchor instance and endpoint/ambient characteristics -/

/-- Probe anchor environment `[w, x, t] = [15, 2, 18]`. -/
private def p3env3 : Fin 3 → P3M.carrier := Fin.cons 15 (Fin.cons 2 (fun _ => 18))

/-- Probe 4-anchor environment `[x1, w, x, t] = [25, 15, 2, 18]` (exterior endpoint
    `x1 = 25 > t = 18`; walk gap `(18, 25)` contains the `P`-point `20`). -/
private def p3env4 : Fin 4 → P3M.carrier := Fin.cons 25 p3env3

/-- The honest level-up ambient: the depth-2 characteristic 3-type of `[w, x, t]`. -/
private noncomputable def p3qnf : NormalForm p3sig 2 3 := nf_characteristic P3M 2 3 p3env3

/-- The endpoint characteristic `τ`: the depth-1 arity-4 type of `[x1, w, x, t]`
    (report 03 §2.3 ingredient 1, `m = 0`). -/
private noncomputable def p3tau : NormalForm p3sig 1 4 := nf_characteristic P3M 1 4 p3env4

/-- Unfold: the quant layer of the ambient is the realized-sub `decide`. -/
private theorem p3qnf_snd (σ : NormalForm p3sig 1 4) :
    p3qnf.2 σ =
      @decide (∃ u : ℤ, nf_eval_nf P3M 1 4 (Fin.cons u p3env3) σ)
        (Classical.dec _) := rfl

/-- Unfold: the quant layer of `τ` is the realized-entry `decide` over depth-0
    arity-5 fiber elements. -/
private theorem p3tau_snd (e : NormalForm p3sig 0 5) :
    p3tau.2 e =
      @decide (∃ z : ℤ, nf_eval_nf P3M 0 5 (Fin.cons z p3env4) e)
        (Classical.dec _) := rfl

/-! ## Concrete depth-0 provider instance (template copy of `p2P`) -/

/-- Concrete provider instance for the probe signature at depth `0`
    (the landed sorry-free depth-0 all-arity converter, NfDepth0Generalized.lean). -/
private noncomputable def p3P : ExistProviders p3sig p3atomMap 0 where
  existF := fun n sub => nf_nvar_exist_depth0_tl_fn p3atomMap p3surj n sub
  correct := fun n sub M _h_UZ _h_SZ t =>
    nf_nvar_exist_depth0_tl_fn_correct p3atomMap p3surj n sub M t

/-! ## C8 ingredient (a): self-zone coincidence (abstract) -/

/-- **C8(a)**: the self-zone head coupling `(false, false)` (`kvE_futSelfZone`) forces
    fresh/`x1` COINCIDENCE on any linear order: a point in the self zone relative to
    `[x1, w, x, t]` IS `x1`. Abstract over any `OrderedMonadicStructure` (stronger than the
    concrete-instance mandate); pure `lt_trichotomy` on the index-0 coupling. -/
theorem kvE_probe_selfZone_coincide {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      kvE_futSelfZone v) :
    v = x1 := by
  have h0 := hz ⟨0, by omega⟩
  rcases lt_trichotomy v x1 with h | h | h
  · exact absurd (h0.1.mp h) Bool.false_ne_true
  · exact h
  · exact absurd (h0.2.mp h) Bool.false_ne_true

/-! ## C8 ingredient (b): endpoint complete-type totality + ambient marking -/

/-- The honest ambient is realized at the actual anchors (`F0(z0)` in Rabinovich's ⇐). -/
private theorem p3_ambient : nf_eval_nf P3M 2 3 p3env3 p3qnf :=
  nf_characteristic_satisfies P3M 2 3 p3env3

/-- `τ` is pinned-realized at `[x1, w, x, t]` (complete-type totality,
    `nf_characteristic_satisfies` — report 03 §2.3 ingredient 1). -/
private theorem p3_tau_pinned : nf_eval_nf P3M 1 4 p3env4 p3tau :=
  nf_characteristic_satisfies P3M 1 4 p3env4

/-- `τ` is marked by the honest ambient (the `(h.2 τ).mp` step — report 03 §2.3
    ingredient 2), witness `u := x1 = 25`. -/
private theorem p3_tau_marked : p3qnf.2 p3tau = true := by
  rw [p3qnf_snd]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨25, nf_characteristic_satisfies P3M 1 4 (Fin.cons 25 p3env3)⟩

/-- **C8(b)**: the endpoint characteristic `τ = nf_characteristic P3M 1 4 [25,15,2,18]`
    is pinned-realized AND marked by the honest level-up ambient
    `qnf = nf_characteristic P3M 2 3 [15,2,18]` — both halves of the totality+marking
    ingredient, compiled on the concrete probe instance. -/
theorem kvE_probe_endpoint_totality :
    nf_eval_nf P3M 1 4 p3env4 p3tau ∧ p3qnf.2 p3tau = true :=
  ⟨p3_tau_pinned, p3_tau_marked⟩

/-! ## C8 ingredient (c): the depth-0 free-env → pinned upgrade -/

/-- **C8(c), gap case**: a FREE-env occurrence (the exact shape `hocc` /
    `kvE_futItemShift_correct` delivers) of an on-fiber (`nf0_dropFresh s = τ.1`),
    gap-zoned depth-0 fiber element at a walk point `r ∈ (t, x1) = (18, 25)` upgrades to
    PINNED realization at `[r, x1, w, x, t]`. Three-channel factorization
    (`nf_eval_nf0_cons_factor`): the fresh profile transports verbatim; the zone spec
    re-renders against the actual anchors (`kvE_futZone4_of_above`, `r` in the pinned walk
    interval); the on-fiber condition + pinned atom layer supply the env restriction. -/
theorem kvE_probe_gapItem_pinned (s : NormalForm p3sig 0 5) (r : ℤ)
    (hr1 : (18 : ℤ) < r) (hr2 : r < 25)
    (hfib : nf0_dropFresh s = p3tau.1)
    (hzone : nf0_zoneSpec s = kvE_futGapZone)
    (hocc : ∃ env : Fin 4 → ℤ, nf_eval_nf P3M 0 5 (Fin.cons r env) s) :
    nf_eval_nf P3M 0 5 (Fin.cons r p3env4) s := by
  obtain ⟨env, hev⟩ := hocc
  have hfac := (nf_eval_nf0_cons_factor P3M env r s).mp hev
  refine (nf_eval_nf0_cons_factor P3M p3env4 r s).mpr ⟨?_, hfac.2.1, ?_⟩
  · rw [hzone]
    have h215 : (2 : ℤ) < 15 := by omega
    have h1518 : (15 : ℤ) < 18 := by omega
    have hn25r : ¬(25 : ℤ) < r := by omega
    exact kvE_futZone4_of_above P3M r 25 15 2 18 h215 h1518 hr1
      (true, false) (iff_of_true hr2 rfl) (iff_of_false hn25r Bool.false_ne_true)
  · rw [hfib]
    exact nf_eval_nf_atom_layer P3M p3env4 p3tau p3_tau_pinned

/-- **C8(c), ray case**: the same upgrade for a ray-zoned fiber element at `r > x1 = 25`
    (the shape `hend`'s exact-ray-content conjuncts deliver). -/
theorem kvE_probe_rayItem_pinned (s : NormalForm p3sig 0 5) (r : ℤ)
    (hr : (25 : ℤ) < r)
    (hfib : nf0_dropFresh s = p3tau.1)
    (hzone : nf0_zoneSpec s = kvE_futRayZone)
    (hocc : ∃ env : Fin 4 → ℤ, nf_eval_nf P3M 0 5 (Fin.cons r env) s) :
    nf_eval_nf P3M 0 5 (Fin.cons r p3env4) s := by
  obtain ⟨env, hev⟩ := hocc
  have hfac := (nf_eval_nf0_cons_factor P3M env r s).mp hev
  refine (nf_eval_nf0_cons_factor P3M p3env4 r s).mpr ⟨?_, hfac.2.1, ?_⟩
  · rw [hzone]
    have h215 : (2 : ℤ) < 15 := by omega
    have h1518 : (15 : ℤ) < 18 := by omega
    have h18r : (18 : ℤ) < r := by omega
    have hnr25 : ¬r < (25 : ℤ) := by omega
    exact kvE_futZone4_of_above P3M r 25 15 2 18 h215 h1518 h18r
      (false, true) (iff_of_false hnr25 Bool.false_ne_true) (iff_of_true hr rfl)
  · rw [hfib]
    exact nf_eval_nf_atom_layer P3M p3env4 p3tau p3_tau_pinned

/-! ## C8 ingredient (c′): the destructor facts separate marking variants at m = 0 -/

/-- The distinguishing `P`-gap fiber element `e* :=` the depth-0 5-type of
    `[20, 25, 15, 2, 18]` — "`P z` and `t < z < x1`". -/
private noncomputable def p3estar : NormalForm p3sig 0 5 :=
  nf_characteristic P3M 0 5 (Fin.cons 20 p3env4)

/-- `e*` is marked in `τ` (witness `z = 20`). -/
private theorem p3_estar_in_tau : p3tau.2 p3estar = true := by
  rw [p3tau_snd]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨20, nf_characteristic_satisfies P3M 0 5 (Fin.cons 20 p3env4)⟩

/-- The marking variant `σ′ := τ` with `e*` UNMARKED — the m=0 analog of the C3
    depth-`m` marking ambiguity. -/
private noncomputable def p3sigma' : NormalForm p3sig 1 4 :=
  (p3tau.1, fun e => if e = p3estar then false else p3tau.2 e)

/-- `σ′ ≠ τ` — they differ at `e*`. -/
private theorem p3_sigma'_ne_tau : p3sigma' ≠ p3tau := by
  intro h
  have hb : p3sigma'.2 p3estar = p3tau.2 p3estar := by rw [h]
  rw [show p3sigma'.2 p3estar =
      (if p3estar = p3estar then false else p3tau.2 p3estar) from rfl,
    if_pos rfl, p3_estar_in_tau] at hb
  exact Bool.noConfusion hb

/-- **C8(c′), separation contrast**: the marking variant `σ′` FAILS the destructor gap
    fact at the walk point `20` — `kvE_futGapD P σ′` is FALSE at `20` under the concrete
    depth-0 provider. Any listed gap element realized at `20` (free env) must carry the
    fresh `P`-bit (`P 20` holds), sit on the pinned atom fiber, and its pinned witness `z`
    must satisfy `P z ∧ 18 < z < 25`, forcing `z = 20` and hence the element to BE `e*` —
    which `σ′` unmarks. So at m = 0 the hypothesis set `hgap`/`hocc`/`hend` provably
    separates σ from its marking variants on the probe instance (the separation that fails
    at m ≥ 1, cf. `kvE_probe_c3_pair`). -/
theorem kvE_probe_marking_separated :
    ¬ temporal_truth P3M p3atomMap 20 (kvE_futGapD p3P p3sigma') := by
  rw [show kvE_futGapD p3P p3sigma' =
      kvE_fiberPosOnShift p3P (kvE_fiberZoneList p3sigma' kvE_futGapZone) from rfl,
    kvE_fiberPosOnShift_correct p3P _ P3M p3_UZ p3_SZ 20]
  rintro ⟨s, hmem, env, hev⟩
  obtain ⟨hbit, hzone⟩ := (kvE_fiberZoneList_mem p3sigma' kvE_futGapZone s).mp hmem
  by_cases hse : s = p3estar
  · rw [show p3sigma'.2 s = (if s = p3estar then false else p3tau.2 s) from rfl,
      if_pos hse] at hbit
    exact Bool.noConfusion hbit
  · have htau : p3tau.2 s = true := by
      rw [show p3sigma'.2 s = (if s = p3estar then false else p3tau.2 s) from rfl,
        if_neg hse] at hbit
      exact hbit
    rw [p3tau_snd] at htau
    obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) htau
    have hzone0 : nf0_zoneSpec s = kvE_futGapZone := hzone
    have hfacz := (nf_eval_nf0_cons_factor P3M p3env4 z s).mp hz
    have hfac20 := (nf_eval_nf0_cons_factor P3M env 20 s).mp hev
    have hzz : zoneHolds P3M p3env4 kvE_futGapZone z := hzone0 ▸ hfacz.1
    have hz25 : z < (25 : ℤ) := ((hzz (0 : Fin 4)).1).mpr rfl
    have h18z : (18 : ℤ) < z := ((hzz (3 : Fin 4)).2).mpr rfl
    have hb : nf0_projFresh s (.pred () 0) = true :=
      (hfac20.2.1 (.pred () 0)).mp (Or.inr (Or.inr rfl))
    have hPz : (z = 0 ∨ z = 10 ∨ z = 20) := (hfacz.2.1 (.pred () 0)).mpr hb
    have hz20 : z = 20 := by rcases hPz with h | h | h <;> omega
    rw [hz20] at hz
    exact hse (nf_eval_unique P3M 0 5 (Fin.cons 20 p3env4) s p3estar hz
      (nf_characteristic_satisfies P3M 0 5 (Fin.cons 20 p3env4)))

/-! ## C3 core: depth-1 fiber marking ambiguity (informative — does NOT gate) -/

/-- The m=1 fiber-type instance: the depth-1 arity-5 type of `[22, 25, 15, 2, 18]`
    (fresh gap point `22`, pinned anchor tail). -/
private noncomputable def p3s : NormalForm p3sig 1 5 :=
  nf_characteristic P3M 1 5 (Fin.cons 22 p3env4)

/-- The inner distinguishing element: the depth-0 6-type of `[20, 22, 25, 15, 2, 18]`
    ("`P u` and `t < u < fresh`"). -/
private noncomputable def p3edag : NormalForm p3sig 0 6 :=
  nf_characteristic P3M 0 6 (Fin.cons 20 (Fin.cons 22 p3env4))

/-- Unfold: the quant layer of `p3s` is the realized-entry `decide`. -/
private theorem p3s_snd (e : NormalForm p3sig 0 6) :
    p3s.2 e =
      @decide (∃ u : ℤ, nf_eval_nf P3M 0 6 (Fin.cons u (Fin.cons 22 p3env4)) e)
        (Classical.dec _) := rfl

/-- `e†` is marked in `p3s` (witness `u = 20`). -/
private theorem p3_edag_in_s : p3s.2 p3edag = true := by
  rw [p3s_snd]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨20, nf_characteristic_satisfies P3M 0 6 (Fin.cons 20 (Fin.cons 22 p3env4))⟩

/-- `p3s` with the inner element `e†` UNMARKED — a depth-1 (m=1 fiber) marking variant. -/
private noncomputable def p3s' : NormalForm p3sig 1 5 :=
  (p3s.1, fun e => if e = p3edag then false else p3s.2 e)

/-- `e†` is un-marked in `p3s'` (by construction). -/
private theorem p3_edag_not_in_s' : p3s'.2 p3edag = false := by
  rw [show p3s'.2 p3edag =
      (if p3edag = p3edag then false else p3s.2 p3edag) from rfl, if_pos rfl]

/-- **C3 core (informative)**: at the m=1 fiber type (`NormalForm sig 1 5`) a marking flip
    one depth level down is INVISIBLE to every atom-layer navigation channel — the pair
    `s ≠ s′` shares its full atom layer (hence zone spec and fresh profile) — while pinned
    realization at `[22, 25, 15, 2, 18]` separates them. This is the mechanism behind
    report 03 §6-C3 (the free-env ray/gap rendering cannot separate depth-`m ≥ 1` marking
    variants); the full binder-level countermodel needs a concrete depth-1 provider (none
    in-tree) and was not assembled within the probe budget. Ambient antecedent retained
    per settled decision 1 regardless. -/
theorem kvE_probe_c3_pair :
    p3s ≠ p3s' ∧ p3s.1 = p3s'.1 ∧ nfk_zoneSpec p3s = nfk_zoneSpec p3s' ∧
    nf_eval_nf P3M 1 5 (Fin.cons 22 p3env4) p3s ∧
    ¬ nf_eval_nf P3M 1 5 (Fin.cons 22 p3env4) p3s' := by
  refine ⟨?_, rfl, rfl, nf_characteristic_satisfies P3M 1 5 (Fin.cons 22 p3env4), ?_⟩
  · intro h
    have hb : p3s.2 p3edag = p3s'.2 p3edag := by rw [h]
    rw [p3_edag_in_s, p3_edag_not_in_s'] at hb
    exact Bool.noConfusion hb
  · intro h
    have heq : p3s' = p3s :=
      nf_eval_unique P3M 1 5 (Fin.cons 22 p3env4) p3s' p3s h
        (nf_characteristic_satisfies P3M 1 5 (Fin.cons 22 p3env4))
    have hb : p3s.2 p3edag = p3s'.2 p3edag := by rw [heq]
    rw [p3_edag_in_s, p3_edag_not_in_s'] at hb
    exact Bool.noConfusion hb

end Bimodal.Metalogic.WeakCanonical.Kamp
