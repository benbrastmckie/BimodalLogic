# Implementation Plan: Task #704

- **Task**: 704 - Certificate non-vacuity and shape gates
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: 696 (completed), 703 (completed). NOT 706 (researched only; its refutations are unlanded, see Overview).
- **Research Inputs**: specs/704_certificate_non_vacuity_and_shape_gates/reports/01_certificate-non-vacuity-shape-gates.md
- **Artifacts**: plans/01_certificate-non-vacuity-shape-gates.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Add two numbered checks to `scripts/check-module-invariants.sh`: **C36** (NON-VACUITY, with a
COVERAGE-LIMIT GUARD as its second table) and **C37** (CLAUSE-SHAPE CHECK), using the published
vocabulary of Beer, Ben-David, Eisner and Rodeh (2001): a certificate class is non-vacuous only
when it carries an exhibited INTERESTING WITNESS; the degenerate case is ANTECEDENT FAILURE. The
next free check numbers were confirmed at research time as C36/C37 (C35 is the last numeric;
`C25N`/`C9D` are letter-suffixed) and must be re-confirmed at implementation time.

The sliced class (`PlusSlicedCertificate`) currently has NO interesting witness: its only closed
`Certifies` fact, `Probe.exists_certifying_triv` (`Complete.lean`), sits at the empty closure --
antecedent failure by construction. So the gate cannot be written until one is exhibited. The
research probe showed `(Embedded.liveFamily.sliced (-1)).Certifies` closes by kernel `decide` in
about 5 s, axiom-clean -- but against a stale build; `specs/errors.json`'s
`err_20261002080500` records that the stale oleans were since purged and a full rebuild went
green (2806 jobs). Phase 1 re-establishes that evidence on a fresh build before anything rests
on it. Phase 2 lands the witness as a new module, `PlusSlicedCertificate/Examples.lean`, together
with every generated surface a new module touches (`FormalSystem.lean` via `mk_all`, the
`README.md` inventory block, `typst/generated/status.typ`). Phases 3-4 land C36 and C37; Phase 5
attempts the `⊡`-carrying Tier-2 sliced witnesses in a time box; Phase 6 closes documentation
and runs the full gate.

Definition of done: `bash scripts/check-module-invariants.sh` passes in both modes with C36
and C37 enforced; the sliced class has at least one interesting witness in the tree; the four
`Certifies`/`PlusCertifies` predicates under `Decidability/` each have an inventory row; the
Shape-(S) allowlist is seeded from the research's re-derived table and every row's anchor
resolves on the live tree.

### Research Integration

- **Every name in the description was re-verified** (report F1). Two layers of the description
  are stale: `PlusGraphCertificate` never existed (correctly superseded by the sliced class), and
  task 706's finite-carrier refutations (`Probe706.no_ofStep_sat` etc.) are NOT landed -- they
  exist only under `specs/706_*/probes/`, which no gate under `scripts/` may cite. The (a3)
  finite-carrier clause is therefore a RESERVED, commented row group, activated when the
  refutation module lands in `FormalSystem/`.
- **(a1) and the Stage-1 half of (a3) are already axiom-pinned by C2** (report F2). C36's value
  is the NAMED non-vacuity assertion with an explicit interesting-witness criterion and a
  `--no-build` structural half; it delegates `#print axioms` to C2 (set-membership, C21-style),
  never a second pin. `plusCompression_fails_at_pumpTarget` is NOT yet in `AXIOM_BASELINE` and
  must be pinned there for the coverage-limit subset check to hold.
- **The sliced condition set has nine conjuncts and zero Shape-(S) instances** (report F3): its
  two-regime liveness is a `Finset` equality, not a biconditional; its box clauses' right-hand
  sides mention no bound position.
