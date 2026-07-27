/-
ARCHIVED — off-faithful-path (Kamp Boneyard). MOVE-not-delete; do NOT delete or empty.

Retired from the live build ahead of the k>=2 E[Sigma] re-architecture. NOT on the
proof-term path from `completeness_discrete` (0 live importers; outside the Bimodal.lean
import closure, so uncompiled). Pinned tail-DG NO-GO probe.
Machine-checked NO-GO / refutation certificate, retained as evidence. Do NOT consume or
reuse for the faithful re-architecture (off-paper arity-4 object; diverges from Rabinovich
Def 4.1, PDF p.5). Filename de-numbered on archival (durable-anchor discipline).

Key declarations: kvE_probe358_tailDG_gapItem_pinned_fails, kvE_probe358_tailDG_sigma_in_population
-/
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# G2 general-m gate probe: the tail-doppelgänger against the co-realization-strengthened
interface (plan-v05 Phase 2 route-R2 gate)

Machine-adjudicates the plan-v05 Phase-2 generalization step (route R2: probe BEFORE landing).
Plan v05 re-keys the G2 exterior slice supply (rows 8-11) to the co-realization-
strengthened guard and prescribes generalizing the m = 0 slice-identification kernel
`kvE_futSliceId_of_end_zero` (`ExteriorPinnedConverseK.lean:899`) to general m. The P2-0
re-probe gate PASSED this session (`kvE_probe358_eP_atomMate_present` still TRUE;
`kvE_probe364_sigma2_inadmissible` GREEN at floor axioms): the v04 planted-mate blocker is
closed. THIS probe adjudicates the NEXT load-bearing step: whether the m = 0 kernel's
free-env → pinned upgrade (`kvE_futGapItem_pinned_zero`, `ExteriorPinnedConverseK.lean:797`)
generalizes to fiber depth ≥ 1.

## The load-bearing step and why it is depth-0-bound

Every direction of `kvE_futSliceId_of_end_zero`'s zone-list identification consumes the
upgrade: an on-fiber, gap-zoned fiber element with a FREE-ENV occurrence at a walk point
`r ∈ (t, x1)` is pinned-realized at `[r, x1, w, x, t]`. At fiber depth 0 this holds by the
lossless three-channel factorization `nf_eval_nf0_cons_factor` (zone + fresh profile + tail
row). At depth ≥ 1 the factorization is LOSSY by the codebase's own D7 doctrine
(`NfEFold.lean:549-561`): a depth-≥1 fiber couples the fresh witness JOINTLY to the
environment through its nested quantifier layers. The chain/endpoint truths that feed the
slice identification (`kvE_futItemShift`/`kvE_futGapD`/`kvE_futEnd` content via
`P.existF 4`) are intrinsically FREE-ENV (`kvE_futItemShift_correct`: `∃ env, …`), so at
depth ≥ 1 a walked point may realize its listed fiber over a deeply-different
"tail-doppelgänger" environment whose depth-0 row coincides with the pinned tail.

## The countermodel instance (all-honest — the family the strengthened guard does NOT exclude)

Model `(ℤ, <)`, one predicate `R = {10}`. REAL pinned anchors `[x1, w, x, t] =
[35, 5, 2, 30]`; FAKE tail `[x̃1, w̃, x̃, t̃] = [40, 12, 8, 25]`. The two 4-tuples are
depth-0 indistinguishable (same order pattern, all slots R-free) — but the R-point `10`
sits in `(x̃, w̃) = (8, 12)` relative to the fake tail vs `(w, t) = (5, 30)` relative to
the real one: a depth-1-visible INTERIOR-zone discrepancy (coupling vector `(<,<,>,<)` vs
`(<,>,>,<)` at the w-slot). The walk point `r = 32` lies in BOTH exterior gaps
(`30 < 32 < 35` real; `25 < 32 < 40` fake). Its honest depth-1 5-type `m3s` over the FAKE
tail is:

* gap-zoned (`nfk_zoneSpec m3s = kvE_futGapZone`),
* on-row (`nfk_dropFresh m3s` is realized at the REAL pinned tuple — the m = 0 upgrade's
  `hfib`+`hA` composite),
