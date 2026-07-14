import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK

/-! # Strengthened fiber-consistency mate check — probe leaf (task 364, GO/NO-GO gates)

NON-PRODUCTION probe module for the task-364 interface strengthening. Task 358's route-R2
probe (`ExteriorPinnedProbe358K.lean`, `kvE_probe358_eP_atomMate_present`) machine-refuted the
task-363 mate check: it is atom-row-only (`mergeNF e.atom_assgn ⟨1,_⟩ = s'.atom_assgn`) and is
defeated by PLANTING the missing row as an unrealizable fiber
`mate := (mergeNF e_P.atom_assgn ⟨1,_⟩, fun _ => false)` inside `σ₂ := τ ⊕ s* ⊕ mate`. This
module defines the strengthened CANDIDATE (`kvE_fiberElemConsistentV2`) and machine-validates
it on the m = 1 and m = 2 casts before any production file is touched.

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
* **(b)-joint synthesis (CHOSEN)**: the mate must be co-realized WITH the ambient `σ`:
  `∃ M env u, σ realized at env ∧ s' realized at Fin.cons u env`. This is the
  literature-faithful reading of the fresh-projection channel: Rabinovich's Def 4.1 (PDF p.5)
  interprets every E[Σ]-atom of the canonical expansion as `{a ∈ M | M, a ⊨ A}` — point
  content is REALIZATION content, never free-floating syntax — so a mate whose depth-≥1
  channel cannot be grounded in any joint realization is not a Def-4.1 mate at all. Honest
  preservation is by the witness `⟨M, env, u, hσ, nf_characteristic_satisfies⟩` (Gate 2a), and
  the adversarial game closes UNIVERSALLY (Gate 3a): any `σ'` marking both `s*` and a single
  honest fiber is jointly unrealizable — `s*` forces an interior `P`-point through its marked
  witness `e_P` (`P v ∧ env'₁ < v < env'₃`), while EVERY honest fiber's quant layer is decided
  in `M2M` (where `P ∩ (15, 18) = ∅`) and therefore marks no 6-type carrying an interior-`P`
  row (`kvE_probe364_sstar_honest_unrealizable`). Slice-equality forces honest (exterior)
  fibers to stay marked, so every re-plant in the countermodel's constraint set is
  self-defeating — not just the two casts below.

## Gates (all sorry-free)

1. `kvE_probe364_plant_rejected`  (Gate 1a) — `kvE_fiberElemConsistentV2 m2sigma m2sstar =
   false`: under the candidate the planted mate no longer discharges the `e_P` obligation, so
   `s*` fails the guard within `σ₂`.
2. `kvE_probe364_m1fake_rejected` (Gate 1b) — `kvE_fiberElemConsistentV2 m1sigma m1sstar =
   false`: task 363's original m = 1 fake remains rejected.
3. `kvE_fiberElemConsistentV2_of_realized` / `kvE_fiberConsistentV2_of_realized` (Gate 2a
   crux) — honest preservation in full generality (any model, any env), plus the depth-0
   inertness pair and the honest cast certificates (`τ` and all pinned fibers, uniform in `r`).
4. `kvE_probe364_sstar_honest_unrealizable` + `kvE_probe364_replant_selfdefeating` (Gate 3a) —
   the UNIVERSAL adversarial certificate quantifying over every adapted plant `X` that keeps
   `s*` and one honest fiber marked, instantiated at the strongest concrete re-plant
   `σ₃ := τ ⊕ s* ⊕ mate₃` (`kvE_probe364_adapted_plant_rejected`), where `mate₃` is the
   honest-in-M2M realizable fiber that DEFEATS both rejected candidate families.

## u-class enumeration cross-check (phase-2 handoff)

The handoff's u-order-class argument (u = 20 P-collision class served by the plant; every
other class by an honest `τ`-fiber under the 18↔21 remap) is superseded at guard level: under
the joint-realization mate check the class bookkeeping never starts, because the AMBIENT σ₂
admits no joint realization at all — the u = 20 class's forced interior `P`-point contradicts
the honest fibers' M2M-decided quant layers (the universal certificate). No per-class mate
supply can service ANY class inside an unrealizable ambient.

