# Research Report: Task #903 - Teammate A Findings

**Task**: Restructure completeness proof for Bimodal task semantics
**Date**: 2026-02-19
**Focus**: Evaluate current representation theorem structure vs. correct completeness pattern

## Summary

The current completeness proof uses a "BMCS" (Bundle of Maximal Consistent Sets) approach that defines its OWN semantic evaluation (`bmcs_truth_at`) rather than reusing the standard semantic definitions in `Theories/Bimodal/Semantics/`. This means the representation theorem proves satisfiability in a BMCS-specific sense, not in terms of the actual `TaskFrame`, `TaskModel`, `WorldHistory`, and `truth_at` definitions that constitute the project's formal semantics. The proof never constructs a TaskFrame, never constructs a TaskModel, never constructs a WorldHistory, and never evaluates the formula using `truth_at`. This is a fundamental structural divergence from the correct completeness pattern.

## Findings

### 1. The Correct Completeness Pattern for Bimodal Task Semantics

The correct completeness proof for bimodal task semantics should follow this form:

**Given**: A consistent sentence phi (i.e., `ContextConsistent [phi]`)

**Construct**:
1. A **TaskFrame** `F : TaskFrame D` -- a purely syntactic frame with world states, task relation, nullity, and compositionality
2. A **TaskModel** `M : TaskModel F` -- a valuation function over the frame's world states
3. A **WorldHistory** `tau : WorldHistory F` -- a function from a convex time domain to world states, respecting the task relation
4. A **time** `t : D` -- a specific evaluation point

**Prove**: `truth_at M tau t phi` -- the formula is true when evaluated in the standard semantic sense

This pattern mirrors standard modal logic completeness, but with the additional requirement that the model includes a world history and time (rather than just a world).

The key semantic definitions that MUST be reused are:
- `TaskFrame` (Semantics/TaskFrame.lean): `WorldState`, `task_rel`, nullity, compositionality
- `TaskModel` (Semantics/TaskModel.lean): `valuation : F.WorldState -> String -> Prop`
- `WorldHistory` (Semantics/WorldHistory.lean): `domain`, `convex`, `states`, `respects_task`
- `truth_at` (Semantics/Truth.lean): The recursive truth evaluation
- `satisfiable` (Semantics/Validity.lean): `exists (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D), forall phi in Gamma, truth_at M tau t phi`

### 2. Current Proof Structure (What Exists Now)

The current proof is organized as follows:

**Core type: `BMCS D`** (Bundle/BMCS.lean)
- A set of `IndexedMCSFamily D` objects (each maps time `D -> Set Formula`)
- Modal coherence conditions (`modal_forward`, `modal_backward`)
- A distinguished `eval_family`

**Truth evaluation: `bmcs_truth_at`** (Bundle/BMCSTruth.lean)
- A CUSTOM recursive truth definition on `Formula`
- `atom p` is true iff `Formula.atom p in fam.mcs t` (MCS membership, NOT valuation on world states)
- `box phi` is true iff `phi` is true at ALL families in the bundle (NOT over all world histories)
- `all_past phi` / `all_future phi` quantify over all times `s <= t` / `s >= t`

**Truth Lemma: `bmcs_truth_lemma`** (Bundle/TruthLemma.lean)
- `phi in fam.mcs t <-> bmcs_truth_at B fam t phi`
- This is the key result, and it is sorry-free for temporally coherent BMCS

**Representation Theorem: `bmcs_representation`** (Bundle/Completeness.lean)
- Statement: `ContextConsistent [phi] -> exists (B : BMCS Int), bmcs_truth_at B B.eval_family 0 phi`
- This shows satisfiability in BMCS, NOT in standard semantics

**Weak Completeness: `bmcs_weak_completeness`** (Bundle/Completeness.lean)
- Statement: `bmcs_valid phi -> Nonempty (DerivationTree [] phi)`
- Where `bmcs_valid` quantifies over all BMCS, NOT over all `TaskFrame`/`TaskModel`/`WorldHistory`

