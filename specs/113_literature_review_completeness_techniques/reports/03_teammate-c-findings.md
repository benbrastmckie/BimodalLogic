# Teammate C Findings: Sequencing Analysis — Refactor vs. Task 107

**Task**: #113 (Round 2, Teammate C)
**Date**: 2026-04-27
**Subject**: Evaluate three sequencing options for the open guard refactor relative to task 107 plan v21

---

## Evidence Base

Files read:
- `specs/107_.../plans/34_implementation-plan.md` — Plan v21 (all 5 phases, including the NOTE at Phase 4.1 about BX9)
- `specs/113_.../reports/02_until-since-guard-semantics.md` — Guard semantics blast radius analysis
- Live source audit of `Chronicle/` (RRelation.lean, PointInsertion.lean, CounterexampleElimination.lean, ChronicleConstruction.lean, ChronicleToCountermodel.lean)

Current state of `irr_until` branch:
- Phase 1 of plan v21 is [PARTIAL]: `burgess_lemma_2_6_content` and helpers have been added to PointInsertion.lean (lines ~743–958), with 4 sorry sites remaining in that theorem block (lines 773, 786, 825, 838)
- Phases 2–5 are [NOT STARTED]: all 7 c2' sorry sites in CounterexampleElimination.lean and 2 FUC sorry sites in ChronicleToCountermodel.lean are open
- Total open sorry sites: 9 (4 in Phase 1 + 7 in Phase 2 + 2 in Phase 4) — Phase 1 is not done yet

---

## File Overlap Map

The refactor touches these files in the Chronicle/ directory:

| File | Refactor changes | Plan v21 changes | Overlap? |
|------|-----------------|-----------------|---------|
| `RRelation.lean` | Delete `until_guard_in_mcs` (line 86–91), `since_guard_in_mcs` (99–104); replace `until_guard_in_mcs` call at line 1193; replace `Axiom.until_guard` at 1236, `Axiom.since_guard` at 1260 | Phase 1.3 may add helper lemmas here (~50 lines) | YES — both touch this file |
| `PointInsertion.lean` | Delete `until_elim_mcs` (167–178); replace call at line 277; replace `until_guard_in_mcs` call at line 673 | Phase 1: add `burgess_lemma_2_6_content` (~250 lines) — currently partially done | YES — both touch this file |
| `CounterexampleElimination.lean` | None — zero guard axiom calls in this file (confirmed by grep) | Phase 2: major (~400 lines changed) | NO — no overlap |
| `ChronicleConstruction.lean` | None — zero guard axiom calls in this file | Phase 3: add g-immutability lemmas (~75 lines); Phase 4.1: add guard lemma (~60 lines) | NO for refactor; Phase 4.1 uses guard indirectly via the BX9 step |
| `ChronicleToCountermodel.lean` | None — zero guard axiom calls in this file | Phase 4.2/4.3: close 2 FUC sorry sites | NO — no overlap |
| `ChronicleTypes.lean` | Delete BX9 calls at lines 554, 573 (used in `burgessRSet` properties) | Not touched | Partial — refactor touches this, v21 does not |

Outside Chronicle/, the refactor also touches:
- `Axioms.lean`: remove 4 constructors (until_guard, since_guard, until_elim, since_elim)
- `SoundnessLemmas.lean`: ~12 match arms removed/updated
- `Soundness.lean`: ~12 match arms removed/updated
- `Frame.lean`: 2 calls (lines 690, 717)
- `Quasimodel/Construction.lean`: 2 calls (lines 118, 169)
- `Filtration/DefectChain.lean`: 2 calls (lines 65, 112)
- `Theorems/TemporalDerived.lean`: ~12 calls
- `Boneyard/QuasimodelOracle/OracleStep.lean`: 1 call

Plan v21 touches NONE of these files outside Chronicle/.

---

## Option A: Refactor First — Pause 107 After Phase 1 Completes, Do Refactor, Resume

### Best stopping point

After Phase 1 is complete (not mid-Phase 1). Phase 1 adds `burgess_lemma_2_6_content` to PointInsertion.lean and optional helpers to RRelation.lean. Once Phase 1 is sorry-free, it is self-contained and additive — no existing code is modified. This makes it a clean branch point.

Stopping mid-Phase 1 (current state) is possible but introduces risk: the partial Phase 1 work in PointInsertion.lean modifies the same region the refactor will also touch. Starting the refactor now (before Phase 1 is done) would mean context-switching in an already-in-progress theorem proof, which risks confusion and errors.

**Recommended stopping point: after Phase 1 is complete and `lake build` passes.**

### Would Phases 1–2 need rework after the refactor?

**Phase 1 (Lemma 2.6)**: The new `burgess_lemma_2_6_content` theorem and its helpers use BX4, BX5, BX6, BX7. None of these are removed under the refactor. The consistency argument in Phase 1 does NOT use `until_guard`, `since_guard`, `until_elim`, or `since_elim`. Phase 1 proof is entirely guard-independent.

