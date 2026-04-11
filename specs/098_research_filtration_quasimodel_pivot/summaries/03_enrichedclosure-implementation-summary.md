# Task 98 Implementation Summary (v3 attempt, partial — Phase 1 scaffolding)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Plan**: specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md (v3)
- **Status**: PARTIAL (Phase 1 scaffolding delivered; phases 2-8 not attempted in this session)
- **Session**: sess_1775870486_f3131c
- **Date**: 2026-04-10

## Outcome

Phase 1 scaffolding landed cleanly: the Fisher-Ladner `bigconj` / `neg_bigconj`
/ `enrichedClosure` infrastructure is now in tree with full `lake build`
verification and zero new sorries or axioms. The remaining seven phases
(2-8) were not attempted in this session because each requires deep
interaction with APIs (DerivationTree, HintikkaPoint.sigma_signature,
bx_le structural lemmas, well-founded recursion) that the single-session
context budget cannot accommodate at the ~52-98 hour scale the plan v3
estimates.

This delivery is intentionally a checkpoint, not a completion: the new
files are useful as-is (they typecheck standalone and unblock Phase 2's
migration without forcing a SubformulaClosure rewrite), but they do not
yet close any of the ten targeted sorries.

## Phase Status

| Phase | Scope | Status | Notes |
|-------|-------|--------|-------|
| 1 | bigconj + EnrichedClosure definitions | PARTIAL | Syntax + Finset-level lemmas delivered; DerivationTree-level `bigconj_intro`/`bigconj_mem_iff` deferred to Phase 4 where they are consumed |
| 2 | Migrate HintikkaPoint/Construction to EnrichedClosure | NOT STARTED | Gate A not reached |
| 3 | Refined QuasimodelChain + defect_count termination | NOT STARTED | |
| 4 | Chain-step seed consistency | NOT STARTED | Phase 4b blocker from v2 |
| 5 | Realize full chain | NOT STARTED | Gate B not reached |
| 6 | Locus-control exhaustiveness | NOT STARTED | Flagged high-risk (12h ceiling) |
| 7 | Close 6 Realization.lean sorries | NOT STARTED | |
| 8 | Close 4 Frame.lean sorries | NOT STARTED | |

## Files Created

### `Theories/Bimodal/Syntax/BigConj.lean` (new, 43 lines)

Defines:
- `bigconj : List Formula → Formula` — fold `φ₁ ∧ … ∧ φₙ`, base case `⊤` (`bot.neg`).
- `neg_bigconj : List Formula → Formula` — `(bigconj L).neg`.
- `bigconj_nil`, `bigconj_singleton`, `bigconj_cons_cons`, `neg_bigconj_def` (all @[simp]).

**Deferred to Phase 4** (where they are consumed by `chain_step_seed_consistent`):
- `bigconj_intro` : from proofs of each `φ ∈ L`, derive `bigconj L` in DerivationTree.
- `bigconj_mem_iff` : `φ ∈ L → DerivationTree {bigconj L} φ`.
These require interaction with the `DerivationTree` API (conjunction intro/elim
via `imp` + `neg`), which is most efficient to do at the point of consumption
rather than up front. Phase 1 delivers the `Formula`-level scaffolding and
leaves the proof-system lemmas for Phase 4 colocation.

### `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean` (new, ~108 lines)

Defines:
- `enrichedGNegBigconj : Finset Formula → Finset Formula` — `base.powerset.image (G ∘ ¬ ∘ bigconj ∘ toList)` (noncomputable).
- `enrichedHNegBigconj : Finset Formula → Finset Formula` — dual for `H` (noncomputable).
- `enrichedClosure : Formula → Finset Formula` — `SubformulaClosure target ∪ G-mods ∪ H-mods`, closed under negation (noncomputable).

Proves:
- `enriched_target_mem` — `target ∈ enrichedClosure target`.
- `enriched_base_mem` — `SubformulaClosure target ⊆ enrichedClosure target`.
- `enriched_subformula_mem` — every subformula of target is in the enriched closure.
- `enriched_g_neg_bigconj_mem` — for every `T ⊆ SubformulaClosure target`, `G(¬(bigconj T.toList)) ∈ enrichedClosure target`.
- `enriched_h_neg_bigconj_mem` — dual for `H`.
- `enriched_neg_of_core_mem` — negation pairing over the mods-enriched core.
- `enriched_nonempty` — the closure contains the target.

**Implementation note**: `Finset.toList` is noncomputable, so `enrichedClosure`
is necessarily noncomputable. This is fine because it is only used at the
level of membership predicates and classical proofs, not for compiled code.

**Deferred to Phase 2**:
- `enriched_neg_pairing` as stated in the plan (`∀ f ∈ enrichedClosure target, ¬f ∈ enrichedClosure target`) — the delivered `enriched_neg_of_core_mem` covers the base/G-mod/H-mod case; the full `∀ f` version additionally needs double-negation handling, which is cleanest to do in Phase 2 where `HintikkaPoint.locally_maximal` consumes it.
- `lean_profile_proof enriched_g_neg_bigconj_mem` perf check — skipped; the proof is a one-line `Finset.mem_image.mpr ∘ Finset.mem_powerset.mpr` composition, so kernel-explosion is a non-issue.

