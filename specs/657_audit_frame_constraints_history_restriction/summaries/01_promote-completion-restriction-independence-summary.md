# Implementation Summary: Task #657

- **Task**: 657 - audit_frame_constraints_history_restriction
- **Status**: [COMPLETED]
- **Started**: 2026-09-23
- **Completed**: 2026-09-23
- **Effort**: ~4 hours
- **Dependencies**: Task 656 (general frames + `FrameOver.IsRegular`), Task 659 (the existing
  constraint witnesses), Task 658 (the state-topology collection)
- **Artifacts**: plans/01_promote-completion-restriction-independence.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The frame-constraint audit returned a verdict rather than an open question, and this round
promoted its five sorry-free probes into the library. All four of `def:frame`'s constraints are
**kept exactly as stated** (D1), on the evidence of a now-complete independence matrix; what
landed is a set of *results about* those constraints — the exact condition `thm:extension`
consumes, the discrete-time redundancy of *Saturation*, the identification of partial histories
with restrictions of possible worlds, the *Limit*-only reflection law, and the last two
independence witnesses — plus three corrected docstring defects and one relocated design-obstruction
probe. No line of `def:frame`'s axiom list, and no manuscript file, was touched.

## What Changed

### New module

- `FormalSystem/Semantics/Extension/Completion.lean` (388 lines) — created. `PartialHistory.Completion`
  and `CoherentCompletion` with their bridge; `OnePointExtension`;
  `completion_of_onePointExtension` (the extension property gives *Completion* at **no** frame
  constraint); `onePointExtension_of_completion` and `completion_iff_onePointExtension`
  (*Completion* **is** the one-point extension property under *Seriality* + *Limit*, with no
  *Saturation* and no *Compositionality*); `completion_of_isRegular` (the sole route by which
  *Saturation* enters); `extension_of_completion` (`thm:extension` in full, elaborating with **no**
  `[F.IsRegular]` binder at all). Then the discrete-time half: `HasNearest`, `hasNearest_int`,
  `hasNearest_of_succPred`, `completion_of_hasNearest` (*Compositionality* + *Seriality*, with
  **neither** *Saturation* **nor** *Limit*), `extension_of_hasNearest`, `extension_of_isZTime`.

### Existing modules

- `FormalSystem/Semantics/TaskFrame.lean` — added `FrameOver.reflection_of_limit`; re-proved
  `FrameOver.reflection` from it, byte-identical statement; **corrected** `reflection`'s docstring,
  which claimed the zero case used `nullity` (*Seriality* plus *Limit*). The proof body never calls
  `nullity`; the zero case is `eq_of_taskRel_zero` in both directions, i.e. *Limit* alone.
- `FormalSystem/Semantics/PartialHistory.lean` — `restrict`, `restrict_domain`, `restrict_states`
  (both `@[simp]`), `restrict_isPartialHistory`, `extends_restrict`, `restrict_univ`,
  `IsRestriction`, `eq_restrict_of_extends`. The two new `@[simp]` lemmas perturbed **no**
  downstream proof; the full build is green with zero warnings, so the attributes were kept.
- `FormalSystem/Semantics/PartialHistoryOrder.lean` — `restrict_mono`, `restrict_le_restrict_iff`.
  `grep -c IsRegular` on this file is still **0**: the Zorn layer stays constraint-free.
- `FormalSystem/Semantics/Extension/Extension.lean` — `isRestriction_of_isRegular`,
  `exists_restrict_eq`, `exists_worldHistory_restricting_pair`, plus a `## The identification`
  docstring section recording both directions, the asymmetry that is the content, and the four
  reasons `def:world-history` keeps coherence primitive. `extension`'s own statement and proof are
  byte-unchanged.
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — the void frame (empty relation
  on `Bool` over ℤ-time; fails *Seriality*) and the bump frame (identity at `0`, everything at
  `±1`, identity from `|d| ≥ 2`; fails *Compositionality*), 16 declarations, plus a module-docstring
  paragraph recording that the independence matrix is now **complete** and recording honestly the
  packaging asymmetry: three rows are certified at the frame level, the *Saturation* row at the
  bare-relation level only.
- `FormalSystem/Semantics/Extension/Constraint.lean` — **corrected** two docstrings.
  `constraint`'s "*Limit* is not consumed either" is false at the level of the elaborated proof
  term: `constraint` reaches `FrameOver.reflection` on three paths and `reflection`'s `d = 0`
  branch is *Limit*, reachable via `nonempty_fib_of_serial` at `t = z`. The accurate consumption
  list `C→`, `C←`, `S`, `L` — and **not** `Sat` — replaces it, in both that docstring and
  `nonempty_fib_of_serial`'s "No other axiom is used".