* free-env realized at the walk point `32` (the `hocc` shape delivered by
  `kvE_futItemShift_correct`),

yet `m3s` is realized at `[z, 35, 5, 2, 30]` for NO fresh witness `z`: its marked inner
witness `m3eR` (the 6-type of the R-point `10` over `(32; fake)`) demands an R-point
strictly below the w-slot value — `R ∩ (2, 5) = ∅` at the real tail
(`kvE_probe358_tailDG_gapItem_pinned_fails`).

**Every element of this cast is HONEST**: `m3s` is a genuinely realized characteristic, the
ambient fake slice `m3sigma` (the depth-2 4-type of the fake tuple) is realized in-model at
its own strict chain `8 < 12 < 25 < 40`, so it passes the co-realization-
strengthened guard through the SANCTIONED byte-stable route itself
(`kvE_futRealizer_admissible` — no guard unfolding anywhere in this module), marks `m3s` on
its gap zone list, and sits on the REAL ambient's fiber
(`kvE_probe358_tailDG_sigma_in_population`). The `s*`-style unrealizability that dissolved
the v04 planted-mate blocker (`kvE_probe364_sstar_honest_unrealizable`) has no purchase
here: there is no fake fiber and no plant — only a second, deeply-different but fully
realized environment.

## VERDICT: **NO-GO** — the m = 0 slice-id route does not generalize to m ≥ 1, and the
rows-8-9 binders are refuted-as-restated at m ≥ 1 (analytical closure below)

