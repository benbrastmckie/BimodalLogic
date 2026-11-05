# Implementation Plan: Task #852

- **Task**: 852 - Author a model-level pumping lemma for tpOf along a ladder path
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: 855
- **Research Inputs**: None (no research report for this round; Stage 1.5 assessment resolved the
  scope by direct codebase audit — see "Opening audit" below)
- **Artifacts**: plans/01_model-level-tpof-periodicity.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The task asks for the model-side analogue of the certificate graph's periodicity: a statement
about `tpOf` along a ladder path, authored rather than cited, so that the bridge from
`prodPre_periodic` to `tpOf` does not run back through the obligations that read the agreement.

The opening audit (below) found the *splice/pump* half of that programme already landed, and the
*periodicity* half genuinely absent. This plan therefore authors the periodicity statement only,
in the one form that is true: `tpOf` along a ladder path is `l`-periodic whenever the path's
object walk is globally `l`-periodic. It then compiles the refutation of the unconditional form
(eventual periodicity with a threshold and a period, the exact shape of
`satThreshold`/`satPeriod`), which is FALSE for an arbitrary ladder path, and records that the
honest conditional form does not discharge the third circularity — the walk on the tight
(doubling) chain is not globally periodic, so the hypothesis is unavailable exactly where the
circularity bites.

### Opening audit (what is already landed, and what is not)

