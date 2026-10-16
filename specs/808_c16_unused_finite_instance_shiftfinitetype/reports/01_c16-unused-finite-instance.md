# Research Report: Task #808

**Task**: 808 - Fix the C16 env_linter failure: unused `[Finite F.WorldState]` on `FrameOver.mem_HF_iff_no_forbidden`
**Started**: 2026-10-16T00:00:00Z
**Completed**: 2026-10-16T00:00:00Z
**Effort**: Small (single-binder signature edit plus one docstring paragraph; one full guarded build and one gate run dominate the cost)
**Dependencies**: None
**Sources/Inputs**:
- `FormalSystem/Semantics/ShiftFiniteType.lean` (the declaration and its module docstring)
- `FormalSystem/Semantics/ShiftFiniteTypeDictionary.lean`
- `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean` (pinned axiom-profile guard blocks)
- `scripts/check-module-invariants.sh` (C3, C14, C16, C20, C26), `scripts/nolints.json`, `scripts/nolint-attribute-allowlist.txt`
- `docs/theorem-index.md`, `docs/reference/paper-definitions-of-record.md`, `FormalSystem/Semantics/README.md`
- Live evidence: `lake exe runLinter FormalSystem` (via `lake-build-guard.sh`), `lean_references`, `lean_run_code` compiled probe
**Artifacts**:
- `specs/808_c16_unused_finite_instance_shiftfinitetype/reports/01_c16-unused-finite-instance.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The finding is exactly one argument and it is genuinely dead.** `lake exe runLinter FormalSystem`
  reproduces a single error: `FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden 1 unused
  argument: argument 3: [Finite F.WorldState]`. `[F.IsRegular]` (argument 2) is *not* reported, so it
  is used; nothing else in the 16736-declaration sweep is flagged.
- **There are no call sites at all, so the "load-bearing binder" escape hatch does not apply.**
  `lean_references` on the declaration returns `total: 1` — the declaration itself. A repository-wide
  `grep` over every `*.lean` finds only docstring prose plus one `#print axioms` command; there is no
  term-level application of this theorem anywhere in `FormalSystem/`, `Tests/`, or evidence probes.
- **A compiled probe confirms the signature edit is safe and axiom-neutral.** The same proof script
  elaborates and closes with the binder absent, and `#print axioms` on the probe reports
  `[propext, Classical.choice, Quot.sound]` — identical to the profile pinned by the `#guard_msgs`
  block at `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean:173-178`. That pin
  stays green without edit.
- **Recommended approach: drop the binder, rewrite one docstring paragraph, re-verify.** Do not add a
  `scripts/nolints.json` entry (the call-site evidence does not justify one) and do not use an
  in-source `@[nolint unusedArguments]` (C26 gates those behind
  `scripts/nolint-attribute-allowlist.txt` at a stated "PERMANENT DOCUMENTED EXEMPTION" admission bar
  that this case cannot clear).
- **One authoring trap to carry into the plan**: the rewritten docstring is a deliverable under
  `FormalSystem/`, so `no-record-versioning-in-deliverables.md` applies. It must state the current
  design outright and must not say the binder was "previously" carried, is "no longer" carried, or
  was "removed".
- **Zero-debt posture**: no `sorry`, no new axiom, no vacuous definition, and no plan decomposition
  is needed. The resulting theorem is strictly *more* general than the current one.

## Context & Scope

`scripts/check-module-invariants.sh` exits 1 today on a single group:

```
FAIL  C16  env_linter batch reports new finding(s) beyond scripts/nolints.json's grandfathered baseline
```

C16 (`scripts/check-module-invariants.sh:3277-3287`, `ENFORCE_C16` defaults to 1) runs
`lake exe runLinter FormalSystem`, which reads `scripts/nolints.json` itself and filters every
grandfathered declaration before deciding pass/fail. Every other invariant group passes, including
both `C1 lake build` groups.

Scope permitted by the dispatch: `FormalSystem/Semantics/ShiftFiniteType.lean`, and
`scripts/nolints.json` only if the baseline genuinely needs an entry. Explicitly forbidden:
`lake exe runLinter --update`.

The research question the dispatch poses is specific — *is the instance binder load-bearing at some
call site for unification?* — and it is answered negatively below with three independent kinds of
evidence.

## Findings

### Codebase Patterns

**The declaration.** `FormalSystem/Semantics/ShiftFiniteType.lean:181`:

```lean
theorem mem_HF_iff_no_forbidden (F : FrameOver intOrder) [F.IsRegular] [Finite F.WorldState]
    (f : ℤ → F.WorldState) :
    (∃ τ : WorldHistory F, τ.path = f) ↔ ∀ n : ℤ, ¬ Forbidden F (f n) (f (n + 1)) := by
  rw [F.mem_HF_iff_adjacent_int f]
  constructor
  · intro h n hn
    exact hn (h n)
  · intro h n
    exact Classical.not_not.mp (h n)
```

The linter reports position `149:1` because that is where the declaration's doc comment begins; the
binder itself is on line 181.

**Reproduction of the finding.** `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- exe
runLinter FormalSystem` (detached, guard `exit_status=1`):

```
Running linter on specified modules: [FormalSystem]
-- Found 1 error in 16736 declarations (plus 25707 automatically generated ones) in FormalSystem with 14 linters

/- The `unusedArguments` linter reports:
UNUSED ARGUMENTS.
This linter can be disabled with `@[nolint unusedArguments]`. -/
-- FormalSystem.Semantics.ShiftFiniteType
.../FormalSystem/Semantics/ShiftFiniteType.lean:149:1: error: FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden 1 unused argument:
  argument 3: [Finite F.WorldState]
```

Two things worth reading off this output: the finding is a **single** argument on a **single**
declaration (no second regression hiding behind it), and `[F.IsRegular]` is not among the unused
arguments, confirming the `rw [F.mem_HF_iff_adjacent_int f]` step consumes it.

