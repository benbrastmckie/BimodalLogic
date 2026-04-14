# Research Report: Task #93 — Close BXCanonical Embedding (Round 12)

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates)
**Session**: sess_1776124230_b9ee33

## Summary

Round 12 team research with focused validation of Plan v11 (quasimodel BFMCS via defect-discharge). All four teammates completed. The Critic (Teammate C) identified a **FATAL FLAW in the identity tail construction**: F(psi) in M_last does NOT imply psi in M_last, so the constant-value tail cannot witness F-eventualities. This invalidates Plan v11's core architecture. Teammate A confirmed the quasimodel infrastructure is complete but disconnected from `int_chain` — the BXPoint-to-integer-position bridge is missing. Teammate B found that `restricted_buc` (line 649) may be independently addressable via Until-carry seed enrichment, without requiring forward_F. Teammate D's literature survey reveals a **critical distinction missed in prior rounds**: standard approaches (Goldblatt 1992, Verbrugge/de Jongh/Veltman 2004) build each canonical world as an ENRICHED MCS that already contains all F-witnesses, rather than trying to carry F-formulas through chain steps. This "enrichment-first" approach avoids the F-loss problem entirely. D also identifies task 82 (FMP) as an immediate 1-2 hour quick win for weak completeness.

## Key Findings

### Finding 1: FATAL — Identity Tail Cannot Witness F-Eventualities (Teammate C)

Plan v11 claims the identity tail (constant chain beyond quasimodel segment) trivially satisfies all FMCS properties. This is **FALSE for forward_F**.

- Forward_G works: G(phi) in M_last → phi in M_last by BX T-axiom `G(phi) → phi` ✓
- Forward_F FAILS: F(psi) in M_last does NOT imply psi in M_last. F(psi) means psi holds at some STRICTLY LATER time. The constant tail chain(s) = M_last for all s > k provides no strictly later position where psi could hold unless psi is already in M_last. But F(psi) → psi does not hold in BX (it would make F reflexive, contradicting strict future semantics).

**Impact**: The quasimodel chain + identity tail architecture cannot close forward_F unless the chain endpoint provably has ALL F-obligations discharged (psi in the last point for every F(psi) in deferralClosure). This is a much stronger requirement than Plan v11 assumes — it means the quasimodel chain must resolve ALL defects before the identity tail begins.

**Resolution path**: The quasimodel chain must be extended until ALL defects in deferralClosure(root) are discharged. Since the defect count strictly decreases at each step (via `hintikka_step_target_decrease`), this terminates in at most |deferralClosure(root)| steps. The identity tail then starts from a defect-free point where every F(psi) has psi already present. But this requires proving: (a) the chain can discharge ALL Until defects, not just one; (b) the final point has no remaining F-defects; (c) the final point is "temporally saturated" — F(psi) in it implies psi in it.

### Finding 2: hintikka_step_g_prop Covers Sigma-Bounded Formulas Only (Teammates A, C)

`hintikka_step_g_prop` (Realization.lean:419-424):
```lean
theorem hintikka_step_g_prop
    {Sigma : Finset Formula} {h1 h2 : HintikkaPoint Sigma}
    (h_step : hintikka_step h1 h2) {chi : Formula}
    (h_Gchi : Formula.all_future chi ∈ h1.formulas) :
    chi ∈ h2.formulas
```

It provides G(chi) in h1 → chi in h2 for any chi, BUT h1.formulas ⊆ Sigma. So G(chi) must be in Sigma.

**Scope issue**: deferralClosure(root) contains seriality formulas (F_top, P_top, G_neg_neg_bot, etc.) that are NOT in SubformulaClosure(root) for arbitrary root. If Sigma = SubformulaClosure(root) (the quasimodel Sigma), then deferralClosure(root) ⊄ Sigma in general.

**Resolution**: Choose Sigma = deferralClosure(root) (or a larger set containing it) instead of SubformulaClosure(root) for the quasimodel construction. This requires verifying the quasimodel machinery works with this larger Sigma.

### Finding 3: restricted_buc May Be Independently Closable (Teammate B)

Teammate B identified that `restricted_buc` (line 649) reduces to a step transfer property via `backward_until_from_step` (UntilSinceCoherence.lean:111):

> Given (φ U ψ) ∈ fam.mcs(r+1), φ ∈ fam.mcs(r) → (φ U ψ) ∈ fam.mcs(r)