- **Shape-(S) allowlist re-derived against the live tree** (report F6): 30 `↔`-bearing
  definitions across the three certificate roots; two genuine RESIDUAL rows (the (C1')
  `untl`/`snce` conjuncts over `trans`, reflexive by `trans_refl`), plus their `Formula`-side
  twins and four decision mirrors; everything else INTENDED or OUT-OF-SHAPE. The RESIDUAL rows
  are sibling task 705's subject, so the allowlist must turn a removed `trans_refl` into a
  visible stale-row FAIL, never a silent pass.
- **Four certificate classes carry a certifying predicate** (confirmed by grep):
  `WitnessFamily.Certifies` (`WitnessFamily/Predicates.lean`),
  `SharingWitnessFamily.Certifies` (`WitnessFamily/Sharing/Agreement.lean`),
  `PlusSharingWitnessFamily.PlusCertifies` (`PlusWitnessFamily/Agreement.lean`),
  `PlusSlicedCertificate.Certifies` (`PlusSlicedCertificate/Check.lean`). The sharing class has
  no closed-term inhabitant either; `Sharing/Specialize.lean`'s `certifies_toSharing` lifts
  `Embedded.liveFamily_certifies` to one in a single line, so Phase 2 exhibits it too.
- **Script conventions** (report F7): `pass`/`fail`/`info`/`note`/`soft` helpers; per-check
  `ENFORCE_Cnn` flag with a comment paragraph; `RUN_BUILD` gating; Python-heredoc checks exit 2
  for an untrustworthy scan and that exit is never suppressed (C34/C35 pattern); companion files
  listed in the header; C2's `mktemp --suffix=.lean` + `lake env lean` + `flock` on
  `.lake/build-guard.lock` scratch-compile pattern; the hook-enforced no-task-reference rule
  binds `scripts/` and `FormalSystem/`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found (no `roadmap_path` in the dispatch context).

## Goals & Non-Goals

**Goals**:
- C36a (`--no-build`): every `def Certifies`/`def PlusCertifies` under
  `FormalSystem/Metalogic/Decidability/` has a `witness` row in
  `scripts/certificate-witness-inventory.txt` whose declaration exists in source with a
  closed-term statement; every `coverage-limit` row's declaration exists and is a member of
  C2's `AXIOM_BASELINE`.
- C36b (`RUN_BUILD=1`): for every `witness` row, a scratch-file `#eval` of the row's
  interesting-witness expression prints `true` (closure non-empty, at least one formula of each
  claimed clause kind in play at the witness, so the clause "affects" the verdict in the
  Definition-1 sense); pass text uses the words "interesting witness" / "antecedent failure".
- C37 (`--no-build`): every `↔`-bearing `def`/`abbrev`/`structure` under the three certificate
  roots has a row in `scripts/clause-shape-allowlist.txt` with verdict
  `INTENDED|RESIDUAL|OUT-OF-SHAPE` and a reason anchor (declaration or file) that resolves on
  the live tree; an unlisted hit FAILs, a listed-but-absent row FAILs, a RESIDUAL row whose
  reflexivity anchor no longer exists FAILs.
- A non-degenerate `PlusSlicedCertificate` inhabitant in the tree
  (`liveFamily_sliced_certifies`), C2-pinned, plus the lifted sharing-class witness.
- Tier-2 `⊡`-carrying sliced witnesses for `targetA`/`targetB` (time-boxed; see Phase 5).

**Non-Goals**:
- Tier 3 of (a2): sliced certificates for `hopTarget`/`pumpTarget`. These contain `stab` and
  their sliced certifiability is the open finite-width question task 710 attacks; file a
  follow-up if Phase 5 shows the hand-built route generalises. The gate gates Tiers 1-2 only.
- Changing any verdict on the (C1') RESIDUAL rows (task 705's subject). C37 records and
  re-affirms; it never edits `Incompleteness.lean` or `Agreement.lean`.
- Soundness gates of any kind. Everything here guards completeness-side regressions.
- Porting an off-the-shelf vacuity algorithm. Published vacuity is post-hoc and
  model-relative; only the vocabulary and the "affects" criterion transfer (report, External
  Resources).
- `docs/theorem-index.md` entries for the new theorems: that file is in task 705's and task
  710's declared scope this cycle; leave it, and note the omission in the summary.
- Activating the finite-carrier coverage-limit rows (task 706 has not landed them).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale oleans make a `decide` probe answer about an older tree (the `err_20261002080500` defect) | H | M | Phase 1 runs the olean-vs-source mtime probe BEFORE trusting any build; purge-and-rebuild per the error record's workaround if any olean predates its source; C36b runs only under `RUN_BUILD=1` after C1, as C2 does |
| `liveFamily_sliced_certifies` does not close by `decide` on the fresh build, or exceeds the heartbeat/recursion budget | H | L | The family satisfies even the unfiltered `TailStable` (`Embed.lean`'s `liveFamily_tailStable`); if `decide` times out, use `set_option maxRecDepth 4096 in` as the probe did; if it still fails, fall back to the conjunct-by-conjunct route (`decidableCertifies` components) before declaring the phase blocked |
| Tier-2 (`⊡`-carrying) sliced certificates cannot be hand-built within the time box | M | M | Phase 5 is time-boxed at 2 h and closes `[COMPLETED WITH EXCLUSIONS]` with a reasoned exclusion; the gate already covers Tier 1, so nothing downstream depends on Tier 2 |
| Sibling task 705 declares `scripts/check-module-invariants.sh` and `Sharing/Agreement.lean` in its file_scope; a concurrent dispatch could edit the script mid-task | H | M | Re-read the script immediately before every edit and before every commit; stage only this task's hunks by explicit path; if a foreign modification or commit is observed, STOP and report per `context/contracts/territory.md` |
| Siblings 707/708 (undeclared scope, plan phase this cycle) touch a file this plan edits | M | L | Same re-read-before-edit discipline; a foreign uncommitted change to `README.md`, `typst/generated/status.typ`, or `FormalSystem.lean` is a stop-and-report event, not noise |
| Adding a module without regenerating every generated surface trips C33/INV/typst-sync | M | H (if forgotten) | Phase 2 is an `atomic-batch` whose declared file set includes `FormalSystem.lean`, `README.md`, `typst/generated/status.typ`; `lake exe mk_all --lib FormalSystem --check` and `--emit-inventory --check` run before its commit |
| C2's whole-string baseline comparison means pin additions must change the hard-coded count word exactly once | L | H | All C2 pin additions of this task happen in Phase 2 (and, if Tier 2 lands, once more in Phase 5); count the BASELINE lines before editing the word |
| `plusCompression_fails_at_pumpTarget` turns out to depend on an extra axiom | L | L | Then it is pinned with its actual axiom line (C2 pins what is true) and the coverage-limit row still passes set membership; record it in the summary |
| Purely textual Shape-(S) detection misclassifies a hit | M | M | C37 is enumerate-and-allowlist by design (the archived enumeration script itself says membership is a hand judgement); the mechanical assertions are existence of hit/row/anchor, not the verdict; a fixture self-test guards the matcher (C27/C34 precedent) |
| No-task-reference hook rejects an allowlist reason | L | M | Reasons cite declaration names and file paths only (`trans_refl`, `plusBox_const`, `Sharing/Agreement.lean`), never task numbers or `specs/` paths |

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

Phases within the same wave can execute in parallel. The plan is fully sequential because
Phases 2-5 all edit `scripts/check-module-invariants.sh` and a parallel dispatch on one file is
exactly the hazard `context/contracts/territory.md` exists to prevent.

### Phase 1: Build freshness and probe re-establishment [COMPLETED]

**Goal**: Establish, on a build whose oleans postdate every source, that the Tier-1 sliced
witness closes by `decide` and is axiom-clean, so that Phase 2 lands evidence rather than a
hope.

**Tasks**:
- [x] Run the staleness probe from `specs/errors.json` `err_20261002080500`: for every
      `FormalSystem/**/*.lean`, compare the source mtime against
      `.lake/build/lib/lean/FormalSystem/**/*.olean`; list every olean older than its source. *(completed: 640 sources, 0 stale or missing)*
- [x] If any is stale: delete that module's `.olean`/`.trace`/`.ilean` and `ir/*.c`,
      `ir/*.c.trace`, then build through `bash .claude/scripts/lake-build-guard.sh build`
      (never a bare `lake build` on this shared tree; see
      `context/patterns/bounded-build-waiter.md` for the wait discipline). If none is stale,
      still run the guarded build once to confirm the tree is green at HEAD. *(completed: none stale; guarded build green, 2806 jobs, 9 s)*
- [x] Re-run `specs/704_certificate_non_vacuity_and_shape_gates/probes/01_decide_sliced_inhabitant.lean`
      and `02_decide_conjuncts.lean` with `lake env lean <path>`; record wall time, the
      `#print axioms` lines, and the per-conjunct readouts in the phase's progress notes. *(completed: probe 01 11 s, both axiom-clean; probe 02 195 s, all nine conjuncts true)*
- [x] Confirm the second probe now AGREES with the landed
      `snceProbeLiveFamily_tailStable` (`EmbedComplete.lean`). If it still disagrees on a
      fresh build, STOP: that is a genuine kernel/elaboration divergence, not a cache defect,
      and must be reported rather than planned around. *(completed: agrees -- TailStable evaluates true on the fresh build)*
- [x] Confirm the next free check numbers by `grep -nE '^#   C3[5-9]' scripts/check-module-invariants.sh`
      and by scanning the `ENFORCE_` block; record them (expected C36, C37). *(completed: C36, C37 confirmed)*
- [x] Check `git log --oneline -5 -- scripts/check-module-invariants.sh` and `git status --short`
      for sibling activity on the files this plan edits; report any foreign change. *(completed: no foreign change; last touch 960e39ede)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: "The stale-olean defect is fully repaired and both probes agree with the
landed theorems on a fresh build." Confirm by the mtime probe (zero stale oleans) and by both
probe files compiling with the expected verdicts (`liveFamily` certifies; `snceProbeLiveFamily`
certifies too, now that `TailStable` is the liveness-filtered form).

**Files to modify**:
- none planned (read-only evidence phase; probe files under `specs/` may gain a result comment)

**Verification**:
- Zero oleans older than their source after the build.
- `lake env lean specs/704_certificate_non_vacuity_and_shape_gates/probes/01_decide_sliced_inhabitant.lean`
  prints two `depends on axioms: [propext, Classical.choice, Quot.sound]` lines and no error.
- Probe 02's per-conjunct `#eval`s all print `true` for `liveFamily.sliced (-1)`.

---

### Phase 2: Exhibit the interesting witnesses (sliced Tier 1 and sharing) [NOT STARTED]

**Goal**: Land the first non-degenerate `PlusSlicedCertificate` inhabitant and the lifted
`SharingWitnessFamily` inhabitant as library theorems, with every generated surface a new
module touches regenerated, and pin them (plus `plusCompression_fails_at_pumpTarget`) in C2.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` with the
      repository copyright header, importing
      `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Embed` (and
      `...WitnessFamily.Sharing.Specialize` if `Embed` does not already reach it). Module
      docstring: state, in the published vocabulary, that this module is the sliced class's
      NON-VACUITY record -- the INTERESTING WITNESS beside `Complete.lean`'s
      `Probe.exists_certifying_triv`, which is the class's ANTECEDENT FAILURE. Cite Beer et al.
      2001 by bibkey in a `## References` block only if `references.bib` already carries it
      (C31); otherwise cite by title in prose.
- [ ] `theorem liveFamily_sliced_certifies : (Embedded.liveFamily.sliced (-1)).Certifies := by decide`
      (with `set_option maxRecDepth 4096 in` only if needed), in namespace
      `FormalSystem.Metalogic.Decidability.WitnessFamily.Embedded` or a new
      `PlusSlicedCertificate.Examples` namespace -- choose the one whose `open`s keep the
      statement closed and readable, and record the fully qualified name for C2.
- [ ] `theorem liveFamily_toSharing_certifies : Embedded.liveFamily.toSharing.Certifies (-1) := certifies_toSharing _ Embedded.liveFamily_certifies`
      (adjust to the actual argument shape of `certifies_toSharing` in
      `WitnessFamily/Sharing/Specialize.lean`).
- [ ] A `#guard` line exercising `decidableCertifies` on the sliced witness is permitted
      (precedent: `PlusWitnessFamily/Examples.lean`); NO `#eval`/`#print`/`#check` (C27). No
      `lemma` (C23). Any new `def` is camelCase (C26).
- [ ] Add the import line to `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean`
      (aggregator), in the position matching its dependency order.
- [ ] Regenerate the library root: `lake exe mk_all --lib FormalSystem`, then
      `lake exe mk_all --lib FormalSystem --check` (C33). Never hand-edit `FormalSystem.lean`.
- [ ] Regenerate the inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`
      then `--emit-inventory --check` (README.md's live-file count moves from 640 to 641).
- [ ] Regenerate `typst/generated/status.typ` via `bash scripts/typst-status-counts.sh`
      (needs the built library) and confirm `bash scripts/typst-sync-check.sh` passes.
- [ ] Build through the guard; confirm zero new warnings for the new file (C28 budget is a
      ceiling; a new file has no entry and must stay at zero).
- [ ] Commit the batch as one green objective (module + aggregator + root + README +
      status.typ).
- [ ] Then, as a separate green sub-step: add three `#print axioms` lines and three BASELINE
      lines to C2 for `liveFamily_sliced_certifies`, `liveFamily_toSharing_certifies` and
      `PlusSharingWitnessFamily.plusCompression_fails_at_pumpTarget`; count the BASELINE lines
      and update the hard-coded count word in C2's pass message exactly once (expected
      twenty-six -> twenty-nine). Re-read the script immediately before editing (sibling
      hazard). Run `bash scripts/check-module-invariants.sh` (full mode) and confirm C2 PASS.
- [ ] Commit the C2 pin sub-step.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: "A new module under `FormalSystem/` touches exactly four generated or
aggregated surfaces: the subtree aggregator, `FormalSystem.lean` (C33), the `README.md`
inventory block (INV), and `typst/generated/status.typ` (typst-sync-check check 2)." Confirm by
running `check-module-invariants.sh --no-build`, `--emit-inventory --check`,
`mk_all --check` and `typst-sync-check.sh` after the batch; any further FAIL names a fifth
surface to add to this phase's file list. Also: "the C2 baseline currently has 26 lines";
confirm by `sed -n '/<<.BASELINE./,/^BASELINE$/p' | grep -c depends`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` - new module: the sliced class's interesting witness and the lifted sharing witness
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one aggregator import line
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem` (never by hand)
- `README.md` - generated inventory block regenerated by `--emit-inventory`
- `typst/generated/status.typ` - regenerated by `scripts/typst-status-counts.sh`
- `scripts/check-module-invariants.sh` - three C2 pins and the count word

**Verification**:
- `lake exe mk_all --lib FormalSystem --check` exits 0.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/typst-sync-check.sh` exits 0.
- `bash scripts/check-module-invariants.sh` (full) reports `PASS C2 all twenty-nine pinned axiom sets match baseline` (or whatever count the BASELINE line count gives), C3 zero sorries, C6/C24/C28/C33 PASS.
- `grep -rn 'no_ofStep_sat\|Probe706' FormalSystem scripts` is still empty (nothing cites the unlanded probe).

---

### Phase 3: C36 -- NON-VACUITY and COVERAGE-LIMIT GUARD [NOT STARTED]

**Goal**: Add the named non-vacuity gate with an explicit interesting-witness criterion, a
`--no-build` structural half, a `RUN_BUILD=1` evaluative half, and a coverage-limit table that
keeps the old class's limits from being overstated again.

**Tasks**:
- [ ] Create `scripts/certificate-witness-inventory.txt` (header comment on the
      `debug-artifact-allowlist.txt` model: purpose, admission bar, the two row kinds, the
      published vocabulary and its source). Row grammar, `|`-separated:
      - `witness | <class predicate FQN> | <witness declaration FQN> | <target declaration or literal> | <clause kinds, comma-separated from {imp,untl,snce,box,stab}> | <interest expression: Lean Bool term>`
      - `coverage-limit | <declaration FQN> | <what it refutes, one phrase> | <anchor file>`
      Seed `witness` rows: `PlusSharingWitnessFamily.PlusCertifies` with
      `plusCertifies_stabSnce_example` (targetA; kinds snce,stab) and
      `plusCertifies_stabUntl_example` (targetB; kinds untl,stab);
      `PlusSlicedCertificate.Certifies` with `liveFamily_sliced_certifies` (`Embedded.evTarget`;
      kind untl); `WitnessFamily.Certifies` with `Embedded.liveFamily_certifies` (kind untl);
      `SharingWitnessFamily.Certifies` with `liveFamily_toSharing_certifies` (kind untl).
      The interest expression is a closed `Bool` term that is `true` iff the closure at the
      witness contains at least one formula of each claimed kind AND at least one label of the
      witness contains such a formula (so the clause's guard is occupied: negating the clause
      body there would flip `Certifies` -- the Definition-1 "affects" criterion). Write it
      against the real accessors (`plusClosureOf`, `closureOf`, the family's `L`/`lassos`
      labels, the sliced `slab`/`slice`); confirm each evaluates with `#eval` in a scratch
      file before committing the row.
      Seed `coverage-limit` rows: `not_exists_hopFree_plusCertifies_hopTarget`,
      `not_exists_plusCertifies_pumpTarget`, `plusCompression_fails_at_pumpTarget`,
      `not_plusValidZTime_hopTarget`, `not_plusValidZTime_pumpTarget` (all under
      `PlusWitnessFamily/Limits/`). Add a COMMENTED, reserved `finite-carrier` row group naming
      `no_finite_carrier_sat`, `no_ofStep_sat`, `not_finite_carrier_fmp`,
      `not_plusValidZTime_neg_θ`, "pending the finite-carrier refutation module
      (`FiniteCarrier.lean`) landing in the tree" -- cite the future module name, never a
      `specs/` path or task number.
- [ ] C36a (Python heredoc, runs in every mode; C34 pattern, reusing `scripts/lib/live_walk.py`
      and `lean_citations.py`'s `decl_spans`): (i) enumerate every `def Certifies` /
      `def PlusCertifies` under `FormalSystem/Metalogic/Decidability/` with its enclosing
      namespace -- anti-silence: zero found or fewer than four is exit 2; (ii) every such
      predicate has at least one `witness` row -- a class with no row FAILs by name
      ("antecedent failure: no interesting witness exhibited for <class>"); (iii) every
      `witness` row's declaration exists in source and its statement is a closed term of the
      form `<term>.Certifies ...` / `<term>.PlusCertifies ...` with no `∃`, `∀`, `→` or `¬`
      at the top level (an existence theorem is not a witness); (iv) every `coverage-limit`
      row's declaration exists and its FQN appears in C2's `AXIOM_BASELINE` (read the
      heredoc from the script's own text, C21 style); (v) a row naming a declaration that no
      longer exists FAILs as stale (C26 precedent). Fixture self-test for the closed-term
      matcher runs first (C27/C34 precedent).
- [ ] C36b (`RUN_BUILD=1` only, after C1, under the same `flock` on `.lake/build-guard.lock`
      C2 uses): write a scratch `.lean` via `mktemp --suffix=.lean` importing `FormalSystem`,
      with one `#eval` per `witness` row evaluating the row's interest expression, plus one
      `#eval` of the closure cardinality; run `lake env lean`; assert every line prints
      `true` / a positive number. Delegate axioms to C2 (no `#print axioms` here). Pass text:
      "C36 every certificate class carries an interesting witness (N witness rows, M
      coverage-limit rows); no antecedent failure". Skipped under `--no-build` with an
      `info C36b skipped (--no-build)` line.
- [ ] Add `ENFORCE_C36=${ENFORCE_C36:-1}` with its comment paragraph (ship enforced on the
      C24/C25/C26 precedent; exit 2 never suppressed), the header enumeration lines for C36
      (both halves, noting which half runs under `--no-build`), the companion-file line for
      `scripts/certificate-witness-inventory.txt`, and the `--no-build` usage note update.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and the full mode; both PASS.
      Negative test (then revert): delete the sliced witness row -> C36a FAILs naming
      `PlusSlicedCertificate.Certifies`; rename a coverage-limit FQN -> stale-row FAIL.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: "Exactly four `def Certifies`/`def PlusCertifies` predicates exist under
`Decidability/`, and each of the five seeded witness rows admits a closed `Bool` interest
expression that `#eval` can run in under a few seconds." Confirm the count with
`grep -rnE '^(def|abbrev) (PlusCertifies|Certifies)\b' FormalSystem/Metalogic/Decidability/`
and each expression by scratch-file `#eval` before committing the row.

**Files to modify**:
- `scripts/certificate-witness-inventory.txt` - new companion file: witness and coverage-limit rows
- `scripts/check-module-invariants.sh` - C36a/C36b bodies, `ENFORCE_C36`, header lines, companion-file line

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` prints `PASS C36` for the structural half and `INFO C36b skipped (--no-build)`.
- Full mode prints both PASS lines with the published vocabulary in the pass text.
- The two negative tests produce named FAILs and are reverted before commit.
- `bash .claude/scripts/check-task-references.sh` (or the write-time hook) accepts the new companion file.

---

### Phase 4: C37 -- CLAUSE-SHAPE CHECK [NOT STARTED]

**Goal**: Make the collapsing clause shape -- a universally quantified biconditional under a
reflexive relational guard whose left side does not mention the bound variable -- impossible to
reintroduce silently, by enumerating every `↔`-bearing definition in the three certificate
trees against a reviewed allowlist whose anchors are re-verified on every run.

**Tasks**:
- [ ] Create `scripts/clause-shape-allowlist.txt`, header stating Shape (S) precisely (the
      archived enumeration's definition: `∀ x, R a x → (P ↔ Ψ(x))`, `R` reflexive at the
      instantiated argument, `P` not mentioning `x`), the verdict vocabulary, the admission
      bar (a new row needs a reason anchor that is a declaration name or a file path), and
      the rule that the mechanical check asserts existence of hit, row and anchor -- the
      verdict is the recorded human judgement. Row grammar: `<path> | <declaration> | <clause, or - > | INTENDED|RESIDUAL|OUT-OF-SHAPE | <guard relation or -> | <anchor: declaration or file> | <reason>`.
      Seed all 30 rows from the research's F6 table, including: the two RESIDUAL rows
      (`PlusLocalCoherentShare` `untl` and `snce` conjuncts, guard `trans`, anchor
      `trans_refl` with residues `untl_succ_congr`/`snce_pred_congr` in
      `Sharing/Agreement.lean`), their `Formula`-side twins in `LocalCoherentShare`, the four
      decision mirrors (`plusShareClauseAt`, `shareClauseAt` arms), the INTENDED congruence
      rows (`PlusAtomCoherent`, `AtomCoherent`, the `atomClauseAt` mirrors; `StabFaithful` and
      `stabClauseAt`; the box-faithfulness family with anchor `plusBox_const`), the sliced
      rows (`BoxFaithful`, `BoxLabelFaithful`, `BoxLabelFaithfulWindow`, `BoxLiveFaithful`,
      `StabFaithful` in `Check.lean`), and the OUT-OF-SHAPE rows (`imp`/`box` conjuncts,
      `SlabTrue`, `AgreesOnState`, `impClauseAt`/`untlClauseAt`/`snceClauseAt`,
      `Live.splice`).
- [ ] C37 (Python heredoc, every mode): (i) walk the three roots
      `FormalSystem/Metalogic/Decidability/{PlusWitnessFamily,PlusSlicedCertificate,WitnessFamily}/`
      via `live_walk`; (ii) recover declaration spans with `decl_spans`, mask comments and
      docstrings with `lean_debug_artifacts.mask`/`comments_only` so a `↔` in prose is not a
      hit; (iii) a hit is a `def`/`abbrev`/`structure`/`class` span whose masked body contains
      `↔`; anti-silence: zero hits or zero spans is exit 2; (iv) every hit has an allowlist
      row (path+declaration) -> else FAIL "unreviewed biconditional clause"; (v) every row
      has a hit -> else FAIL stale; (vi) every row's anchor resolves: a declaration anchor is
      found by `decl_spans` somewhere under `FormalSystem/`, a file anchor exists on disk ->
      else FAIL "anchor no longer on the tree" (this is what turns task 705 removing
      `trans_refl` into a visible FAIL on the RESIDUAL rows); (vii) an ungated CENSUS printed
      every run (C34 precedent): hit count per root, verdict counts, and the reflexive-relation
      roster recovered by the archived pass 3 (`_refl` theorem names, `@[refl]`, `Reflexive`)
      restricted to the three roots. Fixture self-test for the `↔`-under-mask matcher runs
      first.
- [ ] Add `ENFORCE_C37=${ENFORCE_C37:-1}` with its paragraph, header lines, and the
      companion-file line. State in the paragraph that the RESIDUAL verdict is a record of a
      live defect under separate repair, that flipping it to INTENDED requires the residue
      declarations to be gone, and that this check never softens to quiet a failure.
- [ ] Run both modes; PASS. Negative tests (then revert): add a dummy `↔`-bearing `def` in a
      scratch copy of a root file -> FAIL unreviewed; change a row's anchor to a non-existent
      name -> FAIL anchor.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: "The masked `↔` scan over the three roots yields exactly the 30
definitions in the research's F6 table." Confirm by diffing the C37 census against the F6
rows on first run; any extra hit is a row to review and add (with its own verdict), any
missing hit is a matcher gap to fix before enforcing.

**Files to modify**:
- `scripts/clause-shape-allowlist.txt` - new companion file: the reviewed Shape-(S) allowlist, seeded from the research table
- `scripts/check-module-invariants.sh` - C37 body, census, `ENFORCE_C37`, header lines, companion-file line

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` prints `PASS C37` and the census block.
- Census hit count equals the allowlist row count (30 expected; the confirmed number is recorded in the summary).
- Both negative tests produce named FAILs and are reverted before commit.

---

### Phase 5: Tier-2 sliced witnesses carrying `⊡` (time-boxed) [NOT STARTED]

**Goal**: Exhibit sliced certificates for `targetA = (⊤ S p) → ⊡(⊤ S p)` and
`targetB = (⊤ U p) → (¬p → ⊡(⊤ U p))` -- the sliced twins of the (a1) witnesses -- so that
`StabFaithful` and `BoxLiveFaithful` are live at an inventory row and the gate's sliced coverage
is not confined to a `⊡`-free target.

**Tasks**:
- [ ] In `PlusSlicedCertificate/Examples.lean`, hand-build `certA` (and `certB`): width
      `n = 2`, one slice per segment where possible, two threads differing in whether `p` lies
      in the past (resp. future) of the target time, `bx` chosen so `BoxLabelFaithful` and
      `BoxLiveFaithful` hold, labels chosen so `StabFaithful` separates `⊡(⊤ S p)` from
      `⊤ S p` at the target position. Use `onePointCertificate` (`Basic.lean`) as the shape
      reference and `Fixture.cert` (`Fixture.lean`) as the construction idiom.
- [ ] `theorem certA_certifies : certA.Certifies := by decide` (and `certB`). If `decide` does
      not close within the heartbeat budget, isolate the failing conjunct with the
      `decidableCertifies` components as probe 02 does, and repair the construction; do not
      raise `maxHeartbeats` for a whole section (C30).
- [ ] Add the two `witness` rows (kinds `snce,stab` / `untl,stab`) with interest expressions
      to `scripts/certificate-witness-inventory.txt`; add the two C2 pins and update the count
      word once; run both gate modes.
- [ ] **Time box: 2 hours of implementation effort.** If a certifying construction is not
      found within it, close this phase `[COMPLETED WITH EXCLUSIONS]` with a
      `#### Reasoned Exclusions` record naming what was tried and why it failed, leave the
      inventory at Tier 1, and recommend a follow-up task in the summary (it is adjacent to
      task 710's sliced finite-width question). Do NOT leave a `sorry` (C3) or a half-built
      `def`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: "Width-2 sliced certificates for `targetA`/`targetB` exist and
`decide` closes `Certifies` for them in seconds." Confirm by construction; if `n = 2` is too
narrow for `StabFaithful` to separate, try `n = 3` once before invoking the time box.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` - `certA`/`certB` and their `Certifies` theorems
- `scripts/certificate-witness-inventory.txt` - two Tier-2 witness rows
- `scripts/check-module-invariants.sh` - two C2 pins and the count word

**Verification**:
- Full-mode gate PASS with C2's count word updated once and C36b evaluating the new rows `true`.
- Or: phase heading `[COMPLETED WITH EXCLUSIONS]` with a complete exclusion record and no residue in the tree.

---

### Phase 6: Documentation, CI-gap note, and final gate [NOT STARTED]

**Goal**: Make the two new companion files and the one new build-gated half discoverable where
the repository documents such things, and prove the whole gate green in both modes.

**Tasks**:
- [ ] `scripts/README.md`: add rows for `certificate-witness-inventory.txt` and
      `clause-shape-allowlist.txt` to the "Allowlists, manifests, and other data files" table,
      in the table's alphabetical order, each one sentence naming its consuming check.
- [ ] `docs/development/CI_CD_PROCESS.md` "Known Not-in-CI Gaps": add `C36b` (the evaluative
      half runs only in full mode; C36a and C37 run in `--no-build` and therefore in CI). No
      task numbers (C9D).
- [ ] `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` (if it exists) or
      the subtree aggregator docstring: one line pointing at `Examples.lean` as the class's
      non-vacuity record. Skip if neither file carries a per-module table.
- [ ] Run, in this order, and paste the verdict lines into the summary:
      `bash scripts/check-module-invariants.sh --no-build`;
      `bash scripts/check-module-invariants.sh` (full, through the build guard's lock);
      `bash scripts/typst-sync-check.sh`; `lake exe mk_all --lib FormalSystem --check`;
      `bash scripts/check-module-invariants.sh --emit-inventory --check`.
- [ ] Final sibling check: `git status --short` shows only this task's files; `git log` shows
      no foreign commit on them since Phase 1. Commit with explicit paths.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- `scripts/README.md` - two data-file table rows
- `docs/development/CI_CD_PROCESS.md` - one Known-Not-in-CI-Gaps entry for C36b

**Verification**:
- All five commands above exit 0; `ALL CHECKS PASSED` printed in both invariant modes.
- `bash .claude/scripts/check-task-references.sh` reports no new task-number citation outside `specs/`.

## Testing & Validation

- [ ] Phase 1: zero stale oleans; probe 01 prints two axiom-clean lines; probe 02 all `true`.
- [ ] Phase 2: `mk_all --check`, `--emit-inventory --check`, `typst-sync-check.sh` all exit 0; C2 PASS with the new count word.
- [ ] Phase 3: C36a PASS in `--no-build`; C36b PASS in full mode; both negative tests FAIL by name.
- [ ] Phase 4: C37 PASS; census count equals allowlist row count; both negative tests FAIL by name.
- [ ] Phase 5: either two more axiom-clean witness rows, or a complete exclusion record.
- [ ] Phase 6: `ALL CHECKS PASSED` in both modes; no task-number citation outside `specs/`.
- [ ] Throughout: `grep -rn 'Probe706\|no_ofStep_sat' FormalSystem scripts docs` stays empty.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` (new)
- `scripts/certificate-witness-inventory.txt` (new)
- `scripts/clause-shape-allowlist.txt` (new)
- `scripts/check-module-invariants.sh` (C36, C37, three-to-five C2 pins)
- Regenerated: `FormalSystem.lean`, `README.md` inventory block, `typst/generated/status.typ`
- `scripts/README.md`, `docs/development/CI_CD_PROCESS.md` (documentation rows)
- `specs/704_certificate_non_vacuity_and_shape_gates/summaries/01_certificate-non-vacuity-shape-gates-summary.md`

## Rollback/Contingency

- Each phase commits only when both gate modes are green, so rollback is `git revert` of the
  phase's commit(s); the Phase 2 batch reverts as one commit and restores the 640-file
  generated surfaces together.
- If a genuine rollback of uncommitted work is ever needed (e.g. Phase 5 abandoned mid-way),
  take the snapshot per `context/contracts/recovery.md`'s rollback rung first (task number
  explicit; the out-of-scope override only if the revert must touch a generated file outside
  this plan's list) -- never `git-snapshot.sh` in its reverting default mode on this shared
  tree with siblings live, and never a directory or glob `git add`.
- If C36b proves too slow for the full-mode budget, keep it enforced but move the interest
  expressions' evaluation into the C2 scratch file (one `lake env lean` invocation instead of
  two); never soften `ENFORCE_C36`.
- If Phase 1 reveals a real kernel/elaboration divergence on the fresh build, stop the task at
  `[BLOCKED]` with the evidence; nothing downstream is worth building on a tree whose `decide`
  verdicts disagree with its landed theorems.