- `FormalSystem/Semantics/Extension/Step.lean` — **corrected** the module docstring's claim that a
  `grep` for `Saturation` would find a single consuming proof. Replaced with the claim the audit
  verified: `step` is the sole site where *Saturation* is **eliminated** into a non-*Saturation*
  conclusion, with the five transport/restatement sites named.
- `FormalSystem/Semantics/Extension.lean`, `FormalSystem.lean` — the new module wired in.
- `FormalSystem/Semantics/Extension/README.md`, `FormalSystem/Semantics/README.md`, and the three
  generated-inventory READMEs — refreshed, including the same *Saturation* elimination-site
  correction and re-measured line counts.
- `docs/theorem-index.md` — a new `### The extension chain, and what def:frame's constraints buy it`
  section (11 rows) plus 8 witness rows in the state-topology section; all 19 pinned by C14.
- `docs/reference/state-topology-appendix-support.md` — one new row for the completed independence
  matrix, with the packaging asymmetry recorded.
- `scripts/check-module-invariants.sh` — 19 declarations appended to `C14_BASELINE` and to the
  `C14LEAN` heredoc, in the same order in both.
- `scripts/check-evidence-probes.sh` — generalized `EVIDENCE` from a single hard-coded collection
  to `specs/evidence`, with collection-relative `WIRED`/`DEFERRED` entries.
- `specs/evidence/frame-constraints-audit/mixed-sign-composition-obstruction.lean` — moved from
  `specs/657_.../probes/MixedSign.lean`, re-headed to the evidence genre, and rewired to **import**
  the promoted `Completion` and `FrameOver.reflection_of_limit` instead of copying them.

## Decisions

- **`Completion` is a lemma, never a constraint.** D1 keeps all four axioms as stated. The R4
  replacement option is specified in the report and deliberately not taken; `CoherentCompletion`
  is landed only so the option stays expressible without re-deriving it.
- **`TotalComp` stays out of `FormalSystem/`.** A condition the library must *not* satisfy does not
  get a library home. `grep -rn "TotalComp" FormalSystem/` returns nothing, and the evidence probe
  now protects that invariant against rot.
- **Coherence stays primitive; restriction is derived.** The four reasons are recorded in
  `Extension/Extension.lean`'s docstring rather than only in the report.
- **No label-shaped token for a label the paper does not have.** The audit proposes two new paper
  labels; writing either as a `label:`-shaped token anywhere in the tree makes C15 resolve it
  against `paper-definitions-of-record.md` and fail. Both proposals are described in prose and in
  this summary's handoff section instead.

## Plan Deviations

- **Phase 1** altered: `FrameOver.reflection_of_limit` landed at
  `[propext, Classical.choice, Quot.sound]`, not the plan's predicted `[propext]`. The probe's
  figure was measured at the `TaskFrame` level; at the `FrameOver` level
  `eq_of_taskRel_zero_of_limit` already carries choice. `FrameOver.reflection`'s own profile is
  identical before and after, which is the invariant that mattered.
- **Phase 2** altered: `Extension/Completion.lean` imports `Extension.Step`, not
  `Extension.Admissible`, and the aggregator import is sited **after** `Step` rather than before
  it. `completion_of_isRegular` is `completion_of_onePointExtension (fun τ z => step F τ z)`, so
  `step` must be in scope. `Step.lean` imports `Admissible.lean`, so the import closure is
  otherwise unchanged.
- **Phase 8** skipped one item: no `README.md` was added to
  `specs/evidence/frame-constraints-audit/`. Neither sibling collection has one
  (`ls specs/evidence/*/README.md` returns nothing); the convention is a header docstring in each
  probe, which the relocated file now carries.
- **Phase 8** closed `[COMPLETED WITH EXCLUSIONS]`: `scripts/check-evidence-probes.sh` cannot exit
  0, for a **pre-existing** reason independent of this task. See Follow-ups.
- **Phase 10** extended in scope: C15 requires every theorem-index row to carry a matching
  `Paper: <anchor>` line in its declaration's own docstring. 19 such lines were added, and the two
  proposed-but-nonexistent paper labels were removed from every in-tree file.

## Verification

- **Build**: `lake build` (full project, guarded and detached) — **success**, 2,725 jobs,
  **0 errors and 0 warnings** (so `--wfail` is satisfied).
