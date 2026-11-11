# Implementation Plan: Task #916

- **Task**: 916 - Dispatch or compile a refutation of the ANTITONE slice of a `kappa`-class collision — the complement that `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` excludes in its own quantifier
- **Status**: [IMPLEMENTING]
- **Effort**: 14 hours
- **Dependencies**: None (every predecessor artifact is landed and compiled; parent task 910)
- **Research Inputs**: `specs/916_antitone_collision_residue_lower_pair_witnessing/reports/01_antitone-collision-residue-witnessing.md`
- **Artifacts**: plans/01_antitone-slice-dispatch.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

DISPATCH the antitone slice, in both directions, as depth-`0` cell EQUALITY — not a refutation.
The slice is not one object: it splits along a compiled line into a BOUNDED-DESCENT sub-slice
(`n − n' ≤ m · (P + 1)`) and a DEEP-DESCENT residue (`n − n' > m · (P + 1)`), and the two have
different prices. Done means: one exhaustive antitone schema whose upward payment is the
truncated amount `(n − n') − m · (P + 1)`, a compiled record that an amount-`0` witnessing
obligation is FREE, and a bounded-sub-slice corollary that therefore carries NO upward hypothesis
at all; zero sorries; no new axiom; and the reserved name `cellLE_zero_const_of_kappa_eq` still
claimed by nothing.

The route the dispatch names — forward-slack witnessing at the LOWER pair — is the right route
for the DEEP-DESCENT residue and only for it. The bounded sub-slice is reached without it,
because the raise already in the construction buys exactly `m · (P + 1)` of slack from no
hypothesis whatever.

### Research Integration

The research report is integrated in full. Its primary finding — that the slice splits, and that
the predecessor's own non-vacuity witness `(4, 2)` against `(6, 0)` lies in the CHEAPER half —
is what gives this plan its shape: a plan treating the slice as monolithic would
over-hypothesize the bounded half. Its sequencing note (items 1-3 independent, 2 after 1, 5-6
after 2/3/4, 4 cheapest and first) is the dependency structure of the wave table below.

**One deliberate departure from the report's recommendations, grounded in a probe compiled during
this planning dispatch.** The report recommended TWO schemas (its items 5 and 6): a
bounded-sub-slice schema carrying no upward hypothesis, and a separate deep-descent schema
carrying the lower-pair one. This plan lands ONE exhaustive schema plus a bounded corollary
instead, because `ForwardSlackWitnessed … z 0 n` turns out to be a THEOREM, not a hypothesis —
see fact (D) below. The truncated natural-number amount `(n − n') − m · (P + 1)` is literally
`0` on the bounded sub-slice, so one schema covers the whole slice while the bounded half's
freedom becomes a compiled corollary rather than a second signature. This gets the report's
stated goal (do not over-hypothesize the bounded half) with one schema instead of two, and keeps
the schema exhaustive against the dichotomy.

### The arithmetic, re-derived before it is scheduled

Every figure this plan carries from the research report was RE-DERIVED by running Lean during
this planning dispatch (`lean_run_code`), not copied. All ten of the report's probes came back
green — zero diagnostics on the three `kappa` probes, unused-variable linter warnings only on the
seven arithmetic ones. Three further probes, not in the report, were compiled here. The four
facts that matter:

**(A) The antitone anchor clause closes under the DISPLACED Lipschitz bound once the descent is
paid.** With `k` the register's descent and `mP := m · (P + 1)`:

```lean
example (X nz cz mP n₀ d k : ℤ)
    (hX : 0 ≤ X) (hmP : 0 ≤ mP) (hn₀ : 0 ≤ n₀) (hk : 0 ≤ k)
    (hfar : cz + mP < d) (hlip : X ≤ nz + d - mP) (hgap : nz + 2 ≤ cz)
    (hdesc : n₀ + k = nz) (hkle : k ≤ mP) (hhi : n₀ ≤ cz + mP) :
    (X - n₀).natAbs ≤ d.natAbs := by omega
```

and the RAW Lipschitz bound `(X − nz).natAbs ≤ d.natAbs` is NOT enough even with `k ≤ mP`, at
`X = 24, nz = 8, cz = 10, mP = 5, n₀ = 3, d = 16, k = 5`. So the raise's `habove` exposure is
load-bearing, not a convenience.

**(B) The keystone of the widened free-anchor raise.** The two-sided anchor clause at deleted
length `0`, on the RAISED path, from the raise-transported slack `L + mP` plus the RELAXED lower
bound — with no raw Lipschitz bound anywhere in it:

```lean
example (Y nz cz cz1 I n₀ mP L : ℤ)
    (hY : 0 ≤ Y) (hI : 0 < I) (hmP : 0 ≤ mP) (hL : 0 ≤ L) (hn₀ : 0 ≤ n₀)
    (hcz1 : cz1 = cz + mP) (hgap : nz + 2 ≤ cz) (hhi : n₀ ≤ cz1)
    (hrelax : nz ≤ n₀ + (mP + L)) (hslack : Y ≤ nz + cz1 + I - (L + mP)) :
    (Y - n₀).natAbs ≤ (cz1 + I - 0).natAbs := by omega
```

At `L = 0` with the LANDED lower bound `nz ≤ n₀` in place of `hrelax`, the same clause closes —
so the widening is conservative, hypothesis for hypothesis.

**(C) The DOWNWARD antitone half costs NO room bound beyond the lower pair's own gap.** At the
RAISED anchor `n₀ := n`, higher-pair countdown `cz = c + mP`, slack amount `mP`:

```lean
example (Y c n cz I mP : ℤ)
    (hY : 0 ≤ Y) (hI : 0 < I) (hmP : 0 ≤ mP)
    (hcz : cz = c + mP) (hgap : n + 2 ≤ c) (hslack : Y ≤ n + cz + I - mP) :
    (Y - n).natAbs ≤ (cz + I - 0).natAbs := by omega
```

`hgap` here is exactly the lower pair's own pending-forever gap `n + 2 ≤ c`. The monotone
schema's downward half spends `mP + (n' − n)` and carries a room bound `n' + (n' − n) ≤ c`; the
antitone downward half spends `mP` and carries no room bound at all. A register RAISE is free in
the direction that costs, because lowering is what the upper direction of the anchor clause
charges for and a raise moves the other way.

**(D) An amount-`0` forward-slack witnessing obligation is FREE.** Compiled here, zero
diagnostics, and the fact the report did not have:

```lean
example {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (z : ℤ) :
    ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c, n), h⟩ : LadderState Q pend) z 0 n := by
  intro T hT
  rw [mem_cellAt_ladder_iff] at hT
  obtain ⟨g, τ, hg, hgz, hτ, hty⟩ := hT
  have hnz : nxtAt g z = n := by simp [nxtAt, hgz]
  refine ⟨g, τ, hg, hgz, hτ, ?_, hty⟩
  have := hasForwardSlack_zero g hg z
  rwa [hnz] at this
