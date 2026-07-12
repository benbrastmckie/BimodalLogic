# Research Report: Task 341 — Angle B: Public API Surface of the Carrier Layer

- **Task**: 341 — structural_refactor_sharedwitness_carrier_layer
- **Angle**: B — design the clean PUBLIC API (expose vs. hide) of the carrier layer
- **Type**: lean4 (read-only research; no source edited)
- **Date**: 2026-07-12
- **Session**: sess_1783841542_df767b
- **Measured HEAD**: `775b89db7`; `SharedWitness.lean` = 12,800 lines; `NfMultiAnchorBridge/` = 24,509 lines / 15 files
- **Prior artifacts read**: `plans/01_module-split-design.md`, `reports/01_sharedwitness-declaration-survey.md`, `reports/02_post-kamp-revision-realignment.md`

## Executive Summary

**The carrier layer's real public API is tiny; its declared public surface is enormous.**
`SharedWitness.lean` declares **377 non-`private` top-level symbols**, but only **31 of them (8%)
are ever referenced from another file**. The remaining **346 public declarations (92%) are internal
scaffolding that leaked to public** — they are heavily used *within* `SharedWitness.lean` and never
outside it. The single highest-value API action for task 341 is therefore **not** renaming or
re-exporting: it is **privatizing (or module-local-scoping) the 346 leaked symbols** as the split
relocates them, so each new module exposes only its pinned entry points.

Critically, the prior survey's "top 10 anchors" (`reports/01`, table at lines 27–39) measured
*internal reference count*, which is the **wrong metric for public API**: 5 of those 10 anchors
(`kvE2_sepArr'`, `kvE2_sepHonestOrder'`, `kvE2_ordRank`, `kvE2_sepSlotLe`,
`kvE2_sepDisjValidOwner`) have **zero external consumers project-wide** despite 12–135 internal
uses. They are the *largest* pieces of internal scaffolding, not public API. This report re-bases
the API design on **cross-file consumption**, the correct metric.

A hard constraint shapes what 341 may *rename*: **every one of the 31 public SharedWitness symbols
is pinned by a FROZEN consumer** (task 349 freezes `OuterGate`, `ExteriorBracket`,
`ExteriorZoneTriage`, `ExteriorNegation`, `ExteriorNegationPast`). Because the frozen files cannot
be edited to follow a rename, **the 31 public names cannot be renamed in task 341** — only
documented and re-grouped. Renames are proposals for a future task that runs after the exterior
files thaw. Privatizing the 346 non-consumed symbols is fully actionable now (it touches only
`SharedWitness.lean`, which 341 owns).

## Method (how "public" was determined)

The import DAG of `NfMultiAnchorBridge/` (reconstructed from `^import` lines):

```
Base ──> CarrierK1V ──> CarrierKv ──> PriorInterface ──> SubBracket ──> SubBracket2 ──> SubBracket2V ──> NavigatedSpine
  │            │              │                                                                │
  │            │              ├──> RefutationF2                                                 └──> SharedWitness ──> OuterGate ──> ExteriorBracket
  │            └── (endChar0) │                                                                        └──> ExteriorZoneTriage
  ├──> Lemma32Reduction                                                                        (external, FROZEN) ExteriorNegation ──> SharedWitness
  └──> NavigatedEndChar (imports Base + Lemma32Reduction + CarrierKv; NOT SharedWitness)
```

"Public API of X" = the set of X's non-`private` top-level declarations that are referenced by
name in **any other `.lean` file** (grep `-wF` of each declared name across all 15 directory files
plus the two external `Exterior*` consumers and the aggregator). Project-wide re-checks confirmed no
importer outside `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` reaches these symbols directly
(only `KampPrior.lean` consumes them, transitively through the `NfMultiAnchorBridge.lean`
aggregator).

## Finding 1 — SharedWitness public surface: 31 real, 346 leaked

- `grep -cE '^(noncomputable )?private '` `SharedWitness.lean` = 84 already-private decls;
  460 total top-level decls ⇒ **377 declared public**.
- Distinct SharedWitness public names referenced per consumer: `OuterGate` 19, `ExteriorBracket`
  20, `ExteriorZoneTriage` 3, `ExteriorNegation`/`ExteriorNegationPast` 8 (all zone-specs, subset).
- **Union across all five frozen consumers = 31 names** (full list in the API table below).
- **377 − 31 = 346 leaked-public symbols** — safe to privatize; verified zero external consumers.

### The 5 mislabeled "anchors" (internal scaffolding, not API)

