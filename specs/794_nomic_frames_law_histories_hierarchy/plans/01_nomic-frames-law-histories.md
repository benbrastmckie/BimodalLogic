# Implementation Plan: Nomic frames, law-histories, and the nomic hierarchy

- **Task**: 794 - Formalize the paper's nomic frames, law-histories, and the nomic hierarchy
- **Status**: [IMPLEMENTING]
- **Effort**: 11 hours
- **Dependencies**: None (task 795, the nomic operator and its logic, depends on this one)
- **Research Inputs**: specs/794_nomic_frames_law_histories_hierarchy/reports/01_nomic-frames-law-histories-hierarchy.md
- **Artifacts**: plans/01_nomic-frames-law-histories.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Build a new `FormalSystem/Semantics/Nomic/` cluster carrying the frame-level half of the paper's
nomic appendix: `NomicFrame D` (one carrier, one task relation per world state), the law-history
sets `lawHist F w` and their union `HF F`, the three properties of `def:nomic-properties` with the
two trivial implications, `lem:nomic-occurrence`, `lem:nomic-recovery` in full, the ℤ-time
presentation of `def:nomic-witnesses`, and `prop:nomic-hierarchy`'s three finite witnesses with
their independence statements. Nothing nomic exists in the tree today, so every phase is additive;
the whole substrate it consumes (`FrameOver`, `PartialHistory`, `Extension`, `IntNormalForm`) is
already in place and needs no adaptation. Definition of done: the cluster builds under
`lake build FormalSystem` with zero structural `sorry`, `scripts/check-module-invariants.sh`
exits 0, and the paper's six nomic anchors resolve against
`docs/reference/paper-definitions-of-record.md`.

### Research Integration

The research report compiled, sorry-free, nearly the entire design against the built project
(`lean_run_code`, seven probes): the structure and its derived family, the regularity class and
the instance that feeds `FrameOver.IsRegular` back to synthesis, `lawHist`/`HF` and the
`WorldHistory` bridge, the three properties and both implications, `lem:nomic-occurrence`, the
two-point-history lemma, **the full `lem:nomic-recovery` biconditional**, `ofStepFamily` with its
`rfl` bridge to `FrameOver.ofStep`, the adjacency characterisation of `lawHist`, the step-path
invariant helper, and **witness 1 of `prop:nomic-hierarchy` complete**. Three things were *not*
compiled and are the plan's real work: `stepPath_forward_invariant` (R8's forward-only companion),
witness 2 (lawful but not static — the one genuinely hard proof), and witness 3 (static and
lawful but not uniform). Phases 1-3 are therefore transcription of verified text with the two
recorded adjustments (100-column reflow, `_`-prefixed unused binders); phases 4-5 are the new
proof work. Four report findings are load-bearing and are not re-litigated here: `at` is a
reserved token (declare `NomicFrame.at` dotted, outside the namespace); `lawHist` must range over
bare functions `↑D → F.World`, not over `WorldHistory`s, or the union over `w` does not typecheck;
the two-point history must be a *named general lemma over `TaskFrame`*, because an inline
construction at `F.at w` fails with four `rw` type mismatches; and `rw` must not be used across a
derived frame's carrier — `refine Iff.trans … ?_` / `exact` instead.

### Prior Plan Reference

No prior plan. This is the task's first planning round.

### Roadmap Alignment

This dispatch carried no `roadmap_path`, so `specs/ROADMAP.md` was not consulted and no
roadmap-review or roadmap-update phase is included.

### Siting Decision (recorded as the dispatch asks)

**`FormalSystem/Semantics/Nomic/`, not `FormalSystem/OpenLanguage/Nomic/`.** A nomic frame
mentions no object language, no formula and no model, and every tool it consumes lives under
`Semantics/`. `OpenLanguage/` imports `Semantics/`, never the reverse, so siting the frames here
lets task 795's `◈` operator live in `OpenLanguage/` and import them; siting them under
`OpenLanguage/` would invert that dependency and place `def:nomic-frame` in a directory whose
other modules are all about formulas. **The cost, stated plainly**: the operator of task 795 will
live in a different directory from its frames, so that task carries one extra import and the two
halves of the nomic appendix are not co-located. The alternative buys that co-location at the
price of the dependency inversion and of making the frames unreachable for any future
purely-semantic consumer that does not want `OpenLanguage`'s imports. The import direction is the
deciding argument.

### Namespace facts the implementer needs (verified at plan time by reading the module)

In `FormalSystem/Semantics/IntNormalForm.lean`, `IsStepPath` (line 274) and `ofStepRel` (line 391)
sit **directly** in `FormalSystem.Semantics` — outside every `namespace FrameOver` block — while
`ofStep`, `ofStep_step`, `ofStep_isRegular`, `mem_HF_iff_adjacent` and
`isTotal_respects_iff_adjacent` are inside one. Spell them `IsStepPath`/`ofStepRel` and
`FrameOver.ofStep…` respectively. The nomic cluster declares `NomicFrame` at the
`FormalSystem.Semantics` level with its lemmas in a nested `namespace NomicFrame`, mirroring how
`FrameOver` is organised in `TaskFrame.lean`.

## Goals & Non-Goals

**Goals**:
- `NomicFrame`, `NomicFrame.at`, `IsRegular`, `instAtIsRegular`, `TaskRel`, `taskRel_eq`,
  `lawHist`, `HF`, `mem_lawHist_iff`, `Lawful`, `Static`, `Uniform`, `static_of_uniform`,
  `lawful_of_uniform`, `occurrence`, `exists_worldHistory_two_point`,
  `taskRel_imp_of_lawHist_eq`, `lawHist_eq_iff_taskRel_eq`, `ofStepFamily`, `ofStepFamily_at`,
  `ofStepFamily_isRegular`, `mem_lawHist_iff_isStepPath`, `mem_lawHist_ofStepFamily_iff`,
  `lawHist_mono_of_le`, `stepPath_invariant`, `stepPath_forward_invariant`, `nomic_hierarchy` —
  the identifier set pinned under `## Lean Challenge Statements` below, exactly, no more and no
  fewer
