# Implementation Plan: Promote the countable-carrier rigidity results over ℝ

- **Task**: 654 - infinite_frame_rigidity_countable_real_durations
- **Status**: [COMPLETED]
- **Effort**: 7 hours
- **Dependencies**: 646, 652 (time-indexed frames and the Dedekind boundary — both already
  landed; `Semantics/TimeIndexed.lean` and `Semantics/TimeIndexedSharpness.lean` exist in-tree)
- **Research Inputs**: `specs/654_infinite_frame_rigidity_countable_real_durations/reports/01_infinite-frame-rigidity-countable-real.md`
- **Artifacts**: plans/01_promote-countable-real-rigidity.md (this file),
  summaries/01_promote-countable-real-rigidity-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research phase has already settled every question the task poses and has compiled every
answer sorry-free in two probes under this task's `probes/` directory. Q2 — the headline — is
confirmed: over `ℝ`, every task frame with countably many world states is static, with no
finiteness, density or Archimedean hypothesis. This plan therefore contains **no discovery
work**. It is a promotion plan: transcribe two bodies of already-green proof into library
modules, rename the probe-local placeholders to library-grade names, and discharge the full
wiring and gate obligations that every module-adding task in this tree carries.

The promotion is in two pieces, matching the two distinct dependency levels the proof has. The
topological engine — Sierpiński's theorem on countable closed partitions of the line, which
Mathlib does not carry — is Mathlib-shaped, imports nothing from `FormalSystem.*`, and goes to a
new `FormalSystem/ForMathlib/Topology/Sierpinski.lean`. The frame-level results, which consume it
plus *Limit* and *Saturation*, go to a new
`FormalSystem/Semantics/Correspondence/RigidityReal.lean` beside (never inside) `Rigidity.lean`,
whose module docstring advertises an import list of exactly `TaskFrame` plus
`Mathlib.Algebra.Order.Archimedean.Defs` and states that it "takes no topology".

**Definition of done**: both new modules plus the `ratClock_not_static` witness land green;
`lake build --wfail` exits 0; `scripts/check-module-invariants.sh` passes every check including
the C14 axiom baseline extended with `static_of_countable`; `lake exe mk_all --lib FormalSystem
--check` exits 0; `lean_verify` reports `[propext, Classical.choice, Quot.sound]` and no
`sorryAx` on every promoted theorem.

### Research Integration

Every phase below transcribes a named, compiled block of
`probes/02_countable-real-rigidity.lean` or `probes/01_clock-frames.lean`. The report's
Recommendations section (items 1–5) is the skeleton of this plan; three deviations from it are
recorded under Decisions below. The report's Tactic Survey Results carries two findings the
implementer must not rediscover: `abel` is unreliable on `↑D` for an abstract
`(D : TemporalOrder)` (use explicit `add_assoc`/`add_comm`), and `Set.countable_range` is the
wrong lemma for `Set.range τ.state` (use `Set.to_countable _`).

The report's Q3 UNVERIFIED item — whether some history must be *injective on an interval* — is
explicitly **not** gated on here. Q2 does not depend on it; it is a located obstruction recorded
for a separate task.

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap flag is set; no
`specs/ROADMAP.md` consultation was performed.

## Goals & Non-Goals

