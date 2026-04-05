# Research Report: Task #83 — Tier 2 Path to Sorry-Free Completeness

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-05
**Mode**: Team Research (3 teammates)
**Session**: sess_1775406725_d2202a

## Summary

Three research teammates investigated the Tier 2 path to a fully sorry-free representation theorem and completeness result. The central finding is that **two viable paths exist**, with markedly different risk profiles. The **FMP-based completeness path** (Teammate B) is the lowest-risk option (20-35 hours, 85% confidence), leveraging entirely sorry-free FMP infrastructure already in the codebase. The **enhanced chain construction** (Teammate A, Goldblatt-style) is the more mathematically standard approach (25-40 hours, 60% confidence) but faces the same Until Transfer Lemma gap that has resisted 17+ research rounds. Crucially, Teammate C confirmed that **soundness is NOT a blocker** (all individual axiom validity lemmas are sorry-free), the **axiom system is complete** (matches and exceeds Burgess/Goldblatt/Reynolds), and all critical **existence lemmas are sorry-free** — the mathematical foundations are solid for either path.

## Key Findings

### 1. Two Viable Paths to Sorry-Free Completeness

| Path | Approach | New LOC | Hours | Confidence | Key Risk |
|------|----------|---------|-------|------------|----------|
| **A: FMP-based** | Complete filtration truth lemma, finite model arrangement | 600-1000 | 20-35 | HIGH (85%) | Temporal cases of filtration lemma |
| **B: F-resolving chain** | Round-robin Lindenbaum extension (Goldblatt Ch. 8) | 400-800 | 25-40 | MEDIUM (60%) | Until Transfer Lemma through non-x_content steps |

### 2. FMP Path: Finiteness Sidesteps the Infinite Chain Problem (Teammate B)

The FMP module is **entirely sorry-free**: Filtration.lean, FiniteModel.lean, FMP.lean, ClosureMCS.lean, TruthPreservation.lean — ~1000 lines of proven infrastructure. The key insight is that in finite models, **every eventuality MUST be resolved** by pigeonhole: if F(psi) is in a closure MCS and there are only N states, any fair walk through those states resolves F(psi) within N steps.

**Proof sketch**:
1. `mcs_finite_model_property`: not-provable -> exists finite closure MCS without phi (PROVEN)
2. Complete the filtration truth lemma: MCS membership <-> truth in filtered model
3. For temporal cases: closure MCSes are finite, so subformulaClosure(phi) bounds the universe
4. The filtered model has finitely many states — arrange using combinatorial/pigeonhole argument
5. Combined with FMP (valid -> valid_over_finite) gives completeness

**Critical caveat** (Teammate B, self-identified): The temporal filtration lemma may encounter the same forward_F issue in a different guise — F(psi) membership in a closure MCS must correspond to existence of a future witness in the filtered model. However, finiteness makes this a **bounded combinatorial problem** rather than an infinite chain construction. The closure MCS structure guarantees psi appears somewhere in the subformula closure.

### 3. Chain Construction Path: The Until Transfer Lemma is the Crux (Teammate A)

Published proofs (Burgess 1984, Goldblatt 1992, GHR 1994) all build F-resolution INTO the chain. The codebase has the key prerequisite — `temporal_theory_witness_exists` (sorry-free) — which given F(phi) in MCS M, produces MCS W with phi in W and G-theory agreement. The challenge is maintaining Until/Since coherence when the chain uses Lindenbaum extension (W) instead of x_content at F-resolution steps.

**The core tension identified by Teammate A**: x_content linkage gives `phi in chain(n+1) iff X(phi) in chain(n)`, which Until/Since proofs depend on. Lindenbaum extension preserves g_content (formulas under G) but Until obligations are under X (one-step), not G (persistent). When chain(n+1) = W instead of x_content(chain(n)), the biconditional breaks.

**Proposed resolution — Enhanced Seed**: At each Lindenbaum step, include not just g_content but also `until_obligations(chain(n)) = {psi v (phi AND (phi U psi)) : (phi U psi) in chain(n)}`. Consistency of this enhanced seed follows from: x_content(chain(n)) is an MCS containing both g_content and until_obligations. Adding the F-resolution target phi is consistent by `temporal_theory_witness_exists`.

