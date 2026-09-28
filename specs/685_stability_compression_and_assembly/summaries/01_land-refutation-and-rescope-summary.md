# Implementation Summary: Task #685

- **Task**: 685 - stability_compression_and_assembly
- **Status**: [COMPLETED]
- **Started**: 2026-09-28T21:58:10Z
- **Completed**: 2026-09-28T22:20:00Z
- **Effort**: ~2.4 hours
- **Dependencies**: 684 (completed), 623 (completed)
- **Artifacts**: plans/01_land-refutation-and-rescope.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The task as originally stated — prove an L⁺ compression theorem for the branching witness
structure — was machine-refuted during research, so no compression proof was attempted. Instead
the refutation itself was landed as a compiled library module, pinned in the repository's axiom
and ledger gates, written into the two READMEs that had presented (C1') as an unqualified repair,
and the two pieces of real remaining work were spawned as dependent tasks. All five plan phases
are closed; the fifth carries two enumerated, evidenced exclusions for gate failures that predate
this task.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` — **created**. Four
  theorems and two helper defs, all in namespace
  `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily`:
  - `snce_share_congr` — the root cause. (C1') `PlusLocalCoherentShare`'s `snce` clause quantifies
    its predecessor over the `share`-class at the label's own time; read twice (once at `i` with
    the shared index `j`, once at `j` with itself by reflexivity) it forces any two indices naming
    the same world state at `t` to agree on every `snce` formula of the closure. Uses (C1') and
    nothing else.
  - `not_plusCertifies_stabSnce` — no `PlusSharingWitnessFamily` certifies any instance of
    `(g S e) → ⊡(g S e)`, at any time and at any size, conclusion placement (`Del = [φ]`).
  - `not_plusCertifies_stabSnce_premise` — the same for the negated-premise placement
    (`Γ = [¬φ]`, `Del = []`), so restating the target is not an escape.
  - `not_plusValidZTime_stabSnce` — `Pp → ⊡Pp` is a genuine ℤ-time non-validity, refuted on the
    permissive ℤ-frame of `PlusLanguage/PlusNonValidities.lean`.
  - helpers `stabSnceTarget`, `notStabSnceTarget`.
  Together: the L⁺ analogue of the deterministic route's
  `exists_witnessFamily_of_not_validZTime` is **false** against the landed six conditions, and the
  failure is not about the size of the bound — for these targets the certificate class is empty.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` — the new import, a `## Submodules`
  bullet, and a docstring section recording the empty certificate class.
- `FormalSystem.lean` — regenerated via `lake exe mk_all --lib FormalSystem`.
- `scripts/check-module-invariants.sh` — four rows appended to each of C2's two heredocs in the
  same order; pass message `all ten` → `all fourteen`; block header comment rewritten to enumerate
  the four incompleteness rows and to record that a future substrate redesign repairing (C1') must
  make them FAIL.
- `docs/theorem-index.md` — four rows adjacent to the existing `PlusSharingWitnessFamily` rows.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` — the (C1') row amended; a new
  `## What this certificate cannot refute` section; `Incompleteness.lean` in `## Modules` and in
  the imports bullet.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` — the recombination
  table's (C1') row amended to "only half repaired"; a new
  `### Correction: (C1') is only half a repair` subsection beside the existing (C3) correction;
  `### (c) What a follow-up needs` extended with the full substrate requirement.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — generated inventory
  blocks regenerated via `check-module-invariants.sh --emit-inventory`.
- `specs/state.json`, `specs/TODO.md` — two spawned `not_started` tasks (694, 695).

## Decisions

- **Proof bodies were ported, not re-derived.** The research probe was already green against the
  pinned toolchain. The only edits were two requalifications forced by the namespace move, neither
  of which changes a statement: `open FormalSystem.ProofSystem` for `FrameClass.ZTime.Sat`, and
  `FormalSystem.PlusLanguage.NF` written in full because inside `namespace
  PlusSharingWitnessFamily` the bare `NF` resolves to `Decide.lean`'s
  `PlusSharingWitnessFamily.NF : … → ℤ`.
- **The `untl` side is recorded as an inspection result, not a theorem.** (C1')'s `untl` clause
  quantifies forward along a thread rather than over the `share`-class at the label's own time, so
  the collapse does not arise there. The module docstring and both READMEs say so in exactly those
  terms; the positive obligation (a six-condition family separating `Fp` from `⊡Fp`) is carried by
  spawned task 694 rather than inferred from the absence of a refutation.
- **The four C2 axiom sets were taken from an actual run**, not assumed: `lake env lean` on a
  scratch file importing the new module. All four read `[propext, Classical.choice, Quot.sound]` —
  no strict subset.
- **No evidence-probe wiring entry was added.** The refutation now lives in a module `lake build`
  compiles on every run, which is strictly stronger rot protection than
  `check-evidence-probes.sh` provides. The specs-side probe file is left where it is. Recorded here
  so a later reader does not read the absence of a `WIRED` entry as an oversight.
- **No third task for the L⁺ `Compression/` subtree.** It is worth building only against a
  corrected condition set, so task 694 should create it.
- **Sibling contention handled by explicit staging.** Task 693 was dispatched onto this same
  working tree in the same cycle with a coarse declared `file_scope: ["specs/"]`, and in fact
  committed twice to `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/` and left
  `scripts/lean-citation-{seeds.txt,manifest.json}` dirty. Every commit here staged an explicit
  per-file list; no directory or glob pathspec, no `git add -A`, no `git commit -am`, and
  `git-snapshot.sh` was never run.

## Plan Deviations

- **Phase 1, last task** altered: two identifiers needed requalification after the namespace move,
  which the phase's Scope Hypothesis ("no proof-body change — only imports, namespace, names and
  docstrings") did not anticipate. Both changes are namespace-resolution consequences; no
  statement and no proof step changed. The rest of the Scope Hypothesis held: one new file plus one
  edited file, confirmed by `git status --short`.
- **Phase 2** altered: two gate surfaces the plan did not name also had to be regenerated, both
  mechanical consequences of adding one live module that the plan's "reachable via the re-export is
  enough" reasoning missed. C33 requires the generated root `FormalSystem.lean` to import every
  live module (`lake exe mk_all --lib FormalSystem`); INV requires the generated inventory blocks
  in three READMEs to carry current counts (`check-module-invariants.sh --emit-inventory`). Neither
  file was hand-edited.
- **Phase 3** altered: the plan's `*Last verified:*` bump does not apply to
  `WitnessFamily/Sharing/README.md`, which carries no such line at all (pre-existing, reported as
  info-only `MISSING DATE` by `readme-lint.sh`). No stamp was invented. On
  `PlusWitnessFamily/README.md` the existing stamp already reads the current date.
- **Phase 5** closed `[COMPLETED WITH EXCLUSIONS]` rather than `[COMPLETED]`: its "all six gate
  commands exit 0" criterion was not achievable, because two of the six were already red before
  this task's first commit. Both exclusions are enumerated, reasoned and evidenced in the phase's
  `#### Reasoned Exclusions` table.

## Verification

- Build: **Success**. Full guarded, detached `lake build`: exit 0, `Build completed successfully
  (2770 jobs)`, zero `error:` and zero `warning:` lines over both captured streams, and the
  `.olean` for every module this task touched newer than its source (all three verdict tiers).
- Sorry count: **0** in the new module.
- Vacuous count: **0** in the new module. The one repository-wide hit
  (`FormalSystem/Examples/TemporalStructures.lean:495`,
  `intTimeHistory.domain t := trivial`) is pre-existing, present identically at commit
  `182943b9d`, in a file this task never touched, and is an honest proof rather than a placeholder.
- Axiom count: **unchanged**. The crude `^axiom ` scan reports 14 hits over the resolved source
  roots both now and at `182943b9d`; all are prose inside comments, and the new module declares no
  `axiom` and sets no `maxHeartbeats`.
- Other gates: `check-copyright-headers.sh` exit 0; `check-metalogic-cycles.sh` exit 0 (all three
  assertions); `readme-lint.sh FormalSystem docs` exit 0 (`RESULT: PASS`, 0 missing READMEs, 0
  broken references); `check-evidence-probes.sh` exit 0 with its wired list unchanged.
- Within `check-module-invariants.sh`: C2 passes at `all fourteen pinned axiom sets match
  baseline`, with the four new declarations in its `note` lines. C1, C9, C13, C14, C15, C17, C20
  (both blocking tiers), C33 and INV all pass. The script's own exit is 1 on the pre-existing C23
  failure excluded under Phase 5.
- `validate-state.sh` exits 1 on ten pre-existing schema-drift failures, verified byte-identical
  against `git show 182943b9d:specs/state.json`. Both spawned tasks read back correctly, and
  neither is named in any failure or in any warning of its own.
- Tests: N/A (no test-suite change in scope).
- Files verified: Yes.

## Impacts

- The refutation is now compiled on every `lake build` and pinned by C2, so it cannot rot into
  prose and cannot silently change axiom footprint. A future substrate redesign that genuinely
  repairs (C1') will make the four C2 rows FAIL, which is the intended signal; the C2 header
  comment says so.
- A future dispatch reading either README now learns the completeness price before planning against
  (C1'). That is the direct fix for what happened this round: a plan was written against a false
  statement because the READMEs presented (C1') as an unqualified repair.
- The deterministic route is untouched. F2 cannot reach it: it is stated at `Formula`, which has no
  `⊡`, and its device has `share = Eq`. `WitnessFamily/Compression/` and the model checker's JSON
  export contract are unchanged by this work.
- Task 693's A1 conformance surface reads the *deterministic* compression and is unaffected.

## Follow-ups

- Task **694** `sharing_substrate_trans_redesign` — the substrate fix: a fourth periodic datum
  `transBack`/`transMid`/`transFwd` giving `trans u : Fin n → Fin n → Prop`, `Thread.step`
  rewritten as `trans u (idx u) (idx (u+1))`, and the share/trans division of labour. Gated on a
  non-vacuity check plus an explicit check that the redesigned (C1') no longer entails
  `snce_share_congr`, both before the fixpoint layer is re-proved.
- Task **695** `plus_carrier_normalization_int_transfer` — `plusValidZTime_iff_plusValidInt`, an
  absent prerequisite for any L⁺ decidability route, blocked on nothing.
- The two excluded gate failures are pre-existing and out of scope here. C23 is already owned by
  task **691** `resolve_c23_naming_exemptions` (`not_started`); the `validate-state.sh` schema
  drift has no owning task and may be worth one.
- `context/project/lean4/domain/branching-certificate-conditions.md` (a research recommendation)
  was deliberately **not** written: its target is under `.claude/**`, a gitignored deploy artifact
  whose source store for this repository lives in a different repository entirely. The durable
  knowledge landed in the new module's docstring and the two corrected READMEs instead.

## References

- `specs/685_stability_compression_and_assembly/plans/01_land-refutation-and-rescope.md`
- `specs/685_stability_compression_and_assembly/reports/01_stability-compression-and-assembly.md`
- `specs/685_stability_compression_and_assembly/handoffs/` — one handoff per completed phase
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean`
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`