**Goals** (the identifier set this plan commits to proving; see `## Lean Challenge Statements`
for each one's exact signature):
- `Sierpinski.levelSet`, `Sierpinski.locallyConstantLocus`, `Sierpinski.mem_levelSet`,
  `Sierpinski.isOpen_locallyConstantLocus`, `Sierpinski.mem_locallyConstantLocus_iff`,
  `Sierpinski.const_of_isPreconnected`, `Sierpinski.const_of_isClosed_levelSet`,
  `Sierpinski.const_of_countable_range`
- `FormalSystem.Semantics.realOrder`,
  `FormalSystem.Semantics.FrameOver.levels_closed`,
  `FormalSystem.Semantics.FrameOver.exists_history_of_taskRel`,
  `FormalSystem.Semantics.FrameOver.constant_of_countable_range`,
  `FormalSystem.Semantics.FrameOver.static_of_countable`,
  `FormalSystem.Semantics.FrameOver.range_uncountable_of_nonconstant`,
  `FormalSystem.Semantics.FrameOver.uncountable_image_of_not_localConst`,
  `FormalSystem.Semantics.FrameOver.exists_local_clock`
- `FormalSystem.Semantics.Rigidity.realClock_not_static`,
  `FormalSystem.Semantics.Rigidity.padRel`, `FormalSystem.Semantics.Rigidity.paddedClock`,
  `FormalSystem.Semantics.Rigidity.paddedClock_taskRel`,
  `FormalSystem.Semantics.Rigidity.paddedClock_uncountable`,
  `FormalSystem.Semantics.Rigidity.paddedClock_not_static`,
  `FormalSystem.Semantics.Rigidity.ratClock_not_static`

Beyond that identifier set (which the `## Lean Challenge Statements` block pins statement-for-
statement), this plan also owns: the two new module files and their directory README; aggregator
entries in `FormalSystem/ForMathlib.lean` and `FormalSystem/Semantics/Correspondence.lean`; the
regenerated inventory blocks in `FormalSystem/ForMathlib/README.md` and the new
`FormalSystem/ForMathlib/Topology/README.md`; a hand-written Modules row and Key Results bullet
in `FormalSystem/Semantics/Correspondence/README.md`; a cross-reference paragraph in
`Rigidity.lean`'s module docstring; a `docs/theorem-index.md` row for `static_of_countable`; and
the paired C14 baseline entries in `scripts/check-module-invariants.sh`.

**Non-Goals**:
- Generalizing `static_of_countable` from `ℝ` to the manuscript's `TaskFrame.IsRTime` frame
  class. The report costs both routes and recommends against it here; it is a follow-on task.
- Settling Q3's "some history is injective on an interval". UNVERIFIED, with a located
  obstruction, is the recorded outcome.
- Any edit to `Rigidity.lean` or `RigiditySharpness.lean` beyond the cross-reference paragraph
  (Phase 5) and the `ratClock_not_static` addition (Phase 4).
- Any manuscript edit. A separate paper task consumes the report.
- Time-indexed frames. A sibling task owns that boundary; this plan touches neither
  `Semantics/TimeIndexed.lean` nor `Semantics/TimeIndexedSharpness.lean`.
- Re-running research. The probes are green and the verdicts are recorded; nothing below
  re-derives them.

## Decisions

Three deviations from the research report's Recommendations, each with its rationale, so the
implementer does not relitigate them mid-phase:

1. **`paddedClock` and `realClock_not_static` go into `RigidityReal.lean`, not
   `RigiditySharpness.lean`.** The report floated `RigiditySharpness.lean` because `paddedClock`
   shares the "the hypothesis cannot be dropped" role with `lexRatFrame`. But both witnesses
   need `ℝ` ballast and `Cardinal.not_countable_real`, and `RigiditySharpness.lean` currently
   imports only `Rigidity`, `Frames.Standard`, `LexCarrier` and `Mathlib.Data.Int.SuccPred` —
   adding `Mathlib.Analysis.Real.Cardinality` there would be import weight paid for a result
   about the *new* theorem. `RigidityReal.lean` already carries the real-analysis imports, and
   these two witnesses are precisely the cardinality-sharpness of `static_of_countable`. They
   belong beside it.
2. **`ratClock_not_static` does go into `RigiditySharpness.lean`** (Phase 4). It is the
   sharpness witness for the *finiteness* hypothesis of the existing
   `FrameOver.static_of_finite` — countable, dense, Archimedean, and not static — which is
   exactly that module's stated job. It needs no real-analysis import, only `Countable ℚ`.
3. **The `Sierpinski` helper definitions are generalized from `ℝ` to an arbitrary topological
   space; the two main theorems stay at `ℝ`.** `levelSet`, `locallyConstantLocus` and
   `const_of_isPreconnected` use only openness and preconnectedness, so stating them at
   `{α : Type*} [TopologicalSpace α]` costs nothing and is what a Mathlib-shaped module should
   say. `const_of_isClosed_levelSet` genuinely needs `ℝ` (Baire plus the order structure). This
   generalization has a bounded escape hatch — see Phase 1's Scope Hypothesis.

Two naming decisions, fixed here so they are not re-argued:

- The probe's one-letter `S` and `U` become `Sierpinski.levelSet` and
  `Sierpinski.locallyConstantLocus`. The report flagged these as placeholders far too short for
  a Mathlib-shaped file.
- `const_of_preconnected` becomes `const_of_isPreconnected`, matching Mathlib's `IsPreconnected`
  spelling. The remaining probe names are already library-grade and carry over unchanged, except
  `exists_history`, which becomes `exists_history_of_taskRel` (the bare name is far too generic
  for the `FrameOver` namespace).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `lake build --wfail` fails on lints a standalone `lake env lean` probe never sees (docstring coverage C19, `simp`-argument lints, C16 `env_linter` batch, C28 warning budget) | M | M | Phases 1–4 each end with `lake build --wfail` on the touched module before the phase closes. Give every promoted declaration a docstring during transcription, not afterwards — C19's floor is 90% and the new modules are the marginal contribution. |
| Naming collision: `Static`, `UniformDwell`, `static_of_finite` already live in `Rigidity.lean`'s namespaces and `static_of_countable` must sit in `FrameOver` beside them | M | L | Before writing either module, run `lean_local_search` (or `grep -rn` over `FormalSystem/`) on each new base identifier. The report found no collision but did not verify exhaustively. |
| The `Sierpinski` generalization to an arbitrary topological space (Decision 3) costs more elaboration friction than expected | L | M | Bounded escape hatch in Phase 1's Scope Hypothesis: if the generalization is not green within ~15 minutes, keep every declaration at `ℝ` exactly as the probe states them and record the retreat as a `#### Reasoned Exclusions` row. The theorem set is unaffected either way. |
| C33 requires the repository-root `FormalSystem.lean` to be byte-for-byte the `mk_all` output; a hand-added import line diverges | M | M | Never hand-edit `FormalSystem.lean`. Run `lake exe mk_all --lib FormalSystem` to regenerate, then `--check` to confirm exit 0. |
| The C14 baseline is two heredocs (`C14_BASELINE` and the `C14LEAN` source) compared by exact string equality and must list the same declarations in the same order | M | M | Phase 6 edits both together, appending to each, and verifies with a full `scripts/check-module-invariants.sh` run. The script's own header comment states the pairing requirement. |
| `abel` fails on `↑D` for an abstract `(D : TemporalOrder)` | L | M | Recorded in the report's Tactic Survey. Use explicit `add_assoc`/`add_comm` rewriting in `padRel`/`paddedClock`, which are the only abstract-`D` declarations promoted. |
| `import Mathlib` in probe `02` is transcribed verbatim into a library module | H | L | The narrowed import list is already compiled green and is spelled out in Phase 1's tasks. A promoted module must never `import Mathlib`. |
| Q3's UNVERIFIED item is mistaken for a gap that blocks Q2 | L | L | It is not, and nothing below gates on it. `static_of_countable` is proved from `constant_of_countable_range`, which does not mention injectivity. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 2, 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 1 and 4 touch disjoint files
(`ForMathlib/**` plus the two aggregators, versus `Correspondence/RigiditySharpness.lean`) and
share only `FormalSystem.lean`, which is regenerated rather than hand-edited; if they are run in
parallel, the `mk_all` regeneration must be run once after both land rather than once per phase.

### Phase 1: Sierpiński's theorem into ForMathlib [COMPLETED]

**Goal**: `FormalSystem/ForMathlib/Topology/Sierpinski.lean` exists, compiles under
`lake build --wfail`, imports nothing from `FormalSystem.*`, and carries the eight declarations
pinned in `## Lean Challenge Statements` block 1.

**Tasks**:
- [x] Run a collision check on the new base identifiers (`levelSet`, `locallyConstantLocus`,
      `mem_levelSet`, `isOpen_locallyConstantLocus`, `mem_locallyConstantLocus_iff`,
      `const_of_isPreconnected`, `const_of_isClosed_levelSet`, `const_of_countable_range`) with
      `lean_local_search` or `grep -rn` over `FormalSystem/`, before writing anything.
- [x] Create `FormalSystem/ForMathlib/Topology/Sierpinski.lean` with the standard copyright
      header and the narrowed import list, already compiled green by the research phase:
      `Mathlib.Topology.Baire.CompleteMetrizable`, `Mathlib.Topology.Baire.Lemmas`,
      `Mathlib.Topology.Order.Monotone`, `Mathlib.Topology.Order.IntermediateValue`,
      `Mathlib.Topology.Instances.Real.Lemmas`. **No `import Mathlib`, and no
      `import FormalSystem.*`** — the dependency rule in `ForMathlib/README.md` is checkable by
      `grep -rn '^import FormalSystem' FormalSystem/ForMathlib/` returning nothing.
- [x] Write a module docstring stating what the theorem is, that Mathlib does not carry it (the
      four `Sierpinski*` hits in Mathlib are all the Sierpiński *space*), and the proof outline:
      the locally-constant locus is open; on its complement — closed, hence complete, hence
      Baire — `nonempty_interior_of_iUnion_of_closed` produces a window on which one value
      dominates, and that value propagates across the whole window via
      `IsClosed.csSup_mem`/`IsClosed.csInf_mem`, contradicting membership in the complement.
      Record explicitly that the proof does **not** need the complement to be perfect, which is
      where the textbook proof spends most of its effort.
- [x] Transcribe `Probe.Sierp` from
      `specs/654_infinite_frame_rigidity_countable_real_durations/probes/02_countable-real-rigidity.lean`
      (section `Sierp`, `namespace Sierp` through `end Sierp`) under `namespace Sierpinski`,
      applying the renames fixed under Decisions. The two definition bodies, which the Challenge
      block pins as `sorry` by format rule, are:
      `levelSet h a := {t | h t = a}` and `locallyConstantLocus h := ⋃ a, interior (levelSet h a)`.
- [x] Generalize `levelSet`, `locallyConstantLocus`, `mem_levelSet`,
      `isOpen_locallyConstantLocus`, `mem_locallyConstantLocus_iff` and
      `const_of_isPreconnected` to `{α : Type*} [TopologicalSpace α]`, `{W : Type*}`; keep
      `const_of_isClosed_levelSet` and `const_of_countable_range` at `ℝ`. Widen `Type` to
      `Type*` throughout.
- [x] Preserve the probe's `omit [Countable W] in` lines wherever the generalized statement no
      longer needs the instance — the report records that this exact linter bit a sibling task.
- [x] Give every one of the eight declarations a docstring (C19 floor is 90%).
- [x] Create `FormalSystem/ForMathlib/Topology/README.md`, modelled on
      `FormalSystem/ForMathlib/Order/README.md`: the "imports nothing from `FormalSystem.*`"
      paragraph, a `<!-- BEGIN GENERATED: inventory dir=FormalSystem/ForMathlib/Topology -->`
      block, a Key Definitions section, Related Documentation links, and a `*Last verified:*`
      line.
- [x] Add `import FormalSystem.ForMathlib.Topology.Sierpinski` to `FormalSystem/ForMathlib.lean`
      and a matching bullet to its `## Contents` docstring list.
- [x] Add a Role description for the new `Topology/` row to `FormalSystem/ForMathlib/README.md`
      (the generated block is `rows=subdirs`, so the row itself appears automatically; the
      trailing Role column is hand-written), then regenerate:
      `bash scripts/check-module-invariants.sh --emit-inventory`.
- [x] Regenerate the root module list: `lake exe mk_all --lib FormalSystem`. Never hand-edit
      `FormalSystem.lean` (C33 compares it byte-for-byte).
- [x] `lake build --wfail` green on the touched modules.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: 8 declarations, approximately 200 lines including the module docstring,
transcribed from roughly 155 probe lines. Confirm at implementation time by counting
declarations in the finished file against the Challenge block's identifier list; a divergence
means the generalization forced a split or a merge and the Challenge block must be reconciled
before the phase closes. A second hypothesis is that Decision 3's generalization to an arbitrary
topological space is free: confirm by compiling the generalized helpers first, before touching
the two `ℝ`-specific theorems. If they are not green within ~15 minutes, retreat to the probe's
`ℝ`-only statements and record the retreat in a `#### Reasoned Exclusions` subsection under this
phase, with the failing goal as Evidence.

**Files to modify**:
- `FormalSystem/ForMathlib/Topology/Sierpinski.lean` — new module (the topological engine)
- `FormalSystem/ForMathlib/Topology/README.md` — new directory README with a generated inventory
  block
- `FormalSystem/ForMathlib.lean` — new import plus a `## Contents` bullet
- `FormalSystem/ForMathlib/README.md` — Role text for the new `Topology/` subdir row; block
  regenerated, not hand-edited
- `FormalSystem.lean` — regenerated by `mk_all`, never hand-edited

**Verification**:
- `lake build --wfail` exits 0
- `grep -rn '^import FormalSystem' FormalSystem/ForMathlib/` returns nothing
- `grep -n 'import Mathlib$' FormalSystem/ForMathlib/Topology/Sierpinski.lean` returns nothing
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports no stale block
- `lean_verify` on `Sierpinski.const_of_isClosed_levelSet` reports
  `[propext, Classical.choice, Quot.sound]` and no `sorryAx`

---

### Phase 2: RigidityReal.lean — the Q2 headline [COMPLETED]

**Goal**: `FormalSystem/Semantics/Correspondence/RigidityReal.lean` exists with the four
frame-level core results, `static_of_countable` among them, and is wired into the Correspondence
aggregator.

**Tasks**:
- [x] Collision-check `levels_closed`, `exists_history_of_taskRel`, `constant_of_countable_range`
      and `static_of_countable` against the `FrameOver` namespace before writing.
- [x] Create `FormalSystem/Semantics/Correspondence/RigidityReal.lean` with the copyright header
      and imports `FormalSystem.Semantics.Extension`,
      `FormalSystem.Semantics.Correspondence.Rigidity`,
      `FormalSystem.ForMathlib.Topology.Sierpinski`. No `import Mathlib`.
- [x] Write a module docstring that states the theorem, states the axiom division of labour
      exactly as the report records it — *Saturation* supplies the total history through
      `thm:extension` (which is where Zorn, and hence `Classical.choice`, enters); *Limit* makes
      the level sets closed; *Seriality* plus the reflection law give the positive half of
      `Static`; *Compositionality* contributes only what `thm:extension` itself needs — and
      records that density and the Archimedean property are **not** used, Dedekind completeness
      via Baire replacing them. Cite manuscript anchors by label (`def:frame#Limit`,
      `def:frame-properties`, `def:world-history`, `thm:extension`), never by line number.
- [x] Declare `noncomputable abbrev realOrder : TemporalOrder := TemporalOrder.of ℝ` (the
      probe's `RO`, renamed).
- [x] Transcribe `Probe.levels_closed`, `Probe.exists_history` (renamed
      `exists_history_of_taskRel`), `Probe.constant_of_countable_range` and
      `Probe.static_of_countable` from probe `02`, lines beginning at
      `/-! ## The frame-level consequences over ℝ -/`, into `namespace FormalSystem.Semantics`,
      `namespace FrameOver`, updating the `Sierp.*` references to the Phase 1 names.
- [x] Note in `exists_history_of_taskRel`'s docstring that the domain `{0, x}` is not convex, so
      this is `thm:extension` and not `cor:occurrence` — the same construction
      `Semantics/DeterministicBridge.lean`'s `deterministic_of_singletonClasses` uses.
- [x] Docstring every declaration.
- [x] Add `import FormalSystem.Semantics.Correspondence.RigidityReal` to
      `FormalSystem/Semantics/Correspondence.lean` and a matching `## Modules` bullet to its
      docstring.
- [x] Regenerate `FormalSystem.lean` with `lake exe mk_all --lib FormalSystem`.
- [x] `lake build --wfail` green.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: one `abbrev` plus 4 theorems, approximately 140 lines, from roughly 90
probe lines. Confirm by checking the finished file's declaration list against block 2 of
`## Lean Challenge Statements`; any extra helper the transcription needs must be added to that
block before the phase closes, not left undeclared.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/RigidityReal.lean` — new module, Q2 core
- `FormalSystem/Semantics/Correspondence.lean` — new import plus `## Modules` bullet
- `FormalSystem.lean` — regenerated by `mk_all`

**Verification**:
- `lake build --wfail` exits 0
- `lean_verify FormalSystem.Semantics.FrameOver.static_of_countable` reports
  `[propext, Classical.choice, Quot.sound]` and no `sorryAx`
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `grep -c 'sorry' FormalSystem/Semantics/Correspondence/RigidityReal.lean` is 0

---

### Phase 3: Q3 and the cardinality-sharpness witnesses [COMPLETED]

**Goal**: `RigidityReal.lean` additionally carries the Q3 local-clock results and the two
witnesses showing the Q2 boundary is sharp in cardinality.

**Tasks**:
- [x] Add `import Mathlib.Analysis.Real.Cardinality` (for `Cardinal.not_countable_real`) and
      `FormalSystem.Semantics.Frames.Standard` (for `translationFrame` /
      `translationFrame_taskRel`) to `RigidityReal.lean`.
- [x] Transcribe `Probe.range_uncountable_of_nonconstant`,
      `Probe.uncountable_image_of_not_localConst` and `Probe.exists_local_clock` from probe `02`
      into the `FrameOver` namespace, updating `Sierp.U` to
      `Sierpinski.locallyConstantLocus`.
- [x] In `exists_local_clock`'s docstring, state plainly what is and is not proved: at a time
      where the history is not locally constant, *every* window carries uncountably many world
      states; the stronger reading — that some history is **injective on an interval** — is
      **UNVERIFIED**, with the obstruction being whether a history that is injective on no
      interval can satisfy the composition half of `def:frame#Compositionality`. Point at this
      task's report for the full statement of the obstruction.
- [x] Transcribe `Probe.realClock_not_static` and the padded-clock block (`Probe.padRel`,
      `Probe.paddedClock`, `Probe.paddedClock_taskRel`, `Probe.paddedClock_uncountable`,
      `Probe.paddedClock_not_static`) from
      `probes/01_clock-frames.lean` into `namespace FormalSystem.Semantics.Rigidity` inside
      `RigidityReal.lean` — see Decision 1 for why here and not in `RigiditySharpness.lean`.
- [x] Use explicit `add_assoc`/`add_comm` rather than `abel` anywhere the goal mentions `↑D` for
      an abstract `(D : TemporalOrder)`; the report's Tactic Survey records `abel` failing there.
- [x] Keep `paddedClock_taskRel` `@[simp]`, as the probe has it.
- [x] Docstring every added declaration; state in the padded-clock block's header that it fills
      the whole uncountable row of the report's census table at `ℤ`, `ℚ`, `ℚ ×ₗ ℚ` and `ℝ` at
      once, that its relation is functional so *Saturation* is
      `TaskFrame.saturation_of_fib_subsingleton` and *Limit* is `TaskFrame.limit_of_shift` at
      the first projection.
- [x] `lake build --wfail` green.

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: 8 further declarations added to a single existing module, approximately
180 lines, and **no** change to any signature outside that module. *(Confirmed at implementation
time with one correction: the count is **9**, not 8 — the plan's own `- **Goals**:` list and
`## Lean Challenge Statements` block 3 both enumerate nine declarations for this phase
(`range_uncountable_of_nonconstant`, `uncountable_image_of_not_localConst`, `exists_local_clock`,
`realClock_not_static`, `padRel`, `paddedClock`, `paddedClock_taskRel`, `paddedClock_uncountable`,
`paddedClock_not_static`), so the "8" was an arithmetic slip in this field, not a divergence in
the declaration set; nothing in the Challenge block needed reconciling. 166 lines added, and
`git diff --stat` lists `RigidityReal.lean` as the only `.lean` file changed.)* Confirm the second half by
`git diff --stat` showing `RigidityReal.lean` as the only `.lean` file touched by this phase; if
any other module changed, the phase is `interface`, not `local`, and its verification must widen
accordingly before it closes.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/RigidityReal.lean` — two new imports and the Q3 plus
  sharpness blocks

**Verification**:
- `lake build --wfail` exits 0
- `lean_verify` on `FormalSystem.Semantics.FrameOver.exists_local_clock` and
  `FormalSystem.Semantics.Rigidity.paddedClock_not_static` reports
  `[propext, Classical.choice, Quot.sound]` and no `sorryAx`
- `git diff --stat` for this phase lists `RigidityReal.lean` as the only `.lean` file changed

---

### Phase 4: `ratClock_not_static` into RigiditySharpness.lean [COMPLETED]

**Goal**: the rational clock — countable, dense, Archimedean, not static — is a library-citable
witness that the finiteness hypothesis of `FrameOver.static_of_finite` cannot be weakened to
countability.

**Tasks**:
- [x] Add `import Mathlib.Data.Rat.Denumerable` to
      `FormalSystem/Semantics/Correspondence/RigiditySharpness.lean` (for the `Countable ℚ`
      instance); `Frames.Standard` and `Rigidity` are already imported there.
- [x] Add `abbrev ratOrder : TemporalOrder := TemporalOrder.of ℚ` *(deviation: altered —
      `noncomputable` dropped. `TemporalOrder.of ℚ` is computable, as the existing
      `Metalogic/Conservativity/MinusChainCompleteness.lean` abbrev and probe `01` both show;
      `noncomputable` on it is rejected by Lean. The statement is unaffected.)* and
      `theorem ratClock_not_static` to `namespace FormalSystem.Semantics.Rigidity`, transcribed
      from `probes/01_clock-frames.lean`. Note the probe's finding that `norm_num at h` does not
      reduce through the `FrameOver.WorldState` projection: use
      `absurd h1 (by norm_num)` with an explicit `(0 : ℚ) = 1` ascription.
- [x] Docstring it as the countability-sharpness witness for `static_of_finite`, and state in
      the docstring that the *carrier* here is `ℚ` and is countable
      (`inferInstanceAs (Countable ℚ)`), the duration order is dense and Archimedean, and the
      frame is nevertheless not static — so countable plus dense plus Archimedean is not enough
      for rigidity; the escape is a state space that carries a clock reading.
- [x] Extend `RigiditySharpness.lean`'s module docstring with a third bullet for this witness,
      beside the two existing "density cannot be dropped" / "Archimedean cannot be dropped" ones.
- [x] `lake build --wfail` green.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 1 `abbrev` plus 1 theorem plus 1 import plus a docstring bullet, in one
file, approximately 30 lines. Confirm by `git diff --stat` listing `RigiditySharpness.lean` as
the only file changed.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/RigiditySharpness.lean` — one import, one `abbrev`, one
  theorem, one docstring bullet

**Verification**:
- `lake build --wfail` exits 0
- `lean_verify FormalSystem.Semantics.Rigidity.ratClock_not_static` reports
  `[propext, Classical.choice, Quot.sound]` and no `sorryAx`

---

### Phase 5: Documentation wiring [COMPLETED]

**Goal**: every documentation surface that indexes these results carries them, and
`Rigidity.lean` points at its new topology-consuming neighbour.

**Tasks**:
- [x] Add a cross-reference paragraph to `Rigidity.lean`'s module docstring, in its existing
      `## Scope note: time-indexed frames` section or in a new sibling scope note: over a
      Dedekind-complete duration order a **countable** carrier already forces static, with no
      density and no Archimedean hypothesis
      (`Semantics/Correspondence/RigidityReal.lean`, `FrameOver.static_of_countable`), and that
      module is kept separate precisely because it consumes topology, which this one's `##
      Import discipline` section promises not to. Do not otherwise touch `Rigidity.lean`.
- [x] Add two rows to the hand-written Modules table in
      `FormalSystem/Semantics/Correspondence/README.md` — one for `RigidityReal.lean`, and an
      updated line count and description for `RigiditySharpness.lean`. This table is **not**
      wrapped in a `BEGIN GENERATED` block; it is hand-maintained, unlike
      `ForMathlib/README.md`'s.
- [x] Add a Key Results bullet to the same README for `FrameOver.static_of_countable`, naming
      the axiom division of labour in one line and pointing at `RigidityReal.lean`.
- [x] Extend the `## Dependencies` section of that README if the new module introduces an import
      edge it does not already record (it introduces `FormalSystem.ForMathlib.Topology` and
      `FormalSystem.Semantics.Extension` into the Correspondence subtree).
- [x] Add a row to `docs/theorem-index.md` beside the two existing Rigidity rows: paper label
      `—`, statement "Over `ℝ` every task frame with countably many world states is static — no
      finiteness, density or Archimedean hypothesis", Lean name
      `FormalSystem.Semantics.FrameOver.static_of_countable`, file
      `FormalSystem/Semantics/Correspondence/RigidityReal.lean`, frame class `—`, axioms
      `pcq pinned:C14`. Path only, no line numbers.
- [x] Re-run `bash scripts/check-module-invariants.sh --emit-inventory` to refresh any generated
      block whose line counts moved.

**Timing**: 0.75 hours

**Depends on**: 2, 3, 4

**Verification Tier**: prose

**Scope Hypothesis**: 4 documentation files touched and zero Lean semantics changed — the only
`.lean` edit is a docstring. Confirm by reading the diff: every changed hunk in
`Rigidity.lean` must lie inside the `/-! ... -/` module docstring. If any hunk falls outside it,
this phase is not `prose` and must be re-verified at `full` before closing.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/Rigidity.lean` — module-docstring cross-reference only
- `FormalSystem/Semantics/Correspondence/README.md` — Modules rows, Key Results bullet,
  Dependencies
- `docs/theorem-index.md` — one row for `static_of_countable`
- `FormalSystem/ForMathlib/README.md` — regenerated line counts, if they moved

**Verification**:
- Every changed hunk in `Rigidity.lean` lies inside its module docstring (diff read-through)
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports no stale block
- C5, C12, C13 and C15 pass in the Phase 6 full run (module paths, source paths, relative links
  and paper anchors all resolve)

---

### Phase 6: C14 axiom pinning and the full gate sweep [COMPLETED]

**Goal**: `static_of_countable` is machine-pinned rather than prose-only, and the whole gate set
is green.

**Tasks**:
- [x] Append `'FormalSystem.Semantics.FrameOver.static_of_countable' depends on axioms:
      [propext, Classical.choice, Quot.sound]` to the `C14_BASELINE` heredoc in
      `scripts/check-module-invariants.sh`, immediately after the existing
      `FrameOver.static_of_finite` line, and append the matching
      `#print axioms FormalSystem.Semantics.FrameOver.static_of_countable` to the `C14LEAN`
      heredoc **at the same position**. The two heredocs are compared by exact string equality
      and must list the same declarations in the same order — the script's own header comment
      states this; edit them together.
- [x] Decide and record whether `Sierpinski.const_of_isClosed_levelSet` is also pinned. Default:
      yes, appended to both heredocs after the `static_of_countable` pair, since it is the one
      import Mathlib does not supply and the `docs/theorem-index.md` row's claim rests on it.
      If it is not pinned, it must not be described as pinned anywhere.
- [x] Run the full gate set and record each result:
      - `lake build --wfail`
      - `bash scripts/check-module-invariants.sh`
      - `lake exe mk_all --lib FormalSystem --check`
      - `bash scripts/check-module-invariants.sh --emit-inventory --check`
- [x] Run `lean_verify` on every promoted theorem named in `## Lean Challenge Statements` and
      confirm `[propext, Classical.choice, Quot.sound]` with no `sorryAx` on each.
- [x] If C28 (per-file warning budget) flags either new module, add its entry to
      `scripts/warning-budget.txt` only if the warnings are genuinely irreducible; otherwise fix
      the warnings.
- [x] Commit. Do not push and do not open a PR.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: 2 paired heredoc entries (4 appended lines total across the two heredocs).
Confirm at implementation time by running `bash scripts/check-module-invariants.sh` and reading
C14's own output: a mismatch in either count or order fails C14 as a HARD STOP, which is the
confirmation mechanism. Do not re-baseline C14 to make it pass.

**Files to modify**:
- `scripts/check-module-invariants.sh` — paired `C14_BASELINE` / `C14LEAN` entries
- `scripts/warning-budget.txt` — only if C28 requires it

**Verification**:
- `lake build --wfail` exits 0
- `bash scripts/check-module-invariants.sh` reports every check PASS, C14 among them
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `lean_verify` on each promoted theorem: standard axioms only, no `sorryAx`
- `grep -rn 'sorry' FormalSystem/ForMathlib/Topology/Sierpinski.lean FormalSystem/Semantics/Correspondence/RigidityReal.lean`
  returns nothing

---

## Lean Challenge Statements

The three blocks below concatenate in document order to form the Challenge module. Every body is
`sorry` per the format rule, including the two `def` bodies — those two bodies are given
literally in Phase 1's task list, since this section pins statements only.

```lean
import Mathlib.Topology.Baire.CompleteMetrizable
import Mathlib.Topology.Baire.Lemmas
import Mathlib.Topology.Order.Monotone
import Mathlib.Topology.Order.IntermediateValue
import Mathlib.Topology.Instances.Real.Lemmas

namespace Sierpinski

variable {α : Type*} [TopologicalSpace α] {W : Type*}

def levelSet (h : α → W) (a : W) : Set α := sorry

def locallyConstantLocus (h : α → W) : Set α := sorry

theorem mem_levelSet {h : α → W} {t : α} {a : W} : t ∈ levelSet h a ↔ h t = a := sorry

theorem isOpen_locallyConstantLocus (h : α → W) : IsOpen (locallyConstantLocus h) := sorry

theorem mem_locallyConstantLocus_iff {h : α → W} {t : α} :
    t ∈ locallyConstantLocus h ↔ t ∈ interior (levelSet h (h t)) := sorry

theorem const_of_isPreconnected {h : α → W} {C : Set α} (hC : IsPreconnected C)
    (hCU : C ⊆ locallyConstantLocus h) {c₀ : α} (hc₀ : c₀ ∈ C) :
    ∀ t ∈ C, h t = h c₀ := sorry

theorem const_of_isClosed_levelSet {V : Type*} [Countable V] (h : ℝ → V)
    (hc : ∀ a, IsClosed (levelSet h a)) : ∀ s t : ℝ, h s = h t := sorry

theorem const_of_countable_range {V : Type*} (f : ℝ → V) (hcount : (Set.range f).Countable)
    (hcl : ∀ a : V, IsClosed (levelSet f a)) : ∀ s t : ℝ, f s = f t := sorry

end Sierpinski
```

```lean
import FormalSystem.Semantics.Extension
import FormalSystem.Semantics.Correspondence.Rigidity
import FormalSystem.Semantics.Frames.Standard
import Mathlib.Analysis.Real.Cardinality

namespace FormalSystem.Semantics

open TaskFrame

noncomputable abbrev realOrder : TemporalOrder := TemporalOrder.of ℝ

namespace FrameOver

variable (F : FrameOver realOrder)

theorem levels_closed (τ : WorldHistory F.toTaskFrame) (a : F.WorldState) :
    IsClosed {t : ℝ | τ.state t = a} := sorry

theorem exists_history_of_taskRel (w u : F.WorldState) (x : ℝ) (hx : x ≠ 0)
    (hR : F.TaskRel w x u) :
    ∃ σ : WorldHistory F.toTaskFrame, σ.state 0 = w ∧ σ.state x = u := sorry

theorem constant_of_countable_range (τ : WorldHistory F.toTaskFrame)
    (hcount : (Set.range τ.state).Countable) : ∀ s t : ℝ, τ.state s = τ.state t := sorry

theorem static_of_countable [Countable F.WorldState] : Static F.TaskRel := sorry

theorem range_uncountable_of_nonconstant (τ : WorldHistory F.toTaskFrame) {s t : ℝ}
    (h : τ.state s ≠ τ.state t) : ¬ (Set.range τ.state).Countable := sorry

theorem uncountable_image_of_not_localConst (τ : WorldHistory F.toTaskFrame) {t : ℝ}
    (ht : t ∉ Sierpinski.locallyConstantLocus τ.state) {r : ℝ} (hr : 0 < r) :
    ¬ (τ.state '' Set.Icc (t - r) (t + r)).Countable := sorry

theorem exists_local_clock (τ : WorldHistory F.toTaskFrame) {s₀ t₀ : ℝ}
    (hne : τ.state s₀ ≠ τ.state t₀) :
    ∃ t : ℝ, ∀ r : ℝ, 0 < r → ¬ (τ.state '' Set.Icc (t - r) (t + r)).Countable := sorry

end FrameOver
end FormalSystem.Semantics
```

```lean
import Mathlib.Data.Rat.Denumerable

namespace FormalSystem.Semantics.Rigidity

open FormalSystem.Semantics TaskFrame

theorem realClock_not_static :
    ¬ Static (translationFrame realOrder).TaskRel := sorry

def padRel (D : TemporalOrder) : (↑D × ℝ) → ↑D → (↑D × ℝ) → Prop := sorry

noncomputable def paddedClock (D : TemporalOrder) : FrameOver D := sorry

@[simp] theorem paddedClock_taskRel {D : TemporalOrder} (w : ↑D × ℝ) (x : ↑D) (u : ↑D × ℝ) :
    (paddedClock D).TaskRel w x u ↔ (u.1 = w.1 + x ∧ u.2 = w.2) := sorry

theorem paddedClock_uncountable (D : TemporalOrder) :
    ¬ Countable (paddedClock D).WorldState := sorry

theorem paddedClock_not_static (D : TemporalOrder) :
    ¬ Static (paddedClock D).TaskRel := sorry

theorem ratClock_not_static :
    ¬ Static (translationFrame (TemporalOrder.of ℚ)).TaskRel := sorry

end FormalSystem.Semantics.Rigidity
```

## Testing & Validation

- [x] `lake build --wfail` exits 0 with the full tree built
- [x] `bash scripts/check-module-invariants.sh` reports PASS on every check, with C14 asserting
      the new `static_of_countable` baseline entry and C3 finding zero structural `sorry`
- [x] `lake exe mk_all --lib FormalSystem --check` exits 0 (C33's byte-for-byte root list)
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check` finds no stale
      generated inventory block
- [x] `lean_verify` on `Sierpinski.const_of_isClosed_levelSet`,
      `FormalSystem.Semantics.FrameOver.static_of_countable`,
      `FormalSystem.Semantics.FrameOver.levels_closed`,
      `FormalSystem.Semantics.FrameOver.exists_local_clock`,
      `FormalSystem.Semantics.Rigidity.ratClock_not_static` and
      `FormalSystem.Semantics.Rigidity.paddedClock_not_static`: each reports
      `[propext, Classical.choice, Quot.sound]` and no `sorryAx`
- [x] `grep -rn '^import FormalSystem' FormalSystem/ForMathlib/` returns nothing (the ForMathlib
      dependency rule)
- [x] No promoted module contains a bare `import Mathlib`
- [x] Every identifier named under `- **Goals**:` resolves to a real declaration in the tree

## Artifacts & Outputs

- `FormalSystem/ForMathlib/Topology/Sierpinski.lean` — new: Sierpiński's theorem on countable
  closed partitions of the line, Mathlib-shaped, importing nothing from `FormalSystem.*`
- `FormalSystem/ForMathlib/Topology/README.md` — new directory README with a generated inventory
  block
- `FormalSystem/Semantics/Correspondence/RigidityReal.lean` — new: the frame-level results, Q2
  and Q3 plus the cardinality-sharpness witnesses
- `FormalSystem/ForMathlib.lean`, `FormalSystem/Semantics/Correspondence.lean` — aggregator
  entries
- `FormalSystem/ForMathlib/README.md`, `FormalSystem/Semantics/Correspondence/README.md` —
  inventory and Key Results wiring
- `FormalSystem/Semantics/Correspondence/Rigidity.lean` — module-docstring cross-reference only
- `FormalSystem/Semantics/Correspondence/RigiditySharpness.lean` — the `ratClock_not_static`
  witness
- `docs/theorem-index.md` — one row for `static_of_countable`
- `scripts/check-module-invariants.sh` — paired C14 baseline entries
- `FormalSystem.lean` — regenerated by `mk_all`
- `specs/654_infinite_frame_rigidity_countable_real_durations/summaries/01_*-summary.md` — the
  implementation summary

The probes under `specs/654_infinite_frame_rigidity_countable_real_durations/probes/` stay where
they are. They are scratch evidence for the report and are not deleted on promotion; the report's
census table cites them for the cells that remain probe-only.

## Rollback/Contingency

The unit of rollback is a phase. Every phase ends green and is committed at that point, so
reverting a phase is `git revert` of its commit, not a working-tree discard. Phases 1 and 2 add
new files plus additive aggregator lines; reverting either leaves the tree exactly as it was.

If a phase needs a genuine working-tree rollback mid-flight — uncommitted edits that must be
discarded — take a snapshot first, following `context/contracts/recovery.md`'s rollback rung for
the exact invocation shape, including its out-of-scope override flag for the deliberate
whole-tree case. Do not run a bare precautionary `git-snapshot.sh` at the start of a phase; for
an ordinary defensive checkpoint before risky work, use the `--no-revert` form, which is durable
without reverting the working tree.

If Phase 1's generalization (Decision 3) or Phase 3's padded-clock transcription proves
disproportionate, neither blocks the headline: Phase 1 has a documented retreat to the probe's
`ℝ`-only statements, and Phase 3's sharpness witnesses can be closed as a
`[COMPLETED WITH EXCLUSIONS]` phase with a `#### Reasoned Exclusions` table, since
`static_of_countable` does not depend on them. What must not be descoped is Phase 2, Phase 5's
theorem-index row, and Phase 6's C14 pinning — without all three, the headline theorem would be
in the tree but neither indexed nor machine-pinned, which is exactly the drift C14 exists to
prevent.
