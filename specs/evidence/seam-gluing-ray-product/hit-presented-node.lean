/-
Probe 759 (requirement (C)'s Hit-level hypothesis on a ⊡-bearing alphabet at an infinite-width
seam, on the one-region fixture): **POSITIVE — `HitPresented` holds at every pre-seam
`(t, pre m)` of `NoFiniteWidth.M` for the fixture's witness `Φ` at every depth `k ≥ 1`, with the
presentation size `windowN m k + 5` EXHIBITED as a count, uniform over every seam index.**

**Formula.** The dispatch's order was `Φ' := Φ` (the fixture witness), fallback `D`, then `⊡Xp`
— recorded in that order. `Φ` is chosen and is written into every statement below. `cl Φ` has 28
members (`#guard (plusSubformulaClosure Φ).card = 28`, re-derived on every compile) and carries
all four `⊡`-letters of the fixture: `⊡Fp`, `⊡Pp`, `⊡¬Pp`, `⊡¬Xp`. Neither fallback was needed.

**Which headline.** Positive: `hitPresented_node`. The negative headline `not_hitPresented_node`
is FALSE on `Node` at every seam for every `Φ'`: the seam fibre is finite — `through_pre` shows
exactly `m + 1` histories pass through `(t, pre m)`, the canonical `histOf (m - i) (t + 1 + i)` for
`i ≤ m` — so trace-level `Presented` already holds at window `m` (`presented_node`, the
by-product), and the library's `hitPresented_of_presented` would then give `HitPresented` at once.
No Stage 0 ruling arises from this probe. Nothing here bears on `Probe735.not_presented`, whose
fixture (model A) has an infinite seam fibre; `Node` does not separate `Presented` from
`HitPresented`, and model A remains the only separation in the tree.

**The fixture.** `NoFiniteWidth.M` on `F` (`PlusSlicedCertificate/Limits/NoFiniteWidth.lean`, a
library module, imported — regular by `F_isRegular`; every history canonical by `hist_canon`).
The probe cites `histOf`, `histOf_state`, `canon_of_lt`/`canon_self`/`canon_of_gt`,
`truth_p`/`truth_Fp`/`truth_Pp`/`truth_Xp`, `Φ_true`, `box_global`, `seamOmegaEquiv`,
`spliced`, `hitCl_eq_iUnion`, `mem_hitOf_iff`,
`kTypeOf_listSeg_replicate_eventually_periodic_bounded`, `familyTriples_subset_deleteRun` and
`segZ_const_of_kTypeOf_eq_replicate`, and re-proves none of them. `Probe758`'s closure-truth
lemmas (`truth_A'`, `truth_C'`, `truth_D`, `truth_stab*`) are transcribed, never imported, as this
collection's convention requires. No lemma is added under `FormalSystem/`.

**The argument, in three sentences.** Seam classification: every history through `(t, pre m)` is
one of the `m + 1` canonical histories `histOf (m - i) (t + 1 + i)`, `i ≤ m`, so `HitCl` at the
seam is their finite union (`hitCl_pre`), for a GENERAL `τ` with `τ.state t = .pre m`. Four letter
classes: on a canonical history every closure letter at time `s` depends only on the class of the
relative position `t' - s` in `{≥ 2, 1, 0, < 0}` (`clTrace_canon_apply`), so the `i`-th trace is
`ℓ₂^(ω*)·[ℓ₂ + now]·ℓ₂^(i-1)·ℓ₁·ℓ₀·ℓₙ^ω` (and `ℓ₂^(ω*)·[ℓ₁ + now]·ℓ₀·ℓₙ^ω` at `i = 0`) — the
constant `ℓ₂`-run on `[t + 1, t + i)` is model A's `a`-run, and its containment in the middle
segment of every factorization (`run_subset_middle`) is a fixture fact, as on model A; the
library's periodicity theorem and `familyTriples_subset_deleteRun` then shrink the run by `p` at a
time until the history index lies in the window `windowN m k = min m (W + 1)`,
`W := Nat.card (KType (clSig Φ) k)` (`hitCl_eq_truncated_node`). Finally a one-gadget presentation
`labN`/`stepN` on `Fin (windowN m k + 5)` whose anchored runs trace exactly `{c_i : i ≤ windowN m k}`
closes the headline through `mem_hitOf_iff`.

**Bound verdict: EXHIBITED, as a count, uniform in `m`.** `windowN m k = min m (W + 1)` is written
into the statement; `card_QN` reads `Fintype.card (QN L) = L + 5` and `card_QN_le` reads
`Fintype.card (QN (windowN m k)) ≤ Nat.card (KType (clSig Φ) k) + 6` at EVERY pre-seam. In
`AnchorLayer.lean`'s words on its own cell count, binding here with "depth-`k` types" for "cells":
"The one bound (W) can state honestly: a cardinality bound on the SET OF CELLS of a model,
syntactic in `|cl φ|` — a cell is a set of subsets of `cl φ`, so there are at most `2 ^ (2 ^ |cl φ|)`
of them. It is not a complexity bound of any kind: it counts cells, it does not time anything, and
it must not be described as a bound on any procedure's running time." `windowN` counts depth-`k`
types and seam indices, times nothing, bounds no procedure, is not a complexity bound of any kind,
and no minimality is claimed for it; `k` is free.

**What `Node` does and does NOT test.** This is the first `HitPresented` positive on a ⊡-bearing
alphabet and on an infinite-width model (the only previous Hit-level positive,
`Probe745.hitPresented_modelA`, is box/stab-free on a `Fin 3` slice). But `Node`'s seam fibres are
FINITE, so this probe does NOT test the truncation argument's necessity — model A, with infinitely
many splices through `(t, a)`, did; a future Hit-level falsifier for (C) needs a seam with
infinitely many histories through it. The truncation here buys the uniform count `card_QN_le`, not
satisfiability (which `presented_node` already has at window `m`).

**Guardrails (a)–(e).** (a) The alphabet is `clSig Φ`, 28 closure letters plus the marker `now`,
closure-indexed. (b) `Node` has infinite width and the probe adds no finiteness: no `[Finite W]`,
no finite-fibre hypothesis — the finiteness USED (`through_pre`) is a property of this fixture's
states, proved, not assumed. (c) `windowN`, `card_QN`, `card_QN_le` count states and depth-`k`
types, never a running time, and the statement carries no `∃ L`. (d) Zero debt: no automata
library, no Büchi/MSO citation, no cslib require, no sorry, axiom or vacuous definition. (e)
Forward-only: the `Pp`/`⊡Pp`/`⊡¬Pp` letters of `cl Φ` are read off canonical histories as closure
DATA; nothing here is a backward Bool-fixture bridge or bears on deciding `⊡(Pp)`, and `⊡`-letters
are not claimed to discriminate between devices. One fixture, every pre-seam; nothing about
general regular `ℤ`-models or `PlusValidZTime`.

**What `hitPresented_node` does NOT say** — the full list is the section of that name at the
headline itself; read it before citing this file. (Finalized with the headline.)

**Axiom record** — as OBSERVED from the `#print axioms` foot, recorded with the headline.

**Compile line.**
`lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
— or, as the guard runs it, `bash scripts/check-evidence-probes.sh`, whose `WIRED` list carries
`seam-gluing-ray-product/hit-presented-node`. This file sits outside the Lake build graph, so
`lake build` never compiles it; the guard is what keeps it from rotting.
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth
open FormalSystem.Metalogic.Decidability.RaySummary
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness

namespace Probe759

-- The closure figure, re-derived on every compile (a `#guard` failure is a compile error).
#guard (plusSubformulaClosure Φ).card = 28

/-! ## Which histories pass through the pre-seam

Every history of `F` is canonical (`hist_canon`), and `canon k' t' s = .pre m` forces `s < t'` and
`k' + (t' - 1 - s).toNat = m`. So the histories through `(t, pre m)` are exactly the `m + 1`
canonical histories `histOf (m - i) (t + 1 + i)` for `i ≤ m`: the `x`-time `t' = t + 1 + i` is
`i + 1` steps ahead of the seam and the thread index `m - i` makes up the pre-index. This is the
finiteness of the seam fibre — proved of the fixture, not assumed. -/

/-- The canonical history `histOf m (t + 1)` sits at `pre m` at time `t`. -/
theorem seam_state (m : ℕ) (t : ℤ) : (histOf m (t + 1)).state t = .pre m := by
  rw [histOf_state, canon_of_lt (by omega : t < t + 1)]
  congr 1
  omega

