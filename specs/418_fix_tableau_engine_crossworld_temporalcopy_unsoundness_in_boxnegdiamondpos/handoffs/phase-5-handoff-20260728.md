# Phase 5 Handoff — Task 418

## State

Phases 1-5 [COMPLETED] and committed. Phase 6 [IN PROGRESS].

| Commit | Phase |
|---|---|
| `c2a25cfb5` | Phase 3 — the engine fix (`Tableau.lean`) |
| `6b2be0db8` | Phase 4 — library build green, simp-list pruning, bridge prose |
| `243a6cc89` | Phase 5 — `boxAnchoredCheck` finding |

## Immediate next action

Phase 6: read `artifacts/after-corpus-raw.log` (a background `lake build BimodalTest` is
producing it) and `artifacts/after-corpus-bracket.txt` (olean bracketing + RC). Then build each
of the eight probe modules individually to surface every mismatch, and write
`artifacts/after-verdicts.md`. **Do not edit any test file in Phase 6** — Phase 7 adjudicates.

## Key measurements already in hand

- Library `lake build`: **green**, RC 0, 1983 jobs, zero errors, zero repairs needed.
  Investigation's "zero compile-time breakage" prediction confirmed exactly.
- `Verified/Decidable.lean` **not modified**; `Verified/` still has zero term-level `sorry`.
- Corpus row count is **142** directives, not the plan's 145 (3 of the 145 grep hits are prose).
- `boxAnchoredCheck` rows A/B/C: `true → false`. **`boxGridCheck` also `true → false`** — beyond
  what the plan predicted, and it closes repair option (c).
- Row C `|T|` moved 10 → 8; rows A/B keep `|W|=2 |T|=7`.
- Minted world contents (row A): `Gp@w1=false Hp@w1=false p@w1=true boxp@w1=false`.
- Mechanism claim **refined**: nested `T(□□χ)` still reaches a fresh world with `T(Gχ)` via
  `boxProps` + `boxTemporal`. Corroborated by `Saturation.lean` MT4/MT6 still printing PASS.
- Carrier list: 14 sites; plan over-counted `IntTruth.lean` by one (line 366 is not a carrier)
  and missed `sat_box_grid_of_anchored`.

## Pending background measurement

`scratch_418_gp.lean` (`lake env lean`, output `scratchpad/gp.out`) measures the headline row
`(G p) → □(G p)`: `buildTableau` at fuel 100 and 1000, and `decide`. This is a **Phase 6** task.

## Scratch files to delete before the final commit

`scratch_418_probe.lean`, `scratch_418_anchor.lean`, `scratch_418_gp.lean` (repo root, untracked).

## Standing constraints

- Never `lake clean`. Lock at `.lake/.task-418-build.lock`.
- An interrupted build is INCONCLUSIVE — retry, never record. (This already happened once: a
  10-minute foreground timeout killed a corpus build and dropped the olean count 405 → 398.)
- Do not edit `Verified/Decidable.lean`. Do not add any replacement propagation block.
- Do not weaken or delete a `#guard_msgs` row to make it pass.