- The three per-witness carriers, their one-step relation families, their bi-seriality
  obligations and their named independence theorems (static-not-lawful, lawful-not-static,
  static-and-lawful-not-uniform), plus the supporting invariant lemmas each proof needs. These
  are deliberately **not** in the Challenge set: a witness's statement cannot be pinned without
  its carrier and its relation already existing, so pinning one would require real (non-`sorry`)
  bodies for the very declarations the phase is meant to produce. The bundled hierarchy theorem,
  which *is* pinned, carries their joint content as three existentials. Their names are fixed in
  Phases 4 and 5
- A four-module cluster with its sibling aggregator and README, wired into `FormalSystem.lean` and
  `FormalSystem/Semantics.lean`, so the cluster is in the build graph and gated
- Six `KNOWN-ANCHORS` rows in `docs/reference/paper-definitions-of-record.md` (one per nomic
  anchor), so C15 resolves every new citation
- Docstrings that record the choice dependence honestly (`rmk:choice`): `occurrence` and both
  recovery theorems are theorems of ZFC through `thm:extension`'s Zorn appeal, and each witness's
  *Saturation* goes through `TaskFrame.saturation_of_finite`, which is also choice-dependent
- CONDITIONAL (Phase 6, only if Phases 1-5 close with time in hand): clause (1) of the cut
  `thm:nomic-primitive`, the primitive-level two-point form of *Static*. Left out of the Challenge
  set precisely because it is conditional: the pinned set must match the delivered set exactly,
  and its name and statement are fixed in Phase 6

**Non-Goals**:
- The nomic operator `◈`, its truth clause, and its logic — task 795, which depends on this one
- Clauses (2), (3) and (4) of `thm:nomic-primitive`. Clause (2) needs a three-point partial
  history whose well-definedness argument (coinciding times forcing coinciding states via
  `lem:nullity`, over a nested-`if` state function) has no precedent in the tree; (3) and (4) are
  recorded as consumerless in the cut note itself, and (4) duplicates Phase 3's adjacency bridge
- Any edit to `possible_worlds.tex` — clearing the `% PORT:` markers under `lem:nomic-occurrence`
  and `lem:nomic-recovery` and closing their proofs with `\leanproof{}`. A different repository,
  read-only input here; the declarations are named so a later `\leanproof{\texttt{NomicFrame.…}}`
  needs no rename. Listed as a follow-up for the author
- `docs/theorem-index.md` rows for the new declarations, and any re-pin of the record file's
  whole-file `PINNED_COMMIT`/`FILE_CHECKSUM` sentinels. The theorem index is inside concurrent
  task 789's declared `file_scope`; the sentinels are re-pinned only when absorbing a drift
  *correction*, which this task is not
- Refactoring `FormalSystem/Semantics/DeterministicBridge.lean:146-165` to call
  `exists_worldHistory_two_point`, or promoting that lemma into
  `Semantics/Extension/Extension.lean`. Both are recorded in its docstring as available once those
  files are free; neither is this task's business
- Absorbing the 26 pre-existing drifted anchors that make `scripts/check-paper-definitions.sh`
  already red. Unrelated to this task and explicitly not a regression of it

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `FormalSystem.lean` (the generated root) and `FormalSystem/Semantics.lean` are inside concurrent task 789's declared `file_scope`, and 789 is dispatched to *implement* this same cycle | H | H | Both edits are single-line inserts. Re-read each file immediately before editing and again immediately before committing; stage with an explicit path list (`git add -- <file>`), never a directory or glob. After `lake exe mk_all --lib FormalSystem`, inspect `git diff -- FormalSystem.lean`: if the only added lines are the Nomic ones, commit; if a foreign import line appears, that is a sibling's in-flight file — STOP and report per the dispatch's concurrency note rather than absorbing it, and insert only the Nomic line(s) by hand in sorted position instead |
| Witness 2's lawfulness is the one genuinely hard proof and was not compiled during research | M | M | Isolated in its own phase (5), behind two small independently-statable helpers (`stepPath_forward_invariant`, `lawHist_mono_of_le`) landed in Phase 3. If it stalls, Phases 1-4 already discharge `prop:nomic-hierarchy`'s first sentence, witness 1, witness 3 and the uniformity gap; only the lawful-not-static half of the independence claim is outstanding, and that is a `[BLOCKED]` phase to raise — never a `sorry` |
| C15 rejects a docstring citation of a nomic anchor | M | M | Phase 1 adds all six `KNOWN-ANCHORS` `LIVE-UNPINNED` rows before any gate run, and the citation discipline is "by name, never a verbatim quote". The six resolved `sha256` values are recorded in Phase 1's tasks, so promoting any row to a pinned MANIFEST row is a copy-paste if a docstring does end up quoting text |
| C34a/C34b (`Constraints consumed:` markers) fire on the new instance-taking declarations | M | M | Every new declaration carrying `[F.IsRegular]` or `[NomicFrame.IsRegular]` and reading as a constraint claim gets a `Constraints consumed:` line: `occurrence` and both recovery theorems consume all four (through `thm:extension`); `static_of_uniform`/`lawful_of_uniform` take no instance binder and consume none |
| C8 (sibling aggregator), `readme-lint.sh` check 1 (README per directory), C33 (byte-current root) all attach to the new directory | M | H | Phase 1 creates `Semantics/Nomic.lean` and `Semantics/Nomic/README.md` in the same commit as the first module and regenerates the root; every later file-adding phase re-runs `mk_all` and adds the aggregator import line |
| A new module not reachable from the generated root is not built by `lake build FormalSystem`, so "green" would be vacuous | H | M | The root is regenerated in the same phase as each new file, so every subsequent phase's build actually compiles the cluster. This is why `mk_all` is not deferred to the final phase |
| C19 (docstring-coverage floor, 90%) and C28 (per-file warning budget) | L | M | Every new declaration gets a docstring as it is written, not retrofitted; reflow the research report's two long-line lint warnings on transcription (100-column limit) |
| Module length (1500-line linter) if the cluster lands as one file | L | L | Four modules by construction: `Frame.lean`, `Recovery.lean`, `ZTime.lean`, `Witnesses.lean` |
| `lean_local_search`'s index was `warming` throughout research, so absence findings rest on grep sweeps | L | L | Announced rather than treated as a negative finding; re-run `lean_local_search "NomicFrame"` at implementation time and treat an empty result as proof of absence only under `index: consulted` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 6 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 7 | 2, 3, 4, 5, 6 |

