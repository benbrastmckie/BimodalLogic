# Implementation Plan: Task #844

- **Task**: 844 - Land the downward (deletion) half of the depth-0 cell obligation by re-anchoring the lift, then discharge the single residual inequality
- **Status**: [IMPLEMENTING]
- **Effort**: 7.5 hours (Phases 1-5 at 1 / 1.5 / 2 / 2 / 1). Phase 3 is a decision gate and Phase 4 is branch-selected by it; both branches of Phase 4 are sized at 2 hours, so the total does not depend on the verdict
- **Dependencies**: None at the `state.json` level. Parent: task 838, whose Phase 5 closed `[BLOCKED]` on the register goal this task re-anchors, and whose `.blocker-research.json` is this plan's primary input. Nothing here edits any artifact of 838 or 836
- **Research Inputs**: None as a `reports/` artifact (`--fast` dispatch; Stage 1.5 assessment passed — the task description is a specification, and every claim it carries was re-read in source at authoring time). The parent's `specs/838_two_sided_open_core_pin_free_pigeonhole/.blocker-research.json` is consumed as the research record
- **Artifacts**: plans/01_reanchored-deletion-half.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The parent's blocked phase fed the deleted walk to the landed lift anchored at position `0`
with value `nxtAt g 0`, and was left with one goal short by exactly `l`. The blocker research
located the cause as an anchor-position mismatch, not a cascade: `n₀` is a free parameter of
the lift, and the landed deletion theorem `exists_deleted_ladderPath_of_pend_past`
(`LadderPump.lean`) already closes the same clause with the value re-read at the shifted
position. This plan lands the three steps the task names: a lift anchored at an arbitrary
position `z` (Phase 1), a deletion theorem that exposes the register at `z` under an explicit
anchor clause (Phase 2), the collapse of that clause to a single inequality at the first region
start above `z`'s region together with the attempt to discharge it (Phase 3, the gate), and the
consumer-regime downward assembly on the branch the gate selects (Phase 4). Phase 5 brings the
library's own record current and runs the full gate.

Two facts established at authoring time shape the plan and are stated here rather than
discovered mid-implementation:

- **Placement.** The research puts Step 2 in `LadderPump.lean`'s `Del` section. That is not
  executable as written: `LadderChain.lean` imports `LadderPump.lean` (not the reverse), and the
  z-anchored lift conjugates `isLadderPath_shift` and `exists_ladderPath_of_walk_nxt`, both of
  which live in `LadderChain.lean`'s `Assembly` section. `LadderPump.lean` is also at 1,485
  lines against the package-wide `longFile` limit of 1500 (`lakefile.toml`). Every new
  declaration therefore goes into `LadderChain.lean` (632 lines, which already imports everything
  the deletion layer needs). No landed file is reorganized.
- **The residual has one direction with no landed source.** Re-anchoring at `z` with value
  `n = nxtAt g z` collapses the obligation to `|nxtAt g s₀ − n| ≤ (s₀ − z) − l` at the first
  region start `s₀` above `z`'s region. Its lower direction (`n − nxtAt g s₀ ≤ …`) follows from
  the consumer's gap hypothesis alone. Its upper direction (`nxtAt g s₀ − n ≤ (s₀ − z) − l`) is
  not implied by anything landed: `nxtAt_lipschitz_two_sided` gives only `≤ s₀ − z`, and the
  forward window `nxtAt_le_cntAt_add_of_next_region` bounds `n` from ABOVE by the next region's
  countdown, which is the already-free direction. The register relation (`Drift` in
  `RunLayer.lean`) permits the rung `n' = n + 1` at every step, so a path whose register climbs
  by one per step from `z` to `s₀` satisfies every hypothesis and violates the bound by exactly
  `l`. This is a planning-time analysis, carried as a hypothesis for Phase 3 to confirm at the
  goal state, not a verdict — but the plan is built so that the expected FAIL branch is a
  first-class outcome, exactly as the task's "HONEST OUTCOME" paragraph requires.

### Research Integration

Consumed from `specs/838_two_sided_open_core_pin_free_pigeonhole/.blocker-research.json` and
re-verified in source at authoring:

- The landed deletion theorem's anchor clause closes via `nxtAt_lipschitz_two_sided g hg (v + l) l`
  and the rewrite `v + l − l = v` (`LadderPump.lean`, inside
  `exists_deleted_ladderPath_of_pend_past`), with value `nxtAt g (l : ℤ)` at position `0` —
  confirmed by reading the proof.
