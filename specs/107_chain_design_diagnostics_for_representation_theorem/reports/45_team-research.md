# Research Report: Task #107

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-29
**Session**: sess_1777479592_b37497
**Mode**: Team Research (4 teammates)
**Type**: lean4

## Summary

Team research resolves the Phase 5b blocker (`splitting_seed_consistent`) by identifying a clean three-step solution: (1) add `left_mono_until_G` axiom, (2) prove `g_content(A) ⊆ B` when `BurgessR3Maximal(A, B, C)` via a maximality argument, (3) `splitting_seed_consistent` becomes trivial since the seed is a subset of `{β.neg} ∪ B`, which is consistent by `dcs_neg_union_consistent`. This avoids both the problematic bidirectional seed consistency argument (A4a path) and the full Xu 2.3/2.4 formalization. A4a (already in the codebase) can be retained or removed — it is not needed for splitting. The actual sorry count is 10 (not 13), and the remaining 9 sorries downstream are independent of the axiom choice.

## Key Findings

### 1. left_mono_until_G Is the Missing Axiom (Unanimous: A, B, C)

All three research-focused teammates independently confirm that the BX axiom system under open-guard semantics lacks an axiom capturing guard strengthening under G-information:

```
left_mono_until_G:  G(φ → χ) → untl(φ, ψ) → untl(χ, ψ)
```

**Why it's needed**: Under open-guard semantics, `untl(φ, ψ)` at t means ∃s>t: ψ(s) ∧ ∀u∈(t,s): φ(u). The guard interval (t,s) is strictly future of t. Since G(φ→χ) gives (φ→χ) at all u>t, it covers every point in (t,s). So if untl(φ, ψ) holds and G(φ→χ) holds, then untl(χ, ψ) holds. The soundness proof is 3 lines.

**Why BX2 fails**: BX2 (current `left_mono_until`) requires BOTH `(φ→χ)` AND `G(φ→χ)`. Under irreflexive semantics, the pointwise condition `(φ→χ)` at the current time t is NOT available because t ∉ (t,s). The G-condition alone suffices semantically, but BX2 demands both.

**Axiom (1) decomposition** (Teammate A): Xu's axiom (1) has two conjuncts. The first (guard/event swap) is INVALID under open guard. The second IS `left_mono_until_G` in BX conventions. Only the second is needed.

### 2. g_content(A) ⊆ B When BurgessR3Maximal(A, B, C) — The Breakthrough (Teammate B, verified)

Teammate B identifies the key insight: **g_content(A) ⊆ B is provable from BurgessR3Maximal's maximality**, given `left_mono_until_G`.

**Proof sketch** (corrected to use left_mono_until_G for guard strengthening):

```
Given: BurgessR3Maximal(A, B, C), φ ∈ g_content(A) (i.e., G(φ) ∈ A)
Goal: φ ∈ B

Suppose φ ∉ B. Then DC({φ} ∪ B) is a proper DCS extension of B.

Claim: burgessR3(A, DC({φ} ∪ B), C) holds.
  Until direction: Take ψ ∈ DC({φ} ∪ B), γ ∈ C.
    By dc_delta_B_controlled, either:
    (a) ψ ∈ B: untl(ψ, γ) ∈ A by burgessR3(A, B, C). ✓
    (b) ∃β ∈ B with theorem (β∧φ) → ψ:
        • untl(β, γ) ∈ A (from burgessR3)
        • G(φ) ∈ A, theorem (β∧φ)→ψ, so G(β→ψ) ∈ A
          [derivation: TG on (β∧φ)→ψ gives G((β∧φ)→ψ);
           G(φ) ∧ G((β∧φ)→ψ) → G(β→ψ) by prop. under G]
        • left_mono_until_G: G(β→ψ) → untl(β,γ) → untl(ψ,γ)
        • So untl(ψ, γ) ∈ A. ✓
  Since direction: follows from burgessR_implies_burgessRSince (BX13, sorry-free).

But BurgessR3Maximal says B is maximal — no proper extension satisfies burgessR3.
Contradiction. So φ ∈ B. □
```

