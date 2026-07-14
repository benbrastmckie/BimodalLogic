import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedConverseK

/-! # General-m slice-identification probe at m = 1 (task 358, Phase 6 — GO/NO-GO gate)

Machine-adjudicates report 03's mandated C3 probe (the C0 gate of plan
`specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/03_post-360-gap-closure.md`,
Phase 6): does the endpoint slice identification (`kvE_futSliceId_of_end_zero` pattern,
ExteriorPinnedConverseK.lean:891) extend to fiber depth m = 1, where σ : `NormalForm sig 2 4`
and the fiber elements are depth-1 (`NormalForm sig 1 5`)?

**Probe conventions**: model `M1M = (ℤ, <)`, `P = {0, 10, 20}` (template copy of the
established `P3M` probe model, ExteriorPinnedProbeK.lean:81 — `private` there, replicated per
the `kvE_minPick` precedent). Anchor instance `[x1, w, x, t] = [25, 15, 2, 18]`
(`x < w < t < x1`, walk gap `(18, 25)` containing the `P`-point `20`).

## VERDICT: **NO-GO** (machine countermodel at the semantic destructor interface)

The countermodel core is the FAKE gap fiber element
`s* := nf_characteristic M1M 1 5 [22, 25, 15, 2, 21]` — the honest depth-1 5-type of the walk
point `22` over the DOPPELGÄNGER tail `[25, 15, 2, 21]` (same depth-0 atom 4-type as the pinned
tail `[25, 15, 2, 18]`, but with the t-slot `21` adjacent to the fresh point `22`). `s*` is:

- **on the atom fiber** (`nfk_dropFresh s* = σ.1` — conjunct-2 admissibility reads only the
  depth-0 atom restriction, which cannot separate `21` from `18`);
- **gap-zoned** and **free-env realized** at the walk point `22 ∈ (18, 25)` — exactly the
  content shape the depth-1 rendering channels deliver (`kvE_futItemShift_correct` /
  `kvE_fiberPosOnShift_correct`: `∃ env, nf_eval_nf M 1 5 (Fin.cons r env) s`, env fully free);
- **NOT pinned-realizable** over ANY tail `[x1'', 15, 2, 18]` (`m1_sstar_not_pinned`): its
  depth-1 marking says "NO point strictly between the t-slot and the fresh point" (the
  `e_b`-element, forcing the candidate fresh `z = 19`) and "NO `P`-point strictly between the
  fresh point and the x1-slot" (the `e_c`-element, impossible at `z = 19` since
  `20 ∈ (19, x1'')` for every admissible `x1'' ≥ 21`).

Consequently the augmented slice `σ := τ ⊕ s*` (the honest endpoint characteristic
`τ := nf_characteristic M1M 2 4 [25,15,2,18]` with `s*` additionally marked) passes the
m = 1 identification/`hsliceFut` hypothesis set — admissibility, the atom-fiber guard, the
honest level-up ambient, and the full semantic destructor fact set (`hend`/`hgap`/`hocc`,
stated in the P-eliminated semantic form, since no in-tree depth-1 provider instance exists) —
while NO admissible slice-equal qnf-marked mate exists (`kvE_futSliceEq` forces gap-LIST
equality; every qnf-marked σ' is realized, so its gap elements are pinned-realizable at its
endpoint over the ambient tail `[·, 15, 2, 18]`, and `s*` is not).

At m = 0 the same recipe FAILS to produce a countermodel (the depth-0 shadow of `s*` is a pure
atom assignment, which the C8(c) three-channel upgrade transports to the pinned tail — the
landed `kvE_futSliceId_of_end_zero` remains correct); the failure at m = 1 is exactly the
depth-1 marking layer that `nf_eval_nf0_cons_factor` cannot factor (deviation D7: the
factorization is depth-0-ONLY).

Purely additive NEW leaf module; probe-local (`private`) machinery; no production file
touched (Phase 6 makes zero production edits). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Probe signature and model (template copies of the `p3*` conventions,
ExteriorPinnedProbeK.lean:75-84) -/

