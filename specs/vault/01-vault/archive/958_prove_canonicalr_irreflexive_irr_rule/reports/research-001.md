# Research Report: Task #958 - CanonicalR Irreflexivity via IRR Rule

- **Task**: 958 - prove_canonicalr_irreflexive_irr_rule
- **Created**: 2026-03-10
- **Source**: Derived from Task 956 Phase 6 handoff (phase-6-handoff-20260310.md)
- **Artifacts**: specs/958_prove_canonicalr_irreflexive_irr_rule/reports/research-001.md (this file)

## Problem Statement

Task 956 Phase 6 (Cantor Isomorphism Application) is blocked on proving the Mathlib Cantor prerequisites for the antisymmetrized quotient `TimelineQuot`. Specifically:

- **NoMaxOrder**, **NoMinOrder**, and **DenselyOrdered** all require that `CanonicalR` is **irreflexive** — i.e., no MCS relates to itself via `CanonicalR`.

Without irreflexivity, a reflexive MCS (where `CanonicalR(M, M)` holds) may be maximal in the quotient ordering, preventing `NoMaxOrder`. The same issue blocks `NoMinOrder` and `DenselyOrdered` (strict density requires intermediates that are *strictly* between two points).

### The Blocker in Detail

The antisymmetrized quotient `Antisymmetrization DenseTimelineElem (·≤·)` gives a `LinearOrder`. For `Order.iso_of_countable_dense` (Mathlib's Cantor isomorphism), all six prerequisites are needed:
- LinearOrder ✓
- Countable ✓
- Nonempty ✓
- NoMaxOrder ✗ — requires irreflexivity
- NoMinOrder ✗ — requires irreflexivity
- DenselyOrdered ✗ — requires strict intermediates (which require irreflexivity)

The Boneyard at `RestrictedFragment.lean:434-444` documents this exact blocker from a prior approach.

## The Theorem to Prove

```lean
theorem canonicalR_irreflexive
    (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    ¬CanonicalR M M
```

**Location**: `Theories/Bimodal/Metalogic/Canonical/` or `StagedConstruction/`

**Definition of CanonicalR** (from CanonicalR.lean):
```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  GContent M ⊆ M'
```
where `GContent M = { phi | Formula.all_future phi ∈ M }`.

So `CanonicalR M M` means `GContent M ⊆ M`, i.e., all G-formulas in M have their arguments in M.

## Proof Strategies

### Strategy A: Direct via Axioms (Promising)

In the irreflexive temporal semantics, the `G` modality is for *strict* future. No time is in its own strict future. Therefore, at the canonical MCS level, if `G(phi) ∈ M` then `phi ∉ M` should hold for *some* `phi`.

**Key observation**: If `CanonicalR(M, M)` holds, then `GContent(M) ⊆ M`. This means every `G(phi)` that is in M also has `phi ∈ M`. But by the density axiom `F(phi) → F(F(phi))` (equivalently `G(neg phi) → G(G(neg phi))`), combined with the seriality axiom (there is always a future), this should create a contradiction.

**Concretely**: Take the formula `G(⊥)` — "always false in the future". If `G(⊥) ∈ M` then seriality gives contradiction (there must be a future point satisfying ⊥). If `G(⊥) ∉ M`, then since M is maximal consistent, `F(⊤) ∈ M` or equivalently some F-formula holds. Then there exists a G-formula whose content is not in M.

Actually, a cleaner argument:
- Any MCS M contains `¬G(phi) → F(¬phi)` as a theorem (contrapositive of K-axiom).
- The density axiom gives `F(phi) → F(F(phi))`.
- Consider `neg(G(phi)) ∨ F(neg(phi))` — this is a theorem.

This approach may require careful case analysis. The direct route may need the IRR rule.

### Strategy B: Via the IRR Rule (Recommended)

The Gabbay IRR rule (`DerivationTree.irr`) added in Task 957 is sound on irreflexive frames. It can be used to derive contradictions from the assumption `CanonicalR(M, M)`.

**Proof sketch**:

Assume `CanonicalR(M, M)`, i.e., `GContent(M) ⊆ M`. Let `p` be a fresh atom not appearing in any formula of M.

By IRR (with any conclusion `phi` not mentioning `p`), from:
```
⊢ (p ∧ H(¬p)) → phi
```
we can conclude `⊢ phi`.

The key insight: In any MCS M satisfying `CanonicalR(M, M)`, the formula `¬(p ∧ H(¬p))` is either in M or not. If it IS derivable (which it should be in an irreflexive system — no world can name itself), and M is consistent, then...

Actually, the more direct IRR-based approach:

The IRR rule proves soundness of the system on irreflexive frames. For the canonical model to satisfy the soundness theorem, the canonical model must itself be on an irreflexive frame. Hence `CanonicalR` must be irreflexive.

But this is circular reasoning. The soundness proof (which task 957 partially proved as `irr_sound_dense_at_domain`) is for the SEMANTIC level. To use it at the syntactic/canonical model level, we need to connect the two.

**Concrete approach via IRR**:

Choose a fresh `p` (not in `M`). Derive `⊢ (p ∧ H(¬p)) → ¬G(p)`:
- Under assumption `p ∧ H(¬p)`: `p` holds now, `¬p` held at all past times
- `G(p)` would mean `p` holds at all future times. But by density axiom, there is a future time that is also a past time of some further future, at which `¬p` holds. This is a contradiction.

Actually this argument gets complex. Let me state the simplest approach.

### Strategy C: Contradiction from Axioms (Potentially Simplest)

If `CanonicalR(M, M)`, then `GContent(M) ⊆ M`. In particular, for any `G(phi) ∈ M`, we have `phi ∈ M`.

Consider the axiom `G(phi) → F(phi)` (seriality/density):
- `G(phi) → phi` would be the T-axiom (reflexivity), which is NOT in the axiom system for irreflexive semantics.

But `G(phi) → F(phi)` IS an axiom (seriality: there is always a strict future). And `F(phi) → F(F(phi))` (density axiom).

From `G(phi) ∈ M`, we get `F(phi) ∈ M` (by seriality in M). But from `F(phi) ∈ M`, we need `phi ∈ some future MCS` — this goes to other MCS's, not M itself.

Now suppose `CanonicalR(M, M)`. This means the FUTURE of M (in the canonical model) includes M itself. The density axiom says between any two future points there's another. Between M and M (same point), there should be an intermediate — which would be a distinct MCS strictly between M and itself. This is impossible.

But this requires lifting the density argument from syntax to the canonical model level, which is what we're trying to prove.

### Strategy D: Use StagedConstruction Semantics

Since we have `DenseTimeline.lean` establishing a dense linear ordered set at the CanonicalR level (non-strict), we can argue:

- The dense timeline is built from MCSs
- If CanonicalR(M, M), then M is a "fixed point" under CanonicalR
- In a dense timeline with seriality, fixed points create contradictions
- Specifically: `dense_timeline_has_future` gives some N with CanonicalR(M, N)
- If N = M (in the quotient), then NoMaxOrder fails at [M]
- But `dense_timeline_has_intermediate` should give another point strictly between M and N=M...

This circular argument reveals the core issue: we need irreflexivity to break the circularity.

## Key Files

- `Theories/Bimodal/ProofSystem/Derivation.lean:149` — IRR rule definition
- `Theories/Bimodal/Metalogic/Canonical/CanonicalR.lean` — CanonicalR definition and properties
- `Theories/Bimodal/Metalogic/Canonical/MCSProperties.lean` — MCS properties
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` — Phase 5 output
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` — Phase 6 partial
- `Theories/Bimodal/Boneyard/Task956_IntRat/RestrictedFragment.lean:414-463` — prior blocker documentation
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` — Task 957 output

## What This Task Needs to Produce

A Lean proof of:
```lean
theorem canonicalR_irreflexive
    (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    ¬CanonicalR M M
```

Located in a new file `Theories/Bimodal/Metalogic/Canonical/CanonicalRIrreflexive.lean` (or added to `CanonicalR.lean` or `MCSProperties.lean`).

**Once proven**, this unblocks:
1. Task 956 Phase 6 (`CantorApplication.lean`): all three missing prerequisites (NoMaxOrder, NoMinOrder, DenselyOrdered) follow from irreflexivity
2. Task 956 Phases 7-8 (D construction, TaskFrame, completeness)

## Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Direct axiom proof insufficient | HIGH | MEDIUM | Fall back to IRR-based proof |
| IRR rule application requires careful freshness argument | MEDIUM | LOW | Formula.atoms function available |
| Proof reveals deeper logical issue | HIGH | LOW | Document and escalate to user |
| Axiom system doesn't actually force irreflexivity | HIGH | LOW | Check axiom list carefully; density + seriality should suffice |

## Recommendation

1. **Start with Strategy A** (direct from axioms): Try to derive a contradiction from `CanonicalR(M, M)` using the density axiom `F(phi) → F(F(phi))` and seriality. This avoids the IRR rule machinery.

2. **If Strategy A is blocked after ~1 hour**: Switch to a hybrid of Strategy B (IRR) + the canonical model soundness connection.

3. **Last resort**: If neither works, the "bulldozing" alternative mentioned in the Phase 6 handoff (product domain T × Q) eliminates reflexive points by fiat — but this requires significant restructuring of the Cantor approach.

## Connection to Task 956

This task directly unblocks Task 956 Phase 6. Once `canonicalR_irreflexive` is proven:
- `CantorApplication.lean`'s three sorry stubs can be filled in
- The `TimelineQuot` quotient satisfies all Cantor prerequisites
- `Order.iso_of_countable_dense` applies
- Phases 7-8 can proceed

**File to modify**: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` (Phase 6 partial, has sorry stubs for NoMaxOrder, NoMinOrder, DenselyOrdered)
