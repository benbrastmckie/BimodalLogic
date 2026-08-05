# Engine totality at a quantified branch budget — research findings

- **Task**: 428
- **Type**: lean4 (hard mode: H2, H3, H4, H5)
- **Session**: sess_1785952999_c3149a_428
- **Date**: 2026-08-05
- **Reference grounding tier**: **Tier 3 (implementation-backed)**, with a Tier 1 literature
  anchor available (`caleiro_2013`) — see "Reference Grounding" below.

---

## Executive Summary

**The task's own target theorem is refuted, by machine-checked counterexample, at and above the
fuel figure it names and at branch budgets seven orders of magnitude above the engine default.**

```lean
-- REFUTED. Do not attempt in this shape.
theorem buildTableau_isSome_of_budget (phi : Formula) (fc : FrameClass)
    (maxBranches : Nat) (hmb : <bound in phi> <= maxBranches) :
    (buildTableauAt phi (soundFuel' phi) fc maxBranches).isSome = true
```

Counterexample: `φ = F(G p)`. With `soundFuel' φ = 229376` (computed, not estimated),
`expandBranchWithFuel` returns `none` at **every** tested pair
`(fuel, maxBranches) ∈ {500, 8000, 50000, 229376, 300000} × {50000, 10⁹, 10¹²}`.
`buildTableauAt` returns `none` on its first arm whenever `expandBranchWithFuel` does, so no
definition of `buildTableauAt` that threads `maxBranches` into `expandBranchWithFuel` escapes it.

**The cause is a fourth `none` source that neither the task description nor 165's deadlock report
enumerates**: `resolveOpenArm` (`Saturation.lean:563`) returns `none` when the post-blocking pass
leaves the branch unsaturated, and `expandBranchWithFuel`'s two split folds propagate that as
`none` (`:677`, `:703`). This is a signature-level obstruction of exactly the same kind as the
original refutation — `saturateBlocked` *by construction refuses* to expand label-introducing
rules (`:449-450`, `:454-455`, `:468-469`), while `findUnexpanded` *counts* label-introducing work.
When loop-blocking defers label-introducing work — which is precisely what blocking is for — the
two disagree permanently, at any fuel and any budget.

**The good news is that the repair is small, local, and empirically validated.** Swapping the
literal saturation test `findUnexpanded` for the engine's real one, `findUnexpandedUnblocked`, at
`resolveOpenArm`'s two decision points converts the failures to clean open-branch verdicts, with
no change to formulas that already succeeded.

Three further results landed during this research:

1. **`saturateBlocked_isSome` is PROVED, sorry-free** (axioms: `propext`, `Classical.choice`,
   `Quot.sound` only). This discharges a deferred obligation named in-source at
   `Saturation.lean:504` and eliminates two `none` arms outright. Proof is preserved verbatim at
   `specs/428_engine_totality_at_a_quantified_branch_budget/assets/saturateBlocked_isSome.lean.txt`
   and can be lifted into the codebase unchanged.
2. **The branch budget is a per-path counter, not a global tree counter.** Both split folds
   compute `branchesUsed'` *once, before the fold*, and hand the same value to every sibling
   (`Saturation.lean:661`+`668-669`, `:690`+`695-696`). The budget therefore grows linearly, not
   exponentially, and `maxBranches ≥ A · fuel` suffices, where `A` bounds split arity. This makes
   sub-obligation 3 far cheaper than the task anticipates.
