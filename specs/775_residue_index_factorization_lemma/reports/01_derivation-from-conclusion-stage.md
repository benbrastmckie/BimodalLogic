# Derivation Note: Residue-Carrying Cell Index Factorization

**Origin**: `/orchestrate` conclusion stage, channel (c). This task was not researched from
scratch — it was derived from a parent task's issue log and from two machine-checked Lean
artifacts that already exist in the tree. This note records that evidence so the planning phase
has grounding; it is not a substitute for the proof research the task itself calls for.

## Cited Evidence

- `specs/773_ladder_cell_index_factorization/issues.jsonl`, entry `iss_1791779768168_jUhN7G`
  (class `design-record defect or ambiguity`, severity `costly`, resolution `worked_around`).
- `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean` — the fourteenth
  wired evidence probe (1027 lines), tracked and wired, `check-evidence-probes.sh` PASS.
- `specs/773_ladder_cell_index_factorization/summaries/01_cell-index-coordinate-obstructions-summary.md`.

## What Is Already Settled (Negatively)

The gap-carrying three-coordinate index `(q, min c B, min n B, clip (n - c) [-B, B])` and its
factorization lemma are **refuted uniformly in `B`**, at two independent coordinates:

1. The gap coordinate, by the earlier refutation that remains retained.
2. The countdown coordinate — `Count true true` admits no early discharge, so a pending region's
   first idle state sits at distance exactly `c + 1`; `step` is independent of the counters, so
   it alternates a tag per pending step and copies it onto that state, making `p U (r ∧ a)` read
   `c mod 2` at a distance no bound on `c` reaches. The witnessing pair carries equal
   next-deadlines with both gaps saturating the clip, so this is the countdown failing, not the
   gap.

The bounded-carrier alternative (bound the carrier instead of indexing it) is closed as a general
route by a landed derivation: a deadline-bounded ladder sub-carrier is finite,
`ofSlicedStepFinBranch = FrameOver.ofSlicedStep` by `rfl` on a finite carrier, so
`no_finite_width_sat` applies and every bounded-deadline ladder model validates `Φ.neg` — while
`Φ.neg` is a ℤ-time non-validity.

## What Is Open — This Task's Subject

The re-scoped six-coordinate index

```
ladderIndexRes T P B : (q, min c T, c % (P+1), min n T, n % (P+1), clip (n - c) [-B, B])
```

survives all three falsification gates (the known gap pair; the parity pair at a symbolic
modulus; a third gate run one region out and in the past), and its threshold `T` and period `P`
are **exhibited from the object** (eventual periodicity of step-reachability) rather than
assumed. The positive factorization lemma over this index is recorded as OPEN and is **stated
nowhere** in any shape — no `sorry`, no axiom, no same-named weaker restatement.

This task attempts that factorization, or settles it negatively as its predecessor settled the
three-coordinate candidate.

## Known Obstruction To Design Around

Surviving the gates is not evidence of truth. One mechanism is already measured and must be
respected by any proof attempt: `Count false false` holds the countdown at `0` through an idle
interval of any length while `Drift` moves the next deadline freely, so every second-region
length is reachable from every pending state (`second_region_any_length`) — the achievable
second-region-end tag set is everything, independently of `T`, `P` and `B`. There is no
achievable "window" positioned by the residue coordinates to argue from.

A negative result here is a successful outcome, on the same terms as the predecessor's.
