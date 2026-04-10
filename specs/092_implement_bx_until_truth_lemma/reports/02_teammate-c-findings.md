# Task 92 — Teammate C (Critic) Findings

- **Task**: 92 — Close 4 Until/Since truth-lemma sorries in `BXCanonical/Frame.lean`
- **Role**: Critic — identify gaps, blind spots, and unvalidated assumptions in the task 90 recommendation
- **Date**: 2026-04-10
- **Method**: Read-only inspection of Frame.lean, Axioms.lean, task 89/90 artifacts. No `.lean` edits.

## Summary

The task 90 recommendation is **substantially less solid than the inheritance report
01_inherited-from-task90.md represents it to be**. Task 90's Phase 1 diagnostic
*did* establish rigorously that the metalogic/object-logic bridge is missing for a
direct `bx_le_linear` proof — that part is sound. But the "Burgess-Xu Until-induction"
replacement that task 90 then proposes smuggles the **exact same bridge assumption
back in, unproved**, in the form of the statement "by the self-accumulation form,
`(φ U ψ) ∈ u`" for an arbitrary `u` with `w ≤ u`. Self-accumulation via BX5 lives
inside `w.formulas`; it does not propagate along the `g_content ⊆` ordering because
`(φ ∧ (φ U ψ)) U ψ` is an Until formula, not a G-formula. Task 90 has identified a
real obstruction and then papered over it with a proof sketch that cannot discharge
the same obstruction. In addition, BX4's docstring explicitly says it
**"replaces the Burgess-Xu Until-Since connectedness axiom, which is not valid under
half-open guard semantics"**, yet task 90's backward-Until strategy depends on exactly
that displaced connectedness. The 8–16h estimate is unsupported and the Since mirror
introduces new directional asymmetries that task 90 has not analyzed. My confidence
in the task 90 recommendation closing all four sorries is **25%**. I recommend
planning with an explicit pre-phase diagnostic gate (probe the bridge step for BX5)
and an explicit escalation trigger to `/spawn 92` if the diagnostic fails.

## Critical Issues

### Issue 1 — BLOCKER — BX5 self-accumulation does not propagate along `bx_le`

Task 90 step 4 of the `bx_until_eventuality_resolution` sketch says:

> For the guard property, take any `u` with `w ≤ u ≤ v ∧ ¬(v ≤ u)`. By the
> self-accumulation form, `(φ U ψ) ∈ u`.

This claim is **not justified by any BX axiom in the inventory**.

- BX5 gives `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`. In `w.formulas`, this yields
  `(φ ∧ (φ U ψ)) U ψ ∈ w.formulas`.
- `(φ ∧ (φ U ψ)) U ψ` is an **Until formula**, not of shape `G(χ)`, so it is
  **not** in `g_content(w.formulas)`.
- Therefore `bx_le w u = g_content(w) ⊆ u.formulas` does **not** transfer
  `(φ ∧ (φ U ψ)) U ψ` from `w` to `u`.
- To derive `(φ U ψ) ∈ u`, one would need a lemma of the form
  `w ≤ u ∧ χ ∈ w.formulas → χ ∈ u.formulas` for the specific χ, which is
  precisely the missing "Until-propagation" lemma that task 86/88/89 all
  identified as the core obstruction.

**This is the same "object-logic/metalogic bridge gap" that task 90 Phase 1
correctly identified as non-derivable.** Task 90's recommendation recreates the
bridge on line 54 of `03_task92_recommendation.md` without any additional
machinery. The recommendation is internally inconsistent: it says "bypass the
bridge by constructing the trajectory directly" and then uses BX5 to pretend the
trajectory points inherit the self-accumulated Until formula. They do not —
inheritance along `bx_le` is exactly `g_content`-propagation, which is
G-restricted.

**Severity**: Blocker. If this step fails, Phase 1 cannot be completed with the
cited axiom set, and Phases 3–4 (the Since mirrors) inherit the same failure.

