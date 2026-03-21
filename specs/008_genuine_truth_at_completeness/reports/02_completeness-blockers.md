# Research Report: TM Logic Completeness Blockers

**Task**: 1008 - Establish genuine truth_at completeness theorems for TM logic
**Started**: 2026-03-20
**Completed**: 2026-03-20
**Language**: math/lean4

## Executive Summary

The TM logic completeness pipeline has **3 fundamental sorries** representing two distinct architectural problems:

1. **modal_backward** (1 sorry) - Single-family BFMCS cannot satisfy the modal backward coherence condition
2. **forward_F / backward_P** (2 sorries) - Linear chain constructions cannot guarantee F/P witnesses exist in the chain

Both problems stem from a fundamental tension: the working sorry-free construction (`CanonicalFMCS.lean`) uses `CanonicalMCS` as the domain type, but the completeness pipeline requires `D = Int` for the `TaskFrame D` structure.

## Context & Scope

This research examines the 3 sorries blocking TM logic completeness:

| File | Line | Sorry | Blocker Type |
|------|------|-------|--------------|
| IntFMCSTransfer.lean | 134 | `modal_backward` | Single-family degenerate case |
| IntBFMCS.lean | 1199 | `intFMCS_forward_F` | Lindenbaum extension problem |
| IntBFMCS.lean | 1213 | `intFMCS_backward_P` | Lindenbaum extension problem |

---

## 1. The BFMCS Structure

### Definition (BFMCS.lean:88-119)

```lean
structure BFMCS where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : ∀ fam ∈ families, ∀ φ t, Formula.box φ ∈ fam.mcs t →
    ∀ fam' ∈ families, φ ∈ fam'.mcs t
  modal_backward : ∀ fam ∈ families, ∀ φ t,
    (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
  eval_family : FMCS D
  eval_family_mem : eval_family ∈ families
```

**Mathematical Meaning**:
- A BFMCS is a **bundle** of time-indexed MCS families
- `modal_forward`: If Box(phi) is in any family's MCS at time t, then phi is in ALL families' MCSes at time t
- `modal_backward`: If phi is in ALL families' MCSes at time t, then Box(phi) is in each family's MCS at time t

These conditions encode **S5 modal semantics** where the accessibility relation between families is universal.

---

## 2. Blocker 1: modal_backward Failure for Single-Family BFMCS

### Location
IntFMCSTransfer.lean, line 134

### The Problem

When constructing a BFMCS from a single FMCS family:

```lean
noncomputable def singleFamilyBFMCS_Int (fam : FMCS Int) : BFMCS Int where
  families := {fam}  -- SINGLE element set
  ...
  modal_backward := by
    intro fam' hfam' φ t h_all
    -- h_all : ∀ fam' ∈ {fam}, φ ∈ fam'.mcs t
    -- reduces to: φ ∈ fam.mcs t
    -- Need: Box φ ∈ fam.mcs t
    sorry  -- CANNOT BE PROVEN
```

### Why It Fails

For a single-family bundle, `modal_backward` reduces to:
```
φ ∈ fam.mcs t  →  Box(φ) ∈ fam.mcs t
```

This is **logically false** in general modal logic:
- `p` does not entail `Box(p)`
- The formula `p → Box(p)` is the characteristic axiom of logic **S5**, but it's not a theorem of TM logic
- An MCS containing `p` need not contain `Box(p)`

### Mathematical Explanation

The modal_backward condition is designed for **multi-family bundles** where:
- If phi holds at ALL families at time t (universal quantification)
- Then Box(phi) must be derivable (because "all accessible worlds satisfy phi")

With a single family, the universal quantification becomes trivial, and the condition degenerates to requiring every formula to be necessarily true.

### Resolution Path

**Option A**: Multi-family bundle construction (modal saturation)
- Build multiple families to ensure proper universal quantification
- The ModalSaturation.lean module sketches this approach

**Option B**: Use CanonicalMCS domain directly
- The `CanonicalFMCS` construction doesn't have this problem because it uses all MCSes
- But this requires `D = CanonicalMCS`, not `D = Int`

---

## 3. Blocker 2: forward_F / backward_P Failure in Linear Chains

### Location
IntBFMCS.lean, lines 1199 and 1213

### The Definitions

From TemporalCoherence.lean:

