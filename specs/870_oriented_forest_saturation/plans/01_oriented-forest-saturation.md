# Implementation Plan: Task #870

- **Task**: 870 - Oriented-forest Saturation lemma for TaskFrame
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: 884 (the report 03 section 1.2 amendment that pins the hypothesis strength; its
  consumption map is what fixes `acyclic` as a field rather than directed-path uniqueness alone)
- **Research Inputs**: `specs/870_oriented_forest_saturation/reports/01_oriented-forest-saturation.md`
  (plus its compiled companion `specs/870_oriented_forest_saturation/prototype/oriented-forest-core.lean`)
- **Artifacts**: plans/01_oriented-forest-saturation.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/context/standards/artifact-management.md`
  - `.claude/context/formats/tasks.md`
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land `saturation_of_orientedForest`: every relation whose underlying undirected multigraph is a
forest satisfies the literal `TaskFrame.Saturation` predicate at `ofStepRel` over `ℤ`. The
research dispatch already compiled seven of the nine mathematical ingredients as a standalone
prototype, so phases 1-3 are a faithful port into a new `FormalSystem/Semantics/OrientedForest.lean`
in the repository's own `iter` vocabulary, phases 4-5 add the one residual step (merge-point
uniqueness, the only place undirected acyclicity is genuinely consumed), phases 6-7 assemble the
`Saturation` goal through the already-compiled, axiom-free
`TaskFrame.sInter_nonempty_of_directed_of_minimal`, and phase 8 lands the evidence module, the
documentation rows, and the full gate. Definition of done: both headline theorems compile
sorry-free at the signatures pinned under `## Lean Challenge Statements`, with a measured axiom
profile no worse than `[propext, Classical.choice, Quot.sound]`.

### Research Integration

Findings carried in from the research report and acted on here:

- **Hypothesis encoding is fixed** as the three-field `IsOrientedForest` structure over
  `SimpleGraph.fromRel E` (`loopFree`, `oppFree`, `acyclic`). The first two fields are what make
  the predicate a statement about the undirected **multigraph** rather than about `fromRel`'s
  deduplicated simple graph, and they make the predicate manifestly symmetric in `E`/`E.swap`,
  which phase 6's Reduction C needs.
- **Module placement overrides the dispatch's suggested home.** `iter` and `ofStepRel` live in
  `FormalSystem/Semantics/IntNormalForm.lean`, which imports `TaskFrame.lean`; the lemma cannot
  be stated beside `saturation_of_fib_finite`. A new `Semantics/OrientedForest.lean` importing
  `IntNormalForm` plus `Mathlib.Combinatorics.SimpleGraph.Acyclic` is the home, with a pointer
  added to `TaskFrame.lean`'s `saturation_of_*` inventory block so the family stays discoverable
  from one place.
- **Steps 1-3 and 5 of report 03 section 1.2 are already discharged by the prototype**
  (`mid_unique` is the segment-subsingleton fact; `sInter_nonempty_of_directed_of_minimal` is
  step 5 and is axiom-free). The residual work is step 4's independence claim.
- **The residual step needs undirected acyclicity, measured not recalled.** The 4-node digraph
  `a → c`, `b → c`, `a → y`, `b → y` has directed-path uniqueness and two distinct divergent
  merge points for `(a, b)`; its underlying undirected multigraph is a 4-cycle, which
  `IsOrientedForest` excludes. The route through `IsAcyclic.subsingleton_path` plus length
  arithmetic is specified in full in the report and is reproduced as phases 4-5 here.
- **Two Mathlib deprecation pairs at this pin are live traps**: use
  `isAcyclic_iff_subsingleton_path` / `IsAcyclic.subsingleton_path` (not
  `isAcyclic_iff_path_unique` / `IsAcyclic.path_unique`) and `Walk.isPath_iff_nil` /
  `Walk.length_eq_zero_iff` (not `Walk.isPath_iff_eq_nil` / `Walk.nil_iff_length_eq`, whose
  statements also changed shape). The report's verified-name table is the authority; it pins
  `file:line` for every Mathlib name this plan relies on.
- **Minimality must range over all representations.** The duration minimum in phase 7 is
  `min {n | ∃ a, Fib R a n ∈ S}`, not a minimum over one chosen representation per member; the
  report records a measured configuration where the chosen-representation reading is wrong and
  the mistake is invisible.

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

`specs/ROADMAP.md` names this task in three places, all consistent with this plan's scope:

- The ZTime decidability paper theorem is conditional on **(H5)** — "task 870's oriented-forest
  Saturation lemma and universal-cover construction". This plan lands the Saturation half only;
  the universal-cover construction is explicitly a Non-Goal and stays with the cover task.
- The run-order lines (`/orchestrate 870,871`) record that the lemma must be stated at
  oriented-forest strength, "not directed-path uniqueness alone (report 03 §1.2 note; 878
  decision 7)". This plan's `IsOrientedForest` is exactly that strength and the plan refuses the
  weaker statement.
