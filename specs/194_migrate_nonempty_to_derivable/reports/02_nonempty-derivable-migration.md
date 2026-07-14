# Research Report: Migrate Nonempty (DerivationTree ...) to Derivable

**Task**: #194 — Migrate nonempty to derivable (lean4)
**Date**: 2026-07-14
**Supersedes/extends**: `01_derivable-migration-seed.md` (2026-05-22)
**Session**: sess_1784042334_6ccc8d
**Baseline**: default `lake build` GREEN (1752 jobs) at commit c5189a7e4

## 1. Summary

- 56 occurrences of `Nonempty (DerivationTree ...)` (incl. fully-qualified variants) remain in 16 active files, plus 2 notation-based sites (`Nonempty (⊢ ...)`) the seed's grep missed. 5 of the 56 are comments/docstrings.
- The `Derivable` wrapper (task 181) is in place at `Theories/Bimodal/ProofSystem/Derivable.lean` with **frame-class parameterization** — `Derivable (fc : FrameClass) (G : Context) (p : Formula)` — notations `G |-![fc] p` / `G |-! p`, aesop/simp-tagged constructor lemmas, and `Derivable.lift`. It currently has **zero real call sites** outside its own file; this migration establishes the API.
- All six defeq-compatibility patterns required for a mechanical migration were **machine-verified** in this session (Section 5). The migration needs no proof rewrites in green files.
- **Major discovery**: 4 of the 16 files are already broken and orphaned from the default build target: `DenseFMP.lean`, `DiscreteFMP.lean` (pre-existing elaboration bug — `DerivationTree [] phi` missing the frame-class argument), `RestrictedMCS/Deferral.lean`, and `Algebraic/AlgebraicCompleteness.lean` (unrelated unknown-identifier/type errors). Their breakage predates this task and constrains scoping.
- Recommended approach: leaf-to-root mechanical migration over the 12 green files (+ LindenbaumQuotient's `Derives`), replace the two local duplicate predicates in `Bundle/Construction.lean`, change definition bodies of `Consistent`/`SetConsistent`-adjacent defs in a dedicated phase, and handle the 4 broken orphans by explicit exclusion (with a trivial in-passing fix only for Dense/DiscreteFMP's missing-fc bug, which the migration itself repairs).

## 2. Current State of the Derivable API

`Theories/Bimodal/ProofSystem/Derivable.lean` (task 181, imports only `Aesop`, `Bimodal.ProofSystem.Derivation`, `Bimodal.Syntax.Context` — **no import-cycle risk** adding it anywhere in Metalogic/):

```lean
def Derivable (fc : FrameClass) (G : Context) (p : Formula) : Prop :=
  Nonempty (DerivationTree fc G p)
```

Provided: `Derivable.ofTree`, `Derivable.lift`, `Derivable.ax`/`assume` (`@[aesop safe apply, simp]`), `mp` (`@[aesop unsafe 50% apply]`), `weaken`/`nec`/`temp_nec`/`temp_dual` (`@[aesop safe apply]`), notations `G |-![fc] p`, `|-![fc] p`, `G |-! p`, `|-! p`.

Exposed via the `Bimodal.ProofSystem` aggregator (`Theories/Bimodal/ProofSystem.lean:3`), which `Core/MaximalConsistent.lean` imports directly; every target file except `ConservativeExtension/Lifting.lean` sees `Derivable` transitively already (verified via import-chain trace). **Only `Lifting.lean` needs a new `import Bimodal.ProofSystem.Derivable`** (its chain stops at `ProofSystem.Derivation`).

Seed drift note: the seed (2026-05-22) predates the frame-class parameterization of `Derivable` and `Consistent`. Both now carry `fc`; `Consistent {fc : FrameClass} (Γ : Context)` takes `fc` **implicitly**, so call sites use `Consistent (fc := fc) Γ`.

## 3. Site Inventory and Classification

### 3.1 Green, build-reachable files (migrate these)

