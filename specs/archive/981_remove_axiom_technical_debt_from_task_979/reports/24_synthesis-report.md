# Research Report: Task #981 - Synthesis

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-18
**Session**: sess_1773869433_1a5c06
**Type**: Synthesis of teammate findings

---

## Summary

This report synthesizes findings from two parallel research efforts analyzing the blocking sorry in `timelineQuot_not_valid_of_neg_consistent` (TimelineQuotCompleteness.lean:127). The combined analysis reveals a **key breakthrough**: the forward-only truth lemma approach completely bypasses the BFMCS construction that has blocked all previous attempts.

---

## Key Finding: Forward-Only Truth Lemma

**The completeness proof only needs the forward direction of the truth lemma.**

For the contrapositive completeness proof (¬provable → ¬valid), we need to show:
```
φ.neg ∈ root_mcs → truth_at M Omega τ rootTime φ.neg
```

This is the **forward direction only** (MCS membership → semantic truth). The backward direction (semantic truth → MCS membership) is NOT needed for completeness.

### Why Forward-Only Works

The completeness proof via contradiction:
1. `φ.neg ∈ root_mcs` (by Lindenbaum construction)
2. By forward truth lemma: `truth_at M Omega τ rootTime φ.neg`
3. Since `φ.neg = φ.imp bot`: this means `¬truth_at M Omega τ rootTime φ`
4. Therefore `¬valid_over D φ`

### What Forward Direction Requires (All Sorry-Free)

| Formula Case | Requirement | Status |
|--------------|-------------|--------|
| Atom | Valuation definition | Sorry-free |
| Bot | Trivial | Sorry-free |
| Imp | IH (forward only) | Sorry-free |
| Box | Modal T-axiom (□φ → φ) | Sorry-free (in proof system) |
| G (all_future) | `forward_G` from FMCS | Sorry-free (`timelineQuotFMCS`) |
| H (all_past) | `backward_H` from FMCS | Sorry-free (`timelineQuotFMCS`) |

**Critical**: F/P witnesses (temporal coherence) are only needed for the **backward** direction of G/H. The forward direction doesn't need them.

---

## Comparison of Approaches

### Previously Attempted (Blocked)

| Approach | Blocker |
|----------|---------|
| Full BFMCS over TimelineQuot | `modal_backward` requires modal saturation |
| Singleton BFMCS | `modal_backward` fails for single family |
| Dovetailed construction | Covering proof gap, density argument incomplete |
| Int parametric | F/P witnesses construction blocked |

### Recommended: Forward-Only Truth Lemma

**No BFMCS required**. Uses singleton Omega = `{separatedHistory}`.

For the box case:
- `□φ ∈ mcs(t)` (hypothesis)
- By modal T-axiom: `φ ∈ mcs(t)`
- By IH forward: `truth_at ... φ`
- Since Omega = {τ}, quantifying "∀ σ ∈ Omega" reduces to "at τ"

This completely sidesteps:
- `modal_backward` (not needed)
- `modal_forward` (collapses to T-axiom for singleton)
- F/P temporal witnesses (only needed for backward G/H)
- Dovetailing construction (only needed for F/P)

---

## Required Components (All Sorry-Free)

| Component | File | Status |
|-----------|------|--------|
| `timelineQuotFMCS` | TimelineQuotCanonical.lean | Sorry-free |
| `forward_G`, `backward_H` | TimelineQuotCanonical.lean | Sorry-free |
| `timelineQuotMCS_root_time_eq` | TimelineQuotCanonical.lean | Sorry-free |
| `separatedHistory` | SeparatedHistory.lean | Sorry-free |
| `ShiftClosedSeparatedOmega` | SeparatedHistory.lean | Sorry-free |
| `timelineQuotParametricTaskFrame` | ParametricCanonical.lean | Sorry-free |
| `ParametricCanonicalTaskModel` | ParametricCanonical.lean | Sorry-free |
| Modal T-axiom | DerivationTree (proof system) | Derivable |

---

## Implementation Strategy

### Recommended: Specialized Forward Truth Lemma

Create a new theorem in `TimelineQuotCompleteness.lean`:

```lean
theorem timelineQuot_truth_lemma_forward
    (root_mcs : Set Formula) (h_mcs : SetMaximalConsistent root_mcs)
    (φ : Formula) (t : TimelineQuot root_mcs h_mcs) :
    φ ∈ timelineQuotMCS root_mcs h_mcs t →
    truth_at (ParametricCanonicalTaskModel (TimelineQuot root_mcs h_mcs))
      (ShiftClosedSeparatedOmega root_mcs h_mcs)
      (separatedHistory root_mcs h_mcs)
      t φ
```

Then fill the sorry:

```lean
theorem timelineQuot_not_valid_of_neg_consistent (φ : Formula)
    (h_cons : ContextConsistent [φ.neg]) :
    ¬valid_over D φ := by
  intro h_valid
  -- Construct countermodel
  let F := timelineQuotParametricTaskFrame root_mcs h_mcs
  let M := ParametricCanonicalTaskModel D
  let Omega := ShiftClosedSeparatedOmega root_mcs h_mcs
  let τ := separatedHistory root_mcs h_mcs
  -- Show φ.neg is true at rootTime (forward direction)
  have h_neg_true := timelineQuot_truth_lemma_forward root_mcs h_mcs φ.neg rootTime
  -- Extract root_mcs contains φ.neg via Lindenbaum
  have h_neg_mem : φ.neg ∈ root_mcs := lindenbaumMCS_contains ...
  -- Derive φ.neg ∈ mcs(rootTime) = root_mcs
  rw [timelineQuotMCS_root_time_eq] at h_neg_true
  -- Apply forward truth lemma
  have h_truth_neg := h_neg_true h_neg_mem
  -- Contradiction: h_valid instantiated at (F, M, Omega, τ, rootTime) gives truth_at φ
  -- But truth_at φ.neg = ¬truth_at φ
  ...
```

### Estimated Effort

| Component | Estimate |
|-----------|----------|
| Forward truth lemma induction | 2-3 hours |
| Box case (modal T-axiom) | 1 hour |
| G/H cases (forward_G/backward_H) | 1 hour |
| Wiring in completeness theorem | 1 hour |
| **Total** | 4-6 hours |

---

## Plan Revision Recommendation

The existing plan (v8) should be revised:

### Current Plan Status
- Phase 1: COMPLETE (timelineQuotMCS_root_time_eq proved)
- Phases 2-4: BLOCKED (countermodel requires truth lemma)

### Recommended Revision

**Replace Phases 2-4 with:**

**Phase 2: Forward Truth Lemma** (NEW)
- Implement `timelineQuot_truth_lemma_forward` by induction on φ
- Cases: atom, bot, imp, box (via T-axiom), G (via forward_G), H (via backward_H)
- No F/P witnesses or BFMCS machinery needed

**Phase 3: Complete timelineQuot_not_valid_of_neg_consistent** (REVISED)
- Wire forward truth lemma into the sorry
- Construct countermodel using singleton Omega
- Extract contradiction from validity hypothesis

**Phase 4: Remove** (DELETE)
- The "countermodel requires truth lemma infrastructure" concern is resolved
- The forward-only approach doesn't need additional wiring

---

## Confidence Assessment

| Aspect | Confidence | Rationale |
|--------|------------|-----------|
| Mathematical soundness | **High** | Forward-only direction is standard in completeness proofs |
| Required components exist | **High** | All listed components verified sorry-free |
| No hidden blockers | **Medium-High** | Box case requires T-axiom derivability check |
| Effort estimate | **Medium** | Induction proof may have Lean-specific hurdles |

### Potential Risk

The modal T-axiom (□φ → φ) must be derivable for any MCS. This follows from the reflexivity of the canonical accessibility relation, which should be established in the modal semantics. If not explicit, it may require a small lemma.

---

## Synthesis from Teammate Reports

### From Teammate A (Primary Analysis)

Key contributions:
- Precise identification of the mathematical gap (BFMCS over TimelineQuot)
- Detailed analysis of parametric machinery applicability
- Evidence that all entry points (timelineQuotFMCS, timelineQuotMCS_root_time_eq) are sorry-free

### From Teammate B (Alternative Approaches)

Key contributions:
- **Critical breakthrough**: Forward-only truth lemma insight
- Analysis showing F/P witnesses only needed for backward direction
- Proof that box case collapses to T-axiom for singleton Omega
- Detailed implementation sketch

### Combined Insight

Teammate A's deep analysis of the BFMCS requirements combined with Teammate B's alternative approach analysis reveals that the BFMCS machinery was never actually required - the forward direction suffices, and the forward direction doesn't need the BFMCS properties that were blocking progress.

---

## Next Steps

1. **Revise plan** to incorporate forward-only truth lemma approach
2. **Verify T-axiom derivability** in MCS (quick check)
3. **Implement Phase 2** (forward truth lemma)
4. **Complete Phase 3** (wire into completeness theorem)

---

## References

- Teammate A findings: `specs/981_remove_axiom_technical_debt_from_task_979/reports/23_teammate-a-findings.md`
- Teammate B findings: `specs/981_remove_axiom_technical_debt_from_task_979/reports/23_teammate-b-findings.md`
- Prior research (post-task 991): `specs/981_remove_axiom_technical_debt_from_task_979/reports/research-011.md`
- Current plan (v8): `specs/981_remove_axiom_technical_debt_from_task_979/plans/08_truth-lemma-wiring.md`