**Strong Completeness: `bmcs_strong_completeness`** (Bundle/Completeness.lean)
- Statement: `bmcs_consequence Gamma phi -> ContextDerivable Gamma phi`
- Where `bmcs_consequence` uses `bmcs_truth_at`, NOT `truth_at`

**Construction chain**:
1. `construct_saturated_bmcs_int` gets a BMCS from `fully_saturated_bmcs_exists_int` (sorry-backed)
2. The BMCS contains the context at `eval_family.mcs 0`
3. The truth lemma converts MCS membership to `bmcs_truth_at` truth

### 3. Divergences Identified

#### Divergence 1: No TaskFrame is constructed

The current proof never builds a `TaskFrame D` with:
- `WorldState : Type`
- `task_rel : WorldState -> D -> WorldState -> Prop`
- `nullity : forall w, task_rel w 0 w`
- `compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v`

Instead, it uses `IndexedMCSFamily` which maps time to MCS (sets of formulas). There is no concrete notion of "world state" as a semantic entity.

#### Divergence 2: No TaskModel is constructed

The current proof never builds a `TaskModel F` with:
- `valuation : F.WorldState -> String -> Prop`

Instead, atom truth is defined as `Formula.atom p in fam.mcs t` -- membership of a syntactic object in a set of formulas, not evaluation of an atom at a world state.

#### Divergence 3: No WorldHistory is constructed

The current proof never builds a `WorldHistory F` with:
- `domain : D -> Prop` (convex)
- `states : (t : D) -> domain t -> F.WorldState`
- `respects_task` constraint

Instead, the `IndexedMCSFamily` plays the role of a "history" but it maps time to MCS (formula sets), not time to world states. There is no domain, no convexity, and no task relation respect.

#### Divergence 4: Custom truth evaluation instead of `truth_at`

`bmcs_truth_at` is a SEPARATE definition from `truth_at` in `Semantics/Truth.lean`. The key differences:

| Aspect | `truth_at` (Semantics) | `bmcs_truth_at` (Bundle) |
|--------|----------------------|------------------------|
| Atom | `exists (ht : tau.domain t), M.valuation (tau.states t ht) p` | `Formula.atom p in fam.mcs t` |
| Box | `forall (sigma : WorldHistory F), truth_at M sigma t phi` | `forall fam' in B.families, bmcs_truth_at B fam' t phi` |
| Past/Future | Quantify over D with time shift | Quantify over D directly |

The `truth_at` definition checks domain membership and evaluates valuation at world states. The `bmcs_truth_at` definition checks formula membership in MCS. These are fundamentally different operations.

#### Divergence 5: Completeness is w.r.t. BMCS validity, not standard validity

The standard completeness theorem should state:
```
valid phi -> Derivable [] phi
```
where `valid` quantifies over all TaskFrames, TaskModels, WorldHistories, and times.

The current theorem states:
```
bmcs_valid phi -> Derivable [] phi
```
where `bmcs_valid` quantifies over all BMCS bundles and their families.

The comment in the code claims this is equivalent (the "Henkin semantics" argument), but this equivalence is NOT proven. There is no bridge theorem connecting `bmcs_valid` to `valid`.

#### Divergence 6: The "Henkin semantics" justification is a meta-argument, not a formal proof

The codebase contains extensive comments arguing that the BMCS approach gives "full completeness" analogous to Henkin semantics. However:

- No theorem connects `bmcs_valid` to `valid` (standard validity)
- No theorem connects `bmcs_truth_at` to `truth_at` (standard truth)
- No construction shows how a BMCS can be converted to a TaskFrame + TaskModel + WorldHistory
- The claimed equivalence is informal justification, not formal verification

#### Divergence 7: Remaining sorry/axiom debt