- `hstart` inside that proof shows every region start of the deleted walk sits strictly above
  `a` — confirmed; it is what makes the triangle collapse in Phase 3 a one-pin obligation.
- `exists_ladderPath_of_walk_nxt` exposes `nxtAt g' 0 = n₀`; `isLadderPath_shift` translates a
  ladder path — both in `LadderChain.lean`'s `Assembly` section, and the translate-back pattern
  (`fun v => g₃ (v − z)`) the z-anchored lift needs is already written out inside
  `exists_ladderPath_through_shifted_of_pend_past`.
- The research's claim that Step 3 is "dischargeable from the forward window plus `hgap` and
  `hTc`" is NOT adopted as a fact: see the second bullet under Overview. `hTc` bounds the
  countdown, not the register; the forward window bounds the register in the free direction.

### Prior Plan Reference

No prior plan for this task. The parent's plan
(`specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md`)
is referenced for two conventions this plan keeps: gated theorems are not pinned in the Challenge
block, and the FAIL branch of a gate lands a regime-restricted statement under a NEW name while
the reserved name `cellLE_zero_const_of_kappa_eq` stays claimed by nothing.

### Roadmap Alignment

No `roadmap_path` was provided to this dispatch; `specs/ROADMAP.md` was not consulted.

## Goals & Non-Goals

- **Goals**:
  - `exists_ladderPath_of_walk_nxt_at` — the lift of a walk with its register exposed at an
    arbitrary anchor position, by conjugation with the landed translation (Phase 1).
  - `exists_deleted_ladderPath_of_pend_past_nxt` — the deletion admissibility theorem with the
    register exposed at a chosen position, under an explicit anchor clause on the pins above the
    block; the five landed counter and pin clauses are reused verbatim (Phase 2).
  - The collapse of the anchor clause to the first region start above the anchor's region, and
    the gate's attempt to discharge that single inequality from the consumer's hypotheses
    (Phase 3; not pinned, see below).
  - The consumer-regime downward assembly at a single type-respecting block, with the register
    held at the anchor: unconditional on PASS, under a named forward-slack hypothesis on FAIL
    (Phase 4; not pinned, see below).
- **Non-Goals**:
  - The exact-shift iteration of the deletion (`m · (P + 1)` positions through `(P + 1) / l`
    deletions of one block) and the cell-level downward inclusion
    `cellAt … (q, c + m · (P + 1), n) ⊆ cellAt … (q, c, n)`. The task names Steps (1)-(3) only,
    and the iteration is a separate obstacle the task does not mention: the upward iteration
    (`exists_iterSpliced_ladderPath_of_pend_past`) manufactures its own copies by splicing, whereas
    deleting the same block twice from an arbitrary path needs `d + 1` consecutive type-equal
    copies in the ORIGINAL, which the pigeonhole does not supply. Phase 5 records this in the
    module docstring as the named next piece; it is not attempted here.
  - Any statement under the reserved name `cellLE_zero_const_of_kappa_eq`, in either branch.
  - The `(K1)` amendment, settled as out of scope by the task.
  - The Helly-style alternative (pairwise anchor-straddle); recorded in the task, not pursued.
  - Any edit to `LadderPump.lean`, `LadderPin.lean`, `RunLayer.lean`, or `LadderAgree.lean`'s
    proofs; `LadderAgree.lean` receives a docstring-only edit in Phase 5.

### Decisions

- **Every new declaration lands in `LadderChain.lean`**, in a new section placed after
  `section AssemblyFin` and before `cellAt_subset_of_shift_of_pend_past`, except the z-anchored
  lift, which joins `section Assembly` directly after `isLadderPath_shift` (it is the same
  construction with the translation applied once more). Reason: import direction and the
  `longFile` ceiling, as stated under Overview.
- **The anchor clause is an explicit hypothesis of the Phase 2 theorem, not derived inside it.**
  This makes the theorem pinnable now and useful on both branches of the gate: PASS discharges
  the clause, FAIL carries it as the named restriction. Reducing it to the nearest pin is a
  separate lemma (Phase 3) about the ORIGINAL path only, so the two concerns do not entangle.
- **Phase 3's inequality and Phase 4's assembly are deliberately not pinned.** Whether the
  inequality holds is what the gate decides; a pinned signature would vouch for a statement this
  plan expects to be false in one direction. Same posture as the parent's Phase 4/5.
