# Research Report: Task #908

**Task**: 908 - Audit the remaining "Constraints consumed: Compositionality, Seriality, Limit, Saturation" docstring lines against what each declaration's proof actually projects
**Started**: 2026-11-11T06:51:00Z
**Completed**: 2026-11-11T07:10:00Z
**Effort**: medium (classification complete; correction work sized below)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `FormalSystem/**/*.lean` (837 live files), `scripts/check-module-invariants.sh` check C34
- Specification: `docs/development/REFERENCE_NORMAL_FORM.md` §"What the line claims", `docs/development/MODULE_INVARIANTS.md` C34 row
- Lean MCP: `lean_local_search` (field-constant name verification)
- Compiled probes: 5 metaprogram runs via `lake env lean` against the built olean set
- Evidence anchor: `specs/evidence/history-morphism-saturation-audit/`
**Artifacts**:
- `specs/908_constraints_consumed_marker_accuracy_audit/reports/01_constraints-consumed-marker-audit.md` (this report)
- `specs/evidence/constraints-consumed-marker-audit/marker-consumption-probe.lean` (the classifying probe)
- `specs/evidence/constraints-consumed-marker-audit/classification.tsv` (all 68 rows, machine-readable)
- `specs/evidence/constraints-consumed-marker-audit/c34a-gate-simulation.py` (gate-collision simulation)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The audit is complete, not merely scoped.** A single compiled metaprogram classified all 68
  marker sites in one run. **28 over-report; 40 are accurate.** No site is left undetermined.
  The planned per-site transplant-probe sweep is not needed for classification.
- **The population is 68 marker lines in 17 files, not 65 in 16.** The 69th occurrence of the
  string is docstring prose citing the form (`Presheaf/Worlds.lean:59`), not a marker.
- **The correction is gated, and that is the load-bearing finding.** `check-module-invariants.sh`
  C34a is *enforced* and refuses any marker that omits a constraint its own binder supplies.
  22 of the 28 over-reporters carry a bracketed `[F.IsRegular]` binder, so for them a
  docstring-only edit **fails the gate**. Each needs a binder-free twin landed in the same phase,
  or the binder removed. Simulated on 4 representative sites: all 4 FAIL C34a.
- **Three over-reporting sites carry an in-source rationale defending the full-four listing**
  (`ConeUnravelling.lean:876`, `Nomic/ZTime.lean:132`, `Presheaf/Path.lean:1168`). Those
  rationales contradict `REFERENCE_NORMAL_FORM.md`'s authoritative definition, which the task
  premise follows. The docstrings, not the markers' correction, are what must yield.
- **Leverage: the 28 do not need 28 twins.** They funnel through a handful of enabler lemmas,
  and one of the needed twins (`FrameOver.nullity_identity_of_serial_limit`) already exists.
- **Recommended approach**: correct in four file-scoped phases ordered by enabler dependency, each
  naming `scripts/check-module-invariants.sh` in its own verification tier. A sorry-free path
  exists throughout; no `sorry`, axiom, or placeholder is required anywhere in this work.

## Context & Scope

Researched: for each docstring line reading `Constraints consumed: Compositionality, Seriality,
Limit, Saturation`, which of the four `FrameOver.IsRegular` fields the declaration's elaborated
proof term actually reaches, and what it costs to correct the line where it over-reports.

Constraints respected: the marker vocabulary is closed (C34); a side-attributing form
(`source: ...; base: none`) is inadmissible; any phase touching a marker must name
`scripts/check-module-invariants.sh` in its verification tier, since a full `lake build` covers
none of C34/C34a/C34b; `typst/generated/status.typ` is a mandatory `file_scope` member of any
`.lean`-touching phase (`scripts/typst-sync-check.sh` pre-commit gate).

## Findings

### The authoritative definition of the marker, and the probe that mechanizes it

`docs/development/REFERENCE_NORMAL_FORM.md` fixes the semantics, in bold and without hedging:

> **The listed constraints are the whole of what the elaborated proof term reaches, and every
> unlisted constraint is thereby CLAIMED unconsumed.**

and distinguishes consumption from elimination:

> **consumption** is the elaborated proof term reaching the field *at all*.

Two consequences settle the method:

1. **Consumption is transitive.** The document's own worked example,
   `PartialHistory.isTotal_of_isMax`, consumes *Saturation* and marks it, yet its own proof term
   applies no field constant directly — the reach is through a callee. Measured here: that
   declaration's direct field hits are empty and its transitive hits are all four. So the
   predicate to compute is transitive reach.
2. **Provenance of the instance is irrelevant.** The definition asks whether the *term reaches
   the field*, not whether the field came from the ambient binder. A proof that manufactures a
   regular frame internally and then projects its `saturation` field consumes *Saturation* under
   this definition. This removes what would otherwise be the probe's false-positive hazard.

The probe (`specs/evidence/constraints-consumed-marker-audit/marker-consumption-probe.lean`)
therefore computes, for each site, the transitive constant closure of the elaborated declaration
and intersects it with the eight constants through which the four fields can be read — the four
class-field projections `FrameOver.IsRegular.{comp,serial,limit,saturation}` and the four
re-export theorems `FrameOver.{comp,serial,limit,saturation}`. Both groups were confirmed present
in the environment by `lean_local_search` and by an in-probe existence check.

