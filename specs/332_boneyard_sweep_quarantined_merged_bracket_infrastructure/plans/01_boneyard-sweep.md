# Implementation Plan: Task #332 — Boneyard Sweep of the Refuted Merged-Bracket Quarantine

- **Task**: 332 - Boneyard sweep of quarantined/refuted merged-bracket infrastructure
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Dependencies**: Task 321 (verdict recorded; satisfied)
- **Research Inputs**: reports/01_boneyard-sweep-inventory.md
- **Artifacts**: plans/01_boneyard-sweep.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 331 extracted the refuted merged-bracket route (bracket-whose-points-are-brackets; violates
the no-nesting audit rule and Rabinovich 2014 Lemma 5.1 quantifier-free point-type requirement)
into `NfMultiAnchorBridge/MergedQuarantine.lean` as an in-tree byte-identical quarantine. Research
(reports/01) establishes a strictly cleaner picture than the task premise assumed: MergedQuarantine
is a true leaf with **exactly one inbound import edge** — the umbrella `NfMultiAnchorBridge.lean:34`
(verified: `grep -rn "NfMultiAnchorBridge.MergedQuarantine" Theories/` returns that line only).
All 20 declarations are genuinely dead (no live term-level references; external mentions are prose
only). This plan removes that single import edge and disposes of the 1026-line file, then verifies
a green, axiom-clean build. Definition of done: `lake build` exits 0, the surviving
NfMultiAnchorBridge public API is axiom-identical pre/post, and the git diff scope is exactly the
umbrella import line + the moved/deleted file + Boneyard README(s).

### Research Integration

Key findings from reports/01_boneyard-sweep-inventory.md driving this plan:
- **Single inbound edge**: `NfMultiAnchorBridge.lean:34` (confirmed sole hit). `NavigatedSpine.lean`
  does NOT import MergedQuarantine (original task premise corrected — plan against the real graph).
- **All 20 MergedQuarantine decls are dead**; `private` decls are module-local and leave with the
  file. Removing the whole file removes producers and consumers together — no dangling references.
- **The named arity-1 fold-engine remnants are PHANTOM** (`nfk_assemble`, `nfk_dropFresh`,
  `nfk_zoneSpec`, `efold_of_nfk`, `nf_quant_layer_fold_k2_gate`, `nf_eval_nf1_cons_factor` — 0
  declarations anywhere). Nothing to sweep for them; do not spend time hunting them.
- **Boneyard is a non-default `BoneyardArchive` lib** (lakefile.lean), excluded from `lake build`.
  Convention: provenance header (`-- ARCHIVED from … / Reason / Archived: <date> (task 332)`) +
  `#exit` above the original imports, original namespace kept, module `README.md`, plus a new row
  in `Boneyard/README.md`'s inventory table.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this run (no roadmap flag; task is a mechanical cleanup).

## Goals & Non-Goals

**Goals**:
- Remove the sole live import of the refuted merged-bracket quarantine (`NfMultiAnchorBridge.lean:34`).
- Dispose of `MergedQuarantine.lean` (1026 lines) via the convention-faithful Boneyard relocation
  (primary) or outright deletion (sanctioned fallback).
- Prove the default build stays green and the surviving public API is axiom-clean.

**Non-Goals**:
- Do NOT touch `SharedWitness.lean` — task 333 owns its `kvE2_sepArrL/R` (:338/:343) and its two
  real strategic sorries (:1820, :1952). SharedWitness does not import MergedQuarantine.
- Do NOT delete the `NavigatedSpine.lean:37-39` NO-GO note documenting the phantom fold-engine
  names — it is live anti-repeat documentation.
- Do NOT touch `nfk_projFresh` (`CarrierKv.lean:82`, live, 30+ sites) — a look-alike, not a remnant.
- No grep-and-delete on the `nfk_` prefix. No partial extraction from MergedQuarantine (its
  `private`-reuse coupling is satisfied only by moving/deleting the ENTIRE file).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inaccurate green baseline masks a post-sweep regression | M | L | Phase 1 records a fresh green `lake build` before any edit; the sweep is pure subtraction |
