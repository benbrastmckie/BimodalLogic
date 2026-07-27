/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.ConjInterleave
import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas

/-!
# Arity lift of a low-arity `∃∀`-formula to the arity-`r` context (Rabinovich Lemma 3.2(1), p.4-5)

The Prop 4.3 negation case (PDF p.6) produces disjuncts with **at most two free variables**
(inherited from the Lemma 3.2(2) ≤2-free-variable conjuncts), whereas the homogeneous Lean object
`VeeExistsForall sig F r = List (ExistsForallFormula sig F r)` forces every disjunct to pin **all**
`r` free variables via a total `pin`. Reconciling a ≤2-free-variable disjunct with the arity-`r`
context is the **arity lift**: it inserts the `r-2` other (ordered) context points into the
disjunct's existential chain, over every order-preserving insertion — Rabinovich's own Lemma 3.2(1)
chain-merge, already landed both directions as `conjInterleave_iff` (`ConjInterleave.lean`).

## The complete-point-type subtlety (spike finding)

`UnaryType sig F = NormalForm (sigE sig F) 0 1` is a **complete** quantifier-free 1-type:
`unaryHolds N τ y` requires *every* E[Σ] atom at `y` to match `τ` exactly, and a point realizes at
most one such type (`nf_eval_unique`). Consequently there is **no ⊤ point type**: the report-12
sketch's `skelR : ExistsForallFormula sig F r` (`⊤ point types`, satisfied by every `StrictMono
env`) is not constructible as a single formula — a fixed complete point type at an inserted point
constrains the arbitrary context value there. The faithful universally-satisfiable skeleton is a
**`VeeExistsForall`**, disjoining over the finite set of point-type assignments (`skelR` below):
for any environment, the disjunct whose point types are the environment's *characteristic* types
(`charType`) is satisfied. Interval types, by contrast, are **partial** (`IntervalType = Finset
UnaryType`); the ⊤ interval `intervalTop = univ` is trivially satisfied at every point
(`intervalHolds_top`), because every point realizes *some* complete type.

This same disjoin-over-point-types device is what an arity lift needs at each inserted context
point: the inserted point's complete type is not statically known, so `liftPair` must range over
all completions — exactly as `skelR` demonstrates end to end here.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Lemma 3.2(1) (p.4), Lemma 3.4 (p.5), Def 3.1
  (p.4), Prop 4.3 ¬-case (p.6). Cited by PDF page; the companion markdown transcription is corrupt.
- `ConjInterleave.lean`: the landed both-directions merge `conjInterleave_iff` and its internal
  `MergePair` / `mergedFormula` / sorted-union rank machinery reused by the lift.
- `ExistsForallFormula.lean`: `ExistsForallFormula`, `efSat`, `UnaryType`, `unaryHolds`,
  `IntervalType`, `intervalHolds`.
- `NormalForm.lean`: `nf_characteristic` / `nf_characteristic_satisfies` (the characteristic type
  of a point).

OFF the live import path: nothing here is imported by `KampPrior.lean` or the completeness spine.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula)

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}

/-! ## 3. The arity-lift merge datum

`liftPair` lifts a single arity-2 `∃∀`-formula `ξ` into the arity-`r` context by merging `ξ`'s
existential chain (`ξ.n+1` points) with the `r` ordered context points (the skeleton), over every
order-preserving insertion. Structurally this mirrors `ConjInterleave.MergePair`, but with three
differences forced by the lift (see `LiftPair` module docstring / spike findings):

- The two embedded objects have **different shapes**: `ξ`'s chain (`Fin (nξ+1)`) and the `r`
  skeleton points (`Fin r`), not two arity-`r` chains.
- Pin coincidence is required **only at `k, l`** (the two `ξ`-pinned context variables), not at all
  `r` variables — `LiftMergePair.valid` below.
- The skeleton carries no complete point type statically (there is no ⊤ point type). Inserted points
  range over a completion assignment `σ`, constrained to be `ξ`-interval-admissible by
  `LiftMergePair.crossConsistent`. -/

/-- Raw arity-lift merge data: an embedding of `ξ`'s `nξ+1` chain points and an embedding of the `r`
skeleton (context) points into a common merged chain of `K+1` points. Monotonicity, joint
surjectivity, and the `k,l` pin coincidence are imposed by the decidable `valid` predicate. -/
structure LiftMergePair (nξ r K : Nat) where
  /-- Embedding of `ξ`'s existential chain into the merged chain. -/
  eξ : Fin (nξ + 1) → Fin (K + 1)
  /-- Embedding of the `r` ordered skeleton (context) points into the merged chain. -/
  eS : Fin r → Fin (K + 1)
  deriving DecidableEq

/-- `LiftMergePair` is equivalent to the product of its two function spaces (for `Fintype`). -/
def LiftMergePair.equivProd (nξ r K : Nat) :
    LiftMergePair nξ r K ≃ (Fin (nξ + 1) → Fin (K + 1)) × (Fin r → Fin (K + 1)) where
  toFun m := (m.eξ, m.eS)
  invFun p := ⟨p.1, p.2⟩
  left_inv := fun _ => rfl
  right_inv := fun _ => rfl

instance (nξ r K : Nat) : Fintype (LiftMergePair nξ r K) :=
  Fintype.ofEquiv _ (LiftMergePair.equivProd nξ r K).symm

/-- The lift merge is **valid**: both embeddings strictly monotone, jointly surjective onto the
merged chain, and pin-coincident **only** at the two lifted variables `k, l` (their skeleton points
are exactly `ξ`'s two pinned chain points). This is the sole change from `MergePair.valid`, which
demands coincidence at all `r` variables. -/
def LiftMergePair.valid {nξ r K : Nat} (pinξ : Fin 2 → Fin (nξ + 1)) (k l : Fin r)
    (m : LiftMergePair nξ r K) : Prop :=
  StrictMono m.eξ ∧ StrictMono m.eS ∧
    (∀ j : Fin (K + 1), (∃ i, m.eξ i = j) ∨ (∃ i, m.eS i = j)) ∧
    m.eS k = m.eξ (pinξ 0) ∧ m.eS l = m.eξ (pinξ 1)

instance {nξ r K : Nat} (pinξ : Fin 2 → Fin (nξ + 1)) (k l : Fin r) (m : LiftMergePair nξ r K) :
    Decidable (m.valid pinξ k l) := by
  unfold LiftMergePair.valid
  infer_instance
/-! ## 9. Sentence lift: lifting an arity-0 `∃∀` object (the existence-sentence disjunct)

`liftSentence` lifts an arity-`0` `∃∀`-object `ξ` (a sentence — no free variables, in practice the
existence-sentence negation object) to arity `r`, inserting all `r` context points into `ξ`'s chain
with **no** pin coincidence constraint. Structurally it is `liftPair` minus the `k,l` clauses. -/

/-- The lift merge is **valid as a sentence lift**: both embeddings strictly monotone and jointly
surjective, with no pin coincidence (the sentence has no free variables to pin). -/
def LiftMergePair.validS {nξ r K : Nat} (m : LiftMergePair nξ r K) : Prop :=
  StrictMono m.eξ ∧ StrictMono m.eS ∧
    (∀ j : Fin (K + 1), (∃ i, m.eξ i = j) ∨ (∃ i, m.eS i = j))

instance {nξ r K : Nat} (m : LiftMergePair nξ r K) : Decidable m.validS := by
  unfold LiftMergePair.validS
  infer_instance
/-! ## 10. Single-variable lift: lifting an arity-1 `∃∀` object (the `k = l` diagonal disjunct)

`liftSingle` lifts an arity-`1` `∃∀`-object `ξ` (in practice the arity-1 diagonal negation object
of a
`k = l` pairwise projection) into the arity-`r` context, pinning `ξ`'s single free variable to
context
position `k`. Structurally it is `liftPair` with **one** pin coincidence instead of two — the merge
machinery (`LiftMergePair` / `liftMergedFormula` / `crossConsistent` / `liftMergedPointType`) is
already
arity-generic in the source, so only a new one-coincidence `valid1` predicate and the near-verbatim
forward/backward proofs (keeping a single coincidence) are needed. There is **no** order gate: the
diagonal is a genuine one-free-variable condition, so `liftSingle_iff` holds for every `StrictMono
env`. -/

/-- The lift merge is **valid as a single-variable lift**: both embeddings strictly monotone,
jointly
surjective, and pin-coincident at the **one** lifted variable `k` (its skeleton point is exactly
`ξ`'s
single pinned chain point). This is `LiftMergePair.valid` with one coincidence instead of two. -/
def LiftMergePair.valid1 {nξ r K : Nat} (pinξ1 : Fin 1 → Fin (nξ + 1)) (k : Fin r)
    (m : LiftMergePair nξ r K) : Prop :=
  StrictMono m.eξ ∧ StrictMono m.eS ∧
    (∀ j : Fin (K + 1), (∃ i, m.eξ i = j) ∨ (∃ i, m.eS i = j)) ∧
    m.eS k = m.eξ (pinξ1 0)

instance {nξ r K : Nat} (pinξ1 : Fin 1 → Fin (nξ + 1)) (k : Fin r) (m : LiftMergePair nξ r K) :
    Decidable (m.valid1 pinξ1 k) := by
  unfold LiftMergePair.valid1
  infer_instance
/-! ## 11. FinLayer: the per-formula (`M`-relative) skeleton and arity lifts (Phase-4b re-encode)

Fin mirrors of §1-10 on the per-formula representation (`ExistsForallFormulaFin`, bundled `M`;
`PerFormulaExistsForall.lean`). The merge datum `LiftMergePair` and its `valid`/`valid1`/`validS`
predicates are pure index structures (no alphabet content) and are **reused verbatim**; what
changes is the completion axis: the ranged-over completion assignments `σ` are `M`-relative
partial completions `UnaryTypeFin sig₀ F₀ ξ.M` (Rabinovich Def 3.1/Lemma 3.2(1), PDF p.4 —
every formula mentions finitely many atoms, and the lift's disjunction absorbs the finite
per-point completion expansion), NEVER total types. Consequently:

- the tuple-skeleton disjunction `skelRFin` ranges over `Finset.univ : Finset (Fin (m+1) →
  UnaryTypeFin sig₀ F₀ M)` — finite from `M` alone, no whole-alphabet `Finset.univ`;
- the uniqueness engine is `partialHolds_eq_charTypeFin` (the Fin analog of `nf_eval_unique`);
- ⊤ interval slots are `intervalTopFin M` (`IntervalType.lean` §5);
- the slot-placement layer is the landed `chain_interval_clauseFin` /
  `chainIntervalTypeFin_eq_pointSlot` / `intervalSlot_eq_pointSlotFin` /
  `regions_of_pointSlotFin` (`ConjInterleave.lean` §10.4).

Fresh section variables `sig₀`/`F₀` prevent capture of the file-level alphabet instances
(`Fintype sig.preds`/`DecidableEq sig.preds`): NO declaration below consumes any alphabet
finiteness. -/

namespace Kamp

section FinLayer

variable {sig₀ : MonadicSignature} {F₀ : Finset Formula}

/-! ### 11.1 Every point realizes a partial type; ⊤ partial intervals are trivially satisfied

The Fin mirrors of §1's `charType`/`unaryHolds_charType` are the landed
`charTypeFin`/`partialHolds_charTypeFin` (`PerFormulaType.lean`); the ⊤-interval fact is
`intervalHoldsFin_top` (`IntervalType.lean` §5). Only the existence corollary is new. -/

/-- Fin mirror of `exists_unaryHolds`: every point realizes **some** `M`-relative partial type
(its characteristic completion). -/
theorem exists_partialHolds (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (M : Finset (AtomKind (sigE sig₀ F₀) 1)) (y : N.carrier) :
    ∃ c : UnaryTypeFin sig₀ F₀ M, partialHolds N c y :=
  ⟨charTypeFin N M y, partialHolds_charTypeFin N M y⟩

/-! ### 11.2 The universally-satisfiable arity-`m+1` skeleton (per-formula representation) -/

/-- Fin mirror of `skelDisjunct`: a single skeleton disjunct at arity `m+1` over the ambient
mentioned-atom set `M` — `m+1` ordered points, identity-pinned, carrying the `M`-relative
point-type assignment `σ` and ⊤ (`intervalTopFin M`) interval types everywhere. -/
noncomputable def skelDisjunctFin (M : Finset (AtomKind (sigE sig₀ F₀) 1)) (m : Nat)
    (σ : Fin (m + 1) → UnaryTypeFin sig₀ F₀ M) : ExistsForallFormulaFin sig₀ F₀ (m + 1) where
  n := m
  M := M
  pin := id
  pointType := σ
  intervalType := fun _ => intervalTopFin M

open Classical in
/-- Fin mirror of `skelR`: the skeleton `∨∃∀`-formula at arity `m+1` over `M` — the finite
disjunction, over every `M`-relative point-type assignment, of the identity-pinned ⊤-interval
formula. `Finset.univ` ranges over `Fin (m+1) → UnaryTypeFin sig₀ F₀ M`, finite from `M` alone
(report 22 §4 row 4b: the tuple skeleton survives the flip because it is class (c)). -/
noncomputable def skelRFin (M : Finset (AtomKind (sigE sig₀ F₀) 1)) (m : Nat) :
    VeeExistsForallFin sig₀ F₀ (m + 1) :=
  (Finset.univ : Finset (Fin (m + 1) → UnaryTypeFin sig₀ F₀ M)).toList.map (skelDisjunctFin M m)

/-- Fin mirror of `skelR_sat`: every strictly increasing environment satisfies `skelRFin` — the
disjunct whose point types are the environment's characteristic completions (`charTypeFin`)
witnesses it, with the ⊤ partial interval trivially satisfied everywhere. -/
theorem skelRFin_sat {M : Finset (AtomKind (sigE sig₀ F₀) 1)} {m : Nat}
    (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin (m + 1) → N.carrier) (h : StrictMono env) :
    veeSatFin N env (skelRFin M m) := by
  classical
  refine ⟨skelDisjunctFin M m (fun v => charTypeFin N M (env v)), ?_, ?_⟩
  · -- membership: the characteristic-completion assignment is one of the enumerated disjuncts
    unfold skelRFin
    rw [List.mem_map]
    exact ⟨fun v => charTypeFin N M (env v), Finset.mem_toList.mpr (Finset.mem_univ _), rfl⟩
  · -- efSatFin with witness chain `env`
    refine ⟨env, h, ?_, ?_, ?_, ?_, ?_⟩
    · intro k; rfl
    · intro j; exact partialHolds_charTypeFin N M (env j)
    · intro y _; exact intervalHoldsFin_top N y
    · intro i y _ _; exact intervalHoldsFin_top N y
    · intro y _; exact intervalHoldsFin_top N y

/-! ### 11.3 `M`-relative cross-consistency of a lift merge -/

/-- Fin mirror of `LiftMergePair.crossConsistent`: at every merged point `j` that is not one of
`ξ`'s existential points, the `M`-relative completion `σ j` assigned there is admissible to
`ξ`'s partial interval type at that slot. The membership is now `ξ.M`-relative — the
point-vs-interval axis of Lemma 3.2(1) (p.4) on the per-formula representation. -/
def liftCrossConsistentFin {s r K : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ s)
    (m : LiftMergePair ξ.n r K) (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M) : Prop :=
  ∀ j : Fin (K + 1), (∀ i, m.eξ i ≠ j) → σ j ∈ ξ.intervalType (intervalSlot m.eξ j)

/-! ### 11.4 The merged Fin formula -/

open Classical in
/-- Fin mirror of `liftMergedPointType`: `ξ`'s partial point type when `j` is one of `ξ`'s
existential points `eξ i`, and the ranged-over `M`-relative completion `σ j` at an inserted
skeleton point. -/
noncomputable def liftMergedPointTypeFin {s K : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ s)
    (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M) (eξ : Fin (ξ.n + 1) → Fin (K + 1))
    (j : Fin (K + 1)) : UnaryTypeFin sig₀ F₀ ξ.M :=
  if h : ∃ i, eξ i = j then ξ.pointType h.choose else σ j

/-- Fin mirror of `liftMergedPointType_xi`: at `ξ`'s existential point `eξ i`, the merged point
type is exactly `ξ.pointType i`. -/
theorem liftMergedPointTypeFin_xi {s K : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ s)
    (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M) (eξ : Fin (ξ.n + 1) → Fin (K + 1))
    (heξ : StrictMono eξ) (i : Fin (ξ.n + 1)) :
    liftMergedPointTypeFin ξ σ eξ (eξ i) = ξ.pointType i := by
  have hex : ∃ i', eξ i' = eξ i := ⟨i, rfl⟩
  simp only [liftMergedPointTypeFin, dif_pos hex]
  congr 1
  exact heξ.injective hex.choose_spec

/-- Fin mirror of `liftMergedPointType_skel`: at a merged point that is not one of `ξ`'s
existential points, the merged point type is the completion `σ j`. -/
theorem liftMergedPointTypeFin_skel {s K : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ s)
    (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M) (eξ : Fin (ξ.n + 1) → Fin (K + 1))
    (j : Fin (K + 1)) (hj : ∀ i, eξ i ≠ j) :
    liftMergedPointTypeFin ξ σ eξ j = σ j := by
  have hnex : ¬ ∃ i, eξ i = j := by rintro ⟨i, hi⟩; exact hj i hi
  simp only [liftMergedPointTypeFin, dif_neg hnex]

/-- Fin mirror of `liftMergedFormula`: the merged per-formula `∃∀`-formula of a lift merge datum
`m` and `M`-relative completion assignment `σ` — `K+1` points over `ξ`'s own mentioned-atom set
`ξ.M`; context variables pinned through `m.eS`; each point carrying `liftMergedPointTypeFin`;
each interval slot carrying `ξ`'s partial interval set `chainIntervalTypeFin ξ m.eξ t` (the
skeleton contributes ⊤, which drops out). -/
noncomputable def liftMergedFormulaFin {s r K : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ s)
    (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M) (m : LiftMergePair ξ.n r K) :
    ExistsForallFormulaFin sig₀ F₀ r where
  n := K
  M := ξ.M
  pin := m.eS
  pointType := fun j => liftMergedPointTypeFin ξ σ m.eξ j
  intervalType := fun t => chainIntervalTypeFin ξ m.eξ t

/-! ### 11.5 `liftPairFin` and its membership interface -/

open Classical in
/-- Fin mirror of `liftPair` (Rabinovich Lemma 3.2(1), p.4 — arity lift of a ≤2-free-variable
disjunct, per-formula representation): all valid order-preserving insertions of the `r` context
points into `ξ`'s chain, over all merged sizes `K+1 ≤ (ξ.n+1)+r` and all cross-consistent
`M`-relative completion assignments. Both `Finset.univ`s are finite from the chain lengths and
`ξ.M` alone. -/
noncomputable def liftPairFin {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 2) (k l : Fin r) :
    VeeExistsForallFin sig₀ F₀ r :=
  (List.range (ξ.n + r + 1)).flatMap fun K =>
    (Finset.univ.filter fun m : LiftMergePair ξ.n r K => m.valid ξ.pin k l).toList.flatMap fun m =>
      ((Finset.univ : Finset (Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M)).filter fun σ =>
          liftCrossConsistentFin ξ m σ).toList.map fun σ => liftMergedFormulaFin ξ σ m

/-- Fin mirror of `liftMergedFormula_mem_liftPair`: a valid, cross-consistent lift merge of size
`K+1` under the enumeration bound contributes its merged Fin formula as a disjunct. -/
theorem liftMergedFormulaFin_mem_liftPairFin {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 2)
    (k l : Fin r) {K : Nat} (hK : K < ξ.n + r + 1) (m : LiftMergePair ξ.n r K)
    (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M)
    (hvalid : m.valid ξ.pin k l) (hcc : liftCrossConsistentFin ξ m σ) :
    liftMergedFormulaFin ξ σ m ∈ liftPairFin ξ k l := by
  classical
  unfold liftPairFin
  rw [List.mem_flatMap]
  refine ⟨K, List.mem_range.mpr hK, ?_⟩
  rw [List.mem_flatMap]
  refine ⟨m, ?_, ?_⟩
  · rw [Finset.mem_toList, Finset.mem_filter]
    exact ⟨Finset.mem_univ _, hvalid⟩
  · rw [List.mem_map]
    refine ⟨σ, ?_, rfl⟩
    rw [Finset.mem_toList, Finset.mem_filter]
    exact ⟨Finset.mem_univ _, hcc⟩

/-- Fin mirror of `exists_liftMergePair_of_mem`: every disjunct of `liftPairFin` is the merged
Fin formula of some valid, cross-consistent lift merge. -/
theorem exists_liftMergePairFin_of_mem {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 2)
    (k l : Fin r) (φ : ExistsForallFormulaFin sig₀ F₀ r) (hφ : φ ∈ liftPairFin ξ k l) :
    ∃ (K : Nat) (m : LiftMergePair ξ.n r K) (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M),
      m.valid ξ.pin k l ∧ liftCrossConsistentFin ξ m σ ∧ liftMergedFormulaFin ξ σ m = φ := by
  classical
  unfold liftPairFin at hφ
  rw [List.mem_flatMap] at hφ
  obtain ⟨K, _, hφK⟩ := hφ
  rw [List.mem_flatMap] at hφK
  obtain ⟨m, hmvalid, hφm⟩ := hφK
  rw [List.mem_map] at hφm
  obtain ⟨σ, hσcc, hmf⟩ := hφm
  rw [Finset.mem_toList, Finset.mem_filter] at hmvalid
  rw [Finset.mem_toList, Finset.mem_filter] at hσcc
  exact ⟨K, m, σ, hmvalid.2, hσcc.2, hmf⟩

/-! ### 11.6 Forward and backward directions of the per-formula arity lift

Verbatim transcriptions of §5-7 onto the partial relations: the sorted-union merge, the rank
maps, and every order-theoretic step are alphabet-free (`strictMono_rank`,
`orderEmbOfFin_symm_apply`, `rank_orderEmbOfFin`, `strictMono_lt_iff_val_lt_filterCard`); the
only representation-sensitive steps swap `nf_eval_unique` for `partialHolds_eq_charTypeFin` and
the §6c slot-placement layer for its §10.4 Fin mirrors. -/

/-- Fin mirror of `liftPair_forward`: if `ξ` is satisfied at the pair `![env k, env l]`, its
`liftPairFin` is satisfied at `env` — merge `ξ`'s witness chain with the skeleton points via
their sorted union, taking `σ` = the characteristic completion over `ξ.M` at each merged
point. -/
theorem liftPairFin_forward {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (h : StrictMono env) (ξ : ExistsForallFormulaFin sig₀ F₀ 2)
    (k l : Fin r) (hξ : efSatFin N ![env k, env l] ξ) :
    veeSatFin N env (liftPairFin ξ k l) := by
  classical
  obtain ⟨xξ, hxmono, hxpin, hxpt, hxbefore, hxbetw, hxafter⟩ := hξ
  have hpin0 : env k = xξ (ξ.pin 0) := by have := hxpin 0; simpa using this
  have hpin1 : env l = xξ (ξ.pin 1) := by have := hxpin 1; simpa using this
  -- Sorted-union carrier of `xξ` and the skeleton `env`.
  set S := Finset.univ.image xξ ∪ Finset.univ.image env with hSdef
  have hmemξ : ∀ i, xξ i ∈ S := fun i => by
    simp only [hSdef, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
    exact Or.inl ⟨i, rfl⟩
  have hmemS : ∀ v, env v ∈ S := fun v => by
    simp only [hSdef, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
    exact Or.inr ⟨v, rfl⟩
  have hne : S.Nonempty := ⟨xξ 0, hmemξ 0⟩
  have hcard : S.card = (S.card - 1) + 1 := (Nat.succ_pred_eq_of_pos (Finset.card_pos.mpr hne)).symm
  set K := S.card - 1 with hKdef
  -- The merged chain and the two rank maps.
  let w : Fin (K + 1) → N.carrier := fun j => S.orderEmbOfFin hcard j
  let eξ : Fin (ξ.n + 1) → Fin (K + 1) := fun i => (S.orderIsoOfFin hcard).symm ⟨xξ i, hmemξ i⟩
  let eS : Fin r → Fin (K + 1) := fun v => (S.orderIsoOfFin hcard).symm ⟨env v, hmemS v⟩
  have hw : StrictMono w := (S.orderEmbOfFin hcard).strictMono
  have heξ : StrictMono eξ := strictMono_rank S hcard xξ hxmono hmemξ
  have heS : StrictMono eS := strictMono_rank S hcard env h hmemS
  have hrtξ : ∀ i, w (eξ i) = xξ i := fun i => orderEmbOfFin_symm_apply S hcard (xξ i) (hmemξ i)
  have hrtS : ∀ v, w (eS v) = env v := fun v => orderEmbOfFin_symm_apply S hcard (env v) (hmemS v)
  -- Joint surjectivity of the two rank maps.
  have hsurj : ∀ j : Fin (K + 1), (∃ i, eξ i = j) ∨ (∃ i, eS i = j) := by
    intro j
    have hmemj : S.orderEmbOfFin hcard j ∈ S := Finset.orderEmbOfFin_mem S hcard j
    have hmemj' := hmemj
    simp only [hSdef, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and] at hmemj'
    rcases hmemj' with ⟨i, hi⟩ | ⟨i, hi⟩
    · refine Or.inl ⟨i, ?_⟩
      change (S.orderIsoOfFin hcard).symm ⟨xξ i, hmemξ i⟩ = j
      rw [show (⟨xξ i, hmemξ i⟩ : {a // a ∈ S})
            = ⟨S.orderEmbOfFin hcard j, hmemj⟩ from Subtype.ext hi]
      exact rank_orderEmbOfFin S hcard j hmemj
    · refine Or.inr ⟨i, ?_⟩
      change (S.orderIsoOfFin hcard).symm ⟨env i, hmemS i⟩ = j
      rw [show (⟨env i, hmemS i⟩ : {a // a ∈ S})
            = ⟨S.orderEmbOfFin hcard j, hmemj⟩ from Subtype.ext hi]
      exact rank_orderEmbOfFin S hcard j hmemj
  -- The `k,l` pin coincidences.
  have hcoin_k : eS k = eξ (ξ.pin 0) := by
    change (S.orderIsoOfFin hcard).symm ⟨env k, hmemS k⟩
       = (S.orderIsoOfFin hcard).symm ⟨xξ (ξ.pin 0), hmemξ (ξ.pin 0)⟩
    congr 1; exact Subtype.ext hpin0
  have hcoin_l : eS l = eξ (ξ.pin 1) := by
    change (S.orderIsoOfFin hcard).symm ⟨env l, hmemS l⟩
       = (S.orderIsoOfFin hcard).symm ⟨xξ (ξ.pin 1), hmemξ (ξ.pin 1)⟩
    congr 1; exact Subtype.ext hpin1
  -- Interval-slot cardinality bound for `ξ`.
  have hlt_bound : ∀ y : N.carrier, (Finset.univ.filter (fun i => xξ i < y)).card < ξ.n + 2 := by
    intro y
    have hb := Finset.card_filter_le (Finset.univ : Finset (Fin (ξ.n + 1))) (fun i => xξ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at hb; omega
  -- Cross-consistency: the characteristic completion at each inserted point is admissible.
  have hcc : liftCrossConsistentFin ξ ⟨eξ, eS⟩ (fun j => charTypeFin N ξ.M (w j)) := by
    intro j hj
    have hynotx : ∀ i, w j ≠ xξ i := by
      intro i heq
      exact hj i (hw.injective (by rw [hrtξ i]; exact heq.symm))
    have hclause := chain_interval_clauseFin N ξ xξ hxmono hxbefore hxbetw hxafter (w j)
      (fun i => hynotx i) (hlt_bound (w j))
    change charTypeFin N ξ.M (w j) ∈ ξ.intervalType (intervalSlot eξ j)
    rw [intervalSlot_eq_pointSlotFin N ξ eξ xξ w hw hrtξ j (w j) rfl (hlt_bound (w j))]
    obtain ⟨c, hcS, hchold⟩ := hclause
    rw [← partialHolds_eq_charTypeFin N hchold]
    exact hcS
  -- Enumeration bound.
  have hK : K < ξ.n + r + 1 := by
    have hcu : S.card ≤ (Finset.univ.image xξ).card + (Finset.univ.image env).card := by
      rw [hSdef]; exact Finset.card_union_le _ _
    have h1 : (Finset.univ.image xξ).card ≤ ξ.n + 1 := by
      have := Finset.card_image_le (s := (Finset.univ : Finset (Fin (ξ.n + 1)))) (f := xξ)
      simpa using this
    have h2 : (Finset.univ.image env).card ≤ r := by
      have := Finset.card_image_le (s := (Finset.univ : Finset (Fin r))) (f := env)
      simpa using this
    omega
  -- The merged interval clause (single source `ξ`).
  have merged_clause : ∀ (y : N.carrier) (t : Fin (K + 2)),
      (∀ j, y ≠ w j) → t.val = (Finset.univ.filter (fun j => w j < y)).card →
      intervalHoldsFin N (chainIntervalTypeFin ξ eξ t) y := by
    intro y t hyne ht
    have hyx : ∀ i, y ≠ xξ i := fun i => by rw [← hrtξ i]; exact hyne (eξ i)
    rw [chainIntervalTypeFin_eq_pointSlot N ξ eξ xξ w hw hrtξ y t ht (hlt_bound y)]
    exact chain_interval_clauseFin N ξ xξ hxmono hxbefore hxbetw hxafter y hyx (hlt_bound y)
  -- Assemble the satisfied disjunct.
  refine ⟨liftMergedFormulaFin ξ (fun j => charTypeFin N ξ.M (w j)) ⟨eξ, eS⟩, ?_, ?_⟩
  · exact liftMergedFormulaFin_mem_liftPairFin ξ k l hK ⟨eξ, eS⟩
      (fun j => charTypeFin N ξ.M (w j)) ⟨heξ, heS, hsurj, hcoin_k, hcoin_l⟩ hcc
  · refine ⟨w, hw, ?_, ?_, ?_, ?_, ?_⟩
    · -- pinning
      intro v
      change env v = w (eS v)
      exact (hrtS v).symm
    · -- point types
      intro j
      change partialHolds N (liftMergedPointTypeFin ξ (fun j => charTypeFin N ξ.M (w j)) eξ j) (w j)
      by_cases hj : ∃ i, eξ i = j
      · obtain ⟨i, hi⟩ := hj
        rw [← hi, liftMergedPointTypeFin_xi ξ _ eξ heξ i, hrtξ i]
        exact hxpt i
      · push Not at hj
        rw [liftMergedPointTypeFin_skel ξ _ eξ j hj]
        exact partialHolds_charTypeFin N ξ.M (w j)
    · -- before x₀
      intro y hy0
      have hyne : ∀ j, y ≠ w j :=
        fun j => ne_of_lt (lt_of_lt_of_le hy0 (hw.monotone (Fin.zero_le j)))
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = 0 := by
        have hlt0 := (strictMono_lt_iff_val_lt_filterCard w hw y 0).not.mp
          (not_lt.mpr (le_of_lt hy0))
        rw [Fin.val_zero] at hlt0; omega
      exact merged_clause y 0 hyne (by rw [hcnt]; rfl)
    · -- between
      intro i₀ y hlo hhi
      have hyne : ∀ j, y ≠ w j := by
        intro j heq
        subst heq
        have ha := hw.lt_iff_lt.mp hlo
        have hb := hw.lt_iff_lt.mp hhi
        -- `rw [Fin.lt_def]` no longer matches here: the ambient `<` on `Fin (K + 1)` arrives as
        -- `Fin.instLinearOrder.toLT`, while `Fin.lt_def` is stated at `instLTFin`. `rw` matches
        -- only up to reducible/instances transparency and so does not see through the instance
        -- path. Coercing term-level unifies the two at default transparency instead.
        have ha' : (i₀.castSucc : ℕ) < (j : ℕ) := ha
        have hb' : (j : ℕ) < (i₀.succ : ℕ) := hb
        simp only [Fin.val_castSucc, Fin.val_succ] at ha' hb'
        omega
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = i₀.val + 1 := by
        have hlo' := (strictMono_lt_iff_val_lt_filterCard w hw y i₀.castSucc).mp hlo
        rw [Fin.val_castSucc] at hlo'
        have hhi' := (strictMono_lt_iff_val_lt_filterCard w hw y i₀.succ).not.mp
          (not_lt.mpr (le_of_lt hhi))
        rw [Fin.val_succ] at hhi'; omega
      exact merged_clause y i₀.succ.castSucc hyne (by rw [Fin.val_castSucc, Fin.val_succ]; omega)
    · -- after xₙ
      intro y hlast
      have hyne : ∀ j, y ≠ w j := by
        intro j heq
        subst heq
        exact absurd hlast (not_lt.mpr (hw.monotone (Fin.le_last j)))
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = K + 1 := by
        have hla := (strictMono_lt_iff_val_lt_filterCard w hw y (Fin.last K)).mp hlast
        rw [Fin.val_last] at hla
        have hle : (Finset.univ.filter (fun j => w j < y)).card ≤ K + 1 := by
          have hb := Finset.card_filter_le (Finset.univ : Finset (Fin (K + 1))) (fun j => w j < y)
          simp only [Finset.card_univ, Fintype.card_fin] at hb; omega
        omega
      exact merged_clause y (Fin.last (K + 1)) hyne (by rw [Fin.val_last]; omega)

/-- Fin mirror of `liftPair_backward`: if `liftPairFin ξ k l` is satisfied at `env`, then `ξ` is
satisfied at the pair `![env k, env l]` — project `ξ`'s chain out of a satisfied disjunct; at an
inserted skeleton point the `M`-relative cross-consistency supplies the admissible completion. -/
theorem liftPairFin_backward {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (ξ : ExistsForallFormulaFin sig₀ F₀ 2) (k l : Fin r)
    (hv : veeSatFin N env (liftPairFin ξ k l)) :
    efSatFin N ![env k, env l] ξ := by
  classical
  obtain ⟨φ, hφmem, hef⟩ := hv
  obtain ⟨K, m, σ, hvalid, hcc, hmf⟩ := exists_liftMergePairFin_of_mem ξ k l φ hφmem
  rw [← hmf] at hef
  obtain ⟨heξ, heS, hsurj, hcoin_k, hcoin_l⟩ := hvalid
  set eξ := m.eξ with heξdef
  set eS := m.eS with heSdef
  obtain ⟨w, hw, hwpin, hwpt, hwbefore, hwbetw, hwafter⟩ := hef
  -- Projected `ξ` chain.
  let xξ : Fin (ξ.n + 1) → N.carrier := fun i => w (eξ i)
  have hxmono : StrictMono xξ := hw.comp heξ
  have hlt_bound : ∀ y : N.carrier, (Finset.univ.filter (fun i => xξ i < y)).card < ξ.n + 2 := by
    intro y
    have hb := Finset.card_filter_le (Finset.univ : Finset (Fin (ξ.n + 1))) (fun i => xξ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at hb; omega
  have hlt_bound_w : ∀ y : N.carrier, (Finset.univ.filter (fun j => w j < y)).card < K + 2 := by
    intro y
    -- Bound through `Finset.filter_subset` rather than `Finset.card_filter_le (univ : Finset
    -- (Fin (K + 1)))`. `w` is indexed by `Fin ((liftMergedFormulaFin ξ σ m).n + 1)`, which is
    -- only *definitionally* `Fin (K + 1)`; ascribing the `univ` to `Fin (K + 1)` produced two
    -- `card` terms that print identically but carry different `Fintype` instances and no longer
    -- unify at reducible transparency. Going through the subset keeps the goal's own index, and
    -- the residual `n + 1 ≤ K + 1` is discharged by `rfl`.
    refine lt_of_le_of_lt (Finset.card_le_card (Finset.filter_subset _ _)) ?_
    simp only [Finset.card_univ, Fintype.card_fin]
    exact Nat.lt_succ_of_le (Nat.le_of_eq rfl)
  -- Point-slot clause for the projected `ξ` chain.
  have hpts : ∀ (y : N.carrier), (∀ i, y ≠ xξ i) →
      intervalHoldsFin N (ξ.intervalType
        ⟨(Finset.univ.filter (fun i => xξ i < y)).card, hlt_bound y⟩) y := by
    intro y hyne
    by_cases hmerged : ∀ j, y ≠ w j
    · -- `y` not a merged point: `w`'s single-source interval clause + point-slot bridge.
      have hclause : intervalHoldsFin N
          (chainIntervalTypeFin ξ eξ
            ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩) y :=
        chain_interval_clauseFin N (liftMergedFormulaFin ξ σ m) w hw hwbefore hwbetw hwafter y
          hmerged (hlt_bound_w y)
      rw [chainIntervalTypeFin_eq_pointSlot N ξ eξ xξ w hw (fun i => rfl) y
          ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩ rfl
          (hlt_bound y)] at hclause
      exact hclause
    · -- `y = w j` is an inserted skeleton point interior to a `ξ`-interval.
      push Not at hmerged
      obtain ⟨j, hj⟩ := hmerged
      have hjnotxi : ∀ i, eξ i ≠ j := by
        intro i heq
        apply hyne i
        change y = w (eξ i)
        rw [heq]; exact hj
      have hmem : σ j ∈ ξ.intervalType (intervalSlot eξ j) := hcc j hjnotxi
      have hu : partialHolds N (σ j) y := by
        have hpt : partialHolds N (liftMergedPointTypeFin ξ σ eξ j) (w j) := hwpt j
        rw [liftMergedPointTypeFin_skel ξ σ eξ j hjnotxi] at hpt
        rw [hj]; exact hpt
      have hih : intervalHoldsFin N (ξ.intervalType (intervalSlot eξ j)) y := ⟨σ j, hmem, hu⟩
      rw [intervalSlot_eq_pointSlotFin N ξ eξ xξ w hw (fun i => rfl) j y hj.symm
          (hlt_bound y)] at hih
      exact hih
  -- Assemble `efSatFin N ![env k, env l] ξ`.
  refine ⟨xξ, hxmono, Fin.forall_fin_two.mpr ⟨?_, ?_⟩, ?_, ?_, ?_, ?_⟩
  · -- pin at k
    have hval : ![env k, env l] 0 = env k := by simp
    rw [hval]
    change env k = w (eξ (ξ.pin 0))
    rw [← hcoin_k]; exact hwpin k
  · -- pin at l
    have hval : ![env k, env l] 1 = env l := by simp
    rw [hval]
    change env l = w (eξ (ξ.pin 1))
    rw [← hcoin_l]; exact hwpin l
  · -- point types
    intro i
    have hpt : partialHolds N (liftMergedPointTypeFin ξ σ eξ (eξ i)) (w (eξ i)) := hwpt (eξ i)
    rw [liftMergedPointTypeFin_xi ξ σ eξ heξ i] at hpt
    exact hpt
  · exact (regions_of_pointSlotFin N ξ xξ hxmono hlt_bound hpts).1
  · exact (regions_of_pointSlotFin N ξ xξ hxmono hlt_bound hpts).2.1
  · exact (regions_of_pointSlotFin N ξ xξ hxmono hlt_bound hpts).2.2

/-- Fin mirror of `liftPair_iff`: for a strictly increasing environment, `liftPairFin ξ k l` is
satisfied at `env` exactly when `ξ` is satisfied at the pair `![env k, env l]`. -/
theorem liftPairFin_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (h : StrictMono env) (ξ : ExistsForallFormulaFin sig₀ F₀ 2)
    (k l : Fin r) (_hkl : k < l) :
    veeSatFin N env (liftPairFin ξ k l) ↔ efSatFin N ![env k, env l] ξ := by
  constructor
  · exact liftPairFin_backward N env ξ k l
  · exact liftPairFin_forward N env h ξ k l

/-- Fin mirror of `liftPairV`: lift an arity-2 per-formula `∨∃∀`-object disjunct-wise and
flatten. -/
noncomputable def liftPairVFin {r : Nat} (Ψ : VeeExistsForallFin sig₀ F₀ 2) (k l : Fin r) :
    VeeExistsForallFin sig₀ F₀ r :=
  Ψ.flatMap (fun ξ => liftPairFin ξ k l)

/-- Fin mirror of `liftPairV_iff`: per-disjunct `liftPairFin_iff` pushed through
`veeSatFin_flatMap`. -/
theorem liftPairVFin_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (h : StrictMono env) (Ψ : VeeExistsForallFin sig₀ F₀ 2)
    (k l : Fin r) (hkl : k < l) :
    veeSatFin N env (liftPairVFin Ψ k l) ↔ veeSatFin N ![env k, env l] Ψ := by
  unfold liftPairVFin
  rw [veeSatFin_flatMap]
  constructor
  · rintro ⟨ξ, hξmem, hξsat⟩
    exact ⟨ξ, hξmem, (liftPairFin_iff N env h ξ k l hkl).mp hξsat⟩
  · rintro ⟨ξ, hξmem, hξsat⟩
    exact ⟨ξ, hξmem, (liftPairFin_iff N env h ξ k l hkl).mpr hξsat⟩

/-! ### 11.7 Sentence lift (per-formula representation)

Fin mirror of §9: lift an arity-0 per-formula sentence to arity `r` with no pin coincidence
(`LiftMergePair.validS`, reused verbatim). -/

open Classical in
/-- Fin mirror of `liftSentence`: all valid insertions of the `r` context points into the
sentence `ξ`'s chain, over all merged sizes and cross-consistent `M`-relative completion
assignments. -/
noncomputable def liftSentenceFin {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 0) :
    VeeExistsForallFin sig₀ F₀ r :=
  (List.range (ξ.n + r + 1)).flatMap fun K =>
    (Finset.univ.filter fun m : LiftMergePair ξ.n r K => m.validS).toList.flatMap fun m =>
      ((Finset.univ : Finset (Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M)).filter fun σ =>
          liftCrossConsistentFin ξ m σ).toList.map fun σ => liftMergedFormulaFin ξ σ m

/-- Fin mirror of `liftMergedFormula_mem_liftSentence`. -/
theorem liftMergedFormulaFin_mem_liftSentenceFin {r : Nat}
    (ξ : ExistsForallFormulaFin sig₀ F₀ 0) {K : Nat} (hK : K < ξ.n + r + 1)
    (m : LiftMergePair ξ.n r K) (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M)
    (hvalid : m.validS) (hcc : liftCrossConsistentFin ξ m σ) :
    liftMergedFormulaFin ξ σ m ∈ liftSentenceFin (r := r) ξ := by
  classical
  unfold liftSentenceFin
  rw [List.mem_flatMap]
  refine ⟨K, List.mem_range.mpr hK, ?_⟩
  rw [List.mem_flatMap]
  refine ⟨m, ?_, ?_⟩
  · rw [Finset.mem_toList, Finset.mem_filter]
    exact ⟨Finset.mem_univ _, hvalid⟩
  · rw [List.mem_map]
    refine ⟨σ, ?_, rfl⟩
    rw [Finset.mem_toList, Finset.mem_filter]
    exact ⟨Finset.mem_univ _, hcc⟩

/-- Fin mirror of `exists_liftMergePairS_of_mem`. -/
theorem exists_liftMergePairSFin_of_mem {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 0)
    (φ : ExistsForallFormulaFin sig₀ F₀ r) (hφ : φ ∈ liftSentenceFin (r := r) ξ) :
    ∃ (K : Nat) (m : LiftMergePair ξ.n r K) (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M),
      m.validS ∧ liftCrossConsistentFin ξ m σ ∧ liftMergedFormulaFin ξ σ m = φ := by
  classical
  unfold liftSentenceFin at hφ
  rw [List.mem_flatMap] at hφ
  obtain ⟨K, _, hφK⟩ := hφ
  rw [List.mem_flatMap] at hφK
  obtain ⟨m, hmvalid, hφm⟩ := hφK
  rw [List.mem_map] at hφm
  obtain ⟨σ, hσcc, hmf⟩ := hφm
  rw [Finset.mem_toList, Finset.mem_filter] at hmvalid
  rw [Finset.mem_toList, Finset.mem_filter] at hσcc
  exact ⟨K, m, σ, hmvalid.2, hσcc.2, hmf⟩

/-- Fin mirror of `liftSentence_forward`: a satisfiable per-formula sentence lifts to every
strictly increasing environment. -/
theorem liftSentenceFin_forward {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (h : StrictMono env) (ξ : ExistsForallFormulaFin sig₀ F₀ 0)
    (hξ : efSatFin N ![] ξ) :
    veeSatFin N env (liftSentenceFin (r := r) ξ) := by
  classical
  obtain ⟨xξ, hxmono, _, hxpt, hxbefore, hxbetw, hxafter⟩ := hξ
  set S := Finset.univ.image xξ ∪ Finset.univ.image env with hSdef
  have hmemξ : ∀ i, xξ i ∈ S := fun i => by
    simp only [hSdef, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
    exact Or.inl ⟨i, rfl⟩
  have hmemS : ∀ v, env v ∈ S := fun v => by
    simp only [hSdef, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
    exact Or.inr ⟨v, rfl⟩
  have hne : S.Nonempty := ⟨xξ 0, hmemξ 0⟩
  have hcard : S.card = (S.card - 1) + 1 := (Nat.succ_pred_eq_of_pos (Finset.card_pos.mpr hne)).symm
  set K := S.card - 1 with hKdef
  let w : Fin (K + 1) → N.carrier := fun j => S.orderEmbOfFin hcard j
  let eξ : Fin (ξ.n + 1) → Fin (K + 1) := fun i => (S.orderIsoOfFin hcard).symm ⟨xξ i, hmemξ i⟩
  let eS : Fin r → Fin (K + 1) := fun v => (S.orderIsoOfFin hcard).symm ⟨env v, hmemS v⟩
  have hw : StrictMono w := (S.orderEmbOfFin hcard).strictMono
  have heξ : StrictMono eξ := strictMono_rank S hcard xξ hxmono hmemξ
  have heS : StrictMono eS := strictMono_rank S hcard env h hmemS
  have hrtξ : ∀ i, w (eξ i) = xξ i := fun i => orderEmbOfFin_symm_apply S hcard (xξ i) (hmemξ i)
  have hrtS : ∀ v, w (eS v) = env v := fun v => orderEmbOfFin_symm_apply S hcard (env v) (hmemS v)
  have hsurj : ∀ j : Fin (K + 1), (∃ i, eξ i = j) ∨ (∃ i, eS i = j) := by
    intro j
    have hmemj : S.orderEmbOfFin hcard j ∈ S := Finset.orderEmbOfFin_mem S hcard j
    have hmemj' := hmemj
    simp only [hSdef, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and] at hmemj'
    rcases hmemj' with ⟨i, hi⟩ | ⟨i, hi⟩
    · refine Or.inl ⟨i, ?_⟩
      change (S.orderIsoOfFin hcard).symm ⟨xξ i, hmemξ i⟩ = j
      rw [show (⟨xξ i, hmemξ i⟩ : {a // a ∈ S})
            = ⟨S.orderEmbOfFin hcard j, hmemj⟩ from Subtype.ext hi]
      exact rank_orderEmbOfFin S hcard j hmemj
    · refine Or.inr ⟨i, ?_⟩
      change (S.orderIsoOfFin hcard).symm ⟨env i, hmemS i⟩ = j
      rw [show (⟨env i, hmemS i⟩ : {a // a ∈ S})
            = ⟨S.orderEmbOfFin hcard j, hmemj⟩ from Subtype.ext hi]
      exact rank_orderEmbOfFin S hcard j hmemj
  have hlt_bound : ∀ y : N.carrier, (Finset.univ.filter (fun i => xξ i < y)).card < ξ.n + 2 := by
    intro y
    have hb := Finset.card_filter_le (Finset.univ : Finset (Fin (ξ.n + 1))) (fun i => xξ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at hb; omega
  have hcc : liftCrossConsistentFin ξ ⟨eξ, eS⟩ (fun j => charTypeFin N ξ.M (w j)) := by
    intro j hj
    have hynotx : ∀ i, w j ≠ xξ i := by
      intro i heq
      exact hj i (hw.injective (by rw [hrtξ i]; exact heq.symm))
    have hclause := chain_interval_clauseFin N ξ xξ hxmono hxbefore hxbetw hxafter (w j)
      (fun i => hynotx i) (hlt_bound (w j))
    change charTypeFin N ξ.M (w j) ∈ ξ.intervalType (intervalSlot eξ j)
    rw [intervalSlot_eq_pointSlotFin N ξ eξ xξ w hw hrtξ j (w j) rfl (hlt_bound (w j))]
    obtain ⟨c, hcS, hchold⟩ := hclause
    rw [← partialHolds_eq_charTypeFin N hchold]
    exact hcS
  have hK : K < ξ.n + r + 1 := by
    have hcu : S.card ≤ (Finset.univ.image xξ).card + (Finset.univ.image env).card := by
      rw [hSdef]; exact Finset.card_union_le _ _
    have h1 : (Finset.univ.image xξ).card ≤ ξ.n + 1 := by
      have := Finset.card_image_le (s := (Finset.univ : Finset (Fin (ξ.n + 1)))) (f := xξ)
      simpa using this
    have h2 : (Finset.univ.image env).card ≤ r := by
      have := Finset.card_image_le (s := (Finset.univ : Finset (Fin r))) (f := env)
      simpa using this
    omega
  have merged_clause : ∀ (y : N.carrier) (t : Fin (K + 2)),
      (∀ j, y ≠ w j) → t.val = (Finset.univ.filter (fun j => w j < y)).card →
      intervalHoldsFin N (chainIntervalTypeFin ξ eξ t) y := by
    intro y t hyne ht
    have hyx : ∀ i, y ≠ xξ i := fun i => by rw [← hrtξ i]; exact hyne (eξ i)
    rw [chainIntervalTypeFin_eq_pointSlot N ξ eξ xξ w hw hrtξ y t ht (hlt_bound y)]
    exact chain_interval_clauseFin N ξ xξ hxmono hxbefore hxbetw hxafter y hyx (hlt_bound y)
  refine ⟨liftMergedFormulaFin ξ (fun j => charTypeFin N ξ.M (w j)) ⟨eξ, eS⟩, ?_, ?_⟩
  · exact liftMergedFormulaFin_mem_liftSentenceFin ξ hK ⟨eξ, eS⟩
      (fun j => charTypeFin N ξ.M (w j)) ⟨heξ, heS, hsurj⟩ hcc
  · refine ⟨w, hw, ?_, ?_, ?_, ?_, ?_⟩
    · intro v
      change env v = w (eS v)
      exact (hrtS v).symm
    · intro j
      change partialHolds N (liftMergedPointTypeFin ξ (fun j => charTypeFin N ξ.M (w j)) eξ j) (w j)
      by_cases hj : ∃ i, eξ i = j
      · obtain ⟨i, hi⟩ := hj
        rw [← hi, liftMergedPointTypeFin_xi ξ _ eξ heξ i, hrtξ i]
        exact hxpt i
      · push Not at hj
        rw [liftMergedPointTypeFin_skel ξ _ eξ j hj]
        exact partialHolds_charTypeFin N ξ.M (w j)
    · intro y hy0
      have hyne : ∀ j, y ≠ w j :=
        fun j => ne_of_lt (lt_of_lt_of_le hy0 (hw.monotone (Fin.zero_le j)))
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = 0 := by
        have hlt0 := (strictMono_lt_iff_val_lt_filterCard w hw y 0).not.mp
          (not_lt.mpr (le_of_lt hy0))
        rw [Fin.val_zero] at hlt0; omega
      exact merged_clause y 0 hyne (by rw [hcnt]; rfl)
    · intro i₀ y hlo hhi
      have hyne : ∀ j, y ≠ w j := by
        intro j heq
        subst heq
        have ha := hw.lt_iff_lt.mp hlo
        have hb := hw.lt_iff_lt.mp hhi
        -- `rw [Fin.lt_def]` no longer matches here: the ambient `<` on `Fin (K + 1)` arrives as
        -- `Fin.instLinearOrder.toLT`, while `Fin.lt_def` is stated at `instLTFin`. `rw` matches
        -- only up to reducible/instances transparency and so does not see through the instance
        -- path. Coercing term-level unifies the two at default transparency instead.
        have ha' : (i₀.castSucc : ℕ) < (j : ℕ) := ha
        have hb' : (j : ℕ) < (i₀.succ : ℕ) := hb
        simp only [Fin.val_castSucc, Fin.val_succ] at ha' hb'
        omega
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = i₀.val + 1 := by
        have hlo' := (strictMono_lt_iff_val_lt_filterCard w hw y i₀.castSucc).mp hlo
        rw [Fin.val_castSucc] at hlo'
        have hhi' := (strictMono_lt_iff_val_lt_filterCard w hw y i₀.succ).not.mp
          (not_lt.mpr (le_of_lt hhi))
        rw [Fin.val_succ] at hhi'; omega
      exact merged_clause y i₀.succ.castSucc hyne (by rw [Fin.val_castSucc, Fin.val_succ]; omega)
    · intro y hlast
      have hyne : ∀ j, y ≠ w j := by
        intro j heq
        subst heq
        exact absurd hlast (not_lt.mpr (hw.monotone (Fin.le_last j)))
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = K + 1 := by
        have hla := (strictMono_lt_iff_val_lt_filterCard w hw y (Fin.last K)).mp hlast
        rw [Fin.val_last] at hla
        have hle : (Finset.univ.filter (fun j => w j < y)).card ≤ K + 1 := by
          have hb := Finset.card_filter_le (Finset.univ : Finset (Fin (K + 1))) (fun j => w j < y)
          simp only [Finset.card_univ, Fintype.card_fin] at hb; omega
        omega
      exact merged_clause y (Fin.last (K + 1)) hyne (by rw [Fin.val_last]; omega)

/-- Fin mirror of `liftSentence_backward`: a satisfied `liftSentenceFin` projects back to the
satisfiability of the sentence (vacuous pin clause). -/
theorem liftSentenceFin_backward {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (ξ : ExistsForallFormulaFin sig₀ F₀ 0)
    (hv : veeSatFin N env (liftSentenceFin (r := r) ξ)) :
    efSatFin N ![] ξ := by
  classical
  obtain ⟨φ, hφmem, hef⟩ := hv
  obtain ⟨K, m, σ, hvalid, hcc, hmf⟩ := exists_liftMergePairSFin_of_mem ξ φ hφmem
  rw [← hmf] at hef
  obtain ⟨heξ, heS, hsurj⟩ := hvalid
  set eξ := m.eξ with heξdef
  obtain ⟨w, hw, _, hwpt, hwbefore, hwbetw, hwafter⟩ := hef
  let xξ : Fin (ξ.n + 1) → N.carrier := fun i => w (eξ i)
  have hxmono : StrictMono xξ := hw.comp heξ
  have hlt_bound : ∀ y : N.carrier, (Finset.univ.filter (fun i => xξ i < y)).card < ξ.n + 2 := by
    intro y
    have hb := Finset.card_filter_le (Finset.univ : Finset (Fin (ξ.n + 1))) (fun i => xξ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at hb; omega
  have hlt_bound_w : ∀ y : N.carrier, (Finset.univ.filter (fun j => w j < y)).card < K + 2 := by
    intro y
    -- Bound through `Finset.filter_subset` rather than `Finset.card_filter_le (univ : Finset
    -- (Fin (K + 1)))`. `w` is indexed by `Fin ((liftMergedFormulaFin ξ σ m).n + 1)`, which is
    -- only *definitionally* `Fin (K + 1)`; ascribing the `univ` to `Fin (K + 1)` produced two
    -- `card` terms that print identically but carry different `Fintype` instances and no longer
    -- unify at reducible transparency. Going through the subset keeps the goal's own index, and
    -- the residual `n + 1 ≤ K + 1` is discharged by `rfl`.
    refine lt_of_le_of_lt (Finset.card_le_card (Finset.filter_subset _ _)) ?_
    simp only [Finset.card_univ, Fintype.card_fin]
    exact Nat.lt_succ_of_le (Nat.le_of_eq rfl)
  have hpts : ∀ (y : N.carrier), (∀ i, y ≠ xξ i) →
      intervalHoldsFin N (ξ.intervalType
        ⟨(Finset.univ.filter (fun i => xξ i < y)).card, hlt_bound y⟩) y := by
    intro y hyne
    by_cases hmerged : ∀ j, y ≠ w j
    · have hclause : intervalHoldsFin N
          (chainIntervalTypeFin ξ eξ
            ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩) y :=
        chain_interval_clauseFin N (liftMergedFormulaFin ξ σ m) w hw hwbefore hwbetw hwafter y
          hmerged (hlt_bound_w y)
      rw [chainIntervalTypeFin_eq_pointSlot N ξ eξ xξ w hw (fun i => rfl) y
          ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩ rfl
          (hlt_bound y)] at hclause
      exact hclause
    · push Not at hmerged
      obtain ⟨j, hj⟩ := hmerged
      have hjnotxi : ∀ i, eξ i ≠ j := by
        intro i heq
        apply hyne i
        change y = w (eξ i)
        rw [heq]; exact hj
      have hmem : σ j ∈ ξ.intervalType (intervalSlot eξ j) := hcc j hjnotxi
      have hu : partialHolds N (σ j) y := by
        have hpt : partialHolds N (liftMergedPointTypeFin ξ σ eξ j) (w j) := hwpt j
        rw [liftMergedPointTypeFin_skel ξ σ eξ j hjnotxi] at hpt
        rw [hj]; exact hpt
      have hih : intervalHoldsFin N (ξ.intervalType (intervalSlot eξ j)) y := ⟨σ j, hmem, hu⟩
      rw [intervalSlot_eq_pointSlotFin N ξ eξ xξ w hw (fun i => rfl) j y hj.symm
          (hlt_bound y)] at hih
      exact hih
  refine ⟨xξ, hxmono, ?_, ?_, ?_, ?_, ?_⟩
  · intro k; exact k.elim0
  · intro i
    have hpt : partialHolds N (liftMergedPointTypeFin ξ σ eξ (eξ i)) (w (eξ i)) := hwpt (eξ i)
    rw [liftMergedPointTypeFin_xi ξ σ eξ heξ i] at hpt
    exact hpt
  · exact (regions_of_pointSlotFin N ξ xξ hxmono hlt_bound hpts).1
  · exact (regions_of_pointSlotFin N ξ xξ hxmono hlt_bound hpts).2.1
  · exact (regions_of_pointSlotFin N ξ xξ hxmono hlt_bound hpts).2.2

/-- Fin mirror of `liftSentence_iff`: `liftSentenceFin ξ` is satisfied at a strictly increasing
`env` exactly when the per-formula sentence `ξ` is satisfiable (independent of `env`). -/
theorem liftSentenceFin_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (h : StrictMono env) (ξ : ExistsForallFormulaFin sig₀ F₀ 0) :
    veeSatFin N env (liftSentenceFin (r := r) ξ) ↔ efSatFin N ![] ξ := by
  constructor
  · exact liftSentenceFin_backward N env ξ
  · exact liftSentenceFin_forward N env h ξ

/-! ### 11.8 Single-variable lift (per-formula representation)

Fin mirror of §10: lift an arity-1 per-formula object with the one-coincidence
`LiftMergePair.valid1` (reused verbatim). No order gate — the diagonal is a genuine
one-free-variable condition. -/

open Classical in
/-- Fin mirror of `liftSingle`: all valid single-variable insertions of the `r` context points
into `ξ`'s chain, over all merged sizes and cross-consistent `M`-relative completion
assignments. -/
noncomputable def liftSingleFin {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 1) (k : Fin r) :
    VeeExistsForallFin sig₀ F₀ r :=
  (List.range (ξ.n + r + 1)).flatMap fun K =>
    (Finset.univ.filter fun m : LiftMergePair ξ.n r K => m.valid1 ξ.pin k).toList.flatMap fun m =>
      ((Finset.univ : Finset (Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M)).filter fun σ =>
          liftCrossConsistentFin ξ m σ).toList.map fun σ => liftMergedFormulaFin ξ σ m

/-- Fin mirror of `liftMergedFormula_mem_liftSingle`. -/
theorem liftMergedFormulaFin_mem_liftSingleFin {r : Nat}
    (ξ : ExistsForallFormulaFin sig₀ F₀ 1) (k : Fin r) {K : Nat} (hK : K < ξ.n + r + 1)
    (m : LiftMergePair ξ.n r K) (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M)
    (hvalid : m.valid1 ξ.pin k) (hcc : liftCrossConsistentFin ξ m σ) :
    liftMergedFormulaFin ξ σ m ∈ liftSingleFin ξ k := by
  classical
  unfold liftSingleFin
  rw [List.mem_flatMap]
  refine ⟨K, List.mem_range.mpr hK, ?_⟩
  rw [List.mem_flatMap]
  refine ⟨m, ?_, ?_⟩
  · rw [Finset.mem_toList, Finset.mem_filter]
    exact ⟨Finset.mem_univ _, hvalid⟩
  · rw [List.mem_map]
    refine ⟨σ, ?_, rfl⟩
    rw [Finset.mem_toList, Finset.mem_filter]
    exact ⟨Finset.mem_univ _, hcc⟩

/-- Fin mirror of `exists_liftMergePair1_of_mem`. -/
theorem exists_liftMergePair1Fin_of_mem {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 1)
    (k : Fin r) (φ : ExistsForallFormulaFin sig₀ F₀ r) (hφ : φ ∈ liftSingleFin ξ k) :
    ∃ (K : Nat) (m : LiftMergePair ξ.n r K) (σ : Fin (K + 1) → UnaryTypeFin sig₀ F₀ ξ.M),
      m.valid1 ξ.pin k ∧ liftCrossConsistentFin ξ m σ ∧ liftMergedFormulaFin ξ σ m = φ := by
  classical
  unfold liftSingleFin at hφ
  rw [List.mem_flatMap] at hφ
  obtain ⟨K, _, hφK⟩ := hφ
  rw [List.mem_flatMap] at hφK
  obtain ⟨m, hmvalid, hφm⟩ := hφK
  rw [List.mem_map] at hφm
  obtain ⟨σ, hσcc, hmf⟩ := hφm
  rw [Finset.mem_toList, Finset.mem_filter] at hmvalid
  rw [Finset.mem_toList, Finset.mem_filter] at hσcc
  exact ⟨K, m, σ, hmvalid.2, hσcc.2, hmf⟩

/-- Fin mirror of `liftSingle_forward`: if `ξ` is satisfied at `![env k]`, its `liftSingleFin`
is satisfied at `env` (single pin coincidence). -/
theorem liftSingleFin_forward {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (h : StrictMono env) (ξ : ExistsForallFormulaFin sig₀ F₀ 1)
    (k : Fin r) (hξ : efSatFin N ![env k] ξ) :
    veeSatFin N env (liftSingleFin ξ k) := by
  classical
  obtain ⟨xξ, hxmono, hxpin, hxpt, hxbefore, hxbetw, hxafter⟩ := hξ
  have hpin0 : env k = xξ (ξ.pin 0) := by have := hxpin 0; simpa using this
  set S := Finset.univ.image xξ ∪ Finset.univ.image env with hSdef
  have hmemξ : ∀ i, xξ i ∈ S := fun i => by
    simp only [hSdef, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
    exact Or.inl ⟨i, rfl⟩
  have hmemS : ∀ v, env v ∈ S := fun v => by
    simp only [hSdef, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and]
    exact Or.inr ⟨v, rfl⟩
  have hne : S.Nonempty := ⟨xξ 0, hmemξ 0⟩
  have hcard : S.card = (S.card - 1) + 1 := (Nat.succ_pred_eq_of_pos (Finset.card_pos.mpr hne)).symm
  set K := S.card - 1 with hKdef
  let w : Fin (K + 1) → N.carrier := fun j => S.orderEmbOfFin hcard j
  let eξ : Fin (ξ.n + 1) → Fin (K + 1) := fun i => (S.orderIsoOfFin hcard).symm ⟨xξ i, hmemξ i⟩
  let eS : Fin r → Fin (K + 1) := fun v => (S.orderIsoOfFin hcard).symm ⟨env v, hmemS v⟩
  have hw : StrictMono w := (S.orderEmbOfFin hcard).strictMono
  have heξ : StrictMono eξ := strictMono_rank S hcard xξ hxmono hmemξ
  have heS : StrictMono eS := strictMono_rank S hcard env h hmemS
  have hrtξ : ∀ i, w (eξ i) = xξ i := fun i => orderEmbOfFin_symm_apply S hcard (xξ i) (hmemξ i)
  have hrtS : ∀ v, w (eS v) = env v := fun v => orderEmbOfFin_symm_apply S hcard (env v) (hmemS v)
  have hsurj : ∀ j : Fin (K + 1), (∃ i, eξ i = j) ∨ (∃ i, eS i = j) := by
    intro j
    have hmemj : S.orderEmbOfFin hcard j ∈ S := Finset.orderEmbOfFin_mem S hcard j
    have hmemj' := hmemj
    simp only [hSdef, Finset.mem_union, Finset.mem_image, Finset.mem_univ, true_and] at hmemj'
    rcases hmemj' with ⟨i, hi⟩ | ⟨i, hi⟩
    · refine Or.inl ⟨i, ?_⟩
      change (S.orderIsoOfFin hcard).symm ⟨xξ i, hmemξ i⟩ = j
      rw [show (⟨xξ i, hmemξ i⟩ : {a // a ∈ S})
            = ⟨S.orderEmbOfFin hcard j, hmemj⟩ from Subtype.ext hi]
      exact rank_orderEmbOfFin S hcard j hmemj
    · refine Or.inr ⟨i, ?_⟩
      change (S.orderIsoOfFin hcard).symm ⟨env i, hmemS i⟩ = j
      rw [show (⟨env i, hmemS i⟩ : {a // a ∈ S})
            = ⟨S.orderEmbOfFin hcard j, hmemj⟩ from Subtype.ext hi]
      exact rank_orderEmbOfFin S hcard j hmemj
  have hcoin_k : eS k = eξ (ξ.pin 0) := by
    change (S.orderIsoOfFin hcard).symm ⟨env k, hmemS k⟩
       = (S.orderIsoOfFin hcard).symm ⟨xξ (ξ.pin 0), hmemξ (ξ.pin 0)⟩
    congr 1; exact Subtype.ext hpin0
  have hlt_bound : ∀ y : N.carrier, (Finset.univ.filter (fun i => xξ i < y)).card < ξ.n + 2 := by
    intro y
    have hb := Finset.card_filter_le (Finset.univ : Finset (Fin (ξ.n + 1))) (fun i => xξ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at hb; omega
  have hcc : liftCrossConsistentFin ξ ⟨eξ, eS⟩ (fun j => charTypeFin N ξ.M (w j)) := by
    intro j hj
    have hynotx : ∀ i, w j ≠ xξ i := by
      intro i heq
      exact hj i (hw.injective (by rw [hrtξ i]; exact heq.symm))
    have hclause := chain_interval_clauseFin N ξ xξ hxmono hxbefore hxbetw hxafter (w j)
      (fun i => hynotx i) (hlt_bound (w j))
    change charTypeFin N ξ.M (w j) ∈ ξ.intervalType (intervalSlot eξ j)
    rw [intervalSlot_eq_pointSlotFin N ξ eξ xξ w hw hrtξ j (w j) rfl (hlt_bound (w j))]
    obtain ⟨c, hcS, hchold⟩ := hclause
    rw [← partialHolds_eq_charTypeFin N hchold]
    exact hcS
  have hK : K < ξ.n + r + 1 := by
    have hcu : S.card ≤ (Finset.univ.image xξ).card + (Finset.univ.image env).card := by
      rw [hSdef]; exact Finset.card_union_le _ _
    have h1 : (Finset.univ.image xξ).card ≤ ξ.n + 1 := by
      have := Finset.card_image_le (s := (Finset.univ : Finset (Fin (ξ.n + 1)))) (f := xξ)
      simpa using this
    have h2 : (Finset.univ.image env).card ≤ r := by
      have := Finset.card_image_le (s := (Finset.univ : Finset (Fin r))) (f := env)
      simpa using this
    omega
  have merged_clause : ∀ (y : N.carrier) (t : Fin (K + 2)),
      (∀ j, y ≠ w j) → t.val = (Finset.univ.filter (fun j => w j < y)).card →
      intervalHoldsFin N (chainIntervalTypeFin ξ eξ t) y := by
    intro y t hyne ht
    have hyx : ∀ i, y ≠ xξ i := fun i => by rw [← hrtξ i]; exact hyne (eξ i)
    rw [chainIntervalTypeFin_eq_pointSlot N ξ eξ xξ w hw hrtξ y t ht (hlt_bound y)]
    exact chain_interval_clauseFin N ξ xξ hxmono hxbefore hxbetw hxafter y hyx (hlt_bound y)
  refine ⟨liftMergedFormulaFin ξ (fun j => charTypeFin N ξ.M (w j)) ⟨eξ, eS⟩, ?_, ?_⟩
  · exact liftMergedFormulaFin_mem_liftSingleFin ξ k hK ⟨eξ, eS⟩
      (fun j => charTypeFin N ξ.M (w j)) ⟨heξ, heS, hsurj, hcoin_k⟩ hcc
  · refine ⟨w, hw, ?_, ?_, ?_, ?_, ?_⟩
    · intro v
      change env v = w (eS v)
      exact (hrtS v).symm
    · intro j
      change partialHolds N (liftMergedPointTypeFin ξ (fun j => charTypeFin N ξ.M (w j)) eξ j) (w j)
      by_cases hj : ∃ i, eξ i = j
      · obtain ⟨i, hi⟩ := hj
        rw [← hi, liftMergedPointTypeFin_xi ξ _ eξ heξ i, hrtξ i]
        exact hxpt i
      · push Not at hj
        rw [liftMergedPointTypeFin_skel ξ _ eξ j hj]
        exact partialHolds_charTypeFin N ξ.M (w j)
    · intro y hy0
      have hyne : ∀ j, y ≠ w j :=
        fun j => ne_of_lt (lt_of_lt_of_le hy0 (hw.monotone (Fin.zero_le j)))
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = 0 := by
        have hlt0 := (strictMono_lt_iff_val_lt_filterCard w hw y 0).not.mp
          (not_lt.mpr (le_of_lt hy0))
        rw [Fin.val_zero] at hlt0; omega
      exact merged_clause y 0 hyne (by rw [hcnt]; rfl)
    · intro i₀ y hlo hhi
      have hyne : ∀ j, y ≠ w j := by
        intro j heq
        subst heq
        have ha := hw.lt_iff_lt.mp hlo
        have hb := hw.lt_iff_lt.mp hhi
        -- `rw [Fin.lt_def]` no longer matches here: the ambient `<` on `Fin (K + 1)` arrives as
        -- `Fin.instLinearOrder.toLT`, while `Fin.lt_def` is stated at `instLTFin`. `rw` matches
        -- only up to reducible/instances transparency and so does not see through the instance
        -- path. Coercing term-level unifies the two at default transparency instead.
        have ha' : (i₀.castSucc : ℕ) < (j : ℕ) := ha
        have hb' : (j : ℕ) < (i₀.succ : ℕ) := hb
        simp only [Fin.val_castSucc, Fin.val_succ] at ha' hb'
        omega
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = i₀.val + 1 := by
        have hlo' := (strictMono_lt_iff_val_lt_filterCard w hw y i₀.castSucc).mp hlo
        rw [Fin.val_castSucc] at hlo'
        have hhi' := (strictMono_lt_iff_val_lt_filterCard w hw y i₀.succ).not.mp
          (not_lt.mpr (le_of_lt hhi))
        rw [Fin.val_succ] at hhi'; omega
      exact merged_clause y i₀.succ.castSucc hyne (by rw [Fin.val_castSucc, Fin.val_succ]; omega)
    · intro y hlast
      have hyne : ∀ j, y ≠ w j := by
        intro j heq
        subst heq
        exact absurd hlast (not_lt.mpr (hw.monotone (Fin.le_last j)))
      have hcnt : (Finset.univ.filter (fun j => w j < y)).card = K + 1 := by
        have hla := (strictMono_lt_iff_val_lt_filterCard w hw y (Fin.last K)).mp hlast
        rw [Fin.val_last] at hla
        have hle : (Finset.univ.filter (fun j => w j < y)).card ≤ K + 1 := by
          have hb := Finset.card_filter_le (Finset.univ : Finset (Fin (K + 1))) (fun j => w j < y)
          simp only [Finset.card_univ, Fintype.card_fin] at hb; omega
        omega
      exact merged_clause y (Fin.last (K + 1)) hyne (by rw [Fin.val_last]; omega)

/-- Fin mirror of `liftSingle_backward`: a satisfied `liftSingleFin ξ k` projects back to `ξ`
satisfied at `![env k]` (single pin clause via `Fin.forall_fin_one`). -/
theorem liftSingleFin_backward {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (ξ : ExistsForallFormulaFin sig₀ F₀ 1) (k : Fin r)
    (hv : veeSatFin N env (liftSingleFin ξ k)) :
    efSatFin N ![env k] ξ := by
  classical
  obtain ⟨φ, hφmem, hef⟩ := hv
  obtain ⟨K, m, σ, hvalid, hcc, hmf⟩ := exists_liftMergePair1Fin_of_mem ξ k φ hφmem
  rw [← hmf] at hef
  obtain ⟨heξ, heS, hsurj, hcoin_k⟩ := hvalid
  set eξ := m.eξ with heξdef
  obtain ⟨w, hw, hwpin, hwpt, hwbefore, hwbetw, hwafter⟩ := hef
  let xξ : Fin (ξ.n + 1) → N.carrier := fun i => w (eξ i)
  have hxmono : StrictMono xξ := hw.comp heξ
  have hlt_bound : ∀ y : N.carrier, (Finset.univ.filter (fun i => xξ i < y)).card < ξ.n + 2 := by
    intro y
    have hb := Finset.card_filter_le (Finset.univ : Finset (Fin (ξ.n + 1))) (fun i => xξ i < y)
    simp only [Finset.card_univ, Fintype.card_fin] at hb; omega
  have hlt_bound_w : ∀ y : N.carrier, (Finset.univ.filter (fun j => w j < y)).card < K + 2 := by
    intro y
    -- Bound through `Finset.filter_subset` rather than `Finset.card_filter_le (univ : Finset
    -- (Fin (K + 1)))`. `w` is indexed by `Fin ((liftMergedFormulaFin ξ σ m).n + 1)`, which is
    -- only *definitionally* `Fin (K + 1)`; ascribing the `univ` to `Fin (K + 1)` produced two
    -- `card` terms that print identically but carry different `Fintype` instances and no longer
    -- unify at reducible transparency. Going through the subset keeps the goal's own index, and
    -- the residual `n + 1 ≤ K + 1` is discharged by `rfl`.
    refine lt_of_le_of_lt (Finset.card_le_card (Finset.filter_subset _ _)) ?_
    simp only [Finset.card_univ, Fintype.card_fin]
    exact Nat.lt_succ_of_le (Nat.le_of_eq rfl)
  have hpts : ∀ (y : N.carrier), (∀ i, y ≠ xξ i) →
      intervalHoldsFin N (ξ.intervalType
        ⟨(Finset.univ.filter (fun i => xξ i < y)).card, hlt_bound y⟩) y := by
    intro y hyne
    by_cases hmerged : ∀ j, y ≠ w j
    · have hclause : intervalHoldsFin N
          (chainIntervalTypeFin ξ eξ
            ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩) y :=
        chain_interval_clauseFin N (liftMergedFormulaFin ξ σ m) w hw hwbefore hwbetw hwafter y
          hmerged (hlt_bound_w y)
      rw [chainIntervalTypeFin_eq_pointSlot N ξ eξ xξ w hw (fun i => rfl) y
          ⟨(Finset.univ.filter (fun j => w j < y)).card, hlt_bound_w y⟩ rfl
          (hlt_bound y)] at hclause
      exact hclause
    · push Not at hmerged
      obtain ⟨j, hj⟩ := hmerged
      have hjnotxi : ∀ i, eξ i ≠ j := by
        intro i heq
        apply hyne i
        change y = w (eξ i)
        rw [heq]; exact hj
      have hmem : σ j ∈ ξ.intervalType (intervalSlot eξ j) := hcc j hjnotxi
      have hu : partialHolds N (σ j) y := by
        have hpt : partialHolds N (liftMergedPointTypeFin ξ σ eξ j) (w j) := hwpt j
        rw [liftMergedPointTypeFin_skel ξ σ eξ j hjnotxi] at hpt
        rw [hj]; exact hpt
      have hih : intervalHoldsFin N (ξ.intervalType (intervalSlot eξ j)) y := ⟨σ j, hmem, hu⟩
      rw [intervalSlot_eq_pointSlotFin N ξ eξ xξ w hw (fun i => rfl) j y hj.symm
          (hlt_bound y)] at hih
      exact hih
  refine ⟨xξ, hxmono, Fin.forall_fin_one.mpr ?_, ?_, ?_, ?_, ?_⟩
  · have hval : ![env k] 0 = env k := by simp
    rw [hval]
    change env k = w (eξ (ξ.pin 0))
    rw [← hcoin_k]; exact hwpin k
  · intro i
    have hpt : partialHolds N (liftMergedPointTypeFin ξ σ eξ (eξ i)) (w (eξ i)) := hwpt (eξ i)
    rw [liftMergedPointTypeFin_xi ξ σ eξ heξ i] at hpt
    exact hpt
  · exact (regions_of_pointSlotFin N ξ xξ hxmono hlt_bound hpts).1
  · exact (regions_of_pointSlotFin N ξ xξ hxmono hlt_bound hpts).2.1
  · exact (regions_of_pointSlotFin N ξ xξ hxmono hlt_bound hpts).2.2

/-- Fin mirror of `liftSingle_iff`: no order gate — the diagonal is a genuine one-free-variable
condition. -/
theorem liftSingleFin_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (h : StrictMono env) (ξ : ExistsForallFormulaFin sig₀ F₀ 1)
    (k : Fin r) :
    veeSatFin N env (liftSingleFin ξ k) ↔ efSatFin N ![env k] ξ := by
  constructor
  · exact liftSingleFin_backward N env ξ k
  · exact liftSingleFin_forward N env h ξ k

/-- Fin mirror of `liftSingleV`: lift an arity-1 per-formula `∨∃∀`-object disjunct-wise and
flatten. -/
noncomputable def liftSingleVFin {r : Nat} (Ψ : VeeExistsForallFin sig₀ F₀ 1) (k : Fin r) :
    VeeExistsForallFin sig₀ F₀ r :=
  Ψ.flatMap (fun ξ => liftSingleFin ξ k)

/-- Fin mirror of `liftSingleV_iff`: per-disjunct `liftSingleFin_iff` pushed through
`veeSatFin_flatMap`. -/
theorem liftSingleVFin_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig₀ F₀))
    (env : Fin r → N.carrier) (h : StrictMono env) (Ψ : VeeExistsForallFin sig₀ F₀ 1)
    (k : Fin r) :
    veeSatFin N env (liftSingleVFin Ψ k) ↔ veeSatFin N ![env k] Ψ := by
  unfold liftSingleVFin
  rw [veeSatFin_flatMap]
  constructor
  · rintro ⟨ξ, hξmem, hξsat⟩
    exact ⟨ξ, hξmem, (liftSingleFin_iff N env h ξ k).mp hξsat⟩
  · rintro ⟨ξ, hξmem, hξsat⟩
    exact ⟨ξ, hξmem, (liftSingleFin_iff N env h ξ k).mpr hξsat⟩

/-! ### 11.9 Pin-monotonicity of the Fin skeleton and arity lifts (T1 invariant support)

Fin mirrors of §10's pin lemmas: the skeleton pins are `id`, and each lift disjunct's pin is
`m.eS`, forced `StrictMono` by the `valid`/`valid1`/`validS` clause — these feed the
monotone-pin invariant of the (Phase-4-gated) `Prop43Translate` Fin migration. -/

/-- `skelDisjunctFin`'s pin is the identity. -/
@[simp] theorem skelDisjunctFin_pin {M : Finset (AtomKind (sigE sig₀ F₀) 1)} {m : Nat}
    (σ : Fin (m + 1) → UnaryTypeFin sig₀ F₀ M) : (skelDisjunctFin M m σ).pin = id := rfl

/-- The identity-pinned Fin skeleton disjunct has a strictly monotone pin. -/
theorem skelDisjunctFin_pin_strictMono {M : Finset (AtomKind (sigE sig₀ F₀) 1)} {m : Nat}
    (σ : Fin (m + 1) → UnaryTypeFin sig₀ F₀ M) : StrictMono (skelDisjunctFin M m σ).pin := by
  rw [skelDisjunctFin_pin]; exact strictMono_id

/-- Every disjunct of `skelRFin` has a strictly monotone (identity) pin. -/
theorem skelRFin_pin_strictMono {M : Finset (AtomKind (sigE sig₀ F₀) 1)} {m : Nat}
    (φ : ExistsForallFormulaFin sig₀ F₀ (m + 1)) (hφ : φ ∈ skelRFin M m) :
    StrictMono φ.pin := by
  unfold skelRFin at hφ
  rw [List.mem_map] at hφ
  obtain ⟨σ, _, rfl⟩ := hφ
  exact skelDisjunctFin_pin_strictMono σ

/-- Every disjunct of `liftPairFin ξ k l` has a strictly monotone pin (`= m.eS`, from
`valid`). -/
theorem liftPairFin_pin_strictMono {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 2)
    (k l : Fin r) (φ : ExistsForallFormulaFin sig₀ F₀ r) (hφ : φ ∈ liftPairFin ξ k l) :
    StrictMono φ.pin := by
  obtain ⟨K, m, σ, hvalid, _, hmf⟩ := exists_liftMergePairFin_of_mem ξ k l φ hφ
  subst hmf
  exact hvalid.2.1

/-- Every disjunct of `liftPairVFin Ψ k l` has a strictly monotone pin. -/
theorem liftPairVFin_pin_strictMono {r : Nat} (Ψ : VeeExistsForallFin sig₀ F₀ 2) (k l : Fin r)
    (φ : ExistsForallFormulaFin sig₀ F₀ r) (hφ : φ ∈ liftPairVFin Ψ k l) :
    StrictMono φ.pin := by
  unfold liftPairVFin at hφ
  rw [List.mem_flatMap] at hφ
  obtain ⟨ξ, _, hφξ⟩ := hφ
  exact liftPairFin_pin_strictMono ξ k l φ hφξ

/-- Every disjunct of `liftSingleFin ξ k` has a strictly monotone pin (`= m.eS`, from
`valid1`). -/
theorem liftSingleFin_pin_strictMono {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 1)
    (k : Fin r) (φ : ExistsForallFormulaFin sig₀ F₀ r) (hφ : φ ∈ liftSingleFin ξ k) :
    StrictMono φ.pin := by
  obtain ⟨K, m, σ, hvalid, _, hmf⟩ := exists_liftMergePair1Fin_of_mem ξ k φ hφ
  subst hmf
  exact hvalid.2.1

/-- Every disjunct of `liftSingleVFin Ψ k` has a strictly monotone pin. -/
theorem liftSingleVFin_pin_strictMono {r : Nat} (Ψ : VeeExistsForallFin sig₀ F₀ 1) (k : Fin r)
    (φ : ExistsForallFormulaFin sig₀ F₀ r) (hφ : φ ∈ liftSingleVFin Ψ k) :
    StrictMono φ.pin := by
  unfold liftSingleVFin at hφ
  rw [List.mem_flatMap] at hφ
  obtain ⟨ξ, _, hφξ⟩ := hφ
  exact liftSingleFin_pin_strictMono ξ k φ hφξ

/-- Every disjunct of `liftSentenceFin ξ` has a strictly monotone pin (`= m.eS`, from
`validS`). -/
theorem liftSentenceFin_pin_strictMono {r : Nat} (ξ : ExistsForallFormulaFin sig₀ F₀ 0)
    (φ : ExistsForallFormulaFin sig₀ F₀ r) (hφ : φ ∈ liftSentenceFin (r := r) ξ) :
    StrictMono φ.pin := by
  obtain ⟨K, m, σ, hvalid, _, hmf⟩ := exists_liftMergePairSFin_of_mem ξ φ hφ
  subst hmf
  exact hvalid.2.1

end FinLayer

end Kamp

end Bimodal.Metalogic.WeakCanonical
