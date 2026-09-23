# Implementation Plan: Task #659

- **Task**: 659 - Settle saturation witnesses and R0 without Limit
- **Status**: [COMPLETED]
- **Effort**: 12.75 hours
- **Dependencies**: Task 658 (same module; already complete — `b13b357c0 task 658: complete implementation`)
- **Research Inputs**: `specs/659_settle_saturation_witnesses_and_r0_without_limit/reports/01_saturation-witnesses-r0-limit.md`
- **Artifacts**: plans/01_promote-saturation-r0-witnesses.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research round settled every question this task posed and left six sorry-free probes
(~1,190 lines) under `specs/659_.../probes/`. This is therefore a **promotion plan**, not a
discovery plan: the mathematics is done and axiom-checked, and the work is transcribing it into
the library, re-siting it correctly, and propagating the resulting certification changes through
the module docstrings, the appendix-support flags, the theorem index, and the C14 axiom pins.
The one place where new proof work may be attempted is a timeboxed *Saturation* proof for the
newly named metric frame (Phase 8), which has an explicit documented fallback.

### Research Integration

Findings that drive the phase structure:

- **Q1 SETTLED positively for both frames.** `TwoOrigins` and `Hedgehog` both get
  `TaskFrame.Saturation` and become `FrameOver.IsRegular` instances. This is the only item the
  manuscript appendix is blocked on, so it is front-loaded (Phases 1-4).
- **The reusable lemma is only the compactness half.** The research explicitly recommends siting
  `exists_mem_image_of_directedFamily` beside `DirectedFamily` in
  `FormalSystem/Semantics/TaskFrame.lean` rather than in `ForMathlib/` — it is a two-line wrapper
  around `IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed`, and a `ForMathlib/`
  module would cost a C24 exception entry, a `FormalSystem/ForMathlib.lean` entry and two
  generated README rows for no upstreamable content. Phase 1 follows that recommendation.
- **Q2 SETTLED negatively, by replacement not by patch.** The recorded modified-hedgehog sketch is
  superseded by the compiled **ghost-ray** frame. R0 is exactly as fragile as T1, so
  `app:topology-r0`'s derivation from `app:topology-t1` is already optimal and is left untouched.
- **Q3.2 SETTLED positively**, and it required first *naming* a metric frame (`MetricFrame.rel c`),
  which the library did not have as a declared object.
- **Q3.1 partially settled** — a new certified negative constraint (any answer must be strictly
  stronger than regularity), plus the positive criterion
  `finalTopology_eq_of_surjective_open_history`.
- **Q3.3 narrowed** — the literal ℚ transcription is not a task frame (*Saturation* fails), which
  is itself the compiled fact licensing the appendix to say why the witness is over `ℝ`.

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

No `roadmap_path` supplied in the dispatch context; no roadmap consultation performed.

## Goals & Non-Goals

**Goals**:

- Land `TaskFrame.Saturation` and the `FrameOver.IsRegular` instances for `TwoOrigins` and
  `Hedgehog`, so the appendix can say **task frame** instead of "structure satisfying three of the
  four constraints".
- Land the ghost-ray frame as the compiled R0-fails-without-*Limit* witness, replacing the
  recorded `UNVERIFIED` sketch.
- Land the named metric frame with `finalTopology_eq_nbhdTopology`, and the general criterion
  `finalTopology_eq_of_surjective_open_history` it specialises.
- Land the rational two-origin frame's `¬ Saturation`, the ℚ/ℝ contrast.
- Propagate certification: `docs/reference/state-topology-appendix-support.md` flags 1, 3, 4;
  `docs/theorem-index.md` rows; `FormalSystem/Semantics/README.md`; C14 axiom pins.
- Keep every promoted declaration sorry-free on standard axioms
  (`[propext, Classical.choice, Quot.sound]`), and keep the topology modules out of widely-imported
  aggregators.

**Non-Goals**:

- **Proving `R w 0 w` from *Seriality* + *Compositionality*.** The research records this as
  `UNVERIFIED` design guidance used to *find* the ghost-ray witness, not as a step in any probe.
  It is not promoted and not claimed anywhere in this task's output. If wanted it is a separate
  three-line probe beside `nullity_of_serial_limit`.
- **Answering Q3.1's positive half.** The "every escape net admits a coherent thread" candidate
  condition is recorded as `UNVERIFIED` in the report and stays there; a sibling task's Q4 consumes
  the certified *negative* constraint only.
