# Implementation Plan: Documentation Anchor Correction

- **Task**: 484 - Documentation anchor correction: `specs/ROADMAP.md` and `FormalSystem/Metalogic/README.md`
- **Status**: COMPLETED
- **Effort**: 6.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/484_documentation_anchor_roadmap_and_metalogic_readme/reports/01_anchor-doc-verification.md
- **Artifacts**: plans/01_anchor-doc-correction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two documents — `specs/ROADMAP.md` and `FormalSystem/Metalogic/README.md` — are the ground truth
against which every downstream README and `docs/` correction pass is realigned. Research confirmed
all nine asserted defects and found three of them materially larger than the task description
states. This plan repairs both anchors with source-verified values, splitting the work into two
parallel territory tracks (one document each) that converge on a single verification gate. The
work is prose and markdown only: no `.lean` declaration, signature, import, or tactic changes.

Definition of done: `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED, and
`bash scripts/readme-lint.sh` is no worse than its recorded 9-missing-README / 5-broken-reference
baseline.

### Research Integration

The research report (`reports/01_anchor-doc-verification.md`) is the sole source of replacement
values; the implementer must not re-derive them from another document. Key findings that reshape
the task description's own account:

- **A3 is larger than described.** The layer table is not merely missing one Dedekind layer: it
  carries three *phantom* rows that are derived theorems, not `Axiom` constructors
  (`temp_k_dist`, `temp_4`, `temp_future`), and is missing *three* layers (7 Z1, 8 Density,
  9 Reynolds Dedekind). Every `Axioms.lean:NN` citation in the table is stale. Ground-truth
  per-constructor line numbers for all 45 constructors are tabulated in report §3.2.
- **A4 has a caveat.** `completeness_dedekind` is genuinely axiom-clean but is *not* in C2's
  baseline (`scripts/check-module-invariants.sh:127-132` lists exactly four theorems). Appending
  it to a paragraph attributed to C2 would make the ROADMAP assert something C2 does not check.
- **B3 is mis-cited.** `Metalogic/README.md:13` does not violate the aggregator convention. The
  real instance is `FormalSystem/Metalogic/BXCanonical/README.md:13`.
- **B4's replacement in the task description is itself wrong.** With `srcDir := "."`, module
  `FormalSystem` resolves to the repository-root `FormalSystem.lean`; the allowlisted pair is
  *both* `FormalSystem.lean` and `FormalSystem/FormalSystem.lean`.
- **B5 is roughly three times larger than listed** (report §4.5 carries the full recomputed
  inventory).
- **Two decisions were escalated** (report §6). Both are resolved in this plan — see
  "Decisions taken" below.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` is the *subject* of this task, not a consultation input. No `roadmap_flag` was
passed, so no roadmap-review/roadmap-update wrapper phases are added; the ROADMAP edits are the
deliverable itself and live in Phases 1-3.

### Decisions taken

**D1 (resolves report §6.1) — `specs/ROADMAP.md:27-31` gets a surgical narrowing.** The task
description designates `:21-46` DO NOT TOUCH, but `:28-29`'s clause "has no theorem anywhere
relating it to semantic validity" is false by `isValid_sound`, and it is the same false claim A1
exists to remove. Adopting research option (b): change only that clause, preserving the item, its
headline intent, the section, and every other line in `:21-46`. This is an **explicit gated
deviation** from the task's DO-NOT-TOUCH instruction and MUST be recorded as such in the
implementation summary, not taken silently.

**D2 (resolves report §6.2) — re-anchor the ROADMAP citation only; do not edit `Axioms.lean`.**
`ROADMAP.md:357` cites `Axioms.lean:55-59`, a module-docstring block that still says 42. Adopting
research option (a): cite `Axioms.lean:571-582` (the `minFrameClass` docstring, which says 45 and
agrees with enumeration) for the count, keeping `:55-59` cited only for the Burgess/Xu/Venema
references. `Axioms.lean:58` and `:84` are handed to the downstream 42-to-45 sweep, which can
consume report §3.2's verified enumeration rather than redo it.