**By duality**: h_content(C) ⊆ B (mirror argument with left_mono_since_H).

### 3. splitting_seed_consistent Becomes Trivial

With g_content(A) ⊆ B and h_content(C) ⊆ B:

```
{β.neg} ∪ g_content(A) ∪ h_content(C)  ⊆  {β.neg} ∪ B
```

Since β ∉ B and B is a DCS, `{β.neg} ∪ B` is consistent by `dcs_neg_union_consistent` (already in codebase). Any subset of a consistent set is consistent. Done in ~5 lines.

### 4. A4a Is NOT Needed for This Step (Unanimous)

The splitting proof uses only:
- `left_mono_until_G` (new axiom, ~8 lines in Axioms.lean)
- `dcs_neg_union_consistent` (existing)
- `dc_delta_B_controlled` (existing)
- `burgessR_implies_burgessRSince` (existing, sorry-free via BX13)

A4a (`separation_until`) is already in the codebase and is sound, but it plays no role in this proof. It can be retained for potential use in Lemma 2.7 or removed to simplify the axiom system — this is a separate decision.

### 5. Actual Sorry Count Is 10 (Teammate D)

| File | Count | Lines | Description |
|------|-------|-------|-------------|
| PointInsertion.lean | 1 | 306 | `splitting_seed_consistent` (addressed by this research) |
| CounterexampleElimination.lean | 6 | 830, 868, 908, 946, 982, 1014 | c2' invariant maintenance (independent engineering) |
| CounterexampleElimination.lean | 1 | 1130 | density self-pair case (independent structural problem) |
| ChronicleToCountermodel.lean | 2 | 615, 619 | FUC/FSC coherence (independent, needs C5 guard info) |

ChronicleConstruction.lean and RRelation.lean are sorry-free. The ROADMAP's claim of 12-13 sorries is outdated.

### 6. Downstream Sorries Are Independent of Axiom Choice (Teammates C, D)

All 9 downstream sorries are independent of A4a vs left_mono_until_G:
- **6 c2' sorries**: g-function construction during point insertion (Lemma 2.6 output feeds in, but the axiom used to prove Lemma 2.6 doesn't matter)
- **1 density self-pair** (line 1130): needs `burgessR3(f(x), g(x,y), f(x))` when f(z)=f(x) — neither axiom addresses this
- **2 FUC/FSC**: need C5 with guard info, addressable by widening `EliminationResult` (Teammate D path (b))

## Synthesis

### Conflicts Resolved

**Conflict 1: Teammate B cites "right_mono_until" but needs guard strengthening**

Teammate B's conceptual argument (g_content(A) ⊆ B via maximality) is correct but cites the wrong axiom. The guard strengthening step from `untl(β, γ)` to `untl(ψ, γ)` requires changing the FIRST argument (guard), which is LEFT-mono, not RIGHT-mono. And under irreflexive semantics, BX2 (current left_mono) fails because it requires the pointwise condition. The fix is `left_mono_until_G`, which drops the pointwise condition. **Resolution**: The argument works with left_mono_until_G, confirming Teammate B's insight while using Teammate A's axiom identification.

**Conflict 2: Does the Xu path need left_mono_until_G or can existing axioms suffice?**

The assignment suggested Xu 2.3 might work with existing axioms since the key step looks like BX13. Teammate A traces the proof and shows BX13 enriches EVENTS (second arg), not GUARDS (first arg), and the Xu proof needs guard enrichment. All teammates agree: left_mono_until_G is required. **Resolution**: left_mono_until_G IS needed.

**Conflict 3: Phase 5 handoff says A4a "NOT valid" vs later work confirming validity**

Teammate C resolves: the Phase 5 handoff (01_phase5-gate-complete.md) contained an incorrect initial assessment. Later research (Report 44, Task 115 report) and the sorry-free soundness proof in the codebase confirm A4a IS valid under open-guard semantics. **Resolution**: A4a is valid; the old handoff was superseded.