- **Constructing a ℚ-carrier T1-non-Hausdorff frame (Q3.3's positive half).** The report narrows it
  to "a spherically complete non-order carrier with a dense duration type"; that is a different
  construction and belongs to a follow-up task.
- **Touching `app:topology-r0`'s derivation in the manuscript.** Q2's outcome confirms the present
  presentation is optimal. Manuscript `.tex`/`.typ` files are not edited by this task at all.
- **Raising `linter.style.longFile` to park the new frames.** The ceiling is raised only for the
  two *Saturation* proofs, which genuinely belong in `Counterexamples.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Docstring sweep half-done: 5 paragraphs assert *Saturation* is not claimed, 4 assert "not an `IsRegular` instance" | H | H | Phase 4 is grep-gated: `grep -n "deliberately not claim\|not.*\`IsRegular\` instance"` on `Counterexamples.lean` must return **only** the `funnelFrame` occurrences (lines ~37 and ~237) |
| The `funnelFrame` non-regularity paragraph gets swept along with the others | H | M | Phase 4 names it explicitly as must-not-touch; the funnel's entire content is that it is *not* regular |
| `Counterexamples.lean` at 1,510 lines with a 1,700 ceiling; the two *Saturation* proofs are ~520 probe lines | M | H | Raise `linter.style.longFile` in Phase 4 **after** measuring the actual landed size; site the three *new* frames in new leaf modules instead (Phases 6-8) |
| New `IsRegular` instances change instance resolution (`T1Space` via `instT1SpaceOfRegular`, plus `r0Space_coneTop`, `iInter_cone_eq_singleton`, `coneTop_le_stateTopology`) | M | M | `Counterexamples.lean` is a leaf, reached only from the generated root and `Tests/BimodalTest/Semantics/StateTopologyTest.lean:7` — but run the **full** `lake build --wfail`, never a scoped build (Phases 2, 3, 11) |
| A new leaf module reachable from `Semantics.lean` reintroduces the `Preorder ℤ` instance diamond | H | L | `docs/ARCHITECTURE.md`'s "The state topology is a leaf, on purpose" is binding: wire new modules **only** into the generated root via `lake exe mk_all --lib FormalSystem`, and into nothing else (Phase 9) |
| Probe-only tactic imports missing in a new module | M | H | `RationalTwoOrigins` and `MetricFinalTopology` needed explicit `Mathlib.Tactic.{Linarith,FieldSimp,Positivity,Ring}` and `Mathlib.Topology.Algebra.Order.Field`. A new module must carry its own imports; Phases 6-8 each elaborate standalone before wiring |
| "Simplifying" the ℚ proof to `irrational_sqrt_two` | M | M | `Mathlib.NumberTheory.Real.Irrational` is **not built in this checkout**. `sq_ne_two` must stay derived from `Rat.num_pow`; Phase 7 forbids the substitution explicitly |
| C14 baseline and its `#print axioms` heredoc edited out of step | H | M | They are compared by exact string equality. Phase 10 edits `C14_BASELINE` and the `C14LEAN` source heredoc **together**, appending in the same order in both |
| `MetricFrame` promoted as "the paper's running intuition" while being only a structure, reintroducing exactly the weakness Q1 just removed | M | M | Phase 8 timeboxes a *Saturation* attempt (the identity-shadow `Icc` route); on expiry the module docstring states plainly that *Saturation* is not claimed, mirroring the pre-Q1 `TwoOrigins` wording |
| `Subtype.val` unification trap (`?a.1 ≟ e`) re-triggers a whnf timeout during transcription | M | M | Report's tactic survey: never let unification solve `?a.1 ≟ e` for an anonymous-constructor `e`; restate helpers over the base type or pass `(a := _) (b := _)` explicitly |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 5, 6 | -- |
| 2 | 2, 7, 8 | 1, 5, 6 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 9 | 4, 7, 8 |
| 6 | 10 | 9 |
| 7 | 11 | 10 |

Phases within the same wave can execute in parallel. Note that Phases 2 and 3 are deliberately
serialised despite being logically independent: both edit `Counterexamples.lean`.

---

### Phase 1: Extract the shadow/compactness lemma into TaskFrame.lean [COMPLETED]

**Goal**: Land the one genuinely reusable piece of the Q1 argument beside `DirectedFamily`, so
Phases 2 and 3 can consume it rather than each restating the Cantor-intersection step.

**Tasks**:
- [x] Read `probes/ShadowLemma.lean` (51 lines) and locate `DirectedFamily` in
      `FormalSystem/Semantics/TaskFrame.lean`
- [x] Transcribe `TaskFrame.exists_mem_image_of_directedFamily` immediately after the
      `DirectedFamily` block, with a docstring naming the Mathlib declaration it wraps
      (`IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed`) and stating that its
      only content is the `DirectedFamily` → `Directed (· ⊇ ·)` translation
- [x] Transcribe the `Icc`-shaped specialisation `exists_mem_image_of_directedFamily_Icc` over
      `[LinearOrder X] [OrderClosedTopology X] [CompactIccSpace X]`
- [x] Confirm `TaskFrame.lean`'s existing imports supply what the two declarations need; add
      nothing beyond what fails to elaborate *(deviation: altered — one import was needed,
      `Mathlib.Topology.Order.Compact`; and `linter.style.longFile` had to be raised 2600 -> 2700,
      since the addition pushed the file to 2,626 lines and `--wfail` treats the warning as fatal)*
- [x] Do **not** create a `FormalSystem/ForMathlib/Topology/` module — see the research Decision
      *(honoured; the pre-existing `ForMathlib/Topology/Sierpinski.lean` from a sibling task is
      untouched)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - add two declarations beside `DirectedFamily`

**Verification**:
- `lake build --wfail` green (TaskFrame.lean is widely imported; a scoped build is not sufficient)
- `#print axioms TaskFrame.exists_mem_image_of_directedFamily` reports
  `[propext, Classical.choice, Quot.sound]`
- `grep -c sorry` on the changed region returns 0
- `FormalSystem/ForMathlib/Topology/` is unchanged (`git status` shows no new file there)

---

### Phase 2: Promote TwoOrigins Saturation and the IsRegular instance [COMPLETED]

**Goal**: `TwoOrigins` becomes a task frame; `TwoOrigins.taskFrame_t1_not_t2` becomes citable.

**Tasks**:
- [x] Transcribe from `probes/TwoOriginsSaturation.lean`, in the proof's actual order:
      `band`, `band_inter`, `Good`, `fib_band`, `seg_band` (keeping the `hU₂` hypothesis
      `O₂.Nonempty → O₂ = univ ∨ b₂ ≤ x`), `shadow`, `shadow_band`
- [x] Transcribe `rel_saturation`, then `frame_saturation`, then the anonymous
      `instance : frame.IsRegular` *(deviation: altered — `rel_saturation` calls Phase 1's
      `exists_mem_image_of_directedFamily_Icc` instead of re-inlining the probe's Cantor-
      intersection block, which is what Phase 1 was extracted for)*
- [x] Transcribe `taskFrame_t1_not_t2` (`T1Space ∧ ¬ T2Space` at a regular frame)
- [x] Re-use the existing `TwoOrigins` declaration names verbatim (`rel`, `frame`, `frame_serial`,
      `frame_compositional`, `frame_limit`, `frame_t1Space`, `frame_not_t2Space`) — the predecessor
      task's renames are already reflected in the probe
- [x] Write a docstring on `seg_band` recording *why* the `{o true} ∩ {o false} = ∅` case cannot
      arise (`Seg R w v x y = Fib R w x ∩ Fib R v (-y)` with `y ≥ 0` forces the second fibre's
      duration nonpositive) — this is the one genuine gap in the paper argument and must not be
      left implicit
- [x] Leave the module docstring and per-frame docstrings **untouched** in this phase; Phase 4 owns
      them

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: the probe is 259 lines and is expected to land at roughly that size in
`Counterexamples.lean`. Confirm at implementation time with `wc -l` before and after; if the landed
delta exceeds ~300 lines, report it in Phase 4's ceiling decision rather than silently raising
`longFile` further.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` - add the `TwoOrigins` *Saturation*
  development and the `IsRegular` instance

**Verification**:
- `lake build --wfail` green (full build — the new instance changes resolution)
- `#print axioms` on `TwoOrigins.rel_saturation`, `TwoOrigins.frame_saturation`,
  `TwoOrigins.taskFrame_t1_not_t2` each reports `[propext, Classical.choice, Quot.sound]`
- No `sorry` anywhere in the module
- `Tests/BimodalTest/Semantics/StateTopologyTest.lean` still builds

---

### Phase 3: Promote Hedgehog Saturation and the IsRegular instance [COMPLETED]

**Goal**: `Hedgehog` becomes a task frame, which is what turns
`Hedgehog.finalTopology_ne_nbhdTopology` into the Q3.1 obstruction.

**Tasks**:
- [x] Transcribe from `probes/HedgehogSaturation.lean`: `band k N a b` (centre flag + ray-index
      set), `fib_band`, `class_band` (keeping the second conjunct — "each member's ray scope is
      `univ` or a singleton"), the shadow computation, `common_ray`
- [x] Transcribe `rel_saturation`, `frame_saturation`, the anonymous
      `instance : frame.IsRegular`, and `taskFrame_t1Space` (via `FrameOver.instT1SpaceOfRegular`)
      *(deviation: altered — same substitution of the Phase 1 lemma for the probe's inlined block)*
- [x] Record in a docstring that the lifting step is the **mirror image** of the two-origin one:
      here `r = 0` is free (the centre is the unique preimage of `0`) and `r > 0` needs directedness
      to fix a single ray, which is exactly what `common_ray` packages
- [x] Reuse the existing names `Hedgehog.rel`, `frame`, `frame_serial`, `frame_compositional`,
      `frame_limit`, `finalTopology_ne_nbhdTopology`, `history_single_ray`, `history_centre_past`,
      `history_reach`

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: the probe is 264 lines; same confirmation procedure as Phase 2.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` - add the `Hedgehog` *Saturation*
  development and the `IsRegular` instance

**Verification**:
- `lake build --wfail` green
- `#print axioms` on `Hedgehog.rel_saturation`, `Hedgehog.frame_saturation`,
  `Hedgehog.taskFrame_t1Space` each reports `[propext, Classical.choice, Quot.sound]`
- `Hedgehog.finalTopology_ne_nbhdTopology` still elaborates unchanged, now on a regular frame
- No `sorry` in the module

---

### Phase 4: Counterexamples docstring sweep and the longFile ceiling [COMPLETED]

**Goal**: Delete every sentence that says *Saturation* is not claimed or that these frames are not
`IsRegular` instances — deleted, not softened — while leaving the `funnelFrame` paragraph exactly
as it stands.

**Tasks**:
- [x] Rewrite the module docstring's "Two more frames, with a different constraint profile"
      section (around line 44-47): all four constraints are now proved for both frames, and both
      are `IsRegular` instances
- [x] Rewrite the `TwoOrigins` docstring's "**`Saturation` is deliberately NOT claimed for this
      frame**" paragraph (around line 639-644) and **delete** its "therefore **not** an `IsRegular`
      instance" sentence
- [x] Same treatment at the `TwoOrigins.frame` docstring (around line 807)
- [x] Same treatment at the `Hedgehog` docstring (around lines 1079-1080)
- [x] Same treatment at the `Hedgehog.frame` docstring (around line 1238)
- [x] **Do not touch** the `funnelFrame` paragraphs at lines ~37 and ~237 ("deliberately **not** an
      `IsRegular` instance, and must never be given one") — the funnel's entire content is its
      non-regularity
- [x] Measure the module with `wc -l` and raise `set_option linter.style.longFile 1700`
      (line 95) to the smallest round value that clears the landed size; record in a comment beside
      it that the raise is for the two *Saturation* proofs specifically, per the existing standing
      instruction not to raise it to park unrelated material

**Timing**: 1.0 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: five "*Saturation* not claimed" paragraphs and four "not an `IsRegular`
instance" sentences are expected, at the anchors listed above (lines 15, 37, 44, 47, 237, 639,
643-644, 807, 1079-1080, 1238 in the pre-Phase-2 file). Line numbers WILL have shifted after
Phases 2-3 — re-locate by grep, never by the numbers above, and reconcile the actual count against
this hypothesis before closing the phase.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` - docstrings and the `longFile` option

**Verification**:
- `grep -n "deliberately not claim\|deliberately NOT claimed\|not.*\`IsRegular\` instance"` on the
  module returns **only** the two `funnelFrame` occurrences
- `lake build --wfail` green with no `longFile` linter warning
- `git diff` on this phase touches docstrings and one `set_option` line only, no proof terms

---

### Phase 5: Promote the surjective-open-history criterion into StateTopology.lean [COMPLETED]

**Goal**: Land the general Q3.1 positive criterion beside the inequality it upgrades.

**Tasks**:
- [x] Transcribe `finalTopology_eq_of_surjective_open_history` from
      `probes/MetricFinalTopology.lean` into `FormalSystem/Semantics/StateTopology.lean`,
      immediately after `finalTopology_le_nbhdTopology`
- [x] Docstring it with the proof shape: `le_iSup` makes every final-open set coinduced-`τ`-open,
      so `τ ⁻¹' O` is open, so `O = τ '' (τ ⁻¹' O)` is `𝒩_F`-open — and with the reading that
      **one** good history suffices, no relation-level condition is needed
- [x] Confirm `StateTopology.lean`'s existing imports suffice *(they did; no import added)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/StateTopology.lean` - add the criterion after
  `finalTopology_le_nbhdTopology`

**Verification**:
- `lake build --wfail` green
- `#print axioms` on the new declaration reports `[propext, Classical.choice, Quot.sound]`
- `Counterexamples.lean` and the test module still build

---

### Phase 6: Create ConstraintWitnesses.lean with the ghost-ray R0 witness [COMPLETED]

**Goal**: A new leaf module holding the fourth constraint profile — *Seriality* +
*Compositionality*, no *Limit*, R0 fails.

**Tasks**:
- [x] Create `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` with the repository's
      standard copyright header and a module docstring stating its role: witnesses whose content is
      a `def:frame` constraint or a separation property **failing**, sited outside
      `Counterexamples.lean` to keep that module under its length ceiling
- [x] Declare its own imports explicitly — at minimum `FormalSystem.Semantics.StateTopology` plus
      whatever `Mathlib.Tactic.{Linarith,Ring}` the probe needed; verify by elaborating standalone,
      not by assuming the `StateTopology` cone supplies them
- [x] Transcribe the ghost-ray frame from `probes/GhostRayR0.lean`: carrier `{γ} ∪ {r t : t ∈ ℝ}`
      over `D = ℝ`, the four relation clauses, then `rel_refl`, `rel_serial`, `rel_reflection`,
      `rel_compositional` (both halves), `not_limit`, `not_limit_witness`, `γ_mem_cone_r`,
      `isClosed_singleton_r0`, `not_r0Space_nbhdTopology`, and the frame-level `frame`,
      `frame_serial`, `frame_compositional`, `frame_not_limit`, `frame_not_r0Space`
- [x] Docstring the *why*, since it is the fact the appendix consumes: `r s ∈ cl{γ}` for `s > 0`;
      then `r 0 ∈ cl{γ}` not by any task but because every cone at `r 0` contains `r (x/2)` and
      `cl{γ}` is closed; while `{r 0}` is `𝒩_F`-closed, so `γ ∉ cl{r 0}`
- [x] Record in the docstring that the previously recorded modified-hedgehog-with-tips sketch is
      **replaced**, not patched, and why it could not have worked as stated (the asymmetry is
      between the ghost and the ray's endpoint `r 0`, not between the ghost and a tip)
- [x] Do **not** wire the module into the root yet — Phase 9 owns wiring
- [x] Do **not** promote the `UNVERIFIED` "`R w 0 w` from *Seriality* + *Compositionality*"
      observation (declared Non-Goal) *(honoured; no such claim appears anywhere in the output)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: the probe is 222 lines. Confirm the landed module size with `wc -l`; a module
materially larger than ~260 lines means transcription drift worth reviewing before Phase 9.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` - new file

**Verification**:
- `lake env lean FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` elaborates with
  zero errors
- Zero `sorry` in the file
- `#print axioms GhostRay.not_r0Space_nbhdTopology` and `GhostRay.frame_not_r0Space` each report
  `[propext, Classical.choice, Quot.sound]`

---

### Phase 7: Add the rational two-origin Saturation-failure witness [COMPLETED]

**Goal**: The compiled ℚ/ℝ contrast — the only statement in the collection exhibiting a frame
constraint failing for a *completeness* reason.

**Tasks**:
- [x] Append the `RationalTwoOrigins` namespace to
      `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`, transcribed from
      `probes/RationalTwoOrigins.lean`
- [x] Transcribe `rel` (the two-origin relation verbatim with `ℝ → ℚ` in both the duration type
      and the ray index), `rel_serial`, `rel_compositional`, `rel_limit`, `sq_ne_two`,
      `straddleFamily`, `mem_straddle`, and `not_rel_saturation`
- [x] Keep `sq_ne_two` derived from `Rat.num_pow`. **Do not** substitute `irrational_sqrt_two`:
      `Mathlib.NumberTheory.Real.Irrational` is not in this checkout's build and the substitution
      would add a build dependency the tree does not carry
- [x] Add the explicit `Mathlib.Tactic.{FieldSimp,Positivity,Ring}` imports the Newton-step
      arithmetic needs, if the standalone elaboration says they are missing *(deviation: altered —
      the probe's `set_option maxHeartbeats 2000000` was NOT carried over; the module elaborates at
      the default budget, so the bump was probe-local)*
- [x] Docstring: `TaskFrame.Saturation` is a bare-relation predicate needing only
      `[AddCommGroup] [LinearOrder] [IsOrderedAddMonoid] [Nontrivial]` on the duration type, all of
      which `ℚ` has — so **no** `TemporalOrder.of ℚ` is required. State that a frame-level form
      would need one and that this was not investigated
- [x] Record the Newton step in a comment: `t = (2s+2)/(s+2)` satisfies `t² - 2 = 2(s²-2)/(s+2)²`
      and `t - s = (2 - s²)/(s+2)`, so it crosses the cut strictly in whichever direction `s` sits
- [x] Apply the `Subtype.val` guard from the research tactic survey: restate helpers over bare `ℚ`
      or pass `(a := _) (b := _)` explicitly, never letting unification solve `?a.1 ≟ e`

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: interface

**Scope Hypothesis**: the probe is 277 lines, bringing `ConstraintWitnesses.lean` to roughly 500.
If it lands materially above ~600, split `RationalTwoOrigins` into its own leaf module before
Phase 9 rather than carrying an oversized file.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` - append the
  `RationalTwoOrigins` namespace

**Verification**:
- `lake env lean` on the module elaborates with zero errors and no whnf timeout
- `#print axioms RationalTwoOrigins.not_rel_saturation` reports
  `[propext, Classical.choice, Quot.sound]`
- `grep -c "Irrational"` on the module returns 0

---

### Phase 8: Create MetricFrame.lean, with a timeboxed Saturation attempt [COMPLETED]

**Goal**: Name the metric frame the manuscript's intuition rests on, and land
`finalTopology_eq_nbhdTopology` on it.

**Tasks**:
- [x] Create `FormalSystem/Semantics/StateTopology/MetricFrame.lean` with the standard header and
      a module docstring opening on the finding that "the metric frame" was **not** a declared
      object — it existed only as prose in `StateTopology.lean`'s `Triangle` docstring, and what the
      library had was the real-carrier *bridge* (`nbhdTopology_eq_real`,
      `coneTopology_eq_nbhdTopology_real`), a hypothesis shape rather than a frame
- [x] Declare its own imports, including `Mathlib.Topology.Algebra.Order.Field` and the tactic
      imports the probe needed; verify standalone
- [x] Transcribe from `probes/MetricFinalTopology.lean`: *(deviation: altered — eleven tactic-mode
      `show`s in the probe became `change`. Mathlib's standard syntax-linter set is enabled
      package-wide via `lakefile.toml`'s `weak.linter.mathlibStandardSet`, which rejects `show`
      used to change a goal definitionally; `--wfail` makes that fatal. `lake env lean` does not
      apply package `leanOptions`, which is why the probe and the first standalone elaboration
      both looked clean. Term-level `show ... by ring` inside `rw [...]` is unaffected and was
      left alone.)*
      `rel c : ℝ → ℝ → ℝ → Prop := fun r y u => |u - r| ≤ c * |y|`, then `rel_reflection`,
      `rel_serial`, `rel_limit`, `rel_compositional` (both halves — the interpolation direction
      splits at `w + (c·x/|v-w|)·(v-w)`), `cone_eq_ball`, `nbhdTopology_eq` (via the existing
      `nbhdTopology_eq_real`), `isHistory_line`, and `finalTopology_eq_nbhdTopology`
- [x] Prove `finalTopology_eq_nbhdTopology` through Phase 5's
      `finalTopology_eq_of_surjective_open_history`, citing it by name — the straight line
      `t ↦ c · t` is a history, surjective, and open as multiplication by a nonzero constant
- [x] **Timeboxed (30 min of the phase budget)**: attempt `TaskFrame.Saturation (rel c)` by the
      same `Icc` route with the **identity** as shadow map (fibres are closed balls). On success,
      add the `FrameOver.IsRegular` instance and say so in the docstring
- [ ] **On timebox expiry**: land the module without *Saturation*, and state plainly in the
      docstring that *Saturation* is not claimed and the object is therefore a structure, not a
      task frame — mirroring the pre-Q1 `TwoOrigins` wording. Record the attempt's stopping point so
      a follow-up task can resume it. Do not leave a `sorry` *(deviation: not taken — the
      *Saturation* attempt SUCCEEDED well inside the box. `MetricFrame.rel_saturation` is proved
      unconditionally (no speed hypothesis), `MetricFrame.isRegular` assembles all four
      constraints at any positive speed, and `instMetricFrameOneIsRegular` pins the unit-speed
      case. The fallback docstring wording was therefore never written.)*
- [x] Docstring the consequence the manuscript consumes: the hedgehog's separation of `𝒩_F` from
      the final topology is a feature of **branching**, not of the cone construction; on the frame
      the paper's intuition is built from, the two agree

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: interface

**Scope Hypothesis**: the probe is 166 lines; the *Saturation* attempt, if it lands, adds an
unknown amount. If the attempt exceeds its 30-minute box the phase closes on the fallback branch —
that is a **complete** outcome, not a partial one.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/MetricFrame.lean` - new file

**Verification**:
- `lake env lean FormalSystem/Semantics/StateTopology/MetricFrame.lean` elaborates with zero errors
- Zero `sorry`
- `#print axioms MetricFrame.finalTopology_eq_nbhdTopology` reports
  `[propext, Classical.choice, Quot.sound]`
- Exactly one of: an `IsRegular` instance is present, **or** the docstring states *Saturation* is
  not claimed. Never neither, never a hedge

---

### Phase 9: Wire the new modules into the generated root [COMPLETED]

**Goal**: The two new leaf modules reach the build through the generated root and through nothing
else.

**Tasks**:
- [x] Run `lake exe mk_all --lib FormalSystem` to regenerate `FormalSystem.lean`
- [x] Confirm the new imports land beside `FormalSystem.Semantics.StateTopology.Counterexamples`
      (currently `FormalSystem.lean:497-498`) and that the file is otherwise byte-unchanged (C33
      compares it exactly)
- [x] Verify by grep that **neither** new module is imported from `FormalSystem/Semantics.lean` or
      any other aggregator — `docs/ARCHITECTURE.md`'s "The state topology is a leaf, on purpose"
      records a `Preorder ℤ` instance diamond produced twice by exactly that mistake
- [x] Update the `StateTopology/` row in `FormalSystem/Semantics/README.md` (currently
      "`Counterexamples` (1 file)") to name all three modules and their roles, and update the
      `StateTopology.lean` row to mention the new `finalTopology_eq_of_surjective_open_history`
- [x] Run `bash scripts/readme-lint.sh` and `bash scripts/readme-inventory.sh` if the README
      tables are lint-gated *(deviation: altered — `readme-inventory.sh` is a deprecated shim;
      inventories are emitted by `check-module-invariants.sh --emit-inventory`. Also: growing
      `StateTopology/` from 1 to 3 `.lean` files surfaced `readme-lint.sh`'s missing-README check
      on that directory, so `StateTopology/README.md` was created — a file the plan did not list.
      `docs/ARCHITECTURE.md`'s "state topology is a leaf" paragraph was likewise updated to name
      all three siblings, since it explicitly enumerated them)*

**Timing**: 0.75 hours

**Depends on**: 4, 7, 8

**Verification Tier**: full

**Scope Hypothesis**: two new root import lines and two edited README rows. Confirm with
`git diff --stat`; a larger root diff means `mk_all` picked up something unintended and must be
investigated before proceeding.

**Files to modify**:
- `FormalSystem.lean` - regenerated, two new imports
- `FormalSystem/Semantics/README.md` - `StateTopology/` and `StateTopology.lean` rows

**Verification**:
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `lake build --wfail` green
- `grep -rn "ConstraintWitnesses\|StateTopology.MetricFrame" FormalSystem/` shows the modules
  reached only from `FormalSystem.lean`

---

### Phase 10: Certification sweep — appendix flags, theorem index, C14 pins [COMPLETED WITH EXCLUSIONS]

**Goal**: Every document that records what the library certifies now records the new truth.

**Tasks**:
- [x] `docs/reference/state-topology-appendix-support.md` **flag 3**: flip `pending-sibling` →
      `certified`. Replace "what is certified is 'there is a structure satisfying *Seriality*,
      *Compositionality* and *Limit* that is T1 and not Hausdorff'" with the **task frame** form,
      and remove the "Closing this is the sibling open-questions task" sentence
- [x] Same file, **flag 1**: "on a structure satisfying *Seriality*, *Compositionality* and
      *Limit*" becomes "on a task frame"
- [x] Same file, **flag 4**: flip `pending-sibling` → `certified`, naming the **ghost-ray** frame as
      the witness and stating explicitly that the hedgehog-plus-tips sketch was replaced, not built.
      State the Q2 verdict: R0 is exactly as fragile as T1, so `app:topology-r0`'s derivation from
      `app:topology-t1` is optimal and must be left alone
- [x] Same file, the row at line ~88 ("R0 can fail without *Limit*"): fill in the declaration and
      axiom columns with `GhostRay.frame_not_r0Space` and `pcq`
- [x] Same file, the rows at lines ~120, ~121, ~124, ~125: drop the "(but see flag 3 for 'task
      frame')" / "(see flag 3)" qualifications now that flag 3 is closed *(reconciled: exactly 4
      qualified rows existed, matching the Scope Hypothesis's ~5 estimate; the `pending-sibling`
      legend row was also retired, since nothing carries that status any more)*
- [x] `docs/theorem-index.md` line ~193: delete the parenthetical "(and does not claim
      *Saturation*)" from the `TwoOrigins.frame_not_t2Space` row
- [ ] `docs/theorem-index.md`: change the `Frame class` column from `—` to the regular class on the
      `TwoOrigins.*` and `Hedgehog.*` rows (lines ~193-194, ~211-225) *(deviation: skipped — the
      `Frame class` column is defined at `docs/theorem-index.md:17` as the `FrameClass` the result
      is stated at, vocabulary `Base | Dense | ZTime | RTime`, with `—` meaning class-generic.
      "Regular" is not a member of that vocabulary and these results are class-generic, so writing
      it there would corrupt the column. Regularity is instead recorded in the Statement column of
      the new `frame_saturation` / `taskFrame_t1_not_t2` rows.)*
- [x] `docs/theorem-index.md`: add rows for `TwoOrigins.frame_saturation`,
      `TwoOrigins.taskFrame_t1_not_t2`, `Hedgehog.frame_saturation`, `GhostRay.frame_not_r0Space`,
      `RationalTwoOrigins.not_rel_saturation`, `MetricFrame.finalTopology_eq_nbhdTopology`,
      `finalTopology_eq_of_surjective_open_history`, and
      `TaskFrame.exists_mem_image_of_directedFamily`, anchored to the paper labels the research
      report's "What each outcome licenses the appendix to say" table names
- [x] `scripts/check-module-invariants.sh`: append the new declarations to `C14_BASELINE` **and**
      to the `C14LEAN` `#print axioms` source heredoc, **in the same order in both** — they are
      compared by exact string equality
- [x] Do **not** edit `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` or
      `typst/FormalFoundations.typ` — manuscript edits are out of this task's scope *(honoured;
      `git status` shows no manuscript file touched)*