**Possible rescue**: Derive `G((φ U ψ)) ∈ w.formulas` somehow (so that it
propagates via `g_content`). The only axiom resembling that direction is BX4
`connect_future`, which produces `G(P(φ))`, not `G(φ)`. Nothing in the axiom set
produces `G(φ U ψ)` from `φ U ψ` — indeed, soundness of such a principle fails on
general linear orders, because "φ until ψ" is a local commitment that should not
be replayed at every future point. If this rescue is impossible, the task 90
proof sketch is **structurally wrong**, not merely under-specified.

### Issue 2 — BLOCKER — BX4's docstring explicitly disclaims the connectedness task 90 needs for `bx_until_backward`

BX4 is defined in `Axioms.lean:142-147` as `φ → G(P(φ))`, and its docstring
states verbatim:

> This replaces the Burgess-Xu Until-Since connectedness axiom, which is
> not valid under half-open guard semantics.

Task 90's backward-Until argument says:

> Use BX4 `connect_future` directly on `w` to propagate `¬(φ U ψ)` *forward*
> along the `w`-trajectory.

BX4 applied to `¬(φ U ψ) ∈ w` produces `G(P(¬(φ U ψ))) ∈ w`. Unfolded, at every
`u ≥ w`, `P(¬(φ U ψ)) ∈ u.formulas`. To use this, we then need a
**backward-witness** at some such `u` — i.e., a `u' ≤ u` with `¬(φ U ψ) ∈ u'`.
There is no guarantee that the chosen `u'` lies in the `w`-trajectory; the
problem has *moved*, not disappeared. We now need `w ≤ u'`, which is the same
linearity gap task 90 claims to have bypassed.

The task 90 recommendation explicitly says "the point is in the `w`-trajectory
by construction", but **no construction is given** — only the assertion that BX4
suffices. BX4 does not suffice on its own, and the docstring's own disavowal of
Burgess-Xu connectedness is a red flag task 90 did not engage with.

**Severity**: Blocker. This affects `bx_until_backward` (sorry #2) and
`bx_since_backward` (sorry #4, via mirror).

### Issue 3 — HIGH — "Earliest ψ-witness" via BX7 is ill-defined in the BXPoint model

Task 90 step 5 says:

> BX10 gives `F(ψ)`, BX12 gives the vacuous-guard Until form `⊤ U ψ`, which
> combined with BX7 (`linear_until` on `(φ U ψ) ∧ (⊤ U ψ)`) lets us pick the
> *earliest* ψ-witness along the trajectory.

BX7 is a **formula-level linearity**: applying `linear_until φ ψ ⊤ ψ` in
`w.formulas` yields one of three disjuncts, each an Until formula inside
`w.formulas`. None of these disjuncts pick out a particular `BXPoint`. To convert
a formula-level "earliest" into an actual MCS, one still needs the bridge from
formula-linearity to MCS-ordering — the *same* gap task 90 Phase 1 diagnosed as
non-derivable. "Earliest-ness" is a property of a specific `v`, not of an Until
formula.

The diagnostic probes 1–4 specifically demonstrated this: BX7 "produces a new
Until-form *internal to `w.formulas`*, not a linearity statement on BXPoints".
Task 90's recommendation then goes ahead and uses BX7 for BXPoint-level
"earliest selection" anyway. This is a direct contradiction with task 90's own
diagnostic evidence.

**Severity**: High. Even if Issues 1 and 2 were somehow resolved, "pick the
earliest ψ-witness" is not a step available in the current axiom set.

### Issue 4 — HIGH — Frame.lean:647-651 comment was **not** "misleading"; it was accurate

The inherited report claims the `Frame.lean:647-651` comment block is misleading:

> // Approach (B) from the module docstring (proving bx_le linearity from BX7)
> // is blocked by this G-content vs Until-witness mismatch.

The Phase 1 diagnostic **confirms** this exact claim (probes 1–4 all demonstrate
the G-content vs Until-witness mismatch). The comment is not misleading; it is
correct. What task 90 actually proposes is a **new** approach that the comment
never discussed. Calling the comment "misleading" is a rhetorical move, not a
factual correction. The comment should be *extended*, not rewritten as wrong.

If implementation proceeds under the current framing, we risk deleting accurate
historical analysis and replacing it with an as-yet-unjustified claim that BX5
self-accumulation suffices. This is a **regression in documentation accuracy**.

**Severity**: High. Affects task 92's Phase 5 (comment rewrite).

### Issue 5 — MEDIUM — Since mirror has directional asymmetry task 90 has not audited

The Since eventuality-resolution signature at `Frame.lean:683-688` is:

```
∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧
  ∀ u : BXPoint, bx_le v u ∧ ¬bx_le u v → bx_le u w → φ ∈ u.formulas
```

Note the guard universal quantifies over `u` with `v ≤ u` **and** `u ≤ w`,
strictly between `v` and `w`. The mirror BX axioms BX5'/BX6'/BX7'/BX10'/BX12'
exist in `Axioms.lean:161-264`, but the *Since*-mirror of Issue 1 requires
propagating `(φ ∧ (φ S ψ)) S ψ` from `w` **backwards** to `u` via
`bx_le u w`, which is `g_content(u) ⊆ w.formulas` — not `h_content`-based at
all. `h_content`-propagation is triggered by `bx_le v u`, not `bx_le u w`.

In other words, the Since case mixes **two different direction principles** in
its guard (one past-witness construction plus one future-extending guard). The
"mirror is straightforward" claim is not established; the guard interval is
anchored between `v` (past witness) and `w` (current point), and the inner
point `u` is simultaneously future of `v` and past of `w`. A mirror construction
must handle both directions coherently, which is strictly more complex than the
Until case. Task 90 has not discussed this.

**Severity**: Medium-high. Doubles effort estimate at minimum if discovered mid-
implementation.

### Issue 6 — MEDIUM — Estimate 8–16h has no supporting evidence

Task 90 asserts "8–16 hours (4 sorries × 2–4h each, with BX6/BX6' absorption being
the most delicate step)". No step-by-step effort breakdown is given. Compare:

- Task 89's Teammate B estimated 40–80h without temp_linearity (which was
  mistakenly believed absent but is present).
