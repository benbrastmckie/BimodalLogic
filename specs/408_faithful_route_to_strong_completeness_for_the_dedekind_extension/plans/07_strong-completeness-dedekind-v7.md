# Implementation Plan: Weak + Finite-Context Consequence Completeness for FrameClass.Dedekind (v7 — the Doets route)

> **REFRAMING NOTE (carried forward unchanged from v1, applies to the whole plan)**: "Strong
> completeness" is reserved, project-wide, for the genuine infinite-premise statement
> (`Γ : Set Formula` with finitary set-derivability), which is **provably unavailable** for the
> Dedekind class — its consequence relation is not compact (Reynolds 1992 Theorem 7 is *weak*
> completeness, and the restriction is genuine). The headline result for this class is **weak
> completeness** `completeness_dedekind`; the arbitrary-finite-`Γ` form, inter-derivable with it
> through the deduction theorem, is `consequence_completeness_dedekind`. No proof obligation,
> phase boundary, or route decision changes under this renaming. See
> `FormalSystem/Metalogic/StrongCompleteness.lean`'s module docstring for the per-class programme.
>
> **v7 note on the Reframing Note.** The Phase 7.9 handoff worried that the Doets route "entails
> weak rather than strong completeness and therefore reopens this task's terminus". That worry is
> **unfounded and is superseded**: under this Reframing Note the headline result *already is* weak
> completeness, and `reports/07_r3d-limit-blocker-verdict.md` §1.5 establishes on three independent
> grounds that the pinned terminus is reached unchanged. Reynolds' own definition of weak
> completeness (§2, quoted below) *is* the finite-set form.

- **Task**: 408 - faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Status**: [IMPLEMENTING]
- **Effort**: **~149 hours** across 22 phases (the sum of the per-phase timings below, not a
  rounded guess). This is a **programme estimate, stated honestly and without compression**: the
  Doets route is the literature's actual route and the literature's actual route is long. See
  "Programme scale and the phase-count ceiling" in the Overview for why the number is what it is
  and why it is not padded. Every prior revision of this plan under-estimated by compressing; this
  one does not.
- **Dependencies**: None. Coordinates with, but is not blocked by, the concurrent decidability
  effort that owns `FormalSystem/Metalogic/Decidability/` and `FormalSystem/Automation/` (territory
  contract below).
- **Research Inputs**:
  - **reports/07_r3d-limit-blocker-verdict.md** (**primary for this revision**; Tier 1
    literature-backed, adversarially verified — Reynolds 1992 §2/§3/§5/§6/§7/§8/§9, Burgess 1984
    §2.7 and p.116, Doets 1987 ch.3 §3.3, all read verbatim from the local corpus; four
    `lean_verify` axiom checks performed in-dispatch). Supplies: the verdict **(b) — the Doets
    route**; the five-column source-to-implementation mapping; the proof that all three Dedekind
    axioms are individually silent against the two-sided accumulation; the discovery that v6's
    load-bearing premise for killing R2 was **factually false about this tree**; the vacuity
    finding on `uSExpressivelyCompleteOverPrior`; the asset ledger; and the §4 list of ten plan
    sections that this revision supersedes.
  - handoffs/phase-7.9-handoff-20260728.json (the blocker record: the landed refutation
    `noGuardAccumulation_not_implied_by_limit_data`, the `guardAccumFamily` witness, and the
    hand-checked `prior_S_gap` two-sided finding)
  - summaries/06_phase-7-9-limit-transport-summary.md
  - reports/05_forward-guard-r3-research.md, reports/04_backward-transport-blocker.md,
    reports/03_limit-future-witness-blocker.md, reports/01_faithful-route-strong-completeness.md,
    reports/02_literature-coverage-audit.md (superseded as route inputs; retained as the record of
    how the completion route was reached, tested and refuted)
  - plans/06_strong-completeness-dedekind-v6.md (superseded predecessor; its Phases 1-7.9 records
    stay there as history and are **not** reproduced here)
- **Artifacts**: plans/07_strong-completeness-dedekind-v7.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4
- **Phases**: **22 total**, numbered **9 through 30**, all `[NOT STARTED]`.
  `phases_total = 22`, `phases_completed = 0`, `phases_dispatchable = 22`. Next dispatch target:
  **Phase 9**.
  **Numbering decision (binding, verified against the scan, not assumed).** The orchestrator's
  phase scan is `grep -E '^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]'
  … | head -1`. A heading of the form `### Phase D1: …` would **not match** and the phase would be
  invisible to dispatch. Alphabetic phase numbering is therefore **rejected**; v7 continues the
  numeric sequence from v6's Phase 8 and starts at **Phase 9**, so that no v7 phase number
  collides with a v6 phase number in any cross-reference or commit message.
  **v6's Phases 1-8 are not reproduced in this file.** Phases 1 and 2 are `[COMPLETED]` and are
  booked in the Preserved Assets table below; Phases 3-7.9 are the amputated layer and are booked
  in the Amputated Assets table; Phase 8's charter is **absorbed into Phase 30** with the pinned
  terminus signature carried forward verbatim.
- **reports_integrated**: 01_faithful-route-strong-completeness.md,
  02_literature-coverage-audit.md, 03_limit-future-witness-blocker.md,
  04_backward-transport-blocker.md, 05_forward-guard-r3-research.md,
  **07_r3d-limit-blocker-verdict.md**

---

## Revision Rationale (v6 → v7)

**This is a route change, and the honest characterization is a large mid-route amputation — not a
revision that is continuous with v6.** `reports/07_r3d-limit-blocker-verdict.md` §3.2 says so
plainly and this plan repeats it rather than softening it: the entire ℝ-extension-by-limits layer
built by v6's Phases 3 through 7.9 becomes dead weight as forward road.

### The trigger

Phase 7.9 did not fail to prove its target. It **refuted** it. The landed, axiom-clean theorem
`noGuardAccumulation_not_implied_by_limit_data`
(`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleGuardAccumulation.lean`) exhibits an
explicit family over the rationals — the dyadic approach `gapApproach r n = ⌊r·2ⁿ⌋/2ⁿ` to an
unselected real `r`, with one atom and the guard failing exactly at the approach points — which
satisfies **all four** conditions the limit chronicle exports (`C5StrongData`,
`C5BackwardStrongData`, `C4Data`, `C4BackwardData`) on all of `ℚ`, realizes `FamilyQShape`, and
refutes `NoGuardAccumulation`. The invariant is not derivable from the data the construction has.

Blocker research then established that it is not derivable from the **axioms** either. All three
Dedekind axioms were checked individually against the two-sided accumulation and all three are
silent:

- `prior_U_gap` is **satisfied** by the counterexample pattern, not violated by it: at `t` below
  the gap the antecedent `U(⊤,ψ) ∧ F¬ψ` holds and the conclusion `U(¬ψ ∨ K⁺(¬ψ), ψ)` is discharged
  by the *next* guard-failure point, which the accumulating pattern supplies at every stage.
- `prior_S_gap` has **no antecedent to fire on** in the two-sided configuration: if the guard fails
  cofinally above the gap as well as below it, `S(⊤,ψ)` never holds in any right-neighbourhood.
- `sep` **cannot reach it**, and this was new to the verdict. Reynolds' own validity proof for Sep
  (Lemma 10, §7) derives its contradiction from *"an uncountable set of pairwise disjoint
  non-singleton intervals of `ℝ`. Impossible."* — a cardinality argument that requires Sep to fail
  at **every** point of an interval. A single-gap accumulation produces **one** accumulation point
  and therefore countably many intervals; it escapes the argument cleanly.

With all three axioms exhausted, the missing content would have to come from a redesigned
witness-placement discipline inside `CounterexampleElimination.lean`, and whether such a discipline
can exist is precisely the Ehrenfeucht-Fraïssé realizability question Phase 7.5 recorded as out of
scope. **No repair is known.**

### The decision, and the factual error it corrected

The user authorized the Doets route on the verdict. Verbatim, and binding:

> **Doets route AUTHORIZED per reports/07 verdict (b). R3d completion-by-limits is abandoned — the
> 7.9 refutation stands as landed mathematics; the ℝ-extension-by-limits layer (old Phases 3-7.9)
> is amputated as forward road (the landed sorry-free material remains in-tree as record; nothing
> is deleted or reverted without explicit need). Phases 1-2, the rational chronicle
> (`cantorBfmcsDense`, `cantorIsoDense`, `limit_satisfies_c5_strong`), and commit `bd9ae0ac1`'s
> Phase 2 material survive and are the base. Plan v7 implements: re-base expressive completeness
> from `SemanticPriorUZ` onto `HasDedekindINF` (the tree already scoped and deferred this at
> `DedekindINF.lean:87-97`), then the Doets transfer to the terminus. The pinned
> `consequence_completeness_dedekind_of_engine` signature carries forward UNCHANGED (no conditional
> terminus).**

**The trigger for the route change was a factual error in v6's own Postmortem Constraints, not a
change of ambition.** v6 forbade the Reynolds transfer route on the stated ground that expressive
completeness of `{U,S}` "is absent from this tree and from Mathlib". That clause is **false about
this tree**. Verified first-hand at this revision:

- `uSExpressivelyCompleteOverPrior` exists, sorry-free, at
  `FormalSystem/Metalogic/WeakCanonical/PriorExpressiveness.lean` (declaration at the end of the
  372-line file), with `#print axioms` reporting exactly `[propext, Classical.choice, Quot.sound]`
  (verified by `lean_verify` in the blocker dispatch).