The decisive certificate shows the free-env → pinned upgrade — the load-bearing step of BOTH
zone-list inclusions of `kvE_futSliceId_of_end_zero` and hence of the planned general-m
`kvE_{fut,past}SliceId_of_end` (G2-1) — is FALSE at fiber depth 1 inside the
364-strengthened admissible population. Binder-level closure (analytical, the escalation
task's deliverable, per the v04 `kvE_probe358_eP_atomMate_present` precedent): on a dense
homogeneous order (ℚ, `R` a single point placed fake-interior/real-interior discrepantly,
e.g. real `(w,x,t) = (4,2,18)`, fake tuple `(25.5, 15, 4.5, 17)`, `R = {5}`), the pure fake
characteristic `σ := nf_characteristic M (m+1) 4 (fake)` fires the ENTIRE `hsliceFut`
antecedent stack at the real `t`: automorphism homogeneity collapses each fake exterior zone
to a single deep type, every real walked point in `(18, 25.5)` IS a fake-gap point of the
one fake tuple (realizing the single gap item), `x1_dest := x̃1 = 25.5` realizes the
self/ray endpoint description, and `σ` is admissible (realized) and on-row. But every
qnf-marked candidate `σ'` is a REAL-tail characteristic whose gap types mark the R-point
with the REAL coupling vector — never the fake one — so `kvE_futSliceEq σ' σ = false` for
every marked `σ'`: the `hsliceFut` conclusion fails. Rows 8-9 at m ≥ 1 are therefore not
servable as stated; the escalation is an interface restatement that DEEP-anchors the fiber
population to the ambient (the fiber-level analog of the depth-recursive content comparison
already named as the alternative direction in the v04 Phase-2 handoff §"What is needed") —
spawned as its own 363/364-style task, never a sorry.

**G2-2 (`SliceUnique`) is NOT refuted by this cast** (both σ's there are pinned-realized
over the SAME real tail — no free env), and the m = 0 layer, the k ≤ 1 rungs, and all
363/364 assets are untouched by this probe.

Probe conventions: template copies of `ExteriorPinnedProbe358K.lean` (model shape, private
cast, public certificates). Purely additive NEW leaf probe module; no production file is
touched.

## SUPERSESSION NOTE (docstring-only; every statement below is byte-stable)

The escalation prescribed by this probe's verdict has LANDED: the hereditary
deep-anchor guard `kvE_deepOnFiber` (`ExteriorFiberDeepAnchorK.lean`) now replaces the
depth-0 row antecedent `nfk_dropFresh σ = qnf.1` in the rows-8-9 binders and keys the
bracket range. Successor certificates (`ExteriorFiberDeepAnchorProbe367K.lean`):
`kvE_probe367_tailDG_deep_rejected` (THIS module's `m3sigma` fails the deep anchor w.r.t.
the real ambient — the population statement below is about the OLD depth-0 anchor and is
superseded, not falsified), `kvE_probe367_real_slice_deep_anchored` (honest anchoring
preserved), `kvE_probe367_depth2DG_deep_rejected` (depth-2 hereditary re-plant rejected),
`kvE_probe367_copyPlant_collapses` (content-copying plant collapses to the honest slice).
Both certificates below remain TRUE and compiling as the permanent regression record; the
general-m G1/G2 supply against the refined interface remains open. -/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Probe cast -/

/-- One-predicate signature for the probe (the deep marker `R`). -/
private abbrev m3sig : MonadicSignature := { preds := Unit }

/-- The probe model `(ℤ, <)` with `R = {10}`. -/
private abbrev M3M : OrderedMonadicStructure m3sig where
  carrier := ℤ
  interp := fun _ z => z = 10
  carrier_order := inferInstance

/-- REAL ambient anchors `[w, x, t] = [5, 2, 30]`. -/
private def m3realEnv3 : Fin 3 → M3M.carrier := Fin.cons 5 (Fin.cons 2 (fun _ => 30))

/-- REAL pinned anchors `[x1, w, x, t] = [35, 5, 2, 30]` (chain `2 < 5 < 30 < 35`). -/
private def m3realEnv : Fin 4 → M3M.carrier := Fin.cons 35 m3realEnv3

/-- FAKE (doppelgänger) tail `[x̃1, w̃, x̃, t̃] = [40, 12, 8, 25]` (chain `8 < 12 < 25 < 40`).
    Depth-0 indistinguishable from the real anchors, but the R-point `10` lies in
    `(x̃, w̃) = (8, 12)` fake-interiorly vs `(w, t) = (5, 30)` real-interiorly. -/
private def m3fakeEnv : Fin 4 → M3M.carrier :=
  Fin.cons 40 (Fin.cons 12 (Fin.cons 8 (fun _ => 25)))

/-- The walk point `r = 32` over the fake tail: `32` is in the REAL gap `(30, 35)` AND in
    the FAKE gap `(25, 40)`. -/
private def m3tup5 : Fin 5 → M3M.carrier := Fin.cons 32 m3fakeEnv

/-- The depth-1 fiber element: the honest complete depth-1 5-type of the walk point `32`
    over the FAKE tail. -/
private noncomputable def m3s : NormalForm m3sig 1 5 := nf_characteristic M3M 1 5 m3tup5

/-- The separating inner witness: the depth-0 6-type of the R-point `10` over `(32; fake)`.
    Its atom row demands an R-point strictly below the w-slot — satisfiable at the fake tail
    (`10 < 12`), empty at the real one (`R ∩ (2, 5) = ∅`). -/
private noncomputable def m3eR : NormalForm m3sig 0 6 :=
  nf_characteristic M3M 0 6 (Fin.cons 10 m3tup5)

/-- The fake-tail slice: the honest complete depth-2 4-type of the FAKE tuple — fully
    realized in-model, hence inside the 364-strengthened admissible population. -/
private noncomputable def m3sigma : NormalForm m3sig 2 4 := nf_characteristic M3M 2 4 m3fakeEnv

/-! ## Cast facts -/

/-- `m3s` occurs free-env at the walk point `32` (the `hocc`/`kvE_futItemShift_correct`
    shape). -/
private theorem m3_s_free : nf_eval_nf M3M 1 5 m3tup5 m3s :=
  nf_characteristic_satisfies M3M 1 5 m3tup5

/-- `m3s` is gap-zoned: its fresh-slot zone spec over its own tail is the Future gap zone. -/
private theorem m3_s_zone : nfk_zoneSpec m3s = kvE_futGapZone := by
  funext i
  match i with
  | ⟨0, _⟩ =>
    exact Prod.ext (@decide_eq_true _ (Classical.dec _) (by omega : (32:ℤ) < 40))
      (@decide_eq_false _ (Classical.dec _) (by omega : ¬((40:ℤ) < 32)))
  | ⟨1, _⟩ =>
    exact Prod.ext (@decide_eq_false _ (Classical.dec _) (by omega : ¬((32:ℤ) < 12)))
      (@decide_eq_true _ (Classical.dec _) (by omega : (12:ℤ) < 32))
  | ⟨2, _⟩ =>
    exact Prod.ext (@decide_eq_false _ (Classical.dec _) (by omega : ¬((32:ℤ) < 8)))
      (@decide_eq_true _ (Classical.dec _) (by omega : (8:ℤ) < 32))
  | ⟨3, _⟩ =>
    exact Prod.ext (@decide_eq_false _ (Classical.dec _) (by omega : ¬((32:ℤ) < 25)))
      (@decide_eq_true _ (Classical.dec _) (by omega : (25:ℤ) < 32))

/-- `m3s`'s dropped atom row is realized at the REAL pinned tuple — the m = 0 upgrade's
    `hfib` + `hA` composite: the fake and real 4-tuples are depth-0 indistinguishable. -/
private theorem m3_dropRow_real : nf_eval_nf M3M 0 4 m3realEnv (nfk_dropFresh m3s) := by
  intro a
  match a with
  | .pred _ ⟨0, _⟩ =>
    exact iff_of_false (by omega : ¬((35:ℤ) = 10))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((40:ℤ) = 10)))
  | .pred _ ⟨1, _⟩ =>
    exact iff_of_false (by omega : ¬((5:ℤ) = 10))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((12:ℤ) = 10)))
  | .pred _ ⟨2, _⟩ =>
    exact iff_of_false (by omega : ¬((2:ℤ) = 10))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((8:ℤ) = 10)))
  | .pred _ ⟨3, _⟩ =>
    exact iff_of_false (by omega : ¬((30:ℤ) = 10))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((25:ℤ) = 10)))
  | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
  | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
    exact iff_of_false (by omega : ¬((35:ℤ) < 5))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((40:ℤ) < 12)))
  | .order ⟨0, _⟩ ⟨2, _⟩ _ =>
    exact iff_of_false (by omega : ¬((35:ℤ) < 2))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((40:ℤ) < 8)))
  | .order ⟨0, _⟩ ⟨3, _⟩ _ =>
    exact iff_of_false (by omega : ¬((35:ℤ) < 30))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((40:ℤ) < 25)))
  | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
    exact iff_of_true (by omega : (5:ℤ) < 35)
      (@decide_eq_true _ (Classical.dec _) (by omega : (12:ℤ) < 40))
  | .order ⟨1, _⟩ ⟨1, _⟩ h => exact absurd rfl h
  | .order ⟨1, _⟩ ⟨2, _⟩ _ =>
    exact iff_of_false (by omega : ¬((5:ℤ) < 2))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((12:ℤ) < 8)))
  | .order ⟨1, _⟩ ⟨3, _⟩ _ =>
    exact iff_of_true (by omega : (5:ℤ) < 30)
      (@decide_eq_true _ (Classical.dec _) (by omega : (12:ℤ) < 25))
  | .order ⟨2, _⟩ ⟨0, _⟩ _ =>
    exact iff_of_true (by omega : (2:ℤ) < 35)
      (@decide_eq_true _ (Classical.dec _) (by omega : (8:ℤ) < 40))
  | .order ⟨2, _⟩ ⟨1, _⟩ _ =>
    exact iff_of_true (by omega : (2:ℤ) < 5)
      (@decide_eq_true _ (Classical.dec _) (by omega : (8:ℤ) < 12))
  | .order ⟨2, _⟩ ⟨2, _⟩ h => exact absurd rfl h
  | .order ⟨2, _⟩ ⟨3, _⟩ _ =>
    exact iff_of_true (by omega : (2:ℤ) < 30)
      (@decide_eq_true _ (Classical.dec _) (by omega : (8:ℤ) < 25))
  | .order ⟨3, _⟩ ⟨0, _⟩ _ =>
    exact iff_of_true (by omega : (30:ℤ) < 35)
      (@decide_eq_true _ (Classical.dec _) (by omega : (25:ℤ) < 40))
  | .order ⟨3, _⟩ ⟨1, _⟩ _ =>
    exact iff_of_false (by omega : ¬((30:ℤ) < 5))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((25:ℤ) < 12)))
  | .order ⟨3, _⟩ ⟨2, _⟩ _ =>
    exact iff_of_false (by omega : ¬((30:ℤ) < 2))
      (fun hc => absurd (@of_decide_eq_true _ (Classical.dec _) hc) (by omega : ¬((25:ℤ) < 8)))
  | .order ⟨3, _⟩ ⟨3, _⟩ h => exact absurd rfl h

