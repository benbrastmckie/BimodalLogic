# Research Report: Task #977 — Organize TM Base Logic with Extensions

**Task**: 977 - Organize TM base logic with extensions
**Date**: 2026-03-16
**Mode**: Team Research (4 teammates)
**Session**: sess_1773680250_047fb0

---

## Executive Summary

The TM proof system is a bimodal logic combining S5 modal necessity (Box) with reflexive linear temporal operators (G/H) over a parameterized duration type D drawn from a linearly ordered additive group. The current codebase has a **well-designed but underspecified** base/extension structure.

**Key finding**: The existing `isBase`/`isDenseCompatible`/`isDiscreteCompatible` predicates in `Axioms.lean` correctly capture the base vs. extension distinction — but this structure is implicit (predicate-level), not structural (type-level), and critical metalogical results (completeness theorems) are incomplete or missing. The primary work for Task 977 is:

1. **Clarifying and documenting** the theoretical justification for the axiom classification
2. **Completing the dense completeness wiring** (components proven, final theorem missing)
3. **Adding a discrete completeness framework** (largely absent)
4. **Restructuring the proof system** to make base/extension separation explicit and type-safe
5. **Establishing soundness/completeness for each extension** as formal theorems

---

## Part I: Theoretical Foundation

### 1.1 The Minimal TM Base Logic

Standard minimal tense logic **Kt** is valid on ALL frames (with KG, KH, GP, HF axioms). TM's frame class is more constrained: **linearly ordered additive groups** (reflexive, transitive, linear, with group operations). This richer frame class validates additional axioms definitionally — they need not be stated as extension axioms.

