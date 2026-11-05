# Implementation Plan: Task #864

- **Task**: 864 - Land LC schema limit-closure soundness
- **Status**: [IMPLEMENTING]
- **Effort**: 9.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/864_land_lc_schema_limit_closure_soundness/reports/01_lc-schema-limit-closure-soundness.md`
- **Artifacts**: plans/01_lc-schema-limit-closure-soundness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Port the compiled LC_n limit-closure soundness content from task 559's probe
`03_morphisms-clock-rule-lc-schema.lean` (Part I) into `FormalSystem/PlusLanguage/`, re-expressed
against the repository's own `TaskFrame`, `WorldHistory` and `PlusTruthAt` instead of the probe's
Mathlib-only reconstruction over a bare formula type and a raw relation. Two new modules land
beside `PlusLimitClosure.lean`: an ω-limit/ω-chain kernel, then the LC_n schema and its validity.
The compiled claim is `.ZTime`-class (reached as `PlusValidInt` on the ℤ fibre and transferred by
`plusValidZTime_iff_plusValidInt`); the `.Base` case is recorded as open with no claim. Definition
of done: both modules compile sorry-free, the unscoped build is green, every new public result
carries a `docs/theorem-index.md` row with a measured `pinned:C14` axiom profile, and
`check-module-invariants.sh` plus `check-metalogic-cycles.sh` are green against their pre-task
baselines.

### Research Integration

Report `01_lc-schema-limit-closure-soundness.md` is integrated in full. Its three load-bearing
findings shape this plan:

1. **Absence confirmed and re-confirmed.** `grep -rn "lcAnte\|lcCons\|lcN\b\|lcN_valid\|omega_limit\|omegaLimit" FormalSystem/ Tests/ docs/`
   returns no rows, re-run at plan-authoring time. The task is not already satisfied; no
   close-as-already-satisfied branch is needed.
2. **The home module is `FormalSystem/PlusLanguage/`, not `FormalSystem/Metalogic/NamingRules.lean`.**
   The dispatch left this open for confirmation and the research confirmed the other answer:
   `NamingRules.lean` is about naming rules that discharge an auxiliary letter, which LC_n does
   not do, and its imports (`Semantics/Frames/TranslationProduct`) are irrelevant here. The
   actual sibling is `PlusLimitClosure.lean`, which already carries `blc` — the n = 1 limit-closure
   formula — and whose own docstring names this gap verbatim ("the instance at an `ω`-indexed
   recurrence schema is not stated here"). Staying inside `PlusLanguage/` also means
   `check-metalogic-cycles.sh` acquires no new upward edge.
3. **The ℤ-time scoping is forced, not a shortcut.** The ω-chain argument needs its marker
   sequence cofinal in the duration order; a `TemporalOrder` is an arbitrary nontrivial totally
   ordered abelian group, so over a dense order a strictly increasing marker sequence may
   converge and the argument does not close. The library's existing Zorn route does not generalize
   for free either: `lcProp_restrictIic` works at n = 1 because the restriction's maximum *is* a
   `P`-point, and with n indices the splice witness realizes only `⟐α_{j+1}`, leaving the other
   n-1 obligations unexcused. `.Base` is therefore a prose claim, stated-not-claimed, exactly as
   the dispatch instructs.

Verified directly at plan-authoring time against the live tree: `WorldHistory.ofTotal` exists in
`FormalSystem/Semantics/PartialHistory.lean` with the signature the port consumes
(`(F) (f : F.Duration → F.WorldState) (h : ∀ s t, F.TaskRel (f s) (t - s) (f t))`), alongside
`ofTotal_state`; `paste`, `paste_agreeFrom`, `paste_agreeUpTo` exist in `PlusPasting.lean`;
`PlusValidInt` and `plusValidZTime_iff_plusValidInt` exist in `PlusIntTransfer.lean`;
`IsStepPath`, `worldHistoryOfStepPath`, `respects_of_isStepPath`, `mem_HF_iff_adjacent` exist in
`IntNormalForm.lean`; the target namespace is `FormalSystem.PlusLanguage`; and both aggregators
(`FormalSystem/PlusLanguage.lean`, `FormalSystem.lean`) already list `PlusLimitClosure` and
`PlusIntTransfer`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in this dispatch (`roadmap_path` absent, `roadmap_flag` absent),
so no roadmap-review or roadmap-update phase is included and `specs/ROADMAP.md` is not consulted
or modified by this plan.

### LCU: not present in the source

The task title names LCU alongside LC_n. The probe's Part I defines no separate `LCU`
declaration — the compiled content is the `omega_limit`/`omega_chain` kernel plus
`lcAnte`/`lcCons`/`lcN`/`lcN_valid_full`. **Decision**: LCU is identified with the `n = 1`
instance of `lcN`, which is what the schema specializes to, and is recorded as such in the new
schema module's docstring; no separate `LCU` declaration is invented. The module docstring must
also state the relation to the already-landed `blc` — `blc` is the n = 1 case at `.Base` by Zorn,
`lcN` is the n ≥ 1 cycling schema at `.ZTime` by ω-chain, and neither subsumes the other, because
the routes differ in frame class and index arity.

## Goals & Non-Goals

**Goals**:
- `omega_limit` -- the ω-limit-of-splices principle at an arbitrary regular task frame, under an
  explicit cofinality hypothesis on the marker sequence.
- `intOrder_omega_cofinal` -- the ℤ discharge of that cofinality hypothesis.
- `omega_chain` -- iterate the splice stage and take the ω-limit.
- `bigAnd` -- finite conjunction of an `ℕ`-indexed family of `PlusFormula`, with a uniform base case.
- `lcAnte`, `lcCons`, `lcN` -- the LC_n schema, indices mod n.
- `lcN_plusValidInt` -- LC_n is valid on every model over a `FrameOver intOrder` frame, for every
  n ≥ 1 and arbitrary parameter formulas.
- `lcN_plusValidZTime` -- the same result transferred to the `.ZTime` frame class.

**Non-Goals**:
- Any completeness or axiomatizability claim, for TM-plus or for TM-plus + LC_n. Soundness only.
- Any decision engine.
- `.Base` validity of LC_n. The Zorn/Extension-Theorem argument recorded in task 559's report 03
  stays UNVERIFIED and stated-not-claimed; nothing in this plan compiles it, and no phase may
  introduce a `sorry` reaching for it.
- The Auxiliary-Atoms expansion. Its obstruction is `TaskFrame.Saturation` at the unravelled
  carrier, durably recorded in `FormalSystem/Metalogic/NamingRules.lean`'s "The Auxiliary-Atoms
  expansion, and where it stops" section. Not this task's problem.
- The probe's Part H, Part J and Part K. Part K (the clock rule) already landed in
  `NamingRules.lean` as `clock_irr_sound` and `irr_sound` with their four truth
  characterisations, and MUST NOT be redone.
- Any new pasting operator. `PlusPasting.paste` and its two agreement lemmas are reused.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An implementer reads "this is a port, not a proof search" and attempts `.Base` generality, then reaches for `sorry` when cofinality fails | H | M | The Challenge Statements below pin `PlusValidInt`/`PlusValidZTime`, never `PlusValid`; Phase 5 quotes the cofinality obstruction in its own body; `plan-compliance.md`'s Statement Fidelity makes the pinned signature the contract |
| A reviewer concludes `lcN` supersedes the landed `blc`, or vice versa | M | M | Phase 4 writes the relation into the module docstring explicitly: different frame class, different route, different index arity, neither subsumes the other |
| Hand-typed axiom profiles in `docs/theorem-index.md` or in the C14 baseline | H | M | Phase 6 measures with `#print axioms` first and pastes the measured lines second; the dispatch forbids typing a profile by hand, and C14 exists to catch exactly this |
| Concurrent siblings (tasks 866, 868, both with undeclared file scope) collide on `scripts/check-module-invariants.sh` or `docs/theorem-index.md` | M | M | Re-read both files immediately before editing; stage only this task's hunks with an explicit file list, never a directory or glob add; treat an out-of-scope build failure as possibly a sibling's in-flight edit, and STOP and report a foreign commit or foreign uncommitted modification after checking `git log` |
| `Classical.choice` introduced by `omega_chain`'s `Nat.rec`/`choose` moves an existing pinned axiom profile | L | L | Nothing existing imports the new modules, so no existing baseline row can move; Phase 6 adds new rows only. Confirm by observing C14's expected-vs-actual diff naming only new lines |
| The unscoped build is long and collides with a sibling's unguarded `lake` call | M | M | Every `lake` invocation routes through `lake-build-guard.sh` with an explicit `--timeout`; an unexplained failure outside the new modules is checked for guard bypass before being treated as a regression |
| Task 559's directory is archived mid-task, taking the source probe out of version control with it | H | M | Phase 1 promotes the probe into `specs/evidence/` (tracked, task-independent) and wires it into `check-evidence-probes.sh` before any port work depends on it; Phase 1 is in Wave 1 and depends on nothing |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 1, 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Promote the source probe into tracked evidence [COMPLETED]