- "**R3, the doubled AA⊡ rule, is gated on 870** ... The Auxiliary-Atoms carrier's *Saturation*
  obligation is what stops it today, and 870 supplies it." This plan supplies the general lemma;
  discharging `IsOrientedForest` on the AA carrier's `inr` layer belongs to the consumer.

ROADMAP.md is read-only for this plan and is not modified by any phase.

## Goals & Non-Goals

**Goals**:

- `IsOrientedForest` -- the three-field hypothesis predicate over a bare one-step relation: the
  underlying undirected multigraph of `E` is a forest, with no forest data structure assumed.
- `exists_isPath_of_iter` -- (C1) every directed `E`-walk of length `n` is an undirected path
  whose penultimate vertex carries the last `E`-step, and every vertex of that path splits the
  walk.
- `iter_length_unique` -- (UPL) a directed walk's length is determined by its endpoints.
- `not_iter_self` -- no directed cycles.
- `pen_unique` -- (PEN) the penultimate vertex of a directed walk of fixed length is determined.
- `mid_unique` -- (UIV) the intermediate vertex at a fixed distance is determined; this is the
  segment-subsingleton fact, i.e. report 03 section 1.2 steps 1 and 3 at once.
- `exists_merge` -- (MERGE) two directed walks into a common target factor through a last
  divergence point, with the divergence disjunct carried at explicit predecessors.
- `meet_approach_disjoint` -- (DISJ) at a divergent merge point the two approach walks share no
  vertex but the merge point.
- `merge_unique` -- the residual step: a divergent merge point of a pair with a common target,
  together with its three length parameters, is unique. The one declaration that consumes
  `acyclic` rather than directed-path uniqueness.
- `saturation_of_orientedForest` -- the headline result: `TaskFrame.Saturation (ofStepRel E)`
  from `IsOrientedForest E` alone.
- `saturation_of_orientedForest'` -- the `hgen`-parameterised variant for a consumer holding a
  relation only *equal* to `ofStepRel E`, not definitionally it.

**Non-Goals**:

- The universal-cover construction (the other half of ROADMAP (H5)). It needs acyclicity of a
  reduced-walk carrier and belongs to the cover task; `Mathlib/Combinatorics/Quiver/Covering.lean`
  is the recorded starting point.
- Discharging `IsOrientedForest` at either consumer. Neither
  `isOrientedForest_of_inDegree_le_one` (which would make the AA carrier's `inr`-layer discharge
  one line, and which is a real undirected-acyclicity proof, not a one-liner) nor any cover-side
  acyclicity lemma is landed here.
- Any statement at directed-path-uniqueness strength, and any weakening of `acyclic` to
  acyclicity of a deduplicated graph without `loopFree`/`oppFree`. The 4-cycle witness is the
  reason; a lemma at the weaker hypothesis would not discharge (H5) at either consumer.
- `SeparationOver`, Rabin's theorem, MSO, and the ladder/`RaySummary` files held by other
  in-flight tasks. Nothing under `FormalSystem/Metalogic/**` is touched.
- Any change to `FrameOver.ofStep`'s existing `saturation` field, which keeps routing through
  `saturation_of_finite`. Rewiring it is a separate decision with its own blast radius.
- A `Classical.choice`-free variant. `pathOf`'s `Exists.choose` and the `by_cases` in
  `exists_merge` make the profile classical, matching `saturation_of_finite`'s existing profile;
  `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` already records why that hunt
  cannot succeed for this family.

## Lean Challenge Statements

These fix the intended statement of each committed declaration before implementation. Binder
order, implicit/explicit binder choice and namespace openings may be adjusted at implementation
time to make the block elaborate; the quantifier structure and the conclusion of each statement
may not be weakened (see `.claude/rules/plan-compliance.md`, *Statement Fidelity*).