This does NOT require forward_F. It requires Until-formula propagation through chain steps. Currently, neither f_carry (only F-formulas) nor g_content (only G-formulas) carry Until formulas. A new "u_carry" mechanism could address this:

- Define `u_carry(M) = {φ U ψ ∈ M | ψ ∉ M}` (defective Until formulas)
- Enrich non-resolving seed: `g_content(M) ∪ f_carry(M) ∪ u_carry(M)`
- Consistency: u_carry(M) ⊆ M (since these are formulas IN M), and the enriched seed is a subset of M, so it is consistent by M's consistency

However, Teammate B notes that at resolving steps, the seed `{chi} ∪ g_content(M)` still drops Until formulas. So step transfer fails at resolving steps unless the resolving seed is also enriched.

**Verdict**: Promising but requires enriching BOTH resolving and non-resolving seeds with u_carry. The consistency of `{chi} ∪ g_content(M) ∪ u_carry(M)` needs verification — unlike f_carry enrichment, u_carry ⊆ M, so `{chi} ∪ g_content(M) ∪ u_carry(M)` is consistent if `{chi} ∪ g_content(M) ∪ (M ∩ {defective Until formulas})` is consistent, which follows from `{chi} ∪ g_content(M)` being consistent (proved) plus u_carry ⊆ M.

### Finding 4: BXPoint-to-Integer Bridge Is the Core Obstacle (Teammate A)

The quasimodel produces `v : BXPoint` with `bx_le w v` and `ψ ∈ v.formulas`. But `bx_fmcs_forward_F` needs `∃ s : Int, t < s ∧ ψ ∈ (bx_fmcs M₀ h₀).mcs s`. Converting `bx_le w v` to an integer `s > t` requires showing `v` appears as a chain member — which is false for the current scheduling chain (v is an arbitrary BXPoint, not necessarily a chain member).

**This confirms**: No overlay approach (using quasimodel results on top of the existing scheduling chain) can work. The chain itself must be rebuilt or the sorry must be rewritten to use a different FMCS construction.

### Finding 5: Both Until and Since Defect Infrastructure Exist (Teammates A, C)

- `sinceDefectSet`, `since_defect_count`, `HintikkaStepOracleSince` — all defined
- `hintikka_chain_exists_since` (Construction.lean:769-824) — proved (backward chain)
- But `hintikka_step` itself has NO Since-defect propagation clause (only Until)
- The backward chain uses a reversed oracle that produces predecessors

The backward direction is architecturally different: it extends LEFT (snoc construction) while the forward extends RIGHT. Mapping both to Int-indexed MCS requires two separate adapter paths.

### Finding 6: Strict vs Non-Strict Gap Is Real but Fixable (Teammate C)

The sorry requires `t < s` (strict). If psi ∈ M_t already, the quasimodel may give s = t. Fix: case split on whether psi ∈ M_t:
- If psi ∈ M_t: F(psi) in M_t, so by the scheduling chain, there exists a resolving step for psi at some n > t (via `schedule_surjective_above`). The resolving step gives psi in chain(n+1), providing s = n+1 > t.
- If psi ∉ M_t: the quasimodel chain from (⊤ U psi) gives a non-trivial chain with psi at a strictly later position.

Wait — the first case still requires F(psi) persistence to the resolving step, which is the original obstacle. So the case split doesn't fully resolve the strict gap.

### Finding 7: Literature Confirms Enrichment-First Is Standard (Teammate D)

Teammate D's literature survey reveals that ALL standard completeness proofs for temporal logics with F/G operators handle F-eventuality by ensuring canonical worlds are already enriched BEFORE the chain is built:

- **Burgess 1984**: Defect-discharge over finite subformula closure. F-eventuality holds BY CONSTRUCTION because the schedule guarantees every F(psi) is resolved before the chain repeats. This is the quasimodel approach but at the MCS level (not a Hintikka-point abstraction).

- **Goldblatt 1992**: Every chain step is an enriched Lindenbaum extension of `g_content(prev) ∪ {next F-obligation}`. This keeps ALL other F-formulas in g_content, avoiding F-loss at resolving steps entirely. The key: Goldblatt doesn't use "resolving vs non-resolving" — every step enriches.

- **Verbrugge/de Jongh/Veltman 2004**: DETERMINISTIC successors (not Lindenbaum choice). The chain is built by dovetailing F and P resolution. No non-determinism means no F-formula loss.

