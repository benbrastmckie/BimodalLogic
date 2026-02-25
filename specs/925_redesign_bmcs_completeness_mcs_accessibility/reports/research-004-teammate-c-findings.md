# Research Findings: Teammate C - Architecture Clarification and Constant Family Elimination

**Task**: #925 - Redesign BMCS completeness construction using MCS accessibility relation
**Date**: 2026-02-25
**Focus**: Clarify existing architecture terminology, locate all constant family mentions, explain why constant families failed, propose non-constant alternative

## 1. Current Architecture Explained (with Clear Definitions)

### 1.1 BFMCS: Bundled Family of Maximal Consistent Sets

**File**: `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`

A BFMCS is a **single family** that maps time points to MCSs. It is NOT a bundle -- it is a single indexed family of MCSs with temporal coherence.

**Definition** (lines 79-97):
```lean
structure BFMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t <= t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' <= t -> Formula.all_past phi in mcs t -> phi in mcs t'
```

**In words**: A BFMCS assigns one MCS to each time point `t : D`, with the requirement that G-formulas propagate forward in time and H-formulas propagate backward in time.

**The name is misleading**: Despite containing "Bundled", a BFMCS is a single indexed family. The "Bundled" in the name comes from the Lean4 pattern of bundling data with proofs, not from being a collection of multiple families. A better mental model: **"a time-indexed MCS family with temporal coherence proofs"**.

### 1.2 BMCS: Bundle of Maximal Consistent Sets

**File**: `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`

A BMCS is a **bundle** (collection) of BFMCSs with modal coherence conditions.

**Definition** (lines 82-113):
```lean
structure BMCS where
  families : Set (BFMCS D)
  nonempty : families.Nonempty
  modal_forward : forall fam in families, forall phi t,
    Formula.box phi in fam.mcs t -> forall fam' in families, phi in fam'.mcs t
  modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi in fam'.mcs t) -> Formula.box phi in fam.mcs t
  eval_family : BFMCS D
  eval_family_mem : eval_family in families
```

**In words**: A BMCS is a set of BFMCS families, equipped with:
- **modal_forward**: If Box(phi) is in any family's MCS at time t, then phi is in ALL families' MCSs at time t.
- **modal_backward**: If phi is in ALL families' MCSs at time t, then Box(phi) is in each family's MCS at time t.
- **eval_family**: A distinguished family where evaluation begins (containing the original consistent context Gamma).

### 1.3 The Two-Layer Architecture

The architecture is genuinely two-layered:

| Layer | Structure | Handles | Coherence Conditions |
|-------|-----------|---------|---------------------|
| **Temporal** | BFMCS | G, H, F, P operators | forward_G, backward_H (definitional); forward_F, backward_P (existential) |
| **Modal** | BMCS | Box, Diamond operators | modal_forward, modal_backward |

The layers compose: `Box(G phi) in fam.mcs(t)` decomposes as:
1. By modal_forward: `G phi in fam'.mcs(t)` for all fam' in bundle
2. By forward_G: `phi in fam'.mcs(s)` for all fam' and all s >= t

This decomposition is the insight documented in research-002.md Finding 6.

### 1.4 Additional Important Structures

**TemporalCoherentFamily** (`TemporalCoherentConstruction.lean:206-212`):
Extends BFMCS with the existential duals:
- `forward_F`: If F(phi) in mcs(t), then exists s >= t with phi in mcs(s)
- `backward_P`: If P(phi) in mcs(t), then exists s <= t with phi in mcs(s)

These are needed for the TruthLemma backward direction for G and H.

**is_modally_saturated** (`ModalSaturation.lean:94-96`):
A BMCS where every Diamond formula has a witness family:
```lean
def is_modally_saturated (B : BMCS D) : Prop :=
  forall fam in B.families, forall t, forall psi,
    diamondFormula psi in fam.mcs t -> exists fam' in B.families, psi in fam'.mcs t
```

### 1.5 The Completeness Goal

