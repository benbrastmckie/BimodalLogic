# Teammate A Findings: Semantic Refactor Design -- Tuple-Based Construction for Purely Reflexive Logic

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Focus**: Complete semantic refactor design with Burgess-Xu axiom system
**Session**: sess_1775594330_f8d3fa (Teammate A)

---

## Executive Summary

After analyzing reports 29-32 and the full codebase, I recommend a **two-phase semantic refactor** that:

1. **Switches to all-reflexive Burgess-Xu semantics** (Phase 1: minimal semantic change, ~300 LOC)
2. **Replaces the successor chain completeness with BX eventuality resolution** (Phase 2: new completeness proof, ~1500-2500 LOC)

The tuple-based construction maps directly to the BX canonical model with Until/Since eventualities resolved via BX5 (self-accumulation) and BX6 (absorption), completely eliminating the forward_F/backward_G circularity that has blocked all 30+ previous approaches.

**Confidence**: HIGH for Phase 1 (sound axiom system), MEDIUM-HIGH for Phase 2 (completeness via BX, well-studied in literature).

---

## 1. Key Findings

### 1.1 The Root Cause Is the Mixed Semantics + Discrete Architecture

The forward_F problem is NOT a single bug but an emergent consequence of three interacting design choices:

1. **Mixed semantics**: G/H reflexive (`>=`/`<=`) but U/S strict (`>`/`<`) -- no published proof handles this combination
2. **Discrete successor chain**: x_content determines successor deterministically, making F-resolution PULL-based while the construction is PUSH-based
3. **Next-based Until axioms**: until_unfold, until_intro, until_induction all use X(phi) = bot U phi, which under mixed semantics creates the unsound F_until_equiv

**All three must be addressed together.** Report 31's Option E' (replace 2 axioms with 4) patches symptom #3 but leaves #1 and #2, meaning the forward_F circularity persists. The Burgess-Xu refactor addresses all three simultaneously.

### 1.2 The Minimal Semantic Change Is Just One Character

Report 32 Section 8.6 makes the critical observation: switching U/S from strict to reflexive witness requires changing only `t < s` to `t <= s` in Truth.lean. The guard interval `(t, s)` remains open in both semantics. This means:

- Current: `exists s, t < s & psi(s) & forall r, t < r -> r < s -> phi(r)`
- Proposed: `exists s, t <= s & psi(s) & forall r, t < r -> r < s -> phi(r)`

When `s = t`, the guard `(t, t)` is empty, so `phi U psi` at t holds iff `psi` holds at t. This gives `F(phi) <-> top U phi` as a semantic equivalence (not an axiom), immediately resolving the F_until_equiv soundness gap.

### 1.3 The BX Completeness Proof Eliminates forward_F Entirely

The Burgess completeness proof for all linear orders does NOT use:
- Next/Previous operators
- Deterministic successor chains
- forward_F / backward_G lemmas

Instead, it resolves Until-eventualities using:
- **BX5 (Self-Accumulation)**: `phi U psi -> (phi & (phi U psi)) U psi` -- eventuality propagates forward, enriching the guard
- **BX6 (Absorption)**: `phi U (phi & (phi U psi)) -> phi U psi` -- prevents infinite deferral

Together these give the bidirectional `phi U psi <-> (phi & (phi U psi)) U psi`, which allows the canonical model construction to find witnesses without stepping through successor positions.

### 1.4 What the "Tuple" Really Is

The user's tuple-based construction maps precisely to the BX canonical model:

| User's Tuple Concept | BX Canonical Model | Current Codebase Analog |
|-----------------------|-------------------|------------------------|
| Tuple (state) | MCS in canonical frame | `SetMaximalConsistent` |
| Task (eventuality) | Until-formula needing witness | `F(psi) in M` |
| Timeline | Maximal chain of MCS | `deterministic_chain` |
| Duration resolution | BX5/BX6 eventuality resolution | `forward_F` (sorry) |
| Constraint satisfaction | Canonical model truth lemma | `succ_chain_truth_forward` |

The key insight: tuples ARE MCS, the "task" IS an eventuality obligation, and "duration resolution" IS what BX5/BX6 provide axiomatically.

---

## 2. Recommended Approach

### 2.1 New Semantic Types

**No new Lean types are needed for the semantic layer.** The existing type hierarchy survives:

```lean
-- KEEP: These types are frame-class agnostic
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
structure TaskModel {D : Type*} ... (F : TaskFrame D)
structure WorldHistory (F : TaskFrame D)

-- KEEP: MCS infrastructure
def SetMaximalConsistent (S : Set Formula) : Prop
def SetConsistent (S : Set Formula) : Prop
```

**What changes**: Only the truth evaluation for U/S in `Truth.lean`:

```lean
-- BEFORE (strict witness, open guard):
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ

-- AFTER (reflexive witness, open guard):
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

**Confidence**: HIGH -- this is exactly the Burgess 1982 semantics, verified against BX4 in Report 32 Section 8.4-8.5.

### 2.2 New Axiom System

Replace the current 35-constructor `Axiom` inductive with a cleaner ~25-constructor version:

```lean
inductive Axiom : Formula → Type where
  -- Layer 1: Classical Propositional (4, KEEP)
  | prop_k (φ ψ χ : Formula) : Axiom (...)
  | prop_s (φ ψ : Formula) : Axiom (...)
  | ex_falso (φ : Formula) : Axiom (...)
  | peirce (φ ψ : Formula) : Axiom (...)

  -- Layer 2: S5 Modal (5, KEEP)
  | modal_t (φ : Formula) : Axiom (...)
  | modal_4 (φ : Formula) : Axiom (...)
  | modal_b (φ : Formula) : Axiom (...)
  | modal_5_collapse (φ : Formula) : Axiom (...)
  | modal_k_dist (φ ψ : Formula) : Axiom (...)

  -- Layer 3: Burgess-Xu Temporal (14 = 7 schemas x 2 mirrors)
  | temp_t_future (φ : Formula) : Axiom (φ.all_future.imp φ)  -- BX1
  | temp_t_past (φ : Formula) : Axiom (φ.all_past.imp φ)      -- BX1'
  | left_mono_until (φ ψ χ : Formula) : Axiom (...)            -- BX2
  | left_mono_since (φ ψ χ : Formula) : Axiom (...)            -- BX2'
  | right_mono_until (φ ψ χ : Formula) : Axiom (...)           -- BX3
  | right_mono_since (φ ψ χ : Formula) : Axiom (...)           -- BX3'
  | connect_until_since (φ ψ χ : Formula) : Axiom (...)        -- BX4
  | connect_since_until (φ ψ χ : Formula) : Axiom (...)        -- BX4'
  | self_accum_until (φ ψ : Formula) : Axiom (...)             -- BX5
  | self_accum_since (φ ψ : Formula) : Axiom (...)             -- BX5'
  | absorb_until (φ ψ : Formula) : Axiom (...)                 -- BX6
  | absorb_since (φ ψ : Formula) : Axiom (...)                 -- BX6'
  | linear_until (φ ψ χ θ : Formula) : Axiom (...)             -- BX7
  | linear_since (φ ψ χ θ : Formula) : Axiom (...)             -- BX7'

  -- Layer 4: Modal-Temporal Interaction (2, KEEP)
  | modal_future (φ : Formula) : Axiom (...)
  | temp_future (φ : Formula) : Axiom (...)
```

**REMOVED** (all derivable from BX or not needed for general linear orders):
- `temp_k_dist` -- derivable from BX1 + NEC_G
- `temp_4` -- derivable from BX1 + NEC_G
- `temp_a`, `temp_a_dual` -- derivable from BX4
- `temp_l` -- derivable from BX axioms
- `temp_linearity` -- subsumed by BX7
- `density` -- trivially derivable from BX1
- ALL discrete axioms (16): `discreteness_forward`, `seriality_*`, `disc_next/prev`, `until_unfold/intro/induction`, `since_unfold/intro/induction`, `until/since_linearity`, `until/since_connectedness`, `F_until_equiv`, `P_since_equiv`

**Inference rules** (KEEP): MP, NEC_Box, NEC_G, NEC_H (or temporal_duality)

**Confidence**: HIGH -- this is the standard Burgess-Xu system plus S5, well-documented in literature.

### 2.3 Truth Evaluation Under Reflexive Semantics

The key semantic consequences of the reflexive U/S change:

**F = top U (theorem, not axiom)**:
```lean
-- Under reflexive U: top U phi at t = exists s >= t, phi(s) & forall r in (t,s), top(r)
--                                    = exists s >= t, phi(s)
--                                    = F(phi) at t
-- So F(phi) <-> top U phi is a semantic equivalence
theorem F_equiv_top_until (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) (φ : Formula) :
    truth_at M Omega τ t φ.some_future ↔ truth_at M Omega τ t (Formula.untl (.imp .bot .bot) φ) := by
  -- Proof by unfolding definitions; the guard (t, s) with top is vacuously true
  sorry -- straightforward once semantics change is in place
