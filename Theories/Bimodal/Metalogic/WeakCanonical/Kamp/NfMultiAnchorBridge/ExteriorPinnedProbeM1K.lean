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

/-! ## Hypothesis side (i): `σ` is admissible

`kvE_futAdmissible` is model-independent decidable syntax; its four conjuncts read only the
atom layer and the fiber-existential navigation channels. `τ` is admissible because it is
realized (`kvE_futRealizer_admissible`); the `s*` augmentation survives every conjunct:
conjunct 1 reads `σ.1 = τ.1`; conjunct 2 needs only the ATOM-fiber fact
`m1_sstar_dropFresh` (the doppelgänger evasion); conjuncts 3-4 see `s*` only through its
zone spec, which is the (possible, non-self) GAP zone. -/

/-- The gap zone is order-possible (the 7th entry of `kvE_futPossibleZones`). -/
private theorem m1_gap_possible :
    (kvE_futPossibleZones.any fun z => decide (kvE_futGapZone = z)) = true := by
  rw [List.any_eq_true]
  refine ⟨kvE_futGapZone, ?_, decide_eq_true rfl⟩
  exact .tail _ (.tail _ (.tail _ (.tail _ (.tail _ (.tail _ (.head _))))))

/-- The `s*` augmentation is invisible to `kvE_subBit` at every NON-gap zone spec. -/
private theorem m1_subBit_eq_of_ne_gap (zs4 : ZoneSpec 4) (χ : NormalForm m1sig 1 1)
    (hz : zs4 ≠ kvE_futGapZone) :
    kvE_subBit m1sigma zs4 χ = kvE_subBit m1tau zs4 χ := by
  unfold kvE_subBit
  congr 1
  funext s
  by_cases hss : s = m1sstar
  · subst hss
    have hzf : decide (nfk_zoneSpec m1sstar = zs4) = false :=
      decide_eq_false (fun he => hz (he.symm.trans m1_sstar_zone))
    rw [hzf]
    simp only [Bool.and_false, Bool.false_and]
  · have hb : m1sigma.2 s = m1tau.2 s := by
      show (if s = m1sstar then true else m1tau.2 s) = m1tau.2 s
      rw [if_neg hss]
    rw [hb]
    rfl

