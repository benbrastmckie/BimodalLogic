# Blocker Analysis: Task #481

**Parent Task**: #481 - discharge_or_replace_unorderedsuccessorlabelclosed_residual
**Generated**: 2026-08-25
**Blocker**: Phase 6's terminus restatement (`universeClosedAt_signedUniverse_of_propositional`) is
not stateable because `UniverseClosedAt`'s clause 1 quantifies `ord` freely with no
`OrdTimesKnown b ord` available, while every existing route through the time coordinate depends on
that hypothesis; Phase 7 (non-vacuity) is blocked transitively because there is no Phase 6 terminus
to establish non-vacuity for.

## Root Cause

Category: **Design ambiguity / interface shape mismatch**, not a missing proof.

`UniverseClosedAt fc U`'s clause 1 is `∀ b ord tr, (∀ x ∈ b, x ∈ U) → ∀ nb ∈
unorderedSuccessorBranches …, ∀ x ∈ nb, x ∈ U`, with `ord` universally quantified and structurally
unconstrained. Task 481's Phase 5 composite
(`unorderedSuccessor_label_mem_of_propositional`/`unorderedSuccessor_confined_signedUniverse_of_propositional`)
closes the world coordinate unconditionally on a `boxFree` branch and closes the time coordinate via
`unorderedSuccessor_knownTimes_subset`, but that time-coordinate route is itself derived from
`applyRule_emitted_time_mem`, which requires `haux : OrdTimesKnown b ord` as a hypothesis.
`applyRule_emitted_time_mem_ordTimesKnown_needed` proves this hypothesis is **not removable in
general** — it exhibits a configuration in which dropping it makes the statement false. Since
Phase 5's composite has no way to supply `OrdTimesKnown b ord` at an arbitrary `ord`, it discharges
a strictly weaker statement than clause 1 demands, and `universeClosedAt_signedUniverse_of_propositional`
cannot be stated at all (not merely left unproved). Phase 6 was planned to route the terminus
restatement through that theorem, so Phase 6 is unreachable; Phase 7 (non-vacuity for the Phase 6
terminus) has no terminus to apply to and is blocked transitively.

Task 481's own report (`reports/01_unorderedsuccessorlabelclosed-verdict.md`) and summary
(`summaries/01_sharpen-replace-labelclosed-residual-summary.md`) both independently identify this as
a **shape mismatch that must be decided, not a proof gap that must be filled harder**, and both
converge on the same prescription: exactly one follow-up task, scoped to attempting the cheaper of
two routes (re-deriving `applyRule_emitted_time_mem` restricted to a fragment where the
`OrdTimesKnown` hypothesis may not be needed), and explicitly *not* attempting the more expensive
interface-redesign route unless and until the cheap route is decided one way or the other. The task
description embedding this analysis (below) already bakes in that scoping decision per the binding
constraints supplied to this analysis — there is no live ambiguity left to resolve here, only a
task to spawn.

## Proposed New Tasks

### New Item 1: Attempt Route 1 — restricted-rule re-derivation of `applyRule_emitted_time_mem` on the boxFree/untlSnceFree fragment
- **Effort**: 3-5 hours
- **Task Type**: lean4 (topic: decidability)
- **Rationale**: This is the single, user-decided next step to resolve the Phase 6/7 blocker on
  task 481. It attempts to remove the `OrdTimesKnown b ord` dependency from the time-coordinate
  route on the specific fragment task 481's Phase 3-5 work already operates on (`boxFree` +
  `untl`/`snce`-free branches), which — per task 481's own evidence — has structural reasons to
  believe `OrdTimesKnown` may not be needed there at all. If it succeeds, task 481's Phases 6 and 7
  become reachable as originally planned. If it fails, that negative result is itself the complete,
  valid deliverable, recorded as a C9 register amendment (preferring an amendment to one of the
  existing 24 entries over adding a 25th) naming precisely which rule on the fragment still needs
  `OrdTimesKnown` and why.
- **Depends on**: None

**Full description** (verbatim task text, for the return-file `description` field):

> Decide the `OrdTimesKnown`/`UniverseClosedAt` shape mismatch blocking task 481's Phases 6-7, by
> attempting Route 1 ONLY: a re-derivation of `applyRule_emitted_time_mem`
> (`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`) restricted to the
> rules reachable on a `boxFree` + `untl`/`snce`-free branch — the same fragment task 481's section
> D4 already operates on. Route 1 is the cheaper of the two available options and is currently
> unattempted.
>
> **Starting evidence for why Route 1 is believed cheap** (from task 481's Phase 5 "what is needed"
> analysis, to be verified rather than re-derived from scratch):
> - On this fragment, the **linearity stage** yields `.splitOrdered`, and hence there is **no
>   unordered successor at all** to reason about in that case.
> - The **seriality stage** emits at the trigger's own label, not a fresh one.
> - `orderTrichotomy`'s `fires` guard demands a `someFuture`-shaped formula already on the branch
>   (`someFuture φ = untl ⊤ φ`), which a `boxFree`/`untl`/`snce`-free branch structurally cannot
>   carry.
>
> Together these three observations suggest that on this restricted fragment, the case analysis
> `applyRule_emitted_time_mem` performs may never reach the branch that actually needs
> `OrdTimesKnown b ord` — but this has not been checked rule-by-rule and must be verified as real
> proof work, not assumed.
>
> **OUT OF SCOPE — do not start under this task**: Route 2, an `Ord`-flavoured `UniverseClosedAt`
> and `DifficultyBounded`, cascading through roughly twenty theorem restatements down to
> `buildTableauAt` (the `_at`, `_selfGuarded`, and `_fixed` families). This is an interface redesign
> and is explicitly deferred pending the outcome of Route 1. Do not begin any part of it as part of
> this task, even if Route 1 fails.
>
> **A negative result is a valid, complete deliverable.** If the restricted re-derivation cannot be
> made to work — i.e., if some rule reachable on the `boxFree`/`untl`/`snce`-free fragment genuinely
> still needs `OrdTimesKnown b ord` to prove `applyRule_emitted_time_mem`'s conclusion — record that
> finding with evidence (the specific rule, the specific configuration that requires the hypothesis,
> and why the fragment restriction does not exclude it) as a C9 register amendment. The C9 register
> in `MintBound.lean` currently stands at exactly 24 entries (task 481 amended entries 11 and 21 for
> the parent residual without adding a 25th); prefer amending an existing entry — most likely 11 or
> 21, or the D4 boundary block's own dedicated `/-! ### The boundary: why this section stops here
> -/` note — over adding a 25th entry. Do not treat "prove `applyRule_emitted_time_mem` restricted
> to this fragment" as the only acceptable outcome; a well-evidenced negative result closes this
> task exactly as completely as a positive one.
>
> **Success condition**: If Route 1 succeeds (the restricted re-derivation goes through without
> needing `OrdTimesKnown b ord`), continue by checking whether task 481's Phase 6
> (`universeClosedAt_signedUniverse_of_propositional` and the terminus restatement) and Phase 7
> (non-vacuity for that terminus) are now reachable as originally written in task 481's plan
> (`specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/plans/01_sharpen-replace-labelclosed-residual.md`).
> State explicitly, in this task's summary, whether Phases 6 and 7 are now reachable and, if so,
> whether landing them should happen as a resumption of task 481 or as a further follow-up task.
>
> **Context on recent file state — do not re-derive, and beware stale line numbers**:
> `MintBound.lean` is now approximately 14,100+ lines. Task 481 landed a section C11 refutation
> family and a section D4 (commit `ee0fe12a0`); task 462 (now completed) landed a section D5
> discharging `MintPaysForTimeFixed` at a nonempty universe under `¬ (FrameClass.Dense ≤ fc)`
> (commits `2dac7b35f`..`dc090921e`). Any line numbers cited in task 481's plan, report, or summary
> predate task 462's D5 insertion and must be re-located by declaration name, not by line number.
> Read task 481's plan `#### Reasoned Exclusions` table and section D4's boundary block, plus
> `reports/01_unorderedsuccessorlabelclosed-verdict.md` and
> `summaries/01_sharpen-replace-labelclosed-residual-summary.md`, before starting.
>
> **Acceptance criteria**: `lake build` green; no regression to any `check-module-invariants.sh`
> check currently passing; either (a) the restricted re-derivation of `applyRule_emitted_time_mem`
> is proved and Phase 6/7 reachability is explicitly assessed and stated, or (b) a negative result
> is recorded as a C9 register amendment naming the precise rule and configuration that still
> requires `OrdTimesKnown b ord` on this fragment.

## Dependency Reasoning

Only one task is proposed, so there is no internal dependency graph to reason about. This is
itself the correct minimal decomposition: the user's binding constraint (echoed from task 481's own
handoff) is explicit that this blocker requires "one follow-up task, not two" — attempting Route 2
in parallel or in sequence would either duplicate the interface-redesign cost before Route 1's
outcome is known, or violate the explicit sequencing ("Route 2 ... should not be started before
route 1 is decided") task 481 itself specifies. No File Footprint Overlap Check auto-dependency
applies either, since there is only one new task in `new_tasks[]`.

## After Completion

Once the new task is complete, resume the parent task #481 with `/implement 481` if Route 1
succeeded and Phases 6-7 are reachable as written; otherwise task 481 remains in a documented
blocked-with-evidence state (its Phase 6/7 blockers already recorded in its own plan and summary),
and no further resumption of task 481 is required unless a future task chooses to attempt Route 2.

The blocker will be resolved because: the new task directly targets the shape mismatch identified
as the blocker's root cause — either by closing it (enabling Phases 6-7) or by converting the
"unattempted, not refuted" status of Route 1 into a definitively evidenced negative result, which is
itself sufficient closure per task 481's own acceptance criteria (a C9 register entry is a valid,
complete deliverable).
