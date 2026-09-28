# Research Report: Task #623

**Task**: 623 - Decidable `ValidZTime` via the quasimodel / ShiftSet witness-family route (the completeness/compression half)
**Started**: 2026-09-28T17:42:38Z
**Completed**: 2026-09-28T18:40:00Z
**Effort**: 2-4 weeks (implementation estimate, unchanged)
**Dependencies**: 534, 645, 665, 680, 688 — **all five are now complete**; the description's "one unmet dependency" (the documentation task) has since landed
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/WitnessFamily/` (7 modules + `Sharing/`), `FormalSystem/Metalogic/Decidability/BiLasso/` (`GoodCycle.lean`, `Extraction.lean`, `Realized.lean`, `SmallModel.lean`, `Enumerate.lean`, `Assembly.lean`, `Unfold.lean`, `Periodic.lean`), `FormalSystem/Semantics/IntTransfer.lean`, `FormalSystem/Semantics/Frames/TranslationProduct.lean`, `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean`
- lean-lsp MCP: `lean_run_code` (four compiled probes), `lean_local_search`
- Literature: Gabbay, Kurucz, Wolter & Zakharyaschev, *Many-Dimensional Modal Logics: Theory and Applications* (2003), held at `~/Projects/Literature/sources/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics/` (760 chunks)
- Prior report: `specs/623_decidable_validztime_quasimodel_shiftset_route/reports/01_stability-scope-decidability-findings.md`
**Artifacts**:
- `specs/623_decidable_validztime_quasimodel_shiftset_route/reports/02_compression-half-witness-family-route.md` (this report)
- `specs/623_decidable_validztime_quasimodel_shiftset_route/evidence/02_semantic-side-spike.lean` (compiled green)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The semantic half of compression is already de-risked, and is now machine-checked.** A
  compiled spike (`evidence/02_semantic-side-spike.lean`) defines the presentation-free type
  `typeAtM` of a position of an *arbitrary* `FrameOver intOrder` model and proves all **five**
  `LocalCoherentLab` clauses plus the `untl` half of `FulfillingLab` from the semantics alone.
  `LocalCoherentLab` drops `LocalCoherentSeq`'s atom clause — which is the only clause that ever
  needed a presentation — so nothing is lost by working presentation-free. This half costs a
  transcription of `BiLasso/SmallModel.lean`'s `typeAt_localCoherentSeq`, not a new argument.
- **The combinatorial core is reusable verbatim, and the reuse is verified.**
  `GoodCycle.lean`'s `exists_good_cycle_of_seq` is already generic in its datum sequence
  `d : ℤ → PigeonState P φ` and touches `P` only through `Nat.card (PigeonState P φ)`. A
  one-state `IntPresentation` collapses that space to the pure type space: I compiled
  `cycleBound dummyP φ = (2·k + 1)·2^k` with `k = subformulaClosureCard φ`. Recommendation is
  nonetheless to **transcribe** rather than instantiate — see Decisions.
- **Recurrence-freeness is a *negative* licence, and the dispatch's phrasing inverts it.**
  `TranslationProduct.lean`'s `validIn_iff_recurrenceFree` lets the countermodel be taken
  recurrence-free, i.e. **no world state ever recurs**. That does not let the state sequence be
  compressed — it forbids it. What it licenses is exactly the opposite move the route needs: the
  compression must run on the *type* sequence only, and a presentation-free certificate
  (`WitnessFamily`) is the only shape that can carry the result. This is the structural reason
  `Probe476.fmp_false` refutes the finite-presentation hypothesis, and it should be stated in
  the plan in these terms.
- **Four concrete micro-gaps were identified and two of them compiled in three lines each**:
  `closureOf ([] ++ [φ]) = subformulaClosure φ` (`by simp [closureOf]`) and
  `SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ` (six lines; no such lemma exists in the tree).
- **The enumeration has one non-obvious hazard and one clean fix.** `WitnessFamily.bx` is a
  function on the infinite type `Formula`, so the family is *not* directly enumerable — the same
  trap `Assembly.lean` records for `IntPresentation.val`. The fix: `bx` is read only at `χ` with
  `□χ` in the closure, so `cands` enumerates `fun χ => decide (χ ∈ S)` over
  `S ∈ (boxedPart C).powerset`, and compression must produce a family whose `bx` is in that
  canonical form. This is a hard constraint on how the compression theorem is *stated*.
- **`FragmentAxiomatization.lean` does not help and should be dropped from the tool list.** It
  concerns the tense-only L⁻ fragment (no `untl`/`snce`), and its ZTime completeness is
  explicitly **not machine-checked** — it is Venema 2001 Thm 3.3 on paper, available only in the
  conditional form `minusExt_sigmaZTime_iff_tmFrag_of_chainComplete`. Using it would import an
  unproved hypothesis into a chain this task must close unconditionally.
- **Zero-sorry feasibility**: no step of the route requires a `sorry`, an axiom, or a deferral.
  The route is long but every link is either landed, transcribable from a landed template, or
  (for the ℤ two-sided adaptation) already done once in `BiLasso/Extraction.lean` at the other
  carrier.

## Context & Scope

Research covers **items 1 and 2** of the task description only. Item 3 is struck (delegated and
landed: `Assembly.lean`'s docstring now reads "refuted, closed negatively, not open" and carries
the `⊡`-scope paragraph; the `WitnessFamily/README.md` carries the non-monotonicity correction).

Constraints absorbed before planning:

1. **Consume, never re-prove, the soundness half.** `WitnessFamily/{Basic,Closure,Predicates,
   Std,Agreement,Decide,Examples}.lean` are given. The compression direction must terminate in
   `∃ W ∈ cands, ∃ t, W.Certifies t`, feeding `decidableCertifies` and `refutes_of_certifies`.
2. **The non-monotonicity correction** (from the prerequisite-recording task, and now in
   `WitnessFamily/README.md`): the *consuming* model checker's registry folds `back`/`mid`/`fwd`
   bounds by exact modulus, so a search at bound `n` represents exactly the periods dividing `n`
   — measured: SAT at `(3,1,3)` and `(6,1,6)`, genuinely UNSAT at `(4,1,4)` and `(5,1,5)`.
   Representability, not magnitude, is what the folding decides.
3. **Territory.** Siblings 684 and 690 are dispatched this same cycle and own
   `WitnessFamily/{Agreement,Basic,README.md}.lean`, `WitnessFamily.lean`,
   `Sharing/{Predicates.lean,README.md}` and `PlusLanguage/{Formula,PlusTruth}.lean`. Two of
   those (`WitnessFamily.lean`, `WitnessFamily/README.md`) are files this task must also touch.

## Literature Proof Structure

**Source**: Gabbay, Kurucz, Wolter & Zakharyaschev, *Many-Dimensional Modal Logics* (2003),
Ch. 5 §5.2-5.3, Ch. 6 §6.5, Ch. 11 §11.2-11.5.
**Strategy**: quasimodels — replace a (possibly infinite) model by a *state function* assigning a
finite set of **types** to each time point plus a set of **runs** through it, then compress the
state function to an ultimately periodic one with an effectively bounded period.

### Step Map

1. **The product embeds into monodic first-order temporal logic** — [GKWZ] **Theorem 3.29**
   (chunk_0193): for a class `C` of strict linear orders,
   `φ ∈ Log(C × FrS5 × ⋯) iff φ^♭ ∈ QLog_mon(C)`. This is precisely TM's shape (S5 modality ×
   linear temporal over ℤ), and it is what licenses reading the whole quasimodel apparatus onto
   this repository's frames.
2. **The finite model property genuinely fails** — [GKWZ] **Theorems 5.30 and 5.32**
   (chunk_0274, chunk_0275): if `C` contains `(ℕ,<)` or `(ℤ,<)`, then `Log C × L` lacks the
   (abstract) fmp for any Kripke-complete `L` with an infinite frame carrying a universal point;
   likewise for any `C` with an ascending ω-type chain. **Independent corroboration of
   `Probe476.fmp_false`**, from the literature rather than from a probe.
3. **Quasimodels, and the four ways to use them** — [GKWZ] §5.2 (chunk_0264): (1) find a *finite*
   quasimodel and build a finite product model; (2) show a quasimodel exists iff a finite set of
   bounded "blocks"/mosaics satisfying effectively checkable conditions exists; (3) translate
   "a quasimodel exists" into MSO; (4) tableau procedures. **This task is route (2)**; route (3)
   is what report 01 already recorded as "a sanity check, not a route".
4. **The compression criterion, with an explicit bound** — [GKWZ] **Theorem 11.26**
   (chunk_0494): a sentence is satisfiable over `(ℕ,<)` **iff** there are `l₁, l₂` bounded by an
   explicit expression in `|sub φ|` and the type/candidate counts, and a sequence of realizable
   state candidates `T₀,…,T_{l₁+l₂-1}` such that five conditions hold — (1) the target is in
   `T₀`; (2)/(3) forward and backward *suitability* of adjacent pairs, with the loop closing at
   `T_{l₁+l₂-1} → T_{l₁}`; (4) every type in `T_{l₁}` is *root saturated* — some suitable cycle
   from it realizes all its `U`-formulas; (5) the same for the constant runs.
5. **The lasso shape, explicitly** — [GKWZ] **Theorem 11.45** and its proof (chunk_0514,
   chunk_0515): the run set is all infinite words `s₁ · s₂ · s₃^ω` with `s₁`, `s₂` suitable and
   `s₃` **root saturated**, each of separately bounded length. **This is a lasso**, and its
   three segments correspond one-for-one to `LabelledLasso`'s `mid`, `mid`, `fwd`.
6. **The general ℤ/linear-order criterion is non-constructive** — [GKWZ] **Theorems 11.7 and
   11.21** (chunk_0479, chunk_0486): decidability for *any* first-order-definable class of
   strict linear orders, proved in §11.3 by translation into MSO and appeal to Rabin. No bound,
   no certificate.
7. **The complexity target** — [GKWZ] §6.5 and §11.4 (chunk_0297, chunk_0503): `PTL × S5` is
   **EXPSPACE-hard**, with a matching upper bound in §11.4 (Theorems 11.30, 11.31). So the
   procedure this task builds is necessarily exponential-space; that is the literature's own
   lower bound, not an artefact of the Lean encoding.

### Dependencies

- Step 4 depends on Step 3's quasimodel definition; Step 5 refines Step 4's conditions (its
  condition (4)′ strengthens Step 4's (4)).
- Step 1 is what makes Steps 4-5 applicable to this repository at all.
- Step 2 is independent, and is the *negative* result the certificate shape answers to.
- Step 6 is an alternative to Steps 4-5 and is **not** on this task's path.
- Step 7 bounds what can be hoped for, and is independent of the rest.

### Terminology map (literature → this tree)

| [GKWZ] | This tree |
|---|---|
| type `t` for `φ` | `Finset Formula` with `⊆ closureOf (Γ ++ Del)` |
| suitable pair `(t, t')` | the `untl`/`snce` clauses of `LocalCoherentLab` across `t → t+1`; cf. `BiLasso/Realized.lean`'s `CoherentEdge` |
| root saturated sequence | "good cycle" — `GoodCycle.lean`'s `exists_good_cycle_of_seq` conclusion |
| run through the state function | `LabelledLasso.lab : ℤ → Finset Formula` |
| state function `q` | the family `WitnessFamily.L` plus `bx` |
| quasimodel `(q, R)` | `WitnessFamily` + `Certifies` |
| conditions (tqm1)-(tqm3) | `Target` / `LocalCoherentLab` + `FulfillingLab` / `BoxFaithful` |
| `l₁, l₂, l₃` bounds | `cycleBound`, `midBound`, `bound` |

### Potential formalization challenges

- **Step 4/5 are one-sided (`ℕ`); this task needs two-sided (`ℤ`).** The held source has **no**
  bi-lasso compression theorem: its ℤ result is Step 6, the MSO one. The two-sided adaptation is
  formalization-native — but it has already been carried out once in this tree, at the other
  carrier, by `BiLasso/Extraction.lean`'s `exists_annot_of_truth` (back cycle read outward from
  `-1`, mid walk shortened in two legs around the point of interest, forward cycle from `nm`).
  **That file, not the book, is the template for the ℤ geometry.**
