# Implementation Plan: Task #748

- **Task**: 748 - Revise existing tasks and create new ones to move the L⁺ decidability programme forward
- **Status**: [NOT STARTED]
- **Effort**: 5.5 hours
- **Dependencies**: 747 (completed)
- **Research Inputs**: `specs/748_revise_and_create_tasks_lplus_decidability/reports/01_ranked-route-analysis-dispositions.md`, `reports/02_round-two-joint-verification.md`, `reports/03_literature-scope-product-negative-results.md`
- **Artifacts**: plans/03_task-graph-revisions-and-roadmap.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan's executable output is **`specs/state.json` mutations and a hand-edited
`specs/ROADMAP.md`** — nothing else. Four tasks are created, three records are revised, one is
closed as subsumed, and the roadmap's Stage 1 prose and run order are brought into line with the
landed verdicts. No Lean is written, no library module is touched, and no analysis artifact is
produced: deliverable (b) of the task description (the ranked route analysis) is already
discharged by the three landed reports, and deliverable (a) is entirely outstanding
(`reports/02`, §2.8: `next_project_number` is 749 and no project numbered above 748 exists).

The ranked list executed here is **reports/02's R1-R9**, which supersedes reports/01 wherever
they conflict, amended by reports/03's literature position and its one named live risk. Every
creation and revision below names the file:line, wired probe, or named theorem that drove it.

### Research Integration

The findings this plan acts on, with the report section that establishes each:

- **(C)'s bound was descoped at closure and is unowned** (01 F1; 02 §2.2). Its phase 1 —
  `kTypeOf_listSeg_replicate_eventually_periodic` at the signature stated verbatim at
  `RaySummary/README.md:285-290` — is **closed in principle**: 02 compiled it in a 15-line
  scratch proof in 2.3 s with axioms `[propext, Classical.choice, Quot.sound]` (02 §2.1,
  Appendix). The route is **pigeonhole plus `kTypeOf_listSeg_append_congr`** (`Compose.lean:276`),
  **not** "finite-semigroup idempotence" as `README.md:291` and
  `hit-presented-model-a.lean:97` still say.
- **The real unmeasured cost is the factorization-transport lemma**, not (iii) (02 §2.2).
  `hitCl_eq_truncated`'s `L` bounds jump offsets over `familyTriples`, each an existential over
  `SegmentFactorization` (`Family.lean:70-95`, `:201-203`); nothing in the tree transports a
  factorization across a lengthened replicated block, and the converse the tree does hold
  (`kTypeOf_zFiber_eq_of_inFamily`, `Saturation.lean:133`) is the wrong direction.
- **Obligation (ii) is two proof obligations, not a hypothesis with no deliverable** (02 §2.4,
  correcting 01 D4), sourced to `README.md:378-383`,
  `w-soundness-shape-refuted.lean:44-49`, and 747's report line 106. Obligation (iii) is **not**
  (C)'s bound. (C)'s general every-model row (`README.md:154`) is the **completeness half** of the
  (W) lift, not a third task (02 D12).
- **The 739 re-costing is done and the tree already satisfies the constraint** (02 §2.3):
  `clSig φ := subformulas φ ⊕ Unit` (`Closure.lean:80-81`) and `subformulas` carries both `untl`
  and `snce` arguments (`Subformulas.lean:66-73`), so the alphabet is closure-indexed with
  backward labels included by construction. The strengthened threshold is bounded by
  `Nat.card (KType (clSig φ) k)` — **a count, which times nothing**.
- **The R2 contingency is void and nothing replaces it** (01 F3; 02 §2.6). Neither trigger fired
  (733 came back POSITIVE; 745 did not refute) and the literal falsifier is unsatisfiable. 02
  §2.6's table of four named failure modes — none realized — is what replaces it.
- **720 is a CI repair with a recurring mechanism** (02 §2.7), promoted ahead of `716,714`
  (02 D14). Two `WIRED_REPO` entries were deleted from the index by `70321e938` and re-pointed by
  `e8cfcd868`; `check_probe` tests `-f` only (`check-evidence-probes.sh:717-720`); `ci.yml:119-125`
  runs the gate and `:352-356` fails the job on its outcome.
- **The literature settles L⁺ in neither direction** (03 D1-D2). TM/L⁺ over regular ℤ-frames meets
  the hypothesis of no published negative result in the corpus, because it is a **proper
  extension** of a decidable product logic (`modal_future`, `Axioms.lean:297`;
  `box_time_invariant`, `PlusTruth.lean:349`) rather than a relativisation of an undecidable one.
  The fmp failures are **neutral, not corroborating** (03 F3: GKWZ Thm 5.30/5.32 kill the fmp of
  S5-plus-linear products while Thm 6.61 decides them).
- **03's one live risk is perfect recall** (03 Recommendation 3, Risks): if an L⁺ formula can force
  the relevant part of a regular ℤ-frame to be **backward-deterministic**, `stab` satisfies
  Thomason Def. 6 (2) / Caleiro `Wdc` there and the know-time-do-not-forget family becomes a
  reduction target.

Three live re-verifications were run in this planning dispatch rather than carried:
`roadmap-integration.sh --regenerate` **reproduced exit 1 with zero stdout and zero stderr**;
`next_project_number` is **749**; and 714 and 725 carry **no `file_scope`** while 720's already
covers `scripts/check-evidence-probes.sh`.

### Prior Plan Reference

The three research rounds are this plan's only prior artifacts. One scoped revision has since been
applied to this plan on a settled user ruling (`.decisions.json`, cycle 1): the perfect-recall
backward-determinism probe is **recorded as a Stage 1 roadmap risk, not filed as a task**, which is
what `reports/03`'s Recommendation 3 says in those words ("do not file it as a task on this
evidence"). Its phase is gone; its content lives in Phase 6's risk table. Every other ranking,
scope and report-precedence decision below is unchanged.

### Roadmap Alignment

`specs/ROADMAP.md` is **itself a deliverable of this plan** (Phase 7), not a context input to be
honoured. This plan advances its Stage 1 front by replacing the void R2 contingency
(`ROADMAP.md:186-187`), re-costing the (C) bullet (`:128-133`), recording the run-layer filing
against its (W) bullet (`:199-213`), updating the Run-order block (`:20-26`), and adding a
literature-position paragraph. Stage 0's 712/709 rulings, constraint 1 and the 739 bullet are
left exactly as they are.

## Goals & Non-Goals

**Goals**:
- Create four tasks: the (C)-bound task, the (W) run-layer task, the declaration-hygiene remediation, and the roadmap-tooling filing — each with `file_scope` declared at creation.
- Revise 720 (enlarged to a CI repair with the tracked-ness check as a named deliverable) and declare 714's `file_scope`.
- Close 725 as subsumed, with the subsumption evidence written into its description **before** the abandon so the archived record carries it.
- Hand-edit `specs/ROADMAP.md` so Stage 1 asserts no fallback, carries the five named risks and the literature position, and orders the front by the revised task graph.
- Leave an audit trail in which every description and roadmap sentence written here names a file:line, a wired probe, or a named theorem.

