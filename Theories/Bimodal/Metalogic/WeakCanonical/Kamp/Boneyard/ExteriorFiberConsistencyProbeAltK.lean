/-
ARCHIVED — off-faithful-path (Kamp Boneyard). MOVE-not-delete; do NOT delete or empty.

Retired from the live build ahead of the k>=2 E[Sigma] re-architecture. NOT on the
proof-term path from `completeness_discrete` (0 live importers; outside the Bimodal.lean
import closure, so uncompiled). Fiber-consistency refutation probe (S* / plant rejections).
Machine-checked NO-GO / refutation certificate, retained as evidence. Do NOT consume or
reuse for the faithful re-architecture (off-paper arity-4 object; diverges from Rabinovich
Def 4.1, PDF p.5). Filename de-numbered on archival (durable-anchor discipline).

Key declarations: kvE_probe364_sstar_honest_unrealizable, kvE_probe364_plant_rejected, kvE_probe364_sigma2_sstar_inconsistent
-/
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK

/-! # Strengthened fiber-consistency mate check — probe + regression record (task 364)

Probe module for the task-364 interface strengthening, retained as the PERMANENT regression
record (mirroring the task-363 probe-module precedent). Task 358's route-R2 probe
(`ExteriorPinnedProbe358K.lean`, `kvE_probe358_eP_atomMate_present`) machine-refuted the
task-363 mate check: it was atom-row-only (`mergeNF e.atom_assgn ⟨1,_⟩ = s'.atom_assgn`) and
was defeated by PLANTING the missing row as an unrealizable fiber
`mate := (mergeNF e_P.atom_assgn ⟨1,_⟩, fun _ => false)` inside `σ₂ := τ ⊕ s* ⊕ mate`. The
candidate validated here (Phases 1-3) was PROMOTED to the production home
`ExteriorFiberConsistencyK.lean` (Phase 4): the mate check now additionally requires the mate
to be CO-REALIZED with the ambient (`∃ M env u, σ` realized at `env ∧ s'` realized at
`Fin.cons u env`). All certificates below are stated against the PRODUCTION definitions.

## Candidate adjudication record (Phase 1, design-level)

Three candidate families were adjudicated; the analysis is recorded here because it fixes the
shape of the witness term task 358's G2 supply proof must construct.

* **(a) syntactic mate-content comparison** (the mate's `.2` marking must contain a witness
  row-derived from `e` — swap-row `g.atom_assgn = e.atom_assgn ∘ swap01`, or diagonal-row
  `g.atom_assgn = dupFresh s'.atom_assgn`): REJECTED — short-cycle plantable. The honest
  semantics is reflexive: for `e` realized at `[u, xs, env]`, the swap witness `[xs, u, env]`
  drops (at slot 1) back to the FIBER's own tuple `[xs, env]`, so an adapted plant
  `mate₂ := (mergeNF e_P.atom_assgn ⟨1,_⟩, {swapRow e_P})` has its manufactured content's
  whole obligation set discharged by `s*` itself (`mergeNF (swapRow e_P) ⟨1,_⟩ = s*.atom_assgn`
  and `s*.2 e_P = true`) — a 2-cycle the recursion cannot break, because at the probe's
  critical depth the inner witnesses are depth 0 and rows are all there is to compare. The
  diagonal variant is 1-cycle self-supporting (`dupFresh` is drop-inverse to itself). No
  mechanization is needed to act on this: both cycles are closed by the SAME row identities
  the 358 probe already mechanized.
* **(b) standalone realizability** (`∃ M env₊, s'` realized): REJECTED — defeated by the
  honest-in-M2M adapted mate `mate₃ := nf_characteristic M2M 1 5 [20,25,15,2,21]`, which is
  genuinely realizable, carries exactly the required dropped row, and is interior-zoned
  (invisible to the three exterior slice lists), restoring the mate for `e_P`.