**Timing**: 1.5 hours

**Depends on**: 9

**Verification Tier**: local

**Scope Hypothesis**: 2 appendix-support flags flipped plus 1 reworded plus ~5 qualification
removals; ~8 new theorem-index rows plus ~15 `Frame class` cell edits; 1 paired C14 edit. These
counts are estimates from a pre-implementation read — re-derive each by grep at implementation time
and reconcile before closing.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| `docs/theorem-index.md`: change the `Frame class` column from `—` to the regular class on the `TwoOrigins.*` and `Hedgehog.*` rows | The column is not a regularity column. `docs/theorem-index.md:17` defines it as "The `FrameClass` the result is stated at: `Base`, `Dense`, `ZTime`, `RTime`. `—` where the result is class-generic." "Regular" is not in that vocabulary, and these results *are* class-generic, so writing it would corrupt a column other rows depend on. Regularity is instead carried in the Statement column of the new `frame_saturation` / `taskFrame_t1_not_t2` rows. | `sed -n '17p' docs/theorem-index.md`; check C15's second assertion passes on all 167 rows with the column left at `—` |

**Files to modify**:
- `docs/reference/state-topology-appendix-support.md` - flags 1, 3, 4 and the qualified rows
- `docs/theorem-index.md` - row edits and new rows
- `scripts/check-module-invariants.sh` - `C14_BASELINE` and the `C14LEAN` heredoc

