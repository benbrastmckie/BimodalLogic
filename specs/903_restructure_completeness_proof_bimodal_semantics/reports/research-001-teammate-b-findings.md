# Research Report: Task #903 - Teammate B Findings

**Task**: Restructure completeness proof for Bimodal task semantics
**Date**: 2026-02-19
**Focus**: Prior art, alternative approaches, Boneyard lessons, recommended patterns

## Summary

The codebase has undergone at least 5 major iterations of completeness proof architecture (v1-v5 in Boneyard, plus current Bundle and FMP approaches). The core obstruction is bridging BMCS/internal truth to the standard `truth_at` definition from `Semantics/Truth.lean`. The task description asks for a completeness proof that constructs a task frame, model, and contextual parameters from the *actual semantics definitions* (TaskFrame, TaskModel, WorldHistory, truth_at), not from a substitute definition. This bridge is exactly the gap that has never been closed.

## Findings

### 1. Prior Art in Codebase

#### A. FMP Completeness (`Metalogic/FMP/SemanticCanonicalModel.lean`) - SORRY-FREE

The FMP approach is the most successful completeness result. It proves:
```lean
noncomputable def fmp_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    ⊢ phi
```

**Key pattern**: It works by defining an *internal* truth predicate (`semantic_truth_at_v2`) that operates on `FiniteWorldState` objects, NOT by constructing a `TaskFrame`/`TaskModel`/`WorldHistory` and using the standard `truth_at`. The comment in `DeprecatedCompleteness.lean` explicitly states this was a deliberate retreat from the standard semantics because bridging to `truth_at` requires solving:

1. **Box case**: `truth_at M tau t (box psi) = forall sigma : WorldHistory F, truth_at M sigma t psi` quantifies over ALL WorldHistories - uncountably many. The finite model only knows about finitely many states.
2. **Temporal cases**: `truth_at M tau t (all_future psi) = forall s >= t, truth_at M tau s psi` quantifies over ALL integers s >= t, but the finite model has times in [-k, k] only.

**Lesson**: The FMP proof avoids the bridge entirely. It is sorry-free but does NOT prove completeness with respect to the actual `truth_at` from `Semantics/Truth.lean`.

#### B. BMCS Completeness (`Metalogic/Bundle/Completeness.lean`) - SORRY-FREE but Internal

The BMCS approach proves:
```lean
theorem bmcs_weak_completeness (phi : Formula) (h_valid : bmcs_valid phi) :
    Nonempty (DerivationTree [] phi)
```

Where `bmcs_valid` uses `bmcs_truth_at` (from `BMCSTruth.lean`), which is a *different* truth predicate than `truth_at`. In `bmcs_truth_at`, the box case quantifies over families in the *bundle*, not over all WorldHistories. This is Henkin-style: the truth predicate is restricted.

The file comments claim:
```
⊢ phi  <->  bmcs_valid phi  ->  standard_valid phi
```

But the rightward arrow (`bmcs_valid -> standard_valid`) is **never proven** anywhere. It would require constructing an actual `TaskFrame`/`TaskModel`/`WorldHistory` from a BMCS and showing `bmcs_truth_at` implies `truth_at`.

**Lesson**: BMCS completeness is internally sound but does not connect to standard semantics.

#### C. Soundness (`Metalogic/Soundness.lean`) - SORRY-FREE, Standard Semantics

The soundness theorem is the one result that does use the actual standard semantics:
```lean
-- soundness : derivability implies semantic validity (Gamma ⊢ phi -> Gamma |= phi)
```

Where `Gamma |= phi` uses the standard `semantic_consequence` from `Validity.lean`, which is defined in terms of `truth_at`. This is fully proven for all 14 axioms and 7 inference rules.

**Lesson**: The standard semantics IS usable for proofs. Soundness succeeded. The challenge is the reverse direction.

### 2. The Standard Semantics Definitions (What the Task Asks For)

The task description requires constructing objects from these existing definitions:

- **TaskFrame** (`Semantics/TaskFrame.lean`): `WorldState : Type`, `task_rel : WorldState -> D -> WorldState -> Prop`, plus nullity and compositionality
- **TaskModel** (`Semantics/TaskModel.lean`): `valuation : F.WorldState -> String -> Prop`
- **WorldHistory** (`Semantics/WorldHistory.lean`): `domain : D -> Prop` (convex), `states : (t : D) -> domain t -> F.WorldState`, `respects_task`
- **truth_at** (`Semantics/Truth.lean`): Standard recursive evaluation
- **valid** / **semantic_consequence** (`Semantics/Validity.lean`): Quantifies over ALL types D, TaskFrames, TaskModels, WorldHistories, times

The completeness theorem in standard form would be:
```lean
theorem standard_completeness (phi : Formula) :
    valid phi -> Nonempty (⊢ phi)
```

Or contrapositively: `not (⊢ phi) -> not (valid phi)`, which means: if phi is not provable, construct D, F, M, tau, t such that `not (truth_at M tau t phi)`.

### 3. Boneyard Lessons (What Failed Before)

#### Metalogic v1-v3: The Duration-Based Approach
Multiple attempts at directly constructing canonical models with MCS as world states. Archived in `Boneyard/Metalogic/`, `Boneyard/Metalogic_v2/`, `Boneyard/Metalogic_v3/`.

**Failures**:
- Compositionality of task_rel for finite time domains (the sum of two durations can exceed the time bound)
- Bridge from "truth in closure-MCS" to standard `truth_at`
- 30+ sorries in the Representation approach

#### Metalogic v4: Monolithic Completeness
`Boneyard/Metalogic_v4/Completeness/MonolithicCompleteness.lean` - a 3700-line monolithic file.

**Failure**: Too complex to maintain, sorries accumulated.

#### Metalogic v5: Representation + Universal Canonical Model
`Boneyard/Metalogic_v5/Representation/` - The most ambitious attempt. Tried to build a "universal canonical model" with indexed MCS families, canonical histories, and coherent constructions.

**Failures**:
- 30+ sorries in the Representation approach
- `CoherentConstruction.lean` had intractable coherence issues
- `UniversalCanonicalModel.lean` never reached sorry-free status
- Archived in Task 809

#### FDSM Approach
`Boneyard/FDSM/` - "Filtered Decidable Semantic Model". Tried to use tracked histories with modal saturation.

**Failures**:
- Single-history construction trivializes modal operators
- Multi-history saturation never completed
- `ModalSaturation.lean` has TODO stubs for `tracked_saturation_step` and `tracked_saturated_histories`

#### Key Boneyard Insight
The `DeprecatedCompleteness.lean` file is the most honest assessment:
> "For a sorry-free completeness proof suitable for publication, use `semantic_weak_completeness`."

This acknowledges that the bridge from internal truth to standard `truth_at` has never been built.

### 4. Mathlib Patterns Found

Searching Mathlib reveals:
- `FirstOrder.Language.Theory.IsMaximal` - Mathlib's equivalent of MCS for first-order logic
- `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem` - Negation completeness for maximal theories
- `FirstOrder.Language.Theory.IsMaximal.isComplete` - Maximal theories are complete
- `FirstOrder.Language.Theory.CompleteType` - Complete types (maximally consistent formula sets)

Mathlib's model theory uses typed structures (`Language.Structure M`) with semantic evaluation, not Kripke-style frames. The first-order completeness in Mathlib relies on the Henkin construction with model existence via compactness/ultraproducts, which is a different pattern than modal completeness.

**No direct modal logic completeness exists in Mathlib.** The project would need to build this from scratch, which is what the Boneyard attempts tried to do.

### 5. The Fundamental Obstruction (Why Standard Completeness is Hard)

The core difficulty is the **box case** in standard semantics:

```lean
| Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
```

This quantifies over ALL `WorldHistory F` - an uncountably infinite type (parameterized by arbitrary domain predicates and state functions). When constructing a canonical model:

1. World states are MCS (or equivalence classes thereof) - countable or finite
2. The box operator says: phi is true at ALL histories at time t
3. There are uncountably many histories through ANY finite set of world states
4. The canonical model must make phi true at ALL of them, not just the canonical ones

This is fundamentally different from standard Kripke semantics where box quantifies over accessible *worlds*, not over *histories*. In standard modal logic, the canonical model has worlds = MCS and accessibility encodes the box. Here, the box quantifies over WorldHistories (which are richer than just worlds).