| Accidentally touching SharedWitness.lean (task-333 assets/sorries) | H | L | Explicit non-goal; Phase 3 git-diff scope audit asserts SharedWitness is untouched |
| Confusing live `nfk_projFresh` with phantom `nfk_*` remnants | M | L | Non-goal + research R2; no prefix-based deletion; only line 34 + the one file change |
| Deleting the NavigatedSpine NO-GO note | L | L | Explicit non-goal; note is outside the swept file and never edited |
| Axiom profile of public API changes | H | VL | No live decl references any MergedQuarantine symbol; Phase 3 confirms via `lean_verify` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. This plan is fully sequential.

### Phase 1: Baseline + Remove the Single Import Edge [COMPLETED]

**Goal**: Establish an unambiguous green baseline, then delete the one live import of the
quarantine so the default target stops building it.

**Tasks**:
- [ ] Run `lake build` and confirm exit 0 (green baseline for a pure-subtraction change).
- [ ] Confirm the sole inbound edge before editing: `grep -rn "NfMultiAnchorBridge.MergedQuarantine" Theories/ --include=*.lean` returns exactly `NfMultiAnchorBridge.lean:34`.
- [ ] Delete line 34 of `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`
      (`import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.MergedQuarantine`).
- [ ] Confirm nothing else in the umbrella body (lines 1-89 are imports + docstring only) or in its
      sole consumer `KampPrior.lean` references any MergedQuarantine symbol
      (`grep -nE 'kvE_gate|kvE2_body|kvE_body|bracketEndChar_kvE' KampPrior.lean` → none).
- [ ] Run `lake build`; confirm exit 0 (MergedQuarantine.lean is now unbuilt by the default target).

**Timing**: ~20 minutes (dominated by the two builds).

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — delete the single
  `import …MergedQuarantine` line (line 34).

**Verification**:
- Pre-edit `lake build` exit 0 recorded.
- Post-edit `lake build` exit 0.
- Inbound-edge grep confirmed as a single hit before the edit.

---

### Phase 2: Disposition of MergedQuarantine.lean [COMPLETED]

**Goal**: Remove the 1026-line quarantine file from the live tree via the chosen disposition.

**DISPOSITION DECISION POINT** — pick ONE (primary = Option B):

**Option B (RECOMMENDED — convention-faithful, preserves the in-repo record):**
- [ ] `git mv Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/MergedQuarantine.lean
      Theories/Bimodal/Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean`.
- [ ] Prepend the provenance header + `#exit` ABOVE the two original imports (mirrors
      `Boneyard/KampNegationClosure/NegationClosure.lean:1-5`):
      ```
      -- ARCHIVED from Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/MergedQuarantine.lean
      -- Reason: Refuted merged-bracket route (bracket-whose-points-are-brackets) — violates the
      --         no-nesting audit rule and Rabinovich 2014 Lemma 5.1 QF point-type requirement.
      -- Archived: 2026-07-08 (task 332)

      #exit
      ```
      Keep the file's ORIGINAL namespace unchanged; only the module path/id moves. `#exit` sits
      above the imports so the archived file is inert even inside `BoneyardArchive` and needs
      nothing from live modules.
- [ ] Add module `Theories/Bimodal/Boneyard/MergedBracketQuarantine/README.md` (`**Archived**:
      Task 332`, `**Original location**: NfMultiAnchorBridge/MergedQuarantine.lean`, one-line
      reason, "Not on any live call path").
- [ ] Add an inventory row to `Theories/Bimodal/Boneyard/README.md` (table columns: Directory |
      Files | Lines | Archived From | Why Archived | Task) —
      `MergedBracketQuarantine | 1 | 1,026 | WeakCanonical/Kamp/NfMultiAnchorBridge/ | Refuted merged-bracket route — violates no-nesting audit + Rabinovich Lemma 5.1 QF point-type; task-321 fallback | 332`.