- **Sorry count**: 0. `lean-sorry-census.sh FormalSystem Tests` reports `sorry_count: 0`; C3's
  repo-wide structural inventory is ZERO across `FormalSystem/` and `BimodalTools/`.
- **Vacuous count**: 0.
- **Axiom count**: 0 new axioms. `grep -rn "^axiom " ` over the resolved source roots is unchanged.
- **`bash scripts/check-module-invariants.sh`**: exit **0** — every check passes, including
  C1 (both builds), C2, C3, C14 (**both** halves: the content scan and the 19 newly pinned
  declarations), C15 (all 61 anchor citations resolve; all 186 index rows anchored at their
  declaration), C20, C21, C24, C33 and the generated-inventory check.
- **`lake exe mk_all --lib FormalSystem --check`**: exit 0.
- **`bash scripts/check-paper-definitions.sh`**: exit 0; no recorded quotation disturbed, no
  `verbatim:` line changed.
- **`bash scripts/readme-lint.sh`**: RESULT PASS.
- **`bash scripts/check-evidence-probes.sh`**: the new probe PASSes, as do three of the four
  pre-existing ones. The fourth fails for a pre-existing reason — see Follow-ups.
- **Tests**: `lake build BimodalTest` exits 0 (C1's second assertion); no test required repair.

### Per-declaration axiom record

`pcq` abbreviates `[propext, Classical.choice, Quot.sound]`.

| Declaration | Axioms |
|---|---|
| `FrameOver.reflection_of_limit` | pcq |
| `FrameOver.reflection` (unchanged by this task) | pcq |
| `PartialHistory.Completion`, `.CoherentCompletion`, `.OnePointExtension`, `.HasNearest`, `.IsRestriction` | `[propext]` |
| `PartialHistory.completion_iff_coherentCompletion` | `[propext]` |
| `PartialHistory.completion_of_onePointExtension` | `[propext]` |
| `PartialHistory.onePointExtension_of_completion` | pcq |
| `PartialHistory.completion_iff_onePointExtension` | pcq |
| `PartialHistory.completion_of_isRegular` | pcq |
| `PartialHistory.extension_of_completion` | pcq |
| `PartialHistory.hasNearest_int`, `.hasNearest_of_succPred` | pcq |
| `PartialHistory.completion_of_hasNearest`, `.extension_of_hasNearest`, `.extension_of_isZTime` | pcq |
| `PartialHistory.restrict`, `.restrict_domain`, `.restrict_states`, `.restrict_isPartialHistory`, `.extends_restrict` | `[propext]` |
| `PartialHistory.restrict_univ`, `.eq_restrict_of_extends` | `[propext, Quot.sound]` |
| `PartialHistory.restrict_mono`, `.restrict_le_restrict_iff` | `[propext]` |
| `PartialHistory.isRestriction_of_isRegular`, `.exists_restrict_eq`, `.exists_worldHistory_restricting_pair` | pcq |
| `StateTopology.voidFrame`, `.bumpFrame` | `[propext]` |
| `StateTopology.voidFrame_compositional`, `.voidFrame_not_serial` | `[propext, Quot.sound]` |
| `StateTopology.voidFrame_limit`, `.voidFrame_saturation` | pcq |
| `StateTopology.bumpFrame_serial`, `.bumpFrame_limit`, `.bumpFrame_saturation`, `.bumpFrame_not_compositional` | pcq |

### The *Saturation* application sites, re-derived

`grep -rn "\.saturation\b" FormalSystem/` finds six applications in proof bodies. `step`
(`Extension/Step.lean`) is the only one that **eliminates** *Saturation* into a conclusion not
mentioning it. The other five take *Saturation* in and give *Saturation* out:
`FrameOver.rev_isRegular` (`OpenLanguage/OpenReversal.lean`), `FrameOver.map`
(`Semantics/IntTransfer.lean`), `FrameOver.translationProduct`
(`Semantics/Frames/TranslationProduct.lean`), `regionFrame_saturation`
(`Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`) and `zTaskFrameV2_saturation`
(`Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`). Every other occurrence is an
accessor definition or an `example` acceptance test in `Semantics/TaskFrame.lean`.
`completion_of_isRegular` adds **no** new site: it routes through `step`.

### Non-Goals, each confirmed by an explicit check

| Non-Goal | Command | Result |
|---|---|---|
| `TotalComp` never enters the library | `grep -rn "TotalComp" FormalSystem/ \| wc -l` | `0` |
| `def:frame`'s four constraints byte-unchanged | `git diff 7da5d4402 HEAD -- FormalSystem/Semantics/TaskFrame.lean \| grep -E '^[-+](def\|theorem\|structure\|class) '` | only `reflection` / `reflection_of_limit` |
| No manuscript file touched | `git status --short \| grep -i "possible_worlds\|\.typ"` | empty |
| Zorn layer stays constraint-free | `grep -c IsRegular FormalSystem/Semantics/PartialHistoryOrder.lean` | `0` |
| No proposed label recorded as a paper anchor | `grep -n "lem:completion\|cor:restriction" docs/reference/paper-definitions-of-record.md` | empty |
| `Completion` defined exactly once | `grep -rn "def Completion" FormalSystem/ \| wc -l` | `1` |

## Impacts

- The manuscript now has citable declarations for four of the report's five recommendations (R1,
  R2, R3, R5), so the author's edits to `possible_worlds.tex` can cite the library rather than a
  task-directory probe.