- **The book's "realizable state candidate" oracle has no counterpart here** and needs none: this
  is the propositional (not first-order) case, so a type is just a closure subset and
  realizability is trivial. The corresponding work migrates entirely into `BoxFaithful`.
- **[GKWZ]'s state function assigns a *set* of types per time; `WitnessFamily` assigns one type
  per lasso per time.** The translation is: the family's lassos enumerate the runs, and
  `BoxFaithful`'s `∀ i t` quantifier is the "label pool" that replaces the book's `T_n`.

## Findings

### Codebase Patterns

**The target shape (landed, consume as-is).**

- `WitnessFamily.Certifies W t := LocalCoherentLab ∧ FulfillingLab ∧ BoxFaithful ∧ Target t`
  (`Predicates.lean:131`), with `decidableCertifies` (`Decide.lean:936`) and
  `refutes_of_certifies : W.Certifies t → Refutes Γ Del` (`Agreement.lean:282`).
- `Refutes Γ Del` is the eight-fold existential a checker returns; `not_consequence_ztime`
  (`Agreement.lean:219`) is the form the assembly needs.
- **`FulfillingLab` is `BiLasso/SmallModel.lean`'s `FulfillingSeq` verbatim, per lasso**, and
  **`LocalCoherentLab` is `LocalCoherentSeq` minus the atom clause**, with
  `closureOf (Γ ++ Del)` in place of `subformulaClosure φ`. Every sequence-level lemma stated
  against `LocalCoherentSeq`/`FulfillingSeq` therefore transcribes with the atom clause deleted
  and no other change.

