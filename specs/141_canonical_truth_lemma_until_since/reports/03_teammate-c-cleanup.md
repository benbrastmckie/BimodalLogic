# Cleanup Audit: Task 141 WeakCanonical Files

**Date**: 2026-05-14
**Scope**: TruthLemma.lean, ReflexiveCanonical.lean, WeakCanonical.lean, FrameProperties.lean, Boneyard assessment
**Priority**: Correctness of metadata (inaccurate header comments are the main cruft)

---

## File-by-File Audit

### 1. TruthLemma.lean

**Path**: `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean`
**Size**: 572 lines
**Actual sorry count**: 6 `sorry` tactic invocations (lines 426, 443, 479, 494, 548, 563)
**grep "sorry" count**: 20 hits (14 are in comments/docstrings — all legitimate documentation)

#### Sorry inventory

| Line | Theorem | Nature |
|------|---------|--------|
| 426 | `until_forward_mcs` | Intermediate guard condition — documented, correct rationale |
| 443 | `until_backward_mcs` | Full body sorry — documented, correct rationale |
| 479 | `since_forward_mcs` | Intermediate guard condition — documented, correct rationale |
| 494 | `since_backward_mcs` | Full body sorry — documented, correct rationale |
| 548 | `truth_lemma` (untl branch, backward dir) | Calls `until_backward_mcs` variant — documented |
| 563 | `truth_lemma` (snce branch, backward dir) | Calls `since_backward_mcs` variant — documented |

**Verdict**: All 6 sorries are the legitimate research target for Tasks 141/142. None are cruft.

#### Inaccurate header comment — NEEDS FIX

The module header (lines 22-33) has two stale claims:

1. **Line 27**: `"- box backward: needs box-conjunction lemma (modal_K pattern)"`
   - `box_backward_mcs` (line 133) is explicitly labelled "sorry-free" in its own docstring and is fully proved.
   - The header has not been updated since the proof was completed.
   - **Action**: Remove `box backward` from the documented-sorries list in the header.

2. **Line 28**: `"- H forward, H backward: needs g_content/h_content duality lemma"`
   - `H_forward_mcs` (line 315) is fully proved sorry-free. Its docstring says "sorry-free".
   - `H_backward_mcs` (line 329) is also fully proved sorry-free (complete Lindenbaum argument, no sorry).
   - The header's "Documented sorries" list predates these completions.
   - **Action**: Remove `H forward, H backward` from the documented-sorries list in the header.

3. **Line 503** (`truth_lemma` docstring): `"Documented sorries: box backward, H forward/backward, Until/Since (all directions)."`
   - Box backward and H forward/backward are proved. Only Until/Since remain.
   - **Action**: Update to: `"Documented sorries: Until/Since (forward/backward)."` and add a line confirming box, G, H are all sorry-free.

#### Ghost reference — MISLEADING

Lines 392, 424, 436 reference `DovetailingChain.lean`:

- `"requires infrastructure from DovetailingChain.lean or similar, not yet ported to ReflCanDomain"` (line 392)
- `"from DovetailingChain.lean has not been ported to the ReflCanDomain setting"` (line 424)
- `"infrastructure from DovetailingChain.lean or BXCanonical/Filtration/DefectChain.lean"` (line 436)

`DovetailingChain.lean` does not exist anywhere in the active codebase. It is referenced in
`Bundle/TemporalContent.lean` (lines 32, 49) and `Bundle/WitnessSeed.lean` (line 14) as a
historical file from which code was extracted. The closest extant related files are:
- `BXCanonical/Filtration/DefectChain.lean` (exists, active)
- `BXCanonical/CanonicalChain.lean` (exists, active)
- `Boneyard/StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean` (archived, contains dovetailing concept)

**Action**: Replace phantom `DovetailingChain.lean` references with the actual extant files
(`BXCanonical/CanonicalChain.lean`, `BXCanonical/Filtration/DefectChain.lean`) in the
until/since docstrings. The conceptual claim (infrastructure not yet ported) remains valid —
only the specific filename needs correction.

#### Dead code check

- All proved theorems (atom, bot, imp, box, G, H) are used by `truth_lemma`. No orphans.
- `until_backward_mcs`, `since_backward_mcs`: Their docstrings note "Path A note: NOT needed
  for the chronicle+Reynolds pipeline." These are not called from `truth_lemma` — the backward
  sorry is inlined directly in the `truth_lemma` untl/snce branches. These two standalone
  theorems are research scaffolding for the sorry-free completeness path. Keeping them is
  appropriate (not dead code — they define the target lemma shapes).

#### `reflCanTruth` definition