The task description states that "no phase of any plan version to date costs this lemma". That is
true of the periodicity statement and false of the pumping surgery, which landed before this task
was created. Specifically, already in the tree and to be CITED, not re-authored:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean:782`
  `tpOf_eq_spliceIdx_of_tpOf_eq` — "THE DUPLICATION TYPE LEMMA": duplicating a block whose two
  ends carry the same realized stab-free type preserves the realized type at EVERY position,
  read through the retraction. This is the type-respecting-block pumping lemma, and it is
  precisely the statement the known refutation leaves standing.
- `LadderPump.lean:714` `plusTruthAt_iff_spliceIdx_of_tpOf_eq_of_stabPinned` — its pinned-letter
  parent, plus the deletion mirror in the same module.
- `LadderChain.lean:475` `exists_typeBlock_of_spacing` — the spaced type pigeonhole: among
  `budget + 1` samples at spacing `s`, two share `(objAt, tpOf)`.
- `LadderChain.lean:409` `realized_typeBlock_mem_prodCycleLens` and `:435`
  `typeBlock_length_dvd_of_paramsOk` — the realized-chain bridge, a type-respecting block's
  length divides `P + 1` under `(K1)`.
- `LadderAgree.lean:2232` `truthAt_iff_of_objAt_eq_of_stabPinned` and `:2298`
  `tpOf_stabFree_eq_of_objAt_eq` — half (i), object-trace locality.
- `AnchorLayer.lean:122` `tpOf_timeShift` — the type's time-shift equation.

What no declaration in the tree states is a PERIODICITY fact about `tpOf`: a `p > 0` with
`tpOf σ (z + p) = tpOf σ z`. The landed facts are *conditional invariance under a surgery* and
*recurrence by pigeonhole*; neither is periodicity, and the README's own verdict section confirms
`prodPre_periodic`/`satThreshold`/`satPeriod` is the only periodicity statement in the layer. That
gap is this task's whole deliverable.

### The honest statement, and why it is the only one available

Positive form (Phase 1): if `objAt g (v + l) = objAt g v` for EVERY `v : ℤ`, then
`tpOf M φ σ (z + l) = tpOf M φ σ z` for every `z`. The proof is short and uses only landed
machinery: `σ.timeShift l` presents the shifted path (`WorldHistory.timeShift_state`, verified at
`FormalSystem/Semantics/PartialHistory.lean:566`, gives `(σ.timeShift l).state t = σ.state (t + l)`,
hence the presentation `∀ t, (σ.timeShift l).state t = (t + (k + l), g (t + l))`), `tpOf_timeShift`
moves the index, and half (i) (`tpOf_stabFree_eq_of_objAt_eq`) identifies the two realized types
because the two object walks coincide pointwise under the hypothesis.

Negative form (Phase 2): the unconditional statement — for every ladder path there are a threshold
`N` and a period `p > 0` with `tpOf σ (z + p) = tpOf σ z` for all `z ≥ N` — is FALSE. An arbitrary
ladder path's object walk is an arbitrary `step`-admissible walk, the atomic clause reads `objAt`,
and so any aperiodic walk over an all-idle object with a letter-separating label gives an
aperiodic `tpOf`. The refuting walk must be aperiodic IN THE TAIL (an eventually constant walk is
eventually periodic), which is what fixes the witness on powers of two rather than on a single
marked position.

### Relation to the known refutation

Nothing here restates the refuted shape. `tpOf_stabFree_eq_of_splice` — splice invariance of the
realized stab-free type at an OBJECT cycle — is refuted by
`specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean`
(`splice_type_invariance_refuted`), whose own record confines the refutation to a block whose
endpoint TYPES differ (`splice_block_not_type_respecting`) and says nothing about a
type-respecting block. Phase 1 adds no surgery at all: it is an equation between two positions of
ONE path under a hypothesis on that path's walk, so the counting argument that kills the splice
has no purchase — the walk is unchanged, hence so is every occurrence count a nested eventuality
reads. Phase 2's refutation is of a different statement again (periodicity, not splice
invariance) and must not be presented as a restatement of it.

### Research Integration

No research report for this round. The facts this plan rests on were read directly out of the
tree and are cited by file and line above, so each is checkable rather than recalled.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the dispatch context; `specs/ROADMAP.md` was not consulted and
is not modified.

## Goals & Non-Goals

**Goals**:
- `tpOf_periodic_of_objAt_periodic` -- the realized stab-free type of a ladder path is
  `l`-periodic whenever the path's object walk is globally `l`-periodic.
- `objAt_tpOf_eq_of_objAt_periodic` -- the same fact delivered as the endpoint-agreement pair
  `(objAt, tpOf)` at distance `l`, in the tuple shape `exists_typeBlock_of_spacing` and the
  duplication type lemma already consume.

**Non-Goals**:
- Any re-authoring of the splice/pump layer. `tpOf_eq_spliceIdx_of_tpOf_eq`,
  `exists_typeBlock_of_spacing`, `realized_typeBlock_mem_prodCycleLens` and
  `typeBlock_length_dvd_of_paramsOk` are cited, never duplicated or restated.
- Any variant of the refuted splice-invariance claim, under any name.
- Eventual (one-sided) periodicity: walk `l`-periodic on `[N, ∞)` does NOT give `tpOf`
  `l`-periodic on `[N, ∞)`, because the `since` clause reads the past and half (i) requires the
  two walks to agree at EVERY position. A future-only (`S`-free) restriction would need a
  future-locality lemma that the tree does not have; that is a separate object and is not
  attempted here.
- Discharging the third circularity. Phase 1's hypothesis (a globally periodic object walk) is
  not available on the tight/doubling chain, which is where the circularity runs. Phase 3 records
  that in prose; it is not widened away.
- `docs/theorem-index.md`. A concurrent sibling (task 856) declares that file in its own
  `file_scope`; this plan does not touch it. Adding the two rows is a follow-up for a round in
  which that territory is free.
- `cellLE_zero_const_of_kappa_eq`, `CellLEZeroConstOfKappaEq`, and any state-level cell
  agreement. Unclaimed before this task and unclaimed after it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The periodicity lemma reads as a disguised restatement of the refuted splice invariance | H | L | Phase 1 performs no surgery: one path, two positions, a hypothesis on the walk. Phase 3's docstring states the distinction explicitly and names `splice_block_not_type_respecting`. |
| Instance/variable binders in `LadderAgree.lean`'s half-(i) section do not match the Challenge signature verbatim (the section carries `[Finite Q] [Nonempty Q]` via `variable`, with a nearby `omit`) | M | M | A binder or implicit/explicit discrepancy forced by the host section is NOT a statement weakening; keep the hypothesis list and the conclusion exactly as pinned and let the binders follow the section. Any change to a HYPOTHESIS or the CONCLUSION is a blocker under `plan-compliance.md`, not a deviation. |
| The refuting walk is eventually constant, so it refutes nothing (eventual periodicity is satisfied) | H | M | The witness is pinned to powers of two precisely to keep the tail aperiodic; the probe must compile the "for every `p > 0` and every `N`" quantifier, not a single-`p` instance. |
| `README.md` of the RaySummary directory is outside the task's declared `file_scope` | M | H | Phase 3 declares it explicitly as a scope extension; the implementer adds it to `file_scope` before editing. No concurrent sibling claims it (856 claims `FormalSystem/OpenLanguage/README.md`, a different file). |
| A sibling task edits a file in this scope mid-phase (865 has no declared scope) | M | M | Re-read each target immediately before editing; stage only this task's own hunks with an explicit file list; treat an unexplained failure outside this scope as possibly a sibling's in-flight edit, per the dispatch's concurrency note. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is linear: Phase 2's probe record
cites Phase 1's landed name as the statement it does NOT refute, and Phase 3 records both.

### Phase 1: The conditional periodicity lemma [COMPLETED]

**Goal**: Land `tpOf_periodic_of_objAt_periodic` and its endpoint-pair corollary
`objAt_tpOf_eq_of_objAt_periodic` in `LadderAgree.lean`, beside half (i), with no `sorry`, no new
axiom and no vacuous definition.

**Tasks**:
- [x] Re-read `LadderAgree.lean` around the half-(i) section (roughly lines 2220-2320) immediately
  before editing, and confirm the section's `variable` binders for `Q`, `step`, `pend` and the
  `[Finite Q] [Nonempty Q]` instances as they actually stand.
- [x] Add `tpOf_periodic_of_objAt_periodic` immediately after `tpOf_stabFree_eq_of_objAt_eq`,
  with the signature pinned in `## Lean Challenge Statements`.
