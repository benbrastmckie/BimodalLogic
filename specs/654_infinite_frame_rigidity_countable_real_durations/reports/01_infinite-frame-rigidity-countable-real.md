# Research Report: Infinite frame rigidity — countable carriers and real durations

- **Task**: 654 - infinite_frame_rigidity_countable_real_durations
- **Started**: 2026-09-22T22:33:05Z
- **Completed**: 2026-09-22T23:58:00Z
- **Effort**: ~1.5 hours (research with compiled probes)
- **Dependencies**: 646, 652 (time-indexed frames and the Dedekind boundary — the connectedness
  argument this report's partition argument is the duration-indexed cousin of)
- **Sources/Inputs**:
  - Codebase: `FormalSystem/Semantics/TaskFrame.lean`,
    `FormalSystem/Semantics/Correspondence/Rigidity.lean`,
    `FormalSystem/Semantics/Correspondence/RigiditySharpness.lean`,
    `FormalSystem/Semantics/Frames/Standard.lean`,
    `FormalSystem/Semantics/Frames/TranslationProduct.lean`,
    `FormalSystem/Semantics/ShiftSet.lean`,
    `FormalSystem/Semantics/Extension/Extension.lean`,
    `FormalSystem/Semantics/DeterministicBridge.lean`,
    `FormalSystem/Semantics/FrameProperty.lean`,
    `FormalSystem/Semantics/DurationClassification.lean`,
    `FormalSystem/ForMathlib/README.md`
  - Manuscript anchors via `docs/reference/paper-definitions-of-record.md`: `def:frame`
    (*Compositionality*, *Seriality*, *Limit*, *Saturation*), `def:frame-properties`
    (Discrete/Dense/**Complete**), `def:world-history`, `thm:extension`, `cor:occurrence`,
    `sec:Construction`, `sub:Conclusion`
  - Mathlib v4.33.0-rc1 (searched for a partition/Sierpiński theorem; absent — see Findings)
  - lean-lsp MCP (`lean_run_code`, `lean_verify`, `lean_local_search`) and `lake env lean`
- **Artifacts**:
  - `specs/654_infinite_frame_rigidity_countable_real_durations/reports/01_infinite-frame-rigidity-countable-real.md`
  - `specs/654_infinite_frame_rigidity_countable_real_durations/probes/01_clock-frames.lean`
  - `specs/654_infinite_frame_rigidity_countable_real_durations/probes/02_countable-real-rigidity.lean`
  - `specs/654_infinite_frame_rigidity_countable_real_durations/probes/README.md`
- **Standards**: report-format.md, subagent-return.md, status-markers.md

## Executive Summary

- **Q2 is CONFIRMED, and it is the headline.** Over `ℝ`, *every* task frame with countably many
  world states is static. No finiteness, no uniform dwell time, no density or Archimedean
  hypothesis. Compiled sorry-free as `Probe.static_of_countable` in probe `02`.
- The proof needed one thing Mathlib does not have: **Sierpiński's theorem** ("a continuum is not
  a countable disjoint union of two or more nonempty closed sets"), in the form *a map `ℝ → W`
  with `W` countable and all level sets closed is constant*. It is proved here directly
  (`Probe.Sierp.const_of_isClosed_levels`, ~110 lines), by Baire category on the
  non-locally-constant part. Mathlib's `Sierpinski*` declarations are all the Sierpiński *space*.
- **Q1 is CONFIRMED negative, and needed no new construction.** The rational clock is already in
  the library: `FormalSystem.Semantics.translationFrame (TemporalOrder.of ℚ)`
  (`Semantics/Frames/Standard.lean`). Countable + dense + Archimedean is therefore *not* enough
  for rigidity; the escape is exactly a state space carrying a clock reading.
- **Q3 is settled in a sharper form than "contains a clock".** Over `ℝ`, a non-constant world
  history has uncountable range, and more: there is a time at which *every* window, however
  short, already carries uncountably many world states (`Probe.exists_local_clock`). The literal
  reading "some history is injective on an interval" is **UNVERIFIED** — see Findings.
- **Q4 verdict for the paper**: the manuscript's own *Complete* clause (`def:frame-properties`)
  is exactly the new rigidity boundary. Over discrete durations finite frames already have rich
  dynamics; over dense Archimedean durations finiteness kills them but countability does not;
  over complete durations even countability kills them. So "finite task frames are interesting
  only over discrete durations" is supported, and "countable frames over the real line are
  ruled out" is now a theorem — ruled out by *Limit* and *Saturation* together, with completeness
  of the duration order supplying Baire.
- Promotion recommendation: **yes, in two pieces** —
  `FormalSystem/ForMathlib/Topology/Sierpinski.lean` for the topological theorem and
  `FormalSystem/Semantics/Correspondence/RigidityReal.lean` for the frame-level results.

## Context & Scope

`Correspondence/Rigidity.lean` had settled the *finite* case: over a dense Archimedean duration
group, a frame is static iff it has a uniform dwell time (`FrameOver.static_iff_uniformDwell`),
and *Limit* on a finite carrier supplies one (`FrameOver.static_of_finite`).
`RigiditySharpness.lean` had shown both hypotheses sharp (`intPermissiveFrame_not_static` over
`ℤ`; `lexRatFrame_not_static` over `ℚ ×ₗ ℚ`). This task asks what survives once the carrier is
infinite, at the three cardinalities finite / countable / uncountable against the four duration
orders `ℤ`, `ℚ`, `ℚ ×ₗ ℚ`, `ℝ`.

Constraints honoured: every claimed frame-axiom fact carries a sorry-free compiled probe or the
label UNVERIFIED; manuscript claims cite labels, never line numbers; nothing under `FormalSystem/`
or `Tests/` was modified.

## Findings

### The census table

Rows are carrier cardinality; columns are the duration order. Each cell is **static-forced** (no
non-static frame exists) or **non-static** (a witness exists), with the theorem or witness name.
All names below are compiled and sorry-free; library names are in `FormalSystem/`, `Probe.*`
names are in this task's probes.

| Carrier \ Duration | `ℤ` (discrete) | `ℚ` (dense, Archimedean) | `ℚ ×ₗ ℚ` (dense, non-Archimedean) | `ℝ` (dense, Archimedean, **Complete**) |
|---|---|---|---|---|
| **finite** | non-static — `Rigidity.intPermissiveFrame_not_static` | **static-forced** — `FrameOver.static_of_finite` | non-static — `Rigidity.lexRatFrame_not_static` | **static-forced** — `FrameOver.static_of_finite` (also by the new theorem) |
| **countable** | non-static — inherited from the finite row (`intPermissiveFrame`, carrier `Bool`, finite hence countable) | non-static — `Probe.ratClock_not_static` (the rational clock, `translationFrame (TemporalOrder.of ℚ)`) | non-static — inherited from the finite row (`lexRatFrame`) | **static-forced** — `Probe.static_of_countable` (**new**) |
| **uncountable** | non-static — `Probe.paddedClock_not_static` + `Probe.paddedClock_uncountable` at `ℤ` | non-static — `Probe.paddedClock_*` at `ℚ` | non-static — `Probe.paddedClock_*` at `ℚ ×ₗ ℚ` | non-static — `Probe.realClock_not_static` (the real clock) and `Probe.paddedClock_*` |

Reading of the table: the only *new* static-forced cell is countable-over-`ℝ`. Everything else
was either already known or is witnessed by a clock. `paddedClock` is one parametric construction
— a clock coordinate `↑D` plus an inert real coordinate — giving the whole uncountable row at
once; its relation is functional, so *Saturation* is
`TaskFrame.saturation_of_fib_subsingleton` and *Limit* is `TaskFrame.limit_of_shift` at the
first projection.

### Q1 — countable carrier, `ℚ` durations: already in the library

- The rational clock is **not a new construction**. `Semantics/Frames/Standard.lean` defines
  `translationFrame (D : TemporalOrder) : FrameOver D` with `WorldState = ↑D` and
  `w ⇒_x u ↔ u = w + x`, together with the `@[simp]` bridge `translationFrame_taskRel`. At
  `D = TemporalOrder.of ℚ` this is exactly the rational clock: carrier `ℚ` (countable), duration
  order `ℚ` (dense and Archimedean), and not static.
- Probe `01` discharges the dispatch's "check every field of the live `FrameOver` structure"
  obligation by *projection from the frame value*: `ratClock.comp`, `ratClock.serial`,
  `ratClock.limit` (in its literal transcribed shape
  `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ reflect PosRel w y u) → u = w`), `ratClock.saturation`,
  `ratClock.worldNonempty`, plus both halves of *Compositionality* separately
  (`ratClock.interpolates` and `ratClock.forward_comp`). Re-proving them would have been
  redundant: the frame value *is* the proof of all four axioms.
- The alternative routes the dispatch pointed at were checked and are not needed.
  `Semantics/ShiftSet.lean`'s `ShiftSet.fibre` would build the same frame from a shift set (its
  `sep` field is exactly *Limit*), and `Frames/TranslationProduct.lean`'s `prodRel_*` transfer
  theorems build the *time-unfolding* product `(w,e) ⇒ₓ (u,e') ↔ w ⇒ₓ u ∧ e' = e + x`, which is a
  different construction (a clock bolted onto an arbitrary base) and heavier than needed here.
- **Verdict (Q1): countable plus dense plus Archimedean is NOT enough for rigidity.** The escape
  is exactly a state space that carries a clock reading.

### Q2 — countable carrier, `ℝ` durations: the conjecture holds

`Probe.static_of_countable` (probe `02`):

> For `F : FrameOver (TemporalOrder.of ℝ)` with `[Countable F.WorldState]`,
> `TaskFrame.Static F.TaskRel` — that is, `w ⇒_x u ↔ w = u` at every duration.

The proof sketch in the task description survives intact, with one simplification and one
strengthening.

Step-by-step, with the axiom each step consumes:

1. **Realize the task as a history.** Given `w ⇒_x u` with `x ≠ 0`, the two-point partial history
   `{⟨0,w⟩, ⟨x,u⟩}` extends by `thm:extension` to a world history `σ` with `σ(0) = w`,
   `σ(x) = u` (`Probe.exists_history`). *Consumes*: **Saturation**, through `thm:extension` —
   which is where Zorn, and hence `Classical.choice`, enters. *Compositionality* contributes only
   what `thm:extension` itself needs; nothing beyond that. The domain `{0,x}` is not convex, so
   this is `thm:extension` and not `cor:occurrence` — exactly the construction
   `Semantics/DeterministicBridge.lean`'s `deterministic_of_singletonClasses` already uses, and
   probe `02` reuses its idiom verbatim.
   The `x = 0` case is closed by `FrameOver.nullity_identity` alone.
2. **Level sets of a history are closed.** *Limit* (`def:frame#Limit`) gives, for each pair
   `a ≠ b`, a radius `r > 0` with no task of duration `|y| < r` from `b` to `a`;
   `def:world-history`'s `respects_task` then keeps every time within `r` of a `b`-time out of
   the `a`-level set (`Probe.levels_closed`). *Consumes*: **Limit**, and nothing else.
   Note this is the per-pair radius, not a uniform one — no finiteness is used.
3. **Sierpiński collapses the history.** The level sets partition `ℝ` into countably many
   pairwise disjoint closed sets, at least two of them nonempty if the history is non-constant.
   `Probe.Sierp.const_of_isClosed_levels` forbids that, so `σ` is constant and `w = u`.
   *Consumes*: Dedekind completeness of the duration order, through Baire.
4. **The positive half of `Static`** (`w ⇒_x w` at every `x`) comes from **Seriality** plus the
   reflection law, exactly as in `FrameOver.static_of_uniformDwell`.

Two deviations from the sketch, both improvements:

- **The interval `[0,x]` is not used.** The argument runs on the whole of `ℝ`, which is connected
  and complete as it stands, so no relative topology on a subinterval is needed. This removes the
  need to argue that the level sets are *pairwise at positive distance* (the sketch's route to
  closedness); plain closedness of each level set, one pair at a time, suffices.
- **Countability of the range, not the carrier, is what is used.** The working theorem is
  `Probe.constant_of_countable_range`: any world history over `ℝ` whose *range* is countable is
  constant. `static_of_countable` is the corollary at a countable carrier.

Axioms: `lean_verify` reports `[propext, Classical.choice, Quot.sound]` for
`Probe.static_of_countable`, `Probe.Sierp.const_of_isClosed_levels`, `Probe.levels_closed` and
`Probe.exists_local_clock`. No `sorryAx` anywhere in either probe; both files compile under
`lake env lean` with exit 0 and no warnings.

### The missing Mathlib ingredient: Sierpiński's theorem

- **Mathlib does not have it.** A case-insensitive search of the whole Mathlib source for
  `sierpinski`/`sierpiński` returns four files: `Mathlib/Topology/Order.lean` (the Sierpiński
  *space* `Prop`), `Mathlib/Topology/Order/LowerUpperTopology.lean`,
  `Mathlib/Topology/ContinuousMap/T0Sierpinski.lean`, and a bibliography citation in
  `Mathlib/SetTheory/Ordinal/Commute.lean`. The partition theorem on continua is absent.
- **What was proved instead** (`Probe.Sierp.const_of_isClosed_levels`): let `h : ℝ → W` with `W`
  countable and every level set `S a = {t | h t = a}` closed; then `h` is constant. Proof
  structure:
  1. `U := ⋃ a, interior (S a)` — the locally-constant part, open.
     `Sierp.const_of_preconnected`: on any preconnected `C ⊆ U`, `h` is constant, because `C` is
     covered by the two disjoint open sets "interior of the level set at `c₀`" and "the union of
     all the other level-set interiors".
  2. If `Uᶜ = ∅` then `ℝ` itself is preconnected and inside `U`, so `h` is constant outright.
  3. Otherwise `Uᶜ` is a nonempty **closed** subset of `ℝ`, hence complete
     (`IsClosed.completeSpace_coe`), hence a Baire space, and it is covered by the countably many
     closed traces of the level sets. `nonempty_interior_of_iUnion_of_closed` gives a `t ∈ Uᶜ`, a
     value `a` and an `r > 0` with `Uᶜ ∩ (t-r, t+r) ⊆ S a`.
  4. The value `a` then propagates across the *whole* of `(t-r, t+r)`: a point `s` of the window
     not in `Uᶜ` is separated from `t` by `c := sSup (Uᶜ ∩ [t,s])` (or `sInf`, on the other
     side), which lies in `Uᶜ ∩ (t-r,t+r)` so carries `a`; the half-open interval `(c,s]` lies
     inside `U` and is preconnected, so `h` is constant on it, and closedness of that constant's
     level set carries the value back to `c`. Hence `h ≡ a` on `(t-r,t+r)`, i.e. `t ∈ U` —
     contradicting `t ∈ Uᶜ`.
  - Note the proof does **not** need `Uᶜ` to be perfect, which is the step the textbook proof of
    Sierpiński's theorem spends most of its effort on. Step 4 derives the contradiction directly.
- The narrowed import list for this section was compiled green on its own:
  `Mathlib.Topology.Baire.CompleteMetrizable`, `Mathlib.Topology.Baire.Lemmas`,
  `Mathlib.Topology.Order.Monotone`, `Mathlib.Topology.Order.IntermediateValue`,
  `Mathlib.Topology.Instances.Real.Lemmas`.

### Q3 — uncountable carrier, `ℝ` durations

- **The real clock**: `translationFrame (TemporalOrder.of ℝ)`, carrier `ℝ`, not static
  (`Probe.realClock_not_static`), carrier uncountable (`Probe` example via
  `Cardinal.not_countable_real`). So the Q2 boundary is sharp in cardinality: `ℵ₀` is static,
  `2^ℵ₀` is not.
- **What IS settled about "must contain a clock"**, both sorry-free:
  - `Probe.range_uncountable_of_nonconstant` — a non-constant world history over `ℝ` has
    uncountable range.
  - `Probe.exists_local_clock` — stronger and local: if a world history `τ` over `ℝ` is
    non-constant, there is a time `t` such that for *every* `r > 0` the image
    `τ([t-r, t+r])` is uncountable. That is, at `t` the world state is reading a clock at every
    scale. Proof: `t` is any point where `τ` is not locally constant (one exists, else `τ` is
    constant by step 2 above); compose `τ` with the continuous retraction of `ℝ` onto
    `[t-r,t+r]`, whose level sets are still closed and whose range is the window's image, and
    apply the countable-range Sierpiński collapse.
- **What is NOT settled — UNVERIFIED**: the literal claim *some history is injective on an
  interval*. Nothing proved here yields it, and there is a concrete reason to doubt it. The
  level sets of a history may be nondegenerate closed intervals and still satisfy *Limit*, since
  *Limit* only asks that each **pair** of distinct states be separated by a positive duration,
  and two disjoint nondegenerate closed intervals are at positive distance. A devil's-staircase
  shaped history — non-constant, with uncountable range, constant on a dense open set, hence
  injective on no interval — is therefore not excluded by *Limit* or by the theorems above. What
  is *not* known is whether the **composition** half of `def:frame#Compositionality` can be
  arranged for such a relation: the naive relation `R w d u :↔ ∃ s, h(s) = w ∧ h(s+d) = u`
  interpolates and is serial for any `h`, but its composition half needs the level sets to be
  "homogeneous" in a way a staircase is not. **This is the precisely located obstruction**: the
  question reduces to whether a non-injective-on-every-interval history can be a history of a
  frame satisfying the composition half of *Compositionality*. Settling it is a separate task;
  it is not needed for Q2 or Q4.

### Q4 — the interpretive verdict, for the paper

The assembled picture, each row backed by the table above:

- **Over `ℤ` (discrete)**: finite frames already have rich dynamics — `permissiveFrame` on `Bool`
  makes every state assignment a legal history. *Limit* is free over a successor order
  (`TaskFrame.limit_of_succOrder`), so it constrains nothing.
- **Over `ℚ` (dense, Archimedean)**: finite frames are static (`FrameOver.static_of_finite`), but
  countable frames need not be — and the countable non-static ones are *clocks*: the witness is
  literally translation on the duration group.
- **Over `ℚ ×ₗ ℚ` (dense, non-Archimedean)**: even finite frames escape
  (`lexRatFrame_not_static`). Density alone is not the boundary.
- **Over `ℝ` (dense, Archimedean, Complete)**: even countable frames are static. The only
  non-static frames have uncountably many states, and by `exists_local_clock` those states behave
  like clock readings — locally, at every scale, uncountably many of them per time-window.

Answering the two questions put:

- **"Does this support the claim that finite task frames are interesting only over discrete
  durations?"** Yes, but with one qualification the table makes unavoidable: *discrete or
  non-Archimedean*. `lexRatFrame` is a finite non-static frame over a dense order. The accurate
  claim is: a finite task frame over a **dense Archimedean** duration order is static, so finite
  frames are interesting only when the duration order is discrete or non-Archimedean.
- **"Are countable frames over uncountable durations ruled out as uninteresting, and by which
  axiom?"** Over `ℝ` — more generally over any duration order satisfying `def:frame-properties`'
  **Complete** clause (verbatim: "if every nonempty `S ⊆ D` bounded above has a least upper bound
  in `D`") together with density — yes: they are all static. The axioms doing the ruling out are
  **Limit** and **Saturation**, in that division of labour:
  - *Saturation* supplies the total history (through `thm:extension`), which is what turns a
    single task `w ⇒_x u` into a function on the whole line;
  - *Limit* makes that function's level sets closed;
  - completeness of the duration order is what makes a countable closed partition of the line
    impossible.
  Remove any one and the result fails: over `ℚ` (dense, Archimedean, *not* complete) the rational
  clock is the counterexample, and the failure is exactly the failure of Baire on `ℚ`.
- **Relation to the manuscript's standing caveat.** `Frames/TranslationProduct.lean` records it:
  "a state that carries a clock reading is not a world state in the manuscript's sense: world
  states are what recur, and the whole point of the product is that its states cannot." This
  report makes that caveat a theorem rather than a methodological preference over `ℝ`: if world
  states are what recur — if the carrier is small — then over a complete duration order nothing
  happens at all. The manuscript's own `sec:Construction` passage "nothing prevents a world state
  from occurring at many times in a single history" is the recurrence the countable-carrier
  theorem forces to be *total*.

### Relation to the sibling time-indexed result (task 652)

The two boundaries are genuinely different and the report should not be read as collapsing them.
`Semantics/TimeIndexed.lean`'s `TimeIndexed.constantHistories_of_lub` gets constant histories from
*finitely* many states plus *Limit* over a densely ordered, Dedekind-complete **time** order;
`Semantics/TimeIndexedSharpness.lean`'s `qSwitchFrame_not_constantHistories` shows completeness
cannot be dropped there. The result here is about **durations**, reaches **countably** many
states rather than finitely many, and concludes the relation-level `Static` rather than constancy
of histories. What the two share is the mechanism — completeness of the order plus closedness
from *Limit* — which is why the ordering note in the task description was right: this argument
reads much more cleanly with that one in hand.

## Decisions

- Q1 was answered by *finding* the rational clock in the library rather than building one.
  Re-deriving the four axioms for a frame the tree already constructs would have been noise;
  projection from `translationFrame`'s frame value is the stronger evidence.
- The Sierpiński lemma is stated over `ℝ` and over the whole line, not over an interval. Stating
  it on `[0,x]` would have forced relative topology throughout for no gain.
- The frame-level theorem is stated at `FrameOver (TemporalOrder.of ℝ)`, not at an abstract
  Dedekind-complete duration order. Reasons under Risks.
- The working statement is `constant_of_countable_range` (countable **range**), with
  `static_of_countable` as its corollary. The range form is what Q3 needs and is strictly
  stronger.
- Q3's "injective on an interval" is recorded UNVERIFIED with a located obstruction rather than
  guessed either way.

## Recommendations

Prioritized, for the planner.

1. **Promote the topological theorem to `FormalSystem/ForMathlib/Topology/Sierpinski.lean`.**
   It is Mathlib-shaped (no `FormalSystem` dependency), Mathlib does not have it, and
   `ForMathlib/README.md`'s dependency rule (`Mathlib → ForMathlib → FormalSystem.*`) is
   satisfied — the section imports only Mathlib. Suggested names, in Mathlib's own namespace
   style:
   - `IsLocallyConstant.const_of_isClosed_levels` or, closer to the statement,
     `Set.Countable.const_of_isClosed_levels` — pick at plan time; the probe's local names
     (`S`, `U`, `mem_U_iff`, `const_of_preconnected`, `const_of_isClosed_levels`,
     `const_of_countable_range`) are placeholders, and `S`/`U` in particular must be renamed
     before promotion (they are far too short for a Mathlib-shaped file).
   - Import list, already compiled green: `Mathlib.Topology.Baire.CompleteMetrizable`,
     `Mathlib.Topology.Baire.Lemmas`, `Mathlib.Topology.Order.Monotone`,
     `Mathlib.Topology.Order.IntermediateValue`, `Mathlib.Topology.Instances.Real.Lemmas`.
   - This directory needs a new `Topology/` subdirectory with its own `README.md`, and the
     `ForMathlib/README.md` generated inventory table must be re-emitted.
2. **Promote the frame-level results to a new
   `FormalSystem/Semantics/Correspondence/RigidityReal.lean`**, importing
   `Correspondence/Rigidity.lean` and the new `ForMathlib` module. Suggested contents and names:
   - `FrameOver.levels_closed` — level sets of a world history are closed (from *Limit*).
   - `FrameOver.exists_history_of_taskRel` — `thm:extension` at the two-point partial history.
   - `FrameOver.constant_of_countable_range` — the working theorem.
   - `FrameOver.static_of_countable` — **the headline**, the sibling of `static_of_finite`.
   - `FrameOver.range_uncountable_of_nonconstant`, `FrameOver.exists_local_clock` — Q3.
   Do **not** fold these into `Rigidity.lean`: that module's docstring advertises an import list
   of exactly `TaskFrame` plus `Mathlib.Algebra.Order.Archimedean.Defs` and states it "takes no
   topology". A topology-consuming theorem belongs beside it, not in it. The only edit to
   `Rigidity.lean` should be a cross-reference paragraph in its module docstring (its "Scope
   note" section is the natural host), matching the `file_scope` this task already declares.
3. **Promote the clock witnesses only if the planner wants the table citable.** The rational and
   real clocks need no new module (`translationFrame` covers both); `paddedClock` is new, and if
   it is wanted it belongs in `Correspondence/RigiditySharpness.lean` beside `lexRatFrame`,
   whose role — "the hypothesis cannot be dropped" witness — it shares. It is optional: the Q2
   theorem stands without it.
4. **Wiring obligations for any promotion** (the task description already lists them; they are
   restated here with the specific targets): aggregator entries in
   `FormalSystem/Semantics/Correspondence.lean` and `FormalSystem/ForMathlib.lean`, README rows
   in `FormalSystem/Semantics/Correspondence/README.md` and `FormalSystem/ForMathlib/README.md`
   (both use generated inventory tables — re-emit, do not hand-edit), a `docs/theorem-index.md`
   row for `static_of_countable`, the C14 check in `scripts/check-module-invariants.sh`, plus
   `lake build --wfail` green, `lean_verify` standard axioms only, and
   `lake exe mk_all --lib FormalSystem --check` exit 0.
5. **Phase sizing.** Promotion is naturally three phases: (a) the `ForMathlib` topological module
   plus its README/aggregator wiring; (b) `RigidityReal.lean` plus its wiring and the
   `Rigidity.lean` cross-reference; (c) optional `paddedClock` into `RigiditySharpness.lean`.
   Each is one agent run. The proofs are already written and green — phase (a) and (b) are
   transcription plus renaming plus wiring, not discovery.

## Risks & Mitigations

- **Risk: the theorem is stated at `ℝ`, not at the manuscript's *Complete* frame class.**
  `Semantics/FrameProperty.lean` has `TaskFrame.IsComplete` (the bare Complete clause) and
  `TaskFrame.IsRTime` (Dense + Complete), and `FrameClass.RTime` is the class the paper's
  `cor:tm-completeness` targets. Stating `static_of_countable` at `IsRTime` would be the
  paper-facing form.
  *Mitigation / cost*: two routes, both real work, neither needed for the result to stand.
  (i) **Transport.** `Semantics/DurationClassification.lean` explicitly and deliberately does
  *not* prove "a nontrivial dense Dedekind-complete ordered abelian group is `≃+o ℝ`", recording
  it as a scoped ~100–200-line omission with the four-step composition path spelled out. That
  isomorphism is exactly what a transport proof would need. (ii) **Intrinsic rerun.** Redo the
  Sierpiński argument in the order topology of an abstract conditionally-complete densely-ordered
  group: closed bounded intervals are compact there (`CompactIccSpace` for
  `ConditionallyCompleteLinearOrder` + `OrderTopology`), so the space is locally compact
  Hausdorff and Mathlib's `Mathlib/Topology/Baire/LocallyCompactRegular.lean` supplies
  `BaireSpace` without any metric. This route avoids Hölder entirely but has to replace the
  probe's three metric steps (`Metric.mem_nhds_iff`, `Real.dist_eq`, `Subtype.dist_eq`) with
  order-topology neighbourhood bases, and has an instance-plumbing cost: this tree deliberately
  keeps completeness `Prop`-valued (`IsComplete`) rather than as a
  `ConditionallyCompleteLinearOrder` instance, precisely to avoid instance-unification risk on
  `F.Duration`. *Recommendation*: promote at `ℝ` now; record the `IsRTime` generalization as a
  follow-on task, with route (ii) as the preferred path since it does not depend on the omitted
  isomorphism.
- **Risk: `import Mathlib` in probe `02`.** Probes are scratch, but a promoted module must not do
  this. *Mitigation*: the narrowed list for the topological section is already compiled green and
  is recorded in Recommendation 1; the frame-level module additionally needs
  `FormalSystem.Semantics.Extension` (for `thm:extension`) and
  `FormalSystem.Semantics.Correspondence.Rigidity` (for `Static`).
- **Risk: linter failures under `lake build --wfail`.** Both probes currently compile with zero
  warnings under `lake env lean`, including the `omit`-the-unused-section-variable linter that
  bit the sibling task, so this risk is lower than usual. It is not zero: `--wfail` in a library
  context also enforces docstring and `simp`-argument lints that a standalone file does not see.
- **Risk: naming collision on promotion.** `Static`, `UniformDwell` and `static_of_finite`
  already live in `Rigidity.lean`'s namespaces; `static_of_countable` must sit in
  `FrameOver` alongside them and must not shadow. No collision was found, but the plan should
  verify with `lean_local_search` before writing.
- **Risk: Q3's UNVERIFIED item is mistaken for a gap in Q2.** It is not — Q2 does not depend on
  it. The plan should not gate promotion of Q2 on settling the injectivity question.

## Tactic Survey Results

A tactic survey was run implicitly in the course of building the probes rather than as a separate
`lean_multi_attempt` sweep; the findings that affected the proofs are recorded here.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `w.1 + (x + y) = w.1 + x + y` in `↑D` for an abstract `TemporalOrder` | `abel` | **fail** (left `w.1 + (x+y) = y + (w.1+x)` unsolved; `abel_nf` suggested) | replaced by `add_assoc` / `(add_assoc _ _ _).symm`, which works |
| the same shape in `translationFrame` over a concrete carrier | `abel` | success | as used in `Frames/Standard.lean` |
| `w.1 = w.1 + d + -d` | `simp` | success | default simp set |
| `(0 : ℚ) = 1` arising through `FrameOver.WorldState` | `norm_num at h` | **fail** (goal not reduced through the frame projection) | replaced by `absurd h1 (by norm_num)` with an explicit `(0 : ℚ) = 1` ascription |
| `Set.range τ.state` countable from `[Countable F.WorldState]` | `Set.countable_range` | **fail** (wants `Countable` on the *domain*, i.e. `ℝ`) | `Set.to_countable _` is the right lemma |
| level-set closedness | `Metric.isOpen_iff` after `← isOpen_compl_iff` | success | with `push Not` on the negated *Limit* hypothesis |

Note for the implementer: `abel` is unreliable on `↑D` for an abstract `(D : TemporalOrder)` —
the coercion appears to block its normalization. Prefer explicit `add_assoc`/`add_comm`
rewriting in any promoted module that works at an abstract temporal order.

## Context Extension Recommendations

- **Topic**: Sierpiński-type partition theorems and their absence from Mathlib.
  **Gap**: nothing in `.claude/context/project/lean4/` records which classical point-set results
  Mathlib lacks; this task rediscovered the absence by grepping the Mathlib source.
  **Recommendation**: a short `context/project/lean4/domain/mathlib-gaps.md` listing verified
  absences with the search that established them, seeded with Sierpiński's partition theorem and
  the "dense Dedekind-complete ordered group `≃+o ℝ`" omission that
  `Semantics/DurationClassification.lean` already documents in-tree.
- **Topic**: the `abel`-on-`↑D` failure mode.
  **Gap**: `context/project/lean4/` has no note on tactics that misbehave through this tree's
  `TemporalOrder` coercion.
  **Recommendation**: add a bullet to the Lean tactic guidance recording it, with the
  `add_assoc` workaround.

## Appendix

- **Probes** (both `lake env lean`-green, exit 0, no warnings, no `sorry`):
  - `specs/654_infinite_frame_rigidity_countable_real_durations/probes/01_clock-frames.lean`
  - `specs/654_infinite_frame_rigidity_countable_real_durations/probes/02_countable-real-rigidity.lean`
  - `specs/654_infinite_frame_rigidity_countable_real_durations/probes/README.md`
- **Searches run**: `lean_local_search` on `nonempty_interior_of_iUnion_of_closed` and
  `IsClosed.csSup_mem`; source greps of `.lake/packages/mathlib` for
  `sierpinski|sierpiński` (4 files, all Sierpiński space or bibliography),
  `completeSpace_coe`, `Hölder|Holder` under `Mathlib/Algebra/Order/` (no hits). The
  rate-limited semantic search tools were not needed: every Mathlib lemma used was located by
  local search or source grep.
- **Mathlib declarations the argument rests on**: `nonempty_interior_of_iUnion_of_closed`
  (`Mathlib/Topology/Baire/Lemmas.lean`), `IsClosed.completeSpace_coe`, `IsClosed.csSup_mem` /
  `IsClosed.csInf_mem` (`Mathlib/Topology/Order/Monotone.lean`), `isPreconnected_Ico` /
  `isPreconnected_Ioc` / `isPreconnected_univ`, `closure_Ico` / `closure_Ioc`,
  `mem_interior_iff_mem_nhds`, `Metric.mem_nhds_iff`, `Subtype.dist_eq`,
  `Cardinal.not_countable_real` (`Mathlib/Analysis/Real/Cardinality.lean`).
- **Library declarations reused, none modified**: `FrameOver.ofReflective`,
  `FrameOver.ofReflective_taskRel`, `FrameOver.nullity_identity`, `FrameOver.reflection`,
  `FrameOver.serial`, `FrameOver.limit`, `FrameOver.interpolates`, `FrameOver.forward_comp`,
  `TaskFrame.comp_of`, `TaskFrame.limit_of_shift`,
  `TaskFrame.saturation_of_fib_subsingleton`, `TaskFrame.exists_pos_of_nontrivial`,
  `translationFrame`, `translationFrame_taskRel`, `PartialHistory.extension`,
  `WorldHistory.state`, `WorldHistory.respects_task`.
- **Manuscript anchors cited**, all via `docs/reference/paper-definitions-of-record.md`:
  `def:frame` (all four axioms), `def:frame-properties` (the Complete clause, quoted verbatim
  above), `def:world-history`, `thm:extension`, `cor:occurrence`, `sec:Construction` ("nothing
  prevents a world state from occurring at many times in a single history"), and the standing
  caveat quoted from `Frames/TranslationProduct.lean`.