* **(b)-joint synthesis (CHOSEN, promoted)**: the mate must be co-realized WITH the ambient
  `σ`. This is the literature-faithful reading of the fresh-projection channel: Rabinovich's
  Def 4.1 (PDF p.5) interprets every E[Σ]-atom of the canonical expansion as
  `{a ∈ M | M, a ⊨ A}` — point content is REALIZATION content, never free-floating syntax —
  so a mate whose depth-≥1 channel cannot be grounded in any joint realization of the ambient
  is not a Def-4.1 mate at all. Honest preservation is by the witness
  `⟨M, env, u, hσ, nf_characteristic_satisfies⟩` (proved in the production home,
  `kvE_fiberElemConsistent_of_realized`), and the adversarial game closes UNIVERSALLY
  (Gate 3a): any `σ'` marking both `s*` and a single honest fiber is jointly unrealizable —
  `s*` forces an interior `P`-point through its marked witness `e_P`
  (`P v ∧ env'₁ < v < env'₃`), while EVERY honest fiber's quant layer is decided in `M2M`
  (where `P ∩ (15, 18) = ∅`) and therefore marks no 6-type carrying an interior-`P` row
  (`kvE_probe364_sstar_honest_unrealizable`). Slice-equality forces honest (exterior) fibers
  to stay marked, so every re-plant in the countermodel's constraint set is self-defeating —
  not just the two casts below.

## Certificates (all sorry-free, floor axioms)

1. `kvE_probe364_plant_rejected` (Gate 1a) = `kvE_probe364_sigma2_sstar_inconsistent`
   (Phase-5 successor cert 1) — `kvE_fiberElemConsistent m2sigma m2sstar = false`: the
   planted mate no longer discharges the `e_P` obligation, so `s*` fails the strengthened
   guard within `σ₂`. (The raw atom-row fact `kvE_probe358_eP_atomMate_present` remains TRUE
   — the row is present; it merely no longer suffices.)
2. `kvE_probe364_m1fake_rejected` (Gate 1b) — the task-363 m = 1 fake remains rejected.
3. `kvE_probe364_honest_tau_consistent` / `kvE_probe364_honest_fiber_consistent` (Gate 2a) —
   honest preservation on the cast, uniform in `r`, derived from the production
   `_of_realized` lemma (whose statement is byte-identical to task 363's).
4. `kvE_probe364_sstar_honest_unrealizable` + `kvE_probe364_replant_selfdefeating` (Gate 3a)
   — the UNIVERSAL adversarial certificate over every adapted plant `X` keeping `s*` and one
   honest fiber marked, instantiated at the strongest concrete re-plant
   `σ₃ := τ ⊕ s* ⊕ mate₃` (`kvE_probe364_adapted_plant_rejected`), where `mate₃` is the
   honest-in-M2M realizable fiber that DEFEATS both rejected candidate families.
5. `kvE_probe364_sigma2_slice_inconsistent` / `kvE_probe364_sigma2_inadmissible` (Phase-5
   successor certs 2-3) — the σ-level guard and the full production `kvE_futAdmissible`
   reject `σ₂`: the σ₂ doppelgänger no longer defeats G2's exclusion mechanism.

## u-class enumeration cross-check (phase-2 handoff)

The handoff's u-order-class argument (u = 20 P-collision class served by the plant; every
other class by an honest `τ`-fiber under the 18↔21 remap) is superseded at guard level: under
the joint-realization mate check the class bookkeeping never starts, because the AMBIENT σ₂
admits no joint realization at all — the u = 20 class's forced interior `P`-point contradicts
the honest fibers' M2M-decided quant layers (the universal certificate). No per-class mate
supply can service ANY class inside an unrealizable ambient.

Probe conventions: model `(ℤ, <)`, `P = {0,10,20}`, anchors `[25,15,2,18]`, doppelgänger tail
`[25,15,2,21]` (template copies of `ExteriorFiberConsistencyProbeK.lean:82-119` /
`ExteriorPinnedProbe358K.lean:72-120`; the originals are `private`, replication precedent). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Predicate location

The strengthened mate check lives IN PLACE in the production home
(`kvE_fiberElemConsistent` / `kvE_fiberConsistent`, `ExteriorFiberConsistencyK.lean`),
together with the byte-stable `_zero` inertness and `_of_realized` honest-preservation
lemmas. The Phase 1-3 candidate `kvE_fiberElemConsistentV2` was promoted verbatim and the
duplicate dropped (task-363 promotion precedent); this module retains the casts and the
certificates against the production definitions. -/

/-! ## Probe cast (template copies) -/

