# Implementation Summary: Retire the unwired arity-4 characteristic-formula stack

- **Task**: 407 - retire the unwired arity-4 characteristic-formula stack
- **Status**: [COMPLETED]
- **Type**: lean4
- **Plan**: `specs/407_retire_unwired_arity4_char_stack/plans/01_boneyard-arity4-char-stack.md`
- **Baseline record**: `specs/407_retire_unwired_arity4_char_stack/baseline-prestate.txt`
- **Phases**: 6 of 6 completed

## What Was Done

A closed 30-declaration reference island — the losing arity-4 characteristic-formula branch — was
retired from the live tree. It was **archived, not raw-deleted**: the full text landed in
`FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Arity4CharStackK.lean` (1,862 lines) *before*
any excision, so at no commit boundary was the code or either prose record absent from the tree.

Four contiguous source blocks totalling **1,736 lines** were then cut by verified line range:

| File | Before | After | Removed |
|---|---:|---:|---:|
| `NfMultiAnchorBridge/CarrierKv.lean` | 617 | 503 | 114 |
| `NfMultiAnchorBridge/InteriorGateGeneralK.lean` | 2553 | 1426 | 1,127 |
| `NfMultiAnchorBridge/ExteriorGateAssembleK.lean` | 791 | 447 | 344 |
| `Kamp/KampPrior.lean` | 1985 | 1834 | 151 |
| **total** | **5946** | **4210** | **1,736** |

`lake build` and `lake build BimodalTest` both exited 0 on the **first attempt after the cut, with
zero fixes required** — no stray import, no stray open, no missing identifier. The island was
genuinely closed, confirming the audit.

Two prose records that document **live** declarations were then restored as condensed 7-line notes
beside the code they describe (+16 lines), giving a net live-line delta of **-1,720**.

## The Excision Set — all 30 declarations

**`NfMultiAnchorBridge/CarrierKv.lean:503-616` (2)**

1. `kvFib_body` *(private noncomputable def)*
2. `bracketEndCharKvFib`

**`NfMultiAnchorBridge/InteriorGateGeneralK.lean:1424-2550` (23)**

3. `igAllSubs`
4. `igFoldBitFib`
5. `igEpLFib`
6. `igEpRFib`
7. `igSegLFib`
8. `igSegRFib`
9. `igPtWFib`
10. `igGateFib`
11. `igSLFib`
12. `igSRFib`
13. `igCharPFib`
14. `igMkDisjunctFib`
15. `igBodyFib`
16. `igBodyFib_holds_iff`
17. `bracketEndChar_kvFib_succ_eq`
18. `bracketEndChar_kvFib_succ_holds_iff`
19. `bracketEndChar_kvFib_realize_futT`
20. `bracketEndChar_kvFib_realize_pastX`
21. `igk_sorted_realization_fib`
22. `bracketEndChar_kvFib_step_gate`
23. `bracketEndChar_kvFib_step_complete`
24. `bracketEndChar_kvFib_step_sound`
25. `bracketEndChar_kvFib_step_correct`

**`NfMultiAnchorBridge/ExteriorGateAssembleK.lean:447-790` (4)**

26. `bracketEndCharKvExtFib`
27. `bracketEndChar_kvExtFib_holds_iff`
28. `kvExtFib_gate_henv` *(private theorem)*
29. `bracketEndChar_kvExtFib_correct_prior`

**`Kamp/KampPrior.lean:1082-1232` (1)**

30. `kampPrior_site_rungKFib_gate_match`

Each of the 30 was confirmed present exactly once as a defining occurrence in the archive, and
zero times as a defining occurrence anywhere in the live tree after the cut.

## Baseline-vs-Post Comparison

Compared against `baseline-prestate.txt`, never against remembered expectation.

| Signal | Baseline (Phase 1) | Post (Phase 5) | Verdict |
|---|---|---|---|
| `lake build` | exit 0 | exit 0 | unchanged |
| `lake build BimodalTest` | exit 0 | exit 0 | unchanged |
| `completeness_discrete` axioms | `[propext, Classical.choice, Quot.sound]` | identical | unchanged, no `sorryAx` |
| `kampPriorExpressiveCompleteness` axioms | `[propext, Classical.choice, Quot.sound]` | identical | unchanged, no `sorryAx` |
| Bogus-identifier control | errors `unknownIdentifier` | errors `unknownIdentifier` | control still valid |
| Live structural sorry census | 3 | 3 | count unchanged (see note) |
| B0 Boneyard exclusion | PASS, 452 total -> 297 live | PASS, 453 total -> 297 live | green; +1 archived, live count unchanged |
| C1 build (both) | PASS | PASS | unchanged |
| C2 four flagship axiom sets | PASS | PASS, identical 4 lines | unchanged |
| C3 structural sorry | **FAIL** (3 found, expects 1) | **FAIL** (3 found, expects 1) | **pre-existing red, not caused here** |
| C4 import resolution | PASS (1105) | PASS (1105) | unchanged |
| C5 markdown module paths | PASS (1612 files) | PASS (1612 files) | unchanged |
| C6 unreachable-module manifest | PASS x3 + INFO | PASS x3 + INFO | unchanged |
| C7 live inventory | INFO 340 files (297/42), Metalogic 218 | identical | unchanged — archive is pruned |
| C8 aggregator convention | PASS | PASS | unchanged |
| C9 task-number citations | **FAIL** (4) | **FAIL** (2) | **pre-existing red, improved by another task** |
| C10 docs/latex/typst refs | PASS | PASS | unchanged |
| `readme-lint.sh` | exit 1 (1 missing, 5 broken) | exit 1 (1 missing, 5 broken) | unchanged |

