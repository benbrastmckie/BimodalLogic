# Implementation Summary: Task #703

- **Task**: 703 - lplus_compression_and_completeness
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-01T00:09:00Z (dispatch 40)
- **Completed**: not complete — **sub-phase 16.3 is COMPLETED** (the repaired forward conjunct of
  `TailStable`, implementing the user ruling of 2026-09-30). **Phase 17 is unblocked and remains
  NOT STARTED**; Phases 18-21 remain NOT STARTED. Dispatch 40 ended 2026-10-01T00:40:00Z
- **Effort**: ~35 minutes (dispatch 40, sub-phase 16.3)
- **Dependencies**: `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Stable`,
  `...PlusSlicedCertificate.Bridge`, `...PlusSlicedCertificate.FixtureStable` (all landed before
  this dispatch); no new external dependency
- **Artifacts**: plans/05_lplus-sliced-certificate-and-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Dispatch 40 implements the user's tail-stability ruling. `TailStable`'s forward conjunct is no
longer the raw reachability equation `Φ_fwd R₀ = R₀` — which sub-phase 16.2c refuted at a named
certificate, for every member of its re-presentation family — but the **liveness-filtered** transfer
`Φ_fwd R₀ ∩ R₀fwd = R₀`, where `R₀fwd` is the computed **forward**-live set at the right reference
time. The raw demand survives, unchanged and still decidable, as `TailStableRaw`, and every theorem
that was stated from it is now stated from that name instead of being deleted or weakened.

Both halves of the tail collapse survive the change with their statements intact. The `←` half needed
only the filtered equation's `⊇` half, iterated by monotonicity. The `→` half needed a genuinely new
ingredient, and it is the mathematical content of this dispatch: `mem_fwdLiveT_of_fwdLive_fold`, the
`FoldF`-general forward half of the bridge, which carries forward liveness from an arbitrarily far
right-tail time `G.NM + G.NF + k · G.NF` down to the reference time. That is what lets the induction
conclude that an arriving live position is in the filter, one period at a time, without the
functional equation the raw demand supplied.

The repair is also shown to address 16.2c's refutation rather than sidestep it:
`Fixture.not_mem_R₀fwd_pR` proves that the very witness which refuted the raw conjunct — reachable
from `R₀` in one period, occupied by no run down the right tail — is **not** in the filter, in every
member of the family.

**One conflict had to be resolved to do this work, and it is reported rather than papered over.**
Plan v8's Phase 17 heading records candidate 1 ("keep `TailStable` exactly as landed") as the user's
ruling. The user's recorded ruling says the opposite. See Decisions below.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Bridge.lean` — new `fwdVertFold` and
  its three facts (`fwdVertFold_mem_verts`, `fwdVertFold_mem_succT`, `foldF_fwdOrbit_fold`), the
  general `foldF_add_nat`, and the headline `mem_fwdLiveT_of_fwdLive_fold`: a position forward-live
  at any `s'` with `G.FoldF s s'` is in the computed forward fixpoint at the window time `s`. The
  landed `mem_fwdLiveT_of_fwdLive` keeps its statement and becomes the diagonal instance, so the
  ~45-line coinduction is written once rather than twice.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean` —
  `fwdLiveAt` / `mem_fwdLiveAt` / `fwdLiveAt_subset_posAt` / `liveAt_subset_fwdLiveAt`, `R₀fwd` and
  `R₀_subset_R₀fwd`; `foldF_head` (every `NM + NF + k·NF` is a `FoldF` of `NM + NF`);
  `nextTime_ge_right` (the forward wrap never leaves the right periodic region);
  `mem_R₀fwd_of_fwdLive_head`; `TailStableRaw` with `decidableTailStableRaw`; the repaired
  `TailStable` with `decidableTailStable`; `tailStable_of_raw` (the raw demand is strictly stronger);
  `R₀_subset_Φ_fwd_R₀`; `R₀_subset_iterFwd` (the one-sided replacement for `iterFwd_R₀`);
  `forall_mem_R₀_of_live_head` (the one-period induction) with `mem_R₀_of_live_head` as its
  corollary. `iterFwd_R₀`'s hypothesis becomes `TailStableRaw`, its body unchanged.
  `live_of_mem_R₀_head`'s proof changes by one line. `tailStable_iff_window`,
  `tailStable_iff_window_fwd`, `liveAt_tail_eq_L₀`, `liveAt_winLo_eq_L₀`, `mem_L₀_of_live_tail`,
  `iterBack_L₀` and every other landed declaration keep their statements.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FixtureStable.lean` — `not_tailStable`
  renamed to `not_tailStableRaw` (same proof, same content, about the demand that is still
  refuted); `not_tailStableRaw_cert` added; `not_tailStable_cert` keeps its statement, now proved
  from the backward conjunct, which the fixture still fails. New: `not_mem_lab_gd`,
  `not_mem_lab_ev` and `not_mem_R₀fwd_pR` — the witness of the raw refutation is forward-dead at
  the reference time, so the filter removes it. Module header records the ruling that settled the
  design question it escalated.