/-- `m3s` marks the separating inner witness `m3eR` (honest: witnessed by the R-point `10`
    over the fake tail). -/
private theorem m3_s_marks_eR : m3s.2 m3eR = true :=
  @decide_eq_true _ (Classical.dec _) ⟨10, nf_characteristic_satisfies M3M 0 6 (Fin.cons 10 m3tup5)⟩

/-- **The pinned refutation**: `m3s` is realized at the REAL pinned tuple at NO fresh
    witness — its marked inner witness `m3eR` demands an R-point strictly below the w-slot,
    and `R ∩ (2, 5) = ∅`. -/
private theorem m3_noPinned :
    ¬ ∃ z : M3M.carrier, nf_eval_nf M3M 1 5 (Fin.cons z m3realEnv) m3s := by
  rintro ⟨z, hz⟩
  obtain ⟨u, hu⟩ := (hz.2 m3eR).mpr m3_s_marks_eR
  -- the inner witness carries `R` (fresh-slot predicate row of `m3eR`)
  have hu10 : u = 10 := (hu (.pred () 0)).mpr (@decide_eq_true _ (Classical.dec _) (rfl : (10:ℤ) = 10))
  -- `m3eR`'s (fresh, w-slot) order row: `10 < 12` fake-side — pinned it reads `u < 5`
  have hord := hu (.order 0 ⟨3, by omega⟩ (by decide))
  have hlt : u < (5:ℤ) := hord.mpr
    (@decide_eq_true _ (Classical.dec _) (show (10:ℤ) < 12 by omega))
  have h105 : ¬ ((10:ℤ) < (5:ℤ)) := by omega
  rw [hu10] at hlt
  exact h105 hlt

