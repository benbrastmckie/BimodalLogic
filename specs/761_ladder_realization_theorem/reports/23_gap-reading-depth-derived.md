# Research Report: Task #761

**Task**: 761 - Ladder realization theorem
**Started**: 2026-11-16T04:10:00Z
**Completed**: 2026-11-16T06:25:00Z
**Effort**: 2.25 hours
**Dependencies**: None
**Sources/Inputs**: - Codebase (`RaySummary/CounterQuotient.lean`, `LadderModel.lean`, `RunLayer.lean`, `LadderAgree.lean`, `LadderRealize.lean`, `LadderWindow.lean`, `AnchorLayer.lean`, `Certificate.lean`), the fixture `ladder-cell-agreement-refutation.lean` (all four sections), `records/round-21-refutation-verdict.md` (Rounds 3 and 4), `summaries/21_filed-agreement-refuted-gap-clip-summary.md`, `lake env lean` on a new probe, guarded `lake build`
**Artifacts**: - `specs/761_ladder_realization_theorem/reports/23_gap-reading-depth-derived.md` (this report); `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean` (new probe, 1,210 lines, zero `sorry`)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Q1 verdict: the obstruction is the CONSTANT, not the invariant.** Compiled on the part of the
  language where it can be closed outright (every connective, `⊡` and `□` included, `untl`/`snce`
  at the guard `⊥` only — the "step fragment"), for EVERY finite object: the agreement holds at
  the exact gap reading (`cellAt_eq_of_exact_gap_shift`) and at the clip
  `B ≥ max (2 dBack) (2 dFwd + 2)` (`cellAt_const_of_kappa_eq_stepFrag`), and FAILS at the filed
  clip, which is one short at every forward depth (`sigC_refutes`, at `paramsOk_params`).
  For formulas with a genuine jump the verdict is ARGUED, not compiled (see "Q1" below).
- **`κ` was not derived, and the library shows it.** The only conjunct of (K4) any library proof
  consumes is `2 ≤ B` (`LadderWindow.lean:1835`). The two depth conjuncts `2 dBack + 1 ≤ B` and
  `2 dFwd + 1 ≤ B` are passed through `paramsOk_inflate` and used by nothing. No proof step ever
  generated a requirement on the clip.
- **The derivation works where it was tried.** `Zrel a b` in the new probe is a relation on
  ladder states whose every threshold is the solution of a one-step closure condition
  (`Zrel_succ`, `Zrel_pred`); the agreement is then a corollary of a truth lemma
  (`truth_iff_of_lnk` → `cellAt_eq_of_Zrel`), with NO `ParamsOk`, no modulus, no object
  hypothesis. The bound it produces is exact on the fragment (`stepFrag_gap_depth_exact`).
- **Q4: the certificate side repairs with the agreement, not separately**
  (`real_subset_Dmax_stepFrag`: all six conditions on `Real`, condition (5) included, hence
  `Real ⊆ Dmax`, on the fragment at the derived parameters).
- **Q3: reachable as a METHOD, not as a definition.** Defining `κ` as the semantic bisimulation
  quotient makes the agreement a tautology and finite index is already landed
  (`anchorCells_finite`) — but that quotient is not enumerable, and `Dmax` needs an enumerable
  carrier. What is reachable is deriving the EXPLICIT quotient's thresholds from closure
  conditions. The step clauses are done; the two jump clauses are the open theory.
- **Recommendation**: repair (K4)'s SHAPE to `B ≥ 2 (dBack + dFwd) + 2`, do not run a fifth
  patch-then-refute loop as the main line, and aim the plan at the derivation: promote the step
  system as the base case, then close the two jump clauses.
- **Not delivered**: a proved upper bound on the gap-reading depth for the WHOLE language. The
  proof stops at the unrestricted `untl`/`snce` clause; the goal state is recorded below.

## Context & Scope

Dispatched conversationally to test whether route (G-1) (repair the clip, try to refute again)
treats a symptom. Five questions, Q1 decisive. Writes are confined to this report and one new
probe file; `plans/`, `state.json`, `TODO.md`, `.return-meta.json` and
`ladder-cell-agreement-refutation.lean` were not touched. The probe is NOT wired into
`scripts/check-evidence-probes.sh` (out of my write scope) — a follow-up for whoever lands it.

