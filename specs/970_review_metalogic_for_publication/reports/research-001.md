# Research Report: Task #970 — Review Metalogic for Publication Readiness

**Task**: 970 - Review Metalogic for Publication Readiness
**Date**: 2026-03-15
**Mode**: Team Research (2 teammates)
**Session**: sess_1773636272_19213

---

## Summary

The metalogic has accumulated substantial scaffolding from the iterative proof development process. Two parallel research agents independently identified the same core redundancies with high confidence. The main opportunities are:

1. **`bmcs_truth_at` intermediate layer** — structurally redundant (explicitly acknowledged in `CanonicalConstruction.lean`); the `canonical_truth_lemma` was designed specifically to bypass it
2. **~15 unused convenience definitions** — accessor wrappers and derived lemmas in `FMCS`/`BFMCS` that were created during proof development but never adopted by active proofs
3. **Duplicate theorem bodies** — `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`, `temp_4_past` proven independently in both `Completeness.lean` and `Core/MCSProperties.lean`
4. **Thin aliases** — `dne_theorem`, `dne_theorem'`, `diamondFormula`, `set_mcs_modal_saturation_forward` are one-line wrappers with no added value
5. **Dead-code sorrys** — `temporal_coherent_family_exists_Int` and `fully_saturated_bfmcs_exists_int` in `TemporalCoherentConstruction.lean` are on a deprecated proof path not used in the active completeness chain

**Current sorry count**: 9 active sorries (SORRY_REGISTRY.md is outdated — still lists 46 from the old monolithic file era).

---

## Key Findings

### Finding 1: `bmcs_truth_at` Is a Structurally Redundant Intermediate (High-Impact)

The `bmcs_truth_at` definition in `Bundle/BFMCSTruth.lean` is definitionally isomorphic to `truth_at` when canonical definitions are chosen correctly. This is **explicitly acknowledged** in `Bundle/CanonicalConstruction.lean` line 20:

> "The intermediate `bmcs_truth_at` is structurally redundant — it is definitionally identical to `truth_at` when canonical definitions are chosen correctly. Therefore we prove the TruthLemma directly at the `truth_at` level, eliminating the intermediate."

Despite this, `bmcs_truth_at` remains as a separate definition and `TruthLemma.lean` still proves `bmcs_truth_lemma` in terms of it. The result is **two parallel truth lemma paths** for the same mathematical content:
- `bmcs_truth_lemma` (via `BFMCSTruth.lean` → `TruthLemma.lean`) — intermediate level
- `canonical_truth_lemma` (via `CanonicalConstruction.lean`) — direct `truth_at` level

The entire BFMCS intermediate layer (`bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context`) exists as scaffolding for `bmcs_truth_at` and has **no downstream callers** outside `BFMCSTruth.lean` and `TruthLemma.lean` themselves.

**Publication impact**: The main completeness theorem should be stated in terms of standard `truth_at` semantics (Kripke), not `bmcs_truth_at`. The `canonical_truth_lemma` is closer to the mathematically standard form (cf. Blackburn et al.: "if φ is valid in all Kripke frames of class C, then φ is derivable from the axioms for C").

### Finding 2: `TemporalCoherentConstruction.lean` Contains Dead-Code Sorries

Two functions with sorry in `TemporalCoherentConstruction.lean` are **dead code** relative to the active completeness chain:

```
DEAD PATH (not used on publication path):
temporal_coherent_family_exists_Int [SORRY, line ~422]
  → fully_saturated_bfmcs_exists_int [SORRY, line ~516]
  → construct_saturated_bfmcs_int

ACTIVE PATH (publication-ready):
temporal_coherent_family_exists_CanonicalMCS [PROVEN, CanonicalFMCS.lean]
  → cantor_iso [PROVEN, CantorApplication.lean]
  → bmcs_truth_lemma [PROVEN, TruthLemma.lean]
```

`StagedConstruction/Completeness.lean` uses `temporal_coherent_family_exists_CanonicalMCS`, not the Int version. The two sorries in `TemporalCoherentConstruction.lean` therefore do not affect publication but do inflate the sorry count.

**Blocking issue**: `TruthLemma.lean` imports `TemporalCoherentConstruction` for four items that are valid mathematical content: `TemporalCoherentFamily`, `temporal_backward_G`, `temporal_backward_H`, and `BFMCS.temporally_coherent`. These must be extracted to a new `Bundle/TemporalCoherence.lean` before the deprecated file can be archived.

### Finding 3: Thin Aliases with No Mathematical Value