/-- One-predicate signature for the probe. -/
private abbrev m2sig : MonadicSignature := { preds := Unit }

/-- The probe model `M* = (ℤ, <)` with `P = {0, 10, 20}`. -/
private abbrev M2M : OrderedMonadicStructure m2sig where
  carrier := ℤ
  interp := fun _ z => z = 0 ∨ z = 10 ∨ z = 20
  carrier_order := inferInstance

/-- Ambient anchors `[w, x, t] = [15, 2, 18]`. -/
private def m2env3 : Fin 3 → M2M.carrier := Fin.cons 15 (Fin.cons 2 (fun _ => 18))

/-- Pinned 4-anchors `[x1, w, x, t] = [25, 15, 2, 18]`. -/
private def m2env4 : Fin 4 → M2M.carrier := Fin.cons 25 m2env3

/-- The doppelgänger tail `[25, 15, 2, 21]`. -/
private def m2envF : Fin 4 → M2M.carrier :=
  Fin.cons 25 (Fin.cons 15 (Fin.cons 2 (fun _ => 21)))

/-- The fake world's 5-tuple `[22, 25, 15, 2, 21]`. -/
private def m2tupF : Fin 5 → M2M.carrier := Fin.cons 22 m2envF

/-- The honest endpoint characteristic `τ`. -/
private noncomputable def m2tau : NormalForm m2sig 2 4 := nf_characteristic M2M 2 4 m2env4

/-- The fake gap fiber element `s*`. -/
private noncomputable def m2sstar : NormalForm m2sig 1 5 :=
  nf_characteristic M2M 1 5 m2tupF

/-- The separating inner witness `e_P` (honest inner 6-type of the `P`-point `20` over the
    fake tuple `[20, 22, 25, 15, 2, 21]`). -/
private noncomputable def m2eP : NormalForm m2sig 0 6 :=
  nf_characteristic M2M 0 6 (Fin.cons 20 m2tupF)

/-- **The task-358 planted mate**: the dropped atom row of `e_P` with the ALL-FALSE inner
    marking. -/
private noncomputable def m2mate : NormalForm m2sig 1 5 :=
  (mergeNF (m2eP.atom_assgn) ⟨1, by omega⟩, fun _ => false)

/-- **The 358 countermodel slice** `σ₂ := τ ⊕ s* ⊕ mate`. -/
private noncomputable def m2sigma : NormalForm m2sig 2 4 :=
  (m2tau.1, fun s => if s = m2sstar then true else if s = m2mate then true else m2tau.2 s)

/-- **The task-363 countermodel slice** `σ := τ ⊕ s*` (the m = 1 fake cast). -/
private noncomputable def m1sigma : NormalForm m2sig 2 4 :=
  (m2tau.1, fun s => if s = m2sstar then true else m2tau.2 s)

/-- Alias for the m = 1 gate statement (same fake fiber object). -/
private noncomputable abbrev m1sstar : NormalForm m2sig 1 5 := m2sstar

/-- A fixed honest ray fiber (`r = 30 > 25`, exterior zone — the kind of fiber slice-equality
    FORCES any adapted countermodel slice to keep marked). -/
private noncomputable def m2h30 : NormalForm m2sig 1 5 :=
  nf_characteristic M2M 1 5 (Fin.cons 30 m2env4)

/-! ## Marking facts -/

/-- `σ₂` marks `s*`. -/
private theorem m2_sigma_marks_sstar : m2sigma.2 m2sstar = true := by
  show (if m2sstar = m2sstar then true
    else if m2sstar = m2mate then true else m2tau.2 m2sstar) = true
  rw [if_pos rfl]

/-- `σ` (m = 1 fake) marks `s*`. -/
private theorem m1_sigma_marks_sstar : m1sigma.2 m2sstar = true := by
  show (if m2sstar = m2sstar then true else m2tau.2 m2sstar) = true
  rw [if_pos rfl]

/-- `s*` marks `e_P` (realized at `u = 20` over the fake tuple). -/
private theorem m2_sstar_marks_eP : m2sstar.2 m2eP = true :=
  @decide_eq_true (∃ u : ℤ, nf_eval_nf M2M 0 6 (Fin.cons u m2tupF) m2eP)
    (Classical.dec _) ⟨20, nf_characteristic_satisfies M2M 0 6 _⟩

