# Research Report: Task 973

## Executive Summary

The NoMaxOrder and NoMinOrder instances for ConstructiveQuotient are straightforward to prove using the existing infrastructure. The proof pattern from DiscreteTimeline.lean can be directly adapted - the key insight is that every MCS contains F(neg bot) and P(neg bot) via the seriality axioms, which gives forward/backward witnesses. The `canonicalR_strict` theorem then ensures strictness in the quotient.

## Analysis

### Current Sorry States

**Line 580 (NoMaxOrder.exists_gt)**:
```
case a
M0 : Set Formula
h_mcs0 : SetMaximalConsistent M0
w : ConstructiveFragment M0 h_mcs0
|- exists b, [[w]] < b
```

**Line 585 (NoMinOrder.exists_lt)**:
```
case a
M0 : Set Formula
h_mcs0 : SetMaximalConsistent M0
w : ConstructiveFragment M0 h_mcs0
|- exists b, b < [[w]]
```

### Working Proof Pattern (DiscreteTimeline.lean)

The DiscreteTimeline.lean proof at lines 247-285 follows this structure:

1. **Induction**: Use `Antisymmetrization.ind` to reduce to element level
2. **Get seriality witness**: Use `staged_timeline_has_future/past` to get CanonicalR successor/predecessor
3. **Establish strictness**: Use `canonicalR_strict` to show the reverse CanonicalR does NOT hold
4. **Construct quotient element**: Use `toAntisymmetrization` to lift to quotient
5. **Prove strict inequality**: Use `toAntisymmetrization_lt_toAntisymmetrization_iff` and case analysis on the disjunctive le definition

Key code pattern (NoMaxOrder):
```lean
obtain <q, hq_mem, hq_R> := staged_timeline_has_future root_mcs root_mcs_proof p.1 p.2
have h_strict : not CanonicalR q.mcs p.1.mcs :=
  Canonical.canonicalR_strict p.1.mcs q.mcs p.1.is_mcs q.is_mcs hq_R
let q' : DiscreteTimelineElem root_mcs root_mcs_proof := <q, hq_mem>
use toAntisymmetrization (. <= .) q'
rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
constructor
. exact Or.inr hq_R
. intro hqp
  cases hqp with
  | inl h_eq => exact h_strict (h_eq.symm subst hq_R)
  | inr h_R => exact h_strict h_R
```

### Key Lemmas and Definitions

**Available in scope (from imports)**:

1. `mcs_contains_seriality_future` (CanonicalTimeline.lean:84-86):
   ```lean
   theorem mcs_contains_seriality_future (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
       Formula.some_future (Formula.neg Formula.bot) in M
   ```

2. `mcs_contains_seriality_past` (CanonicalTimeline.lean:91-93):
   ```lean
   theorem mcs_contains_seriality_past (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
       Formula.some_past (Formula.neg Formula.bot) in M
   ```

3. `executeForwardStep` (ConstructiveFragment.lean:63-66):
   Given MCS M with F(phi) in M, returns Lindenbaum witness with CanonicalR M (result)

4. `executeBackwardStep` (ConstructiveFragment.lean:72-75):
   Given MCS M with P(phi) in M, returns Lindenbaum witness with CanonicalR (result) M

5. `executeForwardStep_canonicalR` (line 81-84):
   ```lean
   theorem executeForwardStep_canonicalR {M : Set Formula} {h_mcs : SetMaximalConsistent M}
       {phi : Formula} {h_F : Formula.some_future phi in M} :
       CanonicalR M (executeForwardStep M h_mcs phi h_F)
   ```

6. `executeBackwardStep_canonicalR` (line 91-96):
   ```lean
   theorem executeBackwardStep_canonicalR {M : Set Formula} {h_mcs : SetMaximalConsistent M}
       {phi : Formula} {h_P : Formula.some_past phi in M} :
       CanonicalR (executeBackwardStep M h_mcs phi h_P) M
   ```

7. `executeForwardStep_mcs` / `executeBackwardStep_mcs` (lines 98-106):
   These confirm the witness is an MCS

8. `canonicalR_strict` (CanonicalIrreflexivityAxiom.lean:95-99):
   ```lean
   theorem canonicalR_strict
       (M N : Set Formula)
       (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
       (h_MN : CanonicalR M N) : not CanonicalR N M
   ```

9. `ConstructiveReachable.forward_witness` / `ConstructiveReachable.backward_witness`:
   Constructors showing the witness MCS is in ConstructiveFragment

10. `toAntisymmetrization_lt_toAntisymmetrization_iff` (Mathlib):
    ```lean
    theorem toAntisymmetrization_lt_toAntisymmetrization_iff :
        toAntisymmetrization (_ <= _) a < toAntisymmetrization (_ <= _) b <-> a < b
    ```

### Preorder Definition

The preorder on ConstructiveFragment (lines 235-243):
```lean
le a b := a.val = b.val or CanonicalR a.val b.val
```

Thus `a < b` means `a <= b and not (b <= a)`, which expands to:
```
(a.val = b.val or CanonicalR a.val b.val) and
not (b.val = a.val or CanonicalR b.val a.val)
```

Simplifying: `CanonicalR a.val b.val and not CanonicalR b.val a.val` (and a.val != b.val).

## Recommendations

### Proof Strategy

**NoMaxOrder (line 580)**:

1. Extract the underlying ConstructiveFragment element `w` (done by induction tactic)
2. Get seriality witness: `have h_F := mcs_contains_seriality_future w.val w.is_mcs`
3. Execute forward step to get new MCS: `let N := executeForwardStep w.val w.is_mcs _ h_F`
4. Build reachability proof: Combine w's reachability with `ConstructiveReachable.forward_witness`
5. Construct ConstructiveFragment element for N
6. Use `toAntisymmetrization` to lift to quotient
7. Prove strict inequality using `canonicalR_strict`

**NoMinOrder (line 585)**:
Symmetric using `mcs_contains_seriality_past`, `executeBackwardStep`, and `ConstructiveReachable.backward_witness`.

### Specific Tactics

**NoMaxOrder proof sketch**:
```lean
instance : NoMaxOrder (ConstructiveQuotient M0 h_mcs0) where
  exists_gt a := by
    induction a using Quotient.ind with | _ w =>
    -- Get seriality witness: F(neg bot) in w.val
    have h_F := mcs_contains_seriality_future w.val w.is_mcs
    -- Execute forward step
    let N := executeForwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_F
    have h_N_mcs := executeForwardStep_mcs (h_mcs := w.is_mcs) (h_F := h_F)
    have h_R := executeForwardStep_canonicalR (h_mcs := w.is_mcs) (h_F := h_F)
    -- N is strictly greater (by canonicalR_strict)
    have h_strict : not CanonicalR N w.val :=
      canonicalR_strict w.val N w.is_mcs h_N_mcs h_R
    -- Build reachability proof for N
    obtain <h_reach> := w.property
    have h_N_reach : Nonempty (ConstructiveReachable M0 h_mcs0 N) :=
      <ConstructiveReachable.forward_witness w.val (Formula.neg Formula.bot) h_reach w.is_mcs h_F>
    -- Construct ConstructiveFragment element for N
    let w' : ConstructiveFragment M0 h_mcs0 := <N, h_N_reach>
    -- Lift to quotient and prove strict inequality
    use toAntisymmetrization (. <= .) w'
    rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
    constructor
    . exact Or.inr h_R
    . intro h_le_back
      cases h_le_back with
      | inl h_eq =>
        -- w.val = N contradicts h_R (would need CanonicalR w.val w.val)
        exact canonicalR_irreflexive w.val w.is_mcs (h_eq subst h_R)
      | inr h_R_back =>
        exact h_strict h_R_back
```

**NoMinOrder proof sketch**:
```lean
instance : NoMinOrder (ConstructiveQuotient M0 h_mcs0) where
  exists_lt a := by
    induction a using Quotient.ind with | _ w =>
    have h_P := mcs_contains_seriality_past w.val w.is_mcs
    let N := executeBackwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_P
    have h_N_mcs := executeBackwardStep_mcs (h_mcs := w.is_mcs) (h_P := h_P)
    have h_R := executeBackwardStep_canonicalR (h_mcs := w.is_mcs) (h_P := h_P)
    -- Note: h_R : CanonicalR N w.val (backwards!)
    have h_strict : not CanonicalR w.val N :=
      canonicalR_strict N w.val h_N_mcs w.is_mcs h_R
    obtain <h_reach> := w.property
    have h_N_reach : Nonempty (ConstructiveReachable M0 h_mcs0 N) :=
      <ConstructiveReachable.backward_witness w.val (Formula.neg Formula.bot) h_reach w.is_mcs h_P>
    let w' : ConstructiveFragment M0 h_mcs0 := <N, h_N_reach>
    use toAntisymmetrization (. <= .) w'
    rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
    constructor
    . exact Or.inr h_R  -- N <= w via CanonicalR N w
    . intro h_le_back   -- assuming w <= N
      cases h_le_back with
      | inl h_eq => exact canonicalR_irreflexive N h_N_mcs (h_eq.symm subst h_R)
      | inr h_R_back => exact h_strict h_R_back
```

### Potential Challenges

1. **Quotient.ind vs Antisymmetrization.ind**: The current code uses `Quotient.ind`. This works because `ConstructiveQuotient` is defined as an `Antisymmetrization`, which is itself a `Quotient`. The proof should work identically.

2. **Implicit arguments**: The `executeForwardStep` and `executeBackwardStep` functions have many implicit arguments. We need to ensure we pass the right MCS proofs.

3. **Reachability construction**: Unlike DiscreteTimeline which has membership proofs directly, ConstructiveFragment uses `Nonempty (ConstructiveReachable ...)`. We need to construct the reachability witness via the `forward_witness`/`backward_witness` constructors.

4. **Need canonicalR_irreflexive**: For the equality case `h_eq`, we need `canonicalR_irreflexive` to derive a contradiction. This is available from CanonicalIrreflexivityAxiom.lean (line 80).

## Estimated Effort

**Complexity**: Low to Medium
**Time Estimate**: 1-2 hours

The proof structure is well-established from DiscreteTimeline.lean. The main work is:
1. Adapting the proof to use ConstructiveFragment's reachability structure
2. Getting the implicit arguments right for the execute* functions
3. Possible minor tactic adjustments for the quotient types

Both proofs follow the same pattern and can likely share structure via a helper lemma.

## Dependencies

- `Bimodal.Metalogic.Canonical.CanonicalTimeline` (seriality lemmas)
- `Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom` (canonicalR_strict, canonicalR_irreflexive)
- `Mathlib.Order.Antisymmetrization` (toAntisymmetrization_lt_toAntisymmetrization_iff)

All required lemmas are already available via imports.