Phases within the same wave can execute in parallel.

### Phase 1: Cluster scaffolding and the frame layer [COMPLETED]

**Goal**: `def:nomic-frame` and `def:nomic-properties` exist, build, and are gated — the
structure, the derived family, regularity, law-histories, the three properties, the two trivial
implications, and `lem:nomic-occurrence`.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Nomic/Frame.lean` with the copyright header, a `/-! … -/`
      module docstring, and the report's R1-R4 text: `structure NomicFrame` (field `World`,
      instance-implicit `worldNonempty`, field `PosRel`), `attribute [instance]
      NomicFrame.worldNonempty`, `def NomicFrame.at` **declared dotted, outside `namespace
      NomicFrame`** (`at` is a reserved token), `class IsRegular`, `instance instAtIsRegular`,
      `def TaskRel` + `taskRel_eq`, `def lawHist`, `def HF`, `theorem mem_lawHist_iff`, the three
      properties, `static_of_uniform`, `lawful_of_uniform`, `theorem occurrence`
- [x] Keep `NomicFrame.at` a plain `def` — **not** `@[reducible]`: synthesis keys
      `instAtIsRegular` on `FrameOver.IsRegular (F.at w)`
- [x] Give `occurrence` a `Constraints consumed:` line naming all four constraints, and a choice
      note: it is a theorem of ZFC through `thm:extension`'s Zorn appeal (`rmk:choice`). Do not
      advertise it as choice-free; `DeterministicBridge.lean`'s "Choice dependence, recorded
      honestly" section is the model
- [x] Create `FormalSystem/Semantics/Nomic.lean`, the sibling aggregator (C8), importing
      `Frame.lean` and carrying a `## Modules` docstring list
- [x] Create `FormalSystem/Semantics/Nomic/README.md` (`readme-lint.sh` check 1, gated) with a
      `Last verified` date
- [x] Add six `KNOWN-ANCHORS` `LIVE-UNPINNED` rows to
      `docs/reference/paper-definitions-of-record.md` — `def:nomic-frame`,
      `def:nomic-properties`, `def:nomic-witnesses`, `prop:nomic-hierarchy`,
      `lem:nomic-occurrence`, `lem:nomic-recovery` — each noting that the tree cites it by name
      and quotes no text. Do **not** touch the whole-file `PINNED_COMMIT`/`FILE_CHECKSUM`
      sentinels. If a docstring does quote an anchor verbatim, promote that row to a MANIFEST row
      `<anchor>|env|-|-|<sha>` with the sha resolved during research:
      `def:nomic-frame` `60fdc0699603f6fd5f2a10f4e6ee8e17e96d569657e24e8b888849f6d914f60f`;
      `def:nomic-properties` `10c70b4fbcb954f2771ed6afe41dfdfeb86a69b87ea05cc03a2044f49e0b1b8d`;
      `def:nomic-witnesses` `3f2b3ad26238cc701fcce96aa3054c5d7172446bcb29b0a2fe0425eac9db4ae2`;
      `prop:nomic-hierarchy` `7eb2c665feef36bfc6e16b4676292cc2442a85e714d3321fe1bef87737f7779a`;
      `lem:nomic-occurrence` `be1804f3a08925d84878066a16f635555e0edc1d42f39b8ab3b28b7ba35efaad`;
      `lem:nomic-recovery` `3f7df2521f4b222f19cd055cde9767ac441c8b199fad3b67a1819a0199b768e5`
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem`, then inspect
      `git diff -- FormalSystem.lean` under the concurrency protocol in Risks before staging

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is **six anchors** needing record rows and **two** record
files to touch, carried from the research report's "Paper anchors: resolved rows" table.
Confirm at implementation time with
`grep -nE 'nomic-(frame|properties|witnesses)|nomic-(hierarchy|occurrence|recovery)' docs/reference/paper-definitions-of-record.md`
immediately before editing: a row that already exists is not added twice, and an anchor the new
docstrings do not actually cite needs no row at all.

**Tier Justification**: `Frame.lean` is a leaf module with no dependents in the tree, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
plus `bash scripts/readme-lint.sh FormalSystem` (the one gated check the new directory newly
triggers) cover this phase's whole blast radius.

**Files to modify**:
- `FormalSystem/Semantics/Nomic/Frame.lean` - new: R1-R4, the frame layer
- `FormalSystem/Semantics/Nomic.lean` - new: sibling aggregator (C8)
- `FormalSystem/Semantics/Nomic/README.md` - new: directory README (readme-lint check 1)
- `docs/reference/paper-definitions-of-record.md` - six KNOWN-ANCHORS rows appended
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
  exits 0, with the guard's exit status checked directly rather than inferred from stdout
- `bash scripts/readme-lint.sh FormalSystem` exits 0
- `grep -c 'sorry' FormalSystem/Semantics/Nomic/Frame.lean` reports 0
- `grep -n 'nomic-' docs/reference/paper-definitions-of-record.md` shows the six new rows inside
  the `KNOWN-ANCHORS` block

---

### Phase 2: The two-point history and `lem:nomic-recovery` [COMPLETED]

**Goal**: `lem:nomic-recovery` in full — `H_F^w = H_F^u` iff `⇒^w = ⇒^u` — on top of a named
general two-point-history lemma over `TaskFrame`.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Nomic/Recovery.lean` and transcribe R5's
      `exists_worldHistory_two_point` into `namespace FormalSystem.Semantics.PartialHistory`, so a
      later promotion into `Semantics/Extension/Extension.lean` is a pure file move
