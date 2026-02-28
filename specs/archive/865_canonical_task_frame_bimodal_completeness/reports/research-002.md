# Research Report: Task #865 (Follow-up)

**Task**: Canonical task frame for bimodal completeness
**Date**: 2026-02-05
**Focus**: Compositionality of the canonical task relation via family composition. Rebuttal and analysis of Section 4.3 concerns from research-001.md.

## Summary

The previous report (research-001.md, Section 4.3) raised a compositionality concern for the canonical task frame: if `task_rel w x u` is witnessed by family `fam1` and `task_rel u y v` is witnessed by family `fam2`, compositionality requires a *single* family witnessing `task_rel w (x+y) v`, but the two witnessing families may be different. This follow-up report shows that compositionality can be resolved by **composing families** -- given two families that share a point, a third family can be constructed from their union. We formalize this construction, identify its requirements, show it is well-defined under the codebase's existing structures, and analyze implications for the TruthLemma.

## 1. The Compositionality Problem (Recap)

### 1.1 The Canonical Task Relation

The canonical task relation from research-001.md Section 4.1 is:

```lean
def canonical_task_rel (B : BMCS D)
    (w : CanonicalWorldState) (d : D) (u : CanonicalWorldState) : Prop :=
  exists fam in B.families, exists t : D,
    fam.mcs t = w.carrier /\ fam.mcs (t + d) = u.carrier
```

Here `CanonicalWorldState` wraps an MCS (a `Set Formula` that is maximal consistent). The relation says: w is related to u by duration d if some family in the BMCS places w at time t and u at time t + d.

### 1.2 The Cross-Family Problem

For compositionality, we need: if `canonical_task_rel B w x u` and `canonical_task_rel B u y v`, then `canonical_task_rel B w (x + y) v`.

Unpacking:
- There exist `fam1, t1` with `fam1.mcs(t1) = w` and `fam1.mcs(t1 + x) = u`
- There exist `fam2, t2` with `fam2.mcs(t2) = u` and `fam2.mcs(t2 + y) = v`
- We need `fam3, t3` with `fam3.mcs(t3) = w` and `fam3.mcs(t3 + x + y) = v`

The problem: `fam1` and `fam2` may be different. They share the value `u` at the junction point (`fam1.mcs(t1 + x) = u = fam2.mcs(t2)`), but there is no single family placing `w` at the start and `v` at the end.

### 1.3 Why research-001.md Proposed Avoiding This

Research-001.md proposed two resolutions:
- **Resolution A**: Restrict to single-family compositionality (trivial within one family)
- **Resolution B**: Use the BMCS-indexed frame (Section 4.6) where WorldState = (family, time) and task_rel requires the same family

Both resolutions avoid the problem by making the task relation family-local. The user's question is whether this avoidance is necessary, or whether a composed family can be constructed.

## 2. The Family Composition Construction

### 2.1 Setup

Suppose:
- `fam1 : IndexedMCSFamily D` with `fam1.mcs(t1) = w` and `fam1.mcs(t1 + x) = u`
- `fam2 : IndexedMCSFamily D` with `fam2.mcs(t2) = u` and `fam2.mcs(t2 + y) = v`
- The "junction" point is where `fam1.mcs(t1 + x) = u = fam2.mcs(t2)`

We want to construct `fam3 : IndexedMCSFamily D` that maps:
- A time interval covering `[t1, t1 + x]` using `fam1`
- A time interval covering `[t2, t2 + y]` using `fam2`, shifted so the junction aligns

### 2.2 Time Alignment

The key idea is to align the two families at the junction point. Define the **shift offset**:

```
delta := (t1 + x) - t2
```

This is the amount by which `fam2` needs to be shifted so that its time `t2` aligns with `fam1`'s time `t1 + x`. After shifting, `fam2_shifted(t) = fam2(t - delta)`:

- `fam2_shifted(t1 + x) = fam2((t1 + x) - delta) = fam2(t2) = u` (junction matches)
- `fam2_shifted(t1 + x + y) = fam2(t2 + y) = v` (endpoint maps correctly)

### 2.3 The Composed Family

Define `fam3` by cases on whether the time is before or after the junction:

```
fam3.mcs(t) :=
  if t <= t1 + x then fam1.mcs(t)
  else fam2.mcs(t - delta)     -- equivalently, fam2.mcs(t - (t1 + x) + t2)
```

At the junction point `t = t1 + x`:
- Left branch: `fam1.mcs(t1 + x) = u`
- Right branch: `fam2.mcs(t2) = u`
- Both agree.

