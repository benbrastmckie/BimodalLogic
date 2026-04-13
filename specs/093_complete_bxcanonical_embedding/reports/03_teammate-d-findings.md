# Teammate D Findings: Horizons and Literature

**Task**: 93 - Complete BXCanonical embedding (forward_F blocker)
**Angle**: Literature study, reflexive semantics analysis, strategic direction
**Date**: 2026-04-13

## Key Findings

### 1. The Standard Literature Uses a Tree-Shaped Canonical Frame, Not a Single Linear Chain

The classical completeness proof technique for tense logics (Goldblatt 1992, Burgess 1984, Gabbay-Hodkinson-Reynolds 1994) does NOT construct a single linear chain of MCS. Instead, the established approaches use one of two methods:

**Method A: Full canonical frame (Goldblatt 1992).** The canonical model consists of ALL maximally consistent sets as worlds, with the temporal accessibility relation `R(w, v)` defined as `g_content(w) subset v`. In this frame, `forward_F` is trivially provable: given `F(psi) in w`, the seed `{psi} union g_content(w)` is consistent (by the G-lifting argument), so Lindenbaum produces a fresh MCS `v` with `psi in v` and `R(w, v)`. Each F-obligation gets its own independently constructed witness -- there is NO inter-obligation interference. This is exactly what `CanonicalFrame.lean:133-148` (`canonical_forward_F`) already proves in this codebase.

**Method B: Step-by-step construction (Burgess 1984, extended by Venema 1993).** The frame is constructed in stages: start with a linearly ordered set of MCS, and at each stage n, care for the formula phi_n by inserting new points. Specifically: if not-G(phi_n) is in the MCS at some point w, a new successor point is inserted to witness F(not-phi_n). At odd stages, new points are inserted between existing pairs. The key distinction from the current codebase approach: NEW POINTS ARE INSERTED INTO THE EXISTING STRUCTURE (expanding the frame), rather than trying to preserve obligations along a fixed pre-existing chain. The enumeration ensures each formula is addressed infinitely often. This is constructive but produces a GROWING linear order, not a fixed Int-indexed chain.

**Why the current approach fails**: The current `int_chain` construction fixes the index set (Int) upfront and tries to populate it with MCS via a dovetailed schedule. Each chain position is determined by a single Lindenbaum extension of a seed. The Lindenbaum extension at step n has no obligation to preserve F-formulas from earlier steps, because it is a black-box Zorn's-lemma construction that picks an arbitrary maximal consistent superset of the seed. The classical approach (Method B) avoids this by INSERTING fresh witness points rather than trying to reuse existing chain positions.

### 2. The Reflexive/Strict Tension Is NOT the Root Cause

The project uses reflexive temporal operators: `G(phi)` means phi at all `s >= t`, `F(psi)` means there exists `s >= t` with psi at s. The `TemporalCoherentFamily` definition requires STRICT witnesses: `forward_F` demands `t < s` (not `t <= s`).

Under reflexive semantics, `F(psi) in chain(t)` could be satisfied by `psi in chain(t)` itself (the `s = t` case). The coherence definition demands a STRICT future witness `s > t`. This creates a tension, but it is NOT the root cause of the blocker.

**Why the tension is benign**: If `F(psi) in chain(t)` AND `psi in chain(t)`, then the obligation is semantically satisfied at the current point. The strict inequality in `forward_F` is needed for the backward_G contraposition argument (temporal_backward_G), where we need a witness strictly later to contradict the "phi holds at all s > t" hypothesis. Changing `forward_F` to use `t <= s` would break the backward_G proof (the witness `s = t` would be in the range `s >= t` of the hypothesis, making the contradiction vacuous).

The real root cause is inter-obligation interference in Lindenbaum extensions, not the strict/reflexive mismatch.

### 3. The BX Axiom System Provides Key Eventuality-Handling Tools

The Burgess-Xu axiom system includes specific axioms designed for eventuality handling that the literature uses in completeness proofs:

- **BX5 (self-accumulation)**: `(phi U psi) -> ((phi and (phi U psi)) U psi)` -- propagates Until obligations forward through their own guard intervals
- **BX6 (absorption)**: `(phi U (phi and (phi U psi))) -> (phi U psi)` -- prevents infinite deferral
- **BX10 (eventuality extraction)**: `(phi U psi) -> F(psi)` -- connects Until to F-obligations
- **BX11 (temporal linearity)**: F-witness linearity disjunction -- ensures F-witnesses are comparable on a linear order

