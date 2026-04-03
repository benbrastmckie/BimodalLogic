# Research Report: Task #83 (Round 11)

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Mode**: Team Research (2 teammates)
**Session**: sess_1775229441_5eee5c
**Focus**: Should the project use half-open, partial strict, or fully strict semantics?

## Summary

Two teammates investigated the three semantic options from complementary angles: feasibility analysis (A) and mathematical ideality (B). They converge on one critical conclusion but diverge on the recommended path.

**The headline finding**: The half-open backward blocker is a **genuine mathematical impossibility**, not merely a proof difficulty. The `until_unfold` axiom is semantically unsound under the current half-open + reflexive G configuration, making the backward truth lemma unprovable regardless of proof strategy.

**The decisive conflict**: Teammate A recommends **partial strict** (strict U/S, reflexive G/H) at 30-45 hours. Teammate B recommends **fully strict** (strict G/H/S/U) at 60-90 hours. The resolution hinges on a critical finding from Teammate B: **partial strict breaks the F φ ≡ ⊤ U φ equivalence**, which is a fatal mathematical flaw that rules out Option B entirely.

**Final recommendation**: **Fully strict semantics (Option C)** is the only mathematically sound path. It is also the standard in the philosophical logic literature and the most satisfying product.

## Key Findings

### 1. Half-Open Is Mathematically Impossible (Both teammates — HIGH confidence)

Teammate A provides a rigorous argument: the backward truth lemma for Until under half-open semantics requires `G(φ U ψ) ∈ mcs(t)` (via `until_intro`), which means `φ U ψ` at ALL j ≥ t. But semantic Until witnesses only cover [t, s], leaving j > s uncovered. No axiom, chain property, or induction scheme can bridge this gap because:

- **U-Induction** is a forward-direction tool (deduces properties FROM `φ U ψ`, not INTO it)
- **The dovetailed chain** provides forward_G and forward_F but not persistence of Until past its witness
- **Contradiction via forward_F** fails because forward_F witnesses can land at j > s where no contradiction is available
- **The `until_unfold` axiom is UNSOUND** under half-open + reflexive G: `(φ U ψ)(t) ↛ G(φ U ψ)(t)` in general

This is not a matter of finding a clever proof; the axiom system is fundamentally mismatched with the semantics.

### 2. Partial Strict Has a Fatal Flaw (Teammate B — HIGH confidence)

Teammate A advocates partial strict (reflexive G/H, strict U/S) as a middle ground that preserves temp_t and avoids the 67+ call site cascade. However, Teammate B identifies a **fatal mathematical flaw**:

Under reflexive G: `F φ = ¬G(¬φ)` means `∃ s ≥ t, φ(s)` (includes present)
Under strict U: `⊤ U φ` means `∃ s > t, φ(s)` (excludes present)

Therefore `F φ ≠ ⊤ U φ`. The equivalence breaks.

This is not a minor inconvenience — the F-U bridge is used throughout the completeness proof, in the dovetailed chain construction, and in multiple derived theorems. Breaking it would require a pervasive restructuring that eliminates the cost savings of keeping reflexive G/H.

Teammate A also notes this issue (in the "Mathematical Costs" section) but frames it as manageable via bridge axioms `F(ψ) → ψ ∨ (⊤ U ψ)`. However, this introduces a semantic split where `F φ` and `⊤ U φ` mean different things — an internal inconsistency that undermines the mathematical quality the user seeks.

### 3. The Literature Overwhelmingly Favors Strict (Teammate B — HIGH confidence)

| Author(s) | Year | Semantics | Tradition |
|-----------|------|-----------|-----------|
| Prior | 1957-67 | **Strict** | Philosophical logic |
| Kamp | 1968 | **Strict** | Mathematical logic |
| Goldblatt | 1992 | **Strict** | Mathematical logic |
| Reynolds | 1992-96 | **Strict** | Mathematical logic |
| Venema | 1993 | **Strict** | Mathematical logic |
| Gabbay-Hodkinson-Reynolds | 1994 | **Strict** | Mathematical logic |
| Blackburn-de Rijke-Venema | 2001 | **Strict** (default) | Graduate textbook |
| Burgess-Xu | 1982/88 | Reflexive | Convenience simplification |
| Pnueli / CS-LTL | 1977+ | Reflexive | Computer science (different logic) |