**Non-Goals**:
- Writing any Lean. Phase 1 of the created (C)-bound task lands the scratch proof; this plan does not, and the scratch file stays in the scratchpad (02 D17).
- Any complexity bound, upper or lower, in any description or roadmap sentence. `AnchorLayer.lean:317-320` is quoted verbatim wherever a count appears.
- Any change to task **734** — status, blockers, or description. Its `[PARTIAL]` marker encodes a recorded user decision referred to the user and still unanswered; 02's R6 referral stands unre-raised.
- A fourth certificate class; a third task for (C)'s general statement (02 D12); a `two_fwd_paths` probe (02 D15); a "prove L⁺ undecidable" or "transfer decidability from the product" task (03 Recommendation 5).
- **A task for the perfect-recall / backward-determinism probe.** `reports/03`'s Recommendation 3 (line 117) says of exactly this item: "Record it as a risk with the obvious cheap probe (a one-fixture check of whether backward determinism is forceable by a closed formula); do not file it as a task on this evidence." That is a settled user ruling (`.decisions.json`, cycle 1). It is recorded as a Stage 1 risk row in Phase 6 and nowhere else; Phase 7 audits the diff for a record that must not be there.
- `roadmap-integration.sh --regenerate`. It exits 1 silently (re-verified live this dispatch), so the whole file is hand-edited and there is no clobber hazard to manage (01 D9).
- Any edit to `FormalSystem/**` or `docs/**`. 03's Recommendation 2 (the literature paragraph for `RaySummary/README.md`) is **assigned to the created (W) task** rather than executed here, because 748's `file_scope` is `["specs/ROADMAP.md"]` and that file is territory of the two tasks this plan creates.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A created task's `file_scope` is omitted, because the `task.md:181-196` filter does not write the field (`:223`) | H | H | Every creation phase pairs the creating `state-write.sh` call with a second call setting `.file_scope`, and its verification step reads the field back with `jq` before the phase closes |
| Task numbers drift (another writer creates a task mid-run), so a hardcoded 749/750/751 lands on the wrong record | H | L | Each creation phase reads `next_project_number` immediately before its write and reads the assigned number back after; the roadmap phase reads the four actual numbers from `state.json` rather than assuming them |
| A description or roadmap sentence is read as asserting a complexity bound | H | M | Every text carrying a count carries `AnchorLayer.lean:317-320` verbatim beside it; Phase 7 runs an explicit grep audit over every file this plan touched |
| The 725 abandon runs before its subsumption evidence is written, so the archived record loses it | M | M | Phase 4 orders the description write first and verifies it with `jq` before invoking the abandon flow |
| The (W) task is dispatched past phase 1 and burns cycles on open mathematics | M | M | "Dispatch phase 1 and STOP" is written into its description as a dispatch instruction (not a status) and repeated in the roadmap's run-order comment |
| Stage 1 has no fallback, and the roadmap is read as hiding that | M | L | The replacement text says so in those words and names the four modes of 02 §2.6 with their realized status; no fallback is invented |
| `generate-todo.sh` renders a malformed TODO.md after five state writes | L | M | Phase 7 regenerates and reads the Stage-1 rows; `--regen-todo` is folded into the final write of each phase |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3, 4 | -- |
| 2 | 2 | 1 |
| 3 | 5 | 2 |
| 4 | 6 | 1, 2, 3, 4, 5 |
| 5 | 7 | 6 |

Phases within the same wave can execute in parallel. Phases 1, 2 and 5 form a chain only
because each reads `next_project_number` and must observe the previous creation's bump; phases 3
and 4 touch existing records and assign no number, so they are independent of the chain. Every
write in every phase goes through `state-write.sh`, whose `specs/.scope-lock` mutex serializes
concurrent writers (`state-write.sh` header, "fail-closed mutex acquisition").

---

### Phase 1: Create the (C)-bound task [NOT STARTED]

**Goal**: File the highest-value item on the front (02 R1): (C)'s bound half on model A, in three
phases with the cost on phase 2, with `file_scope` declared and the non-negotiables written into
the record.