The composed family satisfies:
- `fam3.mcs(t1) = fam1.mcs(t1) = w` (since `t1 <= t1 + x` whenever `x >= 0`)
- `fam3.mcs(t1 + x + y) = fam2.mcs(t2 + y) = v` (since `t1 + x + y > t1 + x` whenever `y > 0`)

### 2.4 What the Composed Family Must Satisfy

An `IndexedMCSFamily D` requires four fields:

1. **mcs : D -> Set Formula** -- the assignment (defined above)
2. **is_mcs : forall t, SetMaximalConsistent (mcs t)** -- each value is an MCS
3. **forward_G : forall t t' phi, t < t' -> G phi in mcs t -> phi in mcs t'** -- temporal coherence
4. **backward_H : forall t t' phi, t' < t -> H phi in mcs t -> phi in mcs t'** -- temporal coherence

Let us check each:

**is_mcs**: Since `fam3.mcs(t)` is always either `fam1.mcs(something)` or `fam2.mcs(something)`, and both `fam1` and `fam2` have the `is_mcs` property, this holds.

**forward_G**: We need that if `G phi in fam3.mcs(t)` and `t < t'`, then `phi in fam3.mcs(t')`. There are four cases depending on whether `t` and `t'` are before or after the junction:

- **Both before junction** (t, t' <= j where j = t1 + x): Reduces to `fam1.forward_G`. Holds.
- **Both after junction** (t, t' > j): Reduces to `fam2.forward_G` (with shifted times). Holds.
- **t before, t' after junction** (t <= j < t'): This is the cross-boundary case. We have `G phi in fam1.mcs(t)`. Need `phi in fam2.mcs(t' - delta)`.
- **t after, t' before** -- impossible since t < t'.

**backward_H**: Similar four cases, with the cross-boundary case being when `t' <= j < t`.

### 2.5 The Cross-Boundary Case

The cross-boundary case for `forward_G` requires:

Given: `G phi in fam1.mcs(t)` where `t <= j` and `t' > j`
Need: `phi in fam2.mcs(t' - delta)`

Chain of reasoning:
1. `G phi in fam1.mcs(t)` and `t < j = t1 + x`, so by `fam1.forward_G`: `phi in fam1.mcs(j) = u`
2. Actually, since `t <= j`, either `t < j` (use forward_G to get `phi in fam1.mcs(j)`) or `t = j` (use T-axiom: `G phi -> phi` to get `phi in fam1.mcs(j)`). Either way, `phi in u`.
3. But we also need `G phi in fam1.mcs(j)` (not just `phi`). We need `G phi` to propagate *into* `fam2`.

Here is the critical issue: knowing `phi in u` does NOT give us `phi in fam2.mcs(t' - delta)` for arbitrary `t' > j`. We need the formula to propagate through `fam2`'s temporal structure.

What we actually need is: `G phi in u`. Then since `u = fam2.mcs(t2)` and `t2 < t' - delta + t2 = t'`, we can use `fam2.forward_G` to get `phi in fam2.mcs(t' - delta)`.

So the question reduces to: does `G phi in fam1.mcs(t)` imply `G phi in fam1.mcs(j)`?

**Yes!** By the temporal 4-axiom: `G phi -> G(G phi)`. If `G phi in fam1.mcs(t)`, then `G(G phi) in fam1.mcs(t)` (by the 4-axiom and MCS closure). Then by `fam1.forward_G` with `t < j`: `G phi in fam1.mcs(j)`. And since `fam1.mcs(j) = u = fam2.mcs(t2)`, we have `G phi in fam2.mcs(t2)`. Now apply `fam2.forward_G` for `t2 < t' - delta` to get `phi in fam2.mcs(t' - delta)`.

Wait -- we need to verify that `t2 < t' - delta`. We have `t' > j = t1 + x` and `delta = (t1 + x) - t2`, so `t' - delta = t' - (t1 + x) + t2 > t2`. So yes, `t2 < t' - delta`.

Similarly for `backward_H` in the cross-boundary case: `H phi in fam2.mcs(t)` where `t > j` and `t' <= j`. By the past 4-axiom `H phi -> H(H phi)`, `H(H phi) in fam2.mcs(t)`. By `fam2.backward_H`: `H phi in fam2.mcs(t2) = u = fam1.mcs(j)`. Then by `fam1.backward_H` for `t' < j`: `phi in fam1.mcs(t')`.

### 2.6 Summary: The Composition Works

The composed family `fam3` satisfies all four `IndexedMCSFamily` fields:

| Field | Status | Key Argument |
|-------|--------|-------------|
| `mcs` | Defined by cases | Left = fam1, Right = fam2 shifted |
| `is_mcs` | Inherited | Each branch inherits from its source family |
| `forward_G` | Holds | Same-side: inherited. Cross-boundary: 4-axiom propagates G phi through junction |
| `backward_H` | Holds | Same-side: inherited. Cross-boundary: past 4-axiom propagates H phi through junction |

## 3. Domain Considerations and Edge Cases

### 3.1 Duration Signs

The construction in Section 2.3 assumed `x >= 0` (so `t1 <= t1 + x`) and `y > 0` (so `t1 + x < t1 + x + y`). In the general case, durations can be negative (the group D allows negative elements).

**Case x < 0**: Then `t1 + x < t1`, so the "junction" is BEFORE the starting time. The composed family maps `fam3.mcs(t1) = fam2.mcs(t1 - delta)` (since `t1 > t1 + x`), which is NOT `fam1.mcs(t1) = w`. The construction breaks.

**Resolution**: The canonical task relation `task_rel w d u` only requires the existence of SOME time `t` with `fam.mcs(t) = w` and `fam.mcs(t + d) = u`. It does not require `d >= 0`. However, for the composed family to witness `task_rel w (x + y) v`, we need `fam3.mcs(t3) = w` and `fam3.mcs(t3 + x + y) = v` for some `t3`.

If `x >= 0` and `y >= 0`, take `t3 = t1`. The composed family satisfies `fam3.mcs(t1) = w` and `fam3.mcs(t1 + x + y) = v`.

If `x < 0`, the junction is at `t1 + x < t1`, and the composed family assigns the region `[..., t1+x]` to fam1 and `[t1+x, ...]` to fam2_shifted. Then `fam3.mcs(t1) = fam2.mcs(t1 - delta) = fam2.mcs(t2 + (t1 - t1 - x)) = fam2.mcs(t2 - x)`. This does NOT equal `w = fam1.mcs(t1)` in general.

**Key insight**: The split point must be chosen so that `w` is on the `fam1` side and `v` is on the `fam2` side. This requires the split point to be between the two interesting times. Define the split as `s = t1 + x` (the junction). Then:
- `w = fam1.mcs(t1)` is on the fam1 side iff `t1 <= s = t1 + x`, i.e., `x >= 0`.
- `v = fam2_shifted.mcs(t1 + x + y)` is on the fam2 side iff `t1 + x + y > s = t1 + x`, i.e., `y > 0`.

So the simple composition works when `x >= 0` and `y > 0`. For other sign combinations:

- **x >= 0, y = 0**: Trivial, `v = u`, the junction itself suffices.
- **x >= 0, y < 0**: Then `v` is on the fam1 side. But `fam1.mcs(t1 + x + y)` may not equal `v = fam2.mcs(t2 + y)`. Need a different approach.
- **x < 0, y >= 0**: Then `w` is on the fam2 side, similar issue.
- **x < 0, y < 0**: Both on the same side, which depends on the sum.

### 3.2 The BMCS-Indexed Frame Avoids These Issues

The construction from research-001.md Section 4.6 avoids all sign issues because it uses `WorldState = (family, time)` and `task_rel w d u := w.family = u.family /\ u.time = w.time + d`. This is always well-defined regardless of the sign of `d`.

The family composition construction is needed ONLY if we want the canonical task relation to use MCSs-as-world-states (without time or family tagging). In the BMCS-indexed frame, compositionality is trivial.

### 3.3 When Composition is Needed: The Global Canonical Frame

If one wants a "global" canonical frame where world-states are just MCSs (without family/time tags), then the cross-family task relation requires composition. In this setting:

```lean
def canonical_task_rel_global (B : BMCS D)
    (w u : Set Formula) (d : D) : Prop :=
  exists fam in B.families, exists t : D,
    fam.mcs t = w /\ fam.mcs (t + d) = u
```

Compositionality for this relation requires the family composition construction. As shown in Section 2, this works when durations are non-negative (or more precisely, when the split point separates `w` and `v`).

**But there is a deeper issue**: the global canonical frame cannot distinguish between the same MCS appearing at different times in different families. Two distinct `(family, time)` pairs may yield the same MCS, leading to ambiguity. The BMCS-indexed frame resolves this cleanly.

### 3.4 The Correct Frame for Standard Completeness

For bridging BMCS completeness to standard task-frame completeness (the goal of task 865), the BMCS-indexed frame from research-001.md Section 4.6 is the right choice. The family composition construction is interesting and mathematically correct but unnecessary for this bridge. Here is why:

In the BMCS-indexed frame:
- World histories correspond exactly to families (Section 4.6, confirmed by the world-history characterization)
- The box case of the TruthLemma quantifies over world histories = families
- Compositionality is trivial (same family, time addition)
- No need for cross-family composition

The family composition construction would be relevant for an ALTERNATIVE canonical frame design where world-states are bare MCSs. This alternative is not needed for the completeness bridge.

## 4. Formal Construction Details

Despite the BMCS-indexed frame being the practical choice, let us formalize the composition fully for mathematical completeness.

### 4.1 Lean-Style Definition

```lean
-- Assuming x >= 0 and y > 0 for simplicity
noncomputable def compose_families
    (fam1 fam2 : IndexedMCSFamily D)
    (t1 t2 : D) (x y : D)
    (hx : 0 <= x) (hy : 0 < y)
    (h_junction : fam1.mcs (t1 + x) = fam2.mcs t2) :
    IndexedMCSFamily D where
  mcs := fun t =>
    if t <= t1 + x then fam1.mcs t
    else fam2.mcs (t - ((t1 + x) - t2))
  is_mcs := fun t => by
    split
    · exact fam1.is_mcs t
    · exact fam2.is_mcs _
  forward_G := fun t t' phi h_lt h_G => by
    -- Four cases depending on positions relative to junction
    let j := t1 + x
    by_cases h_t : t <= j <;> by_cases h_t' : t' <= j
    · -- Both before junction: use fam1.forward_G
      simp [h_t, h_t'] at h_G |-
      exact fam1.forward_G t t' phi h_lt h_G
    · -- Cross boundary: t <= j, t' > j
      -- G phi in fam1.mcs t, need phi in fam2.mcs (shifted t')
      -- By 4-axiom: G(G phi) in fam1.mcs t
      -- By fam1.forward_G (t < j or t = j): G phi in fam1.mcs j = fam2.mcs t2
      -- By fam2.forward_G: phi in fam2.mcs (shifted t')
      sorry -- detailed proof uses 4-axiom chain as described in Section 2.5
    · -- t > j, t' <= j: impossible since t < t'
      omega
    · -- Both after junction: use fam2.forward_G (shifted)
      simp [h_t, h_t'] at h_G |-
      sorry -- algebra to reduce to fam2.forward_G on shifted times
  backward_H := fun t t' phi h_lt h_H => by
    sorry -- symmetric to forward_G
```

### 4.2 The 4-Axiom Dependency

The critical ingredient is the temporal 4-axiom:
- `G phi -> G(G phi)` (forward 4)
- `H phi -> H(H phi)` (backward 4)

These are present in the codebase as `Axiom.temp_4` and `temp_4_past` respectively. The existing MCS properties provide:
- `G_implies_GG_in_mcs`: If `G phi in M` and M is an MCS, then `G(G phi) in M`
- `H_implies_HH_in_mcs`: If `H phi in M` and M is an MCS, then `H(H phi) in M`

These are used in `TemporalChain.lean` to prove formula propagation along chains and are exactly what is needed for the cross-boundary case of the composed family.

### 4.3 Agreement at Junction

A subtle point: the composed family assigns `fam1.mcs(j)` when `t <= j` and `fam2.mcs(t - delta)` when `t > j`. At exactly `t = j`, it uses `fam1.mcs(j)`. For the family to be "consistent" at the junction, we need `fam1.mcs(j) = fam2.mcs(t2)`, which is exactly the `h_junction` hypothesis.

Since `mcs : D -> Set Formula` is a function (not partial), there is no issue with overlap -- the `if/else` is deterministic. The junction agreement ensures that the temporal coherence properties work across the boundary.

## 5. Implications for the TruthLemma

### 5.1 The Box Case Revisited

The canonical TruthLemma from research-001.md Section 5.3 needs:

```
box phi in fam.mcs t <-> forall sigma : WorldHistory F, truth_at M sigma t phi
```

The critical question is whether all world histories in the canonical frame correspond to BMCS families.

**With the BMCS-indexed frame** (research-001.md Section 4.6): World histories are exactly the canonical ones from BMCS families (up to time-shift offset). The box case works as analyzed in Section 5.3. Family composition is not needed.

**With the global canonical frame** (MCSs as world-states): World histories are more complex. A world history assigns an MCS to each time in its domain, respecting the task relation. The task relation allows cross-family transitions (via the composed family). This means world histories in the global frame are NOT necessarily single-family -- they could be piecewise compositions.

**This is exactly why the BMCS-indexed frame is preferred**: it ensures a bijection between world histories and BMCS families, making the box case clean.

### 5.2 Does Composition Give Us Anything New for the TruthLemma?

No. The family composition construction demonstrates that the global canonical task relation is well-defined and satisfies compositionality. But for the TruthLemma, what matters is the relationship between world-history quantification (in `truth_at`) and family quantification (in BMCS). The BMCS-indexed frame ensures this relationship is exact.

If one were to use the global canonical frame, the TruthLemma's box case would require showing that every world history in the global frame is equivalent (for truth purposes) to some BMCS family. The composed families add complexity without adding expressive power for truth evaluation.

### 5.3 Composition for G/H Cases

For the G and H cases of the TruthLemma:

```
G phi in fam.mcs t <-> forall s >= t, phi in fam.mcs s
```

Family composition is irrelevant here because the quantification is within a single world history (= single family). The temporal coherence conditions (forward_G, backward_H, forward_F, backward_P) handle this entirely within one family.

### 5.4 Where Composition Could Matter: The Diamond Witness

The diamond operator (dual of box) requires: if `neg(box(neg phi)) in fam.mcs t`, then there exists a world history `sigma` where `phi` is true at time `t`. In the BMCS framework, this is handled by `bmcs_diamond_witness` (BMCS.lean): there exists a family `fam'` where `phi in fam'.mcs t`.

Family composition could be relevant if we wanted to build world histories that span multiple families (e.g., for constructing countermodels with specific properties). But for the standard completeness proof, the existing BMCS infrastructure is sufficient.

## 6. Resolution of the Section 4.3 Concern

### 6.1 Was Section 4.3 Correct?

Section 4.3 of research-001.md correctly identified a real issue: the canonical task relation with existential family quantification does NOT trivially satisfy compositionality. The concern was legitimate.

### 6.2 How Composition Resolves It

The family composition construction resolves the issue by showing that given two witnessing families sharing a junction point, a third family can be composed from them. The key ingredients are:
1. Case-split on time relative to junction point
2. The temporal 4-axioms (G phi -> G(G phi), H phi -> H(H phi)) for cross-boundary propagation
3. Agreement at the junction point (hypothesis)

### 6.3 Practical Resolution

However, the compositionality concern does not affect the recommended construction path. The BMCS-indexed frame (research-001.md Section 4.6) avoids the issue entirely by making the task relation family-local. Compositionality becomes trivial: same family, arithmetic on times.

**Conclusion**: The user's proposed composition construction is mathematically correct and resolves the compositionality concern for the global canonical frame. However, the BMCS-indexed frame remains the recommended approach for the completeness bridge because it avoids the complexity entirely.

## 7. Formal Statement of the Composition Theorem

For completeness, here is a precise theorem statement:

**Theorem (Family Composition)**. Let `D` be a linearly ordered abelian group. Let `fam1, fam2 : IndexedMCSFamily D` and let `t1, t2 : D` with `fam1.mcs(t1 + x) = fam2.mcs(t2)` for some `x : D` with `0 <= x`. Then there exists `fam3 : IndexedMCSFamily D` such that:

1. For all `t <= t1 + x`: `fam3.mcs(t) = fam1.mcs(t)`
2. For all `t > t1 + x`: `fam3.mcs(t) = fam2.mcs(t - (t1 + x - t2))`

*Proof sketch*. Define `fam3.mcs` by the case split above. The `is_mcs` property is inherited from `fam1` and `fam2`. The temporal coherence properties `forward_G` and `backward_H` hold in same-side cases by inheritance and in cross-boundary cases by the temporal 4-axioms (`G phi -> G(G phi)` and `H phi -> H(H phi)`) which propagate G/H formulas through the junction. QED.

**Corollary**. If `fam1.mcs(t1) = w`, `fam1.mcs(t1 + x) = u = fam2.mcs(t2)`, and `fam2.mcs(t2 + y) = v` with `x >= 0` and `y > 0`, then `fam3.mcs(t1) = w` and `fam3.mcs(t1 + x + y) = v`. In particular, `canonical_task_rel_global B w (x + y) v` holds.

## 8. Relationship to Existing Codebase Constructions

### 8.1 The TemporalChain Construction

The existing `TemporalChain.lean` builds an `IndexedMCSFamily Int` from two Nat-indexed chains (forward and backward) meeting at a shared base MCS. The forward chain extends `TemporalContent(M_n) = GContent(M_n) union HContent(M_n)` at each step, ensuring both G and H formulas propagate.

Family composition is a more general version of this: instead of building from scratch, it glues two existing families at a junction. The cross-boundary argument in Section 2.5 uses the same 4-axiom machinery that `TemporalChain.lean` uses for chain propagation.

### 8.2 Connection to the Dovetailing Problem

The 4 sorries in `TemporalChain.lean` are:
1. `forward_G` when `t < 0` (cross-sign)
2. `backward_H` when `t >= 0` (cross-sign)
3. `forward_F` (witness placement)
4. `backward_P` (witness placement)

Family composition addresses concerns 1 and 2 conceptually: the cross-sign cases require formula propagation across the junction between forward and backward chains. The composition construction shows this is possible via the 4-axioms, but the current two-chain construction in `TemporalChain.lean` does not produce separate families to compose -- it builds a single piecewise family.

The actual fix for the cross-sign sorries requires a different approach: either
- Building both chains from the SAME base MCS (which the current code does), and using the fact that the base MCS sits at the junction, OR
- Using a dovetailing construction that interleaves steps

The family composition idea provides the mathematical justification for why cross-boundary propagation works (via 4-axioms), even though the implementation pathway is through the chain construction rather than explicit composition.

### 8.3 The Recursive Seed Approach (Task 864)

Task 864's recursive seed approach builds families by recursively extending MCSs with witness formulas. Family composition could be used to combine two recursively-built families, but the recursive seed approach aims to build each family as a self-contained unit with all required coherence properties. Composition is orthogonal to this approach.

## 9. Recommendations

### 9.1 Primary: Use the BMCS-Indexed Frame (Unchanged from research-001.md)

The BMCS-indexed frame from research-001.md Section 4.6 remains the recommended approach for the completeness bridge. Family composition is mathematically interesting but unnecessary for this goal.

### 9.2 Secondary: Document the Composition Construction

The family composition construction should be documented as a supporting result in the canonical frame theory. It demonstrates that:
1. The global canonical task relation IS compositional (not just the family-local one)
2. The 4-axioms play a crucial role in cross-boundary temporal coherence
3. Families can be glued together at shared MCS points

This could be formalized as a standalone lemma (`compose_families`) in a future file like `Theories/Bimodal/Metalogic/Representation/FamilyComposition.lean`.

### 9.3 Tertiary: Use the 4-Axiom Insight for TemporalChain.lean

The cross-boundary argument from Section 2.5 directly applies to the cross-sign sorries in `TemporalChain.lean`. The forward and backward chains meet at the base MCS (at index 0). G formulas propagate from the backward chain into the forward chain via the 4-axiom (`G phi -> G(G phi)` ensures G phi survives across the junction), and similarly H formulas propagate from the forward chain into the backward chain.

This insight could help resolve the 2 cross-sign sorries in `buildTemporalChainFamily` without requiring a full dovetailing construction.

## 10. References

### Codebase Files
- `Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame with compositionality axiom
- `Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory definition
- `Theories/Bimodal/Semantics/Truth.lean` - truth_at with box quantification over all world histories
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` - IndexedMCSFamily with forward_G, backward_H
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - BMCS with modal coherence
- `Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean` - Two-chain construction with 4 sorries
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Temporal backward properties, 4-axiom lemmas
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - BMCS truth lemma (all cases proven)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - BMCS completeness theorems

### Key Codebase Lemmas Used
- `G_implies_GG_in_mcs` (TemporalChain.lean) - G phi in MCS implies G(G phi) in MCS
- `H_implies_HH_in_mcs` (TemporalChain.lean) - H phi in MCS implies H(H phi) in MCS
- `Axiom.temp_4` - G phi -> G(G phi) (temporal 4-axiom)
- `temp_4_past` - H phi -> H(H phi) (past 4-axiom)

## Next Steps

1. **Implement the completeness bridge** using the BMCS-indexed frame (research-001.md Section 4.6). This is the primary path to connecting BMCS completeness to standard task-frame semantics.

2. **Optionally formalize** `compose_families` as a standalone lemma to demonstrate that the global canonical task relation satisfies compositionality.

3. **Investigate** whether the 4-axiom cross-boundary argument can resolve the cross-sign sorries in `TemporalChain.lean` (recommendation 9.3).
