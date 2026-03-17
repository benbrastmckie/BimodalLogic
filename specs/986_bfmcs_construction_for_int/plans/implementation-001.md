# Implementation Plan: BFMCS Construction for Int

- **Task**: 986 - bfmcs_construction_for_int
- **Status**: [PARTIAL]
- **Effort**: 5 hours
- **Dependencies**: Task 985 (completed - provides algebraic infrastructure)
- **Research Inputs**: specs/986_bfmcs_construction_for_int/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Provide a sorry-free `construct_bfmcs` function of type `(M : Set Formula) -> SetMaximalConsistent M -> Sigma' (B : BFMCS Int) (h_tc : B.temporally_coherent) (fam : FMCS Int) (hfam : fam in B.families) (t : Int), M = fam.mcs t`, which is the core argument needed by `parametric_algebraic_representation_conditional` in DiscreteInstantiation.lean. The construction uses an omega-chain approach: given root MCS M0, build a bi-infinite chain `c : Int -> Set Formula` where each `c(t)` is an MCS, consecutive elements are CanonicalR-related, and F/P witness obligations are satisfied via dovetailing enumeration of formulas.

### Research Integration

Research report research-001.md identified three approaches:
1. **Order-Embedding Transfer** (recommended): Map Int to CanonicalMCS chain
2. **DovetailingChain Fix**: Fix deprecated DovetailingChain sorries
3. **Direct Construction**: Build FMCS Int from scratch

This plan uses a **hybrid approach**: a direct chain construction that leverages the proven `canonical_forward_F` and `canonical_backward_P` lemmas from CanonicalFMCS.lean, but builds the Int-indexed chain step by step using a dovetailing enumeration to ensure all F/P obligations are met.

## Goals & Non-Goals

**Goals**:
- Provide sorry-free `construct_bfmcs_int : (M : Set Formula) -> SetMaximalConsistent M -> Sigma' ...`
- Wire it into `DiscreteInstantiation.lean` to produce `discrete_algebraic_representation`
- Ensure `lake build` passes with zero new sorries

**Non-Goals**:
- Fixing the deprecated DovetailingChain in Boneyard
- Proving D-from-syntax completeness (this is D-parametric algebraic approach)
- Building infrastructure beyond what `construct_bfmcs` requires

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multiple F-obligations at same time cannot be simultaneously satisfied by one successor MCS | High | Medium | Use dovetailing: spread obligations across multiple successor steps. Each step handles one obligation. |
| Backward P-witness construction requires past MCS not yet in chain | High | Medium | Build chain in both directions simultaneously using well-founded recursion on |t|. |
| CanonicalR transitivity chain breaks when inserting witness MCSes | Medium | Low | Ensure each step maintains CanonicalR between consecutive elements using g_content subset properties. |
| Construction is noncomputable and Lean has issues with large noncomputable definitions | Low | Low | Factor into small lemmas; use `noncomputable` section. |

## Sorry Characterization

### Pre-existing Sorries
- 0 sorries in CanonicalFMCS.lean (template - all proven)
- 0 sorries in DiscreteInstantiation.lean (conditional formulation)
- 2 sorries in deprecated DovetailingChain.lean (Boneyard, not in scope)

### Expected Resolution
- No pre-existing sorries to resolve. This task creates new sorry-free code.

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in new IntBFMCS module
- DiscreteInstantiation gains unconditional representation theorem
- Publication no longer blocked by missing BFMCS construction for Int

## Implementation Phases

### Phase 1: Chain Construction Core [COMPLETED]

- **Dependencies:** None
- **Goal:** Define the bi-infinite chain `c : Int -> Set Formula` where consecutive elements are CanonicalR-related and a designated root MCS appears at index 0.

