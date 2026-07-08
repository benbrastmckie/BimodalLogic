# Task 332 Research — Boneyard Sweep of Quarantined Merged-Bracket Infrastructure

**Status**: researched
**Type**: lean4 (research only — no files edited)
**Date**: 2026-07-08
**Scope**: `NfMultiAnchorBridge/MergedQuarantine.lean` (task-331 in-tree byte-identical
quarantine) + the named "refuted arity-1 fold-engine remnants".

---

## Executive Summary (headline findings)

1. **The task's import premise is inaccurate — MergedQuarantine is imported by exactly ONE
   file, the umbrella `NfMultiAnchorBridge.lean:34`.** `NavigatedSpine.lean` does **NOT** import
   MergedQuarantine (it imports only `SubBracket2V`). This makes the sweep strictly cleaner than
   the task assumed: MergedQuarantine is a true leaf with a single inbound import edge.

2. **The "refuted arity-1 fold-engine remnants" (`nfk_assemble`, `nfk_dropFresh`,
   `nfk_zoneSpec`, `efold_of_nfk`, `nf_quant_layer_fold_k2_gate`, `nf_eval_nf1_cons_factor`)
   are PHANTOM — they have ZERO declarations anywhere in `Theories/`.** They exist only as prose
   in NO-GO documentation. There is nothing to delete for them. `NavigatedSpine.lean:37-39`
   already documents this explicitly. The genuinely-dead material to sweep is exactly the
   MergedQuarantine file and nothing else.

