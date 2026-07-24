import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK

/-! # Depth-`k` Future-side exterior-negation converter — the reverse `_complete`

The reverse direction of the green `kvE_extNegFut_sound` (`ExteriorNegationK.lean:532`): from the
complement clause holding at `t` it is the **producer** direction we reverse — assuming the
positive local-existence form `kvE_futPos` at `t`, we reconstruct an exterior anchor `x1 > t`
realizing `σ` over `[x1, w, x, t]`, contradicting the carried non-realization hypothesis `hcl`.

**Faithful F2-sidestep (NOT overcome), carried as hypotheses (task 352 report 03 pattern)**: the
producer needs two arity-5 pinned-env inputs that the env-free content channel (`P.existF`,
`∃env`) cannot supply, so — exactly as the frozen k=2 `bracketEndChar_kvE2_sound_two_prior_frag`
(`OuterGate.lean:268`) carries `hrealI`/`hrealB`/`hexcl`/`hexclExt` as hypotheses discharged one
level up (`KampPrior:351`) — they are CARRIED here and discharged by the outer recursion /
task-349 provider:

- `hreal` (fiber-forward): every bit-true fiber sub `s` is realized at the pinned env
  `[v, x1, w, x, t]` (the arity-5 analog of `hrealI`/`hrealB`).
- `hsat` (fiber-backward / saturation, the depth-`k` `hexclExt` analog): at a reconstructed
  endpoint `x1`, every realizable on-fiber sub is recorded in `σ.2`. This is the exterior-anchor
  SATURATION residue — provably NOT derivable in-module (an unrecorded-but-realizable on-fiber
  sub would break the fold biconditional while leaving the recorded gap chain intact, so the
  bare converse is false), and env-dependent at arity 5 (task 352 report 03 Deliverable 2), so it
  is carried, not discharged here.

The depth-`k` chain destructor `kvE_futChainDestructG` (`ExteriorNegationK.lean:293`, the Cor 5.4
`Oₙ` re-anchoring engine, GREEN) drives the length-`n` recursion; the reconstruction reassembles
`nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` via `nf_eval_nfk_iff_efold` (`NfEFold.lean:627`). Off-fiber
falsity of `σ.2` comes from the admissibility conjunct 2. Purely additive NEW leaf module; no
frozen file is touched. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff)

/-! ## Admissibility conjunct-2 reader (off-fiber falsity)

The depth-`k` off-fiber determinacy the fold reconstruction needs: conjunct 2 of
`kvE_futAdmissible` (`ExteriorNegationK.lean:89`) states every bit-true full-arity sub sits on
`σ`'s atom fiber. A navigation-only read (G6) of the already-landed admissibility Boolean. -/

/-- **Admissibility ⇒ fiber dichotomy**: under `kvE_futAdmissible σ`, every full-arity sub either
    sits on `σ`'s atom fiber (`nfk_dropFresh s = σ.1`) or is prescribed false. The Boolean
    conjunct-2 read of `kvE_futAdmissible`. -/
