# Research Report: Bimodal Semantics Analysis (Teammate C)

**Task**: 977 - Organize TM base logic with extensions
**Focus**: Bimodal Semantics specific to TM implementation
**Started**: 2026-03-16
**Completed**: 2026-03-16
**Effort**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (Theories/Bimodal/**/*.lean)
**Artifacts**: This report

## Executive Summary

The TM (Tense and Modality) logic implementation in this codebase uses a sophisticated bimodal structure combining:

1. **S5 Modal Logic** (metaphysical necessity Box/Diamond) with universal accessibility
2. **Linear Temporal Logic** with two independent temporal operators (G/H for future/past)

The canonical model construction uses a **Bundle of Maximal Consistent Sets (BFMCS)** approach with multiple FMCS families for modal coherence, combined with staged timeline construction for dense completeness.

---

## Bimodal Structure Analysis

### Two Modalities

The TM logic has **three** primitive operators with distinct semantic roles:

| Operator | Symbol | Semantic Interpretation |
|----------|--------|------------------------|
| Box (modal) | `[]` | S5 necessity: quantifies over all accessible histories |
| All-Future (temporal) | `G` | Universal future: quantifies over all times t' >= t |
| All-Past (temporal) | `H` | Universal past: quantifies over all times t' <= t |

### Formula Syntax (from `Syntax/Formula.lean`)

```lean
inductive Formula : Type where
  | atom : Atom -> Formula          -- Sentence letters
  | bot : Formula                   -- Bottom/falsum
  | imp : Formula -> Formula -> Formula  -- Implication
  | box : Formula -> Formula        -- Modal necessity (S5)
  | all_past : Formula -> Formula   -- H: "always in the past"
  | all_future : Formula -> Formula -- G: "always in the future"
```

**Derived operators**:
- `neg phi := phi.imp bot` (negation)
- `diamond phi := neg (box (neg phi))` (modal possibility)
- `some_future phi := neg (all_future (neg phi))` (F: eventually)
- `some_past phi := neg (all_past (neg phi))` (P: at some past time)
- `always phi := all_past phi AND phi AND all_future phi` (eternal truth)

### Interaction Between Modalities

The modal and temporal operators interact via two key axioms:

1. **MF (Modal-Future)**: `Box phi -> Box (G phi)` -- necessary truths remain necessary in the future
2. **TF (Temporal-Future)**: `Box phi -> G (Box phi)` -- necessary truths will always be necessary

These enable **box_persistent**: Box phi at time t implies Box phi at ALL times (proven via TF axiom and its temporal dual).

---

## Frame Definition Details

### TaskFrame Structure (from `Semantics/TaskFrame.lean`)

The semantic frame is a **TaskFrame** parameterized by a temporal duration type D:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y ->
    task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

**Key Properties**:
- **Nullity Identity**: Zero-duration task relates exactly identical states
- **Forward Compositionality**: Tasks compose for non-negative durations (via addition)
- **Converse**: Temporal symmetry under duration negation

### World Histories (from `Semantics/WorldHistory.lean`)

A world history is a trajectory through world states over time:

```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D -> Prop                         -- Which times are valid
  convex : ...                               -- No temporal gaps
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall s t hs ht,
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

**Critical Semantic Points**:
- The **modal Box** quantifies over ALL histories at a given time
- The **temporal G/H** quantify over times within the SAME history
- Domains must be convex (no gaps in time)

### Truth Evaluation (from `Semantics/Truth.lean`)

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega ->
      truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

**Semantics**:
- **Reflexive temporal semantics** (Task 967): G/H use `<=` not `<`, enabling T-axioms
- **Omega parameter**: Box quantifies over histories in Omega (for completeness proofs)
- Atoms outside domain are FALSE (explicit domain check)

---

## Canonical Model Construction Approach

### Overview

The completeness proof uses a **multi-layer canonical model construction**:

1. **MCS Layer**: Maximal Consistent Sets as the atomic building blocks
2. **FMCS Layer**: Time-indexed families of MCSes with temporal coherence
3. **BFMCS Layer**: Bundles of FMCS families with modal coherence
4. **Truth Lemma**: Connects MCS membership to semantic truth

### MCS (Maximal Consistent Sets)

Standard Lindenbaum construction:
- A set S is **consistent** if there is no derivation S |- bot
- A set M is **maximal consistent** if consistent and for all phi, either phi in M or neg(phi) in M
- Every consistent set extends to an MCS via Zorn's lemma / countable enumeration

### FMCS: Family of MCS (from `Bundle/FMCSDef.lean`)

An FMCS assigns an MCS to each time point with temporal coherence:

```lean
structure FMCS where
  mcs : D -> Set Formula           -- MCS at each time
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t < t' -> G phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' < t -> H phi in mcs t -> phi in mcs t'
```

### BFMCS: Bundle of FMCS (from `Bundle/BFMCS.lean`)

A BFMCS is a set of FMCS families with modal coherence conditions:

```lean
structure BFMCS where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : forall fam in families, forall phi t,
    Box phi in fam.mcs t -> forall fam' in families, phi in fam'.mcs t
  modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi in fam'.mcs t) -> Box phi in fam.mcs t
  eval_family : FMCS D
  eval_family_mem : eval_family in families