/-- Row discriminator: the honest ray fiber has `¬(fresh < x1)` (`¬(30 < 25)`). -/
private theorem m2h30_ord01_false :
    m2h30.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide)) = false :=
  @decide_eq_false
    (atom_eval M2M (Fin.cons 30 m2env4) (.order (0 : Fin 5) (1 : Fin 5) (by decide)))
    (Classical.dec _) (show ¬((30 : ℤ) < 25) by omega)

/-- Row discriminator: `s*` has `fresh < x1` (`22 < 25`). -/
private theorem m2sstar_ord01_true :
    m2sstar.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide)) = true :=
  @decide_eq_true (atom_eval M2M m2tupF (.order (0 : Fin 5) (1 : Fin 5) (by decide)))
    (Classical.dec _) (show (22 : ℤ) < 25 by omega)

/-- Row discriminator: the planted mate has `fresh < x1` (dropped `e_P` row: `20 < 25`). -/
private theorem m2mate_ord01_true :
    m2mate.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide)) = true := by
  show m2eP (.order (skipFin ⟨1, by omega⟩ (0 : Fin 5)) (skipFin ⟨1, by omega⟩ (1 : Fin 5))
    ((skipFin_injective _).ne (by decide))) = true
  have hf0 : skipFin (⟨1, by omega⟩ : Fin 6) (0 : Fin 5) = (0 : Fin 6) := by decide
  have hf1 : skipFin (⟨1, by omega⟩ : Fin 6) (1 : Fin 5) = (2 : Fin 6) := by decide
  simp only [hf0, hf1]
  exact @decide_eq_true (atom_eval M2M (Fin.cons 20 m2tupF)
      (.order (0 : Fin 6) (2 : Fin 6) (by decide)))
    (Classical.dec _) (show (20 : ℤ) < 25 by omega)

/-- The honest ray fiber is not the fake (`¬(30 < 25)` vs `22 < 25`). -/
private theorem m2h30_ne_sstar : m2h30 ≠ m2sstar := by
  intro h
  have h1 := congrArg (fun f : NormalForm m2sig 1 5 =>
    f.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide))) h
  simp only at h1
  rw [m2h30_ord01_false, m2sstar_ord01_true] at h1
  exact absurd h1 (by decide)

/-- The honest ray fiber is not the planted mate (`¬(30 < 25)` vs `20 < 25`). -/
private theorem m2h30_ne_mate : m2h30 ≠ m2mate := by
  intro h
  have h1 := congrArg (fun f : NormalForm m2sig 1 5 =>
    f.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide))) h
  simp only at h1
  rw [m2h30_ord01_false, m2mate_ord01_true] at h1
  exact absurd h1 (by decide)

/-- `σ₂` marks the honest ray fiber (through the `τ` arm — realized at the fresh anchor 30). -/
private theorem m2_sigma_marks_h30 : m2sigma.2 m2h30 = true := by
  show (if m2h30 = m2sstar then true
    else if m2h30 = m2mate then true else m2tau.2 m2h30) = true
  rw [if_neg m2h30_ne_sstar, if_neg m2h30_ne_mate]
  exact @decide_eq_true (∃ x : ℤ, nf_eval_nf M2M 1 5 (Fin.cons x m2env4) m2h30)
    (Classical.dec _) ⟨30, nf_characteristic_satisfies M2M 1 5 _⟩

/-- `σ` (m = 1 fake) marks the honest ray fiber. -/
private theorem m1_sigma_marks_h30 : m1sigma.2 m2h30 = true := by
  show (if m2h30 = m2sstar then true else m2tau.2 m2h30) = true
  rw [if_neg m2h30_ne_sstar]
  exact @decide_eq_true (∃ x : ℤ, nf_eval_nf M2M 1 5 (Fin.cons x m2env4) m2h30)
    (Classical.dec _) ⟨30, nf_characteristic_satisfies M2M 1 5 _⟩

/-! ## `e_P`'s separating atoms (raw, un-dropped — the interior-`P` payload) -/

