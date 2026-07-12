# Task 341 — Research Findings (Angle A: Module Decomposition)

**Agent**: lean-research-agent (team research, Angle A)
**Session**: sess_1783841542_df767b
**Scope**: Read-only. Propose the *right* module boundaries for splitting
`NfMultiAnchorBridge/SharedWitness.lean`.
**Verification basis**: all line numbers measured against HEAD (`SharedWitness.lean` =
**12,800 lines**, 2026-07-12). The prior survey (`reports/01`, ~4,900 lines) and the draft plan
(`plans/01`, 10,037 lines) are both **stale**; this report re-verifies from scratch.

---

## 0. Headline

`SharedWitness.lean` is a **single flat namespace** (`Bimodal.Metalogic.WeakCanonical.Kamp`,
opened at `SharedWitness.lean:50`, closed at `:12800`) with **461 top-level declarations** and
**no `section`s and no `mutual` blocks** (verified: `grep -nE '^(namespace|section|end|mutual)'`
returns only the one namespace pair). Only **two imports**: `SubBracket2V`, `NavigatedSpine`
(`SharedWitness.lean:1-2`).

**The single most important structural fact**: because there are no `mutual` blocks, Lean 4
elaborates the file strictly top-to-bottom and **every declaration can only depend on
declarations above it**. The internal dependency graph is therefore a **linear tower** — *any*
horizontal cut, in source order, yields an **acyclic** import chain. This dissolves the draft
plan's biggest worry (Risk row: "`kvE2_sepBody` non-contiguity … forces forward references
across module boundaries", `plans/01:82`): under an order-preserving cut there are **no forward
references** by construction.

The corollary is the recommendation: **cut along the existing source order at cohesive
phase boundaries** (a hybrid by-responsibility / by-task-phase axis). Do **not** reorder
declarations to force responsibility-cohesion — reordering is the only way to reintroduce a
dependency cycle, and it also collides with the 85 file-scoped `private` decls (§5, R2).

---

## 1. Why the three candidate axes collapse to one

| Axis | Verdict | Evidence |
|------|---------|----------|
| **By k-layer / arity** (K0/K1/Kv) | **Does not apply internally.** `SharedWitness` is *entirely* one arity layer: the depth-2 (`E2`) separation witness. 56/56 dominant prefixes are `kvE2_sep*` (`grep` prefix histogram). The K1V/Kv/K0 layering already lives in *separate* files (`CarrierK1V.lean`, `CarrierKv.lean`, `SubBracket2V.lean`). There is no K-layer seam left inside this file. |
| **By consumer** | **Degenerate.** Only 4 files import `SharedWitness` (§4), and every one needs the **terminal** exports at the bottom of the tower (`kvE2_outer_fold_frag` @12665, `kvE2_sepBody_kit_sound_frag` @12580). Grouping by consumer selects "the whole tower". |
| **By responsibility / task-phase** | **The right axis.** The file grew by accretion across tasks 321→333→334→337→340→342→344; each task appended its phase, and each phase *is* a cohesive responsibility increment. Responsibilities appear in **contiguous source bands** (the doc-`/-!` headers, §2), so an order-preserving cut and a responsibility grouping **coincide**. |

The file's own top docstring names the responsibility phases explicitly: *"task 321 v7, Phase 7 =
O1 + O1b + O2"* (`SharedWitness.lean:4`); O1/O1b/O2/O3/O4 recur as section headers throughout.

---

## 2. Declaration-cluster map (verified line ranges)

Enumerated from the 65 `/-!` doc-section headers plus `====` task banners
(`grep -nE '^/-!|^-- =='`). Decl counts from
`grep -cE '^(theorem|lemma|def|abbrev|structure|inductive|noncomputable|private|@\[)'` over each
band.

