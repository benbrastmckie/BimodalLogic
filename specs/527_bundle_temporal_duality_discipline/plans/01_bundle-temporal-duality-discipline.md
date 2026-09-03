# Implementation Plan: Bundle Temporal Duality Discipline

- **Task**: 527 - WAVE 4 (canonical-model infrastructure): replace textual future/past mirroring in `Metalogic/Bundle/` with derived duals, bundle the truth lemma's coherence hypotheses, and put the limit-MCS construction on Mathlib's `Filter` API
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours
- **Dependencies**: 520 (COMPLETED), 526 (COMPLETED)
- **Research Inputs**: `specs/527_bundle_temporal_duality_discipline/reports/01_bundle-temporal-duality-discipline.md`
- **Artifacts**: plans/01_bundle-temporal-duality-discipline.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Three grouped bodies of work — coherence bundling and dead-code removal (Group A), the
temporal-duality derivation discipline (Group B), and the `Filter`-API / `TemporalSide`
restructuring of the limit-MCS construction (Group C) — split into ten phases so each fits one
agent run. Every phase leaves `lake build` green and the `scripts/check-module-invariants.sh`
C2 axiom baseline unchanged; each of the three groups additionally has an explicit group-green
checkpoint so the task can stop cleanly at a group boundary.

The plan is built against the research report's re-measurement of the current tree, not against
the task description's `MEASURED STATE` paragraph. Where the two disagree, the report wins: task
520 archived `SuccRelation.lean` and `CanonicalTaskRelation.lean` wholesale, so six of the task
description's mirror-pair anchors no longer exist, and the dead set in `TemporalCoherence.lean` is
substantially larger than the description's "four predicates".

### Research Integration

Findings from the report that materially shaped this plan:

- **F-05 is a two-signature change, not three.** `fc_theorem_true_in_bundle_flow_model` does not
  exist in the tree. The only live consumer of `bundleFlow_truth_lemma` is
  `bundleFlow_completeness_from_neg_membership` (`Algebraic/FlowFrame.lean:782`).
- **The `TemporalCoherence.lean` dead set is ~260 of 611 lines**, not four `def`s: one dead
  structure (`TemporalCoherentFamily` `:124`), four dead derivation lemmas (`:144, :170, :191,
  :213`), four dead predicates (`:243, :455, :492, :507`), six dead bridge lemmas (`:285, :540,
  :571, :583, :595, :605`). Confirmed independently during planning by declaration enumeration.
- **F-17's Filter path is Below-only.** There is no `limitFilterAbove`/`limitMCSAbove`; the
  `TemporalSide` parameterization is the mechanism that makes the Filter construction reachable on
  the past side rather than a pure elegance play. `LimitMCS.lean` also carries a third, entirely
  dead construction (`limitMCSLindenbaum` `:286` + two support lemmas `:290, :295`) plus a dead
  `limitUltrafilterBelow` (`:343`).
- **The five dead `LimitMCSCoherence.lean` lemmas were re-verified at plan time** and the review's
  line numbers still hold exactly: `:110, :131, :174, :188, :211`
  (`limitSetBelow_forward_G_rat_target`, `limitSetBelow_forward_G_limit`,
  `limitSetBelow_of_rat_of_backward_H_rat_source`, `limitSetBelow_backward_H_rat_target`,
  `limitSetBelow_backward_H_limit`) — each referenced only by its own declaration and by prose in
  the module docstrings.
- **F-20 is 127 sites, not 130.** Re-confirmed at plan time.
- **Report sequencing recommendation adopted.** The report advises folding Phase B's duality
  technique into Phase A's witness-seed core extraction so the past half is not written twice. See
  "Phase-boundary decision" below.

### Facts established during planning that the report did not measure

These were checked while sizing phases and change the call-site accounting materially:

1. **`limitSetBelow` and `limitMCSBelow` have ~57 external references across seven files**, five
   of them under `BXCanonical/Chronicle/` — outside the declared `file_scope`. The `TemporalSide`
   parameterization therefore MUST keep `limitSetBelow`/`limitMCSBelow`/`limitSetAbove` as thin
   definitional specializations of the parameterized family rather than renaming them away. This
   is what preserves the "every consumer theorem unchanged in statement" criterion.
2. **`until_witness_seed_consistent` has an external consumer** in
   `BXCanonical/Chronicle/PointInsertion.lean`. Deleting `UntilWitnessSeed` therefore requires the
   theorem name to survive as a restatement over `ForwardTemporalWitnessSeed`, or
   `PointInsertion.lean` to be updated. The plan takes the first option (name survives, statement
   unchanged modulo the definitionally-equal seed).
3. **`since_witness_seed_consistent` (`WitnessSeed.lean:460`) is fully dead** — its only
   occurrence in the live tree is its own declaration. That is ~78 lines deletable outright.
4. **`bundleFlow_completeness_from_neg_membership` has four real call sites** —
   `BXCanonical/DiscreteCarrierProbe.lean:91`, `BXCanonical/CompletenessDedekind.lean:104`,
   `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:835`,
   `BXCanonical/Completeness.lean:150` — all outside the declared `file_scope`, plus prose
   references in `StrongCompleteness.lean:438` and two Chronicle docstrings. Each call-site edit is
   the one-token change `h_rtc h_buc h_fuc` -> `⟨h_rtc, h_buc, h_fuc⟩`; no enclosing statement
   changes.
5. **The `fc := ` reorder may be close to a no-op at existing call sites.** Lean 4 accepts
   `FMCS (fc := fc) D` against a signature declaring `D` first, so the 127 sites likely still
   elaborate unchanged after the reorder. The reorder's value is ergonomic (new sites can write
   `FMCS D`), and its measured line delta is zero — the plan treats "all 127 sites still
   elaborate" as the success condition, with call-site simplification as a bounded, optional
   follow-on inside the same phase.
