# Implementation Plan: Task #733

- **Task**: 733 - Probe the backward-dual stability summary on a backward-NONDETERMINISTIC mirror fixture (E1's hard test)
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: 739 (completed)
- **Research Inputs**: specs/733_backward_dual_mirror_fixture_branching_probe/reports/01_backward-dual-mirror-fixture.md
- **Artifacts**: plans/01_backward-dual-mirror-fixture.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Land the mirror-fixture probe `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`
and wire it into `scripts/check-evidence-probes.sh`. The research dispatch already compiled a
sorry-free prototype of the whole proof
(`specs/733_backward_dual_mirror_fixture_branching_probe/prototype/backward-dual-mirror-fixture.proto.lean`,
namespace `Probe733Mirror`): on Probe710's step graph with every arrow reversed -- forward
deterministic, backward branching factor 2 at every spine state `aft (k+1)` -- the backward
stability operator `⊡(P p)` at a seam state is exactly "every backward root path from that state
meets the `p`-set", True at every `aft` state and False at every `x` and `bef` state. The result is
POSITIVE: the two-factor ray presentation is not falsified at the branching backward factor.
Implementation is therefore a lift-header-wire job: copy the prototype to its `file_scope` path,
write the collection-style header the acceptance criteria demand (branching factor stated
explicitly, outcome, effect on the two-factor presentation, honest limit, axiom record), add one
`WIRED` entry plus one table row to the gate script, and run the full gate. Definition of done:
`lake env lean` on the new probe prints exactly its six `#print axioms` lines with no errors or
warnings, `bash scripts/check-evidence-probes.sh` reports all wired probes passing with the count
up by one, E1's `.lean` file is byte-identical, and the two `file_scope` files are committed.

### Research Integration

From `reports/01_backward-dual-mirror-fixture.md`:
- The compiled prototype (550 lines, 73 declarations, 0 `sorry`, `lake env lean` ~3 s) is the
  proof; the plan does not re-derive any mathematics. The decomposition the plan commits to is the
  prototype's own (`Node`/`Step` fixture, `fwdList`/`bwdList`, `canon` and `hist_canon`,
  `IsBwdPath`/`AllBwdPathsMeet`, `bwd_reaches_x` by induction on the spine index with the uniform
  bound `n ≤ m + 1`, `two_bwd_paths`, `allBwdPathsMeet_iff`, `stabPast_iff_aft`,
  `pastStab_iff_allBwdPathsMeet`, `decide_past_stab`, `decidable_past_stab`).
- The choice-free variant of `bwd_reaches_x` (explicit `Nat.*` lemmas instead of `omega`) is the
  one to ship: it keeps the backward-reachability half at `[propext]`, matching E1's axiom record
  shape. Do not reintroduce `omega` into that declaration.
- E1's header records the `reflectTime` trap (no `PlusTruthAt`/`reflectTime` transport theorem
  exists); the proof is direct and must stay direct.
- Gate mechanics: `check_probe` only runs `lake env lean "$file"`; sorry-freedom is evidenced by
  the `#print axioms` footer (no `sorryAx`). A new probe needs a comment-table row under
  `# --- WIRED ---` and a string in the `WIRED=( ... )` array, both directly after the E1 entry.
- The C9-style register clause of the task is conditional on a negative result; the result is
  positive, so no register entry is written.
- E1's "mirror fixture filed as a follow-up" note is discharged by pointer (new header + gate
  table row), never by editing E1's `.lean` file.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in this dispatch (no `roadmap_path`); ROADMAP.md was not
consulted.

## Goals & Non-Goals

**Goals**:
- Fixture and branching witness: `bwdList`, `bwdList_aft_succ_length`, `bwdExitNow`,
  `bwdExitLater`, `two_bwd_paths`
- Backward reachability on the branching backward graph: `IsBwdPath`, `AllBwdPathsMeet`,
  `bwd_reaches_x`, `allBwdPathsMeet_iff`
- Model and formula under test: `M`, `stabPast` (the frame F is Challenge scaffolding, see the
  note in the Challenge block)
- The backward summary and its decision: `stabPast_iff_aft`, `pastStab_iff_allBwdPathsMeet`,
  `decide_past_stab`, `decidable_past_stab`
