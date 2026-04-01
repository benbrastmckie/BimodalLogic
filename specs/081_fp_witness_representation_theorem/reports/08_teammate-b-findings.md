# Report 08: Teammate B — F-Persistence Chain Construction Design

**Task**: 81 — F/P Witness Representation Theorem
**Date**: 2026-04-01
**Role**: Phase 2 design — F-persistence chain construction

## Executive Summary

The F-persistence chain is a Nat-indexed sequence of MCSs M_0, M_1, M_2, ... where each
step is built by extending a seed that contains `g_content(M_n) ∪ f_content(M_n) ∪ box_theory(M_n)`.
All three components of this seed are subsets of M_n, making consistency trivial. The existing
`lindenbaumMCS_set` infrastructure handles the Lindenbaum extension. This is genuinely new
infrastructure: no existing chain construction preserves ALL F-obligations simultaneously.
The box_theory inclusion is the critical insight enabling `box_class_agree` to be maintained.

**Estimated new code**: 180–240 lines.

---

## 1. Existing Infrastructure Audit

### 1.1 What Exists and Can Be Reused

| Component | File | Exact Identifier | Reusable? |
|-----------|------|-----------------|-----------|
| `set_lindenbaum` | `MaximalConsistent.lean:291` | `set_lindenbaum S h_cons` | Directly |
| `lindenbaumMCS_set` | `Construction.lean:137` | `lindenbaumMCS_set S h_cons` | Directly |
| `lindenbaumMCS_set_extends` | `Construction.lean:144` | `S ⊆ lindenbaumMCS_set S h_cons` | Directly |
| `lindenbaumMCS_set_is_mcs` | `Construction.lean:150` | Returns `SetMaximalConsistent` | Directly |
| `g_content` | `TemporalContent.lean:47` | `{phi | Formula.all_future phi ∈ M}` | Directly |
| `f_content` | `TemporalContent.lean:68` | `{phi | Formula.some_future phi ∈ M}` | Directly |
| `mem_g_content_iff` | `TemporalContent.lean:87` | `@[simp]` | Directly |
| `mem_f_content_iff` | `TemporalContent.lean:95` | `@[simp]` | Directly |
| `box_theory` | `UltrafilterChain.lean:1829` | Includes Box(a) and ¬Box(a) cases | Directly |
| `box_theory_subset_mcs` | `UltrafilterChain.lean:1836` | `box_theory M ⊆ M` when MCS | Directly |
| `box_class_agree` | `UltrafilterChain.lean:1570` | `∀ phi, Box(phi) ∈ M ↔ Box(phi) ∈ W` | Directly |
| `box_class_agree_refl` | `UltrafilterChain.lean:1573` | `box_class_agree M M` | Directly |
| `box_class_agree_trans` | `UltrafilterChain.lean:1576` | Transitivity | Directly |
| `temporal_theory_witness_exists` | `UltrafilterChain.lean:2212` | Resolves ONE F-obligation + box_agree | Not directly |
| `ForwardChainElement` | `SuccChainFMCS.lean:168` | Structure pattern | Pattern only |
| `forwardChainAt` | `SuccChainFMCS.lean:197` | Nat-inductive chain | Pattern only |
| `forward_dovetailed` | `DovetailedChain.lean:147` | Nat-indexed MCS chain | Pattern only |
| `FMCS` | `FMCSDef.lean:99` | Int-indexed structure with forward_G/backward_H | For conversion |

### 1.2 What Doesn't Exist (Genuinely New)

The following do NOT exist in the codebase:
1. A seed containing `g_content ∪ f_content ∪ box_theory` simultaneously
2. A chain that preserves ALL F-obligations (not just one per step)
3. `f_persistent_seed` definition
4. `f_persistent_chain` Nat-indexed chain
5. Properties connecting f_content(M_n) ⊆ f_content(M_{n+1})

---

## 2. The F-Persistence Seed: Design and Consistency

### 2.1 Exact Definition

