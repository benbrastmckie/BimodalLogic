# Teammate C (Critic) Findings: Task 129 Audit

**Date**: 2026-05-14
**Role**: Critic — identify gaps, errors, dead code, and blind spots
**Scope**: WeakCanonical directory (NEquivalence, OrderedSum, IntegerModel, Transfer, Table, ChronicleExtraction)

## Key Findings (Critical Issues First)

### 1. BUILD IS BROKEN — Duplicate `ZStructure` Definition

**Severity**: CRITICAL (blocks all downstream work)

The uncommitted changes to `NEquivalence.lean` add `ZStructure` (line 185) and `ZStructure.toMonadic` (line 192), which are already defined in `IntegerModel.lean` (lines 49 and 66). Since IntegerModel imports NEquivalence transitively (via OrderedSum), Lean rejects the redefinition:

```
error: `Bimodal.Metalogic.WeakCanonical.ZStructure` has already been declared
error: `Bimodal.Metalogic.WeakCanonical.ZStructure.toMonadic` has already been declared
```

**The plan and summary claim "1644 jobs, passes" — this is false in the current working tree.** The committed version builds, but the uncommitted NEquivalence.lean changes break it.

**Fix**: Remove `ZStructure` and `ZStructure.toMonadic` from NEquivalence.lean. The `z_model_exists` field in `KEquivalenceFramework` references `ZStructure`, so it needs to either import IntegerModel (circular) or the `ZStructure` definition must live in NEquivalence while being removed from IntegerModel. The cleanest fix: keep `ZStructure` in NEquivalence (where `KEquivalenceFramework.z_model_exists` references it) and remove the duplicate from IntegerModel.

### 2. `KEquivalenceFramework.z_model_exists` Axiomatizes the Theorem Itself

**Severity**: HIGH (architectural concern)

The `z_model_exists` field added to `KEquivalenceFramework` axiomatizes Reynolds Theorem 15 — the very theorem the pipeline is trying to prove. This is architecturally circular:

- The task's goal is to prove `chronicle_is_good` (which is Reynolds Theorem 15)
- But `KEquivalenceFramework.z_model_exists` assumes Theorem 15 as an axiom
- If the plan intends to use `z_model_exists` to prove `chronicle_is_good`, the entire construction is vacuous — it assumes what it set out to prove

If the intent is to prove `chronicle_is_good` *without* `z_model_exists` (using the gap-elimination chain directly), then `z_model_exists` serves no purpose and should be removed from the framework.

### 3. `contemp_equiv` Definition Deviates from Reynolds 1994

**Severity**: MEDIUM (mathematical incorrectness)

Reynolds 1994 (p. 130) defines `a ~M b` as:
- `a = b`, OR
- `a < b` and `M|a,b` is very good, OR
- `b < a` and `M|b,a` is very good

The implementation defines:
```lean
def contemp_equiv ... (a b : M.carrier) : Prop :=
  very_good sig k (M.subinterval sig (min a b) (max a b))
```

This is **wrong for `a = b`**: when `a = b`, `min a b = max a b = a`, so the subinterval is `[a, a]` (singleton). The definition requires this singleton to be "very good" — meaning every sub-subinterval of a singleton must be good. While this may hold vacuously, it's an unnecessary detour from Reynolds's explicit `a = b` case (which is trivially reflexive).

More importantly, `very_good` of a singleton requires `good` of every subinterval `[c, d]` with `a ≤ c` and `d ≤ a`, so `c = d = a` — meaning the singleton `{a}` must be good (k-equivalent to some Z-interval). This is true but needs `finite_structures_good` which is sorried. So reflexivity of `contemp_equiv` is blocked on a sorry that Reynolds handles trivially.

### 4. `table_correctness` Has Placeholder Conclusion Type `True`

**Severity**: MEDIUM (mathematically vacuous)

```lean
theorem table_correctness (sig : MonadicSignature) (x : ReflCanDomain) (φ : Formula) :
    True := by sorry
```