The completeness proof requires constructing a BMCS that simultaneously has:
1. **Context preservation**: Gamma is in eval_family.mcs(0)
2. **Temporal coherence**: ALL families satisfy forward_F and backward_P
3. **Modal saturation**: Every Diamond formula has a witness family
4. **Modal backward**: Follows from saturation via `saturated_modal_backward` (proven sorry-free)

The current state is `fully_saturated_bmcs_exists_int` at `TemporalCoherentConstruction.lean:799-819`, which is a sorry-backed theorem asserting this exists.

## 2. Constant Family Mentions (Locations to Remove/Revise)

### 2.1 Active Lean Source Files (Non-Boneyard)

These are in the live codebase and should be revised or removed:

#### Construction.lean
| Line(s) | Content | Action |
|----------|---------|--------|
| 14 | `constantBFMCS: A family assigning the same MCS at every time` | Comment references constant family |
| 77-108 | `constantBFMCS` definition and lemma | The definition itself; used by downstream code |
| 111-114 | `constantBFMCS_mcs_eq` | Accessor for constant family |
| 272 | `constantBFMCS: Constant-time MCS family` in summary | Summary comment |

#### ModalSaturation.lean
| Line(s) | Content | Action |
|----------|---------|--------|
| 245-269 | `constantWitnessFamily` definition and lemma | Builds a constant BFMCS for witness families |
| 275-289 | `constructWitnessFamily` using `constantWitnessFamily` | Constructs witness as constant family |

#### CoherentConstruction.lean
| Line(s) | Content | Action |
|----------|---------|--------|
| 37-44 | "Important Note: Constant Families" section | Comment section advocating constant families |
| 51 | `diamond_boxcontent_consistent_constant` | Named for constant families |
| 58 | `CoherentBundle: Structure collecting mutually coherent constant families` | Comment |
| 72 | "Constant families: All families in a CoherentBundle are constant" | Comment |
| 77-78 | "constant-family witnesses avoid the Lindenbaum control problem" | Comment |
| 205-230 | Phase 2 header about constant families, `IsConstantFamily` definition | Core infrastructure |
| 214 | `IsConstantFamily` predicate definition | Used extensively |
| 234-260 | `diamond_boxcontent_consistent_constant` - core lemma restricted to constant families | |
| 342-363 | Witness construction using `constantWitnessFamily` | |
| 435-520 | `MutuallyCoherent_singleton`, `BoxEquivalent_singleton` for constant families | |
| 549-590 | `CoherentBundle` structure requiring `all_constant` | |
| 725-735 | `constantBFMCS_is_constant`, `constantWitnessFamily_is_constant` | |
| 745-935 | `initialCoherentBundle` and entire construction built on constant families | |
| 1039-1185 | `EvalCoherentBundle` with `all_constant`, `eval_constant` fields | |
| 1411-1581 | `exists_fullySaturated_extension` using constant families throughout | |

#### TemporalCoherentConstruction.lean
| Line(s) | Content | Action |
|----------|---------|--------|
| 315 | "For a constant family, this means F(psi) -> psi within the MCS" | Comment |
| 332-372 | `TemporalEvalSaturatedBundle` - structure for constant families | |
| 367-372 | `toBFMCS_constant : IsConstantFamily B.toBFMCS` | |
| 504 | "which claimed a constant family could be temporally saturated" | Comment |
| 787-815 | Comments about witness families being constant, needing temporally saturated MCS | |

#### WitnessGraph.lean
| Line(s) | Content | Action |
|----------|---------|--------|
| 2420 | "We use the root MCS as a constant family" | Comment |
| 2436 | "The constant family sidesteps this issue entirely" | Comment |
| 2545 | "its constant-family BFMCS only has universal G/H propagation" | Comment |
| 2550 | "Since witnessGraphBFMCS is a constant family" | Comment |

#### BFMCS.lean
| Line(s) | Content | Action |
|----------|---------|--------|
| 34 | "They existed only because constant-family constructions provided them trivially" | Comment |

