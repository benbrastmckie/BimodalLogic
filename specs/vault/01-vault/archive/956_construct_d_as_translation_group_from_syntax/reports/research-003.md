# Research Report 003: Archival Analysis and Antisymmetry of the Canonical Relation

**Task**: 956 -- Construct D as translation group from syntax
**Date**: 2026-03-06
**Session**: sess_1772899500_b7c4d8
**Status**: Complete
**Supplements**: research-001.md (theoretical pipeline), research-002.md (codebase audit)

## 1. Executive Summary

This report addresses two goals: (1) identifying files for archival that use trivial `task_rel` or hardcoded `Int` approaches superseded by the translation group construction, and (2) analyzing whether antisymmetry of the canonical temporal relation follows from the axioms.

**Key findings**:

- **Goal 1**: Three files are candidates for Boneyard: `Representation.lean` (trivial task_rel), `DovetailingChain.lean` (2 sorries, superseded by BidirectionalFragment), and `FragmentCompleteness.lean` (2 sorries in Int conversion). Several others contain reusable infrastructure despite using `D = Int`.

- **Goal 2**: CanonicalR is **NOT** antisymmetric from the axioms alone. The codebase already resolves this via `Antisymmetrization` quotient (Mathlib). For the translation group construction, this means the canonical timeline T must be defined as this quotient, not as raw MCSes.

---

## 2. Goal 1: Archival Analysis

### 2.1 Files Using Trivial task_rel

| File | task_rel Pattern | Recommendation |
|------|-----------------|----------------|
| `Metalogic/Representation.lean` | `task_rel := fun _ _ _ => True` (line 100) | **Move to Boneyard** |
| `Semantics/TaskFrame.lean` | `trivialFrame` example (line 115) | **Keep** (example/test code) |
| `Examples/TemporalStructures.lean` | Multiple `fun _ _ _ => True` instances | **Keep** (examples) |

**`Representation.lean` analysis**: This is the primary representation theorem module. It:
- Defines `canonicalFrame B : TaskFrame Int` with trivial task_rel (line 98-102)
- Proves `standard_representation`, `standard_weak_completeness`, `standard_strong_completeness`
- Inherits sorry from `construct_saturated_bfmcs_int` (which itself depends on `fully_saturated_bfmcs_exists_int`)
- Uses `BFMCS Int` throughout (hardcoded Int as duration type)

**Verdict**: The entire module is structured around trivial task_rel and hardcoded `D = Int`. The translation group construction replaces BOTH of these. **Move to Boneyard** once the new construction is in place. Note: this file is imported by `Metalogic.lean` (the umbrella module) and `Examples/Demo.lean`.

### 2.2 Files Using Hardcoded Int

| File | Int Usage | Status | Recommendation |
|------|-----------|--------|----------------|
| `Bundle/DovetailingChain.lean` | `FMCS Int` construction | 2 sorries (forward_F, backward_P) | **Move to Boneyard** |
| `Bundle/CanonicalConstruction.lean` | `TaskFrame Int`, non-trivial task_rel | sorry-free | **Refactor** |
| `Bundle/CanonicalCompleteness.lean` | `BFMCS Int` scaffold | 2 sorry (F-persistence) | **Keep and Refactor** |
| `Bundle/CanonicalChain.lean` | `FMCS Int` via chain | sorry-free | **Keep and Refactor** |
| `Bundle/FragmentCompleteness.lean` | `BFMCS Int` from fragment | 2 sorry (F-persistence) | **Move to Boneyard** |
| `Bundle/TemporalCoherentConstruction.lean` | `FMCS Int` temporal properties | sorry-free (modulo upstream) | **Keep and Refactor** |

### 2.3 DovetailingChain Analysis

**File**: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

- **Size**: Very large (1900+ lines)
- **Status**: 2 sorries remaining (forward_F at line 1869, backward_P at line 1881)
- **Problem**: The F-persistence obstacle is fundamental -- F-formulas do not persist through GContent seeds in a linear chain construction
- **Superseded by**: BidirectionalFragment approach (which solves F/P at the fragment level)
- **Imported by**: `TemporalCoherentConstruction.lean`, `CanonicalFrame.lean`, `CanonicalFMCS.lean`

**Complication**: DovetailingChain is imported by three other modules. Before moving to Boneyard, these imports must be redirected. Specifically:
- `TemporalCoherentConstruction.lean` imports it for `dovetailingFMCS` (the temporal coherent family construction)
- `CanonicalFrame.lean` imports it for `forward_temporal_witness_seed_consistent` and `backward_temporal_witness_seed_consistent`
- `CanonicalFMCS.lean` imports it for witness seed consistency lemmas

**Recommendation**: Move to Boneyard but first extract the still-needed lemmas (witness seed consistency) into a standalone module. The dovetailing index functions and chain construction itself are fully superseded.

### 2.4 FragmentCompleteness Analysis

**File**: `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean`