## Goals & Non-Goals

**Goals**:
- Remove the superseded "the `isValid`-to-validity bridge is MISSING" claim from `ROADMAP.md`,
  replacing it with the sound-direction-landed / completeness-direction-open formulation
  transcribed from `Correctness.lean:209-224`.
- Correct the axiom count to 45 and rebuild the layer table as nine layers with per-constructor
  line citations verified against `Axioms.lean`.
- Replace `Metalogic/README.md`'s false axiom-baseline block with a pointer to
  `scripts/check-module-invariants.sh` (C2), so it cannot drift again.
- Replace the false one-structural-sorry inventory with the verified zero, and relocate
  `countermodel_discrete` to `WeakCanonical/GroupModel/CountermodelBase.lean`.
- Correct the Lake root description and refresh the full file/line inventory.
- Leave both scripts' results no worse than their recorded baselines.

**Non-Goals**:
- The downstream 42-to-45 sweep across the ~26 out-of-scope sites listed in report §3.2. Those
  are handed forward, not fixed here.
- Fixing `readme-lint.sh`'s 9 missing READMEs or its 5 pre-existing broken references.
- Any `.lean` change whatsoever, including the stale `Axioms.lean:58` docstring (see D2).
- Rewriting `BXCanonical/README.md` beyond its single line-13 aggregator row.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer trusts a document instead of source, reintroducing a stale figure | H | M | Every phase's Verification bullet names a source-side command (grep against `.lean`, `lean_verify`, or the `live_files` walk). No figure may be copied from another markdown file. |
| D1's edit inside the DO-NOT-TOUCH block is taken silently and reads as scope creep | M | M | D1 is a pre-declared, single-clause deviation; the summary must flag it explicitly with the before/after text. |
| New file references in `Metalogic/README.md` break `readme-lint.sh` Check 3, adding a sixth broken reference | M | M | Paths such as `WeakCanonical/GroupModel/CountermodelBase.lean` must be written relative to the README's own directory; Phase 4 and 6 re-run `readme-lint.sh` and compare against the 9/5 baseline. |
| A module-shaped path written into `Metalogic/README.md` does not resolve, failing C5 | H | L | C5 covers non-specs markdown, so it catches this; Phases 4-6 carry a `full` tier and run `check-module-invariants.sh`. |
| A task-number citation leaks into `FormalSystem/Metalogic/README.md`, failing C9 | H | L | C9 currently passes. `specs/ROADMAP.md` is exempt and already uses task numbers heavily; the README rewrite must contain none. Phase 7 confirms C9. |
| "axiom-free" phrasing is used instead of the house formulation | M | L | House phrasing is verbatim from `FormalSystem/Metalogic.lean:48`: `SORRY-FREE (sorryAx-free; axioms: exactly propext, Classical.choice, Quot.sound)`. |
| The rebuilt layer table sums to 45 for the wrong reasons (phantoms retained, layers added) | H | M | Phase 2's verification requires per-layer counts to sum to 45 *and* every cited line to land on a constructor in `inductive Axiom`. |
| Parallel tracks collide on a shared file | M | L | Territory split: Phases 1-3 own `specs/ROADMAP.md` only; Phases 4-6 own `FormalSystem/Metalogic/README.md` plus one row of `BXCanonical/README.md`. Within a track, phases are sequential. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2, 5 | 1; 4 |
| 3 | 3, 6 | 2; 5 |
| 4 | 7 | 3, 6 |

Phases within the same wave can execute in parallel. The two tracks are
`specs/ROADMAP.md` (Phases 1-3) and `FormalSystem/Metalogic/README.md` (Phases 4-6); within a
track phases are sequential because they edit the same file.

---

### Phase 1: ROADMAP A1 — the isValid bridge [COMPLETED]