- **Gabbay/Hodkinson/Reynolds 1994**: Quasimodel approach where enrichment is done at world-construction time, not seed-construction time.

**Critical insight**: The current BXCanonical scheduling chain uses NON-DETERMINISTIC Lindenbaum extensions. Non-determinism is what causes F-formula loss at resolving steps. All standard approaches avoid this by either (a) deterministic successors, or (b) enriching each world to already contain its F-witnesses.

**New approach surfaced**: Build an ENRICHED chain where every world is a Lindenbaum extension of `g_content(prev) ∪ f_carry(prev)` — always include all current F-obligations in the seed. Prior research showed this is inconsistent for the RESOLVING seed (`{chi} ∪ g_content(M) ∪ f_carry(M)` — counterexample at CanonicalModel.lean:500-507). But Teammate D notes the counterexample uses a NON-enriched M. If M is itself an enriched MCS (where f_carry is already consistent with g_content by construction), the inconsistency may not arise.

### Finding 8: G-Persistence Through Multi-Step Chains Is a Further Obstacle (Teammate D)

Realization.lean:366-395 documents a "chain realization obstacle": G-formulas do NOT persist through Hintikka chains. `hintikka_step_g_prop` proves G(chi) in h1 → chi in h2 for ONE step, but G(chi) ∈ h2 is NOT guaranteed. For chains longer than 2, G(chi) may vanish at step 2.

This affects any chain-based FMCS adapter and is DISTINCT from the forward_F problem. If the quasimodel chain is used for the FMCS, the adapter needs forward_G (G(chi) in chain(t) → chi in chain(t+1) for all t), which requires G(chi) to persist, not just propagate once.

**Mitigation**: For RESTRICTED coherence, only G(chi) with chi ∈ deferralClosure(root) matters. If Sigma ⊇ deferralClosure(root) and G(chi) ∈ Sigma for all such chi, then G(chi) ∈ h1.formulas is possible, and hintikka_step gives chi ∈ h2.formulas. But we also need G(chi) ∈ h2.formulas for multi-step propagation, which is the obstacle.

### Finding 9: Task 82 FMP Is an Immediate Quick Win (Teammate D)

Task 82 (FMP TruthPreservation) closes 2 sorries (`mcs_all_future_closure`, `mcs_all_past_closure`) with estimated 1-2 hours effort. The proofs are described as "parallel to `mcs_box_closure`" (TruthPreservation.lean:188-203). This gives **weak completeness of TM independently of task 93**.

Once task 82 is complete, the 4 sorry sites in task 93 could be reclassified from "active-path blockers" to "open research problems" — the project would have a sorry-free completeness theorem via the FMP route.

### Finding 10: No Architectural Bypass for forward_F Exists (Teammate D)

All completeness strategies for BX-style logics converge on eventuality resolution through some form of quasimodel or enrichment. The truth lemma for F requires `∃ s > t, psi ∈ fam.mcs(s)`, which IS forward_F. The only way to avoid proving it independently is to build the canonical model so it holds BY CONSTRUCTION.

### Finding 11: deferralClosure Extension Breaks Downstream Proofs (Teammate C)

Adding `(⊤ U ψ)` formulas to deferralClosure:
- Breaks `baseDeferralClosure_eq_deferralClosure` (currently `rfl`)
- Breaks `max_F_depth_deferralClosure_eq` (SubformulaClosure.lean:1062) — used in active-path RestrictedMCS.lean
- Breaks `max_P_depth_deferralClosure_eq` (SubformulaClosure.lean:1146)
- Risk to `DeferralRestrictedMCS` pattern-matching

The values of the depth theorems are unchanged (Until has f_nesting_depth 0), but the proofs fail because they unfold `deferralClosure = baseDeferralClosure` via rfl. Fixable but requires re-derivation.

**Alternative**: Use `extendedDeferralClosure` (already defined at SubformulaClosure.lean:812-814) instead of modifying `deferralClosure`. This preserves all downstream lemmas.

## Synthesis

### Conflicts Resolved

**Conflict 1: Is the identity tail correct?**
- Report 11 (round 11): "Identity tail is trivially correct" for all FMCS properties
- Teammate C (round 12): REFUTED — forward_F fails for identity tail
- **Resolution**: Teammate C is correct. F(psi) → psi is not a BX theorem. The identity tail only works for G/H properties (via T-axiom), not for F/P properties. This is a FATAL FLAW in Plan v11.

