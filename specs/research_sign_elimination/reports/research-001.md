# Research Report: Algebraic Structures for Sign-Case Elimination in Temporal Task Frames

**Task**: Eliminate disjunctive sign-case constructions from TaskFrame compositionality
**Started**: 2026-03-14
**Completed**: 2026-03-14
**Effort**: Medium
**Dependencies**: None (pure mathematical research)
**Sources/Inputs**: Codebase (TaskFrame.lean, CanonicalConstruction.lean, CanonicalFrame.lean, FMCSDef.lean, DurationTransfer.lean, Truth.lean, WorldHistory.lean, Axioms.lean), ROAD_MAP.md
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The current `canonical_task_rel` uses a 3-way sign case split (`d > 0`, `d = 0`, `d < 0`), and older Boneyard approaches had 7-9 mixed-sign compositionality sorries. The current code resolves this by making `d < 0 => False`, which works because `respects_task` only evaluates at `d >= 0`.
- A converse axiom (`task_rel w d u <-> task_rel u (-d) w`) together with non-negative compositionality is algebraically equivalent to the current formulation but more principled. It makes the 3-way split derivable rather than definitional.
- The key algebraic insight is that the task relation for an ordered group G acting on W decomposes into a **preorder** R on W (the non-negative action) plus the group structure. Sign cases are replaced by group-theoretic lemmas.
- **Recommendation**: Reformulate TaskFrame with (a) a converse axiom, (b) compositionality restricted to `0 <= x`, `0 <= y`, and (c) derive full compositionality as a theorem. This is cleaner and avoids all sign-case reasoning in downstream proofs.

## Context & Scope

### The Problem

The `TaskFrame` structure (in `Theories/Bimodal/Semantics/TaskFrame.lean`) currently requires:

```lean
compositionality : forall w u v x y,
  task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

This quantifies over ALL durations x, y in the ordered additive group D. In the canonical model construction, proving this for negative durations has been a persistent pain point:

1. **Boneyard approaches** (Metalogic_v4, Metalogic) had 7+ mixed-sign compositionality sorries
2. **Current approach** (CanonicalConstruction.lean) solves this by defining `d < 0 => False`, making negative-duration premises vacuously true
3. **DurationTransfer.lean** solves this by conflating WorldState with D and using `w + d = w'`, getting compositionality from `add_assoc`

Both solutions work but are "tricks" -- the first by making negative durations meaningless, the second by collapsing the distinction between worlds and times.

### What We Want

A principled algebraic formulation where:
- Sign cases are eliminated structurally, not by tricks
- The task relation has clear mathematical meaning
- Compositionality follows from clean algebraic principles
- The canonical model construction becomes simpler

## Findings

### 1. The Ordered Group Action Perspective

**Setting**: Let (G, +, <=) be a totally ordered abelian group (the duration type D), W a set (world states), and `R : W -> G -> W -> Prop` a relation (task_rel).

**Definition (Group Action via Relation)**: R is a *relational group action* of G on W if:
1. **Identity**: `R(w, 0, w)` for all w
2. **Compositionality**: `R(w, x, u) /\ R(u, y, v) => R(w, x+y, v)` for all x, y
3. **Converse**: `R(w, d, u) <-> R(u, -d, w)` for all d

**Key Theorem**: If R satisfies (1)-(3), then compositionality for ALL x, y follows from compositionality restricted to non-negative x, y.

**Proof**: Let x, y be arbitrary. We need to show that R(w, x, u) and R(u, y, v) imply R(w, x+y, v). Split into cases based on signs:

*Case 1*: x >= 0, y >= 0. Direct from restricted compositionality.

*Case 2*: x >= 0, y < 0. Then R(u, y, v) iff R(v, -y, u) by converse, where -y > 0. We have:
- R(w, x, u) and R(v, -y, u)
- We need R(w, x+y, v)
- By converse, this is equivalent to R(v, -(x+y), w) = R(v, -x-y, w)
- We have R(v, -y, u) and need to compose with something to get to w.
- R(w, x, u) iff R(u, -x, w) by converse.
- So R(v, -y, u) and R(u, -x, w), with -y > 0 and -x <= 0.