/-- `e_P` records `P` at its fresh slot (`P(20)`). -/
private theorem m2eP_pred0 : m2eP (.pred () (0 : Fin 6)) = true :=
  @decide_eq_true (atom_eval M2M (Fin.cons 20 m2tupF) (.pred () (0 : Fin 6)))
    (Classical.dec _) (show (20 : ℤ) = 0 ∨ (20 : ℤ) = 10 ∨ (20 : ℤ) = 20 by omega)

/-- `e_P` records `w`-slot `<` fresh (`15 < 20`; position 3 is the ambient `w` anchor). -/
private theorem m2eP_ord30 :
    m2eP (.order (3 : Fin 6) (0 : Fin 6) (by decide)) = true :=
  @decide_eq_true (atom_eval M2M (Fin.cons 20 m2tupF)
      (.order (3 : Fin 6) (0 : Fin 6) (by decide)))
    (Classical.dec _) (show (15 : ℤ) < 20 by omega)

/-- `e_P` records fresh `<` `t`-slot (`20 < 21`; position 5 is the ambient `t` anchor). -/
private theorem m2eP_ord05 :
    m2eP (.order (0 : Fin 6) (5 : Fin 6) (by decide)) = true :=
  @decide_eq_true (atom_eval M2M (Fin.cons 20 m2tupF)
      (.order (0 : Fin 6) (5 : Fin 6) (by decide)))
    (Classical.dec _) (show (20 : ℤ) < 21 by omega)

/-! ## The Gate-3a universal engine -/

/-- **Universal joint-unrealizability of `s*`-carrying slices** (Gate 3a engine): ANY slice
    `X : NormalForm m2sig 2 4` that marks the fake fiber `s*` and at least one honest fiber
    `nf_characteristic M2M 1 5 (Fin.cons hf m2env4)` (any `hf : ℤ` — ray, self, or gap) is
    realized in NO model at NO environment. The fake forces an interior `P`-point: `s*` marks
    `e_P`, so a realization yields `v` with `P v ∧ env'₁ < v < env'₃`; but the honest fiber's
    quant layer is DECIDED IN `M2M` (where no `P`-point lies in `(15, 18)`), and marking the
    realized 6-type of `[v, xh, env']` demands an M2M-witness `w₀` with
    `P w₀ ∧ 15 < w₀ < 18` — impossible for `P = {0, 10, 20}`. Since slice-equality forces the
    honest fiber population to stay marked, every adapted re-plant against the joint-realized
    mate check is self-defeating, uniformly. -/