| Band (lines) | Decls | Responsibility cluster | Key headers / anchors |
|--------------|-------|------------------------|-----------------------|
| 50–898 | 79 | **Slots & zone foundation** — outer/inner zone constants (Def 3.1), per-σ fold-bit reads (`kvE2_sepBits`/`sepProj`), positive-sub enumeration, tagged joint slots (Lemma 3.2(1)), per-individual-slot `Fin N` family (task 340 Ph3/6), interior-index transfer (task 342 Ph1) | `:64,:98,:146,:190,:248,:368,:414` |
| 899–2332 | 98 | **Gate + order/rank/tie kernel** — cross-σ bit-compat (staged), joint endpoint predicates + shared `ptW`, refined segment types (Cor 5.4), the depth-2 **gate** (`kvE2_sepGate` @1254), order-type disjunction index (task 334 Ph1-2), abstract lex-rank kernel (task 340 Ph5), tie-admitting validity (task 342 Ph6), `wo`-driven slot ordering, tie-class grouping, meet-folded disjunct builder | `:899,:1047,:1116,:1207,:1267,:1396,:1522,:1914,:1974,:2114` |
| 2333–3063 | 24 | **The carrier (O1) + non-vacuity (O1b)** — `kvE2_sepBody` def @2347, `kvE2_sepGate_holds_of_honest` @2797 | `:2333,:2411` |
| 3064–4116 | 42 | **Completeness ⇐ (honest anchor)** — `kvE2_sepBody_complete` @3363, F5 CLOSED-key discharges, anchor-family keystone (340 Ph5A), honest value-rank order (5B), value_j→engine binding (Ph6), value-faithful monotonicity (5C) | `:3064,:3247,:3451,:3545,:3645,:4097` |
| 4117–5447 | 64 | **Engine inputs (halign)** — task 337 Ph1 halign foundation, value-sorted merged slot lists, region assembly, merged `Nodup`, R2 soundness side-conditions, strict base realizers, joint engine inputs, 337 Ph2 global monotone bracket witness, completeness reduction (5D) | `:4117,:4212,:4334,:4397,:4473,:4685,:4752,:5200,:5429` |
| 5448–6957 | 51 | **Soundness extraction (O3)** — joint soundness extraction, witness-count normalization + shared-`w` split, structural nav helpers, bracket point-type + segment match, grouped/flat singleton compat, tie-REPORTING honest order, O3 extraction theorems, O4 crux FAIL record | `:5448,:5563,:5602,:5698,:5795,:6124,:6529,:6693,:6863` |
| 6958–8149 | 37 | **Disjunction spikes + literal honesty** — task 334 make-or-break spike, segment-meet cuts L/R, Lemma 3.2(1) ⇒ soundness, task 342 Ph8(b) non-interior eval pack, σ-level + per-owner literal-honesty families | `:6958,:7053,:7140,:7222,:7253,:7501,:7686` |
| 8150–9813 | 40 | **O2 realization + O4 assembly + PUBLIC THEOREMS** — primed tie-reporting bridge, O2 class point-type realization, O3(a) honest segment-eval, O3(b) gap discharge, **O4 assembly + the two public theorems** (`kvE2_complete_two_prior`), `kvE2_sepBody_holds_of_honest` @9800 | `:8150,:8860,:9128,:9292,:9415` |
| 9814–11515 | 17 | **Per-σ kit + outer fold + LEFT fragment fold** — task 333 per-σ kit (bundles→sound kit→owner nf_eval), outer depth-2 fold `kvE2_outer_fold` (R4), task 344 LEFT pin-anchored fragment fold (`kvE2_sepGateAtPin_fragL` @10605) | `:9814,:10015,:10202` (banner) |
| 11516–12800 | 10 | **RIGHT fragment fold (terminal exports)** — task 344 RIGHT pin-anchored gate producer + fold, `kvE2_sepBody_kit_sound_frag` @12580, `kvE2_outer_fold_frag` @12665 | `:11516` (banner) |

---

## 3. Proposed module boundary set (recommended)

Target: no file `>~2000` lines; `SharedWitness.lean` reduced to a **thin re-export hub**. All
new modules under `NfMultiAnchorBridge/SharedWitness/`, reopening the same namespace + `open`s
(`SharedWitness.lean:50-54`).

| # | New module | Lines (band) | ~LOC | Decls | Imports |
|---|-----------|--------------|------|-------|---------|
| A | `Slots.lean` | 50–898 | 849 | 79 | `SubBracket2V`, `NavigatedSpine` |
| B | `OrderGate.lean` | 899–2332 | 1434 | 98 | `Slots` |
| C | `Carrier.lean` | 2333–3063 | 731 | 24 | `OrderGate` |
| D | `Completeness.lean` | 3064–4116 | 1053 | 42 | `Carrier` |
| E | `EngineInputs.lean` | 4117–5447 | 1331 | 64 | `Completeness` |
| F | `Soundness.lean` | 5448–6957 | 1510 | 51 | `EngineInputs` |
| G | `DisjunctionSpikes.lean` | 6958–8149 | 1192 | 37 | `Soundness` |
| H | `Assembly.lean` | 8150–9813 | 1664 | 40 | `DisjunctionSpikes` |
| I | `KitFold.lean` | 9814–11515 | 1702 | 17 | `Assembly` |
| J | `FragmentFoldRight.lean` | 11516–12800 | 1285 | 10 | `KitFold` |
| — | `SharedWitness.lean` (**hub**) | — | ~30 | 0 | `FragmentFoldRight` (transitively all) |