```

**phi U psi at s=t reduces to psi(t)**:
```lean
-- When witness s = t: guard interval (t, t) is empty
-- So phi U psi at t iff psi(t) OR (exists s > t, psi(s) & phi on (t,s))
-- This means: phi U_reflexive psi = psi ∨ phi U_strict psi
```

**X(phi) = bot U phi under reflexive semantics**:
- `bot U phi` at t = `exists s >= t, phi(s) & forall r in (t,s), bot(r)`
- When s = t: phi(t) (guard empty)
- When s > t: phi(s) and bot on (t,s) -- impossible if (t,s) is nonempty
- On dense orders: (t,s) is always nonempty for s > t, so X(phi) = phi
- On discrete orders: (t, t+1) is empty, so X(phi) = phi(t) or phi(t+1)

**This confirms Report 31's finding**: X is NOT a well-defined "next step" under reflexive U on non-discrete orders. But this is fine -- the BX system does NOT use X. On discrete orders, X can be recovered as a derived operator with additional discrete axioms (Phase 4, optional).

**Confidence**: HIGH -- verified by detailed semantic analysis in Report 32 Section 8.

### 2.4 Canonical Model Construction (Replacing the Chain)

The BX completeness proof replaces the deterministic chain with a canonical model construction that works for ALL linear orders:

**Step 1: Canonical Frame**

```lean
-- The canonical frame for BX + S5
-- Points: MCS of the logic
-- Temporal order: w ≤_T v iff {φ : G(φ) ∈ w} ⊆ v
-- Modal equivalence: w ~_M v iff {φ : □φ ∈ w} = {φ : □φ ∈ v}
structure BXCanonicalFrame where
  points : Type  -- SetMaximalConsistent sets
  temporal_le : points → points → Prop  -- ≤_T
  modal_equiv : points → points → Prop  -- ~_M
  temporal_le_linear : IsLinearOrder points temporal_le  -- BX7 ensures this
  modal_equiv_is_equiv : Equivalence modal_equiv  -- S5 ensures this
```

**Step 2: Truth Lemma**

The truth lemma `φ ∈ w ↔ M_canonical, w ⊨ φ` is proved by induction on formula structure. The critical cases:

- **G(φ) forward**: If G(φ) ∈ w, then by BX1 (reflexivity) and the canonical ordering, φ ∈ v for all v ≥ w. Standard.
- **G(φ) backward**: If φ ∈ v for all v ≥ w, then G(φ) ∈ w. This uses maximality of w: if G(φ) ∉ w, then ¬G(φ) = F(¬φ) ∈ w, so there exists v ≥ w with ¬φ ∈ v, contradicting the hypothesis. **No forward_F needed -- this is pure MCS reasoning.**
- **φ U ψ forward**: If φ U ψ ∈ w, we must find a witness v ≥ w with ψ ∈ v and φ on (w,v). BX5 (self-accumulation) ensures the eventuality propagates with enriched guard. BX6 (absorption) prevents infinite deferral. BX7 (linearity) ensures witnesses from different eventualities are ordered.
- **φ U ψ backward**: If there exists v ≥ w with ψ ∈ v and φ at all u ∈ (w,v), then φ U ψ ∈ w. Uses BX4 (connectedness) and MCS properties.

**The key breakthrough**: The backward G case does NOT require forward_F. In the chain-based approach, converting "φ at all future positions" to "G(φ) ∈ chain(t)" required forward_F because the chain is a fixed construction. In the canonical model, the MCS w is defined to contain G(φ) precisely when the canonical ordering puts φ at all future points -- this is the DEFINITION of the canonical ordering, not a property that needs proving.

**Step 3: Until Witness Construction**

This is the only genuinely hard step. The BX approach:

1. Given `φ U ψ ∈ w₀`, apply BX5 repeatedly: `(φ & (φ U ψ)) U ψ ∈ w₀`
2. The enriched guard `φ & (φ U ψ)` means at every intermediate point, both φ holds AND the eventuality persists
3. By Zorn's lemma on the set of MCS extending the "intermediate" theory, construct a maximal chain
4. BX6 ensures ψ must eventually appear (absorption prevents infinite deferral)
5. BX7 ensures the witnesses from multiple eventualities compose into a single linear order

```lean
-- Sketch of the witness construction
noncomputable def until_witness (w : MCS) (φ ψ : Formula)
    (h : Formula.untl φ ψ ∈ w.val) :
    ∃ v : MCS, canonical_le w v ∧ ψ ∈ v.val ∧
      ∀ u : MCS, canonical_le w u → canonical_le u v → u ≠ v → φ ∈ u.val := by
  -- Use BX5 to get (φ & φ U ψ) U ψ ∈ w
  -- The enriched eventuality propagates through any chain extension
  -- BX6 ensures eventual resolution
  -- Zorn's lemma gives the maximal chain with witness
  sorry
