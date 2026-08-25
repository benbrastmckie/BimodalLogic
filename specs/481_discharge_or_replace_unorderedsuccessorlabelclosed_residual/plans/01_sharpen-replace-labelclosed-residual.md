# Implementation Plan: Sharpen and Replace the `UnorderedSuccessorLabelClosed` Residual

- **Task**: 481 - discharge_or_replace_unorderedsuccessorlabelclosed_residual
- **Status**: [IMPLEMENTING]
- **Effort**: 9 hours
- **Dependencies**: 434 (established the residual set this belongs to; already complete)
- **Research Inputs**: `specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/01_unorderedsuccessorlabelclosed-verdict.md`
- **Artifacts**: plans/01_sharpen-replace-labelclosed-residual.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/git-workflow.md`
  - `.claude/rules/no-task-references-in-deliverables.md`
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research phase settled the verdict with compiled evidence: `UnorderedSuccessorLabelClosed fc L`
is **false at every nonempty finite `L`, at every frame class** — its satisfiability set is exactly
`{∅}` — so outcome (a) is refuted and nine in-tree theorems that carry it as a live hypothesis are
vacuous conditionals wherever their universe is nonempty. This plan lands that sharpened verdict in
`MintBound.lean` (outcome (c), by **amending** C9 entries 11 and 21 rather than adding a 25th
entry), then lands the `StepLengthBounded`-style replacement (outcome (b)): a `boxFree` stock
condition that closes the world-minting escape at the shape gate, mirroring the landed section D3.

Every load-bearing new statement in Phases 1 and 3 has already been compiled against the real module
(`probes/Probe1.lean`, `probes/Probe2.lean`, `probes/Probe3.lean`) — those are proved artifacts to be
**upstreamed, not re-derived**. Definition of done: `lake build` green, zero `sorry`, zero new axiom,
no regression to any currently-passing `check-module-invariants.sh` check, and every nine-carrier
statement left byte-identical.

**Phases 1-2 together are a complete, valid deliverable against the task's acceptance criteria**
(outcome (c) reached and recorded). Phases 3-7 add outcome (b) on top and are additive; stopping
after Phase 2 is a legitimate, non-partial outcome, not a shortfall.

### Research Integration

- The exact carrier list (nine declarations, at `MintBound.lean` lines 6224, 6432, 6472, 6498,
  10061, 10092, 11040, 11059, 12761) drives Phase 2's docstring work and Phase 6's restatement scope.
- The task description's premise of a NEW 25th C9 entry is refuted by the report: entries 11 (:12889)
  and 21 (:13266) already cover this residual. Phase 2 **amends**; it does not add.
- The task description's carrier line `:6215` is wrong; the named theorem
  `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` is at `:6498`.
- Frame class is **not** a discriminating dimension. Every statement in the refutation chain is
  universally quantified in `fc`. No phase below introduces a frame-class restriction.
- The report's §5.4 enumerates the Phase 4-6 mirror targets by their D3 counterparts, which is why
  those phases are proof-engineering rather than open mathematics.

### Prior Plan Reference

No prior plan. This is the first plan for this task.

### Roadmap Alignment

No `roadmap_path` was supplied and no `specs/ROADMAP.md` was consulted. No roadmap phases are
included.

## Goals & Non-Goals

**Goals**:
- Land the label-generalized refutation family so that `¬ UnorderedSuccessorLabelClosed fc L` is a
  theorem at every nonempty `L`, and `UnorderedSuccessorLabelClosed fc ∅` is a theorem.
- Amend C9 entries 11 and 21 from "refutable at some `L`" to "refuted at every nonempty `L`,
  satisfiable exactly at `∅`", with the explicit nine-carrier list.
- Correct the two docstrings the report identifies as now-false or now-misleading:
  `unorderedSuccessorLabelClosed_not_universal` (:6236 region) and
  `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree` (:12750 region).
- Land the `boxFree` replacement route: shape-gate theorems, world-subset machinery, the composite
  label lemma at the propositional fragment, and a terminus restatement with `hlab` **gone**.
- Establish non-vacuity of the restated terminus at the same standard section D3 already meets.

**Non-Goals**:
- Discharging `UnorderedSuccessorLabelClosed` itself. It is refuted; no phase attempts it.
- Touching `hSL : StepLengthBounded` or `hpb : PostBlockingSettles`. They are out of scope
  everywhere below and no phase may weaken, restate, or claim progress on them.
- Discharging `hmint`/`MintPaysForTimeFixed` at a nonempty universe. That is a separate task's
  charter; this plan only supplies the citation that task needs.
- Adding a 25th C9 register entry. The register stays at 24 entries.
- Editing the md5-pinned frozen files `Fuel.lean`, `Saturation.lean`, `Tableau.lean`.
- Altering any previously-landed declaration's statement or proof. All new material is additive.
- Extending the replacement beyond the propositional fragment. §5.5 of the report proves the
  narrowing is forced, not a proof weakness.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Placement error: `UnorderedSuccessorLabelClosedOrd` is defined at `:11306`, **after** the plain predicate at `:6209`, so the `Ord`-form refutation cannot be stated near `:6236` | H | H | Phase 1 places the entire new family in section C11, immediately after `unorderedSuccessorLabelClosedOrd_not_universal` (`:11353`) and before `## C12` (`:11374`), where both predicates are in scope. Phase 2's earlier docstrings cite the C11 names as forward references — the file already does this (`:6111` cites section C11) |
