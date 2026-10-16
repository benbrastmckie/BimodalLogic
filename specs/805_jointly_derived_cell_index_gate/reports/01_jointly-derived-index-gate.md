# Research Report: Jointly derived cell index — the falsification gate

- **Task**: 805 — Gate the formula-coupled residue index against the five-part falsification table
- **Date**: 2026-10-16
- **Status**: seed report (round 0). Written at task creation from the parent record's blocker
  analysis plus a direct verification pass over the tree. No new mathematics is claimed here; the
  deliverable of round 1 is the gate run itself.
- **Parent**: 761 — ladder realization theorem
- **Companion**: `specs/761_ladder_realization_theorem/reports/02_spawn-analysis.md` (the blocker
  analysis; this report is its task-side seed and does not restate its precedent accounting)

## 1. What this task exists to settle

`cellAt` must factor through some computable index of ladder states, or `ladderRealized` and
`LadderCons`'s `box`/`stab` acceptance clause cannot be **stated** — not merely cannot be proved.
The positive factorization lemma

```
ladderIndex … x = ladderIndex … y  →  cellAt M φ (t, x) z = cellAt M φ (t, y) z
```

is claimed nowhere in the tree, in any shape, for any index. This task takes the one candidate
shape the governing guidance names as ungated — parameters `(T, P, B)` derived from the object
**and** the formula jointly — and runs it through the five-part falsification gate **before** any
sufficiency attempt.

A refutation is a successful outcome and is to be reported as one. Both predecessor records closed
that way. What is forbidden is a weakened, same-named substitute for `ladderRealized` or
`LadderCons`.

## 2. Verified starting state

Every row below was checked against the tree on 2026-10-16. Re-check cheaply; do not re-derive.

