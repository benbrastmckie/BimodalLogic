# Implementation Summary: D Construction from Canonical Timeline (2026-03-10b)

- **Task**: 956 - Construct D as translation group from syntax
- **Plan**: implementation-012.md (v012)
- **Status**: PARTIAL (hard blocker on Phase 2B)
- **Session**: sess_1741624800_a3f2c9
- **Iteration**: 2

## What Was Attempted

### Phase 2B: NoMaxOrder/NoMinOrder on ConstructiveQuotient

The ConstructiveFragment.lean file had two sorries at lines 579 and 584, requiring:
- `NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀)`: for all `⟦w⟧`, exists `b > ⟦w⟧`
- `NoMinOrder (ConstructiveQuotient M₀ h_mcs₀)`: for all `⟦w⟧`, exists `b < ⟦w⟧`

These reduce to: given MCS w in the constructive fragment, find MCS b in the fragment with `CanonicalR w.val b.val ∧ ¬CanonicalR b.val w.val` (and vice versa for min).

## Blocker Analysis

### Root Cause: G-closed/G-complete MCS Problem

The proof requires showing that a forward witness (from seriality `F(¬⊥)`) produces a STRICTLY greater element in the Antisymmetrization quotient. This means not just `CanonicalR M W` (which `executeForwardStep` provides), but also `¬CanonicalR W M`.

`¬CanonicalR W M` means `∃ ψ, G(ψ) ∈ W ∧ ψ ∉ M` (some G-content of W is not in M).

### Why This Cannot Be Proven

1. **Lindenbaum non-constructivity**: The forward witness W is obtained via `lindenbaumMCS_set(seed)` = `Classical.choose(set_lindenbaum seed)`. We only know W extends the seed `{φ} ∪ GContent(M)` and is MCS. We have NO control over which G-formulas end up in W.

2. **G-complete MCS possibility**: An MCS M where `φ ∈ M ↔ G(φ) ∈ M` (every true formula is always-true and vice versa) is consistent with all axioms including seriality and density. For such an M, every forward witness W satisfies `CanonicalR M W ∧ CanonicalR W M`, making them equivalent in the quotient. This is the exact blocker identified in `Theories/Bimodal/Boneyard/Task956_IntRat/RestrictedFragment.lean` lines 432-444.

3. **Temporal T-axiom absence**: The axiom `G(φ) → φ` is NOT in the system (removed in task 782, correctly — it is unsound for strict-future semantics where G quantifies over `s > t`). Without it, `GContent(M) ⊆ M` is not guaranteed, but this doesn't help prove `GContent(W) ⊄ M` for a specific witness W.

4. **Temporal T-axiom would not help**: Even if re-added, the T-axiom makes `GContent(M) ⊆ M` hold for ALL M, making the problem WORSE (the Boneyard's irreflexive case `GContent(M) ⊄ M` becomes vacuous, forcing us into the blocked G-closed case).

### Boneyard Historical Context

The Boneyard at `RestrictedFragment.lean:446-463` has the SAME sorry with an identical analysis:
- The irreflexive case (`GContent(a) ⊄ a`) was solved by `no_max_helper_irrefl`
- The reflexive case (`GContent(a) ⊆ a`) was marked BLOCKED
- The Boneyard solution was a product construction `RestrictedQuotient × Q` (bulldozing) in `TemporalDomain.lean`

## Axioms Investigated

- `seriality_future: F(¬⊥)` — gives forward witness, but not strict
- `seriality_past: P(¬⊥)` — gives backward witness, but not strict
- `density: F(φ) → F(F(φ))` — gives intermediate witnesses, still not strict
- `temp_a: φ → G(Pφ)` — explored extensively, cannot produce contradictions with G-completeness
- `temp_4: G(φ) → G(G(φ))` — helps propagate G-formulas but not break symmetry
- `temp_linearity` — explored for two-successor arguments, no help

## Recommended Path Forward

### Option A: Product/Bulldozing Construction (RECOMMENDED)
Adopt the Boneyard's `TemporalDomain = RestrictedQuotient × Q` approach. Even if the quotient has no strict successors (singleton), the product `{[M₀]} × Q ≅ Q` inherits all properties from Q. Truth depends only on the MCS component, preserving logical content. This requires:
- Redefine D as `ConstructiveQuotient × Q` (or just `Q` if quotient is trivial)
- Redefine task_rel to use Q-displacement
- Re-derive truth lemma for the product model

### Option B: Reflexive Semantics Overhaul
Change `all_future` to quantify over `s ≥ t` instead of `s > t`. This makes G(φ) → φ sound, allows adding temporal T-axioms, and CanonicalR becomes reflexive. However, this requires revising ALL soundness proofs and the entire truth lemma.

### Option C: Prove G-complete MCSs Don't Exist
Find a deeper argument (possibly using temp_linearity or density more cleverly) to show that no MCS in the constructive fragment can be G-complete. This would resolve the blocker within the current framework but requires novel mathematical insight.

## Files Modified
- None (sorries remain at lines 579, 584 of `ConstructiveFragment.lean`)

## Files Analyzed
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` (lines 573-585)
- `Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean` (seriality, density)
- `Theories/Bimodal/ProofSystem/Axioms.lean` (all 15 axiom schemata)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (CanonicalR definition, transitivity)
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (GContent, HContent dualities)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (Lindenbaum construction)
- `Theories/Bimodal/Boneyard/Task956_IntRat/RestrictedFragment.lean` (same blocker, same sorry)
- `Theories/Bimodal/Boneyard/Task956_IntRat/TemporalDomain.lean` (bulldozing solution)
- `Theories/Bimodal/Semantics/Truth.lean` (strict-future semantics confirmation)