- **The FAIL branch's side hypothesis is a `def` with a name, quantified over the single
  position it constrains**, never an unnamed inline conjunct. It is a property of a PATH, not of
  a counter state, which is why Phase 4's FAIL deliverable is the path-level assembly and not a
  cell inclusion with a hypothesis the cell's universal quantification cannot express (the
  parent's blocker already made this point and it is not re-litigated).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 3's upper direction is unprovable (the climbing-register path) | M | H | This is the plan's expected outcome, and Phase 4's FAIL branch is fully specified: a named forward-slack hypothesis on one region start, a path-level assembly under it, and a record naming what the consumer must supply. No phase is reopened or weakened |
| The translate-back step in Phase 1 fights `objAt`/`cntAt`/`nxtAt` unfolding on `fun v => g₃ (v − z)` | L | M | The exact pattern is landed in `exists_ladderPath_through_shifted_of_pend_past` (the four `change … ; rw [sub_self …]` bullets); copy it rather than re-deriving |
| Finding the FIRST region start above `z`'s region in Phase 3 needs a well-founded search over `ℤ` | L | M | Use `Nat.find` over the offset `k` with `z + cntAt g z + 1 + k` pending, exactly as `cntAt_le_nxtAt_succ_of_idle_past` does in the backward direction; `k ≥ 1` because the region's end forces an idle successor (`Count` with `c = 0`) |
| `typst-sync-check.sh --fix` needs a built library and the pre-commit gate refuses a `.lean` commit without a fresh `status.typ` | M | H | Every phase builds before committing, runs `bash scripts/typst-sync-check.sh --fix`, and names `typst/generated/status.typ` in its pathspec; the gate's own message names the same remedy |
| A same-named weaker statement slips in under a pinned name | H | L | The two pinned signatures were elaborated standalone at authoring (`lake env lean`, exit 0); `lean-challenge-snapshot.sh --check` is advisory but is run in Phase 5 |
| The cell-level inclusion is expected by a downstream reader as this task's output | M | M | Non-Goals and the Phase 5 docstring state in one sentence why the single-block assembly is the deliverable and what the iteration still needs |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. The chain is deliberately linear: Phase 3's
content is logically independent of Phases 1-2 (it is about the original path only), but all
phases edit `LadderChain.lean`, so they are serialized on file territory rather than run
concurrently. Phase 5 is the final phase: a terminal node that depends transitively on every
other phase.

**Build command used throughout** (scoped; raise the Bash tool `timeout` to `600000`):

```bash
timeout 590 bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain
```

**Commit discipline used throughout**: after the scoped build is green, run
`bash scripts/typst-sync-check.sh --fix` (it needs the built library) and include
`typst/generated/status.typ` in the commit pathspec alongside the `.lean` file; a commit touching
`FormalSystem/**/*.lean` without it is refused by `.githooks/pre-commit`.

---

### Phase 1: The z-anchored lift [COMPLETED]

**Goal**: `exists_ladderPath_of_walk_nxt_at` lands in `LadderChain.lean`'s `section Assembly`,
directly after `isLadderPath_shift`: the landed lift with the hardwired anchor position `0`
replaced by a parameter `z`, so that `hn₀` measures each pin's distance as `(v − z).natAbs` and
the conclusion reads `nxtAt g' z = n₀`.

**Tasks**:
- [x] State the theorem exactly as pinned under `## Lean Challenge Statements` below.
- [x] Prove it by applying `exists_ladderPath_of_walk_nxt` to the translated walk
  `fun v => w (v + z)` and countdown `fun v => c (v + z)`: each of `hw`, `hidle`, `hpp`, `hpi`,
  `hpins` transports by instantiating at `v + z` (with `v + 1 + z = v + z + 1` by `ring` where
  needed), and `hn₀` transports because `(v + z − z).natAbs = v.natAbs`.
- [x] Translate back with `fun v => g₃ (v − z)`: `IsLadderPath` by the one-line rewrite
  `v − z + 1 = v + 1 − z`; the three component equations by `change … (v − z) = _` then
  `sub_add_cancel`; `nxtAt g' z = n₀` by `sub_self`. Copy the four bullets from
  `exists_ladderPath_through_shifted_of_pend_past`'s translate-back block.
- [x] Docstring: one paragraph saying this is the landed lift with the anchor position freed, and
  that `z := 0` recovers `exists_ladderPath_of_walk_nxt` verbatim.
- [x] `lean_verify` on the fully qualified name: axioms a subset of
  `[propext, Classical.choice, Quot.sound]`, no `sorry`.
