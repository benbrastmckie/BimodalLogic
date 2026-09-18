# Research Report: Task #476

**Task**: 476 - The box-faithful small-model theorem
**Started**: 2026-09-18T19:17:00Z
**Completed**: 2026-09-18T20:05:00Z
**Effort**: Literature gate plus refutation probe: done. Replacement route (quasimodel / ShiftSet witness family): about 3-6 weeks of Lean work, estimated below.
**Dependencies**: Both prerequisites are archived as completed. They are the BiLasso wiring task (474) and the carrier-normalization task (475).
**Sources/Inputs**: - Codebase (`BiLasso/*`, `IntPresentation.lean`, `Semantics/ShiftSet.lean`, `Semantics/Truth.lean`, `Semantics/Validity.lean`, `Semantics/IntNormalForm.lean`), the lean-lsp MCP (`lean_run_code` only, with no `lake build` per the user's constraint), and literature: Gabbay, Kurucz, Wolter, Zakharyaschev, *Many-Dimensional Modal Logics* (2003), from the local corpus `~/Projects/Literature/sources/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics/`
**Artifacts**: - specs/476_box_faithful_small_model_theorem/reports/01_box-faithful-literature-gate.md
- specs/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The literature gate fired, and the target is refuted.** A new machine-checked counterexample
  shows that the task's target theorem is **false for every candidate list**:

      ¬ (∀ φ, ¬ ValidZTime φ → ∃ P ∈ cands φ, ∃ w, SatAtState P w φ.neg)

  This is `Probe476.fmp_false` in
  `specs/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`. I checked
  it with `lean_run_code` against the live tree. It is sorry-free and uses the axioms
  `[propext, Classical.choice, Quot.sound]`. (`ValidDiscrete` in the task text is now named
  `ValidZTime`.)
- **The witness formula** is ψ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp). In words: "every history meets
  `p`, and a `p`-time has no earlier `p`-time."
  - ψ is satisfiable over ℤ-time. The model is the shift set on carrier ℤ with `sh w d = w + d`
    and `p` true only at state `0`, so `¬ ValidZTime ψ.neg`.
  - No `IntPresentation` satisfies ψ at any history or time. The proof is a pumping argument:
    the p-free stretch left of a history's `p`-time repeats a state, and that cycle, run forever
    in both directions, is itself a history (every walk of a presentation is a history). That
    history never meets `p`.
- **The literature agrees and places the failure where the task feared.**
  - GKWZ Theorem 5.30: `Log_US(C) × L` lacks the (abstract) finite model property whenever `C`
    contains (N,<) or (Z,<) and `L` has an infinite rooted frame, which includes S5.
  - GKWZ Theorem 5.32: `Log(C) × L` lacks the *product* fmp for transitive `C` with an ascending
    ω-chain.
  - GKWZ Question 6.62: whether `Log{(N,<)} × S5` has the fmp was left open.
  - TM over ℤ is not a product, so these results are evidence, not a decision. The refutation
    above is the decision.
- **Decidability of `ValidZTime` is NOT refuted, and very likely holds.** It needs a different
  kind of small model. By the literature:
  - GKWZ Theorem 3.29 reduces `Log_US(C) × S5` to the one-variable fragment of first-order
    temporal logic.
  - GKWZ Theorems 11.7/11.21 decide that fragment over (Z,<), among other time flows.
  - Theorem 6.64 gives EXPSPACE-completeness for PTL × S5.
  - TM's box is the universal modality (`Truth.box_const`), and the tree's `ShiftSet`
    representation theorem makes TM-over-ℤ models the same thing as arbitrary shift-closed run
    sets. So TM-over-ℤ embeds into `Log_US(Z) × S5`, with □χ ↦ □_S5(Hχ ∧ χ ∧ Gχ).
- **Recommended approach:** abandon or close task 476 as refuted, and open a separate task for
  the quasimodel route (below). The task text forbids agents from re-describing it, so I am not
  re-scoping it myself. This is raised as a blocking `user_decision`.

## Context & Scope

The dispatch asked for the literature gate first, and gave it the power to stop the task. I
followed that order:

1. Read GKWZ 2003 (Ch. 5.3, 6.4-6.6 and the Chapter 6 summary tables, Ch. 7 intro, Ch. 11.1-11.3).
2. Checked the live semantics: `TruthAt`'s box clause, `IntPresentation`, `SatAtState`,
   `ValidZTime`, `ShiftSet`.
3. Built a Lean probe to confirm or refute the target directly.

Per the user's constraint, I ran no `lake build` or `lean_build`. Every Lean check went through
`lean_run_code` against the current oleans.

## Findings

### Codebase Patterns

- `TruthAt` (`Semantics/Truth.lean:237`): `box φ` means `∀ σ : WorldHistory F, TruthAt M σ t φ`.
  Combined with `Truth.box_const`, box is the universal modality over all (history, time) pairs.