**The combinatorial core (reusable).**

- `GoodCycle.lean:361` `exists_good_cycle_of_seq (d : ℤ → PigeonState P φ) (ev) (x) (hrec) (hful)`
  — generic in `d`; `P` enters only via `Nat.card (PigeonState P φ)` in the bound. Its
  conclusion is the "root saturated sequence" of [GKWZ] Thm 11.45.
- `GoodCycle.lean:290` `cycleBound P φ = (2·k + 1)·P.card·2^k`.
- `GoodCycle.lean:583` `fulfilling_of_good_cycles` — takes `hco : LocalCoherentSeq P φ bx lab st`
  but uses `st` nowhere; only the `untl`/`snce` clauses are consumed, via
  `untl_propagates_to_end` / `snce_propagates_to_start`.
- `GoodCycle.lean:524,541` `lab_add_mul_nf` / `lab_sub_mul_nb` — **already presentation-free**
  (`{lab : ℤ → Finset Formula}` only), reusable with no change at all.
- `Realized.lean:284` `localCoherentSeq_of_edges` — the splice lemma. Its docstring states the
  exact reason splicing is sound (no clause reaches two steps away, and no clause mentions `t`).
  That reasoning survives the atom-clause deletion untouched.
- `Enumerate.lean:58,63,189,211` `ofLen`, `upTo` (fully generic in `α`), `closureSubsets`,
  `rawLabels` — the enumeration plumbing, with `mem_ofLen`/`mem_upTo` completeness lemmas.

