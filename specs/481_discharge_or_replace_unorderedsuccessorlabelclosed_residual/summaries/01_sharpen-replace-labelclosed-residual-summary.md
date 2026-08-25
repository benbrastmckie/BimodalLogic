# Implementation Summary: Sharpen and Replace the `UnorderedSuccessorLabelClosed` Residual

- **Task**: 481
- **Plan**: `specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/plans/01_sharpen-replace-labelclosed-residual.md`
- **Outcome**: Phases 1-5 landed; Phases 6-7 BLOCKED with a documented, evidenced obstruction.
- **Sole modified source file**: `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`
  (+674 / -11 against pre-task baseline `6b798def5`; the 11 deletions are all docstring prose).

## Bottom line

**Outcome (c) — the sharpened verdict — is complete.** The residual is now proved false at every
nonempty finite `L` at every frame class, proved true at `∅`, and the file's own prose has stopped
overstating its reach.

**Outcome (b) — the replacement — landed most of the way and then stopped at a settled shape
mismatch, not at a missing proof.** Section D4 closes the world coordinate unconditionally on a
`boxFree` branch and discharges clause 1 at `signedUniverse C L` from hypotheses that are *all
satisfiable* — strictly better than the position section C11 reached, where the reduced antecedent
was itself refutable. It does **not** reach a restated terminus. No carrier loses its `hlab`, and
all nine remain vacuous at every nonempty `L`.

## The citation a sibling task needs

```
FormalSystem.Metalogic.Decidability.unorderedSuccessorLabelClosed_nonempty_false
  : ∀ (fc : FrameClass) (L : Finset Label), L.Nonempty → ¬ UnorderedSuccessorLabelClosed fc L
```

Companions: `unorderedSuccessorLabelClosedOrd_nonempty_false` (the `Ord` form, which is the
stronger statement since `Ord` is the weaker predicate) and `unorderedSuccessorLabelClosed_empty`.
Together they pin the residual's satisfiability set to **exactly `{∅}`** — and `signedUniverse C ∅`
is itself empty, so the one label set at which the hypothesis is available is the one at which the
universe is empty.

**Consequence any dependent task must respect**: discharging `hmint`/`MintPaysForTimeFixed` at a
nonempty universe does **not** unlock the nine `signedUniverse` carriers. They stay vacuous until
`hlab` is *replaced*, and this task establishes that the replacement is harder than the plan
projected.

## What landed, by phase

| Phase | Status | Deliverable |
|-------|--------|-------------|
| 1 | COMPLETED | Label-generalized refutation family, section C11 |
| 2 | COMPLETED | Two docstring corrections + C9 entries 11/21 amended |
| 3 | COMPLETED | Section D4 opened; the `boxFree` shape gate |
| 4 | COMPLETED | World-subset machinery, mirroring D3's time machinery |
| 5 | COMPLETED WITH EXCLUSIONS | The composite; one item excluded as not stateable |
| 6 | BLOCKED | Terminus restatement — blocked on Phase 5's exclusion |
| 7 | BLOCKED | Non-vacuity — blocked transitively (register amendment done anyway) |

### Phase 1 — the refutation family (section C11)

`freshWorldWitnessAt` / `freshWorldBranchAt` / `freshWorldEmittedAt`, thirteen private `rfl`
supporting facts, `findApplicableRule_freshWorldWitnessAt`,
`expandOnceUnblocked_freshWorldBranchAt`, and the three theorems above. Placed in C11 after
`unorderedSuccessorLabelClosedOrd_not_universal` because the `Ord` predicate is defined ~5,000 lines
after the plain one; the existing single-witness `freshWorld*` family is retained beside it, not
replaced.

### Phase 2 — the prose (outcome (c) complete)

