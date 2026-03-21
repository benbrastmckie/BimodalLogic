# Research Report: TaskFrame-based Closure Design (Teammate C)

**Task**: 18 - Dense Representation Theorem Completion
**Focus**: CanonicalTask-based closure design (correcting the CanonicalR-based approach)
**Date**: 2026-03-21

## Executive Summary

Previous research identified that closure of staged timelines under F/P-witnesses (using CanonicalR) converges to all of CanonicalMCS. This finding is correct but was misinterpreted as a "dead end." The correct interpretation is: **CanonicalR-based closure IS closure over ExistsTask, which loses duration structure**. The fix is to use CanonicalTask (the three-place task relation) as the closure operator basis, which preserves duration/distance information.

Key findings:
1. CanonicalR encodes only *existence* of a forward relationship, not *distance*
2. Closure under CanonicalR = closure under ExistsTask (the existential shadow of CanonicalTask)
3. CanonicalTask-based closure preserves distance information and converges to a proper subset
4. DenseTask is the correct instantiation for dense temporal logic
5. The staged timeline should be viewed as constructing a TaskFrame, not just a CanonicalR-connected set

## 1. Why CanonicalR-Based Closure Is Wrong

### 1.1 What CanonicalR Actually Captures

From `CanonicalFrame.lean`:
```lean
def CanonicalR (M M' : Set Formula) : Prop := g_content M ⊆ M'
```

This captures: "all G-formulas in M are satisfied at M'." Semantically:
- `CanonicalR(M, M')` means M' is *some* future of M
- No information about *how far* into the future M' is
- All positive durations collapse to the same relation

### 1.2 CanonicalR = Existential Shadow of CanonicalTask

The three-place task relation (from reports 18-19) is:
```
CanonicalTask(u, n, v)  -- u reaches v in exactly n steps (discrete)
DenseTask(u, q, v)      -- u reaches v after duration q (dense)
```

The two-place CanonicalR is the *existential projection*:
```
CanonicalR(u, v) = ExistsTask(u, v) := exists d > 0, task_rel(u, d, v)
```

This projection loses all duration information. When we close under CanonicalR/ExistsTask, we're asking "what MCSes are reachable?" without caring about distances.

### 1.3 Why Closure Converges to All CanonicalMCS

Teammate A's finding (report-08a) is correct:
```
cl(S) = lfp(F) where F(X) = S ∪ FWit(X) ∪ PWit(X)
```
converges to all of CanonicalMCS at omega steps.

**Why this happens**: Every MCS is reachable from any root MCS by iterated Lindenbaum extension. The F-witness for any `F(phi) ∈ M` is constructed via:
1. Form seed: `{phi} ∪ g_content(M)`
2. Extend via Lindenbaum to get MCS W
3. W satisfies `CanonicalR(M, W)` and `phi ∈ W`

Since *any* MCS can be produced this way (given appropriate phi choices), the closure is unbounded.

### 1.4 The Mistake: Treating Unbounded Closure as Failure

The previous analysis treated "closure = CanonicalMCS" as a failure. But this is *expected* for CanonicalR-based closure because CanonicalR forgets distance. The solution is not to abandon closure, but to use a distance-aware closure.

## 2. CanonicalTask-Based Closure

### 2.1 The Three-Place Task Relation (Discrete Case)

From `CanonicalTaskRelation.lean`:
```lean
inductive CanonicalTask_forward : Set Formula → Nat → Set Formula → Prop where
  | base {u} : CanonicalTask_forward u 0 u
  | step {u w v n} : Succ u w → CanonicalTask_forward w n v → CanonicalTask_forward u (n+1) v

def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k => CanonicalTask_forward u k v
  | Int.negSucc k => CanonicalTask_backward u (k+1) v
```

The key difference from CanonicalR:
- `CanonicalTask(u, n, v)` is *deterministic* in the sense that n counts exact steps
- Multiple different v may satisfy `CanonicalTask(u, n, v)` (non-determinism at each step)
- But `CanonicalTask(u, n, v)` and `CanonicalTask(u, n, v')` with `v != v'` represents *branching*, not redundancy

### 2.2 What Witnesses Would Be Added?

Under CanonicalTask-based closure, when we have `F(phi) ∈ M`, we add a witness W with:
1. `phi ∈ W`
2. `CanonicalTask(M, 1, W)` -- exactly one step forward (if discrete)
3. Or `CanonicalTask(M, q, W)` for some specific `q > 0` (if dense)

