# Research Report: Task #691

**Task**: 691 - Resolve c23 naming exemptions
**Started**: 2026-09-28T21:30:00Z
**Completed**: 2026-09-28T22:44:00Z
**Effort**: small (measurement only; no Lean source read for proof content)
**Dependencies**: None blocking. Tasks 685 and 693 — the in-flight workstreams this report's
first pass flagged as territory overlap and inventory volatility — have both since completed
(`task 685: complete implementation`, `task 693: complete implementation`); see Round 2 Update
below. No dependency remains open.
**Sources/Inputs**:
- `scripts/check-module-invariants.sh` — the C23 block (declaration scan, `UPPER_ALLOW`,
  `SHADOW_ALLOW`, `FROZEN_PREFIX`, the `ENFORCE_C23` guard comment)
- `scripts/check-module-invariants.sh --no-build`, run against committed `HEAD` (8f8ecb906), and
  re-run from a scratch copy with the `shadow[:10]` print cap lifted
- Round 2: `scripts/check-module-invariants.sh --no-build` and `scripts/typst-sync-check.sh`,
  re-run against current `HEAD` (02c2e4a68, post-685/693) to confirm the inventory and gate state
  are unchanged in substance
- `FormalSystem/Metalogic/Decidability/` — `BiLasso/`, `WitnessFamily/Sharing/`,
  `WitnessFamily/Compression/`, `PlusWitnessFamily/`
- `.github/workflows/ci.yml` — step order
- GitHub Actions run 36082531846 (the most recent CI run) and runs 35536540451, 35428958865

**Artifacts**:
- `specs/691_resolve_c23_naming_exemptions/reports/01_c23-naming-exemptions.md`

**Standards**: report-format.md, artifact-formats.md

---

## Round 2 Update (re-verified against current HEAD, post-685/693)

This task's status was still `[RESEARCHING]` with no report linked in `specs/state.json` when
this round began — the Round 1 findings below existed on disk but had never been committed or
returned. Rather than re-deriving them, this round re-ran the measurements against current `HEAD`
(`02c2e4a68`, after tasks 685 and 693 both completed) and confirms every Round 1 finding still
holds, unchanged in substance:

- The eleven-row inventory (Finding 1) is byte-identical except for the one line-number drift
  Finding 7 already flagged and priced in: `decidableValidZTime`'s inner site is now at
  `Compression/Assembly.lean:147` (Round 1 had recorded the pre-685 line `:132`, and separately
  noted the post-move `:147` as the expected drift — both the table and the text already carried
  the current value, so no correction was needed here). All ten other rows, and the two
  `NM_nonneg` sites, are at the exact lines the task description and Round 1 table give.
- **Finding 7's blocking risk has cleared.** C33 (generated-root freshness) and INV (inventory
  staleness) both now `PASS` — they were the two gates task 685's in-flight module addition had
  turned red. `check-module-invariants.sh --no-build` now reports **exactly one** failing check
  group, C23, with its two `Uppercase_x` names and eleven shadow pairs unchanged.
- **Territory collision with task 685 has resolved by task completion**, not by scheduling
  around it: 685 and 693 are both `complete implementation` in git log, so row 1's inner site
  (`Compression/Assembly.lean`) is no longer being concurrently edited. The Recommendations'
  "sequence after 685/693" condition (Recommendation 5) is now satisfied.
- One unrelated, out-of-scope observation: `scripts/typst-sync-check.sh` is red again right now
  (`formalsystem-file-count: committed=603 live=604`, a line-count mismatch of the same shape
  Finding 8 already described as a separate, previously-repaired issue). This is `typst/generated/
  status.typ` trailing the current uncommitted tree, not a C23 finding, and needs no action from
  this task — flagged only so the plan/implement phase does not mistake it for new C23 fallout.

**Net effect on the plan phase**: the "sequence after 685/693" gate is now open, all measurements
are current, and the exemption-key decision in Finding 3 is the only substantive choice a plan
needs to make before editing `scripts/check-module-invariants.sh`.

## Executive Summary

- This report is **supplementary to the task description**, which already establishes the two
  `NM_nonneg` sites, the `SharingWindow` structure-field collision, the `Int`-resolution obstacle,
  the `decidableValidZTime` sub-namespacing rationale, and the exemption-not-rename conclusion.
  Only findings that go beyond those are recorded here.
- **The eleventh pair is invisible in normal output.** The scanner prints `shadow[:10]` while
  reporting a count of 11, which is the origin of the description's `mem_verts x3+`. The true
  `mem_verts` count is **4**, and the full eleven-row inventory is below.
