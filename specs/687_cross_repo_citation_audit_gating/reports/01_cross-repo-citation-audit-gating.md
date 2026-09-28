# Research Report: Task #687

- **Task**: 687 - Cross repo citation audit gating
- **Started**: 2026-09-28T02:31:00Z
- **Completed**: 2026-09-28T02:39:00Z
- **Effort**: ~1h
- **Dependencies**: Task 688 (completed; unrelated file — `scripts/check-module-invariants.sh`
  gained flock-based build serialization, no interaction with the C20/C35 sections read here)
- **Sources/Inputs**: Codebase (`scripts/lean-citation-manifest.json`, `scripts/export-lean-citations.py`,
  `scripts/lean-citation-seeds.txt`, `scripts/check-module-invariants.sh`,
  `docs/reference/transcription-audit-surface.md`), and a read-only inspection of the consuming
  repository's checkout at `~/Projects/ModelChecker` (specifically
  `code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`) — read for verification only,
  never written
- **Artifacts**: this report
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- The four-citation drift the task names is **re-confirmed exactly**: `ZTimeSharpness.lean`'s
  `not_validIn_base_prior_UZ`, `not_validIn_base_z1`, `prior_UZ_minFrameClass_sharp`,
  `z1_minFrameClass_sharp` currently resolve at lines **263, 274, 289, 300** — matching the task
  description's corrected values digit for digit, via a fresh `export-lean-citations.py` run
  against today's tree (manifest is currently byte-current; `--check` exits 0).
- The premise "every other cited line resolved at the time of measurement" **no longer holds and
  should not be carried into the plan unexamined**. Re-verifying the rest of the consuming
  document's proof-mapping table (§4.1 of `ADEQUACY.md`, "Every step, mapped to a landed,
  sorry-free Lean counterpart") surfaced a **second, previously unrecorded drift cluster**: six to
  eight citations into `FormalSystem/Semantics/ShiftSet.lean` now land in the **wrong
  declaration** — the same defect class C20/C35 exist to catch, at a file none of the 53 seeded
  names currently protect for these particular declarations. See Findings.
- The 24-row / 27-declaration inspection-only residue this task describes is **already fully
  recorded**, name-keyed and dated today, at `docs/reference/transcription-audit-surface.md`
  (landed by task 681, completed earlier today). The three rows absent from the consuming
  document's own audit — world-nonemptiness, the world-history totality layer, and the
  truth-correspondence structure — are rows 3, 20 and 24 there, each already carrying its paper
  anchor and a one-line reason it is unreached. Nothing further needs writing on this side for the
  residue *content*; what remains is getting it into the consuming table, which belongs there.
- Recommended path for "extend the gate" is **seed-list extension**, not a new cross-repository
  script: broaden `scripts/lean-citation-seeds.txt` to cover the `ShiftSet.lean` declarations
  §4.1 actually cites (the newly drifted six-to-eight), regenerate the manifest, and let C35
  protect them going forward exactly as it already protects the ZTimeSharpness four. This fits
  the task's declared `file_scope` without inventing a new script, and is the option nothing in
  the consuming repository needs to change to benefit from. "Have the consuming side consume the
  manifest" is the complementary option named in the task description; it requires action in
  `~/Projects/ModelChecker`, is out of this repository's reach to implement, and should be
  recorded as a proposal, not attempted here.

## Context & Scope

This is a `general`-typed, docs/tooling task confined by its own `file_scope` to six files, all in
this repository:

```
scripts/export-lean-citations.py
scripts/lean-citation-seeds.txt
scripts/lean-citation-manifest.json
scripts/check-module-invariants.sh
scripts/module-invariants-allowlist.txt
docs/reference/transcription-audit-surface.md
```

No file under `~/Projects/ModelChecker` is in scope, consistent with the task's own instruction:
"the table correction itself belongs to the consuming repository — propose it there rather than
reaching across." The consuming checkout was read at `~/Projects/ModelChecker` (present on this
machine) purely to verify the task's factual claims and to produce a ready-to-hand-off correction;
nothing there was modified.