- `typst/generated/status.typ` — regenerated line counts (`typst-sync-check.sh --fix`), required by
  the repository's pre-commit gate.
- `specs/703_lplus_compression_and_completeness/plans/05_lplus-sliced-certificate-and-completeness.md`
  — sub-phase 16.3 record under Phase 16's heading; the correction block at Phase 17's heading; the
  Lean Challenge Statement's `TailStable` docstring amended; risk row R2b amended; the Phase 16
  `TailStable` checklist item annotated as altered.

## Decisions

- **The ruling implemented is option 2, the liveness-filtered transfer, and plan v8's candidate-1
  record is treated as a misattribution.** `.decisions.json`'s third entry, timestamped
  2026-09-30T19:31:18Z with provenance "`/orchestrate` batched ask_user relay (blocking)", selects
  option 2 and states "Options 1 (keep the narrowed class), 3 … and 4 … are NOT taken". Plan v8,
  committed 2026-10-01T00:00:04Z — **after** that entry was written, with no later entry appended —
  records candidate 1 as a user ruling of the same date. Dispatch 40's own context relayed the
  option-2 entry as settled, with instructions not to re-ask. The two records cannot both be the
  user's decision; the `.decisions.json` entry is the one with recorded provenance, the one that
  names its rejected alternatives, and the one this dispatch was handed. The most likely origin of
  the candidate-1 text is aux dispatch 39's blocker-research recommendation read as a ruling.
- **The change is made non-destructively, so that reverting it is a one-line swap.** `TailStableRaw`
  keeps the raw demand and `iterFwd_R₀` keeps its body; `Fixture.Φ_fwd_R₀_ne` and
  `Fixture.mem_Φ_fwd_R₀_pR` are untouched. If the user did mean candidate 1, nothing is lost:
  `TailStable := TailStableRaw` restores the previous class, and `not_tailStableRaw` is
  `not_tailStable` under a different name.
- **The filter is the computed FORWARD-live set, not `liveAt`.** The ruling's wording left the filter
  open ("intersected with a computed live set", with `Φ_fwd R₀ ∩ G.liveAt G.winHi' = R₀` as an
  example). The choice is not free, for two reasons now recorded in the Lean source: (i) `winHi ∉
  winTimes`, so `liveAt winHi = ∅` and that demand would force `R₀ = ∅`; (ii) the `→` half of the
  collapse needs "genuinely live far down the tail ⟹ in the filter", which is available for the
  forward half because `FoldF` relates the whole right tail to the reference time, and is available
  for no backward half at all, because `FoldB` relates only negative times.
- **`Fixture.not_tailStable` is renamed rather than weakened or deleted.** Its statement
  (`¬ (certRep a b c).TailStable`) is not provable under the repair and is not asserted in any
  weakened form; its content is preserved verbatim as `not_tailStableRaw`. This is the one landed
  name that does not survive, and it is the only one.
