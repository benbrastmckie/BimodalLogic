# Implementation Plan: F/P Witness via Ultrafilter Chain with Zorn's Lemma

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (builds on sorry-free infrastructure in UltrafilterChain.lean)
- **Research Inputs**: reports/15_algebraic-temporal-shift.md, reports/14_fuel-approach-review.md, summaries/14_execution-summary.md
- **Artifacts**: plans/15_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the single remaining completeness sorry (`bfmcs_from_mcs_temporally_coherent` at Completeness.lean:237) by constructing a temporally coherent ultrafilter chain using Zorn's lemma on partial chains. The approach builds exclusively on sorry-free ultrafilter infrastructure: `ultrafilter_F_resolution`, `ultrafilter_P_resolution`, `UltrafilterChain_to_FMCS`, and `boxClassFamilies`. The central idea is Strategy D from the research report: define a partial order on finite-interval chains satisfying all F/P obligations within their domain, then extract a total chain via Zorn's lemma.

### Research Integration

- **Report 15 (algebraic-temporal-shift)**: Confirms G is not an automorphism; identifies R_G action on ultrafilters as the correct framework. Recommends Strategy D (Zorn on partial chains) when F-persistence fails. Documents sorry-free `ultrafilter_F_resolution` (326 lines, fully proven).
- **Report 14 (fuel-approach-review)**: Documents that fuel-based approaches are dead ends due to conflating F-nesting depth (bounded) with persistence count (unbounded). Eliminates fuel from consideration.
- **Summary 14 (execution-summary)**: Documents that enriched seed approaches (`{target} union constrained_successor_seed`) are provably inconsistent. Eliminates seed enrichment from consideration.
- **ROADMAP.md**: Confirms algebraic/ultrafilter path as the intended approach (lines 91-139). Documents all dead ends.

## Goals & Non-Goals

**Goals**:
- Prove `bfmcs_from_mcs_temporally_coherent` sorry-free, closing the completeness gap
- Construct family-level `forward_F` and `backward_P` for ultrafilter chains
- Use Zorn's lemma (Mathlib) on partial chains to compose single-step F/P witnesses into full chains
- Maintain all existing sorry-free infrastructure intact

**Non-Goals**:
- Fuel-based approaches (known dead end, tasks 48/67, report 14)
- Enriched seed approaches (provably inconsistent, summary 14)
- Bidirectional temporal witness seed (H-theory not G-liftable, ROADMAP line 175)
- Bundle-level coherence as a substitute for family-level (semantically wrong, ROADMAP line 158)
- Modifying the existing `UltrafilterChain` structure or `ultrafilter_F_resolution` proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F-persistence fails at ultrafilter level (F(phi) does not persist along R_G chains) | H | H | Strategy D (Zorn on partial chains) does not require persistence -- it builds chains that already satisfy all obligations within their domain |
| Zorn's lemma application is complex in Lean/Mathlib | M | M | Use Mathlib's `zorn_preorder` or `Zorn.exists_maximal_of_chains_bounded`; the partial order on interval chains by extension is straightforward |
| Partial chain limit step (directed union) fails to be a partial chain | H | L | The union of compatible partial chains inherits R_G connectivity and all F/P satisfaction from components; verify this carefully in Phase 2 |
| Extension step (adding one more time point) fails | H | L | `ultrafilter_F_resolution` (sorry-free) provides the single-step extension; the scheduling argument ensures the right obligation is targeted |
| `UltrafilterChain_to_FMCS` bridge does not transfer forward_F | M | L | The bridge already transfers forward_G and backward_H; forward_F is a property of the chain itself, transferred via `mem_UltrafilterChain_FMCS_iff` |

## Implementation Phases

### Phase 1: Investigate F-Persistence and Define Partial Chain [BLOCKED]

**Goal:** Determine whether F(phi) persists along R_G chains, and define the partial chain structure for the Zorn construction.

