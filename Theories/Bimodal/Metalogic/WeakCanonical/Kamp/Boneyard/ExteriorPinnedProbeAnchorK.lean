/-
ARCHIVED — off-faithful-path (Kamp Boneyard). MOVE-not-delete; do NOT delete or empty.

Retired from the live build ahead of the k>=2 E[Sigma] re-architecture. NOT on the
proof-term path from `completeness_discrete` (0 live importers; outside the Bimodal.lean
import closure, so uncompiled). Pinned atom-mate probe (imports the archived fiber-consistency probe).
Machine-checked NO-GO / refutation certificate, retained as evidence. Do NOT consume or
reuse for the faithful re-architecture (off-paper arity-4 object; diverges from Rabinovich
Def 4.1, PDF p.5). Filename de-numbered on archival (durable-anchor discipline).

Key declarations: kvE_probe358_eP_atomMate_present
-/
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.ExteriorFiberConsistencyProbeK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# G2 residual-hole probe against the task-363 interface (task 358, plan-v04 P2 gate)

Machine-adjudicates the task-358 plan-v04 Phase-2 gate (route R2: probe BEFORE landing). The
plan re-keys the G2 exterior slice supply (rows 8-11) to task 363's depth-graded
fiber-consistency guard, on the premise (report 06 / P1 anchor-content gate) that 363
"overturns" the m = 1 doppelganger countermodel of `ExteriorPinnedProbeM1K.lean`. This probe
adjudicates whether that premise HOLDS at binder strength for the FROZEN `hsliceFut` shape.

## The residual hole (the planted-mate move)

Task 363's guard rejects the fake-carrying slice `sigma = tau (+) s*` because the fake gap
fiber `s*` marks the inner witness `e_P` (the honest inner 6-type of the `P`-point `20` over
the doppelganger tail `[25,15,2,21]`) whose dropped atom row `mergeNF e_P.atom_assgn <1>` has
**no atom-layer mate** among the `sigma`-marked fibers (`kvE_probe363_fake_elem_inconsistent`,
`ExteriorFiberConsistencyProbeK.lean:191`). But `kvE_fiberElemConsistent`'s mate check
(`ExteriorFiberConsistencyK.lean:52-55`) compares ONLY atom rows -- `mergeNF e.atom_assgn <1> =
s'.atom_assgn` -- and imposes NO realizability, consistency-nontriviality, or fresh-projection
constraint on the mate `s'`. So the adversary PLANTS the exact missing atom row as a fiber:

  `mate := (mergeNF e_P.atom_assgn <1>, fun _ => false)`

-- the dropped row of `e_P` equipped with the ALL-FALSE inner marking. `mate` is
* on `sigma`'s atom fiber (drop-drop = the doppelganger 4-row = `tau.1`, the same depth-0
  indistinguishability of `[25,15,2,21]`/`[25,15,2,18]` that admits `s*` itself),
* vacuously elem-consistent within any ambient (its `.2` is constantly false, so
  `kvE_fiberElemConsistent . mate` has both universal conjuncts trivially satisfied), and
* interior-zoned (fresh `20` in `(15,18)` relative to the real anchors), hence in NO exterior
  (gap/ray/self) zone bucket, so the three slice-lists of `sigma2 := tau (+) s* (+) mate`
  equal those of `sigma = tau (+) s*`, and the `hsliceFut` conclusion still fails
  (`m1_no_marked_mate` carries over: `s*` is pinned-unrealizable).

**Decisive certificate** (`kvE_probe358_eP_atomMate_present`, below, sorry-free): the atom-layer
mate 363 declared absent for `e_P` IS present in `sigma2` -- precisely negating the load-bearing
step of `kvE_probe363_fake_elem_inconsistent`. Consequently the atom-only mate check no longer
excludes the `s*` fiber at the `e_P` witness, and 363's guard fails to reject `sigma2` at the
point its exclusion proof depended on.

## SUPERSESSION RECORD (task 364)