- Task 89's "8–16h with temp_linearity" referred to **standard canonical
  linearity**, NOT the Burgess-Xu induction that task 90 now recommends. The
  numbers were imported under a different assumption.
- BX6 absorption has **never been exercised** in this codebase (no existing
  theorem uses `absorb_until`), per the grep sweep I should run. See Question 1.

A realistic worst case, given Issues 1–3 and 5, is that Phase 1 alone exhausts
20–30 hours before stalling on the BX5 propagation gap. The 16-hour ceiling
should be treated as a **soft budget** not a reliable estimate.

**Severity**: Medium.

### Issue 7 — MEDIUM — Task 89's "10% confidence sorries are unprovable as stated" was never retracted

Task 89's team research concluded with **90% confidence the 4 sorries are
unprovable as currently stated** (Teammate B, explicitly at line 26 of
`089.../reports/01_team-research.md`). Task 90's rebuttal rests entirely on
"temp_linearity was already present and task 89 didn't know". But task 89's
Teammate B argued **the universal quantifier in the guard requires interval
linearity regardless of whether temp_linearity is present in the axiom set**,
because BX11/temp_linearity is formula-level and `bx_le` is MCS-level. This is
*the same* obstruction task 90 Phase 1 later confirmed. Task 90 reframed this as
"Burgess-Xu Until-induction" without disputing task 89's correctness. Task 89's
conclusion has therefore never been directly refuted; it has been **renamed**.

**Severity**: Medium. But important: task 92 is proceeding on the assumption
that task 90 supersedes task 89. In fact, task 90's diagnostic *confirms*
task 89's central diagnosis, and task 90's proposed fix inherits the same
obstruction.

### Issue 8 — LOW — Canonical "trajectory" concept is undefined

Task 90 speaks of "the w-trajectory" and points being "in w's trajectory by
construction". But in the `bx_le := g_content ⊆` setting, the
"w-trajectory" is simply the set `{u : BXPoint | bx_le w u}`, which is a
partially-ordered set with no canonical linearization (probes 1–3 of task 90
Phase 1 establish this). There is no "constructed trajectory" in the sense the
sketch uses that phrase; there is only the (non-linear) future cone. All
references to "construction by trajectory" in task 90's sketch are aspirational
language without a technical referent.

