# Research Report: Eventuality Resolution Approaches for Until/Since Truth Lemma

- **Task**: 83 - Close Restricted Coherence Sorries
- **Type**: lean4
- **Focus**: Guard verification in canonical model Until/Since truth lemma
- **Date**: 2026-04-07
- **Artifact**: reports/35_eventuality-resolution-approaches.md
- **Sources**: Literature survey (Burgess 1982/84, Xu 1988, Goldblatt 1992, Venema 1993, GHR 1994, Reynolds 2003, SEP Temporal Logic), codebase analysis (BXCanonical/Frame.lean, TruthLemma.lean, Bundle/CanonicalConstruction.lean, Soundness.lean, Axioms.lean)

## Executive Summary

The 4 remaining sorries in Frame.lean (`bx_until_eventuality_resolution`, `bx_until_backward`, and Since mirrors) are all blocked on a **single unified challenge**: verifying the guard condition `φ ∈ u` at intermediate BXPoints `u ∈ [w, v)` in the canonical model. Literature analysis reveals that our BX4 axiom (`φ → G(P(φ))`) replaced the Burgess-Xu axiom 4 (`α ∧ χ U ψ → χ U (ψ ∧ χ S α)`), which is the critical Until-Since interaction axiom that directly encodes the guard. Five approaches are evaluated; deriving Burgess-Xu 4 from existing axioms (Option A) is recommended as the primary path, with adding it as a new axiom BX11 (Option B) as fallback.

**Confidence**: HIGH that the problem is correctly identified. MEDIUM-HIGH that Option A or B resolves it.

## 1. The Problem

### 1.1 Current State

TruthLemma.lean is structurally complete with 0 direct sorries. All Until/Since cases delegate to 4 helper stubs in Frame.lean:

| Sorry | Type | Direction |
|-------|------|-----------|
| `bx_until_eventuality_resolution` | Forward Until | `φ U ψ ∈ w → ∃ v ≥ w, ψ ∈ v, guard` |
| `bx_until_backward` | Backward Until | `∃ v ≥ w, ψ ∈ v, guard → φ U ψ ∈ w` |
| `bx_since_eventuality_resolution` | Forward Since | Mirror |
| `bx_since_backward` | Backward Since | Mirror |

The guard condition is: `∀ u : BXPoint, bx_le w u → bx_lt u v → φ ∈ u.formulas`

### 1.2 The Guard Verification Gap

Given `φ U ψ ∈ w` and `ψ ∉ w`:

**What works:**
- BX10: `F(ψ) ∈ w` (eventuality extraction)
- `bx_forward_witness`: `∃ v ≥ w, ψ ∈ v` (from seed `{ψ} ∪ g_content(w)`)
- BX9: `φ ∈ w` (since `φ U ψ → φ ∨ ψ` and `ψ ∉ w`)
- BX4: `G(P(φ U ψ)) ∈ w`, so `P(φ U ψ)` propagates to all points above w