/-- **Seam classification.** Every history through `(z, pre m)` is `histOf (m - i) (z + 1 + i)`
for some `i ≤ m`, stated as a pointwise equation of states with `canon`. -/
theorem through_pre {σ : WorldHistory F} {m : ℕ} {z : ℤ} (h : σ.state z = .pre m) :
    ∃ i : ℕ, i ≤ m ∧ ∀ s, σ.state s = canon (m - i) (z + 1 + i) s := by
  obtain ⟨k₀, t, hσ⟩ := hist_canon σ
  rw [hσ z] at h
  rcases lt_trichotomy z t with hlt | heq | hgt
  · rw [canon_of_lt hlt] at h
    cases h
    refine ⟨(t - 1 - z).toNat, by omega, ?_⟩
    have e1 : k₀ + (t - 1 - z).toNat - (t - 1 - z).toNat = k₀ := by omega
    have e2 : z + 1 + (((t - 1 - z).toNat : ℕ) : ℤ) = t := by omega
    rw [e1, e2]
    exact hσ
  · subst heq
    rw [canon_self] at h
    cases h
  · rw [canon_of_gt hgt] at h
    cases h

/-- Conversely each `histOf (m - i) (t + 1 + i)`, `i ≤ m`, passes through `(t, pre m)`. -/
theorem canon_through (m i : ℕ) (hi : i ≤ m) (t : ℤ) :
    (histOf (m - i) (t + 1 + i)).state t = .pre m := by
  rw [histOf_state, canon_of_lt (by omega)]
  congr 1
  omega

/-! ## `HitCl` depends on the seam only through its state

`hitCl_eq_iUnion` presents `HitCl M τ t Φ k` as a union over the seam's ray pairs
`SeqPair F (τ.state t)`, each spliced to a history through `(t, τ.state t)`. The splice map is a
bijection onto those histories (`seamOmegaEquiv`), so the union can be re-indexed by the histories
themselves (`hitCl_eq_through`) — and then, at a pre-seam, by the finite index set of
`through_pre` (`hitCl_pre`). The seam history `τ` enters only through `τ.state t`, which is why the
headline's primary binder is a GENERAL `τ` with `hτ : τ.state t = .pre m`. -/

/-- A splice passes through the seam. -/
theorem spliced_state (τ : WorldHistory F) (t : ℤ) (bf : SeqPair F (τ.state t)) :
    (spliced τ t bf).state t = τ.state t :=
  ((seamOmegaEquiv t (τ.state t)).symm bf).2