The critical difference: the witness is *placed at a specific distance*, not just "somewhere in the future."

### 2.3 Structure Preserved

CanonicalTask-based closure preserves:
- **Distance metric**: Each witness has a defined distance from its source
- **Compositionality**: `CanonicalTask(u, m, w)` and `CanonicalTask(w, n, v)` imply `CanonicalTask(u, m+n, v)`
- **Bounded witness corollary**: If `F^n(phi) ∈ u` and `F^(n+1)(phi) ∉ u`, the witness is at distance n

### 2.4 Would It Converge to a Proper Subset?

**For discrete (CanonicalTask over Z)**: Yes, if we require witnesses at distance 1.

The single-step forcing theorem (`bounded_witness` in CanonicalTaskRelation.lean) shows:
- If `F(phi) ∈ M` and `F(F(phi)) ∉ M`, the witness is at distance 1
- This bounds witness distance based on F-nesting depth

The closure converges because:
1. Each F-obligation has bounded witness distance (by formula complexity)
2. New witnesses also have bounded complexity obligations
3. The subformula relation is well-founded

**For dense (DenseTask over Q)**: More subtle.

In dense logic, `F(phi) ∈ M` implies `F(F(phi)) ∈ M` by the density axiom. There is no "bounded distance" based on F-nesting. However:
- DenseTask assigns *arbitrary rational durations*
- The Cantor isomorphism `TimelineQuot ≃o Q` provides the group structure
- Closure under DenseTask preserves the dense ordering but doesn't add "new points" -- it assigns durations to existing MCSes

## 3. DenseTask as the Dense CanonicalTask

### 3.1 Definition of DenseTask

From `DenseTaskRelation.lean`:
```lean
def DenseTask (u q v : TimelineQuot root_mcs root_mcs_proof) : Prop :=
  @HAdd.hAdd _ _ _ (timelineQuotAddCommGroup ...) u q = v
```

This is: "v is u plus duration q" in the transferred group structure on TimelineQuot.

### 3.2 How DenseTask Interacts with Closure

DenseTask is *deterministic*: given u and q, there is exactly one v with `DenseTask(u, q, v)`.

This changes the closure semantics:
- CanonicalR-closure: "add an MCS somewhere in the future"
- DenseTask-closure: "place a witness at a specific rational distance"

For DenseTask-closure to be well-defined:
1. Start with staged timeline (TimelineQuot elements)
2. Each F-obligation `F(phi) ∈ M` at time t requires a witness at some `s > t`
3. The witness W must satisfy `DenseTask(t, s-t, s)` and `phi ∈ timelineQuotMCS(s)`

The critical insight: **DenseTask-closure is about assigning MCSes to rational timepoints, not about adding new MCSes.**

### 3.3 Is DenseTask the Correct Notion for Dense Witnesses?