**Goal**: Make task 559's archival harmless by moving the compiled source of record into
`specs/evidence/`, which is tracked and task-independent, and wiring it into the evidence-probe
gate.

This phase preserves this task's *input* rather than landing its *output*. It is included
deliberately, as a recorded choice rather than an omission: `scripts/check-evidence-probes.sh`
contains no reference to task 559 or its `probes/` directory, and `.gitignore` excludes
`specs/archive/`, so `/todo` archival of the (already `[COMPLETED]`) task 559 would silently
remove the probe from version control. That matters even if the port lands in full, because the
probe is also the compiled record of the UNVERIFIED `.Base` argument and of Parts H and J, none of
which this task lands.

**Tasks**:
- [x] Re-read `scripts/check-evidence-probes.sh`'s header and its `WIRED` array immediately before
      editing (concurrent siblings have undeclared file scope).
- [x] Create the collection directory `specs/evidence/limit-closure-schema/` and copy the probe to
      `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean`.
- [x] Confirm the copy still compiles standalone: `lake env lean specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean`
      exits 0 with empty output. The probe imports only `Mathlib`, so the new path changes nothing
      about its import resolution.
- [x] Add the `WIRED` entry `"limit-closure-schema/lc-schema-omega-chain"` (collection-relative,
      per the array's documented entry form) and, beside it in the file's own
      "WHAT EACH PROBE HOLDS IN PLACE" table, a line naming the decision it holds: that the LC_n
      schema's validity on all-walks ℤ-models is compiled and sorry-free, and that the `.Base`
      argument is NOT.
- [x] Prefer `WIRED` over `WIRED_REPO`; the file's own header states `WIRED_REPO` needs a named
      blocker recorded beside the entry, and there is none here.
- [x] Run `bash scripts/check-evidence-probes.sh` and confirm green.
- [x] Commit with an explicit two-file staging list; do not stage a directory.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the probe is 814 lines and sorry-free, and compiles standalone with exit 0
and empty output. The 814-line figure is re-derived at plan-authoring time (`wc -l` on the probe).
The exit-0 compile is CARRIED-UNVERIFIED from the research report's own measurement
(`reports/01_lc-schema-limit-closure-soundness.md`, Appendix "Commands run"); confirm it at
implementation time by re-running `lake env lean` on the copy, which this phase's task list
already requires.

**Tier Justification**: `lake env lean specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean`
(exit 0) plus `bash scripts/check-evidence-probes.sh` (green) is the complete covering check — the
new file is a standalone Mathlib-only probe that no library module imports, and the script edit
adds one array entry with no symbol any other module calls.

**Files to modify**:
- `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` - new; verbatim copy of the
  source probe
- `scripts/check-evidence-probes.sh` - one new `WIRED` array entry plus its row in the
  "WHAT EACH PROBE HOLDS IN PLACE" table

**Verification**:
- `lake env lean specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` exits 0 with
  empty output.
- `bash scripts/check-evidence-probes.sh` exits 0 and names the new entry.
- `git status --short` shows exactly the two intended paths before staging.

---

### Phase 2: The ω-limit kernel module [COMPLETED]

**Goal**: Create `FormalSystem/PlusLanguage/PlusOmegaChain.lean` and land the marker-sequence
lemmas and `omega_limit` in it, at an arbitrary regular task frame under an explicit cofinality
hypothesis.

The port is *shorter* than the probe's, not longer. `WorldHistory.ofTotal F f h` asks for
`h : ∀ s t, F.TaskRel (f s) (t - s) (f t)`, which the limit discharges directly from local
agreement — pick a marker above both `s` and `t`, then use that stage's own `respects_task`. The
probe needed `IsWalk` plus a composition argument only because its bundle was defined by
adjacency.

**Tasks**:
- [x] Create `FormalSystem/PlusLanguage/PlusOmegaChain.lean` with the repository's standard
      copyright header, `import FormalSystem.PlusLanguage.PlusPasting` and
      `import FormalSystem.PlusLanguage.PlusIntTransfer`, `namespace FormalSystem.PlusLanguage`,
      and the same `open` block `PlusLimitClosure.lean` uses (`FormalSystem.Syntax`,
      `FormalSystem.Semantics`, `PartialHistory`, `PlusTruth`).
- [x] Write the module docstring: what the ω-limit principle is, that it is class-generic, and
      that the cofinality hypothesis is the one binder at which the ℤ-dependence of the
      downstream LC_n result is isolated and auditable.
- [x] Port the marker lemmas from probe lines 609-628: monotonicity (`c k ≤ c (k + d)`) and
      transitive agreement across stages (`agree_add`), restated at `F.Duration` rather than `ℤ`.
      Keep the probe's decomposition — one named lemma per probe lemma; do not inline them into
      `omega_limit`.
- [x] Port `omega_limit` (probe line 630) at the Challenge signature below, building the limit
      with `WorldHistory.ofTotal` and discharging its `TaskRel` obligation from the marker
      agreement as described above.
- [x] Register the module: add `import FormalSystem.PlusLanguage.PlusOmegaChain` to
      `FormalSystem/PlusLanguage.lean` (beside the existing `PlusLimitClosure`/`PlusIntTransfer`
      imports) with a matching entry in that file's prose module list, and to `FormalSystem.lean`
      beside its existing `PlusLanguage.PlusIntTransfer`/`PlusLimitClosure` imports. Re-read both
      aggregators immediately before editing.
- [x] Guarded scoped build green, zero `sorry`, no vacuous definition.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the ported region is probe lines 609-650 (~42 lines of probe source),
expected to yield a comparable or smaller body in the library because `WorldHistory.ofTotal`
replaces the probe's adjacency/composition argument. Figure carried from
`reports/01_lc-schema-limit-closure-soundness.md`'s step map and re-derived at plan-authoring time
by grepping the probe's declaration lines; confirm the realized module length at implementation
time and record any material overrun in the issue log rather than silently absorbing it.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusOmegaChain`
followed by the same guarded scoped build of `FormalSystem.PlusLanguage` is the complete covering
check — the module is new, nothing imports it yet, and the two aggregator edits add import lines
only, changing no symbol's name, type or arity.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` - new; marker lemmas and `omega_limit`
- `FormalSystem/PlusLanguage.lean` - one new import plus its prose module-list entry
- `FormalSystem.lean` - one new import

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusOmegaChain`
  exits 0 (read the guard's own verdict, never a pipe exit code).
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage`
  exits 0.
- `grep -n "sorry" FormalSystem/PlusLanguage/PlusOmegaChain.lean` returns nothing.
- No `def X := True`/`Unit`/`trivial` pattern in the new module.
- `omega_limit`'s signature matches the Challenge Statement below exactly.

---

### Phase 3: The splice stage and ω-chain [NOT STARTED]

**Goal**: Land the splice bundle and the iteration that consumes `omega_limit`, plus the ℤ
discharge of the cofinality hypothesis, in the same module.

**Tasks**:
- [ ] Re-read `FormalSystem/PlusLanguage/PlusOmegaChain.lean` as Phase 2 left it.
- [ ] Port the splice stage from probe lines 651-679: the stage bundle (probe `Stg`) and the
      one-step splice (probe `stg_step`), which pastes the continuation onto the current stage at
      its marker and produces a later stage with a strictly larger marker. Reuse
      `PlusPasting.paste` with `paste_agreeFrom` and `paste_agreeUpTo`; introduce no second
      pasting operator.
- [ ] Port `omega_chain` (probe line 681) at the Challenge signature below: iterate the splice by
      `Nat.rec` with `Exists.choose`, then take the `omega_limit`. Keep the cofinality hypothesis
      as an explicit binder rather than hard-wiring `intOrder`, so the ℤ-dependence stays visible
      at exactly one place and the kernel remains reusable if the dense case is ever settled.
- [ ] Land `intOrder_omega_cofinal` at the Challenge signature below: a strictly increasing
      `ℕ`-indexed sequence in `ℤ` is cofinal (the probe's `c 0 + k ≤ c k` route).
- [ ] Record in the module docstring that `intOrder_omega_cofinal` is the only discharge of the
      cofinality hypothesis available today, and that it is false over a dense temporal order —
      so every consumer of `omega_chain` is thereby `.ZTime`-scoped.
- [ ] Note in the docstring that `Nat.rec` plus `choose` introduces `Classical.choice`, which is
      the tree's standard `pcq` profile.
- [ ] Guarded scoped build green, zero `sorry`, no vacuous definition.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: the ported region is probe lines 651-706 (~56 lines of probe source).
Figure carried from `reports/01_lc-schema-limit-closure-soundness.md`'s step map and re-derived at
plan-authoring time from the probe's declaration lines; confirm at implementation time.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusOmegaChain`
is the complete covering check — the edit is confined to that one module, which nothing in the
tree imports yet, and it adds no symbol any other module calls.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` - splice stage bundle, one-step splice,
  `omega_chain`, `intOrder_omega_cofinal`, docstring additions

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusOmegaChain`
  exits 0.
- `grep -n "sorry" FormalSystem/PlusLanguage/PlusOmegaChain.lean` returns nothing.
- `omega_chain` and `intOrder_omega_cofinal` signatures match the Challenge Statements below.
- `mcp__lean-lsp__lean_verify FormalSystem.PlusLanguage.omega_chain` reports no `sorry` and an
  axiom profile recorded for Phase 6's use (measurement only; the profile is not typed into any
  ledger here).

---

### Phase 4: The schema module and its syntax [NOT STARTED]

**Goal**: Create `FormalSystem/PlusLanguage/PlusLCSchema.lean` with the finite-conjunction helper,
the local `G≤` abbreviation, and the LC_n formula itself.

**Tasks**:
- [ ] Create `FormalSystem/PlusLanguage/PlusLCSchema.lean` with the standard header,
      `import FormalSystem.PlusLanguage.PlusOmegaChain`, `namespace FormalSystem.PlusLanguage`
      and the same `open` block.
- [ ] Write the module docstring, which MUST state: (a) LC_n is Reynolds 2003's infinite
      limit-closure schema transposed to `⊡` with `G≤`, cited as `reynolds2003` (the repository's
      established key, already used in `FormalSystem/OpenLanguage/README.md` and
      `FormalSystem/Metalogic/BXCanonical/Quasimodel/Realization.lean`); (b) the proof of record
      is the probe's compiled ω-chain transposition, not the paper's own argument, and nothing is
      claimed about the paper's argument; (c) the relation to the landed `blc` — `blc` is the n = 1
      case at `.Base` by Zorn plus the Extension Theorem, `lcN` is the n ≥ 1 cycling schema at
      `.ZTime` by ω-chain, and neither subsumes the other; (d) LCU is identified with the n = 1
      instance of `lcN`, with no separate declaration; (e) `.Base` validity of `lcN` is OPEN — a
      paper argument by Zorn plus the Extension Theorem is recorded in task 559's report 03 and is
      UNVERIFIED in Lean, so nothing here claims it.
- [ ] Port `gle` and its truth clause from probe lines 48 and 111: `G≤ φ := φ ∧ Gφ`, with
      `gle_iff : PlusTruthAt M τ t φ.gle ↔ ∀ s, t ≤ s → PlusTruthAt M τ s φ`. `gle` does not exist
      in `PlusLanguage/Formula.lean`; define it locally in this module.
- [ ] Port `bigAnd` and `bigAnd_iff` from probe lines 707-725. The index must be `ℕ` with a uniform
      `top` base case. `Syntax.bigconj` is NOT reusable: it is `List Formula → Formula`, has a
      non-uniform base case, and sits at the L layer rather than L⁺.
- [ ] Port `lcAnte`, `lcCons`, `lcN` from probe lines 727-734, indices mod n, at the Challenge
      signatures below.
- [ ] Register the module in `FormalSystem/PlusLanguage.lean` (import plus prose module-list
      entry) and `FormalSystem.lean`. Re-read both aggregators immediately before editing.
- [ ] Guarded scoped build green, zero `sorry`, no vacuous definition.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: the ported region is probe lines 48, 111 and 707-734 (~40 lines of probe
source across three regions). Figure carried from
`reports/01_lc-schema-limit-closure-soundness.md`'s step map and re-derived at plan-authoring time
from the probe's declaration lines; confirm at implementation time.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
followed by the guarded scoped build of `FormalSystem.PlusLanguage` is the complete covering
check — the module is new, nothing imports it yet, and the two aggregator edits add import lines
only.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` - new; `gle`, `gle_iff`, `bigAnd`, `bigAnd_iff`,
  `lcAnte`, `lcCons`, `lcN`, module docstring
- `FormalSystem/PlusLanguage.lean` - one new import plus its prose module-list entry
- `FormalSystem.lean` - one new import

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
  exits 0.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage`
  exits 0.
- `grep -n "sorry" FormalSystem/PlusLanguage/PlusLCSchema.lean` returns nothing.
- `bigAnd`, `lcAnte`, `lcCons`, `lcN` signatures match the Challenge Statements below.
- The module docstring contains all five required statements (a)-(e) above, with `.Base` recorded
  as open and unclaimed.

---

### Phase 5: LC_n validity at the ℤ fibre and at ZTime [NOT STARTED]

**Goal**: Prove `lcN_plusValidInt` and transfer it to `lcN_plusValidZTime`.

**The cofinality obstruction, quoted here so no implementer reaches past it.** The consequent's
`G≤` is closed by producing, for an arbitrary `s ≥ t` and index `j`, a marker `c k > s` whose
index is `j + 1 mod n`. That needs the markers cofinal in the duration order, which holds over ℤ
(`intOrder_omega_cofinal`) and **fails over a dense order**, where a strictly increasing marker
sequence may converge. This is the step that fixes the frame class of the result. The target is
`PlusValidInt`, then `PlusValidZTime` — **never `PlusValid`**. If this phase cannot close as
written, mark it `[BLOCKED]` and escalate; do not weaken the Challenge statement, do not add a
hypothesis to it, and do not introduce a `sorry` reaching for `.Base`.

**Tasks**:
- [ ] Re-read `FormalSystem/PlusLanguage/PlusLCSchema.lean` as Phase 4 left it.
- [ ] Port `lcN_valid_full` (probe line 737) as `lcN_plusValidInt` at the Challenge signature
      below, following the probe's own script step by step: case split on whether any
      `⟐α_i`-point is reachable; the vacuous branch uses the evaluation history itself; the main
      branch runs `omega_chain` at `A k := ⟐α_{(i₀+k) mod n}` and closes `G≤` by choosing a marker
      `c k > s` in residue class `j + 1 mod n`.
- [ ] Use the library's own walk/history dictionary rather than reintroducing the probe's
      `IsWalk`-over-a-raw-relation setting: `IsStepPath F f` for the walk condition,
      `FrameOver.worldHistoryOfStepPath` to go from a walk to a model element,
      `WorldHistory.isStepPath` for the converse, and `FrameOver.mem_HF_iff_adjacent` for the
      identification that makes "all-walks ℤ-model" and "every world history of a
      `FrameOver intOrder` frame" the same set. `Walk.IsWalk` in
      `Semantics/Correspondence/FwdRecPeriodicity.lean` is definitionally `IsStepPath F F.step`
      but the history-level statement is the one `PlusTruthAt` consumes.
- [ ] Discharge `omega_chain`'s cofinality binder with `intOrder_omega_cofinal`.
- [ ] Derive `lcN_plusValidZTime` from `lcN_plusValidInt` via
      `plusValidZTime_iff_plusValidInt.mpr`.
- [ ] Guarded scoped build green, zero `sorry`, no vacuous definition.
- [ ] Measure `#print axioms` (or `lean_verify`) for `lcN_plusValidInt` and `lcN_plusValidZTime`
      and record the measured lines for Phase 6. Measure only; do not type a profile anywhere.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: the ported region is probe lines 737-813 (~77 lines of probe source), the
single largest declaration in the port. Figure carried from
`reports/01_lc-schema-limit-closure-soundness.md`'s key-declaration appendix and re-derived at
plan-authoring time (`lcN_valid_full` at probe line 737, probe total 814 lines). If the realized
proof materially exceeds this, record it in the issue log rather than splitting the Challenge
statement.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
is the complete covering check — the edit is confined to that one module, which nothing in the
tree imports yet, and the two new theorems add no symbol any other module calls.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` - `lcN_plusValidInt`, `lcN_plusValidZTime`, and
  their docstrings

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
  exits 0.
- `grep -rn "sorry" FormalSystem/PlusLanguage/PlusLCSchema.lean FormalSystem/PlusLanguage/PlusOmegaChain.lean`
  returns nothing.
- `lcN_plusValidInt` and `lcN_plusValidZTime` signatures match the Challenge Statements below;
  neither mentions `PlusValid`.
- `mcp__lean-lsp__lean_verify FormalSystem.PlusLanguage.lcN_plusValidZTime` reports no `sorry`,
  and its axiom profile is captured verbatim for Phase 6.

---

### Phase 6: Ledger rows, axiom baseline, and the full gate set [NOT STARTED]

**Goal**: Close the task: pin every new public result's measured axiom profile into C14, add its
`docs/theorem-index.md` row stating the conditional form honestly, and run the repository's
complete gate set green.

**Tasks**:
- [ ] Re-read `scripts/check-module-invariants.sh` and `docs/theorem-index.md` immediately before
      editing; both are plausible shared targets for the two concurrent siblings.
- [ ] For each new public result (`omega_limit`, `omega_chain`, `intOrder_omega_cofinal`,
      `bigAnd_iff`, `gle_iff`, `lcN_plusValidInt`, `lcN_plusValidZTime`), add a
      `#print axioms FormalSystem.PlusLanguage.<name>` line to C14's probe block, in the same
      position-order as the existing block's trailing `NamingRules` lines.
- [ ] Run the C14 measurement, capture the emitted `'...' depends on axioms: [...]` lines verbatim,
      and paste them into `C14_BASELINE` in the matching order. **Measure, then paste.** Never type
      an axiom profile by hand — this is the defect C14 exists to catch.
- [ ] Add one `docs/theorem-index.md` row per landed result, following the existing `NamingRules`
      rows as the pattern: `Paper label` is `—` for formalization-native results; the `Lean name`
      column is the FULLY QUALIFIED name, always; the `File` column is a path with no line
      numbers; `Frame class` reads `ZTime` for `lcN_plusValidZTime` and `—` for the class-generic
      kernel lemmas and the syntax lemmas; the `Axioms` cell carries `pcq` (or the literal profile
      when it is not exactly `[propext, Classical.choice, Quot.sound]`) plus `pinned:C14`, and is
      generated from the measured baseline, never typed.
- [ ] `lcN_plusValidInt`'s and `lcN_plusValidZTime`'s `Statement` cells must state the
      CONDITIONAL form honestly: validity for every n ≥ 1 and arbitrary parameter formulas, at the
      `.ZTime` class, with `.Base` not claimed.
- [ ] Run the complete gate set (below) and confirm every gate green against its pre-task
      baseline.
- [ ] Commit with an explicit file list.

**Timing**: 1 hour

**Depends on**: 1, 5

**Verification Tier**: full

**Scope Hypothesis**: seven new C14 probe lines, seven matching `C14_BASELINE` rows, and seven new
`docs/theorem-index.md` rows — one per public *theorem* in the two new modules (`omega_limit`,
`omega_chain`, `intOrder_omega_cofinal`, `gle_iff`, `bigAnd_iff`, `lcN_plusValidInt`,
`lcN_plusValidZTime`); the four definitions (`bigAnd`, `lcAnte`, `lcCons`, `lcN`) carry no ledger
row of their own. This count is this plan's own forward-looking estimate, not a carried figure;
confirm it at implementation time by enumerating the actual public declarations in the two new
modules, and adjust the row count to match what is there rather than to match this number.

**Files to modify**:
- `scripts/check-module-invariants.sh` - new `#print axioms` lines in the C14 probe block and the
  matching measured rows in `C14_BASELINE`
- `docs/theorem-index.md` - one row per landed public result

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (unscoped, full
  project) exits 0. Read the guard's own `result` verdict; never a pipe exit code.
- `bash scripts/check-module-invariants.sh` exits 0, with C14 reporting
  "every pinned declaration matches its axiom baseline". If C14 fails, confirm from its
  expected-vs-actual diff that only the new lines differ; an existing row moving is a HARD STOP,
  not a new baseline.
- `bash scripts/check-metalogic-cycles.sh` exits 0 against its pre-task baseline, with no new
  upward-import edge in assertion B's allowlist (expected: the new modules live inside
  `PlusLanguage/`, so none is added).
