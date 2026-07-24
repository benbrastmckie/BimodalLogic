/-
ARCHIVED — off-faithful-path (Kamp Boneyard). MOVE-not-delete; do NOT delete or empty.

Retired from the live build ahead of the k>=2 E[Sigma] re-architecture. NOT on the
proof-term path from `completeness_discrete` (0 live importers; outside the Bimodal.lean
import closure, so uncompiled). Fiber-consistency probe (honest vs fake population).
Machine-checked NO-GO / refutation certificate, retained as evidence. Do NOT consume or
reuse for the faithful re-architecture (off-paper arity-4 object; diverges from Rabinovich
Def 4.1, PDF p.5). Filename de-numbered on archival (durable-anchor discipline).

Key declarations: kvE_probe363_fake_elem_inconsistent, kvE_probe363_honest_tau_consistent, kvE_probe363_interior_population_clean
-/
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Depth-graded fiber-consistency guard — Phase-1 probe (GO/NO-GO gate)

NON-PRODUCTION probe module for the depth-graded interface restatement. Defines the CANDIDATE
depth-graded fiber-consistency predicate and machine-validates it on the existing m = 1
doppelgänger cast of `ExteriorPinnedProbeM1K.lean` (template-copied here per the replication
precedent — the originals are `private`). No production file is touched by this module.

## The predicate (approach (b), research §2.3)

`kvE_fiberElemConsistent σ s` — decidable, model-independent, depth-recursive over the `.2`
inner marking, trivially `true` at fiber depth 0 (m = 0 inertness):

* **mate check (reads the depth-≥1 inner marking)**: every inner form `e` MARKED by the fiber
  `s` must have an atom-layer mate among the ambient `σ`'s marked fibers after dropping `s`'s
  own fresh slot — `mergeNF e.atom_assgn ⟨1,_⟩ = s'.atom_assgn` for some `σ`-marked `s'`.
  Rationale: if `σ` is realized at `env` and `s` at `Fin.cons xs env`, each marked `e` is
  realized at `Fin.cons u (Fin.cons xs env)`; dropping slot 1 (the `xs` coordinate) leaves the
  tuple `Fin.cons u env`, whose depth-`k` characteristic is itself a `σ`-marked fiber with
  EXACTLY the dropped atom layer. The doppelgänger `s*` fails this: its inner mark at the
  `P`-point `20` drops to the atom row `[20, 25, 15, 2, 21]`, demanding a `σ`-marked mate
  realized at `[x, 25, 15, 2, 18]` with `P x ∧ 15 < x < 18` — impossible (`P = {0,10,20}`).
* **depth recursion**: every marked inner form is itself fiber-consistent one level down
  (`kvE_fiberElemConsistent s e`), so the guard is depth-graded by construction, not an m = 1
  hardcode. At the interior seam this recursion is what rejects the fake ambient: the rows-5-6
  fake `qnfG1` marks `σ = τ ⊕ s*`, and `kvE_fiberConsistent (τ ⊕ s*) = false` via the
  recursive arm reaching `(τ ⊕ s*, s*)`.

`kvE_fiberConsistent σ` — the σ-level guard: every `σ`-marked fiber is elem-consistent.
Direction-agnostic (serves as the future AND past mirror conjunct: realization-based
soundness never reads the anchor order), and inert at fiber depth 0.

## VERDICT: **GO** (recorded on completion of this module)

Certificates below, all sorry-free:
1. `kvE_probe363_fake_elem_inconsistent`  — `kvE_fiberElemConsistent m1sigma m1sstar = false`
   (the fake fiber is rejected, exterior leg core);
2. `kvE_probe363_fake_slice_inconsistent` — `kvE_fiberConsistent m1sigma = false`
   (the fake-carrying slice is rejected — the exterior conjunct fires and the interior
   rows-5-6 antecedent fails at `(qnfG1, m1sigma)`);
3. `kvE_probe363_honest_tau_consistent`   — `kvE_fiberConsistent m1tau = true`
   (the honest endpoint characteristic passes);