```

**(E) The deep-descent residue is real, and the landed necessity record is untouched.** The
RELAXED lower bound `nxtAt g z ≤ n₀ + mP` is itself non-removable, at
`X = 19, nz = 8, cz = 10, mP = 1, n₀ = 0, d = 12` — a deep-descent witness (`k = 8 > 1 = mP`) —
even WITH the displaced Lipschitz bound in hand. And
`free_register_anchor_clause_monotone_required`'s own witness has `mP = 0`, where the relaxed
bound IS the landed bound, so that record stays compiled, unamended and uncontradicted: its
bound is non-removable, as it says; what is new is that the bound is RELAXABLE by exactly the
raise.

**(F) Both halves of the split are non-empty inside the regime.** `(4, 2)` against `(6, 0)` at
`Tc = Tn = P = 0`, `B = 2`, `m = 2`: collides, in regime, not monotone, `n − n' = 2 = m · (P + 1)`
— BOUNDED. `(10, 8)` against `(11, 0)`, same parameters, `m = 1`: collides, in regime, not
monotone, `m · (P + 1) = 1 < 8 = n − n'` — DEEP. Both `by decide`, both green here.

### Prior Plan Reference

No prior plan for this task. The parent task 910's plan
(`specs/910_saturated_gap_branch_kappa_collision_regimes/plans/01_saturated-gap-monotone-dispatch.md`)
was read for CALIBRATION only, not as a template: its seven phases over ten hours covered a
comparable surface in the same two modules, which is the basis for this plan's own estimates;
its final-phase gate set and its handling of the deployed-tree staleness baseline are reused as
patterns; and its `[COMPLETED WITH EXCLUSIONS]` Phase 2 is the reason this plan carries no
contingent retirement phase (nothing landed here supersedes a landed signature). No phase of
that plan is copied.

### Roadmap Alignment

No `roadmap_path` was provided on this dispatch and no roadmap flag is set, so no roadmap
consultation was performed and no roadmap phases are present.

## Goals & Non-Goals

**Goals**:
- `exists_ladderPath_through_shifted_slack_of_pend_past` -- the regime-A raise with the
  raise-bought forward slack EXPOSED in its signature: `HasForwardSlack g' z (L + m · (P + 1))`
  from `HasForwardSlack g z L`, which the landed assembly discards.
- `exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` -- the exact-shift
  deletion with the target register RAISED rather than lowered, at slack amount `m · (P + 1)`
  unchanged.
- `AntitoneCollisionDisplacement` -- the named complement shape, exactly as
  `kappa_collision_monotone_or_antitone` already produces it.
- `kappa_collision_monotone_or_antitone_named` -- the landed dichotomy restated over the two
  named predicates, so the exhaustiveness is readable without unfolding.
- `kappa_collision_antitone_descent_multiple` -- the register's descent across a collision is
  itself a multiple of `P + 1`, which is what makes the split a comparison of two integers.
- `kappa_collision_antitone_bounded_descent_nonvacuous` -- the BOUNDED sub-slice is non-empty
  inside the pending-forever regime above the threshold.
- `kappa_collision_antitone_deep_descent_nonvacuous` -- the DEEP-DESCENT residue is non-empty
  too, so the bounded sub-slice does not exhaust the slice.
- `exists_ladderPath_through_free_register_shifted_slack_of_pend_past` -- the free-register raise
  with the lower bound on the anchor RELAXED to `nxtAt g z ≤ n₀ + (m · (P + 1) + L)` under
  forward slack `L` at the lower pair.
- `free_register_anchor_clause_relaxed_bound_required` -- the compiled record that the RELAXED
  bound is itself non-removable, with its deep-descent arithmetic witness.
- `cellAt_subset_of_antitone_register_shift_of_pend_past` -- the UPWARD antitone cell inclusion,
  under lower-pair witnessing at the truncated amount `(n − n') − m · (P + 1)`.
- `cellAt_subset_of_antitone_register_shift_of_pend_past_rev` -- the DOWNWARD antitone cell
  inclusion, under higher-pair witnessing at amount `m · (P + 1)` and no room bound.
- `forwardSlackWitnessed_zero` -- the amount-`0` witnessing obligation is free.
- `CellLEZeroConstOfKappaEqAntitoneForwardSlack` -- the depth-`0` cell-equality schema for the
  whole antitone slice, with both directions' payments stated in its quantifier.
- `cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack` -- that schema is a theorem at every
  parameter tuple `ParamsOk` admits.
- `cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` -- the BOUNDED sub-slice as
  cell equality carrying NO upward hypothesis, which is where fact (D) is spent.

**Non-Goals**:
- The reserved name `cellLE_zero_const_of_kappa_eq`. It stays reserved and claimed by nothing. No
  phase lands anything under it. Every schema here is strictly stronger in hypotheses than the
  reserved statement and bears on its truth value in NEITHER direction; each one's docstring says
  so in those words.
- Discharging `ForwardSlackWitnessed`. Whether such a hypothesis is satisfiable at any state the
  induction one layer up reaches is this dispatch's explicit out-of-scope line and is sibling task
  917's subject. Every schema here STATES the hypothesis; none attempts to discharge it, with the
  one exception of the amount-`0` case, which is discharged because it is free rather than because
  the general question has been answered. `forwardSlackWitnessed_zero`'s docstring states that
  distinction explicitly.
- A REFUTATION of the slice. Both admissible outcomes were weighed in research and the dispatch
  outcome is DISPATCH: the obstruction was an exposure gap in a landed signature plus a hard-coded
  direction in a landed `hk`, not a mathematical barrier, and the compiled probes close the
  arithmetic in both directions. Should any phase discover a genuine barrier, the contingency in
  Rollback/Contingency below is a compiled refutation record, never an argued one.
- Amending, retiring or contradicting `free_register_anchor_clause_monotone_required`. Its bound
  is non-removable, as it compiles; fact (E) is a different claim and is consistent at that
  record's own witness. Its signature and body are untouched.
- Retiring `exists_ladderPath_through_shifted_of_pend_past`,
  `exists_ladderPath_through_free_register_shifted_of_pend_past`,
  `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`, or any landed schema.
  Each new declaration is a SIBLING; no landed signature or body is edited. The specialization
  relationships are recorded in docstrings only.
- `docs/theorem-index.md`. It carries no row for any `LadderCell.lean` or `LadderChain.lean`
  declaration (confirmed by `grep` at authoring time: `monotone_of_forwardSlack`,
  `free_register_shift_of_pend_past` and `kappa_collision_antitone_residue` all return nothing),
  and the file is declared `file_scope` of ten other tasks. No phase reads or writes it.
- Any `(K1)` or `(K2)` amendment, any change to the parameter contract, and any weakening of
  `HasForwardSlack` or statement of a state-level per-path register regime (refuted by
  `ClimbWitness.hasForwardSlack_refuted_unconditional`).
- Hand-patching anything under `.claude/**`. The dispatch context reports that deployed tree
  STALE for five extensions; that staleness is pre-existing, is recorded as baseline in the final
  phase, and is not remedied here.

## Decisions