```lean
structure TemporalCoherentFamily (D : Type*) [Preorder D] [Zero D] extends FMCS D where
  forward_F : ∀ t : D, ∀ φ : Formula,
    Formula.some_future φ ∈ mcs t → ∃ s : D, t < s ∧ φ ∈ mcs s
  backward_P : ∀ t : D, ∀ φ : Formula,
    Formula.some_past φ ∈ mcs t → ∃ s : D, s < t ∧ φ ∈ mcs s
```

**Mathematical Meaning**:
- `forward_F`: If F(phi) (some-future phi) is in the MCS at time t, there exists a later time s > t where phi is in the MCS
- `backward_P`: If P(phi) (some-past phi) is in the MCS at time t, there exists an earlier time s < t where phi is in the MCS

These are **witness existence** conditions for the existential temporal operators.

### The Linear Chain Construction

The `intChainMCS` builds a Z-indexed family of MCSes:

```lean
def intChainMCS (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) : Set Formula :=
  if t = 0 then M0
  else if 0 < t then (posChain M0 h_mcs0 t.toNat).1
  else (negChain M0 h_mcs0 (-t).toNat).1
```

Where `posChain` iterates `successorMCS` (Lindenbaum extension of g_content) and `negChain` iterates `predecessorMCS` (Lindenbaum extension of h_content).

### Why It Fails

The fundamental problem is that **Lindenbaum extension is non-deterministic** and can introduce formulas that "kill" F/P formulas.

**Detailed Explanation**:

1. Suppose F(phi) is in the MCS at position t (i.e., some-future phi holds)
2. F(phi) = ~G(~phi) by definition (where G = all-future)
3. When building position t+1 via Lindenbaum extension of g_content(M_t):
   - The extension is free to add ANY consistent formula
   - It could add G(~phi) without contradiction (if ~phi is consistent)
4. If G(~phi) is added at some position s > t:
   - By G-propagation, ~phi is in all positions > s
   - The phi witness can never appear after position s
5. Since F(phi) = ~G(~phi), and G(~phi) was added, we now have both F(phi) and G(~phi) in different parts of the chain
   - This doesn't contradict consistency (they're at different positions)
   - But it means **the witness for F(phi) doesn't exist in the chain**

### Concrete Example

```
Position 0: M0 contains F(p) = ~G(~p)
Position 1: Lindenbaum of g_content(M0) - might add G(~p)
Position 2: Contains ~p (from G(~p) at position 1)
Position 3: Contains ~p (from G(~p) at position 1)
...all future positions contain ~p...

Result: F(p) at position 0 has NO witness p in the chain
```

### Why This Is Fundamental

The code comments state (lines 1157-1174):

> Linear chain constructions cannot satisfy forward_F because F-formulas don't persist through generic Lindenbaum extensions. When we build position n+1 from position n, the Lindenbaum extension can introduce G(~phi), which kills F(phi) = ~G(~phi).

This is not a flaw in the implementation - it's a **fundamental limitation of linear chain constructions**.

---

## 4. The Working Alternative: CanonicalFMCS

### Why CanonicalMCS Works

From CanonicalFMCS.lean:

```lean
structure CanonicalMCS where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

-- The domain is ALL maximal consistent sets
noncomputable def canonicalMCSBFMCS : FMCS CanonicalMCS where
  mcs := fun w => w.world  -- identity mapping
  ...
```

**Key Insight**: When the domain is ALL MCSes:
- The witness from `canonical_forward_F` is automatically in the domain
- No reachability requirement needed
- F/P are trivially proven

```lean
theorem canonicalMCS_forward_F (w : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi ∈ canonicalMCS_mcs w) :
    ∃ s : CanonicalMCS, w ≤ s ∧ phi ∈ canonicalMCS_mcs s := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F w.world w.is_mcs phi h_F
  let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  exact ⟨s, CanonicalMCS.le_of_canonicalR w s h_R, h_phi_W⟩  -- NO SORRY!
```

The witness MCS `W` from `canonical_forward_F` is an MCS, hence a `CanonicalMCS` element.

---

## 5. The Architectural Gap

### The Core Problem

The completeness pipeline requires `BFMCS Int` (or more generally `BFMCS D` where `D` has ordered additive group structure) because:

```lean
-- From TaskFrame.lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  ...
```

The semantic evaluation requires `D` to be an **ordered additive group** (like Int, Rat, or Real).