```lean
import Mathlib.Combinatorics.SimpleGraph.Acyclic
import FormalSystem.Semantics.IntNormalForm

namespace FormalSystem.Semantics

/-- The underlying undirected **multigraph** of the one-step relation `E` is a forest. The three
fields are "no undirected 1-cycle", "no undirected 2-cycle", and "no undirected cycle of length
at least 3": `SimpleGraph.fromRel` deduplicates parallel edges, so `loopFree` and `oppFree` are
precisely what that deduplication would otherwise readmit. No forest data structure is assumed,
and the predicate is symmetric in `E`/`E.swap` by inspection. -/
structure IsOrientedForest {W : Type} (E : W → W → Prop) : Prop where
  loopFree : ∀ u, ¬ E u u
  oppFree : ∀ u v, E u v → ¬ E v u
  acyclic : (SimpleGraph.fromRel E).IsAcyclic

theorem exists_isPath_of_iter {W : Type} {E : W → W → Prop} (hF : IsOrientedForest E) :
    ∀ (n : ℕ) (a z : W), iter E n a z →
      ∃ p : (SimpleGraph.fromRel E).Walk a z,
        p.IsPath ∧ p.length = n ∧ (0 < n → E p.penultimate z) ∧
        (∀ d ∈ p.support, ∃ i, i ≤ n ∧ iter E i a d ∧ iter E (n - i) d z) := sorry

theorem iter_length_unique {W : Type} {E : W → W → Prop} (hF : IsOrientedForest E) {n m : ℕ}
    {a z : W} (hn : iter E n a z) (hm : iter E m a z) : n = m := sorry

theorem not_iter_self {W : Type} {E : W → W → Prop} (hF : IsOrientedForest E) {s : ℕ}
    (hs : 0 < s) (d : W) : ¬ iter E s d d := sorry

theorem pen_unique {W : Type} {E : W → W → Prop} (hF : IsOrientedForest E) {n : ℕ}
    {a z w w' : W} (hw : iter E n a w) (hEw : E w z) (hw' : iter E n a w') (hEw' : E w' z) :
    w = w' := sorry

theorem mid_unique {W : Type} {E : W → W → Prop} (hF : IsOrientedForest E) :
    ∀ (j k : ℕ) (a z v v' : W), iter E k a v → iter E j v z → iter E k a v' → iter E j v' z →
      v = v' := sorry

theorem exists_merge {W : Type} {E : W → W → Prop} :
    ∀ (n m : ℕ) (a b z : W), iter E n a z → iter E m b z →
      ∃ (c : W) (k l j : ℕ), iter E k a c ∧ iter E l b c ∧ iter E j c z ∧
        k + j = n ∧ l + j = m ∧
        (k = 0 ∨ l = 0 ∨ ∃ (kk ll : ℕ) (u u' : W), k = kk + 1 ∧ l = ll + 1 ∧
          u ≠ u' ∧ E u c ∧ E u' c ∧ iter E kk a u ∧ iter E ll b u') := sorry

theorem meet_approach_disjoint {W : Type} {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b c d u u' : W} {kk ll i j i' j' : ℕ}
    (hu : iter E kk a u) (hEu : E u c) (hu' : iter E ll b u') (hEu' : E u' c) (hne : u ≠ u')
    (h1 : iter E i a d) (h2 : iter E j d c) (hk : i + j = kk + 1)
    (h3 : iter E i' b d) (h4 : iter E j' d c) (hl : i' + j' = ll + 1) : d = c := sorry

theorem merge_unique {W : Type} {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b z c c' u₁ u₂ u₁' u₂' : W} {k l j k' l' j' : ℕ}
    (hu₁ : iter E k a u₁) (hE₁ : E u₁ c) (hu₂ : iter E l b u₂) (hE₂ : E u₂ c) (hne : u₁ ≠ u₂)
    (hcz : iter E j c z)
    (hu₁' : iter E k' a u₁') (hE₁' : E u₁' c') (hu₂' : iter E l' b u₂') (hE₂' : E u₂' c')
    (hne' : u₁' ≠ u₂') (hc'z : iter E j' c' z) :
    c = c' ∧ k = k' ∧ l = l' ∧ j = j' := sorry

theorem saturation_of_orientedForest {W : Type} {E : W → W → Prop}
    (hF : IsOrientedForest E) : TaskFrame.Saturation (ofStepRel E) := sorry

theorem saturation_of_orientedForest' {W : Type} {E : W → W → Prop} {R : W → ℤ → W → Prop}
    (hF : IsOrientedForest E)
    (hgen : ∀ (n : ℕ) (w u : W),
      (R w (n : ℤ) u ↔ iter E n w u) ∧ (R w (-(n : ℤ)) u ↔ iter E n u w)) :
    TaskFrame.Saturation R := sorry

end FormalSystem.Semantics
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 5 (`merge_unique`) is the only unverified ingredient and carries real bookkeeping (`Walk.support_append` nodup, `getVert_append` index arithmetic) | H | M | The route is specified step-by-step in the research report with every Mathlib name verified present at this pin, and `meet_approach_disjoint` — the part that looked most likely to need a new idea — is already compiled. If phase 5 stalls, the honest outcome is `[BLOCKED]` on that phase with phases 1-4 green and committed, **never** a `sorry` and never a weakened `merge_unique` |
| Minimising duration over one representation per member is wrong and the mistake is invisible | H | M | Phase 7 states the minimum as `min {n | ∃ a, Fib R a n ∈ S}` over all representations of all members, and phase 8 lands the report's measured configuration (`a → u → c`, `a' → c`, `c` with two children, `a'` with a second child `d`, where `Fib(a,3) = Fib(c,1) ⊊ Fib(a',2)`) as a test fixture so the weaker reading cannot be reintroduced silently |
| Mathlib deprecation drift on the acyclicity API (two pairs already deprecated at this pin) | M | H | Phase 1 records the verified-name table in the module docstring with the deprecation pairs named; the implementer reaches for `isAcyclic_iff_subsingleton_path` and `Walk.isPath_iff_nil`, never the first name memory supplies. A future Mathlib bump re-checks that table rather than the lemma bodies |
| `exists_merge`'s divergence disjunct is awkward to consume with truncated subtraction | M | H | The ported statement carries explicit predecessors (`k = kk + 1 ∧ l = ll + 1`) as pinned in the Challenge block, which is the shape phases 5-7 actually consume; the prototype shows both forms work |
| New declarations enter the `FormalSystem.Semantics` namespace that downstream modules open, risking ambiguity at a distance | M | L | `iter` and `iter_add` are taken from `IntNormalForm` rather than redefined, so the new names are only the eleven committed identifiers plus five internal helpers; phase 1's `interface` tier builds the aggregator and phase 8's full unscoped `lake build` catches any resolution breakage repository-wide |
| Concurrent sibling tasks collide on file territory | L | L | Declared scope is one new `Semantics/` module plus six additive edits; task 867's scope is `Metalogic/Expressiveness/**` and the ladder/`RaySummary` files are untouched. The one documented invisible collision in ROADMAP.md (`Semantics/Presheaf.lean`'s import line) is not in this plan's scope |
| `pathOf` must be `noncomputable` (it uses `Exists.choose`) | L | H | This is sanctioned: `rules/lean4.md` prohibits a `noncomputable` **`Decidable`-valued** declaration, which `pathOf` is not. Phase 8's gate records the keyword's presence and its reason rather than treating it as a finding |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. This plan is fully sequential: every phase
but the first edits the same single new module and consumes the declarations the preceding phase
landed, so there is no parallelism to claim.

