# Research Report: Task #686

- **Task**: 686 - modelchecker_contract_handoffs
- **Started**: 2026-09-28T01:31:01Z
- **Completed**: 2026-09-28T (this report)
- **Effort**: ~2h (research only; six independently-sized items, three already resolved)
- **Dependencies**: None declared
- **Sources/Inputs**: Codebase exploration of this repository (BimodalLogic) and
  `~/Projects/ModelChecker` (a sibling checkout on this machine, not a submodule); no web
  search needed (fully internal, cross-repository contract audit)
- **Artifacts**: this report
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Three of the six items are already fully landed in `~/Projects/ModelChecker`, committed,
  and wired into passing tests.** The echo comparison (item 1), the producer's `ensure_ascii`
  pin (item 2), and the `"acceptance"` absent-default handling (item 4) were completed by
  ModelChecker's own tasks 197 and 207 (commits through `ec430559`, `2026-09-27 18:06`, the same
  day as this dispatch). Re-verify only; do not re-implement.
- **One item is not applicable anywhere on this machine.** Item 3 (the source-breaking
  `CheckResult.countermodel` pattern-match audit) has no target: `~/Projects/ModelChecker`
  contains zero `.lean` files, and a filesystem-wide search of every other checkout under
  `~/Projects/` for anything importing `BimodalTools.CertificateImport`/`CanonicalWire` also
  returns zero hits. The audit is genuinely negative, not merely unperformed.
- **One item is a real, precisely located, pre-existing defect that must now actually be fixed**
  (item 6): `Sentence.update_types`'s extremal-operator branch in
  `code/src/model_checker/syntactic/sentence.py:238-240` mishandles `\top`, and the fix is a
  genuine prerequisite for item 5's fixture corpus (row 13 is a `\top` sentence).
  `examples.py` and `test_formula.py`'s box corpus currently route around it rather than fix it.
