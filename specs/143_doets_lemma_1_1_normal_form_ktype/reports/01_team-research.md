# Research Report: Doets Lemma 1.1 Normal Form KType Redesign

- **Task**: 143 - Doets Lemma 1.1: normal form KType redesign with finite domain
- **Started**: 2026-05-15T00:14:00Z
- **Completed**: 2026-05-15T00:17:00Z
- **Effort**: Team research (4 teammates)
- **Dependencies**: 139
- **Sources/Inputs**:
  - Doets 1987 thesis, Chapter 1, Sections 1.6-1.7 (n-characteristics, Lemma 1.7.1)
  - Doets 1989 "Monadic Pi11 Theories" (NDJFL Vol. 30, No. 2, Lemma 1.1)
  - Codebase: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
  - Codebase: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
  - Codebase: `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean`
  - Mathlib: `FirstOrder.Language.BoundedFormula`, `Theory.iffSetoid`, `Complexity.lean`
  - Task 139 research reports
- **Artifacts**:
  - `specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-a-findings.md`
  - `specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-b-findings.md`
  - `specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-c-findings.md`
  - `specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-d-findings.md`
  - `specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_team-research.md` (this file)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Project Context

- **Upstream Dependencies**: Task 139 (FO satisfaction), `MonadicFormula`, `eval`, `OrderedMonadicStructure`
- **Downstream Dependents**: Task 140 (truth transfer), Task 142 (mixed-case countermodel), `sum_preservation` (Doets Lemma 1.4)
- **Alternative Paths**: Quotient approach, EF games, Boolean algebra approach (all require the same core argument)
- **Potential Extensions**: EF-game formalization for sum_preservation, Mathlib model theory bridge

## Executive Summary

- The current `KType sig k := {s : MonadicFormula sig 0 // s.quantifier_depth <= k} -> Bool` has a **syntactically infinite domain** (unbounded not/and nesting), making `Fintype` provably impossible. This is the root cause of the `ktype_finite` sorry.
- The fix is to replace the domain with `NormalFormIdx sig k 0 := Fin (nfCount p k 0)`, a finite type indexing the semantically distinct equivalence classes of depth-<=k formulas (Doets 1987 Lemma 1.7.1 / Doets 1989 Lemma 1.1).
- All four teammates converge on the same architecture: define `nfCount` recursively, define `nf_eval` for semantic interpretation, redefine `KType := NormalFormIdx sig k 0 -> Bool`, prove Doets Lemma 1.1 by induction on quantifier depth k.
- No alternative approach (quotient, range/image, EF games, Boolean algebra, Mathlib BoundedFormula) avoids the core Doets 1.1 argument. No prior formalization exists in any proof assistant.
- The time estimate of 6-9 hours is aggressive; 10-15 hours is more realistic given the two-level induction complexity in the inductive step.
- Neither `ktype_finite` nor `finite_types` is consumed downstream, giving maximum architectural freedom for the redesign.

## Context & Scope

Task 143 targets two sorries in `NEquivalence.lean`:
1. `ktype_finite` (line ~355): `Fintype (KType sig k)` -- impossible with current infinite-domain definition
2. `finite_types` in `KEquivalenceFramework` (line ~379): `Fintype` on the quotient of structures by k-equivalence

The `sum_preservation` sorry in the same file is **out of scope** (requires EF-game formalization, separate task).

Task 139 must stabilize first -- it provides the `eval`, `MonadicFormula`, and `quantifier_depth` definitions that task 143 builds on. Task 139 is currently `[IMPLEMENTING]`.

## Findings

### The Core Problem (unanimous across teammates)

The domain `{s : MonadicFormula sig 0 // s.quantifier_depth <= k}` is syntactically infinite because formulas like `not (not (... (atom p i)))` and `and phi phi` create unbounded nesting at the same quantifier depth. Therefore `Fintype` on the function type `domain -> Bool` is impossible without quotienting by logical equivalence.

### Recommended Architecture (consensus)