Every declaration name below was re-derived against the live tree. Line numbers:
`kappa` `CounterQuotient.lean:169`, `clipIdx` `:160`, `dBack` `:668`, `dFwd` `:683`,
`Bof` `:854`, `paramsOkK4` `:920`, `ParamsOk` `:929`, `certStabK` `:1221`, `Dmax` `:1248`;
`Count`/`Rlad` `RunLayer.lean:261/268`; `cellAt` `AnchorLayer.lean:132`;
`cellAt_eq_cellAt` `AnchorLayer.lean:154`; `kappa_eq_components` `LadderAgree.lean:902`;
`mem_cellAt_ladder_iff` `LadderAgree.lean:2664`; `LadderRealize.lean` is 1,690 lines.

## Findings

### The mechanics the gap obeys (read off `Rlad`, used throughout)

At a pending state `(c, n)` with gap `g = n - c`:

1. one step FORWARD changes the gap by `0`, `+1` or `+2`; one step BACKWARD by `0`, `-1`, `-2`;
2. a pending state has an idle predecessor iff its gap is in `{-1, 0, 1}`;
3. `⊡` re-chooses the history and keeps the state.

So a formula walks the gap by at most `2` per temporal step and tests it against the window
`{-1, 0, 1}`. Backward steps let it reach large POSITIVE gaps (`2 a`), forward steps large
NEGATIVE ones (`2 b + 2`). Nothing in this depends on the object: `Zrel_succ` and `Zrel_pred`
are proved for arbitrary `(step, pend)` by a four-way split on the two pending bits.

### Q1 — constant or invariant

**Compiled (step fragment, every finite object, `⊡` and `□` included):**

| Declaration | Content |
|---|---|
| `cellAt_eq_of_exact_gap_shift` | cell at `(c, n)` = cell at `(c + M, n + M)` once `c, n ≥ 2 (dBack + dFwd)`; no clip, no modulus |
| `cellAt_const_of_kappa_eq_stepFrag` | a `kappa`-collision gives equal cells when `Tc, Tn ≥ 2 (dBack + dFwd)`, `B ≥ 2 dBack`, `B ≥ 2 dFwd + 2` |
| `cellAt_const_of_kappa_eq_stepFrag_at_time` | the same at general world time and evaluation time |
| `sigC_refutes` | at `sigC b := ◇ X^b ◇ Y ¬p` (`dBack = 1`, `dFwd = b`, `Bof = 2 b + 1`), `paramsOk_params`, two pairs of one class have different cells, every `b ≥ 1` |
| `stepFrag_gap_depth_exact` | clip `2 b + 1` fails, clip `2 b + 2` holds, same formula |

The tight family of `tight_state_refuses_C` sits at gaps in `{-1, 0, 1}` with countdown
`2 m + 2`. `cellAt_eq_of_exact_gap_shift` applies to it verbatim: for every step-fragment `φ`
with `dBack φ + dFwd φ ≤ m` the tight state and every common shift of it have the same cell.
`tight_state_refuses_C` says the answering history must rewrite the pending row; it does not say
the type changes, and on the fragment it does not.

**Argued, NOT compiled (formulas with a jump).** I looked for a reader of the exact gap at
unbounded depth and found none. The reasons, each checkable by hand against `Rlad`:

- a jump to a region ENTRY lands on a gap in `{-1, 0, 1}` whatever the starting gap was;
- a jump to a region END lands on countdown `0` with register in `[max 0 g, n + c]` — the lower
  end is `g`, read only up to the reader's own depth;
- along one history the gap is monotone, so every history from a large gap passes every
  intermediate level within `±1`: a jump to "the last point with gap `≤ k`" loses `g` entirely;
- parity of `g` is not forced: the distance back to the entry is any `s ≥ ⌈(g - 1) / 2⌉`.

**Exact reading is not a safe harbour.** Two things the lead's framing should take on board:
(i) the exact-gap agreement is IMPLIED by the agreement at any clip, so "fails at exact gap"
would indeed kill every clip — the dichotomy is sound; (ii) the exact-gap agreement at `⊡`-depth
`d + 1` CONSUMES a clipped agreement at depth `d`: a history holding its register constant shows
a different exact gap at every step, and inserting the `M` steps the longer countdown needs is
invisible only if the lower-depth labels stop reading the gap somewhere. Argued, not compiled.
So an exact-gap quotient is neither finite nor self-supporting; the clip is not optional.

### Q2 — the gap-reading depth

**The two "data points" in the brief are the clips that FAIL.** `thetaC ↦ 3` and
`mixC (k + 2) k ↦ 2 k + 5` are `Bof`'s outputs. A correct `f` must EXCEED them: the separated
gaps need clip `≥ 4` and `≥ 3 k + 5` (`thetaC_pair_not_collision`, `mixC_pair_not_collision`
compile that the landed witnesses are gone exactly there).