/-- One-predicate signature for the probe. -/
private abbrev m1sig : MonadicSignature := { preds := Unit }

/-- Trivial atom map into the one-predicate probe signature. -/
private abbrev m1atomMap : Formula → m1sig.preds := fun _ => ()

/-- The probe model `M* = (ℤ, <)` with `P = {0, 10, 20}` (template copy of `P3M`). -/
private abbrev M1M : OrderedMonadicStructure m1sig where
  carrier := ℤ
  interp := fun _ z => z = 0 ∨ z = 10 ∨ z = 20
  carrier_order := inferInstance

/-! ## Anchor environments -/

/-- Ambient anchors `[w, x, t] = [15, 2, 18]`. -/
private def m1env3 : Fin 3 → M1M.carrier := Fin.cons 15 (Fin.cons 2 (fun _ => 18))

/-- Pinned 4-anchors `[x1, w, x, t] = [25, 15, 2, 18]`. -/
private def m1env4 : Fin 4 → M1M.carrier := Fin.cons 25 m1env3

/-- The DOPPELGÄNGER tail `[25, 15, 2, 21]`: same depth-0 atom 4-type as `m1env4`
    (identical predicate profile and order pattern), different depth-1 content. -/
private def m1envF : Fin 4 → M1M.carrier :=
  Fin.cons 25 (Fin.cons 15 (Fin.cons 2 (fun _ => 21)))

/-- The fake world's 5-tuple `[22, 25, 15, 2, 21]` (walk point `22` over the doppelgänger
    tail). -/
private def m1tupF : Fin 5 → M1M.carrier := Fin.cons 22 m1envF

/-! ## The m = 1 cast: ambient, endpoint characteristic, fake fiber element -/

/-- The honest level-up ambient at m = 1: the depth-3 characteristic 3-type of `[15, 2, 18]`. -/
private noncomputable def m1qnf : NormalForm m1sig 3 3 := nf_characteristic M1M 3 3 m1env3

/-- The honest endpoint characteristic at m = 1: `τ := nf_characteristic M1M 2 4 [25,15,2,18]`
    (`σ★` of the identification conclusion; fibers are depth-1). -/
private noncomputable def m1tau : NormalForm m1sig 2 4 := nf_characteristic M1M 2 4 m1env4

/-- **The fake gap fiber element** `s*`: the honest depth-1 5-type of the walk point `22`
    over the doppelgänger tail `[25, 15, 2, 21]`. -/
private noncomputable def m1sstar : NormalForm m1sig 1 5 :=
  nf_characteristic M1M 1 5 m1tupF

/-- **The countermodel slice** `σ := τ ⊕ s*`: the honest endpoint characteristic with the
    fake gap element additionally marked. -/
private noncomputable def m1sigma : NormalForm m1sig 2 4 :=
  (m1tau.1, fun s => if s = m1sstar then true else m1tau.2 s)

/-! ## `s*` is free-env realized at the walk point 22 ∈ (18, 25) -/

/-- `s*` is realized at the walk point `22` with the free (doppelgänger) tail — exactly the
    content shape the depth-1 rendering channels (`kvE_futItemShift_correct` / `hocc`)
    deliver (env fully free). -/
private theorem m1_sstar_freeEnv : nf_eval_nf M1M 1 5 m1tupF m1sstar :=
  nf_characteristic_satisfies M1M 1 5 m1tupF

/-! ## The core NO-GO engine: `s*` is not pinned-realizable over ANY `[x1'', 15, 2, 18]` tail

The two probe elements:
- `e_b := nf_characteristic M1M 0 6 [19, z, x1'', 15, 2, 18]` — the honest inner 6-type of
  the point `19` in the CANDIDATE world (case `z ≥ 20`); realized there by totality, so
  `s*`'s quant layer must mark it — but `s*`'s world has NO point strictly between its
  t-slot (`21`) and its fresh point (`22`).
