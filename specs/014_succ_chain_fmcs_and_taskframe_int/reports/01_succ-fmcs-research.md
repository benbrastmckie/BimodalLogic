# Research Report: Succ-Chain FMCS and TaskFrame Int Construction

**Task**: 14 - succ_chain_fmcs_and_taskframe_int
**Session**: sess_1774088087_283ed1
**Date**: 2026-03-21

---

## 1. Executive Summary

This research report provides implementation guidance for constructing a time-indexed FMCS family over Int from Succ-chains and instantiating `DiscreteCanonicalTaskFrame` using `CanonicalTask` as the task relation. The key findings are:

1. **FMCS Family Construction**: Build `fam : Int -> MCS` from a starting MCS using:
   - Forward enumeration via `successor_exists` (Task 12) for n >= 0
   - Backward enumeration via `predecessor_exists` (Task 12) for n < 0
   - Use `Classical.choose` to extract witnesses noncomputably

2. **FMCS Coherence**: The forward_G/backward_H properties follow from Succ's g_content/h_content propagation. The forward_F/backward_P properties follow from seriality + Succ existence.

3. **TaskFrame Instantiation**: Use `CanonicalTask` (Task 11) directly as the task relation for `DiscreteCanonicalTaskFrame`. The nullity_identity, forward_comp, and converse properties are already proven.

4. **WorldHistory respects_task**: Follows from the definition of `CanonicalTask` and the chain structure.

**Critical Blocking Factor**: None. All prerequisites from Tasks 10-12 are complete and sorry-free.

---

## 2. Prerequisites Analysis

### 2.1 Task 10 (Succ Relation) - COMPLETED

From `SuccRelation.lean`:

```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

Key theorems:
- `Succ_implies_CanonicalR`: G-persistence
- `Succ_implies_h_content_reverse`: g/h duality
- `single_step_forcing`: F-nesting depth to witness distance

### 2.2 Task 11 (CanonicalTask Relation) - COMPLETED

From `CanonicalTaskRelation.lean`:

```lean
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k => CanonicalTask_forward u k v
  | Int.negSucc k => CanonicalTask_backward u (k + 1) v