**The carrier normalization (landed).**

- `IntTransfer.lean:335` `validZTime_iff_validInt : ValidZTime φ ↔ ValidInt φ`, where `ValidInt`
  quantifies over `F : FrameOver intOrder` only. This is compression step 0 and it is free.
- `Unfold.lean:90,134` `truth_untl_succ` / `truth_snce_pred` are stated at an arbitrary
  `{F : FrameOver intOrder} {M : TaskModel F} {τ : WorldHistory F}` — directly reusable, and the
  spike uses them.
- `TruthTransport.lean:310` `Truth.box_const M τ σ t s φ` — makes a single global `bx` correct.

**Negative findings.**

- **`FragmentAxiomatization.lean` is not a usable tool here.** Its `.ZTime` row reads: soundness
  machine-checked (`minusExt_sigmaZTime_le_tmFrag`), **completeness not machine-checked** —
  Venema 2001 Thm 3.3, "a survey citation whose primary sources (Segerberg 1970, Goldblatt) are
  not in the corpus", available only as
  `minusExt_sigmaZTime_iff_tmFrag_of_chainComplete`. It is also about L⁻ (H/G/□), which has no
  `untl`/`snce`. Recommend the plan drop it from the tool list rather than carry it.
- **`validIn_iff_recurrenceFree` is stated for `ValidIn`, not for `SemanticConsequenceIn`.**
  There is no consequence-form analogue in the tree. Since `cands` will be built at
  `Γ = []`, `Del = [φ]`, this is not blocking — but it means the plan should target
  `ValidZTime φ` and derive the consequence corollary from `Del = [φ]`, not the other way round.