- It is not an isolated result. The tree contains a **complete, sorry-free, Reynolds/Doets-shaped
  bimodal transfer pipeline at the `.Discrete` class**: `countermodel_discrete_reynolds_v2`
  (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`, 1155 lines), whose audit chain is written out
  at `BXCanonical/Completeness.lean:381-383` as
  `countermodel_discrete_reynolds_v2 → limitdom_is_good → no_gaps_discrete_model_surgery →
  uSExpressivelyCompleteOverPrior → kampPriorExpressiveCompleteness →
  nfCharacterizableTemporalPrior → nf_nvar_exist_all_depths`. It includes Reynolds' `good` /
  `VeryGood` / `ContempEquiv` vocabulary, `KEquiv`, `truth_transfer`, and Doets 1989 Lemma 1.4
  (`doets_lemma_1_4`, `WeakCanonical/OrderedSum.lean`).
- The bimodality objection — "Doets' theorem is about monadic FO over a *linear order*, but TM is
  bimodal" — is **already solved in the tree**. `mkSigFrom φ` builds a finite monadic signature
  from `φ.predFormulas` (atoms **and box-subformulas** as unary predicates) and
  `countermodel_discrete_reynolds_v2` packages the modal dimension as `WorldState = FamIdx × ℤ`
  with `multiFamOmega` shift-closed (`multiFamOmega_shiftClosed`). A bimodal TM countermodel is
  already transferred through a monadic-FO `≡ₖ` argument in this repository.

The `.Discrete` instance is Reynolds' **Theorem 9** (§10, printed pp.190-191) — the discrete
counterpart of Doets' theorem. It is the worked example of the exact argument v7 must run at
`.Dedekind`.

### The honest cost, stated without softening

The verdict's own adversarial pass attacked "expressive completeness is available" and **the attack
succeeded**; the verdict was amended and an "already 60-70% done" framing was deleted as
overclaiming. This plan carries the amended statement:

**The landed expressive-completeness theorem is vacuous on dense flows.** `SemanticPriorUZ`
(`WeakCanonical/PriorDefs.lean:28`, read verbatim at this revision) says:

```lean
abbrev SemanticPriorUZ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop :=
  ∀ (t : M.carrier) (ψ : Formula),
    (∃ s : M.carrier, t < s ∧ TemporalTruth M atomMap s ψ) →
    ∃ s : M.carrier, t < s ∧ TemporalTruth M atomMap s ψ ∧
      ∀ r : M.carrier, t < r → r < s → TemporalTruth M atomMap r ψ.neg
```

— *every future occurrence of `ψ` has a **first** occurrence, with `¬ψ` strictly between*. That is
Reynolds' **Prior-UZ** (`Fp → U(p,¬p)`, §10, the *integer* axiom), and it is **false on any dense
flow**: take `ψ` true throughout `(t,∞)`. So `uSExpressivelyCompleteOverPrior` cannot be applied at
`.Dedekind` as it stands, and neither can anything downstream of it.

The tree already knows this and says so precisely
(`WeakCanonical/Kamp/DedekindINF.lean`, module docstring, read verbatim at this revision). Its
strengthening chain is

```
Rabinovich's Dedekind completeness  <  HasDedekindINF  <  HasDefinableINF  <  HasAttainedINF
                                       ^ defined there                       ^ what is LANDED
```

with the warning *"An over-strong hypothesis passes sorry-free, axiom-clean and EXIT 0 exactly as a
vacuous conclusion does — the pattern that recurred three times undetected in this development."*
The re-base is **deferred, not abandoned**, with three named targets at `DedekindINF.lean:87-103`
(Lemma 5.3 → Lemma 5.1 → Prop 4.2). And `prior_hasDedekindINF` (`DedekindINF.lean:232`) is
currently derived **from `prior_hasAttainedINF` (`PriorINF.lean:230`), which consumes
`SemanticPriorUZ`** — so it, too, is unusable on a dense flow as landed. Both halves of the re-base
are real work.

### What v7 does, item by item

1. **The route is (b): Burgess-Xu rational model → Prior structure → Doets' theorem → real flow.**
   Reynolds §3, printed p.171, verbatim: *"Both proofs then finish off by applying a result of Kees
   Doets in [4] for finding a real-flowed model of the formula."* The decisive structural fact,
   and the reason this route does not incur the obligation that killed R3d: **at no point does
   Reynolds insert points at gaps of the rational model.** The real structure is a *different*
   structure, only `≡ₖ`-equivalent, with `k` chosen from the single formula. No analogue of
   `BFMCS.LimitGuardEventual` ever arises.
2. **Ten v6 sections are superseded**, exactly the ten `reports/07` §4 names. The mapping is written
   out in "Superseded v6 sections" below so a reader can audit that none was quietly dropped.
3. **Phases 1 and 2 survive whole and are the base.** The pinned
   `consequence_completeness_dedekind_of_engine` signature (`StrongCompleteness.lean:274-279`,
   commit `bd9ae0ac1`) carries forward **byte-identical**. Phase 30 instantiates it; no phase
   restates it. **There is no conditional terminus.**
4. **The rational chronicle survives whole and is the single largest reused asset.**
   `Chronicle.cantorBfmcsDense` plus `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc` **is**
   Reynolds' §4 Corollary 1 — the rational-flowed model with all axiom instances valid. The Doets
   route consumes it as step 1 and stops there.
5. **`Axiom.sep` becomes load-bearing for the first time on this task**, as Reynolds Theorem 5
   (§7). It has been present and sound since before this task and has been consumed nowhere.
6. **Phases 3-7.9 are amputated as forward road and retained in-tree as record.** Nothing is
   deleted or reverted. See the Amputated Assets table and the standing constraint against ripping
   it out — which is not sentiment: the ω-chain's subtype now *carries* a `NoGuardAccumulation`
   component (`ChronicleConstruction.lean:283`), so the amputated arc is threaded through a live
   construction and removing it is a large, risky refactor with **zero** benefit to the terminus.
7. **The honesty charter's scope is inverted for this route, and this is the single most important
   editorial change in v7.** On the completion route the construction had **no source** and every
   docstring had to say so. On the Doets route the construction **has a source** — Reynolds 1992
   §5-§9 and Doets 1987 3.3.9 — and every docstring must **cite it faithfully**, by theorem/lemma
   number and printed page. The no-source statement is now reserved for the genuinely original
   parts, which are named exhaustively in the charter below. A docstring that carries a
   "no source in the corpus" statement on a declaration that transcribes Reynolds Lemma 5 is now a
   defect in the opposite direction.
8. **`ChronicleTypes.lean` and `ChronicleToCountermodelBasic.lean` stay byte-identical, and on this
   route that is free rather than a constraint.** The Doets route reads the chronicle and writes a
   new bridge module beside it; it never edits it. Same for `cantorIsoDense` and
   `ChronicleConstruction.lean`.
9. **The one unresolved claim in the verdict is moot on this route.** See "The moot claim" below.

### Superseded v6 sections

Every item of `reports/07` §4, with where v7 discharges it. No item is dropped.

| # | v6 section | Disposition in v7 |
|---|---|---|
| 1 | Postmortem Constraint *"Do NOT build any part of the Reynolds transfer route"* (≈L820-826) | **REVERSED.** Its premise is refuted by `uSExpressivelyCompleteOverPrior`. Replaced by the *real* constraint: the landed theorem is pinned at a hypothesis vacuous on dense flows and may not be applied at `.Dedekind` until re-based. See Postmortem Constraints, first bullet |
| 2 | Preserved Assets *"Explicitly NOT touched"* list (≈L767-771) | **REVERSED for three rows.** `WeakCanonical/EFGames/**`, `Kamp/**`, `MonadicFO.lean` and `IntegerModel/**` move from *not touched* to **primary machinery and template**. `Transfer.lean:1242` stays untouched and out of scope |
| 3 | Postmortem Constraint *"Do NOT use `countermodel_discrete_reynolds_v2` as a template"* (≈L849-852) | **REVERSED WITH A NARROWING.** Its objection is about the *statement* (hard-coded `.Discrete`, `SuccOrder`/`PredOrder`/`IsSuccArchimedean` in the existential); the *method* — `mkSigFrom` + multi-family `≡ₖ` transfer + `multiFamOmega` — is exactly the template. `countermodel_dense_enriched` remains the template for the terminus plumbing |
| 4 | Phase 7.2 RESOLUTION *"R2 eliminated on source evidence"* (≈L3006-3016) and the fallback ladder's R2 clause (≈L3120-3128) | **REWRITTEN.** R2 was eliminated solely by item 1's false clause. With that corrected, **R2 is live and is the elected route**. The verbatim Reynolds quotations in those blocks are correct and are carried into this plan's Source-to-Implementation Mapping, where they now read as a route *specification* rather than a prohibition |
| 5 | Source-to-Implementation Mapping rows at ≈L784, L790, L799, L803 | **RE-MAPPED.** Reynolds §6 Theorem 4 → Phases 17-22; §7 Theorem 5 → Phase 23 (first consumer of `Axiom.sep`); §8 Theorem 6 → Phases 24-29. None is "constraint check — nothing built" any more; none is "FORBIDDEN" |
| 6 | Goals & Non-Goals (≈L1355) and the Risk block (≈L1345-1357) | **REWRITTEN.** "requires the EF / modal-depth machinery the Postmortem Constraints forbid and that killed R2" is removed; that machinery is now the route |
| 7 | Risk block at ≈L1460-1475 | **PROMOTED.** Its closing sentence — *"Reynolds … routes through contemporaneous equivalence classes, Doets' theorem and `Axiom.sep` — **not** through a Dedekind completion of a rational chronicle"* — was correct and prescient. It is now the route statement in the Overview |
| 8 | R3d umbrella charter (≈L3501) and Phases 7.5-7.9 | **ROUTE RETIRED**, citing `noGuardAccumulation_not_implied_by_limit_data`. The `[COMPLETED]` markers on 7.5-7.8 describe landed sorry-free Lean and stand as v6's record; 7.9 stays `[BLOCKED]` and is this plan's postmortem exhibit. v7 does not re-adjudicate any v6 marker |
| 9 | Phase 8 (≈L4305-4430) | **ABSORBED INTO PHASE 30.** Its precondition — the discharge of `BFMCS.LimitGuardEventual` — is replaced by the Doets-route engine precondition. **The `consequence_completeness_dedekind_of_engine` pinned signature and commit `bd9ae0ac1` carry over unchanged. This is the one thing v7 does not touch** |
| 10 | Overview (≈L619-640), phase count (≈L78-84), Revision Rationale | **REPLACED** by this file's Overview, the 22-phase count, and this Revision Rationale, which states plainly that Phases 3-7.9 become dead weight and that the trigger was a factual error in v6's own Postmortem Constraints |

### The moot claim

`reports/07` records exactly one load-bearing claim resting on unformalized reasoning: the
two-sided-accumulation defeat of `prior_S_gap` is **hand-checked, not formalized**, at Phase 7.9 and
again in the verdict. Formalizing it would need a `ℚ`-flow semantics module the tree does not have.

**It does not need formalizing on the Doets route, and it is not scheduled.** The reason is
structural, not budgetary: `BFMCS.LimitGuardEventual` is an obligation that arises *only* when one
inserts points at gaps of the rational order. The Doets route never does that (Reynolds §3, printed
p.171; §9, printed p.189: *"We have a temporal structure `R`, with flow of time the reals,
satisfying the same monadic sentences of quantifier depth at most `k` as `M` does"* — a **different**
structure, not a completion). No phase of v7 states, consumes, or discharges `LimitGuardEventual`,
so nothing in v7 depends on whether `prior_S_gap` defeats the two-sided pattern.

The claim's residual value is **postmortem only**: if it were wrong, route (a) might be *revivable*.
That does not change the verdict — (b) is the faithful route regardless of whether (a) is merely
unknown or actually dead — and re-opening (a) is prohibited by the Postmortem Constraints below.

---

## Overview

The terminus pair is `consequence_completeness_dedekind : SemanticConsequenceDedekindDense Γ φ →
Derivable FrameClass.Dedekind Γ φ` with `completeness_dedekind` — the class headline, weak
completeness — as its `Γ = []` instance. Both are obtained by instantiating the **already landed
and pinned** `consequence_completeness_dedekind_of_engine` (`StrongCompleteness.lean:274`), whose
engine binder is

```lean
(engine : ∀ ψ : Formula, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ)
```

— **per formula**, which is exactly the shape Reynolds' Theorem 7 produces (`k` is chosen from the
single formula's table). Nothing about the Doets route requires a uniform model and nothing about
the engine asks for one.

**The route, from the source.** Reynolds 1992 §9, Theorem 7, printed p.189, verbatim:

1. *"First use Burgess–Xu Corollary 1 to furnish us with a structure `M₀` such that 1. the flow of
   time of `M₀` is the rationals, 2. `M₀ ⊨ A₀(0)` and 3. all substitution instances of the axioms
   Prior-U, Prior-S and Sep are valid in `M₀`."*
2. *"By ignoring all the atoms which don't appear in `A₀` we have a temporal structure `M` from a
   finite language. `M` is still a model of `A₀`."*
3. *"The flow of time of `M` is countable, dense and without end points and D1 and D2 follow from
   the theorems 4 and 5. Thus we can apply Doets' theorem."*
4. *"Let `k` be one greater than the quantifier depth of the table `α(t)` of `A₀`. We have a
   temporal structure `R`, with flow of time the reals, satisfying the same monadic sentences of
   quantifier depth at most `k` as `M` does."*
5. *"Thus `R` like `M` is a model of `∃t α(t)`. Say `b ∈ R` and `R ⊨ α(b)`. We have `R ⊨ A₀(b)` as
   promised."*

Step 1 is **already landed** (`cantorBfmcsDense` and its three coherence theorems). Steps 3-5 are
the content of Phases 9-30.

**Definition of done**: `FormalSystem/Metalogic/StrongCompleteness.lean` contains a sorry-free
`consequence_completeness_dedekind` with `completeness_dedekind` as a corollary; full `lake build`
green; `#print axioms consequence_completeness_dedekind` shows exactly
`[propext, Classical.choice, Quot.sound]`.

### Programme scale and the phase-count ceiling

**This plan deliberately exceeds the hard-mode phase-count ceiling of 8, and the deviation is
declared rather than smuggled.** The ceiling exists to stop plans inflating either phase *count* or
phase *size* rather than admitting scope. Here the opposite discipline is applied: **phase size is
held to one bounded, independently verifiable unit each** (H8's primary criterion), and the count
is whatever that discipline produces. Compressing 22 bounded units into 8 phases would mean six
phases of ~1000 lines apiece with open-ended attempt surfaces — the exact failure mode
(research-grade work, small in lines, unbounded in attempts) that consumed dispatches earlier in
this task.

The evidence for the scale is measured, not guessed. The `.Discrete` counterpart of this route —
Reynolds Theorem 9, which needs only D1 and gets it by a *discreteness shortcut* unavailable here —
cost **2215 lines** in `IntegerModel/GoodStructuresModelSurgery.lean` and **1155 lines** in
`IntegerModel/ReynoldsBridge.lean`. The dense case additionally needs D2 (§7), the full §6
bad-interval argument with no shortcut, Doets' shuffle, and an order-theoretic characterization of
`ℝ` that Mathlib does not contain.

**Consequence for dispatch.** Each phase below is one agent run. Phases are grouped into five
labelled blocks; a block boundary is a natural checkpoint at which the orchestrator may stop with
the task at `[PARTIAL]` and a fully honest state, because every phase ends with the tree green and
the live sorry count unchanged. If the orchestrator's budget runs out mid-programme, that is a
`[PARTIAL]` with a named next phase, **not** a blocker.

| Block | Phases | Content | Source |
|---|---|---|---|
| **D** | 9-14 | Expressive completeness of `{U,S}` at the **dense** Prior carrier | Reynolds §5 Thm 3; Rabinovich Lemma 5.3 / 5.1 / Prop 4.2 |
| **E** | 15-16 | The dense monadic bridge: chronicle → `OrderedMonadicStructure` over `ℚ`, with Prior-U/Prior-S/Sep semantically valid | Reynolds §4 Cor 1, §9 steps 1-2 |
| **F** | 17-22 | **D1** — `∼`-classes do not end at gaps, on a dense Prior structure | Reynolds §6 Lemmas 2-9, Theorem 4 |
| **G** | 23 | **D2** — `Sep` ⇒ dense set of singleton classes | Reynolds §7 Theorem 5 |
| **H** | 24-29 | Doets' Theorem: `D1 + D2 ⇒ ∀k` an `ℝ`-flowed `≡ₖ` structure | Reynolds §8 Lemmas 11-13 + shuffle; Doets 1987 **3.3.9** |
| **I** | 30 | The engine and the terminus | Reynolds §9 Theorem 7 |

### Preserved Assets

The following work is complete, verified, and must not regress. No phase rewrites, generalizes, or
"cleans up" any row. Line anchors are as of this revision's reading of the tree; an implementer who
finds an anchor stale must re-locate by name and record the drift, never edit the target.

| Component | File / Anchor | Status | Verified |
|---|---|---|---|
| **`consequence_completeness_dedekind_of_engine`** (`:274-279`), `completeness_dedekind_of_engine` (`:308`), `soundness_dedekind_consequence` (`:292`), `SemanticConsequenceDedekindDense` (`:128`), `truthAt_foldr_imp`, `semantic_deduction_dedekind_dense`, `derivable_foldr_imp_iff` | `Metalogic/StrongCompleteness.lean` (342 lines) | [COMPLETED] landed by v6 Phase 2, commit `bd9ae0ac1`. **The terminus, untouched. The `consequence_completeness_dedekind_of_engine` signature is pinned and may not be restated, reordered or re-bound** | 2026-07-28 |
| `real_lub_of_bddAbove` (`:127`), `dedekind_box_dense_mem` (`:149`), the `CarrierProbe` examples (`:71-117`) | `Metalogic/BXCanonical/CompletenessDedekind.lean` (166 lines) | [COMPLETED] landed by v6 Phase 1. The `D := ℝ` instantiation facts Phase 30 still needs | 2026-07-28 |
| `ValidDedekindDense` | `Semantics/Validity.lean:255` | [COMPLETED] carries the lub property as an explicit `Prop` hypothesis; binder list matches `SemanticConsequenceDedekindDense` exactly except the trailing context hypothesis | 2026-07-28 |
| **`Chronicle.cantorBfmcsDense`** (`:552`), `rootedCantorFmcsDense` (`:500`), `rooted_cantor_fmcs_dense_at_s` (`:513`), `cantor_bfmcs_dense_restricted_tc` (`:629`), `_buc` (`:680`), `_fuc` (`:755`) | `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` (1222 lines) | [COMPLETED] **The single largest reused asset. This *is* Reynolds' §4 Corollary 1.** `(fc : FrameClass)` explicit, carrier `Rat`. `_tc` alone carries the extra deferral-closure binder. **Stays at `Rat`; file stays byte-identical** | 2026-07-28 |
| `limit_F_resolution` (`:771`), `limit_satisfies_c4` (`:825`), `limit_satisfies_c4'` (`:861`), **`limit_satisfies_c5_strong`** (`:1531`), **`limit_satisfies_c5'_strong`** (`:1575`), `omegaChain` (`:283`), `omega_chain_c0` (`:308`), `omega_chain_c2'` (`:315`) | `BXCanonical/Chronicle/ChronicleConstruction.lean` (1613 lines) | [COMPLETED] the rational chronicle's exported data. Both `_strong` forms conclude in `LimitG`. **File stays byte-identical** | 2026-07-28 |
| `cantorIsoDense`, `cantorZeroDense`, `CantorFDense` | `BXCanonical/Chronicle/` | [COMPLETED] not a lever, not edited, out of scope on this route as on the last | 2026-07-28 |
| **`uSExpressivelyCompleteOverPrior`** | `WeakCanonical/PriorExpressiveness.lean:357` (file 372 lines) | [COMPLETED] sorry-free, `[propext, Classical.choice, Quot.sound]`. **Pinned at `SemanticPriorUZ`/`SemanticPriorSZ`, which are FALSE on dense flows — Block D re-bases it and does not edit this declaration** | 2026-07-28 |
| `stavi_U_false_on_prior_UZ` (`:90`), `stavi_S_false_on_prior_SZ` (`:143`), `flatten_stavi_correct_prior` (`:211`) | `WeakCanonical/PriorExpressiveness.lean` | [COMPLETED] sorry-free. Reynolds Theorem 3's Stavi-falsity step **at the integer axioms**; the structural template for the dense mirror, and the reason Block D's target is reachable | 2026-07-28 |
| `StaviUTruth` (`:79`), `StaviSTruth` (`:110`), `StaviFormula` (`:140`), `StaviTemporalTruth` (`:162`), `flattenStavi` (`:446`), `flatten_stavi_correct` (`:497`) | `WeakCanonical/StaviConnectives.lean` (583 lines) | [COMPLETED] sorry-free. The Stavi layer is **present and clean**; only the GHR93 Theorem 9.3.1 chain top is absent (see the fallback route in Rollback) | 2026-07-28 |
| `SemanticPriorUZ` (`:28`), `SemanticPriorSZ` (`:39`) | `WeakCanonical/PriorDefs.lean` (47 lines, sole import `WeakCanonical.Table`) | [COMPLETED] the **integer** Prior axioms. **Not edited.** This module is the tree's deliberate import-cycle breaker (7 live importers); Phase 9's dense siblings go in a **new** module, not here | 2026-07-28 |
| `HasDedekindINF` (`:136`), `HasDedekindSUP` (`:153`), `HasAttainedINF.toHasDedekindINF` (`:172`), `HasDefinableINF.toHasDedekindINF` (`:185`), `hasDedekindINF_admits_kplus_shape`, `prior_hasDedekindINF` (`:232`), `prior_hasDedekindSUP` (`:240`) | `WeakCanonical/Kamp/DedekindINF.lean` (291 lines) | [COMPLETED] sorry-free, CI-protected via the `NfMultiAnchorBridge` import edge. **The faithful Rabinovich eq (5.2) carrier already exists.** `prior_hasDedekindINF` is a one-liner `(prior_hasAttainedINF M atomMap h_UZ).toHasDedekindINF` and therefore routes through `SemanticPriorUZ`; Phase 10 adds the dense derivation beside it and edits neither | 2026-07-28 |
| `HasDefinableINF` (`:114`), `HasDefinableSUP` (`:127`), `HasAttainedINF` (`:208`), `HasAttainedINF.toHasDefinableINF` (`:221`), **`prior_hasAttainedINF` (`:230`)** | `WeakCanonical/Kamp/PriorINF.lean` (296 lines) | [COMPLETED] sorry-free. **Anchor correction**: these live here, **not** in `DedekindINF.lean`. `DedekindINF.lean`'s own docstring has line-reference drift (it cites `PriorINF.lean:224` for `prior_hasAttainedINF` and `:108` for `HasDefinableINF`); do not propagate those numbers | 2026-07-28 |
| `kampPriorExpressiveCompleteness` (`KampPrior.lean:672`), `nf_nvar_exist_all_depths` (`KampPrior.lean:363`), `nfCharacterizableTemporalPrior` (`KampPrior.lean:589`), the whole `Kamp/EANegationFix/` and `Kamp/NfMultiAnchorBridge/` trees | `WeakCanonical/Kamp/**` (`KampPrior.lean` 1834 lines) | [COMPLETED] sorry-free. **Promoted from "explicitly NOT touched" (v6) to primary machinery.** Block D re-bases three named entry points; everything else is consumed as landed. Note `nf_nvar_exist_all_depths` carries the domain restriction `hn : n ≤ 1` (the arity-`n≥2` arm is excluded) — Block D inherits that restriction and must not silently widen it | 2026-07-28 |
| `doets_lemma_1_4` | `WeakCanonical/OrderedSum.lean:41` (file 52 lines) | [COMPLETED] sorry-free. **Doets 1989 Lemma 1.4 = Reynolds §8's "lexicographic sums of `k`-equivalent structures are themselves `k`-equivalent"** — same index set `I`, pointwise `KEquiv`. Consumed directly by Phases 24, 26, 29 | 2026-07-28 |
| `KEquiv` (`:81`), `kTypeOf` (`:72`), `KType` (`:61`) | `WeakCanonical/NEquivalence.lean` (1315 lines) | [COMPLETED] the `≡ₖ` relation (`kTypeOf` equality) and its game/Karp-sequence apparatus | 2026-07-28 |
| `good` (`:78`), `VeryGood` (`:86`), `ContempEquiv` (`:729`), `no_boundary_at_successor` | `WeakCanonical/IntegerModel/GoodStructures.lean` (881 lines) | [COMPLETED] sorry-free **at the `ℤ`-interval instance, and the discreteness is in the definitions, not only in their consumers**: `good` is `∃ Z : ZIntervalStructure sig, KEquiv sig k M (Z.toOrdered sig)` and `VeryGood` quantifies over **closed** `a ≤ b`. Reynolds' dense forms use *open* real intervals (printed p.186). **The vocabulary and the template**; Block H builds genuinely new `ℝ`-interval siblings beside them | 2026-07-28 |
| `truth_transfer` (`:361`), **`mkSigFrom` (`:134`)** | `WeakCanonical/Transfer.lean` (1244 lines) | [COMPLETED] both sorry-free. **Anchor correction**: `mkSigFrom` lives here, not in `ReynoldsBridge.lean`. **This file also carries the repository's single live sorry, at `:1242`, in an unrelated declaration** — importing it is fine and already universal; attempting `:1242` is out of scope | 2026-07-28 |
| `Formula.predFormulas` | `Syntax/Formula.lean:778` | [COMPLETED] `atom a ↦ {atom a}`, `box φ ↦ {box φ} ∪ φ.predFormulas`, and structurally through `imp`/`untl`/`snce`. **This is the bimodal encoding: box-subformulas become unary monadic predicates** | 2026-07-28 |
| `reynolds_model_surgery_core` (`:2102`), `gap_prior_UZ_contradiction` (`:1209`), `gap_prior_SZ_contradiction`, `gap_contradicts_prior` (`:2132`), `gap_contradicts_prior_below` (`:2152`), `no_gaps_discrete_model_surgery` (`:2180`) | `WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (2215 lines) | [COMPLETED] sorry-free (the module docstring's "SORRY" markers at `:26-35` are **stale** — the tree's only live sorry is `Transfer.lean:1242`). **Reynolds Theorem 4 at the discrete instance, and the measured cost baseline for Block F** | 2026-07-28 |
| `multiFamTaskFrame` (`:671`), `multiFamHistory` (`:683`), `multiFamOmega` (`:694`), `multiFamOmega_shiftClosed` (`:708`), **`countermodel_discrete_reynolds_v2`** (`:739`) | `WeakCanonical/IntegerModel/ReynoldsBridge.lean` (1155 lines) | [COMPLETED] sorry-free, `[propext, Classical.choice, Quot.sound]`. **The bimodal encoding, already solved**: `multiFamTaskFrame FamIdx : TaskFrame ℤ` with `WorldState := FamIdx × ℤ` and `TaskRel p d q := p.1 = q.1 ∧ q.2 = p.2 + d`. The `ℤ` is a **carrier parameter, not a discreteness assumption** — the definition generalizes to any `D` by substitution, which is the R7 gate Phase 15 verifies | 2026-07-28 |
| `NormalForm` (`:146`) and its `base`/`step`/`atomAssgn`/`quantAssgn` (`:151`,`:156`,`:163`,`:169`) | `WeakCanonical/NormalForm.lean` (873 lines) | [COMPLETED] the `≡ₖ`-type / characteristic-formula layer Reynolds §8 Lemma 12's finite `γ`-set needs | 2026-07-28 |
| `Axiom.prior_U_gap` (`:377`), `Axiom.prior_S_gap` (`:387`), **`Axiom.sep`** (`:390-401`, the inductive's last constructor), `minFrameClass` block (`:524`) | `ProofSystem/Axioms.lean` | [COMPLETED]. `prior_U_gap`/`prior_S_gap` each carry an explicit "THIS IS NOT `prior_UZ`/`prior_SZ`" caveat at `:374-376`/`:385-386` — the same distinction Block D is about. **`sep` becomes load-bearing for the first time in Phase 23** | 2026-07-28 |
| **`sep_valid`** (`:1601`), its `sep` dispatch (`:1782`), `soundness_dedekind` (`:1910`) | `Metalogic/Soundness.lean` | [COMPLETED] sorry-free. **`sep_valid` is stated directly at `ValidDedekindDense`** — exactly the predicate this task's terminus uses, so Phase 23 needs no soundness work and Reynolds' Lemma 10 is not re-derived | 2026-07-28 |
| `countermodel_dense_enriched` (`:133`), `neg_consistent_of_not_derivable` (`:72`), `completeness_dense` (`:255`), `completeness_discrete` (`:296`), the audit chain at `:381-383` | `Metalogic/BXCanonical/Completeness.lean` (417 lines) | [COMPLETED] `countermodel_dense_enriched` is the **terminus-plumbing template**; the two completeness theorems are read as templates and left byte-identical | 2026-07-28 |
| `fully_restricted_parametric_completeness_from_neg_membership` (`:417`), binders `(B) (root) (h_rtc) (h_buc) (h_fuc) (φ) (h_sub) (fam) (hfam) (t) (h_neg_in)` | `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (434 lines) | [COMPLETED] binders `{fc} {D} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` — no `DenselyOrdered`, no `Rat`. **Accepts `D := ℝ` unchanged** | 2026-07-28 |
| `ParametricCanonicalTaskFrame`/`TaskModel`/`parametricToHistory`/`ShiftClosedParametricCanonicalOmega`; `BFMCS`/`FMCS`; the six coherence predicates | `Metalogic/Algebraic/**`, `Metalogic/Bundle/BFMCS.lean:91`, `Bundle/FMCSDef.lean:103`, `Bundle/TemporalCoherence.lean` | [COMPLETED] generic in `D` and `fc` | 2026-07-28 |
| `set_lindenbaum`, `SetMaximalConsistent.*`, `theorem_in_mcs` (`:491`), `conj_mcs`, `deductionTheorem`/`deductionConverse`, `self_mem_subformulaClosure` (`:42`), `soundness_dedekind` (`:1910`) | `Metalogic/Core/**`, `Syntax/SubformulaClosure/Closure.lean`, `Metalogic/Soundness.lean` | [COMPLETED] generic in `fc`; step 0 of any route | 2026-07-28 |

### Amputated Assets

The following is **landed, sorry-free, axiom-clean Lean that is retired as forward road**. It stays
in the tree, it stays compiling, and it is not deleted, reverted or refactored. This table exists so
that no future dispatch mistakes a compiling declaration for a live obligation.

| Asset | Landed by | Disposition |
|---|---|---|
| `limitSetBelow`/`Above` + 10 lemmas; `limitMCSBelow`, `limitMCSBelow_cofinal_below`, `limitMCSLindenbaum*` (+14) — `Bundle/LimitMCS.lean` (482 lines) | v6 Phases 3-4 | **Retired.** The `ℝ`-completion of the rational order is not performed on this route |
| The 11 `LimitMCSCoherence` case lemmas — `Bundle/LimitMCSCoherence.lean` (328 lines) | v6 Phases 5-6 | **Retired** |
| `realLimitMCS*`, `FMCS.toReal*`, `BFMCS.toRealBundle` (both modal fields), `toRealBundle_restricted_temporally_coherent` — `Bundle/RealExtension.lean` (240), `Bundle/RealExtensionBundle.lean` (433) | v6 Phases 6, 6.1 | **Retired** |
| `limitFutureWitness_of_priorU`, `limitGuardBelow_of_priorS`, `limitGuardAbove_of_priorU`, `boundedWitness_of_limitGuardBelow` and their `cantor_bfmcs_dense_*` instances — `ChronicleLimitGapWitness.lean` (221), `ChronicleLimitGuardWitness.lean` (217), `ChronicleLimitGuardAbove.lean` (224) | v6 Phases 6.2, 6.3, 7.3, 7.4 | **Retired as route.** Individually they are correct, sourced Prior-U/Prior-S consequences and are the best evidence in the tree that the axioms behave as Reynolds says. Keep as record |
| `BFMCS.LimitFutureWitness`, `BFMCS.LimitGuardBelow`, **`BFMCS.LimitGuardEventual`** | v6 Phases 6.2, 6.3, 7.4 | **Retired.** `LimitGuardEventual` is the obligation this route exists to avoid. **No phase of v7 states, consumes or discharges it** |
| `toRealBundle_forward/backward_until_since` and the ~17 supporting declarations — `ChronicleRealExtension.lean` (1159 lines) | v6 Phases 7.1′, 7.2, 7.4 | **Retired** |
| All of `ChronicleGuardAccumulation.lean` (812 lines) — `NoGuardAccumulation`, `AscendsToGap`, `CofinalBelowGap`, `limitGuardEventual_of_noGuardAccumulation`, `noGuardAccumulation_transport`, `guardAccumFamily_*` | v6 Phases 7.5, 7.9 | **Retired as machinery.** **`noGuardAccumulation_not_implied_by_limit_data` must be retained**: it is the machine-checked record of *why* the completion route was abandoned and the closing argument of this task's postmortem |
| The `NoGuardAccumulation` component of `omegaChain`'s subtype (`ChronicleConstruction.lean:283`), `singleton_no_guard_accumulation`, `EliminationResult.guard_accum_preserved`, and the 7.6/7.7 preservation material in `CounterexampleElimination.lean` (3897 lines) | v6 Phases 7.5-7.8 | **Retired but STRUCTURALLY LIVE.** Unlike every other row this one is threaded *through* the construction: `omegaChain`'s subtype carries it as a third component. It must keep compiling. **Do not attempt to strip it** — see the standing constraint |

**Net**: v6 Phases 1 and 2 and the rational chronicle survive whole. v6 Phases 3 through 7.9 — the
entire `ℝ`-extension-by-limits layer, roughly 4100 lines across ten modules — become dead weight.
That is a large amputation and this plan says so rather than presenting the Doets route as
continuous with v6.

### Drafted-but-archived target: `doets_lemma_1_5`

Distinct from both tables above, and a decision-grade find of this revision: **the tree already
contains a drafted statement of the one lemma Phase 27 needs, archived with a `sorry`, and its own
archive header names the dense case as the reason it exists.**

`FormalSystem/Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean:58`:

```lean
theorem doets_lemma_1_5 (sig : MonadicSignature) (k : Nat) (I J : Type)
    [LinearOrder I] [LinearOrder J]
    (m : I → OrderedMonadicStructure sig) (m' : J → OrderedMonadicStructure sig)
    (_h_matching : ∀ (τ : KType sig k),
      (∃ i, k_type_of sig k (m i) = τ) ↔ (∃ j, k_type_of sig k (m' j) = τ)) :
    k_equiv sig k (orderedSum sig I m) (orderedSum sig J m') := by
  sorry
```

Its archive header (`:19-24`) reads: *"`doets_lemma_1_5` (1 sorry) — type-matching ordered-sum
k-equivalence (Doets 1989 Lemma 1.5). Not on the discrete completeness critical path; bypassed in
the discrete case by the one_class argument. **Required only for the dense case (future work).**
The live `doets_lemma_1_4` is NOT part of this excision and remains in live code."*

**Status, verified three ways: it is NOT built and cannot be reused as-is.**

1. The file carries `#exit` at line **41**, before the declaration at line 58 — nothing after it
   elaborates.
2. `lakefile.lean:16-19` declares `lean_lib FormalSystem where roots := #[`FormalSystem]`, and no
   live file imports `FormalSystem.Boneyard.*`.
3. Its statement uses **stale names** (`k_type_of`, `k_equiv`) that no longer exist; the live names
   are `kTypeOf` (`NEquivalence.lean:72`) and `KEquiv` (`:81`). It would not typecheck today.

**Bearing on the plan.** `doets_lemma_1_5` — *ordered sums over **different** index sets with the
same set of realized `k`-types are `k`-equivalent* — is precisely Reynolds' unproved one-liner at
printed p.188 (*"Another simple game argument can be used to show that we can mix into a shuffle
many more copies of the same structures without disturbing `k`-equivalence"*) and precisely Doets
1987 **3.1.8**. **Phase 27 is chartered to land it in live code, under the live names, with the
`sorry` discharged.** The archived draft is a *statement template*, not a proof, and the plan treats
it as such. The forward pointer at `OrderedSum.lean:20-22` should be updated when it lands.

### Source-to-Implementation Mapping (H3, Tier 1 — literature-backed)

Cite by **printed page** in every Lean docstring. Never cite chunk-relative `md:NN` line numbers.
The page-offset for Reynolds 1992 is PDF page `i` ↔ printed `164 + i`. **Printed-page attributions
in this table are carried from `reports/07` §1.1, which read the corpus verbatim; an implementer
must re-verify the printed page against the PDF before landing it in a docstring**, and record any
correction in the phase's summary.

| Source | Location (printed page) | Lean identifier (target) | Statement used | Phase |
|---|---|---|---|---|
| Reynolds 1992 | §5 Thm 3, **p.176** | `SemanticPriorU` / `SemanticPriorS` (new) | *"Call a linear temporal structure a Prior structure if it satisfies all substitution instances of Prior-U and Prior-S. It is easy to see that then there are no definable gaps. Note that this result does not hold for the original Prior axioms in the language of `F` and `P`."* | **9** |
| Reynolds 1992 | Prior-U / Prior-S, **p.168** | `Axiom.prior_U_gap` (`:377`), `Axiom.prior_S_gap` (`:387`) — consumed | `Prior-U: U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)`; `Prior-S` dual. `K⁺A = ¬U(⊤,¬A)` | **9, 10, 16** |
| Rabinovich 2014 | Lemma 5.3 Case 2, eq (5.2), **PDF p.8** | **`prior_hasDedekindINF_dense`** (new) | *"let `r₀ = inf{z ∈ (z₀,z₁) | P₁(z)}` … Note that `r₀ = z₀` iff `K⁺(P₁)(z₀)`. If `r₀ > z₀` then `r₀ ∈ (z₀,z₁)` and `r₀` is definable by …"* `INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀} ¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀))`. **`HasDedekindINF`'s left disjunct is literally `K⁺(P)(z₀)` — the same `K⁺` shape as Prior-U's conclusion.** Instantiate `Axiom.prior_U_gap` at `p := ¬P` and eq (5.2) *is* its conclusion | **10** |
| Rabinovich 2014 | Lemma 5.3, **PDF p.8** | `negChainOnFaithful` (re-base of `negChainOn`, `EANegationFix/OnBuilder.lean:149`) | The printed **three**-disjunct `Oₙ₊₁`; the landed version truncates it to two by dropping disjunct (2). Result type must be `VVecEA2`, not `VBracketFormula` | **11** |
| Rabinovich 2014 | Lemma 5.1, **PDF pp.9-10** | re-base of `BracketFormula.negFix_iff` (`EANegationFix/NegFix.lean:669`) | — | **12** |
| Rabinovich 2014 | Prop 4.2, **PDF p.6** | re-base of `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:164`) and `prop42_contentful_of_attained` | — | **13** |
| Reynolds 1992 | §5 Thm 3 proof, **p.176** | `uSExpressivelyCompleteOverDensePrior` (new) | *"By the expressive completeness of `{U,S,U',S'}` over all linear structures, it suffices to prove that for any `{U,S,U',S'}`-formula `B'` there is a `{U,S}`-formula `B` … Suppose for contradiction that `M ⊨ U'(A,B)(t)` … By Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction."* | **14** |
| Reynolds 1992 | §9 steps 1-2, **p.189** | dense monadic bridge (new module) | *"First use Burgess–Xu Corollary 1 …"*; *"By ignoring all the atoms which don't appear in `A₀` we have a temporal structure `M` from a finite language."* Template: `mkSigFrom`/`predFormulas`/`multiFamTaskFrame` (`ReynoldsBridge.lean`) | **15** |
| Reynolds 1992 | §4 Cor 1, **p.174** | consumes `cantorBfmcsDense` + `cantor_bfmcs_dense_restricted_tc/_buc/_fuc` | *"1. the flow of time of `M` is the rationals, 2. for all `A ∈ Γ`, `M ⊨ A(0)` and 3. all substitution instances of the axioms Prior-U, Prior-S and Sep are valid in `M`."* | **15, 16** |
| Reynolds 1992 | §6, **pp.176-177** | `ContempEquivDense`, `rhoFormula`, `lambdaFormula`, Lemma 2 | The definition of a *contemporaneous equivalence relation* (three clauses); `ρ(x) = ∃y>x ¬ε(x,y) ∧ ¬∃z(x<z ∧ ε(x,z) ∧ ∀y(x<y<z → ε(x,y)))`; *"Now by the expressive completeness of `U` and `S` there is temporal `R` true in any Prior structure exactly where `ρ(x)` is."* | **17** |
| Reynolds 1992 | §6 Lemma 3, **p.177**; Lemma 4 | Lemma 3, Lemma 4 | *"The maximal intervals in which `R` holds are open intervals which, if bounded, have elements of `M` as their (excluded) end points."*; *"There is no last class and no first class in any maximal interval of `R`."* | **18** |
| Reynolds 1992 | §6 Lemma 5, **p.178** | Lemma 5 | *"If a temporal formula holds somewhere in one `∼`-class in a maximal interval of `R`, then it holds somewhere in each `∼`-class in the interval. Furthermore, each pair of the `∼`-classes in a maximal interval of `R` are elementarily equivalent."* | **19** |
| Reynolds 1992 | §6 Lemmas 6-7, **pp.178-179** | Lemma 6, Lemma 7 | *"Bad points only occur in non-singleton bad intervals. In any bad interval both `R` and `L` hold throughout."*; *"If a formula `B` is true for a while at the start of a `∼`-class in a bad interval then it holds throughout the bad interval."* | **20** |
| Reynolds 1992 | §6 Lemma 8, **pp.179-180** | Lemma 8 (bad-interval surgery) | *"For all temporal formulas `A`, for all `t ∈ N`, `M ⊨ A(t)` iff `N ⊨ A(t)`"*, with the seven forward and six backward `U(A,B)` cases written out. In-tree analogue: `truth_transfer` | **21** |
| Reynolds 1992 | §6 Lemma 9 + **Theorem 4**, **≈p.181** | **`no_gaps_dense_prior`** (**D1**) | *"In fact there can't have been any bad points anyway."*; *"Suppose that `∼` is a contemporaneous equivalence relation on a Prior structure `M`. Then the `∼`-classes do not end at gaps."* | **22** |
| Reynolds 1992 | §7 **Theorem 5**, **pp.184-185** | **`dense_singletons_of_sep`** (**D2**) | *"Suppose that `M` is a Prior structure which also satisfies every substitution instance of axiom Sep. Then for every contemporaneous equivalence relation `∼` such that `M/∼` is densely ordered, `M/∼` has a dense set of singletons."* Critical line: *"Let the temporal formula `C` be true exactly at points who are the left hand end points of their classes. … **We use expressive completeness here.**"* | **23** |
| Reynolds 1992 | Sep axiom, **p.168**; Lemma 10, **p.184** | `Axiom.sep` (`:390`) — consumed | `Sep: K⁺p ∧ ¬K⁺(p ∧ U(p,¬p)) → K⁺(K⁺p ∧ K⁻p)`. Landed docstring states it character-for-character. Lemma 10's validity proof is **not** re-derived: soundness is already landed | **23** |
| Reynolds 1992 | §8 Lemma 11, **p.186** | `goodDense`, `veryGoodDense`, `lemma_11_dense` | *"If `N` is countable and very good then it is good."* Proof: choose `aᵢ` cofinal both ways, take `Rᵢ ≡ₖ N|(aᵢ,aᵢ₊₁)` with an open real interval as flow, then `N ≡ₖ Σ_{i∈ℤ}(N|{aᵢ} + Rᵢ)`. Consumes `doets_lemma_1_4` | **24** |
| Reynolds 1992 | §8 Lemma 12, **pp.186-187** | `epsilonDense`, `lemma_12_dense` | *"There is a monadic formula `ε(x,y)` which defines `∼_M` as a contemporaneous equivalence relation on the domain of any `M`. Furthermore, there is a finite set `{γᵢ}` of sentences such that `M` is good if and only if `M ⊨ γᵢ` for some `i`."* with `ε(x,y)` written out via `γ'(z,t) = γ(z,t) ∧ ∃u(z<u<t)`. Discrete analogue: Lemma 15, **p.191** | **25** |
| Reynolds 1992 | §8 Lemma 13, **p.187**; the shuffle, **p.186** | `lemma_13_dense`, `Shuffle` | *"if there are no `∼_M` classes ending at gaps then they are all closed intervals"*; *"Let `π : ℚ → S` be any map such that for any `M ∈ S`, for any `r,s ∈ ℚ`, there is `t ∈ ℚ` with `r<t<s` and `π(t)=M`. We call `Σ_{t∈ℚ} π(t)` the shuffle over `S`."* | **26** |
| Reynolds 1992 | §8, **p.188** | `shuffle_extend_R`, `shuffleFlow_dedekind_complete`, `shuffleFlow_separable` | *"extend `σ` to `σ* : ℝ → {N_γ}` by `σ*(i) = N_{γ₁}` if `i ∈ ℝ − ℚ`. A game will show that `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)`."*; *"In fact `R` is Dedekind complete. This is true because any subset bounded above intersects a last summand."*; *"We can also show that `R` has a countable dense subflow."* | **27** |
| **Doets 1987, 3.1.8** (and Doets 1989 Lemma 1.5) | thesis ch.3 §3.1 | **`doets_lemma_1_5`** — statement drafted in `Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean:58` with a `sorry`, stale names, behind `#exit`; **to be landed in live code by Phase 27** | *"Suppose that `I` and `J` are ordered sets and that `m` and `m'` associate ordered models `m(i)` resp. `m'(j)` to each `i ∈ I` resp. `j ∈ J` such that `(I, {i | m(i) ⊨ σ})_{σ∈Z} ≡ⁿ (J, {j | m'(j) ⊨ σ})_{σ∈Z}`, where `Z` is the set of `n`-characteristics. Then `Σ_{i∈I} m(i) ≡ⁿ Σ_{j∈J} m'(j)`."* **This is the rigorous form of Reynolds' unproved "another simple game argument"**, and the tree's own archive note says it is *"Required only for the dense case (future work)"* | **27** |
| Reynolds 1992 | §8, **p.188** | **`orderIsoRealOfDedekindDenseSeparable`** (new; **no Mathlib equivalent**) | *"But then `R` being Dedekind complete, dense, without end points and with a countable dense subset must be isomorphic to the reals."* Mathlib has `Order.iso_of_countable_dense` (Cantor for `ℚ`) and only *field*-theoretic uniqueness for `ℝ` (`ConditionallyCompleteLinearOrderedField`). **The order-theoretic characterization is absent and must be built** | **28** |
| Reynolds 1992 | §8 **Theorem 6**, **pp.185-188**; Doets 1987 **3.3.9** | **`doets_theorem_dense`** | Reynolds: *"Suppose that `M` is a temporal structure in a finite language whose flow of time is countable, dense and without end points. Suppose further that for any contemporaneous equivalence relation `∼` on `M`, D1) the `∼` classes do not end in gaps and D2) if `M/∼` is densely ordered, then `M/∼` has a dense set of singletons. Then for all `k < ω`, there is a temporal structure with flow of time the real numbers satisfying the same monadic first-order sentences of quantifier depth at most `k` as `M` does."* Doets: *"If `M` is definably-`I`, definably complete and densely ordered without endpoints, then it has `n`-equivalents of order type `λ` for each `n`."* | **29** |
| Reynolds 1992 | §9 **Theorem 7**, **p.189** | **`completeness_dedekind_engine`**, then the pinned `consequence_completeness_dedekind_of_engine` | *"The system US/R is sound and weakly complete for the semantics over structures with real flow."* + the five proof steps quoted in the Overview. `k` = one greater than the quantifier depth of `A₀`'s table | **30** |
| Reynolds 1992 | §2, **p.169** | docstring only | *"It is **weakly** (or **finitely**) **complete** if and only if every finite consistent set of formulas, or equivalently every single consistent formula, is satisfiable."* — the sentence that settles that the Doets route reaches **both** termini. Also: *"in the case of `U` and `S` over the reals, there can be no strongly complete axiomatization … because the compactness property fails"* | **30 (docstring)** |
| Reynolds 1992 | §10 Thm 9, **pp.190-191** | `countermodel_discrete_reynolds_v2` etc. — **template only** | The discrete counterpart of Doets' theorem, already landed. Its D1 uses a **discreteness shortcut** (*"`a`'s class can not end at a gap on the right so it must include a point `c` but not the successor `c+1` … This can not be because `M|[c,c+1]`, like all finite structures, is very good"*) that is **unavailable in the dense case** — which is why Block F is six phases and not one | **(template; 15, 17-22, 24-25)** |
| **NO SOURCE — original work** | — | the chronicle → `OrderedMonadicStructure` dense bridge (15); the `ℝ`-order characterization (28) if no Mathlib route is found; any bimodal encoding step not already discharged by `mkSigFrom`/`multiFamOmega` | These have no counterpart in Reynolds, Doets or Burgess. Their docstrings **must** say so, per the honesty charter | **15, 28** |

---

## Postmortem Constraints

Binding on every implementation dispatch for this task. Derived from the Phase 7.9 refutation, from
`reports/07`'s adversarial verification, and from the accumulated record of five superseded plans.

### Why R3d failed — the digest no phase may re-incur

**The obligation.** v6's route completed the rational chronicle to `ℝ` by inserting a limit MCS at
every unselected real. Forward Until/Since coherence at `ℝ` then required, at every gap `r`, that a
guard `ψ` known to hold *cofinally* below `r` in fact hold *eventually* (on a whole interval)
below `r`. That is `BFMCS.LimitGuardEventual`.

**Why it cannot be discharged.** Three independent findings, each landed or verbatim-sourced:

1. **The construction's data does not entail it.** `noGuardAccumulation_not_implied_by_limit_data`
   is a *theorem*, axiom-clean. The dyadic-approach family satisfies all four exported conditions
   on all of `ℚ` and refutes the invariant. This is not a stuck proof; it is a refutation.
2. **The axioms do not entail it.** All three Dedekind axioms were checked individually against the
   two-sided accumulation and all three are silent (Prior-U is *satisfied* by the pattern; Prior-S
   has no antecedent; Sep's force is a cardinality argument needing failure throughout an interval,
   which one accumulation point escapes). There is no fourth Dedekind axiom.
3. **The literature never incurs it.** Burgess 1984's completion (printed pp.109-110) builds its
   gap MCS from purely existential `Pα`/`Fα` data with **no interval datum at all**, and runs
   entirely in the `¬,∧,G,H` fragment (printed p.116: *"All the systems discussed so far have been
   based on the primitives `~`, `∧`, `G`, `H`"*) — before Until/Since enter the language, so the
   guard obligation cannot even be *posed* in his setting. Reynolds never completes the rational
   order at all.

**The generalization every future phase must carry.** *A guard obligation that arises only because
the construction inserted a point where the literature inserts none is evidence of a wrong route,
not a hard lemma.* The user's no-needless-bridges constraint names exactly this: a step whose only
purpose is to connect two artifacts the tree happens to have.

**Do NOT**:

- **Do NOT re-open completion-by-limits, in any form.** No limit MCS at a gap of a rational
  chronicle, no `ℝ`-extension of `cantorBfmcsDense`, no repair of `NoGuardAccumulation`, no
  invariant carrying MCS-value content about freshly inserted points. It is refuted at the data
  level and unreachable at the axiom level. If a dispatch finds itself proposing one, it has not
  read this section.
- **Do NOT state, consume or discharge `BFMCS.LimitGuardEventual`, `BFMCS.LimitGuardBelow` or
  `BFMCS.LimitFutureWitness`.** They are retired. No phase of v7 mentions them except in prose.
- **Do NOT attempt to formalize the two-sided defeat of `prior_S_gap`.** It is moot on this route
  (see "The moot claim"); formalizing it would need a `ℚ`-flow semantics module and would buy
  nothing. If a future dispatch wants it, that is a new task, not a phase of this one.
- **Do NOT delete, revert or refactor the amputated layer.** Every row of the Amputated Assets
  table stays in the tree and stays compiling. In particular **do NOT strip the
  `NoGuardAccumulation` component out of `omegaChain`'s subtype** (`ChronicleConstruction.lean:283`)
  or out of `EliminationResult`: it is threaded through a live construction, removing it is a large
  refactor across `CounterexampleElimination.lean` (3897 lines), the risk is regression in the
  chronicle this route *depends* on, and the benefit to the terminus is exactly zero. Inert
  compiling code is the correct disposition. **`noGuardAccumulation_not_implied_by_limit_data` in
  particular must be retained** as the machine-checked postmortem exhibit.
- **Do NOT apply `uSExpressivelyCompleteOverPrior`, `kampPriorExpressiveCompleteness`,
  `prior_hasDedekindINF`, `prior_hasAttainedINF`, `no_gaps_discrete_model_surgery`, or any other
  declaration pinned at `SemanticPriorUZ`/`SemanticPriorSZ`, at a dense flow.** They are **vacuous
  there**: `SemanticPriorUZ` demands a *first* occurrence of `ψ` above `t`, which fails whenever `ψ`
  holds on an open right-neighbourhood. This replaces v6's constraint against building the Reynolds
  route, whose stated premise ("absent from this tree") was factually false. **The real constraint
  is vacuity, not absence.** Every Block D phase must therefore ship a non-vacuity witness (see the
  anti-vacuity gate below).
- **Do NOT edit `SemanticPriorUZ` / `SemanticPriorSZ`, `uSExpressivelyCompleteOverPrior`,
  `prior_hasAttainedINF`, `prior_hasDedekindINF`, `no_gaps_discrete_model_surgery`, or
  `countermodel_discrete_reynolds_v2`.** The discrete pipeline is a landed, sorry-free, axiom-clean
  result and `completeness_discrete` depends on it. Block D adds **dense siblings beside** the
  discrete declarations; it does not generalize them in place. A dispatch that "unifies" the two
  has put a working theorem at risk for no gain.
- **Do NOT edit `ChronicleTypes.lean`, `ChronicleToCountermodelBasic.lean`,
  `ChronicleConstruction.lean`, `CounterexampleElimination.lean`, `cantorIsoDense`, `cantorZeroDense`
  or `CantorFDense`.** On this route the chronicle is *read*, never modified: the dense bridge is a
  new module that consumes `cantorBfmcsDense` and its three coherence theorems as landed. The two
  frozen files must be **byte-identical** at the end of every phase, and this is checked in Testing
  & Validation. **v7 asserts positively that the Doets route does not require otherwise** — the
  amendments v6 granted for R3d (permission to alter witness placement inside
  `eliminatePotentialCounterexample` and to extend the stage invariant) are **withdrawn as
  unnecessary**, not merely unused.
- **Do NOT weaken the target to `ValidDedekind`.** `FrameClass.Dedekind` sits above
  `FrameClass.Dense`, so `density` and `dense_indicator` are admissible in a `.Dedekind` derivation
  and both are false on `ℤ`, which is Dedekind-complete. The target is `ValidDedekindDense`.
- **Do NOT make `countermodel_dedekind_dense`, `completeness_dedekind_engine`,
  `consequence_completeness_dedekind`, or `completeness_dedekind` conditional on an undischarged
  predicate.** The single permitted added hypothesis anywhere on that chain is
  `(hfc : FrameClass.Dedekind ≤ fc)`, discharged by `decide` at the instantiation point. **There is
  no conditional terminus.** This constraint is carried from v3 and is not amended by anything in
  v7.
- **Do NOT prove `completeness_dedekind` independently and then strengthen it.** It is
  `consequence_completeness_dedekind []` after `simp` discharges `∀ ψ ∈ [], _`.
- **Do NOT restate, reorder or re-bind `consequence_completeness_dedekind_of_engine`.** Pinned by
  commit `bd9ae0ac1`; Phase 30 instantiates it and nothing else.
- **Do NOT emit a vacuous definition** (`def X := True`, `theorem X := trivial`, a hypothesis no
  structure can satisfy) at any point. See `.claude/rules/lean4.md` and the anti-vacuity gate below.
  If a phase cannot be completed, mark it `[BLOCKED]` with the exact goal state.
- **Do NOT introduce a `sorry`.** The live sorry census outside `Boneyard/` is **exactly one** —
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` — verified at this revision by
  `grep -rnE "^\s*sorry\s*$|:= sorry|by sorry|exact sorry" FormalSystem/ --include=*.lean |
  grep -v Boneyard`. It must remain exactly one at the end of every phase. `Transfer.lean:1242` is
  on the Base/Discrete axis, is not on this route, and is not to be attempted.
- **Do NOT cite task numbers in any `.lean` file.** Cite the sibling module name, the source's
  printed page, or the declaration name.
- **Do NOT touch `FormalSystem/Metalogic/Decidability/` or `FormalSystem/Automation/`.** A
  concurrent effort owns them. Neither read-for-edit nor stage any file under those paths; leave any
  of their modifications unstaged.

### The anti-vacuity gate (binding, per phase)

The `DedekindINF.lean` module docstring records the failure mode this task must not repeat:

> *"An over-strong hypothesis passes sorry-free, axiom-clean and EXIT 0 exactly as a vacuous
> conclusion does — the pattern that recurred three times undetected in this development."*

Every phase that introduces a **hypothesis** (a `structure … : Prop`, an `abbrev … : Prop`, or a
new binder on a transported theorem) MUST, in the same dispatch, land one of:

1. a **witness** — a concrete structure satisfying it, ideally at a dense flow; or
2. a **derivation** of it from an already-witnessed hypothesis; or
3. an explicit **exclusion lemma** in the style of `hasDefinableINF_excludes_kplus` and
   `hasDedekindINF_admits_kplus_shape`, showing which shapes the hypothesis admits and which it
   forbids.

A phase that lands only the hypothesis and its consumers, with no witness, is `[BLOCKED]` — not
`[COMPLETED]`. This is the single most important procedural constraint in v7, because the whole
reason Block D exists is that a previous dispatch shipped a theorem whose hypothesis is vacuous on
the flows this task cares about.

### Honesty charter for docstrings (binding user directive — SCOPE INVERTED FOR THIS ROUTE)

v6's charter required every new declaration to state that it **has no source in the corpus**. On the
completion route that was a first-order fact. **On the Doets route it is false for almost every
declaration, and repeating it would be the new dishonesty.**

**Rule 1 — transcription is cited, faithfully and specifically.** Every declaration in Blocks D, F,
G, H and I transcribes a named result. Its docstring must carry the **source, section, theorem or
lemma number, and printed page**, e.g. `Reynolds 1992, §6 Lemma 5, printed p.178` or
`Rabinovich 2014, Lemma 5.3 eq (5.2), PDF p.8`. A bare "following Reynolds" is a defect; so is a
docstring that omits the citation.

**Rule 2 — the printed page must be verified, not copied.** The Source-to-Implementation Mapping's
page attributions are carried from `reports/07` §1.1. Before a page number lands in a `.lean`
docstring the implementer re-checks it against the PDF and records any correction in the phase
summary. Rabinovich is cited by **PDF page only** — `DedekindINF.lean`'s docstring records that the
`.md` conversion is corrupt (it drops displayed equations and inverts `k ≠ m` to `k = m`) and is
never ground truth.

**Rule 3 — Reynolds may now be cited for discharges, and this is the inversion.** v6 forbade citing
Reynolds for anything but statements, because he obtains his gap-facing formulas by expressive
completeness, which v6 forbade building. **v7 builds it.** Reynolds' proofs are therefore available
as proofs, and the correct docstring for e.g. Lemma 3 says so.

**Rule 4 — the no-source statement is reserved, and its scope is now exhaustively named.** Only
these are original work with no counterpart in the corpus, and only these carry a plain "this
construction has no source in the corpus and is original work" statement:

- the chronicle → `OrderedMonadicStructure` dense bridge (Phase 15), including the bimodal family
  encoding beyond what `mkSigFrom`/`multiFamOmega` already discharge;
- the order-theoretic characterization `orderIsoRealOfDedekindDenseSeparable` (Phase 28), **if and
  only if** no Mathlib route is found — Reynolds asserts it in one sentence and Mathlib does not
  contain it, so the *proof* is original even though the *statement* is his;
- any Lean-specific scaffolding (fuel/termination arguments, decidability instances,
  `Fintype`/`DecidableEq` plumbing) with no mathematical counterpart.

**Rule 5 — ADAPTED-FROM survives, narrowed.** Where a declaration follows a source's *method* on a
different object (e.g. Phase 24's `ℝ`-interval `good` following the landed `ℤ`-interval `good`),
the form is `ADAPTED-FROM: <source>, <location>, printed p.<N>` with a one-clause statement of what
changed. Never "transcribed from" for an adaptation.

**Rule 6 — every carrier states what it excludes.** Carried verbatim from `DedekindINF.lean`'s
practice, and now mandatory for every new `Prop`-valued hypothesis in Block D.

### MUST preserve

- Every row of the Preserved Assets table, byte-identical unless a phase's Tasks list names the
  file.
- Every row of the Amputated Assets table, compiling and unmodified.
- `Metalogic/Soundness.lean` at zero sorries.
- `completeness_dense`, `completeness_discrete` and `countermodel_discrete_reynolds_v2` sorryAx-free
  with axioms exactly `[propext, Classical.choice, Quot.sound]`. **These are the regression canary
  for Block D**: if a re-base disturbs the discrete pipeline, this check fires first.
- The live sorry count outside `Boneyard/` at exactly one (`Transfer.lean:1242`).
- The exact signature of `consequence_completeness_dedekind_of_engine` (commit `bd9ae0ac1`).
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` and
  `ChronicleToCountermodelBasic.lean` **byte-identical**.

### Design decisions are SETTLED (do not re-open without a concrete counterexample)

- **The Doets route, not completion-by-limits.** Settled by the user's authorization on
  `reports/07`, against a landed refutation and three exhausted axioms.
- **The terminus is the finite-context consequence form, and weak completeness is its `Γ = []`
  corollary.** `Context := List Formula`, so the two are inter-derivable through the deduction
  theorem — which is exactly why neither may be called "strong completeness".
- **Genuine strong completeness is NOT the target and is provably unavailable here** (Reynolds
  §2, printed p.169: compactness fails). Out of scope; do not attempt, and do not rename any
  declaration back to a "strong" form.
- **The Doets route reaches BOTH termini with the pinned signature untouched.** Three independent
  grounds, from `reports/07` §1.5: Reynolds' own definition of weak completeness *is* the finite-set
  form; the pinned engine binder is per-formula by construction; and
  `SemanticConsequenceDedekindDense`'s carrier constraints (`AddCommGroup`, `LinearOrder`,
  `IsOrderedAddMonoid`, `DenselyOrdered`, `Nontrivial`, lub) describe a Dedekind-complete densely
  ordered nontrivial ordered abelian group, which by Hölder is order-isomorphic to `ℝ` — so the
  countermodel obligation *is* Reynolds' real-flow obligation.
- **Expressive completeness is available in this tree and is the route's engine, not its
  obstruction.** v6's contrary premise is refuted by `uSExpressivelyCompleteOverPrior`. Machine-
  checked `#print axioms` outranks a plan-time prose inventory.
- **The re-base target is `HasDedekindINF`, not `HasDefinableINF` and not `HasAttainedINF`.**
  `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`, axiom-clean) machine-proves that
  `HasDefinableINF` makes `kplus M atomMap P z0` *impossible* whenever `P` occurs in `(z₀,z₁)` —
  it deletes Rabinovich's disjunct (2). On a dense Prior structure that disjunct is exactly the
  reachable case, because Prior-U's conclusion has the `K⁺` shape. Do not re-open the carrier
  choice.
- **The `.Discrete` pipeline is the template and is not the target.** `countermodel_discrete_reynolds_v2`
  is Reynolds' §10 Theorem 9, whose D1 uses a discreteness shortcut. Its *method* transfers; its
  *statement* does not.
- **The Stavi route is the rejected alternative.** Reynolds proves Theorem 3 by reduction to
  `{U,S,U',S'}` expressive completeness (Theorem 2, GHR93 Thm 9.3.1). The tree's
  `stavi_expressive_completeness` lives **only** in `FormalSystem/Boneyard/StaviDiscretePath/` and
  its chain top is sorry-tainted; `PriorExpressiveness.lean`'s own docstring records that the tree
  deliberately moved off it onto `kampPriorExpressiveCompleteness`. Reviving a Boneyard module and
  discharging its sorry is strictly more work and strictly less certain than the re-base. Recorded
  as the fallback in Risks, not as the plan.
- **Every gap-facing obligation is discharged `fc`-conditionally.** `Axiom.prior_U_gap`,
  `prior_S_gap` and `sep` all have `minFrameClass = .Dedekind`, so every consumer carries
  `(hfc : FrameClass.Dedekind ≤ fc)`, discharged by `decide` at `fc := FrameClass.Dedekind`. This is
  not a weakness — it is the route finally using the axioms that distinguish the class.
- **The chronicle layer stays at `Rat`.** On this route it is not even lifted; it is read.

---

## Goals & Non-Goals

**Goals**:

- `consequence_completeness_dedekind (Γ : Context) (φ : Formula) :
  SemanticConsequenceDedekindDense Γ φ → Derivable FrameClass.Dedekind Γ φ`, sorry-free,
  unconditional, obtained by instantiating the pinned engine theorem.
- `completeness_dedekind (φ : Formula) : ValidDedekindDense φ → Derivable FrameClass.Dedekind [] φ`
  as its `Γ = []` corollary.
- `uSExpressivelyCompleteOverDensePrior` — {U,S} expressive completeness at the **dense** Prior
  carrier, with a non-vacuity witness. **Reusable well beyond this task**: it is the missing
  hypothesis-side half of the tree's Kamp/Rabinovich programme.
- `prior_hasDedekindINF_dense` / `prior_hasDedekindSUP_dense` — the faithful eq (5.2) carrier from
  the *dense* Prior axioms, closing the `DedekindINF.lean` deferral.
- `no_gaps_dense_prior` (**D1**, Reynolds Theorem 4) and `dense_singletons_of_sep` (**D2**,
  Reynolds Theorem 5), both reusable.
- `doets_theorem_dense` (Reynolds Theorem 6 / Doets 3.3.9).
- `orderIsoRealOfDedekindDenseSeparable` — an order-theoretic characterization of `ℝ` absent from
  Mathlib and of independent value.

**Non-Goals**:

- Genuine (infinite-premise) strong completeness. Provably unavailable; see the Reframing Note.
- Discharging `Transfer.lean:1242`. Base/Discrete axis; not on this route.
- Removing or refactoring the amputated layer.
- Formalizing the two-sided `prior_S_gap` defeat. Moot on this route.
- Reviving `stavi_expressive_completeness` from `Boneyard/`. Fallback only.
- Any edit under `FormalSystem/Metalogic/Decidability/` or `FormalSystem/Automation/`.
- A uniform (single) real-flowed model. Reynolds' Theorem 7 is per-formula and the pinned engine
  binder is per-formula; a uniform model is neither needed nor sought.

---

## Risks & Mitigations

| # | Risk | Likelihood | Impact | Mitigation / falsification protocol |
|---|---|---|---|---|
| R1 | **Phase 10 fails: the dense Prior axioms do not yield `HasDedekindINF`.** This is the route's crux — everything downstream is vacuous without it | **Low** | **Fatal to the route** | The argument is short and verified on paper at this revision: instantiate `Axiom.prior_U_gap` at `p := ¬P`. Its antecedent `U(⊤,¬P) ∧ F¬¬P` holds precisely when the left disjunct `K⁺(P)(z₀)` fails and `P` occurs above `z₀`; its conclusion `U(P ∨ K⁺(P), ¬P)(z₀)` **is** eq (5.2) verbatim. Phase 10 is scheduled **second** for exactly this reason: it is cheap and decisive. If it fails, the task is `[BLOCKED]` at Phase 10 with the route refuted, and no downstream phase is dispatched |
| R2 | **Block D's re-base (Phases 11-13) is larger than three phases.** The `EANegationFix/` and `NfMultiAnchorBridge/` trees are ~25k lines and the three named targets are entry points, not leaves | **High** | Schedule | Each of 11, 12, 13 is chartered against **one named declaration** with a stated `Done when`. A phase that on contact finds the re-base needs `n` further lemmas lands whatever is green, records the decomposition in its summary and handoff, and reports `[PARTIAL]` with a named sub-phase list — it does **not** expand silently. The orchestrator then revises to v8 with the sub-phases spliced in. This is the chartered outcome, not a failure |
| R3 | **Block F (Reynolds §6) is six phases of research-grade transcription with no discrete shortcut.** The discrete analogue cost 2215 lines *with* a shortcut | **High** | Schedule | Each phase owns one or two named lemmas of §6 whose statements are fixed verbatim by the source before any tactic is written. The literature's proofs are complete and available (§6 is quoted in full in the corpus), so this is transcription, not discovery. Same `[PARTIAL]`-with-decomposition protocol as R2 |
| R4 | **Phase 27's "game argument" is not spelled out by Reynolds.** He writes *"Another simple game argument can be used to show that we can mix into a shuffle many more copies of the same structures without disturbing `k`-equivalence"* and gives no proof. It is also the **only** result in the whole route that the tree previously attempted and archived unproved (`doets_lemma_1_5`) | Medium-**High** | One-two phases | Three mitigations. (i) The tree has the Karp/EF apparatus (`NEquivalence.lean`, 1315 lines, `KEquiv`, `kTypeOf`) and `doets_lemma_1_4` (same index set). (ii) Doets 1987 **3.1.8** supplies the rigorous general statement (*"if `(I, {i | m(i) ⊨ σ})_{σ∈Z} ≡ⁿ (J, {j | m'(j) ⊨ σ})_{σ∈Z}` then `Σ_{i∈I} m(i) ≡ⁿ Σ_{j∈J} m'(j)`"*), reducing the mixing claim to a `≡ⁿ` fact about the `Z`-coloured orders `(ℚ,…)` and `(ℝ,…)`. **Phase 27 is chartered against 3.1.8, not against Reynolds' one-liner.** (iii) The archived `doets_lemma_1_5` gives a ready statement template — but only a template: it is behind `#exit`, uses stale names, and its body is `sorry`. **It must not be un-archived; it must be re-stated under the live names and proved.** If the `≡ⁿ` colouring fact resists, Phase 27 splits at the mixing / order-theory seam and reports `[PARTIAL]` |
| R5 | **Phase 28's `ℝ` characterization is absent from Mathlib.** Confirmed at this revision: `Order.iso_of_countable_dense` covers `ℚ`; for `ℝ` only `ConditionallyCompleteLinearOrderedField` uniqueness exists | Certain | One-two phases | The construction is standard and bounded: the countable dense subflow `D ⊆ R` gives `D ≃o ℚ` by `Order.iso_of_countable_dense`; extend to `R ≃o ℝ` by mapping each point to the sup of its lower cut, using Dedekind completeness on both sides. Phase 28 is chartered with that proof skeleton and a hard `Done when`. If it overruns, it splits at the `D ≃o ℚ` / cut-extension boundary, which is a clean seam |
| R6 | **Block D disturbs the landed discrete pipeline.** `completeness_discrete` depends on `countermodel_discrete_reynolds_v2` → `no_gaps_discrete_model_surgery` → `uSExpressivelyCompleteOverPrior` | Medium | Regression | **Dense siblings, never in-place generalization** (Postmortem Constraint). Every phase in Block D runs `#print axioms completeness_discrete` and `#print axioms countermodel_discrete_reynolds_v2` as a regression check and records the result in its summary |
| R7 | **The bimodal dimension does not survive the dense `≡ₖ` transfer**, even though it survives the discrete one | Low | Blocks E/I | Attacked and defeated in `reports/07`'s adversarial pass: `mkSigFrom` already encodes box-subformulas as unary predicates and `multiFamOmega_shiftClosed` already packages the modal dimension as a family index, and `countermodel_discrete_reynolds_v2` already transfers a bimodal TM countermodel through a monadic-FO `≡ₖ` argument. Phase 15's **first task** is to verify that the encoding is independent of `SuccOrder`/`PredOrder`/`IsSuccArchimedean`; if it is not, Phase 15 reports `[BLOCKED]` with the exact dependency before any further phase is dispatched |
| R8 | **Effort overrun ends the task mid-programme** | **High** | Task state | Every phase ends with the tree green, the sorry census unchanged and the frozen files byte-identical, so **every phase boundary is a clean stopping point**. Running out of budget yields `[PARTIAL]` with a named next phase, never a broken tree. Block boundaries (14 / 16 / 22 / 23 / 29) are the natural reporting checkpoints |
| R9 | **A phase "succeeds" vacuously** — the failure mode that produced this whole revision | Medium | Silent | The anti-vacuity gate above: witness, derivation, or exclusion lemma, in the same dispatch, or `[BLOCKED]` |
| R10 | **Territory collision with the concurrent decidability effort** | Low | Build | Hard prohibition on `Decidability/` and `Automation/`; staging is scoped to the task directory plus the files a phase's Tasks list names. `git add -A` and `git commit -am` are forbidden |

---

## Implementation Phases

### Dependency Analysis and wave map

Blocks D and E are **independent of each other** and may be dispatched in parallel by an orchestrator
with the budget for it: Block E consumes only the landed chronicle and the landed `mkSigFrom`
apparatus, and touches no file Block D touches. Everything from Block F on is a chain.

| Wave | Phases | Blocked by | Territory (owned files) |
|---|---|---|---|
| 1 | **9**, **15** | — | 9: `WeakCanonical/PriorDefsDense.lean` (new). 15: `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (new) |
| 2 | **10**, **16** | 9 (for 10); 15 (for 16) | 10: `Kamp/DedekindINFDense.lean` (new). 16: same new bridge module |
| 3 | **11** | 10 | `Kamp/EANegationFix/OnBuilderFaithful.lean` (new) |
| 4 | **12** | 11 | `Kamp/EANegationFix/NegFixFaithful.lean` (new) |
| 5 | **13** | 12 | `Kamp/EANegationFix/VecEANegFixFaithful.lean` (new) |
| 6 | **14** | 13 | `WeakCanonical/PriorExpressivenessDense.lean` (new) |
| 7 | **17** | 14, 16 | `WeakCanonical/DenseModelSurgery/Defs.lean` (new) |
| 8 | **18** | 17 | `DenseModelSurgery/Lemma34.lean` (new) |
| 9 | **19** | 18 | `DenseModelSurgery/Lemma5.lean` (new) |
| 10 | **20** | 19 | `DenseModelSurgery/BadIntervals.lean` (new) |
| 11 | **21** | 20 | `DenseModelSurgery/TruthTransfer.lean` (new) |
| 12 | **22** | 21 | `DenseModelSurgery/NoGaps.lean` (new) |
| 13 | **23** | 22 | `DenseModelSurgery/Singletons.lean` (new) |
| 14 | **24**, **25** | 22 (24); 22 (25) | 24: `RealModel/GoodDense.lean` (new). 25: `RealModel/EpsilonDense.lean` (new) — **parallel-eligible pair** |
| 15 | **26** | 24, 25 | `RealModel/Shuffle.lean` (new) |
| 16 | **27** | 26 | `RealModel/ShuffleReal.lean` (new) |
| 17 | **28** | — (independent; schedule any time after wave 1) | `RealModel/OrderIsoReal.lean` (new) — **parallel-eligible with waves 3-16** |
| 18 | **29** | 23, 27, 28 | `RealModel/DoetsTheorem.lean` (new) |
| 19 | **30** | 29 | `BXCanonical/CompletenessDedekind.lean` (extend), `Metalogic/StrongCompleteness.lean` (extend), `FormalSystem/Metalogic.lean` (tracking table) |

Directory names for new modules are proposals; an implementer who places a module elsewhere records
the deviation in the phase summary. **No phase owns a file another phase owns in the same wave.**

---

### Phase 9: `SemanticPriorU` / `SemanticPriorS` and the dense-flow vacuity witness [COMPLETED]

- **Goal**: Land the *dense* semantic Prior hypotheses — Reynolds' Prior-U / Prior-S in the
  `OrderedMonadicStructure` idiom — and, in the same dispatch, a machine-checked witness that
  `SemanticPriorUZ` is the wrong hypothesis for a dense flow.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/PriorDefsDense.lean` (new).
- **Tasks**:
  - [x] Define `SemanticPriorU M atomMap : Prop` as the semantic reading of
        `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)` at every point and every `Formula` — i.e. if `p` holds
        throughout some initial stretch above `t` and `¬p` holds somewhere above `t`, then there is
        `s > t` with `p` throughout `(t,s)` and `(¬p ∨ K⁺(¬p))` at `s`, where `K⁺(A)` unfolds to
        "`A` holds arbitrarily soon after". Define `SemanticPriorS` dually.
  - [x] Docstring per the honesty charter: `Reynolds 1992, Prior-U/Prior-S, printed p.168`, with the
        axioms quoted character-for-character and the correspondence to `Axiom.prior_U_gap`
        (`Axioms.lean:377`) / `Axiom.prior_S_gap` (`:387`) stated explicitly. Verify the printed page
        against the PDF. *(printed p.168 re-verified against PDF page 4; p.176 re-verified against
        PDF page 12)*
  - [x] **Rule 6 — state what the carrier excludes.** Record that `SemanticPriorU` does *not* imply
        `SemanticPriorUZ`, and that on a dense flow it cannot. *(as
        `semanticPriorU_not_implies_semanticPriorUZ` plus the general exclusion lemma
        `semanticPriorUZ_fails_of_interval_witness`)*
  - [x] **Anti-vacuity gate, part 1 — the negative witness.** Land
        `semanticPriorUZ_fails_on_dense`: an explicit `OrderedMonadicStructure` with a densely
        ordered carrier and one predicate true exactly on an open right-ray, refuting
        `SemanticPriorUZ`. This is the machine-checked form of the vacuity finding that triggered
        Block D, and it is the reason the rest of the block exists.
  - [x] **Anti-vacuity gate, part 2 — the positive witness.** Land `semanticPriorU_of_dense_ray` or
        an equivalent: a densely ordered structure satisfying `SemanticPriorU` **and**
        `SemanticPriorS` non-trivially (at minimum, a structure with at least one predicate that is
        neither empty nor the whole carrier). Without this the whole of Block D risks being vacuous.
        *(exceeded: `semanticPriorU_of_flowGLB` / `semanticPriorS_of_flowLUB` give the general
        Dedekind-complete-flow theorem, instantiated at two witnesses — the ray and a bounded
        window whose Prior-U antecedent is actually satisfied,
        `densePriorU_antecedent_reachable`)*
  - [x] `#print axioms` on all four new declarations; record. *(all eleven new declarations
        checked: `[propext, Classical.choice, Quot.sound]`; the exclusion lemma needs only
        `[propext]`)*
  - [x] Scoped build green; full `lake build` green. *(both observed; `lake build` = "Build
        completed successfully (1909 jobs)")*
- **Estimated output**: ~220 lines.
- **Done when**: `SemanticPriorU`, `SemanticPriorS`, `semanticPriorUZ_fails_on_dense` and the
  positive witness are sorry-free with axioms exactly `[propext, Classical.choice, Quot.sound]`;
  full `lake build` green; sorry census unchanged; `PriorDefs.lean` byte-identical.
- **Depends on**: —
- **Timing**: 4 hours.

### Phase 10: `HasDedekindINF` / `HasDedekindSUP` from the dense Prior axioms [COMPLETED]

> **OUTCOME — the single point of failure HELD.** The derivation from `SemanticPriorU` /
> `SemanticPriorS` is complete, sorry-free and axiom-clean, with no discreteness, no attainment and
> no flow completeness. Phase 9's finding was confirmed and is now **on disk as a theorem**, not a
> note: `hasDedekindINF_fails_of_interval_witness` refutes the unguarded `HasDedekindINF` on *any*
> densely ordered flow carrying a formula true at `z₀` and throughout `(z₀,z₁)`, and
> `hasDedekindINF_fails_on_dense_window` instantiates it at `denseWindowFlow`.
>
> **The landed form is the trichotomy `HasDenseDedekindINF`, not the guarded sibling**, and this is
> a deviation from the two options the Phase 9 note anticipated. Reason, measured rather than
> assumed: a survey of every `.first_occ` / `.last_occ` call site outside `Boneyard/` found that
> **`¬P(z₀)` is available at none of them** — each is reached from a `by_cases` on whether `P`
> occurs at an *interior* point of `(z₀,z₁)`, with no hypothesis about `z₀` in scope. A guarded
> carrier is therefore unconsumable downstream. `HasDenseDedekindINF` moves the endpoint case out
> of the hypothesis and into the conclusion as a third disjunct `P(z₀)`, which is Rabinovich's own
> case split on `r₀ = inf{z ∈ (z₀,z₁) | P₁(z)}` with its first two subcases kept apart instead of
> merged under his construction's standing `¬P₁(z₀)`. It is hypothesis-free, so it asks nothing at
> a call site that `HasDedekindINF` did not already ask. The guarded form is landed too and the two
> are interderivable.
>
> **Consequence for Phase 11 and after — re-base target changes.** Downstream must consume
> `HasDenseDedekindINF` and handle the `P(z₀)` disjunct. That case is genuinely reachable
> (`denseWindow_endpoint_disjunct_forced` exhibits a point where it is the *only* disjunct that
> holds), so no restatement can avoid it; it is real mathematical content the discrete route never
> had to face, and it is the honest dense-case cost. `HasDedekindINF.toHasDenseDedekindINF` keeps
> the discrete pipeline supplying the new carrier, so a re-based consumer serves both instances.
>
> **Second finding, unplanned and material to Phases 11-13.** An `EANegationFixFaithful/` subtree
> plus `Lemma53Faithful.lean` and `Prop42Faithful.lean` **already exist in-tree and already consume
> `HasDedekindINF`** — among them `negChainOnFaithful_iff` (`Lemma53Faithful.lean:274`),
> `negFixOneFaithful_cover` (`NegFixOneFaithful.lean:422`) and the list analogue
> (`NegFixListFaithful.lean:446`). `DedekindINF.lean`'s docstring describes this re-base as
> DEFERRED, and the plan's Phases 11-13 are written as though these modules do not exist. They do.
> Because they are pinned at the *unguarded* `HasDedekindINF`, **they cannot be instantiated at any
> dense Prior structure** — the hypothesis is refutable there. Phases 11-13 should be re-scoped
> against what is actually on disk before being dispatched: the work may be substantially a
> hypothesis-swap onto `HasDenseDedekindINF` plus the new endpoint case, rather than the
> from-scratch construction the plan describes.

> **This is the route's crux and it is scheduled second on purpose.** Everything from Phase 11
> onward is vacuous without it, the argument is short, and a failure here refutes the route cheaply.
> If it fails, the phase reports `[BLOCKED]` with the exact goal state and **no later phase is
> dispatched**.

> **INPUT FROM PHASE 9 — two machine-checked facts, both established as `lean_run_code` probes
> against the landed Phase 9 witnesses and neither yet in the tree.**
>
> 1. **`HasDedekindINF` as literally stated is FALSE on a dense Prior structure.** Phase 9's
>    `denseWindowFlow` (carrier `ℝ`, one predicate true exactly on `(0,1)`) satisfies
>    `SemanticPriorU` **and** `SemanticPriorS` — both landed — yet refutes
>    `HasDedekindINF denseWindowFlow densePriorAtomMap`: take `P` the atom, `z₀ = 1/2`, `z₁ = 1`.
>    `P` occurs in `(z₀,z₁)`, so the hypothesis fires; the **left** disjunct `kplus P z₀` fails
>    because `kplus` (`PriorINF.lean:86`) demands `¬P(z₀)` and `P(1/2)` holds; the **right** disjunct
>    fails because it demands a `P`-free interval `(z₀,r₀)`, which a dense flow cannot supply when
>    `P` holds throughout `(z₀,z₁)`. The gap is precisely Rabinovich's `r₀ = z₀` subcase *with `P`
>    true at `z₀`*, which this tree's `kplus` cannot express.
> 2. **With the endpoint guard `¬TemporalTruth M atomMap z0 P` added, the plan's skeleton (steps
>    1-6) goes through verbatim from `SemanticPriorU` alone** — proved as a probe, generic in `sig`,
>    `M` and `atomMap`, no completeness and no attainment used, via `temporal_truth_neg`
>    (`Kamp/Translation.lean:47`) at `p := P.neg`.
>
> Consequence for this phase: `prior_hasDedekindINF_dense` cannot conclude in bare `HasDedekindINF`.
> The honest options are (a) a guarded sibling carrier in the phase's own new module, stating the
> `¬P(z₀)` hypothesis and documenting that it is Rabinovich's Case 2 setup, or (b) `HasDedekindINF`
> supplied only for structures where the endpoint case is excluded. **Neither is a softening**: the
> derivation itself is complete and axiom-clean. What is *not* available is the unguarded universal
> statement, and Phase 9 refutes it rather than leaving it to be discovered mid-proof.

- **Goal**: `prior_hasDedekindINF_dense` and `prior_hasDedekindSUP_dense` — the faithful Rabinovich
  eq (5.2) carrier derived from `SemanticPriorU` / `SemanticPriorS`, with **no** discreteness and
  **no** attainment assumption. This closes the deferral recorded at `DedekindINF.lean:87-103`.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/DedekindINFDense.lean` (new).
  **`DedekindINF.lean` (291 lines) and `PriorINF.lean` (296 lines) are read, not edited.**
- **The exact target, read verbatim from `DedekindINF.lean:136` at this revision** — the phase
  proves this `first_occ` field from `SemanticPriorU` instead of from `prior_hasAttainedINF`:

  ```lean
  structure HasDedekindINF {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
    first_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
      z0 < z1 →
      (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
      kplus M atomMap P z0 ∨
        (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
          (∀ y : M.carrier, z0 < y → y < r0 → ¬TemporalTruth M atomMap y P) ∧
          (TemporalTruth M atomMap r0 P ∨ kplus M atomMap P r0))
  ```

  For contrast, the landed `prior_hasDedekindINF` (`DedekindINF.lean:232`) is a one-liner
  `(prior_hasAttainedINF M atomMap h_UZ).toHasDedekindINF` — it consumes `SemanticPriorUZ` and is
  therefore unusable here.
- **Proof skeleton (verified on paper at this revision against the field above; transcribe, do not
  re-derive)**: Fix `P`, `z₀ < z₁`, and suppose `P` occurs in `(z₀,z₁)`.
  1. Case `K⁺(P)(z₀)`: take `HasDedekindINF`'s **left disjunct** and stop. (Rabinovich, PDF p.8:
     *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"*.)
  2. Otherwise `¬K⁺(P)(z₀)`, i.e. `¬P` holds throughout some initial stretch above `z₀` — which is
     exactly `U(⊤, ¬P)(z₀)`.
  3. `P` occurs in `(z₀,z₁)` gives `F(¬¬P)(z₀)`, the second conjunct of Prior-U's antecedent at
     `p := ¬P`.
  4. `SemanticPriorU` at `p := ¬P` therefore yields `U(P ∨ K⁺(P), ¬P)(z₀)`: some `r₀ > z₀` with
     `¬P` throughout `(z₀,r₀)` and `P(r₀) ∨ K⁺(P)(r₀)`.
  5. `r₀ < z₁` because `P` occurs in `(z₀,z₁)` and `¬P` holds on `(z₀,r₀)`.
  6. Steps 4-5 are **eq (5.2) verbatim** — `HasDedekindINF`'s right disjunct.
- **Tasks**:
  - [x] Prove `prior_hasDedekindINF_dense`, following the skeleton above. *(deviation: altered —
        landed as `prior_hasGuardedDedekindINF_dense` (skeleton steps 1-6 verbatim, guard `¬P(z₀)`)
        and `prior_hasDenseDedekindINF_dense` (the hypothesis-free trichotomy, the exported form).
        The unguarded conclusion is unavailable and is refuted on disk — see the phase note.)*
  - [x] Prove `prior_hasDedekindSUP_dense`, the `SemanticPriorS` mirror. *(deviation: altered —
        same shape: `prior_hasGuardedDedekindSUP_dense` / `prior_hasDenseDedekindSUP_dense`.)*
  - [x] Docstring: `Rabinovich 2014, Lemma 5.3 Case 2 and eq (5.2), PDF p.8` for the carrier, and
        `Reynolds 1992, Prior-U, printed p.168` for the derivation, with the instantiation
        `p := ¬P` stated in words. **Cite Rabinovich by PDF page only** — the `.md` conversion is
        corrupt. *(done; the endpoint guard and the refutation are labelled original glue, and the
        docstring states plainly that Rabinovich's "`r₀ = z₀` iff `K⁺(P₁)(z₀)`" is false read
        literally and sound under his construction's standing `¬P₁(z₀)`.)*
  - [x] Record explicitly, in the docstring, that this derivation **does not** route through
        `prior_hasAttainedINF` and therefore carries no discreteness — the whole point of the
        phase. *(done, in the theorem docstring.)*
  - [x] **Anti-vacuity**: instantiate at the positive witness from Phase 9 and land the resulting
        `HasDedekindINF` as a named `example` or lemma. Also record which of the two disjuncts the
        witness lands in; if it is always the right one, exhibit a structure landing in the left,
        to show `hasDedekindINF_admits_kplus_shape`'s case is reachable here too.
        *(`hasDenseDedekindINF_of_dense_window` / `hasGuardedDedekindINF_of_dense_window` and the
        `SUP` mirrors. **All three disjuncts are reachable and each is exhibited**:
        `denseWindow_kplus_at_zero` lands `K⁺` at `z₀ = 0`;
        `denseWindow_guardedINF_right_disjunct` lands eq (5.2) at `z₀ = -1` via
        `denseWindow_kplus_fails_at_neg_one`; `denseWindow_endpoint_disjunct_forced` lands the new
        `P(z₀)` disjunct at `z₀ = 1/2` and proves the other two fail there.)*
  - [x] `#print axioms` on both; regression: `#print axioms completeness_discrete`. *(all 18
        declarations `[propext, Classical.choice, Quot.sound]`; the two exclusion lemmas and the
        two `toHasDenseDedekind*` shims need only `[propext]`. Canaries unchanged:
        `completeness_dense`, `completeness_discrete`, `countermodel_discrete_reynolds_v2`.)*
  - [x] Scoped build green; full `lake build` green. *(both; `lake build` = "Build completed
        successfully (1912 jobs)". Live sorry outside `Boneyard/` remains exactly
        `Transfer.lean:1242`.)*
- **Estimated output**: ~300 lines.
- **Done when**: both theorems sorry-free with axioms exactly `[propext, Classical.choice,
  Quot.sound]`; the non-vacuity instantiation lands; `DedekindINF.lean` and `PriorINF.lean`
  byte-identical; full build green.
- **Depends on**: 9.
- **Timing**: 6 hours.

### Phase 11: Rabinovich Lemma 5.3 re-based — `negChainOnFaithful` at `VVecEA2` [NOT STARTED]

- **Goal**: The first of the three deferred re-base targets named at `DedekindINF.lean:88-92`:
  `negChainOn` (`Kamp/EANegationFix/OnBuilder.lean:149`) re-based over `HasDedekindINF`, restoring
  the printed **three**-disjunct `Oₙ₊₁`. The landed version truncates it to two by dropping
  disjunct (2) — the `K⁺(P₁)(z₀)` case — which is precisely the case a dense Prior structure
  reaches.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFix/OnBuilderFaithful.lean` (new).
  **`OnBuilder.lean` is read, not edited** — the discrete pipeline depends on it.
- **Tasks**:
  - [ ] Read `OnBuilder.lean:149` and `Lemma53.lean` (including `hasDefinableINF_excludes_kplus` at
        `:282`) and record, in the phase summary, exactly which steps of the landed proof consume
        the attained/definable hypothesis. This is the re-base's actual surface area and it must be
        measured before it is attacked.
  - [ ] Define `negChainOnFaithful` with result type **`VVecEA2`, not `VBracketFormula`** — the
        deferral note records why: disjunct (2) conjoins the endpoint predicate `K⁺(P₁)` at `z₀`,
        which `VBracketFormula` cannot carry.
  - [ ] Prove its correctness lemma over `HasDedekindINF`, reusing `TemporalPred.disj` /
        `TemporalPred.eval_at_disj` (`ExistsForallNF.lean`, `VecEAClosure.lean`) as the point-type
        primitive for eq (5.2)'s `(P₁(r₀) ∨ K⁺(P₁)(r₀))` — `DedekindINF.lean`'s "What already
        exists to build on" section names these as the intended tools.
  - [ ] Docstring: `Rabinovich 2014, Lemma 5.3, PDF p.8`, plus a `ADAPTED-FROM` note naming
        `negChainOn` as the two-disjunct predecessor and stating what the third disjunct adds.
  - [ ] `#print axioms`; regression on `completeness_discrete`.
  - [ ] Scoped build green; full `lake build` green.
- **Estimated output**: ~350 lines.
- **Done when**: `negChainOnFaithful` and its correctness lemma are sorry-free and axiom-clean; the
  surface-area measurement is recorded in the summary; `OnBuilder.lean` byte-identical.
- **Depends on**: 10.
- **Timing**: 7 hours.
- **Decomposition protocol (R2)**: if the measurement in task 1 shows the re-base needs more than
  one agent run, land whatever is green, record a named sub-phase list in the summary and handoff,
  and report `[PARTIAL]`. Do **not** expand the phase silently and do **not** stub with `sorry`.

### Phase 12: Rabinovich Lemma 5.1 re-based — `BracketFormula.negFix_iff` [NOT STARTED]

- **Goal**: The second deferred target: `BracketFormula.negFix_iff`
  (`Kamp/EANegationFix/NegFix.lean:669`) re-based off the attained pin onto `HasDedekindINF`.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFix/NegFixFaithful.lean` (new).
  **`NegFix.lean` is read, not edited.**
- **Tasks**:
  - [ ] Measure and record the attained-hypothesis surface of `NegFix.lean:669`, as in Phase 11.
  - [ ] State and prove the `HasDedekindINF`-based analogue, consuming Phase 11's
        `negChainOnFaithful`.
  - [ ] Docstring: `Rabinovich 2014, Lemma 5.1, PDF pp.9-10`, with an `ADAPTED-FROM` note naming the
        landed `BracketFormula.negFix_iff`.
  - [ ] `#print axioms`; regression on `completeness_discrete`.
  - [ ] Scoped build green; full `lake build` green.
- **Estimated output**: ~320 lines.
- **Done when**: the analogue is sorry-free and axiom-clean; `NegFix.lean` byte-identical.
- **Depends on**: 11.
- **Timing**: 6 hours.
- **Decomposition protocol**: as Phase 11.

### Phase 13: Rabinovich Prop 4.2 re-based — `VVecEA2.negFix_iff` and contentfulness [NOT STARTED]

- **Goal**: The third deferred target: `VVecEA2.negFix_iff`
  (`Kamp/EANegationFix/VecEANegFix.lean:164`) and hence `prop42_contentful_of_attained`
  (`Kamp/Section5Correspondence.lean`) re-based off the attained pin.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFix/VecEANegFixFaithful.lean`
  (new). **`VecEANegFix.lean` and `Section5Correspondence.lean` are read, not edited.**
- **Tasks**:
  - [ ] Measure and record the attained-hypothesis surface, as in Phases 11-12.
  - [ ] State and prove `VVecEA2.negFix_iff_dedekind`, consuming Phase 12.
  - [ ] Land `prop42_contentful_of_dedekind` — the contentfulness guard at the faithful carrier.
        `Section5Correspondence.lean`'s existing guard exists precisely to stop this correspondence
        rotting; the dense sibling must carry the same guard or the re-base is unprotected.
  - [ ] Docstring: `Rabinovich 2014, Prop 4.2, PDF p.6`.
  - [ ] `#print axioms`; regression on `completeness_discrete`.
  - [ ] Scoped build green; full `lake build` green.
- **Estimated output**: ~320 lines.
- **Done when**: both declarations sorry-free and axiom-clean; the contentfulness guard is present
  and non-vacuous; the two read files byte-identical.
- **Depends on**: 12.
- **Timing**: 6 hours.
- **Decomposition protocol**: as Phase 11.

### Phase 14: `uSExpressivelyCompleteOverDensePrior` [NOT STARTED]

- **Goal**: The composed theorem — {U,S} expressive completeness over structures satisfying the
  **dense** Prior axioms — plus its non-vacuity witness. This is Reynolds' Theorem 3 (§5, printed
  p.176) at the carrier the Dedekind route actually needs.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` (new).
  **`PriorExpressiveness.lean` is read, not edited.**
- **Tasks**:
  - [ ] Land `kampDedekindExpressiveCompleteness` — the `HasDedekindINF`/`HasDedekindSUP`-based
        analogue of `kampPriorExpressiveCompleteness` (`Kamp/KampPrior.lean`), composing Phases
        11-13.
  - [ ] Land `uSExpressivelyCompleteOverDensePrior atomMap h_surj psi :
        { A : Formula // ∀ M, SemanticPriorU M atomMap → SemanticPriorS M atomMap →
        ∀ t, eval M (fun _ => t) psi ↔ TemporalTruth M atomMap t A }`, by composing
        `prior_hasDedekindINF_dense` / `prior_hasDedekindSUP_dense` (Phase 10) with the above.
        Mirror the landed `uSExpressivelyCompleteOverPrior`'s shape exactly, including the
        `h_surj` atom-surjectivity binder.
  - [ ] Docstring: `Reynolds 1992, §5 Theorem 3, printed p.176`, quoting the theorem statement, and
        recording that this tree obtains it by Rabinovich's method relativized to `HasDedekindINF`
        rather than by Reynolds' own reduction to `{U,S,U',S'}` (which would require the
        Boneyard'd, sorry-tainted `stavi_expressive_completeness`).
  - [ ] **Anti-vacuity, and this is the phase's most important task.** Instantiate at Phase 9's
        positive dense witness and land the resulting `{A : Formula // …}` as a named example for at
        least one non-trivial `psi`. A sorry-free `uSExpressivelyCompleteOverDensePrior` whose
        hypothesis no dense structure satisfies would reproduce the exact defect this block exists
        to repair.
  - [ ] `#print axioms`; regression on `completeness_discrete` and
        `countermodel_discrete_reynolds_v2`.
  - [ ] Scoped build green; full `lake build` green.
- **Estimated output**: ~250 lines.
- **Done when**: both declarations sorry-free with axioms exactly `[propext, Classical.choice,
  Quot.sound]`; the non-vacuity instantiation lands at a dense flow;
  `#print axioms completeness_discrete` unchanged.
- **Depends on**: 13.
- **Timing**: 5 hours.
- **BLOCK D CHECKPOINT**: at this point the tree contains expressive completeness of `{U,S}` at a
  carrier that dense Prior structures actually inhabit. This is a reusable result of independent
  value and a clean stopping point.

### Phase 15: The dense monadic bridge — chronicle to `OrderedMonadicStructure` over `ℚ` [NOT STARTED]

- **Goal**: Reynolds §9 steps 1-2 (printed p.189): turn the landed rational chronicle into a
  temporal structure *in a finite monadic language* over a countable dense endpointless flow, with
  the bimodal dimension encoded as `ReynoldsBridge.lean` already encodes it at `.Discrete`.
- **Owns**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (new).
  **`ChronicleToCountermodelBasic.lean` and `ChronicleConstruction.lean` are read, not edited, and
  must be byte-identical at phase end.**
- **Tasks**:
  - [ ] **First task, and it is a gate (R7).** Determine whether `mkSigFrom`
        (**`Transfer.lean:134`**, not `ReynoldsBridge.lean`), `Formula.predFormulas`
        (**`Syntax/Formula.lean:778`**), `multiFamTaskFrame` (`ReynoldsBridge.lean:671`),
        `multiFamOmega` (`:694`) and `multiFamOmega_shiftClosed` (`:708`) are independent of
        `SuccOrder` / `PredOrder` / `IsSuccArchimedean`, or whether discreteness is baked into the
        encoding rather than only into `countermodel_discrete_reynolds_v2`'s statement (`:739`).
        **Preliminary reading at this revision says they are independent**: `multiFamTaskFrame
        FamIdx : TaskFrame ℤ` is `WorldState := FamIdx × ℤ` with
        `TaskRel p d q := p.1 = q.1 ∧ q.2 = p.2 + d`, in which `ℤ` occurs only as the carrier and
        `+` only as its group operation — so the `D`-generic form is a substitution. **Verify this
        rather than assuming it, and record the answer explicitly in the summary.** If discreteness
        *is* baked in, report `[BLOCKED]` with the exact dependency; do not attempt a workaround in
        this phase.
  - [ ] Land `multiFamTaskFrameGen (D) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
        (FamIdx) : TaskFrame D` and its `Omega`/shift-closure siblings, **beside** the `ℤ` versions
        (which are consumed by `countermodel_discrete_reynolds_v2` and must stay byte-identical),
        and prove the `ℤ` instances are definitionally the specializations — or, if that is not
        available, record why. Phase 30 consumes these at `D := ℝ`.
  - [ ] Note for the record: `mkSigFrom` lives in `Transfer.lean`, which carries the repository's
        single live sorry at `:1242` in an **unrelated** declaration. Importing it is normal and
        already universal in this tree. `Transfer.lean:1242` is not to be attempted.
  - [ ] Build `chronicleMonadicStructure fc A h_mcs h_box_dense root : OrderedMonadicStructure
        (mkSigFrom root)` with carrier `Rat`, interpreting each predicate of `mkSigFrom root` as
        membership of the corresponding `predFormula` in the chronicle family's MCS at that
        rational. Reuse `cantorBfmcsDense`'s `evalFamily` for the root family and its `families`
        set for the modal dimension.
  - [ ] Prove the **truth-correspondence** lemma: for every `φ ∈ subformulaClosure root`,
        `TemporalTruth (chronicleMonadicStructure …) atomMap q φ ↔ φ ∈ (fam.mcs q)`. This is the
        bridge's whole content and the only thing later phases consume.
  - [ ] Prove the carrier is countable, densely ordered and without endpoints (immediate at `Rat`).
  - [ ] Docstring: the construction has **no source in the corpus** and is original work (honesty
        charter Rule 4), with `ADAPTED-FROM: ReynoldsBridge.lean`'s `.Discrete` encoding named, and
        `Reynolds 1992, §9, printed p.189` cited for the *statement* of what step 2 delivers.
  - [ ] `#print axioms`; verify the two frozen chronicle files byte-identical.
  - [ ] Scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines.
- **Done when**: the structure and its truth-correspondence lemma are sorry-free and axiom-clean;
  the R7 gate answer is recorded; frozen files byte-identical.
- **Depends on**: — (may run in parallel with Phase 9).
- **Timing**: 7 hours.

### Phase 16: The chronicle structure is a dense Prior structure satisfying Sep [NOT STARTED]

- **Goal**: Reynolds §4 Corollary 1 clause 3 (printed p.174), in the monadic idiom: *"all
  substitution instances of the axioms Prior-U, Prior-S and Sep are valid in `M`"* — for the
  structure Phase 15 built.
- **Owns**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (extends
  Phase 15).
- **Tasks**:
  - [ ] Prove `chronicleMonadic_semanticPriorU` : the structure satisfies `SemanticPriorU`. Route:
        `Axiom.prior_U_gap` has `minFrameClass = .Dedekind`, so at `fc := FrameClass.Dedekind` every
        substitution instance is a theorem, hence in every MCS (`theorem_in_mcs`,
        `MaximalConsistent.lean:491`), hence true at every point by Phase 15's truth
        correspondence. Carry `(hfc : FrameClass.Dedekind ≤ fc)`.
  - [ ] Prove `chronicleMonadic_semanticPriorS` from `Axiom.prior_S_gap`, dually.
  - [ ] Define `SemanticSep` (the semantic reading of `Axiom.sep`, `Axioms.lean:390`) and prove
        `chronicleMonadic_semanticSep` the same way. **This is `Axiom.sep`'s first consumer on any
        completeness route in this repository.** Its soundness is already landed; Reynolds' Lemma 10
        (printed p.184) is **not** re-derived.
  - [ ] Land the packaged `chronicleIsDensePriorSepStructure` bundling all three plus countability,
        density and endpointlessness — the exact input Blocks F, G and H consume.
  - [ ] Docstrings cite `Reynolds 1992, §4 Corollary 1, printed p.174` and `Sep, printed p.168`
        (character-for-character, as the landed `Axiom.sep` docstring already does).
  - [ ] **Anti-vacuity**: this phase's output *is* the witness Phase 14's hypothesis wanted. Record
        the cross-reference explicitly: `chronicleIsDensePriorSepStructure` is a dense structure
        satisfying `SemanticPriorU`/`SemanticPriorS`, so `uSExpressivelyCompleteOverDensePrior`
        applies to it. If Phase 14 has landed, land that application as a named lemma here.
  - [ ] `#print axioms`; frozen files byte-identical; full `lake build` green.
- **Estimated output**: ~350 lines.
- **Done when**: all four declarations sorry-free and axiom-clean; the cross-reference to Phase 14's
  hypothesis is landed or explicitly deferred with a reason; frozen files byte-identical.
- **Depends on**: 15.
- **Timing**: 6 hours.
- **BLOCK E CHECKPOINT**: Reynolds' step 1 is now available in the form Doets' theorem consumes.

### Phase 17: Contemporaneous equivalence, `ρ`/`λ`, and Reynolds §6 Lemma 2 [NOT STARTED]

- **Goal**: The vocabulary of Reynolds §6 at the dense instance, and Lemma 2 — the temporal formula
  `R` that holds exactly where a class ends in a gap on the right.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean` (new).
- **Tasks**:
  - [ ] Define `ContempEquivDense`: a binary relation defined by a monadic `ε(x,y)` such that (i) it
        is an equivalence relation, (ii) it partitions the carrier into intervals, and (iii)
        `M ⊨ ε(a,b) ↔ M|[a,b] ⊨ ε(a,b)`. Reynolds §6, printed p.176, states all three clauses
        verbatim; transcribe them. Compare with the landed `ContempEquiv`
        (`IntegerModel/GoodStructures.lean`) and record whether it can be reused as-is or needs a
        dense sibling — **record the answer, do not silently generalize the landed one**.
  - [ ] Define `rhoFormula ε` as the monadic
        `∃y>x ¬ε(x,y) ∧ ¬∃z(x<z ∧ ε(x,z) ∧ ∀y(x<y<z → ε(x,y)))`, verbatim from printed p.177, and
        `lambdaFormula ε` dually.
  - [ ] Prove **Lemma 2**: *"there is a `US`-formula `R` which holds in any Prior structure `N`
        exactly at those points whose `∼_N`-class ends in a gap on the right"*, by applying
        `uSExpressivelyCompleteOverDensePrior` (Phase 14) to `rhoFormula ε`. Dually `L`.
  - [ ] Record, in the docstring, the uniformity Reynolds relies on: the same `R` works in *any*
        Prior structure, because expressive completeness is uniform over the class (Reynolds §5,
        printed p.176: *"Note the uniformity of the translation over the whole of `S`"*). Lemma 9
        will use exactly this.
  - [ ] Docstrings: `Reynolds 1992, §6, printed pp.176-177` and `§6 Lemma 2, printed p.177`.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~300 lines.
- **Done when**: `ContempEquivDense`, `rhoFormula`, `lambdaFormula` and Lemma 2 (both directions)
  are sorry-free and axiom-clean; the `ContempEquiv`-reuse question is answered in the summary.
- **Depends on**: 14, 16.
- **Timing**: 6 hours.

### Phase 18: Reynolds §6 Lemmas 3 and 4 — maximal `R`-intervals [NOT STARTED]

- **Goal**: *"The maximal intervals in which `R` holds are open intervals which, if bounded, have
  elements of `M` as their (excluded) end points"* (Lemma 3) and *"There is no last class and no
  first class in any maximal interval of `R`"* (Lemma 4).
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean` (new).
- **Tasks**:
  - [ ] Prove Lemma 3, transcribing Reynolds' three-case argument (printed p.177): `ρ` at `t` gives
        `R` for a while after `t`; if `R` does not hold forever after `t` then Prior-U applied to
        `R` gives either a last point of the `R`-stretch (impossible given `ρ`) or a first point of
        `¬R`; looking left, Prior-S gives three cases of which the third — a first point `s` of `R`
        with `R ∧ K⁻(¬R)` at `s` — is ruled out by the auxiliary formula `B` ("the class we are now
        in begins with a point satisfying `R ∧ K⁻(¬R)`"), which exists by expressive completeness
        and contradicts Prior-U.
  - [ ] Prove Lemma 4, transcribing printed p.177: the last class in a maximal `R`-interval would
        not end in a gap; and the temporal equivalent of
        `ρ(x) ∧ ∀y<x (y<z<x ∧ ε(y,z))` is true only in first classes, so a first class would give a
        formula true up to a gap and false arbitrarily soon after, contradicting Prior-U.
  - [ ] Each auxiliary formula obtained by expressive completeness is landed as a **named**
        definition with its defining monadic formula, not as an inline `obtain` — later phases
        (19, 20, 21) reuse the same pattern and a named family is what makes them cheap.
  - [ ] Docstrings: `Reynolds 1992, §6 Lemma 3 / Lemma 4, printed p.177`.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines.
- **Done when**: Lemmas 3 and 4 sorry-free and axiom-clean; the auxiliary-formula helpers are named
  and reusable.
- **Depends on**: 17.
- **Timing**: 7 hours.
- **Decomposition protocol (R3)**: as Phase 11 — split at the Lemma 3 / Lemma 4 boundary if needed.

### Phase 19: Reynolds §6 Lemma 5 — formula and elementary transfer across classes [NOT STARTED]

- **Goal**: *"If a temporal formula holds somewhere in one `∼`-class in a maximal interval of `R`,
  then it holds somewhere in each `∼`-class in the interval. Furthermore, each pair of the
  `∼`-classes in a maximal interval of `R` are elementarily equivalent (taken as substructures of
  `M`)."*
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma5.lean` (new).
- **Tasks**:
  - [ ] Prove the first statement, transcribing printed p.178: find `B` true at points only if `A`
        occurs somewhere in their class (expressive completeness + `ε`); use `¬B` if necessary; the
        `B`-to-`¬B` transition point `s` is a left endpoint; Prior-U forbids `B` arbitrarily soon
        after the gap; then `C` ("we are now in a class whose left hand end point is also in the
        class and at that point `K⁻(B)` holds") is true in `s`'s class and false afterwards,
        contradicting Prior-U.
  - [ ] Prove the second statement: relativize a monadic sentence `φ` to `ε(x,−)`, obtain `φ'` of
        one free variable, apply expressive completeness, and conclude by the first statement.
  - [ ] Land the **relativization operator** `relativizeToClass ε φ` as a named, reusable
        definition — Phase 25 (Lemma 12) needs exactly the same operator for `γ(z,t)`.
  - [ ] Docstring: `Reynolds 1992, §6 Lemma 5, printed p.178`.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~380 lines.
- **Done when**: both statements sorry-free and axiom-clean; `relativizeToClass` is named and
  reusable.
- **Depends on**: 18.
- **Timing**: 7 hours.
- **Decomposition protocol**: as Phase 18.

### Phase 20: Reynolds §6 Lemmas 6 and 7 — bad points and bad intervals [NOT STARTED]

- **Goal**: *"Bad points only occur in non-singleton bad intervals. In any bad interval both `R` and
  `L` hold throughout. Any bad interval, if bounded, has excluded end points in `M`"* (Lemma 6);
  *"If a formula `B` is true for a while at the start of a `∼`-class in a bad interval then it holds
  throughout the bad interval. Similarly at the end. If a formula is true anywhere in a bad interval
  it is true arbitrarily close to each end of each class in the interval"* (Lemma 7).
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/BadIntervals.lean` (new).
- **Tasks**:
  - [ ] Define *bad point* (`R ∨ L` holds) and *bad interval* (non-empty maximal interval in which
        `R ∨ L` holds throughout), verbatim from printed p.178.
  - [ ] Prove Lemma 6, transcribing printed pp.178-179: `L` holds wherever `R` does, via the case
        analysis on whether a class includes its left endpoint or begins just after a point of `M`,
        closed by the formula `B` true at times which are not left endpoints of their classes,
        against Prior-U. Then mirror images.
  - [ ] Prove Lemma 7, transcribing printed p.179: for `γ < δ` gaps with `(γ,δ)` a class in a bad
        interval, the formula `C` true only at points within a class after some `¬B` in that class
        is false at the start and true at the end of each class, hence true up to the gap and false
        arbitrarily soon after — contradicting Prior-U. Second part by applying the first to `¬B`.
  - [ ] Docstrings: `Reynolds 1992, §6 Lemma 6 / Lemma 7, printed pp.178-179`.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines.
- **Done when**: both lemmas sorry-free and axiom-clean.
- **Depends on**: 19.
- **Timing**: 7 hours.
- **Decomposition protocol**: as Phase 18 — split at the Lemma 6 / Lemma 7 boundary if needed.

### Phase 21: Reynolds §6 Lemma 8 — truth preservation under bad-interval surgery [NOT STARTED]

- **Goal**: *"For all temporal formulas `A`, for all `t ∈ N`, `M ⊨ A(t)` iff `N ⊨ A(t)"`*, where
  `N` is `M` with a whole bad interval `Q₀` replaced by one of its `∼`-classes `I`.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/TruthTransfer.lean` (new).
- **Tasks**:
  - [ ] Define the surgered structure `N` with domain `Q⁻ ∪ I ∪ Q⁺` (printed p.179).
  - [ ] Prove Lemma 8 by induction on `A`, transcribing all thirteen cases from printed pp.179-180:
        seven forward `U(A,B)` cases and six backward, with `S(A,B)` by the mirror. Each case's
        justification is written out in the source; Lemma 7 is what closes cases 2, 3, 5 and 6 in
        both directions.
  - [ ] Compare against the landed `truth_transfer` (`WeakCanonical/NEquivalence.lean` /
        `IntegerModel/`) and reuse whatever transfers; record what does and does not.
  - [ ] Docstring: `Reynolds 1992, §6 Lemma 8, printed pp.179-180`, with the case numbering
        preserved so a reader can check the transcription case by case.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~500 lines.
- **Done when**: Lemma 8 is sorry-free and axiom-clean with all thirteen cases discharged (no case
  closed by `admit`-shaped hand-waving, no case merged without a stated reason).
- **Depends on**: 20.
- **Timing**: 9 hours.
- **Decomposition protocol**: as Phase 18 — the `U` / `S` boundary and the forward / backward
  boundary are both clean seams.

### Phase 22: Reynolds §6 Lemma 9 and Theorem 4 — D1 [NOT STARTED]

- **Goal**: **D1.** *"In fact there can't have been any bad points anyway"* (Lemma 9), hence
  *"Suppose that `∼` is a contemporaneous equivalence relation on a Prior structure `M`. Then the
  `∼`-classes do not end at gaps"* (Theorem 4).
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/NoGaps.lean` (new).
- **Tasks**:
  - [ ] Prove Lemma 9, transcribing printed p.180: by Lemma 8, `R` holds in `I` in `N`; by Lemma 2,
        `R` holds in *any* Prior structure exactly at points whose class ends in a gap, and `N` **is**
        a Prior structure (*"we still have all the instances of Prior-U/S continuing to hold as any
        counterexample point in `N` is also one in `M`"*); by contemporaneity of `ε`, `I` is in one
        `∼_N`-class; `R` true of that class makes it bounded above, so `Q⁺` is non-empty and by
        Lemma 6 begins with a point `q` at which `¬R` holds — so the class ends just before `q` and
        `R` cannot have been true. The step "`N` is a Prior structure" is the one that needs care in
        Lean: state it as its own named lemma.
  - [ ] Land `no_gaps_dense_prior` — **Theorem 4**, the D1 hypothesis of Doets' theorem — stated so
        that Phase 29 can consume it directly.
  - [ ] **Anti-vacuity**: instantiate D1 at `chronicleIsDensePriorSepStructure` (Phase 16) and land
        the instance as a named lemma. Without this, D1 could be true of nothing.
  - [ ] Docstrings: `Reynolds 1992, §6 Lemma 9 and Theorem 4, printed pp.180-181`.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~300 lines.
- **Done when**: Lemma 9 and `no_gaps_dense_prior` are sorry-free and axiom-clean, and the chronicle
  instance is landed.
- **Depends on**: 21.
- **Timing**: 6 hours.
- **BLOCK F CHECKPOINT**: D1 is the harder of Doets' two hypotheses and it is now available at the
  dense instance. Clean stopping point.

### Phase 23: Reynolds §7 Theorem 5 — D2 from `Axiom.sep` [NOT STARTED]

- **Goal**: **D2.** *"Suppose that `M` is a Prior structure which also satisfies every substitution
  instance of axiom Sep. Then for every contemporaneous equivalence relation `∼` such that `M/∼` is
  densely ordered, `M/∼` has a dense set of singletons."*
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Singletons.lean` (new).
- **Tasks**:
  - [ ] Prove that the classes are **closed intervals**, from Theorem 4 plus density: *"if a class
        has an excluded end point then this point is in the next class and this contradicts
        density"* (printed p.184).
  - [ ] Prove Theorem 5, transcribing printed pp.184-185: with `c < d`, `c ≁ d`, `c` the right
        endpoint of its class, let `C` be true exactly at left endpoints of classes (**expressive
        completeness**, Phase 14); `C ∧ U(C,¬C)` never holds, so `¬K⁺(C ∧ U(C,¬C))` holds at `c`;
        `K⁺(C)` holds at `c`; Sep gives `K⁺(K⁺C ∧ K⁻C)` at `c`; some `e` between `c` and `d` has
        `K⁺C ∧ K⁻C` and must be in a class of its own.
  - [ ] Land `dense_singletons_of_sep` — the D2 hypothesis of Doets' theorem.
  - [ ] **Anti-vacuity**: instantiate at `chronicleIsDensePriorSepStructure` (Phase 16) and land the
        instance.
  - [ ] Docstrings: `Reynolds 1992, §7 Theorem 5, printed pp.184-185`, quoting *"We use expressive
        completeness here"* at the point where Phase 14 is consumed — that sentence is the reason
        Block D exists and the docstring should say so. **Reynolds' Lemma 10 (Sep's validity over
        real flows, printed p.184) is NOT re-derived**: `sep_valid` (`Metalogic/Soundness.lean:1601`)
        is already landed and is already stated at `ValidDedekindDense` — the exact predicate this
        task's terminus uses. Phase 23 consumes `Axiom.sep`'s *derivability side* (every
        substitution instance is a theorem at `fc := FrameClass.Dedekind`, hence in every MCS),
        exactly as Phase 16 does for Prior-U/Prior-S.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~300 lines.
- **Done when**: `dense_singletons_of_sep` and the closed-interval lemma are sorry-free and
  axiom-clean; the chronicle instance is landed.
- **Depends on**: 22.
- **Timing**: 6 hours.
- **BLOCK G CHECKPOINT**: both of Doets' hypotheses, D1 and D2, are now available.

### Phase 24: Reynolds §8 Lemma 11 — countable + very good ⇒ good, at `ℝ`-intervals [NOT STARTED]

- **Goal**: `goodDense`, `veryGoodDense` and *"If `N` is countable and very good then it is good"*.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/GoodDense.lean` (new).
  **`IntegerModel/GoodStructures.lean` is read, not edited.**
- **Tasks**:
  - [ ] Define `RIntervalStructure sig` (the `ℝ`-interval analogue of `ZIntervalStructure`),
        `goodDense M` (`∃ R : RIntervalStructure sig, KEquiv sig k M (R.toOrdered sig)`) and
        `veryGoodDense M` (`∀ t < u`, `M|(t,u)` non-empty and good). **These are genuinely new
        definitions, not instantiations.** The landed `good` (`GoodStructures.lean:78`) is
        `∃ Z : ZIntervalStructure sig, KEquiv sig k M (Z.toOrdered sig)` and the landed `VeryGood`
        (`:86`) quantifies over **closed** `a ≤ b`; Reynolds' dense forms (printed p.186) use
        **open** intervals and strict `t < u`. Record the difference in the docstring; it is not
        cosmetic — the open/closed choice is what makes Lemma 11's `Σ_{i∈ℤ}(N|{aᵢ} + Rᵢ)` have flow
        isomorphic to `ℝ` rather than to a `ℤ`-indexed sum of closed intervals.
  - [ ] Prove Lemma 11, transcribing printed p.186: for `N` with no endpoints choose `aᵢ` (`i ∈ ℤ`)
        increasing and cofinal both ways; `N|(aᵢ,aᵢ₊₁)` is good, so take `Rᵢ ≡ₖ N|(aᵢ,aᵢ₊₁)` with an
        open real interval as flow; then `N ≡ₖ Σ_{i∈ℤ}(N|{aᵢ} + Rᵢ)`, whose flow is isomorphic to
        `ℝ`. Consume `doets_lemma_1_4` (`OrderedSum.lean`) for the `≡ₖ`-preservation step. Then the
        one- and two-endpoint cases by adding singleton structures.
  - [ ] Docstring: `Reynolds 1992, §8 Lemma 11, printed p.186` (attributed there to
        `[8] lemma 6.4`), plus `ADAPTED-FROM: IntegerModel/GoodStructures.lean` naming the `ℤ`
        analogue (Reynolds Lemma 14, printed p.190) and what changed.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~380 lines.
- **Done when**: `goodDense`, `veryGoodDense` and Lemma 11 sorry-free and axiom-clean.
- **Depends on**: 22.
- **Timing**: 7 hours.

### Phase 25: Reynolds §8 Lemma 12 — `ε(x,y)` defines `∼_M`, and the finite `γ`-set [NOT STARTED]

- **Goal**: *"There is a monadic formula `ε(x,y)` which defines `∼_M` as a contemporaneous
  equivalence relation on the domain of any `M`. Furthermore, there is a finite set `{γᵢ}` of
  sentences such that `M` is good if and only if `M ⊨ γᵢ` for some `i`."*
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/EpsilonDense.lean` (new).
- **Tasks**:
  - [ ] Define `∼_M` by Reynolds' three clauses (printed p.186): `a = b`, or `a < b` and `M|(a,b)`
        very good, or `b < a` and `M|(b,a)` very good.
  - [ ] Land the finite `γ`-set: *"There are only finitely many logically inequivalent maximal
        consistent conjunctions `γ` of sentences of quantifier depth `≤ k`"* — consume the tree's
        `NormalForm` / `nf_nvar_exist_all_depths` layer rather than rebuilding it, and record which
        declarations discharge finiteness.
  - [ ] Define `ε(x,y)` verbatim from printed p.187, via `γ(z,t)` = relativization of `⋁γᵢ` to
        `(z,t)` and `γ'(z,t) = γ(z,t) ∧ ∃u(z<u<t)` — reusing Phase 19's `relativizeToClass`. Note
        the **open**-interval relativization, versus the closed `[z,t]` of the discrete Lemma 15.
  - [ ] Prove `ε` defines `∼_M` and that `∼_M` is a contemporaneous equivalence relation, with the
        transitivity argument transcribed (the `a < t < b < u < c` case via `R₁ + R₂ + R₃`).
  - [ ] Docstring: `Reynolds 1992, §8 Lemma 12, printed pp.186-187`, plus `ADAPTED-FROM` naming
        Lemma 15 (printed p.191) and the closed/open difference.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines.
- **Done when**: `ε`, the `γ`-set, and both properties are sorry-free and axiom-clean.
- **Depends on**: 22. **Parallel-eligible with Phase 24** (disjoint files).
- **Timing**: 7 hours.

### Phase 26: Reynolds §8 Lemma 13 and the `ℚ`-shuffle [NOT STARTED]

- **Goal**: *"For any structure `M`, if there are no `∼_M` classes ending at gaps then they are all
  closed intervals"* (Lemma 13), and the shuffle `Σ_{t∈ℚ} π(t)` with its `≡ₖ` property.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/Shuffle.lean` (new).
- **Tasks**:
  - [ ] Prove Lemma 13, transcribing printed p.187: classes are intervals; a class ending at an
        excluded point `b` would make `M|(c,b)` very good, which is the contradiction.
  - [ ] Define `Shuffle S π` for a finite set `S` of structures and `π : ℚ → S` dense in every
        interval (printed p.186), and prove it well defined up to isomorphism.
  - [ ] Prove `M|(⋃I) ≡ₖ Σ_{q∈ℚ} σ(q)` for the density-of-`γᵢ` situation of the main proof, using
        `doets_lemma_1_4`.
  - [ ] Docstrings: `Reynolds 1992, §8 Lemma 13, printed p.187` and `§8 (the shuffle), printed
        p.186`.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~350 lines.
- **Done when**: Lemma 13 and the shuffle's `≡ₖ` property are sorry-free and axiom-clean.
- **Depends on**: 24, 25.
- **Timing**: 7 hours.

### Phase 27: The `ℝ`-extension of the shuffle, its Dedekind completeness and its countable dense subflow [NOT STARTED]

- **Goal**: `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)` where `σ*` is `σ` extended by singletons at the
  irrationals; plus the flow `R` of `Σ_{r∈ℝ} σ*(r)` is dense, endpointless, **Dedekind complete**,
  and has a countable dense subflow.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` (new).
- **Tasks**:
  - [ ] Define `σ*` (printed p.188): `σ*(i) = N_{γ₁}` for `i ∈ ℝ − ℚ`, where `γ₁` is a `γ` in `G`
        satisfied only by one-point structures.
  - [ ] **Land `doets_lemma_1_5` in live code** — the phase's centre of gravity. **Do not attempt
        Reynolds' one-line "another simple game argument" directly**; charter it against
        **Doets 1987, 3.1.8**: *"if `(I, {i | m(i) ⊨ σ})_{σ∈Z} ≡ⁿ (J, {j | m'(j) ⊨ σ})_{σ∈Z}` then
        `Σ_{i∈I} m(i) ≡ⁿ Σ_{j∈J} m'(j)`"*, which reduces the claim to a `≡ⁿ` fact about the
        `Z`-coloured orders `(ℚ,…)` and `(ℝ,…)`. Consume `NEquivalence.lean`'s `KEquiv` / `kTypeOf`
        / `KType` apparatus for that fact, and `doets_lemma_1_4` (`OrderedSum.lean:41`) for the
        same-index-set case.
        **A statement template exists and must be re-stated, not un-archived**: the drafted
        `doets_lemma_1_5` at `Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean:58` sits
        behind `#exit` (line 41), uses the stale names `k_type_of` / `k_equiv`, and its body is
        `sorry`. Copy the *shape* — `(I J : Type) [LinearOrder I] [LinearOrder J]`, the
        `h_matching` hypothesis over `KType sig k`, the `orderedSum` conclusion — into a live
        module under the live names `kTypeOf` / `KEquiv`, and **prove it**. Do not import
        `Boneyard`, and do not reintroduce the `sorry`.
  - [ ] Update the forward pointer at `OrderedSum.lean:20-22` and the archive note at
        `SingletonSorriedDecls.lean:19-24` — or, if editing them is out of the phase's territory,
        record in the summary that they are now stale.
  - [ ] Apply `doets_lemma_1_5` to obtain `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)`.
  - [ ] Prove Dedekind completeness of `R`, transcribing printed p.188: *"any subset bounded above
        intersects a last summand. Because the `γᵢ`'s say so the summands themselves are closed
        intervals of the reals so the supremum of the set exists in this class."*
  - [ ] Prove `R` has a countable dense subflow, transcribing printed p.188: take `σ*(q)` itself for
        each `q ∈ ℚ` when it is a singleton, else a countable dense subset of the interval; conclude
        via density of `ℚ` in `ℝ` and the fact that irrational `r` have singleton `σ*(r)`.
  - [ ] Docstrings: `Reynolds 1992, §8, printed p.188` for each part, plus
        `ADAPTED-FROM: Doets 1987, 3.1.8` for the mixing argument, with a one-clause note that
        Reynolds asserts it without proof.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~500 lines.
- **Done when**: **`doets_lemma_1_5` is landed in live code, sorry-free and axiom-clean, under the
  live names**; the mixing `≡ₖ`, Dedekind completeness, density, endpointlessness and separability
  of `R` are all sorry-free and axiom-clean; the sorry census outside `Boneyard/` is still exactly
  `Transfer.lean:1242`.
- **Depends on**: 26.
- **Timing**: 10 hours.
- **Decomposition protocol**: as Phase 18 — `doets_lemma_1_5` and the three order-theoretic facts
  are a clean seam, and splitting there is the expected outcome if the `≡ⁿ` colouring fact resists.

### Phase 28: `orderIsoRealOfDedekindDenseSeparable` — the order characterization of `ℝ` [NOT STARTED]

> **Confirmed absent from Mathlib at this revision.** `Order.iso_of_countable_dense`
> (`Mathlib.Order.CountableDenseLinearOrder`) gives Cantor's theorem for countable dense
> endpointless orders; for `ℝ` only *field*-theoretic uniqueness exists
> (`ConditionallyCompleteLinearOrderedField`, `Mathlib.Algebra.Order.CompleteField`). The
> order-theoretic characterization must be built. Reynolds asserts it in one sentence (printed
> p.188): *"But then `R` being Dedekind complete, dense, without end points and with a countable
> dense subset must be isomorphic to the reals."*

- **Goal**: For a linear order `R` that is densely ordered, without endpoints, Dedekind complete
  (every non-empty bounded-above subset has a lub), and has a countable dense subset: `Nonempty (R ≃o ℝ)`.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/OrderIsoReal.lean` (new).
- **Proof skeleton (transcribe, do not re-derive)**:
  1. The countable dense subset `D ⊆ R` is itself densely ordered and without endpoints (density of
     `D` in `R` plus `R` dense and endpointless), and non-empty; so `Order.iso_of_countable_dense`
     gives `e : D ≃o ℚ`.
  2. Define `f : R → ℝ` by `f x = sSup (Rat.cast '' (e '' {d : D | (d:R) < x}))`.
  3. Monotone and injective by density of `D`; surjective by Dedekind completeness of `R` against
     completeness of `ℝ`; conclude `R ≃o ℝ`.
- **Tasks**:
  - [ ] Land the hypothesis bundle as a named `structure` (dense, no endpoints, lub property,
        separable) with **Rule 6**'s "what this excludes" docstring paragraph.
  - [ ] Prove step 1 and land it as a named lemma.
  - [ ] Prove steps 2-3 and land `orderIsoRealOfDedekindDenseSeparable`.
  - [ ] **Anti-vacuity**: instantiate at `ℝ` itself and at one non-trivial example; if the only
        instance is `ℝ`, say so.
  - [ ] Docstring per honesty charter Rule 4: the *statement* is `Reynolds 1992, §8, printed p.188`;
        the *proof* has **no source in the corpus** (Reynolds asserts it) and is original work.
  - [ ] Search Mathlib once more before writing (`loogle`, `leansearch`) and record the negative
        result in the docstring, so a future reader does not repeat the search.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~350 lines.
- **Done when**: `orderIsoRealOfDedekindDenseSeparable` is sorry-free and axiom-clean and the
  anti-vacuity instantiation lands.
- **Depends on**: — (independent of Blocks D-G; **parallel-eligible from wave 1 onward**).
- **Timing**: 7 hours.

### Phase 29: Doets' Theorem — Reynolds §8 Theorem 6 [NOT STARTED]

- **Goal**: `doets_theorem_dense`: *"Suppose that `M` is a temporal structure in a finite language
  whose flow of time is countable, dense and without end points. Suppose further that for any
  contemporaneous equivalence relation `∼` on `M`, D1) the `∼` classes do not end in gaps and D2) if
  `M/∼` is densely ordered, then `M/∼` has a dense set of singletons. Then for all `k < ω`, there is
  a temporal structure with flow of time the real numbers satisfying the same monadic first-order
  sentences of quantifier depth at most `k` as `M` does."*
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean` (new).
- **Tasks**:
  - [ ] Assemble the proof, transcribing printed pp.187-188: if `M` is good, done. Otherwise by
        Lemma 11 there are ≥ 2 `∼`-classes; by Lemma 13 and D1 there is a third between any two, so
        `M/∼` is dense and D2 gives density of singletons. Choose `a < b` with `a ≁ b` and `G`
        minimal; show `M|(a,b)` is very good, contradiction. For `a < c < d < b` with `c ≁ d`: the
        classes strictly between have order type `ℚ` and by minimality all `γᵢ ∈ G` are dense in
        `I`, so `M|(⋃I) ≡ₖ` a shuffle (Phase 26); extend to `ℝ` (Phase 27); the flow is `≅o ℝ`
        (Phase 28); and `M|(c,d) ≡ₖ X + R + Y` (Phase 24 + `doets_lemma_1_4`).
  - [ ] Land the statement so that Phase 30 can consume it with `D1 := no_gaps_dense_prior` and
        `D2 := dense_singletons_of_sep` at the chronicle structure.
  - [ ] **Anti-vacuity**: instantiate at `chronicleIsDensePriorSepStructure` (Phase 16) with the D1
        and D2 instances from Phases 22-23, and land the resulting `ℝ`-flowed structure as a named
        definition. This is the phase's real deliverable.
  - [ ] Docstrings: `Reynolds 1992, §8 Theorem 6, printed pp.185-188` and
        `Doets 1987, 3.3.9` (*"If `M` is definably-`I`, definably complete and densely ordered
        without endpoints, then it has `n`-equivalents of order type `λ` for each `n`"*), with
        Reynolds' own note that his statement is slightly stronger and his proof a little different
        because of the contemporaneity notion.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines.
- **Done when**: `doets_theorem_dense` and the chronicle instantiation are sorry-free and
  axiom-clean.
- **Depends on**: 23, 27, 28.
- **Timing**: 8 hours.
- **BLOCK H CHECKPOINT**: an `ℝ`-flowed structure `≡ₖ`-equivalent to the chronicle model now exists.

### Phase 30: Reynolds §9 Theorem 7 — the engine and the unconditional terminus [NOT STARTED]

> **This phase absorbs v6's Phase 8.** Its precondition is no longer the discharge of
> `BFMCS.LimitGuardEventual` (retired) but the availability of `doets_theorem_dense` at the
> chronicle structure. **The `consequence_completeness_dedekind_of_engine` pinned signature and
> commit `bd9ae0ac1` carry over unchanged.** There is no conditional terminus.

- **Goal**: `countermodel_dedekind_dense`, `completeness_dedekind_engine`, and then — by
  instantiating the **pinned, unmodified** Phase 2 theorem — `consequence_completeness_dedekind`
  and `completeness_dedekind`.
- **Owns**: `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (extends v6 Phase 1),
  `FormalSystem/Metalogic/StrongCompleteness.lean` (extends v6 Phase 2),
  `FormalSystem/Metalogic.lean` (tracking table).
- **Tasks**:
  - [ ] Define the **table** `α(t)` of a `Formula` and its quantifier depth, or verify that the
        tree's existing `tableMu` / `staviFoDepth` layer (`EFGames/StaviCompleteness.lean:237,462`)
        already supplies it; record which. Set `k` to one greater than the depth, per printed p.189.
  - [ ] Prove the transfer: `R ⊨ ∃t α(t)` from `M ⊨ ∃t α(t)` via `≡ₖ`, obtain `b ∈ R` with
        `R ⊨ α(b)`, hence `R ⊨ A₀(b)`.
  - [ ] Convert the `ℝ`-flowed monadic structure back to a `TaskFrame ℝ` + `TaskModel` + shift-closed
        `Omega`, using Phase 15's `multiFamTaskFrameGen` and its `Omega`/shift-closure siblings at
        `D := ℝ` (the `ℤ` originals at `ReynoldsBridge.lean:671,694,708` stay byte-identical), and
        land `countermodel_dedekind_dense
        {fc} (hfc : FrameClass.Dedekind ≤ fc) (A) (h_mcs) (φ) (h_neg_in) (h_box_dense) :
        ∃ (F : TaskFrame ℝ) (TM : TaskModel F) (Omega) (_ : ShiftClosed Omega) (τ) (_ : τ ∈ Omega)
        (t : ℝ), ¬TruthAt TM Omega τ t φ`. Follow `countermodel_dense_enriched`
        (`Completeness.lean:133`) statement-for-statement with `Rat → ℝ`. **Do not add any
        hypothesis beyond `hfc`.**
  - [ ] Prove `completeness_dedekind_engine (ψ : Formula) : ValidDedekindDense ψ →
        Derivable FrameClass.Dedekind [] ψ`: contrapositive, `neg_consistent_of_not_derivable
        (fc := FrameClass.Dedekind)` (`Completeness.lean:72`), `set_lindenbaum`,
        `dedekind_box_dense_mem` (`CompletenessDedekind.lean:149`) for the box-dense hypothesis,
        then `countermodel_dedekind_dense` at `ℝ` with `real_lub_of_bddAbove`
        (`CompletenessDedekind.lean:127`) discharging the lub binder and `by decide` discharging
        `hfc`.
  - [ ] Instantiate `consequence_completeness_dedekind_of_engine` (`StrongCompleteness.lean:274`)
        with this engine to obtain the unconditional `consequence_completeness_dedekind`. **Do not
        restate or re-bind that signature** — pinned by commit `bd9ae0ac1`.
  - [ ] Derive `completeness_dedekind (φ : Formula) : ValidDedekindDense φ →
        Derivable FrameClass.Dedekind [] φ` as `consequence_completeness_dedekind []`, with `simp`
        discharging `∀ ψ ∈ [], _`. **It must be a corollary, not an independent proof.**
  - [ ] Verify the root placement: the evaluation family's value at `t = 0` is the root MCS `A`,
        composing with `rooted_cantor_fmcs_dense_at_s` (`ChronicleToCountermodelBasic.lean:513`).
        A mismatch here is silent. Land it as a named lemma, not an inline `have`.
  - [ ] `#print axioms consequence_completeness_dedekind` and `#print axioms completeness_dedekind`;
        record. Regression: `#print axioms completeness_dense`, `completeness_discrete`,
        `countermodel_discrete_reynolds_v2`.
  - [ ] Update the tracking table in `FormalSystem/Metalogic.lean` with the Dedekind rows, matching
        the existing `Completeness (dense)` / `(discrete)` row format at `:37`,`:39`.
  - [ ] Docstrings: `Reynolds 1992, §9 Theorem 7, printed p.189`, quoting the five proof steps, and
        `Reynolds 1992, §2, printed p.169` for the definition of weak completeness that makes the
        finite-context form fall out.
  - [ ] Full `lake build` green.
- **Estimated output**: ~450 lines.
- **Done when**: `consequence_completeness_dedekind` and `completeness_dedekind` are sorry-free;
  full `lake build` green; `#print axioms` on both shows exactly
  `[propext, Classical.choice, Quot.sound]`; the three regression axiom sets are unchanged; the
  tracking table is updated; the two frozen chronicle files are byte-identical.
- **Depends on**: 29 (and, through it, all of Blocks D-H).
- **Timing**: 8 hours.

---

## Testing & Validation

Run at the end of **every** phase, not only at the end of a block:

- [ ] Scoped build green: `lake build <the phase's owned module>`.
- [ ] Full `lake build` green. If a full build is not achievable within the dispatch, the sanctioned
      fallback is a scoped build of the aggregator that transitively covers the phase's module — and
      **the fallback must be recorded honestly in the summary and handoff**, naming which build ran
      and which did not. A scoped build reported as a full build is a defect.
- [ ] Sorry census unchanged: `grep -rnE "^\s*sorry\s*$|:= sorry|by sorry|exact sorry" FormalSystem/
      --include=*.lean | grep -v Boneyard` returns exactly
      `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`.
- [ ] `#print axioms` on every load-bearing declaration the phase introduces = exactly
      `[propext, Classical.choice, Quot.sound]`. Record the results in the summary.
- [ ] **Regression canaries**: `#print axioms completeness_dense`,
      `#print axioms completeness_discrete`, `#print axioms countermodel_discrete_reynolds_v2` —
      unchanged. Mandatory for every Block D phase; recommended for all.
- [ ] **Frozen files byte-identical**: `git diff --stat` shows no change to
      `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` or
      `.../ChronicleToCountermodelBasic.lean`. Also `ChronicleConstruction.lean`,
      `CounterexampleElimination.lean` and `cantorIsoDense`.
- [ ] **Amputated layer intact**: every module in the Amputated Assets table still compiles and is
      unmodified.
- [ ] **Territory respected**: no file under `FormalSystem/Metalogic/Decidability/` or
      `FormalSystem/Automation/` read for edit, modified, or staged.
- [ ] **No vacuous definitions**: every `Prop`-valued hypothesis the phase introduces has a witness,
      a derivation, or an exclusion lemma (the anti-vacuity gate). Record which.
- [ ] **Docstring audit**: every new declaration carries a source citation with a printed page
      (or, for the exhaustively named originals, the no-source statement). Any printed page landed
      in a docstring was re-verified against the PDF in this dispatch, or is flagged as carried.
- [ ] No task-number citations in any file outside `specs/`.

At Phase 30 additionally:

- [ ] `#print axioms consequence_completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `FormalSystem/Metalogic.lean` tracking table updated.

---

## Artifacts & Outputs

| Artifact | Path | Produced by |
|---|---|---|
| This plan | `specs/408_.../plans/07_strong-completeness-dedekind-v7.md` | this revision |
| Per-phase summary | `specs/408_.../summaries/07_phase-{N}-{slug}-summary.md` | each phase |
| Per-phase handoff | `specs/408_.../handoffs/phase-{N}-handoff-{DATE}.json` | each phase |
| Orchestrator handoff | `specs/408_.../.orchestrator-handoff.json` | this revision, then each phase |
| Dense Prior hypotheses | `FormalSystem/Metalogic/WeakCanonical/PriorDefsDense.lean` | Phase 9 |
| Faithful INF/SUP at dense flows | `.../WeakCanonical/Kamp/DedekindINFDense.lean` | Phase 10 |
| Rabinovich re-base | `.../Kamp/EANegationFix/{OnBuilder,NegFix,VecEANegFix}Faithful.lean` | Phases 11-13 |
| Dense expressive completeness | `.../WeakCanonical/PriorExpressivenessDense.lean` | Phase 14 |
| Dense monadic bridge | `.../BXCanonical/Chronicle/ChronicleMonadicBridge.lean` | Phases 15-16 |
| Reynolds §6 (D1) | `.../WeakCanonical/DenseModelSurgery/*.lean` | Phases 17-22 |
| Reynolds §7 (D2) | `.../WeakCanonical/DenseModelSurgery/Singletons.lean` | Phase 23 |
| Doets' theorem | `.../WeakCanonical/RealModel/*.lean` | Phases 24-29 |
| Terminus | `.../BXCanonical/CompletenessDedekind.lean`, `.../StrongCompleteness.lean`, `FormalSystem/Metalogic.lean` | Phase 30 |

Commit convention: `task 408 phase {N}: {objective}`, with a `Session:` line in the body, staging
only the task directory plus the files the phase's Tasks list names. `git add -A` and
`git commit -am` are forbidden.

---

## Rollback/Contingency

**Per-phase rollback.** Every phase owns a new module (except Phase 30, which extends two existing
ones). Rolling back a phase is deleting its module and its aggregator import line. No phase modifies
a preserved asset, so no rollback touches landed mathematics.

**Phase 10 is the route's single point of failure.** If `HasDedekindINF` does not follow from the
dense Prior axioms, the Doets route is refuted at the same place the completion route was — a
hypothesis the axioms do not supply. In that event: mark Phase 10 `[BLOCKED]` with the exact goal
state, do **not** dispatch Phase 11 or anything downstream, and escalate. The task's honest floor is
`[PARTIAL]` with v6's Phases 1-2 and the rational chronicle landed and both routes refuted. **Do not
soften a Phase 10 failure into a strategic sorry, a conditional terminus, or an over-strong
hypothesis.** Those are exactly the three moves this task's history forbids.

**Block-level contingency (R2, R3).** Any phase in Blocks D or F that on contact needs more than one
agent run lands whatever is green, records a named sub-phase list, and reports `[PARTIAL]`. The
orchestrator revises to v8 with the sub-phases spliced in at the same numeric level (flat numbering
`N.1`, `N.2`, … — the scan admits **at most one** dot segment, so three-level numbering would be
invisible to dispatch). This is the chartered outcome, not a failure, and it is how v6's Phase 7.5
correctly became 7.5-7.9.

**Budget contingency (R8).** Every phase ends with the tree green, the sorry census unchanged and
the frozen files byte-identical, so every phase boundary is a clean stop. Running out of budget
yields `[PARTIAL]` with a named next phase. The five block checkpoints (after Phases 14, 16, 22, 23
and 29) are the natural reporting points, and each leaves a reusable result of independent value in
the tree.

**Fallback route (recorded, not planned).** If Block D's re-base proves intractable, Reynolds' own
proof of Theorem 3 is available in principle: reduce to `{U,S,U',S'}` expressive completeness
(Theorem 2 / GHR93 Theorem 9.3.1) and show `U'(A,B) ↔ ⊥` in every Prior structure by applying
Prior-U to `B`. The tree's `stavi_U_false_on_prior_UZ` (`PriorExpressiveness.lean:90`) is exactly
that argument at the *integer* axioms and would mirror cheaply, and the whole Stavi layer
(`StaviConnectives.lean`, 583 lines: `StaviUTruth` `:79`, `StaviSTruth` `:110`, `StaviFormula`
`:140`, `flattenStavi` `:446`, `flatten_stavi_correct` `:497`) is present and sorry-free.
**The blocker is the other half**: verified at this revision, `stavi_expressive_completeness`
**does not exist as a declaration anywhere in live code** — it survives only at
`FormalSystem/Boneyard/StaviDiscretePath/StaviExpressiveCompletenessTail.lean:1674`, its chain top
is sorry-tainted, `EFGames/StaviCompleteness.lean:16` records it as "the dead expressive-completeness
tail", and `PriorExpressiveness.lean:30,350` records that the tree deliberately moved off it onto
`kampPriorExpressiveCompleteness`. Reviving a Boneyard module and discharging its sorry is strictly
more work and strictly less certain than the re-base. Recorded so a future dispatch does not
rediscover it as a novelty.

**What is never a contingency.** Re-opening completion-by-limits; stripping the amputated layer;
generalizing a landed discrete declaration in place; a conditional terminus; a strategic sorry on
the terminus chain; or an over-strong hypothesis that makes a theorem pass vacuously.