### Phase 1: Module skeleton, the hypothesis, and (C1) [COMPLETED]

**Goal**: `FormalSystem/Semantics/OrientedForest.lean` exists, is wired into the `Semantics`
aggregator, and carries `IsOrientedForest` plus the (C1) path-extraction lemma with its
between-clause.

**Tasks**:

- [x] Create `FormalSystem/Semantics/OrientedForest.lean` with the repository's Apache-2.0
      copyright header (matching `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`'s
      header shape) and imports `Mathlib.Combinatorics.SimpleGraph.Acyclic` and
      `FormalSystem.Semantics.IntNormalForm`.
- [x] Write the module docstring: what the module is for, the amendment's multigraph-versus-simple-graph
      reason for `loopFree`/`oppFree`, the verified Mathlib-name table from the research report,
      and the two deprecation pairs named explicitly as traps.
- [x] Declare `IsOrientedForest` at the signature pinned in `## Lean Challenge Statements`, with
      the docstring above.
- [x] Land the internal helper `adj_of_step` (`E u v → (SimpleGraph.fromRel E).Adj u v`).
- [x] Land the internal helper `not_mem_support_of_step` (the step out of a directed path's
      endpoint cannot re-enter the path), via `IsAcyclic.eq_penultimate_of_adj_end` and the
      `loopFree`/`oppFree` fields.
- [x] Land `exists_isPath_of_iter` at the pinned signature, by induction on `n`, using
      `Walk.IsPath.concat`, `Walk.length_concat`, `Walk.penultimate_concat` and
      `Walk.support_concat`. Take `iter`, `iter_zero`, `iter_succ` and `iter_add` from
      `IntNormalForm` — do not redefine any of them.
- [x] Add `import FormalSystem.Semantics.OrientedForest` to `FormalSystem/Semantics.lean`, placed
      after `IntNormalForm` so the import block stays topologically ordered.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: The phase adds declarations to the `FormalSystem.Semantics` namespace and
one import line to the aggregator every downstream module reads, so the covering check is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest FormalSystem.Semantics`
— the new module plus its one enumerated direct dependent; repository-wide resolution is phase 8's.

**Files to modify**:

- `FormalSystem/Semantics/OrientedForest.lean` - new module: header, docstring, `IsOrientedForest`, `adj_of_step`, `not_mem_support_of_step`, `exists_isPath_of_iter`
- `FormalSystem/Semantics.lean` - one added import line

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest FormalSystem.Semantics`
  exits 0, with no `sorry`, no error and no deprecation warning.
- `grep -c 'sorry' FormalSystem/Semantics/OrientedForest.lean` returns 0.
- `IsOrientedForest`'s three field names and types match the Challenge block character for
  character.
- No vacuous definition pattern (`:= True`, `:= trivial`, `:= Unit`) appears in the new file.

---

### Phase 2: The path-uniqueness layer [COMPLETED]

**Goal**: the four consequences of forest path uniqueness that everything downstream consumes,
including the segment-subsingleton fact.

**Tasks**:

- [x] Land the internal `noncomputable def pathOf` and `pathOf_spec` (the chosen path realizing a
      directed walk, with its length, last-step and between-clause data) off
      `exists_isPath_of_iter`.
- [x] Land the internal `walk_unique` via `IsAcyclic.subsingleton_path` — **not** the deprecated
      `IsAcyclic.path_unique`.
- [x] Land `iter_length_unique` at the pinned signature.
- [x] Land `not_iter_self` at the pinned signature, using `Walk.isPath_iff_nil` and
      `Walk.length_eq_zero_iff` — **not** the deprecated `Walk.isPath_iff_eq_nil` /
      `Walk.nil_iff_length_eq`, whose statements also changed shape at this pin.
- [x] Land `pen_unique` at the pinned signature (concatenate both paths with the shared last step
      and transport `Walk.penultimate` across `walk_unique`).