**Severity**: Low. Mostly a terminology problem, but it masks Issues 1–3 from
casual readers.

## Unvalidated Assumptions

| # | Assumption | Validation Proposal |
|---|-----------|---------------------|
| 1 | BX5 self-accumulation propagates the accumulated Until formula to all `u` with `w ≤ u` | Probe with `lean_multi_attempt` at `Frame.lean:653`: assume `(φ U ψ) ∈ w`, derive `(φ ∧ (φ U ψ)) U ψ ∈ w` via BX5, then try to show this formula holds at an arbitrary `u` with `bx_le w u`. Expect failure. Classify as Option-A-style bridge-gap. |
| 2 | BX4 `connect_future` plus a backward witness produces a point in the `w`-trajectory | Probe: assume `¬(φ U ψ) ∈ w`, `bx_le w v`, apply BX4 to get `G(P(¬(φ U ψ))) ∈ w`, transfer to `v`, take backward witness `u' ≤ v`. Goal: show `w ≤ u'`. Expect failure (same obstruction). |
| 3 | BX7 applied to `(φ U ψ) ∧ (⊤ U ψ)` selects a specific BXPoint | Probe: derive the BX7 disjunction in `w.formulas`, then attempt to extract a `v : BXPoint` corresponding to "the earliest ψ witness". Expect failure — the disjunction is still formula-level. |
| 4 | BX6 absorption is usable mid-proof | Search codebase for any existing use of `absorb_until` to confirm it has tooling support. |
| 5 | Since mirror "straightforwardly applies" via primed axioms | Manually walk Issue 5 guard interval in the plan phase. Do not assume symmetry. |
| 6 | 8–16h effort estimate is realistic | Rebaseline after Phase 1 diagnostic (Questions 1–3 below) — do not commit to the estimate until the BX5 propagation probe has been attempted. |
| 7 | Closing these 4 sorries does not require closing task 93's Box sorry | Grep cross-references; verify that `box_preserved_along_bx_le` and `bx_G_forward` are used unconditionally by the Until lemmas (probably yes but not verified). |
| 8 | No other BX axiom is quietly required | Re-read proof sketch and build the literal axiom use list. In particular, what role does BX9 `until_elim` play in producing `φ ∨ ψ ∈ u` when `(φ U ψ)` may not even be in `u`? Issue 1 shows this step may be skipped over a gap. |

## Axiom Audit Results

| Cited Axiom | Statement in `Axioms.lean` | Matches Task 90 sketch? |
|-------------|----------------------------|--------------------------|
| BX4 `connect_future` | `φ → G(P(φ))` (line 146) | **No** — docstring disavows the Burgess-Xu Until-Since connectedness principle the sketch needs. Issue 2. |
| BX5 `self_accum_until` | `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` (line 157) | **Partially** — produces the right formula in `w.formulas`, but that formula does not propagate along `bx_le`. Issue 1. |
| BX6 `absorb_until` | `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)` (line 169) | Matches, but codebase usage is zero. Assumption 4. |
| BX7 `linear_until` | `(φ U ψ) ∧ (χ U θ) → (((φ∧χ) U (ψ∧θ)) ∨ ((φ∧χ) U (ψ∧χ)) ∨ ((φ∧χ) U (φ∧θ)))` (line 180) | Matches, but formula-level linearity does not imply BXPoint-level earliest selection. Issue 3. |
| BX9 `until_elim` | `(φ U ψ) → (φ ∨ ψ)` (line 214) | Matches, but invocation at `u` requires `(φ U ψ) ∈ u`, which Issue 1 blocks. |
| BX10 `until_F` | `(φ U ψ) → F(ψ)` (line 226) | Matches. Used together with `bx_forward_witness` — sound step. |
| BX11 `temp_linearity` | `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)` (line 240) | **Not used** in task 90 sketch despite being listed in the linearity discussion. Suggests the sketch is inconsistent or BX11 should be explicitly justified as unneeded. |
| BX12 `F_until_equiv` | `F(φ) → (⊤ U φ)` (line 258) | Matches. Used as F↔Until bridge — sound but insufficient alone. |

