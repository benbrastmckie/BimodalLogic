# Research Report: CanonicalTask vs CanonicalR Perspective Analysis

**Task**: 18 - Dense Representation Theorem Completion
**Focus**: Analyze the mathematical relationship between CanonicalTask and CanonicalR, and whether the current codebase has the priorities inverted
**Date**: 2026-03-21
**Agent**: math-research-agent (teammate A)

## Executive Summary

The user's observation is mathematically precise: **the closure of the staged timeline under F/P-witnesses converges to all of CanonicalMCS**, which indicates an over-reliance on CanonicalR (a two-place relation) instead of CanonicalTask (a three-place relation). In a TaskFrame, the three-place task_rel is the **primary semantic notion**, while "there exists a task" (CanonicalR = ExistsTask) is merely a derived convenience. The current codebase inverts this priority: it builds temporal coherence around CanonicalR and struggles to close the gap to a proper three-place task relation.

## 1. What IS CanonicalTask Mathematically?

### 1.1 The Three-Place Task Relation in TaskFrame

The `TaskFrame D` structure (from `TaskFrame.lean:93`) defines:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

The **task_rel** is a three-place relation: `W → D → W → Prop`. It says "starting from world w, executing a task of **specific duration d** results in world u."

### 1.2 CanonicalTask as Duration-Precise Instantiation

The discrete `CanonicalTask` (from `CanonicalTaskRelation.lean`) instantiates this with:

```
CanonicalTask(u, 0, v)      ⟺  u = v
CanonicalTask(u, n+1, v)    ⟺  ∃ w, Succ(u, w) ∧ CanonicalTask(w, n, v)
CanonicalTask(u, -(n+1), v) ⟺  CanonicalTask(v, n+1, u)
```

**Key insight**: The duration `n` is **semantically meaningful**. `CanonicalTask(u, 3, v)` means v is exactly 3 Succ-steps away from u. This is **duration-precise**: different durations give different relations.

For the dense case, the proposed `DenseTask` uses the Cantor isomorphism:

```
DenseTask(u, q, v)  ⟺  e(tᵥ) - e(tᵤ) = q
```

where `e : TimelineQuot ≃o ℚ`. This is **deterministic**: given u and q, there is at most one v with DenseTask(u, q, v).

### 1.3 What CanonicalTask Captures

CanonicalTask captures:
1. **Metric structure**: How far apart two worlds are in temporal distance
2. **Chain structure**: The sequence of intermediate worlds between u and v
3. **F-obligation tracking**: The F-step condition ensures obligations are resolved or deferred at each step
4. **Reversibility**: The converse axiom is built into the definition

## 2. CanonicalR as a Derived Notion

### 2.1 Definition of CanonicalR

From `CanonicalFrame.lean:63`:

```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

This says: "all G-formulas of M are satisfied at M'." This is equivalent to **ExistsTask**:

```
CanonicalR(u, v)  ⟺  ∃ d > 0, task_rel u d v  (for the canonical TaskFrame)
```

### 2.2 CanonicalR Forgets Duration Information

When we write `CanonicalR(u, v)`, we assert that v is **somewhere** in u's future — but we forget **how far**. Compare:

| Relation | Information Content |
|----------|---------------------|
| `CanonicalTask(u, 5, v)` | v is exactly 5 steps from u |
| `CanonicalR(u, v)` | v is somewhere ahead of u (could be 1 step or 1000 steps) |

The current codebase uses CanonicalR everywhere because it's simpler — but this loses the metric structure that TaskFrame is designed to capture.

### 2.3 The Duration-Coarse Parametric Relation

The `parametric_canonical_task_rel` (from `ParametricCanonical.lean:85`) instantiates TaskFrame using CanonicalR:

```lean
def parametric_canonical_task_rel (M : WorldState) (d : D) (N : WorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N
```

This is **duration-coarse**: ALL positive durations map to the same relation. The duration parameter d is semantically vacuous beyond its sign.

**Problem**: This collapses the rich metric structure of TaskFrame into a boolean (forward/backward/same). Report 19 correctly identifies this as "maximally non-deterministic."

## 3. Why Closure Converging to CanonicalMCS is Problematic

### 3.1 The Observation

Report 08's key finding (from teammate A):

> The closure of the staged timeline under F/P-witnesses converges to all of CanonicalMCS at omega steps... This means a closure operator on TimelineQuot is just a complicated way of recovering the canonical model.

### 3.2 Why This Indicates a Structural Problem

When we build a temporal model around CanonicalR (the two-place "exists some positive duration" relation), the natural closure operation is:

```
cl(S) = lfp(F) where F(X) = S ∪ FWit(X) ∪ PWit(X)
FWit(X) = { W : MCS | ∃ M ∈ X, ∃ phi, F(phi) ∈ M ∧ CanonicalR(M, W) ∧ phi ∈ W }
```

This closure adds **all** possible witnesses for F-obligations, which is **all** MCSes reachable by CanonicalR. The fixpoint is **all of CanonicalMCS**.

**The structural issue**: CanonicalR doesn't constrain where witnesses land. Any MCS satisfying `CanonicalR(M, W) ∧ phi ∈ W` is valid. Since the set of all MCSes is the only CanonicalR-closed set containing any non-trivial seed, the closure blows up.

### 3.3 What Would Happen with CanonicalTask?

If we used the three-place relation as primary, the closure would be:

```
cl(S) = lfp(F) where F(X) = S ∪ FWit(X) ∪ PWit(X)
FWit(X) = { (W, d) | ∃ (M, t) ∈ X, ∃ phi, F(phi) ∈ M ∧ CanonicalTask(M, d, W) ∧ phi ∈ W }
```

The key difference: witnesses are **indexed by duration**. We don't just ask "does a witness exist?" — we ask "at what duration is the witness?" This constrains the closure because:

1. **Discrete case**: The F-step condition forces phi to be resolved within a bounded number of steps (by the single-step forcing theorem, report 20 Section 3)
2. **Dense case**: The Cantor isomorphism assigns a unique rational to each witness position

The closure with CanonicalTask is **geometrically constrained** by the duration metric, rather than being all MCSes.

## 4. TaskFrame vs CanonicalMCS: What Structure is Lost?

### 4.1 The Three-Place Relation Captures Metric Geometry

A TaskFrame with a proper three-place task_rel has:

1. **Duration metric**: The distance between worlds is a group element d ∈ D
2. **Compositionality**: `task_rel w x u ∧ task_rel u y v → task_rel w (x+y) v`
3. **Unique identity**: Zero duration means same world
4. **Group structure**: The duration domain D is an ordered abelian group

### 4.2 CanonicalMCS + CanonicalR Loses the Metric

When we model time as "CanonicalMCS ordered by CanonicalR":

1. **No metric**: We have a preorder, not a metric space
2. **No composition law**: CanonicalR is transitive, but there's no duration to add
3. **Non-determinism everywhere**: Multiple CanonicalR paths between any two related MCSes
4. **No quantitative reasoning**: Can't ask "how long until phi is satisfied?"

### 4.3 The FMCS Definition Reflects This

The FMCS structure (from `FMCSDef.lean`) only requires a Preorder:

```lean
structure FMCS (D : Type*) [Preorder D] where
  mcs : D → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  forward_G : ∀ t t', t < t' → G φ ∈ mcs t → φ ∈ mcs t'
  backward_H : ∀ t t', t' < t → H φ ∈ mcs t → φ ∈ mcs t'
```

The temporal coherence conditions use `<` (strict ordering), not durations. This is fine for G/H (which are inherently qualitative: "all/some future/past"), but loses information for quantitative reasoning.

### 4.4 The Gap: FMCS to TaskFrame

The gap in the completeness proof is precisely this: FMCS gives us a qualitative temporal structure (preorder + MCS assignment), but TaskFrame needs a quantitative structure (durations + metric). The current approach papers over this with the duration-coarse relation, but loses the ability to reason about "when" things happen.

## 5. Implications for the Dense Completeness Theorem

### 5.1 The Current Architecture's Limitations

The current dense completeness attempt:

1. Builds TimelineQuot from the staged construction
2. Proves `TimelineQuot ≃o ℚ` (Cantor isomorphism)
3. Tries to build an FMCS over TimelineQuot
4. Gets stuck on forward_F/backward_P because Lindenbaum witnesses aren't in TimelineQuot

The problem: TimelineQuot is built from CanonicalR-reachable MCSes, not from the three-place task structure. The staged construction adds points based on CanonicalR accessibility, so it has the "all MCSes" blowup problem.

### 5.2 How CanonicalTask Should Be Primary

The correct architecture, per the user's observation:

1. **Define DenseTask first**: As `w + d = w'` using the Cantor isomorphism
2. **Build the FMCS around DenseTask**: Each time point t maps to the MCS at that position in the timeline
3. **Derive CanonicalR as a convenience**: `CanonicalR(u, v) := ∃ d > 0, DenseTask(u, d, v)`
4. **Forward_F uses the metric**: The witness for `F(phi) ∈ mcs(t)` is at some specific rational t' > t

### 5.3 Why This Resolves the Gap

With DenseTask as primary:

1. **No blowup**: The closure is constrained by the rational metric
2. **Forward_F becomes geometric**: The witness is at a specific location, not "somewhere"
3. **The Cantor isomorphism is central**: It's not an add-on for AddCommGroup compliance; it's the source of the task relation
4. **TimelineQuot IS the canonical model**: No separate CanonicalMCS needed

### 5.4 Recommended Restructuring

**Phase 1**: Define `DenseTask` on TimelineQuot via Cantor isomorphism

```lean
def DenseTask (t : TimelineQuot) (d : ℚ) (t' : TimelineQuot) : Prop :=
  ratOrderIso t' = ratOrderIso t + d
```

**Phase 2**: Prove TaskFrame axioms for `(TimelineQuot, DenseTask)`

**Phase 3**: Define the FMCS with mcs(t) = the MCS at timeline position t

**Phase 4**: Prove forward_F using the density frame condition (report 18 Section 2.1):
- `F(phi) ∈ mcs(t)` means by DN: `F(F(phi)) ∈ mcs(t)`
- By density interpolation, there exists `t'` arbitrarily close to t with `phi ∈ mcs(t')`
- The witness is at a specific rational, not arbitrary

**Phase 5**: Wire completeness using the metric-based proof

## 6. Alternative: Generalize TaskFrame

As noted in report 08, the TaskFrame currently requires AddCommGroup D. An alternative resolution:

1. **Generalize TaskFrame** to require only `LinearOrder D`, `DenselyOrdered D`, `NoMaxOrder D`, `NoMinOrder D`
2. **Use CanonicalMCS directly** as the domain (it has a linear order via CanonicalR with totality from the staged construction)
3. **The three-place relation becomes**: `task_rel M d N` defined as "the unique N with CanonicalR-distance d from M"

This avoids rebuilding the metric structure, but requires proving CanonicalMCS is linearly ordered and densely ordered (which follows from the staged construction + density axiom).

## 7. Summary

| Aspect | CanonicalR (Two-Place) | CanonicalTask (Three-Place) |
|--------|------------------------|-----------------------------|
| Semantic content | "v is somewhere ahead of u" | "v is exactly d ahead of u" |
| Duration information | Lost (sign only) | Preserved (specific d ∈ D) |
| Closure behavior | Blows up to all MCSes | Constrained by metric |
| Forward_F witnesses | Arbitrary MCS | Specific timeline position |
| Compositionality | Transitivity only | Duration addition |
| TaskFrame compliance | Duration-coarse (vacuous d) | Duration-precise |

**The user's observation is correct**: The current codebase treats CanonicalR as primary and struggles to recover the three-place structure. The correct architecture makes CanonicalTask primary and derives CanonicalR as ExistsTask. This resolves the closure blowup and makes forward_F/backward_P geometrically constrained.

## Appendix: Key Codebase References

1. **TaskFrame definition**: `Theories/Bimodal/Semantics/TaskFrame.lean:93`
2. **CanonicalR definition**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean:63`
3. **CanonicalTask definition**: `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean:167`
4. **Parametric (duration-coarse) relation**: `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean:85`
5. **Succ relation**: `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean:60`
6. **Closure blowup analysis**: Report 08 (teammate A), Section 2
7. **Dense three-place relation proposal**: Report 18, Sections 2.3-2.5
8. **Role in representation theorems**: Report 19, Section 2
