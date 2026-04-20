# Teammate D Findings: Strategic Horizons and Long-term Alignment

## Key Findings

### 1. Sorry Landscape is Larger Than Task 109 Describes

The existing report (01) identifies 11 sorry sites (6 CanonicalModel + 5 RootScopedChain). The ROADMAP expands this to **23 BXCanonical sorries** (5 critical-path + 18 irreflexive-consequence). But the full picture across non-Boneyard, non-Example code is **40 sorry sites** across 11 files:

| File | Count | On `bx_completeness` path? |
|------|-------|---------------------------|
| RootScopedChain.lean | 5 | **YES** (critical path) |
| CanonicalModel.lean | 6 | **YES** (dependency of RootScopedChain) |
| Frame.lean | 1 | **YES** (`bx_le_refl`, intentionally invalid) |
| TruthLemma.lean | 2 | **YES** (irreflexive consequence) |
| Construction.lean | 2 | **YES** (irreflexive consequence) |
| Realization.lean | 4 | **YES** (irreflexive consequence) |
| SigmaOrdering.lean | 3 | **YES** (irreflexive consequence) |
| ParametricTruthLemma.lean | 2 | **NO** -- RestrictedParametricTruthLemma is sorry-free and provides its own proof |
| SuccRelation.lean | 3 | **INDIRECT** -- imported via UntilSinceCoherence, but sorry'd lemmas may not be called |
| SuccExistence.lean | 3 | **INDIRECT** -- imported via RestrictedMCS chain |
| TemporalDerived.lean | 9 | **INDIRECT** -- imported via UntilSinceCoherence + WitnessSeed |

**Critical observation**: The 2 sorries in `ParametricTruthLemma.lean` are **NOT** on the critical path. `RootScopedChain.lean` uses the `RestrictedParametricTruthLemma` which has its own sorry-free proof. The sorry'd `parametric_shifted_truth_lemma` is only used by `ParametricRepresentation.lean`, which provides `parametric_representation_from_neg_membership` -- but `dd_countermodel` uses `fully_restricted_parametric_representation_from_neg_membership` instead. This is a relief.

**Hidden dependency risk**: The 15 sorries in SuccRelation (3), SuccExistence (3), and TemporalDerived (9) are transitive dependencies via `UntilSinceCoherence` and `WitnessSeed`. If any sorry'd lemma in these files is actually invoked on the path from `bx_completeness` to its sorry'd leaves, closing the 23 BXCanonical sorries would still leave `bx_completeness` depending on `sorry`. A `#print axioms bx_completeness` audit (task 95) after closing BXCanonical sorries would catch this.

### 2. This is NOT the Last Obstacle

After closing all 23 BXCanonical sorries, the `#print axioms` audit (task 95) may reveal:
- Transitive sorry dependencies through SuccRelation/SuccExistence/TemporalDerived
- The 9 TemporalDerived sorries include `H_bot_absurd`, `density_derivable`, `past_density_derivable`, `G_implies_topUntil`, `psi_imp_since`, `refl_P` -- several of which are derivability lemmas that could be called by infrastructure code

**Recommendation**: Before deep-diving into task 109 implementation, run a dependency trace from `bx_completeness` to identify exactly which sorry sites are reachable. A Lean `#print axioms` on the current sorry'd code would show `sorryAx` if any sorry is reachable.

### 3. No `#print axioms` Checks Exist

There are **zero** `#print axioms` statements anywhere in `Theories/`. Task 95 is planned for this but depends on task 109. Adding `#print axioms bx_completeness` now (even with sorries present) would immediately reveal the full sorry dependency tree.

### 4. The Irreflexive Semantics Switch Created a Structural Debt

The ROADMAP documents the irreflexive semantics switch (task 93) as creating 18 "irreflexive-consequence" sorries. Many of these (e.g., `bx_le_refl`, `g_content_subset_self`, `sigma_le_refl`) are **mathematically false** under the new semantics. They are not bugs to fix but **architectural assumptions to replace**.