- [x] Land `mid_unique` at the pinned signature, by induction on `j` through `pen_unique`.
- [x] Record in the module docstring that `mid_unique` *is* the segment-subsingleton fact, i.e.
      report 03 section 1.2 steps 1 and 3, so a later reader does not look for a separate lemma.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: Every declaration is new and confined to `OrientedForest.lean` with no
externally visible signature changed, so the covering check is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`.

**Files to modify**:

- `FormalSystem/Semantics/OrientedForest.lean` - `pathOf`, `pathOf_spec`, `walk_unique`, `iter_length_unique`, `not_iter_self`, `pen_unique`, `mid_unique`

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`
  exits 0, zero `sorry`, zero deprecation warnings.
- `grep -n 'path_unique\|isPath_iff_eq_nil\|nil_iff_length_eq' FormalSystem/Semantics/OrientedForest.lean`
  returns nothing (the deprecated names are absent).
- The four pinned signatures (`iter_length_unique`, `not_iter_self`, `pen_unique`, `mid_unique`)
  match the Challenge block; no hypothesis added, no quantifier specialised.
- `pathOf` is the only `noncomputable` declaration, and it is not `Decidable`-valued.

---

### Phase 3: The merge layer [COMPLETED]

**Goal**: merges exist, and at a divergent merge the two approach walks are disjoint apart from
the merge point.

**Tasks**:

- [x] Land `exists_merge` at the pinned signature, by induction on `n` with an inner match on `m`
      and a `by_cases` on the two penultimates. Carry the divergence disjunct at **explicit
      predecessors** (`k = kk + 1 ∧ l = ll + 1`), not with truncated subtraction.
- [x] Land `meet_approach_disjoint` at the pinned signature, consuming only `pen_unique` and
      `iter_length_unique`.
- [x] Record in the docstrings that `exists_merge` needs no `IsOrientedForest` hypothesis at all
      (it is pure), and that `meet_approach_disjoint` consumes only directed-path uniqueness —
      so a reader can see exactly where `acyclic` first becomes load-bearing (phase 5).

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: Two new declarations confined to `OrientedForest.lean` with no externally
visible signature changed, covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`.

**Files to modify**:

- `FormalSystem/Semantics/OrientedForest.lean` - `exists_merge`, `meet_approach_disjoint`

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`
  exits 0, zero `sorry`.
- `exists_merge`'s divergence disjunct reads with explicit predecessors, matching the Challenge
  block; it takes no `IsOrientedForest` argument.
- `meet_approach_disjoint` matches its pinned signature.

---

### Phase 4: The concatenated approach walk is a path [COMPLETED]

**Goal**: the internal lemma that turns a divergent merge point into a genuine undirected path
between the two sources — the one new construction phase 5 needs.

**Tasks**:

- [x] State the internal helper `approach_concat_isPath`: for a divergent merge point `c` of
      `(a, b)` with approach lengths `kk + 1` and `ll + 1`, the walk
      `(pathOf … : Walk a c).append (pathOf … : Walk b c).reverse : Walk a b` is a path.
- [x] Prove the support-disjointness side condition: a shared vertex `d` of the two approach
      walks splits both by `exists_isPath_of_iter`'s between-clause, and `meet_approach_disjoint`
      forces `d = c`.
- [x] Discharge nodup of the concatenated support from `Walk.support_append` plus
      `List.Nodup.append` and the previous step.
- [x] Record the walk's length (`(kk + 1) + (ll + 1)`) and the index of `c` along it as separate
      named facts, so phase 5's `Walk.getVert_append` arithmetic has them to hand rather than
      re-deriving them inside a larger proof.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: One internal helper plus its two bookkeeping facts, all confined to
`OrientedForest.lean` with nothing externally visible changed, covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`.

**Files to modify**:

- `FormalSystem/Semantics/OrientedForest.lean` - `approach_concat_isPath` and its length/index bookkeeping facts

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`
  exits 0, zero `sorry`.
- The nodup argument routes through `meet_approach_disjoint` rather than through any new
  acyclicity appeal, confirming the layering the phase-3 docstrings record.
- The length and index facts are named declarations, not `have`s buried inside a larger proof.

---

### Phase 5: Merge-point uniqueness [COMPLETED]

**Goal**: `merge_unique` — the residual step, and the only place undirected acyclicity is
genuinely consumed.

**Tasks**:

- [x] Land `merge_unique` at the pinned signature: two divergent merge points `c`, `c'` of the
      same pair with a common target give two paths `a → b` by `approach_concat_isPath`, which
      `IsAcyclic.subsingleton_path` identifies.
- [x] Derive the length arithmetic: equal walks have equal length, so `k + l = k' + l'`; combined
      with the common target's `iter_length_unique` facts this yields `j = j'`, `k = k'`,
      `l = l'`.