3. **Sub-obligation 2 (the world dimension) is already substantially supplied**, contrary to the
   task's framing. `worldFuel' φ s = (s + soundFuel' φ) * soundFuel' φ` carries the seed-world
   count `s`, and `chain_le_worldFuel'` (`Fuel.lean:1556`) is proved against it. The residual is
   narrower and nameable: discharge `hww : WorldWitness C S (run n)`.

**Recommended disposition**: retarget. The budget-parameterised entry point is still worth adding,
but totality must be stated against a *blocking-aware* saturation certificate. Details in
"Recommended revised targets".

---

## Reference Grounding (H3)

**Tier 3 (implementation-backed)** is primary: the task is an "extend/repair X" task whose
authorities are this repository's own engine source and 165's archived artifacts, both read
directly.

| Source | Location | Lean identifier | Type signature / fact | Status |
|---|---|---|---|---|
| 165 deadlock report, O1 | `specs/archive/165_.../reports/09_phase7-deadlock-blocker-research.md:92-124` | `buildTableau_isSome` | unconditional form | **Confirmed false** (re-read, not re-derived) |
| Engine, branch guard | `Saturation.lean:609` | `expandBranchWithFuel` | `if branchesUsed >= maxBranches then none` | Confirmed by read |
| Engine, default budget | `Saturation.lean:605` | `maxBranches : Nat := 50000` | default arg | Confirmed by read |
| Engine, top-level arm | `Saturation.lean:965` | `buildTableau` | `some _ => none` (still unsaturated) | Confirmed by read |
| Landed conditional | `Fuel.lean:1587-1598` | `expandBranchWithFuel_isSome_at_worldFuel'` | carries `hP : NoSplit P fc`, `hbud : branchesUsed + fuel ≤ maxBranches` | Confirmed by read |
| Branching residual | `Fuel.lean:1250-1254` | `NoSplit` | `∀ b, P b → ∀ ord tr, (…extended → P nb) ∧ (…≠ split bs) ∧ (…≠ splitOrdered bs)` | Confirmed by read |
| World dimension | `Fuel.lean:1512` | `worldFuel' (φ : Formula) (s : Nat) : Nat` | `(s + soundFuel' φ) * soundFuel' φ` | **Has a world factor** (`s`) — corrects task framing |
| World-bound chain lemma | `Fuel.lean:1556-1572` | `chain_le_worldFuel'` | `… → n ≤ worldFuel' φ S.card` | Proved, sorry-free |
| World-count invariant | `Fuel.lean:1023`, `:1039` | `WorldWitness`, `worldFinset_card_le` | exist; `hww` undischarged | Confirmed by read |
| **New refutation source** | `Saturation.lean:554-563` | `resolveOpenArm` | `none` when `findUnexpanded satBr ≠ none` after post-blocking | **Confirmed by machine counterexample** |
| Post-blocking refusal | `Saturation.lean:449-450`, `:454-455`, `:468-469` | `saturateBlocked` | rejects any step creating a new time point | Confirmed by read |
| Saturation-notion mismatch | `Tableau.lean:2112-2113` | `findUnexpandedUnblockedWith` | docstring: "This is the engine's **real** saturation test. `findUnexpanded` remains the *literal* one" | Confirmed by read — names the defect |
| Deferred obligation | `Saturation.lean:504` | `saturateBlocked_isSome` | "always returns `some`" | **Now proved** (this research) |

**Tier 1 literature anchor** (`[lit:auto]`, `SUBINDEX_PRESENT`, 33 entries, per-repo briefing
mode): `caleiro_2013` — *On the Mosaic Method for Many-Dimensional Modal Logics: A Case Study
Combining Tense and Modal Operators* (Caleiro, Viganò, Volpe, *Logica Universalis* 7), §4.2
"Mosaic-Based Tableau Systems", §4.3 "Decidability Via Mosaics and Complexity Bounds". This is the
same operator combination this project formalises. It is **not** the task's stated source and was
not used to derive any claim below; it is recorded because the mosaic method's finite saturation
criterion is the standard, literature-backed shape of the repair recommended here, and a planner
choosing between repair routes should read §4.3 first.

---

## Findings

### F1 — The target theorem is false (machine-checked)

Method: an instrumented structural mirror of `expandBranchWithFuel`, `expandDiag`, identical arm
for arm but returning `Except Fail` instead of `Option`, where `Fail` distinguishes `budget`
(`branchesUsed ≥ maxBranches`), `outOfFuel` (`fuel = 0`), and `resolve` (`resolveOpenArm = none`).

**Mirror faithfulness was verified before any conclusion was drawn from it**:
`(expandBranchWithFuel …).isSome = (expandDiag …).toOption.isSome` over 11 formulas × 2 fuels,
**0 mismatches**.

Results for `φ = F(G p)`, `fc = .Base`, seed branch `[F φ @ initial]`:

| fuel | maxBranches | verdict |
|---|---|---|
| 500 | 50000 | `RESOLVE` |
| 500 | 10⁹ | `RESOLVE` |
| 8000 | 10⁹ | `RESOLVE` |
| 50000 | 10¹² | `RESOLVE` |
| **229376 = `soundFuel' φ`** | 10¹² | `RESOLVE` |
| 300000 | 10¹² | `RESOLVE` |

Never `BUDGET`. Never `FUEL`. Also refuted at the same figures: `F(F(G p))`, `¬G(F p)`.
Unaffected (succeed normally): `p → p`, `U(p,q)`, `¬U(⊤,⊥)`, `G p`, `□p → Gp`, `GGp → Gp`,
`F p → U(p,¬p)`, `¬U(p,q)`, `S(p,q)`, `U(U(p,q),p)`, `□(F p)`, `G(F p)`, `F(G p) ∧ q`.

The failing class is characterised structurally, not just enumerated: these are the formulas whose
refutation requires an infinite descent that loop-blocking must cut (`¬F(G p) ≡ G(F(¬p))`), so
blocking fires and leaves label-introducing work at the blocked time — the exact configuration in
which `saturateBlocked` refuses to act and `findUnexpanded` still reports work outstanding.

**This is a signature-level refutation, not a proof difficulty**, on the same footing as the
original: no fuel figure and no branch budget can rule it out, because neither quantity appears in
the disagreement.

### F2 — The repair, empirically validated

`resolveOpenArm` tests saturation with `findUnexpanded` (the *literal* test). The engine's own
docstring at `Tableau.lean:2112-2113` states that `findUnexpandedUnblocked` "is the engine's real
saturation test". Substituting the real test at `resolveOpenArm`'s two decision points
(`Saturation.lean:549` and `:561`):

| formula | current | blocking-aware |
|---|---|---|
| `F(G p)` | `RESOLVE` (none) | **`ok/open`** |
| `¬G(F p)` | `RESOLVE` (none) | **`ok/open`** |
| `U(p,q)` | `ok` | `ok/open` (unchanged) |

The same substitution is available at `buildTableau:955` and `:963`, which is the top-level twin of
the same defect.

**This is a design change with a soundness obligation, not a free win.** It changes what
`.hasOpen` certifies: from "no formula on this branch has an applicable rule" to "no formula at an
*unblocked* time has an applicable rule". The truth lemma and countermodel extraction read that
certificate. This obligation is adjacent to — and must be sequenced against — obstructions O2/O3,
which concern the same certificate's other side conditions. It is **not** in this task's current
scope and is the single largest thing this research surfaces that the task description does not
budget for.

### F3 — `saturateBlocked_isSome`, proved

```lean
theorem saturateBlocked_isSome :
    ∀ (fuel : Nat) (b : Branch) (ord : TimeOrdering) (fc : ProofSystem.FrameClass),
      (saturateBlocked b fuel ord fc).isSome = true
```

Proved by induction on fuel with two fold-invariant helpers (one per split arm). Compiles
sorry-free; `#print axioms` reports only `[propext, Classical.choice, Quot.sound]`. Roughly 90
lines including helpers. Preserved at
`assets/saturateBlocked_isSome.lean.txt`; it can be dropped into
`Saturation.lean` (after `saturateBlocked`, replacing the deferral note at `:501-505`) or into
`Fuel.lean` without modification beyond namespace placement.

Consequences: `buildTableau:966` (`| none => none -- Should not happen`) and `resolveOpenArm:555`
are both now *provably* dead. Two of the five `none` arms are closed.

### F4 — The branch budget is per-path, and the invariant is linear

`Saturation.lean:661` computes `branchesUsed' := branchesUsed + branches.length` **once**, outside
the fold; `:668-669` passes that same `branchesUsed'` to every sibling. Identically at `:690` and
`:695-696`. Siblings do not see each other's consumption.

Therefore the invariant `branchesUsed + A * fuel ≤ maxBranches` is preserved, where `A` bounds
split arity:

- **extend arm**: `branchesUsed+1`, fuel `f` (from `f+1`). Needs `bu + 1 + A·f ≤ mb`; have
  `bu + A·(f+1) = bu + A·f + A ≤ mb` with `A ≥ 1`. ✓
- **split arms**: `branchesUsed + L`, fuel `min alloc f ≤ f`. Needs `bu + L + A·f ≤ mb`; have
  `bu + A·f + A ≤ mb` with `L ≤ A`. ✓

At `branchesUsed = 0` this discharges to `maxBranches ≥ A · fuel` — **linear**, not exponential.
Arity evidence: all six `.branching` sites in `Tableau.lean` (`:642`, `:647`, `:656`, `:962`,
`:1003`, `:1133`, `:1207`) return two-element list literals; `orderTrichotomy` (`:1282`) builds a
three-element disjunct list. A lemma `expandOnceUnblocked_split_arity_le_3` is required — it is
not yet stated. `A = 3` is the value to target; **do not assume `A = 2`**.

### F5 — The world dimension is largely supplied; the task's premise here is outdated

The task quotes 165's plan: "`soundFuel' = 2·n·2^(2n)` has no world factor at all." That is true of
`soundFuel'` and **false of `worldFuel'`**, which landed afterwards:
`worldFuel' φ s = (s + soundFuel' φ) * soundFuel' φ`, with `s` the seed-world count, and
`chain_le_worldFuel'` proved against it (`Fuel.lean:1556-1572`, sorry-free). `WorldWitness`
(`:1023`) and `worldFinset_card_le` (`:1039`) both exist.

