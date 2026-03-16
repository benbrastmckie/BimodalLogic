# Teammate B Findings: Alternative Approaches for Strict Semantics

**Task**: 964 - resolve_atom_type_freshness_debt
**Run**: 006
**Role**: Research alternative proof approaches for strict semantics
**Started**: 2026-03-14T10:00:00Z
**Completed**: 2026-03-14T11:30:00Z

## Key Findings

### 1. The Core Gap: No T-axiom in TM Logic

The TM logic uses **strict (irreflexive) G/H semantics**:
- `G(phi)` = "phi holds at all times t' > t" (strictly future)
- `H(phi)` = "phi holds at all times t' < t" (strictly past)

**Critical consequence**: The T-axioms `G(phi) -> phi` and `H(phi) -> phi` are NOT valid.

The standard Gabbay IRR proof requires deriving `neg(p) in M'` from `H(neg(p)) in M'`, which uses T-axiom:
```
H(neg(p)) in M'  -->  [by T-axiom: H(phi) -> phi]  -->  neg(p) in M'
```
Without T-axiom, this step fails completely.

### 2. Duality Lemma Analysis

The codebase has a powerful duality lemma in `WitnessSeed.lean`:
```lean
theorem GContent_subset_implies_HContent_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_GC : GContent M ⊆ M') :
    HContent M' ⊆ M
```

This uses `temp_a: phi -> G(P(phi))` to derive:
- If `phi in HContent(M')` (i.e., `H(phi) in M'`), then `phi in M`

**Key insight**: From `CanonicalR(M, M')` and `H(neg(p)) in M'`:
- `neg(p) in HContent(M')` by definition
- `neg(p) in M` by duality

But we need `neg(p) in M'` for contradiction, not `neg(p) in M`.

### 3. temp_a Forward-Backward Iteration Analysis

The temp_a axiom: `phi -> G(P(phi))`

From `neg(p) in M`:
1. `G(P(neg(p))) in M` by temp_a
2. `P(neg(p)) in GContent(M)`
3. If `GContent(M) subseteq M'`, then `P(neg(p)) in M'`

Now `P(neg(p)) = neg(H(neg(neg(p))))`:
- We have `p in M'` from naming set
- Double negation gives `neg(neg(p)) in M'` (derivable from `p`)
- So `H(neg(neg(p)))` may or may not be in M'
- `P(neg(p)) = neg(H(neg(neg(p))))` means `H(neg(neg(p))) not-in M'` or...

**Analysis**: There is NO direct contradiction from having both `H(neg(p)) in M'` and `P(neg(p)) in M'`:
- `H(neg(p))` says "neg(p) at all past times"
- `P(neg(p))` says "neg(p) at some past time"
- These are logically compatible!

### 4. Alternative Naming Set Constructions

#### Approach A: Using F/P instead of atom/H(neg(atom))

**Idea**: Instead of naming set `{atom(p), H(neg(p))}`, use F/P formulas.

**Problem**: F(phi) and P(psi) formulas don't create the same "fresh marker" effect. The Gabbay IRR rule specifically requires the pattern `(atom(p) AND H(neg(p))) -> chi` where p not-in chi.atoms.

#### Approach B: Modified naming set with G-closure

**Idea**: Include `G(neg(p))` in naming set instead of `H(neg(p))`.

**Problem**: `G(neg(p))` says "neg(p) at all future times" which doesn't create contradiction with `p` now. And without T-axiom, we can't derive `neg(p) in M'` from `G(neg(p)) in M'`.

### 5. Frame-Level vs Syntactic Irreflexivity

#### Semantic/Frame-theoretic approach

**Observation**: Irreflexivity in the codebase is ALREADY obtained at the frame level via:
- The Preorder on CanonicalMCS uses strict `<`
- This strict `<` is definitionally irreflexive

From `CanonicalIrreflexivityAxiom.lean`:
> "The completeness chain does NOT require canonicalR_irreflexive. Irreflexivity of the canonical timeline is obtained for free via the preorder on CanonicalMCS, which uses strict `<`."

**Implication**: The syntactic proof of `canonicalR_irreflexive` is mathematically interesting but UNUSED in practice. The working codebase achieves irreflexivity semantically.

### 6. Conservative Extension Analysis

**Strategy**: Extend language F to F+ with fresh atom type, prove irreflexivity in F+, then project back.

**Why it fails**:
- Fresh atom q lives only in F+
- Contradiction `{atom_ext(q), neg_ext(atom_ext(q))} subseteq M'_ext` is at F+ level
- This doesn't propagate back to F level
- The naming set's contradiction is "trapped" in the extension

From `DirectIrreflexivity.lean`:
> "The fundamental gap: the naming argument creates a contradiction at the level of the fresh atom, but since q lives only in F+ (not F), the contradiction does not propagate to the F level."

### 7. The Fundamental Obstruction

After comprehensive analysis, the obstruction is fundamental:

**Theorem (Informal)**: In strict temporal semantics without T-axiom, the canonical accessibility relation's irreflexivity CANNOT be proven syntactically from the naming set construction alone.

