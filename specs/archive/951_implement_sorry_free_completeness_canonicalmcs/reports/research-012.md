# Research Report: Task #951 (research-012) -- G/H Symmetry, Preorder vs AddCommGroup, and the Correct Syntactic Construction of D

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-03-01
**Session**: sess_1772389542_5caef0
**Mode**: Team Research (3 teammates)
**Dependencies**: research-009 through research-011

---

## Executive Summary

This team research addresses three critical concerns about the canonical frame construction raised by the user:

1. **G/H Symmetry**: Both G and H play **equal roles** in defining the temporal relation. The codebase defines dual relations (CanonicalR via GContent, CanonicalR_past via HContent) connected by proven duality bridges (`GContent_subset_implies_HContent_reverse` and converse).

2. **Preorder vs AddCommGroup**: The claim "TruthLemma works with just Preorder D" is **technically correct but misleading**. The BFMCS layer genuinely requires only `Preorder D`, but the completeness theorem as a whole requires `AddCommGroup D + LinearOrder D + IsOrderedAddMonoid D` because:
   - TaskFrame definition requires these
   - The `valid` definition quantifies over these
   - The linearity axiom's soundness requires LinearOrder

3. **Disconnected Chains**: The concern is **valid for full CanonicalMCS but resolved by BidirectionalFragment**. The fragment is the connected component from a root M0, and totality is machine-proven (`bidirectional_totally_ordered`, no sorry).

**Synthesis Verdict**: The syntactic construction of D should proceed on the **BidirectionalQuotient** (Antisymmetrization of BidirectionalFragment), with AddCommGroup derived via the Successor Algebra approach (research-010). The disconnected chains problem is eliminated by using the fragment, and AddCommGroup is needed for the semantic layer.

---

## 1. G/H Symmetry in the Temporal Relation

### Finding: Both Directions Are Fully Represented

**Teammate A** established that G and H play equal, symmetric roles:

| Forward (G-direction) | Backward (H-direction) |
|---|---|
| `CanonicalR M M' := GContent M ⊆ M'` | `CanonicalR_past M M' := HContent M ⊆ M'` |
| `canonical_forward_G` | `canonical_backward_H` |
| `canonical_forward_F` | `canonical_backward_P` |
| `canonicalR_reflexive` (uses temp_t_future) | `canonicalR_past_reflexive` (uses temp_t_past) |
| `canonicalR_transitive` (uses temp_4) | `HContent_chain_transitive` (uses temp_4_past) |

**The Critical Duality Bridges** (DovetailingChain.lean, lines 765-824):

```
GContent_subset_implies_HContent_reverse: CanonicalR M M' → CanonicalR_past M' M
HContent_subset_implies_GContent_reverse: CanonicalR_past M M' → CanonicalR M' M
```

These prove that **CanonicalR and CanonicalR_past are converses**: if M sees M' in the future, M' sees M in the past. The proof uses the `temp_a: phi → G(P(phi))` axiom (the present was in the past of the future).

**Implication**: A single ordering based on CanonicalR suffices because both GContent propagation (forward_G) and HContent propagation (backward_H) follow automatically via the duality bridge.

### Note on F/P vs G/H

The user correctly observes that F and P are duals of G and H (not of each other):
- F(phi) = neg(G(neg(phi)))
- P(phi) = neg(H(neg(phi)))

G and H are independent primitive operators; F and P are their De Morgan duals. The axiom system uses G as "primary" but H gets all the same properties via the `temporal_duality` inference rule.

---

## 2. Preorder vs AddCommGroup Requirements

### Finding: Two-Layer Architecture with Different Constraints

**Teammate B** mapped the exact typeclass requirements across the codebase:

| Layer | Components | Constraints on D |
|-------|------------|------------------|
| **BFMCS Layer** (inner) | FMCS, BFMCS, BFMCSTruth | `Preorder D` only |
| **Truth Lemma** | TruthLemma, TemporalCoherentFamily | `Preorder D` + `Zero D` |
| **Semantic Layer** (outer) | TaskFrame, TaskModel, Truth, Validity | `AddCommGroup D` + `LinearOrder D` + `IsOrderedAddMonoid D` |

### Where AddCommGroup Becomes Required

**Pathway 1: TaskFrame Definition (Primary)**
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  task_rel : WorldState → D → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w                    -- needs 0 from AddCommGroup
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v  -- needs +
```

**Pathway 2: Validity Definition (Structural)**
```lean
def valid (phi : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) ...
```

**Pathway 3: time_shift for MF/TF Soundness**
`time_shift_preserves_truth` uses `y - x`, `add_sub_cancel`, etc. (group identities).

### Where LinearOrder Becomes Required

The **linearity axiom** `temp_linearity` (F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi))` is **unsound** without LinearOrder D. The soundness proof explicitly uses the totality of ≤ on D.