```lean
/-- The F-persistence seed: formulas that must persist into the successor.
    Combines g_content (G-persistence), f_content (F-obligations preserved),
    and box_theory (modal saturation preserved). -/
def f_persistent_seed (M : Set Formula) : Set Formula :=
  g_content M ∪ f_content M ∪ box_theory M
```

### 2.2 Why Each Component Belongs

**g_content(M) ⊆ M**: For each `a ∈ g_content M`, we have `G(a) ∈ M`. By the T-axiom
`temp_t_future: G(a) → a`, and MCS closure under derivation, `a ∈ M`. Hence `g_content M ⊆ M`.
This is already proven in `constrained_successor_seed_consistent` (SuccExistence.lean:468).

**f_content(M) ⊆ M**: For each `a ∈ f_content M`, we have `F(a) ∈ M`. Since `F(a) ∈ M`
directly, and `F(a) = ¬G(¬a)` means `a` is just in `f_content(M)` (the content, not the
operator), we need `a ∈ M`. **Wait — this is NOT trivially true.** `f_content(M) = {phi | F(phi) ∈ M}`,
so `a ∈ f_content(M)` means `F(a) ∈ M`, NOT that `a ∈ M`. We are adding `a` to the seed,
NOT `F(a)`. The seed contains the INNER formulas, not the F-formulas themselves.

**Corrected argument**: `f_content M ⊆ M` is NOT automatically true. An MCS can contain
`F(a)` with `a ∉ M`. So adding `a` (not `F(a)`) to the seed does NOT guarantee consistency
from mere subset inclusion.

**The correct consistency argument for f_content inclusion**:
`f_content(M) ⊆ M` fails in general. However, `{phi} ∪ g_content(M)` IS consistent when
`F(phi) ∈ M` (by `forward_temporal_witness_seed_consistent` in WitnessSeed.lean:79). The
F-persistence seed includes all of `f_content M` simultaneously, so we need a different argument.

**Revised seed definition and consistency strategy**:

The seed should contain the OPERATORS, not the inner formulas:
```lean
-- Option A: Include F(a) themselves (not a), but then FMCS chain M_{n+1} has F(a) ∈ M_{n+1}
-- This would ensure f_content(M_n) ⊆ f_content(M_{n+1}) directly.
def f_persistent_seed (M : Set Formula) : Set Formula :=
  g_content M ∪ (f_content M : Set Formula).image Formula.some_future ∪ box_theory M
```

But this is equivalent to:
```lean
def f_persistent_seed (M : Set Formula) : Set Formula :=
  g_content M ∪ {Formula.some_future phi | phi ∈ f_content M} ∪ box_theory M
```

Which simplifies to `g_content M ∪ {F(phi) | F(phi) ∈ M} ∪ box_theory M`. Since
`{F(phi) | F(phi) ∈ M} ⊆ M` trivially, this IS a subset of M.

**However**, this approach means M_{n+1} contains `F(phi)` itself, NOT `phi`. This preserves
the F-obligations as obligations in M_{n+1} (they are NOT resolved, just carried forward).
The chain accumulates F-obligations without ever resolving them. This is consistent with the
Phase 2 goal: build a chain where ALL F-obligations persist for Phase 3 (dovetailing) to resolve.

### 2.3 The Correct Seed Definition

```lean
/-- The F-persistence seed: formulas that must be in the next world.
    - g_content(M): G-formulas propagate forward (g_content(M) ⊆ M via T-axiom)
    - {F(phi) | F(phi) ∈ M}: F-obligations persist (they are already in M)
    - box_theory(M): modal saturation preserved (box_theory(M) ⊆ M when M is MCS)

    All three components are subsets of M, so consistency is trivial. -/
def f_persistent_seed (M : Set Formula) : Set Formula :=
  g_content M ∪ {psi | ∃ phi, psi = Formula.some_future phi ∧ Formula.some_future phi ∈ M}
              ∪ box_theory M
```

