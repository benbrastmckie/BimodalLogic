# Research Report: Task #892

**Task**: Modify henkinStep to add negations when rejecting packages
**Date**: 2026-02-17
**Focus**: Henkin construction modification for maximal_tcs_is_mcs theorem

## Summary

The current `henkinStep` function in `TemporalLindenbaum.lean` only adds temporal packages when they are consistent, but does NOT add the negation when rejecting them. This leaves "gaps" where neither `phi` nor `neg(phi)` is in the resulting set, preventing the Henkin limit from being a Maximal Consistent Set (MCS). The fix requires modifying `henkinStep` to explicitly add `neg(phi)` when `temporalPackage(phi)` would be inconsistent with the current set.

## Findings

### 1. Current henkinStep Implementation Analysis

The current implementation at line 323 of `TemporalLindenbaum.lean`:

```lean
noncomputable def henkinStep (S : Set Formula) (phi : Formula) : Set Formula :=
  if SetConsistent (S U temporalPackage phi) then S U temporalPackage phi else S
```

This function:
- **Accepts case**: Adds the entire `temporalPackage(phi)` when consistent with S
- **Rejects case**: Returns S unchanged (NO negation added)

### 2. The Missing Negation Problem

For a set M to be SetMaximalConsistent, it must satisfy:
```lean
def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S /\ forall phi : Formula, phi notin S -> not SetConsistent (insert phi S)
```

