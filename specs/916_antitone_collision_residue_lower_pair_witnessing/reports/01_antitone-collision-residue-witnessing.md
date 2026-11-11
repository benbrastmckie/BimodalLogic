# Research Report: Task #916

**Task**: 916 - Dispatch or compile a refutation of the ANTITONE slice of a kappa-class collision
**Started**: 2026-11-10T00:00:00Z
**Completed**: 2026-11-10T00:00:00Z
**Effort**: Medium (single-file read plus ten compiled arithmetic probes; no build run)
**Dependencies**: None (predecessor artifacts are landed and compiled)
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` (read in full, 1,323 lines)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` (anchor-collapse, `HasForwardSlack`, raise/delete transport, and the two exact-shift assemblies)
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (`kappa`, `clipIdx`, `CK`)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (the named-route record)
- Ten compiled arithmetic/`kappa` probes run this session through `lean_run_code` (all green)
- Mathlib search tools: not consulted (no Mathlib lemma is in question; every object is local)
**Artifacts**:
- `specs/916_antitone_collision_residue_lower_pair_witnessing/reports/01_antitone-collision-residue-witnessing.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The antitone slice is NOT a single object. It splits, along a compiled line, into a
  BOUNDED-DESCENT sub-slice and a DEEP-DESCENT residue**, and the two have different costs. The
  splitting quantity is the register's descent `n - n'` against the countdown's rise
  `m · (P + 1)`.
- **Both halves of the BOUNDED-DESCENT sub-slice (`n - n' <= m · (P + 1)`) are dispatchable, and
  neither needs the named route.** The upward half needs NO forward-slack hypothesis at all: the
  raise that widens `z`'s region by `m · (P + 1)` already buys exactly `m · (P + 1)` of forward
  slack from no hypothesis whatever — this is the landed, compiled
  `hasForwardSlack_raise_of_zero` — and that is precisely the currency the lowered anchor needs.
  The downward half needs `ForwardSlackWitnessed` at the higher pair at amount `m · (P + 1)`,
  which is *strictly cheaper* than the monotone slice's own downward half
  (`m · (P + 1) + (n' - n)`): a register RAISE inside the deletion is free in the direction that
  costs.
- **The named route is the right route for the DEEP-DESCENT residue only** (`n - n' > m · (P + 1)`),
  at exactly the amount `(n - n') - m · (P + 1)`, and the register-raise transport
  `hasForwardSlack_raise` carries it from the lower pair's path to the raised path verbatim.
- **The finding is not in tension with `free_register_anchor_clause_monotone_required`.** That
  record's witness has `mP = 0`, where the relaxed lower bound `nxtAt g z <= n_0 + m · (P + 1)`
  *is* the landed `nxtAt g z <= n_0`. The lower bound is non-removable, as compiled; what is new
  is that it is RELAXABLE by exactly the raise. A fresh probe compiles the relaxed bound as
  itself non-removable at a deep-descent witness, so the residue is a genuine gap rather than an
  artifact.
- **Recommended outcome: DISPATCH, not refutation**, in two stages — the bounded sub-slice
  unconditionally, the deep-descent residue under a lower-pair witnessing hypothesis of the named
  family. Zero sorries throughout; no new axiom; `cellLE_zero_const_of_kappa_eq` stays reserved.
- **One assembly-level exposure gap is the whole of the new construction work**:
  `exists_ladderPath_through_shifted_of_pend_past` discards the `habove` clause its own inner call
  returns, so the raise-bought slack is unreachable from its signature. The proven pattern for
  recovering it already exists verbatim at `LadderChain.lean:1979-1990`.

## Context & Scope

The dispatch asks for the ANTITONE slice of a `kappa`-class collision: the complement that
`cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` excludes in its own quantifier via
`MonotoneCollisionDisplacement`. The verified starting position given in the dispatch was
re-read against the source and holds as stated:

- `kappa_collision_monotone_or_antitone` (LadderCell.lean:627) makes monotone/antitone an
  exhaustive dichotomy with no third case, from the countdown residue alone (no `2 <= B`).
- `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` (LadderCell.lean:1295) dispatches the
  monotone slice as depth-0 cell EQUALITY; the antitone slice is excluded by the hypothesis
  `MonotoneCollisionDisplacement P c n c' n'`, not refuted.
- `kappa_collision_antitone_residue_nonvacuous` (LadderCell.lean:689) inhabits the excluded slice
  at `(4, 2)` against `(6, 0)`, `Tc = Tn = P = 0`, `B = 2`.
- `free_register_anchor_clause_monotone_required` (LadderCell.lean:387) compiles the lower bound
  `nxtAt g z <= n_0` of `exists_ladderPath_through_free_register_shifted_of_pend_past` as
  non-removable at `X = 19, nz = 8, cz = 10, mP = 0, n_0 = 0, d = 11`.

Scope held: the antitone slice only. The `ForwardSlackWitnessed` discharge (whether such a
hypothesis is satisfiable at any state the induction one layer up reaches) is a sibling's and is
not touched. `cellLE_zero_const_of_kappa_eq` is treated as reserved throughout and nothing below
is proposed under that name.

Evidence tier: lean-lsp was registered and reachable; all mechanical claims below are either
read directly out of source at a cited line or compiled this session as a standalone probe. No
claim below rests on an empty search result.

## Findings

### Codebase Patterns

#### F1. The two available moves are (countdown up, register up) and (countdown down, register down)

Reading the two assemblies the cell layer rests on:

| assembly | countdown | register | constraint |
|---|---|---|---|
| `exists_ladderPath_through_free_register_shifted_of_pend_past` (LadderCell.lean:298) | UP by `m · (P+1)` | free, but `nxtAt g z <= n_0` | `hlo` |
| `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` (LadderChain.lean:2104) | DOWN by `m · (P+1)` | free, but `n_0 + k = nxtAt g z` | `hk` |

So the register may move UP only when the countdown rises and DOWN only when it falls. That
conjunction *is* `MonotoneCollisionDisplacement`. The monotone slice is not a convenient
restriction of a general machine — it is the exact reach of the two machines as they stand.

#### F2. `HasForwardSlack` is one half of a two-sided collapse, and it is the half that pays for lowering

`anchor_clause_of_first_region_start` (LadderChain.lean:1144) reduces the anchor clause at EVERY
pin to a single TWO-SIDED bound at the nearest one:
`|nxtAt g s_0 - n| <= cntAt g z + I - l`, where `s_0 = z + cntAt g z + I` is the idle position
before the first region start above `z`'s region. The collapse runs on the Lipschitz triangle
plus pin compatibility, so the bound at the nearest pin propagates to all later pins.

`HasForwardSlack g z l n` (LadderChain.lean:1218) is exactly the UPPER direction of that bound.
Its own docstring states the lower direction follows from the consumer's gap `n + l <= cntAt g z`
alone. This is the mechanism by which the lowered deletion pays for its lowering: `hslack_0` in
that proof trades `HasForwardSlack g z (mP + k) (nxtAt g z)` for
`HasForwardSlack g z mP n_0` at `n_0 + k = nxtAt g z` in a one-line `omega`.

**Consequence**: forward slack is the currency of register LOWERING. A register RAISE in the
deletion direction, and a register LOWERING in the raise direction, are the two antitone moves —
and only one of them is priced in slack.

#### F3. The raise buys exactly `m · (P + 1)` of forward slack from nothing

