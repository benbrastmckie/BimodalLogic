# Research Report: Task #113 — R-Relation Redesign for Open Guard

**Task**: 113 - Open Guard Refactoring for Until/Since Semantics
**Date**: 2026-04-28
**Mode**: Team Research (4 teammates)
**Session**: sess_1777359354_f64100

## Summary

The Phase 3 blocker — 10 sorry stubs in Chronicle/ classified as "semantically invalid" — is confirmed real but **more contained than initially assessed**. The r-relation DEFINITIONS are already correct for open guard. The broken LEMMAS split into three categories: (1) 8 genuinely invalid statements to archive, (2) 2 statements that are true but need proof restructuring, and (3) obligation-based infrastructure that is dead code. The chronicle construction does NOT fundamentally depend on BX9; the codebase was taking a shortcut via BX9 that happened to work under half-closed guard but was never the canonical approach (Burgess 1982, Xu 1988).

## Key Findings

### 1. R-Relation Definitions Are Sound (No Change Needed)

All teammates agree: the core `rRelation` and `burgessR3` definitions in ChronicleTypes.lean are semantically correct under open guard. They capture what holds at INTERMEDIATE points between t and the witness s — exactly the open interval (t,s). The definitions are guard-agnostic.

### 2. Classification of Sorry Stubs

**Category A — Genuinely Invalid (8 stubs, archive to Boneyard):**

| Lemma | File | Why Invalid |
|-------|------|-------------|
| `until_disjunction_in_mcs` | RRelation.lean:87 | BX9 statement, semantically false |
| `until_guard_in_mcs` | RRelation.lean:107 | Guard extraction at t, t ∉ (t,s) |
| `since_guard_in_mcs` | RRelation.lean:122 | Mirror |
| `since_disjunction_in_mcs` | RRelation.lean:163 | Mirror |
| `untl_absorb_nested` | RRelation.lean:1259 | Junction point s₁ not covered by open guard |
| `snce_absorb_nested` | RRelation.lean:1271 | Mirror |
| `rRelation_of_superset_mcs` | ChronicleTypes.lean:569 | Requires BX9 for case-split |
| `rRelationSince_of_superset_mcs` | ChronicleTypes.lean:578 | Mirror |

Counterexamples constructed by Teammates A and C confirm these are false under open guard. No alternative proof paths exist.

**Category B — True Statement, Needs Proof Restructuring (2 stubs):**

| Lemma | File | Fix Strategy |
|-------|------|-------------|
| `BurgessR3Maximal_maximality_combined` | PointInsertion.lean:662 | delta.neg-in-B branch needs rework (see §3) |
| `burgess_D0_consistent` | PointInsertion.lean:972 | Depends on above; true by Burgess 1982 Lemma 2.6 |

**Category C — Dead Code (archive):**

| Lemma | File | Why Dead |
|-------|------|----------|
| `rRelation_self_mcs` / `rRelationSince_self_mcs` | RRelation.lean | Only used by obligation-based `lemma_2_6_full` |
| `lemma_2_6_full` | PointInsertion.lean | Obligation-based path; construction uses content-based BurgessR3Maximal |
| `rRelation_of_subset_mcs` | RRelation.lean | Depends on invalid superset lemma |
| `r3Relation_of_superset_mcs` | RRelation.lean | Depends on invalid superset lemma |
| `B_sub_A_of_burgessR3` / `B_sub_C_of_burgessR3` | RRelation.lean | B ⊆ A not needed under open guard (interval set ≠ endpoint set) |
| `burgessR3_gamma_not_in_B_nested` / mirror | RRelation.lean | Uses invalid absorption; C4 condition handles this directly |

**Category D — Orthogonal (not task 113):**

The 6 c2' stubs in CounterexampleElimination.lean and the 1 C4 hard case stub predate the open guard change. These are task 107 Phase 2-3 implementation gaps.

### 3. The Crux: `BurgessR3Maximal_maximality_combined` Delta-Neg-in-B Case

This is the one genuinely hard problem. When delta.neg ∈ B:

- BX2 gives `untl(bot, gamma) ∈ A` for all gamma ∈ C
- Old proof: `until_guard` extracts `bot ∈ A` → contradiction. INVALID under open guard.
- BX10 gives `F(gamma) ∈ A` for all gamma ∈ C — not contradictory.

**Resolution paths identified:**