**Risk**: This enhanced seed approach is novel and not yet verified. The interaction between the F-resolution target and until_obligations consistency needs careful proof.

### 4. Soundness is NOT a Blocker (Teammate C — HIGH confidence)

The 28 sorries in `Soundness.lean` are **architectural** (general theorem lacks frame constraints for discrete/dense axioms). All individual axiom validity lemmas — including **all 12 Until/Since axioms** — are proven sorry-free via `axiom_valid_discrete`. The only real soundness gap is `temporal_duality` (2 sorries in discrete soundness), which is a structural exercise (creating `SoundnessLemmasDiscrete.lean`), not a mathematical gap.

**For a "cutting no corners" result**: Soundness is not on the completeness critical path (completeness = valid -> provable, uses contrapositive: not-provable -> countermodel). But for a complete metatheory, the 2 `temporal_duality` sorries should be closed (8-12 hours, separate parallel track).

### 5. Axiom System is Complete (Teammate C — HIGH confidence)

All 12 Until/Since axioms match or exceed the standard Burgess/Goldblatt/Reynolds axiomatization:
- `until_unfold` / `since_unfold` (U1/S1)
- `until_intro` / `since_intro` (U2/S2)
- `until_induction` / `since_induction` (U3/S3)
- `until_linearity` / `since_linearity`
- `until_connectedness` / `since_connectedness`
- `F_until_equiv` / `P_since_equiv`

**No missing axioms identified.** This eliminates a major class of risk — the axiom system itself is not the blocker.

### 6. Existence Lemmas are Sorry-Free (Teammate C — HIGH confidence)

| Lemma | Status | What it gives |
|-------|--------|---------------|
| `temporal_theory_witness_exists` | Sorry-free | F(phi) in M -> exists W with phi in W, G-theory agreement |
| `past_theory_witness_exists` | Sorry-free | P(phi) in M -> exists W with phi in W, H-theory agreement |
| `box_theory_witness_exists` | Sorry-free | Diamond(phi) in M -> exists W with phi in W |
| `set_lindenbaum` | Sorry-free | Consistent set -> extends to MCS (Zorn) |
| `Denumerable Formula` | Instance | Bijection Formula <-> Nat (enables round-robin) |

These constitute the **complete mathematical bedrock** for any chain construction or model-building approach.

### 7. Approaches Ruled Out

| Approach | Hours | Why ruled out |
|----------|-------|---------------|
| GHR quasimodels | 40-60 | Entirely new infrastructure (2000-3000 LOC), incompatible with BFMCS/FMCS framework |
| Reynolds tableau | 30-50 | S5 modal integration untested, requires tableau-to-model extraction not in codebase |
| Algebraic bridge | 25-40 | Algebraic representation theorem does NOT give Kripke satisfiability — still needs temporal coherence |
| Publication without completeness | 0 | Does not meet "cutting no corners" requirement |

### 8. ParametricRepresentation is Fully Reusable (Teammate C)

The parametric framework (`ParametricRepresentation.lean`, `ParametricTruthLemma.lean`) is sorry-free and separates the chain construction from the truth lemma. Either path (FMP or chain) can plug into this framework:
- FMP path: provide a finite temporally-coherent BFMCS from the filtered model
- Chain path: provide an F-resolving chain BFMCS via `construct_bfmcs` callback

## Synthesis

### Conflicts Resolved

| Topic | Teammate A | Teammate B | Teammate C | Resolution |
|-------|-----------|-----------|-----------|------------|
| Best approach | Enhanced dovetailed chain (60%) | FMP-based completeness (85%) | Either works, foundations are solid (75%) | **Both viable; FMP is lower-risk primary, chain is mathematical fallback** |
| Does FMP sidestep forward_F? | N/A | Yes — finiteness forces resolution | Forward_F is unprovable for deterministic chains but may not apply to finite models | **Partially — FMP changes the problem from infinite chain F-resolution to finite combinatorial arrangement. The temporal filtration lemma is still nontrivial but structurally different.** |
| Risk of Until Transfer Lemma | Critical gap, novel approach | N/A (FMP avoids it) | MEDIUM (35%) that inserting witnesses breaks chain invariants | **Real risk. Enhanced seed approach plausible but unverified. FMP avoids this entirely.** |
| Soundness impact | Not analyzed | Not analyzed | NOT a blocker (individual lemmas all sorry-free) | **Soundness gap is cosmetic (architectural), not mathematical. Close separately.** |