A theorem with conclusion `True` proves nothing useful. This should be `sorry`'d with the correct type signature for eventual use, or removed entirely. Currently it's misleading — it appears as a sorry-bearing theorem but its type is vacuous.

### 5. `Formula.complexity` Sets Until/Since to 0

**Severity**: MEDIUM (mathematically incorrect)

```lean
| .untl _ _ => 0
| .snce _ _ => 0
```

Reynolds's table translation uses Until and Since with quantifier-producing expansions. Setting their complexity to 0 means the depth bound `k = phi.complexity + 1` will be too shallow for formulas containing Until/Since. This needs correction when `table` is properly defined.

### 6. `reflCanToMonadic` Is Vacuously Defined

**Severity**: LOW (dead code)

```lean
def reflCanToMonadic (_A : ReflCanDomain) (sig : MonadicSignature) : MonadicStructure sig where
  carrier := ReflCanDomain
  interp _ _ := True
```

All predicate interpretations are `True`. This is a placeholder that should either be properly defined or removed.

## Sorry Classification Table

| # | File | Line | Declaration | Classification | Notes |
|---|------|------|------------|---------------|-------|
| 1 | NEquivalence | 229 | `ktype_finite` | Deep | Requires monadic FO sentence enumeration |
| 2 | NEquivalence | 242 | `k_type_of` | Deep | Requires monadic FO satisfaction relation |
| 3 | NEquivalence | 271 | `k_equiv_monotone` | Blocked | Blocked on `k_type_of` |
| 4 | OrderedSum | 66 | `doets_lemma_1_4` | Blocked | No `KEquivalenceFramework` instance; but correct wrapper exists |
| 5 | OrderedSum | 113 | `doets_lemma_1_5` | Deep | Full type-matching argument; deferred per plan |
| 6 | OrderedSum | 150 | `finite_structures_k_equiv_to_Z_interval` | Deep | Needs `k_type_of` + `doets_lemma_1_4` + decomposition |
| 7 | IntegerModel | 102 | `finite_structures_good` | Blocked | On `finite_structures_k_equiv_to_Z_interval` |
| 8 | IntegerModel | 136 | `contemp_equiv_is_equiv` | Blocked | On `finite_structures_good` + `doets_lemma_1_4` |
| 9 | IntegerModel | 164 | `no_gaps_discrete` | Blocked | On `contemp_equiv_is_equiv` (needs equivalence properties) |
| 10 | IntegerModel | 183 | `no_boundary_at_successor` | Provable now | Uses `subinterval_two_element_finite` (sorry-free) + `finite_structures_good` (sorried but could be bypassed for 2-element case) |
| 11 | IntegerModel | 210 | `one_class` | Blocked | On `no_gaps_discrete` + `no_boundary_at_successor` + `contemp_equiv_is_equiv` |
| 12 | IntegerModel | 235 | `very_good_implies_good` | Deep | Cofinal sequence decomposition; Doets 1.4/1.5 |
| 13 | IntegerModel | 276 | `chronicle_is_good` | Blocked | On `one_class` + `very_good_implies_good` |
| 14 | IntegerModel | 290-291 | `canonical_model_is_good` (deprecated) | Unnecessary | Deprecated, should be removed |
| 15 | Table | 62 | `table` | Deep | Requires full table translation definition |
| 16 | Table | 74 | `table_depth_bound` | Blocked | On `table` |
| 17 | Table | 104 | `table_correctness` | Unnecessary | Conclusion type is `True` — proves nothing |
| 18 | ReflexiveCanonical | 144 | `canS5R_symm` | Separate | Not on Reynolds pipeline critical path |
| 19 | ReflexiveCanonical | 424 | `reflCanR_linear` | Dead code | Zero callers, confirmed dead |
| 20-25 | TruthLemma | various | 6 sorries | Separate | Truth lemma for G/H backward, Until/Since; not on Theorem 15 path |

