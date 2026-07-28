# Implementation Plan: Weak + Finite-Context Consequence Completeness for FrameClass.Dedekind (v8 — the Doets route, Block D corrected)

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
> **The Doets route is SETTLED and is not re-opened by this revision.** v7's Revision Rationale
> (v6 → v7) — the Phase 7.9 refutation, the three exhausted Dedekind axioms, the user's
> authorization, the amputation of the ℝ-extension-by-limits layer, and the ten superseded v6
> sections — stands **unamended** and is not reproduced here. It is the historical record at
> `plans/07_strong-completeness-dedekind-v7.md` §"Revision Rationale (v6 → v7)". v8 changes
> **Block D and its consumers only**.

- **Task**: 408 - faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Status**: [IMPLEMENTING]
- **Effort**: **~163 hours across 25 phases**, of which **~10 hours (Phases 9 and 10) are landed**
  and **~153 hours remain**. The sum of the per-phase timings below, not a rounded guess. The
  increase over v7's 149 hours is **+14 hours, entirely in Block D**, and it is an increase in
  *honesty* rather than in ambition: v7 scheduled Phases 11-13 as a from-scratch construction of
  modules that **already exist on disk**, and under-counted the real work, which is a carrier
  re-base across **eight** landed modules totalling **3,388 lines**. See "Revision Rationale
  (v7 → v8)".
- **Dependencies**: None. Coordinates with, but is not blocked by, the concurrent decidability
  effort that owns `FormalSystem/Metalogic/Decidability/` and `FormalSystem/Automation/` (territory
  contract below).
- **Research Inputs**:
  - **handoffs/phase-10-handoff-20260728.json** (**primary for this revision**): the deviation
    record and the three route-critical findings that force it — (i) the route's single point of
    failure HELD; (ii) downstream consumes a hypothesis-free carrier, not the guarded one;
    (iii) an `EANegationFixFaithful/` subtree plus `Lemma53Faithful.lean` and `Prop42Faithful.lean`
    already exist in-tree and already consume `HasDedekindINF`.
  - **summaries/07_phase-10-dense-dedekind-inf-summary.md**
  - **summaries/07_phase-9-dense-prior-defs-summary.md**
  - **The read-only faithful-subtree survey performed at this revision** (file:line anchors
    reproduced in "Faithful-Subtree Survey" below; every anchor spot-checked against the tree).
  - **The literature corpus, read verbatim at this revision** for the K⁺ finding below
    (`rabinovich_2014/chunk_0007.md`, `chunk_0015.md`, `chunk_0016.md`, `chunk_0017.md`,
    `chunk_0018.md`; `reynolds_1992/sec01_an-axiomatization-for-until-and-since-ov.md`).
  - reports/07_r3d-limit-blocker-verdict.md (the route verdict; unamended by v8)
  - plans/07_strong-completeness-dedekind-v7.md (superseded predecessor; its Revision Rationale
    (v6 → v7) and its Phases 9-10 execution record stay there as history)
- **Artifacts**: plans/08_strong-completeness-dedekind-v8.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4
- **Phases**: **25 total**, numbered **9, 10, 10.1, 11, 11.1, 12, 12.1, 13, 14, … 30**.
  `phases_total = 25`, `phases_completed = 2` (Phases 9 and 10, both `[COMPLETED]`),
  `phases_dispatchable = 23`. Next dispatch target: **Phase 10.1**.
  **Numbering decision (binding).** The orchestrator's phase scan is
  `grep -E '^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]' … | head -1`,
  which admits **at most one** dot segment and dispatches the **first** matching heading in file
  order. v8 therefore inserts the four new units as `10.1`, `11.1`, `12.1` and re-scopes `11`,
  `12`, `13` **in place**, so that **no phase from 14 through 30 is renumbered** and every
  cross-reference in Blocks E-I carries forward unchanged. v7's alignment of phase number to
  source lemma is preserved: **11 = Rabinovich Lemma 5.3, 12 = Lemma 5.1, 13 = Prop 4.2**.
- **reports_integrated**: 01_faithful-route-strong-completeness.md,
  02_literature-coverage-audit.md, 03_limit-future-witness-blocker.md,
  04_backward-transport-blocker.md, 05_forward-guard-r3-research.md,
  07_r3d-limit-blocker-verdict.md

---

## Revision Rationale (v7 → v8)

**This is a targeted Block-D-and-consumers correction, not a re-plan.** The route is unchanged and
is not re-litigated. Phases 15-30 (Blocks E-I) carry forward with their numbering, territory,
timings and verification gates intact. What changes is Block D, because Phase 10 landed and what it
found does not match what v7 assumed.

### The three findings that force the revision

Verbatim from `handoffs/phase-10-handoff-20260728.json`:

1. **`severity: resolved`** — *"THE SINGLE POINT OF FAILURE HELD. `prior_hasDenseDedekindINF_dense`
   and `prior_hasDenseDedekindSUP_dense` are sorry-free and axiom-clean from `SemanticPriorU` /
   `SemanticPriorS` alone, with no discreteness, no attainment and no flow completeness."*
   R1 is discharged. The route is live.
2. **`severity: plan_amendment_needed`** — *"DOWNSTREAM CONSUMES THE TRICHOTOMY, NOT THE GUARDED
   FORM. Every `.first_occ`/`.last_occ` call site outside `Boneyard/` reaches the call from a
   `by_cases` on interior occurrence of `P` in `(z₀,z₁)`, with no hypothesis about `z₀` in
   scope."* Independently re-verified at this revision at all three by-cases-reached sites
   (`Lemma53Faithful.lean:274`, `NegFixOneFaithful.lean:422`, `NegFixListFaithful.lean:446`).
3. **`severity: plan_amendment_needed`** — *"UNPLANNED, MATERIAL TO PHASES 11-13: an
   `EANegationFixFaithful/` subtree plus `Lemma53Faithful.lean` and `Prop42Faithful.lean` ALREADY
   EXIST in-tree and ALREADY consume `HasDedekindINF` … Because they are pinned at the UNGUARDED
   carrier they cannot be instantiated at any dense Prior structure. Phases 11-13 should be
   re-scoped against what is actually on disk before dispatch."*

Finding 3 is the largest single planning error corrected here. v7's Phases 11-13 were chartered to
**build** `OnBuilderFaithful.lean`, `NegFixFaithful.lean` and `VecEANegFixFaithful.lean` from
scratch, ~990 lines, ~19 hours. **Eight faithful modules totalling 3,388 lines already exist,
sorry-free and CI-protected.** The work was never construction; it is a carrier re-base.

### The fourth finding, made at this revision: the tree's `kplus` is not the sources' `K⁺`

Phase 10's handoff records a third route-critical item — that Rabinovich's *"`r₀ = z₀` iff
`K⁺(P₁)(z₀)`"* (PDF p.8) is *"FALSE read literally"*. **That attribution is wrong, and correcting
it is what makes Block D tractable.** Read verbatim from the corpus at this revision:

| Source | Location | Verbatim |
|---|---|---|
| Rabinovich 2014 | `chunk_0007.md:33` | *"`K+(F)` (respectively, `K−(F)`) is an abbreviation for `¬((¬F)UntilTrue)` (respectively, `¬((¬F)SinceTrue)`)."* |
| Rabinovich 2014 | `chunk_0007.md:39` | *"(3) `K+(F)` holds at a moment `t` iff `t = inf({t′ | t′ > t and F holds at t′})`."* |
| Reynolds 1992 | abbreviations table, §1, **printed p.168** (**re-verify against the PDF before it lands in a docstring**) | `K⁺A` — *"for `¬U(⊤,¬A)`"* — reading *"`A` will be true arbitrarily soon"* |

**Neither source's `K⁺` carries a `¬A` conjunct at the point of evaluation.** Under Rabinovich's
own Definition (3), *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is not an error at all — it is a **definitional
restatement**, true verbatim.

**And this tree already knows it.** `Formula.kPlus` (`FormalSystem/Syntax/Formula.lean:180`) is
`(untl ⊤ φ.neg).neg` — the source-exact, conjunct-free `K⁺` — and its docstring (`:163-179`) cites
Reynolds' abbreviation table at **printed p.168** and GHR 1994 §10.3.1, carrying an explicit
**name-collision warning**: it is *not* the same operator as `PriorINF.lean`'s `kplusFormula`, which
carries the extra `¬P` conjunct, and *"substituting one for the other silently transcribes a
different axiom."* `Formula.kMinus` (`:193`) is the mirror.

**The seam runs straight through Block D, and no bridge lemma exists anywhere in the tree:**

| Layer | `K⁺` used | Anchor |
|---|---|---|
| The **axioms** — `Axiom.prior_U_gap`, `Axiom.prior_S_gap`, `Axiom.sep` | `Formula.kPlus` / `Formula.kMinus` — **conjunct-free** | `ProofSystem/Axioms.lean:377`, `:387`, `:390` |
| The **Prop-level carrier** — `kplus`, `kplusFormula`, `HasDedekindINF` and all eight faithful modules | conjunct-**carrying** | `PriorINF.lean:86`, `:92-94`; `DedekindINF.lean:136` |
| **Bridge between them** | **none exists** | — |

`kplus` and `kplusFormula` are internally coherent with each other — `kplus_formula_correct`
(`Lemma53.lean:162-179`) proves them equivalent, sorry-free. **The mismatch is external**: the
carrier apparatus transcribes a different `K⁺` from the one the axioms are stated with, and the
tree's own docstring forbids exactly that substitution. Phase 9's `SemanticPriorU` is the semantic
reading of an axiom stated with the conjunct-free `Formula.kPlus`; Phase 10 landed its consequence
into a carrier stated with the conjunct-carrying `kplus`. Every symptom Phase 10 observed sits on
that seam.

**v8 takes the probe position, explicitly.** Phase 10.1 is chartered to land the missing Prop-level
`kplusOpen` **as the semantic reading of the already-existing `Formula.kPlus`**, to land the
**missing bridge lemma**, and to **re-run the interval-witness refutation against the conjunct-free
antecedent** — determining by machine, not by argument, whether the guard/trichotomy apparatus is
needed at all. The plan's central bet (R11) is falsifiable in that one dispatch and on the smallest
site. It is not assumed anywhere downstream: both carriers stay landed, and the fallback to the
trichotomy is chartered rather than improvised.

This tree's `kplus` (`FormalSystem/Metalogic/WeakCanonical/Kamp/PriorINF.lean:86`) is:

```lean
def kplus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) : Prop :=
  ¬TemporalTruth M atomMap t P ∧
  ∀ s : M.carrier, t < s → ∃ r : M.carrier, t < r ∧ r < s ∧ TemporalTruth M atomMap r P
```

— **strictly stronger than either source's `K⁺`**, by the added first conjunct. Its own docstring
says *"but not at `t` itself"*, and the comment block immediately above it
(`PriorINF.lean:75-81`) records the author mid-doubt: *"Actually wait, the Rabinovich paper uses
the notation differently."* The doubt was correct and was never resolved.

**Everything Phase 10 discovered follows from that one added conjunct, and from nothing in the
mathematics.**

- `hasDedekindINF_fails_of_interval_witness` (`DedekindINFDense.lean:455`) is a **true theorem
  about the tree's `kplus`**. At `z₀ = 1/2` on `denseWindowFlow` with `P` true exactly on `(0,1)`,
  the left disjunct `kplus M atomMap P z₀` fails *only because* `P(z₀)` holds. Under the sources'
  `K⁺` the left disjunct **holds** there — `P` is true arbitrarily soon after `1/2` — and there is
  no failure to refute.
- The endpoint guard `¬P(z₀)`, the trichotomy `HasDenseDedekindINF`, and the third disjunct
  `P(z₀)` are therefore **repairs for a formalization-level deviation**, not dense-case
  mathematical content. Phase 10's docstring calls them "original glue"; that label is right, and
  v8 records *what they are glue for*.

### Why this is decision-grade rather than cosmetic

The survey found that re-basing the two hardest consumers —
`negFixOneFaithful_cover` (`NegFixOneFaithful.lean:422`) and `negFixListFaithful_iff`
(`NegFixListFaithful.lean:446`) — **onto the trichotomy needs genuinely new proof branches**,
because their `Case1 / Case2 / Case3a/b/c` structure has no slot for a "`P` holds at `z₀`" case.
That is real, unbounded work, and it exists only because the third disjunct is uninformative:
**`P(z₀)` does not imply `r₀ = z₀`**, so a consumer that lands in it learns nothing it can use.

Onto the **source-exact `K⁺`** the same two consumers keep a **two-arm** case split — the identical
shape they have today — because the faithful carrier is a *dichotomy*, not a trichotomy. The only
change at a consumer is the *content* of the left disjunct. And the tree already discards the part
that changes: `orderedPointsExist_combine_kplus` (`Lemma53Faithful.lean:137`) opens its `kplus`
hypothesis as

```lean
  obtain ⟨-, hdense⟩ := hk
```

— the `¬P(z₀)` conjunct is **thrown away unused** at the one place disjunct (2)'s content is
consumed.

**The dichotomy is also derivable, hypothesis-free, from `SemanticPriorU` alone** — the same input
Phase 10 already used. Paper derivation at this revision (transcribe and verify; do not treat as
established): given `P` occurring in `(z₀,z₁)`, either `P` occurs arbitrarily soon after `z₀`
(the faithful left disjunct, done), or some `(z₀,s)` is `P`-free, in which case `U(⊤,¬P)(z₀)` and
`F(¬¬P)(z₀)` hold, `SemanticPriorU` at `p := ¬P` fires, and its conclusion is eq (5.2) verbatim.
No guard is needed at any step, because the case split is on the *interval*, never on `z₀`.

### What v8 does, item by item

1. **The route is unchanged.** Doets, per the user's authorization on `reports/07` verdict (b).
   Not re-opened, not re-litigated, not re-costed.
2. **Phases 9 and 10 are `[COMPLETED]` history.** Their records are preserved below in compressed
   form with their deviation annotations intact. **Nothing landed by them is deleted, reverted,
   restated or regenerated.** `DedekindINFDense.lean` and `PriorDefsDense.lean` are Preserved
   Assets from this revision forward.
3. **A new Phase 10.1 lands the source-exact `K⁺` and the faithful dichotomy carrier** beside the
   trichotomy — `kplusOpen`, `HasFaithfulDedekindINF`/`SUP`, `prior_hasFaithfulDedekindINF_dense`,
   and the shim lattice relating all four carriers. Dense siblings, nothing generalized in place.
4. **Phases 11, 11.1, 12, 12.1, 13 re-base the eight existing faithful modules** onto that carrier,
   in import-chain order, one bounded unit per phase. v7's from-scratch charters for 11-13 are
   **withdrawn as factually wrong about the tree**.
5. **Phase 10.1 also corrects two docstrings**, narrowly and by comment bytes only, so the tree
   stops asserting that a source is wrong where the source is right. This is mandatory under the
   honesty charter, which is a binding user directive.
6. **Phase 14 is re-scoped** to compose the re-based chain and `prior_hasFaithfulDedekindINF_dense`.
   Its goal, owned module and `Done when` are otherwise unchanged.
7. **Phases 15-30 are carried forward unchanged** in goal, territory, tasks, estimates, timings and
   dependencies. The only edits are dependency-arrow updates where a Block D phase number moved.
8. **The Postmortem Constraints are extended, never relaxed**, with five new binding rules drawn
   from Phase 10 (below). One existing constraint — "dense siblings, never in-place generalization"
   — is **narrowed, explicitly and with reasons**, for the eight `*Faithful*` modules only.
9. **A fallback is chartered, not assumed.** If Phase 11's measurement shows the faithful
   dichotomy does *not* collapse the case split at `NegFixOneFaithful.lean:422` /
   `NegFixListFaithful.lean:446`, the phases fall back to the trichotomy with explicit endpoint
   branches, and split under the R2 decomposition protocol. See R11.

### What v8 does NOT do

- It does not re-open the route, the terminus, the amputation, or any of v7's SETTLED decisions.
- It does not delete, revert, weaken or regenerate anything Phases 9 and 10 landed.
- It does not edit `kplus`, `kplusFormula` or `kplus_formula_correct` — the discrete pipeline
  depends on them and they are internally consistent with each other.
- It does not touch Blocks E-I's mathematics.

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
the content of Phases 9-30, of which Phases 9 and 10 are done.

**Definition of done**: `FormalSystem/Metalogic/StrongCompleteness.lean` contains a sorry-free
`consequence_completeness_dedekind` with `completeness_dedekind` as a corollary; full `lake build`
green; `#print axioms consequence_completeness_dedekind` shows exactly
`[propext, Classical.choice, Quot.sound]`.

### Programme scale and the phase-count ceiling