theorem kvE_futAdmissible_fiber_dichotomy {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (hadm : kvE_futAdmissible σ = true) :
    ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 ∨ σ.2 s = false := by
  have hadm' := hadm
  unfold kvE_futAdmissible at hadm'
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hadm'
  obtain ⟨⟨⟨_, hB⟩, _⟩, _⟩ := hadm'
  intro s
  have hs := (List.all_eq_true.mp hB) s (Finset.mem_toList.mpr (Finset.mem_univ s))
  rw [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq] at hs
  rcases hs with ⟨h, -⟩ | h
  · exact Or.inl h
  · exact Or.inr (Bool.not_eq_true' _ |>.mp h)

/-- **On-fiber recording**: under admissibility, a bit-true sub sits on `σ`'s atom fiber. -/
theorem kvE_futAdmissible_onFiber {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (hadm : kvE_futAdmissible σ = true)
    (s : NormalForm sig k 5) (hbit : σ.2 s = true) :
    nfk_dropFresh s = σ.1 := by
  rcases kvE_futAdmissible_fiber_dichotomy σ hadm s with h | h
  · exact h
  · exact absurd hbit (by rw [h]; exact Bool.false_ne_true)

/-- **Off-fiber falsity**: under admissibility, a sub off `σ`'s atom fiber is prescribed false.
    The explicit off-fiber conjunct `nf_eval_nfk_iff_efold` demands for the reconstruction. -/
theorem kvE_futAdmissible_offFiber {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (hadm : kvE_futAdmissible σ = true)
    (s : NormalForm sig k 5) (hne : nfk_dropFresh s ≠ σ.1) :
    σ.2 s = false := by
  rcases kvE_futAdmissible_fiber_dichotomy σ hadm s with h | h
  · exact absurd h hne
  · exact h

/-! ## Atom-layer reconstruction from the carried realization bundle

The exterior anchor's atom layer at `[x1, w, x, t]` is recovered NOT by forcing σ's atom bits out
of the endpoint description (the saturation route, env-free-impossible at arity `k ≥ 1`), but by
routing a SINGLE bit-true sub through the carried `hreal` bundle: `hreal` delivers a full arity-5
realizer `[v, x1, w, x, t]` whose atom layer, dropped at the fresh index, IS `σ.1` at `[x1,w,x,t]`
(`nf_eval_nf0_cons_factor`). One bit-true sub always exists because a reached endpoint forces the
self-zone content nonempty (`hend`). -/

/-- **Atom layer via the bundle**: given any bit-true fiber sub `s0` (with `nfk_dropFresh s0 = σ.1`)
    and its carried realizer at `[v, x1, w, x, t]`, `σ`'s atom layer holds at `[x1, w, x, t]`. -/
theorem kvE_futAtom_of_bundle {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig (k + 1) 4) (v x1 w x t : M.carrier)
    (s0 : NormalForm sig k 5) (hd0 : nfk_dropFresh s0 = σ.1)
    (hv : nf_eval_nf M k 5
      (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s0) :
    nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 := by
  have hatom := nf_eval_nf_atom_layer M
    (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s0 hv
  have hfac := (nf_eval_nf0_cons_factor M
    (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) v s0.atom_assgn).mp hatom
  have hdrop : nf0_dropFresh s0.atom_assgn = σ.1 := hd0
  rw [hdrop] at hfac
  exact hfac.2.2

/-! ## The reverse converter `kvE_extNegFut_complete` (task 354 primary deliverable, Future)

Reverse of `kvE_extNegFut_sound`: assumes `kvE_futPos` at `t`, destructs the Cor 5.4 chain to an
endpoint `x1 > t`, and reassembles `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` (atom layer via the
bundle, fold biconditional forward via `hreal`, backward via the carried saturation residue
`hsat`, off-fiber falsity via admissibility), contradicting `hcl`. -/

/-- **The Future exterior converter** (task 354, the REVERSE of `kvE_extNegFut_sound`): with the
    carried arity-5 realization bundle `hreal` (fiber-forward) and the carried exterior-anchor
    saturation residue `hsat` (fiber-backward, the depth-`k` `hexclExt` analog, discharged by the
    outer recursion / task-349 provider — F2), if no exterior `x1 > t` realizes `σ` over
    `[x1, w, x, t]` then the complement clause holds at `t`.

    **Guarded restatement**: `hreal`/`hsat` carry their
    consumption-site truth antecedents — the chain-fire truth `kvE_futPos P σ` at `t`, the
    destructor-endpoint truth `kvE_futEnd P σ` at `x1`, and the destructor's pinned walk facts
    `hgap` (uniform gap disjunction on `(t, x1)`) and `hocc` (per-item pinned occurrence in
    `(t, x1)`) — making the obligations true-as-stated (the unguarded universals were
    machine-refuted, ExteriorFiberProbeK.lean). The chain destructor's facts are bound and
    threaded, no longer `_`-discarded. -/
theorem kvE_extNegFut_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hreal : ∀ x1 : M.carrier, t < x1 →
      temporal_truth M atomMap t (kvE_futPos P σ) →
      temporal_truth M atomMap x1 (kvE_futEnd P σ) →
      (∀ r : M.carrier, t < r → r < x1 → temporal_truth M atomMap r (kvE_futGapD P σ)) →
      (∀ a ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
        t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P a)) →
      ∀ s : NormalForm sig k 5, σ.2 s = true →
      ∃ v : M.carrier, nf_eval_nf M k 5
        (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hsat : ∀ x1 : M.carrier, t < x1 →
      temporal_truth M atomMap t (kvE_futPos P σ) →
      temporal_truth M atomMap x1 (kvE_futEnd P σ) →
      (∀ r : M.carrier, t < r → r < x1 → temporal_truth M atomMap r (kvE_futGapD P σ)) →
      (∀ a ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
        t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P a)) →
      ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
        (∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
        σ.2 s = true)
    (hcl : ∀ x1 : M.carrier, t < x1 →
      ¬ nf_eval_nf M (k + 1) 4
        (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap t (kvE_extNegFut P σ) := by
  rw [kvE_extNegFut, temporal_truth_neg]
  intro hpos
  have hpos0 := hpos
  by_cases hadm : kvE_futAdmissible σ = true
  · -- admissible: extract a chain and reconstruct the realizer
    rw [kvE_futPos, if_pos hadm, formula_disjList_iff] at hpos
    obtain ⟨φ, hφmem, hφ⟩ := hpos
    obtain ⟨l, hlmem, rfl⟩ := List.mem_map.mp hφmem
    have hlperm : l.Perm (kvE_fiberZoneList σ kvE_futGapZone) :=
      List.mem_permutations.mp hlmem
    -- item ⇒ gap guard: each chain item is a gap fiber sub, so it enters the gap disjunction
    have himp : ∀ a ∈ l, ∀ r : M.carrier,
        temporal_truth M atomMap r (kvE_futItemShift P a) →
        temporal_truth M atomMap r (kvE_futGapD P σ) := by
      intro a ha r hr
      have hamem : a ∈ kvE_fiberZoneList σ kvE_futGapZone := hlperm.subset ha
      rw [kvE_futGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ r]
      rw [kvE_futItemShift_correct P a M h_UZ h_SZ r] at hr
      obtain ⟨env, hev⟩ := hr
      exact ⟨a, hamem, env, hev⟩
    -- destruct the Cor 5.4 chain (binding the pinned walk facts `hgap`/`hocc` — task 360)
    obtain ⟨x1, htx1, hend, hgap, hocc⟩ :=
      kvE_futChainDestructG M atomMap (kvE_futItemShift P) (kvE_futEnd P σ)
        (kvE_futGapD P σ) l t himp hφ
    -- the `l`-free form of the per-item pinned occurrences (via the permutation)
    have hoccZ : ∀ a ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
        t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P a) :=
      fun a ha => hocc a (hlperm.mem_iff.mpr ha)
    -- a reached endpoint forces the self-zone content nonempty ⇒ a bit-true sub exists
    have hend0 := hend
    rw [kvE_futEnd, formula_conjList_iff] at hend0
    have hself := hend0 (kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_futSelfZone)) (by simp)
    rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1] at hself
    obtain ⟨s0, hs0mem, _env0, _hs0ev⟩ := hself
    have hbit0 : σ.2 s0 = true := ((kvE_fiberZoneList_mem σ kvE_futSelfZone s0).mp hs0mem).1
    have hd0 : nfk_dropFresh s0 = σ.1 := kvE_futAdmissible_onFiber σ hadm s0 hbit0
    -- atom layer at `[x1,w,x,t]` via the carried bundle on that bit-true sub
    obtain ⟨v0, hv0⟩ := hreal x1 htx1 hpos0 hend hgap hoccZ s0 hbit0
    have hA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
      kvE_futAtom_of_bundle M σ v0 x1 w x t s0 hd0 hv0
    -- fold biconditional: forward via `hreal`, backward via the carried saturation residue
    have hfib : ∀ sub : NormalForm sig k 5, nfk_dropFresh sub = σ.1 →
        ((∃ y : M.carrier, nf_eval_nf M k 5
          (Fin.cons y (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) sub) ↔
          σ.2 sub = true) := by
      intro sub hd
      constructor
      · intro hex; exact hsat x1 htx1 hpos0 hend hgap hoccZ sub hd hex
      · intro hbit; exact hreal x1 htx1 hpos0 hend hgap hoccZ sub hbit
    -- reassemble the realizer of `σ` at the reconstructed exterior anchor
    have hσ : nf_eval_nf M (k + 1) 4
        (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ :=
      (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mpr
        ⟨⟨hA, hfib⟩, fun sub hne => kvE_futAdmissible_offFiber σ hadm sub hne⟩
    exact hcl x1 htx1 hσ
  · rw [kvE_futPos, if_neg hadm] at hpos
    exact hpos

/-! ## Phase 5 — bundle-shape reconciliation (the outer-recursion discharge template)

The `_complete` above carries two hypotheses — the arity-5 realization bundle `hreal` and the
saturation residue `hsat` — that the outer recursion / task-349 provider must discharge. The
discharge template below proves both carried obligations are SOUND: whenever the outer recursion
produces a GENUINE exterior realizer `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` (as it does when it picks
`x1` by the Rabinovich inf/sup), the carried `hreal`/`hsat` shapes both hold. It is the faithful
Option-B "at-anchor determinacy reader" (report 01 Deliverable 5): a direct read through
`nf_eval_nfk_iff_efold` (`NfEFold.lean:627`) — the below-`t`/at-anchor fiber determinacy — closing
the loop that the carried hypotheses are not debt but a dischargeable interface. -/

/-- **Discharge template** (Future): from an actual realizer of `σ` at the reconstructed anchor
    `[x1, w, x, t]`, BOTH carried obligations of `kvE_extNegFut_complete` hold — the fiber-forward
    bundle (`hreal` shape) and the fiber-backward saturation slice (`hsat` shape). Pure read of the
    fold characterization `nf_eval_nfk_iff_efold`. This is what the task-349 outer recursion supplies
    at a genuine exterior anchor, proving the carried hypotheses sound (not debt). -/
theorem kvE_futBundle_of_realizer {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig (k + 1) 4) (x1 w x t : M.carrier)
    (hσ : nf_eval_nf M (k + 1) 4
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (∀ s : NormalForm sig k 5, σ.2 s = true →
        ∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) ∧
    (∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
        (∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
        σ.2 s = true) := by
  obtain ⟨⟨_hA, hfib⟩, hoff⟩ :=
    (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mp hσ
  refine ⟨fun s hbit => ?_, fun s hd hex => (hfib s hd).mp hex⟩
  by_cases hd : nfk_dropFresh s = σ.1
  · exact (hfib s hd).mpr hbit
  · rw [hoff s hd] at hbit; exact absurd hbit (by decide)

end Bimodal.Metalogic.WeakCanonical.Kamp
