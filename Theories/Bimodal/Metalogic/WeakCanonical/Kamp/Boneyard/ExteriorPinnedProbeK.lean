/-
ARCHIVED — off-faithful-path (Kamp Boneyard). MOVE-not-delete; do NOT delete or empty.

Retired from the live build ahead of the k>=2 E[Sigma] re-architecture. NOT on the
proof-term path from `completeness_discrete` (0 live importers; outside the Bimodal.lean
import closure, so uncompiled). Machine-checked pinned-probe evidence.
Do NOT consume or reuse for the faithful re-architecture: it targets the off-paper arity-4
object, which diverges from Rabinovich Def 4.1 (PDF p.5, atoms kept unary by expanding the
signature). Retained as machine-checked evidence only.

Key declarations: kvE_probe_selfZone_coincide, kvE_probe_endpoint_totality, kvE_probe_gapItem_pinned, kvE_probe_interior_transfer (and siblings)
-/
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedConverseK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Pinned-converse machine-probe gate (task 360, Phase 0 — GO/NO-GO)

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

#exit

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

/-! ## Phase 0b: slice-repair probes P1-P3 (task 360 v2 — plan 02, report 02 §7 rows C4/C8/C9)

Machine-adjudicates the three Medium-confidence claims of report
`specs/360_restate_exterior_hbr_pinned_converse/reports/02_faithful-pinned-converse-repair.md`
§7 BEFORE the Phase-3 slice construction (plan 02 hard gate):

- **P3 (C9)** `kvE_probe_interior_transfer` — the `kvE_futSliceUnique_zero` engine: a depth-0
  fiber element realized with an interior witness `v` (`¬ t < v`) over `[v, x1, w, x, t]`
  transfers to `[v, x1', w, x, t]` with the SAME witness, whenever `x1'` satisfies `x1`'s
  complete depth-0 4-type over `[w, x, t]`. Abstract over any `OrderedMonadicStructure`
  (the `kvE_probe_selfZone_coincide` precedent). Proved FIRST because P1 consumes it.
- **P1 (C4)** `kvE_probe_p1_erased_qnf_unmarked` — the refutation's marking variant σ′
  (`τ` with the interior element `e := char [w, x1, w, x, t] = char [15, 25, 15, 2, 18]`
  erased, verbatim the `kvE_futPinned_of_end_zero_refuted` construction on the P3M
  instance) is marked by NO honest ambient: `p3qnf.2 σ′ = false`. Any putative realizer
  `[u, 15, 2, 18]` carries `x1 = 25`'s complete atomic 4-type at `u`, so `e`'s witness
  `w = 15` transfers (P3) and the depth-1 fold forces the erased bit — contradiction.
  This closes report 02 §2 item 2 (the honest-bracket-unsatisfiability chain's only
  not-machine-run link).
- **P2 (C8)** `kvE_probe_p2_sliceId` — the slice-identification composite (report 02 §3.3
  route steps 1-5 chained) at the concrete instance: for EVERY admissible on-fiber σ
  satisfying the destructor facts `hend`/`hgap`/`hocc` at `[25, 15, 2, 18]`, the honest
  endpoint characteristic `σ★ := p3tau` is qnf-marked, pinned-realized, atom-layer-equal
  to σ, and agrees with σ's marking on every exterior-zone (gap/ray/self) fiber element.
  Suppliers: step 1 = probe (b); step 2 = Phase-2 `kvE_futAtomPinned_zero` + depth-0
  uniqueness; steps 3-4 = probe (c) upgrades + `hgap`/`hocc`/`hend` both inclusions;
  step 5 = admissibility conjunct 4 + `nf0_split_assemble` + self-zone coincidence.

Deviation note (recorded in the plan): consuming the Phase-2 supplier
`kvE_futAtomPinned_zero` requires importing `ExteriorPinnedConverseK` (leaf-safe: that
module does not import this probe file) — the ONE non-append edit of this phase. -/

open Bimodal.Metalogic.WeakCanonical.Separation (formula_conjList formula_conjList_iff)

/-! ### P3 (C9): depth-0 same-witness interior transfer -/

/-- **P3 (C9)** — the `kvE_futSliceUnique_zero` engine: a depth-0 arity-5 fiber element `s`
    realized at `[v, x1, w, x, t]` with an INTERIOR witness (`¬ t < v`) transfers to
    `[v, x1', w, x, t]` with the SAME witness `v`, provided `t < x1`, `t < x1'`, and `x1'`
    realizes `x1`'s complete depth-0 4-type over `[w, x, t]` (profile-equal endpoints).
    Three-channel rebuild (`nf_eval_nf0_cons_factor`): the fresh profile transports verbatim
    (same `v`); the tail 4-type is pinned to the characteristic (`nf_eval_unique`), which the
    profile-equal endpoint realizes by hypothesis; the zone channel changes only at index 0,
    where `v ≤ t < x1` and `v ≤ t < x1'` render the SAME coupling `(true, false)`. -/