**Call-site evidence (the dispatch's decisive question).** Three independent probes, all negative:

| Probe | Result |
|---|---|
| `lean_references` at `ShiftFiniteType.lean:181:9` | `total: 1` — the declaration site only |
| `grep -rn "mem_HF_iff_no_forbidden" --include=*.lean .` | 11 hits, **zero** term applications |
| Does any declaration in `ShiftFiniteTypeDictionary.lean` carry `[Finite F.WorldState]`? | No — `grep -n "Finite" ` on that file matches only its `import` line and one prose line |

The 11 Lean hits break down as: 4 docstring-prose mentions in `ShiftFiniteType.lean` itself
(lines 38, 53, 97, and the signature at 181), 1 docstring-prose mention in
`ShiftFiniteTypeDictionary.lean:25`, and 6 in
`Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean` — of which five are prose or
expected-output text and the sixth, line 178, is `#print axioms
FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden`. A `#print axioms` command names a
declaration without applying it and supplies no instance arguments, so it is insensitive to the
binder count.

`ShiftFiniteTypeDictionary.lean` is the one module that might plausibly have consumed the
identification; it does not. Its own `←` direction redoes the double-negation elimination
independently (its docstring at line 25 says so), and it carries no finiteness hypothesis.

**Compiled probe that the edit elaborates.** Run standalone against the built library:

```lean
import FormalSystem.Semantics.ShiftFiniteType
open FormalSystem.Semantics FormalSystem.Semantics.FrameOver TaskFrame

theorem probe_mem_HF_iff_no_forbidden (F : FrameOver intOrder) [F.IsRegular]
    (f : ℤ → F.WorldState) :
    (∃ τ : WorldHistory F, τ.path = f) ↔ ∀ n : ℤ, ¬ Forbidden F (f n) (f (n + 1)) := by
  rw [F.mem_HF_iff_adjacent_int f]
  constructor
  · intro h n hn
    exact hn (h n)
  · intro h n
    exact Classical.not_not.mp (h n)

#print axioms probe_mem_HF_iff_no_forbidden
```

Result: compiles clean, and

```
'probe_mem_HF_iff_no_forbidden' depends on axioms: [propext, Classical.choice, Quot.sound]
```

This is the *same* profile the test file pins for the real declaration. The unused binder contributed
nothing to the proof term, which is precisely why the linter can see it is dead: `Classical.not_not`
is the sole source of `Classical.choice` here, and `Set.toFinite` (the one consumer of
`[Finite F.WorldState]` in this module) lives in the separate `finite_forbiddenBlocks`.

**Why the binder exists, and why the module docstring already argues against it.** The declaration's
own docstring, `ShiftFiniteType.lean:159-160`, says:

> The identification itself holds at *any* carrier; `[Finite W]` is carried here only so the
> statement reads as the specification does, and it is the finiteness theorem above that uses it.

But the module docstring, `ShiftFiniteType.lean:38-43`, states the opposite design intent for the
two-theorem split:

> Folding the second into the first would hide which hypothesis buys which half — the identification
> holds at *any* carrier, finite or not, and only the finite-type claim needs `[Finite W]`.

Carrying a vestigial `[Finite W]` on the identification is exactly the hiding the module docstring
says the split exists to prevent. The signature edit therefore *resolves* an internal inconsistency
rather than trading one off against the linter. The specification sentence this module transcribes
("When $W$ is finite and $D = \Z$ …") is still fully delivered by the pair: `finite_forbiddenBlocks`
discharges the "when $W$ is finite" clause, which is the half that needs it.

**Baseline shape.** `scripts/nolints.json` holds 220 entries, every one of them
`["unusedArguments", "<decl>"]`. None names anything in `ShiftFiniteType.lean`. (The script's prose
header says "217 findings"; the real count is 220. No check asserts the number, so this is harmless
header drift and not in scope here.)

### External Resources

No Mathlib lemma search was required: the task is a binder-deletion on a locally-proved theorem whose
proof script is four lines and already in the tree, and the only Mathlib-side dependency
(`Classical.not_not`) is unchanged by the edit. No `leansearch`/`loogle`/`leanfinder` queries were
issued, so no rate limits were touched and no MCP fallback was needed.

Relevant local gate documentation consulted instead:

- `scripts/check-module-invariants.sh:629-637` — C16's definition and `ENFORCE_C16=1` default
- `scripts/check-module-invariants.sh:3182-3287` — the `lake exe runLinter FormalSystem` invocation
- `scripts/check-module-invariants.sh:1263-1271` — C3, the structural sorry inventory (the canonical
  "sorry count is zero" measurement; a raw `grep` for the word `sorry` under `FormalSystem/` returns
  379 hits, nearly all of them prose like "sorry-free" in docstrings, and is **not** the measurement
  the deliverable refers to)
- `scripts/nolint-attribute-allowlist.txt` — C26's gate on in-source `@[nolint …]` attributes

### Recommendations

**Recommended: drop the binder (a sorry-free, axiom-neutral, strictly-generalising edit).**

1. Edit `FormalSystem/Semantics/ShiftFiniteType.lean:181` to
   `theorem mem_HF_iff_no_forbidden (F : FrameOver intOrder) [F.IsRegular]` followed by the unchanged
   `(f : ℤ → F.WorldState)` line. Leave the proof body alone — the probe shows it closes as written.
2. Rewrite the docstring paragraph at lines 159-160 so it states the current design: the
   identification is stated at any carrier, and the finite-carrier hypothesis sits on
   `finite_forbiddenBlocks`, where the specification's finiteness clause is discharged. **Comply with
   `no-record-versioning-in-deliverables.md`**: no "no longer", "previously", "formerly", or
   "removed" phrasing, and no narration of the signature's own history.
3. Re-read the module docstring's "*Saturation* needs no separate work here" section
   (lines 65-69). Its sentence "the finite-carrier hypothesis **below** buys the finite-type half"
   should be checked to make sure it unambiguously points at `finite_forbiddenBlocks` once that is the
   module's only finiteness-hypothesis-bearing declaration. This may need no change at all; verify
   rather than assume.
4. Leave `scripts/nolints.json` untouched. Leave the `#guard_msgs` blocks in
   `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean` untouched.
5. Verify in this order, each build detached through `lake-build-guard.sh` with an explicit
   `--timeout` per `context/project/lean4/operations/long-builds.md`:
   - scoped: `-- build FormalSystem.Semantics.ShiftFiniteType`
   - `-- exe runLinter FormalSystem` → expect `-- Found 0 errors` / exit 0
   - full: `-- build` → exit 0
   - `-- build BimodalTest` (the pinned `#print axioms` guard blocks live in the test library)
   - `bash scripts/check-module-invariants.sh` → exit 0

**Rejected: a `scripts/nolints.json` entry.** The dispatch permits it only "if the binder turns out to
be load-bearing at a call site". It is not load-bearing at any call site, because there are no call
sites: `lean_references` reports `total: 1`, the repository-wide grep finds no application, and the
compiled probe elaborates the statement without it. Adding a baseline entry would record a dead
argument as permanent debt when a four-character deletion removes it.

**Rejected: in-source `@[nolint unusedArguments]`.** The linter's own message advertises this route,
but C26 in this repository turns an in-source attribute into a *reviewable line* by requiring an entry
in `scripts/nolint-attribute-allowlist.txt`, whose header sets the admission bar at a "PERMANENT
DOCUMENTED EXEMPTION … the reason must say why THIS declaration cannot conform". No such reason
exists here — the declaration conforms trivially once the binder goes — and the allowlist file is
outside the dispatch's permitted scope anyway.

**Rejected: `lake exe runLinter --update`.** Forbidden by the dispatch, and correctly so: it rewrites
the whole baseline and would grandfather this regression wholesale.

**Not considered: adding `[DecidableRel F.step]`.** The declaration's docstring already records that
this is deliberately not done because it would weaken the theorem for the sake of its axiom profile.
It is also irrelevant to C16.

## Decisions

- **The signature edit is the route, not a baseline entry.** Decided on the call-site evidence the
  dispatch itself named as the deciding test, with three independent negative probes.
- **The proof body is not touched.** The compiled probe shows the existing four-line script closes the
  binder-free statement unchanged, so there is no proof-engineering step in this task.
- **The pinned axiom-profile guard blocks are not touched.** The probe's `#print axioms` output
  matches the pin exactly.
- **Doc fan-out is limited to `ShiftFiniteType.lean`'s own docstrings.** `docs/theorem-index.md:341`,
  `docs/reference/paper-definitions-of-record.md:2587`, `FormalSystem/Semantics/README.md:37`, and
  `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean`'s prose all describe this
  theorem without asserting anything about its finiteness binder, so none of them goes stale. Each
  was read to confirm this rather than assumed.
- **No user decision is required.** The dispatch pre-committed the preference order, and the evidence
  resolves it unambiguously in favour of the edit.

## Risks & Mitigations

- **Risk: a public signature change breaks a downstream elaboration this research missed.**
  Mitigation: the three negative call-site probes above, plus the mandatory full `lake build` and
  `lake build BimodalTest` in the verification sequence. Residual risk is low but non-zero — a
  `simp`/`aesop`/`exact?` call that happened to pick this lemma up by unification would not appear in
  a name grep. The full build is what catches that, which is why it is a deliverable and not optional.
- **Risk: the docstring rewrite trips `no-record-versioning-in-deliverables.md`.** This is the single
  most likely way the task goes red on a gate that has nothing to do with C16. `FormalSystem/**` is a
  deliverable path and the natural way to write the replacement sentence ("`[Finite W]` is no longer
  carried here") is exactly the forbidden form. Mitigation: write the paragraph as a plain statement
  of the current design and re-read it against the rule before committing.
- **Risk: docstring reflow shifts line numbers and breaks a line-anchored citation.** Checked and
  cleared: `grep -rn "ShiftFiniteType\.lean:[0-9]"` over `*.md`/`*.lean`/`*.txt`/`*.json`/`*.sh`/`*.typ`
  outside `specs/` returns nothing. The only `ShiftFiniteType.lean:149` citations live in
  `specs/TODO.md`, `specs/ROADMAP.md`, `specs/state.json`, and an earlier task's artifacts — all in
  the `specs/**` exemption zone, and none read by C20 or `check-phantom-citations.sh`.
- **Risk: `specs/ROADMAP.md:198-203` still describes this task as "red right now".** That stanza
  becomes stale once the gate is green. It is a `specs/**` file, outside the Lean edit scope, and
  ordinarily handled by the orchestrator's roadmap regeneration — flagged here so the implementation
  phase does not treat it as a surprise.
- **Risk: full-build cost.** A full `lake build` in this repository is expensive and
  `SubformulaProperty.lean` alone has been measured at 1103s on a guarded full build. This task
  touches a leaf-ish `Semantics` module with one known importer
  (`ShiftFiniteTypeDictionary.lean`), so the rebuild should be far cheaper than a syntax- or
  proof-system-layer edit — but the verification sequence must still be run detached with a bounded
  waiter, never as a foreground `lake build`.
- **Risk: a competing unguarded `lake` process.** Per `rules/lean4.md`, an unexplained build failure
  during concurrent work may be guard bypass by another process rather than a regression from this
  edit. Mitigation: check for a competing `lake` before attributing a failure to the binder deletion.

## Tactic Survey Results

Not applicable in the usual sense — no open proof goal exists in this task, so no tactic portfolio was
surveyed and `lean_multi_attempt` / `lean_hammer_premise` were not invoked. The one tactic-level
question (does the existing four-line script still close the goal at the weaker hypothesis set?) was
answered by a compiled `lean_run_code` probe instead, which is stronger evidence than a tactic attempt
at a position:

| Goal | Probe | Result | Notes |
|------|-------|--------|-------|
| `mem_HF_iff_no_forbidden` stated without `[Finite F.WorldState]` | `lean_run_code`, existing proof script verbatim | success | `rw [F.mem_HF_iff_adjacent_int f]` + `constructor` + `Classical.not_not.mp`, unchanged |
| Axiom profile of that probe | `#print axioms` | `[propext, Classical.choice, Quot.sound]` | identical to the `#guard_msgs` pin at `EffectivePeriodicExtensionAxiomTest.lean:173-178` |

## Context Extension Recommendations

- **Topic**: Resolving a Batteries `unusedArguments` finding — the decision procedure between a
  signature edit, a `scripts/nolints.json` entry, and an in-source `@[nolint]` attribute.
- **Gap**: The three routes are documented in three different places with three different
  admission bars (`check-module-invariants.sh`'s C16 header, `scripts/nolints.json` itself, and
  `scripts/nolint-attribute-allowlist.txt`'s header). Nothing states the preference order or the
  evidence standard that selects among them, so each occurrence re-derives it.
- **Recommendation**: a short `context/project/lean4/patterns/unused-argument-resolution.md` recording
  the order (signature edit > baseline entry > in-source attribute), the decisive test (no call site
  under `lean_references` **and** a compiled probe at the weaker signature ⇒ edit), the
  `lake exe runLinter --update` prohibition, and the reminder that the accompanying docstring rewrite
  falls under `no-record-versioning-in-deliverables.md`.

## Appendix

### Commands and probes used

```bash
# Reproduce the C16 finding (detached, guarded)
bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- exe runLinter FormalSystem
#   -> guard exit_status=1; "-- Found 1 error in 16736 declarations ... with 14 linters"
#   -> ShiftFiniteType.lean:149:1: FrameOver.mem_HF_iff_no_forbidden 1 unused argument:
#        argument 3: [Finite F.WorldState]

# Call-site sweep
grep -rn "mem_HF_iff_no_forbidden" --include=*.lean .        # 11 hits, 0 applications
grep -n  "Finite" FormalSystem/Semantics/ShiftFiniteTypeDictionary.lean   # import + prose only
grep -rn "ShiftFiniteType\.lean:[0-9]" --include=*.md --include=*.lean \
         --include=*.txt --include=*.json --include=*.sh --include=*.typ . # specs/** only

# Baseline shape
python3 -c "import json; d=json.load(open('scripts/nolints.json')); \
  print(len(d), sorted(set(e[0] for e in d)))"               # 220 ['unusedArguments']

# Provenance
git log -1 --format='%h %ad %s' -- FormalSystem/Semantics/ShiftFiniteType.lean
#   -> 250a74ae0 Thu Oct 15 18:04:19 2026 -0700
```

### MCP tools used

- `lean_references` at `FormalSystem/Semantics/ShiftFiniteType.lean:181:9` → `{"total": 1}`
- `lean_run_code` → the binder-free probe above, `success: true`, one `info` diagnostic
- No search tool (`leansearch`, `loogle`, `leanfinder`, `state_search`, `hammer_premise`) was needed,
  so no rate limit was approached and no fallback path was exercised.
- No blocked tool (`lean_diagnostic_messages`, `lean_file_outline`) was called.

### Evidence tier

`lean-lsp` was registered and reachable for this dispatch; `lean_references` returned a populated
result and `lean_run_code` compiled against the built library, so the call-site conclusion rests on
LSP-backed lookup corroborated by a compiled probe and a repository-wide grep, not on a degraded
index.

### Key file references

| Fact | Location |
|---|---|
| The flagged declaration | `FormalSystem/Semantics/ShiftFiniteType.lean:181` |
| The docstring sentence to rewrite | `FormalSystem/Semantics/ShiftFiniteType.lean:159-160` |
| Module docstring on which half needs `[Finite W]` | `FormalSystem/Semantics/ShiftFiniteType.lean:38-43` |
| "*Saturation*" section to re-read | `FormalSystem/Semantics/ShiftFiniteType.lean:65-69` |
| The only consumer of `[Finite F.WorldState]` in the module | `FormalSystem/Semantics/ShiftFiniteType.lean:145-147` (`finite_forbiddenBlocks`) |
| Pinned axiom profile | `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean:173-178` |
| C16 definition and enforcement default | `scripts/check-module-invariants.sh:629-637`, `:3182-3287` |
| C3 structural sorry inventory | `scripts/check-module-invariants.sh:1263-1271` |
| In-source `@[nolint]` gate | `scripts/nolint-attribute-allowlist.txt` |