/-- **`σ := τ ⊕ s*` is order-admissible.** -/
private theorem m1_sigma_adm : kvE_futAdmissible m1sigma = true := by
  have h215 : (2 : ℤ) < 15 := by omega
  have h1518 : (15 : ℤ) < 18 := by omega
  have h1825 : (18 : ℤ) < 25 := by omega
  have htau : kvE_futAdmissible m1tau = true :=
    kvE_futRealizer_admissible M1M m1tau 25 15 2 18 h215 h1518 h1825
      (nf_characteristic_satisfies M1M 2 4 m1env4)
  rw [kvE_futAdmissible, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at htau ⊢
  obtain ⟨⟨⟨ht1, ht2⟩, ht3⟩, ht4⟩ := htau
  refine ⟨⟨⟨ht1, ?_⟩, ?_⟩, ?_⟩
  · -- conjunct 2: every marked fiber element sits on σ's atom fiber
    rw [List.all_eq_true] at ht2 ⊢
    intro s hs
    show (decide (nfk_dropFresh s = m1sigma.1) || !(m1sigma.2 s)) = true
    rw [Bool.or_eq_true]
    by_cases hss : s = m1sstar
    · subst hss
      exact Or.inl (decide_eq_true m1_sstar_dropFresh)
    · have h2s : (decide (nfk_dropFresh s = m1tau.1) || !(m1tau.2 s)) = true := ht2 s hs
      rw [Bool.or_eq_true] at h2s
      rcases h2s with hl | hr
      · exact Or.inl hl
      · right
        have hb : m1sigma.2 s = m1tau.2 s := by
          show (if s = m1sstar then true else m1tau.2 s) = m1tau.2 s
          rw [if_neg hss]
        rw [hb]
        exact hr
  · -- conjunct 3: quant bits false on every order-impossible zone spec
    rw [List.all_eq_true] at ht3 ⊢
    intro zs4 hzs
    show ((kvE_futPossibleZones.any fun z => decide (zs4 = z)) ||
        ((Finset.univ.toList (α := NormalForm m1sig 1 1)).all fun χ =>
          !(kvE_subBit m1sigma zs4 χ))) = true
    rw [Bool.or_eq_true]
    by_cases hz4 : zs4 = kvE_futGapZone
    · subst hz4
      exact Or.inl m1_gap_possible
    · have h3z : ((kvE_futPossibleZones.any fun z => decide (zs4 = z)) ||
          ((Finset.univ.toList (α := NormalForm m1sig 1 1)).all fun χ =>
            !(kvE_subBit m1tau zs4 χ))) = true := ht3 zs4 hzs
      rw [Bool.or_eq_true] at h3z
      rcases h3z with hl | hr
      · exact Or.inl hl
      · right
        rw [List.all_eq_true] at hr ⊢
        intro χ hχ
        show (!kvE_subBit m1sigma zs4 χ) = true
        rw [m1_subBit_eq_of_ne_gap zs4 χ hz4]
        exact hr χ hχ
  · -- conjunct 4: self-zone fresh-profile uniqueness (self bucket untouched by s*)
    rw [List.all_eq_true] at ht4 ⊢
    intro χ hχ
    show ((Finset.univ.toList (α := NormalForm m1sig 1 1)).all fun χ' =>
        !(kvE_subBit m1sigma kvE_futSelfZone χ) || !(kvE_subBit m1sigma kvE_futSelfZone χ') ||
          decide (χ = χ')) = true
    have h4χ : ((Finset.univ.toList (α := NormalForm m1sig 1 1)).all fun χ' =>
        !(kvE_subBit m1tau kvE_futSelfZone χ) || !(kvE_subBit m1tau kvE_futSelfZone χ') ||
          decide (χ = χ')) = true := ht4 χ hχ
    rw [List.all_eq_true] at h4χ ⊢
    intro χ' hχ'
    show (!(kvE_subBit m1sigma kvE_futSelfZone χ) || !(kvE_subBit m1sigma kvE_futSelfZone χ') ||
        decide (χ = χ')) = true
    rw [m1_subBit_eq_of_ne_gap kvE_futSelfZone χ (Ne.symm m1_gap_ne_self),
        m1_subBit_eq_of_ne_gap kvE_futSelfZone χ' (Ne.symm m1_gap_ne_self)]
    exact h4χ χ' hχ'

/-! ## Hypothesis side (ii): the honest ambient and the semantic destructor facts

The `hend`/`hgap`/`hocc` facts are stated in the P-ELIMINATED semantic form — exactly what
the depth-1 rendering channels deliver through their correctness lemmas
(`kvE_futItemShift_correct` / `kvE_fiberPosOnShift_correct`: formula truth at a point `r` ↔
`∃ env, nf_eval_nf M 1 5 (Fin.cons r env) s`, env FREE). No in-tree depth-1
`ExistProviders` instance exists (that recursion is this task's own open target), so the
formula-level binders cannot be instantiated — but any future instance yields exactly these
semantic facts, so the countermodel applies to every provider-rendered form. -/

/-- The honest level-up ambient is realized at the actual anchors. -/
private theorem m1_ambient : nf_eval_nf M1M 3 3 m1env3 m1qnf :=
  nf_characteristic_satisfies M1M 3 3 m1env3

/-- `σ` marks every honest pinned fiber element (its marking extends `τ`'s). -/
private theorem m1_sigma_marks_honest (s : NormalForm m1sig 1 5) (z : ℤ)
    (hz : nf_eval_nf M1M 1 5 (Fin.cons z m1env4) s) : m1sigma.2 s = true := by
  show (if s = m1sstar then true else m1tau.2 s) = true
  by_cases hss : s = m1sstar
  · rw [if_pos hss]
  · rw [if_neg hss]
    exact @decide_eq_true (∃ u : ℤ, nf_eval_nf M1M 1 5 (Fin.cons u m1env4) s)
      (Classical.dec _) ⟨z, hz⟩

/-- **`hend` (self conjunct), semantic**: some self-listed element of `σ` is realized at
    the endpoint `25` (the honest self type, free env). -/
private theorem m1_hendSelfS :
    ∃ s ∈ kvE_fiberZoneList m1sigma kvE_futSelfZone,
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons 25 env) s := by
  refine ⟨nf_characteristic M1M 1 5 (Fin.cons 25 m1env4), ?_, m1env4,
    nf_characteristic_satisfies M1M 1 5 (Fin.cons 25 m1env4)⟩
  exact (kvE_fiberZoneList_mem _ _ _).mpr
    ⟨m1_sigma_marks_honest _ 25 (nf_characteristic_satisfies M1M 1 5 (Fin.cons 25 m1env4)),
     m1_honest_self_zone⟩

/-- **`hend` (ray `¬F(¬D_ray)` conjunct), semantic**: every point above the endpoint
    realizes some ray-listed element of `σ` (its own honest type, free env). -/
private theorem m1_hendRayCover (v : ℤ) (hv : (25 : ℤ) < v) :
    ∃ s ∈ kvE_fiberZoneList m1sigma kvE_futRayZone,
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons v env) s := by
  refine ⟨nf_characteristic M1M 1 5 (Fin.cons v m1env4), ?_, m1env4,
    nf_characteristic_satisfies M1M 1 5 (Fin.cons v m1env4)⟩
  exact (kvE_fiberZoneList_mem _ _ _).mpr
    ⟨m1_sigma_marks_honest _ v (nf_characteristic_satisfies M1M 1 5 (Fin.cons v m1env4)),
     m1_honest_ray_zone v hv⟩

/-- **`hend` (ray per-item conjuncts), semantic**: every ray-listed element of `σ` occurs
    at some point above the endpoint (free env). -/
private theorem m1_hendRayOcc (s : NormalForm m1sig 1 5)
    (hmem : s ∈ kvE_fiberZoneList m1sigma kvE_futRayZone) :
    ∃ v : ℤ, (25 : ℤ) < v ∧
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons v env) s := by
  obtain ⟨hbit, hzone⟩ := (kvE_fiberZoneList_mem m1sigma kvE_futRayZone s).mp hmem
  by_cases hss : s = m1sstar
  · exact absurd (m1_sstar_zone.symm.trans (hss ▸ hzone)) m1_gap_ne_ray
  · have hbitτ : m1tau.2 s = true := by
      have hb : m1sigma.2 s = m1tau.2 s := by
        show (if s = m1sstar then true else m1tau.2 s) = m1tau.2 s
        rw [if_neg hss]
      rw [← hb]
      exact hbit
    obtain ⟨zz, hzz⟩ := @of_decide_eq_true
      (∃ u : ℤ, nf_eval_nf M1M 1 5 (Fin.cons u m1env4) s) (Classical.dec _) hbitτ
    have hz : s.1 (.order (1 : Fin 5) (0 : Fin 5) (by decide)) = true :=
      congrArg (fun zs : ZoneSpec 4 => (zs 0).2) hzone
    have h25zz : (25 : ℤ) < zz :=
      (hzz.1 (.order (1 : Fin 5) (0 : Fin 5) (by decide))).mpr hz
    exact ⟨zz, h25zz, m1env4, hzz⟩

/-- **`hgap`, semantic**: every walk point `r ∈ (18, 25)` realizes some gap-listed element
    of `σ` (its own honest type, free env). -/
private theorem m1_hgapS (r : ℤ) (h1 : (18 : ℤ) < r) (h2 : r < 25) :
    ∃ s ∈ kvE_fiberZoneList m1sigma kvE_futGapZone,
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons r env) s := by
  refine ⟨nf_characteristic M1M 1 5 (Fin.cons r m1env4), ?_, m1env4,
    nf_characteristic_satisfies M1M 1 5 (Fin.cons r m1env4)⟩
  exact (kvE_fiberZoneList_mem _ _ _).mpr
    ⟨m1_sigma_marks_honest _ r (nf_characteristic_satisfies M1M 1 5 (Fin.cons r m1env4)),
     m1_honest_gap_zone r h1 h2⟩

/-- **`hocc`, semantic**: every gap-listed element of `σ` — INCLUDING the fake `s*` — is
    realized at some walk point `r ∈ (18, 25)` (free env; `s*` at `22` over the
    doppelgänger tail). -/
private theorem m1_hoccS (s : NormalForm m1sig 1 5)
    (hmem : s ∈ kvE_fiberZoneList m1sigma kvE_futGapZone) :
    ∃ r : ℤ, (18 : ℤ) < r ∧ r < 25 ∧
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons r env) s := by
  obtain ⟨hbit, hzone⟩ := (kvE_fiberZoneList_mem m1sigma kvE_futGapZone s).mp hmem
  by_cases hss : s = m1sstar
  · subst hss
    exact ⟨22, by omega, by omega, m1envF, m1_sstar_freeEnv⟩
  · have hbitτ : m1tau.2 s = true := by
      have hb : m1sigma.2 s = m1tau.2 s := by
        show (if s = m1sstar then true else m1tau.2 s) = m1tau.2 s
        rw [if_neg hss]
      rw [← hb]
      exact hbit
    obtain ⟨zz, hzz⟩ := @of_decide_eq_true
      (∃ u : ℤ, nf_eval_nf M1M 1 5 (Fin.cons u m1env4) s) (Classical.dec _) hbitτ
    have hz1 : s.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide)) = true :=
      congrArg (fun zs : ZoneSpec 4 => (zs 0).1) hzone
    have hz2 : s.1 (.order (4 : Fin 5) (0 : Fin 5) (by decide)) = true :=
      congrArg (fun zs : ZoneSpec 4 => (zs 3).2) hzone
    have hzz25 : zz < (25 : ℤ) :=
      (hzz.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide))).mpr hz1
    have h18zz : (18 : ℤ) < zz :=
      (hzz.1 (.order (4 : Fin 5) (0 : Fin 5) (by decide))).mpr hz2
    exact ⟨zz, h18zz, hzz25, m1env4, hzz⟩

/-! ## The assembled NO-GO verdict -/

/-- **C0 probe verdict — NO-GO** (task 358 Phase 6; report 03 §6-C3 confirmed at binder
    strength): at m = 1 the slice `σ := τ ⊕ s*` satisfies the FULL hypothesis side of the
    slice-identification/`hsliceFut` interface over the anchors `[25, 15, 2, 18]` —
    order-admissibility, the atom-fiber guard, the honest level-up ambient, and the complete
    semantic destructor fact set (`hend` self + ray both directions, `hgap`, `hocc`) — yet
    the conclusion FAILS: no admissible, slice-equal, qnf-marked mate exists.

    Contrast with m = 0: the same statement shape is TRUE at m = 0
    (`kvE_futSliceId_of_end_zero` / `kvE_hsliceFut_supply_zero`, both landed and untouched);
    the m = 1 failure is carried entirely by the depth-1 fiber marking layer, which the
    free-env rendering cannot pin (deviation D7: no depth-k cons-factorization for k ≥ 1).
    Consequence for plan v3: Phase 7 (G2 general-m lift of rows 8-11) CANNOT proceed on the
    current interface — the escalation is a slice-kernel/interface restatement spawn per the
    plan's NO-GO branch, never a sorry. -/
theorem kvE_probeM1_sliceId_NOGO :
    kvE_futAdmissible m1sigma = true ∧
    nfk_dropFresh m1sigma = m1qnf.1 ∧
    nf_eval_nf M1M 3 3 m1env3 m1qnf ∧
    (∃ s ∈ kvE_fiberZoneList m1sigma kvE_futSelfZone,
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons 25 env) s) ∧
    (∀ v : ℤ, (25 : ℤ) < v → ∃ s ∈ kvE_fiberZoneList m1sigma kvE_futRayZone,
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons v env) s) ∧
    (∀ s ∈ kvE_fiberZoneList m1sigma kvE_futRayZone, ∃ v : ℤ, (25 : ℤ) < v ∧
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons v env) s) ∧
    (∀ r : ℤ, (18 : ℤ) < r → r < 25 → ∃ s ∈ kvE_fiberZoneList m1sigma kvE_futGapZone,
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons r env) s) ∧
    (∀ s ∈ kvE_fiberZoneList m1sigma kvE_futGapZone, ∃ r : ℤ, (18 : ℤ) < r ∧ r < 25 ∧
      ∃ env : Fin 4 → M1M.carrier, nf_eval_nf M1M 1 5 (Fin.cons r env) s) ∧
    ¬ ∃ σ' : NormalForm m1sig 2 4, kvE_futAdmissible σ' = true ∧
        kvE_futSliceEq σ' m1sigma = true ∧ m1qnf.2 σ' = true :=
  ⟨m1_sigma_adm, m1_sigma_dropFresh, m1_ambient, m1_hendSelfS,
   m1_hendRayCover, m1_hendRayOcc, m1_hgapS, m1_hoccS, m1_no_marked_mate⟩

