# Research Report: Task #843

**Task**: Remove singleFamily_modal_backward_axiom
**Date**: 2026-02-04
**Focus**: Review unstaged implementation attempt for Phase 1 (TemporalLindenbaum.lean)

## Summary

The failed implementation attempt produced `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` (727 lines), implementing a hybrid Henkin+Zorn construction for temporally saturated MCS. Approximately 70-75% of the code is directly usable. The file has 4 `sorry`s representing genuine mathematical gaps that require proof restructuring, not just gap-filling.

## Findings

### File Structure and Proven Content

| Part | Lines | Description | Status |
|------|-------|-------------|--------|
| Part 1 | 62-123 | `temporal_witness_seed_consistent_past` | **Fully proven** |
| Part 2 | 125-148 | Chain union preservation for temporal saturation | **Fully proven** |
| Part 3 | 150-314 | Henkin infrastructure (enumeration, witness chains, packages) | **Fully proven** |
| Part 4 | 316-506 | Henkin chain/limit (monotonicity, consistency, saturation) | **2 sorries** (lines 444, 485) |
| Part 5 | 508-591 | Zorn's lemma for TemporalConsistentSupersets | **Fully proven** |
| Part 6 | 593-672 | `maximal_tcs_is_mcs` (maximality implies MCS) | **2 sorries** (lines 655, 662) |
| Part 7 | 674-726 | `temporalLindenbaumMCS` main theorem | **Fully proven** (depends on above) |

### Architectural Decision: Hybrid Henkin+Zorn

The plan v004 recommended pure Zorn (approach 1). The implementation chose a hybrid:

- **Phase A (Henkin)**: Enumerate formulas, adding temporal packages atomically. Produces a consistent, temporally-saturated base.
- **Phase B (Zorn)**: Maximize within TemporalConsistentSupersets. Produces maximality.

This hybrid is architecturally correct. Pure Zorn requires a nonempty poset of temporally-saturated consistent supersets of Gamma, but Gamma itself is not temporally saturated. The Henkin phase solves this bootstrap problem.

### Sorry Analysis

#### Sorries 1-2: Henkin Limit Temporal Saturation Base Case (lines 444, 485)

**Problem**: `henkinLimit_forward_saturated` and `henkinLimit_backward_saturated` induct on the chain index `n`. The successor case works (formulas entering via packages have their witnesses). The base case `n = 0` fails because `F(ψ) ∈ base` does not guarantee `ψ ∈ base`.

**This is a genuine mathematical gap, not just a proof structure issue.**

The core issue: the Henkin step processes formula `φ` by testing whether `S_k ∪ temporalPackage(φ)` is consistent. If `F(ψ) ∈ base` and `¬ψ` is derivable from the chain at step `encode(F(ψ))`, then the package addition fails, leaving `F(ψ)` in the limit without its witness `ψ`.

This CAN happen: `{F(ψ), ¬ψ}` is consistent in temporal logic (F(ψ) = "ψ at some future time", ¬ψ = "not ψ now").

**Fix approaches**:
1. **Restructure proof to use encoding argument**: Instead of induction on chain index, directly argue via `encode(F(ψ))`. At that step, either the package is added (done) or rejected (need separate argument).
2. **Strengthen Henkin construction**: Process formulas in dependency order, or use a different consistency argument.
3. **Use `temporal_witness_seed_consistent`**: But this requires MCS structure, not just consistency. Would need a modified lemma for non-MCS sets, or an intermediate Lindenbaum step.

**Most promising fix**: A two-phase Henkin construction:
1. First apply standard Lindenbaum to get an MCS `M ⊇ base`
2. Then use `temporal_witness_seed_consistent` (which requires MCS) to build temporal saturation from `M`
3. The witness seeds `{ψ} ∪ GContent(M)` are consistent by the proven lemma
4. Re-Lindenbaum each seed to get witness MCS

