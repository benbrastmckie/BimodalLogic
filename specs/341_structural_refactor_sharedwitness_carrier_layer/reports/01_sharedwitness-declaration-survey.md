# Research Report: Task 341 — SharedWitness.lean Declaration-Graph Survey & Module-Split Map

- **Task**: 341 - structural_refactor_sharedwitness_carrier_layer
- **Status**: [NOT STARTED] (survey phase; hard sequencing: implementation must wait for 335)
- **Date**: 2026-07-10
- **Session**: sess_1783723095_edd5a7_341
- **Type**: lean4 (research/survey only — no source edits, no code moved)
- **Dependencies**: 340 [done], 337 [done], **335 [PLANNED — NOT done; blocks implementation]**
- **Reports Integrated**: task 341 description (state.json); live `wc -l` and `grep` inventory of `NfMultiAnchorBridge/`

## Executive Summary

`SharedWitness.lean` measures **10,037 lines** at HEAD (description said ~9248; it has grown a further
~8%). The enclosing `NfMultiAnchorBridge/` directory is **18,889 lines across 11 files**. The file is
sorry-free (8 `sorry|admit` string hits are all inside prose comments), axiom-clean, and carries **89
dangling `md:NN` citations** confirmed present (top offenders: `md:77`×27, `md:168`×24, `md:154`×9,
`md:72`×8, `md:61`×6). The file has **117 defs, 315 theorems, 1 abbrev, 1 structure, 2 inductives**,
and — critically — **zero `section`/`namespace` structure inside** (all decls live in one flat
`namespace Bimodal.Metalogic.WeakCanonical.Kamp` opened at the top). Organization is entirely by
`/-! ## …` comment banners (40 of them), which give a clean, ready-made seam map. The five module
seams named in the task description map cleanly onto contiguous banner ranges. The deleted-symbol
comment residue and two "inert/staged" blocks are the primary Boneyard candidates. **This is a survey
only; implementation is blocked on 335.**

## Current Symbol Verification (name the split against THESE)

| Symbol | Occurrences | Anchor | Role |
|---|---|---|---|
| `kvE2_sepArr'` | 54 | mem SW:1888, sound SW:6918 | live faithful carrier arrangement |
| `kvE2_sepDisjValidOwner` | 12 | def SW:1733 region | validity filter |
| `kvE2_sepPosI` | 230 | noncomputable def SW:211 | interior-restricted owner index |
| `kvE2_ordRank` | 49 | lex-rank kernel (SW:1377 region) | per-slot global-index kernel |
| `kvE2_sepBody` | 69 | def SW:2314 region | the joint carrier (O1) |
| `kvE2_sepBody_extract` | 12 | thm SW:8410 | O3 extraction |
| `kvE2_sepHonest_hLR_absurd` | 7 | SW:5710 region | certificate: former hLR inconsistent |
| `kvE2_sepHonestOrder'` | 93 | SW:5959 region | the ONLY correct (primed) honest order |
| `kvE2_sepSlotLe` | 26 | SW:6556 region | cross-σ slot order |
| `kvE2_sepGate` | 15 | SW:1207 region | the depth-2 gate |

**Deleted symbols — confirmed comment-only (NEVER name the split against these):**
`kvE2_sepArrL` (9 occ, 0 decls), `kvE2_sepArrR` (2 occ, 0 decls), `kvE2_sepSingleton` (0 occ),
`kvE2_sepValid` (the only decl match is the *unrelated* `kvE2_sepValid_tie_of_nodup` at SW:1659 — not
a `kvE2_sepValid` carrier). All surviving mentions are prose/comment.

## Declaration-Graph Seam Map (banner-driven, contiguous ranges)

The 40 `/-! ## …` banners partition the file. Grouped into the five description-named seams plus
support:

### Seam A — Slot/carrier types & enumeration (SW ~4–413, ~410 lines)
- Header (4); outer zone constants Def 3.1 (64); inner zone constants (98); per-σ fold-bit reads &
  formula pieces (146); outer enumeration: positive subs + placement classes (190); tagged joint
  slots — Lemma 3.2(1) interleaving carriers (248); task-340 full per-individual-slot `Fin N` family
  (368). **Foundational types + enumeration — the natural first module.**