- [x] Scoped build green; `typst-sync-check.sh --fix`; commit with both files.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: One new theorem, no new imports, `LadderChain.lean` grows by roughly 35
lines (from 632; the `longFile` limit is 1500). Confirm by `wc -l` after the edit and by the
scoped build showing no new import edge.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on the new name is
the complete covering check — the edit adds a declaration to one module and changes no existing
signature, so no dependent can break.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add `exists_ladderPath_of_walk_nxt_at` to `section Assembly`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- `lean_goal` shows no remaining goals at the end of the proof; the scoped build exits 0 through the guard.
- `lean_verify FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_of_walk_nxt_at` reports axioms within the standard profile and no `sorry`.
- The signature matches the pinned Challenge statement character-for-character in its hypotheses and conclusion.

---

### Phase 2: The nxt-exposing deletion theorem [COMPLETED]

**Goal**: `exists_deleted_ladderPath_of_pend_past_nxt` lands in `LadderChain.lean`, in a new
`section DelNxt` placed after `section AssemblyFin`: the landed deletion theorem re-run through
Phase 1's lift at anchor `z` with value `n`, exposing `nxtAt g' z = n`, under an explicit anchor
clause `hanch` on the pins above the block.

**Tasks**:
- [x] Open `section DelNxt` with `variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}`
  and state the theorem exactly as pinned below. The `{g} {a} {l}` binders are implicit, matching
  the landed theorem's use of `LadderPump.lean`'s `Del` section variables.
- [x] Reproduce `hstart` and `hpull` from the landed proof verbatim (they are `have`s inside
  `exists_deleted_ladderPath_of_pend_past`, not exported lemmas; copy the ~15 lines rather than
  refactoring the landed file).
- [x] `refine exists_ladderPath_of_walk_nxt_at (delObj g a l) (delCnt g a l) z n (delObj_step hg hrep) (delCnt_idle hg) (delCnt_pend_pend hg hl hcl) (delCnt_pend_idle hg hl hcl) (fun s v hs0 hs1 hv0 hv1 => ?_) (fun v hv0 hv1 => ?_)` — the first five clauses are the landed ones, untouched.
- [x] Pin-compatibility goal: identical to the landed proof's first bullet
  (`hpull` twice, `pinCompat_of_ladderPath` at `s + l` and `v + l`, the `ring` rewrite).
- [x] Anchor goal: from `hpull v hv0 hv1` obtain `hv0'`, `hv1'`, `hvc`; rewrite
  `delCnt g a l (v + 1)` to `cntAt g (v + l + 1)` to `nxtAt g (v + l)` via
  `cntAt_eq_nxtAt_of_idle_pend g hg (v + l) hv0' hv1'`; close with
  `hanch v (hstart v hv0) hv0' hv1'`.
- [x] Docstring: the register is now EXPOSED at `z`, the anchor clause is the one hypothesis the
  landed theorem discharges internally (with `z := 0`, `n := nxtAt g l`, by Lipschitz), and
  Phase 3 reduces it to a single pin.
- [x] `lean_verify` on the fully qualified name; scoped build; `--fix`; commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Exactly five landed clauses are reused verbatim (`delObj_step`,
`delCnt_idle`, `delCnt_pend_pend`, `delCnt_pend_idle`, and the pin-compatibility bullet built on
`pinCompat_of_ladderPath`); `hstart`/`hpull` are copied, not exported. Confirm by diffing the new
proof against `LadderPump.lean`'s `exists_deleted_ladderPath_of_pend_past` body: the only new
lines are the anchor bullet and the statement.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on the new name
covers the edit — one additive declaration in one module, no landed signature touched.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add `section DelNxt` with `exists_deleted_ladderPath_of_pend_past_nxt`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0; `lean_verify` reports the standard axiom profile and no `sorry`.
- The signature matches the pinned Challenge statement.
- Sanity instance (not committed, run via `lean_multi_attempt` or a scratch `example`): with `z := 0` and `n := nxtAt g (l : ℤ)`, `hanch` closes by `nxtAt_lipschitz_two_sided g hg (v + l) l` and the rewrite `v + l − l = v`, recovering the landed theorem's conclusions. This confirms the exposure is a strict strengthening, not a restatement.

---

### Phase 3: Collapse to the first region start, and the residual gate [COMPLETED]

**Goal**: A lemma on the ORIGINAL path reduces Phase 2's anchor clause to one inequality at the
first region start `s₀` above the anchor's region, and the gate attempts to discharge that
inequality from the consumer's hypotheses. The verdict selects Phase 4's branch.

**Tasks**:
- [x] `anchor_clause_of_first_region_start` (name suggested, not pinned): for a ladder path `g`,
  a pending position `z` with `C := cntAt g z`, a block length `l`, a value `n`, and a hypothesis
  `hfirst` quantified over the first idle run after `z`'s region — for every `I`, `0 < I`,
  `(∀ i < I, pend (objAt g (z + C + 1 + i)) = false)`, `pend (objAt g (z + C + 1 + I)) = true` —
  asserting `((nxtAt g (z + C + I) : ℤ) − n).natAbs ≤ (C + I − l : ℤ).natAbs`, conclude the
  all-pins clause in the shape Phase 2's `hanch` takes, for every `a` with `z ≤ a` and
  `a + l ≤ z + C`. Proof: a pin `v + l` with `a < v` is a region start of `g`, hence idle, hence
  above `z + C`; locate the first region start `s₀ = z + C + I₀` by `Nat.find` on the offset
  (the mirror of `cntAt_le_nxtAt_succ_of_idle_past`'s search), then
  `|nxtAt g (v + l) − n| ≤ |nxtAt g (v + l) − nxtAt g s₀| + |nxtAt g s₀ − n| ≤ (v + l − s₀) + (s₀ − l − z) = v − z`
  by `nxtAt_lipschitz_two_sided` and `hfirst`; `omega` closes the `natAbs` arithmetic once the
  two summands are stated over `ℤ`.
- [x] THE GATE. In a scratch `example` (via `lean_multi_attempt`, not committed on FAIL), state
  the single-pin bound under the consumer's hypotheses — `hgap : n + l ≤ C` (the form the
  consumer's `n + 2 ≤ c` with `c + m · (P + 1) = C` and `l ≤ P + 1` yields), the two-sided
  Lipschitz fact `nxtAt_lipschitz_two_sided g hg (z + C + I) z`, and the forward window
  `nxtAt_le_cntAt_add_of_next_region g hg z I hI hidle hnext` — and attempt `omega` on each
  direction separately.
- [x] Record the verdict in this phase's notes. PASS: both directions close. FAIL: the upper
  direction `nxtAt g (z + C + I) − n ≤ C + I − l` does not close; record the exact goal from
  `lean_goal` and the arithmetic witness (`n = 0, C = 3, I = 1, l = 1, nxtAt g s₀ = 4` satisfies
  Lipschitz, the window, and `hgap` and violates the bound), together with the path-level reading:
  `Drift`'s `n' = n + 1` rung taken at every step from `z` to `s₀` realizes it on any object with
  one pending and one idle state. Severity of the authoring-time prediction: FAIL is expected.
  *(verdict: FAIL — `lean_run_code` with one `example` per direction: the lower direction closes by `omega` from `hgap` alone; the upper direction `↑(nxtAt g (z + ↑(cntAt g z) + ↑I)) - ↑n ≤ ↑(cntAt g z) + ↑I - ↑l` is left open, omega's counterexample constraints `b - c + e - h ≤ -1` with `b := ↑n, c := ↑l, e := |z + C + I - z|, h := ↑(nxtAt g s₀)` and `a - e ≤ -1` with `a := ↑(cntAt g z)`, i.e. the witness `n = 0, C = 3, I = 1, l = 1, nxtAt g s₀ = 4`. Phase 4 takes the FAIL branch.)*
- [ ] On PASS only: land the discharge as a lemma
  `first_region_start_bound_of_gap` (name suggested) and commit it with the collapse lemma. *(deviation: skipped — gate verdict FAIL; the PASS branch is not taken)*
- [x] On FAIL: land the collapse lemma alone, and define the side hypothesis
  `HasForwardSlack (g) (z : ℤ) (l n : ℕ) : Prop` (name suggested, not pinned) as exactly the
  upper direction at the first region start — `∀ I, 0 < I → (idle on z + C + 1 … z + C + I) → pending at z + C + 1 + I → nxtAt g (z + C + I) ≤ n + C + I − l` (stated over `ℤ` to avoid truncated subtraction) — with a docstring that names it a regime restriction on ONE region start, with a finite witness, and says why no cell-level hypothesis can replace it.
- [x] Record the verdict via `issue-record.sh` (`--kind issue --class "design-record defect or ambiguity"` on FAIL, since the research's "dischargeable from the forward window" claim is then measured false; `--kind win` on PASS).
- [x] Scoped build; `--fix`; commit.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: The gate's discharge attempt is a two-direction `omega` call whose hypothesis
set is the three facts listed; if `omega` closes neither direction, the hypothesis set is
missing the gap fact's `ℤ`-cast, not the mathematics — check `hgap` is stated with `(n : ℤ)`
before reading the result as FAIL. The FAIL reading requires the upper direction specifically to
remain open with the lower one closed.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on each new name
covers the phase — additive declarations only, no landed signature touched, and the gate's own
evidence is the `lean_goal` state, which is produced by the same elaboration.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add the collapse lemma to `section DelNxt`; on PASS the discharge lemma, on FAIL the `HasForwardSlack` definition
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- The collapse lemma compiles with the standard axiom profile and no `sorry`.
- The verdict is recorded in this phase's notes with the exact goal state (FAIL) or the landed discharge lemma's name (PASS); the verdict line names which branch Phase 4 takes.
- On FAIL, the `HasForwardSlack` definition is not a vacuous `Prop` (it is a universally quantified inequality, and its docstring exhibits the climbing-register witness that falsifies it, so it is neither `True` nor trivially satisfied).

---

### Phase 4: The consumer-regime downward assembly — BRANCH-SELECTED BY PHASE 3 [COMPLETED]

**Goal**: The single-block downward mirror of `exists_ladderPath_through_shifted_of_pend_past`
lands in `LadderChain.lean`: through a pending-forever path's state at `z` with countdown at
least `Tc`, a ladder path with the countdown LOWERED by the pigeonhole block's length `l`
(with `l ∣ P + 1`), the object state and register at `z` held, and the same realized stab-free
type at `z`. Unconditional on PASS; under `HasForwardSlack g z (P + 1) (nxtAt g z)` on FAIL.

**Tasks** (both branches):
- [x] `exists_ladderPath_through_deleted_of_pend_past` (name suggested, not pinned), in
  `section DelNxtFin` with `[Fintype Q] [Nonempty Q]`, mirroring the upward assembly's
  hypothesis list (`step pend fwd bwd lab φ Tc Tn P B hp hno g hg z hpast hTc`) plus a gap
  hypothesis of the weakest form the proof needs (at least `nxtAt g z + (P + 1) ≤ cntAt g z`, so
  that `n + l ≤ C` holds for every `l ∣ P + 1`; record the exact form chosen). On FAIL, add
  `(hslack : HasForwardSlack g z (P + 1) (nxtAt g z))` and derive the `l`-instance by
  monotonicity (`l ≤ P + 1`).
  *(branch: FAIL; gap form chosen: `hgap : nxtAt g z + (P + 1) ≤ cntAt g z`, plus `hslack : HasForwardSlack g z (P + 1) (nxtAt g z)`; the `l`-instance is derived inline in `hfirst` by `omega` from `hslack`, `hgap`, and `l ≤ P + 1` via `Nat.le_of_dvd`)*
- [x] Conclusion shape: `∃ g', IsLadderPath step pend g' ∧ objAt g' z = objAt g z ∧ (∃ l, 0 < l ∧ l ∣ P + 1 ∧ cntAt g' z + l = cntAt g z) ∧ nxtAt g' z = nxtAt g z ∧ ∀ σ σ', (∀ t, σ.state t = (t, g t)) → (∀ t, σ'.state t = (t, g' t)) → tpOf … φ σ' z = tpOf … φ σ z`.
- [x] Proof skeleton, step by step: `exists_hist_of_isLadderPath` for `σ₀`;
  `exists_typeBlock_of_budget_le_cnt_within` at `z` (via `budget_le_Tc`) for `u, l, hl, hlb, hzu, hcl, hul, hrep, hty`;
  `typeBlock_length_dvd_of_paramsOk` for `l ∣ P + 1`; `hpast_u` exactly as in the upward
  assembly; Phase 3's collapse lemma with `a := u` to build `hanch` (PASS: from the discharge
  lemma; FAIL: from `hslack`); Phase 2's theorem with `z`, `n := nxtAt g z` for `g'`;
  `delCnt_sub_of_mem_region` at `z` for `cntAt g' z = cntAt g z − l` (hypotheses `z ≤ u` and
  `u ≤ z + cntAt g z` are `hzu`/`hul`); `delObj_eq_of_le` for `objAt g' z`;
  `tpOf_eq_delIdx_of_tpOf_eq` composed with `tpOf_stabFree_eq_of_objAt_eq` for the type, read
  through `delIdx u l z = z` (`delIdx_of_lt`, or `delIdx_of_ge` at `z = u` with `hrep`).
