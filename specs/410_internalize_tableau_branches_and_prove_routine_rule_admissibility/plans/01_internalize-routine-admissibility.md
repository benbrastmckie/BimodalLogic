# Implementation Plan: Branch Internalization and Routine Rule Admissibility

- **Task**: 410 - Internalize tableau branches and prove routine rule admissibility (Track B part 1)
- **Status**: [NOT STARTED]
- **Effort**: 30 hours (8 phases, 14 sub-phases)
- **Dependencies**: None blocking. Consumes the existing `FormalSystem/Metalogic/Decidability/` tree (engine + `Verified/RuleSpec.lean` gates) read-only.
- **Research Inputs**: `reports/01_internalize-routine-admissibility.md` (Tier 3, implementation-backed; H4-verified with a §9 Claim Verification Table)
- **Artifacts**: plans/01_internalize-routine-admissibility.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4

## Overview

Define `Branch.internalize` — a function turning a labelled tableau branch plus its `TimeOrdering`
into a single TM object-language formula — and prove the 21 routine per-rule admissibility lemmas
that this task owns. The internalization is **time-major with a flat `◇` per non-root world at each
time node**, which is forced rather than chosen (research §3.3, §3.4). The 21 lemmas are the
`.Base`-class rules whose emitted content either stays inside one `Branch.cell`, crosses worlds at a
fixed time, or travels along the `futureOf`/`pastOf` order inside one world. Done when
`Branch.internalize` exists with its root anchor, the four pieces of shared infrastructure exist, all
21 lemmas are sorry-free, and `lake build` is green with no new sorries anywhere in the tree.

The single most consequential source fact shaping the whole plan: **`expandOnce` never removes the
source formula.** `.linear`, `.branching`, and `.persistent` all build children as `delta ++ b`
(`Tableau.lean:2189-2197`); "consumable" is enforced by the `isExpanded`/`AppliedSet` guard, not by
branch subtraction. Every child in this task's scope is therefore a superset of its parent, so
`rule_admissible` collapses to a **positive-position strengthening** obligation, and the
positive-context monotonicity engine (Phase 3) is the highest-leverage item in the task.

### Research Integration

| Report | Integrated | What the plan takes from it |
|---|---|---|
| `reports/01_internalize-routine-admissibility.md` | v1, 2026-07-29 | Verified 34-rule inventory (§1); the 21/13/2 territory split (§1.2, §2); the `internalize` definition (§3.2); time-major forcing argument (§3.4); forest invariant and its one promotion (§3.5); root anchor (§3.7); five corrections to the `rule_admissible` shape (§4); the four infrastructure pieces (§5.1-§5.5); the Barcan route (§5.4); the H3 rule-to-asset mapping (§7); risks R1-R6 (§8) |

### Preserved Assets

No prior 410 implementation exists — `grep -rn "internalize\|rule_admissible"` over the tree returns
only unrelated docstring prose (research §9). The table below records the **upstream** assets this
task consumes and must not regress.

| Component | File | Status | Verified |
|---|---|---|---|
| Rule/axiom frame-class gates (GATE 1-3, 34/34 rule-soundness ledger) | `FormalSystem/Metalogic/Decidability/Verified/RuleSpec.lean` | [COMPLETED] | 2026-07-29 (read-only for this task) |
| Tableau engine: `TableauRule`, `applyRule`, `expandOnce`, rule lists, `mem_boxDiamondPersistence_{,label,shape}` | `FormalSystem/Metalogic/Decidability/Tableau.lean` | [COMPLETED] | 2026-07-29 (read-only for this task) |
| `Label`/`Branch`/`TimeOrdering` API | `FormalSystem/Metalogic/Decidability/SignedFormula.lean` | [COMPLETED] | 2026-07-29 (read-only) |
| Object-language asset library (`Combinators`, `ModalS5`, `TemporalDerived`, `GeneralizedNecessitation`, `Perpetuity/*`) | `FormalSystem/Theorems/**` | [COMPLETED] | 2026-07-29 (read-only) |
| Existing `Verified/` subtrees (`Bridge/`, `Termination/`, `Decidable.lean`) | `FormalSystem/Metalogic/Decidability/Verified/**` | [COMPLETED] | 2026-07-29 (read-only) |
| Baseline sorry count in the Decidability tree: **6** (`Propositional/Decidable.lean` 1, `Correctness.lean` 1, `Verified/Termination/TimeTypeBound.lean` 1, `Verified/Bridge/IntTruth.lean` 3) | — | measured | 2026-07-29 |

**Regression gate**: the baseline sorry count of 6 must not increase. Any new `sorry` in a
pre-existing file is a regression, not a deferral.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the research report's corrections,
risk table, and the settled constraints in the planning brief. No prior implementation attempt on
this task exists; every rule below traces to a verified source fact or a settled design decision.

**Do NOT**:

- **Do not realize world labels by `□`/`◇` nesting.** The task's own charter text says "world labels
  via box/diamond nesting"; that text is **corrected** by research §3.3. `TruthAt`'s `box` clause
  quantifies over `Omega` with no accessibility relation and at the *same* time index, so worlds form
  a flat set at each instant and `◇◇A ↔ ◇A`. One `◇` per non-root known world per time node is
  exactly as strong as any nesting.
- **Do not build a world-major internalization** (one `◇` per world containing that world's whole
  time tree). It makes `boxPos` unprovable: using a `□ψ` buried under `F` would need
  `F(□ψ) → □ψ`, which is false (research §3.4). Time-major is forced.
- **Do not use report 02's `rule_admissible` shape** (`∀ children ∈ applyRule r sf b ord, ...`). It
  does not typecheck: `applyRule` returns `RuleResult × TimeOrdering` (`Tableau.lean:630-631`) and
  `RuleResult` has five constructors (:205-230). Use the corrected shape in research §4.
- **Do not drop the returned `TimeOrdering`.** The child must be internalized against `ord'`, not
  `ord`. Omitting it states a *false* theorem for the four fresh-time rules (15, 17, 18, 20).
- **Do not write admissibility for `serialityRule` or `timeLinearity`.** They are provably outside
  `allRulesForFC` (`RuleSpec.lean:337, 342`) and are owned elsewhere. Do not add a
  `.branchingOrdered` arm beyond the vacuous `True` placeholder — `.branchingOrdered` is the only
  replacement-branch constructor and its identification arm removes a time from `Branch.knownTimes`,
  which no formula-delta can express.
- **Do not write admissibility for rules 22-34** (`untlPos`, `untlNeg`, `sncePos`, `snceNeg`,
  `orderTrichotomy`, `denseIndicatorClosure`, `densityRule`, `priorUZ`, `priorSZ`, `z1Rule`,
  `priorUGap`, `priorSGap`, `sepRule`). These are 411's 13. `priorUZ`/`priorSZ` in particular are
  **not** re-absorbed despite report 02 rating them "routine" — see research §2.2 and the SETTLED
  list below.
- **Do not target the retired PASSIVE arms of `untlNeg`/`snceNeg`.** They are deleted
  (`Tableau.lean:1017-1062` is the tombstone), and `sat_untl_neg` / `sat_snce_neg` are gone from the
  whole tree (verified by negative grep). Nothing in this task touches those two rules at all.
- **Do not scope anything against `buildTableau_isSome`.** That theorem is FALSE (`buildTableau`
  returns `none` above `maxBranches := 50000` at any fuel); a budget-parameterised replacement is
  owned by another task. This task's deliverables never mention `buildTableau`, fuel, or
  termination.
- **Do not introduce cut, or a uniform-substitution admissibility lemma.** Neither exists in this
  tree and neither is being added. The design is internalization, not substitution.
- **Do not `sorry` the Barcan step, and do not silently drop the cross-world `gProps`/`fNegProps`
  sub-case.** If Phase 2.3 exhausts both routes, follow the R1 escalation protocol in
  Risks & Mitigations — a named boundary hand-off, not a sorry and not a lossy emission set.
- **Do not edit `Tableau.lean`.** If a fourth `mem_boxDiamondPersistence_*` lemma turns out to be
  needed (research R5), raise it as a blocker rather than working around it or duplicating the
  `private def`.
- **Do not edit `FormalSystem/Theorems/Perpetuity/Principles.lean`** to hoist the inline
  `future_comp` step out of `persistence`. Re-prove `◇φ → G(◇φ)` locally in this task's own file
  (Phase 2.2). Promoting it into `Theorems/` is a separate concern outside this territory.
