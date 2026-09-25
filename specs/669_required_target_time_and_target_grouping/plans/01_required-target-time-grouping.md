# Implementation Plan: Required Target Time and Target Grouping

- **Task**: 669 - Make the witness-family certificate's target time a required field and group the target condition to mirror the Lean structure.
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/669_required_target_time_and_target_grouping/reports/01_required-target-time-grouping.md
- **Artifacts**: plans/01_required-target-time-grouping.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

One wire-format revision to `lake exe check_certificate`, made in a single pass: `"time"` stops
being an optional field defaulting to `0` and becomes required, and `premises`/`conclusions`/`time`
are grouped under one `"target"` object mirroring `WitnessFamily.Target`'s three data. Required-ness
is expressed by a parse-time partial record (`time : Option Int := none`) that `complete`s into the
wire record through `Except String`, so an absent field lands on `checkLine`'s existing `.error`
path and renders `{"status":"error",...}` rather than a verdict. The change is data-shape plumbing
plus documentation: no proof obligation, no new axiom, no `CheckResult` constructor. Done means the
two example families still produce their existing verdicts through the new shape, an omitted
`"time"` answers `error`, and every repository gate is green.

### Research Integration

The research report verified the design by compiling a full end-to-end spike (`lake env lean`,
exit 0, zero output, 12 passing `#guard` rows) rather than proposing it. Three findings steer this
plan directly:

- **The only genuine technical risk is closed.** `mkFamily`'s dependent return type
  `Except StructuralFault (WitnessFamily raw.premises raw.conclusions)` becomes
  `... (WitnessFamily raw.target.premises raw.target.conclusions)`, and the test rows'
  `fun W : WitnessFamily gammaPos delPos` annotation still unifies through the extra projection.
  Confirmed by passing spike rows, so this plan does not hedge against it.
- **`pObjectFields` cannot be the required-field seam.** It folds a handler over an accumulator
  seeded with `{}`, which is ill-formed once a field loses its default. Hence the partial records.
- **Scope is two files wider than the dispatch states.** `BimodalTools/CheckCertificateMain.lean`'s
  `## Usage` block and `lakefile.toml`'s `# Run with:` comment both print the flat shape; after this
  change both would be *rejected as protocol errors* if copy-pasted, which is worse than stale. Both
  are one line each and are treated as in scope.

One deliberate asymmetry, carried from the report into Phase 2's docstring: `premises` and
`conclusions` keep `:= []` while only `time` becomes required. `[]` is the identity of a context and
an absent premise list has an unambiguous correct reading; `0` is not the identity of a time.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch.

## Goals & Non-Goals

**Goals**:

- `"time"` is a required field of a required `"target"` object; its absence yields
  `{"status":"error","message":...}`, never `{"status":"rejected"}`.
- The wire envelope is `{"target":{"premises":[...],"conclusions":[...],"time":t},"bx":[...],"lassos":[...]}`,
  and `RawCertificate` nests a real `RawTarget` field rather than faking structure in the serializer.
- `parseCertificate ∘ RawCertificate.toJson` remains the identity on base-atom certificates.
- The two example families keep their exact verdicts: non-vacuity `{"status":"countermodel","time":0}`;
  separation rejected at condition `fulfilling`, lasso `0`, position `-2`, formula `p U q`.
- `BimodalTools/README.md`'s protocol section states the final shape completely enough that
  ModelChecker's exporter can be written against it without reading any Lean.
- Zero sorries, zero new axioms, zero warnings under `--wfail`, all invariant gates green.

**Non-Goals**:

- Changing the **output** shape. `{"status":"countermodel","time":t}` keeps echoing the time flat;
  nothing in this change pressures that.
- Making `premises` or `conclusions` required. Only `time` loses its default.
- Adding a `CheckResult` constructor or any new rejection path. Protocol failures already route
  through `parseCertificate`'s `Except String`.
- Writing the ModelChecker-side exporter. This task fixes the interface it must mirror; it does not
  implement it.
- Any change under `FormalSystem/**`. The Lean structures are the model being mirrored, not a target.