But:
- `CanonicalMCS` is NOT an ordered additive group
- `CanonicalMCS` has a preorder (via CanonicalR), but no group structure
- The preorder is NOT total

### Why We Can't Just Use CanonicalMCS

1. **Type mismatch**: `TaskFrame D` requires `[AddCommGroup D]` which `CanonicalMCS` doesn't have
2. **Semantic evaluation**: The truth definition `TaskModel.satisfies` uses `task_rel w x u` where `x : D` is a duration
3. **Completeness statement**: Must produce a `TaskModel` over the right domain type

### The Transfer Attempt

The IntFMCSTransfer module attempted to transfer from CanonicalMCS to Int:

```lean
-- From IntFMCSTransfer comments:
-- Instead of implementing the full FMCSTransfer (which requires a bijection between
-- CanonicalMCS and Int - impossible since CanonicalMCS is uncountable)
```

**Why bijection is impossible**:
- `CanonicalMCS` = set of all MCSes over a countable formula language
- The set of all MCSes has cardinality 2^aleph_0 (uncountable)
- Int has cardinality aleph_0 (countable)

---

## 6. What Would Be Needed to Resolve Each Blocker

### For modal_backward

**Modal Saturation Approach**:
1. Start with a single FMCS family
2. For each formula phi and time t:
   - If phi is in the MCS at t but Box(phi) is not
   - Add a new "witness family" where ~phi is at t
3. This creates a multi-family bundle where:
   - phi in ALL families at t genuinely implies Box(phi) (because if phi fails somewhere, we added a family)

**Complexity**: Requires transfinite iteration (potentially uncountable many families)

### For forward_F / backward_P

**Option A: Omega-squared construction**
- Process F-obligations IMMEDIATELY when they appear
- Before Lindenbaum extension, ensure the witness is placed
- Requires careful bookkeeping of obligations

**Option B: Different domain type**
- Use a domain that directly corresponds to MCSes
- Define a suitable group structure on MCS quotients
- This may require significant mathematical innovation

**Option C: Finite model property**
- Prove TM has finite model property
- Only need finite chains where witnesses can be enumerated explicitly
- This sidesteps the Lindenbaum extension problem

---

## 7. Summary of Definitions

### Core Structures

| Structure | File | Purpose |
|-----------|------|---------|
| `FMCS D` | Bundle/FMCS.lean | Time-indexed family of MCSes |
| `BFMCS D` | Bundle/BFMCS.lean | Bundle of FMCS with modal coherence |
| `TemporalCoherentFamily D` | Bundle/TemporalCoherence.lean | FMCS with F/P witnesses |
| `CanonicalMCS` | Bundle/CanonicalFMCS.lean | All MCSes as a type |
| `TaskFrame D` | Semantics/TaskFrame.lean | Task frames for semantics |

### Key Conditions

| Condition | Definition | Mathematical Meaning |
|-----------|------------|---------------------|
| `modal_forward` | Box(phi) in any family → phi in all families | Box distributes over universal |
| `modal_backward` | phi in all families → Box(phi) in each family | Universal implies Box |
| `forward_F` | F(phi) at t → exists s > t with phi at s | Existential future witness |
| `backward_P` | P(phi) at t → exists s < t with phi at s | Existential past witness |

---

## 8. Recommendations

### Short-term (Tactical)

1. **Document the sorry status** - The current sorries are architectural, not proof gaps
2. **Use CanonicalMCS completeness** - This is fully proven; the Int transfer is the issue
3. **Consider alternative semantic domains** - Perhaps D doesn't need to be Int specifically

### Long-term (Strategic)

1. **Investigate finite model property** - If TM has FMP, finite witnesses suffice
2. **Omega-squared construction** - Implement proper obligation-driven chain building
3. **Modal saturation** - Implement multi-family bundle for proper modal coherence
4. **Alternative algebraic approach** - Consider whether completeness can be stated differently

---

## Appendix: File References

| File | Key Content |
|------|-------------|
| `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` | BFMCS definition, modal coherence |
| `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` | forward_F, backward_P definitions |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` | Sorry-free CanonicalMCS construction |
| `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` | Int chain with F/P sorries |
| `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` | modal_backward sorry |
| `Theories/Bimodal/Semantics/TaskFrame.lean` | TaskFrame D definition |