- **Eleven pairs collapse to four base names and three structural shapes**, so four
  `SHADOW_ALLOW` entries clear all eleven. This is not eleven independent decisions.
- **The exemption mechanisms are keyed differently, and this is the one unrecorded design
  decision.** `UPPER_ALLOW` and `SHADOW_ALLOW` are keyed on the *bare name* and so apply
  tree-wide and to all future modules; only `FROZEN_PREFIX` is path-scoped. Blessing four names
  forever is a strictly wider act than recording eleven measured pairs.
- **Two existing `SHADOW_ALLOW` entries are directly citable precedents** (`isValid`,
  `insertEnv`), so the exemption needs no new justification vocabulary.
- **The Uppercase_x auto-exemption path is closed, measured** — an explicit `UPPER_ALLOW` entry is
  the only available route for `NM_nonneg`.
- **C23 is now the first failure CI will hit**, at workflow step 6, masking steps 7-11. It was
  green in the last CI run and regressed inside the unpushed commits.

## Context & Scope

Scope is the C23 red state as measured at committed `HEAD` (8f8ecb906), plus the mechanics of the
exemption sets the fix must be written into. No Lean proof content was read and no rename was
attempted; the description's conclusion that a rename is inapplicable is taken as settled.

One constraint governs the fix and is quoted from the scanner itself, beside `ENFORCE_C23`:
"Never flip it to 0; add a reasoned entry to the in-scanner exception set instead, where the
reason is read alongside the name it exempts." The reason must therefore sit inline with the
entry, not in a separate manifest file.

## Findings

### 1. The full eleven-pair inventory, including the pair output truncation hides

The scanner reports `FAIL C23 11 outer-shadows-inner bare-declaration pair(s)` but its loop is
`for base, a, b in shadow[:10]`, so the eleventh pair is never printed. Re-running from a scratch
copy with the cap lifted yields all eleven. Line numbers are as of 8f8ecb906 and are volatile
(see Finding 6).

| # | Base | Outer namespace (site) | Inner namespace (site) |
|---|---|---|---|
| 1 | `decidableValidZTime` | `..Decidability` (`BiLasso/Assembly.lean:100`) | `..Decidability.Compression` (`WitnessFamily/Compression/Assembly.lean:147`) |
| 2 | `cohWindowLo` | `..Decidability` (`BiLasso/Decide.lean:378`) | `..PlusSharingWitnessFamily` (`PlusWitnessFamily/Decide.lean:300`) |
| 3 | `cohWindowLo` | same | `..SharingWitnessFamily` (`WitnessFamily/Sharing/Decide.lean:264`) |
| 4 | `cohWindowLo` | same | `..SharingWindow` (`WitnessFamily/Sharing/Window.lean:152`) |
| 5 | `cohWindowHi` | `..Decidability` (`BiLasso/Decide.lean:381`) | `..PlusSharingWitnessFamily` (`PlusWitnessFamily/Decide.lean:303`) |
| 6 | `cohWindowHi` | same | `..SharingWitnessFamily` (`WitnessFamily/Sharing/Decide.lean:267`) |
| 7 | `cohWindowHi` | same | `..SharingWindow` (`WitnessFamily/Sharing/Window.lean:155`) |
| 8 | `mem_verts` | `..SharingWitnessFamily` (`Sharing/Fulfil.lean:324`) | `..SharingWitnessFamily.FwdWalk` (`Sharing/Fulfil.lean:758`) |
| 9 | `mem_verts` | same | `..SharingWitnessFamily.BwdWalk` (`Sharing/Fulfil.lean:831`) |
| 10 | `mem_verts` | `..SharingWindow` (`Sharing/Window.lean:172`) | `..SharingWindow.FwdWalk` (`Sharing/Window.lean:494`) |
| 11 | `mem_verts` | same | `..SharingWindow.BwdWalk` (`Sharing/Window.lean:567`) |

Namespaces are abbreviated from `FormalSystem.Metalogic.Decidability`. Row 11 is the pair the
truncation hides; it is the `BwdWalk` mirror of row 10 and resolves the description's `x3+` to
exactly 4.

### 2. Eleven pairs are four names in three structural shapes

- `decidableValidZTime` — 1 outer x 1 inner. The case the description already argues.
- `cohWindowLo` / `cohWindowHi` — **1 outer x 3 inner each**. A single `BiLasso/Decide.lean`
  declaration is shadowed by the same-named declaration in three sibling witness namespaces. The
  fan-out is the three witness families, not three separate naming decisions.
