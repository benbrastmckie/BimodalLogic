# Research Report: Task #83 — Clean-Break Refactor Design

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Mode**: Team Research (4 teammates)
**Session**: sess_1775597392_9a0f1a

## Summary

Four teammates analyzed reports 29-32 and the full codebase to design a comprehensive clean-break refactor of the bimodal temporal logic TM. The unanimous finding: the forward_F circularity that has blocked 31 rounds of research is **structural** — an artifact of the successor-chain construction — and can only be resolved by replacing the completeness architecture entirely. The Burgess-Xu (BX) axiom system with all-reflexive semantics is the recommended foundation, providing mathematical correctness, elegance, and clean extensibility to both discrete and dense frames.

---

## 1. Root Cause: Why 31 Rounds Failed

All four teammates independently confirmed the same structural diagnosis:

**The invariant failure signature**: Every approach that attempts to derive `G(¬ψ) ∈ chain(t)` from the meta-level fact "¬ψ ∈ chain(s) for all s > t" is blocked by the same circularity. The conversion requires `temporal_backward_G_with_fwd_F`, which takes `forward_F` as a hypothesis — creating a cycle with sizeof that increases rather than decreases.

This circularity manifests identically across dovetailed chains, deterministic chains, quasimodels, tuple constructions, finite deferral cycles, and F-nesting induction. The root cause is three interacting design choices:

1. **Mixed semantics**: G/H reflexive (≥/≤) but U/S strict (>/<) — no published proof handles this combination
2. **Deterministic successor chain**: x_content determines successor deterministically, making F-resolution PULL-based while the construction is PUSH-based
3. **Next-based Until axioms**: until_unfold/intro/induction use X(φ) = ⊥ U φ, which under mixed semantics creates the unsound F_until_equiv

**All three must be addressed together** for a sound, complete system.

---

## 2. The Recommended Refactor: Burgess-Xu with All-Reflexive Semantics

### 2.1 Semantic Change (2 lines in Truth.lean)

Switch U/S from strict to reflexive witness. The guard interval remains open:

```lean
-- BEFORE (strict witness, open guard):
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ

-- AFTER (reflexive witness, open guard):
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

**Key consequences**:
- When s = t, the guard (t, t) is empty, so φ U ψ at t holds iff ψ holds at t
- F(φ) ↔ ⊤ U φ becomes a **semantic theorem** (not an axiom), resolving F_until_equiv
- X(φ) = ⊥ U φ collapses to φ on dense orders (guard (t, s) nonempty for s > t, forcing ⊥ — only s = t works). On discrete orders, X(φ) = φ(t) ∨ φ(succ(t)) — recoverable with discrete extension axioms
- **Guard intervals remain open** `(t, s)` throughout — no half-open intervals are introduced

**Confidence**: HIGH (all 4 teammates agree; this is exactly Burgess 1982 semantics)

### 2.2 Axiom System Replacement

Replace the current 35-constructor `Axiom` inductive with ~25 constructors organized in four layers:

**Layer 1: Classical Propositional (4, KEEP)**
- prop_k, prop_s, ex_falso, peirce

**Layer 2: S5 Modal (5, KEEP)**
- modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist

**Layer 3: Burgess-Xu Temporal (14 = 7 schemas × 2 mirrors, NEW)**

| Schema | Name | Formula | Purpose |
|--------|------|---------|---------|
| BX1/BX1' | temp_t_future/past | G(φ) → φ / H(φ) → φ | Reflexivity (KEEP existing) |
| BX2/BX2' | left_mono_until/since | (φ → χ) → (φ U ψ → χ U ψ) | Left monotonicity |
| BX3/BX3' | right_mono_until/since | (φ → χ) → (ψ U φ → ψ U χ) | Right monotonicity |
| BX4/BX4' | connect_until_since | φ ∧ (χ U ψ) → χ U (ψ ∧ (χ S φ)) | Connectedness |
| BX5/BX5' | self_accum_until/since | φ U ψ → (φ ∧ (φ U ψ)) U ψ | Self-accumulation |
| BX6/BX6' | absorb_until/since | φ U (φ ∧ (φ U ψ)) → φ U ψ | Absorption |
| BX7/BX7' | linear_until/since | (φ U ψ) ∧ (χ U θ) → ... | Linearity |

**Layer 4: Modal-Temporal Interaction (2, KEEP)**
- modal_future: □(φ) → □(G(φ))
- temp_future: □(φ) → G(□(φ))

**REMOVED** (all derivable from BX or frame-specific):
- temp_k_dist (derivable from BX1 + NEC_G)
- temp_4 (derivable from BX1 + NEC_G)
- temp_a, temp_a_dual (derivable from BX4)
- temp_l (derivable)
- temp_linearity (subsumed by BX7)
- density (trivially derivable from BX1 under reflexive G)
- ALL 16 discrete axioms: discreteness_forward, seriality_*, disc_next/prev, until_unfold/intro/induction, since_unfold/intro/induction, until/since_linearity, until/since_connectedness, F_until_equiv, P_since_equiv

**Inference rules** (KEEP): MP, NEC_Box, NEC_G, NEC_H

**Key derived principles** (proved as theorems, not axioms):
- G(φ) distributes over → (from BX1 + NEC_G + prop_k)
- G(φ) → G(G(φ)) (from BX1 + NEC_G)
- φ → G(P(φ)) (from BX4)
- F(φ) ↔ ⊤ U φ (semantic equivalence under reflexive U)

**Confidence**: HIGH (standard Burgess-Xu system plus S5, well-documented in literature)

### 2.3 Why BX Dissolves the Forward-F Problem

The BX completeness proof does NOT use:
- Next/Previous operators
- Deterministic successor chains
- forward_F / backward_G lemmas

Instead, it resolves Until-eventualities using:
- **BX5 (Self-Accumulation)**: φ U ψ → (φ ∧ (φ U ψ)) U ψ — enriches the guard while preserving the eventuality
- **BX6 (Absorption)**: φ U (φ ∧ (φ U ψ)) → φ U ψ — prevents infinite deferral by collapsing intermediate steps

The canonical model truth lemma for G uses MCS negation completeness directly: if G(φ) ∉ w then F(¬φ) ∈ w, so there exists v ≥ w with ¬φ ∈ v — contradicting the hypothesis that φ holds at all future points. **No forward_F needed.**

The forward_F circularity was an artifact of trying to BUILD a model and then VERIFY G/F properties. The BX approach DEFINES the canonical ordering so that G/F properties hold by construction.

**Confidence**: HIGH (all 4 teammates agree this is a genuine departure from the failure pattern)

---

## 3. Unsoundness Audit

### 3.1 Confirmed Unsound Axioms (2)

| Axiom | Location | Sorry | Root Cause |
|-------|----------|-------|------------|
| F_until_equiv | Axioms.lean:608, Soundness.lean:770 | Yes | F(ψ) includes witness s=t but U requires s>t |
| P_since_equiv | Axioms.lean:617, Soundness.lean:786 | Yes | Mirror |

### 3.2 Dependency Chain

```
F_until_equiv (UNSOUND)
  → G_implies_topUntil (TemporalDerived.lean:58)
    → G_implies_X (TemporalDerived.lean:110)  [LOAD-BEARING]
      → g_content_propagates_to_x_content (DeterministicChain.lean:323)
        → forward_G_int, forward_G, chain infrastructure (7+ files)
      → x_nec', XH_implies_self, X_bot_absurd
      → UltrafilterChain.lean, Bundle/TemporalContent.lean, Bundle/WitnessSeed.lean

P_since_equiv (UNSOUND)
  → H_implies_Y (TemporalDerived.lean:143)  [LOAD-BEARING, mirror]
    → h_content_propagates_to_y_content, backward_H_int, backward_H
    → y_nec', YG_implies_self, Y_bot_absurd
```

### 3.3 What Is NOT Affected

All propositional, S5 modal, perpetuity, G/H-only temporal, and discrete-specific axioms (those not touching F↔U or P↔S conversion) are sound. The unsoundness is confined to the F_until_equiv/P_since_equiv dependency chain.

**Confidence**: HIGH (Teammate B traced all dependencies via grep)

---

## 4. Canonical Model Construction Design

### 4.1 The "Tuple" Mapping

The user's tuple-based construction maps precisely to the BX canonical model:

| User's Tuple Concept | BX Canonical Model | Current Codebase |
|-----------------------|-------------------|-----------------|
| Tuple (state) | MCS in canonical frame | SetMaximalConsistent |
| Task (eventuality) | Until-formula needing witness | F(ψ) ∈ M |
| Timeline | Maximal chain of MCS | deterministic_chain |
| Duration resolution | BX5/BX6 eventuality resolution | forward_F (sorry) |
| Constraint satisfaction | Canonical model truth lemma | succ_chain_truth_forward |

Tuples ARE MCS. Tasks ARE eventualities. Duration resolution IS what BX5/BX6 provide axiomatically.

### 4.2 Canonical Frame Structure

```lean
-- New: Metalogic/BXCanonical/Frame.lean
structure BXCanonicalPoint where
  formulas : Set Formula
  is_mcs : SetMaximalConsistent formulas