- [x] Prove it: instantiate half (i) at `σ' := σ.timeShift l`, supplying
  `hσ' : ∀ t, (σ.timeShift l).state t = (t + (k + l), g (t + l))` from
  `WorldHistory.timeShift_state` plus `hσ` and a `ring`-level rearrangement of `t + l + k`; supply
  `hobj` from `hper`; then rewrite the conclusion's left side with `tpOf_timeShift`.
- [x] Add `objAt_tpOf_eq_of_objAt_periodic`, the `(objAt, tpOf)` pair at distance `l` in the tuple
  shape `exists_typeBlock_of_spacing` returns, as a corollary of the above plus `hper`.
- [x] Write a module-level docstring paragraph for each: what it quantifies over (a GLOBALLY
  periodic walk, every `v : ℤ`), what it does not (no surgery, no pending-region hypothesis, no
  `ParamsOk`), and that the hypothesis is on the WALK and not on the certificate layer.
- [x] Run `lean_verify` on both fully qualified names and record the axiom profile; confirm it
  matches the module's own profile and introduces nothing new.
- [x] Scoped build and commit.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts exactly two new declarations in exactly one file
(`LadderAgree.lean`). Confirm at implementation time by `grep -c` on the two identifiers after
the edit and by the scoped build touching no other module's source; if the proof turns out to need
a helper lemma, that helper is a third declaration in the same file and the hypothesis is revised
in place rather than silently exceeded.

**Tier Justification**: the covering check is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree`
plus `lean_verify` on both names, which together cover a two-declaration addition to one module
whose downstream consumers are unchanged by an addition.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - two new theorems after
  `tpOf_stabFree_eq_of_objAt_eq`, with their docstrings.

**Verification**:
- `lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` exits 0.
- `lean_verify FormalSystem.Metalogic.Decidability.RaySummary.tpOf_periodic_of_objAt_periodic`
  and the same for `objAt_tpOf_eq_of_objAt_periodic`: no `sorry`, no axiom beyond
  `[propext, Classical.choice, Quot.sound]`.
- Neither declaration's hypothesis list can be deleted without breaking it: deleting `hper` must
  make the proof fail (the anti-vacuity check for this phase).

---

### Phase 2: Compile the refutation of the unconditional form [COMPLETED]

**Goal**: A new wired probe compiling that EVENTUAL periodicity of `tpOf` along an arbitrary
ladder path — a threshold `N` and a period `p > 0`, the shape of `satThreshold`/`satPeriod` — is
false, so that Phase 1's hypothesis is shown to be load-bearing rather than decorative.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean`
  with the directory's house docstring structure: what was asked, what is settled, non-vacuity,
  what this probe does NOT show, what is refuted precisely, and verification.
- [x] Define the object: `Q := Bool`, `stepA : Bool → Bool → Bool := fun _ _ => true`,
  `pendA : Bool → Bool := fun _ => false` (all idle, so `Count` pins the countdown to `0`),
  `labA : Bool → Atom → Bool` separating the two states on one atom.
