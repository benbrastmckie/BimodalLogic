# Research Report: Task 155 — Reynolds Pipeline Activation

**Task**: Activate Reynolds pipeline for sorry-free discrete completeness
**Date**: 2026-05-16
**Mode**: Team Research (4 teammates)
**Session**: sess_1747398000_0e34c6

## Summary

Task 155 is the final blocker for sorry-free `bx_completeness`. The mathematical preconditions are met: `sum_preservation` (Doets Lemma 1.4) is sorry-free from task 154, and `table_correctness` is sorry-free from task 148. Five sorries in IntegerModel.lean must be closed following Reynolds 1994 Theorem 15, then the Transfer.lean fallback must be replaced with the genuine pipeline. The truth transfer bridge (Step 6) is the hardest piece — it requires systematic construction, not an adapter pattern.

## Key Findings

### 1. The Sorry Chain (All 5 Must Be Closed)

```
bx_completeness (Completeness.lean:162)
  → doets_countermodel_discrete (Transfer.lean:145, currently fallback)
    → chronicle_is_good (IntegerModel.lean:214) [SORRY]
      → one_class (PROVED, but depends on two sorried lemmas below)
        → contemp_equiv_is_equiv.trans (line 128) [SORRY]
          → finite_structures_good (line 90) [SORRY]
          → sum_preservation (DONE - task 154)
        → no_gaps_discrete (line 145) [SORRY]
          → no_boundary_at_successor (PROVED, uses finite_structures_good)
      → very_good_implies_good (line 202) [SORRY]
        → sum_preservation (DONE)
        → finite_structures_good [SORRY]
```

