# Implementation Plan: Migrate Nonempty (DerivationTree ...) to Derivable

- **Task**: 194 - Migrate nonempty to derivable
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Dependencies**: None (task 181 delivered `Derivable`; already merged)
- **Research Inputs**: reports/02_nonempty-derivable-migration.md (authoritative; supersedes reports/01_derivable-migration-seed.md)
- **Artifacts**: plans/02_migrate-nonempty-derivable.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace all live `Nonempty (DerivationTree fc G p)` sites (51 code sites + 5 comments across 15 files) with the canonical `Derivable fc G p` wrapper from `Theories/Bimodal/ProofSystem/Derivable.lean`, plus the notation-based `Derives` body in `LindenbaumQuotient.lean:40`. The migration is mechanical: all six critical defeq patterns (obtain destructuring, anonymous constructor, `not_nonempty_iff.mpr`, `Consistent ↔ ¬Derivable` as `Iff.rfl`, bidirectional term interchange) were machine-verified against master, so expected proof churn is zero in green files. Definition of done: sweep grep returns only documented exclusions, full default `lake build` green (baseline: 1752 jobs at c5189a7e4), sorry delta = 0.

### Research Integration

- Site inventory and per-file line numbers: report Section 3 (use it as the checklist source of truth).
- Defeq compatibility facts (why no proof rewrites are needed): report Section 5.
- Risk table incl. `unfold Consistent` radiation and notation choice (`|-!` fixes fc := .Base): report Section 6.
- Phase order (leaf-to-root along import DAG): report Section 7, adopted verbatim below.

### Prior Plan Reference

No prior plan (01_ report was a seed; this is the first plan for this task).

### Roadmap Alignment

No roadmap context provided for this run.

## Goals & Non-Goals

**Goals**:
- Migrate all `Nonempty (DerivationTree ...)` and live `Nonempty (⊢ ...)` sites in green/reachable files to `Derivable` (or its notations).
- Rewrite the three definition bodies: `Consistent` (MaximalConsistent.lean:59), `deductiveClosure` (RRelation.lean:132), `Derives` (LindenbaumQuotient.lean:40).
- Delete local duplicates `ContextConsistent`/`ContextDerivable` in `Bundle/Construction.lean` (zero external call sites), inlining `Consistent (fc := FrameClass.Base)` / `Derivable FrameClass.Base`.
- Fix `DenseFMP.lean`/`DiscreteFMP.lean` for free (their only errors are the missing-fc sites being migrated).
- Add the one needed import (`Bimodal.ProofSystem.Derivable`) to `ConservativeExtension/Lifting.lean` (cycle-safe).
- Keep default `lake build` green after every phase; sorry delta 0.

**Non-Goals**:
- Repairing `Core/RestrictedMCS/Deferral.lean` or `Algebraic/AlgebraicCompleteness.lean` (broken for unrelated reasons, orphaned) — EXCLUDED; flag as candidate follow-up task in the summary.
- Re-wiring or cleaning the orphaned aggregators (`Decidability/FMP.lean`, `Core/Core.lean`, `Algebraic/Algebraic.lean`).
- Touching Boneyard/, or the pre-existing sorry at `LindenbaumQuotient.lean:169`.
- Changing `Derivable.lean` itself (API is final from task 181).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Consistent` body change radiates to ~29 `unfold` sites outside the 16 files | M | L | All audited sites are defeq-tolerant tactic patterns (report Sec. 6); Phase 2 is isolated and gated by a FULL `lake build`, not a scoped one |
| Wrong notation at variable-fc sites (`G \|-! p` hard-codes fc := .Base) | M | M | At sites with variable `fc` (RRelation, PointInsertion, MCSProperties, MaximalConsistent, Lifting, Completeness:64) use `Derivable fc ...` or `G \|-![fc] p`; never the bare `\|-!` notation |
| aesop/simp-tagged `Derivable.ax`/`assume` change proof behavior on rewritten statements | L | L | No existing proof invokes aesop on such goals; if a simp closes differently it closes MORE; watch per-phase build output |
| Dense/DiscreteFMP outside default target — scoped build forgotten | M | M | Phase 5 verification explicitly requires `lake build Bimodal.Metalogic.Decidability.FMP.DenseFMP Bimodal.Metalogic.Decidability.FMP.DiscreteFMP` |
| Lifting.lean orphaned — regression invisible to default build | L | M | Phase 7 requires scoped `lake build Bimodal.Metalogic.ConservativeExtension.Lifting` |
| Accidental edits to excluded broken files | L | L | Phase 8 sweep grep whitelist names them; do not gate on their building |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4, 5, 6, 7 | 2 |
| 4 | 8 | 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel (waves 3's phases touch disjoint files). Sequential execution in the listed order is equally valid and matches the research report's leaf-to-root order.

Per-phase protocol: edit -> build gate (scoped or full as stated) -> commit (`task 194 phase {P}: {name}`). Fix forward on any error; never proceed past a red gate.

### Phase 1: Core statements (MaximalConsistent, MCSProperties, RestrictedMCS/Basic) [COMPLETED]

**Goal**: Migrate statement-level and proof-internal `Nonempty (DerivationTree ...)` sites in the three Core files WITHOUT touching the `Consistent` definition body.

**Tasks**:
- [x] `Metalogic/Core/MaximalConsistent.lean`: migrate lines 356, 369 (lemma conclusions `inconsistent_derives_bot`, `derives_neg_from_inconsistent_extension`) and 492 (proof-internal `have`). Do NOT touch line 59 (`Consistent` body — Phase 2).
- [x] `Metalogic/Core/MCSProperties.lean`: migrate lines 93, 192 (proof-internal `have ⟨d_bot⟩ : Nonempty (...)`).
- [x] `Metalogic/Core/RestrictedMCS/Basic.lean`: migrate lines 157, 201 (proof-internal), 401 (statement hypothesis of `restricted_mcs_from_formula`).
- [x] Use `Derivable fc ...` (explicit fc) at variable-fc sites; `G |-![fc] p` notation optional.
- [x] Build gate: `lake build Bimodal.Metalogic.Core.MaximalConsistent Bimodal.Metalogic.Core.MCSProperties Bimodal.Metalogic.Core.RestrictedMCS.Basic` then full `lake build` (Core is deep in the DAG; cheap to confirm). *(completed — full build green, 1752 jobs)*

**Timing**: 45 min

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - 3 sites (statements/proof-internal only)
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - 2 sites
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Basic.lean` - 3 sites