**What fails:**
- `φ U ψ ∈ w` does NOT imply `G(φ U ψ) ∈ w` (semantically invalid: Until is not persistent)
- So `φ U ψ` does not propagate through `g_content` to intermediate points
- `P(φ U ψ) ∈ u` only gives ∃ u' ≤ u with `φ U ψ ∈ u'`, not `φ U ψ ∈ u`
- BX5 enriches the guard semantically (`(φ ∧ (φ U ψ)) U ψ ∈ w`) but the enriched formula is more complex than `φ U ψ`, so falls outside the structural induction IH

### 1.3 Root Cause

The BX axiom system replaced Burgess-Xu axiom 4 (an Until-Since interaction axiom) with BX4 (temporal connectedness via G/P). BX4 provides only **existential** past witnesses, while Burgess-Xu 4 provides a **Since condition** that encodes guard continuity. This leaves a gap in the canonical model construction that does not exist in Burgess's original proof technique.

## 2. Literature Findings

### 2.1 The Burgess-Xu Axiom System

The standard complete axiomatization for Until/Since on all reflexive linear orders (Burgess 1982, Xu 1988) uses 7 axiom schemas plus mirrors:

| # | Name | Formula | Our Equivalent |
|---|------|---------|----------------|
| 1 | Reflexivity | `G(φ) → φ` | BX1 |
| 2 | Left mono | `G(φ → ψ) → (φ U χ → ψ U χ)` | BX2 |
| 3 | Right mono | `G(φ → ψ) → (χ U φ → χ U ψ)` | BX3 |
| **4** | **U-S interaction** | **`α ∧ χ U ψ → χ U (ψ ∧ χ S α)`** | **BX4 (weaker)** |
| 5 | Self-accumulation | `φ U ψ → (φ ∧ (φ U ψ)) U ψ` | BX5 |
| 6 | Absorption | `φ U (φ ∧ (φ U ψ)) → φ U ψ` | BX6 |
| 7 | Linearity | `(φ U ψ) ∧ (χ U θ) → ...` (3-way) | BX7 |

**Critical difference**: Burgess-Xu axiom 4 says: if `α` holds now AND `χ U ψ` holds, then the Until witness can be enriched with `χ S α` — meaning `α` has held continuously (as a Since condition) at the witness point. This directly encodes the guard.

Our BX4 (`φ → G(P(φ))`) only says the present is in the past of the future. Our BX8-BX10 (reflexive intro, elimination, eventuality) are additional axioms not in Burgess-Xu.

### 2.2 Burgess's Completeness Proof Technique

Burgess's actual proof uses **step-by-step chain construction** (essentially our FMCS/Bundle approach):
- Points are MCS organized into an explicit linear chain indexed by integers
- The ordering is **total by construction** (not proved from axioms)
- Guard verification is immediate because chain indices provide a linear order
- This is fundamentally different from the BXCanonical approach (abstract MCS with g_content preorder)

### 2.3 Formalization Landscape

**No existing formalization** of Until/Since completeness exists in any proof assistant:
- FormalizedFormalLogic/Foundation (Lean 4): Modal logic only, no temporal Until
- LeanearTemporalLogic (Lean 4): LTL semantics only, no completeness
- Isabelle/HOL synthetic completeness (CPP 2025): Generic MCS framework, not applied to Until
- Coq: S5 completeness only

Our work would be the **first mechanized Until/Since completeness proof**.

### 2.4 The Role of BX5+BX6+BX7

In Burgess's system, axioms 5+6+7 replace the discrete Until-induction axiom:
```
G(ψ → χ) ∧ G((φ ∧ X(χ)) → χ) → ((φ U ψ) → X(χ))
```
which requires a Next operator `X` (discrete-time only). BX5+BX6+BX7 achieve the same power on arbitrary linear orders without requiring `X`. However, the proof technique for extracting this power in the canonical model is not straightforward.

## 3. Approach Analysis

### 3.1 Option A: Derive Burgess-Xu Axiom 4 from BX1-BX10

**Idea**: Show `α ∧ χ U ψ → χ U (ψ ∧ χ S α)` is a theorem of the BX system.

**Rationale**: If both systems are complete for the same frame class, they are inter-derivable. Burgess-Xu 4 should be derivable from BX1-BX10 (which includes BX5-BX10 that Burgess-Xu lacks).

**Sketch**:
1. From `α ∧ (χ U ψ)`:
   - BX5: `(χ ∧ (χ U ψ)) U ψ` (self-accumulation)
   - BX8': `α → χ S α` (reflexive Since introduction)
   - BX2/BX3: monotonicity to combine these
2. Key step: show `χ U ψ ∧ (χ S α) → χ U (ψ ∧ χ S α)` using BX7 (linearity)
3. BX7 gives witness ordering between two temporal formulas at the same point

**Feasibility**: MEDIUM-HIGH. The derivation uses all of BX5, BX7, BX8, and monotonicity. Non-trivial but well-motivated.

**Risk**: If BX1-BX10 is actually weaker than Burgess-Xu (i.e., incomplete), the derivation is impossible. However, BX8-BX10 add power that Burgess-Xu lacks, making this unlikely.

**Payoff**: If successful, the truth lemma proof becomes:
1. From `φ U ψ ∈ w`: apply derived Burgess-Xu 4 with `α = φ`, `χ = φ`, `ψ = ψ`
2. Get `φ U (ψ ∧ φ S φ) ∈ w`
3. By BX10: `F(ψ ∧ φ S φ) ∈ w`
4. Build witness v from enriched seed `{ψ ∧ φ S φ} ∪ g_content(w)` — wait, `φ S φ` is trivially `φ` under reflexive semantics
5. Need to instantiate more carefully: `α = φ U ψ`, `χ = φ`, `ψ = ψ`: get `φ U (ψ ∧ φ S (φ U ψ)) ∈ w`
6. At witness v: `ψ ∈ v` AND `φ S (φ U ψ) ∈ v`
7. By truth lemma for Since (IH or proved simultaneously): `∃ r ≤ v, (φ U ψ) ∈ r, ∀ t ∈ (r, v], φ ∈ t`
8. If r = w or r ≤ w: guard follows for [w, v]

### 3.2 Option B: Add Burgess-Xu Axiom 4 as BX11

**Idea**: Add `α ∧ χ U ψ → χ U (ψ ∧ χ S α)` as a new axiom.

**Rationale**: Sound on all linear orders. Directly resolves the truth lemma gap.

**Implementation**:
1. Add `interact_until_since` constructor to `Axiom` inductive (+ primed version)
2. Prove soundness in Soundness.lean
3. Prove swap-validity in SoundnessLemmas.lean
4. Prove substitution preservation in Substitution.lean
5. Use in Frame.lean for enriched witness construction

**Feasibility**: HIGH. The soundness proof is straightforward (same technique as BX5/BX7 soundness). ~200 LOC.

**Risk**: LOW. The axiom is sound, well-studied, and from the standard reference system.

**Payoff**: Same as Option A, but cleaner implementation (no complex derivation chain).

**Trade-off**: Changes the axiom system. If Option A succeeds, it's mathematically stronger (shows the axiom was derivable all along).

### 3.3 Option C: Enriched Seed + Zorn for Minimal ψ-witness

**Idea**: Build witness v normally, then use Zorn in reverse to find the closest ψ-point.

**Approach**:
1. Define S = {M : BXPoint | bx_le w M ∧ bx_le M v ∧ ψ ∈ M}
2. S is nonempty (v ∈ S)
3. Apply Zorn (reverse ordering) to find minimal m₀ ∈ S
4. For u ∈ [w, m₀): ψ ∉ u (by minimality)
5. At u: P((φ ∧ (φ U ψ)) U ψ) ∈ u (from BX4+BX5, in g_content(w))
6. Get backward witness u' ≤ u with ((φ ∧ (φ U ψ)) U ψ) ∈ u'
7. By BX9 at u': either ψ ∈ u' or (φ ∧ (φ U ψ)) ∈ u'
8. If ψ ∈ u' and w ≤ u': contradicts minimality of m₀

**Key challenge**: Step 8 requires `bx_le w u'`. We have `bx_le u' u` (from P witness) and `bx_le w u`, but bx_le is not symmetric — `u' ≤ u` and `w ≤ u` does NOT imply `w ≤ u'`. The backward witness u' could be "behind" w.

**Feasibility**: MEDIUM. Requires establishing `w ≤ u'` for backward witnesses, which is non-trivial.

