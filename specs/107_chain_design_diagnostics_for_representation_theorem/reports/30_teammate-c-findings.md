# Teammate C Findings: r-Relation Gap Validation + Cruft Audit

**Task**: 107 - Chain design diagnostics for representation theorem
**Date**: 2026-04-26
**Focus**: Critical validation of the r-relation gap claim; comprehensive cruft audit

---

## Part 1: Validation of the r-Relation Gap Claim

### 1.1 Mathematical Notation

**Codebase `rRelation(A, B)`** (ChronicleTypes.lean:134):
```
For all gamma, delta:
  (gamma U delta) in A  ==>  delta in B  OR  (gamma in B  AND  (gamma U delta) in B)
```

This says: every Until obligation in A is either resolved (event delta achieved) or continuing (guard gamma holds and obligation persists) at B. Direction: A -> B (obligations flow forward from A into B).

**Codebase `r3Relation(A, B, C)`** (ChronicleTypes.lean:174):
```
rRelation(A, B)  AND  rRelationSince(C, B)
```

**Burgess r(A, beta, C)** (Lemma 2.3, two equivalent forms):

Form (a): For all gamma in C, `U(gamma, beta) in A`
Form (b): For all alpha in A, `S(alpha, beta) in C`

In codebase notation (guard U event, guard S event), Burgess writes U(event, guard), so:
- Burgess `U(gamma, beta)` = codebase `Formula.untl beta gamma` (beta is guard, gamma is event)
- Form (a): For all gamma in C, `(beta U gamma) in A`  -- i.e., `burgessR A beta C`
- Form (b): For all alpha in A, `(beta S alpha) in C`  -- i.e., `burgessRSince C beta A`

**Burgess r(A, B, C)** (set version): For all beta in B, r(A, beta, C).
This is `burgessRSet A B C` in the codebase (RRelation.lean:544).

**Burgess R(A, B, C)** (maximal version): r(A, B, C) and B is maximal among DCS satisfying r(A, -, C).

### 1.2 Is the Gap Claim Correct?

**The handoff claim**: "R3Maximal does NOT imply burgessR3. The codebase's rRelation and Burgess's r(A,B,C) encode DIFFERENT properties."

**Verdict: The claim is CORRECT in its core observation but WRONG about the practical consequence.**

Here is the precise analysis:

The two relations ARE different in their logical content:
- `rRelation(A, B)`: Propagation-based. Tests each Until formula in A against B.
- `burgessR(A, beta, C)`: Content-based. Tests each formula in C against A via Until with guard beta.

However, the handoff's conclusion that "R3Maximal does NOT imply burgessR3" needs qualification. Since `R3Maximal_is_mcs` forces B to be an MCS (proved sorry-free in PointInsertion.lean:763), B has negation completeness. The question becomes: does negation completeness of B, combined with `r3Relation(A, B, C)`, imply `burgessR3(A, B, C)`?

**Analysis of what r3Relation(A, B, C) + B is MCS gives us:**

Take any beta in B and gamma in C. We want to show `(beta U gamma) in A`.

From `rRelation(A, B)` alone, we get information about Until formulas ALREADY IN A. We do NOT get a mechanism to PRODUCE new Until formulas in A from elements of B and C. The relation flows A -> B, not (B x C) -> A.

So even with B an MCS, `r3Relation(A, B, C)` does NOT imply `burgessR(A, beta, C)` for arbitrary beta in B. The codebase relation simply does not carry the right information.

**However, the practical consequence is different from what the handoff suggests.** The handoff says "close C4 hard case using burgessR3 bridging + lemma_2_6_full." But `lemma_2_6_full` (PointInsertion.lean:840) already WORKS because R3Maximal forces B to MCS, giving negation completeness: delta not in B implies neg(delta) in B. This is EXACTLY what the C4 hard case needs.

### 1.3 Does rRelationSince(C, B) Correspond to Burgess Form (b)?

**No, they are different.**

`rRelationSince(C, B)` (ChronicleTypes.lean:145):
```
For all gamma, delta:
  (gamma S delta) in C  ==>  delta in B  OR  (gamma in B  AND  (gamma S delta) in B)
```

Direction: C -> B (Since obligations from C propagate into B).

Burgess form (b): For all alpha in A, `S(alpha, beta) in C`.
Direction: A -> C (elements of A combined with beta produce Since formulas in C).

These are fundamentally different. The codebase version propagates existing Since obligations from C into B. Burgess's version GENERATES Since formulas in C from elements of A with guard beta.