- [x] Derive `c = c'` from the identified walk via `Walk.getVert_append` at the recorded index. *(deviation: altered — `c = c'` is closed by transferring `c'`'s support membership across the identified walk (`Walk.mem_support_append_iff`) and then applying `meet_approach_disjoint`, not by `getVert_append` index arithmetic. Reason: phase 7's independence step compares merges at two DIFFERENT targets (`x` and `y`), so it needs a target-free merge-point uniqueness; the plan's `getVert` route derives `k = k'` from the common-target length arithmetic and so cannot supply the target-free form. The pinned `merge_unique` signature is still landed, derived from the stronger target-free `mergePoint_unique`, and `approach_concat_getVert` records the index as the plan asks.)*
- [x] Record in the docstring that this is the one declaration in the module whose proof consumes
      `acyclic` rather than `loopFree`/`oppFree`, and name the 4-node witness (`a → c`, `b → c`,
      `a → y`, `b → y`: directed-path uniqueness holds, two distinct divergent merge points, a
      4-cycle underlying) as the reason the hypothesis cannot be weakened.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: One new declaration confined to `OrientedForest.lean` with no externally
visible signature changed, covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`.

**Files to modify**:

- `FormalSystem/Semantics/OrientedForest.lean` - `merge_unique`

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`
  exits 0, zero `sorry`.
- `merge_unique` matches its pinned signature: all four conjuncts of the conclusion present, no
  hypothesis added beyond those pinned.
- The proof cites `IsAcyclic.subsingleton_path` (directly or through `walk_unique`), confirming
  the claim that `acyclic` is load-bearing here.
- If the phase cannot be completed as written: mark it `[BLOCKED]`, record the goal state reached
  and what is missing, and stop. Do **not** introduce a `sorry`, a vacuous definition, or a
  weakened `merge_unique`; phases 1-4 remain green and committed and the partial result
  (segments are subsingletons, merges exist) is itself reusable.

---

### Phase 6: Saturation reductions A, B and C [COMPLETED]

**Goal**: reduce the `Saturation` goal to the all-forward-fibres case, with the singleton-member
and segment cases closed outright.

**Tasks**:

- [x] Land the internal Reduction A: if any member of the directed family is a nonempty
      subsingleton, `TaskFrame.sInter_nonempty_of_directed_of_minimal` closes the goal with that
      member as `Sstar` (a member `T ⊆ {b}` is nonempty, hence `= {b}`). Consumes no forest
      input at all.
- [x] Land the segment-subsingleton bridge: a `TaskFrame.Seg (ofStepRel E) w v x y` with
      `0 ≤ x`, `0 ≤ y` unfolds to `{u | iter E x.natAbs w u ∧ iter E y.natAbs u v}` via
      `ofStepRel_of_nonneg`/`ofStepRel_of_nonpos`, and is a subsingleton by `mid_unique`.
- [x] Land Reduction B: with the bridge plus `Fib (ofStepRel E) a 0 = {a}`, Reduction A disposes
      of every segment member and every zero-duration fibre member, so the remaining case has all
      members fibres of nonzero duration.
- [x] Land Reduction C: if members of both signs occur, `DirectedFamily`'s witness inside
      `Fib R a n ∩ Fib R a' (-m)` is a segment, hence a nonempty subsingleton, and Reduction A
      applies; the all-backward case is the all-forward case for `E.swap`, which is an oriented
      forest whenever `E` is — prove `IsOrientedForest E → IsOrientedForest (flip E)` (or
      `Function.swap`) as its own named lemma rather than inlining the symmetry.
- [x] Record in the docstrings that Reduction C is report 03 section 1.2's step 3 **without** its
      "two directed paths" argument, which `mid_unique` has already absorbed.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: All new declarations confined to `OrientedForest.lean`, consuming
`TaskFrame.lean`'s existing API without editing it, covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`.

**Files to modify**:

- `FormalSystem/Semantics/OrientedForest.lean` - Reduction A, the segment-subsingleton bridge, Reduction B, Reduction C and the `E.swap` symmetry lemma

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`
  exits 0, zero `sorry`.
- Each of the three reductions and the symmetry lemma is a separately named declaration, per
  `.claude/rules/plan-compliance.md`'s decomposition requirement — none is inlined into phase 7's
  assembly.
- `TaskFrame.sInter_nonempty_of_directed_of_minimal` is consumed unchanged; no new family-level
  machinery is introduced and `TaskFrame.lean` is not edited.

---

### Phase 7: Duration-minimal selection and the headline theorems [COMPLETED]

**Goal**: `saturation_of_orientedForest` and `saturation_of_orientedForest'`, sorry-free.

**Tasks**:

- [x] Define the duration minimum as `min {n | ∃ a, Fib R a n ∈ S}` — over **all**
      representations of **all** members, never over one chosen representation per member — and
      obtain its witness `(a_m, r_m)` with `F_m = Fib R a_m r_m`.
- [x] For an arbitrary member `F_i`, take directedness' member `F' = Fib R a' n' ⊆ F_m ∩ F_i`,
      pick `x ∈ F'`, and apply `exists_merge` to the walks `a_m → x` (length `r_m`) and
      `a' → x` (length `n'`), obtaining `c, k, l, j` with `k + j = r_m` and `l + j = n'`.
- [x] Prove `Fib R c j ⊆ F'` by composition (`iter_add`); this direction needs no forest input.
- [x] Prove `F' ⊆ Fib R c j` — the independence claim — by applying `exists_merge` to
      `(a_m, a', y)` for each `y ∈ F'` and identifying its merge point with `c` via
      `merge_unique`.
- [x] Conclude: `(c, j)` represents `F'` with duration `j = r_m - k`, so minimality forces
      `k = 0`, hence `c = a_m` and `F' = F_m`, hence `F_m ⊆ F_i`; `F_m` is `⊆`-least and
      `TaskFrame.sInter_nonempty_of_directed_of_minimal` closes the goal.
- [x] Land `saturation_of_orientedForest` at the pinned signature.
- [x] Land `saturation_of_orientedForest'` at the pinned signature, and record in its docstring
      that `ofStepRel_of_nonneg`/`ofStepRel_of_nonpos` discharge `hgen` for `ofStepRel` itself, so
      the primed variant is for consumers whose relation is only *equal* to `ofStepRel E`.
- [x] Add the module docstring's step map: which declaration discharges which of report 03
      section 1.2's five steps.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Tier Justification**: Both headline theorems and the selection argument are new declarations
confined to `OrientedForest.lean` with no externally visible signature changed, covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`.

**Files to modify**:

- `FormalSystem/Semantics/OrientedForest.lean` - the duration-minimal selection, `saturation_of_orientedForest`, `saturation_of_orientedForest'`, and the step map in the module docstring

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.OrientedForest`
  exits 0, zero `sorry`, zero vacuous definitions.
- Both headline signatures match the Challenge block exactly: `TaskFrame.Saturation` is the
  literal predicate, not a restated or weakened variant, and `saturation_of_orientedForest` takes
  `IsOrientedForest E` as its only hypothesis.
- The minimum is visibly over `{n | ∃ a, Fib R a n ∈ S}`; a reviewer can read off that no
  per-member representation choice is made.
- `lean_verify FormalSystem.Semantics.saturation_of_orientedForest` reports an axiom profile no
  larger than `[propext, Classical.choice, Quot.sound]`.

---

### Phase 8: Evidence module, documentation rows, and the full gate [COMPLETED]

**Goal**: the result is discoverable, its axiom profile and its minimality trap are pinned by a
build-breaking test module, and the repository's complete gate set is green.

**Tasks**:

- [x] Create `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean` with the repository
      copyright header, modelled on `SaturationFiniteAxiomTest.lean`: `#guard_msgs`-gated
      `#print axioms` blocks for `saturation_of_orientedForest`,
      `saturation_of_orientedForest'`, `merge_unique`, `mid_unique` and `exists_merge`, so a
      profile change breaks the build.
- [x] Add to that module the research report's measured minimality fixture (the forest
      `a → u → c`, `a' → c`, with `c` having two children and `a'` a second child `d`, where
      `Fib(a,3) = Fib(c,1) ⊊ Fib(a',2)`) as a compiled witness that per-member-representation
      minimisation is wrong, with a docstring saying so.