Even within the BMCS framework, there is significant proof debt:
- `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean): sorry-backed theorem asserting the existence of a fully saturated temporally coherent BMCS
- `singleFamily_modal_backward_axiom` (Construction.lean): Explicitly marked as FALSE and deprecated
- `fully_saturated_bmcs_exists` (TemporalCoherentConstruction.lean): deprecated axiom
- Multiple sorries in DovetailingChain.lean, FinalConstruction.lean, etc.

### 4. What a Restructured Proof Would Require

To follow the correct completeness pattern, the proof must:

**Phase A: Canonical TaskFrame Construction**
- Define `WorldState` as (some representation of) maximal consistent sets or a quotient thereof
- Define `task_rel w d u` using temporal/modal content of MCS
- Prove nullity (`task_rel w 0 w`)
- Prove compositionality

**Phase B: Canonical TaskModel Construction**
- Define `valuation w p` based on atom membership in the MCS corresponding to world state `w`

**Phase C: Canonical WorldHistory Construction**
- Define `domain` (likely all of D, or a convex subset)
- Define `states t` mapping each time to the world state from the canonical frame
- Prove convexity of domain
- Prove `respects_task` constraint

**Phase D: Truth Lemma in Standard Semantics**
- Prove: `phi in MCS(t) <-> truth_at M tau t phi`
- This uses the STANDARD `truth_at` definition, not `bmcs_truth_at`

**Phase E: Representation Theorem in Standard Semantics**
- Prove: `ContextConsistent [phi] -> satisfiable Int [phi]`
- Where `satisfiable` is the standard definition from Validity.lean

### 5. Files to Move to Boneyard

Files that define structures going in the wrong direction (parallel semantics rather than reusing standard definitions):

| File | Reason for Boneyard |
|------|-------------------|
| `Bundle/BMCSTruth.lean` | Defines `bmcs_truth_at` which is a parallel truth evaluation, not standard `truth_at` |
| `Bundle/Completeness.lean` | Completeness theorems stated w.r.t. `bmcs_valid`/`bmcs_consequence`, not standard validity |
| `Bundle/CoherentConstruction.lean` | EvalBMCS structure, not needed in standard approach |
| `Bundle/FinalConstruction.lean` | FinalConstruction for BMCS saturation |
| `Bundle/SaturatedConstruction.lean` | FamilyCollection/saturation infrastructure for BMCS |

Files that contain REUSABLE infrastructure (should be kept or adapted):

| File | Reusable Content |
|------|-----------------|
| `Bundle/BMCS.lean` | The `BMCS` structure and modal coherence properties (may need adaptation) |
| `Bundle/IndexedMCSFamily.lean` | `IndexedMCSFamily` structure -- could be the basis for world state indexing |
| `Bundle/TruthLemma.lean` | The truth lemma proof TECHNIQUE is correct, only the target evaluation needs changing |
| `Bundle/TemporalCoherentConstruction.lean` | Temporal backward properties, TemporalCoherentFamily, temporal duality infrastructure |
| `Bundle/Construction.lean` | Lindenbaum MCS construction, constant family construction |
| `Bundle/ModalSaturation.lean` | Modal saturation infrastructure |
| `Bundle/DovetailingChain.lean` | DovetailingChain construction for temporal families |
| `Bundle/TemporalContent.lean` | GContent/HContent definitions |
| `Bundle/TemporalLindenbaum.lean` | Temporal-aware Lindenbaum construction |

Files in `Metalogic/Completeness.lean` (top-level) that contain MCS properties are likely reusable.

### 6. Key Design Decision: How to Bridge the Gap

There are two strategies for restructuring:

**Strategy A: Build standard canonical model from scratch**
- Construct TaskFrame directly from MCS theory
- Construct TaskModel directly from MCS valuation
- Construct WorldHistory directly from IndexedMCSFamily
- Prove truth lemma against `truth_at`
- This is the "correct" approach but requires significant new infrastructure

**Strategy B: Build a bridge from BMCS to standard semantics**
- Keep the existing BMCS completeness proof as-is
- Construct a TaskFrame + TaskModel + WorldHistory from a BMCS
- Prove: `bmcs_truth_at B fam t phi -> truth_at M tau t phi` (and vice versa)
- Derive standard completeness from BMCS completeness
- This is more incremental but risks maintaining two parallel frameworks

**Strategy C (Recommended): Hybrid approach**
- Use the existing `IndexedMCSFamily` as the foundation for defining `WorldState` and `task_rel`
- Each `IndexedMCSFamily` maps time -> MCS. Define `WorldState = Set Formula` (MCS), and `task_rel w d u` based on temporal content relationships.
- The `IndexedMCSFamily` essentially provides a canonical world history structure.
- Then overlay `TaskModel` valuation using atom membership.
- Construct `WorldHistory` with full domain and states from the family.
- This reuses maximum existing infrastructure while targeting standard definitions.

## Recommendations

1. **Move `bmcs_truth_at`, `bmcs_valid`, `bmcs_consequence`, and the BMCS completeness theorems to Boneyard.** These define a parallel semantics that does not connect to the standard definitions.

2. **Keep the core MCS infrastructure** (IndexedMCSFamily, TemporalCoherentFamily, temporal backward properties, Lindenbaum lemma, MCS properties). These are logically necessary for any canonical model construction.

3. **Define a canonical TaskFrame** where `WorldState` is the type of MCS (or a suitable representation), and `task_rel` is defined using the temporal structure of MCS content.

4. **Define a canonical TaskModel** where `valuation w p = (Formula.atom p in w)` for MCS `w`.

5. **Construct a WorldHistory from an IndexedMCSFamily** by extracting the MCS at each time to a world state, with appropriate domain and convexity proofs.

6. **Reprove the truth lemma** against `truth_at` from `Semantics/Truth.lean`, not against `bmcs_truth_at`. The proof structure will be very similar to the existing one; only the target changes.

7. **State the representation theorem** as: `ContextConsistent [phi] -> exists (F : TaskFrame Int) (M : TaskModel F) (tau : WorldHistory F) (t : Int), truth_at M tau t phi`. This directly satisfies `satisfiable Int [phi]` from Validity.lean.

## Key Files and Definitions

### Standard Semantic Definitions (must be reused)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean`: `TaskFrame D` structure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskModel.lean`: `TaskModel F` structure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean`: `WorldHistory F` structure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`: `truth_at M tau t phi` definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`: `valid`, `satisfiable`, `semantic_consequence`