Primed duals BX5'/BX6'/BX7'/BX10'/BX11'/BX12' are all present at lines 161–264.
The mirror axiom inventory **is complete**, but Issue 5 still applies.

## Scope Fence Cross-Dependencies

The four Until/Since lemmas depend on:

- `bx_forward_witness` (line 164) — sorry-free, sound step.
- `bx_backward_witness` (line 176) — sorry-free, sound step (used by `bx_since_*`).
- `bx_G_forward` (line 192) — sorry-free, trivially follows from `bx_le` definition.
- `h_content_subset_implies_g_content_reverse` (referenced inside
  `bx_backward_witness`) — not audited but assumed sorry-free.
- `box_preserved_along_bx_le` — NOT in the visible portion; assumed sorry-free
  per the task 90 scope fence.
- **`bx_G_backward`** (line 208) uses `g_content_closed_derivation`; also assumed
  sorry-free.

I did not find evidence that any of the 4 Until/Since lemmas depend on the Box
modal-witness sorry at `Frame.lean:440` or on `Completeness.lean:154`. **Scope
fence appears intact** at the dependency level.

**However**: the scope fence does NOT protect task 92 from discovering mid-
implementation that it needs a new sorry-free helper lemma that lives close to
the Box sorry and therefore triggers task 93 work. I recommend the plan
explicitly identify a "new helper lemma budget" with a cap (e.g., "no more than
two new sorry-free helper lemmas; if a third is required, escalate").

## Task 89 Lessons

Task 89 (archived as superseded) concluded, with 90% confidence across 4
teammates:

1. The `∀ u : BXPoint, bx_le w u → ... → φ ∈ u.formulas` guard requires
   interval linearity of `bx_le`.
2. Interval linearity is not derivable from any combination of BX7/BX11/BX12
   because BX11 is formula-level and `bx_le` is MCS-level.
3. The only viable fixes are: (a) redefine `bx_le` (Option A), (b) re-add
   `temp_linearity` — which was mistakenly believed absent — or (c) adopt a
   quasimodel.

Task 90 correctly refuted (b) (the axiom was present all along) and correctly
refuted (a) (Option A has non-equivalence and non-transitivity flaws). Task 90
then introduced a fourth path ("Burgess-Xu Until-induction") which it asserts is
neither (a) nor (c).

**The lesson task 92 must heed**: task 89's central diagnosis — that the guard
requires an interval-linearity-like property that the bridge gap prevents —
has never been refuted. Task 90's recommendation asserts the property holds
"by construction" but does not exhibit the construction. Task 92 is therefore
at risk of repeating task 89's failure mode under a new name.

## Revised Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| BX5 propagation gap blocks Phase 1 (Issue 1) | **High (70%)** | Phase 1 unclosable | Run Phase 0 diagnostic probe before Phase 1 implementation (<2h) |
| BX4 docstring disavowal blocks Phase 2 (Issue 2) | **High (65%)** | Phase 2 unclosable | Run Phase 0 diagnostic probe for Issue 2 |
| BX7 "earliest selection" blocks (Issue 3) | Medium (50%) | Forces algorithmic reshuffle | Delay until Phases 1–2 succeed |
| Since mirror asymmetry adds hours (Issue 5) | Medium-high (60%) | +4–8h | Audit Since guard manually before Phase 3 |
| 8–16h estimate blown | **High (75%)** | Schedule slip; user frustration | Communicate revised estimate upfront |
| All 4 sorries remain blocked; `/spawn 92` needed | **Medium-high (55%)** | Task 92 produces task 94 instead of closing sorries | Pre-approve `/spawn 92` as an acceptable outcome; set a Phase 1 time box |
| Comment rewrite deletes accurate history (Issue 4) | High (90% if implementation proceeds) | Regression in documentation accuracy | Require plan phase 5 to preserve the existing comments as historical notes alongside any new Burgess-Xu comment |

## Questions for Implementation Phase

1. **Before Phase 1**: Can BX5 `self_accum_until` + `bx_G_forward` + any helper
   derive `(φ ∧ (φ U ψ)) U ψ ∈ u.formulas` from `(φ U ψ) ∈ w.formulas` and
   `bx_le w u`? Run `lean_multi_attempt` at `Frame.lean:653`. If no: Phase 1 is
   blocked.
2. **Before Phase 2**: Can BX4 `connect_future` produce a backward witness that
   lies in `[w, v]`? Run `lean_multi_attempt` at `Frame.lean:675`. If no: Phase
   2 is blocked.
3. **Before Phase 1**: Does `absorb_until` (BX6) have any existing use in the
   codebase? If zero, factor in tooling-absence overhead.
4. **Before Phase 3**: Walk the Since guard interval (Issue 5) on paper and map
   each step to a primed axiom. If any step lacks a primed axiom, Phase 3 is
   blocked.
5. **Cross-cutting**: What is the time-box for each phase before `/spawn 92` is
   invoked? Task 90 says "do not escalate preemptively" — but with a 75%
   probability of budget overrun, a concrete escalation trigger is needed.
6. **Documentation**: Which parts of the existing `Frame.lean:647-651` comment
   should be preserved as historical analysis? (Answer: all of it, plus a new
   "Burgess-Xu attempt (task 92)" addendum.)

## Confidence Level

**Confidence in task 90's recommendation closing all four sorries: 25%.**

Justification:
- Task 90's Phase 1 diagnostic is **rigorous** (probes 1–4 are sound, verdict
  (b) is correct). +20%.