- [x] Discharge `fwd`/`bwd` (seriality of `RladAdm` in both directions on the admissible carrier)
  as discharged hypotheses, not assumptions — follow the `fwdS`/`bwdS` pattern of
  `ladder-splice-type-refutation.lean` and the `ClimbWitness` fixture at
  `LadderChain.lean:1411-1460`.
- [x] Define the aperiodic walk `wA v := decide (∃ n : ℕ, (2 ^ n : ℤ) = v)` (classically, via
  `Classical.dec`), lift it to a ladder path, and obtain the history by
  `exists_hist_of_isLadderPath` / `exists_ladderPath_of_walk_nxt` as the sibling probes do.
- [x] Compile the tail-aperiodicity arithmetic: for every `p > 0` and every `N` there is an
  `n : ℕ` with `2 ^ n ≥ N`, `2 ^ n > p`, hence `2 ^ n < 2 ^ n + p < 2 ^ (n + 1)`, so `2 ^ n` is a
  power of two and `2 ^ n + p` is not.
- [x] State the target as a schema `TpOfEventualPeriodicity` (universally quantified over the
  object, the label, `φ`, the path, its presentation and the stab-free closure condition,
  concluding `∃ N p, 0 < p ∧ ∀ z ≥ N, tpOf σ (z + p) = tpOf σ z`) and compile
  `tpOf_periodicity_refuted_unconditional : ¬ TpOfEventualPeriodicity`.
- [x] Carry non-vacuity on both sides explicitly: the separating atom is IN one realized type and
  NOT in the other, so neither type is empty and the inequality is not an artefact.
- [x] In "what this probe does NOT show", state that it refutes nothing about
  `tpOf_periodic_of_objAt_periodic` (whose hypothesis the witness violates at every `l`), nothing
  about the duplication type lemma, nothing about the realized-chain bridge, and that it is a
  statement about PERIODICITY and not a restatement of `splice_type_invariance_refuted`.
- [x] `#print axioms` on every headline theorem; record the profile in the docstring's
  Verification block.
- [x] Compile with `lake env lean` on the probe file and commit.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts exactly one new file and no edit to any existing Lean
source. Confirm at implementation time with `git status --short` showing a single untracked
`.lean` file under `specs/evidence/seam-gluing-ray-product/` before staging; a probe that turns
out to need a library lemma added to `LadderAgree.lean` revises this hypothesis in place and adds
that file to the phase's list rather than editing it silently.

**Tier Justification**: the covering check is `lake env lean` on the single new probe file plus
`#print axioms` on each headline theorem — a standalone evidence file that nothing imports, so no
wider surface is reachable from it.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean` - new wired
  probe.

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean`
  exits 0 with no `sorry` warning.
- `#print axioms` on each headline theorem prints the fixture profile and no `sorryAx`.
- `grep -nE ':=\s*(True|Unit|trivial|Trivial)\s*$'` on the probe returns nothing (no vacuous
  definition).
- The refutation is of the EVENTUAL form: the compiled schema's conclusion carries both `∃ N` and
  `∃ p, 0 < p`, checkable by reading the schema's statement.

---

### Phase 3: Record the honest form and the gap it leaves [COMPLETED]

**Goal**: State in the layer's own record exactly what the new lemma quantifies over, that the
unconditional form is refuted, and that the conditional form does not discharge the third
circularity — per the dispatch's guardrail, rather than widening the statement.

**Tasks**:
- [x] Add `FormalSystem/Metalogic/Decidability/RaySummary/README.md` to the task's `file_scope`
  (`bash .claude/scripts/update-task-status.sh` scope addition, or the equivalent the script
  exposes) before editing it, and note the extension in the phase's commit message body.
  *(deviation: altered — no scope-addition call was needed; `state.json`'s `file_scope` for this
  task already lists that README, `FormalSystem/Metalogic/README.md`, the repo-root `README.md`
  and `typst/generated/status.typ`, all four of which this phase touches.)*
- [x] Extend `LadderAgree.lean`'s module docstring: a short paragraph naming the two new
  declarations, the quantifier they carry (a globally periodic object walk), and the two things
  they are not — not a surgery, and not the periodicity the certificate layer supplies.