**The TM base logic is valid on ALL structures `(D, +, ≤)` satisfying `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.**

Teammate B's analysis of standard tense logic correspondences, adapted to TM's reflexive semantics and linear frame class:

| Axiom | Standard Correspondence | TM Status |
|-------|------------------------|-----------|
| `temp_k_dist` (KG) | No frame condition | **Base** |
| `temp_a` (GP/HF) | No frame condition | **Base** |
| `temp_l` (TL perpetuity) | No frame condition | **Base** |
| `temp_4` (4) | Transitivity | **Base** (linear orders are transitive) |
| `temp_t_future` (T-future) | Reflexivity | **Base** (reflexive semantics: G/H use ≤) |
| `temp_t_past` (T-past) | Reflexivity | **Base** (reflexive semantics) |
| `temp_linearity` (Lin) | Linearity | **Base** (linear ordered groups are linear) |
| `modal_*` (S5 axioms) | Equivalence relation | **Base** (Box has universal accessibility) |
| `modal_future`, `temp_future` | Interaction | **Base** (TM-specific; definitionally valid) |
| `density` | DenselyOrdered | **Extension** (not all linear groups) |
| `discreteness_forward` (DF) | SuccOrder | **Extension** (not all linear groups) |
| `seriality_future` | NoMaxOrder | **Extension** (not all linear groups) |
| `seriality_past` | NoMinOrder | **Extension** (not all linear groups) |

**Critical conclusion**: The current `isBase` predicate (which excludes exactly `density`, `discreteness_forward`, `seriality_future`, `seriality_past`) is **theoretically correct** for TM's frame class. The 17 base axioms are valid on all TaskFrame structures.

### 1.2 Extensions and Frame Conditions

Four extension axioms correspond to additional frame conditions:

| Extension Axiom | Frame Condition | Standard Logic | Formal Constraint |
|-----------------|-----------------|----------------|-------------------|
| `density` | Dense ordering | Qt (rationals) | `DenselyOrdered D` |
| `discreteness_forward` (DF) | Immediate successor exists | Zt (integers) | `SuccOrder D`, `PredOrder D` (by duality) |
| `seriality_future` | No maximum | Bidirectional unboundedness | `NoMaxOrder D` (or `Nontrivial D` with right instances) |
| `seriality_past` | No minimum | Bidirectional unboundedness | `NoMinOrder D` |

**Note**: `discreteness_backward` (DP) is not an independent axiom — it is derivable from `discreteness_forward` plus temporal duality (`Theories/Bimodal/Theorems/Discreteness.lean`). This is correct.

### 1.3 Three Logic Variants

| Logic | Axioms | Valid Frame Class |
|-------|--------|------------------|
| **TM Base** | All 17 base axioms | All linear ordered additive groups |
| **TM Dense** | Base + `density` + `seriality_future` + `seriality_past` | Dense, unbounded linear orders (Q-like) |
| **TM Discrete** | Base + `discreteness_forward` + `seriality_future` + `seriality_past` | Discrete, unbounded linear orders (Z-like) |

**Mutual exclusivity**: `density` and `discreteness_forward` are incompatible frame conditions — no frame can satisfy both. The `isDenseCompatible`/`isDiscreteCompatible` predicates correctly reflect this.

### 1.4 Bimodal Structure

TM is genuinely bimodal with three primitive operators (Box, G, H). The key semantic novelty:

- **Box** quantifies over ALL WorldHistories in a bundle Ω (modal dimension)
- **G/H** quantify over all time points ≤/≥ t within the SAME WorldHistory (temporal dimension)
- **WorldHistory** is a trajectory through world states over convex time domains
- **TaskFrame** relates world states via a duration-parameterized task relation

This bimodal structure means:
- Standard unimodal tense logic results do not directly apply
- The canonical model must handle WorldHistory bundles (BFMCS approach)
- Modal backward closure (`modal_backward`) requires multi-family bundles
- Box persistence (`box_persistent`: Box φ at t implies Box φ at all t') requires TF axiom

---

## Part II: Current Codebase State

### 2.1 Axiom Inventory (21 constructors)

| # | Constructor | Category | Base? | Extension |
|---|-------------|----------|-------|-----------|
| 1–4 | `prop_k`, `prop_s`, `ex_falso`, `peirce` | Propositional | ✓ | — |
| 5–9 | `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist` | Modal S5 | ✓ | — |
| 10–16 | `temp_k_dist`, `temp_4`, `temp_t_future`, `temp_t_past`, `temp_a`, `temp_l`, `temp_linearity` | Temporal (base) | ✓ | — |
| 17–18 | `modal_future`, `temp_future` | Interaction | ✓ | — |
| 19 | `density` | Temporal | ✗ | Dense |
| 20 | `discreteness_forward` | Temporal | ✗ | Discrete |
| 21–22 | `seriality_future`, `seriality_past` | Temporal | ✗ | Serial |

**Note**: The count in some READMEs says "14 axioms" — this is outdated. The actual count is 21 constructors (22 entries above because seriality_future/past are counted as 2 separate constructors). Documentation needs updating.

### 2.2 Soundness Status (Complete)

**File**: `Theories/Bimodal/Metalogic/Soundness.lean`

All 21 axiom validity theorems are proven. Three combined validators:
- `axiom_base_valid`: All base axioms valid on all linear ordered additive groups ✓
- `axiom_valid_dense`: Dense-compatible axioms valid on dense frames ✓
- `axiom_valid_discrete`: Discrete-compatible axioms valid on discrete frames ✓

**Soundness is complete for all three logic variants.**

However, there is a gap noted by Teammate A: `axiom_base_valid` etc. prove AXIOM validity but not full DERIVATION soundness (i.e., that every derivable formula is valid, not just every axiom). A full derivation soundness theorem of the form:

```
∀ (d : DerivationTree Γ φ) (hbase : d.allAxiomsBase), valid φ
```

may be missing or located elsewhere.

### 2.3 Completeness Status

**Dense Completeness** (`Metalogic/StagedConstruction/Completeness.lean`):

| Component | Status |
|-----------|--------|
| Truth Lemma (BFMCS) | **PROVEN** (sorry-free) |
| Shifted Truth Lemma | **PROVEN** (sorry-free) |
| Cantor Isomorphism (`TimelineQuot ≃o Q`) | **PROVEN** (sorry-free) |
| Temporal Coherent Family construction | **PROVEN** (sorry-free) |
| Final completeness theorem wiring | **INCOMPLETE** — domain mismatch between `CanonicalMCS Int` and `TimelineQuot` |

The missing wiring step is the bridge between the BFMCS construction (over Int indices) and the dense frame (over TimelineQuot ≃ Q). This is the most critical outstanding gap.

**Discrete Completeness**: No dedicated completeness theorem found. The discrete case (`valid_discrete φ → ⊢ φ`) appears largely absent.

**Base Completeness**: The BFMCS approach with D = Int or D = some fixed discrete order handles the base case implicitly through the bundle construction, but a formal statement `valid φ → ⊢ φ` may not be stated as its own theorem.

### 2.4 Key Sorries

| File | Sorry Count | Nature |
|------|-------------|--------|
| `Canonical/ConstructiveFragment.lean` | 2 | NoMaxOrder/NoMinOrder on quotient (task 973) |
| `Domain/DiscreteTimeline.lean` | 4 | SuccOrder/PredOrder coverness properties (task 974) |
| Other Metalogic/ files | ~5 additional | Staged construction gaps |

Total active metalogic sorries: ~9–11 (excluding boneyard).

### 2.5 Current Organization Structure

```
Theories/Bimodal/
├── Syntax/                  # Formula, Atom, Context, Subformulas
├── ProofSystem/             # Axioms.lean, Derivation.lean (monolithic)
├── Semantics/               # TaskFrame, WorldHistory, Truth, Validity
├── Metalogic/
│   ├── Soundness.lean       # All axiom validity proofs
│   ├── Core/                # MCS theory, deduction theorem
│   ├── Bundle/              # BFMCS completeness approach
│   ├── StagedConstruction/  # Dense completeness components
│   ├── Domain/              # CanonicalDomain, DiscreteTimeline
│   ├── Canonical/           # Canonical model support
│   ├── Decidability/        # Tableau decision procedure (complete)
│   └── Algebraic/           # Alternative algebraic approach
├── Theorems/                # Derived theorems
├── Automation/              # Tactics, ProofSearch
└── Examples/
```

---

## Part III: Gaps and Missing Results

### Gap 1: Dense Completeness Wiring

**The single most critical gap.** All dense completeness components are proven, but the final completeness theorem `valid_dense φ → ⊢ φ` is not wired together due to a domain mismatch between the canonical construction (using Int-indexed MCS families) and the dense frame class (requiring DenselyOrdered D via Cantor's theorem `TimelineQuot ≃o Q`).

**Resolution approach**: Construct a transfer map between the Int-indexed BFMCS and the TimelineQuot-based dense frame. This likely requires:
- Showing the canonical timeline quotient embeds into the Int-indexed system
- Or constructing the canonical BFMCS directly over a densely ordered domain

### Gap 2: Discrete Completeness Framework

**Missing entirely**: A completeness theorem `valid_discrete φ → ⊢ φ` for TM Discrete. The DiscreteTimeline construction (task 974) is building infrastructure for this, but a discrete completeness theorem does not appear to exist yet.

### Gap 3: Base Completeness Statement

**May be missing or implicit**: A formal `valid φ → ⊢ φ` for TM Base. The BFMCS construction may handle this implicitly, but it should be stated as an explicit theorem.

### Gap 4: Full Derivation Soundness

The existing soundness results prove axiom validity, but a full derivation soundness theorem (covering modus ponens and necessitation rules in addition to axioms) may be missing or scattered. This should be a single named theorem.

### Gap 5: Proof System Type-Level Separation

No explicit type-level separation between proof systems:
- No `DerivationTree_Base` vs. `DerivationTree_Dense` vs. `DerivationTree_Discrete`
- Axiom filtering is predicate-based, not type-safe
- Users must manually ensure only appropriate axioms are used in each context

### Gap 6: Documentation

- README and ProofSystem.lean cite "14 axiom schemata" — actual count is 21
- The theoretical justification for the base/extension split is not documented
- No "Logic Guide" explaining the three TM variants and their intended semantics

---

## Part IV: Recommended Refactoring Strategy

### 4.1 Core Principle: Additive, Not Disruptive

The existing codebase has a sound foundation. The recommended strategy layers new abstractions on top of working proofs rather than rewriting them. Three phases:

**Phase 1 (Immediate): Clarification and Documentation**
- Document the theoretical justification for the base/extension classification
- Update README.md and ProofSystem.lean with correct axiom counts (21)
- Add a `FrameClass` enumeration and document which axioms belong to each
- Verify full derivation soundness is stated (not just axiom validity)

**Phase 2 (Medium-term): Complete Metalogic**
- Wire together the dense completeness components (the critical gap)
- Add a formal discrete completeness framework
- State explicit completeness theorems for each variant:
  - `theorem completeness_base : valid φ → ⊢_base φ`
  - `theorem completeness_dense : valid_dense φ → ⊢_dense φ`
  - `theorem completeness_discrete : valid_discrete φ → ⊢_discrete φ`
- Resolve remaining sorries in `ConstructiveFragment.lean` and `DiscreteTimeline.lean`

**Phase 3 (Long-term): Structural Improvement**
- Add `FrameClass` enumeration to `Axioms.lean`
- Add derivation validation predicates (which FrameClass does a derivation use?)
- Consider typeclass-based parameterization for frame conditions
- Consider separate inductive types for each logic variant if type safety is needed

### 4.2 Axiom-Frame Correspondence Formalization

Each extension axiom should be paired with an explicit soundness lemma naming the frame condition:

```lean
-- Already exists but could be made more explicit:
theorem density_valid [DenselyOrdered D] [Nontrivial D] :
    valid_dense (density (p := p)) := ...

