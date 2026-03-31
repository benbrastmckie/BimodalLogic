# Teammate B Research Findings

## Summary

Task Semantics is fundamentally different from standard Kripke semantics due to its **ternary task relation** with algebraic duration structure. This enables expressing metric temporal properties and compositional reasoning that standard accessibility relations cannot capture. TM logic is complete with respect to **TaskFrames over totally ordered abelian groups** satisfying nullity_identity, forward_comp, and converse axioms. The group structure provides powerful algebraic tools for completeness proofs via time-shift preservation.

## Task Semantics vs Kripke Semantics

### What's Distinctive

Task Semantics cannot be reduced to standard Kripke frames without losing essential structure:

1. **Ternary vs Binary Relation**: Standard Kripke frames use binary accessibility `R: W -> W -> Prop`. Task frames use ternary `task_rel: W -> D -> W -> Prop` where D is the duration domain. This extra parameter carries metric information.

2. **Algebraic Duration Structure**: The duration parameter D forms a **totally ordered abelian group** `(D, +, 0, -, <=)`. This is NOT just a label -- it enables:
   - **Compositionality**: `task_rel w x u /\ task_rel u y v -> task_rel w (x+y) v` (for appropriate signs)
   - **Converse/Symmetry**: `task_rel w d u <-> task_rel u (-d) w`
   - **Nullity Identity**: `task_rel w 0 u <-> w = u` (stronger than reflexivity)

3. **World Histories as Functions**: A world history `tau: domain -> W` is a partial function from time to world states, subject to:
   - **Convexity**: The domain must be a convex subset of D (no temporal gaps)
   - **Task Respect**: `tau` must respect the task relation: for s <= t in domain, `task_rel (tau s) (t-s) (tau t)`

4. **Two Distinct Modal Dimensions**:
   - Box quantifies over **all histories at fixed time**: `Box phi` at (tau, t) means phi holds for all sigma at t
   - G/H quantify over **times in same history**: `G phi` at (tau, t) means phi holds at all s >= t in tau

### Expressive Power

Task Semantics can express properties that standard Kripke cannot:

1. **Metric Temporal Properties**: The duration group D enables expressing:
   - "After duration d, property phi holds" (not just "eventually phi")
   - Duration composition: sequential tasks add durations algebraically
   - Duration inversion: converse axiom enables backward temporal reasoning

2. **Perpetuity Principles**: The interaction axioms MF and TF capture deep modal-temporal interaction:
   - MF: `Box phi -> Box G phi` (necessary truths are necessary at all future times)
   - TF: `Box phi -> G Box phi` (necessary truths will always be necessary)
   These express that necessity is temporally stable -- cannot be stated in standard product logics.

3. **Shift-Closure**: The `ShiftClosed` property on history sets enables proving that truth is preserved under time-translation. This is a fundamentally algebraic property exploiting the group structure.

4. **Domain-Dependent Truth**: Atoms can be undefined (false) at times outside a history's domain. This models finite processes (games ending, tasks completing) naturally.

## TM Characterization

### Semantic Class

**TM logic is complete with respect to TaskFrame structures** where:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

The key frame properties are:
- **Nullity Identity**: Zero duration means identity (not just reflexivity)
- **Forward Compositionality**: Tasks compose additively (restricted to non-negative durations)
- **Converse**: Temporal symmetry under duration negation

### Representation Theorem

**Statement**: For any totally ordered abelian group D, if phi is valid on all TaskFrames over D, then phi is derivable in TM.

**Proof Sketch** (from `ParametricRepresentation.lean`):

1. Suppose phi is NOT derivable
2. Then {phi.neg} is consistent (deduction theorem + DNE)
3. Extend {phi.neg} to an MCS M_0 via Lindenbaum's lemma
4. Construct a BFMCS (Bundle of Families of MCS) B with M_0 at time 0
5. Build the canonical TaskFrame over D:
   - WorldState = CanonicalMCS (maximal consistent sets)
   - task_rel derived from MCS temporal coherence
6. By the **Truth Lemma**: `phi in fam.mcs t <-> truth_at CanonicalModel Omega (to_history fam) t phi`
7. Since phi.neg in M_0, we have phi false at the canonical model
8. Contrapositive: if phi is valid, then phi is derivable

**Key Innovation**: The construction is **D-parametric** -- it works for ANY totally ordered abelian group D. This avoids the "domain mismatch" problem where syntax forces a specific duration type.

## Stronger Systems

### Extensions with Clean Characterizations

**1. Dense TM Logic** (adding density axiom DN: `GG phi -> G phi`):

- **Frame Class**: TaskFrames where D is DenselyOrdered (for all x < y, exists z with x < z < y)
- **Characterization**: Via Cantor's theorem, the canonical timeline is order-isomorphic to Q (rationals)
- **Completeness**: D = Rat instantiation with DenselyOrdered constraint

**2. Discrete TM Logic** (adding discreteness DF and seriality SF/SP):