Note: The middle component `{F(phi) | F(phi) ∈ M}` is exactly `{psi ∈ M | ∃ phi, psi = F(phi)}`,
i.e., the F-formulas of M themselves. This is just `{psi | psi ∈ M ∧ psi.is_some_future}` which
can also be written as the intersection `M ∩ Formula.range_some_future`. Most cleanly:

```lean
-- The set of all formulas in M of the form F(phi)
def F_obligations (M : Set Formula) : Set Formula :=
  {psi | ∃ phi, psi = Formula.some_future phi ∧ Formula.some_future phi ∈ M}
```

Then: `F_obligations M ⊆ M` trivially (since every element IS in M by definition).

### 2.4 Seed Consistency Proof

```lean
theorem f_persistent_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (f_persistent_seed M) := by
  -- Show f_persistent_seed M ⊆ M, then use MCS consistency
  have h_subset : f_persistent_seed M ⊆ M := by
    intro psi h_mem
    simp only [f_persistent_seed, Set.mem_union, Set.mem_setOf_eq] at h_mem
    rcases h_mem with h_gc | ⟨phi, rfl, h_F⟩ | h_bt
    · -- g_content M ⊆ M via T-axiom
      have h_T := DerivationTree.axiom [] _ (Axiom.temp_t_future psi)
      exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_gc
    · -- F(phi) ∈ M by assumption
      exact h_F
    · -- box_theory M ⊆ M
      exact box_theory_subset_mcs M h_mcs h_bt
  -- Any subset of M is consistent
  intro L hL_sub ⟨d⟩
  exact h_mcs.1 L (fun chi h => h_subset (hL_sub chi h)) ⟨d⟩
```

**Estimated lines**: ~20 lines.

---

## 3. Chain Construction Pattern

### 3.1 Structure Approach

Following the `ForwardChainElement` pattern from SuccChainFMCS.lean:

```lean
/-- One element of the F-persistent chain: an MCS together with proof it is MCS -/
structure FPersistentChainElement where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

/-- Build the next F-persistent chain element from the current one.
    The successor extends f_persistent_seed(e.world) via Lindenbaum. -/
noncomputable def FPersistentChainElement.next (e : FPersistentChainElement) :
    FPersistentChainElement where
  world := lindenbaumMCS_set (f_persistent_seed e.world)
                              (f_persistent_seed_consistent e.world e.is_mcs)
  is_mcs := lindenbaumMCS_set_is_mcs _ _
```

### 3.2 Nat-Indexed Chain

```lean
/-- The F-persistent chain: Nat-indexed sequence of MCSs where all F-obligations persist -/
noncomputable def f_persistent_chain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → Set Formula
  | 0     => M0
  | n + 1 => lindenbaumMCS_set (f_persistent_seed (f_persistent_chain M0 h_mcs0 n))
                                 (f_persistent_seed_consistent _
                                   (f_persistent_chain_mcs M0 h_mcs0 n))

/-- Each element of f_persistent_chain is an MCS -/
theorem f_persistent_chain_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n, SetMaximalConsistent (f_persistent_chain M0 h_mcs0 n)
  | 0     => h_mcs0
  | n + 1 => lindenbaumMCS_set_is_mcs _ _
```

Note: `f_persistent_chain_mcs` is used in the definition of `f_persistent_chain` (mutual
recursion needed). In Lean 4 this is handled by a `mutual` block or by using `FPersistentChainElement`.
Using the structure approach avoids mutual recursion:

```lean
noncomputable def f_persistent_chain_at (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → FPersistentChainElement
  | 0     => ⟨M0, h_mcs0⟩
  | n + 1 => (f_persistent_chain_at M0 h_mcs0 n).next

noncomputable def f_persistent_chain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) : Set Formula :=
  (f_persistent_chain_at M0 h_mcs0 n).world

theorem f_persistent_chain_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    SetMaximalConsistent (f_persistent_chain M0 h_mcs0 n) :=
  (f_persistent_chain_at M0 h_mcs0 n).is_mcs
```

**Estimated lines**: ~40 lines.

---

## 4. Step Properties

### 4.1 Seed Extension