- The extension chain's constraint consumption is now recorded accurately in the tree, in three
  places that previously said something false. A reader tracing where *Limit* enters will now find
  `FrameOver.reflection_of_limit` and the corrected `constraint` docstring rather than a "not
  consumed" claim.
- `extension_of_completion` elaborating with no `[F.IsRegular]` binder is a machine-checked
  certificate that the Zorn layer and `def:frame`'s constraints meet only at `extension`. Any
  future edit that threads a constraint into `PartialHistoryOrder.lean` will break it.
- The independence matrix is complete, so "is constraint X independent of the other three?" is now
  answerable by citation for every X.

## The manuscript handoff

The author makes these edits to `possible_worlds.tex` **after** this task and the task-frame
refactor are both complete. Each block below is the report's proposed statement, now citing the
**promoted** declaration rather than the probe.

### R1 — record *Completion* as a lemma, immediately before `lem:step`

```latex
\begin{Lthm} \label{lem:completion}
	For any task frame $\F = \tuple{W, \D, \Rightarrow}$, partial history $\tau : X \to W$, and duration $z \in D$, there is a world state $u \in W$ where $\tau(t) \Rightarrow_{z - t} u$ for every $t \in X$.
\end{Lthm}
```

With a remark: this is **equivalent** to `lem:step`, and is what `lem:step` actually consumes;
*Saturation* enters only to establish it.

- Certified by `FormalSystem.Semantics.PartialHistory.completion_of_isRegular` and
  `...completion_iff_onePointExtension` (`FormalSystem/Semantics/Extension/Completion.lean`).
- Manuscript sites: `lem:step`'s proof (it would cite `lem:completion` rather than *Saturation*
  directly); `thm:extension`'s footnote, which attributes `cor:occurrence` to "*Seriality* and
  *Saturation*" — accurate, but `lem:completion` is the sharper attribution.

### R2 — state the identification as a corollary, after `thm:extension`

```latex
\begin{Cthm} \label{cor:restriction}
	The partial histories over a task frame $\F = \tuple{W, \D, \Rightarrow}$ are exactly the restrictions of the possible worlds in $H_{\F}$ to nonempty sets of times: every such restriction is a partial history, and every partial history $\tau : X \to W$ is the restriction to $X$ of some $\sigma \in H_{\F}$. Moreover $\sigma$ may be chosen uniformly along the extension order: whenever $\sigma$ extends $\tau$, a single possible world restricts to both.
\end{Cthm}
```

The remark should say that the **first** conjunct costs no frame constraint and the second is
`thm:extension` — the asymmetry is the content.

- Certified by `PartialHistory.restrict` and `...restrict_isPartialHistory`
  (`FormalSystem/Semantics/PartialHistory.lean`), `...exists_restrict_eq` and
  `...exists_worldHistory_restricting_pair` (`FormalSystem/Semantics/Extension/Extension.lean`),
  and `...restrict_le_restrict_iff` (`FormalSystem/Semantics/PartialHistoryOrder.lean`) for the
  free converse half of the order claim.
- Manuscript sites: `def:world-history` gains a forward reference; `thm:extension` gains the
  corollary beneath it; any prose reading "partial histories are pieces of possible worlds" can
  cite the label instead.

### R3 — one sentence on where *Limit* actually enters

Add to `def:task-relation`'s remark, or to `lem:nullity`'s:

> The reflection convention read back as a law — $w \Rightarrow_d u$ if and only if
> $u \Rightarrow_{-d} w$ for every $d \in D$ — is definitional away from $d = 0$ and follows from
> *Limit* at $d = 0$; it is therefore a consequence of `def:frame` rather than a further
> stipulation.

