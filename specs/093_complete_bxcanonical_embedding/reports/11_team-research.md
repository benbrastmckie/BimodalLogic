# Research Report: Task #93 — Close BXCanonical Embedding (Round 11)

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates)
**Session**: sess_1776119505_4d23f2

## Summary

Sixth team research round. After the v10 plan was blocked by three mathematical obstacles (F-carry inconsistency, step transfer invalidity, Until carry inconsistency), this round conducts a fresh investigation of the codebase and viable approaches. All 4 teammates converge on two key findings: (1) the scheduling induction for forward_F (t >= 0) is BLOCKED by F-formula loss at resolving steps for other formulas — f_carry is not included in the resolving branch seed, and no BX axiom gives F(psi) -> G(F(psi)) to recover it; (2) the quasimodel BFMCS approach (Path 1) is the most viable path because RESTRICTED coherence (the only thing needed) bypasses the full Realization.lean G-persistence obstacle — restricted forward_G only needs G-propagation within SubformulaClosure(root), which hintikka_step_g_prop already provides.

## Key Findings

### Finding 1: 4 Active-Path Sorries, Not 2

All teammates confirm: `bx_bfmcs_restricted_tc` at CanonicalModel.lean:603 appears proved (no top-level `sorry`) but delegates to `bx_fmcs_forward_F` (line 610) and `bx_fmcs_backward_P` (line 614), which are both sorry'd. The active path through `bx_countermodel` therefore depends on 4 sorry sites:

| Line | Sorry | Role |
|------|-------|------|
| 497 | `bx_fmcs_forward_F` | F(psi) persistence (via restricted_tc) |
| 503 | `bx_fmcs_backward_P` | P(psi) persistence (via restricted_tc) |
| 621 | `bx_bfmcs_restricted_buc` | Backward Until/Since coherence |
| 627 | `bx_bfmcs_restricted_fuc` | Forward Until/Since coherence |

### Finding 2: BX12 Is Proved But Does Not Close forward_F

BX12 (`F(psi) -> (top U psi)`) exists as `F_imp_top_until_mcs` at CanonicalChain.lean:65 (proved). However:

- **Reduction gap**: BX12 converts F(psi) to (top U psi), and Until resolution gives a BXPoint v with psi in v. But v is an arbitrary Lindenbaum extension, NOT a member of `int_chain`. The chain-membership gap is the core blocker. (Teammate A)
- **Strict/non-strict gap**: forward_F requires `s > t` (strict future), but Until gives `s >= t`. When psi is already in fam.mcs(t), the s=t witness is invalid for forward_F. The strict requirement is mathematically necessary for the `all_future` truth lemma case. (Teammate C)
- **forward_Until is also sorry'd**: `bx_bfmcs_restricted_fuc` (line 627) is itself sorry'd, so reducing forward_F to forward_Until doesn't help without closing forward_Until too. (Teammate C)

### Finding 3: F-Formula Persistence Through Resolving Steps Is Genuinely Impossible

Teammates A, B, C, and D all independently confirm the persistence gap:

- The `fwd_succ` resolving branch (line 74-80) uses seed `{psi'} union g_content(M)` — f_carry is NOT included
- When schedule(k) = psi' != psi and F(psi') in chain(k), the resolving branch fires and F(psi) may be lost
- F(psi) -> G(F(psi)) (perpetuity) does NOT hold in BX for discrete time (Teammate B: if psi holds at exactly the next step and nowhere else, F(psi) holds now but fails at the next step)
- Adding f_carry to the resolving seed is inconsistent (Report 07 Finding 2, re-confirmed)

**A's scheduling induction** (forward_F for t >= 0) has a flaw: A assumes "schedule(k) != psi implies non-resolving branch" but the branch decision depends on F(schedule(k)) in chain(k), not on whether schedule(k) = psi. Other F-formulas can trigger resolving steps that drop F(psi).

### Finding 4: Quasimodel BFMCS Bypasses the G-Persistence Obstacle (for Restricted Coherence)

This is the key new insight from Teammate D, resolving a conflict from round 10:

- **Full G-persistence** (needed for unrestricted FMCS): Requires G(chi) in chain(t) implies chi in chain(t+1) for ALL chi. This fails for chi outside SubformulaClosure(root) — the Realization.lean obstacle at lines 366-395.
- **Restricted G-persistence** (needed for restricted coherence): Only requires G(chi) propagation for chi in deferralClosure(root) subset SubformulaClosure(root). The existing `hintikka_step_g_prop` at Realization.lean:419+ provides exactly this.

Therefore, building an FMCS from a quasimodel chain works for RESTRICTED coherence even though it fails for full coherence. This distinction was missed in rounds 9-10.

### Finding 5: Identity Tail Is Trivially Correct

Teammate D proves: for a constant chain segment `chain(k) = M_last` for all k > n, all FMCS coherence properties hold trivially. Forward_G: `G(phi) in M_last -> phi in M_last` by BX T-axiom. Similarly for backward_H. No new proof needed. This closes one of round 10's open gaps.

### Finding 6: Step Transfer for Backward Until Is Built Into Quasimodel Defect-Discharge

The step transfer (`(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)`) is the hardest remaining problem for the scheduling chain approach. In a quasimodel chain, step transfer is built into the defect-persistence mechanism: when (phi U psi) is a defect at step r, it stays a defect until discharged, so it persists by construction (Teammate D).

This is a decisive advantage of the quasimodel approach over the scheduling chain.

### Finding 7: Literature Confirms Quasimodel/Enrichment as Standard

Teammate D surveys Burgess 1984, Xu 1988, Reynolds 1996/2003, Goldblatt 1992:
- Standard completeness proofs avoid forward_F as an independent obligation by using enriched closures (Reynolds) or quasimodel defect-discharge (Burgess/Xu)
- BX12 is the exact bridge axiom used by Reynolds/Xu
- The codebase already has BX12 proved and ~2,289 lines of quasimodel infrastructure

### Finding 8: No Scope Reduction Possible

All 4 sorry sites must be closed together (Teammate D). There is no meaningful partial milestone. The forward_F sorry is the root cause; closing it propagates to restricted_tc, which enables restricted_fuc and restricted_buc.

## Synthesis

### Conflicts Resolved

**Conflict 1: Can forward_F be proved by scheduling induction?**
- A: YES for t >= 0 (75%), citing f_carry persistence + schedule_surjective_above
- C: NO, F-formulas are lost at resolving steps for other formulas
- **Resolution**: C is correct. A's analysis has a gap: "schedule(k) != psi" does NOT imply the non-resolving branch is taken. The resolving branch fires when F(schedule(k)) in chain(k), which can happen for schedule(k) != psi. F(psi) is then dropped from the resolving seed. **Verdict: scheduling induction alone does NOT close forward_F.**

**Conflict 2: Does the quasimodel approach bypass the G-persistence obstacle?**
- B: NO, the same obstacle appears in any chain-realization attempt
- C: NO, Realization.lean obstacle is not avoided
- D: YES for RESTRICTED coherence — G-propagation within SubformulaClosure suffices
- **Resolution**: D is correct for the restricted case. B and C analyze the UNRESTRICTED case (full G-persistence for arbitrary formulas), which indeed fails. But `bx_countermodel` only needs RESTRICTED coherence, which only requires G-propagation within SubformulaClosure(root). The existing `hintikka_step_g_prop` provides this. **Verdict: quasimodel BFMCS is viable for restricted coherence.**

