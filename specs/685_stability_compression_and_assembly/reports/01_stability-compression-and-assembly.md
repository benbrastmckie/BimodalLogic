# Research Report: Stability Compression and Assembly

- **Task**: 685 - stability_compression_and_assembly
- **Started**: 2026-09-28T14:27:00Z
- **Completed**: 2026-09-28T15:40:00Z
- **Effort**: ~1.2 hours
- **Dependencies**: 684 (agreement lemma over all walks, completed), 623 (deterministic compression half, completed)
- **Sources/Inputs**:
  - Certificate stack (read): `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Basic,Predicates,Agreement,Closure,Examples}.lean`, `.../PlusWitnessFamily/README.md`
  - Branching substrate (read): `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/{Skeleton,Basic,Predicates}.lean`, `.../Sharing/README.md`
  - Deterministic compression template (read): `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/{Types,Extract,Family,Enumerate,Assembly}.lean`, `.../Compression/README.md`, `.../WitnessFamily/README.md`
  - Semantics (read): `FormalSystem/Semantics/{IntTransfer,IntNormalForm,TruthTransport}.lean`, `FormalSystem/Semantics/Frames/TranslationProduct.lean`, `FormalSystem/PlusLanguage/{PlusPasting,PlusNonValidities,PlusValidity,PlusTruth,Formula}.lean`
  - Prior artifacts: `specs/684_agreement_lemma_over_all_walks/summaries/01_stability-quantifier-collapse-summary.md`, task records for 623/683/684/690/693 in `specs/state.json`
  - Machine checks: four `lean_run_code` runs against the pinned toolchain, landed as one probe file
- **Artifacts**:
  - `specs/685_stability_compression_and_assembly/reports/01_stability-compression-and-assembly.md`
  - `specs/685_stability_compression_and_assembly/probes/01_snce_stab_incompleteness.lean`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Project Context

- **Upstream Dependencies**: `PlusWitnessFamily/` (the six conditions, `plusTruth_iff_mem`, `decidablePlusCertifies`), `WitnessFamily/Sharing/Skeleton.lean` (the branching substrate), `WitnessFamily/Compression/` (the deterministic route, landed and sorry-free)
- **Downstream Dependents**: the cross-repository A1 conformance work (task 693) reads the deterministic `exists_witnessFamily_of_not_validZTime`; an L⁺ analogue would be the stability-modal row of the same obligation
- **Alternative Paths**: the monadic-second-order route (closed: no bound), the finite-presentation small-model route (closed: `Probe476.fmp_false`)
- **Potential Extensions**: a redesigned branching substrate carrying an explicit transition relation (see Recommendations)

## Executive Summary

- **The deliverable as stated is false, and this is machine-checked, not conjectured.** No
  `PlusSharingWitnessFamily` satisfies `PlusCertifies` for any instance of the schema
  `(g S e) → ⊡(g S e)`, at any time and at **any size**; and one such instance, `Pp → ⊡Pp`, is a
  genuine ℤ-time non-validity. So the L⁺ analogue of
  `Compression/Family.lean`'s `exists_witnessFamily_of_not_validZTime` cannot be proved against
  the landed six conditions. The failure is not about the magnitude of a bound — for these
  targets the certificate class is empty.