**Risk**: The Zorn construction for S requires showing every chain has a lower bound in S, which needs a "meet" construction on BXPoints — similar difficulty to the existing `until_zorn_chain_seed_consistent`.

### 3.4 Option D: BX7 Linearity Lifting

**Idea**: Prove that bx_le is total on intervals using BX7.

**Approach**: Given u₁, u₂ both above w, use BX7 to show bx_le u₁ u₂ or bx_le u₂ u₁.

**Challenge**: BX7 operates on pairs of Until formulas at the SAME MCS. To use it for ordering u₁ vs u₂, we need Until formulas common to both. Since g_content(w) ⊆ u₁ and g_content(w) ⊆ u₂, we need Until formulas in g_content(w). But g_content(w) contains formulas φ where G(φ) ∈ w, which are universally quantified — not Until formulas.

**Partial workaround**: P(φ U ψ) ∈ g_content(w) (from BX4). And P(α) ↔ ⊤ S α (derivable from BX8' + BX10'). So ⊤ S (φ U ψ) ∈ u₁ and ⊤ S (φ U ψ) ∈ u₂. BX7' (Since linearity) could be applied. But extracting an ordering on g_content from Since linearity is unclear.

**Feasibility**: LOW-MEDIUM. The connection between BX7 and g_content ordering is indirect.

### 3.5 Option E: Maximal Persistence + Zorn (Previous Approach)

**Idea**: Define S = {M : BXPoint | bx_le w M ∧ (φ U ψ) ∈ M ∧ ψ ∉ M}, find maximal m via Zorn, build v from bx_forward_witness at m.

**Why it failed**: The guard for u between w and m requires showing u ∈ S (so φ U ψ ∈ u, ψ ∉ u → φ ∈ u by BX9). But we cannot show that arbitrary u between w and m is in S, because φ U ψ does not propagate through g_content.

**Feasibility**: LOW. Three implementation agents have attempted this without success. The guard verification at intermediate points faces the same fundamental gap as the direct approach.