**Verification**:
- `grep -n "pending-sibling" docs/reference/state-topology-appendix-support.md` returns only the
  legend row at line ~51 (or nothing, if the legend row is also retired)
- `grep -n "does not claim \*Saturation\*" docs/theorem-index.md` returns nothing
- `bash scripts/check-module-invariants.sh` passes C14 (and C2, C5, C12, C15, C20)

---

### Phase 11: Full gate run and axiom verification [COMPLETED]

**Goal**: Close the task on the documented gate set, with an explicit per-declaration axiom record.

**Tasks**:
- [x] `lake build --wfail` — green, no warnings (2,724 jobs, 0 errors, 0 warnings)
- [x] `bash scripts/check-module-invariants.sh` — every check passes (C2, C14 axiom pins, C15
      ledger round trip, C20, C21, C24, C33)
- [x] `lake exe mk_all --lib FormalSystem --check` — exits 0 ("No update necessary"); C33 confirms
      `FormalSystem.lean` is byte-for-byte the generated root
- [x] `#print axioms` on every headline promoted declaration; record the results in the execution
      summary. Expect `[propext, Classical.choice, Quot.sound]` for all
- [x] `grep -rn "sorry" FormalSystem/Semantics/StateTopology/ FormalSystem/Semantics/TaskFrame.lean
      FormalSystem/Semantics/StateTopology.lean` returns nothing (and C3's repo-wide structural
      sorry inventory is ZERO)