**Contrapositive analysis**: If beta NOT in B under codebase rRelationSince(C, B): we get no information (the relation only fires on Since formulas already in C). Under Burgess form (b): if beta NOT in B, this is not directly relevant since B is the set of guards, not the relation's domain.

### 1.4 The C4 Hard Case: What Actually Blocks It?

The sorry at CounterexampleElimination.lean:334 is the case where:
- `gamma in f(x)`, `G(gamma) in f(x)`, `H(gamma) in f(y)`
- `neg(gamma U delta) in f(x)`, `delta in f(y)`

The `c4_hard_case_G_neg_delta` lemma (RRelation.lean:753) derives `G(neg(delta)) in f(x)`, meaning neg(delta) propagates to all future points via g_content.

**What's actually needed**: An MCS D between x and y with `neg(gamma) in D`.

The challenge: both f(x) and f(y) contain gamma and even G(gamma)/H(gamma). But we also know `neg(gamma U delta) in f(x)` with `delta in f(y)`, which means the guard gamma MUST fail somewhere between x and y (semantically). The question is whether this is derivable syntactically.

**Key insight the handoff missed**: The `lemma_2_6_full` proof shows that when `R3Maximal(f(x), g(x,y), f(y))` holds and g(x,y) is an MCS, then for ANY formula delta, either delta in g(x,y) or neg(delta) in g(x,y). The C4 hard case needs neg(gamma) at some intermediate point. If gamma NOT in g(x,y), then neg(gamma) in g(x,y), and by C3 this propagates to any intermediate f(z). If gamma IN g(x,y), then we need a different argument.