- **Frame Class**: TaskFrames where D has SuccOrder (immediate successors/predecessors) and NoMaxOrder/NoMinOrder
- **Characterization**: The canonical timeline is Z (integers) or isomorphic
- **Completeness**: D = Int instantiation with discrete constraints

**3. Reflexive Semantics** (current implementation):

The project uses **reflexive** G and H operators:
- `G phi` at t means phi at all s >= t (including now)
- `H phi` at t means phi at all s <= t (including now)

This makes T-axioms (`G phi -> phi`, `H phi -> phi`) valid and simplifies completeness by eliminating irreflexivity concerns in the canonical model.

### Relationships

```
Base TM  <--  Dense TM
           \
            -->  Discrete TM
```

- Base TM axioms are valid on ALL TaskFrames (any D satisfying group+order)
- Dense TM requires DenselyOrdered D; sound on dense frames, complete via Rat
- Discrete TM requires SuccOrder D; sound on discrete frames, complete via Int
- Dense and Discrete are INCOMPATIBLE: no frame is both dense and has immediate successors

## Algebraic Advantages

### Exploiting Group Structure

The ordered abelian group D provides powerful tools for completeness:

**1. Time-Shift Preservation Theorem** (`time_shift_preserves_truth`):

```lean
theorem time_shift_preserves_truth (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (sigma : WorldHistory F) (x y : D) (phi : Formula) :
    truth_at M Omega (WorldHistory.time_shift sigma (y - x)) x phi <-> truth_at M Omega sigma y phi
```

This states that truth is invariant under time-shifting histories. The proof uses:
- The group operation `y - x` to compute shift amount
- `ShiftClosed Omega` to ensure shifted histories remain admissible
- Structural induction on formulas

**2. Algebraic Identity Laws**:

```lean
-- Double shift cancels
time_shift (time_shift sigma D) (-D) = sigma

-- Shift amount computation
s - (s - (y - x)) = y - x
```

These algebraic identities are essential for the inductive cases of truth preservation.

**3. STSA (Shift-Closed Tense S5 Algebra)**:

The Lindenbaum algebra forms an STSA with operators:
- Box: S5 interior operator (deflationary, monotone, idempotent, S5 collapse)
- G, H: Temporal universal operators
- sigma: Involution swapping G <-> H

This algebraic structure enables proving:
- MF and TF as algebraic inequalities
- Temporal linearity via algebraic encoding
- Completeness via Stone duality (ultrafilters = MCS)

**4. Backward Compositionality** (derived):

```lean
theorem backward_comp (F : TaskFrame D) (w u v : F.WorldState) (x y : D)
    (hx : x <= 0) (hy : y <= 0)
    (h1 : F.task_rel w x u) (h2 : F.task_rel u y v) :
    F.task_rel w (x + y) v
```

This is derived from forward_comp + converse, showing the algebraic structure yields theorems for free.

## Key Evidence

### Proof Sketches

**1. Nullity derived from nullity_identity**:
```lean
theorem nullity (F : TaskFrame D) (w : F.WorldState) : F.task_rel w 0 w :=
  F.nullity_identity w w |>.mpr rfl
```

**2. MF axiom validity** (semantic proof sketch):
- Assume `Box phi` at (tau, t)
- For any history sigma in Omega, phi holds at (sigma, t)
- For any s >= t in sigma, by ShiftClosed: time_shift sigma (s-t) in Omega
- By time-shift preservation: phi at (sigma, s) iff phi at (time_shift sigma (s-t), t)
- Since time_shift sigma (s-t) in Omega, phi holds at (time_shift sigma (s-t), t)
- Therefore phi at (sigma, s), i.e., G phi at (sigma, t)
- Since this holds for all sigma in Omega, Box G phi at (tau, t)

**3. Parametric Completeness** (actual code):
```lean
theorem parametric_algebraic_representation_relative
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (phi : Formula) (h_not_prov : not Nonempty (DerivationTree [] phi))
    (fam : FMCS D) (hfam : fam in B.families)
    (t : D) (h_neg_in : phi.neg in fam.mcs t) :
    not truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t phi
```

### References from Codebase

Key files establishing these results:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean` (TaskFrame definition)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` (time_shift_preserves_truth)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` (21 axiom schemata)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` (D-parametric completeness)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` (STSA structure)

## Confidence Level

**High** with qualifications.

**High confidence**:
- Task Semantics is genuinely distinct from standard Kripke semantics
- The algebraic duration structure provides unique expressive power
- Completeness for TM over TaskFrames is proven in the codebase
- Time-shift preservation is a sound proof technique

**Medium confidence**:
- The precise relationship between TaskFrame validity and standard frame correspondence
- Whether there exists a translation from TaskFrames to some generalized Kripke structure that preserves all properties
- The exact boundary of what Task Semantics can express vs standard temporal/modal products

**Justification**: The codebase contains verified Lean proofs for the main claims. The algebraic structure is explicit and the D-parametric approach is well-documented. However, comparative analysis with other semantic frameworks requires additional literature review.