These axioms work TOGETHER to ensure that eventuality formulas are eventually resolved. In the standard step-by-step construction, BX5 and BX6 are used to show that the defect count (number of unresolved Until obligations) strictly decreases along the chain. This is exactly what the quasimodel/filtration infrastructure (tasks 90-102) already does for the Until/Since cases. The remaining gap is that F-obligations (which arise from the G/H backward cases of the truth lemma) do not benefit from the same defect-discharge mechanism.

### 4. The Canonical Frame Approach Is the Literature-Standard Solution

Reading the codebase carefully reveals a crucial fact: `CanonicalFrame.lean` already proves `canonical_forward_F` trivially. The problem is not proving forward_F in the abstract -- it is proving it for a SPECIFIC FMCS structure indexed by Int.

The literature resolves this by one of:

**(a) Using the full canonical frame directly** (Goldblatt-style). The frame of ALL MCS with `ExistsTask` is a pre-order (reflexive + transitive). It is NOT linear. For completeness of the logic of ALL linear orders, one uses the fact that the canonical frame of Kt (basic tense logic) is ALREADY a pre-order satisfying the required frame conditions. For the logic of all linear orders specifically, one needs additional arguments (typically bulldozing or unraveling) to extract a linear model from the non-linear canonical frame.

**(b) Building the chain incrementally** (Burgess step-by-step). One builds a linear order by inserting witness points, growing the structure at each stage. The final model is the limit (union) of all stages. This gives a countable linear order.

**(c) Using filtration + unraveling** (standard modal logic technique). Build the canonical model, apply filtration to get a finite model, then unravel the cycles to get a tree/linear structure. The project's quasimodel/filtration infrastructure (9 files, 2289 lines) already does a variant of this for Until/Since.

### 5. Strategic Assessment: The Int-Indexed Chain Should Be Abandoned

The Int-indexed chain approach (`int_chain` in CanonicalModel.lean) is an attempt to directly construct a linear FMCS by populating Int with MCS via forward/backward dovetailing. This approach:

- Has failed to prove `forward_F` despite extensive effort (this is the 3rd research round)
- Is documented as a dead end in 12+ prior approaches (see ROAD_MAP.md "Dead Ends")
- Conflicts with the standard literature approaches (which use tree-shaped frames or growing linear orders)
- Duplicates effort: `canonical_forward_F` already proves forward_F for the tree-shaped canonical frame

The fundamental insight from the literature is: **do not try to force a fixed linear chain to satisfy F-obligations; instead, use the canonical frame (where forward_F is trivial) and then extract a linear model from it.**

### 6. Recommended Architecture: Bridge Canonical Frame to FMCS via Tree Linearization

The recommended approach, aligned with the literature and the existing codebase:

**Step 1**: Use `canonical_forward_F` and `canonical_backward_P` from `CanonicalFrame.lean` to establish forward_F/backward_P for the tree-shaped canonical frame.

**Step 2**: Linearize the tree into an Int-indexed FMCS. Two sub-approaches:

**(2a) Depth-first traversal with back-edges.** Enumerate the canonical frame's tree of witnesses depth-first, mapping each visited MCS to an Int position. This produces a linear chain where each F-witness appears at a later position. The challenge: ensuring `forward_G` and `backward_H` hold along the linearized chain (not just between parent-child pairs in the tree).

**(2b) Priority queue construction.** Start from M0 at position 0. Maintain a priority queue of F-obligations. At each step n+1, pop the highest-priority obligation `F(psi)`, use `canonical_forward_F` to get a fresh witness MCS `W`, and place `W` at position n+1 with seed `{psi} union g_content(chain(n))`. Since `canonical_forward_F` guarantees `g_content(chain(n)) subset W`, this preserves the forward_G property. The key insight: the SEED at each resolving step is not `{sigma} union g_content(chain(n))` alone -- it is `{sigma} union g_content(chain(n)) union ALL_F_OBLIGATIONS`, because `canonical_forward_F` constructs the witness independently for EACH obligation, and we can combine them via Lindenbaum (since each individual F-formula is consistent with the seed by the G-lifting argument).

Wait -- this is exactly the biased Lindenbaum approach that Teammate C analyzed. The multi-F combination is the hard part.