theorem kvE_probe_interior_transfer {sig : MonadicSignature}
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

/-! ### P1 (C4): the refutation's erased variant is qnf-unmarked -/

/-- The refutation's erased INTERIOR element on the probe instance: the depth-0 5-type of
    `[w, x1, w, x, t] = [15, 25, 15, 2, 18]` (fresh witness `w` — zone `= w`, interior).
    Verbatim the `e` of `kvE_futPinned_of_end_zero_refuted` at the P3M anchors. -/
private noncomputable def p3eInt : NormalForm p3sig 0 5 :=
  nf_characteristic P3M 0 5 (Fin.cons 15 p3env4)

/-- The refutation's marking variant `σ′ := τ` with `p3eInt` UNMARKED — verbatim the `σ'`
    of `kvE_futPinned_of_end_zero_refuted` at the P3M anchors. -/
private noncomputable def p3sigmaR : NormalForm p3sig 1 4 :=
  (p3tau.1, fun s => if s = p3eInt then false else p3tau.2 s)

/-- **P1 (C4)**: the honest ambient does NOT mark the refutation's erased variant —
    `p3qnf.2 p3sigmaR = false`, i.e. σ′ is realizable at NO `[u, w, x, t]`. Any realizer's
    atom layer gives `u` the complete atomic 4-type of `x1 = 25` (in particular `18 < u`),
    so `p3eInt`'s honest witness `15` transfers to `[15, u, 15, 2, 18]` by the P3 engine,
    and the depth-1 fold biconditional forces `σ′.2 p3eInt = true` — contradicting the
    erasure. Report 02 §2 item 2, machine-run (closing H4 row C4). -/
theorem kvE_probe_p1_erased_qnf_unmarked : p3qnf.2 p3sigmaR = false := by
  have h215 : (2 : ℤ) < 15 := by omega
  have h1518 : (15 : ℤ) < 18 := by omega
  have h1825 : (18 : ℤ) < 25 := by omega
  have hn1815 : ¬ (18 : ℤ) < 15 := by omega
  rw [p3qnf_snd]
  refine @decide_eq_false _ (Classical.dec _) ?_
  rintro ⟨u, hu⟩
  -- the putative realizer's atom layer IS τ's atom layer, read at [u, 15, 2, 18]
  have hA : nf_eval_nf P3M 0 4 (Fin.cons u p3env3) p3tau.1 :=
    nf_eval_nf_atom_layer P3M (Fin.cons u p3env3) p3sigmaR hu
  -- u sits strictly above the t-anchor 18 (admissibility conjunct-1 zone read)
  have hτadm : kvE_futAdmissible p3tau = true :=
    kvE_futRealizer_admissible P3M p3tau 25 15 2 18 h215 h1518 h1825
      p3_tau_pinned
  obtain ⟨hzA, -, -⟩ := (nf_eval_nf0_cons_factor P3M p3env3 u p3tau.1).mp hA
  rw [kvE_futAdmissible_zoneMark p3tau hτadm] at hzA
  have h18u : (18 : ℤ) < u := (hzA ⟨2, by omega⟩).2.mpr rfl
  -- u realizes 25's complete depth-0 4-type over [15, 2, 18]
  have hτ1char : p3tau.1 = nf_characteristic P3M 0 4 p3env4 :=
    nf_eval_unique P3M 0 4 p3env4 p3tau.1 _
      (nf_eval_nf_atom_layer P3M p3env4 p3tau p3_tau_pinned)
      (nf_characteristic_satisfies P3M 0 4 p3env4)
  have hchar : nf_eval_nf P3M 0 4 (Fin.cons u p3env3)
      (nf_characteristic P3M 0 4 p3env4) := by
    rw [← hτ1char]; exact hA
  -- P3 engine: transfer p3eInt's honest witness 15 across the profile-equal endpoints
  have heInt : nf_eval_nf P3M 0 5 (Fin.cons 15 p3env4) p3eInt :=
    nf_characteristic_satisfies P3M 0 5 _
  have h15pin : nf_eval_nf P3M 0 5 (Fin.cons 15 (Fin.cons u p3env3)) p3eInt :=
    kvE_probe_interior_transfer P3M 15 25 u 15 2 18 hn1815 h1825 h18u
      hchar p3eInt heInt
  -- p3eInt is on the fiber; the fold must mark it — contradiction with the erasure
  have hefib : nfk_dropFresh p3eInt = p3sigmaR.1 := by
    have hefac := (nf_eval_nf0_cons_factor P3M p3env4 15 p3eInt).mp heInt
    exact nf_eval_unique P3M 0 4 p3env4 _ _ hefac.2.2
      (nf_eval_nf_atom_layer P3M p3env4 p3tau p3_tau_pinned)
  obtain ⟨⟨-, hfibf⟩, -⟩ := (nf_eval_nfk_iff_efold P3M (Fin.cons u p3env3) p3sigmaR).mp hu
  have hbit := (hfibf p3eInt hefib).mp ⟨15, h15pin⟩
  rw [show p3sigmaR.2 p3eInt = (if p3eInt = p3eInt then false else p3tau.2 p3eInt) from rfl,
    if_pos rfl] at hbit
  exact Bool.noConfusion hbit

/-! ### P2 (C8): the slice-identification composite on the concrete instance -/

/-- File-local replica of the private `nfk_projFresh_zero` (CarrierKv.lean:89 — `private`,
    replicated per the `kvE_minPick` precedent, never imported): at depth 0 the prefix
    projection coincides with the split kit's `nf0_projFresh`. -/
private theorem p3_projFresh_zero {n : Nat} (sub : NormalForm p3sig 0 (n + 1)) :
    nfk_projFresh sub = nf0_projFresh sub := by
  funext a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    rfl
  | .order i j h => exact absurd (Subsingleton.elim i j) h

/-- **P2 (C8)**: the slice-identification composite (report 02 §3.3 steps 1-5, chained) on
    the P3M instance: for EVERY admissible on-fiber `σ` carrying the destructor facts
    `hend`/`hgap`/`hocc` at the anchors `[x1, w, x, t] = [25, 15, 2, 18]`, the honest
    endpoint characteristic `σ★ := p3tau` is qnf-marked (step 1, probe (b)),
    pinned-realized (step 1), atom-layer-equal to σ (step 2, Phase-2
    `kvE_futAtomPinned_zero` + depth-0 uniqueness), and agrees with σ's marking on every
    exterior-zone fiber element (steps 3-5: gap via `hocc`/`hgap` + the probe (c) upgrade
    + uniqueness, both inclusions; ray via `hend`'s per-item and `¬F(¬D_ray)` conjuncts +
    the probe (c) upgrade, both directions; self via `hend`'s self conjunct + coincidence
    + admissibility conjunct 4 + the lossless split `nf0_split_assemble`). This is the
    `kvE_futSliceId_of_end_zero` conclusion instantiated concretely with the explicit
    witness `σ' := p3tau`. -/
