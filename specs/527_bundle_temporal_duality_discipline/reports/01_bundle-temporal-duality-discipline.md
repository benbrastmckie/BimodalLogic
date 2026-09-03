# Bundle Temporal Duality Discipline — Research Report

**Task**: 527 — WAVE 4 (canonical-model infrastructure). Replace textual future/past mirroring in
`Metalogic/Bundle/` with derived duals, bundle the truth lemma's coherence hypotheses, and put the
limit-MCS construction on Mathlib's `Filter` API.
**Date**: 2026-09-03
**Sources**: `specs/reviews/2026-09-01-lean-engineering/F-canonical.md` findings F-04, F-05, F-08,
F-14, F-17, F-20 (High H6, utility U12); live tree at `653b002c2` (post-task-520,
post-task-526).
**Dependencies**: Task 520 (COMPLETED — `520_bundle_retirement_and_cycle_breaking`), Task 526
(COMPLETED — `526_core_mcs_api_consolidation`). Both landed **after** the 2026-09-01 review that
produced F-canonical.md, so the review's anchors are stale in specific, checkable ways. This
report re-measures everything against the current tree rather than trusting the review or the
task description's "MEASURED STATE" paragraph verbatim.

---

## 1. Headline

| Finding | Verdict against current tree |
|---|---|
| F-04 (`multiFamTaskFrame` re-discharge) | **STILL LIVE, UNCHANGED.** `ReynoldsBridge.lean:769-803`. |
| F-05 (truth lemma unused hypothesis + 7 coherence predicates) | **STILL LIVE, SCOPE LARGER THAN STATED.** Only **one** live consumer now (not two — the second, `fc_theorem_true_in_bundle_flow_model`, no longer exists in the tree). The "four dead predicates" figure understates the dead set; see §3. |
| F-08 (four ~85-line witness-seed proofs) | **STILL LIVE, UNCHANGED.** `WitnessSeed.lean:154-537`. `UntilWitnessSeed` still a byte-for-byte duplicate of `ForwardTemporalWitnessSeed`. |
| F-14 (30+ textual mirror pairs) | **SCOPE REDUCED BY TASK 520.** 4 of the ~29 pairs the review lists (`SuccRelation.lean`, `CanonicalTaskRelation.lean`) no longer exist in the live tree — both files were archived wholesale to `Boneyard/BundleDeadHalf/` by task 520, not fixed. ~23 pairs remain live, across `WitnessSeed.lean`, `TemporalContent.lean`, `TemporalCoherence.lean`, `LimitMCS.lean`, `LimitMCSCoherence.lean`. |
| F-17 (`LimitMCS` double-proves finite intersection) | **STILL LIVE, ASYMMETRIC.** The Filter-API path (`limitFilterBelow`/`limitMCSBelow`) exists only for the **Below** side; there is no `limitFilterAbove`/`limitMCSAbove`. A third construction (`limitMCSLindenbaum`, Zorn-based) is also present and is dead outside its own file. See §4. |
| F-20 (`fc`-before-`D` parameter order) | **STILL LIVE.** 127 `FMCS (fc := …)` / `BFMCS (fc := …)` sites (review said ~130 — close, the small drift is task 526 edits). |
| F-09 / F-15 (cited in the task's Phase A/B prose as context, not WORK items) | **ALREADY DISCHARGED by task 526**, phases 4 and 5 respectively. `bot_not_in_mcs` has one canonical `Core/MCSProperties.lean` copy; `right_mono_until … Formula.top` inlining is gone from `Bundle/` (0 occurrences), replaced by `someFuture_mono`/`somePast_mono`. Not part of 527's remaining work, but the plan should not re-derive them. |

**Net effect on the acceptance criterion**: the task description's "at least 800 lines" reduction
target was set against the review's pre-520 baseline, which included `SuccRelation.lean` (553
live lines then) and `CanonicalTaskRelation.lean` (759+ live lines then) as part of the ~1,200-1,400
"second half of a mirror" estimate. Those lines are already gone — deleted by relocation, not by
the duality technique this task is meant to introduce. The current live base for this task's
in-scope files (`WitnessSeed.lean` + `TemporalContent.lean` + `TemporalCoherence.lean` +
`LimitMCS.lean` + `LimitMCSCoherence.lean` + `Algebraic/FlowFrame.lean`) is **4,035 lines**, not
the ~6,870 the review measured. See §6 for a re-baselined per-finding estimate; the honest total
is **550-750 lines**, and the plan/acceptance criterion should be revised downward rather than
carried forward unchanged. This is a scope-correctness issue, not a reason to skip work — every
recommendation below is still worth doing on its own merits.