6. **`multiFamTaskFrame_eq_gen` (`ReynoldsBridge.lean:797`) has zero consumers**;
   `multiFamTaskFrameGen_int` (`ChronicleMonadicBridge.lean:144`) has two prose references in its
   own file. The `rfl` certification to delete is therefore `multiFamTaskFrame_eq_gen`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists and was consulted read-only. No `roadmap_flag` was passed with this
delegation, so no roadmap review/update phases are added and ROADMAP.md is not modified by this
plan.

## Phase-boundary decision (asked for explicitly)

The task description's Phase A / Phase B / Phase C grouping is preserved as the *green-checkpoint*
grouping, but the research report's sequencing advice is adopted **inside** Group A:

- **Group A = Phases 1-4.** Phase 3 (witness-seed core extraction) writes the past half of the
  shared core via `Formula.swapTemporal` + `DerivationTree.temporal_duality` +
  `Formula.swap_temporal_involution` — i.e. the Group B technique — rather than as a second hand
  proof. This is the report's §5 recommendation: doing it any other way means writing the past
  mirror once in Group A and refactoring it again in Group B.
- **Group B = Phases 5-6.** Group B is therefore *not* "introduce the technique"; the technique is
  already in the tree by end of Phase 3. Group B is "apply it to the remaining live mirror pairs
  outside `WitnessSeed.lean`, and record it as the standing rule in `Bundle/README.md`". Its scope
  in `TemporalCoherence.lean` shrinks to the four surviving `restricted_temporal_backward_*`
  theorems, because Phase 2 has already deleted everything else in that file's mirror set.
- **Group C = Phases 7-10.** Unchanged in scope from the task description, with the `TemporalSide`
  work sequenced as the report's §4 recommends: Filter foundation first, then side-parameterization
  (which is what produces the missing `limitFilterAbove`/`limitMCSAbove`), then dead-code prune,
  then the `fc`/`D` reorder.

Each group's last phase carries the group-green checkpoint. The task may be stopped at the end of
Phase 4, Phase 6, or Phase 10 with the tree in a coherent, fully-green state.

## Open decision for the user: the line-reduction acceptance criterion

**This is recorded, not silently resolved.** The task description's acceptance criterion reads
"Bundle/ + Algebraic/FlowFrame.lean shrink by **at least 800 lines**". That figure was set against
the 2026-09-01 review's pre-task-520 baseline, which counted `SuccRelation.lean` (553 lines) and
`CanonicalTaskRelation.lean` (759 lines) as part of the duplication to be removed. Task 520 has
since archived both files wholesale to `FormalSystem/Boneyard/BundleDeadHalf/` — by relocation, not
by the duality technique this task introduces. Roughly 1,300 lines of the original estimate are
therefore already gone and cannot be earned again here.

Re-baselined against the current live scope, the report's honest achievable range is
**550-830 lines**, reaching 800 only at the high end and only if the `TemporalSide`
parameterization also collapses live (non-dead) `LimitMCSCoherence.lean` content beyond the five
already-dead lemmas.

The plan is written to the **550-830 line** range. Neither reading is imposed:

| Option | Effect |
|---|---|
| **A (plan's working assumption)** | Restate the acceptance criterion as "shrink by 550-830 lines", record the measured delta in the summary, and accept any figure in range. |
| **B** | Hold "at least 800 lines" as a hard gate. Achievable only if Phase 8's `LimitMCSCoherence.lean` collapse lands at the optimistic end; if it does not, the task closes `[PARTIAL]` on a line-count technicality despite every structural goal being met. |
| **C** | Drop the numeric criterion entirely and gate on the structural criteria only (zero unused hypotheses, one frame-construction site, no textual mirrors left in the named files). |

**The implementer must not resolve this silently.** Phase 10 measures the actual delta and records
it; if the user has not chosen by then, Phase 10 reports the number against all three options
rather than declaring pass or fail. The other acceptance criteria (every consumer theorem
unchanged in statement, zero unused hypotheses on the truth lemma, one frame-construction site,
`lake build` green, C2 baseline unchanged after every phase) carry forward unchanged and are
gated normally.

**Baseline command** (run once at Phase 1 start, recorded in the progress file):

```
wc -l FormalSystem/Metalogic/Bundle/*.lean FormalSystem/Metalogic/Bundle.lean \
      FormalSystem/Metalogic/Algebraic/FlowFrame.lean
```

Current value at plan time: **4,082 lines** (Bundle/*.lean 3,238 + Bundle.lean 47 + FlowFrame.lean
797; `Bundle/README.md` excluded).

## Goals & Non-Goals

**Goals**:
- `BFMCS.CanonicalCoherence` bundles the three live `Restricted*` coherence predicates; the truth
  lemma binds no unused hypothesis.
- The reachability-dead set in `TemporalCoherence.lean` is removed in one pass.
- The four ~85-line witness-seed consistency proofs become applications of one shared core, with
  the past half derived by temporal duality rather than hand-proved.
- `multiFamTaskFrame` is a definitional specialization of `multiFamTaskFrameGen`; exactly one
  `rfl` certification of that identity survives.
- The `past_tf_deriv` duality pattern is applied to every remaining live mirror pair in the named
  files and recorded as the standing rule in `Bundle/README.md`.
- The limit-MCS construction rests on Mathlib's `Filter` API and is stated once, parameterized by
  `TemporalSide`, instantiated at future/past.
- `FMCS`/`BFMCS` declare `(D) [Preorder D] (fc := .Base)`.
- `lake build` green and C2 axiom baseline unchanged after **every** phase.

**Non-Goals**:
- Re-deriving anything task 526 already discharged (`SetMaximalConsistent.bot_not_mem`,
  `someFuture_mono`/`somePast_mono`). Use them; do not rebuild them.
- Any work against `FormalSystem/Boneyard/BundleDeadHalf/**` — archived by task 520, out of scope.
- Changing the *statement* of any consumer theorem outside the named files. Call-site
  argument-packing changes are in scope; statement changes are not.
- Renaming `limitSetBelow`/`limitMCSBelow`/`limitSetAbove` away. They stay as specializations.
- Modifying `specs/ROADMAP.md`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `TemporalSide` parameterization breaks ~57 external `limitSetBelow`/`limitMCSBelow` call sites under `BXCanonical/Chronicle/` | H | H | Keep the Below/Above names as thin definitional specializations (`def limitSetBelow m r := limitSet .below m r`); never rename. Phase 7 verification enumerates all seven consumer files and builds them. |
| Deleting `UntilWitnessSeed` breaks `PointInsertion.lean` | M | H | `until_witness_seed_consistent` survives as a restatement over the definitionally-equal `ForwardTemporalWitnessSeed`; only its proof changes. Verify by building `PointInsertion.lean`. |
| Retyping the completeness engine touches four files outside `file_scope` | M | H | Each edit is one-token argument packing; enclosing statements unchanged. Phase 1 enumerates all four sites up front and treats them as one atomic batch. Flag the `file_scope` addition in the summary. |
| C2 axiom baseline drifts from a proof-technique change (e.g. `Classical` creeping in via a Filter/Zorn route) | H | M | Run `scripts/check-module-invariants.sh` after every phase, not only at the end. Any drift is a HARD STOP, not a new baseline. |
| The `fc`/`D` reorder turns out to be a no-op at all 127 sites, delivering no measurable value | L | M | Documented in advance (Established Fact 5). Phase 9 succeeds on "all 127 sites elaborate"; call-site simplification is bounded and optional. |
| The 550-830 line reduction lands below 800 | M | H | The open decision above. Phase 10 reports the measured delta against all three options rather than self-declaring pass/fail. |
| Lean elaboration slowdowns from `Filter`-heavy rewrites | M | L | Phase 7 checks `lake build` wall time against the Phase 6 figure; a >20% regression is reported, not absorbed. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- |
| 2 | 3 | 2 |
| 3 | 5 | 2, 3 |
| 4 | 6 | 5 |
| 5 | 7 | 1 |
| 6 | 8 | 7 |
| 7 | 9 | 8 |
| 8 | 10 | 1, 2, 3, 4, 5, 6, 7, 8, 9 |

Phases within the same wave can execute in parallel. Phases 1, 2 and 4 touch disjoint file sets
(`FlowFrame.lean` + four `BXCanonical` call sites / `TemporalCoherence.lean` / `ReynoldsBridge.lean`
+ `ChronicleMonadicBridge.lean`) and are genuinely independent. Everything from Phase 5 onward is
effectively sequential.

---

### Phase 1: `BFMCS.CanonicalCoherence` and truth-lemma retype [COMPLETED]

**Goal**: The truth lemma takes one bundled coherence argument and binds no unused hypothesis.

**Tasks**:
- [ ] Record the line-count baseline (command in the "Open decision" section above) into the
      progress file.
- [ ] Add `structure BFMCS.CanonicalCoherence (B : BFMCS (fc := fc) D) (root : Formula) : Prop`
      to `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean`, with fields `temporal :
      B.RestrictedTemporallyCoherent root`, `untilSince_fwd : B.RestrictedForwardUntilSinceCoherent
      root`, `untilSince_bwd : B.RestrictedBackwardUntilSinceCoherent root`. The three
      `Restricted*` predicates themselves are unchanged — they have ~40 external producer sites
      under `BXCanonical/**` and `Bundle/RealExtensionBundle.lean` that must keep working.
- [ ] Retype `bundleFlow_truth_lemma` (`Algebraic/FlowFrame.lean:662`) to take
      `(h_coh : B.CanonicalCoherence root)` in place of the three loose arguments. The
      `_h_rtc` binder disappears entirely — it is unused, which is F-05's core complaint.
- [ ] Retype `bundleFlow_completeness_from_neg_membership` (`Algebraic/FlowFrame.lean:782`) the
      same way and update its single internal use of the truth lemma (`:792`).
- [ ] Update the four external call sites with `⟨h_rtc, h_buc, h_fuc⟩` argument packing:
      `BXCanonical/DiscreteCarrierProbe.lean:91`, `BXCanonical/CompletenessDedekind.lean:104`,
      `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:835`,
      `BXCanonical/Completeness.lean:150`. Their enclosing statements do not change.
- [ ] Refresh the prose references in `Metalogic/StrongCompleteness.lean:438-441` and the two
      Chronicle docstrings (`ChronicleToCountermodelBasic.lean:604`,
      `ChronicleToCountermodel.lean:1180`) to name the bundled structure.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: exactly one live consumer of `bundleFlow_truth_lemma` and exactly four call
sites of `bundleFlow_completeness_from_neg_membership`. Confirm before editing with
`grep -rn "bundleFlow_truth_lemma\|bundleFlow_completeness_from_neg_membership" --include=*.lean
FormalSystem/ Tests/ | grep -v Boneyard`; if the count differs, record the actual set in the
progress file and widen the batch rather than proceeding on the stated figure.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean` - add `CanonicalCoherence` structure
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` - retype truth lemma and completeness engine
- `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` - argument packing (out of declared file_scope)
- `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` - argument packing (out of declared file_scope)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` - argument packing + docstring (out of declared file_scope)
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean` - argument packing (out of declared file_scope)
- `FormalSystem/Metalogic/StrongCompleteness.lean` - prose refresh (out of declared file_scope)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - prose refresh (out of declared file_scope)

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` — C2 baseline unchanged.
- `grep -n "_h_rtc" FormalSystem/Metalogic/Algebraic/FlowFrame.lean` returns nothing.
- No statement of any theorem outside `FlowFrame.lean` changed: `git diff` on the four call-site
  files shows only argument-packing hunks.
- Record the six out-of-`file_scope` files touched, for the summary's `file_scope` addition note.

---

### Phase 2: Prune the `TemporalCoherence.lean` dead-reachability set [COMPLETED WITH EXCLUSIONS]

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `BFMCS.BackwardUntilSinceCoherent` (`:492` at plan time) | Live external consumer, not dead as the plan's scope hypothesis assumed | `grep -rn "\bBackwardUntilSinceCoherent\b"` finds 6 in-file_scope hits in `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (`:558, :666, :818, :867, :915`) plus a docstring mention in `Bundle/LimitMCS.lean:76` |
| `BFMCS.ForwardUntilSinceCoherent` (`:507` at plan time) | Live external consumer, not dead as the plan's scope hypothesis assumed | `grep -rn "\bForwardUntilSinceCoherent\b"` finds 6 in-file_scope hits in `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (`:545, :665, :817, :866, :914`) plus the same `LimitMCS.lean:76` docstring mention |

Both predicates are retained verbatim (unchanged statements); only the module's surrounding
prose was refreshed to describe them as the unrestricted forms `ChronicleMonadicBridge.lean`
consumes directly. All 13 other named declarations (`TemporalCoherentFamily`,
`temporal_backward_G`, `temporal_backward_H`, `temporal_backward_G_with_fwd_F`,
`temporal_backward_H_with_bwd_P`, `BFMCS.TemporallyCoherent`, `BFMCS.UntilSinceCoherent`, and
the six dead bridge lemmas) were re-verified dead at phase start and deleted as planned; each
returns zero hits repo-wide (Boneyard excluded) after the edit.

**Goal**: Remove the full dead set in `TemporalCoherence.lean` in one pass, not just the four
predicates the task description names.

**Tasks**:
- [ ] Re-run the reachability check for each of the 15 named declarations before deleting any
      (word-boundary-safe grep, Boneyard excluded). `TemporallyCoherent` is a substring of
      `RestrictedTemporallyCoherent`, so a naive grep undercounts — use `\b` anchors.
- [ ] Delete the dead structure `TemporalCoherentFamily` (`:124-142`).
- [ ] Delete the four dead derivation lemmas built on it: `temporal_backward_G` (`:144`),
      `temporal_backward_H` (`:170`), `temporal_backward_G_with_fwd_F` (`:191`),
      `temporal_backward_H_with_bwd_P` (`:213`).
- [ ] Delete the four dead predicates: `BFMCS.TemporallyCoherent` (`:243`),
      `BFMCS.UntilSinceCoherent` (`:455`), `BFMCS.BackwardUntilSinceCoherent` (`:492`),
      `BFMCS.ForwardUntilSinceCoherent` (`:507`).
- [ ] Delete the six dead bridge lemmas: `temporally_coherent_implies_restricted` (`:285`),
      `forward_implies_restricted_forward` (`:540`), `backward_implies_restricted_backward`
      (`:571`), `split_until_since_coherent` (`:583`), `until_since_coherent_backward` (`:595`),
      `until_since_coherent_forward` (`:605`).
- [ ] Remove the now-dangling docstring mention of `TemporalCoherentFamily` in
      `FormalSystem/Metalogic/Bundle/FMCSDef.lean:64`.
- [ ] Refresh the `TemporalCoherence.lean` module docstring so it describes only what survives.

**Preserve** (do not delete): `BFMCS.RestrictedTemporallyCoherent` (`:274`),
`BFMCS.RestrictedForwardUntilSinceCoherent` (`:524`),
`BFMCS.RestrictedBackwardUntilSinceCoherent` (`:555`), the four
`restricted_temporal_backward_{G,H}[_strict]` theorems (`:305, :331, :359, :384`), and the three
helper lemmas at `:64, :83, :100`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: 15 declarations, ~260 of 611 lines, zero live consumers each. Confirm
per-declaration with `grep -rn "\b<name>\b" --include=*.lean FormalSystem/ Tests/ | grep -v
Boneyard` before deleting it; any declaration with a consumer outside `TemporalCoherence.lean`
stays and is recorded as a `#### Reasoned Exclusions` row.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean` - delete dead set, refresh docstring
- `FormalSystem/Metalogic/Bundle/FMCSDef.lean` - remove dangling docstring reference

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` — C2 baseline unchanged.
- `wc -l FormalSystem/Metalogic/Bundle/TemporalCoherence.lean` shows a reduction near 260 lines
  (allowing for the `CanonicalCoherence` structure added in Phase 1 if that phase ran first).
- Each of the 15 names returns zero hits repo-wide (Boneyard excluded).

---

### Phase 3: Witness-seed core extraction with duality-derived past half [COMPLETED]

**Actual line delta**: `WitnessSeed.lean` 596 -> 488 lines (-108), short of the ~220-line
scope hypothesis. The shortfall is a deliberate risk/scope trade-off, recorded here rather
than silently absorbed: full semantic transport of the past proof from the future one (via
an MCS-image-under-`swapTemporal` argument) would have collapsed the entire past-side case
split too, but requires a new "context-level temporal duality" lemma
(`Γ ⊢[fc] φ → (Γ.map swapTemporal) ⊢[fc] φ.swapTemporal`) and an MCS-image-is-MCS transport
lemma, neither of which exists in the tree today and neither of which the plan named as an
explicit task. The narrower technique actually used -- extracting the one genuinely
context-free syntactic step (`allFuture_bot_imp_neg_deriv` / `allPast_bot_imp_neg_deriv`,
Case 2 of each core) and deriving the past half of *that* step by
`Formula.swapTemporal` + `DerivationTree.temporal_duality` + `Formula.swap_temporal_involution`
-- satisfies every other Phase 3 acceptance criterion (shared core named
`allFuture_neg_of_gseed_inconsistent` exists; `forward_temporal_witness_seed_consistent` and
`until_witness_seed_consistent` are both one-line applications of it; the past-side core's
proof contains `swapTemporal` and `temporal_duality`; both public theorem statements are
byte-identical; `UntilWitnessSeed` and its two duplicated membership lemmas are deleted;
`since_witness_seed_consistent` is deleted; `until_witness_seed_consistent`'s name survives
for `PointInsertion.lean`) without the added risk of the larger transport lemma.

**Goal**: One shared core replaces four ~85-line consistency proofs, with the past half obtained
by temporal duality rather than a second hand proof.

**Tasks**:
- [ ] Extract `allFuture_neg_of_gseed_inconsistent` as the shared future-side core of
      `forward_temporal_witness_seed_consistent` (`WitnessSeed.lean:154`).
- [ ] Obtain the past mirror **by duality**, not by a second hand proof: follow
      `past_tf_deriv` (`Algebraic/FlowFrame.lean:618-628`) — `Formula.swapTemporal` +
      `DerivationTree.temporal_duality` + `Formula.swap_temporal_involution`. This is the Group B
      technique, applied here deliberately (see "Phase-boundary decision").
- [ ] Reduce `forward_temporal_witness_seed_consistent` (`:154`) and
      `past_temporal_witness_seed_consistent` (`:263`) to applications of the core. Their
      statements are unchanged — both have heavy external use (27 and 20 references across five
      `BXCanonical/**` files).
- [ ] Delete `UntilWitnessSeed` (`:352`) and its duplicated membership lemmas
      `psi_mem_until_witness_seed` (`:356`), `g_content_subset_until_witness_seed` (`:361`) —
      `UntilWitnessSeed M ψ` is byte-for-byte `ForwardTemporalWitnessSeed M ψ`.
- [ ] **Keep the name** `until_witness_seed_consistent` (`:381`), restated over
      `ForwardTemporalWitnessSeed` and proved by the core.
      `BXCanonical/Chronicle/PointInsertion.lean` consumes it.
- [ ] Delete `since_witness_seed_consistent` (`:460`) outright — confirmed dead at plan time (its
      only live occurrence is its own declaration).
- [ ] Refresh the `WitnessSeed.lean` module docstring.

**Timing**: 2.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: four ~85-line proofs collapsing to ~160 lines total (~220 saved);
`since_witness_seed_consistent` dead; `until_witness_seed_consistent` externally live in exactly
one file. Confirm each with a word-boundary grep before cutting; record actual line delta in the
progress file.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/WitnessSeed.lean` - core extraction, dual derivation, deletions

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` — C2 baseline unchanged.
- `BXCanonical/Chronicle/PointInsertion.lean`, `BXCanonical/CanonicalModel.lean`,
  `BXCanonical/Frame.lean`, `BXCanonical/OrderedSeedConsistency.lean`,
  `BXCanonical/Chronicle/CounterexampleElimination.lean` all build unchanged.
- `grep -c "UntilWitnessSeed\|since_witness_seed_consistent" FormalSystem/Metalogic/Bundle/WitnessSeed.lean`
  returns only the surviving `until_witness_seed_consistent` occurrences.
- The past-side core's proof contains `swapTemporal` and `temporal_duality` — verify by reading
  the diff, not by assuming.

---

### Phase 4: `multiFamTaskFrame` as a definitional specialization [COMPLETED]

**Deviation note**: replacing the `where`-block with `Algebraic.multiFamTaskFrameGen intOrder
FamIdx` broke one downstream `omega` call in `multiFam_total_eq`
(`ReynoldsBridge.lean`, `key` sub-lemma) -- `omega` could no longer close
`(σ.states t ht).2 = (σ.states 0 ⋯).2 + t` from `h₂ : (σ.states t ht).2 = (σ.states 0 ⋯).2 +
(t - 0)` once the extra unfolding layer was introduced (interactive `lean_goal` reported the
tactic closing the goal, but batch `lake build` did not -- the batch compile was treated as
authoritative). Replaced `omega` with the equivalent `rw [h₂, sub_zero]`, which is
unfolding-independent. No other downstream proof needed adjustment.

**Goal**: One frame-construction site; exactly one `rfl` certification of the generic identity.

**Tasks**:
- [ ] Replace the full `where`-block of `multiFamTaskFrame`
      (`WeakCanonical/IntegerModel/ReynoldsBridge.lean:769-793`) with
      `def multiFamTaskFrame (FamIdx : Type) [Nonempty FamIdx] : FrameOver intOrder :=
      Algebraic.multiFamTaskFrameGen intOrder FamIdx`.
- [ ] Delete `multiFamTaskFrame_eq_gen` (`ReynoldsBridge.lean:797`) — zero consumers, and after
      the replacement it certifies `x = x`.
- [ ] Keep `multiFamTaskFrameGen_int` (`ChronicleMonadicBridge.lean:144`): it has two live prose
      references in its own file and is the surviving single certification.
- [ ] Check whether `famShiftRel_fib_subsingleton` (`ReynoldsBridge.lean:760`) is still reachable
      after the `where`-block goes; delete it if not.
- [ ] Verify the four `multiFamTaskFrame_{serial,interpolates,...}` specialization theorems below
      `:800` still hold by the same `Algebraic.multiFamTaskFrameGen_*` applications.
- [ ] Refresh the surrounding section docstring (`:795`), which currently explains the
      definitional-equality argument that the new definition makes trivial.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: `multiFamTaskFrame` has 36 references across five files; only the definition
site changes and every reference should continue to elaborate because the two frames are
definitionally equal. Confirm by building all five files:
`ChronicleMonadicBridge.lean`, `ReynoldsBridge.lean`, `Algebraic/FlowFrame.lean`,
`WeakCanonical/GroupModel/CountermodelBase.lean`, `Semantics/Frames/Standard.lean`.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` - definitional specialization, delete `rfl` certification
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` - docstring refresh only if the surviving `rfl`'s prose needs it

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` — C2 baseline unchanged.
- Exactly one `rfl` certification of the `multiFamTaskFrame`/`multiFamTaskFrameGen` identity
  remains in the live tree.
- `grep -n "nullity_identity\|saturation\|serial" FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`
  shows no re-discharge of `FrameOver` fields.

---

### Phase 5: Apply the duality discipline to the remaining live mirror pairs [NOT STARTED]

**Goal**: Every remaining live future/past mirror pair in the named files is a derived dual, not a
second hand proof.

**Tasks**:
- [ ] `TemporalContent.lean`: derive `p_content_iff_not_neg_in_h_content` (`:198`) from
      `f_content_iff_not_neg_in_g_content` (`:157`) via `Formula.swapTemporal` +
      `DerivationTree.temporal_duality` + `Formula.swap_temporal_involution`. Note the task
      description cites this pair as `:157/212`; the actual second anchor in the current tree is
      `:198`.
- [ ] `TemporalCoherence.lean`: derive the past halves of the four surviving
      `restricted_temporal_backward_{G,H}[_strict]` theorems (`:305/:331` and `:359/:384`) from
      their future halves the same way.
- [ ] `WitnessSeed.lean`: apply the same treatment to the two surviving mirror helpers at
      `:60/:74` (`some_future_all_future_neg_absurd` / `some_past_all_past_neg_absurd`) and
      `:92/:107` (`neg_some_future_to_all_future_neg` / `neg_some_past_to_all_past_neg`) if the
      duality route is shorter than what stands after Phase 3; leave them and record a
      `#### Reasoned Exclusions` row if it is not.
- [ ] Use `someFuture_mono`/`somePast_mono` from `Core/MCSProperties.lean` (landed by task 526)
      wherever the mirror needs a monotonicity step — do not rebuild them.
- [ ] Every statement stays byte-identical; only proofs change.

**Timing**: 2.5 hours

**Depends on**: 2, 3

**Verification Tier**: interface

**Scope Hypothesis**: at most seven mirror pairs remain live in these three files after Phases 2
and 3. Enumerate them at phase start by listing declaration pairs whose names differ only by
`future`/`past`, `allFuture`/`allPast`, `G`/`H`, `untl`/`snce`, and record the actual list; if a
pair's future half is itself the harder direction, prove the future half first as the task
requires and derive the past half from it.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/TemporalContent.lean` - derive `p_content_iff_not_neg_in_h_content`
- `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean` - derive past halves of the four surviving theorems
- `FormalSystem/Metalogic/Bundle/WitnessSeed.lean` - the two surviving helper pairs, if profitable

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` — C2 baseline unchanged.
- `git diff` shows zero changes to any theorem *statement* in the three files.
- Each derived past half's proof body mentions `swapTemporal` and `temporal_duality`.

---

### Phase 6: Record the discipline in `Bundle/README.md`; Group A+B green checkpoint [NOT STARTED]

**Goal**: The duality rule is written down as the standing convention, and Groups A and B close
green together.

**Tasks**:
- [ ] Add a `## Temporal Duality Discipline` section to
      `FormalSystem/Metalogic/Bundle/README.md`, placed immediately after the existing
      `## Key Insight` section (`:23`).
- [ ] State the rule: *when a past statement is the `Formula.swapTemporal` image of a future one,
      prove the future form and obtain the past form by `Formula.swapTemporal` +
      `DerivationTree.temporal_duality` + `Formula.swap_temporal_involution`; do not write the
      mirror by hand.*
- [ ] Name `past_tf_deriv` (`FormalSystem/Metalogic/Algebraic/FlowFrame.lean`) as the reference
      implementation and cite the pairs converted in Phases 3 and 5 as worked examples. Reference
      declarations by name and file, never by line number.
- [ ] State the exception explicitly: order-theoretic mirrors where the mirror is `<`/`>` rather
      than `swapTemporal` (the `limitSet` family) are handled by the `TemporalSide` parameter
      instead — forward-reference Group C.
- [ ] Refresh any `README.md` statements that Phases 1-5 invalidated (architecture list, main
      theorems, module inventory).
- [ ] Run the Group A+B green checkpoint (below).

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/README.md` - new discipline section, refresh stale statements

**Verification**:
- Every changed hunk in `README.md` lies in prose (it is a markdown file; the tier's blind spot
  does not apply).
- **Group A+B green checkpoint**: `lake build` green;
  `bash scripts/check-module-invariants.sh` C2 baseline unchanged; every declaration named as
  deleted in Phases 2-4 returns zero live hits; every declaration named as preserved still
  resolves. Record the running line delta against the Phase 1 baseline.

---

### Phase 7: `LimitMCS.lean` Filter foundation [NOT STARTED]

**Goal**: The limit set is the `Filter`-eventually set by definition, and the hand-rolled
finite-intersection argument is gone.

**Tasks**:
- [ ] Move `limitFilterBelow` (`LimitMCS.lean:315`) ahead of `limitSetBelow` and define it as
      `Filter.comap Rat.cast (𝓝[<] r)` (its current hand-built `Filter` record becomes
      unnecessary).
- [ ] Redefine `limitSetBelow` (`:135`) as `{A | ∀ᶠ q in limitFilterBelow r, A ∈ m q}`.
- [ ] Keep exactly **one** unfolding lemma, `mem_limitSetBelow`, as the interface every downstream
      file uses. `limitSetBelow` has 32 external references across seven files; they must all keep
      working through this lemma.
- [ ] Delete the hand-rolled threshold argument (`:155-240` region:
      `limitSetBelow_mono_directed`, `limitSetAbove_mono_directed`,
      `limitSetBelow_finite_subset_mem`, `limitSetAbove_finite_subset_mem`) in favour of
      `Filter.inter_mem`, `Filter.eventually_all_finite`, `Filter.NeBot.nonempty_of_mem`.
- [ ] Re-prove `limitSetBelow_consistent` / `limitSetAbove_consistent` (`:224, :232`) on the Filter
      route; keep their statements unchanged.
- [ ] Do **not** rename anything in this phase. `limitSetAbove` stays hand-rolled here; Phase 8
      makes it a specialization.
- [ ] Record `lake build` wall time for the elaboration-regression check.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: `limitSetBelow` has 32 external references across
`BXCanonical/Chronicle/{ChronicleGuardAccumulation, ChronicleLimitGuardAbove,
CounterexampleElimination, ChronicleLimitGuardWitness, ChronicleRealExtension}.lean`,
`Bundle/RealExtensionBundle.lean`, `Bundle/RealExtension.lean`. Re-count at phase start; build all
seven files before closing the phase.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean` - Filter-first definitions, delete hand-rolled argument

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` — C2 baseline unchanged.
- All seven external consumer files build with no source change.
- Exactly one `mem_limitSetBelow`-style unfolding lemma exists.
- `lake build` wall time within 20% of the Phase 6 figure; report if not.

---

### Phase 8: `TemporalSide` parameterization and limit-MCS dead-code prune [NOT STARTED]

**Goal**: `limitSet`, `limitFilter`, `limitMCS` and the `LimitMCSCoherence` families are stated
once and instantiated at future/past; the dead constructions are gone.

**Tasks**:
- [ ] Introduce `TemporalSide` and parameterize `limitFilter`, `limitSet`, `limitSet_mono_directed`
      (or its Filter-era successor), `limitSet_consistent`, `limitMCS` on it.
- [ ] **Retain `limitSetBelow`, `limitSetAbove`, `limitMCSBelow`, `limitFilterBelow` as thin
      definitional specializations** of the parameterized family. This is non-negotiable: ~57
      external references across seven files depend on those names, five of them outside the
      declared `file_scope`. This is also what delivers the previously-missing
      `limitFilterAbove`/`limitMCSAbove` for free.
- [ ] Restate the four live `LimitMCSCoherence.lean` families
      (`limitMCSBelow_{forward_G,backward_H}_{rat_target,limit}`, `:259, :278, :298, :315`) once,
      side-parameterized, with the `Below` names surviving as instantiations —
      `Bundle/RealExtension.lean` consumes all four.
- [ ] Keep `limitSetBelow_forward_G_rat_source` (`:92`) and `limitSetBelow_backward_H_rat_source`
      (`:158`) — both have live consumers in `Bundle/RealExtension.lean`.
- [ ] Boneyard the five dead `LimitMCSCoherence.lean` lemmas, re-verified at plan time:
      `limitSetBelow_forward_G_rat_target` (`:110`), `limitSetBelow_forward_G_limit` (`:131`),
      `limitSetBelow_of_rat_of_backward_H_rat_source` (`:174`),
      `limitSetBelow_backward_H_rat_target` (`:188`), `limitSetBelow_backward_H_limit` (`:211`),
      together with the module-docstring lines (`:43-46`) that name them.
- [ ] Delete the dead Zorn/Lindenbaum construction in `LimitMCS.lean`: `limitMCSLindenbaum`
      (`:286`), `limitSetBelow_subset_limitMCSLindenbaum` (`:290`), `limitMCSLindenbaum_is_mcs`
      (`:295`), plus its docstring mentions (`:47, :81, :277`).
- [ ] Delete `limitUltrafilterBelow` (`:343`) and re-prove `limitFilterBelow_le` (`:346`) directly
      if it depended on it; confirm the ultrafilter route is genuinely unused first.

**Timing**: 2.5 hours

**Depends on**: 7

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: five dead `LimitMCSCoherence.lean` lemmas and four dead `LimitMCS.lean`
declarations. Re-verify each with a word-boundary grep at phase start; the plan-time check found
each referenced only by its own declaration and by module-docstring prose, but 526-era drift is
possible. Any declaration found live stays and gets a `#### Reasoned Exclusions` row.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean` - `TemporalSide`, specializations, dead-code deletion
- `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` - side-parameterized families, Boneyard five dead lemmas
- `FormalSystem/Boneyard/` - destination for the Boneyarded lemmas, with a README note naming the retirement reason

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` — C2 baseline unchanged.
- `Bundle/RealExtension.lean`, `Bundle/RealExtensionBundle.lean` and the five
  `BXCanonical/Chronicle/` consumers build with **no source change** — this is the concrete test
  that the Below/Above names survived correctly.
- `limitFilterAbove` and `limitMCSAbove` now exist and typecheck.
- Each of the nine deleted names returns zero live hits (Boneyard excluded).

---

### Phase 9: `FMCS`/`BFMCS` parameter reorder [NOT STARTED]

**Goal**: Both structures declare `(D) [Preorder D] (fc := .Base)`.

**Tasks**:
- [ ] Reorder `structure FMCS` (`Bundle/FMCSDef.lean:103`) and `structure BFMCS`
      (`Bundle/BFMCS.lean:91`) so `D` and its `[Preorder D]` instance binder precede
      `(fc : FrameClass := FrameClass.Base)`.
- [ ] Rebuild and confirm all 127 `FMCS (fc := …)` / `BFMCS (fc := …)` named-argument sites still
      elaborate. Lean 4 resolves a named argument ahead of positional ones, so most or all are
      expected to be unaffected — see Established Fact 5. Fix only the sites that actually break.
- [ ] Optionally, and bounded to the two `Bundle/` files with the highest density
      (`TemporalCoherence.lean`, 20 sites; `RealExtensionBundle.lean`, 11 sites), simplify sites
      where `fc` is the default to the shorter `FMCS D` / `BFMCS D` form. Do not sweep the
      `BXCanonical/**` files — that is out of scope and delivers no line reduction.
- [ ] Record the measured line delta (expected: zero).

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 127 sites across 13 files (top five:
`Chronicle/ChronicleRealExtension.lean` 27, `Algebraic/FlowFrame.lean` 23,
`Bundle/TemporalCoherence.lean` 20, `Chronicle/ChronicleMonadicBridge.lean` 17,
`Bundle/RealExtensionBundle.lean` 11). Re-count at phase start with
`grep -rn "FMCS (fc := \|BFMCS (fc := " --include=*.lean FormalSystem/ Tests/ | grep -v Boneyard
| wc -l`; the number will have drifted if earlier phases deleted declarations.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/FMCSDef.lean` - structure parameter reorder
- `FormalSystem/Metalogic/Bundle/BFMCS.lean` - structure parameter reorder
- Any call site that fails to elaborate after the reorder (enumerated at phase start, expected to
  be few or none)

**Verification**:
- `lake build` green — this is `full` tier because the two structures are core types touched by
  every file in the canonical stack.
- `bash scripts/check-module-invariants.sh` — C2 baseline unchanged.
- Full test suite: `lake build` over `Tests/BimodalTest/` green.
- The structure signatures read `(D : Type) [Preorder D] (fc : FrameClass := FrameClass.Base)`.

---

### Phase 10: Final accounting, line-delta measurement, Group C green checkpoint [NOT STARTED]

**Goal**: The task closes with a measured, honestly-reported line delta and every acceptance
criterion checked.

**Tasks**:
- [ ] Re-run the baseline command and compute the delta against the Phase 1 figure (4,082 lines at
      plan time):
      `wc -l FormalSystem/Metalogic/Bundle/*.lean FormalSystem/Metalogic/Bundle.lean
      FormalSystem/Metalogic/Algebraic/FlowFrame.lean`.
- [ ] **Report the measured delta against all three options in the "Open decision" section** —
      do not self-declare pass or fail on the "at least 800 lines" criterion unless the user has
      chosen an option. State plainly which options the measured figure satisfies.
- [ ] Check each remaining acceptance criterion explicitly and record the evidence:
      zero unused hypotheses on the truth lemma; one frame-construction site; every consumer
      theorem unchanged in statement (`git diff` over the whole task, filtered to statement
      lines); `lake build` green; C2 baseline unchanged.
- [ ] Refresh `FormalSystem/Metalogic/Bundle/README.md` for anything Phases 7-9 invalidated
      (module inventory, main theorems, the `TemporalSide` forward-reference from Phase 6 now
      pointing at landed code).
- [ ] List every file touched outside the declared `file_scope` (Phase 1's six
      `BXCanonical`/`StrongCompleteness` files, plus any from Phases 3-4) for the summary's
      `file_scope` addition note.
- [ ] Run the Group C green checkpoint and the final gate.

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3, 4, 5, 6, 7, 8, 9

**Verification Tier**: full

**Scope Hypothesis**: the total reduction lands in 550-830 lines. This is the plan's central
scope hypothesis and the subject of the open decision above; confirm by measurement and report the
number, never by assertion.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/README.md` - final accuracy pass
- `specs/527_bundle_temporal_duality_discipline/summaries/01_*-summary.md` - implementation summary

**Verification**:
- `lake build` green from a clean state.
- `bash scripts/check-module-invariants.sh` (full run, not `--no-build`) — all checks pass, C2
  baseline unchanged.
- Test suite green.
- Measured line delta recorded with the exact `wc -l` output, before and after.
- Zero `sorry` introduced: `grep -rn "sorry" FormalSystem/Metalogic/Bundle/
  FormalSystem/Metalogic/Algebraic/FlowFrame.lean` unchanged from baseline.

---

## Testing & Validation

- [ ] `lake build` green after **every** phase, not only at the end.
- [ ] `bash scripts/check-module-invariants.sh` C2 axiom baseline unchanged after every phase. Any
      divergence is a HARD STOP, not a new baseline.
- [ ] `Tests/BimodalTest/` green after Phases 9 and 10.
- [ ] No `sorry` introduced anywhere in the touched scope.
- [ ] Every consumer theorem outside the named files unchanged in statement — verified by reading
      `git diff` for the whole task and confirming that out-of-scope hunks are argument-packing or
      prose only.
- [ ] `bundleFlow_truth_lemma` binds zero unused hypotheses.
- [ ] Exactly one frame-construction site for the `ℤ` multi-family frame.
- [ ] `limitFilterAbove` / `limitMCSAbove` exist and typecheck (the concrete proof that the
      `TemporalSide` parameterization did the job the mirror-duplication was hiding).
- [ ] Measured line delta recorded and reported against the open decision's three options.

## Artifacts & Outputs

- `specs/527_bundle_temporal_duality_discipline/plans/01_bundle-temporal-duality-discipline.md` (this file)
- `specs/527_bundle_temporal_duality_discipline/summaries/01_bundle-temporal-duality-discipline-summary.md`
- Modified: `FormalSystem/Metalogic/Bundle/{TemporalCoherence,WitnessSeed,TemporalContent,LimitMCS,LimitMCSCoherence,FMCSDef,BFMCS,README.md}`
- Modified: `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`
- Modified: `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`
- Modified: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean`
- Modified (outside declared `file_scope`, argument-packing and prose only):
  `FormalSystem/Metalogic/BXCanonical/{DiscreteCarrierProbe,CompletenessDedekind,Completeness}.lean`,
  `FormalSystem/Metalogic/BXCanonical/Chronicle/{ChronicleToCountermodelBasic,ChronicleToCountermodel}.lean`,
  `FormalSystem/Metalogic/StrongCompleteness.lean`
- New: `FormalSystem/Boneyard/` entries for the five retired `LimitMCSCoherence.lean` lemmas, with
  a README note naming the retirement reason

## Rollback/Contingency

Every phase is a separate commit and every phase leaves the tree green, so rollback is
`git revert` of the offending phase commit — no phase depends on a half-landed predecessor.

Group boundaries are the designed stopping points. If Group C proves harder than sized (most
likely at Phase 8, where the `TemporalSide` parameterization meets ~57 external call sites), the
task can close `[PARTIAL]` after Phase 6 with Groups A and B fully landed and green, and Group C
respawned as its own task — the `Filter`/`TemporalSide` work is independent of everything in
Groups A and B except Phase 1's coherence bundling.

If C2 diverges at any phase, stop immediately, do not re-baseline, and diagnose which proof
technique introduced the new axiom dependency (the most likely culprit is a `Classical` route
entering through the Mathlib `Filter` or `Ultrafilter` API in Phases 7-8).