### Seam B — Per-slot global-index + `kvE2_ordRank` kernel + interior `kvE2_sepPosI` (SW ~414–1894, ~1480 lines)
- Interior-index transfer foundation, task 342 Phase 1 (414); **[BONEYARD CANDIDATE]** cross-σ
  bit-compatibility predicate, "task 333 Phase 1 — STAGED, not yet wired" (899); joint endpoint
  predicates + `ptW` (1047); refined segment types Cor 5.4 (1116); the depth-2 gate `kvE2_sepGate`
  (1207); task-334 order-type-disjunction index (1248); abstract lex-rank kernel `kvE2_ordRank`
  (1377); task-342 tie-admitting validity infrastructure `kvE2_sepDisjValidOwner` (1503). Contains
  `kvE2_sepPosI` (211 — sits in Seam A's tail but is logically Seam B; a split boundary decision).

### Seam C — Honest-order + membership/monotonicity (SW ~1895–4530, ~2640 lines — the largest)
- `wo`-driven slot ordering (1895); tie-class grouping (1955); meet-folded grouped disjunct builder
  (2095); anchor family keystone — distinct owners ⟹ distinct anchors (3296); honest value-rank order
  (3390); value_j→engine-point binding (3490); value-faithful monotonicity (3942); halign FOUNDATION
  bridge (3962); value-sorted merged slot lists (4057); region-assembly foundations (4179); merged
  slot-list `Nodup` (4242); **[333 R2]** soundness side-conditions over arbitrary `wo ∈ kvE2_sepArr'`
  (4318). This seam is oversized and could split into C1 (order construction) / C2 (halign +
  membership/Nodup foundations).

### Seam D — Coincidence-fold / discharge (SW ~4530–6527, ~2000 lines)
- Task-337 engine: strict base realizers (4530), per-owner per-zone `Nodup` (4581), joint engine
  inputs cross-owner value→gap partition (4597), global monotone bracket witness engine (5045),
  completeness reduction to single `.holds` (5274); O3 joint soundness extraction (5293),
  witness-count normalization / shared-`w` split (5408), structural navigation helpers — private
  plumbing (5447), 337 bracket point-type + segment match (5533), grouped/flat singleton compat
  (5630), `kvE2_sepHonest_hLR_absurd` certificate (5710 region), tie-REPORTING honest order + target
  completeness `kvE2_sepHonestOrder'` (5959), O3 extraction theorems (6364); **[BONEYARD CANDIDATE]**
  Phase 9 O4 carrier-side hgate derivation (6528) + **O4 CRUX RECORD "FAIL (inert; decision-gate
  input)"** (6698 — task-321 vintage, self-annotated "additive and inert", superseded by the live
  334/342 architecture per 335 plan 03 §).

### Seam E — Body / holds_iff / extract assembly (`kvE2_sepBody`, `kvE2_sepBody_extract`) (SW ~2314–2908 + ~6793–end, ~2200 lines split across the file)
- The joint carrier O1 `kvE2_sepBody` (2314); O1b non-vacuity (2392); task-334 Phase 8 Lemma 3.2(1) ⇐
  completeness (2909); task-334 faithful order-type disjunction spike + meet cuts + Lemma 3.2(1) ⇒
  soundness (6793/6888/6975/7057); task-342 honest non-interior evaluation pack (7088); σ-level &
  per-owner literal honesty families (7336/7521); 337 primed tie-reporting order bridge (7985); O2
  class point-type realization (8695); O3(a) honest segment eval (8963); O3(b) gap discharge (9127);
  O4 assembly + two public theorems (9250); **[333]** Phase 3 per-σ kit application (9649); **[333]**
  Phase 4 `kvE2_outer_fold` (9850). NOTE: `kvE2_sepBody` (def, 2314) and its `holds_iff`/`extract`
  theorems (6364, 8410) are **non-contiguous** — the assembly module will need careful extraction to
  avoid forward-reference breakage.

**Split feasibility note**: because the file is a single flat namespace with heavy
cross-banner dependencies (e.g. `kvE2_sepBody` at 2314 but its `extract` at 8410 and `outer_fold` at
9897), the module split is **not** a clean top-to-bottom cut. Recommend the plan phase build an actual
import/dependency DAG (via `lean_references` on the ~10 public anchors + `grep` of cross-symbol uses)
before choosing cut lines, to guarantee each new module compiles with only backward imports.

## Boneyard Archival Inventory (candidates — preserve-in-place if uncertain)

| Candidate | Location | Evidence it is dead/superseded | Action |
|---|---|---|---|
| Cross-σ bit-compatibility predicate | SW:899 banner | banner says "STAGED, not yet wired"; verify 0 live consumers via `lean_references` before moving | ARCHIVE if unreferenced; else NOTE: |
| O4 CRUX RECORD (FAIL, inert) | SW:6698–~6792 | self-annotated "additive and inert"; 335 plan 03 §

 calls it "task-321-vintage, superseded by the live 334/342 architecture" | ARCHIVE to Boneyard |
