# Research Report: Saturation for the Witness Frames, and R0 without Limit

- **Task**: 659 - Settle saturation witnesses and R0 without Limit
- **Started**: 2026-09-23T07:36:00Z
- **Completed**: 2026-09-23T08:58:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: Task 658 (consolidates the citable collection in the same module; run after it)
- **Sources/Inputs**:
  - `specs/659_settle_saturation_witnesses_and_r0_without_limit/SEED.md`
  - `FormalSystem/Semantics/StateTopology/Counterexamples.lean` (live declaration names re-verified)
  - `FormalSystem/Semantics/StateTopology.lean`, `FormalSystem/Semantics/TaskFrame.lean`
  - `docs/reference/state-topology-appendix-support.md` (flags 1, 3, 4)
  - `docs/theorem-index.md` (topology block), `docs/reference/paper-definitions-of-record.md`
  - `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (`app:topology-t1`, `app:topology-r0`)
  - `typst/FormalFoundations.typ` (`#theorem("Separation")`)
  - Mathlib `IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed`
- **Artifacts**:
  - `specs/659_settle_saturation_witnesses_and_r0_without_limit/reports/01_saturation-witnesses-r0-limit.md`
  - `specs/659_settle_saturation_witnesses_and_r0_without_limit/probes/TwoOriginsSaturation.lean`
  - `specs/659_settle_saturation_witnesses_and_r0_without_limit/probes/HedgehogSaturation.lean`
  - `specs/659_settle_saturation_witnesses_and_r0_without_limit/probes/GhostRayR0.lean`
  - `specs/659_settle_saturation_witnesses_and_r0_without_limit/probes/RationalTwoOrigins.lean`
  - `specs/659_settle_saturation_witnesses_and_r0_without_limit/probes/MetricFinalTopology.lean`
  - `specs/659_settle_saturation_witnesses_and_r0_without_limit/probes/ShadowLemma.lean`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- **Q1 SETTLED, positively, for BOTH frames.** *Saturation* is proved sorry-free for the
  two-origin half-line and for the hedgehog. Both are now `FrameOver.IsRegular` instances. This is
  outcome (1) on the seed's value ranking: the appendix may replace "some structure satisfying
  three of the four constraints" with "some **task frame**" throughout.
- **The shadow argument works, and the `r = 0` branch is not where the difficulty lay.** The real
  content is a *band normal form*: every fibre and every nonempty segment of both relations is
  `(a set of origins) ∪ (a real interval of ray points)`, with an invariant tying the two. Given
  that, the shadow image is a closed bounded interval uniformly, with no case split in the
  statement.
- **Q2 SETTLED, negatively — but not by the recorded sketch.** The seed's suspicion was correct:
  the modified-hedgehog-with-tips argument does not survive contact. It is **replaced** by a
  simpler, compiled witness — the *ghost-ray* frame — satisfying *Seriality* and
  *Compositionality*, failing *Limit*, whose `𝒩_F` is **not R0**. So **R0 is exactly as fragile as
  T1**, and `app:topology-r0`'s present derivation from `app:topology-t1` is already optimal.
- **Q3.2 SETTLED, positively.** On the metric frame (speed-at-most-`c` on `ℝ`) the
  cone-neighbourhood topology and the final topology of all histories **coincide**. The general
  criterion extracted is: one surjective open history is enough.
- **Q3.1 partially settled, with a new certified obstruction.** Because the hedgehog is now a
  *regular* frame that separates `𝒩_F` from the final topology, **no condition derivable from
  `def:frame`'s four constraints can force the two to coincide.** Any equivalent frame condition
  is strictly stronger than regularity.
- **Q3.3 narrowed, with the ℚ contrast compiled.** The literal ℚ transcription of the two-origin
  frame satisfies *Seriality*, *Compositionality* and *Limit* and **fails *Saturation***, via
  rational intervals straddling the cut `{q : q² < 2} | {q : 2 < q²}`. Dedekind completeness is
  load bearing in the real-carrier witness, not decorative.

## Context & Scope

Two open frame-level questions left by the topology research were to be settled so the
manuscript's appendix can state what its witnesses license. Everything below is a bare-relation or
frame-level fact about `FormalSystem/Semantics/StateTopology/Counterexamples.lean`'s witnesses, or
about a new witness built here. Every claim carries a sorry-free probe unless explicitly labelled
**UNVERIFIED**.