/-! ## The decisive certificates -/

/-- **G2 general-m gate NO-GO certificate — the free-env → pinned upgrade fails at fiber
    depth 1.** The honest gap-zoned fiber element `m3s` satisfies EVERY antecedent of the
    m = 0 upgrade `kvE_futGapItem_pinned_zero` (the load-bearing step of both zone-list
    inclusions of `kvE_futSliceId_of_end_zero`, hence of the planned general-m G2-1
    kernel): gap zone, dropped row realized at the real pinned tuple, free-env occurrence
    at a walk point strictly inside the real gap `(t, x1) = (30, 35)` — yet it is
    pinned-realizable at the real tuple at NO fresh witness. The depth-0 three-channel
    losslessness the m = 0 proof rests on does not survive one fiber level up (D7).
    Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe358_tailDG_gapItem_pinned_fails :
    nfk_zoneSpec m3s = kvE_futGapZone ∧
    nf_eval_nf M3M 0 4 m3realEnv (nfk_dropFresh m3s) ∧
    (∃ env : Fin 4 → M3M.carrier, nf_eval_nf M3M 1 5 (Fin.cons (32:ℤ) env) m3s) ∧
    ((2:ℤ) < 5 ∧ (5:ℤ) < 30 ∧ (30:ℤ) < 32 ∧ (32:ℤ) < 35) ∧
    ¬ ∃ z : M3M.carrier, nf_eval_nf M3M 1 5 (Fin.cons z m3realEnv) m3s :=
  ⟨m3_s_zone, m3_dropRow_real, ⟨m3fakeEnv, m3_s_free⟩,
    ⟨(by omega : (2:ℤ) < 5), (by omega : (5:ℤ) < 30), (by omega : (30:ℤ) < 32),
      (by omega : (32:ℤ) < 35)⟩, m3_noPinned⟩