**Goal**: Replace the superseded "bridge is MISSING" claim at `specs/ROADMAP.md:109-115` with the
sound-landed / completeness-open formulation, fix the stale sub-citation, and apply decision D1.

**Tasks**:
- [x] Read `FormalSystem/Metalogic/Decidability/Correctness.lean:209-224` and transcribe its
      open-obligation formulation rather than re-phrasing it. Its content: the completeness
      direction `⊨ φ → isValid φ fc = true`, hence the biconditional and the four
      `Decidable (⊨ φ)` instances, requires `valid_iff_allClosed`, which needs the
      fuel/termination side and the truth-lemma gate on top of `ruleSound_of_mem_allRulesForFC`
      (`Verified/Decidable.lean:3155`), and must additionally account for `serialityRule` and
      `timeLinearity`, the two rules scheduled outside `allRulesForFC`.
- [x] Rewrite `:109-115` to record that the SOUND direction is landed, citing
      `Correctness.lean:100` (`sound_of_isValid`) and `:111` (`isValid_sound`), and that the
      completeness direction remains open.
- [x] Fix the stale sub-citation in the same bullet: `decide_sound'` is at `Correctness.lean:71`,
      not `:66`.
- [x] Apply **D1**: narrow the clause at `:28-29` only. Replace "has no theorem anywhere relating
      it to semantic validity" with a formulation in which the sound direction is proved
      (`isValid_sound`) while the biconditional — the property the name `isValid` invites a reader
      to assume — is absent, so no declaration states it and C3's sorry count is silent on it.
      Leave the bullet, its headline, the section, and all other lines in `:21-46` untouched.
- [x] Record D1 in the phase's commit message body as a pre-declared gated deviation.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: this phase asserts that `sound_of_isValid` is at `Correctness.lean:100`,
`isValid_sound` at `:111`, and `decide_sound'` at `:71`. Confirm each at implementation time with
`grep -n 'theorem sound_of_isValid\|theorem isValid_sound\|decide_sound.\{0,1\}' FormalSystem/Metalogic/Decidability/Correctness.lean`
before writing any line number into the ROADMAP; use the observed numbers, not these.

**Files to modify**:
- `specs/ROADMAP.md` - rewrite `:109-115`; narrow one clause at `:28-29`

**Verification**:
- Every claim in the rewritten bullet greps clean against `Correctness.lean` (the two theorem
  sites and `decide_sound'`).
- Diff confirms `:21-46` shows exactly one changed hunk, inside `:27-31`, and nothing else in
  that range moved.
- The rewritten text contains no "axiom-free" phrasing and no assertion that the biconditional
  exists.

---

### Phase 2: ROADMAP A2/A3 — 45 constructors, nine layers [COMPLETED]

**Goal**: Correct the headline count at `:15` and `:354-357` to 45, rebuild the layer table
(`:363-443`) as nine layers with verified per-constructor line citations, and apply decision D2.

**Tasks**:
- [x] Re-enumerate `inductive Axiom` (`FormalSystem/ProofSystem/Axioms.lean:99-517`;
      `inductive FrameClass` begins at `:519`) and confirm the constructor count and each
      constructor's line, using report §3.2's table as the hypothesis to check, not as input.
- [x] Update `:15` and the `## BX Axiom System` intro (`:354-357`) to "45 axiom constructors in
      nine layers".
- [x] Apply **D2**: re-anchor the count citation at `:357` from `Axioms.lean:55-59` to *(deviation: altered — source check showed the Burgess/Xu/Venema references are at `Axioms.lean:72-74`, not `:55-59`, and Reynolds 1992 is cited at `:426`/`:437`/`:449`, not `:309`; the observed values were used)*
      `Axioms.lean:571-582` (the `minFrameClass` docstring). Keep `:55-59` cited only for the
      Burgess/Xu/Venema references.
- [x] Delete the three phantom rows, which are derived theorems and not `Axiom` constructors:
      `temp_k_dist` (`:386`), `temp_4` (`:387`), `temp_future` (`:421`). Note in the table's
      surrounding prose that these are derived, so a future reader does not re-add them.