### Current BMCS Completeness (to be restructured)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BMCS.lean`: BMCS structure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`: `bmcs_truth_at` (parallel truth)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`: `bmcs_truth_lemma`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Completeness.lean`: `bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Construction.lean`: BMCS construction from context
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`: Temporal coherence, axioms/sorries

### Reusable MCS Infrastructure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean`: Time-indexed MCS families
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean`: Lindenbaum, MCS definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MCSProperties.lean`: MCS closure, negation completeness
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean`: Deduction theorem
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`: MCS properties (box closure, diamond duality, CanonicalWorldState)

### Box Case Challenge

The box case is the most challenging part. In standard semantics, `truth_at M tau t (box phi) = forall (sigma : WorldHistory F), truth_at M sigma t phi` -- this quantifies over ALL world histories. In the BMCS approach, it quantifies only over families in the bundle.

For the standard canonical model, the key insight is:
- The canonical frame must have enough world histories to represent all MCS families
- The task relation must be defined so that the world histories correspond to the indexed MCS families
- Modal saturation (every diamond formula has a witness family) ensures the backward direction of the truth lemma for box

This is the primary technical challenge in the restructuring.

## Confidence Level

**High confidence** in the analysis of divergences and the identification of what needs to change. The current proof structure clearly uses parallel semantics (`bmcs_truth_at`) rather than the standard definitions (`truth_at`).

**Medium confidence** in the specific restructuring strategy. The canonical frame/model/history construction is mathematically well-understood, but the formalization details (especially for the box case and task relation definition) will require careful engineering.

**Low confidence** in effort estimation. The restructuring is a significant undertaking that touches most files in the Bundle/ directory and requires new constructions. It likely represents multiple implementation phases.
