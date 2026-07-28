# Phase 10.1 Summary — The source-exact `K⁺`, its missing bridge, and the faithful dichotomy carrier

**Plan**: `plans/08_strong-completeness-dedekind-v8.md`, Phase 10.1
**Status**: `[COMPLETED]`
**Session**: `sess_1785243543_9dde88`
**Commits**: `1e1f15aec` (the module), `b8554cff1` (the two comment-only corrections)

---

## THE R11 VERDICT: **HELD**

The plan's central bet is settled by machine, in this dispatch, on the smallest site.

**`hasFaithfulDedekindINF_survives_interval_witness`** (`Kamp/KPlusFaithful.lean`) takes *exactly*
the hypotheses of `hasDedekindINF_fails_of_interval_witness` (`DedekindINFDense.lean:455`) — a
densely ordered flow, `P` true at `z₀`, `P` true throughout `(z₀,z₁)` — and concludes

```
kplusOpen M atomMap P z0  ∧  ¬HasDedekindINF M atomMap
```

Both conjuncts are sorry-free and axiom-clean. **The interval-witness refutation does not survive
the conjunct-free antecedent.** At the very configuration that refutes the tree's carrier, the
source-exact carrier's left disjunct *holds*, so there is no failure to refute.

The general fact is isolated as `kplusOpen_of_interval_witness`, which is stronger than the probe
required: **`TemporalTruth M atomMap z₀ P` is not used at all.** Density plus "`P` throughout
`(z₀,z₁)`" already gives `kplusOpen P z₀`. The endpoint hypothesis that drives the whole
guard/trichotomy apparatus is irrelevant to the source-exact statement.

Instantiated concretely at `denseWindow_kplusOpen_at_half` and packaged as
`denseWindow_probe_verdict`: at `denseWindowFlow`, `z₀ = 1/2`, `z₁ = 1` — the exact point where
`denseWindow_endpoint_disjunct_forced` (`DedekindINFDense.lean:595`) proves `P(z₀)` holds and
*both* of `HasDedekindINF`'s disjuncts fail — the structure satisfies `SemanticPriorU`,
`SemanticPriorS`, has `P(1/2)`, has `kplusOpen P (1/2)`, and refutes `HasDedekindINF`.

**In the plan's own terms**: *"the guard/trichotomy apparatus is a repair for the tree's `kplus`
and is not needed by a source-exact carrier."*

### Consequence for Phases 11 / 11.1 / 12 / 12.1 / 13

- **The chartered trichotomy fallback is NOT triggered.** Phases 12 and 12.1 do **not** need
  explicit endpoint branches at `NegFixOneFaithful.lean:422` / `NegFixListFaithful.lean:446`.
- Block D proceeds on the **primary** charter: re-base the eight faithful modules onto
  `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP` by hypothesis swap, in import-chain order.
- **What R11 did *not* settle, and what Phase 11 still must measure.** R11 as landed here proves
  the *carrier-level* claim: the faithful carrier is a genuine dichotomy on exactly the
  configuration that broke the two-disjunct form. It does **not** yet prove the *consumer-level*
  claim that `negChainOnFaithful_iff` (`Lemma53Faithful.lean:274`) keeps its two-arm shape under
  the swap. That measurement remains Phase 11's first deliverable exactly as chartered. The
  positive evidence carried forward is unchanged and now stronger: no faithful-family consumer
  destructures `kplus`'s `.1` (audit below), and the shim
  `HasDedekindINF.toHasFaithfulDedekindINF` keeps every existing supplier working.

---

## Task 0 — existence check (binding)

`grep`/`find` for `KPlusFaithful`, `kplusOpen`, `kminusOpen`, `HasFaithfulDedekind*` and any
Prop-level conjunct-free `K⁺`, repository-wide: **zero hits**. Nothing existed to consume; the
module was built.

## Task 1 — the `.1` audit (R12), re-run

Repository-wide, outside `Boneyard/`, every site that projects the first component of a `kplus` /
`kminus` hypothesis:

| Site | Form | Uses `.1`? |
|---|---|---|
| `DedekindINFDense.lean:467` | `exact h_left.1 h_at` | **yes** — inside the refutation machinery |
| `DedekindINFDense.lean:486` | `exact h_left.1 h_at` | **yes** — inside the refutation machinery |
| `DedekindINFDense.lean:609` | `exact h_kplus.1 h_half` | **yes** — inside the refutation machinery |
| `Lemma53Faithful.lean:143` | `obtain ⟨-, hdense⟩ := hk` | no — **discarded** |
| `Lemma53FaithfulPast.lean:261` | `obtain ⟨-, hdense⟩ := hk` | no — **discarded** |
| `Lemma53.lean:296` | `rintro ⟨-, h_dense⟩` | no — **discarded** |
| `Lemma53FaithfulPast.lean:339` | `rintro ⟨-, h_dense⟩` | no — **discarded** |
| `Lemma53.lean:175`, `Lemma53FaithfulPast.lean:142` | `rintro ⟨hnP, h_dense⟩` | yes — but these are the `kplus`-shape *characterisation* lemmas in the frozen discrete files, not faithful-family consumers, and `kplus` is never edited |

**Result: the v8 survey is confirmed.** Exactly three `.1` projections, all inside
`DedekindINFDense.lean`'s own refutation apparatus — i.e. inside the machinery that exists
*because of* the conjunct. No faithful-family consumer projects it. R12 stays at "very low".

**Anchor drift recorded** (survey → actual): `orderedPointsExist_combine_kplus`'s destructure is at
`Lemma53Faithful.lean:143`, not `:137`. `Lemma53.lean:296` and `Lemma53FaithfulPast.lean:339`
confirmed exactly. Anchors re-located by name; no target edited.

---

## What landed

`FormalSystem/Metalogic/WeakCanonical/Kamp/KPlusFaithful.lean` — 710 lines, 33 declarations,
sorry-free, every declaration within `[propext, Classical.choice, Quot.sound]` (several within
`[propext]` alone).

**The source-exact `K⁺` at the `Prop` level**
- `kplusOpen`, `kminusOpen` — `∀ s > t, ∃ r ∈ (t,s), P(r)` and its past mirror.