- **Do not write `⊢![fc] p` for `Derivable`.** The actual notation is ASCII: `G |-![fc] p` /
  `|-![fc] p` (`Derivable.lean:77, 82`). `DerivationTree` is the one that uses `⊢[fc] φ`
  (`Derivation.lean:315, 320`). The research report's §7 mixes these; the source is authoritative.
- **Do not reorder or remove lines in `FormalSystem/Metalogic/Decidability.lean`'s import block.**
  Append-only, one line per new module, at the end of the `Verified.` group. Two adjacent tasks are
  appending to that same block.
- **Do not cite task numbers in any `.lean` file.** `.claude/rules/no-task-references-in-deliverables.md`
  scopes task-number citations to `specs/**` and commit messages only. Reference durable anchors
  (module names, theorem names, section headings) in docstrings instead.
- **Do not use `git add -A` or `git commit -am`.** Stage the task directory, the plan path, and the
  files this task actually modified.

**MUST preserve**:

- Every currently-green declaration in `FormalSystem/Metalogic/Decidability/`. The baseline sorry
  count is **6** across four files (see Preserved Assets); it must not increase.
- `Verified/RuleSpec.lean` and its three GATE theorems, untouched.
- `Decidability.lean`'s existing 33 import lines, unmodified and in order.
- Every phase leaves `lake build FormalSystem.Metalogic.Decidability` green. Phases that add an
  import line additionally leave `lake build` green.

**Design decisions are SETTLED** (do not re-open without a concrete Lean-level counterexample):

1. **Internalization, not substitution.** There is no cut and no uniform-substitution admissibility
   in this tree, and none is being added.
2. **Time-major skeleton, flat `◇` inner layer.** Forced by `boxPos` (research §3.4). Rejected
   alternative: world-major, which requires the false `F(□ψ) → □ψ`.
3. **World 0 is privileged as the actual history** — its cell is asserted flatly, not under `◇`.
   Without this, `internalize` of the initial branch is `◇(¬φ)` and the root anchor fails.
4. **World identity across times is deliberately not preserved.** `slice t` and `slice t'` each emit
   their own `◇(cell w ·)`, so `internalize` is *weaker* than the branch. That direction is safe:
   the obligation needs a weaker consequent, which is easier. This is what keeps `boxNeg`/
   `diamondPos` routine.
5. **`Branch.cell` is keyed on the full `Label` (world AND time), never on time alone.** This is
   what makes `z1Rule`'s same-label two-premise requirement hold by construction (research §3.6) —
   both premises land in the same `conjOf`. A time-only grouping would break it for 411.
