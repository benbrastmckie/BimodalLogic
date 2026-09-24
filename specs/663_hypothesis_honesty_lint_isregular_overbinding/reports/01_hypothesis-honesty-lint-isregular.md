# Research Report: Task #663

**Task**: 663 - Hypothesis-honesty lint for IsRegular over-binding
**Started**: 2026-09-24T00:00:00Z
**Completed**: 2026-09-24T00:00:00Z
**Effort**: Medium (one Lean fix phase, one gate phase, one docs phase)
**Dependencies**: Task "settle S1 vs directedness and restore Saturation" (landed; its Phase 3 is the pattern generalized here)
**Sources/Inputs**: - Codebase (`FormalSystem/Semantics/**`, `scripts/**`, `docs/development/**`), lean-lsp MCP, `lake env lean` elaboration probe
**Artifacts**: - specs/663_hypothesis_honesty_lint_isregular_overbinding/reports/01_hypothesis-honesty-lint-isregular.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The measured starting point in the task description is stale in two ways, both verified.**
  `class IsRegular` is at `FormalSystem/Semantics/TaskFrame.lean:1170`, not `:1044`, and the
  instance-binder population is **258 occurrences across 47 files** (not 225/43) — the
  prerequisite task's own work added some. The four fields are unchanged: `comp`, `serial`,
  `limit`, `saturation`.
- **The independence-claiming residue is small, localized, and already legible in prose.** Of the
  258 occurrences, 200 are declaration binders with a docstring; only **16** of those even mention
  *Saturation*; and only **eight** make a Saturation-independence claim while carrying the class.
  Seven are in `FormalSystem/Semantics/Extension/Constraint.lean`, one in
  `FormalSystem/Semantics/Extension/Admissible.lean`. The flagship is `PartialHistory.constraint`
  (`Constraint.lean:528`), whose docstring says in bold "*Saturation* is **not** consumed" over an
  `[F.IsRegular]` binder.
- **The fix pattern is verified, not assumed.** A scratch file restating
  `nonempty_fib_of_serial` at `(hser, hlim)` and `nonempty_seg_of_interpolates` at
  `(hcomp, hlim)`, plus a one-line corollary at `F.serial F.limit` with the original signature,
  elaborates with **zero errors** under `lake env lean`. `TaskFrame.interpolates_of_comp` and
  `FrameOver.reflection_of_limit` are the two projections that make it work.
- **Recommended marker: a consumption enumeration, not an independence assertion.** A
  `Constraints consumed: ...` docstring line naming a closed vocabulary
  {Compositionality, Seriality, Limit, Saturation} subsumes the independence claim (a constraint
  absent from the list is claimed unconsumed) and, unlike a bare "independent of X" marker, also
  passes the sites that legitimately consume *Saturation* (`step`, `static_of_countable`,
  `extension`) without special-casing. Two docstrings in the tree already write an ad-hoc version
  of exactly this line.
- **Recommended gate: C34 in `scripts/check-module-invariants.sh`**, build-free and textual,
  reusing `scripts/lib/lean_citations.py`'s `decl_spans`, `scripts/lib/live_walk.py`'s walk, and
  `scripts/lib/lean_debug_artifacts.py`'s comment masker — all three already fixture-tested. Two
  assertions: (1) a marked declaration omitting *Saturation* from its list carries no `IsRegular`
  binder; (2) a binder-carrying declaration whose docstring trips the independence-prose heuristic
  but carries no marker fails, with "add a `Constraints consumed:` line" as the remedy. Assertion
  (2) is what keeps the opt-in marker from being silently bypassable.
- **A sorry-free path exists throughout.** No phase of this task needs `sorry`, a new axiom, or a
  deferral; the Lean work is seven restatements and seven one-line corollaries, each a strict
  generalization of an already-green proof.

## Context & Scope

Researched: (a) how to classify the 258 `IsRegular` instance-binder sites re-runnably; (b) which
of them are independence-claiming rather than legitimately ambient; (c) how a mechanical check
should recognize an independence claim, and where it and its convention should live.

Constraints honored: `IsRegular`'s fields are not touched; legitimately ambient binders
(soundness, validity, transfer) are not unbundled; the fix keeps every original signature so no
call site moves.

## Findings

### Codebase Patterns