**(2c) Direct use of canonical frame properties to prove forward_F for the existing chain.** This is the most promising approach. Instead of modifying the chain construction, prove forward_F for `int_chain` by a SEMANTIC argument:

Given `F(psi) in chain(t)`, we know `F(psi) in chain(t)`. By `canonical_forward_F`, there exists MCS `W` with `psi in W` and `g_content(chain(t)) subset W`. We need to show `psi in chain(s)` for some `s > t`.

Since `F(psi) in chain(t)`, by the schedule surjectivity, there exists `n >= t` such that `schedule(n) = psi`. At step n+1, `fwd_succ` checks `F(psi) in chain(n)`. If `F(psi) in chain(n)` (preserved from chain(t) via f_carry through non-resolving steps), then `fwd_succ` resolves it: `psi in chain(n+1)`.

The key question reduces to: is `F(psi) in chain(n)` guaranteed when `F(psi) in chain(t)` and `n >= t`? For non-resolving steps, f_carry preserves F-formulas. For resolving steps (where `F(schedule(k)) in chain(k)` and the resolving seed is used), f_carry is NOT in the seed. So F(psi) can be lost at resolving step k if `t <= k < n`.

This brings us back to the original blocker. The f_carry mechanism preserves F-formulas through non-resolving steps but not through resolving steps.

### 7. The Most Viable Path: Well-Founded Induction on Formula Size

The literature (particularly Gabbay-Hodkinson-Reynolds 1994, Chapter 6) suggests an approach via well-founded induction on formula complexity. The key observation:

The truth lemma's G backward case invokes `forward_F` on `F(neg(phi))` where `phi` is a subformula of the formula being evaluated. So `forward_F` is only needed for formulas of the form `neg(phi)` where `phi` is a strict subformula of the target formula.

This means `forward_F` can be proved by well-founded induction on `Formula.sizeOf`:
- Base case: F-formulas with atomic content are trivially resolved by the schedule
- Inductive case: Assume forward_F holds for all formulas smaller than `phi`. Use the inductive hypothesis to establish `temporal_backward_G_with_fwd_F` for formulas of that size. This gives the G backward case of the truth lemma for subformulas, which in turn lets us reason about the chain's behavior.

However, the codebase's `TemporalCoherence.lean:213-229` already provides `temporal_backward_G_with_fwd_F` (backward G with an explicit forward_F hypothesis rather than requiring a full `TemporalCoherentFamily`). This variant is designed exactly for this well-founded induction pattern.

The question is whether the induction bottoms out: can we prove forward_F for atomic-level F-formulas (like `F(p)` for atom p) without needing a deeper induction? Yes -- for `F(p)`, the schedule eventually resolves it: there exists `n` with `schedule(n) = p`, and if `F(p)` persists to step n, then `p in chain(n+1)`. The persistence through non-resolving steps is guaranteed by f_carry; the issue is persistence through resolving steps for OTHER formulas.

But at the atomic level, there is no "other F-formula that could interfere" argument -- the resolving step for `F(q)` at step k uses seed `{q} union g_content(chain(k))`. Adding `F(p)` to this seed: is `{q} union g_content(chain(k)) union {F(p)}` consistent? By the analysis in Teammate A's report, this is NOT guaranteed. So even the atomic base case faces the persistence problem.

**Conclusion**: Well-founded induction on formula size does not escape the persistence problem. The issue is structural (chain construction), not logical (formula complexity).

### 8. The Restricted Temporal Coherence Path

The codebase defines `BFMCS.restricted_temporally_coherent` (TemporalCoherence.lean:295-300) which only requires forward_F for formulas in `deferralClosure(root)`. This is a finite set. The restricted variants `restricted_temporal_backward_G` and `restricted_temporal_backward_H` are already proved.

However, the active path's `parametric_representation_from_neg_membership` requires UNRESTRICTED `B.temporally_coherent`. A restricted representation theorem would need a restricted truth lemma, which exists only in the Boneyard (`StrictSemanticsLegacy/Algebraic/RestrictedTruthLemma.lean`). Porting this to the active parametric infrastructure is possible but requires:
- A restricted parametric truth lemma (proves truth <-> MCS membership only for formulas in subformulaClosure(root))
- A restricted parametric representation theorem
- Modifying `bx_countermodel` to use restricted coherence