- Goals stated in prose (not Challenge-pinned): the probe file at its declared path with the
  collection-style header (branching factor, outcome, effect on the two-factor presentation,
  honest limit, what it does NOT do, axiom record, citation hygiene, compile-check line); the
  gate wiring (one WIRED entry, one table row); the six-line axiom footer; a scoped commit of
  exactly the two declared files.

**Non-Goals**:
- No complexity claim, no automata or determinization work, no width bound, no tail-period bound
  (task hard constraints; `Probe710.not_finite_width_fmp` stands untouched).
- No general theorem that the summary's shape holds on every step-generated regular frame; the
  research report records that as analysis only, and formalizing it would change the probe's
  character ("decides nothing beyond this one fixture").
- No edit to `backward-dual-asymmetric-fixture.lean` or any other wired probe `.lean` file.
- No `reflectTime` transport; no re-derivation of the prototype's proofs.
- No C9-style register entry (conditional on a negative result that did not occur).
- No closing of task 725 (appears subsumable by E1 per the report; a task-management action for
  the orchestrator/user, not this task).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Concurrent writer on `scripts/check-evidence-probes.sh` (sibling 747 is dispatched with no `file_scope`; 720/725 declare the script but are `not_started`) | M | L | Re-read the script immediately before editing (Phase 3); stage only the two `file_scope` paths plus the plan file by explicit path; treat an unexpected foreign modification as stop-and-report, never overwrite. |
| Header axiom record drifts from the measured record | M | L | Phase 1 captures the printed `#print axioms` lines from the lifted file; Phase 2 copies those lines verbatim into the header and Phase 3 re-runs the compile and diffs the output against the header's record. |
| Over-reading the positive result ("the backward factor is decided") | M | M | Header carries the "honest limit" (finite backward branching gives a König-shaped uniform bound; finite computability under infinite backward branching is a device-selection question, out of scope) and a "what this does NOT do" paragraph mirroring E1's. |
| Header prose introduces a Lean error or lint (unterminated comment, long line, unused variable) | L | L | `lake env lean` on the single file after every header edit; fix forward, never suppress a linter. |
| `omega` creeps back into `bwd_reaches_x` during a tidy-up and pulls `Classical.choice` into the choice-free half | M | L | Lift the prototype verbatim; the plan forbids proof edits; Phase 3's axiom diff catches it. |
| E1 table-row amendment in the gate script misread as touching a wired probe | L | L | Optional, confined to the comment table, pointer-only; E1's `.lean` stays byte-identical (verified by `git status` in Phase 3). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel; this plan is a single sequential chain.

### Phase 1: Lift the prototype to its evidence path and compile [NOT STARTED]

**Goal**: The probe exists at its declared `file_scope` path, compiles clean under `lake env lean`,
and its measured axiom record is captured for the header.

**Tasks**:
- [ ] Re-read the E1 header (`specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`,
      the `/- Probe 719 ... -/` block) per the task description's instruction; confirm its
      "honest limit" paragraph still names the mirror fixture as the follow-up.
- [ ] Copy `specs/733_backward_dual_mirror_fixture_branching_probe/prototype/backward-dual-mirror-fixture.proto.lean`
      to `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` (new file).
- [ ] Replace the 5-line `PROTOTYPE (research dispatch)` banner with a provisional `/- Probe 733 ...
      -/` block ending in the collection's compile-check line
      (`lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`).
      Change nothing below `import FormalSystem`: keep `namespace Probe733Mirror`, every proof, and
      the six-line `#print axioms` footer exactly as in the prototype.
- [ ] Run `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`
      from the repository root; require exit 0, no errors, no warnings, and exactly six
      `'Probe733Mirror.<name>' depends on axioms: [...]` lines.