- `unorderedSuccessorLabelClosed_not_universal`: the old bracket ("refutable at some
  `signedUniverse C L`, satisfiable at others", and "holds at every `L` for which the engine never
  fires") was false in **both** halves. Replaced with the exact bracket.
- `..._signedUniverse_untlSnceFree`: vacuity note added. The section heading promises a discharge
  "at a **nonempty** universe"; the `hmint` half of that promise is kept, the `hlab` half is not.
- C9 entry 21: upgraded from "the reduced antecedent is refutable" to the direct statement that the
  residual itself is refuted at every nonempty `L`, with the explicit nine-carrier list.
- C9 entry 11: closing paragraph brought into the same register.
- **No 25th entry.** The register still opens "Twenty-four statements" and holds exactly 24.

### Phases 3-5 — the replacement route (section D4)

`boxFree` plus the shape-gate theorems close both world-minting rules before any frame-class gate is
consulted, so nothing in D4 carries a frame-class restriction. The world-subset machinery mirrors
D3's time machinery and is strictly simpler (no `OrdTimesKnown`). The composite
`unorderedSuccessor_label_mem_of_propositional` joins the two coordinates via the `TimeMergeClosed`
rectangle, and `unorderedSuccessor_confined_signedUniverse_of_propositional` is clause 1 at
`signedUniverse C L` with **no** `UnorderedSuccessorLabelClosed` argument and no frame-class
restriction.

## The obstruction, stated precisely

`UniverseClosedAt fc U`'s **clause 1** is

```
∀ b ord tr, (∀ x ∈ b, x ∈ U) → ∀ nb ∈ unorderedSuccessorBranches …, ∀ x ∈ nb, x ∈ U
```

with `ord` universally quantified and unconstrained. Every route through the **time** coordinate
carries `OrdTimesKnown b ord`, inherited through `unorderedSuccessor_knownTimes_subset` from
`applyRule_emitted_time_mem` — where `applyRule_emitted_time_mem_ordTimesKnown_needed` *proves* the
hypothesis is not removable, by deciding a configuration in which dropping it makes the statement
false. So the propositional composite discharges a strictly weaker statement than clause 1 demands,
and nothing can supply the gap at an arbitrary `ord`.

`universeClosedAt_signedUniverse_of_propositional` is therefore **not stateable**, not merely
unproved — and Phase 6's terminus, which the plan routes through it, is unreachable.

This is not a new fact about the development, only a newly load-bearing one. Section C11 already ran
into it from the other side: `UnorderedSuccessorLabelClosedOrd` exists precisely because the plain
predicate "quantifies over an arbitrary `TimeOrdering` with nothing tying it to the branch", and
C11's `unorderedSuccessor_confined_signedUniverse_of_freshLabelHeadroom` carries `OrdTimesKnown` for
the same reason and is likewise not wired into `universeClosedAt_signedUniverse_of_headroom`.

### The two routes past it, neither taken

1. **Remove `OrdTimesKnown` on this fragment.** The pick is heavily constrained on a `boxFree`,
   `untl`/`snce`-free branch: the linearity stage yields `.branchingOrdered`, hence `.splitOrdered`,
   hence *no unordered successor at all*; the seriality stage emits at the trigger's own label; and
   `orderTrichotomy`'s `fires` guard demands a `someFuture`-shaped formula already on the branch,
   which such a branch cannot carry (`someFuture φ = untl ⊤ φ`). A bespoke sweep over just the
   reachable rules might avoid the hypothesis. This is genuine new work in section D3's territory.
   **Unattempted — which is deliberately not the same verdict as refuted, and is recorded as such in
   the source file.**
2. **Thread `OrdTimesKnown` through the closure chain.** An `Ord`-flavoured `UniverseClosedAt`, then
   the same for `DifficultyBounded`, then every consumer of both down to `buildTableauAt` — roughly
   twenty theorem restatements across the `_at`, `_selfGuarded` and `_fixed` families.
   `DifficultyBounded` carries its own refutations and register entries, so this is a redesign of
   the closure interface rather than an addition to it.

The obstruction is recorded **in the source**, not only here: section D4 carries a dedicated
`### The boundary: why this section stops here` block, and C9 entry 21 records the same verdict.

## Scope Hypothesis results

| Phase | Hypothesis | Result |
|-------|-----------|--------|
| 1 | ~150 new lines | **Refined**: 180 insertions, 0 deletions |
| 1 | Exactly fourteen `rfl` facts | **Refined**: thirteen new; the fourteenth (`ruleMintsFreshLabel .boxNeg = true`) mentions no label and the in-file `rm_bn` was reused. Every one of the thirteen closes by `rfl` with the label free, so the mechanicality claim holds |
| 1 | Both engine lemmas' scripts transfer unchanged | **Confirmed**, character for character apart from renames |
| 1 | C11 has both predicates in scope | **Confirmed** |
| 2 | Exactly nine carriers | **Confirmed**. 37 total occurrences, all in `MintBound.lean`; no tenth carrier, none in any other module |
| 2 | Entries 11 and 21 are the only two covering it; no 25th warranted | **Confirmed**; register unchanged at 24 |
| 3 | Exactly two world-minting rules | **Confirmed**. `applyRule_emitted_world_mem` carries exactly `rule ≠ .boxNeg` and `rule ≠ .diamondPos` and no others |
| 4 | All three D3 declarations mirror without structural change; `pick_branches_eq` transfers | **Confirmed**; built first try. The predicted `OrdTimesKnown` asymmetry holds |
| 5 | `TimeMergeClosed L` alone closes all four label quadrants | **Confirmed**. Proved standalone first, as instructed; compiled first try; no hypothesis added |
| 6 | The terminus needs exactly the eight listed hypotheses | **Not reached** — the terminus is unreachable |
| 7 | A nonempty `boxFree` + `untlSnceFree` stock exists and `signedUniverse_nonempty` is reusable | **Not reached** — blocked transitively |

## Plan Deviations

- **Phase 1, altered**: thirteen new `rfl` facts rather than fourteen (`rm_bn` reused — it is
  label-independent); the local simp set still has fourteen members. The explanatory doc comment
  above the `attribute` line had to become a `--` comment, since Lean rejects `/-- -/` on an
  `attribute` command. `Option.isNone_none` dropped from one `simp only` as an unused argument.
- **Phase 2, altered**: the vacuity note on the `_untlSnceFree` docstring deliberately does not name
  section D4, because at Phase 2 close that section did not exist and Phases 3-7 were optional. The
  D4 pointer was added at the end, via the C9 entry 21 amendment.
- **Phase 3, altered**: `asDiamond?` dropped from the probe's second `simp_all` inside
  `asDiamond_eq_none_of_boxFree` (in-tree `unusedSimpArgs` linter). Otherwise verbatim from the probe.
- **Phase 5, altered**: `unorderedSuccessor_confined_signedUniverse_of_propositional` carries
  `OrdTimesKnown b ord` in its quantifier prefix, which the `_of_headroom` original does not. See
  the obstruction above; C11's `..._of_freshLabelHeadroom` is the in-file precedent.
- **Phase 5, skipped**: `universeClosedAt_signedUniverse_of_propositional` — not stateable. Recorded
  in the plan's `#### Reasoned Exclusions` table.
- **Phases 6 and 7, blocked**: documented in the plan with full blocker entries.
- **Phase 7, partially completed anyway**: the C9 entry 21 register amendment was executed as part
  of the blocker record, since the register is the durable in-tree home for the finding.

## Verification at task close

- `lake build` exits 0; `lake build BimodalTest` exits 0.
- `bash scripts/check-module-invariants.sh` — **ALL CHECKS PASSED**, identical to the pre-task
  baseline (C1, C2 flagship axiom sets, C3 zero structural `sorry`, C9 zero task-number citations
  under `FormalSystem/`, C10, C4-C8, C11).
- Every new public theorem: axioms `[propext, Classical.choice, Quot.sound]` only. No new axiom;
  `MintBound.lean` declares zero axioms.
- Zero `sorry` added. Zero vacuous definitions added.
- All nine carriers verified **byte-identical** against pre-task baseline `6b798def5`
  (programmatic comparison, not eyeball).
- `Fuel.lean`, `Saturation.lean`, `Tableau.lean` — untouched (`git diff --stat` empty).
- C9 register: still opens "Twenty-four statements", still exactly 24 numbered entries.
- No new global `@[simp]` attribute; the fourteen supporting facts are `private` with
  `attribute [local simp]`.
- No frame-class restriction on any new statement.

## Recommended follow-up

One task, not two: **decide the `OrdTimesKnown`/`UniverseClosedAt` shape mismatch**. Route 1
(a restricted-rule-set re-derivation of `applyRule_emitted_time_mem` on the propositional fragment)
is the cheaper of the two and is unattempted; if it succeeds, Phases 6 and 7 of this plan become
reachable as written. Route 2 is an interface redesign and should not be started without deciding
route 1 first.
