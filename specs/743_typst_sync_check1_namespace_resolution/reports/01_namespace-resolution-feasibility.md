# Research Report: Task #743

**Task**: 743 - Teach typst-sync-check.sh Check 1 to resolve namespaced Lean declarations, or rule
on the whitelist-vs-docstring convention it currently depends on
**Started**: 2026-11-07T19:32:00Z
**Completed**: 2026-11-07T20:05:00Z
**Effort**: ~1 session (research only)
**Dependencies**: None
**Sources/Inputs**:
- `scripts/typst-sync-check.sh` (Check 1 and Check 4 resolvers, read in full)
- `typst/FormalFoundations.typ`, `typst/chapters/ax-lean-appendix.typ` (citation survey)
- `typst/sync-check-whitelist.txt` (266 entries at measurement)
- `FormalSystem/Semantics/IntTransfer.lean`, `FormalSystem/Metalogic/Decidability.lean`,
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`
- A disposable Python prototype run against the full `FormalSystem/` tree (not committed; lived
  only in the scratchpad)
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The gate is currently green (`bash scripts/typst-sync-check.sh` exits 0, all 4 checks), and the
  mechanism gap the dispatch describes is unchanged and still live: Check 1's dotted-identifier
  branch (`typst-sync-check.sh:704-708`) is a literal `grep -F` for the full dotted string, with
  no namespace parsing.
- Of the eight fully-qualified `` `FormalSystem.*` `` backtick spans currently in `typst/`, **seven
  are namespace names** (they always resolve, because the literal string `namespace X.Y.Z` is
  genuinely present in source) and **exactly one is a leaf-declaration citation**:
  `` `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` `` at
  `typst/FormalFoundations.typ:796`. It resolves today only because that exact string also
  happens to appear, verbatim, in an unrelated docstring at `FormalSystem/Metalogic/Decidability.lean:181`
  — the "accidental dependency" the dispatch names as the clearest remaining evidence.
- A build-free, regex-based namespace-stack resolver is feasible and was validated against the
  live `FormalSystem/` tree (16,773 declarations collected, sub-second runtime): it structurally
  resolves both the historical finding (`validZTime_iff_validInt`) and the current accidental one
  (`decidableValidZTime`) without needing either name to appear anywhere outside its own
  declaration site. This confirms **Option (a)** is implementable within the script's build-free
  constraint.
- Correctly implementing it requires comment/docstring-awareness: a naive line-start regex scan
  (no comment stripping) over-collects by ~1.3% (16,998 vs. 16,773 declarations) by matching
  keyword-shaped text inside `/- ... -/` block comments and docstrings. This is a real
  implementation requirement, not a hypothetical edge case — flagged for the plan.
- **Recommendation**: Option (a) (teach Check 1 real namespace resolution), added as a third,
  *additive* resolution path alongside the existing literal grep (never replacing it, since the
  literal grep is still the only way a Mathlib-style or cross-root dotted name — not declared in
  `FormalSystem`/`BimodalTools` — can resolve). Option (c) (status quo) is rejected on the
  evidence above. Option (b) (rule module-path-plus-leaf is the only sanctioned style) is recorded
  as the fallback if (a) is rejected at planning time for cost reasons, since it would require
  rewriting only one live citation.

## Context & Scope

This is a research-phase dispatch for a task whose own description already narrows the decision
to three routes (plus a fallback) and asks for either an implemented fix or a recorded verdict.
The job here is to (1) re-measure the current state against the dispatch's narrative, since the
dispatch itself records that the original repro stopped firing on 2026-10-10 while the mechanism
gap persisted, (2) assess the concrete feasibility of the routes the dispatch leaves open,
particularly Option (a) which the dispatch flags as uncertain ("resolution without a build means
parsing namespace/end nesting"), and (3) produce a recommendation and a concrete design the
planning phase can execute directly.

Non-goals carried over from the dispatch: no change to Check 2, Check 2b, or Check 3; no
generator-emission changes; the script's build-free property (no `lake`, no `.olean`) is
load-bearing and out of bounds to change.

## Findings

### Codebase Patterns

**Check 1's resolution branches** (`scripts/typst-sync-check.sh:669-708`), in order: whitelist
exact match, multi-word-span literal grep, path-like existence/suffix search (excl. `Boneyard/`),
and finally the bare-identifier/dotted-name branch at line 704-708, which is pure
`grep -rl --include=*.lean -F <name> ${LEAN_SRC_ROOTS} --exclude-dir=Boneyard`. There is no
namespace-aware branch anywhere in the script.

**`LEAN_SRC_ROOTS`** (`typst-sync-check.sh:79-82`) is `FormalSystem:BimodalTools`, colon-separated,
used by Check 1 only. This matters for design: a namespace-declaration index only needs to cover
these two trees (not Mathlib), and the existing literal-grep fallback remains the only way a
dotted name declared *outside* these roots (e.g. a Mathlib lemma merely *used* in this repo) can
still resolve — so any new structural resolver must be additive, not a replacement.

**Current citation survey** (backtick-quoted, fully-qualified `FormalSystem.*` spans, excluding
`typst/generated/`):

| Citation | Kind | Resolves today because |
|---|---|---|
| `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` | leaf declaration | accidental docstring match at `Decidability.lean:181` |
| `FormalSystem.ProofSystem.Axioms` | namespace | `namespace ... Axioms` string present verbatim |
| `FormalSystem.ProofSystem.DerivedAxioms` | namespace | ditto |
| `FormalSystem.ProofSystem` | namespace | ditto |
| `FormalSystem.Semantics.FrameClassValidity` | namespace | ditto |
| `FormalSystem.Syntax` | namespace | ditto |
| `FormalSystem.Metalogic.BXCanonical` | namespace | ditto |
| `FormalSystem.Metalogic.Conservativity` | namespace | ditto |

This corrects a detail in the dispatch narrative: it describes "two surviving fully-qualified
declaration citations" under Option (b); the measured count today is **one**. The other seven
listed citations are namespace names, not declaration leaves, and will resolve under the literal
grep regardless of whether Check 1 ever learns namespace resolution — a namespace-opening line
(`namespace FormalSystem.ProofSystem.Axioms`) is, by construction, a literal verbatim occurrence
of its own full dotted name. The structural gap only bites a citation of the form
`<namespace-path>.<declaration-leaf>`, and there is currently exactly one such citation in the
whole `typst/` tree. (Recorded as a minor dispatch-narrative-drift issue in the task's issue log.)

**The one live case's actual namespace structure** was confirmed by direct inspection:
`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:94,128,150,166`
opens `namespace FormalSystem.Metalogic.Decidability` then nests `namespace Compression`, and
declares `def decidableValidZTime` at line 147 — i.e. a **two-level nested `namespace` stack**,
not a single `namespace X.Y.Z` command. This is a harder case than the historical
`validZTime_iff_validInt` finding (a single `namespace FormalSystem.Semantics` at
`IntTransfer.lean:70`), and is good evidence that any resolver design must handle multi-level
nesting, not just a single dotted `namespace` statement.

**Check 4 has its own, separately duplicated resolver** (`typst-sync-check.sh:425-434`, inside
`run_check4_codeblocks`), with the identical literal-grep body as Check 1's `grep_lean`. It is
invoked for `#lean-code(source: ("module", "name"))` calls (`typst-sync-check.sh:471-477`), where
`name` is a bare leaf — `module` is supplied as a separate string, not assembled into a dotted
path. Check 4 therefore does not suffer this exact defect today (it never constructs or resolves
a dotted fully-qualified string), and the task's own title scopes this work to "Check 1"
specifically — so Check 4 is correctly out of scope here, but its resolver would face the same
risk if a future `#lean-code` call ever cited a dotted leaf name. Noted under Context Extension
Recommendations below rather than fixed.