The core property: each M_{n+1} extends the seed of M_n.

```lean
/-- f_persistent_seed(M_n) ⊆ M_{n+1} -/
theorem f_persistent_chain_seed_extends (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) :
    f_persistent_seed (f_persistent_chain M0 h_mcs0 n) ⊆
    f_persistent_chain M0 h_mcs0 (n + 1) :=
  lindenbaumMCS_set_extends _ _
```

### 4.2 G-Content Propagation

```lean
/-- g_content(M_n) ⊆ M_{n+1} -/
theorem f_persistent_chain_g_content_step (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) :
    g_content (f_persistent_chain M0 h_mcs0 n) ⊆ f_persistent_chain M0 h_mcs0 (n + 1) := by
  intro phi h_gc
  apply f_persistent_chain_seed_extends
  simp only [f_persistent_seed, Set.mem_union]
  exact Or.inl (Or.inl h_gc)
```

### 4.3 F-Obligation Persistence (The Key Property)

```lean
/-- {F(phi) | F(phi) ∈ M_n} ⊆ M_{n+1} — F-obligations persist -/
theorem f_persistent_chain_F_obligations_step (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) :
    F_obligations (f_persistent_chain M0 h_mcs0 n) ⊆ f_persistent_chain M0 h_mcs0 (n + 1) := by
  intro psi ⟨phi, rfl, h_F⟩
  apply f_persistent_chain_seed_extends
  simp only [f_persistent_seed, Set.mem_union, Set.mem_setOf_eq]
  exact Or.inl (Or.inr ⟨phi, rfl, h_F⟩)
```

**Corollary**: f_content(M_n) ⊆ f_content(M_{n+1}).

```lean
/-- f_content(M_n) ⊆ f_content(M_{n+1}) -/
theorem f_persistent_chain_f_content_monotone (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) :
    f_content (f_persistent_chain M0 h_mcs0 n) ⊆ f_content (f_persistent_chain M0 h_mcs0 (n + 1)) := by
  intro phi h_phi_fc
  -- h_phi_fc : F(phi) ∈ M_n (i.e., phi ∈ f_content(M_n))
  -- Step 1: F(phi) ∈ F_obligations(M_n)
  have h_F_in_F_obl : Formula.some_future phi ∈ F_obligations (f_persistent_chain M0 h_mcs0 n) :=
    ⟨phi, rfl, h_phi_fc⟩
  -- Step 2: F(phi) ∈ M_{n+1} by persistence
  have h_F_in_next := f_persistent_chain_F_obligations_step M0 h_mcs0 n h_F_in_F_obl
  -- Step 3: phi ∈ f_content(M_{n+1})
  exact h_F_in_next
```

### 4.4 Modal Saturation (box_class_agree)

```lean
/-- box_class_agree M_n M_{n+1} -/
theorem f_persistent_chain_box_agree_step (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) :
    box_class_agree (f_persistent_chain M0 h_mcs0 n) (f_persistent_chain M0 h_mcs0 (n + 1)) := by
  intro psi
  constructor
  · -- Box(psi) ∈ M_n → Box(psi) ∈ M_{n+1}
    intro h_box
    apply f_persistent_chain_seed_extends
    simp only [f_persistent_seed, Set.mem_union]
    apply Or.inr
    simp only [box_theory, Set.mem_setOf_eq]
    exact Or.inl ⟨psi, rfl, h_box⟩
  · -- Box(psi) ∈ M_{n+1} → Box(psi) ∈ M_n
    -- Contrapositive: Box(psi) ∉ M_n → Box(psi) ∉ M_{n+1}
    -- If Box(psi) ∉ M_n, then ¬Box(psi) ∈ box_theory(M_n) ⊆ M_{n+1}
    -- So ¬Box(psi) ∈ M_{n+1}, hence Box(psi) ∉ M_{n+1} by MCS consistency
    intro h_box_next
    by_contra h_not_box
    have h_neg_in_seed : Formula.neg (Formula.box psi) ∈ f_persistent_seed
        (f_persistent_chain M0 h_mcs0 n) := by
      simp only [f_persistent_seed, Set.mem_union]
      apply Or.inr
      simp only [box_theory, Set.mem_setOf_eq]
      exact Or.inr ⟨psi, rfl, h_not_box⟩
    have h_neg_in_next := f_persistent_chain_seed_extends M0 h_mcs0 n h_neg_in_seed
    exact set_consistent_not_both (f_persistent_chain_mcs M0 h_mcs0 (n + 1)).1
      (Formula.box psi) h_box_next h_neg_in_next
```