Well-structured. The definition correctly encodes open-guard Until/Since semantics consistent
with Task 141's goals. No issues.

---

### 2. ReflexiveCanonical.lean

**Path**: `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean`
**Size**: 485 lines
**Actual sorry count**: 1 (line 144, `reflCanR_linear`)

#### `reflCanR_linear` — Documented Sorry

The sorry at line 144 is the linearity theorem for the temporal order. The docstring is
accurate and detailed. The statement is correct and needed for Reynolds Theorem 15.
Blocker: `forward_temporal_witness` not yet ported from `BXCanonical/CanonicalChain.lean`.

**Action**: The comment at line 136 says:
`"-- Port 'forward_temporal_witness' from BXCanonical/CanonicalChain.lean"`
This reference is correct — `BXCanonical/CanonicalChain.lean` exists. No phantom reference.

**Verdict**: Keep as-is. The sorry and its documentation are accurate.

#### Potentially unused cluster: `reflCanR`, `g_w_content`, `h_w_content`

Cross-reference search shows `reflCanR`, `g_w_content`, `h_w_content`,
`reflCanR_refl`, `reflCanR_trans`, `tempR_fwd_imp_reflCanR`,
`tempR_bwd_imp_reflCanR_bwd`, `canS5R_refl`, `canS5R_symm`, `canS5R_trans`,
`reflCanV`, `next_top_in_box_class` are defined in this file but have **zero usage
outside ReflexiveCanonical.lean** in the active codebase.

However, these are not dead code — they are structural components of the canonical model
that will be needed once the full Reynolds pipeline is activated. The module header
accurately describes their role. They are **future-facing infrastructure**, not orphaned
results. Recommend keeping in place.

#### Model construction clarity

`ReflCanDomain`, `tempR_fwd`, `tempR_bwd`, `canS5R` are all used downstream in
`TruthLemma.lean` and `ChronicleExtraction.lean`. Core infrastructure is sound.

No dead code to remove. No redundancy with `FrameProperties.lean` — the two files
have distinct concerns (model construction vs. axiom-instance lemmas).

---

### 3. WeakCanonical.lean

**Path**: `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean`
**Size**: 57 lines (module header + imports only)
**Actual sorry count**: 0 code sorries (the single "sorry" hit from grep is in a doc comment
describing the `succ_cofinal` sorry in the chronicle construction — accurate, not a code sorry)

**Organization**: Imports all 9 WeakCanonical submodules in logical order matching the
documented architecture. No stale imports detected.

**Status comment accuracy**: "Currently delegates to the chronicle construction as interim
fallback" (line 47) — accurate and appropriately honest about the Reynolds pipeline status.

**Action**: None required. File is clean.

---

### 4. FrameProperties.lean

**Path**: `Theories/Bimodal/Metalogic/WeakCanonical/FrameProperties.lean`
**Size**: 47 lines
**Actual sorry count**: 0

**Proved theorems**: `z1_in_frame`, `prior_UZ_in_frame`, `prior_SZ_in_frame`,
`serial_future_in_frame`, `serial_past_in_frame` — five simple one-liners using
`theorem_in_mcs` to package axiom instances as frame facts.

**Usage**: Cross-reference search shows all five theorems have **zero downstream usage**
in active files outside FrameProperties.lean itself. They are not called by any other
WeakCanonical file, nor by ChronicleExtraction, NEquivalence, OrderedSum, Transfer,
or IntegerModel.

**Assessment**: These are valid, correct lemmas establishing that the canonical frame
satisfies the logic's axioms at the MCS level. They are likely intended as components
for a future "frame validation" step in the completeness proof (analogous to
`FrameConditions/` in BXCanonical). They are not dead code — they are unused
future-facing scaffolding. However, unlike the `reflCanR` cluster which has a clear
role in the Reynolds pipeline, these lemmas are not on any current implementation path
in Tasks 141/142.

**No overlap with ReflexiveCanonical.lean**: The two files have completely distinct
content (model construction vs. axiom-instance packaging). No redundancy.

**Action**: Keep. They are correct, inert (no cost to lake build), and may be needed
by a future FrameConditions verification step.

---

## Ghost Reference Summary

| Phantom Reference | Location | Verdict |
|-------------------|----------|---------|
| `DovetailingChain.lean` | TruthLemma.lean lines 392, 424, 436 | Phantom — does not exist. Fix to reference `BXCanonical/CanonicalChain.lean` or `BXCanonical/Filtration/DefectChain.lean` |
| `Bundle/CanonicalFrame.lean` | ReflexiveCanonical.lean line 131 | EXISTS at `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` — not phantom |
| `BXCanonical/CanonicalChain.lean` | ReflexiveCanonical.lean line 131, 136 | EXISTS — not phantom |
| `BXCanonical/Filtration/DefectChain.lean` | TruthLemma.lean line 436 | EXISTS — not phantom |