**Conflict 2: Can restricted_buc be closed independently of forward_F?**
- Prior research: All 4 sorries are interconnected through forward_F
- Teammate B: restricted_buc reduces to step transfer, which is independent of forward_F
- **Resolution**: Teammate B is correct for the step transfer APPROACH, but the step transfer itself is blocked by the same seed enrichment problem (Until formulas are dropped at resolving steps). However, Teammate B's u_carry enrichment proposal is novel and may work because u_carry ⊆ M (unlike f_carry enrichment which adds formulas potentially contradicting the resolving target).

**Conflict 3: Is the quasimodel approach the right path?**
- All prior research (rounds 1-11): YES — quasimodel BFMCS is the recommended approach
- Teammate D (round 12): YES, but with a critical nuance — the ENRICHED CANONICAL MODEL approach (Goldblatt/Verbrugge style) may be more aligned with the codebase's existing scheduling chain
- **Resolution**: Both approaches are viable. The enriched canonical model approach (modifying seeds so every step enriches with ALL F-obligations) may be simpler because it preserves the existing int_chain structure rather than replacing it. The key question is whether the enriched seed is consistent — the prior counterexample (CanonicalModel.lean:500-507) used a non-enriched M. Further investigation needed.

### Gaps Identified

1. **Chain replacement architecture**: The existing int_chain cannot support forward_F or restricted_fuc. A replacement chain must be built that either (a) uses quasimodel construction for the entire chain, (b) splices quasimodel segments into the scheduling chain, or (c) enriches the scheduling chain seeds (Goldblatt approach). None has been fully designed.

2. **Full defect discharge requirement**: The identity tail flaw means the quasimodel chain must discharge ALL F-defects before terminating. This requires iterating defect discharge for all F-formulas in deferralClosure(root), not just one. The termination argument (strictly decreasing defect count) supports this, but the construction is more complex than Plan v11 assumed.

3. **G-persistence through multi-step chains**: Realization.lean:366-395 documents that G-formulas do NOT persist through Hintikka chains beyond one step. Any chain-based FMCS adapter needs multi-step G-propagation for restricted coherence. This is a separate obstacle from forward_F.

4. **Backward chain adapter**: Separate engineering needed for Since/P direction using `hintikka_chain_exists_since` with reversed orientation.

5. **u_carry consistency at resolving steps**: The novel proposal to enrich resolving seeds with defective Until formulas needs formal consistency verification.

6. **Enriched-seed consistency for non-resolving steps**: Teammate D's Goldblatt-style approach (always include f_carry in ALL seeds) requires proving `{chi} ∪ g_content(M) ∪ f_carry(M)` is consistent when M is itself enriched. The prior counterexample assumes non-enriched M — needs re-evaluation.

### Recommendations

**IMMEDIATE ACTION: Close task 82 FMP sorries (1-2 hours)**
This gives a sorry-free weak completeness theorem immediately, independent of task 93. Once done, the 4 sorry sites in task 93 can be reclassified from "critical path blockers" to "open research" — the project has completeness via FMP.

**REVISE Plan v11** to address the identity tail flaw and incorporate literature insights. Four options, ranked:

**Option 1: Enriched canonical model (Goldblatt/Verbrugge style) — NEW, RECOMMENDED**
Modify the scheduling chain so that EVERY step (both resolving and non-resolving) enriches with `g_content(M) ∪ f_carry(M)`. This preserves the existing int_chain structure but changes the seed construction.
- Consistency check: the prior counterexample (`G(F(alpha) → ¬psi) ∈ M, F(alpha) ∈ M, F(psi) ∈ M`) shows `{chi} ∪ g_content(M) ∪ f_carry(M)` can be inconsistent. But if M is itself enriched (built with f_carry-enriched seeds throughout), does this scenario still arise? This is the KEY QUESTION for this approach.
- Estimated effort: 100-200 lines modifying WitnessSeed.lean + re-proving consistency lemmas
- Risk: If the enriched-seed counterexample persists even for enriched M, this approach fails