theorem kvE_probe_p2_sliceId (σ : NormalForm p3sig 1 4)
    (hadm : kvE_futAdmissible σ = true)
    (hfib : nfk_dropFresh σ = p3qnf.1)
    (hend : temporal_truth P3M p3atomMap 25 (kvE_futEnd p3P σ))
    (hgap : ∀ r : ℤ, (18 : ℤ) < r → r < 25 →
      temporal_truth P3M p3atomMap r (kvE_futGapD p3P σ))
    (hocc : ∀ s ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : ℤ,
      (18 : ℤ) < r ∧ r < 25 ∧ temporal_truth P3M p3atomMap r (kvE_futItemShift p3P s)) :
    p3qnf.2 p3tau = true ∧
    nf_eval_nf P3M 1 4 p3env4 p3tau ∧
    p3tau.1 = σ.1 ∧
    ∀ s : NormalForm p3sig 0 5,
      (nfk_zoneSpec s = kvE_futGapZone ∨ nfk_zoneSpec s = kvE_futRayZone ∨
        nfk_zoneSpec s = kvE_futSelfZone) → p3tau.2 s = σ.2 s := by
  have h215 : (2 : ℤ) < 15 := by omega
  have h1518 : (15 : ℤ) < 18 := by omega
  have h1825 : (18 : ℤ) < 25 := by omega
  -- Step 2: atom-layer identification (Phase-2 supplier + depth-0 uniqueness)
  have hτA := nf_eval_nf_atom_layer P3M p3env4 p3tau p3_tau_pinned
  have hσA : nf_eval_nf P3M 0 4 p3env4 σ.1 :=
    kvE_futAtomPinned_zero p3P P3M p3_UZ p3_SZ p3qnf σ hadm hfib
      15 2 18 h215 h1518 p3_ambient 25 h1825 hend
  have h31 : p3tau.1 = σ.1 := nf_eval_unique P3M 0 4 p3env4 p3tau.1 σ.1 hτA hσA
  -- shared: σ-marked elements sit on τ's atom fiber
  have honfib : ∀ s : NormalForm p3sig 0 5, σ.2 s = true → nf0_dropFresh s = p3tau.1 := by
    intro s hbit
    have hd := kvE_futAdmissible_onFiber σ hadm s hbit
    rw [h31]; exact hd
  -- endpoint-description components (consumed by the ray and self cases)
  have hendC := hend
  rw [kvE_futEnd, formula_conjList_iff] at hendC
  have hselfC := hendC (kvE_fiberPosOnShift p3P (kvE_fiberZoneList σ kvE_futSelfZone))
    (by simp)
  have hrayC := hendC (kvE_futRayForm p3P σ) (by simp)
  rw [kvE_futRayForm, formula_conjList_iff] at hrayC
  rw [kvE_fiberPosOnShift_correct p3P _ P3M p3_UZ p3_SZ 25] at hselfC
  obtain ⟨s0, hs0mem, env0, hev0⟩ := hselfC
  obtain ⟨hbit0, hzs0⟩ := (kvE_fiberZoneList_mem σ kvE_futSelfZone s0).mp hs0mem
  -- the delivered self element upgrades to PINNED realization at [25, p3env4]
  have hz25self : zoneHolds P3M p3env4 kvE_futSelfZone 25 :=
    kvE_futZone4_of_above P3M 25 25 15 2 18 h215 h1518 h1825
      (false, false) (iff_of_false (lt_irrefl 25) Bool.false_ne_true)
      (iff_of_false (lt_irrefl 25) Bool.false_ne_true)
  obtain ⟨-, hfr0, -⟩ := (nf_eval_nf0_cons_factor P3M env0 25 s0).mp hev0
  have hs0pin : nf_eval_nf P3M 0 5 (Fin.cons 25 p3env4) s0 := by
    refine (nf_eval_nf0_cons_factor P3M p3env4 25 s0).mpr ⟨?_, hfr0, ?_⟩
    · have hzs0' : nf0_zoneSpec s0 = kvE_futSelfZone := hzs0
      rw [hzs0']; exact hz25self
    · have htl0' : nf0_dropFresh s0 = p3tau.1 := honfib s0 hbit0
      rw [htl0']; exact hτA
  have hτs0 : p3tau.2 s0 = true := by
    rw [p3tau_snd]
    exact @decide_eq_true _ (Classical.dec _) ⟨25, hs0pin⟩
  refine ⟨p3_tau_marked, p3_tau_pinned, h31, ?_⟩
  intro s hzcase
  rcases hzcase with hzs | hzs | hzs
  · -- GAP zone (step 3, both inclusions)
    cases hσbit : σ.2 s with
    | true =>
      -- σ ⊆ σ★: hocc places the listed item in (18, 25); probe (c) upgrades to pinned
      have hmem : s ∈ kvE_fiberZoneList σ kvE_futGapZone :=
        (kvE_fiberZoneList_mem σ kvE_futGapZone s).mpr ⟨hσbit, hzs⟩
      obtain ⟨r, hr1, hr2, hshift⟩ := hocc s hmem
      rw [kvE_futItemShift_correct p3P s P3M p3_UZ p3_SZ r] at hshift
      have hpin := kvE_probe_gapItem_pinned s r hr1 hr2 (honfib s hσbit) hzs hshift
      rw [p3tau_snd]
      exact @decide_eq_true _ (Classical.dec _) ⟨r, hpin⟩
    | false =>
      -- σ★ ⊆ σ: a pinned witness z ∈ (18, 25) meets hgap's listed item; uniqueness
      cases hτbit : p3tau.2 s with
      | false => rfl
      | true =>
        exfalso
        rw [p3tau_snd] at hτbit
        obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) hτbit
        have hzone := kvE_futZoneHolds_of_atom P3M p3env4 z s hz
        rw [hzs] at hzone
        have hz25 : z < (25 : ℤ) := (hzone 0).1.mpr rfl
        have h18z : (18 : ℤ) < z := (hzone ⟨3, by omega⟩).2.mpr rfl
        have hD := hgap z h18z hz25
        rw [kvE_futGapD, kvE_fiberPosOnShift_correct p3P _ P3M p3_UZ p3_SZ z] at hD
        obtain ⟨s', hmem', env', hev'⟩ := hD
        obtain ⟨hbit', hzs'⟩ := (kvE_fiberZoneList_mem σ kvE_futGapZone s').mp hmem'
        have hpin' := kvE_probe_gapItem_pinned s' z h18z hz25 (honfib s' hbit') hzs'
          ⟨env', hev'⟩
        have hss' : s' = s := nf_eval_unique P3M 0 5 (Fin.cons z p3env4) s' s hpin' hz
        rw [hss', hσbit] at hbit'
        exact Bool.noConfusion hbit'
  · -- RAY zone (step 4, both directions)
    cases hσbit : σ.2 s with
    | true =>
      -- σ ⊆ σ★: hend's per-item ray conjunct places s above 25; probe (c) upgrades
      have hmem : s ∈ kvE_fiberZoneList σ kvE_futRayZone :=
        (kvE_fiberZoneList_mem σ kvE_futRayZone s).mpr ⟨hσbit, hzs⟩
      have hitem := hrayC (Formula.untl (kvE_futItemShift p3P s) Formula.top)
        (List.mem_cons_of_mem _ (List.mem_map.mpr ⟨s, hmem, rfl⟩))
      obtain ⟨v, h25v, hsh, -⟩ := hitem
      rw [kvE_futItemShift_correct p3P s P3M p3_UZ p3_SZ v] at hsh
      have hpin := kvE_probe_rayItem_pinned s v h25v (honfib s hσbit) hzs hsh
      rw [p3tau_snd]
      exact @decide_eq_true _ (Classical.dec _) ⟨v, hpin⟩
    | false =>
      -- σ★ ⊆ σ: hend's ¬F(¬D_ray) conjunct covers the pinned witness z > 25; uniqueness
      cases hτbit : p3tau.2 s with
      | false => rfl
      | true =>
        exfalso
        rw [p3tau_snd] at hτbit
        obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) hτbit
        have hzone := kvE_futZoneHolds_of_atom P3M p3env4 z s hz
        rw [hzs] at hzone
        have h25z : (25 : ℤ) < z := (hzone 0).2.mpr rfl
        have hnf := hrayC (Formula.untl (kvE_futRayD p3P σ).neg Formula.top).neg (by simp)
        rw [temporal_truth_neg] at hnf
        have hDz : temporal_truth P3M p3atomMap z (kvE_futRayD p3P σ) := by
          by_contra hnD
          exact hnf ⟨z, h25z, (temporal_truth_neg P3M p3atomMap z _).mpr hnD,
            fun r _ _ => id⟩
        rw [kvE_futRayD, kvE_fiberPosOnShift_correct p3P _ P3M p3_UZ p3_SZ z] at hDz
        obtain ⟨s', hmem', env', hev'⟩ := hDz
        obtain ⟨hbit', hzs'⟩ := (kvE_fiberZoneList_mem σ kvE_futRayZone s').mp hmem'
        have hpin' := kvE_probe_rayItem_pinned s' z h25z (honfib s' hbit') hzs'
          ⟨env', hev'⟩
        have hss' : s' = s := nf_eval_unique P3M 0 5 (Fin.cons z p3env4) s' s hpin' hz
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
          rw [← p3_projFresh_zero s, ← p3_projFresh_zero s0]; exact hχ
        have h3 : nf0_dropFresh s = nf0_dropFresh s0 := by
          rw [honfib s hσbit, honfib s0 hbit0]
        calc s = nf0_assemble (nf0_zoneSpec s) (nf0_projFresh s) (nf0_dropFresh s) :=
              (nf0_split_assemble s).symm
          _ = nf0_assemble (nf0_zoneSpec s0) (nf0_projFresh s0) (nf0_dropFresh s0) := by
              rw [h1, h2, h3]
          _ = s0 := nf0_split_assemble s0
      rw [hs_eq]; exact hτs0
    | false =>
      -- σ★ ⊆ σ: a pinned self witness coincides with 25; uniqueness against s0
      cases hτbit : p3tau.2 s with
      | false => rfl
      | true =>
        exfalso
        rw [p3tau_snd] at hτbit
        obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) hτbit
        have hzone := kvE_futZoneHolds_of_atom P3M p3env4 z s hz
        rw [hzs] at hzone
        have hz25 : z = (25 : ℤ) := kvE_probe_selfZone_coincide P3M z 25 15 2 18 hzone
        rw [hz25] at hz
        have hss0 : s = s0 := nf_eval_unique P3M 0 5 (Fin.cons 25 p3env4) s s0 hz hs0pin
        rw [hss0, hbit0] at hσbit
        exact Bool.noConfusion hσbit

end Bimodal.Metalogic.WeakCanonical.Kamp
