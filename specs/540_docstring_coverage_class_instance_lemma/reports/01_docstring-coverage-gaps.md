# Research Report: Task #540

**Task**: 540 - Docstring coverage for class, instance, and lemma declarations
**Started**: 2026-09-18T00:00:00Z
**Completed**: 2026-09-18T00:00:00Z
**Effort**: Small (about 1-2 hours): 20 docstrings across 8 files, plus a reporting-only per-keyword breakdown in C19
**Dependencies**: None
**Sources/Inputs**: - Codebase (`scripts/check-module-invariants.sh` C19/C23, the 8 affected `.lean` files), `docs/development/LEAN_STYLE_GUIDE.md`, `specs/reviews/2026-09-01-lean-engineering/A-soundness.md` (the three-register convention), git history
**Artifacts**: - specs/540_docstring_coverage_class_instance_lemma/reports/01_docstring-coverage-gaps.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task description's numbers are out of date.** C19's exact counting rule, re-run on the
  current tree (HEAD `c93bc9c31`), gives these per-keyword figures:
  - **class**: 21/21 = **100%** (was 16.3%). Already passes.
  - **lemma**: **0 declarations** (was 55.6%). Every `lemma` has been converted to `theorem`, and
    C23 now enforces "zero live `lemma` declarations". The lemma criterion is met vacuously and
    cannot regress, because C23 would fail first.
  - **instance**: 59/79 = **74.7%** (was 57.6%). **This is the only category still below the
    floor.** 20 instances are undocumented.
  - aggregate (refined): 10158/10832 = **93.78%**, up from 92.34%, so the no-regression bound
    is already met with margin.
- **The remaining work is 20 instance docstrings in 8 files.** 13 of them are enough to reach
  90% (72/79). Documenting all 20 gives 100% and moves the aggregate to 10178/10832 = 93.96%.
  Every one of the 20 has an obvious, non-trivial present-tense description. None is a throwaway
  internal step, and none is a candidate for `private`, because instance resolution consumes
  them all.
- **C19 does not currently report per-keyword figures at all.** It prints only the aggregate
  unrefined and refined lines. The per-keyword rates in the task description come from a
  one-off measurement quoted in C19's header comment, not from any C19 output. The acceptance
  criterion, "C19 reports at least 90% for each of class, instance, and lemma individually",
  therefore needs C19 to gain per-keyword INFO output. That adds reporting only: the counting
  rule, the regexes and the floor stay unchanged.
- **Recommended approach**:
  1. Add a reporting-only per-keyword breakdown to C19 (its per-declaration verdicts are
     unchanged).
  2. Refresh C19's stale header-comment figures.
  3. Write the 20 instance docstrings using the three-register convention.
  4. Verify with a build of the touched modules plus `scripts/check-module-invariants.sh --no-build`.
  No sorry, axiom or proof change is involved.

## Context & Scope

The work covers the C19 docstring-coverage check in `scripts/check-module-invariants.sh`
(lines ~3028-3175), its declaration regex and comment stripper, and every declaration of kinds
`class`, `instance` and `lemma` in non-Boneyard `FormalSystem/**/*.lean`.

The task has three constraints:
- no change to C19's counting rule;
- the aggregate must not drop below 92.34%;
- docstrings must follow the three-register convention.

The convention comes from `specs/reviews/2026-09-01-lean-engineering/A-soundness.md` (around
line 749). There are three registers:
- **(a) Doc-comments** state what the declaration means, its paper anchor, and any trap a
  caller can fall into. Present tense, no history.
- **(b) `docs/design/` notes or a module README** carry rejected alternatives and "why not X"
  arguments.
- **(c) Commit messages** carry history.

Method: the C19 Python heredoc was extracted verbatim and instrumented to tally per keyword and
to dump every declaration not credited under the refined rule. Its per-declaration logic was
left unchanged, and the aggregate lines it printed match C19's own output exactly: unrefined
9884/10832 = 91.25%, refined 10158/10832 = 93.78%.

## Findings

### Codebase Patterns

**Current per-keyword coverage** (C19 rule, current tree):

| keyword   | total | unrefined documented | refined documented | refined % | undocumented |
|-----------|------:|---------------------:|-------------------:|----------:|-------------:|
| abbrev    |   130 |                  126 |                130 |    100.0% |            0 |
| class     |    21 |                   21 |                 21 |    100.0% |            0 |
| def       |  3382 |                 3342 |               3358 |     99.3% |           24 |
| inductive |    60 |                   60 |                 60 |    100.0% |            0 |
| instance  |    79 |                   59 |                 59 |     74.7% |           20 |
| structure |   188 |                  187 |                187 |     99.5% |            1 |
| theorem   |  6972 |                 6089 |               6343 |     91.0% |          629 |
| lemma     |     0 |                    0 |                  0 |       n/a |            0 |