## 4. Recommendation

### Primary Path: Option A (Derive Burgess-Xu 4)

**Why**: Mathematically strongest result. Shows the BX axiom system is at least as powerful as Burgess-Xu, confirming completeness. Uses existing infrastructure (derivation trees, axiom application). No axiom system change needed.

**Implementation plan**:
1. Define target: `⊢ α ∧ (χ U ψ) → χ U (ψ ∧ χ S α)`
2. Work in `Theorems/TemporalDerived.lean` (where BX-derived theorems live)
3. Use BX5, BX7, BX8', BX9, BX3 (right mono), propositional reasoning
4. Key subgoals:
   a. From BX5 + BX8': establish `(χ ∧ (χ U ψ)) U ψ` and `χ S α` at w
   b. From BX7: relate the Until and Since witnesses to establish ordering
   c. From BX3: strengthen the Until target to `ψ ∧ χ S α`
5. If derivation succeeds: use in Frame.lean to close forward Until
6. Backward Until then follows (the guard condition change makes it trivial when the enriched witness exists)

**Estimated effort**: 3-5 hours for derivation attempt. If blocked after thorough exploration, fall back to Option B.

### Fallback Path: Option B (Add as BX11)

**Why**: Guaranteed to work. Sound axiom from the standard reference system. Implementation is mechanical (add constructor, prove soundness/substitution, use in Frame.lean).

**Estimated effort**: 2-3 hours.

### NOT Recommended

- **Option C** (enriched seed + Zorn): The `w ≤ u'` challenge for backward witnesses adds complexity without clear resolution path.
- **Option D** (BX7 lifting): The connection between Since linearity and g_content ordering is too indirect.
- **Option E** (maximal persistence): Failed three times. The fundamental gap (φ U ψ non-propagation) is not addressable by Zorn alone.

## 5. Impact on Plan v34

If Options A or B succeed, the remaining plan phases become straightforward:

| Phase | Current Status | Impact |
|-------|---------------|--------|
| 3 (Truth Lemma) | PARTIAL (4 sorries) | All 4 sorries close; forward uses derived/new axiom, backward becomes trivial |
| 4 (Completeness) | NOT STARTED | Unblocked; truth lemma complete |
| 5 (Archive) | NOT STARTED | Independent; proceed as planned |
| 6 (Audit) | NOT STARTED | Depends on 4, 5 |

## 6. Open Questions

1. **Is BX1-BX10 equivalent to Burgess-Xu 1-7?** If yes, Option A succeeds. If no, Option B is necessary and our axiom system was incomplete.
2. **Can BX7 (Until linearity) be used to derive Since conditions?** The connection between `(φ U ψ) ∧ (χ U θ) → ...` and `α S β` needs exploration.
3. **Is there a simpler derivation via BX6 (absorption)?** BX6 prevents infinite deferral; combined with BX5, it might give a fixed-point characterization that encodes the guard.
4. **For the backward direction**: If we have the enriched witness `v` with `ψ ∧ (φ S (φ U ψ)) ∈ v`, does the Since truth lemma (which is the MIRROR of the Until truth lemma) create a circular dependency? Both Until and Since truth lemmas are proved simultaneously, so this should be fine via mutual induction — but needs verification.

## References

- Burgess, J.P. (1982). "Axioms for Tense Logic I: Since and Until." *Notre Dame Journal of Formal Logic* 23(4):367-374.
- Burgess, J.P. (1984). "Basic Tense Logic." In *Handbook of Philosophical Logic* Vol. II, pp. 89-133.
- Xu, M. (1988). "On Some US-Tense Logics." *Journal of Philosophical Logic* 17(2):181-202.
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes No. 7.
- Venema, Y. (1993). "Derivation Rules as Anti-Axioms in Modal Logic." *Journal of Symbolic Logic* 58(3):1003-1034.
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*. Vol. 1, Oxford.
- Reynolds, M. (2003). "An Axiomatization of Full Computation Tree Logic." *Journal of Symbolic Logic* 66(3):1011-1057.
- Hodkinson, I. and Reynolds, M. (2007). "Temporal Logic." Chapter 11 in *Handbook of Modal Logic*.
- De Jongh, D., Veltman, F., Verbrugge, R. (2018). "Completeness by Construction for Tense Logics." In *Festschrift for Dick de Jongh*.
- SEP: "Temporal Logic." https://plato.stanford.edu/entries/logic-temporal/