| Symbol | Internal uses in SW | External consumers (project-wide) | Verdict |
|---|---|---|---|
| `kvE2_sepHonestOrder'` | 135 | **NONE** | HIDE (private) — the single largest scaffold |
| `kvE2_sepArr'` | 54 | **NONE** | HIDE (private) |
| `kvE2_sepSlotLe` | 21 | **NONE** | HIDE (private) |
| `kvE2_ordRank` | 20 | **NONE** | HIDE (private) |
| `kvE2_sepDisjValidOwner` | 12 | **NONE** | HIDE (private) |

These are the order/rank/validity kernel that assembles `kvE2_sepBody` internally. They are pure
implementation detail of the honest-order construction and should never have been public.

## Finding 2 — The true public API table (the 31 pinned entry points)

`keep-public?` = MUST stay public (a frozen consumer pins it). `proposed name` is a **deferred**
Mathlib-style rename (blocked by the frozen pin; see Finding 5). All in namespace
`Bimodal.Metalogic.WeakCanonical.Kamp`.

### Group 1 — Def 3.1 zone constants (7) — the fundamental public entry point

| Current name | SW line | Consumers | Proposed name (deferred) | Keep public? |
|---|---|---|---|---|
| `kvE2_sep_zPastX3` | 71 | ExtZoneTriage, ExtBracket, ExtNegation, ExtNegationPast | `SepZone.pastX` | **YES (pinned)** |
| `kvE2_sep_zAtX3` | 75 | ExtBracket, ExtNeg(+Past) | `SepZone.atX` | **YES (pinned)** |
| `kvE2_sep_zXW3` | 79 | OuterGate, ExtBracket | `SepZone.interiorLeft` | **YES (pinned)** |
| `kvE2_sep_zAtW3` | 83 | ExtBracket, ExtNeg(+Past) | `SepZone.atW` | **YES (pinned)** |
| `kvE2_sep_zWT3` | 87 | OuterGate, ExtBracket | `SepZone.interiorRight` | **YES (pinned)** |
| `kvE2_sep_zAtT3` | 91 | ExtBracket, ExtNeg(+Past) | `SepZone.atT` | **YES (pinned)** |
| `kvE2_sep_zFutT3` | 95 | ExtZoneTriage, ExtBracket, ExtNeg(+Past) | `SepZone.futT` | **YES (pinned)** |

These 7 `ZoneSpec 3` constants are already well-documented (each has a `/--` docstring naming its
order relation, SW:70–96). They partition the depth-2 environment `x < w < t` into 7 zones and are
the most broadly-consumed public objects. **This group is the model for what good API looks like
here** — keep as the documented anchor of the layer.

### Group 2 — Slot / formula primitives (10)

| Current name | SW line | Consumers | Proposed name (deferred) | Keep public? |
|---|---|---|---|---|
| `kvE2_sepProj3` | 166 | ExtBracket | `Sep.proj3` | YES (pinned) |
| `kvE2_sepLit` | 173 | ExtBracket | `Sep.literal` | YES (pinned) |
| `kvE2_sepPos` | 193 | OuterGate, ExtBracket, ExtNegation | `Sep.positiveSubs` | YES (pinned) |
| `kvE2_sepPosI` | 211 | OuterGate, ExtBracket | `Sep.ownerIndex` | YES (pinned) |
| `kvE2_sepPosI_mem` | 217 | OuterGate, ExtBracket | `Sep.ownerIndex_mem` | YES (pinned) |
| `kvE2_sepPosI_zone` | 230 | OuterGate | `Sep.ownerIndex_zone` | YES (pinned) |
| `kvE2_sepHasPos` | 244 | ExtBracket | `Sep.hasPositive` | YES (pinned) |
| `kvE2_sepEpL` | 1054 | ExtBracket | `Sep.endpointLeft` | YES (pinned) |
| `kvE2_sepEpR` | 1076 | ExtBracket | `Sep.endpointRight` | YES (pinned) |
| `kvE2_sepPtW` | 1100 | OuterGate, ExtBracket | `Sep.witnessPoint` | YES (pinned) |

### Group 3 — The honest gate (3) — Lemma 3.2(1)

| Current name | SW line | Consumers | Proposed name (deferred) | Keep public? |
|---|---|---|---|---|
| `kvE2_sepGate` | 1254 | OuterGate | `Sep.gate` | YES (pinned) |
| `kvE2_sepGate_holds_of_honest` | 2797 | OuterGate | `Sep.gate_of_honest` | YES (pinned) |
| `kvE2_sepGateAtPin_fragL` | 10605 | OuterGate | `Sep.gateAtPin_left` | YES (pinned) |

### Group 4 — The joint carrier / body O1–O3 (5)

