# Research Report: Task #93 — Round 47

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1745106000_4a141e

## Summary

All four teammates confirm the current `dd_chain` architecture under reflexive semantics is definitively blocked (5% success probability). The decisive new finding from this round: **the IRR rule is UNSOUND under the current reflexive semantics** — under reflexive H, `H(¬p) ∧ p` is a contradiction (H includes the present moment), making the IRR rule's antecedent vacuously true and the rule trivially unsound. This eliminates IRR as an option within the current system and establishes that **switching to irreflexive (strict) semantics is a prerequisite for using the IRR rule**.

Three approaches remain viable, ordered by the team's synthesis of probability, user preference, and rollback safety:

1. **Irreflexive semantics switch** (on dedicated branch): Resolves the backward Until step transfer directly (B's key finding), makes IRR sound (D's key finding), aligns with user preference and standard literature (Burgess 1982, GHR 1994). Blast radius: 150+ compilation failures (C's finding), but fully contained on a branch = trivial rollback.

2. **Quasimodel chain concatenation** (additive, on separate branch): Uses 887-line sorry-free infrastructure. Confidence: 20-50% (teammates disagree). D identifies that sigma-signature periodic extension creates temporal ordering cycles; aperiodic extension reintroduces Lindenbaum opacity. Can be attempted in parallel with approach 1.

3. **Goldblatt restructure** (last resort): Full canonical frame rewrite. 800-1500 LOC, lowest cost-effectiveness.

## Key Findings

### 1. IRR Rule Is UNSOUND Under Reflexive Semantics (HIGH confidence, 90%)

**Source**: Teammate D (confirmed by A's analysis)

The IRR rule from GHR 1994 has antecedent `p ∧ H(¬p)`, meaning "p holds now AND ¬p held at all past times." Under irreflexive semantics (H quantifies over strictly past times, s < t), this is consistent — it means "p holds for the first time at t." Under the current reflexive semantics (H quantifies over s ≤ t, including the present), `H(¬p)` requires `¬p` at the current time, directly contradicting `p`. The antecedent is unsatisfiable, making the rule vacuously true — and therefore **trivially unsound** (proves anything).

This definitively eliminates IRR as an option within the current reflexive system, regardless of implementation approach (constructor vs. meta-argument vs. conservative extension).

### 2. Strict Until Step Transfer Is Directly Provable (HIGH confidence, 85%)

**Source**: Teammate B (Finding 3, Sub-option A1)

Under **strict Until** (witness s > t), the backward Until step transfer becomes directly provable:
- `(φ U ψ) ∈ fam(r+1)` means ∃ s > r+1, ψ(s) ∧ φ on (r+1, s)
- Given `φ ∈ fam(r)`, the same s works at r: s > r+1 > r, and (r, s) = {r} ∪ (r+1, s)
- So φ holds on (r, s) by combining `φ ∈ fam(r)` and φ on (r+1, s)

This directly resolves sorry sites #4 (`restricted_buc`) and #5 (`restricted_fuc`), which were blocked by the Until step transfer axiom gap under reflexive semantics.

**Critical distinction**: This requires **strict Until** (Sub-option A1: s > t), not just strict G/H with reflexive Until (Sub-option A2). Sub-option A2 preserves `(⊥ U α) ↔ α` and the deterministic chain triviality. Only A1 makes the switch meaningful.

### 3. Boneyard Contains Prior Strict Semantics Infrastructure (HIGH confidence, 90%)

**Source**: Teammate B (inventory)

The `StrictSemanticsLegacy/` directory (8 files) was built for exactly the irreflexive system:
- `Bundle/CanonicalConstruction.lean` — Sorry-free direct TruthLemma at TaskFrame level for D=Int
- `Algebraic/UltrafilterChain.lean` — Sorry-free R_G/R_Box algebraic foundations
- `FrameConditions/Completeness.lean` — Documents the bundle-vs-family coherence gap (reason for abandonment — NOT a semantic problem)

The strict semantics infrastructure was abandoned because of the bundle-vs-family coherence gap (a semantic level mismatch), not because irreflexive semantics itself was problematic. The BXCanonical architecture now resolves the bundle-vs-family gap independently.

### 4. Five Sorry Sites Have Three Independent Root Causes (HIGH confidence, 90%)

**Source**: Teammate C (Finding 4)

| Category | Sites | Root Cause | Resolved by Irreflexive? |
|----------|-------|------------|--------------------------|
| A: F-eventuality | #1 (`fwd_chain_forward_F`) | BX11 fold opacity, no termination | YES (IRR temporal induction) |
| B: Backward chain | #2-3 (`restricted_tc` backward) | No `preserving_bwd_step` | PARTIALLY (need symmetric infrastructure) |
| C: Until step transfer | #4-5 (`restricted_buc/fuc`) | Missing `φ ∧ F(φ U ψ) → φ U ψ` | YES (strict Until makes it provable) |

Under irreflexive semantics: Categories A and C are directly resolved. Category B requires building backward chain infrastructure (symmetric to forward), but this is standard engineering once the axiom system supports it.

### 5. Blast Radius of Semantic Switch Is 150+ Failures (HIGH confidence, 90%)

**Source**: Teammate C (Finding 2)

Removing BX1 (`G(φ) → φ`) immediately breaks:
- `bx_le_refl` (first theorem in Frame.lean)
- `g_content_subset` (~30 sorry-free theorems)
- 8 Quasimodel/Realization.lean theorems
- `sigma_le_refl` in Filtration
- BX8 (`ψ → φ U ψ`) requires reflexive witness
- 93 total occurrences in Metalogic/ alone

However: all work is on a dedicated git branch. Rollback = don't merge the branch.

### 6. Quasimodel Concatenation Has Unresolved Obstruction (MEDIUM confidence, 60%)

**Source**: Teammate D (Finding 2)

Sigma-signature periodic extension creates cycles in the temporal ordering (violating linearity). Aperiodic extension (fresh BXPoints at each level) reintroduces Lindenbaum opacity — the connection step (hN to h0') requires g_content compatibility that may not hold after defect discharge.

Teammates disagree on success probability: C rates 50%, D rates 20-30%. The approach is mathematically interesting but faces its own form of the chain coherence problem at the level boundaries.

### 7. ConservativeExtension Infrastructure Already Exists (MEDIUM confidence, 75%)

**Source**: Teammates A, D

The `ConservativeExtension/` directory implements IRR rule infrastructure:
- `ExtFormula.lean`, `ExtDerivation.lean` — Extended proof system with fresh atom
- `Lifting.lean`, `Substitution.lean` — Conservative extension machinery
- `IRRSoundness.lean` — IRR soundness proof (referenced in Soundness.lean)

However: `ExtDerivationTree` currently has NO IRR constructor despite comments claiming it does (Teammate C, Finding 1). The infrastructure is incomplete but provides the right framework. Under irreflexive semantics, completing this infrastructure becomes viable.

## Synthesis

### Conflicts Resolved

**Conflict 1: Switch semantics or not?**

| Position | Teammate | Rationale |
|----------|----------|-----------|
| Do NOT switch | A | Task 658 impossibility, 2000+ LOC wasted, 3 completeness theorems needed |
| Switch (strict Until) | B | Step transfer becomes provable, prior infrastructure exists |
| Try quasimodel first | C | Lower rollback risk, 50% confidence |
| Switch + IRR required | D | IRR unsound under reflexive, irreflexive is prerequisite |

**Resolution**: D's finding that IRR is unsound under reflexive semantics is the decisive fact. A's Task 658 impossibility ("independent Lindenbaum extensions cannot be proven coherent without T-axiom") is specific to the current architecture — under irreflexive semantics with the IRR rule, the proof strategy changes fundamentally (GHR 1994 approach). The "3 completeness theorems" concern (A) is mitigated by the translation `p U_refl q = q ∨ (p U_strict q)` which derives reflexive completeness from irreflexive (~200 LOC, per D).

**Decision**: Switch to irreflexive semantics on a dedicated branch, as user prefers.

**Conflict 2: Attempt ordering**

| Order | Teammate | Rationale |
|-------|----------|-----------|
| IRR → quasimodel → Goldblatt | Round 46 | Lowest cost first |
| Quasimodel → IRR → irreflexive → Goldblatt | C | Rollback risk ordering |
| Irreflexive → quasimodel → Goldblatt | D | Mathematical necessity |

**Resolution**: The git branch strategy makes ALL approaches equally easy to roll back (each on own branch, rollback = don't merge). Given this, rollback risk is equalized and we should order by:
1. User preference (irreflexive is "even preferred")
2. Mathematical viability (IRR is unsound under reflexive — eliminates it as standalone)
3. Success probability (irreflexive + IRR: 45-65%; quasimodel: 20-50%)

**Decision**: Irreflexive semantics first (on branch), quasimodel concatenation as parallel/fallback attempt (on separate branch).

**Conflict 3: Is Task 658 impossibility still relevant?**

- A (95% confidence): Yes — the impossibility is fundamental
- D (implicit): No — it applies to the current architecture, not to IRR-based proofs

**Resolution**: Task 658 proves that independent Lindenbaum extensions lack coherence WITHOUT the T-axiom. This is correct and relevant — it means the current `dd_chain` approach (which builds independent Lindenbaum extensions) cannot work under irreflexive semantics either. But the GHR 1994 approach does NOT use independent Lindenbaum extensions in the same way — it uses the IRR rule to simulate well-founded induction, building the chain with a marked "beginning" via the fresh atom. The impossibility applies to the architecture, not to all possible proof strategies.

### Gaps Identified

1. **BX8 under strict Until**: `ψ → φ U ψ` requires a reflexive witness (s = t). Under strict Until (s > t), this axiom is INVALID. The strict system needs different introduction axioms for Until. Exact replacement axioms need to be determined.

2. **BX9 under strict semantics**: `(φ U ψ) → φ ∨ ψ` may also change character. Need complete axiom audit.

3. **Seriality axiom**: Strict G/H require seriality (`F(⊤)`, `P(⊤)`) to prevent degenerate models. Does the current semantics over Int already guarantee this?

4. **TaskFrame nullity compatibility**: `task_rel w 0 w` (reflexive task semantics) must coexist with strict temporal operators. Need to verify this is architecturally compatible.

5. **`phi_imp_F_phi` derivability**: Under irreflexive semantics, `φ → F(φ)` is NOT derivable from `G(φ) → φ` (since BX1 is removed). This changes the "defect count never decreases" obstruction — resolved defects genuinely cannot re-emerge as F-obligations. This is a POSITIVE change.

6. **Backward chain symmetric infrastructure**: Even under irreflexive semantics, sorry sites #2-3 (Category B) need `preserving_bwd_step` or equivalent. This is engineering work, not a mathematical obstruction, but it's still needed.

### ROAD_MAP.md Corrections Needed

1. **Current strategy**: Update to recommend irreflexive semantics switch with IRR rule
2. **Dead end list**: Add "IRR under reflexive semantics" as dead end (unsound — H(¬p) ∧ p contradicts under reflexive H)
3. **Dependency chain**: The three restricted coherence theorems are independent at the type level (confirmed round 46)

## Recommendations

### Primary Path: Irreflexive Semantics Switch (on `feat/irreflexive-semantics` branch)

**Git strategy**: Create branch from `until`, do all work there. Rollback = abandon branch.

**Phase 1** (~100 lines): Revise `Axioms.lean`
- Remove BX1 (`temp_t_future`, `temp_t_past`)
- Remove/revise BX8, BX8', BX9 for strict Until/Since
- Add seriality axiom `F(⊤)` and strict Until expansion
- Add strict Until unfolding: `(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))`

**Phase 2** (~200 lines): Revise `Truth.lean` and `Soundness.lean`
- Change `≤` to `<` for G/H/U/S semantic clauses
- Re-verify soundness for all revised axioms
- Structure preserved, inequalities change

**Phase 3** (~150 lines): Complete IRR infrastructure
- Add IRR constructor to `ExtDerivationTree` (it's missing despite comments)
- Verify IRR soundness under strict semantics (existing `IRRSoundness.lean` as starting point)

**Phase 4** (~200 lines): IRR-based chain construction
- Use GHR 1994 strategy: fresh atom p marks "beginning"
- `p ∧ H(¬p)` holds at exactly one point (the beginning)
- Build Int-indexed chain via temporal induction using IRR
- Wire into `dd_countermodel`

**Phase 5** (~100 lines): Close 5 sorry sites
- Category A (#1): F-eventuality via IRR temporal induction
- Category B (#2-3): Backward chain with `preserving_bwd_step` (symmetric to forward)
- Category C (#4-5): Strict Until step transfer (now directly provable)

**Phase 6** (~200 lines, optional): Derive reflexive completeness
- Translation: `p U_refl q = q ∨ (p U_strict q)`
- Prove reflexive completeness as corollary of irreflexive

**Estimated total**: 600-1000 new/modified lines
**Confidence**: 55-65% (averaged across teammates)

### Parallel Attempt: Quasimodel Concatenation (on `feat/qm-int-chain` branch)

Can be attempted simultaneously. Uses sorry-free `Construction.lean` (887 LOC). Lower confidence (20-50%) but purely additive — no existing code breaks. If it works, it closes the sorries without any semantic changes.

### Fallback: Goldblatt Restructure (on `feat/goldblatt-restructure` branch)

Last resort. 800-1500 LOC rewrite. Only if both above fail.

### Git Branch Strategy

```
until (current)
  ├── feat/irreflexive-semantics   # Attempt 1 (user-preferred, highest mathematical viability)
  ├── feat/qm-int-chain            # Attempt 2 (parallel, additive, lower confidence)
  └── feat/goldblatt-restructure   # Attempt 3 (last resort)
```

Each branch from `until`, independent of each other. Rollback = don't merge.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | IRR rule deep analysis | completed | high (95%) | IRR not in base system; Task 658 impossibility; Task 29 prior attempt history; sorry sites are structural not axiom gaps |
| B | Boneyard inventory + irreflexive analysis | completed | high (85%) | Complete 33-file Boneyard inventory; strict Until step transfer proof; Sub-option A1 vs A2 distinction; prior infrastructure reusability |
| C | Critic: attempt ordering + rollback | completed | high (90%) | Category error in IRR proposal; 150+ failure blast radius; three independent root causes; git branch rollback strategy |
| D | Horizons: strategy + quasimodel + literature | completed | high (90%) | IRR unsound under reflexive (decisive); quasimodel cycling obstruction; literature alignment; reflexive-from-irreflexive reduction |

## References

- Burgess, J.P. (1982). "Axioms for tense logic. I: since and until." Notre Dame J. Formal Logic 23, 367-374
- Xu, M. (1988). "On some U,S-tense logics"
- Goldblatt, R. (1992). "Logics of Time and Computation"
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations and Computational Aspects", Vol. 1
- Reynolds, M. (1992). "An axiomatization for Until and Since over the reals without the IRR rule." Studia Logica 51, 165-193