**Estimated lines for step properties**: ~80 lines.

### 4.5 Transitive Propagation

The step properties give one-step propagation. For the chain-level properties needed
for FMCS conversion, we need multi-step versions:

```lean
/-- G-content propagates forward monotonically -/
theorem f_persistent_chain_g_content_propagate (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n m : Nat) (h_le : n ≤ m) :
    g_content (f_persistent_chain M0 h_mcs0 n) ⊆ f_persistent_chain M0 h_mcs0 m := by
  induction m with
  | zero => exact Nat.le_zero.mp h_le ▸ Set.Subset.refl _
  | succ k ih =>
    rcases Nat.eq_or_lt_of_le h_le with rfl | h_lt
    · exact f_persistent_chain_g_content_step M0 h_mcs0 k
    · exact Set.Subset.trans (ih (Nat.lt_succ_iff.mp h_lt))
        (Set.subset_of_eq rfl)  -- M_k ⊆ M_{k+1} is NOT true in general
```

**PROBLEM**: M_k ⊆ M_{k+1} does NOT hold in general (Lindenbaum can add or omit formulas).
The multi-step G-propagation needs a different approach via G(G(phi)) → G(phi) (temp_4).

**Correct approach** (following DovetailedChain.lean:166-213):

```lean
/-- G(phi) propagates one step: G(phi) ∈ M_n → G(phi) ∈ M_{n+1} -/
theorem f_persistent_chain_G_step (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) (phi : Formula)
    (h_G : Formula.all_future phi ∈ f_persistent_chain M0 h_mcs0 n) :
    Formula.all_future phi ∈ f_persistent_chain M0 h_mcs0 (n + 1) := by
  -- G(G(phi)) ∈ M_n by temp_4
  have h_4 := DerivationTree.axiom [] _ (Axiom.temp_4 phi)
  have h_GG : Formula.all_future (Formula.all_future phi) ∈ f_persistent_chain M0 h_mcs0 n :=
    SetMaximalConsistent.implication_property (f_persistent_chain_mcs M0 h_mcs0 n)
      (theorem_in_mcs (f_persistent_chain_mcs M0 h_mcs0 n) h_4) h_G
  -- G(phi) ∈ g_content(M_n) since G(G(phi)) ∈ M_n
  have h_G_in_gc : Formula.all_future phi ∈ g_content (f_persistent_chain M0 h_mcs0 n) := h_GG
  -- G(phi) ∈ M_{n+1} via seed extension
  exact f_persistent_chain_g_content_step M0 h_mcs0 n h_G_in_gc
```

---

## 5. Converting to FMCS

### 5.1 The Problem: FMCS Needs Int-Indexed, Not Nat-Indexed

`FMCS D` requires a preorder domain D (typically `Int` for the forward direction). The
`f_persistent_chain` is Nat-indexed. For integration with the existing completeness proof,
we need a `TemporalCoherentFamily Int`.

### 5.2 Nat-to-Int Lift

The simplest approach: embed the Nat-indexed chain into an Int-indexed family where
negative times all use M_0 (or the backward chain handles negatives separately).

For the F-persistence chain's specific purpose (demonstrating that an MCS with an
F-obligation can be placed in a family satisfying forward_F coherence), we only need
the FORWARD direction. The FMCS structure requires both forward_G AND backward_H.

