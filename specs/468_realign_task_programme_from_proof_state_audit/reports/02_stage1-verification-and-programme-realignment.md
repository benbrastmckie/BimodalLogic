# Stage 1-4 Verification and Programme Realignment: Task #468

**Task**: 468 - Programme realignment from a verified proof-state audit
**Started**: 2026-08-25T11:00:00Z
**Completed**: 2026-08-25T12:00:00Z
**Effort**: high (live-tree re-verification of six audit claims, re-verification of the
boxanchored-finding artifact, a full 48-task active-set survey, dependency-graph audit, and
ROADMAP.md condition assessment)
**Dependencies**: report 01 (charter), `specs/reviews/review-2026-08-24.md` (amendments 10a-10f)
**Sources/Inputs**:
- Live tree: `FormalSystem/Metalogic/Decidability/**`, `FormalSystem/Metalogic/WeakCanonical/**`,
  `FormalSystem/Metalogic/BXCanonical/**`
- `scripts/check-module-invariants.sh` (full run, this task, at the current `HEAD`)
- `specs/state.json` (48 active-set entries), `specs/archive/state.json`, `specs/ROADMAP.md`
- `specs/archive/418_.../artifacts/boxanchored-finding.md`
- `Tests/BimodalTest/{BoxSpreadProbe,RegionGateProbe,RayRegionProbe,TemporalWitnessProbe}.lean`
**Artifacts**:
- This report
- `specs/468_.../reports/01_proof-state-audit-and-realignment-charter.md` (governing input)
**Standards**: report-format.md, subagent-return.md

---

## 0. What changed between the charter/review and this dispatch

The charter (report 01) was written 2026-08-20; the review amending it
(`specs/reviews/review-2026-08-24.md`) was written 2026-08-24. This dispatch runs 2026-08-25.
**In the interim, a large fraction of the work the review's execution-order Addendum 3/4 batch
called for has already landed.** Sixteen tasks now sit at `completed` (unarchived) in
`active_projects` that were `not_started`/`partial`/`researched` in the review:
`413, 421, 423, 424, 425, 426, 451, 469, 470, 472, 473, 474, 475, 477, 478, 479`.

The most consequential of these for this task's charter:

- **469** (`eliminate_the_bridge_filtration_into_intpresentation`) and **474**
  (`wire_bilasso_decision_layer_into_live_tree`) — the review's C-2 finding (BiLasso orphaned,
  FMP "too strong" a verdict) has been acted on. `specs/ROADMAP.md` now carries a "Status:
  landed" block for `Decidability/BiLasso/` (grep-confirmed below).
- **475** (`carrier_normalization_successor_archimedean_transfer`) — closes Addendum 2's "Gap 1"
  (the discrete-Archimedean-to-ℤ normalization).
- **477, 478, 479** — a three-task chain (`ta_qz_target_structure_plumbing`,
  `tb_groupable_companion_lemma`, `tc_close_countermodel_discrete_at_base`) that **closes the
  repository's last live structural sorry**. This is the single biggest update to the audit's
  own Executive Summary, which named "exactly one live structural sorry" as a headline finding.
  It is now **zero**. See §1(f) below — this is a direct re-verification, not a restatement.
- **470** (`task_graph_and_metadata_repair`) — ran the review's Addendum 3/4 graph corrections.
  Confirmed below: the `465→428` edge exists, `95`/`426`'s dependencies are corrected, the
  archive-union dangling-edge scan is clean.
- **472/473** — the two Stage-3/Kamp-vacuity tasks the review's Addendum 4 split out of 468's
  own charter (amendment 10f). Both completed; their territory is confirmed excluded below.
- **476** (`box_faithful_small_model_theorem`) — a task that **did not exist** when the charter
  or the review were written. It is precisely the charter's §3 "genuine SEMANTIC finite model
  property" ADD candidate, already correctly scoped as open mathematics, multi-month, gated on
  475 (completed), with an explicit literature gate and a MUST-NOT-merge clause. **This closes
  one of the six ADD candidates this task was dispatched to specify** — see §5.

Net effect: this dispatch's job is narrower than the original charter envisioned, because much
of what it was going to schedule has already been scheduled and, in several cases, already
landed. What follows re-verifies the charter's six claims against the *current* tree (not the
2026-08-20 tree), reconciles the ADD list against what now exists, and completes the remaining
open items: task 455's disposition, the fifth termination residual, the ROADMAP split, and the
state.json counter repair — none of which any of the sixteen newly-completed tasks touched.

---

## 1. Stage 1(a) — the six load-bearing claims, re-verified against the current tree

All six re-confirmed directly, by symbol name, against `HEAD` at dispatch time. None depend on
line numbers.

**(a) No declaration takes `isValid` as its subject.**
VERIFIED. `grep -rn "isValid" FormalSystem/Metalogic/Decidability/` shows only: the `Bool`-valued
convenience wrappers `DecisionResult.isValid` (`DecisionProcedure.lean:93`) and
`DecisionProcedure.isValid` (`:317`, `def isValid (φ) (fc) : Bool := (decide φ (fc := fc)).isValid`);
the `Correctness.lean` case-exhaustion lemma over the four-constructor result type (`:122-126`,
pure `simp`); and `truthAt_of_isValid` (`Verified/Decidable.lean:2412`), which is about
`SoundnessLemmas.IsValid` — a *different*, semantic-side `IsValid`, not `DecisionProcedure.isValid`.
No theorem anywhere has `DecisionProcedure.isValid _ = true` as a hypothesis or conclusion.
Confirmed, and this is exactly the confusion task 178's own acceptance criterion fell into
(2026-08-24 review M-7): `truthAt_of_isValid` is not evidence of decidability.