**Verification**:
- Full `lake build` green; zero new sorries; `Consistent` body at :59 untouched (diff check).

---

### Phase 2: Definition bodies (Consistent, deductiveClosure, Derives) [COMPLETED]

**Goal**: Rewrite the three definition bodies so `Consistent`/`Derivable` become visually coherent; gate with a FULL build because bodies radiate to all `unfold` sites (UltrafilterMCS, SuccRelation, SharedWitness, Metalogic/Completeness.lean, ...).

**Tasks**:
- [x] `Metalogic/Core/MaximalConsistent.lean:59`: `Consistent` body -> `¬Derivable fc Γ Formula.bot` (bridge is `Iff.rfl`, machine-verified pattern 4).
- [x] `Metalogic/BXCanonical/Chronicle/RRelation.lean:132`: `deductiveClosure` body -> `Derivable` form.
- [x] `Metalogic/Algebraic/LindenbaumQuotient.lean:40`: `Derives (φ ψ)` body `Nonempty (⊢ (φ.imp ψ))` -> `Derivable FrameClass.Base [] (φ.imp ψ)` (or `|-!` notation; fc is fixed Base here). Leave the pre-existing sorry at :169 untouched.
- [x] Build gate: FULL `lake build` (mandatory for this phase; scoped builds are insufficient). *(completed — green, 1752 jobs, zero unfold-site edits required)*

**Timing**: 45 min

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - 1 def body
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` - 1 def body
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` - 1 def body

**Verification**:
- Full `lake build` green (1752-job default target); no new sorries; no `unfold Consistent`/`unfold SetConsistent` site required edits (if one did, record it — it contradicts the audit and must be flagged in the summary).

---

### Phase 3: Bundle/Construction.lean — delete local duplicates [COMPLETED]

**Goal**: Remove `ContextConsistent` (:107) and `ContextDerivable` (:168) outright (zero external call sites, verified) and inline the canonical predicates at their ~8 internal use sites; migrate the remaining statement site.

**Tasks**:
- [x] Delete `ContextConsistent` def; replace internal uses with `Consistent (fc := FrameClass.Base)` (note: fc is implicit on `Consistent`).
- [x] Delete `ContextDerivable` def; replace internal uses with `Derivable FrameClass.Base` (or `|-!` notation).
- [x] Migrate site at line 180 (statement hypothesis).
- [x] Fallback ONLY if inlining causes elaboration friction in dependent proofs: keep as `abbrev`s over the canonical predicates (report Sec. 4 option b) and note the deviation in the summary. *(not needed — inlining clean)*
- [x] Build gate: `lake build Bimodal.Metalogic.Bundle.Construction` then full `lake build`. *(completed — green, 1752 jobs; identifiers gone from all .lean sources; two stale mentions remain in latex/subfiles/04-Metalogic.tex docs, out of scope)*

**Timing**: 45 min

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - 2 defs deleted, ~8 internal call sites inlined, 1 statement site

**Verification**:
- `grep -rn "ContextConsistent\|ContextDerivable" Theories/ Tests/ --exclude-dir=Boneyard` returns nothing; full `lake build` green.