**Option 1: Constant extension backward**
```lean
noncomputable def f_persistent_fam (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) : Set Formula :=
  match t with
  | Int.ofNat n => f_persistent_chain M0 h_mcs0 n
  | Int.negSucc _ => M0  -- all negative times use M0
```

This satisfies `forward_G` trivially for t < 0 (M0 at all negative times). For t ≥ 0,
`forward_G` follows from `f_persistent_chain_G_step`.

`backward_H` for t ≥ 0: H(phi) ∈ M_n → phi ∈ M_0. This requires showing g_content/h_content
duality holds across the chain. Key: if `g_content(M_n) ⊆ M_{n+1}`, then by
`g_content_subset_implies_h_content_reverse` (WitnessSeed.lean:324), `h_content(M_{n+1}) ⊆ M_n`.
This IS a property of the f_persistent_chain by construction.

### 5.3 TemporalCoherentFamily Connection

```lean
noncomputable def f_persistent_fmcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    FMCS Int where
  mcs    := f_persistent_fam M0 h_mcs0
  is_mcs := fun t => ...
  forward_G := fun t t' phi h_le h_G => ...
  backward_H := fun t t' phi h_le h_H => ...
```

For `forward_F` (to make it a `TemporalCoherentFamily`):
```lean
/-- F-obligation witness: F(phi) ∈ M_n implies phi ∈ M_{n+1}
    Note: this is STRONGER than required (phi is at EXACTLY n+1, not just some s ≥ n) -/
theorem f_persistent_chain_forward_F_witness (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) (phi : Formula)
    (h_F : Formula.some_future phi ∈ f_persistent_chain M0 h_mcs0 n) :
    phi ∈ f_persistent_chain M0 h_mcs0 (n + 1) := by
  -- F(phi) ∈ F_obligations(M_n) ⊆ M_{n+1} gives F(phi) ∈ M_{n+1}
  -- But we need phi ∈ M_{n+1}, NOT F(phi) ∈ M_{n+1}
  ...
```

**CRITICAL PROBLEM**: The F-persistence chain carries `F(phi)` into M_{n+1}, NOT `phi` itself.
So `phi ∈ f_persistent_chain M0 h_mcs0 (n+1)` is NOT directly provable from the seed.

This is the fundamental limitation of Phase 2: it PRESERVES the F-obligations but does NOT
RESOLVE them. Phase 3 (dovetailing) is needed to actually resolve them.

For `forward_F` coherence in the TemporalCoherentFamily, the chain does NOT by itself provide
`phi ∈ M_s for some s ≥ n`. That requires the dovetailing step.

---

## 6. What the F-Persistence Chain Actually Gives Us

### 6.1 Confirmed Properties

1. **MCS at each step**: `f_persistent_chain_mcs` — M_n is an MCS for all n.
2. **G-content forward**: g_content(M_n) ⊆ M_{n+1} — enables forward_G FMCS condition.
3. **F-obligation preservation**: F(phi) ∈ M_n → F(phi) ∈ M_{n+1} — ALL F-obligations persist.
4. **f_content monotone**: f_content(M_n) ⊆ f_content(M_{n+1}) — direct corollary.
5. **box_class_agree**: box_class_agree M_n M_{n+1} — modal saturation preserved.
6. **h_content reverse**: h_content(M_{n+1}) ⊆ M_n — from g_content duality.

### 6.2 What It Does NOT Give

- phi ∈ M_{n+1} when F(phi) ∈ M_n (the F-persistence chain DEFERS not RESOLVES).
- forward_F coherence directly (phi is NOT necessarily in M_{n+1}).
- The chain alone does NOT produce a TemporalCoherentFamily.

### 6.3 Connection to Phase 3 (Dovetailing)

The Phase 2 chain serves as the **base structure** for Phase 3 dovetailing. In Phase 3:
- At each step n, the dovetailing also resolves SOME F(phi_j) by including `phi_j` directly.
- The F-persistence chain guarantees that all other F-obligations are still present.
- This gives a chain where: (a) each step resolves at least one F-obligation, and
  (b) no F-obligation is ever dropped.

---