**Total sorries in target files**: 17 (NEquivalence: 3, OrderedSum: 3, IntegerModel: 8+1 deprecated, Table: 3)
**Total sorries in WeakCanonical**: 25 (adding ReflexiveCanonical: 2, TruthLemma: 6)

The plan claims 18; the actual count is 17 in target files (or 14 if we exclude the deprecated theorem and two `Unnecessary` sorries).

## Mathematical Correctness Issues

### A. `good` Uses `k_equiv` on `MonadicStructure`, Not `OrderedMonadicStructure`

```lean
def good ... (M : OrderedMonadicStructure sig) : Prop :=
  ∃ (Z : ZStructure sig), k_equiv sig k M.toMonadic (Z.toMonadic sig)
```

This converts `M` to `MonadicStructure` via `M.toMonadic` and compares with `Z.toMonadic`. The `good` definition takes `OrderedMonadicStructure` but `k_equiv` works on `MonadicStructure`. This is correct in principle (k-equivalence is about first-order sentences, order is extra structure), but it means `good` drops the order information when comparing. This is fine per Reynolds's definition.

### B. `OrderedMonadicStructure.toMonadic` Takes `sig` as Explicit Argument

```lean
def OrderedMonadicStructure.toMonadic (sig : MonadicSignature) (M : OrderedMonadicStructure sig) :
```

But `M.toMonadic` in `good` uses dot notation which requires the first argument to be the structure itself. Looking at the usage `M.toMonadic`, this would need to resolve to `OrderedMonadicStructure.toMonadic sig M`. Since `sig` is the first argument and not `M`, dot notation `M.toMonadic` may not resolve correctly. This could be a latent type error hidden behind the `sorry` in `good`'s usage context. However, since the build passes for the committed version, this likely works — Lean would elaborate `M.toMonadic` by finding the `toMonadic` in the `OrderedMonadicStructure` namespace.

Wait — actually looking more carefully, the `def good` uses `M.toMonadic` at line 84, and `toMonadic` takes `sig` as its first explicit arg. So `M.toMonadic` would need to infer `sig`. Since `M : OrderedMonadicStructure sig`, Lean should be able to infer `sig` from `M`. But the function signature is `(sig : MonadicSignature) (M : OrderedMonadicStructure sig)` — the first explicit arg is `sig`, not `M`. So `M.toMonadic` won't work as dot notation because `M` isn't the first argument.

**This is likely a build error hidden by the build break.** Need to verify once the `ZStructure` duplicate is fixed.

### C. `KEquivalenceFramework` Fields vs. Standalone Theorems

The framework defines `equiv_at` (its own relation) separately from `k_equiv` (defined via `k_type_of`). These are two different relations that should eventually be proven equivalent but currently are not connected. The `doets_lemma_1_4` theorem uses `k_equiv` while `doets_lemma_1_4_finite` uses `h_framework.equiv_at`. This dual-track approach is intentional per the "shallow encoding" strategy but creates two parallel proof paths that need reconciliation.

## Structural Problems

### A. Import Chain Issues
- IntegerModel imports `ChronicleExtraction` directly AND transitively via `NEquivalence → ReflexiveCanonical`. No circular dependency but redundant import.
- `Transfer.lean` imports both `IntegerModel` and `OrderedSum` — but `IntegerModel` already imports `OrderedSum`. Redundant but harmless.

### B. Dead Code
1. `canonical_model_is_good` (IntegerModel:284) — deprecated, 0 callers. Remove.
2. `reflCanR_linear` (ReflexiveCanonical:424) — confirmed dead, 0 callers. Already noted in plan.
3. `reflCanToMonadic` (Table:84) — vacuous (`interp _ _ := True`), 0 callers. Remove.
4. `table_correctness` (Table:100) — conclusion is `True`, proves nothing. Remove or fix type.

### C. Duplicate Definitions (Current Working Tree)
- `ZStructure`: NEquivalence.lean:185, IntegerModel.lean:49
- `ZStructure.toMonadic`: NEquivalence.lean:192, IntegerModel.lean:66

