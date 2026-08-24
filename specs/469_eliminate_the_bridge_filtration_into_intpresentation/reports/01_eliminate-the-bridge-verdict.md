# Eliminating the Bridge: Filtration into `IntPresentation` — Verdict and Pricing

**Task type**: lean4 · **Topic**: decidability · **Session**: `sess_1787608533_153fad_469`
**Grounding**: `specs/reviews/review-2026-08-24.md` issue C-2 and Addendum 2; task description §7
(re-scope).
**Every claim below cites the check that produced it.** Symbol names, never line numbers.

---

## 0. Verdict in one paragraph

**The re-scoped question — can the rebuilt filtration land in `IntPresentation` directly, so that
no bridge theorem exists to prove? — answers YES, and by a shorter route than Addendum 2's.** The
world-space does not need to be a rebuilt `FilteredWorld` quotient at all: it can be the
**closure-type space** (`Finset`-of-closure-subsets), which is data outright, and the
`def:frame` axioms are then **free**, not multi-month, because `TaskFrame.ofStep` discharges all
seven `TaskFrame` fields for an arbitrary bi-serial relation over ℤ. I confirmed the assembly by
compiling it: given a candidate-presentation family and the finite-model half as a hypothesis,
`Decidable (ValidDiscrete φ)` follows in ~25 lines, sorry-free, with **no transfer lemma, no
enumeration over `Atom`, and no `Fin n`-from-`Finite` extraction anywhere**
(`evidence/decidability-assembly-family-probe.lean`). The soundness half is not a hypothesis — I
**landed it as a compiled 5-line proof** (`evidence/soundness-half-probe.lean`). What remains is
one theorem, and it is **not** routine: a *box-faithful* small-model theorem. Overall verdict:
**PROVABLE-HARD, with a materially cheaper skeleton than either the review or the task description
assumed, and one genuinely research-grade core.**

---

## 1. Verified state of the assets

| Claim | Check that produced it | Result |
|---|---|---|
| Whole tree has exactly one structural `sorry` | `scripts/check-module-invariants.sh --no-build`, C3 | PASS — sole sorry in `countermodel_discrete` (`WeakCanonical/Transfer.lean`) |
| 37 unreachable live modules, all manifested | same run, C6 | PASS |
| BiLasso block = 20 manifest entries | `grep -v '^#' scripts/module-invariants-manifest.txt` | 19 `BiLasso.*` + `FormalSystem.Semantics.Extension.PeriodicExtension` = 20 |
| `Decidability/FMP/` contains zero `TruthAt` | `grep -rc TruthAt FormalSystem/Metalogic/Decidability/FMP/*.lean` | 0 in all six files |
| `specs/ROADMAP.md` never mentions BiLasso | `grep -c BiLasso specs/ROADMAP.md` | 0 |
| Tableau tree size | `find … Verified -name '*.lean'` | 21 files / 30,164 lines (whole `Decidability/`: 61 files / 49,902 lines) |
| BiLasso oleans present | `ls .lake/build/lib/lean/…/BiLasso/` | present — C6 compile-checks them in isolation |

### 1.1 Axiom sets, measured (`#print axioms`, via `lake env lean`)

All of the following measure **exactly** `[propext, Classical.choice, Quot.sound]`:

`check_correct`, `instDecidableSatAtState`, `IntPresentation.toTaskFrame`,
`IntPresentation.card_worldState`, `FMP.filtered_world_bound`, `FMP.FilteredWorld.finite`,
`FMP.filteredCharacteristicSet_injective`, `FMP.mcs_finite_model_property`, `FMP.fmp_size_bound`,
`TaskFrame.extend_periodic`, `TaskFrame.spherical_of_finite`.

**Correction to a premise in the task description.** The task quotes `instDecidableSatAtState` as
"recorded as carrying no `Classical.dec`". That record is accurate *as written* — it is a claim
about **computability** (the instance reduces; the `#guard`s in `Check.lean` are kernel-evaluated
proof of it) — but it is **not** a claim about the axiom set, and the instance does carry
`Classical.choice`. Anyone reading "no `Classical.dec`" as "choice-free" is reading it wrong. This
distinction is the whole subject of §3 below, and getting it right is what makes the route work.

