# Implementation Plan: Task #724

- **Task**: 724 - Decidability of Z-time provability as a corollary of `Compression.decidableValidZTime`
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None (task 723 completed; its C14 trailing-block rows are the shape this task extends)
- **Research Inputs**: `specs/724_decidable_ztime_provability_witness_family_corollary/reports/01_decidable-ztime-provability-corollary.md`
- **Artifacts**: plans/01_decidable-ztime-provability-corollary.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land `Decidable (Derivable FrameClass.ZTime [] φ)` as a six-line corollary composing
`soundness_ztime_valid`, `BXCanonical.derivable_of_validZTime`, and
`Compression.decidableValidZTime`. The mathematics is already settled: research compiled both
declarations in situ via `lean_run_code` and measured their axiom sets as
`[propext, Classical.choice, Quot.sound]`, so the work here is placement, import wiring, and the
mechanical gate obligations (C9, C14, C15, C17, C26, C27, C33, C37) that a new pinned declaration
triggers. Done means: the `def` exists and compiles, its docstring carries every qualifier,
`docs/theorem-index.md` has a row, the C14 matched pair pins the row, and both `lake build` and
`bash scripts/check-module-invariants.sh` are green.

### Research Integration

Four findings from the report drive this plan and override the dispatch where they conflict:

1. **Placement is decided against the dispatch's suggestion, on measurement.** The dispatch offers
   `WitnessFamily/Compression/Assembly.lean` "or a sibling module under
   `WitnessFamily/Compression/`" and requires the import graph be resolved first. It was resolved:
   **no cycle exists in any option**, but both offered placements cost **+331 / +318 net-new
   transitive imports** and propagate into `BimodalTools/CertificateImport.lean`, against **+2**
   for `FormalSystem/Metalogic/ZTimeProvability.lean` (whose two additions are already in the
   `FormalSystem.lean` root closure, so repository-wide build cost is unchanged). `Metalogic.lean`
   is already the one aggregator importing both `Decidability` and `BXCanonical`. **The plan names
   `FormalSystem/Metalogic/ZTimeProvability.lean`; the implementer must not revert to
   `Assembly.lean`.**
2. **The exact working terms are recorded, including the one failure mode.**
   `decidable_of_iff (a) (h : a ↔ b) : Decidable b`, so the iff argument must be
   `(derivable_iff_validZTime φ).symm` — `.symm` on the *iff*, not on the `decidable_of_iff`
   application. The other direction gives `Application type mismatch`.
3. **The docstring must NOT say "task 412's"**, which the dispatch's DOCSTRING REQUIREMENT asks
   for. C9 asserts zero task-number citations under `FormalSystem/`, and
   `.claude/rules/no-task-references-in-deliverables.md` forbids them outside `specs/**`, commit
   messages and PR metadata. Three verified durable anchors replace it (Phase 1 below).
4. **The C14 edit is pre-authorized, with its shape spelled out**, by the comment block
   immediately above `C14_BASELINE` in `scripts/check-module-invariants.sh` — which also means
   that comment's own descriptive count ("The final three lines of this pair…") goes stale on
   landing and must be reconciled in the same change.

### Prior Plan Reference

No prior plan. This is round 1 for task 724.

### Roadmap Alignment