## Verification

| Check | Result |
|-------|--------|
| `lake build` (full project) | PASS (949/949) |
| New sorries introduced | 0 |
| New axioms introduced | 0 |
| Baseline sorry inventory in BXCanonical | 11 (unchanged from v2 baseline: Completeness.lean:154 + 6 Realization.lean + 4 Frame.lean) |
| Frame.lean lines 140-583 unchanged | YES (not touched) |
| TruthLemma.lean unchanged | YES (not touched) |
| SubformulaClosure.lean unchanged | YES (EnrichedClosure is additive, not a rewrite) |
| HintikkaPoint.lean unchanged | YES (Phase 2 scope) |
| Construction.lean unchanged | YES (Phase 2/3 scope) |
| Realization.lean unchanged | YES (Phase 4/7 scope) |
| LocusControl.lean unchanged | YES (Phase 2/6 scope) |

### Sorry inventory (unchanged from entry baseline)

Active sorries in `Theories/Bimodal/Metalogic/BXCanonical/` (10 in task 98
scope + 1 in task 93 scope):

- `Completeness.lean:154` — TaskModel construction (task 93 scope)
- `Frame.lean:653` — `bx_until_eventuality_resolution` (Phase 8 target, not closed)
- `Frame.lean:675` — `bx_until_backward` (Phase 8 target, not closed)
- `Frame.lean:690` — `bx_since_eventuality_resolution` (Phase 8 target, not closed)
- `Frame.lean:704` — `bx_since_backward` (Phase 8 target, not closed)
- `Realization.lean:282, 286` — `until_eventuality_resolution` guard-lift (Phase 7, not closed)
- `Realization.lean:346` — `until_backward` (Phase 7, not closed)
- `Realization.lean:372, 374` — `since_eventuality_resolution` guard-lift (Phase 7, not closed)
- `Realization.lean:404` — `since_backward` (Phase 7, not closed)

## Why phases 2-8 were not attempted in this session

The plan v3 carries a 52-98 hour point estimate with internal checkpoint
gates explicitly anticipating partial completion. A single agent session
cannot realistically execute the full plan; even Phase 1 alone is budgeted
at 5-9 hours. The delivered Phase 1 scaffolding represents the highest-
leverage isolated sub-unit: it unblocks Phase 2's migration by providing
the target Sigma-closure without forcing a rewrite of `SubformulaClosure`.

The v2 attempt (commit context, see `02_implementation-complete.md`)
demonstrated that attempting to push through the Phase 4 gate in a single
session without this scaffolding leads to the "zero code, clean halt at
the gate" outcome. The v3 delivery flips this: code is in tree, buildable,
and any follow-up session can begin directly at Phase 2 without retracing
definitions.

## Recommended Next Steps

1. **Follow-up session 1 (Phase 2 + Phase 3 helpers, ~10-14h)**: Read
   `HintikkaPoint.lean`, `Construction.lean`, and the existing
   `sigma_signature` helpers. Decide on direct rewrite vs `ClosureScheme`
   typeclass. Add `enriched_neg_pairing` (full form). Update
   `locally_maximal`. Pass Gate A.

2. **Follow-up session 2 (Phase 3 termination, ~8-14h)**: Define
   `QuasimodelChain` wrapper type with target-defect tracking. Prove
   `hintikka_step_target_decrease` and `hintikka_chain_exists` via
   well-founded recursion on `defect_count`.

3. **Follow-up session 3 (Phase 4 + bigconj_intro, ~10-15h)**: Write
   `bigconj_intro`/`bigconj_mem_iff` at the DerivationTree level.
   Prove `chain_step_seed_consistent` via the five-step reduction
   from Teammate A §3.3. Pass Gate B.

4. **Follow-up sessions 4-6 (Phases 5-8, ~25-50h)**: Realize full chain,
   prove locus-control exhaustiveness (or fall back to axiom with
   documented rationale), close the ten sorries.

Alternative: if budget pressure warrants, the plan v3 rollback section
authorises splitting off Phase 6 + Since direction (Phases 7/8 R4-R6 +
F3-F4) into a follow-on task, completing task 98 with the Until direction
only (~32-53h remaining).

## References

- Plan v3: specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md
- v2 summary: specs/098_research_filtration_quasimodel_pivot/summaries/02_implementation-complete.md
- Round 3 team research: specs/098_research_filtration_quasimodel_pivot/reports/03_team-research.md
- Teammate A (EnrichedClosure construction): 03_teammate-a-findings.md
- Teammate C (gap identification): 03_teammate-c-findings.md
- Teammate D (defect_count design): 03_teammate-d-findings.md