### Verdict

- **"Just Preorder" is correct** for the BFMCS layer machinery (which never uses +, -, or group identities)
- **"Just Preorder" is misleading** for the completeness theorem as a whole, which must connect to `valid` quantifying over AddCommGroup + LinearOrder + IsOrderedAddMonoid

---

## 3. Disconnected Chains and Temporal Equivalence

### Finding: Concern Valid for Full CanonicalMCS, Resolved by BidirectionalFragment

**Teammate C** analyzed the disconnected chains concern:

**Over ALL MCSes**: The CanonicalR preorder is NOT total. Research-011 Section 5.2 explicitly acknowledges: "The Antisymmetrization of ALL CanonicalMCSes is NOT totally ordered." Two unrelated MCSes can be completely CanonicalR-incomparable.

**Over BidirectionalFragment**: The CanonicalR preorder IS total. This is **machine-proven** at BidirectionalReachable.lean lines 728-740:

```lean
theorem bidirectional_totally_ordered (a b : BidirectionalFragment M0 h_mcs0) :
    CanonicalR a.world b.world ∨ CanonicalR b.world a.world ∨ a.world = b.world
```

No sorry in this proof.

### Why the Fragment Works

The BidirectionalFragment is the **connected component** of the root M0 under symmetric CanonicalR:

```lean
structure BidirectionalFragment (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
  reachable : BidirectionalReachable M0 h_mcs0 world is_mcs
```

Where `BidirectionalReachable` is the reflexive-transitive closure of `BidirectionalEdge` (symmetric closure of CanonicalR). By construction, NO disconnected components exist within a single fragment.

### What "Same Time" Means

Two MCSes are "at the same temporal position" if mutually CanonicalR-related: `CanonicalR M M'` AND `CanonicalR M' M`. This implies `GContent(M) = GContent(M')` (they agree on all temporal formulas). Within the BidirectionalQuotient, they are collapsed to a single point.

### Clarification on Research-011

Research-011 Section 3.1's definition ("A temporal position is an equivalence class of MCSes under the symmetric closure of CanonicalR") should be understood as applying **within a single BidirectionalFragment**, not over all MCSes.

---

## 4. Conflicts Resolved

### Conflict 1: "Preorder is sufficient" vs "AddCommGroup required"

**Resolution**: Both are correct at different layers:
- BFMCS layer: Preorder D only (internal MCS machinery)
- Semantic layer: AddCommGroup + LinearOrder + IsOrderedAddMonoid (TaskFrame, valid, time_shift)

The CanonicalConstruction bridges these by instantiating D = Int.

### Conflict 2: "Temporal position = symmetric closure of CanonicalR" vs "Disconnected chains"

**Resolution**: The definition only makes sense within a connected component (BidirectionalFragment), which is exactly how the codebase uses it. The fragment is rooted at M0 and totality is proven.

---

## 5. The Correct Syntactic Construction of D (Full Detail)

Based on all research findings (009-012), here is the complete syntactic construction:

### Step 1: Build the Canonical Frame from Pure Syntax

Given a consistent formula phi (to be refuted):

1. **Root construction**: Extend {phi} to an MCS M0 via Lindenbaum's lemma
2. **Fragment construction**: Build `BidirectionalFragment M0 h_mcs0` = all MCSes reachable from M0 via iterated forward/backward CanonicalR edges
3. **Temporal relation**: Use `CanonicalR` (GContent inclusion) as the preorder; `CanonicalR_past` (HContent inclusion) is the converse via duality bridge

### Step 2: Establish LinearOrder on the Fragment

1. **Preorder**: Already given by `CanonicalR` on fragment elements
2. **Totality**: Proven via `bidirectional_totally_ordered` using the temporal linearity axiom
3. **Quotient**: Form `BidirectionalQuotient M0 h_mcs0 := Antisymmetrization (BidirectionalFragment M0 h_mcs0) (· ≤ ·)`
4. **LinearOrder**: Instance `instLinearOrderBidirectionalQuotient` is proven (no sorry)

### Step 3: Derive AddCommGroup via Successor Algebra

This is the key step from research-010:

1. **SuccOrder**: Define `succ [w] := [fragmentGSucc w]` using the Lindenbaum extension of GContent
2. **PredOrder**: Define `pred [w]` using the backward analog (HContent extension)
3. **Prove required properties**:
   - `IsSuccArchimedean`: Any two elements are finitely many successor steps apart
   - `NoMaxOrder`: Every element has a strict successor (from F-witness existence)
   - `NoMinOrder`: Every element has a strict predecessor (from P-witness existence)
4. **Apply Mathlib theorem**: `orderIsoIntOfLinearSuccPredArch` gives `BidirectionalQuotient ≃o ℤ`
5. **Transfer AddCommGroup**: `Equiv.addCommGroup` transfers `AddCommGroup` from ℤ to `BidirectionalQuotient`
6. **Verify IsOrderedAddMonoid**: Follows from the OrderIso preserving structure

### Step 4: Define the Syntactic TaskFrame

With `D = BidirectionalQuotient M0 h_mcs0` now having:
- `LinearOrder D` (from quotient)
- `AddCommGroup D` (transferred from ℤ)
- `IsOrderedAddMonoid D` (from order iso)

Define:
```lean
def SyntacticTaskFrame : TaskFrame D where
  WorldState := { M : Set Formula // SetMaximalConsistent M }
  task_rel M d N := pos N - pos M = d ∧ GContent M.val ⊆ N.val ∧ HContent N.val ⊆ M.val
  nullity := by group_algebra  -- pos M - pos M = 0
  compositionality := by group_algebra  -- (pos N - pos M) + (pos V - pos N) = pos V - pos M
```

Where `pos : BidirectionalFragment → BidirectionalQuotient` is the quotient projection.

### Step 5: Connect to FMCS and Completeness

1. **Build FMCS D**: The existing `fragmentFMCS` provides sorry-free forward_F/backward_P
2. **Truth Lemma**: `bmcs_truth_lemma` connects MCS membership to semantic truth
3. **Canonical Truth**: Bridge BFMCS truth to TaskFrame truth via `canonical_truth_lemma`
4. **Completeness**: If phi is not derivable, M0 = Lindenbaum({not phi}) refutes phi at time 0 in the SyntacticTaskFrame

### Axiom-Dependent Structure (Extension)

The construction naturally accommodates axiom extensions:

| Axiom Set | Fragment Structure | D Isomorphism |
|-----------|-------------------|---------------|
| Base TM | Discrete, unbounded | D ≃o ℤ |
| TM + discreteness axiom | Discrete (explicit) | D ≃o ℤ |
| TM + density axiom | Dense, unbounded | D embeds into ℚ |

The discreteness axiom `F(phi) → phi → P(phi)` makes the successor explicitly immediate. The density axiom `F(F(phi)) → F(phi)` forces intermediate points, ruling out SuccOrder.

---

## 6. Remaining Gap: Modal Saturation

**Important**: This syntactic construction of D does NOT resolve the sorry in `fully_saturated_bfmcs_exists_int`. That sorry is about combining:
- Temporal coherence (forward_F + backward_P for all families)
- Modal saturation (enough families for Box backward)

The syntactic D construction is orthogonal to this sorry. The modal saturation problem requires constructing enough BFMCS families, not changing the temporal domain.

---

## 7. Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | G/H Symmetry | completed | high | Dual bridges proven; single ordering suffices |
| B | Preorder vs AddCommGroup | completed | high | Two-layer architecture mapped; AddCommGroup paths identified |
| C | Disconnected Chains | completed | high | Fragment totality proven; concern resolved |

---

## 8. References

### Codebase Files
- `CanonicalFrame.lean` - CanonicalR and CanonicalR_past definitions
- `DovetailingChain.lean` - GContent/HContent duality bridges
- `BidirectionalReachable.lean` - Fragment construction, totality proof
- `FMCSDef.lean` - FMCS with Preorder only
- `TaskFrame.lean` - TaskFrame with AddCommGroup + LinearOrder + IsOrderedAddMonoid
- `Validity.lean` - `valid` definition quantifying over group structure
- `TruthLemma.lean` - bmcs_truth_lemma with Preorder + Zero
- `CanonicalConstruction.lean` - Bridge from BFMCS to TaskFrame (D = Int)

### Previous Research
- research-009: Time-shift groups, torsor constructions
- research-010: Successor Algebra approach (SuccOrder → orderIsoIntOfLinearSuccPredArch → AddCommGroup)
- research-011: Frame construction from pure syntax, per-chain durations

---

## 9. Appendix: Teammate Findings Files

- `specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-012-teammate-a-findings.md`
- `specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-012-teammate-b-findings.md`
- `specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-012-teammate-c-findings.md`