**No `## Lean Challenge Statements` section is present.** That section pins the literal signature of
each theorem a lean plan commits to, and its identifier set must equal the identifier set named
under `- **Goals**:`. This plan commits to no theorem: every new declaration is a structure, a
parser, a serializer or an `Except`-valued conversion, and the `- **Goals**:` bullets above name no
theorem identifiers. An empty or placeholder block would assert a commitment that does not exist.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A missing `"time"` is reported as `rejected` rather than `error` — the acceptance criterion itself | H | L | Route the failure through `parseCertificate`'s existing `Except String`; pin it with a `#guard` asserting on the **rendered JSON prefix** `{"status":"error"` via `checkLineToJson`, not on an internal constructor |
| `mkFamily`'s dependent return type stops unifying with the test rows' `WitnessFamily gammaPos delPos` annotation | H | L | Closed by the research spike (both `mkFamily` rows passed). If it regresses, the failure is a `#guard` error in Phase 1, before any commit |
| `pObjectFields`' `{}` seed breaks once `time` loses its default | M | H (by construction) | Designed around: parse into `PartialTarget`/`PartialCertificate`, `complete` into the real records |
| README inventory blocks go stale on line count, so `check-module-invariants.sh` does not print ALL CHECKS PASSED | L | H (certain) | `bash scripts/check-module-invariants.sh --emit-inventory` as Phase 3's first step, after the Lean edits are final — doing it earlier just means doing it twice |
| Stale flat examples left in `CheckCertificateMain.lean` and `lakefile.toml` | M | M | In scope, Phase 2. An example that is now a protocol *error* is worse than merely stale, and the cross-repo note makes the exporter author a likely reader of exactly those lines |
| The README sentence "only unparseable input is `error`" becomes false (a missing required field is also `error`) | M | H | Phase 2 rewrites that sentence explicitly rather than leaving the error/rejected boundary self-contradictory |
| An intermediate per-hunk state of Phase 1 is committed while `BimodalToolsTest` is red | M | M | Phase 1 is declared `atomic-batch` over its two files; no commit until both lake targets are green |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phase 2's
docstring edit lands in the same file Phase 1 rewrites, and Phase 3's inventory regeneration is only
correct once every line-count-changing edit is final.

---

### Phase 1: Reshape the wire records and the parse/serialize seam [NOT STARTED]

**Goal**: `RawCertificate` nests a `RawTarget` whose `time` has no default; parsing goes through
partial records that `complete` into it via `Except String`; every downstream reader is re-projected;
the test rows are reshaped and the optionality row is inverted. Both lake targets green at the end.

**Tasks**:

- [ ] In `BimodalTools/CertificateImport.lean`, replace the flat `RawCertificate` (currently
      `premises`, `conclusions`, `bx`, `lassos`, `time : Int := 0`) with two records:
      `RawTarget` (`premises : List Formula := []`, `conclusions : List Formula := []`,
      `time : Int` — **no default**) and `RawCertificate` (`target : RawTarget` — no default —
      plus `bx`, `lassos` unchanged). Keep `deriving Repr, Inhabited, DecidableEq` on both;
      `deriving` uses field types, not field defaults, so `Inhabited` still synthesizes.
- [ ] Add the parse-time seam: `PartialTarget` (same fields, `time : Option Int := none`) and
      `PartialCertificate` (`target : Option PartialTarget := none`, `bx`, `lassos`), each with
      `deriving Repr, Inhabited, DecidableEq`.
- [ ] Add `PartialTarget.complete : PartialTarget → Except String RawTarget` and
      `PartialCertificate.complete : PartialCertificate → Except String RawCertificate`, with two
      **distinct** messages — a producer that omitted the whole `"target"` object and one that
      omitted only its `"time"` have made different mistakes, and the distinction costs nothing.
- [ ] Split the envelope parser: a new `pRawTarget` (a `pObjectFields` fold over `PartialTarget`,
      `"time"` writing `some v`) and a rewritten `pRawCertificate` producing `PartialCertificate`
      with a `"target"` key dispatching to `pRawTarget`. `pExpect` already skips leading whitespace,
      so the nested call needs no extra whitespace handling at the `:` boundary; `pSkipValue` keeps
      unknown-field tolerance at **both** nesting levels for free.
- [ ] Keep `parseCertificate`'s name and type `Except String RawCertificate`, now ending in a
      `complete` call. `checkLine` is untouched, so the `{"status":"error"}` routing is inherited
      rather than rebuilt — do not add a `CheckResult` constructor.
- [ ] Split the serializer into `RawTarget.toJson` and `RawCertificate.toJson`, emitting
      `{"target":{"premises":...,"conclusions":...,"time":...},"bx":...,"lassos":...}`.