- Axiom inventory audit is correct (BX5/6/7/9/10/11/12 and primes present). +10%.
- Scope fence and non-dependence on task 93 work appears sound. +10%.
- BX5 propagation step (Issue 1) is **unsound as stated** and has no obvious
  rescue. −30%.
- BX4 disavowal (Issue 2) undermines Phase 2. −15%.
- BX7 "earliest selection" (Issue 3) directly contradicts task 90's own
  diagnostic evidence. −10%.
- Since mirror asymmetry (Issue 5) is unaudited. −5%.
- Effort estimate (Issue 6) is unsupported. −5%.

Net: 25%.

**If Phase 0 diagnostic probes (Questions 1 and 2) succeed**, my confidence
rises to 65%. If they fail, confidence falls to 10% and I recommend invoking
`/spawn 92` immediately with "BX5 propagation gap" as the blocker to create
task 94 (quasimodel or Hintikka pivot).

## Recommendation to Planner

1. **Insert Phase 0: Diagnostic Gate** (≤ 2 hours). Run Questions 1, 2, 3 probes
   via `lean_multi_attempt` at Frame.lean:653 and :675. Record outcomes. Go/no-
   go decision based on whether BX5 self-accumulation and BX4 propagation can
   be made to discharge the bridge step.
2. **Insert Phase 0.5: Budget Check**. If Phase 0 succeeds, commit to the
   8–16h estimate. If Phase 0 fails on any probe, escalate to `/spawn 92` with
   the specific probe failure as the blocker and mark task 92 [BLOCKED],
   pending new task 94.
3. **Explicit escalation trigger in Phase 1**: if 8 hours elapse without a
   closed `bx_until_eventuality_resolution`, stop and `/spawn 92`.
4. **Documentation preservation**: Do NOT replace `Frame.lean:647-651` comment;
   extend it with a "Burgess-Xu attempt" subsection.
5. **Do not tolerate sorry deferral** under any circumstance (zero-debt
   policy). If the probes fail and Burgess-Xu does not close the sorries,
   the correct outcome is [BLOCKED] + task 94, not a partial commit with
   residual sorries.

---

*This report is a critic's assessment and should be read alongside task 92's
other teammate findings. It does not reject the Burgess-Xu approach outright;
it flags three specific technical gaps (BX5 propagation, BX4 connectedness
disavowal, BX7 earliest-selection) that the task 90 recommendation leaves
unaddressed, and proposes a Phase 0 diagnostic gate to resolve them before
implementation hours are committed.*
