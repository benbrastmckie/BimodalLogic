# Proof-State Audit and Realignment Charter: Task #468

**Task**: 468 - Programme realignment from a verified proof-state audit
**Started**: 2026-08-20T05:30:00Z
**Completed**: 2026-08-20T06:15:00Z
**Effort**: high (four parallel read-only audits; synthesis and charter)
**Dependencies**: None (task 455 depends on this task, not the reverse)
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/**` (decidability internals and tableau calculus)
- Codebase: `FormalSystem/Metalogic/**` excluding `Decidability/` (soundness/completeness metatheory)
- Codebase: `FormalSystem/Boneyard/**` (retired approaches and recorded refutations)
- `specs/ROADMAP.md`, `specs/TODO.md`, `specs/state.json`, `specs/archive/state.json`
- `specs/CHANGE_LOG.md`, `specs/events.jsonl`, `specs/reviews/review-2026-08-18.md`
- `scripts/check-module-invariants.sh` (checks C2/C3/C5/C6/C7) and its register files
- The C9 register inside `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`
- `specs/467_update_decidability_readme/reports/01_decidability-readme-alignment.md`
- Lean LSP re-elaboration of the flagship theorems, for actual axiom sets
**Artifacts**:
- This report: `specs/468_realign_task_programme_from_proof_state_audit/reports/01_proof-state-audit-and-realignment-charter.md`
**Standards**: report-format.md, subagent-return.md

**Method**: four parallel read-only audits verified against the Lean sources, not against
documentation. One audit re-elaborated the flagship theorems through the Lean LSP to read their
actual axiom sets; one stripped Lean block/line comments programmatically before counting `sorry`,
because doc prose in this repo mentions the word roughly ninety times.

---

## Executive Summary

Decidability of TM is **open**, and it is the furthest-from-done front in the project. The tableau
calculus is real, substantial, and `sorry`-free — and it is **neither proven sound nor proven
complete as a theorem**. It is proven terminating only under hypotheses, one of which is
*refutable as stated*. Adjacent to it, the soundness/completeness metatheory is nearly finished:
soundness is proven for all four frame classes, weak completeness for three of four, and exactly
one live structural `sorry` remains in the whole compiled tree.

The single most important finding is methodological, and it is why this task exists:

> **`sorry`-free is not the same as proven, and in this repository the difference is large.**
> `FormalSystem/Metalogic/Decidability/` contains zero live `sorry` and zero `axiom` declarations.
> What is missing there is (i) theorems that were never stated, (ii) conditional theorems whose
> hypotheses no caller can supply, and (iii) one subtree that does not exist on disk. None of
> those are visible to a `sorry` count, and the project's status reporting is built on `sorry`
> counts.

A secondary finding: the tracking artifacts currently **understate** remaining work. At least four
tasks are archived or marked `completed` over obligations that are demonstrably still open, and
`specs/ROADMAP.md` carries a section whose status claims are inverted relative to the archive.

Two credits, because they materially affect how much of this is trustworthy. First, the **in-source
prose is unusually honest** and generally drifts *pessimistic* — modules describe their own
obligations as open after they have been discharged more often than the reverse. Second, the
project maintains a **register of machine-refuted dead ends** (the C9 register, 24 entries, living
inside `Verified/Termination/MintBound.lean`) and retires its own vacuous theorems with written
post-mortems. That discipline is why this audit was possible at all. The drift is concentrated in
READMEs and the task tracker, not in the mathematics.

---

## Context & Scope

Commissioned after task 467 corrected `FormalSystem/Metalogic/Decidability/README.md`, which had
been carrying an unproved decidability overclaim. That single finding raised the question this
audit answers: how far does the drift extend, and what actually remains?

**In scope**: the honest proof state of the decidability tree and the tableau calculus; the
soundness/completeness metatheory outside `Decidability/`; the active backlog, dependency graph,
and roadmap.

**Out of scope**: proving anything, editing any `.lean` proof, or transitioning any task's status.

**Verification standing**: findings below were produced by read-only agents and are marked
`VERIFIED` (checked directly, with a citation), `REPORTED` (asserted by the audit, worth
re-confirming before large decisions), or `OPEN` (the audit could not settle it). Task 468's Stage 1
re-confirms the load-bearing `REPORTED` items before any restructuring is built on them.

---

## Findings

### F1. Decidability of TM is open — VERIFIED

No declaration anywhere takes `isValid` as its subject. What exists:

- `decide` (`DecisionProcedure.lean:170`), a five-stage cascade returning
  `valid / invalid / fuelExhausted / extractionFailed`; `isValid` at `:317`.
- `decide_sound` (`Correctness.lean:61`) is real but weaker than its name: it says `(⊢ φ) → ⊨ φ`,
  a restatement of `Metalogic.soundness`. It says nothing about `decide`'s search. `decide_sound'`
  takes the `decide … = .valid proof` hypothesis as `_h` and discards it.
- The remaining `Correctness.lean` theorems are `cases … <;> simp` facts about the result *type*.

`Correctness.lean:74-105` honestly records that `validity_decidable` and
`validity_has_decision_procedure` were **retired as vacuous** — they were `Classical.em` in
disguise. A second independent vacuity retirement sits at `FMP/FMP.lean:311`, where two prior
bounds concluded in `∧ True` discharged by `trivial`. Both retirements are correct and well
documented.

The completeness direction decomposes into three separate open obligations: `valid_iff_allClosed`
(named in prose at `Correctness.lean:100`, **does not exist as a declaration**), proof-extraction
completeness, and fuel adequacy.

### F2. Tableau soundness is half-proven — VERIFIED

The calculus is genuine: `TableauRule` with 34 constructors (`Tableau.lean:73`) over the **full TM
language**, labelled/prefixed signed formulas, four frame classes, lasso-aware subset blocking on
time *types*.

`ruleSound_of_mem_allRulesForFC` (`Verified/Decidable.lean:3129`) proves all 34 rules preserve
branch satisfiability. That is real work, sorry-free, each rule at its weakest carrier property.

**It is never lifted through the engine.** There is no `allClosed → valid`, no
`closed → unsatisfiable`, no `valid_iff_allClosed`. Additionally, two rules (`serialityRule`,
`timeLinearity`) are scheduled from stages 2/3 of `expandOnce`, *outside* `allRulesForFC`, and have
no `RuleSound` obligation discharged at the point they fire.

One caveat on the 34: `RuleSound` is `True` on inapplicable inputs
(`SatResult … | .notApplicable, _ => True`, `Verified/Decidable.lean:198`). Deliberate and
documented, but it means "34 rules sound" covers a mix of contentful and empty cases per rule.

### F3. Tableau completeness is blocked on an unsuppliable hypothesis — REPORTED, highest priority

`branchTruthAt` (`Verified/Bridge/IntTruth.lean:890`) is a genuine six-case signed truth-lemma
induction, sorry-free. Headline results exist at all four carriers — `not_valid_of_hasOpen_int`
(`IntTruth.lean:1035`), `not_validDiscrete_of_hasOpen_int` (`:1063`), and dense/Dedekind siblings
in `Bridge/DenseTruth.lean`.

Each carries five decidable branch gates: `branchOrderValid`, `timeOrderTotal`, `boxAnchoredCheck`,
`regionLabelCheck`, `temporalWitnessCheck`. **`boxAnchoredCheck` computes `false` on every
multi-world branch the engine actually builds** (`Bridge/BoxSaturation.lean:434`,
`Bridge/TruthLemma.lean:473`).

The causal history matters, because it constrains the repair. The engine *was* unsound —
cross-world temporal copying in `boxNeg`/`diamondPos` closed the invalid `(G p) → □(G p)`. This was
found by executable probes, and six offending blocks were deleted. That repair removed the only
route by which `T(Gφ)`/`T(Hφ)` reach a freshly minted world, which is exactly what the anchor
hypothesis needed. So the theorems typecheck, are true as conditionals, and **no caller can use
them on any branch with more than one world**.

`BoxSaturation.lean:521-538` is candid that `timeOrderTotal` "is *not* proved invariant under
expansion anywhere in this development" and that `BoxAnchored` "has exactly the same character".
The audit found no theorem, `#guard`, or `#eval` exhibiting all five gates simultaneously true on
an engine-produced branch.

**This is the single highest-information open question in the project**, and it is cheap to settle
by execution. It decides whether task 429 is a repair or a redesign. Task 468 Stage 1b.

### F4. Termination: the named target is refuted, not merely unproven — VERIFIED

`Fuel.lean:1417` states outright that the plan's named deliverable `buildTableau_isSome` at
`soundFuel'` is **false as stated**: `expandBranchWithFuel` returns `none` once `branchesUsed`
reaches `maxBranches := 50000`, at *any* fuel.

The surviving terminus, `buildTableauAt_isSome_of_budget`
(`Verified/Termination/MintBound.lean:5274`), carries four undischarged residuals: `UniverseClosed`,
`DifficultyBounded` (or `StepLengthBounded`), `MintPaysForTime`, `PostBlockingSettles`. Of these,
`DifficultyBounded` is recorded at `MintBound.lean:5316` as **refutable at every `D`** on any
universe the engine fires on — making that sibling a true conditional with an unsatisfiable
antecedent. `StepLengthBounded` is the non-vacuous repair, still with three residuals.

Separately, `expandBranchWithFuel_isSome_of_noSplit` (`Fuel.lean:1462`) is conditional on a
`NoSplit` invariant whose **only exhibited witness is the empty branch** (`noSplit_nil`, `:1534`) —
the engine reports `saturated` on `[]` because all three pick stages scan the branch and find
nothing. The file flags this itself under a "Non-vacuity" heading. So the conditional termination
theorem is, in practice, termination for the empty branch.

The split arms are the real obstruction, and `Fuel.lean:1567-1583` says why:
`allocateFuelProportionally` gives each arm ≈ `fuel / k`, so fuel adequate for a split run scales
like `β ^ depth`, and `depth` is bounded by nothing proved. The file's own assessment is that this
is "a real property of a deliberate engine policy, not a gap in a proof."

### F5. A whole subtree does not exist — VERIFIED

`FormalSystem/Metalogic/Decidability/Verified/Refutation/` is **zero files**. This is the
`allClosed → Derivable` refutation induction — the content of the missing `valid_iff_allClosed`, and
the largest single missing piece of the decidability programme. `Verified/README.md` lists it as
"planned" in the same register it uses for eight files that already exist and compile, so a reader
cannot distinguish the two meanings.

`ProofExtraction.lean` contains **zero theorems**, only `def`s. `verifyProof` is
`def verifyProof (_phi) (_proof) : Bool := true` (`:345`) — honestly commented, misleadingly named.
Nothing rules out `.extractionFailed`, so even a closed tableau does not currently yield
`isValid = true`.

### F6. FMP is syntactic, not semantic — VERIFIED

`fmp_completeness` (`Correctness.lean:181`) is completeness of the *Hilbert system* via
MCS-membership → derivability. It is **not** `⊨ φ → ⊢ φ`, and it is wired to nothing tableau-side.

`FMP/README.md` is honest that the directory contains **zero** occurrences of `TruthAt`, and that a
truth lemma of the form `TruthAt M τ t ψ ↔ ψ ∈ (τ.states t _).carrier` is **false** on
`RefinedFilteredTaskFrame`, because its task relation is permissive (universal at nonzero
duration) — `someFuture χ` separates the sides. A genuine semantic FMP requires a non-permissive
filtered relation with all four `def:frame` axioms re-discharged, and the permissive route is
precisely what currently delivers Spherical/Limit.

`FMP/README.md` also lists two "Key Results" — `filtration_is_finite` and
`truth_preserved_under_filtration` — that **do not exist as declarations**.

### F7. The metatheory is nearly done — VERIFIED via LSP axiom inspection

| Result | State |
|---|---|
| `soundness`, `soundness_dense`, `soundness_discrete`, `soundness_dedekind` | **Proven**, `[propext, Classical.choice, Quot.sound]` |
| `completeness_discrete`, `completeness_dense`, `completeness_dedekind` | **Proven**, axiom-clean |
| `completeness` (Base) | **Partial** — `[propext, sorryAx, Classical.choice, Quot.sound]` |
| Strong completeness, Discrete / Dedekind | **Refuted** (non-compact); correctly never attempted |
| Strong completeness, Base / Dense | **Open research question**, not engineering |
| `kampPriorExpressiveCompleteness` | Landed sorry-free, but at **arity `n ≤ 1`** (`KampPrior.lean:363`) |
| Propositional fragment | **Genuinely complete** — real `Decidable (⊢ p)`, both directions, kernel `decide` |

The Base failure is localized to a single bare `sorry` at `WeakCanonical/Transfer.lean:1084`
(`countermodel_discrete`) — **the only live structural sorry in the compiled tree**. The cause is
real, not clerical: a Base-MCS is not automatically Discrete-consistent, and the old transfer route
is *refuted* by a ℤ+ℤ counterexample, so this needs new mathematics.

Anti-vacuity for soundness is genuinely discharged: `Independence/ClockFrame.lean:173` constructs a
real `TaskFrame ℚ` with all four frame axioms and an inhabited total history, so the `τ.IsTotal`
binder is not empty.

`StrongCompleteness.lean` is misleadingly *named* but scrupulously honest inside: it proves
**finite-context** consequence completeness (`Γ : Context = List Formula`), states three times that
this is not `Γ : Set Formula` strong completeness, and includes the matching soundness direction
deliberately as a guard against a vacuous target.

### F8. One live vacuous lemma, still consumed — VERIFIED

`neg_2var_vec_ea` (`Kamp/EANegationClosure.lean:722`) has a conclusion that
`Kamp/Prop42Vacuity.lean:99` proves **from no hypotheses at all** (all-⊤ witness). Its hypotheses
are inert; it is not Rabinovich Prop 4.2. It is still live-consumed and re-exported verbatim by
`reflatten_neg_step` (`NfMultiAnchorBridge/NavigatedSpine.lean:178`). The file records that it was
mis-adopted as a proved asset at least twice.

**Qualification**: because the flagship theorems have contentful statements and clean
kernel-checked proofs, a vacuous lemma in the cone cannot corrupt them. The hazard is that
intermediate Kamp deliverables get cited in prose as done when they say nothing. The contentful
biconditional shape is already written down at `Prop42Vacuity.lean:47-52`.

### F9. The tracking understates remaining work — VERIFIED

- **165** archived `completed` — its own summary says Track A decidability is delivered only "up to
  the CONDITIONAL truth-lemma results", and its four obstructions O1–O4 are live as tasks
  428/429/430. A completed umbrella over unfinished work.
- **432** `completed` — summary states the reduction "is **not a discharge**" and the residual
  "correctly stays on the terminus."
- **436** `completed` — left the density coordinate open; it is now task 464, described elsewhere as
  "the one genuinely OPEN MATHEMATICAL question remaining on the totality terminus."
- **170** archived `completed` — its only remaining action was an independent clean-build
  re-verification, and its summary says the task directed that no implementation agent run. The
  ROADMAP claim that Dense weak completeness is "substantively closed" is explicitly conditioned on
  that re-verification.
- **ROADMAP Paper Alignment section** lists 414, 415, 417, 419, 420, 427 as not-started/blocked;
  all six were archived completed between 2026-08-13 and 2026-08-18. The section carries no stale
  banner, unlike two other sections that do.
- **`specs/state.json` counters disagree with themselves**: `metadata.total_tasks: 29` vs
  `task_counts.total: 44` vs 45 actual entries; `metadata.last_sync` is two months stale.
- **Task 177's `file_scope`** names `ROADMAP.md`, which does not resolve — the file is
  `specs/ROADMAP.md` — and duplicates `FormalSystem/`.
- **Task 455** — the project's own acknowledgement of all this ("bring specs/ROADMAP.md and every
  remaining active task into agreement with the progress actually made") — is filed and never
  started.

### F10. Documentation drift is actively misleading — VERIFIED

Beyond the `Decidability/README.md` overclaim that task 467 fixed:

- `Decidability.lean`'s "## Status: Soundness: Proven / Completeness: Proven" block reads as
  tableau soundness and completeness. It is neither; it refers to the Hilbert-system results. This
  is the one place the audit found a genuine overclaim in module prose.
- `Verified/README.md` marks eight existing, compiling, imported files as "planned", omits eleven
  files, and registers the genuinely-absent Refutation subtree the same way.
- `FMP/README.md` lists two non-existent declarations as Key Results (F6).
- `DecisionProcedure.lean:331` claims blocking "ensures termination for all formulas". No theorem
  supports this, and `decideAuto` runs at a figure *below* the already-insufficient `soundFuel'`.
- `Verified/Decidable.lean:79-101` still describes the fresh-time producers as blocked; they are
  proved at `:1817`–`:2044`.
- Stale-pessimistic drift elsewhere: `WeakCanonical.lean:83-95` lists five sorries that no longer
  exist; `RealModel/ShuffleReal.lean:42` calls a lemma a "documented strategic sorry" that is proved
  at `:208`; `Soundness.lean:75` cites an IRR rule and an `IRRSoundness.lean` that do not exist.

### F11. Test suite state — REPORTED

`Tests/BimodalTest/TableauConformance.lean` carries **2 live `[DEFECT]` rows** — `F p → F F p` open
at `.Dense` and `.Dedekind`, i.e. density not delivered. `specs/TODO.md:517` notes `#guard_msgs`
drift in `RegionGateProbe`, `TableauConformance`, and `BoxSpreadProbe`. Task 453 (archived
2026-08-18) reports having returned `lake build BimodalTest` to exit 0; the two `[DEFECT]` rows are
a separate, standing matter. Re-confirm current build state before scheduling on it.

---

## Decisions

**D1. Task 455 is not duplicated, and not deleted unassessed.** It predates this audit and is
backward-looking (description-rot sweep); task 468 is forward-looking (programme design). Both write
`specs/ROADMAP.md`. Resolution: **455 now carries `dependencies: [468]`**, so it cannot run first,
and 468's Stage 0 adjudicates it — ABSORB, NARROW, or RETAIN — with reasoning recorded. Chosen over
absorbing it outright because 455 is a carefully written spec that deserves assessment rather than
pre-emptive deletion.

**D2. No new documentation task is created.** Task 177 already covers "update all documentation",
including README.md, module-level docstrings, ROADMAP.md, and the Axiom Reference. Creating a
second would duplicate it. **177 is instead scheduled for DIVISION**, because it is gated behind
thirteen dependencies including the entire decidability chain — deferring every correction in F10
behind multi-year work — while that drift misleads readers now. The proposed split: an immediate
ungated correction pass for the false and stale claims, modelled on task 467; and the remainder
retained as the final post-refactor polish under its existing gating.

**D3. Task status remains the user's decision.** 468 may create new tasks and edit descriptions,
dependencies, `file_scope`, and ROADMAP.md. It may **not** transition any existing task to
completed, abandoned, or expanded. The F9 corrections are therefore *proposals* in its report.

**D4. `topic: decidability`, `task_type: meta`, `file_scope: ["specs/ROADMAP.md"]`.** Topic chosen
because the decidability programme is the primary subject and the largest active cluster.
`file_scope` is deliberately narrow — `specs/state.json` and `specs/TODO.md` are touched by every
task through scripts and are not meaningfully owned by any one.

**D5. Findings are re-verified before being built upon.** The load-bearing `REPORTED` items are
re-confirmed in 468's Stage 1 against symbol names rather than line numbers, because line-number rot
is the observed failure mode across this backlog.

---

## Recommendations

### R1. Settle the box-anchor question first (hours, highest information)

Determine by execution whether all five branch gates can hold simultaneously on an
engine-produced saturated open branch. No proof required — `#eval` / `#guard`. This decides whether
task 429 is a repair or a redesign, and whether the tableau completeness half is vacuous or merely
unassembled. A negative result is as valuable as a positive one. **Nothing else in the decidability
programme should be scheduled before this is known.**

### R2. Close the cheap, currently-unstated results (days)

- `isValid φ fc = true → ⊨ φ` — invert `.isValid`, apply `decide_sound`. Pure plumbing, unstated.
- Discharge `RuleSound` for `serialityRule` and `timeLinearity` at their firing site. Mechanical
  relative to the 34 already done.
- Correct the F10 documentation claims (the divided half of 177).

### R3. Lift rule soundness through the engine (weeks)

`expandOnceUnblocked` → `expandBranchWithFuel` → `buildTableau`, yielding the real theorem
`allClosed → valid`. An induction over a landed, sorry-free base; the obstacle is a "some successor
stays satisfiable" invariant at the branching arm. Establish whether this sits inside existing task
430 or is a distinct predecessor, and wire accordingly.

### R4. Schedule the genuinely hard items honestly (months each)

The refutation induction (`Verified/Refutation/`, zero files); proof-extraction completeness; a
semantic FMP; the Base-MCS discrete countermodel; `gapPotential`. Each is plausibly multi-month.
**No task may hide one of these behind an engineering description.** Split-arm fuel adequacy may be
unclosable without an engine change — if so it needs a C9 register entry and a re-scoped task, not
another attempt.

### R5. Rewrite ROADMAP.md around the PROVEN / SORRY-FREE distinction

That conflation is the specific failure this whole exercise corrects. Per front, state what is
proven, what is open, what is refuted, and what the terminus looks like. Ground every status claim
in something `scripts/check-module-invariants.sh` can reproduce, and name the check. Give refuted
routes explicit tombstones, cross-referencing the C9 register rather than duplicating it.

### R6. Repair or retire `neg_2var_vec_ea`

Not urgent — it cannot corrupt the flagship theorems — but it is cited in prose as a landed Kamp
deliverable, and the contentful replacement shape is already written down.

### R7. Expect the honest total to be large

Full decidability with a sound and complete tableau system is realistically **several person-years
of formalization**, containing at least three separate multi-month research problems. Base weak
completeness — one hard lemma — is the nearest genuine milestone. Any plan implying otherwise
should be treated as evidence of the drift this report documents.
