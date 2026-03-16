# Research Report: Theoretical Foundations of Tense Logic Axiom-Frame Correspondences

**Task**: 977 - Organize TM Base Logic with Extensions
**Teammate**: B (Theoretical Foundations)
**Started**: 2026-03-16
**Completed**: 2026-03-16
**Focus**: Standard tense logic axioms, axiom-frame correspondences, minimal base logic identification

## Executive Summary

- The minimal tense logic **Kt** consists of K-distribution axioms for G/H plus interaction axioms (GP, HF), with NO frame conditions
- Standard axiom-frame correspondences are well-established (T-reflexivity, 4-transitivity, D-seriality, etc.)
- The ProofChecker TM system currently mixes base logic with extensions (density, discreteness, seriality)
- Key finding: TT-F (Gφ -> φ) and TT-P (Hφ -> φ) are extension axioms corresponding to reflexive frames, NOT base Kt axioms
- Recommendation: Refactor axiom system to clearly separate Kt base from temporal extensions

---

## Standard Kt Base Axioms (No Frame Condition)

The minimal tense logic **Kt** (also called K1 or K_t) is sound and complete with respect to the class of ALL frames. Its axioms have no frame correspondence because they are valid on every possible temporal frame.

### Kt Base Axiom Set

| Axiom | Formula | Description |
|-------|---------|-------------|
| **KG** | `G(φ -> ψ) -> (Gφ -> Gψ)` | K-distribution for future operator |
| **KH** | `H(φ -> ψ) -> (Hφ -> Hψ)` | K-distribution for past operator |
| **GP** | `φ -> GPφ` | Present was in the past of the future |
| **HF** | `φ -> HFφ` | Present will be in the future of the past |

### Kt Inference Rules

| Rule | Description |
|------|-------------|
| **MP** | Modus Ponens: from φ and φ -> ψ, derive ψ |
| **NEC_G** | Future Necessitation: from ⊢ φ, derive ⊢ Gφ |
| **NEC_H** | Past Necessitation: from ⊢ φ, derive ⊢ Hφ |

### Why These Have No Frame Condition

The K-distribution axioms (KG, KH) are the fundamental axioms of normal modal/temporal logics. They are valid on ALL frames because:
- If (φ -> ψ) holds at all R-accessible points, and φ holds at all R-accessible points, then ψ must hold at all R-accessible points

The interaction axioms (GP, HF) capture the converse relationship between G/H and P/F:
- GP: If φ holds now, then at all future times s, φ held at some past time (namely, now)
- HF: If φ holds now, then at all past times s, φ will hold at some future time (namely, now)

These are valid on ALL frames due to the converse relationship between < and >.

**Key Insight**: The theorems of Kt are precisely those formulae that are true at all times under all interpretations over all temporal frames.

---

## Axiom-Frame Correspondence Table

The following table shows the standard correspondences between tense logic axioms and frame properties:

### Temporal Axioms

| Axiom | Formula | Frame Property | First-Order Condition |
|-------|---------|----------------|----------------------|
| **REF** (T-Future) | `Gφ -> φ` | Reflexivity | ∀t. t <= t |
| **REF** (T-Past) | `Hφ -> φ` | Reflexivity | ∀t. t <= t |
| **TRAN** (4) | `Gφ -> GGφ` | Transitivity | ∀s,t,u. (s < t ∧ t < u) -> s < u |
| **DENSE** | `GGφ -> Gφ` | Density | ∀s,t. s < t -> ∃u. (s < u ∧ u < t) |
| **DISCR-F** | `(F⊤ ∧ φ ∧ Hφ) -> FHφ` | Discrete (successor exists) | ∀t. (∃s. t < s) -> ∃s. (t < s ∧ ∀u. ¬(t < u < s)) |
| **DISCR-P** | `(P⊤ ∧ φ ∧ Gφ) -> PGφ` | Discrete (predecessor exists) | Dual of DISCR-F |
| **NOBEG** | `P⊤` or `Hφ -> Pφ` | No minimum (past-seriality) | ∀t. ∃s. s < t |
| **NOEND** | `F⊤` or `Gφ -> Fφ` | No maximum (future-seriality) | ∀t. ∃s. t < s |
| **LIN-F** | `PFφ -> (Pφ ∨ φ ∨ Fφ)` | Forward-linearity | ∀s,t,u. (s < t ∧ s < u) -> (t < u ∨ t = u ∨ u < t) |
| **LIN-P** | `FPφ -> (Pφ ∨ φ ∨ Fφ)` | Backward-linearity | Dual of LIN-F |

### Modal Axioms (for comparison)

