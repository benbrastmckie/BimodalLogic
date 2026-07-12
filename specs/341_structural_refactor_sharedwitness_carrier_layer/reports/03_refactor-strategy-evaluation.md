# Research Report: Task 341 — Reconciled Refactor Strategy (Team Synthesis)

- **Task**: 341 - structural_refactor_sharedwitness_carrier_layer
- **Started**: 2026-07-12
- **Completed**: 2026-07-12
- **Effort**: synthesis of 3-angle team research + 2 prior reports + 1 draft plan + 1 cross-task report
- **Dependencies**: 340 [done], 337 [done], 335 [done], 346/347 [done], **348 [must reach COMPLETED + `SharedWitness.lean` frozen before code-move phases]**; forward-compat cross-check against 349 (in-flight, file-disjoint — see §5)
- **Sources/Inputs**:
  - `reports/03_teammate-a-decomposition-findings.md` (module boundaries, Angle A)
  - `reports/03_teammate-b-api-surface-findings.md` (public API surface, Angle B)
  - `reports/03_teammate-c-mechanics-forwardcompat-findings.md` (mechanics + endChar forward-compat, Angle C)
  - `reports/01_sharedwitness-declaration-survey.md` (PRIOR, **STALE**: measured 10,037 lines; superseded by Angle A's 12,800-line re-verification)
  - `reports/02_post-kamp-revision-realignment.md` (PRIOR, **PARTLY STALE**: correctly flagged the "sixth seam" and the Prop 4.3 re-citation need, both of which this report resolves)
  - `plans/01_module-split-design.md` (DRAFT plan, **STALE phase sizes**: five-seam design at pre-growth line counts; superseded by §2–§3 below)
  - `specs/349_.../reports/05_rabinovich-faithful-endchar-architecture.md` (faithful endChar architecture; consulted for §5 disjointness confirmation)
- **Artifacts**: this report (single source `/revise 341` consumes)
- **Standards**: report-format.md, plan-format.md, status-markers.md, artifact-management.md, lean4.md, git-workflow.md

## Executive Summary

- **Strategy**: privatize-first-then-split. Phase 1 mechanically privatizes the 346 leaked-public
  symbols and cross-reference-audits the ~430 total file-scoped privates (85 pre-existing + 346
  new) **before** any module boundary is cut — this is the single highest-leverage, lowest-risk
  step and de-risks every subsequent extraction.
- **Final module set**: Angle A's 10-module + hub design (`Slots → OrderGate → Carrier →
  Completeness → EngineInputs → Soundness → DisjunctionSpikes → Assembly → KitFold →
  FragmentFoldRight → hub`) is adopted as-is. It is the only one of the three module maps
  measured against the **current, post-growth 12,800-line file** and it already covers the
  "sixth seam" (SW:10210–12800) that reports 01/02 flagged as unmapped — no separate seam is
  needed.
- **Phase count**: **41 phases** total (6 setup/gate + 31 leaf-first ≤500-line extraction
  sub-phases + 4 closing phases), because every one of the 10 modules exceeds the 500-line
  hard-mode cap and must be built across multiple green sub-phase commits. **This exceeds a
  single 13-cycle `/orchestrate` budget by ~3x — plan for 4 orchestrate runs or explicit
  multi-session `/implement` resumption.**
- **349 disjointness confirmed**: report 05 routes the entire faithful-`endChar` fix through
  `Base.lean`/`Lemma32Reduction.lean`/`NavigatedEndChar.lean` assets and explicitly scopes its
  edits to `Base.lean` + `NavigatedEndChar.lean` only (report 05 §6, "Wave/territory note");
  zero `kvE2_sep*` references exist in any of the three endChar files. 341 and 349 touch
  disjoint files and may proceed without cross-serializing edits (ordinary git hygiene only).
- **Scope**: 341 splits **only** `SharedWitness.lean`. The carrier trio (`Base.lean`,
  `CarrierK1V.lean`, `CarrierKv.lean`) and `SubBracket2V.lean` are **out of scope** — the
  carrier-trio naming cleanup Angle B proposes (Finding 4) is a candidate for a new sibling task,
  not 341.
- **Renames deferred**: all 31 frozen-pinned public symbols keep their current names; Angle B's
  `Sep.*`/`SepZone.*` proposal is recorded as a proposal for a post-thaw naming task
  (cross-ref task 175's "no opaque abbreviations" rule), never executed inside 341.

## Context & Scope

341 is a pure structural (code-health) refactor of `NfMultiAnchorBridge/SharedWitness.lean`
(12,800 lines at HEAD `775b89db7`, 2026-07-12) into sibling modules under a new
`NfMultiAnchorBridge/SharedWitness/` subdirectory, with `SharedWitness.lean` reduced to a thin
re-export hub. It carries an explicit **no-semantic-change** invariant (preserve every proof,
statement, and evaluation behavior byte-for-verbatim) plus the LITMUS check
(`NavigatedSpine.lean:437`, `bracketEndChar_kvE2`) and the F1–F7 faithfulness invariants
(owned by 346/347/348, not re-adjudicated by 341 — report 02 Finding 1).

Three research angles ran in parallel against the current HEAD:

- **Angle A** (module decomposition): re-verified the file is a single flat namespace with zero
  `section`/`mutual` blocks, so any source-order cut is acyclic by construction; proposed 10
  content modules + hub.
- **Angle B** (public API surface): re-based the "what's public" question on cross-file
  consumption instead of internal reference count, finding 31 of 377 declared-public symbols are
  actually consumed externally; the other 346 are leaked internal scaffolding.
- **Angle C** (mechanics + forward-compat): verified the split mechanics are unusually safe
  (no `variable`/`section` capture hazard), produced a ≤500-line hard-mode phase sequencing
  template, and proved 341 and 349 (the faithful endChar rebuild) touch disjoint files.

This report reconciles the three angles, resolves three explicit conflicts, and produces the
single module set + phase list + green-preservation contract that `/revise 341` consumes.

## Findings

### Conflict 1 — API metric: internal reference count vs. cross-file consumption (RESOLVED)

**The conflict**: report 01 (prior, stale) ranked "top anchors" — `kvE2_sepArr'` (54 uses),
`kvE2_sepHonestOrder'` (93 uses), `kvE2_ordRank` (49 uses), `kvE2_sepSlotLe` (26 uses),
`kvE2_sepDisjValidOwner` (12 uses) — by **internal** reference count within `SharedWitness.lean`
(report 01 "Current Symbol Verification" table). Angle B re-measured the same five symbols
against **project-wide cross-file** consumption and found **zero external consumers** for all
five (`03_teammate-b-api-surface-findings.md` Finding 1 table).

**Resolution — adopt cross-file consumption as the API metric.** Report 01's "anchors" answer
"what is heavily used internally" (i.e., what is architecturally central to the file's own
construction), not "what other files depend on" (the actual definition of a public API surface
for a split whose contract is "preserve every import site"). The five symbols are the **largest
pieces of internal scaffolding** (up to 135 internal uses for `kvE2_sepHonestOrder'`), not API to
preserve at module boundaries. Concretely: `grep -cE '^(noncomputable )?private '
SharedWitness.lean` = 84 (Angle B) vs. 85 (Angle A's `grep -cE '^\s*private '`) — the two grep
patterns disagree by exactly 1, likely on a `noncomputable private` line; **Phase 1's audit (§3)
re-counts exactly** rather than trusting either grep in isolation. Of 460–461 total top-level
decls, 377 are declared `public` and only **31 (8%)** are ever referenced from another file
(`OuterGate.lean`, `ExteriorZoneTriage.lean`, `ExteriorBracket.lean`, `ExteriorNegation.lean`,
`ExteriorNegationPast.lean` — the union of all five frozen consumers). **377 − 31 = 346
leaked-public symbols** are safe to privatize.

**Consequence for the split design**: module boundaries must preserve the **31-symbol external
contract** (via the re-export hub), not report 01's internal-reference "top 10". Internal
scaffolding — including the report-01 anchors — is free to be privatized/module-local scoped as
part of the split, which shrinks every subsequent module's effective public surface and reduces
cross-module coupling risk.

### Conflict 2 — Module granularity: 10-module map vs. 18-phase sequencing vs. the "sixth seam" (RESOLVED)

**The conflict**: Angle A proposes **10 content modules + hub** (bands verified against the
current 12,800-line HEAD). Angle C proposes an **18-phase ≤500-line sequencing** built from the
**stale** `plans/01` five-seam sizes (1480/2640/2000/2200 lines, pre-growth) and explicitly flags
an un-mapped "sixth seam" at SW:10210–12800 that neither the stale plan nor report 01/02's
five-seam map covers (report 02 Finding 3).

**Resolution — adopt Angle A's 10-module map as the final module boundary set; Angle C's
sequencing methodology (not its stale sizes) governs phase construction.** Angle A's bands are
the *only* ones of the three inputs measured directly against current HEAD via `grep`/`wc -l`,
and they already extend through line 12800 — module I (`KitFold.lean`, 9814–11515) and module J
(`FragmentFoldRight.lean`, 11516–12800) **are** the sixth seam Angle C and report 02 flagged as
missing; it does not need a separate module. Angle C's contribution that *is* adopted verbatim:
the leaf-first extraction order, the ≤500-line-per-phase hard-mode cap, the verbatim-move
discipline, and the scoped-then-full-build-per-phase gate (§4). Because every one of Angle A's 10
modules exceeds 500 lines (minimum 731, `Carrier.lean`), **every module requires 2–4 sub-phases**,
recomputed in §3 against Angle A's true sizes rather than Angle C's stale seam estimates.

**Final counts** (stated explicitly per the deliverable requirement):
- **Module count: 10 content modules + 1 re-export hub = 11 files.**
- **Phase count: 41 phases** (§3).

### Conflict 3 — Scope boundary: SharedWitness.lean only, or the whole carrier layer? (RESOLVED)

**The conflict**: Angle B's Finding 3–4 documents real API smells in the carrier trio
(`Base.lean`, `CarrierK1V.lean`, `CarrierKv.lean` — inconsistent `endChar*` vs.
`bracketEndChar_*` naming, opaque `*cex` abbreviations, trivial `_zero`/`_one` variant pairs) and
leaves as an **open question** (Finding 3, Open Questions #3) whether 341's split boundary
includes the trio.

**Resolution — 341 splits ONLY `SharedWitness.lean`.** All three angles' own scoping statements
agree on this once read together: Angle A's entire decomposition targets
`NfMultiAnchorBridge/SharedWitness.lean` exclusively (title, §0 Headline); Angle C's mechanics
analysis is scoped to `SharedWitness.lean`'s split (§1) and treats `Base.lean`/
`Lemma32Reduction.lean`/`CarrierKv.lean` purely as **upstream-of-endChar, not-341** territory
(§3.3: "341 must therefore NOT attempt to pull these into any `SharedWitness/*` module — it
structurally cannot"); the prior stale reports (01 "Files 341 touches", 02) both scope 341 to
`SharedWitness.lean` + the aggregator + `Boneyard/`. `SubBracket2V.lean` is additionally **frozen**
by task 349 and cannot be edited by any task. **Decision**: Angle B's Finding 4 naming-smell
proposals for `Base`/`CarrierK1V`/`CarrierKv` (the `endChar`/`bracketEndChar` unification, the
`*cex` renames, the `_zero`/`_one` merge) are **out of scope for 341** and are recorded here as
candidates for a new sibling task (to be spawned against task 175's naming-standard charter),
not executed by `/revise 341`.

## Decisions

### Decision 1 — Recommended strategy: privatize-first-then-split

Adopted in this exact order, because privatization is mechanically safe *only* while the file is
still monolithic (a `private` decl restricts to file scope; while everything is one file, no
internal use can ever cross that boundary) and it shrinks the coupling surface every later
extraction phase must respect:

1. **(a) Privatize the ~346 leaked-public symbols** (Angle B Finding 1–2) in place, single-file
   edit, `lake build` green. Safe by construction: Angle B verified zero external consumers via
   `grep -wF` project-wide; a build failure after privatizing would itself prove the metric wrong
   for that symbol, so green-build is the authoritative confirmation, not the grep alone (Angle B
   "Medium confidence" caveat, Confidence + Open Questions §2).
2. **(a, continued) Cross-reference-audit the ~430 total file-scoped privates** (85 pre-existing
   per Angle A's R2 + the newly-privatized 346 — note the 84-vs-85 discrepancy from Conflict 1
   is resolved by re-running the audit's own count, not by trusting either prior grep) via
   `lean_references` (or an equivalent last-use `grep` scan) on **every** private decl, recording
   its last-use line. This produces the input the module-boundary DAG (Decision 2) needs to
   guarantee no cut orphans a private symbol from its sole consumer (Angle A R2, "most important"
   risk).
3. **(b) Split the linear tower** into the 10-module set (Decision 2) + hub, importing strictly
   backward per the verified acyclic linear-tower structure (Angle A §0, Angle C §1.3).
4. **Mandatory re-export hub** preserves the 31 frozen-pinned exports byte-for-byte at the import
   level; `OuterGate.lean` and `ExteriorZoneTriage.lean` (the only two importers of
   `SharedWitness`) require zero edits (Angle A §4, Angle C §1.2).
5. **Renames deferred.** No public symbol is renamed inside 341 — all 31 are frozen-pinned by
   task-349 consumers (`OuterGate`, `ExteriorBracket`, `ExteriorZoneTriage`, `ExteriorNegation`,
   `ExteriorNegationPast`) and cannot be renamed without editing a frozen file (Angle B Finding
   5). The `Sep.*`/`SepZone.*` Mathlib-style rename proposal (Angle B Finding 2 "Proposed name"
   column) is recorded as a **post-thaw naming task** proposal, cross-referenced against task
   175's "no opaque abbreviations" standard (which already flags the carrier trio's `*cex`
   abbreviations, Angle B Finding 4.2) — not executed here.

### Decision 2 — Final module boundary set

All modules live under `NfMultiAnchorBridge/SharedWitness/`, reopen
`namespace Bimodal.Metalogic.WeakCanonical.Kamp`, and replicate the three `open`s
(`open Bimodal.Syntax`, `…WeakCanonical`, `…WeakCanonical.Separation` — SharedWitness.lean:52–54).
Import order is strictly backward (verified acyclic: zero `mutual` blocks, single flat namespace
— Angle A §0).

| # | Module | Band (HEAD lines) | Est. LOC | Decls | Imports | Frozen-API group(s) hosted |
|---|--------|--------------------|----------|-------|---------|------------------------------|
| A | `Slots.lean` | 50–898 | 849 | 79 | `SubBracket2V`, `NavigatedSpine` | Group 1 (7 zone constants, :71–95), most of Group 2 (:166–244) |
| B | `OrderGate.lean` | 899–2332 | 1434 | 98 | `Slots` | rest of Group 2 (`kvE2_sepEpL/R` :1054/1076, `kvE2_sepPtW` :1100), Group 3 head (`kvE2_sepGate` :1254) |
| C | `Carrier.lean` | 2333–3063 | 731 | 24 | `OrderGate` | Group 3 (`kvE2_sepGate_holds_of_honest` :2797), Group 4 head (`kvE2_sepBody` :2347) |
| D | `Completeness.lean` | 3064–4116 | 1053 | 42 | `Carrier` | Group 4 (`kvE2_sepBody_complete` :3363) |
| E | `EngineInputs.lean` | 4117–5447 | 1331 | 64 | `Completeness` | (internal only — no frozen-pinned symbol) |
| F | `Soundness.lean` | 5448–6957 | 1510 | 51 | `EngineInputs` | Group 6 (`kvE2_sepHonest_hLR_absurd` :6087) |
| G | `DisjunctionSpikes.lean` | 6958–8149 | 1192 | 37 | `Soundness` | Group 6 (`kvE2_sepProjFresh_eval` :7297) |
| H | `Assembly.lean` | 8150–9813 | 1664 | 40 | `DisjunctionSpikes` | Group 4 (`kvE2_sepBody_extract` :8575, `kvE2_sepBody_holds_of_honest` :9800) |
| I | `KitFold.lean` | 9814–11515 | 1702 | 17 | `Assembly` | Group 3 tail (`kvE2_sepGateAtPin_fragL` :10605), Group 5 (`kvE2_sepFragment_frag` :10219, `kvE2_sepFragment_realizable` :10265) |
| J | `FragmentFoldRight.lean` | 11516–12800 | 1285 | 10 | `KitFold` | Group 4 tail (`kvE2_sepBody_kit_sound_frag` :12580), Group 5 tail (`kvE2_outer_fold_frag` :12665), Group 6 tail (`kvE2_sepInterior_exterior_notRealizable` :12627) |
| — | `SharedWitness.lean` (hub) | — | ~30 | 0 | `FragmentFoldRight` (transitively all) | re-exports all 31 |

**Import DAG (acyclic by construction)**:

```
SubBracket2V ─┐
NavigatedSpine┴─▶ Slots ─▶ OrderGate ─▶ Carrier ─▶ Completeness ─▶ EngineInputs
                 ─▶ Soundness ─▶ DisjunctionSpikes ─▶ Assembly ─▶ KitFold
                 ─▶ FragmentFoldRight ─▶ SharedWitness (hub)
```

**Hard rule (binding, from Angle C §1.3)**: no `SharedWitness/*` submodule may import the hub
(`…SharedWitness`), `OuterGate.lean`, or `ExteriorZoneTriage.lean` — any such import closes a
cycle. Extraction must proceed strictly in the A→J topological order above.

**Alternative not adopted**: Angle A also documented an 11-module variant splitting `OrderGate`
at line 1267 into `GateSegments.lean` (368 LOC) + `OrderRank.lean` (1066 LOC). Both are valid and
acyclic; the 10-module default is adopted for fewer files at equal cohesion (Angle A §3 Notes).
Record as a documented option, not a re-opened decision, unless the Phase-1 audit (Decision 1
step 2) finds `OrderGate`'s 1434 LOC creates an unmanageable single-module private-boundary
count.

## Recommendations — Phase plan for `/revise 341`

**Total: 41 phases** (6 setup/gate + 31 leaf-first ≤500-line extraction sub-phases + 4 closing
phases). **This exceeds a single 13-cycle `/orchestrate` budget (41 ÷ 13 ≈ 3.15) — plan for
approximately 4 `/orchestrate` invocations, or explicit multi-session `/implement 341`
resumption; do not attempt to force it into one orchestrate run.**

### Setup / gate phases (P1–P6)

| Phase | Goal | Depends on | `.lean` edits |
|---|---|---|---|
| P1 | **GATE-0**: confirm 348 `[COMPLETED]` + `SharedWitness.lean` frozen (supersedes stale "335" gate wording in `plans/01`); baseline `lake build` green, `lean_verify` axiom-clean, sorry count 0; record frozen HEAD SHA | — | none |
| P2 | **Privatize-346**: mark all 346 leaked-public symbols (Angle B Finding 1) `private`, single-file edit to `SharedWitness.lean`; `lake build` green (build failure on any symbol falsifies its "0 external consumers" classification — escalate, do not force) | P1 | `SharedWitness.lean` only |
| P3 | **Private cross-reference audit**: `lean_references` (or grep-based last-use scan) on all ~430 now-private decls (85 pre-existing + 346 from P2); record each one's last-use line; resolve the 84-vs-85 count discrepancy by direct count | P2 | none (audit only) |
| P4 | **Dependency DAG + cut-line spec**: finalize exact cut lines within each of the 10 modules (Decision 2 bands are the top-level cut; P4 resolves any privates from P3 whose last use crosses a proposed boundary — hoist to an earlier module or the boundary's target module per the DAG, never left orphaned) | P3 | design note only |
| P5 | **Boneyard inventory + citation-hazard register**: confirm 0 live consumers (via P3's audit) for SW:899 "STAGED, not yet wired" predicate, SW:6698 O4 CRUX RECORD, SW:6528 hgate residue; register every `md:NN` citation the split will touch for re-citation to Rabinovich PDF pages; re-verify these against the reshaped file per report 02 recommendation #5 (some may now be wired-in by 344/346) | P3 | none (inventory only) |
| P6 | **GATE-1**: re-diff frozen `SharedWitness.lean` against P4's cut-line spec; confirm baseline still green + axiom-clean after P2's privatization; if not green, mark `[BLOCKED]` and stop | P4, P5 | none |

### Extraction phases (P7–P37) — leaf-first, ≤500 lines/phase, each ending green

Each module is built across multiple sequential green sub-phases: move the next ≤500-line
downward-closed chunk (per P4's cut-line spec) from the hub into the target module file, wire/
extend the import, scoped `lake build` then full `lake build`, commit
(`task 341 phase P.O: extract <chunk> into <Module>`).

| Module | Band | Est. LOC | Sub-phases | Phase IDs |
|---|---|---|---|---|
| A `Slots.lean` | 50–898 | 849 | 2 | P7–P8 |
| B `OrderGate.lean` | 899–2332 | 1434 | 3 | P9–P11 |
| C `Carrier.lean` | 2333–3063 | 731 | 2 | P12–P13 |
| D `Completeness.lean` | 3064–4116 | 1053 | 3 | P14–P16 |
| E `EngineInputs.lean` | 4117–5447 | 1331 | 3 | P17–P19 |
| F `Soundness.lean` | 5448–6957 | 1510 | 4 | P20–P23 |
| G `DisjunctionSpikes.lean` | 6958–8149 | 1192 | 3 | P24–P26 |
| H `Assembly.lean` | 8150–9813 | 1664 | 4 | P27–P30 |
| I `KitFold.lean` | 9814–11515 | 1702 | 4 | P31–P34 |
| J `FragmentFoldRight.lean` | 11516–12800 | 1285 | 3 | P35–P37 |

Notes:
- Sub-phase count = `ceil(est. LOC / 500)`; exact intra-module cut lines are P4's deliverable,
  not fixed here (line numbers drift; P4 anchors on symbol names per Angle A R4's binding rule).
- The one non-contiguity hazard (`kvE2_sepBody` def at :2347 living in module C, its `_extract`
  in H, `outer_fold` in I/J) is **dissolved, not mitigated**, under this order-preserving cut —
  Angle A §5 R3 confirms all consumers of the def are in later modules (C→D→…→J), so no forward
  reference exists. P4 need only confirm this holds after P2's privatization (privatizing cannot
  introduce a forward reference — it only restricts visibility).
- Every sub-phase's own verification: `lake build` (scoped module, then full) green; `lean_verify`
  axiom check on that module's public/frozen anchors returns exactly
  `{propext, Classical.choice, Quot.sound}`; sorry/admit code-count 0 (not counting prose).

### Closing phases (P38–P41)

| Phase | Goal | Depends on |
|---|---|---|
| P38 | **Hub reduction**: reduce `SharedWitness.lean` to imports of all 10 modules + module docstring; confirm it holds zero decls; full `lake build`; confirm `OuterGate.lean`/`ExteriorZoneTriage.lean`/aggregator compile **unchanged** | P37 |
| P39 | **Boneyard archival**: move P5-confirmed 0-consumer items to `Theories/Bimodal/Boneyard/SharedWitnessResidue/`; rewrite/drop deleted-symbol comment residue (`kvE2_sepArrL/R/Valid/Singleton`); add `NOTE:`/`QUESTION:` to every PRESERVE-IN-PLACE item | P38 |
| P40 | **API/doc pass**: per-module docstrings grounded in Rabinovich Def 3.1/Lemma 3.2(1)/Cor 5.4/§5 (PDF pages, never `md:NN`); re-cite every P5-registered touched `md:NN` comment to the **revised Prop 4.3 exterior treatment** (347/348), explicitly retiring the old prop43-successor framing (report 02 Finding 4) — this applies specifically to modules I and J (the SW:10210–12800 region) | P39 |
| P41 | **Final verification**: full `lake build` (clean if budget allows); `lean_verify` on all 31 frozen-pinned anchors → axioms exactly `{propext, Classical.choice, Quot.sound}`; sorry/admit = 0; LITMUS (`NavigatedSpine.lean:437`) confirmed byte-unchanged; import-equivalence + downstream-unchanged tripwires (§ Green-Preservation Contract); write execution summary | P40 |

## Green-Preservation Contract (binding, every extraction phase P7–P37 and every closing phase)

1. **Axiom check**: `lean_verify` (fully-qualified name) on every anchor now living in the
   touched module — expect exactly `{propext, Classical.choice, Quot.sound}`. A verbatim move
   must never change the axiom set; any deviation is a hard stop, not a warning.
2. **Scoped → full build**: `lake build Bimodal.…NfMultiAnchorBridge.SharedWitness.<Module>`
   (fast, scoped) first, then full `lake build` (proves the hub re-export and downstream
   `OuterGate.lean`/`ExteriorZoneTriage.lean`/aggregator `NfMultiAnchorBridge.lean` still
   compile). Green + committed before the next phase (commit-per-green-substep mandate).
3. **LITMUS anchor**: `bracketEndChar_kvE2` in `NavigatedSpine.lean` (~:437). 341 never edits
   `NavigatedSpine.lean`, so this is preserved by non-modification; P41 confirms byte-unchanged.
4. **Import-equivalence tripwire**: after P38 (hub reduction), assert the set of names
   re-exported by `…SharedWitness` equals the frozen P1 baseline — compile a throwaway `example`
   referencing each of the 31 frozen-pinned anchors through the hub, or diff `#check` output.
   Catches an accidentally-dropped decl.
5. **Downstream-unchanged tripwire**: `git diff` must show `OuterGate.lean`,
   `ExteriorZoneTriage.lean`, and the aggregator `NfMultiAnchorBridge.lean` **untouched** across
   all 41 phases — any edit there is a red flag that import-preservation failed.
6. **Sorry/admit tripwire**: `grep -c 'sorry\|admit'` in code (not comments, per Angle C §4.1 —
   use `lean_verify`'s source scan, not a raw string grep) = 0 across all new modules at every
   phase.

## Report 05 / 349 Disjointness Confirmation

The 341 SharedWitness split and the 349 faithful-`endChar` rebuild operate on file-disjoint
territory, confirmed by both mechanical grep evidence and report 05's own scoping:

- **Grep evidence** (Angle C, verified): `grep -c kvE2_sep` = **0** in each of
  `NavigatedEndChar.lean`, `Lemma32Reduction.lean`, `Base.lean` — the faithful endChar consumes
  **nothing** from the `SharedWitness.lean` `kvE2_sep*` carrier family. `NavigatedEndChar.lean`
  imports only `{Base, Lemma32Reduction, CarrierKv}` — not `SharedWitness`, `OuterGate`, or
  `ExteriorZoneTriage`. `SharedWitness.lean` imports only `{SubBracket2V, NavigatedSpine}` — not
  any endChar file.
- **Report 05's Base-resident merge choice**: the corrected architecture's Step B (the
  ≤2-free-anchor Prop-valued merge, the analog of Rabinovich's `[…](z0,z1)` Notation 5.2) is
  `nf_zone_flatten_navigable`/`_correct` at **`Base.lean:667`/`687`**, and Step A's arity
  reduction is `nfEval_le2_reduction` at **`Lemma32Reduction.lean:535`** (report 05 §3.4, §3.5
  table). Every "Green asset consumed" in report 05's §3.5 table lives in `Base.lean`,
  `Lemma32Reduction.lean`, or `NavigatedEndChar.lean` — none is a `kvE2_sep*` symbol.
- **Report 05's own territory declaration** (§6, "Wave / territory note") states the phase
  plan's edits are "additive edits to `Base.lean` (new `endCharStep`, `endChar`,
  `endChar_correct`) and `NavigatedEndChar.lean`; **no edits** to the seven frozen providers,
  `KampPrior.lean`, `Lemma32Reduction.lean`" — `SharedWitness.lean` is not named as an edit
  target anywhere in report 05.

**Conclusion**: this closes Angle C's §3.5 open checklist items 1–2 (which report 05 had not yet
answered when Angle C wrote its report). No cross-serialization of 341's and 349's *edits* is
required beyond ordinary git hygiene (both touch the same `NfMultiAnchorBridge/` directory but
disjoint files, so no import cycle is possible per either DAG). 341 and 349 may run concurrently.

## Risks & Mitigations — ranked open questions / residual risks

| # | Risk | Verification step that closes it at plan time | Owner phase |
|---|------|------------------------------------------------|-------------|
| 1 (H) | **85-vs-84 private count discrepancy** (Conflict 1) may hide 1+ symbols from either audit, and the true cross-boundary count for the combined ~430 privates is unmeasured (Angle A "Open questions" #1) | Run the audit itself (P3) rather than trusting either prior grep; `lean_references` on every private decl is authoritative | P3 |
| 2 (H) | **348 may not yet be `[COMPLETED]` / frozen** when `/revise 341` runs — 348 is `[IMPLEMENTING]` as of the source reports and was still appending below the SW:10210 marker | Re-check `specs/state.json` task 348 status immediately before GATE-0 (P1); do not proceed past P1 if not `[COMPLETED]` + frozen | P1 |
| 3 (M) | **41-phase plan exceeds one orchestrate budget** — cross-session/cross-run state must be tracked correctly (resume point, which module/sub-phase is next) | Use the phase-ID table (P1–P41) as the resume ledger; each phase is an independent green commit per the rollback contract, so resumption is mechanical | P1 (design-time), ongoing |
| 4 (M) | **`OrderGate.lean` (1434 LOC, 3 sub-phases) may still be an unwieldy single-file target** if P3's private audit finds heavy cross-boundary private use within band B | If so, fall back to the documented 11-module alternative (split B at :1267 into `GateSegments.lean` + `OrderRank.lean`) — already specified in Decision 2, not a new design | P4 |
| 5 (M) | **Boneyard candidates may now be wired-in** by tasks 344/346 (report 02 recommendation #5) — SW:899/SW:6528 "STAGED"/hgate residue could be load-bearing post-revision | Re-run `lean_references` on each Boneyard candidate at P5, not reuse report 01/02's pre-revision classification | P5 |
| 6 (L) | **`md:NN` re-citation scope**: 89 dangling citations exist file-wide, but the binding rule only re-cites ones the split **touches** — under-scoping risks leaving a retired-framing citation (old prop43-successor) uncorrected in the SW:10210–12800 region specifically | P5 registers every touched `md:NN`; P40 explicitly re-grounds modules I/J in the revised Prop 4.3 treatment (report 02 Finding 4) | P5, P40 |
| 7 (L) | **Lake file+directory coexistence** (`SharedWitness.lean` beside `SharedWitness/`) — idiomatic Mathlib pattern, low risk but unverified on this specific project layout until the first extraction lands | First `lake build` after P7 (module A, first extraction) is the empirical confirmation | P7 |

## Appendix — Verification Trail (carried forward from source angles)

- `SharedWitness.lean` = 12,800 lines at HEAD `775b89db7` (Angle A `wc -l`); single flat
  `namespace Bimodal.Metalogic.WeakCanonical.Kamp` (:50–12800), zero `section`/`mutual` blocks
  (`grep -nE '^(namespace|section|end|mutual)'`).
- Imports: `SharedWitness.lean` ← `{SubBracket2V, NavigatedSpine}` only (`grep -nE '^import'`).
- External importers of `SharedWitness`: `NfMultiAnchorBridge.lean` (aggregator),
  `OuterGate.lean` (frozen), `ExteriorZoneTriage.lean` (frozen list), `ExteriorNegation.lean`
  (frozen) — 4 files, all preserved by the hub without edits.
- `grep -cE '^(noncomputable )?private ' SharedWitness.lean` = 84 (Angle B); Angle A's
  `grep -cE '^\s*private '` = 85 — discrepancy flagged, resolved by P3's direct audit (Risk 1).
- 377 declared-public names × `grep -wF` against
  `{OuterGate, ExteriorZoneTriage, ExteriorBracket, ExteriorNegation, ExteriorNegationPast}` →
  union = 31 (Angle B Finding 1–2, full 31-symbol table with SW line numbers in that report).
- `grep -c kvE2_sep` = 0 in `{NavigatedEndChar.lean, Lemma32Reduction.lean, Base.lean}` (Angle C
  §3.2, re-confirmed against report 05 §3.5's asset table).
- LITMUS text confirmed at `NavigatedSpine.lean:437`, discussing `bracketEndChar_kvE2` (not a
  `SharedWitness` symbol) — Angle C Verification Trail.
- Task 175 cited as the naming-standard authority for the deferred `Sep.*`/opaque-abbreviation
  renames (Angle B Finding 4.2, "no opaque abbreviations" rule).
