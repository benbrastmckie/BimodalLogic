# Research Report: Round-Robin Chain History and Lessons Learned

**Task**: 93 - Complete BXCanonical embedding
**Started**: 2026-04-14T22:00:00Z
**Completed**: 2026-04-14T22:30:00Z
**Effort**: 1 hour
**Dependencies**: None
**Sources/Inputs**:
- Reports 03-16 (task 93)
- Summaries 13, 14 (task 93)
- Handoffs 01-02, 08, 10-11, 01_phase1-partial, 02_forward-F-analysis (task 93)
- Plans 10, 13, 14, 15, 16 (task 93)
- Codebase: RootScopedChain.lean, OrderedSeedConsistency.lean
**Artifacts**: specs/093_complete_bxcanonical_embedding/reports/17_round-robin-chain-history.md
**Standards**: report-format.md, status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

- The round-robin chain concept was introduced in Report 04 (Teammate B) as a finite scheduling approach over `deferralClosure(root)` to ensure every F-obligation is visited periodically.
- The chain was implemented in RootScopedChain.lean (lines 449-652) with `rr_fwd_chain`, `rr_bwd_chain`, and `dd_chain` (all proved, sorry-free). The infrastructure works correctly for g_content/h_content propagation.
- The fundamental problem: `enriched_fwd_step` gives only a DISJUNCTION (`psi in M' OR F(psi) in M'`) at each step. BX11 Case 3 can "hijack" the scheduled target's direct witness slot, preventing guaranteed resolution. This was established definitively in Summary 13 (session sess_1776180711_c675a9).
- Six successive attempts to fix the round-robin chain's forward_F gap have all failed: (1) f_carry seed enrichment (inconsistent seeds), (2) defect counting (non-monotonic), (3) finding BX11-minimum (3-cycles), (4) G(neg psi) impossibility (no backward propagation), (5) dovetailing (same disjunction problem), (6) defects-only fold (Lindenbaum creates new defects).
- Plan v16's Strategy C (direct witness contradiction on existing chain) is the most promising remaining approach but has never been implemented. It avoids the 3-cycle problem by arguing on the existing chain rather than replacing it.

## Context & Scope

This report traces the complete history of the round-robin chain approach across task 93's research rounds (03-16) and implementation attempts. The goal is to identify what has been tried, what failed, and what lessons apply to the current strategy in Plan v16.

The round-robin chain is the forward component of the `dd_chain` (defect-discharge chain) that forms the Int-indexed BFMCS needed for the completeness proof. Closing the 6 sorry sites in RootScopedChain.lean depends entirely on proving `rr_fwd_chain_forward_F`: that `F(psi) in chain(n)` implies `psi in chain(s)` for some `s > n`.

## Findings

### 1. Origin of the Round-Robin Chain (Reports 03-04, Plan 10)

The round-robin concept first appeared in Report 04 (Teammate B), proposed as a root-parameterized chain with a finite schedule cycling through `deferralClosure(root)`:

> "Instead of resolving one formula per step, use a ROUND-ROBIN schedule over Phi at each time step, building the seed as: seed_t = g_content(chain(t)) union {psi | F(psi) in chain(t) and psi in Phi and priority(psi) = round(t)}"

Plan 10 adopted this as "Fallback B" (line 277): "Switch to root-parameterized chain... finite round-robin schedule over deferralClosure(root), ensuring all formulas in the restricted set are resolved."

The key idea was that finiteness of `deferralClosure(root)` would guarantee every formula is visited within `|sigma_list|` steps, making F-obligation resolution inevitable.

### 2. Implementation Phase (Summary 13, Plan 13)

The round-robin chain was successfully implemented and proved sorry-free:

- `rr_fwd_chain` (forward chain with round-robin schedule)
- `rr_bwd_chain` (backward chain)
- `dd_chain` (Int assembly combining forward and backward)
- g_content/h_content propagation for both Nat and Int versions
- `box_stable_dd_chain`
- `dd_fmcs`, `shifted_dd_fmcs`, `dd_bfmcs` structure definitions

This infrastructure (lines 449-684 of RootScopedChain.lean) remains proved and sorry-free. The implementation is correct -- the problem is exclusively in proving the forward_F property.

### 3. The BX11 Case 3 Hijacking Problem (Summary 13, Report 15)

The definitive analysis of why the round-robin chain cannot prove forward_F was established in session sess_1776180711_c675a9 (Summary 13, Section "Critical Analysis"). The argument has four parts:

**Part 1: F-obligation set S(n) is constant.** S(n) = {phi in sigma_list | F(phi) in chain(n)} neither grows (by `no_new_f_defects`) nor shrinks (because chi in M implies F(chi) in M via BX8+BX10). So the set of formulas needing resolution never changes.

**Part 2: BX11 fold may perpetually F-wrap the target.** The `enriched_fwd_fold` processes formulas using BX11's three-way case split:
- Case 1: F(beta and chi) -- target stays direct, chi stays direct
- Case 2: F(beta and F(chi)) -- target stays direct, chi F-wrapped
- Case 3: F(F(beta) and chi) -- target F-wrapped, chi becomes direct

Case 3 fires when chi's BX11 witness comes before beta's. Once the target is F-wrapped, it stays wrapped through subsequent fold steps. If another formula chi always has an earlier witness than psi, then psi is permanently displaced at every scheduling visit.

**Part 3: No syntactic contradiction from persistent F(psi) without psi.** F(psi) and neg(psi) can coexist in an MCS: F(psi) = neg(G(neg(psi))) means "not always neg(psi) in the future," while neg(psi) means "psi false now." Both are satisfiable simultaneously. Deriving G(neg(psi)) from chain membership would require backward G-propagation, which requires forward_F -- creating circularity.

**Part 4: Seed enrichment with f_carry is inconsistent.** The natural fix of adding f_carry(M) to the resolving seed fails with a concrete counterexample: if G(F(alpha) -> neg(psi)) in M, F(alpha) in M, F(psi) in M, then the seed {psi} union g_content(M) union f_carry(M) is inconsistent.

### 4. The Ordered Defect-Discharge Attempt (Reports 14-15, Plan 14-15)

After the round-robin chain was shown unable to prove forward_F, the strategy shifted to replacing `enriched_fwd_step` with `ordered_discharge_step` that uses the BX11-earliest F-defect as the fold target.

**The key theorem `target_stays_direct_in_fold`** (proved, sorry-free at line ~1009): When the target is `bx11_earlier` than every formula in `others`, the fold guarantees target in M' (deterministic, not disjunctive). This was proved in session sess_1776201199_67640c (Handoff 01_phase1-partial).

**The 3-cycle discovery** (Report 16, Teammate A): A concrete semantic counterexample showed `bx11_earlier` is non-transitive and admits 3-cycles. With formulas a, b, c where a holds at times {1,4}, b at {2}, c at {3}, the strict BX11 ordering forms a cycle: a > b > c > a. This means `target_stays_direct_in_fold`'s precondition (`h_earliest` for ALL others) may be unsatisfiable -- there may be no global BX11-minimum among 3+ defects.

**Impact**: Plan v15's Phase 2 was invalidated. The defect-counting argument also fails because defect count is non-monotonic (Lindenbaum can create new defects from former non-defects).

### 5. Complete Catalog of Failed Approaches

| # | Approach | Report/Handoff | Failure Reason |
|---|----------|---------------|----------------|
| 1 | Simple round-robin scheduling | Reports 03-04, Summary 13 | BX11 Case 3 hijacking; disjunctive resolution |
| 2 | f_carry seed enrichment | Reports 07, 10, Handoff 10 | Seed provably inconsistent (G(F(alpha)->neg(psi)) counterexample) |
| 3 | until_neg_carry in seed | Handoff 02 | Forward stability semantically invalid; seed inconsistent via BX8 contrapositive |
| 4 | Deferral disjunctions in seed | Handoff 01_deferral-chain | Consistency proof non-trivial; not completed |
| 5 | BX12 reduction F(phi)->top U phi | Reports 10, Handoff 08 | (top U phi) not in deferralClosure(root) |
| 6 | Quasimodel-to-Int bridge | Reports 10, 14, 15 | sigma_le incompatible with g_content; finite chains can't form global FMCS |
| 7 | Deterministic successor | Handoff 10 | Would require 20+ hours major restructuring |
| 8 | Dovetailing (Goldblatt omega^2) | Report 15 | Same F-preservation problem; omega^2 adds complexity without solving it |
| 9 | Zorn/Compactness | Report 15 | forward_F is Sigma_1 (existential); not preserved by directed limits |
| 10 | Identity tail for F | Report 14 | F is strict future (s > t); identity tail cannot witness |
| 11 | Defect counting / scheduling induction | Reports 14-16 | Defect count non-monotonic; resolved formulas can be lost at subsequent steps |
| 12 | Finding BX11-minimum | Reports 15-16, Handoff 02 | bx11_earlier non-transitive; 3-cycles possible; no global minimum |
| 13 | G(neg psi) impossibility | Reports 15-16 | No backward G-propagation in forward chain; Lindenbaum freely adds G(neg psi) |
| 14 | Per-formula chain | Report 16 | Can't merge into single Int-indexed chain |
| 15 | FMP bridge | Report 14 | FMP proves decidability, not completeness; same construction needed |
| 16 | G(F(psi)) axiom | Report 16 | F(psi) -> G(F(psi)) false in linear frames |
| 17 | Two-phase chain | Report 14 | Reduces to same core problem |
| 18 | Defects-only fold | Report 16 | Lindenbaum can create new defects from non-defect F-obligations |
| 19 | Partial domination | Report 16 | "Bad" formulas' F-obligations not preserved; circles back to ordering problem |