### Gaps Identified

1. **Burgess Lemma 2.1 (r-relation equivalence) is not yet formalized** in the codebase. Teammate A confirms it works with existing axioms (BX13 + BX10 only). Needed if the full Xu 2.3/2.4 path is pursued, but NOT needed for the simpler g_content ⊆ B approach.

2. **The density self-pair sorry (line 1130) blocks completion regardless of axiom choice** (Teammate C). This is an independent structural problem requiring `burgessR3(f(x), g(x,y), f(x))` when only `burgessR3(f(x), g(x,y), f(y))` is available.

3. **Convention confusion between Xu U(event, guard) and BX untl(guard, event)** creates translation risk (Teammate C). Any implementation must be careful about argument order.

### Recommendations

**Primary recommendation (unanimous: A, B, D; supported by C's verification)**:

1. **Add `left_mono_until_G` and `left_mono_since_H`** to Axioms.lean (~8 lines each)
2. **Prove soundness** in Soundness.lean (~20 lines each, trivial)
3. **Prove `g_content_sub_B_of_BurgessR3Maximal`**: G(φ)∈A → φ∈B (~30-40 lines, using left_mono_until_G + dc_delta_B_controlled + maximality)
4. **Prove dual `h_content_sub_B_of_BurgessR3Maximal`** (~30-40 lines)
5. **Close `splitting_seed_consistent`**: seed ⊆ {β.neg}∪B, consistent by dcs_neg_union_consistent (~10 lines)
6. **Revise plan v29 → v30** to incorporate this approach

**Estimated effort for steps 1-5**: 4-6 hours (vs 6+ hours estimated for the A4a path with open questions).

**On A4a**: Can be retained (it's sound and adds deductive power) or removed (not needed for splitting). Recommend retaining it since it's already in the codebase and might be useful for Lemma 2.7 or other purposes.

**On Task 115**: Effectively subsumed — left_mono_until_G gets added in task 107, and the splitting proof uses the simpler g_content ⊆ B argument rather than full Xu 2.3/2.4. Task 115 can be marked [ABANDONED] with "subsumed by task 107 plan v30" or kept as a future cleanup task to optionally remove A4a and simplify BX2.

**On the broader 10-sorry roadmap** (Teammate D):
- Phase A: left_mono_until_G + g_content ⊆ B + splitting (4-6h) — this research
- Phase B: 7 c2' invariant sorries in CounterexampleElimination (8-12h)
- Phase C: 2 FUC/FSC sorries via widened EliminationResult (4-6h)
- Phase D: Final verification + cleanup (2-4h)
- Total: 18-28 hours to sorry-free `dd_countermodel_chronicle`

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary analysis | completed | high | Traced Xu 2.3 proof, confirmed left_mono_until_G needed, identified axiom (1) decomposition |
| B | Alternatives | completed | high | Discovered g_content(A) ⊆ B maximality argument (breakthrough), compared Burgess D₀ vs codebase seed |
| C | Critic | completed | medium-high | Verified 5 claims, identified r(A,⊤,D) ≠ g_content gap, flagged density self-pair blind spot |
| D | Horizons | completed | high | Reconciled sorry count (10), mapped 4-phase roadmap, recommended task 107+115 merger |

## References

- Burgess 1982: "Axioms for tense logic I: Since and Until", Section 2, Lemmas 2.3-2.6
- Xu 1988: "On some U,S-tense logics", Section 2, Lemmas 2.1-2.4, axiom (1)
- Task 107 plan v29: specs/107_chain_design_diagnostics_for_representation_theorem/plans/44_implementation-plan.md
- Task 107 handoff (Phase 5b): specs/107_chain_design_diagnostics_for_representation_theorem/handoffs/02_phase5b-seed-consistency.md
- Task 115 report: specs/115_replace_a4a_with_left_mono_until_g/reports/01_a4a-vs-left-mono.md