/-! ## Task 358 Phase 8 probe — G1 shared-root-cause check (interior `hreal`, rows 5-6)

Machine-adjudicates whether the Phase-6 NO-GO root cause (depth-1 fiber marking not pinned by
free-env rendering) ALSO defeats the G1 interior supply (`kampPrior_hreal_supply`, ledger rows
5-6) at general depth, or whether G1 is independent.

**Mechanism probed**: the rows 5-6 binders (KampPrior.lean:835-846) guard by
`igPtW … qnf.1 (igFoldBit qnf)` — and `igFoldBit` (InteriorGateGeneralK.lean:318) reads each
marked depth-`(k+1)` arity-4 fiber ONLY through the pair
`(nf0_zoneSpec ∘ atom_assgn, nfk_projFresh)` — the arity-1 projection (the documented F1
information-loss channel). So a fake fiber that is **projection-invisible** (same zone, same
arity-1 projection as an honestly marked fiber) produces a qnf whose ENTIRE rows-5-6
hypothesis side is literally identical to the honest one, for EVERY rendering
`charBase`/`charK` — while the `hreal` conclusion (pinned realization `∃ x1,
nf_eval … [x1,w,x,t] σ`) fails.

**The countermodel is the SAME Phase-6 cast**: `σ := τ ⊕ s*` (the doppelgänger-tail fake) is
projection-invisible one level up — `nfk_projFresh m1sigma = nfk_projFresh m1tau` because
`s*`'s arity-2 prefix take equals that of the HONEST inner element
`s° := nf_characteristic M1M 1 5 [22, 25, 15, 2, 18]` (both are the depth-1 2-type of the
prefix `[22, 25]`; the tails differ only at slots the take discards), and `τ` marks `s°`.
Hence `qnfG1 := m1qnf ⊕ m1sigma` has `igFoldBit qnfG1 = igFoldBit m1qnf` — guard-identical to
the honest ambient — yet `qnfG1.2 m1sigma = true` and `m1sigma` has NO pinned realization
over `[·, 15, 2, 18]` (it marks `s*`, which `m1_sstar_not_pinned` kills at every anchor).

