# Implementation Plan: Task #139

- **Task**: 139 - Build FO satisfaction infrastructure for monadic structures
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: Task 129 (completed)
- **Research Inputs**: specs/139_fo_satisfaction_monadic_structures/reports/01_team-research.md
- **Artifacts**: plans/01_fo-satisfaction-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This task replaces the placeholder monadic FO infrastructure in `NEquivalence.lean` with a genuine first-order satisfaction relation, closing the k-equivalence sorry chain that blocks the Reynolds pipeline. The current `MonadicSentence` type has three fatal design flaws (no variable binding, nullary `lt`, missing `exists`), `KType` uses an incorrect `Finset`-based representation, and `k_type_of` is entirely sorried. The plan redesigns `MonadicSentence` as `MonadicFormula sig n` with De Bruijn `Fin n` variables, implements Tarski `eval`, redefines `KType` as a truth-assignment function type, proves the finiteness of depth-bounded formulas, and updates the `KEquivalenceFramework` instance. Downstream breakage in `IntegerModel.lean` and `OrderedSum.lean` is addressed by rewriting proofs to use genuine semantic arguments. The `table` definition in `Table.lean` is updated for compatibility with Task 140. Definition of done: `lake build` succeeds, the 3 NEquivalence sorries (`ktype_finite`, `k_type_of`, `finite_types`) are closed, and `sum_preservation` carries an explicit deferred-sorry with TODO marker.

### Research Integration

The team research report (4 teammates, all converging) identified the following key design decisions integrated into this plan:

- **MonadicFormula with De Bruijn variables**: All teammates agree on `Fin n` indexing following Reynolds 1994 Section 6 and Doets 1987 Chapter 1. Minimal constructors (no `or`) to reduce proof cases.
- **KType as truth-assignment function**: `{s : MonadicFormula sig 0 // s.quantifier_depth <= k} -> Bool` instead of `Finset (MonadicSentence sig)`. Gives immediate `Fintype` via `Fintype.Pi.fintype` once the domain is proved finite.
- **Eval by structural recursion**: Using `Fin.cons` for quantifier binding. Decidability follows from `Fintype.decidableForallFintype` and `Fintype.decidableExistsFintype` for finite carriers.
- **Downstream sorry-propagation cascade**: All proofs in `IntegerModel.lean` and `OrderedSum.lean` that use `simp only [k_equiv, k_type_of]` reducing to `sorry = sorry` will break once `k_type_of` has a genuine definition.
- **sum_preservation deferred**: Doets Lemma 1.4 requires EF-game formalization -- all teammates recommend deferring to a follow-up task.
- **table co-design**: Define `table` as `MonadicFormula sig 1` in Task 139 (definition only), prove correctness in Task 140.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances the following ROADMAP.md items:
- "3 sorries in NEquivalence.lean: ktype_finite, k_type_of, finite_types (KEquivalenceFramework) -- task 139"
- Critical path: Task 129 (COMPLETED) -> **139 (this task)** -> 140 -> 141 -> 142 -> sorry-free `bx_completeness`
- Discrete completeness sorry count reduction from 5 to 2 (the remaining 2 are in Table.lean for Task 140)

## Goals & Non-Goals

**Goals**:
- Redesign `MonadicSentence` as `MonadicFormula sig n` with De Bruijn `Fin n` variable binding
- Implement Tarski satisfaction (`eval`) by structural recursion
- Redefine `KType` as truth-assignment function type and close `ktype_finite`
- Implement `k_type_of` genuinely (no sorry) and close `finite_types` in `KEquivalenceFramework`
- Prove `Fintype {s : MonadicFormula sig n // s.quantifier_depth <= k}` by induction on k
- Update `table` definition signature to `MonadicFormula sig 1` (body still sorry, for Task 140)
- Fix all downstream compilation errors in `IntegerModel.lean`, `OrderedSum.lean`, `Table.lean`, and `Transfer.lean`

