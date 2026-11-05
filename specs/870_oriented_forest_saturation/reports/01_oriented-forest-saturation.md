# Research Report: Task #870

**Task**: 870 - Oriented-forest Saturation lemma for TaskFrame
**Started**: 2026-11-05T00:00:00Z
**Completed**: 2026-11-05T00:00:00Z
**Effort**: medium-high
**Dependencies**: None
**Sources/Inputs**:
- Codebase (`FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/Semantics/IntNormalForm.lean`)
- Mathlib `Mathlib/Combinatorics/SimpleGraph/{Acyclic,Paths,Basic}.lean`, `Walk/{Basic,Operations,Decomp}.lean` (pin `v4.33.0-rc1`, commit `79d0395a`)
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` section 1.2 (claim, five-step argument, and the 2026-11-05 oriented-forest amendment)
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md` finding 4 (AA carrier layer split, consumer 1)
- Compiled prototype written this dispatch: `specs/870_oriented_forest_saturation/prototype/oriented-forest-core.lean`
**Artifacts**:
- `specs/870_oriented_forest_saturation/reports/01_oriented-forest-saturation.md`
- `specs/870_oriented_forest_saturation/prototype/oriented-forest-core.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **A sorry-free route exists and most of it is already compiled.** A 200-line standalone
  prototype (`prototype/oriented-forest-core.lean`, compiles clean under `lake env lean`, no
  `sorry`, no warnings) verifies the oriented-forest hypothesis encoding plus *steps 1-3* of
  report 03 section 1.2's five-step argument and the *existence* half of step 4. Everything
  measured below is compiled unless explicitly labelled derived.
- **Recommended hypothesis encoding** (three fields, no forest data structure, stated over the
  bare one-step relation): `loopFree : ∀ u, ¬ E u u`; `oppFree : ∀ u v, E u v → ¬ E v u`;
  `acyclic : (SimpleGraph.fromRel E).IsAcyclic`. The three fields are exactly "no undirected
  1-cycle", "no undirected 2-cycle", "no undirected cycle of length ≥ 3" in the underlying
  **multigraph**, which is how this encoding discharges the amendment's "why multigraph, not
  simple graph" requirement: `SimpleGraph.fromRel` deduplicates parallel edges, and the first
  two fields are precisely what the deduplication would otherwise readmit.
- **Mathlib's `SimpleGraph/Acyclic.lean` at this pin carries exactly the needed API** —
  `IsAcyclic.subsingleton_path`, `IsAcyclic.eq_penultimate_of_adj_end`, `IsAcyclic.path_concat`,
  `Walk.IsPath.concat`, `Walk.penultimate_concat`, `Walk.support_concat`, `Walk.getVert_append`.
  Two names the obvious search finds are **deprecated** at this pin and must not be used:
  `isAcyclic_iff_path_unique` and `IsAcyclic.path_unique` (use `isAcyclic_iff_subsingleton_path`
  / `IsAcyclic.subsingleton_path`), and `Walk.isPath_iff_eq_nil` / `Walk.nil_iff_length_eq`
  (use `Walk.isPath_iff_nil` / `Walk.length_eq_zero_iff`).
- **One residual hard step, located precisely**: step 4's *independence* claim (the merge vertex
  does not depend on which member element was chosen). It is **not** derivable from
  directed-path uniqueness — witness below — and needs a Mathlib-path-uniqueness argument over
  a concatenated approach walk. Estimated 150-250 lines; route given in full, nothing blocking.
- **Natural home is a new module, not `TaskFrame.lean`.** The lemma must mention the one-step
  relation and `iter`, both of which live downstream of `TaskFrame.lean`
  (`FormalSystem/Semantics/IntNormalForm.lean`). Recommendation: new
  `FormalSystem/Semantics/OrientedForest.lean` importing `IntNormalForm`, with a pointer added
  to `TaskFrame.lean`'s `saturation_of_*` inventory block.

## Context & Scope

Researched: how to state and prove, sorry-free, that every oriented forest over ℤ-time
satisfies the literal `TaskFrame.Saturation` obligation, following report 03 section 1.2's
five-step argument, at the **undirected-acyclicity** hypothesis strength pinned by that
section's 2026-11-05 amendment (the underlying undirected *multigraph* of the one-step edge
relation is a forest), stated over a bare task relation without a forest data structure.

Constraints honoured: no `sorry`, no new axiom, no plan-level deferral; blocked MCP tools
(`lean_diagnostic_messages`, `lean_file_outline`) not called; the two concurrent sibling tasks'
file scope (867: `Metalogic/Expressiveness/**`) is disjoint from everything touched here, and
nothing in `FormalSystem/**` was modified by this dispatch.

Out of scope and untouched: the universal-cover construction itself (consumer 2's prerequisite),
`SeparationOver`, Rabin's theorem, and the ladder/`RaySummary` files.

## Findings

### Codebase Patterns

**The literal obligation** (compiled, `FormalSystem/Semantics/TaskFrame.lean:691`):

```lean
def Saturation {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ S : Set (Set W), DirectedFamily S →
    (∀ s ∈ S, (IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty) → (⋂₀ S).Nonempty
```

with `Fib R w x = {u | R w x u}` (`:427`), `Seg R w v x y = Fib R w x ∩ Fib R v (-y)` (`:477`),
`DirectedFamily S = S.Nonempty ∧ ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂` (`:507`),
`IsFiber` (`:569`) and `IsSegment` (`:580`, carrying the `0 ≤ x`, `0 ≤ y` proviso).

**The reusable constructive core already exists** (compiled, `TaskFrame.lean:1812`):
`sInter_nonempty_of_directed_of_minimal` takes a member `Sstar` that is `⊆`-minimal among
members and concludes `(⋂₀ S).Nonempty`, depending on **no axioms at all**. Its docstring says
in as many words that it is "reusable at any carrier where a minimal member is available by
other means". That is exactly this task's shape: **steps 2-5 of the paper argument are nothing
but the production of a `⊆`-least member**, and step 5 is then this one lemma. No new
family-level machinery is needed.

**The relation shape to target** (compiled, `FormalSystem/Semantics/IntNormalForm.lean:391`):

```lean
def ofStepRel {W : Type} (R₁ : W → W → Prop) (w : W) (d : ℤ) (u : W) : Prop :=
  (0 ≤ d → iter R₁ d.natAbs w u) ∧ (d ≤ 0 → iter R₁ d.natAbs u w)
```

with `iter` (`:130`) right-appending (`iter R (n+1) w u ↔ ∃ v, iter R n w v ∧ R v u`), and the
sign-split lemmas `ofStepRel_of_nonneg` (`:397`) / `ofStepRel_of_nonpos` (`:404`) already
compiled. `FrameOver.ofStep` (`:456`) currently discharges its `saturation` field through
`saturation_of_finite`, and its own docstring records that this is "the *only* applicable route
here" and costs `Classical.choice`. **The lemma this task lands is the first route that reaches
an infinite carrier for a relation of arbitrary branching shape**, which is what both consumers
need (the AA carrier `W ⊕ (W × List W)` is infinite; the cover is infinite).

**Existing `saturation_of_*` inventory and why none applies** (compiled; confirms task 865
finding 4's reading): `saturation_of_finite` (finite carrier), `saturation_of_subsingleton`,
`saturation_of_permissive`, `saturation_of_eq`, `saturation_of_fib_subsingleton`,
`saturation_of_fib_finite` (all shape-constrained), `saturation_of_deterministic`
(`Semantics/FrameProperty.lean`). An oriented forest may branch infinitely in both directions,
so fibres are neither subsingletons nor finite.

**No graph or acyclicity predicate exists in `FormalSystem/**`** (measured by grep for
`SimpleGraph` / `Acyclic`): the only two hits are prose — `Semantics/FrameClassValidity.lean:61`
(about import acyclicity, unrelated) and `Semantics/Correspondence/FwdRecPeriodicity.lean:49`
(a note that `SimpleGraph.Walk` is finite and undirected and so cannot model a bi-infinite
history). This confirms the amendment's own grep and means the encoding choice is unconstrained
by precedent.

**Module-placement finding.** `TaskFrame.lean` cannot host the lemma: a Lean structure field's
type may only mention declarations that precede it, and more simply, `iter`/`ofStepRel` live in
`IntNormalForm.lean`, which imports `TaskFrame.lean` (via `PartialHistory`). The dispatch's
"natural home: next to `saturation_of_fib_finite`" is therefore not available as written. Both
files' import blocks are fine-grained Mathlib imports, so adding
`import Mathlib.Combinatorics.SimpleGraph.Acyclic` to a new `Semantics/` module is in keeping
with the existing style.

### External Resources

**Mathlib names verified to exist at this pin** (read from the pinned source under
`.lake/packages/mathlib`, not recalled):

| Name | File:line | Use here |
|------|-----------|----------|
| `SimpleGraph.fromRel` | `Combinatorics/SimpleGraph/Basic.lean:134` | symmetrization; `Adj a b ↔ a ≠ b ∧ (r a b ∨ r b a)` |
| `SimpleGraph.fromRel_adj` | `Basic.lean:138` | `simp` form of the above |
| `SimpleGraph.IsAcyclic` | `SimpleGraph/Acyclic.lean:56` | `∀ ⦃v⦄ (c : G.Walk v v), ¬c.IsCycle` |
| `SimpleGraph.isAcyclic_iff_subsingleton_path` | `Acyclic.lean:189` | path uniqueness (**non-deprecated** form) |
| `SimpleGraph.IsAcyclic.subsingleton_path` | `Acyclic.lean:196` (alias) | `Subsingleton (G.Path u v)` |
| `SimpleGraph.IsAcyclic.eq_penultimate_of_adj_end` | `Acyclic.lean:217` | the (C1) induction step |
| `SimpleGraph.IsAcyclic.path_concat` | `Acyclic.lean:237` | available for the residual step |
| `SimpleGraph.Walk.IsPath.concat` | `SimpleGraph/Paths.lean:253` | extend a path by one edge |
| `SimpleGraph.Walk.isPath_iff_nil` | `Paths.lean:206` (via rename) | closed path is nil |
| `SimpleGraph.Walk.penultimate_concat` | `Walk/Operations.lean:656` | last-step bookkeeping |
| `SimpleGraph.Walk.length_concat` | `Walk/Operations.lean:232` | length bookkeeping |
| `SimpleGraph.Walk.getVert_append` | `Walk/Operations.lean:245` | residual step's index arithmetic |
| `SimpleGraph.Walk.eq_of_length_eq_zero` | `Walk/Basic.lean:98` | nil-case handling |
| `SimpleGraph.Walk.length_eq_zero_iff` | (renamed from `nil_iff_length_eq`) | nil-case handling |
| `SimpleGraph.Walk.support_concat` | `Walk/Operations.lean` (`support_concat`) | the between-clause induction |

**Deprecation hazard, recorded explicitly.** At this pin `isAcyclic_iff_path_unique` and
`IsAcyclic.path_unique` are marked `@[deprecated ... (since := "2026-06-30")]` in favour of
`isAcyclic_iff_subsingleton_path` / `IsAcyclic.subsingleton_path`, and `Walk.isPath_iff_eq_nil`
/ `Walk.nil_iff_length_eq` are deprecated in favour of `Walk.isPath_iff_nil` /
`Walk.length_eq_zero_iff` **with a changed statement** (`p.Nil` in place of `p = nil`, and the
iff reversed). The prototype hit both and was corrected; an implementation that reaches for the
first name it recalls will produce deprecation warnings and, in the second case, a type error.

### The mathematics, restated at the hypothesis the amendment pins

Over a bare one-step relation `E : W → W → Prop`:

```lean
structure IsOrientedForest (E : W → W → Prop) : Prop where
  loopFree : ∀ u, ¬ E u u
  oppFree  : ∀ u v, E u v → ¬ E v u
  acyclic  : (SimpleGraph.fromRel E).IsAcyclic
```

The decomposition the five-step argument actually needs, in the order the prototype proves it:

1. **(C1)** every directed `E`-walk is an undirected *path*, with its penultimate vertex
   carrying the last `E`-step, and every vertex of that path splits the walk
   (`∀ d ∈ p.support, ∃ i ≤ n, iter E i a d ∧ iter E (n-i) d z`) — `exists_isPath_of_iter`;
2. **(UPL)** a directed walk's length is determined by its endpoints — `iter_length_unique`;
3. no directed cycles — `not_iter_self`;
4. **(PEN)** the penultimate vertex of a directed walk of fixed length is determined —
   `pen_unique`;
5. **(UIV)** the intermediate vertex at a fixed distance is determined — `mid_unique`. **This
   is the segment-subsingleton fact**, i.e. steps 1 and 3 of the paper argument at once: a
   segment `Fib R w x ∩ Fib R v (-y)` is `{u | iter E x w u ∧ iter E y u v}`, and `mid_unique`
   says such a `u` is unique;
6. **(MERGE)** two directed walks into a common target factor through a last divergence point —
   `exists_merge`, a four-line induction comparing penultimates;
7. **(DISJ)** at a *divergent* merge point the two approach walks share no vertex but the merge
   point — `meet_approach_disjoint`.

Items 1-7 are **compiled** in `prototype/oriented-forest-core.lean` (200 lines + axiom probes).
Measured axiom profile of all five headline lemmas: `[propext, Classical.choice, Quot.sound]` —
the same profile `saturation_of_finite` already carries, so this lemma introduces no new axiom
cost at any consumer. (`Classical.choice` enters through `pathOf`'s `Exists.choose` and the
`by_cases` in `exists_merge`; a choice-free variant is conceivable by returning a `Σ`-type but
is not worth pursuing, and the existing `ofStep` route is already classical.)

### How the compiled layer reduces the Saturation goal

With 1-7 in hand the `Saturation` proof is short, and only one piece is missing. Derived:

- **Reduction A (singleton member).** If any member of the directed family is a nonempty
  subsingleton `{b}`, then `sInter_nonempty_of_directed_of_minimal` closes the goal immediately
  with `Sstar = {b}`: a member `T ⊆ {b}` is nonempty, hence `= {b}`, hence `{b} ⊆ T`. No forest
  input at all.
- **Reduction B (segments and zero-duration fibres gone).** Every segment is a subsingleton by
  `mid_unique`, and `Fib (ofStepRel E) a 0 = {a}`; so by Reduction A we may assume every member
  is a fibre of nonzero duration.
- **Reduction C (mixed signs gone).** If members of both signs occur, directedness supplies a
  member inside `Fib R a n ∩ Fib R a' (-m)`, which is a segment, hence a nonempty subsingleton;
  Reduction A applies. So we may assume all members are forward fibres (the all-backward case is
  the forward case for `E.swap`, which is an oriented forest whenever `E` is — the three fields
  are symmetric in `E`/`E.swap` by inspection). This is paper step 3 without its "two directed
  paths" argument, which `mid_unique` has already absorbed.
- **Step 4 (the remaining work).** Let `r_m = min {n | ∃ a, Fib R a n ∈ S}` — the minimum over
  **all representations** of **all** members, which is what makes the argument correct;
  minimising over one chosen representation per member is wrong, and a concrete
  counterexample to that weaker reading is recorded in Risks below. With witness `a_m`, set
  `F_m = Fib R a_m r_m`. For any member `F_i`, directedness gives a member
  `F' = Fib R a' n' ⊆ F_m ∩ F_i` with `F'` nonempty; pick `x ∈ F'` and apply `exists_merge` to
  the two walks `a_m → x` (length `r_m`) and `a' → x` (length `n'`), obtaining `c, k, l, j` with
  `k + j = r_m`, `l + j = n'`. Then:
  - `Fib R c j ⊆ F'` is immediate (`a' → c → ·` composes, `iter_add`) — **no new input needed**;
  - `F' ⊆ Fib R c j` is the **independence claim**: every `y ∈ F'` must also be at distance `j`
    from the *same* `c`. This is the residual step.
  Given both, `(c, j)` is a representation of the member `F'` with duration `j = r_m - k`, so
  minimality forces `k = 0`, hence `c = a_m` and `F' = F_m`, hence `F_m = F' ⊆ F_i`. `F_m` is
  then `⊆`-least and `sInter_nonempty_of_directed_of_minimal` finishes.

### The residual step, and why it needs undirected acyclicity

**Finding (derived, with a witness).** The independence claim is *not* a consequence of
directed-path uniqueness. Witness: the four-node digraph `a → c`, `b → c`, `a → y`, `b → y`.
Between any two of its nodes there is at most one directed path (and no directed path at all
between `c` and `y`), so it satisfies directed-path uniqueness; yet it has **two distinct
divergent merge points** for the pair `(a, b)`, namely `c` and `y`, so the merge vertex is not a
function of `(a, b)`. Its underlying undirected multigraph is a 4-cycle, so `IsOrientedForest`
excludes it. This is an independent, mechanical confirmation of task 884's consumption map
(steps 1-3 consume directed-path uniqueness, **step 4 consumes undirected acyclicity**) — it was
measured here, not carried over.

**Route for the residual step (derived; all ingredients named and verified to exist).**

1. For a divergent merge point `c` of `(a, b)` with approach lengths `k, l`, the concatenation
   `(a → c path).append (b → c path).reverse : Walk a b` is a **path**: a shared vertex `d`
   splits both approach walks by (C1)'s between-clause, and `meet_approach_disjoint` (already
   compiled) forces `d = c`; nodup of the concatenated support then follows from
   `Walk.support_append` plus `List.Nodup.append`.
2. Two divergent merge points `c, c'` of the same pair therefore give two paths `a → b`, which
   `IsAcyclic.subsingleton_path` identifies. Equal walks have equal length, so
   `k + l = k' + l'`; combined with `exists_merge`'s `k' + j' = k + j` and `l' + j' = l + j`
   this gives `2j' = 2j`, hence `j' = j`, `k' = k`, `l' = l`, and finally
   `c = W.getVert k = W.getVert k' = c'` via `Walk.getVert_append`.
3. Independence follows: apply `exists_merge` to `(a_m, a', y)` for each `y ∈ F'`, and step 2
   identifies its merge point with `c`.

No orientation/cocycle argument is needed — the length arithmetic in step 2 does the work that a
"which edges point forward" argument would otherwise have to do. This is the one place where the
`oppFree` field is *not* what rules the configuration out; `acyclic` is.

### Recommendations

1. **Encode the hypothesis as the three-field `IsOrientedForest` structure above.** It is
   recognisably "the underlying undirected multigraph is a forest", it assumes no forest data
   structure, it is stated over the bare one-step relation, and it is manifestly symmetric in
   `E`/`E.swap` (needed for Reduction C). Record in its docstring the amendment's
   multigraph-versus-simple-graph reason for the first two fields.
2. **Place it in a new `FormalSystem/Semantics/OrientedForest.lean`** importing
   `FormalSystem.Semantics.IntNormalForm` and `Mathlib.Combinatorics.SimpleGraph.Acyclic`, and
   add a one-line pointer to `TaskFrame.lean`'s `saturation_of_*` inventory block (lines 234-237)
   so the family stays discoverable from one place. Do **not** attempt to put it in
   `TaskFrame.lean`: `iter`/`ofStepRel` are downstream.
3. **Headline statement** (the shape both consumers want):
   `theorem saturation_of_orientedForest {W : Type} {E : W → W → Prop} (hF : IsOrientedForest E) : TaskFrame.Saturation (D := intOrder) (ofStepRel E)`,
   with the generic-`R` variant
   `theorem saturation_of_orientedForest' {R : W → ℤ → W → Prop} (hgen : ∀ (n : ℕ) w u, (R w n u ↔ iter E n w u) ∧ (R w (-(n:ℤ)) u ↔ iter E n u w)) ...`
   stated beside it for consumers whose relation is only *equal* to `ofStepRel E`, not
   definitionally it. `ofStepRel_of_nonneg`/`ofStepRel_of_nonpos` discharge `hgen` for
   `ofStepRel` itself.
4. **Promote the prototype wholesale.** The compiled prototype is written in the repository's own
   `iter` vocabulary with no shortcuts; the implementation should port items 1-7 verbatim (with
   `iter`/`iter_add` taken from `IntNormalForm` rather than re-defined) and then add only the
   residual step and the assembly.
5. **Phase the implementation as follows** (sizes are the prototype's measured sizes for the
   compiled parts, estimates for the rest):
   - Phase 1 (~70 lines, compiled): `IsOrientedForest`, `adj_of_step`,
     `not_mem_support_of_step`, `exists_isPath_of_iter` with the between-clause.
   - Phase 2 (~60 lines, compiled): `pathOf`/`pathOf_spec`, `walk_unique`,
     `iter_length_unique`, `not_iter_self`, `pen_unique`, `mid_unique`.
   - Phase 3 (~40 lines, compiled): `exists_merge`, `meet_approach_disjoint`.
   - Phase 4 (~150-250 lines, estimated): the concatenated-approach path and merge-point
     uniqueness (residual step 1-2 above).
   - Phase 5 (~120-180 lines, estimated): Reductions A/B/C and the duration-minimal selection,
     closing on `sInter_nonempty_of_directed_of_minimal`.
   - Phase 6 (~60 lines): instantiation at `ofStepRel`, the `hgen` variant, an axiom-profile
     test beside `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`, and the
     `README.md` / `docs/theorem-index.md` rows.
6. **Do not state the lemma at directed-path-uniqueness strength**, and do not weaken `acyclic`
   to acyclicity of a deduplicated graph without the `loopFree`/`oppFree` fields. The 4-cycle
   witness above is the concrete reason, and a lemma landed at the weaker hypothesis would not
   discharge hypothesis (H5) at either consumer.

## Decisions

- **Hypothesis encoding**: three-field `IsOrientedForest` over `SimpleGraph.fromRel`, rather than
  a bespoke reduced-closed-walk predicate over a signed-step list. Reason: the bespoke predicate
  is equally faithful but buys none of Mathlib's path-uniqueness API, and the whole residual
  step is an application of that API. Rejected on cost, not on correctness.
- **Not a Quiver encoding.** `Mathlib/Combinatorics/Quiver/{Path,Symmetric,Covering}.lean` exists
  at this pin and `Quiver.Symmetrify` is exactly the right multigraph convention, but Quiver
  carries no forest/acyclicity notion and no path-uniqueness theorem, so it would mean building
  the tree theory from scratch. Recorded because it is the natural second guess and because
  `Quiver.Covering` may well be the right tool for the *cover* construction (a different task).
- **Not `Mathlib/Combinatorics/Graph/`** (the general multigraph API, present at this pin as
  `Basic`/`Delete`/`Lattice`/`Maps`/`Subgraph`): it has no walk, path, or acyclicity layer yet.
- **Minimality is over all `(a, n)` with `Fib R a n ∈ S`**, not over one representation per
  member. This was checked against a concrete configuration (Risks below), not assumed.
- **The lemma is stated at `ofStepRel` over `intOrder`**, with a `hgen`-parameterised variant
  beside it, rather than at a `FrameOver` field. Reason: `TaskFrame.lean`'s own standing
  invariant is that `Saturation` must be the literal predicate a downstream proof consumes, and
  both consumers hold a bare relation, not a frame.
- **Module placement overrides the dispatch's suggested home**, for the import-direction reason
  given above. Flagged here rather than silently.

## Risks & Mitigations

- **Risk: the residual step is the only unverified piece, and it is the one with real
  bookkeeping** (`Walk.support_append` nodup, `getVert_append` index arithmetic). *Mitigation*:
  the route is fully specified above with every Mathlib name verified present, and
  `meet_approach_disjoint` — the part that looked most likely to need a new idea — is already
  compiled. If phase 4 stalls, the honest fallback is **not** a `sorry`: it is to mark phase 4
  `[BLOCKED]` and raise it, since phases 1-3 and 5-6 would still be green and the partial result
  (segments are subsingletons; merges exist) is itself reusable.
- **Risk: minimising duration over one representation per member is wrong, and the mistake is
  invisible.** *Measured counterexample*: forest `a → u → c`, `a' → c`, with `c` having two
  children and `a'` having a second child `d`. Then `Fib(a, 3) = Fib(c, 1) ⊊ Fib(a', 2)`, so the
  member `Fib(a, 3)` is *strictly smaller* than the member `Fib(a', 2)` although its chosen
  duration is larger; only the representation `(c, 1)` exposes it. *Mitigation*: state the
  minimum as `min {n | ∃ a, Fib R a n ∈ S}` and add this configuration as a test fixture.
- **Risk: `exists_merge`'s divergence disjunct is awkward to consume** (it carries `k = 0 ∨
  l = 0 ∨ ∃ u u' …` with `k-1`/`l-1` truncated subtraction). *Mitigation*: in the port, restate
  it with explicit predecessors (`k = kk + 1 ∧ l = ll + 1 ∧ …`) as
  `meet_approach_disjoint` already does; the prototype shows both forms work but the explicit
  one is what the consumer wants.
- **Risk: Mathlib deprecation drift** on the acyclicity API (two deprecations dated 2026-06-30
  are already live at this pin). *Mitigation*: the table above pins file:line for every name used;
  a future Mathlib bump should re-check that table rather than the lemma bodies.
- **Risk: consumer 1 (AA carrier) must discharge `IsOrientedForest` on the `inr` layer.**
  *Derived*: the `inr` layer has in-degree ≤ 1 (`h' = u :: h` determines the predecessor) and no
  directed cycles (list length strictly increases), and in-degree ≤ 1 plus no directed cycle
  implies the underlying undirected multigraph is a forest. A companion
  `isOrientedForest_of_inDegree_le_one` would make that discharge one line. Recommended as an
  optional phase-6 addition, **not** required by this task's scope.
- **Risk: consumer 2 (MSO cover) needs the cover to satisfy `IsOrientedForest`**, which is the
  universal-cover-is-a-tree theorem and is **not** in this task's scope. Recorded so that the
  cover task is not surprised: it will need acyclicity of a reduced-walk carrier, for which
  `Mathlib/Combinatorics/Quiver/Covering.lean` is the most promising starting point.

## Tactic Survey Results

Tactics were exercised directly against the compiling prototype rather than probed in the
abstract; the table records what the 200 lines actually needed.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `iter_add` (associativity of walk composition) | `induction` + `constructor`/`rintro` | success | no automation needed |
| nil-case of `exists_isPath_of_iter` | `simp` then explicit term | success | `Walk.support` simp set |
| length/index side goals throughout | `omega` | success | 9 occurrences, all discharged |
| `support_concat` membership split | `simpa [Walk.support_concat, List.concat_eq_append]` | success | `List.mem_append` via simp |
| nil-length extraction | `Walk.length_eq_zero_iff` + `omega` | success | deprecated predecessor fails to typecheck |
| penultimate transport across `walk_unique` | `congrArg Walk.penultimate` + `rwa` | success | `Walk.penultimate_concat` twice |
| `exists_merge` case split on penultimates | `by_cases hww : w = w'` | success | costs `Classical.choice` |
| whole file | `lake env lean` | success | 0 errors, 0 warnings, 0 `sorry` |

`aesop` and `decide` were not needed anywhere and were not used; `lean_hammer_premise` was not
consulted because the proof obligations were resolved by reading the pinned Mathlib source,
which is the stronger evidence tier.

## Context Extension Recommendations

- **Topic**: Mathlib `SimpleGraph` acyclicity/path-uniqueness API as used from `FormalSystem/`.
- **Gap**: `context/project/lean4/` has no note on this API, and the two deprecations at the
  current pin (`isAcyclic_iff_path_unique`, `Walk.isPath_iff_eq_nil`) are exactly the names a
  from-memory attempt reaches for. `Semantics/Correspondence/FwdRecPeriodicity.lean:49` records
  only the *negative* finding that `SimpleGraph.Walk` is unsuitable for bi-infinite histories,
  which could be misread as "SimpleGraph is not usable here".
- **Recommendation**: add `context/project/lean4/tools/mathlib-simplegraph-acyclic.md` carrying
  the verified-name table from this report plus the deprecation pairs, and cross-reference it
  from `FwdRecPeriodicity.lean`'s note so the negative finding is scoped to walks-as-histories
  rather than to the graph library as a whole.

## Appendix

**Prototype**: `specs/870_oriented_forest_saturation/prototype/oriented-forest-core.lean`
(200 lines plus five `#print axioms` probes). Compile command used:
`timeout 500 lake env lean specs/870_oriented_forest_saturation/prototype/oriented-forest-core.lean`
— exit 0, no diagnostics. Declarations landed: `iter`, `iter_zero`, `iter_succ`, `iter_add`,
`IsOrientedForest`, `adj_of_step`, `not_mem_support_of_step`, `exists_isPath_of_iter`, `pathOf`,
`pathOf_spec`, `walk_unique`, `iter_length_unique`, `not_iter_self`, `pen_unique`, `mid_unique`,
`exists_merge`, `meet_approach_disjoint`.

**Searches and reads performed**: grep over `FormalSystem/**` for `Saturation`,
`saturation_of_*`, `SimpleGraph`, `Acyclic`, `def Fib|Seg|DirectedFamily`, `ofStep*`, `iter`;
directory listing and targeted reads of `.lake/packages/mathlib/Mathlib/Combinatorics/`
(`SimpleGraph/`, `Graph/`, `Quiver/`); full read of `SimpleGraph/Acyclic.lean`'s declaration
list and of lines 196-300 and 560-600; targeted greps for `fromRel`, `penultimate`,
`getVert_append`, `IsPath.concat`, `isPath_iff_eq_nil`, `eq_of_length_eq_zero`. `lean-lsp` MCP
search tools were not needed: the pinned Mathlib source is on disk and reading it is a stronger
evidence tier than an index lookup, and no rate-limited call was spent.

**Report 03 section 1.2 step map, as consumed here**: step 1 → `mid_unique`; step 2 →
Reduction A; step 3 → `mid_unique` + Reduction C; step 4 → `exists_merge` +
`meet_approach_disjoint` + the residual merge-uniqueness step + duration-minimal selection;
step 5 → `sInter_nonempty_of_directed_of_minimal` (already compiled, axiom-free).
