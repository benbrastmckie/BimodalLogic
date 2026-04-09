# Teammate D Findings: Strategic Horizons

**Task**: 88 -- Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Role**: Teammate D (Horizons / Strategic Direction)
**Focus**: Long-term viability, representation theorem design, clean-sheet analysis

---

## Key Findings

### 1. What a "Standard Representation Theorem" Means for This Logic

A representation theorem for a logic L with respect to a class C of frames states:

> For every consistent formula phi, there exists a model M based on a frame in C such that phi is satisfiable in M.

Equivalently (by contrapositive): every valid formula is derivable. For tense logics with Until/Since on reflexive linear orders, the standard result (Burgess 1982, Xu 1988, Venema 1993) takes the form:

> The Burgess-Xu axiom system is complete with respect to the class of all reflexive linear orderings.

The proof method is a **step-by-step Henkin construction** that builds a linear order of maximal consistent sets (MCS), where at each step one pending eventuality obligation is resolved. This is fundamentally different from the standard modal canonical model (which is a branching structure). The key distinction:

- **Modal canonical model**: Worlds = all MCSs. Accessibility is defined globally. The model is NOT linear -- it branches.
- **Temporal canonical model (Henkin chain)**: Worlds = a SPECIFIC sequence of MCSs constructed one-by-one, forming a linear order by construction. Each new MCS is chosen to resolve one pending Until/Since obligation.

**Critical insight for this project**: The BXCanonical architecture attempts to use the modal approach (global canonical frame with bx_le ordering over ALL MCSs) for a fundamentally temporal problem. This is the root cause of 11+ dead ends. The ordering bx_le (defined via g_content inclusion) is NOT linear, and BX7 cannot make it linear (report 08 proved this definitively). The standard representation theorem for Until/Since requires a CONSTRUCTED linear chain, not a global pre-order.

### 2. The BXCanonical Architecture Is the Wrong Architecture for Until/Since

The BXCanonical architecture works correctly for the Until/Since-free fragment (USF): {atom, bot, imp, box, G, H}. For this fragment:

- The constant-history canonical model (one MCS, one history) suffices for temporal-free formulas
- The fragment completeness (`fragment_completeness`) is sorry-free
- The USF completeness (`usf_completeness`) has only 1 sorry (imp Case B)

But for Until/Since, the architecture has a fundamental mismatch:

| Property | BXCanonical approach | Standard approach |
|----------|---------------------|-------------------|
| **Canonical model structure** | All MCSs, global ordering | Constructed chain of MCSs |
| **Temporal ordering** | bx_le: g_content inclusion | Position in constructed chain |
| **Linearity** | Must be PROVED (impossible) | Built by CONSTRUCTION |
| **Eventuality resolution** | Must hold for ALL intermediate MCSs | Holds by construction for chain points only |
| **Guard condition** | Universal quantification over all BXPoints | Quantification over chain points only |

The 4 Frame.lean sorries all stem from this mismatch. The eventuality resolution lemmas require guards that hold for ALL BXPoints in an interval -- but there is no mechanism to control what happens at arbitrary off-chain MCSs.

**Verdict**: The BXCanonical architecture CANNOT close the 4 Frame.lean sorries without either (a) adding temp_linearity back as an axiom (rejected for philosophical reasons), or (b) fundamentally restructuring to use a constructed chain instead of a global ordering. Option (b) is essentially building a new architecture.

### 3. The Ideal Completeness Proof: Clean-Sheet Design

If we could design the completeness proof from scratch with no legacy constraints, here is what the ideal proof would look like:

**Phase 1: Consistency to MCS**
- Given non-derivable phi, show {neg phi} is consistent (DONE, sorry-free in Completeness.lean)
- Extend to MCS M0 containing neg phi via Lindenbaum (DONE, sorry-free)

**Phase 2: Construct canonical linear model (THE MISSING PIECE)**
- Build a sequence of MCSs indexed by integers: `chain : Int -> MCS`
- Place M0 at position 0: `chain(0) = M0`
- At each step, extend in both directions:
  - Forward: `chain(n+1)` is chosen to satisfy one pending Until eventuality from `chain(n)`
  - Backward: `chain(-(n+1))` is chosen to satisfy one pending Since eventuality from `chain(-n)`
- Use dovetailed scheduling to ensure ALL eventualities are eventually resolved
- Each new MCS is constructed via Lindenbaum extension of a carefully chosen seed