- [x] Its docstring records: it belongs beside `PartialHistory.point`/`occurrence`; it is stated
      with `p q : F.WorldState` deliberately, because an inline construction at `F.at w`
      elaborates the `if`-terms at `(F.at w).WorldState` while the surrounding `have`s state them
      at `F.World`, and all four `respects_task` branches then fail on `rw`; and
      `DeterministicBridge.lean:146-165` carries the same construction inline and can call this
      lemma once that file is free
- [x] Transcribe R6's `taskRel_imp_of_lawHist_eq` and `lawHist_eq_iff_taskRel_eq`, keeping the
      paper's case order: `d = 0` by `nullity_identity` at `F^w` and `F^u`, `d > 0` through the
      two-point history and `thm:extension`, `d < 0` by the reflection convention reducing to the
      positive case. The `⇐` direction is `simp only [lawHist, h]`
- [x] `Constraints consumed:` lines on both, plus the ZFC/`rmk:choice` note
- [x] Add the import to `Semantics/Nomic.lean` and re-run `lake exe mk_all --lib FormalSystem`

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: `Recovery.lean` is a new leaf inside the cluster whose only dependent is
`Semantics/Nomic.lean`, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
builds both the module and that aggregator and covers the whole edit.

**Files to modify**:
- `FormalSystem/Semantics/Nomic/Recovery.lean` - new: R5-R6, the two-point history and recovery
- `FormalSystem/Semantics/Nomic.lean` - one import line and one `## Modules` bullet
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
  exits 0
- `grep -c 'sorry' FormalSystem/Semantics/Nomic/Recovery.lean` reports 0
- `mcp__lean-lsp__lean_verify FormalSystem.Semantics.NomicFrame.lawHist_eq_iff_taskRel_eq` reports
  the expected ZFC axiom set (`Classical.choice` present), confirming the `rmk:choice` docstring
  claim rather than asserting choice-freedom

---

### Phase 3: The ℤ-time presentation and the step-path invariants [COMPLETED]

**Goal**: `def:nomic-witnesses` as `ofStepFamily`, the two `lawHist`-over-ℤ bridges, the
monotonicity lemma, and both step-path invariant helpers — everything the three witnesses consume.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Nomic/ZTime.lean` and transcribe R7: `def ofStepFamily` (its
      `PosRel` built from `ofStepRel (R w)`, which lives directly in `FormalSystem.Semantics`, not
      in `FrameOver`), `theorem ofStepFamily_at` — which holds **by `rfl`**, the fact that makes
      every ℤ-normal-form lemma apply unchanged — `instance ofStepFamily_isRegular` with
      `regular w := FrameOver.ofStep_isRegular (R w) (fwd w) (bwd w)` **as a bare term**, never
      via `rw [ofStepFamily_at w]` (which fails to synthesize
      `Finite (ofStepFamily R fwd bwd).World`)
- [x] `theorem mem_lawHist_iff_isStepPath := FrameOver.isTotal_respects_iff_adjacent (F.at w) τ` —
      one term, no tactic: `lawHist` is literally that lemma's left-hand side. Record in the
      docstring why `isTotal_respects_iff_adjacent` and not `mem_HF_iff_adjacent` is the primary
      bridge, and that the latter stays reachable through `mem_lawHist_iff`
- [x] `theorem mem_lawHist_ofStepFamily_iff` via `refine Iff.trans … ?_`, **not** `rw`: the
      membership's type is `↑intOrder → (ofStepFamily …).World`, which `rw` will not match against
      a `ℤ → W` binder (the `SlicedFrame.lean:360` pattern)
- [x] `theorem lawHist_mono_of_le` — pointwise containment of one `R v` in `R u` gives
      `lawHist v ⊆ lawHist u` — a two-line consequence of `mem_lawHist_ofStepFamily_iff`
- [x] Transcribe R8's `stepPath_invariant` using `omega` (not `ring`) for the three index
      identities and `Int.induction_on`'s `zero`/`succ`/`pred` case names (`hz`/`hp`/`hn` are
      rejected on this pin) *(deviation: altered — `Int.le_induction` is deprecated on this pin in favour of `Int.leInduction`; the `zero`/`succ`/`pred` case names for `Int.induction_on` were correct as recorded)*
- [x] Write `stepPath_forward_invariant`, the forward-only companion, by `Int.le_induction` —
      **the one declaration in this phase whose proof was not compiled during research**; it is a
      three-line mirror of `stepPath_invariant`'s `succ` branch
- [x] Add the import to `Semantics/Nomic.lean` and re-run `lake exe mk_all --lib FormalSystem`

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: `ZTime.lean` is a new leaf whose only dependents are
`Semantics/Nomic.lean` and the `Witnesses.lean` of Phase 4, which does not exist yet, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
covers every call site this phase creates.

**Files to modify**:
- `FormalSystem/Semantics/Nomic/ZTime.lean` - new: R7-R8, the ℤ-time presentation and invariants
- `FormalSystem/Semantics/Nomic.lean` - one import line and one `## Modules` bullet
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
  exits 0
- `grep -c 'sorry' FormalSystem/Semantics/Nomic/ZTime.lean` reports 0
- An `example … := rfl` pins `ofStepFamily_at` as definitional rather than merely provable

---

### Phase 4: Witnesses 1 and 3 [COMPLETED]