**Option 2: Full chain replacement (quasimodel-only FMCS)**
Replace `int_chain` entirely with a quasimodel-constructed chain:
1. Start from M₀ (the root MCS)
2. Forward direction: iteratively discharge ALL F-defects and Until-defects using `hintikka_chain_exists`, concatenating finite chains
3. Backward direction: symmetrically using `hintikka_chain_exists_since`
4. No identity tail — the chain is the full concatenation of finite defect-discharge segments, then periodic extension
5. G-persistence obstacle (Finding 8) must be addressed

Risk: G-persistence through multi-step chains + the concatenation may reintroduce defects. Estimated 500-700 lines, 20-30 hours.

**Option 3: Modified scheduling chain with u_carry enrichment (partial fix)**
1. Add `u_carry(M)` to both resolving and non-resolving seeds in `fwd_succ`/`bwd_pred`
2. Prove consistency of enriched seeds
3. Close restricted_buc via step transfer
4. Forward_F and restricted_fuc remain blocked — defer to quasimodel approach

This gives a partial win (1 of 4 sorries) with lower risk.

**Option 4: Redefine BFMCS using quasimodel families**
Instead of shifted scheduling chains as BFMCS families, use quasimodel-constructed chains directly. This avoids the int_chain ↔ BXPoint bridge entirely but is the most invasive change.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary (quasimodel adapter) | completed | MEDIUM | Mapped full quasimodel API; confirmed BXPoint-to-Int bridge is the core gap; found both Until and Since infrastructure exist |
| B | Alternatives | completed | MEDIUM | Found restricted_buc may be independent of forward_F; proposed u_carry enrichment; decomposed 4 sorries into two groups |
| C | Critic | completed | HIGH | FATAL FLAW: identity tail cannot witness F-eventualities; deferralClosure extension breaks downstream; strict gap analysis |
| D | Strategic horizons | completed | MEDIUM | Literature confirms enrichment-first is standard; Goldblatt-style enriched chain as new approach; task 82 quick win; G-persistence obstacle documented |

## Key Decision Points

| Decision | Options | Recommendation |
|----------|---------|----------------|
| Immediate action? | Continue task 93 / Do task 82 first | **Task 82 first** — 1-2h for sorry-free weak completeness |
| Identity tail approach? | Use / Abandon | **ABANDON** — F(psi) not witnessed by constant tail |
| Chain architecture? | Enriched seeds (Goldblatt) / Full replacement / Redefine BFMCS | **Enriched seeds** if consistency holds; **Full replacement** as fallback |
| Close restricted_buc independently? | Yes (u_carry) / No (wait for full fix) | **YES** — lower risk, tangible progress |
| deferralClosure modification? | Modify / Use extendedDeferralClosure | **Use extendedDeferralClosure** (preserves downstream) |
| Continue quasimodel path? | Continue / Abandon / Descope | **CONTINUE** with revised architecture (no identity tail) |

## Priority-Ordered Action Plan

1. **Close task 82 FMP sorries** (1-2 hours) — sorry-free weak completeness
2. **Investigate enriched-seed consistency** (2-4 hours) — does `{chi} ∪ g_content(M) ∪ f_carry(M)` remain inconsistent when M is enriched?
3. **If enriched seeds work**: Modify WitnessSeed.lean to always include f_carry (Goldblatt approach)
4. **If enriched seeds fail**: Proceed with full quasimodel chain replacement (Option 2)
5. **In parallel**: Attempt u_carry enrichment for restricted_buc (Option 3)

## References

- CanonicalModel.lean lines 491-510 (obstacle analysis)
- Realization.lean lines 366-395 (G-persistence obstacle)
- Realization.lean lines 419-424 (hintikka_step_g_prop)
- Construction.lean lines 594-659 (hintikka_chain_exists)
- Construction.lean lines 769-824 (hintikka_chain_exists_since)
- UntilSinceCoherence.lean line 111 (backward_until_from_step)
- SubformulaClosure.lean lines 809-814 (deferralClosure, extendedDeferralClosure)
- CanonicalChain.lean lines 65-72 (F_imp_top_until_mcs / BX12)
- DefectChain.lean (defect step infrastructure)
- Burgess 1984 "Basic Tense Logic" — defect-discharge at MCS level
- Goldblatt 1992 "Logics of Time and Computation" Ch.4,8 — enriched canonical models
- Verbrugge/de Jongh/Veltman 2004 "Completeness by Construction" — deterministic successors
- Gabbay/Hodkinson/Reynolds 1994 Vol.1 — quasimodel enrichment at construction time