- [x] Docstring: name the branch taken, the hypothesis the consumer must supply on FAIL, and the
  two remaining pieces for the cell-level inclusion (the exact-shift iteration and the
  path-versus-state quantification), in that order.
- [x] `lean_verify`; scoped build; `--fix`; commit.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: The proof reuses the upward assembly's first half (history, pigeonhole,
divisibility, `hpast_u`) unchanged — roughly 20 lines copied — and the deletion type lemma's
`delIdx` reading needs at most one case split at `z = u`. Confirm by the diff against
`exists_ladderPath_through_shifted_of_pend_past`'s opening block.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on the new name
covers the phase — the theorem is additive, consumed by nothing yet, and no landed signature
changes.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add `section DelNxtFin` with the downward assembly
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- The assembly compiles on the standard axiom profile with no `sorry`; the branch taken is named in its docstring and matches Phase 3's recorded verdict.
- On FAIL, the only hypothesis absent from the upward mirror's list, beyond the gap form, is the single `HasForwardSlack` hypothesis; nothing is weakened under an existing name, and `cellLE_zero_const_of_kappa_eq` remains claimed by nothing (`grep -n "cellLE_zero_const_of_kappa_eq" FormalSystem/` shows only the `LadderAgree.lean` docstrings and `def CellLEZeroConstOfKappaEq`).