---

## 2. The three gaps, re-verified — and where §7's own premises need correcting

### Gap 1 — carrier normalization. **Confirmed exactly as §7 states it.**

`ValidDiscrete` (`Semantics/Validity.lean`) binds
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]`
`[IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]`. `Semantics/IntNormalForm.lean`'s
module docstring already carries the binder-fit finding verbatim and it is correct:
`orderIsoIntOfLinearSuccPredArch` fits the bundle but gives only `D ≃o ℤ`;
`LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` gives `D ≃+o ℤ` but needs
`Archimedean D` (which does **not** synthesize from the two order-successor classes) plus an
`IsLeast {y | 0 < y}` witness. `Semantics/DurationClassification.lean` carries `archimedean_of_lub`
for the Dedekind branch only; the **successor-based analogue is absent** — confirmed by symbol
enumeration of that file (its only theorems are `archimedean_of_lub`,
`complete_duration_discrete_or_dense`, `complete_not_dense_iso_int`).

§2(a) of the task description is wrong and §7 already says so. Nothing further to adjudicate.

**One thing §7 does not say, and it matters for sequencing**: Gap 1 is needed only in the
*completeness* direction. In the *soundness* direction ℤ instantiates the whole bundle with zero
instance work — see §4.1.

### Gap 2 — the finite model property. **Confirmed unavoidable, and confirmed to have zero current coverage.**

`Decidability/FMP/` does **not** contribute to it. Read `FMP.lean`'s actual termini:
`mcs_finite_model_property` is `¬Derivable FrameClass.Base [] φ → ∃ S : ClosureMCSBundle φ, φ ∉ S.carrier ∧ Finite (FilteredWorld φ)`,
and `fmp_size_bound` adds `Nat.card (FilteredWorld φ) ≤ 2 ^ (subformulaClosure φ).card`. Both are
Lindenbaum-plus-cardinality statements about **MCS membership**. Neither mentions a model, a
history, or a time. Task 468's finding F6 ("FMP is syntactic, not semantic") is therefore **correct
as applied to `FMP/`**; C-2's charge that F6 was "too strong" is correct only in that F6 omitted
`BiLasso/`, which is a different directory proving a different thing (§2.1).

Consequence for planning: "rebuild the filtration" is **not a refactor of `FMP/`**. `FMP/`'s world
space is a quotient of `ClosureMCSBundle` (sets of formulas), its relation is permissive, and it has
no truth lemma. A semantic FMP needs a world space derived from *a given model*, a non-permissive
relation, and a truth lemma. That is a rewrite with a different subject, and `FMP/` supplies at most
its cardinality bookkeeping.

### 2.1 What BiLasso actually proves — and what it does not

`exists_annot_of_truth` (`BiLasso/Extraction.lean`) takes
`(τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (t : ℤ) (hφ : TruthAt P.toModel τ t φ)` — its
input is **already a presentation**. BiLasso is a *model-checking* layer for one given finite graph:
it compresses histories **within** a presentation. It performs no part of Gap 2. `Check.lean`'s own
docstring says so ("It does *not* decide the logic: nothing here quantifies over frames"), and that
docstring is accurate.

### Gap 3 — representation. **This is the genuine bridge, and it is avoidable — but the review's reason is wrong in two places.**

**Correction A (factual).** Addendum 2 states that `filteredCharacteristicSet_injective` "embeds
`FilteredWorld phi` into `Finset (subformulaClosure phi)`". It does not. Reading
`FMP/FiniteModel.lean`: `filteredCharacteristicSet` lands in **`Set (subformulaClosure phi)`**, and
the ambient finiteness instance `set_finite` is declared **`noncomputable`**, as is
`FilteredWorld.finite` itself. So the existing filtration world-space is *not* "already data-shaped";
it is `Prop`-shaped, exactly like every other `Finite`. The review's factual ground for
"§(i) the world-space is already the right shape" does not hold.

**Correction B (pricing).** Addendum 2 prices "re-discharging all four `def:frame` axioms for a
non-universal filtered relation" as "the multi-month piece … unavoidable on ANY route". Over
**ℤ**, that is false, and the counter-evidence is landed. `TaskFrame.ofStep`
(`Semantics/IntNormalForm.lean`) discharges all seven `TaskFrame` fields from a bare bi-serial
relation on a finite nonempty carrier; its own docstring tabulates the sources:

| field | source |
|---|---|
| `nonempty` | the `[Nonempty W]` instance |
| `nullity_identity` | free — `iter R₁ 0` *is* `Eq` |
| `comp` | free — `iter_add` |
| `converse` | free — `ofStepRel` is sign-symmetric by construction |
| `serial` | **the one genuine obligation**: exactly `fwd` and `bwd` |
| `limit` | `TaskFrame.limit_of_succOrder` |
| `spherical` | `TaskFrame.spherical_of_finite` |

So for **any** non-permissive relation over ℤ on a finite carrier, the four `def:frame` axioms cost
**one obligation** — bi-seriality — and nothing else. `IntPresentation.toTaskFrame` is literally
`TaskFrame.ofStep P.stepRel P.fwd P.bwd`. The multi-month figure Addendum 2 attaches here is an
artifact of the `FMP/` frames being **polymorphic in `D`** (`RefinedFilteredTaskFrame D`), where
`limit_of_succOrder` and `ofStep` are unavailable. **Doing Gap 1 first buys the right to work over
ℤ, and working over ℤ makes the axiom re-discharge free.** That is the single largest cost
correction in this report, and it reorders the plan.

---

## 3. The constructive-line accounting (task §3, per half)

§3's distinction **holds**, and it holds for a sharper reason than §3 gives.

### 3.1 The classical half: the existence theorem

`¬ ValidDiscrete φ → ∃ P ∈ cands φ, ∃ w, SatAtState P w φ.neg` is a `Prop`. Everything inside it
may be classical: choosing the countermodel, `Classical.dec`-ing a `Prop`-valued relation into a
`Bool`, selecting a realized subgraph. **Expected axiom set: `[propext, Classical.choice,
Quot.sound]`** — i.e. exactly what every landed theorem in this area already measures (§1.1),
including `check_correct` itself.

### 3.2 The computable half: the decision procedure

The procedure never sees the `P` produced by the existence proof. It ranges over its own,
independently constructed candidate list. `check` computes (`Check.lean`'s three `#guard`s are
kernel-evaluated: `!checkAt loopPresentation 0 ⊥ 1`, `checkAt loopPresentation 0 (atom pA) 1`,
`!checkAt loopPresentation 0 (atom qA) 1` — the third is the load-bearing one). **Expected axiom
set: the same `[propext, Classical.choice, Quot.sound]`, with computability preserved**, because
`Classical.choice` sits in the *proofs about* the data, never in the data.