- `mem_verts` — **2 outers x 2 inners**, a fully regular grid: each of `SharingWitnessFamily` and
  `SharingWindow` carries `mem_verts`, and each has `FwdWalk` and `BwdWalk` sub-namespaces
  carrying the mirror. This is the mirrored-API shape the description names, and its regularity is
  evidence for that reading rather than a coincidence.

Because the scan keys on base name, **four entries clear all eleven rows.**

### 3. The three exemption mechanisms are keyed differently — the unrecorded decision

The description says to extend "`UPPER_ALLOW` and/or the shadowing scan". The scan in fact offers
three mechanisms, and they differ in what they bless:

| Mechanism | Key | Scope of effect |
|---|---|---|
| `UPPER_ALLOW` | bare declaration name | every occurrence in `FormalSystem/` + `BimodalTools/`, now and in future |
| `SHADOW_ALLOW` | base name only (`if base in SHADOW_ALLOW: continue`) | as above — the whole base-name bucket is skipped before any pair is formed |
| `FROZEN_PREFIX` | path prefix (`a[1].startswith(...)` or `b[1]`) | only pairs with a member under that path |

The consequence is not stated in the description and is the substantive choice this task makes:
a `SHADOW_ALLOW` entry for `mem_verts` does not record the four measured pairs, it **disables the
`mem_verts` bucket permanently**, so a genuinely accidental future collision on that name is never
reported. The same holds for `cohWindowLo`/`cohWindowHi`/`decidableValidZTime`.

Three options follow, in ascending fidelity and cost:
1. Four `SHADOW_ALLOW` entries — smallest change, widest blessing.
2. A path-scoped entry in the `FROZEN_PREFIX` shape — narrower, and the existing precedent for
   "cannot be fixed from here right now", but its recorded intent is *removable and in-flight*,
   which does not match a permanent mirrored-API decision.
3. Extend the scan to a `(base, outer_ns, inner_ns)` triple key, exempting exactly the eleven
   measured pairs. **No such key exists today**; this is new scanner capability, and it is the only
   option that cannot silently absorb a future regression.

### 4. Two citable precedents already carry the needed reasoning

`SHADOW_ALLOW` currently holds, with their inline reasons:
- `isValid` — "structure-member namesakes on distinct types: legitimate dot-notation". This is the
  same shape as `mem_verts` and arguably `cohWindowLo`/`cohWindowHi`: namesakes on distinct types
  reached by dot-notation.
- `insertEnv` — "two genuinely different operations sharing a name; resolving it needs a per-site
  arity analysis across 14 files, recorded as follow-up rather than done blind". This is the
  precedent for *recording instead of renaming*, which is exactly this task's disposition.

So the entries can cite existing recorded reasons rather than inventing a justification class.

### 5. The Uppercase_x auto-exemption path is closed, and measured