- [x] Correct the existing layer headings and membership to: Layer 1 Propositional (4),
      Layer 2 S5 Modal (5), Layer 3 BX Temporal (18), Layer 3b Additional BX Temporal (4),
      Layer 4 Modal-Temporal Interaction (1), Layer 5 Uniformity (5), Layer 6 Prior for
      Integers (2).
- [x] Add the three absent layers: Layer 7 Z1 (1: `z1`), Layer 8 Density (2: `density`,
      `dense_indicator`), Layer 9 Reynolds Dedekind (3: `prior_U_gap`, `prior_S_gap`, `sep`),
      with their `minFrameClass` values `.Discrete`, `.Dense`, `.Dedekind`.
- [x] Refresh every `Axioms.lean:NN` citation in the table from the confirmed enumeration.
- [x] Do NOT trust the in-source `-- Layer N` comments: `:123` says Layer 3 is 20 (it is 18) and
      `:349` says Layer 8 is 1 (it is 2). Only enumeration is authoritative.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: this phase asserts 45 constructors partitioned 4/5/18/4/1/5/2/1/2/3 across
nine layers, and an enumerated line number for each. Confirm at implementation time by
re-enumerating `inductive Axiom` directly (constructor lines between `Axioms.lean:99` and the
`inductive FrameClass` start) and checking the per-layer sum equals the enumerated total before
any figure is written. If the re-enumeration disagrees with report §3.2, the source wins and the
divergence must be recorded in the summary.

**Files to modify**:
- `specs/ROADMAP.md` - `:15`, `:354-357`, layer table `:363-443`

**Verification**:
- Per-layer counts sum to the enumerated constructor total (expected 45).
- Every `Axioms.lean:NN` citation in the rebuilt table lands on a constructor line in
  `inductive Axiom` — spot-check each layer's first and last entry with `sed -n 'NNp'`.
- `grep -n '42' specs/ROADMAP.md` shows no surviving axiom-count occurrence of 42.
- No row names `temp_k_dist`, `temp_4`, or `temp_future` as a constructor.

---

### Phase 3: ROADMAP A4 — completeness_dedekind [COMPLETED]

**Goal**: Record `completeness_dedekind`'s axiom profile at `:348-350` without misattributing it
to the C2 baseline.

**Tasks**:
- [x] Run `lean_verify` on `FormalSystem.Metalogic.completeness_dedekind`
      (`FormalSystem/Metalogic/StrongCompleteness.lean:469`) and confirm the axiom set is exactly
      `[propext, Classical.choice, Quot.sound]`.
- [x] Confirm C2's baseline list at `scripts/check-module-invariants.sh:127-132` contains exactly
      four theorems: `completeness`, `completeness_dense`, `completeness_discrete`,
      `Chronicle.countermodel_dense`.
- [x] Add `completeness_dedekind` to `:348-350` **typographically separate** from the C2 four,
      attributed to `FormalSystem/Metalogic.lean:57-60` and a `#print axioms` run — never to C2.
      The ROADMAP must not assert that C2 checks something it does not.
- [x] Note that the task description's cited range `:349-352` is off by one at the top; the block
      is `:348-350`.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: this phase asserts C2's baseline is exactly four theorems and
`completeness_dedekind` is not among them. Confirm at implementation time by reading
`scripts/check-module-invariants.sh` around the C2 baseline definition and counting the listed
theorems directly.

**Files to modify**:
- `specs/ROADMAP.md` - `:348-350`

**Verification**:
- `lean_verify` output for `FormalSystem.Metalogic.completeness_dedekind` matches the recorded set.
- The paragraph's C2 attribution still covers exactly the four theorems the script checks, with
  `completeness_dedekind` visibly outside that attribution.

---

### Phase 4: README B1 + B2 — the two actively-harmful defects [COMPLETED]