**The S5 structure helps**: Since box in TM logic is S5 (the modality quantifies over ALL histories universally - no accessibility relation), every world history at time t gives the same truth values for boxed formulas. This means:
- `truth_at M sigma t (box phi) = truth_at M rho t (box phi)` for any sigma, rho
- The box truth doesn't depend on the current history, only on the set of all histories

But the construction still needs to ensure phi holds at ALL histories, not just canonical ones.

### 6. Analysis of What "Constructing from Actual Definitions" Requires

Given a consistent formula phi (i.e., `not (⊢ phi.neg)`), the task asks for:

**Step 1**: Choose temporal type `D`. The natural choice is `Int` (already used in the codebase).

**Step 2**: Construct a `TaskFrame Int`:
- `WorldState`: Could be MCS (Set Formula), or FiniteWorldState, or CanonicalWorldState
- `task_rel`: Must satisfy nullity and compositionality
- Compositionality has been problematic (see Boneyard lessons about finite time bounds)

**Step 3**: Construct a `TaskModel F`:
- `valuation : F.WorldState -> String -> Prop`
- Natural choice: `valuation w p = (atom p) ∈ w` (for MCS-based worlds)

**Step 4**: Construct a `WorldHistory F`:
- `domain : Int -> Prop` - convex subset
- `states : (t : Int) -> domain t -> F.WorldState` - state assignment
- `respects_task` - must satisfy compositionality

**Step 5**: Choose a time `t : Int` (e.g., `t = 0`)

**Step 6**: Prove `truth_at M tau t phi` (or `not (truth_at M tau t phi.neg)`)

The hardest parts:
- Compositionality of task_rel (Step 2)
- Making `truth_at` agree with MCS membership for the box case (Step 6)
- Making `truth_at` agree with MCS membership for temporal cases (Step 6)

## Recommended Patterns to Adopt

### Pattern A: Trivial Frame + Universal Domain (Recommended)

Use the simplest possible frame structure to bypass compositionality issues:

```lean
-- World states: CanonicalWorldState (MCS as subtypes)
-- Task relation: trivial (always true) - satisfies both nullity and compositionality
-- Domain: universal (all of Int)
-- States: constant history (same MCS at all times)
```

**Why trivial task_rel works**: The JPL paper defines task frames with the task relation as a constraint on which state transitions are possible. A permissive (trivial) task relation allows ALL transitions. This is valid - it just means the frame doesn't constrain transitions.

**Key insight**: The box case in `truth_at` quantifies over ALL `WorldHistory F`. With a trivial task_rel (`fun _ _ _ => True`), every function `Int -> WorldState` can be packaged as a valid WorldHistory. This means box quantifies over ALL possible state assignments - which matches the S5 semantics of box in TM logic (box quantifies over all possible scenarios).

**Problem**: With trivial task_rel and universal domain, we have:
```
truth_at M tau t (box phi)
  = forall sigma : WorldHistory F, truth_at M sigma t phi
```
This still requires phi to be true at ALL WorldHistories, including non-canonical ones.

### Pattern B: Restricted Frame (WorldState = Unit, all truth in valuation)

A radical simplification:

```lean
-- World state: Unit (single world state)
-- Task relation: trivial
-- Valuation: valuation () p = (atom p ∈ Gamma_MCS)
-- History: trivial (domain = everything, states = fun _ _ => ())
```

Then `truth_at M tau t (atom p) = exists (ht : True), valuation () p = (atom p ∈ MCS)`.

**Problem**: Box case becomes `forall sigma : WorldHistory F, truth_at M sigma t phi`. Since WorldState = Unit, all histories assign the same state () at all times. So `truth_at M sigma t phi = truth_at M tau t phi` for all sigma, tau. This makes `box phi = phi`, which means box is trivialized. This won't work for non-trivial modal formulas.

### Pattern C: Canonical Model with Non-Trivial WorldState (Most Promising)

This is the standard approach for S5 modal completeness:

```lean
-- WorldState: CanonicalWorldState = {S : Set Formula // SetMaximalConsistent S}
-- Task relation: trivial (allowing all transitions)
-- Valuation: valuation w p = (atom p ∈ w.val)
-- Histories: One WorldHistory per MCS (canonical histories)
```