**Tasks:**
- [x] Create `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` with imports from CanonicalFMCS, TemporalCoherence, DiscreteSuccSeed, CanonicalTimeline
- [x] Define `successorMCS`: given an MCS `M`, produce a successor MCS `M'` with `CanonicalR M M'`, using g_content-based Lindenbaum extension
- [x] Define `predecessorMCS`: given an MCS `M`, produce a predecessor MCS `M'` with `CanonicalR M' M`, using h_content-based construction
- [x] Define `posChain` and `negChain` via Nat recursion
- [x] Define `intChainMCS : Int -> Set Formula` combining posChain and negChain
- [x] Prove `intChainMCS_is_mcs`: each `c(t)` is an MCS
- [x] Prove `posChain_canonicalR`: `CanonicalR (c n) (c (n+1))` for positive chain
- [x] Prove `negChain_canonicalR`: `CanonicalR (c (n+1)) (c n)` for negative chain
- [x] Prove `h_content_consistent`: symmetric to existing `g_content_consistent`
- [x] Prove `intChain_forward_G`: G propagation through chain
- [x] Prove `intChain_backward_H`: H propagation through chain

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` (new file)

**Verification:**
- [x] `lake build Bimodal.Metalogic.Algebraic.IntBFMCS` compiles
- [x] `lean_goal` shows no sorry-requiring goals for G/H proofs
- [ ] `grep -n "\bsorry\b" IntBFMCS.lean` returns empty (2 remain: forward_F, backward_P)

**Progress:**

**Session: 2026-03-17, sess_1773752190_077933**
- Added: `successorMCS`, `predecessorMCS` - MCS successor/predecessor construction via Lindenbaum
- Added: `posChain`, `negChain`, `intChainMCS` - Int-indexed chain definitions
- Added: `intChainMCS_is_mcs` - proves each chain element is MCS
- Added: `posChain_canonicalR`, `negChain_canonicalR` - CanonicalR between consecutive elements
- Added: `h_content_consistent` - h_content of MCS is consistent (symmetric to g_content_consistent)
- Sorries: 4 remaining (intChain_forward_G, intChain_backward_H, intFMCS_forward_F, intFMCS_backward_P)
- Blocker: forward_G/backward_H require proof of G/H propagation through CanonicalR chain across positive/negative index boundary

**Session: 2026-03-17, sess_1773754705_cfda86**
- Added: `intChain_canonicalR` - CanonicalR holds for all adjacent pairs in Int chain (handles boundary cases)
- Added: `intChain_G_propagates` - G-formula preservation along chain via induction
- Completed: `intChain_forward_G` - sorry-free proof using induction and canonicalR_propagates_G/GG
- Added: `intChain_canonicalR_past` - CanonicalR_past via g/h duality
- Added: `canonicalR_past_propagates_H`, `canonicalR_past_propagates_HH` - H propagation helpers
- Added: `intChain_H_propagates` - H-formula preservation along chain via induction
- Completed: `intChain_backward_H` - sorry-free proof symmetric to forward_G
- Sorries: 2 remaining (intFMCS_forward_F, intFMCS_backward_P)

---

### Phase 2: FMCS Int with G/H Coherence [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Wrap the chain into an `FMCS Int` with proven forward_G and backward_H.

**Tasks:**
- [x] Define `intFMCS_basic : (M0 : Set Formula) -> SetMaximalConsistent M0 -> FMCS Int`
- [x] Prove `forward_G`: If `G(phi) in c(t)` and `t < t'`, then `phi in c(t')`. Strategy: induction on `t' - t`, using CanonicalR transitivity and `canonical_forward_G`.
- [x] Prove `backward_H`: If `H(phi) in c(t)` and `t' < t`, then `phi in c(t')`. Strategy: symmetric to forward_G using h_content/g_content duality.

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`

**Verification:**
- [x] `intFMCS_basic` compiles with type `FMCS Int`
- [x] No sorry in forward_G or backward_H proofs
- [x] `lake build` passes

**Progress:**

**Session: 2026-03-17, sess_1773754705_cfda86**
- `intFMCS_basic` defined and compiles with `FMCS Int` type
- forward_G and backward_H are sorry-free (proven in Phase 1)

---

### Phase 3: Forward_F and Backward_P via Dovetailing [BLOCKED]

- **Dependencies:** Phase 2
- **Goal:** Prove that the chain satisfies forward_F and backward_P temporal coherence.

This is the core mathematical challenge. Two sub-approaches were considered:

**Sub-approach A (Preferred): Enriched chain construction.** Modify the chain construction from Phase 1 so that `ChainStep` at position `t` produces a successor that satisfies `phi in c(t+1)` for a specific phi determined by a dovetailing schedule. Since formulas are countably enumerable, we can enumerate all `(t, phi)` pairs where `F(phi) in c(t)` and ensure each is witnessed. Similarly for backward P.

**Sub-approach B (Fallback): Post-hoc witness existence.** Keep the simple chain from Phase 1 but prove that for any `F(phi) in c(t)`, the witness MCS from `canonical_forward_F` lies somewhere in the chain. This is harder and may not hold for a naive chain.

**Tasks (Sub-approach A):**
- [ ] Define `FormulaEnumeration`: countable enumeration of Formula (may need Mathlib's Countable instance or a manual definition)
- [ ] Define `dovetail_schedule : Nat -> (Int x Formula x Direction)` that enumerates all obligation triples
- [ ] Redefine `ChainStep` to accept a "target formula" parameter: given MCS M and formula phi where `F(phi) in M`, produce successor M' with `CanonicalR M M'` AND `phi in M'`. This follows directly from `canonical_forward_F`.
- [ ] Redefine `PastStep` similarly using `canonical_backward_P`
- [ ] Prove `forward_F`: given `F(phi) in c(t)`, the dovetailing schedule eventually processes this obligation at some step `s > t`, and `phi in c(s)` by construction
- [ ] Prove `backward_P`: symmetric argument for past direction

**Tasks (Sub-approach B - only if A is infeasible):**
- [x] Sub-approach B is INFEASIBLE: the simple chain does not guarantee witnesses land in chain range

**Timing:** 1.5 hours (estimated for implementation if approach were feasible)

**Blocker Analysis:**

The F/P witness problem is a fundamental architectural limitation:

1. **The simple chain approach** (Phase 1's `successorMCS`/`predecessorMCS`) constructs each chain element as `Lindenbaum(g_content(prev))` or `Lindenbaum(h_content(prev))`. This does NOT include any specific F/P witness formulas.

2. **The `canonical_forward_F` lemma** gives us a witness MCS W for any F(phi) obligation, but W is constructed as `Lindenbaum({phi} ∪ g_content(M))`. This W is SOME MCS in the space of all MCSes, but there is no guarantee that W equals `intChainMCS s` for any specific s.

3. **The DovetailingChain in Boneyard** has the same 2 sorries (forward_F, backward_P) with a comment: "The remaining 2 sorries cannot be resolved for this linear chain construction because F-formulas do not persist through GContent seeds."

4. **Implementing enriched dovetailing** requires a complex construction:
   - Define formula enumeration
   - Define obligation schedule
   - Redefine chain construction to accept witness targets
   - Prove schedule eventually covers all obligations
   - This is significant additional work (~4-6 hours)

**Progress:**

**Session: 2026-03-17, sess_1773754705_cfda86**
- Analyzed both sub-approaches
- Confirmed Sub-approach B is infeasible for simple chain
- Sub-approach A requires significant refactoring not in scope for current iteration
- 2 sorries remain: `intFMCS_forward_F`, `intFMCS_backward_P`
- Marked phase BLOCKED pending architectural decision

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`