This leads to a CIRCULAR argument under the naive approach: we need the very thing we are trying to prove. The resolution requires a different decomposition strategy.

**Corrected Theorem**: Full compositionality follows from:
- (A) Non-negative compositionality: `0 <= x -> 0 <= y -> R(w, x, u) -> R(u, y, v) -> R(w, x+y, v)`
- (B) Converse: `R(w, d, u) <-> R(u, -d, w)`

**Proof (corrected)**: Given arbitrary x, y with R(w, x, u) and R(u, y, v):

*Case x >= 0, y >= 0*: Direct from (A).

*Case x < 0, y >= 0, x+y >= 0*:
- R(w, x, u) iff R(u, -x, w) by (B), where -x > 0.
- R(u, y, v) with y >= 0.
- We have R(u, -x, w) and R(u, y, v).
- We need R(w, x+y, v).
- Since -x > 0 and y >= 0, we cannot directly compose R(u, -x, w) and R(u, y, v) (they share source u, not chain endpoint).
- **This requires an additional property**: *functionality* or *determinism* of the positive-duration action.

This reveals a crucial subtlety: **converse + non-negative compositionality alone are NOT sufficient for full compositionality** without additional structure (like functionality or the positive-duration action being deterministic).

### 2. Why the Current Codebase Avoids the Problem

The current `CanonicalConstruction.lean` makes negative durations `False`. This is sound because:

1. **`respects_task`** (WorldHistory.lean, line 96-97) only evaluates `task_rel` at `d = t - s` where `s <= t`, so `d >= 0`.
2. **`truth_at`** (Truth.lean) evaluates temporal operators by quantifying over times `s > t` (future) or `s < t` (past), but these quantifications are over the TIME index, not over task_rel durations directly.
3. **The task_rel is NOT used in the truth lemma proof** (CanonicalConstruction.lean, line 287-294): temporal operators use strict order on D directly, and box quantifies over histories in Omega.

Therefore, the task_rel is only used in `WorldHistory.respects_task`, which only tests non-negative durations. Making negative durations `False` is vacuously safe.

### 3. The Preorder Perspective

**Key Insight**: In the canonical model, `CanonicalR(M, M')` = `GContent(M) ⊆ M'` is a **preorder** on MCSs (reflexive by T-axiom closure + Temp4, transitive by `canonicalR_transitive` using Temp4). The full task relation is generated by this preorder:

```
task_rel(w, d, u) :=
  if d > 0 then R(w, u)     -- R is the preorder
  if d = 0 then w = u        -- identity
  if d < 0 then R(u, w)     -- converse of preorder
```

This is exactly the structure of a **group action generated by a preorder**: the positive cone G+ acts via R, the identity acts trivially, and the negative cone acts via R^{op}.

**Duration Independence**: In the canonical model, if `CanonicalR(M, M')` holds, it holds independent of the specific positive duration d. The relation R is "all-or-nothing" for positive durations. This is the **duration independence** property:

```
task_rel(w, x, u) /\ x > 0 /\ y > 0 => task_rel(w, y, u)
```

This is a very strong property specific to the canonical model -- it says the task relation only depends on the SIGN of d, not its magnitude.

### 4. The Correct Algebraic Abstraction: Sign-Homogeneous Relations

**Definition**: A *sign-homogeneous task relation* over an ordered group (G, +, <=) acting on W is a relation `task_rel : W -> G -> W -> Prop` such that:

(SH1) **Nullity**: `task_rel(w, 0, w)` for all w
(SH2) **Converse**: `task_rel(w, d, u) <-> task_rel(u, -d, w)` for all d
(SH3) **Positive Compositionality**: For `0 < x`, `0 < y`:
  `task_rel(w, x, u) /\ task_rel(u, y, v) => task_rel(w, x+y, v)`