- `e_c := nf_characteristic M1M 0 6 [20, 19, x1'', 15, 2, 18]` — the honest inner 6-type of
  the `P`-point `20` once `z = 19` is forced; `s*`'s world has NO `P`-point strictly above
  its fresh point (`22`). -/

/-- **`s*` is not pinned-realizable**: for every fresh `z` and every endpoint `x1''`, `s*`
    is NOT realized at `[z, x1'', 15, 2, 18]`. The atom layer forces `18 < z < x1''` with
    `z, x1'' ∉ P`; if `z ≥ 20` the honest inner type of `19` (`e_b`) is realized in the
    candidate world but demands a point in `(21, 22)` of the fake world; so `z = 19`, whence
    `x1'' ≥ 21` and the honest inner type of `20` (`e_c`) is realized in the candidate world
    but demands a `P`-point above `22` of the fake world — `P ∩ (22, ∞) = ∅`. -/
private theorem m1_sstar_not_pinned (z x1'' : ℤ) :
    ¬ nf_eval_nf M1M 1 5
      (Fin.cons z (Fin.cons x1'' (Fin.cons 15 (Fin.cons 2 (fun _ => (18 : ℤ)))))) m1sstar := by
  intro h
  -- atom extraction: 18 < z (s*'s atom layer records t-slot < fresh, i.e. 21 < 22)
  have h2122 : (21 : ℤ) < 22 := by omega
  have hv40 : m1sstar.1 (.order (4 : Fin 5) (0 : Fin 5) (by decide)) = true :=
    @decide_eq_true (atom_eval M1M m1tupF (.order (4 : Fin 5) (0 : Fin 5) (by decide)))
      (Classical.dec _) h2122
  have h18z : (18 : ℤ) < z :=
    (h.1 (.order (4 : Fin 5) (0 : Fin 5) (by decide))).mpr hv40
  -- atom extraction: z < x1'' (fresh < x1-slot, i.e. 22 < 25)
  have h2225 : (22 : ℤ) < 25 := by omega
  have hv01 : m1sstar.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide)) = true :=
    @decide_eq_true (atom_eval M1M m1tupF (.order (0 : Fin 5) (1 : Fin 5) (by decide)))
      (Classical.dec _) h2225
  have hzx1 : z < x1'' :=
    (h.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide))).mpr hv01
  -- atom extraction: ¬P(x1'') (x1-slot predicate profile: ¬P(25))
  have hn25 : ¬((25 : ℤ) = 0 ∨ (25 : ℤ) = 10 ∨ (25 : ℤ) = 20) := by omega
  have hv1 : m1sstar.1 (.pred () (1 : Fin 5)) = false :=
    @decide_eq_false (atom_eval M1M m1tupF (.pred () (1 : Fin 5)))
      (Classical.dec _) hn25
  have hPx1 : ¬(x1'' = 0 ∨ x1'' = 10 ∨ x1'' = 20) := fun hp =>
    Bool.noConfusion (hv1.symm.trans ((h.1 (.pred () (1 : Fin 5))).mp hp))
  by_cases hz20 : (20 : ℤ) ≤ z
  · -- case z ≥ 20: the honest inner type of 19 is realized in the candidate world …
    have h19z : (19 : ℤ) < z := by omega
    set eb : NormalForm m1sig 0 6 :=
      nf_characteristic M1M 0 6
        (Fin.cons 19 (Fin.cons z (Fin.cons x1'' (Fin.cons 15 (Fin.cons 2
          (fun _ => (18 : ℤ))))))) with hebdef
    have hebreal : nf_eval_nf M1M 0 6
        (Fin.cons 19 (Fin.cons z (Fin.cons x1'' (Fin.cons 15 (Fin.cons 2
          (fun _ => (18 : ℤ))))))) eb :=
      nf_characteristic_satisfies M1M 0 6 _
    have hmark : m1sstar.2 eb = true := (h.2 eb).mp ⟨19, hebreal⟩
    -- … so s* must mark it: a witness u in the fake world with 21 < u < 22
    obtain ⟨u, hu⟩ := @of_decide_eq_true
      (∃ u : ℤ, nf_eval_nf M1M 0 6 (Fin.cons u m1tupF) eb) (Classical.dec _) hmark
    have heb1 : eb (.order (0 : Fin 6) (1 : Fin 6) (by decide)) = true := by
      rw [hebdef]
      exact @decide_eq_true (atom_eval M1M
        (Fin.cons 19 (Fin.cons z (Fin.cons x1'' (Fin.cons 15 (Fin.cons 2
          (fun _ => (18 : ℤ))))))) (.order (0 : Fin 6) (1 : Fin 6) (by decide)))
        (Classical.dec _) h19z
    have hu22 : u < (22 : ℤ) :=
      (hu (.order (0 : Fin 6) (1 : Fin 6) (by decide))).mpr heb1
    have h1819 : (18 : ℤ) < 19 := by omega
    have heb2 : eb (.order (5 : Fin 6) (0 : Fin 6) (by decide)) = true := by
      rw [hebdef]
      exact @decide_eq_true (atom_eval M1M
        (Fin.cons 19 (Fin.cons z (Fin.cons x1'' (Fin.cons 15 (Fin.cons 2
          (fun _ => (18 : ℤ))))))) (.order (5 : Fin 6) (0 : Fin 6) (by decide)))
        (Classical.dec _) h1819
    have h21u : (21 : ℤ) < u :=
      (hu (.order (5 : Fin 6) (0 : Fin 6) (by decide))).mpr heb2
    omega
  · -- case z = 19 (forced by 18 < z ≤ 19): then x1'' ≥ 21 and the honest inner type of the
    -- P-point 20 is realized in the candidate world …
    have hz : z = 19 := by omega
    subst hz
    have hx121 : (21 : ℤ) ≤ x1'' := by omega
    set ec : NormalForm m1sig 0 6 :=
      nf_characteristic M1M 0 6
        (Fin.cons 20 (Fin.cons 19 (Fin.cons x1'' (Fin.cons 15 (Fin.cons 2
          (fun _ => (18 : ℤ))))))) with hecdef
    have hecreal : nf_eval_nf M1M 0 6
        (Fin.cons 20 (Fin.cons 19 (Fin.cons x1'' (Fin.cons 15 (Fin.cons 2
          (fun _ => (18 : ℤ))))))) ec :=
      nf_characteristic_satisfies M1M 0 6 _
    have hmark : m1sstar.2 ec = true := (h.2 ec).mp ⟨20, hecreal⟩
    -- … so s* must mark it: a P-point u of the fake world with u > 22 — but P ⊆ (-∞, 20]
    obtain ⟨u, hu⟩ := @of_decide_eq_true
      (∃ u : ℤ, nf_eval_nf M1M 0 6 (Fin.cons u m1tupF) ec) (Classical.dec _) hmark
    have h1920 : (19 : ℤ) < 20 := by omega
    have hec1 : ec (.order (1 : Fin 6) (0 : Fin 6) (by decide)) = true := by
      rw [hecdef]
      exact @decide_eq_true (atom_eval M1M
        (Fin.cons 20 (Fin.cons 19 (Fin.cons x1'' (Fin.cons 15 (Fin.cons 2
          (fun _ => (18 : ℤ))))))) (.order (1 : Fin 6) (0 : Fin 6) (by decide)))
        (Classical.dec _) h1920
    have h22u : (22 : ℤ) < u :=
      (hu (.order (1 : Fin 6) (0 : Fin 6) (by decide))).mpr hec1
    have h20P : ((20 : ℤ) = 0 ∨ (20 : ℤ) = 10 ∨ (20 : ℤ) = 20) := by omega
    have hec2 : ec (.pred () (0 : Fin 6)) = true := by
      rw [hecdef]
      exact @decide_eq_true (atom_eval M1M
        (Fin.cons 20 (Fin.cons 19 (Fin.cons x1'' (Fin.cons 15 (Fin.cons 2
          (fun _ => (18 : ℤ))))))) (.pred () (0 : Fin 6)))
        (Classical.dec _) h20P
    have hPu : u = 0 ∨ u = 10 ∨ u = 20 := (hu (.pred () (0 : Fin 6))).mpr hec2
    omega