| Axiom | Formula | Frame Property | First-Order Condition |
|-------|---------|----------------|----------------------|
| **D** | `□φ -> ◇φ` | Serial | ∀w. ∃u. wRu |
| **T/M** | `□φ -> φ` | Reflexive | ∀w. wRw |
| **4** | `□φ -> □□φ` | Transitive | ∀w,v,u. (wRv ∧ vRu) -> wRu |
| **B** | `φ -> □◇φ` | Symmetric | ∀w,v. wRv -> vRw |
| **5** | `◇φ -> □◇φ` | Euclidean | ∀w,v,u. (wRv ∧ wRu) -> vRu |
| **C4** | `□□φ -> □φ` | Dense | ∀w,v. wRv -> ∃u. (wRu ∧ uRv) |
| **CD** | `◇φ -> □φ` | Functional | ∀w,v,u. (wRv ∧ wRu) -> v=u |

### Non-Definable Properties

Some frame properties are NOT expressible by any tense logic formula:

| Property | Reason |
|----------|--------|
| **Irreflexivity** | No tense formula defines ∀t. ¬(t < t) |
| **Asymmetry** | Follows from irreflexivity, also not definable |
| **Antisymmetry** | Not definable in basic tense logic |
| **Connectedness** | Not expressible, but doesn't generate extra validities |

---

## Common Extensions and Their Frame Conditions

### Standard Extension Systems

| System | Base | Added Axioms | Frame Class |
|--------|------|--------------|-------------|
| **K4t** | Kt | TRAN | Transitive frames |
| **S4t** | Kt | REF + TRAN | Partial orderings (reflexive, transitive) |
| **Lt** (Kt.Li) | Kt | TRAN + LIN | Strict linear orderings |
| **Nt** | Kt | NOEND + IND_G + WELLORD | Natural numbers (N, <) |
| **Zt** | Kt | NOBEG + NOEND + IND_H + IND_G | Integers (Z, <) |
| **Qt** | Kt | NOBEG + NOEND + DENSE | Rationals (Q, <) |
| **Rt** | Kt | NOBEG + NOEND + DENSE + COMPL | Reals (R, <) |

### Layered Extension Architecture

A natural organization emerges:

**Layer 0: Kt (Base)**
- KG, KH, GP, HF
- Valid on all frames

**Layer 1: Order Structure**
- TRAN (transitivity)
- REF (reflexivity, if desired)

**Layer 2: Seriality (No Endpoints)**
- NOBEG (past seriality / no minimum)
- NOEND (future seriality / no maximum)

**Layer 3: Linearity**
- LIN-F (forward linearity)
- LIN-P (backward linearity)

**Layer 4: Density OR Discreteness (Mutually Exclusive)**
- DENSE (density)
- DISCR-F, DISCR-P (discreteness)

**Layer 5: Completeness/Induction**
- COMPL (Dedekind completeness)
- IND_G, IND_H (induction principles)
- WELLORD (well-ordering)

---

## Extension Dependencies

### Logical Dependencies

```
DENSE and DISCR are mutually exclusive
  |-- DENSE valid on dense orders (Q, R)
  |-- DISCR valid on discrete orders (Z, N)

LINEAR implies TRAN is useful
  |-- Linearity schemas often assume transitivity

REF + TRAN = partial order (S4t)
  |-- S4t is complete for reflexive, transitive frames

NOBEG + NOEND = bidirectional seriality
  |-- Required for Z, Q, R

WELLORD implies forward-directedness
  |-- Only one direction from any point (like N)

COMPL (Dedekind completeness) is second-order
  |-- Completeness for R requires infinitary rules or frame constants
```

### Derivability Relations

| Derived Axiom | Derivable From |
|---------------|----------------|
| **DISCR-P** | DISCR-F + temporal duality |
| **LIN-P** | LIN-F + temporal duality |
| **NOEND** | REF (trivially: P⊤ at t witnessed by t itself) |
| **NOBEG** | REF (trivially: F⊤ at t witnessed by t itself) |

**Important**: With reflexive semantics (G/H quantify over <= instead of <):
- REF axioms (Gφ -> φ, Hφ -> φ) become valid by definition
- Seriality axioms become trivially valid (current time witnesses)
- This is the ProofChecker's current design choice

---

## Adaptation Notes for Bimodal TM

### Current TM Axiom System Analysis

The ProofChecker's TM logic (Axioms.lean) currently has 21 axiom constructors. Analyzing which are base vs. extension:

**Propositional (Base - no frame condition)**:
- `prop_k`: K distribution for implication
- `prop_s`: Weakening
- `ex_falso`: Ex falso quodlibet
- `peirce`: Classical logic (Peirce's law)

**Modal S5 (Extension - equivalence relation frame)**:
- `modal_t`: Reflexivity (T axiom)
- `modal_4`: Transitivity (4 axiom)
- `modal_b`: Symmetry (B axiom)
- `modal_5_collapse`: S5 collapse
- `modal_k_dist`: K distribution for box

**Temporal Base Kt (No frame condition)**:
- `temp_k_dist`: K distribution for G
- `temp_a`: GP interaction axiom
- `temp_l`: TL axiom (perpetuity)

**Temporal Extensions (Frame conditions)**:
- `temp_4`: Transitivity for G
- `temp_t_future`: REF (Gφ -> φ) - REQUIRES REFLEXIVE FRAMES
- `temp_t_past`: REF (Hφ -> φ) - REQUIRES REFLEXIVE FRAMES
- `temp_linearity`: Linearity - REQUIRES LINEAR FRAMES
- `density`: Density - REQUIRES DENSE FRAMES
- `discreteness_forward`: Discreteness - REQUIRES DISCRETE FRAMES
- `seriality_future`: NOEND - REQUIRES NO MAXIMUM
- `seriality_past`: NOBEG - REQUIRES NO MINIMUM

**Modal-Temporal Interaction (Need analysis)**:
- `modal_future`: Cross-modal axiom
- `temp_future`: Cross-modal axiom

### Recommended Refactoring

To organize TM base logic with extensions:

1. **Separate `Axiom.isBase`**: Already exists, but should be refined
   - Current: Excludes density, discreteness, seriality
   - Missing: Should also mark temp_t_future/temp_t_past as extensions

2. **Add `Axiom.isKtBase`**: New predicate for pure Kt axioms
   - Include: temp_k_dist, temp_a, temp_l
   - Exclude: temp_4, temp_t_*, temp_linearity, density, discreteness, seriality

3. **Add `Axiom.FrameCondition`**: Type describing required frame property
   - `none`: Base axioms
   - `reflexive`: temp_t_future, temp_t_past
   - `transitive`: temp_4
   - `linear`: temp_linearity
   - `dense`: density
   - `discrete`: discreteness_forward
   - `no_max`: seriality_future
   - `no_min`: seriality_past

4. **Parameterized Derivation**: Allow proving "phi derivable in Kt+X"
   - Use typeclass or predicate to filter axioms
   - Enables reasoning about different extension combinations

### Reflexive vs. Irreflexive Semantics Note

The ProofChecker uses REFLEXIVE temporal semantics (G/H quantify over <=):
- This makes temp_t_future and temp_t_past valid by definition
- Seriality axioms become trivially valid (t <= t witnesses F⊤ at t)
- This is a deliberate design choice documented in Truth.lean

If switching to IRREFLEXIVE semantics (G/H quantify over strict <):
- temp_t_future and temp_t_past would need to be REMOVED from base
- Seriality would require actual successor/predecessor existence
- Density would interact differently with the ordering

---

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Int/Rat Import Approaches | Medium | D-from-syntax constraint doesn't affect axiom organization, but confirms need for clean separation of frame-dependent axioms |
| Reflexive G/H Semantics | High | ADOPTED - confirms TT-F/TT-P are definitionally valid, which affects how we categorize them (definitional vs. axiomatic) |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family | ACTIVE | Uses reflexive semantics, consistent with this analysis |
| D Construction from Canonical Timeline | ACTIVE | Frame conditions (density, seriality) are axiom requirements, confirming need to clearly mark these extensions |

---

## References

### Primary Sources

1. [Stanford Encyclopedia of Philosophy - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) - Comprehensive overview of Kt and extensions
2. [Stanford Encyclopedia of Philosophy - Modal Logic](https://plato.stanford.edu/entries/logic-modal/) - Axiom-frame correspondences
3. Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed. CSLI Publications.
4. Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.

### Codebase Sources

1. [Axioms.lean](/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean) - Current TM axiom definitions
2. [ProofSystem.lean](/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem.lean) - Proof system overview
3. [Truth.lean](/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean) - Reflexive semantics documentation
4. [LinearityDerivedFacts.lean](/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean) - Linearity analysis
5. [Discreteness.lean](/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/Discreteness.lean) - DP derivable from DF

---

## Summary

The theoretical foundations for organizing TM base logic with extensions are well-established:

1. **Kt base**: KG, KH, GP, HF - valid on ALL frames
2. **Extensions**: Each additional axiom corresponds to a specific frame property
3. **Reflexive semantics choice**: Makes T-axioms definitionally valid (not axiomatic)
4. **Mutual exclusivity**: Density and discreteness are incompatible
5. **Layered architecture**: Natural organization from base to order structure to density/discreteness

The ProofChecker should:
- Clearly separate base Kt axioms from frame-specific extensions
- Add machinery to reason about axiom subsets (e.g., "derivable in Kt+DENSE")
- Document which axioms are definitionally valid under reflexive semantics vs. which impose genuine frame conditions