def canonical_temporal_le (w v : BXCanonicalPoint) : Prop :=
  ∀ φ, φ.all_future ∈ w.formulas → φ ∈ v.formulas

def canonical_modal_equiv (w v : BXCanonicalPoint) : Prop :=
  ∀ φ, Formula.box φ ∈ w.formulas ↔ Formula.box φ ∈ v.formulas
```

### 4.3 Eventuality Resolution (the key new component)

BX5 gives: if φ U ψ ∈ w, then (φ ∧ (φ U ψ)) U ψ ∈ w — at intermediate points, both φ holds AND the eventuality persists.

BX6 gives: absorption prevents infinite deferral — if the eventuality can be deferred to a point where it still holds, the two-step resolution collapses to one.

Combined with Zorn's lemma on chains of MCS, this constructs a maximal chain where every Until-eventuality is resolved.

### 4.4 Truth Lemma Architecture

The truth lemma φ ∈ w ↔ M_canonical, w ⊨ φ proceeds by induction on formula structure:
- **atom, ⊥, →, □**: Standard MCS arguments (reuse existing infrastructure)
- **G(φ) forward**: BX1 (reflexivity) + canonical ordering definition
- **G(φ) backward**: MCS negation completeness (G(φ) ∉ w → F(¬φ) ∈ w → contradiction)
- **φ U ψ forward**: BX5/BX6 eventuality resolution (**hardest case**)
- **φ U ψ backward**: BX4 (connectedness) + MCS properties

**Confidence**: MEDIUM-HIGH for the architecture, MEDIUM for the Until cases

---

## 5. Extensibility Architecture

### 5.1 Frame Hierarchy

The existing D-parametric architecture (TaskFrame D, parametric representation) already supports this. Under BX:

| Layer | Frame Class | D Constraints | Additional Axioms | Completeness |
|-------|------------|---------------|-------------------|-------------|
| Base | All linear orders | AddCommGroup + LinearOrder + IsOrderedAddMonoid | BX1-BX7 + S5 + interaction | BX canonical model |
| Dense | Dense orders | + DenselyOrdered + Nontrivial | Base only (density derivable from BX1) | = Base completeness |
| Discrete | Discrete orders | + SuccOrder + PredOrder + IsSuccArchimedean + ... | Base + DF + seriality | Successor chain (future work) |

**Critical insight**: Under BX with reflexive G, the density axiom G(G(φ)) → G(φ) is trivially derivable from BX1 (G(φ) → φ, instantiate with G(φ)). Dense completeness is simply base completeness restricted to dense models — **no additional axioms needed**.

### 5.2 Clean Extension Points

1. **Axiom Classification** (update existing): isBase → BX + S5 + interaction; isDiscreteCompatible → base + DF + seriality; isDenseCompatible → = isBase
2. **Temporal Coherence Abstraction** (exists): BFMCS.temporally_coherent — base proves via BX5/BX6, discrete proves via successor chain
3. **Domain Constraint Abstraction** (exists): valid/valid_dense/valid_discrete already parameterize over D
4. **Eventuality Resolution** (NEW): typeclass or structure for how Until-eventualities are resolved
5. **Derived Operator Registry** (NEW): F(φ) = ⊤ U φ (base), X(φ) = ⊥ U φ (discrete extension only)

**Confidence**: HIGH (most hooks already exist; only eventuality resolution is genuinely new)

---

## 6. Migration Analysis

### 6.1 Files That Survive Unchanged

| Category | Files | Reason |
|----------|-------|--------|
| Syntax | Formula.lean, Atom.lean, Context.lean | No semantic dependency |
| Semantics | TaskFrame.lean, TaskModel.lean, WorldHistory.lean, Validity.lean | Frame-agnostic |
| Core Metalogic | MaximalConsistent.lean, DeductionTheorem.lean, Core.lean | Pure proof theory |
| Algebraic | BooleanStructure.lean, LindenbaumQuotient.lean, TenseS5Algebra.lean, InteriorOperators.lean, UltrafilterMCS.lean | Reusable infrastructure |
| Theorems | All Propositional/, ModalS5.lean, ModalS4.lean, Perpetuity.lean | No temporal U/S dependency |
| Other | Relational/, ConservativeExtension/, Decidability/ (mostly) | Orthogonal |

### 6.2 Files That Need Modification

| File | Change | Effort |
|------|--------|--------|
| Truth.lean | `t < s` → `t ≤ s` for U/S witness (2 lines) | ~50 LOC (re-prove lemmas) |
| Axioms.lean | Replace 35 constructors with ~25 BX constructors | ~200 LOC |
| Derivation.lean | Minor inference rule updates | ~50 LOC |
| Soundness.lean | New soundness proofs for BX2-BX7 (14 axioms) | ~400 LOC |
| SoundnessLemmas.lean | Update bridge theorems | ~200 LOC |
| MCSProperties.lean | Add BX-specific MCS properties | ~300 LOC |
| Substitution.lean | Update axiom match cases | ~50 LOC |
| FrameConditions/Compatibility.lean | Update compatibility instances | ~50 LOC |

### 6.3 Files That Get Replaced (New Completeness Proof)

| Old Files | New Files | Description |
|-----------|-----------|-------------|
| Bundle/SuccChain*.lean (6 files) | BXCanonical/Frame.lean | Canonical frame definition |
| DeterministicChain.lean | BXCanonical/Ordering.lean | Canonical temporal ordering |
| DeterministicFMCS.lean | BXCanonical/TruthLemma.lean | BX truth lemma |
| FiniteDeferral.lean | BXCanonical/EventualityResolution.lean | BX5/BX6 witness construction |
| DovetailedChain.lean | BXCanonical/Completeness.lean | Final completeness theorem |
| SuccChainCompleteness.lean | (wired through BXCanonical/) | Base completeness |

### 6.4 Scope Estimates

| Component | LOC (new) | LOC (deleted) | Confidence |
|-----------|-----------|---------------|------------|
| Semantic change + axiom replacement | 600-800 | ~500 (old axioms) | HIGH (90%) |
| BX axiom soundness proofs | 400-600 | ~200 (old sorry proofs) | HIGH (85%) |
| BX canonical model completeness | 1500-2500 | ~2500 (chain code) | MEDIUM (60%) |
| Derived theorem recovery | 200-400 | ~200 (old derivations) | HIGH (85%) |
| Match exhaustiveness updates | 200-300 | — | HIGH (90%) |
| **Total** | **2900-4600** | **~3400** | — |

---

## 7. Conflicts Resolved

### Conflict 1: Phasing Strategy

**Teammates A/C**: Full BX refactor, semantics first, then completeness.
**Teammate B**: Option E' first (immediate), reflexive semantics later.
**Teammate D**: Experimental module first, hard decision gates.

**Resolution**: The user explicitly requested "cutting no corners, deferring nothing that makes good sense to include in a clean-break refactor." This favors the full BX approach (A/C). However, D's validation-first strategy is prudent engineering. **Recommendation**: Full BX refactor, structured in validation-gated phases. No Option E' intermediate step — go directly to BX axioms with reflexive semantics, but validate BX soundness proofs before investing in completeness.

### Conflict 2: Guard Intervals

**Teammate A**: Open guards (t, s) throughout — no half-open intervals.
**Teammate D**: Concern about half-open [t, s) boundaries causing soundness issues.

**Resolution**: A is correct. The guard intervals are and remain open (t, s). Only the witness condition changes from strict (s > t) to reflexive (s ≥ t). D's concern is based on a mischaracterization — reflexive witness with open guard is NOT the same as half-open intervals. The current codebase (Truth.lean:127-128) uses `t < r → r < s` for the guard, which is open (t, s), and this does NOT change. **No half-open interval concern exists.**

### Conflict 3: Completeness Confidence

**Teammate A**: 60% confidence in BX completeness.
**Teammate C**: MEDIUM confidence, well-understood but never formalized.
**Teammate D**: 30-40% that completeness can be completed in reasonable time.

**Resolution**: The spread (30-60%) reflects genuine uncertainty. BX completeness has never been formalized in any proof assistant. However, even at 30%, this dramatically outperforms the chain-based approach (~5% after 31 failed rounds). The validation-gated approach mitigates: if BX soundness proofs succeed, completeness confidence rises; if they fail, we stop early. **Recommendation**: Proceed with BX, but treat completeness as high-risk and structure phases to validate early.

### Conflict 4: Chain Infrastructure Preservation

**Teammate A**: Replace chain files with new BX modules.
**Teammate D**: Keep chain code in Boneyard/, don't delete until proven.

**Resolution**: For a clean-break refactor, the chain code should be removed from the build path but preserved in version control (it's always recoverable via git). No Boneyard/ directory needed — git history serves this purpose. **Recommendation**: Remove chain files from the build, but do this in a separate commit after the new completeness proof compiles.

---

## 8. Gaps Identified

1. **BX4 semantic verification**: Report 32's verification of BX4 (connectedness) was noted as incomplete by Teammate D. The plan should include a rigorous BX4 soundness proof as an early validation step.

2. **G(φ) = φ U φ derivation**: Teammate A claims this identification holds under reflexive semantics. Teammate D notes it hasn't been formally proven from BX axioms. This is a critical derived principle — if it fails, G-distribution may need to remain an axiom.

3. **Zorn's lemma in Lean**: The BX completeness proof requires Zorn's lemma for maximal chain construction. Mathlib provides `zorn_subset_nonempty` and related results, but wiring them to the MCS chain context needs verification.

4. **Interaction axiom re-verification**: modal_future and temp_future should be re-verified under reflexive U/S semantics. Since G/H semantics don't change, this should be straightforward but wasn't explicitly checked.

5. **Test coverage**: No semantic test suite exists for BX axioms on finite models. Creating one would provide early validation.

---

## 9. Complete Change Catalog

This section lists every change that should be included in the clean-break refactor.

### 9.1 Semantic Layer

| # | Change | File(s) | Type |
|---|--------|---------|------|
| S1 | Switch Until witness from `t < s` to `t ≤ s` | Truth.lean | 2-line edit |
| S2 | Switch Since witness from `s < t` to `s ≤ t` | Truth.lean | 2-line edit |
| S3 | Re-prove all Truth.lean lemmas affected by the witness change | Truth.lean | ~50 LOC |
| S4 | Prove F(φ) ↔ ⊤ U φ as semantic theorem | Truth.lean or new file | ~30 LOC |

### 9.2 Proof System Layer

| # | Change | File(s) | Type |
|---|--------|---------|------|
| P1 | Replace Axiom inductive (35 → ~25 constructors) | Axioms.lean | ~200 LOC |
| P2 | Update axiom classification (isBase, isDense, isDiscrete) | Axioms.lean | ~50 LOC |
| P3 | Update frame class assignment | Axioms.lean | ~30 LOC |
| P4 | Update substitution lemma for new axiom constructors | Substitution.lean | ~50 LOC |
| P5 | Update inference rules if needed | Derivation.lean | ~50 LOC |

### 9.3 Soundness Layer

| # | Change | File(s) | Type |
|---|--------|---------|------|
| SD1 | Remove F_until_equiv_valid / P_since_equiv_valid sorries | Soundness.lean | Delete |
| SD2 | Prove soundness of BX2-BX7 (12 new axioms; BX1/BX1' already proved) | Soundness.lean | ~400 LOC |
| SD3 | Update SoundnessLemmas for new axiom cases | SoundnessLemmas.lean | ~200 LOC |
| SD4 | Update FrameConditions/Compatibility | Compatibility.lean | ~50 LOC |

### 9.4 Derived Theorems Layer

| # | Change | File(s) | Type |
|---|--------|---------|------|
| D1 | Prove G-distribution from BX1 + NEC_G | New or TemporalDerived.lean | ~50 LOC |
| D2 | Prove G-transitivity from BX1 + NEC_G | New or TemporalDerived.lean | ~30 LOC |
| D3 | Prove φ → G(P(φ)) from BX4 | New or TemporalDerived.lean | ~50 LOC |
| D4 | Prove φ → H(F(φ)) from BX4' | New or TemporalDerived.lean | ~50 LOC |
| D5 | Remove/simplify G_implies_X, H_implies_Y (no longer needed for base) | TemporalDerived.lean | Simplify |
| D6 | Remove G_implies_topUntil (no longer needed) | TemporalDerived.lean | Delete |

### 9.5 Completeness Layer (New BX Architecture)

| # | Change | File(s) | Type |
|---|--------|---------|------|
| C1 | BX canonical frame definition | BXCanonical/Frame.lean | ~200 LOC |
| C2 | Canonical temporal ordering + linearity (from BX7) | BXCanonical/Ordering.lean | ~300 LOC |
| C3 | Eventuality resolution (BX5 + BX6 + Zorn) | BXCanonical/EventualityResolution.lean | ~500 LOC |
| C4 | Truth lemma (induction on formula) | BXCanonical/TruthLemma.lean | ~400 LOC |
| C5 | Final completeness theorem | BXCanonical/Completeness.lean | ~200 LOC |
| C6 | Wire to BaseCompleteness.lean | BaseCompleteness.lean | ~100 LOC |
| C7 | Wire to DenseCompleteness.lean (= base, no new axioms) | DenseCompleteness.lean | ~50 LOC |

### 9.6 Cleanup Layer

| # | Change | File(s) | Type |
|---|--------|---------|------|
| X1 | Remove chain construction files from build | DeterministicChain, DeterministicFMCS, FiniteDeferral, DovetailedChain | Remove from lakefile |
| X2 | Remove SuccChain bundle files from build | Bundle/SuccChain*.lean (6 files) | Remove from lakefile |
| X3 | Update UltrafilterChain.lean (remove x_content/y_content dependencies) | UltrafilterChain.lean | Modify or remove |
| X4 | Update Bundle/TemporalContent.lean | TemporalContent.lean | Modify |
| X5 | Update all remaining match exhaustiveness | ~5 files | Mechanical |
| X6 | Update tests | Tests/ | Adapt |

### 9.7 Future Extension Hooks (included now, implemented later)

| # | Change | File(s) | Type |
|---|--------|---------|------|
| E1 | Eventuality resolution typeclass/structure | New file | ~50 LOC |
| E2 | Derived operator registry (F = ⊤ U, X = ⊥ U for discrete) | New or existing | ~30 LOC |
| E3 | Discrete extension axiom stubs (DF + seriality + SuccOrder) | DiscreteCompleteness.lean | Update |

---

## 10. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| BX completeness harder than expected | 70% | HIGH | Validate BX soundness first; phase completeness with decision gate |
| Reflexive U/S creates new soundness gaps | 30% | MEDIUM | Guards remain open (t,s) — no half-open intervals; semantic test suite |
| Chain infrastructure loss before new proof works | 40% | HIGH | Git preserves everything; separate deletion commit after new proof compiles |
| BX4 or BX7 soundness proof harder than expected | 50% | MEDIUM | Prove these first as validation gate |
| Pattern match cascade from Axiom type change | 40% | LOW | Single commit with all updates; lake build catches all |

---

## 11. Recommendations

### What to Include in the Clean-Break Refactor

1. **ALL semantic changes** (S1-S4): Switch to reflexive U/S
2. **ALL axiom system changes** (P1-P5): Replace with BX + S5
3. **ALL soundness proofs** (SD1-SD4): Sorry-free BX soundness
4. **ALL derived theorem recovery** (D1-D6): Prove key principles from BX
5. **BX completeness architecture** (C1-C7): New canonical model
6. **Cleanup** (X1-X6): Remove chain infrastructure after new proof works
7. **Extension hooks** (E1-E3): Prepare for discrete/dense extensions

### Validation-Gated Phase Structure

**Phase 1** (Semantics + Axioms + Soundness): ~1200-1600 LOC
- S1-S4, P1-P5, SD1-SD4, D1-D6
- **Validation gate**: All BX axioms have sorry-free soundness proofs, lake build passes

**Phase 2** (BX Completeness): ~1500-2500 LOC
- C1-C7
- **Validation gate**: Completeness theorem compiles (may have internal sorries initially)

**Phase 3** (Integration + Cleanup): ~300-500 LOC
- X1-X6, E1-E3
- **Validation gate**: Full lake build clean, sorry count reduced

### What NOT to Do

- Do NOT apply Option E' as an intermediate step — go directly to BX (the user wants a clean break, not patches)
- Do NOT delete chain code before Phase 2 completes
- Do NOT change the Formula inductive type (keep untl/snce constructors)
- Do NOT attempt to fix forward_F within the chain architecture (31 failed rounds is sufficient evidence)

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Semantic refactor design | completed | HIGH (Phase 1), MEDIUM (Phase 2) | Complete BX canonical model design with Lean type signatures |
| B | Unsoundness audit + axiom system | completed | HIGH | Full dependency chain trace, exact Lean code for replacements |
| C | Extensibility architecture | completed | HIGH | Frame hierarchy, extension points, code reuse assessment |
| D | Devil's advocate + feasibility | completed | HIGH (strategy), MEDIUM (timelines) | Failure pattern analysis, top 5 risks, phased strategy |

---

## References

- Burgess, J. P. (1982). "Axioms for tense logic II: Time periods"
- Xu, M. (1988). "On some U,S-tense logics" (completeness proof for BX over all linear orders)
- Reports 29-32 in specs/083_close_restricted_coherence_sorries/reports/