- **No `SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ` lemma exists** (`lean_local_search` and a
  repo-wide grep both empty). Six lines; see the spike header.
- **The `BiLasso/` row of `FormalSystem/Metalogic/Decidability/README.md` still says "outside
  the build graph"**, contradicted by the `BiLasso/README.md` Dependencies section and by the
  generated root. Recorded as a known follow-up by the soundness task's summary; still unfixed.

**The enumerability trap, in full.**

`WitnessFamily Γ Del` has field `bx : Formula → Bool` — a function on an infinite type. This is
the *identical* trap `Assembly.lean`'s docstring records for `IntPresentation.val`:

> `cands` cannot be "presentations of card at most `presentationBound φ`", because
> `IntPresentation.val` is a function on the `Infinite` type `Atom` and no such finite list
> exists.

The `WitnessFamily` route escapes it where the `IntPresentation` route could not, because `bx` is
**only ever read at `χ` with `□χ ∈ closureOf (Γ ++ Del)`** — both in `LocalCoherentLab`'s box
clause and in `BoxFaithful`. So define `boxedPart C := C.filterMap (·.boxArg?)` (or equivalent)
and enumerate `bx` as `fun χ => decide (χ ∈ S)` for `S ∈ (boxedPart C).powerset`. **The
compression theorem must be stated so that the family it produces already has `bx` in this
canonical form** — that is a constraint on the statement, not a lemma to add afterwards. It is
discharged by taking `S := (boxedPart C).filter (fun χ => ∀ σ v, TruthAt M σ v χ)` with
`Classical.dec`: the resulting `S` is a genuine `Finset`, so `fun χ => decide (χ ∈ S)` is
computable and enumerated, even though the filter predicate is not.

**Target-time search.** `Target t` quantifies a `t : ℤ`. Two routes, both sound:
(a) the compression delivers `t` in `[0, nm]` (exactly `Extraction.lean`'s
`witness_pos_mem_cohWindow` shape) and the assembly searches
`Finset.Ico (-nb) (nm + nf)`; or (b) reduce `t` modulo the periodicities — `Target t` reads only
`W.main t`, which is `nb`-periodic below `0` and `nf`-periodic at or past `nm`. Route (a) is
recommended: it mirrors a landed template and needs no new periodicity reasoning.

### External Resources

- **Held and used**: [GKWZ] 2003, all seven cited results located and read (chunks 0193, 0264,
  0274, 0275, 0479, 0486, 0494, 0503, 0514, 0515). Cite by **theorem number plus chunk file**,
  per the corpus's citation rule; the conversion has OCR noise in displayed formulas (e.g.
  `QT L` for `QTL`, `Sb5` for `S5`), so **transcribe no formula from it verbatim** — take
  structure only.
- **Not held / not needed**: Rabin's tree theorem (report 01 already flags this), Venema 2001,
  Segerberg 1970.

### Recommendations