### 3.3 Why `PeriodicExtension.lean`'s objection does not transfer — the precise reason

`PeriodicExtension.lean`'s module docstring is aimed at *emitting a certificate a model checker can
consume*: there, a `Classical.choice`-produced `IntPresentation` is worthless, because the whole
point is that the object be evaluable. Here it is not worthless, because the object produced
classically is never evaluated — only quantified over.

And there is a second, stronger reason the objection cannot bite, which §3 does not name:
`Fin n → Fin n → Bool` is a `Fintype` with `DecidableEq`. A `step` function defined via
`Classical.dec` is still **equal** to one of the finitely many enumerated functions. So a classically
constructed presentation is automatically *captured* by a computable enumeration of presentations of
the same `card`. The existential and the enumeration meet without any extraction ever happening.

**This is not a refutation and it is not a hedge — it is a positive result, and I compiled it.**
`evidence/decidability-assembly-family-probe.lean` and
`evidence/decidability-assembly-probe.lean` both elaborate sorry-free at
`[propext, Classical.choice, Quot.sound]` (`#print axioms`, no `sorryAx`).

### 3.4 One `Classical.choice` cost that *is* proved unavoidable, and is already paid

`TaskFrame.spherical_of_finite`'s docstring records a proved obstruction: weak excluded middle
(`¬¬P ∨ ¬P`) is derivable from `Spherical R` at the finite carrier `Bool` over `D = ℤ`, from
`[propext, Quot.sound]` alone (`wlem_of_spherical`, in
`Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`). So **no** finite-carrier frame with an
arbitrarily shaped relation can be choice-free, on any route. This is already paid by
`IntPresentation.toTaskFrame` and is not a new cost; it does mean **no plan should promise a
choice-free decidability result**, and any task spec that does is promising something proved
impossible.