**Non-Goals**:
- Prove `sum_preservation` (Doets Lemma 1.4) -- deferred, requires EF-game formalization
- Prove `table_depth_bound` or `table` correctness -- Task 140 scope
- Close `mkSigFrom` / `mkAtomMap` stubs in `Transfer.lean` -- Task 140 scope
- Replace the chronicle fallback in `Transfer.lean` -- requires truth transfer (Task 140)
- Prove genuine `contemp_equiv.trans`, `no_gaps_discrete`, `very_good_implies_good`, or `chronicle_is_good` -- these require `sum_preservation` and deeper model-theoretic arguments

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Fintype` proof for depth-bounded formulas is harder than expected | H | M | Start with explicit enumeration for small k; fall back to well-founded recursion on formula structure |
| Universe polymorphism conflicts between `MonadicStructure.carrier : Type` and Mathlib `Fintype` | M | L | Test universe levels early in Phase 2; `KEquivalenceFramework` is already `Type 1` so the pattern is established |
| Downstream proof repair is more extensive than estimated | M | M | Budget generous time in Phase 5; accept sorry placeholders with TODO markers for proofs that genuinely require `sum_preservation` |
| `eval` decidability for infinite carriers blocks `k_type_of` | H | L | `k_type_of` only needs `eval` at the propositional level (sentences have 0 free variables); decidability only needed for finite carrier structures used in `finite_structures_good` |
| Breaking changes cascade beyond WeakCanonical directory | M | L | Grep for all imports of NEquivalence.lean before starting; the blast radius should be limited to WeakCanonical/ |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Redesign MonadicFormula Type and quantifier_depth [COMPLETED]

**Goal**: Replace `MonadicSentence sig` with `MonadicFormula sig n` using De Bruijn `Fin n` variables, add `exists` constructor, fix `atom` and `lt` signatures, and define `quantifier_depth`.

**Tasks**:
- [x] Replace the `MonadicSentence` inductive with `MonadicFormula sig n` inductive containing constructors: `atom (p : sig.preds) (i : Fin n)`, `lt (i j : Fin n)`, `not`, `and`, `all` (binding `n+1 -> n`), `ex` (binding `n+1 -> n`) *(deviation: altered -- used `all`/`ex` instead of `forall`/`exists` to avoid clashing with Lean keywords)*
- [x] Define `abbrev MonadicSentence (sig) := MonadicFormula sig 0`
- [x] Redefine `MonadicFormula.quantifier_depth` for the new type (unchanged for atom/lt/not/and, +1 for all/ex)
- [x] Add `DecidableEq` instance for `MonadicFormula sig n` (derived via `deriving DecidableEq`)
- [x] Verify NEquivalence.lean compiles in isolation (downstream breakage expected)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- type redesign

**Verification**:
- `MonadicFormula sig n` compiles with all 6 constructors
- `MonadicSentence sig` is an abbreviation for `MonadicFormula sig 0`
- `quantifier_depth` compiles without sorry

---

### Phase 2: Implement eval, Redefine KType and k_type_of [COMPLETED]

**Goal**: Implement Tarski satisfaction (`eval`), redefine `KType` as a truth-assignment function type, and provide a genuine (sorry-free) definition of `k_type_of`.

**Tasks**:
- [x] Define `eval` by structural recursion on `OrderedMonadicStructure sig` *(deviation: altered -- eval takes OrderedMonadicStructure instead of MonadicStructure, since lt evaluation requires LinearOrder on carrier)*
- [x] Add `Decidable` instance for `eval` *(deviation: altered -- using Classical.dec in k_type_of instead of a standalone Decidable instance, since carrier may be infinite)*
- [x] Redefine `KType sig k := {s : MonadicFormula sig 0 // s.quantifier_depth <= k} -> Bool`
- [x] Redefine `k_type_of` as genuine (sorry-free) definition using eval and Classical.dec
- [x] Redefine `k_equiv` to use the new `k_type_of`
- [x] Prove `k_equiv_monotone` genuinely via funext and congr_fun
- [x] Verify the redefined types compile (downstream files will break)

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- eval, KType, k_type_of, k_equiv, k_equiv_monotone

**Verification**:
- `eval` compiles by structural recursion without sorry
- `k_type_of` has a genuine definition (may need Decidable assumptions on the structure)
- `k_equiv` and `k_equiv_monotone` compile

---

### Phase 3: Prove ktype_finite and Close KEquivalenceFramework finite_types [PARTIAL]

**Goal**: Prove that depth-bounded formulas form a `Fintype`, then use this to close `ktype_finite` and the `finite_types` field of `KEquivalenceFramework`.

**Tasks**:
- [ ] **Task 3.1**: Prove `Fintype {s : MonadicFormula sig n // s.quantifier_depth <= k}` *(deviation: skipped -- depth-bounded formulas are syntactically infinite due to unbounded not/and nesting; this is a mathematical error in the plan. Doets 1989 Lemma 1.1 proves finiteness of SEMANTICALLY distinct formulas, not syntactic ones.)*
- [ ] **Task 3.2**: Close `ktype_finite` *(deviation: deferred -- depends on Task 3.1 which is infeasible as stated)*
- [ ] **Task 3.3**: Close `finite_types` in `KEquivalenceFramework` instance *(deviation: deferred -- requires Doets' theorem on finite k-type count, which needs semantic equivalence quotient)*
- [x] **Task 3.4**: Update `equiv_is_equiv` to use genuine k_equiv (equality is trivially an equivalence)
- [x] **Task 3.5**: Update `equiv_monotone` to use genuine `k_equiv_monotone`
- [x] **Task 3.6**: Keep `sum_preservation` as sorry with TODO comment

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- finiteness proofs, KEquivalenceFramework instance

**Verification**:
- `ktype_finite` compiles without sorry
- `KEquivalenceFramework` instance compiles with only `sum_preservation` sorry remaining
- `lake build` on NEquivalence.lean succeeds (downstream files still expected to break)

---

### Phase 4: Update Table.lean for MonadicFormula sig 1 [COMPLETED]

**Goal**: Update the `table` definition signature to use `MonadicFormula sig 1` (one free variable) and adjust `table_depth_bound` to match. Both bodies remain sorry for Task 140.

**Tasks**:
- [x] Update `table` signature from `MonadicSentence sig` to `MonadicFormula sig 1`
- [x] Update `table_depth_bound` to reference the new type
- [x] Both bodies remain `sorry` with TODO markers referencing Task 140
- [x] Table.lean compiles with NEquivalence.lean changes

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` -- signature updates

**Verification**:
- `Table.lean` compiles with only the expected 2 sorries (`table`, `table_depth_bound`)
- `table` returns `MonadicFormula sig 1`

---

### Phase 5: Fix Downstream Breakage in IntegerModel.lean, OrderedSum.lean, Transfer.lean [COMPLETED]

**Goal**: Repair all downstream compilation errors caused by the type redesign. Proofs that previously worked via sorry-propagation (`simp only [k_equiv, k_type_of]` reducing to `sorry = sorry`) need rewriting. Where genuine mathematical arguments require `sum_preservation` (still sorry), use explicit sorry with TODO markers.

**Tasks**:
- [x] Fix `OrderedSum.lean`: Updated all signatures to use `OrderedMonadicStructure` for `k_equiv`. `doets_lemma_1_4`, `doets_lemma_1_5` sorried with TODO markers. `finite_structures_k_equiv_to_Z_interval` uses reflexivity.
- [x] Fix `IntegerModel.lean`: Updated `good` to use `ZIntervalStructure.toOrdered`. `finite_structures_good` sorried (needs Doets Theorem 1.1). `contemp_equiv_is_equiv.refl` and `no_boundary_at_successor` proved via Fintype instances. `contemp_equiv_is_equiv.trans`, `no_gaps_discrete`, `very_good_implies_good`, `chronicle_is_good` sorried with TODO markers. *(deviation: altered -- finite_structures_good now requires genuine k-type realizability argument, not just sorry propagation)*
- [x] Fix `Transfer.lean`: No changes needed -- the file compiled as-is with the new types.
- [x] `lake build` succeeds (1644 jobs, no errors)
- [x] No other files outside WeakCanonical import NEquivalence

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- proof repairs
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- proof repairs
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- type compatibility

**Verification**:
- `lake build` succeeds with no errors
- All remaining sorries are explicitly marked with TODO comments indicating which follow-up task owns them
- Sorry count in NEquivalence.lean reduced from 3 to 1 (`sum_preservation` only)
- Total sorry count across WeakCanonical does not increase beyond what is justified by deferred `sum_preservation`

---

## Testing & Validation

- [ ] `lake build` succeeds on the full project after all phases
- [ ] `ktype_finite` in NEquivalence.lean is sorry-free
- [ ] `k_type_of` in NEquivalence.lean is sorry-free
- [ ] `finite_types` in KEquivalenceFramework instance is sorry-free
- [ ] `eval` correctly evaluates formulas by structural recursion (no sorry)
- [ ] `MonadicFormula sig n` has all 6 constructors (atom, lt, not, and, forall, exists)
- [ ] `table` signature is `MonadicFormula sig 1` (not `MonadicSentence sig`)
- [ ] `sum_preservation` has explicit TODO marker for deferred sorry
- [ ] All downstream files (IntegerModel, OrderedSum, Table, Transfer) compile
- [ ] No increase in sorry count beyond justified `sum_preservation` and downstream proofs that depend on it
- [ ] Grep for remaining sorry calls and verify each is documented

## Artifacts & Outputs

- `specs/139_fo_satisfaction_monadic_structures/plans/01_fo-satisfaction-plan.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (primary implementation)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` (signature update)
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (downstream repair)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` (downstream repair)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (downstream repair)
- `specs/139_fo_satisfaction_monadic_structures/summaries/01_fo-satisfaction-summary.md` (post-implementation)

## Rollback/Contingency

If the `Fintype` proof for depth-bounded formulas proves intractable within the time budget:
1. Fall back to axiomatizing the finiteness as a `sorry` with detailed documentation of the gap
2. Still close `k_type_of` (does not depend on finiteness) and `eval`
3. The downstream repairs remain valid regardless

If universe polymorphism conflicts arise:
1. Use `universe u` annotations explicitly on `MonadicStructure` and `MonadicFormula`
2. Match the existing `Type 1` pattern from `KEquivalenceFramework`

Git rollback: all changes are in the `Theories/Bimodal/Metalogic/WeakCanonical/` directory and `specs/139_*/`. A `git stash` or `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/` reverts to the pre-task state.