## 7. Lean 4 Implementation Plan

### 7.1 File Structure

New file: `Theories/Bimodal/Metalogic/Bundle/FPersistentChain.lean`

Imports needed:
```lean
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.Construction     -- lindenbaumMCS_set
import Bimodal.Metalogic.Bundle.WitnessSeed       -- g_content_subset_implies_h_content_reverse
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Algebraic.UltrafilterChain  -- box_theory, box_class_agree
import Bimodal.Syntax.Formula
```

### 7.2 Complete Definition List with Line Estimates

| Definition/Theorem | Lines | Status |
|--------------------|-------|--------|
| `F_obligations` def | 5 | New |
| `f_persistent_seed` def | 5 | New |
| `mem_f_persistent_seed_iff` | 5 | New |
| `f_persistent_seed_consistent` | 20 | New |
| `FPersistentChainElement` structure | 5 | New |
| `FPersistentChainElement.next` | 10 | New |
| `f_persistent_chain_at` | 5 | New |
| `f_persistent_chain` def | 5 | New |
| `f_persistent_chain_mcs` | 5 | New |
| `f_persistent_chain_seed_extends` | 5 | New |
| `f_persistent_chain_g_content_step` | 10 | New |
| `f_persistent_chain_F_obligations_step` | 10 | New |
| `f_persistent_chain_f_content_monotone` | 15 | New |
| `f_persistent_chain_box_agree_step` | 30 | New |
| `f_persistent_chain_G_step` | 20 | New |
| `f_persistent_chain_G_propagate` | 20 | New |
| `f_persistent_chain_h_content_reverse_step` | 10 | New |
| `f_persistent_chain_box_agree_trans` | 10 | New |
| **Total** | **195** | |

Plus FMCS conversion infrastructure (~40 lines if needed in Phase 2):
- `f_persistent_fam` def
- `f_persistent_fmcs` def
- Forward G/backward H proofs for the FMCS structure

### 7.3 Key Lemma: box_theory_subset_f_persistent_seed

This lemma is essential for the box_class_agree backward direction:

```lean
theorem box_theory_subset_f_persistent_seed (M : Set Formula) :
    box_theory M ⊆ f_persistent_seed M :=
  Set.subset_union_right
```

---

## 8. Critical Finding: Seed Subset vs Resolution Distinction

**The F-persistence seed keeps `F(phi)` (the operator), not `phi` (the content).**

This is the most important architectural finding. The seed `f_persistent_seed M` contains:
- `g_content M` = {phi | G(phi) ∈ M}  — these are the INNER formulas of G-operators
- `F_obligations M` = {F(phi) | F(phi) ∈ M} — these are the F-OPERATORS THEMSELVES
- `box_theory M` = {Box(phi) | Box(phi) ∈ M} ∪ {¬Box(phi) | Box(phi) ∉ M}

This is INCONSISTENT with using the same inner-formula convention for g_content and f_content.
The two serve different roles:
- g_content: "what must hold because G says so" → inner formula goes in successor
- f_obligations: "what must eventually hold" → the OBLIGATION (F-formula) goes in successor

An alternative, simpler formulation:

```lean
/-- F-persistence seed: everything in M that must be in M_{n+1}.
    Components:
    - g_content(M): via T-axiom G(phi) → phi, these must hold in M_{n+1} for FMCS forward_G
    - M_F := {F(phi) ∈ M}: F-obligations stay (not resolved) to preserve f_content monotonicity
    - box_theory(M): modal formulas persist for same-family modal saturation
    All three are subsets of M, so the seed is trivially consistent. -/
def f_persistent_seed (M : Set Formula) : Set Formula :=
  g_content M
  ∪ {psi | ∃ phi, psi = Formula.some_future phi ∧ Formula.some_future phi ∈ M}
  ∪ box_theory M
```