- **Two declarations land in `LadderChain.lean`, not in `LadderCell.lean`.** This widens the
  task's declared `file_scope`, which named only `LadderCell.lean` and `RaySummary/README.md` at
  dispatch time, and it departs from parent task 910's plan, which declared `LadderChain.lean` a
  non-goal. The reason is the research report's finding F9, confirmed by read: the regime-A raise
  `exists_ladderPath_through_shifted_of_pend_past` DISCARDS (`-` pattern at
  `LadderChain.lean:1013`) the `habove` clause its own `_idx_` inner call returns, so the
  raise-bought slack is not reachable from its signature at all. No reading of landed material
  from the cell layer can recover it; the exposure has to happen in the module that owns the
  assembly. The register-RAISING deletion is in the same position: its sibling hard-codes
  `hk : n₀ + k = nxtAt g z`, forcing `n₀ ≤ nxtAt g z`, in its own signature. Both additions are
  pure siblings inside existing sections (`AssemblyFin`, `DelNxt`'s successor), and
  `LadderChain.lean` is not in any other non-terminal task's `file_scope`.
- **One exhaustive schema plus a bounded corollary, not two schemas.** Grounded in fact (D),
  compiled at plan time. See "Research Integration" above for the full reasoning and for the
  departure from the report this represents.
- **The split's three records land FIRST, before any assembly is touched.** They are independent
  of everything, all five proofs are compiled already, and landing them gives a green commit and
  a readable statement of what the rest of the plan is dispatching. This is the report's own
  sequencing recommendation.
- **The antitone schema carries NO room bound.** The monotone schema carries
  `n' + (n' − n) ≤ c` in its quantifier; fact (C) shows the antitone downward half needs nothing
  beyond the lower pair's own gap, and the upward half's `n' ≤ c + m · (P + 1)` follows from
  `n' < n` and `n + 2 ≤ c` by `omega`. Neither is promoted to a hypothesis.
- **Both orientations of the antitone disjunction are handled by the same two inclusions.** The
  second disjunct (`c = c' + m · (P + 1) ∧ n < n'`) is the first with the roles of `(c, n)` and
  `(c', n')` swapped, and cell equality is symmetric, so the schema's proof applies the same two
  inclusions through `Set.Subset.antisymm` in both branches — exactly as
  `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` does.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The `habove` exposure does not survive the regime-A raise's internal block choice: the block `(u, l)` comes from `exists_typeBlock_of_budget_le_cnt_within` and the raise uses `m · q` copies with `q · l = P + 1`, while `hasForwardSlack_raise` needs `hul : u + l ≤ z + cntAt g z` | H | L | The identical composition is already compiled at `LadderChain.lean:1979-1990` in `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`, with the same block source and the same `hul'` derivation the raise already performs. Phase 2 is built and built-green ALONE, before Phase 4 is written. |
| The register-raising deletion's `hgap`/`hroom` bookkeeping: the module's own docstrings record that none of `hgap`, `hgap'`, `hroom` implies another | M | M | Carry `n₀ + 2 + m · (P + 1) ≤ cntAt g z` as a NAMED hypothesis rather than deriving it, exactly as the research report's mitigation prescribes. Fact (C) compiles the clause it has to close, and the two re-lift inputs (`n₀ + mP ≤ cz`, `Tc + mP ≤ cz`) both follow from it by `omega`. |
| `decide` cost on the deep-descent non-vacuity witness: `kappa 0 0 0 2 (10, 8)` carries larger numerals than any landed witness | L | L | It compiled green at `by decide` both in research and again in this planning dispatch. Recorded only because a future witness with larger `B` may not; if it regresses, replace `decide` with `kappa_eq_components` plus `omega` rather than enlarging the witness. |
| Scope creep into the `ForwardSlackWitnessed` discharge (sibling task 917) | M | M | Each schema's docstring repeats that the hypothesis is one a CONSUMER supplies, and `forwardSlackWitnessed_zero`'s docstring states that discharging the amount-`0` case settles nothing about the general question. Phase 7's verification greps for the reserved name and reads the three docstrings against this criterion. |
| Territory collision with sibling task 917, which declares the same `LadderCell.lean` in its `file_scope` | M | L | 917 is `not_started`, so no concurrent writer exists at authoring time. Should it become live, the collision is on one file and is handled by serialization (`--depends-on-add`), not by exclusion, per `batch-orchestration-guardrails.md`'s Batching Is the Default. |
| A `verify-deploy.sh` gate is red for reasons unrelated to this task (the dispatch context reports the deployed `.claude/` tree STALE for core, lean, literature, memory and typst) | M | H | Condition 2 of `plan-authoring-gate-collisions.md`: the final phase's criterion distinguishes findings naming this task's own touched files from the tree's standing baseline, never a bare "the gate passes". The staleness is pre-existing, is NOT remedied here, and no phase hand-patches under `.claude/**`. |
| Line-count drift leaves the generated module-inventory blocks stale | L | H | Final-phase deliverable: edit the Description cells first, then `bash scripts/check-module-invariants.sh --emit-inventory` (which preserves Description text and refreshes only counts), then `--emit-inventory --check`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4, 6 | 2, 3 |
| 3 | 5 | 4 |
| 4 | 7 | 1, 5, 6 |
| 5 | 8 | 7 |

Phases within the same wave can execute in parallel. This plan is nevertheless executed
SEQUENTIALLY in phase order: every phase stages the same generated `typst/generated/status.typ`,
so two phases running concurrently would collide on that one blocking pre-commit surface even
where their logical dependencies permit parallelism. The wave table records the logical
dependency structure; the serialization is a generated-file constraint, not a logical one.

### Phase 1: Name the Antitone Shape and Land Its Split Records [COMPLETED]

**Goal**: `AntitoneCollisionDisplacement`, the named dichotomy, the descent destructor and the
two non-vacuity witnesses compile in `LadderCell.lean`'s existing `section Collision`, so the
split the rest of the plan dispatches is stated rather than tacit.

**Tasks**:
- [ ] Add `AntitoneCollisionDisplacement` immediately after `kappa_collision_monotone_or_antitone`
      in `section Collision`, at the signature pinned in `## Lean Challenge Statements` below —
      the exact disjunction that theorem's second disjunct already produces, so the two are
      definitionally equal.
- [ ] Add `kappa_collision_monotone_or_antitone_named` as the landed dichotomy restated over the
      two named predicates. The proof is `exact kappa_collision_monotone_or_antitone … hk`: the
      conclusion is definitionally the landed one. Do NOT edit
      `kappa_collision_monotone_or_antitone`'s own statement or body — the named form is a
      sibling, and its docstring says that the two are the same theorem read through a name.
- [ ] Add `kappa_collision_antitone_descent_multiple`, with the compiled proof: destructure by
      `kappa_eq_components` for the register residue, read it through
      `Nat.modEq_iff_dvd'` at `n' ≤ n`, orient by `Nat.mul_comm`, close by `omega`. This is the
      record that makes `n − n' ≤ m · (P + 1)` a comparison of two multipliers rather than of two
      raw registers.
- [ ] Add `kappa_collision_antitone_bounded_descent_nonvacuous` at the witness
      `Tc = Tn = P = 0, B = 2, (c, n) = (4, 2), (c', n') = (6, 0), m = 2`, with `by decide` for
      the `kappa` equality and `rintro`/`omega` for the non-monotone clause. Its docstring records
      the significant fact: this is the predecessor's OWN non-vacuity witness
      (`kappa_collision_antitone_residue_nonvacuous`), and it lies in the half that needs no
      upward hypothesis.
- [ ] Add `kappa_collision_antitone_deep_descent_nonvacuous` at the witness
      `Tc = Tn = P = 0, B = 2, (c, n) = (10, 8), (c', n') = (11, 0), m = 1`, same proof shape.
      Its docstring says what it is for: the bounded sub-slice does not exhaust the slice, so the
      lower-pair route is not decorative.
- [ ] Scoped `lake build`, then `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` with the Lean change in one commit.

**Timing**: 1 hour 30 minutes

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly FIVE new declarations and no new section header,
and modifies no existing declaration's signature or body. The five proofs were each compiled
during this planning dispatch (the report's probes 5, 6, 7 plus two one-liners), so the
hypothesis is about the EDIT's extent, not about the proofs' viability. Confirm at implementation
time with `git diff --stat` on the module plus a `git diff` read-through showing only additions
inside `section Collision`.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths
(no shell suite covers a `.lean` or generated-`typst` path), so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module this phase edits with no externally visible signature change.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - five new declarations in `section Collision`
- `typst/generated/status.typ` - regenerated line counts; blocking pre-commit surface, staged in this phase's own commit

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`
  exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_antitone_deep_descent_nonvacuous`
  reports no `sorryAx` and no custom axiom beyond the module's own recorded profile.
- `grep -n "theorem kappa_collision_monotone_or_antitone\b" -A 8` shows the landed dichotomy's
  statement byte-identical to its pre-phase form.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 2: Expose the Raise-Bought Forward Slack [COMPLETED]

**Goal**: `exists_ladderPath_through_shifted_slack_of_pend_past` compiles in
`LadderChain.lean`'s existing `section AssemblyFin`, returning the regime-A raise's four landed
clauses PLUS `HasForwardSlack g' z (L + m · (P + 1)) (nxtAt g z)`.

**Tasks**:
- [x] Add the theorem immediately after `exists_ladderPath_through_shifted_of_pend_past` in
      `section AssemblyFin`, at the signature pinned below. Leave the landed assembly's signature
      and body untouched. *(deviation: altered — the pinned SIGNATURE is landed verbatim, but the
      pinned PLACEMENT is impossible: `HasForwardSlack` is defined at `LadderChain.lean:1218` in
      `section DelNxt` and `hasForwardSlack_raise` at `:1347` in `section Slack`, both BELOW
      `section AssemblyFin` (844-1066), so a declaration whose conclusion mentions either cannot
      sit in `AssemblyFin`. Landed at the end of `section Slack` instead, with the placement
      reason recorded in its own docstring. The landed assembly's signature and body are
      untouched, as required.)*
- [ ] Build the body as the landed assembly's spine with exactly two changes: call
      `exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` (the `_idx_` variant, which
      RETURNS `habove`) in place of the non-`_idx_` wrapper, and assemble the raise's slack from
      it. The landed assembly already derives everything the swap needs: `hz`, `hbud`, `σ₀`/`hσ₀`,
      the block `(u, l, hl, hlb, hzu, hcl, hul, hrep, hty)`, `hpast_u`, `hpu`, the divisor
      `q` with `hq`, `hdl : (m * q) * l = m * (P + 1)`, and `hul'`.
- [ ] Recover the four landed conclusion clauses from the `_idx_` variant's richer ones exactly as
      the non-`_idx_` wrapper at `LadderChain.lean:1009-1013` does: `objAt g' z = objAt g z` by
      `iterSpliceIdx_of_lt` at `z`, the countdown by `hcz` and `hdl`, the register verbatim, and
      the type clause by `iterSpliceIdx_of_lt` at `z` composed with
      `tpOf_stabFree_eq_of_objAt_eq`.
- [ ] Assemble the slack clause with the five-line idiom already proven at
      `LadderChain.lean:1979-1990`: build `hobj_above` from the `_idx_` variant's `hobj₁` through
      `iterSpliceIdx_of_ge` paired with its `habove₁`, then
      `rw [hdl]; exact hasForwardSlack_raise g hg z hul' hslack g' hg' hcz hobj_above`.
- [ ] Write the docstring in the module's voice: name the ONE clause the landed assembly discards
      and where (`LadderChain.lean`'s non-`_idx_` wrapper, `-` pattern), state the accounting the
      raise pays (`a raise increases the amount by exactly d · l`, citing
      `hasForwardSlack_raise_of_zero`'s own docstring rather than paraphrasing it), and record
      that `L = 0` needs no hypothesis because `hasForwardSlack_zero` supplies it free.
- [ ] Scoped `lake build` on `LadderChain`, then `typst-sync-check.sh --fix`, then commit.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly ONE new declaration to `LadderChain.lean` and
modifies no existing declaration. The hypothesis carried from the research report (its finding
F9) is that the landed assembly's `habove` discard at `LadderChain.lean:1013` and the recovery
idiom at `LadderChain.lean:1979-1990` are both present as described — both were re-read directly
at those lines during this planning dispatch and hold. Confirm the edit's extent at
implementation time with `git diff --stat` on the module.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths
(no shell suite covers a `.lean` or generated-`typst` path), so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`,
which elaborates the single module this phase edits; the addition is a new sibling symbol with no
existing signature changed, so no dependent module's call sites move.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - one new declaration in `section AssemblyFin`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`
  exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_through_shifted_slack_of_pend_past`
  reports no `sorryAx` and no custom axiom beyond the module's own recorded profile.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`
  exits 0, confirming the one direct dependent still elaborates.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 3: The Register-RAISING Exact-Shift Deletion [COMPLETED]

**Goal**: `exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` compiles in
`LadderChain.lean`, delivering the register at a prescribed `n₀ ≥ nxtAt g z` at slack amount
`m · (P + 1)` unchanged.

**Tasks**:
- [ ] Add the theorem immediately after
      `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`, at the signature
      pinned below. Leave the lowered sibling's signature and body untouched.
- [ ] Build the body as the lowered sibling's proof with exactly one step changed: in place of its
      `hslack₀` trade (which spends the `k` of a lowering), derive
      `HasForwardSlack g z (m * (P + 1)) n₀` from `hslack : HasForwardSlack g z (m * (P + 1)) (nxtAt g z)`
      by the monotone-in-`n` step fact (C) of the Overview compiles — `intro I hI hidle hnext`,
      `have := hslack I hI hidle hnext`, `omega`, consuming `hraise : nxtAt g z ≤ n₀`.
- [ ] Reuse the lowered sibling's remaining five blocks VERBATIM: the `hfirst` two-sided clause at
      deleted length `0`, the `anchor_clause_of_first_region_start` call at `l := 0, a := z`, the
      `hn₀` pin clause through `cntAt_eq_nxtAt_of_idle_pend`, the `exists_ladderPath_of_walk_nxt_at`
      re-lift with the original walk and countdown, and the `htrans` transfer of the regime to the
      re-lift. Each closes at the raised anchor from `hroom : n₀ + 2 + m * (P + 1) ≤ cntAt g z`,
      which fact (C) compiles and which is carried as a NAMED hypothesis rather than derived.
- [ ] Close against the held-register exact-shift theorem on the re-lifted path, whose two inputs
      (`n₀ + m * (P + 1) ≤ cntAt g z` and `Tc + m * (P + 1) ≤ cntAt g z`) both follow from
      `hroom` and `hTc` by `omega`.
- [ ] Write the docstring: say that the lowering costs `k` in the UPPER direction of the single
      anchor inequality while a RAISE costs nothing in it, name fact (C)'s room condition as the
      one thing the raise does need, and state that `n₀ = nxtAt g z` recovers the held-register
      theorem hypothesis for hypothesis.
- [ ] Scoped `lake build` on `LadderChain`, then `typst-sync-check.sh --fix`, then commit.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly ONE new declaration to `LadderChain.lean` and
modifies no existing declaration. The claim that the lowered sibling's five reusable blocks close
unchanged at a RAISED anchor is a hypothesis about the proof, not a fact: fact (C) compiles the
one arithmetic clause they bottom out in, but the blocks themselves have not been re-elaborated
at `n₀ ≥ nxtAt g z`. Confirm at implementation time by building the module and, if a block does
not transfer, recording which one in the phase's own commit message rather than widening the
signature silently.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths
(no shell suite covers a `.lean` or generated-`typst` path), so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`,
which elaborates the single module this phase edits; the addition is a new sibling symbol with no
existing signature changed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - one new declaration beside the lowered exact-shift deletion
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`
  exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past`
  reports no `sorryAx` and no custom axiom beyond the module's own recorded profile.
- `grep -n "theorem exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past" -A 20`
  shows the lowered sibling's signature byte-identical to its pre-phase form.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 4: Widen the Free-Anchor Raise, and Record That the Relaxed Bound Is Non-Removable [COMPLETED]

**Goal**: `exists_ladderPath_through_free_register_shifted_slack_of_pend_past` and
`free_register_anchor_clause_relaxed_bound_required` compile in `LadderCell.lean`'s existing
`section FreeRegister`.

**Tasks**:
- [ ] Add the widened assembly immediately after
      `free_register_anchor_clause_monotone_required`, at the signature pinned below. Leave the
      landed raise and the landed necessity record untouched.
- [ ] Build the body as the landed raise's spine with two changes. First, call Phase 2's
      `exists_ladderPath_through_shifted_slack_of_pend_past` in place of the landed
      `exists_ladderPath_through_shifted_of_pend_past`, so `g₁` arrives with
      `HasForwardSlack g₁ z (L + m * (P + 1)) (nxtAt g z)`. Second — and this is the substantive
      change — close the register's pin clause `hn₀` through
      `anchor_clause_of_first_region_start` at `l := 0, a := z` on `g₁`, the lowered deletion's
      own pattern at `LadderChain.lean:2140-2160`, rather than through raw
      `nxtAt_lipschitz_two_sided`. The two-sided `hfirst` obligation that call needs is exactly
      fact (B) of the Overview, which `omega` discharges from the transported slack, `hhi`,
      `hgap` and the relaxed `hlo`.
- [ ] Keep the landed raise's `hw`/`hidle`/`hpp`/`hpi`/`hpins` block, its
      `exists_ladderPath_of_walk_nxt_at` call and its closing
      `tpOf_stabFree_eq_of_objAt_eq` step unchanged.
- [ ] Add `free_register_anchor_clause_relaxed_bound_required` at the pinned signature, with the
      witness `19, 8, 10, 1, 0, 12` (compiled at plan time), under the same correspondence the
      landed record names: `X ↔ nxtAt g₁ v`, `nz ↔ nxtAt g z`, `cz ↔ cntAt g z`,
      `mP ↔ m · (P + 1)`, `d ↔ v − z`.
- [ ] Write both docstrings. For the assembly: say that at `L = 0` and `nxtAt g z ≤ n₀` it is the
      landed raise hypothesis for hypothesis (fact (B)'s second half), and that what the slack
      buys is the UPPER direction of the one anchor clause — the direction
      `free_register_anchor_clause_monotone_required` compiles as failing. For the record: say
      that the witness is DEEP-DESCENT (`k = 8 > 1 = mP`), that the landed record's own witness
      has `mP = 0` where the relaxed bound IS the landed bound, and therefore that the landed
      record stays compiled and unamended — the bound is non-removable, as it says, and what is
      new is that it is RELAXABLE by exactly the raise.
- [ ] Scoped `lake build` on `LadderCell`, then `typst-sync-check.sh --fix`, then commit.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly TWO new declarations to `LadderCell.lean` and
modifies no existing declaration's signature or body. The substantive hypothesis is that
re-routing `hn₀` from raw Lipschitz to `anchor_clause_of_first_region_start` at `l := 0` works on
the RAISED path `g₁` — fact (B) compiles the arithmetic obligation that routing bottoms out in,
but the routing itself has not been elaborated on `g₁`. Confirm at implementation time by
building the module; if `anchor_clause_of_first_region_start`'s own side conditions do not hold at
`a := z` on `g₁`, record which one in the commit message and mark the phase `[BLOCKED]` rather
than falling back to raw Lipschitz (which fact (A)'s probe 1b shows is insufficient).

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths
(no shell suite covers a `.lean` or generated-`typst` path), so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module this phase edits with no externally visible signature change.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - two new declarations in `section FreeRegister`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`
  exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_through_free_register_shifted_slack_of_pend_past`
  reports no `sorryAx` and no custom axiom beyond the module's own recorded profile.
- `grep -n "theorem free_register_anchor_clause_monotone_required" -A 8` shows the landed
  necessity record byte-identical to its pre-phase form.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 5: The UPWARD Antitone Cell Inclusion [NOT STARTED]

**Goal**: `cellAt_subset_of_antitone_register_shift_of_pend_past` compiles: the cell at
`(q, c, n)` is contained in the cell at `(q, c + m · (P + 1), n')` for `n' < n`, under lower-pair
forward-slack witnessing at the truncated amount `(n − n') − m · (P + 1)`.

**Tasks**:
- [ ] Add the theorem in `section FreeRegister`, after Phase 4's two declarations, at the
      signature pinned below.
- [ ] Build the body as `cellAt_subset_of_free_register_shift_of_pend_past_rev`'s spine — the
      landed inclusion that also consumes witnessing at its SOURCE: `intro T hT`, obtain the
      witnessing path and its slack from `hw T hT`, read `objAt`/`cntAt`/`nxtAt` at `z` off
      `hgz`, then apply Phase 4's widened raise and come back through
      `mem_cellAt_ladder_iff`.
- [ ] Supply the widened raise's two bounds by `omega` from the phase's own hypotheses: the
      relaxed `nxtAt g z ≤ n₀ + (m * (P + 1) + L)` at `n₀ := n'` and
      `L := (n - n') - m * (P + 1)` is `n ≤ n' + (m * (P + 1) + ((n - n') - m * (P + 1)))`, which
      holds in ℕ for every `m` by truncated-subtraction case analysis; and `hhi : n' ≤ c + m * (P + 1)`
      follows from `hlt : n' < n` and `hgap : n + 2 ≤ c`.
- [ ] Write the docstring: name the direction (countdown UP, register DOWN — the exact move the
      landed raise excludes), state the amount in words (the descent beyond what the raise already
      bought), record that on the BOUNDED sub-slice the amount is `0` and therefore free by
      Phase 7's `forwardSlackWitnessed_zero`, and say that the hypothesis is one a consumer
      supplies.
- [ ] Scoped `lake build` on `LadderCell`, then `typst-sync-check.sh --fix`, then commit.

**Timing**: 1 hour 30 minutes

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly ONE new declaration and modifies none. The
hypothesis is that the truncated-subtraction bound `n ≤ n' + (mP + ((n - n') - mP))` closes by
`omega` in ℕ without a manual case split on `mP ≤ n - n'`; confirm at implementation time by
running the goal through `omega` first and falling back to `rcases le_total (m * (P + 1)) (n - n')`
only if it does not.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths
(no shell suite covers a `.lean` or generated-`typst` path), so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module this phase edits with no externally visible signature change.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - one new declaration in `section FreeRegister`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`
  exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_antitone_register_shift_of_pend_past`
  reports no `sorryAx` and no custom axiom beyond the module's own recorded profile.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 6: The DOWNWARD Antitone Cell Inclusion [NOT STARTED]

**Goal**: `cellAt_subset_of_antitone_register_shift_of_pend_past_rev` compiles: the cell at
`(q, c + m · (P + 1), n')` is contained in the cell at `(q, c, n)` for `n' < n`, under
higher-pair forward-slack witnessing at amount `m · (P + 1)` and NO room bound.

**Tasks**:
- [ ] Add the theorem in `section FreeRegister`, after Phase 5's declaration, at the signature
      pinned below.
- [ ] Build the body as `cellAt_subset_of_free_register_shift_of_pend_past_rev`'s spine with the
      landed register-LOWERING deletion replaced by Phase 3's register-RAISING one: obtain the
      witnessing path and its slack from `hw T hT`, read the counter coordinates at `z` off
      `hgz`, apply `exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` at
      `n₀ := n`, and come back through `mem_cellAt_ladder_iff`.
- [ ] Supply the raising deletion's three bounds by `omega` from the phase's own hypotheses:
      `hraise : nxtAt g z ≤ n₀` is `n' ≤ n` from `hlt`; `hroom : n₀ + 2 + m * (P + 1) ≤ cntAt g z`
      is `n + 2 + m * (P + 1) ≤ c + m * (P + 1)`, i.e. the LOWER pair's own gap `hgap : n + 2 ≤ c`
      and nothing more — fact (C); and `hTc : Tc + m * (P + 1) ≤ cntAt g z` is `hTc : Tc ≤ c`.
- [ ] Write the docstring: name the direction (countdown DOWN, register UP), state the amount
      (`m · (P + 1)`, the countdown displacement alone), and make the comparison explicit — the
      monotone downward half spends `m · (P + 1) + (n' − n)` under a room bound
      `n' + (n' − n) ≤ c`, while this one spends `m · (P + 1)` under no room bound at all, because
      a register RAISE is free in the direction the anchor clause charges for. Say that the
      hypothesis is one a consumer supplies.
- [ ] Scoped `lake build` on `LadderCell`, then `typst-sync-check.sh --fix`, then commit.

**Timing**: 1 hour 30 minutes

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly ONE new declaration and modifies none. The claim
that NO room bound beyond `hgap : n + 2 ≤ c` is needed rests on fact (C), compiled at plan time
in its arithmetic form; the hypothesis is that Phase 3's assembly consumes nothing further.
Confirm at implementation time by building the module, and if a fourth bound is required, carry
it as an explicit named hypothesis and amend this phase's docstring comparison rather than
asserting the no-room-bound claim anyway.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths
(no shell suite covers a `.lean` or generated-`typst` path), so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module this phase edits with no externally visible signature change.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - one new declaration in `section FreeRegister`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`
  exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_antitone_register_shift_of_pend_past_rev`
  reports no `sorryAx` and no custom axiom beyond the module's own recorded profile.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 7: The Antitone Schema, Its Theorem, and the Bounded Corollary [NOT STARTED]

**Goal**: `forwardSlackWitnessed_zero`,
`CellLEZeroConstOfKappaEqAntitoneForwardSlack`,
`cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack` and
`cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` compile in `LadderCell.lean`'s
existing `section ForwardSlack`, so the antitone slice is dispatched as depth-`0` cell EQUALITY
and the bounded sub-slice is dispatched without an upward hypothesis.

**Tasks**:
- [ ] Add `forwardSlackWitnessed_zero` at the pinned signature, with the body compiled during
      this planning dispatch verbatim (`intro T hT`, `rw [mem_cellAt_ladder_iff] at hT`, obtain,
      `simp [nxtAt, hgz]` for the register, `refine`, `hasForwardSlack_zero` rewritten by it).
      Its docstring must say both things: that the amount-`0` obligation is free, and that this
      settles NOTHING about the general `ForwardSlackWitnessed` discharge, which is sibling task
      917's subject and is out of this task's scope.
- [ ] Add `CellLEZeroConstOfKappaEqAntitoneForwardSlack` at the pinned signature, mirroring
      `CellLEZeroConstOfKappaEqMonotoneForwardSlack`'s shape exactly: the collision equality
      retained as a binder and discarded at `intro` with a `_` pattern, the displacement
      hypothesis named, the regime and threshold bounds, and one branch per orientation of the
      antitone disjunction — each branch carrying TWO witnessing obligations, the truncated
      upward one at the lower pair and the `m · (P + 1)` downward one at the higher pair, and NO
      room bound.
- [ ] Add `cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack`. The proof is
      `intro hp hno q c n c' n' h h' z _ hanti hgap hgap' hTc hTc' hwup hwdn`, `rcases hanti`,
      and in each branch `subst` the displacement and close by `Set.Subset.antisymm` against
      Phase 5's and Phase 6's inclusions with the roles assigned by the orientation — the same
      two-branch shape `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` uses.
- [ ] Add `cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` at the pinned
      signature, carrying ONE witnessing hypothesis (the downward one) and none upward. The proof
      closes by `Set.Subset.antisymm` against the same two inclusions, discharging Phase 5's
      upward hypothesis with `forwardSlackWitnessed_zero` after rewriting
      `(n - n') - m * (P + 1)` to `0` from `hbounded : n - n' ≤ m * (P + 1)` by `omega`.
- [ ] Write the schema's and both theorems' docstrings. Each must state, in these words, that the
      reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing here and that the
      schema — strictly stronger in hypotheses — bears on the reserved statement's truth value in
      NEITHER direction. The schema's docstring must additionally say WHAT A CONSUMER MUST SUPPLY,
      itemized per direction, and that none of it is a consequence of `ParamsOk`. The bounded
      corollary's docstring must name the predecessor's own non-vacuity witness `(4, 2)` against
      `(6, 0)` as lying in this half.
- [ ] Scoped `lake build` on `LadderCell`, then `typst-sync-check.sh --fix`, then commit.

**Timing**: 2 hours

**Depends on**: 1, 5, 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly FOUR new declarations to `LadderCell.lean` and
modifies no existing declaration's signature or body. `forwardSlackWitnessed_zero`'s proof is
compiled already, so the hypothesis is confined to the three remaining items — in particular to
the claim that the second orientation of the antitone disjunction closes by the SAME two
inclusions with roles swapped, which is argued from the monotone schema's analogous two-branch
proof rather than compiled. Confirm at implementation time by building the module; if the second
branch needs an inclusion the first does not, add it as its own declaration in this phase and
record the deviation rather than restricting the schema to one orientation.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths
(no shell suite covers a `.lean` or generated-`typst` path), so the covering check named here is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`,
which elaborates the single module this phase edits; `LadderCell.lean` is a leaf of the
`RaySummary` import graph for these symbols, so no dependent module's call sites move.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - four new declarations in `section ForwardSlack`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`
  exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack`
  and on
  `FormalSystem.Metalogic.Decidability.RaySummary.cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack`
  each report no `sorryAx` and no custom axiom beyond the module's own recorded profile.
- `grep -c "cellLE_zero_const_of_kappa_eq\b" FormalSystem/` confirms the reserved name is
  declared by nothing.
- The bounded corollary's signature carries exactly ONE `ForwardSlackWitnessed` hypothesis, read
  directly off the declaration.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 8: Records, Generated Surfaces and Full Verification [NOT STARTED]

**Goal**: both module docstrings and `RaySummary/README.md` record the dispatched antitone slice,
its two-way split and what each half costs; the route the predecessor named is marked as now
TAKEN for the deep-descent residue and as never needed for the bounded sub-slice; every generated
surface is reconciled; the full gate set is run and every finding is attributed.

**Tasks**:
- [ ] Amend `LadderCell.lean`'s module docstring. Its FREE-REGISTER RAISE part gains the widened
      assembly and the relaxed necessity record; its COLLISION CASE SPLIT part gains the named
      antitone predicate, the named dichotomy, the descent destructor and the two non-vacuity
      witnesses; its FORWARD-SLACK part gains the antitone schema, its theorem and the bounded
      corollary. Keep the standing sentence that the reserved name
      `cellLE_zero_const_of_kappa_eq` is claimed by nothing in the module.
- [ ] Amend `LadderChain.lean`'s module docstring: the raise's slack-exposing sibling and the
      register-RAISING deletion, each named with the one clause it adds over its landed sibling.
- [ ] Amend `FormalSystem/Metalogic/Decidability/RaySummary/README.md`. Two edits, both against
      paragraphs confirmed present by read at authoring time. First, extend the `LadderCell.lean`
      and `LadderChain.lean` Description cells with the new declarations. Second, amend **"The
      antitone route left open"** paragraph (confirmed at lines 1180-1186 at authoring time): it
      currently says the route is "named rather than claimed" and that "no landed schema carries a
      hypothesis of that family". Both halves are now false — the route is TAKEN for the
      deep-descent residue and a landed schema carries exactly that hypothesis, while the bounded
      sub-slice turned out not to need it at all. Rewrite the paragraph to say what is now
      compiled, and keep the one claim that is still open and still named rather than claimed:
      whether such a hypothesis is satisfiable at any state the induction one layer up reaches.
      If that paragraph has been rewritten by the time this phase runs, amend whatever paragraph
      then carries the antitone-route claim rather than inventing a new section; if no paragraph
      carries it, add one to the `LadderCell.lean` discussion rather than leaving the stale claim
      standing elsewhere.
- [ ] Regenerate the generated module inventories: edit the Description cells FIRST, then
      `bash scripts/check-module-invariants.sh --emit-inventory`, then `--emit-inventory --check`.
- [ ] `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.
- [ ] Full-project build and the full gate set; attribute every finding.

**Timing**: 1 hour 30 minutes

**Depends on**: 7

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the generated surfaces this phase may reconcile are at most `README.md`,
`FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
`FormalSystem/Metalogic/Decidability/README.md`,
`FormalSystem/Metalogic/Decidability/RaySummary/README.md` and `typst/generated/status.typ` — the
ancestor-chain generated-inventory READMEs for a `LadderCell.lean`/`LadderChain.lean` edit, each
confirmed to exist by `ls` at authoring time. In the immediate predecessor's phase-closing commit
only three of the comparable five moved, so some of these are declared but may legitimately come
back unchanged. Confirm at implementation time from `--emit-inventory`'s own report of which
blocks it rewrote, and stage only the files it actually changed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - module docstring amended across its free-register, collision-split and forward-slack parts
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - module docstring amended with the two new assemblies
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - both Description cells extended; "The antitone route left open" paragraph amended to record the route as taken for the deep-descent residue and unneeded for the bounded sub-slice
- `README.md` - regenerated inventory block if `--emit-inventory` moves it; staged only if it actually changed
- `FormalSystem/README.md` - regenerated inventory block if `--emit-inventory` moves it; staged only if it actually changed
- `FormalSystem/Metalogic/README.md` - regenerated inventory block if `--emit-inventory` moves it; staged only if it actually changed
- `FormalSystem/Metalogic/Decidability/README.md` - regenerated inventory block if `--emit-inventory` moves it; staged only if it actually changed
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project) exits 0
  with no `sorry` and no error.
- `bash scripts/check-module-invariants.sh` exits 0 (C1 build, C2 axiom baselines, inventory and
  doc-count checks), and `--emit-inventory --check` exits 0.
- `bash scripts/typst-sync-check.sh` exits 0.
- `bash .claude/scripts/lean-sorry-census.sh` shows no new `sorry` attributable to this task.
- `grep -rn "cellLE_zero_const_of_kappa_eq\b" FormalSystem/` shows the reserved name declared by
  nothing.
- `grep -n "named rather than claimed" FormalSystem/Metalogic/Decidability/RaySummary/README.md`
  no longer returns the antitone-route paragraph, and the replacement text names what is compiled
  and what remains open.
- `bash .claude/scripts/check-task-references.sh` exits 0: no task-number citation lands in any
  `FormalSystem/**` or `typst/**` deliverable.
- `bash .claude/scripts/verify-deploy.sh` is run as the complete gate set for this phase's `full`
  tier. Because the gate set runs against the whole deploy tree and the dispatch context reports
  that tree STALE for the core, lean, literature, memory and typst extensions, the criterion is:
  every finding is attributed, and NO finding names a file this task touched. A pre-existing
  finding attributable to the recorded staleness is recorded as baseline and is NOT hand-patched
  under `.claude/**`.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

set_option autoImplicit false

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-! Phase 2 -- LadderChain.lean, section AssemblyFin -/

theorem exists_ladderPath_through_shifted_slack_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hTc : Tc ≤ cntAt g z) (m : ℕ) (L : ℕ)
    (hslack : HasForwardSlack g z L (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z + m * (P + 1) ∧
      nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z (L + m * (P + 1)) (nxtAt g z) ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry

/-! Phase 3 -- LadderChain.lean, beside the lowered exact-shift deletion -/

theorem exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ) (n₀ : ℕ)
    (hraise : nxtAt g z ≤ n₀)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hroom : n₀ + 2 + m * (P + 1) ≤ cntAt g z)
    (hslack : HasForwardSlack g z (m * (P + 1)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = n₀ ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry

/-! Phase 1 -- LadderCell.lean, section Collision -/

def AntitoneCollisionDisplacement (P c n c' n' : ℕ) : Prop :=
  (∃ m : ℕ, c' = c + m * (P + 1) ∧ n' < n) ∨ (∃ m : ℕ, c = c' + m * (P + 1) ∧ n < n')

theorem kappa_collision_monotone_or_antitone_named (Tc Tn P B c n c' n' : ℕ)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    MonotoneCollisionDisplacement P c n c' n' ∨
      AntitoneCollisionDisplacement P c n c' n' := sorry

theorem kappa_collision_antitone_descent_multiple (Tc Tn P B c n c' n' : ℕ)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) (hlt : n' < n) :
    ∃ j : ℕ, n = n' + j * (P + 1) := sorry

theorem kappa_collision_antitone_bounded_descent_nonvacuous :
    ∃ Tc Tn P B c n c' n' m : ℕ, 2 ≤ B ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      n + 2 ≤ c ∧ n' + 2 ≤ c' ∧ Tc ≤ c ∧ Tc ≤ c' ∧
      ¬ MonotoneCollisionDisplacement P c n c' n' ∧
      c' = c + m * (P + 1) ∧ n' < n ∧ n - n' ≤ m * (P + 1) := sorry

theorem kappa_collision_antitone_deep_descent_nonvacuous :
    ∃ Tc Tn P B c n c' n' m : ℕ, 2 ≤ B ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      n + 2 ≤ c ∧ n' + 2 ≤ c' ∧ Tc ≤ c ∧ Tc ≤ c' ∧
      ¬ MonotoneCollisionDisplacement P c n c' n' ∧
      c' = c + m * (P + 1) ∧ n' < n ∧ m * (P + 1) < n - n' := sorry

/-! Phase 4 -- LadderCell.lean, section FreeRegister -/

theorem exists_ladderPath_through_free_register_shifted_slack_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hgap : nxtAt g z + 2 ≤ cntAt g z) (hTc : Tc ≤ cntAt g z) (m : ℕ) (n₀ L : ℕ)
    (hslack : HasForwardSlack g z L (nxtAt g z))
    (hlo : nxtAt g z ≤ n₀ + (m * (P + 1) + L))
    (hhi : n₀ ≤ cntAt g z + m * (P + 1)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z + m * (P + 1) ∧
      nxtAt g' z = n₀ ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry

theorem free_register_anchor_clause_relaxed_bound_required :
    ¬ ∀ X nz cz mP n₀ d : ℤ, 0 ≤ X → 0 ≤ mP → 0 ≤ n₀ →
        cz + mP < d → X ≤ nz + d - mP → nz + 2 ≤ cz →
        n₀ ≤ cz + mP → (X - n₀).natAbs ≤ d.natAbs := sorry

/-! Phase 5 -- LadderCell.lean, section FreeRegister -/

theorem cellAt_subset_of_antitone_register_shift_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (hlt : n' < n) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c, n), h⟩ : LadderState Q pend) z (n - n' - m * (P + 1)) n) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

/-! Phase 6 -- LadderCell.lean, section FreeRegister -/

theorem cellAt_subset_of_antitone_register_shift_of_pend_past_rev
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (hlt : n' < n) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c + m * (P + 1), n'), h'⟩ : LadderState Q pend) z (m * (P + 1)) n') :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

/-! Phase 7 -- LadderCell.lean, section ForwardSlack -/

theorem forwardSlackWitnessed_zero {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (z : ℤ) :
    ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c, n), h⟩ : LadderState Q pend) z 0 n := sorry

def CellLEZeroConstOfKappaEqAntitoneForwardSlack {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (z : ℤ),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      AntitoneCollisionDisplacement P c n c' n' →
      n + 2 ≤ c → n' + 2 ≤ c' → Tc ≤ c → Tc ≤ c' →
      (∀ m : ℕ, c' = c + m * (P + 1) → n' < n →
        ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c, n), h⟩ : LadderState Q pend) z (n - n' - m * (P + 1)) n ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c', n'), h'⟩ : LadderState Q pend) z (m * (P + 1)) n') →
      (∀ m : ℕ, c = c' + m * (P + 1) → n < n' →
        ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c', n'), h'⟩ : LadderState Q pend) z (n' - n - m * (P + 1)) n' ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c, n), h⟩ : LadderState Q pend) z (m * (P + 1)) n) →
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        = cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

theorem cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
    CellLEZeroConstOfKappaEqAntitoneForwardSlack step pend fwd bwd lab φ Tc Tn P B := sorry

theorem cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m n' : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (hlt : n' < n)
    (hbounded : n - n' ≤ m * (P + 1)) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c + m * (P + 1), n'), h'⟩ : LadderState Q pend) z (m * (P + 1)) n') :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
      = cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c + m * (P + 1), n'), h'⟩) :
            (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] Full-project `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` green
      at Phase 8, with no `sorry` and no error.
- [ ] Scoped `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`
      green at the end of Phases 2 and 3, and the same for `…LadderCell` at the end of Phases 1,
      4, 5, 6 and 7.
- [ ] `lean_verify` reports no `sorryAx` and no axiom beyond each module's recorded profile for
      all fifteen declarations named under `- **Goals**:`.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 at Phase 8, and
      `--emit-inventory --check` exits 0.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 at Phase 8, and `--counts-only` exits 0 before
      every intermediate commit.
- [ ] `bash .claude/scripts/lean-sorry-census.sh` shows no new `sorry` attributable to this task.
- [ ] `grep -rn "cellLE_zero_const_of_kappa_eq\b" FormalSystem/` shows the reserved name declared
      by nothing, checked at Phases 7 and 8.
- [ ] Every landed signature this plan declares untouched is confirmed byte-identical:
      `kappa_collision_monotone_or_antitone`,
      `free_register_anchor_clause_monotone_required`,
      `exists_ladderPath_through_shifted_of_pend_past`,
      `exists_ladderPath_through_free_register_shifted_of_pend_past`,
      `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`,
      `CellLEZeroConstOfKappaEqMonotoneForwardSlack` and
      `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack`.
- [ ] `bash .claude/scripts/check-task-references.sh` exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` run at Phase 8 with every finding attributed and
      none naming a file this task touched.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — two new assemblies
  (slack-exposing raise, register-raising exact-shift deletion) plus an amended module docstring.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — thirteen new declarations
  across `section Collision`, `section FreeRegister` and `section ForwardSlack`, plus an amended
  module docstring.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — both Description cells extended and
  the antitone-route paragraph amended to record the route as taken for the deep-descent residue
  and never needed for the bounded sub-slice.
- Regenerated generated surfaces: `typst/generated/status.typ` and whichever of the four
  ancestor-chain inventory READMEs `--emit-inventory` actually rewrites.
- `specs/916_antitone_collision_residue_lower_pair_witnessing/summaries/01_antitone-slice-dispatch-summary.md`
  at completion.

## Rollback/Contingency

Each phase commits independently and green, so the ordinary contingency is to stop at the last
green phase and leave the rest `[NOT STARTED]`: nothing in Phases 1-7 is load-bearing for any
landed declaration, because every addition is a sibling and no landed signature or body is
edited. A partial landing is therefore coherent, not broken.

**If a phase cannot be completed as written**, mark it `[BLOCKED]` in this plan with the goal
state reached and what is needed, per `rules/plan-compliance.md` — do NOT substitute a different
decomposition, and do NOT weaken a signature pinned in `## Lean Challenge Statements` to make a
proof go through.

**If a genuine mathematical barrier appears** — the one outcome that would change this plan's
verdict from DISPATCH to REFUTATION — the contingency is a COMPILED refutation record in the
style of `free_register_anchor_clause_monotone_required`: an arithmetic or `kappa` witness
against the specific clause that fails, landed as its own theorem with its correspondence stated
in the docstring. A refutation is as good an outcome as a proof, and must be a compiled witness,
never an argument. The reserved name `cellLE_zero_const_of_kappa_eq` stays reserved in that case
too, and nothing lands under it.

**If uncommitted work must be discarded** to reach a clean tree, that is a genuine rollback and
uses the snapshot-then-rollback recipe at `context/contracts/recovery.md`'s rollback rung, with
the task number explicit — never a bare precautionary checkpoint. For an ordinary defensive
checkpoint before a risky phase, use `bash .claude/scripts/git-snapshot.sh 916 --no-revert`,
which is durable without reverting the working tree.
