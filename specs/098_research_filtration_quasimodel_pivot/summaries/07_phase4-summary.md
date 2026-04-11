# Task 98 Implementation Summary (v3, session 5 — Phase 4 partial)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Plan**: specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md (v3)
- **Status**: PARTIAL (Phases 1-3 COMPLETED; Phase 4 PARTIAL; Phases 5-8 NOT STARTED)
- **Session**: sess_1775872721_1e9067
- **Date**: 2026-04-11

## Outcome

Phase 4 is now **partially complete**. The two DerivationTree-level scaffolding
lemmas promised by the plan (`bigconj_intro`, `bigconj_mem_iff`) are proved and
in-tree. The chain-step seed consistency theorem itself (`chain_step_seed_consistent`)
remains unproved pending resolution of a Hintikka-point global-consistency gap
that surfaced during architectural analysis (documented in detail below). The
session halts cleanly before attempting the main theorem in keeping with the
plan's "zero new sorries" constraint and the 12h Phase 4 ceiling.

## Phase Status

| Phase | Scope | Status | Notes |
|-------|-------|--------|-------|
| 1 | bigconj + EnrichedClosure definitions | COMPLETED | Session 1 |
| 2 | Migrate HintikkaPoint/Construction to EnrichedClosure | COMPLETED | Session 2; Gate A passed |
| 3 | Refined QuasimodelChain + defect_count termination | COMPLETED | Session 4 |
| 4 | Chain-step seed consistency | **PARTIAL** | DerivationTree helpers proved; main theorem deferred (see "Architectural gap" below) |
| 5 | Realize full chain | NOT STARTED | Gate B not reached |
| 6 | Locus-control exhaustiveness | NOT STARTED | — |
| 7 | Close 6 Realization.lean sorries | NOT STARTED | — |
| 8 | Close 4 Frame.lean sorries | NOT STARTED | — |

## Files Modified

### `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`

- Added imports: `Bimodal.Syntax.BigConj`, `Bimodal.Theorems.Combinators`,
  `Bimodal.Theorems.Propositional`.
- Added a new "Phase 4 Scaffolding" section immediately before the existing
  "Enriched Seed Consistency" section with two `noncomputable def`s:

  ```lean
  noncomputable def bigconj_intro : (L : List Formula) → L ⊢ bigconj L
  ```

  Proof by structural recursion on `L`: empty list yields `⊢ ⊥ → ⊥` via
  `identity Formula.bot`; singleton yields the assumption; cons-cons uses
  `pairing` to combine the head with the recursive tail result, applied via
  two modus-ponens steps after weakening to the larger context.

  ```lean
  noncomputable def bigconj_mem_iff :
      (L : List Formula) → (φ : Formula) → φ ∈ L → [bigconj L] ⊢ φ
  ```

  Proof by structural recursion on `L`: empty case is vacuous; singleton case
  substitutes and returns the assumption; cons-cons case splits on whether
  `φ = a` (head) — if so `lce` extracts it, otherwise the recursive call
  combined with `rce` + deduction theorem + weakening extracts it from the
  right conjunct.

These two lemmas are the syntactic engine that the chain-step seed consistency
reduction (Teammate A §3.3) will drive. They are self-contained and their
termination is purely structural — they compile in < 1 second.

### `specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md`

- Phase 4 marker flipped from `[NOT STARTED]` to `[PARTIAL]`.

## Architectural Gap Found in Phase 4

During proof planning, the following gap in the plan-v3 Phase 4 reduction
surfaced and must be resolved before the main theorem can be stated, let alone
proved.

### The gap in concrete terms

Teammate A's §3.3 reduction closes seed inconsistency by the chain:

```
L_g ∪ L_h ⊢ ⊥
⟹ L_g ⊢ ¬(bigconj L_h)                           (deduction theorem)
⟹ G(¬(bigconj L_h)) ∈ v_i.formulas                (g_content_closed_derivation)
⟹ G(¬(bigconj L_h)) ∈ Sigma                       (enriched_g_neg_bigconj_mem)
⟹ G(¬(bigconj L_h)) ∈ h_i.formulas                (sigma_signature_mem)
⟹ ¬(bigconj L_h) ∈ h_{i+1}.formulas               (hintikka_step G-clause)
⟹ ⊥                                               (??? "contradiction with
                                                        h_{i+1} local consistency")
```

The final step is the unjustified one. `HintikkaPoint.locally_consistent` is
pairwise: `∀ f ∈ formulas, ¬f ∉ formulas`. It does NOT say: "if a list of
formulas is all in `h.formulas`, then their conjunction is in `h.formulas`",
and it certainly does not say: "the formula set is Derivation-consistent".
Indeed `bigconj L_h` is generally not even in `Sigma`, let alone `h_{i+1}.formulas`.

For the final step to work we need one of:

1. **Strengthen `HintikkaPoint`** to carry a derivation-consistency witness:
   `∀ L ⊆ formulas.toList, ¬(L ⊢ Formula.bot)`. This is a much stronger
   condition than local consistency and cannot in general be imposed on
   arbitrary HintikkaPoints — it holds only for points backed by an MCS.

2. **Tie `h_{i+1}` to a BXPoint at Phase 4 time**, i.e., state
   `chain_step_seed_consistent` as: "for every BXPoint `v_i`, every BXPoint
   `v_{i+1}` with `bx_le v_i v_{i+1}` and `hintikka_step (sigma_signature v_i) (sigma_signature v_{i+1})`,
   the seed `↑(sigma_signature v_{i+1}).formulas ∪ g_content v_i.formulas` is
   consistent". But if `v_{i+1}` already exists as a BXPoint then the seed
   is automatically consistent (it is a subset of `v_{i+1}.formulas ∪ g_content v_i`
   which is contained in `v_{i+1}.formulas` since `bx_le v_i v_{i+1}` gives
   `g_content v_i ⊆ v_{i+1}`). So the statement would be vacuous.

3. **Phase 5-first approach**: skip stating `chain_step_seed_consistent` and
   instead prove the BXPoint-level forward step directly: given `v_i` with
   `φ U ψ ∈ v_i.formulas`, construct `v_{i+1}` with `bx_le v_i v_{i+1}` and
   the target propagated. This uses `bx_forward_witness` on `F(ψ) ∈ v_i`
   (from BX10) and Lindenbaum extension, entirely bypassing the Hintikka
   chain-step seed consistency lemma. The resulting BXPoint chain is then
   projected to a HintikkaRawChain via `sigma_signature` and the oracle
   witnesses for `hintikka_chain_exists` are supplied at that projection step.
   The defect-decrease property follows from `hintikka_step_target_decrease`
   once monotonicity (`untilDefectSet h_{i+1} ⊆ untilDefectSet h_i`) is
   discharged — which itself requires the Phase 5 Lindenbaum seed to be
   constructed from `h_i.formulas` so that all non-discharged defects carry
   forward.

### Recommended resolution (for next session)

Pursue option (3). Specifically:

- Add a new file `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/BXChain.lean`
  (or extend `Construction.lean`) with a `BXUntilChain` type: a nonempty list
  of BXPoints with consecutive `bx_le` relations and a target Until-defect.
- Prove `bx_until_chain_exists`: by well-founded recursion on `defect_count`
  of `sigma_signature`, given `v_0 : BXPoint` with `φ U ψ ∈ v_0` and
  `ψ ∉ v_0`, construct a `BXUntilChain` ending at a `v_k` with `ψ ∈ v_k`.
- The recursive step: from `v_i`, get `F(ψ) ∈ v_i` by `until_F_mcs`, then
  `bx_forward_witness` gives `v_{i+1}` with `bx_le v_i v_{i+1}` and
  `ψ ∈ v_{i+1}` (one-step discharge!). So the chain has at most length 2
  in the "simple" case.

  This is much simpler than the abstract-Hintikka chain approach. Why does
  the plan go through Hintikka chains at all? Because the "guard" property
  `φ ∈ u` for intermediate `u` is the *hard* part, not the witness existence.
  `bx_forward_witness` gives `ψ ∈ v_k` in one step, but nothing about
  intermediate points satisfying `φ`. The Hintikka-chain approach threads the
  guard through the chain construction.

- Therefore the real deliverable for Phase 4 is not "seed consistency" at
  all, but a **multi-step BX-chain construction preserving the guard φ**
  at all intermediate points. This is the essence of BX9 + BX5 (self-accumulation)
  applied at each step: `φ U ψ → (φ ∨ ψ)`, and if `φ` then carry forward to
  the next step via BX5's `(φ ∧ (φ U ψ)) U ψ`.

- The `bigconj_intro` / `bigconj_mem_iff` lemmas landed this session are not
  actually needed for option (3) — they were scaffolding for options (1) and (2).
  They remain in-tree as useful infrastructure for any future conjunction-based
  proof.

### Why the gap was not caught in Round 3 research

Teammate A's §3.3 reduction implicitly assumes that `h_{i+1}` is "finite-MCS-like"
(closed under classical reasoning within `Sigma`), which holds for the
`sigma_signature` of a BXPoint but not for arbitrary `HintikkaPoint Sigma`.
The current `HintikkaPoint` structure lacks the derivation-consistency axiom
and plan v3 does not propose adding one. The chain-step lemma statement also
does not restrict `h_{i+1}` to be BXPoint-backed. Together, these mean the
§3.3 reduction, as written, has an implicit premise that the formal statement
does not discharge.

Teammate C's §3.2 (gap identification) flagged "chain-exhaustiveness for
locus-control" and "hintikka_chain_exists with well-founded termination" as
the two hard sub-problems. They did not flag the `locally_consistent` vs
`finite-MCS-consistent` gap for the chain-step seed proof itself.