theorem kvE_probe364_sstar_honest_unrealizable (hf : ℤ)
    (X : NormalForm m2sig 2 4)
    (hXs : X.2 m2sstar = true)
    (hXh : X.2 (nf_characteristic M2M 1 5 (Fin.cons hf m2env4)) = true)
    (M' : OrderedMonadicStructure m2sig) (env' : Fin 4 → M'.carrier) :
    ¬ nf_eval_nf M' 2 4 env' X := by
  intro hX
  -- the fake fiber is realized somewhere over env'
  obtain ⟨xs, hxs⟩ := (hX.2 m2sstar).mpr hXs
  -- its marked witness e_P is realized: an interior P-point v appears
  obtain ⟨v, hv⟩ := (hxs.2 m2eP).mpr m2_sstar_marks_eP
  have hPv : M'.interp () v := (hv (.pred () (0 : Fin 6))).mpr m2eP_pred0
  have h1v : env' 1 < v := (hv (.order (3 : Fin 6) (0 : Fin 6) (by decide))).mpr m2eP_ord30
  have hv3 : v < env' 3 := (hv (.order (0 : Fin 6) (5 : Fin 6) (by decide))).mpr m2eP_ord05
  -- the honest fiber is realized somewhere over env'
  obtain ⟨xh, hxh⟩ := (hX.2 _).mpr hXh
  -- the realized 6-type of [v, xh, env'] must be marked by the honest fiber's M2M layer
  have hbit : (nf_characteristic M2M 1 5 (Fin.cons hf m2env4)).2
      (nf_characteristic M' 0 6 (Fin.cons v (Fin.cons xh env'))) = true :=
    (hxh.2 _).mp ⟨v, nf_characteristic_satisfies M' 0 6 _⟩
  obtain ⟨w₀, hw₀⟩ := @of_decide_eq_true
    (∃ x : ℤ, nf_eval_nf M2M 0 6 (Fin.cons x (Fin.cons hf m2env4))
      (nf_characteristic M' 0 6 (Fin.cons v (Fin.cons xh env'))))
    (Classical.dec _) hbit
  -- read the three interior-P atoms through the characteristic, back into M2M
  have hχP : (nf_characteristic M' 0 6 (Fin.cons v (Fin.cons xh env')))
      (.pred () (0 : Fin 6)) = true :=
    @decide_eq_true (atom_eval M' (Fin.cons v (Fin.cons xh env')) (.pred () (0 : Fin 6)))
      (Classical.dec _) hPv
  have hχ30 : (nf_characteristic M' 0 6 (Fin.cons v (Fin.cons xh env')))
      (.order (3 : Fin 6) (0 : Fin 6) (by decide)) = true :=
    @decide_eq_true (atom_eval M' (Fin.cons v (Fin.cons xh env'))
        (.order (3 : Fin 6) (0 : Fin 6) (by decide)))
      (Classical.dec _) h1v
  have hχ05 : (nf_characteristic M' 0 6 (Fin.cons v (Fin.cons xh env')))
      (.order (0 : Fin 6) (5 : Fin 6) (by decide)) = true :=
    @decide_eq_true (atom_eval M' (Fin.cons v (Fin.cons xh env'))
        (.order (0 : Fin 6) (5 : Fin 6) (by decide)))
      (Classical.dec _) hv3
  have hw₀P : (w₀ : ℤ) = 0 ∨ w₀ = 10 ∨ w₀ = 20 :=
    (hw₀ (.pred () (0 : Fin 6))).mpr hχP
  have hw₀15 : (15 : ℤ) < w₀ :=
    (hw₀ (.order (3 : Fin 6) (0 : Fin 6) (by decide))).mpr hχ30
  have hw₀18 : w₀ < (18 : ℤ) :=
    (hw₀ (.order (0 : Fin 6) (5 : Fin 6) (by decide))).mpr hχ05
  omega

/-! ## Gate 3a — universal guard-level self-defeat of every adapted plant -/

set_option maxRecDepth 8000 in
/-- **Gate 3a (candidate survives, universally — against the PRODUCTION guard)**: for EVERY
    adapted countermodel slice `X` that marks `s*` and the honest ray fiber (the fiber
    population slice-equality forces), the strengthened `kvE_fiberElemConsistent` rejects
    `s*` within `X`: the mate obligation at `e_P` demands a joint realization of `X`, which
    `kvE_probe364_sstar_honest_unrealizable` refutes. This quantifies over ALL manufactured
    mate contents at once — the swap-row 2-cycle plant, the diagonal 1-cycle plant, the
    all-false 358 plant, and the honest-in-M2M realizable mate alike. -/