- **Status**: 2 sorries (forward_F at line 460, backward_P at line 471)
- **Problem**: Converting fragment-level sorry-free FMCS to `FMCS Int` hits the same F-persistence obstacle
- **Imported by**: Nothing (leaf module)
- **Recommendation**: **Move to Boneyard**. The fragment-level FMCS (`fragmentFMCS` in `CanonicalCompleteness.lean`) is sorry-free and reusable; the Int conversion in this file is not.

### 2.5 Files to Keep and Refactor

| File | Reusable Infrastructure | Refactoring Needed |
|------|------------------------|-------------------|
| `CanonicalConstruction.lean` | Non-trivial `canonical_task_rel`, `CanonicalTaskFrame`, truth lemma | Change `D = Int` to `D = Aut+(T)` |
| `CanonicalCompleteness.lean` | `fragmentFMCS`, enriched seed consistency, `GContent_eq_of_preorder_equiv`, diamond witness construction | Adapt BFMCS construction to new D |
| `CanonicalChain.lean` | `CanonicalChain` structure, `forwardChainStep`, `backwardChainStep` | Reusable as-is for building timeline T |
| `CanonicalFrame.lean` | `CanonicalR`, `canonical_forward_F`, `canonical_backward_P`, transitivity | Reusable as-is (core infrastructure) |
| `CanonicalFMCS.lean` | sorry-free forward_F/backward_P at CanonicalMCS level | Reusable as-is |
| `BidirectionalReachable.lean` | Fragment definition, totality, `Antisymmetrization` quotient | Reusable -- THIS IS the timeline T |
| `TemporalCoherentConstruction.lean` | Temporal backward properties (G/H backward via contraposition) | Redirect DovetailingChain imports |

### 2.6 Summary Table

| File | Action | Reason |
|------|--------|--------|
| `Representation.lean` | Boneyard | Trivial task_rel, hardcoded Int, entire approach superseded |
| `DovetailingChain.lean` | Boneyard (after import extraction) | 2 sorries, F-persistence fundamental, superseded by BidirectionalFragment |
| `FragmentCompleteness.lean` | Boneyard | 2 sorries, Int conversion blocked, leaf module |
| `CanonicalConstruction.lean` | Refactor | Good structure, change D type |
| `CanonicalCompleteness.lean` | Refactor | Much reusable infrastructure |
| `CanonicalChain.lean` | Keep | Directly useful for timeline construction |
| `BidirectionalReachable.lean` | Keep | IS the timeline T (after quotient) |
| Others (CanonicalFrame, CanonicalFMCS, etc.) | Keep | Core infrastructure, sorry-free |

---

## 3. Goal 2: Antisymmetry of the Canonical Relation

### 3.1 The Question

Given the canonical relation `w < w'` defined as `GContent(w) ⊆ w'` (where `GContent(M) = {phi | G(phi) in M}`), can we prove antisymmetry:

> If `GContent(w) ⊆ w'` and `GContent(w') ⊆ w`, then `w = w'`?

### 3.2 Answer: NO, CanonicalR is Not Antisymmetric

CanonicalR is a **preorder** (reflexive + transitive) but NOT a partial order. Two distinct MCSes can be mutually CanonicalR-related without being equal.

**Why not**: An MCS `w` contains much more than just `GContent(w)` and `HContent(w)`. It contains all propositional formulas, modal formulas (Box/Diamond), and their boolean combinations. Two MCSes can agree on all G-formulas and H-formulas but disagree on, say, `Box p` or propositional `p`.

**Concrete scenario**: Consider two MCSes `w` and `w'` such that:
- `GContent(w) = GContent(w')` (same G-formulas)
- `HContent(w) = HContent(w')` (same H-formulas)
- But `Box(p) in w` and `Box(p) not in w'`

This is possible because the modal and temporal dimensions are partially independent. The G/H axioms constrain how temporal content relates across MCSes, but Box content can vary independently (subject to modal axioms at each individual MCS).

### 3.3 What the Axioms DO Give Us

From `GContent_eq_of_preorder_equiv` (proven in `CanonicalCompleteness.lean:471-484`):

> If `CanonicalR w w'` and `CanonicalR w' w`, then `GContent(w) = GContent(w')`.