---

## 4. What is landed by this task, machine-checked

Two probe files, both compiled with `lake env lean`, both sorry-free, both under
`specs/469_…/evidence/`. Neither touches the live tree (a research dispatch should not), but both
are drop-in.

### 4.1 The soundness half — **landed, 5 lines, first attempt**

`evidence/soundness-half-probe.lean`:

```lean
theorem not_validDiscrete_of_satAtState
    (P : IntPresentation) (w : Fin P.card) (φ : Formula)
    (h : SatAtState P w φ.neg) : ¬ ValidDiscrete φ := by
  obtain ⟨τ, hτ, t, -, htr⟩ := h
  intro hv
  exact htr (hv ℤ P.toTaskFrame P.toModel τ hτ t)
```

Measured `[propext, Classical.choice, Quot.sound]`. **ℤ instantiates the entire `ValidDiscrete`
binder bundle with no instance work whatsoever** — no `Archimedean`, no least-positive witness, no
Gap-1 lemma. This is the "cheap half" the task permits landing, and it is cheaper than anyone
priced it.

### 4.2 The assembly — **landed, ~25 lines**

`evidence/decidability-assembly-family-probe.lean`:

```lean
theorem validDiscrete_iff_checkFamily
    (cands : Formula → List IntPresentation)
    (fmp : ∀ ψ, ¬ ValidDiscrete ψ → ∃ P ∈ cands ψ, ∃ w : Fin P.card, SatAtState P w ψ.neg)
    (φ : Formula) :
    (∀ P ∈ cands φ, ∀ w : Fin P.card, check P w φ.neg = false) ↔ ValidDiscrete φ
```

with `decidableValidDiscreteFamily` reading it off through `decidable_of_iff`. Decidability of the
outer quantifier is `List.decidableBAll`, of the inner `Fintype.decidableForallFintype`, of the body
`decEq` — all compute. `evidence/decidability-assembly-probe.lean` is the single-presentation
variant.

**What these two files establish, jointly**: the *entire* remaining obligation for decidability of
`ValidDiscrete` is the one hypothesis named `fmp`. No bridge theorem. No transfer lemma. No
enumeration over the infinite `Atom` type. No `Fin n`-from-`Finite`. `check_correct` is the final
step, exactly as §7 hoped.

---

## 5. The residue, named precisely — and why it is hard

The residue is:

> **`fmp`**: `¬ ValidDiscrete φ → ∃ P ∈ cands φ, ∃ w, SatAtState P w φ.neg`, with `cands φ` a
> computable, formula-indexed list of presentations.

It decomposes into three pieces, of sharply different cost.

### 5.1 Carrier transport (Gap 1) — **bounded, named, small-to-medium**

The successor-based analogue of `archimedean_of_lub`, plus frame-and-model transport along
`D ≃+o ℤ`. `IntNormalForm.lean` already names the exact route. Estimate: **days to two weeks**,
split roughly as one Mathlib-shaped lemma plus a transport that must move `TaskRel`, `TaskModel`,
`WorldHistory`, and `TruthAt` across an order-additive iso. The transport is mechanical but touches
every semantic definition, so it is not a one-sitting job.

### 5.2 The type presentation as data — **routine engineering, but not trivial**

`cands φ` should be built from the **closure-type space**: subsets of `subformulaClosure φ`
satisfying the local Hintikka conditions, with `step` given by `LocalCoherent`'s `untl`/`snce`
unfolding clauses (`Annotation.lean` already states them, and they relate `label t` to
`label (t ± 1)` only — i.e. they *are* an adjacency relation), and `val p X := decide (atom p ∈ X)`.
Every ingredient is `Finset`/`Bool` data with `DecidableEq`.

Two real obligations here, neither research-grade:

1. **`fwd`/`bwd` seriality of the type graph.** Not free: a Hintikka type may have no locally
   coherent successor, which forces an iterated pruning to a maximal serial subgraph. Standard,
   bounded, fiddly.
2. **Indexing.** `IntPresentation` demands `Fin card` specifically, so the type `Finset` must be
   listed and indexed. Mechanical.

Estimate: **two to four weeks.**

### 5.3 The box-faithful small-model theorem — **THE research core**

This is where the honesty is owed. The `box` clause of `TruthAt` is
`∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ` — universal over **all** total histories. Two
landed facts make this a *global* modality rather than a local one:

- `Truth.box_const` (`Semantics/Truth.lean`): box truth is independent of both the history and the
  time. Its own docstring: *"a model has one finite set of box facts, computed once."*
- `Extension.occurrence` (`cor:occurrence`): every state occurs at every time in some total history.

That collapse is exactly why `BoxOracleSound P bx` types `bx` as `Formula → Bool` — one `Bool` per
formula, per model. Good news; but it is also the obstruction:

> The box facts of the **source** model `M` and of the **target** presentation `P` are each global
> constants of their own model, and they need not agree. `P` admits every path of its graph. The
> subgraph of types realized in `M` still generates paths that `M` does not realize, and along such
> a path a `□χ` that is true in `M` can fail. When it fails, the type-map image is no longer a
> `LocalCoherent` annotation, and the transfer breaks.

Restricting `cands φ` to realized-type subgraphs does not by itself close this: the subshift
generated by the realized edges properly contains the realized paths. So the residue is a genuine
**box-faithful** small-model theorem — in effect, a bounded-model property for
*LTL(Until, Since) over bi-infinite paths of a graph, plus a universal path quantifier over the
whole structure*.

**Is it true?** Almost certainly yes: the shape is the classical automata-theoretic bounded-model
setting, and the analogous results (CTL\*-style satisfiability, LTL with a universal modality) are
decidable with finite/bounded model properties. **Is it in reach?** Not routinely. Neither Mathlib
nor this tree carries ω-automata, Büchi complementation, or any language-inclusion machinery, so a
Lean proof must be hand-rolled. The in-tree precedent for the *technique* is real and helps —
`BiLasso/GoodCycle.lean`'s good-cycle argument, `cycleBound`, and `exists_annot_of_truth` are
exactly the fulfilment machinery a hand-rolled proof would reuse — but they operate inside a
presentation, not across the model boundary.

**Literature check, and its honest outcome.** I searched for a decisive citation on the decidability
of products of S5 with LTL(U,S). What is firm from the search: products of **three or more** modal
logics are undecidable, with no logic between `K×K×K` and `S5×S5×S5` decidable (Kurucz; Gabbay,
Kurucz, Wolter, Zakharyaschev, *Many-Dimensional Modal Logics*, 2003), and `S5×S5×S5` lacks the
finite model property. What is **not** settled by the search: the two-dimensional case with
`Until`/`Since`, which is what this logic is closest to. TM is in any case **not** a full product —
its second dimension is the path space of a graph, not an arbitrary set of runs — so a product-logic
result would be evidence, not a decision. **Recommendation: acquire GKWZ 2003 and check its temporal
products chapter before committing to §5.3.** That is a days-long check that could move the estimate
by months in either direction, and it should be a gate, not an afterthought.

Estimate for §5.3: **months, and genuinely hard** — 468's R4 category ("a semantic FMP"), which R4
already schedules there. This report does not move it out of that category and explicitly declines
to.

---

## 6. Cost comparison against the tableau route

Same units as the 468 audit. **Neither figure below is restated as verified; each cites the check.**