- **One item is genuinely unstarted** (item 5, the translation conformance channel): no test,
  script, or module anywhere in ModelChecker consumes
  `Tests/fixtures/sentence-translation-fixtures.jsonl` or invokes `lake exe translate_sentence`.
  This is real, scoped, new work with a clear pattern to follow (`_lean_check.py`'s
  skip-resolution idiom) and a clear comparison target (parsed JSON, never bytes, per both
  repositories' own README text).
- **Recommended sequencing for the plan phase**: item 6 (top-operator fix) before item 5
  (translation channel), since 5's fixture corpus includes the row that exercises 6's bug;
  items 1/2/3/4 need only a verification pass, not implementation.

## Context & Scope

The task description frames every one of its six items as "an edit to `~/Projects/ModelChecker`
gated on artifacts that already exist here [BimodalLogic]." This report audits, for each item,
what state ModelChecker is actually in — not what the task description assumed going in — because
ModelChecker runs its own independent task-management system (`specs/TODO.md`,
`specs/state.json`, `next_project_number: 209` at the time of this research) and had, in fact,
already completed adjacent work (its own tasks 197 and 207) targeting the exact same BimodalLogic
landing (task 678, commit `d55e2760e`) that this task's description cites. Scope was therefore:
read the BimodalLogic-side contract precisely (README + source), then read the ModelChecker-side
implementation precisely, and report the actual gap — which is narrower than the task description
implies for four of the six items, and includes one genuine dependency the description does not
mention (5 needs 6 fixed first).

No files were edited in either repository; this is the research phase only. No web search was
needed — this is a closed, internal, cross-repository contract-conformance question.

## Findings

### Item 1 — Echo comparison ("THE ONE THAT MATTERS MOST"): ALREADY DONE

BimodalLogic's `BimodalTools/README.md:176-200` documents the `"echo"` key (added by task 678):
a `countermodel`/`rejected` verdict now carries a canonical reprint of what the binary parsed,
resting on `BimodalTools.CanonicalWire.print_parse_canonical`. The consuming side must compare
this against the bytes it sent, modulo surrounding whitespace only.

ModelChecker already does this:
- `code/src/model_checker/theory_lib/bimodal/tests/_lean_check.py:114-160` — `run_check_certificate_with_sent`
  (returns `(verdict, sent)`) and `assert_echo_matches_sent(verdict, sent)`, both landed at
  commit `ae3584d0` ("task 197 phase 1: canonical wire bytes") through `ec430559` ("task 197
  phase 6: the joint trust-base claim").
- **Actually called**, not merely defined, at
  `code/src/model_checker/theory_lib/bimodal/tests/integration/test_certificate_lean_agreement.py:148,173,190`
  (the positive `countermodel` path, and both `error`-path negative checks that no `echo` is
  present) and at
  `code/src/model_checker/theory_lib/bimodal/tests/unit/test_semantics_core.py:290`.

Nothing remains to implement here. A verification pass (does the test suite currently pass
against the live `lake exe check_certificate`?) is the only outstanding action, and it is cheap:
`cd ~/Projects/ModelChecker && PYTHONPATH=code/src pytest code/src/model_checker/theory_lib/bimodal/tests/integration/test_certificate_lean_agreement.py -v`
(the module self-skips cleanly if the BimodalLogic checkout or `lake` is unavailable, and fails
loudly rather than skipping if the binary answers wrong — `_lean_check.py`'s `PROTOCOL_FAILURE`
mechanism, module docstring lines 24-32).

### Item 2 — Pin the producer's encoding (`ensure_ascii=False`): ALREADY DONE

`code/src/model_checker/theory_lib/bimodal/semantic/certificate.py:177-206` —
`canonical_wire_bytes` is the **single** function that serializes a certificate payload to the
wire bytes `lake exe check_certificate` receives (confirmed as the sole call site from
`_lean_check.py:127`'s `sent = canonical_wire_bytes(payload)`), and its docstring names
`ensure_ascii=False` explicitly as "the producing-side hand-off BimodalLogic's phase 9 names in
`BimodalTools/README.md`" (lines 195-198), landed by the same commit range as item 1
(`ae3584d0`, "task 197 phase 1: canonical wire bytes, in the protocol module").

Other `json.dumps` call sites in this repository (`oracle/bimodal_logic/cli.py:121,129`,
`ground_truth.py:246`) are a different, unrelated CLI tool (`oracle/bimodal_logic/`, a
BimodalHarness-era ground-truth oracle) that does not feed the certificate wire protocol — they
are out of scope and require no change.

### Item 3 — Source-breaking `CheckResult.countermodel` pattern-match audit: NO TARGET FOUND

`BimodalTools/CertificateImport.lean:315-322` shows `CheckResult.countermodel` now carries
`(time : Int) (acceptance : Acceptance)` — two fields, was one before task 678. Any Lean code
importing `BimodalTools.CertificateImport` and matching `.countermodel time` (one arg) would fail
to compile.

`~/Projects/ModelChecker` contains **zero `.lean` files** (`find . -iname "*.lean"` returns
nothing, confirmed excluding `.lake`/build artifacts — there are none, since this is a pure
Python repository). A second, wider check — every other checkout directly under `~/Projects/`
(`cslib`, `cslib-pr648`, `Frame`, `Logos`, `ProofChecker` [effectively empty, `.git` only],
`TenseModality`, etc.) — for anything importing `CertificateImport`, `CanonicalWire`, or
`BimodalTools` in a `.lean` file, also returns zero hits. Within BimodalLogic itself, every
existing pattern match already uses the current two-argument shape (e.g.
`Tests/BimodalToolsTest/CertificateImportTest.lean:96,98`:
`CheckResult.countermodel 0 .entailment`; `BimodalTools/CertificateImport.lean:466,553,583`), so
this repository's own build is not at risk either (confirmed independently by task 678's summary
reporting a green, `--wfail` build).

**This item has no actionable target on this machine.** Treat the audit as performed with a
negative result, not as unperformed. If a Lean-based consumer exists somewhere off this machine
(not fetchable and not evidenced by anything in either repo's own references), that is outside
what this research pass can discover; nothing in either repository's cross-references (READMEs,
docstrings, `KNOWN_EXTERNAL_DEFECTS.md`) names one.

### Item 4 — The additive `"acceptance"` key's default: ALREADY DONE

BimodalLogic's contract (`BimodalTools/README.md:159-174`): `"acceptance"` appears on
`countermodel` only; an absent field must read as `"decided"`.

ModelChecker already implements exactly this default in both places that read the field:
- `test_certificate_lean_agreement.py:135-145`: `acceptance = verdict.get("acceptance",
  "decided")`, followed by an assertion the fixture corpus (against the *current* binary, which
  does construct the entailment) expects `"entailment"` specifically — i.e. the default path is
  implemented and a stricter same-module assertion additionally pins the current binary's
  stronger behavior.
- `test_semantics_core.py:248-279`: identical `.get("acceptance", "decided")` idiom, with
  matching docstring commentary.

Nothing remains to implement; a verification-only pass applies here too.

### Item 5 — The translation conformance channel: GENUINELY UNSTARTED, and depends on item 6

BimodalLogic's side (landed by task 679, commit range `19a893bc..d815cf3e`, **after** the commit
ModelChecker's echo/acceptance work is pinned to — see "Sequencing" below):
- `FormalSystem/SourceLanguage/Sentence.lean` — `Sentence` (18 constructors), `tr : Sentence ->
  Formula`, twelve push-through equations, three deliberate inequalities (`tr_cond_ne`,
  `tr_someFut_ne`, `tr_somePast_ne`), and `tr_not_injective` (the channel is forward-only).
- `FormalSystem/SourceLanguage/SentenceTruth.lean` — `Sat`, `sat_iff` (the agreement theorem).
- `BimodalTools/SentenceExport.lean` — `Sentence.toJson`, `pSentence`,
  `translateSentenceLineToJson` (parse -> `tr` -> `Formula.toJson`).
- `BimodalTools/TranslateSentenceMain.lean` — `lake exe translate_sentence`: one JSON line in,
  one JSON line out.
- `Tests/fixtures/sentence-translation-fixtures.jsonl` — 26 lines, each
  `{"surface", "kind", "sentence", "formula"}`; `kind` in `{primitive, defined, asymmetry,
  nesting}`. Row 13 is the `\top` row:
  `{"surface": "\\top", "kind": "defined", "sentence": {"tag": "top"}, "formula": {"tag":
  "imp", "left": {"tag": "bot"}, "right": {"tag": "bot"}}}`.
- `BimodalTools/README.md:293-372` states explicitly what the consuming repository must assert:
  "that its own translation of `surface` serializes to `formula` for every line" and that
  **comparison is on parsed JSON, never on bytes** (`Formula.toJson`'s `", "`/`": "` separators
  are not a promise).

ModelChecker's side: a full grep for `translate_sentence` and
`sentence-translation-fixtures` across the whole repository (excluding archived spec directories,
which are historical prose, not code) returns **zero hits**. No test module, no CLI wrapper, no
fixture mirror exists. ModelChecker does, however, already have the pieces this channel needs to
consume, independently built for other reasons:
- `code/src/model_checker/theory_lib/bimodal/semantic/formula.py` — a Python `Formula` ADT
  structurally identical to `FormalSystem.Syntax.Formula` (module docstring, lines 1-13), with
  `to_json`/`from_json` mirroring `Formula.toJson`/`pFormula` exactly (tag vocabulary
  `atom`/`bot`/`imp`/`box`/`untl`/`snce`, `untl`/`snce` guard-first — same as the BimodalLogic
  side), and `translate(sentence)` (`formula.py:323-370`) converting an already-`update_types`'d
  `syntactic.Sentence` into this `Formula`.
- `code/src/model_checker/syntactic/sentence.py` — `Sentence.update_types` (`sentence.py:185-254`)
  is ModelChecker's own operator-elimination pass (defined operators -> primitives), the direct
  analogue of BimodalLogic's `tr`.

**What is missing is the bridge**: nothing currently (a) constructs a ModelChecker
`syntactic.Sentence` from a fixture row's `surface`/`sentence` field, (b) runs it through
`update_types` + `translate` + `to_json`, and (c) asserts the result equals the fixture's
`formula` field as **parsed JSON** (dict/list equality, not string equality). The natural
integration point, by precedent, is a new test module beside
`test_certificate_lean_agreement.py` (same directory,
`code/src/model_checker/theory_lib/bimodal/tests/integration/`), following `_lean_check.py`'s
established idiom for resolving the BimodalLogic checkout and (optionally, for a stronger,
skippable differential leg) invoking `lake exe translate_sentence` directly and comparing its
parsed stdout to the fixture-only assertion. The fixture-only assertion (comparing against the
committed `.jsonl`, not the live binary) can and should run unconditionally, with no skip
condition, since it needs no subprocess.

**Item 6 is a hard prerequisite for a complete item 5.** Fixture row 13 is a `\top` sentence.
Building that row's ModelChecker-side `Sentence` and running it through `update_types` hits the
exact defect documented below — so item 5's fixture loop cannot pass on all 26 rows until item
6 is fixed. (An implementer could special-case row 13 as an initially-skipped/xfail row, but the
task description is explicit that the new theorem "does cover top" and that this defect
"belongs in this pass" — i.e. skipping it is not the intended outcome.)

### Item 6 — The pre-existing `\top` defect in `update_types`: real, located, must be fixed here

**Location**: `code/src/model_checker/syntactic/sentence.py:238-240`, inside
`Sentence.update_types`'s nested `store_types` function:

```python
# Check for extremal operator
if self.name in {'\\top', '\\bot'}:
    return first_elem, None, None
```

**Root cause**: this branch tests `self.name` — the *original*, pre-derivation operator name of
the sentence being updated — not the shape of `derived_type` (the value `derive_type` actually
produced after recursively eliminating defined operators). `\bot` is a true primitive: for a
`\bot` sentence, `derived_type` really is a one-element extremal shape, and `first_elem` is the
operator itself with no arguments, so the branch is correct. `\top`, however, is a **defined**
operator (`Sentence.lean`'s counterpart: `\top` = `¬⊥`, and BimodalLogic's own `tr_top : tr
Sentence.top = Formula.top` confirms `Formula.top` is itself `Formula.bot.neg`, i.e. an `imp`
of two `bot`s, not a nullary primitive). After `derive_type` fully eliminates `\top`, the
resulting `derived_type` is a **three-element** structure (an operator plus two arguments — the
Imp-shaped expansion), not a one-element extremal shape. Because the branch keys off `self.name`
(still `"\\top"`) rather than the derived shape, it fires anyway and returns
`(first_elem, None, None)` — discarding the two argument sentences the expansion actually
produced. The sentence ends up with `operator` set to whatever `first_elem` is (the outermost
operator of the `\top` expansion) but `arguments = None`, an internally inconsistent state that
either crashes or silently misbehaves in every downstream consumer of `.arguments` (including
`formula.py`'s `translate`, whose docstring at `formula.py:323-333` explicitly states it expects
`update_types` to have already fully expanded any `DefinedOperator` — `\top` reaching `translate`
at all is documented there as *itself* diagnostic of this exact upstream failure).

**Corroborating evidence this is real and already known, just routed around rather than fixed**:
- `code/src/model_checker/theory_lib/bimodal/examples.py:1050,1069` — `# Note: \top = \neg \bot
  (explicit expansion to avoid TopOperator bug)`: every example needing verum is hand-written as
  `\neg \bot` instead of `\top`, throughout this theory's own example corpus.
- `code/src/model_checker/theory_lib/bimodal/tests/unit/test_formula.py:962-968` —
  `_BOX_TEST_CORPUS = [ast for ast in _GENERATED_CORPUS if ast[0] != "top"] + ...`, with an
  explicit comment: "`\top` is excluded from the differential exercise below (though it stays in
  `_GENERATED_CORPUS` for the coverage assertion): a bare/nested `\top` sentence hits a
  pre-existing, already-documented TopOperator bug in `Sentence.update_types`'s extremal-operator
  branch ... out of scope for this translation-bridge obligation to fix as a drive-by."

**Proposed fix direction** (for the plan phase to size and confirm, not performed here): key the
extremal-operator check off the *derived* shape rather than the original name — e.g. test
`len(derived_type) == 1` (or equivalently, that `first_elem` itself carries no further
arguments) instead of `self.name in {'\\top', '\\bot'}`. This would let `\bot` continue to take
the extremal branch (its `derived_type` is genuinely one element) while letting `\top` fall
through to the general "complex sentence with operator and arguments" branch just below
(`sentence.py:242-246`), which is exactly the shape its Imp-of-two-Bots expansion actually has.
The `KNOWN_EXTERNAL_DEFECTS.md` accommodation-and-removal-criterion pattern used elsewhere in
this repository (for the unrelated BimodalHarness boundary defect) is a precedent for how a fix
here should be verified: re-run every existing consumer that currently routes around the bug
(`examples.py`'s explicit-expansion comments, the box test corpus exclusion) and confirm each
could now use `\top` directly, though undoing those routings is a separate, optional cleanup the
plan phase should decide on its own merits rather than bundling automatically.

## Decisions

- **Treat items 1, 2, and 4 as verification-only, not implementation.** Re-running the existing
  ModelChecker test suite against the current `lake exe check_certificate` binary is the whole
  of the remaining work; no source change is proposed for any of the three.
- **Treat item 3 as a completed, negative-result audit.** No further searching for a
  nonexistent out-of-repo Lean consumer is warranted; document the negative result and move on.
- **Sequence item 6 before item 5 in the implementation plan**, since 5's fixture corpus
  (specifically row 13) cannot be asserted end-to-end while 6 is open.
- **Comparison for item 5 must be on parsed JSON, never on bytes** — both repositories' own
  documentation states this independently and for the same reason (the `Formula.toJson`
  separator convention is not a cross-language promise).

## Risks & Mitigations

- **Risk**: an implementer re-does items 1/2/4, treating the task description's framing ("every
  item is an edit to make") at face value without first checking ModelChecker's current state.
  **Mitigation**: this report's file:line citations for the already-landed code and its git
  commit hashes (`ae3584d0`..`ec430559`) make the already-done state independently checkable in
  under a minute.
- **Risk**: item 6's fix is scoped too broadly (e.g. also touching every `examples.py` site that
  currently spells verum as `\neg \bot`), turning a small, well-isolated bug fix into an
  open-ended refactor. **Mitigation**: the plan phase should scope item 6 to the
  `store_types`/`update_types` branch fix and the minimal test proving `\top` now round-trips
  correctly; treat un-routing `examples.py`'s existing workarounds as optional, separately
  decided cleanup.
- **Risk**: item 5's live-binary differential leg (invoking `lake exe translate_sentence` per
  fixture row) adds 26 subprocess invocations per test run if not batched, which is slow and a
  poor match for the `_lean_check.py` single-probe-then-skip pattern built for the certificate
  tests. **Mitigation**: prefer the fixture-only (no-subprocess) comparison as the primary,
  always-run assertion; treat a live `lake exe translate_sentence` differential leg (if wanted at
  all) as a single optional, skippable module mirroring `_lean_check.py`'s probe-once idiom,
  not a per-row subprocess loop.

