# Handoff — Phase 5 closing (fourth implementation dispatch)

- **Task**: 291 — upgrade_lean_toolchain_to_v431_and_mathlib
- **Session**: `sess_1784987503_5e1100`
- **HEAD at handoff**: `06ef4e29a`
- **Tree state**: clean except `specs/TODO.md`, `specs/state.json`, `specs/events.jsonl`, which
  were already modified before this dispatch and are not mine to stage.

## Where things stand

| Measure | Start of dispatch | End of dispatch |
|---|---|---|
| `Theories/` modules elaborating | 373 / 430 | **430 / 430** (projected; full build confirming) |
| Modules blocked behind a failure | 57 | **0** |
| Files with errors | 1 (`Kamp/ExteriorNegation.lean`) | **0** |
| New `sorry` | 0 | **0** |
| New axioms | 0 | **0** |
| `set_option backward.*` | 0 | **0** |
| `set_option maxHeartbeats` sites | 88 | **88** (unchanged) |
| Source files repaired this dispatch | — | 3 |

Three files were repaired, not one. `Kamp/ExteriorNegationPast.lean` and
`Expressiveness/SplitPoint.lean` had been sitting behind `Kamp/ExteriorNegation.lean` and only
became visible once it went green — the same "every rise is a newly-reached module" dynamic the
previous handoffs recorded, now playing out one last time. Each of the three is confirmed green
by its own scoped `lake build`.

## The specified `zoneCons` fix was NOT landed — read this before re-proposing it

The previous handoff specified a `zoneCons` helper in `Kamp/NfEFold.lean` (the `orderedSumPt`
pattern applied to `Fin.cons` at `ZoneSpec`) plus an `@[simp] zoneCons_eq` bridge. **It does not
work, and it should not be retried.** Two independent reasons:

1. **The bridge undoes the fix.** `zoneCons_eq : zoneCons p zs = Fin.cons p zs` is needed because
   the goal side produces bare `Fin.cons` (via `Fin.cons_self_tail`). As a `@[simp]` lemma it
   rewrites the list entries *back* into the untraversable `Fin.cons` form — so `simp` stalls one
   step later than before, not zero steps later. Stating it in the reverse direction does not help
   either: the LHS pattern is then exactly the term that fails to match at reducible transparency.
2. **Blast radius.** `ZoneSpec` lives in `NfEFold.lean`; touching it invalidates every module that
   imports it, which is most of `Kamp/`.

**What was landed instead**: local, term-level membership certificates next to each list literal.
`exact`/`apply` check at `default` transparency, where `ZoneSpec` unfolds and the literal is
perfectly well-typed, so no goal-side normalisation is needed at all:

- introduction: `List.Mem.head _`, nested `List.Mem.tail _ (…)` (one `tail` per index)
- elimination: `List.mem_cons.mp h` applied as a **term**, chained, `List.mem_singleton.mp` last

Five lemmas per side (`_mem_below`/`_mem_above`, `_mem_gap`, `_mem_self`, `_mem_ray`, `_cases`).
The call sites keep their original `rcases … with rfl | rfl | …` shape, so the nine downstream
bullet bodies in each file are untouched. Full rationale, including the rejected alternative, is
inventory row **N16**.

## New taxonomy rows added this dispatch (N16-N19)

- **N16** — list literals of `Fin.cons p (zs : ZoneSpec k)` are untraversable as a *whole*: `simp`
  makes no progress, and a half-applied `simp only … at h` makes the following `rcases` report
  *"`[Fin.cons …, …]` is not a free variable"* — a message that names a list, not a hypothesis,
  and reads like a `rcases` arity bug. It is not; it is the `simp` above it.
- **N17** — `Set.ne_univ_iff_exists_not_mem` -> `Set.ne_univ_iff_exists_notMem` (Mathlib's
  `not_mem` -> `notMem` sweep; deleted outright, so `Unknown constant`, not a deprecation).
- **N18** — `push_neg` / `rw [not_le]` no longer fire at a semireducible carrier type. Bind
  through an **ascribed** `have` with `not_le.mp`. Note the consumer needs the same treatment:
  `p ∈ g.val.cut` and `extendPoint p ≤ Sum.inr g` are likewise only definitionally equal, so
  writing `le_of_lt h` straight into a `p ∈ g.val.cut`-typed `have` still fails. `lt_of_not_le`
  is gone; use `not_le.mp` or `lt_of_not_ge`.
- **N19** — `simp [f]` no longer discharges `Sum.inl _ ≠ Sum.inr _` after unfolding `f`; use
  `exact Sum.inl_ne_inr`. Same family: `simp [IsGap]` leaves both existentials.
  **Read the witness type off the `def`, not off the `simp`-printed goal** — `IsGap e` is
  `∃ g : RDefinableGap …, e = Sum.inr g` (one existential over a subtype), but `simp` prints it
  already split into two binders. Writing the term against the printed form gives the misleading
  pair `Application type mismatch` + `` Constructor `Eq.refl` does not have explicit fields, but 2
  were provided ``.

## Phase status

- Phases 1-4: `[COMPLETED]`.
- Phase 5: all known defeq/transparency breakage cleared; close as `[COMPLETED]` once the full
  build confirms.
- Phase 6: **zero `(deterministic) timeout` errors** corpus-wide and **no** `maxHeartbeats` value
  changed (88 sites, unchanged from baseline). The plan rated this the second-highest cost risk;
  it did not materialise. Close as a verified no-op, recording the grep on the final green build.
- Phase 7: its residue was exactly the three files above. Close with Phase 5.
- Phases 8-10: `[NOT STARTED]` — and Phase 8 is the one that matters. A green build cannot detect
  the Lean 4.32 nested-`return` semantic change; that phase exists precisely because
  "`lake build` passes" is not this task's definition of done.

## Verification commands

```bash
lake build                                                    # full
grep -c 'deterministic) timeout' <build.log>                  # Phase 6 gate; currently 0
git diff 29b9cea6f -- Theories/ | grep '^+' | grep -c sorry   # zero-debt gate; currently 0
grep -rn 'set_option backward' Theories/ Tests/ | wc -l       # currently 0
bash baseline/compare-exes.sh baseline/exe <new-capture>      # Phase 8 gate
```

Note the two greps that need care: `grep -rn '^axiom ' Theories/` returns 2 hits that are prose
inside docstrings, not declarations; and the vacuous-definition grep returns
`Examples/TemporalStructures.lean:269`, which is pre-existing (last touched in `21adc2281`) and
not this task's doing. Both are zero in substance.