| Current name | SW line | Consumers | Proposed name (deferred) | Keep public? |
|---|---|---|---|---|
| `kvE2_sepBody` | 2347 | OuterGate, ExtBracket | `Sep.body` | YES (pinned) |
| `kvE2_sepBody_complete` | 3363 | OuterGate | `Sep.body_complete` | YES (pinned) |
| `kvE2_sepBody_extract` | 8575 | ExtBracket | `Sep.body_extract` | YES (pinned) |
| `kvE2_sepBody_holds_of_honest` | 9800 | OuterGate | `Sep.body_of_honest` | YES (pinned) |
| `kvE2_sepBody_kit_sound_frag` | 12580 | OuterGate | `Sep.body_kit_sound` | YES (pinned) |

### Group 5 — Fragment realizability (task 344) (3)

| Current name | SW line | Consumers | Proposed name (deferred) | Keep public? |
|---|---|---|---|---|
| `kvE2_sepFragment_frag` | 10219 | OuterGate | `Sep.fragment` | YES (pinned) |
| `kvE2_sepFragment_realizable` | 10265 | OuterGate | `Sep.fragment_realizable` | YES (pinned) |
| `kvE2_outer_fold_frag` | 12665 | OuterGate, ExtBracket | `Sep.outerFold` | YES (pinned) |

### Group 6 — Exterior interface (task 347) + honesty certificate (3)

| Current name | SW line | Consumers | Proposed name (deferred) | Keep public? |
|---|---|---|---|---|
| `kvE2_sepInterior_exterior_notRealizable` | 12627 | OuterGate, ExtZoneTriage | `Sep.interior_exterior_notRealizable` | YES (pinned) |
| `kvE2_sepProjFresh_eval` | 7297 | ExtBracket | `Sep.projFresh_eval` | YES (pinned) |
| `kvE2_sepHonest_hLR_absurd` | 6087 | OuterGate | `Sep.honest_hLR_absurd` | YES (pinned) |

**Everything else declared in `SharedWitness.lean` (346 symbols) → `private` / module-local.**

## Finding 3 — Carrier trio (Base / CarrierK1V / CarrierKv = K0 / K1 / Kv) public surface

The three depth-strata "carrier" files export a second, separate API consumed by
`NavigatedEndChar` (a named consumer), `Lemma32Reduction`, `RefutationF2`, `PriorInterface`, and
the `SubBracket*` chain. Public counts: `Base` 59 declared / ~18 consumed; `CarrierK1V` 15 / 12;
`CarrierKv` 9 / 8. These files are **less bloated** than SharedWitness (CarrierKv/K1V already use
`private` aggressively: 4 and 13 privates respectively) — but their **naming is the worst smell in
the layer** (Finding 4).

Carrier symbols consumed by a **frozen** file (pinned, rename-blocked): `BracketEndCharCarrierV`,
`bracketEndChar_k1v_correct`, `nfk_projFresh`, `nf_eval_depth1_fold_iff`, `nf_char2_atom_layer`
(→ OuterGate/ExtBracket). Carrier symbols consumed only by **non-frozen** files (renameable now):
`Mcex`, `sigCex`, `endChar0`, `seg`, `nf_char3_*`, `nf_zone_flatten_navigable*` (→
`NavigatedEndChar` / `Lemma32Reduction` only).

## Finding 4 — API smells (with file:line)

1. **Two parallel, inconsistently-named endpoint-characterization families across K0/K1/Kv.**
   - `Base.lean`: `endChar0` (995), `endChar` (1558), `endCharN0` (1660), `endCharRec` (1523) —
     bare `endChar*`, no "bracket" prefix.
   - `CarrierK1V.lean`: `bracketEndChar_k0` (73), `bracketEndChar_k1` (180), `bracketEndChar_k1v`
     (433) — `bracketEndChar_` prefix + `_kN` suffix.
   - `CarrierKv.lean`: `bracketEndChar_kv` (238).
   - `bracketEndChar_k0` (CarrierK1V:73) vs `endChar0` (Base:995) read as **near-duplicate
     characterizations at different layers with unrelated names**. The suffix ladder `_k0 / _k1 /
     _k1v / _kv` is opaque: the distinction between `_k1v` and `_kv` is undocumented in the name.
     *Proposal*: unify under one `bracketEndChar` root with an explicit depth/stratum suffix and a
     docstring table mapping K0/K1/Kv → depth semantics. (`bracketEndChar_k1v_*` and
     `BracketEndCharCarrierV` are frozen-pinned; rename deferred.)

