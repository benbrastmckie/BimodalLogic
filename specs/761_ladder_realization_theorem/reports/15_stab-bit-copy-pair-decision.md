# Research Report: Task #761

**Task**: 761 - Ladder realization theorem
**Started**: 2026-11-14T22:30:00Z
**Completed**: 2026-11-14T23:05:00Z
**Effort**: NOT COSTABLE (route-deciding research round; the probe itself was one authoring pass plus three compile iterations)
**Dependencies**: None open. All six declared edges (760, 775, 805, 806, 819, 820) are DISCHARGED; task 836 is an ARTIFACT INPUT, not a predecessor (recorded decision, cycle 0, 2026-11-04)
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/RaySummary/` — `LadderModel.lean`, `LadderAgree.lean`, `LadderCell.lean`, `LadderChain.lean`, `LadderPump.lean`, `CounterQuotient.lean`, `Realize.lean`
- `FormalSystem/PlusLanguage/PlusTruth.lean` — `stab_state_only`, `PlusTruth.stab_iff`
- `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean` — the four-state tagged fixture reproduced by the probe
- `specs/761_ladder_realization_theorem/handoffs/phase-11.6-handoff-20261114T221500Z.md` — the dispatch-39 obligation check this round answers
- `specs/761_ladder_realization_theorem/plans/14_carried-hypothesis-depth-zero-route.md` — Phase 11.6's two BLOCKER entries
- No external search tool was used (no `leansearch`/`loogle`/`leanfinder`/`hammer_premise` call): every object at issue is in-tree, and the evidence tier used is compiled (`lake env lean`), which dominates an LSP-index lookup
**Artifacts**:
- `specs/761_ladder_realization_theorem/reports/15_stab-bit-copy-pair-decision.md` (this report)
- `specs/761_ladder_realization_theorem/prototype/stab-bit-copy-pair-probe.lean` (compiled, exit 0, 12 `#print axioms` lines, no `sorryAx`)
**Standards**: report-format.md, subagent-return.md
**Type**: lean4 research (route decision S-1)

## Executive Summary

- **Both recorded obstruction sources are GENUINE, not merely underivable.** A `⊡` bit really
  does differ at an off-residue copy pair (O1) and at a threshold-straddling pair (O2). `hL` is
  FALSE at such pairs, so no proof route — no stronger induction hypothesis, no relativization,
  no re-derivation — can supply it. Both must be eliminated by changing the construction.
- **The two cures are independent and both are needed.** O1 is cured by the residue alone (a
  displacement that is an exact multiple of `P + 1` leaves the bit unchanged, with no threshold
  hypothesis, and `(K1)` already forces the modulus the bit reads). O2 is NOT cured by any
  residue: the compiled witness differs at `c = 0` versus `c = m · (P + 1)` for every `0 < m`.
  A threshold margin is therefore mandatory.
- **The margin design (route S-2) survives; the certificate-side route (S-3) is not forced.**
  Both of the open points the dispatch-39 handoff left on S-2 are answered from landed lemmas
  plus one compiled parameter fact: the "exact shift `m · (P + 1)`" question does not arise, and
  the `(K2)` strengthening the margin needs is dischargeable.
- **The exact-shift question is answered by a landed lemma, not by new work.**
  `exists_typeBlock_of_spacing` (`LadderChain.lean:564`) at spacing `s := P + 1` returns a
  type-respecting block of length `d · (P + 1)` with `1 ≤ d ≤ b`. Its length is a multiple of
  `P + 1` whatever `d` is, so every interior-copy displacement `(k − i) · (d · (P + 1))` is a
  multiple of `P + 1`. `d` never needed controlling; only the block's *length* did.
- **What the margin costs is one new `(K2)` conjunct coupling `Tc` to `P`, and it is
  satisfiable.** `paramsOk_inflate` is the proof that the room hypothesis
  `b · (P + 1) ≤ Tc` does NOT follow from the present `ParamsOk` (compiled:
  `paramsOk_modulus_unbounded_at_fixed_Tc`), and `exists_paramsOk_with_margin` (compiled) shows
  the strengthened condition is dischargeable at every margin `N`. So the strengthening is a real
  change with no vacuity risk.