The relevant mechanism, landed today by task 681 (completed, see
`specs/681_narrow_transcription_audit_surface/`):

- `scripts/lean-citation-seeds.txt` — a reviewable, name-keyed seed list (currently 53 fully
  qualified declaration names, grouped by comment headers).
- `scripts/export-lean-citations.py` — resolves every seeded name to its current file, keyword
  line and declaration span (via `scripts/lib/lean_citations.py`'s `decl_spans`, the same reader
  C20 uses) and writes `scripts/lean-citation-manifest.json`, deterministically.
- `scripts/check-module-invariants.sh`'s **C35** — build-free, enforced (`ENFORCE_C35=1`, no soft
  window), fails the moment a fresh resolution differs from the committed manifest.
- `docs/reference/transcription-audit-surface.md` — the name-keyed residue record and the
  "Corrections the consuming table owes" table, both landed today.

C35's own header comment already names the incident this task investigates almost verbatim
(`scripts/check-module-invariants.sh:759-773`): "a consuming repository's adequacy argument cited
four declarations by `file.lean:NNN`, every one of those citations drifted by exactly +38 lines
… and every gate in both repositories stayed green." That comment is accurate as far as it goes;
what it does not yet know is documented below.

## Findings

### 1. The measured +38 drift: reconfirmed, unchanged

Fresh resolution (`python3 scripts/export-lean-citations.py --check` exits 0; the committed
manifest is byte-current today) gives:

| Declaration | Manifest keyword line (today) | Corrected line named in the task |
|---|---|---|
| `not_validIn_base_prior_UZ` | 263 | 263 |
| `not_validIn_base_z1` | 274 | 274 |
| `prior_UZ_minFrameClass_sharp` | 289 | 289 |
| `z1_minFrameClass_sharp` | 300 | 300 |

