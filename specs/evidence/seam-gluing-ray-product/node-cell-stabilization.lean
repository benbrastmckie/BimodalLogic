/-
Probe 758 (requirement (W)'s run layer, phase 2, first statement, on the one-region fixture):
**POSITIVE — realized cells on `Node` stabilize past pre-index 1, the deadline index is real,
the thread index is invisible.** This file is the machine-checked record of the stabilization
statement the RaySummary README names first under "(W): what landed and what did not",
obligation (ii) item 1, specialised to the library's one-region fixture; the general ladder
lemma (its successor) is not stated here.

**Witness.** `Φ` of `PlusSlicedCertificate/Limits/NoFiniteWidth.lean`, the fixture's own
`⊡`-bearing witness; fallback `D` not needed. The chosen formula is written into the statements.

**The fixture.** `NoFiniteWidth.M` on `F` — regular by `F_isRegular`; every history canonical
by `hist_canon`/`path_eq_canon`. The probe cites `histOf`, `histOf_state`, `canon_of_lt`,
`canon_self`, `canon_of_gt`, `canon_eq_x_iff`, `lt_of_canon_eq_of_lt`, `gt_of_canon_eq_of_gt`,
`eq_of_canon_eq_of_eq`, `truth_p`, `truth_Fp`, `truth_Pp`, `truth_Xp`, `Φ_true`, `box_global`,
`cellAt`, `mem_cellAt_iff` and `mem_tpOf_iff`, and re-proves none of them. No lemma is added
to `FormalSystem/`.

**What it establishes.** The three statements, verbatim:
  `theorem preCell_stable (k k' : ℕ) (hk : 1 ≤ k) (hk' : 1 ≤ k') (z : ℤ) :
      cellAt M Φ (.pre k) z = cellAt M Φ (.pre k') z`
  `theorem preCell_zero_ne (z : ℤ) : cellAt M Φ (.pre 0) z ≠ cellAt M Φ (.pre 1) z`
      -- the deadline index is real
  `theorem postCell_stable (k k' j j' : ℕ) (hj : 1 ≤ j) (hj' : 1 ≤ j') (z : ℤ) :
      cellAt M Φ (.post k j) z = cellAt M Φ (.post k' j') z`
      -- the thread index is invisible
and the bonus `xCell_stable` (`cellAt M Φ (.x k) z = cellAt M Φ (.x k') z`). `cellAt` is
`RaySummary/AnchorLayer.lean`'s realized cell — the set of closure types `tpOf M Φ σ z` over
the histories `σ` through the state at time `z` — time-independent by `cellAt_eq_cellAt`.

**The mechanism: branch-time saturation.** On a canonical history `histOf k t` at time `s`,
every member of `cl Φ` has a truth value that is a Boolean combination of `s < t`, `s = t`,
`t < s`, `s + 1 = t` — never of the thread index `k` (`truth_transfer`, a single `simp only`
over the enumerated closure; `truth_A'`/`truth_C'`/`truth_D` make the three `box` letters
global via `box_global` and `Φ_true`; `truth_stabFp`/`truth_stabPp`/`truth_stabNegPp`/
`truth_stabNegXp` read the four `⊡`-letters off the canonical-history toolkit). A closure type
is therefore determined by the relative position `t - s`, and only through its class in
`{<0}, {0}, {1}, {≥2}` (`SameClass`, `tpOf_eq_of`). Which canonical histories pass through
which state is `through_pre`/`through_post`/`through_x`. The cells, as SETS of the types they
realize: `pre 0 ↦ {tp 1}`, `pre (≥1) ↦ {tp 1, tp ≥2}`, `x ↦ {tp 0}`, `post ↦ {tp <0}`.

**The sharpening.** `⊡Xp ∉ cl Φ`. The closure's `⊡`-letter `⊡¬Xp` is FALSE at every pre
state (`truth_stabNegXp`: the history reaching the same state one step later reads `Xp`), so
all four `⊡`-letters of `cl Φ` take identical values at `pre 0` and `pre 1`. The cells differ
because `pre 1` additionally realizes the type with `Xp ∉ T` — the history through `pre 1`
that detours via `pre 0`. The separator between `pre 0` and `pre 1` is the non-`⊡` letter
`Xp`, through set membership of a second type; it is not a `⊡`-letter.

**Thread index at `post k 0`.** `postCell_subset` needs neither `1 ≤ j` nor `1 ≤ j'`: `post k 0`
and `post k j` realize the same single type. The dispatch's hypotheses on `postCell_stable`
are kept verbatim (statement fidelity) and are vacuous on `Node`.

**What this probe does NOT say.** (a) Cells are closure-indexed SETS over the time axis
(a 28-member closure, four realized types), never one bit per depth. (b) `Node` has infinite
width and the probe adds no finiteness: no `[Finite W]`, no finite-fibre retreat, no capped
ladder. (c) No bound of any kind is claimed — the probe exhibits cells; the "1" in
`preCell_stable`'s hypotheses is where THIS fixture's cells coincide, not a bound syntactic in
`φ` (a closure with a `⊡`-letter under a temporal operator, e.g. `F(⊡Xp)`, would separate
`pre 1` from `pre 2`, since only thread `0` passes through `pre 0`). (d) Zero debt: no external
Büchi/MSO lemma, no cslib require. (e) Forward-only: the fixture's witness is forward-looking;
nothing here bears on `⊡(Pp)`, and no claim is made that `⊡`-letters discriminate between
devices — on this fixture they do not even discriminate `pre 0` from `pre 1`. Also: nothing
about `HitPresented`, nothing about `PlusValidZTime` in any form, no model constructed, no
`Adm`, and nothing about the general ladder lemma or its bound.

Every headline theorem carries `[propext, Classical.choice, Quot.sound]`; `Classical.choice`
enters through `hist_canon` (via `FrameOver.mem_HF_iff_adjacent` and
`FrameOver.worldHistoryOfStepPath`), as the eighth and ninth probes already note for this
fixture.

Compile: `lake env lean specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean`
-/
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe758

/-! ## The box letters are global: `A'`, `C'`, `D` hold at every point of `M` (from `Φ_true`) -/

theorem truth_A' (σ : WorldHistory F) (s : ℤ) : PlusTruthAt M σ s A' := by
  have h := Φ_true
  simp only [Φ, PlusTruth.and_iff] at h
  have hA : PlusTruthAt M (histOf 0 0) 0 A' := h.1.1
  unfold A' at hA ⊢
  exact (box_global M _ σ 0 s _).mp hA

theorem truth_C' (σ : WorldHistory F) (s : ℤ) : PlusTruthAt M σ s C' := by
  have h := Φ_true
  simp only [Φ, PlusTruth.and_iff] at h
  have hC : PlusTruthAt M (histOf 0 0) 0 C' := h.1.2
  unfold C' at hC ⊢
  exact (box_global M _ σ 0 s _).mp hC

theorem truth_D (σ : WorldHistory F) (s : ℤ) : PlusTruthAt M σ s D := by
  have h := Φ_true
  simp only [Φ, PlusTruth.and_iff] at h
  have hD : PlusTruthAt M (histOf 0 0) 0 D := h.2
  unfold D at hD ⊢
  exact (box_global M _ σ 0 s _).mp hD

/-! ## The four `⊡`-letters of `cl Φ` on a canonical history -/

section Canon
variable {σ : WorldHistory F} {k : ℕ} {t : ℤ} (hσ : ∀ s, σ.state s = canon k t s)
include hσ

theorem truth_stabFp (s : ℤ) : PlusTruthAt M σ s (.stab Fp) ↔ s < t := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    exact (truth_Fp hσ s).mp (h σ rfl)
  · intro hlt σ' hσ'
    obtain ⟨k', t', hσ''⟩ := hist_canon σ'
    rw [truth_Fp hσ'']
    have := hσ s ▸ hσ'' s ▸ hσ'
    exact lt_of_canon_eq_of_lt this hlt

theorem truth_stabPp (s : ℤ) : PlusTruthAt M σ s (.stab Pp) ↔ t < s := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    exact (truth_Pp hσ s).mp (h σ rfl)
  · intro hgt σ' hσ'
    obtain ⟨k', t', hσ''⟩ := hist_canon σ'
    rw [truth_Pp hσ'']
    have := hσ s ▸ hσ'' s ▸ hσ'
    exact gt_of_canon_eq_of_gt this hgt

theorem truth_stabNegPp (s : ℤ) : PlusTruthAt M σ s (.stab Pp.neg) ↔ s ≤ t := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    have := h σ rfl
    rw [PlusTruth.neg_iff, truth_Pp hσ] at this
    omega
  · intro hle σ' hσ'
    obtain ⟨k', t', hσ''⟩ := hist_canon σ'
    rw [PlusTruth.neg_iff, truth_Pp hσ'']
    have hc := hσ s ▸ hσ'' s ▸ hσ'
    rcases hle.lt_or_eq with hlt | heq
    · have := lt_of_canon_eq_of_lt hc hlt; omega
    · have := eq_of_canon_eq_of_eq hc heq; omega

/-- `⊡¬Xp` fails at EVERY pre state: the history `histOf (k + (t-1-s).toNat) (s+1)` shares the
state and reads `Xp`. This is why `⊡¬Xp` does NOT separate `pre 0` from `pre 1`. -/
theorem truth_stabNegXp (s : ℤ) : PlusTruthAt M σ s (.stab Xp.neg) ↔ t ≤ s := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h
    by_contra hlt
    push Not at hlt
    have hst : σ.state s = (histOf (k + (t - 1 - s).toNat) (s + 1)).state s := by
      rw [hσ s, histOf_state, canon_of_lt hlt, canon_of_lt (by omega : s < s + 1)]
      congr 1
      omega
    have := h _ hst
    rw [PlusTruth.neg_iff, truth_Xp (fun s => histOf_state _ _ s)] at this
    exact this (by omega)
  · intro hle σ' hσ'
    obtain ⟨k', t', hσ''⟩ := hist_canon σ'
    rw [PlusTruth.neg_iff, truth_Xp hσ'']
    have hc := hσ s ▸ hσ'' s ▸ hσ'
    rcases hle.lt_or_eq with hlt | heq
    · have := gt_of_canon_eq_of_gt hc hlt; omega
    · have := eq_of_canon_eq_of_eq hc heq.symm; omega

end Canon

/-! ## The closure truth table depends only on the relative position `t - s`, never on `k` -/

/-- Two points `(histOf k t, s)` and `(histOf k' t', s')` are in the same class when their
relative positions agree, or both are `≥ 2` (pre, no `Xp`), or both are `< 0` (post). -/
def SameClass (s t s' t' : ℤ) : Prop :=
  t - s = t' - s' ∨ (2 ≤ t - s ∧ 2 ≤ t' - s') ∨ (t - s < 0 ∧ t' - s' < 0)

theorem truth_transfer {σ σ' : WorldHistory F} {k k' : ℕ} {t t' : ℤ}
    (hσ : ∀ s, σ.state s = canon k t s) (hσ' : ∀ s, σ'.state s = canon k' t' s) (s s' : ℤ)
    (h : SameClass s t s' t') :
    ∀ ψ ∈ plusSubformulaClosure Φ, (PlusTruthAt M σ s ψ ↔ PlusTruthAt M σ' s' ψ) := by
  unfold SameClass at h
  have hlt : s < t ↔ s' < t' := by constructor <;> intro <;> omega
  have heq : s = t ↔ s' = t' := by constructor <;> intro <;> omega
  have hgt : t < s ↔ t' < s' := by constructor <;> intro <;> omega
  have hle : s ≤ t ↔ s' ≤ t' := by constructor <;> intro <;> omega
  have hge : t ≤ s ↔ t' ≤ s' := by constructor <;> intro <;> omega
  have hX : s + 1 = t ↔ s' + 1 = t' := by constructor <;> intro <;> omega
  have hp := truth_p hσ s; have hp' := truth_p hσ' s'
  have hF := truth_Fp hσ s; have hF' := truth_Fp hσ' s'
  have hP := truth_Pp hσ s; have hP' := truth_Pp hσ' s'
  have hX1 := truth_Xp hσ s; have hX1' := truth_Xp hσ' s'
  have hsF := truth_stabFp hσ s; have hsF' := truth_stabFp hσ' s'
  have hsP := truth_stabPp hσ s; have hsP' := truth_stabPp hσ' s'
  have hsNP := truth_stabNegPp hσ s; have hsNP' := truth_stabNegPp hσ' s'
  have hsNX := truth_stabNegXp hσ s; have hsNX' := truth_stabNegXp hσ' s'
  have hA := truth_A' σ s; have hA' := truth_A' σ' s'
  have hC := truth_C' σ s; have hC' := truth_C' σ' s'
  have hD := truth_D σ s; have hD' := truth_D σ' s'
  simp only [p, Fp, Pp, Xp, PlusFormula.top] at hp hp' hF hF' hP hP' hX1 hX1'
  simp only [p, Fp, Pp, PlusFormula.top, PlusFormula.neg] at hsF hsF' hsP hsP' hsNP hsNP'
  simp only [p, Xp, PlusFormula.neg] at hsNX hsNX'
  simp only [A', p, Fp, Pp, PlusFormula.top, PlusFormula.neg, PlusFormula.or] at hA hA'
  simp only [C', p, Pp, PlusFormula.top, PlusFormula.neg] at hC hC'
  simp only [D, Fp, Xp, p, PlusFormula.top, PlusFormula.neg] at hD hD'
  simp only [plusSubformulaClosure, List.mem_toFinset, Φ, A', C', D, Fp, Pp, Xp, p,
    PlusFormula.and, PlusFormula.or, PlusFormula.neg, PlusFormula.top, PlusFormula.subformulas,
    List.mem_cons, List.mem_append, List.not_mem_nil, or_false, or_imp, forall_and, forall_eq,
    PlusTruth.imp_iff, PlusTruth.bot_false, hp, hp', hF, hF', hP, hP', hX1, hX1',
    hsF, hsF', hsP, hsP', hsNP, hsNP', hsNX, hsNX', hA, hA', hC, hC', hD, hD',
    hlt, heq, hgt, hle, hge, hX, iff_self, and_self]

theorem tpOf_eq_of {σ σ' : WorldHistory F} {k k' : ℕ} {t t' : ℤ}
    (hσ : ∀ s, σ.state s = canon k t s) (hσ' : ∀ s, σ'.state s = canon k' t' s) (s s' : ℤ)
    (h : SameClass s t s' t') : tpOf M Φ σ s = tpOf M Φ σ' s' := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  constructor
  · rintro ⟨hcl, hψ⟩
    exact ⟨hcl, (truth_transfer hσ hσ' s s' h ψ hcl).mp hψ⟩
  · rintro ⟨hcl, hψ⟩
    exact ⟨hcl, (truth_transfer hσ hσ' s s' h ψ hcl).mpr hψ⟩

/-! ## Which canonical histories pass through which state -/

theorem through_pre {σ : WorldHistory F} {m : ℕ} {z : ℤ} (h : σ.state z = .pre m) :
    ∃ (k₀ : ℕ) (t : ℤ), (∀ s, σ.state s = canon k₀ t s) ∧ z < t ∧ k₀ + (t - 1 - z).toNat = m := by
  obtain ⟨k₀, t, hσ⟩ := hist_canon σ
  refine ⟨k₀, t, hσ, ?_⟩
  rw [hσ z] at h
  rcases lt_trichotomy z t with hlt | heq | hgt
  · rw [canon_of_lt hlt] at h
    cases h
    exact ⟨hlt, rfl⟩
  · subst heq
    rw [canon_self] at h
    cases h
  · rw [canon_of_gt hgt] at h
    cases h

theorem through_post {σ : WorldHistory F} {m j : ℕ} {z : ℤ} (h : σ.state z = .post m j) :
    ∀ s, σ.state s = canon m (z - j - 1) s := by
  obtain ⟨k₀, t, hσ⟩ := hist_canon σ
  have h' := h
  rw [hσ z] at h'
  rcases lt_trichotomy z t with hlt | heq | hgt
  · rw [canon_of_lt hlt] at h'
    cases h'
  · subst heq
    rw [canon_self] at h'
    cases h'
  · rw [canon_of_gt hgt] at h'
    injection h' with hk hj
    subst hk
    have ht : t = z - j - 1 := by omega
    subst ht
    exact hσ

theorem through_x {σ : WorldHistory F} {m : ℕ} {z : ℤ} (h : σ.state z = .x m) :
    ∀ s, σ.state s = canon m z s := by
  obtain ⟨k₀, t, hσ⟩ := hist_canon σ
  have h' : canon k₀ t z = Node.x m := by rw [← hσ z]; exact h
  obtain ⟨rfl, rfl⟩ := canon_eq_x_iff.mp h'
  exact hσ

/-! ## The three dispatch statements, and the `x` bonus -/

theorem preCell_subset (k k' : ℕ) (hk' : 1 ≤ k') (z : ℤ) :
    cellAt M Φ (.pre k) z ⊆ cellAt M Φ (.pre k') z := by
  intro T hT
  obtain ⟨σ, hσz, rfl⟩ := (mem_cellAt_iff M Φ _ z T).mp hT
  obtain ⟨k₀, t, hσ, hlt, hm⟩ := through_pre hσz
  refine (mem_cellAt_iff M Φ _ z _).mpr ?_
  by_cases hX : z + 1 = t
  · refine ⟨histOf k' (z + 1), ?_, ?_⟩
    · rw [histOf_state, canon_of_lt (by omega : z < z + 1)]
      congr 1
      omega
    · exact (tpOf_eq_of hσ (fun s => histOf_state _ _ s) z z (by unfold SameClass; omega)).symm
  · refine ⟨histOf 0 (z + 1 + k'), ?_, ?_⟩
    · rw [histOf_state, canon_of_lt (by omega : z < z + 1 + k')]
      congr 1
      omega
    · exact (tpOf_eq_of hσ (fun s => histOf_state _ _ s) z z (by unfold SameClass; omega)).symm

theorem preCell_stable (k k' : ℕ) (hk : 1 ≤ k) (hk' : 1 ≤ k') (z : ℤ) :
    cellAt M Φ (.pre k) z = cellAt M Φ (.pre k') z :=
  Set.Subset.antisymm (preCell_subset k k' hk' z) (preCell_subset k' k hk z)

theorem preCell_zero_ne (z : ℤ) : cellAt M Φ (.pre 0) z ≠ cellAt M Φ (.pre 1) z := by
  intro h
  have hmem : tpOf M Φ (histOf 0 (z + 2)) z ∈ cellAt M Φ (.pre 1) z := by
    refine (mem_cellAt_iff M Φ _ z _).mpr ⟨_, ?_, rfl⟩
    rw [histOf_state, canon_of_lt (by omega : z < z + 2)]
    congr 1
    omega
  have hmem0 : tpOf M Φ (histOf 0 (z + 2)) z ∈ cellAt M Φ (.pre 0) z :=
    (Set.ext_iff.mp h _).mpr hmem
  obtain ⟨σ, hσz, hT⟩ := (mem_cellAt_iff M Φ _ z _).mp hmem0
  obtain ⟨k₀, t, hσ, hlt, hm⟩ := through_pre hσz
  have hXin : Xp ∈ tpOf M Φ σ z := by
    rw [mem_tpOf_iff]
    exact ⟨by decide, (truth_Xp hσ z).mpr (by omega)⟩
  rw [hT, mem_tpOf_iff] at hXin
  have := (truth_Xp (fun s => histOf_state 0 (z + 2) s) z).mp hXin.2
  omega

theorem postCell_subset (k k' j j' : ℕ) (z : ℤ) :
    cellAt M Φ (.post k j) z ⊆ cellAt M Φ (.post k' j') z := by
  intro T hT
  obtain ⟨σ, hσz, rfl⟩ := (mem_cellAt_iff M Φ _ z T).mp hT
  have hσ := through_post hσz
  refine (mem_cellAt_iff M Φ _ z _).mpr ⟨histOf k' (z - j' - 1), ?_, ?_⟩
  · rw [histOf_state, canon_of_gt (by omega : z - j' - 1 < z)]
    congr 1
    omega
  · exact (tpOf_eq_of hσ (fun s => histOf_state _ _ s) z z (by unfold SameClass; omega)).symm

set_option linter.unusedVariables false in
/-- Stated with the dispatch's `1 ≤ j`, `1 ≤ j'` hypotheses; on `Node` they are not needed
(`postCell_subset` has none), because `post k 0` and `post k j` realize the same single type. -/
theorem postCell_stable (k k' j j' : ℕ) (hj : 1 ≤ j) (hj' : 1 ≤ j') (z : ℤ) :
    cellAt M Φ (.post k j) z = cellAt M Φ (.post k' j') z :=
  Set.Subset.antisymm (postCell_subset k k' j j' z) (postCell_subset k' k j' j z)

theorem xCell_stable (k k' : ℕ) (z : ℤ) : cellAt M Φ (.x k) z = cellAt M Φ (.x k') z := by
  ext T
  constructor <;> intro hT
  · obtain ⟨σ, hσz, rfl⟩ := (mem_cellAt_iff M Φ _ z T).mp hT
    exact (mem_cellAt_iff M Φ _ z _).mpr ⟨histOf k' z, by rw [histOf_state, canon_self],
      (tpOf_eq_of (through_x hσz) (fun s => histOf_state _ _ s) z z
        (by unfold SameClass; omega)).symm⟩
  · obtain ⟨σ, hσz, rfl⟩ := (mem_cellAt_iff M Φ _ z T).mp hT
    exact (mem_cellAt_iff M Φ _ z _).mpr ⟨histOf k z, by rw [histOf_state, canon_self],
      (tpOf_eq_of (through_x hσz) (fun s => histOf_state _ _ s) z z
        (by unfold SameClass; omega)).symm⟩

end Probe758

#print axioms Probe758.preCell_stable
#print axioms Probe758.preCell_zero_ne
#print axioms Probe758.postCell_stable
#print axioms Probe758.xCell_stable