| File | Sites (line: kind) |
|------|--------------------|
| `Metalogic/Core/MaximalConsistent.lean` | 59: **def body** `Consistent`; 356, 369: lemma conclusions (`inconsistent_derives_bot`, `derives_neg_from_inconsistent_extension`); 492: proof-internal `have` |
| `Metalogic/Core/MCSProperties.lean` | 93, 192: proof-internal `have ⟨d_bot⟩ : Nonempty (...)` |
| `Metalogic/Core/RestrictedMCS/Basic.lean` | 157, 201: proof-internal `have`; 401: statement hypothesis (`restricted_mcs_from_formula`) |
| `Metalogic/Bundle/Construction.lean` | 107: **def body** `ContextConsistent`; 168: **def body** `ContextDerivable`; 180: statement hypothesis |
| `Metalogic/BXCanonical/Chronicle/RRelation.lean` | 132: **def body** `deductiveClosure`; 707: proof-internal `∃ L, ... ∧ Nonempty (...)`; 1122: statement conclusion; (705: comment) |
| `Metalogic/BXCanonical/Chronicle/PointInsertion.lean` | 568: statement (disjunct `∃ beta ∈ B, Nonempty (...)`); 1233: statement hypothesis; 3291, 3307, 3450, 3466: proof-internal `suffices`/`have`; (876, 877: comments) |
| `Metalogic/Decidability/FMP/ClosureMCS.lean` | 227: statement hypothesis |
| `Metalogic/Decidability/FMP/FMP.lean` | 58, 140, 194, 208: statement hypotheses/conclusions; 63: proof-internal `have` |
| `Metalogic/Decidability/Correctness.lean` | 125, 135: statement conclusions (`fmp_completeness`, `fmp_incompleteness_witness`) |
| `Metalogic/Algebraic/ParametricCompleteness.lean` | 115, 189, 225, 256, 295: statement hypotheses (all fully-qualified `Bimodal.ProofSystem.DerivationTree`) |
| `Metalogic/BXCanonical/Completeness.lean` | 64: statement hypothesis; 136, 178, 235, 277: statement conclusions (`completeness`, `completeness'`, dense/discrete variants); 142: proof-internal `have` using `not_nonempty_iff.mpr`; (20, 25: docstring) |
| `Metalogic/Algebraic/LindenbaumQuotient.lean` | 40: **def body** `Derives (φ ψ) := Nonempty (⊢ (φ.imp ψ))` — notation-based, missed by the seed's grep; file builds (one pre-existing sorry at :169, unrelated) |

### 3.2 Green but orphaned from default build (migrate; verify with scoped build)

| File | Sites | Note |
|------|-------|------|
| `Metalogic/ConservativeExtension/Lifting.lean` | 685: statement conclusion (`lift_derivation_qfree`) | Builds fine, but nothing outside `ConservativeExtension/` imports it — not reachable from the `Bimodal` root. Needs `import Bimodal.ProofSystem.Derivable` added. |

### 3.3 Broken, orphaned files (pre-existing breakage — NOT caused by, and mostly not fixable by, this task)

| File | Sites | Breakage | Recommendation |
|------|-------|----------|----------------|
| `Decidability/FMP/DenseFMP.lean` | 63, 75 | `DerivationTree [] phi` — missing fc argument; elaboration error (`List ?m` vs `FrameClass`). Only importer is `Decidability/FMP.lean` (aggregator), which itself has **no importers**. | Migrating the two sites to `¬Derivable FrameClass.Base [] phi` / `Derivable FrameClass.Base [] phi` **fixes the file as a side effect** (the delegated-to `mcs_finite_model_property` is Base). Cheap win — include. |
| `Decidability/FMP/DiscreteFMP.lean` | 63, 75 | Identical missing-fc bug. | Same trivial fix — include. |
| `Core/RestrictedMCS/Deferral.lean` | 149, 175, 233, 637 | Unknown identifiers `closure_F_bound`, `iter_F`, `iter_F_exceeds_max_depth`, ... (~15 errors). Only importer is `Core/Core.lean`, which has no importers. | **Exclude.** Breakage is structural and unrelated. Do text-level substitution only if desired for grep-cleanliness, but do not gate the task on this file building. Flag for a separate repair/abandon decision. |
| `Algebraic/AlgebraicCompleteness.lean` | 59 (**def body** `AlgConsistent`), 188 (notation form `¬Nonempty (⊢ φ.neg)`), + `unfold AlgConsistent` at 73, 143 | Error at :156 "Function expected" (unrelated). Only importer is `Algebraic/Algebraic.lean`, which has no importers. | **Exclude** from build-gated migration, same reasoning as Deferral. |