## Context Extension Recommendations

None. This is a one-off cross-repository contract audit; no recurring pattern here is missing
from `.claude/context/` that would benefit future tasks beyond what this report itself records.

## Appendix

### Files read (BimodalLogic)

- `BimodalTools/README.md` (certificate wire schema, echo/acceptance sections, joint canonical
  contract table, source-sentence translation protocol section)
- `BimodalTools/CanonicalWire.lean`, `BimodalTools/CertificateImport.lean`
  (`Acceptance`, `CheckResult`, `CheckOutcome`, `checkCertified`, `checkRaw`,
  `refutes_of_countermodel`, `toJsonWithEcho`)
- `FormalSystem/SourceLanguage/Sentence.lean` (`Sentence`, `tr`, push-through/non-push-through
  theorems, `tr_not_injective`)
- `BimodalTools/SentenceExport.lean`, `BimodalTools/TranslateSentenceMain.lean`
- `Tests/fixtures/sentence-translation-fixtures.jsonl` (26 rows)
- `specs/678_canonical_wire_parser_round_trip/summaries/01_canonical-wire-parser-round-trip-summary.md`
- `specs/state.json` (task 686's own description, verbatim)
- `git log` for `FormalSystem/SourceLanguage/`, `Tests/fixtures/sentence-translation-fixtures.jsonl`
  (task 679, commits `19a893bc`..`d815cf3e`) and current `HEAD` (`0d0e4051f`)

### Files read (`~/Projects/ModelChecker`)

- `code/src/model_checker/theory_lib/bimodal/tests/_lean_check.py` (full)
- `code/src/model_checker/theory_lib/bimodal/tests/integration/test_certificate_lean_agreement.py`
  (full)
- `code/src/model_checker/theory_lib/bimodal/tests/unit/test_semantics_core.py:240-290`
- `code/src/model_checker/theory_lib/bimodal/semantic/certificate.py:160-215`
  (`canonical_wire_bytes`)
- `code/src/model_checker/theory_lib/bimodal/semantic/formula.py` (module docstring, `translate`)
- `code/src/model_checker/syntactic/sentence.py:150-310` (`update_types`, `store_types`)
- `code/src/model_checker/theory_lib/bimodal/tests/unit/test_formula.py:940-970` (box test
  corpus exclusion comment)
- `code/src/model_checker/theory_lib/bimodal/examples.py:1050,1069` (workaround comments)
- `oracle/bimodal_logic/KNOWN_EXTERNAL_DEFECTS.md` (checked and ruled out as the location of the
  top-operator defect — it documents an unrelated BimodalHarness boundary defect)
- `oracle/bimodal_logic/cli.py`, `oracle/bimodal_logic/translation.py` (checked and ruled out of
  scope — a separate, unrelated CLI/oracle tool)
- `specs/TODO.md`, `git log --oneline -20` (ModelChecker's own task history: 197, 207, 208)

### Search queries used

- `grep -rn "echo"`, `"acceptance"`, `"CheckResult"`, `"countermodel"` across both repositories
- `find . -iname "*.lean"` under `~/Projects/ModelChecker` and every other `~/Projects/*` checkout
  (item 3's negative-result audit)
- `grep -rln "translate_sentence\|sentence-translation-fixtures"` (item 5's negative-result check)
- `grep -rn "TopOperator bug\|avoid TopOperator"` (item 6's cross-reference chain)
- `git log --oneline -- <path>` for dating BimodalLogic's task 678 vs. 679 landings and
  ModelChecker's task 197/207 landings, to establish the sequencing claim above