```

**Confidence**: MEDIUM-HIGH -- this is the standard Burgess/Xu completeness argument, well-documented. The Lean formalization requires care but follows established mathematical reasoning.

### 2.5 Forward-F Resolution

**The forward_F problem is dissolved, not solved.** Under the BX approach:

1. There is no deterministic chain, so no `deterministic_forward_F`
2. The canonical model truth lemma for G uses MCS negation completeness directly (if G(φ) ∉ w then F(¬φ) ∈ w), not a chain construction
3. Until-witnesses are constructed via BX5/BX6 axioms, not by stepping through successor positions
4. The circularity `forward_F → backward_G → forward_F` is broken because backward_G is not needed -- the canonical ordering DEFINES the G-relationship

**This is why the BX approach succeeds where 30+ rounds of chain-based attempts failed**: the chain approach tried to BUILD a model and then VERIFY it satisfies G/F properties, which requires forward_F. The BX approach DEFINES the model so that G/F properties hold by construction.

**Confidence**: HIGH -- this is the standard mathematical resolution. The circularity was an artifact of the chain-based architecture.

### 2.6 Migration Path

#### Files That SURVIVE Unchanged

| File | Reason |
|------|--------|
| `Syntax/Formula.lean` | Formula type unchanged (untl/snce constructors stay) |
| `Syntax/Atom.lean` | No dependency on semantics |
| `Syntax/Context.lean` | No dependency on semantics |
| `Syntax/SubformulaClosure.lean` | May need minor updates for BX closure |
| `Semantics/TaskFrame.lean` | Frame structure unchanged |
| `Semantics/TaskModel.lean` | Model structure unchanged |
| `Semantics/WorldHistory.lean` | History structure unchanged |
| `Semantics/Validity.lean` | Validity definition unchanged |
| `Metalogic/Core/MaximalConsistent.lean` | MCS infrastructure unchanged |
| `Metalogic/Core/DeductionTheorem.lean` | Pure proof theory |
| `Metalogic/Core/Core.lean` | Core definitions |
| `Theorems/Propositional/` | All propositional theorems |

#### Files That Need MODIFICATION

| File | Change | Effort |
|------|--------|--------|
| `Semantics/Truth.lean` | Change `t < s` to `t <= s` for U/S (2 lines) | ~50 LOC (re-prove lemmas) |
| `ProofSystem/Axioms.lean` | Replace 35 constructors with ~25 BX constructors | ~200 LOC |
| `ProofSystem/Derivation.lean` | Update inference rules (minor) | ~50 LOC |
| `Metalogic/Soundness.lean` | Re-prove soundness for new axioms | ~400 LOC |
| `Metalogic/SoundnessLemmas.lean` | Update bridge theorems | ~200 LOC |
| `Metalogic/Core/MCSProperties.lean` | Add BX-specific MCS properties | ~300 LOC |
| `Metalogic/Core/RestrictedMCS.lean` | May need updates | ~100 LOC |

#### Files That Get REPLACED (New Completeness Proof)

| Old File(s) | New File(s) | Description |
|-------------|-------------|-------------|
| `Metalogic/Bundle/*` (23 files) | `Metalogic/BXCanonical/Frame.lean` | Canonical frame definition |
| `Metalogic/Algebraic/DeterministicChain.lean` | `Metalogic/BXCanonical/Ordering.lean` | Canonical temporal ordering |
| `Metalogic/Algebraic/DeterministicFMCS.lean` | `Metalogic/BXCanonical/TruthLemma.lean` | BX truth lemma |
| `Metalogic/Algebraic/FiniteDeferral.lean` | `Metalogic/BXCanonical/EventualityResolution.lean` | BX5/BX6 witness construction |
| `Metalogic/Completeness/SuccChainCompleteness.lean` | `Metalogic/BXCanonical/Completeness.lean` | Final completeness theorem |

#### Files That Can Be PRESERVED (Algebraic Infrastructure)

| File | Status |
|------|--------|
| `Metalogic/Algebraic/BooleanStructure.lean` | KEEP (used by BX canonical model) |
| `Metalogic/Algebraic/LindenbaumQuotient.lean` | KEEP (Lindenbaum's lemma still needed) |
| `Metalogic/Algebraic/TenseS5Algebra.lean` | KEEP (algebraic structure reusable) |
| `Metalogic/Algebraic/InteriorOperators.lean` | KEEP (modal operators reusable) |
| `Metalogic/Algebraic/UltrafilterMCS.lean` | KEEP (ultrafilter construction reusable) |

---

## 3. Evidence and Examples

### 3.1 BX4 Verification (Connectedness)

Report 32 Section 8.4 verified BX4 semantically with **open guard intervals**. The verification:

Given: phi(t) and chi U psi at t with witness s >= t, psi(s), chi on (t,s).
Goal: chi U (psi & chi S phi) at t.
Proof: Same witness s. At s: psi(s) holds. For chi S phi at s: take witness s' = t, then phi(t) given, chi on (t,s) given (open interval matches). Guard for conclusion: chi on (t,s), same as premise.

This ONLY works with open guard intervals `(t,s)`, NOT with the half-open `[t,s)` that some sources use. The current codebase already uses open guards (Truth.lean lines 127-128: `t < r → r < s`), so the guard intervals need NO change.

### 3.2 F_until_equiv Resolution

Under reflexive U/S:
- `F(psi)` at t = `exists s >= t, psi(s)` (reflexive G gives reflexive F)
- `top U psi` at t = `exists s >= t, psi(s) & forall r in (t,s), top(r)` = `exists s >= t, psi(s)`
- Therefore `F(psi) <-> top U psi` is a semantic theorem

The sorry at Soundness.lean:770 becomes provable (or the axiom is removed entirely since it's derivable from BX).

### 3.3 Soundness of BX5 (Self-Accumulation)

`phi U psi -> (phi & (phi U psi)) U psi`

Semantic check: Suppose phi U psi at t with witness s >= t, psi(s), phi on (t,s).
For (phi & (phi U psi)) U psi at t: use same witness s.
- At s: psi(s) holds.
- At any r in (t,s): phi(r) holds (from premise guard). Also phi U psi at r holds, because s is still a future witness for psi with phi on (r,s) subset of (t,s).
- So phi & (phi U psi) holds at each r in (t,s).

Valid on all linear orders under reflexive semantics.

### 3.4 Why BX6 Prevents Infinite Deferral

`phi U (phi & (phi U psi)) -> phi U psi`

Suppose phi U (phi & (phi U psi)) at t. Then there exists s >= t with (phi(s) & (phi U psi)(s)) and phi on (t,s).
Since phi U psi at s, there exists s' >= s with psi(s') and phi on (s, s').
Then psi(s') with phi on (t,s) union (s,s'). If s = t, then phi on (t,s') = (t,s'). If s > t, then phi on (t,s) and phi(s) and phi on (s,s') gives phi on (t,s').
Wait -- we need phi(s) explicitly. We have it: phi(s) & (phi U psi)(s).
So phi on (t,s') (combining (t,s), {s}, (s,s') -- but (t,s) is open so we get (t,s'), noting phi(s) bridges the gap).

Actually: the guard for the conclusion needs phi on (t, s'). We have phi on (t,s) from the outer Until, phi(s) from the witness, and phi on (s, s') from the inner Until at s. The union (t,s) ∪ {s} ∪ (s, s') = (t, s'). So phi U psi at t with witness s'. Valid.

This axiom says: if you can defer the eventuality to a point where it still holds, you can collapse the two-step resolution into one. Combined with BX5, this means the eventuality MUST be resolved -- you can't keep deferring forever because absorption collapses any intermediate deferral.

---

## 4. Detailed Design: Phase 1 (Semantic Change + Axiom Replacement)

### 4.1 Truth.lean Changes

```lean
-- Change exactly 2 lines:
-- Line 127: t < s  →  t ≤ s
-- Line 129: s < t  →  s ≤ t

| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

### 4.2 Axioms.lean Replacement

See Section 2.2 above for the full axiom list. The key new axioms (BX2-BX7 and mirrors) are given in Report 32 Appendix B with precise Lean syntax.

### 4.3 Soundness Re-proof

Each BX axiom needs a soundness proof. BX1 (temp_t_future/past) is already proved. BX2-BX7 need new proofs, but all are straightforward semantic verifications (see Section 3 above for examples). Estimated ~400 LOC total for all 14 BX axioms.

### 4.4 Derived Theorem Recovery

Several currently-primitive axioms become derivable theorems:
- `temp_k_dist`: G distributes over implication (from BX1 + NEC_G + prop_k)
- `temp_4`: G(φ) → GG(φ) (from BX1 + NEC_G)
- `temp_a`: φ → GP(φ) (from BX4)
- `F_until_equiv`: F(φ) ↔ ⊤ U φ (semantic equivalence under reflexive U)

These should be proved as derived theorems to maintain backward compatibility with existing infrastructure that uses them.

---

## 5. Detailed Design: Phase 2 (BX Canonical Model Completeness)

### 5.1 Canonical Frame

```lean
-- New file: Metalogic/BXCanonical/Frame.lean
structure BXCanonicalPoint where
  formulas : Set Formula
  is_mcs : SetMaximalConsistent formulas

-- Canonical temporal ordering
def canonical_temporal_le (w v : BXCanonicalPoint) : Prop :=
  ∀ φ, φ.all_future ∈ w.formulas → φ ∈ v.formulas

-- Canonical modal equivalence
def canonical_modal_equiv (w v : BXCanonicalPoint) : Prop :=
  ∀ φ, Formula.box φ ∈ w.formulas ↔ Formula.box φ ∈ v.formulas
```

### 5.2 Linearity of Canonical Order

BX7 ensures the canonical temporal ordering is linear:

```lean
-- From BX7: (φ U ψ) & (χ U θ) → three-way disjunction
-- This forces any two MCS to be temporally comparable
theorem canonical_temporal_le_total (w v : BXCanonicalPoint) :
    canonical_temporal_le w v ∨ canonical_temporal_le v w := by
  -- Use BX7 + MCS completeness
  sorry -- standard argument via linearity axiom
```

### 5.3 Eventuality Resolution Module

```lean
-- New file: Metalogic/BXCanonical/EventualityResolution.lean

-- BX5 gives: if φ U ψ ∈ w, then (φ & (φ U ψ)) U ψ ∈ w
-- This means at intermediate points, both φ and the eventuality hold

-- BX6 gives: absorption prevents infinite deferral
-- Combined: eventual resolution is guaranteed

-- The witness construction uses Zorn's lemma on chains of MCS
theorem until_eventuality_resolved (w : BXCanonicalPoint) (φ ψ : Formula)
    (h : Formula.untl φ ψ ∈ w.formulas) :
    ∃ v : BXCanonicalPoint, canonical_temporal_le w v ∧ ψ ∈ v.formulas ∧
      ∀ u, canonical_temporal_le w u → canonical_temporal_le u v → u ≠ v →
        φ ∈ u.formulas := by
  sorry -- Burgess construction via BX5/BX6/Zorn
```

### 5.4 Truth Lemma

```lean
-- New file: Metalogic/BXCanonical/TruthLemma.lean
theorem bx_truth_lemma (w : BXCanonicalPoint) (φ : Formula) :
    φ ∈ w.formulas ↔ canonical_model_satisfies w φ := by
  induction φ with
  | atom _ => -- Direct from valuation definition
  | bot => -- MCS consistency
  | imp _ _ ih1 ih2 => -- MCS implication property + IH
  | box _ ih => -- Modal saturation + IH
  | all_future _ ih => -- Canonical ordering definition + IH
  | all_past _ ih => -- Mirror of all_future
  | untl _ _ ih1 ih2 => -- BX5/BX6 eventuality + IH (HARDEST CASE)
  | snce _ _ ih1 ih2 => -- Mirror of untl
  sorry
```

### 5.5 Final Completeness

```lean
-- New file: Metalogic/BXCanonical/Completeness.lean
theorem bx_completeness (φ : Formula) :
    (∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
       (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
       (τ : WorldHistory F) (t : D), truth_at M Omega τ t φ) →
    Nonempty (DerivationTree [] φ) := by
  -- Contrapositive: ¬provable(φ) → ¬valid(φ)
  -- 1. ¬provable(φ) → {¬φ} is consistent
  -- 2. Extend to MCS w₀ via Lindenbaum
  -- 3. Build canonical model
  -- 4. Truth lemma: ¬φ ∈ w₀ → canonical model falsifies φ at w₀
  -- 5. Therefore φ is not valid
  sorry
```

---

## 6. Risk Assessment and Confidence Levels

| Component | Confidence | Risk | Mitigation |
|-----------|-----------|------|------------|
| Semantic change (Truth.lean) | HIGH (95%) | Very low | Minimal change, well-understood |
| BX axiom soundness | HIGH (90%) | Low | Each axiom semantically verified |
| Axiom replacement | HIGH (85%) | Medium | Many pattern matches to update |
| Derived theorem recovery | HIGH (85%) | Low | Standard proof theory |
| Canonical frame linearity | MEDIUM-HIGH (75%) | Medium | BX7 argument well-known |
| Until eventuality resolution | MEDIUM (65%) | High | Zorn's lemma in Lean, BX5/BX6 interaction |
| Full truth lemma | MEDIUM (60%) | High | Until case requires careful formalization |
| Integration with S5 modal | MEDIUM-HIGH (75%) | Medium | Interaction axioms unchanged |
| Overall completeness | MEDIUM (60%) | Medium-High | Novel formalization of known proof |

**Overall assessment**: Phase 1 (semantic change + axioms) has ~90% confidence with ~600-800 LOC. Phase 2 (completeness) has ~60% confidence with ~1500-2500 LOC. The completeness proof is mathematically well-established but formalizing it in Lean 4 is non-trivial.

**Comparison with status quo**: The current approach has ~5% confidence of closing forward_F (30+ failed attempts). Even at 60% confidence, the BX refactor is a dramatic improvement.

---

## 7. Discreteness Extension (Future Work)

After the base BX system is complete, discrete reasoning can be recovered as an extension layer:

```lean
-- Extension axioms for discrete linear orders (Z)
-- These are ADDED to the BX base, not replacements
inductive DiscreteAxiom : Formula → Type where
  | seriality_future (φ : Formula) : DiscreteAxiom (φ.all_future.imp φ.some_future)
  | seriality_past (φ : Formula) : DiscreteAxiom (φ.all_past.imp φ.some_past)
  -- Note: Next/Previous are derived operators under reflexive U/S:
  -- X(φ) = ⊥ U φ  (on discrete orders: φ at current time OR φ at next time)
  -- Y(φ) = ⊥ S φ  (on discrete orders: φ at current time OR φ at previous time)
```

On discrete orders, the current until_unfold/intro/induction axioms would become derivable from BX + discrete extension. The existing chain-based completeness proof could potentially be recovered as a specialization.

---

## 8. Summary of Recommendations

1. **IMMEDIATE**: Change U/S semantics from strict to reflexive witness in Truth.lean (2 lines)
2. **PHASE 1**: Replace axiom system with BX + S5 (~25 constructors), re-prove soundness (~600-800 LOC)
3. **PHASE 2**: Build BX canonical model completeness proof (~1500-2500 LOC), replacing the chain-based approach entirely
4. **PRESERVE**: All propositional, S5 modal, and algebraic infrastructure
5. **DEFER**: Discrete extension axioms as future work (not needed for base completeness)
6. **DO NOT**: Attempt to fix forward_F within the current chain architecture (30+ failed rounds is sufficient evidence)

The BX refactor is the mathematically correct approach because:
- It uses a published, well-studied axiom system (Burgess 1982, Xu 1988)
- It eliminates the forward_F circularity by construction (not by finding a clever proof)
- It generalizes to all linear orders (not just discrete)
- It aligns with the codebase's existing reflexive G/H semantics
- It reduces the axiom count from 35 to ~25
- It makes F_until_equiv a theorem rather than an unsound axiom
