# Teammate C Findings (Round 20): Critic Analysis

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-16
**Role**: Teammate C (Critic)
**Focus**: Gap analysis, challenged assumptions, blind spots in the evidence record

---

## Executive Summary

After reading the full failure history (reports 01-19, plans v10-v18, the actual sorry sites in RootScopedChain.lean, and the axiom system), I identify **four significant blind spots** in the accumulated evidence and **one assumption that may be wrong in a way that matters**. The most important finding is that the fold-order trick has been identified twice (reports 18 and 19 synthesis sections) as a potential low-cost fix, but **has never been concretely analyzed to determine whether it actually works or fails**. Every team synthesis document says "this needs investigation" and then no investigation occurs. This is the highest-priority gap.

The secondary finding is that the backward sorry (dd_fmcs_backward_P, line 1333) may have a much simpler proof than the forward case, because BX4' (`φ → H(F(φ))`) provides a direct bridge. This has not been exploited.

---

## Key Findings

### Finding 1: The Fold-Order Trick Has Never Been Tested

Reports 18 and 19 both independently identify "process target LAST in the BX11 fold so Case 3 cannot fire for target" as a low-cost intervention, but **no agent has actually worked through whether this is correct**.

Reading the fold code directly (RootScopedChain.lean lines 257-361), BX11 Case 3 fires when `temp_linearity_mcs` returns the `h_χ_first` branch for the pair `(β, χ)`, putting β under F. The "target" starts as β. If target is processed LAST (i.e., it is the last element added to `others` in the fold), then when the fold arrives at the final step, the current compound already incorporates all previous formulas. The question is whether, at the final BX11 application with the compound on the left and target on the right, Case 3 can fire.

**The case structure is**:
- `temp_linearity_mcs h_mcs β χ h_Fβ h_Fχ` where β is the accumulated compound and χ is target.
- Case 3 gives `F(F(β) ∧ χ) ∈ M`, putting β (the compound) under F, and giving χ (target) as the right conjunct.
- In Case 3, the new direct witness BECOMES χ (line 342: `apply ih ... χ`).

So if target is the last element (χ in the final fold step), Case 3 gives the target as the direct witness. This is exactly what we want: target ∈ M'.

**This is a concrete mathematical observation, not speculation**: When the fold processes target as the FINAL element, Case 3 makes target the direct witness. Cases 1 and 2 also give target directly (Case 1: target ∈ M' via rce_imp; Case 2: target ∈ M' via rce_imp). ALL THREE cases give target ∈ M' when target is last.

**Why this has been missed**: Previous analysis assumed "target is first" (lines 376-381 of the `resolving_enriched_fwd_exists` proof initialize with `target` as the initial β). When target is first, Case 3 can F-wrap it. But the fold argument is parameterized — the CODE puts target first, but it does NOT have to.

**The concrete fix**: In `resolving_enriched_fwd_exists`, change the fold initialization so target is placed LAST in `others`, not FIRST in `tracked`. Specifically: instead of calling `enriched_fwd_fold_with_witness` with β = target and others = sigma_list, call it with the first element of sigma_list as β and target placed at the END of others.

**Why this might fail**: The initial β must have F(β) ∈ M. We need some formula to start the fold. If we pick an arbitrary σ₀ ∈ sigma_list as the starting formula, we need F(σ₀) ∈ M. But `others` is filtered to only formulas with F-obligations, so F(σ₀) ∈ M is guaranteed IF σ₀ is in the filtered list. If the filtered list is empty (no other formula has an F-obligation), then the fold reduces to just target, which is the single-formula case where Case 3 cannot fire.

**Assessment**: This is worth 2-4 hours of concrete investigation. It is genuinely unclear why this specific formulation has not been attempted in Lean. The mathematical argument that "target last guarantees target ∈ M'" is correct as stated. The implementation question is whether the fold infrastructure supports this reorganization without re-proving all downstream lemmas.

