# Teammate B Findings: Documentation and Comments Cleanup

## Summary

The source files and task artifacts contain a mixture of well-documented blockers and subtly misleading content. The most dangerous category is **optimistic framing of the dovetailing chain's witness placement mechanism** -- comments in DovetailingChain.lean describe a witness placement scheme (lines 38-46, 518-519) that DOES fire psi into the chain, but cannot guarantee psi is at a *strictly future* position because F-persistence through GContent seeds is impossible. The second category is **stale references to abandoned approaches** (RecursiveSeed, constant family oracle) that remain in docstrings. These two categories explain why agents repeatedly attempt linear chain approaches: the code literally says "This enables the forward_F coverage argument" (line 520) and builds the witness infrastructure, creating the illusion that forward_F is close to provable.

## Misleading Content Found

### In Source Files

| File | Line(s) | Current Text | Problem | Recommended Fix |
|------|---------|--------------|---------|-----------------|
| DovetailingChain.lean | 38-46 | "F-witness formulas via dovetailing enumeration" / "P-witness formulas via dovetailing enumeration" in module doc | **HIGH PRIORITY**: The module doc lists F/P witness enumeration as part of the construction, implying these witnesses solve forward_F. They do NOT -- they place psi but cannot guarantee F(psi) persists to the witness step. | Add warning: "Note: while the construction places witnesses, the F-persistence problem (F-formulas are invisible to GContent seeds) prevents proving that F(psi) survives to the witness step. See 'Technical Debt' section below." |
| DovetailingChain.lean | 518-520 | "With witness placement: if F(psi_n) is alive at step n, then psi_n is placed in the seed for step n+1 (via ForwardTemporalWitnessSeed). **This enables the forward_F coverage argument.**" | **CRITICAL MISLEADER**: The phrase "enables the forward_F coverage argument" is FALSE -- the coverage argument is proven (line 1530), but it has a precondition `h_F : Formula.some_future psi in chain(n)` that CANNOT be satisfied because F(psi) may have been killed before step n. The coverage infrastructure is correct but insufficient. | Replace with: "With witness placement: if F(psi_n) is alive at step n, then psi_n is placed in the seed for step n+1. However, F(psi) may be killed by G(neg psi) entering via Lindenbaum extension at any earlier step, making this coverage mechanism insufficient for forward_F (see Technical Debt section)." |
| DovetailingChain.lean | 548-550 | Same pattern for backward chain: "**This enables the backward_P coverage argument.**" | Same problem as line 520 for the backward direction. | Same fix pattern: add caveat about P-persistence failure. |
| DovetailingChain.lean | 43-44 | "When processing pair (s, psi) at step n... include psi in seed_t" | Module header describes F/P witness enumeration mechanism without any caveat that this mechanism is insufficient. | Add explicit caveat inline. |
| TemporalCoherentConstruction.lean | 559-564 | "This construction produces a NON-CONSTANT family ... that satisfies: forward_F: F phi in M_t -> exists s > t, phi in M_s (by dovetailing enumeration)" | **HIGH PRIORITY**: This docstring claims the dovetailing construction satisfies forward_F. It does NOT -- DovetailingChain.lean has sorry at this exact proof. The claim "by dovetailing enumeration" is aspirational, not factual. | Replace with: "This construction aims to produce ... forward_F and backward_P remain as sorry debt because the dovetailing enumeration cannot guarantee F-persistence (see DovetailingChain.lean Technical Debt section)." |
| TemporalCoherentConstruction.lean | 577-590 | Docstring references "RecursiveSeed approach" and "Task 864" | **STALE**: RecursiveSeed is in the Boneyard (abandoned). The docstring describes an approach that no longer exists in active code, creating confusion about what strategy is actually in use. | Remove RecursiveSeed references entirely. Replace with: "Delegates to DovetailingChain.temporal_coherent_family_exists_theorem. The forward_F and backward_P components rely on sorry in DovetailingChain.lean." |
| TemporalCoherentConstruction.lean | 619-624 | "The RecursiveSeed construction pre-places temporal witnesses during seed building" | **STALE**: Same RecursiveSeed reference in the generic version's docstring. | Mark as historical or remove. |
| WitnessGraph.lean | 2418-2438 | "Approach: Constant Family with Witness Graph Oracle" section describes using constant family as skeleton and deferring F/P to Phase 5 | **MISLEADING by omission**: Does not say the constant family approach for forward_F was attempted and FAILED (the oracle bridge doesn't work because F(psi) in rootMCS does not imply psi in rootMCS). The progress notes at line 284-300 of the plan document this failure, but the code comment does not. | Add: "NOTE: The constant family approach was later found insufficient for forward_F because F(psi) in rootMCS does not imply psi in rootMCS. The witness graph oracle provides local witnesses but these cannot be bridged to the constant family. See Phase 5B progress notes." |
| WitnessGraph.lean | 2467-2473 | `witnessGraphBFMCS` docstring: "This provides the structural skeleton for the completeness proof" | **MISLEADING**: This constant family is NOT used for forward_F/backward_P. It provides forward_G and backward_H only. Saying it provides "the structural skeleton" implies forward_F will be added to it, but the architecture requires a fundamentally different construction. | Add: "This BFMCS provides forward_G and backward_H only. Forward_F and backward_P require a non-constant construction (see enrichedChainBFMCS or a future witness-graph-guided construction)." |
| WitnessGraph.lean | 2534-2538 | "These lemmas connect the witness graph's local properties to the BFMCS, enabling Phase 5 to prove forward_F and backward_P." | **MISLEADING**: Phase 5 did NOT succeed in proving forward_F/backward_P. The lemmas exist but the bridge is incomplete. | Change to: "These lemmas were intended to connect... but the bridge from local witnesses to a global BFMCS construction remains incomplete. Forward_F/backward_P require a non-constant embedding strategy." |
| DovetailingChain.lean | 1403-1406 | "F-formula dichotomy in the forward witness chain: for any formula psi, at any step n, either F(psi) is in the chain or its negation G(neg(psi)) is." | **MISLEADING by context**: While technically correct (it's just MCS negation completeness), the naming "F-formula dichotomy" and its placement in the "F/P coverage" section implies this is building toward a forward_F proof. An agent reading sequentially sees: dichotomy -> persistence -> coverage -> forward_F, and thinks the proof is nearly complete. | Add comment: "Note: while F(psi) or G(neg psi) must hold at each step, the choice is not stable across steps. G(neg psi) can enter at any step through Lindenbaum extension, killing F(psi). This instability is the root cause of the forward_F sorry." |
| DovetailingChain.lean | 1523-1527 | "Coverage with persistence" lemma docstring | **MISLEADING by name**: The lemma IS correct, but "coverage with persistence" suggests the persistence problem is solved. In reality, the hypothesis `h_F : Formula.some_future psi in chain(n)` requires F-persistence to step n, which cannot be established. | Add: "The precondition `h_F` (F(psi) at step n) cannot in general be established because F-formulas may be killed by Lindenbaum extensions at earlier steps." |

### In Task Artifacts

| File | Section | Problem | Recommended Fix |
|------|---------|---------|-----------------|
| implementation-011.md, Phase 5B | Lines 200-300 | Plan describes forward_F as achievable via "witness graph as oracle" using constant family, then documents in progress notes that this FAILED | The plan body should be updated to mark the constant family oracle approach as definitively blocked, not just in progress notes. Progress notes are easy to miss. | Add a warning box at top of Phase 5B: "APPROACH BLOCKED: The constant family oracle approach (described below) was attempted and found mathematically impossible. See progress notes." |
| implementation-011.md, Phase 5C | Lines 304-354 | Phase 5C exit criteria show "[x] WitnessGraph.lean: 0 sorries" but the note says this was achieved by REMOVING the unprovable theorems, not proving them. | The exit criterion `witnessGraphBFMCS_backward_P proven (0 sorries)` is checked as "not applicable" style, which is confusing. The unchecked criterion should explicitly state the theorem was removed. | Change: "- [ ] `witnessGraphBFMCS_backward_P` proven (0 sorries)" to "- [REMOVED] `enrichedBackwardChain_backward_P` removed (mathematically impossible for linear chain)" |
| implementation-011.md, Phase 6 | Lines 357-399 | Phase 6 describes wiring forward_F/backward_P into DovetailingChain.lean as if these proofs will exist. | Phase 6 should acknowledge that the proofs don't exist yet and the wiring cannot proceed until a non-linear construction is built. | Add: "BLOCKED: Phases 5B/5C did not produce forward_F/backward_P proofs. This phase requires a fundamentally new construction." |
| research-001.md | Lines 45-59 | Sorry 3 analysis: "The chain construction must explicitly arrange for [witness scheduling]" | **OUTDATED**: This is from the earliest research, before the F-persistence problem was understood. It implies the chain construction CAN arrange for witness scheduling, when in fact it CANNOT due to GContent opacity. | Mark as superseded by research-003/008/014. |
| research-003.md | Lines 31-44 | "The Viable Path: Augmented Dovetailing (D + Omega^2)" | **PARTIALLY OUTDATED**: Research-014 (the latest synthesis) confirms omega-squared directed limit approach has been blocked (research-004: "generalized seed consistency is FALSE"). The omega-squared approach described here was later found unviable. | Add note: "UPDATE (research-014): The omega-squared directed limit approach was found to have a false prerequisite (generalized seed consistency). The viable variant is the step-by-step WitnessGraph approach." |

## Missing Critical Warnings

### 1. No "DO NOT TRY" List at BFMCS Definition Site

`Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` defines the structure that every implementation must satisfy, but contains no warning about the forward_F/backward_P difficulty. An agent starting fresh will see forward_G and backward_H in the structure, then look for forward_F and backward_P, and attempt a linear chain.

**Recommendation**: Add a `/-! ## Warning: forward_F and backward_P -/` section in BFMCS.lean near lines 30-40 stating:
- Forward_F and backward_P are NOT fields of BFMCS (proven separately)
- Linear chain constructions CANNOT satisfy forward_F (14 research reports confirm this)
- The only viable approach is the WitnessGraph (deferred concretization)
- Blocked approaches: constant family, enriched chain, F-preserving seed, derivation surgery, omega-squared directed limit

### 2. GContent Stripping Not Documented at GContent Definition

The `GContent` definition in `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` does not document that it strips F-formulas. An agent reading GContent will see `{phi : G(phi) in M}` and may not realize that F-formulas are invisible to it.

**Recommendation**: Add to TemporalContent.lean's GContent docstring:
"IMPORTANT: GContent only carries formulas of the form phi where G(phi) is in M. F-formulas (F(psi) = neg(G(neg psi))) are NOT in GContent form and will NOT be propagated through GContent-based chain extensions. This is the root cause of the forward_F sorry in DovetailingChain.lean."

### 3. No Warning at Lindenbaum Extension

The `set_lindenbaum` function (used everywhere in chain construction) produces a maximal consistent extension via `Classical.choose`, meaning the extension can contain ANY consistent formula -- including G(neg psi) which kills F(psi). There is no warning about this opacity.

**Recommendation**: Add docstring note to set_lindenbaum or at chain construction sites:
"The Lindenbaum extension is opaque (uses Classical.choose). The resulting MCS may contain G(neg psi) even when the seed contains F(psi), because {F(psi), G(neg psi)} is inconsistent but the extension process may include G(neg psi) and exclude F(psi)."

### 4. No Consolidated "Blocked Approaches" Document

Each research report individually describes what was tried and why it failed, but there is no single consolidated document listing ALL blocked approaches with their fatal blockers. Agents must read 14 research reports to understand the full picture.

**Recommendation**: Create `specs/916_implement_fp_witness_obligation_tracking/BLOCKED_APPROACHES.md` with:
- Table of all 8+ blocked approaches with 1-line reason
- Reference to the research report that established the block
- The ONE viable path (WitnessGraph deferred concretization)

## Root Cause of Diversion

Agents keep trying linear chain approaches because of **three reinforcing factors**:

### Factor 1: The Code Tells a Compelling (But Incomplete) Story

DovetailingChain.lean has ~500 lines of sorry-free infrastructure for witness placement, F-persistence, coverage, and dichotomy (lines 1380-1555). These lemmas are correct and build upon each other logically:
1. `witnessForwardChain_F_dichotomy` -- at each step, F or G(neg) holds (correct)
2. `witnessForwardChain_F_persists_if_not_killed` -- if G(neg) is absent, F survives (correct)
3. `witnessForwardChain_coverage_of_le` -- if F survives to step k, witness fires (correct)
4. `witnessForwardChain_F_persists` -- F persists from 0 to n IF not killed (correct)

An agent reads these and concludes: "The proof is 90% done, I just need to show F isn't killed." But showing F isn't killed is PRECISELY the thing that's impossible -- the Lindenbaum extension CAN kill it at any step.

### Factor 2: The Module Doc Claims forward_F Is Part of the Design

Lines 38-46 of DovetailingChain.lean describe "F-witness formulas via dovetailing enumeration" as an integral part of the construction. Lines 518-520 say the mechanism "enables the forward_F coverage argument." This strongly implies the construction was designed to handle forward_F, and the sorry is just a proof engineering gap.

### Factor 3: Stale References Create False Hope

The TemporalCoherentConstruction.lean docstring (lines 559-564) claims the dovetailing construction satisfies forward_F "by dovetailing enumeration." The RecursiveSeed references (lines 577-624) describe an alternative approach that was abandoned and moved to the Boneyard. These stale references make agents believe there are multiple viable paths, when in fact all paths through the linear chain are blocked.

### The Fix

The fundamental fix is to make the **impossibility** as prominent as the **infrastructure**. Every comment that says "this enables..." or "this provides..." for forward_F should be paired with "...but this is insufficient because F-persistence cannot be guaranteed." The module doc should lead with the sorry debt explanation, not bury it after 50 lines of construction description.

## Confidence Level

**High** -- The analysis is based on direct reading of source code, all 14 research reports, 11 plan versions, and 4 handoff documents. The misleading content patterns are concrete and verifiable by line number. The root cause analysis is consistent with the documented failure pattern (3+ implementation iterations reverting to linear chains).
