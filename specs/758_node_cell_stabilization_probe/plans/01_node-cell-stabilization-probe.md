# Implementation Plan: Task #758

- **Task**: 758 - Node fixture probe: cell stabilization in the deadline index (preCell_stable, preCell_zero_ne, postCell_stable)
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/758_node_cell_stabilization_probe/reports/01_node-cell-stabilization-probe.md
- **Artifacts**: plans/01_node-cell-stabilization-probe.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Port the research phase's compiled prototype (`prototype/node-cell-stabilization-proto.lean`,
284 lines by `wc -l`, re-derived at plan time: `lake env lean` exits 0 in 2.7 s with
`preCell_stable`, `preCell_zero_ne`, `postCell_stable` and the bonus `xCell_stable` all at
`[propext, Classical.choice, Quot.sound]`) into the wired evidence probe
`specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean`, under the header the task
mandates; then wire it into `scripts/check-evidence-probes.sh` and record it in one sentence in
the RaySummary README's Evidence section. The verdict is POSITIVE: on the library fixture
`NoFiniteWidth.M` with its own witness `Φ`, realized cells stabilize past pre-index 1, the
deadline index is real (`pre 0 ≠ pre 1`), and the thread index is invisible. The implementer
ports proofs; nothing is discovered, and no library file is touched.

### Research Integration

- **Verdict and formula**: all three dispatch statements are proved for `Φ` itself; fallback `D`
  is not needed. The header records "witness `Φ`; fallback `D` not needed", in that order.
- **Mechanism (sharper than the README's phrasing)**: on a canonical history `histOf k t` at time
  `s`, every member of `cl Φ` has a truth value that is a Boolean combination of `s<t`, `s=t`,
  `t<s`, `s+1=t` — never of `k`. Types depend only on the class of `t - s` in `{<0, 0, 1, ≥2}`.
  Cells: `pre 0 ↦ {tp 1}`, `pre (≥1) ↦ {tp 1, tp ≥2}`, `x ↦ {tp 0}`, `post ↦ {tp <0}`.
- **What separates `pre 0` from `pre 1` is the non-`⊡` letter `Xp`, as SET membership** (the
  history through `pre 1` detouring via `pre 0` realizes a second type with `Xp ∉ T`), not a
  `⊡`-letter: `⊡Xp ∉ cl Φ`, and the closure's `⊡¬Xp` is false at every pre state
  (`truth_stabNegXp`), so all four `⊡`-letters of `cl Φ` agree at `pre 0` and `pre 1`. The
  README's "`pre 0` reads `⊡Xp` where `pre (k+1)` reads `¬⊡Xp`" is a true fact about a formula
  outside the closure; the probe header states the closure-level mechanism precisely and does not
  edit that README sentence (see Non-Goals).
- **Thread index invisible everywhere, including `post k 0`**: `postCell_subset` needs neither
  `1 ≤ j` nor `1 ≤ j'`; `postCell_stable` keeps the dispatch's hypotheses verbatim (statement
  fidelity) under `set_option linter.unusedVariables false in` with a docstring saying they are
  vacuous on `Node`.
- **Lemma order to port** (report Recommendation 2): `truth_A'/C'/D` → `truth_stabFp/Pp/NegPp/NegXp`
  → `SameClass`, `truth_transfer`, `tpOf_eq_of` → `through_pre/post/x` → `preCell_subset`,
  `preCell_stable`, `preCell_zero_ne`, `postCell_subset`, `postCell_stable`, `xCell_stable` →
  `#print axioms`. `histOf_timeShift` is NOT needed and is left out.
- **Two hazards named for the implementer**: (1) `rw [mem_cellAt_iff]` / `rw [canon_eq_x_iff]`
  fail on goals mentioning `cellAt M Φ (.pre k) z` (the literal sits at type `F.WorldState`,
  defeq to `Node` only at default transparency) — apply them in term mode
  (`(mem_cellAt_iff M Φ _ z T).mp/.mpr`, `canon_eq_x_iff.mp`) exactly as the prototype does;
  (2) the `simp only` in `truth_transfer` needs `forall_eq` (not `forall_eq_or_imp`) and the
  truth lemmas' `p/Fp/Pp/Xp/top/neg` unfolded first — port the call verbatim. `push_neg` is
  deprecated at this Mathlib pin; the prototype uses `push Not`.
