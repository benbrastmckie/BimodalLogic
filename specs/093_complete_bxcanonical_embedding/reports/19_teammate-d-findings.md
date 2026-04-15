# Teammate D Findings: Bilateral Pairs — Strategic Horizons

## Key Findings

### 1. Project Roadmap Context

The roadmap is unambiguous: the project goal is to achieve `lake build` with zero sorry on the active completeness path, unblocking `bx_completeness` at `Completeness.lean:154`. There is exactly **1 active sorry** (task 93). The roadmap does not mention bilateral semantics; the publication direction is BX completeness for TM as-is. The roadmap also notes that tasks 98+102 closed Until/Since via a sophisticated Hintikka quasimodel with defect-discharge — a pattern that took ~4 tasks and hundreds of hours of infrastructure to develop.

### 2. What "Bilateral Pairs" Would Actually Mean Here

The user's proposal is to use bilateral pairs `⟨V, F⟩` where V = set of true formulas, F = set of false formulas, with extended semantics via `true_at` + `false_at`. In classical logic, this is essentially Hintikka sets / signed tableaux — since a classical MCS already determines truth and falsity completely (φ ∈ M ↔ ¬φ ∉ M), any MCS already implicitly encodes a bilateral pair. The V-component of an MCS-based bilateral pair is just the MCS itself; the F-component is its complement.

The question is: **does making V and F explicit give us new proof-theoretic leverage for the chain construction?**

**Critical observation**: The forward_F problem is not about truth/falsity of formulas in the canonical world — it is about the *temporal* structure of the chain. The gap is:
- `F(ψ) ∈ M` means "there exists a future MCS in the chain where ψ holds"
- The Lindenbaum extension's `.choose` is unconstrained: it can always pick an MCS that has `F(ψ)` without having `ψ`
- This creates an infinite regress where ψ is permanently deferred

Making V and F explicit as bilateral components does NOT fix this problem. The chain still must visit an MCS where ψ ∈ V. A bilateral pair at each step still faces the same issue: the step function can produce a pair `⟨V', F'⟩` where `ψ ∈ F'` (or neither V' nor F', if incomplete) perpetually. The temporal witness problem is about chain *navigation*, not about truth-value attribution.

### 3. Intellectual Value Assessment

**Bilateral semantics for TM formalization — honest assessment:**

- **Constructive temporal logic**: Bilateral pairs are most valuable in intuitionistic/constructive settings where truth and falsity are not De Morgan duals. BX is classical throughout (it has `peirce`, ex falso quodlibet, and the full classical propositional layer). A bilateral pair for a classical theory degenerates: `F = complement(V)`. No genuinely new constructive content.

- **Paraconsistent extensions**: Bilateral semantics allows V ∩ F ≠ ∅ (dialetheia). BX completeness requires consistency (MCS are consistent by definition). A paraconsistent extension would require rewriting the axiom system, not just the semantics.

- **Publication value**: The existing construction (Hintikka quasimodel with defect-discharge, 9 files, 2,289 lines) is already publication-worthy as a novel Lean formalization approach for Until/Since eventualities in classical bimodal logic. A bilateral semantics layer on top of classical MCS adds no mathematical novelty — it is definitionally equivalent to what exists.

- **Distinguishing factor**: The project's distinctive contribution is the BX axiom system formalization for reflexive TM and the quasimodel/filtration technique for eventualities. Bilateral semantics would not distinguish it; it would add complexity without adding distinction.

### 4. Strategic Comparison: Path A vs Path B

**Path A (Plan v18 — Ordered-Discharge Chain Replacement)**:
- Scope: ~24 hours, ~30 theorem re-proofs
- Confidence: 55-65% (never-resolved count is mathematically sound; Lean formalization risk is the main uncertainty)
- Alignment: Directly advances the active sorry; zero architectural disruption
- Risk: The circular dependency between chain definition and never-resolved invariant (30% risk per Report 18). Mitigation: define via well-founded recursion on count directly.
- Nature: Conservative engineering with good mathematical foundation