Yes, with a caveat:
- DenseTask captures the *temporal structure* (when things happen)
- The *modal structure* (what's accessible) is still via CanonicalR

The truth lemma for F:
```
F(phi) ∈ M at time t  iff  ∃ s > t, phi ∈ timelineQuotMCS(s)
```

This is equivalent to:
```
F(phi) ∈ M  iff  ∃ q > 0, DenseTask(t, q, s) ∧ phi ∈ timelineQuotMCS(s)
```

The witness is found via CanonicalR (semantically), but placed via DenseTask (structurally).

## 4. The Staged Timeline Revisited as TaskFrame Construction

### 4.1 Current View: CanonicalR-Connected Set

The current staged construction builds:
1. Start with root MCS M₀
2. Add F/P-witnesses via Lindenbaum
3. Add density intermediates
4. Form `denseTimelineUnion` as the set of all added MCSes
5. Quotient by antisymmetrization to get `TimelineQuot`

This views the timeline as "the set of MCSes reachable from M₀ under CanonicalR."

### 4.2 Correct View: TaskFrame Construction

The timeline should be viewed as constructing a TaskFrame:
1. **WorldState**: The MCSes in the timeline
2. **D (Duration)**: TimelineQuot with transferred Q-structure
3. **task_rel**: `DenseTask(t, q, s)` iff `t + q = s`

Properties to satisfy:
- `nullity_identity`: `DenseTask(t, 0, s) iff t = s` -- from group identity
- `forward_comp`: Composition -- from group associativity
- `converse`: `DenseTask(t, q, s) iff DenseTask(s, -q, t)` -- from group inverse

### 4.3 Should the Staged Timeline Be Closed Under DenseTask Witnesses?

The staged timeline is already closed under DenseTask in the sense that:
- `DenseTask(t, q, s)` defines s = t + q, which exists by group closure
- The question is whether `phi ∈ timelineQuotMCS(s)` for the required phi

The gap (m > 2k in ClosureSaturation.lean) is:
- An MCS M at stage m > 2k has `F(phi) ∈ M`
- The witness for `F(phi)` was processed at stage 2k+1 < m
- M wasn't in the build at stage 2k+1, so no witness was added for M's `F(phi)`

This is NOT a TaskFrame structure issue -- it's a temporal coherence issue (FMCS property).

### 4.4 Density and the Three-Place Relation

The density axiom `F(phi) → F(F(phi))` creates a key constraint:
- In discrete logic: `F(phi) ∈ M` and `F(F(phi)) ∉ M` bounds witness distance
- In dense logic: `F(phi) ∈ M` always implies `F(F(phi)) ∈ M` -- no bounded distance

For DenseTask:
- Witnesses can be at *any* positive rational distance
- The density interpolation theorem (`density_interpolation` in DenseTaskRelation.lean) shows any task can be subdivided

This means:
- Dense closure doesn't have a "step-by-step" structure like discrete
- Instead, all witnesses exist simultaneously (the full TimelineQuot is built at once)
- The question is: does every `F(phi) ∈ timelineQuotMCS(t)` have a witness `s > t` with `phi ∈ timelineQuotMCS(s)`?

## 5. Correct Infrastructure Design

### 5.1 The Mathematical Picture

For dense completeness, we need:

**Layer 1: World States**
- `W = CanonicalMCS` (all MCSes)
- Modal relation: CanonicalR

**Layer 2: Time Domain**
- `D = TimelineQuot ≃o Q`
- Ordered abelian group structure

**Layer 3: Task Frame**
- `TaskFrame D` with `WorldState = CanonicalMCS` (or TimelineQuot elements)
- `task_rel = DenseTask`

**Layer 4: FMCS**
- `FMCS` indexed by `D`
- `mcs : D → Set Formula` assigning MCSes to timepoints
- Temporal coherence: `forward_G`, `forward_F`, `backward_H`, `backward_P`

**Layer 5: BFMCS**
- Bundle of FMCSes for modal saturation
- `modal_forward`, `modal_backward` properties

### 5.2 Two Viable Approaches

**Approach A: CanonicalMCS as Primary Domain**

Use `D = CanonicalMCS` ordered by CanonicalR.
- Pro: `forward_F` and `backward_P` are trivially satisfied (every Lindenbaum witness is an MCS)
- Con: CanonicalMCS lacks `AddCommGroup` structure
- Con: Need to prove `DenselyOrdered CanonicalMCS`

If we generalize `TaskFrame` to not require `AddCommGroup`:
```lean
structure TaskFrame' (D : Type*) [LinearOrder D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  -- axioms that don't reference addition
```

Then CanonicalMCS works directly.

**Approach B: TimelineQuot with Proper Closure**

Keep `D = TimelineQuot` with its `AddCommGroup` structure.
- Pro: Compatible with existing infrastructure
- Con: Need to ensure temporal coherence (the m > 2k gap)

The closure needed is NOT on MCSes but on *saturation*:
- Ensure every `F(phi)` obligation at every time t has a witness at some s > t
- This is the FMCS `forward_F` property, not a closure on the set of worlds

### 5.3 Key Definitions (Sketch)

**For Approach A (CanonicalMCS domain)**:

```lean
-- CanonicalMCS is DenselyOrdered via density axiom
instance : DenselyOrdered CanonicalMCS := {
  dense := fun a b hab => by
    -- Use density_frame_condition: for CanonicalR(a, b) with ¬CanonicalR(b, a),
    -- exists w with CanonicalR(a, w) and CanonicalR(w, b)
    obtain ⟨w, h_aw, h_wb⟩ := density_frame_condition a.world b.world a.is_mcs b.is_mcs hab
    exact ⟨⟨w, is_mcs_from_density_witness ...⟩, h_aw, h_wb⟩
}

-- Task relation via CanonicalR
def CanonicalMCSTaskRel (a : CanonicalMCS) (d : CanonicalMCS) (b : CanonicalMCS) : Prop :=
  -- This doesn't make sense because d should be a duration, not a world
  -- The issue: CanonicalMCS conflates worlds and times
```

**Problem with Approach A**: CanonicalMCS is both the world type AND the time type. The TaskFrame structure separates these: `WorldState` and `D` are different types. Using CanonicalMCS for both creates a degenerate structure.

**For Approach B (TimelineQuot domain)**:

```lean
-- Task relation on TimelineQuot (already defined)
def DenseTask (u q v : TimelineQuot ...) : Prop := u + q = v

-- FMCS with temporal coherence
def timelineQuotFMCS : FMCS (TimelineQuot ...) := {
  mcs := timelineQuotMCS
  is_mcs := timelineQuotMCS_is_mcs
  forward_G := timelineQuotFMCS_forward_G
  backward_H := timelineQuotFMCS_backward_H
  forward_F := timelineQuotFMCS_forward_F  -- THE GAP
  backward_P := timelineQuotFMCS_backward_P  -- THE GAP
}
```

The gap is proving `forward_F` and `backward_P` for the timelineQuotFMCS.

### 5.4 Resolving the Gap: Eager Processing

The m > 2k gap arises because:
- Formula phi with encoding k is processed at stage 2k+1
- Point p entering at stage m > 2k+1 misses this processing

**Fix**: Modify staged construction to process ALL F-obligations for each newly added point:

```lean
-- Pseudocode for eager processing
def processAllObligations (p : StagedPoint) : Finset StagedPoint :=
  let f_witnesses := for phi in all_formulas, if F(phi) ∈ p.mcs then witness_for(phi, p)
  let p_witnesses := for phi in all_formulas, if P(phi) ∈ p.mcs then witness_for(phi, p)
  f_witnesses ∪ p_witnesses
```

This ensures every point has all its F/P-obligations satisfied when added.

**Finiteness concern**: The set of formulas is infinite, so we can't process "all" at once.

**Resolution**: Use the fact that obligations are determined by `mcs` membership, and each MCS has only countably many F-formulas. Process them via dovetailing:
- At each stage, process the "next" F-formula for each existing point
- Continue until all obligations are covered

This is essentially the existing dovetailed construction (`DovetailedBuild.lean`), but needs completion.

## 6. Summary of Findings

| Question | Finding |
|----------|---------|
| Why is CanonicalR-based closure wrong? | CanonicalR forgets duration; closure converges to all MCSes |
| What is the correct closure basis? | CanonicalTask (discrete) or DenseTask (dense) -- preserves distance |
| What witnesses would CanonicalTask-closure add? | Witnesses at *specific distances*, not arbitrary futures |
| Does CanonicalTask-closure converge to a subset? | Yes (discrete); more nuanced for dense |
| Is DenseTask the correct dense notion? | Yes -- it assigns durations via Cantor isomorphism |
| Should staged timeline be closed under DenseTask? | Not closure on MCSes, but saturation of FMCS temporal coherence |
| What's the correct infrastructure? | Either generalize TaskFrame (remove AddCommGroup), or complete dovetailed construction |

## 7. Recommended Next Steps

### Immediate (unblocks Task 18):

1. **Complete `derive_F_to_FF`** (CantorPrereqs.lean sorry #7) -- mechanical derivation, 1-2 hours

2. **Choose approach**:
   - A: Generalize TaskFrame, use CanonicalMCS (need to resolve world/time conflation)
   - B: Complete dovetailed construction for eager processing

### If Approach A (CanonicalMCS):

3. Prove `DenselyOrdered CanonicalMCS` using `density_frame_condition`
4. Define `task_rel` that separates world and time dimensions
5. Wire `parametric_canonical_truth_lemma`

### If Approach B (TimelineQuot with eager processing):

3. Complete `DovetailedCoverageReach.lean` sorries (termination of density recursion)
4. Prove `forward_F` using dovetailed coverage
5. Archive ClosureSaturation.lean exploration code

## Appendix: Codebase Files Referenced

- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (CanonicalR definition, canonical_forward_F)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` (CanonicalTask, bounded_witness)
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTaskRelation.lean` (DenseTask, DenseTaskFrame)
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` (m > 2k gap analysis)
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` (eager processing infrastructure)
- `specs/006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md`
- `specs/006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md`
- `specs/018_dense_representation_theorem_completion/reports/08_team-research.md`
- `specs/018_dense_representation_theorem_completion/reports/08_teammate-a-findings.md`
