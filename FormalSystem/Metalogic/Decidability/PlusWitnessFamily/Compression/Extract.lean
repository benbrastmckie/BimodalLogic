/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Compression.Fulfil
import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Extract

/-!
# L⁺ Readout and the Segment Bound

The L⁺ twin of `WitnessFamily/Compression/Extract.lean`'s readout layer: the lemmas that turn
three finite segments into a bi-infinite function and back, plus the segment-length bound the
compression theorem states.

## Eight readout lemmas are reused, not transcribed

The `Formula`-side module's readout layer is generic by construction. `getD_mapC`,
`getD_range_mapC`, `periodic_rel_of_windowC`, `readout_backC`, `readout_midC` and `readout_fwdC`
are all declared over `{α : Type*} [Inhabited α]`, and `reduce_emodC` and `emod_succ_congrC` are
pure `Int.emod` facts over bare integers. None of the eight mentions `Formula`, `Context`,
`closureOf` or `TypeState`, so all eight are **reused by import** rather than re-proved. This
module imports the `Formula`-side `Compression/Extract.lean` for exactly those eight, alongside
the pigeonhole pair `Compression/Cycle.lean` already supplies.

What is *not* generic is the decoding lemma `typeOfT_unrollOf`, which is stated at
`TypeState C = {S : Finset Formula // S ∈ C.powerset}` and cannot be re-indexed at
`PlusFormula` — `Formula` and `PlusFormula` are separate inductives with no supertype. It is
transcribed below as `plusTypeOfT_unrollOf`.

## The two bounds

`plusMidBoundC` and `plusCompressionBound` are the `Formula`-side `midBoundC` and
`compressionBound` at the L⁺ closure. Their *shape* is unchanged for the reason Phase 4's
`plusCycleBoundC` records: the L⁺ closure carries a `stab` tier, which enlarges `C.card`, but
`⊡` contributes no event and so no excursion, so no accounting term is added.

`plusCompressionBound` takes the maximum of the two derived bounds unconditionally, exactly as
the `Formula` side does, so that no closure-cardinality lemma is needed here and the definition
stays correct with no side condition.

## Main Definitions

- `plusMidBoundC` — the mid-segment bound, twice one full residue system
- `plusCompressionBound` — the segment-length bound the L⁺ compression theorem states

## Main Results

- `plusTypeOfT_unrollOf` — the type component of a decoded L⁺ datum is the decoded label
- `plusCycleBoundC_le_plusCompressionBound` / `plusMidBoundC_le_plusCompressionBound`

