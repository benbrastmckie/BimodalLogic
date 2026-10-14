# Research Report: Task #789

**Task**: 789 - Prove `app:gluing` in full generality (two convex histories, nonempty overlap)
**Started**: 2026-10-14T00:15:00Z
**Completed**: 2026-10-14T01:40:00Z
**Effort**: 1 implementation round, 4 phases, low risk — the construction is verified, not sketched
**Dependencies**: None blocking. Reuses landed material only (`PartialHistory.rel_across_seam`,
`TaskFrame.reflection_of_ne`, `Presheaf.partialHistory_ext`).
**Sources/Inputs**:
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` — `app:gluing`
  statement and proof, `rmk:choice`, `def:world-history`, and the `% PORT:` marker
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` — the superseded
  longer draft of the same proof (`An earlier proof of gluing`), and the `ρ ⌢_z σ` pasting passage
- `FormalSystem/Semantics/PartialHistory.lean`, `FormalSystem/Semantics/PartialHistoryOrder.lean`
- `FormalSystem/Semantics/Presheaf/{Sheaf,Ray,Directed,Behavior}.lean`
- `FormalSystem/PlusLanguage/PlusPasting.lean` (`pasteAt`, the disjointified-seam precedent)
- `docs/reference/paper-definitions-of-record.md` (the `app:gluing` KNOWN-ANCHORS row)
- `specs/ROADMAP.md` Stage 1 note; `specs/566_.../reports/01_total-histories-limit-clause.md`
- `scripts/check-module-invariants.sh` (C2/C14/C15 gates), `docs/theorem-index.md`
- Mathlib search (`lean_leanfinder`, `lean_loogle`) for a reusable union-gluing device
- Six `lake env lean` probe runs against the live tree
**Artifacts**:
- `specs/789_prove_app_gluing_general_convex_overlap/reports/01_general-convex-gluing.md`
- `specs/789_prove_app_gluing_general_convex_overlap/gluing-probe.lean` — the **fully verified,
  warning-free, choice-free** probe the implementation round transcribes
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The whole lemma is already proved, machine-checked, in the probe.** Union domain, glued state
  function, the four-way `respects_task` split with both mixed-pair seam steps, convexity of
  `X₁ ∪ X₂`, both reading equations, both restriction identities, uniqueness, and the packaged
  `ExistsUnique` all elaborate green under `lake env lean` with no `sorry`, no vacuous definition,
  and zero linter warnings. The implementation round is transcription plus gates, not discovery.
- **Choice-freeness holds and is measured, not argued.** `#print axioms` reports
  `[propext, Quot.sound]` on every declaration, and `[propext]` on the convexity-of-the-union
  lemma — exactly the profile `Sheaf.lean` and `Ray.lean` record. `rmk:choice`'s classification of
  `app:gluing` as choice-free is therefore confirmed in Lean, not merely asserted.
- **One encoding hypothesis is unavoidable and must be documented: `DecidablePred τ₁.domain`.**
  The union domain is a `Prop`-valued `Or` with two constructors, so eliminating it to pick a
  state is eliminating a `Prop` into a `Type`; Lean forbids that without a decision procedure.
  `Classical.propDecidable` would supply one and would reinstate `Classical.choice`, destroying
  exactly the pin this task exists to land. This is a Lean-constructivity artifact, not a
  mathematical choice principle, and Mathlib's own gluing of two partial maps
  (`PartialEquiv.piecewise`) carries the identical instance binder.
- **The overlap witness must be an explicit parameter of the construction, but the clause may
  take the paper's own `X₁ ∩ X₂ ≠ ∅`.** Extracting `z` from an existential needs
  `Classical.choose`; but the `∃!` clause is a `Prop`, so `gluing_clause_of_overlap` takes
  `∃ z, τ₁.domain z ∧ τ₂.domain z` and is measured choice-free. Both forms are verified.
- **Uniqueness needs no frame constraint, no convexity and no overlap** — the same shape as
  `Presheaf.directed_gluing_unique`. It needs partial-history extensionality, which currently
  lives in `Presheaf/Behavior.lean` under a recorded "move this down rather than copy it"
  follow-up. Honouring that follow-up is a prerequisite, not optional.
- **Recommended approach**: one new module `FormalSystem/Semantics/Gluing.lean` (namespace
  `FormalSystem.Semantics.PartialHistory`, names `convexGlue*` / `gluing_clause*`), the
  `partialHistory_ext` relocation, the two Presheaf cases **left independent** with an explicit
  docstring decision plus one cheap instance-witness for the paper's `ρ ⌢_z σ`, and the axiom
  claim made machine-gated via C14 rather than left as prose.

## Context & Scope