The genuine residual is narrow: `chain_le_worldFuel'`'s docstring states that `hww : WorldWitness
C S (run n)` "is an invariant and is **not discharged here**". Sub-obligation 2 should be restated
as *"discharge `WorldWitness` along engine runs"*, not *"supply a missing world dimension"*.

Magnitudes (computed): `soundFuel'(p→p) = 64`, `worldFuel'(p→p, s=1) = 4160`;
`soundFuel'(U(p,q)) = 384`, `worldFuel' = 147840`; `soundFuel'(F(G p)) = 229376`,
`worldFuel' = 52613578752`. The side condition is astronomically large but finite and, being
quantified, never evaluated at runtime.

### F6 — A fifth obstruction the plan must budget for: fuel halves at every split

Separate from the budget, and not covered by `NoSplit`'s removal:
`allocateFuelProportionally` (`Saturation.lean:378-388`) gives sub-branch `i` roughly
`fuel · d_i / Σd`, capped at `fuel`. For two equally-difficult arms that is `≈ fuel/2` (the
in-repo test `FA3` shows `fuel=200 → [25,100,75]`). So the progress hypothesis
`U.card < b.toFinset.card + fuel` that `expandBranchWithFuel_isSome_of_noSplit` (`Fuel.lean:1276`)
carries is **not inherited by sub-branches**: fuel decays multiplicatively down the split tree
while the universe bound does not shrink.