All four are `+38` from what `ADEQUACY.md` still cites today (225, 236, 251, 262 — unchanged;
that document has not been edited to absorb the correction). The sorry-count claim
("`grep -c sorry` returns `0` for `Semantics/ShiftSet.lean`, `WitnessFamily/Agreement.lean`,
`WitnessFamily/Decide.lean` and `Metalogic/Independence/ZTimeSharpness.lean`") also still holds —
re-measured directly, all four return 0. The axiom-census claim ("`FormalSystem/` declares no
axioms") is unaffected by anything measured here; `MainResults.lean` still runs its `#print axioms`
audit at build time and nothing in this pass found a new `axiom` declaration in the live library
tree beyond the pre-existing structural/class `axiom` stubs already accounted for elsewhere.

### 2. A second, previously unrecorded drift cluster — the task's own re-verify instruction earns its keep

`ADEQUACY.md` §4.1 ("Every step, mapped to a landed, sorry-free Lean counterpart") is a distinct
table from the four ZTimeSharpness rows — it is the Lemma-1-through-4 proof-step mapping, and nine
of its file:line citations point into `FormalSystem/Semantics/ShiftSet.lean`. None of the
declarations this sub-cluster names are in the current 53-name seed list, so C35 has never
protected them. Resolving each by name against the live tree (via a scratch seed probe, not the
committed manifest) and checking the cited line against the resolved declaration's span:

| §4.1 row | Declaration(s) cited | `ADEQUACY.md` cites | Actual span (today) | Verdict |
|---|---|---|---|---|
| Lemma 1, Compositionality | `shRel_comp` | `ShiftSet.lean:148` | `[156, 170]` | **Wrong declaration** — line 148 is inside `shRel_reflection`'s docstring, the *previous* declaration |
| Lemma 1, Seriality | `shRel_serial` | `ShiftSet.lean:163` | `[171, 177]` | **Wrong declaration** — line 163 is inside `shRel_comp`'s body |
| Lemma 1, Saturation | `shRel_saturation` | `ShiftSet.lean:171` | `[178, 183]` | **Wrong declaration** — line 171 is `shRel_serial`'s docstring-open line |
| Lemma 1, Limit (2nd ref) | `limit_reflect_of_reflective` usage site (inside `fibre_isRegular`) | `ShiftSet.lean:203` | `fibre_isRegular` is `[206, 214]` | **Wrong declaration** — line 203 is inside the *preceding* `fibre` def's body |
| Lemma 1, whole | `fibre_isRegular` | `ShiftSet.lean:200` | `[206, 214]` | **Wrong declaration** — line 200 is the closing `-/` of `fibre`'s own docstring |
| Lemma 1, whole | `frame_isRegular` | `ShiftSet.lean:225` | `[231, 235]` | **Wrong declaration** — line 225 is inside `frame`'s docstring |
| Lemma 3 | `forward_repr` | `ShiftSet.lean:284` | `[286, 322]` | **Wrong declaration** — line 284 is inside `ShiftTruth`'s pattern-match body (the preceding def) |
| Lemma 1, Limit (1st ref) | the `sep` field | `ShiftSet.lean:115` | field doc `~[108,123]`, field at 124 | Correct (field citation, no declaration span to miss) |
| Lemma 2 | `total_eq_orbit` | `ShiftSet.lean:252` | `[248, 267]` | Correct — lands inside its own span, though not on the keyword line (261) |
| (residue-adjacent) | `WitnessFamily.std` | `Std.lean:65` | `[59, 78]` | Correct-but-loose — already recorded in the existing corrections table |

Net: **six of nine `ShiftSet.lean` citations in this one table now name the wrong declaration**,
plus one further wrong-declaration hit on the second file:line of the "Lemma 1, Limit" row — the
same failure mode C20/C35 exist to catch, on a file this task's own seed list does not yet cover
for these names. `git log -L148,150:FormalSystem/Semantics/ShiftSet.lean` traces the drift at that
location to commit `ef4707035` (2026-09-16), so this is not new since the task was written; it is
older than the +38 incident and was simply never caught, because nothing — in either repository —
was reading these particular citations. This is exactly the blind spot the task's "why it rotted"
paragraph describes, just at a second location the task's own description had not yet measured.

**Implication for the plan.** The task description's framing ("every other cited line resolved…
re-verify before editing rather than trusting those numbers") should be read as fully vindicated:
the four-citation correction is confirmed as-stated, but the "everything else is fine" half of
that premise is now false and the plan needs to fold this second cluster into the same correction
pass, or explicitly scope it out with a reason.

### 3. The 24-row residue is already fully recorded on this side, today

`docs/reference/transcription-audit-surface.md` (landed by task 681, dated
`*Last verified: 2026-09-27*` — today) already carries:

- The full 24-row / 27-declaration residue table, name-keyed, zero line numbers.
- An explicit "The three rows the consuming audit does not reach" section identifying exactly the
  three notions the task names — row 3 (`FrameOver`/`TaskFrame.worldNonempty`), row 20
  (`PartialHistory`, `PartialHistory.IsTotal`, `WorldHistory`), and row 24 (`TruthCorr`, reachable
  only if the *general* time-shift lemma is cited rather than the instantiated
  `timeShift_preserves_truth`) — each with its paper anchor and the reason it is unreached.
- A "Corrections the consuming table owes" table already covering the four stale citations, the
  deleted hand-proof (`WitnessFamily.std`), the two loose-but-technically-correct citations, the
  over-strong *Limit* verdict, and the time-shift instance-vs-general-lemma ambiguity.

One caveat worth recording precisely, cross-checked directly against `ADEQUACY.md` rather than
assumed: `ADEQUACY.md` §4.2 already states, in its own table, `` `app:auto_existence` (`:3197`) |
not needed: Corollary 2.1 derives it | **Not a dependency** ``. That is a reasoned position, not an
omission — the consuming document is aware of the general time-shift lemma and explicitly declines
it because it only ever cites the *instantiated* form. `transcription-audit-surface.md`'s own
corrections table already anticipates exactly this ("conditional on which time-shift statement is
cited"), so row 24 is correctly framed there as conditional rather than as a flat omission — the
proposal below should carry that nuance rather than presenting "not needed" as a plain gap.

Nothing in `transcription-audit-surface.md`'s residue content needs to change. What is missing is
getting rows 3, 20 and 24 (with the row-24 nuance above) turned into actual rows in `ADEQUACY.md`
§4.2 — which is the consuming repository's edit to make, not this one's.

### 4. The gating mechanism has no cross-repository counterpart, confirmed by search

- `grep`-ing `~/Projects/ModelChecker` for `lean-citation-manifest` or any reference to this
  repository's manifest mechanism returns nothing. The consuming repository's own citations
  (`ADEQUACY.md`'s `All Lean citations are to ~/Projects/BimodalLogic/FormalSystem/… Every cited
  name was checked to resolve at the cited file and line at the time of writing`) are hand-verified
  prose, never machine-checked, and nothing there re-runs that check.
  `~/Projects/ModelChecker/specs/TODO.md` has no open task addressing `ADEQUACY.md`'s stale
  citations or its missing residue rows — this genuinely has no owner yet on that side.
- The consuming repository does already have an established convention for resolving this
  repository's checkout path from Python test code — `BIMODAL_LOGIC_PATH`, falling back to
  `~/Projects/BimodalLogic` (see
  `code/src/model_checker/theory_lib/bimodal/tests/_lean_check.py`). That is the natural handle a
  future consuming-side check would reuse to locate `scripts/lean-citation-manifest.json`, but
  building that check is `~/Projects/ModelChecker` work, outside this task's `file_scope` and
  outside what this repository can commit.

## Recommendations

1. **Extend `scripts/lean-citation-seeds.txt`**, in the "Derived rather than assumed" or a new
   group, to add the six-to-eight `ShiftSet.lean` names identified in Finding 2:
   `shRel_saturation`, `fibre_isRegular`, `frame_isRegular`, `forward_repr` at minimum (the ones
   found wrong today), plus `shRel_comp`/`shRel_serial` are *already* seeded (residue group) — the
   gap is only that C35 protects their *own future drift* going forward, not that it retroactively
   fixes what `ADEQUACY.md` currently cites for them. Regenerating the manifest after the addition
   gives the plan/implementation phase the authoritative current line for every one of these, the
   same way it already did for the four ZTimeSharpness names.
2. **Add a new block to `docs/reference/transcription-audit-surface.md`'s "Corrections the
   consuming table owes" table** (or a clearly delineated addendum) recording the second drift
   cluster from Finding 2, with the same "what's wrong / declarations involved / what to do"
   shape already used there, resolved against the freshly regenerated manifest rather than against
   this report's line numbers (which are a snapshot, not the generated view).
3. **Do not attempt to write, patch, or PR anything under `~/Projects/ModelChecker`.** The
   deliverable for the plan/implementation phases is a complete, mechanically-verifiable
   correction proposal recorded on this side (extended seed list + regenerated manifest + extended
   corrections table), ready for a human or a future `~/Projects/ModelChecker`-side task to apply
   by mechanical lookup — exactly the handoff shape `transcription-audit-surface.md` already uses
   for the original four.
4. **Record "have the consuming side consume the manifest" as a named, deferred proposal**, not an
   implementation item here: a `~/Projects/ModelChecker`-side gate (most naturally reusing the
   existing `BIMODAL_LOGIC_PATH` checkout-resolution convention) that reads
   `scripts/lean-citation-manifest.json` from a local BimodalLogic checkout and cross-checks
   `ADEQUACY.md`'s own `file.lean:NNN` citations against it, skipping cleanly when no checkout is
   present (mirroring the existing `_lean_check.py` skip discipline). This is the second option the
   task names; it closes the loop completely but is not implementable within this task's
   `file_scope`.
5. **The residue rows (§3) require no further drafting** — `transcription-audit-surface.md`'s
   existing rows 3, 20 and 24 (with the row-24 conditional framing) are ready to be copied into
   `ADEQUACY.md` §4.2 essentially as-is; note the row-24 nuance (conditional on which time-shift
   citation is used) explicitly wherever this is proposed to the consuming repository so it is not
   presented as a flat omission that document does not, in fact, have.

## Decisions

- Verified rather than assumed: the task's numeric claims (263/274/289/300, sorry counts) are
  confirmed exactly as stated against today's tree.
- Scope boundary honored: no file under `~/Projects/ModelChecker` was written; it was read only to
  verify claims and locate the exact table this proposal must correct.
- The second drift cluster (Finding 2) is treated as in-scope for this task rather than a
  separate one, since it is the same failure mode, the same consuming document, the same
  mechanism gap, and was only found by doing the re-verification the task explicitly asked for.

## Risks & Mitigations

- **Risk**: treating the seed-list extension as fixing `ADEQUACY.md` itself. **Mitigation**: it
  only fixes this repository's ability to *detect* future drift at those names; the actual
  correction still requires an edit in the consuming repository, which this task does not perform.
- **Risk**: the corrected line numbers recorded anywhere (this report, or a future addendum to
  `transcription-audit-surface.md`) going stale again before the consuming repository acts on
  them. **Mitigation**: consistent with the existing convention, any proposal text should point at
  "resolve against the manifest" rather than hard-coding line numbers wherever avoidable, exactly
  as the existing corrections table already does.
- **Risk**: scope creep into implementing the `~/Projects/ModelChecker`-side consumer script.
  **Mitigation**: explicitly deferred in Recommendation 4; flagged as a separate, cross-repository
  follow-up rather than folded into this task's plan.

## Context Extension Recommendations

- **Topic**: cross-repository citation gating pattern (a repository whose declarations are cited
  by line number from a consuming repository's docs, and how to keep that gate honest from the
  cited side).
- **Gap**: no existing `.claude/context/` page documents this pattern generally; it currently lives
  only in `scripts/check-module-invariants.sh`'s C35 comment and
  `docs/reference/transcription-audit-surface.md`'s prose.
- **Recommendation**: if this pattern recurs (e.g. once a `~/Projects/ModelChecker`-side consumer
  exists per Recommendation 4), consider a short pattern note under
  `.claude/context/patterns/` describing the seed-list -> generated-manifest -> build-free-gate
  shape so a future cross-repository citation table elsewhere in the Logos ecosystem does not
  reinvent it. Not urgent enough to spawn on its own; noted for `/distill`-style harvesting.

## Appendix

- `python3 scripts/export-lean-citations.py --check` — exit 0, manifest byte-current today.
- Scratch seed probe (8 names, not committed) used to resolve the `ShiftSet.lean` declarations
  §4.1 cites but the committed seed list does not yet cover; probe files were written under the
  session scratchpad, not under `scripts/`, and are not part of this report's deliverable.
- `grep -c sorry` on `Semantics/ShiftSet.lean`, `WitnessFamily/Agreement.lean`,
  `WitnessFamily/Decide.lean`, `Metalogic/Independence/ZTimeSharpness.lean` — all 0.
- `git log -L148,150:FormalSystem/Semantics/ShiftSet.lean` — drift at that location traced to
  commit `ef4707035` (2026-09-16).
- Read-only inspection of `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`
  (§4.1, §4.2) and a repo-wide grep of `~/Projects/ModelChecker` for `lean-citation-manifest` /
  `BimodalLogic` references, plus `~/Projects/ModelChecker/specs/TODO.md` for any existing
  counterpart task (none found).