**Tasks:**
- [ ] Check whether `a <= G(F(a))` holds in the STSA (would give F-persistence via the TA axiom pattern). Use `lean_goal` and `lean_multi_attempt` at the Lindenbaum algebra level.
- [ ] If F-persistence holds: document the proof and note that fair scheduling (simpler approach) becomes viable. Proceed to Phase 2 with fair-scheduled chain.
- [ ] If F-persistence fails (likely): define `PartialUltrafilterChain` structure in UltrafilterChain.lean:
  - Domain: a finite integer interval `[lo, hi]`
  - Chain: `(t : Int) -> lo <= t -> t <= hi -> Ultrafilter LindenbaumAlg`
  - R_G connectivity within domain
  - F-satisfaction: for all `F(phi)` in chain(t) with `lo <= t <= hi`, there exists `t'` with `t <= t' <= hi` and `phi` in chain(t')
  - P-satisfaction: symmetric for backward direction
- [ ] Define the extension partial order: `pc1 <= pc2` iff `pc2.lo <= pc1.lo` and `pc1.hi <= pc2.hi` and chain values agree on the overlap

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- add PartialUltrafilterChain definition and extension order

**Verification:**
- `lake build` succeeds with the new definitions
- F-persistence question answered definitively (proven or counterexample documented)

---

### Phase 2: Zorn Infrastructure -- Directed Union and Chain Boundedness [NOT STARTED]

**Goal:** Prove the two key Zorn prerequisites: (1) the directed union of compatible partial chains is a partial chain, and (2) every totally ordered set of partial chains has an upper bound.

**Tasks:**
- [ ] Prove that the union of a directed family of partial chains inherits R_G connectivity (chain values agree on overlaps, so R_G transfers from any component)
- [ ] Prove that the union inherits F-satisfaction: if F(phi) in chain(t), some component already resolved it at t' >= t, and t' is within the union's domain
- [ ] Prove that the union inherits P-satisfaction (symmetric)
- [ ] Prove the chain condition for Zorn: every totally ordered set of partial chains has an upper bound (the union with domain = union of all domains)
- [ ] Handle the technical subtlety: the union domain must be an interval [lo, hi] (not arbitrary). For a directed family of intervals, the union is `[inf lo_i, sup hi_i]`, which is an interval.

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- directed union construction, Zorn prerequisites

**Verification:**
- All Zorn prerequisite lemmas compile sorry-free
- `lake build` succeeds

---

### Phase 3: Extension Step -- Enlarging a Partial Chain [NOT STARTED]

**Goal:** Prove that any non-total partial chain can be extended by one time step, resolving at least one F/P obligation.

**Tasks:**
- [ ] Prove forward extension: given a partial chain on `[lo, hi]`, extend to `[lo, hi+1]` using `ultrafilter_F_resolution` to pick chain(hi+1) that resolves the highest-priority pending F-obligation (by `Nat.unpair`-based scheduling)
- [ ] Prove backward extension: symmetric, using `ultrafilter_P_resolution` to extend to `[lo-1, hi]`
- [ ] Prove that the extended chain is still a partial chain: R_G connectivity holds for the new edge, and all previously-resolved obligations are still resolved (since the domain only grew)
- [ ] Prove that if a partial chain has an unresolved F-obligation at time t, extension can resolve it in finitely many steps (within hi - t + 1 extensions, the obligation is targeted by fair scheduling)
- [ ] Alternative: if the F-persistence check in Phase 1 succeeds, use fair scheduling directly instead of Zorn, building an omega-chain with `ultrafilter_F_resolution` at each step and proving forward_F from persistence + fair scheduling + surjectivity of `Nat.unpair`

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- extension step lemmas

**Verification:**
- Extension lemmas compile sorry-free
- `lake build` succeeds

---

### Phase 4: Main Theorem -- Temporally Coherent Ultrafilter Chain Exists [NOT STARTED]

**Goal:** Combine Zorn's lemma application with extension steps to produce a total ultrafilter chain with family-level forward_F and backward_P.

**Tasks:**
- [ ] Apply `zorn_preorder` (or appropriate Mathlib Zorn variant) to the partial chain poset, using the chain condition from Phase 2 and non-maximality from Phase 3
- [ ] Extract the maximal partial chain and prove it is total (domain = all of Int): if domain were bounded, Phase 3's extension would contradict maximality
- [ ] Convert maximal partial chain to `UltrafilterChain` structure
- [ ] Prove `forward_F` for the resulting chain: F(phi) in chain(t) implies phi in chain(t') for some t' >= t (inherited from the partial chain's F-satisfaction property)
- [ ] Prove `backward_P` symmetrically
- [ ] Define `TemporalCoherentUltrafilterChain` (UltrafilterChain + forward_F + backward_P) and prove its existence from any starting ultrafilter

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- Zorn application, main existence theorem

**Verification:**
- `TemporalCoherentUltrafilterChain` existence theorem compiles sorry-free
- `lake build` succeeds

---

### Phase 5: Wire to Completeness -- Close the Sorry [NOT STARTED]

**Goal:** Connect the temporally coherent ultrafilter chain to the BFMCS construction and close the sorry at Completeness.lean:237.

**Tasks:**
- [ ] Convert `TemporalCoherentUltrafilterChain` to `TemporalCoherentFamily Int` via `UltrafilterChain_to_FMCS` plus forward_F/backward_P transfer
- [ ] Prove that the resulting `TemporalCoherentFamily` contains the starting MCS at time 0 (via `mem_UltrafilterChain_FMCS_iff` and `mcsToUltrafilter`/`ultrafilter_to_mcs` round-trip)
- [ ] Show that each family in `boxClassFamilies` can be made into a `TemporalCoherentFamily` by applying the construction to each family's base ultrafilter
- [ ] Prove `bfmcs_from_mcs_temporally_coherent` at Completeness.lean:237 using the construction
- [ ] Run `lake build` to verify the entire project compiles with no sorries in the completeness path
- [ ] Run `lean_verify` on `completeness_over_Int` to confirm no axiom violations

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- bridge to TemporalCoherentFamily
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- replace sorry with proof

**Verification:**
- `lake build` succeeds with zero sorries in completeness path
- `lean_verify Bimodal.FrameConditions.Completeness.completeness_over_Int` reports no sorry usage
- `lean_verify Bimodal.FrameConditions.Completeness.bfmcs_from_mcs_temporally_coherent` reports no sorry usage

## Testing & Validation

- [ ] `lake build` succeeds with no new sorries introduced
- [ ] `bfmcs_from_mcs_temporally_coherent` has no sorry (grep for `sorry` in Completeness.lean)
- [ ] `lean_verify` on `completeness_over_Int` confirms no sorry in dependency chain
- [ ] All existing sorry-free theorems remain sorry-free (no regressions)
- [ ] The `UltrafilterChain.lean` file maintains its sorry-free status (the 2 sorries in RestrictedTruthLemma.lean are unrelated and remain untouched)

## Artifacts & Outputs

- `specs/081_fp_witness_representation_theorem/plans/15_implementation-plan.md` (this file)
- `specs/081_fp_witness_representation_theorem/summaries/15_execution-summary.md` (after implementation)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (new constructions)
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean` (sorry removed)

## Rollback/Contingency

- All new code is additive (new definitions and theorems in UltrafilterChain.lean); the only modification to existing code is replacing the sorry in Completeness.lean:237
- If Zorn approach proves infeasible: revert Completeness.lean sorry, keep any sorry-free partial chain infrastructure for future use
- If Phase 1 reveals F-persistence holds: skip Zorn machinery entirely and use the simpler fair-scheduled chain approach (Phases 2-3 collapse into a single fair-scheduling phase)
- Git revert to pre-implementation commit restores all prior state