**Phase 3: Define semantics on the chain**
- World states = the MCSs in the chain
- Time = integers (the chain index)
- Task relation: `task_rel w d u` iff `w = chain(n)` and `u = chain(n+d)` for some n
- Valuation: `atom p true at chain(n)` iff `atom p in chain(n).formulas`
- Modal omega: constant histories through each chain point (for S5)

**Phase 4: Truth lemma (by structural induction on formulas)**
- Atom, bot, imp: standard MCS properties
- Box: S5 modal equivalence class construction (sorry-free in existing code)
- G: `G(alpha) in chain(n)` iff `alpha in chain(m)` for all m >= n
  - Forward: g_content inclusion along the chain (bx_le between consecutive chain points)
  - Backward: g_content_closed_derivation (already sorry-free)
- H: mirror of G
- Until: `phi U psi in chain(n)` iff exists m >= n with psi in chain(m) and phi in chain(k) for all n <= k < m
  - Forward: by construction (dovetailed scheduling ensures the witness exists)
  - Backward: by BX axioms (BX8 for base case, BX5/BX6 for propagation)
- Since: mirror of Until

**Phase 5: Contradiction**
- phi not in chain(0) = M0 (since neg phi in M0)
- By truth lemma: phi is false at time 0 in the chain model
- Therefore phi is not valid (countermodel exists)
- Contrapositive: valid phi implies derivable phi

**How far is the current code from this ideal?**

| Component | Current status | Gap |
|-----------|---------------|-----|
| Phase 1 | Sorry-free | None |
| Phase 2 (chain construction) | DovetailedChain.lean DEPRECATED (6 sorries) | Major: needs clean rebuild |
| Phase 3 (semantic embedding) | CanonicalEmbedding.lean partial | Medium: needs chain-based version |
| Phase 4 (truth lemma for atom/bot/imp/box) | Sorry-free (fragment_truth_iff) | None |
| Phase 4 (truth lemma for G/H) | Partial (G_iff_mcs, H_iff_mcs sorry-free) | Small: needs chain-specific version |
| Phase 4 (truth lemma for Until/Since) | Frame.lean 4 sorries | Major: the core problem |
| Phase 5 | Completeness.lean 1 sorry | Depends on Phase 2-4 |

The largest gap is Phase 2: a clean chain construction with dovetailed eventuality resolution. The existing DovetailedChain.lean is deprecated due to the X-vs-G mismatch. A new construction that avoids this mismatch is needed.

### 4. Adjacent Roadmap Items and Synergies

**Task 58 (Wire completeness to FrameConditions)**: This task needs `forward_until_since_coherent` -- essentially the same Until/Since truth lemma problem as the BXCanonical sorries. A clean chain construction would directly serve both tasks. However, task 58 operates in the Bundle/BFMCS architecture, not BXCanonical. A new chain construction could be placed in a shared location.

**Task 60 (Remove discrete_Icc_finite_axiom)**: This custom axiom asserts finiteness of integer intervals. It is used in the discrete completeness path but NOT in the BXCanonical path. Closing the BXCanonical sorries does not directly help task 60, but establishing full completeness via BXCanonical would make the discrete completeness path less critical.

**Task 87 (Full representation theorem via enriched chain)**: This task explicitly calls for the construction described in Section 3 above. Tasks 87 and 88 are essentially the same mathematical problem approached from different starting points. Task 87 starts from scratch in Bundle/; task 88 tries to patch BXCanonical. The ideal approach would be to build the chain construction ONCE and use it for both.

**Synergy recommendation**: Build the clean chain construction as a standalone module (e.g., `Metalogic/BXCanonical/CanonicalChain.lean` or `Metalogic/Chain/EventualityChain.lean`) that can serve tasks 58, 87, and 88 simultaneously.

### 5. Should the Approach Be Redesigned from Scratch?

**Yes, partially.** After 11+ dead ends, the evidence is overwhelming:

1. **Global bx_le linearity is mathematically impossible** from BX axioms (report 08)
2. **Constant-history models are structurally impossible** for G/H backward truth (report 07)
3. **Combined F-seed approaches are mathematically false** (report 07)
4. **x_content triviality** makes all x_content-based chain constructions degenerate (task 85)
5. **Proof-theoretic Case B** is blocked (plan 07 NO-GO)
6. **Chain-specific eventuality resolution** requires 20+ hours of new infrastructure (plan 08 NO-GO)