### Lemma-level mapping: specification to mechanization

| Source | Location | Lean identifier | Type signature / mechanized form | Status |
|---|---|---|---|---|
| REFERENCE_NORMAL_FORM.md | §"What the line claims" | — (prose spec) | "listed = whole of what the elaborated proof term reaches" | Mechanized as transitive closure ∩ field-constant set |
| REFERENCE_NORMAL_FORM.md | §"Consumption is not elimination" | — (prose spec) | "reaching the field *at all*" | Confirms transitive, provenance-blind reading |
| TaskFrame.lean:1189 | class decl | `FormalSystem.Semantics.FrameOver.IsRegular` | `class IsRegular (F : FrameOver D) : Prop` with fields `comp serial limit saturation` | Verified (read in source) |
| TaskFrame.lean:1232 | re-export | `FrameOver.comp` | `(F : FrameOver D) → [h : F.IsRegular] → TaskFrame.Compositional F.TaskRel` | Verified (source + probe existence check) |
| TaskFrame.lean:1237 | re-export | `FrameOver.serial` | `(F : FrameOver D) → [h : F.IsRegular] → TaskFrame.Serial F.TaskRel` | Verified |
| TaskFrame.lean:1245 | re-export | `FrameOver.limit` | `(F : FrameOver D) → [h : F.IsRegular] → TaskFrame.Limit F.TaskRel` | Verified |
| TaskFrame.lean:1259 | re-export | `FrameOver.saturation` | `(F : FrameOver D) → [h : F.IsRegular] → TaskFrame.Saturation F.TaskRel` | Verified (`lean_local_search` hit + probe) |
| TaskFrame.lean:2674 | abbrev | `TaskFrame.IsRegular` | `abbrev IsRegular (G : TaskFrame) : Prop := G.toFibre.IsRegular` | Verified — a `[G.IsRegular]` binder on a `TaskFrame` is literally the `FrameOver` class, so the same eight constants cover it |
| Nomic/Frame.lean:107 | second class | `NomicFrame.IsRegular` | `class IsRegular (F : NomicFrame D) : Prop` with single field `regular : ∀ w, (F.at w).IsRegular` | Verified — consumption flows through `instAtIsRegular` to the same eight constants; see gap note below |
| check-module-invariants.sh:6424 | C34 table | `BUNDLERS` | `{"IsRegular": ("Compositionality","Seriality","Limit","Saturation")}` | Verified (read in source; matched by short name, so it covers both classes) |

### Probe validation (six independent controls, all exact)

Every declaration in the tree whose honest marker was established by hand in the completed
`HistoryMorphism`/`UniversalCover` work, plus the two self-documenting `TaskFrame.lean` anchors,
reproduces exactly under the probe:

| Control | Recorded marker (hand-established) | Probe transitive hits | Match |
|---|---|---|---|
| `FrameOver.saturation` | `Saturation` | `Sat` | exact |
| `FrameOver.limit` | (field re-export at *Limit*) | `Lim` | exact |
| `FrameOver.nullity` | derived from *Seriality* + *Limit* (TaskFrame.lean:1275) | `Ser, Lim` | exact |
| `FrameOver.reflection` | *Limit*, "no other constraint" (TaskFrame.lean:1373) | `Lim` | exact |
| `UniversalCover.coverFrame` | `Seriality` | `Ser` | exact |
| `UniversalCover.endpt_twoWayBounded` | `Compositionality, Seriality, Limit` | `Comp, Ser, Lim` | exact |
| `PartialHistory.step` (positive control) | full four; sole *Saturation* elimination site | `Comp, Ser, Lim, Sat` | exact |

The two binder-free explicit-hypothesis twins `coverFrameOfSerial` and
`endpt_twoWayBounded_of_constraints` correctly return *no* hits: they take their constraints as
explicit arguments and reach no bundler field, which is the expected reading and not a miss.

Three further robustness checks, all clean:

- **Module provenance**: 0 of 68 sites resolved to a declaration outside the file its marker was
  read from, so the namespace resolution joining source lines to environment constants is sound.
- **Value-only vs type+value**: identical verdicts on all 68 rows, so including the declaration's
  type in the walk changes nothing.
- **Anti-silence**: all 68 targets and all 8 field constants resolved in the environment
  (`SUMMARY targets=68 missing=0`).

### Population: 68 marker lines in 17 files

`grep` finds 69 occurrences of the full-four string across 17 files. One
(`FormalSystem/Semantics/Presheaf/Worlds.lean:59`) is docstring prose quoting the form inside
backticks, not a marker. The remaining 68 are markers, and the live C34 census agrees exactly:
62 of them carry a bracketed binder and "omit nothing", which is C34a's discharge group 1.

The task description's figure of 65 across 16 files is an undercount by 3 lines and 1 file.

### The 28 over-reporting sites

Each row's `corrected marker` is the probe's transitive hit set, spelled in the closed vocabulary.
"Binder" is whether the declaration carries a bracketed `[F.IsRegular]`, which decides whether
the correction collides with C34a.