For the box case:
- Forward: `box phi ∈ tau_MCS` implies (by MCS closure under Modal T) `phi ∈ tau_MCS`. Need to show `truth_at M sigma t phi` for ALL sigma. Since box is S5 and `box phi` is in the CANONICAL history's MCS, we need `phi` to be true at ALL histories.
- The key: `box phi ∈ some_MCS` implies (by S5 properties) `phi` is a THEOREM (provable from empty context). Then by soundness, `phi` is valid, hence true at all models, hence true at all histories.

Wait - that's not right for non-theorems. `box phi ∈ MCS` does NOT mean phi is a theorem; it means phi is provable from the assumptions in the MCS.

**Revised S5 insight**: In TM logic, the box semantics is that box quantifies over ALL histories (not relative to the current MCS). So `box phi` is true iff phi is true at ALL possible histories. This means `box phi ∈ MCS` iff for every MCS M', phi ∈ M'. This is equivalent to phi being a THEOREM (provable without assumptions), because if phi is in ALL MCS, it's in particular in the trivial MCS, which means it's provable.

Actually, this is the S5 collapse: in S5, `box phi` is either true at all worlds or false at all worlds. If `box phi ∈ MCS_1` and `neg(box phi) ∈ MCS_2`, then both MCS are consistent but the model can't satisfy both. The resolution is that in the canonical model for S5, the BMCS approach restricts to a coherent collection.

This is precisely the gap the codebase has struggled with.

### Pattern D: Henkin-to-Standard Bridge (Most Direct for the Task)

The most direct approach to the task description:

1. Use the existing BMCS completeness (sorry-free) which gives: `consistent [phi] -> exists BMCS B, bmcs_truth_at B eval 0 phi`
2. Build a bridge theorem: `bmcs_truth_at B fam t phi -> truth_at M_B tau_B t phi` for a specific TaskFrame, TaskModel, and WorldHistory constructed from B
3. This requires constructing:
   - `F_B : TaskFrame Int` from a BMCS B
   - `M_B : TaskModel F_B` from B
   - `tau_B : WorldHistory F_B` from B's eval_family
   - Proving: `phi ∈ fam.mcs t <-> truth_at M_B tau_fam t phi` for all formulas

**Construction sketch**:
- `F_B.WorldState := CanonicalWorldState` (MCS as subtypes)
- `F_B.task_rel := fun w d v => True` (trivial)
- `M_B.valuation := fun w p => Formula.atom p ∈ w.val`
- For each family `fam` in B, define `tau_fam : WorldHistory F_B` with:
  - `domain := fun _ => True` (universal)
  - `states t _ := ⟨fam.mcs t, fam.is_mcs t⟩`
  - `respects_task` is trivial (task_rel is always True)

Then the truth lemma would be:
```
phi ∈ fam.mcs t <-> truth_at M_B tau_fam t phi
```

This is essentially the BMCS truth lemma, but with `truth_at` instead of `bmcs_truth_at`.

**The box case obstruction**:
- Forward: `box phi ∈ fam.mcs t` implies (by BMCS modal_forward) `phi ∈ fam'.mcs t` for all fam' in B. Need: `truth_at M_B sigma t phi` for ALL `sigma : WorldHistory F_B`. But sigma can be any WorldHistory, not just those corresponding to families in B.
- The set of all WorldHistories is much larger than the set of families in B.

**Resolution options**:
1. Make the frame have a constrained task_rel that forces all valid histories to correspond to BMCS families (but this conflicts with compositionality/convexity requirements)
2. Prove that if phi is in ALL MCS at time t (which S5 modal_forward gives), then phi must be true at ALL WorldHistories at time t (this would require that the model is "full" enough)
3. Use soundness: if phi is in ALL MCS, then not-phi is not consistent, so not-phi is not provable from empty context, so by soundness phi is valid, so phi is true at ALL models including ours