**The established pattern, read from the committed prerequisite work.**
`FormalSystem/Semantics/Extension/Constraint.lean` now carries three matched pairs from the
prerequisite task's Phase 3:

| Explicit-hypothesis statement | Hypotheses it takes | One-line corollary (signature unchanged) |
|---|---|---|
| `fib_subset_fib_of_compositional` (:161) | `hcomp` | `fib_subset_fib_of_le_of_le` (:184) = `... F.comp` |
| `fib_subset_fib_of_compositional'` (:212) | `hcomp`, `hlim` | `fib_subset_fib_of_le_of_le'` (:240) = `... F.comp F.limit` |
| `seg_subset_seg_of_compositional` (:272) | `hcomp`, `hlim` | `seg_subset_seg` (:289) = `... F.comp F.limit` |

`FormalSystem/Semantics/Extension/Completion.lean:344`'s `extension_of_completion
(hser) (hlim) (hC) ...` is a third, independently-arrived-at attestation: a minimality claim
stated at explicit hypotheses with no binder at all.

Correction confirmed: `FrameOver.reflection` (`TaskFrame.lean:1356`) and `TaskFrame.reflection`
(`:2626`) are derived theorems carrying `[F.IsRegular]`, proved via `FrameOver.reflection_of_limit`
— not `FrameOver` fields. The explicit-hypothesis restatements therefore reach reflection as
`F.toFibre.reflection_of_limit hlim`.

**The eight sites that must be fixed (independence claim + bundling class).**

| Site | Claim in the statement, name or docstring | What the proof actually consumes |
|---|---|---|
| `Constraint.lean:250 fib_zero_subset` | Derived from the two already-honest fiber lemmas | `comp`, `limit` |
| `Constraint.lean:301 fib_zero_subset_of_mem_Constraints` | Same, plus `seg_eq_inter_fib` (axiom-free) | `comp`, `limit` |
| `Constraint.lean:332 nonempty_fib_of_serial` | "**Axioms consumed: *Seriality* and *Limit*.** … *Compositionality* and *Saturation* are not consumed." | `serial`, `limit` |
| `Constraint.lean:350 nonempty_seg_of_interpolates` | Name and docstring: "by the interpolation half of *Compositionality*" | `comp` (interpolation half), `limit` |
| `Constraint.lean:365 nonempty_of_mem_Constraints` | "discharged by *Seriality* and by the interpolation half of *Compositionality*" | `serial`, `comp`, `limit` |
| `Constraint.lean:409 exists_mem_subset_inter` | Directedness via `seg_subset_seg` / the fiber lemmas | `comp`, `limit` |
| `Constraint.lean:528 constraint` | "*Saturation* is **not** consumed… the accurate consumption list is `C→`, `C←`, `S`, `L` — and **not** `Sat`." | `comp` (both halves), `serial`, `limit` |
| `Admissible.lean:301 admissible` | "*Saturation* is not consumed." | `serial`, `limit` (via `nullity_of_serial_limit`), `fibers` |

`Constraint.lean:384 nonempty_Constraints` already carries no binder and needs no work.

**The sites that must NOT be touched (they genuinely consume *Saturation*).**
`Extension/Step.lean:191 step` (the sole elimination site, reading `F.saturation` directly),
`Extension/Extension.lean:197 isTotal_of_isMax`, `:228 extension`, `:249 isRestriction_of_isRegular`,
`Extension/Completion.lean:319 completion_of_isRegular`, and
`Correspondence/RigidityReal.lean:166 static_of_countable` ("The axioms consumed: *Saturation*
(through `thm:extension`…)"). These should be **marked**, not changed — marking them is what makes
the audit re-runnable at the honest sites too.

**A distinction the marker vocabulary must respect.** `isTotal_of_isMax`'s docstring says "this is
not a second *Saturation* elimination site" — true, and *not* an independence claim.
*Elimination* (spending the field on a conclusion that does not mention it) and *consumption*
(the elaborated proof term reaching the field at all) are different relations, and the tree
already uses both words precisely. The marker must enumerate **consumption**, which is what
`constraint`'s corrected docstring already does ("at the level of the elaborated proof term").

**Why prose pattern-matching cannot be the gate's judgment, only its trigger.** A sweep of the 200
binder-carrying declarations with a hand-tuned independence regex returns five hits, three of
which are false positives (`not_validOn_bot`, `class IsRegular` itself, `step`) and which miss
`constraint`, the flagship. Widened to "docstring mentions *Saturation*" it returns 16, of which
eight are the real defects. That ratio is fine for a **trigger** ("this declaration owes a marker")
and useless as a **verdict**.

**Binder-occurrence breakdown, for the audit record.** 258 bracketed occurrences; 200 are
declaration binders with a docstring; 2 are `variable` blocks; 0 are `haveI`/`letI`; the remainder
are binders on declarations without docstrings plus multi-binder signatures. Separately, **95**
declarations *conclude* `IsRegular` (instances and constructions) — these mention the class in the
conclusion, not as a hypothesis, and the gate's bracketed-binder regex must not catch them.

**`IsRegular` is the only bundling class of this kind.** 66 classes live under `FormalSystem/`;
the `TruthClauses` families are structural rather than axiomatic. Scoping the gate to `IsRegular`
is correct today, but the implementation should be table-driven over `(class, field-vocabulary)`
pairs so a second one costs a table row.

**Naming-collision hazard to record.** `FormalSystem/Metalogic/Independence/` means *logical*
independence of proof-system axioms, unrelated to constraint independence. Five binder sites live
there and are ambient. The marker's name should avoid the word "independence" for this reason —
another argument for `Constraints consumed:`.

### External Resources

No Mathlib search was needed: every projection the fix requires already exists in this tree.
`TaskFrame.forward_of_comp` (`TaskFrame.lean:905`), `TaskFrame.interpolates_of_comp` (`:911`) and
`FrameOver.reflection_of_limit` are the three that carry the whole pattern.

**Harness precedent for the gate.** `scripts/check-module-invariants.sh` runs C1–C33 (highest
allocated: **C33**), documented row-by-row in `docs/development/MODULE_INVARIANTS.md`. C26, C27,
C29, C30 and C32 are the textual, build-free, source-reading checks this one should be modelled
on; C29's recorded rationale — "a reason in a central file goes stale silently when the code it
covers moves, whereas a reason at the site moves with it" — is the direct precedent for choosing
an at-site marker over a central 258-row manifest.

**Reusable machinery, all already fixture-tested.**
`scripts/lib/lean_citations.py::decl_spans(lines)` returns each declaration's name, keyword line
and span, walking back past `@[...]` attribute lines into the `/--` docstring — exactly the span
this gate needs. `scripts/lib/live_walk.py::live_files` is the Boneyard-excluding walk.
`scripts/lib/lean_debug_artifacts.py::mask` / `comments_only` are the comment/string maskers C27,
C29, C30 and C32 share.

**Documentation siting.** `docs/development/REFERENCE_NORMAL_FORM.md` already defines three
docstring normal forms (bibliographic, paper anchor, module cross-reference), each gated (C15,
C31). The consumption line is a natural fourth form there, with the enforcement row added to
`docs/development/MODULE_INVARIANTS.md` alongside C33.

### Recommendations

**1. Marker convention — `Constraints consumed:` in the docstring.**

```
Constraints consumed: Seriality, Limit
```

A single line in the declaration's own `/--` block, values from the closed vocabulary
`{Compositionality, Seriality, Limit, Saturation}` (case-sensitive, comma-separated, `None`
permitted for a constraint-free result). Semantics: **the listed constraints are the whole of what
the elaborated proof term reaches; every unlisted one is claimed unconsumed.** Rationale over the
alternatives:

- Over a free-form independence assertion: it is *positive* information, so the honest
  *Saturation*-consuming sites (`step`, `static_of_countable`, `extension`) can carry it too and
  the audit record covers them instead of ignoring them.
- Over a Lean attribute (`@[hypothesis_honest]`): an attribute would need registering in
  `FormalSystem/Tactic/Attr.lean` and an environment-reading exe to query, which would put the
  gate in CI's "not-in-CI" bucket the way C2/C6/C24 already are. The docstring line is
  build-free and runs under `--no-build`, which is how CI invokes the harness. The attribute buys
  elaboration-time attachment; `decl_spans` already gives attachment-by-span, which is what C15
  and C20 rely on.
- Over a central `scripts/isregular-binder-audit.txt` manifest of 258 rows: rejected on C29's own
  recorded evidence about central reason files going stale.

Two docstrings already write an ad-hoc form of this line (`Constraint.lean:321` and `:498`,
"**Axioms consumed…**"); normalize both.

**2. Gate — C34 in `scripts/check-module-invariants.sh`, enforced, build-free.**

Two assertions plus one report:

- **C34a (gated).** For every declaration carrying a `Constraints consumed:` line whose list omits
  *Saturation*: the declaration's text **from its keyword line to the end of its span**, comment-
  masked, contains no `IsRegular`. Masking excludes the docstring, so the explanatory prose the
  pattern requires ("never the `IsRegular` instance") is not a self-failure; scanning to the end of
  the span rather than to `:=` also catches an in-proof `haveI : F.IsRegular`.
- **C34b (gated).** For every declaration carrying an `IsRegular` **binder** (bracketed match only,
  so the 95 `IsRegular`-concluding declarations are out of scope) whose docstring trips the
  independence-prose heuristic (mentions *Saturation* within a negation or a consumption
  enumeration) and carries **no** `Constraints consumed:` line: fail, with the remedy "add a
  `Constraints consumed:` line". This is the half that stops a new unmarked claim slipping past an
  opt-in marker. Its false positives cost one marker line each, never a redesign, because the
  heuristic only forces *marking* and never renders a verdict.
- **Report (never gated).** Total binder sites, marked sites, marked-and-*Saturation*-free sites,
  and unmarked binder sites — printed at every run. This is the re-runnable classification record
  scope (a) asks for; it replaces a 258-row manifest that nothing would keep current.
- **Anti-silence guard (exit 2, not suppressed by `ENFORCE_C34=0`)**, matching C29/C30/C31: zero
  markers found anywhere, or an empty walk, is a broken matcher, not a clean tree.
- Vocabulary and class list in a small table at the top of the check, so a second bundling class
  or a fifth constraint is a table row.

**3. Lean fix — seven restatements, seven corollaries, one file plus one declaration.**

Each of the eight sites above gets an explicit-hypothesis twin named on the established
`_of_<hypothesis>` convention, with the original kept as a one-line corollary at
`F.comp` / `F.serial` / `F.limit` and its statement and implicit-argument order unchanged, so no
call site moves. `Admissible.lean:301 admissible` is the only one outside `Constraint.lean`.

**Verified, not assumed.** A probe restating `nonempty_fib_of_serial` at `(hser, hlim)` and
`nonempty_seg_of_interpolates` at `(hcomp, hlim)`, with a corollary
`nonempty_fib_of_serial'' F.serial F.limit ht` at the original signature, elaborates with zero
errors:

```lean
theorem nonempty_fib_of_serial'' (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) {τ : PartialHistory F} {z t : F.Duration}
    (ht : τ.domain t) : (Fib F.TaskRel (τ.states t ht) (z - t)).Nonempty := by
  have hrefl := F.toFibre.reflection_of_limit hlim
  ...
