# Seed Report: Saturation for the Witness Frames, and R0 without Limit

**Type**: Seed report — written by the orchestrating session as input to this task's research
round, not by a research agent. **Verify it; do not re-derive it.**

**Scope note**: this task exists because its two questions have *uncertain outcomes*, and the
manuscript's appendix must not be blocked on them. The predecessor task consolidates the citable
collection and completes on a predictable schedule. This one settles what that collection is
allowed to *claim*. A precisely located obstruction is a complete outcome here, and is preferred
to a hedged assertion.

**Prior artifacts** (read them; not summarized away here):
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/reports/01_topology-characterizing-limit.md`
  — §3.3 carries the Saturation shadow argument; §3.4 carries the R0 sketch. Both are labelled
  UNVERIFIED there and neither has been formalized.
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/TwoOrigins.lean`,
  `probes/Hedgehog.lean` — the compiled frames.
- The predecessor task's seed report, `specs/658_.../reports/01_seed-topology-collection.md` —
  §3 inventories every compiled fact about both frames.

---

## 1. Q1 — Saturation for the two witness frames

### 1.1 Why it matters, stated precisely

`FormalSystem/Semantics/StateTopology/Counterexamples.lean` proves *Seriality*,
*Compositionality* and *Limit* for both the two-origin half-line and the hedgehog, and
**deliberately does not claim *Saturation***. The module docstrings say so explicitly. Neither
frame is an `IsRegular` instance.

The cost falls on the appendix's most interesting claim. Today it can say:

> some structure satisfying three of the four frame constraints is T1 and not Hausdorff

It cannot yet say:

> some **task frame** is T1 and not Hausdorff

The second is the claim worth making — it says the paper's own notion of a task frame does not
force Hausdorff separation, and that the level of separation *Limit* delivers is exactly T1. The
first is a remark about an auxiliary structure. Closing this gap is the single highest-value item
in this task.

The same holds for the hedgehog, where the stake is the separation of `𝒩_F` from the final
topology of all histories (`finalTopology_ne_nbhdTopology`): a genuine task frame witnessing that
separation is a much stronger statement than a mere structure doing so.

### 1.2 The two-origin frame and the shadow argument

The frame (as compiled): `W = {o true, o false} ∪ {p t : t > 0}` over `D = ℝ`. Origins loop at
every duration; `o b ⇒_x p t` iff `t ≤ x`; `p t ⇒_x p s` iff `t ≤ s ≤ t + x` for `x ≥ 0`;
negatives by reflection.

The paper argument recorded in §3.3 of the topology research report, reproduced here in full so
this task need not reconstruct it:

> Map `W → [0, ∞)` by `o b ↦ 0`, `p t ↦ t`. Every fibre and segment has closed shadow:
> `Fib(o b, x) ↦ [0, x]`, `Fib(p t, x) ↦ [t, t + x]`, and backward fibres and segments are
> intersections of such. So a `⊇`-directed family of nonempty fibres and segments has a common
> shadow point `r` by compactness of `[0,1]`-type intervals. If `r > 0` then `p r` is in every
> member. If `r = 0`, every member contains an origin, and directedness forbids one member
> containing only `o true` and another only `o false` — their common sub-member would contain
> neither, contradicting `r = 0`. So one origin is in every member.

**The `r = 0` branch is where the argument is doing real work** and is the place to concentrate.
The `r > 0` branch is routine.

**A genuine contrast worth compiling either way**: the ℚ-indexed version of this frame **fails**
Saturation — nested rational intervals with an irrational limit have empty intersection. That is
why the witness is over ℝ. Landing `¬ Saturation` for the rational analogue alongside `Saturation`
for the real one makes the role of Dedekind completeness visible, and is a result the appendix can
use even if the positive half proves hard. It also connects to the completed time-indexed-frames
work, whose whole subject is that boundary.

### 1.3 The extractable lemma

The reusable content — and the thing most worth having in `ForMathlib/` — is the general shape:

> a `⊇`-directed family of nonempty sets whose images under a map into a compact space are
> closed has nonempty intersection, under stated conditions on the fibres over the
> accumulation point

State it at the generality the proof actually needs. The `r = 0` directedness step is the part
that does not obviously generalize; if it does not, say so and state the lemma at the weaker
generality that does, rather than forcing it.

Note the precedent set by the countable-ℝ rigidity task, which found Mathlib carries **no**
Sierpiński partition theorem (its `Sierpinski*` declarations are all the Sierpiński *space*) and
proved the real-line form directly in `FormalSystem/ForMathlib/Topology/Sierpinski.lean`. Check
whether that module already contains machinery this argument can reuse, and whether this lemma
belongs beside it.

### 1.4 The hedgehog

Same treatment, **one ray at a time** (the frame has a centre `c` and countably many rays
`p n t`, with no cross-ray tasks). The per-ray structure should make the shadow map easier, not
harder; the question is what happens at the centre, where all rays meet. The compiled history
lemmas `history_single_ray`, `history_centre_past` and `history_reach` characterize how histories
behave there and are the right starting point.

### 1.5 Acceptable outcomes

In descending order of value:

1. *Saturation* proved for both frames; both become `IsRegular` instances; the appendix upgrades
   "structure" to "task frame" throughout.
2. Proved for the two-origin frame only. This is enough for the T1-non-Hausdorff claim, which is
   the appendix's priority; the hedgehog's separation result stays a statement about a structure.
3. Shown to **fail** for one or both, with a witness. Then say exactly what the frames license and
   record it in the appendix support table — a negative result here is informative, since it would
   mean the four constraints exclude these shapes, which is itself a fact about the constraints.
4. A precisely located obstruction: the step that resists, why, and what would close it.

## 2. Q2 — R0 without Limit

### 2.1 What was recorded, and why it is thin

`app:topology-r0` currently derives R0 from T1 alone, and under *Limit* both topologies are R0
(`r0Space_nbhdTopology_of_limit`). The open question is whether R0 is *as fragile as* T1 — i.e.
whether it too fails once *Limit* is dropped — or whether it survives on the other three
constraints.

§3.4 of the topology research report sketched a negative answer, labelled UNVERIFIED: take the
hedgehog with a second special state `u` reaching all ray tips instantaneously (tips-to-`u` by
reflection), giving `w ∈ cl{u}` while `u ∉ cl{w}`.

**Treat that sketch with suspicion.** Its own text visibly restarts mid-sentence ("then every open
set containing `w`… — more simply, …"), which is the signature of an argument that was not
carried through. It also depends on a *modified* hedgehog with tips, whereas the compiled
hedgehog has **unbounded rays and no tips** — the implementation round of the topology task
already caught and corrected exactly this discrepancy once, rewriting §2.3's prose because the
research round's bounded-spokes-with-tips frame is not the frame that was compiled. So the
modified frame this argument needs **does not exist in compiled form**, and may not satisfy what
it needs to.

### 2.2 What to determine

1. Does a witness exist at all — a structure satisfying *Seriality* and *Compositionality*,
   failing *Limit*, whose `𝒩_F` is not R0? Construct it properly rather than patching the sketch.
2. Or does R0 **follow** from the other three constraints? **This is the better outcome if true**,
   and should be stated as a theorem rather than left as the absence of a counterexample.
3. Either way: over ℤ with symmetric `⇒_0` the partition topology is R0 (see
   `nbhdTopology_isOpen_iff_int`), so any witness must live over a dense order. That narrows the
   search.

### 2.3 Why the appendix cares

`app:topology-r0` is stated as a corollary of `app:topology-t1`. Under option (a) that derivation
survives verbatim. But if R0 turns out to hold *without* Limit, the appendix could state R0 at a
weaker hypothesis than T1 — a strictly better result, and a small but real strengthening of the
paper's topological section. If R0 is as fragile as T1, the current presentation is already
optimal and should be left alone. Either finding is worth having; the present state, where nobody
knows, is not.

## 3. Q3 — the three open questions (optional)

Recorded so they are not mistaken for gaps. These are open **mathematically**, not merely
unverified. Settling any is a bonus; none is required.

1. **A frame condition equivalent to `𝒩_F = the final topology of all histories.** The most
   interesting of the three. Known: `𝒩_F` is always *below* the final topology
   (`finalTopology_le_nbhdTopology`), strictly so on the hedgehog
   (`finalTopology_ne_nbhdTopology`). The located obstruction: **the extension theorem gives one
   history per escape, never one history witnessing all escapes.** A condition that supplies the
   simultaneous witness is what is wanted. Record partial progress even if incomplete — the
   frame-constraints audit task (which depends on this one) names this question in its own Q4 and
   will build on whatever is found.
2. **Do they coincide on the metric frame?** Known: on the metric frame both `𝒩_F` and the final
   topology are Euclidean *as far as has been checked* (the straight-line history through `w` hits
   every nearby point). Whether that is an equality proof or an observation needs settling.
3. **A rational-carrier analogue of the two-origin T1-non-Hausdorff frame.** Known: the
   ℚ-indexed version fails *Saturation* (§1.2 above), so the question is whether some *other*
   rational-carrier frame is T1 and not Hausdorff while satisfying all four constraints. Connects
   directly to Q1.

## 4. Constraints

- Every claimed fact carries a sorry-free probe or the label **UNVERIFIED**. No hedged assertions.
- Reuse the compiled witnesses by declaration name; do not rebuild them. The predecessor task may
  have **renamed or re-sited** declarations in `Counterexamples.lean` — re-verify names against the
  live tree before citing, since this seed was written before that task ran.
- Every claim about the manuscript cites a label or quotable phrase, never a line number outside
  `specs/`.
- If anything is promoted: `lake build --wfail` green, standard axioms only,
  `check-module-invariants.sh` all checks pass, `mk_all --check` exits 0, theorem-index and C14
  wiring, and the topology modules kept **out of widely-imported aggregators** (a topology-carrying
  module reachable from `Semantics.lean` has twice caused a `Preorder ℤ` diamond).
- Output: a numbered report giving a verdict per question, the probes, and — the part that matters
  downstream — **an explicit statement of what each outcome licenses the appendix to say**.
