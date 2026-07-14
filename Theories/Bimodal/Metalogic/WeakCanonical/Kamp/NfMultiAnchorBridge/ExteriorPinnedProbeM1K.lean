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

end Bimodal.Metalogic.WeakCanonical.Kamp