**Layer 1: Counting function** (computable)
```
def atomCount (p n : Nat) : Nat := p * n + n * (n - 1)

def nfCount (p : Nat) : Nat -> Nat -> Nat
  | 0, n => 2 ^ atomCount p n
  | k+1, n => 2 ^ (atomCount p n + nfCount p k (n + 1))
```

**Layer 2: Finite index type**
```
abbrev NormalFormIdx (sig : MonadicSignature) (k n : Nat) :=
  Fin (nfCount (Fintype.card sig.preds) k n)
```

**Layer 3: Semantic evaluation** (noncomputable, uses Classical.dec)
```
noncomputable def nf_eval (sig : MonadicSignature) (k n : Nat) :
    NormalFormIdx sig k n -> OrderedMonadicStructure sig -> (Fin n -> carrier) -> Prop
```

**Layer 4: KType redesign**
```
def KType (sig : MonadicSignature) (k : Nat) : Type :=
  NormalFormIdx sig k 0 -> Bool

instance ktype_finite : Fintype (KType sig k) := inferInstance

noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  fun idx => decide (nf_eval sig k 0 idx M Fin.elim0)
```

**Layer 5: Bridge theorem** (Doets Lemma 1.1)
```
theorem doets_lemma_1_1 : for every depth-<=k formula phi, its truth is
  determined by the nf_eval values at depth k
```

### Atom Count Clarification

The depth-0 atoms with n free variables over signature with p unary predicates and binary < are:
- Predicate atoms: `P_i(x_j)` -- count: `p * n`
- Order atoms: `x_i < x_j` for `i != j` -- count: `n * (n - 1)` (both directions, since in a linear order knowing `x_i < x_j` is independent of knowing `x_j < x_i` given we also have equality)

**Open question** (Teammate C, Teammate D): The exact atom count formula needs verification against Doets 1987 Definition 1.6.1 -- specifically whether to use `n * (n-1)` (both directions) or `n * (n-1) / 2` (one direction, with negation handling the reverse). Teammate A uses `n * (n-1)`, the task description uses `n * (n-1) / 2`. Both are correct upper bounds; the choice affects concrete `nfCount` values but not the finiteness proof.

### nfCount Step Case Discrepancy (Teammate D finding)

Teammate D identified a potential discrepancy in the step case formula. The task 139 research report had:
```
nfCount p (k+1) n = nfCount p 0 n * 2^(nfCount p k (n+1))
```

The correct formula (matching Doets) should be:
```
nfCount p (k+1) n = 2^(atomCount p n + nfCount p k (n+1))
```

These differ because the first multiplicatively separates QF and quantified parts while the second exponentiates their sum. The second formula is correct: depth-(k+1) normal forms are truth assignments over ALL atoms (both QF atoms and forall-of-depth-k formulas), not products of separate assignments.

### Alternative Approaches Evaluated (Teammate B)

| Approach | Avoids Doets 1.1? | Effort | Verdict |
|----------|-------------------|--------|---------|
| Quotient of sentences | No | Medium-High | Not a shortcut |
| Range/Image | No | Medium | Same obligation |
| Mathlib BoundedFormula | No | Very High (refactor) | Not recommended |
| EF Games | No (equivalent) | Very High (20+h) | Separate future task |
| Boolean Algebra | No | High | Adds indirection |

All alternatives require the same core finiteness argument. The NormalForm inductive approach is the most direct.

### NormalForm Representation (Teammate A vs Teammate C)

Two options debated:

**Option A**: `Fin (nfCount p k n)` -- opaque finite type. Trivial `Fintype`. Requires well-founded recursion for `nf_eval`.

**Option B**: Inductive type with explicit structure:
```
inductive NormalForm : Nat -> Nat -> Type where
  | base : (Fin (atomCount sig n) -> Bool) -> NormalForm 0 n
  | step : (NormalForm k (n+1) -> Bool) -> NormalForm (k+1) n
```
Cleaner `nf_eval` by structural recursion. Must prove `Fintype` by induction (additional work).