`roadmap_flag` was not set for this dispatch, so no roadmap-review/roadmap-update phases are
added. `specs/ROADMAP.md` does carry an unticked checkbox for exactly this deliverable ("Land
`Decidable (Derivable FrameClass.ZTime [] φ)` as a corollary of `Compression.decidableValidZTime`
… closing decidability of provability over ℤ without the spine"), immediately after the task 723
checkbox this task extends. Ticking it is an optional, non-blocking bullet in Phase 3; it is not
part of acceptance.

## Goals & Non-Goals

**Goals**:

- `derivable_iff_validZTime`
- `decidableDerivableZTime`
- Both land in a new module at the measured-cheapest placement, wired into the library root and
  the metalogic aggregator without an import-weight regression.
- The declaration that the theorem index names is machine-pinned by a C14 matched pair in the same
  change set, so no index row is prose-only and no new declaration reads as dead to C17.
- Every gate the new module touches passes: the build-free set and the build-backed set both.

**Non-Goals**:

- The tableau spine. Not touched, not extended, not re-opened.
- Any complexity or running-time claim. The compression module header already states the cost
  honestly and points at its literature source; cite that, never restate a bound.
- The phrase "TM is decidable" unqualified, in any file, in any form.
- The C9 do-not-re-attempt register. Not re-opened.
- A global `Decidable` instance. This is a `def`, matching the two existing siblings.
- Editing the Verified subdirectory README's "not built" verdict on the never-created
  `Provable.lean`. That verdict is about the spine-route, `fc`-parameterized shape and remains
  accurate; editing it is adjacent to the do-not-touch-the-spine constraint. An optional
  one-sentence cross-reference there is explicitly out of scope for acceptance.
- Base, Dense and RTime provability decidability. Those three remain owed by the spine's
  completeness direction.
- Rows in the witness-family or compression subdirectory README module tables — not needed, because
  the recommended placement is outside that subtree.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer follows the dispatch's suggested compression-subtree placement and lands a +331-import regression | H | M | Phase 1 names the file path explicitly and Phase 1's verification re-states the measured alternative; the report's measured table is the evidence of record |
| "task 412" (or any task number) written into the new docstring → C9 fails | H | M | Phase 1 supplies the three verified durable anchors and the recommended phrasing shape; the C9 check runs build-free in Phase 4 |
| `decidable_of_iff` direction mismatch → `Application type mismatch` | L | M | The exact working term and the exact failure mode are recorded in Phase 1's task list |
| Library-root import inserted out of code-point-sorted order → C33 fails | M | M | Phase 2 pins the exact insertion point (immediately after the weak-canonical truth-lemma import, immediately before the first minus-language import) and verifies via the gate's own build-free C33 scan rather than by eye |
| C14 matched pair appended to only one heredoc, or at mismatched positions | H | M | Phase 4 gives both content anchors (the trailing `decidableValidZTime` line in each heredoc) and states that the baseline compares concatenated output in emission order, so trailing position must match on both sides |
| New `def` lands with no index row and no baseline line in the same change → C17 flags it dead | M | M | Phases 3 and 4 are in the same wave as Phase 2 and all land before the Phase 5 gate run; the Lean file, the index row and the C14 pair are one change set |
| A live `#print axioms` line in the new module → C27 fails (no allowlist entry for it) | M | M | Phase 1 requires any axiom-audit text to sit inside a `/-! … -/` block, as the completeness and assembly modules already do |
| A `↔` token inlined into the `def` body → C37 risk if placement ever moves under a certificate root | L | L | Two declarations, not one: the biconditional stays a separate `theorem`. Do not inline it |
| A SORRY-FREE bullet added to the metalogic aggregator docstring naming an unpinned declaration | M | L | Phase 2 forbids adding such a bullet for anything the Phase 4 C14 pair does not pin |
| `lake build` overruns the dispatch | M | M | Phase 5 runs it detached and guarded per `context/project/lean4/operations/long-builds.md` and `context/patterns/bounded-build-waiter.md`. The mathematics is already compiled-probe verified, so a build timeout is a gate risk, not a correctness risk; resume from Phase 5 |
| Index-row Axioms column typed rather than derived | L | L | The column reads `pcq pinned:C14` and is generated from the baseline; Phase 4 lands the baseline line that makes the claim true |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Create `FormalSystem/Metalogic/ZTimeProvability.lean` [COMPLETED]

**Goal**: The new module exists with both declarations and fully compliant docstrings, and
compiles on its own.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/ZTimeProvability.lean` with the standard copyright header
      used by its sibling metalogic modules.
- [x] Three imports, nothing more: `FormalSystem.Metalogic.Soundness`,
      `FormalSystem.Metalogic.BXCanonical.Completeness`,
      `FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly`.
- [x] `namespace FormalSystem.Metalogic` with
      `open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics`. Namespace is
      `FormalSystem.Metalogic` — **not** a compression sub-namespace: that keeps C23's shadow-pair
      allowlist untouched, keeps the compression README's standing "one sub-namespaced
      declaration" statement true, and reflects that this is a metalogic corollary rather than
      part of the compression route.
- [x] Write `theorem derivable_iff_validZTime (φ : Formula) : Derivable FrameClass.ZTime [] φ ↔ ValidZTime φ`
      as the anonymous constructor. Forward leg
      `fun h => h.elim (fun d => soundness_ztime_valid d)` — the `Nonempty` elimination is required
      because `Derivable fc Γ p` is literally `Nonempty (DerivationTree fc Γ p)`; the target is a
      `Prop`, so this step introduces no choice. Backward leg
      `BXCanonical.derivable_of_validZTime φ`.
- [x] Write `def decidableDerivableZTime (φ : Formula) : Decidable (Derivable FrameClass.ZTime [] φ)`
      as `letI := Decidability.Compression.decidableValidZTime φ` followed by
      `decidable_of_iff (ValidZTime φ) (derivable_iff_validZTime φ).symm`. **The `.symm` goes on the
      iff, not on the `decidable_of_iff` application**: `decidable_of_iff (a) (h : a ↔ b)` yields
      `Decidable b`, so `h` must run validity → derivability. Writing it the other way round gives
      `Application type mismatch`. The empty-premise semantic-consequence corollary at the tail of
      the compression assembly module is the exact same shape; copy it.
- [x] Keep the biconditional in its own `theorem`. **Do not inline it into the `def` body** — that
      leaves no `↔` token in any `def` body, which is what keeps C37 a non-issue if placement ever
      moves under a certificate root.
- [x] `def`, not `instance`, matching `Compression.decidableValidZTime` and the bilasso assembly's
      family procedure. Say so in the docstring: a global
      `Decidable (Derivable FrameClass.ZTime [] φ)` instance would change instance resolution
      repository-wide.
- [x] Name check for C26: no non-trailing underscore in a live `def`/`abbrev` name.
      `decidableDerivableZTime` conforms; a snake_case `def` name would FAIL. The companion
      `theorem` may use underscores — C26 scopes to `def`/`abbrev`.
- [x] Docstring on the `def` carries **every qualifier**: frame class `FrameClass.ZTime`; the
      object language is `Formula`, which has **no stability operator** (the box-dot belongs to
      `PlusFormula`); premises are **empty** (`[]`).
- [x] Docstring records that this closes **decidability of provability over ℤ — one of the four
      frame-class deliverables the tableau spine was to supply — without the spine**, and that the
      other three (`Base`, `Dense`, `RTime`) remain owed by the spine's completeness direction.
      Cite these three verified durable anchors and **no task number**:
      - the `Provable.lean` row in `FormalSystem/Metalogic/Decidability/Verified/README.md`
        ("Track B: `Decidable (Derivable fc [] φ)` and the completeness corollaries | not built"),
        the `fc`-parameterized spine deliverable this corollary does not supply;
      - the section "`validity_decidable` / `validity_has_decision_procedure` — Retired as
        vacuous" in `FormalSystem/Metalogic/Decidability/Correctness.lean`;
      - the Status section of `FormalSystem/Metalogic/Decidability.lean`, which records the
        four-frame-class `Decidable (⊨ φ)` instances as open.
- [x] Docstring carries `Paper: —` **plus a reason**, for C15. Mirror the wording the compression
      assembly module already uses on its two pinned declarations ("formalization-native; the
      paper's commented-out decidability corollary carries no live label, and states nothing about
      the witness-family route").
- [x] Never write "TM is decidable" unqualified. Land **no** complexity claim: point at the
      compression assembly module's own header for the cost statement and its literature source
      rather than restating any bound.
- [x] If an axiom-audit note is included, put it **inside a `/-! … -/` block**, as the completeness
      and compression assembly modules do. A live `#print axioms` in library code fails C27, and
      neither of those files has a debug-artifact allowlist entry — their audit lines survive only
      because C27 masks docstring regions.
- [x] No task-number citation anywhere in the file (C9, and
      `.claude/rules/no-task-references-in-deliverables.md`).

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the module is **one new file with exactly two
declarations and exactly three imports**, and that the two declaration bodies are the exact terms
the research probe compiled. Confirm at implementation time by building the module alone
(`lake build FormalSystem.Metalogic.ZTimeProvability`) and reading the diagnostics: zero errors,
zero warnings, zero sorries. If a third import or a third declaration turns out to be needed, that
is a hypothesis failure — record it in the issue log rather than absorbing it silently, because
the +2 import-weight measurement in Phase 2 was computed against exactly these three imports.

**Files to modify**:

- `FormalSystem/Metalogic/ZTimeProvability.lean` - new file; both declarations and their docstrings

**Verification**:

- `lake build FormalSystem.Metalogic.ZTimeProvability` succeeds with no error, no warning, no
  sorry. This is a single new module with no externally visible signature change anywhere else,
  which is exactly the `local` tier's scope.
- `grep -n 'sorry' FormalSystem/Metalogic/ZTimeProvability.lean` returns nothing.
- The file contains no live `#check`/`#print`/`#eval` outside a `/-! … -/` block.
- The file contains no task-number citation.
- **Known blind spot of this tier** (deferred to Phases 2 and 5): whether the new module's import
  closure is cycle-free against the library root and the aggregators, and whether the measured
  net-new import cost holds. Research found no cycle in any placement option, but the import graph
  is not exercised until Phase 2 builds the root.

---

### Phase 2: Wire the module into the library root and the metalogic aggregator [COMPLETED]

**Goal**: The new module is reachable from `FormalSystem.lean` in correct sorted position and
re-exported by `FormalSystem/Metalogic.lean`, with no cycle and no import-weight regression.

**Tasks**:

- [x] Insert `import FormalSystem.Metalogic.ZTimeProvability` into `FormalSystem.lean` in
      code-point-sorted position: **immediately after** the weak-canonical truth-lemma import and
      **immediately before** the first minus-language import. (`Metalogic.W…` < `Metalogic.Z…` <
      `MinusLanguage`.) C33 requires the file be byte-for-byte the generated root, one sorted
      import line per `.lean` under the library directory.
- [x] Append `import FormalSystem.Metalogic.ZTimeProvability` to `FormalSystem/Metalogic.lean`'s
      re-export list. *(deviation: altered — two further machine-generated artifact sets
      had to be regenerated in the same change set, because adding a `.lean` file under
      `FormalSystem/` invalidates them and the pre-commit gate refuses the commit otherwise: the
      three README inventory blocks via `check-module-invariants.sh --emit-inventory`, and
      `typst/generated/status.typ` via `typst-sync-check.sh --fix`. Phases 1 and 2 are therefore
      one commit rather than two.)* That list is a hand-maintained convenience block and is **not**
      alphabetically sorted — append at the end of the block rather than forcing a sort.
- [x] **Do not** add a SORRY-FREE bullet to the metalogic aggregator's module docstring unless the
      Phase 4 C14 pair pins its subject. The gate script's own comment makes an unpinned SORRY-FREE
      bullet exactly the drift the C14 second block exists to catch.
- [x] Confirm the import addition is cycle-free in fact, not only in the report: neither the
      soundness module nor the BX-canonical completeness module transitively imports anything under
      the decidability subtree, and the importers of `FormalSystem.Metalogic` (the main-results
      module, the walkthrough example, and the library root) are imported by neither leg.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts **exactly two import-line insertions, in two files**, and
that the metalogic aggregator gains **+2 net-new transitive modules** (the compression assembly and
enumerate modules), both already in the library-root closure, so repository-wide build cost is
unchanged. Confirm at implementation time by `git diff --stat` on the two files (expect one added
line each, no other hunk) and by the Phase 5 build being an incremental rebuild of the metalogic
aggregator's dependents rather than a from-scratch library build. If the build is unexpectedly
broad, the +2 measurement did not hold — record it.

**Files to modify**:

- `FormalSystem.lean` - one sorted import line for the new module (C33)
- `FormalSystem/Metalogic.lean` - one appended re-export import line

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` reports **PASS C33** (the generated-root
  scan is a build-free python scan inside the gate script itself; it sorts dotted names in
  code-point order and compares byte-for-byte, so it is the authority on insertion position — do
  not eyeball it).
- `lake build FormalSystem.Metalogic` succeeds: the changed aggregator plus the new module.
- `lake build` of the enumerated one-hop dependents of the changed aggregator (the main-results
  module and the walkthrough example) succeeds. This enumerated-dependent set is what the
  `interface` tier covers.
- C24 (every root-closure module transitively imports the init module) and C8 (aggregator
  convention requires `X.lean` beside `X/`, which a new *file* does not trigger) are reported by
  the same build-free run.
- **Known blind spot of this tier** (deferred to Phase 5): transitive breakage beyond the
  enumerated one-hop dependents, and every build-backed gate — C2 and C14 in particular, which
  need the whole library built before `#print axioms` can be run against the root.

---

### Phase 3: Add the `docs/theorem-index.md` row [COMPLETED]

**Goal**: The theorem index carries a row for the new `def`, conforming to the page's own column
contract.

**Tasks**:

- [x] Add one row to the `### Decidability` table, **immediately after** the
      `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` row.
- [x] Column contract, read off the page's own "How to read a row": Paper label `—`; Statement one
      line; Lean name **fully qualified, always** (`FormalSystem.Metalogic.decidableDerivableZTime`);
      File **path only, no line numbers** (`FormalSystem/Metalogic/ZTimeProvability.lean`); Frame
      class `ZTime`; Axioms `pcq pinned:C14`.
- [x] Suggested Statement text, honouring every qualifier: *"Decidability of ℤ-time provability:
      `Derivable FrameClass.ZTime [] φ` is decidable, by soundness and completeness composed with
      the witness-family validity procedure"*.
- [x] Do **not** type a measured axiom value into the Axioms column. That column is generated from
      the baselines; `pcq pinned:C14` is a claim that Phase 4's baseline line makes true, and the
      page's standing assertion is that every declaration listed is machine-pinned.
- [x] Give the companion `theorem` **no** index row. One row means one C14 pair, which is exactly
      what the gate script's comment pre-authorizes; the `theorem` needs no pin because it has no
      row, and C17 already covers it through the `def` body's reference to it.
- [x] No task-number citation in the row (this file is outside `specs/**`).
- [ ] *Optional, non-blocking*: tick the matching `specs/ROADMAP.md` checkbox with the
      `*(Completed: Task 724, {DATE})*` annotation. `specs/**` is the one place task numbers are
      permitted. Not part of acceptance. *(deviation: skipped — the
      immediately preceding checkbox, for the already-completed task 723, is also still unticked,
      so this repository's roadmap checkboxes are evidently not ticked per-task by the
      implementation dispatch. Ticking only this one would make the two adjacent rows inconsistent.
      Explicitly non-blocking and outside acceptance.)*

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts **exactly one added table row** in the theorem index (plus
at most one optional roadmap checkbox edit). Confirm by `git diff` showing a single added line in
the index's Decidability table and no other hunk in that file.

**Files to modify**:

- `docs/theorem-index.md` - one new row in the `### Decidability` table
- `specs/ROADMAP.md` - optional, non-blocking: tick the matching checkbox with a completion
  annotation

**Verification**:

- Diff read-through: every changed hunk is markdown table/checkbox text, with zero compile or
  elaboration surface. That is precisely the `prose` tier.
- The new row has exactly six pipe-delimited cells, matching the table's header.
- The Lean name is fully qualified and the File cell carries no `:line` suffix.
- `bash scripts/check-module-invariants.sh --no-build` reports PASS for C15 (anchor at the
  declaration) and C17 (the new `def` is referenced by this row, so not dead).
- **Known blind spot of this tier** (deferred to Phase 5): whether the `pinned:C14` claim is
  actually true. It becomes true only when Phase 4's baseline line lands and Phase 5's build-backed
  C14 asserts it. A row claiming `pinned:C14` with no baseline line behind it is exactly the defect
  the preceding task in this series existed to fix — do not reintroduce it.

---

### Phase 4: Append the C14 matched pair and reconcile the adjacent comment [COMPLETED]

**Goal**: The new `def` is machine-pinned by a matched pair of lines in the two C14 heredocs, and
the descriptive comment above them no longer misstates the block's contents.

**Tasks**:

- [x] Append to the `C14_BASELINE` heredoc, as its **new trailing line**, immediately after the
      existing `'FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime' depends on axioms: …`
      line and before the `C14BASE` terminator:

      `'FormalSystem.Metalogic.decidableDerivableZTime' depends on axioms: [propext, Classical.choice, Quot.sound]`

- [x] Append to the `C14LEAN` `#print axioms` heredoc, as its **new trailing line**, immediately
      after the existing `#print axioms FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`
      line and before the `C14LEAN` terminator:

      `#print axioms FormalSystem.Metalogic.decidableDerivableZTime`

- [x] **Positions must match.** The baseline compares concatenated output in emission order, and
      emission order follows the `#print axioms` heredoc's line order, so a pair appended at
      different relative positions in the two heredocs fails even with the right axiom value.
- [x] Reconcile the descriptive comment block immediately above `C14_BASELINE`, which currently
      says "The final **three** lines of this pair pin the witness-family decidability declarations
      that `docs/theorem-index.md` carries rows for" and enumerates three names: update the count to
      four and add `FormalSystem.Metalogic.decidableDerivableZTime` to the enumeration.
- [x] Replace that comment's forward-looking paragraph — "A fourth sibling declaration,
      `Decidable (Derivable FrameClass.ZTime [] φ)` …, is expected to join this trailing block once
      it lands in `FormalSystem/`; pinning it then is a copy of this block's shape" — with a
      statement that it **has** landed, naming the module it lives in. Leaving a stale
      "expected to join" sentence in place beside the line that satisfies it is the same descriptive
      drift the preceding task in this series reconciled.
- [x] No task-number citation in the script (outside `specs/**`).
- [x] Note the ordering dependency: the C14 assertion cannot run until Phase 2 has made the
      declaration reachable from the library root, because the C14 probe file imports the root.
      The *edit* here is independent; the *assertion* lands in Phase 5.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts **exactly two appended lines plus one comment-block
reconciliation, all in one file**, and that the axiom value is
`[propext, Classical.choice, Quot.sound]` — measured by the research probe on both declarations in
the exact proposed namespace and `open` set, before the file existed. Confirm at implementation
time by the Phase 5 build-backed C14 run, which compares the concatenated `#print axioms` output
against the baseline: a value mismatch is a hypothesis failure, not a gate bug, and the fix is to
correct the baseline line to the measured value, never to loosen the check.

**Files to modify**:

- `scripts/check-module-invariants.sh` - one appended baseline line, one appended `#print axioms`
  line, and the adjacent descriptive comment reconciled

**Verification**:

- `bash -n scripts/check-module-invariants.sh` parses cleanly (single-file syntax check — the
  `local` tier's scope for a shell edit with no externally visible interface change).
- `bash scripts/check-module-invariants.sh --no-build` still completes with no new failure: this
  exercises the build-free set (C9, C15, C17, C26, C33, C37) and proves the edit did not break the
  script, while deliberately **not** running C14.
- Both heredocs' new trailing lines sit in the same relative position, verified by reading the two
  tails side by side rather than by line number.
- The comment's count and enumeration match the baseline block's actual contents.
- **Known blind spot of this tier** (deferred to Phase 5): C14 itself. `--no-build` skips it
  entirely, so the appended value is unasserted until the build-backed run.

---

### Phase 5: Full gate run [IN PROGRESS]

**Goal**: The complete gate set is green with every change in place.

**Tasks**:

- [ ] Run `lake build` **detached and guarded** per
      `context/project/lean4/operations/long-builds.md` and
      `context/patterns/bounded-build-waiter.md`: a hard timeout, writer liveness via `kill -0` on
      the captured PID (never `ps | grep` or `pgrep -f`), one waiter per log.
- [ ] On a green build, run `bash scripts/check-module-invariants.sh` with **no** `--no-build`, so
      the build-backed checks (C1, C2, C14, C36b) run alongside the build-free set.
- [ ] Triage any failure by check id. The expected-failure shortlist, in likelihood order: C14
      (value or position mismatch — correct the baseline to the measured value, never loosen the
      check), C33 (import out of sorted position), C15 (missing `Paper:` anchor or missing reason),
      C9 (a task number slipped into a non-`specs/` file), C27 (a live debug artifact outside a
      docstring), C26 (a non-trailing underscore in the `def` name).
- [ ] Confirm acceptance directly, not by inference:
      `grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/` now returns **exactly one**
      declaration hit, in the new module. (It returned zero before; the pre-existing unrestricted
      hits are a documentation row, a gate-script comment, and `specs/` artifacts — none a
      declaration.)
- [ ] Confirm `grep -rn 'TM is decidable' .` surfaces no new unqualified occurrence in this change
      set.
- [ ] Commit per green sub-step throughout, not once at the end.

**Timing**: 1.25 hours (dominated by `lake build`; the incremental rebuild is expected to cover the
new module, the two aggregators, and the aggregator's one-hop dependents)

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the rebuild is **incremental, not from-scratch** — the new
module plus the two aggregators plus the metalogic aggregator's importers — on the strength of the
+2 net-new-import measurement. Confirm by the build log's compiled-module count and wall time
against a no-op `lake build` baseline. A from-scratch-scale rebuild means the import-weight
hypothesis failed; record it and re-check placement before proceeding.

**Files to modify**:

- `FormalSystem/Metalogic/ZTimeProvability.lean` - fixes only, if a gate fails
- `FormalSystem.lean` - fixes only, if C33 fails
- `scripts/check-module-invariants.sh` - fixes only, if C14 fails
- `docs/theorem-index.md` - fixes only, if C15 fails

**Verification**:

- **The complete gate set for this repository**, both halves, named explicitly as the `full` tier
  requires: `lake build` (green, zero errors, zero sorries, no new warnings) **and**
  `bash scripts/check-module-invariants.sh` (the aggregate gate, build-backed, reporting PASS for
  B0–B3 and C1–C37 — in particular C2, C8, C9, C14, C15, C17, C23, C24, C26, C27, C28, C33, C37).
  `.claude/scripts/verify-deploy.sh` is the agent-system deploy gate and is not the gate set for a
  Lean library change; `check-module-invariants.sh` plus `lake build` is. A run that reaches only a
  hand-picked subset of checks does not satisfy this tier.
- Nothing is deferred past this phase. This is the ceiling.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.BXCanonical.Completeness
import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics

theorem derivable_iff_validZTime (φ : Formula) :
    Derivable FrameClass.ZTime [] φ ↔ ValidZTime φ := sorry

def decidableDerivableZTime (φ : Formula) :
    Decidable (Derivable FrameClass.ZTime [] φ) := sorry

end FormalSystem.Metalogic
```

## Testing & Validation

- [ ] `lake build FormalSystem.Metalogic.ZTimeProvability` green: no error, no warning, no sorry.
- [ ] `grep -n 'sorry' FormalSystem/Metalogic/ZTimeProvability.lean` returns nothing.
- [ ] `lake build` green across the repository.
- [ ] `bash scripts/check-module-invariants.sh` (build-backed) reports PASS for the whole check set,
      C14 and C33 included.
- [ ] `bash scripts/check-module-invariants.sh --no-build` green at each intermediate sub-step, as
      the fast feedback loop.
- [ ] `grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/` returns exactly one
      declaration hit, in the new module.
- [ ] The new module's docstring contains all three qualifiers (frame class, no stability operator,
      empty premises), the without-the-spine record, the three durable anchors, `Paper: —` with a
      reason, and the `def`-not-`instance` rationale.
- [ ] The new module contains no task number, no unqualified "TM is decidable", no complexity claim,
      and no live `#check`/`#print`/`#eval` outside a `/-! … -/` block.
- [ ] `docs/theorem-index.md` carries the new row with `pcq pinned:C14`, and the C14 baseline line
      behind that claim exists.

## Artifacts & Outputs

- `FormalSystem/Metalogic/ZTimeProvability.lean` — new module: `derivable_iff_validZTime` and
  `decidableDerivableZTime`
- `FormalSystem.lean` — one sorted import line
- `FormalSystem/Metalogic.lean` — one appended re-export import line
- `docs/theorem-index.md` — one new `### Decidability` row
- `scripts/check-module-invariants.sh` — one C14 matched pair plus the reconciled adjacent comment
- `specs/ROADMAP.md` — optional, non-blocking checkbox tick
- `specs/724_decidable_ztime_provability_witness_family_corollary/summaries/01_…-summary.md` —
  implementation summary

## Rollback/Contingency

Every phase is a small, independently revertible edit, and the Commit-Per-Green-Substep Mandate
keeps each green sub-step its own commit, so the ordinary recovery path is `git revert` of the
offending commit — no working-tree discard is needed and no snapshot is owed.

- **A gate fails in Phase 5**: fix forward. The failure shortlist and its per-check remedy are in
  Phase 5's task list. C14 in particular is fixed by correcting the baseline line to the measured
  value, never by loosening the check or setting an `ENFORCE_*` flag to 0.
- **The build overruns the dispatch**: the task is resumable from Phase 5 with no rework. Phases 1–4
  are committed and the mathematics is already compiled-probe verified, so a timeout costs time,
  not correctness.
- **The placement decision turns out wrong** (a cycle or an unexpected build blow-up that the
  measurement did not predict): revert the Phase 2 commit only. The module itself (Phase 1) stays
  valid and can be re-wired at a different host aggregator; the report's measured net-new-import
  table ranks the alternatives.
- **A genuine working-tree rollback becomes necessary** (uncommitted, half-applied edits that must
  be discarded): take the snapshot first per `context/contracts/recovery.md`'s rollback rung, which
  gives the exact invocation shape including its out-of-scope override flag, then run the
  destructive command. Do not emit a bare precautionary snapshot at the start of a phase; an
  ordinary defensive checkpoint uses the non-reverting mode instead.