| | Tableau route | BiLasso route |
|---|---|---|
| Recorded price | *"several person-years of formalization, containing at least three separate multi-month research problems"* — 468 report R7 | — |
| Provenance of that price | R7 is a **judgment**, not a measurement. It is corroborated by the C9 register in `Verified/Termination/MintBound.lean` — **24 do-not-re-attempt entries**, several refuted by machine-checked witnesses (`difficultyBounded_multiplicity_false`, `universeClosed_identify_retime_false`, `universeClosedAt_fresh_world_escapes`, `freshLabelHeadroom_not_universal`, `budgetedTotality_beta_zero_false`) | — |
| Landed mass | 21 files / 30,164 lines under `Verified/`; `Verified/Refutation/` has **zero files** (468 R4) | 19 files / 6,593 lines, sorry-free, unreachable |
| Open research problems | ≥3 (refutation induction, proof-extraction completeness, `gapPotential`), plus split-arm fuel adequacy which R4 flags as possibly unclosable without an engine change | **1** (§5.3) |
| Bounded engineering | Large and not itemized | §5.1 + §5.2 ≈ 3–6 weeks, itemized above |
| Assembly | Not yet stated | **Landed here**, compiled, sorry-free |
| Soundness direction | Not yet stated | **Landed here**, 5 lines |

**The comparison, stated plainly.** The BiLasso route reduces decidability of `ValidDiscrete` from
"several person-years across ≥3 research problems" to **"one research problem plus 3–6 weeks of
bounded engineering"**. That is a large reduction and it is the finding that justifies the fork
C-2 opened. It is **not** a reduction to routine work: §5.3 is a real multi-month research problem
and must not be hidden behind an engineering description.

Two caveats that must travel with the comparison:

1. **The two routes deliver different things.** The tableau route targets a *sound and complete
   proof-theoretic calculus*; the BiLasso route targets *decidability of semantic validity*. A
   decidability result does not give a tableau calculus, and vice versa. Choosing BiLasso does not
   retire the tableau tree's other purposes.
2. **R7's "several person-years" is a judgment.** It should not be quoted as a measurement in any
   downstream artifact. The C9 register is the measured part, and what it measures is 24 refuted or
   unavailable statements — evidence of difficulty, not a duration.

---

## 7. §4(e): the cost of wiring BiLasso into the live tree, and the C6 entries

`scripts/module-invariants-manifest.txt` states the wiring procedure itself, in the block comment
above the BiLasso lines:

> "Registering the layer means adding one import of the re-export to `Decidability.lean` **AND**
> deleting every line of this block in the same commit — C6 fails if a manifest entry names a module
> that has become reachable. Do not do one without the other."

**Cost**: one `import` line, plus a manifest edit, plus one `lake build` (the modules already
compile in isolation under C6, and their oleans exist). **Hours, not days.** Nothing else in the
tree references BiLasso symbols, so there is no fan-out.

**Should the 20 C6 entries be retired as part of it? Split the answer — the manifest already does.**

**Exactly 15 of the 20, and I verified which.** `grep '^import' BiLasso.lean` returns **14**
modules: `Basic`, `Unfold`, `Periodic`, `Annotation`, `TruthLemma`, `Decide`, `Enumerate`,
`Examples`, `SmallModel`, `Realized`, `GoodCycle`, `Extraction`, `BoxOracle`, `Check`. So:

- **Delete 15 lines**: those 14 plus the aggregator's own line
  (`FormalSystem.Metalogic.Decidability.BiLasso`), which becomes reachable from the new import.
- **Keep 4 lines**: `Extend`, `Successor`, `Orbit`, `Agreement`. Verified by importer search —
  `Agreement` has **no importer anywhere in the tree**, `Orbit` is imported only by `Agreement`, and
  `Extend`/`Successor` only by `Orbit`. That closed cluster stays outside the build graph, exactly
  as the manifest's own comment predicts ("the effective-periodic-extension work, which the
  re-export deliberately does not carry").
- **Keep the `PeriodicExtension` line** (the 20th). It is a separate block with its own rationale —
  deliberately unregistered in `FormalSystem/Semantics.lean` "while the bi-lasso decision layer
  above is in flight, so that no aggregator is edited by two concurrent lines of work at once".
  Retiring it is a second, independent edit.

**Recommendation on timing.** Wire it **now**, independently of §5.3. The layer is sorry-free, it
compiles, and while it is unreachable it is invisible to `lake build`, absent from `ROADMAP.md`
(measured: 0 mentions), and — as C-2 documents — was omitted from 468's own audit. Wiring costs
hours and removes the recurrence of exactly that failure. Do not gate it on the research half.