#### Representation.lean
| Line(s) | Content | Action |
|----------|---------|--------|
| 91 | "WorldState is generalized to any MCS (not restricted to constant families)" | Comment |

### 2.2 Boneyard Files (Dead Code)

These are in `Theories/Bimodal/Boneyard/` and are not used by active code:

- `Boneyard/Bundle/SaturatedConstruction.lean`: ~70+ mentions of constant families (lines 452-1403)
- `Boneyard/Bundle/FinalConstruction.lean`: ~30+ mentions (lines 23-519)
- `Boneyard/Bundle/RecursiveSeed/Builder.lean`: ~5 mentions (lines 5440-5839)

### 2.3 Research Reports and Specs

The phrase "Witness families for modal saturation are typically constant" appears in:
- `research-001-teammate-b-findings.md:11` - "Witness families ... are typically constant families"
- `research-002.md:135` - "Witness families for modal saturation are typically constant"

These should be revised to state that constant families are NOT to be used.

## 3. Why Constant Families Failed

### 3.1 The Core Impossibility

A **constant family** assigns the same MCS `M` to every time point: `fam.mcs(t) = M` for all `t`.

For such a family:
- `forward_G` and `backward_H` hold trivially via the T-axioms (G phi -> phi, H phi -> phi), since the MCS is the same at all times.
- `forward_F` requires: if F(psi) in M, then exists s >= t with psi in M. Since mcs(s) = M for all s, this reduces to: **F(psi) in M implies psi in M**.
- `backward_P` requires: if P(psi) in M, then exists s <= t with psi in M. This reduces to: **P(psi) in M implies psi in M**.

### 3.2 Why F(psi) in M Does NOT Imply psi in M

The formula F(psi) = neg(G(neg(psi))) asserts "it is not the case that neg(psi) holds at all future times." This is an EXISTENTIAL claim: there EXISTS a future time where psi holds.

For an MCS M, having F(psi) in M does NOT mean psi is in M. Counterexample:
- Let M be an MCS containing {F(p), neg(p)} where p is an atom.
- This is consistent: "p is false now, but p will be true at some future time."
- F(p) in M but p NOT in M.

This is proven impossible in research-005 for task 924 (Section 4.3-4.4).

### 3.3 The Cascade of Failure

This impossibility cascades through the completeness proof:

1. Modal saturation requires witness families for Diamond formulas.
2. The `constructWitnessFamily` function (ModalSaturation.lean:277) builds constant families.
3. Constant witness families cannot satisfy forward_F/backward_P.
4. The TruthLemma backward direction for G/H requires forward_F/backward_P for ALL families.
5. Therefore: the TruthLemma fails for witness families at the G/H cases.