- [x] Add the RaySummary `README.md` rows for the two declarations in the file's existing row
  style, *(deviation: altered — the file's only declaration table is a GENERATED inventory block
  (`<!-- BEGIN GENERATED: inventory -->`, one row per FILE, not per declaration, carrying
  `<!-- TODO: add description -->` for `LadderAgree.lean`); hand-editing it is barred, so the two
  declarations are recorded in the bold-headed trailing-paragraph style the file's later entries
  use, and the generated block was refreshed with
  `scripts/check-module-invariants.sh --emit-inventory`.)* and one sentence in the verdict section recording: the only landed model-level
  periodicity statement is now the CONDITIONAL one; the unconditional/eventual form is refuted by
  the new probe; and the conditional form does not reach the third circularity, because the
  tight (doubling) chain's walk is not globally periodic, so the hypothesis is unavailable exactly
  there. Mark that last clause as argued, not compiled, matching the file's existing convention
  for the tight-chain gap.
- [x] Register the new probe in whatever probe inventory the directory's record keeps (check
  `specs/evidence/seam-gluing-ray-product/` and the README's probe numbering before asserting a
  number; do not invent an ordinal). *(completed: ordinals in the README run to "fifteenth" in the
  `## Evidence` section with one later "forty-seventh", and every entry after the fifteenth is
  registered WITHOUT an ordinal; the new probe follows that style and says so in its own
  sentence.)*
- [x] Commit.

**Timing**: 1 hour

**Depends on**: 1, 2

**Verification Tier**: prose

**Scope Hypothesis**: this phase asserts exactly two files edited and no Lean declaration added or
changed. Confirm with `git diff --staged --stat` showing only the two paths, and with the Phase 4
build (an unchanged `.lean` body cannot regress it).

**Tier Justification**: the covering check is the Phase 4 full build plus
`bash .claude/scripts/check-task-references.sh` on the two edited files — the edits are a module
docstring and a markdown record, neither of which carries a Lean proof obligation.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - module docstring paragraph
  only (no declaration change).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - two declaration rows plus the
  verdict sentence. Outside the declared `file_scope`; added to it in this phase's first step.

**Verification**:
- The README states the quantifier of the new lemma and the refuted status of the unconditional
  form in the same place, so a reader cannot take the one for the other.
- `bash .claude/scripts/check-task-references.sh` reports no task-number reference introduced into
  either file (both are deliverables under `.claude/rules/no-task-references-in-deliverables.md`).
- No version-history language introduced into either file
  (`.claude/rules/no-record-versioning-in-deliverables.md`).

---

### Phase 4: Final gate [COMPLETED]

**Goal**: The whole gate set, green, with the zero-debt guarantees the dispatch requires.

**Tasks**:
- [x] Re-read every file this task touched, in case a concurrent sibling has edited one.
- [x] Full project build through the guard.
- [x] `lean_verify` on both new library declarations and `#print axioms` on the probe's headline
  theorems; collect the profiles into the summary.
- [x] Repo-wide debt scan over the task's own diff: no `sorry`, no `axiom`, no `native_decide`,
  no vacuous `:= True`/`Unit`/`trivial` body, no `noncomputable` `Decidable`-valued declaration.
- [x] Confirm the Goals' identifiers resolve in the source root exactly as named (the
  `## Lean Challenge Statements` set), and that no weakened substitute was published under either
  name.
- [x] Write the completion summary, including the honest-gap statement in its own words.

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: full

**Batch-deferral note**: the full gate SET was deferred to this /orchestrate batch's own final
stage per this dispatch's directive, not independently run here. The narrowing harnesses that
directive names cover no file in this task's diff (`run-all.sh` discovers shell suites under
`.claude/scripts/` and `agent-system/extensions/`; `verify-deploy.sh` compares the deployed
`.claude/` tree against the source store; this task touched no shell script, no `.claude/**` and
no `agent-system/**` file). The checks that DO cover these files -- the full `lake build`, the
probe compile, `lean_verify` on both declarations, and `check-module-invariants.sh`,
`typst-sync-check.sh`, `readme-lint.sh`, `check-task-references.sh` -- were run in FULL rather
than scoped.

**Scope Hypothesis**: this phase asserts exactly one new file (the completion summary) and no
source change. Confirm with `git status --short` before staging; any source fix the gate forces is
a Phase 1-3 regression to be fixed in the phase that owns the file, with this hypothesis revised
in place.