Discharging `NoSplit` therefore requires *either* a lemma bounding the number of splits along any
root-to-leaf path and a fuel figure carrying a matching `2^(#splits)` factor, *or* a restatement
of the induction against per-branch fuel. This is the real quantitative content of sub-obligation
1, and it is larger than "handle two more match arms".

---

## Recommended revised targets

Ordered by dependency. Each is Lean-ready.

**T1 — land the proved lemma** (no research risk; lift verbatim from assets):
```lean
theorem saturateBlocked_isSome :
    ∀ (fuel : Nat) (b : Branch) (ord : TimeOrdering) (fc : ProofSystem.FrameClass),
      (saturateBlocked b fuel ord fc).isSome = true
```

**T2 — split arity bound** (new, small):
```lean
theorem expandOnceUnblocked_split_arity_le
    (b : Branch) (ord : TimeOrdering) (fc : ProofSystem.FrameClass)
    (tr : EventualityTracker) (bs : List Branch)
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs) :
    bs.length ≤ 3
```
plus the `splitOrdered` twin.

**T3 — the budget entry point** (ADDITION only; `buildTableau` untouched):
```lean
def buildTableauAt (phi : Formula) (fuel : Nat) (fc : FrameClass) (maxBranches : Nat) :
    Option ExpandedTableau
```
threading `maxBranches` into `expandBranchWithFuel` and otherwise mirroring `buildTableau`.
Add `buildTableau_eq_buildTableauAt_default : buildTableau φ fuel fc = buildTableauAt φ fuel fc 50000`
so the existing engine and its verified corpus stay pinned to the new definition.