**Goal**: Replace the false axiom-baseline block with a C2 pointer, and replace the false
one-structural-sorry inventory with the verified zero and the current theorem location.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh` and capture C2's live output and C3's
      structural-sorry count as the transcription source.
- [x] Replace `FormalSystem/Metalogic/README.md:213-218` with a pointer to
      `scripts/check-module-invariants.sh` and the check name **C2** — cite the script path and
      check name, never a line number, so the pointer cannot itself drift. Do not re-type the
      four theorems' axiom sets into the README.
- [x] Leave `:220-222` ("a hard stop, not a new baseline") in place; it reads correctly against a
      pointer.
- [x] Rewrite `:233-248` to record ZERO structural sorries across `FormalSystem/`
      (`Boneyard/` excluded), per C3.
- [x] Relocate `theorem countermodel_discrete` to
      `WeakCanonical/GroupModel/CountermodelBase.lean:142` (write the path relative to the
      README's own directory) and record it as axiom-clean.
- [x] Note that `WeakCanonical/Transfer.lean:25-31` now documents the move, and that its remaining
      `sorry` occurrences (`:542`, `:622`, `:628`, `:718`, `:725`) are all inside prose describing
      sorry-*freeness*, not structural sorries.
- [x] Delete `:239-242` entirely ("This is why `completeness` depends on `sorryAx` ...") — it
      explains a dependency that does not exist.
- [x] KEEP the "locate by content, not line number" guidance at `:244-246` and the archived-dead-
      ends sentence at `:248`.
- [x] Use the house phrasing verbatim from `FormalSystem/Metalogic.lean:48`:
      `SORRY-FREE (sorryAx-free; axioms: exactly propext, Classical.choice, Quot.sound)`.
      Never write "axiom-free".
- [x] Transcribe the corrected discrete-branch statement from `FormalSystem/Metalogic.lean:48-52`
      rather than re-phrasing it.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts C3 reports zero structural sorries and that
`countermodel_discrete` is at `WeakCanonical/GroupModel/CountermodelBase.lean:142`. Confirm both
at implementation time — C3 from a live `check-module-invariants.sh` run, the theorem location
with `grep -n 'theorem countermodel_discrete' -r FormalSystem/Metalogic/WeakCanonical/`.

**Files to modify**:
- `FormalSystem/Metalogic/README.md` - `:213-218` (pointer), `:233-248` (sorry inventory rewrite)

**Verification**:
- `bash scripts/check-module-invariants.sh` — C2 and C3 both PASS; overall ALL CHECKS PASSED.
- `bash scripts/readme-lint.sh` — no worse than the 9-missing / 5-broken baseline (the new
  `CountermodelBase.lean` reference must resolve relative to the README's directory).
- `grep -n 'sorryAx' FormalSystem/Metalogic/README.md` shows no surviving claim that
  `completeness` depends on it.
- `grep -n 'axiom-free' FormalSystem/Metalogic/README.md` returns nothing.

---

### Phase 5: README B4 (Lake root) + B3 (aggregator row) [COMPLETED]

**Goal**: Correct the Lake root paragraph by transcription from C8's own comment, and fix the one
genuine aggregator-convention violation.

**Tasks**:
- [x] Confirm ground truth at `lakefile.lean:15-19`: `lean_lib FormalSystem where srcDir := "."`,
      ``roots := #[`FormalSystem]``. Confirm `FormalSystem/Bimodal.lean` does not exist.
- [x] Rewrite `FormalSystem/Metalogic/README.md:147-150` by transcribing C8's own comment at
      `scripts/check-module-invariants.sh:402-407`: the allowlisted exception is the pair
      `FormalSystem.lean` + `FormalSystem/FormalSystem.lean`, which is the Lake `lean_lib
      FormalSystem` root, so the self-named indirection is load-bearing, not a convention
      violation.
- [x] Do NOT write "the real root is `FormalSystem/FormalSystem.lean`" — the task description's
      own replacement is wrong. With `srcDir := "."`, module `FormalSystem` resolves to the
      repository-root `FormalSystem.lean` (50 lines), which imports
      `FormalSystem.FormalSystem` at `FormalSystem.lean:8`. The allowlisted pair is both files.