- **Carried figures not re-derived here**: `cl Φ` has 28 members and `cl D` 11
  (CARRIED-UNVERIFIED, from the report's `lean_run_code` enumeration); "four realized types" is
  the content of the proofs, not a theorem — the header exhibits the cells as sets and does not
  claim "exactly four cells" as a theorem unless the optional distinctness lemmas are added.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch, so ROADMAP.md was not consulted. The task
description's GUARDRAILS (a)-(e) are labelled "ROADMAP Stage 1" and are carried into Phase 1's
header checklist verbatim.

## Goals & Non-Goals

**Goals**:
- `preCell_stable` — for pre-indices k, k' both at least 1, the realized cells at pre k and pre k' coincide (stabilization on the one-region fixture).
- `preCell_zero_ne` — the cell at pre 0 differs from the cell at pre 1: the deadline index is real.
- `postCell_stable` — the cells at post k j and post k' j' coincide for all thread and age indices (hypotheses 1 ≤ j, 1 ≤ j' kept verbatim from the dispatch; vacuous on the fixture).

**Non-Goals**:
- No lemma is added to `FormalSystem/`; the probe imports the library model and re-proves nothing.
- No claim about the general ladder lemma's bound (the figure "1" is `Φ`-specific — the report's
  `F(⊡Xp)` observation shows a closure with a `⊡`-letter under a temporal operator would need 2).
- Nothing about `⊡(Pp)`, `HitPresented`, `PlusValidZTime`, any `Adm`, or finiteness of any kind.
- No edit to the README's "(W): what landed and what did not" obligation (ii) text or its
  "The verdict" row — the task fixes ONE sentence in the Evidence section; the README's `⊡Xp`
  phrasing is true as stated (about a formula outside `cl Φ`) and is left alone.
- No `histOf_timeShift`; no distinctness lemmas (`xCell_ne_preCell` etc.) — optional per the
  report, not in the dispatch's STATEMENT, and omitted to keep the record to its three statements.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `rw` transparency failures on `cellAt … (.pre k) …` goals cost an hour of flailing | M | M | Port the prototype's term-mode `.mp/.mpr` applications verbatim; never `rw` the iff lemmas on these goals (Research Integration, hazard 1) |
| `truth_transfer`'s `simp only` set drifts during the port and leaves 28 `∀ x, x = f → …` residues | M | L | Copy the call verbatim; the two `unusedSimpArgs` warnings (`true_and`, `and_true`) are harmless and may be trimmed; 0 errors is the criterion |
| Over-reading the verdict as evidence for the general lemma's bound or for `⊡`-letter device discrimination | H | M | Header language fixed in Phase 1's checklist (guardrails (c) and (e), plus the `Xp`-not-`⊡` sharpening) |
| Cross-set collisions on `scripts/check-evidence-probes.sh` (task 734, `[PARTIAL]`) and the README (task 744, not started) | L | L | Both edits are single appended lines/paragraphs at the end of their lists; `git status` on both files is clean at plan time; the admission gate orders them — no edge is added |
| README sentence trips C9 (`check-module-invariants.sh`) or the task-reference lint | M | L | Cite only `specs/evidence/...`, declaration names and section headings; never `specs/758_...` (C9 matches `specs/[0-9]{3}_` paths) or "task N" |
| `lake env lean` on the probe fails because the two imported `.olean`s are stale while another session rebuilds | M | L | Phase 1 compiles against the current tree; if `lake env lean` reports a missing/stale import, wait for the guarded build (`lake-build-guard.sh status`) rather than starting a competing one |
| Probe gate run (`check-evidence-probes.sh`, 28 files) exceeds a foreground tool call | L | M | Run detached with a bounded waiter per `context/patterns/bounded-build-waiter.md`; it is a sequence of `lake env lean` calls, not a `lake build` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. This plan is fully sequential.

### Phase 1: Author the Wired Probe File [COMPLETED]

**Goal**: Create `specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean` — the
mandated header followed by the prototype's proofs under `namespace Probe758` — compiling under
`lake env lean` with no `sorry`, no axiom, no vacuous definition, and the three dispatch
statements verbatim.

**Tasks**:
- [x] Write the header docstring (`/- … -/`, before the imports, modeled on
      `deadline-ladder-branching.lean`'s), containing in this order:
      - Title line: "Probe 758 (requirement (W)'s run layer, phase 2, first statement, on the
        one-region fixture): POSITIVE — realized cells on `Node` stabilize past pre-index 1, the
        deadline index is real, the thread index is invisible."
      - **Witness**: `Φ` of `Limits/NoFiniteWidth.lean`; fallback `D` not needed (in that order).
      - **The fixture**: `NoFiniteWidth.M` on `F` (regular by `F_isRegular`; every history
        canonical by `hist_canon`/`path_eq_canon`); the probe cites `histOf`, `histOf_state`,
        `canon_of_lt/self/gt`, `canon_eq_x_iff`, `lt_of_canon_eq_of_lt`, `gt_of_canon_eq_of_gt`,
        `eq_of_canon_eq_of_eq`, `truth_p/Fp/Pp/Xp`, `Φ_true`, `box_global`, `cellAt`,
        `mem_cellAt_iff`, `mem_tpOf_iff` and re-proves none of them.
      - **What it establishes**: the three dispatch theorems (statement text verbatim) and the
        bonus `xCell_stable`; the mechanism — branch-time saturation: every member of `cl Φ` on a
        canonical history is a Boolean combination of `s<t`, `s=t`, `t<s`, `s+1=t`, never of `k`;
        the four position classes `{<0}, {0}, {1}, {≥2}` and the cells as SETS of the types they
        realize (`pre 0 ↦ {tp 1}`, `pre (≥1) ↦ {tp 1, tp ≥2}`, `x ↦ {tp 0}`, `post ↦ {tp <0}`).
      - **The sharpening**: `⊡Xp ∉ cl Φ`; `⊡¬Xp` is false at every pre state
        (`truth_stabNegXp`), so all four `⊡`-letters of `cl Φ` agree at `pre 0` and `pre 1`; the
        cells differ because `pre 1` additionally realizes the type with `Xp ∉ T`. The separator is
        the non-`⊡` letter `Xp`, through set membership of a second type.
      - **Thread index at `post k 0`**: `postCell_subset` needs no `1 ≤ j`; the dispatch's
        hypotheses on `postCell_stable` are kept verbatim and are vacuous on `Node`.
      - **What it does NOT say** (guardrails (a)-(e)): cells are closure-indexed SETS over the
        time axis, never one bit per depth; `Node` has infinite width and the probe adds no
        finiteness; no bound of any kind is claimed — the probe exhibits cells, and the "1" in
        `preCell_stable`'s hypotheses is where THIS fixture's cells coincide, not a bound
        syntactic in `φ` (a closure with a `⊡`-letter under a temporal operator, e.g. `F(⊡Xp)`,
        would separate `pre 1` from `pre 2`); zero debt — no external Büchi/MSO lemma, no cslib
        require; forward-only — nothing here bears on `⊡(Pp)`, and no claim that `⊡`-letters
        discriminate between devices (on this fixture they do not even discriminate `pre 0` from
        `pre 1`). Also: nothing about `HitPresented`, nothing about `PlusValidZTime`, no model
        constructed, no `Adm`.
      - Axiom foot sentence ("Every headline theorem carries `[propext, Classical.choice,
        Quot.sound]`; `Classical.choice` enters through `hist_canon`") and the compile line
        `lake env lean specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean`.
- [x] Imports and opens exactly as the prototype: `Limits.NoFiniteWidth` and
      `RaySummary.AnchorLayer`; the four `open` lines; `namespace Probe758`.
- [x] Port the prototype's declarations in the report's order (Research Integration), keeping
      names and statements; keep `set_option linter.unusedVariables false in` and the docstring on
      `postCell_stable`; keep `truth_stabNegXp`'s docstring. Optionally drop the two unused simp
      arguments (`true_and`, `and_true`) flagged by the linter. Do NOT port `histOf_timeShift`.
- [x] Close with `end Probe758` and `#print axioms` for `Probe758.preCell_stable`,
      `Probe758.preCell_zero_ne`, `Probe758.postCell_stable`, `Probe758.xCell_stable`.
- [x] `git add` the new file (the gate's "tracked, not merely present" rule — Phase 2 fails
      otherwise) and commit per the green-substep mandate.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The probe is ~360-380 lines (prototype 284 lines by `wc -l`, re-derived at
plan time, plus a 70-90 line header; the task description's 400-800 estimate is an upper
envelope). Confirm with `wc -l` on the written file; a figure outside 330-450 is a signal to
re-check that nothing was dropped or duplicated, not a defect in itself.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean`
exiting 0 is the complete covering check — the file sits outside the Lake build graph, nothing
imports it, and it modifies no library module, so no other compilation unit can be affected.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean` - new probe file (header + ported proofs)

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean` exits 0 with
  zero `error` lines; the four `#print axioms` lines each read exactly
  `[propext, Classical.choice, Quot.sound]`.
- `grep -nE "sorry|^axiom |:= (True|Unit|trivial|Trivial)\s*$" specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean`
  prints nothing.
- The three dispatch statements appear with their exact signatures (compare against the
  `## Lean Challenge Statements` block below; `set_option` and docstring lines may precede them).
- Header read-through confirms every item in the first task's checklist is present, including
  "witness `Φ`; fallback `D` not needed" and the forward-only sentence.
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean` exits 0.

---

### Phase 2: Wire the Probe into the Evidence Gate [COMPLETED]

**Goal**: Register the probe in `scripts/check-evidence-probes.sh` so the gate compiles it on
every run, with a table row recording what it holds in place.

**Tasks**:
- [x] Add a table row in the `# --- WIRED ---` comment table, directly after the
      `seam-gluing-ray-product/deadline-ladder-branching` row (the row block ends at the line
      before `WIRED=(`), in the same two-column `# probe | decision` wrapped format, headed
      `POSITIVE VERDICT (requirement (W)'s run layer, "(W): what landed and what did not",
      obligation (ii) item 1, on the one-region fixture)` and stating: cells on
      `Limits/NoFiniteWidth.lean`'s `Node` stabilize past pre-index 1 (`preCell_stable`), `pre 0`
      and `pre 1` differ (`preCell_zero_ne`, the deadline index is real), the thread index is
      invisible (`postCell_stable`, hypotheses vacuous on `Node`); the mechanism (types depend on
      the relative-position class only; `Xp` as set membership separates `pre 0` from `pre 1`,
      not a `⊡`-letter); what it does NOT say (forward-only; nothing about `⊡(Pp)`; no bound of
      any kind; no finiteness; no claim that `⊡`-letters discriminate between devices; nothing
      about `HitPresented` or `PlusValidZTime`). No task number anywhere in the row — durable
      anchors only.
- [x] Append `"seam-gluing-ray-product/node-cell-stabilization"` to the `WIRED=(` array
      immediately after `"seam-gluing-ray-product/deadline-ladder-branching"`.
- [x] `bash -n scripts/check-evidence-probes.sh` (syntax) and then run the gate detached with a
      bounded waiter (`context/patterns/bounded-build-waiter.md`).
- [x] Commit the script edit.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: At plan time `WIRED` has 26 entries and `WIRED_REPO` 1 (counted with
`awk '/^WIRED=\(/,/^\)/' … | grep -c '^  "'`), so the gate's PASS line should read
`PASS  all 28 wired probe(s) compile` after the edit. Confirm by re-counting both arrays before
and after the edit (exactly +1) and matching the PASS line's number to the sum.

**Tier Justification**: `bash -n scripts/check-evidence-probes.sh` plus a full
`bash scripts/check-evidence-probes.sh` run exiting 0 is the complete covering check — the edit is
one comment block and one array element, the script has no other consumer that parses `WIRED`,
and `scripts/check-evidence-probes.sh` is self-excluded from `check-module-invariants.sh`'s C9.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - one WIRED table row and one `WIRED=(` array entry

**Verification**:
- `bash -n scripts/check-evidence-probes.sh` exits 0.
- `bash scripts/check-evidence-probes.sh` exits 0; its output contains
  `seam-gluing-ray-product/node-cell-stabilization … PASS` and the final line
  `PASS  all 28 wired probe(s) compile` (the count per the Scope Hypothesis).
- `bash .claude/scripts/check-task-references.sh --quiet scripts/check-evidence-probes.sh` exits 0.
- `git diff --staged --stat` shows only `scripts/check-evidence-probes.sh` for this phase's commit.

---

### Phase 3: Record the Probe in the RaySummary README and Run the Full Gate [COMPLETED]

**Goal**: Add the one mandated sentence to the README's Evidence section, refresh its
"Last verified" stamp, and run the complete repository gate set over the finished task.

**Tasks**:
- [x] In `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `## Evidence` section,
      insert ONE sentence as its own paragraph directly after the "A ninth wired probe, …"
      paragraph and before "The permanent computability witnesses are …", of the shape:
      "A tenth wired probe, `specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean`,
      is the run layer's phase-2 first statement on the one-region fixture, gate-compiled: on
      `NoFiniteWidth.M` with its own witness `Φ`, the realized cells `cellAt` of `AnchorLayer.lean`
      stabilize past pre-index 1 (`Probe758.preCell_stable`), differ between `pre 0` and `pre 1`
      (`preCell_zero_ne`, the deadline index is real), and ignore the thread index
      (`postCell_stable`), every theorem at `[propext, Classical.choice, Quot.sound]`, citing the
      fixture and re-proving nothing — forward-only, with no bound of any kind claimed and no
      finiteness added, and with the separator between `pre 0` and `pre 1` being the non-`⊡`
      letter `Xp` as set membership of a second type, not a `⊡`-letter." Durable anchors only:
      no task number, no `specs/758_…` path, no record-versioning language.
- [x] Update the README's trailing `*Last verified: YYYY-MM-DD*` line to the implementation date.
- [x] Run the final gate set (below), detached where the pattern requires, and record each
      exit status in the summary.
- [x] Commit the README edit; write the implementation summary per `summary-format.md`.

**Timing**: 1 hour

**Depends on**: 1, 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - one sentence in `## Evidence` after the ninth-probe paragraph; `Last verified` date

**Verification** (the complete gate set — every command's exit status is checked, never only its
output):
- `lake env lean specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean` exits 0
  (re-run after all commits; four `#print axioms` lines at `[propext, Classical.choice, Quot.sound]`).
- `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 28 wired probe(s) compile`.
- `bash scripts/check-module-invariants.sh` exits 0 (C9 in particular: zero task-number or
  `specs/NNN_` citations under `FormalSystem/` and `scripts/`); run detached with a bounded waiter.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- `bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` exits 0 (check 3,
  relative references, is gated; the `Last verified` check is reported).
- Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
  detached (`Bash(run_in_background: true)`) per
  `context/project/lean4/operations/long-builds.md`, exits 0 — expected a no-op success, since the
  probe is outside the build graph and the README is markdown, but mandatory before `implemented`.
- Lean agent Final Verification Stage over the resolved source roots AND the probe file:
  `lean-sorry-census.sh` count 0; vacuous-definition grep count 0; `grep -rn "^axiom "` count
  unchanged from baseline.
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- `git status --short` shows no stray modified files outside the three in `file_scope`.

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe758

theorem preCell_stable (k k' : ℕ) (hk : 1 ≤ k) (hk' : 1 ≤ k') (z : ℤ) :
    cellAt M Φ (.pre k) z = cellAt M Φ (.pre k') z := sorry

theorem preCell_zero_ne (z : ℤ) : cellAt M Φ (.pre 0) z ≠ cellAt M Φ (.pre 1) z := sorry

theorem postCell_stable (k k' j j' : ℕ) (hj : 1 ≤ j) (hj' : 1 ≤ j') (z : ℤ) :
    cellAt M Φ (.post k j) z = cellAt M Φ (.post k' j') z := sorry

end Probe758
```

## Testing & Validation

- [x] The probe compiles under the gate's own command (`lake env lean`) with 0 errors and the
      axiom foot `[propext, Classical.choice, Quot.sound]` on all four `#print axioms` lines.
- [x] No `sorry`, `axiom`, or vacuous-definition pattern in the probe (grep count 0).
- [x] The three dispatch statements match the Lean Challenge Statements block exactly
      (`lean-challenge-snapshot.sh --check 758 .` is available as an advisory drift check).
- [x] `check-evidence-probes.sh` reports 28 wired probes, all PASS.
- [x] `check-module-invariants.sh`, `check-task-references.sh`, `readme-lint.sh`,
      `verify-deploy.sh` and the guarded full `lake build` all exit 0.
- [x] Header read-through: witness/fallback order, forward-only sentence, no-bound sentence,
      no-finiteness sentence, zero-debt sentence, the `Xp`-not-`⊡` sharpening, and the
      `post k 0` remark are all present.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean` (new, tracked, wired)
- `scripts/check-evidence-probes.sh` (one table row, one `WIRED` entry)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (one Evidence sentence, `Last verified` date)
- `specs/758_node_cell_stabilization_probe/summaries/01_node-cell-stabilization-probe-summary.md`

## Rollback/Contingency

- Each phase is one or two files and commits per green substep; reverting a phase is reverting its
  commit(s). If Phase 2's gate run fails on the new entry, remove the entry and row (the probe file
  stays, unwired) rather than weakening any statement.
- If the port does not compile and the cause is not one of the two named hazards, STOP and compare
  against the prototype line by line — the prototype is a compiled oracle for every declaration;
  do not re-derive proofs or substitute a different decomposition (`plan-compliance.md`).
- The research has exhibited a sorry-free path, so a `[BLOCKED]` outcome is not expected. Should a
  statement nonetheless fail to close as written, the task's own rule applies: record the failure
  in the header as the obstruction, mark the phase `[BLOCKED]`, never a `sorry`, axiom, vacuous
  definition, or finite-fibre retreat.