**This plan deliberately exceeds the hard-mode phase-count ceiling of 8, and the deviation is
declared rather than smuggled.** The ceiling exists to stop plans inflating either phase *count* or
phase *size* rather than admitting scope. Here the opposite discipline is applied: **phase size is
held to one bounded, independently verifiable unit each** (H8's primary criterion), and the count
is whatever that discipline produces. Compressing 25 bounded units into 8 phases would mean phases
of ~1000 lines apiece with open-ended attempt surfaces — the exact failure mode that consumed
dispatches earlier in this task.

v8's four added units are the *consequence of applying the ceiling honestly*, not of relaxing it:
the eight faithful modules form a **strictly linear import chain**
(`Lemma53Faithful → BoundedFixFaithful → BoundedFixAnchoredFaithful → NegFixOneFaithful →
NegFixListFaithful → VecEANegFixFaithful → Prop42Faithful`, with `Lemma53FaithfulPast` joining at
`Prop42Faithful`), so the tree cannot be left green with a partial sweep. Each phase must end at a
chain boundary.

The evidence for the overall scale is measured, not guessed. The `.Discrete` counterpart of this
route — Reynolds Theorem 9, which needs only D1 and gets it by a *discreteness shortcut*
unavailable here — cost **2215 lines** in `IntegerModel/GoodStructuresModelSurgery.lean` and
**1155 lines** in `IntegerModel/ReynoldsBridge.lean`. The dense case additionally needs D2 (§7),
the full §6 bad-interval argument with no shortcut, Doets' shuffle, and an order-theoretic
characterization of `ℝ` that Mathlib does not contain.

**Consequence for dispatch.** Each phase below is one agent run. Phases are grouped into five
labelled blocks; a block boundary is a natural checkpoint at which the orchestrator may stop with
the task at `[PARTIAL]` and a fully honest state, because every phase ends with the tree green and
the live sorry count unchanged. If the orchestrator's budget runs out mid-programme, that is a
`[PARTIAL]` with a named next phase, **not** a blocker.

| Block | Phases | Content | Source |
|---|---|---|---|
| **D** | 9-14 (incl. 10.1, 11.1, 12.1) | Expressive completeness of `{U,S}` at the **dense** Prior carrier | Reynolds §5 Thm 3; Rabinovich Lemma 5.3 / 5.1 / Prop 4.2 |
| **E** | 15-16 | The dense monadic bridge: chronicle → `OrderedMonadicStructure` over `ℚ`, with Prior-U/Prior-S/Sep semantically valid | Reynolds §4 Cor 1, §9 steps 1-2 |
| **F** | 17-22 | **D1** — `∼`-classes do not end at gaps, on a dense Prior structure | Reynolds §6 Lemmas 2-9, Theorem 4 |
| **G** | 23 | **D2** — `Sep` ⇒ dense set of singleton classes | Reynolds §7 Theorem 5 |
| **H** | 24-29 | Doets' Theorem: `D1 + D2 ⇒ ∀k` an `ℝ`-flowed `≡ₖ` structure | Reynolds §8 Lemmas 11-13 + shuffle; Doets 1987 **3.3.9** |
| **I** | 30 | The engine and the terminus | Reynolds §9 Theorem 7 |

### Faithful-Subtree Survey (read-only, this revision)

**This section is the correction to v7's factual error about the tree, and it is binding: no phase
may plan against a module inventory it has not re-checked.** Every anchor below was produced by a
read-only survey at this revision and spot-checked against the tree. An implementer who finds an
anchor stale re-locates by name and records the drift; it is never a licence to re-plan.

| Module (all under `FormalSystem/Metalogic/WeakCanonical/Kamp/`) | Lines | `HasDedekind*` hypothesis sites | Destructure sites | Re-base difficulty |
|---|---|---|---|---|
| `Lemma53Faithful.lean` | 391 | `:230`, and inside `lemma53Faithful` (`:~318`) | **`:274`** (`negChainOnFaithful_iff`, by-cases-reached) | **One-arm**: the `kplus` primitives (`kplusPred :81`, `kplusPred_eval :83`, `kplusLeftBlock :~186`, `orderedPointsExist_combine_kplus :137`) all live here and are re-pointed once |
| `Lemma53FaithfulPast.lean` | 364 | `:173` | `:181` (`HasDedekindSUP.last_occ_tp`, **unconditional wrapper**) | **One-arm**, mirror. **Absent from the Phase 10 handoff's list — do not omit it** |
| `EANegationFixFaithful/BoundedFixFaithful.lean` | 371 | `:188`, `:258` | — | **Pure signature swap** (delegates without destructuring) |
| `EANegationFixFaithful/BoundedFixAnchoredFaithful.lean` | 355 | `:150`, `:230` | — | **Pure signature swap** |
| `EANegationFixFaithful/NegFixOneFaithful.lean` | 726 | `:156`, `:247`, `:339`, `:403`, `:488` | `:164` (`first_occ_tp` wrapper, unconditional); **`:422`** (`negFixOneFaithful_cover`, by-cases-reached) | **The hard site.** `Case1/Case2/Case3a/b/c` split with **no slot** for an endpoint case |
| `EANegationFixFaithful/NegFixListFaithful.lean` | 584 | `:335` | **`:446`** (`negFixListFaithful_iff`, by-cases-reached) | **The second hard site**, same reason |
| `EANegationFixFaithful/VecEANegFixFaithful.lean` | 314 | `:105`, `:138`, `:207`, `:234` (+ shim use `:312`) | — | **Pure signature swap** |
| `Prop42Faithful.lean` | 283 | `:142`, `:167` | — | **Pure signature swap** |
| **Total** | **3,388** | **19 declarations** | **5 sites, 3 by-cases-reached** | — |

**Facts that constrain every Block D phase:**

- **Zero sorries** in all eight modules (every `grep` hit is prose about the anti-vacuity failure
  mode). The sorry census outside `Boneyard/` stays exactly `Transfer.lean:1242`.
- **The whole family is CI-protected** via `NfMultiAnchorBridge.lean` — imports at `:7-18` and
  continuing *inside* a `NOTE` comment block at `:238`, `:252`, `:275`, `:297`, `:320`, `:345`
  (valid Lean; interleaving imports with comments is legal). A red faithful module reddens the
  build.
- **`WeakCanonical.lean:20-21`** directly imports `PriorDefsDense.lean` and `DedekindINFDense.lean`
  — a second CI edge, added by Phases 9 and 10.
- **`DedekindINFDense.lean` currently has no faithful-family consumer.** Its only importer is
  `WeakCanonical.lean:21`. Phase 10's carrier is landed and **unconsumed**; connecting it is
  exactly what Block D now does.
- **The three by-cases-reached sites have no left-endpoint hypothesis in scope**, re-verified.
  Phase 10's framing is confirmed.
- **The faithful family is currently unobservable on the discrete pipeline.**
  `prior_makes_disjunct2_unreachable` (`Lemma53Faithful.lean:382`) proves that under
  `SemanticPriorUZ`, `¬kplus M atomMap P z₀` holds whenever `P` occurs in `(z₀,z₁)` — so
  disjunct (2) *never fires* there; the mirror is
  `prior_makes_kminus_disjunct_unreachable` (`Lemma53FaithfulPast.lean:355`). This is the
  machine-checked statement of why the re-base is safe for the discrete pipeline **and** of why
  the dense carrier is the thing that finally makes the faithful modules do work.

### Preserved Assets

Complete, verified, and must not regress. No phase rewrites, generalizes, or "cleans up" any row.
Line anchors are as of this revision; an implementer who finds an anchor stale re-locates by name
and records the drift, never edits the target.

**New in v8** (landed by Phases 9 and 10; these rows did not exist in v7):

| Component | File / Anchor | Status | Verified |
|---|---|---|---|
| `SemanticPriorU`, `SemanticPriorS`, `semanticPriorUZ_fails_of_interval_witness`, `semanticPriorUZ_fails_on_dense`, `semanticPriorU_of_flowGLB`, `semanticPriorS_of_flowLUB`, `densePriorU_antecedent_reachable`, `denseWindowFlow`, `densePriorAtomMap` (11 declarations) | `WeakCanonical/PriorDefsDense.lean` (407 lines) | [COMPLETED] Phase 9. Sorry-free, `[propext, Classical.choice, Quot.sound]` (exclusion lemma `[propext]` only). **The dense Prior hypotheses and the vacuity witness.** Not edited by any later phase | 2026-07-28 |
| `HasGuardedDedekindINF` (`:128`), `HasDenseDedekindINF` (`:187`), `HasDenseDedekindSUP` (`:201`), `HasDedekindINF.toHasDenseDedekindINF` (`:274`), `prior_hasDenseDedekindINF_dense` (`:428`), `prior_hasDenseDedekindSUP_dense` (`:434`), `hasDedekindINF_fails_of_interval_witness` (`:455`), `denseWindow_endpoint_disjunct_forced`, and the rest of the 32 declarations | `WeakCanonical/Kamp/DedekindINFDense.lean` (631 lines) | [COMPLETED] Phase 10. Sorry-free, axiom-clean, **the route's single point of failure discharged**. **Nothing here is deleted, reverted or restated by v8.** Phase 10.1 may edit **comment bytes only**, in the narrow correction chartered there | 2026-07-28 |

**Carried forward from v7** (unchanged; the authoritative long form with per-row commentary is
`plans/07_strong-completeness-dedekind-v7.md` §"Preserved Assets", which v8 does not amend):

| Component | File / Anchor | Status |
|---|---|---|
| **`consequence_completeness_dedekind_of_engine`** (`:274-279`), `completeness_dedekind_of_engine` (`:308`), `soundness_dedekind_consequence` (`:292`), `SemanticConsequenceDedekindDense` (`:128`) | `Metalogic/StrongCompleteness.lean` (342 lines) | [COMPLETED] commit `bd9ae0ac1`. **The terminus, untouched. The pinned signature may not be restated, reordered or re-bound** |
| `real_lub_of_bddAbove` (`:127`), `dedekind_box_dense_mem` (`:149`) | `BXCanonical/CompletenessDedekind.lean` (166 lines) | [COMPLETED] the `D := ℝ` facts Phase 30 needs |
| `ValidDedekindDense` | `Semantics/Validity.lean:255` | [COMPLETED] |
| **`Chronicle.cantorBfmcsDense`** (`:552`), `rootedCantorFmcsDense` (`:500`), `rooted_cantor_fmcs_dense_at_s` (`:513`), `cantor_bfmcs_dense_restricted_tc` (`:629`), `_buc` (`:680`), `_fuc` (`:755`) | `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` (1222 lines) | [COMPLETED] **Reynolds' §4 Corollary 1. Stays at `Rat`; file stays byte-identical** |
| `limit_satisfies_c5_strong` (`:1531`), `limit_satisfies_c5'_strong` (`:1575`), `omegaChain` (`:283`) and the rest | `BXCanonical/Chronicle/ChronicleConstruction.lean` (1613 lines) | [COMPLETED] **byte-identical** |
| **`uSExpressivelyCompleteOverPrior`** (`:357`), `stavi_U_false_on_prior_UZ` (`:90`), `stavi_S_false_on_prior_SZ` (`:143`), `flatten_stavi_correct_prior` (`:211`) | `WeakCanonical/PriorExpressiveness.lean` (372 lines) | [COMPLETED] **Pinned at `SemanticPriorUZ`/`SemanticPriorSZ`, FALSE on dense flows — Block D builds a dense sibling and does not edit this file** |
| `StaviUTruth` (`:79`), `StaviSTruth` (`:110`), `StaviFormula` (`:140`), `flattenStavi` (`:446`), `flatten_stavi_correct` (`:497`) | `WeakCanonical/StaviConnectives.lean` (583 lines) | [COMPLETED] |
| `SemanticPriorUZ` (`:28`), `SemanticPriorSZ` (`:39`) | `WeakCanonical/PriorDefs.lean` (47 lines) | [COMPLETED] the **integer** Prior axioms. **Not edited** — the tree's deliberate import-cycle breaker |
| `HasDedekindINF` (`:136`), `HasDedekindSUP` (`:153`), `HasAttainedINF.toHasDedekindINF` (`:172`), `HasDefinableINF.toHasDedekindINF` (`:185`), `hasDedekindINF_admits_kplus_shape`, `prior_hasDedekindINF` (`:232`), `prior_hasDedekindSUP` (`:240`) | `WeakCanonical/Kamp/DedekindINF.lean` (291 lines) | [COMPLETED] **statements and proofs not edited**; Phase 10.1 may not touch this file at all |
| `kplus` (`:86`), `kplusFormula` (`:~93`), `kminus` (`:98`), `HasDefinableINF` (`:114`), `HasAttainedINF` (`:208`), **`prior_hasAttainedINF` (`:230`)** | `WeakCanonical/Kamp/PriorINF.lean` (296 lines) | [COMPLETED] **`kplus`'s statement is NOT edited** (the discrete pipeline depends on it). Phase 10.1 corrects its **docstring only** |
| `kampPriorExpressiveCompleteness` (`KampPrior.lean:672`), `nf_nvar_exist_all_depths` (`:363`, carries `hn : n ≤ 1`), `nfCharacterizableTemporalPrior` (`:589`), `Kamp/EANegationFix/**`, `Kamp/NfMultiAnchorBridge/**` | `WeakCanonical/Kamp/**` | [COMPLETED] **`EANegationFix/` (the attained originals) is read, not edited. `EANegationFixFaithful/` is the re-base territory** |
| `doets_lemma_1_4` | `WeakCanonical/OrderedSum.lean:41` | [COMPLETED] Doets 1989 Lemma 1.4; consumed by Phases 24, 26, 29 |
| `KEquiv` (`:81`), `kTypeOf` (`:72`), `KType` (`:61`) | `WeakCanonical/NEquivalence.lean` (1315 lines) | [COMPLETED] |
| `good` (`:78`), `VeryGood` (`:86`), `ContempEquiv` (`:729`) | `WeakCanonical/IntegerModel/GoodStructures.lean` (881 lines) | [COMPLETED] `ℤ`-interval, **closed** intervals; Block H builds `ℝ`-interval siblings beside them |
| `truth_transfer` (`:361`), **`mkSigFrom` (`:134`)** | `WeakCanonical/Transfer.lean` (1244 lines) | [COMPLETED]. **Carries the repository's single live sorry at `:1242`, in an unrelated declaration; out of scope** |
| `Formula.predFormulas` | `Syntax/Formula.lean:778` | [COMPLETED] the bimodal encoding |
| `reynolds_model_surgery_core` (`:2102`), `no_gaps_discrete_model_surgery` (`:2180`) | `WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (2215 lines) | [COMPLETED] Reynolds Theorem 4 at the discrete instance; the cost baseline for Block F |
| `multiFamTaskFrame` (`:671`), `multiFamOmega` (`:694`), `multiFamOmega_shiftClosed` (`:708`), **`countermodel_discrete_reynolds_v2`** (`:739`) | `WeakCanonical/IntegerModel/ReynoldsBridge.lean` (1155 lines) | [COMPLETED] **regression canary** |
| `NormalForm` (`:146`) and its constructors | `WeakCanonical/NormalForm.lean` (873 lines) | [COMPLETED] |
| `Axiom.prior_U_gap` (`:377`), `Axiom.prior_S_gap` (`:387`), **`Axiom.sep`** (`:390-401`), `minFrameClass` (`:524`) | `ProofSystem/Axioms.lean` | [COMPLETED]. `sep` becomes load-bearing for the first time in Phase 23 |
| **`sep_valid`** (`:1601`), `soundness_dedekind` (`:1910`) | `Metalogic/Soundness.lean` | [COMPLETED] `sep_valid` is stated directly at `ValidDedekindDense` |
| `countermodel_dense_enriched` (`:133`), `neg_consistent_of_not_derivable` (`:72`), `completeness_dense` (`:255`), `completeness_discrete` (`:296`), audit chain `:381-383` | `Metalogic/BXCanonical/Completeness.lean` (417 lines) | [COMPLETED] **regression canaries** and the terminus-plumbing template |
| `fully_restricted_parametric_completeness_from_neg_membership` (`:417`) | `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (434 lines) | [COMPLETED] **accepts `D := ℝ` unchanged** |
| `ParametricCanonicalTaskFrame`/`TaskModel`/`parametricToHistory`; `BFMCS`/`FMCS`; the six coherence predicates | `Metalogic/Algebraic/**`, `Bundle/BFMCS.lean:91`, `Bundle/FMCSDef.lean:103`, `Bundle/TemporalCoherence.lean` | [COMPLETED] generic in `D` and `fc` |
| `set_lindenbaum`, `theorem_in_mcs` (`:491`), `deductionTheorem`/`deductionConverse`, `self_mem_subformulaClosure` (`:42`) | `Metalogic/Core/**`, `Syntax/SubformulaClosure/Closure.lean` | [COMPLETED] generic in `fc` |

**The eight faithful modules are Preserved Assets in their *content* and re-base territory in their
*carrier*.** Every declaration in them is complete and sorry-free and must remain so; what Block D
changes is the hypothesis they take, never what they prove. A Block D phase that loses a
declaration, weakens a conclusion, or introduces a `sorry` has failed, not deviated.

### Amputated Assets

**Landed, sorry-free, axiom-clean Lean that is retired as forward road.** It stays in the tree, it
stays compiling, and it is not deleted, reverted or refactored. Carried forward from v7 unchanged;
the per-row commentary is at `plans/07_...v7.md` §"Amputated Assets".

| Asset | Landed by | Disposition |
|---|---|---|
| `limitSetBelow`/`Above` + 10 lemmas; `limitMCSBelow*` — `Bundle/LimitMCS.lean` (482 lines) | v6 Phases 3-4 | **Retired** |
| The 11 `LimitMCSCoherence` case lemmas — `Bundle/LimitMCSCoherence.lean` (328 lines) | v6 Phases 5-6 | **Retired** |
| `realLimitMCS*`, `FMCS.toReal*`, `BFMCS.toRealBundle` — `Bundle/RealExtension.lean` (240), `Bundle/RealExtensionBundle.lean` (433) | v6 Phases 6, 6.1 | **Retired** |
| `limitFutureWitness_of_priorU`, `limitGuardBelow_of_priorS`, `limitGuardAbove_of_priorU` and their instances — `ChronicleLimitGapWitness.lean` (221), `ChronicleLimitGuardWitness.lean` (217), `ChronicleLimitGuardAbove.lean` (224) | v6 Phases 6.2, 6.3, 7.3, 7.4 | **Retired as route.** Keep as record |
| `BFMCS.LimitFutureWitness`, `BFMCS.LimitGuardBelow`, **`BFMCS.LimitGuardEventual`** | v6 Phases 6.2-7.4 | **Retired.** No phase of v8 states, consumes or discharges them |
| `toRealBundle_forward/backward_until_since` + ~17 supporting declarations — `ChronicleRealExtension.lean` (1159 lines) | v6 Phases 7.1′, 7.2, 7.4 | **Retired** |
| All of `ChronicleGuardAccumulation.lean` (812 lines) | v6 Phases 7.5, 7.9 | **Retired as machinery. `noGuardAccumulation_not_implied_by_limit_data` must be retained** as the machine-checked postmortem exhibit |
| The `NoGuardAccumulation` component of `omegaChain`'s subtype (`ChronicleConstruction.lean:283`), `EliminationResult.guard_accum_preserved`, and the 7.6/7.7 material in `CounterexampleElimination.lean` (3897 lines) | v6 Phases 7.5-7.8 | **Retired but STRUCTURALLY LIVE.** Must keep compiling. **Do not strip it** |

### Source-to-Implementation Mapping (H3, Tier 1 — literature-backed)

Cite by **printed page** in every Lean docstring. Never cite chunk-relative `md:NN` line numbers.
The page-offset for Reynolds 1992 is PDF page `i` ↔ printed `164 + i`. **Printed-page attributions
must be re-verified against the PDF before landing in a docstring**, and any correction recorded in
the phase summary (honesty charter Rule 2).

**Rows changed or added by v8** (all others carry forward from v7 unchanged and are reproduced
below them):

| Source | Location | Lean identifier (target) | Statement used | Phase |
|---|---|---|---|---|
| **Rabinovich 2014** | **`K⁺` definition, PDF p.3** (corpus `chunk_0007.md:33,39`) | **`kplusOpen`** (new) | *"`K+(F)` … is an abbreviation for `¬((¬F)UntilTrue)`"*; *"(3) `K+(F)` holds at a moment `t` iff `t = inf({t′ | t′ > t and F holds at t′})`."* **No `¬F(t)` conjunct.** This is the definition the tree's `kplus` deviates from | **10.1** |
| **Reynolds 1992** | **abbreviations table, §1, printed p.168** | **`kplusOpen`** (new Prop) and the **missing bridge** to the landed `Formula.kPlus` (`Syntax/Formula.lean:180`, docstring `:163-179` citing this same table plus GHR 1994 §10.3.1) | `K⁺A` *"for `¬U(⊤,¬A)`"*, reading *"`A` will be true arbitrarily soon"*. `U(A,B)(t)` iff *"there is `s > t` such that `A(s)` and for all `u`, if `t < u < s` then `B(u)`"* | **10.1** |
| Rabinovich 2014 | Lemma 5.3 Case 2, **eq (5.2), PDF p.8** (corpus `chunk_0015.md:11-15`) | **`HasFaithfulDedekindINF`** (new), `prior_hasFaithfulDedekindINF_dense` (new) | *"Case 2: If case 1 does not hold then let `r₀ = inf{z ∈ (z₀, z₁) | P₁(z)}` … Note that `r₀ = z₀` iff `K⁺(P₁)(z₀)`. If `r₀ > z₀` then `r₀ ∈ (z₀, z₁)` and `r₀` is definable by the following ∨∃⃗∀ formula:"* then `INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀} ¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀))` **(5.2)** | **10.1** |
| Rabinovich 2014 | Lemma 5.3, the printed `Oₙ₊₁`, **PDF p.9** (corpus `chunk_0016.md:3`) | `negChainOnFaithful` (re-based, `Lemma53Faithful.lean`) | *"Subcase `r₀ = z₀`: In this subcase `Oₙ(P₂,…,Pₙ,z₀,z₁)` and `Oₙ₊₁(P₁,…,Pₙ₊₁,z₀,z₁)` should be equivalent. Subcase `r₀ ∈ (z₀,z₁)`: Now `Oₙ(P₂,…,Pₙ,r₀,z₁)` and `Oₙ₊₁` should be equivalent. Hence `Oₙ₊₁` can be defined as the disjunction of "`(z₀,z₁)` is empty" and the following formulas: (1) `(∀y)^{<z₁}_{>z₀} ¬P₁(y)` (2) `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)` (3) `(∃r₀)^{<z₁}_{>z₀} INF(z₀,r₀,z₁,P₁) ∧ Oₙ(P₂,…,Pₙ,r₀,z₁)`"* — **the printed subcase split is on `r₀ = z₀` vs `r₀ > z₀`; `K⁺` is its definable proxy and, at the source's `K⁺`, an exact one** | **11** |
| Rabinovich 2014 | Lemma 5.1 case enumeration, **PDF p.9** (corpus `chunk_0017.md:9`) | `negFixOneFaithful_cover`, `negFixListFaithful_iff` (re-based) | *"at least one of the following cases holds: Case 1: `¬α₀(z₀)` or `K⁺(¬β₁)(z₀)`. Case 2: `α₀(z₀)`, and `β₁` holds along `(z₀,z₁)`. Case 3: (1) `α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀)`, and (2) there is `x ∈ (z₀,z₁)` such that `¬β₁(x)`."* — **the negation-chain discipline**: the case split is exhaustive *only* under the source's `K⁺` | **12, 12.1** |
| Rabinovich 2014 | Lemma 5.1 Case 3, **eq (5.3), PDF p.10** (corpus `chunk_0018.md:9-13`) | the eq (5.3) pieces in `NegFixOneFaithful.lean` (`infPinPoint`, `allSeg`, `somePointBlock`) | *"When the first condition holds, then the second condition is equivalent to "there is (a unique) `r₀ ∈ (z₀,z₁)` such that `r₀ = inf{z ∈ (z₀,z₁) | ¬β₁(z)}`" (If `¬K⁺(¬β₁)` holds at `z₀` and there is `x ∈ (z₀,z₁)` such that `¬β₁(x)`, then such `r₀` exists because we deal with Dedekind complete chains.)"*; `INF_{¬β₁}(z₀,z,z₁) := z₀ < z < z₁ ∧ (∀y)^{<z}_{>z₀} β₁(y) ∧ (¬β₁(z) ∨ K⁺(¬β₁)(z))` **(5.3)**; *"Hence, Case 3 is described by `α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀) ∧ (∃z)^{<z₁}_{>z₀} INF_{¬β₁}(z₀,z,z₁)`"* — **the standing guard is printed at the use site, twice** | **12, 12.1** |
| Rabinovich 2014 | Prop 4.2, **PDF p.6** (corpus `chunk_0012.md:9`) | `VVecEA2.negFixFaithful_iff`, `prop42_contentful_of_faithful` (re-based) | *"Proposition 4.2. (Closure under negation) The negation of ∃⃗∀-formulas with at most two free variables is equivalent over Dedekind complete chains to a disjunction of ∃⃗∀-formulas."* | **13** |

**Carried forward from v7 unchanged** (Blocks D-tail and E-I):

| Source | Location (printed page) | Lean identifier (target) | Phase |
|---|---|---|---|
| Reynolds 1992 | §5 Thm 3, **p.176** | `SemanticPriorU` / `SemanticPriorS` — **landed** | 9 |
| Reynolds 1992 | Prior-U / Prior-S, **p.168** | `Axiom.prior_U_gap` (`:377`), `Axiom.prior_S_gap` (`:387`) — consumed | 9, 10, 10.1, 16 |
| Reynolds 1992 | §5 Thm 3 proof, **p.176** | `uSExpressivelyCompleteOverDensePrior` (new) | 14 |
| Reynolds 1992 | §9 steps 1-2, **p.189** | dense monadic bridge (new module) | 15 |
| Reynolds 1992 | §4 Cor 1, **p.174** | consumes `cantorBfmcsDense` + the three coherence theorems | 15, 16 |
| Reynolds 1992 | §6, **pp.176-177** | `ContempEquivDense`, `rhoFormula`, `lambdaFormula`, Lemma 2 | 17 |
| Reynolds 1992 | §6 Lemmas 3-4, **p.177** | Lemma 3, Lemma 4 | 18 |
| Reynolds 1992 | §6 Lemma 5, **p.178** | Lemma 5, `relativizeToClass` | 19 |
| Reynolds 1992 | §6 Lemmas 6-7, **pp.178-179** | Lemma 6, Lemma 7 | 20 |
| Reynolds 1992 | §6 Lemma 8, **pp.179-180** | Lemma 8 (bad-interval surgery) | 21 |
| Reynolds 1992 | §6 Lemma 9 + **Theorem 4**, **≈p.181** | **`no_gaps_dense_prior`** (**D1**) | 22 |
| Reynolds 1992 | §7 **Theorem 5**, **pp.184-185**; Sep, **p.168** | **`dense_singletons_of_sep`** (**D2**); `Axiom.sep` consumed | 23 |
| Reynolds 1992 | §8 Lemma 11, **p.186** | `goodDense`, `veryGoodDense`, `lemma_11_dense` | 24 |
| Reynolds 1992 | §8 Lemma 12, **pp.186-187** | `epsilonDense`, `lemma_12_dense` | 25 |
| Reynolds 1992 | §8 Lemma 13, **p.187**; the shuffle, **p.186** | `lemma_13_dense`, `Shuffle` | 26 |
| Reynolds 1992 | §8, **p.188**; **Doets 1987 3.1.8** | `shuffle_extend_R`, `shuffleFlow_dedekind_complete`, `shuffleFlow_separable`, **`doets_lemma_1_5`** | 27 |
| Reynolds 1992 | §8, **p.188** | **`orderIsoRealOfDedekindDenseSeparable`** (**no Mathlib equivalent**) | 28 |
| Reynolds 1992 | §8 **Theorem 6**, **pp.185-188**; Doets 1987 **3.3.9** | **`doets_theorem_dense`** | 29 |
| Reynolds 1992 | §9 **Theorem 7**, **p.189**; §2, **p.169** | `completeness_dedekind_engine`, then the pinned `consequence_completeness_dedekind_of_engine` | 30 |
| Reynolds 1992 | §10 Thm 9, **pp.190-191** | `countermodel_discrete_reynolds_v2` — **template only** | (15, 17-22, 24-25) |
| **NO SOURCE — original work** | — | the chronicle → `OrderedMonadicStructure` dense bridge (15); the `ℝ`-order characterization (28) if no Mathlib route is found; **the guard/trichotomy apparatus of `DedekindINFDense.lean` (Phase 10), which is a formalization-level repair for the tree's `kplus` deviation and has no counterpart in either source** | 15, 28, **10.1 (labelling)** |

### Drafted-but-archived target: `doets_lemma_1_5`

Carried forward from v7 verbatim in substance. `FormalSystem/Boneyard/SorriedDeclExcisions/
SingletonSorriedDecls.lean:58` carries a drafted `doets_lemma_1_5` with a `sorry`, behind `#exit`
(line 41), under the stale names `k_type_of` / `k_equiv` (live: `kTypeOf` `NEquivalence.lean:72`,
`KEquiv` `:81`). Its archive header (`:19-24`) reads: *"Not on the discrete completeness critical
path … **Required only for the dense case (future work).**"* It is **not built and cannot be reused
as-is**; **Phase 27 is chartered to re-state it under the live names in live code and prove it.**
Do not import `Boneyard`; do not reintroduce the `sorry`.

---

## Postmortem Constraints

Binding on every implementation dispatch for this task. Derived from the Phase 7.9 refutation, from
`reports/07`'s adversarial verification, from the accumulated record of six superseded plans, and
— new in v8 — from Phase 10's landed findings.

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
   entirely in the `¬,∧,G,H` fragment (printed p.116) — before Until/Since enter the language.
   Reynolds never completes the rational order at all.

**The generalization every future phase must carry.** *A guard obligation that arises only because
the construction inserted a point where the literature inserts none is evidence of a wrong route,
not a hard lemma.* The user's no-needless-bridges constraint names exactly this: a step whose only
purpose is to connect two artifacts the tree happens to have.

### Why Block D needed correcting — the v8 digest

**The obligation.** Phase 10 discharged the route's single point of failure and then found that the
carrier it had to export was a **trichotomy** whose third disjunct — `P(z₀)` — is *uninformative*:
it does not imply `r₀ = z₀`, so a consumer landing in it learns nothing. The survey then found
that the two hardest consumers have a case structure with **no slot** for it.

**What it actually was.** The corpus, read verbatim at this revision, shows both sources define
`K⁺` **without** a `¬P` conjunct at the point of evaluation (`chunk_0007.md:33,39`; Reynolds'
abbreviations table). The tree's `kplus` (`PriorINF.lean:86`) adds one. Every symptom Phase 10
observed — the refutation, the guard, the trichotomy, the endpoint hole — is downstream of that
single added conjunct.

**The generalization every future phase must carry.** *Before attributing an error to a source,
check the source's own definitions of the symbols in the disputed sentence.* A definitional
deviation introduced by the formalization will present exactly as a mathematical defect in the
literature, and the tree will pass sorry-free and axiom-clean while asserting it. This is the same
family as the anti-vacuity failure mode `DedekindINF.lean` already records, one level up: not a
vacuous *hypothesis* but a mis-transcribed *primitive*.

**Do NOT**:

- **Do NOT re-open completion-by-limits, in any form.** No limit MCS at a gap of a rational
  chronicle, no `ℝ`-extension of `cantorBfmcsDense`, no repair of `NoGuardAccumulation`, no
  invariant carrying MCS-value content about freshly inserted points. Refuted at the data level and
  unreachable at the axiom level.
- **Do NOT state, consume or discharge `BFMCS.LimitGuardEventual`, `BFMCS.LimitGuardBelow` or
  `BFMCS.LimitFutureWitness`.** Retired. No phase of v8 mentions them except in prose.
- **Do NOT attempt to formalize the two-sided defeat of `prior_S_gap`.** Moot on this route.
- **Do NOT delete, revert or refactor the amputated layer.** In particular do **NOT** strip the
  `NoGuardAccumulation` component out of `omegaChain`'s subtype (`ChronicleConstruction.lean:283`)
  or out of `EliminationResult`. Inert compiling code is the correct disposition.
  **`noGuardAccumulation_not_implied_by_limit_data` must be retained.**
- **Do NOT apply `uSExpressivelyCompleteOverPrior`, `kampPriorExpressiveCompleteness`,
  `prior_hasDedekindINF`, `prior_hasAttainedINF`, `no_gaps_discrete_model_surgery`, or any other
  declaration pinned at `SemanticPriorUZ`/`SemanticPriorSZ`, at a dense flow.** They are **vacuous
  there**. Every Block D phase must ship a non-vacuity witness (anti-vacuity gate below).
- **Do NOT edit `SemanticPriorUZ` / `SemanticPriorSZ`, `uSExpressivelyCompleteOverPrior`,
  `prior_hasAttainedINF`, `prior_hasDedekindINF`, `no_gaps_discrete_model_surgery`, or
  `countermodel_discrete_reynolds_v2`.** The discrete pipeline is landed, sorry-free and
  axiom-clean and `completeness_discrete` depends on it.
- **Do NOT edit `ChronicleTypes.lean`, `ChronicleToCountermodelBasic.lean`,
  `ChronicleConstruction.lean`, `CounterexampleElimination.lean`, `cantorIsoDense`, `cantorZeroDense`
  or `CantorFDense`.** On this route the chronicle is *read*, never modified. The two frozen files
  must be **byte-identical** at the end of every phase.
- **Do NOT weaken the target to `ValidDedekind`.** `FrameClass.Dedekind` sits above
  `FrameClass.Dense`, so `density` and `dense_indicator` are admissible and both are false on `ℤ`.
  The target is `ValidDedekindDense`.
- **Do NOT make `countermodel_dedekind_dense`, `completeness_dedekind_engine`,
  `consequence_completeness_dedekind`, or `completeness_dedekind` conditional on an undischarged
  predicate.** The single permitted added hypothesis on that chain is
  `(hfc : FrameClass.Dedekind ≤ fc)`, discharged by `decide`. **There is no conditional terminus.**
- **Do NOT prove `completeness_dedekind` independently and then strengthen it.** It is
  `consequence_completeness_dedekind []` after `simp` discharges `∀ ψ ∈ [], _`.
- **Do NOT restate, reorder or re-bind `consequence_completeness_dedekind_of_engine`.** Pinned by
  commit `bd9ae0ac1`; Phase 30 instantiates it and nothing else.
- **Do NOT emit a vacuous definition** (`def X := True`, `theorem X := trivial`, a hypothesis no
  structure can satisfy). If a phase cannot be completed, mark it `[BLOCKED]` with the exact goal
  state.
- **Do NOT introduce a `sorry`.** The live census outside `Boneyard/` is **exactly one** —
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` — and must remain exactly one at the
  end of every phase. `Transfer.lean:1242` is not on this route and is not to be attempted.
- **Do NOT cite task numbers in any `.lean` file.** Cite the sibling module name, the source's
  printed page, or the declaration name.
- **Do NOT touch `FormalSystem/Metalogic/Decidability/` or `FormalSystem/Automation/`.** A
  concurrent effort owns them. Neither read-for-edit nor stage any file under those paths; leave
  any of their modifications unstaged.

**Do NOT — new in v8, from Phase 10**:

- **Do NOT plan, charter or dispatch a construction phase against a module inventory that has not
  been re-checked against the tree in the same dispatch.** v7's Phases 11-13 chartered ~990 lines
  of from-scratch construction for modules that already existed, sorry-free and CI-protected, at
  3,388 lines. A `find`/`grep` costing seconds would have caught it. Every phase below that names a
  file to create MUST first confirm it does not exist.
- **Do NOT attribute a mathematical error to a source before checking that source's own definitions
  of the symbols in the disputed sentence.** Rabinovich's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is a
  definitional restatement, true verbatim under his own Definition (3) (`chunk_0007.md:39`). Any
  docstring in this tree asserting otherwise is a defect and Phase 10.1 corrects it.
- **Do NOT consume `HasDenseDedekindINF`'s third disjunct as though it supplied `r₀ = z₀`.** It
  supplies `TemporalTruth M atomMap z₀ P` and nothing else. `denseWindow_endpoint_disjunct_forced`
  exhibits a point where it is the only disjunct that holds, and where no infimum information is
  available. A consumer that "handles" it by assuming an infimum is unsound.
- **Do NOT duplicate the eight faithful modules to avoid weakening a hypothesis in place.** Cloning
  3,388 lines to change a binder type is a needless bridge of exactly the kind this task's
  postmortem names. The re-base is a hypothesis **weakening**: every current supplier still
  typechecks through a shim, and the canaries fire immediately if it does not.
- **Do NOT edit `kplus`, `kplusFormula`, `kplus_formula_correct`, `kminus`, `kminusFormula` or
  `kminus_formula_correct` — statements or proofs.** They are internally consistent with each other
  and the discrete pipeline depends on them (`hasDefinableINF_excludes_kplus`, `Lemma53.lean:290`;
  `prior_makes_disjunct2_unreachable`, `Lemma53Faithful.lean:382`). The source-exact `K⁺` is a
  **new sibling**, `kplusOpen`, landed beside them. Their **docstrings** are corrected in Phase
  10.1 and nothing else about them changes.
- **Do NOT substitute `Formula.kPlus` for `kplusFormula` (or `Formula.kMinus` for `kminusFormula`)
  anywhere, in either direction, without going through the bridge lemma Phase 10.1 lands.**
  `Syntax/Formula.lean:163-179` states the prohibition in the tree's own words: *"substituting one
  for the other silently transcribes a different axiom."* The two spellings differ by exactly the
  conjunct this revision is about, and the axioms (`Axioms.lean:377`, `:387`, `:390`) are stated
  with the conjunct-free one while the carrier apparatus is stated with the conjunct-carrying one.
  Any phase that needs to move between them cites the bridge by name.

### The narrowed in-place constraint (v8 amendment, declared)

v7 carried an unqualified constraint: *"Dense siblings, never in-place generalization."* v8
**narrows it, deliberately, with reasons, and only for the eight `*Faithful*` modules**:

- **Still binding, unamended**, for `PriorDefs.lean`, `PriorINF.lean` (statements/proofs),
  `DedekindINF.lean`, `PriorExpressiveness.lean`, `Lemma53.lean`, `Section5Correspondence.lean`,
  `EANegationFix/**`, `KampPrior.lean`, `IntegerModel/**` and everything else on the
  discrete/attained axis. Block D adds siblings beside these; it does not generalize them.
- **Lifted, narrowly**, for `Lemma53Faithful.lean`, `Lemma53FaithfulPast.lean`, `Prop42Faithful.lean`
  and `EANegationFixFaithful/**`. Three reasons, all checkable:
  1. The change is a hypothesis **weakening** (`HasDedekindINF` → `HasFaithfulDedekindINF`), so
     every existing supplier keeps working through `HasDedekindINF.toHasFaithfulDedekindINF`. No
     conclusion is weakened anywhere.
  2. These eight modules **exist for the faithful carrier**. Re-pointing them at the source-exact
     carrier is what they are for; cloning them would leave two faithful families and no rule for
     which to consume.
  3. The discrete pipeline cannot observe the difference — `prior_makes_disjunct2_unreachable`
     (`Lemma53Faithful.lean:382`) and its mirror prove disjunct (2) never fires under
     `SemanticPriorUZ` — and the canaries (`completeness_discrete`,
     `countermodel_discrete_reynolds_v2`, `completeness_dense`) fire if that reasoning is wrong.
- **The lift does not extend to deletion.** No declaration in the eight modules may be removed,
  renamed away, or have its conclusion weakened. If a re-base cannot preserve a declaration, the
  phase is `[BLOCKED]`, not "simplified".

### The anti-vacuity gate (binding, per phase)

The `DedekindINF.lean` module docstring records the failure mode this task must not repeat:

> *"An over-strong hypothesis passes sorry-free, axiom-clean and EXIT 0 exactly as a vacuous
> conclusion does — the pattern that recurred three times undetected in this development."*

Every phase that introduces a **hypothesis** (a `structure … : Prop`, an `abbrev … : Prop`, or a
new binder on a transported theorem) MUST, in the same dispatch, land one of:

1. a **witness** — a concrete structure satisfying it, ideally at a dense flow; or
2. a **derivation** of it from an already-witnessed hypothesis; or
3. an explicit **exclusion lemma** in the style of `hasDefinableINF_excludes_kplus` and
   `hasDedekindINF_admits_kplus_shape`, showing which shapes the hypothesis admits and forbids.

A phase that lands only the hypothesis and its consumers, with no witness, is `[BLOCKED]` — not
`[COMPLETED]`.

**v8 addition — the re-base corollary.** A phase that *weakens* a hypothesis must additionally
show the weakening is **strict and consumed**: land the shim from the old carrier to the new one
(so nothing regresses) **and** exhibit at least one structure satisfying the new carrier that does
**not** satisfy the old one. Without the second half, a "weakening" may be an equivalence in
disguise and the re-base buys nothing. `denseWindowFlow` (Phase 9) at `z₀ = 1/2` is the intended
witness and Phase 10 already proved the old carrier fails there
(`hasDedekindINF_fails_on_dense_window`).

### Honesty charter for docstrings (binding user directive — SCOPE INVERTED FOR THIS ROUTE)

On the completion route the construction had **no source** and every docstring had to say so. On
the Doets route the construction **has a source** — Reynolds 1992 §5-§9, Rabinovich 2014 §4-§5 and
Doets 1987 3.3.9 — and every docstring must **cite it faithfully**.

**Rule 1 — transcription is cited, faithfully and specifically.** Every declaration in Blocks D, F,
G, H and I transcribes a named result. Its docstring must carry the **source, section, theorem or
lemma number, and printed page**, e.g. `Reynolds 1992, §6 Lemma 5, printed p.178` or
`Rabinovich 2014, Lemma 5.3 eq (5.2), PDF p.8`. A bare "following Reynolds" is a defect; so is a
docstring that omits the citation.

**Rule 2 — the printed page must be verified, not copied.** Before a page number lands in a `.lean`
docstring the implementer re-checks it against the PDF and records any correction in the phase
summary. Rabinovich is cited by **PDF page only** — `DedekindINF.lean`'s docstring records that the
`.md` conversion is corrupt (it drops displayed equations and inverts `k ≠ m` to `k = m`) and is
never ground truth. **The corpus chunk files ARE usable for the plain prose sentences quoted in the
Source-to-Implementation Mapping above** — each was read verbatim at this revision — but the
*displayed equations* must be read from the PDF.

**Rule 3 — Reynolds may be cited for discharges, not only for statements.** v8 builds expressive
completeness, so Reynolds' proofs are available as proofs.

**Rule 4 — the no-source statement is reserved, and its scope is exhaustively named.** Only these
carry a plain "this construction has no source in the corpus and is original work" statement:

- the chronicle → `OrderedMonadicStructure` dense bridge (Phase 15), including any bimodal family
  encoding beyond what `mkSigFrom`/`multiFamOmega` already discharge;
- `orderIsoRealOfDedekindDenseSeparable` (Phase 28), **if and only if** no Mathlib route is found;
- **the guard/trichotomy apparatus of `DedekindINFDense.lean`** — `HasGuardedDedekindINF`,
  `HasDenseDedekindINF`, their mirrors, and the `hasDedekindINF_fails_*` exclusion family. These
  are a formalization-level repair for this tree's `kplus` deviation and have **no counterpart in
  either source**. Phase 10 already labelled them original glue; Phase 10.1 completes the label by
  recording *what they are glue for*;
- any Lean-specific scaffolding (fuel/termination arguments, decidability instances,
  `Fintype`/`DecidableEq` plumbing) with no mathematical counterpart.

**Rule 5 — ADAPTED-FROM survives, narrowed.** Where a declaration follows a source's *method* on a
different object, the form is `ADAPTED-FROM: <source>, <location>, printed p.<N>` with a one-clause
statement of what changed. Never "transcribed from" for an adaptation.

**Rule 6 — every carrier states what it excludes.** Mandatory for every new `Prop`-valued hypothesis
in Block D.

**Rule 7 — new in v8: a docstring may not assert that a source is wrong without quoting the
source's own definition of every symbol in the disputed sentence.** If, after quoting, the source
is right and the tree deviates, the docstring says *that* instead: it names the tree's definition,
names the source's, and states which is which. A tree that silently redefines a primitive and then
records the literature as mistaken is worse than one that omits the citation.

### MUST preserve

- Every row of the Preserved Assets tables, byte-identical unless a phase's Tasks list names the
  file. **`PriorDefsDense.lean` and `DedekindINFDense.lean` join this list from v8 onward**; the
  only permitted change to either is Phase 10.1's comment-bytes-only correction to the latter.
- Every declaration in the eight faithful modules — present, sorry-free, and with its conclusion
  unweakened — through and after the re-base.
- Every row of the Amputated Assets table, compiling and unmodified.
- `Metalogic/Soundness.lean` at zero sorries.
- `completeness_dense`, `completeness_discrete` and `countermodel_discrete_reynolds_v2` sorryAx-free
  with axioms exactly `[propext, Classical.choice, Quot.sound]`. **The regression canary for
  Block D.**
- The live sorry count outside `Boneyard/` at exactly one (`Transfer.lean:1242`).
- The exact signature of `consequence_completeness_dedekind_of_engine` (commit `bd9ae0ac1`).
- `ChronicleTypes.lean` and `ChronicleToCountermodelBasic.lean` **byte-identical**.

### Design decisions are SETTLED (do not re-open without a concrete counterexample)

- **The Doets route, not completion-by-limits.** Settled by the user's authorization on
  `reports/07`, against a landed refutation and three exhausted axioms. **v8 does not re-open it.**
- **The terminus is the finite-context consequence form, and weak completeness is its `Γ = []`
  corollary.** Genuine (infinite-premise) strong completeness is **provably unavailable** here
  (Reynolds §2, printed p.169: compactness fails). Out of scope; do not rename any declaration back
  to a "strong" form.
- **The Doets route reaches BOTH termini with the pinned signature untouched.** Three grounds, from
  `reports/07` §1.5.
- **Expressive completeness is available in this tree and is the route's engine.** Machine-checked
  `#print axioms` outranks a plan-time prose inventory.
- **The re-base target is the faithful eq (5.2) carrier, not `HasDefinableINF` and not
  `HasAttainedINF`.** `hasDefinableINF_excludes_kplus` (`Lemma53.lean:290`, axiom-clean) proves
  `HasDefinableINF` makes `kplus M atomMap P z₀` *impossible* whenever `P` occurs in `(z₀,z₁)` — it
  deletes Rabinovich's disjunct (2), which on a dense Prior structure is exactly the reachable case.
- **NEW, SETTLED in v8: the carrier Block D's consumers take is the source-exact dichotomy
  `HasFaithfulDedekindINF`, not the trichotomy `HasDenseDedekindINF`.** Grounds: (i) both sources
  define `K⁺` without an endpoint conjunct, verbatim (`chunk_0007.md:33,39`; Reynolds'
  abbreviations table), so the dichotomy is the *faithful* statement and the trichotomy is the
  repair; (ii) the trichotomy's third disjunct is uninformative — `P(z₀)` does not imply `r₀ = z₀`;
  (iii) the two hardest consumers (`NegFixOneFaithful.lean:422`, `NegFixListFaithful.lean:446`)
  have a case structure with no slot for it. **The trichotomy is not deleted, not deprecated, and
  not restated** — it stays landed, it stays the record of the deviation, and
  `HasFaithfulDedekindINF.toHasDenseDedekindINF` keeps it supplied.
- **NEW, SETTLED in v8: the re-base is performed in place in the eight `*Faithful*` modules**, not
  by cloning. See "The narrowed in-place constraint" for the three reasons and the limits.
- **The `.Discrete` pipeline is the template and is not the target.** Its *method* transfers; its
  *statement* does not.
- **The Stavi route is the rejected alternative.** `stavi_expressive_completeness` exists only in
  `Boneyard/StaviDiscretePath/` with a sorry-tainted chain top. Recorded as the fallback in Risks.
- **Every gap-facing obligation is discharged `fc`-conditionally.** `Axiom.prior_U_gap`,
  `prior_S_gap` and `sep` all have `minFrameClass = .Dedekind`, so every consumer carries
  `(hfc : FrameClass.Dedekind ≤ fc)`, discharged by `decide` at `fc := FrameClass.Dedekind`.
- **The chronicle layer stays at `Rat`.** On this route it is read, not lifted.

---

## Goals & Non-Goals

**Goals**:

- `consequence_completeness_dedekind (Γ : Context) (φ : Formula) :
  SemanticConsequenceDedekindDense Γ φ → Derivable FrameClass.Dedekind Γ φ`, sorry-free,
  unconditional, obtained by instantiating the pinned engine theorem.
- `completeness_dedekind (φ : Formula) : ValidDedekindDense φ → Derivable FrameClass.Dedekind [] φ`
  as its `Γ = []` corollary.
- **`kplusOpen` and `HasFaithfulDedekindINF`/`SUP`** — the source-exact `K⁺` and the eq (5.2)
  dichotomy carrier, with `prior_hasFaithfulDedekindINF_dense` derived from `SemanticPriorU` alone.
  **Reusable well beyond this task**: it repairs the tree's one deviation from the sources'
  primitive vocabulary.
- **The eight faithful modules re-based onto that carrier**, all declarations preserved, sorry-free
  and axiom-clean — closing the deferral recorded at `DedekindINF.lean:87-103`.
- `uSExpressivelyCompleteOverDensePrior` — `{U,S}` expressive completeness at the **dense** Prior
  carrier, with a non-vacuity witness.
- `no_gaps_dense_prior` (**D1**, Reynolds Theorem 4) and `dense_singletons_of_sep` (**D2**,
  Reynolds Theorem 5), both reusable.
- `doets_theorem_dense` (Reynolds Theorem 6 / Doets 3.3.9) and `doets_lemma_1_5` in live code.
- `orderIsoRealOfDedekindDenseSeparable` — an order-theoretic characterization of `ℝ` absent from
  Mathlib and of independent value.

**Non-Goals**:

- Genuine (infinite-premise) strong completeness. Provably unavailable.
- Discharging `Transfer.lean:1242`. Base/Discrete axis; not on this route.
- Removing or refactoring the amputated layer.
- Formalizing the two-sided `prior_S_gap` defeat. Moot on this route.
- Reviving `stavi_expressive_completeness` from `Boneyard/`. Fallback only.
- **Deleting, deprecating or restating `HasGuardedDedekindINF` / `HasDenseDedekindINF`.** They stay
  landed as the record of the deviation and as suppliers.
- **Editing `kplus`'s statement or proof, or unifying it with `kplusOpen`.**
- Any edit under `FormalSystem/Metalogic/Decidability/` or `FormalSystem/Automation/`.
- A uniform (single) real-flowed model.

---

## Risks & Mitigations

| # | Risk | Likelihood | Impact | Mitigation / falsification protocol |
|---|---|---|---|---|
| R1 | ~~Phase 10 fails: the dense Prior axioms do not yield the eq (5.2) carrier~~ | — | — | **DISCHARGED.** `prior_hasDenseDedekindINF_dense` / `prior_hasDenseDedekindSUP_dense` are landed, sorry-free and axiom-clean from `SemanticPriorU`/`SemanticPriorS` alone. The route's single point of failure held |
| R2 | **Block D's re-base is larger than the five phases scheduled.** Eight modules, 3,388 lines, 19 hypothesis sites | Medium | Schedule | Each of 11, 11.1, 12, 12.1, 13 is chartered against a **named module boundary in the import chain** with a stated `Done when`. A phase that on contact needs more lands whatever is green, records a named sub-phase list in its summary and handoff, and reports `[PARTIAL]` — it does **not** expand silently. The orchestrator then revises with the sub-phases spliced in at the same numeric level (flat `N.1` numbering; the scan admits at most one dot) |
| R3 | **Block F (Reynolds §6) is six phases of research-grade transcription with no discrete shortcut.** The discrete analogue cost 2215 lines *with* a shortcut | **High** | Schedule | Each phase owns one or two named lemmas of §6 whose statements are fixed verbatim by the source before any tactic is written. §6 is quoted in full in the corpus, so this is transcription, not discovery. Same `[PARTIAL]`-with-decomposition protocol as R2 |
| R4 | **Phase 27's "game argument" is not spelled out by Reynolds**, and is the only result the tree previously attempted and archived unproved | Medium-**High** | One-two phases | (i) The tree has `NEquivalence.lean`'s Karp/EF apparatus and `doets_lemma_1_4`. (ii) **Phase 27 is chartered against Doets 1987 3.1.8**, not Reynolds' one-liner. (iii) The archived draft is a *statement template* only — behind `#exit`, stale names, `sorry` body — and must be re-stated, not un-archived |
| R5 | **Phase 28's `ℝ` characterization is absent from Mathlib** | Certain | One-two phases | Standard bounded construction; chartered with a proof skeleton and a hard `Done when`; splits at the `D ≃o ℚ` / cut-extension seam |
| R6 | **Block D disturbs the landed discrete pipeline** | Medium | Regression | Hypothesis **weakening** only, never conclusion change; `HasDedekindINF.toHasFaithfulDedekindINF` keeps every current supplier working; `prior_makes_disjunct2_unreachable` proves the discrete pipeline cannot observe disjunct (2). Every Block D phase runs the three canaries and records the result |
| R7 | **The bimodal dimension does not survive the dense `≡ₖ` transfer** | Low | Blocks E/I | Attacked and defeated in `reports/07`'s adversarial pass. Phase 15's **first task** is the explicit `SuccOrder`/`PredOrder`/`IsSuccArchimedean` independence gate; `[BLOCKED]` with the exact dependency if it fails |
| R8 | **Effort overrun ends the task mid-programme** | **High** | Task state | Every phase ends green with the sorry census unchanged and the frozen files byte-identical, so every phase boundary is a clean stop. Block boundaries (14 / 16 / 22 / 23 / 29) are the reporting checkpoints |
| R9 | **A phase "succeeds" vacuously** | Medium | Silent | The anti-vacuity gate, plus v8's re-base corollary: a weakening must be shown strict by a structure satisfying the new carrier and not the old |
| R10 | **Territory collision with the concurrent decidability effort** | Low | Build | Hard prohibition on `Decidability/` and `Automation/`; staging scoped to the task directory plus the files a phase's Tasks list names. `git add -A` and `git commit -am` forbidden |
| **R11** | **The faithful dichotomy does not collapse the case split at `NegFixOneFaithful.lean:422` / `NegFixListFaithful.lean:446`.** v8's central planning bet — that the source-exact `K⁺` keeps those two consumers at two arms — is a **plan-time paper derivation**, not a machine-checked fact | **Medium** | Blocks D schedule | **Falsification is Phase 11's first deliverable, on the smallest site.** `negChainOnFaithful_iff` (`Lemma53Faithful.lean:274`) has the same two-arm shape; if the swap does not go through there, it will not go through at `:422`/`:446` either. **Chartered fallback**: Phases 12 and 12.1 fall back to consuming `HasDenseDedekindINF` with explicit endpoint branches at the two hard sites, split under the R2 protocol, and the schedule grows by the branches actually needed — **recorded honestly, not absorbed**. The fallback is strictly available because both carriers stay landed and interderivable-in-one-direction |
| **R12** | **The `¬P(z₀)` conjunct of `kplus` is load-bearing somewhere the survey did not reach**, so weakening the left disjunct breaks a proof | **Very low** | Block D | Surveyed and answered at this revision: **exactly three** sites destructure `kplus`'s `.1`, all inside `DedekindINFDense.lean`'s own refutation machinery (`:467`, `:486`, `:609`) — i.e. inside the apparatus that exists *because of* the conjunct. Every faithful-family consumer threads `kplus`/`kminus` opaquely. `orderedPointsExist_combine_kplus` (`Lemma53Faithful.lean:137`) discards it (`obtain ⟨-, hdense⟩ := hk`); `hasDefinableINF_excludes_kplus` (`Lemma53.lean:296`) and `hasDefinableSUP_excludes_kminus` (`Lemma53FaithfulPast.lean:339`) both `rintro ⟨-, h_dense⟩`. Phase 10.1 re-runs the audit as its first task and records any site the survey missed; such a site keeps the strong carrier via the shim rather than being weakened. **`kplus` itself is never edited, so no existing proof can break by construction** |
| **R13** | **`kplusOpen` is landed as a third `K⁺` spelling and the tree ends up with three**, deepening the collision `Formula.lean:163-179` already warns about | Medium | Maintainability | `kplusOpen` is chartered **not** as a new operator but as the **missing Prop-level reading of the existing `Formula.kPlus`** (`Syntax/Formula.lean:180`), landed together with the bridge lemma that has been absent since `Formula.kPlus` was written. Phase 10.1's `Done when` requires the bridge, and requires a single docstring paragraph — in the new module and in the two corrected docstrings — that names all three spellings, says which transcribes which source, and points at the collision warning. Net effect on the tree is **one fewer** unbridged spelling, not one more |

---

## Implementation Phases

### Dependency Analysis and wave map

Blocks D and E are **independent of each other** and may be dispatched in parallel by an
orchestrator with the budget for it: Block E consumes only the landed chronicle and the landed
`mkSigFrom` apparatus, and touches no file Block D touches. Everything from Block F on is a chain.

**New in v8**: Block D's re-base phases (11 → 11.1 → 12 → 12.1 → 13) are a **strict chain**, not a
sweep. The eight faithful modules form a linear import order and the tree cannot be left green with
a partial sweep. **No phase owns a file another phase owns in the same wave.**

| Wave | Phases | Blocked by | Territory (owned files) |
|---|---|---|---|
| — | **9**, **10** | — | `[COMPLETED]`. `WeakCanonical/PriorDefsDense.lean`; `Kamp/DedekindINFDense.lean` |
| 1 | **10.1**, **15** | 10 (for 10.1) | 10.1: `Kamp/KPlusFaithful.lean` (new) + comment-only edits to `Kamp/PriorINF.lean` and `Kamp/DedekindINFDense.lean`. 15: `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (new) |
| 2 | **11**, **16** | 10.1 (for 11); 15 (for 16) | 11: `Kamp/Lemma53Faithful.lean`, `Kamp/Lemma53FaithfulPast.lean`. 16: same bridge module |
| 3 | **11.1** | 11 | `Kamp/EANegationFixFaithful/BoundedFixFaithful.lean`, `.../BoundedFixAnchoredFaithful.lean` |
| 4 | **12** | 11.1 | `Kamp/EANegationFixFaithful/NegFixOneFaithful.lean` |
| 5 | **12.1** | 12 | `Kamp/EANegationFixFaithful/NegFixListFaithful.lean` |
| 6 | **13** | 12.1 | `Kamp/EANegationFixFaithful/VecEANegFixFaithful.lean`, `Kamp/Prop42Faithful.lean` |
| 7 | **14** | 13 | `WeakCanonical/PriorExpressivenessDense.lean` (new) |
| 8 | **17** | 14, 16 | `WeakCanonical/DenseModelSurgery/Defs.lean` (new) |
| 9 | **18** | 17 | `DenseModelSurgery/Lemma34.lean` (new) |
| 10 | **19** | 18 | `DenseModelSurgery/Lemma5.lean` (new) |
| 11 | **20** | 19 | `DenseModelSurgery/BadIntervals.lean` (new) |
| 12 | **21** | 20 | `DenseModelSurgery/TruthTransfer.lean` (new) |
| 13 | **22** | 21 | `DenseModelSurgery/NoGaps.lean` (new) |
| 14 | **23** | 22 | `DenseModelSurgery/Singletons.lean` (new) |
| 15 | **24**, **25** | 22 | 24: `RealModel/GoodDense.lean` (new). 25: `RealModel/EpsilonDense.lean` (new) — **parallel-eligible pair** |
| 16 | **26** | 24, 25 | `RealModel/Shuffle.lean` (new) |
| 17 | **27** | 26 | `RealModel/ShuffleReal.lean` (new) |
| 18 | **28** | — (independent; schedule any time after wave 1) | `RealModel/OrderIsoReal.lean` (new) — **parallel-eligible with waves 2-17** |
| 19 | **29** | 23, 27, 28 | `RealModel/DoetsTheorem.lean` (new) |
| 20 | **30** | 29 | `BXCanonical/CompletenessDedekind.lean` (extend), `Metalogic/StrongCompleteness.lean` (extend), `FormalSystem/Metalogic.lean` (tracking table) |

**Explicit parallel opportunities**: `{10.1, 15}`, `{11, 16}`, `{24, 25}`, and `28` against
anything from wave 2 onward. Every other edge is a genuine dependency.

Directory names for new modules are proposals; an implementer who places a module elsewhere records
the deviation in the phase summary.

---

### Phase 9: `SemanticPriorU` / `SemanticPriorS` and the dense-flow vacuity witness [COMPLETED]

> **Record, preserved from v7.** Landed `FormalSystem/Metalogic/WeakCanonical/PriorDefsDense.lean`
> (407 lines, 11 declarations, sorry-free). `SemanticPriorU` / `SemanticPriorS` are Reynolds'
> Prior-U / Prior-S in the `OrderedMonadicStructure` idiom (printed p.168, re-verified against PDF
> page 4; p.176 re-verified against PDF page 12). The anti-vacuity gate was **exceeded**:
> `semanticPriorUZ_fails_of_interval_witness` and `semanticPriorUZ_fails_on_dense` refute the
> *integer* hypothesis on a dense flow, and `semanticPriorU_of_flowGLB` / `semanticPriorS_of_flowLUB`
> give the general Dedekind-complete-flow theorem, instantiated at `denseWindowFlow` and at a
> bounded window whose Prior-U antecedent is actually satisfied
> (`densePriorU_antecedent_reachable`). All eleven declarations `[propext, Classical.choice,
> Quot.sound]`; the exclusion lemma `[propext]` only. `lake build` = "Build completed successfully
> (1909 jobs)". `PriorDefs.lean` byte-identical.
>
> **v8 note.** `SemanticPriorU` is the semantic reading of `Axiom.prior_U_gap`, which is stated with
> the **conjunct-free** `Formula.kPlus` (`Axioms.lean:377`; `Syntax/Formula.lean:180`). This is the
> upper end of the seam Phase 10.1 closes, and it is the reason the faithful dichotomy is derivable
> from `SemanticPriorU` with no guard.

- **Owns**: `FormalSystem/Metalogic/WeakCanonical/PriorDefsDense.lean` (now a Preserved Asset).
- **Timing**: 4 hours (spent).

### Phase 10: `HasDedekindINF` / `HasDedekindSUP` from the dense Prior axioms [COMPLETED]

> **OUTCOME — the route's single point of failure HELD.** The derivation from `SemanticPriorU` /
> `SemanticPriorS` is complete, sorry-free and axiom-clean, with **no discreteness, no attainment
> and no flow completeness**. The plan's proof skeleton (steps 1-6) transcribed verbatim and the
> module built green on its first compilation. Landed
> `FormalSystem/Metalogic/WeakCanonical/Kamp/DedekindINFDense.lean` (631 lines, 32 declarations).
> `DedekindINF.lean`, `PriorINF.lean` and `PriorDefsDense.lean` byte-identical. `lake build` =
> "Build completed successfully (1912 jobs)". Canaries `completeness_dense`,
> `completeness_discrete`, `countermodel_discrete_reynolds_v2` unchanged. Live sorry outside
> `Boneyard/` remains exactly `Transfer.lean:1242`.
>
> **Deviation (recorded, `kind: altered`, authorized by the Phase 9 input block).** The target was
> `prior_hasDedekindINF_dense` concluding in bare `HasDedekindINF`. Landed instead as
> `prior_hasGuardedDedekindINF_dense` (guard `¬P(z₀)`, conclusion character-for-character
> `HasDedekindINF`'s) **plus** `prior_hasDenseDedekindINF_dense` (the hypothesis-free trichotomy,
> the exported form), with the `SUP` mirrors. Both are landed and interderivable. The unguarded
> statement is refuted on disk by `hasDedekindINF_fails_of_interval_witness` (`:455`) and
> instantiated at `hasDedekindINF_fails_on_dense_window`. All three disjuncts are exhibited
> reachable: `denseWindow_kplus_at_zero`, `denseWindow_guardedINF_right_disjunct`,
> `denseWindow_endpoint_disjunct_forced`.
>
> **The three findings this phase produced are the input to v8 and are recorded in the Revision
> Rationale**: (1) the single point of failure held; (2) downstream consumes a hypothesis-free
> carrier, not the guarded one, at three by-cases-reached sites with no left-endpoint hypothesis in
> scope; (3) an `EANegationFixFaithful/` subtree plus `Lemma53Faithful.lean` and
> `Prop42Faithful.lean` already exist and already consume `HasDedekindINF`.
>
> **v8 amendment to this phase's record, not to its Lean.** Phase 10's docstring asserts that
> Rabinovich's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is *"false read literally"*. **That attribution is
> withdrawn.** Read against Rabinovich's own Definition (3) — *"`K+(F)` holds at a moment `t` iff
> `t = inf({t′ | t′ > t and F holds at t′})`"* — the biconditional is a definitional restatement,
> true verbatim. What is true is that **this tree's `kplus` (`PriorINF.lean:86`) is not
> Rabinovich's `K⁺`**, and the tree's own `Syntax/Formula.lean:163-179` says so independently. **No
> landed statement or proof of this phase is affected**; the guard, the trichotomy and the
> refutation remain true theorems about the tree's `kplus`. Only the docstring's attribution is
> wrong, and Phase 10.1 corrects it by comment bytes.

- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/DedekindINFDense.lean` (now a Preserved
  Asset; comment-only edits permitted to Phase 10.1 alone).
- **Timing**: 6 hours (spent).

---

### Phase 10.1: The source-exact `K⁺`, its missing bridge, and the faithful dichotomy carrier [COMPLETED]

> **This phase is a probe as much as a construction, and it is chartered to be falsifiable in one
> dispatch.** v8's central bet (R11) is that the sources' conjunct-free `K⁺` turns Phase 10's
> trichotomy back into a two-arm dichotomy that the eight faithful modules can consume with a
> signature swap. That bet is settled here, by machine, before a single consumer is touched. If the
> refutation `hasDedekindINF_fails_of_interval_witness` still goes through against a conjunct-free
> antecedent, the bet is **lost**, this phase reports the fact, Phases 11-13 fall back to the
> trichotomy with explicit endpoint branches, and the schedule grows by what the branches actually
> cost. Nothing downstream assumes the bet.

- **Goal**: Land `kplusOpen` / `kminusOpen` as the **Prop-level reading of the already-existing
  `Formula.kPlus` / `Formula.kMinus`** (`Syntax/Formula.lean:180`, `:193`), together with **the
  bridge lemma the tree has never had**; land `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP`
  (eq (5.2) with its left disjunct at the source's `K⁺`); derive them from `SemanticPriorU` /
  `SemanticPriorS` **with no guard and no endpoint disjunct**; and settle by machine whether the
  guard/trichotomy apparatus is needed at all.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/KPlusFaithful.lean` (**new — confirm it does
  not already exist before creating it**), plus **comment-bytes-only** corrections to
  `Kamp/PriorINF.lean` and `Kamp/DedekindINFDense.lean`.
  **`DedekindINF.lean`, `Lemma53.lean`, `Syntax/Formula.lean`, `ProofSystem/Axioms.lean` and all
  eight faithful modules are read, not edited, in this phase.**
- **Tasks**:
  - [x] **Task 0 — existence check (binding, from the v8 postmortem rule).** `find`/`grep` for
        `KPlusFaithful`, `kplusOpen`, `HasFaithfulDedekindINF` and any Prop-level conjunct-free `K⁺`
        before writing a line. If any exists, consume it and record the finding instead of building.
  - [x] **Task 1 — the `.1` audit (R12).** Repository-wide, outside `Boneyard/`: every site that
        projects the first component of a `kplus` / `kminus` hypothesis. The survey at this revision
        found **exactly three**, all inside `DedekindINFDense.lean`'s own refutation machinery
        (`:467`, `:486`, `:609`), and confirmed that
        `orderedPointsExist_combine_kplus` (`Lemma53Faithful.lean:137`, `obtain ⟨-, hdense⟩ := hk`),
        `hasDefinableINF_excludes_kplus` (`Lemma53.lean:296`) and `hasDefinableSUP_excludes_kminus`
        (`Lemma53FaithfulPast.lean:339`) all discard it. **Re-run the audit and record the result in
        the summary.** Any site the survey missed is recorded and keeps the strong carrier via a
        shim rather than being weakened.
  - [x] Define `kplusOpen M atomMap P t : Prop :=
        ∀ s, t < s → ∃ r, t < r ∧ r < s ∧ TemporalTruth M atomMap r P`, and `kminusOpen` dually.
        **State in the docstring that this is `kplus` minus its first conjunct, and that the first
        conjunct is the tree's addition, not the sources'.**
  - [x] **Land the missing bridge**: `kPlus_formula_correct :
        TemporalTruth M atomMap t (Formula.kPlus P) ↔ kplusOpen M atomMap P t`, and the `kMinus`
        mirror. **The tree has had `Formula.kPlus` and `kplusFormula` side by side with a
        name-collision warning and no bridge to either's semantics.** This lemma is the phase's
        second deliverable and is independently valuable: `Axiom.prior_U_gap`, `Axiom.prior_S_gap`
        and `Axiom.sep` are all stated with `Formula.kPlus`/`kMinus`, and nothing in the tree could
        previously read them semantically.
  - [x] Land the relating lemmas: `kplus M atomMap P t ↔ ¬TemporalTruth M atomMap t P ∧
        kplusOpen M atomMap P t`; `kplus … → kplusOpen …`; and
        `(TemporalTruth M atomMap t P ∨ kplus M atomMap P t) → kplusOpen M atomMap P t` **together
        with a machine-checked witness that the converse fails**
        *(deviation: altered — the arrow as written is **not a theorem**: `P(t)` does not imply
        `kplusOpen P t`. The plan's own parenthetical ("a point where `P` holds and `P` does not
        occur arbitrarily soon after") specifies the counterexample to exactly that direction, so
        the intended content is unambiguous and was landed in full: `truth_or_kplus_of_kplusOpen :
        kplusOpen P t → TemporalTruth t P ∨ kplus P t` (the true direction, and the one the shim
        lattice needs), plus `kplusOpen_not_implied_by_truth_at`, the machine-checked witness that
        the stated direction fails — `denseClosedRayFlow` at `t = 0`. Nothing is weakened; one
        arrow is turned around and its failure is proved.)* The pair is what makes the
        trichotomy's weakness precise rather than asserted.
  - [x] Define `HasFaithfulDedekindINF` — `HasDedekindINF`'s `first_occ` field character-for-character
        **except** that the left disjunct is `kplusOpen M atomMap P z0` in place of
        `kplus M atomMap P z0` — and `HasFaithfulDedekindSUP` dually. **Rule 6**: state what the
        carrier excludes.
  - [x] Prove `prior_hasFaithfulDedekindINF_dense : SemanticPriorU M atomMap →
        HasFaithfulDedekindINF M atomMap`, and the `SemanticPriorS` mirror.
        **Proof skeleton (paper-derived at this revision; transcribe and verify, do not treat as
        established).** Fix `P`, `z₀ < z₁`, `P` occurring in `(z₀,z₁)`. `by_cases` on whether some
        `(z₀,s)` is `P`-free.
        1. **No `P`-free initial stretch** — that *is* `kplusOpen M atomMap P z₀`; take the left
           disjunct. (Rabinovich's subcase `r₀ = z₀`, PDF p.8, at his own `K⁺`.)
        2. **Some `(z₀,s)` is `P`-free** — then `U(⊤,¬P)(z₀)` holds, and `P` occurring in `(z₀,z₁)`
           gives `F(¬¬P)(z₀)`. `SemanticPriorU` at `p := ¬P` yields `r₀ > z₀` with `¬P` throughout
           `(z₀,r₀)` and `P(r₀) ∨ K⁺(P)(r₀)`; `r₀ < z₁` because `P` occurs in `(z₀,z₁)` and `¬P`
           holds on `(z₀,r₀)`. That is eq (5.2) verbatim.
        **The case split is on the interval, never on `z₀`** — which is why no guard appears.
        Note that `P(r₀) ∨ kplusOpen P r₀` and `P(r₀) ∨ kplus P r₀` are interderivable as
        *disjunctions*, so the right disjunct is literally `HasDedekindINF`'s.
  - [x] Land the shim lattice, and state which directions are **not** available and why:
        `HasDedekindINF.toHasFaithfulDedekindINF` (weakening — keeps every current supplier,
        including the whole discrete pipeline via `HasAttainedINF.toHasDedekindINF`);
        `HasFaithfulDedekindINF.toHasDenseDedekindINF` (the faithful carrier supplies the
        trichotomy, since `kplusOpen → kplus ∨ P(z₀)`); and a recorded note that
        `HasDenseDedekindINF → HasFaithfulDedekindINF` is **not** available, because `P(z₀)` does
        not imply `r₀ = z₀`. Mirrors for `SUP`.
  - [x] **THE PROBE (R11's falsification, and this phase's most important task).** Re-run the
        interval-witness refutation against the conjunct-free antecedent: attempt
        `hasFaithfulDedekindINF_of_interval_witness` — i.e. show that at `denseWindowFlow` with
        `z₀ = 1/2`, `z₁ = 1`, the point at which `denseWindow_endpoint_disjunct_forced` forces the
        trichotomy's third disjunct, **`HasFaithfulDedekindINF`'s left disjunct holds**. Land it as
        a named lemma. **Record the outcome explicitly in the summary and handoff, in these terms**:
        either *"the guard/trichotomy apparatus is a repair for the tree's `kplus` and is not needed
        by a source-exact carrier"*, or *"the refutation survives the conjunct-free antecedent"* —
        the latter falsifies R11 and triggers the chartered fallback.
  - [x] **Anti-vacuity, positive.** Instantiate `prior_hasFaithfulDedekindINF_dense` at Phase 9's
        `denseWindowFlow` and land the resulting `HasFaithfulDedekindINF` as a named lemma.
  - [x] **Anti-vacuity, re-base corollary (v8).** Exhibit a structure satisfying
        `HasFaithfulDedekindINF` that does **not** satisfy `HasDedekindINF` — `denseWindowFlow` is
        the intended witness and `hasDedekindINF_fails_on_dense_window` already supplies the second
        half. Without this the "weakening" may be an equivalence in disguise.
  - [x] **Docstring correction 1 — `PriorINF.lean`, comment bytes only.** Record on `kplus` that it
        is **not** Reynolds' or Rabinovich's `K⁺`: quote both source definitions
        (`¬U(⊤,¬A)` / `¬((¬F)UntilTrue)`, and *"`K+(F)` holds at `t` iff
        `t = inf({t′ | t′ > t and F holds at t′})`"*), name `Formula.kPlus` (`Syntax/Formula.lean:180`)
        as the tree's source-exact spelling and `kplusOpen` as its Prop-level reading, and point at
        the collision warning at `Formula.lean:163-179`. **Resolve the unresolved doubt already in
        the file at `:75-81`** (*"Actually wait, the Rabinovich paper uses the notation
        differently"*) rather than leaving it. **No statement or proof byte changes.**
  - [x] **Docstring correction 2 — `DedekindINFDense.lean`, comment bytes only.** Withdraw the claim
        that Rabinovich's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is false read literally; replace it with the
        accurate statement (the biconditional is a definitional restatement under his Definition (3);
        the tree's `kplus` carries an extra conjunct neither source has). Complete the honesty-charter
        Rule 4 label already present on the guard/trichotomy apparatus by recording **what it is glue
        for**. **No statement or proof byte changes; every landed theorem stays exactly as it is.**
  - [x] **Verify both corrections are comment-only**: `git diff -U0` on the two files shows changes
        only inside `/-` … `-/` or `--` lines; re-run `#print axioms` on
        `prior_hasDenseDedekindINF_dense` and `hasDedekindINF_fails_of_interval_witness` and confirm
        unchanged.
  - [x] Docstrings on all new declarations per the honesty charter: `Rabinovich 2014, K⁺ definition
        and Lemma 5.3 eq (5.2), PDF pp.3 and 8`; `Reynolds 1992, K⁺ abbreviation and Prior-U,
        printed p.168` — **re-verify both printed pages against the PDF and record any correction**.
  - [x] `#print axioms` on every new declaration; regression canaries `completeness_dense`,
        `completeness_discrete`, `countermodel_discrete_reynolds_v2`.
  - [x] Add the aggregator import edge for CI protection, matching Phases 9 and 10's practice
        (`WeakCanonical.lean`).
  - [x] Scoped build green; full `lake build` green; sorry census unchanged.
- **Estimated output**: ~320 lines (new module), plus ~40 lines of corrected comments across two
  files.
- **Done when**: `kplusOpen`, `kminusOpen`, **the `Formula.kPlus`/`kMinus` bridge lemmas**,
  `HasFaithfulDedekindINF`/`SUP`, `prior_hasFaithfulDedekindINF_dense`/`SUP` and the shim lattice
  are sorry-free with axioms exactly `[propext, Classical.choice, Quot.sound]`; **the probe's
  outcome is recorded explicitly in the summary and handoff, either way**; the anti-vacuity witness
  and the re-base-corollary witness both land; the two docstring corrections are verified
  comment-only; the three canaries are unchanged; `DedekindINF.lean`, `Lemma53.lean`,
  `Syntax/Formula.lean`, `Axioms.lean` and all eight faithful modules are byte-identical; full
  `lake build` green; sorry census exactly `Transfer.lean:1242`.
- **Depends on**: 10.
- **Timing**: 5 hours.
- **If the probe falsifies R11**: report the phase `[COMPLETED]` anyway — the carrier, the bridge
  and the corrections are all real deliverables — but record the falsification prominently in the
  handoff's `route_critical_findings`, and flag that Phases 12 and 12.1 must take the trichotomy
  fallback. Do **not** dispatch Phase 11 without the orchestrator having read that finding.

### Phase 11: Faithful-carrier re-base, base layer — `Lemma53Faithful` + `Lemma53FaithfulPast` [IN PROGRESS]

> **v7's charter for this phase is withdrawn as factually wrong about the tree.** v7 chartered the
> construction of a new `EANegationFix/OnBuilderFaithful.lean`, ~350 lines. `Lemma53Faithful.lean`
> (391 lines) **already exists**, sorry-free and CI-protected, and already contains the printed
> three-disjunct `Oₙ₊₁` over `HasDedekindINF` — including the `Subcase r₀ = z₀` branch that the
> attained carrier deletes. Its Since mirror `Lemma53FaithfulPast.lean` (364 lines) exists too and
> **was absent from the Phase 10 handoff's list**. This phase re-bases them; it builds nothing from
> scratch.

- **Goal**: `Lemma53Faithful.lean` and `Lemma53FaithfulPast.lean` re-based from `HasDedekindINF` /
  `HasDedekindSUP` onto `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP`, every declaration
  preserved with its conclusion unweakened, and the `K⁺` primitives in `Lemma53Faithful.lean`
  re-pointed at the source-exact spelling.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53Faithful.lean`,
  `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53FaithfulPast.lean`.
  **`Lemma53.lean`, `DedekindINF.lean`, `PriorINF.lean`, `EANegationFix/**` and
  `EANegationFixFaithful/**` are read, not edited.**
- **Tasks**:
  - [ ] Re-point the `K⁺` primitives in `Lemma53Faithful.lean`: land `kplusOpenPred` beside
        `kplusPred` (`:81`) as `⟨Formula.kPlus P.formula⟩` — **the object-language spelling already
        exists and needs no new formula** — with `kplusOpenPred_eval` from Phase 10.1's bridge;
        `kplusOpenLeftBlock` beside `kplusLeftBlock`; and
        `orderedPointsExist_combine_kplusOpen` beside `orderedPointsExist_combine_kplus` (`:137`).
        **The last is expected to be nearly free**: the landed proof opens its hypothesis as
        `obtain ⟨-, hdense⟩ := hk`, discarding exactly the conjunct being dropped. Prove the landed
        `kplus` versions **from** the `kplusOpen` ones so nothing is duplicated in substance.
  - [ ] Re-base `negChainOnFaithful` and `negChainOnFaithful_iff` (`:230` binder, `:274` destructure)
        onto `HasFaithfulDedekindINF`, keeping the printed three-disjunct `Oₙ₊₁` — disjunct (2) now
        gated on the **source-exact** `K⁺`, which is Rabinovich's own *"`K⁺(P₁)(z₀) ∧
        Oₙ(P₂,…,Pₙ,z₀,z₁)`"* (PDF p.9, corpus `chunk_0016.md:3`) rather than a strictly stronger
        proxy. **The two-arm `rcases … with hk | ⟨r0, …⟩` shape is expected to survive unchanged**;
        only `hk`'s type moves.
  - [ ] Re-base `lemma53Faithful` (the `∃ O, ∀ M …` form) onto the faithful carrier.
  - [ ] Re-base `HasDedekindSUP.last_occ_tp` (`Lemma53FaithfulPast.lean:181`, an unconditional
        wrapper) and the `kminus` primitives (`kminusFormula`, `kminus_formula_correct`,
        `kminusPred`, `kminusPred_eval`, `orderedPointsExist_combine_kminus`) onto the mirror.
  - [ ] **Preserve `prior_makes_disjunct2_unreachable` (`Lemma53Faithful.lean:382`) and
        `prior_makes_kminus_disjunct_unreachable` (`Lemma53FaithfulPast.lean:355`)**, and land their
        faithful-carrier analogues or record why the analogue does not hold. These two are the
        tree's machine-checked statement that the discrete pipeline cannot observe disjunct (2); if
        the faithful carrier changes that, **say so** — it is exactly the observability the dense
        route needs.
  - [ ] **THE MEASUREMENT (binding, and the input to Phases 11.1-13).** Record in the summary, per
        remaining module and per declaration, whether the re-base was (a) binder-type only,
        (b) binder + a projection/name fix, or (c) genuinely new proof. Give counts and file:line.
        **Phases 11.1, 12, 12.1 and 13 are scheduled against this measurement, not against this
        plan's estimate.** In particular state plainly whether the two-arm shape survived — that is
        R11's verdict at the smallest site.
  - [ ] Docstrings: `Rabinovich 2014, Lemma 5.3 and eq (5.2), PDF pp.8-9`, with an `ADAPTED-FROM`
        note naming the previous `HasDedekindINF` pin and one clause on what changed (the left
        disjunct moved from the tree's `kplus` to the source's `K⁺`). Cite Rabinovich's printed
        `Oₙ₊₁` disjunct list verbatim so a reader can check the transcription disjunct by disjunct.
  - [ ] `#print axioms` on every re-based declaration; regression canaries.
  - [ ] Scoped build green; full `lake build` green; sorry census unchanged.
- **Estimated output**: ~280 lines changed/added across the two modules.
- **Done when**: both modules compile with every pre-existing declaration present, sorry-free,
  axiom-clean and with its conclusion unweakened; `negChainOnFaithful_iff` and `last_occ_tp` are
  stated at the faithful carriers; **the measurement is recorded**; the three canaries are
  unchanged; `Lemma53.lean`, `DedekindINF.lean`, `PriorINF.lean` and `EANegationFix/**`
  byte-identical.
- **Depends on**: 10.1.
- **Timing**: 6 hours.
- **Decomposition protocol (R2)**: if the re-base needs more than one agent run, land whatever is
  green (the INF side is the natural first half; the `Past`/SUP mirror is the second), record a
  named sub-phase list in the summary and handoff, and report `[PARTIAL]`. Do **not** expand
  silently and do **not** stub with `sorry`.
- **Fallback (R11)**: if Phase 10.1's probe falsified the bet, or if the two-arm shape does not
  survive here, re-base onto `HasDenseDedekindINF` instead and handle the `P(z₀)` disjunct
  explicitly at `:274` — recording the branch's actual content, since `P(z₀)` supplies no infimum
  information and the branch must derive what it needs from the ambient hypotheses. Report the
  extra cost honestly rather than absorbing it.

### Phase 11.1: Faithful-carrier re-base — `BoundedFixFaithful` + `BoundedFixAnchoredFaithful` [NOT STARTED]

- **Goal**: Rabinovich Corollary 5.4, unanchored and anchored, re-based onto the faithful carrier.
  Surveyed as **pure signature swap**: four hypothesis sites, **no destructure sites** — both
  modules delegate to `Lemma53Faithful`'s primitives without opening the carrier.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/BoundedFixFaithful.lean`
  (371 lines, sites `:188`, `:258`),
  `.../EANegationFixFaithful/BoundedFixAnchoredFaithful.lean` (355 lines, sites `:150`, `:230`).
  **`EANegationFix/BoundedFix.lean` and `EANegationFix/BoundedFixAnchored.lean` — the attained
  originals — are read, not edited.**
- **Tasks**:
  - [ ] Swap the four hypothesis binders to `HasFaithfulDedekindINF` and re-point every downstream
        application at Phase 11's re-based primitives.
  - [ ] Confirm by inspection — and record — that neither module opens the carrier. If either does,
        that is a survey miss: record it with file:line and treat it under the Phase 11 fallback.
  - [ ] Verify every pre-existing declaration is present with its conclusion unweakened.
  - [ ] Docstrings: `Rabinovich 2014, Corollary 5.4(1)/(2), PDF p.9`, with `ADAPTED-FROM` naming the
        previous pin and the one-clause change.
  - [ ] `#print axioms`; regression canaries; scoped build green; full `lake build` green.
- **Estimated output**: ~120 lines changed.
- **Done when**: both modules compile with all declarations preserved, sorry-free and axiom-clean at
  the faithful carrier; canaries unchanged; the attained originals byte-identical.
- **Depends on**: 11.
- **Timing**: 4 hours.
- **Decomposition protocol**: as Phase 11 — split at the module boundary.

### Phase 12: Rabinovich Lemma 5.1 re-based — `NegFixOneFaithful` [NOT STARTED]

> **The first of the two genuinely hard sites.** `negFixOneFaithful_cover`
> (`NegFixOneFaithful.lean:422`) is by-cases-reached with no left-endpoint hypothesis in scope, and
> its `Case1 / Case2 / Case3a/b/c` structure — Rabinovich's own, transcribed — has **no slot** for a
> "`P` holds at `z₀`" case. Under the trichotomy this needs new proof branches. Under the faithful
> dichotomy it should not, because Rabinovich's Case 1 is *"`¬α₀(z₀)` or `K⁺(¬β₁)(z₀)`"* and his
> Case 3 is *"`α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀)`, and there is `x ∈ (z₀,z₁)` with `¬β₁(x)`"* (PDF p.9, corpus
> `chunk_0017.md:9`) — **an exhaustive split precisely because `K⁺` is the source's conjunct-free
> one**. That is the negation-chain discipline this phase must transcribe, not assume.

- **Goal**: `NegFixOneFaithful.lean` re-based onto `HasFaithfulDedekindINF`, with the eq (5.3)
  machinery (`infPinPoint`, `allSeg`, `somePointBlock`) and `HasDedekindINF.first_occ_tp` (`:164`)
  re-pointed, and `negFixOneFaithful_cover` (`:422`) re-proved at the faithful carrier.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixOneFaithful.lean`
  (726 lines; hypothesis sites `:156`, `:247`, `:339`, `:403`, `:488`; destructure sites `:164`,
  `:422`). **`EANegationFix/NegFixOne.lean` is read, not edited.**
- **Tasks**:
  - [ ] **First task — transcribe the negation-chain discipline, from the source, before touching a
        tactic.** Record in the module docstring, verbatim and cited, Rabinovich's Lemma 5.1 case
        enumeration (PDF p.9): *"Case 1: `¬α₀(z₀)` or `K⁺(¬β₁)(z₀)`. Case 2: `α₀(z₀)`, and `β₁`
        holds along `(z₀,z₁)`. Case 3: (1) `α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀)`, and (2) there is `x ∈ (z₀,z₁)`
        such that `¬β₁(x)`."*, together with the eq (5.3) use-site guard, printed twice (PDF p.10):
        *"(If `¬K⁺(¬β₁)` holds at `z₀` and there is `x ∈ (z₀,z₁)` such that `¬β₁(x)`, then such
        `r₀` exists …)"* and *"Case 3 is described by `α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀) ∧ (∃z)^{<z₁}_{>z₀}
        INF_{¬β₁}(z₀,z,z₁)`"*. **State explicitly which `K⁺` makes the split exhaustive** — the
        source's conjunct-free one — and that the tree's `kplus` would not.
  - [ ] Re-point `HasDedekindINF.first_occ_tp` (`:164`, unconditional wrapper) onto the faithful
        carrier.
  - [ ] Re-point the eq (5.3) pieces (`infPinPoint`, `allSeg`, `somePointBlock`) at
        `Formula.kPlus` / `kplusOpenPred` via Phase 10.1's bridge and Phase 11's primitives.
  - [ ] Re-prove `negFixOneFaithful_cover` (`:422`) and `negFixOneFaithful_iff` at the faithful
        carrier, preserving Rabinovich's case numbering in the proof structure and in the docstring
        so the transcription is checkable case by case. **Do not merge a case without a stated
        reason; do not close a case by hand-waving.**
  - [ ] Swap the remaining hypothesis binders (`:156`, `:247`, `:339`, `:403`, `:488`).
  - [ ] Verify every pre-existing declaration is present with its conclusion unweakened.
  - [ ] Docstrings: `Rabinovich 2014, Lemma 5.1 and eq (5.3), PDF pp.9-10`, cited by **PDF page
        only** (the `.md` conversion is corrupt for displayed equations); `ADAPTED-FROM` naming the
        previous pin.
  - [ ] `#print axioms`; regression canaries; scoped build green; full `lake build` green.
- **Estimated output**: ~330 lines changed/added.
- **Done when**: `NegFixOneFaithful.lean` compiles with every declaration preserved, sorry-free and
  axiom-clean at the faithful carrier; the negation-chain discipline is transcribed and cited in the
  docstring; the case numbering is preserved; canaries unchanged; `EANegationFix/NegFixOne.lean`
  byte-identical.
- **Depends on**: 11.1.
- **Timing**: 7 hours.
- **Decomposition protocol**: as Phase 11 — the `first_occ_tp` + eq (5.3) primitives and the
  `_cover`/`_iff` pair are a clean seam, and splitting there is the expected outcome if the cover
  resists.
- **Fallback (R11)**: if the faithful dichotomy does not collapse the split here, fall back to the
  trichotomy and add the endpoint branches Rabinovich's enumeration has no slot for. **That is a
  genuinely new sub-argument, not a transcription**: record it as such, label it original glue under
  honesty-charter Rule 4, and split under R2 rather than absorbing the cost.

### Phase 12.1: Rabinovich Lemma 5.1, list form — `NegFixListFaithful` [NOT STARTED]

> **The second hard site.** `negFixListFaithful_iff` (`NegFixListFaithful.lean:446`) is
> by-cases-reached with the same case structure and the same absence of a slot for an endpoint case.

- **Goal**: `NegFixListFaithful.lean` re-based onto `HasFaithfulDedekindINF`, with
  `negFixListFaithful_iff` (`:446`) re-proved at the faithful carrier.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixListFaithful.lean`
  (584 lines; hypothesis site `:335`; destructure site `:446`). **`EANegationFix/NegFixList.lean`
  is read, not edited.**
- **Tasks**:
  - [ ] Swap the hypothesis binder at `:335` and re-prove `negFixListFaithful_iff` (`:446`) at the
        faithful carrier, consuming Phase 12's re-based `negFixOneFaithful_cover`.
  - [ ] Preserve the case numbering and the per-case citations, as in Phase 12.
  - [ ] Verify every pre-existing declaration is present with its conclusion unweakened.
  - [ ] Docstring: `Rabinovich 2014, Lemma 5.1, PDF pp.9-10`; `ADAPTED-FROM` naming the previous pin.
  - [ ] `#print axioms`; regression canaries; scoped build green; full `lake build` green.
- **Estimated output**: ~220 lines changed.
- **Done when**: the module compiles with all declarations preserved, sorry-free and axiom-clean at
  the faithful carrier; canaries unchanged; `EANegationFix/NegFixList.lean` byte-identical.
- **Depends on**: 12.
- **Timing**: 6 hours.
- **Decomposition protocol** and **Fallback (R11)**: as Phase 12.

### Phase 13: Rabinovich Prop 4.2 re-based — `VecEANegFixFaithful` + `Prop42Faithful` [NOT STARTED]

- **Goal**: The top of the faithful chain re-based: `VVecEA2.negFixFaithful_iff` and the Prop 4.2
  per-disjunct lemmas, plus `Prop42Faithful.lean`'s contentfulness guard, all at the faithful
  carrier. Surveyed as **pure signature swap** on both modules — six hypothesis sites, **no
  destructure sites**.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/VecEANegFixFaithful.lean`
  (314 lines; sites `:105`, `:138`, `:207`, `:234`, shim use `:312`),
  `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Faithful.lean` (283 lines; sites `:142`, `:167`).
  **`EANegationFix/VecEANegFix.lean` and `Kamp/Section5Correspondence.lean` are read, not edited.**
- **Tasks**:
  - [ ] Swap the six hypothesis binders and re-point the shim use at `VecEANegFixFaithful.lean:312`
        from `HasAttainedINF.toHasDedekindINF` to the composed
        `HasAttainedINF.toHasDedekindINF |> HasDedekindINF.toHasFaithfulDedekindINF` (or the direct
        composite, landed by name in Phase 10.1 if cleaner) — **so the attained/discrete pipeline
        keeps supplying the faithful carrier unchanged**. Record which composite is used.
  - [ ] Land `prop42_contentful_of_faithful` — the contentfulness guard at the faithful carrier.
        `Section5Correspondence.lean`'s existing `prop42_contentful_of_attained` exists precisely to
        stop this correspondence rotting; the faithful sibling must carry the same guard or the
        re-base is unprotected. **The guard must be non-vacuous**: state what it excludes (Rule 6)
        and exhibit the exclusion.
  - [ ] Verify every pre-existing declaration is present with its conclusion unweakened.
  - [ ] **CI-edge audit (chain closure).** Confirm `NfMultiAnchorBridge.lean`'s import edges
        (`:7-18`, `:238`, `:252`, `:275`, `:297`, `:320`, `:345`) still reach every re-based module,
        and that `WeakCanonical.lean:20-21` still reaches `PriorDefsDense`/`DedekindINFDense`. Add an
        edge for `KPlusFaithful.lean` if Phase 10.1 did not. **Record the audit** — a faithful module
        that falls out of CI rots invisibly, which is the failure `DedekindINF.lean:98-103` names.
  - [ ] Update `NfMultiAnchorBridge.lean`'s `NOTE` comment blocks where they describe the carrier as
        `HasDedekindINF`, so the aggregator's own prose stays true. **Comment bytes only.**
  - [ ] Docstrings: `Rabinovich 2014, Prop 4.2, PDF p.6` (*"Proposition 4.2. (Closure under
        negation) The negation of ∃⃗∀-formulas with at most two free variables is equivalent over
        Dedekind complete chains to a disjunction of ∃⃗∀-formulas."*); `ADAPTED-FROM` naming the
        previous pin.
  - [ ] `#print axioms`; regression canaries; scoped build green; full `lake build` green.
- **Estimated output**: ~200 lines changed/added.
- **Done when**: both modules compile with all declarations preserved, sorry-free and axiom-clean at
  the faithful carrier; `prop42_contentful_of_faithful` is landed and non-vacuous; the CI-edge audit
  is recorded; canaries unchanged; `EANegationFix/VecEANegFix.lean` and
  `Section5Correspondence.lean` byte-identical.
- **Depends on**: 12.1.
- **Timing**: 5 hours.
- **Decomposition protocol**: as Phase 11 — split at the module boundary.
- **BLOCK D RE-BASE CHECKPOINT**: at this point the whole faithful chain — 3,388 lines across eight
  modules, plus `KPlusFaithful.lean` — runs on a carrier that dense Prior structures actually
  inhabit, and `prior_hasFaithfulDedekindINF_dense` connects it to `SemanticPriorU`. The deferral
  recorded at `DedekindINF.lean:87-103` is closed. This is a reusable result of independent value
  and a clean stopping point.

### Phase 14: `uSExpressivelyCompleteOverDensePrior` [NOT STARTED]

> **Re-scoped by v8, same goal.** v7 chartered this phase to compose three from-scratch modules.
> It now composes the **re-based faithful chain** (Phases 11-13) with
> `prior_hasFaithfulDedekindINF_dense` (Phase 10.1). The target, the owned module, the anti-vacuity
> requirement and the `Done when` are otherwise unchanged.

- **Goal**: The composed theorem — `{U,S}` expressive completeness over structures satisfying the
  **dense** Prior axioms — plus its non-vacuity witness. Reynolds' Theorem 3 (§5, printed p.176) at
  the carrier the Dedekind route actually needs.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` (new — **confirm it
  does not already exist**). **`PriorExpressiveness.lean` and `Kamp/KampPrior.lean` are read, not
  edited.**
- **Tasks**:
  - [ ] **First task — measure, do not assume.** Determine and record which carrier
        `kampPriorExpressiveCompleteness` (`KampPrior.lean:672`) and `nfCharacterizableTemporalPrior`
        (`:589`) actually consume, and whether they route through the faithful chain or through the
        attained originals in `EANegationFix/`. v7 assumed the former; the tree must be checked. If
        they route through the attained originals, the composition needs a faithful sibling of
        `kampPriorExpressiveCompleteness` and **that** is this phase's real content.
  - [ ] Land `kampDedekindExpressiveCompleteness` — the `HasFaithfulDedekindINF`/`SUP`-based
        analogue, composing Phases 11-13.
  - [ ] Land `uSExpressivelyCompleteOverDensePrior atomMap h_surj psi :
        { A : Formula // ∀ M, SemanticPriorU M atomMap → SemanticPriorS M atomMap →
        ∀ t, eval M (fun _ => t) psi ↔ TemporalTruth M atomMap t A }`, composing
        `prior_hasFaithfulDedekindINF_dense` / `SUP` with the above. Mirror the landed
        `uSExpressivelyCompleteOverPrior`'s shape exactly, including the `h_surj` binder.
  - [ ] **Inherit, do not silently widen, the domain restriction.** `nf_nvar_exist_all_depths`
        (`KampPrior.lean:363`) carries `hn : n ≤ 1` (the arity-`n ≥ 2` arm is excluded). Record
        whether the composition inherits it and state the restriction in the docstring.
  - [ ] Docstring: `Reynolds 1992, §5 Theorem 3, printed p.176`, quoting the theorem statement, and
        recording that this tree obtains it by Rabinovich's method relativized to the faithful eq
        (5.2) carrier rather than by Reynolds' own reduction to `{U,S,U',S'}` (which would require
        the Boneyard'd, sorry-tainted `stavi_expressive_completeness`).
  - [ ] **Anti-vacuity, and this is the phase's most important task.** Instantiate at Phase 9's
        positive dense witness and land the resulting `{A : Formula // …}` as a named example for at
        least one non-trivial `psi`. A sorry-free `uSExpressivelyCompleteOverDensePrior` whose
        hypothesis no dense structure satisfies would reproduce the exact defect Block D exists to
        repair.
  - [ ] `#print axioms`; regression canaries `completeness_discrete` and
        `countermodel_discrete_reynolds_v2`.
  - [ ] Scoped build green; full `lake build` green; sorry census unchanged.
- **Estimated output**: ~250 lines.
- **Done when**: both declarations sorry-free with axioms exactly `[propext, Classical.choice,
  Quot.sound]`; the carrier measurement of task 1 is recorded; the non-vacuity instantiation lands
  at a dense flow; `#print axioms completeness_discrete` unchanged.
- **Depends on**: 13.
- **Timing**: 5 hours.
- **Decomposition protocol**: as Phase 11 — if task 1 shows a faithful sibling of
  `kampPriorExpressiveCompleteness` is needed, that is a named sub-phase, reported `[PARTIAL]`, not
  a silent expansion.
- **BLOCK D CHECKPOINT**: the tree contains expressive completeness of `{U,S}` at a carrier that
  dense Prior structures actually inhabit. A reusable result of independent value and a clean
  stopping point.

---

> **Blocks E-I (Phases 15-30) are carried forward from v7 unchanged in goal, territory, tasks,
> estimates, timings and dependencies.** The only v8 edits are dependency-arrow updates where a
> Block D phase number moved. Nothing Phase 10 found touches them.

### Phase 15: The dense monadic bridge — chronicle to `OrderedMonadicStructure` over `ℚ` [NOT STARTED]

- **Goal**: Reynolds §9 steps 1-2 (printed p.189): turn the landed rational chronicle into a
  temporal structure *in a finite monadic language* over a countable dense endpointless flow, with
  the bimodal dimension encoded as `ReynoldsBridge.lean` already encodes it at `.Discrete`.
- **Owns**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (new).
  **`ChronicleToCountermodelBasic.lean` and `ChronicleConstruction.lean` are read, not edited, and
  must be byte-identical at phase end.**
- **Tasks**:
  - [ ] **First task, and it is a gate (R7).** Determine whether `mkSigFrom` (**`Transfer.lean:134`**,
        not `ReynoldsBridge.lean`), `Formula.predFormulas` (**`Syntax/Formula.lean:778`**),
        `multiFamTaskFrame` (`ReynoldsBridge.lean:671`), `multiFamOmega` (`:694`) and
        `multiFamOmega_shiftClosed` (`:708`) are independent of `SuccOrder` / `PredOrder` /
        `IsSuccArchimedean`, or whether discreteness is baked into the encoding rather than only into
        `countermodel_discrete_reynolds_v2`'s statement (`:739`). **Preliminary reading says they are
        independent**: `multiFamTaskFrame FamIdx : TaskFrame ℤ` is `WorldState := FamIdx × ℤ` with
        `TaskRel p d q := p.1 = q.1 ∧ q.2 = p.2 + d`, in which `ℤ` occurs only as the carrier and `+`
        only as its group operation. **Verify rather than assume, and record the answer.** If
        discreteness *is* baked in, report `[BLOCKED]` with the exact dependency; do not attempt a
        workaround in this phase.
  - [ ] Land `multiFamTaskFrameGen (D) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
        (FamIdx) : TaskFrame D` and its `Omega`/shift-closure siblings, **beside** the `ℤ` versions
        (which `countermodel_discrete_reynolds_v2` consumes and which must stay byte-identical), and
        prove the `ℤ` instances are definitionally the specializations — or record why not. Phase 30
        consumes these at `D := ℝ`.
  - [ ] Note for the record: `mkSigFrom` lives in `Transfer.lean`, which carries the repository's
        single live sorry at `:1242` in an **unrelated** declaration. Importing it is normal and
        already universal. `Transfer.lean:1242` is not to be attempted.
  - [ ] Build `chronicleMonadicStructure fc A h_mcs h_box_dense root : OrderedMonadicStructure
        (mkSigFrom root)` with carrier `Rat`, interpreting each predicate of `mkSigFrom root` as
        membership of the corresponding `predFormula` in the chronicle family's MCS at that rational.
        Reuse `cantorBfmcsDense`'s `evalFamily` for the root family and its `families` set for the
        modal dimension.
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
- **Done when**: the structure and its truth-correspondence lemma are sorry-free and axiom-clean; the
  R7 gate answer is recorded; frozen files byte-identical.
- **Depends on**: — (may run in parallel with Phase 10.1).
- **Timing**: 7 hours.

### Phase 16: The chronicle structure is a dense Prior structure satisfying Sep [NOT STARTED]

- **Goal**: Reynolds §4 Corollary 1 clause 3 (printed p.174), in the monadic idiom: *"all
  substitution instances of the axioms Prior-U, Prior-S and Sep are valid in `M`"* — for the
  structure Phase 15 built.
- **Owns**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (extends
  Phase 15).
- **Tasks**:
  - [ ] Prove `chronicleMonadic_semanticPriorU`: the structure satisfies `SemanticPriorU`. Route:
        `Axiom.prior_U_gap` has `minFrameClass = .Dedekind`, so at `fc := FrameClass.Dedekind` every
        substitution instance is a theorem, hence in every MCS (`theorem_in_mcs`,
        `MaximalConsistent.lean:491`), hence true at every point by Phase 15's truth correspondence.
        Carry `(hfc : FrameClass.Dedekind ≤ fc)`. **Note (v8): `Axiom.prior_U_gap` is stated with
        `Formula.kPlus` (`Axioms.lean:377`; `Syntax/Formula.lean:180`), and Phase 10.1's bridge
        lemma is what reads it semantically. Cite the bridge by name; do not substitute
        `kplusFormula`.**
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
        the cross-reference explicitly; if Phase 14 has landed, land the application as a named lemma
        here.
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
        (`IntegerModel/GoodStructures.lean:729`) and **record** whether it can be reused as-is or
        needs a dense sibling — do not silently generalize the landed one.
  - [ ] Define `rhoFormula ε` as the monadic
        `∃y>x ¬ε(x,y) ∧ ¬∃z(x<z ∧ ε(x,z) ∧ ∀y(x<y<z → ε(x,y)))`, verbatim from printed p.177, and
        `lambdaFormula ε` dually.
  - [ ] Prove **Lemma 2**: *"there is a `US`-formula `R` which holds in any Prior structure `N`
        exactly at those points whose `∼_N`-class ends in a gap on the right"*, by applying
        `uSExpressivelyCompleteOverDensePrior` (Phase 14) to `rhoFormula ε`. Dually `L`.
  - [ ] Record, in the docstring, the uniformity Reynolds relies on: the same `R` works in *any*
        Prior structure, because expressive completeness is uniform over the class (§5, printed
        p.176: *"Note the uniformity of the translation over the whole of `S`"*). Lemma 9 uses
        exactly this.
  - [ ] Docstrings: `Reynolds 1992, §6, printed pp.176-177` and `§6 Lemma 2, printed p.177`.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~300 lines.
- **Done when**: `ContempEquivDense`, `rhoFormula`, `lambdaFormula` and Lemma 2 (both directions) are
  sorry-free and axiom-clean; the `ContempEquiv`-reuse question is answered in the summary.
- **Depends on**: 14, 16.
- **Timing**: 6 hours.

### Phase 18: Reynolds §6 Lemmas 3 and 4 — maximal `R`-intervals [NOT STARTED]

- **Goal**: *"The maximal intervals in which `R` holds are open intervals which, if bounded, have
  elements of `M` as their (excluded) end points"* (Lemma 3) and *"There is no last class and no
  first class in any maximal interval of `R`"* (Lemma 4).
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean` (new).
- **Tasks**:
  - [ ] Prove Lemma 3, transcribing Reynolds' three-case argument (printed p.177): `ρ` at `t` gives
        `R` for a while after `t`; if `R` does not hold forever after `t` then Prior-U applied to `R`
        gives either a last point of the `R`-stretch (impossible given `ρ`) or a first point of `¬R`;
        looking left, Prior-S gives three cases of which the third — a first point `s` of `R` with
        `R ∧ K⁻(¬R)` at `s` — is ruled out by the auxiliary formula `B` ("the class we are now in
        begins with a point satisfying `R ∧ K⁻(¬R)`"), which exists by expressive completeness and
        contradicts Prior-U.
  - [ ] Prove Lemma 4, transcribing printed p.177: the last class in a maximal `R`-interval would not
        end in a gap; and the temporal equivalent of `ρ(x) ∧ ∀y<x (y<z<x ∧ ε(y,z))` is true only in
        first classes, so a first class would give a formula true up to a gap and false arbitrarily
        soon after, contradicting Prior-U.
  - [ ] Each auxiliary formula obtained by expressive completeness is landed as a **named**
        definition with its defining monadic formula, not as an inline `obtain` — Phases 19-21 reuse
        the pattern and a named family is what makes them cheap.
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
  - [ ] Prove the second statement: relativize a monadic sentence `φ` to `ε(x,−)`, obtain `φ'` of one
        free variable, apply expressive completeness, and conclude by the first statement.
  - [ ] Land the **relativization operator** `relativizeToClass ε φ` as a named, reusable definition
        — Phase 25 (Lemma 12) needs exactly the same operator for `γ(z,t)`.
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
        interval, the formula `C` true only at points within a class after some `¬B` in that class is
        false at the start and true at the end of each class, hence true up to the gap and false
        arbitrarily soon after — contradicting Prior-U. Second part by applying the first to `¬B`.
  - [ ] Docstrings: `Reynolds 1992, §6 Lemma 6 / Lemma 7, printed pp.178-179`.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines.
- **Done when**: both lemmas sorry-free and axiom-clean.
- **Depends on**: 19.
- **Timing**: 7 hours.
- **Decomposition protocol**: as Phase 18 — split at the Lemma 6 / Lemma 7 boundary if needed.

### Phase 21: Reynolds §6 Lemma 8 — truth preservation under bad-interval surgery [NOT STARTED]

- **Goal**: *"For all temporal formulas `A`, for all `t ∈ N`, `M ⊨ A(t)` iff `N ⊨ A(t)"`*, where `N`
  is `M` with a whole bad interval `Q₀` replaced by one of its `∼`-classes `I`.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/TruthTransfer.lean` (new).
- **Tasks**:
  - [ ] Define the surgered structure `N` with domain `Q⁻ ∪ I ∪ Q⁺` (printed p.179).
  - [ ] Prove Lemma 8 by induction on `A`, transcribing all thirteen cases from printed pp.179-180:
        seven forward `U(A,B)` cases and six backward, with `S(A,B)` by the mirror. Each case's
        justification is written out in the source; Lemma 7 is what closes cases 2, 3, 5 and 6 in
        both directions.
  - [ ] Compare against the landed `truth_transfer` (`Transfer.lean:361`) and reuse whatever
        transfers; record what does and does not.
  - [ ] Docstring: `Reynolds 1992, §6 Lemma 8, printed pp.179-180`, with the case numbering preserved
        so a reader can check the transcription case by case.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~500 lines.
- **Done when**: Lemma 8 is sorry-free and axiom-clean with all thirteen cases discharged (no case
  closed by hand-waving, no case merged without a stated reason).
- **Depends on**: 20.
- **Timing**: 9 hours.
- **Decomposition protocol**: as Phase 18 — the `U`/`S` and forward/backward boundaries are both
  clean seams.

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
        `R` cannot have been true. The step "`N` is a Prior structure" needs care in Lean: state it
        as its own named lemma.
  - [ ] Land `no_gaps_dense_prior` — **Theorem 4**, the D1 hypothesis of Doets' theorem — stated so
        Phase 29 can consume it directly.
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
  - [ ] Prove that the classes are **closed intervals**, from Theorem 4 plus density: *"if a class has
        an excluded end point then this point is in the next class and this contradicts density"*
        (printed p.184).
  - [ ] Prove Theorem 5, transcribing printed pp.184-185: with `c < d`, `c ≁ d`, `c` the right
        endpoint of its class, let `C` be true exactly at left endpoints of classes (**expressive
        completeness**, Phase 14); `C ∧ U(C,¬C)` never holds, so `¬K⁺(C ∧ U(C,¬C))` holds at `c`;
        `K⁺(C)` holds at `c`; Sep gives `K⁺(K⁺C ∧ K⁻C)` at `c`; some `e` between `c` and `d` has
        `K⁺C ∧ K⁻C` and must be in a class of its own. **Note (v8): `Axiom.sep` is stated with
        `Formula.kPlus`/`kMinus`; read it through Phase 10.1's bridge, cited by name.**
  - [ ] Land `dense_singletons_of_sep` — the D2 hypothesis of Doets' theorem.
  - [ ] **Anti-vacuity**: instantiate at `chronicleIsDensePriorSepStructure` (Phase 16).
  - [ ] Docstrings: `Reynolds 1992, §7 Theorem 5, printed pp.184-185`, quoting *"We use expressive
        completeness here"* at the point where Phase 14 is consumed — that sentence is the reason
        Block D exists and the docstring should say so. **Reynolds' Lemma 10 (Sep's validity over
        real flows, printed p.184) is NOT re-derived**: `sep_valid` (`Soundness.lean:1601`) is landed
        and already stated at `ValidDedekindDense`. Phase 23 consumes `Axiom.sep`'s *derivability*
        side, exactly as Phase 16 does for Prior-U/Prior-S.
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
        `veryGoodDense M` (`∀ t < u`, `M|(t,u)` non-empty and good). **Genuinely new definitions, not
        instantiations.** The landed `good` (`:78`) is `∃ Z : ZIntervalStructure sig, …` and the
        landed `VeryGood` (`:86`) quantifies over **closed** `a ≤ b`; Reynolds' dense forms (printed
        p.186) use **open** intervals and strict `t < u`. Record the difference in the docstring; it
        is not cosmetic — the open/closed choice is what makes Lemma 11's `Σ_{i∈ℤ}(N|{aᵢ} + Rᵢ)` have
        flow isomorphic to `ℝ`.
  - [ ] Prove Lemma 11, transcribing printed p.186: for `N` with no endpoints choose `aᵢ` (`i ∈ ℤ`)
        increasing and cofinal both ways; `N|(aᵢ,aᵢ₊₁)` is good, so take `Rᵢ ≡ₖ N|(aᵢ,aᵢ₊₁)` with an
        open real interval as flow; then `N ≡ₖ Σ_{i∈ℤ}(N|{aᵢ} + Rᵢ)`, whose flow is isomorphic to
        `ℝ`. Consume `doets_lemma_1_4` (`OrderedSum.lean:41`). Then the one- and two-endpoint cases
        by adding singleton structures.
  - [ ] Docstring: `Reynolds 1992, §8 Lemma 11, printed p.186` (attributed there to `[8] lemma 6.4`),
        plus `ADAPTED-FROM: IntegerModel/GoodStructures.lean` naming the `ℤ` analogue (Reynolds Lemma
        14, printed p.190) and what changed.
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
        declarations discharge finiteness. **Note the `hn : n ≤ 1` restriction inherited from
        Phase 14.**
  - [ ] Define `ε(x,y)` verbatim from printed p.187, via `γ(z,t)` = relativization of `⋁γᵢ` to
        `(z,t)` and `γ'(z,t) = γ(z,t) ∧ ∃u(z<u<t)` — reusing Phase 19's `relativizeToClass`. Note the
        **open**-interval relativization, versus the closed `[z,t]` of the discrete Lemma 15.
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
  - [ ] Docstrings: `Reynolds 1992, §8 Lemma 13, printed p.187` and `§8 (the shuffle), printed p.186`.
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
        Reynolds' one-line "another simple game argument" directly**; charter it against **Doets 1987,
        3.1.8**: *"if `(I, {i | m(i) ⊨ σ})_{σ∈Z} ≡ⁿ (J, {j | m'(j) ⊨ σ})_{σ∈Z}` then
        `Σ_{i∈I} m(i) ≡ⁿ Σ_{j∈J} m'(j)`"*, which reduces the claim to a `≡ⁿ` fact about the
        `Z`-coloured orders `(ℚ,…)` and `(ℝ,…)`. Consume `NEquivalence.lean`'s `KEquiv`/`kTypeOf`/
        `KType` apparatus for that fact, and `doets_lemma_1_4` (`OrderedSum.lean:41`) for the
        same-index-set case.
        **A statement template exists and must be re-stated, not un-archived**: the drafted
        `doets_lemma_1_5` at `Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean:58` sits behind
        `#exit` (line 41), uses the stale names `k_type_of`/`k_equiv`, and its body is `sorry`. Copy
        the *shape* into a live module under the live names `kTypeOf`/`KEquiv`, and **prove it**. Do
        not import `Boneyard`, and do not reintroduce the `sorry`.
  - [ ] Update the forward pointer at `OrderedSum.lean:20-22` and the archive note at
        `SingletonSorriedDecls.lean:19-24` — or, if editing them is out of territory, record in the
        summary that they are now stale.
  - [ ] Apply `doets_lemma_1_5` to obtain `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)`.
  - [ ] Prove Dedekind completeness of `R`, transcribing printed p.188: *"any subset bounded above
        intersects a last summand. Because the `γᵢ`'s say so the summands themselves are closed
        intervals of the reals so the supremum of the set exists in this class."*
  - [ ] Prove `R` has a countable dense subflow, transcribing printed p.188.
  - [ ] Docstrings: `Reynolds 1992, §8, printed p.188` for each part, plus
        `ADAPTED-FROM: Doets 1987, 3.1.8` for the mixing argument, with a one-clause note that
        Reynolds asserts it without proof.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~500 lines.
- **Done when**: **`doets_lemma_1_5` is landed in live code, sorry-free and axiom-clean, under the
  live names**; the mixing `≡ₖ`, Dedekind completeness, density, endpointlessness and separability of
  `R` are all sorry-free and axiom-clean; the sorry census outside `Boneyard/` is still exactly
  `Transfer.lean:1242`.
- **Depends on**: 26.
- **Timing**: 10 hours.
- **Decomposition protocol**: as Phase 18 — `doets_lemma_1_5` and the three order-theoretic facts are
  a clean seam, and splitting there is the expected outcome if the `≡ⁿ` colouring fact resists.

### Phase 28: `orderIsoRealOfDedekindDenseSeparable` — the order characterization of `ℝ` [NOT STARTED]

> **Confirmed absent from Mathlib.** `Order.iso_of_countable_dense`
> (`Mathlib.Order.CountableDenseLinearOrder`) gives Cantor's theorem for countable dense endpointless
> orders; for `ℝ` only *field*-theoretic uniqueness exists (`ConditionallyCompleteLinearOrderedField`,
> `Mathlib.Algebra.Order.CompleteField`). Reynolds asserts the order-theoretic form in one sentence
> (printed p.188): *"But then `R` being Dedekind complete, dense, without end points and with a
> countable dense subset must be isomorphic to the reals."*

- **Goal**: For a linear order `R` that is densely ordered, without endpoints, Dedekind complete
  (every non-empty bounded-above subset has a lub), and has a countable dense subset:
  `Nonempty (R ≃o ℝ)`.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/OrderIsoReal.lean` (new).
- **Proof skeleton (transcribe, do not re-derive)**:
  1. The countable dense subset `D ⊆ R` is itself densely ordered and without endpoints, and
     non-empty; so `Order.iso_of_countable_dense` gives `e : D ≃o ℚ`.
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
        the *proof* has **no source in the corpus** and is original work.
  - [ ] Search Mathlib once more before writing (`loogle`, `leansearch`) and record the negative
        result in the docstring so a future reader does not repeat the search.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~350 lines.
- **Done when**: `orderIsoRealOfDedekindDenseSeparable` is sorry-free and axiom-clean and the
  anti-vacuity instantiation lands.
- **Depends on**: — (independent of Blocks D-G; **parallel-eligible from wave 2 onward**).
- **Timing**: 7 hours.

### Phase 29: Doets' Theorem — Reynolds §8 Theorem 6 [NOT STARTED]

- **Goal**: `doets_theorem_dense`: *"Suppose that `M` is a temporal structure in a finite language
  whose flow of time is countable, dense and without end points. Suppose further that for any
  contemporaneous equivalence relation `∼` on `M`, D1) the `∼` classes do not end in gaps and D2) if
  `M/∼` is densely ordered, then `M/∼` has a dense set of singletons. Then for all `k < ω`, there is a
  temporal structure with flow of time the real numbers satisfying the same monadic first-order
  sentences of quantifier depth at most `k` as `M` does."*
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean` (new).
- **Tasks**:
  - [ ] Assemble the proof, transcribing printed pp.187-188: if `M` is good, done. Otherwise by
        Lemma 11 there are ≥ 2 `∼`-classes; by Lemma 13 and D1 there is a third between any two, so
        `M/∼` is dense and D2 gives density of singletons. Choose `a < b` with `a ≁ b` and `G`
        minimal; show `M|(a,b)` is very good, contradiction. For `a < c < d < b` with `c ≁ d`: the
        classes strictly between have order type `ℚ` and by minimality all `γᵢ ∈ G` are dense in `I`,
        so `M|(⋃I) ≡ₖ` a shuffle (Phase 26); extend to `ℝ` (Phase 27); the flow is `≅o ℝ` (Phase 28);
        and `M|(c,d) ≡ₖ X + R + Y` (Phase 24 + `doets_lemma_1_4`).
  - [ ] Land the statement so Phase 30 can consume it with `D1 := no_gaps_dense_prior` and
        `D2 := dense_singletons_of_sep` at the chronicle structure.
  - [ ] **Anti-vacuity**: instantiate at `chronicleIsDensePriorSepStructure` (Phase 16) with the D1
        and D2 instances from Phases 22-23, and land the resulting `ℝ`-flowed structure as a named
        definition. This is the phase's real deliverable.
  - [ ] Docstrings: `Reynolds 1992, §8 Theorem 6, printed pp.185-188` and `Doets 1987, 3.3.9`, with
        Reynolds' own note that his statement is slightly stronger and his proof a little different
        because of the contemporaneity notion.
  - [ ] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines.
- **Done when**: `doets_theorem_dense` and the chronicle instantiation are sorry-free and axiom-clean.
- **Depends on**: 23, 27, 28.
- **Timing**: 8 hours.
- **BLOCK H CHECKPOINT**: an `ℝ`-flowed structure `≡ₖ`-equivalent to the chronicle model now exists.

### Phase 30: Reynolds §9 Theorem 7 — the engine and the unconditional terminus [NOT STARTED]

> **This phase absorbs v6's Phase 8.** Its precondition is the availability of `doets_theorem_dense`
> at the chronicle structure. **The `consequence_completeness_dedekind_of_engine` pinned signature
> and commit `bd9ae0ac1` carry over unchanged. There is no conditional terminus.**

- **Goal**: `countermodel_dedekind_dense`, `completeness_dedekind_engine`, and then — by instantiating
  the **pinned, unmodified** Phase 2 theorem — `consequence_completeness_dedekind` and
  `completeness_dedekind`.
- **Owns**: `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`,
  `FormalSystem/Metalogic/StrongCompleteness.lean`, `FormalSystem/Metalogic.lean` (tracking table).
- **Tasks**:
  - [ ] Define the **table** `α(t)` of a `Formula` and its quantifier depth, or verify that the tree's
        existing `tableMu` / `staviFoDepth` layer (`EFGames/StaviCompleteness.lean:237,462`) already
        supplies it; record which. Set `k` to one greater than the depth, per printed p.189.
  - [ ] Prove the transfer: `R ⊨ ∃t α(t)` from `M ⊨ ∃t α(t)` via `≡ₖ`, obtain `b ∈ R` with
        `R ⊨ α(b)`, hence `R ⊨ A₀(b)`.
  - [ ] Convert the `ℝ`-flowed monadic structure back to a `TaskFrame ℝ` + `TaskModel` + shift-closed
        `Omega`, using Phase 15's `multiFamTaskFrameGen` and siblings at `D := ℝ` (the `ℤ` originals
        at `ReynoldsBridge.lean:671,694,708` stay byte-identical), and land `countermodel_dedekind_dense
        {fc} (hfc : FrameClass.Dedekind ≤ fc) (A) (h_mcs) (φ) (h_neg_in) (h_box_dense) :
        ∃ (F : TaskFrame ℝ) (TM : TaskModel F) (Omega) (_ : ShiftClosed Omega) (τ) (_ : τ ∈ Omega)
        (t : ℝ), ¬TruthAt TM Omega τ t φ`. Follow `countermodel_dense_enriched`
        (`Completeness.lean:133`) statement-for-statement with `Rat → ℝ`. **Do not add any hypothesis
        beyond `hfc`.**
  - [ ] Prove `completeness_dedekind_engine (ψ : Formula) : ValidDedekindDense ψ →
        Derivable FrameClass.Dedekind [] ψ`: contrapositive, `neg_consistent_of_not_derivable`
        (`Completeness.lean:72`), `set_lindenbaum`, `dedekind_box_dense_mem`
        (`CompletenessDedekind.lean:149`), then `countermodel_dedekind_dense` at `ℝ` with
        `real_lub_of_bddAbove` (`:127`) discharging the lub binder and `by decide` discharging `hfc`.
  - [ ] Instantiate `consequence_completeness_dedekind_of_engine` (`StrongCompleteness.lean:274`) with
        this engine to obtain the unconditional `consequence_completeness_dedekind`. **Do not restate
        or re-bind that signature** — pinned by commit `bd9ae0ac1`.
  - [ ] Derive `completeness_dedekind (φ : Formula) : ValidDedekindDense φ →
        Derivable FrameClass.Dedekind [] φ` as `consequence_completeness_dedekind []`, with `simp`
        discharging `∀ ψ ∈ [], _`. **It must be a corollary, not an independent proof.**
  - [ ] Verify the root placement: the evaluation family's value at `t = 0` is the root MCS `A`,
        composing with `rooted_cantor_fmcs_dense_at_s` (`ChronicleToCountermodelBasic.lean:513`). A
        mismatch here is silent. Land it as a named lemma, not an inline `have`.
  - [ ] `#print axioms consequence_completeness_dedekind` and `#print axioms completeness_dedekind`;
        record. Regression: `completeness_dense`, `completeness_discrete`,
        `countermodel_discrete_reynolds_v2`.
  - [ ] Update the tracking table in `FormalSystem/Metalogic.lean` with the Dedekind rows, matching
        the existing `Completeness (dense)` / `(discrete)` row format at `:37`,`:39`.
  - [ ] Docstrings: `Reynolds 1992, §9 Theorem 7, printed p.189`, quoting the five proof steps, and
        `Reynolds 1992, §2, printed p.169` for the definition of weak completeness that makes the
        finite-context form fall out.
  - [ ] Full `lake build` green.
- **Estimated output**: ~450 lines.
- **Done when**: `consequence_completeness_dedekind` and `completeness_dedekind` are sorry-free; full
  `lake build` green; `#print axioms` on both shows exactly `[propext, Classical.choice, Quot.sound]`;
  the three regression axiom sets are unchanged; the tracking table is updated; the two frozen
  chronicle files are byte-identical.
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
      unchanged. **Mandatory for every Block D phase**; recommended for all.
- [ ] **Frozen files byte-identical**: `git diff --stat` shows no change to
      `BXCanonical/Chronicle/ChronicleTypes.lean` or `.../ChronicleToCountermodelBasic.lean`. Also
      `ChronicleConstruction.lean`, `CounterexampleElimination.lean` and `cantorIsoDense`.
- [ ] **Amputated layer intact**: every module in the Amputated Assets table still compiles and is
      unmodified.
- [ ] **Territory respected**: no file under `FormalSystem/Metalogic/Decidability/` or
      `FormalSystem/Automation/` read for edit, modified, or staged.
- [ ] **No vacuous definitions**: every `Prop`-valued hypothesis the phase introduces has a witness,
      a derivation, or an exclusion lemma (the anti-vacuity gate). Record which.
- [ ] **Docstring audit**: every new declaration carries a source citation with a printed page (or,
      for the exhaustively named originals, the no-source statement). Any printed page landed in a
      docstring was re-verified against the PDF in this dispatch, or is flagged as carried.
- [ ] No task-number citations in any file outside `specs/`.

**Additional gates for every Block D phase (new in v8):**

- [ ] **Declaration census**: every declaration present in the phase's owned module(s) *before* the
      dispatch is still present *after* it, with its conclusion unweakened. A re-base that loses,
      renames away, or weakens a declaration has failed, not deviated. Record the before/after count.
- [ ] **Re-base strictness (anti-vacuity corollary)**: the shim from the old carrier to the new one is
      landed, **and** a structure is exhibited satisfying the new carrier and not the old.
- [ ] **CI-edge intactness**: every re-based module is still reachable from `FormalSystem.lean`
      through `NfMultiAnchorBridge.lean` (`:7-18`, `:238`, `:252`, `:275`, `:297`, `:320`, `:345`) or
      `WeakCanonical.lean`. A faithful module that falls out of CI rots invisibly.
- [ ] **`K⁺` spelling discipline**: no substitution between `Formula.kPlus` and `kplusFormula` (or
      their `kMinus` mirrors) except through Phase 10.1's bridge lemma, cited by name.
- [ ] **Comment-only edits verified**: where a phase's Tasks list says "comment bytes only",
      `git diff -U0` shows changes confined to `/-` … `-/` or `--` lines, and `#print axioms` on the
      affected declarations is unchanged.

At Phase 30 additionally:

- [ ] `#print axioms consequence_completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `FormalSystem/Metalogic.lean` tracking table updated.

---

## Artifacts & Outputs

| Artifact | Path | Produced by |
|---|---|---|
| This plan | `specs/408_.../plans/08_strong-completeness-dedekind-v8.md` | this revision |
| Superseded predecessor (retained) | `specs/408_.../plans/07_strong-completeness-dedekind-v7.md` | v7; carries the Revision Rationale (v6 → v7) and the Phases 9-10 execution record |
| Per-phase summary | `specs/408_.../summaries/08_phase-{N}-{slug}-summary.md` | each phase |
| Per-phase handoff | `specs/408_.../handoffs/phase-{N}-handoff-{DATE}.json` | each phase |
| Orchestrator handoff | `specs/408_.../.orchestrator-handoff.json` | this revision, then each phase |
| Dense Prior hypotheses | `WeakCanonical/PriorDefsDense.lean` | Phase 9 — **landed** |
| Guarded/trichotomy carriers + the refutation family | `WeakCanonical/Kamp/DedekindINFDense.lean` | Phase 10 — **landed** |
| Source-exact `K⁺`, the `Formula.kPlus` bridge, and the faithful dichotomy carrier | `WeakCanonical/Kamp/KPlusFaithful.lean` | Phase 10.1 |
| Faithful-carrier re-base | `WeakCanonical/Kamp/Lemma53Faithful.lean`, `Lemma53FaithfulPast.lean`, `Prop42Faithful.lean`, `Kamp/EANegationFixFaithful/*.lean` (in place) | Phases 11, 11.1, 12, 12.1, 13 |
| Dense expressive completeness | `WeakCanonical/PriorExpressivenessDense.lean` | Phase 14 |
| Dense monadic bridge | `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` | Phases 15-16 |
| Reynolds §6 (D1) | `WeakCanonical/DenseModelSurgery/*.lean` | Phases 17-22 |
| Reynolds §7 (D2) | `WeakCanonical/DenseModelSurgery/Singletons.lean` | Phase 23 |
| Doets' theorem | `WeakCanonical/RealModel/*.lean` | Phases 24-29 |
| Terminus | `BXCanonical/CompletenessDedekind.lean`, `StrongCompleteness.lean`, `FormalSystem/Metalogic.lean` | Phase 30 |

Commit convention: `task 408 phase {N}: {objective}`, with a `Session:` line in the body, staging
only the task directory plus the files the phase's Tasks list names. `git add -A` and
`git commit -am` are forbidden.

---

## Rollback/Contingency

**Per-phase rollback.** Phases 10.1 and 14-30 each own a new module (Phase 30 extends two existing
ones); rolling one back is deleting its module and its aggregator import line, and no landed
mathematics is touched.

**Block D re-base rollback (new in v8, and the one place rollback is not a deletion).** Phases 11,
11.1, 12, 12.1 and 13 edit landed modules in place. Rollback is `git revert` of that phase's commit,
which is clean because (i) each phase owns a disjoint set of files, (ii) each ends with the tree
green and the canaries unchanged, and (iii) the change is a hypothesis weakening, so reverting
restores a state every supplier already satisfied. **This is why the phases follow the import chain
one boundary at a time rather than sweeping**: a partial sweep cannot be left green, and a sweep
that fails halfway cannot be reverted phase-wise.

**R1 is discharged.** v7's contingency for a Phase 10 failure is spent: the dense Prior axioms *do*
yield the eq (5.2) carrier, sorry-free and axiom-clean. That branch of the plan is closed.

**R11 contingency — the faithful-carrier bet.** v8's central planning bet is that the source-exact
`K⁺` collapses the trichotomy back to a dichotomy the existing consumers can take with a signature
swap. It is **falsifiable in Phase 10.1's probe** and again at the smallest consumer in Phase 11.
If falsified:

1. Phase 10.1 still `[COMPLETED]` — `kplusOpen`, the `Formula.kPlus` bridge and the two docstring
   corrections are real deliverables regardless.
2. Phases 11-13 re-base onto `HasDenseDedekindINF` instead, adding explicit endpoint branches at
   `Lemma53Faithful.lean:274`, `NegFixOneFaithful.lean:422` and `NegFixListFaithful.lean:446`.
3. **Those branches are new mathematics, not transcription**: `P(z₀)` supplies no infimum
   information, so each branch must derive what it needs from the ambient hypotheses. Each is
   labelled original glue under honesty-charter Rule 4, and each is split out under the R2
   decomposition protocol with its own `[PARTIAL]` report — **the cost is recorded, never absorbed
   into an unchanged estimate**.
4. Both carriers stay landed and the shims stay in place throughout, so the fallback is always
   available and never requires undoing work.

**Block-level contingency (R2, R3).** Any phase in Blocks D or F that on contact needs more than one
agent run lands whatever is green, records a named sub-phase list, and reports `[PARTIAL]`. The
orchestrator revises with the sub-phases spliced in at the same numeric level (flat numbering `N.1`,
`N.2`, … — the scan admits **at most one** dot segment, so three-level numbering would be invisible
to dispatch). This is the chartered outcome, not a failure, and it is how v6's Phase 7.5 correctly
became 7.5-7.9 and how v8's Phases 11-13 became 11, 11.1, 12, 12.1, 13.

**Budget contingency (R8).** Every phase ends with the tree green, the sorry census unchanged and the
frozen files byte-identical, so every phase boundary is a clean stop. Running out of budget yields
`[PARTIAL]` with a named next phase. The checkpoints — after Phases 13, 14, 16, 22, 23 and 29 — are
the natural reporting points, and each leaves a reusable result of independent value in the tree.

**Fallback route (recorded, not planned).** If Block D proves intractable, Reynolds' own proof of
Theorem 3 is available in principle: reduce to `{U,S,U',S'}` expressive completeness (Theorem 2 /
GHR93 Theorem 9.3.1) and show `U'(A,B) ↔ ⊥` in every Prior structure by applying Prior-U to `B`. The
tree's `stavi_U_false_on_prior_UZ` (`PriorExpressiveness.lean:90`) is exactly that argument at the
*integer* axioms and would mirror cheaply, and the whole Stavi layer (`StaviConnectives.lean`, 583
lines) is present and sorry-free. **The blocker is the other half**: `stavi_expressive_completeness`
**does not exist as a declaration anywhere in live code** — it survives only at
`Boneyard/StaviDiscretePath/StaviExpressiveCompletenessTail.lean:1674`, its chain top is
sorry-tainted, `EFGames/StaviCompleteness.lean:16` records it as "the dead expressive-completeness
tail", and `PriorExpressiveness.lean:30,350` records that the tree deliberately moved off it onto
`kampPriorExpressiveCompleteness`. Reviving a Boneyard module and discharging its sorry is strictly
more work and strictly less certain than the re-base. Recorded so a future dispatch does not
rediscover it as a novelty.

**What is never a contingency.** Re-opening completion-by-limits; stripping the amputated layer;
generalizing a landed discrete declaration in place; deleting or weakening a declaration in the
faithful subtree; cloning the faithful subtree to avoid a hypothesis weakening; a conditional
terminus; a strategic sorry on the terminus chain; an over-strong hypothesis that makes a theorem
pass vacuously; or substituting one `K⁺` spelling for the other without the bridge.