This is viable but adds ~200-400 lines of infrastructure parallel to the existing unrestricted versions.

## Literature Summary

| Source | Approach | Frame Shape | F-Obligation Handling |
|--------|----------|-------------|----------------------|
| Goldblatt 1992 | Full canonical frame | Tree/DAG (all MCS) | Trivial: fresh Lindenbaum witness per obligation |
| Burgess 1984 | Step-by-step construction | Growing linear order | Insert new points at each stage; enumerate formulas ensuring each is addressed infinitely often |
| Venema 1993 | Extended Burgess + filtration | Growing linear order | Same as Burgess, extended to discrete/well-ordered |
| GHR 1994 | Comprehensive: canonical frame + bulldozing + filtration | Varies by target frame class | Canonical frame for general case; bulldozing/unraveling for specific frame classes |
| Reynolds 2003 | Limit closure axiom | Branching time (CTL) | Infinite axiom scheme for limit histories |
| **This project** | **Fixed Int-indexed chain** | **Single linear chain** | **BLOCKED: Lindenbaum interference** |

## Strategic Assessment

### Is the Int-Indexed Chain the Right Long-Term Strategy?

**No.** The Int-indexed chain is a non-standard approach that the literature does not use for exactly the reasons encountered here. The standard approaches use either the full canonical frame (tree-shaped, forward_F trivial) or a growing linear order (step-by-step insertion). Both fundamentally differ from a fixed Int-indexed chain populated by dovetailed Lindenbaum extensions.

### Should the Project Invest in Canonical Frame Infrastructure?

**Yes, cautiously.** The canonical frame already exists (`CanonicalFrame.lean`) and proves forward_F trivially. The missing piece is bridging from the canonical frame (non-linear) to a linear model (required by the truth evaluation in `Truth.lean`). Two investment options:

1. **Restricted coherence path** (~300-500 lines): Port the restricted truth lemma from Boneyard to the active parametric infrastructure. Then prove restricted temporal coherence for the Int-indexed chain (only need forward_F for finitely many formulas in `deferralClosure(root)`). The finite set of obligations makes a deterministic priority schedule feasible: resolve each of the finitely many F-obligations in turn, with f_carry preserving the REMAINING finite obligations through each resolving step. Since the set of obligations is finite, and the schedule revisits each one, eventual resolution is guaranteed even with some losses at resolving steps.

2. **Canonical frame linearization** (~500-800 lines): Build infrastructure to extract a linear model from the canonical frame. This is the standard approach (bulldozing / unraveling) but requires significant new infrastructure not currently in the codebase.

### Are There Upcoming Tasks That Benefit from One Approach Over Another?

Dense completeness (task 68, D = Rat) faces an even harder version of this problem: the guard interval `[t, s)` is infinite for rational `t < s`, so Until guard population is non-trivial. A canonical frame approach would benefit both Int and Rat completeness. A restricted coherence approach is more Int-specific.

## Recommended Approach

**Primary recommendation: Restricted temporal coherence for Int.**

Rationale:
- Smallest delta from current code (restricted coherence infrastructure partially exists)
- Avoids restructuring the BFMCS/parametric infrastructure
- The deferralClosure is finite, making the finite-priority-schedule argument viable
- The restricted truth lemma exists in the Boneyard (strict semantics version) and can be adapted

**Secondary recommendation: Biased Lindenbaum.**

If the restricted path proves too complex, the biased Lindenbaum (Teammate C's refined analysis) is viable: add F-formulas one at a time during enumeration, relying on the single-F consistency argument for each addition. The multi-F interaction is the risk, but Teammate C's analysis suggests it may be manageable because F-formulas are "future-looking" and thus broadly compatible with present-time seed elements.

**Not recommended: Canonical frame linearization.** While literature-standard, this requires too much new infrastructure for the current project state. Reserve for a future architectural revision.

## Confidence Level

- Literature analysis: **HIGH** (multiple consistent sources confirm canonical frame is standard)
- Reflexive/strict tension analysis: **HIGH** (the tension is real but not the root cause)
- Restricted coherence recommendation: **MEDIUM** (viable path but unproven in this codebase; the Boneyard version was for strict semantics)
- Biased Lindenbaum viability: **MEDIUM-LOW** (single-F argument is sound; multi-F interaction is unresolved)
- Int-indexed chain as dead end: **HIGH** (12+ prior failures, literature does not use this approach)