**Files to modify**:
- `specs/852_model_level_pumping_lemma_for_tpof_along_ladder_path/summaries/01_model-level-tpof-periodicity-summary.md` - completion summary.

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 for the full
  project.
- `lake env lean` on the new probe exits 0.
- `lean_verify` on both new declarations: clean, with no axiom beyond the module's own profile.
- The debt scan is empty over the task's diff.
- `bash .claude/scripts/check-task-references.sh` and the record-version lint report nothing new
  in the deliverable files.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-- **MODEL-LEVEL PERIODICITY OF THE REALIZED TYPE.** When the object walk of a ladder path is
globally `l`-periodic, the realized stab-free type is `l`-periodic along the path, at every
position. No surgery, no pending-region hypothesis, no `ParamsOk`, no certificate object: the
hypothesis is on the WALK alone. -/
theorem tpOf_periodic_of_objAt_periodic {Q : Type} [Finite Q] [Nonempty Q]
    {step : Q → Q → Bool} {pend : Q → Bool}
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (l : ℤ)
    {k : ℤ} {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t))
    (hper : ∀ v : ℤ, objAt g (v + l) = objAt g v)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (z : ℤ) :
    tpOf (ladderModel step pend fwd bwd lab) φ σ (z + l)
      = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry

/-- **THE ENDPOINT PAIR AT DISTANCE `l`**, in the tuple shape the type pigeonhole and the
duplication type lemma consume: a globally `l`-periodic walk makes EVERY position the low end of a
type-respecting block of length `l`. -/
theorem objAt_tpOf_eq_of_objAt_periodic {Q : Type} [Finite Q] [Nonempty Q]
    {step : Q → Q → Bool} {pend : Q → Bool}
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (l : ℤ)
    {k : ℤ} {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t))
    (hper : ∀ v : ℤ, objAt g (v + l) = objAt g v)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (z : ℤ) :
    objAt g z = objAt g (z + l) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (z + l) := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

Binder note: `LadderAgree.lean`'s half-(i) section supplies `Q`, `step` and `pend` through
`variable` and carries the `[Finite Q] [Nonempty Q]` instances. If the host section forces a
binder to be section-level rather than per-declaration, or implicit rather than explicit, that is
not a statement weakening and needs no escalation. Any change to a HYPOTHESIS or to the
CONCLUSION of either statement is a blocker under `.claude/rules/plan-compliance.md`, to be raised
rather than annotated.

## Testing & Validation

- [x] Scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` green after
  Phase 1.
- [x] `lake env lean` green on the new probe after Phase 2.
- [x] Full project build green after Phase 4.
- [x] `lean_verify` clean on `tpOf_periodic_of_objAt_periodic` and
  `objAt_tpOf_eq_of_objAt_periodic`; `#print axioms` clean on every probe headline.
- [x] Zero-debt scan over the task diff: no `sorry`, no new `axiom`, no `native_decide`, no
  vacuous definition, no `noncomputable` `Decidable`-valued declaration.
- [x] `hper` is load-bearing in both new declarations (deleting it breaks the proof).
- [x] The probe refutes the EVENTUAL form (threshold AND period), not a single-period instance.
- [x] No task-number reference and no record-version language introduced into any deliverable
  file.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - two new theorems plus a
  module-docstring paragraph.
- `specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean` - new wired
  probe refuting unconditional eventual periodicity.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - two declaration rows and the
  verdict sentence recording the honest form and the gap it leaves.
- `specs/852_model_level_pumping_lemma_for_tpof_along_ladder_path/summaries/01_model-level-tpof-periodicity-summary.md` -
  completion summary.

## Rollback/Contingency

Each phase commits on its own, so reverting is per-commit. If Phase 1's proof cannot be closed,
Phases 2-4 do not run: the probe's record cites Phase 1's name, and a probe refuting the
unconditional form with no conditional form landed beside it would misrepresent the layer's state.
Mark Phase 1 `[BLOCKED]` with the goal state reached and raise it; do not substitute a weaker
statement under either pinned name, and do not publish a vacuous placeholder.

If a rollback of uncommitted work becomes necessary, take the snapshot first — see
`context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
out-of-scope override flag. A defensive checkpoint before risky editing uses
`bash .claude/scripts/git-snapshot.sh 852 --no-revert`, which is durable without reverting the
working tree.