This is the "fundamental tension" documented in research-002.md (Section "Synthesis: The Core Problem"):
> - Temporal coherence for ALL families (forward_F, backward_P for TruthLemma G/H cases)
> - Modal saturation (witness families for Diamond formulas)
> - Non-constant witness families (to satisfy #1)

### 3.4 Historical Attempts That Failed Due to Constant Families

| Task | Approach | Failure Point |
|------|----------|--------------|
| 812 | Single constant family + FALSE axiom (singleFamily_modal_backward_axiom) | Axiom was false |
| 843 | TemporalEvalSaturatedBundle (constant + temporally saturated) | Cannot build temporally saturated MCS in general |
| 844/851/853 | CoherentBundle (all constant families) | Modal saturation achieved, but temporal coherence impossible |
| 881 | Int-specialized combination | Constant witness families fail temporal coherence |
| 916 | WitnessGraph constant family oracle | F(psi) in rootMCS does not imply psi in rootMCS |
| 922 | Strategy study | Confirmed constant families fundamentally incompatible |
| 924 | Two-tier BMCS with constant witness tier | Phase 1 analysis proved constant families unsafe |

## 4. Non-Constant Alternative

### 4.1 The Existing Non-Constant Success: CanonicalBFMCS

The codebase already has a **sorry-free non-constant BFMCS** construction:

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean`

This constructs a BFMCS over ALL maximal consistent sets (CanonicalMCS) where:
- Domain D = CanonicalMCS (all MCSs, with CanonicalR Preorder)
- `mcs(w) = w.world` (each element maps to its own MCS -- genuinely non-constant)
- `forward_F` uses `canonical_forward_F` -- the witness MCS IS a domain element
- `backward_P` uses `canonical_backward_P` -- the witness MCS IS a domain element

This approach works because every MCS is in the domain, so F/P witnesses are always available. No temporal saturation assumption needed.

### 4.2 The User's Intended Approach: Seed Unraveling

The user describes the approach:
> "To get around Lindenbaum uncontrollability, the idea was to unravel the seed by recursively expanding just the single consistent sentence, where this generates a partial set of partial families of consistent sets that are then saturated and closed in various ways in order to work back towards a BFMCS."

This approach differs from constant families in a fundamental way:

**Constant family approach**: Start with one MCS, replicate it at all times. Hope temporal formulas are already satisfied within that single MCS. **This fails** because existential temporal formulas (F, P) require witnesses at DIFFERENT times, but a constant family has the same set at all times.

**Seed unraveling approach**: Start with a single consistent sentence. Recursively expand it to produce different MCSs at different time points. The expansion process CREATES the witnesses at the appropriate times. Each time point may have a genuinely different MCS, allowing F(psi) at time t to have its witness psi at some other time s with a different MCS.

### 4.3 What Non-Constant Witness Families Need

For the redesigned completeness proof, witness families should be non-constant histories:

1. When Diamond(psi) appears in some family fam at time t, instead of creating a constant family containing psi at ALL times...
2. Construct a NEW HISTORY (non-constant BFMCS) that:
   - Contains psi at time t (witnessing the Diamond)
   - Has GContent-based temporal coherence along its timeline
   - Satisfies forward_F and backward_P through its own temporal construction

3. This means each witness family is itself a dovetailing chain or canonical history, not a single replicated MCS.

### 4.4 Path D from Research-002: Non-Constant Witness Histories

The most promising approach (research-002.md "Path D"):

1. **Domain**: CanonicalMCS (all MCSs with CanonicalR preorder)
2. **Eval family**: canonicalMCSBFMCS using identity mapping w -> w.world (sorry-free)
3. **Witness families**: For Diamond(psi) in fam.mcs(t), construct a NEW HISTORY h' where:
   - h'(t) is an MCS containing psi
   - h' extends forward/backward from h'(t) as a CanonicalR chain
   - h' is a temporally coherent non-constant family

This leverages the existing CanonicalBFMCS infrastructure for building temporally coherent non-constant families.

## 5. Summary of Key Points

### The terminology corrected:
- **BFMCS** = A single time-indexed family of MCSs (NOT a bundle of families)
- **BMCS** = A bundle (set) of BFMCSs with modal coherence
- The "two-layer" architecture (BMCS wrapping BFMCSs) is structurally correct
- The problem is not the architecture but the constant family strategy for witness families

### The constant family directive:
- Constant families are NEVER to be pursued for witness families
- They cannot satisfy forward_F/backward_P (mathematically impossible, proven in task 924)
- All comments suggesting constant families work or are "typically" used should be revised
- The `constantBFMCS` and `constantWitnessFamily` definitions remain useful as building blocks for the eval family's initial construction, but should NOT be used for modal saturation witness families

### The replacement approach:
- Witness families should be non-constant histories through CanonicalMCS
- The CanonicalBFMCS infrastructure provides a sorry-free template
- The seed unraveling approach generates different MCSs at different times, naturally satisfying existential temporal properties

## Confidence Level

**HIGH (85%)** for the architecture analysis and constant family impossibility -- these are well-documented and proven in the codebase.

**MODERATE (65%)** for the non-constant witness family approach -- the CanonicalBFMCS infrastructure exists and works, but extending it to construct witness families for arbitrary Diamond formulas while maintaining all coherence conditions simultaneously has not been proven.

**HIGH (90%)** for the constant family removal locations -- the grep search was comprehensive across both active and Boneyard code.