| Re-deriving the probes instead of consuming them, burning a phase on already-proved work | M | M | Phases 1 and 3 state explicitly that the probe bodies transfer verbatim; the implementer's first action is to open the probe file, not to write a proof |
| Line numbers in this plan drift once Phase 1 inserts ~150 lines | M | H | Every target below is named by **declaration name and section heading** as well as line; after Phase 1, re-locate by `grep -n` on the declaration name, never by the line number recorded here |
| Phase 5's composite is harder than "mechanical" — a label is a pair and four quadrants must be covered | H | M | `TimeMergeClosed L` is already a sibling hypothesis at every carrier and `timeMergeClosed_iff_product` (`:5727`) characterizes it as exactly the rectangle needed. If the composite still resists, stop at Phase 4 and record the obstruction with evidence; Phases 1-2 already satisfy acceptance |
| Restated terminus (Phase 6) turns out vacuous — a stock that is both `boxFree` and `untlSnceFree` and also `TableauClosed`/`TrichStock` may be hard to exhibit | H | M | Phase 7 is a dedicated non-vacuity phase held to exactly D3's standard (`signedUniverse_nonempty` + a nonempty concrete stock satisfying the syntactic conditions). D3 does **not** discharge `TableauClosed`/`TrichStock` at its concrete stock and Phase 7 is not required to either. Do not scope-creep into that |
| A new global `simp` attribute or a name collision breaks downstream modules | M | L | No phase adds a global `@[simp]`. The 14 supporting facts are `private` with `attribute [local simp]`, exactly as the probe has them. Full `lake build` at every phase close catches a collision |
| Task-number citations leak into `MintBound.lean` docstrings, failing invariant check C9 | M | L | `check-module-invariants.sh` C9 asserts zero task-number citations under `FormalSystem/`. Every phase below cites declaration names and section letters only — never a task number |
| Downstream artifacts continue to describe the `signedUniverse` termini as carrying one residual fewer, which is vacuous until Phase 6 lands | M | M | Phase 2's docstring correction on the `untlSnceFree` terminus is the in-tree record; the wrap-up must name `unorderedSuccessorLabelClosed_nonempty_false` as the citation any sibling task must use |

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

Phases within the same wave can execute in parallel. This plan is fully sequential by design: every
phase edits the same file (`MintBound.lean`), so parallel waves would create line-offset conflicts in
a single 13,442-line file with no benefit.

---

### Phase 1: Label-generalized refutation family in section C11 [COMPLETED]

**Goal**: `UnorderedSuccessorLabelClosed` and `UnorderedSuccessorLabelClosedOrd` are proved false at
every nonempty finite `L` at every frame class, and proved true at `∅`, so the residual's
satisfiability set is pinned to exactly `{∅}` in-tree.

**Tasks**:
- [x] Read `specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/probes/Probe2.lean`
      in full before writing any Lean. Its bodies transfer; do not re-derive them.
- [x] Locate the insertion point: section C11, after `unorderedSuccessorLabelClosedOrd_not_universal`
      (currently `:11353`) and before the `/-! ## C12` heading (currently `:11374`). Confirm by
      `grep -n "unorderedSuccessorLabelClosedOrd_not_universal\|## C12" <file>` rather than by the
      line numbers recorded here.