- [ ] Re-project the three downstream readers, with no logic change: `RawCertificate.formulas`
      (`c.target.premises ++ c.target.conclusions ++ ...`); `mkFamily`'s return type **and** its
      `closureOf (raw.target.premises ++ raw.target.conclusions)` argument; `checkRaw`'s three
      `raw.time` uses (the `decidableTarget` call, the `targetFailure` scan, and
      `.countermodel raw.time`) to `raw.target.time`.
- [ ] Update the two stale field docstrings carried over from the flat record: the
      `/-- The target time. Optional on the wire, defaulting to `0`. -/` field comment and
      `pRawCertificate`'s `/-- ... `"time"` may be absent, in which case it reads as `0`. -/`.
- [ ] In `Tests/BimodalToolsTest/CertificateImportTest.lean`, reshape the certificate literals:
      `posRaw` and `sepRaw` gain `target := { premises := ..., conclusions := ..., time := 0 }`;
      the `{ sepRaw with premises := [Formula.atom ⟨"p", some 3⟩] }` row becomes
      `{ sepRaw with target := { sepRaw.target with premises := ... } }`.
- [ ] Reshape every wire-literal row to the nested envelope, and **extend** the unknown-field row to
      also carry an unknown field *inside* the `"target"` object — new surface the nesting creates.
- [ ] **Invert**, do not merely edit, the row commented `` -- `"time"` is optional on the wire and
      defaults to `0`. ``: that comment now states the contract falsely. Replace it with a row
      asserting the same input is an error.
- [ ] Add the two acceptance rows, asserting on the rendered JSON prefix so they speak the
      acceptance criterion's own vocabulary:
      `#guard (checkLineToJson "{\"target\":{\"premises\":[],\"conclusions\":[]},\"lassos\":[]}").startsWith "{\"status\":\"error\""`
      and `#guard (checkLineToJson "{\"bx\":[],\"lassos\":[]}").startsWith "{\"status\":\"error\""`.
      (`checkLineToJson` is already public in `CertificateImport.lean` and needs no export change.)

**Timing**: 1.75 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: The declared file set is exactly two files —
`BimodalTools/CertificateImport.lean` and `Tests/BimodalToolsTest/CertificateImportTest.lean` — and
the test file carries **20** rows matching `^#guard` as of planning (the research report says 21;
the discrepancy is a line-continuation counting difference, not a disagreement about the file).
Confirm both before editing: `grep -c '^#guard' Tests/BimodalToolsTest/CertificateImportTest.lean`,
and `grep -rn 'raw\.time\|c\.premises\|raw\.premises\|\.conclusions' BimodalTools/CertificateImport.lean`
to confirm the three re-projection sites are the only ones. If a third file turns out to reference
the flat fields, widen the batch **before** starting, never retroactively.

**Files to modify**:

- `BimodalTools/CertificateImport.lean` - record split, partial records + `complete`, nested parser,
  split serializer, three re-projected readers, two corrected field docstrings
- `Tests/BimodalToolsTest/CertificateImportTest.lean` - nested literals, inverted optionality row,
  extended unknown-field row, two new acceptance rows

**Verification**:

- `lake build BimodalTools --wfail` exits 0 with no warnings
- `lake build BimodalToolsTest --wfail` exits 0 with no warnings (a failing `#guard` is an error, so
  a green build **is** the row-by-row assertion)
- `echo '{"target":{"premises":[],"conclusions":[]},"lassos":[]}' | lake exe check_certificate`
  prints a line beginning `{"status":"error"` — not `"rejected"`
- Intermediate per-file states are expected red and MUST NOT be committed; one commit when both
  targets are green

---

### Phase 2: Record the rationale and the interface in prose [NOT STARTED]

**Goal**: Every place that describes or demonstrates the wire format shows the new shape, states
plainly that `"target"` and `"target"."time"` are required and that their absence is `error`, and
records **why** the time is witnessed rather than defaulted.

**Tasks**:

- [ ] Extend `CertificateImport.lean`'s module docstring with the rationale, in two strands:
      (a) `Target Γ Δ` is an existential ("some `t` with `Γ ⊆ L₀ t` and `Δ ∩ L₀ t = ∅`") whose
      witness is `t`; every other existential in the certificate is explicitly witnessed — the box
      guess witnesses which boxes are false, the lassos witness the falsifying histories, the labels
      witness the types — so a defaulted `t` left the **outermost** existential the only unwitnessed
      one, against the whole point of a certificate, which is that checking requires no search.
      (b) `0` denotes the origin only by `LabelledLasso`'s three-segment decoding convention; a
      re-indexing (branching families with shared states; the compression half of the quasimodel
      route) would silently change the meaning of every stored certificate relying on the default.