This uses the Temporal 4 axiom (`G(phi) -> G(G(phi))`):
1. `G(phi) in w` implies `G(G(phi)) in w` (by Temp 4)
2. `G(G(phi)) in w` implies `G(phi) in w'` (by CanonicalR w w')
3. Symmetrically for the other direction

Similarly, `HContent_eq_of_preorder_equiv` shows `HContent(w) = HContent(w')`.

But equal GContent + equal HContent does NOT imply `w = w'`.

### 3.4 The Relevant Axioms and Their Role

| Axiom | Statement | Role in Canonical Relation |
|-------|-----------|---------------------------|
| T4 (Temporal 4) | `G(phi) -> G(G(phi))` | Makes CanonicalR transitive |
| TT-G | `G(phi) -> phi` | Makes CanonicalR reflexive |
| TT-H | `H(phi) -> phi` | Makes CanonicalR_past reflexive |
| TA | `phi -> G(P phi)` | Connects present to future-past; NOT relevant for antisymmetry |
| TF | `Box(phi) -> G(Box(phi))` | Box persistence; NOT relevant for antisymmetry |
| MF | `Box(phi) -> Box(G(phi))` | Modal-temporal interaction; NOT relevant for antisymmetry |
| Linearity | `F(phi) & F(psi) -> ...` | Makes CanonicalR total (on reachable fragment); NOT relevant for antisymmetry |

**Critical observation about TA**: The axiom `phi -> G(Pphi)` (where `P` = `sometime_past` = existential) says "if phi now, then at all future times, phi happened at some past time." This does NOT help with antisymmetry because:
- It talks about existential past (`P` = `neg H neg`), not universal past
- It connects the present to a future-past relationship, not two present MCSes
- The dual `phi -> H(Fphi)` similarly does not help

**No combination of the listed axioms can prove antisymmetry.** The temporal axioms (T4, TT, TA, TL) govern how G/H content propagates. The modal axioms (MT, M4, MB, M5, MK) govern Box/Diamond at a single world. The interaction axioms (MF, TF) connect these. But none force two MCSes with the same temporal content to be identical.

### 3.5 How the Codebase Handles This

The codebase resolves the lack of antisymmetry via **Mathlib's `Antisymmetrization` quotient** (imported in `BidirectionalReachable.lean`):

```
abbrev BidirectionalQuotient (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :=
  Antisymmetrization (BidirectionalFragment M0 h_mcs0) (. <= .)
```

This quotient identifies preorder-equivalent elements (those with `a <= b` and `b <= a`). The quotient inherits:
- `PartialOrder` from `Antisymmetrization` (antisymmetry by construction)
- `LinearOrder` from fragment totality (`bidirectional_totally_ordered`)

### 3.6 Implications for the Translation Group Construction

For task 956's translation group construction:

1. **The canonical timeline T** should be defined as `BidirectionalQuotient M0 h_mcs0` (the antisymmetrization quotient), NOT as raw MCSes. This is already done in the codebase.

2. **Well-definedness of operations on T**: The quotient works because preorder-equivalent elements have the same GContent and HContent (proven in `GContent_eq_of_preorder_equiv` and `HContent_eq_of_preorder_equiv`). This means:
   - `fragmentGSucc` is well-defined on the quotient (proven in `fragmentGSucc_eq_of_preorder_equiv`)
   - `fragmentHPred` is similarly well-defined on the quotient

3. **D = Aut+(T)**: The translation group should be the group of order-preserving automorphisms of `T = BidirectionalQuotient M0 h_mcs0`. Since T has a `LinearOrder`, this is a well-defined group.

4. **The designated origin**: The equivalence class of `M0` in the quotient serves as the designated origin, defining how D acts on T.

---

## 4. Consolidated Recommendations

### 4.1 Immediate Actions (Before Implementation)

1. **Create Boneyard directory**: `Theories/Bimodal/Metalogic/Boneyard/`
2. **Move `Representation.lean`** to Boneyard (update imports in `Metalogic.lean` and `Demo.lean`)
3. **Move `FragmentCompleteness.lean`** to Boneyard (no importers)
4. **Extract witness seed lemmas** from `DovetailingChain.lean` into a standalone module, then move DovetailingChain to Boneyard

### 4.2 Implementation Path

5. **Use `BidirectionalQuotient`** as the canonical timeline T
6. **Define D = Aut+(T)** using the `LinearOrder` on the quotient
7. **Construct canonical_task_rel** from the group action (replacing trivial task_rel)
8. **Adapt `CanonicalConstruction.lean`** truth lemma for the new D type

### 4.3 Risk Assessment

- **Import extraction from DovetailingChain**: Medium complexity. Three files import it; the needed lemmas must be identified and relocated.
- **Antisymmetry is resolved**: The quotient approach is already implemented and proven. No new mathematical work needed here.
- **F-persistence obstacle**: NOT resolved by the translation group approach. The challenge of converting fragment-level FMCS to FMCS over a linearly ordered D persists. The translation group construction must either (a) work at the fragment level directly, or (b) find a novel solution to F-persistence.

---

## 5. Files Referenced

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation.lean` -- trivial task_rel, hardcoded Int, Boneyard candidate
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- 2 sorries, superseded, Boneyard candidate
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` -- 2 sorries, leaf module, Boneyard candidate
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- non-trivial task_rel, sorry-free, refactor target
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` -- fragment infrastructure, reusable
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` -- chain construction, reusable
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` -- IS the timeline T, Antisymmetrization quotient
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` -- core CanonicalR infrastructure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` -- sorry-free forward_F/backward_P
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` -- 17 axiom schemata
