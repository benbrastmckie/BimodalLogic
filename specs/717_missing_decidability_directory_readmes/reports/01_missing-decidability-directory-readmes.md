# Research Report: Task #717

**Task**: 717 - Write the three missing directory READMEs that fail `scripts/readme-lint.sh` in CI
**Started**: 2026-10-02T00:00:00Z
**Completed**: 2026-10-02T00:00:00Z
**Effort**: Medium (3 README files; ~33 Lean modules to inventory; no Lean proof work)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `scripts/readme-lint.sh`, `scripts/check-module-invariants.sh`, `.github/workflows/ci.yml`
- Standards: `docs/development/DIRECTORY_README_STANDARD.md`, `docs/reference/readme-standard.md`
- Exemplars: `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md`, `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md`
- Primary content source: the three directories' 33 Lean module docstrings, plus the re-export docstring in `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean`
- lean-lsp MCP: not used (no theorem discovery required; see Decisions)
- Literature source: none referenced by the task
**Artifacts**:
- `specs/717_missing_decidability_directory_readmes/reports/01_missing-decidability-directory-readmes.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The acceptance criterion is reachable with three new files and nothing else.** `bash scripts/readme-lint.sh FormalSystem BimodalTools` currently exits **1** with exactly `Missing READMEs: 3` and `Broken file references: 0`. Only Checks 1 (missing README) and 3 (broken relative links) are gated; Checks 2 (`NOT LISTED`) and 4 (date stamps) are reported but never affect the exit code. So the gate flips to PASS as soon as the three `README.md` files exist *and* no link they introduce fails to resolve.
- **The real risk is not the missing files — it is introducing a broken link.** Check 3 resolves `[text](path)` by bare `grep -oP`, with **no code-fence awareness**. A bracket-paren pair inside a fenced Lean block, or inline notation such as `A[g U e](x)`, is read as a link and will turn the gate red. Every relative link must be verified to resolve from the README's own directory.
- **A second gate shares this surface**: `scripts/check-module-invariants.sh` enforces **C9 — zero task-number citations under `FormalSystem/`**. The new READMEs must cite durable anchors (module names, theorem names, sibling READMEs) and must never say "task N" or reference plan/phase numbering.
- **Content is already written; it needs transcribing, not inventing.** `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean`'s module docstring contains a per-submodule bullet for **23 of 25** modules plus a "closing record" (what is proved / refuted / open, the nine `Certifies` conjuncts, the forced infinite carrier). The two gaps are `HalfRun.lean` and `FixtureStable.lean`, whose own docstrings supply the material (quoted below). `PlusWitnessFamily/README.md` already narrates `Limits/`'s two refutations.
- **All three directories are sorry-free and axiom-free.** The single `grep` hit for `sorry` under `PlusSlicedCertificate/` is prose inside `EmbedComplete.lean`'s docstring, not a tactic. This matters because C14 gates documented sorry/axiom counts against the tree: a README may state "sorry-free", and that statement is true.
- **Recommended shape**: follow the sibling exemplar `WitnessFamily/Compression/README.md` — purpose statement, numbered route narrative, unmarked `| Module | Contents |` table, scope-boundary section — **plus** a `*Last verified: YYYY-MM-DD*` footer (which the exemplar itself lacks, and is warned for). Do **not** add a `<!-- BEGIN GENERATED: inventory -->` marker.

## Context & Scope

### What was researched

1. The exact gating contract of `scripts/readme-lint.sh` (which checks fail the build, which only warn).
2. The adjacent gates that the new files will also be subject to (`check-module-invariants.sh` C9, C13/C14, `INV`).
3. The two README standards in the tree and which one governs a Lean source subdirectory.
4. The depth, section set and house style of the named sibling exemplar and of the parent directory README.
5. The module inventory, route order, dependency position and scope boundaries of all 33 Lean modules across the three target directories.

### Constraints

- **No Lean source may be edited.** This is a documentation task; the acceptance command reads markdown only.
- **Zero-debt / no-deferral**: not applicable in the usual sense (no proofs are written), but the corresponding documentation discipline *is* applicable — a README must not assert a result the tree does not prove. Both `PlusWitnessFamily/Limits/` and `PlusSlicedCertificate/` contain explicit "what is refuted / what is open" records precisely because earlier drafts overclaimed. The new READMEs must preserve that honesty rather than smooth it over.
- **No task-number citations** in any of the three new files (C9, and `.claude/rules/no-task-references-in-deliverables.md`).

### Out of scope for this task

- The 28 `STALE DATE` and 3 `MISSING DATE` warnings elsewhere in the tree. They are ungated and fixing them is a different, larger sweep.
- The ~94 `Files not listed (info)` Check 2 warnings.
- Adding rows for `PlusSlicedCertificate/` and `PlusWitnessFamily/` to `FormalSystem/Metalogic/Decidability/README.md` (see Recommendations — a cheap, optional, non-gating improvement).

## Findings

### Codebase Patterns

#### 1. The gate: what actually fails the build

`scripts/readme-lint.sh` runs four checks. Its header and its exit block agree:

| Check | What it looks for | Gated? |
|---|---|---|
| 1 | every directory containing `.lean` files has a `README.md` | **YES** (`ERRORS`) |
| 2 | every `.lean` basename in a directory appears somewhere in its README | no (reported) |
| 3 | every relative markdown link in a README resolves on disk | **YES** (`ERRORS`) |
| 4 | a `Last verified` / `Last updated` stamp exists and is not older than the directory's last commit | no (reported) |

Final block:

```bash
if [ "$MISSING" -gt 0 ] || [ "$BROKEN" -gt 0 ]; then ... exit 1; else ... exit 0; fi
```

Current measured state (`bash scripts/readme-lint.sh FormalSystem BimodalTools`, exit code **1**):

```
Missing READMEs:          3
Total READMEs found:      72
Markdown files in scope:  72
Broken file references:   0
Files not listed (info):  94
Missing dates (info):     3
```

The three missing paths, verbatim from Check 1:

```
MISSING: FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md (25 .lean files)
MISSING: FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/README.md (5 .lean files)
MISSING: FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/README.md (3 .lean files)
```

CI invokes it at `.github/workflows/ci.yml:159-166` as a named step `readme-lint`, whose `outcome` is aggregated at line 340 (the workflow aggregates rather than short-circuits, per commit `f697f456f`), so this is a real build-visible failure.

#### 2. Check 3's link scan has no code-fence awareness — the principal hazard

```bash
{ grep -oP '\[.*?\]\(\K[^)]+' "$readme" 2>/dev/null || true; } | while read -r link; do
  case "$link" in http://*|https://*) continue ;; esac
  path="${link%%#*}"
  ...
  full_path="$dir/$path"
  if [ ! -e "$full_path" ]; then echo "  BROKEN: ..." ; fi