- [ ] In the same docstring, state the `premises`/`conclusions` vs. `time` asymmetry and its reason
      (`[]` is the identity of a context; `0` is not the identity of a time), so a later reader does
      not "tidy" it in either direction.
- [ ] Add `RawTarget`, `PartialTarget`, `PartialCertificate` and the `complete` pair to the
      docstring's `## Main Definitions` list.
- [ ] In `BimodalTools/README.md`'s "Certificate re-verification protocol" section, rewrite the
      **input JSON block** to the nested shape.
- [ ] In the same section's field table, replace the flat `premises`/`conclusions`/`time` rows with a
      `target` row plus indented `target.premises` / `target.conclusions` / `target.time` rows.
      **Delete** the `` | `time` | **optional**, default `0` ... | `` note and state required-ness in
      its place.
- [ ] Fix the now-false boundary sentence "A structural violation ... is `rejected`; only
      unparseable input is `error`": a *missing required field* is also `error`. State both classes
      explicitly, and add the cross-repo sentence — a certificate lacking `"target"` or
      `"target"."time"` is answered `{"status":"error"}` — so ModelChecker's exporter can be written
      against the section without reading the Lean.
- [ ] Update `BimodalTools/CheckCertificateMain.lean`'s `## Usage` example (currently the flat shape
      *with* `"time"`) to the nested shape.
- [ ] Update `lakefile.toml`'s `# Run with:` comment above the `check_certificate` `[[lean_exe]]`
      block (currently the flat shape *without* `"time"`, which this change turns from stale into an
      example that would be rejected).

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Four documentation sites are asserted: the `CertificateImport.lean` module
docstring, the `BimodalTools/README.md` protocol section, `CheckCertificateMain.lean`'s `## Usage`
block, and `lakefile.toml`'s `# Run with:` comment. The research census found **no** schema
documentation under `docs/` or `typst/`. Re-confirm before closing the phase with
`grep -rn 'premises' --include='*.md' --include='*.toml' --include='*.lean' . | grep -v specs/ | grep -v .claude/`;
any additional hit showing the flat wire shape joins this phase rather than being deferred.

**Files to modify**:

- `BimodalTools/CertificateImport.lean` - module docstring rationale, asymmetry note,
  `## Main Definitions` additions
- `BimodalTools/README.md` - protocol section: input block, field table, required-field statement,
  corrected error/rejected boundary sentence, cross-repo exporter sentence
- `BimodalTools/CheckCertificateMain.lean` - `## Usage` example
- `lakefile.toml` - `# Run with:` comment

**Verification**:

- `lake build BimodalTools --wfail` exits 0 (Lean doc comments are parsed, so this is a real check,
  not a formality — `prose` tier would not cover a malformed `/-! ... -/`)
- Every JSON example in the four sites is the nested shape and, piped to `lake exe check_certificate`
  with concrete formulas substituted for `<formula>` placeholders, would not be a protocol error
- The README section is read once end to end as if by an exporter author with no Lean access: is the
  required-ness of `target` and `target.time`, and the `error` (not `rejected`) answer to their
  absence, stated without inference?

---

### Phase 3: Regenerate inventories and run the full gate set [NOT STARTED]

**Goal**: The generated README inventories match the edited files, and every acceptance criterion in
the dispatch is demonstrated by a command that was actually run.

**Tasks**:

- [ ] `bash scripts/check-module-invariants.sh --emit-inventory` (regenerates the per-file line-count
      rows in `BimodalTools/README.md` and `Tests/BimodalToolsTest/README.md`, both of which are
      certain to be stale after Phases 1-2). Do **not** use the deprecated `scripts/readme-inventory.sh`
      shim.
- [ ] `bash scripts/check-module-invariants.sh` — must print ALL CHECKS PASSED. C25 (every
      `lean_exe` root compiles) covers `check_certificate`; C19 (docstring coverage) covers the new
      declarations; C28's warning budget for both edited files is zero (neither has an entry in
      `scripts/warning-budget.txt`).
- [ ] `bash scripts/check-copyright-headers.sh --strict` — clean.
- [ ] `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail` — both exit 0 at
      zero warnings.
- [ ] Sorry count 0 and no new axioms: this change introduces no proof obligation by construction
      (every new declaration is data or `Except`-valued plumbing, and `mem_closureList` is untouched),
      so confirm rather than investigate.