- [x] Confirm the Non-Goals held: no `R w 0 w` claim anywhere; no manuscript file touched; no
      `ForMathlib/Topology/` module added; the `funnelFrame` non-regularity paragraph byte-identical
- [x] Write the execution summary recording, per question (Q1 both frames, Q1's lemma, Q1's ℚ
      contrast, Q2, Q3.1, Q3.2, Q3.3), the verdict, the landed declaration names, and what each
      outcome licenses the appendix to say — mirroring the research report's closing table but
      citing the **promoted** names rather than the probe names

**Timing**: 1.0 hours

**Depends on**: 10

**Verification Tier**: full

**Files to modify**:
- `specs/659_settle_saturation_witnesses_and_r0_without_limit/summaries/01_*-summary.md` - new

**Verification**:
- All four gate commands exit 0
- The axiom record in the summary lists every promoted headline declaration with
  `[propext, Classical.choice, Quot.sound]`
- Every Non-Goal confirmed by an explicit grep or `git diff` check

---

## Testing & Validation

- [x] `lake build --wfail` green (incremental from a warm cache, 2,724 jobs)
- [x] `bash scripts/check-module-invariants.sh` — all checks pass
- [x] `lake exe mk_all --lib FormalSystem --check` exits 0
- [x] Zero `sorry` in `FormalSystem/Semantics/TaskFrame.lean`,
      `FormalSystem/Semantics/StateTopology.lean`, and all of
      `FormalSystem/Semantics/StateTopology/`