4. `kvE_probe363_honest_fiber_consistent` — every honest pinned fiber
   `nf_characteristic M1M 1 5 (Fin.cons r m1env4)` (gap `r ∈ (18,25)`, self `r = 25`, ray
   `r > 25` — uniformly in `r`) is elem-consistent in `m1tau`;
5. `kvE_probe363_interior_population_clean` + `_nonempty` — 358-dischargeability feasibility:
   every `m1qnf`-marked slice satisfies the antecedent, and the population is non-trivial;
6. `kvE_probe363_qnfG1_antecedent_fails` — the restated interior antecedent is violated by
   the fake ambient `qnfG1` (it marks the inconsistent `m1sigma`);
7. `kvE_probe363_sigma_inadmissible` (Phase 5 DoD cert 1) — against the RESTATED production
   `kvE_futAdmissible`, the fake slice is INADMISSIBLE: `kvE_futAdmissible m1sigma = false`.
   The old `m1_sigma_adm` hypothesis-side assembly of `kvE_probeM1_sliceId_NOGO` is
   unprovable — the exterior countermodel no longer applies;
8. `kvE_probe363_tau_admissible` (Phase 5 DoD cert 2) — the honest endpoint characteristic
   REMAINS admissible under the strengthened predicate (`kvE_futRealizer_admissible` fires
   on the cast), so the honest population is preserved.

General honest-preservation (`kvE_fiberConsistent_of_realized`: ANY realized σ passes, over
ANY model/env — the exact obligation `kvE_futRealizer_admissible`'s new conjunct needs) is
proved in full generality in the production home `ExteriorFiberConsistencyK.lean`
(promoted from this module in Phase 2). -/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Predicate location

The predicate pair (`kvE_fiberElemConsistent`, `kvE_fiberConsistent`), the depth-0 inertness
lemmas, the symbolic membership helper `kvE_nf_mem_univ_toList`, and the general honest-
preservation lemmas (`kvE_fiberElemConsistent_of_realized`, `kvE_fiberConsistent_of_realized`)
were PROMOTED verbatim to the production home `ExteriorFiberConsistencyK.lean`
(Phase 2). This module retains the m = 1 cast and the six GO certificates against the
production definitions. -/

/-! ## The m = 1 probe cast (template copy of `ExteriorPinnedProbeM1K.lean:60-107,813-814`;
the originals are `private` — replication precedent) -/

/-- One-predicate signature for the probe. -/
private abbrev m1sig : MonadicSignature := { preds := Unit }

/-- The probe model `M* = (ℤ, <)` with `P = {0, 10, 20}`. -/
private abbrev M1M : OrderedMonadicStructure m1sig where
  carrier := ℤ
  interp := fun _ z => z = 0 ∨ z = 10 ∨ z = 20
  carrier_order := inferInstance

/-- Ambient anchors `[w, x, t] = [15, 2, 18]`. -/
private def m1env3 : Fin 3 → M1M.carrier := Fin.cons 15 (Fin.cons 2 (fun _ => 18))

/-- Pinned 4-anchors `[x1, w, x, t] = [25, 15, 2, 18]`. -/
private def m1env4 : Fin 4 → M1M.carrier := Fin.cons 25 m1env3

/-- The doppelgänger tail `[25, 15, 2, 21]`. -/
private def m1envF : Fin 4 → M1M.carrier :=
  Fin.cons 25 (Fin.cons 15 (Fin.cons 2 (fun _ => 21)))

/-- The fake world's 5-tuple `[22, 25, 15, 2, 21]`. -/
private def m1tupF : Fin 5 → M1M.carrier := Fin.cons 22 m1envF

/-- The honest level-up ambient at m = 1. -/
private noncomputable def m1qnf : NormalForm m1sig 3 3 := nf_characteristic M1M 3 3 m1env3

/-- The honest endpoint characteristic `τ`. -/
private noncomputable def m1tau : NormalForm m1sig 2 4 := nf_characteristic M1M 2 4 m1env4

/-- The fake gap fiber element `s*`. -/
private noncomputable def m1sstar : NormalForm m1sig 1 5 :=
  nf_characteristic M1M 1 5 m1tupF

/-- The countermodel slice `σ := τ ⊕ s*`. -/
private noncomputable def m1sigma : NormalForm m1sig 2 4 :=
  (m1tau.1, fun s => if s = m1sstar then true else m1tau.2 s)