Strict is the standard in the Prior-Kamp-Venema tradition. Burgess-Xu's reflexive choice was a deliberate simplification to avoid the irreflexivity problem in completeness proofs — a problem that report 10 showed is dissolved by the three-place task relation.

### 4. Fully Strict Resolves the Backward Blocker Cleanly (Both teammates — HIGH confidence)

Under fully strict semantics with X-based discrete axioms:

```
until_unfold: φ U ψ ↔ X(ψ ∨ (φ ∧ (φ U ψ)))
```

The backward truth lemma uses induction on witness distance k = s − t > 0:

- **Base (k=1)**: ψ(t+1) → ψ ∈ mcs(t+1) by IH on subformula → X(ψ ∨ ...) ∈ mcs(t) by X-backward → φ U ψ ∈ mcs(t)
- **Step (k>1)**: φ(t+1) + φ U ψ at (t+1) by IH on distance → φ ∧ (φ U ψ) ∈ mcs(t+1) → X(... ∨ (φ ∧ φ U ψ)) ∈ mcs(t) → φ U ψ ∈ mcs(t)

The X-based axiom requires only information about time t+1, not ALL future times. This makes induction well-founded.

### 5. The Three-Place Task Relation Was Designed for Strict Semantics (Teammate B — HIGH confidence)

The task frame uses `task_rel w d u` with `nullity_identity: task_rel w 0 u ↔ w = u`. This creates:
- d > 0: forward temporal (strict future)
- d = 0: identity (present)
- d < 0: backward temporal (strict past)

Strict temporal operators quantify over d > 0 / d < 0, never d = 0. The identity case is structurally separated. This is the semantic content of strict operators.

### 6. The T-Axiom Is an Artifact, Not a Principle (Teammate B — HIGH confidence)

`G φ → φ` says "if φ holds at all future times, then φ holds now." Under strict semantics, this is invalid because the future does not include the present. The present is not the future.

The `always` operator `H φ ∧ φ ∧ G φ` becomes genuinely three-part under strict semantics — the middle conjunct `φ` is no longer redundant. This is MORE honest, not less.

### 7. Key Technical Challenge: X Truth Lemma Backward Direction (Both teammates — MEDIUM-HIGH confidence)

Both teammates identify the same remaining challenge: proving `χ ∈ mcs(t+1) → X(χ) ∈ mcs(t)` (backward X propagation). Report 10 rates this MEDIUM-HIGH difficulty.

Teammate A sketches a contradiction approach via forward_F. The discrete axiom `disc_next: F(⊤) → ⊥ U ⊤` ensures X(⊤) is derivable from F(⊤), connecting the chain's Succ structure to the X operator. The dovetailed chain's Succ relation provides the forward direction; backward requires strengthening Succ or using the discrete axioms to derive backward propagation.

This is solvable but requires careful construction — it is the new "hard problem" replacing the old backward Until blocker.

## Synthesis

### Conflicts Resolved

**Conflict 1: Partial strict vs fully strict**

Teammate A recommends partial strict (30-45 hours, preserves temp_t). Teammate B recommends fully strict (60-90 hours, standard in literature).

**Resolution**: Fully strict wins. Teammate B's finding that partial strict breaks `F φ ≡ ⊤ U φ` is decisive. This equivalence is load-bearing throughout the completeness proof. The cost savings of preserving temp_t are illusory if F-U bridging must be rebuilt.

Additionally:
- The user explicitly asked for "the most mathematically correct and satisfying product, not just the easiest"
- The literature standard is strict, and this is a reference formalization
- The three-place task relation naturally supports strict semantics
- Report 10 already established that the irreflexivity problem is dissolved

**Adopted position**: Fully strict (Option C).

**Conflict 2: Effort estimates**

Teammate A estimates partial strict at 30-45 hours. Report 10 estimates fully strict at 60-90 hours.

**Resolution**: Report 10's estimate likely overestimates because:
1. Phases 1-3 of plan v7 already implemented (half-open semantic change, some soundness work) — much of this carries forward
2. The irreflexivity problem is dissolved (report 10 confirmed no frame changes needed)
3. The T-axiom cascade is "HIGH effort, LOW conceptual risk" (mechanical, not creative)
4. The backward truth lemma — previously the hardest problem — is now cleanly solvable