The residual hole certified below was CLOSED by task 364: `kvE_fiberElemConsistent`'s mate
check (`ExteriorFiberConsistencyK.lean`) now additionally requires the mate to be CO-REALIZED
with the ambient sigma (`∃ M env u, sigma realized at env ∧ s' realized at Fin.cons u env`).
The decisive certificate `kvE_probe358_eP_atomMate_present` REMAINS TRUE and green — it is a
raw atom-row fact (the row is present in sigma2); it merely NO LONGER SUFFICES, because the
planted mate is grounded in no joint realization of sigma2. The guard-level successor
certificates live in `ExteriorFiberConsistencyProbe364K.lean`:
`kvE_probe364_sigma2_sstar_inconsistent` (`kvE_fiberElemConsistent m2sigma m2sstar = false`),
`kvE_probe364_sigma2_slice_inconsistent` (`kvE_fiberConsistent m2sigma = false`), and
`kvE_probe364_sigma2_inadmissible` (`kvE_futAdmissible m2sigma = false`) — the sigma2
doppelganger no longer defeats G2's exclusion mechanism, and the adversarial game is closed
UNIVERSALLY (`kvE_probe364_sstar_honest_unrealizable`: any slice marking `s*` plus one honest
fiber is realized in no model). This module is retained verbatim below as the permanent
NO-GO record against the PRE-364 interface.

## VERDICT: **NO-GO** -- G2 rows 8-11 not servable against the 363 interface as landed
(SUPERSEDED by task 364 — see the supersession record above)

The task-363 mate check is defeatable by planting an unrealizable interior-zoned mate. Full
mechanization of `kvE_futAdmissible sigma2 = true` (the sigma2-level universal: every
`s*`-marked inner witness has a mate -- the u = 20 P-collision via `mate`, every other
order-class via an honest `tau`-fiber, by the doppelganger order-remap) is itself research-scale
and is the deliverable of the escalation task, not this gate. This gate's job (route R2) is to
decide GO/NO-GO for building the G2 kernels on the current interface; the decisive certificate
below shows the interface's exclusion mechanism is holed at exactly the witness 363 relied on,
so building the kernels would re-encounter the countermodel. Plan-v04 P2/P3 are therefore
[BLOCKED]; the escalation is a strengthened mate check (realizability-anchored or depth-recursive
mate CONTENT comparison, not atom-row-only), spawned as a new 363-style interface task -- never a
sorry.

**G1 (rows 5-6) is NOT re-broken by this cast**: `mate` is projection-VISIBLE (`P` at its fresh
atom prefix has no honest counterpart in the cast), so the fake ambient `qnf (+) sigma2` has
`igFoldBit /=` the honest ambient's and its `igPtW` guard is not satisfied by honest walk points
-- the separation 363 built for the interior leg stands.

Probe conventions: model `(Int, <)`, `P = {0,10,20}`, anchors `[25,15,2,18]`, doppelganger tail
`[25,15,2,21]` (template copies of `ExteriorFiberConsistencyProbeK.lean:82-119`; the originals
are `private`, replication precedent). Purely additive NEW leaf probe module; no production file
is touched. -/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Probe cast (template copies) -/

/-- One-predicate signature for the probe. -/
private abbrev m2sig : MonadicSignature := { preds := Unit }

/-- The probe model `M* = (Int, <)` with `P = {0, 10, 20}`. -/
private abbrev M2M : OrderedMonadicStructure m2sig where
  carrier := ℤ
  interp := fun _ z => z = 0 ∨ z = 10 ∨ z = 20
  carrier_order := inferInstance

/-- Ambient anchors `[w, x, t] = [15, 2, 18]`. -/
private def m2env3 : Fin 3 → M2M.carrier := Fin.cons 15 (Fin.cons 2 (fun _ => 18))

/-- Pinned 4-anchors `[x1, w, x, t] = [25, 15, 2, 18]`. -/
private def m2env4 : Fin 4 → M2M.carrier := Fin.cons 25 m2env3

