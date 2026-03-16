# Research Report: Task #951 (research-008) -- Syntactic Reconstruction: MCS Subsets as Times, Task Relation, and History Functions

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-02-28
**Session**: sess_1772318011_5deb2e
**Mode**: Team Research (2 teammates)
**Dependencies**: research-001 through research-007, phases A-D completed, phase E blocked
**Teammates**:
- Teammate A: MCS subsets as times and the task relation
- Teammate B: Histories as MCS-preserving functions and convexity

---

## Summary

This report addresses the user's proposed new approach: define temporal structure from appropriately
constrained subsets of all MCSes, study the task relation to define it from pure syntax given those
times, and then define histories as functions from convex time intervals to MCSes that preserve the
task relation.

**Critical finding**: The proposed approach is already substantially implemented in the codebase in
two complementary forms. The `BidirectionalFragment` IS the constrained MCS subset providing
temporal structure. The `FMCS` structure IS the history-as-function-from-time-to-MCS with
task-relation preservation (captured by `forward_G`/`backward_H`). The `WorldHistory` structure
IS the semantic form of a history with convex domain. The fundamental Phase E blocker is NOT about
these structures -- it is the algebraic gap: `BidirectionalFragment` has `LinearOrder` but lacks
`AddCommGroup D`, while `valid` requires `AddCommGroup D`.

**Recommendation**: The enriched canonical chain (`CanonicalChain.lean`) is the immediate resolution
path. Fix the `forward_F`/`backward_P` proofs using omega-squared diagonal processing. This gives a
sorry-free `FMCS Int` that fits the existing architecture without changing `valid` or the axiom set.

---

## Key Findings

### Finding 1: The BidirectionalFragment Is the Correct MCS Subset for Times

The `BidirectionalFragment M0 h_mcs0` (`BidirectionalReachable.lean:119-125`) is the right
constrained MCS subset to serve as "times." It restricts to MCSes reachable from a root `M0` by
finite sequences of `CanonicalR` edges in either direction.

**Why it works as a temporal structure:**

| Property | Status | Location |
|----------|--------|----------|
| Total preorder (`IsTotal`) | PROVEN | `BidirectionalReachable.lean:768` |
| Forward_F witness closure | PROVEN | `BidirectionalReachable.lean:195-204` |
| Backward_P witness closure | PROVEN | `BidirectionalReachable.lean:214-228` |
| G/H coherence | PROVEN | `CanonicalCompleteness.lean:76-81` |
| LinearOrder (Antisymmetrization quotient) | PROVEN | `BidirectionalReachable.lean:784-795` |
| Nonempty / contains root | PROVEN | `BidirectionalReachable.lean:140-146` |

**Why it cannot be the time type `D` directly**: The `BidirectionalQuotient` has `LinearOrder` but
not `AddCommGroup`. The `valid` definition requires `AddCommGroup D` for the `time_shift`
construction underlying MF/TF soundness. As research-006 established, there is no natural additive
group structure on the quotient.

### Finding 2: CanonicalR IS the Temporal Ordering -- Defined Purely from Syntax

The `CanonicalR` preorder (`CanonicalFrame.lean:63-64`) is:

```
CanonicalR M M' := GContent(M) ⊆ M'
```

where `GContent(M) = {phi | G(phi) ∈ M}`. This is the syntactic definition of temporal ordering:
- `M` is "earlier" than `M'` if everything committed to the future at `M` holds at `M'`
- Reflexivity: from `G(phi) -> phi` (T-axiom), `GContent(M) ⊆ M` -- proven (`canonicalR_reflexive`)
- Transitivity: from `G(phi) -> G(G(phi))` (Temporal 4), `CanonicalR M M'` and `CanonicalR M' M''` implies `CanonicalR M M''` -- proven (`canonicalR_transitive`)

The ordering is PURELY SYNTACTIC: it reads off `G`-formulas from the MCS and checks containment.
No external time structure is assumed.

**GContent as a measure of time**: Larger `GContent` = "earlier" time (stronger future commitments);
smaller = "later" (commitments consumed). Moving forward in time consumes G-formulas via the
T-axiom.

**Duality**: `CanonicalR M M'` for MCSes implies `CanonicalR_past M' M` and vice versa -- the
single ordering captures BOTH temporal directions.

### Finding 3: The Task Relation Defined from Pure Syntax

From `TaskFrame.lean:84-103`, the task relation `task_rel : WorldState -> D -> WorldState -> Prop`
must satisfy:

1. **Nullity**: `task_rel w 0 w` (reflexivity)
2. **Compositionality**: `task_rel w x u ∧ task_rel u y v → task_rel w (x+y) v` (transitivity)

**Syntactic definition**: The CanonicalR preorder directly provides the task relation for the
canonical model:
```
canonical_task_rel M d M' := CanonicalR M.world M'.world
```

- **Nullity**: Immediate from `canonicalR_reflexive` (T-axiom gives `GContent(M) ⊆ M`)
- **Compositionality**: Immediate from `canonicalR_transitive` (Temporal-4 gives transitivity)