---

## 2. What changed since the review (task 520, task 526)

- **Task 520** broke the `Core -> Bundle` import cycle by relocating 29 pure-syntax
  `iterF`/`iterP` declarations out of `CanonicalTaskRelation.lean` into a new
  `Syntax/SubformulaClosure/IteratedTemporal.lean`, then archived the six modules left with no
  live importer — `CanonicalTaskRelation.lean` (759 lines as archived), `SuccRelation.lean` (553),
  `CanonicalFrame.lean` (312), `Construction.lean` (253), `UntilSinceCoherence.lean` (46),
  `ModalSaturation.lean` (337) — to `FormalSystem/Boneyard/BundleDeadHalf/`, with a README
  explaining each retirement. `Bundle/` went from 15 modules / 6,073 lines to 9 modules / 3,299
  lines. **Consequence for this task**: every F-14 anchor in `SuccRelation.lean` and
  `CanonicalTaskRelation.lean` (6 of the ~29 pairs) is gone; do not plan work against them. The
  seven live helpers `ModalSaturation.lean` carried (including `gDneTheorem`/`hDneTheorem`, moved
  from `TemporalCoherence.lean`, and `pastTempA`, moved from `WitnessSeed.lean`) now live in
  `Theorems/ModalDerived.lean` and `Core/MCSProperties.lean` — F-16 is fully discharged and is not
  part of this task's scope either.
- **Task 526** added `Core/MCSProperties.lean` declarations that eliminate two things the review's
  narrative (not its WORK list) mentions in passing: `SetMaximalConsistent.bot_not_mem` (F-09,
  fully discharged, 0 live `bot_not_in_mcs` occurrences) and `someFuture_mono`/`somePast_mono`
  (F-15, fully discharged in `Bundle/`, 0 `right_mono_until`-with-`Formula.top` inlining left).
  These are useful as **building blocks** for this task's F-14(a) work (a duality-derived
  `someFuture_mono` genuinely is the shape `past_tf_deriv` uses) but are not deliverables of 527.

---

## 3. F-05: the coherence-predicate dead set is bigger than "four predicates"

`bundleFlow_truth_lemma` (`FlowFrame.lean:662-669`) still binds
`(_h_rtc : B.RestrictedTemporallyCoherent root)` unused, exactly as F-05 describes. But its only
live consumer is now `bundleFlow_completeness_from_neg_membership` (`FlowFrame.lean:782-793`) —
the review's second call site, `fc_theorem_true_in_bundle_flow_model`, does not exist anywhere in
the current tree (searched the full repo, live and archived). The `BFMCS.CanonicalCoherence`
bundling F-05 recommends is a **two-signature** change now (the truth lemma + its one consumer),
not three.

Following the bridge-lemma chain with word-boundary-safe search (the review's own grep-based
survey undercounts here because `TemporallyCoherent` is a substring of
`RestrictedTemporallyCoherent`), the dead set inside `TemporalCoherence.lean` (611 lines) is:

- **1 dead structure**: `TemporalCoherentFamily` (`:124-142`) — mentioned only in a docstring
  comment in `FMCSDef.lean:64`, never instantiated or extended anywhere live.
- **4 dead derivation lemmas** built on it: `temporal_backward_G` (`:144`), `temporal_backward_H`
  (`:170`), `temporal_backward_G_with_fwd_F` (`:191`), `temporal_backward_H_with_bwd_P` (`:213`) —
  span `:124-242`, ~119 lines.
- **4 dead `Prop` predicates**: `BFMCS.TemporallyCoherent` (`:243`), `BFMCS.UntilSinceCoherent`
  (`:455`), `BFMCS.ForwardUntilSinceCoherent` (`:507`), `BFMCS.BackwardUntilSinceCoherent`
  (`:492`) — this is F-05's stated "four predicates with no live consumer", confirmed.
- **6 dead bridge lemmas** that only exist to connect the dead predicates to the three live
  `Restricted*` ones: `temporally_coherent_implies_restricted` (`:285`),
  `forward_implies_restricted_forward` (`:540`), `backward_implies_restricted_backward` (`:571`),
  `split_until_since_coherent` (`:583`), `until_since_coherent_backward` (`:595`),
  `until_since_coherent_forward` (`:605`) — none has any consumer outside this one file, including
  each other.