- **Recommended route: S-2, with the two requirements now named mechanically.** Phase 11.6 should
  be re-decomposed on (i) block spacing at exactly `P + 1`, and (ii) a depth-stratified margin
  `Tc ≥ Tc_0 + D · b · (P + 1)` where `D := (plusSubformulaClosure φ).sup stabDepth`. A
  non-blocking `user_decision` carries this, because S-2 lifts the plan's standing "do NOT raise
  `Tc` or further strengthen `ParamsOk`" prohibition.

## Context & Scope

Route (S-1) was recorded in cycle 2 (2026-11-14T22:22:15Z) with this obligation:

> Evidence, compiled where it can be, that decides between a margin design and the
> certificate-side route: either a fixture on which a stab bit differs at a pump copy pair (so no
> path-level correspondence through kappa-classes exists), or a stated induction invariant whose
> position pairs are all inside its own scope.

This round discharges that obligation in **both** of its disjuncts, which turns out to be the
informative outcome: the fixture exists (so the naive path-level correspondence through
`kappa`-classes is refuted) *and* an invariant whose pairs are all in scope exists (so the
correspondence is recoverable once the construction is changed). The two together say the
obstruction is a construction defect, not a proof-strength defect.

Scope boundary: this round authored no library file, ran no build of `FormalSystem`, and changed
no plan or status. Its deliverable is this report plus the compiled probe under `prototype/`.

## Carried-Figure Discipline

The dispatch extracted three description lines. Each was checked against live state; the result
is stated even where it only confirms the description.