This changes the approach from "build one temporally-saturated MCS" to "build a temporally-saturated consistent set by collecting witness seeds, then Zorn-maximize". The Henkin infrastructure (Part 3) remains useful for the witness chain tracking.

**Effort**: 3-5 hours

#### Sorries 3-4: Maximality in TCS Implies MCS (lines 655, 662)

**Problem**: To show `M` is MCS, we prove: for all `φ ∉ M`, `insert φ M` is inconsistent. The proof attempts to show `insert φ M ∈ TCS(base)` (contradicting maximality). For non-temporal `φ`, insertion preserves saturation trivially. For `φ = F(ψ)`, we need `ψ ∈ insert F(ψ) M`, which requires `ψ ∈ M` — but that's not guaranteed.

**This is a genuine logical gap in the proof strategy.**

**Fix via negation completeness + duality**:
1. First prove negation completeness for non-temporal formulas and `G`/`H` formulas (straightforward — `insert G(χ) M` is trivially in TCS if consistent)
2. Then derive `F`/`P` membership via duality: `F(ψ) = ¬G(¬ψ)`
   - Either `G(¬ψ) ∈ M` (by step 1, since G-formulas don't break saturation) → then `¬F(ψ) ∈ M` → `insert F(ψ) M` is inconsistent
   - Or `insert G(¬ψ) M` is inconsistent → `M` derives `F(ψ)` → need deductive closure of `M`
3. Prove deductive closure of `M` simultaneously using the same maximality argument

**Effort**: 3-5 hours

### Other Unstaged Changes

| File | Change | Worth Keeping? |
|------|--------|----------------|
| `specs/TODO.md` | Task 863 status → [PLANNING] | **Yes** — reflects actual state |
| `specs/state.json` | Task 863 status → planning | **Yes** — matches TODO.md |
| `specs/843_.../.postflight-pending` | Deleted | **Yes** — stale postflight file |
| `Theories/Logos/latex/subfiles/01-Introduction.tex` | Formatting changes | **Unrelated** — task 863 work |

## Recommendations

### Keep: TemporalLindenbaum.lean

The file represents ~70-75% of Phase 1 work. Specifically:

**Directly usable** (~530 lines):
- Part 1: Past witness seed consistency (proven) — needed regardless of approach
- Part 2: Chain union preservation (proven) — needed for Zorn
- Part 3: Henkin infrastructure (proven) — witness chains useful for restructured construction
- Part 5: Zorn application (proven) — core of Phase B
- Part 7: Main theorem assembly (proven) — may need minor adjustments

**Needs restructuring** (~200 lines):
- Part 4: Henkin chain/limit — saturation proofs need different approach
- Part 6: `maximal_tcs_is_mcs` — needs duality-based argument

### Commit the file as-is (with sorries)

The file should be committed as work-in-progress. The sorries are well-documented, the architecture is sound, and 70-75% of the proofs are complete. This preserves progress and makes the remaining work clear.

### Next implementation attempt should focus on:

1. **Fix sorries 3-4 first** (maximality → MCS via duality) — this is independent of the Henkin issue
2. **Then fix sorries 1-2** (Henkin base case) — may require restructuring the Henkin construction
3. Both fixes benefit from reading `temporal_witness_seed_consistent` (TemporalCoherentConstruction.lean:~477) and `set_lindenbaum` (MaximalConsistent.lean) for patterns

### Estimated remaining effort for Phase 1: 7-11 hours

## References

- TemporalLindenbaum.lean (this file, unstaged)
- TemporalCoherentConstruction.lean: `temporal_witness_seed_consistent` at ~line 477
- MaximalConsistent.lean: `set_lindenbaum` (Zorn-based standard Lindenbaum)
- Plan v004: specs/843_.../plans/implementation-004.md

## Next Steps

1. Commit TemporalLindenbaum.lean as work-in-progress
2. Re-attempt Phase 1 completion focusing on the 4 sorries
3. Consider restructuring the Henkin construction if the encoding-based fix for sorries 1-2 proves difficult