### Finding 2: The Backward Sorry (Line 1333) Has an Independent Proof Path

`dd_fmcs_backward_P` (line 1333) requires: P(ψ) ∈ dd_chain(t) → ∃ s < t, ψ ∈ dd_chain(s).

The backward chain `rr_bwd_chain` uses `bwd_pred` at each step. By the symmetry of the construction, `bwd_pred` should give h_content propagation in the backward direction, analogous to g_content propagation in the forward direction.

**Key insight not exploited**: BX4' states `φ → H(F(φ))`. At MCS level: if φ ∈ M, then H(F(φ)) ∈ M. For the backward chain, P(ψ) ∈ chain(t) means at some step in the backward chain. If ψ ∈ chain(s) for s < t (in the backward chain), we are done. If not, we need to find such s.

Actually the more relevant bridge is the SYMMETRIC construction: `rr_bwd_chain` visits formulas in round-robin and resolves P-obligations. The sorry at line 1333 is symmetric to the sorry at line 1275. IF the forward sorry is proved (by whatever mechanism), the backward sorry follows by the same argument applied to `rr_bwd_chain`.

**But here is the potentially independent path**: For the backward sorry in the `t < 0` case of `dd_fmcs_forward_F` (line 1326), the comment says "G(F(ψ)) ∈ dd_chain(t) is not guaranteed." But note BX4': φ ∈ M → H(F(φ)) ∈ M. More relevantly, BX4 states `φ → G(P(φ))`. So if ψ ∈ M_t (backward chain at negative t), then G(P(ψ)) ∈ M_t, hence P(ψ) ∈ M_{t'} for all t' > t. But we want F(ψ) propagation, not P. These axioms do not directly give us what we need.

What DOES matter: the comment at line 1322-1325 is correct that this sorry depends on the forward sorry. Both the `t < 0` case of `dd_fmcs_forward_F` and the full `dd_fmcs_backward_P` are downstream of `rr_fwd_chain_forward_F`. They are not independent sorries.

**Net assessment**: The backward sorries are genuinely downstream. Plan v18 is correct that closing the primary sorry at line 1275 will automatically unlock the others (lines 1306, 1313 directly, and then lines 1366-1376 which require both forward and backward coherence). The 6 sorry sites reduce to 2 independent problems: (A) line 1275 `rr_fwd_chain_forward_F` and (B) line 1366-1376 restricted coherence (tc, buc, fuc), where (B) requires (A).

### Finding 3: The Restricted Coherence Sorries (Lines 1382-1396) May Be Simpler Than Assumed

`dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, and `dd_bfmcs_restricted_fuc` are listed as three separate sorries but treated as equally hard as the forward_F sorry.

Reading line 1382-1396: `restricted_temporally_coherent root` requires that for formulas in `deferralClosure(root)`, the FMCS satisfies temporal coherence. This is a RESTRICTED version — it only needs to hold for formulas reachable from the root formula being disproved.

**Key observation**: `dd_bfmcs_restricted_tc` at line 1382 has a hypothesis: `h_sub : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ sigma_list`. This means sigma_list already CONTAINS all formulas in the deferral closure. The forward_F proof for formulas in deferralClosure(root) is a subcase of the general forward_F proof (with the same sigma_list that contains those formulas).

So `dd_bfmcs_restricted_tc` requires proving forward_F specifically for ψ ∈ deferralClosure(root). Once `rr_fwd_chain_forward_F` is proved (for ALL ψ ∈ sigma_list, hence for ψ ∈ deferralClosure(root) ⊆ sigma_list), restricted_tc follows as a corollary.

**The real question**: Are `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` harder or easier than forward_F? These concern Until/Since coherence (backward Until coherence and forward Until/Since coherence). Prior reports indicate buc is an independent obstacle (Report 17, Lesson 6). Let me look at what these require.

The backward Until coherence (`restricted_backward_until_since_coherent`) needs: if φ U ψ ∈ chain(t), then either ψ ∈ chain(t) or (φ ∈ chain(t) and φ U ψ ∈ chain(t-1)). This is about Until formulas in the chain, NOT about forward_F. It is structurally different.

**Assessment**: Of the three restricted coherence sorries, only buc is likely independent from forward_F. The tc sorry depends on forward_F (and likely backward_P). The fuc sorry depends on forward_F and Until coherence infrastructure. Plan v18's note that buc is "independent" is confirmed.

**The gap**: No agent has written out what `restricted_backward_until_since_coherent` requires in terms of the dd_chain construction. This needs explicit analysis. If the quasimodel infrastructure (2,289 lines, sorry-free) already proves a version of Until coherence, there may be a bridge.

### Finding 4: The BX12 Approach Has Not Been Properly Ruled Out

BX12 states `F(ψ) → (⊤ U ψ)`. Report 18 (Teammate B) mentions Approach 21: use BX12 to reduce forward_F to the proved `bx_until_eventuality_resolution`. The obstacles cited are: (1) produces abstract BXPoints not chain indices, (2) `⊤ U ψ` may not be in deferralClosure(root).

**Challenge to obstacle (2)**: `⊤ U ψ` being in deferralClosure(root) is not required for the proof. The proof structure would be:
1. F(ψ) ∈ chain(n) (hypothesis)
2. By BX12 applied in MCS chain(n): ⊤ U ψ ∈ chain(n)
3. By `bx_until_eventuality_resolution` (proved, sorry-free in Frame.lean): there exists a BXPoint v accessible from chain(n) with ψ ∈ v.
4. This BXPoint v is accessible via the bx_le relation in the canonical frame.
5. Need: v = chain(s) for some s > n.

Step 5 is where it breaks: `bx_until_eventuality_resolution` gives an abstract BXPoint, not an index into the dd_chain. The canonical frame's BXPoints are ALL MCS's, not just those in the chain.

**But**: The canonical frame's FMCS structure uses ALL BXPoints. The temporal accessibility relation bx_le is: N ≤ N' iff g_content(N) ⊆ N'. The BXPoint v given by `bx_until_eventuality_resolution` satisfies: (a) chain(n) ≤_bx v (there exists some accessibility path), and (b) ψ ∈ v.

The question is whether v is representable as some chain step. In general, NO — the BFMCS structure has FAMILIES of shifted chains (each shifted chain corresponds to a modal world), and the temporal witness might be in a DIFFERENT shifted chain than the one containing chain(n).

Actually, wait. The coherence property needed is for a SINGLE fmcs (shifted_dd_fmcs N h_N sigma_list s), not across families. Within a single fmcs, temporal accessibility is indexed by Int: n ≤ m iff n ≤ m (as integers). The BX12 approach would need ψ ∈ chain(s) for some specific integer s, not just some abstract BXPoint.

**Assessment**: Obstacle (1) is real and not easily overcome. BX12 reduces forward_F to the canonical frame's bx_le accessibility, which is indexed by MCS pairs — not by integer chain indices. There is no obvious bridge from "accessible BXPoint v" to "chain(s) for integer s > n." This approach likely fails at step 5 as stated.

However, there is a variant worth considering: what if we directly prove, within the FMCS structure, that the Until eventuality resolution works FOR THE SPECIFIC CHAIN rather than for abstract BXPoints? The chain IS a specific sequence of MCS's. If ⊤ U ψ ∈ chain(n), then by the Until eventuality resolution argument (not using the abstract canonical model, but directly on the chain), ψ must appear at some chain step. But this is exactly forward_F again, applied to ⊤ U ψ instead of F(ψ). BX12 converts the problem but does not simplify it.

---

## Challenged Assumptions

### Challenged Assumption A: "All 6 sorry sites are downstream of one primary blocker"

**The claim**: Plans v16-v18 consistently say line 1275 (`rr_fwd_chain_forward_F`) is "the primary blocker" and all others are downstream.

**The challenge**: This is mostly correct, but `dd_bfmcs_restricted_buc` (line 1391) is genuinely independent. It requires backward Until coherence, which needs:
- The backward chain satisfies the buc property for Since formulas
- This involves `rr_bwd_chain` and h_content propagation, which is symmetric to g_content

If `rr_fwd_chain_forward_F` is proved tomorrow, `dd_bfmcs_restricted_buc` would still be sorry. The evidence (Report 17, Lesson 6) confirms this. However, no agent has estimated HOW HARD the buc sorry is independently. It may be much simpler than forward_F.

**What this means for the plan**: Plan v18 correctly caps buc at 2 hours. But if the forward_F sorry is closed after significant effort (15-20 hours), and buc turns out to be another 5-10 hours, the total effort estimate needs revision.

### Challenged Assumption B: "Strategy C is dead (10-15% confidence)"

**The claim**: Reports 18 and 19 consensus: permanent BX11 displacement is syntactically consistent, so forward_F is unprovable on the current chain. Confidence dropped from 60% to 10-15%.

**The challenge**: This confidence drop is based on a CONCEPTUAL argument, not a fully formalized counterexample. The concrete scenario given in report 18 is:
- sigma_list = [ψ, χ]
- At every visit step for ψ: BX11 Case 3 fires, χ displaces ψ

But this scenario requires that EVERY TIME ψ is the scheduled target, the BX11 application to (ψ, χ) gives Case 3. This means `F(F(ψ) ∧ χ) ∈ M` rather than `F(ψ ∧ χ)` or `F(ψ ∧ F(χ))` — at EVERY visit step.

Is this actually possible? BX11's three cases are determined by the MCS content. The SAME MCS cannot simultaneously support all three cases (they are mutually exclusive for a fixed pair (ψ, χ)). But the MCS CHANGES between visit steps. So at visit step k₁, the chain has MCS M_k1, and Case 3 might fire; at visit step k₂, the chain has MCS M_k2, and Case 3 might fire again.

The question is whether there exists a valid chain where Case 3 fires for ψ at EVERY visit step. The answer is yes IF the invariant "F(F(ψ) ∧ χ) ∈ M" is preserved through all chain steps — but this seems hard because F-obligation constancy gives us F(ψ) ∈ all chain steps, and BX11 applied to (ψ, χ) at each step determines which case fires.

**The subtle point**: The enriched_fwd_step at each step uses the FILTERED others (line 584: `sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))`). If χ is also in sigma_list and F(χ) ∈ M, then χ is in others. The fold then applies BX11 to (ψ, χ). The case that fires depends on the CURRENT MCS.

**The truly uninvestigated question**: Can the chain be constructed so that F(F(ψ) ∧ χ) ∈ M at EVERY visit step for ψ, while maintaining all other chain properties? If the construction of chi's visit steps forces M into states where F(ψ ∧ χ) or F(ψ ∧ F(χ)) must hold, then Case 3 cannot fire every time.

**Assessment**: The consensus confidence of 10-15% for Strategy C is plausible but not rigorously established. The scenario requires Case 3 to fire at every ψ-visit step, which would require the chain to avoid a BX11 structure that guarantees ψ comes before or simultaneously with χ. Whether this is achievable within the MCS axiom system — specifically whether the chi-resolution steps can always create MCS states where Case 3 fires for ψ — has not been fully analyzed.

### Challenged Assumption C: "The fold-order trick was investigated and found to fail"

**The claim**: Report 19 synthesis (line 95 of plan v18) says "Strategy C fold-order variant (task 93, report 18 synthesis): Processing target last in the BX11 fold. Investigated but fold outcome depends on MCS content which is itself determined by .choose."

**The challenge**: This characterization of the fold-order variant as "investigated" is inaccurate. Reports 18 and 19 both list it as a GAP REQUIRING INVESTIGATION. No report contains an actual analysis of whether processing target last prevents Case 3. The plan v18's road map entry for dead end #21 is wrong — it claims it was "investigated" based on the synthesis recommendation to investigate it, not on actual investigation.

**The mathematical point as I analyzed above** (Finding 1): When target is the LAST element in the BX11 fold, ALL THREE cases of BX11 give target ∈ M' (not just as direct witness, but guaranteed). This is because in the final fold step, the compound β is the accumulated fold of all previous formulas, and χ is target. Case 1: F(β ∧ target) ∈ M → target ∈ M' (rce_imp). Case 2: F(β ∧ F(target)) ∈ M → target ∈ M' (rce_imp gives F(target) ∈ M' then... wait, F(target) ∈ M' not target ∈ M'). Case 3: F(F(β) ∧ target) ∈ M → target ∈ M' (rce_imp).

Actually let me reconsider Case 2 more carefully: if target is the LAST element (χ = target), and Case 2 fires, we get `F(β ∧ F(target)) ∈ M`. Then target (as χ) gets tracked as `F(target) ∈ M'` via rce_imp — NOT target ∈ M' directly. So Case 2 does NOT guarantee target ∈ M' when target is last!