Only `DovetailingChain.lean` is a ghost reference.

---

## Cleanup Actions

### Priority 1 — Fix (inaccurate metadata, actively misleading)

**Action A: Fix TruthLemma.lean header "Status" section (lines 22-33)**

The "Documented sorries" list must be corrected. Currently says:
```
- box backward: needs box-conjunction lemma (modal_K pattern)
- H forward, H backward: needs g_content/h_content duality lemma
- Until forward/backward: ...
- Since forward/backward: ...
```
Should say:
```
- Until forward/backward: eventuality resolution / counter-witness chain
- Since forward/backward: symmetric to Until
```
And the "Proved" list should be expanded:
```
### Proved (sorry-free)
- atom, bot, imp (6 lemmas)
- box forward, box backward (2 lemmas) — uses generalized_modal_k + Lindenbaum
- G forward, G backward (2 lemmas) — uses g_content_closed_derivation
- H forward, H backward (2 lemmas) — uses h_content_closed_derivation + Lindenbaum
```

**Action B: Fix TruthLemma.lean `truth_lemma` docstring (line 503)**

Currently: `"Documented sorries: box backward, H forward/backward, Until/Since (all directions)."`
Should be: `"Documented sorries: Until/Since (all directions — forward and backward)."`

**Action C: Fix DovetailingChain.lean ghost references (TruthLemma.lean lines 392, 424, 436)**

Replace `DovetailingChain.lean` with `BXCanonical/CanonicalChain.lean` or
`BXCanonical/Filtration/DefectChain.lean` as appropriate to the context. The conceptual
claim ("this infrastructure has not been ported to ReflCanDomain") remains valid and
should be preserved.

### Priority 2 — Keep (no action required)

- `reflCanR_linear` sorry in ReflexiveCanonical.lean: accurately documented, correct blocker.
- `reflCanR`, `g_w_content`, `h_w_content` cluster: future-facing, not dead.
- FrameProperties.lean theorems: correct, inert, potentially needed later.
- WeakCanonical.lean: clean, no action needed.
- All 6 sorries in TruthLemma.lean: legitimate open obligations for Tasks 141/142.

---

## Boneyard Assessment

### ChainCompleteness/ — Keep as-is

9 files, 2,216 lines. Archived in task #93. These represent the earlier "SuccChain" approach,
superseded by the current ReflexiveCanonical/Reynolds path. They contain useful chain
construction patterns (MCSWitnessChain, ResolvingChain, TargetedChain) that could provide
inspiration for the Until/Since intermediate guard condition proof — exactly the blocker in
Task 141. Should stay in the Boneyard (not restored to active), but are worth consulting.

### StrictSemanticsLegacy/ — Keep as-is

9 files, 14,330 lines. Archived in task #94. `UltrafilterChain.lean` contains the dovetailing
concept (lines 3035, 3067) which is the spiritual ancestor of the `DovetailingChain.lean`
ghost reference. Confirms that "DovetailingChain" was always a conceptual name for the
dovetailing strategy, never a named file. Keep in Boneyard.

### Should any current WeakCanonical code move TO the Boneyard?

No. All current WeakCanonical files are on the active Reynolds pipeline path. Moving any of
them to the Boneyard would break the WeakCanonical.lean import chain. The only candidate for
eventual archival is `reflCanR_linear` if linearity is eventually proved via a different route
and this approach is abandoned — but that is speculative and premature.

---

## Stale TODO Markers

No `TODO:`, `FIXME:`, `FIX:`, `NOTE:`, or `QUESTION:` tag markers were found in any of the
four audited files. All comment annotations use the prose docstring style (not tag style).

---

## Summary

| File | Sorries | Action Needed | Priority |
|------|---------|---------------|----------|
| TruthLemma.lean | 6 code | Fix header (stale claims + ghost ref) | High |
| ReflexiveCanonical.lean | 1 code | None | — |
| WeakCanonical.lean | 0 | None | — |
| FrameProperties.lean | 0 | None | — |

**Confidence**: High. The sorry counts are confirmed by targeted grep. The ghost reference
`DovetailingChain.lean` is confirmed non-existent by `find`. The stale header claims
(box backward, H forward/backward listed as sorry'd when proved) are confirmed by reading
the theorem bodies and their individual docstrings.

**The only real cleanup work**: Three comment fixes in TruthLemma.lean (header status section,
truth_lemma docstring, DovetailingChain ghost references). No code deletion, no archival moves.
