# Teammate C Findings: Extensibility Analysis — Discrete/Dense Extensions and Completeness Architecture

**Task**: 83 — Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Focus**: Frame hierarchy design, completeness architecture, forward_F in extensibility context, code reuse assessment, clean extension points

---

## Key Findings

### 1. The Codebase Already Has a D-Parametric Architecture That Works

The most important finding is that the existing codebase already implements the right architectural pattern for extensibility. The `ParametricRepresentation.lean` module proves a D-parametric algebraic representation theorem where the duration type D is a **parameter**, not constructed from syntax. The completeness hierarchy is already sketched:

| Extension | D | Additional Typeclass Constraints | Additional Axioms |
|-----------|---|--------------------------------|-------------------|
| Base | Int | `AddCommGroup + LinearOrder + IsOrderedAddMonoid` | 18 base axioms |
| Dense | Rat | `+ DenselyOrdered + Nontrivial` | base + density DN |
| Discrete | Int | `+ SuccOrder + PredOrder + IsSuccArchimedean + IsPredArchimedean + Nontrivial` | base + DF + seriality |

This is documented in `BaseCompleteness.lean`, `DenseCompleteness.lean`, and `DiscreteCompleteness.lean`, which already exist as interface modules. The pattern is sound.

### 2. The Burgess-Xu Axiom System Radically Simplifies the Extension Story

Report 32 identifies that switching to the Burgess-Xu (BX) axiom system with all-reflexive semantics has a profound impact on extensibility:

- **Base BX is complete for ALL linear orders** — no density/discreteness axioms needed for the base
- Under reflexive G, the density axiom `G(G(phi)) -> G(phi)` is **trivially derivable** from BX1
- The discrete axiom formulation under reflexive U/S needs redesign (current `F(top) -> bot U top` becomes trivially valid when U is reflexive)
- **Net effect**: The base system becomes genuinely universal, and extensions add frame-specific structure on top

### 3. Forward_F Dissolves Under Burgess-Xu (No Next Operator)

The forward_F circularity is fundamentally tied to the successor-chain construction, which requires the Next operator. The BX completeness proof uses an entirely different eventuality resolution mechanism:

- **BX5 (Self-Accumulation)**: `phi U psi -> (phi & (phi U psi)) U psi` — eventualities propagate
- **BX6 (Absorption)**: `phi U (phi & (phi U psi)) -> phi U psi` — eventualities resolve