/-- The fake ambient `qnfG1 := m1qnf ⊕ m1sigma` (the interior rows-5-6 cast). -/
private noncomputable def m1qnfG1 : NormalForm m1sig 3 3 :=
  (m1qnf.1, fun s => if s = m1sigma then true else m1qnf.2 s)

/-- `σ` marks `s*` (by construction). -/
private theorem m1_sigma_marks_sstar : m1sigma.2 m1sstar = true := by
  show (if m1sstar = m1sstar then true else m1tau.2 m1sstar) = true
  rw [if_pos rfl]

/-! ## The separating inner witness

`e_P := nf_characteristic M1M 0 6 [20, 22, 25, 15, 2, 21]` — the honest inner 6-type of the
`P`-point `20` in the FAKE world. `s*` marks it (realized at `u = 20` over `s*`'s own tuple),
but its dropped atom row `[20, 25, 15, 2, 21]` records `P(fresh) ∧ w < fresh ∧ fresh < t-slot`
— on the HONEST tail `[·, 25, 15, 2, 18]` that demands `P x ∧ 15 < x < 18`, impossible for
`P = {0, 10, 20}`. No `σ`-marked fiber matches: honest fibers are pinned over the honest tail
(the omega contradiction), and `s*` itself has `¬P` at the fresh slot. -/

/-- The separating inner witness `e_P`. -/
private noncomputable def m1eP : NormalForm m1sig 0 6 :=
  nf_characteristic M1M 0 6 (Fin.cons 20 m1tupF)

/-- `s*` marks `e_P` (realized at `u = 20` over the fake tuple). -/
private theorem m1_sstar_marks_eP : m1sstar.2 m1eP = true :=
  @decide_eq_true (∃ u : ℤ, nf_eval_nf M1M 0 6 (Fin.cons u m1tupF) m1eP)
    (Classical.dec _) ⟨20, nf_characteristic_satisfies M1M 0 6 _⟩

/-- `e_P`'s dropped atom row at the fresh predicate slot: `P(20)` — true. -/
private theorem m1_drop_eP_pred0 :
    mergeNF (m1eP.atom_assgn) ⟨1, by omega⟩ (.pred () (0 : Fin 5)) = true := by
  show m1eP (.pred () (skipFin ⟨1, by omega⟩ (0 : Fin 5))) = true
  have hf : skipFin (⟨1, by omega⟩ : Fin 6) (0 : Fin 5) = (0 : Fin 6) := by decide
  rw [hf]
  exact @decide_eq_true (atom_eval M1M (Fin.cons 20 m1tupF) (.pred () (0 : Fin 6)))
    (Classical.dec _) (show (20 : ℤ) = 0 ∨ (20 : ℤ) = 10 ∨ (20 : ℤ) = 20 by omega)

/-- `e_P`'s dropped atom row at `w < fresh`: `15 < 20` — true. -/
private theorem m1_drop_eP_ord20 :
    mergeNF (m1eP.atom_assgn) ⟨1, by omega⟩
      (.order (2 : Fin 5) (0 : Fin 5) (by decide)) = true := by
  show m1eP (.order (skipFin ⟨1, by omega⟩ (2 : Fin 5)) (skipFin ⟨1, by omega⟩ (0 : Fin 5))
    ((skipFin_injective _).ne (by decide))) = true
  have hf2 : skipFin (⟨1, by omega⟩ : Fin 6) (2 : Fin 5) = (3 : Fin 6) := by decide
  have hf0 : skipFin (⟨1, by omega⟩ : Fin 6) (0 : Fin 5) = (0 : Fin 6) := by decide
  simp only [hf2, hf0]
  exact @decide_eq_true (atom_eval M1M (Fin.cons 20 m1tupF)
      (.order (3 : Fin 6) (0 : Fin 6) (by decide)))
    (Classical.dec _) (show (15 : ℤ) < 20 by omega)

/-- `e_P`'s dropped atom row at `fresh < t-slot`: `20 < 21` — true. -/
private theorem m1_drop_eP_ord04 :
    mergeNF (m1eP.atom_assgn) ⟨1, by omega⟩
      (.order (0 : Fin 5) (4 : Fin 5) (by decide)) = true := by
  show m1eP (.order (skipFin ⟨1, by omega⟩ (0 : Fin 5)) (skipFin ⟨1, by omega⟩ (4 : Fin 5))
    ((skipFin_injective _).ne (by decide))) = true
  have hf0 : skipFin (⟨1, by omega⟩ : Fin 6) (0 : Fin 5) = (0 : Fin 6) := by decide
  have hf4 : skipFin (⟨1, by omega⟩ : Fin 6) (4 : Fin 5) = (5 : Fin 6) := by decide
  simp only [hf0, hf4]
  exact @decide_eq_true (atom_eval M1M (Fin.cons 20 m1tupF)
      (.order (0 : Fin 6) (5 : Fin 6) (by decide)))
    (Classical.dec _) (show (20 : ℤ) < 21 by omega)

/-- `s*`'s own atom row has `¬P` at the fresh slot (`¬P(22)`). -/
private theorem m1_sstar_pred0_false : m1sstar.1 (.pred () (0 : Fin 5)) = false :=
  @decide_eq_false (atom_eval M1M m1tupF (.pred () (0 : Fin 5))) (Classical.dec _)
    (show ¬((22 : ℤ) = 0 ∨ (22 : ℤ) = 10 ∨ (22 : ℤ) = 20) by omega)

/-! ## Certificate 1 — the fake fiber is rejected -/

set_option maxRecDepth 8000 in
/-- **GO certificate 1 (fake-exclusion, per-fiber)**: the doppelgänger fiber `s*` fails the
    guard within `σ = τ ⊕ s*`. Its marked inner witness `e_P` has no atom-mate among `σ`'s
    marked fibers: `s*` itself differs at the fresh predicate slot, and any honest fiber
    (pinned over `[·, 25, 15, 2, 18]`) would need `P x ∧ 15 < x < 18` — impossible. -/
theorem kvE_probe363_fake_elem_inconsistent :
    kvE_fiberElemConsistent m1sigma m1sstar = false := by
  cases hc : kvE_fiberElemConsistent m1sigma m1sstar with
  | false => rfl
  | true =>
    exfalso
    rw [kvE_fiberElemConsistent, Bool.and_eq_true] at hc
    have hA := hc.1
    rw [List.all_eq_true] at hA
    have h1 := hA m1eP (kvE_nf_mem_univ_toList _)
    rw [Bool.or_eq_true] at h1
    rcases h1 with h1 | h1
    · rw [m1_sstar_marks_eP] at h1
      exact absurd h1 (by decide)
    · rw [List.any_eq_true] at h1
      obtain ⟨s', -, hs'⟩ := h1
      -- The mate check gained a co-realization conjunct; the original
      -- atom-row contradiction still closes this certificate, so it is discarded here
      rw [Bool.and_eq_true, Bool.and_eq_true] at hs'
      obtain ⟨⟨hbit, hdec⟩, -⟩ := hs'
      have heq : mergeNF (m1eP.atom_assgn) ⟨1, by omega⟩ = s'.atom_assgn :=
        of_decide_eq_true hdec
      -- read the three separating atoms through the claimed mate
      have e1 : s'.atom_assgn (.pred () (0 : Fin 5)) = true := by
        rw [← heq]; exact m1_drop_eP_pred0
      have e2 : s'.atom_assgn (.order (2 : Fin 5) (0 : Fin 5) (by decide)) = true := by
        rw [← heq]; exact m1_drop_eP_ord20
      have e3 : s'.atom_assgn (.order (0 : Fin 5) (4 : Fin 5) (by decide)) = true := by
        rw [← heq]; exact m1_drop_eP_ord04
      -- σ marks s' — either the fake itself or an honest pinned fiber
      by_cases hss : s' = m1sstar
      · -- the fake: ¬P at the fresh slot, contradicting e1
        subst hss
        have : m1sstar.1 (.pred () (0 : Fin 5)) = true := e1
        rw [m1_sstar_pred0_false] at this
        exact absurd this (by decide)
      · -- honest: pinned at [x, 25, 15, 2, 18] with P x ∧ 15 < x ∧ x < 18 — impossible
        have hbitτ : m1tau.2 s' = true := by
          have hb : m1sigma.2 s' = m1tau.2 s' := by
            show (if s' = m1sstar then true else m1tau.2 s') = m1tau.2 s'
            rw [if_neg hss]
          rw [← hb]; exact hbit
        obtain ⟨xw, hxw⟩ := @of_decide_eq_true
          (∃ x : ℤ, nf_eval_nf M1M 1 5 (Fin.cons x m1env4) s') (Classical.dec _) hbitτ
        have hP : xw = 0 ∨ xw = 10 ∨ xw = 20 :=
          (hxw.1 (.pred () (0 : Fin 5))).mpr e1
        have h15 : (15 : ℤ) < xw :=
          (hxw.1 (.order (2 : Fin 5) (0 : Fin 5) (by decide))).mpr e2
        have h18 : xw < (18 : ℤ) :=
          (hxw.1 (.order (0 : Fin 5) (4 : Fin 5) (by decide))).mpr e3
        omega

/-! ## Certificate 2 — the fake-carrying slice is rejected (both legs) -/

set_option maxRecDepth 8000 in
/-- **GO certificate 2 (fake-exclusion, σ-level)**: `σ = τ ⊕ s*` fails the σ-level guard —
    it marks the elem-inconsistent `s*`. This is simultaneously (i) the exterior leg: the new
    admissibility conjunct fires against `m1sigma`, so the old `m1_sigma_adm` hypothesis-side
    assembly of `kvE_probeM1_sliceId_NOGO` dissolves; and (ii) the interior leg: the restated
    rows-5-6 antecedent ("every marked slice is fiber-consistent") is FALSE at `qnfG1`. -/
theorem kvE_probe363_fake_slice_inconsistent :
    kvE_fiberConsistent m1sigma = false := by
  cases hc : kvE_fiberConsistent m1sigma with
  | false => rfl
  | true =>
    exfalso
    rw [kvE_fiberConsistent, List.all_eq_true] at hc
    have h := hc m1sstar (kvE_nf_mem_univ_toList _)
    rw [Bool.or_eq_true] at h
    rcases h with h | h
    · rw [m1_sigma_marks_sstar] at h
      exact absurd h (by decide)
    · rw [kvE_probe363_fake_elem_inconsistent] at h
      exact absurd h (by decide)

/-! ## Certificates 3-4 — honest preservation on the cast -/

/-- **GO certificate 3 (honest preservation, σ-level)**: the honest endpoint characteristic
    `τ` passes the σ-level guard (it is realized at the pinned anchors). -/
theorem kvE_probe363_honest_tau_consistent : kvE_fiberConsistent m1tau = true :=
  kvE_fiberConsistent_of_realized M1M m1env4 m1tau
    (nf_characteristic_satisfies M1M 2 4 m1env4)

/-- **GO certificate 4 (honest preservation, per-fiber)**: EVERY honest pinned fiber — the
    gap fibers (`r ∈ (18,25)`), the self witness (`r = 25`), the ray witnesses (`r > 25`),
    uniformly in `r` — is elem-consistent within `τ`. -/
theorem kvE_probe363_honest_fiber_consistent (r : ℤ) :
    kvE_fiberElemConsistent m1tau (nf_characteristic M1M 1 5 (Fin.cons r m1env4)) = true :=
  kvE_fiberElemConsistent_of_realized M1M m1env4 r m1tau _
    (nf_characteristic_satisfies M1M 2 4 m1env4)
    (nf_characteristic_satisfies M1M 1 5 (Fin.cons r m1env4))

/-! ## Certificates 5-6 — interior seam feasibility and fake-ambient exclusion -/

/-- **GO certificate 5a (358-dischargeability)**: the honest ambient's marked-slice
    population is consistency-clean — every `m1qnf`-marked σ satisfies the restated
    antecedent. The Phase-8 supply population is exactly this kind. -/
theorem kvE_probe363_interior_population_clean (σ : NormalForm m1sig 2 4)
    (h : m1qnf.2 σ = true) : kvE_fiberConsistent σ = true := by
  obtain ⟨x, hx⟩ := @of_decide_eq_true
    (∃ x : ℤ, nf_eval_nf M1M 2 4 (Fin.cons x m1env3) σ) (Classical.dec _) h
  exact kvE_fiberConsistent_of_realized M1M (Fin.cons x m1env3) σ hx

/-- **GO certificate 5b (non-triviality)**: the restricted population is non-empty — the
    honest ambient marks `τ` (realized at the fresh anchor `25`). -/
theorem kvE_probe363_interior_population_nonempty : m1qnf.2 m1tau = true :=
  @decide_eq_true (∃ x : ℤ, nf_eval_nf M1M 2 4 (Fin.cons x m1env3) m1tau)
    (Classical.dec _) ⟨25, nf_characteristic_satisfies M1M 2 4 m1env4⟩

set_option maxRecDepth 8000 in
/-- **GO certificate 6 (interior fake-ambient exclusion)**: the fake ambient `qnfG1` VIOLATES
    the restated rows-5-6 antecedent — it marks `m1sigma`, which is not fiber-consistent. The
    old `kvE_probeM1_interiorHreal_NOGO` hypothesis side (now including this antecedent) is
    therefore unsatisfiable at `qnfG1`. -/
theorem kvE_probe363_qnfG1_antecedent_fails :
    ¬ (∀ σ : NormalForm m1sig 2 4, m1qnfG1.2 σ = true → kvE_fiberConsistent σ = true) := by
  intro hcons
  have hmark : m1qnfG1.2 m1sigma = true := by
    show (if m1sigma = m1sigma then true else m1qnf.2 m1sigma) = true
    rw [if_pos rfl]
  have := hcons m1sigma hmark
  rw [kvE_probe363_fake_slice_inconsistent] at this
  exact absurd this (by decide)

/-! ## Certificates 7-8 — the Phase-5 re-probe against the RESTATED production admissibility -/

set_option maxRecDepth 8000 in
/-- **GO certificate 7 (DoD 1 — exterior fake excluded)**: against the restated
    `kvE_futAdmissible`, the countermodel slice `σ = τ ⊕ s*` is INADMISSIBLE — conjunct 2's
    fiber-consistency guard fires at the marked `s*`. The old `m1_sigma_adm` hypothesis-side
    assembly of `kvE_probeM1_sliceId_NOGO` (`ExteriorPinnedProbeM1K.lean`, pre-363 revision,
    preserved in git history) is therefore unprovable: the doppelgänger countermodel no
    longer applies to the exterior (G2, rows 8-11) leg. -/
theorem kvE_probe363_sigma_inadmissible : kvE_futAdmissible m1sigma = false := by
  cases hc : kvE_futAdmissible m1sigma with
  | false => rfl
  | true =>
    exfalso
    rw [kvE_futAdmissible, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hc
    have h2 := hc.1.1.2
    rw [List.all_eq_true] at h2
    have h := h2 m1sstar (kvE_nf_mem_univ_toList _)
    rw [Bool.or_eq_true] at h
    rcases h with h | h
    · rw [Bool.and_eq_true] at h
      have hcons := h.2
      rw [kvE_probe363_fake_elem_inconsistent] at hcons
      exact absurd hcons (by decide)
    · rw [m1_sigma_marks_sstar] at h
      exact absurd h (by decide)

/-- **GO certificate 8 (DoD 2 — honest population preserved)**: the honest endpoint
    characteristic `τ` REMAINS admissible under the strengthened predicate — the re-proved
    `kvE_futRealizer_admissible` fires on the cast's pinned realizer. Together with
    certificate 7: honest σ still admissible, fake σ not. -/
theorem kvE_probe363_tau_admissible : kvE_futAdmissible m1tau = true :=
  kvE_futRealizer_admissible M1M m1tau 25 15 2 18
    (show (2 : ℤ) < 15 by omega) (show (15 : ℤ) < 18 by omega) (show (18 : ℤ) < 25 by omega)
    (nf_characteristic_satisfies M1M 2 4 m1env4)

end Bimodal.Metalogic.WeakCanonical.Kamp
