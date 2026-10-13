# Research Report: Task #778

**Task**: 778 - Record the modulus convention for the residue-carrying ladder index
**Started**: 2026-10-13T00:00:00Z
**Completed**: 2026-10-13T00:00:00Z
**Effort**: small (record-only; no new Lean declaration, no proof obligation)
**Dependencies**: None
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` (docstring, lines 74-88)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (row at line 45, Evidence narrative at line 781)
- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` (`ladderIndexRes`, mechanisms (4) and (5))
- `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean` (`reachN_eventually_periodic`, `cell_succ_ne`, `gate_parity_separates`)
- lean extension source store: `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`, `index-entries.json`
- `scripts/check-module-invariants.sh`, `scripts/check-evidence-probes.sh`
- lean-lsp `lean_run_code` (core-Lean evaluation of the `Qp` reach-set iteration)
**Artifacts**:
- `specs/778_residue_index_modulus_convention_record/reports/01_residue-index-modulus-convention.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The ambiguity is a name collision, and naming the modulus dissolves it rather than choosing
  between two off-by-one readings.** `ladderIndexRes T P B` takes both residues modulo `P + 1`,
  so its `P` is a *modulus minus one*; `reachN_eventually_periodic` returns a *period* `p` with
  `1 ≤ p`. The two quantities share the letter `P` and are not the same number. The recommended
  record states that an instantiation is fixed by naming the modulus `m` (`1 ≤ m`) and setting
  `P := m - 1`, so an exhibited period `p` enters as `m := p`, i.e. `P := p - 1`.
- **Both readings are refuted, and the record should say so on compiled ground.** The uniform
  refutation is `object_only_parameters_refuted`, which quantifies over every `(T, P, B)`;
  mechanism (5)'s `reach_period_refuted` holds for every `P` with `¬ 3 ∣ (P + 1)`, covering
  moduli `1` and `2` on fixture B. Stating the convention therefore changes no theorem and keeps
  every probe statement convention-independent, exactly as the task requires.
- **The task description's justification needs re-sourcing.** "The modulus-3 reading is already
  refuted by the existing parity observable" is true at the mechanism level but has no compiled
  theorem: `cell_succ_ne` is at countdown offset `1` only, and `gate_parity_separates` is a
  positive gate carrying `1 ≤ P`. The compiled statement that does cover modulus `3` is
  `object_only_parameters_refuted`. The record must cite that and mark the odd-modulus parity
  collision as a mechanism-level consequence, since no new theorem is to be added.
- **A third site carries the gap.** `RaySummary/README.md` line 781 asserts the convention is
  unrecorded. Landing the record in the two files the task names would leave the library README
  contradicting it. The probe's own docstring section carries the same sentence.
- **One adjacent inaccuracy is worth correcting in the same edit.** The parameter-origin rule
  says the modulus must "dominate" every letter-definable sub-object period. What the compiled
  hypothesis `¬ 3 ∣ (P + 1)` establishes is **divisibility**, not magnitude: modulus `100`
  exceeds `3` and is still refuted. The clause should read "be a multiple of".
- **Implementation risk is a gate collision, not a proof.** The docstring edit changes
  `LadderModel.lean`'s line count, which the hand-maintained README row (`| LadderModel.lean |
  219 |`) and `check-module-invariants.sh`'s generated inventory blocks both track; the note edit
  changes a `line_count` recorded in the extension's `index-entries.json`.

## Context & Scope

The open question behind all of this is the cell-index factorization lemma for the admissible
ladder carrier: a `Fintype I` and a map `LadderState Q pend → I` with
`index x = index y → cellAt … x = cellAt … y`. The residue-carrying six-coordinate candidate

```
ladderIndexRes T P B x = (q, min c T, c % (P+1), min n T, n % (P+1), clip (n - c) [-B, B])
```

is refuted at both of its object-exhibited parameters. The scope of this task is purely a record
gap inside that settled negative result: the index's residue coordinates are taken modulo
`P + 1`, the exhibited period from `reachN_eventually_periodic` satisfies `1 ≤ P`, and no
record states which quantity the index's parameter is.

In scope: the docstring and note wording that fixes the convention. Out of scope: any change to a
theorem statement, any new declaration, any re-attempt at the factorization lemma.

## Findings

### Codebase Patterns

**The two quantities, verbatim.** The index's parameter enters only through `% (P + 1)` and
`Fin (P + 1)` (`ladder-residue-index-refutation.lean:145-152`, ported byte-for-byte from
`ladder-cell-index-obstructions.lean:608-615`). The exhibited period enters as the `P` of

```lean
theorem reachN_eventually_periodic {Q : Type} [Fintype Q] [DecidableEq Q]
    (step : Q → Q → Bool) (S : Finset Q) :
    ∃ T P : ℕ, 1 ≤ P ∧
      ∀ k, T ≤ k → (reachStep step)^[k + P] S = (reachStep step)^[k] S