**Closure order** (strict dependencies):
1. `finite_structures_good` — foundation for everything
2. `contemp_equiv_is_equiv` transitivity — uses #1 + sum_preservation
3. `no_gaps_discrete` — uses #2
4. `very_good_implies_good` — uses #1 + sum_preservation (independent of #2-3)
5. `chronicle_is_good` — uses one_class (now sorry-free via #1-3) + #4

### 2. finite_structures_good — The Foundation (NON-TRIVIAL)

**The Critic's finding is critical**: This does NOT follow from sum_preservation. It is Doets 1989 Theorem 1.1 (k-type realizability).

**The real difficulty**: `ZIntervalStructure.toOrdered` has carrier = ALL of ℤ (unbounded), not just the interval. A depth-k sentence like `∃x, P(x)` could be true on the full ℤ model (if P is true outside the intended interval) but false on the finite structure M. The naive "embed M into ℤ" approach is WRONG.

**Correct approach (from Reynolds Section 8)**: A finite structure on n elements IS a Z-interval `[0, n-1]`. The definition `good sig k M := ∃ Z : ZIntervalStructure sig, k_equiv sig k M (Z.toOrdered sig)` requires Z.toOrdered to be k-equivalent to M. But Z.toOrdered.carrier = ℤ while M.carrier = Fin n. The k-equivalence `k_equiv sig k` compares `k_type_of` (normal form satisfaction as sentences). For sentences of depth ≤ k, the elements outside the interval can participate in quantifiers.

**Resolution options**:
- **(A) Redefine `ZIntervalStructure.toOrdered`** to restrict its carrier to the interval (makes `good` mean "k-equiv to a structure on a Z-interval"), or
- **(B) Prove that for any finite M, there exists a predicate assignment on ℤ extending M such that the full ℤ structure is k-equivalent to M**. This is standard: pad outside with a repeating pattern that preserves the k-type. For finite M with endpoints, the repetition is: copy the last element's predicates infinitely. A singleton is k-equivalent to itself for all k.
- **(C) Recognize the existing definition may already handle this**: Re-read `good` and `ZIntervalStructure.toOrdered` to check if the definition already restricts quantifiers. The definition at IntegerModel.lean:53-58 shows `toOrdered` has `carrier := ℤ` with `carrier_order := inferInstance`. So quantifiers range over all of ℤ. This means (B) is the correct approach.

**The easiest implementation**: Since M is finite and discrete, it has n elements. Construct Z with `lo = some 0, hi = some (n-1)` and `interp` matching M on `[0,n-1]`. For the k-equivalence proof, observe that the `carrier_order` on Z.toOrdered is ℤ's full order, but `k_equiv` compares `k_type_of` which evaluates `NormalForm sig k 0` on the structure. The sentence-level normal forms (arity 0) are Boolean combinations of statements about existence of elements with certain predicate patterns. Since Z has infinite carrier, it has elements outside `[0,n-1]` — their predicates affect truth of existential sentences.

**Best resolution**: Modify the interpretation outside the interval to not affect depth-k truth. Standard technique: for a finite structure M on [0,n-1], extend to ℤ by making all integers outside [0,n-1] satisfy the same predicates as the nearest endpoint. This preserves k-equivalence because any winning strategy in the EF game on M can be extended to the padded Z: the Duplicator responds to challenges outside [0,n-1] by pointing to the relevant endpoint.

**Estimated difficulty**: MEDIUM-HARD. The EF argument is clean mathematically but may require building a new `nf_eval_nf` equivalence lemma.

### 3. contemp_equiv_is_equiv Transitivity

**Reynolds Lemma 17 argument**: If a < b < c with [a,b] very good and [b,c] very good, show [a,c] is very good. For any t ≤ u in [a,c]:
- Both in [a,b] or both in [b,c]: immediate from hypothesis
- t ∈ [a,b], u ∈ [b,c]: M|[t,u] = M|[t,b] + M|[b+1,u] (in discrete order). Each piece is good. By `doets_lemma_1_4` (sum_preservation), the 2-element sum is k-equiv to a concatenation of Z-intervals, which IS a Z-interval.

**Estimated difficulty**: MEDIUM. Requires formalizing the subinterval decomposition and applying sum_preservation on a 2-element index set.

### 4. very_good_implies_good (Reynolds Lemma 16)

For a countable, very-good, discrete structure M without endpoints:
- Choose a cofinal sequence a₀ < a₁ < a₂ < ... covering M
- Each M|[aᵢ, aᵢ₊₁-1] is good (by very-good + finite)
- Take Zᵢ ≡_k M|[aᵢ, aᵢ₊₁-1]
- By sum_preservation: M ≡_k Σᵢ(Zᵢ), and Σᵢ(Zᵢ) is a half-interval of ℤ

**Estimated difficulty**: MEDIUM-HIGH. Requires careful construction of cofinal sequences in Lean (Countable + NoMaxOrder/NoMinOrder).

### 5. The Truth Transfer Bridge (Step 6) — Systematic, Not an Adapter

**The fundamental challenge**: The Reynolds pipeline produces `good sig k M` (= ∃ Z, k_equiv sig k M Z.toOrdered). We need to go from this to `¬truth_at TM Omega τ t φ` in the full TaskFrame semantics.

**Why naive bridges fail**: `truth_at` for `.box φ` quantifies over ALL histories σ ∈ Omega. `temporal_truth` for `.box φ` merely reads a predicate value. A "bridge" that forces these to agree (e.g., singleton Omega) destroys the intended S5 semantics that the box operator is supposed to capture. This would be a degenerate model.

**Why it still works — the mathematical argument**: In the discrete MCS chronicle, `□φ ∈ mcs(t)` iff φ is in ALL box-equivalent MCS's. The Z-model's predicate for `□φ` at point t captures exactly this: it's true iff the chronicle's root MCS contains `□φ`, which means φ holds at every accessible world. When we construct the TaskFrame, the Omega must be rich enough that `∀σ∈Omega, truth_at M Omega σ t φ` corresponds to `□φ ∈ mcs(t)`. The existing `ParametricCanonicalTaskFrame` + BFMCS coherence does this correctly.

**Recommended systematic approach**: Two viable paths, from simplest to most principled:

**(A) Direct: Prove `k_equiv_preserves_temporal_truth`** — a theorem stating that if two OrderedMonadicStructures are k-equivalent with k ≥ operator_depth(φ)+1, then they agree on temporal_truth for φ at all points. This follows from `k_equiv_preserves_eval` + `table_correctness`. This gives temporal truth on the Z-interval. Then construct a TaskFrame Int directly for the Z-interval where temporal truth = truth_at. For the integer model (one world, deterministic), this IS correct because:
  - The MCS at each integer in the Z-model is the set of formulas temporally true there
  - □φ is in the MCS iff φ is in ALL MCS's (since we have one S5 class — the whole model)
  - With Omega = {single history}, □φ at t ↔ ∀σ∈Omega, truth_at σ t φ ↔ truth_at τ t φ ↔ φ is temporally true everywhere
  - This is correct IFF the Z-model validates □φ at all points when φ is valid — which holds because the chronicle extraction starts from an MCS with □(next_top) (all MCS's in the S5 equivalence class are box-equivalent)

**(B) Reuse ParametricCanonical infrastructure** — construct an FMCS on ℤ from the Z-model (each point's MCS = formulas temporally true there), feed into existing ParametricCanonicalTaskFrame + restricted parametric truth lemma. This is more principled but requires showing the Z-model's temporal truths form MCS's at each point (non-trivial Lindenbaum construction).

**(C) Avoid the bridge entirely** — prove that k_equiv between chronicle and Z means the existing `dd_countermodel_chronicle_discrete` construction works with the Z-model instead of the chronicle, inheriting the same FMCS structure. The Z-model's positions correspond to the chronicle's positions; the parametric machinery transfers.

**Recommendation**: Path (A) is the easiest implementation. The single-history model IS mathematically correct for the discrete case because the chronicle extraction produces an S5-class where all points are box-equivalent (from `□(next_top) ∈ A`). This means □φ holds at time t iff φ holds at ALL times — which is exactly what Omega = {single world-history covering all of ℤ} captures.

### 6. The Missing `k_equiv_preserves_eval` Theorem

This is the critical bridge lemma. Statement:
```lean
theorem k_equiv_preserves_eval (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) (h : k_equiv sig k M N)
    (α : MonadicFormula sig 0) (h_depth : α.quantifier_depth ≤ k) :
    eval M Fin.elim0 α ↔ eval N Fin.elim0 α
```

**Proof sketch**: k-equiv means k_type_of M = k_type_of N. k_type_of maps each NormalForm to whether M satisfies it. Every sentence of depth ≤ k is a Boolean combination of normal forms (by the normal form theorem). Since M and N agree on all normal forms (same k-type), they agree on all Boolean combinations, hence on all depth-k sentences.

**Implementation**: Requires the "formula to normal form compilation" step — showing that every `MonadicFormula sig 0` of depth ≤ k can be expressed as a Boolean combination of statements captured by `NormalForm sig k 0`. The NormalForm machinery exists in NEquivalence.lean but the compilation theorem may not be explicit.

**Alternative**: If `nf_eval_nf` and `eval` are connected via a proven equivalence, this may already be available implicitly.

## Synthesis

### Conflicts Resolved

1. **Teammate B claimed "trivial TaskFrame with Set.univ"** vs. **Teammate C/A showed box semantics mismatch**: RESOLVED in favor of C/A. The naive singleton WorldState approach fails for temporal formulas where box varies with time. However, for this specific problem (discrete case, single S5 class), a carefully constructed single-history model IS correct — but must be justified mathematically, not assumed trivially.

2. **"finite_structures_good follows from sum_preservation"** (implied by task description) vs. **Critic: it requires Doets Theorem 1.1**: RESOLVED — Critic is correct. This is independent of sum_preservation and requires a separate argument about finite structure embedding.

3. **Effort estimates**: Teammate A says 18-26 hours; Teammate D says "clear path." Synthesis: the IntegerModel.lean sorries (phases 1-4) are 8-12 hours; the truth transfer bridge (phases 5-6) is 8-12 hours; wiring is 1-2 hours. Total: 17-26 hours.

### Gaps Identified

1. **`k_equiv_preserves_eval`** — Not yet formalized. May require significant normal-form infrastructure.
2. **`finite_structures_good`** — The carrier mismatch (finite M vs. unbounded Z.toOrdered) requires careful handling. Not a trivial embedding.
3. **atomMap direction** — `table_correctness` takes `atomMap : Formula → sig.preds` but Transfer.lean defines `mkAtomMap : sig.preds → Formula`. A forward map must be constructed (LOW difficulty).
4. **ROADMAP.md is stale** — References tasks 139/140 as blocking, but both are completed. Should be updated post-task-155.

### Recommendations

**Implementation order** (follow Reynolds 1994 exactly, no shortcuts):

1. **finite_structures_good** — Embed finite M into Z-interval with predicate extension preserving k-type. Use EF-game/normal-form argument. (MEDIUM-HARD, 3-4h)

2. **contemp_equiv_is_equiv transitivity** — Reynolds Lemma 17. Decompose [a,c] into [a,b]+[b+1,c], apply sum_preservation. (MEDIUM, 2-3h)

3. **no_gaps_discrete** — In discrete order, if class boundary exists, it must be at a successor pair (contradiction with no_boundary_at_successor). Classical logic + well-ordering on ℤ. (MEDIUM, 2-3h)

4. **very_good_implies_good** — Reynolds Lemma 16. Cofinal decomposition + sum_preservation. (MEDIUM-HIGH, 3-4h)

5. **chronicle_is_good** — Chain: one_class → very_good → good. (EASY once #1-4 done, 1h)

6. **k_equiv_preserves_eval** + truth transfer — The key bridge theorem. May require formula-to-normal-form compilation. (HARD, 4-6h)

7. **TaskFrame Int construction** — For the single-S5-class discrete case: WorldState = Int, task_rel deterministic, single history, valuation from Z-model. Prove truth_at = temporal_truth for this specific model. (MEDIUM-HARD, 3-4h)

8. **Wire Transfer.lean** — Replace fallback with genuine pipeline. Verify `#print axioms bx_completeness` shows no sorryAx. (EASY, 1-2h)

**Total estimated effort**: 19-27 hours across 8 phases.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary implementation approach | completed | medium-high |
| B | Alternative approaches, infrastructure | completed | high |
| C | Critic (gaps, blockers) | completed | high |
| D | Strategic horizons | completed | high |

## References

- Reynolds 1994, Theorem 15 (Section 8): One-class + very_good → good → Z-model
- Reynolds 1994, Theorem 18 (Section 9): Full completeness pipeline
- Reynolds 1994, Lemma 16: very_good → good (lexicographic sum)
- Reynolds 1994, Lemma 17: ~M is a contemporaneous equivalence relation
- Doets 1989, Lemma 1.4: Sum preservation (task 154, CLOSED)
- Doets 1989, Theorem 1.1: k-type realizability for finite structures
- `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- `literature/Doets_1989_Monadic_Pi11_Theories.md`