**Recommendation**: Teammate C recommends Option B (inductive), Teammate A recommends Option A (Fin-based, specifically using `Fin N -> Bool` for KType). The consensus leans toward **Option A for KType** (simpler `Fintype` proof) but **Option B for `NormalForm` itself** (cleaner semantics). These are compatible: `NormalForm sig k n` can be the inductive type with a proven equivalence to `Fin (nfCount ...)`.

### Proof Structure for Doets Lemma 1.1 (Teammates A, C)

**Base case (k=0)**: Every quantifier-free formula is a Boolean combination of finitely many atoms. By structural induction on formula: atom/lt map to specific atoms, not/and are handled by Boolean combination. The truth value is determined by the truth assignment to atoms.

**Inductive step (k -> k+1)**: This is the hard part. Requires **two-level induction**:
- Outer: natural number induction on k
- Inner: structural induction on formula within depth k+1

The inner induction handles:
- atom/lt/not/and: same as base case (don't increase depth)
- all/ex: by IH, the quantified body (depth <= k, n+1 vars) has a normal form; the quantifier applied to this normal form is one of the "quantified atoms" at depth k+1

**Key lemma needed**: Boolean Combination Lemma -- if phi is a Boolean combination of P_1,...,P_m, truth of phi is determined by truth values of P_1,...,P_m (structural induction on not/and).

### Risk Assessment (Teammate C)

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| `nfCount` double exponential blocks Lean kernel | HIGH | MEDIUM | Keep opaque, never unfold, work symbolically |
| Binary `<` complicates "monadic" base case | HIGH | HIGH | Explicitly enumerate order atoms alongside predicate atoms |
| Inductive step requires 2-level induction | HIGH | HIGH | Careful structural induction within depth levels |
| Semantic equivalence requires quantifying over all models | MEDIUM | HIGH | Use Classical.dec (already present for k_type_of) |
| Task 139 dependency not yet complete | HIGH | HIGH | Define NormalForm independently; integration waits |
| k_equiv_monotone breaks with new KType | MEDIUM | HIGH | Rewrite with inclusion map on NormalForm domains |
| Fin(nfCount) requires nfCount > 0 proof | MEDIUM | MEDIUM | Prove > 0 for relevant cases |

### Downstream Compatibility (Teammates A, D)

Direct dependents of `KType` / `k_type_of`:
- `NEquivalence.lean`: PRIMARY TARGET -- all definitions change
- `OrderedSum.lean`: `k_equiv`, `k_type_of` in Doets Lemma 1.5 statements
- `IntegerModel.lean`: uses `k_equiv` transitively via `good`, `very_good`
- `Transfer.lean`: minimal impact (comments only)

The API contract to preserve: `k_type_of sig k M : KType sig k` with `k_equiv M N := k_type_of M = k_type_of N`. The new definition satisfies this with `KType := NormalFormIdx sig k 0 -> Bool`.

### Strategic Value (Teammate D)

- **Novel formalization**: No proof assistant has formalized Doets Lemma 1.1, n-characteristics, or EF games for FO logic
- **Enables sum_preservation**: Normal forms transform the EF-game argument into structural induction on quantifier depth (simpler to formalize)
- **Publication potential**: Publishable as first mechanized proof of finiteness of FO formulas up to equivalence at bounded depth
- **Recommended placement**: NormalForm in its own file for reusability

## Decisions

1. **Use NormalFormIdx = Fin(nfCount p k n) as the core finite type** -- gives trivial Fintype, clean downstream API
2. **Keep existing MonadicFormula infrastructure** -- do not migrate to Mathlib BoundedFormula (high cost, zero benefit for finiteness)
3. **Scope to monadic FO over linear orders** -- general FO normal forms are out of scope
4. **Computational nfCount + classical nf_eval** -- counting is pure arithmetic; evaluation uses Classical.dec for infinite carriers
5. **Redefine KType := NormalFormIdx sig k 0 -> Bool** -- makes ktype_finite trivial (inferInstance)
6. **Prove doets_lemma_1_1 by induction on k** -- base case (atom enumeration + Boolean combinations), inductive step (quantified normal form reduction)
7. **EF games are a separate future task** -- needed for sum_preservation (Doets Lemma 1.4) but out of scope for 143
8. **NormalForm in its own file** (e.g., NormalForm.lean) for independence and reusability

## Recommendations

1. **Verify atom count formula** against Doets 1987 Definition 1.6.1 before implementation: `n*(n-1)` vs `n*(n-1)/2` for order atoms
2. **Verify nfCount step case**: use `2^(atomCount p n + nfCount p k (n+1))`, not the multiplicative variant from task 139 report
3. **Wait for task 139 to stabilize** before beginning implementation -- eval and MonadicFormula definitions are foundations
4. **Keep nfCount opaque** in all proofs -- never `@[reducible]` or `@[simp]`; the double-exponential growth would crash the kernel
5. **Consider a fallback**: even without full Doets Lemma 1.1, `Fintype (NormalForm sig k n)` can be proved directly from the inductive structure, which suffices for ktype_finite
6. **Plan for 10-15 hours** rather than 6-9 -- the two-level induction in the inductive step is the bottleneck
7. **Place NormalForm definitions in a separate file** importable independently of the Reynolds pipeline
8. **Delete the old ktype_finite sorry** after redefining KType (it was impossible as stated)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| nfCount double exponential blocks Lean kernel | Keep opaque, never unfold, use structural induction on k |
| Two-level induction too complex | Fallback: prove Fintype NormalForm directly without full equivalence theorem |
| Task 139 changes break NormalForm integration | Define NormalForm independently; integration layer is thin |
| Encoding Fin(2^N) <-> (Fin N -> Bool) unavailable in Mathlib | Check Mathlib for Equiv.boolArrowEquivFin; may need custom equiv |
| k_equiv_monotone breaks | Monotonicity requires showing depth-m NFs embed into depth-k NFs -- provable from nfCount structure |
| Time estimate exceeded | Minimum viable: NormalForm + Fintype + KType redesign + ktype_finite (skip full Doets 1.1 if needed) |

## Appendix

### Sorries Targeted by This Task

| Location | Sorry | Resolution |
|----------|-------|------------|
| NEquivalence.lean ~355 | `ktype_finite` | `inferInstance` after KType redesign |
| NEquivalence.lean ~379 | `finite_types` | `Fintype.ofInjective` + Doets 1.1 |

### Sorries NOT Targeted

| Location | Sorry | Reason |
|----------|-------|--------|
| NEquivalence.lean ~382 | `sum_preservation` | Requires EF-game formalization (separate task) |
| NEquivalence.lean ~331,334 | `carrier_order` in sum_preservation | Related to sum_preservation |

### Sample nfCount Values (p=1 predicate)

| k | n | nfCount | Notes |
|---|---|---------|-------|
| 0 | 0 | 1 | No atoms with 0 vars |
| 0 | 1 | 2 | 1 atom: P(x0) |
| 0 | 2 | 8 | 3 atoms: P(x0), P(x1), x0<x1 |
| 1 | 0 | 4 | 2 new atoms from nfCount(1,0,1)=2 |
| 1 | 1 | 256 | 8 new atoms from nfCount(1,0,2)=8 |
| 2 | 0 | 2^256 | Enormous but finite |

### Teammate Contributions

- **Teammate A**: Literature analysis, Lean architecture design, implementation phases, proof sketch for Doets 1.1
- **Teammate B**: Alternative approaches survey (quotient, range/image, Mathlib BoundedFormula, EF games, Boolean algebra), prior art search, comparison table
- **Teammate C**: Risk assessment (10 risks), hidden complexity analysis (double exponential, binary < complication, two-level induction, DNF reduction), proof difficulty estimates, NormalForm representation comparison
- **Teammate D**: Strategic assessment (Reynolds pipeline positioning), cross-task impact analysis, literature-guided design, publication value assessment, nfCount step case discrepancy identification