- `bash scripts/check-evidence-probes.sh` exits 0 (covers Phase 1's new entry).
- `grep -rn "sorry" FormalSystem/PlusLanguage/PlusOmegaChain.lean FormalSystem/PlusLanguage/PlusLCSchema.lean`
  returns nothing, and neither module contains a prohibited vacuous-definition pattern
  (`:= True`, `:= Unit`, `:= trivial`).
- `bash .claude/scripts/verify-deploy.sh` exits 0 for the doc/markdown surface this phase touches
  (`docs/theorem-index.md`); under a batch gate deferral, record in this phase's verification
  notes that the full set was deferred to the batch stage rather than independently run.
- Every `docs/theorem-index.md` row added carries a fully qualified `Lean name`, no line numbers in
  `File`, and an `Axioms` cell whose value was copied from the measured C14 output.

---

## Lean Challenge Statements

```lean
import FormalSystem.PlusLanguage.PlusPasting
import FormalSystem.PlusLanguage.PlusIntTransfer
import FormalSystem.Semantics.IntNormalForm

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics

/-- The ω-limit-of-splices principle, class-generic, under an explicit cofinality hypothesis. -/
theorem omega_limit {F : TaskFrame} [F.IsRegular] {τ : ℕ → WorldHistory F} {c : ℕ → F.Duration}
    (hc : ∀ k, c k < c (k + 1)) (hcof : ∀ x : F.Duration, ∃ k, x ≤ c k)
    (hag : ∀ k x, x ≤ c k → (τ (k + 1)).state x = (τ k).state x) :
    ∃ lim : WorldHistory F, ∀ k x, x ≤ c k → lim.state x = (τ k).state x := sorry

/-- A strictly increasing `ℕ`-indexed sequence in `ℤ` is cofinal. False over a dense order. -/
theorem intOrder_omega_cofinal (c : ℕ → ℤ) (hc : ∀ k, c k < c (k + 1)) (x : ℤ) :
    ∃ k, x ≤ c k := sorry

/--
Iterate the splice stage and take the ω-limit: given a stability-modal recurrence family `A`
supplying, along every history through the evaluation state, a further `A (k+1)`-point after
every `A k`-point, there is one history carrying all of them.

The cofinality hypothesis `hcof` is the single binder at which the ℤ-dependence of every
downstream consumer is isolated; `intOrder_omega_cofinal` is its only available discharge today.
-/
theorem omega_chain {F : TaskFrame} [F.IsRegular] (M : TaskModel F) (σ : WorldHistory F)
    (t : F.Duration) (A : ℕ → PlusFormula)
    (hcof : ∀ c : ℕ → F.Duration, (∀ k, c k < c (k + 1)) → ∀ x : F.Duration, ∃ k, x ≤ c k)
    (hstart : ∃ s, t ≤ s ∧ PlusTruthAt M σ s (A 0))
    (hstep : ∀ (ρ : WorldHistory F), ρ.state t = σ.state t →
      ∀ k s, t ≤ s → PlusTruthAt M ρ s (A k) →
        PlusTruthAt M ρ s (dstab (someFuture (A (k + 1))))) :
    ∃ (ρ : WorldHistory F) (c : ℕ → F.Duration), ρ.state t = σ.state t ∧
      (∀ k, c k < c (k + 1)) ∧ (∀ k, t ≤ c k ∧ PlusTruthAt M ρ (c k) (A k)) := sorry

/-- Finite conjunction of an `ℕ`-indexed family, with a uniform `top` base case. -/
def bigAnd : ℕ → (ℕ → PlusFormula) → PlusFormula := sorry

/-- LC_n's antecedent: `⊡ G≤ ⋀_{i<n} (⟐α_i → ⟐F⟐α_{i+1 mod n})`. -/
def lcAnte (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula := sorry

/-- LC_n's consequent: `⟐ G≤ ⋀_{i<n} (⟐α_i → F⟐α_{i+1 mod n})`. -/
def lcCons (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula := sorry

/-- Reynolds 2003's infinite limit-closure schema, transposed to `⊡` with `G≤`. -/
def lcN (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula := sorry

/--
LC_n is valid on every model over a `FrameOver intOrder` frame, for every `n ≥ 1` and arbitrary
parameter formulas. The ℤ fibre is where the ω-chain's cofinality requirement is discharged.
-/
theorem lcN_plusValidInt (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) :
    PlusValidInt (lcN n α) := sorry

/--
LC_n is valid at the `.ZTime` frame class. `.Base` validity is OPEN: a paper argument by Zorn
plus the Extension Theorem exists but is unverified, and nothing here claims it.
-/
theorem lcN_plusValidZTime (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) :
    PlusValidZTime (lcN n α) := sorry

end FormalSystem.PlusLanguage
```

Two of these signatures are plan-time proposals whose exact binder shape the implementer may need
to adjust against the live library: `omega_chain`'s recurrence-family bundle (the probe's own
binder bundle, re-expressed at `WorldHistory`/`PlusTruthAt`) and `bigAnd`'s elaborated form. Per
`plan-compliance.md`'s Statement Fidelity section, an adjustment that makes a statement **weaker**
— adding a hypothesis, specialising a quantifier, or restating a strictly weaker claim under the
same name — is a `[BLOCKED]` escalation, not a permitted edit. `lcN_plusValidInt` and
`lcN_plusValidZTime` are the results of record and their signatures are fixed.