The scanner auto-exempts a `Prefix_rest` name when `rest` is itself a live base
(`n.split("_", 1)[1] not in LIVE_BASES`), on the recorded name-capture ground. Measured against
the live tree:
- `NM` **is** a live declaration — `abbrev NM` at `WitnessFamily/Sharing/Decide.lean:176` and
  `PlusWitnessFamily/Decide.lean:203`. So the "prefix names no live declaration" class
  (`UPPER_ALLOW`'s recorded purpose) does not describe this case.
- `nonneg` is **not** a live base anywhere in `FormalSystem/` or `BimodalTools/`. So the
  name-capture auto-exemption does not fire, which is precisely *why* the two names are reported.
- `NM_` does not match `TENSE_PREFIX`.

All three recorded classes therefore miss, and an explicit `UPPER_ALLOW` entry is the only route.
This also forecloses a tempting non-fix: introducing some live `nonneg` would silence the check as
a side effect, and must not be mistaken for a resolution.

### 6. The rename alternative's blast radius, and one site the description does not name

If a rename is ever revisited, `NM_nonneg` has **26 occurrences across 5 files**
(`Sharing/Decide.lean`, `Sharing/Fulfil.lean`, `Sharing/Window.lean`,
`PlusWitnessFamily/Decide.lean`, `PlusWitnessFamily/Fulfil.lean`). The sharpest of them is
`PlusWitnessFamily/Decide.lean:334`, `NM_nonneg := S.NM_nonneg` — a structure-instance field
assignment in which the *field* `NM_nonneg` and the *theorem* `NM_nonneg` occur in one expression.
Any rename must split those two in place, which strengthens the description's conclusion.

### 7. The inventory is volatile while the Decidability tree is in flight

Observed within a single session, with tasks 685 and 693 orchestrating:
- Row 1's inner site moved from `Compression/Assembly.lean:132` to `:147`.
- A new module, `PlusWitnessFamily/Incompleteness.lean`, appeared and turned C33
  (generated-root freshness) and INV (stale inventory blocks) red. Both are ordinary mid-phase
  state for a task that has just added a module, not C23 findings, and both clear via
  `lake exe mk_all --lib FormalSystem` and
  `bash scripts/check-module-invariants.sh --emit-inventory`.

Two consequences: the eleven rows must be **re-measured at implementation time** rather than
trusted from this table, and any exemption keyed on line numbers would rot immediately.

### 8. Clarifying "C23 is the sole remaining red gate group"

The claim holds as written, and was re-verified: run against clean committed `HEAD`, C23 was the
only failing group in `check-module-invariants.sh`. It should not, however, be read as "CI is
green apart from C23":

- `scripts/typst-sync-check.sh` had been failing in CI for **three consecutive runs**
  (2026-09-19, 09-20, 09-25) on stale counts in `typst/generated/status.typ`.
- `scripts/check-metalogic-cycles.sh` had gone red on a missing layer row for
  `PlusLanguage/Subformulas.lean`.

Both were repaired outside this task. The relevant point for 691 is ordering: C23 sits at **step 6**
of `.github/workflows/ci.yml`, ahead of the copyright, README, cycles and typst steps, so while it
is red it masks steps 7-11. It was green in the last CI run (d43af985d) and regressed inside the
unpushed commits, which is why no CI run has ever reported it.

## Decisions

- No C23 change was made under this report. The user's standing decision is that the fix belongs
  to this task, taken after tasks 685 and 693 land, on the ground that row 1's inner site sits in
  685's territory and the inventory is still moving. **That condition is now satisfied** — both
  tasks show `complete implementation` in git log as of this round.
- The `mem_verts` count is settled at 4, and the eleven-row table above supersedes `x3+`.

## Recommendations

1. **Choose the exemption key before writing any entry** (Finding 3). The bare-name default is the
   smallest diff and the widest blessing; the triple key is the only shape that exempts the
   measured pairs without disabling future detection. This is the task's real decision and should
   be recorded as such.
2. **Re-measure the eleven rows first** (Finding 7), with the print cap lifted or the count
   cross-checked, so the hidden eleventh pair is not dropped again.
3. **Cite `isValid` and `insertEnv`** for the shadow entries and keep each reason inline, per the
   `ENFORCE_C23` instruction.
4. **Write the `UPPER_ALLOW` entry's reason against the measurement in Finding 5** — that `NM` is
   live and `nonneg` is not, so all three recorded classes miss. `UPPER_ALLOW`'s existing comment
   describes prefixes naming nothing live, which is not this case; extending the set without also
   extending that comment would leave the file self-contradicting.
5. ~~Sequence after 685/693~~ — **satisfied**: both are complete, and C33/INV are already
   confirmed `PASS` in Round 2. The plan may proceed straight to the exemption-key choice
   (Recommendation 1) and re-run the full gate after the edit.

## Risks & Mitigations

- ~~Territory collision with task 685 on `Compression/Assembly.lean` (row 1)~~ — **resolved**:
  685 and 693 have both completed (see Round 2 Update). The fix touches only
  `scripts/check-module-invariants.sh` if the bare-name or triple-key route is chosen, so no Lean
  file need be edited at all.
- **A bare-name exemption silently absorbing a future regression** (Finding 3). Mitigation: prefer
  the triple key, or record explicitly in the inline reason that the whole base-name bucket is
  being disabled and why that is acceptable.
- **Stale line numbers in this report** (Finding 7). Mitigation: treat the table as a census of
  pairs and namespaces, not of line numbers. Re-verified in Round 2: only the one line already
  flagged as moving has moved, and to the value this report already recorded.
- **`typst-sync-check.sh` red in the working tree** (Round 2 Update). Not a C23 finding and out of
  this task's scope; do not attempt to fix it under this task's edits.

## Appendix

- Scanner internals: `scripts/check-module-invariants.sh` — `UPPER`/`TENSE_PREFIX`/`UPPER_ALLOW`
  and the `LIVE_BASES` auto-exemption; `SHADOW_ALLOW` and `FROZEN_PREFIX` in the pair scan; the
  `shadow[:10]` print cap; the `ENFORCE_C23` guard comment.
- CI step order: `.github/workflows/ci.yml`, "Check module invariants" (step 6) through "Text-based
  style linters".
- CI runs consulted: 36082531846 (2026-09-25), 35536540451 (09-20), 35428958865 (09-19) — all
  three failed at the typst sync check, with module invariants green.