Note: g_content M ∪ {F(phi) | F(phi) ∈ M} = g_content M ∪ (M's F-type formulas).

**REMARK**: The standard seed in `temporal_theory_witness_exists` is
`{phi} ∪ G_theory(M) ∪ box_theory(M)` — note it uses `G_theory(M)` = {G(a) | G(a) ∈ M}
(the G-OPERATORS), not `g_content(M)` (the inner formulas). This is because G(a) is what
needs to be G-liftable. The F-persistence seed analogously puts F-operators in the seed.

---

## 9. Canonical Imports and Reuse Summary

### From existing code, directly reusable:
- `lindenbaumMCS_set`, `lindenbaumMCS_set_extends`, `lindenbaumMCS_set_is_mcs`
  (Construction.lean:137–155)
- `box_theory`, `box_theory_subset_mcs`, `box_class_agree`, `box_class_agree_refl`
  (UltrafilterChain.lean:1829–1576)
- `g_content`, `f_content`, `mem_g_content_iff`, `mem_f_content_iff`
  (TemporalContent.lean:47–99)
- `g_content_subset_implies_h_content_reverse` (WitnessSeed.lean:324)
- `set_consistent_not_both`, `theorem_in_mcs`, `SetMaximalConsistent.implication_property`
  (MCSProperties.lean — various)
- `Axiom.temp_t_future` (T-axiom for G), `Axiom.temp_4` (G → GG)

### Pattern reuse (not direct):
- `FPersistentChainElement` structure mirrors `ForwardChainElement` (SuccChainFMCS.lean:168)
- Inductive chain definition mirrors `forward_dovetailed` (DovetailedChain.lean:147)
- G-step propagation mirrors `forward_dovetailed_G_step` (DovetailedChain.lean:170)

### Genuinely new:
- `F_obligations` definition (new concept)
- `f_persistent_seed` (new seed combining g_content + F-operators + box_theory)
- `f_persistent_chain` (new chain type — preserves ALL F-obligations, resolves NONE)
- F-obligation persistence theorems
- f_content monotonicity proof

---

## 10. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| `box_theory` import from `UltrafilterChain.lean` creates a long import chain | Medium | Extract to shared file, or use inline definition |
| Mutual recursion in `f_persistent_chain` def | Low | Use structure pattern (FPersistentChainElement) |
| Lean elaboration issues with `Set.mem_union` simp lemmas | Low | Use `rcases` + explicit membership |
| The chain doesn't give `forward_F` for TemporalCoherentFamily | High | This is by design; Phase 3 dovetailing handles it |
| Phase 3 integration: f_content monotone alone is insufficient for dovetailing | Medium | Dovetailing needs F-obligations IN the chain, which we provide |

---

## 11. Summary Answer to Research Questions

1. **Existing chain patterns**: `ForwardChainElement` + `forwardChainAt` pattern (SuccChainFMCS.lean:168–199) is the right pattern. `forward_dovetailed` (DovetailedChain.lean:147) is also relevant. Neither handles F-preservation. Use the structure pattern to avoid mutual recursion.

2. **Seed definition**: `f_persistent_seed M = g_content M ∪ {F(phi) | F(phi) ∈ M} ∪ box_theory M`. All three components are subsets of M (g_content via T-axiom; F-operators trivially; box_theory via box_theory_subset_mcs). Consistency proof: ~20 lines.

3. **Chain construction**: Use `FPersistentChainElement` structure + `f_persistent_chain_at` induction, then `f_persistent_chain` as the world extractor. ~40 lines.

4. **Properties to prove**: All five target properties are provable in ~150 lines using existing infrastructure. The `box_class_agree` proof is the most complex (~30 lines).

5. **Box theory inclusion**: YES, include `box_theory(M)` in the seed. It IS a subset of M (via `box_theory_subset_mcs`). This gives `box_class_agree` by construction.

6. **FMCS conversion**: The Nat-indexed chain converts to FMCS Int by using M_0 at all negative times. It satisfies `forward_G` and `backward_H` (required by FMCS). It does NOT automatically satisfy `forward_F` (required by TemporalCoherentFamily) — that requires Phase 3 dovetailing.

**Total estimated new code**: ~200 lines.