- `IntPresentation` (`Decidability/IntPresentation.lean`): a finite graph on `Fin card`. Its
  histories are **exactly all bi-infinite walks** (`isStepPath_iff` + `mem_HF_iff_adjacent`).
  This is the structural cause of the refutation: a presentation cannot rule out walks that loop
  on a cycle forever.
- The same pumping argument refutes more than `IntPresentation`: it applies to any ℤ-frame with a
  finite `WorldState`, because histories over ℤ are exactly step paths (`mem_HF_iff_adjacent`).
  So "finite frame" is the wrong kind of small model for TM over ℤ, not just this particular
  presentation format. (The probe proves the `IntPresentation` case; the general finite-frame
  case follows by the identical argument through `mem_HF_iff_adjacent` and was not separately
  mechanized.)
- `ShiftSet` (`Semantics/ShiftSet.lean`) provides:
  - `forward_repr`: every shift set induces a task model whose truth matches `ShiftTruth`.
  - `reverse_repr`: every task model is a shift set.
  - `total_eq_orbit`: the histories of `S.frame` are exactly the orbits.

  This is the right carrier for a small model. A **finite disjoint union of ℤ-orbits of
  eventually-periodic words** has no extra histories, so box truth is exactly what the witnesses
  say, and box-faithfulness holds by construction.
- `Assembly.lean` states the `fmp` hypothesis in precisely the refuted shape. Both its docstring
  and the BiLasso `README.md` call `fmp` "the one open theorem" between the layer and
  decidability. That is now known to be false.
- `truth_along_annot` (`BiLasso/TruthLemma.lean`) is parameterized by an oracle
  `bx : Formula → Bool` with `BoxOracleSound P bx`, which ties `bx` to the presentation's own
  histories. The replacement route keeps `LocalCoherent`/`Fulfilling` (already parameterized by
  `bx`) but interprets box via a *guessed* `B`, in a shift-set model built from the witnesses.

### External Resources

GKWZ 2003 results, located by chunk in the local corpus:

- Theorem 5.30 (chunk 0274): `Log_US C × L` has no abstract fmp for C ∋ (N,<) or (Z,<).
- Theorem 5.32 (chunk 0275): no product fmp for transitive linear time with an ascending ω-chain.
- Theorems 6.60, 6.63 and 6.64 (chunks 0351-0357): `Log{(N,<)} × S5` and `PTL × S5` are in
  EXPSPACE and are EXPSPACE-complete. Theorem 6.61: K4.3/Lin/Log(Q) × S5 are in 2EXPTIME, by
  quasimodel "block elimination". That iterated-elimination algorithm is the template for the
  replacement route.
- Question 6.62 (chunk 0353): the fmp of `Log{(N,<)} × S5` is open. Note that PTL here means
  Until-only over (N,<), and `Log_US` adds Since.
- Theorem 3.29 (chunk 0193): `Log_US(C × S5)` corresponds to the one-variable fragment
  `QLog_US(C) ∩ QTL¹`.
- Theorems 11.7 and 11.21 (chunks ~0470-0490): monodic and one-variable QTL fragments are
  decidable over (N,<), **(Z,<)**, (Q,<), and first-order-definable classes, via reduction to
  monadic second-order logic plus realizable "state candidates" (quasimodels).
- Theorem 7.2 (chunk 0365): products of *two* linear time flows are undecidable. This is not
  TM's case: TM has one temporal dimension plus one universal/S5 dimension.

### Recommendations

1. **Record the refutation.** Move the evidence file under the evidence-probe guard if the
   project wants it wired. Update the `Assembly.lean` docstring and the BiLasso `README.md`,
   which currently call `fmp` "open" and "genuinely hard". It is **false**. The assembly
   theorems remain valid as implications, but their hypothesis is uninhabitable.