**Goal**: `prop:nomic-hierarchy`'s static-not-lawful witness on `{a,b,c}` and its
static-and-lawful-not-uniform witness on `{a,b,c}`, each with its independence theorems.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Nomic/Witnesses.lean`: the shared carrier `inductive W3 | a |
      b | c deriving DecidableEq`, a hand-written `Fintype` instance (`elems := {a,b,c}`,
      `complete := by intro x; cases x <;> simp`) and a `Nonempty` instance — the
      `OpenLanguage/OpenOckhamist.lean:130-145` house pattern; `deriving Fintype` is used nowhere
      in this tree
- [x] Witness 1, transcribed from R9 (compiled during research): `R1` written as a `match` with
      `| _ => Eq`, so `R1 .a` and `R1 .b` reduce to the same term and `F1_lawHist_a_eq_b` holds
      **by `rfl`**; `R1_fwd`/`R1_bwd`; `F1 := ofStepFamily R1 R1_fwd R1_bwd`;
      `F1_const_of_mem_a`; `F1_c_invariant`; `F1_static`; `alt` (the alternating `a`/`b` path);
      `alt_mem_c`; `F1_not_lawful`. Reflow the two long `refine … (P := …) ?_ 0 Iff.rfl n` lines
      to 100 columns
- [x] Witness 3, the structural mirror of witness 1: `R3` with `R_a = Eq` and
      `R_b = R_c = {(a,a)} ∪ ({b,c} × {b,c})`, written as a `match` so that `R3 .b` and `R3 .c`
      reduce to the same term and `R_b ≡ R_c` is again `rfl`; `R3_fwd`/`R3_bwd`;
      `F3 := ofStepFamily R3 R3_fwd R3_bwd` *(deviation: altered — `R_b`/`R_c` written as "both ends are `a` or neither is", which is the same five-pair relation as `{(a,a)} ∪ ({b,c} × {b,c})` and makes the two-sided `R_b`-invariance of `u = a` immediate; witnesses live in a dedicated `namespace NomicHierarchy`, per `FrameConstraintIndependence.lean`'s house style, rather than at the bare `Semantics` level)*
- [x] `F3_static` and `F3_lawful`: `P u := (u = a)` is a two-sided `R_b`-invariant
      (`stepPath_invariant`), so every `τ ∈ lawHist b` is either constantly `a` or never `a`;
      `lawHist a` is the constants (`stepPath_invariant` at `R_a = Eq`, as in
      `F1_const_of_mem_a`), and a constant lies in every `lawHist w` by reflexivity of each `R_w`
- [x] `F3_not_uniform`: the alternating `b`/`c` path lies in `HF` through `lawHist b` but not in
      `lawHist a`, which would force `τ 0 = τ 1`
- [x] Add the import to `Semantics/Nomic.lean` and re-run `lake exe mk_all --lib FormalSystem`

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that **witness 1 transcribes without change** from the
research report's R9 block, which that report states compiled clean with only two long-line lint
warnings. Confirm at implementation time by building the module immediately after transcribing
witness 1 and before starting witness 3 — a transcription error surfaces as a compile failure in
a block with a known-good origin, so it is diagnosed as drift (the paper, the pin, or the
reflow), not as a design problem.

**Tier Justification**: `Witnesses.lean` is a new leaf whose only dependent is
`Semantics/Nomic.lean`, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
covers the whole edit, and witness independence is a statement about these two frames alone.

**Files to modify**:
- `FormalSystem/Semantics/Nomic/Witnesses.lean` - new: the shared carrier, witness 1, witness 3
- `FormalSystem/Semantics/Nomic.lean` - one import line and one `## Modules` bullet
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
  exits 0
- `grep -c 'sorry' FormalSystem/Semantics/Nomic/Witnesses.lean` reports 0
- `F1_lawHist_a_eq_b` and the witness-3 analogue each close by `rfl`, pinning the `match`-with-
  `| _ => Eq` shape as definitional

---

### Phase 5: Witness 2 and the aggregate hierarchy theorem [COMPLETED]

**Goal**: the lawful-but-not-static witness on `{a,b,e}` — the one genuinely hard proof — and
`nomic_hierarchy`, the bundled statement of `prop:nomic-hierarchy`.

**Tasks**:
- [x] Add the carrier `inductive W3e | a | b | e` with its hand-written `Fintype`/`Nonempty`
      instances, and `R2` with `R_a = {(a,a),(b,b),(e,a),(e,e)}`,
      `R_b = {(a,a),(b,b),(e,b),(e,e)}`, `R_e = R_a ∪ R_b`; `R2_fwd`/`R2_bwd` (both relations are
      bi-serial, so `ofStepFamily` applies verbatim); `F2 := ofStepFamily R2 R2_fwd R2_bwd`
- [x] `F2_lawful`, case on which `lawHist v` the history came from:
      - `τ ∈ lawHist a`: `P u := (u = b)` is a two-sided `R_a`-invariant, so `τ x = b` forces `τ`
        constantly `b` and hence `τ ∈ lawHist b` by reflexivity of `R_b` at `b`; otherwise
        `τ x ∈ {a, e}` and `lawHist a ⊆ lawHist e` by `lawHist_mono_of_le` (`R_a ⊆ R_e`). Mirror
        for `τ ∈ lawHist b`
      - `τ ∈ lawHist e`: no `R_e`-path visits both `a` and `b` — forward from `a` only `a` is
        reachable, forward from `b` only `b` — which is `stepPath_forward_invariant` at
        `P u := (u = a)` and at `P u := (u = b)`. With `b` excluded, every step of `τ` lies in
        `R_a` (the `R_e`-pairs not mentioning `b` are exactly `(a,a),(e,a),(e,e) ⊆ R_a`), so
        `τ ∈ lawHist a`; symmetrically for `a` excluded
- [x] `F2_not_static`: `σ₀ᵃ := fun n => if n ≤ 0 then e else a` lies in `lawHist a ⊆ HF` with
      `σ₀ᵃ 0 = e` and `σ₀ᵃ 1 = a`, while `σ₀ᵇ := fun n => if n ≤ 0 then e else b` lies in
      `lawHist e` and not in `lawHist a` (its step at `n = 0` is `R_a e b`, which is false), so
      `Static` would equate `lawHist e` with `lawHist a`
- [x] State `nomic_hierarchy` as the three existentials of the Challenge block, each bundling its
      witness's regularity instance as `∃ _ : F.IsRegular, …`, discharged by the per-witness
      theorems of Phases 4-5 plus `static_of_uniform`/`lawful_of_uniform` from Phase 1
- [ ] If `F2_lawful` stalls: mark this phase `[BLOCKED]`, record what was reached, and raise it. *(deviation: not applicable — `F2_lawful` compiled on the first attempt, so no `[BLOCKED]` escalation was needed)*
      Do **not** place a `sorry` — the constraint is zero new structural `sorry` at the end of
      every phase, and `prop:nomic-hierarchy`'s other content is already landed by Phase 4

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: the edit stays inside `Witnesses.lean` plus one aggregator line, with no
externally visible signature change, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
is the cheapest check that covers it.