done
```

Consequences for authoring:

- Any `[...](...)` pair **anywhere** in the file, including inside a ```` ```lean ```` fence, is treated as a link.
- Only `http://` and `https://` are skipped. A bare anchor `[x](#y)` is skipped only because the path becomes empty after `${link%%#*}`.
- Paths resolve relative to the README's own directory via plain concatenation, so `../WitnessFamily/README.md` from `PlusWitnessFamily/Compression/` must be written with the correct depth.

The same hazard is documented independently at `scripts/check-module-invariants.sh` (C32's rationale): the bare link regex matches inline mathematics such as `[z_0, z_1](x, y)` and `f[a](root)` 82 times across live Lean comments. The exemplar `PlusWitnessFamily/README.md` contains `A[g U e]` and `⊥ U ⊥`, which are safe only because no `(` immediately follows the `]`. **Authoring rule for the implementation**: never let a `]` be immediately followed by `(` unless it is a genuine, resolvable relative link or an `http(s)` URL.

#### 3. Adjacent gates the new files are also subject to

| Gate | Scope | Relevance |
|---|---|---|
| C9 — zero task-number citations | `FormalSystem/`, `lakefile.toml`, root `README.md`, `scripts/` | **Binding.** No "task N", no plan/phase numbering in the new READMEs. |
| C12/C13 — path & link resolution | `docs/` + root `README.md` only | Not binding on these files (readme-lint Check 3 covers them instead). |
| C14 — documented axiom/sorry counts match the tree | `docs/`, root `README.md`, and Lean files | Binding on any count a README states. All three directories are sorry-free and axiom-free, so "sorry-free" is accurate. |
| `INV` — generated/registered inventory blocks are current | only files carrying `<!-- BEGIN GENERATED: inventory ... -->` or `<!-- INVENTORY: hand-maintained (dir=...) -->` | **Not binding unless opted into.** Currently PASS. Adding a marker opts the file into exhaustiveness checking. |

`INV` currently passes (`bash scripts/check-module-invariants.sh --emit-inventory --check` → exit 0, `PASS INV every generated inventory block is current, every hand-maintained one is exhaustive`). Only 10 markers exist tree-wide, in 4 files; the named exemplar carries none.

#### 4. Two README standards exist; they disagree on the table shape

| Standard | Governs | Table shape | Stamp |
|---|---|---|---|
| `docs/development/DIRECTORY_README_STANDARD.md` (the one the task names) | Lean source, test, example and docs directories; Templates D-G | "Submodules" list, lightweight 40-70 lines for Template D | not required |
| `docs/reference/readme-standard.md` | `FormalSystem/` tree specifically | required: Title, scope description, module inventory table (`File | Lines | Description`), key definitions, cross-links, `*Last verified: YYYY-MM-DD*` | **required** |

The named exemplar `WitnessFamily/Compression/README.md` follows **neither** literally: it uses a `| Module | Contents |` table with no `Lines` column and has **no** date stamp (it is one of the three `MISSING DATE` warnings). The parent `PlusWitnessFamily/README.md` uses a `- Module — description` bullet list **and** carries `*Last verified: 2026-09-29*`.

**The house style the implementation should actually match** is the exemplar's structure plus the parent's stamp. Rationale: the task explicitly names the exemplar's depth as the bar; the stamp is cheap and silences a warning rather than creating one; and the `Lines` column is a drift liability that nothing gates for an unmarked table.

Dominant stamp format in the tree: `*Last verified: YYYY-MM-DD*` (51 occurrences), with `**Last verified**: YYYY-MM-DD` a minority (6). Use the former.

#### 5. Stamp staleness is a same-commit concern

Check 4 compares the stamp against `git log -1 --format=%cs -- "$dir"`. Creating the README **inside** that directory advances the directory's last-commit date to the commit date. Measured now:

| Directory | last commit date |
|---|---|
| `PlusSlicedCertificate/` | 2026-10-02 |
| `PlusWitnessFamily/Compression/` | 2026-09-30 |
| `PlusWitnessFamily/Limits/` | 2026-09-30 |

Today is 2026-10-02. **The stamp must be the date the implementation commits**, not an earlier date, or a fresh `STALE DATE` warning appears the moment the file lands. (Warning only — ungated — but trivially avoidable.)

#### 6. Exemplar depth: the bar the task sets

`WitnessFamily/Compression/README.md` is ~110 lines and carries:

1. **Purpose statement** — one paragraph naming what the directory is the half *of*, what it composes with, and the headline result (`Decidable (ValidZTime φ)`).
2. **An explicit "nothing here redefines X" clause** — what is consumed as given.
3. **`## The route`** — a numbered 7-step pipeline, one step per layer, in dependency order.
4. **`## Modules`** — a `| Module | Contents |` table listing every `.lean` file with its principal declaration names.
5. **A terminology map against the literature** (`[GKWZ] 2003`, Thm 11.26 / 11.45), with an explicit note that the book's `(ℤ,<)` result is *not* on this path.
6. **Design-decision sections** — "The bound is a grid, not a magnitude"; "Deliberate duplication, and what retires it"; "Dependency on `BiLasso/`" (recording an invariant *widened*, not hidden); "One sub-namespaced declaration".
7. **`## What is out of scope`** — three bulleted boundaries, each with its obstruction named and its residue enumerated.

The parent `PlusWitnessFamily/README.md` adds: a numbered condition table `(C0)`-`(C5)` with "Where / Decided by" columns; a "What this certificate can and cannot refute" section with a **what-went-wrong-and-is-now-fixed** subsection; a "Dependencies / Imported by" block; a `## Related Documentation` link footer; and the `*Last verified:*` stamp.

### Primary content sources per directory

#### A. `PlusWitnessFamily/Limits/` (3 modules, 1,226 lines, sorry-free)

| Module | Lines | Content (from its docstring) |
|---|---|---|
| `Targets.lean` | 456 | The two limit targets as library declarations, parametric in the atom: `nextTrue`/`nextFalse`/`someFuture` tense abbreviations, their `⊡`-duals `someNextTrue`/`someNextFalse`, `hopTarget p = □⟐Xp → (□⟐X¬p → ⊥)`, `pumpTarget p = □⟐Xp → (□⟐X¬p → ((Fp → Fp) → ⊥))`, the two closures `hopClosure`/`pumpClosure`, the non-validities `not_plusValidZTime_hopTarget`/`..._pumpTarget`, the two shared antecedents `plusTruthAt_box_someNextTrue`/`..._False`, and two membership chains (13 and 17 steps). **States no limit itself.** |
| `HopFree.lean` | 326 | **Hop-free families are incomplete**: `not_plusCertifies_hopTarget_of_hopFree` and `not_exists_hopFree_plusCertifies_hopTarget`. A 5-step argument ending in a pigeonhole: a family with `n` indices presents at most `n` constant succession paths, while `hopTarget` forces `lassos.length + 1` distinct state paths. Bounds a *strategy*, not the class. Hypothesis spelled exactly as `TransId.lean`'s `hid`. |
| `NoCertificate.lean` | 444 | **The class is incomplete**: `not_exists_plusCertifies_pumpTarget` — a ℤ-time non-validity **no** `PlusSharingWitnessFamily` certifies, at any time, lasso count or segment lengths, **under no hypothesis**. 7-step argument (long-postponement path `seqPostpone`, `lift`, backward `Fp` propagation, pigeonhole over `lassos.length + 1` times spaced by `S.perFwd`, thread folding via `transRaw_congr_NF`/`data_congr_fwd`, (C2') contradiction). |

Route narrative for `Limits/`: **Targets → {HopFree, NoCertificate}** (both import `Targets`; `HopFree` also imports `../TransId`; `NoCertificate` adds `Mathlib.Data.Fintype.Pigeonhole`, `Ring`, `WLOG`). The two refutations are *parallel siblings*, not a chain — they are about different targets and different hypothesis classes, and `NoCertificate.lean`'s docstring says explicitly that the three shared opening steps are **re-derived rather than imported** because `hopClosure p` and `pumpClosure p` are distinct `Finset PlusFormula` values with no transporting membership fact.

Scope boundaries already stated in-tree and worth carrying into the README:
- `HopFree.lean` does **not** say `TransId.lean` is wrong, does **not** say the six-condition class is incomplete, and does **not** say `hopTarget p` is unrefutable.
- `NoCertificate.lean`: the defect "is not a missing bound and no bound repairs it"; weakening (C2') is not an option while `plusRefutes_of_certifies` is to survive; `plusTruth_iff_mem` and `plusRefutes_of_certifies` are untouched.
- Both modules record **provenance**: transcriptions of compiled probes from the second research round on L⁺ compression, now parametric in the atom.

Imported by: the re-export `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` (all three), and `PlusSlicedCertificate/Sound.lean`, `PlusSlicedCertificate.lean`, `PlusWitnessFamily/Compression/Extract.lean`.

#### B. `PlusWitnessFamily/Compression/` (5 modules, 2,047 lines, sorry-free)

The **L⁺ twin** of `WitnessFamily/Compression/` — i.e. the directory whose README is the named exemplar. The structural parallel is the single most useful authoring fact: the exemplar's 7-step route and its "deliberate duplication / what retires it" section have direct counterparts here, and each module's docstring already states which upstream declarations are **reused by import** versus **transcribed**.

| Module | Lines | Content |
|---|---|---|
| `Types.lean` | 344 | `plusTypeAtM` (type of a position of an arbitrary `FrameOver intOrder` model, filtered through `plusClosureOf (Γ ++ Del)`), `PlusLocalCoherentSeqLab` / `PlusFulfillingSeqLab` (the family conditions with the `Fin W.lassos.length` index dropped), `mem_plusTypeAtM`, `plusTypeAtM_subset`, `plusTypeAtM_localCoherentSeqLab`, `plusTypeAtM_fulfillingSeqLab`. Plus **three truth lemmas with no L⁺ counterpart anywhere in the tree**, proved here: `plusBox_const`, `plusTruth_untl_succ`, `plusTruth_snce_pred`. |
| `Cycle.lean` | 411 | `PlusTypeState`, `plusTypeOfT`, `PlusSeqStepT`, `plusJoinPathT` with its three joining lemmas, `natCard_plusTypeState`, `iter_plusSeqStepT`, `exists_recurring_plusTypeState`; derived bound `(2k+1)·2^k` with `k = C.card`. **Reuses by import** the `Formula`-side pigeonhole pair `exists_iterT_lt_card_aux`/`exists_iterT_lt_card` (stated at an abstract `{W} [Finite W] [Nonempty W]` and a bare relation). |
| `Fulfil.lean` | 260 | `plusUntl_propagates_to_endC`, `plusSnce_propagates_to_startC`, `plusLab_add_mul_nfC`, `plusLab_sub_mul_nbC`, `plusFulfillingSeqLab_of_good_cycles`. Nothing here mentions `⊡`. |
| `Extract.lean` | 843 | `plusMidBoundC`, `plusCompressionBound`, `plusTypeOfT_unrollOf`. **Reuses eight readout lemmas by import** (`getD_mapC`, `getD_range_mapC`, `periodic_rel_of_windowC`, `readout_backC`, `readout_midC`, `readout_fwdC`, `reduce_emodC`, `emod_succ_congrC`). Contains a **retained-and-unused alignment half** (`plusAlignOffset` … `exists_plusLabelledLasso_of_history_aligned`, ~620 lines). |
| `Saturate.lean` | 189 | The (C5) demand's semantics: `plusSameState`, `exists_history_state_eq_of_not_stab`, `plusTypeAtM_stab_demand`, `plusTypeAtM_mem_of_stab_of_state_eq`, `plusTypeAtM_stab_congr_state`, `plusTypeAtM_atom_congr_state`. |

Route narrative: **Types → Cycle → Fulfil → Extract → Saturate** (a strict chain; each imports exactly its predecessor, with `Cycle` and `Extract` additionally importing their `Formula`-side counterparts for the reused generic lemmas).

Scope boundaries that **must** be stated, because this is the directory's most important and least obvious fact:

1. **The L⁺ compression theorem does not exist and cannot exist for the landed certificate class.** `Extract.lean`'s docstring says so in terms: the alignment half "has **no consumer in this tree**, and is expected to have none… `PlusWitnessFamily/Limits/NoCertificate.lean`'s `not_exists_plusCertifies_pumpTarget` refutes that theorem outright, under no hypothesis." It is kept rather than deleted (it is correct and non-trivial; deleting it would erase the record of what the withdrawn route required), and **C17's dead-declaration census is expected to report this block**. A README that presents this directory as "the completeness half, giving decidability" — the exemplar's own framing — would be **false here**. This is the one place where mirroring the exemplar's prose would introduce an overclaim.
2. **No clause is added to either sequence predicate by the L⁺ re-index.** `PlusLocalCoherentSeqLab` has the same **five** clauses as `LocalCoherentSeqLab`; `PlusFulfillingSeqLab` the same **two**. `⊡` is not an eventuality, has no one-step unfolding, and (C5) is a *family* condition quantifying across the `share`-class at one time, so it cannot be stated at a bare label sequence at all.
3. **The bound's shape is unchanged** despite the larger closure: the L⁺ closure carries a `stab` tier, enlarging `C.card`, but `⊡` contributes no event and so no excursion, so no accounting term is added.
4. **The duplication is forced, and its retirement trigger is named**: `Formula` and `PlusFormula` are separate inductives sharing no supertype, so `Finset Formula` and `Finset PlusFormula` are unrelated and `TypeState C = {S : Finset Formula // S ∈ C.powerset}` cannot be re-indexed. The retirement trigger is the same one the `Formula`-side records — a shared periodic-label presentation, after which both cores become its instances.
5. **The `snce` propagation lemma is stated separately rather than derived by duality**, because the tree has no `PlusFormula` duality operation.

Imported by: `PlusWitnessFamily.lean` (Types, Fulfil, Extract, Saturate directly; Cycle transitively), `PlusSlicedCertificate/Position.lean`, `PlusSlicedCertificate/Sound.lean`, `PlusSlicedCertificate.lean`.

#### C. `PlusSlicedCertificate/` (25 modules, 15,123 lines, sorry-free)

By far the largest of the three. **The route narrative and 23 of 25 per-module descriptions already exist**, in the module docstring of the sibling re-export `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` (25,031 bytes). That docstring contains:

- `# ... — the time-sliced L⁺ certificate` with a one-sentence definition ("a **time-sliced** bi-serial labelled graph presenting a frame on the infinite carrier `ℤ × Fin n` with finite fibres").
- `## Why this subtree exists beside PlusWitnessFamily/` — the two structural failures it answers (all-threads fulfilment; the finite carrier) and the disappearance of absolute-time alignment.
- `## Soundness is not at issue in either direction`.
- `## Submodules` — a bullet per module.
- `## The closing record: what this subtree proves, and what it does not` — four subsections: what the class is; the forced infinite carrier; what is proved (soundness / relative completeness / the embedding, each with its headline theorem named); what is refuted vs. **open**; and the **nine conjuncts** of `Check.Certifies`.

**The dependency/route order is readable directly off the re-export's import list**, which is written in layering order:

```
Basic → Frame → Splice → Position → Live → Canon → Window → Fixture → Stable → Tail
→ FixtureStable → Timed → Fixpoint → Computed → Fold → Unroll → LiveFix → Bridge
→ HalfRun → Check → Sound → Complete → Embed → EmbedComplete → Examples
```

This groups naturally into six layers, which is the route narrative the README should state:

1. **The object and its frame** — `Basic` (`PlusGraphPath`, `PlusSlice`, `PlusSlicedCertificate`, three-segment readout, bi-seriality in both forms with `biSerial_iff_window`, `onePointCertificate`), `Frame` (`G.frame h` on `ℤ × Fin G.n` with its infinitude **proved**, `G.model h`, `mem_HF_iff_slicedPath`, `pathHistory`, shift normalization).
2. **Declarative liveness** — `Splice` (the Q5 factorization, `stab_factors`/`not_stab_factors`, the justification for `live = fwdLive ∩ bwdLive`), `Position` (the finite position space, `succP`/`predP` adjointness, `mem_succP_of_path`), `Live` (`LabRun`, `FwdLive`/`BwdLive`/`Live`, `untl_push`/`snce_push`, `live_of_path`/`exists_path_of_live`/`live_iff`), `Canon` (`canAt`/`canLab`/`canRun`, `canAt_iff_mem_lab`, `lab_eq_canLab`, `live_iff_canLab`).
3. **The window, and the fixture that fixes its width** — `Window` (`NB`/`NF`/`NM` from least common multiples, six compatibility facts, doubled endpoints `winLo`/`winHi`, `winTimes`, `exists_win_eq`/`forall_iff_win`), `Fixture` (`live_not_determined_by_slice`, `Fixture.window_verdict`).
4. **Tail stability** — `Stable` (`ΦBack`/`ΦFwd`, `stepBack`/`stepFwd`, `TailStable` with `decidableTailStable` as a **residue-indexed** demand, `L₀`/`R₀`, `mem_L₀_of_live_tail`), `Tail` (the reverse direction: `tailPos`/`headPos`, `live_of_mem_L₀_tail`/`live_of_mem_R₀_head`, `tailStable_iff_window`/`..._fwd`, `exists_win_live_eq`), `FixtureStable` (the verdict **against** the plan's `exists_tailStable_repr`: `Fixture.not_tailStable_cert`, `Fixture.ΦBack_L₀_inter_ne_cert`, `Fixture.not_tailStable` — *no* member of the re-presentation family is tail-stable).
5. **Computed liveness, and the bridge** — `Timed` (`TPos := G.Pos × ℤ`, `verts`, `nextTime`/`prevTime` with faithfulness), `Fixpoint` (`Nu.gfp`, `EGFix.gfp`, `EUFix.lfp`, `EUFix.lfp_mono_V`, and `AUFix` deliberately unused), `Computed` (`fwdWalkable`/`bwdWalkable`/`untlReach`/`snceReach`, each with both directions; **claims no equality with `Live`**), `Fold` (`FoldF`/`FoldB`, residue conditions, `foldF_succ`/`foldB_pred`), `Unroll` (`fwdWalk_foldF`/`bwdWalk_foldB`, `fwdWalkPos`/`bwdWalkPos`), `LiveFix` (`fwdLiveT`/`bwdLiveT`/`liveT` as a **nested** `Nu.gfp`, `exists_fwdLive_walk`/`exists_bwdLive_walk`), `Bridge` (`G.Live s p ↔ (p, s) ∈ G.liveT` at a window time, via `runOfWalks`; yields the `Decidable` instance), `HalfRun` (one-directional liveness from an explicit half-line — `mem_iterBack_of_run`/`mem_iterFwd_of_run`, `exists_bwdHalfRun_of_mem_bwdLiveT`/`exists_fwdHalfRun_of_mem_fwdLiveT`, `live_of_bwdHalf_chain_run`/`live_of_run_chain_fwdHalf`).
6. **The checker and its two theorems, then the embedding** — `Check` (`Certifies` as **nine** clauses, `decidableCertifies`, `forall_iff_win_succ`), `Sound` (`plusTruthAt_iff_canAt`, `plusRefutes_of_certifies` landing `PlusWitnessFamily.PlusRefutes Γ Del` **unchanged**), `Complete` (`SlabTrue`, `exists_plusSlicedCertificate_of_tailStable_countermodel`, `Probe.exists_certifying_triv`), `Embed` (`Periodic.segBack`/`segMid`/`segFwd`, `plusClosureOf_ofCtx`, `WitnessFamily.sliced`, `sliced_biSerial`, `Embedded.emptyFamily_tailStable`/`liveFamily_tailStable`), `EmbedComplete` (`sliced_history_const`, `sliced_target_lab_eq_canLab`, `sliced_slabTrue`, the `BotTargets` regression pair), `Examples` (`liveFamily_sliced_certifies`).

**The two gaps** — the re-export has no dedicated bullet for `HalfRun.lean` or `FixtureStable.lean` (the latter is mentioned only inside `Stable`'s bullet). Both modules' own docstrings supply full material and are summarized in layers 4-5 above. The implementation should read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/HalfRun.lean` lines 1-48 and `.../FixtureStable.lean` lines 1-55 directly.

Scope boundaries that must be carried, verbatim in substance:

- **The sliced finite model property is OPEN, not refuted.** "No module here states it, implies it, or treats it as settled either way."
- **The finite-carrier FMP for this certificate shape is refuted**, unconditionally. Restricting to the CTL-like fragment does *not* rescue it — the `⊡`-free non-validity that defeats it already lies inside that fragment.
- **The doubly-exponential expected slice width is a research finding, not a theorem**: "no slice-width bound, no tail-period bound and no complexity claim is proved anywhere in this subtree, and none should be read into it."
- **`exists_tailStable_repr` is false**, and `FixtureStable.lean` proves it false; it is therefore **not stated in any weakened form**.
- **`FixtureStable.lean` carries a STANDING RULE** binding on future work in that subtree: any probe of a `TailStable`-like demand must carry **both** an `untl` and a `snce`, with the two smallest witnesses kept as a permanent regression pair in `EmbedComplete.lean`'s `BotTargets` namespace (`⊥ U ⊥`, `⊥ S ⊥`). A durable rule of this kind belongs in the directory README, not only in one module's header.
- **Soundness is untouched in both directions**; the landed sharing-family interface is not edited.

Imported by: `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` (all 25), which `FormalSystem/Metalogic/Decidability.lean` imports. The generated library root `FormalSystem.lean` imports every module under `FormalSystem/` directly, so `lake build` compiles all 25.

### External Resources

- `docs/development/DIRECTORY_README_STANDARD.md` — Templates D-G, the "when README required" decision tree, the four anti-patterns (over-documentation, stale documentation, missing README, README for simple directories), and §7's doc-gen4 division of labour: READMEs provide **navigation, organization, usage, learning paths, context and motivation**; doc-gen4 provides API detail from docstrings. The directory is on the allowlist `scripts/markdown-link-allowlist.txt` because its template snippets are link-syntax illustrations.
- `docs/reference/readme-standard.md` — the `FormalSystem/`-specific required-section list and the `--emit-inventory` opt-in mechanism.
- No external/web resource is needed. No Mathlib search was required (see Decisions).
- Literature: none referenced by the task. The exemplar's `[GKWZ] 2003` terminology map is a *pattern* worth noting but is not reproducible for these three directories, whose results (the two incompleteness refutations, the sliced certificate) have no stated book counterpart; `Limits/` and `PlusSlicedCertificate/` both record their provenance as in-tree compiled probes instead.

### Recommendations

1. **Write exactly three files**, nothing else, to flip the gate:
   - `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md`
   - `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/README.md`
   - `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/README.md`

2. **Section skeleton** for each (matching the exemplar, with the stamp added):

   ```
   # <directory path or name> — <one-line characterization>
   <purpose paragraph: what this directory is the half/layer OF, what it composes with,
    what the headline result is, and what it consumes as given>
   ## The route            (numbered pipeline in dependency order)
   ## Modules              (| Module | Contents | table — EVERY .lean basename)
   ## <design-decision sections, one per non-obvious choice>
   ## What is out of scope (or: What is refuted, and what is open)
   ## Dependencies         (Imports from / Imported by)
   ## Related Documentation (relative links to sibling + parent READMEs)
   *Last verified: <commit date>*
   ```

3. **Sizing** (the exemplar is ~110 lines; the parent is ~210):
   - `Limits/README.md` — 70-100 lines. Three modules, two parallel refutations, strong "what this does not say" content already written.
   - `Compression/README.md` — 100-140 lines. Mirror the exemplar's structure, but **invert its conclusion**: this is the L⁺ twin of a completeness half whose theorem is *refuted*, with a retained-and-unused alignment block.
   - `PlusSlicedCertificate/README.md` — 160-220 lines. Twenty-five modules in six layers; the closing proved/refuted/open record is essential. Transcribe and condense the re-export docstring; do not paraphrase its claims loosely.

4. **Link policy** — prefer *naming* modules in backticks (`` `Stable.lean` ``) over linking them. Reserve real links for the handful of cross-directory navigation targets, and verify each:
   - From `Compression/` and `Limits/`: `[PlusWitnessFamily README](../README.md)`, `[WitnessFamily Compression README](../../WitnessFamily/Compression/README.md)`, `[Decidability README](../../README.md)`.
   - From `PlusSlicedCertificate/`: `[Decidability README](../README.md)`, `[PlusWitnessFamily README](../PlusWitnessFamily/README.md)`.
   Confirm with `test -e` from the README's own directory before committing.

5. **Verification sequence** (run from the repository root, in this order):
   ```bash
   bash scripts/readme-lint.sh FormalSystem BimodalTools; echo "exit=$?"   # must print exit=0
   bash scripts/check-module-invariants.sh --emit-inventory --check        # must stay PASS INV
   ```
   Then confirm the three directories report no `NOT LISTED` and no `MISSING DATE` lines:
   ```bash
   bash scripts/readme-lint.sh FormalSystem BimodalTools \
     | grep -E 'PlusSlicedCertificate|PlusWitnessFamily/(Compression|Limits)'
   ```
   `lake build` is **not** required — no Lean source changes.

6. **Optional, non-gating, cheap** — add four rows to `FormalSystem/Metalogic/Decidability/README.md`'s Modules table for `PlusWitnessFamily.lean`, `PlusWitnessFamily/`, `PlusSlicedCertificate.lean` and `PlusSlicedCertificate/`, mirroring the existing `WitnessFamily/` and `BiLasso/` rows (which carry file counts and sorry status). That table currently mentions neither subtree, so Check 2 reports them as `NOT LISTED`. Also worth one line in `PlusWitnessFamily/README.md`, which names `Limits` but never `Compression`. Recommend scoping this as a **separate, clearly-optional final phase** so the gate-flipping work commits independently of it.

7. **No `sorry` deferral, no axiom introduction, no placeholder content.** Every table row must describe the module as it actually is; a row whose content is unknown must be researched from that module's docstring before the file is written, not stubbed. If any module's purpose genuinely cannot be determined, mark the task `[BLOCKED]` rather than shipping a placeholder — but note that no such case was found: all 33 modules carry substantive docstrings.

## Decisions

1. **lean-lsp MCP tools were deliberately not used.** The dispatch's `<lean-readiness-context>` reports the server registered and reachable, but this task discovers no theorems, verifies no lemma names against Mathlib and checks no proof states. The evidence tier here is **direct source reading plus two mechanical gates** (`readme-lint.sh`, `check-module-invariants.sh`), which is strictly stronger for this question than an LSP symbol lookup would be. No search tool (`leansearch`/`loogle`/`leanfinder`/`state_search`/`hammer_premise`) was called, so no rate limit was consumed and no fallback was needed.
2. **House style resolved in favour of the exemplar's structure plus the parent's date stamp**, rather than either written standard literally. Reason: the task names the exemplar as the depth bar; `docs/reference/readme-standard.md`'s `Lines` column is unmaintained drift risk for an unmarked table; and the stamp costs one line and removes a warning.
3. **No `<!-- BEGIN GENERATED: inventory -->` marker.** `INV` currently passes; adding a marker opts these files into exhaustiveness checking for no gate benefit, and the route-ordered table these directories need is explicitly the kind the generator does not produce (it sorts by name or by line count).
4. **Route order for `PlusSlicedCertificate/` taken from the re-export's import list**, which is written in layering order, rather than re-deriving a graph. Cross-checked against each layer's module docstrings; the six-layer grouping above is consistent with them.
5. **Checks 2 and 4 treated as targets even though ungated.** Satisfying Check 2 is automatic (every basename appears in the Modules table); satisfying Check 4 costs one line. Leaving either unsatisfied would add new warning lines in the very directories this task exists to document.
6. **`Decidability/README.md` updates recommended but scoped as optional.** They do not affect the acceptance command and would widen the diff into a directory the task does not name.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| A bracket-paren pair in notation or a fenced Lean block is read as a broken link, turning the gate red | **High** — this is the only realistic way to fail the acceptance criterion | Never follow `]` with `(` except in a verified relative link or an `http(s)` URL. Prefer backticked module names over links. Run `readme-lint.sh` before committing and read the `--- Check 3 ---` section, not just the summary. |
| Mirroring the exemplar's framing into `Compression/README.md` produces an overclaim (the exemplar's directory *yields decidability*; this one's compression theorem is **refuted**) | **High** — a false documented claim is worse than a missing README | State the withdrawal explicitly, citing `Limits/NoCertificate.lean`'s `not_exists_plusCertifies_pumpTarget`, and explain why the alignment half is retained and unused (and why C17 is expected to report it). |
| Condensing `PlusSlicedCertificate.lean`'s closing record loses the open/refuted distinction | **High** | Keep "what is proved / what is refuted / what is **open**" as a named section with the three bullets intact. The sliced FMP is **open**; the finite-carrier FMP is **refuted**; the slice-width estimate is a **research finding, not a theorem**. |
| A task number leaks into a README via copied plan prose (C9 gate) | Medium | Cite durable anchors only — module names, theorem names, sibling READMEs. Grep the three new files for `task [0-9]` and for phase/sub-phase numbering before committing. Note that `FixtureStable.lean`'s own docstring says "sub-phase 16.2c", which must **not** be transcribed. |
| `*Last verified:*` stamp predates the commit, producing a fresh `STALE DATE` warning | Low (ungated) | Stamp with the actual commit date; verify with `git log -1 --format=%cs -- <dir>` after committing. |
| A module is renamed or added between research and implementation, leaving a `NOT LISTED` row | Low | Re-list each directory (`ls *.lean`) immediately before writing its table. Measured now: 25 / 5 / 3 files. |
| The 25-module table drifts within one review cycle | Low | Describe modules by *role in the route* rather than by declaration enumeration where the list is long; the route grouping survives a single-file addition, a flat declaration dump does not. |
| Stating a sorry/axiom count that C14 contradicts | Low | Measured: all three directories are sorry-free and axiom-free (the one `grep` hit under `PlusSlicedCertificate/` is prose in `EmbedComplete.lean`'s docstring). "Sorry-free" is safe to state. |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task writes markdown; no proof goal exists to attempt, so no tactic candidate was tested via `lean_multi_attempt` and no premise lookup via `lean_hammer_premise` was warranted.

## Context Extension Recommendations

- **Topic**: The `readme-lint.sh` gated-vs-reported contract and its code-fence-blind link scan.
  - **Gap**: No context file records that Check 3 resolves `[text](path)` by bare grep with no fence awareness, nor that only Checks 1 and 3 are gated. An agent writing any `FormalSystem/**/README.md` can turn CI red with a notation-shaped bracket-paren pair, and the only places this is written down are the script's own header and C32's rationale inside a 6,000-line invariants script.
  - **Recommendation**: add `.claude/context/project/lean4/operations/readme-gates.md` covering: the four checks and which two are gated; the link-scan hazard with the "never let `]` be followed by `(`" authoring rule; the C9 no-task-numbers constraint on `FormalSystem/**`; the C14 count constraint; the `INV` opt-in semantics of `<!-- BEGIN GENERATED: inventory -->` / `<!-- INVENTORY: hand-maintained -->`; and the same-commit date-stamp rule.

- **Topic**: Which README standard governs a `FormalSystem/` subdirectory.
  - **Gap**: `docs/development/DIRECTORY_README_STANDARD.md` and `docs/reference/readme-standard.md` disagree on the module-table shape and on whether a date stamp is required, and the in-tree exemplars follow neither literally. Nothing records the resolution, so each task re-derives it.
  - **Recommendation**: add a short "which standard wins" subsection to one of the two documents (or a pointer in the new context file above) recording the de facto house style: exemplar structure (purpose / route / `| Module | Contents |` / scope boundaries / dependencies / related docs) plus a `*Last verified: YYYY-MM-DD*` footer, with the `Lines` column reserved for tables that opt into generation.

## Appendix

### Commands run (all read-only)

```bash
bash scripts/readme-lint.sh FormalSystem BimodalTools            # exit 1; 3 missing, 0 broken
bash scripts/check-module-invariants.sh --emit-inventory --check # exit 0; PASS INV
git log -1 --format=%cs -- <each of the three directories>
git show --stat f1d597353                                        # prior commit = task creation only
wc -l <each directory>/*.lean
grep -rn 'sorry' FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/*.lean
grep -rl 'PlusWitnessFamily.Compression' FormalSystem --include=*.lean
grep -rl 'PlusWitnessFamily.Limits'      FormalSystem --include=*.lean
grep -rl 'PlusSlicedCertificate'         FormalSystem --include=*.lean
grep -rn 'BEGIN GENERATED: inventory'    FormalSystem --include=README.md
grep -rn 'INVENTORY: hand-maintained'    FormalSystem --include=README.md
grep -rh 'Last verified' FormalSystem --include=README.md | sort | uniq -c | sort -rn
```

### Files read

- `scripts/readme-lint.sh` (295 lines, in full)
- `scripts/check-module-invariants.sh` (headers for C9, C12/C13, C14, C32, `INV`, `--emit-inventory`)
- `.github/workflows/ci.yml` (the `readme-lint` step and the aggregation block)
- `docs/development/DIRECTORY_README_STANDARD.md` (in full)
- `docs/reference/readme-standard.md` (required sections and template)
- `scripts/markdown-link-allowlist.txt`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md` (exemplar, in full)
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` (parent, in full)
- `FormalSystem/Metalogic/Decidability/README.md` (structure)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` (module docstring, the primary content source)
- Module docstrings of all 5 `Compression/` modules, all 3 `Limits/` modules, and `PlusSlicedCertificate/{HalfRun,FixtureStable}.lean`

### Measured inventory

| Directory | `.lean` files | lines | `sorry` | `axiom` |
|---|---|---|---|---|
| `PlusSlicedCertificate/` | 25 | 15,123 | 0 (one prose mention) | 0 |
| `PlusWitnessFamily/Compression/` | 5 | 2,047 | 0 | 0 |
| `PlusWitnessFamily/Limits/` | 3 | 1,226 | 0 | 0 |

Per-file line counts, for a table that opts into a `Lines` column:

- `PlusSlicedCertificate/`: Basic 657, Bridge 784, Canon 545, Check 742, Complete 714, Computed 276, Embed 851, EmbedComplete 1542, Examples 81, Fixpoint 1074, Fixture 1309, FixtureStable 393, Fold 280, Frame 217, HalfRun 364, Live 529, LiveFix 471, Position 351, Sound 357, Splice 337, Stable 1529, Tail 696, Timed 475, Unroll 257, Window 292
- `Compression/`: Cycle 411, Extract 843, Fulfil 260, Saturate 189, Types 344
- `Limits/`: HopFree 326, NoCertificate 444, Targets 456