/-- The doppelganger tail `[25, 15, 2, 21]`. -/
private def m2envF : Fin 4 → M2M.carrier :=
  Fin.cons 25 (Fin.cons 15 (Fin.cons 2 (fun _ => 21)))

/-- The fake world's 5-tuple `[22, 25, 15, 2, 21]`. -/
private def m2tupF : Fin 5 → M2M.carrier := Fin.cons 22 m2envF

/-- The honest endpoint characteristic `tau`. -/
private noncomputable def m2tau : NormalForm m2sig 2 4 := nf_characteristic M2M 2 4 m2env4

/-- The fake gap fiber element `s*`. -/
private noncomputable def m2sstar : NormalForm m2sig 1 5 :=
  nf_characteristic M2M 1 5 m2tupF

/-- The separating inner witness `e_P` (honest inner 6-type of the `P`-point `20` over the fake
    tuple) -- the witness whose missing atom-mate dissolved the pre-363 countermodel. -/
private noncomputable def m2eP : NormalForm m2sig 0 6 :=
  nf_characteristic M2M 0 6 (Fin.cons 20 m2tupF)

/-- **The planted mate**: the dropped atom row of `e_P` (the `P`-point-`20` 5-row over the
    doppelganger tail) equipped with the ALL-FALSE inner marking. -/
private noncomputable def m2mate : NormalForm m2sig 1 5 :=
  (mergeNF (m2eP.atom_assgn) ⟨1, by omega⟩, fun _ => false)

/-- **The adapted countermodel slice** `sigma2 := tau (+) s* (+) mate`. -/
private noncomputable def m2sigma : NormalForm m2sig 2 4 :=
  (m2tau.1, fun s => if s = m2sstar then true else if s = m2mate then true else m2tau.2 s)

/-- `sigma2` marks the planted mate. -/
private theorem m2_sigma_marks_mate : m2sigma.2 m2mate = true := by
  show (if m2mate = m2sstar then true
    else if m2mate = m2mate then true else m2tau.2 m2mate) = true
  by_cases h : m2mate = m2sstar
  · rw [if_pos h]
  · rw [if_neg h, if_pos rfl]

/-! ## The decisive certificate: the atom-mate 363 declared absent is present -/

/-- **P2 NO-GO certificate -- the atom-mate hole at `e_P`.** The `sigma2`-marked planted `mate`
    has atom row exactly `mergeNF e_P.atom_assgn <1>` -- the dropped row of `s*`'s separating
    inner witness `e_P`. This is precisely the atom-layer mate that
    `kvE_probe363_fake_elem_inconsistent` (`ExteriorFiberConsistencyProbeK.lean`) proved ABSENT
    among `sigma = tau (+) s*`'s marked fibers, and on whose absence 363's rejection of the fake
    slice depends. Its presence in `sigma2` shows the atom-row-only mate check
    (`kvE_fiberElemConsistent`, `ExteriorFiberConsistencyK.lean:52-55`) no longer excludes the
    `s*` fiber at the `e_P` witness -- the residual hole in the task-363 interface that blocks
    the G2 rows-8-11 general-m supply. Sorry-free; axioms `[propext, Classical.choice,
    Quot.sound]`.

    **Task-364 supersession**: this statement remains TRUE against the strengthened interface
    (it is a raw atom-row fact), but the row alone no longer discharges the mate obligation —
    the strengthened `kvE_fiberElemConsistent` additionally demands joint co-realization with
    `sigma2`, which fails (`kvE_probe364_sigma2_sstar_inconsistent`,
    `ExteriorFiberConsistencyProbe364K.lean`). Kept green as the permanent atom-row
    regression record. -/
theorem kvE_probe358_eP_atomMate_present :
    ∃ s' : NormalForm m2sig 1 5, m2sigma.2 s' = true ∧
      mergeNF (m2eP.atom_assgn) ⟨1, by omega⟩ = s'.atom_assgn :=
  ⟨m2mate, m2_sigma_marks_mate, rfl⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