### Gaps Identified

1. **FMP temporal filtration lemma**: TruthPreservation.lean has infrastructure but the full Until/Since cases are incomplete. This is the key gap for the FMP path. Teammate B calls it a "finite combinatorial problem" but it has not been attempted.

2. **Enhanced seed consistency proof**: Teammate A's proposed enhanced seed (g_content + until_obligations + F-target) needs a formal consistency argument. The claim that x_content(M) contains all three is sound but has not been mechanized.

3. **Omega-squared indexing design**: For the chain path, the interaction between deterministic x_content steps and Lindenbaum F-resolution steps needs a concrete indexing scheme. Teammate C's 2k+1/2k+2 interleaving is one option; Goldblatt's omega-squared is another.

4. **TaskFrame structure compatibility**: For FMP path, the filtered model must produce a TaskFrame (with specific constraints beyond linear ordering). This equivalence has not been analyzed.

### Recommendations

**Primary Path: FMP-Based Completeness** (20-35 hours, HIGH confidence 80%)

Rationale:
- Builds on ~1000 lines of zero-sorry FMP infrastructure
- Finiteness transforms the infinite chain F-resolution problem into a bounded combinatorial one
- Less new code (600-1000 LOC vs 400-800 LOC, but FMP has more existing foundation)
- Lower risk of encountering the same Until Transfer Lemma blocker
- The closure MCS structure already guarantees all relevant subformulas appear somewhere

Concrete next steps:
1. Audit TruthPreservation.lean to identify exact gaps in temporal filtration lemma
2. Prove the Until/Since cases using closure properties + finite model arrangement
3. Wire filtration truth lemma to completeness via FMP theorem
4. Produce sorry-free `completeness_over_Int` (or `completeness_finite`)

**Secondary Path: F-Resolving Chain Construction** (25-40 hours, MEDIUM confidence 60%)

If FMP path encounters unexpected blockers:
1. Build `FResolvingChain.lean` using Goldblatt Ch. 8 construction
2. Use `temporal_theory_witness_exists` + `Denumerable Formula` for round-robin
3. Prove Until Transfer Lemma via enhanced seed approach
4. Wire to `ParametricRepresentation` via `construct_bfmcs` callback

**Parallel Track: Soundness Closure** (8-12 hours, independent)

Close the 2 `temporal_duality` sorries by creating `SoundnessLemmasDiscrete.lean`. This is independent of both completeness paths and gives a fully sorry-free metatheory.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | F-resolution chain constructions | Completed | MEDIUM (60%) | Analyzed Burgess/Goldblatt/GHR, identified core x_content vs Lindenbaum tension, proposed enhanced seed approach |
| B | Alternative approaches | Completed | HIGH (85%) | Comprehensive comparison matrix, identified FMP as lowest-risk path, ruled out algebraic bridge and GHR |
| C | Mathematical foundations audit | Completed | MEDIUM-HIGH (75%) | Confirmed soundness non-blocker, axiom completeness, existence lemma availability, Denumerable Formula |

## Critical Action Items

1. **Choose primary path**: FMP-based (recommended) or chain construction
2. **Audit TruthPreservation.lean**: Identify exact gaps in temporal filtration lemma — this is the decision point for FMP viability
3. **Close backward Until/Since**: Still highest-value immediate step regardless of path choice (from plan v18, Phase 2)
4. **Close temporal_duality soundness**: Parallel track for complete metatheory

## References

- Burgess, J. (1984). "Basic Tense Logic" in Handbook of Philosophical Logic, Vol. II
- Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed. CSLI Publications, Chapter 8
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic*, Vol. 1. Oxford University Press
- Reynolds, M. (2003). "An Axiomatization of Full Computation Tree Logic"
- Blackburn, de Rijke, Venema (2001). *Modal Logic*. Cambridge University Press, Ch 2.3 (Filtrations)
- Venema (1993). Extensions of Burgess-Xu axiomatization for discrete linear orderings
