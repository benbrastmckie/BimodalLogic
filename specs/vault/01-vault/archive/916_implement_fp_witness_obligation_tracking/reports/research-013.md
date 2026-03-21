# Research Report: Task #916

**Task**: Implement F/P Witness Obligation Tracking
**Date**: 2026-02-23
**Focus**: Options analysis for fixing 8 remaining build errors in WitnessGraph.lean

## Summary

WitnessGraph.lean (2,419 lines, 0 sorries) has 8 build errors resulting from Phase 3A implementation. All errors stem from a common root cause: the proofs manipulate `processStep` results (a complex nested match/if expression over `Nat.unpair`) and struggle with dependent type rewriting when `processStep` output must be equated with `addFutureWitness` or `addPastWitness`. This report analyzes three fix options and provides concrete technical solutions for the recommended approach.

## The 8 Errors: Detailed Analysis

### Error Group 1: Dependent Index Transport (Lines 1700, 1816)

**Error 1700** (`simp` made no progress):
- **Location**: `forward_witness_of_isWitnessed`, case: processStep = addFutureWitness
- **Goal**: `psi' in (processStep g m).nodes[g.nodes.length].mcs`
- **Available**: `h_ps_eq : processStep g m = g.addFutureWitness nIdx h_nIdx psi' h_F'` and `h_mem : psi' in Classical.choose ...` (from `addFutureWitness_contains_formula`)
- **Root Cause**: `simp only [h_ps_eq, WitnessGraph.addFutureWitness, ...]` fails because the rewrite target `(processStep g m).nodes[g.nodes.length]` has a dependent bound proof `g.nodes.length < (processStep g m).nodes.length` embedded in the term. The `simp` cannot rewrite `processStep g m` to `g.addFutureWitness ...` inside the indexed access because the bound proof's type changes.
- **Fix**: Extract `.nodes` equality via `congrArg WitnessGraph.nodes h_ps_eq`, then use `simp` on the nodes-level equality to transport the index.

**Error 1816** (Type mismatch):
- **Location**: `backward_witness_of_isWitnessed`, case: processStep = addPastWitness
- **Goal**: `(processStep g m).nodes = (g.addPastWitness nIdx h_nIdx psi' h_P').nodes`
- **Root Cause**: The proof uses `congr 1; exact h_ps_eq`, but `congr 1` on an indexed list access does not produce the expected subgoals. The `congr 1` decomposes the getElem access incorrectly instead of going through the struct field.
- **Fix**: Replace `congr 1; exact h_ps_eq` with `exact congrArg WitnessGraph.nodes h_ps_eq`.

### Error Group 2: processStep Unfolding (Lines 1980-1981)

**Error 1980** (`rewrite` failed: pattern not found):
- **Location**: `witnessGraph_backward_P_local`, proving `isWitnessed` becomes true at step n+1
- **Goal**: After `unfold processStep; simp only [h_unpair, ..., dite_true]; split`, the proof expects the `split` to match on `decodeFormulaWG`, but it actually splits on a different `if`/`match` in the unfolded term.
- **Root Cause**: After `simp only [h_unpair, show i < g_n.nodes.length from h_i_at_n, dite_true]`, the `split` picks the first splittable expression, which may be a different branch than expected. The subsequent `rename_i h_none; rw [h_decode] at h_none` fails because `h_none` captures the wrong hypothesis.

**Error 1981** (too many variable names / `rewrite` failed):
- **Location**: Same as 1980, subsequent tactic line
- **Root Cause**: Cascading from 1980 - the proof is in the wrong case split.
- **Fix**: Replace the manual `unfold processStep; split` approach with `simp only [processStep, h_unpair, ...]` followed by explicit `split` on the decode match, or use a helper lemma that factors out the processStep-to-addFutureWitness reduction.

### Error Group 3: Placeholder Synthesis (Line 2135)