## Testing & Validation

- [ ] `lake env lean specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` exits 0 with
      empty output.
- [ ] `bash scripts/check-evidence-probes.sh` green, naming the new `WIRED` entry.
- [ ] Guarded scoped build green for `FormalSystem.PlusLanguage.PlusOmegaChain`,
      `FormalSystem.PlusLanguage.PlusLCSchema` and `FormalSystem.PlusLanguage`.
- [ ] Guarded unscoped build (`-- build`, no module) green.
- [ ] Zero `sorry` in both new modules; zero vacuous definitions.
- [ ] `bash scripts/check-module-invariants.sh` green, C14 matching the re-measured baseline.
- [ ] `bash scripts/check-metalogic-cycles.sh` green against its pre-task baseline, no new upward
      edge.
- [ ] `bash .claude/scripts/verify-deploy.sh` green for the touched doc surface.
- [ ] Every landed public result has a `docs/theorem-index.md` row with a fully qualified Lean
      name, an honest conditional statement, the correct frame class, and a measured
      `pinned:C14` axiom cell.
- [ ] No claim anywhere in the landed content asserts `.Base` validity of `lcN`, or any
      completeness or axiomatizability property of TM-plus + LC_n.

## Artifacts & Outputs

- `specs/864_land_lc_schema_limit_closure_soundness/plans/01_lc-schema-limit-closure-soundness.md`
  (this file)