## Plan Accuracy Assessment

The plan marks Phases 3-7 as **[COMPLETED]** but:

1. **Phase 3**: Definitions are in place. `subinterval_singleton_finite` and `subinterval_two_element_finite` are actually sorry-free (proven with explicit `Fintype` construction). The uncommitted changes prove these. **Assessment: COMPLETED for definitions, but uncommitted changes break the build.**

2. **Phase 4**: `doets_lemma_1_4_finite` dispatches to `KEquivalenceFramework.sum_preservation` (correct). All other proofs sorried. **Assessment: Structure complete, proofs not done. Should be [PARTIAL].**

3. **Phase 5**: All 5 vacuous definitions replaced with non-vacuous ones. All proof bodies sorried. **Assessment: Definitions done, proofs not done. Should be [PARTIAL].**

4. **Phase 6**: Transfer.lean still delegates to chronicle fallback. The Reynolds pipeline is commented out. **Assessment: Should be [PARTIAL] — the pipeline is documented but not active.**

5. **Phase 7**: Build currently broken (duplicate ZStructure). Sorry audit numbers are inaccurate. **Assessment: Should be [PARTIAL].**

**Recommendation**: Phases 3-7 should all be marked [PARTIAL], not [COMPLETED]. The plan's completion claims are premature.

## What's Being Overlooked

### 1. The Entire Table Translation Is Undefined
The `table` function body is `sorry`. Without a proper table translation, the truth transfer step (Phase 6, step 6: "Transfer truth: N ⊨ ¬φ via k-equivalence + table translation") cannot work even in principle. This is a fundamental gap: the Reynolds pipeline needs to show that k-equivalence of structures implies preservation of temporal truth for formulas of appropriate complexity.

### 2. No `mkSigFrom` or `mkAtomMap` Functions Exist
The Reynolds pipeline in Transfer.lean (commented out, lines 96-97) references:
```lean
let sig : MonadicSignature := mkSigFrom phi
let atomMap : sig.preds → Formula := mkAtomMap sig phi
```

These functions don't exist anywhere in the codebase. They need to be defined to construct the monadic signature from a formula's atoms.

### 3. The Proof of `no_boundary_at_successor` Is Simpler Than It Appears
Reynolds's argument (p. 131): "M|c, c+1, like all finite structures is very good and ~ is transitive." The proof needs:
- `subinterval_two_element_finite` (sorry-free!)
- 2-element structures are good (special case of `finite_structures_good`)
- Therefore the subinterval is very good
- Therefore `c ~M c+1`

The 2-element case of `finite_structures_good` could potentially be proved directly without the general induction, which would unblock `no_boundary_at_successor` → `one_class`.

### 4. `doets_lemma_1_5` May Not Be Bypassable
The plan claims Doets 1.5 is "bypassed in the discrete case." But Reynolds's proof of Lemma 16 (very good → good) explicitly uses lexicographic sums of structures mapped to Z-intervals. The discrete case doesn't bypass Lemma 16 — it's used in `chronicle_is_good`. What's bypassed is only the *continuous* gap-elimination machinery (Theorems 5-14). Lemma 1.5 or an equivalent is still needed for the cofinal sequence composition.

### 5. The `Until/Since` Complexity Bug Will Block Completeness
Setting `Formula.complexity` of `untl`/`snce` to 0 means the table depth bound `k = phi.complexity + 1` will be 1 for a formula like `U(p, q)`. But the table translation of Until requires at least one quantifier (existential over witnesses), so depth should be at least 1 for the formula itself plus the subformula depths.

## Confidence Level

**HIGH** for the build break finding (verified by running `lake build`).
**HIGH** for the duplicate definition finding.
**HIGH** for the plan accuracy assessment.
**MEDIUM** for the mathematical correctness issues (the `contemp_equiv` deviation is real but may be equivalent in the discrete case).
**MEDIUM** for the `z_model_exists` circularity concern (depends on intended proof strategy).