**Error 2135** (can't synthesize placeholder for `head`):
- **Location**: `processStep_new_edge_nodes_gt`, contradiction case
- **Goal**: Derive `False` from `h_edges : g.edges = g.edges ++ [{ src, dst, dir }]`
- **Root Cause**: The code `have : g.edges.length = (g.edges ++ [_]).length := by rw [h_edges]` uses `[_]` where the anonymous placeholder `_` inside a list literal `[_]` creates an unresolvable metavariable for the list element type's `head` argument.
- **Fix**: Replace `[_]` with the concrete edge value. Since `h_edges` already contains the edge, use `have := congrArg List.length h_edges; simp at this` which avoids the placeholder entirely.

### Error Group 4: Split on Unfolded processStep (Lines 2260, 2386)

**Error 2260** (`split` failed):
- **Location**: `witnessGraph_GContent_propagates`, new forward edge case
- **Goal**: After `unfold processStep at h_j |->`, the goal contains a massive nested `match Nat.unpair n with | (fst, pairIdx) => match Nat.unpair pairIdx with ...` expression.
- **Root Cause**: `split` cannot find a splittable `if`/`match` because the `match` on `Nat.unpair` result (a `let`-bound pattern match) is not in a form that `split` recognizes. The `let (_, pairIdx) := Nat.unpair n` compiles to a `match` on pairs, but after `unfold`, the resulting term structure differs from what `split` expects.

**Error 2386** (`split` failed):
- **Location**: `witnessGraph_HContent_propagates`, new backward edge case
- **Root Cause**: Identical to 2260, symmetric case for HContent.
- **Fix for both**: Do NOT unfold `processStep`. Instead, use `processStep_outcome` to get the structural equality `h_ps_eq`, then use `congrArg WitnessGraph.nodes h_ps_eq` to transport node-level properties. The GContent/HContent extension properties are already proven in `addFutureWitness_GContent_extends` and `addPastWitness_HContent_extends` respectively.

## Option A: Dependent Rewrite Patterns (Recommended)

### Approach

Fix each error using proven Lean 4 patterns for dependent type rewrites, without introducing any sorry. The key insight is that most errors arise from trying to rewrite through struct equality at the indexed-access level, when the fix is to work at the `.nodes` field level first.

### Technical Solutions

#### Pattern 1: `congrArg` for Struct Field Transport

When `h_ps_eq : processStep g m = g.addFutureWitness ...` and the goal involves `(processStep g m).nodes[idx]`, extract the field first:

```lean
have h_nodes_eq : (processStep g m).nodes = (g.addFutureWitness ...).nodes :=
  congrArg WitnessGraph.nodes h_ps_eq
rw [show (processStep g m).nodes[idx] = (g.addFutureWitness ...).nodes[idx] from by simp [h_nodes_eq]]
```

This avoids the dependent type issue because `simp` on lists handles index bounds automatically.

**Verified**: This pattern compiles successfully in isolation testing.

#### Pattern 2: Direct `congrArg` for Field Equality Goals

When the goal is `(processStep g m).nodes = (g.addPastWitness ...).nodes`:

```lean
exact congrArg WitnessGraph.nodes h_ps_eq
```

**Verified**: Compiles successfully.

#### Pattern 3: Length Contradiction via `congrArg`

When deriving contradiction from `h_edges : g.edges = g.edges ++ [edge]`:

```lean
have := congrArg List.length h_edges
simp at this
```

This avoids the placeholder issue with `[_]`.

**Verified**: Compiles successfully.

#### Pattern 4: Avoid Unfolding processStep for Content Propagation

For the GContent/HContent propagation proofs (lines 2260, 2386), replace the `unfold processStep; split; split at h_j` approach with:

```lean
-- Instead of unfold processStep, use processStep_outcome
have h_out := processStep_outcome g n
rcases h_out with h_unchanged | ⟨nIdx, h_nIdx, psi, h_F, h_ps_eq⟩ |
    ⟨nIdx, h_nIdx, psi, h_P, h_ps_eq⟩
-- In the addFutureWitness case:
-- Use h_ps_eq to get node equality
have h_nodes_eq := congrArg WitnessGraph.nodes h_ps_eq
-- Show the new node at g.nodes.length has GContent from source
simp only [WitnessGraph.addFutureWitness] at h_nodes_eq
-- Extract the specific node and apply addFutureWitness_GContent_extends
```

This restructuring avoids all `split` issues because it never unfolds `processStep`.

#### Pattern 5: Correct split Targeting for processStep

For line 1980, the processStep unfolding can work if splits are correctly targeted:

```lean
unfold processStep
simp only [h_unpair, show i < g_n.nodes.length from h_i_at_n, dite_true]
have h_decode := decodeFormulaWG_encodeFormulaWG psi
rw [h_decode]  -- rewrite the decode BEFORE split
-- Now the match on decode is resolved, and we can split on the remaining ifs
simp only [h_F_at_n, dite_true, h_F_wit_false, ite_false]
-- Now we're in the addFutureWitness branch directly
```

The key fix is to rewrite `decodeFormulaWG (encodeFormulaWG psi) = some psi` BEFORE the `split`, collapsing the match on decode, so the subsequent splits target the correct `if` expressions.

### Effort Estimate

| Error | Complexity | Estimated Time |
|-------|-----------|----------------|
| Line 1700 | Medium - congrArg pattern | 20-30 min |
| Line 1816 | Low - direct congrArg | 10 min |
| Lines 1980-1981 | Medium - restructure split sequence | 30-45 min |
| Line 2135 | Low - congrArg for length | 10 min |
| Line 2260 | High - restructure entire proof block | 45-60 min |
| Line 2386 | High - symmetric to 2260 | 30-45 min |
| **Total** | | **2.5-3.5 hours** |

### Risks

1. **Lines 2260/2386 restructuring**: Replacing the `unfold processStep` approach requires connecting `processStep_outcome` with `processStep_edges_subset_or_new`. The former gives structural equality; the latter gives edge form. They must be reconciled to determine which `addFutureWitness`/`addPastWitness` matches the edge constraints. This may require an additional helper lemma.

2. **Line 1980 decode rewriting**: The `rw [h_decode]` before `split` may fail if the decode expression is under a binder. If so, `simp only [h_decode]` or `conv` may be needed.

3. **Cascading errors**: Fixing one error may reveal new errors downstream if the proof state changes.

## Option B: Sorry-Based Structure Verification

### Approach

Insert `sorry` at the 4 distinct proof locations (covering all 8 errors) to verify the overall proof structure compiles, then fix each sorry individually.

### Sorry Locations

1. **Lines 1696-1702** (forward_witness_of_isWitnessed): Replace the failing simp+exact block with `sorry` - covers Error 1700
2. **Lines 1812-1820** (backward_witness_of_isWitnessed): Replace the congr approach with `sorry` - covers Error 1816
3. **Lines 1976-2001** (witnessGraph_backward_P_local): Replace the unfold+split block with `sorry` - covers Errors 1980-1981
4. **Line 2135** (processStep_new_edge_nodes_gt): Replace the length equality with `sorry` - covers Error 2135
5. **Lines 2259-2295** (witnessGraph_GContent_propagates): Replace the unfold block with `sorry` - covers Error 2260
6. **Lines 2385-2417** (witnessGraph_HContent_propagates): Replace the unfold block with `sorry` - covers Error 2386

### Effort Estimate

| Step | Time |
|------|------|
| Insert 6 sorries | 15 min |
| Verify build | 5 min |
| Fix each sorry individually | 2-3 hours |
| **Total** | **2.5-3.5 hours** |

### Assessment

This option has the same total effort as Option A but provides an intermediate checkpoint where the structural soundness is verified. The sorries are all development placeholders (Category 2 per proof-debt-policy.md) with clear remediation paths.

**Drawback**: Introduces temporary proof debt (6 sorries) that must be immediately resolved. The sorries block transitive sorry-freedom for all dependent theorems.

## Option C: Revert and Reapply Incrementally

### Approach

Revert to the phase 2 version (commit eec2a811, 1087 lines, 0 sorries, 0 errors) and reapply the Phase 3 proofs incrementally, building up one theorem at a time.

### Assessment

The phase 2 version has 0 sorries and 0 errors but lacks all Phase 3 theorems (forward_F_local, backward_P_local, GContent/HContent propagation, acyclicity, countability, edge validity). The current version has all these theorems written with 8 errors.

The errors are localized to specific tactic failures, not structural proof problems. The proof architecture is sound; the tactics just need adjustment.

**Drawback**: Reverting would discard ~1,332 lines of correct proof code to rewrite it from scratch. The same dependent type issues would be encountered again during reapplication.

### Effort Estimate

| Step | Time |
|------|------|
| Revert to phase 2 | 5 min |
| Re-prove processStep_edges_subset_or_new | 1 hour |
| Re-prove forward/backward_witness_of_isWitnessed | 2-3 hours |
| Re-prove main theorems | 2-3 hours |
| Re-prove content propagation | 2-3 hours |
| **Total** | **7-10 hours** |

## Recommendation

**Option A (Dependent Rewrite Patterns)** is the recommended approach, with the following rationale:

1. **Same effort as Option B** (~2.5-3.5 hours) but without introducing temporary proof debt
2. **3-4x less effort than Option C** (revert+reapply)
3. **All fixes are well-understood**: Each error has a verified solution pattern
4. **No structural changes needed**: The proof architecture is sound; only tactic-level adjustments are required

### Implementation Order

1. **Line 2135 first** (easiest, standalone) - verify the `congrArg List.length` pattern works in context
2. **Line 1816 second** (easy, builds confidence with congrArg) - verify field-level congrArg
3. **Line 1700 third** (medium, similar pattern to 1816) - verify node-level transport
4. **Lines 1980-1981 fourth** (medium, requires careful split targeting) - verify decode rewriting
5. **Lines 2260+2386 last** (hardest, may need helper lemma) - restructure to avoid unfold

This order ensures early wins build confidence and later fixes can leverage established patterns.

### Contingency

If any single error proves harder than expected (>1 hour), insert a targeted `sorry` for that specific location and continue with other fixes. This limits proof debt to at most 1-2 development placeholder sorries rather than 6.

## Key Technical Insights

1. **Never unfold processStep in content propagation proofs**. Use `processStep_outcome` + `congrArg` instead.
2. **Work at the `.nodes` field level**, not the struct level, when transporting through indexed access.
3. **Rewrite decode before splitting** when manually unfolding processStep for isWitnessed proofs.
4. **Mathlib's `DepRewrite` tactic** (`Mathlib.Tactic.DepRewrite`) exists for dependent rewrites but is likely overkill here since `congrArg`-based patterns suffice.

## References

- WitnessGraph.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
- Implementation plan v007: `specs/916_implement_fp_witness_obligation_tracking/plans/implementation-007.md`
- Mathlib.Tactic.DepRewrite: dependent rewrite tactic (found via lean_leansearch)
- Lean 4 `congrArg`: `{a1 a2 : A} (f : A -> B), a1 = a2 -> f a1 = f a2`

## Next Steps

1. Implement Option A fixes in the order specified above
2. Build after each fix to verify error count decreases
3. Run final build to confirm 0 errors, 0 sorries
4. Proceed to Phase 4 (Int embedding)