---

### Phase 4: Chronicle (RRelation remainder, PointInsertion) [COMPLETED]

**Goal**: Migrate the largest file cluster; kept to its own phase because PointInsertion.lean is ~3,500 lines.

**Tasks**:
- [x] `RRelation.lean`: migrate 707 (proof-internal `∃ L, ... ∧ Nonempty (...)`), 1122 (statement conclusion); update comment at 705.
- [x] `PointInsertion.lean`: migrate 568 (disjunct `∃ beta ∈ B, Nonempty (...)`), 1233 (statement hypothesis), 3291, 3307, 3450, 3466 (proof-internal `suffices`/`have`); update comments at 876, 877. *(deviation: altered — `h_ne.some` at 3311/3470 replaced by `Nonempty.some h_ne`; dot notation does not resolve through the `Derivable` def and the goal is Type-valued so `obtain` cannot eliminate)*
- [x] These files have variable `fc` — use `Derivable fc ...`, never bare `|-!`.
- [x] Build gate: `lake build Bimodal.Metalogic.BXCanonical.Chronicle.RRelation Bimodal.Metalogic.BXCanonical.Chronicle.PointInsertion`. *(completed — scoped green, full build green 1752 jobs, sweep grep clean)*

**Timing**: 60 min

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` - 2 code sites + 1 comment
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - 6 code sites + 2 comments

**Verification**:
- Scoped build green; `grep -n "Nonempty (DerivationTree" <both files>` returns nothing.

---

### Phase 5: FMP/Decidability + Dense/DiscreteFMP repair [COMPLETED]

**Goal**: Migrate the FMP/Decidability layer; the same substitution FIXES the pre-existing missing-fc elaboration bug in DenseFMP/DiscreteFMP for free.

**Tasks**:
- [x] `Decidability/FMP/ClosureMCS.lean`: migrate 227 (statement hypothesis).
- [x] `Decidability/FMP/FMP.lean`: migrate 58, 140, 194, 208 (statements) and 63 (proof-internal).
- [x] `Decidability/Correctness.lean`: migrate 125, 135 (conclusions of `fmp_completeness`, `fmp_incompleteness_witness`).
- [x] `Decidability/FMP/DenseFMP.lean`: replace broken `¬Nonempty (DerivationTree [] phi)` at 63 with `¬Derivable FrameClass.Base [] phi` and the positive form at 75 with `Derivable FrameClass.Base [] phi` (the delegated-to `mcs_finite_model_property` is Base).
- [x] `Decidability/FMP/DiscreteFMP.lean`: identical fix at 63, 75.
- [x] Build gate: full `lake build` PLUS explicit scoped `lake build Bimodal.Metalogic.Decidability.FMP.DenseFMP Bimodal.Metalogic.Decidability.FMP.DiscreteFMP` (they are outside the default target). *(completed — scoped Dense/DiscreteFMP builds GREEN, fixed pre-existing regression; full build green 1752 jobs)*

**Timing**: 60 min

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/FMP/ClosureMCS.lean` - 1 site
- `Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean` - 5 sites
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - 2 sites
- `Theories/Bimodal/Metalogic/Decidability/FMP/DenseFMP.lean` - 2 sites (repairs file)
- `Theories/Bimodal/Metalogic/Decidability/FMP/DiscreteFMP.lean` - 2 sites (repairs file)

**Verification**:
- Full `lake build` green; scoped DenseFMP/DiscreteFMP builds now GREEN (were red at baseline — record this as a fixed regression in the summary).

---

### Phase 6: Completeness layer (ParametricCompleteness, BXCanonical/Completeness) [COMPLETED]

**Goal**: Migrate the top-of-DAG public completeness statements.

**Tasks**:
- [x] `Algebraic/ParametricCompleteness.lean`: migrate 115, 189, 225, 256, 295 (all fully-qualified `Bimodal.ProofSystem.DerivationTree` hypotheses).
- [x] `BXCanonical/Completeness.lean`: migrate 64 (hypothesis, variable fc — use `Derivable fc ...`), 136, 178, 235, 277 (conclusions of `completeness`, `completeness'`, dense/discrete variants), 142 (proof-internal `not_nonempty_iff.mpr` — verified safe, pattern 3); update docstrings at 20, 25. *(deviation: altered — line 142 `not_nonempty_iff.mpr h_not_deriv` simplified to plain `h_not_deriv`; with `Derivable` opaque to push_neg the hypothesis stays `¬Derivable` so no IsEmpty conversion is needed)*
- [x] Build gate: full `lake build` (these are public statements; consumers must re-elaborate). *(completed — green, 1752 jobs)*