### 6. What Remains Viable: Strategy C (Direct Witness Contradiction)

Plan v16 identifies Strategy C (Report 16, Part 6.3) as the most promising remaining approach (60% confidence). The key insight:

1. `rr_fwd_chain_F_propagate` (proved, line 1071/1124): Reduces forward_F to "F(psi) cannot persist forever without psi ever appearing."
2. Assume psi is NEVER resolved (for all s > n, psi not in chain(s)). Then F(psi) in chain(m) for ALL m >= n.
3. At each step, `enriched_fwd_step_resolves_one` guarantees SOME formula is directly resolved. If psi is never that formula, then at every visit step some chi displaces psi via BX11 Case 3.
4. The open question: Does permanent displacement lead to a structural contradiction? For example, does the set of displacing formulas exhaust sigma_list in a way that is inconsistent?

**Why Strategy C is better than previous approaches**:
- Works with the EXISTING round-robin chain (no replacement needed, no ~30 downstream theorems to re-prove)
- Avoids the 3-cycle problem entirely (doesn't require finding a BX11-minimum)
- Leverages the proved `rr_fwd_chain_F_propagate` to reduce the problem to a contradiction argument

**Why Strategy C is risky (40% failure probability)**:
- The argument that "permanent displacement leads to contradiction" is novel and unproven
- No prior formalization or paper proof addresses this specific gap
- The BX11 fold structure may genuinely allow permanent displacement without contradiction
- The literature handles this implicitly via semantic arguments on integer models, not syntactically

### 7. Lessons for Plan v16 Implementation

**Lesson 1: The proved infrastructure is solid.** 16 sorry-free lemmas from v14 Phase 1 remain valid: `target_stays_direct_in_fold`, `bx11_earlier_total`, `enriched_fwd_step_preserves`, `enriched_fwd_step_resolves_one`, `rr_fwd_chain_F_propagate`, `discharge_single_step`, `no_new_f_defects`, etc. Any approach must build on these, not around them.

**Lesson 2: Avoid replacing the chain.** Every attempt to replace `rr_fwd_chain` with a new chain (ordered_fwd_chain, discharge_chain, deterministic chain) was estimated at 200-500 LOC plus ~30 downstream theorem re-proofs. Strategy C's advantage is working with the existing chain.

**Lesson 3: The gap between semantics and syntax is real.** The literature proofs work because they argue semantically (in integer models, F-witnesses have well-ordered temporal structure). BX11 is a syntactic approximation that is weaker than the semantic reality (non-transitive, admits 3-cycles). Any successful approach must either bridge this gap or find a purely syntactic argument.

**Lesson 4: Time-cap investigation phases.** The 3-hour cap on Strategy A (Phase 1) in Plan v16 reflects the lesson from Plan v15 where unbounded investigation of BX11 acyclicity consumed time without definitive resolution. Early detection of dead ends is critical.

**Lesson 5: The F-obligation constancy is a key structural fact.** The set {chi | F(chi) in chain(n)} is exactly constant across steps (BX8+BX10 for non-shrinking, no_new_f_defects for non-growing). Any successful argument must use this constancy. The corrected derivation (BX8+BX10, not temp_t contrapositive) was established in Report 16.

**Lesson 6: Backward Until coherence (sorry #5) is independent.** All analysis confirms `dd_bfmcs_restricted_buc` is an independent obstacle from forward_F. Plan v16 correctly caps it at 2 hours with a fallback of closing 5/6 sorries. This matches the consensus from Reports 15-16.

## Decisions

- Strategy C (direct witness contradiction argument on existing chain) is the correct next investigation, as it avoids both the 3-cycle problem and the chain replacement overhead.
- Strategy A (BX11 acyclicity) should be attempted as a fast gate check (3-hour cap) but is expected to fail given the semantic counterexample.
- The 19 failed approaches documented above should be treated as definitively closed. No further investigation of these paths is warranted.

## Recommendations

1. **Implement Plan v16 Phase 0 first** (ROAD_MAP.md update) to capture all dead ends permanently before any further implementation.
2. **Execute Strategy A gate check** with strict 3-hour time cap. Expected outcome: failure (confirming 3-cycles in MCS).
3. **Focus implementation effort on Strategy C** (direct witness contradiction). The key unexplored mathematical question is whether permanent BX11 Case 3 displacement of a specific formula psi leads to a contradiction detectable within the MCS axiom system.
4. **If Strategy C fails**: Document the precise gap as a genuine open problem in temporal logic formalization. The literature is silent on this specific syntactic obstruction. Consider publishing the partial result (16 sorry-free lemmas, complete infrastructure, 5/6 sorries closeable).
5. **Do not attempt chain replacement** unless Strategy C is definitively shown to fail. The downstream re-proof cost (~30 theorems, 200+ LOC) makes this a last resort.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Strategy C argument has unfillable mathematical gap | Cap at 4 hours per Plan v16. Document precise gap for future research. |
| Strategy A wastes time on known-dead approach | 3-hour hard cap. Expected to fail; serves as definitive closure. |
| Backward Until coherence remains unsolved even if forward_F closes | Independent sorry; closing 5/6 is publishable. Spawn dedicated task. |
| All strategies fail | The proved infrastructure (16 lemmas) has permanent value. The gap would be a genuine contribution to the literature (identifying a syntactic obstruction that paper proofs gloss over). |

## Appendix

### Search Queries Used
- `round.?robin` across all task 93 artifacts (reports, summaries, handoffs, plans)
- `rr_fwd_chain` across all task 93 artifacts
- `chain` in handoffs and summaries

### Chronological Timeline of Round-Robin Chain Investigations

| Date | Session | Event |
|------|---------|-------|
| 2026-04-13 | Report 03 | First mention: biased Lindenbaum not viable; round-robin suggested |
| 2026-04-13 | Report 04 | Teammate B proposes finite round-robin schedule over deferralClosure |
| 2026-04-13 | Plan 10 | Round-robin adopted as Fallback B for F-formula preservation |
| 2026-04-13 | Report 10 | Root-parameterized chain with round-robin confirmed as viable architecture |
| 2026-04-13 | Handoff 08 | Analysis of 3 restricted coherence sorries; forward_F identified as root blocker |
| 2026-04-13 | Handoff 10 | F-carry inconsistency established; 3 fundamental obstacles identified |
| 2026-04-13 | Handoff 11 | Forward_F unprovable for current scheduling chain; quasimodel recommended |
| 2026-04-14 | Plan 13 | Round-robin chain implemented and proved sorry-free (lines 449-684) |
| 2026-04-14 | Summary 13 | **Definitive**: Round-robin cannot prove forward_F (4-part argument) |
| 2026-04-14 | Plan 14 | Ordered defect-discharge chain proposed as replacement |
| 2026-04-14 | Report 14 | 6 alternatives rejected; ordered discharge confirmed as only viable path |
| 2026-04-14 | Summary 14 | Implementation partial; forward_F remains sole blocker |
| 2026-04-14 | Handoff 01_phase1 | target_stays_direct_in_fold proved; 4 approaches proposed |
| 2026-04-14 | Handoff 02_forward-F | BX11 non-transitivity discovered; counting argument fails |
| 2026-04-14 | Report 15 | G(neg psi) impossibility killed; ordered discharge with target_stays_direct_in_fold confirmed |
| 2026-04-14 | Report 16 | **3-cycle counterexample**; Plan v15 invalidated; Strategy C proposed |
| 2026-04-14 | Plan 16 | Strategy A gate check + Strategy C primary; 20-hour estimate |

### Key File References

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Main file with all sorry sites
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- Sorry-free seed consistency proofs
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- forward_temporal_witness_seed_consistent
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Dead code with original 8 sorry sites