/-! ## Zone-spec computations -/

/-- Generic zone computation for a depth-1 arity-5 characteristic: the zone spec of
    `nf_characteristic M1M 1 5 (Fin.cons c env)` is the pointwise coupling record of `c`
    against `env`. -/
private theorem m1_zone_char (c : ℤ) (env : Fin 4 → M1M.carrier) (p : ZoneSpec 4)
    (hc : ∀ i : Fin 4, ((c < env i) ↔ (p i).1 = true) ∧ ((env i < c) ↔ (p i).2 = true)) :
    nfk_zoneSpec (nf_characteristic M1M 1 5 (Fin.cons c env)) = p := by
  funext i
  refine Prod.ext ?_ ?_
  · cases hp : (p i).1 with
    | true =>
      exact @decide_eq_true
        (atom_eval M1M (Fin.cons c env) (.order 0 i.succ (Fin.succ_ne_zero i).symm))
        (Classical.dec _) ((hc i).1.mpr hp)
    | false =>
      exact @decide_eq_false
        (atom_eval M1M (Fin.cons c env) (.order 0 i.succ (Fin.succ_ne_zero i).symm))
        (Classical.dec _)
        (fun hcc => Bool.noConfusion (hp.symm.trans ((hc i).1.mp hcc)))
  · cases hp : (p i).2 with
    | true =>
      exact @decide_eq_true
        (atom_eval M1M (Fin.cons c env) (.order i.succ 0 (Fin.succ_ne_zero i)))
        (Classical.dec _) ((hc i).2.mpr hp)
    | false =>
      exact @decide_eq_false
        (atom_eval M1M (Fin.cons c env) (.order i.succ 0 (Fin.succ_ne_zero i)))
        (Classical.dec _)
        (fun hcc => Bool.noConfusion (hp.symm.trans ((hc i).2.mp hcc)))