- [x] Open a new `/-! ### ... -/` subsection heading in the file's established register, stating in
      two or three sentences that the refutation the file already records at one witness `L`
      generalizes to every nonempty `L`, and why the generalization is mechanical (the engine's shape
      gates match on sign and formula constructor, never on the label).
- [x] Add the label-generalized witness family beside — never replacing — the existing `freshWorld*`
      family: a private atom, `gWitness (l : Label)`, `gBranch (l : Label)`, `gEmitted (l : Label)`.
      Choose names in the file's own idiom (e.g. `freshWorldWitnessAt` / `freshWorldBranchAt` /
      `freshWorldEmittedAt`); the probe's `g*` names are scratch names, not a naming proposal.
- [x] Add the fourteen `private theorem` `rfl` facts (`g_ia_ug` … `g_tw_bn` in the probe), then the
      `attribute [local simp]` line over them. *(deviation: altered — **thirteen** new facts, not
      fourteen. The probe's `g_rm_bn` (`ruleMintsFreshLabel .boxNeg = true`) mentions neither the
      witness nor a label, so the in-file `rm_bn` is reused instead of restated; the local simp set
      still has fourteen members. Also altered: the explanatory doc comment above the `attribute`
      line had to become a `--` comment, since Lean rejects a `/-- -/` doc comment on an
      `attribute` command.)*
- [x] Add `findApplicableRule_gWitness` and `expandOnceUnblocked_gBranch` (renamed to match the
      witness family). Their proof scripts transfer character for character.
- [x] Add `unorderedSuccessorLabelClosedOrd_nonempty_false` — the `Ord` form, which is the stronger
      statement since `Ord` is the weaker predicate.
- [x] Add `unorderedSuccessorLabelClosed_nonempty_false`, derived from the `Ord` form via the landed
      `unorderedSuccessorLabelClosedOrd_of_unorderedSuccessorLabelClosed` (`:11313`). Prefer the
      one-line derivation (Probe2's `unorderedSuccessorLabelClosed_nonempty_false'`) over Probe2's
      duplicated direct proof, so the file carries one refutation argument rather than two.
- [x] Add `unorderedSuccessorLabelClosed_empty`, completing `{∅}` as the exact satisfiability set.
- [x] Give each new public theorem a docstring in the file's register, stating the result and the
      one-line reason (`.boxNeg` emits at `Branch.nextWorld = l₀.world + 1`, outside `L`'s world
      projection by maximality of `l₀`).
- [x] Verify: `lake build` green, `grep` confirms no `sorry` added, `#print axioms` on the two new
      refutation theorems shows only `[propext, Classical.choice, Quot.sound]`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis result** (recorded at implementation time): (i) **refined** — 180 insertions,
not ~150 (`git diff --stat`, zero deletions). (ii) **refined** — thirteen new `rfl` facts, not
fourteen; each closed by `rfl` with the label a free variable, so the mechanicality claim holds.
(iii) **confirmed** — both engine lemmas' proof scripts transferred character for character apart
from the renames. (iv) **confirmed** — both predicates are in scope at the C11 insertion point.

**Scope Hypothesis**: This phase asserts (i) ~150 new lines, (ii) exactly fourteen `rfl`-provable
supporting facts, (iii) that both engine lemmas' proof scripts transfer unchanged, and (iv) that the
C11 insertion point has both predicates in scope. Confirm at implementation time by: building after
the fourteen facts land (each must close by `rfl` with the label a free variable — if any does not,
the mechanicality claim is false and must be recorded, not worked around); building after each engine
lemma (if a script needs editing, note the edit in the summary); and reading the actual line count
from `git diff --stat` rather than restating this estimate.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive block inside
  section C11, between `unorderedSuccessorLabelClosedOrd_not_universal` and the `## C12` heading.

**Verification**:
- `lake build` exits 0.
- The two refutation theorems and the `∅` theorem elaborate with no `sorry` and no new axiom.
- No previously-landed declaration's text changed: `git diff` shows insertions only in the C11 range.

---

### Phase 2: Docstring corrections and C9 entries 11/21 amendment [COMPLETED]

**Goal**: The file's own prose stops overstating the residual's reach. Entry 21 records the sharpened
verdict and the nine-carrier list; entry 11's closing paragraph is brought into the same register; the
two misleading docstrings are corrected. This phase, together with Phase 1, is the complete outcome-(c)
deliverable.

**Tasks**:
- [x] Correct `unorderedSuccessorLabelClosed_not_universal`'s docstring (currently at the `:6236`
      region; re-locate by declaration name). It currently claims the residual "holds at every `L` for
      which the engine never fires" as if that were a substantive class, and brackets it as
      "refutable at some `signedUniverse C L` … satisfiable at others". Both readings are now false.
      Replace with the exact bracket: refuted at every nonempty `L`, satisfiable exactly at `∅`,
      citing the Phase 1 theorem names. Leave the theorem's **statement and proof byte-identical** —
      it remains the single-witness form and is not withdrawn.