- **No claim is made that `(certRep a b c).TailStable` holds.** What is proved is that the filter
  removes the refutation's witness. Characterizing the fixture's whole `Φ_fwd R₀` is recorded as a
  follow-up, not claimed.

## Plan Deviations

- **Phase 16's `TailStable` checklist item** altered: the forward conjunct is now
  `Φ_fwd R₀ ∩ R₀fwd = R₀`; the conjunction the item names is kept as `TailStableRaw`. Annotated
  inline on the item and recorded in full in the sub-phase 16.3 record.
- **Phase 17 not started.** The dispatch's nominal target was Phase 17, but the ruling makes the
  `TailStable` repair a hard prerequisite: Phase 17 writes `Certifies` with `TailStable` as a
  structural conjunct, and writing it against the demand the user rejected would build Phases 18-21
  on it. The repair is landed, committed and green; Phase 17's Tasks list is executable verbatim and
  is left [NOT STARTED] rather than opened and abandoned half-done.
- **A plan-text correction was written at Phase 17's heading** rather than silently followed or
  silently overridden. This is prose in a plan, normally reviser territory; it is written here
  because the plan's Prohibited-workarounds bullet requires any `TailStable` redefinition to be
  recorded at Phase 16's heading and in the Lean Challenge Statement, and because the next dispatch
  reading only the candidate-1 paragraph would revert correct work.

## Verification

- Build: **Success**. Full `lake build` through the build guard, detached: 2798 jobs,
  `exit_status=0`, zero `error:` and zero `warning:` across both captured streams. The final scoped
  re-verification after the last style trim: 1231 jobs, `exit_status=0`, zero warnings. Tier 3
  checked: the `.olean` for each of `Bridge`, `Stable` and `FixtureStable` is newer than its source.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots; empty inventory).
- Vacuous count: **1, pre-existing and not a placeholder.** The single-line grep flags
  `FormalSystem/Examples/TemporalStructures.lean:495`
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial` — a true statement
  about the `Int` time domain whose proof happens to be `trivial`. The same count holds at main-tree
  `HEAD`, so this dispatch introduced nothing: no vacuous definition was added.
- Axiom count: **14, unchanged** (`grep -rn "^axiom "` over the resolved source roots; identical at
  main-tree `HEAD`). No new axiom.
- Tests: N/A — no test-suite change in scope; `lake build` covers `Tests/BimodalTest`.
- Files verified: Yes.
- Decidability confirmed by synthesis, not assertion: `example (G) : Decidable G.TailStable :=
  inferInstance` and the same for `TailStableRaw` both elaborate.
- Axiom dependencies **measured per declaration**, not inferred: a temporary `#print axioms` probe
  over the twelve declarations this dispatch added or re-proved —
  `mem_fwdLiveT_of_fwdLive_fold`, `TailStable`, `tailStable_of_raw`,
  `forall_mem_R₀_of_live_head`, `mem_R₀_of_live_head`, `live_of_mem_R₀_head`,
  `tailStable_iff_window_fwd`, `R₀_subset_iterFwd`, `mem_R₀fwd_of_fwdLive_head`,
  `Fixture.not_mem_R₀fwd_pR`, `Fixture.not_tailStableRaw`, `Fixture.not_tailStable_cert` —
  reports `[propext, Classical.choice, Quot.sound]` for all twelve, the three standard axioms and
  nothing else. The probe was removed and the subtree rebuilt green afterwards; the working tree is
  clean.

### Environment hazard found and worked around (report, not a side quest)