What SHOULD be preserved:
- BXCanonical/Frame.lean infrastructure (bx_le properties, bx_forward_witness, bx_backward_witness) -- these are sorry-free and useful
- BXCanonical/TruthLemma.lean (G_iff_mcs, H_iff_mcs, box_iff_mcs, until_iff_mcs, since_iff_mcs) -- the MCS-level truth lemma is correct; the gap is embedding it into a semantic model
- CanonicalEmbedding.lean fragment completeness -- sorry-free and a publishable result
- WitnessSeed.lean -- now sorry-free after task 86

What SHOULD be rebuilt:
- The canonical model construction: replace constant-history with a constructed chain
- The completeness proof: restructure to use chain-based truth lemma
- The CanonicalEmbedding.lean imp Case B: use chain-based countermodel instead of constant-history

**The incremental patching strategy has been exhausted.** 11 dead ends across 3 tasks (83, 84, 85-86) confirm this. A clean-sheet chain construction that directly builds a linear model (rather than trying to impose linearity on a branching canonical model) is the only viable path.

### 6. Literature-Based Analysis of the Construction Technique

From the temporal logic literature (Burgess 1982, Xu 1988, Venema 1993, Goldblatt 1992, Gabbay/Hodkinson/Reynolds 1994):

**The standard technique for Until/Since completeness** uses a "step-by-step" or "Henkin-style" construction:

1. Start with a consistent set of formulas
2. Enumerate all formulas (or a relevant subset)
3. At each step, either add the formula or its negation, maintaining consistency
4. Additionally, for each Until formula `phi U psi` added to the set at step n, ensure that some future step m > n has psi in its set, with phi in all intermediate sets
5. This creates a "deficiency" system that tracks unresolved eventualities
6. A dovetailing argument ensures all deficiencies are eventually resolved

**Key difference from standard modal Henkin construction**: The temporal construction builds a SINGLE chain (one model), not a global accessibility structure. The chain IS the model. Each point in the chain is an MCS that was specifically constructed to satisfy pending obligations.

**For S5 modal + temporal (the TM logic)**: The construction is more complex because at each time point, the modal S5 component requires an equivalence class of worlds (for the box modality). The standard approach:
- Build an Int-indexed chain of MCSs for the temporal dimension
- At each chain point, construct a set of modally equivalent MCSs for the S5 dimension
- The "canonical task model" has worlds = union of all modal equivalence classes at all chain points

This is essentially what the existing `canonical_task_frame` and `modal_omega` constructions do, but applied to a SINGLE constant history instead of a constructed chain.

**The fix**: Replace the constant history with the constructed chain. The modal dimension (modal_omega) can remain as-is -- it is parameterized by a BXPoint and works for any world.

### 7. Creative Alternatives

**Alternative A: General frames instead of Kripke frames**

General frames equip a Kripke frame with a set of "admissible" valuations, restricting which subsets count as propositions. Every normal modal logic is complete with respect to some class of general frames (even Kripke-incomplete logics). For temporal logic, general frames would allow us to restrict attention to valuations that are "temporally coherent" -- avoiding the need to prove properties for ALL possible MCS configurations.

**Assessment**: General frames are a powerful theoretical tool, but they would require rebuilding the entire semantic framework. The current `TaskFrame` semantics uses standard Kripke-style truth evaluation. Switching to general frames would mean redefining `truth_at`, `valid`, soundness, etc. This is a multi-month effort and not appropriate for closing 6 sorries.

**Confidence**: LOW for practical application. HIGH for theoretical elegance.

**Alternative B: Algebraic semantics (tense S5 algebras)**

The Lindenbaum-Tarski algebra of TM is a tense S5 algebra. The representation theorem for tense S5 algebras would give completeness via the algebraic route. The existing `Metalogic/Algebraic/` directory has infrastructure for this, including `TenseS5Algebra.lean` and `LindenbaumQuotient.lean`.

**Assessment**: The algebraic path has its own sorries (temp_l and temp_a removed in BX). More critically, the representation theorem for tense algebras with Until/Since operators requires the same chain construction -- the algebraic approach doesn't avoid the fundamental problem; it just phrases it differently (as "the Lindenbaum algebra is representable in a complete tense S5 algebra" rather than "the canonical model satisfies the truth lemma").

**Confidence**: LOW. Same fundamental obstacle repackaged.

**Alternative C: Avoid eventuality resolution entirely via FMP bridge**