**The missing bridge** (the phase's second deliverable, independently valuable)
- `kPlus_formula_correct : TemporalTruth M atomMap t (Formula.kPlus P) ↔ kplusOpen M atomMap P t`
- `kMinus_formula_correct` — the mirror.

`Formula.kPlus` / `Formula.kMinus` have stood in the tree since they were written, with a
name-collision warning and **no lemma relating either to a truth condition**. `Axiom.prior_U_gap`,
`Axiom.prior_S_gap` and `Axiom.sep` are all stated with them; nothing in the tree could previously
read those axioms semantically. It can now.

**The relating lemmas**
- `kplus_iff_not_and_kplusOpen`, `kminus_iff_not_and_kminusOpen` — `Iff.rfl`; the difference is
  exactly one conjunct.
- `kplusOpen_of_kplus`, `kminusOpen_of_kminus`.
- `truth_or_kplus_of_kplusOpen : kplusOpen P t → P(t) ∨ kplus P t` (and the `kminus` mirror).
- `kplusOpen_not_implied_by_truth_at` — the machine-checked failure of the converse, at
  `denseClosedRayFlow` (the real line with the predicate true exactly on `(-∞,0]`) at `t = 0`.

**The faithful dichotomy carrier**
- `HasFaithfulDedekindINF`, `HasFaithfulDedekindSUP` — `HasDedekindINF.first_occ` /
  `HasDedekindSUP.last_occ` character-for-character except that the left disjunct is `kplusOpen` /
  `kminusOpen`. The right disjunct is left *literally* `HasDedekindINF`'s, `kplus` and all, so the
  two carriers' right disjuncts stay syntactically identical for the re-base.

**The derivation from the dense Prior hypotheses, with no guard**
- `prior_hasFaithfulDedekindINF_dense : SemanticPriorU M atomMap → HasFaithfulDedekindINF M atomMap`
- `prior_hasFaithfulDedekindSUP_dense` — the `SemanticPriorS` mirror.

Both follow the paper's Case 2 at the paper's own `K⁺`. The case split is on the **interval**,
never on `z₀`: the failure of `kplusOpen P z₀` *is* Prior-U's first antecedent `U(⊤,¬P)(z₀)`,
directly, with no `¬P(z₀)` needed — which is precisely where
`prior_hasGuardedDedekindINF_dense` (`DedekindINFDense.lean:326`) must consume its guard. The two
derivations are otherwise the same proof.

**The shim lattice**, one-way at each edge
- `HasDedekindINF.toHasFaithfulDedekindINF`, `HasDedekindSUP.toHasFaithfulDedekindSUP` — the
  weakening that keeps every current supplier, discrete pipeline included.
- `HasAttainedINF.toHasFaithfulDedekindINF`, `HasAttainedSUP.toHasFaithfulDedekindSUP`.
- `HasFaithfulDedekindINF.toHasDenseDedekindINF`, `...SUP.toHasDenseDedekindSUP` — the faithful
  carrier keeps Phase 10's trichotomy supplied.
- `HasFaithfulDedekindINF.toHasGuardedDedekindINF`, `...SUP.toHasGuardedDedekindSUP`.
- **The edge that does not exist**: `HasDenseDedekindINF → HasFaithfulDedekindINF` is recorded as
  unavailable, with its reason, grounded on `kplusOpen_not_implied_by_truth_at`. This is the
  precise sense in which the trichotomy's third disjunct is uninformative.

**The probe**
- `kplusOpen_of_interval_witness`, `kminusOpen_of_interval_witness`
- `hasFaithfulDedekindINF_survives_interval_witness`
- `denseWindow_kplusOpen_at_half`, `denseWindow_probe_verdict`

**Anti-vacuity**
- Positive: `hasFaithfulDedekindINF_of_dense_window`, `hasFaithfulDedekindSUP_of_dense_window`.
- Re-base corollary (v8's addition): `hasFaithfulDedekindINF_not_implies_hasDedekindINF` and its
  `SUP` mirror — `denseWindowFlow` satisfies both dense Prior hypotheses **and** the faithful
  carrier **and** refutes `HasDedekindINF`. The weakening is strict; it is not an equivalence in
  disguise.

**CI edge**: `WeakCanonical.lean` imports the new module, matching Phases 9 and 10's practice.

---

## The two comment-bytes-only corrections

**`PriorINF.lean`** — the `K⁺` section comment block and the `kplus` / `kminus` docstrings now
record that these are **not** the sources' operators, quote both source definitions verbatim, name
`Formula.kPlus` (`Syntax/Formula.lean:180`) as the tree's source-exact spelling and `kplusOpen` as
its Prop-level reading, and point at the collision warning at `Formula.lean:163-179`. The
unresolved doubt already in the file — *"Actually wait, the Rabinovich paper uses the notation
differently"* — is **resolved** rather than left standing: it was correct. The correct arithmetic
in the old block (`(⊤ U ¬P)(t)` is a *gap* condition, not `F(¬P)`) is retained.

**`DedekindINFDense.lean`** — the claim that Rabinovich's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is *false
read literally* is **withdrawn**, and replaced with the accurate statement: under his own
Definition (3) it is a definitional restatement, true verbatim; what carries the extra conjunct is
this tree's `kplus`. The honesty-charter Rule 4 label on the guard/trichotomy apparatus is
**completed** by recording what it is glue *for*, with the machine-checked pointer to
`hasFaithfulDedekindINF_survives_interval_witness`. The Rule 6 exclusion section now points at the
faithful carrier. Two further sentences repeating the same mis-attribution (in
`HasGuardedDedekindINF`'s docstring and the exclusion section) were corrected in the same narrow
pass; leaving them would have left the tree still asserting the withdrawn claim.

**Comment-only, verified by machine**: a nesting-aware comment stripper (handling nested `/- -/`
and `--`) was run over the HEAD version and the working-tree version of both files; with all
comments removed and whitespace normalised, both are **byte-identical**. `git diff -U0` shows
changes only inside comment blocks. Not a single statement or proof byte changed.

---

## Verification

| Gate | Result |
|---|---|
| Scoped build (`KPlusFaithful`) | green |
| **Full `lake build`** | **green, 1919 jobs, exit 0** — no scoped-aggregator fallback needed |
| `#print axioms`, all 33 new declarations | `[propext, Classical.choice, Quot.sound]` or a subset. No `sorryAx`, no new axioms |
| Sorry census outside `Boneyard/` | **exactly 1**: `Transfer.lean:1242`. Baseline unchanged |
| Vacuous definitions introduced | 0 (the one repo-wide hit, `Examples/TemporalStructures.lean:277`, is pre-existing and untouched) |
| New `axiom` declarations | 0 |
| Canary `completeness_dense` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| Canary `completeness_discrete` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| Canary `countermodel_discrete_reynolds_v2` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| `prior_hasDenseDedekindINF_dense` / `...SUP_dense` | unchanged after the comment edit |
| `hasDedekindINF_fails_of_interval_witness` | `[propext]` — unchanged after the comment edit |
| `consequence_completeness_dedekind_of_engine` | `[propext, Classical.choice, Quot.sound]`; `StrongCompleteness.lean` byte-identical |
| Frozen files byte-identical | `DedekindINF.lean`, `Lemma53.lean`, `Syntax/Formula.lean`, `Axioms.lean`, `StrongCompleteness.lean`, `PriorDefsDense.lean`, all eight `*Faithful*` modules, `ChronicleTypes.lean`, `ChronicleToCountermodelBasic.lean` — **all verified identical** |

---

## Literature verification (honesty charter Rule 2)

- **Rabinovich 2014, `K⁺` definition** — read verbatim at
  `~/Projects/Literature/sources/rabinovich_2014/chunk_0007.md`: the abbreviation clause
  (*"`K+(F)` … is an abbreviation for `¬((¬F)UntilTrue)`"*) and Definitions (2) and (3) are all
  present exactly as the plan quotes them. Cited by **PDF page only** (p.3), per the standing rule
  that this paper's `.md` conversion is not ground truth for displayed equations. The quoted
  material here is plain prose, which the rule explicitly admits.
- **Reynolds 1992, abbreviation table §1** — read verbatim at
  `~/Projects/Literature/sources/reynolds_1992/sec01_....md`: the table row is
  `$K^+ A$ | for $\neg U(\top, \neg A)$ | $A$ will be true arbitrarily soon`, with `$K^- A$` for
  `$\neg S(\top, \neg A)$`; the `U`/`S` truth clauses immediately above match the tree's
  `Formula.untl` / `Formula.snce` argument order. **Confirmed verbatim.**
- **Printed-page attribution, honest statement.** The corpus markdown carries **no per-page
  markers**; the only page datum in the file is the article's printed range, *Studia Logica* 51:
  **165–193**, 1992. So `printed p.168` could **not** be re-derived from the corpus at this
  revision. It is inherited from the tree's own prior verification recorded at
  `Syntax/Formula.lean:163-179` (which cites this table at printed p.168) and from the plan's
  Source-to-Implementation Mapping. The attribution is consistent with the article's range and with
  two independent prior attestations, but this dispatch did **not** re-verify it against the PDF
  itself. **Recorded as an outstanding Rule 2 item**, not silently passed.
- **Argument-convention note, new at this revision.** Rabinovich's `Until` takes its eventuality as
  the *second* argument, so his `(¬F) Until True` is Reynolds' `U(⊤,¬F)`. The two abbreviations
  denote the same operator under mirrored conventions, and `Formula.untl` follows Reynolds'. This
  is recorded in the new module's docstring and in the corrected `PriorINF.lean` block, because
  reading the two source strings side by side without it invites the opposite conclusion.

---

## Plan deviations

**One**, annotated inline in the plan at the corresponding checklist item.

*Task "Land the relating lemmas"* — the plan's third arrow,
`(TemporalTruth M atomMap t P ∨ kplus M atomMap P t) → kplusOpen M atomMap P t`, **is not a
theorem**: `P(t)` does not imply `kplusOpen P t`. The plan's own parenthetical on that same line —
*"a machine-checked witness that the converse fails (a point where `P` holds and `P` does not occur
arbitrarily soon after)"* — describes the counterexample to exactly that direction, so the intended
content is unambiguous, and it was landed in full:

- `truth_or_kplus_of_kplusOpen : kplusOpen P t → TemporalTruth t P ∨ kplus P t` — the true
  direction, and the one `HasFaithfulDedekindINF.toHasDenseDedekindINF` needs;
- `kplusOpen_not_implied_by_truth_at` — the machine-checked witness that the plan's stated
  direction fails, at `denseClosedRayFlow` and `t = 0`.

Nothing is weakened and nothing is skipped: one arrow is turned around and its failure is proved.
The lemma is not named in the phase's `Done when` list. Raised here and in the handoff rather than
absorbed silently.

**One new local definition beyond the plan's list**: `denseClosedRayFlow` (the real line with the
predicate true exactly on `(-∞,0]`), original scaffolding, needed because neither Phase 9 witness
(`denseRayFlow` = `(0,∞)`, `denseWindowFlow` = `(0,1)`) has a point where `P` holds without
accumulating above — both predicates are open sets. Labelled as original scaffolding in its
docstring.

---

## Observed anomaly outside this phase's territory (not acted on)

`plans/08_...v8.md` carries an **uncommitted** working-tree change, present before this dispatch
began and made by another actor, flipping Phase 11's heading from `[NOT STARTED]` to
`[IN PROGRESS]`. No Phase 11 work exists in the tree: `Lemma53Faithful.lean` and
`Lemma53FaithfulPast.lean` are byte-identical to HEAD. This marker appears spurious, and Phase 10.1's
own charter says Phase 11 must not be dispatched before the orchestrator has read this finding.
**Left untouched** — it is outside this phase's territory and reverting another actor's marker
unilaterally would be worse than reporting it. Flagged for the orchestrator.
