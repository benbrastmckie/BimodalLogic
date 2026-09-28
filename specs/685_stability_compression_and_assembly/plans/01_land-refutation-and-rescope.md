# Implementation Plan: Task #685

- **Task**: 685 - stability_compression_and_assembly
- **Status**: [COMPLETED]
- **Effort**: 5.5 hours
- **Dependencies**: 684 (completed), 623 (completed)
- **Research Inputs**: `specs/685_stability_compression_and_assembly/reports/01_stability-compression-and-assembly.md`
- **Artifacts**: plans/01_land-refutation-and-rescope.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Research machine-refuted this task's stated deliverable: the L⁺ analogue of
`exists_witnessFamily_of_not_validZTime` is **false** against the landed six conditions, because
(C1')'s `snce` clause forces any two indices sharing a world state at a time to agree on every
`snce` formula of the closure, so every presented model validates `Pψ → ⊡Pψ` while
`Pp → ⊡Pp` is a genuine ℤ-time non-validity. Per the settled decision on
`.decisions.json`, this plan therefore **attempts no compression proof**. It lands the refutation
as a compiled library module beside the device it constrains, corrects the two READMEs that
currently present (C1') as the repair for recombination without recording its completeness price,
pins the new declarations in the repository's own axiom/ledger gates, and spawns the substrate
redesign and the L⁺ carrier normalization as separate dependent tasks.

### Research Integration

Findings consumed directly:

- **F1/F2** supply the four proved declarations and the root-cause factoring. The probe at
  `specs/685_stability_compression_and_assembly/probes/01_snce_stab_incompleteness.lean` is
  already green through `lean_run_code` against the pinned toolchain, sorry-free, no new axiom, no
  `set_option maxHeartbeats`. Phase 1 is a port, not a re-proof.
- **F3** is the scope of the spawned substrate-redesign task (the fourth periodic datum
  `transBack`/`transMid`/`transFwd`, `Thread`'s step change, the named downstream re-proof
  surface, and the non-vacuity gate).
- **F4, first bullet** is the scope of the spawned L⁺ carrier-normalization task
  (`plusValidZTime_iff_plusValidInt` on the `plus_invariance` template).
- **F4, second bullet, and F5** are *not* scoped into any task here: an L⁺ `Compression/` subtree
  is worth building only against a corrected condition set, so it belongs downstream of the
  redesign. The bound shape in F5 is recorded in the research report and needs no further
  artifact.
- **Recommendation 1** fixes the two README sites for Phase 3.

### Prior Plan Reference

No prior plan. This is round 01 for this task.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only; no `roadmap_path` or `roadmap_flag` was passed in the
delegation context, so **no ROADMAP.md edit is in scope** and no roadmap-review/update phase is
included. The relevant front is Phase 2 ("Decidability and the Tableau Engine") and Phase 4
("Finite Model Property and Decidable Model Checking"): this work closes the branching-compression
sub-route negatively rather than advancing a checkbox, and the roadmap carries no line for that
sub-route to tick.

## Goals & Non-Goals

**Goals**:

- Promote the four refutation declarations into
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean`, reachable from the
  build graph so `lake build` compiles them on every run and they cannot rot.
- Pin the new declarations in the C2 axiom baseline and give each a `docs/theorem-index.md` row,
  so the refutation is machine-asserted rather than prose.
- Correct `PlusWitnessFamily/README.md` and `WitnessFamily/Sharing/README.md` so neither presents
  (C1') as an unqualified repair, and so a future dispatch cannot plan a compression proof against
  a false statement (which is exactly what happened this round).
- Spawn two dependent tasks: the substrate redesign (F3) and the L⁺ carrier normalization (F4).
- Leave the repository's gate set green: `lake build`, `check-module-invariants.sh`,
  `readme-lint.sh`.

**Non-Goals**:

- **Any compression or assembly proof.** The statement is false; the zero-debt policy forbids a
  `sorry` standing in for it. This is the settled decision, not a deferral for convenience.
- **The substrate redesign itself.** It is ~3500 lines of re-proof across nine modules on both the
  `Formula` and `PlusFormula` sides (F3) and is spawned, not attempted.
- **Any edit to `WitnessFamily/Compression/` or the deterministic route.** F2 cannot reach it:
  it is stated at `Formula`, which has no `⊡`, and its device has `share = Eq`.
- **`FormalSystem/Metalogic/Decidability.lean`'s `PlusWitnessFamily` bullet.** Its claim — that
  the re-index is what makes (C5) stateable — is true and unaffected by F2, so it needs no
  correction. Deliberately excluded rather than overlooked.
- **The cross-repository adequacy document** (research Recommendation 5). Task 693 owns the A1
  conformance surface and reads the *deterministic* compression, which is unaffected.
- **`context/project/lean4/domain/branching-certificate-conditions.md`** (research's Context
  Extension Recommendation). Its target is under `.claude/**`, a gitignored deploy artifact whose
  source store for this repository is `/home/benjamin/.config/nvim/agent-system/extensions/lean`
  — a *different* repository, outside this task's Lean scope, and the same boundary for which a
  sibling task was recently abandoned as "relocated to nvim agent-system repository". The durable
  knowledge lands instead in the new module's docstring and the two corrected READMEs, which is
  where a reader of this device will actually look. Flagged in the return summary.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A citation of the probe's `specs/685_.../probes/...` path in a new `.lean` or README file fails gate C9, whose regex matches `specs/[0-9]{3}_[A-Za-z0-9_]+` verbatim | M | H | The library module **is** the record; it carries no back-reference to the specs-side path. Phase 1 and Phase 3 both forbid the citation explicitly. (The existing `Probe476` citations survive C9 only because `specs/archive/476_...` does not match that regex — do not read them as a precedent.) |
| C2's pass message hardcodes the string "all ten pinned axiom sets" and its header comment counts "the first four rows … the six that follow"; appending four rows leaves both stale | L | H | Phase 2 updates the count string and the header prose in the same edit as the heredoc pair. |
| The C2 `AXIOM_BASELINE` and `LEAN` heredocs are compared by exact string equality and must list the same declarations in the same order | M | M | Phase 2 appends to both in one edit and verifies by running the gate, not by inspection. |
| `docs/theorem-index.md` rows are gated by C15's second assertion (every row's anchor present at the declaration) and by C14/C2 pinning | M | M | Phase 1 writes a `Paper: —` line plus a reason into each declaration's docstring, following `Examples.lean`'s existing convention; Phase 2 adds the rows only after the C2 pinning is green. |
| C17's dead-declaration scan flags a base identifier with zero occurrences outside its declaring line | L | M | All four declarations gain README and theorem-index citations in Phases 2-3; the two helper `def`s are used inside the module. |
| A reader takes the new module as refuting *soundness*, or as refuting stability-modal decidability itself | H | M | Both readings are wrong: `plusTruth_iff_mem` is untouched and a certified family still presents a genuine countermodel. The module docstring states this explicitly (the probe header already does), and the README correction repeats it. |
| The `untl` side is asserted defect-free by inspection only, not machine-checked | M | M | The module docstring records it as an inspection result, not a theorem. The spawned redesign task carries the *positive* obligation (a full six-condition family separating `Fp` from `⊡Fp`) rather than relying on the absence of a refutation. |
| Sibling task 693 is dispatched this same cycle with declared `file_scope: ["specs/"]`, so `specs/state.json`, `specs/TODO.md` and `specs/events.jsonl` are contended | M | H | Phase 4 mutates `specs/state.json` only through `.claude/scripts/state-write.sh` (which takes the task lock); every commit stages an explicit file list, never a directory or glob pathspec; `git-snapshot.sh` is never run in its reverting default mode. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Promote the Refutation to a Compiled Library Module [COMPLETED]

**Goal**: The four refutation declarations live in
`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean`, are reachable from
the build graph, and `lake build` is green. No proof is re-derived — the probe is already green.

**Tasks**:

- [ ] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` with the
      repository's Apache-2.0 copyright header (copy the four-line form from
      `PlusWitnessFamily/Examples.lean`) so `scripts/check-copyright-headers.sh` passes.
- [ ] Port the probe's four theorems and two helper `def`s verbatim in their proof bodies, changing
      only: (a) the imports — `import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Agreement`
      plus `import FormalSystem.PlusLanguage.PlusNonValidities` (no cycle risk: `PlusLanguage/`
      sits below `Metalogic/` and imports nothing from it, so `check-metalogic-cycles.sh`
      assertions A/B/C are unaffected); (b) the namespace — `namespace
      FormalSystem.Metalogic.Decidability` then `namespace PlusSharingWitnessFamily`, closing both,
      following `Examples.lean`; (c) the declaration names, from the probe's `Probe685.*` to
      repo-convention names.
- [ ] Rename to the sibling convention set by `stabFaithful_share_congr`:
      `snce_share_congr` (was `snce_state_determined`), `not_plusCertifies_stabSnce` (was
      `no_certificate`), `not_plusCertifies_stabSnce_premise` (was
      `no_certificate_premise_form`), `not_plusValidZTime_stabSnce` (was
      `not_plusValidZTime_instance`), and the helpers `stabSnceTarget` (was `tgt`) /
      `notStabSnceTarget` (was `ngt`). Check the chosen names against gate C23's naming
      sub-assertions before settling them.
- [ ] Write the module docstring from the probe's header, adding three things the probe header does
      not carry: that `plusTruth_iff_mem` is **untouched** and the failure is of *completeness* of
      the certificate class, not of soundness; that the `untl` side is defect-free **by inspection,
      not by machine check**; and that the fix is at the substrate level (F3), not a re-wording of
      (C1').
- [ ] Give each of the four theorems a `Paper: —` line plus a reason in its docstring, following
      the existing convention at `PlusWitnessFamily/Examples.lean`'s two witnesses. This is what
      C15's second assertion reads when Phase 2 adds the ledger rows.
- [ ] Cite declaration **names** only. No `file.lean:NNN` citation anywhere in the module (C20
      tier 2 gates file:line citations in publication-facing scope), and **no citation of the
      probe's `specs/685_.../probes/...` path** (C9 matches `specs/[0-9]{3}_[A-Za-z0-9_]+`).
- [ ] Add `import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Incompleteness` to the
      re-export `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`, after the
      `Examples` import, so the module is inside a build closure and needs no
      `scripts/module-invariants-manifest.txt` entry (C6 fails on an unreachable live module that
      is missing from that file, and the manifest's intended resting state is empty).
- [ ] Add the matching `PlusWitnessFamily.Incompleteness` bullet to that file's `## Submodules`
      list, and one clause in its docstring recording that the certificate class is empty for
      targets carrying a `snce` under a `stab`.
- [x] Run `lake build` and confirm green with no new warning. *(deviation: altered — two
      identifiers needed requalification after the namespace move, which the Scope Hypothesis
      did not anticipate: `open FormalSystem.ProofSystem` added for `FrameClass.ZTime.Sat`, and
      `NF` written as `FormalSystem.PlusLanguage.NF` because inside `namespace
      PlusSharingWitnessFamily` the bare `NF` resolves to `Decide.lean`'s
      `PlusSharingWitnessFamily.NF : ... → ℤ`. No statement changed and no proof step changed.)*
      The probe's own recorded tactic
      hazards carry over: do **not** reach for `tauto` on the `imp`-clause split (it times out at
      200000 heartbeats), and do **not** use `push_neg` (deprecated in favour of `push Not`, and
      the repo warning budget treats the deprecation as blocking) — the ported proofs already
      avoid both.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts the port needs **no proof-body change** — only imports,
namespace, names and docstrings. Confirm at implementation time by building; if any proof body
needs repair, the cause is API drift since the probe ran, and the repair must track the API
without weakening any statement (the no-weakening rule the evidence-probe guard states for
exactly this case). It also asserts **one** new file plus **one** edited file
(`PlusWitnessFamily.lean`); confirm by `git status --short` before staging.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` - new; the four
  refutation declarations, two helper defs, and the docstring that says what they do and do not
  show
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - add the import and the
  `## Submodules` bullet; one docstring clause on the empty certificate class

**Verification**:

- `lake build` exits 0 with no new warning or error.
- `grep -c sorry` on the new module returns 0; the module declares no new `axiom` and sets no
  `maxHeartbeats`.
- `bash scripts/check-copyright-headers.sh` passes.
- `bash scripts/check-metalogic-cycles.sh` passes (all three assertions).
- `grep -nE 'specs/[0-9]{3}_[A-Za-z0-9_]+|\.lean:[0-9]+' ` over the two touched files returns
  nothing.

---

### Phase 2: Pin the New Declarations in the Gates and the Ledger [COMPLETED]

**Goal**: The refutation is machine-asserted on every gate run — axiom sets pinned by C2, and one
`docs/theorem-index.md` row per declaration — so it cannot become prose-only or silently change
axiom footprint.

**Tasks**:

- [x] Append four lines to `scripts/check-module-invariants.sh`'s `AXIOM_BASELINE` heredoc, in the
      form the existing `PlusSharingWitnessFamily.*` rows use, and the four matching
      `#print axioms` lines to the `LEAN` heredoc **in the same order**. The two heredocs are
      compared by exact string equality; edit them together, appending to both.
- [x] Take the four axiom-set values from an actual run, not from assumption: the existing five
      `PlusSharingWitnessFamily` rows all read `[propext, Classical.choice, Quot.sound]`, but a
      strict subset is possible and is recorded literally rather than rounded up (the C14 header
      documents eight such entries). Run the gate, read the `--- actual ---` block, and write what
      it says.
- [x] Update C2's pass message from `"all ten pinned axiom sets match baseline"` to the new count,
      and update the block's header comment, which currently reads "The first four rows … The six
      that follow" and enumerates the five L⁺ declarations.
- [x] Add one `docs/theorem-index.md` row per new declaration, in the same table and adjacent to
      the existing `PlusSharingWitnessFamily` rows. Columns: paper label `—`, a one-line
      statement, the **fully qualified** Lean name, the file path with **no line number**, frame
      class (`ZTime` for `not_plusValidZTime_stabSnce`, `—` for the three that are class-generic),
      and axioms `pcq pinned:C2`.
- [x] Re-run the gate and confirm C2, C14, C15, C17 and C20 all pass.
- [x] *(deviation: altered — two gate surfaces the plan did not name also had to be
      regenerated, both mechanical consequences of adding one live module that the plan's
      "reachable from the build graph via the re-export is enough" reasoning missed. C33 requires
      the generated library root `FormalSystem.lean` to import every live module, fixed by
      `lake exe mk_all --lib FormalSystem`; the INV check requires the generated inventory blocks
      in `README.md`, `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md` to carry
      current file/line counts, fixed by `bash scripts/check-module-invariants.sh
      --emit-inventory`. Neither file was hand-edited.)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **four** new baseline lines and **four** new ledger rows,
matching the four theorems Phase 1 lands. Confirm against the actual declaration list in the built
module, not against this plan: if Phase 1 settled on a different count (e.g. the two placement
variants merged), adjust both counts together and say so in the summary.

**Files to modify**:

- `scripts/check-module-invariants.sh` - four lines in each of the two C2 heredocs; the pass
  message count; the block header comment
- `docs/theorem-index.md` - four rows

**Verification**:

- `bash scripts/check-module-invariants.sh` exits 0, with C2 passing at the new count and its
  `note` lines listing the four new declarations.

  **Result**: C2 passes at `all fourteen pinned axiom sets match baseline`, with the four new
  declarations in its `note` lines. C9, C14, C15, C17, C20, C33 and INV all pass. The gate's
  overall exit is 1 on a **pre-existing** C23 failure — 2 `NM_nonneg` Uppercase_x names and 11
  outer-shadows-inner pairs, every one of them in a file this task neither created nor modified,
  and every one verified present at commit `182943b9d`, the commit preceding this task's first.
  No finding names any declaration this task introduced. See Phase 5 for how this bears on the
  plan's "leave the gate set green" goal.
- C15's second assertion passes, i.e. every new row's anchor resolves at the declaration (this is
  what Phase 1's `Paper: —` lines are for).
- C17 reports no new dead declaration.
- C20 reports no new `file.lean:NNN` citation.
- C9 still passes at zero task-number citations.

---

### Phase 3: Correct the Two READMEs [COMPLETED]

**Goal**: Neither README presents (C1') as an unqualified repair for recombination. A reader
arriving at either one learns the completeness price before planning anything against it.

**Tasks**:

- [x] In `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md`: amend the (C1') row of
      the `## The six conditions` table to record that its `snce` clause forces class agreement at
      the label's own time; add a new `## What this certificate cannot refute` section stating the
      empty-certificate-class result, naming the four new declarations, and drawing the
      soundness/completeness distinction explicitly; add the `Incompleteness.lean` bullet to the
      `## Modules` list; bump the trailing `*Last verified:*` date.
- [x] In `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`: amend the
      `## Which conditions break under recombination, and which do not` table's (C1') row, which
      currently presents the branching form as the fix with no qualification, and add the
      correction subsection beside the existing `### Correction: (C3) is recombination-stable` —
      same shape, same candour: the received account named (C1') as the repair; the Lean reading
      shows it is only half a repair, because the `snce` clause's same-time quantification collapses
      backward branching. Extend `## (C5), the stability clause: not here, and why` subsection
      `### (c) What a follow-up needs` with the substrate-level requirement from F3. Bump
      `*Last verified:*`.
- [x] Record the `untl`/`snce` asymmetry and its origin in `Thread`'s tight step field in whichever
      of the two READMEs the substrate discussion already lives in (`Sharing/README.md`), together
      with the rule of thumb F2 states: a condition quantifying over the `share`-class at a label's
      *own* time forces class agreement on that label.
- [x] Cite declaration names and no `file:line`; cite **no** `specs/685_...` path (C9, C20).
- [x] *(deviation: altered — the `*Last verified:*` bump was carried out on
      `PlusWitnessFamily/README.md` only, where the stamp already reads the current date and so
      needed no change. `WitnessFamily/Sharing/README.md` carries **no** `*Last verified:*` line
      at all, which `readme-lint.sh` reports as an info-only `MISSING DATE` and which predates
      this task; no stamp was invented for it, since inventing document structure the file never
      had is a larger change than this phase is scoped for.)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts exactly **two** README files. Confirm before staging that
no third surface in `FormalSystem/**` states the branching device is the stability-modal route to
decidability: re-run
`grep -rln 'PlusCertifies\|plusRefutes_of_certifies\|StabFaithful\|PlusSharingWitnessFamily' --include=*.md --include=*.lean FormalSystem/`
and check each hit. If a third site needs the caveat, add it and say so in the summary rather than
silently leaving it.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` - (C1') table row, new
  incompleteness section, `Modules` bullet, `Last verified`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` - recombination table's
  (C1') row, new correction subsection, `(c) What a follow-up needs`, `Last verified`

**Verification**:

- `bash scripts/readme-lint.sh FormalSystem` passes its two gated checks (README present per
  `.lean` directory; no broken relative reference).
- `bash scripts/check-module-invariants.sh --no-build` passes the structural checks, C9 and C13
  included.
- Manual read-back: each README's new text names at least one of the four new declarations, so
  C17 has a citation for it, and states the soundness/completeness distinction.

  **Result**: `readme-lint.sh FormalSystem` PASSES (0 missing READMEs, 0 broken file references).
  `check-module-invariants.sh --no-build` passes C9 (zero task-number citations), C13 (all
  relative markdown links resolve) and both blocking C20 tiers; the only FAIL is the pre-existing
  C23 recorded under Phase 2. Both READMEs name all four new declarations and state the
  soundness/completeness distinction explicitly. Scope Hypothesis **confirmed at two files**: the
  re-run grep returns 13 hits, and the only ones that could state a decidability-route claim are
  `Decidability.lean` (whose bullet claims solely that the re-index makes (C5) stateable — true,
  and a declared Non-Goal) and `PlusWitnessFamily.lean` (already amended in Phase 1). No third
  README needed the caveat.

---

### Phase 4: Spawn the Two Dependent Tasks [COMPLETED]

**Goal**: The substrate redesign and the L⁺ carrier normalization exist as `not_started` tasks in
`specs/state.json`, scoped from F3 and F4 respectively, so the re-scope loses no work.

**Tasks**:

- [x] Compose the **substrate redesign** task: `task_type: lean4`, `topic: decidability`, deps
      `[685]`, `file_scope` naming the F3 re-proof surface —
      `WitnessFamily/Sharing/{Skeleton,Predicates,Decide,Fulfil,Agreement,Specialize}.lean`,
      `PlusWitnessFamily/{Predicates,Decide,Fulfil,Agreement}.lean`, plus both READMEs. Its
      description must carry: the fourth periodic datum
      (`transBack`/`transMid`/`transFwd`, decoded by the same `Periodic.unrollOf` scheme, giving
      `trans u : Fin n → Fin n → Prop`); `Thread`'s step becoming `trans u (idx u) (idx (u+1))`
      rather than `share (u+1) (idx u) (idx (u+1))`; the division of labour (`share` keeps the `⊡`
      quantifier, the quotient carrier, (C0) and (C5); `trans` carries the one-step branching);
      the export contract gaining three fields exactly as `repBack`/`repMid`/`repFwd` did; the
      ~3500-line re-proof surface with `Sharing/Fulfil.lean` (1669 lines) and
      `PlusWitnessFamily/Fulfil.lean` (1093 lines) dominating; and the **non-vacuity gate** — one
      concrete family satisfying all six conditions at non-trivial sharing, plus a check that the
      redesigned (C1') no longer entails the state-determination lemma, *before* the fixpoint layer
      is re-proved. Note in the description that (C2')'s window reduction already carries a
      recorded (C1')-relative limitation that the redesign must re-examine.
- [x] Compose the **L⁺ carrier normalization** task: `task_type: lean4`, `topic: decidability`,
      deps `null` (blocked on nothing — it is useful regardless of the redesign's outcome).
      Target: `plusValidZTime_iff_plusValidInt`, the L⁺ twin of `Semantics/IntTransfer.lean`'s
      `validZTime_iff_validInt`, by a seven-case induction on the `plus_invariance` template in
      `Semantics/Frames/TranslationProduct.lean`. Record that the `stab` case goes through on
      `Aligned` because `(FrameOver.map F e).WorldState` is definitionally `F.WorldState`, so
      `WorldHistory.comap` plus `aligned_comap` transport the state-agreement side condition, and
      that either a `PlusTruthCorr` with a state-agreement field or a direct seven-case
      `plusTruthAt_map` will do. `file_scope`: `FormalSystem/Semantics/IntTransfer.lean`,
      `FormalSystem/Semantics/TruthTransport.lean`, and a new `FormalSystem/PlusLanguage/` or
      `FormalSystem/Semantics/` module for the L⁺ transfer.
- [x] Write both entries through `bash .claude/scripts/state-write.sh` with a `+=` jq filter on
      `.active_projects` and `.next_project_number += 1` per task — **never** a wholesale
      `.artifacts = [...]` or `.active_projects = [...]` assignment. Use the two-step
      `--argjson-file` form so no description text has to survive jq escaping. The script takes
      the task lock, which is what makes this safe against the sibling dispatch declaring
      `file_scope: ["specs/"]` this same cycle.
- [x] Do **not** add the F4 second-bullet L⁺ `Compression/` subtree as a third task: it is worth
      building only against a corrected condition set, so it belongs downstream of the redesign
      and should be created by that task, not now.
- [x] Neither description may cite a task number in prose that will be copied into a deliverable
      later; task numbers inside `specs/**` are the rule's own documented exemption, so the
      `dependencies: [685]` field and a description reference are fine here, but the spawned tasks'
      own future READMEs are not.
- [x] Run `bash .claude/scripts/generate-todo.sh` to regenerate `specs/TODO.md` from
      `specs/state.json`; never hand-edit `TODO.md`.

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts **two** new tasks and a `next_project_number` advancing by
exactly 2 from its pre-phase value (694 at the time of planning — re-read it rather than assuming,
since the sibling dispatch may have taken a number first). Confirm by reading
`.next_project_number` immediately before and after.

**Files to modify**:

- `specs/state.json` - two appended `active_projects` entries; `next_project_number` advanced by 2
- `specs/TODO.md` - regenerated, not hand-edited

**Verification**:

- `bash .claude/scripts/validate-state.sh` exits 0.
- `jq -r '.active_projects[] | select(.dependencies != null and (.dependencies | index(685))) | .project_number'`
  returns the redesign task's number.
- Both new entries read back with non-empty `title`, `description`, `task_type: "lean4"` and
  `status: "not_started"`.
- `specs/TODO.md` shows both new tasks, with artifact links in bracket-only form.

  **Result**: `next_project_number` advanced 694 → 696, exactly 2, confirmed by reading it
  immediately before and after. Task **694** `sharing_substrate_trans_redesign`
  (`task_type: lean4`, `topic: decidability`, `dependencies: [685]`, 12 `file_scope` entries) and
  task **695** `plus_carrier_normalization_int_transfer` (`task_type: lean4`,
  `topic: decidability`, `dependencies: null`, 5 `file_scope` entries), both `not_started` with
  non-empty descriptions. The dependency query returns 694 (alongside pre-existing 177).
  `specs/TODO.md` regenerated by `state-write.sh --regen-todo`, never hand-edited, and shows both.
  `validate-state.sh` exits 1 on **ten pre-existing** schema-drift failures — five unknown
  top-level fields (`active_goal`, `artifacts`, `last_updated`, `metadata`, `task_counts`) and five
  unknown entry fields on tasks 257, 298, 410-412, 428-430 and 481. None names 694 or 695, and
  neither new entry drew a failure or a warning of its own. Both entries were written through
  `state-write.sh` under the task lock, using `--argjson-file` so no description text passed
  through jq escaping, and via a `+=` filter — never a wholesale array assignment.

---

### Phase 5: Full Gate Sweep and Close-Out [COMPLETED WITH EXCLUSIONS]

**Goal**: Every gate green on the combined change set, and the work committed in scoped commits
that name only this task's own files.

**Tasks**:

- [x] Run the full gate set in order: `lake build`; `bash scripts/check-module-invariants.sh`;
      `bash scripts/check-copyright-headers.sh`; `bash scripts/check-metalogic-cycles.sh`;
      `bash scripts/readme-lint.sh FormalSystem docs`; `bash .claude/scripts/validate-state.sh`.
- [x] Run `bash scripts/check-evidence-probes.sh` and confirm it still passes **unchanged**: the
      new library module is compiled by `lake build`, which is strictly stronger rot protection
      than that guard provides, so **no `WIRED`/`WIRED_REPO` entry is added** and the specs-side
      probe file is left where it is. Record this reasoning in the summary so a later reader does
      not mistake the absence of a wiring entry for an oversight.
- [x] Re-read every file immediately before staging it (the sibling dispatch shares this working
      tree), then commit with explicit per-file pathspecs. No `git add -A`, no `git add .`, no
      directory or glob pathspec, no `git commit -am`. Never run `git-snapshot.sh` in its reverting
      default mode.
- [x] Commit messages per the repository convention, one per completed phase:
      `task 685 phase {P}: {phase name}`, with `Session: sess_1790630813_a17992_685` in the body
      and the session's attribution lines.
- [x] If any gate fails on something outside this task's own files, check `git log` before assuming
      it is this work: an unexpected failure in a file outside the declared scope may be the
      sibling's in-flight edit. Stop and report a foreign commit or foreign uncommitted
      modification rather than fixing it.

**Timing**: 45 minutes

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Files to modify**:

- none (verification and commits only)

**Verification**:

- All six gate commands above exit 0. **Not achieved, and not achievable** — two of the six were
  already red before this task's first commit, for reasons wholly outside its files. See the
  Reasoned Exclusions below. The other four exit 0:
  - `lake build` (full project, guarded + detached): **exit 0**, `Build completed successfully
    (2770 jobs)`, zero `error:` and zero `warning:` lines over both captured streams, and the
    `.olean` for every module this task touched newer than its source.
  - `bash scripts/check-copyright-headers.sh`: **exit 0** (0 missing of 604).
  - `bash scripts/check-metalogic-cycles.sh`: **exit 0** (all three assertions).
  - `bash scripts/readme-lint.sh FormalSystem docs`: **exit 0**, `RESULT: PASS`, 0 missing
    READMEs, 0 broken file references.
  - Within `check-module-invariants.sh`, every check this task bears on passes: C2 at `all
    fourteen pinned axiom sets match baseline`, plus C1, C9, C13, C14, C15, C17, C20 (both
    blocking tiers), C33 and INV.
- `bash scripts/check-evidence-probes.sh` exits 0 with its wired list unchanged. **Achieved**: 6
  wired probes PASS, 1 pre-existing SKIP, and **no `WIRED`/`WIRED_REPO` entry was added**. The
  reasoning, recorded here so a later reader does not read the absence as an oversight: the
  refutation now lives in a module `lake build` compiles on every run, which is strictly stronger
  rot protection than that guard provides. The specs-side probe file is left where it is.
- `git status --short` shows a clean tree for this task's files after the final commit, and shows
  no file this task did not touch. **Achieved for this task's files.** The tree additionally
  carries sibling task 693's in-flight edits (`scripts/lean-citation-seeds.txt`,
  `scripts/lean-citation-manifest.json`) and four modifications that predate this dispatch
  (`ORGANISATION.md`, `scripts/measure-refactor-partitions.py`, `typst/generated/status.typ`,
  `specs/events.jsonl`). None was staged in any commit here.
- `git log --oneline -5` shows the phase commits with the session ID in each body. **Achieved.**

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `bash scripts/check-module-invariants.sh` exits 0 | Blocked by a **pre-existing** C23 failure with no connection to this task: 2 `NM_nonneg` Uppercase_x names and 11 outer-shadows-inner bare-declaration pairs. Every reported declaration lives in a file this task neither created nor modified, and no finding names any declaration this task introduced. The repository already owns this work as task 691 `resolve_c23_naming_exemptions` (`not_started`), so absorbing it here would be scope theft from an existing task as well as ~13 renames across `BiLasso/`, `Sharing/` and `PlusWitnessFamily/Decide.lean` — none of which this task's `file_scope` covers. | Each reported declaration verified present at commit `182943b9d`, the commit immediately preceding this task's first: `NM_nonneg` in both `Decide.lean` files, `decidableValidZTime` in `BiLasso/Assembly.lean`, `cohWindowLo`/`cohWindowHi` in `BiLasso/Decide.lean`, `mem_verts` ×3 in each of `Sharing/Fulfil.lean` and `Sharing/Window.lean`. Grep for this task's six new base names across the gate log returns nothing. Every other check in the script passes, C2 included. |
| `bash .claude/scripts/validate-state.sh` exits 0 | Blocked by **ten pre-existing** schema-drift failures: five unknown top-level fields (`active_goal`, `artifacts`, `last_updated`, `metadata`, `task_counts`) and five unknown entry fields on tasks 257, 298, 410-412, 428-430 and 481. Repairing them means either editing the schema or deleting live fields other tasks' tooling writes — a state-schema decision, not a Lean refutation-landing decision. | The same script run against `git show 182943b9d:specs/state.json` reports the identical ten failures, with identical wording and identical project-number lists. Neither spawned entry (694, 695) appears in any failure or in any warning of its own; the only warning naming 694 is attached to pre-existing task 177's coarse `file_scope` declaration. |

## Testing & Validation

- [x] `lake build` green, no new warning, no `sorry`, no new `axiom` in the new module.
- [x] `bash scripts/check-module-invariants.sh` exits 0, with C2 pinning the four new declarations
      at the axiom sets an actual run reports. *(C2 achieved; script exit excluded — see Phase 5's
      Reasoned Exclusions.)*
- [x] C9 at zero task-number citations: no `specs/685_...` path and no `task 685` string under
      `FormalSystem/`, `scripts/`, `README.md` or `lakefile.toml`.
- [x] C15's second assertion passes for each new `docs/theorem-index.md` row.
- [x] C17 reports no new dead declaration.
- [x] `bash scripts/readme-lint.sh FormalSystem docs` passes its gated checks.
- [x] `bash .claude/scripts/validate-state.sh` exits 0 and both spawned tasks read back correctly.
      *(Both spawned tasks read back correctly; script exit excluded — see Phase 5's Reasoned
      Exclusions.)*
- [x] `bash scripts/check-evidence-probes.sh` unchanged and green.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` — the four
  refutation declarations, compiled on every `lake build`
- Edits: `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`,
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md`,
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`,
  `docs/theorem-index.md`, `scripts/check-module-invariants.sh`
- Two new `not_started` tasks in `specs/state.json`, rendered into `specs/TODO.md`
- `specs/685_stability_compression_and_assembly/summaries/01_*-summary.md` (written at postflight)

## Rollback/Contingency

The change set is additive and each phase commits independently, so rollback is per-phase
`git revert` of that phase's commit — no snapshot-and-reset is needed and none should be taken in
`git-snapshot.sh`'s reverting default mode.

Per-phase contingencies:

- **Phase 1 fails to build** because an API the probe cited has drifted: repair the proof to track
  the API. Do **not** weaken or delete a statement to make it compile — that would undo the very
  obstruction the module exists to record. If the repair is genuinely large, stop and report:
  a drifted refutation is a finding, not a formatting problem.
- **Phase 2's C2 baseline disagrees** with the expected axiom set: write what the `--- actual ---`
  block says. A strict subset of `[propext, Classical.choice, Quot.sound]` is not a regression and
  is recorded literally.
- **Phase 4's state write collides** with the sibling dispatch: `state-write.sh` holds the task
  lock, so retry after it releases. Never hand-edit `specs/state.json` around a held lock, and
  never `git add specs/`.
- **A gate fails on a file outside this task's scope**: check `git log` first. Report a foreign
  change rather than absorbing it.