The duration `d` is an element of the time type `D`; in the Int-indexed chain, it is the integer
distance between chain positions.

**Key observation**: The task relation is defined independently of the additive structure of `D`.
The FMCS coherence conditions (`forward_G`, `backward_H`) ARE the MCS-level realization of the task
relation: they say the MCS assignment respects CanonicalR over time.

### Finding 4: FMCS IS the History-as-Function-from-Time-to-MCS

The `FMCS` structure (`FMCSDef.lean`) is already the formal implementation of "history as function
from time to MCS with task-relation preservation":

```lean
structure FMCS where
  mcs : D -> Set Formula                   -- sigma : D -> MCS
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : ...                          -- G-coherence (= forward task preservation)
  backward_H : ...                         -- H-coherence (= backward task preservation)
```

The `forward_G` condition says: if `G(phi) ∈ mcs(t)`, then `phi ∈ mcs(s)` for all `s ≥ t`. This
IS the MCS-level statement that the history preserves the task relation forward. `backward_H` is
the symmetric past condition.

**Why FMCS uses full domain**: FMCS maps all of `D` to MCSes (not a subdomain). This makes
convexity trivially satisfied (`Set.ordConnected_univ`).

### Finding 5: WorldHistory Already Implements Convex-Domain Histories

The `WorldHistory` structure (`WorldHistory.lean:69-97`) is the semantic counterpart:

```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D -> Prop                              -- The convex interval I ⊆ D
  convex : Set.OrdConnected {t | domain t}        -- I is order-connected
  states : (t : D) -> domain t -> F.WorldState   -- sigma : I -> WorldState
  respects_task : forall s t, domain s -> domain t ->
    s <= t -> F.task_rel (states s) (t - s) (states t)
```

The `convex` field is equivalent to Mathlib's `Set.OrdConnected` (`Mathlib.Order.Interval.Set.Defs`).
The `respects_task` field is the formal statement of "preserving the task relation over duration."

**Convexity and completeness**: For the completeness proof, all histories use `domain = Set.univ`,
making convexity trivially satisfied via `Set.ordConnected_univ`. Convexity matters for general
models but is not the bottleneck here.

### Finding 6: The Fundamental AddCommGroup Gap

Both teammates independently confirm: the Phase E blocker is that `BidirectionalFragment` (and its
quotient) has `LinearOrder` but not `AddCommGroup D`. The `valid` definition requires `AddCommGroup D`
because:

1. `time_shift sigma Delta` uses `z + Delta` -- needs `AddCommGroup`
2. `respects_task` uses `t - s` -- needs `AddCommGroup`
3. MF axiom soundness uses `time_shift` -- breaks without AddCommGroup
4. TF axiom soundness uses `time_shift` -- breaks without AddCommGroup

**This is not a deficiency in the MCS-subset approach -- it is a structural property of the TM
semantics that task composition requires temporal arithmetic.**

### Finding 7: The Enriched Canonical Chain Is the Resolution Path

`CanonicalChain.lean` provides the Int-indexed chain with most proofs complete:

| What's proven | Lean name | Status |
|---------------|-----------|--------|
| Ordering | `enrichedForwardStep_ordered` | PROVEN |
| Witness placement | `enrichedForwardStep_witness_placed` | PROVEN |
| Backward ordering | `enrichedBackwardStep_ordered` | PROVEN |
| Backward witness placement | `enrichedBackwardStep_witness_placed` | PROVEN |
| Decode surjectivity | `decodePosFormula_encodePosFormula` | PROVEN |
| Full chain construction | `buildEnrichedCanonicalChain` | PROVEN |

**What remains**: `forward_F`/`backward_P` for the enriched chain FMCS.

The gap: The current enriched construction checks `F(phi) ∈ chain(n)` at step `n`, but `F(phi)`
might enter the chain at position `t ≠ n`. The fix requires **omega-squared diagonal processing**:
decode the obligation as `(position, formula)` and check `F(phi) ∈ chain(pos)` for the decoded
position (when `pos ≤ n`). This leverages the already-proven `decodePosFormula_encodePosFormula`
surjectivity.

---

## Synthesis

### Conflicts Found: 1

**Conflict**: Teammate A concludes "Do NOT pursue MCS subsets as direct time replacement" while
Teammate B says the proposed approach "is already implemented" (in FMCS form). These are
complementary, not contradictory: MCS subsets ARE the right structure for the syntactic/proof-
theoretic level (FMCS), but cannot serve as `D` in the semantic `valid` definition. Both teammates
are correct from their respective levels.

**Resolution**: The user's proposal is realized at two levels:
- **Proof-theoretic level** (FMCS): MCS subsets as times ✓ (already implemented via BidirectionalFragment + CanonicalR)
- **Semantic level** (`D` in `valid`): Requires AddCommGroup, which MCS subsets lack

The bridge is the Int embedding: FMCS BidirectionalFragment → FMCS Int (via enriched chain) → semantic model.

### Gaps Identified: 2