**But the C4 hard case hypotheses give us**: G(gamma) in f(x), so gamma in g_content(f(x)). The question is whether g_content(f(x)) subset g(x,y). This is NOT guaranteed by the codebase's r3Relation. It IS guaranteed by Burgess's r-relation (since g_content elements are in g(x,y) by construction in Burgess's proof).

**This IS the real gap**: The codebase's r3Relation does not enforce g_content(f(x)) subset g(x,y), which Burgess's construction provides by design. The g-values in the codebase can be MCS that do NOT contain g_content of their left endpoint.

### 1.5 Resolution Assessment

The handoff's three options are reasonable. The simplest fix:

**Option 3 (augmented seed)**: When constructing g(x,y) via `r3Maximal_extension_exists`, ensure the seed includes g_content(f(x)) union h_content(f(y)). Since the seed must satisfy r3Relation(f(x), -, f(y)), and g_content(f(x)) trivially satisfies rRelation(f(x), -) (every Until formula gamma U delta in f(x) has G(gamma U delta) in f(x) by BX5+BX4, so gamma U delta in g_content, satisfying the "guard continues" case), this should work.

Concretely: define the seed as `deductiveClosure(g_content(f(x)) union h_content(f(y)))`, prove it satisfies r3Relation, then extend to R3Maximal. The resulting B contains g_content(f(x)), so G(gamma) in f(x) implies gamma in B.

---

## Part 2: Comprehensive Cruft Audit

### 2.1 `g_ordered` / `h_ordered`

**Location**: ChronicleTypes.lean:466-473

**Status**: DEPRECATED (explicitly marked). Defined but not used in any proof or structure field. Only referenced in sorry-site comments at CounterexampleElimination.lean:333 and :448.

**Recommendation**: DELETE both definitions. They are vestiges of the pre-C3 approach where g_content propagation was expected to drive the truth lemma. The comments referencing them should be updated to reference the actual approach (R3Maximal + C3 three-way intersection).

### 2.2 `g_content_chain_property`

**Status**: FULLY REMOVED as a definition. Only two textual references remain:
- ChronicleTypes.lean:427 (comment: "no need for g_content_chain_property") -- accurate, informational
- ChronicleConstruction.lean:1170 (comment in claim_2_11: "requires omega-chain fix") -- STALE, refers to the old approach

**Recommendation**: Update the ChronicleConstruction.lean:1170 comment to reference C3 instead.

### 2.3 `extended_limit_f`

**Status**: FULLY DELETED from source. One textual reference remains:
- ChronicleToCountermodel.lean:39 (docstring: "The legacy chronicle_bfmcs pathway (using extended_limit_f) has been deleted")

**Recommendation**: Keep the docstring reference (it documents what was removed and why).

### 2.4 `chronicle_fmcs` / `chronicle_bfmcs`

**Status**: FULLY DELETED from source. Textual references remain:
- ChronicleToCountermodel.lean:39, :426 (docstrings documenting the deletion)

**Recommendation**: Keep docstring references (historical documentation).

### 2.5 Sorry Sites

**Active sorry sites (4 total)**:

| File | Line | Description | Dead Code? |
|------|------|-------------|------------|
| CounterexampleElimination.lean | 334 | C4 hard case (Until) | NO - active blocker |
| CounterexampleElimination.lean | 449 | C4' hard case (Since) | NO - mirror of above |
| ChronicleToCountermodel.lean | 615 | restricted_fuc Until | NO - active blocker |
| ChronicleToCountermodel.lean | 619 | restricted_fuc Since | NO - mirror of above |

**Pseudo-sorry sites**:

| File | Line | Description | Status |
|------|------|-------------|--------|
| ChronicleConstruction.lean | 1163 | `claim_2_11` | NOT a sorry -- `exact Iff.rfl` makes it trivially true. The "real" claim (semantic truth equivalence) is stated in comments but not formalized. This is dead code masquerading as progress. |

**Recommendation**: `claim_2_11` should either be deleted or replaced with the actual semantic truth equivalence statement. Currently it proves `phi in f(x) <-> phi in f(x)` which is a tautology.

### 2.6 Stale Phase References

**PointInsertion.lean:37-41**: References "Phase 2" and says "These will be unified with Phase 2 when both phases are complete." Phase 2 was completed long ago. No "local versions" appear to remain in the file.

**Recommendation**: Update the docstring to remove the Phase 2 reference and "local versions" language.

**CounterexampleElimination.lean:300, :421**: Reference "Phase 2" for the hard case.

**Recommendation**: Update to reference the actual blocker (r-relation gap / g_content seed inclusion).

### 2.7 `density` References

The `density` keyword appears extensively in CounterexampleElimination.lean and ChronicleConstruction.lean as an active part of the construction (density counterexample elimination). These are NOT cruft -- they are part of the working density insertion machinery.

### 2.8 `g_agrees` on EliminationResult

**Location**: CounterexampleElimination.lean:708

**Status**: ACTIVE and CORRECT. The `g_agrees` field ensures that when a counterexample is eliminated, the g-values for existing domain pairs are preserved. This is essential for the omega-chain invariant (each step only adds new g-values for pairs involving the new point).

**Assessment**: Given the r-relation findings, `g_agrees` is still the right approach. The issue is not that g-values change during elimination, but that g-values need to be CONSTRUCTED with the right content (containing g_content/h_content of endpoints). The `g_agrees` field correctly preserves existing g-values; the fix needed is in how NEW g-values are seeded (see Section 1.5).

### 2.9 Unused Definitions in ChronicleTypes.lean

- `rMaximal` (line 200): Used by `rMaximal_extension_exists` in RRelation.lean. ACTIVE.
- `rMaximalSince` (line 211): Used by `rMaximalSince_extension_exists`. ACTIVE.
- `R3MaximalSince` (line 239): Used by `r3MaximalSince_extension_exists`. ACTIVE.
- `r3RelationSince` (line 184): Used in R3MaximalSince. ACTIVE.
- `SetDeductivelyClosed` and associated lemmas: All ACTIVE.
- `Adjacent` (line 114): Used in `Chronicle.c2'`. ACTIVE.

**No unused definitions found** in ChronicleTypes.lean beyond the already-flagged g_ordered/h_ordered.

### 2.10 FIX:/TODO:/HACK:/WORKAROUND: Tags

**None found** in the Chronicle/ directory. The codebase uses comments rather than structured tags for blockers.

---

## Summary of Recommended Actions

### Deletions (safe to remove)

1. `Chronicle.g_ordered` (ChronicleTypes.lean:466-467) -- deprecated, unused
2. `Chronicle.h_ordered` (ChronicleTypes.lean:472-473) -- deprecated, unused
3. The entire `/-! ## g_content Chain Ordering (DEPRECATED)` section (lines 449-473)
4. `claim_2_11` (ChronicleConstruction.lean:1160-1171) -- proves a tautology, misleading

### Comment Updates

1. CounterexampleElimination.lean:333 -- replace "g_ordered invariant" with "g_content-seeded R3Maximal"
2. CounterexampleElimination.lean:448 -- same
3. PointInsertion.lean:37-41 -- remove stale Phase 2 references
4. CounterexampleElimination.lean:300, :421 -- update Phase 2 references
5. ChronicleConstruction.lean:1170 -- replace g_content_chain_property reference

### Critical Design Fix

The C4 hard case sorry requires ensuring g_content(f(x)) subset g(x,y) and h_content(f(y)) subset g(x,y). This can be achieved by seeding the R3Maximal extension with `deductiveClosure(g_content(f(x)) union h_content(f(y)))` and proving this seed satisfies r3Relation(f(x), -, f(y)). This is the path forward for closing all 4 active sorry sites.