| Carried claim | Check | Result |
|---|---|---|
| `w-soundness-shape-refuted.lean` carries `Probe747.modelOf_incomplete` and `Probe747.stab_iff_of_presented_nowUnique` | grep of that evidence file | CONFIRMED — both named at its lines 29/40/45/48/82-83 |
| `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}`, `Adm`, `ladderFrameAdm`, `ladderModel`, `no_fwd`, `no_bwd_of_idle`, `ladderFrameAdm_isRegular` in `RaySummary/LadderModel.lean` | full read of the file | CONFIRMED verbatim; `Adm` at `:159`, carrier below it, `ladderModel`'s valuation reads the object component only |
| `Rlad_slice_infinite` "one level down" | grep `RunLayer.lean` | CONFIRMED at `:328` (`¬ Finite (Q × ℕ × ℕ)`) |
| `Realize.lean` is 1004 lines | `wc -l` | CONFIRMED — exactly 1004 |
| CONTINGENCY line (never `sorry`, axiom, vacuous definition, trace-level hypothesis, finite-fibre/finite-width assumption); HWZ 2000 Theorem 14 ⇐ sources no claim | policy claim, no figure; honoured by this round (nothing landed, probe axiom profile `propext, Classical.choice, Quot.sound` only) | CONFIRMED, unchanged |
| Design of record at `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections A, C, H4 | path probe | **STALE PATH, content intact.** The file is at `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md` (task 757 was archived). Sections A (`:238`), C (`:467`) and H4 (`:783`) all present. A future revision should cite the archive path. |

One further figure, carried by the previous round's `.return-meta.json` rather than by the
description, was re-measured because this round would otherwise have propagated it: the prior
`axiom_count: 14` (reported in the dispatch-39 handoff as "`^axiom `: 12 under `FormalSystem`, 2
under `Tests/BimodalTest`"). Re-measured this round, there are **0 real `axiom` declarations**
across `FormalSystem` and `Tests`. All 12 `^axiom ` matches were inspected individually and every
one is a docstring line-wrap whose wrapped line happens to begin with the word "axiom"
(`FormalSystem/MainResults.lean:14`, `Semantics/TaskFrame.lean:570` and `:1850`, and nine more of
the same shape). The baseline is unchanged either way — nothing was added — but the figure as
stated overcounts, and a plain `grep -c '^axiom '` is not a declaration count.

No carried figure was found inaccurate in substance; one path citation is stale and one metadata
figure overcounts.

## Findings

### Codebase Patterns

**F1. `hL` is a statement about a pair of ladder STATES, not about paths.** `stab_state_only`
(`FormalSystem/PlusLanguage/PlusTruth.lean:338`) gives
`τ.state t = σ.state s → (PlusTruthAt M τ t (⊡φ) ↔ PlusTruthAt M σ s (⊡φ))`. So each instance of
the step's premise

```
hL : ∀ χ, L (⊡χ) → ∀ w, (PlusTruthAt M σ' w (⊡χ) ↔ PlusTruthAt M σ (ρ w) (⊡χ))
```

is exactly "the `⊡χ` bit agrees at the two states `σ'.state w` and `σ.state (ρ w)`" — time drops
out entirely. This is what makes a fixture decisive: a `⊡` bit is a function of the state, so a
two-state counterexample refutes `hL` outright rather than merely failing to witness it.

**F2. The retraction is the identity below the pump window and a uniform shift above it.**
`iterSpliceIdx_of_lt` (`LadderChain.lean:769`) and `iterSpliceIdx_of_ge` (`:776`). Below
`u + l` the two paths are at the same position; above `u + (d+1)·l` the correspondence is a
constant shift, and the landed clause `cntAt g' v = cntAt g (v − d·l)` holds there. So the only
positions whose pair can differ are the window's interior copies, at which
`iterSpliceIdx_add_mul` retracts `u + i·l + j` to `u + j`.

**F3. `exists_iterSpliced_ladderPath_idx_of_pend_past` exposes no countdown clause inside the
window, and no `nxtAt` clause anywhere.** Its four clauses (`LadderChain.lean:855`) are: object
equality at every position, countdown raised by `d·l` for `v ≤ u` whose region reaches `u`,
countdown shifted above `u + (d+1)·l`, and stab-free type equality at every position. The
interior-copy countdown `cntAt g u − j + (d−i)·l` and the register agreement
`nxtAt g' (u + i·l + j) = nxtAt g (u + j)` are ARGUED in the dispatch-39 handoff and are not
landed. Both are obligations any S-2 decomposition must discharge; this round assumes neither.

**F4. The spaced pigeonhole already delivers a block whose LENGTH is a multiple of `P + 1`.**
`exists_typeBlock_of_spacing` (`LadderChain.lean:564`) returns `u` and `d` with `0 < d ≤ b`
(`b := Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card`), block length `d · s`, the block
inside `[w₀, w₀ + b·s]`, `d · s ≤ cntAt g u`, and both the object and the realized type repeating
across it. At `s := P + 1` the length `d · (P + 1)` is a multiple of `P + 1` for every `d`. This
retires the handoff's "the exact shift `m·(P + 1)` is a separate open point for any margin
design": the construction never needs the shift to be exactly `m·(P + 1)`, only the block length
to be a multiple of `P + 1`, and the uncontrolled multiplier `d` is harmless because it is
bounded by `b` and only enters the margin arithmetic.

**F5. The room hypothesis for `s := P + 1` is not available from `(K2)`.** The landed room bound
is `budget_mul_succ_le_Tc` (`LadderChain.lean:212`): `b · (b + 1) ≤ Tc`, which mentions `P`
nowhere. The pigeonhole at `s := P + 1` needs `w₀ + b·(P + 1) ≤ z + cntAt g z`, i.e.
`b · (P + 1) ≤ Tc` at the schemas' `Tc ≤ cntAt g z`. Nothing in `ParamsOk` couples `Tc` to `P`.

### External Resources

No Mathlib lemma was needed beyond `Int.emod_two_eq_zero_or_one`, `Nat.mul_mod_right`,
`Nat.le_mul_of_pos_right` and `not_lt`. No documentation lookup, no web search, no rate-limited
search tool. The lean-lsp index was reported `reachable` by the dispatch's readiness block; it was
not consulted, because the evidence of record here is compiled rather than index-backed — the
stronger tier, so no degraded-mode announcement applies.

### The compiled probe

`specs/761_ladder_realization_theorem/prototype/stab-bit-copy-pair-probe.lean`, compiled with
`lake env lean`, exit 0. All twelve `#print axioms` lines report `[propext, Classical.choice,
Quot.sound]` — no `sorryAx`, no new axiom. The fixture (four-state tagged object `Qp = Bool ×
Bool`, `pendP = Prod.fst`, tag-flipping `stepP`, letters `p`/`r`/`a`, `phiP := p U (r ∧ a)`, the
forced-run lemmas `pending_run`/`idle_at`, `truth_phiP`, `gRef`) is reproduced from
`specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean` because an evidence
file is not an importable module; everything from `## The stab bit is a state datum` down is new.

| Declaration | What it compiles |
|---|---|
| `exists_hist_at` | every pending ladder state carries a history, so no `⊡` statement below is vacuous |
| `truth_phiP_of_state`, `stab_phiP_iff` | the `⊡phiP` bit at `(q, c, n)` IS `tagAt tg c` — the countdown's parity, independent of `n` |
| **`stab_bit_ne_of_odd_shift`** | **(O1) is genuine**: at an odd displacement the `⊡phiP` bits DIFFER, at every tag, every `c`, every `n` |
| `stab_bit_eq_of_even_shift` | at an even displacement they agree — with NO threshold hypothesis on either member |
| `two_mem_objCycleLens`, `two_dvd_succ_of_paramsOkK1` | `2` is an object cycle length here, so `(K1)` already forces `2 ∣ P + 1`: the modulus covers this fixture's bit |
| `stab_bit_eq_of_paramsOkK1_shift` | under `(K1)` alone, a displacement by any multiple of `P + 1` leaves the bit unchanged, at every `c` |
| `truth_Xr_of_state`, `stab_Xr_iff` | the `⊡(X r)` bit at `(q, c, n)` IS `c = 0` — a reading of the EXACT countdown, blind to every residue |
| **`stab_bit_ne_of_below_threshold`**, **`stab_bit_ne_of_below_threshold_on_residue`** | **(O2) is genuine and residue-proof**: the `⊡(X r)` bits at `c = 0` and `c = m·(P + 1)` differ for every `0 < m` |
| `paramsOk_modulus_unbounded_at_fixed_Tc` | generic in the object: `ParamsOk` holds at an arbitrarily large modulus with `Tc` held, so `b·(P + 1) ≤ Tc` is not a consequence of `(K1)`-`(K4)` |
| `paramsOk_raise_Tc` | generic: `ParamsOk` is monotone upward in `Tc` once `Tn` is raised with it |
| `exists_paramsOk_with_margin` | generic: for every margin `N` there are parameters satisfying `(K1)`-`(K4)` with `N ≤ Tc` — the margin conjunct is DISCHARGEABLE |

What the probe does not do, stated so the record cannot overclaim: it is one fixture, it refutes
universals and proves no agreement, it bounds nothing (every quantity named is a count), and it
does not claim the pump produces these exact pairs — F3's two unexposed clauses are assumed
nowhere in it.

### The induction invariant whose pairs are all in scope

With both cures in force, the relation the depth induction can be stated on is:

```
(q, c, n) ~_d (q', c', n')   iff   q = q' ∧ n = n' ∧ c ≡ c' (mod P + 1) ∧ Tc_d ≤ c ∧ Tc_d ≤ c'
```

and the claim at level `d` is agreement of the cell restricted to formulas of `⊡`-depth at most
`d`. Every position pair the regrouped pump produces lies in `~_d`:

1. *Below the window* (`F2`): the two paths are at the same position and, by the construction's
   own agreement below `u`, at the same state — the pair is the diagonal, trivially in scope.
2. *Above the window* (`F2`): the correspondence is the constant shift `d·L` with
   `L = d_blk · (P + 1)` a multiple of `P + 1`, so the residue condition holds; the object and
   register are held by the assembly's own clauses.
3. *Inside the window*: copy `i` at offset `j` pairs with `u + j`, countdown displaced by
   `(k − i) · L`, again a multiple of `P + 1` because `L` is (`F4`). The lower member's countdown
   is at least `cntAt g u − L ≥ Tc − b·(P + 1)`, so requiring `Tc ≥ Tc_d + b·(P + 1)` puts it
   above `Tc_d`.
4. *Block boundaries* (`u + i·L`): the pair is `(u, u + i·L)`, same object (the block is closed),
   same register (`F3`'s unexposed clause), displacement `i·L` — in scope by the same two
   conditions.

Stratifying over the depths `0 … D` with `D := (plusSubformulaClosure φ).sup stabDepth`
(`stabDepth_le_sup`, `LadderAgree.lean:508`, is the lemma that makes the induction terminate) costs
one margin per level: `Tc ≥ Tc_0 + D · b · (P + 1)`. That is a finite, `φ`-and-object-determined
quantity, and `exists_paramsOk_with_margin` says parameters meeting it exist. There is no
circularity: `Pof` does not read `Tc`, so `Tcof` may be redefined through `Pof`.

### Recommendations

- **Take route S-2 (depth-stratified threshold margins) and revise Phase 11.6 onto it; do not
  re-open S-3 (the certificate-side family) on this evidence.** The two refutations say the
  path-level route's failures are construction defects with known cures, and the certificate-side
  route is a larger change answering a question that is no longer open.
  `[VERIFIED: PASS — the gate deciding whether a margined `ParamsOk` is an admissible artifact is
  its own dischargeability, and it was run: `exists_paramsOk_with_margin` compiled, exit 0, no
  `sorryAx`, at every margin `N`]`
- **Add exactly one conjunct to `(K2)`:
  `Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (P + 1) * ((plusSubformulaClosure φ).sup
  stabDepth + 1) ≤ Tc`, and redefine `Tcof` as the `max` of its present value and that
  quantity.** This is the minimal coupling of `Tc` to `P` that the spaced pigeonhole at
  `s := P + 1` and the depth stratification jointly need.
  `[VERIFIED: PASS — `paramsOk_raise_Tc` and `exists_paramsOk_with_margin` compiled; the raise
  keeps `(K1)`-`(K4)` once `Tn` is raised with `Tc`, and `(K3)`'s ordering is the only conjunct
  that needed re-establishing]`
- **Instantiate the pump through `exists_typeBlock_of_spacing` at `s := P + 1`, not through
  `exists_typeBlock_of_budget_le_cnt_within`.** The block length is then a multiple of `P + 1` by
  construction and the "exact shift" question is retired.
  `[No compiled gate applicable — this names a call site, not a landable artifact whose
  acceptance an existing compiled gate decides; `F4` is a reading of the landed signature]`
- **Land the two clauses `F3` shows are missing before the step is attempted**: the interior-copy
  countdown clause of `exists_iterSpliced_ladderPath_idx_of_pend_past`
  (`cntAt g' (u + i·l + j) = cntAt g (u + j) + (d − i)·l`) and the register clause
  (`nxtAt g' (u + i·l + j) = nxtAt g (u + j)`). Without them the invariant's membership at the
  window's interior is unprovable even though it is true.
  `[No compiled gate applicable — new library clauses, with no existing gate deciding their
  acceptance]`
- **Do NOT carry `hL`, or any per-position `⊡` agreement along the rebuilt path, as a premise.**
  The plan's existing prohibition stands and this round strengthens the reason for it: `hL` is
  now known to be FALSE at the pairs the un-regrouped construction produces, so carrying it would
  make the statement vacuous rather than merely circular.
  `[No compiled gate applicable — a prohibition, not an artifact]`
- **Re-cite the design of record as
  `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`** in the next
  description amendment. `[No compiled gate applicable — a path citation]`

## Decisions

- **D15.1 — Both obstruction sources are reported as refutations, not as gaps.** The dispatch-39
  handoff called them "an obstruction to the route, not a refutation of the agreement", correctly
  for the evidence then available. With `stab_bit_ne_of_odd_shift` and
  `stab_bit_ne_of_below_threshold` compiled, the classification changes: `hL` is false at those
  pairs. The agreement itself (on `kappa`-classes, above the thresholds) is untouched — nothing
  here bears on its truth value.
- **D15.2 — The fixture reproduces rather than imports the tagged object.** An evidence file under
  `specs/` is not a Lake module. The alternative — promoting the fixture into the library — was
  rejected: a research-round probe must not change the library's surface.
- **D15.3 — The probe lives under `prototype/`, not `specs/evidence/`.** Wiring an evidence file
  into the evidence gate is an implementation act with a README/inventory obligation attached; a
  research round records its compiled artifact and leaves the wiring to the phase that consumes
  it. If S-2 is taken, the two refutation theorems are the natural content of a wired probe and
  should be promoted then.
- **D15.4 — No library file, plan file, or status was edited.** The route question S-2-vs-S-3 is
  the user's to rule on (it lifts a standing prohibition), so this round reports and recommends
  rather than acting.
- **D15.5 — The second disjunct of the S-1 obligation is answered positively, and is reported
  even though the first disjunct already discharges the obligation.** Reporting only the
  refutations would have read as closing the path-level family; the invariant section is what
  shows it is recoverable.

## Risks & Mitigations

- **Risk: the margin arithmetic is fixture-blind.** The compiled margin facts are generic, but the
  claim that `Tc ≥ Tc_0 + D·b·(P + 1)` suffices rests on `F2`-`F4`'s reading of the landed
  signatures, not on a compiled derivation. *Mitigation*: the S-2 decomposition's first phase
  should be the two missing clauses of `F3` plus a compiled room lemma `b·(P + 1) ≤ Tc` from the
  new conjunct, before any depth induction is attempted.
- **Risk: the `kappa` gap coordinate.** The invariant above holds `n` fixed and displaces `c`, so
  `clipIdx B c n` moves unless both members are gap-saturated. The depth-`0` schemas carry
  `n + 2 ≤ c` only, while saturation wants `n + B ≤ c`. *Mitigation*: check
  `kappa_eq_components` (`LadderAgree.lean:906`) against the intended instantiation during the
  revision; if the gap coordinate is not saturated, the invariant must be stated on `~_d` directly
  rather than as a sub-relation of `kappa`-equality — which is harmless, since `~_d` is what the
  pump's pairs satisfy and `kappa`-equality was only ever a convenient carrier.
- **Risk: `D` is a `Finset.sup`, so the stratification's depth is a `φ`-determined count with no
  bound claimed.** *Mitigation*: this is the standing posture of the whole record (every quantity
  is a count); the report states it rather than bounding it.
- **Risk: one fixture.** Both refutations are fixture-level. *Mitigation*: they are refutations of
  universals, which is exactly what one fixture can do; no positive general claim is drawn from
  the fixture, and the three generic parameter facts are stated for an arbitrary finite object.

## Tactic Survey Results

A tactic survey was performed on the probe's own goals (the only proof goals this round had).

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `tagAt tg i ≠ tagAt tg j` from `i % 2 ≠ j % 2` | `simp only [hi, hj] at h ⊢` then `first | exact absurd rfl h | (cases tg <;> simp)` | fail | `simp` reduced `h` to `¬True`, so `absurd rfl h` no longer matched; four explicit cases needed instead |
| same | `rcases` ×2 then `rw [hi, hj, if_pos rfl, if_neg …]` + `cases tg <;> simp` | success | `Int.emod_two_eq_zero_or_one` |
| `m * (P + 1) % 2 = 0` from `P + 1 = 2 * j` | `rw [hj]; omega` | fail | non-linear: `omega` cannot multiply two variables |
| same | `rw [hj, show m * (2*j) = 2*(m*j) by ring]; exact Nat.mul_mod_right 2 (m*j)` | success | `Nat.mul_mod_right` |
| `PlusTruthAt M σ s' ⊥` under `0 < s' < 1` | `exact absurd h1' (by omega)` | fail | `omega` did not pick up the `s' < 1` hypothesis through the frame's order instance |
| same | `exact absurd h2' (not_lt.mpr (by omega))` | success | `not_lt`, with `omega` on the standard-instance hypothesis only |
| `N ≤ (N+1)*(P+1) - 1` | `omega` after `Nat.le_mul_of_pos_right` | success | — |
| `ParamsOk` at raised `Tc` | `exact ⟨hK1, ⟨le_trans …⟩, ⟨hn, le_trans …⟩, hK4⟩` | success | structural; no automation needed |
| `2 ≤ Fintype.card (Bool × Bool)` | `simp` | success | — |

Reading: `omega` is unreliable across the frame's order instance (two of the three failures), and
unusable on the residue goals, where the `Nat.*_mod_*` lemmas are the right tools. No
`lean_multi_attempt` or `lean_hammer_premise` call was made — the goals were small enough that a
direct compile cycle was cheaper than an MCP round trip, and three compile iterations closed all
twelve declarations.

## Context Extension Recommendations

- **Topic**: `stab_state_only` as the reason a two-state fixture refutes a path-level premise.
  **Gap**: nothing under `context/project/lean4/` records that a `⊡` premise quantified over
  positions collapses to a statement about state pairs, which is the move that made this round
  cheap. **Recommendation**: add a short subsection to
  `context/project/lean4/patterns/dependency-tracing.md` (or a new
  `patterns/state-only-collapse.md`) naming `stab_state_only` and `PlusTruth.box_time_invariant`
  as the two collapse lemmas of this semantics, with the "refute a path premise with two states"
  recipe.
- **Topic**: the repository's own idiom for refuting "parameter condition X is derivable".
  **Gap**: `paramsOk_inflate` is the general tool (a closure property that makes one parameter
  unbounded at the others' fixed values), and nothing records it as a *technique*.
  **Recommendation**: one paragraph in the RaySummary README's parameter section, or in
  `context/project/lean4/patterns/plan-authoring-gate-collisions.md`, so the next round that
  wonders whether a room hypothesis follows from `ParamsOk` reaches for inflation first.

## Appendix

**Probe compile command** (from the repository root):

```
lake env lean specs/761_ladder_realization_theorem/prototype/stab-bit-copy-pair-probe.lean
```

Exit 0. Twelve `#print axioms` lines, all `[propext, Classical.choice, Quot.sound]`.

**Searches and reads used** — all in-tree, no external or rate-limited tool:

- `grep` for `def kappa|def ParamsOk|def cellLE|def cellAt|stab_mem_tpOf_iff_cell|def Adm|def cascadeBound|def satThreshold|def satPeriod` across `FormalSystem/Metalogic/Decidability/`
- `grep` for `cellLE` across `FormalSystem/` — establishes that `cellLE` is a planned object with
  no definition in the library; only the five `cellLE_zero_const_of_kappa_eq_*_of_forwardSlack`
  schemas exist, in `LadderCell.lean`
- full reads: `LadderModel.lean`; `LadderAgree.lean:360-560`; `LadderCell.lean:1490-1560`;
  `CounterQuotient.lean:140-200, 512-530, 620-900`; `LadderChain.lean:212-240, 520-620, 759-900`;
  `LadderPump.lean:78-96`; `PlusTruth.lean:151-175, 233-260, 338-360`;
  `ladder-cell-index-obstructions.lean:156-540`; `ladder-cell-refutation.lean:1-60`;
  `stab-depth-stratification.lean:1-70`
- the live `.return-meta.json`, the dispatch-39 handoff, and Phase 11.6 of plan v14

**Declaration anchors cited in this report** (file:line, this round):

| Declaration | Location |
|---|---|
| `stab_state_only` | `FormalSystem/PlusLanguage/PlusTruth.lean:338` |
| `PlusTruth.stab_iff` | `FormalSystem/PlusLanguage/PlusTruth.lean:151` |
| `stab_mem_tpOf_iff_cell` | `RaySummary/LadderAgree.lean:377` |
| `stabDepth`, `StabPinned`, `stabDepth_le_sup` | `RaySummary/LadderAgree.lean:476, 488, 508` |
| `kappa_eq_components` | `RaySummary/LadderAgree.lean:906` |
| `kappa`, `clipIdx`, `CK` | `RaySummary/CounterQuotient.lean:160, 151, 147` |
| `objCycleLens` | `RaySummary/CounterQuotient.lean:512` |
| `paramsOkK1`, `paramsOkK2`, `ParamsOk`, `paramsOk_params`, `paramsOk_inflate` | `RaySummary/CounterQuotient.lean:818, 827, 851, and the two theorems below them` |
| `cascadeBound`, `satThreshold`, `satPeriod`, `ell0` | `RaySummary/CounterQuotient.lean:701, 638, 643, 692` |
| `budget_mul_succ_le_Tc` | `RaySummary/LadderChain.lean:212` |
| `exists_typeBlock_of_spacing` | `RaySummary/LadderChain.lean:564` |
| `iterSpliceIdx`, `iterSpliceIdx_of_lt`, `iterSpliceIdx_of_ge` | `RaySummary/LadderChain.lean:759, 769, 776` |
| `exists_iterSpliced_ladderPath_idx_of_pend_past` | `RaySummary/LadderChain.lean:855` |
| `typeBlock_length_dvd_of_paramsOk` | `RaySummary/LadderChain.lean:524` |
| `delIdx` | `RaySummary/LadderPump.lean:78` |
| the five depth-`0` schemas | `RaySummary/LadderCell.lean:1530, 1631, 1767, 1910, 1961` |
| `Adm`, `LadderState`, `ladderFrameAdm`, `ladderModel` | `RaySummary/LadderModel.lean:159, and below` |
| `Rlad`, `Count`, `Drift`, `Rlad_slice_infinite` | `RaySummary/RunLayer.lean:268, 261, 254, 328` |