- [x] Every promoted headline declaration reports exactly
      `[propext, Classical.choice, Quot.sound]` — machine-checked by the C14 pins, not by hand
- [x] `Tests/BimodalTest/Semantics/StateTopologyTest.lean` builds unchanged (C1's
      `lake build BimodalTest` leg)
- [x] Neither new module is reachable from `FormalSystem/Semantics.lean` or any aggregator other
      than the generated root
- [x] The `funnelFrame` "must never be given one" paragraph is byte-identical to its pre-task state

## Artifacts & Outputs

- `FormalSystem/Semantics/TaskFrame.lean` — `exists_mem_image_of_directedFamily` and its `Icc`
  specialisation
- `FormalSystem/Semantics/StateTopology.lean` — `finalTopology_eq_of_surjective_open_history`
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` — `TwoOrigins` and `Hedgehog`
  *Saturation*, both `IsRegular` instances, `taskFrame_t1_not_t2`, `taskFrame_t1Space`, swept
  docstrings, raised `longFile`
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` (new) — the ghost-ray R0 witness
  and the rational two-origin *Saturation* failure
- `FormalSystem/Semantics/StateTopology/MetricFrame.lean` (new) — the named metric frame and
  `finalTopology_eq_nbhdTopology`
- `FormalSystem.lean` — regenerated root
- `FormalSystem/Semantics/README.md`, `docs/theorem-index.md`,
  `docs/reference/state-topology-appendix-support.md` — certification updates
- `scripts/check-module-invariants.sh` — C14 baseline pins
- `specs/659_settle_saturation_witnesses_and_r0_without_limit/summaries/01_*-summary.md` — the
  numbered per-question verdict record

## Rollback/Contingency

- Every phase is its own commit (`task 659 phase {P}: {name}`), so any phase reverts with a single
  `git revert` without disturbing its predecessors.
- The probes under `specs/659_.../probes/` are the authoritative compiled source and are never
  deleted. If a transcription goes wrong, re-read the probe rather than reconstructing the proof.
- Phases 6-8 create isolated leaf modules that are unwired until Phase 9; if any of them cannot be
  landed cleanly, delete the file and skip its Phase 9 root entry. The Q1 work (Phases 1-4) is
  independent of them and is the item the appendix actually blocks on — it must land even if the
  Q2/Q3 promotions do not.
- If the `IsRegular` instances cause downstream instance-resolution breakage that cannot be
  contained in the leaf, make them scoped instances rather than reverting *Saturation*: the
  `Saturation` theorems are the load-bearing content, the instance is convenience.
- Before any destructive recovery, `bash .claude/scripts/git-snapshot.sh 659`.