2. **Opaque `*cex` abbreviations** (`Base.lean`): `sigCex` (1756), `Mcex` (1761), `atomMapCex`
   (1767). Violates task 175's "no opaque abbreviations" rule (cf. banned `bfmcs`/`drm`/`cud`).
   Consumed only by non-frozen `Lemma32Reduction` → **renameable now**. *Proposal*:
   `counterexampleSignature`, `counterexampleStructure`, `counterexampleAtomMap`.

3. **Trivial primed/`_zero`/`_one` variants.** `bracketEndChar_kv_correct_zero` (CarrierKv:367) /
   `bracketEndChar_kv_correct_one` (CarrierKv:395) are the bit=0 / bit=1 split of one correctness
   fact — task 175 flags trivial variants. Consider a single `bracketEndChar_kv_correct` quantified
   over the bit, with the two directions as `private` helpers. (Both are frozen-consumed via
   `PriorInterface`/`RefutationF2`, which are *not* frozen — check consumers before merging.)

4. **The `_frag` fork leaves dead non-`_frag` twins public.** `kvE2_outer_fold` (non-frag) and
   `kvE2_outer_fold_frag` (SW:12665) **both exist**; only the `_frag` version is externally
   consumed. Same for `kvE2_sepBody_kit_sound` vs `kvE2_sepBody_kit_sound_frag` (SW:12580). The
   task-344 pin-anchored rewrite superseded the originals at the API boundary but left the originals
   public. *Proposal*: privatize/retire the non-`_frag` twins (verify no internal use first), then
   drop the now-meaningless `_frag` suffix from the survivors during the deferred rename. Additional
   `_frag` family members `kvE2_sepBundleL_sound_frag` / `kvE2_sepBundleR_sound_frag` (L/R pair) and
   `kvE2_sepGateAtPin_fragL` / `_fragR` are near-duplicate L/R mirrors.

5. **Generic utility lemma leaked to public.** `getElem_append3_mid` (`CarrierK1V.lean`, consumed
   only by `SubBracket2V`) is a domain-agnostic list-indexing lemma sitting in the public carrier
   API. It belongs `private` or in a shared list-utility module, not the carrier's public face.