**10 content modules + hub.** Largest = `KitFold` at ~1702 LOC (under the 2000 cap). Every band
boundary lands on a `/-!` header or a `====` task banner — no cut splits a declaration.

Notes:
- **B (`OrderGate`)** merges the small gate/segment band (899–1266, 368 LOC) with the order/rank
  band (1267–2332). If a finer split is preferred, cut B at line 1267 into `GateSegments.lean`
  (368 LOC) + `OrderRank.lean` (1066 LOC) — 11 content modules. Both are acyclic; the merge is
  the recommended default (fewer files, still cohesive: gate feeds the carrier via order/rank).
- **I/J** is the mandatory split of the task-344 tail (9814–12800 = 2986 LOC, over cap). The
  natural seam is the `====` banner at `:11516` (LEFT fold vs. RIGHT fold). The task-333 kit
  (9814–10201, only 4 decls / 388 LOC) is too small to stand alone and is folded into `KitFold`
  with the LEFT fragment fold (both are "fold" responsibilities).

---

## 4. Import DAG (verified acyclic)

Internal chain is strictly linear (a total order), so trivially acyclic:

```
SubBracket2V ─┐
NavigatedSpine┴─▶ Slots ─▶ OrderGate ─▶ Carrier ─▶ Completeness ─▶ EngineInputs
                 ─▶ Soundness ─▶ DisjunctionSpikes ─▶ Assembly ─▶ KitFold
                 ─▶ FragmentFoldRight ─▶ SharedWitness (hub)
```

**External importers of `SharedWitness` (whole-repo `grep`)** — 4 files, all preserved by the hub:

| Importer | Location | Frozen? |
|----------|----------|---------|
| `NfMultiAnchorBridge.lean` (aggregator) | `Kamp/NfMultiAnchorBridge.lean:38` | no |
| `OuterGate.lean` | in-dir consumer | **YES** (task 349 frozen provider) |
| `ExteriorZoneTriage.lean` | in-dir consumer | in task-349 frozen list |
| `ExteriorNegation.lean` | `Kamp/ExteriorNegation.lean` | **YES** (task 349 frozen provider) |

Because Lean re-exports imported declarations **transitively**, importing the hub makes the full
public surface available; **none of these 4 files needs editing**. The public surface actually
consumed by `OuterGate`/`ExteriorZoneTriage` (`grep kvE2_*`): zone constants
(`kvE2_sep_zPastX3/zXW3/zWT3/zFutT3`), `kvE2_sepPos`/`kvE2_sepPosI(+_mem/_zone)`, `kvE2_sepPtW`,
`kvE2_sepGate(+_holds_of_honest)`, `kvE2_sepBody(+_complete/_holds_of_honest/_kit_sound_frag)`,
`kvE2_sepGateAtPin_fragL`, `kvE2_outer_fold_frag`, `kvE2_sepHonest_hLR_absurd`. All of these are
`public` (non-`private`) and land in modules A–J; the hub re-exports each.

`SharedWitness` is **sorry-free** (the 5 `\bsorry\b` matches are all "sorry-free"/"Sorry-free"
inside doc comments; no live `sorry`, no `axiom`).

---

## 5. Risks

**R1 — Frozen importers make the re-export hub mandatory, not optional (H).** Two of the four
importers (`OuterGate.lean`, `ExteriorNegation.lean`) are task-349 **frozen provider files** that
**cannot be edited**. The split must keep `import …NfMultiAnchorBridge.SharedWitness` resolving to
a file that transitively re-exports **every** currently-exported symbol. Mitigation: hub imports
`FragmentFoldRight` (bottom of tower ⇒ all names). Acceptance gate: `lake build` of all 4
importers + axiom audit `{propext, Classical.choice, Quot.sound}` unchanged.

