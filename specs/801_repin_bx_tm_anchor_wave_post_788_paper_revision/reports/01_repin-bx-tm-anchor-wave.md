# Seed Report: The Live BX/TM Anchor Drift Wave

- **Task**: 801 - Re-pin the BX/TM anchor wave in paper-definitions-of-record.md after the paper's post-788 revision, and verify in-tree axiom-membership prose matches
- **Started**: 2026-10-15T04:16:05Z
- **Completed**: 2026-10-15T04:16:05Z
- **Effort**: seed only (single measurement pass; not a substitute for the task's own research round)
- **Dependencies**: 791, 793
- **Sources/Inputs**:
  - `scripts/check-paper-definitions.sh` (full run, live working tree)
  - `docs/reference/paper-definitions-of-record.md` (2454 lines at measurement time)
  - `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (3998 lines, sha256 `553adb3178c096d9...`)
  - `scripts/check-module-invariants.sh` (C15, C35 definitions)
  - `FormalSystem/`, `docs/` (in-tree citation counts)
- **Artifacts**: this report
- **Standards**: report-format.md, artifact-formats.md, status-markers.md

## Executive Summary

- The gate is red: `scripts/check-paper-definitions.sh` exits **1** with **10** drifted anchors, measured at authoring time against the live working tree.
- The live wave is **10 anchors, not the 4** the task description names. The description already anticipated this and instructs absorbing whichever wave is live, so this is confirmation rather than a scope change.
- The 10 split into **three tiers of very different cost**. Only 4 anchors carry the judgment pass the task describes as its real content; 1 is a citation-only re-pin and 5 are mechanical or out-of-subsystem.
- The central substantive finding: **`def:BX` lost eight schemata** and **`NB` moved out of BX into `def:TMplus`**. That is precisely the axiom-membership shift the task exists to audit, now located concretely.
- **Four anchors have zero in-tree citations** (`def:id`, `def:strongest`, `thm:exist`, `lem:uniq`). They are objective-modality material this repository does not formalize, so they re-pin mechanically — but they fall outside BX/TM, where the task's own non-goal requires an explicitly recorded decision.
- **The paper is dirty at measurement time** and its repository HEAD is `5736a967`. Every hash in this report is a snapshot to re-derive at implementation time, not a figure to trust.

## Context & Scope

The paper is read-only input maintained in a separate repository. This repository pins a `sha256`
per definition block in `docs/reference/paper-definitions-of-record.md`, resolving anchors by
`\label{}` / `\aitem{}` name rather than line number, so the lint survives reflowing. A changed
block hash is outcome (c) of the gate's three outcomes: FAIL, exit 1.

This report establishes only *what is currently drifted and what each item costs*. It does not
re-pin anything, does not touch the record file, and does not perform the in-tree prose audit.
Those are the task's own work.

Measurement boundary worth noting: task 791 was editing
`docs/reference/paper-definitions-of-record.md` concurrently with this measurement. The row-tier
counts below (4 MANIFEST, 11 KNOWN-ANCHORS, 37 LIVE-UNPINNED) are therefore a snapshot of a file
under active edit, and 791 adds at least one further row before it closes.

## Findings

### Tier A - citation-only drift (1 anchor, lowest cost)

`CO`: the axiom text is **byte-identical apart from an appended
`\leanfoot{DedekindDerived.coDerived}`**. The paper gained a citation pointing *into* this
repository; the principle itself did not change.

- The cited declaration resolves: `coDerived` is described at `FormalSystem/Theorems.lean:38`.
- Work required: re-pin the hash and confirm the named declaration exists. No prose audit, no
  membership question.
- `CO` is the only one of the ten whose NEW text adds a `\leanfoot`/`\leanproof`; the other nine
  add none.

### Tier B - axiom-membership drift (4 anchors, the task's real content)

These are the four the task description names, and they carry the judgment pass.

- **`def:BX`**: the schema list shrank from
  `{TS, TL, TC, UE, UT, UI, UC, UF, UG, US, CN, NP, NF, NA, NB}` to
  `{TS, UI, UC, UF, UG, US, CN}`. Eight schemata removed: **TL, TC, UE, UT, NP, NF, NA, NB**.
  The metarules `TN` and `TR` are unchanged.
- **`def:TMplus`**: its anchor references are `{MF, MT, NA, NB, NF, NP}`.
- Read together, these two confirm the description's thesis mechanically: `NB` is **absent from
  BX's list and present in TMplus's**, and `NP`/`NF`/`NA` left BX while remaining referenced at
  TMplus. The membership claim to audit in-tree is therefore specific and checkable, not vague.
- **`def:BX-z`** (anchor refs `{UZ, Z1}`) and **`def:BX-d`** also drifted; their changes were not
  characterized line-by-line in this pass.
- In-tree citation load for this tier: `def:BX` 31 files, `def:BX-z` 23, `def:BX-d` 6,
  `def:TMplus` 6.

### Tier C - content addition in a formalized anchor (1 anchor)

`app:discrete` (7 in-tree citing files) drifted by **pure addition of two lines**, with nothing
removed or reworded:

1. A new soundness claim: over the integers the static frame also validates `\Next\top` at every
   time, so extending TM by `DN` alone does not prove `NN`.
2. A new label, `\label{fn:static-frame}`.

Two consequences. The new sentence is an **independence claim** adjacent to the
`FormalSystem/Metalogic/Independence/` subsystem, so it may be formalizable rather than merely
quotable. And `fn:static-frame` is a **new anchor with no row yet**, so it is a candidate
addition to the record rather than a re-pin of an existing row.

### Tier D - unformalized-subsystem drift (4 anchors, mechanical but out of scope)

`def:id`, `def:strongest`, `thm:exist`, `lem:uniq` each have **zero** citing files under
`FormalSystem/` or `docs/` (excluding the record file itself).

The substance: the paper **dropped the primed `Str'` operator**. `def:strongest` lost its primed
variant and its dominance-and-identity prose; `thm:exist` dropped the `Str'(Bm)`-and-hence
clause; `lem:uniq`'s second conjunct changed from a claim about two primed strongest operators to
a biconditional about `Q ≡ Bm`. This is the objective-modality material, which this repository
does not formalize.

Because nothing in the tree cites them, they re-pin with no Lean and no prose consequence. But
they are not BX/TM, and the task's non-goals forbid absorbing unrelated subsystem waves without
recording the decision.

### Mechanism notes

- There is **no `--fix` mode** on `check-paper-definitions.sh`, by design. `--resolve
  "ID|KIND|ENCLOSING|LOCATOR"` is the sanctioned way to obtain current text plus hash.
- The record file carries a dated drift-correction convention. Precedent entries include
  `### Drift correction (2026-10-14): the 27-anchor wave` and
  `### Drift correction (2026-09-02): ten-anchor re-pin`.
- Gate coupling: **C15** requires a MANIFEST or KNOWN-ANCHORS row for every paper anchor cited in
  live scope; **C35** asserts the generated citation manifest is byte-current and goes red on
  docstring edits in seeded files.

### Carried figures

Marked per the standard rather than presented as measured here:

- `CARRIED-UNVERIFIED` (source: task 792's dispatch report) - that 792 changed zero `sha256` lines
  and that its five new rows are pointer-only `LIVE-UNPINNED`; that C15 coverage rose 69 to 73.
- `CARRIED-UNVERIFIED` (source: task 801's own description) - that task 788 is completed at commit
  `c77645f8d` and landed the 20-constructor system.

## Decisions

- The wave to absorb is the **10 anchors enumerated here**, superseding the 4 named in the task
  description, consistent with that description's own instruction to re-derive at implementation
  time.
- `CO`'s drift is **not** a definitional change and must not be routed through the membership
  audit; treating it as one would waste the expensive path on a citation append.
- The Tier D four are **mechanically re-pinnable**, established by zero in-tree citations rather
  than by assumption.

## Recommendations

1. **Re-derive every hash first.** The paper was dirty at measurement time. Run the gate and
   `--resolve` at implementation time and treat this report's appendix as a prior, not a source.
2. **Re-pin Tier A and Tier D first** (5 anchors, low cost) to shrink the red surface before the
   judgment pass, asserting each OLD block re-hashes to its recorded OLD hash before writing.
3. **Spend the judgment pass on Tier B only**, anchored on the concrete finding above: verify
   every in-tree site describing BX/TM membership reflects `NB` in TM rather than BX, and
   `NP`/`NF`/`NA` as derived theorems. Sites to sweep: `FormalSystem/ProofSystem/Axioms.lean`
   docstrings, `FormalSystem/ProofSystem/README.md`, `FormalSystem/README.md`,
   `docs/reference/API_REFERENCE.md`, and the Typst reference manual.
4. **Record the Tier D decision explicitly** in the drift-correction entry, satisfying the
   non-goal rather than silently absorbing it.
5. **Raise `fn:static-frame` and the new `app:discrete` sentence as a separate question**: decide
   whether the `DN`-does-not-prove-`NN` claim is formalizable in
   `FormalSystem/Metalogic/Independence/` or quotable only. Do not fold a possible new Lean
   obligation into a re-pin task.
6. **Expect the wave to have moved again.** State which wave was absorbed and which was not,
   rather than claiming an unconditional green gate.

## Risks & Mitigations

- **The paper moves mid-task.** It is dirty now and has moved repeatedly during prior runs.
  Mitigation: re-derive hashes at implementation time; report the absorbed wave precisely.
- **Mistaking inherited red for self-inflicted red.** This gate was already red before the
  current batch began. Mitigation: read per-anchor verdicts, never whole-script exit status, when
  judging whether a change regressed anything.
- **Scope creep via Tier C.** `app:discrete` could pull a formalization obligation into a
  record-and-prose task. Mitigation: split it out as recommended above.
- **Concurrent edits to the record file.** 791 is amending it. Mitigation: re-read the file
  immediately before editing and re-count row tiers.

## Appendix

### Measured hash pairs (snapshot; re-derive before use)

| Anchor | OLD sha256 | NEW sha256 |
|---|---|---|
| `CO` | `5c468c01776c449b212c98070b5bfc70951691a23905cd4d4c249bf1f5375d41` | `707368059ff1f7cc53c8b4ca9c591781ee427263797c8d36d3fb85e8abe8e955` |
| `def:BX` | `8fdba7ab64b74d245bd47bfa14e6baac17c9d2ce67fdea5371a5fa9fc624a903` | `64cc5cc90860bd5c3855701a4de57c38a10ffb6d0c59025224c82869f8454ec2` |
| `def:BX-z` | `96e4b25e71c457bd3618f3a818b1852176b345d2c86199fbe16b6c46076ba334` | `c38466b21121724f71d039014c525e5e4f8c397025f37746fcfb7587c85a5581` |
| `def:BX-d` | `2423da4688632bfea7d0d3613a4bca4953c6197e6120dd43f79cbd5e44e294d0` | `44a74c839c0c74141fb1565120cb91193973fc33a69c35d5070bcbc67379e40c` |
| `def:TMplus` | `d71622fc325a3d40ae4a7823c0d5d17f73e4a18bcf2e1c4be59e6693db35e142` | `139a9a56bdf9b22c2544c6c86ec1eeb178e4908810578556ed6c057de8ef5e42` |
| `app:discrete` | `465b089fd41ed5b599cf080621c0181bfcce5ef8374d44f9f147709d23409864` | `240826f45dae75872ef1219aaac79903d775f424ac46077feac45febfd7bcc54` |
| `def:id` | `f56301e580b40894ddd7d69c6a72d326a8a41f984f8713cf431215b5f0fd9c92` | `0d994904bc8d6f1166fd4c947fe69a889e36be37343aca778182e9b19594d1d0` |
| `def:strongest` | `1df0d202e5c4ccfeb92b6c83048ece99bb80dc6ce46774a05ff9e728e93231ec` | `0b96a04d79de927726435874a3def84136b85776a0d3f8e230b87e4b11622a70` |
| `thm:exist` | `93d234140af7d36b60d55ffa2248a3f3896c6a80e115b2801efaeed07c115eef` | `299ecc33bf9397538f37aa263a5022c15c2a9a915de07dbee2b1b1244ee3c635` |
| `lem:uniq` | `56f31fcacb80f4811e98c7ab8c1bcd49502cb8d51b10f813f36a2c943a950003` | `100afee0cc59fee195e34ccadd23b6bbd6fe9f4800637e7561b4101a7347518c` |

`CO`'s OLD hash is reported by the gate against base commit
`9ad4aa5d1bda09d885d37b296fdde1bc1a0817ee` and matches the record's pin; the other nine OLD
hashes are reported as verified against the pinned text in the record file.

### Tier summary

| Tier | Anchors | In-tree citing files | Work |
|---|---|---|---|
| A | `CO` | 7 (citation-form match) | re-pin; confirm declaration resolves |
| B | `def:BX`, `def:BX-z`, `def:BX-d`, `def:TMplus` | 31 / 23 / 6 / 6 | re-pin + membership prose audit |
| C | `app:discrete` | 7 | re-pin; decide formalizable vs quotable |
| D | `def:id`, `def:strongest`, `thm:exist`, `lem:uniq` | 0 each | mechanical re-pin + recorded decision |

Citation counts come from `grep -rl` over `FormalSystem/` and `docs/` for `*.lean` and `*.md`,
excluding the record file. `CO` is counted by citation form
(`Paper: CO`, `aitem{CO}`, `CO principle`) because a bare-token match over-reports; a
word-boundary `\bCO\b` match returns 31 files and should not be read as a citation count.

### Commands used

- `bash scripts/check-paper-definitions.sh` - full drift run, exit 1
- `bash scripts/check-paper-definitions.sh --resolve "ID|KIND|ENCLOSING|LOCATOR"` - per-anchor text and hash
- `grep -nE '^### Drift correction' docs/reference/paper-definitions-of-record.md` - precedent entries