```

**Key Insight**: The bundle construction makes Box quantify over a FINITE/CONTROLLED set of families rather than all possible MCSes, making the truth lemma provable.

### Canonical Frame (from `Bundle/CanonicalFrame.lean`)

The canonical relations connect MCSes:

```lean
def CanonicalR (M M' : Set Formula) : Prop := g_content M subseteq M'
def CanonicalR_past (M M' : Set Formula) : Prop := h_content M subseteq M'
```

Where:
- `g_content M = { phi | G phi in M }` (future content)
- `h_content M = { phi | H phi in M }` (past content)

**Critical Properties**:
- `canonical_forward_F`: F(psi) in M implies exists MCS W with CanonicalR M W and psi in W
- `canonical_backward_P`: P(psi) in M implies exists MCS W with CanonicalR_past M W and psi in W
- These use **Lindenbaum witness construction** (WitnessSeed.lean)

### TemporalCoherentFamily (from `Bundle/TemporalCoherence.lean`)

Extends FMCS with existential witness properties:

```lean
structure TemporalCoherentFamily extends FMCS D where
  forward_F : forall t phi, F phi in mcs t -> exists s > t, phi in mcs s
  backward_P : forall t phi, P phi in mcs t -> exists s < t, phi in mcs s
```

---

## Soundness and Completeness Architecture

### Soundness (from `Metalogic/Soundness.lean`)

**Approach**: Direct semantic validation of each axiom.

All 17+ axiom schemata are proven valid:
- Propositional: K, S, EFQ, Peirce
- Modal S5: MT (T), M4 (4), MB (B), M5-collapse, MK-dist
- Temporal: TK-dist, T4, TT-future, TT-past, TA, TL
- Modal-Temporal: MF, TF
- Frame extensions: density, discreteness, seriality, linearity

**Key techniques**:
- Time-shift invariance (for MF, TF): Uses `WorldHistory.time_shift` and `time_shift_preserves_truth`
- ShiftClosed Omega parameter for valid interaction

### Completeness (from `Metalogic/Bundle/CanonicalConstruction.lean`)

**Approach**: Henkin-style canonical model with BFMCS.

#### Truth Lemma (The Key Result)

```lean
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

**Proof by structural induction on phi**:

1. **Atom**: Valuation = MCS membership (definitional)
2. **Bot**: bot in MCS contradicts consistency
3. **Imp**: MCS closed under modus ponens + negation completeness
4. **Box**: Modal coherence conditions (modal_forward/modal_backward) enable quantification over bundle families
5. **G/H**: Temporal coherence (forward_G/backward_H) + backward lemmas via contraposition

#### Shifted Truth Lemma

For shift-closed Omega (needed for validity connection):

```lean
theorem shifted_truth_lemma (B : BFMCS Int)
    (h_tc : B.temporally_coherent) (phi : Formula)
    (fam : FMCS Int) (hfam : fam in B.families) (t : Int) :
    phi in fam.mcs t <->
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t phi
```

Uses **box_persistent** (Box phi persists to all times via TF + temporal dual).

### Staged Construction for Dense Completeness (from `StagedConstruction/`)

For dense temporal orders (like rationals):

1. **TimelineQuot**: Quotient construction for canonical times
2. **Cantor Isomorphism**: `TimelineQuot ≃o Rat` via Cantor's theorem for countable dense linear orders
3. **Components**: All proven sorry-free, but final wiring theorem requires additional infrastructure

---

## Key Technical Challenges

### Challenge 1: Modal-Temporal Interaction

The interaction between Box and G/H operators requires careful axiomatization. The TF axiom (`Box phi -> G (Box phi)`) is crucial for `box_persistent`, which in turn enables the shifted truth lemma.

### Challenge 2: Reflexive vs Irreflexive Temporal Semantics

**Task 967** switched to reflexive semantics (G/H use `<=` instead of `<`):
- Enables T-axioms: `G phi -> phi` and `H phi -> phi`
- Required for Gabbay IRR proof
- Changes temporal coherence conditions to use strict inequality in forward_F/backward_P

### Challenge 3: Multi-Family Bundle Construction

The single-family approach was documented as a **dead end** in ROAD_MAP.md:
- "Single-Family BFMCS modal_backward" blocked because multi-family bundles are essential for modal completeness without T-axiom obstruction

### Challenge 4: Task Relation Compositionality

**Task 966/969** resolved issues with the task relation axiomatization:
- Forward-only compositionality (for non-negative durations) + converse axiom
- Avoids "algebraically impossible" mixed-sign compositionality
- Zero duration = identity (nullity_identity), not universal True

### Challenge 5: Domain Mismatch in Dense Completeness

The BFMCS uses `D = CanonicalMCS` while the dense TaskFrame uses `D = TimelineQuot`:
- Components proven separately
- Final wiring theorem requires transfer between domains
- Documented as Phase 10 limitation

---

## Summary of Codebase Structure

### Core Semantic Files

| File | Content |
|------|---------|
| `Syntax/Formula.lean` | Formula inductive type, derived operators |
| `Semantics/TaskFrame.lean` | Frame structure with task relation |
| `Semantics/WorldHistory.lean` | History structure with convexity |
| `Semantics/Truth.lean` | Truth evaluation, time-shift preservation |
| `Semantics/Validity.lean` | Validity definitions (dense/discrete) |
| `ProofSystem/Axioms.lean` | 17+ axiom schemata |
| `ProofSystem/Derivation.lean` | Derivation tree structure |

### Canonical Model Files

| File | Content |
|------|---------|
| `Bundle/FMCSDef.lean` | FMCS structure |
| `Bundle/BFMCS.lean` | Bundle structure with modal coherence |
| `Bundle/CanonicalFrame.lean` | CanonicalR relations, F/P witnesses |
| `Bundle/TemporalCoherence.lean` | TemporalCoherentFamily, backward lemmas |
| `Bundle/CanonicalConstruction.lean` | Truth lemma, shifted truth lemma |
| `Bundle/WitnessSeed.lean` | Lindenbaum witness seed consistency |
| `Bundle/CanonicalFMCS.lean` | FMCS construction from MCS |

### Metalogic Files

| File | Content |
|------|---------|
| `Metalogic/Soundness.lean` | Axiom validity proofs |
| `Metalogic/SoundnessLemmas.lean` | Helper lemmas, temporal duality |
| `StagedConstruction/Completeness.lean` | Dense completeness components |
| `StagedConstruction/CantorApplication.lean` | Cantor isomorphism |

---

## Recommendations for Task 977

Based on this analysis, the TM base logic organization should consider:

1. **Core Logic Layer**: Formula syntax, TaskFrame, WorldHistory, Truth - these are tightly coupled and form the semantic foundation

2. **Proof System Layer**: Axioms, Derivation - defines provability independent of semantics

3. **Metalogic Layer**: Soundness, Completeness infrastructure - connects proof system to semantics

4. **Extensions**:
   - Density extension: adds density axiom, DenselyOrdered constraint
   - Discreteness extension: adds discreteness_forward axiom, SuccOrder/PredOrder
   - Seriality extension: adds NoMaxOrder/NoMinOrder

The `Axiom.isBase`, `Axiom.isDenseCompatible`, `Axiom.isDiscreteCompatible` predicates already encode this layering in the codebase.