Total: **~260 of the file's 611 lines (~43%)** have zero live consumers once the bridge chain is
followed to its end, not just the four `def`s F-05 names. **Recommendation for Phase A**: prune
the whole reachability-dead set in one pass (structure + 4 derivation lemmas + 4 predicates + 6
bridges), not just the four predicates — cheaper to do once than to discover the orphaned bridge
lemmas in a follow-up pass. Keep `BFMCS.RestrictedTemporallyCoherent` (`:274`),
`BFMCS.RestrictedForwardUntilSinceCoherent` (`:524`), `BFMCS.RestrictedBackwardUntilSinceCoherent`
(`:555`), and their four `restricted_temporal_backward_*` consumer lemmas (`:305,331,359,384`) —
those are exactly the three fields `BFMCS.CanonicalCoherence` should bundle.

---

## 4. F-17: the Filter-API rewrite target is asymmetric, and there is a third construction

`LimitMCS.lean` (441 lines) currently has **three** parallel finite-intersection/consistency
arguments, not two:

1. **Hand-rolled, `max`/`min`-threshold, both directions**: `limitSetBelow`/`limitSetAbove`
   (`:135,142`), `_mono_directed` (`:155,176`), `_finite_subset_mem` (`:202,210`), `_consistent`
   (`:224,232`), `_of_rat` (`:254,266`). This is what F-17 targets for deletion.
2. **Zorn/Lindenbaum-based extension**, Below-only: `limitMCSLindenbaum` (`:286`) plus
   `limitSetBelow_subset_limitMCSLindenbaum` (`:290`) and `limitMCSLindenbaum_is_mcs` (`:295`).
   This construction is **dead outside `LimitMCS.lean` itself** — grepped the full live tree,
   zero external references. The file's own docstring (`:47,81`) already frames it as "the
   arbitrary-extension variant, recorded for comparison," i.e. known-unused. Not named in F-17,
   but it is a fourth thing this task should remove (or explicitly Boneyard) while in the file,
   since Phase C is already restructuring the surrounding declarations.
3. **Filter-based, correct, Below-only**: `limitFilterBelow` (`:315`, `Filter.comap`),
   `limitMCSBelow` (`:354`), `limitMCSBelow_finite_subset_mem` (`:392`, via `Filter.inter_mem`),
   `limitMCSBelow_is_mcs` (`:424`). **There is no `limitFilterAbove`/`limitMCSAbove`.** Every
   external consumer of the "Above" direction (`RealExtension.lean`, `LimitMCSCoherence.lean`)
   uses the hand-rolled `limitSetAbove`, because the Filter-based path was only ever built for one
   side.

**Consequence for Phase C**: F-14(b)'s `TemporalSide` parameterization is not just an elegance
improvement here — it is the mechanism that makes the Filter-based construction available on the
Above/past side at all, since building `limitFilterAbove` by hand-mirroring `limitFilterBelow`
(swap `𝓝[<] r` for `𝓝[>] r`, swap the finite-intersection direction) would just reproduce the
mirror-duplication problem F-14 exists to eliminate. Recommend sequencing Phase C as: (a)
introduce the side-parameterized `limitFilter`/`limitSet`/`limitMCS` family instantiated at
future/past, (b) delete the hand-rolled Below/Above pair in favor of it, (c) delete
`limitMCSLindenbaum` (dead) in the same pass, (d) Boneyard the five dead `LimitMCSCoherence.lean`
lemmas the review names (`:110,131,174,188,211` in the review's numbering — re-verify exact lines
before deleting, since 526 may have shifted them by a few).

---

## 5. F-08 / F-04 / F-20: confirmed as described, no drift worth flagging

