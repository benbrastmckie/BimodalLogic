# Task 98 Implementation Summary (v3, session 4 — Phase 3 completion)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Plan**: specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md (v3)
- **Status**: PARTIAL (Phases 1-3 COMPLETED; Phases 4-8 NOT STARTED)
- **Session**: sess_1775871930_0825da
- **Date**: 2026-04-11

## Outcome

Phase 3 is now **complete**. The previously-deferred
`hintikka_chain_exists` well-founded recursion has landed in
`Construction.lean` as a standalone combinatorial theorem, closing the
Phase 3 scaffolding-versus-recursion gap left by session 3.

Key design: the recursion is parameterised by a `HintikkaStepOracle` — a
propositional predicate delivering, at every Hintikka point carrying the
target defect and missing the witness, a next point that either reaches
the witness or strictly decreases `defect_count`. The oracle abstracts
the derivation-theoretic content (Phase 4 seed consistency + Phase 5
Lindenbaum extension) away from the purely combinatorial termination
argument. This separation keeps Phase 3 fully proved and sorry-free
without waiting on Phases 4-5.

The chain data is stored in a new `HintikkaRawChain Sigma` structure
backed by Mathlib's `List.IsChain`, which supplies the cons/last/head
lemmas for free and avoids the brittle `Fin (length - 1)` indexing
approach sketched in session 3.

## Phase Status

| Phase | Scope | Status | Notes |
|-------|-------|--------|-------|
| 1 | bigconj + EnrichedClosure definitions | COMPLETED | Session 1 |
| 2 | Migrate HintikkaPoint/Construction to EnrichedClosure | COMPLETED | Session 2; Gate A passed |
| 3 | Refined QuasimodelChain + defect_count termination | **COMPLETED** | `hintikka_chain_exists` proved this session |
| 4 | Chain-step seed consistency | NOT STARTED | Phase 4 not attempted — see "Why Phase 4 not attempted" |
| 5 | Realize full chain | NOT STARTED | Gate B not reached |
| 6 | Locus-control exhaustiveness | NOT STARTED | — |
| 7 | Close 6 Realization.lean sorries | NOT STARTED | — |
| 8 | Close 4 Frame.lean sorries | NOT STARTED | — |

## Files Modified

### `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`

- Added import: `Mathlib.Data.List.Chain` (for `List.IsChain` + `IsChain.cons`).
- Replaced the session-3 `QuasimodelChain` `Fin`-indexed step_chain approach
  with a `HintikkaRawChain Sigma` structure backed by `List.IsChain`:

  ```
  structure HintikkaRawChain (Sigma : Finset Formula) where
    points : List (HintikkaPoint Sigma)
    nonempty : points ≠ []
    is_chain : points.IsChain hintikka_step
  ```

- Added `HintikkaRawChain.last`, `.head`, `.singleton`, `.cons`
  with corresponding `_points`, `_head`, `_last` lemmas.
- Defined `HintikkaStepOracle` (Until) and `HintikkaStepOracleSince`:

  ```
  def HintikkaStepOracle {Sigma} (φ ψ : Formula) : Prop :=
    ∀ h : HintikkaPoint Sigma,
      Formula.untl φ ψ ∈ h.formulas → ψ ∉ h.formulas →
      ∃ h' : HintikkaPoint Sigma, hintikka_step h h' ∧
        (ψ ∈ h'.formulas ∨
          (Formula.untl φ ψ ∈ h'.formulas ∧ defect_count h' < defect_count h))
  ```

- **Main theorem** `hintikka_chain_exists`: by strong induction on
  `defect_count h0` via `Nat.strong_induction_on`, given an oracle and a
  starting Hintikka point `h0` with the target Until-defect, there
  exists a `HintikkaRawChain` starting at `h0` whose last point
  contains `ψ`.
- Added `hintikka_chain_guard_step`: the single-step guard lemma
  extracting `φ ∈ h1.formulas` from the `hintikka_step` Until-clause when
  the target is present and the witness is absent.

**Net**: file grew from 440 to 623 lines. Zero sorries. Construction.lean is
now a self-contained Phase 3 module delivering the combinatorial chain
existence theorem.

### Note on the earlier `QuasimodelChain` type

The session-3 `QuasimodelChain` with `target_lhs`/`target_rhs` fields is
preserved in the file because its `target_at_head` + `step_chain`
invariants may still be useful for the Phase 5 realization lemma. The
new `HintikkaRawChain` is a simpler companion type targeting only the
Phase 3 combinatorial claim.

### Plan file

- `specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md`:
  Phase 3 marker flipped from `[PARTIAL]` to `[COMPLETED]`.

## Verification