**Files to modify**:
- `FormalSystem/Semantics/Nomic/Witnesses.lean` - witness 2 and `nomic_hierarchy` appended
- `FormalSystem/Semantics/Nomic.lean` - `## Modules` bullet updated if the module summary changes

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
  exits 0
- `grep -c 'sorry' FormalSystem/Semantics/Nomic/Witnesses.lean` reports 0
- `mcp__lean-lsp__lean_verify FormalSystem.Semantics.nomic_hierarchy` reports a ZFC axiom set, and
  the docstring says so (each witness's *Saturation* goes through
  `TaskFrame.saturation_of_finite`, which is choice-dependent)

---

### Phase 6: CONDITIONAL -- `thm:nomic-primitive` clause (1) [COMPLETED]

**Goal**: the primitive-level form of *Static* — a two-point equation on the relativized relation
— if and only if Phases 1-5 close with time in hand.

**Decision gate**: fire this phase only if Phases 2-5 have all closed `[COMPLETED]`. If any of
them is `[BLOCKED]` or `[PARTIAL]`, or if the task's cycle budget is spent, close this phase
`[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` table whose single row records
the clause as not attempted, the reason, and the evidence (the blocking phase's status). The
clause is cut material with no consumer in the tree; nothing downstream waits on it.

**Tasks**:
- [x] Append `static_iff_taskRel_eq` to `FormalSystem/Semantics/Nomic/Recovery.lean`:
      `F.Static ↔ ∀ v w u d, F.TaskRel v w d u → F.TaskRel w = F.TaskRel u`. `⇒` is the two-point
      history (`exists_worldHistory_two_point`) plus `lawHist_eq_iff_taskRel_eq`; `⇐` is the
      definition of `lawHist` plus the same biconditional
- [x] Cite the clause as **cut material by file and header** —
      `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`, header
      "Primitive-level characterization of the nomic frames" — never as a paper anchor, so C15 is
      not asked to resolve `thm:nomic-primitive` against a record the file does not track
- [x] Do not attempt clause (2): its three-point partial history
      (`{⟨0,w⟩,⟨e,p⟩,⟨e+d,q⟩}`) needs a well-definedness argument with no precedent in the tree

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: one appended theorem in `Recovery.lean` with no signature change
anywhere, covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`.

**Files to modify**:
- `FormalSystem/Semantics/Nomic/Recovery.lean` - `static_iff_taskRel_eq` appended

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
  exits 0
- `grep -c 'sorry' FormalSystem/Semantics/Nomic/Recovery.lean` reports 0
- `grep -n 'thm:nomic-primitive' FormalSystem/Semantics/Nomic/Recovery.lean` shows the citation
  naming `appendix_cut_material.tex` and its header, not a bare anchor

---

### Phase 7: Library wiring, docs, and the full gate set [NOT STARTED]

**Goal**: the cluster is reachable from `FormalSystem/Semantics.lean`, documented in the
directory and parent READMEs, and green under the repository's complete gate set.

**Tasks**:
- [ ] Add `import FormalSystem.Semantics.Nomic` to `FormalSystem/Semantics.lean` and one
      `## Submodules` bullet describing the cluster. Re-read the file immediately before editing
      and again immediately before committing — it is inside concurrent task 789's declared
      `file_scope`
- [ ] Add a `Nomic/` entry to `FormalSystem/Semantics/README.md` (same concurrency protocol; this
      is `readme-lint.sh` check 2, reported and not gated, so if the file carries foreign
      uncommitted edits, record the entry as a reasoned exclusion rather than absorbing them)
- [ ] Finalize `FormalSystem/Semantics/Nomic/README.md`: the four modules, the paper anchors each
      one ports, the siting decision and its recorded cost, the choice-dependence note, and a
      `Last verified` date
- [ ] Final `lake exe mk_all --lib FormalSystem` and the `git diff -- FormalSystem.lean`
      inspection from Risks
- [ ] Run the full gate set below and fix only this task's own findings; a finding in a file
      outside this task's `file_scope` is possibly a sibling's in-flight edit and is reported, not
      silently repaired

**Timing**: 1.5 hours

**Depends on**: 2, 3, 4, 5, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Semantics.lean` - one import line and one `## Submodules` bullet
- `FormalSystem/Semantics/README.md` - one `Nomic/` entry
- `FormalSystem/Semantics/Nomic/README.md` - finalized
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project,
  unscoped) exits 0, with the guard's exit status captured un-piped
- `bash scripts/check-module-invariants.sh` exits 0 — C1, C3 (zero structural `sorry`, asserted
  by content), C4, C5, C8 (the new sibling aggregator), C9, C14, C15 (the six new anchors), C16
  (no linter finding beyond `scripts/nolints.json`), C19 (docstring-coverage floor), C23, C24
  (every module transitively imports `FormalSystem.Init`), C26, C28, C33 (byte-current generated
  root), C34a/C34b (`Constraints consumed:` honesty)
- `bash scripts/readme-lint.sh FormalSystem` exits 0
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0
- `bash scripts/typst-sync-check.sh` exits 0
- `bash .claude/scripts/verify-deploy.sh` — the complete repository gate set this tier requires —
  exits 0
- `bash scripts/check-paper-definitions.sh` is **advisory here only**: it is already red with 26
  pre-existing drifted anchors unrelated to this task. Assert only that the six nomic rows
  themselves resolve, and do not absorb the drift wave or re-pin the whole-file sentinels
- Every command's exit status is checked directly; a diff of captured stdout against a baseline is
  not accepted as evidence for any of them
- `git log --oneline` shows one commit per phase with no foreign commit interleaved into this
  task's range

## Lean Challenge Statements