/-- **The countermodel lives INSIDE the 364-strengthened population.** The fake-tail slice
    `m3sigma` is (i) admissible under the co-realization-strengthened guard — discharged
    through the SANCTIONED byte-stable route `kvE_futRealizer_admissible` on its own honest
    realizer `8 < 12 < 25 < 40` (no guard unfolding), (ii) on the REAL ambient's fiber (its
    dropped row equals the real ambient characteristic's atom layer — the `hsliceFut`
    on-fiber antecedent shape at m = 1), and (iii) marks the un-pinnable gap fiber `m3s` on
    its Future gap zone list (the population `hocc` walks). The honest-unrealizability
    engine (`kvE_probe364_sstar_honest_unrealizable`) has no purchase: every cast element is
    realized. Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe358_tailDG_sigma_in_population :
    kvE_futAdmissible m3sigma = true ∧
    nfk_dropFresh m3sigma = (nf_characteristic M3M 3 3 m3realEnv3).atom_assgn ∧
    m3sigma.2 m3s = true ∧
    m3s ∈ kvE_fiberZoneList m3sigma kvE_futGapZone := by
  have hmark : m3sigma.2 m3s = true :=
    @decide_eq_true _ (Classical.dec _) ⟨32, nf_characteristic_satisfies M3M 1 5 m3tup5⟩
  refine ⟨?_, ?_, hmark, (kvE_fiberZoneList_mem m3sigma kvE_futGapZone m3s).mpr
    ⟨hmark, m3_s_zone⟩⟩
  · exact kvE_futRealizer_admissible M3M m3sigma 40 12 8 25
      (show (8:ℤ) < 12 by omega) (show (12:ℤ) < 25 by omega) (show (25:ℤ) < 40 by omega)
      (nf_characteristic_satisfies M3M 2 4 m3fakeEnv)
  · funext a
    match a with
    | .pred _ ⟨0, _⟩ =>
      exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((12:ℤ) = 10))).trans
        (@decide_eq_false _ (Classical.dec _) (by omega : ¬((5:ℤ) = 10))).symm
    | .pred _ ⟨1, _⟩ =>
      exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((8:ℤ) = 10))).trans
        (@decide_eq_false _ (Classical.dec _) (by omega : ¬((2:ℤ) = 10))).symm
    | .pred _ ⟨2, _⟩ =>
      exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((25:ℤ) = 10))).trans
        (@decide_eq_false _ (Classical.dec _) (by omega : ¬((30:ℤ) = 10))).symm
    | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
    | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
      exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((12:ℤ) < 8))).trans
        (@decide_eq_false _ (Classical.dec _) (by omega : ¬((5:ℤ) < 2))).symm
    | .order ⟨0, _⟩ ⟨2, _⟩ _ =>
      exact (@decide_eq_true _ (Classical.dec _) (by omega : (12:ℤ) < 25)).trans
        (@decide_eq_true _ (Classical.dec _) (by omega : (5:ℤ) < 30)).symm
    | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
      exact (@decide_eq_true _ (Classical.dec _) (by omega : (8:ℤ) < 12)).trans
        (@decide_eq_true _ (Classical.dec _) (by omega : (2:ℤ) < 5)).symm
    | .order ⟨1, _⟩ ⟨1, _⟩ h => exact absurd rfl h
    | .order ⟨1, _⟩ ⟨2, _⟩ _ =>
      exact (@decide_eq_true _ (Classical.dec _) (by omega : (8:ℤ) < 25)).trans
        (@decide_eq_true _ (Classical.dec _) (by omega : (2:ℤ) < 30)).symm
    | .order ⟨2, _⟩ ⟨0, _⟩ _ =>
      exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((25:ℤ) < 12))).trans
        (@decide_eq_false _ (Classical.dec _) (by omega : ¬((30:ℤ) < 5))).symm
    | .order ⟨2, _⟩ ⟨1, _⟩ _ =>
      exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((25:ℤ) < 8))).trans
        (@decide_eq_false _ (Classical.dec _) (by omega : ¬((30:ℤ) < 2))).symm
    | .order ⟨2, _⟩ ⟨2, _⟩ h => exact absurd rfl h

end FormalSystem.Metalogic.WeakCanonical.Kamp