---

### Phase 5: Record, sync, and the full gate [NOT STARTED]

**Goal**: The library's own account of the downward direction is brought current, the generated
Typst status is in sync, and the complete gate set runs green.

**Tasks**:
- [ ] `LadderChain.lean`: the `Assembly` section docstring's sentence "This is ONE direction only
  … which is the cascade the Phase 3 gate refuted as a device" and
  `cellAt_subset_of_shift_of_pend_past`'s "ONE direction only — the downward inclusion … is not
  claimed" are rewritten to say what is now landed: the register obstruction was an anchor-position
  mismatch, the single-block downward assembly exists (naming the branch and, on FAIL, the
  `HasForwardSlack` hypothesis), and the cell-level inclusion still needs the exact-shift
  iteration. Durable anchors only, no task numbers.
- [ ] `LadderAgree.lean`: the obligation section's docstring (around `CellLEZeroConstOfKappaEq`)
  gains one sentence pointing at `LadderChain.lean`'s downward assembly as the current state of
  the second inclusion; the reserved-name sentence is unchanged.
- [ ] `bash scripts/typst-sync-check.sh --fix` then the bare `bash scripts/typst-sync-check.sh`
  (all four checks) exits 0.
- [ ] `bash .claude/scripts/lean-challenge-snapshot.sh --check` against this plan: both pinned
  signatures match the landed declarations (advisory; a drift finding is investigated, not
  auto-failed).
