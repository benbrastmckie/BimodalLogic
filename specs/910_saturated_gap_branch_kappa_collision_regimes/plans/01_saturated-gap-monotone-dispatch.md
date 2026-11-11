# Implementation Plan: Task #910

- **Task**: 910 - Dispatch or explicitly exclude the SATURATED-GAP third branch of `kappa_collision_regimes`, which neither landed cell inclusion addresses in either direction
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: 909 (landed: `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`)
- **Research Inputs**: None (no `research_artifact` on this dispatch; see "Why no research round" below)
- **Artifacts**: plans/01_saturated-gap-monotone-dispatch.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Split branch 3 of `kappa_collision_regimes` — the saturated-gap residue — into the part that can
be DISPATCHED with a genuine argument and the part that is EXPLICITLY EXCLUDED in the signature,
with nothing left tacit. The dispatched part is the MONOTONE residue: a collision whose register
displacement runs in the same direction as its countdown displacement. The excluded part is the
ANTITONE residue: countdown up with register down (or the mirror). Done means: a free-register
raise and the register-lowering deletion close the monotone residue in BOTH directions as cell
EQUALITY; the antitone residue is excluded by a named hypothesis visible in the schema's
quantifier, with its dichotomy against the monotone part and its own non-vacuity both COMPILED;
and the reserved name `cellLE_zero_const_of_kappa_eq` is still claimed by nothing.

The split is not a convenience. Both halves of it were compiled during this planning dispatch,
not argued — see "The arithmetic, compiled before it is scheduled" below.

### The arithmetic, compiled before it is scheduled

Three facts were established by running Lean during this dispatch (`lean_run_code`, zero
diagnostics in each case). They are the whole reason the plan has the shape it has.

**(1) The free-register raise's anchor clause closes exactly on the monotone side.** The landed
`exists_ladderPath_through_common_shifted_of_pend_past` rebuilds the register at the freed anchor
`exists_ladderPath_of_walk_nxt_at` with the anchor VALUE `nxtAt g z + m · (P + 1)`. That value is
not forced by the construction: `exists_ladderPath_of_walk_nxt_at` takes any `n₀ : ℕ` subject to
one clause, `|cntAt g₁ (v + 1) − n₀| ≤ |v − z|` at every pin `v`. On the raised path that clause
closes from four facts the landed proof already assembles — the pin-distance bound
(`hpin_far`: every pin lies beyond `z + cntAt g z + m · (P + 1)`), the pin identity
(`cntAt_eq_nxtAt_of_idle_pend`), the two-sided register Lipschitz bound
(`nxtAt_lipschitz_two_sided`) and the pending-forever gap — plus exactly two hypotheses on `n₀`:

    nxtAt g z ≤ n₀    and    n₀ ≤ cntAt g z + m · (P + 1)

Compiled form of the claim (`omega` discharges it from those facts alone):

```lean
example (X nz cz mP n₀ d : ℤ)
    (hX : 0 ≤ X) (hmP : 0 ≤ mP) (hn₀ : 0 ≤ n₀)
    (hfar : cz + mP < d) (hlip : (X - nz).natAbs ≤ d.natAbs)
    (hgap : nz + 2 ≤ cz) (hlo : nz ≤ n₀) (hhi : n₀ ≤ cz + mP) :
    (X - n₀).natAbs ≤ d.natAbs := by omega
```

So the UPWARD half of the residue needs no forward slack at all: the widened window pays for it.

**(2) The lower bound `nxtAt g z ≤ n₀` is NOT removable.** Dropping it makes the same clause
unprovable, with the arithmetic witness `X = 19, nz = 8, cz = 10, mP = 0, n₀ = 0, d = 11` — every
other fact satisfied, the clause violated. This is why the raise cannot reach the antitone side:
lowering the anchor costs in the UPPER direction of the clause, and on the raised path nothing
bounds the register at the far pin from above. Paying that cost would require a forward-slack
hypothesis at the LOWER pair, a hypothesis family no landed schema carries.

**(3) Both residue witnesses are real, at the parameters this plan pins.** `kappa 0 0 0 2 (2, 0)
= kappa 0 0 0 2 (4, 1)` and `kappa 0 0 0 2 (4, 2) = kappa 0 0 0 2 (6, 0)` both close by `decide`.
The first is MONOTONE (countdown `+2`, register `+1`) and is exactly the pair the task
description names as reached by no landed inclusion — so the dispatched half of this plan covers
the compiled witness the task cites. The second is ANTITONE (countdown `+2`, register `−2`),
satisfies the pending-forever gap and the threshold bound at both pairs, and is the excluded
half's own non-vacuity witness.

### What the two halves cost, and why the split is the whole of branch 3

The monotone residue closes in both directions from landed material:

* UPWARD, by fact (1): the landed raise `exists_ladderPath_through_shifted_of_pend_past` followed
  by a register re-lift at a FREE anchor `n₀ = n'`. No slack.
* DOWNWARD, by task 909's `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`
  at `n₀ := n` and `k := n' − n`, under forward slack at `m · (P + 1) + (n' − n)` and a room bound
  `n' + (n' − n) ≤ c`.

Those two amounts SPECIALIZE to both landed schemas, which is the evidence that the monotone
shape is the right generalization rather than a third sibling:

| Sub-regime | `n'` | room bound | slack amount | register |
|------------|------|------------|--------------|----------|
| equal register | `n` | `n ≤ c` (implied by the gap) | `m · (P + 1)` | `n` |
| common shift | `n + m · (P + 1)` | `n + (m · (P + 1) + m · (P + 1)) ≤ c` | `m · (P + 1) + m · (P + 1)` | `n + m · (P + 1)` |
| monotone residue | any `n'` with `n ≤ n'` | `n' + (n' − n) ≤ c` | `m · (P + 1) + (n' − n)` | `n'` |

Row 3 at `n' = n` is row 1 hypothesis for hypothesis; at `n' = n + m · (P + 1)` it is row 2
hypothesis for hypothesis. And the monotone/antitone dichotomy is exhaustive over collisions: the
countdown residue of `kappa_eq_components` puts `c' = c + m · (P + 1)` or `c = c' + m · (P + 1)`,
and trichotomy on `n` against `n'` leaves no third case. So every collision — branches 1, 2 and 3
of `kappa_collision_regimes` alike — is either dispatched by this plan's schema or falls in the
one named, compiled, non-vacuous excluded set. That is the task's "never leave it tacit"
requirement discharged structurally rather than by prose.

### Why no research round

This dispatch carries no `research_artifact`. The opening assessment was run and a research round
was NOT requested: the task description is a specification, not a research question — it names the
three-branch shape, the compiled refutations on both sides, the obstruction, and the two
admissible outcomes — and everything the plan needed beyond it was settled inside this dispatch by
direct reads of `LadderCell.lean`, `LadderChain.lean`, `CounterQuotient.lean`, `LadderAgree.lean`
and `RaySummary/README.md`, plus the three Lean runs recorded above. The anchor clause's exact
hypothesis set was measured, not guessed.

### Prior Plan Reference

No prior plan. `specs/910_saturated_gap_branch_kappa_collision_regimes/plans/` was empty at
authoring time.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no `roadmap_flag` was set, so no roadmap
phases are scheduled and `specs/ROADMAP.md` is not read or written by any phase.

## Goals & Non-Goals

**Goals**:
- `exists_ladderPath_through_free_register_shifted_of_pend_past` -- the landed regime-A raise with
  the target register FREE: the countdown raised by exactly `m · (P + 1)`, the object state and
  the realized stab-free type held, and the register delivered at any prescribed `n₀` between
  `nxtAt g z` and `cntAt g z + m · (P + 1)`.
- `free_register_anchor_clause_monotone_required` -- the compiled record that the lower bound
  `nxtAt g z ≤ n₀` is not removable, with its arithmetic witness.
- `cellAt_subset_of_free_register_shift_of_pend_past` -- the UPWARD cell inclusion on the monotone
  residue, with no forward-slack hypothesis.
- `mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact` -- the DOWNWARD cell membership on
  the witnessing path for the monotone residue.
- `cellAt_subset_of_free_register_shift_of_pend_past_rev` -- the same inclusion at the STATE level,
  under `ForwardSlackWitnessed` of the higher pair.
- `MonotoneCollisionDisplacement` -- the named displacement shape the dispatched half covers, and
  whose negation is the explicit exclusion.
- `kappa_collision_monotone_or_antitone` -- the dichotomy: every collision is monotone or antitone,
  with no third case.
- `kappa_collision_monotone_saturated_gap_nonvacuous` -- the monotone residue genuinely reaches
  branch 3: a collision inside the regime that is monotone, has unequal registers, and is not a
  common shift.
- `kappa_collision_antitone_residue_nonvacuous` -- the excluded set is non-empty inside the
  pending-forever regime above the threshold.
- `CellLEZeroConstOfKappaEqMonotoneForwardSlack` -- the depth-`0` cell-equality schema for the
  monotone residue, with the antitone exclusion stated in the signature.
- `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` -- that schema is a theorem at every
  parameter tuple `ParamsOk` admits.

**Non-Goals**:
- The reserved name `cellLE_zero_const_of_kappa_eq`. It stays reserved and claimed by nothing. The
  new schema is strictly stronger in hypotheses than the reserved statement and bears on its truth
  value in neither direction; no phase lands anything under the reserved name.
- The ANTITONE residue. It is excluded, by a hypothesis visible in the schema's quantifier, and the
  exclusion is evidenced by three compiled declarations rather than by prose. No phase claims it is
  unreachable: the route it would need — forward-slack witnessing at the LOWER pair, to pay the
  upper direction of the anchor clause that fact (2) above measures — is NAMED in the final phase's
  record and claimed in neither direction.
- Retiring `CellLEZeroConstOfKappaEqForwardSlack` or
  `CellLEZeroConstOfKappaEqCommonShiftForwardSlack`. Both are landed, both have pinned statements,
  and the new schema subsumes them only in the sense that its hypotheses specialize to theirs. The
  subsumption is recorded in docstrings; no landed schema's signature is touched.
- `docs/theorem-index.md`. It carries no row for any `LadderCell.lean` declaration (confirmed by
  grep at authoring time), C15 anchors rows by declaration NAME rather than by line number, and the
  file is declared territory of concurrent sibling task 895. No phase reads or writes it.
- `LadderChain.lean` and `LadderPump.lean`. Every construction here is a reading of landed
  path-level material with the register's anchor moved, which `LadderCell.lean`'s own module
  contract already admits; no new path-level assembly is needed. `LadderPump.lean` is declared
  territory of concurrent sibling task 911.
- Any `(K1)` amendment, any change to the parameter contract, and any re-opening of the
  spanning-block device.
- Weakening `HasForwardSlack` or stating any state-level per-path register regime. Refuted by
  `ClimbWitness.hasForwardSlack_refuted_unconditional`.

## Decisions