The 4 genuinely false/unprovable theorems (#2, #4, #5, #6 from the report) must be deleted and their callers redesigned, not proved.

## Strategic Assessment

### The Core Obstruction is Well-Understood

The ROADMAP's "Dead Ends" section (36 entries!) documents an extraordinary depth of investigation. The core obstruction is clearly identified: the gap between semantic temporal reasoning and syntactic MCS membership, caused by Lindenbaum extension non-determinism (`Classical.choose`).

The irreflexive semantics switch (plan v48) was designed precisely to break this obstruction by making `phi -> F(phi)` non-derivable, which enables a finite descent argument on active defects. The ROADMAP states: "Under irreflexive semantics, the active defect count strictly decreases at each chain step."

**Assessment**: The mathematical strategy is sound. The question is whether the Lean formalization can carry it through.

### The Defect Descent Argument is the Crux

The 5 critical-path sorries all reduce to one core argument: proving that `fwd_chain_forward_F` terminates. The infrastructure is in place:
- `defect_step_early` gives: for each defect chi, either `chi in M'` (resolved) or `F(chi) in M'` (pending)
- Under irreflexive semantics, resolved defects do NOT re-enter
- `sigma_list` is finite, bounding the descent

The ROADMAP claims this is "Phase 3-4 remaining work" from plan v48. The other 4 critical-path sorries (`restricted_tc` forward/backward, `restricted_buc`, `restricted_fuc`) are downstream of `fwd_chain_forward_F`.

## Architecture Analysis

### Module Structure is Sound

The BXCanonical module (5,829 lines, 16 files) has a clean separation:
- **Frame.lean**: Points and ordering (BXPoint, bx_le)
- **TruthLemma.lean**: Formula induction
- **Quasimodel/**: Hintikka-set defect discharge (6 files, sorry-free for Until/Since)
- **Filtration/**: Sigma-restricted ordering (2 files)
- **CanonicalModel.lean**: Chain construction
- **RootScopedChain.lean**: Final wiring to dd_countermodel

The `Completeness.lean` file is already sorry-free -- it delegates everything to `dd_countermodel` in `RootScopedChain.lean`. This is architecturally clean.

### Blast Radius of Different Approaches

**Approach 1: Close the 5 critical-path sorries via defect descent** (recommended)
- Blast radius: Small. Only modifies `RootScopedChain.lean` and possibly `CanonicalModel.lean`.
- The 18 irreflexive-consequence sorries need separate treatment but many can be addressed by deleting false lemmas and rewiring callers.
- Risk: Medium. The defect descent argument must work within the existing chain construction.

**Approach 2: Redesign the chain construction** (if Approach 1 fails)
- Blast radius: Large. Would rewrite `CanonicalModel.lean` and `RootScopedChain.lean` (combined ~1,960 lines).
- The quasimodel infrastructure (2,228 lines) would be preserved.
- Risk: High. Previous chain redesigns (see dead ends #1-36) have repeatedly failed.

**Approach 3: Alternative proof architecture** (nuclear option)
- Blast radius: Very large. Would replace the entire BXCanonical module.
- Options include: algebraic semantics, translation-based completeness, step-by-step model construction.
- Risk: Very high. The current infrastructure represents substantial proven work.

### Cascade Analysis

Closing the 23 BXCanonical sorries would affect:
- `Completeness.lean`: Already sorry-free, no changes needed
- `RootScopedChain.lean`: Primary target (5 critical sorries + wiring)
- `CanonicalModel.lean`: 6 sorries, 4 of which are false/unprovable (need deletion + redesign)
- Other files: 12 sorries that are reflexivity artifacts (need `bx_le` redesign or deletion)

No cascade to files outside `BXCanonical/` is expected, since `BXCanonical` is self-contained and only exports `bx_completeness`.

## Alternative Proof Architectures

### Could completeness be proved differently?

1. **Algebraic semantics** (e.g., tense-S5 algebras): The codebase has `TenseS5Algebra.lean` and `BooleanStructure.lean` in the Algebraic directory. However, these are infrastructure files, not an alternative completeness path. Algebraic completeness for bimodal logic with Until/Since is not simpler -- it faces the same eventuality resolution problem.

2. **Translation to a logic with known completeness**: TM could potentially be translated to standard temporal logic (without the modal component) and back. However, the S5 modal component interacts non-trivially with the temporal operators (axioms `modal_future`, `temp_future`), making clean separation difficult.

3. **Step-by-step model construction** (a la Goldblatt 1992): This is essentially what the current approach does. The canonical model IS a step-by-step construction. The difference from Goldblatt is that the current approach builds the chain syntactically (via Lindenbaum extensions) rather than semantically (via model-theoretic witnesses). A semantic approach would require a different truth lemma.

4. **Decidability-to-completeness**: Explicitly excluded by the ROADMAP. The project goal is a representation theorem (canonical model construction), not bare completeness.

**Assessment**: The current architecture is the right one. The BX axiom system is specifically designed for this canonical model approach (Burgess 1982, Xu 1988). The problem is not the architecture but the gap between the mathematical argument and its Lean formalization.

## Verification and Maintenance

### Testing Infrastructure

- Test suite exists at `Tests/BimodalTest/` with directories for Automation, Integration, ProofSystem, Property, Semantics, Syntax, and Theorems.
- `#eval`-based tests exist for proof search automation.
- No `#print axioms` checks anywhere in the codebase.
- Soundness is fully verified: `Soundness.lean`, `DenseSoundness.lean`, and `DiscreteSoundness.lean` are all sorry-free.

### Post-Closure Confidence

After closing all 23 BXCanonical sorries:
- **High confidence** if `#print axioms bx_completeness` shows exactly `{propext, Classical.choice, Quot.sound}`.
- **Medium confidence** without the axiom check, due to the transitive sorry dependencies through SuccRelation/SuccExistence/TemporalDerived.
- The soundness proof being sorry-free provides strong cross-validation: if both soundness and completeness are sorry-free, the system is consistent.

### Recommended Verification Steps

1. Add `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness` immediately (even before closing sorries) to see the current dependency tree
2. After closing sorries, verify the axiom check
3. Add `#print axioms` as a permanent CI check

## Lean Ecosystem Alignment

### Mathlib Conventions

The codebase uses Mathlib for basic infrastructure (`Mathlib.Data.Finset.Powerset`, `Mathlib.Data.List.Chain`, etc.) but does not follow Mathlib's naming conventions consistently. For example:
- Theorem names use `snake_case` (Mathlib convention: good)
- Module organization is project-specific rather than Mathlib-style
- No `@[simp]` annotations on key lemmas visible in the files I examined

### Mathlib Relevance

There are no existing Mathlib formalizations of bimodal temporal logic completeness. The closest Mathlib has is basic modal logic (S5) without temporal operators. This project is novel in the Lean ecosystem.

### Lean 4 Idioms

- Uses Lean 4 v4.27.0-rc1 (recent)
- Uses `structure` for BXPoint, `def` for key constructions
- Classical logic throughout (`Classical.choice` expected in axioms)
- `noncomputable` annotations where needed
- Good use of `DerivationTree` inductive type for proof terms

## Recommendations

### Immediate Actions

1. **Add `#print axioms bx_completeness` now** to get a baseline dependency picture.
2. **Trace sorry dependencies** from `dd_countermodel` to identify which of the 40 sorries are actually reachable. This determines whether task 109 is truly "close 23 sorries" or potentially more.
3. **Delete the 4 genuinely false lemmas** (`g_content_subset_self`, `h_content_subset_self`, `fwd_succ_f_carry`, `bwd_pred_p_carry`) and their callers before attempting the defect descent argument.

### Strategic Priorities

1. **Focus on `fwd_chain_forward_F`** (RootScopedChain.lean:1065). This is the keystone sorry. The other 4 critical-path sorries are downstream. The mathematical argument (finite descent on active defects under irreflexive semantics) is sound per the ROADMAP analysis.

2. **Handle the 18 irreflexive-consequence sorries as architectural cleanup**, not proof obligations. Many are false and need deletion. The genuine ones (e.g., `enriched_seed_consistent` via seriality) have known proof strategies.

3. **Task 95 (`#print axioms` audit) should be unblocked early** by adding the check before all sorries are closed. This identifies hidden dependencies immediately rather than after weeks of work.

### Long-term Vision

The project is attempting something genuinely novel: a machine-checked completeness theorem for bimodal tense logic with Until/Since in Lean 4. No comparable formalization exists in any proof assistant. The architectural approach (canonical model via Hintikka-set quasimodel with defect discharge) is mathematically sound and has been validated by closing the hardest cases (Until/Since eventuality resolution in Frame.lean).

The remaining work is primarily a formalization challenge, not a mathematical one. The irreflexive semantics switch was designed to make the finite descent argument work, and the ROADMAP's analysis of why it should work is convincing.

## Confidence Level

**Medium-High**

- **High confidence** that the mathematical strategy (defect descent under irreflexive semantics) is correct
- **Medium confidence** that the formalization can carry it through without major redesign
- **Medium confidence** that closing BXCanonical's 23 sorries suffices for a clean `#print axioms` (the transitive sorry dependencies through SuccRelation/TemporalDerived are a risk)
- **Low confidence** in time estimates (the 36 documented dead ends suggest this problem is resistant to quick resolution)