## VERDICT: **NO-GO — G1 SHARES the Phase-6 root cause**

Rows 5-6 as shaped cannot be supplied at fiber depth ≥ 1: any `kampPrior_hreal_supply`
covering the qnf population would have to hold at `qnfG1`, whose hypothesis side is
indistinguishable from the honest `m1qnf` (satisfiable whenever the honest guard is — and the
honest guard MUST be satisfiable for the gate route to be non-vacuous), while the conclusion
fails at `σ = m1sigma`. The interface-restatement spawn recommended by Phase 6 (anchored/pinned
item rendering or a depth-graded fiber guard) must therefore cover the interior rows 5-6 as
well, not only rows 8-11. -/

/-- The honest inner 5-tuple over the PINNED tail: `[22, 25, 15, 2, 18]` (walk point `22`
    over the honest 4-anchors — contrast `m1tupF`, which carries the doppelgänger tail). -/
private def m1tupH : Fin 5 → M1M.carrier := Fin.cons 22 m1env4

/-- The HONEST inner element `s°`: the depth-1 5-type of `22` over the pinned tail. -/
private noncomputable def m1shonest : NormalForm m1sig 1 5 :=
  nf_characteristic M1M 1 5 m1tupH

/-- `τ` marks the honest inner element (realized at fresh witness `22`). -/
private theorem m1_shonest_marked : m1tau.2 m1shonest = true :=
  @decide_eq_true (∃ x : ℤ, nf_eval_nf M1M 1 5 (Fin.cons x m1env4) m1shonest)
    (Classical.dec _) ⟨22, nf_characteristic_satisfies M1M 1 5 m1tupH⟩