### External Resources

Not applicable — this is a pure codebase-mechanics question with no external library or
documentation dependency.

### Feasibility Prototype (Option (a))

A disposable Python script (not committed; scratchpad-only) was run twice against the live
`FormalSystem/` tree to validate a namespace-stack resolver design, build-free (regex/text only,
no `lake`):

1. **Naive version** (line-start regex matching `namespace`/`end`/declaration keywords, no
   comment awareness): found both target names correctly, but collected 16,998 total
   declarations.
2. **Comment-aware version** (same logic, but each line is first stripped of `--` line comments
   and `/- ... -/` block-comment spans, including nested `/- -/`, before regex matching): also
   found both target names correctly, but collected 16,773 declarations — a ~1.3% (225-entry)
   reduction, confirming the naive version was picking up keyword-shaped text inside docstrings
   or block comments as spurious declarations.

Both versions correctly resolved:
- `FormalSystem.Semantics.validZTime_iff_validInt` -> `FormalSystem/Semantics/IntTransfer.lean:338`
- `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` -> `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:147`

Runtime for either version over the full tree (~900 `.lean` files, 16.7k+ declarations) was
sub-second, well within a build-free pre-commit gate's budget.

**Design implication**: the comment-aware version is the one to implement — the naive version's
~1.3% false-positive rate, while it happened not to produce an incorrect *resolution* in this
sample, is not a safe property to rely on in general (a docstring that happens to say, at
line-start, something shaped like `theorem foo_bar ...` inside the *wrong* open-namespace context
could produce a wrong fully-qualified name that coincidentally matches a bogus citation).