The current Henkin construction produces sets that are:
- **Consistent**: Yes (henkinStep preserves consistency)
- **Temporally saturated**: Yes (packages include witnesses)
- **Negation complete**: NO (rejected formulas don't have negations)

This is exactly why `maximal_tcs_is_mcs` has sorries at lines 649 and 656. The theorem tries to prove that a set maximal in `TemporalConsistentSupersets` is an MCS, but the proof gets stuck when:
- We insert `phi = F(psi)` into M
- We need `psi in insert phi M` for temporal saturation
- But `psi notin M` and `psi != phi`

### 3. The Proof State at the Sorries

At line 649, the goal is:
```lean
case inl
h_eq : psi.some_future = phi
-- Need to prove: psi in insert phi M
```

At line 656, the symmetric goal for backward case:
```lean
case inl
h_eq : psi.some_past = phi
-- Need to prove: psi in insert phi M
```

The issue: when `phi = F(psi)` and `phi notin M`, we don't know `psi in M`. The current Henkin construction doesn't guarantee this.

### 4. Why Adding Negations Fixes the Problem

With the modified `henkinStep`:
```lean
noncomputable def henkinStep (S : Set Formula) (phi : Formula) : Set Formula :=
  if SetConsistent (S U temporalPackage phi) then
    S U temporalPackage phi
  else
    S U {neg phi}  -- ADD: negation when rejecting
```

This ensures:
1. For every enumerated formula phi, either:
   - `temporalPackage(phi) subset henkinLimit`, OR
   - `neg(phi) in henkinLimit`

2. Since `phi in temporalPackage(phi)` (by `mem_temporalPackage_self`), we get:
   - Either `phi in henkinLimit`, OR
   - `neg(phi) in henkinLimit`

This is exactly the negation completeness required for MCS.

### 5. What Negation Form to Add

**Key insight**: We should add `neg(phi)`, NOT `neg(temporalPackage(phi))`.

Rationale:
- `temporalPackage(phi)` is a SET of formulas (phi and its witnesses)
- We reject the package because adding ALL of them is inconsistent
- But we want `neg(phi)` to indicate the formula phi itself is rejected
- The witnesses inside the package are irrelevant for negation completeness

For `phi = F(psi)`, we add `neg(F(psi))`, which by duality equals `G(neg(psi))`.

### 6. Consistency of Adding Negations

**Claim**: If `SetConsistent(S)` and `not SetConsistent(S U temporalPackage(phi))`, then `SetConsistent(S U {neg(phi)})`.

**Proof sketch**:
1. Assume `not SetConsistent(S U {neg(phi)})` for contradiction
2. Then there exists L subset S U {neg(phi)} with L |- bot
3. By deduction theorem reasoning on neg(phi), we get S |- phi
4. This means S already "believes" phi
5. Combined with `S |- neg(phi)` (from the inconsistent extension), we get S |- bot
6. Contradiction with SetConsistent(S)

This is the standard argument from Lindenbaum's lemma that one of `phi` or `neg(phi)` can be consistently added.

### 7. Impact on Downstream Proofs

**henkinStep_consistent**: Needs modification to handle the new case.
```lean
lemma henkinStep_consistent (S : Set Formula) (phi : Formula) (h_cons : SetConsistent S) :
    SetConsistent (henkinStep S phi) := by
  simp only [henkinStep]
  split
  . assumption  -- Package case: unchanged
  . -- Negation case: needs new proof
    -- Use: not SetConsistent(S U pkg) implies SetConsistent(S U {neg phi})
    sorry
```

**henkinChain_consistent**: Should follow from henkinStep_consistent without change.

**henkinLimit_consistent**: Should follow from chain consistency.

**henkinLimit_forward_saturated / henkinLimit_backward_saturated**:
- The saturation proofs examine formulas in the limit
- Adding negations doesn't break saturation since:
  - Negations are never temporal witness formulas (F(psi) or P(psi))
  - The saturation only requires witnesses for temporal formulas that ARE in the set

**maximal_tcs_is_mcs**: With the modified construction, the proof changes:
- The sorries go away because the Henkin limit is now directly MCS
- We don't need to prove `insert phi M in TCS` anymore
- Instead, we prove: if `phi notin M`, then `neg(phi) in M` (from construction), hence `insert phi M` is inconsistent

### 8. Alternative Approaches Considered

**Approach A: Modify henkinStep (Recommended)**
- Add `neg(phi)` when rejecting packages
- Clean, local change
- Directly ensures negation completeness

**Approach B: Post-process Henkin limit**
- Leave henkinStep unchanged
- After building henkinLimit, extend it to MCS using standard set_lindenbaum
- Problem: May lose temporal saturation (set_lindenbaum doesn't preserve it)

**Approach C: Different maximalization argument**
- Prove that Zorn maximal in TCS implies MCS directly
- Problem: This is exactly what `maximal_tcs_is_mcs` tries and fails

Approach A is recommended because it addresses the root cause.

### 9. Mathlib Patterns

In Mathlib's `ModelTheory.Satisfiability`, the definition of `IsMaximal` for first-order theories is:
```lean
def IsMaximal (T : L.Theory) : Prop :=
  T.IsSatisfiable /\ forall phi : L.Sentence, phi in T \/ phi.not in T
```

The standard proof of Lindenbaum's lemma (which produces maximal theories) uses a transfinite enumeration where at each step:
- If T U {phi} is satisfiable, add phi
- Otherwise, add phi.not (which must be satisfiable by completeness of classical logic)

This is exactly the pattern we need to follow.

### 10. Required Supporting Lemmas

To implement the fix, we need:

**L1: neg_consistent_when_pkg_inconsistent**
```lean
lemma neg_consistent_when_pkg_inconsistent (S : Set Formula) (phi : Formula)
    (h_cons : SetConsistent S) (h_pkg_incons : not SetConsistent (S U temporalPackage phi)) :
    SetConsistent (S U {neg phi})
```

**L2: henkinStep_consistent_v2** (modified version)
```lean
lemma henkinStep_consistent (S : Set Formula) (phi : Formula) (h_cons : SetConsistent S) :
    SetConsistent (henkinStep S phi)
```

**L3: henkinLimit_negation_complete**
```lean
lemma henkinLimit_negation_complete (base : Set Formula) (h_base : ...) (phi : Formula) :
    phi in henkinLimit base \/ neg(phi) in henkinLimit base
```

## Recommendations

1. **Modify henkinStep definition** to add `neg(phi)` when rejecting packages:
   ```lean
   noncomputable def henkinStep (S : Set Formula) (phi : Formula) : Set Formula :=
     if SetConsistent (S U temporalPackage phi) then
       S U temporalPackage phi
     else
       S U {neg phi}
   ```

2. **Prove neg_consistent_when_pkg_inconsistent** as the key supporting lemma. This is a standard result from classical logic that can be proven using the deduction theorem.

3. **Update henkinStep_consistent** to handle the new case. The proof will need to invoke the new lemma.

4. **Verify saturation proofs** still work. They should, since negations are not temporal witness formulas.

5. **Simplify maximal_tcs_is_mcs** once the Henkin limit is directly MCS. The current approach of proving `insert phi M in TCS` becomes unnecessary.

## References

- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Main file with henkinStep and sorries
- `Theories/Bimodal/Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` - MCS definitions and standard set_lindenbaum
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS properties including negation completeness
- `Mathlib.ModelTheory.Satisfiability` - Mathlib's IsMaximal definition for theories

## Next Steps

1. Create implementation plan with phases:
   - Phase 1: Prove `neg_consistent_when_pkg_inconsistent`
   - Phase 2: Modify henkinStep and update henkinStep_consistent
   - Phase 3: Verify downstream proofs (saturation, consistency)
   - Phase 4: Remove sorries from `maximal_tcs_is_mcs`
   - Phase 5: Verify task 888 Phase 3 is unblocked