theorem kvE_probe364_replant_selfdefeating (X : NormalForm m2sig 2 4)
    (hXs : X.2 m2sstar = true) (hXh : X.2 m2h30 = true) :
    kvE_fiberElemConsistent X m2sstar = false := by
  cases hc : kvE_fiberElemConsistent X m2sstar with
  | false => rfl
  | true =>
    exfalso
    rw [kvE_fiberElemConsistent, Bool.and_eq_true] at hc
    have hA := hc.1
    rw [List.all_eq_true] at hA
    have h1 := hA m2eP (kvE_nf_mem_univ_toList _)
    rw [Bool.or_eq_true] at h1
    rcases h1 with h1 | h1
    · rw [m2_sstar_marks_eP] at h1
      exact absurd h1 (by decide)
    · rw [List.any_eq_true] at h1
      obtain ⟨s', -, hs'⟩ := h1
      rw [Bool.and_eq_true] at hs'
      obtain ⟨-, hreal⟩ := hs'
      obtain ⟨M', env', u, hσ, -⟩ := @of_decide_eq_true
        (∃ (M : OrderedMonadicStructure m2sig) (env : Fin 4 → M.carrier) (u : M.carrier),
          nf_eval_nf M 2 4 env X ∧ nf_eval_nf M 1 5 (Fin.cons u env) s')
        (Classical.dec _) hreal
      exact kvE_probe364_sstar_honest_unrealizable 30 X hXs hXh M' env' hσ

/-! ## Gates 1a / 1b — the two mandated casts (production guard) -/

/-- **Gate 1a (plant rejection) = Phase-5 successor certificate 1**: under the strengthened
    production guard, the planted mate no longer discharges the mate obligation for `e_P`,
    so `s*` fails the guard within `σ₂ = τ ⊕ s* ⊕ mate`. (The raw atom-row fact
    `kvE_probe358_eP_atomMate_present` remains TRUE — the row is present; it merely no
    longer suffices.) -/
theorem kvE_probe364_plant_rejected :
    kvE_fiberElemConsistent m2sigma m2sstar = false :=
  kvE_probe364_replant_selfdefeating m2sigma m2_sigma_marks_sstar m2_sigma_marks_h30

/-- **Phase-5 successor certificate 1 (canonical DoD name)**: the strengthened production
    guard rejects `s*` within `σ₂`. -/
theorem kvE_probe364_sigma2_sstar_inconsistent :
    kvE_fiberElemConsistent m2sigma m2sstar = false :=
  kvE_probe364_plant_rejected

/-- **Gate 1b (m = 1 fake still rejected)**: task 363's original doppelgänger fiber remains
    rejected within `σ = τ ⊕ s*` — no regression on the 363 exclusion. -/
theorem kvE_probe364_m1fake_rejected :
    kvE_fiberElemConsistent m1sigma m1sstar = false :=
  kvE_probe364_replant_selfdefeating m1sigma m1_sigma_marks_sstar m1_sigma_marks_h30

/-! ## Gate 3a instance — the strongest concrete re-plant

`mate₃ := nf_characteristic M2M 1 5 [20, 25, 15, 2, 21]` is the strongest adapted plant: a
GENUINELY realizable (standalone) fiber, carrying exactly the required dropped row of `e_P`
(depth-0 indistinguishable from the 358 plant), with fully honest depth-≥1 content — it
defeats both rejected candidate families ((a) syntactic content, (b) standalone
realizability). Under the joint-realization check it is still self-defeating. -/

/-- The honest-in-M2M adapted mate `mate₃` over `[20, 25, 15, 2, 21]`. -/
private noncomputable def m2mate3 : NormalForm m2sig 1 5 :=
  nf_characteristic M2M 1 5 (Fin.cons 20 m2envF)

/-- **The adapted countermodel slice** `σ₃ := τ ⊕ s* ⊕ mate₃`. -/
private noncomputable def m2sigma3 : NormalForm m2sig 2 4 :=
  (m2tau.1, fun s => if s = m2sstar then true else if s = m2mate3 then true else m2tau.2 s)

/-- `σ₃` marks `s*`. -/
private theorem m2_sigma3_marks_sstar : m2sigma3.2 m2sstar = true := by
  show (if m2sstar = m2sstar then true
    else if m2sstar = m2mate3 then true else m2tau.2 m2sstar) = true
  rw [if_pos rfl]

/-- Row discriminator: `mate₃` has `fresh < x1` (`20 < 25`). -/
private theorem m2mate3_ord01_true :
    m2mate3.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide)) = true :=
  @decide_eq_true (atom_eval M2M (Fin.cons 20 m2envF)
      (.order (0 : Fin 5) (1 : Fin 5) (by decide)))
    (Classical.dec _) (show (20 : ℤ) < 25 by omega)

/-- The honest ray fiber is not `mate₃`. -/
private theorem m2h30_ne_mate3 : m2h30 ≠ m2mate3 := by
  intro h
  have h1 := congrArg (fun f : NormalForm m2sig 1 5 =>
    f.1 (.order (0 : Fin 5) (1 : Fin 5) (by decide))) h
  simp only at h1
  rw [m2h30_ord01_false, m2mate3_ord01_true] at h1
  exact absurd h1 (by decide)

/-- `σ₃` marks the honest ray fiber (through the `τ` arm). -/
private theorem m2_sigma3_marks_h30 : m2sigma3.2 m2h30 = true := by
  show (if m2h30 = m2sstar then true
    else if m2h30 = m2mate3 then true else m2tau.2 m2h30) = true
  rw [if_neg m2h30_ne_sstar, if_neg m2h30_ne_mate3]
  exact @decide_eq_true (∃ x : ℤ, nf_eval_nf M2M 1 5 (Fin.cons x m2env4) m2h30)
    (Classical.dec _) ⟨30, nf_characteristic_satisfies M2M 1 5 _⟩