/-- `s*` sits in the GAP zone (`22 ∈ (21, 25)` relative to its own tail — the same zone
    spec as `22 ∈ (18, 25)` relative to the pinned tail). -/
private theorem m1_sstar_zone : nfk_zoneSpec m1sstar = kvE_futGapZone := by
  refine m1_zone_char 22 m1envF kvE_futGapZone ?_
  intro i
  match i with
  | ⟨0, _⟩ =>
    exact ⟨iff_of_true (show (22 : ℤ) < 25 by omega) rfl,
           iff_of_false (show ¬((25 : ℤ) < 22) by omega) Bool.false_ne_true⟩
  | ⟨1, _⟩ =>
    exact ⟨iff_of_false (show ¬((22 : ℤ) < 15) by omega) Bool.false_ne_true,
           iff_of_true (show (15 : ℤ) < 22 by omega) rfl⟩
  | ⟨2, _⟩ =>
    exact ⟨iff_of_false (show ¬((22 : ℤ) < 2) by omega) Bool.false_ne_true,
           iff_of_true (show (2 : ℤ) < 22 by omega) rfl⟩
  | ⟨3, _⟩ =>
    exact ⟨iff_of_false (show ¬((22 : ℤ) < 21) by omega) Bool.false_ne_true,
           iff_of_true (show (21 : ℤ) < 22 by omega) rfl⟩

/-- Honest gap elements: the depth-1 5-type of any `r ∈ (18, 25)` over the PINNED tail sits
    in the gap zone. -/