**Why the numbers moved** (from git history, not re-derived):
- **lemma**: the lemma-to-theorem conversion and C23's "zero live `lemma`" assertion landed
  after the per-keyword figures in C19's header comment were measured
  (`68cff8657`, "C19 docstring-coverage floor").
- **class**: later docstring sweeps (e.g. `ca9b06a48`, `054dd8b0a`, `b8502cfd2`) documented all
  classes.
- **Total count**: it grew from 10427 to 10832 over the same period.

**The 20 undocumented instances.** None of them gets credit from `/-!` sections either: refined
coverage equals unrefined coverage for this category.

| # | File:line | Instance | What it is |
|---|-----------|----------|------------|
| 1 | `Metalogic/Bundle/LimitMCS.lean:210` | `limitFilterBelow_neBot` | `NeBot` for the left-sided filter; specialises `limitFilter_neBot .below` |
| 2 | `Metalogic/Bundle/LimitMCS.lean:211` | `limitFilterAbove_neBot` | same, right side |
| 3 | `Metalogic/Decidability/BiLasso/Decide.lean:310` | `instDecidableClauseAt` | decidability of the per-formula local clause, by case split on the formula |
| 4 | `.../BiLasso/Decide.lean:325` | `instDecidableLocalCoherentAt` | decidability of `LocalCoherentAt` at each position |
| 5 | `.../BiLasso/Decide.lean:489` | `instDecidableUntlOblB` | decidability of the finite-range forward (until) obligation |
| 6 | `.../BiLasso/Decide.lean:493` | `instDecidableSnceOblB` | same, backward (since) obligation |
| 7 | `.../BiLasso/Decide.lean:701` | `instDecidableEventClauseAt` | decidability of the per-formula eventuality clause |
| 8 | `.../BiLasso/Decide.lean:710` | `instDecidableFulfilAt` | decidability of `FulfilAt` at each position |
| 9 | `Metalogic/Decidability/BiLasso/Enumerate.lean:140` | `instDecidableIsLasso` | decidability of the raw-lasso well-formedness predicate |
| 10 | `Metalogic/Decidability/Verified/Bridge/BranchOrder.lean:294` | `instDecidableBranchLT` | `DecidableRel` for the branch-time strict order |
| 11 | `Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean:258` | `instInStructureClassUnrestricted` | every structure is in `UnrestrictedClass` |
| 12 | `.../DenseModelSurgery/Defs.lean:262` | `instInStructureClassCountableDense` | a structure with countable, densely ordered carrier is in `CountableDense` |
| 13 | `Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean:50` | `ZIntervalStructure.intervalCarrierLinearOrder` | subtype order on the ℤ-interval carrier |
| 14 | `Metalogic/WeakCanonical/NormalForm.lean:69` | `atomKindDecEq` | hand-written `DecidableEq (AtomKind sig n)` |
| 15 | `Metalogic/WeakCanonical/NormalForm.lean:191` | `normalFormFintype` | first projection of the joint `normalFormFintypeAndDecEq` |
| 16 | `Metalogic/WeakCanonical/NormalForm.lean:196` | `normalFormDecEq` | second projection of the same |
| 17 | `Metalogic/WeakCanonical/RealModel/GoodDense.lean:201` | `RIntervalStructure.intervalCarrierLinearOrder` | subtype order on the ℝ-interval carrier (noncomputable) |
| 18 | `Semantics/LexCarrier.lean:110` | `instSuccOrder` | `SuccOrder (α ×ₗ ℤ)` via `lexSucc`, which advances only the ℤ component |
| 19 | `Semantics/LexCarrier.lean:130` | `instPredOrder` | `PredOrder (α ×ₗ ℤ)` via `lexPred`. Has a plain `/- -/` comment above it, **not** a `/--` doc comment, so it is uncredited |
| 20 | `Semantics/Ultraproduct/IndexFilter.lean:78` | `tailFilter_neBot` | the tail filter on finite sublists is proper |

(All paths are relative to `FormalSystem/`.)

**Draft docstrings.** These are grounded in the surrounding definitions and follow register (a):
what the declaration is, present tense, plus a caller trap where one exists. The implementer
should reword them freely.

- **1-2**:
  - `/-- The left-sided limit filter at \`r\` is proper; the \`.below\` case of \`limitFilter_neBot\`, stated at the named filter so instance search finds it without unfolding \`limitFilter\`. -/`
  - The right-sided version is the same with "right-sided" and `.above`.
  - **Trap**: these are separate instances because `limitFilterBelow r` does not syntactically
    match `limitFilter .below r` for instance search.