Orphaned aggregators discovered in passing (no importers, candidates for cleanup or re-wiring, out of scope): `Metalogic/Decidability/FMP.lean`, `Metalogic/Core/Core.lean`, `Metalogic/Algebraic/Algebraic.lean`.

### 3.4 Comments/docstrings (5 sites)

`BXCanonical/Completeness.lean:20,25`, `RRelation.lean:705`, `PointInsertion.lean:876,877` — update wording opportunistically; zero risk.

## 4. Local Duplicate Predicates (Bundle/Construction.lean)

- `ContextConsistent (Gamma) := ¬Nonempty (DerivationTree .Base Gamma ⊥)` (line 107) — duplicate of `Consistent (fc := .Base)`.
- `ContextDerivable (Γ φ) := Nonempty (DerivationTree .Base Γ φ)` (line 168) — duplicate of `Derivable .Base`.

**Verified: neither has any call site outside `Construction.lean` itself** (grep across Theories/ and Tests/, Boneyard excluded). Two options:
- (a) Delete both and inline `Consistent (fc := FrameClass.Base)` / `Derivable FrameClass.Base` at their ~8 internal use sites (`lindenbaumMCS*`, `not_derivable_implies_neg_consistent`, ...). Preferred — removes duplication permanently.
- (b) Keep as `abbrev`s over the canonical predicates. Only if (a) causes friction with elaboration of dependent proofs.

## 5. Machine-Verified Compatibility Facts

All six patterns compiled clean this session against current master (via `lean_run_code`):

1. `obtain ⟨d⟩ := (h : Derivable fc G p)` destructures (rcases unfolds the def).
2. `⟨d⟩ : Derivable fc G p` from `d : DerivationTree fc G p` (anonymous constructor).
3. `not_nonempty_iff.mpr : IsEmpty (DerivationTree fc [] p) → ¬Derivable fc [] p` unifies through the def (relevant to `BXCanonical/Completeness.lean:142`).
4. `Consistent (fc := fc) G ↔ ¬Derivable fc G Formula.bot := Iff.rfl`.
5. Term-position interchange both directions: `h : Nonempty (DerivationTree fc G p)` accepted where `Derivable fc G p` expected, and vice versa.
6. `(h : ¬Derivable fc G ⊥) : Consistent (fc := fc) G` — direct term acceptance.

Consequence: **statement-level and proof-internal replacements are pure text substitutions**; downstream term-mode consumers of migrated theorems (`inconsistent_derives_bot`, `fmp_contrapositive`, `completeness`, ...) keep type-checking by defeq without edits.

## 6. Risk Analysis

| Risk | Assessment |
|------|------------|
| `unfold Consistent` / `unfold SetConsistent` sites (≈29 across Metalogic, incl. files outside the 16: `UltrafilterMCS`, `SuccRelation`, `SharedWitness`, `Metalogic/Completeness.lean`) | Only triggered if **definition bodies** change. Pattern audit: all are `unfold` + `push_neg` + `exact`/`intro ⟨d⟩` — all defeq-tolerant (Section 5 patterns 1, 5, 6). No `rw [Consistent]` or `simp only [Consistent]` sites exist. Low risk, but this is why body changes get their own phase + full `lake build`. |
| `Derivable` not in scope | Only `Lifting.lean`; add one import. Cycle-safe (Derivable imports nothing in Metalogic). |
| Notation collision | `G |-! p` fixes `fc := .Base`. Sites with variable `fc` (RRelation, PointInsertion, MCSProperties, MaximalConsistent, Lifting, Completeness:64) must use `Derivable fc ...` or `G |-![fc] p`, not the Base notation. |
| aesop/simp behavior shift | `Derivable.ax`/`assume` are `@[simp]`/`@[aesop safe]`. Rewriting *statements* into `Derivable` form makes goals newly visible to these rules. Existing proofs don't invoke aesop on such goals today, so no expected breakage; if a `simp` closes differently, it closes *more*, not less. Monitor at phase builds. |
| Broken orphan files | Pre-existing; excluded from the build gate (except Dense/DiscreteFMP whose only errors are exactly the sites being migrated). Zero-debt gate applies to the files this task touches and the default target staying green. |
| Public statement shape change | `completeness : valid φ → Nonempty (DerivationTree ...)` becomes `valid φ → Derivable .Base [] φ`. Defeq-safe for all consumers (pattern 5); grep found no consumer doing syntactic matching on the `Nonempty` head. |