**T4 — the linear budget invariant** (replaces `hbud`'s current shape):
```lean
theorem expandBranchWithFuel_isSome_of_budget_linear {P : Branch → Prop} …
    (hbud : branchesUsed + 3 * fuel ≤ maxBranches) …
```

**T5 — the honest totality statement.** Given F1, the theorem must be stated against the
blocking-aware certificate. Recommended shape:
```lean
theorem buildTableauAt_isSome_of_budget (phi : Formula) (fc : FrameClass) (maxBranches : Nat)
    (hmb : 3 * worldFuel' phi 1 ≤ maxBranches)
    (hww : ⟨WorldWitness discharged along the run⟩)
    (hsplit : ⟨split-depth/fuel-decay bound, per F6⟩) :
    (buildTableauAt phi (worldFuel' phi 1) fc maxBranches).isSome = true
```
**and this is only true once the F2 repair is applied.** Without it, `F(G p)` refutes T5 exactly as
it refutes the original target.

**Sequencing note.** T5 depends on a certificate-semantics change (F2) whose soundness obligation
belongs with O2/O3, not here. A planner has two honest options: (a) narrow 428 to T1–T4 plus a
*conditional* T5 carrying an explicit "post-blocking saturation succeeds" hypothesis — replacing
one escape hatch (`NoSplit`) with a strictly weaker and better-targeted one; or (b) widen 428 to
own the `resolveOpenArm`/`buildTableau` certificate repair, accepting the soundness obligation.
Option (a) is recommended: it keeps 428 discharge-able and hands the certificate question to the
task that already owns the truth-lemma side conditions.

## Do-not-re-attempt register (addition)

`buildTableau_isSome_of_budget` **in the shape given in this task's description** — with
`maxBranches` quantified as the only new hypothesis and `soundFuel' φ` as the fuel — joins
`buildTableau_isSome` on the register. Refuted by `φ = F(G p)` at
`fuel = soundFuel' φ = 229376`, `maxBranches = 10¹²`; cause is `resolveOpenArm = none`, which is
independent of both parameters. Reproduction harness:
`assets/expandDiag-instrumented-mirror.lean.txt`.

---

## Coordination

- **Task 426** — shares `Fuel.lean`. T1/T2 touch `Saturation.lean` only; T4 touches `Fuel.lean`.
  Sequence T4 after 426, or merge. T1–T3 can proceed concurrently with 426.
- **Task 412** — consumes this theorem in place of `buildTableau_isSome`. 412 must be told that the
  replacement carries hypotheses (option (a)) or waits on a certificate change (option (b)). 412's
  acceptance criterion "zero sorries repo-wide outside Boneyard" remains unmeetable as scoped
  until that is settled — 165's report flagged this independently and it still holds.

## Adversarial Self-Verification

Applied after the draft was complete, per the Claim Verification Bar. Every load-bearing claim
below was re-checked against a second source or a machine run.

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `buildTableauAt` does not currently exist | repo-wide grep for `buildTableauAt` returns nothing | `lean_local_search` hit (none) + grep | High |
| `buildTableau` takes no `maxBranches` parameter | `Saturation.lean:943-944` | Direct source read | High |
| Task's target theorem is false | `φ = F(G p)` at `fuel = soundFuel' φ = 229376`, `mb = 10¹²` | `lake build` `#eval`, instrumented mirror | High |
| The mirror is faithful | 22 comparisons vs real `expandBranchWithFuel`, 0 mismatches | `lake build` `#eval` | High |
| Failure cause is `resolveOpenArm`, not fuel/budget | mirror reports `.resolve`, never `.budget`/`.outOfFuel`; invariant across 7 orders of magnitude of `mb` and 600× of fuel | `lake build` `#eval` | High |
| No fuel figure can fix it | `saturateBlocked` refuses new time points (`:449-450`) while `findUnexpanded` counts them; structural, plus empirical at 6 fuel values | Source read + `#eval` | High |
| `saturateBlocked_isSome` is provable | Proof compiles | `lake build` green; `#print axioms` = `[propext, Classical.choice, Quot.sound]` | High |
| `saturateBlocked_isSome` did not already exist | `lean_local_search "saturateBlocked"` returns only the two defs; in-source deferral note at `:504` | `lean_local_search` hit + source read | High |
| Budget counter is per-path | `Saturation.lean:661`+`668-669`, `:690`+`695-696` — `branchesUsed'` computed outside the fold | Direct source read (both split arms) | High |
| `maxBranches ≥ A·fuel` suffices | Invariant checked by hand on all three recursive arms | Hand proof, **not machine-checked** | Medium |
| Split arity ≤ 3 | 6 `.branching` sites are binary literals; `orderTrichotomy` builds 3 disjuncts | Grep + source read; **no lemma exists** | Medium |
| `worldFuel'` carries a world factor | `Fuel.lean:1512-1513`, `s` is the seed-world count | Direct source read | High |
| `chain_le_worldFuel'` is proved sorry-free | `Fuel.lean:1556-1572`; `grep -c sorry Fuel.lean` = 0 | Source read + grep | High |
| `WorldWitness` residual is `hww` | `Fuel.lean:1552-1554` docstring states it is not discharged | Direct source read | High |
| Fuel halves at splits | `allocateFuelProportionally:378-388`; in-repo test FA3 `fuel=200 → [25,100,75]` | Source read + existing test output | High |
| Blocking-aware swap fixes the failures | `F(G p)`, `¬G(F p)`: `RESOLVE → ok/open`; `U(p,q)` unchanged | `lake build` `#eval` | High |
| The swap has a soundness cost | `Tableau.lean:2112-2113` distinguishes "real" vs "literal" saturation; `.hasOpen` is read by the truth lemma | Source read; **consequence is reasoned, not proved** | Medium |

### Contradiction Log

**Resolved — task description vs. current source, on the world dimension.** The task states
"neither bounds worlds … `soundFuel'` has no world factor at all", citing 165's plan:1484-1488.
Current `Fuel.lean:1512` defines `worldFuel' φ s = (s + soundFuel' φ) * soundFuel' φ`, which does
carry a world factor, with `chain_le_worldFuel'` proved against it. Precedence ranking puts
machine-checked current source above an archived plan note. **Resolution**: the task statement
describes a superseded state; `worldFuel'` landed after the note was written. Sub-obligation 2 is
narrowed to discharging `WorldWitness`, not to supplying a missing dimension. Reported in F5.

**Resolved — task description vs. measurement, on what blocks totality.** The task attributes the
`none` verdicts to `maxBranches = 50000` and to `buildTableau`'s last arm. Measurement shows the
binding constraint on the failing class is neither: `resolveOpenArm` inside
`expandBranchWithFuel`'s split fold, which surfaces as `expandBranchWithFuel = none` and is
therefore easy to misattribute to the budget. Precedence: machine counterexample over prose.
**Resolution**: both cited sources are real `none` arms, but neither is the operative one for the
failing class; the operative one was unenumerated. Reported in F1.

**No unresolved contradictions.**

### Recommendations modified after verification

1. **Initially** I had drafted the budget invariant as the headline deliverable, on the strength of
   the per-path discovery (F4). Verification against `F(G p)` at high `maxBranches` showed the
   budget is not binding for the failing class, demoting F4 from "the answer" to "a real but
   insufficient improvement". The report was restructured around F1.
2. **Initially** I recorded `F(G p)` failing at fuel 500/8000 as evidence. That was below
   `soundFuel' φ = 229376`, so it did not test the theorem as stated and would have been an
   invalid refutation. Re-ran at 229376 and 300000 before drawing the conclusion.
3. **Initially** I labelled the `F(G p)` failure `ARM-A: expandBranchWithFuel exhausted (fuel or
   maxBranches)` from a top-level probe. That attribution was wrong; the instrumented mirror
   corrected it to `resolveOpenArm`. The wrong label is preserved here deliberately — it is the
   same misattribution the task description makes, and it is easy to repeat.
4. **Added** F6 (fuel decay at splits) after tracing why `NoSplit` removal is harder than arm
   count suggests; it was not in the draft.

---

## Artifacts

- `specs/428_engine_totality_at_a_quantified_branch_budget/assets/saturateBlocked_isSome.lean.txt`
  — proved, sorry-free, lift-ready.
- `specs/428_engine_totality_at_a_quantified_branch_budget/assets/expandDiag-instrumented-mirror.lean.txt`
  — faithfulness-verified diagnostic harness; reproduces the refutation.

All scratch modules were removed from `FormalSystem/`; the source tree is unmodified by this
research (`git status` clean apart from `specs/`).