- **Every new declaration lands in `LadderCell.lean`.** The module contract reads: "every
  construction here is a reading of the landed regime-A assembly
  `exists_ladderPath_through_shifted_of_pend_past` with the register's anchor moved, or of the
  landed class destructors". The free-register raise is exactly the first of those, and the three
  arithmetic records are readings of the destructors. Nothing here consumes a pump or a pin beyond
  what `LadderChain.lean` already landed, so no new file is opened and the task's declared
  `file_scope` is unchanged apart from the generated surfaces every Lean edit drags in.
- **The exclusion is stated as a POSITIVE hypothesis, and made non-tacit by three compiled
  records.** The schema takes `MonotoneCollisionDisplacement P c n c' n'` as a named hypothesis
  rather than carrying a negated side condition. On its own that would be a tacit exclusion of the
  complement, which the task forbids; so the complement is named and closed by
  `kappa_collision_monotone_or_antitone` (it is exactly the other side of a dichotomy, not a gap in
  a case split), inhabited by `kappa_collision_antitone_residue_nonvacuous`, and separated from the
  landed coverage by `kappa_collision_monotone_saturated_gap_nonvacuous`. The three together are
  what make the exclusion visible rather than implied.
- **The higher pair's gap `n' + 2 ≤ c + m · (P + 1)` is carried explicitly, not derived.** The
  landed common-shift statements derive their `pend_past_of_nxtAt_lt` input from the lower pair's
  gap because the register displacement there equals the countdown displacement. With a free
  register that derivation fails at `m = 0`, so both gaps are named hypotheses on the cell-level
  statements. At the schema level the higher gap is already a hypothesis, so nothing is added to a
  consumer's burden.
- **`n' ≤ c + m · (P + 1)` is a hypothesis of the raw inclusion and derived inside the schema.**
  It is needed for the anchor clause (fact (1)) but follows from `n' + 2 ≤ c'` once the schema has
  the higher pair's gap, so it does not appear in the schema's quantifier.
- **Phase 2 is contingent and nothing depends on it.** Retiring the landed common-shift raise to
  the `n₀ := nxtAt g z + m · (P + 1)` instance of Phase 1 is a diff-reduction, not a deliverable.
  It is non-circular by construction — Phase 1 is proved from
  `exists_ladderPath_through_shifted_of_pend_past` and `exists_ladderPath_of_walk_nxt_at` directly,
  not from the common-shift theorem — but if the instance does not reduce hypothesis for
  hypothesis, the landed proof is left exactly as it stands.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 1's pinned signature carries the wrong bound on `n₀`, making it unprovable as written | H | L | The exact fact set and both bounds were COMPILED during this planning dispatch (see "The arithmetic, compiled before it is scheduled", facts (1) and (2)), not derived on paper. If the Lean-level assembly nevertheless fails, `plan-compliance.md` forbids substituting a weaker same-named statement: mark the phase `[BLOCKED]`, record which `omega` goal failed and by how much, and escalate for a `/revise`. |