**Path B (Bilateral Semantics)**:
- Scope: 50-100+ hours estimate is optimistic. Realistic estimate: 200-400+ hours.
  - New `BilateralPoint` type replacing `BXPoint` everywhere
  - New `bilateral_le` ordering (at least as complex as `bx_le`)
  - New truth lemma (every case needs bilateral analogue)
  - New Lindenbaum extension for bilateral pairs
  - New quasimodel construction (the existing 887-line `Construction.lean` assumes MCS, not bilateral)
  - Re-proof of all 3,473 BXCanonical lines
  - And the forward_F problem likely recurs (see §5 below)
- Alignment: Does not advance the roadmap goal. Replaces the architecture instead of completing it.
- Risk: Very high. The forward_F analogue (see §5) would block completion again.

### 5. Risk That Forward_F Recurs in Bilateral Clothing

**This is the critical risk and it is NEAR-CERTAIN (90%+ confidence).**

The forward_F problem arises because: given `F(ψ)` in the current MCS, the chain step can always produce an MCS with `F(ψ)` (BX11, Case 3: put the formula "even further in the future") without producing one with `ψ`. This is a property of BX11 = `temp_linearity`, not of the truth-value attribution.

In a bilateral construction:
- `bilateral_step(⟨V, F⟩)` must produce `⟨V', F'⟩` such that if `F(ψ) ∈ V` then eventually some step produces `⟨V'', F''⟩` with `ψ ∈ V''`
- The step function still uses BX11 to extend: given `F(ψ) ∈ V`, BX11 says `ψ ∈ V' ∨ F(ψ) ∈ V'` (the third disjunct: `ψ ∈ predecessor`, irrelevant for forward)
- The Lindenbaum/bilateral extension can still choose `F(ψ) ∈ V'` indefinitely

The bilateral pair construction changes NOTATION but not the fundamental problem: classical BX axioms cannot syntactically force an MCS step to choose ψ over F(ψ). The same `.choose` non-determinism exists. The never-resolved count (Plan v18) is the mechanism that CONTROLS the choice; bilateral pairs do not provide this control.

### 6. Creative Combinations

#### Combination C1: Local Bilateral Pairs in the Step Function Only (Most Promising)

Use bilateral structure purely within `target_resolving_fwd_step` as a BOOKKEEPING device, without changing the global semantics:

- Define `ResolverState = { mcs : BXPoint, pending : Finset Formula, resolved : Finset Formula }`
- The "V" component = formulas in the MCS; "F" component = explicitly tracked pending F-obligations
- This is exactly the "never-resolved count" variant of Plan v18, just reframed as bilateral bookkeeping
- The key insight: tracking `resolved` vs `pending` IS a bilateral-style partition of F-obligations
- This does not require changing BXPoint, truth_at, or any global infrastructure

**Assessment**: This IS Plan v18, semantically. The bilateral framing is a useful way to think about it but requires no new definitions at the global level.

#### Combination C2: Balanced Lindenbaum Extension

Refine the Lindenbaum extension to produce MCS sets that are "balanced" w.r.t. a target formula ψ:
- Define `balanced_lindenbaum(S, ψ)`: extend S to an MCS M such that if `F(ψ) ∈ M`, then `ψ` was already in the "resolved" set (i.e., appeared in a prior chain step)
- This is a CONSTRAINED Lindenbaum lemma that adds a priority constraint
- Provable: extend S ∪ {ψ} first (if consistent), then extend further to an MCS. If S ∪ {ψ} is inconsistent (ψ is genuinely unprovable from S), then ψ ∉ M — but then BX11 gives `F(ψ) ∈ M` only if the external context forces it, which is addressable

**Assessment**: This is the mathematical heart of Plan v18 Phase 2. The "balanced" property corresponds exactly to `target ∈ M'` being the invariant of `target_resolving_fwd_step`.

#### Combination C3: Bilateral Truth Lemma as a SEPARATE MODULE

Implement bilateral semantics as a parallel module (like `BXCanonical` is parallel to legacy `UltrafilterChain`) that bridges back to the existing infrastructure via an equivalence theorem:

```
bilateral_complete : bilateral_valid φ → Nonempty (DerivationTree [] φ)
bilateral_to_bx_validity : bilateral_valid φ → valid φ
bx_to_bilateral_validity : valid φ → bilateral_valid φ
```