`hasForwardSlack_raise` (LadderChain.lean:1348) and `hasForwardSlack_raise_of_zero`
(LadderChain.lean:1415) compile: raising `z`'s region by `d · l` increases the slack amount by
exactly `d · l`, and composed with the free baseline `hasForwardSlack_zero` this needs NO slack
hypothesis at all. Its own docstring states the accounting in full ("a raise ... increases the
amount by exactly `d · l` ... a raise-then-delete round trip at `z` is net zero").

This is the finding the named route did not anticipate. The free-anchor raise in LadderCell.lean
closes its anchor clause from `hpin_far` plus raw `nxtAt_lipschitz_two_sided`, which is why only
`nxtAt g z <= n_0` works there. But the raised path's register at a far pin is the ORIGINAL's
register `m · (P + 1)` closer to `z`, so the displaced Lipschitz bound is
`X <= nz + d - m · (P + 1)` — exactly `m · (P + 1)` better than raw Lipschitz — which is the
slack the raise bought, read at a pin instead of at a region start.

#### F4. The register's descent across a collision is itself a multiple of `P + 1`

`kappa`'s fourth coordinate is `n % (P + 1)` (CounterQuotient.lean:160), so a collision forces
`n = n' (mod P + 1)`. Compiled this session (probe 5, green): for every collision with `n' < n`
there is `j` with `n = n' + j · (P + 1)`. So the splitting condition
`n - n' <= m · (P + 1)` is exactly `j <= m`: a comparison of two integers, the countdown's
displacement multiplier against the register's.

#### F5. The antitone slice splits, and BOTH halves are non-empty inside the regime

Compiled this session, green:

- **probe 6** — `j = m = 2` at `(4, 2)` against `(6, 0)`, `Tc = Tn = P = 0`, `B = 2`: collides,
  sits in the pending-forever regime above the threshold, is NOT monotone, and satisfies
  `n - n' <= m · (P + 1)`. **The predecessor's own non-vacuity witness lies in the BOUNDED
  sub-slice.** This is a significant, non-obvious fact: the one antitone pair the landed record
  exhibits is in the half that needs no new hypothesis family.
- **probe 7** — `j = 8`, `m = 1` at `(10, 8)` against `(11, 0)`, same parameters: collides, in
  regime, not monotone, and `m · (P + 1) = 1 < 8 = n - n'`. So the bounded sub-slice does not
  exhaust the antitone slice and the deep-descent residue is genuinely inhabited.

#### F6. The BOUNDED-DESCENT upward half closes with no slack hypothesis

Compiled this session, green:

- **probe 1** — the anchor clause `|X - n_0| <= |d|` follows from `0 <= X`, the pin distance
  `cz + mP < d`, the displaced Lipschitz bound `X <= nz + d - mP`, the gap `nz + 2 <= cz`, the
  descent `n_0 + k = nz`, `k <= mP`, and the upper bound `n_0 <= cz + mP`.
- **probe 1b** — and the RAW Lipschitz bound `|X - nz| <= |d|` is NOT enough, even with
  `k <= mP`, at `X = 24, nz = 8, cz = 10, mP = 5, n_0 = 3, d = 16, k = 5`. So the displaced form
  (hence the raise's `habove` exposure clause) is load-bearing, not a convenience.
- **probes 2 and 3** — in the forward-slack formulation: the raise-bought regime at amount `mP`
  and register `nz` IS the regime at amount `0` and register `n_0` exactly when `k <= mP`
  (probe 2), and the two-sided `hfirst` obligation at deleted length `0` then closes from
  `0 <= Y`, `0 < I`, `n_0 <= cz_1` (probe 3). Both are one-line `omega`.

#### F7. The DOWNWARD antitone half is CHEAPER than the monotone downward half

Compiled this session, green:

- **probe 4** — the two-sided `hfirst` obligation at the RAISED anchor `n_0 >= nz` closes from
  `HasForwardSlack g z mP nz` alone, with no extra payment, given `n_0 + 2 + mP <= cz`.
- **probe 4b** — and the held-register exact-shift theorem's own inputs survive the raise:
  `n_0 + mP <= cz` and `Tc + mP <= cz` follow from `n_0 + 2 <= c`, `cz = c + mP`, `Tc <= c`.

Compare the amounts. Monotone downward (`mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact`,
LadderCell.lean) spends `m · (P + 1) + (n' - n)` with room `n' + (n' - n) <= c`. Antitone
downward spends `m · (P + 1)` with no room bound beyond the lower pair's own gap. **The register
raise is free in the direction that costs**, because lowering is what the upper direction of the
anchor clause charges for and a raise moves the other way.

The structural obstruction is therefore NOT arithmetic on this side — it is that
`exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` hard-codes
`hk : n_0 + k = nxtAt g z`, forcing `n_0 <= nxtAt g z`. A register-RAISING sibling is needed, and
its proof is the landed one with `hslack_0` replaced by the trivially weaker monotone-in-`n`
step probe 4 compiles.

#### F8. The relaxed lower bound is itself non-removable, so the deep-descent residue is real

Compiled this session, green:

- **probe 8** — the clause fails at `X = 19, nz = 8, cz = 10, mP = 1, n_0 = 0, d = 12` even WITH
  the displaced Lipschitz bound in hand. That witness is deep-descent (`k = 8 > 1 = mP`). So the
  relaxed bound `nxtAt g z <= n_0 + m · (P + 1)` is non-removable in exactly the way the landed
  bound is, and the deep-descent residue is not an artifact of the derivation.
- **probe 9** — the landed necessity record's own witness has `mP = 0` and `n_0 = 0 < 8 = nz`, so
  it fails the relaxed hypothesis too (`8 <= 0 + 0` is false). **No tension**: at `mP = 0` the
  relaxed bound IS the landed bound, and `free_register_anchor_clause_monotone_required` stays
  compiled and unamended.
- **probe 10** — with forward slack of amount `s` supplied at the LOWER pair and transported
  through the raise to amount `s + mP`, the clause closes for every descent `k <= mP + s`. At
  `s := (n - n') - m · (P + 1)` that is exactly the deep-descent residue. **The named route is
  the right route for the residue and only for the residue.**

#### F9. The one assembly-level exposure gap

`exists_ladderPath_through_shifted_of_pend_past` (LadderChain.lean:1016) exposes four clauses —
`objAt`, `cntAt`, `nxtAt` at `z`, and the type equality — and calls
`exists_ladderPath_through_iterSpliced_nxt_of_pend_past`, which itself DISCARDS (`-` pattern,
LadderChain.lean:1013) the `habove` clause that
`exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` (LadderChain.lean:854) returns. The
pigeonhole block `(u, l)` is also found internally and not exposed. So neither the raise-bought
slack nor the displaced Lipschitz bound is reachable from the landed signature.

The pattern for recovering it is already proven in the same file, at
`exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` (LadderChain.lean:1979-1990): call
the `_idx_` variant, assemble `hobj_above` from `hobj_1` plus `iterSpliceIdx_of_ge` and
`habove_1`, and feed `hasForwardSlack_raise`. Copying that five-line idiom into a
slack-exposing sibling of the regime-A raise is the whole of the new construction work.

### External Resources

No Mathlib declaration is in question. Every object in the argument is local to
`FormalSystem/Metalogic/Decidability/RaySummary/`, and the only Mathlib lemmas the existing
proofs consume on these paths are `Nat.modEq_iff_dvd'`, `Set.Subset.antisymm`, `Nat.find_spec`
and `Nat.find_min`, all already in use at the cited sites. `lean_leansearch` / `lean_loogle` /
`lean_leanfinder` were deliberately not called: there is no "find me a lemma" question here, and
spending a rate-limited search on a question the local source already answers would weaken rather
than strengthen the evidence tier.

Literature: the task is an internal arithmetic/assembly question about this repository's own
ladder construction. No literature source is referenced in the task description and none of the
106 indexed documents bears on it, so the Literature Extraction Protocol does not apply.

### Recommendations

Prioritized. A sorry-free path exists for every item; nothing below requires an axiom or a
deferral.

1. **(Highest) Expose the raise-bought slack.** Add a slack-exposing sibling of the regime-A
   raise — `exists_ladderPath_through_shifted_slack_of_pend_past` — returning the four landed
   clauses PLUS `HasForwardSlack g' z (m · (P + 1) + L) (nxtAt g z)` given
   `HasForwardSlack g z L (nxtAt g z)`. Body: the landed proof with the `_idx_` inner call and the
   `LadderChain.lean:1979-1990` idiom. The landed assembly is untouched and keeps its signature.
2. **Widen the free-anchor raise.** State
   `exists_ladderPath_through_free_register_shifted_slack_of_pend_past` with the lower bound
   relaxed to `nxtAt g z <= n_0 + (m · (P + 1) + L)`, closing the anchor clause through
   `anchor_clause_of_first_region_start` at `l := 0, a := z` (the lowered deletion's own pattern,
   LadderChain.lean:2140-2160) rather than through raw Lipschitz. At `L = 0` and
   `nxtAt g z <= n_0` this is the landed raise, hypothesis for hypothesis.
3. **Add the register-RAISING deletion.** A sibling of
   `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` with `hk` replaced by
   `nxtAt g z <= n_0` and `n_0 + 2 + m · (P + 1) <= cntAt g z`, slack amount `m · (P + 1)`
   unchanged. Proof: the landed one with the `hslack_0` trade replaced by probe 4's monotone-in-`n`
   step.
4. **Name the antitone shape and its split.** Define
   `AntitoneCollisionDisplacement P c n c' n'` as the compiled complement
   `kappa_collision_monotone_or_antitone` already produces, and `BoundedDescent` /
   deep-descent as the `n - n' <= m · (P + 1)` split. Land probes 5, 6, 7 as the three records
   that keep the split from being tacit — a multiple-of-`P+1` destructor for the descent, plus
   one non-vacuity witness on each side.
5. **Dispatch the bounded sub-slice**, with the downward half's `ForwardSlackWitnessed` at amount
   `m · (P + 1)` and NO upward hypothesis, as a depth-0 cell-EQUALITY schema
   `CellLEZeroConstOfKappaEqAntitoneBoundedForwardSlack` and its theorem.
6. **Dispatch the deep-descent residue** under a lower-pair `ForwardSlackWitnessed` hypothesis at
   amount `(n - n') - m · (P + 1)` — the named route, now priced. Land probe 8 as the record that
   the relaxed bound is non-removable, so the hypothesis is not decorative, and probe 9's
   observation that the landed necessity record is untouched.
7. **(Optional, and only if items 1-6 land clean) Consider the combined schema.** With the
   dichotomy exhaustive, monotone plus antitone covers EVERY collision. A combined schema would
   be the first statement in this layer with no displacement-shape restriction at all. It must
   NOT be named `cellLE_zero_const_of_kappa_eq`: it carries the regime, room and forward-slack
   witnessing hypotheses, so it is strictly stronger and bears on the reserved statement's truth
   value in neither direction. Say so in its docstring in those words.

**Sequencing note for the planner.** Items 1-3 are independent assembly work in
`LadderChain.lean` (1 and 3) and `LadderCell.lean` (2). Item 2 depends on item 1. Items 5 and 6
depend on 2, 3 and 4. Item 4 is independent of everything and is the cheapest phase; putting it
first gives a green commit before any assembly is touched.

## Decisions

- **DISPATCH, not refutation.** Both admissible outcomes were weighed. A refutation would have to
  be a compiled witness against the slice's cell equality, and nothing found supports one: the
  obstruction is an exposure gap in a landed signature plus a hard-coded direction in a landed
  `hk`, not a mathematical barrier. The compiled probes close the arithmetic in both directions
  for the bounded sub-slice and reduce the residue to one named, priced hypothesis.
- **The split is reported as the primary finding, not the dispatch itself.** The dispatch framed
  the antitone slice as one object needing one route. It is two objects with two prices, and the
  predecessor's own non-vacuity witness sits in the cheaper one. A plan that treats the slice as
  monolithic would over-hypothesize the bounded half.
- **`free_register_anchor_clause_monotone_required` is not amended, retired, or contradicted.**
  Its lower bound is non-removable, as it compiles. The finding is that the bound is RELAXABLE by
  exactly the raise — a different claim, consistent at the record's own witness (probe 9).
- **`cellLE_zero_const_of_kappa_eq` stays reserved.** Nothing recommended above lands under it,
  and every proposed schema is strictly stronger in hypotheses than the reserved statement.
- **Searches not run, deliberately.** No rate-limited Mathlib search was spent: the question is
  internal and every answer came from cited local source or a compiled probe. Recorded here so
  the absence is not read as an empty negative finding.

## Risks & Mitigations

- **Risk: the `habove` exposure may not survive the regime-A raise's internal block choice.** The
  block `(u, l)` comes from `exists_typeBlock_of_budget_le_cnt_within` and the raise uses `m · q`
  copies where `q · l = P + 1`. `hasForwardSlack_raise` needs `hul : u + l <= z + cntAt g z`,
  which the landed proof already derives as `hul'`. *Mitigation*: the identical composition is
  already compiled at LadderChain.lean:1979-1990 with the same block source, so the risk is low;
  verify by building item 1 alone before item 2 is written.
- **Risk: the register-raising deletion's `hgap` bookkeeping.** `hgap'`-style asymmetries bit the
  free-register downward half (its docstring records that none of `hgap`, `hgap'`, `hroom`
  implies another). *Mitigation*: probe 4b compiles the two inputs the re-lift actually needs;
  carry `n_0 + 2 + m · (P + 1) <= cntAt g z` as a named hypothesis rather than deriving it.
- **Risk: `decide` cost on the new non-vacuity witnesses.** Probe 7 uses `kappa 0 0 0 2 (10, 8)`,
  larger numbers than the landed witnesses. It compiled green this session at `by decide`, so no
  mitigation is needed; recorded because a future witness with a larger `B` may not.
- **Risk: scope creep into the `ForwardSlackWitnessed` discharge.** Items 5 and 6 state
  witnessing hypotheses; they must not attempt to discharge them. *Mitigation*: the dispatch's own
  scope line is explicit, and each schema's docstring should repeat that the hypothesis is one a
  consumer supplies.

## Tactic Survey Results

A tactic survey was performed as part of the compiled-probe work. Every arithmetic obligation in
the proposed route reduced to a single `omega` call after `intro`; no `simp`, `aesop`, `decide`,
`ring` or `linarith` was needed or tried on the arithmetic, and `decide` carried the two `kappa`
collision facts.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| antitone anchor clause under displaced Lipschitz, `k <= mP` (probe 1) | `omega` | success | after `intro` of all 10 hypotheses |
| raw Lipschitz insufficient (probe 1b) | `omega` | success | witness `24 8 10 5 3 16 5`, each side bound `by omega` |
| forward-slack trade upward, `(mP, nz) -> (0, n_0)` (probe 2) | `omega` | success | default |
| two-sided `hfirst` at lowered anchor (probe 3) | `omega` | success | default |
| two-sided `hfirst` at RAISED anchor, deletion side (probe 4) | `omega` | success | default |
| re-lift inputs survive the anchor raise (probe 4b) | `omega` | success | default |
| register descent is a multiple of `P + 1` (probe 5) | `omega` after `kappa_eq_components` + `Nat.modEq_iff_dvd'` | success | destructor supplies the residue; `Nat.mul_comm` to orient |
| bounded-descent non-vacuity (probe 6) | `decide` + `omega` | success | `decide` for the `kappa` equality, `rintro`/`omega` for the non-monotone clause |
| deep-descent non-vacuity (probe 7) | `decide` + `omega` | success | same shape, larger numerals |
| relaxed bound non-removable (probe 8) | `omega` | success | witness `19 8 10 1 0 12` |
| lower-pair slack closes deep descent (probe 10) | `omega` | success | default |

`lean_hammer_premise` and `lean_state_search` were not called: every goal above was closed by
`omega` on the first attempt, so there was no premise-discovery question to spend a rate-limited
call on.

## Context Extension Recommendations

- **Topic**: The forward-slack accounting as a *budget*, not just a hypothesis family.
- **Gap**: `hasForwardSlack_raise_of_zero`'s docstring already states the full accounting (raise
  adds exactly `d · l`, deletion spends exactly `l`, round trip is net zero), but that accounting
  is discoverable only by reading `LadderChain.lean` at line 1415. Two consecutive tasks have
  framed an antitone/anchor obstruction as "needs a hypothesis family no landed schema carries"
  when part of it is in fact payable from the raise already in the construction.