- **Root cause, isolated to one clause.** (C1') `PlusLocalCoherentShare`'s `snce` clause
  quantifies its predecessor universally over the `share`-class at the *same* time `t`. Read
  twice, it forces any two indices naming the same world state at `t` to agree on every `snce`
  formula of the closure — so in every presented model past-tense truth is a function of the
  world state, and every presented model validates `Pψ → ⊡Pψ`. The `untl` clause has no such
  consequence, because it quantifies over the class at `t+1` rather than at `t`; the asymmetry
  traces to `Thread`'s deliberately *tight* step field.
- **Only three conditions are involved.** The refutation uses (C1')'s `imp`/`bot`/`snce` clauses,
  (C4) `PlusTarget` and (C5) `StabFaithful`. It is independent of (C0), (C2') and (C3), of every
  bound, and of where the target sits — the premise placement `Γ = [¬φ], Del = []` is refuted
  too, so "reformulate the target" is not an escape.
- **The compression route the task names is otherwise sound and its enabling tools are landed.**
  Recombination in an arbitrary ℤ-time model is free (`IntNormalForm.lean`'s
  `mem_HF_iff_adjacent` / `worldHistoryOfStepPath`), single-seam pasting is free
  (`PlusPasting.lean`'s `paste`), recurrence-freedom is free
  (`plusValidIn_iff_recurrenceFree`, `frame_recurrenceFree`), and a seven-case `PlusTruthAt`
  induction template exists (`TranslationProduct.lean`'s `plus_invariance`). What is missing is a
  *correct* condition set to compress into.
- **Two prerequisites are absent even after a redesign**: there is no L⁺ carrier normalization
  (`ValidInt` / `validZTime_iff_validInt` exist for `Formula` only — compression step 0 of the
  deterministic route), and `PlusWitnessFamily/` has no `Compression/` subtree at all (no
  `plusTypeAtM`, no type-space pigeonhole, no candidate enumeration, no assembly).
- **Zero-debt verdict**: there is no sorry-free path to the stated deliverable, because the
  statement is false. Recommended disposition is to land the refutation plus the redesign
  specification and re-scope, not to attempt the theorem. A `user_decision` is raised for the
  scope fork.

## Context & Scope

The task asks for the stability-modal analogue of the deterministic compression theorem: from
`¬ PlusValidZTime φ`, produce a branching witness structure satisfying the redesigned conditions
whose size is bounded by a computable function of the closure size, plus the assembly step (a
formula-indexed candidate list and `Decidable (PlusValidZTime φ)` by reduction to "no candidate
is accepted").

The landed state this research had to assess:

- The **soundness half for L⁺ is complete**. `PlusWitnessFamily/` carries `PlusLabelledLasso`,
  `PlusWitnessFamily`, `PlusSharingWitnessFamily`, the six conditions (C0)-(C5), the truth lemma
  `plusTruth_iff_mem` (seven cases, `stab` case consuming (C5)), the bundle `PlusCertifies`,
  `decidablePlusCertifies`, and the producer `plusRefutes_of_certifies`.
- The **deterministic completeness half is complete** at `Formula`:
  `WitnessFamily/Compression/` with `compressionBound`, `exists_witnessFamily_of_not_validZTime`,
  `cands`/`mem_cands_of_bounded`, `validZTime_iff_noCertifiedCandidate` and
  `Compression.decidableValidZTime`, all sorry-free.
- The **branching completeness half does not exist** for either language. The only producer of a
  branching `Certifies` anywhere in the tree is `Sharing/Specialize.lean`'s
  `certifies_toSharing`, i.e. the deterministic diagonal where `share u i j ↔ i = j` — the one
  instance on which (C5) provably collapses to `⊡φ ↔ φ`
  (`Examples.lean`'s `stabFaithful_diagonal`). There is **no landed example** of any family
  satisfying the full six-condition bundle with non-trivial sharing;
  `Examples.lean`'s `stabFamily_separates` establishes (C5) alone on its family, not (C1') or
  (C2').

Both closed routes named in the task description were confirmed closed and not retried.

## Findings

### F1. The stated theorem is refuted [MACHINE-CHECKED]

All declarations below are in
`specs/685_stability_compression_and_assembly/probes/01_snce_stab_incompleteness.lean` and were
run green through `lean_run_code` against the pinned toolchain.

- `Probe685.no_certificate (g e : PlusFormula) (S : PlusSharingWitnessFamily [] [tgt g e]) (t : ℤ) : ¬ S.PlusCertifies t`
  where `tgt g e = (g S e) → ⊡(g S e)`. Universally quantified over `g`, `e`, the family and the
  time: no such certificate exists at all.
- `Probe685.no_certificate_premise_form` — the same conclusion with the target as a negated
  premise (`Γ = [¬ tgt g e]`, `Del = []`).
- `Probe685.not_plusValidZTime_instance (p : Atom) : ¬ PlusValidZTime (tgt ⊤ p)` — the instance
  `Pp → ⊡Pp` is a genuine ℤ-time non-validity, on the permissive frame
  `PlusNonValidities.NF` (`FrameOver.natFrame (D := ℤ)`, whose `FrameClass.ZTime.Sat` is
  `⟨inferInstance, TaskFrame.isZTime_of_instances _⟩`) with the two histories
  `refute_somePast_stab` already uses.

Taken together: the target statement
`¬ PlusValidZTime φ → ∃ (S : PlusSharingWitnessFamily [] [φ]) (t : ℤ), (bounds) ∧ S.PlusCertifies t`
has a counterexample at `φ := Pp → ⊡Pp`. The assembly step inherits the failure: the criterion
`plusValidZTime_iff_noCertifiedCandidate` would be false in its backward-contrapositive
direction, so `Decidable (PlusValidZTime φ)` does not follow from this device either.

### F2. Root cause: (C1')'s `snce` clause makes past truth state-determined [MACHINE-CHECKED]

`Probe685.snce_state_determined` is the whole mechanism, and it is two readings of one clause:

- `Predicates.lean:95-98` — (C1')'s fifth clause reads
  `∀ k, S.share t i k → ∀ g e, snce g e ∈ plusClosureOf (Γ ++ Del) → (snce g e ∈ S.L i t ↔ unfolding at (k, t-1))`.
  The class quantified is at time `t`, the *same* time as `i`'s own label.
- Instantiating at `(i, t)` with `k := j`, and at `(j, t)` with `k := j` (by `share_refl`), gives
  two biconditionals with an identical right-hand side. Hence
  `snce g e ∈ S.L i t ↔ snce g e ∈ S.L j t` for every `j` sharing the state at `t`.

Consequences:

- Every presented model has past-tense truth determined by the world state at that time, so
  `Pψ → ⊡Pψ` is *valid* in every presented model, while it is not ℤ-time valid. The device is
  **incomplete**, not unsound.
- (C5) can therefore only ever have content at formulas the class is permitted to disagree on.
  By the same double reading, the class at `t` is forced to agree on atoms (by (C0)), on `box`
  formulas (by (C1')'s third clause, both sides equal `S.bx χ`) and on `snce` formulas (F2). It
  is **not** forced to agree on `untl` formulas: (C1')'s fourth clause quantifies `j` over the
  class at `t+1`, and two indices sharing at `t` may sit in different classes at `t+1`. That is
  exactly the room `Examples.lean`'s `stabFamily_separates` occupies — it separates `Fp` from
  `⊡Fp`, a future eventuality. (The `untl` side being defect-free is an inspection result here,
  not a machine-checked one.)
- The asymmetry is inherited from `Skeleton.lean`'s `Thread`, whose step field is the *tight*
  `share (u+1) (idx u) (idx (u+1))`. A thread renames the state it **arrives at**, so its index
  at `u` may be chosen knowing the forward step (which the substrate's own header records as
  costing nothing) — but its predecessor index is thereby forced into `i`'s class at `u`, which
  is what collapses backward branching.

### F3. What the redesign has to change

The defect is not repairable by re-wording (C1'). For the truth lemma's `snce` case, the
unfolding must hold at the particular predecessor each thread uses; with the tight step field the
set of possible predecessors *is* the class at `t`, so the universal quantifier is forced and the
agreement follows. The fix has to be at the substrate level:

- Add an **explicit periodic transition relation on indices** to `SharingSkeleton` — a fourth
  three-segment datum `transBack`/`transMid`/`transFwd`, decoded by the same
  `Periodic.unrollOf` scheme, giving `trans u : Fin n → Fin n → Prop` — and define `Thread`'s
  step as `trans u (idx u) (idx (u+1))` rather than as `share (u+1) (idx u) (idx (u+1))`.
- `share` then keeps its present role (the `⊡` quantifier, the quotient carrier, (C0), (C5))
  while `trans` carries the one-step branching. (C1')'s two temporal clauses become "over every
  `trans`-successor at `t+1`" and "over every `trans`-predecessor at `t-1`", and two indices
  sharing a state at `t` may have different `trans`-predecessors — which is precisely what
  restores the ability to refute `Pp → ⊡Pp`.
- Downstream re-proof surface, all of which currently derives the transition from "ride the same
  index": `Sharing/Skeleton.lean` (`Thread`, `Step`, `ReachN` and its four congruences, the
  quotient frame, its four `def:frame` constraints, `total_eq_thread`), `Sharing/Predicates.lean`
  and `PlusWitnessFamily/Predicates.lean` ((C1'), (C2')), `Sharing/Decide.lean` and
  `PlusWitnessFamily/Decide.lean` (the window collapses), `Sharing/Fulfil.lean` and
  `PlusWitnessFamily/Fulfil.lean` (the position graph and the `A[g U e]` fixpoint — the largest
  single body, 1669 + 1093 lines), `Sharing/Agreement.lean` and
  `PlusWitnessFamily/Agreement.lean` (the two inner inductions and the truth lemma), and
  `Sharing/Specialize.lean` (the diagonal, now `trans u i j ↔ j = i` as well as `share = Eq`).
  The export contract gains three fields, exactly as `repBack`/`repMid`/`repFwd` did.
- A **non-vacuity obligation** the present tree does not discharge and the redesign must: one
  concrete family satisfying all six conditions at non-trivial sharing. Its absence today is why
  the incompleteness went unnoticed — `stabFamily_separates` checks (C5) in isolation.

### F4. Prerequisites for the compression proper, absent regardless of the redesign

- **No L⁺ carrier normalization.** `Semantics/IntTransfer.lean` supplies `ValidInt` and
  `validZTime_iff_validInt` for `Formula` only; `Semantics/TruthTransport.lean`'s `TruthCorr` and
  `truthAt_of_truthCorr` are a six-case induction over `Formula`. The deterministic compression
  opens with this normalization ("compression step 0 and it is free"). An L⁺ analogue needs
  either a `PlusTruthCorr` with a state-agreement field or a direct seven-case
  `plusTruthAt_map`; the `stab` case goes through on `Aligned` because
  `(FrameOver.map F e).WorldState` is definitionally `F.WorldState`, so
  `WorldHistory.comap` + `aligned_comap` transport the state-agreement side condition.
  `TranslationProduct.lean`'s `plus_invariance` is the in-tree template for the seven-case shape,
  `stab` case included.
- **No L⁺ `Compression/` subtree.** Every module of the deterministic route needs an L⁺ twin:
  `plusTypeAtM` and the two sequence-level predicates (`Types.lean`), the type-space pigeonhole
  and good cycles (`Cycle.lean`), the propagation and iterated periodicities (`Fulfil.lean`), the
  three-segment ℤ geometry and the bound (`Extract.lean`), the canonical enumerable box guess
  (`Family.lean`), the candidate list (`Enumerate.lean`), the assembly (`Assembly.lean`). The
  closure interface to reproduce is the nine declarations `WitnessFamily/README.md` enumerates,
  plus `plusClosureOf_stab` — ten, and the L⁺ closure already exports all ten.

### F5. The bound shape, for whenever the conditions are fixed

- The deterministic bound is `compressionBound Γ Del = max (cycleBoundC C) (midBoundC C)` with
  `midBoundC C = 2 * 2 ^ C.card` (`Extract.lean:298-312`), and `Enumerate.lean` sweeps every
  triple in `[0, B]³`.
- The branching generalization pigeonholes over **configurations**, not types: a configuration at
  a time is a labelling `Fin n → Finset C` together with the idempotent representative map
  `Fin n → Fin n` (and, after the redesign, the transition relation on `Fin n`). All three are
  finite, so the pigeonhole and the good-cycle machinery transfer in shape. Index count: one main
  lasso, at most `|C|` box witnesses for (C3), and at most `|C|` stability witnesses per class
  for (C5) — so `n` bounded by a polynomial in `|C|`, and the configuration space by
  `(2^{|C|})^n · n^n · 2^{n²}`. Doubly exponential in `|C|`, which still satisfies "a computable
  function of the closure size".
- **The bound must stay an upper bound swept over a grid, never a lower bound.** Both
  `Compression/README.md` and `WitnessFamily/README.md` record the measured non-monotonicity on
  the consuming side: the registry folds `back`/`mid`/`fwd` by **exact modulus**, so a search at
  bound `n` represents exactly the periods dividing `n` (one formula SAT at `(3,1,3)` and
  `(6,1,6)`, genuinely UNSAT at `(4,1,4)` and `(5,1,5)`). Representability is a divisibility
  question, not a magnitude question. A branching bound adds a fourth and fifth dimension
  (`repBack`/`repMid`/`repFwd`, and the transition segments) to the same grid.

### F6. Enabling tools that are landed and should not be rebuilt

- `Semantics/IntNormalForm.lean:348` `FrameOver.mem_HF_iff_adjacent` and `:323`
  `worldHistoryOfStepPath` — over ℤ, `H_F` is *exactly* the set of bi-infinite one-step paths. So
  an arbitrary recombination of model histories at shared states is itself a genuine model
  history, with no frame-class side condition. This is the model-side analogue of
  `total_eq_thread` and it is what makes a branching extraction possible at all.
- `PlusLanguage/PlusPasting.lean` `paste` / `paste_rel` — single-seam pasting from
  *Compositionality* and the reflection convention alone, plus `AgreeFrom`/`AgreeUpTo` and the
  two purity congruences.
- `Semantics/Frames/TranslationProduct.lean:597` `plusValidIn_iff_recurrenceFree` and
  `Sharing/Stability.lean` `frame_recurrenceFree` — recurrence-freedom is available on both
  sides, so only the *type* sequence need be eventually periodic, not the state sequence.
- `Sharing/Stability.lean` `stabQuant_iff_share_class` — the stability quantifier does not range
  over walks; it collapses to a finite quantifier over the `share`-class. Unaffected by F2, since
  it is a statement about the presented frame.

## Decisions

- **Recorded the refutation as the round's primary result rather than attempting the theorem.**
  A compression proof against the landed conditions is unreachable, and the zero-debt policy
  forbids landing a `sorry` to stand in for it. The probe is the deliverable a downstream planner
  can act on.
- **Wrote the refutation at the schema level (`∀ g e`) rather than at `Pp → ⊡Pp` alone**, and
  added the premise-placement variant, so that the two obvious dodges — "pick a different
  instance", "move the target into `Γ`" — are closed in the artifact rather than in prose.
- **Factored the probe through `snce_state_determined`** so the root cause is a named lemma
  rather than an inlined step; that lemma is the statement a redesign has to falsify.
- **Did not run a `lake build`.** Nothing in `FormalSystem/` was modified this round; the probe
  lives under `specs/` and was verified through `lean_run_code` against the existing `.olean`
  cache. This also avoids contending with the concurrent sibling declared in the dispatch
  territory block.
- **Did not treat the deterministic `Compression/` route as suspect.** It is stated at `Formula`,
  which has no `⊡`, and its device has `share = Eq`; F2 cannot reach it.

## Recommendations

Priority order. Owner is the next dispatch in each case unless noted.

1. **Land the refutation into the library, not only into `specs/`.** Promote the probe to a
   module beside the device it constrains — the natural home is
   `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` — following the
   precedent of `Probe476.fmp_false`, which is cited by name in three READMEs. Add the
   corresponding scope sentences to `PlusWitnessFamily/README.md` (the six-conditions table's
   (C1') row and a new incompleteness section) and to
   `WitnessFamily/Sharing/README.md` ("Which conditions break under recombination" — the table
   currently presents (C1') as the *fix*, which F2 shows is only half true).
2. **Re-scope this task.** Its stated deliverable is unreachable; the compression and assembly
   work should be re-created as a dependent of the substrate redesign, not attempted now. See
   the `user_decision` on `.return-meta.json`.
3. **Spawn the substrate redesign as its own task**, scoped by F3: the fourth periodic datum, the
   `Thread` step change, and the named downstream re-proof surface. Size it against
   `Sharing/Fulfil.lean` (1669 lines) and `PlusWitnessFamily/Fulfil.lean` (1093 lines), which
   dominate. Require, as its non-vacuity gate, one concrete family satisfying all six conditions
   at non-trivial sharing plus a `#guard` that the redesigned (C1') no longer entails
   `snce_state_determined`.
4. **Spawn the L⁺ carrier normalization as a separate, independent task** (F4, first bullet). It
   is bounded, useful regardless of the redesign's outcome, and blocked on nothing:
   `plusValidZTime_iff_plusValidInt` by a seven-case induction on the `plus_invariance` template.
5. **Do not let the cross-repository record inherit the gap.** The A1 conformance work (task 693)
   reads the *deterministic* compression, which is unaffected. But any document that presents the
   branching device as the stability-modal route to decidability now needs the F2 caveat; the
   consuming repository's adequacy document is the likely site.

## Risks & Mitigations

- **Risk**: the redesign in F3 may not be sufficient — adding `trans` restores the freedom the
  `snce` clause loses, but the truth lemma, (C2')'s fixpoint decidability and the window
  collapses all have to survive it, and the (C2') window reduction already carries a recorded
  (C1')-relative limitation.
  **Mitigation**: gate the redesign on a non-vacuity family *before* re-proving the fixpoint
  layer; the family is cheap and it falsifies or confirms the design in one step.
- **Risk**: the doubly-exponential index count in F5 could make the branching candidate list
  uninstantiable even as a `Decidable`.
  **Mitigation**: none needed for correctness — `Compression/Assembly.lean` already records that
  `cands` is astronomically large and that the cost is the literature's own (GKWZ §6.5,
  EXPSPACE-hardness for `PTL × S5`). `Decidable` is the deliverable, not a usable executable.
- **Risk**: a reader could take F1 as refuting the *soundness* half, or as refuting the
  stability-modal decidability question itself.
  **Mitigation**: both readings are wrong and the probe's header says so. `plusTruth_iff_mem` is
  untouched — a certified family still presents a genuine countermodel. What fails is
  completeness of the certificate class, and only for targets whose closure carries a `snce`
  under a `stab`.
- **Risk**: the `untl` side is asserted defect-free on inspection, not by machine check.
  **Mitigation**: the redesign task should carry the positive obligation (a full six-condition
  family separating `Fp` from `⊡Fp`) rather than relying on the absence of a refutation.

## Tactic Survey Results

No tactic survey against open proof goals was performed: this round's work was design-level and
refutational, and the four probe proofs were closed by hand. What the probe runs did establish
about tactic behaviour on this surface is worth recording, since it recurs:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `imp` clause split (`¬(a ∈ L → b ∈ L)` to the conjunction) | `tauto` | fail | `(deterministic) timeout at whnf` at 200000 heartbeats — `tauto` unfolds `PlusFormula` label membership |
| the same split | explicit `fun h => …` + `by_contra` | success | no `set_option maxHeartbeats` needed |
| `tgt p ∈ [tgt p]` | `simp` | fail | leaves `(pastP p).imp (pastP p).stab = tgt p` unsolved |
| the same | `List.mem_singleton_self _` | success | — |
| negating (C5)'s `∀ j` to get a witness | `push_neg` | success but blocking-lint | deprecated in favour of `push Not`; repo warning budget treats it as blocking |
| the same | `by_contra` + `refine … (fun j hj => ?_)` | success | avoids the deprecation entirely |
| `¬ PlusValidZTime` on `NF` | `⟨inferInstance, TaskFrame.isZTime_of_instances _⟩` | success | the `FrameClass.ZTime.Sat` idiom, as in `DiscreteNonCompactness.lean:207` |

## Context Extension Recommendations

- **Topic**: the branching-certificate condition set and what each condition can and cannot
  express.
  **Gap**: `context/project/lean4/` has no note on this device. The two in-tree READMEs are the
  only account, and both currently present (C1') as the repair for recombination without
  recording the completeness price it charges. A future agent reading either would re-derive F2
  from scratch — or, worse, plan a compression proof against a false statement, which is exactly
  what this round was dispatched to do.
  **Recommendation**: add `context/project/lean4/domain/branching-certificate-conditions.md`
  recording (a) the six conditions and which are recombination-stable, (b) the
  `snce`-state-determination result with its probe path, (c) the `untl`/`snce` asymmetry and its
  origin in `Thread`'s tight step field, and (d) the rule of thumb that a condition quantifying
  over the `share`-class at a label's *own* time forces class agreement on that label.

## Appendix

### Probe provenance

`specs/685_stability_compression_and_assembly/probes/01_snce_stab_incompleteness.lean`, four
declarations, each run green through `lean_run_code`:
`snce_state_determined`, `no_certificate`, `no_certificate_premise_form`,
`not_plusValidZTime_instance`. No `sorry`, no new axiom, no `set_option maxHeartbeats`.

### Declarations consulted, by path

- `PlusWitnessFamily/Predicates.lean:71` (C0), `:84` (C1'), `:143` (C2'), `:195` (C3), `:205`
  (C4), `:276` (C5); `:294` `stabFaithful_share_congr`
- `PlusWitnessFamily/Agreement.lean:183` `plusTruth_iff_mem`, `:325` `PlusCertifies`, `:333`
  `decidablePlusCertifies`, `:371` `PlusRefutes`, `:413` `plusRefutes_of_certifies`
- `PlusWitnessFamily/Basic.lean:65` `PlusLabelledLasso`, `:161` `PlusWitnessFamily`, `:220`
  `PlusSharingWitnessFamily`, `:343` `total_eq_thread`
- `PlusWitnessFamily/Closure.lean:59` `plusClosureOf`, `:141` `plusClosureOf_stab`, `:151`
  `plusPremise_mem_closure`, `:156` `plusConclusion_mem_closure`
- `PlusWitnessFamily/Examples.lean` `stabFaithful_diagonal`, `stabFamily_separates`
- `WitnessFamily/Sharing/Skeleton.lean:301` `Thread`, `:325` `Thread.const`, `:337` `Step`
- `WitnessFamily/Sharing/Basic.lean` `SharingWitnessFamily`, `rep`, `share`, `share_refl`
- `WitnessFamily/Compression/Extract.lean:298` `midBoundC`, `:311` `compressionBound`, `:342`
  `exists_labelledLasso_of_history_realized`, `:579` `exists_labelledLasso_of_history`
- `WitnessFamily/Compression/Family.lean` `exists_witnessFamily_of_not_validZTime`
- `WitnessFamily/Compression/Enumerate.lean:245` `cands`, `:258` `mem_cands_of_bounded`
- `WitnessFamily/Compression/Assembly.lean` `validZTime_iff_noCertifiedCandidate`,
  `Compression.decidableValidZTime`, `decidableSemanticConsequenceNil`
- `WitnessFamily/Compression/Types.lean` `typeAtM`, `LocalCoherentSeqLab`, `FulfillingSeqLab`
- `Semantics/IntTransfer.lean:315` `ValidInt`, `:335` `validZTime_iff_validInt`, `:252` `Aligned`,
  `:281` `alignedCorr`, `:300` `truthAt_map`
- `Semantics/IntNormalForm.lean:323` `worldHistoryOfStepPath`, `:348` `mem_HF_iff_adjacent`
- `Semantics/TruthTransport.lean:92` `TruthCorr`, `:122` `truthAt_of_truthCorr`
- `Semantics/Frames/TranslationProduct.lean:472` `plus_invariance`, `:597`
  `plusValidIn_iff_recurrenceFree`
- `PlusLanguage/PlusPasting.lean:80` `pasteFun`, `:99` `paste_rel`, `:111` `paste`
- `PlusLanguage/PlusNonValidities.lean:70` `NF`, `:73` `natHist`, `:83` `natModel`, `:186`
  `refute_somePast_stab`
- `PlusLanguage/PlusValidity.lean:111` `PlusValidZTime`; `PlusLanguage/Formula.lean:143`
  `somePast`
- `Metalogic/DiscreteNonCompactness.lean:207` — the `FrameClass.ZTime.Sat (natFrame (D := ℤ))`
  idiom

### External references

- Gabbay, Kurucz, Wolter, Zakharyaschev 2003, *Many-Dimensional Modal Logics*: Thm 11.26 and
  11.45 (the compression criterion and the `s₁·s₂·s₃^ω` lasso shape over `(ℕ,<)`) are the
  deterministic route's structure; Thm 11.7 / 11.21 is the non-constructive MSO/Rabin route and
  is not on this path; §6.5 is the EXPSPACE-hardness lower bound cited for the cost.
- Thomason 1984 §4 (Kamp's AK12) and Reynolds 2003 (HN) — the T×W / Ockhamist tense-modal
  interaction axiom whose `⊡`-analogue `PlusNonValidities.refute_somePast_stab` refutes. The
  refutation this round found is the certificate-side shadow of the same failure of backward
  closure.