| Definition | File | Description |
|------------|------|-------------|
| `dne_theorem` | `ModalSaturation.lean` | One-line wrapper for `Propositional.double_negation` |
| `dne_theorem'` | `TemporalCoherentConstruction.lean:94` | One-line wrapper for `dne_theorem`; **zero usage** outside defining file |
| `dni_theorem` | `ModalSaturation.lean` | Re-derives `Propositional.dni` from scratch |
| `diamondFormula` | `ModalSaturation.lean:63` | `def diamondFormula phi := phi.diamond` — pure alias |
| `set_mcs_modal_saturation_forward` | `Completeness.lean` | One-line wrapper for `set_mcs_box_closure` (historical name) |

All can be eliminated. Callers should use the underlying definitions directly.

### Finding 4: Unused Convenience Definitions in FMCS/BFMCS

~15 definitions created during proof development that were never adopted by active proofs (confirmed by grep — no external usage):

**`FMCSDef.lean` — unused derived lemmas** (active proofs call structure fields directly):
- `FMCS.at`, `FMCS.forward_G_chain`, `FMCS.backward_H_chain`
- `FMCS.GG_to_G`, `FMCS.HH_to_H`
- `FMCS.G_implies_future_phi`, `FMCS.H_implies_past_phi`
- `FMCS.consistent`, `FMCS.maximal`, `FMCS.theorem_mem`
- `IsConstantFamily` (never instantiated)

**`BFMCS.lean` — unused accessors**:
- `BFMCS.mcs_at`, `BFMCS.is_mcs` (delegates to `fam.is_mcs t`)
- `BFMCS.consistent`, `BFMCS.phi_from_box`, `BFMCS.box_from_universal`

**`BFMCSTruth.lean`** (if `bmcs_truth_at` layer is kept):
- `bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context` — appear only in comments/README, never in proofs

Evidence pattern: Active proofs call `fam.forward_G`, `fam.backward_H`, `fam.mcs t` directly rather than through these convenience wrappers.

### Finding 5: Duplicate Theorem Bodies in `Completeness.lean` and `Core/MCSProperties.lean`

The following theorems have **two independent proof bodies** — one in `Completeness.lean` (namespace `Bimodal.Metalogic`) and one in `Core/MCSProperties.lean` (namespace `Bimodal.Metalogic.Core`):
- `set_mcs_all_future_all_future`
- `set_mcs_all_past_all_past`
- `temp_4_past`

The `Completeness.lean` header claims these are "re-exported from Core modules," but they contain separate full proof bodies (no Lean `export` directive).

The unique content of `Completeness.lean` that is NOT duplicated in `MCSProperties.lean`:
- `set_mcs_disjunction_intro/elim/iff` (3 theorems)
- `set_mcs_conjunction_intro/elim/iff` (3 theorems)
- `set_mcs_box_closure`, `set_mcs_box_box` (2 fundamental theorems)
- `set_mcs_neg_box_implies_diamond_neg`, `set_mcs_diamond_neg_implies_neg_box`, `set_mcs_diamond_box_duality` (3 theorems)

**Recommendation**: Migrate unique content to `Core/MCSProperties.lean` and deprecate or eliminate `Completeness.lean`.

### Finding 6: `asDiamond` Defined Independently in Two Files

- `ModalSaturation.lean:70`: `def asDiamond : Formula → Option Formula`
- `Decidability/Tableau.lean:157`: `def asDiamond? : Formula → Option Formula`

The `ModalSaturation` version is only used internally for `is_modally_saturated_iff_no_needs_witness`. These diverged independently during development. The `ModalSaturation` version can be eliminated or the shared definition extracted to a common location.

### Finding 7: `needs_modal_witness` Is Internal Scaffolding

`ModalSaturation.lean` defines `needs_modal_witness` and `is_modally_saturated_iff_no_needs_witness`. The `needs_modal_witness` predicate appears only within that equivalence proof — it is internal proof scaffolding, not a published interface.

### Finding 8: Current Sorry Count Is 9 (SORRY_REGISTRY.md Outdated)

Active sorries (excluding Boneyard and Examples):
```
Bundle/TemporalCoherentConstruction.lean  - temporal_coherent_family_exists_Int [dead code]
Bundle/TemporalCoherentConstruction.lean  - fully_saturated_bfmcs_exists_int [dead code]
Domain/DiscreteTimeline.lean:179,187,200,218,231 - SuccOrder/PredOrder/IsSuccArchimedean
Canonical/ConstructiveFragment.lean:579,584 - forward/backward reachability
```

