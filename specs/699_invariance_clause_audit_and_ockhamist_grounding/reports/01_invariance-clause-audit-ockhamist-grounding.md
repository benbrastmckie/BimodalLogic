# Research Report: Task #699

**Task**: 699 - invariance_clause_audit_and_ockhamist_grounding
**Started**: 2026-09-28T21:31:46Z
**Completed**: 2026-09-28T22:35:00Z
**Effort**: ~1 hour research; no implementation is proposed by this task (audit + grounding only)
**Dependencies**: None. Cites task 696's reports as given; does not re-derive or restate them.
**Sources/Inputs**: - Codebase: `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Predicates,Incompleteness,Decide,Agreement,Fulfil}.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/{Predicates,Decide,Skeleton,Stability}.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily/{Predicates,Decide}.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Types.lean`, `FormalSystem/Metalogic/Decidability/BiLasso/{Annotation,Decide,Realized,SmallModel}.lean`, `FormalSystem/Metalogic/Decidability/Verified/Bridge/{Interpolate,TruthLemma}.lean`, `FormalSystem/Metalogic/{BXCanonical/Frame,Core/MCSProperties,Conservativity/MinusChronicle,Decidability/FMP/Filtration,Expressiveness/*,Independence/LoopingDuration}.lean`, `FormalSystem/Semantics/{Truth,TruthTransport}.lean`, `FormalSystem/PlusLanguage/PlusTruth.lean`, both `Sharing/README.md` and `PlusWitnessFamily/README.md`
- Closing round (implementation) additions: `probes/02_remaining_verdicts_probe.lean` (row 6 and row 12 machine-checks), `audit/enumerate-shape-s.sh` and `audit/01_enumeration-snapshot.md` (re-runnable enumeration), `proposals/01_trans-reflexivity-residual-collapse.md` (follow-on payload and documentation handoffs)
- Task 696 reports `01_stability-modal-substrate-design.md` and `02_trans-redesign-gate-verification.md` (read in full; cited, not restated)
- One probe elaborated with `lake env lean` against the current oleans (archived under this task's `probes/`)
- Literature corpus `~/Projects/Literature/sources/`: `thomason_1984` (sec03, sec04, sec05), `thomason-1970-indeterminist-time`, `reynolds_2003_priors-ockhamist-logic-historical-necessity`, `reynolds_2001`, `emerson_and_halpern_-_1986_-_sometimes_and_not_never_revisited...`
**Artifacts**: - `specs/699_invariance_clause_audit_and_ockhamist_grounding/reports/01_invariance-clause-audit-ockhamist-grounding.md` (this report)
- `specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/01_clause_shape_collapse_probe.lean` (220 lines; elaborates clean, exit 0, all ten `#print axioms` lines show `[propext, Classical.choice, Quot.sound]` or "does not depend on any axioms" — no `sorryAx`)
- `specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/02_remaining_verdicts_probe.lean` (standalone; elaborates clean, exit 0, no warnings; all four `#print axioms` lines show `[propext, Classical.choice, Quot.sound]` — no `sorryAx`; machine-checks row 6's `Formula`-side `shareClauseAt` collapse and row 12's `PlusBoxFaithful` globality composition, both previously asserted rather than probed)
- `specs/699_invariance_clause_audit_and_ockhamist_grounding/proposals/01_trans-reflexivity-residual-collapse.md` (paste-ready `/task` payload for the `trans_reflexivity_residual_collapse` follow-on, plus the two documentation-ownership handoffs)
- `specs/699_invariance_clause_audit_and_ockhamist_grounding/audit/enumerate-shape-s.sh` and `audit/01_enumeration-snapshot.md` (re-runnable three-pass Shape-(S) enumeration and its dated output, replacing the inline Appendix commands below)
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal:logic

## Executive Summary

- **Soundness is not in question anywhere in this report.** `plusTruth_iff_mem` and
  `plusRefutes_of_certifies` are untouched and were not read for any purpose other than locating the
  box case. Every finding below is a *completeness-side* restriction on which families are
  well-formed. A family meeting the six conditions still presents a genuine ℤ-time countermodel.
- **The audit's mechanical core is now one abstract lemma, machine-checked.**
  `clause_shape_collapse` (probe, 3 lines): if `R` is reflexive and `∀ i j, R i j → (P i ↔ Ψ j)`
  with `P` not mentioning `j`, then `∀ i j, R i j → (P i ↔ P j)`. Every collapse verdict in Part A's
  table is an instantiation of it, so each verdict is checkable rather than asserted. `snce_share_congr`
  re-derives from it verbatim (`snce_share_congr'`).
- **Part A finds four live collapses in the landed tree, of which three are unrecorded.** The
  `snce` conjunct of (C1') is the known one. Its `untl` sibling collapses **in the same shape, not
  merely one step shifted**: `untl_share_succ_congr` proves `share (t+1) i j → (untl g e ∈ L i t ↔
  untl g e ∈ L j t)` — the exact mirror of `snce_share_congr`, distinct from task 696's
  `untl_shift_share_congr` and not recorded anywhere. Both conjuncts collapse identically on the
  `Formula` side (`SharingWitnessFamily.LocalCoherentShare`), which nothing in the tree or in task
  696's reports records. The two decision-procedure mirrors (`plusShareClauseAt`, `shareClauseAt`)
  inherit the collapse through the guards `rt i = rt k` / `rp i = rp j`, as they must.
- **Highest-value finding: task 696's recommended redesign does not repair the collapse — it
  relocates it.** Re-quantifying (C1')'s temporal conjuncts over the proposed `trans` datum leaves
  the derivation intact, because the proposed skeleton declares `trans_refl` as a field.
  `tUntl_trans_congr` and `tSnce_trans_congr` (probe, machine-checked against an external `trans`)
  prove `trans t i j → (untl g e ∈ L i t ↔ untl g e ∈ L j t)` and `trans (t-1) k i →
  (snce g e ∈ L i t ↔ snce g e ∈ L k t)`. Nothing relates `i` and `j` at time `t` semantically —
  arrival pruning relates them at `t + 1` — so this is a residual latent collapse, invisible to both
  gate families because both set `trans = eq`.
- **Reflexivity is the whole hypothesis, and it is not free.** `clause_shape_common_witness`
  (machine-checked, no axioms) shows that without reflexivity the clause entails only "two sources
  with a common successor agree", which task 696's own report already classifies as semantically
  forced and harmless. So `trans_refl` — adopted to keep `Thread.const` — is precisely what converts
  a harmless residual into the collapse the redesign exists to remove. The alternative is to replace
  `trans_refl` with the weaker field the proofs actually consume ("every position lies on some
  thread"), at a cost of about 25 term-level `Thread.const` call sites in 8 files.
- **(C3) `PlusBoxFaithful`'s globality is intended invariance, not a second over-strength.**
  It is of the audited shape (the quantified relation is the total relation on positions, trivially
  reflexive) and the derivation goes through — but the resulting invariance is semantically forced:
  `Semantics.Truth.box_const` proves a boxed formula's truth is independent of both history and time
  for *every* `TaskFrame`, from time-homogeneity via `TimeShift.timeShift_preserves_truth`, and the
  L⁺ ingredient `plusTruthAt_timeShift` is present for all seven constructors. The truth lemma's box
  case actively consumes the globality (`Agreement.lean` 205-218, via `Thread.const S j` shifted by
  `v - t`), so weakening it would break a landed proof rather than free a countermodel.
- **(C5) `StabFaithful` is intended invariance too, and for a checkable reason.** Its shape is
  different (`P i ↔ ∀ j, R i j → Q j`), its invariance needs symmetry and transitivity, and it is
  already recorded as `stabFaithful_share_congr`. `PlusTruth.stab_state_only` is *stronger* than
  (C5) — it identifies `⊡φ` across equal states at *different* times — but that strength is vacuous
  in presented models, because `shareSetoid` never identifies pairs at different times
  (`Skeleton.lean` 515-533). So (C5) at one time is exactly right, not an under- or over-statement.
- **Part B overturns the hypothesis it was asked to test.** The collapse is not a recognized
  consequence of the Peircean option, and the repair is not a move philosophical logic knows is
  forced. Every axiomatized tense-plus-modality frame class in the surveyed literature imposes some
  form of past/diagram completion on the alternativeness relation — Thomason 1984 Definition 6
  clause (2) for T × W frames ("historical alternatives differ only in what is future to `t`"),
  Definition 9 for Kamp frames, Definition 10 clause (5) for neutral frames₁ — and in all of them
  `Pp → □Pp` is valid. The project's ZTime task frames impose none of them, which is exactly what
  `not_plusValidZTime_stabSnce` machine-checks. (C1')'s `snce` conjunct is that completion condition
  smuggled back in, in its strongest (universal, biconditional) form. The literature therefore
  supplies the *diagnosis* and the shape of the correct condition (existential completion), but no
  importable result for the past direction, because the standard classes make the collapse harmless
  by assuming it.
- **`Liftable` does instantiate a named literature condition, precisely.** With `R := Step`, it is
  the "⊇" half of Emerson–Halpern's **R-generability**, and Emerson–Halpern 1986 §1 records the
  characterization "a set `X` of infinite paths is R-generable iff it is suffix closed, fusion
  closed, and limit closed" (attributed there to Emerson & Halpern 1985). This decomposes task 696's
  three closure lemmas exactly: shift-invariance of threads is suffix closure; its
  `liftable_of_spliceClosed` premise is fusion closure on the lasso bundle; its deferred
  `liftable_of_liftWindow` compactness step is limit closure. Reynolds 2003 §5 names the failure mode
  in the same words the certificate needs — "emergent" histories that "do not even have any labels
  constructed for them" and that "generally prevent the truth lemma from holding".
- **One published bound does constrain the design before it is built.** Reynolds 2003 solves limit
  closure only with an axiom schema that is "an infinite sequence of axioms: one for each `n > 0`",
  and Thomason 1984 §4 records that Kamp's own axiom system is *incomplete* for Kamp frames, the
  witness being Kamp's formula (17) whose validity flows from closure under diagram completion. Both
  say the same thing about `Liftable`: a closure condition of this kind is not capturable by finitely
  many local conditions, which independently corroborates task 696's F4 (every pointwise local
  surrogate tried was either a collapse or over-restrictive) and supports its choice of an
  `n`-indexed / compactness route over a pointwise one.
- **Follow-on task proposed** (Part A, one task): *Drop `trans_refl` from the substrate redesign and
  re-base the constant thread* — see "Follow-On Task Proposal" below. Nothing else Part A found is
  unrepaired by task 696's plan beyond what that task already owns.

## Context & Scope

Read in full: `PlusWitnessFamily/{Predicates,Incompleteness}.lean`; `Sharing/Predicates.lean`; the
`shareClauseAt` / `plusShareClauseAt` / `stabClauseAt` / `plusAtomClauseAt` / `atomClauseAt` blocks
of the two `Decide.lean` files; `Skeleton.lean` 140-375 and 515-560; `Semantics/Truth.lean` 220-250;
`Semantics/TruthTransport.lean` 275-325; `PlusLanguage/PlusTruth.lean` 70-115 and 250-340;
`PlusWitnessFamily/Agreement.lean` 200-245; task 696's two reports and its probe 01. Sampled for the
enumeration: every remaining `FormalSystem/Metalogic/**` definition whose body contains `↔` (64
candidates as re-run 2026-09-29 via `audit/enumerate-shape-s.sh`, corrected from an original count
of 67 that predates the re-runnable script; method below).

Constraints honoured. No Lean statement in the tree was modified; the only file written under
`FormalSystem/` is none. The probes live under this task's own `probes/` and are standalone files
elaborated against the existing oleans. Task 696's fourteen declared paths were read but not
touched, and its design is cited rather than restated or redesigned. `plusTruth_iff_mem` and
`plusRefutes_of_certifies` were not modified and are not in question.

### Enumeration method (so Part A is reproducible, not a sample)

The audited shape is stated precisely as:

> **Shape (S)**: a predicate definition containing a subterm `∀ x, R a x → (P ↔ Ψ(x))` in which `R`
> is reflexive at the relevant argument and `P` does not mention `x`.

Shape (S) is exactly what `clause_shape_collapse` consumes. Enumeration ran in two passes:

1. **All candidates**: every `def` / `abbrev` / `structure` in `FormalSystem/Metalogic/**/*.lean`
   whose body contains `↔` — 64 definitions across 39 files, per the re-runnable script's
   2026-09-29 run (`audit/enumerate-shape-s.sh`, snapshot `audit/01_enumeration-snapshot.md`;
   originally stated as 67 across 40, corrected — no tree drift, see the snapshot's Divergence
   analysis for the root cause).
2. **Filter to Shape (S)**: for each candidate, does a `↔` sit under a `∀` whose binder appears in a
   relational guard but *not* on the biconditional's left side? Independently, the reflexive
   relations of `FormalSystem/Metalogic/**` were enumerated by their `_refl` lemmas and `@[refl]`
   attributes (45 hits per the re-run, corrected from an originally stated 39 — the original
   command was missing the `-E` flag its alternation needs) and cross-checked against guard
   positions.

Both passes agree: inside `FormalSystem/Metalogic/`, the only relation guarding a Shape-(S)
biconditional is `share` (and its data-level presentation `rt i = rt j` / `rp i = rp j`), plus the
implicit total relation on label positions in (C3). This holds up under the re-run's corrected
scan too: the re-run additionally covers `FormalSystem/Metalogic/WeakCanonical/**` (omitted from
the original pass despite being in scope), and each of its six new candidates was individually
checked and is OUT OF SHAPE under one of the two reasons row 17 already gives — see
`audit/01_enumeration-snapshot.md` for the per-candidate derivation. The exclusions are itemized in the table's
"out of shape" rows, with the reason for each, so the enumeration can be audited rather than trusted.

## Findings

### PART A — The clause-shape audit

#### A0. The mechanical core

```lean
theorem clause_shape_collapse {ι : Type*} {R : ι → ι → Prop} (hrefl : ∀ i, R i i)
    {P Ψ : ι → Prop} (hclause : ∀ i j, R i j → (P i ↔ Ψ j)) :
    ∀ i j, R i j → (P i ↔ P j) :=
  fun i j hij => (hclause i j hij).trans (hclause j j (hrefl j)).symm
```

Read the clause once at `i` against an arbitrary related `j`, and once at `j` against itself. The two
right-hand sides are the *same* proposition, so the two left-hand sides are equivalent. `Ψ` is
arbitrary; reflexivity of `R` is the only property used; no symmetry, transitivity, closure
condition, size bound or decidability enters. This is the content of `snce_share_congr`'s two lines
with everything specific to time, to `snce` and to the certificate removed.

The reflexivity-free residual is what a repaired clause is *allowed* to entail:

```lean
theorem clause_shape_common_witness {ι : Type*} {R : ι → ι → Prop} {P Ψ : ι → Prop}
    (hclause : ∀ i j, R i j → (P i ↔ Ψ j)) :
    ∀ i i' j, R i j → R i' j → (P i ↔ P i') :=
  fun i i' j hij hi'j => (hclause i j hij).trans (hclause i' j hi'j).symm
```

Two sources with a common witness agree. Task 696's report 01 already classifies this residual as
semantically forced and harmless ("two positions with the same predecessor set agree on `snce`
labels; two positions with the same successor set agree on shifted `untl` unfoldings … record these
so the next reader knows the relocation is intended"). **`clause_shape_collapse` is
`clause_shape_common_witness` plus reflexivity, at `i' := j`.** That identity is the audit's single
most useful output: the difference between the harmless residual and the fatal collapse is exactly
one reflexivity hypothesis.

#### A1. The audit table

`refl?` = is the quantified relation reflexive at the argument the clause instantiates.
Verdicts: **COLLAPSE** = Shape (S) holds and the derived invariance is not semantically forced;
**INTENDED** = the derived invariance is semantically forced or is the congruence itself;
**OUT OF SHAPE** = Shape (S) fails, with the reason given.

| # | Predicate (conjunct) | Location | Relation quantified over | refl? | Verdict | Derivation / reason |
|---|---|---|---|---|---|---|
| 1 | `PlusLocalCoherentShare`, `snce` conjunct | `PlusWitnessFamily/Predicates.lean` 95-98 | `S.share t` | yes (`share_refl`) | **COLLAPSE** (landed, exploited) | `snce_share_congr` (`Incompleteness.lean` 129-136); re-derived as probe `snce_share_congr'` from `clause_shape_collapse (S.share_refl t)` |
| 2 | `PlusLocalCoherentShare`, `untl` conjunct | same, 91-94 | `S.share (t+1)` | yes | **COLLAPSE** (new, unrecorded) | probe `untl_share_succ_congr`: `clause_shape_collapse (S.share_refl (t+1)) (fun i j hij => (hloc i t).2.2.2.1 j hij g e hc)` gives `share (t+1) i j → (untl g e ∈ L i t ↔ untl g e ∈ L j t)`. See A2 for why this is *not* task 696's `untl_shift_share_congr` |
| 3 | `LocalCoherentShare`, `snce` conjunct | `Sharing/Predicates.lean` 158-161 | `S.share t` | yes | **COLLAPSE** (unrecorded anywhere) | probe `snce_share_congr_formula`; identical derivation at `Formula` |
| 4 | `LocalCoherentShare`, `untl` conjunct | same, 154-157 | `S.share (t+1)` | yes | **COLLAPSE** (unrecorded anywhere) | probe `untl_share_succ_congr_formula` |
| 5 | `plusShareClauseAt`, `snce` and `untl` arms | `PlusWitnessFamily/Decide.lean` 518-530 | `rt i = rt k` / `rp i = rp j` | yes (`rfl`) | **COLLAPSE** (decision mirror; must be, being equivalent to (C1')) | probe `plusShareClauseAt_snce_collapse`, `plusShareClauseAt_untl_collapse` |
| 6 | `shareClauseAt`, `snce` and `untl` arms | `Sharing/Decide.lean` 420-429 | same | yes | **COLLAPSE** (decision mirror) | probe `SharingWitnessFamily.shareClauseAt_snce_collapse`, `SharingWitnessFamily.shareClauseAt_untl_collapse` (probe 02) — the same two derivations at `Formula`, now separately probed rather than asserted |
| 7 | `PlusAtomCoherent` | `PlusWitnessFamily/Predicates.lean` 71-73 | `S.share u` | yes | INTENDED | Shape (S) fails: the biconditional's *left* side mentions the bound index. It **is** the congruence, and it is mandatory — the branching model's valuation is a `Quotient.lift` over `share`-classes and is not well defined without it |
| 8 | `AtomCoherent` | `Sharing/Predicates.lean` 136-138 | `S.share u` | yes | INTENDED | as row 7 |
| 9 | `plusAtomClauseAt` / `atomClauseAt` / `plusAtomCoherentData` / `atomCoherentData` | `PlusWitnessFamily/Decide.lean` 438-470; `Sharing/Decide.lean` 347-360 | `rt i = rt j` | yes | INTENDED | data mirrors of rows 7-8; same reason |
| 10 | `StabFaithful` | `PlusWitnessFamily/Predicates.lean` 276-279 | `S.share u`, on the biconditional's *right* side, not as a guard | yes, plus symm+trans | INTENDED | Shape (S) fails (`P i ↔ ∀ j, R i j → Q j` is a different shape, and its invariance needs an equivalence, not just reflexivity). The invariance is landed as `stabFaithful_share_congr` (289-304) and is semantically forced by `PlusTruth.stab_state_only`. See A4 for the one place this deserved a second look |
| 11 | `stabClauseAt` / `stabFaithfulData` | `PlusWitnessFamily/Decide.lean` 657-690 | `rt i = rt j` | yes | INTENDED | data mirror of row 10 |
| 12 | `PlusBoxFaithful` | `PlusWitnessFamily/Predicates.lean` 195-197 | the total relation on label positions `(i, t)` (implicit) | yes, trivially | INTENDED, **not** a second over-strength | probe `PlusSharingWitnessFamily.plusBox_globality` / `plusBox_share_congr` (probe 02) — A3's composition of (C1')'s `box` conjunct with `PlusBoxFaithful`, now written out as a theorem rather than prose; both hypotheses A3 named were needed. Shape (S) *does* hold and the derivation runs (A3). The invariance it yields is semantically forced by `Semantics.Truth.box_const`; the truth lemma's box case consumes it. Full argument in A3 |
| 13 | `BoxFaithful` / `boxClause` / `plusBoxClause` | `WitnessFamily/Predicates.lean` 106-108; `WitnessFamily/Decide.lean` 898-900; `PlusWitnessFamily/Decide.lean` 930-932 | same | yes | INTENDED | as row 12 |
| 14 | (C1')'s `box` conjunct | `PlusWitnessFamily/Predicates.lean` 89-90; `Sharing/Predicates.lean` 152-153 | none | — | INTENDED | the right side `S.bx χ = true` mentions no position at all, so invariance is immediate and is row 12's fact |
| 15 | `PlusThreadFulfilling` / `ThreadFulfilling` (C2') | `PlusWitnessFamily/Predicates.lean` 143-151; `Sharing/Predicates.lean` 206-214 | `S.Thread` (quantified), no biconditional | — | OUT OF SHAPE | the condition is an implication into an existential; there is no biconditional to read twice |
| 16 | `PlusLocalCoherentLab` / `PlusFulfillingLab` / `LocalCoherentLab` / `FulfillingLab` / `labClauseAt` / `clauseAt` / `LocalCoherentSeq` / `LocalCoherentSeqLab` / `LocalCoherent` / `CoherentEdge` | `PlusWitnessFamily/Predicates.lean` 166-185; `WitnessFamily/Predicates.lean` 72-104; `WitnessFamily/Decide.lean` 283-290; `Compression/Types.lean` 106-120; `BiLasso/{Annotation,Decide,Realized,SmallModel}.lean` | none | — | OUT OF SHAPE | the deterministic / per-lasso clauses carry no relational guard: the only "class-mate" of a position is the position itself, so `clause_shape_collapse` returns `P i ↔ P i`. This is why the one-position forms are the safe reductions (`plusLocalCoherentLab_of_share`) rather than a second copy of the defect |
| 17 | `BxModalEquiv`, `MCSFiltrationEquiv`, `SameRegion`, `InterpInvariant`, `InterpInvariantAt`, `RegionValued`, `AtomRegionInvariant.valuation_congr`, `IntEquiv`, `IsPurePast` / `IsPureFuture` / `IsPurePresent`, `StaviNEquiv`, `BracketCarrierCorrect` / `…V` / `…VPrior` / `…VPriorFaithful`, `Prop42Contentful`, `partialHolds`, `LoopingDuration`, `BoxOracleSound`, `derivationExchange`, `Stage.supp_spec` | `BXCanonical/Frame.lean` 77; `FMP/Filtration.lean` 68; `Verified/Bridge/{Interpolate,TruthLemma}.lean` 143/465/86/109/369; `Expressiveness/**`; `Independence/LoopingDuration.lean` 52; `BiLasso/Annotation.lean` 356; `Core/MCSProperties.lean` 71; `Conservativity/MinusChronicle.lean` 72 | various | various | INTENDED or OUT OF SHAPE | Two reasons, per definition: either the biconditional's **both** sides mention the quantified object, so the definition *is* the congruence/correctness statement it looks like (`BxModalEquiv`, `MCSFiltrationEquiv`, `SameRegion`, the three `InterpInvariant*`, `RegionValued`, `IntEquiv`, the purity predicates, `StaviNEquiv`, the `BracketCarrierCorrect*` family, `Prop42Contentful`, `partialHolds`); or there is **no relational guard on the quantifier at all** (`LoopingDuration`, `BoxOracleSound`, `derivationExchange`, `Stage.supp_spec`). In neither case does `clause_shape_collapse` apply |
| 18 | **Redesigned** `untl` conjunct over `trans t` | proposed (task 696 report 01 step 4; report 02 `TLocalCoherent`) | `trans t` | **yes**, by the proposed `trans_refl` field | **COLLAPSE — NOT REPAIRED** | probe `tUntl_trans_congr`: `trans t i j → (untl g e ∈ L i t ↔ untl g e ∈ L j t)`. See A5 |
| 19 | **Redesigned** `snce` conjunct over `trans (t-1)` | same | `trans (t-1)`, read backwards | **yes** | **COLLAPSE — NOT REPAIRED** | probe `tSnce_trans_congr`: `trans (t-1) k i → (snce g e ∈ L i t ↔ snce g e ∈ L k t)`. See A5 |

#### A2. Row 2 is a distinct finding from task 696's `untl`-side result

Task 696's probe 01 proves `untl_shift_share_congr`: reading the `untl` conjunct at `(i, t-1)`
against two class-mates at `t` forces the *one-step unfolding* `e ∨ (g ∧ g U e)` to agree across the
`share t` class. Row 2 is a different consequence of the same conjunct, obtained without any time
shift:

```
(C1') at (i, t), untl conjunct:   ∀ j, share (t+1) i j → (untl g e ∈ L i t ↔ Ψ(j, t+1))
(C1') at (j, t), untl conjunct, at j itself by share_refl (t+1) j:
                                  untl g e ∈ L j t ↔ Ψ(j, t+1)
chain:                            share (t+1) i j → (untl g e ∈ L i t ↔ untl g e ∈ L j t)
```

So the `untl` conjunct is an invariance axiom for the `untl` *label itself* — the exact mirror of
`snce_share_congr`, one time-index away — in addition to being one for the unfolding. Consequences
for the record:

- `PlusWitnessFamily/README.md` 100-102's "(C1')'s `untl` clause quantifies forward along a thread
  rather than over the `share`-class at the label's own time, so the same collapse does not arise
  there" is wrong twice over: the collapse arises, and it arises in the *same* shape, not only a
  shifted one. The same text is the module docstring of `Incompleteness.lean` ("**The `untl` side is
  defect-free by inspection, not by machine check**").
- `Sharing/README.md` 124's "The `untl` half is a genuine repair; the `snce` half collapses backward
  branching" is wrong in the same way, and additionally understates the scope: rows 3-4 show both
  halves collapse on the `Formula` side too, which neither README nor task 696 records.
- The rule of thumb both READMEs state ("any condition quantifying over the `share`-class at a
  label's *own* time forces class agreement", `PlusWitnessFamily/README.md` 106) should be replaced
  by Shape (S): *any* biconditional conjunct universally quantified over a reflexive relation is an
  invariance axiom for its left side across that relation, whatever time the relation is taken at.
  Task 696's report 01 reaches the same correction from its own finding and schedules it for its
  Phase 0; row 2 means the replacement text must also stop calling the `untl` side shifted-only.

#### A3. Row 12 — (C3)'s globality is forced, and the derivation is worth writing out anyway

Shape (S) applies with the quantified relation taken to be the total relation on label positions,
`R (i,t) (j,v) := True`, which is reflexive. (C1')'s `box` conjunct gives
`box χ ∈ L i t ↔ bx χ = true`, whose right side mentions no position; composing with (C3)
`bx χ = true ↔ ∀ i t, χ ∈ L i t` yields immediately

```
box χ ∈ L i t  ↔  bx χ = true  ↔  box χ ∈ L j v      for every (i,t) and (j,v)
```

— i.e. a boxed formula is labelled at every position or at none, across indices *and* times. So the
globality is real and it is of the audited shape. It is nonetheless **intended**, for three
independent reasons, each checkable:

1. `Semantics.Truth.box_const` (`Semantics/TruthTransport.lean` 311-318) proves
   `TruthAt M τ t φ.box ↔ TruthAt M σ s φ.box` for **every** `TaskFrame`, arbitrary histories and
   arbitrary times. History-independence is definitional (the `box` clause does not mention `τ`);
   time-independence is time-homogeneity, discharged by `TimeShift.timeShift_preserves_truth`, which
   `TruthTransport.lean` 250 records needs *no* shift-closure hypothesis. So no `TaskFrame` model
   has time-varying box facts, and (C3) cannot be over-strong relative to the semantics.
2. The L⁺ ingredient is present: `PlusLanguage/PlusTruth.lean` 264-327's `plusTruthAt_timeShift`
   covers all seven constructors including `stab`, so the `Formula`-side argument transfers to
   `PlusFormula` with no gap.
3. The presented model *realizes* the globality rather than merely tolerating it. The box case of
   `plusTruth_iff_mem` (`PlusWitnessFamily/Agreement.lean` 205-218) discharges its forward direction
   by building, for an arbitrary label position `(j, v)`, the history `S.hist (Thread.const S j) (v-t)`
   — the constant thread at `j` shifted so that its state at time `t` is `cls j v`. Every label
   position is thereby a history-state at every time, so (C3)'s quantifier over all `(i, t)` is
   exactly the range `□` has in the presented model. Weakening (C3) would break this landed proof,
   not free a countermodel.

This composition is now written out as a theorem rather than asserted in prose: probe 02's
`PlusSharingWitnessFamily.plusBox_globality` states the full three-way chain
`box χ ∈ L i t ↔ bx χ = true ↔ ∀ j v, χ ∈ L j v`, and `plusBox_share_congr` is the named row-12
congruence `box χ ∈ L i t ↔ box χ ∈ L j v`. Both elaborate clean, axiom-free of `sorryAx`, and
both hypotheses this section names — (C1')'s `box` conjunct and `PlusBoxFaithful` — were needed
and used; no additional hypothesis A3 did not name was required.

Verdict: intended invariance; not a second, independent over-strength; no action.

#### A4. Row 10 — where (C5) deserved a second look, and why it survives it

`PlusTruth.stab_state_only` (`PlusLanguage/PlusTruth.lean` 332-339) is strictly stronger than (C5):
if `τ.state t = σ.state s` at **possibly different** times `t` and `s`, then `⊡φ` agrees at `(τ,t)`
and `(σ,s)`. `⊡φ` is a function of the world state alone, not of the state-and-time pair. (C5) only
constrains one time at a time. That asymmetry is the shape a latent gap usually has, so it was
checked rather than assumed.

It is not a gap: the presented model's carrier is `Quotient shareSetoid` with
`shareSetoid.r p q := p.2 = q.2 ∧ share p.2 p.1 q.1` (`Skeleton.lean` 521-533), and the docstring at
515-520 records the design decision explicitly — "Pairs at different times are never identified,
which is what keeps `time` well defined on the quotient and the frame a flow." So in every presented
model no state recurs at two times, the antecedent of `stab_state_only`'s cross-time case is never
satisfiable, and (C5)'s single-time form is exactly as strong as the semantics requires. No action.

#### A5. Rows 18-19 — the redesign's residual collapse, and the one hypothesis it rests on

Task 696's recommendation re-quantifies (C1')'s two temporal conjuncts over a fourth periodic datum
`trans`, pruned by arrival renaming (`trans u i j → share (u+1) i j`), and declares
`trans_refl : ∀ r ∈ transBack ++ transMid ++ transFwd, ∀ i, r i i = true` as a field of the proposed
skeleton. Reflexivity is exactly and only what `clause_shape_collapse` needs, so the derivation
survives. Stated against an external `trans` parameter, in the same style as task 696's probe 03, so
that these are theorems about the redesigned conditions without the redesign being built:

```lean
theorem tUntl_trans_congr (hrefl : ∀ u i, trans u i i) (h : S.TUntlClause trans) … :
    ∀ i j, trans t i j → (untl g e ∈ S.L i t ↔ untl g e ∈ S.L j t)
theorem tSnce_trans_congr (hrefl : ∀ u i, trans u i i) (h : S.TSnceClause trans) … :
    ∀ i k, trans (t - 1) k i → (snce g e ∈ S.L i t ↔ snce g e ∈ S.L k t)
```

Both elaborate clean. The `snce` case needs the abstract lemma at the flipped relation
`R i k := trans (t-1) k i`, reflexive by the same field.

**Is the residual harmful?** It is not semantically forced. `trans t i j` says a history of type `i`
at `t` may continue as type `j` at `t + 1`. Nothing relates `i` and `j` at time `t`: arrival pruning
relates them at `t + 1`, and position `(j, t)` is not on the thread in question at all. So the
conjunct constrains a label row the thread never visits — the same category of spurious constraint
as the original defect, relocated from `share`-classes to `trans`-classes.

**Why the gate does not see it.** Both of task 696's gate families set every `trans` segment to
`[eq]` (report 01 Q3; report 02 F3-F4), so `trans t` is the diagonal and both theorems are vacuous
on them. Task 696's report 01 itself notes "both families have `trans = eq`, i.e. the minimal repair
for the two known targets is hop-free; hopping (design T's generality) is for targets whose
countermodels have infinitely many histories". The residual bites exactly on those hopping families
— the ones design T's generality exists to admit, and the ones the deferred exact-closure phase is
for. So the gate is green and the generality is still compromised.

**Whether it is fatal is open, and deliberately left open here.** Exhibiting a genuine ℤ-time
non-validity that the *redesigned* certificate still cannot refute would need a hopping countermodel
and a target that detects the `trans`-congruence; that is a new incompleteness theorem, outside this
task's mandate (probes demonstrating a collapse derivation, not new refutations). What is
established is that the derivation is live, not hypothetical.

**The repair, and its cost.** `clause_shape_common_witness` shows precisely what is left if
`trans_refl` goes: `trans t i j → trans t i' j → (untl g e ∈ L i t ↔ untl g e ∈ L i' t)`, the
common-successor congruence task 696's report 01 already classifies as semantically forced and
proposes to record as `untl_succ_congr` / `snce_pred_congr`. So dropping reflexivity removes the
collapse and leaves exactly the intended residual — no third thing appears.

What reflexivity was adopted for is `Thread.const` (adequacy criterion A5, "every position lies on a
thread"). But A5 as the proofs consume it is an *existential*: `succF_nonempty` / `predF_nonempty`,
`plusFulfillingLab_of_thread` / `fulfillingLab_of_thread`, and the box case of both truth lemmas each
need *some* thread through a given position, not the constant one. `Thread.const` is the cheapest
witness, not the required one. Replacing `trans_refl` with the field it is standing in for — "for
every `i` and `u` there is a thread with `idx u = i`" — costs about 25 term-level `Thread.const` call
sites across 8 files (`PlusWitnessFamily/{Agreement,Basic,Predicates}.lean`,
`Sharing/{Agreement,Predicates,Stability,Thread}.lean`), each of which becomes "obtain the thread
from the field". That is the follow-on task below.

Two consequences worth recording for whoever writes it:

- A reflexive *and* functional succession relation is forced to be the identity, so "succession is a
  function on history types" (the honest reading, where a type at `t` determines its type at `t+1`)
  is *incompatible* with `trans_refl` unless `trans = eq`. Dropping reflexivity is what makes the
  functional/permutation readings of `trans` available at all.
- `trans_refl` is also what makes `liftable_of_full` (the port of today's `total_eq_thread` proof)
  and the `Specialize.lean` diagonal trivial. Those need `trans ⊇ eq` on the *specific* families that
  use them, which a per-producer hypothesis supplies; they do not need it as a skeleton-wide field.

### PART B — The literature grounding

Four claims were put to the sources. Each verdict below names what was actually read.

#### B1. Is the collapse a recognized consequence of the moment-only (Peircean) option? — **No, and the framing is wrong.** The recognized condition it violates is past/diagram completion of the alternativeness relation.

The Ockhamist/Peircean distinction is about the *future* and about how `F` is read. Reynolds 2003 §1
(`chunk_0001.md`) states the shared setting of both options: "indeterminist time is usually modelled
by a tree with each point having one linear past but branching towards the future … The unique past
represents the necessity of history: it cannot be changed and there are no choices in that
direction." Under a unique past, `Pp → □Pp` is *valid*, and the certificate's `snce`-side collapse is
harmless. So the past-directed instance of the defect cannot be a result about treelike branching
time: in treelike frames it does not arise.

Thomason 1984 §3 supplies the general diagnosis that *does* transfer, and states it in the sharpest
available form (`sec04_3-historical-necessity.md`, following Definition 2):

> "To make sense of `φ` being true at `t` no matter what the future is like, we will have to think of
> formulas being satisfied not just at moments `t`, but at pairs `⟨t,b⟩` … Once satisfaction is made
> relative to pairs `(t,b)` for some formulas, it must be relativized in the same way for all
> formulas; otherwise the recursive definition of satisfaction will become snarled."

That is the certificate's defect at the level of principle, written in 1984: `⊡`'s clause quantifies
over the histories through a state, so satisfaction must be relativized to (moment, history) pairs
for *every* operator — and (C1') instead evaluates the two tense conjuncts against the moment (the
`share`-class). `snce_share_congr` is the snarl. The same section states the consequence the
certificate is forced into: "it seems that the Ockhamist theory gives no account of truth relative to
a moment `t`, and it also suggests very strongly that if `φ` is true at `t` then `□φ` is also true at
`t`. The only way that a thing can be true at a moment is for it to be settled at that moment."

The *specific* condition the project's frames violate is named in the surveyed frame classes, and
every one of them imposes it:

| Frame class | Source | The condition | `Pp → □Pp`? |
|---|---|---|---|
| Treelike (Ockhamist) | Thomason 1984 Def 1-2; Reynolds 2003 §1 | one linear past per moment | valid |
| T × W | Thomason 1984 §4 Def 6 clause (2): "if `w₁ ~_t w₂` and `t' < t` then `w₁ ~_{t'} w₂`. The intention is that `w ~_t w'` if `w` and `w'` are historical alternatives through `t`, and so **differ only in what is future to `t`**" — with Def 7 adding that atoms agree across `~_t` at every `t₁ ≤ t` | alternativeness is backward-closed | valid |
| Kamp frames | Thomason 1984 §4 Def 9: "if `w ≈_t w'` and `t' <_w t` then `w ≈_{t'} w'`" | backward-closed, with per-world orderings | valid |
| Neutral frames₁ | Thomason 1984 §4 Def 10 clause (5): "if `a ≈ a'` and `b <_w a` then there is some `b' ∈ 𝒰_{w'}` such that `b ≈ b'` and `b' <_{w'} a'`" — the **diagram-completion** property (Fig. 2, "one-way completion") | existential backward completion | valid (completion transfers the witness; atoms noncontingent across `≈` by (AK13)) |

The project's frames impose none of these. `⊡φ` at `(τ,t)` quantifies over every `σ` with
`τ.state t = σ.state t`, with no requirement that `σ` agree with `τ *before* `t`, and
`not_plusValidZTime_stabSnce` machine-checks that `Pp → ⊡Pp` fails on the permissive ℤ-frame `NF`
with exactly two such histories. So:

- **The project's stability modal is a two-sided historical-alternative modality**: `~_t` is "same
  state at `t`", an equivalence for each `t`, closed in *neither* direction. That is outside every
  frame class Thomason's survey axiomatizes, and the reason is not oversight — Def 6's own gloss says
  the intention is that alternatives "differ only in what is future to `t`".
- **(C1')'s `snce` conjunct is a completion condition smuggled back in**, in the strongest available
  form. Where neutral frames₁ demand an *existential* completion (`∃ b' ≈ b` below `a'`), (C1')
  demands a *universal biconditional* over the whole class. Thomason's remark on Def 10(5) is the
  contrast in one line: "It's important to realize that nothing prevents `a ≠ b` while at the same
  time `a' = b'`." The correct condition identifies nothing; the certificate's identifies labels.
- **The repair is therefore not a move philosophical logic knows is forced.** Philosophical logic
  takes the *other* branch: it assumes some completion and keeps `Pp → □Pp`. The project has chosen a
  frame class the literature does not axiomatize, so there is no importable completeness result for
  the past direction; what is importable is the *shape* of the fix (existential completion, pair
  relativization) and the warning that the surveyed classes' results are all proved under a
  condition the project drops.

Recorded caveat on sources. `thomason-1970-indeterminist-time` was located in the corpus (79 chunks)
and read: it is the right paper (Theoria, p. 265 ff., "Indeterminist Time and Truth-Value Gaps"), and
its opening establishes the nonlinear-time setting and the van Fraassen truth-value-gap apparatus.
But the conversion is a two-column OCR whose columns are interleaved line-by-line, so no passage is
quotable verbatim and the global index already flags it `no_source_pdf` (conversion not verified
against a PDF). **The 1970 content is therefore cited only through Thomason 1984 §3 Definition 5**,
which restates it ("In Thomason [1970], it is suggested that such an absolute notion of truth can be
introduced by superposing Van Fraassen's treatment of truth-value gaps onto Prior's Ockhamist
theory") and has a clean conversion. Any claim resting on the 1970 text alone is marked unverified
below.

One claim is marked **unverified**: that Thomason 1970's supervaluational definition validates the
*object-language implication* `φ → □φ` rather than only the rule "if `‖φ‖ᵗ = 1` then `‖□φ‖ᵗ = 1`".
Thomason 1984 Def 5 and the paragraph after it assert only the rule, and explicitly add that the
supervaluation "preserves the validities of linear tense logic; indeed, `φ` is Ockhamist valid if and
only if it is valid here" — which suggests the implication is *not* validated. If so, the certificate
is one step worse than Thomason's own moment-only option: it collapses the implication, not merely
the rule. Settling this needs the 1970 text and is not settled here.

#### B2. Is `Liftable` a known history-closure / bundled-branch condition? — **Yes, exactly: it is the "⊇" half of R-generability, equivalently suffix + fusion + limit closure.**

Task 696's `Liftable` reads: every `Step`-path of the frame is traced by a thread (up to `share`).
Emerson–Halpern 1986 §1 defines (`chunk_0014.md`, `chunk_0015.md`):

> "We say that a set `X` of paths is **R-generable** iff there exists a total, binary relation `R` on
> `S` such that `X` consists precisely of the infinite sequences `(s₀, s₁, s₂, …)` of states from `X`
> for which `(sᵢ, sᵢ₊₁) ∈ R`."
> … "As shown in [5], a set `X` of infinite paths is R-generable iff it is **suffix closed, fusion
> closed, and limit closed**."

with `X` **suffix closed** if `x ∈ X → x_succ ∈ X`; **fusion closed** if `x₁·s·y₁, x₂·s·y₂ ∈ X →
x₁·s·y₂ ∈ X`; **limit closed** if whenever `x₁y₁, x₁x₂y₂, x₁x₂x₃y₃, … ∈ X` then the limit
`x₁x₂x₃…` ∈ X.

Take `R := Step` and `X :=` the thread traces. `thread_is_history` is the "⊆" half; `Liftable` is
exactly the "⊇" half; together they say the thread set is `Step`-generable. The characterization then
decomposes task 696's three closure lemmas one-to-one:

| Emerson–Halpern condition | Certificate-side counterpart |
|---|---|
| suffix closure | free: threads are ℤ-indexed and the substrate is shift-invariant (`share_sub_back_length`, `share_add_fwd_length`); a shifted thread is a thread |
| fusion closure | task 696's `liftable_of_spliceClosed` premise, `∀ u i j, share u i j → ∃ k, (∀ v < u, share v k i) ∧ (∀ v ≥ u, share v k j)` — literally "the splice of `i`'s past with `j`'s future at `u` is in the bundle" |
| limit closure | task 696's deferred `liftable_of_liftWindow`, the compactness step on `ℤ → Fin n`; also why its pigeonhole route (`Finite.exists_infinite_fiber`) suffices when the bundle is finite — limit closure is free on a finite path set |

The failure mode has a name in the same literature. Reynolds 2003 §5 (`chunk_0013.md`), explaining
why the bundled system is incomplete for the complete-structure semantics:

> "In the limit of the step by step construction of a perfect Kamp frame chronicle we only construct a
> countable number of vertical lines (or columns) which correspond to histories … However, the
> resulting tree generally also has an uncountable number of other histories which do not correspond
> to columns. These may be called **'emergent' histories** and it is they which generally prevent the
> truth lemma from holding: they do not even have any labels constructed for them."

In certificate terms: the lassos are the columns, an emergent history is a `Step`-path no thread
traces, and "they do not even have any labels constructed for them" is precisely why the `box` and
`stab` cases of `plusTruth_iff_mem` need `total_eq_thread` and hence `Liftable`. The bundled/complete
distinction is also stated directly (`chunk_0012.md`): "The difference in validity between bundled and
complete versions of branching logics is connected with what is sometimes called the limit closure
property of the complete structures."

So `Liftable` is not a formalization-native invention; it is the limit-closure/R-generability
condition of the bundled-versus-complete literature, instantiated to a ℤ-indexed, finitely presented
path set. Task 696's report 01 already gestures at Emerson–Halpern for the vocabulary; what this
report adds is the *characterization theorem*, which turns its three sufficient lemmas from a list of
tactics into a complete decomposition of the condition, and tells the planner that nothing is
missing from the list.

#### B3. Does any known result bound what a finite periodic certificate over moment-history pairs can decide? — **Yes: two, and they both say a closure condition of this kind is not finitely local. A third is a positive decidability result that de-risks the programme.**

1. **Limit closure needs an infinite schema.** Reynolds 2003 §5 (`chunk_0013.md`): "We solve the limit
   closure problem by the addition of what we call a limit closure schema. It is an **infinite
   sequence of axioms: one for each `n > 0`**", with `LC` as displayed there and Lemma 3 proving
   soundness by transfinite induction. Reynolds 2001 §6 (`sec03_…md` 192-194, 348) adds the limit
   closure axiom schema *and* an auxiliary atoms rule to the bundled system `⊢_B` for full CTL*. The
   bearing on task 696's design: its empirical finding (report 01, F4) that every *pointwise local*
   surrogate for `Liftable` is either a collapse or over-restrictive is not an artifact of the search
   — the published solution is an `n`-indexed family too, and the index `n` plays the role of task
   696's "every finite segment lifts" segment length. This is direct corroboration for its
   compactness route and against any further attempt at a single local condition.
2. **Diagram completion defeats the natural axiom set, in the two-sided case specifically.**
   Thomason 1984 §4 records that Kamp's own system (AK0)-(AK13) + (RK0)-(RK3) is **incomplete** for
   Kamp frames, the witness being Kamp's formula (17), and that "the validity of (17) in Kamp frames
   follows from the fact that these frames are closed under the sort of diagram completion given in
   Figure 1". It then records a completeness result for the strictly weaker neutral frames₁ (Def 10,
   i.e. one-way completion only; Thomason [1981c]), that (17) is invalid there, and that stronger
   diagram-completion conditions yield further frame classes and further completeness results — "but
   this effort did not produce an axiomatization of Kamp validity". Gabbay's irreflexivity method
   eventually obtains all Kamp validities by adding (AG1) and a rule (RG1) quantifying over
   "formulas which record a finite number of steps forwards, backwards, and **sideways**". Again an
   `n`-indexed family; again no finite local condition.
3. **The positive result, which bounds the *risk* rather than the design.** Thomason 1984 §4:
   "Gurevich and Shelah have proved a result implying that Ockhamist validity is decidable … The main
   result is that the theory of trees with second-order quantification over maximal chains is
   decidable"; and Burgess 1980 proves the Peircean validities decidable. So the decidability of the
   target logic is not what the certificate is needed for, and a failure of *this* certificate class
   is not evidence of undecidability — which is exactly what `Incompleteness.lean`'s own docstring
   already says about `⊡` ("Stability-modal decidability is not refuted"), now with named external
   support. The countervailing warning is also on the record: Thomason 1984 §4 cites Burgess 1979
   p. 577 for "an Ockhamist invalid formula valid in countable treelike frames", i.e. a restricted
   class of presentations can validate a non-validity — structurally the same failure the certificate
   exhibits.

**Net Part B verdict.** The general lesson — relativize satisfaction to moment-history pairs for all
operators, or the recursion snarls — is a known result (Thomason 1984 §3) and the certificate's defect
is a clean instance of ignoring it. `Liftable` is a known condition with a known characterization
(Emerson–Halpern 1986 §1) and a known hardness (Reynolds 2001/2003, Thomason 1984 §4 on Kamp's
system). But the specific claim the task set out to test — that the defect and its repair instantiate
a known result about tense in branching time, past-directed — is **false as stated**: the surveyed
classes all impose the completion condition the project drops, so in all of them `Pp → □Pp` is valid
and the collapse is harmless. The project's two-sided alternativeness relation is outside the
axiomatized families, and the past-directed instance is formalization-native.

## Decisions

- Shape (S) is adopted as the audit's filter, stated before enumeration, and `clause_shape_collapse`
  is its executable form. Verdicts are instantiations, not judgements.
- (C3) and (C5) are recorded as **intended invariance** on evidence (`Truth.box_const` +
  `plusTruthAt_timeShift` + the truth lemma's box case; `stab_state_only` + `shareSetoid`'s
  time-stamping), not on the strength of their docstrings.
- The `untl`-side label congruence (row 2) is reported as a finding distinct from task 696's shifted
  version, because the two READMEs' correction text differs depending on which is true.
- The residual `trans` collapse is reported as live and unrepaired, but **not** promoted to a new
  incompleteness theorem: constructing the hopping countermodel and detecting target is new work and
  is scoped as the follow-on task's optional second phase, not asserted here.
- Thomason 1970 is cited only through Thomason 1984 §3, with the OCR defect recorded and one
  dependent claim marked unverified, rather than quoted from an unusable conversion.
- No Lean statement was modified and no substrate design was proposed; task 696 keeps ownership of
  the redesign. The one design input this report offers (drop `trans_refl`) is filed as a task
  proposal against that design, not as an edit to it.
- **Closing-round consistency pass (2026-09-29).** Every row of Part A's table was walked: each
  **COLLAPSE** cell now names a probe declaration (rows 6 and 12 were the only asserted-not-probed
  cells; both are now probe 02) and each **INTENDED** cell names its specific semantic evidence.
  Part B was walked and every claim either names a source `doc_id` plus chunk/section or is marked
  unverified. The Executive Summary's soundness paragraph and its "four live collapses" count both
  survived this pass unaltered — the documentation defect this pass additionally filed
  (`Incompleteness.lean`'s docstring, see the Follow-On Task Proposal section) is recorded as a
  documentation defect, not counted as a fifth collapse.

## Risks & Mitigations

- **Risk**: the residual `trans` collapse might be harmless in practice if every family task 696's
  programme actually needs has `trans = eq`. **Mitigation**: that is precisely the hypothesis the
  follow-on task's first step tests, and it is cheap — if `trans = eq` suffices for every target,
  design D (hop-free splice-closed lassos) is the cheaper design and `trans` is unnecessary
  generality, which is itself a decision task 696 should make on evidence.
- **Risk**: dropping `trans_refl` breaks ~25 `Thread.const` sites and could cascade into
  `Window.lean`'s `succF_nonempty` / `predF_nonempty` and the fixpoint layer. **Mitigation**: each
  site consumes only "some thread through this position"; the replacement field supplies exactly
  that, and the follow-on task is scoped to do the substitution mechanically and prove the
  substitution lemma once.
- **Risk**: rows 3-4 (the `Formula`-side collapses) have no observable consequence, because `L` has
  no `⊡` with which to detect class disagreement, so they might be dismissed. **Mitigation**: they
  still restrict which `Formula`-side families are well-formed, and they are the conditions
  `Specialize.lean` reduces through. They are recorded as collapses without a claimed refutation, and
  the report says so explicitly rather than implying a `Formula`-side incompleteness.
- **Risk**: the Part B verdict contradicts the task's own framing, and a reader may take the
  Ockhamist/Peircean vocabulary from the task description as settled. **Mitigation**: the frame-class
  table names the exact clause in each source that makes `Pp → □Pp` valid, so the disagreement is
  checkable against four named definitions rather than a matter of emphasis.
- **Risk**: `thomason-1970-indeterminist-time`'s conversion is unusable and its re-conversion might
  change the unverified claim's status. **Mitigation**: the claim is marked unverified and nothing
  else in the report depends on it; re-conversion is noted as optional in the follow-on proposal's
  non-goals.

## Follow-On Task Proposal

One task, addressing the single Part A finding task 696's plan does not repair.

**Proposed title**: `trans_reflexivity_residual_collapse`
**Proposed type**: `formal:logic` (research first; the implementation belongs to whichever cycle
lands task 696's Phase 1)
**Blocks**: task 696 Phase 1 (the additive data layer, where `trans_refl` would be declared). Best
resolved *before* that phase, since removing a field afterwards is more expensive than not adding it.

**Statement of the defect.** Task 696's recommended substrate declares `trans_refl` as a field of
`SharingSkeleton`. With that field, the redesigned (C1') still entails
`trans t i j → (untl g e ∈ L i t ↔ untl g e ∈ L j t)` and
`trans (t-1) k i → (snce g e ∈ L i t ↔ snce g e ∈ L k t)`, both machine-checked in this task's probe
against an external `trans`. The invariance is not semantically forced: arrival pruning relates the
two indices at `t + 1`, not at `t`. Both of task 696's gate families set `trans = eq`, so neither
exhibits it and the gate passes.

**Scope.**

1. Decide whether `trans_refl` is required, by auditing the ~25 term-level `Thread.const` call sites
   (`PlusWitnessFamily/{Agreement,Basic,Predicates}.lean`,
   `Sharing/{Agreement,Predicates,Stability,Thread}.lean`) against the weaker existential field
   "for every `i` and `u` there is a thread with `idx u = i`". Expected answer: every site consumes
   only the existential.
2. If so, specify the replacement field and the one substitution lemma, and hand the specification to
   task 696's Phase 1 so the reflexivity field is never declared.
3. Record `untl_succ_congr` / `snce_pred_congr` (the common-successor / common-predecessor
   congruences, `clause_shape_common_witness`) as the *intended* residual, so the next reader knows
   the relocation is deliberate — task 696's report 01 already asks for this; this task supplies the
   reflexivity-free derivation that makes it exactly the residual and nothing more.
4. Optionally, and only if step 1 says reflexivity is genuinely required: construct a hopping
   countermodel and a target schema that the `trans`-congruence blocks, turning the residual into a
   named incompleteness theorem the way `not_plusCertifies_stabSnce` did for the original.

**Non-goals.** No substrate redesign (task 696 owns it). No change to `plusTruth_iff_mem` or
`plusRefutes_of_certifies`. No re-conversion of `thomason-1970-indeterminist-time` (optional, and only
if B1's unverified claim becomes load-bearing).

**Paste-ready payload.** The complete `/task "…"` invocation, with the evidence citations above
inlined and no unresolved placeholder, is filed at
`specs/699_invariance_clause_audit_and_ockhamist_grounding/proposals/01_trans-reflexivity-residual-collapse.md`.
Filing the task is a user `/task` action; no phase of this task's implementation round writes
`specs/state.json` or `specs/TODO.md`, or creates a task.

**Documentation defect found alongside this proposal (not a fifth collapse).** Part A's four live
collapses count in the Executive Summary is unchanged by this item — it is a documentation defect,
not a new collapse. `PlusWitnessFamily/Incompleteness.lean:51-52`'s module docstring asserts "The
`untl` side is defect-free by inspection, not by machine check", which row 2 refutes (the `untl`
conjunct collapses in the same shape as the `snce` conjunct, not merely a shifted one).
`Incompleteness.lean` is not among task 696's fourteen declared `file_scope` paths, so no task
currently owns this correction, and this task cannot make it either (no Lean-adjacent modification
permitted; the path is outside this task's own `file_scope`). The same false claim, in the two
READMEs task 696 *does* own (`PlusWitnessFamily/README.md:100-102`, `Sharing/README.md:124`), is
recorded as a strengthening of task 696's own scheduled Phase 0 correction — see the proposal file
for both handoff items in full, with line references re-verified at write time.

## Appendix

### Probe

`specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/01_clause_shape_collapse_probe.lean`
(220 lines). Elaborated with:

```
cd /home/benjamin/Projects/BimodalLogic && \
  lake env lean specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/01_clause_shape_collapse_probe.lean
```

Exit 0, no errors, no warnings. Ten `#print axioms` lines: `clause_shape_common_witness` "does not
depend on any axioms"; the other nine show `[propext, Classical.choice, Quot.sound]` (inherited from
the imported library); **no `sorryAx` anywhere**. Declarations:

| Declaration | What it establishes |
|---|---|
| `clause_shape_collapse` | the abstract lemma; reflexivity is the only hypothesis |
| `clause_shape_common_witness` | the reflexivity-free residual (axiom-free) |
| `snce_share_congr'` | the landed `snce_share_congr`, re-derived from the abstract lemma |
| `untl_share_succ_congr` | row 2: the new `untl`-side label congruence across `share (t+1)` |
| `snce_share_congr_formula` | row 3: `Formula`-side `snce` collapse |
| `untl_share_succ_congr_formula` | row 4: `Formula`-side `untl` collapse |
| `plusShareClauseAt_snce_collapse` | row 5, `snce` arm, at the decision procedure's data |
| `plusShareClauseAt_untl_collapse` | row 5, `untl` arm |
| `tUntl_trans_congr` | row 18: the redesign's residual `untl` collapse |
| `tSnce_trans_congr` | row 19: the redesign's residual `snce` collapse |
| `tUntl_common_succ_congr` | what row 18 becomes with `trans_refl` removed |

`specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/02_remaining_verdicts_probe.lean`
(standalone; does not import probe 01). Elaborated with:

```
cd /home/benjamin/Projects/BimodalLogic && \
  lake env lean specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/02_remaining_verdicts_probe.lean
```

Exit 0, no errors, no warnings. Four `#print axioms` lines, all `[propext, Classical.choice,
Quot.sound]`; **no `sorryAx`**. Declarations:

| Declaration | What it establishes |
|---|---|
| `SharingWitnessFamily.shareClauseAt_snce_collapse` | row 6, `snce` arm, `Formula`-side decision-procedure mirror |
| `SharingWitnessFamily.shareClauseAt_untl_collapse` | row 6, `untl` arm |
| `PlusSharingWitnessFamily.plusBox_globality` | row 12, the full (C1')/(C3) composition A3 states in prose |
| `PlusSharingWitnessFamily.plusBox_share_congr` | row 12, the named globality congruence `box χ ∈ L i t ↔ box χ ∈ L j v` |

### Enumeration commands

Superseded by `specs/699_invariance_clause_audit_and_ockhamist_grounding/audit/enumerate-shape-s.sh`,
a re-runnable version of the three passes below, and its dated output snapshot
`audit/01_enumeration-snapshot.md`. The inline commands originally run for this report are kept
here for the historical record, but **the figures below are corrected against the script's
2026-09-29 run, not against a re-run of the exact text shown**:

```
# candidate predicates: definitions in Metalogic whose body contains a biconditional
for f in $(find FormalSystem/Metalogic -name '*.lean'); do
  awk -v F="$f" '/^def |^abbrev |^structure |^class |^  def / { indef=1; buf=$0"\n"; ln=NR; next }
    indef==1 { buf=buf $0"\n"; if ($0 ~ /^$/) { if (buf ~ /↔/) printf "%s:%d\n", F, ln; indef=0; buf="" } }' "$f"
done | sort -u            # corrected: 64 hits, 39 files (was stated as 67/40; no tree drift —
                           # see audit/01_enumeration-snapshot.md's Divergence analysis)

# share-guarded quantifiers
grep -rn "share" FormalSystem/Metalogic --include=*.lean | grep -E "∀.*share|share.*→"
                           # 18 hits (not previously given as a standalone figure)

# reflexive relations in Metalogic — NOTE: this command as originally written is missing `-E`
# and returns 0 hits if run literally (GNU grep's basic-regex mode treats `|` as literal, not
# alternation). The working, corrected form:
grep -rnE "^theorem .*_refl\b|^@\[refl\]|Reflexive" FormalSystem/Metalogic --include=*.lean
                           # corrected: 45 hits (was stated as 39)
```

**Divergence, in one line**: no file under `FormalSystem/Metalogic` changed between this report's
completion and the 2026-09-29 re-run (`git log` empty over that window). The three corrected
figures above come from (a) the pass-3 command's missing `-E`, and (b) the original enumeration
never having scanned `FormalSystem/Metalogic/WeakCanonical/**` (pre-existing at report time, not
new code). All six Shape-(S) candidates the re-run finds under `WeakCanonical/` were individually
checked and are OUT OF SHAPE under the same two reasons row 17 already names (both sides of the
`↔` mention the bound object, or there is no relational guard at all) — **the audit table's
nineteen rows and their verdicts are unaffected**. Full derivation-level detail:
`audit/01_enumeration-snapshot.md`.

### Literature read

| Source (corpus `doc_id`) | Chunks / sections actually read | What was taken from it |
|---|---|---|
| `thomason_1984` | `sec04_3-historical-necessity.md` 95-210; `sec05_4-the-technical-side-of-historical-neces.md` 10-135, 135-232, 240-315 | Ockhamist Def 2-4 and the pair-relativization argument; "the only way a thing can be true at a moment is for it to be settled"; Def 5 (via 1970); T × W Def 6-8 with backward closure clause (2); Kamp frames Def 9; Kamp's axioms (AK0)-(AK13), (RK0)-(RK3) and their incompleteness via formula (17); neutral frames₁ Def 10(5) and Fig. 2 one-way completion; Gabbay (AG1)/(RG1); Gurevich–Shelah decidability; Burgess 1979 p. 577 |
| `thomason-1970-indeterminist-time` | `chunk_0001`-`chunk_0004`, `chunk_0035`, `chunk_0043`; grep over all 79 chunks | Confirmed identity and setting only. Conversion is column-interleaved OCR, unusable verbatim; global index flags `no_source_pdf`. Content cited through Thomason 1984 Def 5 instead; one dependent claim marked unverified |
| `reynolds_2003_priors-ockhamist-logic-historical-necessity` | `chunk_0001`, `chunk_0012`, `chunk_0013`, `chunk_0027` | Tree-with-unique-past setting of both Prior options; bundled-vs-complete and limit closure; "emergent histories" and the truth-lemma failure; LC as an infinite schema, one axiom per `n > 0`, Lemma 3 |
| `reynolds_2001` | `sec03_…md` 192-194, 348 (grep-located) | LC axiom schema plus auxiliary atoms rule added to `⊢_B` for full CTL* |
| `emerson_and_halpern_-_1986_-_…` | `chunk_0014`, `chunk_0015` | Suffix / fusion / limit closure definitions; R-generability; "R-generable iff suffix closed, fusion closed, and limit closed" |

Not consulted, and why: `rumberg-zanardo-2019-transition-structures` and
`reynolds_2002_axioms_for_branching_time` (both flagged `no_source_pdf`; the definability and
survey material they carry is already covered by Reynolds 2003 §5 and Thomason 1984 §4 for the two
questions asked), `burgess_1982_i` / `burgess_1982_ii` (period-based substrate, consulted by task 696
round 2 and not re-read here).

### Cross-references

- Task 696 reports `01_stability-modal-substrate-design.md` (F1-F8, Q1-Q4, phasing) and
  `02_trans-redesign-gate-verification.md` (F1-F4, the gate families in Lean). Cited throughout; not
  restated.
- Task 696 probe `01_untl_shift_congr_probe.lean` contains `untl_shift_share_congr`, the shifted
  `untl`-side congruence that row 2 is distinct from.
