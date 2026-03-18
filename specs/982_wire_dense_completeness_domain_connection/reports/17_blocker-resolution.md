# Research Report: Task #982 Blocker Resolution

**Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
**Date**: 2026-03-17
**Focus**: Resolve coverage gap in dovetailing construction for has_future/has_past proofs

## Executive Summary

The blocking issue in Phase 4 stems from a subtlety in the dovetailing construction: when a point p enters at step s with point_index L, the obligation (L, k) for formula phi with encoding k is processed at step pair(L, k), which may occur BEFORE step s. The suggested resolution using F^i(neg bot) with growing encodings is **mathematically sound** and provides an elegant proof path.

## The Coverage Gap Problem (Detailed Analysis)

### Construction Mechanics

The dovetailed build works as follows:
- At step 0: Initialize with root MCS at index 0
- At step n+1: Process obligation `unpair(n+1) = (p, f)` where p is a point index and f is a formula encoding
- A point entering at step s gets index L = list_length at step s-1
- The obligation (L, k) is processed at step pair(L, k)

### The Gap Scenario

Consider a point p entering at step s:
1. p.point_index = L (assigned as list length when p enters)
2. Formula phi has encoding k
3. Step pair(L, k) processes obligation (L, k)

**Key question**: Is pair(L, k) >= s, ensuring p exists when (L, k) is processed?

**Analysis**:
- Cantor pairing satisfies: pair(L, k) >= L (triangular property)
- But L = list_length at step s-1, which can be much smaller than s
- If list grows slowly (few points per step), L << s is possible
- Therefore pair(L, k) can be less than s, meaning p doesn't exist when (L, k) is processed

### Example

- Step 1: Add witness w1, list length = 2
- Step 2: No new points, list length = 2
- Step 3: No new points, list length = 2
- Step 4: Add point p, p.point_index = 2
- pair(2, 0) = 2 * 3 / 2 = 3
- At step 3, obligation (2, 0) is processed
- But p (index 2) doesn't exist yet at step 3 (added at step 4)!

## The Density Argument Resolution

### Mathematical Foundation

The density axiom provides: F(phi) -> F(F(phi)) for all phi.

From this, we derive for any MCS M:
- F(neg bot) in M (by forward seriality)
- F(F(neg bot)) in M (by density once)
- F^i(neg bot) in M for all i >= 1 (by induction)

Let phi_i = F^{i-1}(neg bot), so F(phi_i) = F^i(neg bot).

### Encoding Growth

The formula encodings grow with formula complexity:
- phi_1 = neg bot has encoding k_1
- phi_2 = F(neg bot) has encoding k_2 > k_1
- phi_i = F^{i-1}(neg bot) has encoding k_i

**Key property**: The sequence k_i is strictly increasing and unbounded.

This follows from:
1. Formula encodings are injective (distinct formulas have distinct encodings)
2. The formulas phi_i are all distinct (structurally)
3. The encoding uses a recursive structure where sub-formulas contribute to the encoding

### The Resolution Proof Sketch

**Given**: Point p in timeline at step n with F(neg bot) in p.mcs.

**Goal**: Show there exists q in timeline with CanonicalR(p.mcs, q.mcs).

**Construction**:

1. **Find large encoding**:
   - Let L = p.point_index
   - By encoding growth, there exists i such that k_i > n - L
   - Therefore pair(L, k_i) >= L + k_i > n (using pair(a,b) >= a + b for a,b > 0)
   - Choose i* = min{i : pair(L, k_i) > n}

2. **Show phi_{i*} obligation is processed with p present**:
   - At step pair(L, k_{i*}), obligation (L, k_{i*}) is processed
   - Since pair(L, k_{i*}) > n and p is in build at step n
   - By monotonicity, p is in build at step pair(L, k_{i*}) - 1
   - The lookup at index L returns p (by point index invariant)

3. **Show witness is added**:
   - phi_{i*} = F^{i*-1}(neg bot) decodes from encoding k_{i*}
   - F(phi_{i*}) = F^{i*}(neg bot) is in p.mcs (by density)
   - processForwardObligationDovetailed adds witness W with:
     - CanonicalR(p.mcs, W) (via executeForwardStep)
     - phi_{i*} in W

4. **Conclude**:
   - W is in dovetailedBuild at step pair(L, k_{i*})
   - Hence W is in dovetailedTimelineUnion
   - CanonicalR(p.mcs, W) provides the required future witness

## Key Lemmas Needed

### Lemma 1: Encoding Growth (encoding_unbounded)

```lean
theorem encoding_unbounded :
    ∀ N : Nat, ∃ i : Nat,
      let phi := iterate Formula.some_future i (Formula.neg Formula.bot)
      ∃ k, decodeFormulaStaged k = some phi ∧ k > N
```

**Proof approach**: Show that formula size grows with iteration depth, and encoding is roughly proportional to size (or at least grows monotonically with complexity).

### Lemma 2: Density Iteration (density_iterate_in_mcs)

```lean
theorem density_iterate_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) (n : Nat) :
    Formula.some_future (iterate Formula.some_future n phi) ∈ M
```

**Proof approach**: Induction on n, using `SetMaximalConsistent.density_F_to_FF` at each step.

### Lemma 3: Large Step Coverage (witness_at_large_step)

