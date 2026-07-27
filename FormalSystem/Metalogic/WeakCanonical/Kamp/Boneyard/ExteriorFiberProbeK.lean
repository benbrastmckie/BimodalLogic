/-
ARCHIVED — off-faithful-path (Kamp Boneyard). MOVE-not-delete; do NOT delete or empty.

Retired from the live build ahead of the k>=2 E[Sigma] re-architecture. NOT on the
proof-term path from `completeness_discrete` (0 live importers; outside the Bimodal.lean
import closure, so uncompiled). Machine-checked fiber-separation probe (evidence).
Do NOT consume or reuse for the faithful re-architecture: it targets the off-paper arity-4
object, which diverges from Rabinovich Def 4.1 (PDF p.5, atoms kept unary by expanding the
signature). Retained as machine-checked evidence only.

Key declarations: kvE_fiber_separates_pair, kvE_sepPos_separates_qnf_pair, kvE_fiberPos_separates_F2
-/
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# F2 separation probe for the full-fiber content channel (Phase 1.2 — GO/NO-GO)

Machine-checks the plan's central design ruling (research Conflict 1): the corrected
full-fiber content channel (`kvE_fiberPos`/`kvE_fiberPosOn`, ExteriorFiberK.lean) SEPARATES
the F2 counterexample pattern that kills every marginal construction
(`f2_carrier_eq`, RefutationF2.lean:582).

**Probe-local reconstruction**: all of RefutationF2.lean's machinery is `private`
(`f2sig`:92, `F2M`:104, `f2env3`:328, `f2qnf`:332, `f2sub1/2`:335/339, `f2qnf'`:343), so the
F2-style pair construction is REPLICATED here as a byte-faithful template copy (`p2*` names);
RefutationF2.lean is not touched.