## Verification

| Check | Result |
|-------|--------|
| `lake build` (full project) | **PASS** (950/950) |
| New sorries introduced this session | **0** |
| New axioms introduced this session | **0** |
| Sorry count in `Realization.lean` | 6 (unchanged baseline) |
| Sorry count in `Frame.lean` (Until/Since) | 4 (unchanged baseline) |
| Sorry count in `Completeness.lean` | 1 (unchanged — task 93 scope) |
| Axioms in `Theories/` | 4 (unchanged from baseline) |
| `BigConj.lean` | UNCHANGED (trivial whitespace) |
| `Construction.lean` | UNCHANGED |
| `Realization.lean` | MODIFIED — two new `noncomputable def`s (bigconj_intro, bigconj_mem_iff) |
| `EnrichedClosure.lean` | UNCHANGED |
| `HintikkaPoint.lean` | UNCHANGED |
| `LocusControl.lean` | UNCHANGED |
| `Frame.lean` lines 140-583 unchanged | YES |

## Why the Main Theorem Was Not Attempted

After the architectural analysis above, stating `chain_step_seed_consistent`
in any of the three directions (with Hintikka-point finite-MCS strengthening,
with a BXPoint-linked `h_{i+1}` producing a vacuous statement, or via the
Phase 5-first option 3 route) would require substantial upstream work:

- Option 1 requires a new `HintikkaPoint` consistency field and rebuilding
  everything that constructs HintikkaPoints. Cascade risk high.
- Option 2 yields a vacuously-true statement that does not unblock Phase 5.
- Option 3 requires introducing a new `BXUntilChain` type with its own
  well-founded recursion proof mirroring the Phase 3 `hintikka_chain_exists`
  construction — essentially duplicating Phase 3 at the BXPoint level. This
  is the cleanest mathematically but is an 8-15h chunk of work on its own.

Per plan v3's Phase 4 ceiling ("12h") and the explicit session scope
directive ("halt cleanly with status='partial' on ceiling breach"), this
session halts after landing the DerivationTree-level scaffolding and
documenting the gap for the next session.

## Recommended Next Steps

1. **Follow-up session (Phase 4 continuation, ~8-15h)**: Implement option (3)
   — a `BXUntilChain` type with BXPoint-level forward-step construction.
   Use `bx_forward_witness` on `F(ψ)` for each step, combined with BX5
   (`self_accum_until`) to carry the guard. Supply
   `HintikkaStepOracle` by projecting the BXPoint chain through
   `sigma_signature`. At the projection step, verify the
   `untilDefectSet h_{i+1} ⊆ untilDefectSet h_i` monotonicity hypothesis
   of `hintikka_step_target_decrease` holds by construction (the seed for
   each new BXPoint includes `h_i.formulas`, so all non-discharged defects
   persist).

2. **Alternative follow-up**: Start with Phase 5 directly; the abstract
   chain existence of Phase 3 may never need to be instantiated if Phase 5
   constructs BXPoint chains directly.

3. **Phase 6 (locus-control exhaustiveness)**: unchanged from plan — still
   the second hard sub-problem and an independent 8-16h chunk.

4. **Phases 7-8 (sorry closure)**: unchanged from plan.

## Key Technical Choices

- **`bigconj_intro` and `bigconj_mem_iff` as `noncomputable def`**. Both
  are structurally recursive on the list, so they are definitionally
  computable (no well-founded recursion needed), but they produce
  `DerivationTree` values (a `Type`, not a `Prop`), so we mark them
  `noncomputable` to avoid Lean's code-generation pipeline. This matches
  the `pairing`, `lce`, `rce` definitions they depend on.

- **Namespace qualification**. Combinators like `identity`, `pairing`,
  `lce`, `rce` are not re-opened in the Quasimodel namespace, so the new
  code uses the fully qualified `Bimodal.Theorems.Combinators.identity`,
  `Bimodal.Theorems.Combinators.pairing`,
  `Bimodal.Theorems.Propositional.lce`, `Bimodal.Theorems.Propositional.rce`.

- **Avoiding Greek-letter pattern variables**. An earlier draft used
  `| [ψ] => ...` in the match on `bigconj_mem_iff`; Lean rejected `ψ` as
  a pattern variable in that position (likely a parser issue with Greek
  letters in nested recursion). Renamed to `a`, `b`, `rest`.

## References

- Plan v3: specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md
- Session 4 summary: specs/098_research_filtration_quasimodel_pivot/summaries/06_phase3-completion-summary.md
- Round 3 team research: specs/098_research_filtration_quasimodel_pivot/reports/03_team-research.md
- Teammate A §3.3 (the reduction whose gap we flagged): specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-a-findings.md
- DerivationTree combinators: Theories/Bimodal/Theorems/Combinators.lean (pairing, identity)
- Conjunction elimination: Theories/Bimodal/Theorems/Propositional.lean (lce, rce)