| A pinned witness pair does not collide at the stated parameters | H | L | Both `decide` goals were run at plan time with zero diagnostics (fact (3)). Phase 5 re-runs them as its own verification rather than trusting this note. |
| Phase 2's instance does not recover the landed common-shift statement, so the retirement cannot close | L | M | Phase 2 is explicitly contingent with a stated fallback (leave the landed proof untouched, record the duplication, close `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record). No later phase depends on it. |
| The pre-commit hook refuses the first Lean-touching commit because `typst/generated/status.typ` drifted | M | H | Surface (b) of `plan-authoring-gate-collisions.md` Condition 1 is BLOCKING and cannot be deferred. Every Lean-touching phase (1-7) runs `bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in its own commit, and carries that path in its own `Files to modify`. |
| A concurrent sibling's Lean edit moves the same generated surfaces (`typst/generated/status.typ`, `README.md`, `FormalSystem/Metalogic/README.md`) | M | M | The dispatch's territory block names tasks 895 and 911 as scheduled this cycle; 895's declared scope includes `FormalSystem/Metalogic/*.lean`, whose line counts feed the same generated blocks. Per `context/contracts/territory.md`: re-read each generated file immediately before editing it, stage only this task's own hunks (explicit file lists, never a directory or glob add), never run `git-snapshot.sh` in its reverting default mode, and if a foreign commit or foreign uncommitted modification appears, STOP and report rather than proceeding. A count disagreement caused by a sibling's uncommitted `.lean` file is the one legitimate `--no-verify` case the pre-commit hook itself documents, and is reported rather than used silently. |
| A `verify-deploy.sh` gate is red for reasons unrelated to this task (the dispatch context reports the deployed `.claude/` tree STALE for core, lean, literature, memory and typst) | M | H | Condition 2 of `plan-authoring-gate-collisions.md`: the final phase's criterion is phrased to distinguish findings naming this task's own touched files from the tree's standing baseline, never as a bare "the gate passes". The staleness is pre-existing and is NOT remedied by this task; no phase hand-patches anything under `.claude/**`. |
| An unused-binder linter fires on the schema's unconsumed collision hypothesis | L | M | The collision hypothesis is discarded at `intro` with a `-` pattern rather than bound to a name, exactly as `cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack` already does, so no unused local is created. If the environment linter fires anyway, the remedy is a hand-added row in `scripts/nolints.json`, never `lake exe runLinter --update`. |
| The new schema is read as retiring or superseding the two landed schemas | M | M | Phase 6's docstring states the specialization table above explicitly and says that neither landed schema is retired and neither signature is touched; Phase 7's README edit repeats the boundary. |
| The antitone exclusion is read as a claim that the antitone residue is unreachable | M | M | Phase 7's record names the route it would need (forward-slack witnessing at the LOWER pair, to pay the upper anchor direction fact (2) measures) and claims it in neither direction — the same "named rather than claimed" form `RaySummary/README.md` already uses for its open routes. |
| Line-count drift leaves the module-inventory blocks stale (surface (a)) | L | H | Final phase deliverable: edit the Description cells first, then `bash scripts/check-module-invariants.sh --emit-inventory` (which preserves existing Description text and refreshes only the counts), then `--emit-inventory --check`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1 |
| 4 | 4 | 1 |
| 5 | 5 | 1 |
| 6 | 6 | 3, 4, 5 |
| 7 | 7 | 2, 6 |

Phases within the same wave can execute in parallel. This plan is nevertheless executed
SEQUENTIALLY in phase order: every phase edits the same module and stages the same generated
`typst/generated/status.typ`, so two phases running concurrently would collide on that one
blocking pre-commit surface even where their logical dependencies permit parallelism. The wave
table records the logical dependency structure; the serialization is a generated-file constraint,
not a logical one.

### Phase 1: The Free-Register Raise [COMPLETED]

**Goal**: `exists_ladderPath_through_free_register_shifted_of_pend_past` and
`free_register_anchor_clause_monotone_required` compile in a new `section FreeRegister` of
`LadderCell.lean`, immediately after `section CommonShift`.

**Tasks**:
- [ ] Add `section FreeRegister` after `end CommonShift`, with the same `variable` block
      `{Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}` the
      common-shift section uses.
- [ ] Add `exists_ladderPath_through_free_register_shifted_of_pend_past` at the signature pinned in
      `## Lean Challenge Statements` below.
- [ ] Build the proof as the landed `exists_ladderPath_through_common_shifted_of_pend_past` spine
      with exactly one change: the anchor VALUE passed to `exists_ladderPath_of_walk_nxt_at` is
      `n₀` in place of `nxtAt g z + m * (P + 1)`, and the `hn₀` step closes by `omega` from
      `hpin_far`, `cntAt_eq_nxtAt_of_idle_pend`, `nxtAt_lipschitz_two_sided`, `hgap`, `hlo` and
      `hhi` — the six facts fact (1) of the Overview compiles. Reuse the landed `hw`/`hidle`/`hpp`/
      `hpi`/`hpins` block and the closing `tpOf_stabFree_eq_of_objAt_eq` step unchanged.
- [ ] Add `free_register_anchor_clause_monotone_required` at the pinned signature, with the witness
      `19, 8, 10, 0, 0, 11` (compiled at plan time) and a docstring naming the correspondence:
      `X ↔ nxtAt g₁ v`, `nz ↔ nxtAt g z`, `cz ↔ cntAt g z`, `mP ↔ m · (P + 1)`, `d ↔ v − z`.
- [ ] Write both docstrings in the module's established voice: for the assembly, name the one
      changed step, say that the lower bound is what the Lipschitz direction needs and the upper
      bound what the pin distance needs, and name `n₀ := nxtAt g z + m · (P + 1)` as recovering the
      common-shift assembly; for the record, say which direction of the clause fails and that
      paying it would require a forward-slack hypothesis at the lower pair.
- [ ] Scoped `lake build`, then `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` with the Lean change in one commit.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly TWO new declarations and one new section header, and
modifies no existing declaration's signature or body; confirm at implementation time with
`git diff --stat` on the module plus a `git diff` read-through showing only additions between
`end CommonShift` and the `/-! ## The collision case split -/` header.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths
(no shell suite covers a `.lean` or generated-`typst` path), so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module this phase edits with no externally visible signature change.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - new `section FreeRegister` with two new declarations
- `typst/generated/status.typ` - regenerated line counts; blocking pre-commit surface, staged in this phase's own commit

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`
  exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_through_free_register_shifted_of_pend_past`
  reports no `sorryAx` and no custom axiom beyond the module's own recorded profile.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 2: Retire the Common-Shift Raise to Its Instance (CONTINGENT) [NOT STARTED]

**Goal**: `exists_ladderPath_through_common_shifted_of_pend_past` keeps its signature
byte-for-byte and gets a one-line proof body: the `n₀ := nxtAt g z + m * (P + 1)` instance of
Phase 1's assembly. If that instance does not reduce exactly, the landed proof is left untouched.

**Tasks**:
- [ ] Attempt the instance: `n₀ := nxtAt g z + m * (P + 1)`, with `hlo` by `omega` and `hhi` by
      `omega` from `hgap`. Check that the instantiated conclusion's `nxtAt g' z = n₀` clause is
      syntactically the landed `nxtAt g' z = nxtAt g z + m * (P + 1)`.
- [ ] If it reduces: replace the proof body, leaving every signature line untouched, and note in
      the docstring that the statement is now the free-register assembly's instance.
- [ ] If it does not reduce: STOP. Leave the landed declaration exactly as it stands, close this
      phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record naming the
      specific clause that failed to reduce and the goal state observed, and proceed to Phase 3. Do
      NOT alter the landed signature to make the instance fit — that is the
      same-name-different-signature drift `plan-compliance.md`'s Statement Fidelity section
      forbids.
- [ ] Either way: scoped `lake build`, then `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` with the Lean change if any Lean line moved.

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the landed theorem's signature is unchanged by this phase; confirm with
`git diff` on `LadderCell.lean` showing changed lines strictly below the landed `:= by` line and
none within its binder list or conclusion.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths,
so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which covers a proof-body-only change whose signature is verified unchanged by the `git diff`
above.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - proof body of `exists_ladderPath_through_common_shifted_of_pend_past` only; this declaration exists at authoring time (confirmed by read at lines 107-172) — if it has moved or been renamed by the time this phase runs, treat the phase as `[BLOCKED]` and escalate rather than relocating the edit
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- The scoped `lake build` above exits 0.
- `git diff` on the module confirms the landed signature lines are unchanged.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check` is run and its verdict recorded; per
  `plan-compliance.md` the verdict is ADVISORY — a drift finding is investigated, never treated as
  an automatic failure.

---

### Phase 3: The Upward Cell Inclusion on the Monotone Residue [NOT STARTED]

**Goal**: `cellAt_subset_of_free_register_shift_of_pend_past` compiles in `section FreeRegister`:
in the pending-forever regime at countdown at least `Tc`, the cell at `(q, c, n)` is contained in
the cell at `(q, c + m · (P + 1), n')` for every `n'` with `n ≤ n' ≤ c + m · (P + 1)`. No
forward-slack hypothesis.

**Tasks**:
- [ ] Add the declaration after Phase 1's assembly, at the signature pinned in
      `## Lean Challenge Statements` below.
- [ ] Build the proof as the landed `cellAt_subset_of_common_shift_of_pend_past` body with the
      target register `n'` in place of `n + m * (P + 1)`: the same `hoz`/`hcz`/`hnz`/`hz`/`hpast`
      preamble, Phase 1's assembly in place of the common-shift one with `hlo` and `hhi` rewritten
      through `hnz` and `hcz`, and the same `Subtype.ext` / `mem_cellAt_ladder_iff` closing.
- [ ] Write the docstring: name the sub-regime (the register moves UP by an amount the countdown
      need not match), say that this is the first cell inclusion to reach branch 3 of
      `kappa_collision_regimes`, and state that no forward slack is consumed because the widened
      window pays for the anchor.
- [ ] Scoped `lake build`, then `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` with the Lean change in one commit.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly ONE new declaration and modifies no existing
declaration; confirm with `git diff --stat` on the module and a `git diff` read-through.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths,
so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module this purely additive declaration lands in.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - one new declaration in `section FreeRegister`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- The scoped `lake build` above exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_free_register_shift_of_pend_past`
  reports no `sorryAx` and no custom axiom.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 4: The Downward Half on the Monotone Residue [NOT STARTED]

**Goal**: `mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact` (path level) and
`cellAt_subset_of_free_register_shift_of_pend_past_rev` (state level, under
`ForwardSlackWitnessed`) compile in `section FreeRegister`.

**Tasks**:
- [ ] Add the path-level membership at the signature pinned in `## Lean Challenge Statements`
      below, immediately after Phase 3's inclusion.
- [ ] Build its proof as the landed `mem_cellAt_of_common_shift_of_hasForwardSlack_exact` body with
      the 909 deletion called at `n₀ := n` and `k := n' - n` in place of `k := m * (P + 1)`: `hk`
      closes by `omega` from `hlo` and `hnz`, `hTc` from `hTc` and `hcz`, the deletion's own gap
      from `hroom` and `hcz`/`hnz`, and `hslack` by rewriting `hnz`. The `pend_past_of_nxtAt_lt`
      input is `hgap'` rather than a consequence of `hgap` — this is the one place the free
      register costs a named hypothesis the common-shift statement did not need.
- [ ] Add the state-level inclusion at its pinned signature; its body is the path-level theorem
      applied to the witnessing path `hw` supplies, exactly as
      `cellAt_subset_of_common_shift_of_pend_past_rev`'s is.
- [ ] Write both docstrings: name the slack amount `m · (P + 1) + (n' − n)` and the room bound
      `n' + (n' − n) ≤ c` and show the two specializations in the Overview's table (equal register
      at `n' = n`, common shift at `n' = n + m · (P + 1)`); state that the regime stays a property
      of the PATH for the compiled reason
      `ClimbWitness.hasForwardSlack_refuted_unconditional` gives; state that neither `hgap`,
      `hgap'` nor `hroom` implies another.
- [ ] Scoped `lake build`, then `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` with the Lean change in one commit.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly TWO new declarations and modifies no existing
declaration; confirm with `git diff --stat` on the module and a `git diff` read-through.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths,
so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module these two purely additive declarations land in.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - two new declarations in `section FreeRegister`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- The scoped `lake build` above exits 0 with no `sorry` and no error.
- `lean_verify` on both
  `FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact`
  and
  `FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_free_register_shift_of_pend_past_rev`
  reports no `sorryAx` and no custom axiom.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 5: The Displacement Dichotomy and Its Two Non-Vacuity Records [NOT STARTED]

**Goal**: `MonotoneCollisionDisplacement`, `kappa_collision_monotone_or_antitone`,
`kappa_collision_monotone_saturated_gap_nonvacuous` and
`kappa_collision_antitone_residue_nonvacuous` compile in `section Collision` of
`LadderCell.lean`, after `kappa_collision_two_regimes_refuted_of_pend_gap`.

**Tasks**:
- [ ] Add `MonotoneCollisionDisplacement` at the pinned definition, with a docstring saying that
      it covers branch 1 and branch 2 of `kappa_collision_regimes` entire plus the monotone slice
      of branch 3, and that its negation is the exclusion the schema below carries.
- [ ] Add `kappa_collision_monotone_or_antitone`: from `kappa_eq_components`' countdown residue
      (`Nat.modEq_iff_dvd'` in both orientations, as `kappa_collision_regimes` already does) plus
      `lt_trichotomy` on `n` against `n'`. No `2 ≤ B` hypothesis — the residue congruence does not
      consume it; confirm that at implementation time rather than adding an unused binder.
- [ ] Add `kappa_collision_monotone_saturated_gap_nonvacuous` with the witness
      `Tc = Tn = P = 0`, `B = 2`, `(c, n) = (2, 0)`, `(c', n') = (4, 1)`: the collision by `decide`,
      the monotone displacement at `m = 2`, the register inequality `0 ≠ 1`, and the
      not-a-common-shift conjunct by `rintro` plus `omega`.
- [ ] Add `kappa_collision_antitone_residue_nonvacuous` with the witness `Tc = Tn = P = 0`,
      `B = 2`, `(c, n) = (4, 2)`, `(c', n') = (6, 0)`: the collision by `decide`, both gaps and both
      thresholds by `omega`, and the negated monotone displacement by `rintro` plus `omega`.
- [ ] Write the docstrings in the module's established refutation voice: for each witness, say
      which coordinates are pinned, that the registers differ, and what the pair shows — the first
      that the dispatched half genuinely reaches branch 3 (no landed inclusion applies to `(2, 0)`
      against `(4, 1)`), the second that the excluded half is non-empty inside the regime.
- [ ] Scoped `lake build`, then `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` with the Lean change in one commit.

**Timing**: 1 hour 30 minutes

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly FOUR new declarations (one `def`, three `theorem`s),
all inside `section Collision`, and modifies no existing declaration; confirm with
`git diff --stat` on the module and a `git diff` read-through. The two witness pairs were compiled
at plan time (`decide`, zero diagnostics) — re-run both as this phase's own verification rather
than trusting the plan's note.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths,
so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module these four purely additive arithmetic declarations land in.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - four new declarations in `section Collision`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- The scoped `lake build` above exits 0 with no `sorry` and no error.
- `lean_verify` on all four new names reports no `sorryAx` and no custom axiom.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 6: The Monotone Cell-Equality Schema [NOT STARTED]

**Goal**: `CellLEZeroConstOfKappaEqMonotoneForwardSlack` and
`cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` compile in `section ForwardSlack` of
`LadderCell.lean`, after `cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack`.

**Tasks**:
- [ ] Add the schema `def` at the pinned definition, with the antitone exclusion carried as the
      named hypothesis `MonotoneCollisionDisplacement P c n c' n'`.
- [ ] Add its theorem: `intro` the hypotheses, discarding the collision equality with a `-` pattern
      (it is retained as a binder for shape parity with the two landed schemas and is not
      consumed); `rcases` the displacement; in each direction derive
      `n' ≤ c + m * (P + 1)` from the higher pair's gap by `omega` and close with
      `Set.Subset.antisymm` against Phase 3's upward inclusion and Phase 4's state-level downward
      inclusion.
- [ ] Write the docstring: enumerate the hypotheses that separate this schema from the reserved
      statement; give the three-row specialization table from the Overview showing that its
      hypotheses specialize to BOTH landed schemas'; say explicitly that neither landed schema is
      retired and neither signature is touched; and state the exclusion — the ANTITONE residue,
      named by the negation of the hypothesis, exhaustive by
      `kappa_collision_monotone_or_antitone`, non-empty by
      `kappa_collision_antitone_residue_nonvacuous`, and not reached in either direction.
- [ ] Record in the same docstring that the schema is strictly stronger in hypotheses than
      `CellLEZeroConstOfKappaEq` and therefore bears on the reserved statement's truth value in
      neither direction, and that `cellLE_zero_const_of_kappa_eq` is claimed by nothing here.
- [ ] Scoped `lake build`, then `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` with the Lean change in one commit.

**Timing**: 1 hour 30 minutes

**Depends on**: 3, 4, 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly TWO new declarations (one `def`, one `theorem`) in
`section ForwardSlack` and modifies no existing declaration; confirm with `git diff --stat` on the
module and a `git diff` read-through.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths,
so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module these two purely additive declarations land in.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - two new declarations in `section ForwardSlack`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- The scoped `lake build` above exits 0 with no `sorry` and no error.
- `lean_verify` on both
  `FormalSystem.Metalogic.Decidability.RaySummary.CellLEZeroConstOfKappaEqMonotoneForwardSlack`
  and
  `FormalSystem.Metalogic.Decidability.RaySummary.cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack`
  reports no `sorryAx` and no custom axiom.
- `grep -rn "cellLE_zero_const_of_kappa_eq\b" FormalSystem/` confirms the reserved name is still
  declared by nothing (it appears only inside docstrings).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 7: Records, Generated Surfaces and Full Verification [NOT STARTED]

**Goal**: the module docstring and `RaySummary/README.md` record the four-part layer, the
dispatched monotone residue, the named antitone exclusion and the route the exclusion leaves open;
every generated surface is reconciled; the full gate set is run and every finding is attributed.

**Tasks**:
- [ ] Amend `LadderCell.lean`'s module docstring: the layer now has FOUR parts, not three — add the
      FREE-REGISTER RAISE part naming the assembly, the two cell inclusions, the two bounds on `n₀`
      and the compiled necessity record; amend the COLLISION CASE SPLIT part to say that branch 3
      is now split into a dispatched monotone slice and an excluded antitone one, naming the
      dichotomy and both non-vacuity records; amend the FORWARD-SLACK part to add the third schema
      and its specialization to the two landed ones. Keep the standing sentence that the reserved
      name `cellLE_zero_const_of_kappa_eq` is claimed by nothing in the module.
- [ ] Amend `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: extend the
      `LadderCell.lean` Description cell with the new declarations, and amend the
      "The EQUAL-REGISTER hypothesis is carried for a compiled reason" paragraph and the
      "What it buys" paragraph so that neither still asserts that the saturated residue is reached
      by nothing — the monotone slice now is. State the antitone exclusion and name, without
      claiming, the route it would need: forward-slack witnessing at the LOWER pair, to pay the
      upper direction of the anchor clause that
      `free_register_anchor_clause_monotone_required` compiles as failing. This paragraph exists at
      authoring time (confirmed by read at lines 1095-1140) — if it has been rewritten by the time
      this phase runs, extend whatever paragraph then carries the saturated-residue claim rather
      than inventing a new section.
- [ ] Regenerate surface (a): edit the Description cells first, then
      `bash scripts/check-module-invariants.sh --emit-inventory`, then
      `--emit-inventory --check`.
- [ ] `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.
- [ ] Full-project build and the full gate set; attribute every finding.

**Timing**: 1 hour 30 minutes

**Depends on**: 2, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the generated surfaces this phase may reconcile are at most
`README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
`FormalSystem/Metalogic/Decidability/RaySummary/README.md` and `typst/generated/status.typ` —
the ancestor-chain generated-inventory READMEs `plan-file-scope-harvest.sh` appends for a
`LadderCell.lean` edit, run against this plan at authoring time. Only four of the five moved in
this task's immediate predecessor's phase-closing commit (`FormalSystem/README.md` did not), so
the fifth is declared but may legitimately come back unchanged. Confirm at implementation time
from `--emit-inventory`'s own report of which blocks it rewrote, and stage only the files it
actually changed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - module docstring amended to four parts
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - `LadderCell.lean` Description cell extended; the saturated-residue and "what it buys" paragraphs amended
- `README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block if `--emit-inventory` moves it; staged only if it actually changed
- `FormalSystem/Metalogic/README.md` - regenerated inventory block
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project) exits 0
  with no `sorry` and no error.
- `bash scripts/check-module-invariants.sh` exits 0 (C1 build, C2 axiom baselines, inventory and
  doc-count checks), and `--emit-inventory --check` exits 0.
- `bash scripts/typst-sync-check.sh` exits 0.
- `bash .claude/scripts/lean-sorry-census.sh` shows no new `sorry` attributable to this task.
- `grep -rn "cellLE_zero_const_of_kappa_eq\b" FormalSystem/` shows the reserved name declared by
  nothing.
- `bash .claude/scripts/verify-deploy.sh` is run as the complete gate set for this phase's `full`
  tier. Because the gate set runs against the whole deploy tree and the dispatch context reports
  that tree STALE for the core, lean, literature, memory and typst extensions, the criterion is:
  every finding is attributed, and NO finding names a file this task touched. A pre-existing
  finding attributable to the recorded staleness is recorded as baseline and is NOT hand-patched
  under `.claude/**`.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

set_option autoImplicit false

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

theorem exists_ladderPath_through_free_register_shifted_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hgap : nxtAt g z + 2 ≤ cntAt g z) (hTc : Tc ≤ cntAt g z) (m : ℕ) (n₀ : ℕ)
    (hlo : nxtAt g z ≤ n₀) (hhi : n₀ ≤ cntAt g z + m * (P + 1)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z + m * (P + 1) ∧
      nxtAt g' z = n₀ ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry

theorem free_register_anchor_clause_monotone_required :
    ¬ ∀ X nz cz mP n₀ d : ℤ, 0 ≤ X → 0 ≤ mP → 0 ≤ n₀ →
        cz + mP < d → (X - nz).natAbs ≤ d.natAbs → nz + 2 ≤ cz →
        n₀ ≤ cz + mP → (X - n₀).natAbs ≤ d.natAbs := sorry

theorem cellAt_subset_of_free_register_shift_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (hlo : n ≤ n') (hhi : n' ≤ c + m * (P + 1)) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

theorem mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hgap' : n' + 2 ≤ c + m * (P + 1)) (hlo : n ≤ n')
    (hroom : n' + (n' - n) ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n'), h'⟩)
    (hslack : HasForwardSlack g z (m * (P + 1) + (n' - n)) n')
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

theorem cellAt_subset_of_free_register_shift_of_pend_past_rev
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hgap' : n' + 2 ≤ c + m * (P + 1)) (hlo : n ≤ n')
    (hroom : n' + (n' - n) ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c + m * (P + 1), n'), h'⟩ : LadderState Q pend) z
      (m * (P + 1) + (n' - n)) n') :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

def MonotoneCollisionDisplacement (P c n c' n' : ℕ) : Prop :=
  (∃ m : ℕ, c' = c + m * (P + 1) ∧ n ≤ n') ∨ (∃ m : ℕ, c = c' + m * (P + 1) ∧ n' ≤ n)

theorem kappa_collision_monotone_or_antitone (Tc Tn P B c n c' n' : ℕ)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    MonotoneCollisionDisplacement P c n c' n' ∨
      ((∃ m : ℕ, c' = c + m * (P + 1) ∧ n' < n) ∨
        (∃ m : ℕ, c = c' + m * (P + 1) ∧ n < n')) := sorry

theorem kappa_collision_monotone_saturated_gap_nonvacuous :
    ∃ Tc Tn P B c n c' n' : ℕ, 2 ≤ B ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      n + 2 ≤ c ∧ n' + 2 ≤ c' ∧ Tc ≤ c ∧ Tc ≤ c' ∧
      MonotoneCollisionDisplacement P c n c' n' ∧ n ≠ n' ∧
      ¬ ∃ m : ℕ, (c' = c + m * (P + 1) ∧ n' = n + m * (P + 1)) ∨
        (c = c' + m * (P + 1) ∧ n = n' + m * (P + 1)) := sorry

theorem kappa_collision_antitone_residue_nonvacuous :
    ∃ Tc Tn P B c n c' n' : ℕ, 2 ≤ B ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      n + 2 ≤ c ∧ n' + 2 ≤ c' ∧ Tc ≤ c ∧ Tc ≤ c' ∧
      ¬ MonotoneCollisionDisplacement P c n c' n' := sorry

def CellLEZeroConstOfKappaEqMonotoneForwardSlack {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (z : ℤ),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      MonotoneCollisionDisplacement P c n c' n' →
      n + 2 ≤ c → n' + 2 ≤ c' → Tc ≤ c → Tc ≤ c' →
      (∀ m : ℕ, c' = c + m * (P + 1) → n ≤ n' →
        n' + (n' - n) ≤ c ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c', n'), h'⟩ : LadderState Q pend) z (m * (P + 1) + (n' - n)) n') →
      (∀ m : ℕ, c = c' + m * (P + 1) → n' ≤ n →
        n + (n - n') ≤ c' ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c, n), h⟩ : LadderState Q pend) z (m * (P + 1) + (n - n')) n) →
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        = cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

theorem cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
    CellLEZeroConstOfKappaEqMonotoneForwardSlack step pend fwd bwd lab φ Tc Tn P B := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] Scoped `lake build` green on `...RaySummary.LadderCell` after each of Phases 1-6.
- [ ] Full-project `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` green
      at Phase 7.
- [ ] `lean_verify` reports no `sorryAx` and no custom axiom on all eleven new declarations.
- [ ] Both witness pairs re-confirmed by `decide` inside Phase 5's own declarations, not by
      reference to this plan's note.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 at Phase 7, and
      `--emit-inventory --check` exits 0.
- [ ] `bash scripts/typst-sync-check.sh --counts-only` exits 0 before every Lean-touching commit;
      the full `bash scripts/typst-sync-check.sh` exits 0 at Phase 7.
- [ ] `bash .claude/scripts/lean-sorry-census.sh` shows no new `sorry` attributable to this task.
- [ ] `grep -rn "cellLE_zero_const_of_kappa_eq\b" FormalSystem/` shows the reserved name declared
      by nothing.
- [ ] `bash .claude/scripts/verify-deploy.sh` run at Phase 7 with every finding attributed and none
      naming a file this task touched.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — eleven new declarations (the
  free-register raise and its necessity record; the upward inclusion; the path-level and
  state-level downward halves; the displacement predicate, the dichotomy and two non-vacuity
  records; the monotone schema and its theorem), an amended module docstring, and — contingent on
  Phase 2 — the common-shift raise's proof body retired to an instance with its signature
  unchanged.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the `LadderCell.lean` Description
  cell extended; the saturated-residue paragraphs amended so that the dispatched monotone slice is
  recorded and the antitone exclusion is stated with its open route named rather than claimed.
- `README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks.
- `typst/generated/status.typ` — regenerated line counts (one regeneration per Lean-touching
  phase).
- `specs/910_saturated_gap_branch_kappa_collision_regimes/summaries/01_saturated-gap-monotone-dispatch-summary.md`
  — written at implementation postflight, not by this plan.

## Rollback/Contingency

Each phase is a small additive group of Lean declarations committed on its own, so the rollback
unit is one commit and `git revert` of that commit is the first response. Only Phase 2 and
Phase 7 touch existing content: Phase 2 changes one proof body and nothing else, and its own
fallback is to make no change at all; Phase 7's edits are docstring, README prose and generated
blocks.

If a phase must be abandoned mid-edit with uncommitted work present, do NOT reach for a bare
precautionary snapshot: follow `context/contracts/recovery.md`'s recovery ladder — fix forward
first; if the phase genuinely cannot close, mark it `[BLOCKED]` with the goal state recorded and
escalate. Only a genuine rollback of uncommitted work uses the reverting
`bash .claude/scripts/git-snapshot.sh 910` form named on that contract's rollback rung (with its
out-of-scope override flag if the rollback must reach a generated surface outside the task's
declared `file_scope`); an ordinary defensive checkpoint uses `--no-revert`.

Contingency on the construction itself: if Phase 1's pinned signature proves unprovable — the one
substantive risk, and the one the plan-time compilation of fact (1) was run to retire — the
correct response is `[BLOCKED]` plus the measured deficit (which `omega` goal failed, by how much,
in which anchor direction), so a `/revise` can re-pin the bounds on `n₀`. Substituting a weaker
same-named statement is forbidden by `plan-compliance.md`, and no phase of this plan may land
anything under the reserved name `cellLE_zero_const_of_kappa_eq`.

If Phase 1 is blocked, the whole dispatched half of this plan falls with it, and the task's
remaining admissible outcome is the exclusion alone: Phase 5 is independent of Phases 1-4 and can
still land the displacement predicate, the dichotomy and both non-vacuity records, which together
state the exclusion of the entire saturated-gap branch explicitly rather than tacitly. That is the
contingency branch, and it closes the task against the second of the two admissible outcomes
rather than leaving it open.