**Revised mathematical conclusion**: Cases 1 and 3 guarantee target ∈ M' when target is last. Case 2 only guarantees F(target) ∈ M', not target ∈ M'. So the fold-order trick is NOT a complete fix — it still fails when BX11 Case 2 fires for the pair (compound_β, target).

However, Case 2 gives `F(target) ∈ M'`, which by the F-obligation constancy means the next round-robin cycle will again have F(target) ∈ M. The question becomes: can Case 2 fire EVERY time target is the last element? For Case 2 to fire: `F(β ∧ F(target)) ∈ M` — the compound comes before target. This is consistent but requires β's witnesses to all precede target's witnesses. Whether this creates a contradiction via the schedule cycling is unclear.

**Bottom line**: The fold-order trick eliminates Case 3 displacement but does not eliminate Case 2 deferral. Case 2 puts target under F (as F(target) ∈ M') rather than under identity. This is still a form of "target not resolved at this step." The trick might reduce the problem but not eliminate it.

---

## Recommended Approach

Based on the above analysis:

### Immediate Priority: Concrete Investigation of Fold-Order Trick (2-4 hours)

Despite the revised analysis showing Case 2 still defers target, the fold-order trick creates a SIMPLER structure: instead of the full 3-case displacement, only Case 2 can prevent target from being directly resolved. Case 2 has a specific structure: `F(β ∧ F(target)) ∈ M`. This means ALL the other formulas come BEFORE target in the temporal ordering.

If ALL formulas in sigma_list come before target (Case 2 fires every time), then eventually the accumulation of "all others first" creates a contradiction: if target is always last, but F(target) ∈ M, and all others resolve in finite time (by F-obligation constancy and the round-robin), then after all others are resolved, target must be next. This is a FINITENESS argument: the set of formulas that can displace target (via Case 2) is sigma_list \ {target}, which is finite. Each formula in sigma_list \ {target} resolves within |sigma_list| steps. After enough steps, no formula can displace target.

This argument needs formalization but the key claim is: if target is always the LAST in the fold, then the number of formulas with F-obligation that come BEFORE target (per BX11 ordering) decreases over the chain, leading to a well-founded induction. This is exactly the "never-resolved count" idea but applied to the SET OF FORMULAS ORDERING BEFORE TARGET rather than the set of all F-defects.

**Concrete proof attempt**: Define `before_target(n) = |{χ ∈ sigma_list | F(χ) ∈ chain(n) ∧ bx11_earlier chain(n) χ target}|`. Show this is non-increasing and, when Case 2 fires for target, at least one formula from this set gets resolved (directly, not via F-wrap). The finite decrease gives well-founded induction.

The key obstacle: does χ being resolved (χ ∈ chain(m)) guarantee it leaves `before_target`? If χ is resolved, F(χ) ∈ chain(m) (by phi_in_mcs_imp_F_phi). So χ might remain in `before_target`. But if χ is no longer F(χ) ∈ chain(m+1)... wait, F-obligation constancy says F(χ) ∈ chain(n) → F(χ) ∈ chain(m) for all m ≥ n. So χ NEVER leaves before_target once it's in. This is the same non-monotonicity problem as the defect count.

**Revised bottom line on fold-order trick**: It reduces Case 3 to Case 2, making the structure simpler, but does not obviously give a well-founded measure. The original defect-count failure reappears in a new form.

### Primary Recommendation: Proceed with Plan v18, but with Two Pre-Attempts

1. **Fold-order (2 hours)**: Implement the variant where target is processed last. Verify whether Cases 1+3 alone guarantee target ∈ M' (ignoring Case 2), and check what happens when Case 2 fires. This will either (a) yield a simplified proof if Case 2 fires vanishingly rarely, or (b) confirm the approach fails and clarify exactly where the measure breaks down. The result will inform the never-resolved-count approach.

2. **Restricted buc analysis (2 hours)**: Write out what `restricted_backward_until_since_coherent` requires for the dd_chain concretely. If the quasimodel infrastructure has proved this for quasimodels, a bridge theorem may exist. Determine whether buc is actually independent or whether closing forward_F automatically closes it.

3. **Plan v18 primary (20 hours)**: Ordered-discharge chain replacement with never-resolved count.

### Secondary Recommendation: Separate Task for restricted_buc

If analysis in step 2 shows that buc is genuinely independent and hard (estimated > 5 hours after forward_F is closed), spawn a separate task for it. Report 17 Lesson 6 and plan v18 already flag this as potentially needing its own task. Making this explicit now prevents the situation where forward_F is closed but the 5/6 sorries claim turns out to be 5/7 because buc takes longer than expected.

---

## Evidence

### Evidence for Finding 1 (Fold-Order Never Tested)

Plan v18 Section "Implementation Phases" lists dead end #21 as "Strategy C fold-order variant... Investigated but fold outcome depends on MCS content." Cross-referencing with reports 18 and 19: BOTH reports recommend investigating this as a gap, and neither contains actual investigation results. The plan v18 dead-end entry was written BEFORE implementation, mischaracterizing a recommendation-to-investigate as a completed investigation.

Report 19 synthesis, line: "No teammate analyzed whether `enriched_fwd_step`'s BX11 fold could be MODIFIED to guarantee target resolution." Report 18 synthesis, line: "Fold-order trick (2h): Modify `enriched_fwd_fold_with_witness` so target is processed LAST."

Both identify this as TODO. Neither reports a result.

### Evidence for Finding 2 (Backward Sorry Independence)

Lines 1318-1326 of RootScopedChain.lean explicitly document the t < 0 case sorry: "This sorry depends on rr_fwd_chain_forward_F being proved first." Line 1333 (dd_fmcs_backward_P) is identified as symmetric in report 17 but no agent has checked whether the symmetric backward chain (`rr_bwd_chain` using `bwd_pred`) has the same structure.

### Evidence for Challenged Assumption C

Reading plan v18's dead end list entry #21: "Strategy C fold-order variant (task 93, report 18 synthesis): Processing target last in the BX11 fold. Investigated but fold outcome depends on MCS content which is itself determined by .choose."

This entry is in the ROAD_MAP dead ends section of plan v18 Phase 1. But Phase 1 is the "ROAD_MAP update" phase that was completed before any implementation. The entry was written based on the reports-18/19 RECOMMENDATION to investigate, not on investigation results.

### Evidence for Challenged Assumption A (6 sorries reduce to 2 independent)

- Lines 1306-1326: `dd_fmcs_forward_F` (t < 0 case) explicitly depends on `rr_fwd_chain_forward_F`.
- Lines 1328-1333: `dd_fmcs_backward_P` is symmetric, depends on backward chain property.
- Lines 1382-1396: restricted_tc, buc, fuc depend on forward_F (and backward_P for buc).

Report 17, Lesson 6: "Backward Until coherence (sorry #5) is independent." This sorry (#5 in the v17 ordering) corresponds to `dd_bfmcs_restricted_buc` (line 1391 in current code).

---

## Confidence Levels

| Claim | Confidence |
|-------|-----------|
| Fold-order trick has never been tested | High (90%) |
| Fold-order trick eliminates Case 3 when target is last | High (95%) — this is mechanical |
| Fold-order trick eliminates Case 2 when target is last | Low (10%) — Case 2 still fires |
| Fold-order trick + finiteness argument works | Low (25%) — would need before_target measure |
| dd_bfmcs_restricted_buc is independent of forward_F | High (85%) |
| dd_fmcs_backward_P is downstream of forward_F | High (90%) |
| BX12 approach (F(ψ) → ⊤ U ψ) can be made to work | Very low (10%) |
| Plan v18 (never-resolved count) can succeed | Medium (55-65%) — consistent with prior estimates |

---

## Sunk Cost Analysis

The question of true cost of alternative architectures has been asked but not answered precisely. Here is my estimate:

**Reusable under Plan v18 (ordered-discharge chain replacement)**:
- All of Frame.lean (673 lines, sorry-free): FULLY REUSABLE — uses MCS, not chain-specific.
- All of TruthLemma.lean (320 lines, sorry-free): FULLY REUSABLE.
- All of CanonicalModel.lean (~dead code but sorry-free): FULLY REUSABLE.
- Quasimodel infrastructure (2,289 lines, sorry-free): FULLY REUSABLE.
- OrderedSeedConsistency.lean (enriched_resolving_seed_consistent, temp_linearity_mcs, two_defect_consistent_seed, discharge_single_step, discharge_two_step, bx11_earlier_resolving_seed_strong): FULLY REUSABLE.
- RootScopedChain.lean lines 1-449 (FF_imp_F, F-monotonicity, enriched_fwd_fold, resolving_enriched_fwd_exists): PROBABLY REUSABLE.
- RootScopedChain.lean lines 449-684 (rr_fwd_chain, rr_bwd_chain, dd_chain, g_content/h_content propagation, box_stable): PARTIALLY REUSABLE (chain definition changes, but most lemmas have analogues).
- Lines 684-1200 (shifted_dd_fmcs, ordered discharge infrastructure, F-obligation constancy, rr_fwd_chain_F_propagate): PARTIALLY REUSABLE.

**Needs rewriting under Plan v18**: Approximately 30-40 theorems in lines 557-684 that depend on the specific behavior of `enriched_fwd_step`. These are the "~30 theorem re-proofs" cited in plans. Most are mechanical (change the step definition, re-prove the spec lemma, downstream lemmas follow).

**True cost**: 6,400+ sorry-free lines have ~6,000 lines reusable. The ~400 lines of chain-specific lemmas need updating. At ~10-15 lines/hour for Lean proof repair, this is 25-40 hours of mechanical work, plus the core 5-10 hours of proving the new step properties. Total: 30-50 hours (Plan v18's 24-hour estimate seems optimistic).

---

## Summary of Actionable Gaps

1. **Test the fold-order trick concretely** (2-4 hours): Even if it does not completely solve forward_F, understanding EXACTLY how it fails will clarify the structure of the fix needed.

2. **Analyze dd_bfmcs_restricted_buc independently** (1-2 hours): Write out what it needs, check if quasimodel infrastructure bridges, estimate effort separately from forward_F.

3. **Do not add fold-order trick to the "dead ends" list prematurely**: Plan v18's phase 1 ROAD_MAP update incorrectly lists it as dead. Correct this before committing.

4. **Revise the effort estimate for Plan v18**: 24 hours may be optimistic. The mechanical re-proof of ~30-40 downstream theorems is closer to 30-40 hours total. Plan for this contingency.