Researched: whether `app:gluing` can be stated and proved in full generality at the
convex-history layer of this tree; at what cost in hypotheses, imports and axioms; where the
declaration belongs; and what relation it bears to the three special cases already landed
(`Presheaf.sheaf_clause`, `Presheaf.directed_gluing_clause`, `Ray.seamGlue`).

Constraints honoured: no `sorry` and no deferral anywhere (the probe is complete); no new axiom;
choice-freeness is a hard requirement from `rmk:choice`; the aggregator-contention note applies
because `FormalSystem/Semantics.lean` sits in the concurrently dispatched sibling's declared
`file_scope`.

Not in scope and deliberately untouched: task 566's limit presentation of `H_F` (a different
statement — related only by the remark recorded below), and the paper-side `% PORT:` /
`\leanproof` edit, which is a different repository.

## Literature Proof Structure

**Source**: `app:gluing` (Lthm, *Gluing*) in `possible_worlds.tex`, with the superseded longer
draft retained verbatim in `appendix_cut_material.tex` under `An earlier proof of gluing`.
**Strategy**: direct construction plus a uniqueness tail; the only non-trivial device is a fixed
overlap point `z` used both to interpolate the union's convexity and to compose the task
constraint across the two domains.

The two texts agree step for step; the live proof is the cut draft with the two convexity
sub-cases compressed into one sentence. Nothing in the draft is needed that the live proof omits.

### Step Map

1. Fix `z ∈ X₁ ∩ X₂` (nonempty by hypothesis) and observe `τ := τ₁ ∪ τ₂` is a *function* on
   `X₁ ∪ X₂`, since the two agree on the overlap — [Source] `app:gluing` proof, ¶1.
2. `X₁ ∪ X₂` is nonempty and convex. For `a ≤ b ≤ c` with `a, c ∈ X₁ ∪ X₂`: if both lie in one
   `Xᵢ`, convexity of `Xᵢ` gives `b`; otherwise (relabelling) `a ∈ X₁`, `c ∈ X₂`, and since `≤` is
   total either `a ≤ b ≤ z` with `a, z ∈ X₁` or `z ≤ b ≤ c` with `z, c ∈ X₂` — [Source] ¶2.
3. `τ(x) ⇒_{y−x} τ(y)` for all `x ≤ y` in `X₁ ∪ X₂`, the `y < x` instances covered by the
   reflection convention — [Source] ¶3, first sentence.
   1. Both in one `Xᵢ`: inherited from `τᵢ`.
   2. `x ∈ X₁`, `y ∈ X₂`, `z < x`: then `z ≤ x ≤ y` with `z, y ∈ X₂`, so `x ∈ X₂` by convexity
      and the constraint is inherited from `τ₂` after all.
   3. Symmetrically `y ∈ X₁` should `y < z`.
   4. Remaining case `x ≤ z ≤ y`: `τ₁(x) ⇒_{z−x} τ(z)` and `τ(z) ⇒_{y−z} τ₂(y)` compose by
      *Compositionality*.
4. Uniqueness: any convex history on `X₁ ∪ X₂` restricting to both agrees with `τ₁` on `X₁` and
   `τ₂` on `X₂`, hence with `τ` — [Source] ¶4.

### Dependencies

- Step 3.2/3.3/3.4 depend on Step 1 (well-definedness at `z`) and on the two convexity
  hypotheses; Step 3.4 is the only step that touches a frame constraint.
- Step 2 and Step 4 depend on nothing but the order and the hypotheses.
- Step 4 depends on Steps 1–3 only for there to *be* a `τ` to be unique.

### Potential Formalization Challenges

- **Step 1 is the only genuinely hard step in Lean**, and not for mathematical reasons: "τ is a
  function on `X₁ ∪ X₂`" is a one-line set-theoretic observation and a decidability obligation in
  type theory. See **Findings → The one encoding hypothesis**.
