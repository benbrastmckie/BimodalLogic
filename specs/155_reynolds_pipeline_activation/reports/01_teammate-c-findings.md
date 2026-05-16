# Critic Findings: Reynolds Pipeline Activation (Task 155)

**Date**: 2026-05-16
**Role**: Teammate C (Critic)
**Confidence Level**: HIGH

## Key Findings

### 1. sum_preservation IS Sorry-Free (Assumption 1: CONFIRMED)

`NEquivalence.lean` has **zero sorries**. The stale comment at line 1141-1143 ("sum_preservation_proof delegates to sum_nf_agree, which has 4 remaining sorries") is from before task 154 closed them. The `KEquivalenceFramework` instance at line 1113-1145 is fully implemented.

### 2. finite_structures_good Does NOT Follow From sum_preservation (Assumption INCORRECT)

**Critical gap**: The docstring correctly states `finite_structures_good` requires "Doets 1989, Theorem 1.1 (k-type realizability)." This is a DIFFERENT theorem from sum_preservation (Doets 1.4).

**What it actually needs**: For a finite ordered structure M with carrier embedded in ℤ, prove there exists a `ZIntervalStructure sig` Z such that `k_equiv sig k M (Z.toOrdered sig)`. The proof should be straightforward: a finite structure on n elements is isomorphic (as an ordered structure) to some interval [a, a+n-1] of ℤ. Since `ZIntervalStructure.toOrdered` has carrier = ALL of ℤ (not just the interval!), we need to construct Z with:
- `interp p i := M.interp p (embedding i)` for i in the interval
- `interp p i := arbitrary` for i outside

Then show k-equivalence. This is actually a non-trivial construction because the carrier types differ (`M.carrier` is finite, `Z.toOrdered.carrier = ℤ`). k-equivalence compares normal form satisfaction, so we need: for every depth-k sentence, M satisfies it iff Z (restricted to the interval in terms of quantifier scope) does. But `Z.toOrdered` has carrier ℤ with NO restriction — the extra elements outside the interval may cause quantified sentences to have different truth values!

**This is a REAL BLOCKER**: The naive embedding fails because monadic FO sentences on Z.toOrdered can quantify over all of ℤ, while the finite structure M only has a bounded domain. A depth-k sentence `∃x, P(x)` would be true in Z.toOrdered (with elements outside the interval satisfying P) but false in M.

**Resolution strategy**: Either (a) define `good` using a restricted version of k_equiv that only considers the interval portion, or (b) prove that for finite discrete structures, the interpretation outside the interval can be chosen to not affect depth-k truth. This requires careful analysis of the Ehrenfeucht-Fraissé game characterization.

### 3. table_correctness Connection: atomMap Direction Mismatch (Minor Issue)

`table_correctness` takes `atomMap : Formula → sig.preds`, but Transfer.lean's `mkAtomMap` provides `sig.preds → Formula`. The forward map (`atomMap_fwd`) is needed but doesn't exist yet.

**Severity**: LOW. Since `sig.preds = φ.predFormulas` (a `Finset Formula` treated as type), and for atoms/box-subformulas of φ they WILL be members, constructing the forward map is straightforward: `fun ψ => if h : ψ ∈ φ.predFormulas then ⟨ψ, h⟩ else default`.

The remaining question: what happens for formulas NOT in `predFormulas`? `temporal_truth` calls `atomMap (.atom a)` which may not be in `φ.predFormulas` if `a` doesn't appear in `φ`. But this can't happen: `temporal_truth` is called recursively on subformulas of φ, so any atom encountered IS a subformula of φ and thus in `predFormulas`.

### 4. The one_class → no_gaps_discrete Dependency Chain (NOT Circular but BLOCKED)

Dependency chain:
```
one_class
  ← no_gaps_discrete (SORRY: line 145)
  ← no_boundary_at_successor (PROVEN, uses finite_structures_good)
  ← finite_structures_good (SORRY: line 90)
```

And separately:
```
one_class uses contemp_equiv_is_equiv.trans (SORRY: line 128)
```

**Not circular** but has TWO independent sorry paths:
1. `finite_structures_good` (needed for both `no_boundary_at_successor` and `contemp_equiv.refl`)
2. `contemp_equiv_is_equiv.trans` (transitivity of ~M)
3. `no_gaps_discrete` (boundary existence)

The transitivity sorry (line 128) is particularly important: Reynolds proves transitivity using sum_preservation (if [a,b] is very good and [b,c] is very good, then [a,c] is very good because [a,c] = [a,b] + {b} + [b+1,c] and sum_preservation applies). So this IS closeable with the now-sorry-free sum_preservation, but requires careful formalization.

### 5. very_good_implies_good: Only Needs Lemma 1.4 (Confirmed)

Reynolds Lemma 16 proof decomposes M into subintervals (indexed by ℕ) and applies sum_preservation (Lemma 1.4) to show the lexicographic sum of their Z-interval equivalents is k-equivalent to M. This does NOT need Lemma 1.5 (the type-matching variant). The comment in `OrderedSum.lean` line 15-16 correctly states "doets_lemma_1_5: bypassed in discrete case by one_class argument."

### 6. The Bridge Problem: TaskFrame Int Construction (SIGNIFICANT Gap)

The return type requires:
```lean
∃ (D : Type) (_ : AddCommGroup D) ... (F : TaskFrame D) (TM : TaskModel F)
  (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
  (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D), ¬truth_at TM Omega τ t φ
```

The Reynolds pipeline produces a `ZIntervalStructure sig` with `interp : sig.preds → ℤ → Prop`. The gap:

**`truth_at` vs `temporal_truth`**:
- `temporal_truth` treats `.box φ` as a simple predicate lookup
- `truth_at` quantifies `.box φ` over ALL histories σ ∈ Omega
- `truth_at` atoms require `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`

**Two approaches**:

**(A) Reuse ParametricCanonicalTaskFrame Int (following dd_countermodel_chronicle_discrete pattern):**
This requires constructing an FMCS on ℤ from the Z-model. Specifically, at each integer i, we need an MCS `mcs(i)` such that for each predicate formula ψ ∈ φ.predFormulas: `ψ ∈ mcs(i) ↔ Z.interp (atomMap ψ) i`. But MCS's contain ALL formulas, not just those in predFormulas. Constructing such MCS's would essentially require a Lindenbaum extension at each point — non-trivial but follows the existing pattern.

**(B) Build a minimal TaskFrame directly:**
- WorldState = Unit (single world state)
- task_rel = trivial (always related)
- WorldHistory with domain = Set.univ, states = const
- Valuation from Z.interp
- Omega = Set.univ (single-history model)

This is MUCH simpler but has a problem: `truth_at` for `.box φ` quantifies over ALL σ ∈ Omega. If Omega = {τ} (singleton), box reduces to `truth_at M {τ} τ t φ`, effectively making □φ ↔ φ. This is S5-valid only if all histories in Omega agree. So approach (B) works if Omega is a singleton or if all histories agree on non-temporal content.

**Actually the simplest approach is (A')**: Use the existing `ParametricCanonicalTaskFrame Int` + `ParametricCanonicalTaskModel Int` + the existing `rooted_succ_discrete_fmcs` construction. The current fallback ALREADY uses this! The insight: the chronicle produces an FMCS on ℤ → these MCS's at each integer provide the parametric canonical model → the parametric truth lemma gives `¬truth_at`.

The Reynolds pipeline shows this FMCS is k-equivalent to a Z-interval. So we don't need a NEW TaskFrame — we just need to prove that the k-equivalence implies the same temporal truth, which means φ is still false at the root.

### 7. Hidden Lean Issues

- **noncomputable markers**: `mkSigFrom`, `mkAtomMap` are `noncomputable`. This is fine for existence proofs.
- **No universe issues** detected: all types are in `Type` or `Type 1`.
- **Typeclass resolution**: `SuccOrder` and `PredOrder` instances on `LimitDomSubtype` exist. `ℤ` has these via Mathlib.

## Recommended Approach

**The easiest implementation path** avoids constructing a new TaskFrame entirely:

1. **Close `finite_structures_good`**: This requires showing every finite ordered structure is k-equivalent to some interpretation on ℤ. Strategy: embed the finite structure into ℤ preserving order, extend predicates arbitrarily outside, show depth-k FO sentences only depend on the bounded portion (using a quantifier depth argument or EF games).

2. **Close `contemp_equiv_is_equiv.trans`**: Use sum_preservation to combine [a,b] and [b,c] very-good certificates into [a,c] very-good.

3. **Close `no_gaps_discrete`**: By contradiction using `no_boundary_at_successor` + transitivity — this may actually be provable ONCE transitivity is closed (the one_class proof already does a similar argument).

4. **Close `very_good_implies_good`**: Decompose into subintervals, apply sum_preservation.

5. **Close `chronicle_is_good`**: Via one_class + very_good_implies_good.

6. **For Step 6 (the bridge)**: Rather than building a new TaskFrame, prove that k-equivalence between the chronicle and a Z-interval implies `temporal_truth` agreement, then use the EXISTING `dd_countermodel_chronicle_discrete` construction but replacing `succ_cofinal`-dependent sorries with Reynolds-pipeline-based proofs.

**ALTERNATIVELY** (most direct): The fallback already delegates to `dd_countermodel_chronicle_discrete`. If that construction's only sorry is through `succ_cofinal` → `limitDomSubtype_isSuccArchimedean`, and the Reynolds pipeline can provide the same conclusion (that the FMCS on ℤ is valid), then we can either:
- Replace `succ_cofinal` with a proof that uses the Reynolds one_class theorem directly
- Or show the FMCS derived from the Z-model is sorry-free

## Evidence/Examples

Key file locations:
- `IntegerModel.lean:90` — `finite_structures_good` sorry
- `IntegerModel.lean:128` — `contemp_equiv_is_equiv.trans` sorry
- `IntegerModel.lean:145` — `no_gaps_discrete` sorry
- `IntegerModel.lean:202` — `very_good_implies_good` sorry
- `IntegerModel.lean:214` — `chronicle_is_good` sorry
- `OrderedSum.lean:56` — `doets_lemma_1_5` sorry (NOT on critical path)
- `Transfer.lean:138` — `atomMap_fwd` reference (doesn't exist yet)

## Summary of Critical Blockers

| # | Blocker | Difficulty | Dependency |
|---|---------|-----------|------------|
| 1 | `finite_structures_good` | MEDIUM-HARD | Independent (Doets Thm 1.1) |
| 2 | `contemp_equiv_is_equiv.trans` | MEDIUM | Uses sum_preservation (now available) |
| 3 | `no_gaps_discrete` | MEDIUM | Uses transitivity (blocker 2) |
| 4 | `very_good_implies_good` | MEDIUM | Uses sum_preservation (now available) |
| 5 | `chronicle_is_good` | EASY | Uses one_class + blocker 4 |
| 6 | TaskFrame bridge (Step 6) | HARD | Novel construction needed |
| 7 | `atomMap_fwd` construction | EASY | Straightforward |

**Total estimated remaining work**: 5 non-trivial lemmas + 1 substantial bridge construction. This is more than "just Step 6" — it's a full proof chain.