- [x] Keep the README's existing "allowlists it by name" phrasing — it is accurate against
      `C8_ALLOW_SELFNAMED = {"FormalSystem/FormalSystem.lean"}`.
- [x] Fix the single row at `FormalSystem/Metalogic/BXCanonical/README.md:13`: `BXCanonical.lean`
      is a **sibling** at `FormalSystem/Metalogic/BXCanonical.lean`, not a file inside
      `BXCanonical/`, and it is 43 lines, not 28. Change that row only; leave the rest of
      `BXCanonical/README.md` to the downstream README pass.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts `FormalSystem/Metalogic/BXCanonical.lean` is 43 lines and
the repository-root `FormalSystem.lean` is 50. Confirm both with `wc -l` at implementation time
and use the observed values.

**Files to modify**:
- `FormalSystem/Metalogic/README.md` - `:147-150`
- `FormalSystem/Metalogic/BXCanonical/README.md` - line 13 row only

**Verification**:
- `bash scripts/check-module-invariants.sh` — C8 still PASSES.
- `grep -n 'Bimodal' FormalSystem/Metalogic/README.md` shows no surviving reference to a
  nonexistent `FormalSystem/Bimodal.lean`.
- `wc -l FormalSystem/Metalogic/BXCanonical.lean` matches the number written into the row.

---

### Phase 6: README B5 — the inventory sweep [COMPLETED]

**Goal**: Refresh every stale file/line count in `FormalSystem/Metalogic/README.md`, add the
missing directories and subdirectories, and add the "Last verified" line.

**Tasks**:
- [x] Recompute all counts with the script's own `live_files` walk
      (`scripts/check-module-invariants.sh:212-219`, `Boneyard/` pruned). Use report §4.5's table
      as the hypothesis to check, not as input.
- [x] Update `:6-7` (live `.lean` file totals and the `WeakCanonical/` share).
- [x] Update the Directory Inventory (`:154-162`) and Three Completeness Routes (`:29-33`) tables,
      and ADD the missing `Independence/` directory to both.
- [x] Update the aggregator table (`:124-132`) — every line count is stale — and add
      `Independence.lean`.
- [x] Correct `:134-136`: there are five loose non-aggregators, not two —
      `Soundness.lean`, `StrongCompleteness.lean`, `SetConsequence.lean`,
      `DiscreteNonCompactness.lean`, `Conservativity.lean` — plus `Metalogic.lean` itself.
- [x] Correct `:166-168` (Inside `BXCanonical/`): the loose list omits `CompletenessDedekind.lean`
      and `DiscreteCarrierProbe.lean`; refresh the `Chronicle/`, `Quasimodel/`, `Filtration/`
      counts.
- [x] Correct `:172` and the subdirectory table `:175-181` (Inside `WeakCanonical/`): refresh the
      loose-module and subdirectory counts, and ADD the three omitted subdirectories
      `DenseModelSurgery/`, `GroupModel/`, `RealModel/`. `GroupModel/`'s absence is not cosmetic —
      Phase 4's corrected sorry text names a file in a directory this README currently claims
      does not exist.
- [x] Correct `:183-190` (under `Kamp/`): refresh the loose-module count, add the third
      sub-subtree `EANegationFixFaithful/`, and refresh `NfMultiAnchorBridge/` and
      `EANegationFix/`.
- [x] Add a "Last verified" line in house format, e.g. `FormalSystem/README.md:311`:
      `*Last verified: YYYY-MM-DD*`.
- [x] Ensure every new relative file reference resolves from the README's own directory
      (`readme-lint.sh` Check 3) and contains no task-number citation (C9).

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase asserts a large set of per-directory file and line counts
(report §4.5). Every one is a hypothesis. Confirm at implementation time by re-running the
`live_files` walk over each directory and comparing against C7's live totals before writing any
figure; where the walk disagrees with the report, the walk wins and the divergence is recorded in
the summary.