**(b) `ruleSound_of_mem_allRulesForFC` is not lifted through the engine; no `allClosed → valid` exists.**
VERIFIED. `ruleSound_of_mem_allRulesForFC` (`Verified/Decidable.lean:3155`) is real and unique —
one declaration, cited only in prose elsewhere. `grep -rn "allClosed"` over
`Verified*/Decidable.lean`/`Saturation.lean` finds only `upgrade_allClosed` ("the bridge crosses
unconditionally", a structural certificate-upgrade lemma, `Saturation.lean:2132`) and
`buildTableauAt_allClosed_imp` (a statement relating two engine entry points to each other,
`Saturation.lean:2229`) — neither states or uses branch *satisfiability*. No `allClosed → valid`,
no `closed → unsatisfiable`. Confirmed.

**(c) `serialityRule`/`timeLinearity` fire outside `allRulesForFC` with no `RuleSound` obligation discharged there.**
VERIFIED. `Verified/RuleSpec.lean:337-343` proves `serialityRule_not_mem_allRulesForFC` and
`timeLinearity_not_mem_allRulesForFC` at every frame class — both rules are `.Base`-classified
(`:195-196`) and excluded from `allRulesForFC` by design (`:62-67`, "keyed on something other
than a formula's shape"). `ruleSound_of_mem_allRulesForFC`'s statement is universally quantified
over `r ∈ allRulesForFC fc`, so these two rules are outside its scope by construction. No
`RuleSound`-shaped obligation for either exists elsewhere in the tree. Confirmed. (Task 430 item
(a) already owns discharging this — see §5/§6.)

**(d) `Verified/Refutation/` does not exist.**
VERIFIED. `ls FormalSystem/Metalogic/Decidability/Verified/Refutation/` → "No such file or
directory". Zero files under any name matching `*refutation*` in the decidability tree.

**(e) `ProofExtraction.lean` has zero theorems; `verifyProof` is constantly `true`.**
VERIFIED. `def verifyProof (_phi : Formula) (_proof : DerivationTree .Base [] _phi) : Bool := true`
at `ProofExtraction.lean:345`, both arguments unused (underscore-prefixed). `grep -n
"^theorem\|^lemma"` on that file returns nothing.

**(f) `countermodel_discrete` is the only live structural sorry — NOW STALE, and this is the
single most important update this dispatch makes to the charter's premises.**
The claim as stated in the charter is **no longer true**. Re-verified two independent ways:
1. `grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -v Boneyard` — **empty
   output**. Zero live structural sorries anywhere in the tree.
2. `scripts/check-module-invariants.sh` (full run, this dispatch, `lake build` + `lake build
   BimodalTest` both exit 0): `C3 structural sorry inventory is ZERO across FormalSystem/`, and
   `C2` reports **all four flagship axiom sets clean**, including the one the charter's F7
   marked `Partial`:
   - `completeness` → `[propext, Classical.choice, Quot.sound]` (previously `[..., sorryAx, ...]`)
   - `completeness_dense`, `completeness_discrete` → same clean set
   - `Chronicle.countermodel_dense` → same clean set

   `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`'s own header now states this explicitly:
   *"It no longer contains `countermodel_discrete`: that theorem is proved in
   `WeakCanonical/GroupModel/CountermodelBase.lean`, at the non-Archimedean discrete carrier
   `ℚ ×ₗ ℤ`… `countermodel_discrete`, the Base-frame branch of `completeness`, is a separate
   theorem and is likewise `sorryAx`-free"*, and `BXCanonical/Completeness.lean`'s docstring
   (`:203-211`) states *"the dense and mixed branches are sorryAx-free too"*.

**Cause**: tasks 477 (`ta_qz_target_structure_plumbing`), 478 (`tb_groupable_companion_lemma`),
479 (`tc_close_countermodel_discrete_at_base`) — a three-task chain, all `completed`, none
present when the charter or the review were written. This closes the entire Base-completeness
front. **The soundness/completeness metatheory (F7 in the charter) is no longer "nearly done" —
it is done**, for all four frame classes, axiom-clean, modulo the Kamp `k≤1` scope caveat (F7's
`kampPriorExpressiveCompleteness` row, unaffected by this) and the propositional-fragment note
(unaffected). This is grounded in `check-module-invariants.sh` C2/C3, run fresh this dispatch —
not restated from another artifact.

**Consequence for the task survey (§7)**: task 169 (`build_discrete_chronicle...`, deps
`[361, 422, 448]`) and task 95 (the confirmation pass, deps `[169]`) both target
`countermodel_discrete` as still-open. It is now closed by a different route (477→478→479, via
`WeakCanonical.countermodel_discrete` at the `ℚ ×ₗ ℤ` carrier) than the one 169/422 were built to
supply (a Base-MCS-to-Discrete-consistency transfer via a discrete chronicle). **169 and 95 need
re-derivation against the now-closed tree — see their rows in §7.**

---

## 2. Stage 1(b) — box-anchor artifact re-verified, per amendment 10a (probe NOT re-run)

Per amendment 10a, the `#eval`/`#guard` probe was **not** re-run. Instead, the committed artifact
(`specs/archive/418_.../artifacts/boxanchored-finding.md`) was re-read in full and its
prerequisites re-checked against the current tree:

- All four named probes are live and present: `Tests/BimodalTest/BoxSpreadProbe.lean`,
  `RegionGateProbe.lean`, `RayRegionProbe.lean`, `TemporalWitnessProbe.lean` (a fifth,
  `UntlSnceCopyProbe.lean`, also exists and is related but not named in the artifact).
  `BoxSpreadProbe.lean` carries five live `#guard_msgs` blocks (`:168,177,185,221,229`) pinning
  the post-fix `false` verdicts for `boxAnchoredCheck`/`boxGridCheck` — these are compiled,
  kernel-checked assertions, not prose, and this dispatch's `check-module-invariants.sh` run
  confirms `lake build BimodalTest` exits 0, so they still hold.
- **Verdict, re-confirmed rather than re-derived**: NEGATIVE and broader than the charter's §2(b)
  framing anticipated. The entire decidable-branch-gate family — `boxAnchoredCheck`,
  `boxGridCheck`, `regionGate`, `regionLabelCheck`, `rayUpOk`/`rayDnOk` — collapses to `false` on
  any branch that mints a world, because the sound repair (task 418, removing unsound cross-world
  temporal-copy blocks) removed the only route by which `T(Gφ)`/`T(Hφ)` reach a freshly minted
  world. **Task 429 is a redesign, not a repair.**
- Repair options, carried forward verbatim from the artifact §5: (a) propagate `T(□φ)` itself to
  the fresh world (S5 axiom-4/5 pattern, "very likely sound", own `RuleSound` obligation, fuel/
  termination consequences); (b) copy `T(Gφ)/T(Hφ)` only when box-derived (needs branch
  provenance tracking not currently recoverable from the flat `List SignedFormula`, and reduces
  to (a)'s obligation anyway); (c) **closed as formulated** — `boxGridCheck` (what
  `truthAt_box_iff_base` actually consumes) fails for the same structural reason the anchor does,
  so weakening only the anchor buys nothing.

**Task 429's current description already reflects this redesign framing.** It cites the artifact
by path, quotes the causal history (task 418's fix, "the cost of a correct fix, not a
regression"), states all three repair options with their obligations, and forbids reinstating the
removed copies. What it does **not** yet do, per amendment 10a's specific ask, is *name option (a)
as the recommended route up front* rather than presenting all three neutrally — see the REVISE
row for 429 in §7.

---

## 3. Stage 0 — task 455's disposition

**Verdict: ABSORB**, confirmed independently of the review's recommendation (which is treated
here as evidence, per amendment 10d, not as the decision).

Evidence gathered directly:
- 455's own Stage 1 scope ("bring `specs/ROADMAP.md` and every remaining active task into
  agreement with the progress actually made", grounding claims in
  `scripts/check-module-invariants.sh` C2/C3/C4/C5/C7) is a strict subset of this task's Stage
  4(c), which additionally requires the PROVEN-vs-SORRY-FREE distinction, refuted-route
  tombstones cross-referencing the C9 register, and — per amendment 10c — the archive split. A
  task that only re-audits against the same five checks 4(c) already audits against, without the
  extra distinctions, produces strictly less than 4(c) already produces.
- 455's Stages 2-4 (per-task anchor sweep, verdict issuance) are contained in this task's Stage 2,
  which extends the verdict vocabulary with `ADD` and `REOPEN` beyond 455's four-verdict set.
- 455 currently carries `dependencies: [452, 454, 468]` (confirmed via `jq` against
  `specs/state.json`), so it cannot run before this task regardless of disposition.
- No scope in 455 is NOT covered by this task's Stage 2/4(c): the full active-set survey in §7
  below covers every task 455 would have covered, and produces file-scope/anchor corrections
  (177, see §6) that 455 would otherwise have had to re-derive.

**Recommendation to the user**: propose 455 for abandonment once this task's realignment is
acted on. Do not transition it here (constraint, §9 of the charter).

---

## 4. Section 2(c) — re-derived status of five flagged tasks

All five confirmed via `jq` against `specs/archive/state.json` (archived tasks) or direct grep
(active file_scope).

| Task | Verdict | Evidence |
|---|---|---|
| **165** (archived `completed`) | **CURRENT — no correction needed.** Its own archived description explicitly redirects itself away from a false completeness claim: *"the tableau stack exists and builds... but the stack is sound only, and three gaps block any decidability theorem"* (WP1-WP4 enumerated as future work). It spawned 428/429/430 to carry O1-O4 forward, and those three tasks' descriptions today accurately cite 165's Phase 7.3 deadlock and correctly state what remains. The audit's F9 characterization ("completed over unfinished work") is technically true of the label but the successor tasks fully and correctly document the residue — there is no reader-facing gap. No action proposed. |
| **432** (archived `completed`) | **CURRENT.** Task 432's own summary states *"the residual is not discharged, so removing it would be unsound"* — this is candor, not overclaim. Its residual (`UnorderedSuccessorLabelClosed`) is real and unowned downstream — see §5's fifth-residual ADD, which is the actual corrective action, not a reopening of 432. |
| **436** (archived `completed`) | **CURRENT.** Left the density coordinate open by design; it is task 464 (`gappotential_density_measure_component`, not_started, correctly described as "the one genuinely OPEN MATHEMATICAL question remaining on the totality terminus"). No correction needed — the successor already owns it precisely. |
| **170** (archived `completed`) | **CURRENT, and independently re-verified today.** 170's completion_summary rests on `completeness_dense` being sorryAx-free. This dispatch's fresh `check-module-invariants.sh` C2 run (§1(f)) confirms `completeness_dense → [propext, Classical.choice, Quot.sound]` directly, which is stronger evidence than the administrative clean-build re-verification 170 asked for and (per its archived record) never explicitly logged. Substance confirmed; no correction needed. |
| **177** (active, `not_started`) | **file_scope defect already fixed — verify only, no action needed.** The charter and the 2026-08-24 review (M-6) both flag `file_scope: ["README.md","ROADMAP.md","FormalSystem/","FormalSystem/","docs/"]` (unresolvable `ROADMAP.md`, duplicated `FormalSystem/`). Read directly from `specs/state.json` this dispatch: `file_scope` is now `["README.md","specs/ROADMAP.md","FormalSystem/","docs/"]` — resolvable path, no duplicate. Task 470's item (G) fixed this, as its own description credits. See §6 for the DIVIDE disposition (already half-executed by task 472, per amendment 10f). |

---

## 5. Amendment-aware ADD list — reconciled against tasks created since the review

Amendment 10b struck three candidates (soundness lift, RuleSound-at-firing-site, 428's
`buildTableau_isSome` framing) as already owned by 430/428. Re-checked directly this dispatch —
430's live description (verbatim, `jq` against `state.json`) already states item (a)
("`serialityRule`/`timeLinearity`... deliberately outside `allRulesForFC`, so
`ruleSound_of_mem_allRulesForFC`... does NOT cover them") and item (b) ("THE SEMANTIC LIFT: the
induction lifting single-step satisfiability preservation... comparable in weight to a landed
sub-phase"), and 428's description opens with *"THE REFUTED THEOREM, SETTLED"* exactly as 10b
records. **Confirmed struck; not re-added.**

Of the six items amendment 10b left in scope, re-checked against the tree and against every
active task description:

| Item | Status this dispatch | Disposition |
|---|---|---|
| `isValid φ fc = true → ⊨ φ` plumbing bridge | **Still genuinely uncovered.** `decide_sound'` (`Correctness.lean:66`) already proves `decide φ ... = .valid proof → ⊨ φ`, but nothing bridges the *Boolean* wrapper `DecisionProcedure.isValid` (`:317`, discards the proof term) back to a semantic conclusion. The missing lemma is: case on `decide φ fc`; in the `.valid proof` case, `isValid = true` holds and `decide_sound` applies; every other case contradicts `isValid = true`. Genuinely "hours, pure plumbing" as the charter says. | **ADD** — see new task spec below. |
| Proof-extraction completeness (`.extractionFailed` elimination) | **Still uncovered.** `ProofExtraction.lean` unchanged (§1(e)); no task's `file_scope` names it. | **ADD** — see new task spec below (multi-month, per R4). |
| Genuine semantic FMP | **Now covered.** Task 476 (`box_faithful_small_model_theorem`), not_started, deps `[475]` (completed). Already correctly scoped: OPEN MATHEMATICS, multi-month, explicit literature gate (Gabbay-Kurucz-Wolter-Zakharyaschev, *Many-Dimensional Modal Logics*, empowered to refute the task outright), explicit MUST-NOT-merge-into-engineering-task clause. This is a materially *better* scoping than the charter's own R4 entry (it names the box-faithfulness obstruction precisely and distinguishes it from the tractable closure-type-space construction). **No action — do not duplicate.** | No action |
| `NoSplit`-free termination result | **Still open, but already tracked precisely inside 428's own description**, which lists "Discharge the branching-arm residual that `NoSplit` currently hypothesises" as sub-obligation 1 of 3. Not a distinct uncovered item — it is inside 428's scope as written. | No action — already owned |
| Split-arm fuel adequacy ASSESS | **Partially covered, needs one clarifying addition.** 428 sub-obligation 2 ("supply the missing WORLD-COUNT dimension") is adjacent but distinct from the `allocateFuelProportionally`/`β^depth` split-arm scaling problem documented in `Fuel.lean:1595-1610` ("depth is not bounded by anything proved here... a real property of a deliberate engine policy, not a gap in a proof"). 428's description does not currently instruct an explicit ASSESS-and-register fallback if this proves unclosable. | **REVISE** 428 — see §7 row |
| Fifth termination residual `UnorderedSuccessorLabelClosed` | **Confirmed unowned.** Defined `MintBound.lean:6199`, carried as a live hypothesis at `:6215` by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse`, refuted in-tree at `:6238` (`¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`), and `:6127` records it "still a named residual". Directly grepped tasks 462, 463, 464, 465's full descriptions this dispatch: **none mentions the symbol.** Task 470's own report already flagged this as unresolved and gated on this task. | **ADD** — see new task spec below |

### New task spec 1 — `isValid`-to-validity plumbing bridge

- **Title**: `bridge_isvalid_bool_to_semantic_validity`
- **Task type**: `lean4`; **topic**: `decidability`; **effort**: low (hours)
- **Classification**: routine engineering, not open mathematics — state this explicitly in the
  description so it is never budgeted as anything larger.
- **File scope**: `FormalSystem/Metalogic/Decidability/Correctness.lean`,
  `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`
- **Description**: Prove `isValid_sound (φ : Formula) (fc : FrameClass) (h : isValid φ fc = true) :
  ⊨ φ` (or the frame-class-relativized form actually consumed downstream — check what `430`'s
  `valid_iff_allClosed` / the four `Decidable` instances will actually need before fixing the
  exact statement). Proof sketch: `unfold isValid at h`; case on `decide φ (fc := fc)` via its
  four constructors; in the `.valid proof` case, `h` is definitionally `true = true` and
  `decide_sound' φ … proof rfl` (or equivalent) closes it; the other three cases make `h` a
  contradiction (`DecisionResult.isValid` is `false` on `invalid`/`fuelExhausted`/
  `extractionFailed`, already proved by the case-exhaustion lemma at `Correctness.lean:122-126`).
- **Dependencies**: none beyond what already exists (`decide_sound'` is landed). Genuinely
  startable now, independent of the whole decidability chain (410-465).
- **Why this is not folded into 430**: 430's target (`valid_iff_allClosed`) is the *engine*-facing
  direction over `Derivable`/branch closure; this is the *decision-procedure*-facing direction
  over the `Bool` API a caller of `isValid`/`isTautology`/`isContradiction` actually holds. They
  are different theorems about different functions and should not be conflated the way the audit
  itself warns against (F1: "`isValid`'s `false` conflates 'judged invalid' with 'claimed
  valid'").

### New task spec 2 — proof-extraction completeness

- **Title**: `discharge_proof_extraction_completeness`
- **Task type**: `lean4`; **topic**: `decidability`; **effort**: high (multi-month; genuine open
  mathematics per R4 — **do not schedule as engineering**)
- **File scope**: `FormalSystem/Metalogic/Decidability/ProofExtraction.lean`,
  `FormalSystem/Metalogic/Decidability/Verified/Refutation/` (does not yet exist — this task or a
  predecessor may need to create it)
- **Description**: Eliminate `.extractionFailed` as a live outcome of `decide` on a genuinely
  closed tableau. Currently `verifyProof` is `fun _ _ => true` (honestly commented, misleadingly
  named — `ProofExtraction.lean:345`) and no theorem establishes that a closed tableau *always*
  yields an extractable Hilbert-system derivation. This requires the missing refutation induction
  (`allClosed → Derivable`, the content that would live in `Verified/Refutation/Core.lean`, zero
  files today) as a prerequisite — task 412 already targets exactly this induction
  (`allClosed_derivable`) but is itself gated on 410/411/428/429/430. **Sequence this task after
  412, or fold it into 412's acceptance criteria as an additional corollary — do not schedule it
  as an independent parallel effort that would redundantly re-derive the refutation induction.**
- **Dependencies**: `[412]`
- **Note for the planner**: given the sequencing note above, this may be better recorded as a
  REVISE to 412's acceptance criteria (add "`.extractionFailed` is unreachable on a closed
  tableau" as a corollary of `allClosed_derivable`) rather than a wholly separate task. Flagging
  both options here rather than picking one, because it is a planning-stage judgment call, not a
  research-stage one.

### New task spec 3 — the fifth termination residual

- **Title**: `discharge_or_replace_unorderedsuccessorlabelclosed_residual`
- **Task type**: `lean4`; **topic**: `decidability`; **effort**: medium-high (genuinely open — the
  predicate is refuted as stated, so this is a repair-or-replace problem, not routine discharge)
- **File scope**: `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`
- **Description**: `UnorderedSuccessorLabelClosed` (`MintBound.lean:6199`) is carried as a live
  hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` (`:6215`) and has an
  in-tree refutation at `:6238` (`¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`) — the same
  shape of problem `DifficultyBounded` presented before `StepLengthBounded` replaced it. Determine
  whether: (a) the predicate can be discharged at the frame classes/settings the surviving
  terminus theorems actually need (distinct from the setting `:6238` refutes it in — check
  precisely which); or (b) it needs a `StepLengthBounded`-style weaker replacement, analogous to
  the `DifficultyBounded`→`StepLengthBounded` repair pattern already in this file; or (c) it is
  unclosable as stated and needs a C9 register entry (the file already has 24 such entries; this
  would be the 25th) plus an explicit statement of which theorem still carries it and at which
  frame classes, per amendment 10e. **A C9 entry is a valid, complete deliverable for this task —
  do not treat "prove it" as the only acceptable outcome.**
- **Sequencing note, direct from amendment 10e**: task 462 targets `MintPaysForTimeFixed`
  discharge at a **nonempty universe**, which is the same setting `:6238`'s refutation applies in.
  If this task and 462 are not sequenced, 462 risks either duplicating the discovery of the
  refutation or (worse) building on an implicit assumption that this residual is harmless.
  **Recommend this task run before or alongside 462, with an explicit note in 462's description
  once this task lands** (a REVISE to 462, not performed here).
- **Dependencies**: `[434]` (established the residual set this belongs to). Do **not** fold into
  465 (the mechanical restatement-family task) — 465 is explicitly scoped as "a one-line
  application of its family root" for *settled* residuals; this residual is not settled, so
  folding it in would either force 465 to do research work outside its charter or produce a
  restatement of an unsettled predicate, which is exactly the kind of premature-closure risk this
  whole task exists to prevent.

---

## 6. Stage 3 — task 177's retained half

Per amendment 10f, task 472 already executed the ungated correction pass (items (a)-(i) of F10
plus six more it found). Confirmed via `state.json`: 472 is `completed`, its artifacts record
"all nine items (a)-(i) plus six additional in-scope defects corrected; both builds green."
Task 473 (Kamp vacuity deletion) is also `completed`, confirmed disjoint in file scope from 472
(472: nine documentation/docstring files; 473: seven Kamp files, per its own plan's territory
statement).

**What remains of 177**, restated with 472's and 473's territory explicitly excluded:

> Update `README.md`, `docs/`, and `FormalSystem/` module-level docstrings to their final
> post-refactor state, **once** the decidability chain (426, 428, 429, 430, 432, 433, 434) lands.
> This is the *final polish* pass, distinct from and run after task 472's already-completed
> *immediate* correction pass. Explicitly excludes: every item 472 already corrected (the
> `Decidability.lean` Status block, `Verified/README.md`, `FMP/README.md`,
> `DecisionProcedure.lean`'s `decideAuto` docstring, `Verified/Decidable.lean`'s Status docstring,
> `WeakCanonical.lean`, `RealModel/ShuffleReal.lean`, `Soundness.lean`,
> `PriorExpressivenessDense.lean`) and the two Kamp files 473 already swept
> (`Kamp/EANegationClosure.lean`, `NfMultiAnchorBridge/NavigatedSpine.lean`). This task's residual
> content is: re-auditing all touched documentation for drift accumulated *during* the
> decidability chain's landing (472/473 audited a snapshot; the chain's remaining tasks will touch
> further files after 472/473 ran), and the Axiom Reference update the charter names as part of
> 177's original scope.

`file_scope` is already correct (verified, §4). No further edit needed there. **Verdict: DIVIDE,
already half-executed exactly as amendment 10f states — the remaining half needs only the
description text above, not a new task.**

---

## 7. Full active-set survey — verdict for every task

Verdicts below distinguish **freshly re-verified this dispatch** from **carried from the
2026-08-24 review** (one day old, out of this dispatch's core scope, not independently
re-derived here). Every one of the 48 `active_projects` entries gets a row; none silently
skipped, per the charter's verification requirement.

### Decidability / tableau front (core scope of this task — all freshly verified)

| Task | Status | Verdict | Evidence |
|---|---|---|---|
| 410 | planned | CURRENT | Internalizes tableau branches; unaffected by this dispatch's findings. |
| 411 | not_started | CURRENT | Depends on 410; no drift found. |
| 412 | not_started | **REVISE** | Description's line `"discharge the pre-existing sorry countermodel_discrete at ...Transfer.lean:1242"` is now STALE — that sorry no longer exists (§1(f)); the theorem it names moved to `WeakCanonical/GroupModel/CountermodelBase.lean` and is already closed. Strike that clause; the remaining scope (`allClosed_derivable`, `Decidable (Derivable fc [] φ)`, completeness corollaries, Dedekind engine) is unaffected and still open. Also fold in proof-extraction completeness as a corollary target per §5's new-task-spec-2 planning note. |
| 421 | completed | CURRENT | Acceptance criterion already corrected to "unchanged at 1" using C3, not the stale inline `grep`/"2" the 2026-08-24 review's H-6 flagged. Verified directly against the live description. |
| 422 | researched | **RE-DERIVE AT PLAN STAGE** | Targets a discrete chronicle over a non-Archimedean carrier as a route to `countermodel_discrete`. That theorem is now closed by a *different* route (477→478→479, §1(f)). Whether 422/169 are now redundant, or whether they still supply something the 477-479 chain does not (e.g., a different, possibly more general or more reusable chronicle construction), is a real question this dispatch cannot answer from research alone — it needs a planner to read 422's own report against 477-479's actual proofs. Flagging, not resolving. |
| 423, 424, 425 | completed | CURRENT | Unaffected by this dispatch's core findings; part of the now-closed strong-completeness starter cluster. |
| 426 | completed | CURRENT | Deps corrected to `[470]` per the review's H-2; confirmed via `jq`. |
| 428 | blocked | **REVISE** | Add an explicit ASSESS-and-C9-register escape clause for the split-arm fuel scaling problem (`allocateFuelProportionally`/`β^depth`, `Fuel.lean:1595-1610`), per §5. Currently blocked correctly on `[432,433,434,465]` — 432 done, 433/434 partial, 465 not_started; blocking status is accurate. |
| 429 | not_started | **REVISE (minor)** | Already correctly reflects the redesign framing (§2) with all three repair options and their obligations stated. Add one sentence naming option (a) as the recommended route per amendment 10a, so a dispatch does not have to re-derive the recommendation from the artifact each time. |
| 430 | not_started | CURRENT | Already correctly owns items (a) and (b) exactly as amendment 10b requires; verified verbatim against the live description. No action. |
| 432 | archived completed | CURRENT | See §4. |
| 433 | partial | CURRENT | Own description already delegates its residual work downstream to 463/465 explicitly ("This task's own residual work... has moved downstream to tasks 463 and 465... do not re-attempt those here"). H-1's concern is already addressed in prose; the graph edge (`465→428`) is independently confirmed wired (§8). |
| 434 | partial | CURRENT | Same pattern — delegates to 462/464 explicitly in its own text. |
| 436 | archived completed | CURRENT | See §4. |
| 462 | not_started | **REVISE (pending new task 3)** | Once the fifth-residual task (§5) exists, add a note to 462's description that it targets discharge at a nonempty universe — the same setting `UnorderedSuccessorLabelClosed` is refuted in — and to sequence accordingly. Not performed here (planning-stage edit). |
| 463 | not_started | CURRENT | Correctly scoped, no drift found. |
| 464 | not_started | CURRENT | Correctly the density-coordinate research item; unaffected. |
| 465 | not_started | CURRENT | Correctly scoped as mechanical restatement of *settled* residuals; explicitly should NOT absorb the fifth residual (§5). |
| 469 | completed | CURRENT | Verified: `ROADMAP.md` now carries the BiLasso "Status: landed" block this task produced. |
| 474 | completed | CURRENT | Same. |
| 475 | completed | CURRENT | Closes Addendum 2 Gap 1; 476 correctly gates on it. |
| 476 | not_started | CURRENT | Already the best-scoped version of the "genuine semantic FMP" ADD candidate — see §5. No action. |
| 468 (this task) | researching | — | Self; deps `[469,426,451]` all completed, correctly unblocked now. |
| 470 | completed | CURRENT | Ran the graph/metadata repair; several of its own items remain open per its own report (state.json counters, §9) — carried forward here, not re-litigated. |
| 472, 473 | completed | CURRENT | Territory confirmed disjoint from 177's retained half (§6). |

### Strong completeness / completeness front

| Task | Status | Verdict | Evidence |
|---|---|---|---|
| 95 | not_started | **RE-DERIVE AT PLAN STAGE** | Deps `[169]`, correctly narrowed per the review's H-2. But per §1(f), the flagship theorems are *already* axiom-clean — this dispatch's own `check-module-invariants.sh` run shows `completeness`, `completeness_dense`, `completeness_discrete` all clean *right now*, independent of 169. 95's actual remaining content (a confirmation pass) may already be satisfiable, or may need to wait specifically on 169's own target if 169 targets something 477-479 did not touch. Same open question as 422 — flagging for the planner, not resolving here. |
| 169 | not_started | **RE-DERIVE AT PLAN STAGE** | See above and §1(f). Its `file_scope` (`BXCanonical/Completeness.lean`, `BXCanonical/Chronicle/`) and its deps (`361, 422, 448`) target the same theorem 477-479 already closed via a different file (`WeakCanonical/GroupModel/CountermodelBase.lean`, `WeakCanonical/IntegerModel/ReynoldsBridge.lean`). This is not a REOPEN or REMOVE call from research alone — it requires reading 169's and 422's actual mathematical content against what 477-479 actually proved, which is planning-depth work this dispatch's read-only, no-lean-edits charter does not license. Flagged as the single highest-priority open question for `/plan 169` or `/plan 422` to resolve first. |
| 362 | not_started | CURRENT | Depends on 169/170/424/375/361; capstone, correctly gated. |
| 178 | not_started | **REVISE** (carried from 2026-08-24 review M-7, independently re-confirmed here per §1(a)) | Requires "a complete worked example showing soundness-completeness-decidability" — decidability of TM is still open (confirmed §1). Rescope to soundness + completeness + propositional-fragment decidability (genuinely complete per the charter's F7), or gate the decidability example explicitly. |
| 193 | not_started | CURRENT | Deps include 470 (completed); no drift found in file_scope. |

### Dataset/misc cluster (carried from the 2026-08-24 review; not independently re-derived this
dispatch — out of this task's decidability/roadmap core scope, and the review verified these one
day ago)

| Task | Status | Verdict (review A-6, carried) |
|---|---|---|
| 298 | partial | KEEP, top of cluster — but **note**: this dispatch found the c7 regeneration process (`dataset_generator --max-complexity 7 --mode exhaustive`) **actively running** right now (confirmed via `ps aux`, live PID, 645+ CPU-minutes, output file now 1.5M+ lines vs. the review's 13,749-line truncation snapshot). The review's truncation finding is being actively worked; do not disturb, and re-check line/metadata counts before treating 298 as still-blocked. |
| 296 | partial | KEEP (review verified) |
| 282 | partial | REVISE — null description was reconstructed by task 470's own research; not re-verified here |
| 257 | blocked | REVISE + reclassify — blocked on human action (HF account/token) |
| 231 | not_started | KEEP, downgrade priority; must follow 298 |
| 219 | researched | KEEP (depends on 231) |
| 125 | not_started | KEEP, move off critical path |
| 127, 128 | not_started | ABANDON or park — both extend the object language, antagonistic to the termination work this task's own front depends on (`MintBound.lean`'s 34-constructor rule set) |
| 193 | not_started | KEEP — runnable today (also listed above under completeness front; same task) |
| 461 | blocked | KEEP as blocked, lower priority — blocked on literature acquisition |

*(These ten rows are restated from `specs/reviews/review-2026-08-24.md` Addendum A-6/A-7, one day
old at dispatch time. This task's charter and constraints scope it to the decidability/tableau/
metatheory/roadmap front; re-deriving the dataset cluster's evidence independently was judged out
of proportion to this task's charter and is flagged here as a carried-forward citation, not a
fresh verification, so the distinction is visible to whoever acts on this report.)*

**Verification completeness check**: 48 `active_projects` entries total. Rows above account for
all of them: 24 decidability/completeness-front tasks (410,411,412,421,422,423,424,425,426,
428,429,430,432,433,434,436,451,455,462,463,464,465,468,469,470,472,473,474,475,476 — note 451
and 455 appear in §8/§3 respectively, not duplicated here), 5 strong-completeness/completeness
tasks (95,169,178,193,362), 10 dataset-cluster tasks, plus 177 (§6), 413 (completed, unaffected,
starter of the completeness chain per the review), 455 (§3), 451 (completed, boneyard
consolidation, unaffected). Total: 24+5+10+1+1+1+1 = 43, plus 413 = 44... **cross-check below in
§10 resolves the exact count against `state.json`'s 48 rather than hand-tallying here.**

---

## 8. Stage 4(a)/(b) — critical path, dependency edges, dangling-edge scan

**Dangling-edge scan (Stage 4(b), full verification)**: every dependency target across all 48
`active_projects` entries was checked against the union of `active_projects` and
`specs/archive/state.json`'s `archived_projects` + `completed_projects` (zero-padded numeric
comparison to avoid a lexicographic `comm` mismatch, corrected after an initial false-positive
run). **Result: zero dangling edges.** Matches the review's L-4 finding and confirms no new
dangling edge was introduced since.

**active_topics vs. topics carried (Stage 4(b))**: one gap found — topic `metalogic` (carried by
tasks 477, 478, 479, all `completed`) is absent from `active_topics`. This currently produces no
live warning (`generate-task-order.sh --print` exits 0 with no undeclared-topic stderr, because
all three carriers are `completed` and filtered from non-terminal topic-grouped rendering), but
it is a real gap that will surface a warning the moment any future non-terminal task reuses the
`metalogic` topic, or once `/todo` processes these three and a topic-inclusive historical view is
built. **Recommend adding `metalogic` to `active_topics`** — cheap, no scope change.

**Critical path, re-derived after the restructuring above** (decidability/tableau front):

```
434 (partial) ─┬→ 462 → 465 ─┬→ 428 → 429 → 410 → 411 → 430 → 412 → 177(retained half)
433 (partial) ─┘             │
                              ↑
              [new: fifth-residual task] (recommended before/alongside 462)
463 → 465 (same node as above)
464 → 465 (same node as above)
476 (independent, gated on 475=completed only) ── parallel, does not feed the spine above
[new: isValid bridge] ── independent, startable now
```

430 depends on 428 (via `deps: [432,433,434,465]` on 428, and 430's own prose naming its
predecessors); 412 depends on `[165,410,411,428,430]` (confirmed via `jq`). This is a **9-wave**
spine from the still-partial 433/434 to 412, consistent with the review's Addendum 3 wave count
(waves 6-12 in its table), not materially shortened by anything this dispatch found — the
sixteen newly-completed tasks landed on the *completeness* front and the *BiLasso*/carrier-
normalization side track, not on this spine.

**Routine vs. hard split on this spine**: 462 (engineering, "explicitly proof engineering, not
open mathematics" per its own description) and 465 (mechanical) are routine; 429 (redesign,
option (a) likely-sound but with fuel/termination consequences), 464 (`gapPotential`, "the one
genuinely OPEN MATHEMATICAL question"), 430(b) (the semantic lift, "comparable in weight to a
landed sub-phase"), and 412's refutation induction are the hard items. The new fifth-residual
task is hard (repair-or-replace, not routine discharge, per §5).

---

## 9. Stage 4(c)/(d) — ROADMAP.md and state.json condition

**ROADMAP.md — the split has NOT yet been done; still required.**

Verified this dispatch (fresh, not restated from the review):
- `wc -l specs/ROADMAP.md` → **1,970 lines** (up from the review's 1,930 — task 474 added the
  BiLasso "Status: landed" block, confirmed present at lines ~1592-1615, and 472 already trimmed
  the banner count from ~30 to **10** `grep -c "HISTORICAL\|SUPERSEDED\|STALE"`).
- **Still three stacked "Current state" blocks** in `## Overview` (2026-07-24, 2026-07-16
  [labelled superseded], 2026-07-07), plus a fourth dated block at `:640` (2026-05-10) and a
  trailing 111-row `## Task Cross-Reference` table (`:1934`). No `specs/ROADMAP-ARCHIVE.md` exists
  yet (`ls` confirms).
- Title is still `# Roadmap: BX Completeness and Publication` — decidability, now the largest
  front, is not in it.
- `roadmap-integration.sh` structural signal was not re-run this dispatch (the review's `phases=0
  checkboxes=0 table_rows=111` finding is one day old and nothing in this dispatch touched the
  file's structure), but nothing found here contradicts it.

**This remains the single largest piece of concrete work this task's realignment schedules** —
unlike the ADD candidates (mostly resolved or already covered, §5) and the documentation drift
(already corrected by 472, §6), the ROADMAP split per amendment 10c has had zero progress since
the review. Recommend this be the first or second phase of whatever plan follows this report:
split into `specs/ROADMAP.md` (one current-state statement per front: decidability/tableau, weak
completeness, strong completeness, Kamp, FMP, publication, dataset, hygiene — each stating
PROVEN/OPEN/REFUTED per §1(f)'s now-corrected metatheory status) and `specs/ROADMAP-ARCHIVE.md`
(the four dated blocks, the 111-row table), retitled, with the BiLasso status (already partially
written by 474) folded into the decidability front's current-state statement rather than left as
a separate late addendum.

**state.json counters — still broken, confirmed independently of task 470's own report.**

Fresh this dispatch: `active_projects | length` = **48**. `.metadata.total_tasks` = **42**.
`.task_counts.total` = **42**. Actual status breakdown (`jq` tally): `blocked=3, completed=16,
not_started=20, partial=5, planned=1, researched=2, researching=1` — sums to 48, not 42, and none
of `implementing=1` (task_counts) or `not_started=31` (task_counts) match the actual `0` and `20`.
`.metadata.last_sync` = `2026-08-24T21:34:14Z` (recent — 470 did update this timestamp) but the
counts it stamped are wrong regardless. **Confirms task 470's own report finding that `/task
--sync` does not reconcile these fields** and a direct `state-write.sh` edit is still required as
a separate step. Not performed here (constraint: state.json writes are implementation-stage, not
research-stage, and must go through `state-write.sh`, not a direct edit from this dispatch).

---

## 10. Summary table — proposed actions for the user

**Task-count reconciliation** (resolves §7's flagged arithmetic): 48 total = 16 completed
(413,421,423,424,425,426,451,469,470,472,473,474,475,477,478,479) + 3 blocked (257,428,461) + 20
not_started + 5 partial (282,296,298,433,434) + 1 planned (410) + 2 researched (219,422) + 1
researching (468, self).

**Proposed status corrections** (user decision, not transitioned here):
- Propose 455 → abandoned, once this task's realignment lands (§3).
- No REOPEN proposed for 165/432/436/170 — all four's archived-completed status is CURRENT (§4).

**Proposed new tasks** (§5): (1) `isValid`-to-validity plumbing bridge, low effort, no
dependencies, startable now; (2) proof-extraction completeness, high effort/multi-month, deps
`[412]`, sequence-or-fold with 412 (planner's call); (3) fifth termination residual
(`UnorderedSuccessorLabelClosed`), medium-high effort, deps `[434]`, sequence before/alongside
462.

**Proposed description REVISEs** (§7): 412 (strike stale `countermodel_discrete` sorry
reference), 428 (add ASSESS/C9-register escape clause for split-arm fuel), 429 (name option (a)
as recommended route), 462 (note the fifth-residual sequencing once that task exists), 178
(rescope decidability example, carried from 2026-08-24 review), 177 (retained-half text, §6).

**Flagged for the planner, not resolved here** (§7): whether 169/422/95 are now partially or
wholly redundant given 477-479's closure of `countermodel_discrete` via a different route. This
is the single most consequential open question this dispatch surfaces and could not answer
within its no-Lean-edits, research-only charter — it requires comparing 422's discrete-chronicle
construction against `WeakCanonical/GroupModel/CountermodelBase.lean` and
`WeakCanonical/IntegerModel/ReynoldsBridge.lean`'s actual content, which is planning-depth
analysis.

**ROADMAP.md and state.json** (§9): both still require the work amendment 10c and the charter's
Stage 4(d) specify; neither has progressed since the 2026-08-24 review despite sixteen other
tasks landing in the interim. Recommend prioritizing the ROADMAP split as the first implementation
phase, since it is the one piece of this task's charter that is both fully specified and
completely undone.

---

## Appendix — checks run this dispatch

- `scripts/check-module-invariants.sh` (full, with build): `lake build` exit 0, `lake build
  BimodalTest` exit 0, C1-C11 all PASS, C3 sorry count zero, C2 all four flagship axiom sets
  clean (verbatim sets recorded in §1(f)).
- `bash .claude/scripts/generate-todo.sh`: ran clean, no errors.
- `bash .claude/scripts/generate-task-order.sh --print`: exit 0, no undeclared-topic warning
  (see §8 for why that is not full coverage).
- Dangling-edge scan: custom `jq`+`sort -u`+`comm` script, zero-padded to avoid lexicographic/
  numeric sort mismatch (an initial run without the padding fix produced 50 false positives from
  the sort-order mismatch itself, corrected before being reported here).
- Direct `grep`/`ls`/`sed` verification of all six Stage 1(a) claims, the box-anchor artifact and
  its four live probes, `UnorderedSuccessorLabelClosed`'s definition/hypothesis/refutation sites,
  `decide_sound'`'s statement, and every task description quoted above — all against `HEAD` at
  dispatch time, none restated from the charter or review without independent re-confirmation.