/-- **Projection-invisibility, inner layer**: the arity-2 prefix takes of the fake `s*` and
    the honest `s°` COINCIDE — both are realized at the same prefix `[22, 25]` (of the
    doppelgänger and honest 5-tuples respectively), so `nf_eval_unique` identifies the takes.
    The doppelgänger difference (t-slot `21` vs `18`) lives entirely in the discarded
    suffix. -/
private theorem m1_take2_eq :
    nfk_take (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le 3))) m1sstar =
      nfk_take (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le 3))) m1shonest := by
  have h1 := nf_eval_take M1M (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le 3)))
    m1tupF m1sstar m1_sstar_freeEnv
  have h2 := nf_eval_take M1M (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le 3)))
    m1tupH m1shonest (nf_characteristic_satisfies M1M 1 5 m1tupH)
  have henv : (fun i : Fin 2 =>
        m1tupF (Fin.castLE (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le 3))) i)) =
      (fun i : Fin 2 =>
        m1tupH (Fin.castLE (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le 3))) i)) := by
    funext i
    fin_cases i <;>
      simp [m1tupF, m1tupH, m1envF, m1env4, m1env3, Fin.castLE]
  rw [henv] at h1
  exact nf_eval_unique M1M 1 2 _ _ _ h1 h2

/-- The take-existential of the fake slice agrees with the honest one at every projected
    type: `s*`'s contribution is covered by the honest marked element `s°`
    (`m1_take2_eq`). -/