- **Step 3's "for all `x ≤ y`" is not the Lean obligation.** `PartialHistory.respects_task` is
  stated *unconditionally* over all pairs (the repository's recorded transcription decision), so
  the obligation has four cases per side-split, not two, and the backwards-orientation cases must
  be discharged by `TaskFrame.reflection_of_ne` — the *off-zero* law. The unrestricted
  `FrameOver.reflection` closes the same goals and measures `Classical.choice`; substituting it
  silently destroys the pin. `pasteAt` and `Presheaf.glue` both record this trap.
- **"Relabelling if necessary"** is a `Prop`-level `rcases` on `le_total`, free; it does *not*
  license a symmetry argument at the level of the construction, which is left-biased on `τ₁`.
- **Step 4's "and so with τ"** needs partial-history extensionality, i.e. `propext` + `funext` +
  proof irrelevance. The lemma exists but is in the wrong cluster.

## Findings

### The verified construction

`specs/789_prove_app_gluing_general_convex_overlap/gluing-probe.lean` elaborates green and
warning-free. Its shape, declaration by declaration:

| Probe declaration | Content | Hypotheses consumed |
|---|---|---|
| `isConvex_union` | Step 2 | both convexities, `z` in both; **no** frame constraint, **no** decidability |
| `rel_mixed_left` | Step 3.2 + 3.4 (`x ∈ X₁`, `y ∈ X₂`, `¬ τ₁.domain y`, `x ≤ y`) | `Compositional`, both convexities, agreement at `z` |
| `rel_mixed_right` | the mirror (`x ∈ X₂`, `y ∈ X₁`, `¬ τ₁.domain x`, `x ≤ y`) | same |
| `glue` | the glued convex history | the above + `DecidablePred τ₁.domain` |
| `glue_domain`, `glue_mem_left/right` | domain bridges, all `Iff.rfl` / `Or.inl` / `Or.inr` | — |
| `glue_states_left`, `glue_states_not_left` | the two `dite` branches, literally `dif_pos` / `dif_neg` | — |
| `glue_states_right` | the reading **where the seam hypothesis is consumed** | agreement |
| `glue_isConvex` | `isConvex_union` at `glue`, on the nose | — |
| `glue_extends_left/right` | both restriction identities | agreement (right only) |
| `glue_unique` | Step 4 | **nothing**: no frame constraint, no convexity, no overlap |
| `gluing_clause` | the `∃!`, with the overlap point explicit | all of the above |
| `gluing_clause_of_overlap` | the `∃!` under `∃ z, τ₁.domain z ∧ τ₂.domain z` | same |
| `pastRay_isConvex`, `futRay_isConvex`, `decPastRay`, `seamGlue_isTotal`, `seamGlue_states_past` | the paper's `ρ ⌢_z σ` exhibited as an instance | `Compositional` |

The statement the probe proves (modulo the naming recommended below):

```lean
theorem gluing_clause_of_overlap {τ₁ τ₂ : PartialHistory F}
    (hcomp : TaskFrame.Compositional F.TaskRel) [DecidablePred τ₁.domain]
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    (hov : ∃ z : F.Duration, τ₁.domain z ∧ τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q) :
    ∃! υ : PartialHistory F,
      (∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t)) ∧ υ.IsConvex ∧
        υ.Extends τ₁ ∧ υ.Extends τ₂
```

Three points about this signature are deliberate and should survive into the module.

*The domain condition is a pointwise `Iff`, not a predicate equality.* This is the same choice
`Beh F l` makes and for the same reason recorded in `Behavior.lean`: in `Iff` form the
construction's own domain obligation discharges by `Iff.rfl`, and every downstream `rfl` survives.

*Convexity is a conjunct of the `∃!`, although it is implied by the domain condition.* The paper
says "the unique **convex** history with domain `X₁ ∪ X₂`", and adding an implied conjunct makes
the uniqueness half strictly easier while making the statement literally faithful.

*`Compositional` is explicit, never an `[F.IsRegular]` bundle.* This is the `Sheaf`/`Ray` house
rule: the signature must say which frame law is used. One law is used, in one sub-case.

### The one encoding hypothesis, and why nothing cheaper works

`PartialHistory.states : (t : F.Duration) → domain t → F.WorldState` is dependent on a
`Prop`-valued domain. With `domain := fun t => τ₁.domain t ∨ τ₂.domain t`, choosing a state means
eliminating a two-constructor `Prop` into a `Type`, which Lean permits only via `Decidable`.
Four escapes were considered and each fails:

1. **Unique choice.** The glued value *is* uniquely determined, but Lean 4 has no choice-free
   definite description: `∃!`-extraction routes through `Classical.choice` (which is precisely why
   `PartialHistoryOrder.chainSup` is `noncomputable` and measures it).
2. **`Classical.propDecidable`.** Supplies the instance and reinstates `Classical.choice` on
   everything downstream. Rejected by the task's own deliverable (2).
3. **Disjointify the union as `pasteAt` does.** `pasteAt` escapes decidability by *defining* its
   domain as `(z ≤ t ∧ σ.domain z) ∨ (¬ z ≤ t ∧ τ.domain z)` and splitting on the order test
   first. That works because its domain is the disjointified one by construction. It does **not**
   generalize: with `X₁ = [0,10]`, `X₂ = [5,6]`, `z = 5`, the disjointified predicate is `[0,6]`
   either way round, not `X₁ ∪ X₂ = [0,10]`. Verified by hand against the definition; this is the
   substantive reason the general lemma is not a one-line corollary of `pasteAt`.
4. **A functional-relation presentation** (domain + graph, union of graphs) is choice-free but
   converting back to `PartialHistory` is unique choice again — escape 1.

So the hypothesis stays, and the honest framing for the docstring is: `DecidablePred τ₁.domain` is
what Lean charges for *defining a function by cases on a union*, exactly as Mathlib charges it in
`Set.piecewise` and `PartialEquiv.piecewise` (`[(x : α) → Decidable (x ∈ s)]`); it is not the
Axiom of Choice, and the paper's ZF-level claim is untouched by it. Every instance the paper and
this tree actually use supplies it for free from the frame's `LinearOrder`: interval domains
(`Beh F l`), ray domains (`· ≤ z`, `z ≤ ·`), and the translates of both.

One practical detail for the plan: the instance must be *declared* at a call site whose domain is
a `restrict`ed predicate, because `(PartialHistory.restrict ρ P hP).domain` does not reduce to `P`
at instance-reducible transparency. `instance decPastRay ... := fun t => inferInstanceAs
(Decidable (t ≤ z))` in the probe is the pattern, and it typechecks.

### Choice-freeness, measured

Final probe run, `lake env lean`, exit 0, no warnings:

| Declaration | Measured axioms |
|---|---|
| `isConvex_union` | `[propext]` |
| `rel_mixed_left`, `rel_mixed_right` | `[propext, Quot.sound]` |
| `glue`, `glue_states_right`, `glue_isConvex`, `glue_extends_right` | `[propext, Quot.sound]` |
| `glue_unique` | `[propext, Quot.sound]` |
| `gluing_clause`, `gluing_clause_of_overlap` | `[propext, Quot.sound]` |
| `seamGlue_isTotal`, `seamGlue_states_past` | `[propext, Quot.sound]` |

This is the same profile `Sheaf.lean` and `Ray.lean` record for the seam cases, and it is the
profile `rmk:choice` predicts. Two steps earn it and would lose it if rewritten: the
backwards-orientation cases go through `TaskFrame.reflection_of_ne` rather than
`FrameOver.reflection`, and the overlap point is a parameter of `glue` rather than extracted from
an existential.

### Where the declaration belongs

The task directs the lemma to the convex-history layer. Three candidate homes were weighed:

- **`FormalSystem/Semantics/Extension/Gluing.lean`** (aggregator `Semantics/Extension.lean`, not
  in any sibling's declared scope) — rejected on charter: `Extension/`'s README defines it as the
  Zorn/*Saturation* chain, and this lemma is choice-free and independent of `thm:extension`.
  Filing it there would misreport the dependency structure the cluster exists to record.
- **Appending to `Semantics/PartialHistory.lean`** — zero aggregator touch, and `rel_across_seam`
  already lives there. Rejected only because the module's docstring is a careful contract about
  the history *layer* and a second substantial topic (with its own paper transcription, choice
  record and instance-relationship decision) would dilute it past the repo's one-topic-per-module
  norm. A viable fallback if aggregator contention turns out to bite.
- **`FormalSystem/Semantics/Gluing.lean`** (recommended) — imports `Semantics.PartialHistory`
  only, so the import closure provably cannot reach `Extension/` or `Presheaf/`, which is itself
  evidence for the choice-free claim. Costs one import line in `FormalSystem/Semantics.lean`.

`FormalSystem/Semantics.lean` is in the concurrently dispatched sibling's declared `file_scope`,
so that one line is a shared touch: re-read the file immediately before editing and stage only
that hunk. The same cycle also requires `lake exe mk_all --lib FormalSystem` to regenerate the
library root `FormalSystem.lean` (one import line per file under `FormalSystem/`; a stale root is
a reported inconsistency in `scripts/typst-status-counts.sh`).

### `partialHistory_ext` must move first

`Presheaf.partialHistory_ext` (`Semantics/Presheaf/Behavior.lean`) is the extensionality lemma
uniqueness needs. Its own docstring records the position: *"The natural home for it is
`Semantics/PartialHistory.lean` beside the structure … Anything else needing partial-history
extensionality should move this lemma down rather than write a second copy."* This task is that
"anything else", and a module under `Semantics/` cannot import `Presheaf/Behavior.lean` without
inverting the cluster order.

The move is cheap and call-site-neutral. Relocated into `namespace FormalSystem.Semantics` under
the same name, all four existing uses keep resolving: `Behavior.lean` and `Directed.lean` sit
inside `namespace FormalSystem.Semantics.Presheaf` (outer-namespace lookup), and
`Metalogic/Independence/BehSeparatedness.lean` already `open`s `FormalSystem.Semantics`. The
sentence in `FormalSystem/Semantics/README.md`'s `Presheaf/` row that records the deferral must be
updated in the same step, and the `Behavior.lean` Implementation-Note paragraph that announces the
follow-up becomes a pointer instead.

### The three landed special cases, and the instance decision

| Landed | Domains | Is it an instance of the general lemma? |
|---|---|---|
| `Presheaf.sheaf_clause` / `Presheaf.glue` | `[0, p]` and the translate of `[0, l−p]` to `[p, l]`, overlap `{p}` | Mathematically yes — this is exactly how the paper proves its *Sheaf* clause ("`app:gluing` provides the unique convex history on `[0, ℓ₁+ℓ₂]`"). |
| `Ray.seamGlue` / `PlusPasting.paste`, `pasteAt` | `(−∞, z]` and `[z, ∞)`, overlap `{z}` | Mathematically yes — the paper's `ρ ⌢_z σ` passage *defines* the operator by applying `app:gluing` to those two restrictions. |
| `Presheaf.directed_gluing_clause` | an upward-directed family of subintervals | **No.** Independent statement, ZFC, measured `[propext, Classical.choice, Quot.sound]`, with `app:gluing`'s own ℚ counterexample showing *Saturation* is genuinely required. |

**Recommended decision, to be recorded in the new module's docstring: leave all three
independent, and discharge the instance claim by witness rather than by re-derivation.**

Re-deriving `Presheaf.glue` from the general construction would replace its `dite` test `z ≤ p`
with the test `τ₁.domain z` (i.e. `0 ≤ z ∧ z ≤ p`), and `Sheaf.lean`'s Implementation Notes record
that `glue_states_le` / `glue_states_not_le` being *literally* `dif_pos` / `dif_neg` is
load-bearing for every proof downstream of them. The same objection applies to `Ray.seamGlue`,
whose two reading equations carry the ray layer. Breaking two landed, measured modules to avoid a
25-line duplication is the wrong trade.

What the probe already supplies instead is the *witness*: `seamGlue_isTotal` and
`seamGlue_states_past` exhibit the paper's `ρ ⌢_z σ` as the general gluing at two ray domains,
total and reading as `ρ` below the seam, measured choice-free. That is enough to say in the
docstring that the seam cases *are* instances, with a verified pointer rather than a bare claim.
An optional, strictly additive bridge — `paste ρ σ z hsame = ⟨convexGlue …, …⟩`, in the shape of
the existing `paste_eq_pasteAt` — can be added later in `PlusPasting.lean` without touching
`Sheaf.lean` or `Ray.lean`; it is listed as an optional phase, not a requirement.

### Relation to the limit presentation (task 566)

Task 566's *Total Histories* clause presents `H_F` as a limit of `Beh(F)(2x)` over centred windows
along the central restrictions. Its compatible-family condition is pairwise agreement on overlaps,
of which this lemma is the two-member case — that is the sense in which "a compatible family of
sections is a gluing", and it is the right note for the docstring. What must **not** be claimed:
566's backward map does not route through any gluing construction at all. It uses the canonical
window index `|t|` to make the union's value definable outright, which is exactly what buys *its*
choice-freeness; 566's own report records that `directedSup` "is not needed and should not be
used" there. So the relation is conceptual, not a dependency in either direction, and the two
statements stay separate as the task directs.

### Paper-side state

- `app:gluing` is live in `possible_worlds.tex` and carries a `% PORT:` comment naming exactly the
  gap this task closes ("the repository has only the closed-interval seam case … and the directed
  case"). `rmk:choice` sits immediately above it and lists `app:gluing` among the choice-free
  results.
- The anchor's row in `docs/reference/paper-definitions-of-record.md` is `LIVE-UNPINNED`, with the
  reason recorded as "*Not pinned: no docstring quotes its text*". **The new docstrings must cite
  `app:gluing` by name and must not block-quote its statement**; quoting it would oblige promoting
  the anchor to the pinned manifest, and that file is in the concurrently dispatched sibling's
  declared `file_scope`. Verbatim quotation is still available for `def:world-history`, which *is*
  pinned, and that is the right anchor for the convexity and extension vocabulary.
- Clearing the `% PORT:` marker and closing the proof with `\leanproof{…}` is a *paper-repository*
  edit, outside this repository. Precedent in this tree (see another in-flight task's report
  §7) is to list it as a follow-up step in the plan and leave the edit to the author.

### Gates the implementation round must clear

- `lake build FormalSystem` green, no new `sorry` (C1, C3).
- `lake exe mk_all --lib FormalSystem` after adding the module, or the generated root drifts.
- `scripts/check-module-invariants.sh`: C4 (imports resolve), C8 (aggregator convention — a new
  `Semantics/Gluing.lean` beside `Semantics/` is already the sanctioned shape), C15 (every
  paper-anchor citation resolves; `app:gluing` and `def:world-history` both have rows), C19
  (docstring coverage), C16 (linters — the probe is already clean), C17 (no dead declarations: the
  reading lemmas are all used by the proofs above them, and `gluing_clause` is used by nothing
  until the optional bridge lands, which is the usual state for a keystone and is reached without
  being named only if it is `instance`-attributed — expect a C17 row to inspect, not a failure).
- `scripts/readme-lint.sh`: the new module needs a row in `FormalSystem/Semantics/README.md`.
- `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree` at
  the module's close, as every `Presheaf/` module does, pinning the module below `Truth.lean`.

### Making the axiom claim gated rather than prose-only

The `Presheaf/` cluster records its measured axioms in docstring tables; none of its declarations
is in a C2/C14 baseline, so those claims are prose. `docs/theorem-index.md` states the stricter
rule for its own rows: *"Every declaration listed here is machine-pinned"*, with `pinned:C14`
naming the baseline that asserts the value on every build.

Since deliverable (2) is explicitly to *pin* choice-freeness, the recommendation is to go the
gated route: add `convexGlue` and `gluing_clause` to **both** heredocs in
`scripts/check-module-invariants.sh` — the `C14_BASELINE` block (the expected
`'…' depends on axioms: [propext, Quot.sound]` lines) and the `C14LEAN` source block (the matching
`#print axioms …` lines) — and add one `docs/theorem-index.md` row carrying `pinned:C14`. The two
heredocs are compared by exact string equality and must stay aligned; that alignment is the only
real risk in the step and it is mechanical.

## Decisions

1. **Statement form**: `∃!` over `PartialHistory F`, with the domain condition as a pointwise
   `Iff`, convexity as an (implied, faithful) conjunct, and both `Extends` conjuncts. Two entry
   points: overlap point explicit (`gluing_clause`) and overlap existential
   (`gluing_clause_of_overlap`), the latter being the paper's literal hypothesis.
2. **`DecidablePred τ₁.domain` is accepted as an instance-implicit hypothesis** and documented as
   a Lean-constructivity artifact with the Mathlib `piecewise` precedent cited. Rejected
   alternatives: `Classical.propDecidable` (loses the pin), unique choice (unavailable), the
   `pasteAt` disjointification (does not generalize — counterexample recorded above).
3. **Home**: new `FormalSystem/Semantics/Gluing.lean`, namespace
   `FormalSystem.Semantics.PartialHistory`. Rejected: `Extension/` (charter mismatch), appending
   to `PartialHistory.lean` (docstring dilution; retained as fallback).
4. **Naming**: `PartialHistory.convexGlue`, `convexGlue_states_left`, `convexGlue_states_right`,
   `convexGlue_isConvex`, `convexGlue_extends_left/right`, `convexGlue_unique`,
   `PartialHistory.gluing_clause`, `PartialHistory.gluing_clause_of_overlap`,
   `PartialHistory.isConvex_union`, `PartialHistory.rel_mixed_left/right`. Not `glue`: `Sheaf.lean`
   already owns that base identifier and `Ray.lean` records the deliberate avoidance of reusing it.
5. **`partialHistory_ext` is relocated** to `Semantics/PartialHistory.lean` under the same name, in
   `namespace FormalSystem.Semantics`, honouring the recorded follow-up. No call site changes.
6. **The two Presheaf seam cases are left independent**, with the decision and its reason recorded
   in the new module's docstring, and with the ray instance exhibited as a verified witness rather
   than asserted. The directed case is independent as a matter of mathematics, not of filing.
7. **Backwards-orientation cases go through `TaskFrame.reflection_of_ne`**, never
   `FrameOver.reflection`. Recorded in the module's Implementation Notes as a trap, as
   `Sheaf.lean` and `Ray.lean` both do.
8. **`app:gluing` is cited by name only, never block-quoted**, to keep its
   `LIVE-UNPINNED` row valid and `docs/reference/paper-definitions-of-record.md` untouched.

## Recommendations

A four-phase round; a sorry-free path exists end to end and is already verified.

**Phase 1 — relocate `partialHistory_ext`.** Move the lemma from `Semantics/Presheaf/Behavior.lean`
into `Semantics/PartialHistory.lean` (`namespace FormalSystem.Semantics`, same name), replace the
Behavior Implementation Note with a pointer, update the `Presheaf/` row of
`FormalSystem/Semantics/README.md`. Verification: scoped build of `FormalSystem.Semantics` plus the
three dependent modules; no call site should need editing, and if one does, that is the signal to
stop and re-read rather than to add an `open`.

**Phase 2 — the module.** Create `FormalSystem/Semantics/Gluing.lean` by transcribing
`gluing-probe.lean` under the Phase-1 names, with the full docstring: paper transcription of the
step map, the `DecidablePred` record, the measured choice table, the reflection-law trap, the
left-bias note, the instance decision for the two Presheaf cases, and the limit-presentation
remark. Close with `assert_not_exists`. Then the one-line import in `FormalSystem/Semantics.lean`
(re-read first — shared touch), the module list entry in its docstring, the README row, and
`lake exe mk_all --lib FormalSystem`. Verification: `lake build FormalSystem` green, no new
`sorry`, `#print axioms` on all declarations reproducing the table above.

**Phase 3 — gate the axiom claim.** Add the two aligned rows to both heredocs in
`scripts/check-module-invariants.sh` and one `pinned:C14` row to `docs/theorem-index.md`.
Verification: `bash scripts/check-module-invariants.sh` passes C14 and C15.

**Phase 4 — the citation surface.** Point the existing `app:gluing` citations at the new general
declaration where they currently name only a special case: `Presheaf/Sheaf.lean`,
`Presheaf/Ray.lean`, `Presheaf/Directed.lean`, `PlusLanguage/PlusPasting.lean`,
`PlusLanguage/PlusRayFibre.lean`, `OpenLanguage/OpenClasses.lean` (+ its README),
`HybridLanguage/HybridTransposition.lean` (+ its README) — docstring References lines only, no
statement changes. Verification: full `lake build`, `check-module-invariants.sh`, `readme-lint.sh`.

**Optional, strictly additive (defer unless cheap):** the bridge
`paste ρ σ z hsame = ⟨convexGlue …⟩` in `PlusLanguage/PlusPasting.lean`, in the shape of the
existing `paste_eq_pasteAt`. It converts the Decision-6 witness into an equation. Do not let it
touch `Sheaf.lean` or `Ray.lean`.

**Territory note.** `FormalSystem/Semantics.lean` and
`docs/reference/paper-definitions-of-record.md` are both inside the concurrently dispatched
sibling's declared `file_scope`. Decision 8 removes the need to touch the second at all; the first
is one appended import line — re-read immediately before editing and stage that hunk alone.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| A reviewer reads `DecidablePred` as a weakening of the paper's statement | medium | Document it as an encoding hypothesis with the Mathlib `piecewise` precedent, and state in the docstring that every instance the paper uses supplies it from the frame's `LinearOrder` |
| `FrameOver.reflection` substituted for `reflection_of_ne` during cleanup, silently reinstating `Classical.choice` | high if it happens | Implementation Notes trap paragraph + the Phase-3 C14 gate, which fails the build the moment the axiom set changes |
| Aggregator collision on `FormalSystem/Semantics.lean` with the concurrent sibling | low | Re-read before editing; stage the single hunk; fallback is appending to `PartialHistory.lean` and touching no aggregator |
| The two C14 heredocs drift out of alignment | low | Both edits in one commit; `check-module-invariants.sh` fails loudly on mismatch |
| Re-deriving the Presheaf cases breaks their `dif_pos`/`dif_neg` reading lemmas | high if attempted | Decision 6 forbids it; the witness route is already verified |
| `lean_local_search`'s index reported `warming`, so no LSP-backed absence claim was made | low | All absence claims in this report rest on `grep`/`lake env lean` evidence instead, and the one Mathlib absence (`Set.OrdConnected` union lemma) rests on an empty `lean_loogle` result, which is reported as such and not as proof |

## Tactic Survey Results

The survey was run against the live obligations, not against a hypothetical goal; every row below
is from a compiled probe rather than from `lean_multi_attempt`.

| Goal | Tactic / device | Result | Premises / config |
|---|---|---|---|
| convexity of `X₁ ∪ X₂` | `rcases … <;> rcases …` + `le_total b z` | success | both `IsConvex` hypotheses, `z` in both |
| mixed-pair constraint, `x ≤ z ≤ y` | `PartialHistory.rel_across_seam` | success | `hcomp`, both seam coordinates at `z`, `hd` by `rw [add_comm]; exact (sub_add_sub_cancel y z x).symm` |
| mixed-pair constraint, `z < x` | convexity of `X₂` then `τ₂.respects_task`, after `rw [hagree x _ _]` | success | — |
| the impossible sub-case `y < z` | `by_contra` + convexity of `X₁` contradicting `¬ τ₁.domain y` | success | — the paper's "symmetrically" case collapses outright on the left-biased encoding |
| backwards orientation (`t ≤ s`) | `rw [TaskFrame.reflection_of_ne F hne, neg_sub]` then the forward step | success | `hne` from the side-split: the two sides' domain memberships differ, so `t ≠ s` |
| `t - s ≠ 0` | `sub_ne_zero_of_ne (fun h : t = s => …)` | success | the domain-membership asymmetry, no order facts |
| the two `dite` readings | `dif_pos` / `dif_neg` as whole proof terms | success | the `Decidable` instance; no unfolding lemma needed |
| uniqueness | `partialHistory_ext (funext fun t => propext (hdom t))` then the readings | success | `propext`, `funext`, proof irrelevance |
| `Extends.agree` with a mismatched domain witness | nothing needed | success | definitional proof irrelevance closes it |
| `Extends` built by `refine ⟨…, fun t ht => ?_⟩` then `rw [dif_…]` | **fail** | the `dite` is not visible through `.states` at `implicit` transparency; prove the `agree` component as its own named lemma instead and supply it as a field |
| `PartialHistory.ofLe` to halve the case split | **rejected, not attempted to completion** | it discharges the unconditional field via `FrameOver.reflection`, which measures `Classical.choice` — the four-way split is the price of the pin |
| `simp` / `aesop` / `omega` on any of the above | not used | the obligations are structural case splits over an abstract ordered group; nothing here is an automation target, and `linarith`/`ring` are unavailable this low in the import closure (recorded in `Sheaf.lean`) |

## Context Extension Recommendations

- **Topic**: the Prop-to-Type barrier when gluing dependent partial functions in this tree.
  **Gap**: `context/project/lean4/` has no note on it, yet it has now been met three times
  (`chainSup` paying `Classical.choice`, `pasteAt` escaping by disjointification, and this task
  paying a `Decidable` instance), with a different resolution each time and the choice-free
  requirement deciding between them. **Recommendation**: a short pattern note, *"Gluing partial
  functions: the three escapes and what each costs in axioms"*, cross-referencing
  `TaskFrame.reflection_of_ne` as the companion trap.
- **Topic**: making an axiom claim gated rather than prose-only. **Gap**: the C14 two-heredoc
  procedure is documented only inside `scripts/check-module-invariants.sh`'s own comments, and
  `docs/theorem-index.md`'s "every row is machine-pinned" rule is easy to violate by adding a row
  without a baseline. **Recommendation**: a few lines in the Lean operations context recording the
  "edit both heredocs, then add the row" sequence.

## Appendix

### Searches and probes

- `grep` sweeps of `possible_worlds.tex` / `appendix_cut_material.tex` for `app:gluing`,
  `rmk:choice`, `convex`, and the `% PORT:` marker; both proof texts read in full.
- `grep` sweeps of `FormalSystem/` for `IsConvex`, `partialHistory_ext`, `paste`, `chainSup`,
  `reflection_of_ne`, `app:gluing`.
- `mcp__lean-lsp__lean_local_search "PartialHistory.ext"` — returned `index: warming`, so its
  result is **not** treated as evidence of absence; the absence of a `PartialHistory` `ext` lemma
  rests on `grep` plus `Behavior.lean`'s own docstring, which states it.
- `mcp__lean-lsp__lean_loogle "Set.OrdConnected (?s ∪ ?t)"` — empty: no Mathlib lemma for the
  union of two order-connected sets sharing a point, so Step 2 is proved directly.
- `mcp__lean-lsp__lean_leansearch` — HTTP 500 on the first call; per the MCP fallback table the
  query was reissued on `lean_leanfinder`, which returned `PartialEquiv.piecewise`,
  `PartialEquiv.piecewise_apply` and `Partrec.merge` — the precedent cited for Decision 2.
- Six `lake env lean` runs of `gluing-probe.lean` through `lake-build-guard.sh`, detached. Run 1
  found two genuine slips (a reversed `rw [← hagree …]`, two mismatched mixed-case helpers); run 2
  landed Steps 1–5; runs 3–4 added the ray instance; run 5 cleared two unused-binder warnings; run
  6 added the existential-overlap clause. Final state: exit 0, no warnings, no `sorry`.

### References

- JPL paper `app:gluing` (statement + live proof), `rmk:choice`, `def:world-history`,
  `def:task-relation` (the reflection convention), and the `ρ ⌢_z σ` pasting passage in
  `appendix_cut_material.tex`
- `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory`, `IsConvex`, `Extends`,
  `rel_across_seam`, `restrict`
- `FormalSystem/Semantics/Presheaf/Behavior.lean` — `partialHistory_ext` and the recorded
  consolidation follow-up
- `FormalSystem/Semantics/Presheaf/Sheaf.lean`, `Ray.lean`, `Directed.lean` — the three landed
  cases and their measured choice records
- `FormalSystem/PlusLanguage/PlusPasting.lean` — `pasteAt`, the disjointified-seam precedent and
  the `paste_eq_pasteAt` bridge shape
- `scripts/check-module-invariants.sh` (C1/C3/C14/C15/C17), `docs/theorem-index.md`