/-- **Gate 3a (concrete instance)**: the strongest adapted plant is self-defeating — `s*`
    still fails the strengthened guard within `σ₃ = τ ⊕ s* ⊕ mate₃`. -/
theorem kvE_probe364_adapted_plant_rejected :
    kvE_fiberElemConsistent m2sigma3 m2sstar = false :=
  kvE_probe364_replant_selfdefeating m2sigma3 m2_sigma3_marks_sstar m2_sigma3_marks_h30

/-! ## Gate 2a — honest cast certificates (derived from the production `_of_realized`) -/

/-- **Gate 2a (σ-level)**: the honest endpoint characteristic `τ` passes the strengthened
    production guard. -/
theorem kvE_probe364_honest_tau_consistent : kvE_fiberConsistent m2tau = true :=
  kvE_fiberConsistent_of_realized M2M m2env4 m2tau
    (nf_characteristic_satisfies M2M 2 4 m2env4)

/-- **Gate 2a (per-fiber, uniform in `r`)**: EVERY honest pinned fiber — gap (`r ∈ (18,25)`),
    self (`r = 25`), ray (`r > 25`) — is elem-consistent within `τ` under the strengthened
    production guard. -/
theorem kvE_probe364_honest_fiber_consistent (r : ℤ) :
    kvE_fiberElemConsistent m2tau (nf_characteristic M2M 1 5 (Fin.cons r m2env4)) = true :=
  kvE_fiberElemConsistent_of_realized M2M m2env4 r m2tau _
    (nf_characteristic_satisfies M2M 2 4 m2env4)
    (nf_characteristic_satisfies M2M 1 5 (Fin.cons r m2env4))

/-! ## Phase-5 successor certificates 2-3 — σ-level and full-admissibility rejection of σ₂ -/

set_option maxRecDepth 8000 in
/-- **Phase-5 successor certificate 2**: `σ₂ = τ ⊕ s* ⊕ mate` fails the σ-level guard — it
    marks the (now correctly rejected) elem-inconsistent `s*`. -/
theorem kvE_probe364_sigma2_slice_inconsistent : kvE_fiberConsistent m2sigma = false := by
  cases hc : kvE_fiberConsistent m2sigma with
  | false => rfl
  | true =>
    exfalso
    rw [kvE_fiberConsistent, List.all_eq_true] at hc
    have h := hc m2sstar (kvE_nf_mem_univ_toList _)
    rw [Bool.or_eq_true] at h
    rcases h with h | h
    · rw [m2_sigma_marks_sstar] at h
      exact absurd h (by decide)
    · rw [kvE_probe364_sigma2_sstar_inconsistent] at h
      exact absurd h (by decide)

set_option maxRecDepth 8000 in
/-- **Phase-5 successor certificate 3 (DoD)**: against the strengthened production
    `kvE_futAdmissible`, the 358 countermodel slice `σ₂ = τ ⊕ s* ⊕ mate` is INADMISSIBLE —
    conjunct 2's fiber-consistency guard fires at the marked `s*`. The σ₂ doppelgänger no
    longer defeats G2's exclusion mechanism: `kvE_futAdmissible σ₂ = true` (the universal the
    not-yet-mechanized u-class enumeration was meant to establish) is now FALSE. -/
theorem kvE_probe364_sigma2_inadmissible : kvE_futAdmissible m2sigma = false := by
  cases hc : kvE_futAdmissible m2sigma with
  | false => rfl
  | true =>
    exfalso
    rw [kvE_futAdmissible, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hc
    have h2 := hc.1.1.2
    rw [List.all_eq_true] at h2
    have h := h2 m2sstar (kvE_nf_mem_univ_toList _)
    rw [Bool.or_eq_true] at h
    rcases h with h | h
    · rw [Bool.and_eq_true] at h
      have hcons := h.2
      rw [kvE_probe364_sigma2_sstar_inconsistent] at hcons
      exact absurd hcons (by decide)
    · rw [m2_sigma_marks_sstar] at h
      exact absurd h (by decide)

end Bimodal.Metalogic.WeakCanonical.Kamp