1. **Land the compression in a new presentation-free subdirectory module set, not in
   `BiLasso/`.** `WitnessFamily/README.md` states as an invariant that "the only dependency on
   `../BiLasso/` is `Periodic.lean`, which is deliberately directory-independent". Importing
   `BiLasso/GoodCycle.lean` into `WitnessFamily/` would break that stated invariant. Proposed
   modules, all new, all under `WitnessFamily/`:
   - `Type.lean` — `typeAtM`, `mem_typeAtM`, `typeAtM_clauses`, `typeAtM_fulfilling`
     (**the spike is this module, already green**)
   - `Cycle.lean` — the pigeonhole core over `TypeState C := {S : Finset Formula // S ∈ C.powerset}`:
     `SeqStep`, `exists_recurring_datum`, `exists_base_cycle`, `exists_good_cycle_of_seq`,
     `cycleBound`, plus `untl_propagates_to_end` / `snce_propagates_to_start` and
     `fulfilling_of_good_cycles` with the atom clause deleted
   - `Compress.lean` — the per-history bi-lasso extraction (the ℤ geometry, transcribing
     `Extraction.lean`)
   - `Complete.lean` — the family assembly: main lasso + one lasso per falsified box witness,
     `BoxFaithful`, `Target`
   - `Enumerate.lean` + `Assembly.lean` — `cands`, `validZTime_iff_checkFamily`-shaped iff,
     `decidableValidZTime`