- **3**: `/-- Each local clause \`clauseAt P bx Lm Lt Lp w ψ\` is decidable: a case split on \`ψ\` reduces every constructor to finset membership and propositional connectives. -/`
- **4**: `/-- \`LocalCoherentAt\` is decidable at every position: \`⊥\`-freedom of the label plus a bounded quantifier over \`subformulaClosure φ\`. -/`
- **5-6**: `/-- The forward (resp. backward) eventuality obligation is decidable, because its witness ranges over the explicit finite range \`Finset.Ico\`/\`Finset.Ioo\` rather than over all of \`ℤ\`. -/`
  - **Trap**: this is exactly why the `…OblB` forms exist. The unbounded obligations are not
    decidable by this instance.
- **7**: `/-- Each eventuality clause \`eventClauseAt A t ψ\` is decidable; only \`untl\` and \`snce\` impose a (bounded) obligation, every other constructor is \`True\`. -/`
- **8**: `/-- \`FulfilAt A t\` is decidable: a bounded quantifier over \`subformulaClosure φ\` of decidable eventuality clauses. -/`
- **9**: `/-- \`IsLasso P\` is decidable: two list non-emptiness tests and a quantifier over a \`Fin\`-indexed window of \`P.step\` checks. -/`
- **10**: `/-- The branch-time strict order \`branchLT b ord\` is decidable: a Boolean \`strictBefore\` test, or equal times with a \`Fin\` tie-break. -/`
- **11**: `/-- Every structure belongs to \`UnrestrictedClass\`, so Reynolds' unrestricted quantification needs no membership witness at call sites. -/`
- **12**: `/-- A structure whose carrier is \`Countable\` and \`DenselyOrdered\` belongs to \`CountableDense\`; the membership is assembled from the two carrier instances already in scope. -/`
- **13**: `/-- The interval carrier of a \`ZIntervalStructure\` is linearly ordered by the order it inherits as a subtype of \`ℤ\`. -/`
- **17**: the same as 13 with `ℝ`, plus "noncomputable because `ℝ`'s order is". This follows the
  style guide's rule that a noncomputable declaration states why
  (`LEAN_STYLE_GUIDE.md` §587).
- **14**: `/-- Decidable equality on \`AtomKind sig n\`, by constructor case split; the \`order\` constructor's proof field is irrelevant to equality. -/`
  - Confirm this by reading the body at NormalForm.lean:69-85 before committing the wording.
- **15-16**: `/-- \`NormalForm sig k n\` is a \`Fintype\` (resp. has \`DecidableEq\`): the first (resp. second) component of \`normalFormFintypeAndDecEq\`, which builds both together by induction on \`k\`. -/`
  - **Trap**: the two cannot be derived separately, because each level's `Fintype` needs the
    previous level's `DecidableEq` and vice versa.