The FMP path is completely sorry-free. If we could prove:

```
valid phi -> forall (S : ClosureMCSBundle phi), phi in S.carrier
```

then composing with `fmp_contrapositive` (sorry-free) gives full completeness. This bridge lemma says "every formula that is valid in all models is a member of every closure MCS." This is essentially the truth lemma restricted to the finite closure.

**Assessment**: The bridge lemma IS easier than the full truth lemma because:
1. It only needs to work for formulas in `subformulaClosure(phi)`, not all formulas
2. The closure MCS is finite, allowing inductive arguments
3. The FMP filtration already shows that closure MCSs "behave like" models

However, the bridge still requires embedding closure MCSs into semantic models (to connect "member of MCS" to "true in model"). This embedding is a restricted version of the canonical model construction. It might be tractable for the Until/Since case because the closure is finite and Until/Since eventualities within the closure form a finite, well-founded system.

**Confidence**: MEDIUM (50-60%). This is the most promising creative alternative. The finite closure constrains the problem in ways that the infinite canonical model does not. Worth a focused research spike.

**Alternative D: Two-phase completeness (USF first, then Until/Since by conservative extension)**

Prove USF completeness first (close the 1 remaining CanonicalEmbedding sorry). Then show that Until/Since is a conservative extension of the USF fragment -- i.e., any USF formula that is valid with Until/Since in the language is already valid without them.

**Assessment**: Conservative extension is the WRONG direction. We need to show that Until/Since formulas are DERIVABLE from the BX axioms when valid, not that they are conservative over USF. A formula like `G(p) -> p U G(p)` is valid and contains Until, so it must be derivable. Conservative extension doesn't help here.

**Confidence**: LOW. Wrong tool for the problem.

### 8. The "Quasimodel" Path: A Detailed Assessment

A quasimodel is a finite structure that captures the local consistency requirements of a model without requiring a full linear order. The technique (used for decidability of temporal logics with Until) works as follows:

1. Define a "type" as a maximally consistent set of formulas from the closure
2. A "run" is a sequence of types satisfying local consistency conditions
3. A quasimodel is a set of types with deficiency conditions ensuring eventualities are resolved
4. Quasimodels are finite (bounded by closure size)
5. If phi is satisfiable, it is satisfiable in a quasimodel

**For completeness**: If we could show that every quasimodel can be "unraveled" into a genuine linear model, we get:
- not provable -> consistent -> quasimodel exists -> genuine model exists -> not valid
- Contrapositive: valid -> provable

**Assessment**: The FMP/Decidability module already implements a version of this (ClosureMCSBundle is essentially a quasimodel type). The gap is the "unraveling" step -- going from a finite quasimodel to a genuine TaskModel. This is the same chain construction problem, just approached from the finite side.

**Confidence**: MEDIUM. The finite setting makes induction arguments more tractable, but the fundamental chain construction is still needed.

## Recommended Approach

### Strategic Recommendation: Two-Track Strategy

**Track 1 (Short-term, 8-12 hours): Close CanonicalEmbedding.lean:418 (imp Case B)**

The single sorry at CanonicalEmbedding.lean:418 is the closest to closure. It requires a non-constant-history countermodel for USF formulas. The approach:

1. For the specific MCS w with psi in w and chi not in w (where psi -> chi is USF and valid):
2. Build a two-point chain: {w, w'} where w' is an MCS chosen to make G/H non-trivial
3. Construct a history that visits both w and w' (non-constant)
4. Show that the bidirectional truth lemma works on this two-point model

This does NOT require solving the Until/Since problem (the formula is USF). It requires solving the G/H backward truth problem on non-constant histories.

**Expected outcome**: sorry-free `usf_completeness` -- a publishable result.

**Track 2 (Long-term, 20-40 hours): Clean chain construction for Until/Since**

Build a new `CanonicalChain.lean` module that:

1. Constructs an Int-indexed chain of BXPoints with dovetailed eventuality resolution
2. Proves chain-specific truth lemma for all formula types (including Until/Since)
3. Embeds the chain into a canonical TaskModel
4. Closes the Frame.lean sorries by instantiation (or replaces them entirely)
5. Closes the Completeness.lean sorry

This serves tasks 87 and 88 simultaneously and represents the full representation theorem.

**Expected outcome**: sorry-free `bx_completeness` -- the standard representation theorem.

### What NOT to Pursue

1. **Global bx_le linearity** -- proved impossible (report 08)
2. **Constant-history countermodels** for formulas with G/H -- proved impossible (report 07)
3. **Combined F-seed construction** -- proved mathematically false (report 07)
4. **Proof-theoretic Case B** -- reached NO-GO (plan 07)
5. **Patching DovetailedChain.lean** -- deprecated with 6 sorries from same X-vs-G mismatch
6. **Re-adding temp_linearity axiom** -- rejected for philosophical reasons (BX should be self-contained)

## Evidence/Examples

### Literature References

- **Burgess 1982**: "Axioms for tense logic I: Since and Until" -- foundational axiomatization and step-by-step Henkin completeness proof for Until/Since on reflexive linear orders
- **Xu 1988**: "On some U,S-tense logics" -- simplified the Burgess axiomatization; the Burgess-Xu system used in this project
- **Venema 1993**: "Completeness via completeness" -- extended axiomatizations to strict linear orderings, natural numbers, and well-orderings; key technique: connecting expressive completeness (Kamp) with axiomatic completeness
- **Goldblatt 1992**: "Logics of Time and Computation" -- canonical model construction for tense logics, including detailed treatment of eventuality resolution
- **Gabbay, Hodkinson, Reynolds 1994**: "Temporal Logic: Mathematical Foundations and Computational Aspects" -- comprehensive treatment including quasimodel technique, filtration, and completeness for various temporal logics on different frame classes
- **General frames**: Every normal modal/temporal logic is complete with respect to general frames (Wikipedia: General frame). Not practically applicable to this project but theoretically important.

### Codebase Evidence

- **Report 08** (bxle-linearity-research.md): Definitive proof that global bx_le linearity is mathematically impossible from BX axioms
- **Report 07** (team-research.md): All three known obstructions confirmed by all teammates; combined F-seed invalidated
- **Task 85** (team-research.md): x_content triviality discovered; Burgess-Xu axiom 4 invalidity confirmed; BXCanonical identified as most promising path
- **Plan 07** (proof-theoretic-plan.md): Proof-theoretic Case B reached NO-GO after 3 hours
- **Plan 08** (chain-eventuality-plan.md): Chain-specific eventuality resolution reached NO-GO; WitnessSeed sorries closed as partial progress
- **FMP path**: Zero sorries across all Decidability/FMP/*.lean files (verified by grep)
- **DovetailedChain.lean**: 6 sorries, all DEPRECATED with explicit "architectural limitation" markers

### Formal Verification of Key Claims

No formalizations of temporal logic completeness with Until/Since were found in Lean, Coq, or Isabelle. The Lean community has formalized S5 completeness (Bentzen) and propositional logic completeness (various), but temporal logic with binary temporal operators remains an open formalization target. This project would be a first if completed.

## Confidence Level

**Overall confidence**: MEDIUM-HIGH

| Claim | Confidence | Justification |
|-------|-----------|---------------|
| BXCanonical architecture cannot close Frame.lean sorries as-is | HIGH (95%) | Proved by report 08 (bx_le linearity impossible) and 11 dead ends |
| Clean chain construction is the right path forward | HIGH (90%) | Matches standard literature technique; addresses root cause |
| USF completeness (Track 1) is closable | MEDIUM-HIGH (75%) | 1 sorry, well-understood obstacle, needs non-constant history |
| Full completeness (Track 2) is achievable in 20-40 hours | MEDIUM (60%) | Requires new construction; no Lean precedent; complexity uncertain |
| FMP bridge (Alternative C) could be a shortcut | MEDIUM (50%) | Finite setting is more tractable; but still needs chain construction |
| This project would be first formalized Until/Since completeness | HIGH (95%) | No prior formalizations found in any proof assistant |

## Summary

The 6 remaining BXCanonical sorries stem from a fundamental architectural mismatch: the BXCanonical module uses a global canonical frame with a non-linear ordering, but Until/Since completeness requires a constructed linear chain. The standard representation theorem for tense logics with Until/Since (Burgess 1982, Xu 1988) uses a step-by-step Henkin construction that builds linearity by construction rather than proving it post-hoc. The project should pursue a two-track strategy: (1) close the USF completeness sorry (Track 1, 8-12 hours) for a near-term publishable result, and (2) build a clean chain construction module (Track 2, 20-40 hours) for the full representation theorem. The 11+ dead ends from incremental patching confirm that a clean-sheet design -- informed by all lessons learned -- is needed for Track 2.