2. **Transcribe the pigeonhole core; do not instantiate `GoodCycle.lean` at a dummy
   presentation.** The dummy route *works* — I compiled
   `cycleBound dummyP φ = (2k+1)·2^k` for a one-state `IntPresentation` — but it threads a
   semantically meaningless `P` through every statement in the new directory and breaks the
   directory invariant above. Transcribe instead, and **record the duplication with the same
   retirement trigger the directory already uses** for `Decide.lean` ("once a shared periodic-label
   presentation lands, both should be redefined as its two instances"). The dummy-presentation
   result should nonetheless be recorded in the plan as the *cross-check* that the transcribed
   bound is right.
3. **State the compression bound as a length *grid*, not as a single bound.** Because
   representability is a divisibility question, the plan's enumeration must be
   `∀ (nb, nm, nf) ∈ [1,B] × [0,B] × [1,B]` — every triple — and the completeness statement must
   say "there exist segment lengths *at most* `B`", never "at least `f(|C|)`". `Enumerate.lean`'s
   `upTo` already enumerates every length up to `n`, so the Lean side is naturally correct; the
   hazard is purely one of how the theorem is *worded* and of what the consuming checker then
   reads into it. Add one sentence to the compression theorem's docstring saying that the
   enumeration sweeps the grid and that a bound alone does not transfer to a modulus-folding
   consumer.
4. **Order the phases so that each is independently green**: Type → Cycle → Compress (one
   history) → Complete (the family) → Enumerate → Assembly. Phases 1 and 2 are transcriptions
   with landed templates; phase 3 is the only genuinely new geometry, and it has a 250-line
   worked precedent.
5. **Coordinate on `WitnessFamily.lean` and `WitnessFamily/README.md`** — both are in sibling
   684's declared file scope. Plan the aggregator/README edits as a single final phase, re-read
   immediately before editing, and stage only this task's hunks.
6. **No sorry-free risk was found.** Every step is either landed, transcribable, or has a worked
   precedent in-tree. If the ℤ geometry of phase 3 proves harder than `Extraction.lean` suggests,
   the correct response is to split phase 3 (back cycle / mid walk / forward cycle as three
   sub-phases, each with its own green gate), **not** to introduce a placeholder.

## Decisions

- **Target `ValidZTime φ` directly, with `Γ = []`, `Del = [φ]`**, and derive the consequence
  corollary from `not_consequence_ztime` at `Del = [φ]`. Reason: `validIn_iff_recurrenceFree` and
  `validZTime_iff_validInt` are both stated for validity, not for consequence, and no
  consequence-form analogue exists.
- **Transcribe rather than import the `BiLasso/` pigeonhole core**, preserving the
  `WitnessFamily/` directory's stated "only `Periodic.lean`" dependency invariant, and record the
  duplication with the directory's existing retirement trigger. The dummy-presentation
  instantiation is kept as a cross-check, not as the implementation.
- **Canonical `bx`**: the compression theorem states its conclusion with
  `bx = fun χ => decide (χ ∈ S)` for an explicit `S ⊆ boxedPart C`, so that the enumerated
  candidate list can match it.
- **Target time delivered in `[0, nm]`**, searched over `Finset.Ico (-nb) (nm + nf)`, mirroring
  `witness_pos_mem_cohWindow`.
- **`FragmentAxiomatization.lean` is dropped** from the task's tool list, with the reason
  recorded (L⁻ fragment; ZTime completeness not machine-checked).
- **No decision taken** on whether the eventual shared periodic-label abstraction should be built
  as part of this task. Recommendation is no — it would put a large refactor under `BiLasso/`'s
  live `check`.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| The ℤ two-sided compression is not in the held literature (only the ℕ one-sided version, Thm 11.26/11.45) | Medium | `BiLasso/Extraction.lean`'s `exists_annot_of_truth` is the in-tree precedent for exactly this geometry; transcribe its three-segment table rather than re-deriving |
| `bx` is a function on an infinite type, so the family is not naively enumerable | High if missed, low if planned | Canonical-`bx` constraint written into the compression theorem's statement (see Decisions); this is the same trap `Assembly.lean` records for `IntPresentation.val` |
| A bound of the shape "segment lengths at least `f(|C|)`" is read as sufficient by the consuming checker | Medium | State the enumeration as a grid sweep; add the divisibility sentence to the docstring; the correction is already in `WitnessFamily/README.md` |
| Sibling 684 edits `WitnessFamily.lean` / `WitnessFamily/README.md` concurrently | Medium | Single final documentation phase; re-read immediately before edit; hunk-scoped staging; never `git add` a directory |
| Transcribed duplication of `GoodCycle.lean` drifts from its original | Low | Record the retirement trigger in the new module's docstring, as `Decide.lean` and `Basic.lean` already do |
| Candidate-list size is astronomically large (`~(2^k)^{3B(1+k)}`) | Low (correctness), High (usability) | `Decidable` is the deliverable, not a usable executable; [GKWZ] §6.5 gives an EXPSPACE-hardness lower bound, so no encoding can do materially better. Say so in the docstring rather than apologising for it |
| OCR noise in the literature conversion | Low | Take structure only; transcribe no formula verbatim; cite theorem number + chunk file |

## Tactic Survey Results

Four probes were run through `lean_run_code` against the tree at `26d45a4c5`. The survey was
design-level (there is no existing partial proof to close), so the table records *statement
feasibility*, which is what the plan needs.

| Goal | Tactic / route | Result | Premises/Config |
|---|---|---|---|
| `closureOf ([] ++ [φ]) = subformulaClosure φ` | `simp [closureOf]` | **success** | none |
| `SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ` | `constructor` + two `intro`/`exact`, with `by simp` for the vacuous premise | **success** | none |
| one-state `IntPresentation` exists | structure literal, `norm_num` for `card_pos`, `rfl` for `fwd`/`bwd` | **success** | `dummyP` |
| `Nat.card (PigeonState dummyP φ) = 2 ^ subformulaClosureCard φ` | `rw [natCard_pigeonState]; simp [dummyP]` | **success** | `natCard_pigeonState` |
| `cycleBound dummyP φ = (2k+1)·2^k` | `rw [cycleBound_eq]; simp [dummyP, subformulaClosureCard]` | **success** | `cycleBound_eq` |
| all five `LocalCoherentLab` clauses for `typeAtM` at an arbitrary `FrameOver intOrder` model | explicit term proofs; `Truth.imp_iff`/`Truth.box_iff` (explicit formula args), `Truth.box_const`, `truth_untl_succ`, `truth_snce_pred`, `closureOf_*` projections | **success** | see `evidence/02_semantic-side-spike.lean` |
| `FulfillingLab`'s `untl` half for `typeAtM` | `obtain` on the truth clause + `mem_typeAtM.mpr` | **success** | `closureOf_untl_left/right` |

Two naming traps worth recording for the implementation: `Truth.imp_iff` and `Truth.box_iff` take
their **formula arguments explicitly** (`Truth.imp_iff a b`, `Truth.box_iff χ`), and
`closureOf_untl_left` returns the **event** `e` while `closureOf_untl_right` returns the **guard**
`g` (their `left`/`right` refers to the underlying `closure_untl_left χ e g` argument order, not
to the `untl g e` argument order). Both cost a round trip when guessed.

`lean_diagnostic_messages` and `lean_file_outline` were not called (blocked tools).

## Context Extension Recommendations

- **Topic**: the quasimodel method, as this tree instantiates it.
  **Gap**: `context/project/lean4/` has no note mapping [GKWZ]'s type / suitable-pair / root-saturated-sequence / run / state-function vocabulary onto `LabelledLasso` / `CoherentEdge` / good cycle / `lab` / `WitnessFamily`. The mapping was re-derived here from scratch and will be re-derived again by the next reader.
  **Recommendation**: add `context/project/lean4/domain/quasimodel-vocabulary.md` carrying the terminology table from this report's Literature Proof Structure section.
- **Topic**: the infinite-function-field enumerability trap.
  **Gap**: `Assembly.lean` records it for `IntPresentation.val` in a module docstring; nothing states it as a reusable pattern, and it recurs verbatim for `WitnessFamily.bx`.
  **Recommendation**: one paragraph in `context/project/lean4/patterns/`, naming the escape (read the function only at a finite index set, enumerate `fun x => decide (x ∈ S)` over that set's powerset).

## Appendix

**Probes** (all via `lean_run_code`; the last is preserved at
`specs/623_decidable_validztime_quasimodel_shiftset_route/evidence/02_semantic-side-spike.lean`):
closure bridge; empty-premise consequence; one-state presentation + `cycleBound`; `typeAtM` with
all five coherence clauses and the `untl` fulfilment half.

**Literature chunks read** (`~/Projects/Literature/sources/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics/`):
`chunk_0193` (Thm 3.29), `chunk_0264` (quasimodels, the four routes, Thm 5.22),
`chunk_0274` (Thm 5.30), `chunk_0275` (Thm 5.32), `chunk_0479` (Thm 11.7, Question 11.8),
`chunk_0486` (Thm 11.21, §11.3), `chunk_0493` (§11.4 preamble, "periodical state function"),
`chunk_0494` (Thm 11.26, conditions (1)-(5)), `chunk_0500` (Thm 11.30),
`chunk_0503` (Thm 11.31, EXPSPACE-complete), `chunk_0514` (Thm 11.45),
`chunk_0515` (the `s₁·s₂·s₃^ω` run set, root saturation), `chunk_0297` (`PTL × S5` EXPSPACE-hard),
`chunk_0520` (the `(ℤ,<)` reduction remark).

**Codebase anchors**: `WitnessFamily/Predicates.lean:69,95,109,120,131`;
`WitnessFamily/Agreement.lean:209,219,269,282`; `WitnessFamily/Decide.lean:866-936`;
`BiLasso/GoodCycle.lean:112,141,173,257,290,361,524,541,583`;
`BiLasso/Realized.lean:93,156,186,222,284`; `BiLasso/SmallModel.lean:59,77,99,121,192`;
`BiLasso/Extraction.lean:299,320,354`; `BiLasso/Enumerate.lean:58,63,189,211`;
`BiLasso/Assembly.lean:80,110`; `BiLasso/Unfold.lean:90,134`;
`Semantics/IntTransfer.lean:315,335`; `Semantics/Frames/TranslationProduct.lean:613`;
`Semantics/TruthTransport.lean:310`; `Semantics/Truth.lean:287,312`.