However, the refactor WILL delete `until_elim_mcs` (PointInsertion.lean:167–178), which is currently used in Phase 1's existing code at line 277 (`lemma_2_7_guard`). After the refactor, `lemma_2_7_guard` must be rewritten: instead of calling `until_elim_mcs`, it derives `ξ ∈ A` through the r-relation. This is a 5–10 line change, not a rewrite of the Lemma 2.6 block itself. The `burgess_lemma_2_6_content` block (starting at ~line 743) does not call `until_elim_mcs` — it uses different infrastructure.

The refactor also deletes `until_guard_in_mcs` (RRelation.lean:86–91), which is called at PointInsertion.lean:673 (inside `BurgessR3Maximal_maximality_combined`). Plan v21 does not modify this theorem — it is existing sorry-free code. After the refactor, that proof step must use a different contradiction argument (MCS consistency directly, without extracting `bot` via the guard axiom). This is a 5–10 line change to existing code, independent of anything plan v21 adds.

**Phase 2 (c2' sorry sites)**: CounterexampleElimination.lean has zero guard axiom calls (confirmed by grep). Phase 2 is completely guard-independent. No rework needed after the refactor.

**Summary for Option A rework**: If the refactor happens after Phase 1 completes, the additional rework required to resume plan v21 is:
1. Rewrite `lemma_2_7_guard` at PointInsertion.lean:272–279 (~10 lines, using r-relation instead of `until_elim_mcs`)
2. Rewrite the contradiction step at PointInsertion.lean:673 in `BurgessR3Maximal_maximality_combined` (~10 lines, existing code not added by Phase 1)
3. Update any RRelation.lean helper lemmas added in Phase 1.3 that happen to reference `until_guard_in_mcs` (check at Phase 1 completion — likely zero, since Lemma 2.6 uses BurgessR3Maximal not guard extraction)

Estimated rework: 1–2 hours. Not zero, but genuinely small.

### Would Phase 4 be easier after the refactor?

Yes. Phase 4.1's single BX9 dependency (the step "by BX9 (until_elim), xi or eta in f(t)") would already be resolved under open guard. The replacement derivation — using Xu Lemma 2.3(i) to extract the guard through the r-relation rather than at the current point — would be the *only* way to prove this step, so there would be no ambiguity or temptation to use the invalid BX9 shortcut.

If 107 finishes before the refactor, this step uses BX9 under the half-closed semantics. When the refactor later arrives, that one step must be rewritten. The refactor-first path eliminates this future rework: Phase 4.1 is written correctly from the start.

**Estimated effort for Option A**: Phase 1 completion (~10 hrs remaining) + refactor (~30 hrs) + Plan v21 Phases 2–5 with 1–2 hrs rework adjustment (~35 hrs) = ~75–77 hrs total.

---

## Option B: Finish 107 First, Then Refactor

### How much Phase 4 work gets wasted?

Exactly one sub-step of Phase 4.1 uses BX9: "from U(xi, eta) in f(t), by BX9 (until_elim), xi or eta in f(t)." This is one `rcases until_elim_mcs ...` call (pattern matching on a disjunction). The surrounding 95% of Phase 4.1 — the C3 interval containment argument, limit_g_contains_finite_stage, BurgessR3Maximal construction evidence, Cantor isomorphism transfer — is entirely guard-independent.

When the refactor comes, this one step in Phase 4.1 becomes invalid. It must be replaced with a derivation through the BurgessR3Maximal r-relation. The replacement is well-understood (Xu Lemma 2.3(i), documented in report 02). Estimated replacement cost: 2–3 hours.

No other completed phase work gets wasted. Phases 1–3 and Phase 5 are entirely guard-independent.

### Merge conflict risk

Both plan v21 and the refactor touch RRelation.lean and PointInsertion.lean. If plan v21 runs to completion on the `irr_until` branch and then the refactor is done on the same branch, there is no merge conflict per se — it is sequential editing, not a branch merge. But if the refactor is done on a NEW branch off `irr_until` (post-v21 completion), the rebasing or merging is clean since they touch non-overlapping lines: plan v21 adds 250+ lines at the end of PointInsertion.lean and the refactor modifies lines 86–278, 673, and 1193–1260 (all earlier sections and the existing `BurgessR3Maximal_maximality_combined` theorem). There is no line-level conflict.

**Estimated effort for Option B**: Plan v21 Phases 1–5 (~45 hrs remaining) + refactor (~30 hrs) + 2–3 hrs rework for Phase 4.1 BX9 replacement = ~77–78 hrs total.

Essentially the same total effort as Option A. The only structural difference is that Option B leaves one known future rework item (the BX9 step in Phase 4.1) while Option A avoids it.

---

## Option C: Parallel Execution on Separate Branches

### File overlap assessment

Both the refactor and plan v21 would be modifying RRelation.lean and PointInsertion.lean simultaneously on different branches. The changes are:

- Refactor in RRelation.lean: deletes lines 86–104 (guard theorems), modifies lines 1176–1260 (replaces guard-based derivations)
- Plan v21 Phase 1.3 in RRelation.lean: adds ~50 new lines (BurgessR3Maximal helper lemmas, likely at the end of the file)

- Refactor in PointInsertion.lean: deletes lines 167–178 (until_elim_mcs), modifies lines 272–279 (lemma_2_7_guard), modifies line 673
- Plan v21 Phase 1 in PointInsertion.lean: adds ~250 lines at the bottom (burgess_lemma_2_6_content block, currently lines ~743–958)

The plan v21 additions are all at the END of the file (new theorems appended). The refactor modifications are in the MIDDLE of the file (existing theorem deletions/replacements in the first 700 lines). These changes do not overlap at the line level, but a merge of the two branches will require manual resolution of the diff context if the file structure shifts.

More seriously: `until_elim_mcs` at PointInsertion.lean:167 is called inside Phase 1's existing sorry-free code at line 277 (`lemma_2_7_guard`). If the refactor deletes `until_elim_mcs` on its branch, and plan v21's Phase 1 depends on `lemma_2_7_guard` (which calls `until_elim_mcs`) on its branch, merging will create a build error — `lemma_2_7_guard`'s proof will reference a deleted theorem. The merge is not clean.

### Is parallel execution practical?

Technically possible but not recommended. The merge will require:
1. Rewriting `lemma_2_7_guard` to not use `until_elim_mcs` (the refactor deletes it)
2. Resolving which version of RRelation.lean lines 86–104 to keep (none — both branches delete/replace them)
3. Verifying that plan v21's new Lemma 2.6 block in PointInsertion.lean still builds after the refactor changes the file's earlier sections

This is manageable but adds a non-trivial merge coordination step. It requires one developer (or one session) to own the merge, understand both sets of changes, and verify the combined build. Given that one developer is working on this project, parallel branches offer no productivity gain — the merge serializes the work anyway.

**Estimated effort for Option C**: Plan v21 (~45 hrs) + refactor (~30 hrs) running in parallel, but merge resolution adds ~5 hrs and requires completing both sets of changes before the combined build is verified. Net: ~80 hrs with higher coordination overhead and no time savings for a solo developer.

---

## Comparative Summary

| | Option A: Refactor First (after Ph.1) | Option B: Finish 107 First | Option C: Parallel |
|---|---|---|---|
| Total effort | ~75–77 hrs | ~77–78 hrs | ~80 hrs |
| Phase 4.1 BX9 step | Written correctly from the start | 1 step needs replacement post-refactor (+2–3 hrs) | Must be resolved at merge |
| Wasted work | ~1–2 hrs rework (lemma_2_7_guard, BurgessR3Maximal_maximality_combined) | ~2–3 hrs rework (Phase 4.1 BX9 step) | ~5 hrs merge overhead |
| Risk | Low — Phase 1 is additive; refactor well-scoped | Low — sequential, no merge | Medium — parallel mod of shared files |
| Clean stopping point | After Phase 1 completes (requires ~10 hrs first) | After Phase 5 completes | N/A |
| Aligns with paper from start | Yes | No (BX9 used under half-closed semantics) | Mixed |

---

## Recommendation

**Option A (refactor first, pausing after Phase 1 completes) is very slightly preferred, but the difference is negligible.**

The total effort estimates are essentially equal (~75–78 hrs across A and B). The real distinctions are:

1. **Option A writes Phase 4.1 correctly the first time.** The BX9 step is the only interaction point between the refactor and plan v21. Doing the refactor first means this step is simply never written under the wrong semantics — no future rework needed.

2. **Option A requires completing Phase 1 first (~10 hrs), then pausing.** If Phase 1 proves difficult (the seed consistency argument is the highest-risk step in the entire plan), deferring the refactor until Phase 1 is done is responsible. If Phase 1 goes smoothly, the pause is a natural milestone.

3. **Option B's 2–3 hr rework is well-understood and low-risk.** The BX9 step replacement is documented in report 02 (Xu Lemma 2.3(i) via the r-relation). It is not a research problem. If the user wants to finish 107 without interruption, Option B is entirely sound — the rework is minor and the risk is low.

4. **Option C is not recommended** for a solo developer. No time savings, added merge risk.

**The user's explicit preference to evaluate Option A is well-founded.** The math supports it. The best stopping point is unambiguously after Phase 1 completes (all 4 Phase 1 sorry sites closed, `lake build` passes). Stopping mid-Phase 1 (current state) is not recommended — finish the in-progress work first, then context-switch to the refactor.

**If the user wants the simplest path**: finish Phase 1, then do the refactor, then resume with Phase 2. Phase 2–5 are entirely guard-independent (confirmed by grep — zero guard axiom calls in CounterexampleElimination.lean, ChronicleConstruction.lean, and ChronicleToCountermodel.lean). The only interaction point is the Phase 4.1 BX9 step, which will already be handled correctly by virtue of BX9 being removed before Phase 4 is written.
