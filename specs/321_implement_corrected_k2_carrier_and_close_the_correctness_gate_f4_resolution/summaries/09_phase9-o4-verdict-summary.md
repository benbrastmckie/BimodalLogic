# Phase 9 Summary — Carrier-Side Per-σ `hgate` Derivation (O4): VERDICT = FAIL

- **Task**: 321 — Implement corrected k=2 carrier and close the correctness gate (F4 resolution)
- **Phase**: 9 of 13 (O4, MAKE-OR-BREAK, one dedicated dispatch — hard cap honored)
- **Session**: sess_1783487859_3f6358 (2026-07-07)
- **Outcome**: **O4 FAIL** — an honest, evidenced verdict, which is the phase's sanctioned
  success mode ("an incomplete O4 goes to Phase 10 as a FAIL, with the failing goal captured
  as an inert record"). Phase heading marked [COMPLETED].
- **Commits**: `7488001ec` (derivable core), `e79da7f94` (crux capture + inert record)

## What landed (sorry-free, axiom-clean, purely additive to `SharedWitness.lean`)

| Object | Role | Axioms |
|--------|------|--------|
| `kvE2_sep_zone4_consistent` | PUBLIC N-point re-derivation of the private `kvE_sub2V_zone_consistent` template (plan task 1): any zone realized over `[x1,w,x,t]` under `x<x1<w<t` is in the named nine-zone set `kvE2_sepInnerConsistentL` | `[propext, Classical.choice, Quot.sound]` |
| `kvE2_sepHgate_offFiber` | `hgate` off-fiber conjunct (`SubBracket2V.lean:1872`) from gate clause (iii) | `[propext, Quot.sound]` |
| `kvE2_sepHgate_innerNine` | Gate clause (iv) surfaced: inner nine-zone falsity for left-interior positives | `[propext, Quot.sound]` |
| `kvE2_sepSegForm_excludes` | Cor 5.4 segment channel: realized exclusion segment + bit-false ⇒ ¬`charBase χ` at the point | `[propext, Classical.choice, Quot.sound]` |
| O4 CRUX RECORD (inert doc block) | Captured crux goal, five failed closers, channel-exhaustion argument, no-additive-repair analysis, N2 consequence | — |

## The verdict and its evidence

Five of the six `hgate` conjuncts (`SubBracket2V.lean:1868-1882`) are determined at the
extracted anchor by: the lemmas above, the `kvE2_sepLit` biconditional endpoint/witness
literals (`zPastX4`/`zAtX4`/`zAtX1L`/`zAtWL`/`zAtT4`/`zFutT4`, both directions), and σ's own
slot enumeration. The **forward-zone conjunct fails** at cross-σ slot points: with distinct
left-interior positives σ ≠ τ and τ's `zXU`-positive χ-slot interleaved below σ's fresh slot
(cross-σ order is free in `kvE2_sepSlotLe`), every realization places a χ-point `v` in σ's
`zXU` zone, and the required `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` has no carrier
channel:

- all four `kvE2_sepGate` clauses conclude `= false` (polarity exhaustion, machine-verified
  by the `simp_all` closer unfolding);
- the segment contrapositive fires only on OPEN refined sub-intervals — `v` is a bracket
  point between segments (the exact residue both prior handoffs flagged);
- the biconditional literals never cover the three open interior regions.

Probed with the FULL hypothesis superset (the realized disjunct `h` itself + gate + all
Phase-8-extracted facts), so the failure is not attributable to a dropped input. Five failed
closers captured verbatim (task-327 evidence style). A second, independent obstruction blocks
the ∀-anchor form: `a < w` is unprovable (right-region segments exclude only depth-0
1-types, never the `charK` E[Σ]-atom).

No additive repair exists within scope: the conjunctive cross-σ gate clause is not
honest-derivable (breaks `kvE2_sepGate_holds_of_honest` + non-vacuity, FM-vac); the
disjunctive one is arrangement-blind; the faithful repair (bit-compatibility filtering of
the interleaving enumeration) re-defines the Phase 7 carrier — routed to the Phase 10 gate.

## Verification (final suite)

| Check | Result |
|-------|--------|
| `lake build` (full) | green (1720 jobs) |
| Sorry census (`lean-sorry-census.sh`) | 0 in `SharedWitness.lean`; inventory empty |
| Vacuous defs | 0 introduced (single repo hit pre-existing, untouched) |
| New axioms | 0 (baseline unchanged) |
| Litmus (`x1 < e_i`) | 0 live hits (doc-comment rule quotations only) |
| `git diff --stat` scope | `SharedWitness.lean` + plan file only (additive) |
| Prohibited-on-failure patterns | none: no sorry, no chain splicing, no `x1 < e_i`, no gate-modulo-assumed-`hgate`, no placeholder; probe deleted before commit |

## Plan deviations

- Task 2 (per-σ zone biconditionals) annotated FAILED-at-crux inline; partial dischargers
  landed; the rest is the FAIL evidence, per the phase's own contingency clause.
- Tasks 1 and 3 completed as specified.

## Phase 10 input

**FAIL on O4 → N2** per the plan's routing table. Everything Phase 10 needs is consolidated
in `handoffs/phase-9-handoff-20260707.md` and the in-file O4 CRUX RECORD.