| Claim | Verification |
|---|---|
| `truncate` is defined nowhere in `FormalSystem/` | `grep -rn 'truncate' --include=*.lean FormalSystem` returns only the English word "truncates" in `Expressiveness/Kamp/` modules. The `[Fintype Q]` obligation in the filed `ladderRealized` has no carrier. |
| The ladder carrier is infinite | `Rlad_slice_infinite` (`RaySummary/RunLayer.lean`); `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` (`LadderModel.lean`) |
| The set of cells is finite and bounded | `anchorCells_finite`, `anchorCells_ncard_le : ≤ 2 ^ (2 ^ |cl φ|)` (`RaySummary/AnchorLayer.lean`) — untouched, still hold, and **not** what is open |
| `ladderCell_stabilizes` is refuted and deleted | no declaration of that name exists; `cell_ne` is proved at `ladder-cell-refutation.lean:453` |
| `stab`'s clause is the collapse mechanism | `FormalSystem/PlusLanguage/PlusTruth.lean:93` — `| .stab φ => ∀ σ, τ.state t = σ.state t → PlusTruthAt M σ t φ` |
| `Drift` moves the next deadline by ±1 per step | `Drift (n n' : ℕ) : Prop := n' = n ∨ n' = n + 1 ∨ n' + 1 = n` (`RunLayer.lean:254`) |
| `Count`'s no-early-discharge clause | `count_tt : Count true true c n c' ↔ c' + 1 = c` — so a region's countdown runs to `0` exactly and its first idle state sits at distance exactly `c + 1` |
| The gate note is readable from this repo | `.claude/context/project/lean4/domain/ladder-counter-observables.md` (deployed, ~15KB) |
| The letter-restricted periodicity prototype survives archival | `specs/archive/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean`, alongside `residue-index-gate.lean` and `gap-index-test.lean` |
| The refutation probes are wired | `scripts/check-evidence-probes.sh` carries the wired-probe table (33 entries at the fifteenth probe's landing) |

## 3. Why each coordinate's origin is forced

The parameter-origin rule in the gate note is **necessary**, each clause by a refutation, and its
sufficiency is **open**. The mechanism behind it, stated once so the gate run is not flown blind:

- The step relation is independent of the counters, so it may compute anything along a pending
  region and deposit the result on the state that ends it. That deposit is visible to a formula at
  the region's start under a single `untl`, at distance `c + 1`. **Clipping `c` destroys exactly
  the information that locates that state.**
- A hypothesis of the shape `B ≤ c, c', n, n'` bounds each counter separately and **never their
  difference**, which is why every independently-clipped-counter candidate fails and why `cell_ne`
  is uniform in `B`.
- The idle interval between regions may be of any length (`Count false false` pins the countdown
  at `0`) while `Drift` moves the next deadline one step at a time, so every next-deadline value
  is reachable before the following region starts and `Count false true` hands it to the new region
  as its length.

Hence: `B` from the formula's `X`-nesting depth **and** its `snce`-nesting depth; `T` at least the
formula's `untl`-nesting depth; `P + 1` a multiple of the period of every **letter-definable**
sub-object — a divisibility condition, not a magnitude one (a modulus of `100` fails where
`3 ∤ P + 1`). Instantiation convention: `P := m − 1` for modulus `m` with `1 ≤ m`, and `2 ≤ m` is
forced, since at `m = 1` both residue coordinates are constant and the index collapses to the
already-refuted clipped-coordinate candidate.

## 4. The gate, and the discipline it encodes

Run all five as compiled theorems before any sufficiency attempt. Gates 4 and 5 must be **rebuilt
against the formula-derived `T` and `B`** — in the refuted predecessor they were stated against
object-exhibited parameters, which is precisely what they refuted.

| Gate | Separation pair | Mechanism |
|---|---|---|
| 1 | `(B, B+1)` vs `(B, B+2)` | small gap at large counters |
| 2 | `(2B, 4B+2)` vs `(2B+1, 4B+2)` | consecutive countdowns, equal next-deadlines, both gaps saturating the clip |
| 3 | one region further out, and in the past direction | survives a second region boundary and a `snce`-reachable region start |
| 4 | `(q, T, n)` vs `(q, T+(P+1), n)` at `n = T+(P+1)+B`, under `X^(T+1) r` | is the threshold at least the formula's `untl`-nesting depth? |
| 5 | coprime-cycle object: `(a, 3(P+1)(T+1), n)` vs `(a, 3(P+1)(T+1)+(P+1), n)`, under `p U (r ∧ ℓ_a)` with `⊤ U ℓ_d` in the closure | is the modulus a multiple of every letter-definable sub-object's period? |

**A gate probing one coordinate certifies one coordinate.** The counter-pair candidate passed a
sound, non-vacuous one-part gate on mechanism (1) and died at mechanism (2); the residue candidate
passed gates 1–3 and died at 4 and 5. Passing a gate says only that one mechanism does not lift.

## 5. Round 1, in order

1. **Correct or delete** `specs/761_ladder_realization_theorem/.blocker-research.json`. It is dated
   2026-10-11, predates the fourteenth wired probe, and its `solution_path` recommends the
   gap-carrying candidate that `ladder-cell-index-obstructions.lean` has since refuted
   (`exhibited_form_refuted`, `exists_form_refuted`, `cell_succ_ne`). Left standing, it routes the
   next reader into a dead candidate. Do this first; it is cheap and it is a live trap.
2. **Define** the jointly derived candidate, with each parameter's origin stated at its definition
   site, not in prose: `B` from φ's `X`- and `snce`-nesting depth, `T` from φ's `untl`-nesting
   depth, `P + 1` from a letter-restricted variant of `reachN_eventually_periodic` (port the
   archived prototype rather than re-deriving it).
3. **Gate** it — all five rows, as compiled theorems, gates 4 and 5 rebuilt against the
   formula-derived parameters.
4. **Report the verdict** as a wired evidence probe under
   `specs/evidence/seam-gluing-ray-product/`, following the thirteenth–fifteenth probes' header
   convention (what was asked; what is settled or why no statement exists; what the probe does
   **not** say), registered in `scripts/check-evidence-probes.sh`. Zero `sorry`, zero `axiom`, no
   `native_decide`, as every predecessor probe in this family.
5. **Only if the gate is survived**, attempt the positive factorization lemma, carrying these four
   obligations verbatim as what it must meet: (a) eventual periodicity of the realizable types in
   the countdown over the product of the object with the closure; (b) a region-length pumping lemma
   for `untl`/`snce`-depth-bounded formulas; (c) the next deadline's coupling through `Drift`;
   (d) the `box`/`stab` letters through the anchor-layer equations (`box_mem_tpOf_iff`,
   `stab_mem_tpOf_iff`). If that is not costable in the round, name them as the next round's scope.
   Do not state a `LadderCons` without the `box`/`stab` clause: `stab_mem_tpOf_iff` pins that
   letter per cell, so dropping it publishes a same-named weaker statement.

## 6. Scope boundaries

- **No edits under `FormalSystem/` or `Tests/`.** Probes and reports live under this task's own
  directory and `specs/evidence/seam-gluing-ray-product/`.
- **What is positively proved so far is fixture-level only**: `qp_cell_eq_of_depth_parity` on the
  two-state object for `box`/`stab`-free φ, where every history through a pending state is forced
  onto one object path (`qp_forced_path`). The general object has region restarts and its histories
  through a pending state do not share an object path, so this is explicitly not the factorization
  lemma and must not be cited as partial credit toward it.
- **The guidance note is source-store-bound.** If the gate run changes what
  `ladder-counter-observables.md` should say, the edit target is
  `~/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`,
  never the deployed `.claude/` mirror, per `.claude/rules/source-store-deploy-boundary.md`. That
  path is outside this repository, so it cannot be committed by this repo's scoped-commit path —
  commit it in the source store separately, as the fifteenth probe's record did.
- **Do not re-attack** the finiteness of the set of cells, and do not widen the tuple in response to
  a refutation. If this candidate falls, the successor direction already on record is a set-valued
  per-state datum over a quotient, not a sixth or seventh coordinate.

## 7. Open question this task does not own

Whether the index is reachable at all is open. If the gate refutes the jointly derived candidate,
every index shape the current guidance anticipates is spent, and the choice returns to the parent
record's standing alternatives: a set-valued per-state datum over a quotient, or the index-free,
`box`/`stab`-free run-layer half (R2) under an honest name, retaining `slive` and replacing only
`ulive` — the ladder's structural liveness being forward-only
(`ladder-liveness-forward-only.lean`, `gPast_isPath`). That choice is a user ruling, not this
task's to make.
