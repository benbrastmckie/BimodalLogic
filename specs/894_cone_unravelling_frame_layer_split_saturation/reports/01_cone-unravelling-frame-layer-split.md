# Research Report: Task #894

**Task**: 894 - The forward-cone unravelling as a regular ZTime frame: inr-layer oriented forest and the two-layer Saturation split
**Started**: 2026-11-10T00:00:00Z
**Completed**: 2026-11-10T00:00:00Z
**Effort**: Medium-large (one new module, ~450-600 lines, 4 phases)
**Dependencies**: None (all prerequisites already landed)
**Sources/Inputs**:
- Codebase: `FormalSystem/Semantics/OrientedForest.lean`, `UniversalCover.lean`, `TaskFrame.lean`, `IntNormalForm.lean`, `HistoryMorphism.lean`, `ForMathlib/Combinatorics/SimpleGraphAcyclic.lean`, `Metalogic/NamingRules.lean`
- Compiled probe: `specs/evidence/cone-unravelling-frame-layer-split/cone-core-probe.lean` (written and verified during this dispatch)
- Literature corpus (searched; no in-corpus statement of Reynolds' *Auxiliary Atoms* rule — see Risks)
- lean-lsp MCP: not used (the compiled-probe route gave stronger evidence at lower cost)

**Artifacts**: - `specs/894_cone_unravelling_frame_layer_split_saturation/reports/01_cone-unravelling-frame-layer-split.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The design works, and it is now machine-checked rather than argued.** A single probe file,
  compiled against the pinned toolchain with zero errors and zero warnings, establishes the
  entire structural core: `IsOrientedForest (coneRin E)` on the inr layer, **double seriality of
  `coneR` on the literal sum carrier `W ⊕ (W × List W)` with no coherence subtype**, the
  projection homomorphism, four iter-level transport identities, the Fib-level transport bridge
  used by both halves of the Saturation split, and both `step`-direction lifts that
  `TwoWayBounded` needs.

- **The task description's promiscuous entry edge (`inl u → inr (v, h)` for *every* `h` when
  `u → v`) is load-bearing, not loose phrasing.** It is what makes the plain sum carrier doubly
  serial — under the narrower rule `h = [u]` the carrier contains incoherent nodes
  `inr (v, a :: t)` with `¬ E a v`, which have no predecessor at all, so `TaskFrame.Serial`
  fails and the carrier would have to be cut to a coherence subtype. The same promiscuity also
  collapses what would otherwise be a union over entry points into a single base fibre
  (`iter_inl_inr`, probed), which is exactly what the inl-anchored half of the Saturation split
  consumes, and it is what makes `TwoWayBounded.step` lift a base predecessor at an
  inr-anchored point. **Do not "tidy" the entry rule.**

- **The two-layer Saturation proof has a four-step shape, derived in full below and resting only
  on already-public lemmas.** Subsingleton-member reduction → split on `∃ s ∈ S, s ⊆ range inr`
  → inl-anchored half transports by `Sum.inl ⁻¹'` to the base's own *Saturation* → inr-anchored
  half uses a **cofinality** argument (directedness replaces the inr-contained member under any
  other member) and then `saturation_of_orientedForest` on `W × List W`. Mixed families are
  handled exactly as the task description says: by directedness.

- **Finding that narrows the statement: *Saturation* of `coneR` needs no seriality hypothesis.**
  Every nonemptiness obligation in the split is discharged by the projection homomorphism
  (`coneF_iter`) from the member's own nonemptiness, not from a seriality witness. Recommended
  signature: `saturation_coneR (hbase : TaskFrame.Saturation (ofStepRel E)) : TaskFrame.Saturation (ofStepRel (coneR E))`.
  Seriality is still needed, separately, for `FrameOver.ofStepSat`'s two seriality fields.

- **Recommended approach**: a new `FormalSystem/Semantics/ConeUnravelling.lean` modelled
  declaration-for-declaration on `UniversalCover.lean`, which is the proven template for every
  frame-assembly and `TwoWayBounded` step. A sorry-free path exists and is specified below; no
  step in it is open.

## Context & Scope

Researched: how to land the Auxiliary-Atoms carrier `W ⊕ (W × List W)` with the one-step
relation `coneR` as a regular `FrameOver intOrder`, and what the three required lemmas cost.
Constraints: zero-debt (no `sorry`, no new axiom), the carrier must be the literal sum type, and
the *Saturation* obligation must be the literal `TaskFrame.Saturation` predicate recorded in
`FormalSystem/Metalogic/NamingRules.lean`'s module docstring.

Out of scope and deliberately untouched: the formula-level Auxiliary-Atoms rule (this task is
the frame-side prerequisite only), any completeness or decidability claim, and any change to
`UniversalCover.lean` (which solves a *different* problem — see "Why not reuse the universal
cover").

## Findings

### Codebase Patterns

**`UniversalCover.lean` is the template and it is complete.** It already builds a carrier whose
one-step relation is an oriented forest, presents it via `FrameOver.ofStepSat`, proves the
projection surjective and `TwoWayBounded`, and assembles the L⁺ transfer through
`TwoWayBounded.plus_invariance_of_isZTime_of_constraints`. Its declaration sequence —
`*_loopFree`, `*_oppFree`, `*_acyclic`, `*_isOrientedForest`, `*_serial_fwd`, `*_serial_bwd`,
`*_surjective`, `*_iter`, `exists_iter_*_fwd`, `exists_iter_*_bwd`, `*FrameOfSerial`,
`*_taskRel`, `*_isRegular`, `*_twoWayBounded_of_constraints`, `exists_*_of_constraints` — should
be mirrored name-for-name. The `_of_constraints` / instance-projected pairing (a general form
taking `hcomp hser hlim` explicitly, plus a thin `[F.IsRegular]` specialisation) is the house
convention and should be kept.

**Why not reuse the universal cover.** `exists_orientedForest_cover` already transfers L⁺ truth
onto a regular oriented-forest frame, so it is reasonable to ask whether this task is
redundant. It is not. The universal cover is a forest *everywhere* and is not a copy of the base
anywhere; Reynolds' device needs a preimage that keeps a **verbatim copy of the frame** (so every
predecessor survives, which is what makes the projection two-way bounded) while the **forward
cone above the chosen point is a tree**. The cone unravelling delivers exactly that: `coneF` maps
`inr (v, h) ↦ v`, so above any base state `u` there sit inr nodes whose forward cones lie wholly
inside `coneRin` and are therefore forests, while the inl layer is the verbatim copy. This is
also the carrier the recorded obligation in `NamingRules.lean` is literally stated over
(`Set (Set (W ⊕ (W × List W)))`), so discharging it requires this carrier and not another.

**Everything the proof cites is already public.** Verified present, with signatures read:

| Declaration | File | Role |
|---|---|---|
| `IsOrientedForest` (`loopFree`/`oppFree`/`acyclic`) | OrientedForest.lean:134 | lemma (1)'s target |
| `saturation_of_orientedForest` / `'` | OrientedForest.lean:880 / 837 | inr-anchored half |
| `sInter_nonempty_of_forward_fibres` | OrientedForest.lean:743 | alternative for the same half |
| `sInter_nonempty_of_subsingleton_member` | OrientedForest.lean:536 | the Step-1 reduction |
| `seg_subsingleton`, `fib_zero_eq_singleton` | OrientedForest.lean:652, 659 | shape bookkeeping |
| `TaskFrame.sInter_nonempty_of_directed_of_minimal` | TaskFrame.lean:1816 | under the two above |
| `TaskFrame.Saturation`, `DirectedFamily`, `IsFiber`, `IsSegment`, `Fib`, `Seg` | TaskFrame.lean:695, 511, 573, 583, 431, 481 | the obligation's vocabulary |
| `SimpleGraph.isAcyclic_of_rank_parent` | ForMathlib/.../SimpleGraphAcyclic.lean:130 | lemma (1)'s `acyclic` field |
| `FrameOver.ofStepSat` + `_taskRel` / `_isRegular` / `_step` | IntNormalForm.lean:516, 557, 551, 565 | frame assembly |
| `ofStepRel`, `ofStepRel_of_nonneg/nonpos`, `ofStepRel_gen`, `iter`, `iter_add` | IntNormalForm.lean:445-463, OrientedForest.lean:592, IntNormalForm.lean:138, 162 | relation plumbing |
| `FrameOver.taskRel_eq_iter_of_constraints` | IntNormalForm.lean:259 | base-side decomposition |
| `TwoWayBounded` (`forth`/`step`) | HistoryMorphism.lean:281 | lemma (3)'s target |
| `TwoWayBounded.plus_invariance_of_isZTime_of_constraints` | HistoryMorphism.lean (~544) | the L⁺ transfer |

No name collision: `coneR`, `coneRin`, `coneF`, `ConeUnravelling` are unused in the tree
(`TaskFrame.cone` and `coneFilter` are unrelated and differently named).

**One small gap.** There is no `F.TaskRel = ofStepRel F.step` relation-level equality for a
general regular `F`; only `taskRel_eq_iter_of_constraints` (a pointwise `iff`). The Saturation
lemma should therefore take the base *Saturation* in `ofStepRel` form as a hypothesis (mirroring
`saturation_of_orientedForest'`'s own `hgen`-parameterised design), and the frame-level assembly
should bridge it once with `funext`/`propext`.

### External Resources

Mathlib at this pin contributes only through the already-wrapped
`SimpleGraph.isAcyclic_of_rank_parent` (a repo-local ForMathlib extension — Mathlib carries no
rank/parent sufficient condition at `v4.33.0-rc1`). The three deprecation traps recorded in
`OrientedForest.lean`'s header (`isAcyclic_iff_subsingleton_path`, `Walk.isPath_iff_nil` /
`length_eq_zero_iff`, `Walk.cons_tail_support`) are not touched by this task, because the
acyclicity proof goes through the rank/parent criterion and never mentions a walk.

### The construction, as probed

```lean
def coneRin (E : W → W → Prop) : (W × List W) → (W × List W) → Prop :=
  fun p q => E p.1 q.1 ∧ q.2 = p.1 :: p.2

def coneR (E : W → W → Prop) : (W ⊕ (W × List W)) → (W ⊕ (W × List W)) → Prop
  | .inl u, .inl v => E u v
  | .inl u, .inr q => E u q.1          -- PROMISCUOUS in q.2; see Decisions
  | .inr p, .inr q => coneRin E p q
  | .inr _, .inl _ => False

def coneF : (W ⊕ (W × List W)) → W
  | .inl u => u
  | .inr p => p.1
```

`parIn (v, []) = (v, [])`, `parIn (_, a :: t) = (a, t)`; rank is `fun p => p.2.length`.

### Lemma (1) — the inr layer is an oriented forest

`IsOrientedForest (coneRin E)`, **probed and compiling**. `loopFree` and `oppFree` are list-length
contradictions; `acyclic` is `SimpleGraph.isAcyclic_of_rank_parent (fun p => p.2.length) parIn`
with the rank inequality by `cases` on the list and the adjacency obligation by `simp_all [parIn]`
after `SimpleGraph.fromRel_adj`. The "unique inr-predecessor" half of the task description's
parenthetical is a separate, also-probed lemma (`coneRin_bwd_unique`, by induction with
`List.head?`/`List.tail` injectivity), consumed by the segment case of the split rather than by
`IsOrientedForest` itself.

Note that lemma (1) holds on the **full** `W × List W`, incoherent records included: a record
that does not trace a real `E`-path simply has no incoming edge, which an acyclicity statement is
indifferent to.

### Lemma (2) — the two-layer Saturation split

Target: `TaskFrame.Saturation (ofStepRel (coneR E))` from `TaskFrame.Saturation (ofStepRel E)`.
Let `S` be a `DirectedFamily` whose members are nonempty fibres or segments. Directedness plus
member-nonemptiness gives the handle the whole proof turns on: **any two members intersect
nonemptily** (take the common sub-member and use its nonemptiness).

**Step 1 — subsingleton reduction.** If some member is a subsingleton, close with
`sInter_nonempty_of_subsingleton_member`. This disposes of every duration-zero fibre
(`fib_zero_eq_singleton`), every segment with `x = 0` or `y = 0`, and every segment contained in
the inr layer (such a segment's elements are determined by `coneRin_bwd_unique`).

**Step 2 — the split.** Case on `∃ s₀ ∈ S, s₀ ⊆ Set.range Sum.inr`.

**Step 3 — Case A (no member lies in the inr layer): transport by `Sum.inl ⁻¹'` to the base.**
For every member `s`, `Sum.inl ⁻¹' s` is a base fibre or segment, and `inl b ∈ s ↔ b ∈ Sum.inl ⁻¹' s`
by definition. The shape analysis (each line probed at Fib level):

| member shape | `Sum.inl ⁻¹' s` | probe |
|---|---|---|
| `Fib R (.inl a) x`, any sign | `Fib (ofStepRel E) a x` | `inl_preimage_fib_inl` |
| `Fib R (.inr q) x`, `x < 0` | `Fib (ofStepRel E) q.1 x` | `inl_preimage_fib_inr_neg` |
| `Fib R (.inr p) x`, `0 ≤ x` | *excluded*: `s ⊆ range inr` contradicts Case A | `fib_inr_pos_subset` |
| `Seg R w v x y` | intersection of the two rows above = a base `Seg` | composes |

Nonemptiness of `Sum.inl ⁻¹' s` is free: take `u ∈ s`, then `coneF u` lies in the base set by
`coneF_iter`, and the table's equality puts it in `Sum.inl ⁻¹' s`. Directedness transports
trivially under a preimage. Base *Saturation* yields `b` with `inl b` in every member.

**Step 4 — Case B (some `s₀ ⊆ range inr`): cofinality, then the forest.** Put
`S_inr := {s ∈ S | s ⊆ range inr}`. It is **cofinal** in `S`: for any `s ∈ S`, directedness gives
`s' ∈ S` with `s' ⊆ s₀ ∩ s ⊆ range inr`, so `s' ∈ S_inr` and `s' ⊆ s`; hence
`⋂₀ S_inr = ⋂₀ S`. `S_inr` is itself directed and nonempty by the same move. After Step 1, every
member of `S_inr` is `Fib R (.inr p) x` with `0 ≤ x` (an inl-anchored fibre always contains an inl
element, obtained from any member element via `coneF` and `iter_inl_inl` / `iter_inl_inr`; a
negative-duration inr-anchored fibre likewise; segments in the inr layer are subsingletons).
Transport by `Sum.inr ⁻¹'` (`inr_preimage_fib_inr_pos`, probed) onto `W × List W` and apply
`saturation_of_orientedForest (coneRin_isOrientedForest E)` to the transported family — each
member is an `IsFiber (ofStepRel (coneRin E))`. The resulting point `p` gives `inr p ∈ ⋂₀ S_inr = ⋂₀ S`.

`sInter_nonempty_of_forward_fibres` is an equally valid endpoint for Step 4 and skips the
`IsFiber` repackaging; `saturation_of_orientedForest` is preferred for fidelity to the task
description. Either is already public.

### Lemma (3) — `TwoWayBounded` for `coneF`, with surjectivity

`forth` is `coneF_iter` on the two sign-guarded conjuncts of `ofStepRel`, read against the base's
`taskRel_eq_iter_of_constraints` — character-for-character `endpt_twoWayBounded_of_constraints`.
`step` splits four ways, all probed or immediate:

| anchor | duration | witness |
|---|---|---|
| `.inl w` | either sign | `.inl v`, via `iter_inl_inl` |
| `.inr p` | `0 ≤ x` | the inr-layer lift `exists_iter_coneRin` (records the base path) |
| `.inr p` | `x < 0` | `.inl v`, via `iter_inl_inr` — the promiscuous entry edge at the **last** step |

`coneF` is surjective with the `Sum.inl` section (axiom-free, as `endpt_surjective` is). Then
`TwoWayBounded.plus_invariance_of_isZTime_of_constraints` applies verbatim, with
`SuccOrder ℤ` / `IsSuccArchimedean ℤ` by `inferInstanceAs` as in `UniversalCover.lean`.

### Recommendations

A **sorry-free path exists**; no step in it is open or conjectural, and the three riskiest
mechanical pieces are already compiling. Recommended decomposition for the plan:

1. **Phase 1 — carrier, relation, oriented forest.** `coneRin`, `coneR`, `coneF`, `parIn`, the
   three `IsOrientedForest` fields, `coneRin_isOrientedForest`, `coneRin_bwd_unique`,
   `coneR_serial_fwd`, `coneR_serial_bwd`. **All of this is already written and compiling in the
   probe** and can be lifted with docstrings added.
2. **Phase 2 — the transport layer.** `coneF_step`, `coneF_iter`, `iter_inl_target`,
   `iter_inl_inl`, `iter_inr_fwd`, `iter_inl_inr`, `exists_iter_coneRin`, then the four Fib-level
   bridges. **Also already compiling in the probe.**
3. **Phase 3 — the two-layer Saturation lemma.** The only genuinely new work: the shape
   classification plus the four-step case analysis above. Recommended intermediate lemmas, one per
   bookkeeping burden: `fib_or_seg_inl_preimage` (Case A's table as one lemma),
   `subsingleton_of_subset_range_inr` (Step 1's inr-segment case), `mem_range_inl_of_mem`
   (the "contains an inl element" fact used to exclude shapes in Case B), and
   `cofinal_sInter_eq` (a frame-independent set lemma — it mentions no relation and could sit
   beside `sInter_nonempty_of_subsingleton_member`).
4. **Phase 4 — frame assembly and the headline.** `coneFrameOfSerial`/`coneFrame` via
   `FrameOver.ofStepSat`, the `_taskRel` and `_isRegular` bridges, `coneF_surjective`,
   `coneF_twoWayBounded_of_constraints` and its `[F.IsRegular]` specialisation, and
   `exists_coneUnravelling_of_constraints` mirroring `exists_orientedForest_cover_of_constraints`.
   Then amend `NamingRules.lean`'s module docstring: the paragraph ending "Discharging
   *Saturation* for a path-recording relation directly is left open" is what this task retires,
   and it must be rewritten rather than left standing.

Two statement-shape recommendations the plan should pin as Lean Challenge Statements:

- `theorem saturation_coneR {E : W → W → Prop} (hbase : TaskFrame.Saturation (ofStepRel E)) : TaskFrame.Saturation (ofStepRel (coneR E))`
  — **no seriality hypothesis**, per the Executive Summary finding. Adding one would be a
  silently weaker statement.
- `theorem coneRin_isOrientedForest (E : W → W → Prop) : IsOrientedForest (coneRin E)`
  — over the full `W × List W`, **not** a coherence subtype. A subtype-restricted variant would
  be strictly weaker and would not support the frame assembly.

Also worth a line in the new module's docstring: a `Tests/BimodalTest/Semantics/` axiom-profile
pin, mirroring `OrientedForestSaturationTest.lean`, for the two headline theorems.

## Decisions

- **Entry edge stays promiscuous in the recorded list.** Decided on the evidence above: it is the
  unique reading under which the literal sum carrier is doubly serial, and it is what turns two
  otherwise-messy set computations into single-fibre equalities. Recorded here because the
  alternative (`h = [u]`) is the "obvious" reading and will look like a correctness improvement
  to a later reader; it is not — it breaks `TaskFrame.Serial`.
- **The carrier is not cut to coherent records.** A coherence subtype was considered and
  rejected: it would restore the narrow entry rule at the cost of a subtype carrier, a
  `Sigma`-type or inductive family, and the `HEq` discipline `UniversalCover.lean` had to adopt
  for `RWalk`. The promiscuous rule avoids all of it.
- **Saturation is split on `∃ s ∈ S, s ⊆ Set.range Sum.inr`**, not on the anchor of a
  distinguished member. The subset condition is decidable-by-cases from the member's shape and is
  stable under the directedness refinement, which an anchor-based split is not.
- **Case B goes through cofinality rather than a per-member reshaping.** A member anchored at an
  inl state has an inr part that is a *union* of inr-layer fibres over entry points, so it cannot
  be transported member-by-member; replacing it by a sub-member inside the inr layer is what
  makes the forest lemma applicable, and that replacement is pure directedness.
- **`UniversalCover.lean` is not modified.** The two constructions answer different questions and
  the existing module's headline has its own consumers.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| The Saturation shape classification is the one unprobed step; a missed member shape would leave a gap mid-proof | Medium | The classification is exhaustive over `IsFiber ∨ IsSegment` × anchor-side × duration sign (12 cells, all accounted for above). Phase 3 should open by stating the classification as its own lemma, so a missing cell fails at a named declaration rather than inside the main proof. |
| `simp_all [parIn]` in the acyclicity proof is brittle under a Mathlib bump | Low | It compiles at this pin and the obligation is a two-case list destructuring; a bump re-check belongs in the module's "Verified Mathlib names" table, as `OrientedForest.lean` already does. |
| A later reader "fixes" the promiscuous entry edge | Medium | Recorded as a Decision above; the plan should require the module docstring to state why, in the shape `UniversalCover.lean` uses for its own multigraph convention. |
| `NamingRules.lean`'s docstring keeps asserting the obligation is open after this lands | Medium (documentation correctness) | Made an explicit Phase 4 deliverable, not a cleanup. |
| No in-corpus source for Reynolds' *Auxiliary Atoms* rule | Low for this task | The task's target is the obligation recorded in-repo, which was read in full and is quoted above; no step of this work reproduces a proof from the paper. Flagged as a corpus gap below. |
| Scope creep into the formula-level rule | Low | The task boundary is frame-side; `NamingRules.lean`'s `clock_irr_sound` / `irr_sound` are untouched. |

Zero-debt posture: no `sorry`, no new axiom, and no vacuous-definition pattern is required
anywhere in the recommended path. If Phase 3's case analysis were to stall, the correct response
is `[BLOCKED]` with the stalled cell named — not a placeholder — but on the evidence here that
outcome is unlikely.

## Tactic Survey Results

Surveyed empirically against the probe's real goals rather than speculatively; every row below is
a measured outcome from `specs/evidence/cone-unravelling-frame-layer-split/cone-core-probe.lean`
compiling at `lake env lean`.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `coneRin` loop-freeness (list length) | `absurd (congrArg List.length h) (by simp)` | success | `List.length` simp set |
| `coneRin` opposite-edge-freeness | `simp at …; omega` | success | two length equations |
| `coneRin` acyclicity, rank inequality | `cases l <;> simp [parIn]` | success | `parIn` unfolded |
| `coneRin` acyclicity, adjacency obligation | `simp_all [parIn]` after `SimpleGraph.fromRel_adj` | success | product destructuring first |
| `iter`-level transport identities (5 lemmas) | `induction n` + `match … with` on the step | success | `coneR` unfolded by `simp [coneR]` for the `inr → inl` absurd branch |
| `iter`-level transport, base cases | `rw [iter_zero]` then `subst`/`exact` | success | — |
| Fib-level bridges (4 lemmas) | `ext` + `simp only [Set.mem_preimage, TaskFrame.mem_Fib, ofStepRel_of_nonneg/nonpos]` | success | sign hypothesis supplied by `rcases le_or_gt 0 x` |
| negative-duration `natAbs` normalisation | `obtain ⟨n, hn⟩ : ∃ n, x.natAbs = n + 1 := ⟨…, by omega⟩` | success | `omega` closes the arithmetic side |
| inr-layer lift (`exists_iter_coneRin`) | `induction n` + explicit anonymous-constructor witness | success | no automation needed |

Observations for the implementer: `omega` and `simp [List.length]` carry every arithmetic and
list-length obligation in lemma (1); `match … with` on the step relation (rather than `cases`) is
what keeps the sum-type case analysis free of motive trouble; and `simp [coneR]` discharges the
`inr → inl` impossible branch uniformly. No goal in the probe needed `aesop`, `decide`, or a
`lean_hammer_premise` consultation.

## Context Extension Recommendations

- **Topic**: Reynolds' *Auxiliary Atoms* rule, primary statement
  **Gap**: `literature-search.sh` finds no formal-logic occurrence of "auxiliary atoms" in the
  corpus, and `reynolds_2001`'s sub-index skips the axiom-system sections where the rule sits (its
  TOC jumps from §4.7-4.8 straight to §9). The repository's only statement of the rule's semantic
  core is `NamingRules.lean`'s module docstring — adequate for this task, but the formula-level
  follow-on task will want the source.
  **Recommendation**: ingest the missing `reynolds_2001` §5-8 chunks (or
  `reynolds_2002_axioms_for_branching_time`, already in the index, if the rule appears there)
  before the formula-level Auxiliary-Atoms task is planned.

- **Topic**: the "unravelling constructions" family in this tree
  **Gap**: after this task there will be two structurally similar carriers —
  `UniversalCover.CoverPt` (reduced walks, forest everywhere) and the cone unravelling (two
  layers, forest above the entry) — with no single place recording which to reach for.
  **Recommendation**: a short `context/project/lean4/patterns/` note, or a cross-reference
  paragraph in each module's docstring, stating the division of labour (verbatim-copy-plus-tree
  vs. forest-everywhere) and that `ProofSystem.FrameClass.Sat`'s `IsRegular` demand is what both
  exist to satisfy.

## Appendix

### Probe artifact

`specs/evidence/cone-unravelling-frame-layer-split/cone-core-probe.lean` — three namespaces
(`Probe894`, `Probe894b`, `Probe894c`), 23 declarations, compiles with **no output** (no errors,
no warnings, no sorries) under
`timeout 420 lake env lean specs/evidence/cone-unravelling-frame-layer-split/cone-core-probe.lean`
at Lean v4.33.0-rc1 / Mathlib `v4.33.0-rc1`. Contents: the three definitions and `parIn`;
`coneRin_loopFree`, `coneRin_oppFree`, `coneRin_acyclic`, `coneRin_isOrientedForest`;
`coneR_serial_fwd`, `coneR_serial_bwd`; `coneF_step`, `coneF_iter`, `iter_inl_target`,
`iter_inl_inl`, `iter_inr_fwd`, `iter_inl_inr`, `coneRin_bwd_unique`,
`coneRin_bwd_subsingleton`; `inl_preimage_fib_inl`, `inl_preimage_fib_inr_neg`,
`fib_inr_pos_subset`, `inr_preimage_fib_inr_pos`; `exists_iter_coneRin`,
`exists_iter_coneR_bwd_inr`. Phases 1 and 2 of the recommended plan are substantially present
there and should be lifted rather than rewritten.

### Searches and probes run

- `grep` sweep for `IsOrientedForest|saturation_of_orientedForest|TwoWayBounded|ofStepRel|plus_invariance_of_isZTime` across the tree (17 files; 6 relevant)
- Declaration listings of `OrientedForest.lean` and `UniversalCover.lean`; full read of
  `NamingRules.lean`'s module docstring, `UniversalCover.lean`'s docstring and assembly tail,
  and the `Saturation` / `DirectedFamily` / `IsFiber` / `IsSegment` / `Fib` / `Seg` /
  `sInter_nonempty_of_directed_of_minimal` / `IsRegular` sites in `TaskFrame.lean`
- Signature reads of `ofStepSat`, `isAcyclic_of_rank_parent`, `taskRel_eq_iter_of_constraints`,
  `Serial`, `seg_subsingleton`, `sInter_nonempty_of_subsingleton_member`,
  `sInter_nonempty_of_forward_fibres`, `saturation_of_orientedForest'`
- Collision check for `coneR` / `coneF` / `ConeUnravelling` (none)
- `literature-search.sh` for the Auxiliary-Atoms rule (two phrasings, no hit) and
  `--toc reynolds_2001`
- Two compile rounds of the probe file (one arity correction between them; the second and third
  blocks compiled first try)

### References

- `FormalSystem/Semantics/OrientedForest.lean` — `IsOrientedForest`, the `saturation_of_*` family
- `FormalSystem/Semantics/UniversalCover.lean` — the template for assembly and `TwoWayBounded`
- `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.Saturation` and its vocabulary
- `FormalSystem/Semantics/IntNormalForm.lean` — `ofStepRel`, `iter`, `FrameOver.ofStepSat`
- `FormalSystem/Semantics/HistoryMorphism.lean` — `TwoWayBounded`, `plus_invariance_of_isZTime`
- `FormalSystem/Metalogic/NamingRules.lean` — the recorded *Saturation* obligation this discharges
- `FormalSystem/ForMathlib/Combinatorics/SimpleGraphAcyclic.lean` — the rank/parent criterion