- [x] Register the test module: `import BimodalTest.Semantics.OrientedForestSaturationTest` in
      `Tests/BimodalTest.lean`, and a row in `Tests/BimodalTest/Semantics/README.md`.
- [x] Add a one-line pointer to `TaskFrame.lean`'s `saturation_of_*` inventory block (the
      docstring list that currently ends at `saturation_of_fib_finite`) naming
      `Semantics.saturation_of_orientedForest` and its module, so the family stays discoverable
      from one place. Docstring prose only — no declaration in `TaskFrame.lean` is changed.
- [x] Add a row for `FormalSystem/Semantics/OrientedForest.lean` to
      `FormalSystem/Semantics/README.md` and refresh that file's "Last verified" date.
- [x] Add rows to `docs/theorem-index.md` for both headline theorems, matching the existing
      column shape (`Paper label | Statement | Lean name | File | Frame class | Axioms`) with
      fully qualified Lean names, no line numbers, and the axiom column written from the measured
      profile rather than typed from memory.
- [x] Run the repository's complete gate set and record its result.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts six touched files (the new test module plus five
additive edits) and five `#print axioms` blocks. *(Confirmed by `git status --short` before
committing: the six asserted files were all touched, plus four more this hypothesis did not
anticipate — `FormalSystem/Semantics/OrientedForest.lean` (two added `Paper:` docstring lines that
C15 requires before a `docs/theorem-index.md` row is accepted), the regenerated inventory blocks
in `FormalSystem/README.md` and `README.md`, and the regenerated
`scripts/lean-citation-manifest.json`; `typst/generated/status.typ` is regenerated at every phase.
Seven `#print axioms` blocks landed, not five, per this hypothesis's own instruction to pin
whatever declarations actually landed.)* Both are hypotheses: confirm the file count by
`git status --short` before committing, and confirm the block count against the declarations that
actually landed in phases 1-7 — if `merge_unique` was landed under a different internal
decomposition, pin whatever the committed declarations are rather than forcing the asserted five.
The axiom profiles themselves are measured in this phase, never carried: the research report's
`[propext, Classical.choice, Quot.sound]` reading is a prototype measurement, not a measurement
of the landed declarations.

**Files to modify**:

- `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean` - new evidence module: axiom-profile guards and the minimality fixture
- `Tests/BimodalTest.lean` - one added import line
- `Tests/BimodalTest/Semantics/README.md` - one added row
- `FormalSystem/Semantics/TaskFrame.lean` - one added docstring line in the `saturation_of_*` inventory block
- `FormalSystem/Semantics/README.md` - one added row plus the "Last verified" date
- `docs/theorem-index.md` - two added rows

**Verification**:

- The complete gate set has been run in this dispatch and observed:
  `bash .claude/scripts/verify-deploy.sh` green, plus `bash scripts/check-module-invariants.sh`,
  `bash scripts/check-metalogic-cycles.sh`, `bash scripts/readme-lint.sh` and
  `bash scripts/check-copyright-headers.sh --strict` green against their pre-task baselines, plus
  the guarded unscoped build
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` green. Each invocation's
  exit status is read directly, never inferred from a stdout diff, and every failure is attributed
  by path to a file inside or outside this plan's touched set.
- Zero `sorry` and zero vacuous definitions across every file this task changed.
- Every axiom profile pinned in the test module was measured in this same run.
- `pathOf` is the only `noncomputable` declaration added, and it is not `Decidable`-valued.
- `git log` confirms exactly this task's commits and that no foreign work was staged.

## Testing & Validation

- [x] All eleven declarations named under `- **Goals**:` compile sorry-free at exactly the
      signatures pinned in `## Lean Challenge Statements`.
- [x] `grep -rn 'sorry' FormalSystem/Semantics/OrientedForest.lean Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean`
      returns nothing.
- [x] No deprecated Mathlib name (`isAcyclic_iff_path_unique`, `IsAcyclic.path_unique`,
      `Walk.isPath_iff_eq_nil`, `Walk.nil_iff_length_eq`) appears anywhere in the new files, and
      the build reports zero deprecation warnings.
- [x] `saturation_of_orientedForest` concludes the literal `TaskFrame.Saturation` predicate, with
      `IsOrientedForest E` as its only hypothesis — no `[Finite W]`, no fibre-shape hypothesis,
      no directed-path-uniqueness restatement.
- [x] The duration minimum ranges over all `(a, n)` with `Fib R a n ∈ S`, and the test module's
      minimality fixture compiles as a witness that the per-member-representation reading is wrong.
- [x] `merge_unique`'s proof consumes `acyclic` (via `IsAcyclic.subsingleton_path`), and no
      declaration before it does.
- [x] Measured axiom profiles of both headline theorems are no larger than
      `[propext, Classical.choice, Quot.sound]`, matching `saturation_of_finite`'s existing
      profile, so the lemma adds no new axiom cost at either consumer.
- [x] `FrameOver.ofStep`'s `saturation` field is unchanged and still routes through
      `saturation_of_finite`.
- [x] Nothing under `FormalSystem/Metalogic/**`, no ladder/`RaySummary` file, and
      `specs/ROADMAP.md` are modified.
- [x] The complete gate set is green, with any pre-existing failure attributed by path and
      reported rather than baselined.

## Artifacts & Outputs

- `FormalSystem/Semantics/OrientedForest.lean` — the new module: `IsOrientedForest`, the five
  internal helpers (`adj_of_step`, `not_mem_support_of_step`, `pathOf`, `pathOf_spec`,
  `walk_unique`), the eight committed lemmas of the mathematical layer, the three reductions plus
  the `E.swap` symmetry lemma, and both headline theorems.
- `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean` — build-breaking axiom-profile
  guards plus the compiled minimality fixture.
- Additive edits: `FormalSystem/Semantics.lean` (import), `Tests/BimodalTest.lean` (import),
  `Tests/BimodalTest/Semantics/README.md` (row), `FormalSystem/Semantics/README.md` (row and
  date), `FormalSystem/Semantics/TaskFrame.lean` (one inventory docstring line),
  `docs/theorem-index.md` (two rows).
- A completion summary under `specs/870_oriented_forest_saturation/summaries/`.
- No change to `FrameOver.ofStep`, no change under `FormalSystem/Metalogic/**`, no `.typ` file,
  and no edit to `specs/ROADMAP.md`.

## Rollback/Contingency

The deliverable is one new module plus six additive edits, each phase committed on its own, so
rollback is per-phase and loses nothing else: `git revert` of the offending phase commit leaves
the earlier phases' compiled layer intact. Reverting phase 1 additionally removes the aggregator
import, which is the only edit any other module can observe.

If a phase cannot be completed as written, the sanctioned response is `[BLOCKED]` on that phase
with the goal state recorded — never a `sorry`, never a vacuous definition, and never a weakened
restatement of a pinned Challenge signature (see `.claude/rules/plan-compliance.md`'s *Statement
Fidelity* and escalation rules, which apply to every `.lean` file here). Phase 5 is the phase
most likely to need this; phases 1-4 and the partial result they establish (segments are
subsingletons, merges exist, divergent approaches are disjoint) are independently reusable at
both consumers and at the cover task.

No destructive git operation is anticipated. Should one become necessary, take the snapshot first
per `.claude/context/contracts/recovery.md`'s rollback rung rather than reverting the working tree
bare.