```

The remaining five are strictly downstream compositions of already-honest lemmas plus
`interpolates_of_comp`, so they carry the least risk in the set.

**4. Documentation.** A fourth normal form in `docs/development/REFERENCE_NORMAL_FORM.md`
(vocabulary, the consumption-vs-elimination distinction, and the rule that an unlisted constraint
is a claim), plus a C34 row in `docs/development/MODULE_INVARIANTS.md`'s table in the established
"what it checks / why it exists" shape.

## Decisions

- **Marker is a consumption enumeration, not an independence assertion.** Subsumes the
  independence claim, covers the honest sites, and sidesteps the `Metalogic/Independence/`
  name collision.
- **Marker is a docstring line, not a Lean attribute.** Build-free is decisive: CI runs the
  harness `--no-build`, and an environment-reading check would join the recorded not-in-CI gaps.
- **Classification is recorded at the site plus a per-run census, not in a central manifest.**
  Follows C29's recorded rationale; a 258-row file would go stale silently.
- **The gate carries a prose-heuristic half (C34b).** Without it the marker is opt-in and a new
  unmarked claim is invisible. The heuristic forces marking only; it never judges honesty.
- **Scope stays `IsRegular`,** implemented table-driven. No other bundling class of this kind
  exists in the tree today.
- **No new `sorry` and no new axiom** at any point; every restatement is a strict generalization
  of a green proof.

## Risks & Mitigations

- **C34b false positives on legitimately ambient binders whose docstrings mention *Saturation*
  in passing.** Measured population: 16 of 200 binder sites mention *Saturation* at all, and all
  16 either are in the fix set or should be marked anyway. Mitigation: land C34b reporting-only
  for the first run, read the list, then flip `ENFORCE_C34` — the soft-then-enforced ladder C24
  and C9D already use.
- **Marker drift: a docstring edit moves the line away from its declaration.** Mitigated by
  reading the span through `decl_spans`, the same machinery whose drift-detection C20's
  declaration-span assertion was built on after 327 citations were found mis-anchored.
- **Over-correction into a blanket unbundling.** The task explicitly forbids it, and the audit
  bounds the fix set at eight declarations in two files. The plan should pin that file list and
  fail the phase if the diff reaches a third `Semantics/` file.
- **A restatement changing an implicit-argument order and moving call sites.** Mitigated by the
  corollary-with-unchanged-signature rule; verify with a diff that touches no file outside
  `Extension/`, plus `lake build` exit 0 and zero new warnings.
- **The prerequisite task's measured baseline is already stale (225→258, :1044→:1170).** The plan
  must re-measure at implementation time rather than quote this report's numbers as fixed.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `nonempty_fib_of_serial''` at explicit `(hser, hlim)` | structural (`rcases` / `obtain` / `rwa`) | success | `F.toFibre.reflection_of_limit hlim`, `TaskFrame.mem_Fib` |
| `nonempty_seg_of_interpolates''` at explicit `(hcomp, hlim)` | structural (`obtain` / `abel` / `rw`) | success | `TaskFrame.interpolates_of_comp hcomp`, `reflection_of_limit` |
| `nonempty_fib_of_serial_c` corollary at `[F.IsRegular]` | term-mode one-liner | success | `F.serial`, `F.limit` |

No automation tactic (`simp`, `omega`, `aesop`, `decide`) is applicable to this work: every goal
is a structural restatement of an existing proof with a projection substituted for a field access,
and the existing proofs are already minimal. `lean_multi_attempt` was therefore not used;
verification was by direct elaboration (`lake env lean` on a scratch file), which is the stronger
check.

## Context Extension Recommendations

- **Topic**: hypothesis-honesty as a repository convention.
  **Gap**: `context/project/lean4/` documents MCP tooling and hard-mode routing but has nothing on
  the statement-level honesty discipline this repo now enforces in two places
  (`Extension/Constraint.lean`, `Extension/Completion.lean`) and is about to enforce in a third
  (C34).
  **Recommendation**: a short `context/project/lean4/patterns/hypothesis-honesty.md` naming the
  explicit-hypothesis-plus-corollary pattern, the consumption-vs-elimination distinction, and the
  `Constraints consumed:` line, so a future dispatch reaches for it rather than rediscovering it.

## Appendix

**Verification commands run.**

- `grep -rcE '\[[^]]*IsRegular[^]]*\]' --include=*.lean FormalSystem/ Tests/` — 258 occurrences,
  47 files.
- Python scan over 10,811 docstring-bearing declarations → 200 with an `IsRegular` binder in the
  signature; 16 whose docstring mentions *Saturation*; 5 matching a hand-tuned independence regex.
- `lake env lean <scratch>/Probe.lean` — empty output (zero errors), backgrounded and waited on by
  `kill -0` liveness per `context/patterns/bounded-build-waiter.md`.
- `grep -noE 'C[0-9]{1,2}[A-Z]?' scripts/check-module-invariants.sh | sort -u` — highest allocated
  invariant is C33.

**Files read.**

- `FormalSystem/Semantics/TaskFrame.lean` (`:1170` class, `:1206`–`:1236` re-exports, `:905`/`:911`
  projections)
- `FormalSystem/Semantics/Extension/Constraint.lean` (whole)
- `FormalSystem/Semantics/Extension/{Step,Admissible,Extension,Completion}.lean` (claim regions)
- `FormalSystem/Semantics/Correspondence/RigidityReal.lean:150-182`
- `scripts/check-module-invariants.sh` (header flags, C32/C33 blocks, tail),
  `scripts/check-evidence-probes.sh`, `scripts/CheckInitImportsMain.lean`
- `scripts/lib/{lean_citations,live_walk,lean_debug_artifacts}.py`
- `docs/development/MODULE_INVARIANTS.md`, `docs/development/REFERENCE_NORMAL_FORM.md`
- The prerequisite task's plan and summary artifacts.