(SH4) **Duration Independence**: For `0 < x`, `0 < y`:
  `task_rel(w, x, u) => task_rel(w, y, u)`

From (SH1)-(SH4), full compositionality is derivable:

**Theorem**: (SH1)-(SH4) imply `compositionality`: for all x, y,
`task_rel(w, x, u) /\ task_rel(u, y, v) => task_rel(w, x+y, v)`.

**Proof**:

*Case x = 0*: task_rel(w, 0, u) implies w = u (by SH2 + SH1: task_rel(w, 0, u) iff task_rel(u, 0, w), and the only witness at 0 is identity). Wait -- SH1 says `task_rel(w, 0, w)` but does NOT say `task_rel(w, 0, u) => w = u`. We need:

(SH1') **Nullity-Identity**: `task_rel(w, 0, u) <-> w = u`

The `<->` direction is important. The forward direction (`task_rel(w, 0, u) => w = u`) is NOT implied by just `task_rel(w, 0, w)`. The current CanonicalConstruction defines `d = 0 => (M = N)`, which IS the full `<->`.

With (SH1') instead of (SH1):

*Case x = 0*: task_rel(w, 0, u) => w = u, so task_rel(u, y, v) becomes task_rel(w, y, v) = task_rel(w, 0+y, v). Done.

*Case y = 0*: Symmetric.

*Case x > 0, y > 0*: Direct from (SH3).

*Case x > 0, y < 0, x+y > 0*:
- task_rel(w, x, u) with x > 0
- task_rel(u, y, v) with y < 0
- By SH2: task_rel(u, y, v) iff task_rel(v, -y, u) with -y > 0
- By SH4 applied to task_rel(v, -y, u): task_rel(v, x, u) (duration independence, any positive works)
- Wait, SH4 says `task_rel(w, x, u) => task_rel(w, y, u)` for positive x, y. So task_rel(v, -y, u) implies task_rel(v, 1, u) for any positive 1.
- We have task_rel(w, x, u) and task_rel(v, -y, u) with x > 0, -y > 0.
- We need task_rel(w, x+y, v). x+y > 0.
- By SH2: task_rel(w, x+y, v) iff task_rel(v, -(x+y), w) = task_rel(v, -x-y, w) with -x-y < 0.
- Hmm, this does not simplify easily.

Let me take a different approach entirely.

### 5. The Clean Formulation: Preorder + Group Generation

The cleanest approach is to NOT parameterize by duration at all for the "base relation", and instead generate the temporal structure from a preorder.

**Definition**: A *Temporal Preorder Frame* consists of:
- A set W (world states)
- A preorder R on W (the "forward reachability" relation)

**Derived task relation**: Given an ordered group D and any preorder R on W, define:
```
task_rel(w, d, u) :=
  (d > 0 /\ R(w, u)) \/
  (d = 0 /\ w = u)  \/
  (d < 0 /\ R(u, w))
```

**Theorem**: This derived task_rel satisfies nullity and compositionality.

*Nullity*: task_rel(w, 0, w) = (False /\ _) \/ (True /\ w = w) \/ (False /\ _) = True. Done.

*Compositionality*: task_rel(w, x, u) /\ task_rel(u, y, v) => task_rel(w, x+y, v).

This requires a 9-way case split (3 signs of x times 3 signs of y). But each case is simple:

| x sign | y sign | x+y sign | Premise 1 | Premise 2 | Need | Proof |
|--------|--------|----------|-----------|-----------|------|-------|
| x=0 | y=0 | 0 | w=u | u=v | w=v | transitivity of = |
| x=0 | y>0 | >0 | w=u | R(u,v) | R(w,v) | subst |
| x=0 | y<0 | <0 | w=u | R(v,u) | R(v,w) | subst |
| x>0 | y=0 | >0 | R(w,u) | u=v | R(w,v) | subst |
| x>0 | y>0 | >0 | R(w,u) | R(u,v) | R(w,v) | transitivity of R |
| x>0 | y<0 | ? | R(w,u) | R(v,u) | ? | **needs case split on x+y sign** |
| x<0 | y=0 | <0 | R(u,w) | u=v | R(v,w) | subst |
| x<0 | y>0 | ? | R(u,w) | R(u,v) | ? | **needs case split on x+y sign** |
| x<0 | y<0 | <0 | R(u,w) | R(v,u) | R(v,w) | transitivity of R |

The problematic cases are x>0, y<0 and x<0, y>0. For x>0, y<0:
- Premises: R(w,u) and R(v,u)
- If x+y > 0: need R(w,v). From R(w,u) and R(v,u), we need: w and v are both R-below-or-equal u. Need R(w,v) or R(v,w). **This requires totality of R** (linear preorder).
- If x+y = 0: need w=v. From R(w,u) and R(v,u), this is NOT generally true.
- If x+y < 0: need R(v,w). Same totality issue.

**Critical Finding**: Compositionality for the preorder-generated task relation requires the preorder R to be **total** (a total preorder, i.e., for all w, u: R(w,u) or R(u,w)).

Moreover, even with totality, the x+y=0 case (x>0, y<0, x+y=0) requires: from R(w,u) and R(v,u), derive w=v. This requires R to be **antisymmetric** at the points involved, or the task_rel at d=0 to be defined as `R(w,u) /\ R(u,w)` (mutual reachability) rather than `w=u`.

### 6. The Preorder-Generated Frame: Complete Analysis

Let R be a **total preorder** on W. Define:

```
task_rel(w, d, u) :=
  if d > 0 then R(w, u)
  else if d < 0 then R(u, w)
  else w = u
```

For the mixed-sign cases in compositionality:

**Case x > 0, y < 0, x+y = 0** (i.e., y = -x):
- Premises: R(w,u) and R(v,u) (from task_rel(u, y, v) with y < 0, i.e., R(v,u))
- Need: w = v
- We have R(w,u) and R(v,u). We CANNOT conclude w = v in general.

This means the preorder-generated task relation with `d=0 => (w=u)` does NOT satisfy compositionality, even with a total preorder, unless we add extra conditions.

**Resolution Options**:

*Option A*: Define `d=0` case as `R(w,u) /\ R(u,w)` instead of `w=u`. Then the problematic case becomes: from R(w,u) and R(v,u) and x+y=0, need R(w,v) /\ R(v,w). By totality, either R(w,v) or R(v,w). But we need BOTH directions. Still fails.

*Option B*: Require **duration independence** (SH4) -- but then R becomes "if any positive relation holds, ALL positive relations hold", which makes the task_rel depend only on sign.

*Option C*: Make negative durations `False`. This is exactly what CanonicalConstruction.lean does. Then the mixed-sign cases become vacuously true.

*Option D*: Add the converse property as an axiom and restrict compositionality to non-negative durations only. Then:
- Non-negative compositionality: `0 <= x -> 0 <= y -> ...` -- only cases 0/0, 0/+, +/0, +/+ arise, all trivial.
- Converse: derived from the definition (swap sign, swap worlds).
- Full compositionality is NOT stated as an axiom but can be derived in contexts where it is needed (which is: never, since respects_task only uses d >= 0).

### 7. Analysis of Frame Constraints in the Canonical Model

Let me verify which constraints hold in the canonical model:

**Converse**: `task_rel(w, d, u) <-> task_rel(u, -d, w)`

In the canonical model with the current definition:
- d > 0: task_rel(w, d, u) = CanonicalR(w, u). task_rel(u, -d, w) = False (since -d < 0).
- So converse FAILS with the current definition (d < 0 => False).

However, if we were to define: d < 0 => CanonicalR(u, w) (instead of False), then:
- d > 0: task_rel(w, d, u) = CanonicalR(w, u). task_rel(u, -d, w) = CanonicalR(w, u) (since -d < 0, swapping w and u). YES, this is the converse.
- d = 0: task_rel(w, 0, u) = (w = u). task_rel(u, 0, w) = (u = w). YES.
- d < 0: task_rel(w, d, u) = CanonicalR(u, w). task_rel(u, -d, w) = CanonicalR(u, w) (since -d > 0). YES.

So converse holds if we define d < 0 via CanonicalR in the reverse direction.

**Duration Independence**: `task_rel(w, x, u) /\ x > 0 /\ y > 0 => task_rel(w, y, u)`

In the canonical model: task_rel(w, x, u) for x > 0 is CanonicalR(w, u), which does not depend on x. So YES, duration independence holds trivially.

**Totality**: `forall w d, exists u, task_rel(w, d, u)`

In the canonical model with d > 0: need exists u with CanonicalR(w, u). This is the F-witness existence, which requires F(T) in w.val. With the seriality axiom `F(not bot)`, this holds.

With d < 0 and the converse definition: need exists u with CanonicalR(u, w). This is the P-witness existence. With seriality_past `P(not bot)`, this holds.

With d = 0: u = w. Done.

So totality holds in the canonical model (given seriality axioms).

**Forward Compositionality** (`0 <= x, 0 <= y`):

- x = 0, y = 0: w = u, u = v => w = v. Trivial.
- x = 0, y > 0: w = u, CanonicalR(u, v) => CanonicalR(w, v). Substitution.
- x > 0, y = 0: CanonicalR(w, u), u = v => CanonicalR(w, v). Substitution.
- x > 0, y > 0: CanonicalR(w, u), CanonicalR(u, v) => CanonicalR(w, v). `canonicalR_transitive`.

All cases clean. No sign issues.

### 8. The Recommended Reformulation

**Proposed TaskFrame' structure** (replaces TaskFrame):

```lean
structure TaskFrame' (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop

  -- Core axioms (sign-free)
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  converse : forall w u d, task_rel w d u <-> task_rel u (-d) w
  forward_compositionality : forall w u v x y,
    0 <= x -> 0 <= y ->
    task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

**Derived properties** (all provable from the three axioms):

```lean
-- Nullity (backward compatible)
theorem nullity : forall w, task_rel w 0 w :=
  fun w => (nullity_identity w w).mpr rfl

-- Full compositionality (backward compatible)
theorem compositionality : forall w u v x y,
  task_rel w x u -> task_rel u y v -> task_rel w (x + y) v := by
  -- Case analysis on signs of x, y
  -- Negative cases reduced to positive via converse
  sorry -- see proof sketch below

-- Duration independence (if desired, as separate axiom or derived)
-- NOT needed for compositionality proof
```

**Proof Sketch for Full Compositionality**:

Given task_rel(w, x, u) and task_rel(u, y, v), derive task_rel(w, x+y, v).

*Case x >= 0, y >= 0*: Direct from forward_compositionality.

*Case x < 0, y < 0*:
- By converse: task_rel(w, x, u) iff task_rel(u, -x, w) with -x > 0.
- By converse: task_rel(u, y, v) iff task_rel(v, -y, u) with -y > 0.
- By forward_compositionality (since -y > 0, -x > 0):
  task_rel(v, -y, u) and task_rel(u, -x, w) => task_rel(v, -y + (-x), w) = task_rel(v, -(x+y), w)
- By converse: task_rel(v, -(x+y), w) iff task_rel(w, x+y, v). Done.

*Case x >= 0, y < 0*:
- task_rel(w, x, u) with x >= 0.
- task_rel(u, y, v) iff task_rel(v, -y, u) with -y > 0.
- We have task_rel(w, x, u) and task_rel(v, -y, u).
- Need task_rel(w, x+y, v).

  Sub-case x+y >= 0:
  - By converse: task_rel(w, x+y, v) iff showing R goes from w to v at positive displacement.
  - From task_rel(w, x, u): R(w -> u) at displacement x.
  - From task_rel(v, -y, u): R(v -> u) at displacement -y.
  - **We need information connecting w and v via u.** This is the hard case.

  **Important realization**: This case CANNOT be proved from just the three axioms above without additional structure. Here is why:

  Consider G = (Z, +), W = {a, b, c}, and define:
  - task_rel(a, d, b) for all d > 0 (R(a,b))
  - task_rel(c, d, b) for all d > 0 (R(c,b))
  - task_rel(w, 0, w) for all w (identity)
  - Converse-compatible extension for d < 0.
  - No other positive-duration relations.

  Then: task_rel(a, 1, b) and task_rel(b, -1, c) (i.e., task_rel(c, 1, b) by converse).
  Need: task_rel(a, 0, c), i.e., a = c. But a != c. Contradiction!

  So task_rel(a, 1, b) and task_rel(b, -1, c) does NOT imply task_rel(a, 0, c) in general.

  **This confirms the fundamental issue**: mixed-sign compositionality requires **functionality** of the positive relation or equivalently that the relation is generated by a genuine group action (function, not just relation).

### 9. When Does Full Compositionality Hold?

Full compositionality (including mixed-sign) holds exactly when the task relation comes from a **genuine group action**, i.e., when the positive-duration task_rel is **functional**: for each w and d > 0, there is at most one u with task_rel(w, d, u).

In the canonical model, CanonicalR is NOT functional (many MCSs can be forward-accessible from a given MCS). So **full compositionality for all durations is NOT naturally available** in the canonical model when we define d < 0 via the converse.

This is precisely why the current codebase uses `d < 0 => False` -- it avoids the mixed-sign cases entirely.

### 10. The Right Answer: Restricted Compositionality IS the Right Formulation

Given the analysis above, the algebraically correct formulation is:

**TaskFrame should use restricted compositionality** (0 <= x, 0 <= y), with the converse property as optional. Full compositionality should NOT be an axiom because:

1. It is not needed (respects_task only uses d >= 0)
2. It forces unnatural constraints on the canonical model
3. The mixed-sign cases require functionality, which the canonical model lacks

**Proposed Clean TaskFrame**:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  forward_compositionality : forall w u v x y,
    0 <= x -> 0 <= y ->
    task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

With the optional converse property as a mixin:

```lean
class HasConverse (F : TaskFrame D) where
  converse : forall w u d, F.task_rel w d u <-> F.task_rel u (-d) w
```

### 11. Impact on Existing Proofs

**What changes**:
1. `TaskFrame.compositionality` signature gains two hypotheses `0 <= x` and `0 <= y`
2. All callers of `compositionality` must provide these proofs

**What callers exist**:
1. `WorldHistory.respects_task` (WorldHistory.lean, line 96-97): already has `s <= t`, so `t - s >= 0`. The compositionality is used implicitly when multiple respects_task segments are chained. Since all segments have non-negative durations, `0 <= x` and `0 <= y` are available.
2. `time_shift.respects_task` (WorldHistory.lean, line 247-258): uses `(t + D) - (s + D) = t - s` where `s <= t`. The duration is non-negative.
3. `CanonicalConstruction.canonical_task_rel_compositionality`: this IS the compositionality proof and would be simplified.

**What DOESN'T change**:
1. `truth_at` -- does not use task_rel
2. The canonical truth lemma -- does not use task_rel
3. Soundness proofs -- use validity definitions that don't directly invoke compositionality

**Net effect**: The change is backward-compatible modulo adding `0 <= x` and `0 <= y` hypotheses at call sites, which are always available.

### 12. The Tarski-Lindenbaum / Ultrafilter Connection

The user asked about the Galois connection structure. Here is the precise formulation:

Let L = Formula / ~, the Lindenbaum-Tarski algebra (Boolean algebra of formulas modulo provable equivalence). The operators G and H give modal operators on L:
- G : L -> L maps [phi] to [G phi]
- H : L -> L maps [phi] to [H phi]

An MCS M corresponds to an ultrafilter on L (a maximal filter, equivalently a Boolean homomorphism L -> {0,1}).

The map `GContent` defines a function from ultrafilters to filters (not necessarily ultrafilters):

```
GContent : Ult(L) -> Filt(L)
GContent(M) = {[phi] | [G phi] in M}
```

This is a filter because:
- G(T) is a theorem, so T in GContent(M)
- G(phi /\ psi) <-> G(phi) /\ G(psi) in the logic (from TK + temporal necessitation), so GContent is closed under finite meets

The relation CanonicalR(M, M') = GContent(M) <= M' (as a filter included in an ultrafilter) is exactly the statement that M' extends the G-filter of M.

This has the structure of a **Galois connection** between:
- The poset of ultrafilters (ordered by inclusion -- but ultrafilters are maximal, so this is discrete)
- The poset of filters (ordered by inclusion)

More precisely, GContent defines a *monotone map* from (Ult(L), CanonicalR) to (Filt(L), <=). The relation CanonicalR(M, M') = GContent(M) <= M' is then the **graph of the composition** GContent; extension, where extension is the relation "filter extends to ultrafilter".

The adjunction structure is:
- Left adjoint: filter generation from ultrafilter via G (= GContent)
- Right adjoint: ultrafilter extension of filter (= Lindenbaum lemma)

The Lindenbaum lemma acts as the "right adjoint" providing witnesses: given a consistent filter F, there exists an ultrafilter extending F. This is exactly `canonical_forward_F`.

### 13. The Quiver/Path Perspective

The user suggested defining task_rel via paths in a quiver. Here is the precise formulation:

A **quiver** Q = (V, E) has vertices V (= W) and edges E : V -> V -> Prop (= CanonicalR).

The **path category** Path(Q) has:
- Objects: vertices of Q
- Morphisms: finite paths (sequences of edges)
- A path of length n from w to u is a sequence w = w_0, w_1, ..., w_n = u with E(w_i, w_{i+1})

For the canonical model, CanonicalR is already transitive (by canonicalR_transitive), so Path(Q) collapses:
- Path of length 0: identity (w = u)
- Path of length >= 1: CanonicalR(w, u) (transitivity collapses all longer paths)

This means the quiver perspective adds no new information beyond the preorder. The task_rel generated by the quiver is exactly the preorder-generated task_rel from Section 5.

The **opposite quiver** Q^{op} has E^{op}(w, u) = E(u, w), giving the past direction. Paths in Q^{op} give the d < 0 component of task_rel (if we choose to define it).

### 14. Summary of Recommendations

**Recommendation 1 (Primary)**: Restrict compositionality to non-negative durations in TaskFrame. This eliminates all sign-case reasoning and is sufficient for all downstream uses.

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  forward_compositionality : forall w u v x y,
    0 <= x -> 0 <= y ->
    task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

**Recommendation 2 (Optional Enhancement)**: Add a converse mixin class for frames where the past direction is the inverse of the future direction.

**Recommendation 3**: Do NOT add duration independence as a frame axiom. It holds in the canonical model but may not hold in general frames of interest.

**Recommendation 4**: Do NOT attempt full compositionality for all signs. It requires functionality of the positive relation, which the canonical model lacks.

**Recommendation 5**: The current `d < 0 => False` approach in CanonicalConstruction.lean is correct and should be kept. The restricted compositionality formulation would make this cleaner (no need for the False case at all -- just don't define task_rel for negative durations, or define it however is convenient).

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | Low | Our recommendations are about TaskFrame structure, independent of how D is constructed |
| Product Domain Temporal Trivialization | Low | Not relevant to sign-case elimination |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | The restricted compositionality would simplify the TaskFrame construction in Phase 7-8 |
| Algebraic Verification Path | PAUSED | The Tarski-Lindenbaum connection (Section 12) supports this direction |
| Indexed MCS Family Approach | ACTIVE | FMCS coherence conditions (forward_G, backward_H) align with restricted compositionality |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Sign-homogeneous task relations | Section 4 | No | new_file |
| Preorder-generated task frames | Section 5-6 | No | extension |
| Restricted vs full compositionality | Section 10 | No | extension |
| GContent as ultrafilter-to-filter map | Section 12 | No | new_file |

### Summary

- **New files needed**: 0 (concepts are task-specific, not broadly reusable)
- **Extensions needed**: 0 (findings are specialized to this research)
- **Tasks to create**: 0
- **High priority gaps**: 0

## Decisions

1. Full compositionality for all signs is NOT achievable without functionality (determinism) of the positive-duration relation.
2. Restricted compositionality (non-negative only) is the correct algebraic formulation.
3. The current `d < 0 => False` approach is sound and should be preserved as a consequence of the restricted formulation.
4. The converse property is an independent axiom that can be added as a mixin.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Changing TaskFrame signature breaks downstream code | The change only adds two hypotheses (0 <= x, 0 <= y) which are always available at call sites |
| Restricted compositionality might be insufficient for future extensions | Full compositionality can be derived for specific frame classes (e.g., deterministic frames) as a theorem |
| The canonical model may need converse in the future | Add as optional mixin, not as core axiom |

## Appendix

### A. Complete Case Analysis: Preorder-Generated Compositionality

Given preorder R on W, task_rel defined by sign, with `d=0 => (w=u)`:

The 9 cases for compositionality(task_rel(w,x,u), task_rel(u,y,v)):

1. x=0, y=0: w=u, u=v => w=v. By transitivity of =.
2. x=0, y>0: w=u, R(u,v) => R(w,v). Substitution.
3. x=0, y<0: w=u, R(v,u) => R(v,w). Substitution.
4. x>0, y=0: R(w,u), u=v => R(w,v). Substitution.
5. x>0, y>0: R(w,u), R(u,v) => R(w,v). Transitivity of R. (x+y > 0)
6. x>0, y<0, x+y>0: R(w,u), R(v,u) => R(w,v). **Requires totality of R AND either w=v or R goes one way.**
7. x>0, y<0, x+y=0: R(w,u), R(v,u) => w=v. **FALSE in general** (counterexample: R(a,b) and R(c,b) but a != c).
8. x>0, y<0, x+y<0: R(w,u), R(v,u) => R(v,w). **Requires totality of R.**
9. x<0, y>0, x+y>0: R(u,w), R(u,v) => R(w,v). **Requires totality of R.**
10. x<0, y>0, x+y=0: R(u,w), R(u,v) => w=v. **FALSE in general.**
11. x<0, y>0, x+y<0: R(u,w), R(u,v) => R(v,w). **Requires totality of R.**
12. x<0, y=0: R(u,w), u=v => R(v,w). Substitution.
13. x<0, y<0: R(u,w), R(v,u) => R(v,w). Transitivity of R. (x+y < 0)

Cases 7 and 10 are the fatal ones: they require that if two elements are R-related to a common element, they must be equal. This is "confluence + antisymmetry" and holds only in trivial preorders (partial orders where each element has at most one predecessor/successor in R).

### B. Mathlib Alignment

The key Mathlib structures for this formulation:

- `AddCommGroup D`: The duration group
- `LinearOrder D`: Total order on D
- `IsOrderedAddMonoid D`: Order-compatible addition
- `Preorder`: The base relation R on WorldState
- `VAdd G X` / `AddAction G X`: Mathlib's group action infrastructure (for the deterministic case)

For the non-deterministic case (relation, not function), there is no direct Mathlib structure. The closest is the relational composition structure in `Mathlib.Order.RelClasses`.

### C. Search Queries Used

- Codebase: `TaskFrame`, `task_rel`, `canonical_task_rel`, `CanonicalR`, `GContent`, `compositionality`, `sign`, `case_split`, `converse`
- Mathlib (attempted, failed due to network): `AddAction`, `VAddAction`, `PositiveCone`
- ROAD_MAP.md: Dead Ends section, Strategies section