- **F-08**: `WitnessSeed.lean:154-537` still has the four ~78-90-line proofs
  (`forward_temporal_witness_seed_consistent`, `past_temporal_witness_seed_consistent`,
  `until_witness_seed_consistent`, `since_witness_seed_consistent`), and `UntilWitnessSeed`
  (`:352`) is still `{ψ} ∪ GContent M`, identical to `ForwardTemporalWitnessSeed` (`:123`), with
  its own duplicated `psi_mem_*`/`g_content_subset_*` lemmas (`:356,361`). The review's
  recommendation (extract `allFuture_neg_of_gseed_inconsistent` + past mirror as the shared core,
  delete `UntilWitnessSeed`) stands unchanged. Note the review's own cross-reference —
  "Depends on: F-14" — is correct and should stay reflected in phase ordering: doing the mirror
  abstraction (Phase B) first makes the past half of the shared core a derivation rather than a
  second proof, so Phase A's witness-seed core extraction is cheaper if Phase B's discipline (or
  at least its `allFuture`/`allPast`-pair helper) lands first for this file. The task's own
  phase order (A before B) inverts this; it is not wrong (F-08's *forward* half needs no
  duality), but the *past* mirrors inside the four proofs will end up written twice (once during
  Phase A's core extraction, once refactored again during Phase B) unless Phase A's core
  extraction already writes the past half via `swapTemporal`+`temporal_duality` instead of by a
  second hand-proof. Recommend the planner fold this specific piece of Phase B's technique into
  Phase A's witness-seed work directly, rather than doing it twice.
- **F-04**: `ReynoldsBridge.lean:769` `multiFamTaskFrame` is still a full `where`-block
  re-discharging all six `FrameOver` fields that `FlowFrame.lean:146` `multiFamTaskFrameGen`
  already discharges generically, and `:797` `multiFamTaskFrame_eq_gen` still proves the `rfl`
  identity the review describes. The `ChronicleMonadicBridge.lean:144`-area duplicate `rfl`
  restatement is confirmed present too. No drift; the review's recommended
  `def multiFamTaskFrame ... := Algebraic.multiFamTaskFrameGen intOrder FamIdx` replacement is
  still exactly right.
- **F-20**: `FMCSDef.lean:103` `structure FMCS (fc : FrameClass := FrameClass.Base)` and
  `BFMCS.lean:91` still declare `fc` ahead of the `variable (D : Type) [Preorder D]`-supplied `D`.
  127 named-argument call sites confirmed live (`grep -c "FMCS (fc := \|BFMCS (fc := "` across the
  live tree, Boneyard excluded). This is a large, purely mechanical sweep; nothing about the count
  or shape changed since the review beyond the small (~3-site) drift from task 526's edits.

---

## 6. Re-baselined line-reduction estimate

Measured against the **current** live tree (not the review's pre-520 baseline):

| Item | Current lines | Estimated after | Saved |
|---|---:|---:|---:|
| F-08 witness-seed core extraction (`WitnessSeed.lean` proofs, `:154-537`) | ~384 | ~160 | ~220 |
| F-05 + extended dead-code prune (`TemporalCoherence.lean` dead structure/lemmas/predicates/bridges) | ~260 (dead span) | 0 | ~260 |
| F-14(a) duality-derivation for the remaining live mirror pairs (`TemporalContent.lean:157/212`, `TemporalCoherence.lean`'s 3 live `restricted_*` pairs at `:305/331,359/384` region) | ~150 (past halves) | ~30 (derived, ~5-10 lines each) | ~120 |
| F-17 Filter rewrite (`LimitMCS.lean` hand-rolled Below/Above `:135-267`, plus dead `limitMCSLindenbaum` `:286-297`) | ~145 | ~40 (side-parameterized) | ~105 |
| F-17 dead `LimitMCSCoherence.lean` lemmas (5, review-numbered `:110,131,174,188,211`) | ~90 (estimate, re-verify exact spans before cutting) | 0 | ~90 |
| F-04 `multiFamTaskFrame` specialization + duplicate `rfl` deletion | ~40 | ~5 | ~35 |
| F-20 `fc`/`D` reorder | 127 call sites | 127 call sites | 0 (mechanical, no line delta) |
| **Total** | | | **~830** at the high end if every item lands cleanly, **~550-650** more conservatively (the F-14(a) figure in particular depends on how much of `LimitMCSCoherence.lean`'s live content also collapses under the `TemporalSide` parameterization, which this report has not fully traced line-by-line) |

This lands inside the task's stated 800-1,400 line target only at the high end of the range, and
only if the `TemporalSide` parameterization in Phase C also collapses live (non-dead)
`LimitMCSCoherence.lean` content beyond the five already-dead lemmas — plausible, since F-14
itself lists five `LimitMCSCoherence.lean` mirror pairs (`:92/158, :110/188, :131/211, :259/298,
:278/315`) as still-live duplication, separate from the five dead lemmas F-17 names. **Recommend
the planner re-verify the low end of the acceptance range (800 lines) is achievable before
locking it, or state 550-830 as the honest range** — the task description's 800-1,400 figure
predates task 520's removal of ~1,300 lines of the review's own duplication estimate.

---

## 7. Recommendations for the planner, by phase

**Phase A** (as scoped, with one addition and one sequencing note):
- Add `BFMCS.CanonicalCoherence` structure (3 fields: `temporal`, `untilSince_fwd`,
  `untilSince_bwd`), retype `bundleFlow_truth_lemma` and its **single** live consumer
  `bundleFlow_completeness_from_neg_membership` (not two consumers — verify no other caller
  exists before finalizing the plan's call-site list).
- Prune the **full** dead-reachability set in `TemporalCoherence.lean`, not just the four
  predicates: `TemporalCoherentFamily` struct, `temporal_backward_{G,H}` +
  `temporal_backward_{G_with_fwd_F,H_with_bwd_P}`, the four dead predicates, and the six dead
  bridge lemmas (§3 above has exact names and line spans).
- Extract the witness-seed core (`allFuture_neg_of_gseed_inconsistent` + past mirror), but derive
  the past mirror via `swapTemporal`/`temporal_duality` rather than a second hand proof (folds
  part of Phase B's technique in here — see §5).
- Delete `UntilWitnessSeed` in favor of `ForwardTemporalWitnessSeed`.
- Make `multiFamTaskFrame` a definitional specialization of `multiFamTaskFrameGen`; delete the
  `ChronicleMonadicBridge.lean` duplicate `rfl` restatement.

**Phase B** (as scoped): apply the `past_tf_deriv` pattern
(`Formula.swapTemporal` + `DerivationTree.temporal_duality` + `swap_temporal_involution`) to the
remaining live mirror pairs — `TemporalContent.lean:157/212` and the (surviving,
non-pruned) `restricted_temporal_backward_*` pairs in `TemporalCoherence.lean`. Note that after
Phase A's dead-code prune, `TemporalCoherence.lean`'s only remaining mirror pairs are the four
`restricted_temporal_backward_{G,H}[_strict]` theorems (`:305,331,359,384` currently) — Phase B's
scope in this file shrinks accordingly. Record the discipline in `Bundle/README.md`, which
currently (183 lines, regenerated by task 520) has no section on this; add it near the "Key
Insight" section.

**Phase C** (as scoped, with the addition from §4): define `limitFilterBelow` as the `comap`
first, `limitSetBelow` as the eventually-set; delete the hand-rolled `:156-218` region in favor of
`Filter.eventually_all_finite`/`Filter.NeBot.nonempty_of_mem`; delete the dead
`limitMCSLindenbaum`/`limitSetBelow_subset_limitMCSLindenbaum`/`limitMCSLindenbaum_is_mcs` trio
found in this report (§4, item 2) in the same pass; Boneyard the five dead
`LimitMCSCoherence.lean` lemmas (re-verify line numbers first — 526 may have shifted them);
introduce the `TemporalSide` parameter so `limitSet`/`limitFilter`/`limitMCS` and the
`LimitMCSCoherence` families are stated once and instantiated at future/past — this is what
produces the missing `limitFilterAbove`/`limitMCSAbove` without hand-mirroring. Reorder
`FMCS`/`BFMCS` to `(D) [Preorder D] (fc := .Base)` last, as a purely mechanical 127-site sweep
(not 130 — re-verify at plan time, task 526 may have touched a couple more sites since this
count).

**Acceptance criteria**: recommend restating the line-reduction target as **550-830 lines**
(re-baselined against the current 4,035-line live scope, not the review's pre-520 6,870-line
baseline) rather than carrying forward "at least 800." Every other acceptance criterion in the
task description (unchanged consumer statements, zero unused hypotheses on the truth lemma, one
frame-construction site, `lake build` green, C2 baseline unchanged after every phase) is unaffected
by this report and should stand as written.

---

## 8. Files touched by this task (confirmed current paths)

- `FormalSystem/Metalogic/Bundle/WitnessSeed.lean` (596 lines)
- `FormalSystem/Metalogic/Bundle/TemporalContent.lean` (225 lines)
- `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean` (611 lines)
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (441 lines)
- `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` (328 lines)
- `FormalSystem/Metalogic/Bundle/FMCSDef.lean` (131 lines) / `BFMCS.lean` (236 lines) — F-20 only
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` (797 lines) — `bundleFlow_truth_lemma`,
  `past_tf_deriv`, `multiFamTaskFrameGen`
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` — `multiFamTaskFrame`,
  `multiFamTaskFrame_eq_gen`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` — duplicate `rfl`
  restatement (`multiFamTaskFrameGen_int`)
- `FormalSystem/Metalogic/Bundle/README.md` (183 lines) — Phase B documentation target

**Out of scope** (archived by task 520, do not plan work against these paths):
`FormalSystem/Boneyard/BundleDeadHalf/SuccRelation.lean`,
`FormalSystem/Boneyard/BundleDeadHalf/CanonicalTaskRelation.lean`.

**Already discharged** (task 526, do not re-derive): `SetMaximalConsistent.bot_not_mem` (F-09),
`someFuture_mono`/`somePast_mono` replacing inline `right_mono_until ... Formula.top` (F-15).