```

(`ladder-cell-index-obstructions.lean:754-759`). The residue coordinate exists to make countdowns
that the region-end observable cannot separate congruent; that holds of `c` and `c + p` only when
the modulus is `p`, which is the `P := p - 1` reading. Under `P := p` the modulus is `p + 1` and
`c` is not congruent to `c + p`, so the coordinate is not aligned with the periodicity it was
introduced for.

**The note already treats `P + 1` as the modulus.** The parameter-origin rule's third bullet
begins "`P + 1`, the modulus, must dominate the period of every letter-definable sub-object"
(`ladder-counter-observables.md:142-146`). That phrasing is already consistent with the
recommended convention and inconsistent with the `P := p` reading.

**Three sites carry the gap.** The deliverable the task names is two files; a repository grep for
`unrecorded` finds a third inside the main library:

| Site | Line | What it says |
|------|------|--------------|
| `RaySummary/LadderModel.lean` | 74-88 | refutation at both parameters, no convention stated |
| lean source store `ladder-counter-observables.md` | 93-94 | "under the unrecorded `P` versus `P + 1` instantiation convention" |
| `RaySummary/README.md` | 781 | "both readings of period 1 under the unrecorded `P` versus `P + 1` convention" |
| `ladder-residue-index-refutation.lean` | 66-72 | docstring section "The `P` versus `P + 1` convention": "no record fixes whether …" |

`scripts/check-evidence-probes.sh` line 1007 says only "both readings of period 1", which stays
accurate under either outcome and needs no edit.

**Generated-count surfaces the edit disturbs.** `RaySummary/README.md` is *not* wrapped in
`<!-- BEGIN GENERATED: inventory … -->` markers, so its `| LadderModel.lean | 219 |` row is
hand-maintained and no gate catches its drift; the root `README.md:19` block
(`dir=FormalSystem rows=totals`) *is* machine-owned and aggregates the line count.
The issue log of the originating task records that a docstring-only edit to this same file tripped
`check-module-invariants.sh`'s INV group on stale generated inventory blocks in three READMEs, and
was resolved with the script's own `--emit-inventory`. Separately, the extension source store's
`index-entries.json` records `"line_count": 180` for the note, matching it exactly today.

### External Resources

**What is compiled, and with which hypothesis.** These are the statements the record may cite:

| Theorem | Probe | Parameter coverage |
|---------|-------|--------------------|
| `object_only_parameters_refuted` | residue-index refutation | every `(T, P, B)`, so every modulus |
| `reach_period_refuted (h3 : ¬ 3 ∣ (P + 1))` | residue-index refutation | every modulus not divisible by `3` |
| `gate_parity_separates (hP : 1 ≤ P)` | cell-index obstructions | positive gate; needs modulus `≥ 2` |
| `cell_succ_ne (tg c n)` | cell-index obstructions | cells at `c` and `c + 1` differ, every `c`, `n` |
| `ladderIndex_not_factoring (B)` | cell-index obstructions | the three-coordinate index, every `B` |

Two consequences for wording. First, `reach_period_refuted`'s hypothesis is a **divisibility**
condition: a modulus of `100` is far larger than `3` and still refuted, so "dominate" in the
parameter-origin rule understates what is proved. Second, there is no compiled theorem separating
cells at countdown offset `3`. The generic ingredient exists — `phiP_mem_iff_of_mem_cell` gives
`phiP ∈ T ↔ tagAt tg c = true` for every `c` — so the odd-modulus collision is a few lines from
compiled material, but it is not itself compiled, and the task forbids adding it.

**The exhibited period is not a single number, for two reasons beyond the off-by-one.** A
core-Lean evaluation of `reachStep` on the `Qp` fixture (`lean_run_code`, no Mathlib import, no
project build) gives:

| Start set | Behaviour | Minimal period | Threshold |
|-----------|-----------|----------------|-----------|
| `{(true, false)}` (pending singleton) | alternates between two sets | 2 | 2 |
| `Finset.univ` | constant from the start | 1 | 0 |

So the task description's premise that the `Qp` fixture's own reach-set period is `2` is correct
for the start set the observable uses (the current object state), and the same object exhibits
period `1` from a different start set. On top of that, `reachN_eventually_periodic` is an
existential satisfied by any multiple of a period and any larger threshold, so it exhibits no
canonical `(T, P)` at all. The record should say that "the object's period" is not a well-defined
instantiation target, which independently reinforces the rule's conclusion that the modulus is
object-and-formula-derived.

**Each reading degenerates, on a different fixture.** This is the argument that no instantiation
is privileged, and it is worth stating because it is sharper than "both are refuted":

- `P := p` on `Qp`: `p = 2`, so the modulus is `3`, odd. The residue coordinate then fails to
  determine the countdown parity that mechanism (2) made it necessary for, colliding `c` with
  `c + 3`. Mechanism-level; the compiled cover is `object_only_parameters_refuted`.
- `P := p - 1` on fixture B: `p = 1`, so `P = 0` and the modulus is `1`. Both residue
  coordinates become constant and the index collapses to the three-coordinate candidate already
  refuted by `ladderIndex_not_factoring`. The constraint this implies, `2 ≤ m`, is exactly the
  `1 ≤ P` hypothesis `gate_parity_separates` already carries.

### Recommendations

**Do both halves of the deliverable's disjunction**: state the convention *and* state that no
refutation turns on it. The task permits either; doing both costs two sentences and leaves no
successor able to re-open the question.

**Recommended convention, for the `LadderModel.lean` docstring** (insert into the paragraph at
lines 74-88, after the sentence naming the two refuted parameters; wording to be finalised by the
implementer, the content is what matters):

> The candidate's `P` is a modulus minus one, not a period: both residue coordinates are taken
> modulo `P + 1`, so an instantiation is fixed by naming the modulus `m` with `1 ≤ m` and setting
> `P := m - 1`, and a period `p` exhibited by `reachN_eventually_periodic` (which gives `1 ≤ p`)
> enters as `m := p`. No refutation turns on that convention:
> `object_only_parameters_refuted` quantifies over every `(T, P, B)` and `reach_period_refuted`
> holds for every modulus not divisible by `3`, so both readings of the exhibited period `1` fall
> (moduli `1` and `2`). At `m = 1` both residue coordinates are constant and the index collapses
> to the three-coordinate candidate refuted at the countdown coordinate, so `2 ≤ m` is forced —
> the hypothesis the parity gate of that family already carries.

**For the note** (`ladder-counter-observables.md`, source store only):

1. Replace the clause at lines 93-94 so it reads as "both readings of the exhibited period `1`
   (moduli `2` and `1`)" and points at the parameter-origin rule, with no claim about what is or
   is not on record.
2. Extend the modulus bullet (lines 142-146) with the convention: `P + 1` is the modulus, the
   instantiation is specified by `m` with `P := m - 1`, and `2 ≤ m` is forced because `m = 1`
   trivialises both residue coordinates.
3. Sharpen the same bullet's "must dominate the period of every letter-definable sub-object" to
   "must be a multiple of the period of every letter-definable sub-object", with the one-clause
   reason that `reach_period_refuted` refutes every modulus `m` with `3 ∤ m`, including moduli
   larger than `3`.
4. Consider adding, to the same bullet or the gate-5 row, that `reachN_eventually_periodic`
   exhibits no canonical period: its `(T, P)` depends on the start set `S` and is satisfied by any
   multiple of a period, which is a second reason the modulus cannot be read off the object.

**For `RaySummary/README.md`**: replace line 781's "both readings of period 1 under the unrecorded
`P` versus `P + 1` convention" with the reading-neutral form ("both readings of the exhibited
period `1`, moduli `1` and `2`"). This is a correctness edit, not scope creep: leaving it would
have the library README deny the record the task creates.

**For the probe docstring** (`ladder-residue-index-refutation.lean`, section "The `P` versus
`P + 1` convention"): restate the section so it names the convention and keeps its own
convention-independence claim, with **every theorem statement untouched**. Recompiling the probe
(`lake env lean specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`,
1549 lines) is the cost of this one; it is optional in the sense that no gate fails without it,
but the current sentence becomes false the moment the record lands.

**Recommended `file_scope` for the implementation phase** (no overlap with the concurrent
siblings, which hold `Semantics/Presheaf/*` and `Decidability/PlusSlicedCertificate/*`):

```
FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean
FormalSystem/Metalogic/Decidability/RaySummary/README.md
README.md                                  # generated inventory totals only
/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md
/home/benjamin/.config/nvim/agent-system/extensions/lean/index-entries.json
specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean   # docstring only
```

**Verification obligations, in order:**

1. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`, detached, to confirm the docstring edit is inert.
2. `bash scripts/check-module-invariants.sh`; resolve any INV finding with
   `bash scripts/check-module-invariants.sh --emit-inventory` and commit the regenerated blocks
   with the same change.
3. Hand-update the `| LadderModel.lean | 219 |` count in `RaySummary/README.md`; no gate covers
   that unwrapped table.
4. Update `"line_count"` for the note in the extension's `index-entries.json`.
5. If the probe docstring is edited: `lake env lean` on the probe, then
   `bash scripts/check-evidence-probes.sh`.

## Decisions

- **Name the modulus, do not pick between `P` and `P - 1`.** Recording "the modulus is `P + 1`;
  an instantiation names `m` and sets `P := m - 1`" removes the ambiguity at its source rather
  than resolving an off-by-one by fiat. The alternative — declaring `P := period - 1` without
  saying why — leaves the same collision of names in place for the next reader.
- **Ground the "both readings refuted" claim on `object_only_parameters_refuted`, not on the
  parity observable.** The parity route has no compiled instance at offset `3`, and the task bars
  adding one.
- **Treat `RaySummary/README.md` line 781 as in scope.** A record that one of the repository's own
  documents contradicts is not a record.
- **Do not add the offset-3 parity theorem, do not touch any probe statement, do not introduce a
  seventh coordinate or a successor candidate.** The task is a record gap and the refutations are
  already uniform.
- **Do not hand-patch `.claude/**`.** The deployed copy of the note is stale for the lean
  extension already (three mechanisms, not five), independently of this task; the source store is
  the edit target and a redeploy is the only sanctioned way to refresh the deployed tree.

## Risks & Mitigations

- **Gate collision on generated line counts** (observed once already on this exact file). The
  docstring grows by roughly ten lines, which moves `LadderModel.lean`'s count and the
  `FormalSystem` totals. Mitigation: run `check-module-invariants.sh`, regenerate with
  `--emit-inventory`, and hand-fix the unwrapped `RaySummary` row in the same change.
- **Source-store staging hazard.** The originating task recorded a pre-existing uncommitted hunk
  in the source store's `index-entries.json` and a `git-commit-scoped.sh` whole-file staging
  quirk. Mitigation: re-read that file immediately before editing, and verify the staged blob
  contains only this change.
- **Probe recompile cost.** Editing the probe docstring forces a 1549-line `lake env lean` run.
  Mitigation: make it the last edit, detached through the build guard, and skip it only by
  consciously accepting that one probe sentence stays inaccurate.
- **Wording rules.** `LadderModel.lean` and `RaySummary/README.md` are deliverables, so the
  no-record-versioning rule applies: the new text must state the convention in the present tense
  and must not say "unrecorded", "previously", "formerly", or "now recorded".
- **Deployed-tree divergence persists.** The edited note will not reach `.claude/` until a
  redeploy. Mitigation: state this in the summary rather than patching the deployed copy.

## Tactic Survey Results

- Not applicable (no proof obligation; no tactic survey performed). The task adds no declaration
  and no goal state exists to attack. The one mechanical check this research ran was a
  core-Lean `#eval` of the `Qp` reach-set iteration through `lean_run_code`, reported under
  Findings rather than here.

## Context Extension Recommendations

- **Topic**: The instantiation convention for residue coordinates in a counter index.
  **Gap**: `ladder-counter-observables.md`'s parameter-origin rule names `P + 1` as the modulus
  but does not say how an exhibited period becomes a `P`, and states the modulus condition as
  magnitude ("dominate") where the compiled hypothesis is divisibility.
  **Recommendation**: extend the modulus bullet of that existing note, as itemised above. No new
  context file is needed.
- **Topic**: What `reachN_eventually_periodic` does and does not exhibit.
  **Gap**: nothing records that its `(T, P)` depends on the start set and is non-minimal, which is
  a standing invitation to read "the object's period" as a single number.
  **Recommendation**: one sentence in the same note's mechanism (5) or gate-5 row.

## Appendix

**Searches and checks run**

- `grep -rln "ladderIndexRes"` across `*.lean` and `*.md`, excluding `.lake`, to enumerate sites.
- `grep -rn "unrecorded"` across deliverable paths, which surfaced the third site.
- `grep -n "BEGIN GENERATED"` across `*.md` to establish which inventory blocks are machine-owned
  and that the `RaySummary` table is not among them.
- `lean_run_code` with a core-Lean `List` model of `reachStep` on `Qp`: iterates from the pending
  singleton and from `univ`, plus equality probes at offsets `1` and `2` to read off minimality.
- `.claude-extensions.json` parsed for the lean extension's `source_dir`
  (`/home/benjamin/.config/nvim/agent-system/extensions/lean`), per the source-store boundary rule.
- Issue log of the originating task read in full for implementation hazards; the INV gate
  collision and the source-store staging quirk both come from there.

**Evidence tier**: lean-lsp was reachable and the one evaluation ran through it. No
`lean_local_search` negative result is relied on anywhere in this report, so the index-state
interpretation rule does not bear on any finding.

**Blocked tools**: `lean_diagnostic_messages` and `lean_file_outline` were not called.