private theorem m1_honest_gap_zone (r : ℤ) (h1 : (18 : ℤ) < r) (h2 : r < 25) :
    nfk_zoneSpec (nf_characteristic M1M 1 5 (Fin.cons r m1env4)) = kvE_futGapZone := by
  refine m1_zone_char r m1env4 kvE_futGapZone ?_
  intro i
  match i with
  | ⟨0, _⟩ =>
    exact ⟨iff_of_true h2 rfl,
           iff_of_false (show ¬((25 : ℤ) < r) by omega) Bool.false_ne_true⟩
  | ⟨1, _⟩ =>
    exact ⟨iff_of_false (show ¬(r < (15 : ℤ)) by omega) Bool.false_ne_true,
           iff_of_true (show (15 : ℤ) < r by omega) rfl⟩
  | ⟨2, _⟩ =>
    exact ⟨iff_of_false (show ¬(r < (2 : ℤ)) by omega) Bool.false_ne_true,
           iff_of_true (show (2 : ℤ) < r by omega) rfl⟩
  | ⟨3, _⟩ =>
    exact ⟨iff_of_false (show ¬(r < (18 : ℤ)) by omega) Bool.false_ne_true,
           iff_of_true h1 rfl⟩

/-- Honest ray elements: the depth-1 5-type of any `v > 25` over the PINNED tail sits in
    the ray zone. -/
private theorem m1_honest_ray_zone (v : ℤ) (hv : (25 : ℤ) < v) :
    nfk_zoneSpec (nf_characteristic M1M 1 5 (Fin.cons v m1env4)) = kvE_futRayZone := by
  refine m1_zone_char v m1env4 kvE_futRayZone ?_
  intro i
  match i with
  | ⟨0, _⟩ =>
    exact ⟨iff_of_false (show ¬(v < (25 : ℤ)) by omega) Bool.false_ne_true,
           iff_of_true hv rfl⟩
  | ⟨1, _⟩ =>
    exact ⟨iff_of_false (show ¬(v < (15 : ℤ)) by omega) Bool.false_ne_true,
           iff_of_true (show (15 : ℤ) < v by omega) rfl⟩
  | ⟨2, _⟩ =>
    exact ⟨iff_of_false (show ¬(v < (2 : ℤ)) by omega) Bool.false_ne_true,
           iff_of_true (show (2 : ℤ) < v by omega) rfl⟩
  | ⟨3, _⟩ =>
    exact ⟨iff_of_false (show ¬(v < (18 : ℤ)) by omega) Bool.false_ne_true,
           iff_of_true (show (18 : ℤ) < v by omega) rfl⟩

/-- The honest self element: the depth-1 5-type of `25` itself over the PINNED tail sits in
    the self zone. -/
private theorem m1_honest_self_zone :
    nfk_zoneSpec (nf_characteristic M1M 1 5 (Fin.cons 25 m1env4)) = kvE_futSelfZone := by
  refine m1_zone_char 25 m1env4 kvE_futSelfZone ?_
  intro i
  match i with
  | ⟨0, _⟩ =>
    exact ⟨iff_of_false (show ¬((25 : ℤ) < 25) by omega) Bool.false_ne_true,
           iff_of_false (show ¬((25 : ℤ) < 25) by omega) Bool.false_ne_true⟩
  | ⟨1, _⟩ =>
    exact ⟨iff_of_false (show ¬((25 : ℤ) < 15) by omega) Bool.false_ne_true,
           iff_of_true (show (15 : ℤ) < 25 by omega) rfl⟩
  | ⟨2, _⟩ =>
    exact ⟨iff_of_false (show ¬((25 : ℤ) < 2) by omega) Bool.false_ne_true,
           iff_of_true (show (2 : ℤ) < 25 by omega) rfl⟩
  | ⟨3, _⟩ =>
    exact ⟨iff_of_false (show ¬((25 : ℤ) < 18) by omega) Bool.false_ne_true,
           iff_of_true (show (18 : ℤ) < 25 by omega) rfl⟩