```

Key theorems proven:
- `CanonicalTask_nullity_identity`: task_rel w 0 u <-> w = u
- `CanonicalTask_forward_comp`: Forward chain concatenation
- `CanonicalTask_converse`: task_rel w n u <-> task_rel u (-n) w
- `bounded_witness`: F^n(phi) witness placement

### 2.3 Task 12 (Succ Existence) - COMPLETED (with axioms)

From `SuccExistence.lean`:

```lean
theorem successor_exists (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    ∃ v, SetMaximalConsistent v ∧ Succ u v

theorem predecessor_exists (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    ∃ v, SetMaximalConsistent v ∧ Pred u v
```

Uses axioms for deferral seed consistency (documented semantic justification).

### 2.4 Seriality Properties

From `CanonicalTimeline.lean`:

```lean
theorem SetMaximalConsistent.contains_seriality_future (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_future (Formula.neg Formula.bot) ∈ M

theorem SetMaximalConsistent.contains_seriality_past (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_past (Formula.neg Formula.bot) ∈ M
```

These ensure every MCS has F(top) and P(top), enabling successor/predecessor existence.

---

## 3. FMCS Family Construction

### 3.1 Design: Int-Indexed Chain from Starting MCS

Given a starting MCS `M0`, construct `fam : Int -> Set Formula`:

```lean
noncomputable def succ_chain_fam (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : Int -> Set Formula :=
  fun n => match n with
  | Int.ofNat 0 => M0
  | Int.ofNat (k + 1) =>
      let M_k := succ_chain_fam M0 h_mcs0 (Int.ofNat k)
      Classical.choose (successor_exists M_k (succ_chain_is_mcs M0 h_mcs0 k)
        (contains_seriality_future M_k (succ_chain_is_mcs M0 h_mcs0 k)))
  | Int.negSucc k =>
      let M_neg_k := succ_chain_fam M0 h_mcs0 (Int.negSucc (k - 1))  -- or handle base case
      Classical.choose (predecessor_exists M_neg_k ...)
```

**Issue**: Direct recursion on Int is problematic. Need well-founded recursion or split definition.

### 3.2 Recommended Approach: Split Forward/Backward

Define separately:

```lean
-- Forward chain from M0 (n >= 0)
noncomputable def forward_chain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : Nat -> Set Formula
  | 0 => M0
  | n + 1 =>
      let M_n := forward_chain M0 h_mcs0 n
      Classical.choose (successor_exists M_n (forward_chain_mcs M0 h_mcs0 n)
        (contains_seriality_future M_n (forward_chain_mcs M0 h_mcs0 n)))

-- Backward chain from M0 (n > 0 gives predecessor at index -n)
noncomputable def backward_chain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : Nat -> Set Formula
  | 0 => M0
  | n + 1 =>
      let M_n := backward_chain M0 h_mcs0 n
      Classical.choose (predecessor_exists M_n (backward_chain_mcs M0 h_mcs0 n)
        (contains_seriality_past M_n (backward_chain_mcs M0 h_mcs0 n)))

-- Combined Int-indexed family
noncomputable def succ_chain_fam (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Int) : Set Formula :=
  match n with
  | Int.ofNat k => forward_chain M0 h_mcs0 k
  | Int.negSucc k => backward_chain M0 h_mcs0 (k + 1)
```

### 3.3 MCS Property Propagation

Each element of the chain is an MCS by the existence theorems:

```lean
theorem forward_chain_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    SetMaximalConsistent (forward_chain M0 h_mcs0 n)

theorem backward_chain_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    SetMaximalConsistent (backward_chain M0 h_mcs0 n)

theorem succ_chain_fam_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Int) :
    SetMaximalConsistent (succ_chain_fam M0 h_mcs0 n)
```

Proofs by induction using `successor_from_deferral_seed_mcs` and `predecessor_from_deferral_seed_mcs`.

### 3.4 Succ/Pred Properties

The chain satisfies Succ/Pred by construction:

```lean
theorem forward_chain_succ (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    Succ (forward_chain M0 h_mcs0 n) (forward_chain M0 h_mcs0 (n + 1))

theorem backward_chain_pred (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    Succ (backward_chain M0 h_mcs0 (n + 1)) (backward_chain M0 h_mcs0 n)
```

These follow from `Classical.choose_spec` applied to `successor_exists`/`predecessor_exists`.

---

## 4. FMCS Coherence Properties

### 4.1 forward_G: Gφ at n implies φ at all m > n

**Strategy**: By Succ.g_persistence propagating through the chain.

```lean
theorem succ_chain_forward_G (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n m : Int) (phi : Formula) (h_lt : n < m) (h_G : Formula.all_future phi ∈ succ_chain_fam M0 h_mcs0 n) :
    phi ∈ succ_chain_fam M0 h_mcs0 m
```

**Proof Sketch**:
1. G(phi) ∈ fam(n) means G(G(phi)) ∈ fam(n) (by G4 axiom closure in MCS)
2. By Succ.g_persistence: G(phi) ∈ fam(n+1)
3. By induction: phi ∈ fam(m) for any m > n

### 4.2 backward_H: Hφ at n implies φ at all m < n

**Strategy**: Symmetric using Succ_implies_h_content_reverse.

```lean
theorem succ_chain_backward_H (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n m : Int) (phi : Formula) (h_lt : m < n) (h_H : Formula.all_past phi ∈ succ_chain_fam M0 h_mcs0 n) :
    phi ∈ succ_chain_fam M0 h_mcs0 m
```

### 4.3 forward_F: Fφ at n implies witness at some m > n

**Strategy**: Use successor_exists and single_step_forcing, or the structure of F-obligations.

```lean
theorem succ_chain_forward_F (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Int) (phi : Formula) (h_F : Formula.some_future phi ∈ succ_chain_fam M0 h_mcs0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 h_mcs0 m
```

**Proof Sketch**:
The F-obligation `F(phi) ∈ fam(n)` is resolved or deferred at each step. Since chains are infinite (seriality), the F-obligation must eventually be resolved. By the bounded witness theorem, if F^k(phi) ∈ u but F^(k+1)(phi) ∉ u, then phi appears at distance k.

Key insight: Use `bounded_witness` from CanonicalTaskRelation.lean to determine exact witness distance.

### 4.4 backward_P: Pφ at n implies witness at some m < n

**Strategy**: Symmetric via predecessor_exists.

---

## 5. DiscreteCanonicalTaskFrame Instantiation

### 5.1 Current DiscreteCanonicalTaskFrame

From `DiscreteInstantiation.lean`:

```lean
abbrev DiscreteCanonicalTaskFrame : TaskFrame Int :=
  ParametricCanonicalTaskFrame Int
```

This uses `CanonicalR` for the task relation, not `CanonicalTask`.

### 5.2 New TaskFrame Using CanonicalTask

Define a TaskFrame using `CanonicalTask` as the task relation:

```lean
def CanonicalTaskTaskFrame : TaskFrame Int where
  WorldState := Set Formula  -- or CanonicalMCS
  task_rel := fun w n u => CanonicalTask w n u
  nullity_identity := CanonicalTask_nullity_identity
  forward_comp := by
    intros w u v x y hx hy h1 h2
    -- Need Int version of compositionality
    -- x >= 0 and y >= 0 gives CanonicalTask_forward_comp_int
    sorry  -- Requires proof using Int arithmetic
  converse := CanonicalTask_converse
```

**Challenge**: The `forward_comp` axiom requires composition for non-negative Int, which needs careful handling of the Int.ofNat case.

### 5.3 TaskFrame Axiom Verification

| Axiom | CanonicalTask Property | Status |
|-------|------------------------|--------|
| nullity_identity | `CanonicalTask_nullity_identity` | Proven |
| forward_comp (restricted) | `CanonicalTask_forward_comp_int` | Proven for Nat |
| converse | `CanonicalTask_converse` | Proven |

**Gap**: Need to adapt `CanonicalTask_forward_comp_int` for Int with 0 <= x, 0 <= y restriction.

---

## 6. WorldHistory respects_task

### 6.1 Definition Review

From `WorldHistory.lean`:

```lean
respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
  s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

### 6.2 Constructing WorldHistory from Succ-Chain

Given a Succ-chain `fam : Int -> Set Formula`:

```lean
def succ_chain_history (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    WorldHistory CanonicalTaskTaskFrame where
  domain := fun _ => True  -- Full Int domain
  convex := by intros; trivial
  states := fun t _ => succ_chain_fam M0 h_mcs0 t
  respects_task := by
    intros s t hs ht hst
    -- Need: CanonicalTask (fam s) (t - s) (fam t)
    -- This follows from the chain structure
    sorry
```

### 6.3 Respects_task Proof Strategy

For `s <= t`:
1. Let `d = t - s >= 0`
2. Need `CanonicalTask (fam s) d (fam t)`
3. The chain structure gives `CanonicalTask_forward (fam s) d.toNat (fam t)`

**Key Lemma**:

```lean
theorem succ_chain_canonical_task (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n m : Int) (h_le : n ≤ m) :
    CanonicalTask (succ_chain_fam M0 h_mcs0 n) (m - n) (succ_chain_fam M0 h_mcs0 m)
```

Proof by induction on the distance `m - n`:
- Base (m = n): `CanonicalTask u 0 u` by nullity_identity
- Step: Use forward_chain_succ to extend the chain

---

## 7. Implementation Architecture

### 7.1 File Structure

```
Theories/Bimodal/Metalogic/Bundle/
├── SuccChainFMCS.lean          # Succ-chain FMCS construction
├── SuccChainTaskFrame.lean     # TaskFrame instantiation
└── SuccChainWorldHistory.lean  # WorldHistory construction
```

### 7.2 Module Dependencies

```
SuccChainFMCS.lean
  ├── SuccExistence.lean (Task 12)
  ├── CanonicalTaskRelation.lean (Task 11)
  ├── SuccRelation.lean (Task 10)
  └── CanonicalTimeline.lean (seriality)

SuccChainTaskFrame.lean
  ├── SuccChainFMCS.lean
  ├── TaskFrame.lean
  └── CanonicalTaskRelation.lean

SuccChainWorldHistory.lean
  ├── SuccChainFMCS.lean
  ├── SuccChainTaskFrame.lean
  └── WorldHistory.lean
```

### 7.3 Import Requirements

```lean
import Bimodal.Metalogic.Bundle.SuccExistence
import Bimodal.Metalogic.Bundle.CanonicalTaskRelation
import Bimodal.Metalogic.Canonical.CanonicalTimeline
import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.WorldHistory
import Mathlib.Data.Int.Basic
```

---

## 8. Complexity Assessment

| Component | Lines (Est.) | Difficulty | Blocking Risk |
|-----------|--------------|------------|---------------|
| forward_chain definition | 15 | Easy | None |
| backward_chain definition | 15 | Easy | None |
| succ_chain_fam definition | 10 | Easy | None |
| Chain MCS theorems | 30 | Moderate | None |
| forward_G/backward_H | 40 | Moderate | None |
| forward_F/backward_P | 60 | Hard | Low |
| FMCS structure | 20 | Easy | None |
| CanonicalTaskTaskFrame | 40 | Moderate | Low |
| WorldHistory construction | 30 | Moderate | None |
| respects_task proof | 50 | Moderate | Low |

**Total Estimated Lines**: 310-350
**Overall Difficulty**: Moderate
**Blocking Dependencies**: None - Tasks 10-12 complete

---

## 9. Potential Challenges and Mitigations

### 9.1 Int Recursion

**Challenge**: Lean's termination checker may struggle with Int-indexed recursion.

**Mitigation**: Use split Nat-indexed forward/backward chains, then combine.

### 9.2 Choice Function Well-Definedness

**Challenge**: `Classical.choose` returns a specific witness, but chain coherence needs witnesses to "match up".

**Mitigation**: The chain structure ensures coherence by construction. Each step extends from the previous step's result.

### 9.3 forward_comp for Int

**Challenge**: Current `CanonicalTask_forward_comp_int` works for Nat. Need Int version with non-negativity constraints.

**Mitigation**: Define:

```lean
theorem CanonicalTask_forward_comp_int_full (u w v : Set Formula) (m n : Int)
    (hm : 0 ≤ m) (hn : 0 ≤ n) :
    CanonicalTask u m w → CanonicalTask w n v → CanonicalTask u (m + n) v
```

Using `Int.toNat` conversion and existing Nat proof.

### 9.4 Coherence Property Proofs

**Challenge**: forward_F requires showing F-obligations eventually resolve.

**Mitigation**: Use bounded_witness theorem. For F(phi) ∈ fam(n), consider the F-nesting depth of phi. By the structure of chains, phi appears within bounded distance.

---

## 10. Implementation Order

### Phase 1: Forward/Backward Chain Construction
1. Define `forward_chain : Nat -> Set Formula`
2. Prove `forward_chain_mcs`
3. Prove `forward_chain_succ`
4. Define `backward_chain : Nat -> Set Formula`
5. Prove `backward_chain_mcs`
6. Prove `backward_chain_pred`

### Phase 2: Combined FMCS
1. Define `succ_chain_fam : Int -> Set Formula`
2. Prove `succ_chain_fam_mcs`
3. Define `SuccChainFMCS : FMCS Int` structure

### Phase 3: FMCS Coherence
1. Prove `succ_chain_forward_G`
2. Prove `succ_chain_backward_H`
3. Prove `succ_chain_forward_F`
4. Prove `succ_chain_backward_P`

### Phase 4: TaskFrame Instantiation
1. Prove `CanonicalTask_forward_comp_int_full`
2. Define `CanonicalTaskTaskFrame : TaskFrame Int`

### Phase 5: WorldHistory Construction
1. Define `succ_chain_history`
2. Prove `respects_task`

---

## 11. Mathlib Patterns

### 11.1 Function Iteration

Use `Function.iterate` from Mathlib for chain iteration proofs:

```lean
import Mathlib.Order.Iterate
-- f^[n] x = iterate f n x
```

### 11.2 Int Arithmetic

```lean
import Mathlib.Data.Int.Basic
-- Int.ofNat_add, Int.neg_add, Int.toNat_of_nonneg
```

### 11.3 Classical Choice

```lean
import Mathlib.Logic.Classical.Basic
-- Classical.choose, Classical.choose_spec
```

---

## 12. Connection to Existing Infrastructure

### 12.1 FMCSTransfer (FMCSTransfer.lean)

The existing `FMCSTransfer` pattern could potentially be adapted for this construction, but the direct Succ-chain approach is simpler for the discrete case.

### 12.2 DiscreteCanonicalTaskFrame

The existing `DiscreteCanonicalTaskFrame` uses `CanonicalR` which is weaker than `Succ`. Using `CanonicalTask` (built on Succ) provides the stronger discrete structure needed for completeness.

### 12.3 TemporalCoherentFamily

The constructed FMCS can be packaged as a `TemporalCoherentFamily` by proving forward_F and backward_P:

```lean
noncomputable def succ_chain_temporal_coherent (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    TemporalCoherentFamily Int where
  toFMCS := succ_chain_fmcs M0 h_mcs0
  forward_F := succ_chain_forward_F M0 h_mcs0
  backward_P := succ_chain_backward_P M0 h_mcs0
```

---

## 13. Verification Checklist

Before marking task complete, verify:

- [ ] `forward_chain` and `backward_chain` definitions compile
- [ ] `succ_chain_fam_mcs` proven for all Int indices
- [ ] `SuccChainFMCS` structure satisfies FMCS signature
- [ ] All four coherence properties proven:
  - [ ] `succ_chain_forward_G`
  - [ ] `succ_chain_backward_H`
  - [ ] `succ_chain_forward_F`
  - [ ] `succ_chain_backward_P`
- [ ] `CanonicalTaskTaskFrame` satisfies TaskFrame axioms
- [ ] `succ_chain_history` satisfies `respects_task`
- [ ] `lake build` succeeds with no sorries
- [ ] Documentation comments added

---

## 14. Summary

The task is implementable with moderate effort. All prerequisites are complete:

1. **Task 10**: Succ relation with g_content/f_content propagation
2. **Task 11**: CanonicalTask with nullity, compositionality, converse
3. **Task 12**: Successor/predecessor existence (with axioms)

The construction follows a standard pattern:
- Build Int-indexed chains using Classical.choose
- Derive FMCS coherence from Succ properties
- Instantiate TaskFrame using CanonicalTask
- Construct WorldHistory via respects_task

No blocking issues identified. Estimated implementation time: 4-6 hours.