- [ ] Run the three acceptance certificates end to end through `lake exe check_certificate` and
      record the exact output lines: the non-vacuity family → `{"status":"countermodel","time":0}`;
      the separation family → rejected with condition `fulfilling`, lasso `0`, position `-2`,
      formula `p U q`; a certificate omitting `"time"` → `{"status":"error",...}`.
- [ ] Confirm the round trip on the nested shape is pinned by a green `#guard`
      (`parseCertificate posRaw.toJson = .ok posRaw` and the `sepRaw` equivalent), not merely asserted.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: Two generated inventory blocks are expected to change — `BimodalTools/README.md`
(the `CertificateImport.lean` row) and `Tests/BimodalToolsTest/README.md` (the
`CertificateImportTest.lean` row). Confirm by diffing the working tree after `--emit-inventory`: if
the regeneration touches a third file or a row for a file this task did not edit, stop and
investigate rather than committing the wider diff.

**Files to modify**:

- `BimodalTools/README.md` - generated inventory block (line counts only)
- `Tests/BimodalToolsTest/README.md` - generated inventory block (line counts only)

**Verification**:

- `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED
- `bash scripts/check-copyright-headers.sh --strict` is clean
- Both `--wfail` builds exit 0 at zero warnings
- Every acceptance line from the dispatch is reproduced as captured command output, quoted in the
  implementation summary — not paraphrased

---

## Testing & Validation

- [ ] `lake build BimodalTools --wfail` exits 0, zero warnings
- [ ] `lake build BimodalToolsTest --wfail` exits 0, zero warnings (green build = every `#guard` true)
- [ ] A certificate omitting `"time"` inside a present `"target"` returns `{"status":"error",...}`
- [ ] A certificate omitting `"target"` entirely returns `{"status":"error",...}` with a *distinct*
      message
- [ ] `parseCertificate posRaw.toJson = .ok posRaw` and the `sepRaw` equivalent — the nested shape
      round-trips field for field
- [ ] Non-vacuity family → `{"status":"countermodel","time":0}`
- [ ] Separation family → rejected, condition `fulfilling`, lasso `0`, position `-2`, formula `p U q`
- [ ] Negative `"time"` still survives `pInt`'s sign handling
- [ ] Unknown fields are skipped at **both** nesting levels
- [ ] `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED
- [ ] `bash scripts/check-copyright-headers.sh --strict` is clean
- [ ] Sorry count 0; no new axioms

## Artifacts & Outputs

- `BimodalTools/CertificateImport.lean` — `RawTarget`/`RawCertificate` split, `PartialTarget`/
  `PartialCertificate` + `complete` pair, nested parser, split serializer, re-projected readers,
  rationale docstring
- `BimodalTools/CheckCertificateMain.lean` — nested `## Usage` example
- `BimodalTools/README.md` — rewritten protocol section (the interface ModelChecker's exporter
  mirrors) + regenerated inventory row
- `Tests/BimodalToolsTest/CertificateImportTest.lean` — reshaped rows, inverted optionality row,
  two new error-not-rejected acceptance rows
- `Tests/BimodalToolsTest/README.md` — regenerated inventory row
- `lakefile.toml` — corrected `# Run with:` comment
- `specs/669_required_target_time_and_target_grouping/summaries/01_*-summary.md` — implementation
  summary quoting the captured acceptance output

## Rollback/Contingency

Each phase ends at a green, committed state, so the ordinary contingency is `git revert` of the
phase commit — no working-tree destruction, no snapshot needed.

The one phase where a mid-phase abort leaves an uncommittable tree is Phase 1, which is declared
`atomic-batch` over two files: its intermediate per-file states are expected red and are never
committed, so an abort there means discarding uncommitted work in exactly two known paths. If that
discard is genuinely wanted, it is a rollback, not a checkpoint: take a snapshot first per
`context/contracts/recovery.md`'s rollback rung (which names the invocation shape, including the
out-of-scope override flag for a deliberate whole-tree case) and only then run the destructive
command. Do not emit a bare default-mode `git-snapshot.sh` as a routine start-of-phase precaution;
a defensive checkpoint before risky work uses `--no-revert`, which is durable without reverting.

Contingency short of rollback: the change decomposes cleanly at the record boundary. If the grouping
half proves unexpectedly costly, the required-`time` half stands alone (drop `:= 0`, keep the flat
record, keep the partial-record seam) and still satisfies Deliverable 1 — but note the dispatch's
own argument that splitting one schema change across two revisions is the expensive version, so this
is a fallback, not a preferred decomposition.