Argument order is **guard first**: `PlusFormula.untl g e`, `PlusFormula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics

variable {C : Finset PlusFormula}

/-! ## The L⁺ decoding lemma -/

/--
**The type component of a decoded L⁺ datum is the decoded label.**

The one member of the readout layer that is not generic: it is stated at `PlusTypeState C`, whose
`Formula`-side counterpart `TypeState C` cannot be re-indexed. The proof is the `Formula`-side
one with `typeOfT` replaced by `plusTypeOfT`, and it consumes the *generic* `getD_mapC`, which is
reused by import rather than transcribed.
-/
theorem plusTypeOfT_unrollOf (bD mD fD : List (PlusTypeState C)) (t : ℤ) :
    plusTypeOfT (Periodic.unrollOf bD mD fD t)
      = Periodic.unrollOf (bD.map plusTypeOfT) (mD.map plusTypeOfT) (fD.map plusTypeOfT) t := by
  have hd : plusTypeOfT (default : PlusTypeState C) = (default : Finset PlusFormula) := rfl
  have hcyc : ∀ (l : List (PlusTypeState C)) (i : ℤ),
      plusTypeOfT (Periodic.cyc l i) = Periodic.cyc (l.map plusTypeOfT) i := by
    intro l i
    simp only [Periodic.cyc, List.length_map]
    exact (getD_mapC plusTypeOfT hd l _).symm
  simp only [Periodic.unrollOf, List.length_map]
  split_ifs with h1 h2
  · exact hcyc bD t
  · exact (getD_mapC plusTypeOfT hd mD _).symm
  · exact hcyc fD _

/-! ## The bounds -/

/--
The L⁺ mid-segment bound: twice one full residue system.

The mid walk is shortened in two legs, each to fewer than `Nat.card (PlusTypeState C)` steps, and
the recorded segment is one shorter than their sum.
-/
def plusMidBoundC (C : Finset PlusFormula) : ℕ := 2 * 2 ^ C.card

theorem plusMidBoundC_eq (C : Finset PlusFormula) :
    plusMidBoundC C = 2 * Nat.card (PlusTypeState C) := by
  rw [plusMidBoundC, natCard_plusTypeState]

/--
**The L⁺ segment-length bound**: the length every extracted lasso segment is bounded by.

The maximum of the two derived bounds, taken unconditionally exactly as the `Formula`-side
`compressionBound` is, so that no closure-cardinality lemma is needed here and the definition
stays correct with no side condition.

This is the quantity the compression theorem states for `back`, `mid` and `fwd` alike, and it is
also the common padded cycle length Phase 7's Invariant A drives every extracted lasso to. Those
two roles are deliberately the same number: `SharingWindow` requires the backward and forward
periods to be common multiples of every listed cycle length, and leaving the segments at
differing lengths would make that a least common multiple over as many lengths as there are
lassos.
-/
def plusCompressionBound (Γ Del : PlusContext) : ℕ :=
  max (plusCycleBoundC (plusClosureOf (Γ ++ Del))) (plusMidBoundC (plusClosureOf (Γ ++ Del)))

theorem plusCycleBoundC_le_plusCompressionBound (Γ Del : PlusContext) :
    plusCycleBoundC (plusClosureOf (Γ ++ Del)) ≤ plusCompressionBound Γ Del := le_max_left _ _

theorem plusMidBoundC_le_plusCompressionBound (Γ Del : PlusContext) :
    plusMidBoundC (plusClosureOf (Γ ++ Del)) ≤ plusCompressionBound Γ Del := le_max_right _ _

/-- The L⁺ segment bound is positive, so a padded segment is never the empty list. Phase 7's
Invariant A and the `PlusLabelledLasso` non-emptiness fields both need this. -/
theorem plusCompressionBound_pos (Γ Del : PlusContext) : 0 < plusCompressionBound Γ Del := by
  refine lt_of_lt_of_le ?_ (plusMidBoundC_le_plusCompressionBound Γ Del)
  rw [plusMidBoundC]
  positivity

/-! ## The splice lemma, presentation-free -/

/--
**An L⁺ label sequence whose every consecutive pair is realised by the model is locally
coherent.**

The reason cutting and pasting is sound is worth restating, because it is what the whole
compression rests on: every clause of `PlusLocalCoherentSeqLab` at a position `t` reads only

- that position's label (`bot`, `imp`, `box`),
- the label one step to the right (`untl`),
- the label one step to the left (`snce`),

and nothing else. No clause reaches two steps away and no clause mentions `t` itself. So a
sequence assembled by jumping from a model time `u` to a model time `v + 1` whenever the types
agree still satisfies every clause: the seam edge is literally an edge the history realised.

**This is exactly where the absence of a `stab` clause pays.** A sixth clause relating a label to
labels at *other indices* at the same time would not be a local read, and no amount of type
agreement along one history would establish it. (C5) is that condition, and it is discharged at
the family, not at a sequence — which is why the L⁺ splice lemma is the `Formula`-side one with
the language changed and nothing added.
-/
theorem plusLocalCoherentSeqLab_of_edges {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : PlusContext) (bx : PlusFormula → Bool)
    (hbx : ∀ χ : PlusFormula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), PlusTruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) (lab : ℤ → Finset PlusFormula)
    (hedge : ∀ T : ℤ, ∃ u : ℤ,
      lab T = plusTypeAtM M Γ Del τ u ∧ lab (T + 1) = plusTypeAtM M Γ Del τ (u + 1)) :
    PlusLocalCoherentSeqLab Γ Del bx lab := by
  have hmodel := plusTypeAtM_localCoherentSeqLab M Γ Del bx hbx τ
  intro t
  obtain ⟨u, hu0, hu1⟩ := hedge t
  obtain ⟨v, hv0, hv1⟩ := hedge (t - 1)
  rw [show t - 1 + 1 = t by omega] at hv1
  obtain ⟨hbot, himp, hbox, huntl, -⟩ := hmodel u
  obtain ⟨-, -, -, -, hsnce⟩ := hmodel (v + 1)
  rw [show v + 1 - 1 = v by omega] at hsnce
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · rw [hu0]; exact hbot
  · rw [hu0]; exact himp
  · rw [hu0]; exact hbox
  · rw [hu0, hu1]; exact huntl
  · rw [hv1, hv0]; exact hsnce

/-! ## One history to one labelled lasso -/

/--
**One L⁺ history compresses to one bounded labelled lasso.**

From an arbitrary world history `τ` of an arbitrary `FrameOver intOrder` model and an arbitrary
time `t`, produce a `PlusLabelledLasso (plusClosureOf (Γ ++ Del))` with all three segments bounded
by `plusCompressionBound Γ Del`, whose decoded label function is locally coherent and fulfilling,
and which carries `τ`'s type at `t` at a position in the closed interval `[0, nm]`.

The proof compresses `τ` into three walks in the L⁺ type graph and reassembles them:

- **`fwd`** is a good forward cycle through a type recurring at arbitrarily large times;
- **`back`** is a good backward cycle through a type recurring at arbitrarily small times,
  obtained from the *same* generic construction at the reversed sequence `fun u => d (-u)`;
- **`mid`** is the walk between the two, shortened in two legs so that the position of `t`
  survives as a marked interior point — and whose first leg takes one real step before
  shortening, so that the marked position is never negative.

Local coherence comes from `plusLocalCoherentSeqLab_of_edges` fed by `periodic_rel_of_windowC`;
fulfilment from `plusFulfillingSeqLab_of_good_cycles`.

The realization conjunct — every decoded label is the type of *some* genuine position of the
same model — is what the assembly spends on the forward direction of `PlusBoxFaithful`, and it
is what Phase 8's (C5) saturation reads to find the world state underlying each index.
-/
theorem exists_plusLabelledLasso_of_history_realized {F : FrameOver intOrder}
    (M : TaskModel F.toTaskFrame)
    (Γ Del : PlusContext) (bx : PlusFormula → Bool)
    (hbx : ∀ χ : PlusFormula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), PlusTruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ∃ (Λ : PlusLabelledLasso (plusClosureOf (Γ ++ Del))) (i : ℤ),
      Λ.back.length ≤ plusCompressionBound Γ Del ∧
      Λ.mid.length ≤ plusCompressionBound Γ Del ∧
      Λ.fwd.length ≤ plusCompressionBound Γ Del ∧
      0 ≤ i ∧ i ≤ Λ.nm ∧
      Λ.lab i = plusTypeAtM M Γ Del τ t ∧
      PlusLocalCoherentSeqLab Γ Del bx Λ.lab ∧ PlusFulfillingSeqLab Λ.lab ∧
      (∀ j : ℤ, ∃ u : ℤ, Λ.lab j = plusTypeAtM M Γ Del τ u) := by
  classical
  set C : Finset PlusFormula := plusClosureOf (Γ ++ Del) with hC
  -- ### The type sequence of the history, as a datum sequence
  set d : ℤ → PlusTypeState C := fun u =>
    ⟨plusTypeAtM M Γ Del τ u, Finset.mem_powerset.mpr (plusTypeAtM_subset M Γ Del τ u)⟩ with hd
  have hdtype : ∀ u : ℤ, plusTypeOfT (d u) = plusTypeAtM M Γ Del τ u := fun _ => rfl
  have hful := plusTypeAtM_fulfillingSeqLab (M := M) Γ Del τ
  -- ### The two good cycles
  have hfulf : ∀ (u : ℤ) (f e : PlusFormula), f ∈ (d u).1 → plusUntlEventT f = some e →
      ∃ s : ℤ, u < s ∧ e ∈ (d s).1 := by
    intro u f e hfm hev
    obtain ⟨g, rfl⟩ := plusUntlEventT_eq_some hev
    obtain ⟨s, hs, hes, -⟩ := hful.1 u g e hfm
    exact ⟨s, hs, hes⟩
  have hfulb : ∀ (u : ℤ) (f e : PlusFormula), f ∈ (d (-u)).1 → plusSnceEventT f = some e →
      ∃ s : ℤ, u < s ∧ e ∈ (d (-s)).1 := by
    intro u f e hfm hev
    obtain ⟨g, rfl⟩ := plusSnceEventT_eq_some hev
    obtain ⟨s, hs, hes, -⟩ := hful.2 (-u) g e hfm
    refine ⟨-s, by omega, ?_⟩
    rw [show -(-s) = s by omega]
    exact hes
  obtain ⟨xf, hrecf⟩ := exists_recurring_plusTypeState d
  obtain ⟨Lf, pf, hLf1, hLfB, hpf0, hpfL, hpfst, hpfgood⟩ :=
    exists_good_cycle_of_plusTypeSeq C d plusUntlEventT xf hrecf hfulf
  obtain ⟨xb, hrecb⟩ := exists_recurring_plusTypeState (fun u => d (-u))
  obtain ⟨Lb, qb, hLb1, hLbB, hqb0, hqbL, hqbst', hqbgood⟩ :=
    exists_good_cycle_of_plusTypeSeq C (fun u => d (-u)) plusSnceEventT xb hrecb hfulb
  -- the backward cycle's steps, read in the forward direction
  have hqbst : ∀ j, j < Lb → PlusSeqStepT d (qb (j + 1)) (qb j) := by
    intro j hj
    obtain ⟨u, hu1, hu2⟩ := hqbst' j hj
    refine ⟨-u - 1, ?_, ?_⟩
    · rw [← hu2]; congr 1; omega
    · rw [← hu1]; congr 1; omega
  -- ### The mid walk, shortened in two legs around the point of interest
  obtain ⟨ub, hubge, hubd⟩ := hrecb (1 - t)
  have hitA : iter (PlusSeqStepT d) (t - (-ub + 1)).toNat (d (-ub + 1)) (d t) := by
    have h := iter_plusSeqStepT d (-ub + 1) (t - (-ub + 1)).toNat
    rwa [show -ub + 1 + (((t - (-ub + 1)).toNat : ℕ) : ℤ) = t by omega] at h
  obtain ⟨a, ha, haiter⟩ := exists_iterT_lt_card (PlusSeqStepT d) hitA
  obtain ⟨pa, hpa0, hpaa, hpast⟩ := exists_path_of_iter (PlusSeqStepT d) a _ _ haiter
  obtain ⟨uf, hufge, hufd⟩ := hrecf (t + 1)
  have hitB : iter (PlusSeqStepT d) (uf - t).toNat (d t) xf := by
    have h := iter_plusSeqStepT d t (uf - t).toNat
    rwa [show t + (((uf - t).toNat : ℕ) : ℤ) = uf by omega, hufd] at h
  obtain ⟨b, hb, hbiter⟩ := exists_iterT_lt_card (PlusSeqStepT d) hitB
  obtain ⟨pb, hpb0, hpbb, hpbst⟩ := exists_path_of_iter (PlusSeqStepT d) b _ _ hbiter
  -- the first leg, with one real step prepended so that its length is at least one
  obtain ⟨wA, hwA⟩ : ∃ f : ℕ → PlusTypeState C,
      f = fun j => if j = 0 then xb else pa (j - 1) := ⟨_, rfl⟩
  have hwA0 : wA 0 = xb := by rw [hwA]; simp
  have hwAa : wA (a + 1) = d t := by rw [hwA]; simpa using hpaa
  have hwAst : ∀ j, j < a + 1 → PlusSeqStepT d (wA j) (wA (j + 1)) := by
    intro j hj
    rcases Nat.eq_zero_or_pos j with rfl | hjpos
    · rw [hwA]
      simp only [hpa0]
      exact ⟨-ub, hubd, rfl⟩
    · rw [hwA]
      simp only [if_neg (by omega : ¬ j = 0), if_neg (by omega : ¬ j + 1 = 0)]
      have := hpast (j - 1) (by omega)
      rwa [show j - 1 + 1 = j + 1 - 1 by omega] at this
  -- the whole mid walk
  obtain ⟨w, hw⟩ : ∃ f : ℕ → PlusTypeState C, f = plusJoinPathT wA pb (a + 1) := ⟨_, rfl⟩
  have hseam : wA (a + 1) = pb 0 := by rw [hwAa, hpb0]
  have hw0 : w 0 = xb := by rw [hw, plusJoinPathT_left wA pb (Nat.zero_le _), hwA0]
  have hwmark : w (a + 1) = d t := by rw [hw, plusJoinPathT_left wA pb (le_refl _), hwAa]
  have hwend : w (a + 1 + b) = xf := by
    rw [hw, plusJoinPathT_right wA pb (a + 1) hseam b, hpbb]
  have hwst : ∀ j, j < a + 1 + b → PlusSeqStepT d (w j) (w (j + 1)) := by
    rw [hw]; exact plusJoinPathT_steps wA pb (a + 1) b hseam hwAst hpbst
  -- ### The three segments
  obtain ⟨nm, hnm⟩ : ∃ n : ℕ, n = a + b := ⟨_, rfl⟩
  have hnmw : w (nm + 1) = xf := by rw [hnm, show a + b + 1 = a + 1 + b by omega, hwend]
  have hnmst : ∀ j, j < nm + 1 → PlusSeqStepT d (w j) (w (j + 1)) := by
    rw [hnm, show a + b + 1 = a + 1 + b by omega]; exact hwst
  obtain ⟨bD, hbD⟩ : ∃ l : List (PlusTypeState C),
      l = (List.range Lb).map (fun i => qb (Lb - 1 - i)) := ⟨_, rfl⟩
  obtain ⟨mD, hmD⟩ : ∃ l : List (PlusTypeState C),
      l = (List.range nm).map (fun i => w (i + 1)) := ⟨_, rfl⟩
  obtain ⟨fD, hfD⟩ : ∃ l : List (PlusTypeState C),
      l = (List.range Lf).map (fun i => pf i) := ⟨_, rfl⟩
  have hbDlen : bD.length = Lb := by rw [hbD]; simp
  have hmDlen : mD.length = nm := by rw [hmD]; simp
  have hfDlen : fD.length = Lf := by rw [hfD]; simp
  -- ### Reading the decoding back off the three walks
  have hback : ∀ T : ℤ, -(Lb : ℤ) - 1 ≤ T → T ≤ -1 →
      Periodic.unrollOf bD mD fD T = qb (-1 - T).toNat := by
    intro T h1 h2
    rw [hbD]
    exact readout_backC Lb hLb1 qb (by rw [hqbL, hqb0]) mD fD h1 h2
  have hfwd : ∀ T : ℤ, (nm : ℤ) ≤ T → T ≤ (nm : ℤ) + (Lf : ℤ) →
      Periodic.unrollOf bD mD fD T = pf (T - (nm : ℤ)).toNat := by
    intro T h1 h2
    rw [hfD]
    have hr := readout_fwdC Lf hLf1 pf (by rw [hpfL, hpf0]) bD mD (T := T)
      (by rw [hmDlen]; exact h1) (by rw [hmDlen]; exact h2)
    rwa [hmDlen] at hr
  have hmidall : ∀ T : ℤ, -1 ≤ T → T ≤ (nm : ℤ) →
      Periodic.unrollOf bD mD fD T = w (T + 1).toNat := by
    intro T h1 h2
    rcases (by omega : T = -1 ∨ (0 ≤ T ∧ T < (nm : ℤ)) ∨ T = (nm : ℤ)) with rfl | ⟨h3, h4⟩ | rfl
    · rw [hback (-1) (by omega) (by omega),
        show (-1 - (-1 : ℤ)).toNat = 0 by omega, show ((-1 : ℤ) + 1).toNat = 0 by omega,
        hqb0, hw0]
    · rw [hmD, readout_midC bD fD nm w h3 h4]
      congr 1
      omega
    · rw [hfwd (nm : ℤ) (by omega) (by omega), show ((nm : ℤ) - (nm : ℤ)).toNat = 0 by omega,
        hpf0, show (((nm : ℤ)) + 1).toNat = nm + 1 by omega, hnmw]
  -- ### Every consecutive pair of decoded data is realised by the history
  have hbDne : bD ≠ [] := by
    intro hnil; rw [hnil] at hbDlen; simp at hbDlen; omega
  have hfDne : fD ≠ [] := by
    intro hnil; rw [hnil] at hfDlen; simp at hfDlen; omega
  have hEstep : ∀ T : ℤ,
      PlusSeqStepT d (Periodic.unrollOf bD mD fD T) (Periodic.unrollOf bD mD fD (T + 1)) := by
    refine periodic_rel_of_windowC bD mD fD hbDne hfDne ?_
    intro T h1 h2
    rw [hbDlen] at h1
    rw [hmDlen, hfDlen] at h2
    rcases (by omega : T ≤ -2 ∨ (-1 ≤ T ∧ T ≤ (nm : ℤ) - 1) ∨ (nm : ℤ) ≤ T) with h3 | ⟨h3, h4⟩ | h3
    · rw [hback T (by omega) (by omega), hback (T + 1) (by omega) (by omega),
        show (-1 - T).toNat = (-1 - (T + 1)).toNat + 1 by omega]
      exact hqbst (-1 - (T + 1)).toNat (by omega)
    · rw [hmidall T (by omega) (by omega), hmidall (T + 1) (by omega) (by omega),
        show (T + 1 + 1).toNat = (T + 1).toNat + 1 by omega]
      exact hnmst (T + 1).toNat (by omega)
    · rw [hfwd T (by omega) (by omega), hfwd (T + 1) (by omega) (by omega),
        show (T + 1 - (nm : ℤ)).toNat = (T - (nm : ℤ)).toNat + 1 by omega]
      exact hpfst (T - (nm : ℤ)).toNat (by omega)
  -- ### Assemble the labelled lasso
  have hbackne : bD.map plusTypeOfT ≠ [] := by
    intro hnil
    have hl : (bD.map plusTypeOfT).length = Lb := by rw [List.length_map, hbDlen]
    rw [hnil] at hl; simp at hl; omega
  have hfwdne : fD.map plusTypeOfT ≠ [] := by
    intro hnil
    have hl : (fD.map plusTypeOfT).length = Lf := by rw [List.length_map, hfDlen]
    rw [hnil] at hl; simp at hl; omega
  obtain ⟨Λ, hΛ⟩ : ∃ Λ : PlusLabelledLasso C, Λ =
      { back := bD.map plusTypeOfT
        mid := mD.map plusTypeOfT
        fwd := fD.map plusTypeOfT
        back_ne := hbackne
        fwd_ne := hfwdne
        label_sub := by
          intro S hS
          simp only [List.mem_append, List.mem_map] at hS
          rcases hS with (⟨x, -, rfl⟩ | ⟨x, -, rfl⟩) | ⟨x, -, rfl⟩ <;>
            exact plusTypeOfT_subset x } :=
    ⟨_, rfl⟩
  have hΛlab : ∀ T : ℤ, Λ.lab T = plusTypeOfT (Periodic.unrollOf bD mD fD T) := by
    intro T; rw [hΛ, PlusLabelledLasso.lab_def, plusTypeOfT_unrollOf]
  have hΛnb : Λ.back.length = Lb := by rw [hΛ, List.length_map, hbDlen]
  have hΛnm : Λ.mid.length = nm := by rw [hΛ, List.length_map, hmDlen]
  have hΛnf : Λ.fwd.length = Lf := by rw [hΛ, List.length_map, hfDlen]
  -- ### Local coherence, from the splice lemma
  have hloc : PlusLocalCoherentSeqLab Γ Del bx Λ.lab := by
    refine plusLocalCoherentSeqLab_of_edges M Γ Del bx hbx τ Λ.lab (fun T => ?_)
    obtain ⟨u, hu1, hu2⟩ := hEstep T
    exact ⟨u, by rw [hΛlab, ← hu1, hdtype], by rw [hΛlab, ← hu2, hdtype]⟩
  -- ### The three segment lengths, as integers
  have hnbZ : Λ.nb = (Lb : ℤ) := by simp only [PlusLabelledLasso.nb, hΛnb]
  have hnmZ : Λ.nm = (nm : ℤ) := by simp only [PlusLabelledLasso.nm, hΛnm]
  have hnfZ : Λ.nf = (Lf : ℤ) := by simp only [PlusLabelledLasso.nf, hΛnf]
  -- ### Fulfilment, from the two good cycles
  have hfulΛ : PlusFulfillingSeqLab Λ.lab := by
    refine plusFulfillingSeqLab_of_good_cycles (bx := bx) hloc (fun T => Λ.lab_subset T)
      (nb := Λ.nb) (nf := Λ.nf) (nm := Λ.nm) Λ.nb_pos Λ.nf_pos
      (fun T hT => Λ.lab_sub_back_length hT) (fun T hT => Λ.lab_add_fwd_length hT) ?_ ?_
    · intro g e hge
      have hlabnm : Λ.lab Λ.nm = plusTypeOfT (pf 0) := by
        rw [hnmZ, hΛlab, hfwd (nm : ℤ) (le_refl _) (by omega),
          show ((nm : ℤ) - (nm : ℤ)).toNat = 0 by omega]
      rw [hlabnm, hpf0] at hge
      obtain ⟨j, hj, hjmem⟩ := hpfgood _ e hge rfl
      refine ⟨(nm : ℤ) + (j : ℤ) + 1, by rw [hnmZ]; omega, by rw [hnmZ, hnfZ]; omega, ?_⟩
      rw [hΛlab, hfwd _ (by omega) (by omega),
        show ((nm : ℤ) + (j : ℤ) + 1 - (nm : ℤ)).toNat = j + 1 by omega]
      exact hjmem
    · intro g e hge
      have hlabm1 : Λ.lab (-1) = plusTypeOfT (qb 0) := by
        rw [hΛlab, hback (-1) (by omega) (by omega), show (-1 - (-1 : ℤ)).toNat = 0 by omega]
      rw [hlabm1, hqb0] at hge
      obtain ⟨j, hj, hjmem⟩ := hqbgood _ e hge rfl
      refine ⟨-2 - (j : ℤ), by rw [hnbZ]; omega, by omega, ?_⟩
      rw [hΛlab, hback _ (by omega) (by omega),
        show (-1 - (-2 - (j : ℤ))).toNat = j + 1 by omega]
      exact hjmem
  -- ### The bounds
  have hcard : Nat.card (PlusTypeState C) = 2 ^ C.card := natCard_plusTypeState C
  have hcbU : (2 * C.card + 1) * 2 ^ C.card ≤ plusCompressionBound Γ Del := by
    have h : plusCycleBoundC C ≤ plusCompressionBound Γ Del := by
      rw [hC]; exact plusCycleBoundC_le_plusCompressionBound Γ Del
    exact h
  have hmbU : 2 * 2 ^ C.card ≤ plusCompressionBound Γ Del := by
    have h : plusMidBoundC C ≤ plusCompressionBound Γ Del := by
      rw [hC]; exact plusMidBoundC_le_plusCompressionBound Γ Del
    exact h
  have ha' : a < 2 ^ C.card := by rwa [hcard] at ha
  have hb' : b < 2 ^ C.card := by rwa [hcard] at hb
  -- ### The witness position
  have hreal : ∀ j : ℤ, ∃ u : ℤ, Λ.lab j = plusTypeAtM M Γ Del τ u := by
    intro j
    obtain ⟨u, hu1, -⟩ := hEstep j
    exact ⟨u, by rw [hΛlab, ← hu1, hdtype]⟩
  refine ⟨Λ, (a : ℤ), ?_, ?_, ?_, by omega, ?_, ?_, hloc, hfulΛ, hreal⟩
  · rw [hΛnb]; exact le_trans hLbB hcbU
  · rw [hΛnm]; omega
  · rw [hΛnf]; exact le_trans hLfB hcbU
  · rw [hnmZ]; omega
  · rw [hΛlab, hmidall (a : ℤ) (by omega) (by rw [hnm]; omega),
      show ((a : ℤ) + 1).toNat = a + 1 by omega, hwmark, hdtype]

/--
**One L⁺ history compresses to one bounded labelled lasso** — the pinned form.

`exists_plusLabelledLasso_of_history_realized` with its last conjunct dropped. That conjunct
records that every decoded label is the type of a genuine position of the same model; it is what
the assembly spends on the forward direction of `PlusBoxFaithful` and what the (C5) saturation
reads, and it is carried by the strengthened form rather than by this one so that this statement
stays exactly as the plan pins it.
-/
theorem exists_plusLabelledLasso_of_history {F : FrameOver intOrder}
    (M : TaskModel F.toTaskFrame)
    (Γ Del : PlusContext) (bx : PlusFormula → Bool)
    (hbx : ∀ χ : PlusFormula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), PlusTruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ∃ (Λ : PlusLabelledLasso (plusClosureOf (Γ ++ Del))) (i : ℤ),
      Λ.back.length ≤ plusCompressionBound Γ Del ∧
      Λ.mid.length ≤ plusCompressionBound Γ Del ∧
      Λ.fwd.length ≤ plusCompressionBound Γ Del ∧
      0 ≤ i ∧ i ≤ Λ.nm ∧
      Λ.lab i = plusTypeAtM M Γ Del τ t ∧
      PlusLocalCoherentSeqLab Γ Del bx Λ.lab ∧ PlusFulfillingSeqLab Λ.lab := by
  obtain ⟨Λ, i, h1, h2, h3, h4, h5, h6, h7, h8, -⟩ :=
    exists_plusLabelledLasso_of_history_realized M Γ Del bx hbx τ t
  exact ⟨Λ, i, h1, h2, h3, h4, h5, h6, h7, h8⟩

/--
**Transporting L⁺ local coherence across a box guess that agrees on the closure.**

`PlusLocalCoherentSeqLab`'s only use of `bx` is its box clause, which is guarded by
`PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del)`. So two guesses agreeing on exactly those `χ` are
interchangeable. This is what lets the compression build its lassos against the (noncomputable,
unguarded) truth oracle and then hand the family the canonical, *enumerable* guess
`fun χ => decide (χ ∈ B)`.
-/
theorem plusLocalCoherentSeqLab_congr_bx {Γ Del : PlusContext} {bx₁ bx₂ : PlusFormula → Bool}
    {lab : ℤ → Finset PlusFormula}
    (hagree : ∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) → bx₁ χ = bx₂ χ)
    (hco : PlusLocalCoherentSeqLab Γ Del bx₁ lab) :
    PlusLocalCoherentSeqLab Γ Del bx₂ lab := by
  intro t
  obtain ⟨hbot, himp, hbox, huntl, hsnce⟩ := hco t
  refine ⟨hbot, himp, fun χ hχ => ?_, huntl, hsnce⟩
  rw [hbox χ hχ, hagree χ hχ]

end FormalSystem.Metalogic.Decidability
