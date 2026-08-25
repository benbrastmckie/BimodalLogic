# Task 413 — Phase 1 handoff

**Phase 1 (BL syntax) COMPLETED.** `lake build` full green.

## Landed
- `FormalSystem/BaseLanguage/Formula.lean` — `BLFormula` (6 ctors: atom/bot/imp/box/allPast/allFuture),
  derived ops (`top`,`neg`,`and`,`or`,`iff`,`diamond`,`somePast`,`someFuture`,`always`),
  `swapBL`, `swapBL_involution` (`#print axioms` = `[propext]`), push-through simp lemmas,
  `atom_injective`. Instances: `Repr, DecidableEq, BEq, Hashable, Countable`.
- `FormalSystem/BaseLanguage.lean` — aggregator, four later imports present but commented out.
- `FormalSystem/FormalSystem.lean` — one import line + one `## Components` bullet.

## Key decisions
- `always φ = φ.allPast.and (φ.and φ.allFuture)` mirrors `Formula.always` association exactly,
  so CO's translation lines up with `Formula.co` without reassociation.
- `somePast φ = (φ.neg.allPast).neg` (H/G primitive, P/F derived) — the polarity the paper's
  `\Past`/`\past` distinction demands.

## Next action
Phase 5 (DF at `FrameClass.Discrete`) — the one genuine unknown. Route A decomposition
verified on paper (see phase-5 handoff once written).
