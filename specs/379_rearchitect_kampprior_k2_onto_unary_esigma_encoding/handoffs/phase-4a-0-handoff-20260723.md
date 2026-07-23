# Phase 4a-0 handoff + 4a-1 BLOCKER

- **Task**: 379 — additive-bridge migration (plan v23)
- **Session**: sess_1784829998_2462de
- **Date**: 2026-07-23
- **Commit**: `a22315433` (task 379 phase 4a-0)

## What landed (green)

Phase **4a-0 COMPLETE**. New off-path file
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PerFormulaType.lean`:

- Promoted `UnaryTypeFin` / `partialHolds` / `charTypeFin` / `partialHolds_charTypeFin` out of the
  Phase-1 gate `InfAlphabetProbe.lean` (which now `import`s `PerFormulaType` and no longer duplicates
  them).
- Added `IntervalTypeFin M := Finset (UnaryTypeFin sig F M)` + `intervalHoldsFin`.
- Added restriction/weakening maps `restrict` (total→partial) and `weaken` (M'→M, `M ⊆ M'`).
- Added the finite-alphabet `completions` bridge: `completions c := Finset.univ.filter (fun τ => ∀ a ∈ M, τ a = c a)`,
  `mem_completions`, and the bridge lemma **`intervalHolds_completions_iff`**
  (`intervalHolds N (completions c) y ↔ partialHolds N c y`) — forward restricts a realized completion
  to `M`; reverse uses `nf_characteristic N 0 1 (fun _ => y)` as the total witness.
- The three bridge decls carry `[Fintype sig.preds] [DecidableEq sig.preds]` (feeding
  `sigE_fintypePreds` / `sigE_decEqPreds`), because Phase 2 removed those as `MonadicSignature` fields.

Verification: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PerFormulaType` green; full `lake build`
EXIT 0 (1770 jobs); spine untouched (git shows only off-path files changed) so
`#print axioms completeness_discrete` is unchanged from baseline.

## Immediate next action: DO NOT proceed to 4a-1 — plan premise refuted

Phase **4a-1 is BLOCKED** (see plan file, Phase 4a-1 heading + BLOCKER block). The additive-bridge
migration cannot proceed as written.

### The blocker in one line

Report 22 §3's "17 Kamp files at **green** HEAD" is **false**: 12 of the ~15 exists-forall consumer
files are **RED at HEAD**. They are off the default `lake build` target, so the spine's green build
(EXIT 0) masked it. Phase 2's `Fintype`/`DecidableEq`-field-removal cascade was threaded only into the
~45 spine files, never into this off-path chain.

### Ground-truth build state (per-file `lake build Kamp.<file>`)

- **GREEN**: `ExistsForallFormula`, `IntervalType`, `ExistsForallLemmas`, `PerFormulaType` (new).
- **RED (12)**: `ConjInterleave`, `Prop35ExistsForall`, `Prop35Assembly`, `Prop35Chain`, `LiftPair`,
  `Prop42ExistsForall`, `EFSatNegationGeneral`, `VeeSatNegation`, `VVecEA2Collapse`, `Prop43Translate`,
  `ESigmaCapture`, `ZetaAtomMapReconcile`.

### Error census (why they are red)

1. **Un-threaded instances (dominant, mechanical)**: `Fintype sig.preds`, `DecidableEq sig.preds`,
   `Decidable (…)`. E.g. `ConjInterleave` 5 Fintype + 2 Decidable; `EFSatNegationGeneral` /
   `VeeSatNegation` / `Prop43Translate` 6 Fintype + 2 Decidable each. Same repair Phase 2 applied to
   the spine files (add the two instance binders after each abstract-`sig` declaration).
2. **Pre-existing off-path `sorry`s**: `Prop35ExistsForall` 2, `Prop42ExistsForall` /
   `EFSatNegationGeneral` / `VeeSatNegation` / `Prop43Translate` 4 each. Not among the 3 "live"
   permitted sorries (report 20), but present. Phase 5's spine-wire would make them **live** — the
   amended sorry gate does not account for this.
3. **Genuine proof breakages (not instance-only)**: type mismatches, e.g. `ConjInterleave:888`
   (`intervalConj` expected type mismatch); `other=2` also in `LiftPair`, `EFSatNegationGeneral`,
   `VeeSatNegation`, `Prop43Translate`.

### What is needed (recommended plan revision)

Add a prerequisite phase BEFORE the additive-bridge migration — **"restore the off-path exists-forall
chain to green"**:

1. Finish Phase 2's `Fintype`/`DecidableEq` instance-threading across the 12 off-path files (mechanical).
2. Resolve the genuine proof breakages (`ConjInterleave:888` + the other `other=2` sites) — may need
   `/research` to scope.
3. Decide the disposition of the pre-existing off-path sorries (retire vs. fold into the sorry gate
   with justification) so Phase 5's spine-wire does not silently make them live.

Only then does the additive-bridge invariant ("add Fin-variants alongside UNTOUCHED total-type lemmas,
green at every commit") become executable. 4a-2's micro-gate needs `translateProp35` (in the RED
`Prop35Assembly`); 4a-4 migrates the RED files directly; 4b re-encodes the RED `LiftPair`.

**Surface for `/revise` (plan) and/or `/research` (proof-breakage sites).** Do NOT force past red
total-type lemmas with `sorry`, `def := True`, or a full-alphabet `Finset.univ`.

## Resume point

- Green HEAD = `a22315433`. Working tree clean of Lean changes (only pre-existing `.claude-extensions.json`,
  `README.md`, `specs/events.jsonl` remain, untouched by this session).
- `PerFormulaType.lean` (the bridge) is landed and available for the eventual 4a-3/4a-4 Fin-variant
  proofs once the chain is restored to green.