private theorem m1_take_exists_iff (χ' : NormalForm m1sig 1 2) :
    (∃ sub' : NormalForm m1sig 1 5, m1sigma.2 sub' = true ∧
      nfk_take (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le 3))) sub' = χ') ↔
    (∃ sub' : NormalForm m1sig 1 5, m1tau.2 sub' = true ∧
      nfk_take (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le 3))) sub' = χ') := by
  constructor
  · rintro ⟨sub', hbit, htake⟩
    by_cases hss : sub' = m1sstar
    · subst hss
      refine ⟨m1shonest, m1_shonest_marked, ?_⟩
      rw [← m1_take2_eq]
      exact htake
    · refine ⟨sub', ?_, htake⟩
      have hb : m1sigma.2 sub' = m1tau.2 sub' := by
        show (if sub' = m1sstar then true else m1tau.2 sub') = m1tau.2 sub'
        rw [if_neg hss]
      rwa [hb] at hbit
  · rintro ⟨sub', hbit, htake⟩
    refine ⟨sub', ?_, htake⟩
    show (if sub' = m1sstar then true else m1tau.2 sub') = true
    by_cases hss : sub' = m1sstar
    · rw [if_pos hss]
    · rw [if_neg hss]; exact hbit

set_option maxRecDepth 8000 in
/-- **Projection-invisibility, fiber layer**: the fake slice `σ = τ ⊕ s*` and the honest
    endpoint characteristic `τ` have the SAME arity-1 fresh projection — `s*`'s contribution
    to the take-existential is covered by the honest marked element `s°`. -/