**Tasks**:
- [ ] Read `next_project_number` from `specs/state.json` (`jq -r '.next_project_number'`); call it `$N`.
- [ ] Create the record with `state-write.sh` using the `task.md:181-196` filter shape: `project_name` `c_bound_half_model_a_presentation_size`, `status` `not_started`, `task_type` `lean4`, `topic` `decidability`, `.next_project_number = $N + 1`, `--regen-todo` omitted on this write.
- [ ] Use this description text verbatim (it is the record's whole content):

  > **(C)'s BOUND HALF ON MODEL A.** 745 delivered (C)'s satisfiability half only; the bound half
  > was descoped at closure and is owned by no other record. `RaySummary/README.md:154` states
  > what landed is "**one fixture**, so no computable bound and no general regular `ℤ`-model
  > statement follows". This record owns the bound **on the fixture**. The general every-model
  > statement is OUT OF SCOPE here and is the completeness half of the (W) run-layer record.
  >
  > **PHASE 1 (hours; closed in principle).** Land, in
  > `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Saturation.lean`, namespace
  > `FormalSystem.Metalogic.WeakCanonical` (matching `kTypeOf_listSeg_append_congr`'s at
  > `Compose.lean:296`), the STRENGTHENED shape
  > `∃ m₀ p, 0 < p ∧ m₀ + p ≤ Nat.card (KType sig k) ∧ ∀ m, m₀ ≤ m → kTypeOf sig k (listSeg (List.replicate (m + p) ℓ)) = kTypeOf sig k (listSeg (List.replicate m ℓ))`,
  > with the shape stated verbatim at `RaySummary/README.md:285-290` as its one-line corollary so
  > the recorded signature stays literally true. ROUTE: **pigeonhole plus
  > `kTypeOf_listSeg_append_congr`** (`Compose.lean:276`), NOT finite-semigroup idempotence — no
  > semigroup is constructed and no idempotent is needed; the congruence is applied once with the
  > first argument varying and the second fixed. Premises: `kType_finite`
  > (`KTypeSummary/Basic.lean:112`), `Finite.exists_ne_map_eq_of_infinite` for the stated shape,
  > `Fintype.exists_ne_map_eq_of_card_lt` on `Fin (Nat.card (KType sig k) + 1)` after
  > `Fintype.ofFinite` and `Nat.card_eq_fintype_card` for the strengthened one, `List.replicate_add`.
  > A feasibility elaboration of both theorems compiled in 2.3 s against the current oleans with
  > axioms `[propext, Classical.choice, Quot.sound]` and no `sorryAx`; the scratch text is
  > reproduced in `specs/748_revise_and_create_tasks_lplus_decidability/reports/02_round-two-joint-verification.md`'s
  > Appendix and is FEASIBILITY ONLY — land it here, under this record's `file_scope`, pins and
  > index row, never copied in as a research commit. Keep the stated `[DecidableEq sig.preds]`
  > binder even though the proof does not use it (the `unusedArguments` linter will say so, as
  > `Compose.lean:270-275` predicts for `append_congr`): the stated signature is the recorded one.
  > Pin both theorems in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` at
  > `[propext, Classical.choice, Quot.sound]` (the profile of every (C) pin at `:405-413`); add one
  > `docs/theorem-index.md` row cross-referencing the `anchorCells_ncard_le` row so both counts
  > carry the same disclaimer in the same words. Replace "finite-semigroup idempotence" with
  > "pigeonhole plus `kTypeOf_listSeg_append_congr`" at `RaySummary/README.md:291`,
  > `hit-presented-model-a.lean:97`, and in `append_congr`'s docstring at `Compose.lean:271-275`.
  >
  > **PHASE 2 (THE COST; UNMEASURED, AND THIS RECORD SAYS SO).** The factorization-transport
  > lemma: `InFamily` is invariant under lengthening a maximal constant run beyond phase 1's
  > threshold — "if `c'` is `c` with a maximal constant run `ℓ^n` replaced by `ℓ^(n+p)`, and `n` is
  > beyond phase 1's threshold, then `InFamily … c ↔ InFamily … c'`". Nothing in the tree states
  > it and no attempt is recorded anywhere; it has NO cost figure and this record asserts none.
  > It is needed because `hitCl_eq_truncated`'s `L` bounds jump OFFSETS over `familyTriples`, a
  > family triple is `InFamily sig k τneg τzero τpos c := ∃ F : SegmentFactorization sig k c, …`
  > (`Family.lean:201-203`), and a `SegmentFactorization` is a monotone covering cutting sequence
  > `W : ℤ → ℤ` (`Family.lean:70-95`) — so phase 1 is about the `k`-type of one finite replicated
  > block and `L` is about cutting sequences of a bi-infinite colouring. The proof is cut surgery
  > (shrink or extend the segment holding the run, with phase 1 and `append_congr` preserving its
  > type) and has a GENUINE CASE SPLIT a plan must face: when every segment meeting the run is
  > short, no single segment can absorb the `p` positions and the factorization must be re-cut.
  > The converse the tree holds, `kTypeOf_zFiber_eq_of_inFamily` (`KTypeSummary/Saturation.lean:133`),
  > is the WRONG DIRECTION for this. State it generally over `sig` first; if that resists, fall
  > back to model A's concrete traces, which by `clTrace_stayA_apply`/`clTrace_jump_apply`
  > (`hit-presented-model-a.lean:470-500`) are `(Fp,¬p)^(ω*) · now · (Fp,¬p)^n · (Fp,p)^ω`. If it
  > does not close: mark the phase `[BLOCKED]` and name the obstruction. NEVER a `sorry`, never a
  > new axiom.
  >
  > **PHASE 3 (bookkeeping once phase 2 lands).** Exhibit `L` in `hitCl_eq_truncated`
  > (`hit-presented-model-a.lean:593-596`) — `≤ m₀ + p` from phase 1, hence
  > `≤ Nat.card (KType (clSig Fp) k)` — replacing the non-constructive `Set.Finite.bddAbove`
  > witness at `:603`. Exhibiting `L` CHANGES `hitCl_eq_truncated`'s statement, so revise the
  > `∃ L` prefix of `Probe745.hitPresented_modelA` and its "What `hitPresented_modelA` does NOT
  > say" block (`:1303-1312`) in the SAME change rather than leaving them asserting
  > non-exhibition; then re-run `bash scripts/check-evidence-probes.sh`.
  >
  > **NON-NEGOTIABLES.** (1) `Nat.card (KType …)` is described as a COUNT and nothing else. Quote,
  > verbatim, `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean:317-320` wherever
  > this record's count appears: "The one bound (W) can state honestly: a cardinality bound on the
  > SET OF CELLS of a model, syntactic in `|cl φ|` — a cell is a set of subsets of `cl φ`, so there
  > are at most `2 ^ (2 ^ |cl φ|)` of them. It is not a complexity bound of any kind: it counts
  > cells, it does not time anything, and it must not be described as a bound on any procedure's
  > running time." Derive nothing from the size of `NormalForm (clSig φ) k 0`. (2) The alphabet
  > constraint 739 left standing is already met by the tree and is not re-litigated:
  > `clSig φ := subformulas φ ⊕ Unit` (`Closure.lean:80-81`) and `subformulas` carries both `untl`
  > and `snce` arguments (`Subformulas.lean:66-73`), so backward labels are letters by
  > construction. (3) `k` STAYS FREE: land the bound for every `k` and choose none. `k = 1`
  > suffices for the `⊡` bridge alone (`plusStab_iff_forall_hitSig`,
  > `plusStab_iff_forall_hitCl`, both `(hk : 1 ≤ k)` at `Trace.lean:240`; `hitPresented_modelA` at
  > `hit-presented-model-a.lean:1282`); what depth the `untl`/`snce` run layer needs is the (W)
  > record's phase-1 output, not this record's. (4) `Decidable (PlusValidZTime φ)` appears in no
  > statement. (5) No complexity bound, upper or lower, is asserted or implied anywhere; the
  > ARGUED CTL⋆ 2EXPTIME ceiling is never an upper-bound source. (6) Sorry-free completion
  > required; a route that does not close is `[BLOCKED]` with the obstruction named.

- [ ] In a second `state-write.sh` call, set `.file_scope` on record `$N` to: `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Saturation.lean`, `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean`, `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`, `docs/theorem-index.md`, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `scripts/check-module-invariants.sh`. Fold `--regen-todo` into this write.
- [ ] `bash .claude/scripts/manage-topics.sh set $N decidability` (hard error if it fails; do not roll back the record).

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The only file written is `specs/state.json`, whose covering check is `bash .claude/scripts/validate-state.sh specs/state.json` — no Lean module, shell script, or deployed `.claude/**` file is touched, so no build and no test suite is implicated.

**Scope Hypothesis**: The number assigned is expected to be 749 (`next_project_number` read 749 at planning time), but the implementer MUST read `next_project_number` immediately before the write and read the assigned `project_number` back afterwards rather than hardcoding 749.

**Files to modify**:
- `specs/state.json` - one new `active_projects[]` record with `file_scope`, `next_project_number` bumped, `active_topics` entry added
- `specs/TODO.md` - regenerated (never hand-edited)

**Verification**:
- `jq '.active_projects[] | select(.project_number == $N)' specs/state.json` shows `status: "not_started"`, `task_type: "lean4"`, `topic: "decidability"`, a non-empty `description`, and a 7-entry `file_scope`.
- `jq -r '.next_project_number' specs/state.json` is one greater than the value read at phase start.
- `bash .claude/scripts/validate-state.sh specs/state.json` reports no ERROR (file_scope WARN lines are advisory).
- `grep -c '2EXPTIME\|EXPTIME\|PSPACE\|exponential time\|running time' <(jq -r '.active_projects[]|select(.project_number==$N)|.description' specs/state.json)` is 0.

---

### Phase 2: Create the (W) run-layer task [NOT STARTED]

**Goal**: File the (W) run layer (02 R2) with the frame-scheme design question as phase 1 and
obligation (ii)'s two halves as phases 2 and 3, the completeness half being (C)'s general
every-model statement (02 §2.4, D12-D13).

**Tasks**:
- [ ] Read `next_project_number`; call it `$W`.
- [ ] Create the record (same filter shape as Phase 1): `project_name` `w_run_layer_closure_wide_lift`, `task_type` `lean4`, `topic` `decidability`, `status` `not_started`, `dependencies` left empty.
- [ ] Use this description text verbatim:

  > **(W)'s RUN LAYER — ITS OWN RECORD, AS `RaySummary/README.md` AND 747's follow-up both
  > instruct.** (W)'s anchor layer is landed and bounded in `AnchorLayer.lean`; the run layer —
  > the `untl`/`snce` nesting and the lift from one seam to `¬ PlusValidZTime φ` — is BLOCKED on
  > three named obligations, each with its source and none with a measured cost
  > (`README.md:378-383`). Obligation (iii) is the presentation-size bound and is a SEPARATE
  > record's phase 1, not this one's.
  >
  > **PHASE 1 (the design question only; DISPATCH STOPS HERE).** Thread-indexed unfolding versus
  > a bounded-deadline encoding, for a frame-scheme constructor producing infinite-width,
  > finitely branching regular frames. Inputs: the refuted repair shapes `Rbad`
  > (`b2b-frame-constructor-branching.lean:178`) and `Rok`, whose positive halves
  > `fib_finite_of_finBranch` (`:147`) and `saturation_of_finBranch` (`:169`) need TWO-SIDED
  > finite branching; and the `Node` thread-unfolding shape
  > (`PlusSlicedCertificate/Limits/NoFiniteWidth.lean:132`), which is neither refuted nor built.
  > Phase 1's outcome is what makes phases 2-3 costable; this record says so rather than pricing
  > them. **Phase 1 also outputs the depth `k` the run layer needs**, since the bound record lands
  > its result for every `k` and chooses none. **INFINITE WIDTH IS FORCED**, by
  > `not_finite_width_fmp` (`Limits/NoFiniteWidth.lean:1280`) and concretely by
  > `Probe747.modelOf_incomplete` (`w-soundness-shape-refuted.lean:131`); any phase reintroducing
  > a finite-width or finite-fibre assumption reproduces a refuted shape. The ~120-160 line figure
  > is CARRIED, UNVERIFIED from (S) and covers the regularity part only (`README.md:368-370`); the
  > unfolding design is unmeasured and this record states that it has no cost figure.
  >
  > **PHASE 2 — OBLIGATION (ii), SOUNDNESS HALF (object → model).** A Hit-level realization
  > theorem for phase 1's constructor: the analogue of `presented_modelOf` (`Realize.lean`, the (S)
  > realization theorem that discharged `Presented` for `modelOf`) at `HitPresented` level, PER
  > CELL. The `stab` case of the constructor's truth lemma needs the built model to be
  > `HitPresented` at every cell by the object's per-cell presentation. It must be Hit-level or
  > product-level per cell — `HitPresented`, family-triple SETS — and NEVER trace-level
  > `Presented`, because `stab_iff_of_presented_nowUnique`
  > (`w-soundness-shape-refuted.lean:188`) shows trace level collapses `ψ ↔ ⊡ψ` at any
  > `Presented`+`nowUnique` seam; see `w-soundness-shape-refuted.lean:44-49` for the consequence
  > as the probe states it.
  >
  > **PHASE 3 — OBLIGATION (ii), COMPLETENESS HALF (model → object) = (C)'s GENERAL ROW.** Every
  > refuting model must yield an object whose per-cell presentations present its cells. Stated
  > verbatim from `RaySummary/README.md:154`: "For every regular `ℤ`-model `M`, seam `(τ, t)`,
  > formula `φ` and depth `1 ≤ k`, a finite labelled presentation `(Q, lab, step)` with
  > `Fintype.card Q` below a computable bound in `φ`, such that
  > `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`". This is OPEN MATHEMATICS with ONE positive
  > fixture and no general argument: `Probe735.not_presented` refutes the TRACE-level version
  > (which is why the Hit level is the only one left), `Probe745.hitPresented_modelA` is the only
  > Hit-level positive, and a grep for `¬ HitPresented` / `not_hitPresented` over
  > `specs/evidence/seam-gluing-ray-product/*.lean` and `RaySummary/` returns ZERO — there is no
  > Hit-level negative anywhere. No cost figure, and this record states that none exists.
  >
  > **SEMI-DECIDABILITY CAVEAT, carried verbatim from `README.md:380-385` and binding on this
  > record's acceptance**: "Without (iii), a landed composition theorem would read
  > `¬ PlusValidZTime φ ↔ ∃ object, …` over an UNBOUNDED run layer — at best semi-decidable — and
  > NOT `Decidable (PlusValidZTime φ)`." `Decidable (PlusValidZTime φ)` must appear in no
  > statement of this record.
  >
  > **DOCUMENTATION DELIVERABLE (one paragraph, no new task).** Record in
  > `FormalSystem/Metalogic/Decidability/RaySummary/README.md`'s (W) section that the obstruction
  > (W) names has a literature description: the quasimodel-realisation step of Hodkinson-Wolter-Zakharyaschev
  > 2000 Def. 12 and Gabbay-Kurucz-Wolter-Zakharyaschev 2003 Thm 13.6 presupposes a freely chosen
  > state function and run set — HWZ Remark 13 (PDF p.11) makes run choice free in both — whereas
  > TM's quasistate at every time is the type set realised by the history set (the SAME set at
  > every time, by shift closure) and its runs are the task-respecting paths of ONE time-invariant
  > relation whose states carry both the atoms and every `stab` formula (`stab_state_only`,
  > `PlusTruth.lean:332`). That is the condition under which published quasimodel realisation
  > stops applying, and it is exactly what (W)'s soundness half is about. DELIVERABLE-HYGIENE: this
  > file is NOT `specs/**`, so the paragraph must carry no task-number references and no
  > record-versioning language; cite durable anchors (file names, theorem names, author-year
  > citations, section headings) only.
  >
  > **NO DEPENDENCY EDGE to the bound record.** An edge would assert the run layer cannot proceed
  > without the bound; `README.md:380-385` says it can, yielding a weaker (semi-decidable)
  > statement. Serialization comes from the `file_scope` overlap both records declare on
  > `RaySummary/README.md` and `docs/theorem-index.md`; ordering comes from the roadmap's Run
  > block. The gate serializes, the roadmap orders, and no record claims a blocking relation that
  > does not exist.
  >
  > **BINDING CONSTRAINTS.** No complexity bound, upper or lower, anywhere; the ARGUED CTL⋆
  > 2EXPTIME ceiling is never an upper-bound source. Never write that L⁺ is decidable or
  > undecidable unqualified — carry frame class, fragment, premise set and hypothesis,
  > `[F.IsRegular]` at minimum. File no fourth certificate class: no class presenting finite
  > per-time fibres is complete whatever its clauses, and both halves of that obstruction are
  > landed under `PlusSlicedCertificate/Limits/`. Sorry-free completion required; `[BLOCKED]` with
  > the obstruction named is the honest outcome for a route that does not close.

- [ ] Second `state-write.sh` call setting `.file_scope` on `$W`: a `FormalSystem/Metalogic/Decidability/RaySummary/`-resident new module path, `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `docs/theorem-index.md`, `specs/evidence/seam-gluing-ray-product/`, `scripts/check-evidence-probes.sh`. Fold `--regen-todo` in.
- [ ] `bash .claude/scripts/manage-topics.sh set $W decidability`.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: Only `specs/state.json` is written, covered by `bash .claude/scripts/validate-state.sh specs/state.json`; no Lean module or script is edited, so no build or suite applies.

**Scope Hypothesis**: `$W` is expected to be one greater than Phase 1's `$N` (750 if nothing else creates a task); read `next_project_number` immediately before the write and read the assigned number back.

**Files to modify**:
- `specs/state.json` - one new record with `file_scope`, number bumped, topic registered
- `specs/TODO.md` - regenerated

**Verification**:
- `jq` read-back shows the record with a 5-entry `file_scope`, `dependencies` absent or `[]`, and the "DISPATCH STOPS HERE" instruction present in the description.
- The description contains no `Decidable (PlusValidZTime` string except inside the sentence saying it must appear nowhere.
- `bash .claude/scripts/validate-state.sh specs/state.json` reports no ERROR.

---

### Phase 3: Revise 720 (enlarged) and declare 714's file_scope [NOT STARTED]

**Goal**: Execute 02 R5 and R7: enlarge 720 from a citation tidy-up to a CI repair with the
tracked-ness check as a named deliverable, and declare 714's `file_scope` so the overlap gate can
see it.

**Tasks**:
- [ ] Revise 720's description with a `state-write.sh` jq filter on `.active_projects[] | select(.project_number == 720) | .description`. **Append** the following to the existing text rather than replacing it, and delete only the two spent passages named below:

  > **ENLARGED: THIS IS A CI REPAIR, NOT A CITATION TIDY-UP.** Two of the three `WIRED_REPO`
  > entries in `scripts/check-evidence-probes.sh` point at files git does not track. Both were
  > tracked under their live task paths (`1b7b8431f`, `b1180dbf8`), were DELETED FROM THE INDEX by
  > the archive commit `70321e938` (349 and 1180 lines), and were then re-pointed to the ignored
  > `specs/archive/` paths by `e8cfcd868`. The gate never checked tracking: `check_probe` tests
  > `[ ! -f "$file" ]` only (`scripts/check-evidence-probes.sh:717-720`), and a grep for
  > `ls-files|check-ignore` over the script finds nothing executable.
  >
  > **CI CONSEQUENCE.** `.github/workflows/ci.yml:119-125` runs
  > `bash scripts/check-evidence-probes.sh` after a plain `actions/checkout@v5` (`:22-23`; no
  > workspace cache, only `lean-action`'s `.lake` cache). The step is `continue-on-error: true`
  > (`:121`) but the summary step counts a failed outcome and EXITS 1 (`:352-356`). A checkout that
  > lacks untracked files hits the missing-file branch for both entries, so the gate reports
  > `FAIL (missing: …)` twice and the summary step fails the job. (That last step is an inference
  > from `git ls-files` + `.gitignore:94` + `:717-720` + `:352-356`, each verified; CI logs were
  > not fetched.)
  >
  > **DELIVERABLE A — CLOSE THE MECHANISM (not optional).** Add a tracked-ness check to
  > `check_probe` beside the `-f` test — `git ls-files --error-unmatch "$file"`, failing loudly —
  > so a `WIRED_REPO` target that git does not track is reported as such. WHY IT RECURS WITHOUT
  > THIS: `/task --abandon` moves a task directory into `specs/archive/` with `mv`
  > (`.claude/context/patterns/task-abandon-mode.md:58-65`) and `/todo` archival does the same (the
  > `70321e938` commit), so ANY `WIRED_REPO` entry pointing into a live task directory is silently
  > un-tracked the day that task is archived, with the gate still green locally for everyone who
  > has the file on disk. Add one paragraph to `check-evidence-probes.sh`'s header stating the rule
  > — TRACKED, NOT MERELY PRESENT — and one sentence beside the `mv` in `task-abandon-mode.md`.
  >
  > **DELIVERABLE B — RESOLVE THE TWO ENTRIES.** Either force-track them (the precedent is the
  > third `WIRED_REPO` entry, `specs/archive/476_…/evidence/fmp-hypothesis-is-false.lean`, which IS
  > tracked as one of the five force-tracked archive files `ci.yml:239-240` names), or convert them
  > to `WIRED` entries under `specs/evidence/`, or delete them if the landed `Limits/` theorems
  > subsume them. Library prose also cites the force-tracked 476 path
  > (`Limits/FiniteCarrier.lean:55,146`, `BiLasso/Assembly.lean:26`); those citations are NOT
  > broken and are named only so a future force-track audit knows they exist.
  >
  > **SPENT PASSAGES, to delete rather than carry.** The "PATHS NOT YET BUILT" paragraph is spent:
  > `PlusSlicedCertificate/Limits/` now exists, and the landed library names to cite are
  > `no_finite_carrier_sat`/`not_finite_carrier_fmp` (`Limits/FiniteCarrier.lean:248,:349`) and
  > `no_finite_width_sat`/`not_sliced_complete`/`not_finite_width_fmp`
  > (`Limits/NoFiniteWidth.lean:1200,:1257,:1280`), in namespace
  > `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth`
  > (`NoFiniteWidth.lean:95-103`) — never the archived `Probe706.`/`Probe710.` spellings. And
  > Deliverable 3 (close as subsumed) NO LONGER APPLIES, per `FMP/README.md:84-98`.
  >
  > **RUN-ORDER NOTE.** This record is promoted ahead of the sliced-certificate pair: a red CI gate
  > on every push outranks a local defect seen only by whoever runs the 300 s reproducer.

- [ ] Confirm 720's existing `file_scope` already covers `scripts/check-evidence-probes.sh` (it does: three entries, including that path). Add `.github/workflows/ci.yml` and `.claude/context/patterns/task-abandon-mode.md` to it if Deliverable A's header/prose edits are to be in scope — **decide and record which**; do not silently widen.
- [ ] Declare 714's `file_scope` (it currently has none, verified this dispatch) with a `state-write.sh` filter: `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Live.lean`, `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean`, `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Labels.lean` if it exists (verify with `ls` first; omit if absent), `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean`. 714 and 716 both touch `PlusSlicedCertificate/`, and declaring 714's scope is the prerequisite to running them as a batch at all. Fold `--regen-todo` into the last write.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: Only `specs/state.json` is written (descriptions and one `file_scope`), covered by `bash .claude/scripts/validate-state.sh specs/state.json`; `ci.yml` and `check-evidence-probes.sh` are only CITED in prose here, never edited, so no CI or gate run is implicated.

**Scope Hypothesis**: `PlusSlicedCertificate/Labels.lean` is a guess at the module 714's "full labels" evaluation would touch; the implementer MUST `ls FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/` and declare only paths that exist or that the task's own description names.

**Files to modify**:
- `specs/state.json` - 720's `description` (and possibly `file_scope`), 714's `file_scope`
- `specs/TODO.md` - regenerated

**Verification**:
- `jq -r '.active_projects[]|select(.project_number==720)|.description' specs/state.json | grep -c '70321e938\|e8cfcd868\|717-720\|352-356'` is 4 or more, and the "PATHS NOT YET BUILT" string is absent.
- `jq '.active_projects[]|select(.project_number==714)|.file_scope' specs/state.json` is a non-empty array of paths that all exist on disk.
- `bash .claude/scripts/validate-state.sh specs/state.json` reports no ERROR.

---

### Phase 4: Close 725 as subsumed [NOT STARTED]

**Goal**: Execute 02 R4: write the subsumption evidence into 725's description **first** so the
archived record carries it, then abandon it.

**Tasks**:
- [ ] Revise 725's description with a `state-write.sh` jq filter, appending:

  > **CLOSED AS SUBSUMED.** This record's own subsumption clause forbids manufacturing a redundant
  > second probe, and its deliverable already exists, wired, in two places.
  > `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` is experiment
  > E1 on the transcribed time-asymmetric graph, wired at `scripts/check-evidence-probes.sh:641`,
  > with `Probe719Backward.pastStab_iff_allBwdPathsMeet` at `:577` and
  > `Probe719Backward.decide_past_stab` at `:599`. The backward-NONDETERMINISTIC case — the one
  > region where the finite-width obstruction can appear — is covered by the mirror fixture
  > `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`, wired at
  > `scripts/check-evidence-probes.sh:642`, whose `Probe733Mirror.two_bwd_paths` (`:550`) is
  > axiom-free with backward branching factor exactly 2 at every spine state. Nothing remains for
  > this record to deliver.

- [ ] Verify the write landed: `jq -r '.active_projects[]|select(.project_number==725)|.description' specs/state.json | grep -c 'CLOSED AS SUBSUMED'` is 1.
- [ ] Only then run the abandon flow per `.claude/context/patterns/task-abandon-mode.md`: read the full record JSON, insert it into `specs/archive/state.json` with `status: "abandoned"` and an `abandoned` timestamp via `state-write.sh --state-file specs/archive/state.json`, then `del()` it from `active_projects` via `state-write.sh` with `--regen-todo`.
- [ ] No directory move is needed: `specs/725_*` does not exist (verified in 02 §2.8 and re-checkable with `ls -d specs/725_* 2>/dev/null`).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: Only `specs/state.json` and `specs/archive/state.json` are written, each covered by `bash .claude/scripts/validate-state.sh` on that file; no code path is touched.

**Files to modify**:
- `specs/state.json` - 725's description, then 725 removed from `active_projects`
- `specs/archive/state.json` - 725 inserted into `completed_projects` with `status: "abandoned"`
- `specs/TODO.md` - regenerated

**Verification**:
- `jq '[.active_projects[]|select(.project_number==725)]|length' specs/state.json` is 0.
- `jq -r '.completed_projects[]|select(.project_number==725)|"\(.status) \(.abandoned)"' specs/archive/state.json` shows `abandoned` with a timestamp, and that record's description contains the subsumption evidence.
- `bash .claude/scripts/validate-state.sh specs/state.json` reports no ERROR.

---

### Phase 5: File the two low-priority successors [NOT STARTED]

**Goal**: Execute 02 R8 and R9 (both confirmed from 01): the declaration-hygiene remediation and
the roadmap-tooling filing. Neither is a Stage 1 item.

**Tasks**:
- [ ] Create the hygiene task (`task_type: meta`, `topic: repo-hygiene`), description:

  > **DECLARATION-HYGIENE REMEDIATION FOR THE ADMISSION GATE.** Two defects make the overlap gate
  > unable to see collisions. (1) Task 177 declares `FormalSystem/Metalogic/Decidability/` as a
  > WHOLE-DIRECTORY `file_scope` entry, overlapping every non-terminal task that touches that
  > subtree — narrow it to the files it actually touches. (2) Of the non-terminal tasks, a large
  > majority (28 of 52 at the time this was detected) declare NO `file_scope` at all — backfill
  > them. `bash .claude/scripts/validate-state.sh specs/state.json` already enumerates both
  > defects as Check 8 (coarse whole-directory-root declarations) and Check 9 (duplicates); the
  > detector exists, the remediation does not. ALSO IN SCOPE if not landed first elsewhere: the
  > recurring mechanism by which `/task --abandon` and `/todo` archival un-track a `WIRED_REPO`
  > gate target (`.claude/context/patterns/task-abandon-mode.md:58-65`), whose detector is a
  > one-line `git ls-files --error-unmatch` beside the `-f` test at
  > `scripts/check-evidence-probes.sh:717-720`. Read the live validator output rather than
  > trusting the counts above; they are a snapshot, not a contract.

- [ ] Set its `file_scope`: `specs/state.json`, `.claude/scripts/validate-state.sh`. Register the topic.
- [ ] Create the roadmap-tooling task (`task_type: meta`, `topic: agent-system`), description:

  > **`roadmap-integration.sh --regenerate` IS SILENTLY INOPERATIVE ON THIS ROADMAP.** Verified
  > live: `bash .claude/scripts/roadmap-integration.sh --regenerate` exits 1 with ZERO stdout and
  > ZERO stderr and writes nothing, because `specs/ROADMAP.md` carries none of the headings the
  > assembler needs — it is a Stage-based authored document, not the `## Open work` / `## Next`
  > generated layout the script expects. Pick one and land it: either teach the script the
  > Stage-based layout, or decide that `specs/ROADMAP.md` is AUTHORED-ONLY and make `--regenerate`
  > say so LOUDLY (a named error on stderr and a documented exit code) instead of aborting in
  > silence. A silent abort is the worst of the three outcomes because a caller cannot tell it from
  > success. Note that a reference to a roadmap-tooling task circulates in other records without
  > resolving to an existing one; filing this is what makes that reference resolve.

- [ ] Set its `file_scope`: `.claude/scripts/roadmap-integration.sh`, `specs/ROADMAP.md`. Register the topic. Fold `--regen-todo` into the last write.
- [ ] **Source-store note for the implementer**: `.claude/scripts/roadmap-integration.sh` lives in a deployed tree. The created task's own implementation must resolve `source_dir` from `.claude-extensions.json` and edit the source store, per `.claude/rules/source-store-deploy-boundary.md`. State that in the description.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: Only `specs/state.json` is written; `bash .claude/scripts/validate-state.sh specs/state.json` is the covering check, and neither created task's work is performed here.

**Scope Hypothesis**: "28 of 52 non-terminal tasks" is a carried snapshot figure from reports/01; the description instructs the implementer of THAT task to read the live validator output instead, and this plan does not re-verify the count.

**Files to modify**:
- `specs/state.json` - two new records with `file_scope`, number bumped twice, two topics registered
- `specs/TODO.md` - regenerated

**Verification**:
- Both records read back with `status: "not_started"`, `task_type: "meta"`, non-empty `file_scope`, and their topics present in `active_topics`.
- `jq -r '.next_project_number' specs/state.json` equals the Phase 1 starting value plus 4.
- `bash .claude/scripts/validate-state.sh specs/state.json` reports no ERROR.

---

### Phase 6: Hand-edit specs/ROADMAP.md [NOT STARTED]

**Goal**: Deliverable (c). Make the roadmap's Stage 1 ordering and rationale match the revised task
graph: delete the void R2 contingency, replace it with the five named risks and the literature
position, state that Stage 1 proceeds on R1 alone with no fallback, and re-order the run block.

**DO NOT run `roadmap-integration.sh --regenerate`.** It exits 1 with zero output and writes
nothing (re-verified live this dispatch), so the whole file is effectively authored. Hand-edit
only. There is no generated section to protect and no clobber hazard to manage.

**Tasks**:
- [ ] Read the four task numbers assigned by Phases 1, 2 and 5 out of `specs/state.json`; do not assume 749-752.
- [ ] **Delete the void contingency at `:186-187`** — "**Promote this line if 745 refutes, or if 733 falsifies the two-factor presentation**: R2 is the route to switch to." — and replace it with: 733 came back POSITIVE on a backward-NONDETERMINISTIC mirror fixture (backward branching factor exactly 2 at every spine state, `Probe733Mirror.two_bwd_paths` axiom-free, `pastStab_iff_allBwdPathsMeet` and `decide_past_stab` holding state-dependently) — R1's sharpest available falsifier, and it survived; and the literal R2 falsifier is UNSATISFIABLE, because `Probe718Mosaic.StabSaturated M S` is a tautology holding for every finite mosaic set by a one-line term (its body already carries the same-state equality box-dot's clause quantifies over; `PlusTruth.stab_iff` is an `Iff.rfl`). **R2 is a CONSUMER of R1, not an alternative to it**: the real mosaic content is the witness direction, and deciding it on semantic mosaics presupposes deciding box-dot, which IS R1's reachability summary — Caleiro-Viganò-Volpe §4.3 states verbatim that the mosaic decidability argument "does not extend" once the vertical and horizontal components interact. **STAGE 1 PROCEEDS ON R1 ALONE. THERE IS NO FALLBACK ROUTE.** Keep the existing sentence "739's refutation does NOT trigger this … Do not read '739 refuted' as a route-switch signal" — 739's ruling still binds.
- [ ] **Add the five named risks** — 02 §2.6's four failure modes plus `reports/03`'s perfect-recall question (03 Recommendation 3) — as a table in the Stage 1 prose, each with its realized status, replacing a contingency that could not fire with modes that can:

  | Failure mode | Where it lives | Realized? |
  |---|---|---|
  | No constructor for infinite-width, finitely branching regular frames | `Rbad` (`b2b-frame-constructor-branching.lean:178`) and `Rok` refuted as repair shapes; positive halves `fib_finite_of_finBranch` (`:147`) and `saturation_of_finBranch` (`:169`) need two-sided finite branching; the `Node` thread-unfolding shape (`Limits/NoFiniteWidth.lean:132`) neither refuted nor built | **No.** Two shapes refuted, one unbuilt. Open, not failed |
  | The factorization-transport lemma does not close on model A | Not in tree; no attempt recorded anywhere | **No.** Never attempted |
  | Hit-level completeness fails for some regular ℤ-model | Trace level is false (`Probe735.not_presented`); Hit level holds on model A (`Probe745.hitPresented_modelA`); no Hit-level negative exists anywhere | **No.** One positive fixture, zero negatives, no general argument |
  | The `⊡` summary is not finitely computable under infinite backward branching | Held by `device-selection-probe.lean`, per `backward-dual-mirror-fixture.lean:65-72` | **Not a Stage 1 question**; the mirror header says so |
  | A closed L⁺ formula forces backward determinism on the relevant part of a regular ℤ-frame — the one literature-grounded route by which a published negative result could reach L⁺ | `stab`'s clause is the same-state-at-the-same-time equivalence (the `.stab` branch at `PlusTruth.lean:93`: `∀ σ, τ.state t = σ.state t → …`), and it fails the backward closure that defines the historical-necessity tradition: Thomason 1984 §4 Def. 6 condition (2) and Caleiro-Viganò-Volpe 2013 Def. 2.5 `Wdc`. **If forcing is possible**, `stab` satisfies Thomason Def. 6 (2) / Caleiro `Wdc` on that part and the know-time-do-not-forget family (GKWZ §13.2) becomes a REDUCTION TARGET. CHEAP CHECK, NAMED AND NOT SCHEDULED: one fixture deciding whether backward determinism is forceable by a closed formula; `Probe719Backward` (`backward-dual-asymmetric-fixture.lean`) and `Probe733Mirror` (`backward-dual-mirror-fixture.lean:18-24`) already inhabit the backward factor. No task is filed for it, per 03 Recommendation 3 (line 117) | **Open falsifiable question, argued in neither direction.** The hypothesis is currently unmet — which is exactly why the corpus's negatives do not apply — and nothing in the tree decides whether it can be met |

- [ ] **Add a "Literature position" paragraph** to the Stage 1 prose (03 D1-D2, F3), stating: TM/L⁺ over regular ℤ-frames EVADES every published negative result in the corpus, and for a boring reason — not one of them has a hypothesis TM meets. Every undecidability or non-r.e. theorem for products with an S5 factor needs a SECOND linear/transitive/`K` factor commuting with time, or THREE commuting factors, or a DIFFERENCE/counting operator; TM has one linear factor, one S5 factor, and no difference modality, and `stab` is not a product coordinate (Church-Rosser between `stab` and the temporal relation fails on any non-deterministic step; `stab_state_only`, `PlusTruth.lean:332`, is the formal face of the same fact). The S5-plus-linear products themselves sit on the DECIDABLE side (GKWZ Thms 6.60, 6.61; HWZ Cor 69 for `⟨Z,<⟩` with Until and Since). **Neither direction transfers**: the published positives decide SUBLOGICS of TM/L⁺ — TM is a proper extension, witnessed by `modal_future` (`Axioms.lean:297`) and `box_time_invariant` (`PlusTruth.lean:349`) being TM-valid and product-refutable, and by `stab p ↔ p` being L⁺-valid and fusion-refutable — and decidability is not inherited by extensions. **So the literature does not settle L⁺ in either direction, and "evades" is not evidence of decidability.** Record also that the fmp-plus-Until/Since signal is **NEUTRAL, not corroborating**: GKWZ Thm 5.30 and 5.32 kill the fmp of S5-plus-linear products while Thm 6.61 decides them. Reproduce NO complexity class, including from theorems whose statements name one.
- [ ] **Re-cost the (C) bullet at `:128-133`.** The "Probe before bound … Re-cost the bound half against that before planning it" instruction is SPENT: the probe ran (`Probe745.hitPresented_modelA` holds on model A at every depth `k ≥ 1`) and the bound half is now the created bound record's. Record that the bound's phase 1 is closed in principle by a compiled feasibility proof (pigeonhole plus `kTypeOf_listSeg_append_congr`, NOT finite-semigroup idempotence) and that **the cost sits in the factorization-transport lemma**, which has no figure anywhere in the tree. The 739 re-costing instruction is DISCHARGED and the finding is that the tree already satisfies the constraint: `clSig φ := subformulas φ ⊕ Unit` (`Closure.lean:80-81`) with both `untl` and `snce` arguments carried (`Subformulas.lean:66-73`), so the surviving alphabet is closure-indexed with backward labels by construction. Any count named here is a COUNT: carry `AnchorLayer.lean:317-320` verbatim beside it.
- [ ] **Update the (W) bullet at `:199-213`.** Its closing instruction — "If the run layer is to be attempted, file it as ITS OWN record with the design question … as its phase 1" — is now DONE; name the created record and that its dispatch stops at phase 1. Correct obligation (ii): it is TWO PROOF OBLIGATIONS of that record (a Hit-level realization theorem for the constructor, and the per-cell extraction for every model, which is (C)'s general row), not a hypothesis with no deliverable. Obligation (iii) is the created bound record's phase 1 and is NOT (C)'s bound.
- [ ] **Rewrite the Stage 1 Run-order block at `:20-26`** to:
  ```bash
  # Stage 1 — decidability of L⁺; run to exhaustion before anything below
  # 739,740 done 2026-10-08 -- 739 refuted the one-bit reading; see Stage 1
  # 745,746 done; 733 done (POSITIVE: the two-factor presentation was NOT falsified); 747 done
  # 734 is [PARTIAL] by a recorded user decision; it is NOT a fallback route -- see Stage 1
  /orchestrate {C-BOUND} --hard --lit   # (C)'s bound half on model A; the cost is phase 2
  /orchestrate 720                      # CI repair: untracked WIRED_REPO + the tracked-ness check
  /orchestrate {W-RUN-LAYER} --hard --lit  # dispatch phase 1 and STOP
  /orchestrate 716,714 --hard
  /orchestrate 712 --hard               # only after Stage 0 corrects its marker
  ```
  substituting the actual numbers. **725 is removed** (closed as subsumed) and **720 is promoted** out of the former `725,720` closeout line to ahead of `716,714`.
- [ ] **Update the `725,720` closeout bullet at `:228-231`**: record 725's close-as-subsumed with its two wired fixtures, and 720's enlarged scope (CI repair, tracked-ness check as a named deliverable, the `70321e938`/`e8cfcd868` history, the `ci.yml:119-125` and `:352-356` consequence, `check-evidence-probes.sh:717-720` as the line to change). Delete the now-false "it is gated behind 734 on that script" clause if the dependency no longer holds — **verify 720's `dependencies` first** and do not assert an edge state without reading it.
- [ ] **Leave untouched**: Stage 0's 712/709/712-disposition rulings, the four constraints block at `:233-248` (including constraint 1 and constraint 3's no-upper-bound rule), the 739 bullet at `:105-131`, the "Two limits on what a result may claim" and "Routes closed" blocks, and every Stage 2-4 section. Also update the file's derivation note at `:3` from "(2026-10-08)" to the current date, since the file is now authored rather than derived — or state plainly that it is authored; do not leave a stale derivation claim.

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3, 4, 5

**Verification Tier**: prose

**Tier Justification**: `specs/ROADMAP.md` is markdown with zero compile or elaboration surface, and `suite_selection_select` returns `__FULL_SWEEP__` for a `specs/**` path (no suite covers it), so the honest covering checks are a diff read-through confirming every hunk is prose plus the no-complexity-bound grep below — `specs/**` is exempt from the task-reference lint, so Gate 4 does not apply.

**Files to modify**:
- `specs/ROADMAP.md` - Stage 1 prose, run-order block, (C) and (W) bullets, the closeout bullet, the derivation note

**Verification**:
- `grep -c 'R2 is the\s*route to switch to' specs/ROADMAP.md` is 0, and `grep -c 'no fallback' specs/ROADMAP.md` is at least 1.
- The Stage 1 risk table has **five** data rows, the fifth naming Thomason Def. 6 (2), Caleiro `Wdc`, GKWZ §13.2 and the one-fixture cheap probe, and stating the question as open in neither direction — `grep -c 'Wdc' specs/ROADMAP.md` is at least 1 and no `/orchestrate` line mentions it.
- `grep -n '725' specs/ROADMAP.md` shows only the close-as-subsumed record, never a `/orchestrate` line.
- The run-order block's Stage 1 lines name the four created/revised numbers actually present in `specs/state.json` — cross-check each with `jq`.
- `grep -nEi '2EXPTIME|EXPSPACE|PSPACE|NP-|co-NP|running time|time bound' specs/ROADMAP.md` returns only the pre-existing constraint-3 sentence that rules the ARGUED ceiling OUT as a source, and nothing newly added.
- `grep -c 'AnchorLayer.lean:317-320\|counts cells, it does not time anything' specs/ROADMAP.md` is at least 1 wherever a count was added.
- Diff read-through: every changed hunk is prose or a fenced `bash` comment block; no generated section was rewritten by a tool.

---

### Phase 7: Final verification and audit [NOT STARTED]

**Goal**: Confirm the state is consistent, TODO.md renders, no settled ruling was reopened, no
complexity bound was asserted anywhere, and task 734 was not touched.

**Tasks**:
- [ ] `bash .claude/scripts/validate-state.sh specs/state.json` — no ERROR lines; record the `file_scope` WARN lines as the input they are to the hygiene task filed in Phase 6.
- [ ] `bash .claude/scripts/generate-todo.sh` and read the Stage 1 rows: four new tasks present, 725 absent, 720 and 714 showing their revisions.
- [ ] `bash scripts/check-evidence-probes.sh` — the evidence gate is expected to report the two known `WIRED_REPO` misses (that is 720's filed defect, not a regression introduced here); confirm nothing ELSE changed.
- [ ] **`git diff` audit — two assertions, both on `git diff specs/state.json`**: (1) **no 734 hunk appears** — `jq '.active_projects[]|select(.project_number==734)|{status,blockers,description}' specs/state.json` is byte-identical to its pre-run value (`status: "partial"`, `blockers: null`); and (2) **no new task record for a perfect-recall or backward-determinism probe appears** — `git diff specs/state.json | grep -niE 'perfect.?recall|backward.?determin'` returns nothing, and `jq -r '.active_projects[]|"\(.project_number) \(.project_name)"' specs/state.json | grep -iE 'perfect.?recall|backward.?determin'` returns nothing. The probe is a roadmap risk row only (03 Recommendation 3, line 117; `.decisions.json` cycle 1); a record for it in this diff is a failure of the phase, not an extra.
- [ ] **No-complexity-bound audit**: `grep -nEi '2EXPTIME|EXPSPACE|PSPACE|NP-complete|co-NP|running time|time complexity|space complexity'` over `specs/ROADMAP.md` and over every description written by Phases 1-5 (`jq -r '.active_projects[]|.description'`). Every hit must be a sentence that rules such a bound OUT, never one that asserts one.
- [ ] **Settled-rulings audit**: confirm no text written asserts a fourth certificate class, re-attempts a C9 tombstone, claims the tableau front delivers a first decidability theorem, reopens 712 or 709, schedules 713, or writes "L⁺ is decidable/undecidable" unqualified.
- [ ] **Deliverable-hygiene audit**: `bash .claude/scripts/check-task-references.sh` (or the repo's equivalent lint) over any non-`specs/**` file this run touched. Expected: this run touches none, so the audit is a confirmation that `git status --short` lists only `specs/` paths.
- [ ] Run the full gate set: `bash .claude/scripts/verify-deploy.sh`.
- [ ] Record one `issue-record.sh` entry for the run (`--kind win` or `--kind issue` as the run warrants; a run with nothing to record attests that explicitly in the summary prose).

**Timing**: 0.75 hours

**Depends on**: 6

**Verification Tier**: full

**Files to modify**:
- None (verification only; `specs/TODO.md` is regenerated, not hand-edited)

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` completes with no FINDING attributable to this run.
- `git status --short` lists only paths under `specs/`.
- `git diff specs/state.json` contains no hunk touching task 734 and no hunk introducing a perfect-recall or backward-determinism probe record.
- Every audit grep above returns the expected result, each recorded in the task summary.

---

## Testing & Validation

- [ ] Four tasks exist in `specs/state.json` with `status: "not_started"` and a non-empty `file_scope` each.
- [ ] `next_project_number` advanced by exactly 4 from its pre-run value.
- [ ] 725 is absent from `active_projects` and present in `specs/archive/state.json` as `abandoned`, with its subsumption evidence in the archived description.
- [ ] 720's description names `70321e938`, `e8cfcd868`, `ci.yml:119-125`, `:352-356`, and `check-evidence-probes.sh:717-720`, and the tracked-ness check as a deliverable.
- [ ] 714 has a `file_scope` whose every entry exists on disk.
- [ ] 734's record is byte-identical to its pre-run state, and no record for a perfect-recall or backward-determinism probe exists anywhere in `specs/state.json`.
- [ ] `specs/ROADMAP.md` asserts no fallback route, carries the five named risk rows (02 §2.6's four plus 03's perfect-recall question) and the literature-position paragraph, and its Stage 1 run order names the actual task numbers.
- [ ] `bash .claude/scripts/validate-state.sh specs/state.json` reports no ERROR; `bash .claude/scripts/verify-deploy.sh` reports no new FINDING.
- [ ] No file outside `specs/` was modified.

## Artifacts & Outputs

- `specs/state.json` — four created records, two revised descriptions, two `file_scope` declarations, one record removed
- `specs/archive/state.json` — one abandoned record carrying its subsumption evidence
- `specs/ROADMAP.md` — Stage 1 prose, risks table, literature position, run order
- `specs/TODO.md` — regenerated
- `specs/748_revise_and_create_tasks_lplus_decidability/summaries/03_*-summary.md` — written at completion
- `specs/748_revise_and_create_tasks_lplus_decidability/issues.jsonl` — appended as issues and wins arise

## Rollback/Contingency

Every write goes through `state-write.sh`, which stages to a private `mktemp` path, validates, and
moves — so a failed filter leaves the previous `specs/state.json` intact and no partial JSON is
ever published. If a phase lands a wrong value, the repair is a corrective `state-write.sh` filter
on the same field, never a hand edit of `specs/state.json` and never a destructive git operation on
the working tree.

Before Phase 4 (the only phase that removes a record), take a non-reverting checkpoint:
`bash .claude/scripts/git-snapshot.sh 748 --no-revert`. `--no-revert` is required — the default
reverting form belongs only to a genuine rollback scenario, not to a defensive checkpoint.

If Phase 6's roadmap edit goes wrong, the file is recoverable from git (`git show HEAD:specs/ROADMAP.md`)
since `roadmap-integration.sh --regenerate` cannot reconstruct it. If a phase cannot complete, mark
it `[PARTIAL]` or `[BLOCKED]` with the obstruction named; the created tasks are independent records,
so a run that lands Phases 1-4 and stalls at 5 has still delivered the primary output (tasks created
and revised) and only the roadmap edit remains.
