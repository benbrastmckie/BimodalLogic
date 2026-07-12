# Research Report: Task 341 — Post-Kamp-Revision Realignment Assessment

- **Task**: 341 - structural_refactor_sharedwitness_carrier_layer
- **Status**: [PLANNED] (this report scopes a pre-implementation plan revision; no source edits)
- **Date**: 2026-07-11
- **Type**: lean4 (assessment only — no code moved, no proofs touched)
- **Purpose**: Determine whether the 341 module-split plan requires revision after the recent
  Kamp-theorem revision pass (tasks 344, 345, 346, 347, and in-flight 348) reshaped
  `SharedWitness.lean`, and whether faithful alignment with Rabinovich's proof is at risk.
- **Baseline artifacts**: `reports/01_sharedwitness-declaration-survey.md` (survey at 10,037 lines),
  `plans/01_module-split-design.md` (five-seam design, dated 2026-07-10)
- **Measured HEAD**: `7107021d6`; `SharedWitness.lean` = **12,800 lines** (survey measured 10,037)

## Executive Summary

**341 does NOT require a faithfulness revision in the semantic sense — but it DOES require a
plan/survey re-survey before its implementation phases, and re-grounding the new exterior material
in the revised Rabinovich Prop 4.3 treatment is part of that re-survey.** A `/revise 341` is
warranted; a proof-faithfulness rework is not.

341 is a **pure structural refactor** (relocate declarations into sibling modules, turn
`SharedWitness.lean` into a re-export hub) under an explicit *no-semantic-change* invariant plus the
LITMUS check (`NavigatedSpine:437`). It does not encode or re-prove Rabinovich, so it **cannot make
the formalization unfaithful** — relocating a proved, axiom-clean theorem preserves its meaning by
construction. Faithfulness to Rabinovich is owned by the Kamp-theorem tasks (346/347/348), not 341.

The revision pass nonetheless invalidates 341's *design artifacts* (survey line ranges, five-seam
map, dependency/GATE wording, docstring citations), because the file grew ~27% and gained an entire
un-mapped exterior/fragment region. The revision needed is a **re-survey + re-citation**, NOT a
redesign — 341's Phase 3 GATE re-diff was designed for exactly this drift, and the symbol-anchored
(not line-anchored) design survived.

## Finding 1 — Faithfulness is not at risk (341 has no semantic content to be unfaithful)

- 341's plan (`plans/01_module-split-design.md`) sets a hard **no-semantic-change** non-goal: "do NOT
  alter any proof, statement, definition body, or evaluation behavior," and preserves the F1–F7
  faithfulness invariants + LITMUS (`NavigatedSpine:437`) exactly.
- A structural refactor relocates declarations; a proved, axiom-clean
  (`{propext, Classical.choice, Quot.sound}`) theorem carries its meaning with it. 341 therefore
  cannot introduce a faithfulness *defect* — the recent revision creates no faithfulness *hazard* in
  341.
- **Faithfulness ownership**: the Rabinovich-alignment work lives in 346 (successor carrier
  redefinition), 347 (bracket faithfulness review — retired/replaced the prop43 successor spec,
  narrowed `hexclExt` to exterior-marked σ), and 348 (Prop 4.3 exterior reflatten). 341 consumes
  their frozen result; it does not re-adjudicate it.

**Conclusion**: There is no "faithful-alignment bug" for 341 to fix. The revision 341 needs is about
*mapping accuracy against the reshaped file*, not proof fidelity.

## Finding 2 — All ten split-anchor symbols survived the revision