theorem discreteness_forward_valid [SuccOrder D] [PredOrder D] [Nontrivial D] :
    valid_discrete (discreteness_forward (p := p)) := ...

theorem seriality_future_valid [NoMaxOrder D] [Nontrivial D] :
    valid_dense (seriality_future) := ...
    -- (also valid_discrete version)
```

The frame condition in the typeclass constraint IS the axiom-frame correspondence.

### 4.3 Logic Variant Specification

Introduce explicit notation for provability in each variant:

```lean
-- Notation for derivation in each variant
notation Γ " ⊢_TM " φ => ∃ d : DerivationTree Γ φ, d.allAxiomsBase
notation Γ " ⊢_TMD " φ => ∃ d : DerivationTree Γ φ, d.isDenseCompatible
notation Γ " ⊢_TMZ " φ => ∃ d : DerivationTree Γ φ, d.isDiscreteCompatible
```

These enable formal statements of the soundness/completeness theorems for each variant.

### 4.4 Repository Organization

No major directory restructuring is recommended short-term. Instead:

1. Add a `Metalogic/Completeness/` directory (or use existing `StagedConstruction/`) for the completeness theorems once wired
2. Add a `Metalogic/DenseCompleteness.lean` top-level file that imports and assembles the dense completeness components
3. Add a `Metalogic/DiscreteCompleteness.lean` when discrete completeness work begins
4. Consider a `Theories/Bimodal/LogicVariants.lean` top-level file that exports the three logic characterizations

---

## Part V: Prioritized Work Plan

### Priority 1 (Blocking): Resolve Task 973 and 974

Tasks 973 (`NoMaxOrder`/`NoMinOrder` on ConstructiveQuotient) and 974 (`SuccOrder`/`PredOrder` on DiscreteTimeline) are prerequisites for completeness work. Resolve these first.

### Priority 2 (Critical): Wire Dense Completeness

The dense completeness theorem is the most mature incomplete result. All components are proven; only the domain transfer step is missing. This likely requires ~4–8 hours of focused work to identify the exact mismatch and construct the transfer.

### Priority 3 (Important): State Base and Discrete Completeness

Once dense completeness is wired:
- State the base completeness theorem (may already follow from the Int-indexed BFMCS construction)
- Begin the discrete completeness framework (using DiscreteTimeline infrastructure)

### Priority 4 (Near-term): Documentation and Explicit Classification

- Update all axiom counts in documentation
- Add `FrameClass` enumeration
- Document the theoretical justification for each classification decision
- Write a Logic Variants guide

### Priority 5 (Long-term): Type-Level Separation

If desired for type safety, introduce separate derivation types per logic variant. This is not blocking for the metalogical results.

---

## Part VI: Conflicts Resolved

### Conflict 1: Are temp_t_future/temp_t_past base axioms?

**Teammate B** noted that in standard tense logic, T-axioms (Gφ→φ) correspond to reflexive frames and are extensions.

**Resolution**: In TM, these are correctly classified as base axioms because TM uses **reflexive temporal semantics** (G/H quantify over ≤, not <). Under reflexive semantics, Gφ→φ is definitionally valid at any time t (since t ≤ t). Teammate A's analysis of the current codebase confirms this design choice (Task 967). The classification is correct.

### Conflict 2: Is temp_4 a base axiom?

**Teammate B** noted that temp_4 (Gφ→GGφ) corresponds to transitivity in standard tense logic.

**Resolution**: Correct as base in TM because linear ordered groups are transitively ordered by definition. The frame class already includes transitivity, so temp_4 is valid on ALL TM frames.

### Conflict 3: Architecture recommendation

**Teammate A** suggested type family approach. **Teammate D** suggested mixin predicates short-term, typeclasses long-term.

**Resolution**: Adopt Teammate D's pragmatic approach. The existing predicate system (`isBase`, `isDenseCompatible`, `isDiscreteCompatible`) is already a working Option B (mixin predicates). Enhance it with `FrameClass` enumeration and derivation validation. Full typeclass migration is Phase 3.

### Conflict 4: Axiom count

**Teammate C** cited "17+" axioms. **Teammate A** enumerated 21 constructors.

**Resolution**: 21 constructors is correct per Teammate A's careful enumeration. The discrepancy reflects additions in Tasks 967, 922, 913 that postdate some documentation.

---

## Part VII: Summary

### Current State Assessment

| Aspect | Current State | Assessment |
|--------|--------------|------------|
| Axiom classification | isBase/isDenseCompatible/isDiscreteCompatible predicates | Correct, needs documentation |
| Base soundness | Fully proven (all 21 axiom validity theorems) | Complete |
| Dense soundness | Fully proven | Complete |
| Discrete soundness | Fully proven | Complete |
| Full derivation soundness | Likely present but verify | Verify |
| Base completeness | Implicit in BFMCS, not stated explicitly | State explicitly |
| Dense completeness | Components proven, wiring missing | Critical gap |
| Discrete completeness | Framework largely absent | Major gap |
| Documentation | Outdated (wrong axiom counts) | Needs update |
| Type-level separation | Absent (predicate-based only) | Enhancement needed |

### Path Forward

The TM logic system is conceptually well-organized but needs the metalogic formalized and made explicit. The best path to a "fully satisfactory logic, semantics with appropriate frame constraints, and metalogical results" is:

1. **Fix blocking sorries** (tasks 973, 974)
2. **Wire dense completeness** — the most mature gap, highest return
3. **State base completeness** — likely already implicit, needs surfacing
4. **Build discrete completeness** — requires more infrastructure
5. **Enhance documentation** — update counts, document the three variants
6. **Optionally** add type-level separation for axiom sets

No major refactoring of the directory structure or axiom type is required near-term. The existing design is sound; what's missing is the completion of metalogical results and explicit documentation of the theoretical structure.

---

## Teammate Contributions

| Teammate | Focus | Status | Confidence |
|----------|-------|--------|------------|
| A | Codebase analysis — axioms, frame conditions, metalogic status | Completed | High |
| B | Theoretical foundations — Kt base, axiom-frame correspondences | Completed | High |
| C | Bimodal semantics — canonical model construction, truth lemma | Completed | High |
| D | Refactoring strategy — architecture options, migration phases | Completed | High |

## References

1. `Theories/Bimodal/ProofSystem/Axioms.lean` — Axiom constructors and classification predicates
2. `Theories/Bimodal/Semantics/TaskFrame.lean` — Frame structure
3. `Theories/Bimodal/Semantics/Validity.lean` — Validity variants
4. `Theories/Bimodal/Metalogic/Soundness.lean` — Axiom validity proofs
5. `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` — Dense completeness status
6. `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` — Truth lemma
7. `Theories/Bimodal/Theorems/Discreteness.lean` — DP derived from DF
8. Teammate B findings: Standard tense logic references (Goldblatt 1992, Blackburn et al. 2001, SEP)