Together, BX5 and BX6 give `phi U psi <-> (phi & phi U psi) U psi`, enabling witness construction for Until-formulas without deterministic successor steps. The canonical model uses maximal chains of MCS (via Zorn's lemma or transfinite construction), not successor chains.

**This eliminates the forward_F problem entirely for the base logic.** The problem reappears only if one wants discrete completeness with a step-by-step chain construction, which is an extension-specific concern.

### 4. The Semantic Change Is Minimal But Foundational

Report 32 Section 8.6 identifies that switching U/S from strict to reflexive requires changing exactly one comparison in `Truth.lean`:

- Current: `t < s` (strict witness for Until), `s < t` (strict witness for Since)
- Proposed: `t <= s` (reflexive witness), `s <= t` (reflexive witness)
- Guard intervals remain identical: open `(t, s)` for Until, `(s, t)` for Since

This is a single-line semantic change per operator, but it cascades through all soundness proofs referencing U/S.

### 5. Current Sorry Map Aligns with Extension Boundaries

| Sorry Location | Count | Extension Layer | Status Under BX |
|---------------|-------|-----------------|-----------------|
| `deterministic_forward_F` | 1 | Discrete-only (chain construction) | **Eliminated** (no chain needed for base) |
| `deterministic_backward_P` | 1 | Discrete-only (chain construction) | **Eliminated** (symmetric) |
| `F_until_equiv_valid` (Soundness.lean:770) | 1 | Semantic mismatch (mixed semantics) | **Eliminated** (becomes a theorem under reflexive U/S) |
| `P_since_equiv_valid` (Soundness.lean:786) | 1 | Semantic mismatch (mixed semantics) | **Eliminated** (symmetric) |
| forward Until in `usc` | 1 | Depends on forward_F | **Eliminated** |
| forward Since in `usc` | 1 | Depends on backward_P | **Eliminated** |
| Discrete Soundness sorries | ~14 | Discrete-only axioms | **Moved** to discrete extension |
| Density axiom sorry | 1 | Dense-only | **Eliminated** (derivable from BX1) |

**Net effect**: All current sorries either dissolve or are properly scoped to their extension layer.

---

## Recommended Approach

### Frame Hierarchy Design (Lean Typeclasses)

The existing `TaskFrame D` structure is already parameterized correctly. The extension mechanism should use Lean's typeclass system on D:

```
Layer 0: TaskFrame D
  Constraints: [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  Logic: BX base (7 schemas x 2 mirrors + S5 + interaction)
  Completeness: BX canonical model (maximal chains, BX5/BX6 eventuality resolution)

Layer 1a: Discrete extension
  Additional: [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D]
  Additional: [NoMaxOrder D] [NoMinOrder D]
  Logic: BX base + discrete axioms (DF + seriality)
  Completeness: Successor chain construction (current DeterministicChain.lean architecture)
  Note: Next/Previous become DERIVED operators: X(phi) = bot U phi, Y(phi) = bot S phi
        (well-defined under reflexive U/S on discrete frames — bot U phi at t means
        exists s >= t with phi(s) and bot on (t,s), forcing s to be the successor of t)

Layer 1b: Dense extension
  Additional: [DenselyOrdered D] [Nontrivial D]
  Logic: BX base (density axiom is derivable from BX1 under reflexive G)
  Completeness: BX canonical model (same as base — density adds no new axiom)
  Note: Dense completeness is actually BASE completeness restricted to dense models
```

**Key architectural insight**: Under BX with reflexive semantics, dense completeness requires NO additional axioms. The density axiom `G(G(phi)) -> G(phi)` is derivable from BX1 (`G(phi) -> phi`) by instantiating with `G(phi)`. This means `DenseCompleteness.lean` can simply re-export `BaseCompleteness.lean` with the additional `DenselyOrdered` constraint on D.

### Completeness Architecture

**Shared components** (survive across all frame classes):
1. `ParametricRepresentation.lean` — D-parametric representation theorem (already exists, already sorry-free modulo temporal coherence)
2. `ParametricTruthLemma.lean` — D-parametric truth lemma (already exists)
3. `ParametricCanonical.lean` — D-parametric TaskFrame and TaskModel
4. `ParametricHistory.lean` — D-parametric history conversion
5. `Bundle/CanonicalConstruction.lean` — MCS extension, Lindenbaum
6. `Bundle/Construction.lean` — Consistency/provability bridge
7. `Bundle/ModalSaturation.lean` — Box saturation across families
8. `Algebraic/BooleanStructure.lean` — Boolean algebra on MCS
9. `Algebraic/LindenbaumQuotient.lean` — Quotient construction
10. `Algebraic/TenseS5Algebra.lean` — Algebraic semantics

**Divergence points**:

| Component | Base/Dense (BX) | Discrete (BX + DF) |
|-----------|----------------|-------------------|
| Temporal coherence proof | BX5/BX6 eventuality resolution via maximal chains | Successor chain + forward_F/backward_P |
| FMCS construction | Non-deterministic (maximal chain of MCS) | Deterministic (x_content chain) |
| Forward_F/backward_P | Not needed (handled by BX5/BX6 in the model construction) | Required (the current sorry location) |
| Domain characterization | Any LOAG (parametric) | Z via `orderIsoIntOfLinearSuccPredArch` |

**Parameterization strategy**: The `BFMCS` bundle and `FMCS` family already parameterize over D. The temporal coherence property (`B.temporally_coherent`) abstracts over how forward_F/backward_P are established. For the BX approach, temporal coherence would be proven using BX5/BX6 instead of successor chains.

### The Forward-F Problem in Context

**For base/dense completeness under BX**: The forward_F problem does not exist. The BX completeness proof constructs the canonical model differently — it builds a maximal chain of MCS where Until-eventualities are resolved by BX5/BX6. There is no deterministic successor chain, so there is no circularity between forward_F and backward_G.

**For discrete completeness**: Forward_F reappears in a different form. The successor chain construction requires showing that F-obligations in the chain are eventually witnessed. However, under BX + discrete axioms:
- X(phi) = bot U phi is well-defined (reflexive U on discrete frames gives X the right semantics)
- The DF axiom (`(F(top) & phi & H(phi)) -> F(H(phi))`) provides the key frame property
- The chain construction can potentially use BX5/BX6 + DF for eventuality resolution

**Critical observation**: The tuple-based construction from Report 30 maps cleanly onto the BX approach. Tuples correspond to MCS restricted to subformula closure. Tasks correspond to unfulfilled eventualities. BX5/BX6 provide the mechanism for eventuality resolution that the tuple construction needed but couldn't formalize within the strict-U successor-chain paradigm.

### Current Code Reuse Assessment

**Survives intact** (~60% of metalogic code):
- All of `Algebraic/` except `DeterministicChain.lean`, `DeterministicFMCS.lean`, `FiniteDeferral.lean`, `DovetailedChain.lean`
- All of `Bundle/` except files tied to successor chain specifics (`SuccChainFMCS.lean`, `SuccChainTaskFrame.lean`, `SuccChainTruth.lean`, `SuccChainWorldHistory.lean`, `SuccExistence.lean`, `SuccRelation.lean`)
- `Core/` directory entirely (MCS properties, Lindenbaum, etc.)
- `Decidability/` mostly (FMP infrastructure)
- `Relational/` entirely
- `ConservativeExtension/` entirely
- `Semantics/` almost entirely (only `Truth.lean` changes 2 lines)

**Needs modification** (~15%):
- `Truth.lean`: Change U/S witness from strict to reflexive (2 lines)
- `Soundness.lean`: Re-prove U/S soundness lemmas, add BX2-BX7 soundness
- `Axioms.lean`: Replace discrete axioms with BX axioms, update `isBase`/`isDenseCompatible`/`isDiscreteCompatible`
- `BaseCompleteness.lean`, `DenseCompleteness.lean`, `DiscreteCompleteness.lean`: Update proof strategy

**Needs major rewrite or replacement** (~25%):
- `DeterministicChain.lean`, `DeterministicFMCS.lean`: Currently the core of completeness; under BX, replaced by maximal chain construction
- `FiniteDeferral.lean`: Infrastructure for forward_F; under BX, replaced by BX5/BX6 eventuality resolution
- `DovetailedChain.lean`: Obsolete
- `SuccChain*.lean` files: Tied to successor-chain paradigm

**Migration complexity estimate**: 2000-3000 LOC of new code (BX axiom soundness, eventuality resolution, maximal chain construction), replacing ~2500 LOC of current sorry-laden code. Net LOC change approximately zero, but sorry count goes from ~20 to potentially 0 for the base system.

### Clean Extension Points

The following parameterization hooks are needed:

1. **Axiom Classification** (already exists but needs update):
   - `Axiom.isBase` → true for BX1-BX7 + mirrors + S5 + interaction
   - `Axiom.isDiscreteCompatible` → true for base + DF + seriality
   - `Axiom.isDenseCompatible` → true for base (= isBase, since density is derivable)
   - `Axiom.frameClass` → `Base | Discrete` (Dense collapses to Base under BX)

2. **Temporal Coherence Abstraction** (already exists):
   - `BFMCS.temporally_coherent` abstracts forward_F/backward_P
   - Base/dense: proven via BX5/BX6 maximal chain
   - Discrete: proven via successor chain + DF

3. **Domain Constraint Abstraction** (already exists):
   - `valid` quantifies over all D with `AddCommGroup + LinearOrder + IsOrderedAddMonoid`
   - `valid_dense` adds `DenselyOrdered + Nontrivial`
   - `valid_discrete` adds `SuccOrder + PredOrder + IsSuccArchimedean + IsPredArchimedean + Nontrivial`

4. **Eventuality Resolution** (NEW — needs creation):
   - A typeclass or structure for "how Until-eventualities are resolved"
   - Base/dense: BX5/BX6 self-accumulation/absorption
   - Discrete: successor chain forward_F

5. **Derived Operator Registry** (NEW — needs creation):
   - Base: F(phi) = ~G(~phi), P(phi) = ~H(~phi), equivalently F(phi) = top U phi
   - Discrete extension adds: X(phi) = bot U phi, Y(phi) = bot S phi
   - Dense extension adds: nothing new

6. **Completeness Proof Wiring** (partially exists):
   - `parametric_algebraic_representation_conditional` already takes a BFMCS and produces the completeness result
   - Each extension provides its own BFMCS construction
   - The wiring in `BaseCompleteness.lean` / `DenseCompleteness.lean` / `DiscreteCompleteness.lean` connects extension-specific BFMCS to the parametric representation

---

## Evidence/Examples

### Evidence 1: Existing D-Parametric Architecture

From `ParametricRepresentation.lean`:
```
| Extension | D   | Constraint                              | BFMCS Construction                          |
|-----------|-----|-----------------------------------------|---------------------------------------------|
| Base      | Int | AddCommGroup + LinearOrder + IsOrderedAddMonoid | temporal_coherent_family_exists_CanonicalMCS |
| Dense     | Rat | + DenselyOrdered                        | Same, with density axiom in MCSs             |
| Discrete  | Int | + SuccOrder                             | Same, with discreteness axiom in MCSs        |
```

This table from the existing code confirms the architecture is already designed for extension.

### Evidence 2: Semantic Change Minimality

From `Truth.lean` lines 127-130:
```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

Change to:
```lean
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

Only the witness condition changes (`<` to `≤`). Guard intervals remain open `(t, s)` and `(s, t)`.

### Evidence 3: Sorry Elimination Path

Current Soundness.lean sorries (line numbers from grep):
- Line 770: `F_until_equiv_valid` — becomes a theorem under reflexive U/S
- Line 786: `P_since_equiv_valid` — symmetric
- Line 1182: `density` — derivable from BX1
- Lines 1183-1195: All discrete-specific axioms — moved to discrete extension

All base axiom soundness proofs (BX1-BX7) are semantically straightforward (verified in Report 32 Section 8).

### Evidence 4: Existing Extension Interface

From `DiscreteCompleteness.lean`, the discrete extension already:
1. Documents required SuccOrder/PredOrder instances
2. Identifies the gap (sorries in `DiscreteTimeline.lean`)
3. Provides the completeness hierarchy diagram
4. Notes that discrete and dense are incompatible extensions

This infrastructure needs only adaptation, not creation from scratch.

---

## Confidence Levels

| Section | Confidence | Rationale |
|---------|------------|-----------|
| Frame Hierarchy Design | **HIGH** | Existing D-parametric architecture confirms feasibility; typeclass-based extension is standard Lean 4 pattern |
| Completeness Architecture (shared components) | **HIGH** | Existing code already separates shared from extension-specific; parametric truth lemma is proven |
| Completeness Architecture (BX eventuality resolution) | **MEDIUM** | BX5/BX6 approach is well-established in literature (Burgess 1982, Xu 1988) but has not been formalized in Lean; the formalization is non-trivial |
| Forward_F Elimination | **HIGH** | The forward_F problem is structurally tied to the successor-chain construction; BX completeness does not use successor chains |
| Code Reuse Assessment | **HIGH** | Based on direct reading of all relevant files and their dependency structure |
| Migration Complexity | **MEDIUM** | LOC estimates are approximate; BX5/BX6 formalization complexity is uncertain |
| Clean Extension Points | **HIGH** | Most hooks already exist; only eventuality resolution abstraction is genuinely new |

---

## Summary Recommendation

The Burgess-Xu axiom system with all-reflexive semantics is the right foundation for the extensibility refactor. The key reasons:

1. **It eliminates all current sorries at the base level** — F_until_equiv becomes a theorem, forward_F becomes unnecessary
2. **The existing D-parametric architecture is already designed for this** — only the BFMCS construction and temporal coherence proof need replacement
3. **Dense completeness collapses to base completeness** — no additional axiom needed under reflexive G
4. **Discrete completeness becomes a clean extension** — adds DF + seriality + SuccOrder, uses successor chains only within the discrete layer
5. **The semantic change is minimal** — two comparison operators in Truth.lean

The main risk is the formalization of BX5/BX6 eventuality resolution for the base completeness proof. This is well-understood mathematically but has not been formalized in Lean 4. Estimated effort: 1500-2000 LOC for the new base completeness proof, offset by deletion of ~2500 LOC of current sorry-laden infrastructure.