- [ ] Full project build through the guard (unscoped `-- build`), detached as a shell-level
  background job and waited on with the bounded single-call idiom if it does not fit one call.
- [ ] `bash .claude/scripts/verify-deploy.sh` — the complete gate set.
- [ ] Commit; write the summary naming the branch taken, the verdict's evidence, and the two
  named next pieces.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: Docstring-only edits in two files plus the regenerated status file; no new
declaration. Confirm with `git diff --stat` showing only comment hunks in the two `.lean` files
(the `prose` reading of the diff) before the full gate runs.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - docstring updates in `section Assembly` and on `cellAt_subset_of_shift_of_pend_past`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - one-sentence docstring pointer in the obligation section
- `typst/generated/status.typ` - regenerated and verified in sync
- `specs/844_reanchored_deletion_half_depth_zero_cell/summaries/01_reanchored-deletion-half-summary.md` - the summary

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` exits 0 (the complete gate set, not a subset).
- The unscoped guarded `lake build` exits 0; `bash scripts/typst-sync-check.sh` exits 0.
- `lean_verify` on every new declaration from Phases 1-4 reports a subset of `[propext, Classical.choice, Quot.sound]` and no `sorry`.
- `grep -rn "task 8" FormalSystem/` returns nothing (no task-number references in deliverables).

## Lean Challenge Statements

Both declarations were elaborated standalone at authoring time against the built library
(`lake env lean` on this block with the two `sorry` bodies: exit 0, two `declaration uses
'sorry'` warnings, no errors). Phase 3's lemmas and Phase 4's assembly are deliberately not
pinned — see Decisions.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

namespace FormalSystem.Metalogic.Decidability.RaySummary

theorem exists_ladderPath_of_walk_nxt_at {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (w : ℤ → Q) (c : ℤ → ℕ) (z : ℤ) (n₀ : ℕ)
    (hw : ∀ v, step (w v) (w (v + 1)) = true)
    (hidle : ∀ v, pend (w v) = false → c v = 0)
    (hpp : ∀ v, pend (w v) = true → pend (w (v + 1)) = true → c (v + 1) + 1 = c v)
    (hpi : ∀ v, pend (w v) = true → pend (w (v + 1)) = false → c v = 0)
    (hpins : ∀ s v, pend (w s) = false → pend (w (s + 1)) = true →
      pend (w v) = false → pend (w (v + 1)) = true →
      ((c (s + 1) : ℤ) - c (v + 1)).natAbs ≤ (s - v).natAbs)
    (hn₀ : ∀ v, pend (w v) = false → pend (w (v + 1)) = true →
      ((c (v + 1) : ℤ) - n₀).natAbs ≤ (v - z).natAbs) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = w v) ∧ (∀ v, cntAt g' v = c v) ∧ nxtAt g' z = n₀ := sorry

theorem exists_deleted_ladderPath_of_pend_past_nxt
    {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    {g : ℤ → LadderState Q pend} {a : ℤ} {l : ℕ}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hpast : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true)
    (hrep : objAt g a = objAt g (a + (l : ℤ)))
    (z : ℤ) (n : ℕ)
    (hanch : ∀ v : ℤ, a < v → pend (objAt g (v + (l : ℤ))) = false →
      pend (objAt g (v + (l : ℤ) + 1)) = true →
      ((nxtAt g (v + (l : ℤ)) : ℤ) - n).natAbs ≤ (v - z).natAbs) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = delObj g a l v) ∧ (∀ v, cntAt g' v = delCnt g a l v) ∧
      nxtAt g' z = n := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] Each of Phases 1-4: scoped guarded build of `LadderChain` exits 0; `lean_verify` on every new name reports the standard axiom profile and no `sorry`.
- [ ] Phase 2's sanity instance (`z := 0`, `n := nxtAt g l`) recovers the landed deletion theorem's conclusions from the new one.
- [ ] Phase 3's verdict is recorded with its evidence (goal state on FAIL, discharge lemma on PASS) before Phase 4 is entered.
- [ ] Phase 5: `verify-deploy.sh`, the unscoped guarded build, and `typst-sync-check.sh` all exit 0; `lean-challenge-snapshot.sh --check` reports no drift on the two pinned names.
- [ ] No file under `FormalSystem/` or `typst/` carries a task-number reference.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`: `exists_ladderPath_of_walk_nxt_at`; `exists_deleted_ladderPath_of_pend_past_nxt`; the collapse lemma; on PASS the discharge lemma, on FAIL the `HasForwardSlack` definition; the single-block downward assembly; updated docstrings.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`: a one-sentence docstring pointer.
- `typst/generated/status.typ`: regenerated.
- `specs/844_reanchored_deletion_half_depth_zero_cell/summaries/01_reanchored-deletion-half-summary.md`.

## Rollback/Contingency

- Every phase is a self-contained additive edit committed only when green, so a failed phase is
  reverted by discarding its uncommitted hunk; the repository is never left with a red
  `LadderChain.lean` at a commit boundary. Before any destructive revert on a dirty tree, take
  `bash .claude/scripts/git-snapshot.sh 844` first (the rollback rung of `recovery.md`); do not
  emit it as a routine checkpoint.
- If Phase 1's translate-back fights unfolding for more than 30 minutes, state the theorem with
  `g'` given explicitly as `fun v => g₃ (v − z)` in a `refine ⟨_, ?_, ?_, ?_, ?_⟩` and close each
  component by `show` with the explicit term; the pattern is landed and the plan does not change.
- If Phase 3 returns PASS against the authoring-time prediction, Phase 4's unconditional branch
  is already specified; no replanning is needed, and the `HasForwardSlack` definition is simply
  not written.
- If Phase 4's proof cannot be completed on its selected branch, close it `[BLOCKED]` with the
  goal state reached, leave Phases 1-3's landed theorems in place (they are useful on their own),
  and let Phase 5 record the state honestly; never a `sorry`, never a vacuous placeholder, never a
  statement under the reserved name.