2. **Replacement route to `Decidable (ValidZTime φ)`, the quasimodel / witness-family
   certificate.** Everything below is standard mathematics, not open research:
   - *Certificate*:
     - a box guess `B ⊆ {χ | □χ ∈ subformulaClosure φ}`;
     - a finite list of annotated bi-lassos over the closure-type space, each `LocalCoherent`
       with `bx := B` and each `Fulfilling`;
     - "B-closure": `B χ` forces `χ ∈ label t` at every position of every witness;
     - "B-witnessing": for each `□χ` in the closure with `¬B χ`, some witness has `χ ∉ label` at
       some position;
     - one witness has `φ.neg` in some label.
   - *Soundness* (certificate ⇒ `¬ ValidZTime φ`): build a `ShiftSet intOrder` with carrier
     `Σ i : Fin k, ℤ`, `sh (i,n) d = (i, n+d)`, and valuation read off the labels. Prove a truth
     lemma analogous to `truth_along_annot`, where the box case uses B-closure and B-witnessing
     plus `forward_repr`/`total_eq_orbit`. Close with the five-line ℤ refutation, as in
     `not_validZTime_neg_psi`.
   - *Completeness* (`¬ ValidZTime φ` ⇒ some certificate exists):
     - Use `validZTime_iff_validInt` (IntTransfer) to get a ℤ-countermodel.
     - Take `B` as the model's actual box facts, which are constants by `box_const`.
     - Pick witness histories for `φ.neg` and for each failing `□χ`.
     - Their closure-type sequences are locally coherent and fulfilling. This is a
       `SmallModel.lean` analogue over an arbitrary ℤ-model rather than a presentation.
     - Compress each sequence to a bi-lasso by two-sided pigeonhole on the types, reusing the
       `GoodCycle.lean` eventuality-propagation / `cycleBound` machinery on the *type graph*
       rather than a presentation's state graph.
     - Compression keeps B-closure (it holds pointwise) and B-witnessing (keep the witnessing
       position inside the window, as `Extraction.lean` already does for its point of
       interest).
   - *Decision*: enumerate the finite set of `B` guesses and the bounded bi-lassos over types.
     `Enumerate.lean` / `Decide.lean` already make `LocalCoherent`/`Fulfilling` decidable on an
     annotation.
   - *Why box-faithfulness disappears*: the target model contains only the witness orbits, never
     a graph's full path set, so there is no subshift of unrealized paths.
3. **A sorry-free path exists** for the replacement route. No axioms and no deferral are needed.
   The main new proofs are the shift-set truth lemma and the type-level compression.

## Decisions

- **I treated the gate result as decisive.** The task text says that a recorded failure of the
  fmp means "THIS TASK IS REFUTED and must be REPORTED AS SUCH". GKWZ 5.30/5.32 record that
  failure for the closest product logics, and the probe proves the target itself false. So this
  report does not propose a plan for the original target.
- **I did not re-describe task 476.** The task text forbids agents from doing so. The re-scope
  goes to the user as a `user_decision`.
- The refutation witness was chosen to need only `A` (□(p ∨ Fp ∨ Pp)) and `C` (□(p → ¬Pp)). A
  "no later p" conjunct is unnecessary.

## Risks & Mitigations

- **Risk: the probe checked against stale oleans** while another session rebuilds.
  - *Mitigation*: the probe uses only stable APIs (`ShiftSet`, `IntPresentation`,
    `worldHistoryOfStepPath`, `SatAtState`, `ValidZTime`). Re-run
    `lake env lean specs/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
    once the rebuild lands.
- **Risk: the replacement route's completeness direction needs a type-level analogue of
  `SmallModel.lean` over an arbitrary ℤ-model.**
  - *Mitigation*: the existing code uses `P` only for the step relation and valuation. Type
    sequences of any `TaskModel` over ℤ satisfy the same local clauses by `Unfold.lean`'s
    one-step unfolding, which is stated at ℤ.
- **Risk: expecting choice-freedom.**
  - *Mitigation*: none is claimed. `ShiftSet` routes and the probe both use `Classical.choice`,
    consistent with `wlem_of_saturation`.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `ShiftSet.sep` at carrier ℤ | `Int.abs_lt_one_iff` + `simp` | success | `abs_lt` route failed (cast shape); use `Int.abs_lt_one_iff` |
| `ShiftTruth` of ψ | `simp only [...ShiftTruth]` + `omega` | success | unfold `Formula.and/or/neg/top` |
| pigeonhole on times | `Fintype.exists_ne_map_eq_of_card_lt` | success | `f : Fin (card+1) → Fin card` |
| periodic step `(n+1) % L` | `Int.emod_add_mul_ediv`, `Int.add_mul_emod_self_left`, `Int.emod_eq_of_lt`, `Int.emod_self` | success | `omega` cannot use variable modulus directly |
| `ValidZTime` instantiation | `TaskFrame.isZTime_of_instances _` | success | at `S.frame` with `D = intOrder` |

## Context Extension Recommendations

- **Topic**: Small-model shape for TM over ℤ.
- **Gap**: The context files and the BiLasso README present the finite-graph `fmp` as open. It is
  refuted.
- **Recommendation**: Add a short note to the lean4/logic decidability context: finite-carrier
  frames are the wrong small models for TM over ℤ, and the right shape is finite unions of
  eventually-periodic shift orbits, i.e. GKWZ-style quasimodels.

## Appendix

- Corpus searches: `grep` over GKWZ chunks for "Products with S5", "PTL x S5", "EXPSPACE",
  "finite model property", "Theorem 5.32", "Theorem 11.2x", and "Theorem 3.29".
- Lean probes: five `lean_run_code` runs. The final run compiles `fmp_false` with no errors.
- Key tree declarations: `Truth.box_const`, `ShiftSet.forward_repr`, `ShiftSet.total_eq_orbit`,
  `IntPresentation.isStepPath_iff`, `FrameOver.worldHistoryOfStepPath`,
  `validZTime_iff_checkFamily`, `truth_along_annot`, and `BoxOracleSound`.