3. **Every reference to a MergedQuarantine declaration from outside the file is prose
   (doc-comment / strategy note), never a term-level use.** MergedQuarantine's `private` decls
   are module-local by construction; its public decls (`bracketEndChar_kvE`/`kvE'`/`kvE2`, their
   `_two_eq` mates, `kvE2_joint_nonvacuous_at_honest`) are referenced only inside comments in
   sibling files. `KampPrior.lean` (the umbrella's sole consumer) references **none** of them.

4. **Safe minimal sweep = delete import edge `NfMultiAnchorBridge.lean:34` + remove the file
   (delete outright, or relocate to `Boneyard/` with the `#exit` convention).** No live decl's
   axiom profile changes, because no live decl references any MergedQuarantine symbol.

5. **Task 333 is fully orthogonal.** Its assets (`kvE2_sepArrL/R` at `SharedWitness.lean:338/343`)
   and its two strategic sorries (`SharedWitness.lean:1820`, `:1952`) live in `SharedWitness.lean`,
   which does **not** import MergedQuarantine. Preserve `SharedWitness.lean` untouched.

---

## Deliverable 1 — Reference Inventory (decl → referencing-files map)

### 1a. MergedQuarantine.lean declarations (file: 1026 lines, sorry-free)

Header provenance (MergedQuarantine.lean:4-20): "Extracted from NfMultiAnchorBridge.lean lines
5077-5332, 5360-5856, 8586-8826 (task 331)… QUARANTINE / DEAD-CODE: merged-bracket route
(bracket-whose-points-are-brackets)… Violates the no-nesting audit rule and the Rabinovich 2014
Lemma 5.1 quantifier-free point-type requirement (md:134-135). Retained byte-identical for the
record; task 321 retires it once the faithful route lands."

Full declaration list (line-cited):

| Line | Decl | Vis | External live refs? |
|-----:|------|-----|---------------------|
| 112 | `kvE_consistent` | private | none (module-local) |
| 127 | `kvE_gate` | private | none — sibling hits are prose analogies (`SubBracket2V.lean:1001,1079`; `SubBracket2.lean:420,438,510`; `NavigatedSpine.lean:429`) |
| 242 | `kvE_body_gate_fail` | private | none |
| 262 | `bracketEndChar_kvE` | public | none — refs are prose (`PriorInterface.lean:57`, `RefutationF2.lean:947`, `SubBracket.lean:222`) |
| 279 | `bracketEndChar_kvE_two_eq` | public | none |
| 427 | `kvE_PinArrangement` (structure) | private | none |
| 435 | `kvE_consistentZones` | private | none |
| 449 | `kvE_pinArrangements` | private | none — prose only (`SubBracket.lean:25,257`) |
| 459 | `kvE_pinDisjunct` | private | none — prose only |
| 472 | `kvE_exclConj` | private | none — prose only |
| 579 | `kvE'_body_gate_fail` | private | none |
| 595 | `bracketEndChar_kvE'` | public | none |
| 608 | `bracketEndChar_kvE'_two_eq` | public | none |
| 732 | `probe_P1_channel_i_collapse` | private | none |
| 751 | `probe_P3_cor54_step_shape` | private | none |
| 775 | `probe_P4_b3_positions_by_eval_point` | private | none |
| 894 | `kvE2_body_gate_fail` | private | none |
| 911 | `bracketEndChar_kvE2` | public | none — refs are prose (`NavigatedSpine.lean:389,405,428,432`; `SubBracket.lean:221,235,238,239`; `SubBracket2.lean:101`; `SubBracket2V.lean:652,1853`) |
| 926 | `bracketEndChar_kvE2_two_eq` | public | none |
| 947 | `kvE2_joint_nonvacuous_at_honest` | public | none |

Also `kvE_body` (:5193 orig), `kvE'_body` (:5562 orig), `kvE2_body` (:8608 orig) — the `open
Classical in` carrier bodies at lines 134, 479, 785. All external `kvE2_body` hits
(`NavigatedSpine.lean:208,217,410,428,445`, `SubBracket2V.lean:6,1016,1084,1169,1853`,
`SubBracket.lean:218`, `CarrierK1V.lean:802`, `SharedWitness.lean:40`) are prose describing the
"pattern"; `SharedWitness.lean:40` is explicit: "`kvE2_body` reused as a *pattern*, never
imported".

**Classification: every MergedQuarantine declaration is category (a) genuinely dead** —
no live term-level reference. The `private` decls are additionally category (b)
(module-local; used only by other MergedQuarantine decls in the same file — the "same-module
`private` reuse of `kvE_gate`/`kvE_pinArrangements`/`kvE_pinDisjunct`/`kvE_exclConj`" the header
at :5-6 warns keeps parts 1+2 together). Removing the whole file removes producers and consumers
together — no dangling references.

### 1b. Named "arity-1 fold-engine remnants" — PHANTOM (0 declarations)

Verified via `grep -rnE '(def|theorem|lemma|abbrev) <name>\b' Theories/`:

| Name | Declarations found | Where the name appears |
|------|-------------------:|------------------------|
| `nfk_assemble` | 0 | prose only — `MergedQuarantine.lean:969`, `NavigatedSpine.lean:37-38` |
| `nfk_dropFresh` | 0 | prose only — `NavigatedSpine.lean:37` |
| `nfk_zoneSpec` | 0 | prose only — `NavigatedSpine.lean:37` |
| `efold_of_nfk` | 0 | prose only — `MergedQuarantine.lean:965`, `NavigatedSpine.lean:39` |
| `nf_quant_layer_fold_k2_gate` | 0 | prose only — `MergedQuarantine.lean:962`, `NavigatedSpine.lean:39` |
| `nf_eval_nf1_cons_factor` | 0 | prose only — `NavigatedSpine.lean:39` |

`NavigatedSpine.lean:37-39` is a live NO-GO note: "`nfk_assemble` / `nfk_dropFresh` /
`nfk_zoneSpec` — do NOT exist as live declarations … appear ONLY in the NO-GO prose". **This
note should STAY** — it is live documentation of what must not be re-attempted. There is no
code to sweep for these names; the only cleanup is the prose inside MergedQuarantine (:962,:965,
:969) which disappears with the file.

### 1c. Look-alike that is LIVE and MUST NOT be touched

`nfk_projFresh` (declared `CarrierKv.lean:82`, `noncomputable def`) is **live** and consumed by
`CarrierK1V.lean:890-891`, `SubBracket.lean` (many), `SubBracket2V.lean` (30+ sites). It is NOT
in MergedQuarantine and is unrelated to the phantom `nfk_*` remnants despite the shared prefix.
**Do not confuse it with a fold-engine remnant.**

---

## Deliverable 2 — Import Graph

### 2a. Intra-subdirectory import DAG (`NfMultiAnchorBridge/`)

```
Base
 └─ CarrierK1V
     └─ CarrierKv ──┬─ PriorInterface ──┬─ SubBracket ── SubBracket2 ── SubBracket2V ─┬─ NavigatedSpine ── (SharedWitness)
                    │                   │                                             │
                    └─ RefutationF2     └─ (MergedQuarantine imports PriorInterface + SubBracket2V)
```

- `MergedQuarantine.lean:1-2` imports `PriorInterface` + `SubBracket2V` (both live). Nothing in
  the subdir imports MergedQuarantine.
- `NavigatedSpine.lean:1` imports **only** `SubBracket2V` — **NOT** MergedQuarantine (task premise
  corrected).
- `SharedWitness.lean:1-2` imports `SubBracket2V` + `NavigatedSpine` — **NOT** MergedQuarantine.

### 2b. Inbound edge to MergedQuarantine (exhaustive)

```
grep -rn "NfMultiAnchorBridge.MergedQuarantine" Theories/ --include=*.lean
  → Theories/.../NfMultiAnchorBridge.lean:34   (the umbrella — ONLY hit)
```

Umbrella consumer chain: `NfMultiAnchorBridge.lean` (umbrella) is imported by exactly one file —
`KampPrior.lean:4`. The umbrella body is 89 lines, all imports + module docstring, **no
declarations** and no reference to any MergedQuarantine symbol. `KampPrior.lean` references
none of MergedQuarantine's decls (verified: `grep -nE 'kvE_gate|kvE2_body|kvE_body|
bracketEndChar_kvE' KampPrior.lean` → NONE).

### 2c. Is the import used or vestigial?

**Vestigial.** The umbrella pulls MergedQuarantine into the default-target build purely to keep
the byte-identical record compiling; no downstream symbol is consumed. Removing
`NfMultiAnchorBridge.lean:34` breaks nothing at the type level. What "breaks" if the import is
removed while the file remains on disk: the file simply stops being built by the default target
(it would only build if some lib still globs it) — which is the desired end-state.

---

## Deliverable 3 — Boneyard Conventions

`lakefile.lean` defines Boneyard as a **separate, non-default library**:

```lean
@[default_target] lean_lib Bimodal where roots := #[`Bimodal] …        -- default build
lean_lib BoneyardArchive where                                          -- NOT default
  srcDir := "Theories"; globs := #[.submodules `Bimodal.Boneyard]