**Proved, on the step fragment** (`Zrel_of_kappa_eq` + `cellAt_eq_of_Zrel`):

    f_step(φ) = max (2 · dBack φ) (2 · dFwd φ + 2)

with a matching lower bound on the forward arm (`sigC_refutes`): tight.

**Lower bounds for any depth-only clip `F(dBack, dFwd)` on the whole language** (compiled):

| Family | `dBack` | `dFwd` | Needs `B ≥` | Source |
|---|---|---|---|---|
| `sigC b` | 1 | `b` | `2 b + 2 = 2 dFwd + 2` | new probe |
| `thetaC` | 1 | 1 | `4 = 2 dFwd + 2` | fixture, `thetaC_mem`/`thetaC_not_mem` |
| `mixC a k` | `a` | `k + 2` | `2 a + k + 1 = 2 dBack + dFwd - 1` | fixture, `mixC_mem`/`mixC_not_mem` |

So `F(a, b) ≥ max (2 a + b - 1) (2 b + 2)`. The jump adds `dFwd` to the POSITIVE arm (a forward
jump to the region end, then counting the next region's length at one unit per `X`), which the
step fragment cannot do. This envelope reproduces all three families exactly (`4`, `3 k + 5`,
`2 b + 2`).

**Upper bound for the whole language: NOT PROVED.** Conjecture, with the reasoning above:
`2 (dBack + dFwd) + 2` suffices (each temporal operator moves the gap by at most `2`; jumps
saturate). The lead's number is consistent with every compiled datum and I could not beat it,
but it is a conjecture. Where the proof stops: dropping `γ = ⊥` from the `untl` case of
`truth_iff_of_lnk` leaves (this is `PlusTruthAt`'s clause, `PlusTruth.lean:89`, unfolded)

    hl : Lnk a b g g' t
    ⊢ (∃ s, t < s ∧ PlusTruthAt M τ s α ∧ ∀ r, t < r → r < s → PlusTruthAt M τ r γ) ↔
      (∃ s, t < s ∧ PlusTruthAt M τ' s α ∧ ∀ r, t < r → r < s → PlusTruthAt M τ' r γ)

and `Lnk` constrains only positions in `[t - a, t + b]`. A witness `s > t + b` is unconstrained.
What is owed is `exists_linked_path` with a WHOLE-PATH correspondence in place of the window.

### Q3 — deriving `κ`

Two readings of "define `κ` as the bisimulation quotient", with different answers.

**(a) The semantic quotient — reachable and useless.** Take `κ x := cellAt M φ x 0`. The
agreement is `rfl`, the index is finite by the landed `anchorCells_finite`. But `Dmax` is a
union over subsets of `Q × ClType φ × CK …` and `relK` is an image over finite counter
representatives: both need the carrier enumerable and the class map computable. The semantic
quotient gives neither. Finite index is NOT the prize — it is free. The prize is an effective
index, which is the agreement lemma under another name.

**(b) Thresholds derived from closure conditions — reachable, and done for the step clauses.**
`Zrel` was written with unknown thresholds `T(a, b)`, `N(a, b)`, `G⁺(a, b)`, `G⁻(a, b)` and the
eight one-step cases solved for them:

    G⁺(a, b) ≥ G⁺(a-1, b) + 2,  G⁺ ≥ 2 when a ≥ 1        ⟹  G⁺ = 2 a
    G⁻(a, b) ≥ G⁻(a, b-1) + 2,  G⁻ ≥ 2 when a ≥ 1        ⟹  G⁻ = 2 b + 2
    T(a, b) ≥ N(a-1, b),  N(a, b) ≥ T(a, b-1),  N(a, b) - 1 ≥ G⁺(a-1, b)   ⟹  T = N = 2 (a + b)

Nothing was tuned, and the first compile of both step lemmas went through with those values.
That is the sense in which the clip "falls out as a theorem". The residue coordinates fall out
as UNUSED on the fragment — they are a jump phenomenon.

**What `no_transferSys_links_collisions` does and does not rule out.** Its proof is: a link ⇒
the count move (`typePreservingCountMove_of_transferSys`) ⇒ the agreement over the FILED `κ`
at `thetaC`'s filed parameters ⇒ contradiction with `no_fibre_equation_over_kappa`. It is the
contrapositive of the transfer theorem's soundness applied to one separated pair. It rules out
exactly: a transfer system linking every collision of `kappa … (Bof thetaC = 3)`. It says
nothing about a system linking the collisions of a finer quotient — a transfer system can only
ever link indistinguishable points, so a correctly derived quotient is untouched. It does not
obstruct Q3.

**Cost of the remainder.** The jump clauses are not one-step closure conditions. They need,
given `x Zrel y` and a ladder path through `x`, a ladder path through `y` whose WHOLE pending
row corresponds — which is Round 3's count move (lengthen a region, cascade through the cap,
insert a region in a tight chain). That is where (K1)'s modulus and (K2)'s margin enter. This
round does not shrink it; it supplies its base case, its `⊡` clause
(`exists_linked_path` is the `⊡` clause, and the pattern carries over), and the correct clip.

### Q4 — certificate side

`real_subset_Dmax_stepFrag` compiles `certAdmK … Real` and `Real ⊆ Dmax` on the fragment. The
assembly is: conditions (1), (2), (3), (4), (6) are `real_certLocK`, `real_certBiInfK`,
`real_certFwdK`, `real_certBwdK`, `real_certBoxK` — landed, and they take NO parameter
hypothesis; condition (5) is `real_certStabK_of_classRepTransport`, and `ClassRepTransport` is
the agreement at general times.

So: **condition (5) is the only one that reads the clip, and it repairs automatically** the
moment the agreement holds over the repaired `κ`. `certStabK`'s definition needs no change.
`certStabK_fails_of_contains_realized` is the agreement's failure seen from the certificate, not
a second defect. Nothing here addresses the converse inclusion (`ladderLift`).

### Q5 — φ-dependence

Acceptable, and already the design. Checked against consumers, not prose:

- `Bof`, `Tcof`, `Tnof`, `Pof` are all functions of `φ`; `paramsOk_params` discharges at them.
- `Dmax`, `certAdmK`, `Real`, `ClassRepTransport` and every agreement statement quantify
  `∀ Tc Tn P B` under a per-`φ` hypothesis. None fixes `B` before `φ`.
- `Dmax`/`certAdmK`/`Bof`/`Tcof` are referenced only inside `CounterQuotient.lean` and
  `LadderRealize.lean` (plus docstrings in `RaySummary.lean`); `Certificate.lean` has zero
  references to `kappa`, `CK`, `Dmax`, `Bof` or `ParamsOk` — its `certAdm` is `K`-free.

No consumer needs a `φ`-uniform bound. A clip growing with `dBack + dFwd` costs a larger `CK`
(a COUNT) and nothing else.

### Codebase Patterns

- (K4)'s depth conjuncts are dead hypotheses in the library: only `hp.2.2.2.2.2 : 2 ≤ B` is
  projected (`LadderWindow.lean:1835`); `paramsOk_inflate` re-packs `hK4` unread
  (`CounterQuotient.lean:995, 1020`). Grep-based over `RaySummary/*.lean`, not a deletion trial.
- `exists_isLadderPath_of_hist` / `exists_hist_of_isLadderPath_at_offset` / `mem_cellAt_ladder_iff`
  are enough to run a state-level back-and-forth; no new library lemma was needed.
- `omega` closes every one-step case once `Count` is reduced by the two pending bits.

### External Resources

- None. No Mathlib search was needed; the probe uses `Function.iterate_succ_apply'` only.

### Recommendations

- Change (K4) to `2 * (dBack φ + dFwd φ) + 2 ≤ B` (and `Bof` to match). It dominates the proved
  step-fragment value and every compiled lower bound. [VERIFIED: PASS -- `lake env lean` on the
  probe: `thetaC_pair_not_collision` (`B ≥ 4`), `mixC_pair_not_collision` (`B ≥ 3 k + 5`) and
  `stepFrag_gap_depth_exact` (`B ≥ 2 b + 2`) show all three landed refuting witnesses are gone at
  that clip; this certifies the witnesses are gone, NOT that the agreement holds there]
- Promote `Zrel`, `Zrel_succ`, `Zrel_pred`, `exists_linked_path`, `truth_iff_of_lnk`,
  `cellAt_eq_of_Zrel` into the library as the base case of the derivation (they are stated for an
  arbitrary object and import only `LadderRealize`). [VERIFIED: PASS -- `lake env lean` on the
  probe, exit 0, axioms `[propext, Classical.choice, Quot.sound]`; guarded `lake build` exit 0,
  2975 jobs]
- Aim the plan at the two jump clauses, stated as a path-forth lemma with a whole-row
  correspondence, on the `⊡`-free level first. Treat (G-1)'s refutation attempt as a time-boxed
  gate, not the main line. [No compiled gate applicable]
- Do not re-define `κ` as a semantic quotient, and do not move to an exact-gap coordinate.
  [No compiled gate applicable]

## Decisions

- Answered Q1 on the largest fragment where a full proof fits a research round, rather than
  argue the whole language. The fragment keeps `⊡` and `□` and drops only the unbounded jump.
- Proved the fragment theorem for every object, not the two-state fixture: the gap mechanics
  never use the object.
- Indexed the relation by TWO budgets `(a, b)`. A single budget `a + b` proves a clip of
  `2 (dBack + dFwd)` but hides that the two arms differ (`2 dBack` against `2 dFwd + 2`), which is
  exactly the asymmetry (K4) got wrong.
- Did not re-state `cellAt_const_of_kappa_eq` or `ladderRealized` under their pinned names. The
  new statements carry `stepFrag` in the name and their own hypotheses.

## Risks & Mitigations

- **The conjectured clip `2 (dBack + dFwd) + 2` may still be short for some jump-reader I did not
  find.** Mitigation: the lower-bound envelope `max (2 a + b - 1) (2 b + 2)` leaves room below it
  for `a, b ≥ 1`; and the derivation, not the constant, is what the plan should rest on — a
  derived relation fixes its own thresholds.
- **The thresholds `2 (dBack + dFwd) ≤ Tc, Tn` are explicit hypotheses**, not discharged from
  `ParamsOk`. They are far below `Tcof` (`≥ 2 ^ card closure`), but that inequality is not
  compiled here.
- **The fragment result can be over-read.** It does not cover `thetaC` or `mixC`: each uses one
  jump. It shows the clip is exact where there is no jump, and that the filed clip is wrong even
  there.
- **(K2)'s margin is thin, not obviously wrong.** A doubling chain from a length-1 region to a
  countdown `≥ 2 ^ card` has about `card` regions, and a formula spends at least one closure
  member per region it counts. I found no refutation, but the count move's region-insertion step
  will consume exactly this margin; expect it to be the next constant under pressure.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| one-step closure, each of 8 cases (`Zrel_succ`, `Zrel_pred`) | `omega` | success | after `simpa [Count, hp, hp1]` on the count clause and `unfold Drift` |
| `Zrel_symm`, `Zrel_mono` | `omega` | success | on the three disjunctive components |
| `clipIdx` collisions (`Zrel_of_kappa_eq`, `not_kappa_collision_of_gap_inside`) | `split_ifs <;> omega` | success | after `unfold clipIdx` |
| `t < s`, `s ≠ t + 1 ⊢ t + 1 < s` inside `truth_nxt` | `omega` | fail | order is on `F.Duration`; fixed by stating the fact as a separate `ℤ` lemma |
| `StepFrag (sigC b)` | anonymous constructor | fail | `StepFrag` is a recursive `Prop`; fixed with `show` of the unfolded conjunction |

## Context Extension Recommendations

- **Topic**: deriving a quotient's thresholds from closure conditions.
- **Gap**: no context file describes the pattern "write the relation with unknown thresholds,
  list the one-step cases, solve"; four rounds tuned `ParamsOk` instead.
- **Recommendation**: a short pattern note under `.claude/context/project/lean4/patterns/`, with
  `Zrel` as the worked example.

## Appendix

- Probe: `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean`.
  Headline declarations: `Zrel` (:80), `Zrel_succ` (:102), `Zrel_pred` (:191),
  `exists_linked_path` (:382), `StepFrag` (:480), `truth_iff_of_lnk` (:595),
  `cellAt_eq_of_Zrel` (:710), `cellAt_const_of_kappa_eq_stepFrag` (:749),
  `cellAt_eq_of_exact_gap_shift` (:768), `real_subset_Dmax_stepFrag` (:820), `sigC_refutes` (:1134),
  `stepFrag_gap_depth_exact`, `thetaC_pair_not_collision`, `mixC_pair_not_collision`.
- Verification: `lake env lean` on the probe, exit 0, no `sorry`, no axiom, no `native_decide`.
  Guarded full build `lake-build-guard.sh build --timeout 1800 -- build`: exit 0, 2975 jobs.
- Not run: a deletion trial of (K4)'s depth conjuncts; `scripts/check-evidence-probes.sh`.