1. **Density approach** (Teammate B, C): On dense orders, `bot U gamma` is semantically unsatisfiable (guard interval (t,s) is always nonempty, bot can't hold). The density axiom DN (`FF(phi) → F(phi)`) may allow deriving `¬(bot U gamma)` syntactically, giving the contradiction. The Burgess construction targets dense orders, so this is appropriate.

2. **Extension-fails restructuring** (Teammate A): When delta.neg ∈ B, the set {delta} ∪ B is inconsistent. Restructure the proof to first check consistency of {delta} ∪ B, short-circuiting the inconsistent case via the extension-fails theorem.

3. **Contrapositive via `left_mono_contrapositive_neg_delta`** (Teammate C): This existing VALID theorem (RRelation.lean:887) provides an alternative tool that avoids the `bot U gamma` step entirely.

**Recommendation**: Try path 2 first (cleanest), fall back to path 1 if needed. Path 3 is available as backup.

### 4. Xu 2.3(i) Already Implemented

Teammate B confirmed: Xu's Lemma 2.3(i) — the canonical r-relation propagation mechanism — is ALREADY implemented as `rRelation_guard_continues'` (RRelation.lean:185). No new infrastructure needed. The invalid lemmas were shortcuts, not structural requirements.

### 5. `untl_absorb_nested` Is Genuinely Invalid

Teammate C constructed an explicit counterexample in ℤ: gamma(2) is the uncovered junction point between outer guard (0,2) and inner guard (2,4). This confirms the statement `φ U (φ U ψ) → φ U ψ` is FALSE under open guard semantics. Callers should use `burgessR3_gamma_not_in_B` (valid, no absorption needed) combined with C4 condition.

### 6. Strategic Alignment

Teammate D confirmed:
- Open guard is unambiguously correct (all published sources agree)
- The 31-axiom system (BX minus BX8/BX8'/BX9/BX9'/guards) matches Xu's Σ₄, which is complete
- Task 107 impact is contained: only Phase 4.1 has a single BX9 dependency
- The Boneyard approach is correct — archived code is provably unsound
- Ideal end state: sorry-free `dd_countermodel_chronicle` via Burgess chronicle

## Synthesis

### Conflicts Resolved

1. **"Can the lemmas be rebuilt?" vs "They are semantically invalid"**: All teammates agree on the 8/2/dead classification. No conflict.

2. **Density requirement**: Teammates B and C flagged that `BurgessR3Maximal_maximality_combined` may need density for the `bot U gamma` case. Teammate A proposed a restructuring that may avoid density. Resolution: try restructuring first; if it fails, density is available and appropriate since the chronicle targets dense orders.

3. **B ⊆ A requirement**: Teammate A initially explored whether this is needed, then concluded it is NOT needed under open guard (the interval set represents formulas on the open interval, not at endpoints). Teammates C and D agree.

### Gaps Identified

1. Whether the extension-fails restructuring of `BurgessR3Maximal_maximality_combined` works mechanically in Lean (needs hands-on proof development)
2. Whether density axiom DN is needed or if the restructuring avoids it entirely
3. Complete dead-code audit of obligation-based rRelation infrastructure (high-confidence but not exhaustive)

### Recommendations

**For the revised Phase 3 plan:**

1. **Archive Category A** (8 invalid lemmas) to `Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean` (extend existing archive)
2. **Archive Category C** (dead code: obligation-based rRelation infrastructure) to same Boneyard file
3. **Fix Category B**: Restructure `BurgessR3Maximal_maximality_combined` delta.neg-in-B branch, then fix `burgess_D0_consistent`
4. **Fix `cantor_bfmcs_restricted_buc`**: Mechanical `le` → `lt` adjustment in ChronicleToCountermodel.lean
5. **Leave Category D** (c2' stubs) for task 107

**Estimated effort**: 4-6 hours for archival + restructuring + verification.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Lines |
|----------|-------|--------|------------|-------|
| A | Primary: r-relation analysis | completed | 9/10 | 384 |
| B | Alternatives: literature | completed | 8/10 | 260 |
| C | Critic: verification | completed | 8.5/10 | 227 |
| D | Horizons: strategy | completed | 9/10 | 227 |

## References

- Burgess, J. P. (1982). "Axioms for Tense Logic II: Time Periods." *Notre Dame Journal of Formal Logic*.
- Xu, M. (1988). "On some U,S-tense logics." *Journal of Philosophical Logic*, 17(2), 181-202.
- Reynolds, M. (1992). "An axiomatization of Prior's temporal logic with Since and Until."
- Kamp, H. (1968). *Tense Logic and the Theory of Linear Order*. PhD thesis, UCLA.
- Venema, Y. (1993). "Derivation rules as anti-axioms in modal logic."