private theorem m1_projFresh_eq : nfk_projFresh m1sigma = nfk_projFresh m1tau := by
  unfold nfk_projFresh nfk_take
  refine Prod.ext rfl (funext fun χ' => ?_)
  rw [decide_eq_decide]
  exact m1_take_exists_iff χ'

/-- The honest ambient marks `τ` (realized at the fresh anchor `25`). -/
private theorem m1_tau_marked : m1qnf.2 m1tau = true :=
  @decide_eq_true (∃ x : ℤ, nf_eval_nf M1M 2 4 (Fin.cons x m1env3) m1tau)
    (Classical.dec _) ⟨25, nf_characteristic_satisfies M1M 2 4 m1env4⟩

/-- **The fake ambient** `qnfG1 := m1qnf ⊕ m1sigma`: the honest depth-3 3-type with the fake
    slice `σ = τ ⊕ s*` additionally marked — the rows-5-6 analogue of the Phase-6 `σ = τ ⊕
    s*` move, one level up. -/
private noncomputable def m1qnfG1 : NormalForm m1sig 3 3 :=
  (m1qnf.1, fun s => if s = m1sigma then true else m1qnf.2 s)

/-- **Fold-bit invisibility**: the fake ambient's fold bits are IDENTICAL to the honest
    ambient's — `m1sigma`'s `(zone, projection)` pair is already contributed by the honestly
    marked `τ` (same atom row, same fresh projection by `m1_projFresh_eq`). Every quantity the
    rows-5-6 interface reads off the qnf (`qnf.1` and `igFoldBit qnf`) therefore agrees
    between fake and honest. -/
private theorem m1_qnfG1_foldBit_eq : igFoldBit m1qnfG1 = igFoldBit m1qnf := by
  funext zs χ
  unfold igFoldBit
  refine decide_eq_decide.mpr ?_
  constructor
  · rintro ⟨sub, hbit, hzone, hproj⟩
    by_cases hs : sub = m1sigma
    · subst hs
      refine ⟨m1tau, m1_tau_marked, hzone, ?_⟩
      rw [← m1_projFresh_eq]
      exact hproj
    · refine ⟨sub, ?_, hzone, hproj⟩
      have hb : m1qnfG1.2 sub = m1qnf.2 sub := by
        show (if sub = m1sigma then true else m1qnf.2 sub) = m1qnf.2 sub
        rw [if_neg hs]
      rwa [hb] at hbit
  · rintro ⟨sub, hbit, hzone, hproj⟩
    refine ⟨sub, ?_, hzone, hproj⟩
    show (if sub = m1sigma then true else m1qnf.2 sub) = true
    by_cases hs : sub = m1sigma
    · rw [if_pos hs]
    · rw [if_neg hs]; exact hbit

/-- **The `hreal` conclusion fails**: the fake slice `σ = τ ⊕ s*` has NO pinned realization
    over the ambient tail `[·, 15, 2, 18]` at ANY anchor `x1` — it marks `s*`, which
    `m1_sstar_not_pinned` refutes at every fresh witness. This is exactly the conclusion
    shape of ledger row 5 (`hreal`, KampPrior.lean:835-840) at `k = 1`. -/
private theorem m1_sigma_not_pinned4 (x1 : ℤ) :
    ¬ nf_eval_nf M1M 2 4 (Fin.cons x1 m1env3) m1sigma := by
  intro h
  obtain ⟨v, hv⟩ := (h.2 m1sstar).mpr m1_sigma_marks_sstar
  exact m1_sstar_not_pinned v x1 hv

/-- The honest ambient does NOT mark the fake slice (otherwise `m1_ambient` would give it a
    pinned realization, contradicting `m1_sigma_not_pinned4`) — so `qnfG1 ≠ m1qnf`: the fake
    is a genuinely different qnf that the interface cannot separate from the honest one. -/
private theorem m1_qnf_sigma_false : m1qnf.2 m1sigma = false := by
  cases hb : m1qnf.2 m1sigma with
  | false => rfl
  | true =>
    obtain ⟨x1, hx1⟩ := (m1_ambient.2 m1sigma).mpr hb
    exact absurd hx1 (m1_sigma_not_pinned4 x1)

/-! ## The assembled G1 NO-GO verdict -/

/-- **G1 probe verdict — NO-GO, shared root cause** (task 358 Phase 8): at ambient depth 3
    (`k = 1` in the rungK binders) there is a qnf — `qnfG1 = m1qnf ⊕ (τ ⊕ s*)` — that

    1. has the SAME atom row as the honest ambient characteristic (`rfl`),
    2. has IDENTICAL `igFoldBit` fold bits (so `igPtW`, `igGate`, `igSL`/`igSR`, and every
       other quantity the rows-5-6 hypothesis side reads off the qnf agree with the honest
       ambient's, for EVERY rendering `charBase`/`charK` — see
       `kvE_probeM1_interiorGuard_identical`),
    3. marks the fiber `σ = τ ⊕ s*` which the honest ambient does NOT mark, and
    4. `σ` has NO pinned realization `nf_eval_nf M1M 2 4 [x1, 15, 2, 18] σ` at ANY `x1`.

    Consequence: the row-5 `hreal` supply shape (KampPrior.lean:835-840) is FALSE at `qnfG1`
    whenever its `igPtW` guard is satisfiable — and the guard is satisfiable iff the honest
    ambient's guard is (they are equal), which any non-vacuous use of the gate route
    requires. The depth-1 fiber marking layer defeats the interior rows 5-6 exactly as it
    defeats the exterior rows 8-11 (`kvE_probeM1_sliceId_NOGO`): free-env/projected rendering
    cannot pin it (deviation D7). The slice-kernel/interface restatement spawn must cover G1
    too. -/
theorem kvE_probeM1_interiorHreal_NOGO :
    m1qnfG1.1 = m1qnf.1 ∧
    igFoldBit m1qnfG1 = igFoldBit m1qnf ∧
    m1qnfG1.2 m1sigma = true ∧
    m1qnf.2 m1sigma = false ∧
    ∀ x1 : M1M.carrier, ¬ nf_eval_nf M1M 2 4 (Fin.cons x1 m1env3) m1sigma :=
  ⟨rfl, m1_qnfG1_foldBit_eq,
   by show (if m1sigma = m1sigma then true else m1qnf.2 m1sigma) = true; rw [if_pos rfl],
   m1_qnf_sigma_false, m1_sigma_not_pinned4⟩

/-- **Guard identity**: for EVERY rendering pair (`charBase`, `charK`) — in particular for
    every provider-generated `charF (k+1) = P.existF 0` the recursion site could ever
    instantiate — the rows-5-6 `igPtW` guard of the fake ambient is the SAME temporal
    predicate as the honest ambient's. No rendering can separate them; the interface itself
    is information-losing (the F1 arity-1 projection channel). -/
theorem kvE_probeM1_interiorGuard_identical
    (charBase : NormalForm m1sig 0 1 → Formula)
    (charK : NormalForm m1sig 2 1 → Formula) :
    igPtW charBase charK m1qnfG1.1 (igFoldBit m1qnfG1) =
      igPtW charBase charK m1qnf.1 (igFoldBit m1qnf) := by
  rw [m1_qnfG1_foldBit_eq]
  rfl

end Bimodal.Metalogic.WeakCanonical.Kamp