---

## 8. Follow-up task specs

§7 asks for a follow-up spec "if the answer is yes". The answer is yes for the *representation*
question and no for *routine overall*, so the honest response is **three tasks, sharply separated by
classification.** Do not merge them: merging is precisely how a research problem gets hidden behind
an engineering description.

### Task A — wire the BiLasso layer into the live tree

- **task_type**: `lean4` · **topic**: `decidability` · **effort**: `small`
- **classification**: **routine engineering**
- **file_scope**: `FormalSystem/Metalogic/Decidability.lean`,
  `FormalSystem/Metalogic/Decidability/BiLasso.lean`, `scripts/module-invariants-manifest.txt`
- **dependencies**: none
- **Description**: Add one import of `FormalSystem.Metalogic.Decidability.BiLasso` to
  `Decidability.lean`. Delete exactly **15** manifest lines — the 14 modules `BiLasso.lean` imports,
  plus the aggregator's own line. Do **not** delete the `Extend`/`Successor`/`Orbit`/`Agreement`
  lines (verified: that cluster stays unreachable) and do **not** touch the `PeriodicExtension`
  line. Land the two probe files from
  `specs/469_…/evidence/` as live theorems (`not_validDiscrete_of_satAtState`,
  `validDiscrete_iff_checkFamily`, `decidableValidDiscreteFamily`) — they are compiled and
  sorry-free. Acceptance: `scripts/check-module-invariants.sh` passes C1/C2/C3/C6 with no manifest
  entry naming a reachable module. Also add BiLasso to `specs/ROADMAP.md`, which currently mentions
  it zero times.

### Task B — carrier normalization: the successor-Archimedean transfer

- **task_type**: `lean4` · **topic**: `semantics` · **effort**: `medium`
- **classification**: **routine engineering with one genuine lemma** — the lemma is small and its
  route is already written down; the transport is mechanical but wide
- **file_scope**: `FormalSystem/Semantics/DurationClassification.lean`,
  `FormalSystem/Semantics/IntNormalForm.lean`, `FormalSystem/Semantics/Validity.lean`
- **dependencies**: none
- **Description**: Prove the successor-based analogue of `archimedean_of_lub`, supplying
  `Archimedean D` and an `IsLeast {y : D | 0 < y}` witness from
  `[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]`, so that
  `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` applies. Then transport
  `TaskFrame`, `TaskModel`, `WorldHistory`, and `TruthAt` along `D ≃+o ℤ`, yielding: `ValidDiscrete φ`
  iff `φ` holds in every ℤ-frame model. Follow `IntNormalForm.lean`'s stated route; do **not** reach
  for `orderIsoIntOfLinearSuccPredArch`, which is order-only and is the recorded wrong turn.
  Independently valuable — it is a prerequisite for anything reasoning about the discrete class.

### Task C — the box-faithful small-model theorem

- **task_type**: `lean4` · **topic**: `decidability` · **effort**: `large`
- **classification**: **OPEN MATHEMATICS.** Multi-month. 468 R4 category. **This task may not be
  re-described as engineering, and may not be merged into A or B.**
- **file_scope**: a new `FormalSystem/Metalogic/Decidability/TypeModel/` directory;
  `FormalSystem/Metalogic/Decidability/IntPresentation.lean` (read-only)
- **dependencies**: Task B; and a **literature gate** (below)
- **Description**: Construct `cands : Formula → List IntPresentation` from the closure-type space
  (§5.2) and prove
  `¬ ValidDiscrete φ → ∃ P ∈ cands φ, ∃ w, SatAtState P w φ.neg`. The crux is box-faithfulness
  (§5.3): the source model's global box facts and the target presentation's must agree, and the
  realized-subgraph restriction does not by itself deliver that. Reuse `BiLasso/GoodCycle.lean`'s
  fulfilment machinery and `cycleBound`. Do **not** promise a choice-free result: `wlem_of_spherical`
  proves that impossible for any finite-carrier frame with an arbitrarily shaped relation.
  **Literature gate, to run first and to be allowed to stop the task**: acquire Gabbay, Kurucz,
  Wolter, Zakharyaschev, *Many-Dimensional Modal Logics* (2003) and read its temporal-products
  chapter. If the two-dimensional `Until`/`Since` case is recorded as undecidable or FMP-free, this
  task is **refuted** and must be reported as such rather than attempted — a negative result here is
  as valuable as a positive one and would redirect the whole front.