/-- Every history through the seam is a splice (`seamOmegaEquiv`'s `symm_apply_apply`). -/
theorem exists_splice_eq (τ : WorldHistory F) (t : ℤ) (σ : WorldHistory F)
    (h : σ.state t = τ.state t) : ∃ bf : SeqPair F (τ.state t), spliced τ t bf = σ := by
  refine ⟨seamOmegaEquiv t (τ.state t) ⟨σ, h⟩, ?_⟩
  exact congrArg Subtype.val ((seamOmegaEquiv t (τ.state t)).symm_apply_apply ⟨σ, h⟩)

/-- `HitCl` at `(τ, t)` is the union of the family triples of the closure traces of the histories
through the seam state `τ.state t`. -/
theorem hitCl_eq_through (τ : WorldHistory F) (t : ℤ) (k : ℕ) :
    HitCl M τ t Φ k
      = ⋃ σ ∈ {σ : WorldHistory F | σ.state t = τ.state t},
          familyTriples (clSig Φ) k (clTrace M Φ t σ) := by
  ext x
  rw [hitCl_eq_iUnion]
  simp only [Set.mem_iUnion, Set.mem_setOf_eq]
  constructor
  · rintro ⟨bf, hx⟩
    exact ⟨spliced τ t bf, spliced_state τ t bf, hx⟩
  · rintro ⟨σ, hσ, hx⟩
    obtain ⟨bf, hbf⟩ := exists_splice_eq τ t σ hσ
    exact ⟨bf, by rw [hbf]; exact hx⟩

/-- **`HitCl` at a pre-seam is a finite union**: for any `τ` with `τ.state t = .pre m`, the family
triples realized at the seam are those of the `m + 1` canonical histories through `(t, pre m)`. -/
theorem hitCl_pre (τ : WorldHistory F) (t : ℤ) (m k : ℕ) (hτ : τ.state t = .pre m) :
    HitCl M τ t Φ k
      = ⋃ i ∈ Finset.range (m + 1),
          familyTriples (clSig Φ) k (clTrace M Φ t (histOf (m - i) (t + 1 + i))) := by
  rw [hitCl_eq_through]
  ext x
  simp only [Set.mem_iUnion, Set.mem_setOf_eq, Finset.mem_range]
  constructor
  · rintro ⟨σ, hσ, hx⟩
    rw [hτ] at hσ
    obtain ⟨i, hi, hσ'⟩ := through_pre hσ
    refine ⟨i, by omega, ?_⟩
    have heq : σ = histOf (m - i) (t + 1 + i) :=
      WorldHistory.ext_state fun s => by rw [hσ' s, histOf_state]
    rw [heq] at hx
    exact hx
  · rintro ⟨i, hi, hx⟩
    exact ⟨histOf (m - i) (t + 1 + i), by rw [canon_through m i (by omega), hτ], hx⟩


/-! ## The closure letters on a canonical history (transcribed)

Transcribed from `node-cell-stabilization.lean` (`Probe758`), names kept, as this collection's
convention requires (a probe imports library modules only, never another probe). The three `box`
letters `A'`, `C'`, `D` are global by `box_global` from `Φ_true`; the four `⊡`-letters of `cl Φ`
are read off the canonical-history toolkit: on `σ` with `σ.state s = canon k t s` for all `s`,
`⊡Fp ↔ s < t`, `⊡Pp ↔ t < s`, `⊡¬Pp ↔ s ≤ t`, `⊡¬Xp ↔ t ≤ s`. The last is the sharpening
`Probe758` recorded: `⊡¬Xp` FAILS at every pre state, because the history reaching the same pre
state one step later reads `Xp`. -/

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
state and reads `Xp`. -/
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

/-! ## The four letter classes

On a canonical history `histOf k' t'` at time `s`, every member of `cl Φ` has a truth value that is
a Boolean combination of `s < t'`, `s = t'`, `t' < s`, `s + 1 = t'` — never of the thread index
`k'` — so it depends only on the class of `d := t' - s` in `{≥ 2, 1, 0, < 0}`. The primitives'
truth table, in that column order (from `truth_p`/`truth_Fp`/`truth_Pp`/`truth_Xp` and the four
`truth_stab*` above): `p`: F F T F; `Fp`: T T F F; `Pp`: F F F T; `Xp`: F T F F; `⊡Fp`: T T F F;
`⊡Pp`: F F F T; `⊡¬Pp`: T T T F; `⊡¬Xp`: F F T T; `A'`, `C'`, `D`, `⊤`: T T T T; `⊥`: F F F F;
the 15 composite members by their connectives (`¬a := a → ⊥`, `a ∨ b := ¬a → b`,
`a ∧ b := ¬(a → ¬b)`). The four lists below are the members TRUE in each class; a hand error in
them is a compile failure of the class lemmas in the next section (which are proved against the
real semantics), never a silent defect. The vectors `ℓ₂ ℓ₁ ℓ₀ ℓₙ` are computable
(`decide` of list membership, as the prototype's `ℓtest`), which is what lets `labN` below be a
`def`. -/

/-- Closure members true at relative position `d ≥ 2` (deep inside the pre-run). -/
def T₂ : List PlusFormula :=
  [Φ, A'.and C', A', p.or ((PlusFormula.stab Fp).or (PlusFormula.stab Pp)), p.neg,
   (PlusFormula.stab Fp).or (PlusFormula.stab Pp), PlusFormula.stab Fp, Fp, PlusFormula.top,
   C', p.imp (PlusFormula.stab Pp.neg), PlusFormula.stab Pp.neg, Pp.neg, D,
   (PlusFormula.stab Fp).imp (PlusFormula.stab Xp.neg).neg, (PlusFormula.stab Xp.neg).neg,
   Xp.neg]

/-- Closure members true at relative position `d = 1` (the last pre state, reading `Xp`). -/
def T₁ : List PlusFormula :=
  [Φ, A'.and C', A', p.or ((PlusFormula.stab Fp).or (PlusFormula.stab Pp)), p.neg,
   (PlusFormula.stab Fp).or (PlusFormula.stab Pp), PlusFormula.stab Fp, Fp, PlusFormula.top,
   C', p.imp (PlusFormula.stab Pp.neg), PlusFormula.stab Pp.neg, Pp.neg, D,
   (PlusFormula.stab Fp).imp (PlusFormula.stab Xp.neg).neg, (PlusFormula.stab Xp.neg).neg,
   Xp]

/-- Closure members true at relative position `d = 0` (the `x` state, reading `p`). -/
def T₀ : List PlusFormula :=
  [Φ, A'.and C', A', p.or ((PlusFormula.stab Fp).or (PlusFormula.stab Pp)), p,
   (PlusFormula.stab Fp).neg, PlusFormula.top,
   C', p.imp (PlusFormula.stab Pp.neg), PlusFormula.stab Pp.neg, Pp.neg, D,
   (PlusFormula.stab Fp).imp (PlusFormula.stab Xp.neg).neg, PlusFormula.stab Xp.neg,
   Xp.neg]

/-- Closure members true at relative position `d < 0` (the post states). -/
def Tₙ : List PlusFormula :=
  [Φ, A'.and C', A', p.or ((PlusFormula.stab Fp).or (PlusFormula.stab Pp)), p.neg,
   (PlusFormula.stab Fp).or (PlusFormula.stab Pp), (PlusFormula.stab Fp).neg, PlusFormula.top,
   PlusFormula.stab Pp, Pp,
   C', p.imp (PlusFormula.stab Pp.neg), D,
   (PlusFormula.stab Fp).imp (PlusFormula.stab Xp.neg).neg, PlusFormula.stab Xp.neg,
   Xp.neg]

/-- The letter vector of class `d ≥ 2`; `now` is never part of a letter vector. -/
def ℓ₂ : (clSig Φ).preds → Bool
  | .inl ψ => decide (ψ.1 ∈ T₂)
  | .inr () => false

/-- The letter vector of class `d = 1`. -/
def ℓ₁ : (clSig Φ).preds → Bool
  | .inl ψ => decide (ψ.1 ∈ T₁)
  | .inr () => false

/-- The letter vector of class `d = 0`. -/
def ℓ₀ : (clSig Φ).preds → Bool
  | .inl ψ => decide (ψ.1 ∈ T₀)
  | .inr () => false

/-- The letter vector of class `d < 0`. -/
def ℓₙ : (clSig Φ).preds → Bool
  | .inl ψ => decide (ψ.1 ∈ Tₙ)
  | .inr () => false

/-- The letter read at relative position `d`, by class. -/
def letterAt (d : ℤ) : (clSig Φ).preds → Bool :=
  if 2 ≤ d then ℓ₂ else if d = 1 then ℓ₁ else if d = 0 then ℓ₀ else ℓₙ

theorem letterAt_now (d : ℤ) : letterAt d (clNow Φ) = false := by
  unfold letterAt
  split_ifs <;> rfl

theorem ℓ₂_now : ℓ₂ (clNow Φ) = false := rfl
theorem ℓ₁_now : ℓ₁ (clNow Φ) = false := rfl
theorem ℓ₀_now : ℓ₀ (clNow Φ) = false := rfl
theorem ℓₙ_now : ℓₙ (clNow Φ) = false := rfl

/-! The discriminating letters and their entries: `Fp` separates `ℓ₂` from `ℓₙ` (the containment
argument), `Xp` separates `ℓ₂` from `ℓ₁`, and `p` separates `ℓ₀` from `ℓ₁` and `ℓₙ`. -/

theorem cl_Fp : Fp ∈ plusSubformulaClosure Φ := by decide
theorem cl_Xp : Xp ∈ plusSubformulaClosure Φ := by decide
theorem cl_p : p ∈ plusSubformulaClosure Φ := by decide
theorem cl_Pp : Pp ∈ plusSubformulaClosure Φ := by decide

theorem ℓ₂_Fp : ℓ₂ (clLetter Φ cl_Fp) = true := by decide
theorem ℓₙ_Fp : ℓₙ (clLetter Φ cl_Fp) = false := by decide
theorem ℓ₂_Xp : ℓ₂ (clLetter Φ cl_Xp) = false := by decide
theorem ℓ₁_Xp : ℓ₁ (clLetter Φ cl_Xp) = true := by decide
theorem ℓ₀_p : ℓ₀ (clLetter Φ cl_p) = true := by decide
theorem ℓ₁_p : ℓ₁ (clLetter Φ cl_p) = false := by decide
theorem ℓₙ_p : ℓₙ (clLetter Φ cl_p) = false := by decide

theorem now_ne_Fp : clNow Φ ≠ clLetter Φ cl_Fp := clNow_ne_clLetter Φ cl_Fp
theorem now_ne_Xp : clNow Φ ≠ clLetter Φ cl_Xp := clNow_ne_clLetter Φ cl_Xp
theorem now_ne_p : clNow Φ ≠ clLetter Φ cl_p := clNow_ne_clLetter Φ cl_p
theorem now_ne_Pp : clNow Φ ≠ clLetter Φ cl_Pp := clNow_ne_clLetter Φ cl_Pp


/-! ## The letter bridge: the closure trace of a canonical history is `letterAt` plus `now`

The four class lemmas below settle every closure letter on a canonical history by its class, each
by ONE `simp only` over the enumerated 28-member closure — `truth_transfer`'s skeleton from
`node-cell-stabilization.lean`, with the relative-position facts of the class in place of the
`SameClass` transfer and `decide` evaluating membership in the class's list. A wrong entry in
`T₂`/`T₁`/`T₀`/`Tₙ` fails here, against the real semantics. `clTrace_canon_apply` then reads the
whole trace off `letterAt`: the `now` bit at `z = t`, and otherwise the class of `t' - z`. Nothing
here evaluates a `kTypeOf`. -/

section Classes
variable {σ : WorldHistory F} {k' : ℕ} {t' : ℤ} (hσ : ∀ s, σ.state s = canon k' t' s)
include hσ

theorem truth_class₂ (s : ℤ) (hd : 2 ≤ t' - s) :
    ∀ ψ ∈ plusSubformulaClosure Φ, (PlusTruthAt M σ s ψ ↔ ψ ∈ T₂) := by
  have hlt : s < t' := by omega
  have hne : ¬ s = t' := by omega
  have hgt : ¬ t' < s := by omega
  have hle : s ≤ t' := by omega
  have hge : ¬ t' ≤ s := by omega
  have hX : ¬ s + 1 = t' := by omega
  have hp := truth_p hσ s; have hF := truth_Fp hσ s; have hP := truth_Pp hσ s
  have hX1 := truth_Xp hσ s
  have hsF := truth_stabFp hσ s; have hsP := truth_stabPp hσ s
  have hsNP := truth_stabNegPp hσ s; have hsNX := truth_stabNegXp hσ s
  have hA := truth_A' σ s; have hC := truth_C' σ s; have hD := truth_D σ s
  simp only [p, Fp, Pp, Xp, PlusFormula.top] at hp hF hP hX1
  simp only [p, Fp, Pp, PlusFormula.top, PlusFormula.neg] at hsF hsP hsNP
  simp only [p, Xp, PlusFormula.neg] at hsNX
  simp only [A', p, Fp, Pp, PlusFormula.top, PlusFormula.neg, PlusFormula.or] at hA
  simp only [C', p, Pp, PlusFormula.top, PlusFormula.neg] at hC
  simp only [D, Fp, Xp, p, PlusFormula.top, PlusFormula.neg] at hD
  simp +decide only [plusSubformulaClosure, List.mem_toFinset, Φ, A', C', D, Fp, Pp, Xp, p,
    PlusFormula.and, PlusFormula.or, PlusFormula.neg, PlusFormula.top, PlusFormula.subformulas,
    List.mem_cons, List.mem_append, List.not_mem_nil, or_false, or_imp, forall_and, forall_eq,
    PlusTruth.imp_iff, PlusTruth.bot_false, hp, hF, hP, hX1, hsF, hsP, hsNP, hsNX, hA, hC, hD,
    hlt, hne, hgt, hle, hge, hX, iff_self, and_self, imp_self, true_implies, implies_true]

theorem truth_class₁ (s : ℤ) (hd : t' - s = 1) :
    ∀ ψ ∈ plusSubformulaClosure Φ, (PlusTruthAt M σ s ψ ↔ ψ ∈ T₁) := by
  have hlt : s < t' := by omega
  have hne : ¬ s = t' := by omega
  have hgt : ¬ t' < s := by omega
  have hle : s ≤ t' := by omega
  have hge : ¬ t' ≤ s := by omega
  have hX : s + 1 = t' := by omega
  have hp := truth_p hσ s; have hF := truth_Fp hσ s; have hP := truth_Pp hσ s
  have hX1 := truth_Xp hσ s
  have hsF := truth_stabFp hσ s; have hsP := truth_stabPp hσ s
  have hsNP := truth_stabNegPp hσ s; have hsNX := truth_stabNegXp hσ s
  have hA := truth_A' σ s; have hC := truth_C' σ s; have hD := truth_D σ s
  simp only [p, Fp, Pp, Xp, PlusFormula.top] at hp hF hP hX1
  simp only [p, Fp, Pp, PlusFormula.top, PlusFormula.neg] at hsF hsP hsNP
  simp only [p, Xp, PlusFormula.neg] at hsNX
  simp only [A', p, Fp, Pp, PlusFormula.top, PlusFormula.neg, PlusFormula.or] at hA
  simp only [C', p, Pp, PlusFormula.top, PlusFormula.neg] at hC
  simp only [D, Fp, Xp, p, PlusFormula.top, PlusFormula.neg] at hD
  simp +decide only [plusSubformulaClosure, List.mem_toFinset, Φ, A', C', D, Fp, Pp, Xp, p,
    PlusFormula.and, PlusFormula.or, PlusFormula.neg, PlusFormula.top, PlusFormula.subformulas,
    List.mem_cons, List.mem_append, List.not_mem_nil, or_false, or_imp, forall_and, forall_eq,
    PlusTruth.imp_iff, PlusTruth.bot_false, hp, hF, hP, hX1, hsF, hsP, hsNP, hsNX, hA, hC, hD,
    hlt, hne, hgt, hle, hge, hX, iff_self, and_self, imp_self, true_implies, implies_true]

theorem truth_class₀ (s : ℤ) (hd : t' - s = 0) :
    ∀ ψ ∈ plusSubformulaClosure Φ, (PlusTruthAt M σ s ψ ↔ ψ ∈ T₀) := by
  obtain rfl : s = t' := by omega
  have hlt : ¬ s < s := lt_irrefl s
  have hle : s ≤ s := le_refl s
  have hX : ¬ s + 1 = s := by omega
  have hp := truth_p hσ s; have hF := truth_Fp hσ s; have hP := truth_Pp hσ s
  have hX1 := truth_Xp hσ s
  have hsF := truth_stabFp hσ s; have hsP := truth_stabPp hσ s
  have hsNP := truth_stabNegPp hσ s; have hsNX := truth_stabNegXp hσ s
  have hA := truth_A' σ s; have hC := truth_C' σ s; have hD := truth_D σ s
  simp only [p, Fp, Pp, Xp, PlusFormula.top] at hp hF hP hX1
  simp only [p, Fp, Pp, PlusFormula.top, PlusFormula.neg] at hsF hsP hsNP
  simp only [p, Xp, PlusFormula.neg] at hsNX
  simp only [A', p, Fp, Pp, PlusFormula.top, PlusFormula.neg, PlusFormula.or] at hA
  simp only [C', p, Pp, PlusFormula.top, PlusFormula.neg] at hC
  simp only [D, Fp, Xp, p, PlusFormula.top, PlusFormula.neg] at hD
  simp +decide only [plusSubformulaClosure, List.mem_toFinset, Φ, A', C', D, Fp, Pp, Xp, p,
    PlusFormula.and, PlusFormula.or, PlusFormula.neg, PlusFormula.top, PlusFormula.subformulas,
    List.mem_cons, List.mem_append, List.not_mem_nil, or_false, or_imp, forall_and, forall_eq,
    PlusTruth.imp_iff, PlusTruth.bot_false, hp, hF, hP, hX1, hsF, hsP, hsNP, hsNX, hA, hC, hD,
    hlt, hle, hX, iff_self, and_self, imp_self, true_implies]

theorem truth_classₙ (s : ℤ) (hd : t' - s < 0) :
    ∀ ψ ∈ plusSubformulaClosure Φ, (PlusTruthAt M σ s ψ ↔ ψ ∈ Tₙ) := by
  have hlt : ¬ s < t' := by omega
  have hne : ¬ s = t' := by omega
  have hgt : t' < s := by omega
  have hle : ¬ s ≤ t' := by omega
  have hge : t' ≤ s := by omega
  have hX : ¬ s + 1 = t' := by omega
  have hp := truth_p hσ s; have hF := truth_Fp hσ s; have hP := truth_Pp hσ s
  have hX1 := truth_Xp hσ s
  have hsF := truth_stabFp hσ s; have hsP := truth_stabPp hσ s
  have hsNP := truth_stabNegPp hσ s; have hsNX := truth_stabNegXp hσ s
  have hA := truth_A' σ s; have hC := truth_C' σ s; have hD := truth_D σ s
  simp only [p, Fp, Pp, Xp, PlusFormula.top] at hp hF hP hX1
  simp only [p, Fp, Pp, PlusFormula.top, PlusFormula.neg] at hsF hsP hsNP
  simp only [p, Xp, PlusFormula.neg] at hsNX
  simp only [A', p, Fp, Pp, PlusFormula.top, PlusFormula.neg, PlusFormula.or] at hA
  simp only [C', p, Pp, PlusFormula.top, PlusFormula.neg] at hC
  simp only [D, Fp, Xp, p, PlusFormula.top, PlusFormula.neg] at hD
  simp +decide only [plusSubformulaClosure, List.mem_toFinset, Φ, A', C', D, Fp, Pp, Xp, p,
    PlusFormula.and, PlusFormula.or, PlusFormula.neg, PlusFormula.top, PlusFormula.subformulas,
    List.mem_cons, List.mem_append, List.not_mem_nil, or_false, or_imp, forall_and, forall_eq,
    PlusTruth.imp_iff, PlusTruth.bot_false, hp, hF, hP, hX1, hsF, hsP, hsNP, hsNX, hA, hC, hD,
    hlt, hne, hgt, hle, hge, hX, iff_self, and_self, imp_self, true_implies]

end Classes

/-! The class selectors of `letterAt`, so that every positional read-out is an `omega` side
condition followed by a rewrite. -/

theorem letterAt_of_two_le {d : ℤ} (h : 2 ≤ d) : letterAt d = ℓ₂ := by
  unfold letterAt; rw [if_pos h]
theorem letterAt_of_eq_one {d : ℤ} (h : d = 1) : letterAt d = ℓ₁ := by
  unfold letterAt; rw [if_neg (by omega), if_pos h]
theorem letterAt_of_eq_zero {d : ℤ} (h : d = 0) : letterAt d = ℓ₀ := by
  unfold letterAt; rw [if_neg (by omega), if_neg (by omega), if_pos h]
theorem letterAt_of_neg {d : ℤ} (h : d < 0) : letterAt d = ℓₙ := by
  unfold letterAt; rw [if_neg (by omega), if_neg (by omega), if_neg (by omega)]

/-- **The alphabet, exhausted**: every letter of `clSig Φ` is the marker or a closure letter, with
the membership proof delivered at the type `clLetter` expects. -/
theorem letter_cases (ℓ : (clSig Φ).preds) :
    ℓ = clNow Φ ∨ ∃ (ψ : PlusFormula) (hψ : ψ ∈ plusSubformulaClosure Φ), ℓ = clLetter Φ hψ := by
  rcases ℓ with ⟨ψ, hψ⟩ | ⟨⟩
  · exact Or.inr ⟨ψ, hψ, rfl⟩
  · exact Or.inl rfl

/-! The vectors on a closure letter are list membership, decided. -/

theorem ℓ₂_letter {ψ : PlusFormula} (hψ : ψ ∈ plusSubformulaClosure Φ) :
    ℓ₂ (clLetter Φ hψ) = true ↔ ψ ∈ T₂ := decide_eq_true_iff
theorem ℓ₁_letter {ψ : PlusFormula} (hψ : ψ ∈ plusSubformulaClosure Φ) :
    ℓ₁ (clLetter Φ hψ) = true ↔ ψ ∈ T₁ := decide_eq_true_iff
theorem ℓ₀_letter {ψ : PlusFormula} (hψ : ψ ∈ plusSubformulaClosure Φ) :
    ℓ₀ (clLetter Φ hψ) = true ↔ ψ ∈ T₀ := decide_eq_true_iff
theorem ℓₙ_letter {ψ : PlusFormula} (hψ : ψ ∈ plusSubformulaClosure Φ) :
    ℓₙ (clLetter Φ hψ) = true ↔ ψ ∈ Tₙ := decide_eq_true_iff

/-- **The letter bridge.** The closure trace of the canonical history `histOf k' t'`, anchored at
`t`, reads the marker exactly at `z = t` and otherwise the class letter of `t' - z`. The thread
index `k'` does not appear on the right-hand side. -/
theorem clTrace_canon_apply (k' : ℕ) (t t' : ℤ) (ℓ : (clSig Φ).preds) (z : ℤ) :
    clTrace M Φ t (histOf k' t') ℓ z ↔ (ℓ = clNow Φ ∧ z = t) ∨ letterAt (t' - z) ℓ = true := by
  have hσ : ∀ s, (histOf k' t').state s = canon k' t' s := fun s => histOf_state k' t' s
  rcases letter_cases ℓ with rfl | ⟨ψ, hψ, rfl⟩
  · rw [clTrace_now, letterAt_now]
    simp
  · have hnow : clLetter Φ hψ ≠ clNow Φ := (clNow_ne_clLetter Φ hψ).symm
    rw [clTrace_letter]
    simp only [hnow, false_and, false_or]
    rcases lt_trichotomy (t' - z) 1 with h1 | h1 | h1
    · rcases lt_or_eq_of_le (show t' - z ≤ 0 by omega) with h0 | h0
      · rw [letterAt_of_neg h0, truth_classₙ hσ z h0 ψ hψ]
        exact (ℓₙ_letter hψ).symm
      · rw [letterAt_of_eq_zero h0, truth_class₀ hσ z h0 ψ hψ]
        exact (ℓ₀_letter hψ).symm
    · rw [letterAt_of_eq_one h1, truth_class₁ hσ z h1 ψ hψ]
      exact (ℓ₁_letter hψ).symm
    · rw [letterAt_of_two_le (by omega), truth_class₂ hσ z (by omega) ψ hψ]
      exact (ℓ₂_letter hψ).symm

/-- The function-level form of the bridge. -/
theorem clTrace_canon_eq (k' : ℕ) (t t' : ℤ) :
    clTrace M Φ t (histOf k' t')
      = fun ℓ z => (ℓ = clNow Φ ∧ z = t) ∨ letterAt (t' - z) ℓ = true := by
  funext ℓ z
  exact propext (clTrace_canon_apply k' t t' ℓ z)

/-- **The thread index is invisible to the closure trace**: two canonical histories with the same
`x`-time have the same closure trace. -/
theorem clTrace_canon_thread_free (k₁ k₂ : ℕ) (t t' : ℤ) :
    clTrace M Φ t (histOf k₁ t') = clTrace M Φ t (histOf k₂ t') := by
  rw [clTrace_canon_eq, clTrace_canon_eq]

/-- The canonical representative of the `i`-th trace through `(t, pre m)`: the closure trace,
anchored at `t`, of the thread-`0` history with `x`-time `t + 1 + i`. Thread-index-free by
`clTrace_canon_thread_free`, so it does not depend on `m`. -/
def cN (t : ℤ) (i : ℕ) : (clSig Φ).preds → ℤ → Prop := clTrace M Φ t (histOf 0 (t + 1 + i))

/-- `hitCl_pre` with the traces named by `cN`. -/
theorem hitCl_pre' (τ : WorldHistory F) (t : ℤ) (m k : ℕ) (hτ : τ.state t = .pre m) :
    HitCl M τ t Φ k = ⋃ i ∈ Finset.range (m + 1), familyTriples (clSig Φ) k (cN t i) := by
  rw [hitCl_pre τ t m k hτ]
  exact Set.iUnion_congr fun i => Set.iUnion_congr fun _ => by
    rw [cN, clTrace_canon_thread_free]

/-! ### Positional read-outs of `cN t i`

With `t' = t + 1 + i`, the relative position of `z` is `t + 1 + i - z`: `≥ 2` strictly below `t`
and on the run `[t + 1, t + i)`; `1` at `t + i` (and at the seam when `i = 0`); `0` at `t + i + 1`;
`< 0` above. Each read-out is `clTrace_canon_apply` with one `omega` side condition. -/

theorem cN_below (t : ℤ) (i : ℕ) (z : ℤ) (hz : z < t) (ℓ : (clSig Φ).preds) :
    cN t i ℓ z ↔ ℓ₂ ℓ = true := by
  rw [cN, clTrace_canon_apply, letterAt_of_two_le (by omega)]
  constructor
  · rintro (⟨-, h⟩ | h)
    · omega
    · exact h
  · exact Or.inr

theorem cN_seam_zero (t : ℤ) (ℓ : (clSig Φ).preds) :
    cN t 0 ℓ t ↔ ℓ = clNow Φ ∨ ℓ₁ ℓ = true := by
  rw [cN, clTrace_canon_apply, letterAt_of_eq_one (by simp)]
  simp only [and_true]

theorem cN_seam_pos (t : ℤ) (i : ℕ) (hi : 1 ≤ i) (ℓ : (clSig Φ).preds) :
    cN t i ℓ t ↔ ℓ = clNow Φ ∨ ℓ₂ ℓ = true := by
  rw [cN, clTrace_canon_apply, letterAt_of_two_le (by omega)]
  simp only [and_true]

theorem cN_run (t : ℤ) (i : ℕ) (z : ℤ) (hz : t + 1 ≤ z) (hz' : z < t + i) (ℓ : (clSig Φ).preds) :
    cN t i ℓ z ↔ ℓ₂ ℓ = true := by
  rw [cN, clTrace_canon_apply, letterAt_of_two_le (by omega)]
  constructor
  · rintro (⟨-, h⟩ | h)
    · omega
    · exact h
  · exact Or.inr

theorem cN_one (t : ℤ) (i : ℕ) (hi : 1 ≤ i) (ℓ : (clSig Φ).preds) :
    cN t i ℓ (t + i) ↔ ℓ₁ ℓ = true := by
  rw [cN, clTrace_canon_apply, letterAt_of_eq_one (by omega)]
  constructor
  · rintro (⟨-, h⟩ | h)
    · omega
    · exact h
  · exact Or.inr

theorem cN_zero (t : ℤ) (i : ℕ) (ℓ : (clSig Φ).preds) :
    cN t i ℓ (t + i + 1) ↔ ℓ₀ ℓ = true := by
  rw [cN, clTrace_canon_apply, letterAt_of_eq_zero (by omega)]
  constructor
  · rintro (⟨-, h⟩ | h)
    · omega
    · exact h
  · exact Or.inr

theorem cN_above (t : ℤ) (i : ℕ) (z : ℤ) (hz : t + i + 1 < z) (ℓ : (clSig Φ).preds) :
    cN t i ℓ z ↔ ℓₙ ℓ = true := by
  rw [cN, clTrace_canon_apply, letterAt_of_neg (by omega)]
  constructor
  · rintro (⟨-, h⟩ | h)
    · omega
    · exact h
  · exact Or.inr


/-! ## The `ℓ₂`-run inside the middle segment

`cN t i` reads `ℓ₂` strictly below the seam and on the run `[t + 1, t + i)`, the marker at `t`
(over `ℓ₂` when `1 ≤ i`, over `ℓ₁` when `i = 0`), `ℓ₁` at `t + i`, `ℓ₀` at `t + i + 1`, and `ℓₙ`
above. The transport layer (`RaySummary/Transport.lean`) deletes `p` positions of a constant run
held inside ONE segment of a `SegmentFactorization`; what this section supplies is the fixture fact
that EVERY factorization of `cN t i`, at every depth `k ≥ 1` and for `2 ≤ i`, holds the whole run
`[t + 1, t + i)` inside its middle segment `[W 0, W 1)` (`run_subset_middle`), so the surgery
applies with no re-cutting — exactly model A's `run_subset_middle`, with seam classification in
place of rigidity.

The argument is the keystone `segZ_const_of_kTypeOf_eq_replicate`, twice. If `W 0 > t`, the seam
`t` lies in a negative segment; some nonempty negative segment lies entirely below `t` (cover the
position `W z_t - 1`), reads `ℓ₂` throughout, and so fixes `τneg` as the type of a nonempty
`ℓ₂`-block; the keystone then makes the segment holding `t` constantly `ℓ₂`, but `t` reads
`now ∉ ℓ₂`. If `W 1 ≤ t + i - 1`, the run position `t + i - 1` lies in a positive segment; a
nonempty positive segment entirely above `t + i + 1` is found in TWO hops — cover `t + i + 2` to
get `z₁`, then cover `W (z₁ + 1)` to get `z₂ ≥ z₁ + 1` with `W z₂ = W (z₁ + 1) > t + i + 2` — because
`t + i` (`ℓ₁`) and `t + i + 1` (`ℓ₀`) sit between the run and the `ℓₙ` tail, so model A's one-hop
cover of `W (z_p + 1)` would not clear them; that segment reads `ℓₙ` throughout, fixes `τpos`, and
the keystone makes the segment holding `t + i - 1` constantly `ℓₙ`, but `t + i - 1` reads
`Fp ∈ ℓ₂ ∖ ℓₙ`. Depth `k ≥ 1` is consumed exactly at the keystone. -/

theorem cN_now (t : ℤ) (i : ℕ) (z : ℤ) : cN t i (clNow Φ) z ↔ z = t := Iff.rfl

/-- **The middle segment starts at or before the seam.** Otherwise `t` lies in a negative
segment, which the keystone makes constantly `ℓ₂` — but `t` reads `now`. -/
theorem W0_le_seam (k : ℕ) (hk : 1 ≤ k) (t : ℤ) (i : ℕ)
    (F : SegmentFactorization (clSig Φ) k (cN t i)) : F.W 0 ≤ t := by
  by_contra hcon
  push Not at hcon
  obtain ⟨zt, h1, h2⟩ := F.cover t
  have hzt : zt < 0 := by
    by_contra h
    push Not at h
    have := F.mono h
    omega
  -- a nonempty negative segment entirely below `t`: the one covering `W zt - 1`
  obtain ⟨z', h3, h4⟩ := F.cover (F.W zt - 1)
  have hz' : z' + 1 ≤ zt := by
    by_contra h
    push Not at h
    have := F.mono (show zt ≤ z' by omega)
    omega
  have h5 : F.W (z' + 1) ≤ F.W zt := F.mono hz'
  have hτ : kTypeOf (clSig Φ) k (segZ (clSig Φ) (cN t i) (F.W z') (F.W (z' + 1)))
      = kTypeOf (clSig Φ) k (listSeg (List.replicate (F.W (z' + 1) - F.W z').toNat ℓ₂)) :=
    kTypeOf_segZ_eq_replicate_of_const k _ _ _ ℓ₂
      (fun u _ hu' q => cN_below t i u (by omega) q)
  have hlen : 0 < (F.W (z' + 1) - F.W z').toNat := by omega
  have hzt_type := (F.neg_type zt hzt).trans ((F.neg_type z' (by omega)).symm.trans hτ)
  obtain ⟨-, hconst⟩ :=
    segZ_const_of_kTypeOf_eq_replicate hk _ (F.W zt) (F.W (zt + 1)) ℓ₂ hlen hzt_type
  have := (hconst t h1 h2 (clNow Φ)).mp ((cN_now t i t).mpr rfl)
  rw [ℓ₂_now] at this
  exact Bool.false_ne_true this

/-- **The middle segment ends after the run** (`2 ≤ i`). Otherwise the run position `t + i - 1`
lies in a positive segment, which the keystone makes constantly `ℓₙ` — but `t + i - 1` reads `Fp`.
The nonempty positive segment above `t + i + 1` is found in two hops (see the section header). -/
theorem run_lt_W1 (k : ℕ) (hk : 1 ≤ k) (t : ℤ) (i : ℕ) (hi : 2 ≤ i)
    (F : SegmentFactorization (clSig Φ) k (cN t i)) : t + i - 1 < F.W 1 := by
  by_contra hcon
  push Not at hcon
  obtain ⟨zp, h1, h2⟩ := F.cover (t + i - 1)
  have hzp : 0 < zp := by
    by_contra h
    push Not at h
    have := F.mono (show zp + 1 ≤ 1 by omega)
    omega
  -- hop 1: the segment covering `t + i + 2`
  obtain ⟨z₁, h3, h4⟩ := F.cover (t + i + 2)
  -- hop 2: the segment covering `W (z₁ + 1)`, which starts exactly there
  obtain ⟨z₂, h5, h6⟩ := F.cover (F.W (z₁ + 1))
  have hz₂ : z₁ + 1 ≤ z₂ := by
    by_contra h
    push Not at h
    have := F.mono (show z₂ + 1 ≤ z₁ + 1 by omega)
    omega
  have h7 : F.W (z₁ + 1) ≤ F.W z₂ := F.mono hz₂
  have hz₁ : 1 ≤ z₁ := by
    by_contra h
    push Not at h
    have := F.mono (show z₁ + 1 ≤ 1 by omega)
    omega
  have hτ : kTypeOf (clSig Φ) k (segZ (clSig Φ) (cN t i) (F.W z₂) (F.W (z₂ + 1)))
      = kTypeOf (clSig Φ) k (listSeg (List.replicate (F.W (z₂ + 1) - F.W z₂).toNat ℓₙ)) :=
    kTypeOf_segZ_eq_replicate_of_const k _ _ _ ℓₙ
      (fun u hu _ q => cN_above t i u (by omega) q)
  have hlen : 0 < (F.W (z₂ + 1) - F.W z₂).toNat := by omega
  have hzp_type := (F.pos_type zp hzp).trans ((F.pos_type z₂ (by omega)).symm.trans hτ)
  obtain ⟨-, hconst⟩ :=
    segZ_const_of_kTypeOf_eq_replicate hk _ (F.W zp) (F.W (zp + 1)) ℓₙ hlen hzp_type
  have hFp := (hconst (t + i - 1) h1 h2 (clLetter Φ cl_Fp)).mp
    ((cN_run t i (t + i - 1) (by omega) (by omega) _).mpr ℓ₂_Fp)
  rw [ℓₙ_Fp] at hFp
  exact Bool.false_ne_true hFp

/-- **Every factorization of `cN t i` (`2 ≤ i`) holds the whole run `[t + 1, t + 1 + (i - 1))`
inside its middle segment** (`k ≥ 1`). The containment hypothesis of
`familyTriples_subset_deleteRun`, discharged on the fixture. -/
theorem run_subset_middle (k : ℕ) (hk : 1 ≤ k) (t : ℤ) (i : ℕ) (hi : 2 ≤ i)
    (F : SegmentFactorization (clSig Φ) k (cN t i)) :
    F.W 0 ≤ t + 1 ∧ t + 1 + ((i - 1 : ℕ) : ℤ) ≤ F.W 1 :=
  ⟨by have := W0_le_seam k hk t i F; omega, by have := run_lt_W1 k hk t i hi F; omega⟩

/-- **Deleting `p` positions of the `ℓ₂`-run of `cN t (i + p)` gives `cN t i`** (`1 ≤ i`).
Pointwise from `clTrace_canon_apply`: below `t + 1` both traces read `ℓ₂` (the marker at `t`
included, since `1 ≤ i` puts the seam over `ℓ₂` on both), and from `t + 1` on the deleted trace
reads `cN t (i + p)` at `u + p`, whose relative position `t + 1 + (i + p) - (u + p)` is
`t + 1 + i - u`, with `now` on neither side. -/
theorem deleteRun_cN (t : ℤ) (i p : ℕ) (hi : 1 ≤ i) :
    deleteRun (cN t (i + p)) (t + 1) p = cN t i := by
  funext ℓ u
  apply propext
  by_cases h : u < t + 1
  · rw [deleteRun_of_lt h, cN, cN, clTrace_canon_apply, clTrace_canon_apply,
      letterAt_of_two_le (by omega), letterAt_of_two_le (by omega)]
  · rw [deleteRun_of_le (not_lt.mp h), cN, cN, clTrace_canon_apply, clTrace_canon_apply]
    have e : t + 1 + ((i + p : ℕ) : ℤ) - (u + (p : ℤ)) = t + 1 + (i : ℤ) - u := by
      push_cast; ring
    have h1 : ¬ (u + (p : ℤ) = t) := by omega
    have h2 : ¬ (u = t) := by omega
    rw [e]
    simp only [h1, h2, and_false, false_or]

/-- **Family triples shrink along the history index**: beyond the threshold, every family triple
of `cN t (i + p)` is one of `cN t i`. `deleteRun_cN` rewrites the target, `run_subset_middle`
supplies the containment with `z₀ = 0`, `s = t + 1` and `j = i - 1 + p`, `cN_run` the constancy,
and the surgery `familyTriples_subset_deleteRun` does the rest; `2 ≤ i` is what makes `p < j`, and
`m₀ + 1 ≤ i` what makes `m₀ + p ≤ j`. -/
theorem familyTriples_cN_shrink (k : ℕ) (hk : 1 ≤ k) (t : ℤ) (m₀ p : ℕ)
    (hper : ∀ n, m₀ ≤ n → kTypeOf (clSig Φ) k (listSeg (List.replicate (n + p) ℓ₂))
      = kTypeOf (clSig Φ) k (listSeg (List.replicate n ℓ₂)))
    (i : ℕ) (hi : m₀ + 1 ≤ i) (h2 : 2 ≤ i) :
    familyTriples (clSig Φ) k (cN t (i + p)) ⊆ familyTriples (clSig Φ) k (cN t i) := by
  rw [← deleteRun_cN t i p (by omega)]
  refine familyTriples_subset_deleteRun k _ (t + 1) ℓ₂ (i - 1 + p) p m₀ (by omega) (by omega)
    ?_ ?_ hper
  · intro F
    refine ⟨0, ?_⟩
    have := run_subset_middle k hk t (i + p) (by omega) F
    simp only [zero_add]
    push_cast [Nat.cast_sub (by omega : 1 ≤ i + p), Nat.cast_sub (by omega : 1 ≤ i)] at this ⊢
    constructor <;> omega
  · intro u hu hu' q
    exact cN_run t (i + p) u hu (by push_cast at hu' ⊢; omega) q


/-! ## The truncation bound and the exhibited counts

`hitCl_pre'` presents `HitCl` at `(t, pre m)` as a union over the `m + 1` history indices — already
finite, but growing with the seam index `m`. The truncation below replaces it by the window
`[0, windowN m k]` with `windowN m k = min m (W + 1)`, `W := Nat.card (KType (clSig Φ) k)`: a
window uniform over every seam. **Where the bound comes from, named exactly.** The library's
`kTypeOf_listSeg_replicate_eventually_periodic_bounded` at the letter `ℓ₂` gives a threshold `m₀`
and a period `p > 0` with `m₀ + p ≤ W`; `familyTriples_cN_shrink` moves a family triple from index
`i` to index `i - p` whenever `m₀ + 1 ≤ i - p` and `2 ≤ i - p`, both true once `i > W + 1`; so an
index above the window reduces by `p` at a time, by strong induction, until it lies in
`[0, windowN m k]`. No `Set.Finite.bddAbove`, no `choose!`: the window is written down. Nothing in
this section evaluates a `kTypeOf`, runs `decide` over `KType`, or `#eval`s `windowN`. -/

/-- **The window, exhibited**: `min m (Nat.card (KType (clSig Φ) k) + 1)`. In `AnchorLayer.lean`'s
words on its own cell count, binding here with "depth-`k` types" for "cells": "The one bound (W)
can state honestly: a cardinality bound on the SET OF CELLS of a model, syntactic in `|cl φ|` — a
cell is a set of subsets of `cl φ`, so there are at most `2 ^ (2 ^ |cl φ|)` of them. It is not a
complexity bound of any kind: it counts cells, it does not time anything, and it must not be
described as a bound on any procedure's running time." `windowN m k` counts depth-`k` types (and
seam indices), times nothing, bounds no procedure, and is not a complexity bound of any kind. It
is never `#eval`-ed here; `Nat.card` is a well-formed `ℕ` term in a `Prop`. -/
noncomputable abbrev windowN (m k : ℕ) : ℕ := min m (Nat.card (KType (clSig Φ) k) + 1)

/-- The presentation's state type at window `L`: `Fin (L + 5)` — one gadget, five fixed states
`A, N₀, N₊, Z, P` and the chain `C_1 … C_L` (Phase 6's index table). -/
abbrev QN (L : ℕ) := Fin (L + 5)

/-- The state count at window `L`. -/
theorem card_QN (L : ℕ) : Fintype.card (QN L) = L + 5 := Fintype.card_fin _

/-- **The state count at the exhibited window, uniform over every pre-seam**: at most
`Nat.card (KType (clSig Φ) k) + 6`, whatever the seam index `m`. A count of states and of depth-`k`
types, not a complexity bound of any kind (the disclaimer at `windowN`). -/
theorem card_QN_le (m k : ℕ) :
    Fintype.card (QN (windowN m k)) ≤ Nat.card (KType (clSig Φ) k) + 6 := by
  rw [card_QN]
  have hw : windowN m k = min m (Nat.card (KType (clSig Φ) k) + 1) := rfl
  omega

#guard Fintype.card (QN 2) = 7

/-- **The truncation bound, with the window exhibited.** For any `τ` with `τ.state t = .pre m` and
any depth `k ≥ 1`, `HitCl M τ t Φ k` is the union of the family triples of `cN t i` for
`i ≤ windowN m k`. `⊆`: every realized index is `≤ m` (`hitCl_pre'`); if it exceeds
`windowN m k = min m (W + 1)` it exceeds `W + 1 ≥ m₀ + p + 1`, so `familyTriples_cN_shrink` lowers
it by `p`, and strong induction lands it in the window. `⊇`: `windowN m k ≤ m`. `hk` is consumed
by the containment `run_subset_middle` inside `familyTriples_cN_shrink`. -/
theorem hitCl_eq_truncated_node (t : ℤ) (m k : ℕ) (hk : 1 ≤ k) (τ : WorldHistory F)
    (hτ : τ.state t = .pre m) :
    HitCl M τ t Φ k
      = ⋃ i ∈ Finset.range (windowN m k + 1), familyTriples (clSig Φ) k (cN t i) := by
  obtain ⟨m₀, p, hp, hle, hper⟩ :=
    kTypeOf_listSeg_replicate_eventually_periodic_bounded (clSig Φ) k ℓ₂
  have hw : windowN m k = min m (Nat.card (KType (clSig Φ) k) + 1) := rfl
  -- every realized index `≤ m` reduces, `p` at a time, into the window
  have reduce : ∀ i : ℕ, i ≤ m → ∀ x, x ∈ familyTriples (clSig Φ) k (cN t i) →
      ∃ i' : ℕ, i' ≤ windowN m k ∧ i' ≤ i ∧ x ∈ familyTriples (clSig Φ) k (cN t i') := by
    intro i
    induction i using Nat.strong_induction_on with
    | _ i ih =>
      intro him x hx
      by_cases hi : i ≤ windowN m k
      · exact ⟨i, hi, le_refl i, hx⟩
      · push Not at hi
        obtain ⟨i', rfl⟩ : ∃ i', i = i' + p := ⟨i - p, by omega⟩
        obtain ⟨i'', h1, h2, h3⟩ := ih i' (by omega) (by omega) x
          (familyTriples_cN_shrink k hk t m₀ p hper i' (by omega) (by omega) hx)
        exact ⟨i'', h1, by omega, h3⟩
  rw [hitCl_pre' τ t m k hτ]
  ext x
  simp only [Set.mem_iUnion, Finset.mem_range]
  constructor
  · rintro ⟨i, hi, hx⟩
    obtain ⟨i', hi', -, hx'⟩ := reduce i (by omega) x hx
    exact ⟨i', by omega, hx'⟩
  · rintro ⟨i, hi, hx⟩
    exact ⟨i, by omega, hx⟩


/-! ## The presentation data

ONE gadget on `QN L = Fin (L + 5)`, one anchored run per trace the truncation left standing. The
index table (binding for the run characterization below):

| index                  | name  | letter | `now` | successors                              |
|------------------------|-------|--------|-------|-----------------------------------------|
| `0`                    | `A`   | `ℓ₂`   | no    | `0, 1, 2`                               |
| `1`                    | `N₀`  | `ℓ₁`   | YES   | `3`                                     |
| `2`                    | `N₊`  | `ℓ₂`   | YES   | every `j` with `5 ≤ j` (none at `L = 0`) |
| `3`                    | `Z`   | `ℓ₀`   | no    | `4`                                     |
| `4`                    | `P`   | `ℓₙ`   | no    | `4`                                     |
| `4 + j`, `1 ≤ j < L`   | `C_j` | `ℓ₂`   | no    | `5 + j`                                 |
| `L + 4` (only `1 ≤ L`) | `C_L` | `ℓ₁`   | no    | `3`                                     |

Anchored runs (`IsRun`: `now` exactly at `t`): `A^(ω*)·N₀·Z·P^ω` traces `cN t 0`;
`A^(ω*)·N₊·C_j·C_(j+1)·…·C_L·Z·P^ω`, entering the chain at `C_j` (`1 ≤ j ≤ L`), reads `ℓ₂` on
`[t + 1, t + (L - j)]`, `ℓ₁` at `t + (L - j) + 1`, `ℓ₀` next and `ℓₙ` after — i.e. `cN t i` with
`i = L - j + 1 ∈ [1, L]`. `N₊` may enter the chain at ANY `C_j`, and `C_L` plays the role of the
last run state (reading `ℓ₁`); this is what leaves room at `L = 0`, where `N₊` has no successor
at all and so no anchored run passes it. No chain state has a self-loop, so a run entering the
chain reaches `Z` within `L` steps; the only predecessor of `N₀`, `N₊` and `A` is `A`.

`stepN`, `isNowN`, `vecN` and `labN` are `def`, never `noncomputable def`: `HitPresented` is a
proposition ABOUT `hitOf lab step`, and `hitOf` is a `Finset`, so the presentation data has to
compute. `labN` reads the marker off `isNowN` and every closure letter off the state's letter
vector, so the labelling bridge below is a case split on the index, never a re-derivation of the
semantics. -/

/-- The step table (see the index table above). -/
def stepN (L : ℕ) : QN L → QN L → Bool := fun q r =>
  decide ((q.val = 0 ∧ r.val ≤ 2) ∨ (q.val = 1 ∧ r.val = 3) ∨ (q.val = 2 ∧ 5 ≤ r.val)
    ∨ (5 ≤ q.val ∧ q.val < L + 4 ∧ r.val = q.val + 1) ∨ (5 ≤ q.val ∧ q.val = L + 4 ∧ r.val = 3)
    ∨ (q.val = 3 ∧ r.val = 4) ∨ (q.val = 4 ∧ r.val = 4))

/-- The marker is read at `N₀` and `N₊`, and nowhere else. -/
def isNowN (L : ℕ) (q : QN L) : Bool := decide (q.val = 1 ∨ q.val = 2)

/-- The letter vector of a state. Order matters: index `4` is `P` and is tested before the
`L + 4` test, so at `L = 0` the two cannot collide. -/
def vecN (L : ℕ) (q : QN L) : (clSig Φ).preds → Bool :=
  if q.val = 1 then ℓ₁ else if q.val = 3 then ℓ₀ else if q.val = 4 then ℓₙ
  else if 5 ≤ q.val ∧ q.val = L + 4 then ℓ₁ else ℓ₂

/-- **The labelling**: the marker from `isNowN`, every closure letter from the state's vector. -/
def labN (L : ℕ) : QN L → (clSig Φ).preds → Bool := fun q ℓ =>
  if ℓ = clNow Φ then isNowN L q else vecN L q ℓ

-- live checks on the table at `L = 2` (a `#guard` failure is a compile error)
#guard labN 2 ⟨1, by omega⟩ (clNow Φ) = true
#guard labN 2 ⟨0, by omega⟩ (clNow Φ) = false
#guard labN 2 ⟨6, by omega⟩ (clLetter Φ cl_Xp) = true
#guard stepN 2 ⟨2, by omega⟩ ⟨6, by omega⟩ = true
#guard stepN 2 ⟨6, by omega⟩ ⟨3, by omega⟩ = true

/-! ### The labelling bridge -/

theorem labN_now (L : ℕ) (q : QN L) : labN L q (clNow Φ) = true ↔ q.val = 1 ∨ q.val = 2 := by
  unfold labN isNowN
  rw [if_pos rfl, decide_eq_true_iff]

theorem labN_letter (L : ℕ) (q : QN L) (ℓ : (clSig Φ).preds) (hℓ : ℓ ≠ clNow Φ) :
    labN L q ℓ = vecN L q ℓ := by
  unfold labN
  rw [if_neg hℓ]

theorem vecN_A (L : ℕ) (q : QN L) (h : q.val = 0) : vecN L q = ℓ₂ := by
  unfold vecN
  rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega)]
theorem vecN_N₀ (L : ℕ) (q : QN L) (h : q.val = 1) : vecN L q = ℓ₁ := by
  unfold vecN
  rw [if_pos h]
theorem vecN_Npos (L : ℕ) (q : QN L) (h : q.val = 2) : vecN L q = ℓ₂ := by
  unfold vecN
  rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega)]
theorem vecN_Z (L : ℕ) (q : QN L) (h : q.val = 3) : vecN L q = ℓ₀ := by
  unfold vecN
  rw [if_neg (by omega), if_pos h]
theorem vecN_P (L : ℕ) (q : QN L) (h : q.val = 4) : vecN L q = ℓₙ := by
  unfold vecN
  rw [if_neg (by omega), if_neg (by omega), if_pos h]
theorem vecN_chain (L : ℕ) (q : QN L) (hj : 5 ≤ q.val) (hj' : q.val < L + 4) :
    vecN L q = ℓ₂ := by
  unfold vecN
  rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega)]
theorem vecN_last (L : ℕ) (q : QN L) (hL : 1 ≤ L) (h : q.val = L + 4) : vecN L q = ℓ₁ := by
  unfold vecN
  rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_pos ⟨by omega, h⟩]

/-! ### The step table, read out -/

theorem stepN_pred_now (L : ℕ) {q r : QN L} (h : stepN L q r = true) (hr : r.val = 1 ∨ r.val = 2) :
    q.val = 0 := by
  simp only [stepN, decide_eq_true_eq] at h; omega
theorem stepN_pred_A (L : ℕ) {q r : QN L} (h : stepN L q r = true) (hr : r.val = 0) : q.val = 0 := by
  simp only [stepN, decide_eq_true_eq] at h; omega
theorem stepN_N₀ (L : ℕ) {q r : QN L} (h : stepN L q r = true) (hq : q.val = 1) : r.val = 3 := by
  simp only [stepN, decide_eq_true_eq] at h; omega
theorem stepN_Npos (L : ℕ) {q r : QN L} (h : stepN L q r = true) (hq : q.val = 2) : 5 ≤ r.val := by
  simp only [stepN, decide_eq_true_eq] at h; omega
theorem stepN_chain (L : ℕ) {q r : QN L} (h : stepN L q r = true) (hq : 5 ≤ q.val) :
    (q.val < L + 4 ∧ r.val = q.val + 1) ∨ (q.val = L + 4 ∧ r.val = 3) := by
  simp only [stepN, decide_eq_true_eq] at h; omega
theorem stepN_Z (L : ℕ) {q r : QN L} (h : stepN L q r = true) (hq : q.val = 3) : r.val = 4 := by
  simp only [stepN, decide_eq_true_eq] at h; omega
theorem stepN_P (L : ℕ) {q r : QN L} (h : stepN L q r = true) (hq : q.val = 4) : r.val = 4 := by
  simp only [stepN, decide_eq_true_eq] at h; omega

/-- The step table as an `↔` on the index values (for building the witness runs). -/
theorem stepN_iff (L : ℕ) (q r : QN L) :
    stepN L q r = true ↔
      ((q.val = 0 ∧ r.val ≤ 2) ∨ (q.val = 1 ∧ r.val = 3) ∨ (q.val = 2 ∧ 5 ≤ r.val)
        ∨ (5 ≤ q.val ∧ q.val < L + 4 ∧ r.val = q.val + 1) ∨ (5 ≤ q.val ∧ q.val = L + 4 ∧ r.val = 3)
        ∨ (q.val = 3 ∧ r.val = 4) ∨ (q.val = 4 ∧ r.val = 4)) := by
  simp only [stepN, decide_eq_true_eq]

end Probe759

-- temporary foot (Phase 1); replaced by the full axiom foot with the headline
#print axioms Probe759.hitCl_pre
#print axioms Probe759.clTrace_canon_apply
#print axioms Probe759.familyTriples_cN_shrink
#print axioms Probe759.hitCl_eq_truncated_node
#print axioms Probe759.labN
#print axioms Probe759.stepN