/-- Zone separation: the gap zone is not the self zone (head couplings `(true, false)` vs
    `(false, false)`). -/
private theorem m1_gap_ne_self : kvE_futGapZone ≠ kvE_futSelfZone := fun h =>
  Bool.noConfusion (congrArg (fun zs : ZoneSpec 4 => (zs 0).1) h)

/-- Zone separation: the gap zone is not the ray zone (head couplings `(true, false)` vs
    `(false, true)`). -/
private theorem m1_gap_ne_ray : kvE_futGapZone ≠ kvE_futRayZone := fun h =>
  Bool.noConfusion (congrArg (fun zs : ZoneSpec 4 => (zs 0).1) h)

/-! ## Atom-fiber facts -/

/-- **The doppelgänger evasion**: `s*` sits on the PINNED atom fiber — dropping the fresh
    variable from `s*`'s atom layer recovers `τ`'s atom layer exactly, because the depth-0
    atom 4-type cannot separate the tail `[25, 15, 2, 21]` from `[25, 15, 2, 18]`. -/
private theorem m1_sstar_dropFresh : nfk_dropFresh m1sstar = m1tau.1 := by
  have h1521 : (15 : ℤ) < 21 := by omega
  have h1518 : (15 : ℤ) < 18 := by omega
  have h221 : (2 : ℤ) < 21 := by omega
  have h218 : (2 : ℤ) < 18 := by omega
  have h2125 : (21 : ℤ) < 25 := by omega
  have h1825 : (18 : ℤ) < 25 := by omega
  have hn2521 : ¬((25 : ℤ) < 21) := by omega
  have hn2518 : ¬((25 : ℤ) < 18) := by omega
  have hn2115 : ¬((21 : ℤ) < 15) := by omega
  have hn1815 : ¬((18 : ℤ) < 15) := by omega
  have hn212 : ¬((21 : ℤ) < 2) := by omega
  have hn182 : ¬((18 : ℤ) < 2) := by omega
  have hn2121 : ¬((21 : ℤ) < 21) := by omega
  have hn1818 : ¬((18 : ℤ) < 18) := by omega
  have hP21 : ¬((21 : ℤ) = 0 ∨ (21 : ℤ) = 10 ∨ (21 : ℤ) = 20) := by omega
  have hP18 : ¬((18 : ℤ) = 0 ∨ (18 : ℤ) = 10 ∨ (18 : ℤ) = 20) := by omega
  funext a
  cases a with
  | pred p i =>
    simp only [nfk_dropFresh, nf0_dropFresh, mergeNF, skipFin_zero_succ]
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => exact decide_eq_decide.mpr (iff_of_false hP21 hP18)
  | order i j h =>
    simp only [nfk_dropFresh, nf0_dropFresh, mergeNF, skipFin_zero_succ]
    match i, j with
    | ⟨0, _⟩, ⟨0, _⟩ => rfl
    | ⟨0, _⟩, ⟨1, _⟩ => rfl
    | ⟨0, _⟩, ⟨2, _⟩ => rfl
    | ⟨0, _⟩, ⟨3, _⟩ => exact decide_eq_decide.mpr (iff_of_false hn2521 hn2518)
    | ⟨1, _⟩, ⟨0, _⟩ => rfl
    | ⟨1, _⟩, ⟨1, _⟩ => rfl
    | ⟨1, _⟩, ⟨2, _⟩ => rfl
    | ⟨1, _⟩, ⟨3, _⟩ => exact decide_eq_decide.mpr (iff_of_true h1521 h1518)
    | ⟨2, _⟩, ⟨0, _⟩ => rfl
    | ⟨2, _⟩, ⟨1, _⟩ => rfl
    | ⟨2, _⟩, ⟨2, _⟩ => rfl
    | ⟨2, _⟩, ⟨3, _⟩ => exact decide_eq_decide.mpr (iff_of_true h221 h218)
    | ⟨3, _⟩, ⟨0, _⟩ => exact decide_eq_decide.mpr (iff_of_true h2125 h1825)
    | ⟨3, _⟩, ⟨1, _⟩ => exact decide_eq_decide.mpr (iff_of_false hn2115 hn1815)
    | ⟨3, _⟩, ⟨2, _⟩ => exact decide_eq_decide.mpr (iff_of_false hn212 hn182)
    | ⟨3, _⟩, ⟨3, _⟩ => exact decide_eq_decide.mpr (iff_of_false hn2121 hn1818)