Probe conventions: model `(ℤ, <)`, `P = {0,10,20}`, anchors `[25,15,2,18]`, doppelgänger tail
`[25,15,2,21]` (template copies of `ExteriorFiberConsistencyProbeK.lean:82-119` /
`ExteriorPinnedProbe358K.lean:72-120`; the originals are `private`, replication precedent).
Purely additive NEW leaf probe module; no production file is touched by Phases 1-3. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## The strengthened candidate -/

/-- **Task-364 candidate guard** (approach (b)-joint synthesis): per-fiber depth-graded
    consistency of a fiber `s` within an ambient `σ` marking it. Relative to the task-363
    production `kvE_fiberElemConsistent`, the mate check gains ONE conjunct: the mate `s'`
    must be co-realized with `σ` in some model — `∃ M env u, σ` realized at `env` and `s'`
    realized at `Fin.cons u env`. The depth-0 arm is literally `true` (m = 0 inertness,
    `rfl`-stable), and the depth recursion arm is untouched. Model-independent (no model
    parameter; the existential is internal) and `Bool`-valued via classical decidability —
    the def was already `noncomputable` at task 363. -/
noncomputable def kvE_fiberElemConsistentV2 {sig : MonadicSignature} :
    {k n : Nat} → NormalForm sig (k + 1) n → NormalForm sig k (n + 1) → Bool
  | 0, _, _, _ => true
  | (j + 1), n, σ, s =>
    ((Finset.univ.toList (α := NormalForm sig j (n + 2))).all fun e =>
      !(s.2 e) ||
        ((Finset.univ.toList (α := NormalForm sig (j + 1) (n + 1))).any fun s' =>
          σ.2 s' && decide (mergeNF (e.atom_assgn) ⟨1, by omega⟩ = s'.atom_assgn) &&
            @decide (∃ (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
                (u : M.carrier),
                nf_eval_nf M (j + 2) n env σ ∧
                nf_eval_nf M (j + 1) (n + 1) (Fin.cons u env) s')
              (Classical.dec _))) &&
    ((Finset.univ.toList (α := NormalForm sig j (n + 2))).all fun e =>
      !(s.2 e) || kvE_fiberElemConsistentV2 s e)

/-- σ-level candidate guard: every `σ`-marked fiber is V2-elem-consistent. -/
noncomputable def kvE_fiberConsistentV2 {sig : MonadicSignature} {k n : Nat}
    (σ : NormalForm sig (k + 1) n) : Bool :=
  (Finset.univ.toList (α := NormalForm sig k (n + 1))).all fun s =>
    !(σ.2 s) || kvE_fiberElemConsistentV2 σ s

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
/-- **Gate 3a (candidate survives, universally)**: for EVERY adapted countermodel slice `X`
    that marks `s*` and the honest ray fiber (the fiber population slice-equality forces),
    the strengthened guard rejects `s*` within `X`: the mate obligation at `e_P` demands a
    joint realization of `X`, which `kvE_probe364_sstar_honest_unrealizable` refutes. This
    quantifies over ALL manufactured mate contents at once — the swap-row 2-cycle plant, the
    diagonal 1-cycle plant, the all-false 358 plant, and the honest-in-M2M realizable mate
    alike. -/
theorem kvE_probe364_replant_selfdefeating (X : NormalForm m2sig 2 4)
    (hXs : X.2 m2sstar = true) (hXh : X.2 m2h30 = true) :
    kvE_fiberElemConsistentV2 X m2sstar = false := by
  cases hc : kvE_fiberElemConsistentV2 X m2sstar with
  | false => rfl
  | true =>
    exfalso
    rw [kvE_fiberElemConsistentV2, Bool.and_eq_true] at hc
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

/-! ## Gates 1a / 1b — the two mandated casts -/

/-- **Gate 1a (plant rejection)**: under the strengthened candidate, the planted mate no
    longer discharges the mate obligation for `e_P`, so `s*` fails the guard within
    `σ₂ = τ ⊕ s* ⊕ mate`. (The raw atom-row fact `kvE_probe358_eP_atomMate_present` remains
    TRUE — the row is present; it merely no longer suffices.) -/
theorem kvE_probe364_plant_rejected :
    kvE_fiberElemConsistentV2 m2sigma m2sstar = false :=
  kvE_probe364_replant_selfdefeating m2sigma m2_sigma_marks_sstar m2_sigma_marks_h30

/-- **Gate 1b (m = 1 fake still rejected)**: task 363's original doppelgänger fiber remains
    rejected within `σ = τ ⊕ s*` — no regression on the 363 exclusion. -/
theorem kvE_probe364_m1fake_rejected :
    kvE_fiberElemConsistentV2 m1sigma m1sstar = false :=
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
    kvE_fiberElemConsistentV2 m2sigma3 m2sstar = false :=
  kvE_probe364_replant_selfdefeating m2sigma3 m2_sigma3_marks_sstar m2_sigma3_marks_h30

/-! ## Phase 2 — honest preservation for the candidate (the crux)

The strengthened guard must accept every honestly realized fiber, in full generality (any
model, any environment). The extra proof obligation over the task-363 argument is exactly one
witness: the characteristic mate `nf_characteristic M (j+1) (n+1) (Fin.cons u env)` is
co-realized with `σ` BY CONSTRUCTION — `⟨M, env, u, hσ, nf_characteristic_satisfies⟩`. This is
the adjudication checkpoint's dischargeability test for the chosen candidate, and it passes
without any new bookkeeping lemma beyond the task-363 `cons_cons_skipOne` (replicated here;
the original is `private` in the production home). -/

/-- Environment bookkeeping for the mate check: dropping slot 1 from the doubly-extended
    tuple `[u, xs, env]` leaves `[u, env]` (template copy of the `private` production
    original, `ExteriorFiberConsistencyK.lean:90`). -/
private theorem cons_cons_skipOne364 {α : Type _} {n : Nat} (u xs : α) (env : Fin n → α)
    (i : Fin (n + 1)) :
    (Fin.cons u (Fin.cons xs env) : Fin (n + 2) → α) (skipFin ⟨1, by omega⟩ i) =
      (Fin.cons u env : Fin (n + 1) → α) i := by
  rcases i with ⟨iv, hi⟩
  cases iv with
  | zero =>
    have hs : skipFin (⟨1, by omega⟩ : Fin (n + 2)) ⟨0, hi⟩ = ⟨0, by omega⟩ := by
      simp only [skipFin]
      rw [dif_pos (by omega)]
    rw [hs]
    rfl
  | succ m =>
    have hs : skipFin (⟨1, by omega⟩ : Fin (n + 2)) ⟨m + 1, hi⟩ =
        Fin.succ (Fin.succ (⟨m, by omega⟩ : Fin n)) := by
      simp only [skipFin]
      rw [dif_neg (by omega)]
      rfl
    have hr : (⟨m + 1, hi⟩ : Fin (n + 1)) = Fin.succ (⟨m, by omega⟩ : Fin n) := rfl
    rw [hs, hr, Fin.cons_succ, Fin.cons_succ, Fin.cons_succ]

/-- **Gate 2a crux — realized fibers pass the strengthened guard** (honest preservation,
    per-fiber, full generality): if `σ` is realized at `env` and its fiber `s` at
    `Fin.cons xs env`, then `s` passes the V2 guard. The mate witness for a marked inner `e`
    (realized at `Fin.cons u (Fin.cons xs env)`) is the characteristic of the dropped tuple
    `Fin.cons u env` — `σ`-marked by realization, atom-matching by construction, and
    CO-REALIZED with `σ` by the very hypotheses in scope. Induction on the fiber depth. -/
theorem kvE_fiberElemConsistentV2_of_realized {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    ∀ {k n : Nat} (env : Fin n → M.carrier) (xs : M.carrier)
      (σ : NormalForm sig (k + 1) n) (s : NormalForm sig k (n + 1)),
      nf_eval_nf M (k + 1) n env σ →
      nf_eval_nf M k (n + 1) (Fin.cons xs env) s →
      kvE_fiberElemConsistentV2 σ s = true := by
  intro k
  induction k with
  | zero => intro n env xs σ s _ _; rfl
  | succ j ih =>
    intro n env xs σ s hσ hs
    rw [kvE_fiberElemConsistentV2, Bool.and_eq_true]
    constructor
    · -- mate check (row match AND joint co-realization)
      rw [List.all_eq_true]
      intro e _
      rw [Bool.or_eq_true]
      by_cases hbe : s.2 e = true
      · refine Or.inr ?_
        obtain ⟨u, hu⟩ := (hs.2 e).mpr hbe
        rw [List.any_eq_true]
        refine ⟨nf_characteristic M (j + 1) (n + 1) (Fin.cons u env),
          Finset.mem_toList.mpr (Finset.mem_univ _), ?_⟩
        rw [Bool.and_eq_true, Bool.and_eq_true]
        refine ⟨⟨(hσ.2 _).mp ⟨u, nf_characteristic_satisfies M (j + 1) (n + 1) _⟩, ?_⟩, ?_⟩
        · -- row match: LHS the dropped atom row of `e`; RHS the characteristic's atom row
          refine decide_eq_true ?_
          funext a
          have hatoms : ∀ a' : AtomKind sig (n + 2),
              atom_eval M (Fin.cons u (Fin.cons xs env)) a' ↔ e.atom_assgn a' = true :=
            nf_eval_nf_atom_layer M _ e hu
          have hchar : (nf_characteristic M (j + 1) (n + 1) (Fin.cons u env)).atom_assgn a =
              @decide (atom_eval M (Fin.cons u env) a) (Classical.dec _) := rfl
          rw [hchar]
          cases a with
          | pred p i =>
            have hL := hatoms (.pred p (skipFin ⟨1, by omega⟩ i))
            simp only [atom_eval, cons_cons_skipOne364] at hL
            show e.atom_assgn (.pred p (skipFin ⟨1, by omega⟩ i)) = _
            cases hb : e.atom_assgn (.pred p (skipFin ⟨1, by omega⟩ i)) with
            | true =>
              exact (@decide_eq_true (atom_eval M (Fin.cons u env) (.pred p i))
                (Classical.dec _) (hL.mpr hb)).symm
            | false =>
              refine (@decide_eq_false (atom_eval M (Fin.cons u env) (.pred p i))
                (Classical.dec _) ?_).symm
              intro hev
              exact absurd (hL.mp hev) (by rw [hb]; exact Bool.false_ne_true)
          | order i j' hne =>
            have hL := hatoms (.order (skipFin ⟨1, by omega⟩ i) (skipFin ⟨1, by omega⟩ j')
              ((skipFin_injective _).ne hne))
            simp only [atom_eval, cons_cons_skipOne364] at hL
            show e.atom_assgn (.order (skipFin ⟨1, by omega⟩ i) (skipFin ⟨1, by omega⟩ j')
              ((skipFin_injective _).ne hne)) = _
            cases hb : e.atom_assgn (.order (skipFin ⟨1, by omega⟩ i) (skipFin ⟨1, by omega⟩ j')
                ((skipFin_injective _).ne hne)) with
            | true =>
              exact (@decide_eq_true (atom_eval M (Fin.cons u env) (.order i j' hne))
                (Classical.dec _) (hL.mpr hb)).symm
            | false =>
              refine (@decide_eq_false (atom_eval M (Fin.cons u env) (.order i j' hne))
                (Classical.dec _) ?_).symm
              intro hev
              exact absurd (hL.mp hev) (by rw [hb]; exact Bool.false_ne_true)
        · -- joint co-realization: the hypotheses in scope ARE the witness
          exact @decide_eq_true
            (∃ (M0 : OrderedMonadicStructure sig) (env0 : Fin n → M0.carrier)
              (u0 : M0.carrier),
              nf_eval_nf M0 (j + 2) n env0 σ ∧
              nf_eval_nf M0 (j + 1) (n + 1) (Fin.cons u0 env0)
                (nf_characteristic M (j + 1) (n + 1) (Fin.cons u env)))
            (Classical.dec _)
            ⟨M, env, u, hσ, nf_characteristic_satisfies M (j + 1) (n + 1) _⟩
      · exact Or.inl (by rw [Bool.not_eq_true] at hbe; rw [hbe]; rfl)
    · -- depth recursion
      rw [List.all_eq_true]
      intro e _
      rw [Bool.or_eq_true]
      by_cases hbe : s.2 e = true
      · obtain ⟨u, hu⟩ := (hs.2 e).mpr hbe
        exact Or.inr (ih (Fin.cons xs env) u s e hs hu)
      · exact Or.inl (by rw [Bool.not_eq_true] at hbe; rw [hbe]; rfl)

/-- **Realized slices pass the strengthened σ-level guard** (honest preservation, σ-level). -/
theorem kvE_fiberConsistentV2_of_realized {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {k n : Nat} (env : Fin n → M.carrier)
    (σ : NormalForm sig (k + 1) n)
    (hσ : nf_eval_nf M (k + 1) n env σ) :
    kvE_fiberConsistentV2 σ = true := by
  rw [kvE_fiberConsistentV2, List.all_eq_true]
  intro s _
  rw [Bool.or_eq_true]
  by_cases hb : σ.2 s = true
  · obtain ⟨xs, hxs⟩ := (hσ.2 s).mpr hb
    exact Or.inr (kvE_fiberElemConsistentV2_of_realized M env xs σ s hσ hxs)
  · exact Or.inl (by rw [Bool.not_eq_true] at hb; rw [hb]; rfl)

/-- Depth-0 inertness, per-fiber: unchanged `rfl` (the depth-0 arm is verbatim `true`). -/
theorem kvE_fiberElemConsistentV2_zero {sig : MonadicSignature} {n : Nat}
    (σ : NormalForm sig 1 n) (s : NormalForm sig 0 (n + 1)) :
    kvE_fiberElemConsistentV2 σ s = true := rfl

/-- Depth-0 inertness, σ-level: the m = 0 layers see a vacuous conjunct, exactly as at 363. -/
theorem kvE_fiberConsistentV2_zero {sig : MonadicSignature} {n : Nat}
    (σ : NormalForm sig 1 n) : kvE_fiberConsistentV2 σ = true := by
  rw [kvE_fiberConsistentV2, List.all_eq_true]
  intro s _
  rw [kvE_fiberElemConsistentV2_zero σ s, Bool.or_true]

/-! ## Gate 2a — honest cast certificates (derived from `_of_realized`, not by computation) -/

/-- **Gate 2a (σ-level)**: the honest endpoint characteristic `τ` passes the V2 guard. -/
theorem kvE_probe364_honest_tau_consistent : kvE_fiberConsistentV2 m2tau = true :=
  kvE_fiberConsistentV2_of_realized M2M m2env4 m2tau
    (nf_characteristic_satisfies M2M 2 4 m2env4)

/-- **Gate 2a (per-fiber, uniform in `r`)**: EVERY honest pinned fiber — gap (`r ∈ (18,25)`),
    self (`r = 25`), ray (`r > 25`) — is V2-elem-consistent within `τ`. -/
theorem kvE_probe364_honest_fiber_consistent (r : ℤ) :
    kvE_fiberElemConsistentV2 m2tau (nf_characteristic M2M 1 5 (Fin.cons r m2env4)) = true :=
  kvE_fiberElemConsistentV2_of_realized M2M m2env4 r m2tau _
    (nf_characteristic_satisfies M2M 2 4 m2env4)
    (nf_characteristic_satisfies M2M 1 5 (Fin.cons r m2env4))

end Bimodal.Metalogic.WeakCanonical.Kamp