```lean
theorem witness_at_large_step
    (p : DovetailedPoint) (hp : p ∈ dovetailedBuild n)
    (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs)
    (k : Nat) (h_dec : decodeFormulaStaged k = some phi)
    (h_large : Nat.pair p.point_index k > n) :
    ∃ w ∈ dovetailedBuild (Nat.pair p.point_index k),
      CanonicalR p.mcs w.mcs ∧ phi ∈ w.mcs
```

**Proof approach**:
- At step pair(p.point_index, k), p is in build (monotonicity from n)
- By point index invariant, getPointAt returns p at index p.point_index
- processForwardObligationDovetailed adds the witness

### Lemma 4: Main Theorem (dovetailedTimeline_has_future)

```lean
theorem dovetailedTimeline_has_future
    (p : DovetailedPoint) (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof) :
    ∃ q : DovetailedPoint, q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR p.mcs q.mcs
```

**Proof structure**:
1. p is in build at some step n (from hp)
2. F(neg bot) in p.mcs (seriality)
3. Find i with encoding k_i of F^{i-1}(neg bot) satisfying pair(p.point_index, k_i) > n
4. F^i(neg bot) = F(F^{i-1}(neg bot)) is in p.mcs (density iteration)
5. Apply witness_at_large_step with phi = F^{i-1}(neg bot) and k = k_i
6. The witness is in dovetailedTimelineUnion

## Potential Obstacles and Mitigations

### Obstacle 1: Proving Encoding Growth

The encoding function is defined implicitly via `Encodable Formula`. We need to show that iterating F increases the encoding.

**Mitigation**: Use the Encodable instance structure. For staged formulas, the encoding likely uses a structural recursion that increases with nesting depth. If necessary, prove a lemma relating formula depth to encoding bounds.

### Obstacle 2: Connecting decodeFormulaStaged to iterate

The density argument uses `iterate Formula.some_future n phi`, but we need `decodeFormulaStaged k = some (iterate ...)` for some k.

**Mitigation**: Use `formula_has_encoding` for each iterated formula. Since iterate produces a valid formula, it has an encoding.

### Obstacle 3: Nat.pair Lower Bound

We need pair(L, k) >= L + k (or similar) to ensure large k implies large step.

**Mitigation**: The triangular pairing satisfies pair(a, b) = (a + b)(a + b + 1)/2 + a >= a + b for a, b >= 0. This is a standard property that should be in Mathlib or easy to prove.

## Alternative Approaches (if primary fails)

### Alternative 1: Backlog Processing

Modify the construction to maintain a backlog of unprocessed obligations. When a new point enters, add all missed obligations to the backlog and process them eventually.

**Complexity**: Moderate - requires construction changes and new invariants.

### Alternative 2: (step, formula) Enumeration

Instead of (point_index, formula) pairs, enumerate (step, formula) pairs. At step pair(s, k), process formula k for all points that entered at step s.

**Complexity**: High - requires significant construction redesign.

### Alternative 3: Direct Witness Construction

Instead of relying on dovetailing, directly construct the witness MCS and prove it's in the timeline.

**Complexity**: High - requires showing all comparable MCSs eventually enter.

## Implementation Recommendations

1. **Phase 4A**: Prove helper lemmas
   - encoding_unbounded (or equivalent pair growth lemma)
   - density_iterate_in_mcs
   - Nat.pair lower bound (pair(a,b) >= a + b)

2. **Phase 4B**: Prove witness_at_large_step
   - Combines point index invariant with processing logic
   - May require strengthening existing processForwardObligationDovetailed lemmas

3. **Phase 4C**: Complete main theorems
   - dovetailedTimeline_has_future using the above
   - dovetailedTimeline_has_past (symmetric using P and backward witness)

4. **Estimated effort**: 4-6 hours for remaining Phase 4 work

## Mathematical Correctness Check

**Is the density argument sound?**
- YES: The axiom F(phi) -> F(F(phi)) is part of the dense logic's axiom system
- The iteration property follows by induction
- The encoding growth is a property of the formula structure

**Does F^i(neg bot) work?**
- YES: neg bot is in every MCS (theorem_in_mcs via double negation)
- F(neg bot) is in every MCS (forward seriality axiom)
- F^i(neg bot) is in every MCS (density iteration)
- The witness for F^i(neg bot) satisfies CanonicalR

**What lemmas are needed?**
- encoding_unbounded or pair_growth: Show encodings grow
- density_iterate_in_mcs: F in M implies F^n in M
- witness_at_large_step: Large encoding means p is present when processed

## Conclusion

The suggested density resolution is **mathematically correct and elegant**. The key insight is that while the specific encoding k of phi may give pair(L, k) < s, we can use a semantically equivalent F-formula (from the density iteration sequence) with a larger encoding to ensure processing occurs after p enters.

The proof requires approximately 3-4 supporting lemmas:
1. Encoding growth (or pair lower bound)
2. Density iteration membership
3. Large-step witness addition
4. Main theorem assembly

This approach requires no construction modifications and leverages existing density infrastructure (SetMaximalConsistent.density_F_to_FF).

## References

- CantorPrereqs.lean: `formula_has_encoding`, `SetMaximalConsistent.density_F_to_FF`
- DovetailedBuild.lean: Current sorry locations and partial proof
- Dovetailing.lean: `forall_obligation_eventually_processed`, pair properties
- CanonicalSerialFrameInstance.lean: Pattern for NoMaxOrder proof using executeForwardStep