**NO CHECK MOVED GREEN → RED.** That, not "all checks green", is the pass criterion: C3 and C9
were already red before this task touched anything.

### Why C3 and C9 are red, and why it is not this task

Both reds live entirely inside `FormalSystem/Metalogic/Soundness.lean` and
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean` — files this task never edited. `Soundness.lean`
is owned by two concurrent tasks and was explicitly read-only here; it appears in none of this
task's five commits (verified by `git show --name-only`).

- **C3** expects exactly one structural sorry and found three, both before and after. The two
  `Soundness.lean` sorries *moved* (`:1553`/`:1576` → `:1582`/`:1605`) because a concurrent task
  committed to that file mid-implementation; `Transfer.lean:1242` is unmoved. The count is
  identical at 3.
- **C9** went from 4 citations to 2 — an *improvement* produced by a concurrent task removing its
  own two. This task introduced no new citation: both Phase 4 notes and the Phase 6 README cite
  only declaration names and Boneyard filenames, per
  `.claude/rules/no-task-references-in-deliverables.md`.

### Live-survivor verification

All five `#check`s resolved and both excised-name `#check`s failed with `unknownIdentifier`, run
through `lake env lean` (never `lean_run_code`) with the bogus control retained to prove the probe
can actually fail. The full ten-name survivor set was additionally asserted present in the source:

`igOffFiber` (`:329`), `igFoldBit` (`:346`), `igFoldBit_realize_iff` (`:611`), `kvEFiber`,
`kvEDeepOnFiber`, `bracketEndCharKv` (`:248`), `bracketEndCharKvExt`,
`bracketEndChar_kv_correct_prior`, `kampPrior_site_rungK_gate_match`, `InteriorGateAllK`.

Both `open private k1v_*` lines in `InteriorGateGeneralK.lean` and the one in
`ExteriorGateAssembleK.lean` survive, and `InteriorGateGeneralK.lean` still ends with the `end`
closing its `noncomputable section` followed by the namespace `end`.

## Key Risk That Was Avoided

`igOffFiber` shares the `Fib` suffix with the island but is **LIVE**, with three arity-1 consumers.
The same is true of the `kvEFiber*` and `kvE_deepOnFiber_*` families. Any `*Fib` grep-and-delete
would have broken the build. Deletion was therefore performed **by verified line block only**, with
every boundary re-confirmed by content-string match immediately before cutting via an
assert-or-abort script. Zero drift was found.

## Plan Deviations

- **Phase 1, sorry census** *(altered)*: the plan predicted 5 live sorries at
  `Soundness.lean:1461,1472,1486,1509` + `Transfer.lean:1242`. The measured pre-state was **3**
  (`Soundness.lean:1553,1576`, `Transfer.lean:1242`). The plan's figure was stale — concurrent
  `Soundness.lean` work had both moved and reduced them. The measured value was recorded as the
  baseline of record and used for the Phase 5 comparison.
- **Phase 1, invariant checks** *(altered)*: the plan and delegation brief name **C3** as the only
  pre-existing red. A second pre-existing red, **C9** (4 task-number citations, all in
  `Soundness.lean`), was found and recorded. Phase 5's criterion was widened to cover both.
- **Phase 1** *(added)*: a `readme-lint.sh` baseline (exit 1) was captured, which the plan did not
  ask for but Phase 6's "exits as it did in the Phase 1 baseline" criterion requires.
- **Phase 5, C7 line delta** *(altered)*: the plan asks to confirm "C7's informational live line
  count dropped by ~1,736". C7 reports live **file** counts, not line counts, so the line delta was
  measured directly instead: 5946 → 4226 across the four files (−1,736 deleted, +16 re-added as the
  Phase 4 notes, net −1,720). C7's file counts were confirmed unchanged at 340 (297/42), which is
  the property the archive-under-`Boneyard/` placement was supposed to guarantee.
- **Phase 2** *(added)*: a `#exit` guard was added after the archive's module docstring, matching
  `Boneyard/InteriorHrealSupplyK.lean`'s convention, so the file cannot compile even if something
  ever imports it. An explicit "What is NOT here" section was also added naming the live
  `Fib`-suffixed non-members.

No plan step was skipped, and no step was blocked.

## Artifacts

- `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Arity4CharStackK.lean` (new, 1,862 lines)
- `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` (inventory + retirement narrative)
- `FormalSystem/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierKv.lean`
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean`
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean`
- `specs/407_retire_unwired_arity4_char_stack/baseline-prestate.txt`
- `specs/407_retire_unwired_arity4_char_stack/summaries/01_boneyard-arity4-char-stack-summary.md`