## 7. Recommended Migration Order (leaf-to-root along the import DAG)

Each phase: edit → scoped `lake build <modules>` → commit. Final phase: full `lake build`.

1. **Phase 1 — Core statements** (`MaximalConsistent.lean` sites 356/369/492, `MCSProperties.lean` 93/192, `RestrictedMCS/Basic.lean` 157/201/401). Statement + proof-internal sites only; do NOT touch the `Consistent` body yet.
2. **Phase 2 — Definition bodies** (`Consistent` :59 → `¬Derivable fc Γ Formula.bot`; `deductiveClosure` RRelation:132; `Derives` LindenbaumQuotient:40 → `Derivable .Base [] (φ.imp ψ)`). Verify with **full `lake build`** (bodies radiate to all `unfold` sites, incl. WeakCanonical/SharedWitness).
3. **Phase 3 — Bundle/Construction.lean**: delete `ContextConsistent`/`ContextDerivable`, inline canonical predicates (option (a), Section 4); migrate site 180.
4. **Phase 4 — Chronicle** (`RRelation.lean` 707/1122 + comment 705; `PointInsertion.lean` 568/1233/3291/3307/3450/3466 + comments). Largest file (~3,500 lines) — keep to its own phase.
5. **Phase 5 — FMP/Decidability** (`ClosureMCS.lean` 227, `FMP/FMP.lean` 58/63/140/194/208, `Correctness.lean` 125/135) **+ Dense/DiscreteFMP repair**: replace `¬Nonempty (DerivationTree [] phi)` → `¬Derivable FrameClass.Base [] phi` (and positive form at :75), which simultaneously fixes their pre-existing elaboration bug. Verify with `lake build Bimodal.Metalogic.Decidability.FMP.DenseFMP ...DiscreteFMP` explicitly (they are outside the default target).
6. **Phase 6 — Completeness layer** (`ParametricCompleteness.lean` 5 sites, `BXCanonical/Completeness.lean` 6 sites + docstrings). Site :142 (`not_nonempty_iff.mpr`) verified safe.
7. **Phase 7 — Lifting.lean**: add `import Bimodal.ProofSystem.Derivable`, migrate site 685; `lake build Bimodal.Metalogic.ConservativeExtension.Lifting` (orphan — scoped build required).
8. **Phase 8 — Sweep + full verification**: `grep -rn "Nonempty (DerivationTree\|Nonempty (⊢" Theories/ --exclude-dir=Boneyard` must return only `Derivable.lean`'s own definition, `Deferral.lean`, and `AlgebraicCompleteness.lean` (documented exclusions); full `lake build` green.

Excluded (document in summary, decide separately): `Deferral.lean`, `AlgebraicCompleteness.lean` (broken for unrelated reasons + orphaned; candidate follow-up task for repair-or-boneyard), the three orphaned aggregators.

## 8. Effort Estimate

- ~51 code sites + 5 comments across 15 files (12 green-reachable, 1 green-orphan, 2 trivially-repairable orphans); 1 new import; 2 defs deleted, 3 def bodies rewritten.
- All substitutions defeq-verified; expected proof churn ≈ 0. Estimated 8 phases, each one agent dispatch, small (3-6 h total).
- Sorry delta: 0 (no sorries added; pre-existing `LindenbaumQuotient.lean:169` sorry untouched).

## 9. Key Answers to Seed Questions

1. **Non-standard uses?** Yes: notation-based `Nonempty (⊢ ...)` in `LindenbaumQuotient.lean:40` (live) and `AlgebraicCompleteness.lean:188` (dead); and `DerivationTree [] phi` in Dense/DiscreteFMP is an outright pre-existing bug the migration fixes. Everything else is the standard pattern.
2. **`Consistent` body change breakage?** No — all 29 `unfold`-family sites use defeq-tolerant tactic patterns (verified categories); bridge is `Iff.rfl` (machine-checked).
3. **Import cycles?** None possible: `Derivable.lean` imports nothing in Metalogic; 15/16 files already see it transitively.
4. **Change `Consistent` body?** Yes, in its own phase (Phase 2) gated by a full build — it makes `Consistent`/`Derivable` visually coherent and costs nothing given defeq tolerance.