**The pair and the channels**:
- `p2sub1`/`p2sub2` — the depth-1 arity-4 types of `[12, 15, 2, 18]` / `[4, 15, 2, 18]` in
  `M* = (ℤ, <)`, `P = {0, 10, 20}`. Every marginal channel of the new layer agrees on the
  pair: shared atom layer (`p2_sub_atom_eq` — hence shared zone spec) and shared depth-`k`
  fresh shadow (`p2_projFreshD_agree`, via `kvE_projFreshD_zero`). This is the agreement
  that makes the frozen/marginal construction collapse (`f2_carrier_eq`'s channel inputs).
- The pair differs at the FULL fiber element `e*` = the depth-0 5-type of
  `[10, 12, 15, 2, 18]` ("`P z` and `x < z < u`"): `p2_estar_in_sub1` /
  `p2_estar_not_in_sub2` — the `(2, 4)` gap has no `P`-point.

**Separation results (the GO gate)**:
1. `kvE_fiber_separates_pair` — syntactic: the fiber enumeration distinguishes the pair
   (`e* ∈ kvE_fiber p2sub1`, `e* ∉ kvE_fiber p2sub2`) although every marginal channel
   agrees on it.
2. `kvE_sepPos_separates_qnf_pair` — syntactic, one rung up: the full-fiber read of the
   qnf-level pair (`p2qnf` honest / `p2qnf'` un-marked, the exact `f2_carrier_eq` pair
   shape) distinguishes them — the fiber-set fact the corrected clause layer induces.
3. `kvE_fiberPos_separates_F2` — SEMANTIC, under a concrete provider instance `p2P`
   (the sorry-free depth-0 all-arity converter `nf_nvar_exist_depth0_tl_fn`,
   NfDepth0Generalized.lean:1615): the `e*`-bucketed content disjunction is TRUE at
   `t = 18` for `p2sub1` and FALSE (everywhere, in particular at `t = 18`) for `p2sub2` —
   the corrected construction assigns the pair members DIFFERENT truth values, i.e.
   exactly the separating power the marginal construction lacks.

**VERDICT: GO** — recorded in the phase-completion commit and orchestrator handoff.

Purely additive NEW leaf module; probe-local (`private`) machinery; no frozen file touched. -/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Probe signature and model (template copies of `f2sig`/`F2M`, RefutationF2.lean:92/:104) -/

/-- One-predicate signature for the probe (`()` names the single monadic predicate `P`). -/
private abbrev p2sig : MonadicSignature := { preds := Unit }

/-- Trivial atom map into the one-predicate probe signature. -/
private abbrev p2atomMap : Formula → p2sig.preds := fun _ => ()

/-- Surjectivity of the probe atom map (every predicate is hit by an atom). -/
private theorem p2surj : ∀ p : p2sig.preds, ∃ a : Atom, p2atomMap (.atom a) = p :=
  fun _ => ⟨Atom.mk_base "P", rfl⟩

/-- The probe model `M* = (ℤ, <)` with `P = {0, 10, 20}` (template copy of `F2M`). -/
private abbrev P2M : OrderedMonadicStructure p2sig where
  carrier := ℤ
  interp := fun _ z => z = 0 ∨ z = 10 ∨ z = 20
  carrier_order := inferInstance

/-- `ℤ` first-occurrence principle (template copy of `f2_int_first`). -/
private theorem p2_int_first {Q : ℤ → Prop} (t : ℤ) (h : ∃ s, t < s ∧ Q s) :
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

/-- `ℤ` last-occurrence principle (template copy of `f2_int_last`). -/
private theorem p2_int_last {Q : ℤ → Prop} (t : ℤ) (h : ∃ s, s < t ∧ Q s) :
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

/-- `(ℤ, <)` satisfies semantic Prior-UZ (template copy of `f2_UZ`). -/
private theorem p2_UZ : semantic_prior_UZ P2M p2atomMap := by
  intro t ψ h
  obtain ⟨s, hts, hs, hmin⟩ :=
    p2_int_first (Q := fun z => temporal_truth P2M p2atomMap z ψ) t h
  refine ⟨s, hts, hs, ?_⟩
  intro r htr hrs
  simp only [Formula.neg, temporal_truth]
  exact hmin r htr hrs

/-- `(ℤ, <)` satisfies semantic Prior-SZ (template copy of `f2_SZ`). -/
private theorem p2_SZ : semantic_prior_SZ P2M p2atomMap := by
  intro t ψ h
  obtain ⟨s, hst, hs, hmax⟩ :=
    p2_int_last (Q := fun z => temporal_truth P2M p2atomMap z ψ) t h
  refine ⟨s, hst, hs, ?_⟩
  intro r hsr hrt
  simp only [Formula.neg, temporal_truth]
  exact hmax r hsr hrt

/-! ## Char/eval helpers (template copies of `f2_eval_iff_char`/`f2char14_snd`/`f2qnf_snd`) -/

/-- Evaluation is characteristic-equality (template copy of `f2_eval_iff_char`). -/
private theorem p2_eval_iff_char {k n : Nat} (env : Fin n → P2M.carrier)
    (σ : NormalForm p2sig k n) :
    nf_eval_nf P2M k n env σ ↔ σ = nf_characteristic P2M k n env :=
  ⟨fun h => nf_eval_unique P2M k n env σ _ h (nf_characteristic_satisfies P2M k n env),
   fun h => h ▸ nf_characteristic_satisfies P2M k n env⟩

/-- Depth-0 characteristic congruence (template copy of `f2_char0_congr`). -/
private theorem p2_char0_congr {n : Nat} (e₁ e₂ : Fin n → P2M.carrier)
    (hP : ∀ i, (e₁ i = 0 ∨ e₁ i = 10 ∨ e₁ i = 20) ↔ (e₂ i = 0 ∨ e₂ i = 10 ∨ e₂ i = 20))
    (hO : ∀ i j, e₁ i < e₁ j ↔ e₂ i < e₂ j) :
    nf_characteristic P2M 0 n e₁ = nf_characteristic P2M 0 n e₂ := by
  funext a
  simp only [nf_characteristic]
  apply decide_eq_decide.mpr
  cases a with
  | pred p i => exact hP i
  | order i j h => exact hO i j

/-! ## The F2-style pair (template copies of `f2env3`/`f2qnf`/`f2sub1`/`f2sub2`/`f2qnf'`) -/

/-- Probe anchor environment `[w, x, t] = [15, 2, 18]`. -/
private def p2env3 : Fin 3 → P2M.carrier := Fin.cons 15 (Fin.cons 2 (fun _ => 18))

/-- `qnf`: the honest depth-2 characteristic 3-type of `[15, 2, 18]` in `M*`. -/
private noncomputable def p2qnf : NormalForm p2sig 2 3 := nf_characteristic P2M 2 3 p2env3

/-- `sub₁`: the depth-1 arity-4 type of `[u₁, w, x, t] = [12, 15, 2, 18]`. -/
private noncomputable def p2sub1 : NormalForm p2sig 1 4 :=
  nf_characteristic P2M 1 4 (Fin.cons 12 p2env3)

/-- `sub₂`: the depth-1 arity-4 type of `[u₂, w, x, t] = [4, 15, 2, 18]`. -/
private noncomputable def p2sub2 : NormalForm p2sig 1 4 :=
  nf_characteristic P2M 1 4 (Fin.cons 4 p2env3)

/-- `qnf'`: `qnf` with the `u₂`-sub un-marked — the F1/F2 information-loss pattern. -/
private noncomputable def p2qnf' : NormalForm p2sig 2 3 :=
  (p2qnf.1, fun σ => if σ = p2sub2 then false else p2qnf.2 σ)

/-- Unfold: the quant layer of `qnf` is the realized-sub `decide` (honest marking). -/
private theorem p2qnf_snd (σ : NormalForm p2sig 1 4) :
    p2qnf.2 σ =
      @decide (∃ u : ℤ, nf_eval_nf P2M 1 4 (Fin.cons u p2env3) σ)
        (Classical.dec _) := rfl

/-- Unfold: the quant layer of a depth-1 arity-4 characteristic is the realized-entry
    `decide` over depth-0 arity-5 types. -/
private theorem p2char14_snd (env : Fin 4 → P2M.carrier) (e : NormalForm p2sig 0 5) :
    (nf_characteristic P2M 1 4 env).2 e =
      @decide (∃ z : ℤ, nf_eval_nf P2M 0 5 (Fin.cons z env) e)
        (Classical.dec _) := rfl

/-- `sub₁` and `sub₂` share their full atom layer: same order pattern `x < u < w < t`,
    same `P`-bits (both fresh points `¬P`) — template copy of `f2_sub_atom_eq`. -/
private theorem p2_sub_atom_eq : p2sub1.1 = p2sub2.1 := by
  show nf_characteristic P2M 0 4 (Fin.cons 12 p2env3) =
    nf_characteristic P2M 0 4 (Fin.cons 4 p2env3)
  exact p2_char0_congr _ _ (by decide) (by decide)

/-- The distinguishing entry `e* :=` the depth-0 5-type of `[10, 12, 15, 2, 18]` — the type
    "`P z` and `x < z < u < w < t`" (template copy of `f2estar`). -/
private noncomputable def p2estar : NormalForm p2sig 0 5 :=
  nf_characteristic P2M 0 5 (Fin.cons 10 (Fin.cons 12 p2env3))

/-- `e*` is marked in `sub₁` (witness `z = 10`: `P 10` and `2 < 10 < 12`) — template copy
    of `f2_estar_in_sub1`. -/
private theorem p2_estar_in_sub1 : p2sub1.2 p2estar = true := by
  rw [show p2sub1.2 p2estar = _ from p2char14_snd _ p2estar]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨10, nf_characteristic_satisfies P2M 0 5 (Fin.cons 10 (Fin.cons 12 p2env3))⟩

/-- `e*` is NOT marked in `sub₂`: a witness would need `P z` with `2 < z < 4` — the gap
    `(x, u₂)` contains no `P`-point (template copy of `f2_estar_not_in_sub2`). THE
    information every marginal read discards. -/
private theorem p2_estar_not_in_sub2 : p2sub2.2 p2estar = false := by
  rw [show p2sub2.2 p2estar = _ from p2char14_snd _ p2estar]
  apply @decide_eq_false _ (Classical.dec _)
  rintro ⟨z, hz⟩
  rw [p2_eval_iff_char] at hz
  have hP : ((z : ℤ) = 0 ∨ (z : ℤ) = 10 ∨ (z : ℤ) = 20) := by
    have hb := congrFun hz (.pred () ⟨0, by omega⟩)
    simp only [p2estar, nf_characteristic] at hb
    have h10 : (10 : ℤ) = 0 ∨ (10 : ℤ) = 10 ∨ (10 : ℤ) = 20 := by norm_num
    exact (decide_eq_decide.mp hb).mp h10
  have hgt : (2 : ℤ) < z := by
    have hb := congrFun hz (.order ⟨3, by omega⟩ ⟨0, by omega⟩ (Fin.ne_of_val_ne (by decide)))
    simp only [p2estar, nf_characteristic] at hb
    have h210 : (2 : ℤ) < 10 := by omega
    exact (decide_eq_decide.mp hb).mp h210
  have hlt : (z : ℤ) < 4 := by
    have hb := congrFun hz (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (Fin.ne_of_val_ne Nat.zero_ne_one))
    simp only [p2estar, nf_characteristic] at hb
    have h1012 : (10 : ℤ) < 12 := by omega
    exact (decide_eq_decide.mp hb).mp h1012
  rcases hP with h | h | h <;> omega

/-- `sub₁ ≠ sub₂` — they differ at `e*` (template copy of `f2_sub_ne`). -/
private theorem p2_sub_ne : p2sub1 ≠ p2sub2 := by
  intro h
  have hb : p2sub1.2 p2estar = p2sub2.2 p2estar := by rw [h]
  rw [p2_estar_in_sub1, p2_estar_not_in_sub2] at hb
  exact Bool.noConfusion hb

/-- `sub₂` is marked in the honest `qnf` (realized at `u₂ = 4`). -/
private theorem p2_sub2_in_qnf : p2qnf.2 p2sub2 = true := by
  rw [p2qnf_snd]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨4, nf_characteristic_satisfies P2M 1 4 (Fin.cons 4 p2env3)⟩

/-- `sub₂` is un-marked in `qnf'` (by construction). -/
private theorem p2_sub2_not_in_qnf' : p2qnf'.2 p2sub2 = false := by
  show (if p2sub2 = p2sub2 then false else p2qnf.2 p2sub2) = false
  rw [if_pos rfl]

/-! ## Marginal-channel agreement on the pair

The navigation channels of the NEW layer — zone spec off the atom layer and the depth-`k`
fresh shadow `kvE_projFreshD` — CANNOT distinguish `sub₁` from `sub₂`: both are functions
of the shared atom layer at `k = 0` (`kvE_projFreshD_zero`, ExteriorBracketK.lean:376).
This replicates, inside the new layer's own vocabulary, the channel agreements
(`f2_sub_atom_eq`/`f2_sub_proj_eq`) under which `f2_carrier_eq` collapses the marginal
construction — and is exactly why G6 forbids marginal bits in content position. -/

/-- The zone channel agrees on the pair (shared atom layer). -/
private theorem p2_zone_agree : nf0_zoneSpec p2sub1.1 = nf0_zoneSpec p2sub2.1 := by
  rw [p2_sub_atom_eq]

/-- The depth-`k` fresh-shadow channel agrees on the pair (`kvE_projFreshD_zero` reduces
    it to the shared atom layer at `k = 0`). -/
private theorem p2_projFreshD_agree : kvE_projFreshD p2sub1 = kvE_projFreshD p2sub2 := by
  rw [kvE_projFreshD_zero, kvE_projFreshD_zero, p2_sub_atom_eq]

/-! ## Concrete provider instance (depth 0, sorry-free)

The canonical `ExistProviders` bundle instantiated by the landed depth-0 all-arity
existential converter `nf_nvar_exist_depth0_tl_fn` (NfDepth0Generalized.lean:1615) — its
correctness is UNCONDITIONAL, so the UZ/SZ hypotheses of the bundle's `correct` field are
simply dropped. Consumed VERBATIM per postmortem rule 11 (no bespoke bundle). -/

/-- Concrete provider instance for the probe signature at depth `0`. -/
private noncomputable def p2P : ExistProviders p2sig p2atomMap 0 where
  existF := fun n sub => nf_nvar_exist_depth0_tl_fn p2atomMap p2surj n sub
  correct := fun n sub M _h_UZ _h_SZ t =>
    nf_nvar_exist_depth0_tl_fn_correct p2atomMap p2surj n sub M t

/-! ## The `e*`-bucket and environment bookkeeping -/

/-- The `e*`-bucket of a sub's fiber: the sub-list of `kvE_fiber σ` at the distinguishing
    entry (a legitimate Phase-2-style bucketing — a SYNTACTIC sub-list selection; content
    is still rendered by `P.existF` on the full element, G6). -/
private noncomputable def p2bucket (σ : NormalForm p2sig 1 4) :
    List (NormalForm p2sig 0 5) :=
  (kvE_fiber σ).filter fun s => decide (s = p2estar)

/-- `e* ∈` the `e*`-bucket of `sub₁`'s fiber. -/
private theorem p2_estar_in_bucket1 : p2estar ∈ p2bucket p2sub1 :=
  List.mem_filter.mpr
    ⟨(kvE_fiber_mem p2sub1 p2estar).mpr p2_estar_in_sub1, decide_eq_true rfl⟩

/-- The witness environment for `e*` at anchor `t = 18`: inserting `18` after
    `[10, 12, 15, 2]` is the characteristic environment `[10, 12, 15, 2, 18]`. -/
private theorem p2_insertEnv4 :
    insertEnv (Fin.cons 10 (Fin.cons 12 (Fin.cons 15 (fun _ => 2))) : Fin 4 → ℤ) 18 =
      Fin.cons 10 (Fin.cons 12 p2env3) := by
  funext i
  match i with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl
  | ⟨2, _⟩ => rfl
  | ⟨3, _⟩ => rfl
  | ⟨4, _⟩ => rfl

/-! ## Separation theorems (the GO gate) -/

/-- **Syntactic fiber separation of the sub pair**: the full-fiber enumeration
    distinguishes `sub₁` from `sub₂` at `e*`, ALTHOUGH every marginal navigation channel
    (atom layer, zone spec, depth-`k` fresh shadow) agrees on the pair. -/
theorem kvE_fiber_separates_pair :
    p2estar ∈ kvE_fiber p2sub1 ∧ p2estar ∉ kvE_fiber p2sub2 ∧
    p2sub1.1 = p2sub2.1 ∧ nf0_zoneSpec p2sub1.1 = nf0_zoneSpec p2sub2.1 ∧
    kvE_projFreshD p2sub1 = kvE_projFreshD p2sub2 := by
  refine ⟨(kvE_fiber_mem p2sub1 p2estar).mpr p2_estar_in_sub1, ?_,
    p2_sub_atom_eq, p2_zone_agree, p2_projFreshD_agree⟩
  intro hmem
  have hbit := (kvE_fiber_mem p2sub2 p2estar).mp hmem
  rw [p2_estar_not_in_sub2] at hbit
  exact Bool.noConfusion hbit

/-- **Syntactic fiber separation of the qnf-level pair** (the exact `f2_carrier_eq` pair
    shape, RefutationF2.lean:582): the full-fiber read (`kvE_sepPos`, the content index set
    of the depth-`k` clause layer one rung up) distinguishes the honest `qnf` from the
    un-marked `qnf'` — the fiber-set fact the corrected construction induces, which the
    marginal carrier provably cannot see. -/
theorem kvE_sepPos_separates_qnf_pair :
    p2sub2 ∈ kvE_sepPos (k := 0) p2qnf ∧ p2sub2 ∉ kvE_sepPos (k := 0) p2qnf' := by
  refine ⟨(kvE_sepPos_mem p2qnf p2sub2).mpr p2_sub2_in_qnf, ?_⟩
  intro hmem
  have hbit := (kvE_sepPos_mem p2qnf' p2sub2).mp hmem
  rw [p2_sub2_not_in_qnf'] at hbit
  exact Bool.noConfusion hbit

/-- **SEMANTIC separation under a concrete provider (the Phase-1.2 GO theorem)**: the
    corrected full-fiber content channel assigns the pair members DIFFERENT truth values —
    the `e*`-bucketed content disjunction of `sub₁` is TRUE at `t = 18` in `M*` (witness
    `e*` realized over `[10, 12, 15, 2, 18]` via `p2P.correct`), while that of `sub₂` is
    FALSE (its `e*`-bucket is empty: `e*` is not in its fiber). Exactly the separating
    power `f2_carrier_eq` shows the marginal/frozen construction lacks. -/
theorem kvE_fiberPos_separates_F2 :
    temporal_truth P2M p2atomMap 18 (kvE_fiberPosOn p2P (p2bucket p2sub1)) ∧
    ¬ temporal_truth P2M p2atomMap 18 (kvE_fiberPosOn p2P (p2bucket p2sub2)) := by
  constructor
  · rw [kvE_fiberPosOn_correct p2P (p2bucket p2sub1) P2M p2_UZ p2_SZ 18]
    refine ⟨p2estar, p2_estar_in_bucket1,
      Fin.cons 10 (Fin.cons 12 (Fin.cons 15 (fun _ => 2))), ?_⟩
    rw [p2_insertEnv4]
    exact nf_characteristic_satisfies P2M 0 5 (Fin.cons 10 (Fin.cons 12 p2env3))
  · rw [kvE_fiberPosOn_correct p2P (p2bucket p2sub2) P2M p2_UZ p2_SZ 18]
    rintro ⟨s, hmem, -⟩
    obtain ⟨hfib, hdec⟩ := List.mem_filter.mp hmem
    have hs : s = p2estar := of_decide_eq_true hdec
    subst hs
    have hbit := (kvE_fiber_mem p2sub2 p2estar).mp hfib
    rw [p2_estar_not_in_sub2] at hbit
    exact Bool.noConfusion hbit

end Bimodal.Metalogic.WeakCanonical.Kamp