341's design deliberately names the split against verified live symbols (not line numbers) to
survive drift. Re-checked at HEAD `7107021d6` — all ten are still live single decls (none
retired/renamed by 347's "retire-and-replace prop43 successor spec"):

| Symbol | Live decls at HEAD |
|---|---|
| `kvE2_sepArr'` | 3 (family) |
| `kvE2_sepDisjValidOwner` | 1 |
| `kvE2_sepPosI` | 1 |
| `kvE2_ordRank` | 1 |
| `kvE2_sepBody` | 1 |
| `kvE2_sepBody_extract` | 1 |
| `kvE2_sepHonest_hLR_absurd` | 1 |
| `kvE2_sepHonestOrder'` | 4 (family) |
| `kvE2_sepSlotLe` | 1 |
| `kvE2_sepGate` | 1 |

**Conclusion**: Seams A–E's *anchors* are intact. The symbol-anchored design paid off — the five-seam
map for the original 1–10,037 region does not need re-anchoring, only re-measuring.

## Finding 3 — The file grew ~27%; a whole new un-mapped region exists (effective sixth seam)

- **Size**: 10,037 → **12,800 lines** (+2,763, +27%). Every line range, per-module size estimate,
  and phase-order arithmetic in `plans/01` is stale.
- **Banners**: 40 → 58 `/-! ##`-style headers, plus the new region is organized with `/--` docstring
  headers per decl (a cleaner style than the flat comment banners the survey mapped).
- **The new region sits entirely ABOVE the survey's 10,037 ceiling** — the five-seam map (A–E) never
  saw it. There is even an in-file marker left for 341 at **SW:10210**:
  `-- 341 GATE re-diff: everything below this banner is new; nothing above is touched.`
- **What the new ~2,763 lines contain** (tasks 344/346/347/348 — the `_frag` / pin-anchored /
  exterior-successor family):

  | Anchor | Decl | Origin |
  |---|---|---|
  | SW:10062 | `kvE2_outer_fold` | task 333 P4 (R4) |
  | SW:10219 | `kvE2_sepFragment_frag` | task 344 |
  | SW:10265 | `kvE2_sepFragment_realizable` | task 344 |
  | SW:10249 | interior-singleton realizability witness | task 346 P2 |
  | SW:10303/10359 | `kvE2_sepBundleL/R_sound_frag` | task 344 P1 |
  | SW:10596/11625 | `kvE2_sepGateAtPin_fragL/R` (pin-anchored gate producers) | task 344 P1 / dispatch 11 |
  | SW:12580 | `kvE2_sepBody_kit_sound_frag` | task 344 P2 |
  | SW:12627 | `kvE2_sepInterior_exterior_notRealizable` | **task 347 P1** |
  | SW:12665 | `kvE2_outer_fold_frag` | task 344 P3 |

**Conclusion**: The re-survey must add a **sixth seam** (or extend Seam E) covering SW:10210–12800.
This is a cohesive `_frag`/pin-anchored/exterior cluster — a natural module boundary — but it did not
exist when the five-seam map was drawn.

## Finding 4 — Rabinovich grounding shifted; the new module's docstrings must cite revised Prop 4.3

This is the ONLY place "faithful alignment with Rabinovich" genuinely touches 341, and it is a
*citation* concern, not a *proof* concern.

- 341's plan grounds module docstrings in **Def 3.1, Lemma 3.2(1), Cor 5.4, Rabinovich §5** — the
  organization of the original region.
- Task 347 **retired the old prop43 successor framing** and re-based the exterior handling on
  **Prop 4.3**. In-file evidence at SW:12707: "NOT exterior-exclusion on this bracket — that framing
  is retired"; SW:12663: "provider-discharged downstream (task 335 / the Prop-4.3 exterior
  successor)."
- 341's plan and survey contain **zero references to 347, 348, Prop 4.3, `hexclExt`, or
  reflatten** — they predate the entire revision pass.

**Risk if not revised**: when the re-survey assigns the SW:10210–12800 region to a module, its
docstrings would either be missing or (worse) copy a *retired* framing forward — propagating a
citation that no longer reflects the proof. The plan's own "never copy `md:NN` forward silently" rule
generalizes here: the new module must cite the **revised Prop 4.3 exterior treatment** established by
347/348, not the retired prop43-successor framing.

## Finding 5 — Dependency chain and GATE wording in the plan body are stale

- Commit `cc319d626` (2026-07-11) added 341's dependency on 346 ("341 code-move GATE must wait for
  346, not just 335; 344/345 growth of SharedWitness noted for GATE re-diff") — but that edit landed
  **only in `state.json` / `TODO.md`**, not in `plans/01`. The plan body still names **335** as the
  freeze gate.
- The real freeze gate is now **348 complete + `SharedWitness.lean` confirmed frozen**. 348 is
  `[IMPLEMENTING]` and still appending to the file (it added the SW:12627 exterior region under
  frozen-file discipline, working only below the SW:10210 banner).

**Conclusion**: The revised plan must update the Phase 3 GATE precondition from "335 [COMPLETED] +
frozen" to "**348 [COMPLETED] + frozen** (335/346/347 already complete)."

## Recommended Revision Scope (`/revise 341`, to run AFTER 348 completes)

Run against the final frozen file so the re-survey hits stable line numbers. Scope:

1. **Re-run the declaration survey** against the current HEAD (12,800 lines): refresh line ranges,
   per-module size estimates, banner inventory, and dangling-`md:NN` count. Symbol anchors (Finding
   2) need no change.
2. **Add a sixth seam** (or extend Seam E) for the SW:10210–12800 `_frag`/pin-anchored/exterior
   cluster — the SW:10210 in-file marker gives a ready-made lower cut line.
3. **Re-ground the new module's docstrings in the revised Rabinovich Prop 4.3 exterior treatment**
   (from 347/348), and explicitly retire the old prop43-successor framing — do not copy it forward.
   *This is the faithful-alignment step.*
4. **Update the Phase 3 GATE precondition** to "348 [COMPLETED] + `SharedWitness.lean` frozen"; fold
   the `cc319d626` 346-dependency addendum into the plan body (currently only in state.json/TODO).
5. **Re-verify Boneyard candidates** against the reshaped file — some SW:899 "STAGED, not yet wired"
   / SW:6528 hgate residue may now be wired-in (344/346 landed pin-anchored gates); re-check
   `lean_references` before listing anything as dead.

## What does NOT need to change

- The core five-seam design (A–E) and its symbol anchors — intact.
- The no-semantic-change / F1–F7 / LITMUS invariants — unchanged and still correct.
- The re-export-hub strategy and byte-for-byte import-preservation goal — unaffected.
- The proofs themselves — 341 relocates, never re-proves; faithfulness is 346/347/348's charge.

## Sequencing Note

There is **no urgency to revise 341 today**. Because 348 is still editing `SharedWitness.lean`, the
re-survey should run against the *frozen* file after 348 lands — revising now would immediately go
stale again. The correct order is: **348 completes → confirm frozen → `/revise 341` (re-survey per
scope above) → 341 implementation phases**. Design-only phases (1–2 of the existing plan) remain safe
to run pre-freeze if desired, but the re-survey they depend on is cheapest done once, post-freeze.

## Verification Trail

- `wc -l SharedWitness.lean` = 12,800 (survey: 10,037).
- Symbol currency: `grep -E '^(noncomputable )?(def|theorem|lemma|abbrev) +<sym>'` for all ten
  anchors → all ≥1 decl.
- New region: `grep -nE '^(def|theorem|lemma) +kvE2' | awk '$1>10037'` → 22 new top-level decls
  (344/346/347 family).
- SW:10210 in-file 341-GATE marker confirmed present.
- 341 plan/report ∌ {347, 348, Prop 4.3, hexclExt, reflatten} (grep, empty).
- `cc319d626` diff touches only `specs/TODO.md` + `specs/state.json` (not `plans/01`).