6. **The `U`/`S` guard slot is present from day one, in per-edge function form:**
   `guard : TimeIndex → TimeIndex → Formula`, with `Branch.internalize` instantiating it at
   `fun _ _ => Formula.top`. Writing edges as `untl _ ⊤` / `snce _ ⊤` **is** writing `F`/`P`
   definitionally (`Formula.lean:131, 141`), so the slot costs nothing now. The function form (over
   the report's plain `Formula`) is the R2 recommendation, taken because 411's needs are not yet
   known and retrofitting the parameter later would force 411 to reprove this task's tree-touching
   lemmas.
7. **411 owns `priorUZ`/`priorSZ`** despite report 02 rating them "routine". File ownership is the
   territory contract, and both independent counts for this task come to 21 without them (research
   §2.2, contradiction C1). They are 411's two *cheapest* lemmas, not hard ones.
8. **The `rule_admissible` harness lives in `Verified/Internalize.lean`**, not in
   `Verified/Refutation/Core.lean`. `Core.lean` belongs to the downstream consumer task; duplicating
   the harness there would be a collision.
9. **Object-language assets live in a task-owned `Verified/Refutation/Rules/TemporalAssets.lean`**,
   not in `FormalSystem/Theorems/`. This keeps `fConjG`/`pConjH`/the Barcan lemma inside this
   task's territory while remaining importable by 411.
10. **The forest invariant is an explicit hypothesis, not an approximation and not a `sorry`.** This
    task proves the invariant's preservation for its own 21 rules and names the two rules that break
    it (`densityRule`, `timeLinearity`) as the residual obligation of their owners.

## Goals & Non-Goals

- **Goals**:
  - `FormalSystem/Metalogic/Decidability/Verified/Internalize.lean`: `SignedFormula.content`,
    `conjOf`, `Branch.cell`, `Branch.slice`, `Branch.timeTree`, `Branch.internalizeWith`,
    `Branch.internalize`, and `internalize_initial` (the root anchor a downstream task consumes).
  - The positive-context monotonicity engine (`internalize_mono` family).
  - `TimeOrdering.IsForestAt` plus the freshness-conditioned preservation lemmas.
  - The `rule_admissible` statement shape and the generic contraposition bridge.
  - All 21 routine admissibility lemmas: 8 propositional, 4 S5 modal, `boxTemporal`, 8 temporal
    universal/existential.
  - Two new object-language assets not currently in the tree: `fConjG`/`pConjH` (§5.2) and
    `barcanDiamondG : ⊢ ◇(Gχ) → G(◇χ)` (§5.4).
- **Non-Goals**:
  - The 13 lemmas for rules 22-34 (411's, in `Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean`).
  - `serialityRule` / `timeLinearity` admissibility, and any non-vacuous `.branchingOrdered` arm (430's).
  - `allClosed_derivable` and `Decidable (Derivable fc [] φ)` (412's, in `Refutation/Core.lean`,
    `Verified/Provable.lean`).
  - Any budget-parameterised replacement for the refuted `buildTableau_isSome` (428's).
  - The non-forest realization machinery (`enrichment_until`-based back-edges). This task leaves the
    guard slot open and writes no proof using it.
  - Any new literature transcription. Grounding is Tier 3 (implementation-backed): the Burgess/
    Reynolds axioms are already in `ProofSystem/Axioms.lean` with per-constructor provenance
    docstrings, and this task works against those transcriptions. No chunk read is required.

## Territory Contract

Two adjacent tasks (411 on the hard rule lemmas, 430 on the two out-of-list rules) work in the same
subtree. Ownership is by file.

| Ownership | Paths | Rule |
|---|---|---|
| **Exclusive to this task (new)** | `Verified/Internalize.lean`; `Verified/Refutation/Rules/TemporalAssets.lean`; `Verified/Refutation/Rules/Propositional.lean`; `Verified/Refutation/Rules/Modal.lean`; `Verified/Refutation/Rules/Temporal.lean` | Created and owned here. No other task writes them. |
| **Pre-authorized overflow** | `Verified/Internalize/*.lean` | If `Internalize.lean` exceeds ~900 lines, the implementer MAY split the monotonicity engine into `Verified/Internalize/Mono.lean`. No other task claims anything under `Verified/Internalize/`. Note the split in the phase's commit message. |
| **Shared, append-only** | `FormalSystem/Metalogic/Decidability.lean` | Append one `import` line per new module at the end of the `Verified.` group. Never reorder, never remove. If a concurrent append is observed, re-add only this task's own line. |
| **Read-only (do not edit)** | `Tableau.lean`, `SignedFormula.lean`, `Verified/RuleSpec.lean`, `Verified/Decidable.lean`, `FormalSystem/Theorems/**`, `FormalSystem/ProofSystem/**` | Consume by import. A needed addition here is a blocker to raise, not an edit to make. |
| **Other tasks' territory (boundary notes only)** | `Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean` (411); `Verified/Refutation/Core.lean`, `Verified/Provable.lean` (412) | Not created, not touched. If a phase finds it *would* need one of these, record a boundary note in the summary and stop — do not absorb. |

**Build targets** (a new module is only compiled once it is reachable from `FormalSystem.lean`, so
the import line is part of the phase that creates the file):

| Target | Command |
|---|---|
| Single module | `lake build FormalSystem.Metalogic.Decidability.Verified.Internalize` (etc.) |
| Subtree aggregate — **the per-phase gate** | `lake build FormalSystem.Metalogic.Decidability` |
| Full — the phase-close and task-close gate | `lake build` |

## Risks & Mitigations

- **R1 — The Barcan dualization (§5.4) costs more than its phase.** Likelihood: Medium. This is the
  one genuinely hard step inside the 21. Mitigation: Phase 2.3 is **front-loaded into Wave 1** so the
  risk surfaces before 17 downstream lemmas are written, and it declares a two-route attempt budget
  (Route B via `persistence` + contraposed `modal_future` first because it is shorter; Route A via
  the `perpetuity6` chain second). **Escalation protocol on exhaustion of both routes**: record a
  boundary note naming rules 15/17/18/20 and *only* their cross-world `gProps`/`fNegProps` sub-case
  as a hand-off to 411 (which already owns the `Until`/`Since` block where the same commutations
  recur), leave Phase 8 at `[BLOCKED]`, and complete Phases 3-7 in full. Do NOT `sorry` it, and do
  NOT drop the cross-world case from the emitted set.
- **R2 — The guard parameter's arity.** Likelihood: Medium-low, and pre-mitigated. Settled decision 6
  takes the per-edge function form now; at `fun _ _ => Formula.top` it is definitionally the same
  formula, so it costs nothing and cannot need retrofitting.
- **R3 — 411 instantiates `guard` at a non-`⊤` value and these 21 lemmas do not transfer.**
  Likelihood: Medium. Mitigation: Phases 5 and 6 (13 of the 21) never touch a tree edge and are
  guard-agnostic outright. Phases 7 and 8 state their lemmas generically in `guard` wherever the
  proof permits; where it does not, this is 411's cost and the phase records which lemmas are
  `⊤`-specific so 411 is told rather than surprised.
- **R4 — The forest hypothesis propagates into 412 as an unproved side condition.** Likelihood:
  Medium, and accepted by design. Mitigation: Phase 4.1 proves the freshness-conditioned
  preservation lemmas and Phase 8 discharges the four instances, so the residual obligation is
  *exactly* `densityRule` (411) and `timeLinearity` (430). Both are named in the research report and
  in Phase 4.1's docstring, so neither owner can lose it.
- **R5 — `boxDiamondPersistence` is `private` and a fourth public lemma is needed.** Likelihood: Low.
  The three existing `mem_*` lemmas are universally quantified over membership, which is the
  direction admissibility needs (§5.5). Mitigation: if a fourth is needed it is a one-line
  `Prop`-valued additive lemma in a read-only file — raise as a blocker, do not work around.
- **R6 — `directFutureOf`/`directPastOf` do not deduplicate.** Likelihood: Low, newly identified
  (not in the research report). Both are `constraints.filterMap`, so a duplicated constraint would
  emit a duplicated tree edge. `addFuture`/`addPast` prepend unconditionally, and `nextTime` is
  always strictly fresh, so duplicates cannot arise within this task's 21 — but the invariant must
  say so. Mitigation: `IsForestAt` (Phase 4.1) includes a `constraints.Nodup`-style clause, and
  `nextTime` freshness is the hypothesis that discharges it.
- **R7 — `Rules/Propositional.lean` overlap confusion.** Not a risk; recorded to pre-empt it.
  `impPos`/`impNeg` match `.imp` directly and therefore overlap `negPos`/`negNeg`/`andPos` on the
  same formula. Each admissibility lemma is stated per rule and is independently true; overlap
  affects only engine priority, not admissibility.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5, 6, 7 | 2, 3, 4 |
| 5 | 8 | 2, 4, 6, 7 |

Phases within the same wave own disjoint files and may be dispatched in parallel. **Sub-phases
`N.M` within a phase are strictly sequential** — they extend the same file, and concurrent writes to
one file violate the territory contract. Phase 4 is blocked by Phase 3 for file-serialization only
(both extend `Internalize.lean`), not for any logical dependency.

**Why sub-phases are `####`, not `###`.** The eight `### Phase N:` headings are the dispatch units —
one agent run each, 200-450 lines of output, inside H8's budget. Sub-phases are the green-commit
substeps *within* one run (`Commit Mode: per-substep`), i.e. `progress-file.md` objectives, so they
are deliberately nested at `####` and are **not** counted by the phase-accounting regex
`^### Phase [0-9]+(\.[0-9]+)?:.*\[[A-Z][A-Z ]*\]$`. Promoting them to `###` would double-count every
grouped phase (parent plus children) and distort the progress denominator. Verified: the regex
matches exactly 8 headings in this file.

Phase 2 is deliberately in Wave 1 rather than last. The research report's own tier ordering puts the
Barcan work at Tier 5; front-loading it surfaces R1 — the task's only Medium-likelihood blocking
risk — before 17 downstream lemmas depend on it.

### Phase 1: Internalize.lean core definitions and the root anchor [NOT STARTED]

- **Goal:** `Verified/Internalize.lean` exists, is wired into the build, and defines the
  internalization exactly as research §3.2 specifies, together with the root anchor that pins the
  definition against later drift.
- **Tasks:**
  - [ ] Create `FormalSystem/Metalogic/Decidability/Verified/Internalize.lean` with the standard
        copyright header, importing `Verified.RuleSpec` (which transitively supplies `Tableau`,
        `SignedFormula`, and `Axioms`) plus whatever of `FormalSystem.Theorems.*` the anchor proof
        needs.
  - [ ] `SignedFormula.content : SignedFormula → Formula` — `.pos ↦ φ`, `.neg ↦ φ.neg`.
  - [ ] `conjOf : List Formula → Formula` — right-nested, `⊤`-terminated (`[] ↦ Formula.top`).
  - [ ] `Branch.cell (b) (w) (t) : Formula` — `conjOf` of the `content`s of every `sf` with
        `sf.label == ⟨w, t⟩`. **Keyed on the full `Label`** (settled decision 5). `Label` derives
        `BEq`/`DecidableEq` (`SignedFormula.lean:64`), so `filter (· .label == ⟨w,t⟩)` elaborates.
  - [ ] `Branch.slice (b) (t) : Formula` — `(b.cell 0 t).and (conjOf ((b.knownWorlds.filter (· != 0)).map fun w => (b.cell w t).diamond))`.
        World 0 flat, every other known world under one `◇` (settled decisions 2, 3).
  - [ ] `Branch.timeTree (b) (ord) (guard : TimeIndex → TimeIndex → Formula) (visited) (t) : Nat → Formula`
        — fuel-recursive walk away from `t` along `ord.directFutureOf` / `ord.directPastOf`, skipping
        `visited`, emitting `Formula.untl (subtree) (guard t t')` per unvisited direct successor and
        `Formula.snce (subtree) (guard t' t)` per unvisited direct predecessor. Note the per-edge
        guard arity (settled decision 6) — this is the one deviation from the report's plain-`Formula`
        signature.
  - [ ] `Branch.internalizeWith (b) (ord) (guard) : Formula := b.timeTree ord guard [] 0 (b.knownTimes.length + ord.timeCount + 1)`
        and `Branch.internalize (b) (ord) : Formula := b.internalizeWith ord (fun _ _ => Formula.top)`.
        The `⊤` instantiation makes every edge literally `F`/`P` definitionally
        (`Formula.lean:131, 141`); `internalizeWith` is the named hook 411 extends.
  - [ ] `internalize_initial (φ) {fc} : |-![fc] ([SignedFormula.neg φ ⟨0,0⟩].internalize TimeOrdering.empty).neg → |-![fc] φ`
        — the root anchor (research §3.7). For `b₀`, `knownWorlds = [0]`, `knownTimes = [0]`, and both
        `directFutureOf 0` and `directPastOf 0` are `[]`, so the internalization reduces to
        `((φ.neg.and ⊤).and ⊤).and (⊤.and ⊤)`. Proof is `⊤`-conjunct elimination from
        `Combinators.lean` plus double-negation elimination.
  - [ ] Append `import FormalSystem.Metalogic.Decidability.Verified.Internalize` to the end of the
        `Verified.` group in `FormalSystem/Metalogic/Decidability.lean`.
  - [ ] Module docstring recording the time-major/flat-`◇` design and why (settled decisions 2-5),
        with no task-number citations.
- **Timing:** 2-3 hours
- **Depends on:** none
- **Verification Tier:** interface
- **Commit Mode:** per-substep
- **Build gate:** `lake build FormalSystem.Metalogic.Decidability.Verified.Internalize`, then
  `lake build FormalSystem.Metalogic.Decidability`, then `lake build` (the import line touches the
  shared root).
- **Done when:** all seven declarations elaborate, `internalize_initial` is sorry-free, and
  `lake build` is green with the sorry count still at 6.
- **Scope Hypothesis:** ~200 lines of output; 7 declarations; 2 files touched (1 created, 1
  append-only). Confirm at implementation time by `wc -l` on the new file and `git diff --stat`.
  `Branch.timeTree`'s fuel recursion is asserted to be structurally accepted by the equation
  compiler; if Lean demands a `termination_by`, that is an expected local adjustment, not a scope
  change.

### Phase 2: Rules/TemporalAssets.lean -- the two missing object-language assets [NOT STARTED]

- **Goal:** the two object-language principles that are *not* in the tree, proved sorry-free in a
  task-owned file, before anything depends on them. This phase is pure object-language work: it
  imports nothing from Phase 1 and can run fully in parallel with it.
- **Timing:** 8-10 hours total
- **Depends on:** none
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Build gate:** `lake build FormalSystem.Metalogic.Decidability.Verified.Refutation.Rules.TemporalAssets`,
  then `lake build FormalSystem.Metalogic.Decidability`, then `lake build` (Phase 2.1 adds the import
  line).
- **Scope Hypothesis:** ~450 lines across three sub-phases; 4 new declarations; 2 files touched (1
  created, 1 append-only). Confirm by `wc -l` and `git diff --stat`. The 4-step and 5-step assembly
  chains in research §5.2 and §5.4 are *designs, not executed proofs* (research §9 explicitly says
  no composition was run in Lean) — step counts may grow.

#### Phase 2.1: fConjG and pConjH [NOT STARTED]

- **Goal:** `fConjG : ⊢ Gψ → (F A → F (A ∧ ψ))` and its past mirror `pConjH`, the principle the four
  temporal universal rules need to propagate along the transitive `futureOf`/`pastOf` closure.
  Verified absent from the tree (research §5.2).
- **Tasks:**
  - [ ] Create `FormalSystem/Metalogic/Decidability/Verified/Refutation/Rules/TemporalAssets.lean`
        (creating the `Refutation/Rules/` directories) with the standard header, importing
        `FormalSystem.Theorems.*` only — no `Verified.` dependency.
  - [ ] Append its import line to `Decidability.lean` (append-only, end of the `Verified.` group).
  - [ ] `fConjG` via the research §5.2 chain: `pairing` (`Combinators.lean:555`) +
        `theoremFlip` (:169) for `⊢ ψ → (A → A ∧ ψ)`; `DerivationTree.temporal_necessitation`
        (`Derivation.lean:196`); `gDistribution` (`TemporalDerived.lean:260`); `right_mono_until`
        (`Axioms.lean:134`), using `U(A,⊤) = F A` definitionally (`Formula.lean:131`).
  - [ ] `pConjH` as the mirror: `hDistribution` (`TemporalDerived.lean:268`) + `right_mono_since`
        (`Axioms.lean:138`) + `pastNecessitation` (`GeneralizedNecessitation.lean:95`).
  - [ ] Docstring noting that `gTransitivity` (`TemporalDerived.lean:275`) / `hTransitivity` (:283)
        are the iterators for reaching a node `k` edges away — which is why `futureOf` is the
        transitive closure and not the direct-edge filter.
- **Verification Tier:** local
- **Done when:** both declarations sorry-free; `lake build` green; sorry count still 6.
- **Scope Hypothesis:** ~150 lines; 2 declarations; 4 assembly steps each per research §5.2.

#### Phase 2.2: diamondToFutureDiamond [NOT STARTED]

- **Goal:** `⊢ ◇φ → G(◇φ)` as a named top-level declaration. It currently exists **only** as an
  inline `have future_comp` inside `persistence`'s `by` block
  (`Perpetuity/Principles.lean:771-787`), which cannot be referenced.
- **Tasks:**
  - [ ] Add `diamondToFutureDiamond (φ) : ⊢ φ.diamond.imp φ.diamond.allFuture` to
        `TemporalAssets.lean`, re-proving the ~17-line inline argument locally.
  - [ ] Docstring noting it duplicates an inline step in `Perpetuity/Principles.lean`'s
        `persistence`, and that promoting it into `Theorems/Perpetuity/` is deliberately out of this
        territory (settled: read-only files are not edited here).
- **Timing:** 1-2 hours
- **Depends on:** 2.1
- **Verification Tier:** local
- **Done when:** the declaration is sorry-free and `lake build` is green.
- **Scope Hypothesis:** ~100 lines. The research report calls this "free" (§5.4); confirm by whether
  the local re-proof closes without new lemmas. If it does not, the inline argument depends on
  `persistence`'s surrounding context and this becomes a genuine sub-proof — record that as a
  finding.

#### Phase 2.3: barcanDiamondG -- the one genuinely hard step [NOT STARTED]

- **Goal:** `barcanDiamondG (χ) : ⊢ (χ.allFuture).diamond.imp (χ.diamond).allFuture`, i.e.
  `◇(Gχ) → G(◇χ)`. This is **not** a TM axiom — the only modal-temporal axiom is
  `modal_future : □φ → □(Gφ)` (`Axioms.lean:268`) — but a verified route exists.
- **Why it is needed:** in the four fresh-time existential rules, `gProps`/`fNegProps` are filtered
  on `gsf.label.time == l.time` **only**; the *world* is unconstrained, and the emitted formula lands
  at `{world := gsf.label.world, time := freshTime}` (`Tableau.lean:767-785, 807-825, 840-856,
  884-900`). Under time-major internalization the source sits inside `◇` at node `t` and the target
  inside `◇` at node `freshTime`. Because the admissibility statement is over `applyRule` directly
  rather than over the guarded engine path, this is an obligation whether or not the engine ever
  schedules it.
- **Tasks (declared attempt budget — this is the phase's stopping condition):**
  - [ ] **Route B first** (shorter): `persistence : ⊢ ◇φ → △(◇φ)` (`Principles.lean:698`) at
        `φ := Gχ` gives `◇Gχ → △(◇Gχ)`, then `alwaysToFuture` (`MonotonicityDuality.lean:235`) to
        reach `G(◇Gχ)`; inside the `G`, `◇Gχ → ◇Fχ` (via `Axiom.serial_future` `Axioms.lean:113` +
        `diamondMono` `MonotonicityDuality.lean:150`) and `◇Fχ → ◇χ` (contraposed `modal_future`);
        close via `futureMono` (:160).
  - [ ] **Route A second** if B stalls: the contrapositive `F(□θ) → □(Fθ)` chain —
        `F θ → ▽θ` (definitional: `sometimes φ = φ.neg.always.neg`, `Formula.lean:594`);
        `perpetuity6 : ⊢ φ.box.sometimes.imp φ.always.box` (`MonotonicityDuality.lean:560`,
        hover-confirmed); `alwaysToFuture`; `boxMono` (:139); `Gθ → Fθ` via `serial_future` +
        `fConjG` (Phase 2.1). Dualize using `doubleContrapose` (:480), `alwaysDne`/`alwaysDni`
        (:365, :267), `boxDne` (`Principles.lean:474`).
  - [ ] **On exhaustion of both routes**: stop, do not `sorry`, and execute the R1 escalation
        protocol — record a boundary note naming rules 15/17/18/20 and *only* their cross-world
        `gProps`/`fNegProps` sub-case as a hand-off to 411, mark Phase 8 `[BLOCKED]`, and let
        Phases 3-7 proceed and complete.
- **Timing:** 5-6 hours
- **Depends on:** 2.1
- **Verification Tier:** local
- **Done when:** `barcanDiamondG` is sorry-free and `lake build` is green; **or** both routes are
  exhausted with the escalation protocol executed and the boundary note written.
- **Scope Hypothesis:** ~200 lines; 1 declaration; 2 declared routes. Every *ingredient* is verified
  present with the stated type (research §7, §9), but no composition has been executed in Lean —
  this is the plan's least certain line estimate. The two-route budget, not the line count, is the
  bounded-unit stopping condition.

### Phase 3: Positive-context monotonicity engine [NOT STARTED]

- **Goal:** the highest-leverage item in the task. Every label position in `internalize` sits under
  `∧`, `◇`, `untl(·, guard)`, `snce(·, guard)` — all monotone positions. This phase proves once, and
  generically, that strengthening a cell strengthens the whole internalization, so that none of the
  21 rule lemmas re-derives the descent.
- **Timing:** 5-6 hours total
- **Depends on:** 1
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Build gate:** `lake build FormalSystem.Metalogic.Decidability.Verified.Internalize`, then
  `lake build FormalSystem.Metalogic.Decidability`.
- **Implementation constraint (research §5.1, recommendation 1):** implement this as recursion over
  `timeTree`'s own structure — a `slice`-at-node replacement lemma plus a tree-lifting lemma. Do
  **not** introduce a general `Formula` context type; that was explicitly dropped after seeing how
  few formers occur.
- **Scope Hypothesis:** ~280 lines across two sub-phases; 5-6 declarations; 1 file touched
  (`Internalize.lean`, or `Internalize/Mono.lean` if the ~900-line overflow trigger fires — see the
  Territory Contract). Confirm by `wc -l` and `git diff --stat`.

#### Phase 3.1: conjOf / cell / slice monotonicity [NOT STARTED]

- **Goal:** `conjOf_mono`, a `cell`-replacement lemma, and `slice_mono` — strengthening one cell's
  content strengthens the enclosing slice.
- **Tasks:**
  - [ ] `conjOf_mono`: from a pointwise `⊢[fc] Xᵢ → Yᵢ` (or a list-superset relation) conclude
        `⊢[fc] conjOf Xs → conjOf Ys`, via `combineImpConj` / `combineImpConj3`
        (`Combinators.lean:603, 622`), `pairing` (:555), `impTrans` (:99).
  - [ ] `conjOf_append_left` / `conjOf_append_right` style lemmas: the shape needed for the
        `delta ++ b` child form, since `expandOnce` never subtracts (research §4 correction 4).
  - [ ] `slice_mono`: lift a cell strengthening through the flat-`◇` layer using `diamondMono`
        (`MonotonicityDuality.lean:150`), with `kDistDiamond` (`ModalS5.lean:280`) + `necessitation`
        as the fallback route.
- **Depends on:** 1
- **Verification Tier:** local
- **Done when:** all declarations sorry-free; `lake build FormalSystem.Metalogic.Decidability` green.
- **Scope Hypothesis:** ~140 lines; 3-4 declarations.

#### Phase 3.2: timeTree and internalize monotonicity [NOT STARTED]

- **Goal:** `timeTree_mono` and `internalize_mono` — the tree-lifting lemma, by recursion on
  `timeTree`'s fuel argument.
- **Tasks:**
  - [ ] `timeTree_mono`: induction on fuel; at each node use `slice_mono` (Phase 3.1) for the node's
        own content, `fMono` (`TemporalDerived.lean:407`) / `right_mono_until` (`Axioms.lean:134`)
        for the `untl` edges, and `pMono` (:417) / `right_mono_since` (`Axioms.lean:138`) for the
        `snce` edges. State it generically in `guard` — the edge formers are monotone in their first
        argument regardless of the guard.
  - [ ] `internalize_mono` / `internalizeWith_mono` as the `t := 0` corollary.
  - [ ] Docstring naming the four monotone formers and stating that no other former occurs in
        `internalize`, so this family is complete for the 21 lemmas.
- **Depends on:** 3.1
- **Verification Tier:** local
- **Done when:** `internalize_mono` is sorry-free and `lake build FormalSystem.Metalogic.Decidability`
  is green.
- **Scope Hypothesis:** ~140 lines; 2 declarations. If the fuel induction needs a strengthened
  hypothesis over `visited` that the plan did not anticipate, record it as a finding — that is the
  most likely place this sub-phase overruns.

### Phase 4: Forest invariant and the rule_admissible harness [NOT STARTED]

- **Goal:** the remaining two pieces of `Internalize.lean` plumbing: the forest hypothesis with its
  preservation lemmas, and the `rule_admissible` statement shape plus the generic contraposition
  bridge every rule lemma routes through.
- **Timing:** 4-5 hours total
- **Depends on:** 3 (file serialization on `Internalize.lean` only; there is no logical dependency on
  the monotonicity engine)
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Build gate:** `lake build FormalSystem.Metalogic.Decidability`.
- **Scope Hypothesis:** ~230 lines across two sub-phases; 6-8 declarations; 1 file touched.

#### Phase 4.1: TimeOrdering.IsForestAt and its preservation lemmas [NOT STARTED]

- **Goal:** the explicit hypothesis that research §3.5 promotes out of a would-be silent unsoundness,
  plus the generic lemmas that let each fresh-time rule discharge its own instance in one line.
- **Tasks:**
  - [ ] `TimeOrdering.IsForestAt (ord) (root : TimeIndex) : Prop` — the constraint graph is a forest
        rooted at `root`. **Must include a no-duplicate-constraints clause** (risk R6, newly
        identified): `directFutureOf`/`directPastOf` are `constraints.filterMap` and do not
        deduplicate, so a duplicated constraint would emit a duplicated tree edge. Not a vacuous
        `True` and not an unhypothesised definition — both would be worse than the hypothesis.
  - [ ] `TimeOrdering.empty_isForestAt : IsForestAt TimeOrdering.empty 0` — `empty.constraints = []`
        (`SignedFormula.lean:679`).
  - [ ] `addFuture_preserves_forest` / `addPast_preserves_forest`, hypothesised on the new time being
        **fresh** (not among the branch's times). `addFuture`/`addPast` prepend exactly one
        constraint (`SignedFormula.lean:685, 689`) and `Branch.nextTime` (:380) is strictly above
        every time on the branch, so the new node has exactly one incident edge and no duplicate.
  - [ ] `Branch.nextTime` freshness lemma, if not already available, as the hypothesis-discharging
        step the four fresh-time rules will cite.
  - [ ] Docstring naming the residual obligation precisely: within this task's 21 rules the ordering
        stays a forest rooted at time 0. The only two rules that break it are `densityRule` (inserts
        an intermediate node between `t` and an existing `t' ∈ futureOf t`, producing a diamond) and
        `timeLinearity` (`identifyTime`, `SignedFormula.lean:705`, so a merged node inherits both
        predecessors' edges). Name them by rule, so their owners cannot lose the obligation.
- **Depends on:** 3
- **Verification Tier:** local
- **Done when:** the predicate and all preservation lemmas are sorry-free; `lake build
  FormalSystem.Metalogic.Decidability` green.
- **Scope Hypothesis:** ~130 lines; 4-5 declarations. Note the deliberate *narrowing* against
  research §3.5, which proposed one `applyRule_preserves_forest` over all 21 rules: only four of the
  21 mutate `ord` at all (`allFutureNeg`, `allPastNeg`, `someFuturePos`, `somePastPos` — call sites
  `Tableau.lean:763, 803, 836, 880`); `boxNeg`/`diamondPos` mint a fresh *world*, not a fresh time.
  Generic lemmas here plus four one-line instances in Phase 8 keeps both phases bounded. Confirm the
  "exactly four" count at implementation time by grepping `addFuture`/`addPast` call sites inside
  `applyRule`.

#### Phase 4.2: rule_admissible statement shape and the contraposition bridge [NOT STARTED]

- **Goal:** state the obligation once, correctly, so each of the 21 lemmas is a one-arm instance;
  and provide the bridge from the working contrapositive form every proof actually establishes to the
  `Derivable`-of-negation form the downstream consumer needs.
- **Tasks:**
  - [ ] The `rule_admissible` shape per research §4, honouring all five corrections: `applyRule`
        returns `RuleResult × TimeOrdering` (`Tableau.lean:630-631`) so the child is internalized
        against `ord'`; a five-way case-split over `RuleResult` (`.linear`, `.branching`,
        `.branchingOrdered`, `.persistent`, `.notApplicable`, :205-230), not `∀ children ∈ ...`;
        children are `delta ++ b` for the three in-scope constructors; `.branchingOrdered` and
        `.notApplicable` arms are `True`.
  - [ ] The generic contraposition bridge: from `⊢[fc] b.internalize ord → (delta ++ b).internalize ord'`
        conclude `|-![fc] ((delta ++ b).internalize ord').neg → |-![fc] (b.internalize ord).neg`,
        via `contraposition` (`Perpetuity/Principles.lean:116`) or `doubleContrapose`
        (`MonotonicityDuality.lean:480`). Proved **once**, generically. Note the notation:
        `Derivable` is `|-![fc] p` (`Derivable.lean:77, 82`); `DerivationTree` is `⊢[fc] φ`
        (`Derivation.lean:315, 320`).
  - [ ] A `h_fc` discharge helper for the `.Base` case: every one of this task's 21 rules has
        `ruleFrameClass r = .Base` (`RuleSpec.lean:151-175`), so `h_fc` is `FrameClass.base_le fc`
        (`Axioms.lean:568`) and Base-only reused theorems lift via `DerivationTree.lift`
        (`Derivation.lean:190`) or `Derivable.lift` (`Derivable.lean:110`). **Keep `h_fc` in the
        statement anyway** — 411 needs it, and 412's induction over `allRulesForFC` supplies it via
        `mem_allRulesForFC_iff` (`RuleSpec.lean:310`).
  - [ ] A branching-case helper: from `∀ nf ∈ brs, |-![fc] ((nf ++ b).internalize ord').neg`
        conclude the parent's refutability, so Phase 5.2 and Phase 6 do not each re-derive the case
        analysis.
- **Depends on:** 4.1
- **Verification Tier:** local
- **Done when:** the shape elaborates, the bridge and both helpers are sorry-free, and `lake build
  FormalSystem.Metalogic.Decidability` is green.
- **Scope Hypothesis:** ~100 lines; 3-4 declarations. In practice each of the 21 is stated as its own
  theorem with `r` fixed, so the five-way `match` collapses to the single arm that rule can produce.

### Phase 5: Rules/Propositional.lean -- the 8 propositional lemmas [NOT STARTED]

- **Goal:** all 8 truth-functional rules. Every emission stays inside a single `Branch.cell`, so
  these are the cheapest of the 21 and the first real exercise of the Phase 3 and Phase 4
  infrastructure.
- **Timing:** 4-5 hours total
- **Depends on:** 3, 4 (not Phase 2 — no temporal asset is needed here)
- **Verification Tier:** interface
- **Commit Mode:** per-substep
- **Build gate:** `lake build FormalSystem.Metalogic.Decidability.Verified.Refutation.Rules.Propositional`,
  then `lake build FormalSystem.Metalogic.Decidability`, then `lake build` (Phase 5.1 adds the import
  line).
- **Boundary note:** `impPos`/`impNeg` match `.imp` directly and therefore overlap
  `negPos`/`negNeg`/`andPos` on the same formula (risk R7). Each lemma is stated per rule and is
  independently true; the overlap affects only engine priority
  (`Tableau.lean:1569-1588`), never admissibility. Do not attempt to deduplicate them.
- **Scope Hypothesis:** ~330 lines across two sub-phases; 8 theorems; 2 files touched (1 created, 1
  append-only). Confirm by `wc -l`, a `grep -c "^theorem"` count of 8, and `git diff --stat`.

#### Phase 5.1: the five .linear propositional rules [NOT STARTED]

- **Goal:** `negPos`, `negNeg`, `impNeg`, `orNeg`, `andPos` — the `.linear` arms.
- **Tasks:**
  - [ ] Create `Verified/Refutation/Rules/Propositional.lean` importing `Verified.Internalize` and
        `Rules.TemporalAssets` (or only the former if no temporal asset is needed), and append its
        import line to `Decidability.lean`.
  - [ ] `andPos` (`Tableau.lean:635-638`, via `asAnd?` :249): `impTrans` (`Combinators.lean:99`),
        `pairing` (:555), `combineImpConj` (:603), `deductionTheorem`
        (`Metalogic/Core/DeductionTheorem.lean:325`).
  - [ ] `orNeg` (:650-653): `Combinators.lean:99, 555, 589`.
  - [ ] `impNeg` (:658-659): `theoremApp1` (`Combinators.lean:292`), `notNotIntro` (:589),
        `ex_falso` (`Axioms.lean:93`).
  - [ ] `negPos` (:661-664, via `asNeg?` :240): identity modulo `neg` unfolding
        (`Formula.lean:121`), `identity` (`Combinators.lean:126`).
  - [ ] `negNeg` (:666-669): the DNE step — `notNotIntro` (`Combinators.lean:589`),
        `doubleContrapose` (`MonotonicityDuality.lean:480`).
- **Depends on:** 4
- **Verification Tier:** interface
- **Done when:** 5 theorems sorry-free; `lake build` green; sorry count still 6.
- **Scope Hypothesis:** ~180 lines; 5 theorems.

#### Phase 5.2: the three .branching propositional rules [NOT STARTED]

- **Goal:** `andNeg`, `orPos`, `impPos` — the `.branching` arms, each a two-arm case analysis routed
  through Phase 4.2's branching helper.
- **Tasks:**
  - [ ] `andNeg` (`Tableau.lean:640-643`): `notNotIntro` (`Combinators.lean:589`), `theoremApp1`
        (:292), `theoremApp2` (:318), `peirce` (`Axioms.lean:95`).
  - [ ] `orPos` (:645-648, via `asOr?` :258): `peirce` (`Axioms.lean:95`), `prop_k` (:88),
        `bCombinator` (`Combinators.lean:148`).
  - [ ] `impPos` (:655-656): `peirce` (`Axioms.lean:95`), `mp` (`Combinators.lean:112`).
- **Depends on:** 5.1
- **Verification Tier:** interface
- **Done when:** 3 theorems sorry-free; `lake build` green.
- **Scope Hypothesis:** ~150 lines; 3 theorems.

### Phase 6: Rules/Modal.lean -- boxTemporal and the four S5 rules [NOT STARTED]

- **Goal:** the 5 lemmas whose content moves across worlds at a **fixed time**, so the whole
  obligation is local to one `Branch.slice`. This is where the time-major design pays off: source and
  target are both inside the same time node, and no temporal step is needed.
- **Timing:** 5-6 hours total
- **Depends on:** 3, 4 (not Phase 2 — these five never leave a single time node)
- **Verification Tier:** interface
- **Commit Mode:** per-substep
- **Build gate:** `lake build FormalSystem.Metalogic.Decidability.Verified.Refutation.Rules.Modal`,
  then `lake build FormalSystem.Metalogic.Decidability`, then `lake build`.
- **Scope Hypothesis:** ~400 lines across two sub-phases; 5 theorems; 2 files touched (1 created, 1
  append-only). Confirm by `wc -l`, `grep -c "^theorem"` = 5, `git diff --stat`. These 5 lemmas never
  touch a tree edge, so they are guard-agnostic outright (risk R3) — record that in the module
  docstring so 411 knows they transfer unchanged.

#### Phase 6.1: boxTemporal and the two .persistent S5 rules [NOT STARTED]

- **Goal:** `boxTemporal`, `boxPos`, `diamondNeg`.
- **Tasks:**
  - [ ] Create `Verified/Refutation/Rules/Modal.lean` importing `Verified.Internalize`, and append its
        import line to `Decidability.lean`.
  - [ ] `boxTemporal` (`Tableau.lean:743-748`): `T(□ψ)@l → T(Gψ)@l, T(Hψ)@l`, same cell. The
        cheapest lemma in the task — `boxToFuture : ⊢ φ.box.imp φ.allFuture`
        (`Perpetuity/Helpers.lean:62`) and `boxToPast` (:81) are exact.
  - [ ] `boxPos` (:671-677, `.persistent`): `T(□ψ)@(w,t) → T(ψ)@(w',t)` for every
        `w' ∈ knownWorlds`. Extract the universal claim from inside a `◇` conjunct with
        `s5DiamondBoxToTruth : ⊢ (◇□A) → A` (`ModalS5.lean:766`) and `s5DiamondBox : ⊢ (◇□A) ↔ □A`
        (:717); distribute into every `◇` with `modal_k_dist` (`Axioms.lean:106`) + `kDistDiamond`
        (`ModalS5.lean:280`); `boxConjIff` (:465) for conjunction bookkeeping; `modal_t`
        (`Axioms.lean:98`).
  - [ ] `diamondNeg` (:731-740, `.persistent`): as `boxPos` via `¬◇ = □¬` —
        `modalDualityNeg`/`modalDualityNegRev` (`MonotonicityDuality.lean:78, 108`),
        `ModalS5.lean:766, 280`.
- **Depends on:** 4
- **Verification Tier:** interface
- **Done when:** 3 theorems sorry-free; `lake build` green.
- **Scope Hypothesis:** ~200 lines; 3 theorems.

#### Phase 6.2: the two .linear S5 rules [NOT STARTED]

- **Goal:** `boxNeg`, `diamondPos` — the fresh-world rules.
- **Why they stay routine:** both mint a world whose content lands at *several* times, keyed on
  `bsf.label.time` rather than `l.time` (`Tableau.lean:685-697, 712-724`). Settled decision 4 —
  `internalize` does not preserve world identity across times — is exactly what makes this
  unproblematic: each affected time node simply gains one more `◇` conjunct.
- **Tasks:**
  - [ ] `boxNeg` (`Tableau.lean:679-702`): `F(□ψ)@(w,t) → F(ψ)@(wF,t)` plus `boxProps` and
        `diaProps`, all at their *sources'* times. Slice-wise, one new `◇` conjunct per affected
        node. Assets: `modalDualityNeg`/`modalDualityNegRev` (`MonotonicityDuality.lean:78, 108`),
        `boxDne` (`Principles.lean:474`), `mbDiamond : ⊢ φ → ◇□φ` (:567), `modal_t`/`modal_b`
        (`Axioms.lean:98, 102`).
  - [ ] `diamondPos` (:704-729, via `asDiamond?` :267): the dual, same assets plus `tBoxToDiamond`
        (`ModalS5.lean:108`).
  - [ ] The `◇⊤` case: when a minted world has no content at some time node, close with `mbDiamond`
        (`Principles.lean:567`) + `boxToPresent` (`Perpetuity/Helpers.lean:93`), or `tBoxToDiamond`
        (`ModalS5.lean:108`).
- **Depends on:** 6.1
- **Verification Tier:** interface
- **Done when:** 2 theorems sorry-free; `lake build` green.
- **Scope Hypothesis:** ~200 lines; 2 theorems. The `◇⊤` sub-case is asserted to be a one-lemma
  step; if the minted world's empty cell needs its own treatment across *every* time node, that is a
  finding to record.

### Phase 7: Rules/Temporal.lean -- the four temporal universal rules [NOT STARTED]

- **Goal:** `allFuturePos`, `someFutureNeg`, `allPastPos`, `somePastNeg` — the 4 `.persistent` rules
  that propagate node-to-node along the transitive `futureOf`/`pastOf` closure **within one world**.
  No fresh time, no ordering mutation, no cross-world step.
- **Timing:** 5-6 hours total
- **Depends on:** 2 (needs `fConjG`/`pConjH` from 2.1), 3, 4
- **Verification Tier:** interface
- **Commit Mode:** per-substep
- **Build gate:** `lake build FormalSystem.Metalogic.Decidability.Verified.Refutation.Rules.Temporal`,
  then `lake build FormalSystem.Metalogic.Decidability`, then `lake build`.
- **Scope Hypothesis:** ~330 lines across two sub-phases; 4 theorems; 2 files touched (1 created, 1
  append-only). Confirm by `wc -l`, `grep -c "^theorem"` = 4, `git diff --stat`. These four *do*
  touch tree edges, so state them generically in `guard` wherever the proof permits and record which
  (if any) end up `⊤`-specific — that is risk R3's hand-off information for 411.

#### Phase 7.1: allFuturePos and someFutureNeg [NOT STARTED]

- **Goal:** the future pair.
- **Tasks:**
  - [ ] Create `Verified/Refutation/Rules/Temporal.lean` importing `Verified.Internalize` and
        `Rules.TemporalAssets`, and append its import line to `Decidability.lean`.
  - [ ] `allFuturePos` (`Tableau.lean:751-757`): `T(Gψ)@(w,t) → T(ψ)@(w,t')` for every
        `t' ∈ futureOf t`. Walk down the `F`-chain with `fConjG` (Phase 2.1), iterating with
        `gTransitivity : ⊢ Gφ → G(Gφ)` (`TemporalDerived.lean:275`) and distributing with
        `gDistribution` (:260) / `right_mono_until` (`Axioms.lean:134`). This is why `futureOf` is
        the transitive closure and not the direct-edge filter (`SignedFormula.lean:764-771`).
  - [ ] `someFutureNeg` (:863-872): `F(Fψ)@(w,t) → F(ψ)@(w,t')` for every `t' ∈ futureOf t` — as
        `allFuturePos` modulo `¬F` vs `G` DNE bookkeeping, via `notNotIntro`
        (`Combinators.lean:589`) and `TemporalDerived.lean:260, 275`.
- **Depends on:** 4
- **Verification Tier:** interface
- **Done when:** 2 theorems sorry-free; `lake build` green.
- **Scope Hypothesis:** ~180 lines; 2 theorems. The chain-iteration depth is bounded by the fuel used
  in `Branch.timeTree`; if the induction needs a separate reachability-to-tree-depth lemma, record it
  as a finding.

#### Phase 7.2: allPastPos and somePastNeg [NOT STARTED]

- **Goal:** the past mirrors.
- **Tasks:**
  - [ ] `allPastPos` (`Tableau.lean:791-797`): mirror of `allFuturePos` via `hTransitivity`
        (`TemporalDerived.lean:283`), `hDistribution` (:268), `right_mono_since`
        (`Axioms.lean:138`), and `pConjH` (Phase 2.1).
  - [ ] `somePastNeg` (:907-916): mirror of `someFutureNeg` via `TemporalDerived.lean:268, 283` and
        `notNotIntro` (`Combinators.lean:589`).
- **Depends on:** 7.1
- **Verification Tier:** interface
- **Done when:** 2 theorems sorry-free; `lake build` green.
- **Scope Hypothesis:** ~150 lines; 2 theorems. Asserted to be mechanical mirrors of 7.1; if
  `snce`'s guard interval behaves asymmetrically to `untl`'s, that asymmetry is a finding to record
  rather than a scope overrun to absorb silently.

### Phase 8: The four temporal existential rules [NOT STARTED]

- **Goal:** the last 4 of the 21 — `allFutureNeg`, `someFuturePos`, `allPastNeg`, `somePastPos`. Each
  grows a fresh time node, mutates the `TimeOrdering`, and propagates `gProps`/`fNegProps` **across
  worlds**. This is the task's risk concentration and depends on every other phase.
- **Timing:** 6-7 hours total
- **Depends on:** 2 (Barcan from 2.3), 4 (forest lemmas from 4.1), 6 (the `◇` handling from 6.2), 7
  (the `F`-chain machinery from 7.1)
- **Verification Tier:** interface
- **Commit Mode:** per-substep
- **Build gate:** `lake build FormalSystem.Metalogic.Decidability.Verified.Refutation.Rules.Temporal`,
  then `lake build FormalSystem.Metalogic.Decidability`, then `lake build`.
- **`boxDiamondPersistence` is `private`** (`Tableau.lean:434`) and cannot be unfolded from here.
  Use its three public lemmas, whose docstrings name exactly these four rules
  (`Tableau.lean:480-485`): `mem_boxDiamondPersistence` (:454), `mem_boxDiamondPersistence_label`
  (:491), `mem_boxDiamondPersistence_shape` (:551). Together they say every contributed formula is a
  `□`-positive or `◇`-negative relabelling of a branch member from `(w,t)` to `(w,ft)`. The
  corresponding object-language obligation is `□χ → G(□χ)` / `□χ → H(□χ)`: `temporalFutureDerived`
  (`Combinators.lean:653`) and `boxToPast` (`Perpetuity/Helpers.lean:81`) composed with `modal_4`
  (`Axioms.lean:100`) — the exact composition already performed at
  `Verified/../BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:385-390`. These three are
  *necessary* conditions on membership, which is precisely the `∀ g ∈ ...` direction admissibility
  needs; **no sufficiency/surjectivity lemma is required** (research §5.5).
- **Scope Hypothesis:** ~450 lines across two sub-phases; 4 theorems plus 4 one-line forest-instance
  discharges; 1 file touched (`Rules/Temporal.lean`, extended). Confirm by `wc -l`,
  `grep -c "^theorem"` reaching 8 in that file, and `git diff --stat`. This is the plan's largest
  sub-phase pair; if 8.1 overruns, split the witness emission from the `gProps`/`fNegProps`
  propagation rather than widening the sub-phase.

#### Phase 8.1: allFutureNeg and someFuturePos [NOT STARTED]

- **Goal:** the future pair, `.linear` with `newOrd = ord.addFuture l.time freshTime`.
- **Tasks:**
  - [ ] `allFutureNeg` (`Tableau.lean:760-788`): `F(Gψ)@(w,t) → F(ψ)@(w,tF)` plus `gProps`,
        `fNegProps`, and `boxDiamondPersistence`. Witness via `fNegG : ⊢ ¬Gψ → F¬ψ`
        (`TemporalDerived.lean:504`); the fresh `F`-child of node `t` via `fConjG` (Phase 2.1); the
        cross-world `gProps`/`fNegProps` via `barcanDiamondG` (Phase 2.3); the persistence
        contributions via the three `mem_boxDiamondPersistence_*` lemmas plus
        `temporalFutureDerived` (`Combinators.lean:653`).
  - [ ] `someFuturePos` (:831-860, via `asSomeFuture?` :285): `T(Fψ)@(w,t) → T(ψ)@(w,tF)` plus the
        same props. `F_until_equiv` (`Axioms.lean:255`) — here definitional (`Formula.lean:131`) —
        and `fMono` (`TemporalDerived.lean:407`).
  - [ ] Discharge both rules' forest-preservation instances from Phase 4.1's
        `addFuture_preserves_forest` plus `Branch.nextTime` freshness (call sites
        `Tableau.lean:763, 836`).
- **Depends on:** 2, 4, 6, 7
- **Verification Tier:** interface
- **Done when:** 2 theorems sorry-free with both forest instances discharged; `lake build` green;
  sorry count still 6.
- **Scope Hypothesis:** ~250 lines; 2 theorems + 2 forest instances.

#### Phase 8.2: allPastNeg and somePastPos [NOT STARTED]

- **Goal:** the past mirrors, `.linear` with `newOrd = ord.addPast l.time freshTime`.
- **Tasks:**
  - [ ] `allPastNeg` (`Tableau.lean:800-828`): `F(Hψ)@(w,t) → F(ψ)@(w,tF)` plus `hProps`,
        `pNegProps`, and persistence. `pNegH` (`TemporalDerived.lean:514`), `boxToPast`
        (`Perpetuity/Helpers.lean:81`), `pConjH` (Phase 2.1), the past dual of `barcanDiamondG`.
  - [ ] `somePastPos` (:875-903, via `asSomePast?` :276): `P_since_equiv` (`Axioms.lean:260`),
        `pMono` (`TemporalDerived.lean:417`).
  - [ ] Discharge both forest instances from `addPast_preserves_forest` (call sites
        `Tableau.lean:803, 880`).
  - [ ] Module docstring closing the ledger: 21 of 21, with the boundary explicitly restated —
        rules 22-34 are 411's, `serialityRule`/`timeLinearity` are 430's, and the residual forest
        obligation is exactly `densityRule` and `timeLinearity`.
- **Depends on:** 8.1
- **Verification Tier:** interface
- **Done when:** 2 theorems sorry-free with both forest instances discharged; the full 21-lemma
  ledger closes; `lake build` green; sorry count still 6.
- **Scope Hypothesis:** ~200 lines; 2 theorems + 2 forest instances. If the past dual of
  `barcanDiamondG` is not a mechanical mirror (the `snce` guard interval is the *same* open interval
  as `untl`'s at the witness, which is what makes `enrichment_until` work, but the seriality
  direction differs), that is a finding to record — and if it needs its own derivation, add it to
  `TemporalAssets.lean` as a named sub-phase rather than inlining it.

## Planned Strategic Sorries

**None planned.** `plan_metadata.skeleton` is `false`. This section is present deliberately rather
than omitted: the task has one Medium-likelihood risk (R1, the Barcan step) whose research-specified
contingency is explicitly **not** a sorry.

The R1 escalation protocol, restated so it cannot be mistaken for a sorry-shaped deferral: if Phase
2.3 exhausts both declared routes to `barcanDiamondG`, the implementer records a boundary note
naming rules 15/17/18/20 and *only* their cross-world `gProps`/`fNegProps` sub-case as a hand-off to
411 (which already owns the `Until`/`Since` block where the same commutations recur), marks Phase 8
`[BLOCKED]`, and completes Phases 3-7 in full. The research report is explicit on both prohibitions:
do **not** `sorry` it, and do **not** silently drop the cross-world sub-case from the emitted set.

Per the plan-format deviation flag: any strategic sorry an implementer does place has no
corresponding row here, is therefore a plan-unanticipated deviation, and MUST be flagged in the
implementation summary rather than treated as equivalent to a planned one.

## Testing & Validation

- [ ] `lake build` green at the close of every phase, with **no increase to the baseline sorry count
      of 6** (`Propositional/Decidable.lean` 1, `Correctness.lean` 1,
      `Verified/Termination/TimeTypeBound.lean` 1, `Verified/Bridge/IntTruth.lean` 3).
- [ ] `grep -rn "sorry" FormalSystem/Metalogic/Decidability/Verified/Internalize.lean FormalSystem/Metalogic/Decidability/Verified/Refutation/` returns nothing at task close.
- [ ] Ledger check: exactly **21** admissibility theorems across `Rules/Propositional.lean` (8),
      `Rules/Modal.lean` (5), `Rules/Temporal.lean` (8). 21 + 13 (411) + 2 (430) = 36 =
      `allTableauRules_length` (`RuleSpec.lean:282`).
- [ ] Boundary check: `grep -n "serialityRule\|timeLinearity\|untlPos\|untlNeg\|sncePos\|snceNeg\|orderTrichotomy\|densityRule\|denseIndicatorClosure\|priorUZ\|priorSZ\|z1Rule\|priorUGap\|priorSGap\|sepRule"`
      over this task's five new files returns only boundary-note prose in docstrings, never a theorem
      statement.
- [ ] `internalize_initial` typechecks against the shape the downstream consumer expects; a change to
      `slice`/`conjOf` that breaks it must break the build, which is the whole point of shipping it.
- [ ] `Decidability.lean` diff is append-only: `git diff FormalSystem/Metalogic/Decidability.lean`
      shows exactly five added `import` lines and zero removed or reordered lines.
- [ ] No task-number citations in any `.lean` file:
      `bash .claude/scripts/check-task-references.sh` (or a targeted grep over the five new files).
- [ ] A test-suite addition under `Tests/BimodalTest/` is **not** required by this task and is not
      planned; the 21 lemmas are their own specification and the build is the gate.

## Artifacts & Outputs

| Path | Kind |
|---|---|
| `specs/410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md` | this plan |
| `specs/410_internalize_tableau_branches_and_prove_routine_rule_admissibility/summaries/01_internalize-routine-admissibility-summary.md` | implementation summary |
| `FormalSystem/Metalogic/Decidability/Verified/Internalize.lean` | new (Phases 1, 3, 4) |
| `FormalSystem/Metalogic/Decidability/Verified/Refutation/Rules/TemporalAssets.lean` | new (Phase 2) |
| `FormalSystem/Metalogic/Decidability/Verified/Refutation/Rules/Propositional.lean` | new (Phase 5) |
| `FormalSystem/Metalogic/Decidability/Verified/Refutation/Rules/Modal.lean` | new (Phase 6) |
| `FormalSystem/Metalogic/Decidability/Verified/Refutation/Rules/Temporal.lean` | new (Phases 7, 8) |
| `FormalSystem/Metalogic/Decidability.lean` | modified, append-only (5 import lines) |
| `FormalSystem/Metalogic/Decidability/Verified/Internalize/Mono.lean` | conditional (Phase 3 overflow only) |

## Rollback/Contingency

- **Per-phase**: every phase is one or more green commits (`per-substep` commit mode throughout), so
  reverting a phase is reverting its commits. The five new files are additive and the
  `Decidability.lean` change is five append-only import lines, so a full rollback is: revert the
  commits, delete the new files, remove the five import lines. Nothing pre-existing is modified.
- **Phase 2.3 (Barcan) exhausted**: execute the R1 escalation protocol — boundary note, Phase 8
  `[BLOCKED]`, Phases 3-7 complete. Task closes as `[PARTIAL]` at 17 of 21 with a named, owned
  residual. Do not `sorry`, do not drop the cross-world sub-case.
- **Phase 3 overflow**: if `Internalize.lean` passes ~900 lines, split the monotonicity engine into
  `Verified/Internalize/Mono.lean` (pre-authorized in the Territory Contract) and note the split in
  the commit message.
- **A fourth `mem_boxDiamondPersistence_*` lemma turns out to be needed** (risk R5): raise as a
  blocker. `Tableau.lean` is read-only for this task; do not duplicate the `private def` and do not
  work around it.
- **Concurrent append conflict in `Decidability.lean`**: re-add only this task's own import line.
  Never resolve by reordering or by removing another task's line.