- `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` (promoted source of record)
- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` (new)
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` (new)
- Edits to `FormalSystem/PlusLanguage.lean`, `FormalSystem.lean`,
  `scripts/check-evidence-probes.sh`, `scripts/check-module-invariants.sh`,
  `docs/theorem-index.md`
- `specs/864_land_lc_schema_limit_closure_soundness/summaries/01_lc-schema-limit-closure-soundness-summary.md`

## Rollback/Contingency

Each phase closes with its own commit, so the ordinary contingency is to stop at the last green
phase and leave the rest `[NOT STARTED]`; the new modules are leaves that nothing imports, so a
partially landed port never breaks the existing tree.

- **If Phase 5 cannot close** (the `G≤` step does not go through at the ℤ fibre): mark Phase 5
  `[BLOCKED]`, record the goal state reached and what was tried, and return `partial` with
  `requires_user_review: true`. Do NOT introduce a `sorry`, a vacuous definition, or a weakened
  restatement of `lcN_plusValidInt`.
- **If C14 shows an existing pinned row moving** (not only the new lines): HARD STOP. Do not
  re-baseline. Report it — a moved existing profile under concurrent sibling activity is more
  likely a foreign edit than this task's own effect.
- **If a foreign commit, foreign uncommitted modification, or a build this task did not start is
  observed**: STOP and report after checking `git log` to confirm the work is not this task's own,
  per the dispatch's concurrency note.
- **If a genuine revert of uncommitted work is required**: take a snapshot first — see
  `context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
  out-of-scope override flag — then perform the revert. Never emit `git-snapshot.sh` in its
  default reverting form as a routine start-of-phase precaution; an ordinary defensive checkpoint
  uses `--no-revert`.
