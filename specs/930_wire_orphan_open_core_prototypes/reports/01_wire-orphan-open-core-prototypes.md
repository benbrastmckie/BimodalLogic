# Research Report: Task #930

**Task**: 930 - Promote and wire the two orphan open-core prototypes into the evidence gate
**Started**: 2026-11-13T17:40:00Z
**Completed**: 2026-11-13T18:05:00Z
**Effort**: Small-to-medium (mechanical promotion; all verification already measured)
**Dependencies**: None
**Sources/Inputs**: - Codebase (`scripts/check-evidence-probes.sh`, `scripts/readme-lint.sh`,
  `scripts/check-module-invariants.sh`, `scripts/generate-decidability-inventory.sh`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`), `lake env lean` through
  `.claude/scripts/lake-build-guard.sh`, measured runs of the evidence gate
**Artifacts**: - specs/930_wire_orphan_open_core_prototypes/reports/01_wire-orphan-open-core-prototypes.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Neither README authority claim is stale.** Both orphan prototypes compile clean against the
  live tree on first attempt (`lake env lean` exit 0 through the build guard; 2.37 s and 1.75 s),
  and every headline theorem's `#print axioms` shows only `[propext, Classical.choice, Quot.sound]`
  (or `[propext, Quot.sound]`). No `sorryAx`, no custom axiom, no `native_decide`. The serious
  outcome the dispatch flagged did not materialize.
- **The promotion was measured end-to-end, not projected.** Promoted copies were placed at the
  proposed `specs/evidence/` paths, intent-to-added so the gate's tracked-ness test passes, and the
  gate was run with both entries wired: `PASS  all 60 wired probe(s) compile`, exit 0 — the
  baseline 58 raised by exactly two, with every other probe row byte-identical to the baseline run.
  The trial state was then reverted; the working tree carries no promotion edits.
- **The library cites both prototypes by bare filename only**, at `README.md:1002` and
  `README.md:1039`, with no path. The promotion therefore needs no companion edit anywhere else —
  the same condition that let `lowering-anchor-deficit` be promoted cleanly.
- **Recommended landing**: verbatim copies (one header line changed) into
  `specs/evidence/seam-gluing-ray-product/` as `ladder-tight-chain-regime-b.lean` and
  `ladder-spanning-divisibility.lean`, two `WIRED` entries plus two table blocks, and two README
  parenthetical rewrites.
- **Three further orphan prototypes of the same defect class exist** and are out of this task's
  scope because nothing in the library cites them (see Risks).

## Context & Scope

`RaySummary/README.md` cites two standalone prototypes as the sole authority for two load-bearing
refutations about the depth-`0` open core, and flags each as "not a wired probe". Both files sit in
gitignored `specs/archive/`, so they are absent from a fresh clone and the evidence gate does not
hold them. Researched: whether each still compiles against the live tree; where each belongs under
`specs/evidence/`; what the gate wiring costs; and what else in the repository would move.

Not in scope: any change to the obligations themselves, to `(K1)`-`(K4)`, or to the reserved name
`cellLE_zero_const_of_kappa_eq` (neither prototype claims it — grep count 0 in both files).

## Findings

### Codebase Patterns

**The two orphans and their live-tree status.**

| prototype (archived path) | imports | headline theorems | `lake env lean` | axioms |
|---|---|---|---|---|
| `specs/archive/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean` | `...RaySummary.LadderAgree` | `tightChain_isLadderPath`, `tightChain_pin`, `tightChain_slack_zero`, `tightChain_pins`, `spanningBlockBwd_refuted`, `spanningBlockFwd_refuted` | exit 0, 2.37 s | `[propext, Classical.choice, Quot.sound]` on all six |
| `specs/archive/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean` | `...RaySummary.LadderPin` | `spanning_walk_not_pending`, `spanningBlockLengthDvd_refuted` | exit 0, 1.75 s | `[propext, Quot.sound]` and `[propext, Classical.choice, Quot.sound]` |

Both already carry their `#print axioms` lines at end of file, outside the namespace, exactly as
the wired siblings do. Namespaces `Probe836B` and `Probe838B` collide with nothing (each probe
compiles standalone; the promoted sibling `ladder-cell-obligation-refutation.lean` keeps
`Probe836A` the same way).

**The gate's acceptance conditions** (`check_probe`, `scripts/check-evidence-probes.sh`): the file
must exist, must satisfy `git ls-files --error-unmatch` (presence on disk is explicitly not
enough), and `lake env lean` must exit 0. `specs/evidence/` is tracked — `.gitignore` excludes
`specs/archive/`, `specs/vault/`, `specs/tmp/` and `specs/**/.*`, not `specs/evidence/`.

**Baseline**: `bash scripts/check-evidence-probes.sh` → `PASS  all 58 wired probe(s) compile`,
exit 0 (57 `WIRED` + 1 `WIRED_REPO`, 1 `DEFERRED` skipped).

**Collection placement.** `seam-gluing-ray-product/` already holds the whole `ladder-*` family (15
entries), including `ladder-cell-obligation-refutation.lean` — which is the promoted form of
`cell-obligation-refutation.lean` from the *same* archived prototype directory as
`tight-chain-regime-b.lean`. `forward-slack-pin-cascade/` was considered and rejected: it holds the
two pin-cascade route probes, not the ladder-schema refutations, and `spanning-divisibility.lean`
imports `LadderPin` and refutes a ladder schema.

**No redundancy with `ladder-tight-chain-nonliftability.lean`.** That wired probe shares the
two-state object and the doubling-chain scaffolding (it names "the archived regime-B prototype" in
its own header) but proves a different result: no finite deletion-derivative of the chain lifts,
on a chain unbounded above. `spanningBlockBwd_refuted` / `spanningBlockFwd_refuted` — the content
`README.md:1002` actually cites — exist nowhere else in the tree.

**Citation surface.** Repository-wide grep for both filenames outside `specs/archive/` and `.lake`
returns exactly two live-library hits: `README.md:1002` and `README.md:1039`. Every other hit is
under `specs/` (TODO.md, ROADMAP.md, and task 761's plans/summaries), which the
no-task-references and no-record-versioning rules exempt and which nothing gates.

**Downstream consumers of the `WIRED` arrays.**

- `.github/workflows/ci.yml` step `evidence-probes` runs the gate (`continue-on-error: true`).
- `scripts/generate-decidability-inventory.sh` parses `WIRED`/`WIRED_REPO` as "source 2". Two new
  entries will surface as `+ REFUTED probe:...` rows in a `--diff` run, and would bump the exit
  code only under `--strict --diff`. It is **not** in CI and not in this task's VERIFY list. This
  is an expected, non-gating consequence, not a regression.
- `scripts/check-module-invariants.sh` mentions `specs/evidence/` only in comments; no check
  enumerates the directory.

**Gate-adjacent checks that the edits touch, and why each stays green.**

- **C9** (`check-module-invariants.sh`, enforced): forbids `task N` / `specs/NNN_slug/` under
  `FormalSystem/`, `lakefile.toml`, `README.md`, `scripts/`. `scripts/check-evidence-probes.sh` is
  explicitly excluded from the scan, so a table block may name the archived origin; the README
  replacement text must not, and the recommended text uses only `specs/evidence/...`.
- **C12** (slash-shaped source paths): regex is
  `\b(?:FormalSystem|Boneyard|Tests|Logos|Bimodal)/...` — `specs/evidence/...` does not match, so
  the new README paths are neither validated nor flagged by it.
- **C13 / readme-lint Check 3** (gated): both parse only `[text](path)` markdown links. A
  backticked path is untouched, which is what the surrounding README prose already uses.
- **readme-lint Check 4** (reported, not gated): `RaySummary/README.md` carries
  `*Last verified: 2026-10-13*` while the directory's last commit is `2026-11-12` — the stamp is
  **already** stale before this task touches anything. Refreshing it is a courtesy, not a gate.
- **`--emit-inventory --check`**: generated blocks are `dir=FormalSystem/...` scoped; files under
  `specs/evidence/` do not enter them.

**Measured baselines**: `bash scripts/readme-lint.sh` exit 0 (`RESULT: PASS`);
`bash .claude/scripts/check-task-references.sh --quiet` exit 0 (`0 unexempted occurrences`).

### External Resources

No Mathlib or literature search was needed: both prototypes are self-contained against the
project's own `RaySummary` modules, and the task is a records/gate-wiring operation rather than a
proof-search one. The `--lit` briefing was not drawn on for this reason.

### Recommendations

- **Promote verbatim into `specs/evidence/seam-gluing-ray-product/`, changing exactly one header
  line per file.** Both headers carry the identical line
  `Prototype, compiled standalone with `lake env lean` through the build guard; NOT a wired probe.`
  (836B line 5, 838B line 4; one occurrence each). Replace it with
  `A wired probe, compiled by `scripts/check-evidence-probes.sh`.` and change nothing else — the
  gate's no-weakening rule forbids deleting or restating an obstruction, and the chain-lemma
  overlap with `ladder-tight-chain-nonliftability.lean` is a cost worth paying to keep the record
  exact (1.75-2.37 s each; the gate already compiles 58 probes).
  New paths: `ladder-tight-chain-regime-b.lean`, `ladder-spanning-divisibility.lean`.
  [VERIFIED: PASS -- promoted copies placed at these paths, `git add -N`'d, both `WIRED` entries
  added to a copy of the gate run from `scripts/`: `PASS  all 60 wired probe(s) compile`, exit 0;
  per-row diff against the 58-probe baseline shows no other probe disturbed. Trial state reverted.]
- **Do not place them in `forward-slack-pin-cascade/`.** [No compiled gate applicable — a
  collection choice, not a gate-decided artifact. Grounded instead in the sibling precedent:
  `ladder-cell-obligation-refutation.lean` came from the same archived prototype directory.]
- **Wire two `WIRED` entries immediately after
  `"seam-gluing-ray-product/lowering-anchor-deficit"`**, keeping the collection grouping the array
  already uses. [VERIFIED: PASS -- this is the exact insertion point used in the measured trial.]
- **Add two table blocks in the comment table above `WIRED=(`**, in the same position relative to
  the surrounding rows, in the file's fixed column format: `# ` + probe id, padded so the `|` sits
  at **column 61**, description from column 63, wrapped at roughly column 100. Each row states the
  decision the probe holds in place and closes with its measured axiom profile, as the neighbouring
  rows do. [No compiled gate applicable -- the table is free-text; `generate-decidability-inventory.sh`
  explicitly does not parse it.]
- **Rewrite the two README parentheticals** (`FormalSystem/Metalogic/Decidability/RaySummary/README.md`):
  - lines 1001-1003, replace `(the\nstandalone prototype `tight-chain-regime-b.lean` in the task record that landed this layer, not\na wired probe)` with a reference to the wired probe
    `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-regime-b.lean`;
  - lines 1038-1039, replace `(The standalone prototype\n`spanning-divisibility.lean` in the task record, not a wired probe.)` with the same shape for
    `specs/evidence/seam-gluing-ray-product/ladder-spanning-divisibility.lean`.
  Both rewrites also drop the "in the task record" framing, which is the indirect task-management
  reference the no-task-references rule targets. [VERIFIED: PASS -- `scripts/readme-lint.sh` and
  `.claude/scripts/check-task-references.sh --quiet` both measured exit 0 at baseline, and the
  replacement text introduces no markdown link (Check 3 / C13 parse only `[text](path)`), no
  `specs/NNN_slug/` or `task N` shape (C9), and no `FormalSystem|Boneyard|Tests|Logos|Bimodal`-rooted
  path (C12).]
- **Run `bash scripts/check-module-invariants.sh --no-build` as an extra gate** at implementation
  time: both edited files (`README.md` under `FormalSystem/`, and `scripts/`) are in C9's and
  C12/C13's scan scope even though the analysis above says each stays green.
  [No compiled gate applicable to this recommendation itself -- it prescribes running a gate, it
  does not name an artifact for one to accept.]
- **Do not force-track either archived original, and do not edit them in place.** The gate's own
  failure text names force-tracking under `specs/archive/` as the wrong remedy.
  [No compiled gate applicable -- a prohibition, not a landable artifact.]

## Decisions

- Collection is `seam-gluing-ray-product/`, not a new collection and not `forward-slack-pin-cascade/`.
- Filenames take the `ladder-` prefix the collection's ladder family already uses, rather than
  preserving the bare archived names. The README cites by filename, so both citations change
  anyway; the prefix buys consistency at no extra cost.
- Promotion is verbatim apart from the one header line. The alternative — pruning the chain
  lemmas that overlap `ladder-tight-chain-nonliftability.lean` — was rejected: it edits a compiled
  record to save ~2 s of gate time, against the file's own no-weakening rule.
- `WIRED`, not `WIRED_REPO`. `WIRED_REPO` exists only for probes with a named promotion blocker;
  neither of these has one, since both citations are bare filenames.

## Risks & Mitigations

- **Three further orphan prototypes of the same defect class remain**:
  `specs/archive/838_.../prototype/pin-free-side.lean`,
  `specs/archive/838_.../prototype/idle-gap-lengthening.lean`, and
  `specs/archive/836_.../prototype/cell-obligation-refutation.lean` (the last superseded by its
  promoted, substantially rewritten form). The first two still carry the "NOT a wired probe"
  header line. They are **out of this task's scope** because no live-library file cites them — the
  defect this task repairs is specifically "cited by the library as an authority, in a location git
  does not track". *Mitigation*: recorded here so the gap is visible; a follow-up task can promote
  them on the same pattern if the records are judged worth gating.
- **Concurrency with the sibling task dispatched this cycle.** Both edited files
  (`scripts/check-evidence-probes.sh`, `RaySummary/README.md`) are outside any declared sibling
  scope, but no `file_scope` was declared for the sibling. *Mitigation*: re-read both immediately
  before editing; stage only this task's own files by explicit path.
- **The gate takes the exclusive `.lake/build-guard.lock` for its whole run.** A concurrent guarded
  build will block on it. *Mitigation*: expected and accepted by design (the script's own header
  records the trade); no action needed beyond not launching a build in parallel with the gate.
- **`generate-decidability-inventory.sh --strict --diff` will report two added `REFUTED` probe
  ids.** *Mitigation*: expected and benign; the script is not in CI. If its committed baseline is
  ever refreshed, these two entries belong in it.

## Tactic Survey Results

- Not applicable (no tactic survey performed). No proof obligation was opened in this task: both
  prototypes compile unchanged, and the work is file promotion plus gate wiring.

## Context Extension Recommendations

- **Topic**: running a copy of a repo gate script from outside its own directory.
- **Gap**: `scripts/check-evidence-probes.sh` does `cd "$(dirname "$0")/.."` at line 95, so a copy
  executed from a scratchpad silently resolves `specs/evidence` against the wrong root and reports
  `FAIL (missing: ...)` for *every* wired probe — a failure mode indistinguishable at a glance from
  mass rot. This cost one full wasted gate run here.
- **Recommendation**: note in `context/project/lean4/operations/` (or wherever gate-trial technique
  is recorded) that a trial copy of a repo gate must be placed inside the directory the original
  occupies, so its self-relative `cd` still resolves to the repository root.

## Appendix

**Commands run (all measured, none projected).**

```
bash .claude/scripts/lake-build-guard.sh build --timeout 300 -- env lean <836B prototype>   # exit 0
bash .claude/scripts/lake-build-guard.sh build --timeout 300 --no-share -- env lean <838B>  # exit 0
bash scripts/check-evidence-probes.sh                       # PASS all 58 wired probe(s), exit 0
bash scripts/readme-lint.sh                                 # RESULT: PASS, exit 0
bash .claude/scripts/check-task-references.sh --quiet        # 0 unexempted occurrences, exit 0
bash scripts/.probe-gate-trial-930.sh                       # PASS all 60 wired probe(s), exit 0
```

The last of these is the compile-verify measurement: a copy of the gate carrying the two proposed
`WIRED` entries, run against the two promoted files in place. The trial copy and both promoted
files were removed and unstaged afterwards; `git status --short` returns to its pre-trial contents.

**Grep sweeps.**

- `tight-chain-regime-b|spanning-divisibility` over `*.md`/`*.lean`/`*.sh`, excluding
  `specs/archive/` and `.lake/`: two live-library hits, both in `RaySummary/README.md`.
- `cellLE_zero_const_of_kappa_eq` in either prototype: 0 occurrences — no reserved name claimed.
- `specs/evidence` over `*.sh`/`*.yml` outside `.claude/`: `check-evidence-probes.sh`,
  `generate-decidability-inventory.sh`, `check-module-invariants.sh` (comments only),
  `.github/workflows/ci.yml`.