- **Do not begin C before A and B are landed.** A and B have standalone value; C does not, and its
  cost is dominated by a problem that a two-day literature check might refute.

---

## 9. Corrections this report makes to its own inputs

Recorded explicitly so they are not re-derived later.

1. **Task §2(a)** ("the carrier half is not open work"): wrong, and §7 already retracts it. Confirmed
   wrong by symbol inspection.
2. **Review Addendum 2**, "`filteredCharacteristicSet_injective` embeds `FilteredWorld` into
   `Finset (subformulaClosure phi)`": **it lands in `Set`, not `Finset`**, and the surrounding
   finiteness instances are `noncomputable`. The existing filtration world-space is *not* already
   data-shaped.
3. **Review Addendum 2**, "re-discharging all four `def:frame` axioms … is the multi-month piece and
   is unavoidable on ANY route": **false over ℤ.** `TaskFrame.ofStep` gives all seven fields for one
   bi-seriality obligation. The figure applies only to `D`-polymorphic frames. Sequencing Gap 1
   first makes it free.
4. **Task §0**, `instDecidableSatAtState` "recorded as carrying no `Classical.dec`": accurate as a
   *computability* claim; the measured axiom set is `[propext, Classical.choice, Quot.sound]`. Not a
   choice-free instance.
5. **Task §1's target shape** (`∃ P, P.card ≤ presentationBound φ ∧ …` plus "an enumeration of
   presentations up to that bound"): the bound-plus-enumeration framing is **not needed**, and is
   actively harmful — `IntPresentation.val : Atom → Fin card → Bool` is a function on an `Infinite`
   type (`Atom` is `structure Atom where base : String; freshIndex : Option Nat`, with an
   `Infinite Atom` instance), so presentations are not finite objects and cannot be enumerated at a
   cardinality bound without a valuation-restriction lemma that does not exist in the tree. A
   **formula-indexed candidate list** built from closure types sidesteps this entirely, because its
   `val` is read off the type. §4.2's compiled probe is stated in that shape.
6. **Task 468 finding F6** ("FMP is syntactic, not semantic"): **correct as applied to `FMP/`**,
   verified by reading `FMP.lean`'s termini and by `grep -c TruthAt` = 0 across all six files. C-2's
   charge that F6 is "too strong" holds only in that F6 did not mention `BiLasso/` — a different
   directory that also does not perform Gap 2 (§2.1).

---

## 10. Scope compliance

- Did **not** prove the bridge. Landed only the two halves the task explicitly permits as "cheap":
  the soundness direction and the assembly. Both compiled, both sorry-free, both confined to
  `specs/469_…/evidence/`.
- Did **not** edit the tableau tree, `PeriodicExtension.lean`, or any live file. No live-tree write
  of any kind occurred.
- Did **not** claim this work unblocks `countermodel_discrete`. Per Addendum 2's correction, task
  169's terminus is a Base-class countermodel over `ℚ ×ₗ ℤ` — a different frame class and a
  non-Archimedean carrier, reached by 421→422. This report serves the FMP result and the
  decidability front only.
- Recommended **no** `sorry` deferral, **no** new axiom, and **no** re-description of §5.3 as
  engineering.

**Sources consulted for §5.3's literature gate**:
[Many-Dimensional Modal Logics / products of modal logics (Cambridge, JSL)](https://www.cambridge.org/core/journals/journal-of-symbolic-logic/article/abs/on-modal-logics-between-k-k-k-and-s5-s5-s5/9E1BBEAD93798C3A29891A15D567B927) ·
[Bimodal logics with a 'weakly connected' component without the finite model property](https://arxiv.org/pdf/1502.05834) ·
[Minimal Temporal Epistemic Logic (NDJFL)](https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-37/issue-2/Minimal-Temporal-Epistemic-Logic/10.1305/ndjfl/1040046088.pdf)