**Option A (SANCTIONED LIGHTER FALLBACK — minimal tree; git history + task 320/321/327/331
artifacts already hold the byte-identical record):**
- [ ] `git rm Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/MergedQuarantine.lean`.
- [ ] No Boneyard files created; Phase 3 scope audit expects only the import line + the deleted file.

**Timing**: ~15 minutes.

**Depends on**: 1

**Files to modify**:
- Option B: `git mv` MergedQuarantine.lean → `Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean`
  (+ header/`#exit` edit); new `Boneyard/MergedBracketQuarantine/README.md`; edit
  `Boneyard/README.md` (add inventory row).
- Option A: `git rm` MergedQuarantine.lean.

**Verification**:
- Option B: the moved file begins with the provenance header then `#exit` then the original two
  imports; module README present; Boneyard/README.md gains exactly one inventory row.
- Option A: MergedQuarantine.lean no longer exists; no Boneyard changes.
- Either way: `NfMultiAnchorBridge/MergedQuarantine.lean` no longer exists at its original path.

---

### Phase 3: Final Verification and Scope Audit [COMPLETED]

**Goal**: Prove the sweep is green, axiom-neutral, and scope-tight.

**Tasks**:
- [ ] `lake build` (default target) exits 0.
- [ ] Axiom-clean check: `lean_verify` a couple of KampPrior-facing NfMultiAnchorBridge public
      bridge decls; confirm the axiom set is unchanged vs pre-sweep (expected: identical — no live
      decl referenced any MergedQuarantine symbol).
- [ ] Git diff scope audit — `git status --short` / `git diff --staged` must show EXACTLY:
      the umbrella import line at `NfMultiAnchorBridge.lean:34`; the moved-or-deleted
      `MergedQuarantine.lean`; and (Option B only) the new `Boneyard/MergedBracketQuarantine/`
      files + the `Boneyard/README.md` row. Nothing else.
- [ ] Assert `SharedWitness.lean` is untouched (`git diff --name-only` does not list it); its
      sorries at :1820 and :1952 and its `kvE2_sepArrL/R` at :338/:343 remain intact for task 333.
- [ ] Assert `NavigatedSpine.lean` is untouched (NO-GO note at :37-39 preserved) and
      `CarrierKv.lean` is untouched (live `nfk_projFresh` at :82 preserved).

**Timing**: ~20 minutes.

**Depends on**: 2

**Files to modify**: none (verification only).

**Verification**:
- `lake build` exit 0.
- `lean_verify` axiom set on sampled public decls unchanged.
- Git diff limited to the sanctioned scope; SharedWitness/NavigatedSpine/CarrierKv absent from it.

## Testing & Validation

- [ ] `lake build` (default target) exits 0 after the import removal (Phase 1) and after disposition
      (Phase 3).
- [ ] Sole inbound edge confirmed as a single grep hit before editing.
- [ ] Surviving NfMultiAnchorBridge public API axiom-identical pre/post (`lean_verify`).
- [ ] `git diff` scope is exactly: umbrella import line + moved/deleted file + (Option B) Boneyard
      README(s)/module files.
- [ ] `SharedWitness.lean`, `NavigatedSpine.lean`, and `CarrierKv.lean` all untouched.

## Artifacts & Outputs

- `plans/01_boneyard-sweep.md` (this plan).
- Edited `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (import line removed).
- Option B: `Theories/Bimodal/Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean`
  (relocated, `#exit`-headed) + `Boneyard/MergedBracketQuarantine/README.md` + updated
  `Boneyard/README.md`. Option A: `MergedQuarantine.lean` deleted.
- `summaries/01_boneyard-sweep-summary.md` (produced at implementation time).

## Rollback/Contingency

The change is a pure subtraction of dead code. To revert: `git revert` the sweep commit(s), or
`git checkout` the pre-sweep revision of `NfMultiAnchorBridge.lean` and restore
`MergedQuarantine.lean` from git history (the file is byte-identical in history under task 331).
Because no live decl references any MergedQuarantine symbol, a revert cannot reintroduce a build
break beyond restoring the previously-green state. If Phase 3's axiom/scope audit surprises,
prefer fix-forward (re-scope the diff) over discarding uncommitted work.