## Recommendations

**Adopt Option (a): teach Check 1 real namespace resolution**, as a third resolution path for the
bare-identifier/dotted-name branch, added *alongside* (not replacing) the existing literal grep:

1. For each `.lean` file under `LEAN_SRC_ROOTS` (excl. `Boneyard/`, matching every other Check 1
   branch's exclusion), strip `--` line comments and `/- ... -/` block comments (track nesting
   depth; Lean allows nested block comments) before any regex matching.
2. Track a namespace stack per file: push on `namespace X.Y.Z` (split on `.`), pop on `end X.Y.Z`
   only when the given name exactly matches the current stack top (LIFO, mirroring Lean's own
   `namespace`/`end` pairing rule — a single `namespace` command's `end` must repeat that
   command's exact argument). Do not track `section` as a namespace-affecting construct.
3. On a declaration keyword at line start (`theorem`, `lemma`, `def`, `abbrev`, `instance`,
   `structure`, `inductive`, `class`, `axiom`, optionally preceded by `@[...]`, `private`,
   `protected`, `noncomputable`, `scoped`), extract the identifier and join it to the current
   namespace stack to form the declaration's fully-qualified name. (The identifier itself may
   already be dotted if a declaration supplies an explicit prefix without an enclosing
   `namespace` — not observed in this codebase today, but the join logic handles it unchanged:
   `stack + '.' + local_name_as_given`.)
4. Build this index once per Check 1 run (reusing `LEAN_SRC_ROOTS`); a dotted candidate resolves
   if it is a key in the index, **or** (unchanged) the existing literal grep succeeds — this keeps
   every currently-passing case passing and adds coverage for the structural case without
   narrowing anything.
5. State the mechanism's documented limit where the next citation author will see it: a comment
   immediately above this branch in `typst-sync-check.sh` plus a short note in
   `typst/sync-check-whitelist.txt`'s header, saying namespace resolution covers only
   declarations under `FormalSystem/`/`BimodalTools` reachable via literal `namespace`/`end`
   nesting — a name declared only through other mechanisms (e.g. `export`, `open ... in`
   one-liners, or any identifier from outside those two roots) still depends on the literal grep
   and, failing that, the whitelist.

This satisfies the task's ACCEPTANCE criteria directly (`bash scripts/typst-sync-check.sh` keeps
exiting 0, and the one live citation now resolves structurally rather than by accident), is
consistent with the NON-GOALS (build-free preserved; Checks 2/2b/3 untouched; no generator
changes), and removes the recurring-finding risk the dispatch's reproduction recipe names (any
future namespaced citation whose dotted form is not independently mentioned in a docstring will
now resolve correctly instead of failing).

**Fallback if Option (a) is rejected at planning time** (e.g. judged too much parsing complexity
for a pre-commit gate): Option (b) — rule that the manual's citation convention is
module-path-plus-leaf (the style the commit already moved the historical citation to), document
it, and bring the one surviving fully-qualified leaf citation
(`` `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` ``) into that same style
by rewriting it in `typst/FormalFoundations.typ:796`. This is cheap (one citation) precisely
because the earlier survey shows only one exists today; it was not cheap in the dispatch's
original framing (which believed two existed).