This would let the bilateral construction stand alone without touching the active sorry. It could be a separate research direction (task 96 or similar) after task 93 is closed via Plan v18.

**Assessment**: Viable as a FUTURE task, after the active sorry is closed. Not viable as a path to closing the current sorry.

### 7. Summary Risk Matrix

| Path | Mathematical Validity | Lean Complexity | Forward_F Recurrence | Timeline | Roadmap Alignment |
|------|----------------------|-----------------|----------------------|----------|-------------------|
| Plan v18 (ordered-discharge) | High (55-65%) | Moderate (~30 re-proofs) | N/A (direct fix) | ~24h | Direct |
| Full Bilateral Semantics | Theoretically valid | Extreme (3,000+ re-proofs) | Near-certain (90%+) | 200-400h | None |
| Combination C1 (local bilateral bookkeeping) | High | Low (= Plan v18) | Addressed by design | ~24h | Direct |
| Combination C3 (parallel bilateral module) | High | High (new module) | Irrelevant (post-sorry) | 50-100h | Future only |

## Recommended Strategic Path

**Proceed with Plan v18 (ordered-discharge chain replacement), framed via Combination C1 (bilateral bookkeeping).**

The bilateral pairs framing is intellectually productive as a DESIGN LENS for Plan v18:
- Think of `(pending_obligations, resolved_obligations)` as a bilateral partition of F-formulas
- This clarifies why the never-resolved count works: we are tracking the "false" side (pending) shrinking
- The Lean definition uses `ResolverState` rather than a new global `BilateralPoint`

Do NOT pursue full bilateral semantics as a path to closing the sorry. It is:
1. Definitionally equivalent to existing MCS semantics (classical setting)
2. Does not resolve the forward_F problem (same BX11 non-determinism applies)
3. Would require 200-400 hours vs 24 hours for Plan v18
4. Would likely re-encounter forward_F in bilateral clothing

After task 93 is closed, bilateral/constructive semantics as a separate formalization (Combination C3) would be a genuine research contribution if the goal is to study constructive bimodal logic. But that is a different project.

## Creative Possibilities

1. **Bilateral bookkeeping = Plan v18 reframed**: The never-resolved count is a bilateral partition. Making this framing explicit could help clarify the Lean definitions (call the resolver state `BilateralResolver` for documentation purposes) without changing the mathematical content.

2. **After task 93**: Bilateral semantics as a constructive alternative is interesting for intuitionistic temporal logic, which DOES have non-trivial truth/falsity distinction. If the project ever moves toward intuitionistic TM, bilateral pairs would be the right starting point.

3. **Fold order trick (from Report 18 synthesis)**: The synthesis identified that if the BX11 fold processes `target` LAST, Case 3 cannot fire for `target` (it puts the LEFT operand under F, not the right). This fold reordering is worth trying BEFORE implementing the full ordered-discharge chain — it may be a 2-hour fix rather than a 24-hour refactor. This is independent of bilateral semantics.

4. **Until reformulation via BX12 (Approach 21)**: Report 18 identified `bx_until_eventuality_resolution` as a potential bridge via `F(ψ) → ⊤Uψ` (BX12). This is worth 3-5 hours of investigation before committing to chain replacement.

## Confidence Level

**High (90%)** on the negative finding: full bilateral semantics does not address forward_F and requires 10-20x more work than Plan v18.

**High (85%)** on the positive recommendation: Plan v18 (ordered-discharge chain with never-resolved count) is the correct path. The bilateral framing is useful as a design lens but not as a new implementation strategy.

**Medium (60%)** on the specific timeline for Plan v18: the never-resolved count approach is mathematically sound but the Lean formalization overhead (circular dependency risk, 30 re-proofs) introduces uncertainty. The 24-hour estimate is plausible if the chain definition proceeds cleanly; 40-60 hours is possible if the circular dependency materializes.

**Recommendation**: Try the fold-order trick (2h) and Approach 21 (3h) first as low-cost alternatives. If both fail, commit to Plan v18. Do not pursue bilateral semantics.