**Verification:**
- `forward_F` and `backward_P` proven without sorry
- `lean_goal` at each proof point shows "no goals"

---

### Phase 4: BFMCS Int Construction and Wiring [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Construct the full `BFMCS Int` (with modal coherence) and wire `construct_bfmcs_int` into DiscreteInstantiation.lean.

**Tasks:**
- [ ] Construct a modally saturated `BFMCS Int` containing the chain FMCS. Strategy: use the existing `ModalSaturation` infrastructure - start with a single family, then saturate by adding witness families for all Diamond formulas.
- [ ] Prove `temporal_coherence`: all families in the BFMCS satisfy forward_F and backward_P. Each family is built from the same chain construction, so inherits temporal coherence.
- [ ] Define `construct_bfmcs_int : (M : Set Formula) -> SetMaximalConsistent M -> Sigma' (B : BFMCS Int) (h_tc : B.temporally_coherent) (fam : FMCS Int) (hfam : fam in B.families) (t : Int), M = fam.mcs t`
- [ ] Wire into `DiscreteInstantiation.lean`: add `discrete_algebraic_representation` theorem using `construct_bfmcs_int`
- [ ] Add import of IntBFMCS to DiscreteInstantiation

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean`

**Verification:**
- `construct_bfmcs_int` has correct type signature
- `discrete_algebraic_representation` compiles
- `lake build` passes with zero sorries in modified files

---

### Phase 5: Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Full build verification, sorry audit, and cleanup.

**Tasks:**
- [ ] Run `lake build` for full project
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` to confirm zero sorries
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` to confirm zero sorries
- [ ] Run `grep -n "^axiom " Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` to confirm no new axioms
- [ ] Verify `construct_bfmcs_int` with `lean_verify` if available
- [ ] Clean up any unused imports or dead code

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` (cleanup only)
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` (cleanup only)

**Verification:**
- `lake build` passes cleanly
- Zero sorries in all modified files
- Zero new axioms
- All proofs verified

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` returns empty (zero-debt gate)
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Integration Tests
- [ ] `discrete_algebraic_representation` theorem compiles and has expected type
- [ ] `construct_bfmcs_int` can be called with any MCS argument
- [ ] No downstream build breaks

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` (new file - BFMCS construction for Int)
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` (modified - wired representation theorem)
- `specs/986_bfmcs_construction_for_int/plans/implementation-001.md` (this plan)
- `specs/986_bfmcs_construction_for_int/summaries/implementation-summary-YYYYMMDD.md` (upon completion)

## Rollback/Contingency

- If the dovetailing approach (Phase 3) proves infeasible:
  - Mark Phase 3 [BLOCKED] with `requires_user_review: true`
  - Consider alternative: use CanonicalMCS-indexed BFMCS with a type-level embedding from Int (requires changes to ParametricRepresentation to accept a more general D)
  - Consider alternative: weaken the theorem to conditional form that assumes a countable chain exists
- If the modal saturation step (Phase 4) is problematic:
  - Use a single-family approach if modal backward can be proven for the specific chain construction
- All new code is in a new file (IntBFMCS.lean), so rollback is trivial: delete the file and revert DiscreteInstantiation changes