**R2 — 85 `private` declarations are file-scoped and are THE cut hazard (H, most important).**
`grep -cE '^\s*private '` = 85. In Lean 4 a `private` decl in module X is **invisible** in module
Y even when Y imports X. Any private used across a proposed cut boundary breaks compilation.
Highest-risk are the **generic utility privates** (pure `{α : Type*}` list/order helpers, reuse-
prone across phases): `kvE2_sep_flatMap_filter_of_vanish` (:480), `kvE2_pairwise_of_forall`
(:738), `kvE2_sep_flatten_map_singleton` (:2173), `kvE2_sep_pairwise_of_forall`/`_flatMap`
(:2421/:2428), `kvE2_sepChain_lt_between` (:4930), `kvE2_sepForall₂_*` (:5294/:5310),
`kvE2_sep_getElem_{mid,left,right}` (:5605/:5612/:5619), `kvE2_sep_eq_map_singleton` (:5927),
`kvE2_sep_flatMap_sublist` (:5957), `kvE2_sep_{take,drop}_flatten_*` (:9306/:9321/:9450/:9474),
`kvE2_sep_usOf_*` (:9428-:9442), `kvE2_nodup_filter_unique` (:10230). Mitigation (implementation-
time, before each move): grep each private's *last* reference; if it lies in a later module,
either (a) drop `private` (make it namespace-scoped) or (b) hoist the generic helpers into a
`SharedWitness/Util.lean` imported by `Slots`. **Recommend a dedicated Phase-1 private cross-
reference audit** (`lean_references` on each of the 85, or a `grep` last-use scan) before any code
moves. Most locally-named privates (e.g. the per-zone `kvE2_sepOwnerLit_*` at :7725-:7922) are
used within their own band and are safe.

**R3 — `kvE2_sepBody` non-contiguity is DISSOLVED, not mitigated (was H, now L).** The draft
plan's central risk (def @2347, consumers in the O2/O3/O4/fold bands) only bites under
responsibility-*regrouping*. Under the order-preserving cut, `kvE2_sepBody`'s def sits in
`Carrier` (module C) and every consumer is in D–J, all of which import C. No forward reference.

**R4 — Task coordination / anchor drift (M).** Tasks 335/344 already landed content into
`SharedWitness` (banners at :10202, :11516); task 349 is `[RESEARCHING]` and treats
`SharedWitness` as a frozen provider it must not touch. The split must wait until the file is
confirmed frozen (335 `[COMPLETED]`, per `plans/01:42`), and design artifacts should cite
**symbols, not line numbers** — all line anchors here are HEAD-relative and will drift on any
further content landing. Re-diff at implementation GATE.

**R5 — Header replication (L, mechanical).** Every new module must reopen `namespace
Bimodal.Metalogic.WeakCanonical.Kamp` and replicate the three `open`s (`open Bimodal.Syntax`,
`…WeakCanonical`, `…WeakCanonical.Separation`, `:52-54`) or unqualified names fail to resolve.
`@[simp]`/`instance` decls register globally regardless of module, so simp-set behavior is
preserved.

---

## 6. Confidence + open questions

**Confidence: High** on the axis choice and the acyclicity guarantee (both follow mechanically
from "one namespace, zero `mutual`, zero `section`", directly verified). **High** on the band
boundaries and sizes (measured at HEAD). **Medium** on the exact `private` resolution cost —
bounded above by 85 decls but the true cross-boundary count needs the R2 audit.

**Open questions for synthesis / planning:**
1. **Private audit not yet run.** How many of the 85 privates actually cross a proposed boundary?
   This sets the real edit cost and may justify a `SharedWitness/Util.lean` (module A-minus-one).
   Recommend running `lean_references` on the ~18 generic-utility privates listed in R2 first.
2. **B split granularity** — 10-module (merge gate+order) vs. 11-module (`GateSegments` +
   `OrderRank`). Both valid; a cohesion-vs-file-count trade-off for the planner.
3. **Boneyard / dead code** — the draft plan (`plans/01:25,164`) references archiving dead decls
   to `Boneyard/`; the O4 crux is marked **FAIL/inert** (`:6863`, `:6958` "MAKE-OR-BREAK SPIKE").
   Whether any FAIL-marked bands are dead (removable) vs. load-bearing is out of Angle A's scope —
   flag for a dedicated dead-code angle (likely Angle B/C).
4. **Hub-file-beside-directory** Lake layout (`SharedWitness.lean` coexisting with
   `SharedWitness/`) is the idiomatic Mathlib pattern; low risk but verify with `lake build` on
   the first extracted module.