The dispatch worktree's hardlinked `.lake` carried a **mismatched olean/trace pair** for
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Timed`: the `.olean` predated the commit
that added `edge_congr`, `succP_congr`, `predP_congr`, `succT` and `predT`, while the `.trace`
claimed it current. Lake therefore treated the module as up to date and `Fold.lean` / `Computed.lean`
failed with "the environment does not contain `edge_congr`" on code **nobody had touched**. Two
further facts matter for whoever fixes this properly:

1. The same mismatched pair is present in the **main tree's** `.lake` (link count 2 on both files),
   so the next build in the main tree will hit it again. It was repaired only inside this worktree,
   by deleting the subtree's artifacts and rebuilding.
2. `lake-build-guard.sh` **replayed** the first failed result on the second invocation, so the
   deletion appeared to have had no effect. Diagnosis required `--no-share`. Every build in this
   dispatch after that point passes `--no-share`.

One diagnostic `lake build` of a single module was run outside the guard while isolating this; every
other `lake` invocation in this dispatch went through the guard, detached.

## Impacts

- **Phase 17 is unblocked and its Tasks list is unchanged.** `TailStable` is still one of the three
  structural conjuncts of `Certifies`, still decidable by a synthesized instance, still backed by a
  landed window biconditional. Nothing in Phase 17 reads the forward conjunct's internal shape.
- **Phase 19's relative completeness is unaffected in form** — it carries `hstab : G₀.TailStable` as
  a hypothesis — but the hypothesis is now **weaker**, so the theorem it will state is **stronger**:
  it quantifies over a larger class of certificates.
- **Phase 20's risk changes shape.** Its probe must now evaluate `Φ_fwd R₀ ∩ R₀fwd = R₀`, not
  `Φ_fwd R₀ = R₀`, and the evidence from `Fixture.not_mem_R₀fwd_pR` is that the filter removes
  exactly the kind of position that defeated the raw demand. Risk row R2b is amended accordingly;
  candidate 1 leaves the fallback menu, candidates 3 and 4 stay on it.
- **`mem_fwdLiveT_of_fwdLive_fold` is reusable beyond tail-stability.** Any later clause that must
  read computed forward liveness at a folded time — Phase 18's soundness pass through the bridge is
  the obvious consumer — can cite it instead of re-running the coinduction.
- A reviser pass is needed on plan v8's Phase 17 paragraph; the correction block says exactly what
  to rewrite.

## Follow-ups

- **Reviser**: rewrite plan v8's Phase 17 candidate-1 paragraph to record the option-2 ruling, and
  fold the dispatch-40 correction block into it. Plan v8's own revision record (lines 55-140) still
  describes four edits made on the candidate-1 premise.
- **Satisfiability of the repaired conjunct at the fixture** is open: `(certRep a b c).TailStable`
  for `b ≥ 1` would need `Φ_fwd R₀` characterized at the fixture (the backward conjunct's repair is
  only known to remove *its* witness, by `not_mem_L₀_pR`, which is explicitly not a proof that
  `Φ_fwd L₀ = L₀` holds). Worth one probe before Phase 20 rather than at it.
- **The main tree's stale `Timed` olean/trace pair** should be cleared (`rm` the two files and
  rebuild) before the next dispatch is provisioned from it, or every future worktree inherits the
  same failure.
- `iterFwd_R₀` now has no consumer inside the subtree. It is kept because it is the raw demand's
  content and the record of what the functional form bought; if Phase 21's audit wants it gone, that
  is a deliberate deletion, not a cleanup.

## References

- `specs/703_lplus_compression_and_completeness/plans/05_lplus-sliced-certificate-and-completeness.md`
  — sub-phase 16.3 record (Phase 16), the correction block (Phase 17), amended Lean Challenge
  Statement and risk row R2b
- `specs/703_lplus_compression_and_completeness/.decisions.json` — the option-2 ruling, entry 3
- `specs/703_lplus_compression_and_completeness/summaries/04_lplus-sliced-certificate-and-completeness-summary.md`
  — dispatches 21-38, including 16.2c's refutation
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean`,
  `.../Bridge.lean`, `.../FixtureStable.lean`