-- "Archived dead code. Not built by default. Build with: lake build BoneyardArchive"
```

So `lake build` (default target) does **not** compile `Bimodal.Boneyard.*`. Confirmed:
`grep -rn "import.*Boneyard" Theories/` → 35 hits, **all internal to Boneyard**; no live module
imports Boneyard, and Boneyard files import each other only.

**Conventions (from `Boneyard/README.md` + representative files):**

1. **Provenance header (newer/preferred convention, task-302 style — `KampNegationClosure/
   NegationClosure.lean:1-5`):**
   ```
   -- ARCHIVED from Metalogic/WeakCanonical/Kamp/NegationClosure.lean
   -- Reason: Dead code — negation closure chain with no live downstream consumers
   -- Archived: 2026-06-16 (task 302)

   #exit

   import …   (original imports, verbatim, below #exit)
   ```
   The `#exit` command halts Lean elaboration at that point, so the original imports/content
   below are never processed — the archived file is **inert even inside `BoneyardArchive`** and
   does not depend on live modules still existing. (Older files such as
   `VecEADecomposition/VecEADecomposition.lean` omit `#exit` and keep real imports; the `#exit`
   pattern is the safer current convention.)

2. **Namespace unchanged**: archived files keep their ORIGINAL namespace
   (`namespace Bimodal.Metalogic.WeakCanonical.Kamp`), only the file PATH/module id moves to
   `Bimodal.Boneyard.<Group>.<File>` (`NegationClosure.lean:41`).

3. **Module directory + README**: each archived group is a directory under `Boneyard/` with a
   `README.md` (`**Archived**: Task N`, `**Original location**: …`, short reason, "Not on any
   live call path"). The top-level `Boneyard/README.md` has an inventory table (Directory | Files
   | Lines | Archived From | Why Archived | Task) that must gain a new row.

4. **Sorries/non-compilation tolerated**: `Boneyard/README.md` states "Code may not compile" and
   "Sorry counts are not bugs". (Irrelevant here — MergedQuarantine is sorry-free.)

**Recommendation on preservation:** The task's byte-identical record is *already* preserved in
git history (committed under task 331, and the refutation is documented in tasks 320/321/327/331
artifacts + the file's own prose). Two defensible options:

- **(B) Relocate to `Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean`** with an
  `#exit` provenance header + module `README.md` + a `Boneyard/README.md` inventory row. This is
  the convention-faithful choice and matches the task title ("Boneyard sweep"). **Recommended.**
- **(A) Delete outright.** Safe because git history + task artifacts already hold the byte-identical
  record and the refutation rationale. Lighter footprint. Acceptable fallback if the planner/user
  prefers minimal tree.

Given the established, actively-maintained Boneyard convention (57 files, taxonomy table, recent
task-302 Kamp archives), **option (B) relocation with `#exit`** is the recommended primary; note
(A) as the sanctioned lighter alternative.

---

## Deliverable 4 — Build-Safety Analysis (minimal safe sequence)

**Precondition to record for the implementer:** confirm current default build is green before
touching anything (`lake build` — the sweep is a pure subtraction, so a green baseline makes any
post-sweep failure unambiguous). MergedQuarantine is sorry-free (its 6 "sorry" lexical hits are
all prose documenting "no sorry": lines 364, 417, 620, 692, 703, 1024).

Minimal safe sequence:

1. **Delete the single import edge** `NfMultiAnchorBridge.lean:34`
   (`import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.MergedQuarantine`).
   Nothing in the umbrella body (lines 1-89 are imports+docstring only) or in `KampPrior.lean`
   references any MergedQuarantine symbol, so this edit alone is compile-safe.

2. **Relocate-or-delete the file:**
   - Option B: `git mv NfMultiAnchorBridge/MergedQuarantine.lean
     Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean`; prepend the `-- ARCHIVED
     from … / Reason / Archived: 2026-…(task 332)` header + `#exit` above the two original
     imports; add module `README.md`; add `Boneyard/README.md` inventory row (~1026 lines, task
     332, "merged-bracket route — violates no-nesting audit + Rabinovich Lemma 5.1 QF point-type;
     refuted, task-321 fallback"). Because `#exit` sits above its imports, the archived file needs
     nothing from live modules.
   - Option A: `git rm NfMultiAnchorBridge/MergedQuarantine.lean`.

3. **Verify green + axiom-clean:** `lake build` (default target). Removal cannot change any live
   decl's axiom profile — no live decl references a MergedQuarantine symbol, so the surviving
   NfMultiAnchorBridge public API (whatever `KampPrior.lean` consumes) is axiom-identical
   pre/post. Optionally `lean_verify` a couple of KampPrior-facing bridge decls to confirm the
   axiom set is unchanged.

**Transitively load-bearing check (looks-dead-but-isn't):** NONE inside MergedQuarantine. The
only live look-alike is `nfk_projFresh` (`CarrierKv.lean:82`), which is outside the file and
untouched. All `private` decls are internal producers/consumers removed together with the file.

---

## Deliverable 5 — Risk Flags

- **R1 (task-333 preservation — HIGH importance, LOW risk if scoped):** Do NOT touch
  `SharedWitness.lean`. Task 333 will redefine `kvE2_sepArrL` (`SharedWitness.lean:338`) /
  `kvE2_sepArrR` (`:343`) and discharge the two strategic sorries at `SharedWitness.lean:1820`
  (in `kvE2_sepSingleton_coverage_left`, decl `:1796`) and `:1952` (in
  `kvE2_sepBody_singleton_complete_left`, decl `:1939`). These are REAL `sorry` tactics that must
  remain. SharedWitness does not import MergedQuarantine, so the sweep does not interfere — but
  the plan must explicitly fence SharedWitness out of scope.

- **R2 (naming confusion):** `nfk_projFresh` (live, `CarrierKv.lean:82`) vs the phantom `nfk_*`
  remnants. The plan/implementer must not grep-and-delete on the `nfk_` prefix. Only phantom
  names with 0 declarations are "removed" (and there is nothing to remove — only MergedQuarantine
  prose that mentions them).

- **R3 (do not delete the NavigatedSpine NO-GO note):** `NavigatedSpine.lean:37-39` documents that
  the fold-engine names never existed. This is live, valuable anti-repeat documentation — leave it.

- **R4 (umbrella docstring hygiene, optional):** The umbrella's module docstring and sibling doc
  comments (`SubBracket*.lean`, `NavigatedSpine.lean`) contain prose mentions of `bracketEndChar_
  kvE2` / `kvE2_body` as "pattern" references. These remain valid as historical/strategy prose
  after the file moves; no obligation to edit them, but the planner may optionally add a "moved to
  Boneyard" breadcrumb. Not build-affecting.

- **R5 (private-reuse coupling — resolved by whole-file move):** The header (:5-6) warns parts 1+2
  must stay together due to same-module `private` reuse. Because the sweep moves/deletes the ENTIRE
  file (both parts), this coupling is satisfied automatically — do not attempt a partial extraction.

- **R6 (build cost / green baseline):** This is a pure subtraction of ~1026 lines from the default
  build; it should only speed builds. The single real risk is an inaccurate green baseline — run
  `lake build` before and after.

---

## Evidence Index (file:line)

- Umbrella import of quarantine: `NfMultiAnchorBridge.lean:34`; sole umbrella consumer
  `KampPrior.lean:4`.
- MergedQuarantine header/provenance: `MergedQuarantine.lean:4-20`; imports `:1-2`.
- MergedQuarantine decls: lines 112, 127, 242, 262, 279, 427, 435, 449, 459, 472, 579, 595, 608,
  732, 751, 775, 894, 911, 926, 947 (+ `open Classical in` bodies at 134, 479, 785).
- NavigatedSpine imports SubBracket2V only: `NavigatedSpine.lean:1`; NO-GO phantom note `:37-39`.
- SharedWitness imports `:1-2`; task-333 assets `:338`,`:343`; sorries `:1820`,`:1952`.
- Live `nfk_projFresh`: `CarrierKv.lean:82`.
- Boneyard lib (non-default): `lakefile.lean` (`BoneyardArchive`, globs `Bimodal.Boneyard`).
- Boneyard conventions: `Boneyard/README.md` (inventory table + "not built by default");
  `#exit` header pattern `Boneyard/KampNegationClosure/NegationClosure.lean:1-13,41`.

## Zero-Debt / Faithfulness Notes

- No sorry, axiom, or vacuous-definition patterns are recommended. The sweep only removes proven,
  refuted dead code; it introduces no proof obligations.
- Faithfulness (Rabinovich 2014 Lemma 5.1 QF point-types / no-nesting audit) is the very reason
  the merged-bracket route was refuted — removing it strengthens, not weakens, faithfulness.
