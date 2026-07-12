# Research Report (Team Angle C): Task 341 — Refactor Mechanics & endChar Forward-Compatibility

- **Task**: 341 — structural_refactor_sharedwitness_carrier_layer
- **Angle**: C — Lean-safe split mechanics + phase sequencing + endChar "don't-refactor-twice" forward-compat + green-preservation
- **Session**: sess_1783841542_df767b
- **Type**: lean4 (read-only research; NO source edited)
- **Date**: 2026-07-12
- **Inputs read**: 341 reports 01/02, 341 plan 01; 349 report 04 (arity-4 bridge NON-THEOREM audit); live import/grep of `NfMultiAnchorBridge/`

---

## Executive Summary (read first)

**The 341 SharedWitness split and the 349 endChar Rabinovich rebuild operate on DISJOINT files.**
This is the single most important forward-compat fact, and it is verified mechanically:

- The endChar recursion (`NavigatedEndChar.lean`) imports only `Base`, `Lemma32Reduction`, `CarrierKv`
  and references **zero** `kvE2_sep*` symbols (`grep -c kvE2_sep NavigatedEndChar.lean = 0`;
  same for `Lemma32Reduction.lean` and `Base.lean`).
- The carrier declarations the faithful (Prop-valued-over-≤2-anchors) endChar consumes —
  `nf_zone_flatten_navigable`/`_correct` (Base.lean:667/687), `nfEval_pair_arity3_flatten`/`_interior`
  (Lemma32Reduction.lean:318/344), `nfEval_le2_reduction` (Lemma32Reduction.lean:535), and the
  interface being revised, `nf_char3_endpoint_tl`/`_correct` (Base.lean:869/885) — all live in
  **Base.lean and Lemma32Reduction.lean**, which **341 does not touch** (341 splits only
  `SharedWitness.lean`).
- Conversely, `SharedWitness.lean` imports only `SubBracket2V` (FROZEN) and `NavigatedSpine`, and is
  consumed only by `OuterGate.lean` and `ExteriorZoneTriage.lean`.

**Consequence**: 341 can proceed on `SharedWitness.lean` without anticipating any *relocation* forced
by 349's endChar rebuild — those carrier assets are already isolated in Base/Lemma32Reduction, not in
the file 341 is splitting. The "don't refactor twice" risk reduces to a **single** open question that
report 05 must close (see §3): whether the faithful endChar will begin consuming the
`kvE2_sep*` arity-2 V-carrier family (currently 0 uses). If report 05 confirms it will NOT (expected,
per report 04 §5.2 which points endChar at the `Base.lean` merge, not the SharedWitness carrier), the
two refactors are fully independent and can even run concurrently subject to the freeze gate.

Two mechanical caveats: (1) the existing plan's per-phase sizes (1480/2640/2000/2200 lines)
**violate a ≤500-line hard-mode phase budget** and must be sub-split; §2 gives a concrete ≤500-line
phase list. (2) Both refactors edit files in the **same directory** — no import cycle is possible
given the DAG, but the freeze/territory discipline in §4 must be honored.

---

## 1. Lean-safe split mechanics (each step independently green-buildable)

### 1.1 The header context every extracted module must carry (verified)

`SharedWitness.lean` is a single flat namespace with **no `section`, no `variable`, no `set_option`**
at file scope (`grep -nE '^(namespace|section|open|variable|set_option)' SharedWitness.lean`):

```
line 50:  namespace Bimodal.Metalogic.WeakCanonical.Kamp
line 52:  open Bimodal.Syntax
line 53:  open Bimodal.Metalogic.WeakCanonical
line 54:  open Bimodal.Metalogic.WeakCanonical.Separation
line 12800: end Bimodal.Metalogic.WeakCanonical.Kamp
```

(The `variables`/`open-` hits at 1525/3073/6972 are inside comment prose, not directives.)

**Mechanical rule**: every new `SharedWitness/<Module>.lean` opens with exactly:

```lean
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.<its backward deps>
namespace Bimodal.Metalogic.WeakCanonical.Kamp
open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
-- moved decls verbatim
end Bimodal.Metalogic.WeakCanonical.Kamp
```