Live declaration names were re-verified against the working tree (the seed predates the
predecessor task's renames): `TwoOrigins.rel`, `TwoOrigins.frame`, `TwoOrigins.frame_serial`,
`TwoOrigins.frame_compositional`, `TwoOrigins.frame_limit`, `TwoOrigins.frame_t1Space`,
`TwoOrigins.frame_not_t2Space`, `Hedgehog.rel`, `Hedgehog.frame`, `Hedgehog.frame_serial`,
`Hedgehog.frame_compositional`, `Hedgehog.frame_limit`,
`Hedgehog.finalTopology_ne_nbhdTopology`, `Hedgehog.history_single_ray`,
`Hedgehog.history_centre_past`, `Hedgehog.history_reach` all exist under
`FormalSystem.Semantics.StateTopology` as the seed names them.

Probe verification protocol: each file was elaborated with `lake env lean <path>` (zero errors),
checked for `sorry` (zero occurrences in all six files), and every headline declaration checked
with `#print axioms` — all report exactly `[propext, Classical.choice, Quot.sound]`.

## Findings

### 1. Q1 — *Saturation* holds for both witness frames [SETTLED]

**Verdict: PROVED, both frames.** Probes:
`probes/TwoOriginsSaturation.lean` (259 lines), `probes/HedgehogSaturation.lean` (264 lines).

Headline declarations, all sorry-free, all `pcq` axioms:

| Declaration | Statement |
|---|---|
| `TwoOrigins.rel_saturation` | `TaskFrame.Saturation rel` |
| `TwoOrigins.frame_saturation` | `TaskFrame.Saturation frame.TaskRel` |
| `TwoOrigins.instIsRegular` (anonymous `instance : frame.IsRegular`) | all four `def:frame` constraints |
| `TwoOrigins.taskFrame_t1_not_t2` | `T1Space ∧ ¬ T2Space` on the state topology of a **regular** frame |
| `Hedgehog.rel_saturation` | `TaskFrame.Saturation rel` |
| `Hedgehog.frame_saturation` | `TaskFrame.Saturation frame.TaskRel` |
| `Hedgehog.instIsRegular` (anonymous `instance : frame.IsRegular`) | all four `def:frame` constraints |
| `Hedgehog.taskFrame_t1Space` | `T1Space` via `FrameOver.instT1SpaceOfRegular` |

**The proof's actual shape** (this is what the promotion phase must transcribe, and it differs
from the seed's framing):

1. *Band normal form.* Define `band O a b` = `{o c | c ∈ O} ∪ {p u | a ≤ u ≤ b}` (hedgehog:
   `band k N a b`, with a centre flag `k` and a ray-index set `N`). Then `TwoOrigins.fib_band`
   and `Hedgehog.fib_band` show **every** fibre is a band, and `band_inter` shows bands are closed
   under intersection, so every segment is one too (`TwoOrigins.seg_band`,
   `Hedgehog.class_band`).
2. *The invariant.* `Good O a := (O.Nonempty ∧ a ≤ 0) ∨ (O = ∅ ∧ 0 < a)` — "the origins are
   present exactly when the interval reaches down to `0`". Every fibre is `Good`; `Good` is
   preserved by the intersections that segments actually take.
3. *The uniform shadow.* `TwoOrigins.shadow_band`: for a `Good` band,
   `shadow '' band O a b = Icc (max a 0) (max b 0)` — **one formula, no case split**, closed and
   compact for free (`isCompact_Icc`, `isClosed_Icc`).
4. *Cantor.* `IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed` applied to
   `fun i : ↥S => shadow '' i` gives a common shadow point `r`.
5. *Lifting `r` back.* This is the frame-specific half, and the two frames need **opposite**
   arguments:
   - Two-origin frame: `r > 0` is routine (the ray point `p r` is the unique preimage). `r = 0`
     needs directedness — a member containing only `o true` and one containing only `o false`
     would have a common sub-member containing neither.
   - Hedgehog: `r = 0` is *free* (the centre is the unique preimage of `0`). `r > 0` needs
     directedness to fix a single ray — packaged as `Hedgehog.common_ray`, which consumes
     "each member's ray scope is `univ` or a singleton" (`class_band`'s second conjunct).

**Correction to a recorded expectation.** The seed says "the `r = 0` branch is where the argument
is doing real work and is the place to concentrate". That is true for the two-origin frame only,
and it is four lines. The genuinely load-bearing step in both proofs is step 1-3 — establishing
that every fibre and segment is a band and that the shadow is an `Icc` — which the paper argument
states as "every fibre and segment has closed shadow" without noticing that segments are
intersections whose image under a non-injective map need not be the intersection of the images.
The `{o true} ∩ {o false} = ∅` case is real, and is excluded only because a segment's second
fibre carries a *nonpositive* duration (`Seg R w v x y = Fib R w x ∩ Fib R v (-y)`, `y ≥ 0`).
That is the one place where the paper argument has a genuine gap; `seg_band`'s `hU₂` hypothesis
(`O₂.Nonempty → O₂ = univ ∨ b₂ ≤ x`) is what closes it.

### 2. Q1 — the extractable lemma, at the generality the proof actually needs [SETTLED]

**Verdict: the general lemma is strictly the compactness half.** Probe: `probes/ShadowLemma.lean`.

```
TaskFrame.exists_mem_image_of_directedFamily
  (φ : W → X) [TopologicalSpace X] (hdir : DirectedFamily S)
  (hne : ∀ s ∈ S, s.Nonempty)
  (hc : ∀ s ∈ S, IsCompact (φ '' s)) (hcl : ∀ s ∈ S, IsClosed (φ '' s)) :
  ∃ r : X, ∀ s ∈ S, r ∈ φ '' s
```

plus an `Icc`-shaped specialisation `exists_mem_image_of_directedFamily_Icc` over any
`[LinearOrder X] [OrderClosedTopology X] [CompactIccSpace X]`, which is the form both witnesses
consume.

**The lifting step does not generalize**, and the seed's instruction ("if it does not, say so and
state the lemma at the weaker generality that does") applies: the two frames' arguments at the
accumulation point are not instances of one another. Stating a common generalization would mean
abstracting "the fibre of `φ` over `r` is finite and directedness selects a member of it", which
is longer than either concrete argument and has exactly two instances. Recommendation: extract the
lemma above only.

**Where it belongs.** `FormalSystem/ForMathlib/Topology/` currently holds only `Sierpinski.lean`
(Baire + order-propagation; no directed-family, compactness or Cantor-intersection machinery — I
checked the whole `ForMathlib/` tree). There is nothing there to reuse. But note the lemma above is
a two-line wrapper around a Mathlib declaration that already exists
(`IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed`); it is **not** upstreamable
material, since its only content is the translation from this development's `DirectedFamily` to
Mathlib's `Directed (· ⊇ ·)`. **Recommendation: put it next to `DirectedFamily` in
`FormalSystem/Semantics/TaskFrame.lean`, not in `ForMathlib/`.** Adding a `ForMathlib/` module
also costs a C24 exception entry in `scripts/CheckInitImportsMain.lean`, an entry in
`FormalSystem/ForMathlib.lean`, and two generated README table rows — unjustified for a wrapper.

### 3. Q1 — the ℚ contrast: *Saturation* fails over a rational carrier [SETTLED]

**Verdict: PROVED to fail.** Probe: `probes/RationalTwoOrigins.lean` (277 lines).

`RationalTwoOrigins.rel` is the two-origin relation verbatim with `ℝ` replaced by `ℚ` in both the
duration type and the ray index. Compiled facts:

- `rel_serial`, `rel_compositional`, `rel_limit` — the three constraints survive the move
  unchanged (the proof scripts transfer verbatim; nothing in them used completeness).
- `not_rel_saturation : ¬ TaskFrame.Saturation rel`.

The witness family is `straddleFamily`: all segments `Seg rel (p a) (p b) (b-a) (b-a)` with
`0 < a`, `a² < 2 < b²`. `mem_straddle` shows each such segment is exactly the rational interval
`[a, b]` on the ray, with no origins. Directedness is `max`/`min`. Emptiness of the intersection
uses the Newton step `t = (2s+2)/(s+2)`, which satisfies `t² - 2 = 2(s²-2)/(s+2)²` and
`t - s = (2 - s²)/(s+2)`, so it crosses the cut strictly in whichever direction `s` sits; the
remaining case `s² = 2` is excluded by `sq_ne_two`, proved from `Rat.num_pow` (no `Real`, no
`Irrational` — that Mathlib module is not in this checkout's build).

**Note for the promotion phase**: no `TemporalOrder.of ℚ` is needed. `TaskFrame.Saturation` is a
bare-relation predicate whose duration type needs only
`[AddCommGroup] [LinearOrder] [IsOrderedAddMonoid] [Nontrivial]`, all of which `ℚ` has. A frame-level
form would additionally need a `TemporalOrder` instance over `ℚ`, which was not investigated.

### 4. Q2 — R0 fails without *Limit*; the recorded sketch is replaced [SETTLED]

**Verdict: R0 FAILS. It is as fragile as T1.** Probe: `probes/GhostRayR0.lean` (222 lines).

The seed's suspicion about §3.4 of the topology report is confirmed: the modified hedgehog with
"tips" is not the compiled hedgehog (which has unbounded rays and no tips), and the sketch was not
carried through. **It is not patched here; it is replaced.** The replacement is much simpler and
needs no hedgehog at all.

**The ghost-ray frame.** States `W = {γ} ∪ {r t : t ∈ ℝ}` over `D = ℝ`:

```
γ   ⇒_x γ    always
γ   ⇒_x r s  iff  0 < x ∧ 0 < s        (the ghost reaches the whole open ray, instantly)
r t ⇒_x γ    iff  x < 0 ∧ 0 < t        (the reflection; nothing reaches γ forward)
r t ⇒_x r s  iff  t ≤ s ≤ t + x        (x ≥ 0; negatives by reflection — the two-origin drift law)
```

Compiled facts: `rel_refl`, `rel_serial`, `rel_reflection`, `rel_compositional` (both halves),
`not_limit`, `not_limit_witness`, `not_r0Space_nbhdTopology`, plus the frame-level
`frame`, `frame_serial`, `frame_compositional`, `frame_not_limit`, `frame_not_r0Space`.

**Why R0 fails, in one paragraph.** `r s ∈ cl{γ}` for every `s > 0`, because `γ` lies in every
positive cone at `r s` (`γ_mem_cone_r`). Then `r 0 ∈ cl{γ}` too — not by any task linking them,
but because every cone at `r 0` contains `r (x/2)`, and `cl{γ}` is closed
(`nbhdTopology_isClosed_iff`). Conversely `{r 0}` is `𝒩_F`-**closed** (`isClosed_singleton_r0`:
the complement is open, with radius `1` at `γ` and radius `|t|` at `r t`), so `cl{r 0} = {r 0}`
and `γ ∉ cl{r 0}`. Specialization is therefore asymmetric.

**Two structural observations worth recording**, both used in finding the witness:

- The "infinitesimal" relation `I w u := ∀ x > 0, u ∈ cone R w x` is **always symmetric** at a
  frame, because `TaskFrame.reflect` makes `R w y u ↔ R u (-y) w` and `|-y| = |y|`. So an R0
  failure can never come from stage 1 of the closure; it must come from a *later* stage. This is
  why the funnel (`funnelRel`) cannot be a witness — its `𝒩_F` is indiscrete
  (`funnelRel_nbhdTopology_eq_top`) and therefore R0.
- At every *Serial* + *Compositional* reflective frame, `R w 0 w` holds: `R₀` is symmetric (by
  reflection), transitive (by *Compositionality* at `x = y = 0`) and total-on-its-domain (by
  *Seriality*), hence reflexive. *(This one is **UNVERIFIED** — it was used as design guidance for
  the witness, not as a step in any probe. It is a three-line argument and would be worth landing
  beside `nullity_of_serial_limit`, which currently derives `R w 0 w` from *Limit*.)*

**Why the intended-but-broken sketch could not have worked as stated**: the sketch wants `u` to
reach the ray *tips* instantaneously. The ghost-ray frame shows the correct shape is that the
ghost must reach *an entire open set of ray points that accumulates at the excluded point* — the
asymmetry is between the ghost and the ray's endpoint `r 0`, not between the ghost and a tip.

### 5. Q3.1 — a frame condition for `𝒩_F` = the final topology [PARTIAL, with a new obstruction]

**Verdict: a new, certified negative constraint on any answer; the positive half stays open.**

- **Certified (this task):** the hedgehog is now a **regular** frame
  (`Hedgehog.instIsRegular`) and `Hedgehog.finalTopology_ne_nbhdTopology` separates the two
  topologies on it. Therefore **no condition that follows from `def:frame`'s four constraints can
  be equivalent to (or sufficient for) the coincidence.** Before this task that inference was
  unavailable, because the hedgehog was only a structure. Any answer to Q3.1 must be strictly
  stronger than regularity. **This is the fact the frame-constraints audit task's Q4 should build
  on.**
- **Certified (this task), the positive side:**
  `MetricFrame.finalTopology_eq_of_surjective_open_history` — if some history `τ` is surjective
  and `𝒩_F`-open as a map, the final topology collapses onto `𝒩_F`. No relation-level condition is
  needed; a single good history suffices. Proof: `le_iSup` makes every final-open set
  coinduced-`τ`-open, hence `τ ⁻¹' O` is open, hence `O = τ '' (τ ⁻¹' O)` is `𝒩_F`-open.
- **UNVERIFIED reformulation of the remaining gap.** Unpacking the equality gives: `𝒩_F` equals
  the final topology iff for every `w` and every `C` with `w ∉ C` and `C ∩ cone R w x ≠ ∅` for all
  `x > 0`, there is a history `τ` with `τ 0 = w` and `0 ∈ closure (τ ⁻¹' C)`. The located
  obstruction is that the escapes `u_x ∈ C ∩ cone R w x` must be **pairwise compatible along one
  history** — `R (u_x) (t_y - t_x) (u_y)` for the visiting times — which is a *thread* condition,
  not a two-point condition on `⇒`. The hedgehog's escapes lie on distinct rays with no cross-ray
  task, so no thread exists. A candidate frame condition is therefore "every escape net admits a
  coherent thread"; whether that is equivalent, and whether it has a formulation not mentioning
  histories, was **not** settled here.

### 6. Q3.2 — do they coincide on the metric frame? [SETTLED, yes]

**Verdict: YES, and it is an equality proof, not an observation.** Probe:
`probes/MetricFinalTopology.lean` (166 lines).

First finding: **"the metric frame" is not a declared object in the library.** `grep` over
`FormalSystem/` and `docs/` finds it only as prose in `StateTopology.lean`'s `Triangle` docstring.
What exists is the real-carrier *bridge* (`nbhdTopology_eq_real`,
`coneTopology_eq_nbhdTopology_real`), which is a hypothesis shape
(`hcone : ∀ r x, 0 < x → cone R r x = Metric.ball r (c * x)`), not a frame. The question could not
be answered without first naming one, so the probe names it:

`MetricFrame.rel c : ℝ → ℝ → ℝ → Prop := fun r y u => |u - r| ≤ c * |y|` (speed at most `c`).

Compiled facts: `rel_reflection`, `rel_serial`, `rel_limit`, `rel_compositional` (both halves —
the interpolation direction splits at `w + (c·x/|v-w|)·(v-w)`), `cone_eq_ball`,
`nbhdTopology_eq` (`𝒩_F` **is** the Euclidean topology, via the existing
`nbhdTopology_eq_real`), `isHistory_line`, and

```
MetricFrame.finalTopology_eq_nbhdTopology (hc : 0 < c) :
  (⨆ σ : {σ : ℝ → ℝ // IsHistory (rel c) σ}, coinduced σ.1 inferInstance) = nbhdTopology (rel c)
```

The straight line `t ↦ c · t` is a history, surjective, and open (it is multiplication by a
nonzero constant), so the general criterion of §5 applies. *Saturation* for `MetricFrame.rel` was
not probed (its fibres are closed balls, so it should follow from the same `Icc` route with the
identity as shadow map) — **UNVERIFIED**.

**Consequence for the manuscript**: the hedgehog's separation of `𝒩_F` from the final topology is
a feature of **branching**, not of the cone construction. On the frame the paper's intuition is
built from, the two agree.

### 7. Q3.3 — a rational-carrier T1-non-Hausdorff frame [PARTIAL, narrowed]

**Verdict: the obvious candidate is ruled out; the question stays open, narrowed.**

- The literal ℚ transcription of the two-origin frame is **not** a task frame: §3 above compiles
  `¬ Saturation` for it. So it cannot witness anything about task frames over ℚ.
- The duration type must be densely ordered: `TaskFrame.nbhdTopology_isOpen_iff_int` and
  `limit_int_iff` make `⇒₀ ⊆ id` and *Limit* coincide over `ℤ`, so no witness lives there. ℚ
  passes that test.
- **What a ℚ-carrier witness would have to do** (UNVERIFIED, but a precise narrowing): T1 and
  non-Hausdorff requires two distinct states whose positive cones meet at every scale — the
  two-origin pattern — while *Saturation* is the `S₁ᵈ` downward-directed-intersection condition of
  the ball-space hierarchy (see `TaskFrame.Saturation`'s docstring). Over a ray indexed by ℚ, the
  fibres and segments are order-intervals and `S₁ᵈ` is exactly Dedekind completeness of the index,
  which ℚ lacks. So a witness cannot have a ℚ-indexed *ray*; it would need a carrier that is
  spherically complete for a non-order reason (a valued/ultrametric shape, where balls are nested
  rather than linearly ordered) while the *duration* type stays dense. That is a different
  construction from anything in the collection, and is the honest next probe.

## Decisions

- **Replace, do not patch, the R0 sketch.** §3.4 of the topology research report is superseded by
  the ghost-ray frame, which is simpler, is compiled, and does not depend on a modified hedgehog
  that never existed in Lean.
- **Extract only the compactness half of the shadow argument**, and site it beside
  `DirectedFamily` in `FormalSystem/Semantics/TaskFrame.lean` rather than in `ForMathlib/`. The
  lifting step is genuinely frame-specific and abstracting it would cost more than it saves.
- **Name a metric frame.** Q3.2 was unanswerable while "the metric frame" existed only as prose;
  `MetricFrame.rel` is the minimal object that makes the question well posed, and it is worth
  promoting on its own (it also supplies the paper's running intuition with a citable declaration).
- **Do not claim `R w 0 w` from *Seriality* + *Compositionality* in the manuscript yet** — it is
  labelled UNVERIFIED above and should be a probe in the implementation round if wanted.

## Recommendations

Prioritized, for the plan and promotion phases.

1. **Promote `TwoOrigins` and `Hedgehog` *Saturation* and the two `IsRegular` instances** into
   `FormalSystem/Semantics/StateTopology/Counterexamples.lean`. This is the highest-value item and
   the only one the appendix is currently blocked on. Required edits beyond the proofs:
   - Rewrite the module docstring's "Two more frames, with a different constraint profile" section
     and both per-frame docstrings: the "**`Saturation` is deliberately NOT claimed for this
     frame**" paragraphs (lines ~44, ~639, ~807, ~1078, ~1238) become statements that all four are
     proved, and the "**not** an `IsRegular` instance" sentences must be **deleted**, not softened.
     The `funnelFrame` paragraph ("deliberately **not** an `IsRegular` instance, and must never be
     given one") must be left exactly as it is — the funnel's whole content is that it is not
     regular.
   - `docs/reference/state-topology-appendix-support.md` **flag 3** flips from `pending-sibling` to
     `certified`, and its text ("what is certified is 'there is a structure satisfying *Seriality*,
     *Compositionality* and *Limit* that is T1 and not Hausdorff'") is replaced by the task-frame
     form. Flag 1's "on a structure satisfying *Seriality*, *Compositionality* and *Limit*" becomes
     "on a task frame".
   - `docs/theorem-index.md`: the row at the `TwoOrigins.frame_not_t2Space` entry loses its
     parenthetical "(and does not claim *Saturation*)"; the `Frame class` column on the
     `TwoOrigins.*` and `Hedgehog.*` rows changes from `—` to the regular class.
   - C14 axiom pins: `C14_BASELINE` and its `#print axioms` source heredoc in
     `scripts/check-module-invariants.sh` must be edited **together**, appending the new
     declarations in the same order in both.
   - `FormalSystem/Semantics/README.md:63` prose.
2. **Promote the ghost-ray frame** as the R0 witness, into the same module (it is a fourth witness
   with a fourth constraint profile — *Seriality* + *Compositionality*, no *Limit*, R0 fails). The
   module's `linter.style.longFile 1700` ceiling will need raising; the docstring comment there
   says to raise it "only when a witness genuinely grows", so a new witness is a legitimate reason
   — but see risk 3 below about splitting instead.
   `docs/reference/state-topology-appendix-support.md` **flag 4** flips from `pending-sibling` to
   `certified`, with the corrected witness named. `app:topology-r0`'s derivation from
   `app:topology-t1` is confirmed optimal and should be **left alone**.
3. **Promote `MetricFrame`** (relation, constraints, `cone_eq_ball`, `nbhdTopology_eq`,
   `isHistory_line`, `finalTopology_eq_nbhdTopology`) plus the general criterion
   `finalTopology_eq_of_surjective_open_history`. The criterion belongs in
   `FormalSystem/Semantics/StateTopology.lean` beside `finalTopology_le_nbhdTopology`; the frame
   belongs in `Counterexamples.lean` or (better, see risk 3) a new sibling module.
4. **Promote `RationalTwoOrigins`** for the ℚ contrast. Lowest priority of the four, but it is the
   only compiled statement in the collection that exhibits a frame constraint *failing* for a
   completeness reason, and it is what licenses the appendix to say why the witness is over ℝ.
5. **Keep the topology modules out of widely-imported aggregators.** `Counterexamples.lean` is
   reached only from the generated root `FormalSystem.lean:498` and
   `Tests/BimodalTest/Semantics/StateTopologyTest.lean:7`; `FormalSystem/Semantics.lean` does not
   mention `StateTopology` at all, and `docs/ARCHITECTURE.md`'s "The state topology is a leaf, on
   purpose" section records that a topology-carrying module reachable from `Semantics.lean` has
   produced a `Preorder ℤ` diamond twice. Any new sibling module must be added to the generated
   root via `lake exe mk_all --lib FormalSystem` and to nothing else.
6. **Gate commands for the promotion phase**, as documented:
   `lake build --wfail`; `bash scripts/check-module-invariants.sh` (C2/C14 axiom pins, C15 ledger
   round trip, C21, C24, C33); `lake exe mk_all --lib FormalSystem --check`.

## Risks & Mitigations

- **Risk: the promoted proofs are long and the module has a length ceiling.** The five witness
  probes total ~1,190 lines; `Counterexamples.lean` is already at 1,510 with a
  `linter.style.longFile 1700` ceiling. *Mitigation*: the *Saturation* proofs must go into
  `Counterexamples.lean` (they are about its frames), but the ghost-ray, metric and ℚ frames are
  new witnesses and are better sited in one or two new leaf modules under
  `FormalSystem/Semantics/StateTopology/`, wired only into the generated root. Decide this in the
  plan, not during implementation.
- **Risk: raising `longFile` to park unrelated material.** The existing comment forbids exactly
  that. *Mitigation*: raise it only for the two *Saturation* proofs; put the new frames elsewhere.
- **Risk: the `IsRegular` instances change instance resolution downstream.** Both frames become
  `T1Space` instances through `FrameOver.instT1SpaceOfRegular`, and `FrameOver.r0Space_coneTop`,
  `iInter_cone_eq_singleton` and `coneTop_le_stateTopology` all become available on them.
  *Mitigation*: `Counterexamples.lean` is a leaf, so blast radius is confined to it and the test
  module; still, run the full `lake build --wfail`, not a scoped build.
- **Risk: docstring edits are the largest part of the diff and are easy to half-do.** Five
  separate paragraphs assert *Saturation* is not claimed, and two assert the frames are not
  `IsRegular` instances. *Mitigation*: the plan should enumerate them by line anchor (they are at
  the module docstring's "Two more frames" section, and at the `TwoOrigins` / `TwoOrigins.frame` /
  `Hedgehog` / `Hedgehog.frame` docstrings), and the phase is not green until
  `grep -n "deliberately not claim\|not.*IsRegular instance"` returns only the `funnelFrame`
  occurrences.
- **Risk: `Mathlib.NumberTheory.Real.Irrational` is not built in this checkout.** The ℚ probe was
  written to avoid `Real` entirely for that reason (`sq_ne_two` from `Rat.num_pow`). *Mitigation*:
  keep it that way on promotion; do not "simplify" it to `irrational_sqrt_two`, which would add a
  build dependency the tree does not currently carry.
- **Risk: probe-only tactic imports.** `RationalTwoOrigins.lean` and `MetricFinalTopology.lean`
  needed explicit `Mathlib.Tactic.{Linarith,FieldSimp,Positivity,Ring}` and
  `Mathlib.Topology.Algebra.Order.Field` imports that `FormalSystem.Semantics.TaskFrame` does not
  transitively supply. *Mitigation*: on promotion into `Counterexamples.lean` (which imports
  `StateTopology`) these are already in scope; a *new* module must check its own imports.

## Tactic Survey Results

Tactics were exercised directly against the real proof goals rather than surveyed abstractly;
`lean_multi_attempt` was not used because every goal here sits inside a multi-hundred-line
development that had to be written before any goal existed.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| shadow image = `Icc` (band case analysis) | `rcases` + `linarith` | success | `max_eq_right`, `max_eq_left`, `abs_of_pos` |
| directed family of compacts has a common point | `exact` | success | `IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed` |
| ray-drift arithmetic, all frames | `linarith` | success | needs explicit `Mathlib.Tactic.Linarith` import outside `StateTopology`'s cone |
| interpolation point for `Compositionality` | `rcases min_choice ... <;> simp only [...] <;> linarith` | success | the existing `TwoOrigins.rel_compositional` idiom transfers verbatim |
| metric-frame interpolation `|v - u| ≤ c·y` | `rw [abs_mul, abs_of_nonneg …]` + `linarith` | success | `div_mul_cancel₀`, `div_le_one` |
| `∀ q : ℚ, q² ≠ 2` | `omega` case split + `nlinarith` | success | `Rat.num_pow`; hints `sq_nonneg (q.num ± 2)` |
| `Newton step` inequalities over ℚ | `field_simp; ring` then `div_pos` / `div_neg_of_neg_of_pos` | success | needs `Mathlib.Tactic.Ring` imported explicitly |
| `positivity` on `c * |x|` | `positivity` | fail as a bare closer | succeeds after `simp only [sub_self, abs_zero]` |
| `rw [mem_straddle (lt_of_straddle …)]` with subtype anonymous constructors | `rw` | fail (whnf timeout at 2,000,000 heartbeats) | fixed by restating the helper over bare `ℚ` and passing `(a := _) (b := _)` explicitly — **the lesson: never let unification solve `?a.1 ≟ e` for an anonymous-constructor `e`** |

## Context Extension Recommendations

- **Topic**: Probe-file import prerequisites outside the `StateTopology` import cone.
  **Gap**: `FormalSystem.Semantics.TaskFrame` does not transitively supply `linarith`, `ring`,
  `field_simp`, `positivity`, or the `LinearOrder ℚ` instances; a probe importing only it fails
  with a bare "unknown tactic", which is easy to misread as a Lean-version problem.
  **Recommendation**: add a short subsection to
  `.claude/context/project/lean4/operations/` (or to `FormalSystem/Semantics/README.md`) listing
  the explicit `Mathlib.Tactic.*` imports a standalone probe needs, and noting that
  `Mathlib.NumberTheory.Real.Irrational` and `Mathlib.Analysis.SpecialFunctions.Pow.NNRpow` are
  **not** in this checkout's build.
- **Topic**: The `Subtype.val` unification trap.
  **Gap**: No context file records that passing `h : (⟨e, _⟩ : {x // P x}).val < …` to a lemma with
  implicit subtype arguments makes Lean attempt `?a.1 ≟ e` and hang in `whnf`.
  **Recommendation**: add it to the lean4 extension's patterns directory as a named pitfall with
  the fix (restate the helper over the base type, or pass `(a := …) (b := …)` explicitly).

## Appendix

### Probe inventory

All six files are under
`specs/659_settle_saturation_witnesses_and_r0_without_limit/probes/`. All compile with
`lake env lean <path>` with zero errors, contain zero `sorry`, and every headline declaration
reports axioms `[propext, Classical.choice, Quot.sound]`.

| File | Lines | Settles |
|---|---|---|
| `TwoOriginsSaturation.lean` | 259 | Q1, two-origin half-line |
| `HedgehogSaturation.lean` | 264 | Q1, hedgehog |
| `RationalTwoOrigins.lean` | 277 | Q1's ℚ contrast, Q3.3 partial |
| `GhostRayR0.lean` | 222 | Q2 |
| `MetricFinalTopology.lean` | 166 | Q3.2, Q3.1 positive criterion |
| `ShadowLemma.lean` | 51 | Q1's extractable lemma |

### What each outcome licenses the appendix to say

| Outcome | Licensed statement | Evidence |
|---|---|---|
| Q1, two-origin | "Some **task frame** is T1 and not Hausdorff." Replaces "some structure satisfying three of the four constraints". | `TwoOrigins.taskFrame_t1_not_t2`, `TwoOrigins.frame_saturation` |
| Q1, hedgehog | "Some **task frame** has `𝒩_F` strictly below the final topology of all histories." | `Hedgehog.frame_saturation` + `Hedgehog.finalTopology_ne_nbhdTopology` |
| Q1, ℚ contrast | "The witness is over `ℝ` because the same relation over `ℚ` satisfies *Seriality*, *Compositionality* and *Limit* but fails *Saturation*." | `RationalTwoOrigins.not_rel_saturation` |
| Q2 | "*R0* is as fragile as *T1*: dropping *Limit* breaks it, even with *Seriality* and *Compositionality*. `app:topology-r0`'s derivation from `app:topology-t1` is therefore the right presentation and should not be weakened." | `GhostRay.not_r0Space_nbhdTopology`, `GhostRay.frame_not_r0Space` |
| Q3.1 | "No condition following from `def:frame`'s four constraints makes `𝒩_F` the final topology of all histories." | `Hedgehog.instIsRegular` + `Hedgehog.finalTopology_ne_nbhdTopology` |
| Q3.2 | "On the metric frame the two topologies coincide; the hedgehog's separation is a feature of branching." | `MetricFrame.finalTopology_eq_nbhdTopology` |

### Manuscript anchors cited

- `app:topology-t1` — `\begin{Tthm} \label{app:topology-t1}` "$\mathcal{T}_{\F}$ is T1 for every
  task frame $\F$."
- `app:topology-r0` — `\begin{Cthm} \label{app:topology-r0}` "$\mathcal{T}_{\F}$ is \textit{R0}
  for every task frame $\F$.", proved as a corollary of `app:topology-t1`.
- `def:frame#Saturation` — "$\bigcap \mathcal{S} \neq \emptyset$ for any $\supseteq$-directed
  family $\mathcal{S}$ of nonempty fibers and segments."
- Typst counterpart: `#theorem("Separation")[$cal(T)_(taskframe)$ is T1, and hence R0, for every
  frame $taskframe$.]` in `typst/FormalFoundations.typ`.
- Both appendix labels are recorded `LIVE-UNPINNED` in
  `docs/reference/paper-definitions-of-record.md`; cite them by label, since the line numbers
  recorded there are stale against the live file.

### References

- `FormalSystem/Semantics/TaskFrame.lean` — `Saturation`, `DirectedFamily`, `IsFiber`,
  `IsSegment`, `Fib`, `Seg`, `cone`, `FrameOver.IsRegular`, `FrameOver.instT1SpaceOfRegular`
- `FormalSystem/Semantics/StateTopology.lean` — `nbhdTopology`, `nbhdTopology_isClosed_iff`,
  `t1Space_nbhdTopology_iff_limit`, `r0Space_nbhdTopology_of_limit`,
  `r0Space_iff_mem_closure_comm`, `finalTopology_le_nbhdTopology`, `nbhdTopology_eq_real`,
  `Triangle`, `QuickFwd`, `NoOneWay`
- `docs/ARCHITECTURE.md` — "The state topology is a leaf, on purpose"
- `docs/development/MODULE_INVARIANTS.md`, `docs/development/CI_CD_PROCESS.md` — gate commands