**Evidence**:
1. `DirectIrreflexivity.lean` proves Path A (direct F-proof) is impossible
2. All literature proofs rely on T-axiom
3. The 2 sorries in `CanonicalIrreflexivity.lean` are at precisely the T-axiom gap
4. Alternative approaches all fail at the same point: getting `neg(p) in M'`

## Alternative Approaches Analyzed

| Approach | Description | Why It Fails |
|----------|-------------|--------------|
| **Duality argument** | Use `HContent(M') subseteq M` to get `neg(p) in M` | We need `neg(p) in M'`, not `neg(p) in M`. And `neg(p)` is not p-free. |
| **temp_a iteration** | Chain `neg(p) -> G(P(neg(p))) -> P(neg(p)) in M'` | `P(neg(p))` and `H(neg(p))` in M' are compatible, no contradiction |
| **F/P naming set** | Replace `{atom(p), H(neg(p))}` with F/P formulas | IRR rule specifically needs the atom/H(neg) pattern |
| **G(neg) instead of H(neg)** | Use `G(neg(p))` in naming set | No contradiction without T-axiom |
| **Conservative extension** | Prove in extended language F+ | Contradiction trapped at F+ level, doesn't propagate |
| **Semantic/frame approach** | Prove irreflexivity as frame property | **WORKS** - already implemented via strict `<` |

## Most Promising Direction

### Direction 1: Accept the Axiom (Recommended)

The axiom `canonicalR_irreflexive` is:
1. **Mathematically legitimate** as a frame property for strict semantics
2. **Unused** in the active codebase (completeness works without it)
3. **Already satisfied** via the definitional irreflexivity of strict `<` on CanonicalMCS

**Action**: Keep axiom as documented frame property. No code changes needed.

### Direction 2: Correspondence Theory Reformulation

If a syntactic proof is desired, reformulate using correspondence theory:

**Idea**: The T-axiom `G(phi) -> phi` corresponds to reflexivity of the accessibility relation. Its absence corresponds to potential irreflexivity. But proving actual irreflexivity requires showing the frame condition is FORCED by the logic.

**Observation**: In strict semantics, irreflexivity is NOT forced by axioms alone - it's a choice of which frames to consider. The axiom simply documents this choice.

### Direction 3: Explicit Frame Condition

Add irreflexivity as a semantic frame condition rather than trying to prove it syntactically:

```lean
-- Already exists in the codebase:
axiom canonicalR_irreflexive :
  forall (M : Set Formula), SetMaximalConsistent M -> neg (CanonicalR M M)
```

This is the CORRECT formalization: irreflexivity is a frame constraint for the intended semantics, not a derivable theorem.

## Confidence Level

**HIGH** confidence in the analysis:

1. **Multiple independent paths exhausted**: Direct proof, duality, temp_a iteration, conservative extension, F/P variants - all fail at the same point
2. **Literature confirmation**: Goldblatt (1992), BdRV (2001), and Gabbay (1981) all use T-axiom in their proofs
3. **Codebase evidence**:
   - `DirectIrreflexivity.lean` formally proves Path A impossible
   - `CanonicalIrreflexivity.lean` has 2 sorries at precisely the T-axiom gap
   - The working completeness proof uses semantic irreflexivity via strict `<`
4. **ROAD_MAP confirmation**: Reflexive G/H refactor was ABANDONED after 3 months of effort, precisely because strict semantics is essential for density proofs

## Summary

The irreflexivity proof WITHOUT T-axiom appears to be mathematically impossible in strict temporal semantics. However, this is NOT a blocker because:

1. The axiom is UNUSED - completeness obtains irreflexivity semantically
2. The axiom is LEGITIMATE - it documents a frame property choice
3. The axiom is SOUND - strict `<` on CanonicalMCS satisfies it

**Recommendation**: Accept `canonicalR_irreflexive` as a legitimate frame property axiom. Do NOT attempt syntactic proof. The mathematical gap is fundamental, not a fixable implementation issue.

## Appendix: Code Locations Examined

| File | Purpose | Key Finding |
|------|---------|-------------|
| `CanonicalIrreflexivityAxiom.lean` | Axiom declaration | Documents "unprovable without freshness" |
| `CanonicalIrreflexivity.lean` (lines 1273, 1356) | Failed proof | 2 sorries at T-axiom gap |
| `DirectIrreflexivity.lean` | Path A analysis | Proves direct F-proof impossible |
| `WitnessSeed.lean` (lines 324-351) | Duality lemma | `GContent_subset_implies_HContent_reverse` |
| `Axioms.lean` (line 228) | temp_a axiom | `phi -> G(P(phi))` |
| `TemporalContent.lean` | GContent/HContent | Definitions for canonical accessibility |

## References

- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes. Ch. 6
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge. Ch. 4.8
- Gabbay, D.M. (1981). An irreflexivity lemma with applications to axiomatizations of conditions on tense frames.
- Prior research: research-003.md, research-004.md, research-005.md (Task 964)