Because there are no `variable`/`section` bindings to thread, the notorious "universe/section
capture" refactor hazard is **absent here** — decls are self-contained w.r.t. binder context. This is
a materially safer split than the general case; the only elaboration inputs are the three `open`s
(carry all three into every module) and the imports.

### 1.2 File+directory coexistence and the re-export hub (mechanically sound)

Lake supports `SharedWitness.lean` sitting *beside* a `SharedWitness/` directory: module
`…NfMultiAnchorBridge.SharedWitness` resolves to the `.lean` file, and
`…NfMultiAnchorBridge.SharedWitness.Slots` resolves to `SharedWitness/Slots.lean`. Lean 4 imports are
**transitive/public**: a downstream file that does `import …NfMultiAnchorBridge.SharedWitness` sees
every declaration re-exported through the hub. Therefore `OuterGate.lean` and `ExteriorZoneTriage.lean`
(the only two importers of `SharedWitness`) need **no edit** — the plan's re-export-hub strategy
(plan §"Target Module Split") is correct. Verified importer set:
`grep -rl 'import .*NfMultiAnchorBridge.SharedWitness' → OuterGate.lean, ExteriorZoneTriage.lean`.

### 1.3 Import ordering / cycle-freedom (backward-only is forced, not merely chosen)

`SharedWitness.lean` imports only two siblings: `SubBracket2V` (FROZEN) and `NavigatedSpine`
(`grep -nE '^import' SharedWitness.lean`). Every new `SharedWitness/*` module may import:

- `SubBracket2V`, `NavigatedSpine` (SharedWitness's own upstream), and
- any **earlier-extracted** `SharedWitness/*` sibling.

A cycle is impossible **by construction** if extraction proceeds in dependency (topological) order,
because a sub-module can never import the hub (the hub imports *it*). The one hard invariant an
implementer must not violate: **never make a `SharedWitness/*` module import
`…SharedWitness` (the hub), `OuterGate`, or `ExteriorZoneTriage`** — that would close a cycle.

### 1.4 The verbatim-move discipline that keeps each step green

- Move a **downward-closed prefix** of the dependency order into the new module (i.e. the block plus
  everything it depends on that is not already in `SubBracket2V`/`NavigatedSpine`/an earlier module).
- Add `import …SharedWitness.<NewModule>` at the **top** of the hub. Because Lean imports are
  file-global, the decls remaining in the hub still see the moved decls — so the extraction never
  breaks a *downstream* reference inside the hub, only an *upstream* one, which the topological order
  prevents.
- Move text **byte-for-byte** (no reflow, no rename) so elaboration is identical; the only new tokens
  are the module's header (§1.1) and the hub's new `import` line.
- The `kvE2_sepBody` non-contiguity hazard (def SW:2314, `extract` SW:8410, `outer_fold` SW:9897 —
  341 report 01 §"Split feasibility") is the one place a naive line-order cut fails; the def must be
  extracted with (or before) its consumers per the Phase-1 DAG, exactly as plan Phase 1 mandates.

---

## 2. Phase sequencing for a hard-mode plan (≤500-line, one-agent-run, each ending green)

**The existing plan's phases exceed a ≤500-line hard-mode budget.** Measured seam sizes
(341 report 01) are A≈410, B≈1480, C≈2640, D≈2000, E≈2200. Only Seam A fits in one ≤500 chunk. The
hard-mode ask ("≤500-line phases, each one agent-run, each ending green") requires sub-splitting
B–E at banner boundaries. The plan already *authorizes* sub-splits (plan Phases 6–8 "sub-split at a
banner boundary if overflow"); hard mode makes them **mandatory and pre-declared**, not contingent.

### 2.1 Ordering principle: leaf-first (extract the most-upstream decls first)

Extract in **dependency-topological order = the plan's A→B→C→D→E order**, because each module may
only import earlier ones (§1.3). Within each seam, sub-split so every chunk is itself downward-closed:
extract the sub-chunk that depends only on already-extracted material first. This "leaf-first,
extract-then-reexport" order minimizes risk: at every commit the hub still compiles because it
re-imports what it lost, and the new module compiles because it imports only backward.

### 2.2 Proposed ≤500-line phase list (banner-anchored; exact cut lines are Phase-1's deliverable)

Design phases (read-only, safe pre-freeze), then the GATE, then extractions in ≤500-line chunks:

| Phase | Content | Est. lines moved | Imports (backward) |
|---|---|---|---|
| P1 | Dependency DAG + cut-line spec (read-only) | 0 | — |
| P2 | Boneyard inventory + `md:NN` citation register (read-only) | 0 | — |
| P3 | **GATE**: 348 [COMPLETED] + file frozen + baseline green/axiom-clean | 0 | — |
| P4 | Seam A → `Slots.lean` | ~410 | SubBracket2V, NavigatedSpine |
| P5 | Seam B-1 → `OrdRank.lean` (`kvE2_sepPosI`, `kvE2_sepGate`, endpoint preds) | ~500 | Slots |
| P6 | Seam B-2 → `OrdRankKernel.lean` (`kvE2_ordRank`, `kvE2_sepDisjValidOwner`) | ~480 | OrdRank |
| P7 | Seam C-1 → `HonestOrder.lean` (wo-ordering, tie-class grouping) | ~500 | OrdRankKernel |
| P8 | Seam C-2 → `AnchorFamily.lean` (distinct-owner keystone, value-rank order) | ~500 | HonestOrder |
| P9 | Seam C-3 → `HalignFoundation.lean` (halign bridge, merged-slot `Nodup`, `kvE2_sepArr'` side-conds) | ~500 | AnchorFamily |
| P10 | Seam D-1 → `CoincidenceEngine.lean` (task-337 bracket engine, base realizers) | ~500 | HalignFoundation |
| P11 | Seam D-2 → `HonestOrderPrimed.lean` (`kvE2_sepHonest_hLR_absurd`, `kvE2_sepHonestOrder'`, `kvE2_sepSlotLe`, O3 extraction) | ~500 | CoincidenceEngine |
| P12 | Seam E-1 → `BodyCore.lean` (`kvE2_sepBody` def + O1/O1b non-vacuity) | ~500 | HalignFoundation (or per DAG) |
| P13 | Seam E-2 → `BodyExtract.lean` (`kvE2_sepBody_extract`, holds_iff, honesty families) | ~500 | HonestOrderPrimed, BodyCore |
| P14 | Seam E-3 → `BodyAssembly.lean` (O2/O3/O4 assembly, `kvE2_outer_fold`, two public theorems) | ~500 | BodyExtract |
| P15 | Reduce `SharedWitness.lean` to re-export hub (imports only; no decls) | ~30 hub | all above |
| P16 | Boneyard archival (0-consumer code only) | (removals) | — |
| P17 | API/doc pass + `md:NN` re-citation on touched comments | (comment edits) | — |
| P18 | Final verification (clean build, axiom profile, LITMUS, F1–F7) | 0 | — |

Notes:
- Exact chunk boundaries and the `kvE2_sepBody` def placement (P12 vs earlier) are the DAG's call
  (plan Phase 1); the table's line estimates are provisional and must be re-measured at the GATE
  against the frozen 12,800-line file (341 report 02 Finding 3: the file grew +27% and gained an
  un-mapped SW:10210–12800 `_frag`/exterior region — a **sixth seam** the plan's five-seam map never
  covered; hard-mode phasing must add ~3–5 more ≤500 chunks for it).
- Each extraction phase ends with a scoped `lake build …SharedWitness.<Module>` then a full
  `lake build`, and a green commit (`task 341 phase N.O: extract <Module>`), per the
  commit-per-green-substep mandate.
- **Reordering safety**: because the order is strictly topological and each phase is verbatim, any
  phase that fails to land green can be reverted in isolation (`git revert`) without disturbing
  earlier extractions (plan §Rollback).

---

## 3. endChar forward-compatibility — "don't refactor twice" (CRITICAL)

### 3.1 What the faithful endChar consumes, and where it lives (verified)

Report 04 (349) is decisive: the arity-4 single-point-`Formula` bridge is a machine-checked
**NON-THEOREM** (parameter-independence, generalizing `endCharN0_correct_infeasible`, Base.lean:1779).
The faithful fix (report 04 §5.2) keeps the inner converter **Prop-valued over its two enclosing
anchors** and collapses to a `Formula` only at ≤1 free anchor. The carrier declarations that faithful
architecture consumes are enumerated in report 04's Reference-Grounding table, and I confirmed each
lives **outside** `SharedWitness.lean`:

| Faithful-endChar asset | Location | In 341 scope? |
|---|---|---|
| `nf_zone_flatten_navigable` / `_correct` (the ≤2-free Prop merge) | **Base.lean:667 / 687** | NO — 341 splits only SharedWitness |
| `nfEval_pair_arity3_flatten` / `_interior` (fixed explicit pair) | **Lemma32Reduction.lean:318 / 344** | NO (Lemma32Reduction FROZEN per 349) |
| `nfEval_le2_reduction` (Lem 3.2(2) ≤2-anchor reduction) | **Lemma32Reduction.lean:535** | NO |
| `nf_char3_endpoint_tl` / `_correct` (defective interface being revised) | **Base.lean:869 / 885** | NO — revised by 349 in Base.lean |
| endChar recursion driver | **NavigatedEndChar.lean** | NO |

### 3.2 The disjointness proof (mechanical)

- `grep -c kvE2_sep {NavigatedEndChar,Lemma32Reduction,Base}.lean` = **0, 0, 0** → the endChar line
  consumes **nothing** from the SharedWitness `kvE2_sep*` carrier family.
- `NavigatedEndChar.lean` imports = `Base`, `Lemma32Reduction`, `CarrierKv` → it does **not** import
  `SharedWitness`, `OuterGate`, or `ExteriorZoneTriage`.
- `SharedWitness.lean` imports = `SubBracket2V`, `NavigatedSpine` → it does **not** import any endChar
  file; `NavigatedEndChar` is imported by nothing (a leaf endpoint under construction).

Therefore the two refactors touch **disjoint files** and cannot force each other to re-refactor,
**provided §3.4's one condition holds**.

### 3.3 Answer to "should the consumed decls live in a dedicated module?"

They **already do** — `Base.lean` (the arity-3 primitive + `nf_zone_flatten_navigable` merge) and
`Lemma32Reduction.lean` (the ≤2-anchor reduction) are exactly the dedicated homes. 341 must therefore
**NOT** attempt to pull these into any `SharedWitness/*` module (it structurally cannot — they are not
in `SharedWitness.lean`), and the new module layout needs **no dedicated "endChar-carrier" module**
because that role is filled by Base/Lemma32Reduction, which 341 leaves untouched. The forward-compat
action for 341 is *inaction*: preserve Base/Lemma32Reduction imports exactly (the hub already does),
and do not relocate `CarrierKv`/`CarrierK1V` (also out of 341 scope, also consumed by endChar).

### 3.4 The ONE residual coupling report 05 must close

The `kvE2_sep*` family is itself a **depth-2 / ≤2-anchor separated carrier** ("kvE2" ≈ arity-2
evaluation). Report 04 §5.2 says the faithful merge is `nf_zone_flatten_navigable` (Base), **not** the
SharedWitness carrier — but report 04 is a 349-side audit and does not *bind* the SharedWitness carrier
out of the future endChar. If report 05 (the Rabinovich faithful architecture, in progress) were to
re-point the ≤2-anchor Prop merge at the `kvE2_sep*` V-carrier instead of `nf_zone_flatten_navigable`,
then endChar would begin importing `SharedWitness` and the 341 module boundaries would become
load-bearing for 349 — the "refactor twice" hazard. Current evidence says this will **not** happen
(0 references today; report 04 explicitly routes endChar through Base's merge), but it is the single
fact that must be confirmed, not assumed.

### 3.5 "What report 05 must confirm before 341 implementation starts" — checklist

1. **[Disjointness]** Confirm the faithful endChar's ≤2-anchor Prop merge is
   `nf_zone_flatten_navigable(_correct)` (Base.lean:667/687) and/or `nfEval_pair_arity3_*`
   (Lemma32Reduction.lean:318/344) — and **NOT** the `kvE2_sep*` SharedWitness V-carrier. If it will
   consume `kvE2_sep*`, name exactly which symbols, so 341 can co-locate them in one dedicated
   `SharedWitness/` module (a `Prop-valued ≤2-anchor merge` module) rather than scattering them across
   Seam C/D/E.
2. **[No new SharedWitness decl]** Confirm the endChar rebuild adds its new carrier declarations to
   **Base.lean / Lemma32Reduction.lean / NavigatedEndChar.lean** (or a new endChar-side file), **not**
   to `SharedWitness.lean`. If any new decl is destined for SharedWitness, 341 must sequence *after*
   it lands (extends the freeze gate).
3. **[Interface home]** Confirm the revised `nf_char3_endpoint_tl` interface (report 04 §5.1) stays in
   **Base.lean**. If the revision relocates it into the NfMultiAnchorBridge directory as a new file,
   confirm that file will not import `SharedWitness` (no cycle) and is outside 341's edit set.
4. **[CarrierKv stability]** Confirm the endChar rebuild does not force a re-shape of `CarrierKv`/
   `CarrierK1V` that would in turn pull in SharedWitness decls (today CarrierKv←CarrierK1V←Base only;
   no SharedWitness edge).
5. **[Freeze-gate timing]** Confirm whether 349's endChar work writes to `SharedWitness.lean` at all.
   If **no** (expected), 341 and 349 may run concurrently subject to §4's territory rule. If **yes**,
   341's Phase-3 GATE precondition must add "349 endChar SharedWitness edits complete + frozen"
   alongside the existing "348 [COMPLETED] + frozen" (341 report 02 Finding 5).

If items 1–2 confirm disjointness (the expected outcome), **341 needs no module-layout change to
accommodate 349** — the split proceeds exactly as the (re-sized) plan in §2 describes.

---

## 4. Green-preservation checks (no-regression verification)

### 4.1 Axiom profile

- Baseline (341 report 01, plan §Overview): the carrier theorems are axiom-clean
  `{propext, Classical.choice, Quot.sound}` and sorry-free (the 7 `sorry`/`admit` string hits in
  `SharedWitness.lean` are all in prose comments — 341 report 01 §Exec Summary).
- After **every** extraction phase, run `lean_verify` (fully-qualified name) on that module's public
  anchors and assert the axiom set is **exactly** `{propext, Classical.choice, Quot.sound}` — a
  verbatim move must not change it. Key anchors to check: `kvE2_sepArr'`, `kvE2_sepBody`,
  `kvE2_sepBody_extract`, `kvE2_sepHonestOrder'`, and the two public Body theorems.
- **Do NOT** trust `grep -c 'sorry'` alone (it counts comment prose); use `lean_verify`'s axiom+source
  scan for the authoritative sorry/axiom check. (`lean_diagnostic_messages` and `lean_file_outline`
  are BLOCKED — use `lean_goal` + `lake build` + `lean_verify`.)

### 4.2 Scoped-then-full build

- Per phase: `lake build Bimodal.…NfMultiAnchorBridge.SharedWitness.<Module>` (fast, scoped), then
  `lake build` (full — proves the hub re-export and downstream `OuterGate`/`ExteriorZoneTriage`/
  aggregator still compile). Green + committed before the next phase (commit-per-green-substep
  mandate, git-workflow rule).
- Final phase: `lake clean && lake build` from clean if budget allows (plan Phase 11/our P18).

### 4.3 LITMUS + F1–F7

- **LITMUS anchor is `bracketEndChar_kvE2` in `NavigatedSpine.lean` (~:437)**, not in SharedWitness —
  verified: the "No `x1 < e_i` relative-position literal" LITMUS text sits at NavigatedSpine.lean:437,
  discussing the `bracketEndChar_kvE2` carrier. Since 341 does **not** edit `NavigatedSpine.lean`, the
  LITMUS is preserved by non-modification; P18 confirms it is byte-unchanged.
- F1–F7 faithfulness invariants are properties of statements/proofs that 341 relocates verbatim; the
  no-semantic-change invariant (plan Non-Goals) preserves them by construction. P18 diffs public API
  import-equivalence against the frozen baseline.

### 4.4 Regression tripwires specific to the split

- **Import-equivalence check**: after P15 (hub reduction), assert the set of names re-exported by
  `…SharedWitness` equals the frozen baseline (e.g. compile a throwaway `example` referencing each of
  the ~10 public anchors through the hub, or diff `#print axioms`/`#check` output). This catches an
  accidentally-dropped decl.
- **Downstream-unchanged check**: `git diff` must show `OuterGate.lean`, `ExteriorZoneTriage.lean`,
  and the aggregator `NfMultiAnchorBridge.lean` **untouched** (re-export means zero downstream edits;
  any edit there is a red flag that import-preservation failed).

---

## 5. Confidence + Open Questions

**Confidence: HIGH** on the central forward-compat finding (endChar/SharedWitness disjointness). It
rests on directly-verified import lists and `grep -c kvE2_sep = 0` on all three endChar files, plus
report 04's explicit routing of faithful endChar through Base's `nf_zone_flatten_navigable`. It does
not depend on any unsearched or "likely" claim.

**Confidence: MEDIUM** on the exact ≤500-line phase boundaries in §2.2 — the line estimates are from
the pre-freeze 10,037-line survey; the file is now 12,800 lines with an un-mapped SW:10210–12800
region (341 report 02 Finding 3). Boundaries **must** be re-measured at the GATE against the frozen
file (a Phase-1/GATE deliverable, not something to fix pre-freeze).

**Open questions (for report 05 / synthesis):**

1. **[Blocking-ish]** Report 05 must confirm §3.5 items 1–2 (endChar does not consume/write
   `kvE2_sep*` / `SharedWitness.lean`). Expected disjoint, but must be stated, not assumed. This is
   the one thing that could turn "independent refactors" into "refactor twice."
2. Does 348 (still `[IMPLEMENTING]`, appending to SharedWitness below SW:10210) actually complete and
   freeze before 341's GATE? 341's freeze precondition is "348 [COMPLETED] + frozen" (341 report 02
   Finding 5), superseding the plan-body's stale "335" wording.
3. The sixth seam (SW:10210–12800 `_frag`/pin-anchored/exterior cluster, 341 report 02 Finding 3)
   needs its own ≤500-line sub-phases; Angle A's module decomposition should assign it, and it must
   cite the **revised Prop 4.3** exterior treatment (347/348), never the retired prop43-successor
   framing (341 report 02 Finding 4).
4. Concurrency: if §3.5 item 5 confirms 349 never writes SharedWitness, can 341 and 349 run in
   parallel? DAG says yes (disjoint files, no cycle), but the directory-level territory contract (§4)
   and the freeze gate should still serialize any *SharedWitness-touching* work.

---

## Verification Trail

- `wc -l` NfMultiAnchorBridge/*.lean: SharedWitness=12,800; Base=1,982; Lemma32Reduction=549;
  CarrierKv=482; CarrierK1V=2,097; NavigatedEndChar=246; SubBracket2V=2,160.
- Imports: `NavigatedEndChar` ← {Base, Lemma32Reduction, CarrierKv}; `Lemma32Reduction` ← {Base};
  `CarrierKv` ← {CarrierK1V}; `CarrierK1V` ← {Base}; `SharedWitness` ← {SubBracket2V, NavigatedSpine}.
- `grep -c kvE2_sep` = 0 in each of NavigatedEndChar.lean, Lemma32Reduction.lean, Base.lean.
- Importers of SharedWitness = {OuterGate.lean, ExteriorZoneTriage.lean}; importers of NavigatedEndChar
  = {} (leaf).
- Faithful-endChar assets located: Base.lean:667/687/869/885; Lemma32Reduction.lean:318/344/535.
- SharedWitness header: namespace @50, three `open` @52-54, single `end` @12800; no `section`/
  `variable`/`set_option` at file scope.
- LITMUS text at NavigatedSpine.lean:437 references `bracketEndChar_kvE2` (not a SharedWitness symbol).
- endChar HEAD commit for NavigatedEndChar: `077c2e9ca task 349 phase 3.b: navPiece_reduce … + 3b deferral`.