**Explicitly rejected: Option (c)** (keep the literal grep, accept docstring-coincidence
dependency) — this is the status quo that produced the original recurring finding, and the
dispatch's own evidence (the sole surviving citation resolving by an unrelated docstring's
accident) argues directly against it. If the plan nonetheless whitelists the name instead of
fixing the mechanism, ACCEPTANCE requires saying explicitly that the whitelist entry suppresses a
resolution gap rather than certifying the name — do not add it silently.

**Not recommended as primary, but noted**: the dispatch's "fourth" fallback (add the
fully-qualified cross-reference to `IntTransfer.lean`'s own module docstring) is unnecessary if
Option (a) is adopted, and was already partially how the *other* citation resolves today by
accident — formalizing that pattern as the chosen mechanism would be choosing Option (c) by
another name.

## Decisions

- **Recommended route: Option (a)**, implemented as an additive third resolution path in Check 1's
  dotted-identifier branch, comment/docstring-aware, scoped to `LEAN_SRC_ROOTS`.
- **Rejected: Option (c)** (status quo literal-grep-only), on the evidence above.
- **Fallback, if (a) is rejected on cost grounds: Option (b)**, rewriting the single surviving
  leaf citation to module-path-plus-leaf style and documenting the convention.
- **Out of scope, flagged for a possible separate task**: Check 4's duplicate `grep_lean`
  resolver, which does not share this exact defect today but shares the underlying
  literal-grep-only pattern.

## Risks & Mitigations

- **Parsing edge cases** (sections nested inside namespaces, re-opened namespaces across multiple
  files, an `end` that doesn't exactly repeat its `namespace` command's argument) — mitigated by
  validating the prototype against the full live tree (16,773 declarations, both target names
  resolved correctly) rather than a synthetic sample; the planner should keep this validation
  step (run the resolver over the full tree and diff declaration counts against a comment-aware
  vs. naive pass) as an implementation acceptance check.
- **False positives from comment text** — demonstrated concretely (the naive prototype's 225-entry
  over-collection); mitigated by requiring the comment-stripping step as part of the design, not
  an optional refinement.
- **Scope creep into Check 4** — explicitly avoided; Check 4's resolver is structurally different
  (module and leaf given separately, no dotted-string assembly) and is not touched by this
  recommendation.
- **Runtime budget for the pre-commit gate** — validated as sub-second over the full tree; not a
  real risk.

## Context Extension Recommendations

- **Topic**: Check 4's `#lean-code(source: (module, name))` resolver duplicates Check 1's
  literal-grep `grep_lean` body independently (`typst-sync-check.sh:425-434` vs. `:625-634`).
- **Gap**: no context file documents that these two resolvers are separate, un-shared
  implementations of the same idea — a future change to one is easy to apply without realizing
  the other exists.
- **Recommendation**: if Option (a)'s namespace index is implemented for Check 1, consider (as a
  separate, later task — not this one) factoring both `grep_lean` bodies and any new namespace
  index into one shared Python module invoked by both checks, so a future fix doesn't have to be
  applied twice. Not acted on here: out of this task's stated scope (title names "Check 1" only).

## Appendix

**Commands run**:
- `bash scripts/typst-sync-check.sh` (confirmed current green state, all 4 checks)
- `grep -rno '` `` `FormalSystem\.[A-Za-z0-9_.]*` `` '` typst --include=*.typ` (citation survey,
  excluding `typst/generated/`)
- `grep -n "^namespace\|^end" FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`
  (confirmed the two-level nested namespace structure)
- Two disposable Python prototypes (naive and comment-aware namespace-stack resolvers) run against
  the full `FormalSystem/` tree; not committed to the repo.

**References**:
- `scripts/typst-sync-check.sh:669-708` (Check 1's resolution branches)
- `scripts/typst-sync-check.sh:425-434,471-477` (Check 4's separate resolver)
- `FormalSystem/Semantics/IntTransfer.lean:70,338,353`
- `FormalSystem/Metalogic/Decidability.lean:181`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:94,128,147,150,166`
- `typst/FormalFoundations.typ:796,1082-1083`
- `typst/chapters/ax-lean-appendix.typ:140,142,1024,1146`