- **Recommendation**: add
  `.claude/context/project/lean4/patterns/forward-slack-budget.md` recording the three transport
  directions, the net-zero round trip, and the rule of thumb that a register move opposite to the
  countdown costs slack equal to the opposing displacement minus whatever the raise in the same
  construction bought. Source it from `hasForwardSlack_raise_of_zero`'s docstring rather than
  paraphrasing it.

## Appendix

### Probe inventory

All ten probes were run this session through `lean_run_code` and returned
`{"success": true, "diagnostics": []}`. Probes 1-4b and 8-10 import `Init` only (pure `Int`
arithmetic); probes 5-7 import
`FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`. The probe texts are reproduced in
the findings above by name and are not duplicated here.

Probe-numbering note for the implementer: probes 1, 2, 3 are the bounded-descent upward core;
probe 1b is its load-bearing-hypothesis record; probes 4, 4b are the downward core; probe 5 is
the descent destructor; probes 6, 7 are the two non-vacuity witnesses; probes 8, 9 are the
relaxed-bound necessity record and its consistency check against the landed one; probe 10 is the
named route's own closure.

### Source anchors

| claim | file:line |
|---|---|
| exhaustive monotone/antitone dichotomy | `LadderCell.lean:627` |
| antitone non-vacuity at `(4,2)`/`(6,0)` | `LadderCell.lean:689` |
| lower-bound necessity record | `LadderCell.lean:387` |
| free-anchor raise | `LadderCell.lean:298` |
| monotone schema and theorem | `LadderCell.lean:1253`, `:1295` |
| anchor-clause collapse to the first region start | `LadderChain.lean:1144` |
| `HasForwardSlack` definition | `LadderChain.lean:1218` |
| slack monotone in the amount | `LadderChain.lean:1242` |
| slack across a raise / from zero | `LadderChain.lean:1348`, `:1415` |
| `habove` + `hasForwardSlack_raise` idiom | `LadderChain.lean:1979-1990` |
| `_idx_` raise exposing `habove` | `LadderChain.lean:854` |
| regime-A raise discarding `habove` | `LadderChain.lean:1013`, `:1016` |
| lowered deletion with `hk` | `LadderChain.lean:2104` |
| `kappa` and its register residue coordinate | `CounterQuotient.lean:160` |
| the named route as recorded | `RaySummary/README.md:1180-1186` |

### Searches used

- Local `grep` sweeps over `FormalSystem/**/*.lean` for each declaration named in the dispatch,
  for `HasForwardSlack`, `hasForwardSlack_raise*`, and for `kappa`/`clipIdx` definitions.
- `lean_run_code` x 3 (one failed on a bad `Mathlib.Tactic.Omega` import path, then `Init`;
  one with the project import).
- `lean_local_search`, `lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_state_search`,
  `lean_hammer_premise`: not called, for the reason given under Decisions.