- [ ] Record the six printed axiom lines verbatim (scratchpad or progress file) for Phase 2.
- [ ] Record an issue-log entry (`issue-record.sh`, kind `win` or an explicit "nothing to
      record") for this phase.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The prototype is 550 lines / 73 declarations with a 6-line `#print axioms`
footer and compiles with 0 errors, 0 warnings, 0 `sorry` (carried from
`reports/01_backward-dual-mirror-fixture.md`, Executive Summary and Appendix); confirm at lift
time with `wc -l`, `grep -c '^#print axioms'`, `grep -c sorry` (expect 0 outside comments), and
the compile's exit status and output line count.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`
is the complete covering check -- the probe lives outside the Lake build graph, imports only
`FormalSystem`, and no file imports it, so the single-file compile is its entire blast radius.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` - new file, lifted
  from the prototype with a provisional header

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` exits 0
  with no `error`/`warning` lines and exactly six axiom lines.
- The axiom lines show `two_bwd_paths` axiom-free (no `depends on axioms` list beyond the empty
  set, as the prototype prints), `bwd_reaches_x` at `[propext]`, `allBwdPathsMeet_iff` at
  `[propext, Quot.sound]`, and `stabPast_iff_aft`, `pastStab_iff_allBwdPathsMeet`,
  `decide_past_stab` at `[propext, Classical.choice, Quot.sound]` -- any deviation is a
  stop-and-investigate signal (a proof was altered), not something to paper over in the header.
- `git status --short` shows the new probe file and nothing under `specs/evidence/` modified.

---

### Phase 2: Write the collection-style header [NOT STARTED]

**Goal**: The header states, with every claim backed by a named declaration, what the acceptance
criteria require: the fixture's backward branching factor, which way the result came out, and what
it does to the two-factor presentation -- plus the honest limit, the exclusions, and the measured
axiom record.

**Tasks**:
- [ ] Replace the provisional header with the full `/- Probe 733 ... -/` block, modelled on E1's
      header structure (bold-lead paragraphs, compile-check line last). Required paragraphs:
  - [ ] **Title line**: the backward dual of the finite-graph `⊡` summary on the MIRROR fixture --
        time-asymmetric AND backward-nondeterministic; E1's hard test.
  - [ ] **Why this fixture**: E1 (`backward-dual-asymmetric-fixture.lean`, `Probe719Backward`)
        ran on a backward-deterministic fixture whose backward factor is a singleton and names the
        mirror fixture as the follow-up; the finite-width obstruction
        (`Probe710.not_finite_width_fmp`) lives in the backward factor, so this is where the dual
        must be tested.
  - [ ] **The fixture**: Probe710's step graph with every arrow reversed -- carrier `bef k j` /
        `x k` / `aft k`; steps `bef k (j+1) → bef k j`, `bef k 0 → x k`, `x k → aft k`,
        `aft k → aft (k+1)`; forward deterministic (`step_bef_inv`, `step_x_inv`, `step_aft_inv`);
        **backward branching factor exactly 2 at every `aft (k+1)`** (`bwdList_aft_succ_length`
        by `rfl`, `two_preds_aft`), with two distinct backward root paths from the state under
        test that already differ at their first step (`two_bwd_paths`, axiom-free). Saturation via
        `TaskFrame.saturation_of_fib_finite` and `FrameOver.ofReflectiveRegular` (infinite
        carrier, finite fibres; `ofSlicedStep_isRegular` unavailable), transcribed not imported.
  - [ ] **Outcome: POSITIVE, state-dependent**: `pastStab_iff_allBwdPathsMeet`; True at the `aft`
        states, False at the `x` and `bef` states (`past_stab_at_aft`, `not_past_stab_at_x`,
        `not_past_stab_at_bef`); decision by `decide_past_stab` / `decidable_past_stab`; the
        clause-for-clause dual of `Probe718FiniteGraph.will_iff_allPathsMeet`.
  - [ ] **What is new relative to E1**: the universal quantifier over backward paths does not
        collapse to one chain; `bwd_reaches_x` closes both branches of `step_inv_aft` at every spine
        state by induction on the spine index with the uniform bound `n ≤ m + 1`; the canonicity
        argument's backward search (`aft_back`) routes through the two-way split.
  - [ ] **What it does to the two-factor presentation**: not falsified at the backward factor where
        the finite-width refutation inhabits; E1's "hard test is a mirror fixture, filed as a
        follow-up" note is discharged by this file (cite E1 by file name and declaration).
  - [ ] **The honest limit**: finite backward branching gives a König-shaped uniform depth bound;
        the residue -- finite computability of "all backward paths meet" under infinite backward
        branching -- is a device-selection question (`device-selection-probe.lean`), not a fixture
        question; say plainly that this settles the dual's shape at a branching backward factor and
        should not spawn an open-ended chain of "harder" fixtures.
  - [ ] **The `reflectTime` trap**: no semantic transport theorem exists; the argument is direct.
  - [ ] **Citation hygiene**: `decide_will` is ambiguous (`Probe718FiniteGraph` and
        `Probe718PathQuantifier`); qualify every citation.
  - [ ] **What this does NOT do**: no width bound, no tail-period, no complexity claim, no
        automata/determinization device, nothing beyond `⊡(Pp)` on this fixture;
        `not_finite_width_fmp` untouched.
  - [ ] **Axiom record**: the six lines captured in Phase 1, copied verbatim, with the cause named
        (`hist_canon` through `FrameOver.mem_HF_iff_adjacent` and
        `FrameOver.worldHistoryOfStepPath`, as in E1 and Probe710).
  - [ ] **Compile-check line**: `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`.
- [ ] Keep the body byte-identical to Phase 1's lift; adjust only docstrings if a docstring still
      says "prototype".
- [ ] Re-run `lake env lean` on the file; require exit 0, no errors/warnings, six axiom lines
      identical to Phase 1's capture.
- [ ] Record an issue-log entry for this phase.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The header's cited declaration names (`step_bef_inv`, `step_x_inv`,
`step_aft_inv`, `two_preds_aft`, `step_inv_aft`, `aft_back`, `hist_canon`, `past_stab_at_aft`,
`not_past_stab_at_x`, `not_past_stab_at_bef`) exist under those names in the lifted file (carried
from the report's Findings mapping table); confirm each with `grep -n '^theorem <name>\|^lemma <name>'`
on the lifted file before citing it, and use the file's actual name if any differs.

**Tier Justification**: The edit is confined to the opening block comment of one file, and
`lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` (~3 s)
covers the one blind spot of a comment-only edit -- an edit that escapes the `/- -/` boundary --
while the diff read-through confirms every changed hunk lies inside the comment.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` - header block only

**Verification**:
- Diff against the Phase 1 file shows changes only inside the opening `/- ... -/` block (and at
  most docstring wording).
- Header contains, as literal text, the branching factor ("2"), the outcome word "POSITIVE", a
  sentence on the two-factor presentation, the honest-limit paragraph, the "What this does NOT do"
  paragraph, the axiom record, and the compile-check line.
- `lake env lean` on the file exits 0 with six axiom lines matching Phase 1's capture.

---

### Phase 3: Wire into the evidence gate, run the full gate, and commit the two declared files [NOT STARTED]

**Goal**: The probe is held in place by `scripts/check-evidence-probes.sh`, the full gate set is
green, E1's `.lean` file is untouched, and exactly the declared `file_scope` files are committed.

**Tasks**:
- [ ] Re-read `scripts/check-evidence-probes.sh` immediately before editing (concurrent-sibling
      hazard); if the `WIRED` array or the comment table differs from the state recorded in
      `reports/01_backward-dual-mirror-fixture.md` in a way that touches the insertion point,
      stop and report rather than overwrite.
- [ ] Add `"seam-gluing-ray-product/backward-dual-mirror-fixture"` to the `WIRED=( ... )` array
      directly after `"seam-gluing-ray-product/backward-dual-asymmetric-fixture"`.
- [ ] Add a comment-table row under `# --- WIRED ---` directly after the E1 row, in the table's
      two-column wrapped style: `POSITIVE (backward factor, on the MIRROR fixture -- time-asymmetric
      AND backward-branching, factor 2 at every spine state): the backward stability operator at a
      seam state is exactly "every backward root path from that state meets the p-set", decided by
      backward reachability alone and STATE-DEPENDENTLY -- True at the aft states, False at x and
      bef; two distinct backward root paths from the state under test (two_bwd_paths); discharges
      E1's "mirror fixture filed as a follow-up" note. No automata, no width bound, no complexity
      claim.`
- [ ] Optional, pointer-only: amend the final clause of the E1 table row (the comment, not the
      `.lean` file) so "filed as a follow-up" points at the new entry. Skip if the row's wording
      has changed since the research read.
- [ ] `bash scripts/check-evidence-probes.sh` from the repository root; require exit 0 and the
      PASS summary with the wired count one higher than the pre-edit baseline.
- [ ] `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`
      once more; diff the six axiom lines against the header's axiom record (must match verbatim).
- [ ] `git status --short` and `git diff --stat -- specs/evidence/`: the only `specs/evidence/`
      change is the new probe; `backward-dual-asymmetric-fixture.lean` is byte-identical to HEAD.
- [ ] `bash .claude/scripts/verify-deploy.sh` (the complete gate set, per the `full` tier).
- [ ] Commit through `bash .claude/scripts/git-commit-scoped.sh --message "task 733 phase 3: wire
      mirror-fixture probe into the evidence gate" --session <session_id> --task 733 -- <explicit
      paths>` with exactly the two `file_scope` paths plus this plan file as the pathspec -- never
      `git add -A`, `git add .`, a directory pathspec, or `git commit -am`.
- [ ] Record an issue-log entry for this phase.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: Before the edit the gate holds 22 `WIRED` + 3 `WIRED_REPO` = 25 probes and
reports `PASS  all 25 wired probe(s) compile` (re-derived at plan time by counting the two arrays;
the 25 PASS baseline is carried from the report's Appendix); after the edit expect 26. Confirm at
implementation time by running the script before and after the edit -- a concurrent sibling may
have changed the count, in which case the expectation is "baseline + 1", not literally 26.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - one `WIRED` entry and one comment-table row (plus the
  optional E1 row pointer amendment)
- `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` - no planned change;
  re-verified and committed here

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0; its summary line reports every wired probe
  passing with the count equal to the pre-edit baseline plus one, and a PASS line for
  `seam-gluing-ray-product/backward-dual-mirror-fixture`.
- `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` exits
  0; its six axiom lines equal the header's axiom record.
- `git diff HEAD --stat -- specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`
  is empty (E1 untouched); no other wired probe `.lean` file is modified.
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- The phase commit contains exactly `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`,
  `scripts/check-evidence-probes.sh`, and the plan file (`git show --stat HEAD`).

## Lean Challenge Statements

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability

namespace Probe733Mirror

/-- `⊡(P p)`: the backward stability operator under test. -/
def stabPast : PlusFormula := sorry

/-- The mirror fixture's carrier: `bef k j` (`j + 1` steps before `x k`), `x k` (the `p` state of
thread `k`), `aft k` (the spine). -/
inductive Node : Type
  | bef : ℕ → ℕ → Node
  | x : ℕ → Node
  | aft : ℕ → Node
  deriving DecidableEq

/-- Probe710's step graph with every arrow reversed. -/
inductive Step : Node → Node → Prop
  | befNext (k j : ℕ) : Step (.bef k (j + 1)) (.bef k j)
  | befX (k : ℕ) : Step (.bef k 0) (.x k)
  | xAft (k : ℕ) : Step (.x k) (.aft k)
  | aftUp (k : ℕ) : Step (.aft k) (.aft (k + 1))

/-- Predecessor list; `bwdList (aft (k + 1)) = [aft k, x (k + 1)]`. -/
def bwdList : Node → List Node := sorry

/-- **Backward branching factor 2 at every spine state.** -/
theorem bwdList_aft_succ_length (k : ℕ) : (bwdList (.aft (k + 1))).length = 2 := sorry

/-- A backward root path from `w₀`: `g 0 = w₀` and each `g (n + 1)` steps to `g n`. -/
def IsBwdPath (w₀ : Node) (g : ℕ → Node) : Prop := sorry

/-- Every backward root path from `w₀` meets the `p`-set (an `x` state) at a positive index. -/
def AllBwdPathsMeet (w₀ : Node) : Prop := sorry

/-- The backward root path from `aft m` that exits to `x m` at once. -/
def bwdExitNow (m : ℕ) : ℕ → Node := sorry

/-- The backward root path from `aft (m + 1)` that first descends to `aft m`. -/
def bwdExitLater (m : ℕ) : ℕ → Node := sorry

/-- **The backward factor at `aft (m + 1)` is NOT a singleton**: two backward root paths from it
that already differ at their first step. -/
theorem two_bwd_paths (m : ℕ) :
    IsBwdPath (.aft (m + 1)) (bwdExitNow (m + 1)) ∧ IsBwdPath (.aft (m + 1)) (bwdExitLater m) ∧
      bwdExitNow (m + 1) 1 ≠ bwdExitLater m 1 := sorry

/-- **The branching step.** From `aft m`, EVERY backward root path meets an `x` state within
`m + 1` steps -- the König-style uniform depth bound. -/
theorem bwd_reaches_x (m : ℕ) : ∀ g : ℕ → Node, g 0 = .aft m →
    (∀ n, Step (g (n + 1)) (g n)) → ∃ n, 0 < n ∧ n ≤ m + 1 ∧ ∃ k, g n = .x k := sorry

/-- `AllBwdPathsMeet` holds exactly at the `aft` states. -/
theorem allBwdPathsMeet_iff (w : Node) : AllBwdPathsMeet w ↔ ∃ m, w = .aft m := sorry

instance : Nonempty Node := ⟨.x 0⟩

/-- The regular ℤ-frame generated by `Step`. Declared as an `abbrev` with `sorry`-discharged
obligations (not a `sorry`-bodied `def`) so that `F.toTaskFrame.WorldState` reduces to `Node` and
the statements below type-check exactly as the probe states them; `F` is scaffolding, not a pinned
identifier (the snapshot regex matches `theorem|lemma|def|instance` only). The landed probe keeps
`def F` with the real proof terms. -/
abbrev F : FrameOver intOrder :=
  FrameOver.ofReflectiveRegular Node (ofStepRel Step) sorry sorry sorry sorry sorry

/-- The model: `p` holds exactly at the `x` states. -/
def M : TaskModel F.toTaskFrame := sorry

/-- `⊡(Pp)` at `(τ, t)` iff the seam state is an `aft` state. -/
theorem stabPast_iff_aft (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    PlusTruthAt M τ t stabPast ↔ ∃ m, τ.state t = .aft m := sorry

/-- **The backward summary on a branching backward factor**: `⊡(Pp)` at a seam state is exactly
"every backward root path from that state meets the `p`-set". -/
theorem pastStab_iff_allBwdPathsMeet (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    PlusTruthAt M τ t stabPast ↔ AllBwdPathsMeet (τ.state t) := sorry

/-- The decision, state-dependent: True at `aft`, False at `x` and `bef`. -/
theorem decide_past_stab (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    (PlusTruthAt M τ t stabPast ↔ ∃ m, τ.state t = .aft m) := sorry

instance decidable_past_stab (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    Decidable (PlusTruthAt M τ t stabPast) := sorry

end Probe733Mirror
```

## Testing & Validation

- [ ] `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`
      exits 0 with no errors or warnings and exactly six `#print axioms` output lines (after
      Phases 1, 2, and 3).
- [ ] Axiom record: `two_bwd_paths` axiom-free; `bwd_reaches_x` `[propext]`; `allBwdPathsMeet_iff`
      `[propext, Quot.sound]`; `stabPast_iff_aft`, `pastStab_iff_allBwdPathsMeet`,
      `decide_past_stab` `[propext, Classical.choice, Quot.sound]` -- and the header's record
      equals the printed lines verbatim.
- [ ] No `sorry` in the probe outside comments (`grep -n sorry` on the file).
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with the wired count at baseline + 1 and a
      PASS line for the new probe.
- [ ] `backward-dual-asymmetric-fixture.lean` and every other wired probe `.lean` file are
      byte-identical to HEAD.
- [ ] Header literally states the backward branching factor (2), the outcome (POSITIVE), the
      effect on the two-factor presentation, the honest limit, and the "does NOT do" exclusions.
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0 (final-phase `full` gate).
- [ ] Signatures of the fifteen Challenge-pinned declarations in the landed file match
      `## Lean Challenge Statements` above (`bash .claude/scripts/lean-challenge-snapshot.sh --check`
      where available; otherwise a manual signature diff).

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` -- the probe
  (new; `file_scope`).
- `scripts/check-evidence-probes.sh` -- one new `WIRED` entry and one comment-table row
  (`file_scope`).
- `specs/733_backward_dual_mirror_fixture_branching_probe/summaries/01_backward-dual-mirror-fixture-summary.md`
  -- implementation summary written by the implementing dispatch's postflight.
- Issue-log entries under the task directory for each phase.

## Rollback/Contingency

- The probe is a new file outside the Lake build graph; if it fails to compile at any phase, do
  not wire it -- fix forward against the compiled prototype (which is the known-good reference),
  and if the lifted file cannot be made to compile, delete the lifted file and report `blocked`
  with the compiler output.
- If the gate script edit breaks `check-evidence-probes.sh`, revert the two hunks by hand (they
  are additive: one array string, one comment row) rather than with a tree-reverting git command.
- Do not use `git-snapshot.sh` in its default (reverting) mode as a checkpoint. If a genuine
  rollback of committed work becomes unavoidable, follow `context/contracts/recovery.md`'s rung
  (c) (snapshot, then smallest-scope rollback) with the task number passed explicitly.
- A negative finding at any point (a proof that no longer closes, an axiom line that changes) is a
  stop-and-report event, not a header-weakening event: the standing no-weakening rule applies to
  every wired probe in this collection.