**Conflict 3: What is the primary approach?**
- A: Scheduling induction (for t >= 0) + unresolved negative-t case
- B: F(psi) -> G(F(psi)) perpetuity route (but this axiom doesn't exist in BX)
- D: BX12 + quasimodel BFMCS (Path 1)
- **Resolution**: Path 1 (D's approach) is the only approach that addresses all obstacles simultaneously: F-persistence via quasimodel defect-discharge, step transfer via built-in defect-persistence, G-propagation via restricted hintikka_step. **Verdict: Path 1 (BX12 + quasimodel BFMCS).**

### Gaps Identified

1. **FMCS forward_G interface**: Can `hintikka_step_g_prop` provide forward_G for all formulas in deferralClosure(root), or only those in SubformulaClosure(root)? If deferralClosure includes formulas outside SubformulaClosure (like deferral disjunctions), restricted forward_G needs more than hintikka_step alone.

2. **Backward chain construction**: The quasimodel chain is naturally forward-directed (discharging Until defects). The backward direction (Since defects) needs a symmetric construction. Is there existing backward quasimodel infrastructure?

3. **deferralClosure extension downstream impact**: Adding (top U psi) for each F(psi) enlarges deferralClosure. Downstream lemmas like `max_F_depth_deferralClosure_eq` and `DeferralRestrictedMCS` pattern-matching need verification (Teammate C).

4. **QuasimodelChain-to-FMCS adapter**: The exact interface between `QuasimodelChain` output (finite Hintikka point sequence) and `FMCS Int` input (Int-indexed MCS function with forward_G/backward_H) needs engineering. Estimated 100-150 lines.

### Recommendations

**Primary approach (Path 1): BX12 + Quasimodel BFMCS**

Phase 1 (~20 lines): Extend deferralClosure to include (top U psi) for each F(psi).

Phase 2 (~100-150 lines): Build QuasimodelChain-to-FMCS adapter:
- Map finite Hintikka chain to Int via offset + identity tails
- Prove forward_G/backward_H within deferralClosure(root) using hintikka_step_g_prop
- Forward_F follows from quasimodel defect-discharge (F-eventualities are discharged by construction)

Phase 3 (~100-150 lines): Prove restricted coherence:
- restricted_tc: forward_F via defect-discharge, backward_P symmetrically
- restricted_buc: via backward_until_from_step with step transfer from defect-persistence
- restricted_fuc: via defect-discharge for Until eventualities

Phase 4 (~50 lines): Wire into bx_bfmcs and bx_countermodel.

Total estimated: 300-400 lines, 12-16 hours.

**Fallback (Path 2): Root-parameterized chain**

If Path 1 hits interface obstacles, modify the scheduling chain with a finite round-robin over deferralClosure(root). Step transfer via BX4' remains the highest-risk element. Estimated 250-350 lines.

**Go/No-Go gate**: After Phase 1 (deferralClosure extension), verify downstream compilation. If major breakage, reassess.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary (scheduling induction) | completed | MEDIUM | Identified f_carry persistence for non-resolving steps; mapped all 6 sorry sites; found negative-t case is genuinely hard |
| B | Alternatives (quasimodel pipeline) | completed | MEDIUM | Mapped FMCS/BFMCS interfaces; confirmed F(psi)->G(F(psi)) unavailable; identified forward_Until as independently sorry'd |
| C | Critic | completed | HIGH | Exposed A's scheduling induction flaw; confirmed strict/non-strict gap is real; forward_Until independently sorry'd; 4 active-path sorries not 2 |
| D | Strategic Horizons | completed | MEDIUM-HIGH | Proved identity tail trivial; discovered restricted G-persistence bypasses Realization obstacle; literature survey confirms standard approach; step transfer built into quasimodel |

## Key Decision Points

| Decision | Options | Recommendation |
|----------|---------|----------------|
| Scheduling induction for forward_F? | Execute / Skip | **SKIP** — F-formula loss at resolving steps for other formulas |
| BX12 deferralClosure extension? | Extend / Skip | **EXTEND** — ~20 lines, enables F -> Until reduction |
| Primary architecture? | Quasimodel BFMCS / Root-param chain / Scheduling fix | **Quasimodel BFMCS** (Path 1) |
| Accept sorries? | Accept / Continue | **CONTINUE** — 300-400 lines away from completion |

## References

- Burgess 1984, "Basic Tense Logic" — quasimodel defect discharge
- Reynolds 1996/2003 — F-to-Until reduction via enriched closure (BX12)
- Xu 1988 — BX completeness over linear orders
- Goldblatt 1992 — Logics of Time and Computation
- Report 10 (team research) — Plan v8 double-fatality confirmed
- Handoff 10 (deep analysis) — F-carry inconsistency counterexample, step transfer invalidity
- Realization.lean:366-395 — G-persistence obstacle documentation
- CanonicalModel.lean:74-113 — fwd_succ with f_carry mechanism
- CanonicalChain.lean:65 — F_imp_top_until_mcs (BX12 at MCS level, proved)
- UntilSinceCoherence.lean:111 — backward_until_from_step (parameterized by step transfer)
