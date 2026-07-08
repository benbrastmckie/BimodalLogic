# Implementation Summary: Task #332 — Boneyard Sweep of the Refuted Merged-Bracket Quarantine

- **Task**: 332 — Boneyard sweep of quarantined/refuted merged-bracket infrastructure
- **Type**: lean4
- **Plan**: `plans/01_boneyard-sweep.md`
- **Disposition**: Option B (convention-faithful Boneyard relocation via `git mv`)
- **Status**: Implemented — all 3 phases COMPLETED

## What Was Done

A pure-subtraction sweep of the refuted merged-bracket route (bracket-whose-points-are-brackets;
violates the no-nesting audit rule and Rabinovich 2014 Lemma 5.1 QF point-type requirement).

### Phase 1 — Baseline + remove the single import edge
- Recorded a green baseline (`lake build` exit 0, 1720 jobs).
- Removed the sole inbound import at `NfMultiAnchorBridge.lean:34`
  (`import …NfMultiAnchorBridge.MergedQuarantine`).
- Confirmed KampPrior.lean references no quarantine symbols; the only other mention of
  `MergedQuarantine` in the tree is prose in `NavigatedSpine.lean:4` (documenting it does NOT
  import the module).
- Post-edit `lake build` exit 0 (1719 jobs — one fewer module built, as expected).

### Phase 2 — Disposition (Option B relocation)
- `git mv Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/MergedQuarantine.lean
  → Theories/Bimodal/Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean`
  (rename retained, R099 — history preserved).
- Prepended the provenance header + `#exit` ABOVE the two original imports (mirrors
  `Boneyard/KampNegationClosure/NegationClosure.lean:1-5`). Original namespace
  (`Bimodal.Metalogic.WeakCanonical.Kamp`) kept unchanged.
- Added module `Boneyard/MergedBracketQuarantine/README.md`.
- Added an inventory row to `Boneyard/README.md` (after KampNegationClosure).
- No `lakefile.lean` edit needed — `BoneyardArchive` uses a recursive
  `.submodules Bimodal.Boneyard` glob.
- Confirmed the archived file is inert under `BoneyardArchive` (build exit 0; only the expected
  `using 'exit' to interrupt Lean` warning at line 6).

### Phase 3 — Final verification and scope audit
- Default `lake build` exit 0 (1719 jobs).
- Axiom-clean check via `lean_verify` on two KampPrior-facing public bridge decls:
  - `bracketEndChar_kv_correct_zero_prior` (PriorInterface): `{propext, Classical.choice, Quot.sound}`
  - `bracketEndChar_kv_correct_one` (CarrierKv): `{propext, Classical.choice, Quot.sound}`
  - No `sorryAx`, no new axioms — profile unchanged (as expected; no live decl referenced any
    MergedQuarantine symbol).
- Git diff scope audit (against true base `d62d5949e`) — exactly:
  the renamed file, the new `Boneyard/MergedBracketQuarantine/README.md`, the `Boneyard/README.md`
  row, and the `NfMultiAnchorBridge.lean` import removal. Nothing else in `Theories/`.
- Hard fences verified UNTOUCHED: `SharedWitness.lean`, `NavigatedSpine.lean`, `CarrierKv.lean`
  (`nfk_projFresh` at :82 still live).

## Verification Results

| Check | Result |
|-------|--------|
| Default `lake build` | exit 0 (1719 jobs) |
| New sorries (live edits) | 0 |
| Vacuous definitions | 0 |
| New axioms | 0 |
| Public-API axiom profile | unchanged (propext, Classical.choice, Quot.sound) |
| Original path removed | yes |
| Boneyard path present | yes |
| Hard fences untouched | SharedWitness / NavigatedSpine / CarrierKv all clean |

## Plan Deviations

- None (implementation followed plan). Option B disposition executed exactly as specified; the
  only clarification recorded is that no `lakefile.lean` change was required because
  `BoneyardArchive` already discovers the new file via its recursive submodule glob.

## Artifacts

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — import line removed.
- `Theories/Bimodal/Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean` — relocated,
  `#exit`-headed.
- `Theories/Bimodal/Boneyard/MergedBracketQuarantine/README.md` — new module README.
- `Theories/Bimodal/Boneyard/README.md` — inventory row added.
- `plans/01_boneyard-sweep.md` — phase markers set to [COMPLETED].
- `summaries/01_boneyard-sweep-summary.md` — this file.