- **18**: `/-- \`α ×ₗ ℤ\` is a \`SuccOrder\` whose successor advances only the discrete \`ℤ\` component (\`lexSucc\`), leaving the \`α\` component fixed. -/`
- **19**: `/-- \`α ×ₗ ℤ\` is a \`PredOrder\` whose predecessor retreats only the discrete \`ℤ\` component (\`lexPred\`). -/`
  - Keep the existing `/- ... -/` rationale ("built by hand rather than through the
    `to_dual`-generated name") as an ordinary comment placed **above** the new docstring. It is
    register-(b) content, and the docstring must end within 3 lines of the `instance` line for
    C19 to credit it.
- **20**: `/-- The tail filter on finite sublists of \`Γ\` is proper: any finite family of up-sets has a common member, the concatenation of their generators. -/`

**Placement rule the implementer must respect.** C19 credits a declaration only if a `/--`
comment's closing `-/` is on one of the 3 lines immediately above the declaration line. This
has three consequences:
- **Items 1-2 (adjacent one-liners)**: each needs its own docstring directly above it, so a
  single docstring cannot cover both.
- **Attributes**: a docstring placed before an `@[...]` attribute line still counts, provided
  the attribute line is within the 3-line window.
- **Item 19**: the docstring, not the plain comment, must be the nearest block.

### External Resources

- No Mathlib lemma search was needed. The task is documentation-only and does not change any
  statement or proof. The docstrings cite existing Mathlib names already used in the code
  (`exists_rat_btwn`, `SuccOrder.ofSuccLeIff`, `Subtype.instLinearOrder`).
- `docs/development/LEAN_STYLE_GUIDE.md`, "Declaration Docstrings" (§355) and the
  noncomputable-documentation rule (§587).

### Recommendations

1. **C19 per-keyword reporting (reporting-only).** After the two existing aggregate lines, emit
   one INFO line per keyword in `(class, instance, lemma)`. If practical, emit one for every
   keyword. Each line gives the refined documented/total count and percentage, e.g.
   `INFO  C19  per-keyword (refined): instance 79/79 = 100.00%`.
   - **Zero-total keywords**: print `n/a (0 declarations; C23 forbids \`lemma\`)` instead of
     dividing by zero.
   - **Unchanged**: the per-declaration verdict (`decl_lines`, `doc_ends`,
     `section_end_lines`, the `active` scope walk) must be byte-identical.
   - **How to verify**: the aggregate lines' output before and after the edit must match.
   - **Status**: keep it reporting-only, meaning no `FAILURES` increment and no `ENFORCE_` flag.
     This matches C19's existing contract.
   - **Why it is needed**: without it, the acceptance criterion cannot be observed from C19's
     output at all.
2. **Refresh C19's header comment.** The comment block still quotes 10427 total, 89.37%/92.32%,
   and "class 16.3%, instance 57.6%, lemma 55.6%". Replace those figures with the current
   measured values, or with a pointer to the new per-keyword lines, so the comment stops
   describing a tree that no longer exists. This is a comment edit only.
3. **Write all 20 instance docstrings.** Going beyond the 13-docstring minimum is cheap, and
   100% leaves headroom against future instances.
4. **Verify.**
   - Build the 8 touched modules with `lake build` (detached, through the build guard).
     Docstring edits cannot break proofs, but a malformed `/--` or a docstring separated from
     its declaration can fail the build.
   - Then run `bash scripts/check-module-invariants.sh --no-build` and read C19's per-keyword
     lines. Expected results:
     - instance: 79/79
     - class: 21/21
     - lemma: n/a
     - aggregate (refined): >= 93.96%
   - Also confirm C23 still passes.
   - The change is sorry-free by construction, since no proof or statement changes.

**Suggested phases for the planner**:
1. C19 per-keyword reporting plus header-comment refresh, verified by identical aggregate output.
2. Docstrings in the Decidability files (items 3-10: `Decide.lean`, `Enumerate.lean`,
   `BranchOrder.lean`).
3. Docstrings in the WeakCanonical, Semantics and Bundle files (items 1-2 and 11-20).
4. Final gate: build the touched modules and run the invariants check.

These could reasonably be collapsed into two phases.

## Decisions

- **Adding per-keyword output to C19 is not a change to its counting rule.** It is required to
  make the acceptance criterion observable. The planner should keep the per-declaration logic
  untouched.
- **The lemma criterion is satisfied vacuously (0 declarations) and needs no work.** C23 already
  guarantees it stays that way.
- **No instance should be made `private` instead of documented.** Instance resolution consumes
  all 20, and C17 exempts instances for the same reason.
- **The theorem category is out of scope**: 91.0% refined, 629 undocumented. It is above the
  floor and not named in the task.

## Risks & Mitigations

- **Risk**: the per-keyword edit accidentally perturbs C19's aggregate.
  **Mitigation**: diff C19's two aggregate lines before and after. They must be identical.
- **Risk**: a docstring does not sit within 3 lines above its `instance`, most likely at item 19
  (a plain comment is in the way) or at items 1-2 (adjacent one-liners), so it is not credited.
  **Mitigation**: re-run the instrumented count, or the new per-keyword line, after editing.
- **Risk**: the tree gains new undocumented instances between research and implementation.
  **Mitigation**: the implementer re-derives the undocumented list at implementation time
  rather than trusting this table's line numbers.
- **Risk**: draft docstring wording is inaccurate. Item 14 was not read in full.
  **Mitigation**: the implementer reads each body before committing its docstring.

## Tactic Survey Results

- Not applicable (no tactic survey performed). The task changes documentation only, with no
  proof goals.

## Context Extension Recommendations

- **Topic**: docstring three-register convention.
- **Gap**: the convention is defined only in a review file
  (`specs/reviews/2026-09-01-lean-engineering/A-soundness.md`). It does not appear in
  `docs/development/LEAN_STYLE_GUIDE.md`, which still says only "every public definition,
  theorem, and structure requires a docstring", and that sentence does not mention `instance`
  or `class`.
- **Recommendation**: add a short "three registers" subsection to LEAN_STYLE_GUIDE.md
  "Declaration Docstrings", and extend its coverage sentence to name `instance` and `class`.

## Appendix

- **Measurement**: C19's heredoc was extracted verbatim from `scripts/check-module-invariants.sh`
  and instrumented with a per-keyword tally and an undocumented-declaration dump. Aggregate
  output matched C19 exactly: 9884/10832 unrefined, 10158/10832 refined.
- **Relevant C19/C23 locations**: C19 at `scripts/check-module-invariants.sh` ~3028-3175. The
  C23 zero-`lemma` assertion is at ~2514-2520.
- **Arithmetic**:
  - instance floor: ceil(0.9 × 79) = 72, so at least 13 more docstrings are needed.
  - all 20 documented: aggregate 10178/10832 = 93.96%.