**Option 3 is circular**: we're trying to prove completeness and using soundness as a subroutine. But wait - we're not proving "valid -> provable". We're proving "consistent -> satisfiable". The soundness detour would be:
- `box phi ∈ MCS` (in ALL families of the BMCS)
- This means phi is in ALL MCS in the BMCS
- By BMCS construction, phi is in every SetMaximalConsistent set (requires a separate argument)
- Therefore not-phi is not in any consistent set, so not-phi derives bot
- Therefore phi is provable: `⊢ phi`
- By soundness: phi is valid (true in ALL models)
- In particular, phi is true at ALL WorldHistories in our canonical model

This is actually sound reasoning! The key intermediate step is showing that phi being in every MCS of the BMCS implies phi is a theorem. This follows from the S5 axiom `modal_b : phi -> box(diamond(phi))`: if not-phi were consistent, not-phi would be in some MCS M, and `box(diamond(not-phi))` would be in M, meaning `diamond(not-phi)` is in ALL MCS. But `diamond(not-phi) = neg(box(phi))`, so `box(phi)` would NOT be in all MCS - contradiction.

**This is the recommended approach** because it reuses existing sorry-free infrastructure.

### Pattern E: Direct Construction (Alternative)

Instead of bridging from BMCS, directly construct the canonical model:

1. From a consistent set `{phi}`, extend to MCS M_0 via Lindenbaum
2. Define WorldState = {S : Set Formula // SetMaximalConsistent S}
3. Define task_rel = trivial
4. Define valuation from atom membership
5. For each MCS M, define a canonical WorldHistory through M
6. Set eval_history = canonical history through M_0, time = 0
7. Prove truth lemma by induction on formula structure

The box case still requires the S5 argument, but can avoid the BMCS machinery entirely.

## Analysis of Sorry Debt in Current Approach

The current Bundle/ directory has **183 sorry occurrences across 22 files**. The main sorry chains are:

1. **FinalConstruction.lean** (32 sorries): Combining modal saturation with temporal coherence
2. **TemporalChain.lean** (14 sorries): Building temporal witness chains
3. **SaturatedConstruction.lean** (12 sorries): Modal saturation infrastructure
4. **DovetailingChain.lean** (9 sorries): Dovetailing for temporal coherence
5. **TruthLemma.lean** (9 sorries): Backward direction of truth lemma
6. **ZornFamily.lean** (11 sorries): Zorn-based family construction

Most of these sorries exist because of the temporal coherence problem: ensuring ALL families in the BMCS have proper F/P witness propagation. The task description suggests this complexity may be unnecessary if the proof is restructured to work with the actual semantics definitions directly.

## Confidence Level

**Medium-High** confidence in Pattern D (Henkin-to-Standard Bridge using soundness for box case).

Rationale:
- The box case via S5 + soundness argument is mathematically sound and avoids the temporal coherence nightmare
- The BMCS completeness is already sorry-free, providing a solid foundation
- The trivial task_rel avoids compositionality issues entirely
- The universal domain avoids convexity complexity
- The main risk is the formal complexity of the S5 argument showing "phi in all MCS of BMCS implies phi is a theorem"

**Low** confidence in Pattern E (direct construction without BMCS) because:
- It would require rebuilding much of the MCS machinery from scratch
- The S5 argument is the same regardless of approach
- No advantage over Pattern D

## Recommended Architecture for Restructured Proof

```
1. Existing infrastructure (reuse as-is):
   - Metalogic/Core/MaximalConsistent.lean (Lindenbaum, MCS properties)
   - Metalogic/Bundle/Completeness.lean (BMCS representation theorem)
   - Metalogic/Soundness.lean (soundness theorem)

2. New bridge module (to create):
   - Metalogic/StandardCompleteness.lean
     - Constructs TaskFrame, TaskModel, WorldHistory from BMCS
     - Proves truth_at bridge lemma
     - Proves standard completeness theorem

3. Key lemmas needed:
   a. bmcs_all_families_implies_theorem:
      If phi ∈ fam.mcs t for ALL fam in B and ALL t,
      then ⊢ phi

   b. theorem_implies_true_at_all:
      If ⊢ phi, then for any M tau t, truth_at M tau t phi
      (This is soundness, already proven)

   c. canonical_truth_lemma:
      phi ∈ fam.mcs t <-> truth_at M_B tau_fam t phi
      (For non-box cases: by induction. For box case: use (a) + (b))

   d. standard_representation:
      consistent [phi] -> exists F M tau t, truth_at M tau t phi
      (Combines BMCS representation + bridge)

   e. standard_completeness:
      valid phi -> ⊢ phi
      (Contrapositive of standard_representation)
```

## Key Risk: The S5 Box Argument

The argument "phi in all MCS of BMCS implies phi is a theorem" needs careful formalization:

1. Assume phi is in all families' MCS at all times in BMCS B
2. Suppose phi is NOT a theorem (⊢ phi is empty)
3. Then {phi.neg} is consistent
4. Extend to MCS M_neg containing phi.neg
5. M_neg is NOT in B (since phi is not in M_neg but phi is in all MCS of B)
6. But we need a contradiction...

Actually, the argument is:
1. B is a BMCS where the eval family has `box phi ∈ eval.mcs t`
2. By BMCS modal_forward: phi ∈ fam.mcs t for all fam in B
3. By BMCS modal_backward: box phi ∈ fam.mcs t for all fam in B
4. So box phi is in ALL families at ALL times (by the coherence of B)
5. In particular, box phi is in eval.mcs t
6. By Modal T closure: phi ∈ eval.mcs t

This gives us phi in the canonical history, but we need phi at ALL WorldHistories. The issue is that arbitrary WorldHistories don't correspond to families in B.

**Revised approach**: For the box case, instead of showing phi is in ALL WorldHistories, show that the canonical model's WorldHistories are exactly those induced by BMCS families. This requires the frame to be constrained so that only "canonical" histories exist.

**Frame constraint idea**: Define `F.WorldState := CanonicalWorldState` and `F.task_rel w d v := True`. Then a WorldHistory is any function from (convex subset of Int) to CanonicalWorldState respecting task_rel. Since task_rel is trivial, every such function is a valid history. There are many more of these than BMCS families.

**Better approach**: Use `F.WorldState := Unit` with a single world state. Then:
- ALL WorldHistories are equivalent (they all assign `()` to all times)
- `truth_at M sigma t phi = truth_at M tau t phi` for all sigma, tau
- So `truth_at M tau t (box phi) = truth_at M tau t phi`
- Box becomes redundant (box phi = phi)

But this DOES correctly model the S5 semantics if the valuation makes atoms depend only on the formula set, not on the history! The issue is that atoms then don't depend on the history at all, making the modal logic trivial.

**The real solution**: The canonical model for S5 modal logic typically uses a SINGLE world (since all worlds see all worlds, all modal formulas collapse). The temporal dimension is what gives structure. So:

- WorldState = Unit (S5 collapse)
- Valuation = time-dependent (via the history assignment)
- truth_at depends on the time, not the world state

Wait, looking at the actual definition:
```lean
| Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
```

The atom truth depends on `tau.states t ht`, which is a WorldState. If WorldState = Unit, then `M.valuation () p` is a constant - it doesn't depend on time or history. This would make ALL atoms have the same truth value everywhere, which can't model non-trivial formulas.

**Conclusion**: WorldState CANNOT be Unit. It must be rich enough to distinguish different atom assignments. The canonical construction needs MCS-based world states.

**Final recommended approach for box**: Accept that the trivial task_rel allows uncountably many WorldHistories, and handle the box case by proving that if `box phi ∈ MCS` then `phi` is in every consistent set (hence phi is a theorem, hence by soundness phi is true everywhere). This is the soundness-roundtrip approach.

Actually, re-reading the S5 axioms more carefully:
- Modal T: `box phi -> phi` (every MCS containing box phi also contains phi)
- Modal 4: `box phi -> box(box phi)` (positive introspection)
- Modal B: `phi -> box(diamond phi)` (if phi then necessarily possibly phi)
- Modal 5 collapse: `diamond(box phi) -> box phi`

From these we get: `box phi -> box(box phi)` (4) and `phi -> box(diamond phi)` (B).

The key S5 property: `box phi` is equivalent to `phi being in all MCS`. Proof:
- If `box phi ∈ M` for some MCS M, then for ALL MCS M', `phi ∈ M'`.
  - Suppose not: some MCS M' has `phi ∉ M'`, so `phi.neg ∈ M'`.
  - Then `diamond(phi.neg) ∈ M'` (by Modal B applied to phi.neg: `phi.neg -> box(diamond(phi.neg))`, then Modal T: `box(...) -> ...`). Actually this doesn't directly work.

Let me think again. The semantic interpretation: `box phi` means phi is true at ALL histories at time t. In the canonical model, each MCS determines a history. So `box phi ∈ M` means "in M, phi holds at all histories", which by the truth lemma means "phi is in every MCS at time t".

For the standard semantics bridge, we need: if phi is in every MCS (at a given time), then phi is true at every WorldHistory in the canonical model. Since every WorldHistory's state at time t is SOME MCS (in our construction), and phi is in every MCS, phi is true at every WorldHistory.

**This works if every WorldHistory's state corresponds to an MCS!** With our construction:
- WorldState = CanonicalWorldState = {S : Set Formula // SetMaximalConsistent S}
- Any WorldHistory assigns MCS to times
- If phi is in ALL MCS (elements of WorldState), then phi is in the MCS assigned by any history at any time
- So `truth_at M sigma t phi` holds for any sigma

The challenge: the truth_at definition for atoms requires `exists (ht : sigma.domain t), M.valuation (sigma.states t ht) p`. This works if t is in sigma's domain. If t is NOT in sigma's domain, the atom is false. But we need phi (which may contain atoms) to be true at sigma even if t is outside sigma's domain.

**Resolution**: Ensure all canonical WorldHistories have universal domain (domain = fun _ => True). With trivial task_rel and universal domain, this is achievable.

## Summary of Recommended Approach

1. **Construct canonical TaskFrame** with WorldState = CanonicalWorldState, trivial task_rel
2. **Construct canonical TaskModel** with valuation from MCS membership
3. **Construct canonical WorldHistories** from BMCS families with universal domain
4. **Prove canonical truth lemma**: `phi ∈ fam.mcs t <-> truth_at M_B tau_fam t phi`
   - Atom: by construction of valuation and universal domain
   - Bot: trivial
   - Imp: by MCS negation completeness
   - Box: by S5 property (phi in all MCS <-> phi in all WorldHistories because WorldState = CanonicalWorldState and all histories assign MCS to times)
   - G/H: by temporal coherence of BMCS families (forward_G, backward_H)
5. **Combine**: BMCS representation + truth bridge = standard representation = standard completeness

**Key advantage of this approach**: The box case works because WorldState IS CanonicalWorldState, so every WorldHistory's states are MCS, and phi being in all MCS means phi holds at every WorldHistory's state.

**Main concern**: For the G/H temporal cases, the canonical truth lemma requires induction. The `truth_at` definition has `all_future phi = forall s >= t, truth_at M tau s phi`. We need: `all_future phi ∈ fam.mcs t <-> forall s >= t, truth_at M tau_fam s phi`. The forward direction uses forward_G (from IndexedMCSFamily). The backward direction needs: if phi is true at all future times in the CANONICAL history, then `all_future phi ∈ fam.mcs t`. This is the temporal backward direction, which currently has sorries in the BMCS approach. However, with standard truth_at and the canonical history, this becomes a purely syntactic argument using the temporal T axiom and MCS closure.

## References

- `Theories/Bimodal/Semantics/Truth.lean` - Standard truth_at definition
- `Theories/Bimodal/Semantics/Validity.lean` - Standard validity/satisfiability
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - BMCS completeness (sorry-free)
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - FMP completeness (sorry-free)
- `Theories/Bimodal/Metalogic/Soundness.lean` - Standard soundness (sorry-free)
- `Theories/Bimodal/Boneyard/DeprecatedCompleteness.lean` - Lessons from failed approaches
- `Theories/Bimodal/Boneyard/Metalogic_v5/` - Most recent archived approach (30+ sorries)
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - Current construction challenges

## Next Steps

1. Formalize the canonical TaskFrame + TaskModel + WorldHistory construction
2. Prove the box case of the canonical truth lemma using the CanonicalWorldState argument
3. Verify the temporal cases work with the standard truth_at definition
4. Assemble the standard completeness theorem by combining BMCS representation + bridge