The pinned set is the carrier-generic, frame-level API plus the bundled `nomic_hierarchy`. Two
declarations below deliberately carry **real bodies** rather than `sorry`: `NomicFrame.at` and
`ofStepFamily` are two-field record constructors with no proof content, and a `sorry` body for
either makes `(F.at w).WorldState` / `(ofStepFamily …).World` opaque, at which point none of the
ℤ-time statements that quantify over `ℤ → F.World` elaborates at all. The three witnesses'
carriers, relations and per-witness independence theorems are **not** pinned, for the same
reason inverted: their statements cannot exist before their carriers do, so pinning them would
require implementing them. `nomic_hierarchy` carries their joint content instead.

```lean
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.Extension

namespace FormalSystem.Semantics

/-- `def:nomic-frame`: one carrier, one task relation per world state. -/
structure NomicFrame (D : TemporalOrder) where
  World : Type
  [worldNonempty : Nonempty World]
  PosRel : World → World → D.PositiveCone → World → Prop

attribute [instance] NomicFrame.worldNonempty

variable {D : TemporalOrder}

/-- `F^w`, the `w`-th member of the relativized family. Declared with its dotted name outside
`namespace NomicFrame`, because `at` is a reserved token. -/
def NomicFrame.at (F : NomicFrame D) (w : F.World) : FrameOver D where
  WorldState := F.World
  PosRel := F.PosRel w

namespace NomicFrame

/-- `def:nomic-frame`'s regularity hypothesis: every member is a task frame. -/
class IsRegular (F : NomicFrame D) : Prop where
  regular : ∀ w : F.World, (F.at w).IsRegular

instance instAtIsRegular (F : NomicFrame D) [F.IsRegular] (w : F.World) :
    (F.at w).IsRegular := sorry

/-- The relativized derived relation `⇒^w`, reflection convention included. -/
def TaskRel (F : NomicFrame D) (w : F.World) : F.World → ↑D → F.World → Prop := sorry

theorem taskRel_eq (F : NomicFrame D) (w : F.World) : F.TaskRel w = (F.at w).TaskRel := sorry

/-- `H_F^w`, as a set of bare functions so that the union over `w` typechecks. -/
def lawHist (F : NomicFrame D) (w : F.World) : Set (↑D → F.World) := sorry

/-- `H_F := ⋃_w H_F^w`. -/
def HF (F : NomicFrame D) : Set (↑D → F.World) := sorry

theorem mem_lawHist_iff (F : NomicFrame D) (w : F.World) (τ : ↑D → F.World) :
    τ ∈ F.lawHist w ↔ ∃ σ : WorldHistory (F.at w).toTaskFrame, σ.state = τ := sorry

/-- `def:nomic-properties`, *Lawful*. -/
def Lawful (F : NomicFrame D) : Prop := sorry

/-- `def:nomic-properties`, *Static*. -/
def Static (F : NomicFrame D) : Prop := sorry

/-- `def:nomic-properties`, *Uniform*. -/
def Uniform (F : NomicFrame D) : Prop := sorry

theorem static_of_uniform {F : NomicFrame D} (h : F.Uniform) : F.Static := sorry

theorem lawful_of_uniform {F : NomicFrame D} (h : F.Uniform) : F.Lawful := sorry

/-- `lem:nomic-occurrence`: every state occurs at every time along some law-history at `w`. -/
theorem occurrence (F : NomicFrame D) [F.IsRegular] (w u : F.World) (x : ↑D) :
    ∃ τ ∈ F.lawHist w, τ x = u := sorry

/-- `lem:nomic-recovery`, the one-directional helper the `⇒` direction applies twice. -/
theorem taskRel_imp_of_lawHist_eq (F : NomicFrame D) [F.IsRegular] {w u : F.World}
    (h : F.lawHist w = F.lawHist u) {p q : F.World} {d : ↑D}
    (hpq : F.TaskRel w p d q) : F.TaskRel u p d q := sorry

/-- `lem:nomic-recovery`: `H_F^w = H_F^u` iff `⇒^w = ⇒^u`. -/
theorem lawHist_eq_iff_taskRel_eq (F : NomicFrame D) [F.IsRegular] (w u : F.World) :
    F.lawHist w = F.lawHist u ↔ F.TaskRel w = F.TaskRel u := sorry

/-- `def:nomic-witnesses`: the ℤ-time presentation `⇒^w_n = (R_w)^n`. -/
def ofStepFamily {W : Type} [Finite W] [Nonempty W] (R : W → W → W → Prop)
    (_fwd : ∀ w p, ∃ q, R w p q) (_bwd : ∀ w q, ∃ p, R w p q) : NomicFrame intOrder where
  World := W
  PosRel := fun w p x q => ofStepRel (R w) p (x : ℤ) q

theorem ofStepFamily_at {W : Type} [Finite W] [Nonempty W] {R : W → W → W → Prop}
    {fwd : ∀ w p, ∃ q, R w p q} {bwd : ∀ w q, ∃ p, R w p q} (w : W) :
    (ofStepFamily R fwd bwd).at w = FrameOver.ofStep (R w) (fwd w) (bwd w) := sorry

instance ofStepFamily_isRegular {W : Type} [Finite W] [Nonempty W] (R : W → W → W → Prop)
    (fwd : ∀ w p, ∃ q, R w p q) (bwd : ∀ w q, ∃ p, R w p q) :
    (ofStepFamily R fwd bwd).IsRegular := sorry

theorem mem_lawHist_iff_isStepPath (F : NomicFrame intOrder) [F.IsRegular] (w : F.World)
    (τ : ℤ → F.World) : τ ∈ F.lawHist w ↔ IsStepPath (F.at w) τ := sorry

theorem mem_lawHist_ofStepFamily_iff {W : Type} [Finite W] [Nonempty W] {R : W → W → W → Prop}
    {fwd : ∀ w p, ∃ q, R w p q} {bwd : ∀ w q, ∃ p, R w p q} (w : W) (τ : ℤ → W) :
    τ ∈ (ofStepFamily R fwd bwd).lawHist w ↔ ∀ n : ℤ, R w (τ n) (τ (n + 1)) := sorry

theorem lawHist_mono_of_le {W : Type} [Finite W] [Nonempty W] {R : W → W → W → Prop}
    {fwd : ∀ w p, ∃ q, R w p q} {bwd : ∀ w q, ∃ p, R w p q} {v u : W}
    (h : ∀ p q, R v p q → R u p q) :
    (ofStepFamily R fwd bwd).lawHist v ⊆ (ofStepFamily R fwd bwd).lawHist u := sorry

theorem stepPath_invariant {W : Type} {R : W → W → Prop} {τ : ℤ → W}
    (h : ∀ n : ℤ, R (τ n) (τ (n + 1))) {P : W → Prop}
    (hstep : ∀ p q, R p q → (P p ↔ P q)) (n₀ : ℤ) (h₀ : P (τ n₀)) (n : ℤ) : P (τ n) := sorry

theorem stepPath_forward_invariant {W : Type} {R : W → W → Prop} {τ : ℤ → W}
    (h : ∀ n : ℤ, R (τ n) (τ (n + 1))) {P : W → Prop}
    (hstep : ∀ p q, R p q → P p → P q) {n₀ : ℤ} (h₀ : P (τ n₀)) :
    ∀ n, n₀ ≤ n → P (τ n) := sorry

end NomicFrame

namespace PartialHistory

/-- The two-point partial history `{⟨0,p⟩,⟨d,q⟩}`, extended to a possible world by
`thm:extension`. Stated at `F.WorldState` deliberately. -/
theorem exists_worldHistory_two_point (F : TaskFrame) [F.IsRegular]
    (p q : F.WorldState) {d : F.Duration} (hd : (0 : F.Duration) ≠ d)
    (hpq : F.TaskRel p d q) :
    ∃ σ : WorldHistory F, σ.state 0 = p ∧ σ.state d = q := sorry

end PartialHistory

/-- `prop:nomic-hierarchy`, bundled: Static does not imply Lawful, Lawful does not imply Static,
and Static-and-Lawful does not imply Uniform. -/
theorem nomic_hierarchy :
    (∃ F : NomicFrame intOrder, ∃ _ : F.IsRegular, F.Static ∧ ¬ F.Lawful) ∧
    (∃ F : NomicFrame intOrder, ∃ _ : F.IsRegular, F.Lawful ∧ ¬ F.Static) ∧
    (∃ F : NomicFrame intOrder, ∃ _ : F.IsRegular, F.Static ∧ F.Lawful ∧ ¬ F.Uniform) := sorry

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] `lake build FormalSystem` green with zero new structural `sorry` at the end of every phase
      (the task's stated constraint), checked by `grep -c 'sorry'` per new file and by C3 at the
      end
- [ ] `ofStepFamily_at` pinned as `rfl` by an `example`, and the two `match`-shaped witness
      relations' coincidences (`R1 .a ≡ R1 .b`, `R3 .b ≡ R3 .c`) likewise
- [ ] `mem_lawHist_iff` exercised in both directions (it is the only bridge between `lawHist` and
      `WorldHistory`)
- [ ] All three cases of `lem:nomic-recovery` reached: `d = 0`, `d > 0`, `d < 0`
- [ ] Each of the three witnesses' independence theorems proved as a named theorem, following
      `Semantics/FrameConstraintIndependence.lean`'s per-witness style rather than only a bundled
      existential; `nomic_hierarchy` sits on top of them
- [ ] `lean_verify` run on `occurrence`, `lawHist_eq_iff_taskRel_eq` and `nomic_hierarchy`, and
      the measured axiom sets stated in the docstrings — ZFC, never advertised as choice-free
- [ ] `bash scripts/check-module-invariants.sh` exits 0 (Phase 7)
- [ ] `bash scripts/readme-lint.sh FormalSystem` exits 0 (Phases 1 and 7)

## Artifacts & Outputs

- `FormalSystem/Semantics/Nomic/Frame.lean` — `def:nomic-frame`, `def:nomic-properties`,
  `lem:nomic-occurrence`
- `FormalSystem/Semantics/Nomic/Recovery.lean` — the two-point history, `lem:nomic-recovery`, and
  conditionally `thm:nomic-primitive` clause (1)
- `FormalSystem/Semantics/Nomic/ZTime.lean` — `def:nomic-witnesses` and the step-path invariants
- `FormalSystem/Semantics/Nomic/Witnesses.lean` — `prop:nomic-hierarchy`'s three witnesses and
  `nomic_hierarchy`
- `FormalSystem/Semantics/Nomic.lean` — the sibling aggregator
- `FormalSystem/Semantics/Nomic/README.md` — the cluster README, carrying the siting decision
- `FormalSystem/Semantics.lean`, `FormalSystem/Semantics/README.md`, `FormalSystem.lean` — wiring
- `docs/reference/paper-definitions-of-record.md` — six `KNOWN-ANCHORS` rows
- `specs/794_nomic_frames_law_histories_hierarchy/summaries/01_nomic-frames-law-histories-summary.md`
  — the implementation summary

## Rollback/Contingency

Every phase is additive: four new modules, one new aggregator, one new README, and three
single-line inserts into existing files. A phase that fails is rolled back by deleting its new
file(s) and reverting its one aggregator/root line, which leaves the tree exactly as the previous
phase's commit left it — no destructive git operation is needed for the ordinary case, and none
should be run, because a sibling task is live on this same working tree.

If a genuine working-tree rollback is unavoidable, take the snapshot first per
`context/contracts/recovery.md`'s rollback rung and use the invocation shape recorded there; do
**not** run `git-snapshot.sh` in its reverting default mode as a precaution, since it can discard
a concurrent sibling's in-flight edits along with this task's rollback target. For an ordinary
defensive checkpoint before the Phase 5 proof work, use
`bash .claude/scripts/git-snapshot.sh 794 --no-revert`, which is durable without touching the
working tree.

Contingency branches already built into the plan: Phase 5 stalls → `[BLOCKED]`, with Phases 1-4's
content (both trivial implications, witness 1, witness 3, the uniformity gap) already landed and
no `sorry` placed. Phase 6 does not fire → `[COMPLETED WITH EXCLUSIONS]` with a
`#### Reasoned Exclusions` row; nothing downstream waits on it.