**Timing**: 45 min

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCompleteness.lean` - 5 sites
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - 6 code sites + 2 docstrings

**Verification**:
- Full `lake build` green; no consumer of `completeness`/`fmp_contrapositive` needed edits (defeq pattern 5).

---

### Phase 7: ConservativeExtension/Lifting.lean [COMPLETED]

**Goal**: Migrate the one green-but-orphaned file; requires the single new import of the whole task.

**Tasks**:
- [x] Add `import Bimodal.ProofSystem.Derivable` to `Metalogic/ConservativeExtension/Lifting.lean` (cycle-safe: Derivable.lean imports nothing in Metalogic).
- [x] Migrate site 685 (conclusion of `lift_derivation_qfree`); fc is variable here — use `Derivable fc ...`.
- [x] Build gate: scoped `lake build Bimodal.Metalogic.ConservativeExtension.Lifting` (orphan — default build will NOT catch regressions here) plus full `lake build`. *(completed — scoped green 664 jobs, full green 1752 jobs)*

**Timing**: 20 min

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` - 1 import + 1 site

**Verification**:
- Scoped Lifting build green; full `lake build` green.

---

### Phase 8: Sweep + full verification [COMPLETED]

**Goal**: Prove completeness of the migration and close out with a zero-debt gate.

**Tasks**:
- [x] Run `grep -rn "Nonempty (DerivationTree\|Nonempty (⊢" Theories/ --exclude-dir=Boneyard`. Allowed residuals ONLY: `ProofSystem/Derivable.lean` (its own definition), `Core/RestrictedMCS/Deferral.lean`, `Algebraic/AlgebraicCompleteness.lean` (documented exclusions). Anything else = missed site; migrate it and re-run. *(verified — residuals exactly the whitelist)*
- [x] Also sweep fully-qualified spelling: `grep -rn "Nonempty (Bimodal.ProofSystem.DerivationTree" Theories/ --exclude-dir=Boneyard` — same whitelist. *(verified — zero hits)*
- [x] Confirm sorry delta 0: `grep -rn "sorry" Theories/ --exclude-dir=Boneyard | wc -l` matches baseline count (pre-existing `LindenbaumQuotient.lean:169` only among touched files). *(verified — 541 before and after)*
- [x] Final FULL `lake build` green (compare job count against 1752 baseline; growth from newly-reachable modules is acceptable, failures are not). *(verified — 1752 jobs, green)*
- [x] Document in the implementation summary: (a) Dense/DiscreteFMP repaired as side effect; (b) Deferral.lean + AlgebraicCompleteness.lean excluded as broken/orphaned — recommend a follow-up repair-or-boneyard task; (c) the three orphaned aggregators noted for separate cleanup. *(done — see summaries/02_migrate-nonempty-derivable-summary.md)*

**Timing**: 30 min

**Depends on**: 3, 4, 5, 6, 7

**Files to modify**:
- None expected (sweep only; stragglers migrated in place if found)

**Verification**:
- Sweep greps clean modulo whitelist; full `lake build` green; sorry delta 0.

## Testing & Validation

- [x] Full default `lake build` green after Phases 1, 2, 3, 5, 6, 7, 8 (Phase 4 may use scoped build; Phase 8 is final full gate). *(all phases were additionally gated by a full build — all green, 1752 jobs)*
- [x] Scoped builds green for out-of-target modules: `...Decidability.FMP.DenseFMP`, `...Decidability.FMP.DiscreteFMP` (Phase 5), `...ConservativeExtension.Lifting` (Phase 7).
- [x] Sweep greps (standard + fully-qualified + notation `Nonempty (⊢`) return only the whitelisted 3 files.
- [x] Sorry count unchanged from baseline (delta 0; 541 -> 541).
- [x] `ContextConsistent`/`ContextDerivable` identifiers gone from Theories/ and Tests/ `.lean` sources (two stale prose mentions remain in `Theories/Bimodal/latex/subfiles/04-Metalogic.tex`, out of scope).

## Artifacts & Outputs

- plans/02_migrate-nonempty-derivable.md (this file)
- summaries/02_migrate-nonempty-derivable-summary.md (on completion; must include the exclusion/follow-up notes from Phase 8)
- Modified Lean files per phases 1-7 (15 files total; 1 new import; 2 defs deleted; 3 def bodies rewritten)

## Rollback/Contingency

- Each phase is an independent commit (`task 194 phase {P}: {name}`); revert the offending phase commit with `git revert` if a downstream problem surfaces later.
- Within a phase: fix forward first (all substitutions are defeq-verified, so failures indicate a mis-transcription, not a design problem). If a Phase 2 body change unexpectedly breaks a remote `unfold` site in a way that resists a local fix, revert Phase 2 only — statement-level migrations (all other phases) do not depend on the body rewrites for correctness, only for coherence.
- Bundle/Construction fallback: if deletion+inline causes elaboration friction, downgrade to `abbrev` wrappers (report Sec. 4 option b) rather than blocking.