- [x] Add the vacuity note to
      `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`'s docstring (currently
      the `:12750` region). It is presented as "the residual, discharged at a nonempty concrete
      universe", but it still carries `hlab`, so at every `L` where the universe is in fact nonempty
      it is a **vacuously true conditional**. Say so in the register `MintBound.lean:5711-5713` uses
      for `DifficultyBounded` ("a residual nobody can satisfy makes its theorem a true conditional
      with no reach"). Do not alter the theorem's statement or proof.
- [x] Amend C9 entry 21 (`:13266`, "Discharging `UnorderedSuccessorLabelClosed` now that the time
      coordinate has landed"): upgrade "the reduced antecedent is refutable" to the direct statement
      that the residual **itself** is refuted at every nonempty `L`, citing the Phase 1 theorem names,
      and note that the satisfiability set is exactly `{∅}`. Add the explicit nine-carrier list
      (`unorderedSuccessor_confined_signedUniverse_of_headroom`,
      `universeClosedAt_signedUniverse_of_headroom`,
      `buildTableauAt_isSome_of_lengthBudget_signedUniverse`,
      `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse`, the two `_selfGuarded` siblings,
      the two `_fixed` siblings, and `..._untlSnceFree`) by declaration name, never by line number,
      and state that each is vacuous at every nonempty `L`.
- [x] Amend entry 11's closing paragraph (`:12889` region, the "*And the label coordinate is not open
      either*" paragraph) into the same register, so the two entries agree rather than one implying a
      weaker fact than the other.
- [x] Do **not** add a 25th entry. Confirm the register's opening sentence still reads
      "Twenty-four statements" and that the count is unchanged.
- [x] Confirm no task number appears in any added prose (invariant check C9 asserts zero task-number
      citations under `FormalSystem/`).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis result** (recorded at implementation time): (i) **confirmed** — exactly nine
`hlab : UnorderedSuccessorLabelClosed fc L` carriers, and they are exactly the nine the plan names.
The full census (`grep -rn "UnorderedSuccessorLabelClosed" FormalSystem/ Tests/`) finds 37
occurrences, all inside `MintBound.lean`: the two predicate definitions, the `_of_` implication, the
four refutation/`∅` theorems, the nine `hlab` hypotheses, and prose. No tenth carrier, and no
occurrence in any other module. (ii) **confirmed** — entries 11 and 21 are the only two register
entries covering this residual; no 25th entry was added and the register still opens "Twenty-four
statements" with exactly 24 numbered entries.

Additional finding recorded here rather than propagated: one deviation from the plan's Phase 2 text
— the vacuity note added to the `_untlSnceFree` docstring deliberately does **not** name section D4,
because at Phase 2 close that section does not exist and Phases 3-7 are optional. The D4 pointer is
added in Phase 7 if and only if D4 lands.

**Scope Hypothesis**: This phase asserts (i) exactly nine carriers and (ii) that entries 11 and 21
are the only two register entries covering this residual, so no 25th is warranted. Confirm at
implementation time by `grep -n "UnorderedSuccessorLabelClosed" MintBound.lean` and checking every hit
against the nine-carrier list plus the definition, the refutations, and the register entries; if a
tenth carrier appears, the list is wrong and must be corrected here rather than propagated.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — docstring text at the
  `unorderedSuccessorLabelClosed_not_universal` and `..._untlSnceFree` declarations; register prose in
  C9 entries 11 and 21.

**Verification**:
- `lake build` exits 0 (Lean docstrings compile; an unbalanced `/--`/`-/` breaks the file).
- `git diff` touches only comment and docstring regions — no declaration statement or proof changed.
- `bash scripts/check-module-invariants.sh` passes at least every check it passed before this phase,
  C9 (task-number citations) included.

---

### Phase 3: The `boxFree` shape gate — new section D4 [COMPLETED]

**Goal**: The world-minting escape route is closed at the shape gate, before any frame-class gate is
consulted, so the replacement carries **no** frame-class restriction.

**Tasks**:
- [x] Read `specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/probes/Probe3.lean`
      in full. All four theorems compiled first try; transfer them.
- [x] Open a new section `/-! ## D4. ... -/` immediately after section D3's last declaration
      (`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`, currently `:12786`)
      and before the `/-! ## C9` heading (currently `:12787`).
- [x] Write the section docstring in D3's own register (compare `:12377-12419`): what the section
      delivers, why the two escape routes are the only two, and — critically — a **"What this is not"**
      paragraph stating that combining `boxFree` with `untlSnceFree` collapses the stock to the purely
      propositional fragment, that this narrowing is **forced** rather than a proof weakness
      (`freshWorldHeadroom_not_universal` proves no condition on a finite `L` can absorb a fresh
      world), and that no downstream artifact may read the propositional discharge as a general one.
- [x] Add `def boxFree : Formula → Bool`, stated on raw constructors (mirroring `untlSnceFree`'s
      own justification for that choice), with a docstring saying it is *sufficient* rather than
      necessary.
- [x] Add `asDiamond_eq_none_of_boxFree`, `isApplicable_boxNeg_false_of_boxFree`,
      `isApplicable_diamondPos_false_of_boxFree`, and `findApplicableRule_not_worldMinting`.
      *(deviation: altered — the probe's second `simp_all [asDiamond?, boxFree]` inside
      `asDiamond_eq_none_of_boxFree` triggers the `unusedSimpArgs` linter in-tree; `asDiamond?` was
      dropped from that one call. Proof otherwise character-for-character from the probe.)*
- [x] State in the `findApplicableRule_not_worldMinting` docstring that `.boxNeg` is gated by
      `isApplicable`'s `| .boxNeg, .neg, .box _ => true` arm and `.diamondPos` by `asDiamond? φ`,
      whose only matching pattern also contains a `.box` node — the structural reason the discharge
      carries no frame-class restriction.
- [x] Verify: `lake build` green; no `sorry`; no new axiom.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis result** (recorded at implementation time): **confirmed**.
`applyRule_emitted_world_mem`'s signature carries exactly two inequality hypotheses,
`(h1 : rule ≠ .boxNeg)` and `(h2 : rule ≠ .diamondPos)`, and no others — so the census is exactly
two and `findApplicableRule_not_worldMinting`'s conclusion is complete. No third world-minting rule
exists. Confirmed additionally that `boxFree` collides with no existing name anywhere in
`FormalSystem/` or `Tests/`. All four theorems transferred from the probe; one deviation, noted on
the checklist item below.

**Scope Hypothesis**: This phase asserts that exactly two rules (`.boxNeg`, `.diamondPos`) can emit
at a fresh world, per `applyRule_emitted_world_dichotomy` and `applyRule_emitted_world_mem`'s
hypotheses `rule ≠ .boxNeg`, `rule ≠ .diamondPos`. Confirm at implementation time by reading
`applyRule_emitted_world_mem`'s signature (currently `:2223`) — its two inequality hypotheses are the
authoritative census. If a third world-minting rule exists, `findApplicableRule_not_worldMinting`'s
conclusion is incomplete and the whole route must be re-scoped, not patched.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — new section D4 between
  D3's last declaration and the C9 register heading.

**Verification**:
- `lake build` exits 0; all four theorems elaborate.
- The C9 register heading still opens section C9 and the register's entry count is unchanged.

---

### Phase 4: The world-subset machinery — mirror of D3's time machinery [IN PROGRESS]

**Goal**: `unorderedSuccessor_worldFinset_subset`: no unordered successor of a `boxFree` branch
carries a new world — the world-coordinate mirror of the landed
`unorderedSuccessor_knownTimes_subset` (`:12619`).

**Tasks**:
- [ ] Read the three D3 declarations being mirrored, in order: `pick_stage_source_noMint` (`:12544`),
      `pickBranches_knownTimes_subset` (`:12594`), `unorderedSuccessor_knownTimes_subset` (`:12619`).
      They are a line-for-line template.
- [ ] Add `pick_stage_source_noWorldMint`, the mirror of `pick_stage_source_noMint`. Stage 1 uses
      Phase 3's `findApplicableRule_not_worldMinting`. Stages 2 and 3 run exactly one rule each
      (`serialityRule` via `findApplicableSerialRule_rule`, `timeLinearity` via
      `findApplicableLinearityRule_rule`), and neither is `.boxNeg` or `.diamondPos` — both close by
      `rfl` on the rule identity, exactly as the D3 original closes its `ruleMintsFreshTime` obligation.
- [ ] Add `pickBranches_worldFinset_subset`, the mirror of `pickBranches_knownTimes_subset`, using
      `applyRule_emitted_world_mem` (`:2223`) in place of `applyRule_emitted_time_mem`. Note the
      asymmetry in the implementer's favour: the world lemma carries **no** `OrdTimesKnown`
      hypothesis where its time twin does, so this mirror is strictly simpler than its template.
- [ ] Add `unorderedSuccessor_worldFinset_subset`, routed through the same `pick_branches_eq` so the
      three-stage pick is not destructured a second time.
- [ ] Docstring each in D3's register, and state the `OrdTimesKnown` asymmetry rather than leaving a
      reader to wonder why the mirror is shorter.
- [ ] Verify: `lake build` green; no `sorry`; no new axiom.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that all three D3 declarations mirror without structural
change and that `pick_branches_eq` applies unchanged. Confirm at implementation time per declaration:
each must build before the next is started. If `pick_branches_eq` does not transfer, stop and record
that as a genuine obstruction — do not re-destructure the three-stage pick by hand.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D4, after
  Phase 3's block.

**Verification**:
- `lake build` exits 0.
- `unorderedSuccessor_worldFinset_subset` has no frame-class hypothesis and no `OrdTimesKnown`
  hypothesis beyond what its statement genuinely needs.

---

### Phase 5: The composite label lemma at the propositional fragment [NOT STARTED]

**Goal**: `unorderedSuccessor_label_mem_of_propositional` and its `signedUniverse` consequences: with
both coordinates closed and `TimeMergeClosed L` supplying the rectangle, an unordered successor of a
confined branch has every label in `L` — **with no residual hypothesis**.

**Tasks**:
- [ ] Read `unorderedSuccessor_label_mem_of_headroom` (`:11254`) and
      `unorderedSuccessor_confined_signedUniverse_of_freshLabelHeadroom` (`:11279`) as the shape
      template — this composite is the same assembly with the two subset facts in place of
      `FreshLabelHeadroom`.
- [ ] Add `unorderedSuccessor_label_mem_of_propositional`: from Phase 4's world subset, the landed
      `unorderedSuccessor_knownTimes_subset` (time subset), `TimeMergeClosed L`, and confinement of
      `b` to `L`, conclude every successor label is in `L`. The four-quadrant problem C9 entry 21
      warns about is paid for by `TimeMergeClosed L` — `timeMergeClosed_iff_product` (`:5727`)
      characterizes it as exactly "`L` is a full rectangle", which is precisely the cross-product
      closure the pair-valued label needs. Cite that in the docstring so a reader does not re-derive
      the worry.
- [ ] Add `unorderedSuccessor_confined_signedUniverse_of_propositional`: the mirror of
      `unorderedSuccessor_confined_signedUniverse_of_headroom` (`:6224`) with `hlab` replaced by the
      syntactic conditions. The formula coordinate is discharged as before by
      `unorderedSuccessor_formula_mem` from `hC`/`hT`.
- [ ] Add `universeClosedAt_signedUniverse_of_propositional`: the mirror of
      `universeClosedAt_signedUniverse_of_headroom` (`:6432`) with `hlab` gone.
- [ ] Leave `unorderedSuccessor_confined_signedUniverse_of_headroom` and
      `universeClosedAt_signedUniverse_of_headroom` **byte-identical**. The new theorems are
      additional declarations stated beside them, exactly as
      `UnorderedSuccessorLabelClosedOrd` was stated beside `UnorderedSuccessorLabelClosed`.
- [ ] Verify: `lake build` green; no `sorry`; no new axiom; the two new `signedUniverse` theorems have
      no `hlab` argument and no frame-class restriction.

**Timing**: 1.75 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that `TimeMergeClosed L` alone closes all four label
quadrants given the two per-coordinate subset facts. Confirm at implementation time by proving
`unorderedSuccessor_label_mem_of_propositional` first, standalone, before touching the two
`signedUniverse` consequences: if the rectangle does not close the quadrants, that is a genuine
obstruction to be recorded with evidence — stop the phase at that point rather than adding a new
hypothesis to force it through, since a new hypothesis would reintroduce exactly the unsatisfiable-
residual failure mode this task exists to remove.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D4, after
  Phase 4's block.

**Verification**:
- `lake build` exits 0.
- The two new `signedUniverse` theorems take `hC`, `hT`, `hL : TimeMergeClosed L`, and the two
  syntactic conditions — and take no `UnorderedSuccessorLabelClosed` argument.
- `git diff` shows the two `_of_headroom` originals untouched.

---

### Phase 6: Terminus restatement with `hlab` gone [NOT STARTED]

**Goal**: A seed-level terminus whose `hlab` argument is genuinely absent — not discharged from a
false hypothesis — carrying **two** named residuals fewer than the `_fixed` sibling it mirrors.

**Tasks**:
- [ ] Read `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree` (`:12761`) as the
      statement template. The restatement is that theorem with `hlab` deleted and a `boxFree`
      condition on `C` added.
- [ ] Add the restated terminus, routed through Phase 5's
      `universeClosedAt_signedUniverse_of_propositional` and the landed
      `mintPaysForTimeFixed_signedUniverse_untlSnceFree`. It should carry: `hC`, `hT`,
      `hL : TimeMergeClosed L`, `hSL : StepLengthBounded`, `hpb : PostBlockingSettles`, the
      `untlSnceFree` condition on `C`, the new `boxFree` condition on `C`, and `hseed` — and **no**
      `hlab` and **no** `hmint`.
- [ ] Add the intermediate `buildTableauAt_isSome_of_lengthBudget_*` form as well if the seed-level
      form needs it, mirroring the `:6472`/`:6498` pairing. Do not add the `_selfGuarded` or `_fixed`
      variants; they are out of scope.
- [ ] Docstring it in the register `:12748-12752` uses: state plainly that the two remaining named
      residuals are `StepLengthBounded` and `PostBlockingSettles`, and that this section says nothing
      about them.
- [ ] Leave all nine carriers byte-identical. Confirm by `git diff`.
- [ ] Verify: `lake build` green; no `sorry`; no new axiom.

**Timing**: 1.25 hours

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the restated terminus needs exactly the eight hypotheses
listed above. Confirm at implementation time by reading the elaborated signature back from the built
module (`#check` or hover) rather than trusting the list here; record any extra hypothesis in the
summary rather than silently accepting it, since an unlisted extra hypothesis may itself be a new
residual.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D4, after
  Phase 5's block.

**Verification**:
- `lake build` exits 0.
- `#print axioms` on the new terminus shows only `[propext, Classical.choice, Quot.sound]`.
- The new terminus's signature contains no `UnorderedSuccessorLabelClosed` and no
  `MintPaysForTime*` argument.

---

### Phase 7: Non-vacuity, the boundary docstring, and the register's closing amendment [NOT STARTED]

**Goal**: The Phase 6 terminus is shown to apply at a genuinely nonempty universe, at exactly the
standard section D3 already meets, and the register records that the replacement landed and how far
its reach goes.

**Tasks**:
- [ ] Read D3's non-vacuity block (`:12717-12760`) as the template: `signedUniverse_nonempty`
      (already landed and reusable), a concrete stock, the stock's syntactic-condition theorem, and
      the stock's nonemptiness.
- [ ] Add a concrete propositional stock — the purely propositional fragment (`atom`/`bot`/`imp`).
      Note explicitly in its docstring that `modalWitnessStock` (`:12732`) does **not** qualify,
      because it contains `□p`; a reader reaching for it has already been here.
- [ ] Add the stock's `boxFree` theorem and its `untlSnceFree` theorem, plus its nonemptiness.
- [ ] Add the concrete instantiation of the Phase 6 terminus at that stock, mirroring
      `mintPaysForTime_modalWitness` (`:12750`).
- [ ] Do **not** attempt to discharge `TableauClosed`/`TrichStock` at the concrete stock. D3 does not,
      and matching D3's standard is the bar. If it turns out to be cheap, it may be added — but it is
      not a completion condition and must not consume the phase.
- [ ] Amend C9 entry 21's "*What is not withdrawn*" paragraph one final time: record that the
      world coordinate now has an `L`-side replacement route in section D4, that it reaches only the
      propositional fragment, and that the narrowing is forced by `freshWorldHeadroom_not_universal`
      rather than being a proof weakness. Still **no** 25th entry.
- [ ] Final gate: `lake build` green, `lake build BimodalTest` green, and
      `bash scripts/check-module-invariants.sh` passing every check it passed at the pre-task baseline.

**Timing**: 1 hour

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that a nonempty stock satisfying both `boxFree` and
`untlSnceFree` exists and that `signedUniverse_nonempty` is reusable unchanged. Confirm at
implementation time by proving the stock's two syntactic-condition theorems before writing the
instantiation; if no such stock is exhibitable, the Phase 6 terminus is vacuous and that fact must be
recorded prominently in the summary rather than the terminus being presented as a discharge.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D4 non-vacuity
  block, plus C9 entry 21 prose.

**Verification**:
- `lake build` exits 0 and `lake build BimodalTest` exits 0.
- `bash scripts/check-module-invariants.sh` reports no check failing that passed at baseline.
- The concrete instantiation elaborates, establishing the terminus is not vacuous at the stock.

---

## Testing & Validation

- [ ] `lake build` exits 0 after every phase; `lake build BimodalTest` exits 0 at task close.
- [ ] `bash scripts/check-module-invariants.sh` passes every check it passed at the pre-task baseline
      — in particular C1 (build), C2 (flagship axiom sets match baseline), C3 (zero structural
      `sorry` across `FormalSystem/`), and C9 (zero task-number citations under `FormalSystem/`).
- [ ] `#print axioms` on every new public theorem shows only `[propext, Classical.choice, Quot.sound]`
      — no new axiom anywhere.
- [ ] `git diff` confirms all nine carriers (`unorderedSuccessor_confined_signedUniverse_of_headroom`,
      `universeClosedAt_signedUniverse_of_headroom`,
      `buildTableauAt_isSome_of_lengthBudget_signedUniverse`,
      `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse`, both `_selfGuarded` siblings, both
      `_fixed` siblings, `..._untlSnceFree`) retain byte-identical statements and proofs.
- [ ] `git diff --stat` shows no change to `Fuel.lean`, `Saturation.lean`, or `Tableau.lean`.
- [ ] The C9 register still opens "Twenty-four statements" and contains exactly 24 numbered entries.
- [ ] No phase introduced a frame-class restriction on any new statement.
- [ ] No new global `@[simp]` attribute was added.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — the sole modified source
  file. Additive blocks in section C11 (Phase 1) and a new section D4 (Phases 3-7); prose amendments in
  two docstrings and C9 entries 11 and 21 (Phases 2, 7).
- `specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/summaries/01_{short-slug}-summary.md`
  — implementation summary, which MUST record: the sharpened verdict's theorem names for a sibling
  task to cite, whether the run stopped after Phase 2 (a complete outcome-(c) deliverable) or ran the
  full replacement, and the confirmed-or-refuted status of every Scope Hypothesis above.
- The probe files under `probes/` are inputs, not outputs. They are not modified and not deleted;
  they remain the record of what was proved before the file was touched.

## Rollback/Contingency

- **Rollback**: every phase commits separately and every change is additive to one file. Reverting
  any phase is `git revert` of that phase's commits; no phase creates a dependency in a previously
  landed declaration, so a later phase can be reverted without disturbing an earlier one.
- **Natural stopping point**: Phases 1-2 alone satisfy the task's acceptance criteria (outcome (c)
  reached and recorded, `lake build` green, no invariant regression). If Phase 5 or 6 hits a genuine
  obstruction, stop, record it with evidence in the summary, and close at the last green phase —
  forcing a replacement through with an added hypothesis would recreate exactly the unsatisfiable-
  residual failure mode this task exists to remove.
- **If a Scope Hypothesis is refuted** (a `rfl` fact does not generalize, a tenth carrier appears, a
  third world-minting rule exists, no propositional stock is exhibitable): that is a finding, not a
  failure. Record it, correct the plan's claim in the summary, and re-scope rather than working around
  it silently.
- **Hard stop conditions**: any `sorry`, any new axiom, any edit to a frozen md5-pinned file, any
  change to a previously-landed declaration's statement or proof, or a `check-module-invariants.sh`
  check that passed at baseline and now fails.