/-- The fiber guard: dropping the fresh (x1) variable from `σ`'s atom layer recovers the
    ambient's atom layer (`f2_drop_char` pattern — the tails coincide literally). -/
private theorem m1_sigma_dropFresh : nfk_dropFresh m1sigma = m1qnf.1 := by
  funext a
  cases a with
  | pred p i =>
    simp only [nfk_dropFresh, nf0_dropFresh, mergeNF, skipFin_zero_succ]
    rfl
  | order i j h =>
    simp only [nfk_dropFresh, nf0_dropFresh, mergeNF, skipFin_zero_succ]
    rfl

/-! ## `s*` sits in `σ`'s gap list -/

/-- `σ` marks `s*` (by construction). -/
private theorem m1_sigma_marks_sstar : m1sigma.2 m1sstar = true := by
  show (if m1sstar = m1sstar then true else m1tau.2 m1sstar) = true
  rw [if_pos rfl]

/-- `s* ∈ kvE_fiberZoneList m1sigma kvE_futGapZone`. -/
private theorem m1_sstar_mem_gapList :
    m1sstar ∈ kvE_fiberZoneList m1sigma kvE_futGapZone :=
  (kvE_fiberZoneList_mem m1sigma kvE_futGapZone m1sstar).mpr
    ⟨m1_sigma_marks_sstar, m1_sstar_zone⟩

/-! ## The conclusion failure: no admissible slice-equal qnf-marked mate -/

/-- **The `hsliceFut`/identification CONCLUSION fails for `σ`**: there is NO
    `σ' : NormalForm m1sig 2 4` that is admissible, slice-equal to `σ`, and marked by the
    honest ambient. Any qnf-marked σ' is realized at some `[x1'', 15, 2, 18]`; slice
    equality forces `s*` into σ''s gap list, so σ''s realization demands a pinned witness
    for `s*` over `[x1'', 15, 2, 18]` — refuted by `m1_sstar_not_pinned`. -/
private theorem m1_no_marked_mate :
    ¬ ∃ σ' : NormalForm m1sig 2 4, kvE_futAdmissible σ' = true ∧
        kvE_futSliceEq σ' m1sigma = true ∧ m1qnf.2 σ' = true := by
  rintro ⟨σ', -, hslEq, hmark⟩
  -- the marked mate is realized at some ambient-tail anchor
  obtain ⟨x1'', hx⟩ := @of_decide_eq_true
    (∃ u : ℤ, nf_eval_nf M1M 2 4 (Fin.cons u m1env3) σ') (Classical.dec _) hmark
  -- slice equality delivers gap-LIST equality
  rw [kvE_futSliceEq, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hslEq
  obtain ⟨⟨⟨-, hgapL⟩, -⟩, -⟩ := hslEq
  have hgapL := of_decide_eq_true hgapL
  -- s* transfers into σ''s gap list
  have hmem : m1sstar ∈ kvE_fiberZoneList σ' kvE_futGapZone := by
    rw [hgapL]
    exact m1_sstar_mem_gapList
  have hbit : σ'.2 m1sstar = true :=
    ((kvE_fiberZoneList_mem σ' kvE_futGapZone m1sstar).mp hmem).1
  -- σ''s realization forces a pinned witness for s* — contradiction
  obtain ⟨zz, hzz⟩ := (hx.2 m1sstar).mpr hbit
  exact m1_sstar_not_pinned zz x1'' hzz

end Bimodal.Metalogic.WeakCanonical.Kamp
