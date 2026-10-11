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

end Probe759

-- temporary foot (Phase 1); replaced by the full axiom foot with the headline
#print axioms Probe759.hitCl_pre