Revised estimate: **45-65 hours** for fully strict, accounting for the T-axiom cascade but leveraging existing work.

### Gaps Identified

1. **Exact formulation of strict until_induction**: The Venema (1993) and Reynolds (1996) papers need to be consulted for the precise statement. Report 10 identifies this as MEDIUM difficulty.

2. **X truth lemma backward direction construction**: The specific Lean implementation of backward X propagation in the chain. This is the new critical path.

3. **Since dual of all changes**: All Until changes must be mirrored for Since. This is mechanical but doubles the raw line count.

## Recommendations

### The Path Forward: Fully Strict Semantics

**Phase 0: Revert half-open changes** (~2 hours)
The Phase 1-3 work from plan v7 (half-open semantic change, partial soundness fixes) should be assessed — some carries forward (e.g., the general structure of soundness proofs), but the semantic definitions must change from half-open to fully strict, and G/H must change from reflexive to strict.

**Phase 1: Semantic definitions** (~2-3 hours)
Change Truth.lean: G/H from `≤` to `<`, Until/Since from half-open to fully strict (`<` for all bounds).

**Phase 2: Axiom system** (~6-8 hours)
- Remove temp_t_future, temp_t_past
- Add temp_a_dual (`φ → H F φ`)
- Add disc_next (`F ⊤ → ⊥ U ⊤`), disc_prev (`P ⊤ → ⊥ S ⊤`)
- Replace until/since unfold/intro/induction with X/Y-based versions

**Phase 3: Soundness proofs** (~8-10 hours)
- Prove soundness for all new/modified axioms
- Remove unsound axiom proofs (temp_t, old unfold/intro)
- Add frame condition hypotheses where needed

**Phase 4: T-axiom cascade** (~8-12 hours)
- Systematically replace 85 occurrences across 17 files
- Most become `always_to_present` or explicit `weak_future`/`weak_past`
- Perpetuity module survives mostly intact

**Phase 5: Chain construction and X truth lemma** (~10-15 hours)
- Redefine forward_G/backward_H with strict `<`
- Add forward_X/backward_Y for next-step
- Strengthen Succ relation for backward X propagation
- The critical path: backward X truth lemma

**Phase 6: Until/Since truth lemma** (~8-12 hours)
- Forward direction: uses dovetailed chain forward_U/forward_S
- Backward direction: distance induction using X-based axioms (THE PAYOFF)
- Since mirrors Until

**Phase 7: Completeness wiring and verification** (~5-8 hours)
- Wire new truth lemma into completeness_over_Int
- Verify sorry-free path
- Clean up dead code

**Total: ~50-70 hours**

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | Half-open feasibility + partial strict | completed | Rigorous impossibility argument for half-open; detailed partial strict analysis; X truth lemma backward sketch |
| B | Literature survey + mathematical ideality | completed | Comprehensive literature table; F-U equivalence breaking under partial strict (decisive); three-place task relation alignment |

## References

### Literature
- Prior (1957, 1967). Original tense logic with strict operators
- Kamp (1968). "Tense Logic and the Theory of Linear Order" — strict Since/Until
- Burgess (1982). "Axioms for tense logic I: Since and Until" — reflexive (simplification)
- Xu (1988). Simplification of Burgess — reflexive
- Goldblatt (1992). "Logics of Time and Computation" — strict as standard
- Reynolds (1992). "An axiomatization for Until and Since over the reals without the IRR rule"
- Venema (1993). "Completeness via Completeness" — strict extension of Burgess-Xu
- Gabbay, Hodkinson, Reynolds (1994). "Temporal Logic: Mathematical Foundations" — strict
- Reynolds (1996). "Axiomatizing U and S over integer time" — strict with X/Y
- Blackburn, de Rijke, Venema (2001). "Modal Logic" — strict as default

### Codebase
- `Truth.lean:118-129` — current semantic definitions (change site)
- `Axioms.lean:279-512` — current axiom system (change site)
- `TaskFrame.lean:93-122` — three-place task relation (supports strict)
- `Formula.lean:326-398` — always, weak_future, weak_past (survive intact)
- `SuccRelation.lean:59-60` — Succ relation (canonical X)
- `Bridge.lean:532-577` — always decomposition (survives intact)
- T-axiom: 85 occurrences across 17 files (cascade target)