- Certified by `FormalSystem.Semantics.FrameOver.reflection_of_limit`
  (`FormalSystem/Semantics/TaskFrame.lean`).
- Manuscript sites: `def:task-relation`'s remark (or `lem:nullity`'s). This is the finding most
  likely to save a reader a wrong inference, and it costs one sentence.

### R5 — the determinism companion to `cor:saturation-finite`

```latex
\begin{Lthm} \label{lem:saturation-deterministic}
	Every \textsc{Deterministic} task frame $\F = \tuple{W, \D, \Rightarrow}$ satisfies \textit{Saturation}, choice-free.
\end{Lthm}
```

- Certified **today, with no promotion needed** by
  `FormalSystem.Semantics.TaskFrame.saturation_of_deterministic` (via
  `...saturation_of_fib_subsingleton`).
- Manuscript site: beside `cor:saturation-finite`. Together with the ℤ-time redundancy result
  (`extension_of_isZTime`) it tells the reader that the least intuitive constraint is automatic in
  the three most familiar classes — finite carriers, deterministic frames, and discrete time.

### R4 — specified, not taken

The replacement of *Saturation* by *Completion* inside `def:frame` is fully specified in the
report (§R4) and deliberately **not** recommended. The one piece landed for it is
`PartialHistory.CoherentCompletion` and `completion_iff_coherentCompletion`, the bare-relation form
the replacement would need, so the option remains expressible without re-derivation. Its blocker is
unchanged: `Saturation → Completion` is proved, the converse is **open**, and a conditional converse
plus its obstruction is on record at
`specs/evidence/frame-constraints-audit/mixed-sign-composition-obstruction.lean`.

### R6 — the recommended successor task

The final-topology coincidence condition (report §5a). `𝒩_F` is strictly below the final topology
of all histories in general (`Hedgehog.finalTopology_ne_nbhdTopology`) and coincides with it on the
metric frame (`MetricFrame.finalTopology_eq_nbhdTopology`); a **frame condition** equivalent to
coincidence is left UNVERIFIED and open. Inputs already compiled:
`TaskFrame.finalTopology_eq_of_surjective_open_history` and the two witnesses above.

### D1, recorded prominently

**The four constraints are kept exactly as stated.** Nothing is added, nothing is dropped, nothing
is weakened. This is reached on evidence — a completed independence matrix, every row a compiled
witness — and not by default. The four recommendations above are additions of *recorded results*;
none alters `def:frame`'s axiom list.

## Follow-ups

- **A pre-existing evidence probe does not compile**, so `scripts/check-evidence-probes.sh` cannot
  exit 0. `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean` cites
  `FrameOver.ofReflective_taskRel_eq` against a frame built by `ofReflectiveRegular` — the
  constructor split introduced by the task-frame refactor. Substituting the correct
  `ofReflectiveRegular_taskRel_eq` does **not** fix it: `RefinedFilteredTaskFrame._proof_4` carries
  a definitionally-unfolded `TaskFrame.Limit`, so no syntactic rewrite matches
  (`Application type mismatch: ... has type ∀ (w u : FilteredWorld phi), ... but is expected to
  have type TaskFrame.Limit (refinedFilteredTaskRel intOrder phi)`). Repairing it is real work on
  an unrelated decision layer and was left untouched, per the plan's instruction that the existing
  entries' behavior stay byte-identical. It warrants its own task; the script's own rule applies —
  repair the citation drift, never weaken the obstruction.
- **R6** is the recommended successor task, and is the most interesting open question in this
  neighbourhood.
- **Whether the rational two-origin frame satisfies `Completion`** would settle
  `Completion → Saturation` unconditionally. With `extension_of_completion` now in the library this
  is a one-probe task rather than a research round.
- The three probes whose content is fully promoted (`Completion.lean`, `Nearest.lean`,
  `Restriction.lean`) remain under `specs/657_.../probes/` and will be archived with the task.
  The library is now the record; they need no rot guard.

## References

- `specs/657_audit_frame_constraints_history_restriction/reports/01_audit-frame-constraints-restriction.md`
- `specs/657_audit_frame_constraints_history_restriction/plans/01_promote-completion-restriction-independence.md`
- `specs/evidence/frame-constraints-audit/mixed-sign-composition-obstruction.lean`
- `docs/theorem-index.md`, `docs/reference/state-topology-appendix-support.md`
- `FormalSystem/Semantics/Extension/README.md`, `FormalSystem/Semantics/README.md`