| Phase 9 O4 carrier-side hgate derivation | SW:6528 | precedes the CRUX RECORD; check whether any live theorem consumes it | verify then ARCHIVE or NOTE: |
| Deleted-symbol comment residue | `kvE2_sepArrL/R/Valid/Singleton` prose (9+2+17+0 mentions) | 0 live decls | REWRITE/DROP comments; do not propagate |
| 89 `md:NN` dangling citations | file-wide (`md:77`×27, `md:168`×24, `md:154`×9, `md:72`×8, `md:61`×6, `md:91`×3, `md:218`×3, `md:170`×3, singletons md:78/74/66/207/137/100) | markdown replaced 2026-07-09 by a PDF extract that drops displayed equations and inverts `k≠m`→`k=m`; anchors meaningless | RE-CITE to Rabinovich PDF pages **wherever a refactor touches the comment** (e.g. existing style `Rabinovich §5, p.7` at SW:6132); never silently propagate `md:NN` |

**Preservation rule (from the description, binding)**: anything still uncertain or potentially
load-bearing stays in place with `NOTE:`/`QUESTION:` comments — do NOT delete on suspicion. The 339
region-primary machinery and obsolete owner-block tuple remnants named in the description were not
positively located as distinct banners in this survey and must be pinpointed by `lean_references`
during the plan phase before any move.

## Citation Discipline (binding)

Cite Rabinovich by **PDF page only** (`p.N`), never `md:NN`. The codebase already uses the correct
style (`Rabinovich §5, p.7` at SW:6132; the mandated Lemma 3.2 form is in 335 plan 03 §"Citation
rule": Def 3.1 p.4 / k=m split p.7 / Def 7.5 p.13). The refactor MUST NOT copy `md:NN` comments into
new modules as if valid.

## Cross-Task Coordination

- **Hard sequencing (binding)**: 341 implementation MUST run **after 335 lands** and must NOT run
  concurrently with the H7 territory that assigns `SharedWitness.lean` to task 333 and
  `OuterGate.lean` to task 335. Task 333 is COMPLETE (its `SharedWitness.lean` edits are frozen), but
  **335 is still PLANNED/in-flight** and its Phase 4 may yet need a `SharedWitness.lean` re-shape if
  `hbdry`/`hexcl` do not discharge (see the 335 report). **Therefore `SharedWitness.lean` is NOT yet
  safe to move.** 341 must wait for 335 to reach [COMPLETED] and for `SharedWitness.lean` to be
  confirmed frozen.
- **Files 341 touches**: `SharedWitness.lean` (split into new sibling modules under
  `NfMultiAnchorBridge/`), the aggregator `NfMultiAnchorBridge.lean` (import sites), and
  `Theories/Bimodal/Boneyard/` (archival). Public API + all import sites must be preserved exactly;
  behavior and proved theorems unchanged (code-health pass, not semantic change).
- **Staleness risk for downstream 309**: 309's eventual v8 plan (see 309 report) will reference
  `NfMultiAnchorBridge/OuterGate.lean` symbols and possibly line numbers into `SharedWitness.lean`. If
  341 runs before 309's v8, the public API is preserved but line-number citations shift — 309's v8
  should cite symbol names, not line numbers, to survive the refactor.
- **Recommendation**: proceed to `/plan 341` for the module-split DESIGN (dependency DAG + cut lines +
  Boneyard list) now — a plan/design is safe pre-335 — but gate the `/implement 341` code-move phase
  on 335 [COMPLETED] + `SharedWitness.lean` frozen. The description's "survey/plan phase first"
  recommendation is well-founded given the non-contiguous `kvE2_sepBody` assembly.

## Open Questions / Risks

1. The `kvE2_sepBody` def (2314) / `extract` (8410) / `outer_fold` (9897) triple is non-contiguous;
   the assembly module boundary needs a real dependency DAG before cutting.
2. Exact location of the "339 region-primary machinery" and "obsolete owner-block tuple remnants"
   (description) not yet pinpointed — requires `lean_references` sweep in the plan phase.
3. `kvE2_sepPosI` (SW:211) sits physically in Seam A but logically in Seam B — split-boundary decision
   for the plan.
4. Whether 335 will force a `SharedWitness.lean` re-shape (335 Phase 4b risk) — if so, 341's frozen-
   file precondition slips further. Coordinate with 335 status before dispatching the code-move phase.