6. **The pervasive `kvE2_sep` prefix is itself an undocumented abbreviation.** `kvE2` (≈ "Kv,
   depth-2 EA") appears in ~100+ decls with no in-name expansion. Because 31 public bearers are
   frozen-pinned, a prefix rename is a large, deferred, mechanical change — but the split is the
   natural moment to introduce a `Sep`/`SepCarrier` **namespace** so future decls drop the prefix
   even if legacy names are kept as `export`/`alias` shims.

## Finding 5 — The frozen-file constraint gates all renames

Task 349 freezes `SubBracket2V, OuterGate, ExteriorBracket, ExteriorZoneTriage, ExteriorNegation,
ExteriorNegationPast, KampPrior`. **All 31 public SharedWitness symbols are referenced by at least
one frozen file**, so renaming any of them would require editing a frozen consumer — forbidden.

Consequence for task 341's scope:
- **Actionable now (touches only `SharedWitness.lean`, 341's own target):** privatize/module-local
  the 346 non-consumed symbols; introduce a nested `namespace`/`section` structure; add docstrings
  to the 31 entry points; group them per Findings 2's six groups.
- **Deferred to a post-thaw rename task:** the Mathlib-style `Sep.*` / `SepZone.*` renames, the
  `kvE2_sep` prefix retirement, the `endChar`/`bracketEndChar` unification. These are *proposals*
  in this report, not 341 work. A future task can land them as an `export`-alias-then-migrate pass
  once the exterior files are editable.
- **Renameable now (non-frozen consumers only):** the `Base.lean` `*cex` triple (Finding 4.2) and
  possibly the `bracketEndChar_kv_correct_{zero,one}` merge (Finding 4.3) — but these live in the
  carrier trio, and whether they fall in 341's split scope depends on the plan's file boundaries.

## Finding 6 — Recommended documented entry points

For a future reader, **task 350's `quantEndSeg` aggregate** (confirmed **not yet in the tree** —
`grep -rln quantEndSeg` is empty), and the endChar rebuild, the documented public interface should
be exactly:

1. **The 7 Def 3.1 zone constants** (`kvE2_sep_z*3`, SW:71–95) — the partition every downstream
   evaluator dispatches on. Already docstring-quality; make these the layer's headline export.
2. **`kvE2_sepGate` (SW:1254) + `kvE2_sepGate_holds_of_honest` (SW:2797)** — the Lemma 3.2(1)
   honest gate: the single predicate a consumer asserts.
3. **`kvE2_sepBody` (SW:2347) + `kvE2_sepBody_extract` (SW:8575) + `kvE2_sepBody_holds_of_honest`
   (SW:9800)** — the O1 carrier and its O3 extraction / honesty bridge: the "what you get out" side.
4. **`kvE2_sepFragment_realizable` (SW:10265) + `kvE2_outer_fold_frag` (SW:12665)** — the task-344
   fragment realizability result: the current *recommended* soundness entry (supersedes the
   non-`_frag` twins).
5. **`kvE2_sepInterior_exterior_notRealizable` (SW:12627)** — the task-347 exterior boundary fact;
   docstring MUST cite **revised Prop 4.3** (per `reports/02` Finding 4), never the retired prop43
   framing.
6. For the carrier trio: **`bracketEndChar_kv` + `bracketEndChar_kv_correct_*` (CarrierKv)** and
   **`endChar` / `endChar0` (Base)** — but only after the K0/K1/Kv naming is unified (Finding 4.1).

Task 350's `quantEndSeg` should be built against **these named entry points**, never against the
internal order/rank kernel (`kvE2_sepHonestOrder'` et al.) — which this report recommends
privatizing precisely so 350 cannot accidentally couple to it.

## Confidence + Open Questions

**High confidence:**
- The 31-vs-346 public/leaked split (direct `grep -wF` of all 377 declared-public names across every
  consuming file + project-wide re-check of the 5 mislabeled anchors → all NONE externally).
- All 31 public names are frozen-pinned ⇒ rename-blocked in 341 (each maps to ≥1 file in the 349
  freeze set).
- `quantEndSeg` does not yet exist (empty project-wide grep).

**Medium confidence / needs plan-phase verification:**
- Exact privatization safety of each of the 346: the counts prove *no cross-file* use, but a few may
  be referenced by `@[simp]`/`attribute` or `open`-exposed tactic blocks that grep-by-name still
  catches — recommend a `lean_references` sweep on a sample before bulk-privatizing, and rely on
  `lake build` green as the real gate (privatizing an unused-external decl cannot break a build).
- The `_frag` non-frag twins (Finding 4.4): I confirmed both decls exist and only `_frag` is
  externally consumed, but did not confirm the non-frag twins are internally dead — verify with
  `lean_references` before retiring.
- Whether the carrier trio (Base/K1V/Kv) even falls inside 341's split boundaries or is out of
  scope (prior plan `plans/01` seams A–E are all inside `SharedWitness.lean`). If the trio is out of
  scope, Findings 4.1–4.3/4.5 are proposals for a sibling task, not 341.

**Open questions for synthesis / plan:**
1. Should 341 privatize the 346 *in place* first (a mechanical, independently-verifiable green step),
   or only as a side effect of the module split? Recommendation: **privatize-in-place as an early
   phase** — it is the lowest-risk, highest-signal API win and shrinks every subsequent seam.
2. Does the plan want a legacy-name `export`/alias shim layer so the deferred renames can land later
   without a second frozen-file collision? (Would let 350 adopt clean `Sep.*` names immediately.)
3. Confirm with Angle A / the module-split design that "one module ⇒ one small public API +
   everything else `private`" is the adopted encapsulation contract for each new sibling module.

## Verification Trail

- `grep -cE '^(noncomputable )?private '` SharedWitness.lean = 84; total top-level decls = 460 ⇒ 377 public.
- 377 public names × `grep -wF` in {OuterGate, ExteriorZoneTriage, ExteriorBracket, ExteriorNegation, ExteriorNegationPast} → union = 31.
- `kvE2_sepArr'|kvE2_sepHonestOrder'|kvE2_ordRank|kvE2_sepSlotLe|kvE2_sepDisjValidOwner` → external files = NONE (project-wide, excluding SharedWitness.lean).
- Import DAG from `^import .*NfMultiAnchorBridge` across all 15 files; external SharedWitness importers = ExteriorNegation only; aggregator `NfMultiAnchorBridge.lean` re-exports 13 of 15 (not NavigatedEndChar/Lemma32Reduction); sole aggregator consumer = KampPrior.lean.
- `grep -rln quantEndSeg Theories/ specs/` → empty.
- Carrier naming: `bracketEndChar_{k0,k1,k1v,kv}` at CarrierK1V:73/180/433, CarrierKv:238; `endChar{0,N0,Rec}` at Base:995/1660/1523; `sigCex/Mcex/atomMapCex` at Base:1756/1761/1767; `getElem_append3_mid` in CarrierK1V (consumer: SubBracket2V).
- `_frag` twins: `kvE2_outer_fold` + `kvE2_outer_fold_frag`, `kvE2_sepBody_kit_sound` + `_frag` both declared in SharedWitness.lean.