| Check | Result |
|-------|--------|
| `lake build` (full project) | **PASS** (949/949) |
| New sorries introduced this session | **0** |
| New axioms introduced this session | **0** |
| Sorry count in `Construction.lean` | 0 (only a reference in a comment) |
| Sorry count in `Realization.lean` | 6 (unchanged baseline) |
| Sorry count in `Frame.lean` (Until/Since) | 4 (unchanged baseline) |
| Sorry count in `Completeness.lean` | 1 (unchanged — task 93 scope) |
| Axioms in `Theories/` | 4 (unchanged from baseline) |
| Frame.lean lines 140-583 unchanged | YES |
| TruthLemma.lean unchanged | YES |
| SubformulaClosure.lean unchanged | YES |
| HintikkaPoint.lean unchanged | YES |
| EnrichedClosure.lean unchanged | YES |
| Realization.lean unchanged | YES |
| LocusControl.lean unchanged | YES |
| Construction.lean | MODIFIED (Phase 3 completion) |

## Why Phase 4 Was Not Attempted

Phase 4 (chain-step seed consistency via Teammate A's §3.3 five-step
reduction) requires:

1. `bigconj_intro` and `bigconj_mem_iff` at the `DerivationTree` level
   (deferred by session 1 to Phase 4 "colocation").
2. A contradiction argument composing `g_content_closed_derivation`,
   `sigma_signature_mem` over `enrichedClosure`, and the `hintikka_step`
   G-clause.
3. Plus the Since dual.

Plan v3 budgets 8-15h for this phase and notes it is "tightly coupled to
Phase 5 realization lifting". Phase 3's well-founded recursion proof
consumed substantial context this session (5 failed design iterations
resolving `List.IsChain` imports, `Nat.strong_induction_on` naming,
`Exists`-elimination in `noncomputable def` contexts, and `rcases`
interaction with dependent `Fin` indices). Attempting Phase 4 in the
remaining window would risk either (i) partial-progress sorries that
violate the "zero new sorries" constraint, or (ii) cascading build
failures that leave Phase 3's clean completion in a dirty state.

Per the plan v3 Rollback section and the explicit session-scope
directive ("halt at a clean partial checkpoint"), this session halts
after Phase 3 completion.

## Recommended Next Steps

1. **Follow-up session 1 (Phase 4, ~8-15h)**: Write `bigconj_intro` and
   `bigconj_mem_iff` at the `DerivationTree` level, either in
   `BigConj.lean` or colocated with `Realization.lean`. Prove
   `chain_step_seed_consistent` via the five-step reduction from Teammate
   A §3.3. Add supporting lemmas (`bigconj_mem_hintikka`,
   `neg_bigconj_mem_next_hintikka`, `hintikka_locally_consistent`). Dual
   for Since.

2. **Follow-up session 2 (Phase 5, ~8-14h)**: Prove `realize_chain_step`
   by Lindenbaum extension on the Phase 4 seed. Prove `realize_full_chain`
   by induction on the raw chain. Discharge the
   `HintikkaStepOracle` for the concrete realization setting. Reach Gate B.

3. **Follow-up sessions 3-4 (Phases 6-8, ~25-50h)**: Prove locus-control
   exhaustiveness (or fall back to axiom per Phase 6 mitigation), close
   the 6 Realization.lean sorries, close the 4 Frame.lean sorries.

## Key Technical Choices (Lessons Learned)

- **`List.IsChain` over custom `Fin`-indexed invariant**. The session-3
  `QuasimodelChain` structure used
  `∀ i : Fin (points.length - 1), hintikka_step (points.get ⟨i.val, _⟩) (points.get ⟨i.val + 1, _⟩)`.
  Proving `cons` with this representation requires intricate dependent-Fin
  rewrites that fail on motive checks. `List.IsChain` bypasses the
  indexing entirely — `IsChain.cons` takes a head-option hypothesis and
  conses cleanly.

- **Propositional `∃`-valued theorem, not `noncomputable def`**. A `def`
  returning a `Subtype` cannot use `obtain` on an oracle's `∃` because
  `Exists.casesOn` only eliminates into `Prop`. Restating the theorem as
  a `Prop`-valued existential keeps the recursion clean and lets
  `Classical.choose` extract data at the Phase 5 call site.

- **Strong induction naming**. Mathlib's idiom is
  `Nat.strong_induction_on` (the `_on` suffix is mandatory); `Nat.strongRecOn`
  also works but requires a different syntax.

- **Oracle-based separation of concerns**. By taking the step as a
  propositional oracle, Phase 3 becomes purely combinatorial and can be
  proved in isolation without waiting on Phase 4's derivation-theoretic
  apparatus. Phase 5 will discharge the oracle by constructing steps
  explicitly via Lindenbaum extension on the Phase 4 seed.

## References

- Plan v3: specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md
- Session 1 summary: specs/098_research_filtration_quasimodel_pivot/summaries/03_enrichedclosure-implementation-summary.md
- Session 2 summary: specs/098_research_filtration_quasimodel_pivot/summaries/04_phase2-plus-summary.md
- Session 3 summary: specs/098_research_filtration_quasimodel_pivot/summaries/05_phase3-plus-summary.md
- Round 3 team research: specs/098_research_filtration_quasimodel_pivot/reports/03_team-research.md
- Teammate A (EnrichedClosure construction): 03_teammate-a-findings.md
- Teammate C (gap identification): 03_teammate-c-findings.md
- Teammate D (defect_count termination design): 03_teammate-d-findings.md