1. **Forward_F/Backward_P for enriched chain**: The omega-squared diagonal fix is
   technically clear but not yet implemented. Estimated 4-6 hours.

2. **`fully_saturated_bfmcs_exists_int`** (TemporalCoherentConstruction.lean:600): Combining
   temporal coherence (chain FMCS) with modal saturation (diamond witnesses). This is independent
   of the history/convexity approach and requires separate investigation.

### What the User's Proposed Approach Achieves

The user's proposal to "define temporal structure from appropriately constrained subsets of all MCSes"
is mathematically correct and is already realized in the proof:

1. **Times** = `BidirectionalFragment` quotient (constrained MCS subset with CanonicalR total order)
2. **Task relation** = CanonicalR (defined purely from syntax via GContent inclusion)
3. **Histories** = FMCS (functions from `D` to MCSes preserving task relation via forward_G/backward_H)
4. **Convexity** = trivially satisfied (full-domain FMCS, so `domain = Set.univ`)

The only remaining step is embedding the fragment time type into `Int` to obtain `AddCommGroup`
structure required by `valid`. This is the enriched chain fix.

---

## Detailed Recommendations

### Recommendation 1 (Primary): Fix Enriched Chain forward_F/backward_P

**Problem location**: `CanonicalChain.lean` -- the enriched chain checks `F(phi) ∈ chain(n)` but
needs to check `F(phi) ∈ chain(pos)` for decoded position `pos`.

**Lean sketch**:
```lean
-- Fix: use decodePosFormula to get (pos, phi) pairs
-- Modify enrichedForwardStep to check F(phi) ∈ chain(pos) for pos ≤ n
-- Proof of forward_F:
-- For any t : Int, F(phi) ∈ chain(t):
--   1. decodeFormula surjectivity: ∃ k, decodePosFormula k = (t, phi)
--   2. At step k, pos = t is decoded and F(phi) ∈ chain(t) is checked
--   3. phi is placed in chain(k+1) ⊇ chain(t+1) ∋ phi
--   4. t < k+1, so ∃ s = k+1 > t with phi ∈ chain(s) □
```

**Key lemmas available**:
- `decodePosFormula_encodePosFormula` (CanonicalChain.lean:527) -- surjectivity ✓
- `enrichedForwardStep_witness_placed` (CanonicalChain.lean:657) -- placement ✓

**Effort**: 4-6 hours. **Risk**: Low.

### Recommendation 2 (Secondary): Address `fully_saturated_bfmcs_exists_int`

This sorry (TemporalCoherentConstruction.lean:600) requires combining:
- Sorry-free `FMCS Int` (from Recommendation 1)
- Modal saturation (diamond witness families)

Once Recommendation 1 provides sorry-free `FMCS Int`, the modal saturation argument is standard
Lindenbaum extension. Estimated 6-10 additional hours.

### Recommendation 3 (Architectural): No Changes to `valid` Required

The analysis confirms:
- The `valid` definition should remain unchanged (preserves MF/TF soundness)
- No new axioms needed in `Axioms.lean`
- The AddCommGroup constraint is satisfied by embedding into `Int`
- The completeness proof goes via BFMCS truth (bypassing explicit WorldHistory/ShiftClosed)

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | MCS subsets as times, task relation | completed | high | Confirmed CanonicalR as syntactic task relation; identified omega-squared diagonal fix for enriched chain |
| B | Histories, convexity | completed | high | Confirmed WorldHistory/FMCS already implement the proposal; ShiftClosed bypassed by BFMCS approach |

---

## Sorry Inventory

| Sorry | File | Line | Resolution |
|-------|------|------|------------|
| `buildDovetailingChainFamily_forward_F` | DovetailingChain.lean | 1869 | Replace with enriched chain forward_F (omega-squared diagonal fix) |
| `buildDovetailingChainFamily_backward_P` | DovetailingChain.lean | 1881 | Replace with enriched chain backward_P (symmetric fix) |
| `fully_saturated_bfmcs_exists_int` | TemporalCoherentConstruction.lean | 600 | Combine sorry-free FMCS Int + modal saturation |

**Total**: 3 sorries, all in the temporal coherence / BFMCS construction chain.

---

## References

- `BidirectionalReachable.lean` -- fragment construction and LinearOrder proof
- `CanonicalChain.lean` -- enriched chain with omega-squared diagonal encoding
- `CanonicalCompleteness.lean` -- fragment-level FMCS (sorry-free)
- `DovetailingChain.lean` -- current sorry locations
- `FMCSDef.lean` -- FMCS as history function
- `WorldHistory.lean` -- semantic history with convex domain
- `Validity.lean` -- the `valid` definition to preserve
- `Mathlib.Order.Interval.Set.Defs` -- `Set.OrdConnected` (convexity)
- `Mathlib.Algebra.Order.UpperLower` -- `Set.OrdConnected.vadd` (translation invariance)
- Previous reports: research-004 (FPClosure), research-005 (Rat embedding), research-006 (automorphism analysis), research-007 (approach comparison)