**Files to modify**:
- `FormalSystem/Metalogic/README.md` - `:6-7`, `:29-33`, `:124-136`, `:152-191`, plus a new
  "Last verified" line

**Verification**:
- Every figure written traces to a `live_files` walk run in this phase, not to another document.
- `bash scripts/readme-lint.sh` — Check 4 no longer flags this README for a missing
  "Last verified" date; overall result no worse than the 9/5 baseline.
- `bash scripts/check-module-invariants.sh` — C5 (module paths resolve), C7 (directory rollup),
  and C9 (no task-number citations) all PASS.

---

### Phase 7: Verification gate [COMPLETED]

**Goal**: Confirm both anchors are internally consistent and neither script regressed.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh` and confirm **ALL CHECKS PASSED** (exit 0),
      with C5, C7, C8, and C9 individually PASS.
- [x] Run `bash scripts/readme-lint.sh`, record the full result, and confirm it is no worse than
      the recorded baseline of 9 missing READMEs / 5 broken references.
- [x] Confirm `git diff --stat` touches only `specs/ROADMAP.md`,
      `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/BXCanonical/README.md`, and the
      task's own `specs/484_*/` artifacts. No `.lean` file may appear.
- [x] Re-read the D1 hunk and confirm the diff inside `ROADMAP.md:21-46` is the single
      pre-declared clause change and nothing else.
- [x] Record in the summary: the D1 gated deviation with before/after text; the D2 handoff of
      `Axioms.lean:58` and `:84` to the downstream sweep, with report §3.2's verified enumeration
      and out-of-scope site list as its input; and any figure where implementation-time
      re-verification diverged from the research report.

**Timing**: 0.75 hours

**Depends on**: 3, 6

**Verification Tier**: full

**Files to modify**:
- None (gate only; summary artifact is written by postflight)

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 with ALL CHECKS PASSED.
- `bash scripts/readme-lint.sh` result recorded and not regressed.
- `git diff --name-only` contains no `.lean` path.

---

## Testing & Validation

- [x] `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED (exit 0).
- [x] `bash scripts/readme-lint.sh` result recorded; no worse than 9 missing READMEs /
      5 broken references.
- [x] `lean_verify FormalSystem.Metalogic.completeness_dedekind` returns
      `[propext, Classical.choice, Quot.sound]`.
- [x] No `.lean` file appears in `git diff --name-only`.
- [x] `grep -n 'axiom-free' FormalSystem/Metalogic/README.md specs/ROADMAP.md` returns nothing.
- [x] The ROADMAP layer table's per-layer counts sum to the enumerated `inductive Axiom` total.
- [x] `FormalSystem/Metalogic/README.md` contains no task-number citation (C9).

## Artifacts & Outputs

- `specs/ROADMAP.md` (corrected: A1 + D1, A2/A3 + D2, A4)
- `FormalSystem/Metalogic/README.md` (corrected: B1, B2, B4, B5, plus "Last verified")
- `FormalSystem/Metalogic/BXCanonical/README.md` (one row corrected: B3)
- `specs/484_documentation_anchor_roadmap_and_metalogic_readme/summaries/01_anchor-doc-correction-summary.md`
- A handoff note in the summary carrying report §3.2's verified 45-constructor enumeration and
  out-of-scope site list forward to the downstream 42-to-45 sweep.

## Rollback/Contingency

All changes are confined to three markdown files. If either script regresses and the cause is not
immediately clear, revert the offending phase's commit with `git revert` — phases commit
independently (Phase 6 as a single atomic batch), so a single phase can be backed out without
disturbing the other track. Because Phases 1-3 and 4-6 touch disjoint files, reverting one track
never invalidates the other. If the D1 deviation is rejected on review, revert only Phase 1's
`:27-31` hunk; the `:109-115` rewrite stands independently.