The SORRY_REGISTRY.md still lists 46 sorries from the old monolithic `Completeness.lean` era. It requires a full update.

---

## Synthesis

### Methodology: Three-Test Filter for Redundancy

Apply to every candidate definition:

1. **Alias test**: Is it a direct rename/wrapper with no additional preconditions or structural complexity? → Redundant
2. **Usage test**: Is it referenced outside its defining module? → If no, may be removable internal scaffolding
3. **Standard form test**: Does it correspond to a standard mathematical concept, or is it an internal bridge artifact? → Bridge artifacts that can be expressed directly via official semantics are redundant

A definition is **necessary** when it introduces new mathematical structure, has a name corresponding to standard literature concepts (`SetMaximalConsistent`, `CanonicalR`, `GContent`), or is a stable interface referenced from multiple independent modules.

### Conflicts Resolved

**None** — both teammates independently identified the same redundancies with corroborating evidence. The findings are mutually reinforcing.

### Gaps Identified

1. **No assessment of `Core/MCSProperties.lean` vs `Completeness.lean` import graph** — need to verify which downstream files import `Completeness.lean` under its old namespace before deprecating
2. **`asDiamond` extraction path not fully specified** — needs decision on whether to move to shared `Formula` utilities or just eliminate the `ModalSaturation` version
3. **`DiscreteTimeline.lean` sorry remediation** not in scope for this task but blocks discrete completeness path

### Prioritized Recommendations

**Priority 1 (Blocking — enables `TemporalCoherentConstruction.lean` archival)**:
- Extract `TemporalCoherentFamily`, `temporal_backward_G`, `temporal_backward_H`, `BFMCS.temporally_coherent` (and supporting lemmas) to new `Bundle/TemporalCoherence.lean`
- Update `TruthLemma.lean` to import from new file
- Archive `TemporalCoherentConstruction.lean` to Boneyard

**Priority 2 (High-impact, reduces sorry count to 7)**:
- Mark the 2 dead-code sorry functions in `TemporalCoherentConstruction.lean` as deprecated (they go with the file to Boneyard)

**Priority 3 (Safe, zero-risk removals)**:
- `dne_theorem'` from `TemporalCoherentConstruction.lean:94`
- `diamondFormula` from `ModalSaturation.lean:63` → replace with `phi.diamond` in callers
- `set_mcs_modal_saturation_forward` from `Completeness.lean` → replace with `set_mcs_box_closure`
- All `FMCS.*` unused derived lemmas from `FMCSDef.lean`
- All `BFMCS.*` unused accessors from `BFMCS.lean`
- `bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context` from `BFMCSTruth.lean`
- `IsConstantFamily` from `FMCSDef.lean`

**Priority 4 (Structural cleanup)**:
- Migrate unique `Completeness.lean` content to `Core/MCSProperties.lean`, eliminating the duplicate theorem bodies
- Mark `BFMCSTruth.lean` and `TruthLemma.lean` as "legacy path — use `canonical_truth_lemma` for new proofs"

**Priority 5 (Major refactor — future task)**:
- Full elimination of `bmcs_truth_at` layer by deriving `bmcs_truth_lemma` as a corollary of `canonical_truth_lemma`
- This would allow deletion of `BFMCSTruth.lean` and the entire `bmcs_truth_at` infrastructure

**Priority 6 (Documentation)**:
- Update SORRY_REGISTRY.md — current count is 9, not 46
- Ensure main theorems (`bmcs_weak_completeness_mcs`, `soundness`, etc.) are stated in standard Kripke form in the publication-facing interface

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary methodology, criteria, duplicate theorems, sorry status | completed | high |
| B | Prior art, concrete examples, BFMCS accessor inventory, blocking issue | completed | high |

---

## References

- `Bundle/CanonicalConstruction.lean` — explicit acknowledgment of `bmcs_truth_at` redundancy (line 20)
- `specs/929_prepare_metalogic_for_publication/reports/research-001.md` — task 929 research (context)
- `specs/929_prepare_metalogic_for_publication/reports/research-001-teammate-b-findings.md` — identifies `TemporalCoherentConstruction` as deprecated
- Research-006 for task 945 — confirms `bmcs_truth_at` redundancy
- `docs/project-info/SORRY_REGISTRY.md` — outdated (lists 46, current active count is 9)
- `Theories/Bimodal/Boneyard/` — historical pattern of scaffolding accumulation