| Declaration | Site | Binder | Probe hits | Corrected marker |
|---|---|---|---|---|
| `Semantics.base_taskRel_eq_ofStepRel` | FormalSystem/Semantics/ConeUnravelling.lean:885 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.NomicHierarchy.F2.lawful` | FormalSystem/Semantics/Nomic/Witnesses.lean:512 | no | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.nomic_hierarchy` | FormalSystem/Semantics/Nomic/Witnesses.lean:626 | no | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.NomicFrame.ofStepFamily_isRegular` | FormalSystem/Semantics/Nomic/ZTime.lean:118 | no | (none) | None |
| `Semantics.NomicFrame.mem_lawHist_iff_isStepPath` | FormalSystem/Semantics/Nomic/ZTime.lean:139 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.NomicFrame.mem_lawHist_ofStepFamily_iff` | FormalSystem/Semantics/Nomic/ZTime.lean:152 | no | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.NomicFrame.lawHist_mono_of_le` | FormalSystem/Semantics/Nomic/ZTime.lean:167 | no | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathHom.id` | FormalSystem/Semantics/Presheaf/Path.lean:422 | yes | Ser,Lim | Seriality, Limit |
| `Semantics.Presheaf.PathHom.id_len` | FormalSystem/Semantics/Presheaf/Path.lean:450 | yes | Ser,Lim | Seriality, Limit |
| `Semantics.Presheaf.PathHom.id_comp` | FormalSystem/Semantics/Presheaf/Path.lean:459 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathHom.comp_id` | FormalSystem/Semantics/Presheaf/Path.lean:491 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathCat.instCategory` | FormalSystem/Semantics/Presheaf/Path.lean:706 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathCat.len` | FormalSystem/Semantics/Presheaf/Path.lean:720 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathCat.len_map` | FormalSystem/Semantics/Presheaf/Path.lean:729 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathCat.len_isDiscreteConduche` | FormalSystem/Semantics/Presheaf/Path.lean:908 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.Beh.ofAdjacentWindow` | FormalSystem/Semantics/Presheaf/Path.lean:1081 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.Beh.ofAdjacentWindow_states` | FormalSystem/Semantics/Presheaf/Path.lean:1107 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.beh_int_iff_adjacent_window` | FormalSystem/Semantics/Presheaf/Path.lean:1119 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathHom.toPathAux` | FormalSystem/Semantics/Presheaf/Path.lean:1163 | yes | (none) | None |
| `Semantics.Presheaf.PathHom.toPath` | FormalSystem/Semantics/Presheaf/Path.lean:1196 | yes | (none) | None |
| `Semantics.Presheaf.PathHom.toPath_length` | FormalSystem/Semantics/Presheaf/Path.lean:1205 | yes | (none) | None |
| `Semantics.Presheaf.PathHom.toPath_id` | FormalSystem/Semantics/Presheaf/Path.lean:1230 | yes | Ser,Lim | Seriality, Limit |
| `Semantics.Presheaf.PathHom.toPath_comp` | FormalSystem/Semantics/Presheaf/Path.lean:1242 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathHom.ofStep` | FormalSystem/Semantics/Presheaf/Path.lean:1435 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathHom.ofPath` | FormalSystem/Semantics/Presheaf/Path.lean:1453 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathHom.ofPath_toPath` | FormalSystem/Semantics/Presheaf/Path.lean:1467 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathHom.toPath_ofPath` | FormalSystem/Semantics/Presheaf/Path.lean:1528 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |
| `Semantics.Presheaf.PathHom.pathEquiv` | FormalSystem/Semantics/Presheaf/Path.lean:1545 | yes | Comp,Ser,Lim | Compositionality, Seriality, Limit |

By file: `Presheaf/Path.lean` 20, `Nomic/ZTime.lean` 4, `Nomic/Witnesses.lean` 2,
`ConeUnravelling.lean` 1, `Nomic/Uniformity.lean` 0.

Four of the 28 reach **no** constraint at all (`PathHom.toPathAux`, `PathHom.toPath`,
`PathHom.toPath_length`, `NomicFrame.ofStepFamily_isRegular`): their honest marker is `None`.

### The 40 accurate sites (marker unchanged)

| Declaration | Site | Binder |
|---|---|---|
| `NomicLanguage.exists_refutation_of_not_uniform` | FormalSystem/NomicLanguage/NomicFour.lean:93 | yes |
| `Semantics.four_validOn_iff_uniform` | FormalSystem/NomicLanguage/NomicFour.lean:196 | yes |
| `Semantics.nomic_iff_box_validOn_iff_uniform` | FormalSystem/NomicLanguage/NomicFour.lean:218 | yes |
| `Semantics.not_four_nomicValid` | FormalSystem/NomicLanguage/NomicFour.lean:244 | no |
| `NomicLanguage.tenseFree_satSet_iff` | FormalSystem/NomicLanguage/NomicTenseFree.lean:159 | yes |
| `NomicLanguage.nomic_iff_box_tenseFree` | FormalSystem/NomicLanguage/NomicTenseFree.lean:210 | yes |
| `NomicLanguage.nomic_k_tenseFree` | FormalSystem/NomicLanguage/NomicTenseFree.lean:230 | yes |
| `NomicLanguage.nomic_t_tenseFree` | FormalSystem/NomicLanguage/NomicTenseFree.lean:250 | yes |
| `NomicLanguage.nomic_four_tenseFree` | FormalSystem/NomicLanguage/NomicTenseFree.lean:266 | yes |
| `NomicLanguage.nomic_five_tenseFree` | FormalSystem/NomicLanguage/NomicTenseFree.lean:282 | yes |
| `NomicLanguage.nomic_b_tenseFree` | FormalSystem/NomicLanguage/NomicTenseFree.lean:299 | yes |
| `Semantics.nomic_serial` | FormalSystem/NomicLanguage/NomicValidity.lean:96 | yes |
| `Semantics.coneFrame` | FormalSystem/Semantics/ConeUnravelling.lean:917 | yes |
| `Semantics.coneF_twoWayBounded` | FormalSystem/Semantics/ConeUnravelling.lean:967 | yes |
| `Semantics.exists_coneUnravelling` | FormalSystem/Semantics/ConeUnravelling.lean:1046 | yes |
| `Semantics.FrameOver.static_of_countable` | FormalSystem/Semantics/Correspondence/RigidityReal.lean:195 | yes |
| `Semantics.PartialHistory.completion_of_isRegular` | FormalSystem/Semantics/Extension/Completion.lean:325 | yes |
| `Semantics.PartialHistory.isTotal_of_isMax` | FormalSystem/Semantics/Extension/Extension.lean:204 | yes |
| `Semantics.PartialHistory.extension` | FormalSystem/Semantics/Extension/Extension.lean:239 | yes |
| `Semantics.PartialHistory.isRestriction_of_isRegular` | FormalSystem/Semantics/Extension/Extension.lean:266 | yes |
| `Semantics.PartialHistory.step` | FormalSystem/Semantics/Extension/Step.lean:198 | yes |
| `Semantics.NomicFrame.occurrence` | FormalSystem/Semantics/Nomic/Frame.lean:196 | yes |
| `Semantics.PartialHistory.exists_worldHistory_two_point` | FormalSystem/Semantics/Nomic/Recovery.lean:81 | yes |
| `Semantics.NomicFrame.taskRel_imp_of_lawHist_eq` | FormalSystem/Semantics/Nomic/Recovery.lean:126 | yes |
| `Semantics.NomicFrame.lawHist_eq_iff_taskRel_eq` | FormalSystem/Semantics/Nomic/Recovery.lean:160 | yes |
| `Semantics.NomicFrame.static_iff_taskRel_eq` | FormalSystem/Semantics/Nomic/Recovery.lean:192 | yes |
| `Semantics.NomicFrame.exists_mem_HF_eq` | FormalSystem/Semantics/Nomic/Uniformity.lean:108 | yes |
| `Semantics.NomicFrame.lawHist_nonempty` | FormalSystem/Semantics/Nomic/Uniformity.lean:125 | yes |
| `Semantics.NomicFrame.uniform_of_transAt` | FormalSystem/Semantics/Nomic/Uniformity.lean:196 | yes |
| `Semantics.NomicFrame.uniform_of_symmAt` | FormalSystem/Semantics/Nomic/Uniformity.lean:223 | yes |
| `Semantics.NomicFrame.uniform_of_euclAt` | FormalSystem/Semantics/Nomic/Uniformity.lean:245 | yes |
| `Semantics.NomicFrame.uniform_iff_taskRel_indep` | FormalSystem/Semantics/Nomic/Uniformity.lean:315 | yes |
| `Semantics.NomicFrame.nomic_uniform` | FormalSystem/Semantics/Nomic/Uniformity.lean:366 | yes |
| `Semantics.NomicFrame.transAtState_iff` | FormalSystem/Semantics/Nomic/Uniformity.lean:404 | yes |
| `Semantics.NomicFrame.uniform_iff_forall_transAtState` | FormalSystem/Semantics/Nomic/Uniformity.lean:423 | yes |
| `Semantics.Presheaf.totality_clause` | FormalSystem/Semantics/Presheaf/Directed.lean:295 | yes |
| `Semantics.Presheaf.totality_clause_site` | FormalSystem/Semantics/Presheaf/Directed.lean:307 | yes |
| `Semantics.Presheaf.directed_gluing_clause` | FormalSystem/Semantics/Presheaf/Directed.lean:508 | yes |
| `Semantics.Presheaf.lim_nonempty` | FormalSystem/Semantics/Presheaf/Worlds.lean:387 | yes |
| `Semantics.TaskFrame.not_validOn_bot` | FormalSystem/Semantics/Validity.lean:289 | yes |

This is the answer to the task's "many occurrences will be ACCURATE" expectation: 40 of 68,
including the whole of `Nomic/Uniformity.lean` (9), `Nomic/Recovery.lean` (4),
`NomicLanguage/` (12), `Extension/` (5) and `Presheaf/Directed.lean` (3). These consume
*Saturation* genuinely, overwhelmingly by routing through `PartialHistory.step` or
`PartialHistory.extension`.

### The C34a gate collision

This is the finding that determines how the correction must be phased, and it points the opposite
way from what a docstring-edit task implies.

C34a is **enforced** (`ENFORCE_C34A` defaults to 1) and exit-code-affecting. Its predicate: a
marker that omits a constraint its own binder supplies is a violation unless discharged by
(a) **delegation** — the declaration's code names another declaration carrying the *identical*
marker list and mentioning no bundling class anywhere in its span, or (b) **field re-export** —
the whole proof term is one field projection and the marker names exactly that field.

An all-four marker over a binder omits nothing and so is exempt by construction. **Correcting it
removes that exemption.** Simulated against the live census, with each site's marker replaced by
the probe's honest list:

| Site | Binder | Corrected marker | Omitted | Discharge found | C34a verdict |
|---|---|---|---|---|---|
| `PathHom.toPath_comp` | `IsRegular` | Compositionality, Seriality, Limit | Saturation | none | **FAIL** |
| `PathHom.id` | `IsRegular` | Seriality, Limit | Compositionality, Saturation | none | **FAIL** |
| `NomicFrame.mem_lawHist_iff_isStepPath` | `IsRegular` | Compositionality, Seriality, Limit | Saturation | none | **FAIL** |
| `base_taskRel_eq_ofStepRel` | `IsRegular` | Compositionality, Seriality, Limit | Saturation | none | **FAIL** |

So the work is not 28 docstring edits. It is 22 restructurings plus 6 free edits:

- **6 sites carry no binder** (`F2.lawful`, `nomic_hierarchy`, `mem_lawHist_ofStepFamily_iff`,
  `lawHist_mono_of_le`, `ofStepFamily_isRegular`, and the binder-free row in `NomicFour.lean`).
  With no binder, `omitted` is empty whatever the marker says, so these are C34a-exempt and the
  correction is a one-line edit. Four of them currently discharge by delegation; correcting a
  delegating pair **together** keeps the discharge intact, since `delegates` matches on list
  identity.
- **22 sites carry the binder** and need one of three routes.

### The three correction routes, and which applies

1. **Delete the binder** — for a site that reaches no constraint, and whose `[F.IsRegular]` is not
   needed for instance synthesis elsewhere in its signature. Marker becomes `None`, `binders`
   becomes empty, C34a exempt. Candidates: the three `PathHom.toPathAux`/`toPath`/`toPath_length`
   rows. **Must be probed per site**: the probe proves no constraint is *consumed*, which is not
   the same as the binder being removable — it may still be needed to elaborate a sibling
   instance argument. This is the one place the transplant probe is still required, and it is 3
   sites, not 68.
2. **Binder-free twin plus one-line corollary** — the fix pattern of record, named in
   `REFERENCE_NORMAL_FORM.md` as discharge route 2 and already instantiated four times in the
   tree (`FrameOver.nullity_identity_of_serial_limit`,
   `FrameOver.static_of_uniformDwell_of_compositional_serial_limit`,
   `FrameOver.levels_closed_of_limit`,
   `PartialHistory.constraint_of_compositional_serial_limit`). Prove the statement at explicit
   constraint hypotheses under the `_of_<constraints>` naming convention, keep the
   binder-carrying original as a one-line corollary whose signature line is byte-identical so no
   call site moves, and give both the identical corrected marker.
3. **Unbundle in place** to explicit constraint hypotheses — what the completed
   `HistoryMorphism.lean` work did (`exists_preimage_step_neg_of_ne (hlim' : TaskFrame.Limit
   F'.TaskRel) ...`, marker `Limit`). Honest and gate-clean, but it moves call sites, so route 2
   is preferable wherever the original's signature is depended on.

### Enabler leverage: the 22 do not need 22 twins

The over-reporting sites funnel through a small set of enabler lemmas, each of which is itself
clean of *Saturation*. Measured:

| Enabler | Probe transitive hits | Already has a binder-free twin? |
|---|---|---|
| `FrameOver.nullity_identity` | `Ser, Lim` | **yes** — `nullity_identity_of_serial_limit` (reaches nothing; takes the two explicitly) |
| `Presheaf.Beh.ofGerm` | `Ser, Lim` | no |
| `FrameOver.isTotal_respects_iff_adjacent` | `Comp, Ser, Lim` | no |
| `FrameOver.taskRel_eq_iter` | `Comp, Ser, Lim` | no |
| `PartialHistory.constraint` | `Comp, Ser, Lim` | **yes** — `constraint_of_compositional_serial_limit` |

So the cascade is shallow and *Saturation*-free at every level: three new enabler twins
(`Beh.ofGerm`, `isTotal_respects_iff_adjacent`, `taskRel_eq_iter`) unlock the `Presheaf/Path.lean`
cluster of 20, the `Nomic/ZTime.lean` cluster of 4, and `ConeUnravelling.lean`'s one site
respectively. No upstream *Saturation* blocker exists anywhere in the chain.

### Three in-source rationales that must yield

Three of the 28 carry docstring prose defending the full-four listing on a *different* definition
of the marker than the specification gives:

- `ConeUnravelling.lean:876` — "The proof reads only the first three, through
  `FrameOver.taskRel_eq_iter`, but the marker lists what the **binder supplies**".
- `Nomic/ZTime.lean:132` — "The marker below lists all four constraints because the
  `[F.IsRegular]` binder supplies all four... a marker records what the declaration consumes, not
  what its proof emphasises."
- `Presheaf/Path.lean:1168` — "The proof term reaches *Seriality* and *Limit* through
  `Beh.ofGerm`'s use of `nullity_identity`; the marker lists the whole bundle the binder
  supplies."

Each of the three is independently confirmed by the probe as to *what the proof reaches*
(`Comp, Ser, Lim`; `Comp, Ser, Lim`; `Ser, Lim`) — the prose and the probe agree on the facts and
disagree only on what the marker is for. `REFERENCE_NORMAL_FORM.md` settles it against them: the
line enumerates what the term reaches. The `ConeUnravelling` note also gives the real reason the
convention drifted — "a three-constraint marker here would advertise a hypothesis set no
declaration in the tree offers" — which is precisely the gap route 2 closes by landing the twin.
These three docstring paragraphs must be rewritten alongside their markers, or the file will
contradict itself.

### Two surfaces to carry along

- `typst/generated/status.typ` holds commit-stamped scalar counts and is a mandatory `file_scope`
  member of any `.lean`-touching phase (`scripts/typst-sync-check.sh` Check 2 compares the
  committed file against a regeneration). It carries no marker counts, so the obligation is to
  re-stamp, not to re-derive content.
- `docs/development/MODULE_INVARIANTS.md` (C34 row) and `docs/development/REFERENCE_NORMAL_FORM.md`
  both state C34a's live discharge-group counts as 7 omit-nothing / 18 delegation / 2 re-export.
  A live run reports **62 / 22 / 2** over 163 markers and 341 binder-carrying declarations. Those
  prose counts are stale now and will move again with this work; a phase that corrects 28 markers
  must re-derive them from the gate's own `PASS C34a` line.

### One gap in C34's own table (out of scope, worth filing separately)

`BUNDLERS` is keyed by the *short* name `IsRegular`, so it matches both
`FrameOver.IsRegular` (four fields) and `NomicFrame.IsRegular` (one field, `regular`). The
companion `BUNDLER_FIELDS` table maps only `comp`/`serial`/`limit`/`saturation`, so a bare
re-export of `NomicFrame.IsRegular.regular` cannot be discharged by the re-export rule even in
principle. Nothing in the 68 depends on this, and the audit does not require touching it.

### Recommendations

**Phase the work by enabler dependency, four phases, each file-scoped.** Every phase's
verification tier must name `bash scripts/check-module-invariants.sh` explicitly (a full
`lake build` covers none of C34/C34a/C34b), and every phase's `file_scope` must include
`typst/generated/status.typ`.

| Phase | Scope | Sites | Work |
|---|---|---|---|
| 1 | `Nomic/Witnesses.lean`, `Nomic/ZTime.lean` (binder-free rows only) | 5 | Marker-only edits; C34a-exempt (no binder). Correct the delegating pairs together so list identity is preserved. Rewrite the `ZTime.lean:132` rationale paragraph. |
| 2 | `ConeUnravelling.lean` + a new binder-free twin of `FrameOver.taskRel_eq_iter` | 1 (+1 new) | Route 2. Rewrite the `ConeUnravelling.lean:876` rationale paragraph, which states the twin's absence as the reason for the over-report. |
| 3 | `Nomic/ZTime.lean` (`mem_lawHist_iff_isStepPath`) + a new binder-free twin of `FrameOver.isTotal_respects_iff_adjacent` | 1 (+1 new) | Route 2. |
| 4 | `Presheaf/Path.lean` + a new binder-free twin of `Presheaf.Beh.ofGerm` | 20 (+1 new) | Route 2 for 17; route 1 (binder deletion) for `toPathAux`/`toPath`/`toPath_length` after a transplant probe confirms the binder is not needed for elaboration. Rewrite the `Path.lean:1168` rationale paragraph. |

**Do not attempt a docstring-only sweep.** 22 of the 28 corrections fail C34a without a twin, and
a phase that edits markers and defers the twins leaves the gate red.

**Do not touch the 40 accurate sites.** The task is right that a blind rewrite would be worse than
the current state; `classification.tsv` is the per-site record that makes the distinction
auditable rather than asserted.

**Re-derive the C34a group counts from the gate's own `PASS C34a` line** when updating
`MODULE_INVARIANTS.md` and `REFERENCE_NORMAL_FORM.md`, rather than computing them by hand.

**Reuse the probe rather than re-deriving the classification.** It is retained at
`specs/evidence/constraints-consumed-marker-audit/marker-consumption-probe.lean` and re-runs in
one `lake env lean` call against the built olean set; after each phase it is the cheapest
confirmation that the corrected markers match what the terms reach.

## Decisions

- **Classification is settled by the closure probe, not by 68 transplant probes.** The probe
  mechanizes the specification's own predicate (transitive reach of a field constant), and it
  reproduces every one of six independently hand-established control markers exactly. The
  transplant probe is retained only for the 3 binder-removal candidates, where the question is
  elaboration, not consumption.
- **Corrected markers are taken verbatim from the probe's hit sets**, spelled in the closed
  vocabulary and ordered as `Compositionality, Seriality, Limit, Saturation` restricted to the
  hits — matching the existing in-tree spelling.
- **No side-attributing marker form is proposed.** `source: ...; base: none` is inadmissible, and
  nothing in the findings needs it: every corrected marker is a plain sublist.
- **The specification wins over the three in-source rationales.** They are rewritten, not honored.
- **Zero-debt**: a sorry-free, axiom-free path exists for all 28 corrections. The only
  restructuring needed is explicit-hypothesis restatement, a pattern the tree already carries
  four instances of.

## Adversarial Self-Verification

The draft's load-bearing claims were re-read against the Claim Verification Bar; two were revised
as a result (see "Recommendations modified after verification" below).

| Claim | Source / counterexample sought | Verification method | Confidence |
|---|---|---|---|
| 28 of 68 sites over-report | Sought a site whose empty hit set is a probe artifact rather than a fact | Compiled probe over the built olean set; value-only variant agrees on all 68 rows; 0/68 module-provenance mismatches | High |
| 40 sites are accurate | Sought a false positive from instance provenance (a field reached through a manufactured regular frame rather than the ambient binder) — 9 sites do reach `instIsRegularOfReflective`/`ofReflectiveRegular` | Resolved by specification, not by measurement: `REFERENCE_NORMAL_FORM.md` defines consumption as "the elaborated proof term reaching the field *at all*", which is provenance-blind. Under the definition of record these 9 are accurate | High for the 31 with no manufacturer in closure; **Medium** for the 9 with one (`not_four_nomicValid`, `coneFrame`, `coneF_twoWayBounded`, `exists_coneUnravelling`, and the 5 over-reporters) — accurate under the written definition, but a reader who takes the marker to mean ambient consumption would read them differently |
| The probe mechanizes the specification's predicate | Checked against the specification's own worked example | `PartialHistory.isTotal_of_isMax` has empty *direct* hits and full-four *transitive* hits, and `REFERENCE_NORMAL_FORM.md` states it consumes *Saturation* — so the standard is transitive, as the probe assumes | High |
| Field constants are the right eight | Sought a ninth access path | `lean_local_search` confirmed `FrameOver.saturation` and `FrameOver.IsRegular.saturation`; source read of TaskFrame.lean:1189-1263 confirms the class has exactly four fields and four re-exports; `TaskFrame.IsRegular` is an `abbrev` onto the same class, `NomicFrame.IsRegular` routes through `instAtIsRegular` to the same constants | High |
| Correcting a binder-carrying marker fails C34a | Tried to find a discharge that would save it | Ran C34a's own `omitted`/`discharge`/`c34a_violation` predicates, extracted verbatim from `check-module-invariants.sh`, against the live census with substituted markers: 4/4 FAIL | High |
| The live C34a counts are 62/22/2 | Checked against both prose documents, which say 7/18/2 | Executed the C34 block: `PASS C34a ... 22 discharge it by delegating ..., 2 by field re-export, and 62 omit nothing` | High |
| A sorry-free path exists | Sought an over-reporting site whose honest restatement needs an unavailable hypothesis | Probed all five enabler lemmas: none reaches *Saturation*, so no enabler twin needs a hypothesis the tree cannot supply | **Medium** — the enabler chain is clean, but no twin has been written and compiled yet; this is a well-founded expectation, not a compiled result |

### Contradiction Log

**Resolved — the marker's definition.** Three in-source docstrings define the marker as "what the
binder supplies"; `REFERENCE_NORMAL_FORM.md` §"What the line claims" and the C34 header both
define it as "the whole of what the elaborated proof term reaches". Precedence: the specification
document is the named authority for the form (the C34 header says so explicitly:
"`docs/development/REFERENCE_NORMAL_FORM.md` defines the form; this is its gate"), and an at-site
docstring is not a competing authority over it. Resolved in favor of the specification; the three
docstrings are defects to be corrected, and the task premise stands.

**Resolved — live counts vs documented counts.** `MODULE_INVARIANTS.md` and
`REFERENCE_NORMAL_FORM.md` say 7/18/2; the gate says 62/22/2. Precedence: an executed gate run
outranks prose describing it. Resolved in favor of the live run; the prose is stale.

**Resolved — probe returning a uniformly clean result.** The first probe run reported zero field
hits for all 68 sites with plausible closure sizes (12-974 constants). Rather than report that,
the cause was found: `ConstantInfo.value?` returns `none` for every `thmInfo` on Lean v4.33
unless `allowOpaque := true` is passed, so the walk covered types only. The recipe in
`context/project/lean4/patterns/dependency-tracing.md` Shape 1 uses the bare form and is
therefore wrong for theorems; its stated anti-silence heuristic ("a non-trivial closure size is
itself evidence the traversal is doing real work") does not catch this. Recorded as an issue;
the context extension below carries the fix.

**No unresolved contradictions.**

### Recommendations modified after verification

- The draft initially split the 68 into 28 over-reporters, 36 accurate and 4 "unresolved",
  treating the manufactured-instance path as a false-positive hazard requiring per-site transplant
  probes. Reading `REFERENCE_NORMAL_FORM.md`'s "reaching the field *at all*" clause showed the
  hazard is dissolved by the definition, not by measurement: the 4 are accurate under the
  definition of record. Revised to 28 / 40 / 0, with the residual reader-expectation risk recorded
  as Medium confidence in the table above rather than as an open classification question.
- The draft initially carried a `direct` (depth-1) hit column as a second signal. It was validated
  as mechanically sound (`FrameOver.nullity`'s own value does show `FrameOver.serial` and
  `FrameOver.limit`) but reads empty for all 68 sites, and it under-reports for `def`s whose proof
  obligations Lean lifts into `_proof_N` auxiliaries. Dropped from the recommendations as a
  validated null result rather than reported as signal it does not carry.

## Tactic Survey Results

No proof-search tactics were surveyed: this task's unit of work is a docstring line plus, where
the gate requires it, an explicit-hypothesis restatement whose proof body is the original's. The
probe runs listed below are the mechanical work of record.

| Probe | Question | Result |
|---|---|---|
| closure, `value?` bare | transitive field reach over 68 sites | **invalid** — 0 hits everywhere; theorem values absent (see Contradiction Log) |
| closure, `value? (allowOpaque := true)` | same | 68/68 classified; 28 over-report |
| same + `getModuleFor?` | does each resolved name live in its marker's file? | 0/68 mismatches |
| value-only variant | does including the type change a verdict? | 0/68 differences |
| control set (10 targets) | do hand-established markers reproduce? | 6/6 binder-carrying controls exact; 2 explicit-hypothesis twins correctly empty |
| C34a predicate simulation | does a corrected marker pass the gate? | 4/4 FAIL |

## Context Extension Recommendations

- **Topic**: `context/project/lean4/patterns/dependency-tracing.md` Shape 1 (and Shape 2, which
  reuses `collect` verbatim).
  **Gap**: both use `ci.value?`, which returns `none` for every theorem on Lean v4.33, so the
  probe silently walks types only and reports a clean closure. The file's anti-silence advice
  does not catch it, and the originating use evidently had `def` targets, where the bug is
  invisible.
  **Recommendation**: change both snippets to `ci.value? (allowOpaque := true)`, and replace the
  closure-size heuristic with a named positive control — a declaration known to reach the suspect
  set, asserted to hit it — since only a positive control distinguishes a clean tree from a
  broken walk.

- **Topic**: `context/project/lean4/patterns/plan-authoring-gate-collisions.md`.
  **Gap**: the collision documented here — correcting a `Constraints consumed:` marker *downward*
  is refused by C34a unless a binder-free twin lands in the same phase — is a gate that fires on
  a change that looks like a comment edit. A plan author who sizes the work as 28 docstring lines
  will be wrong by an order of magnitude.
  **Recommendation**: add the C34a entry with the three discharge routes and the
  `_of_<constraints>` twin-naming convention.

## Appendix

### Probe invocations

```
lake env lean <probe>            # 5 runs, each against the built olean set
bash .claude/scripts/lake-build-guard.sh build --timeout 2400 -- build \
  FormalSystem.Semantics FormalSystem.NomicLanguage
python3 <extracted C34 block>    # live gate run: PASS C34a, PASS C34b
```

### Search queries used

- `lean_local_search "FrameOver.saturation"` -> confirmed `FormalSystem.Semantics.FrameOver.saturation`
  (theorem) and `FormalSystem.Semantics.FrameOver.IsRegular.saturation` (declaration). Index state
  was `warming`, so this is read as a positive hit only, never as proof of absence.
- `grep -rn "Constraints consumed: Compositionality, Seriality, Limit, Saturation"` -> 69 hits, 17 files
- `grep -rn "whole bundle|binder supplies"` -> the three in-source rationales plus two already-honest
  notes in `Extension/Constraint.lean` and one in `Presheaf/Ray.lean`

### References

- `docs/development/REFERENCE_NORMAL_FORM.md` — §"What the line claims", §"Consumption is not
  elimination", §"Where it goes, and what gates it"
- `docs/development/MODULE_INVARIANTS.md` — C34a / C34b row
- `scripts/check-module-invariants.sh` — C34 block, `BUNDLERS` / `BUNDLER_FIELDS` /
  `omitted` / `delegates` / `reexports` / `c34a_violation`
- `FormalSystem/Semantics/TaskFrame.lean:1184-1266` — the class, its four fields, the four re-exports
- `FormalSystem/Semantics/HistoryMorphism.lean:300-321`, `FormalSystem/Semantics/UniversalCover.lean:473-590`
  — the completed corrections used as controls
- `specs/evidence/history-morphism-saturation-audit/` — the two compiled transplant probes from the
  originating work
- `specs/evidence/constraints-consumed-marker-audit/` — this audit's probe, classification and gate simulation
