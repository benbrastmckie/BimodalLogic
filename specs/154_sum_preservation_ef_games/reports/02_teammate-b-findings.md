# Research Report: Alternative Approaches to sum_preservation (Teammate B)

**Task**: 154
**Date**: 2026-05-15
**Teammate**: B — Alternative Approaches
**Session**: sess_1747338900_d4e5f6

---

## Key Findings

### Finding 1: EF Game Infrastructure Does Not Exist in Mathlib (for This Purpose)

Mathlib's `ModelTheory` namespace (`FirstOrder.Language.*`) provides:
- `PartialEquiv` — partial equivalences between structures
- `ElementarilyEquivalent` — equality of complete theories
- `IsFraisse` / `IsFraisseLimit` — Fraisse class infrastructure

None of these provide an **Ehrenfeucht-Fraisse game** in the form required here. Specifically:

- There is no `EFGame`, `EFPosition`, or `WinningStrategy` type in Mathlib.
- `Order.PartialIso` exists (`Mathlib.Order.CountableDenseLinearOrder`) and provides finite partial order isomorphisms, but it only handles pure order structures (no unary predicates).
- Mathlib's `ModelTheory.PartialEquiv` is for full first-order languages, not bounded-quantifier-depth k-equivalence.
- The Fraisse infrastructure (`isFraisse_finite_linear_order`) is for isomorphism-type results, not k-equivalence composition.

**Conclusion**: Formalizing EF games would require building the entire game-theoretic infrastructure from scratch: game positions (partial isomorphisms extended to unary predicates), round-bounded strategies, the fundamental theorem connecting winning strategies to k-equivalence, and the composition lemma. No Mathlib shortcut exists.

### Finding 2: `Sigma.Lex.linearOrder` Closes the carrier_order Sorry

Mathlib provides `Sigma.Lex.linearOrder` in `Mathlib.Data.Sigma.Lex`:

```lean
instance Sigma.Lex.linearOrder [LinearOrder ι] [∀ i, LinearOrder (α i)] :
    LinearOrder (Σₗ i, α i)
```

where `Σₗ` is `Lex (Sigma alpha)`, a type synonym for the same underlying type. The lexicographic ordered sum needed in `sum_preservation` is exactly this instance. The `carrier_order := sorry` in both `NEquivalence.lean:141-144` and `OrderedSum.lean:41-44, 66-69` can be closed by:

```lean
carrier_order := inferInstanceAs (LinearOrder (Lex (Sigma fun i => (ms i).carrier)))
```

This is definitionally sound because the carrier type in both cases is `Sigma fun i => (ms i).carrier`, and `Lex` is a type alias (not a newtype) in Lean 4, so the linear order instance transfers directly.

**Cost**: 10-20 lines. Trivially closable. No new definitions required.

### Finding 3: Direct k-type Computation Is Circular

The idea of computing `k_type_of sig k (Σ M_i)` directly from `{k_type_of sig k (M_i)}` without induction on formulas is not simpler than normal form induction. Reason:

The k-type is defined as `fun nf => decide (nf_eval_nf (Σ M_i) k 0 Fin.elim0 nf)`. Any computation of this value must eventually unfold `nf_eval_nf`, which is defined by induction on `k`. There is no "algebra of k-types" that avoids this — the k-type of a sum IS defined by the k-types of components (by Lemma 1.4), but proving that equality requires exactly the inductive argument. Computing it differently would not avoid the work; it would just rename it.

**Conclusion**: Approach C is not a real alternative. It is equivalent to Approach B in disguise.

### Finding 4: The Pipeline Does Not Call sum_preservation Directly

`KEquivalenceFramework.sum_preservation` is a field of the typeclass declared in `NEquivalence.lean:135-144`. Searching the entire codebase:

- `NEquivalence.lean`: declares the field and provides the (sorried) instance
- `OrderedSum.lean`: `doets_lemma_1_4` is marked as depending on it (in comments), but the actual proof body is also `sorry` — it does not call the instance field
- `IntegerModel.lean`: references `sum_preservation` only in **comments** (lines 19, 89, 107, 124, 197, 209); the downstream sorried theorems (`finite_structures_good`, `contemp_equiv_is_equiv` transitivity, `very_good_implies_good`, `chronicle_is_good`) do not call the field
- `Transfer.lean`: references sum_preservation only in a comment (line 104)
- No other Lean file calls `KEquivalenceFramework.sum_preservation`

This is important: `sum_preservation` is **not yet wired into the downstream proofs**. Those proofs are all `sorry`. Proving `sum_preservation` would make those sorries in principle closable, but they would still need separate proof work.

### Finding 5: The Downstream Sorry Chain Has Three Distinct Obligations

Once `sum_preservation` is proved, the downstream path requires three separate proof efforts:

1. **`finite_structures_good`** (IntegerModel.lean:84): Requires Doets Theorem 1.1 — every finite ordered monadic structure's k-type is realized by some Z-interval structure. This is independent of `sum_preservation` (comment says it depends on sum_preservation, but reading carefully: the actual dependency is on "k-type realizability", which is a separate theorem). Finite structures are already good by `reflexivity of k_equiv`, but that vacuous proof was archived (see Boneyard comment at OrderedSum.lean:72). The genuine proof needs non-trivial new content.

2. **`contemp_equiv_is_equiv` transitivity** (IntegerModel.lean:125): Requires showing that if [a,b] and [b,c] are very good, then [a,c] is very good. The key step is: a subinterval [x,y] ⊆ [a,c] can be split at b if needed. If [x,y] ⊆ [a,b] or [x,y] ⊆ [b,c], it's directly very good. If x < b < y, then [x,y] = [x,b] + {b} + [b,y], all sub-intervals of good structures, and sum_preservation would close the gap. **This is the most direct use of sum_preservation in the downstream chain.**

3. **`very_good_implies_good`** (IntegerModel.lean:199): Requires Reynolds Lemma 16, which uses sum_preservation to construct a Z-interval equivalent of a very good structure. This is a substantial separate proof.

### Finding 6: Circumventing sum_preservation via the chronicle Fallback

The `Transfer.lean` file reveals the current state of the pipeline: `doets_countermodel_discrete` falls back to `dd_countermodel_chronicle_discrete` (the working chronicle construction). The comment in `Transfer.lean:104` lists the steps, and the **chronicle fallback already provides the working countermodel**.

The Reynolds pipeline (step 3: `chronicle_is_good` → `sum_preservation`) is needed only to activate the Z-model countermodel. But the **discrete completeness theorem already works** via the chronicle fallback. This means:

- `sum_preservation` is not on the critical path for discrete completeness
- Proving it would enable replacing the chronicle fallback with a Z-model countermodel (a cleaner mathematical statement), but does not change what the theorem proves
- The only use of `KEquivalenceFramework.sum_preservation` visible in the codebase is as a field declaration — nothing currently calls it in a proof

### Finding 7: Refactoring KEquivalenceFramework Is Low-Risk

The `KEquivalenceFramework` typeclass currently has `carrier_order := sorry` embedded in the **type signature** of `sum_preservation` (lines 141-144). This means the field's output type references a sorry. Any proof of this field must either:

(a) Work with a sorry-typed carrier order (not possible for correctness), or  
(b) Require a refactoring of the field signature to use a properly-defined ordered sum

The refactoring needed is: replace the inline structure expressions with an `orderedSum` definition that uses the lexicographic order. This change would be confined to `NEquivalence.lean` and `OrderedSum.lean`, with no impact on downstream files (since nothing currently calls the field in a proof).

---

## Recommended Approach

**Primary Recommendation: Normal Form Induction (Approach B from Report 01)**

This teammate's investigation confirms Report 01's analysis. The alternatives are:

| Approach | Feasibility | Cost | Risk |
|----------|-------------|------|------|
| A: EF Game formalization | Feasible (no Mathlib blocker) | 500-800 lines | High — entirely new infrastructure |
| B: Normal form induction | Feasible, uses existing infra | 200-350 lines | Moderate — complex env management |
| C: Direct k-type algebra | Not a real alternative | Same as B | N/A |
| D: Circumvent (pipeline bypass) | Already done via fallback | 0 lines | N/A for completeness |
| E: Remove from typeclass | Feasible | 50 lines refactoring | Low — but defers the proof |

**If the goal is to close the sorry with a genuine proof**: Use normal form induction (B). The existing `nf_eval_nf`, `nf_exists_unique`, `nf_characteristic`, and `nf_agreement_monotone` provide all the machinery needed. The carrier_order sorry is trivially closed via `Sigma.Lex.linearOrder`.

**If the goal is to unblock downstream proofs for discrete completeness**: No action on `sum_preservation` is needed. The chronicle fallback already makes `doets_countermodel_discrete` work. The only downstream sorry that genuinely needs `sum_preservation` in its proof body (not just comments) is `contemp_equiv_is_equiv` transitivity.

**If the goal is the cleanest architecture**: Refactor `KEquivalenceFramework.sum_preservation` to use `orderedSum` with a proper order, then prove it via normal form induction.

---

## Evidence and Examples

### EF Game Infrastructure Cost Estimate

The Doets 1.4 proof in the literature says: "It is straightforward to describe a winning strategy for the second player in the Ehrenfeucht n-game between these sums under the condition given." This is deceptively terse. A full Lean formalization would require:

```lean
-- Round 1: Define game positions
structure EFPosition (sig : MonadicSignature) (M N : OrderedMonadicStructure sig) where
  pairs : List (M.carrier × N.carrier)

-- Round 2: Define admissible positions (partial isomorphisms)
def isAdmissible {sig : MonadicSignature} {M N : OrderedMonadicStructure sig}
    (pos : EFPosition sig M N) : Prop :=
  ∀ (p q : M.carrier × N.carrier), p ∈ pos.pairs → q ∈ pos.pairs →
    -- 5+ conditions: predicate agreement, order preservation, etc.
    ...

-- Round 3: Define winning strategy for Duplicator
def hasWinningStrategy (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) : Prop :=
  ∀ (pos : EFPosition sig M N), isAdmissible pos →
    ∀ (moveM : M.carrier) (moveN : N.carrier),
      ∃ (response : ...), isAdmissible (extend pos response)

-- Round 4: Fundamental theorem (both directions)
theorem ef_game_iff_k_equiv (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) :
    k_equiv sig k M N ↔ hasWinningStrategy sig k M N
-- This alone is ~150-200 lines

-- Round 5: Composition lemma
theorem ef_game_composition ...
-- ~100 lines
```

Estimated total: 450-700 lines, all new with no reuse potential in the current codebase.

### Sigma.Lex Usage Pattern

From Mathlib (`Mathlib.Data.Sigma.Lex`), the linearOrder instance:
```
Sigma.Lex.linearOrder : [LinearOrder ι] → [∀ i, LinearOrder (α i)] → LinearOrder (Σₗ i, α i)
```
where `Σₗ i, α i` is notation for `Lex (Sigma (fun i => α i))`, and `Lex α = α` by definition.

The carrier type `Sigma fun i => (ms i).carrier` is the same as `(Σₗ i, (ms i).carrier)` as sets, so:
```lean
noncomputable instance orderedSumLinearOrder {I : Type} [LinearOrder I]
    {sig : MonadicSignature} (ms : I → OrderedMonadicStructure sig) :
    LinearOrder (Sigma fun i => (ms i).carrier) :=
  inferInstanceAs (LinearOrder (Lex (Sigma fun i => (ms i).carrier)))
```
This compiles with no other infrastructure needed.

### Actual Dependency Graph for contemp_equiv_is_equiv Transitivity

The transitivity sorry (IntegerModel.lean:125-128):
```lean
trans {a b c} hab hbc := by
  simp only [contemp_equiv, very_good] at *
  intro x y hxy
  sorry
```

The goal at `sorry` is: given `hab : ∀ x y, x ≤ y → good sig k (M.subinterval sig (min a b) (max a b)).subinterval ...` and `hbc` similarly, prove that `good sig k (M.subinterval sig (min a c) (max a c)).subinterval sig x y`.

This requires: any subinterval of `[a,c]` is good. The proof splits into:
1. If the subinterval lies within `[a,b]`: directly from `hab`
2. If the subinterval lies within `[b,c]`: directly from `hbc`
3. If the subinterval spans `b`: write it as sum of a `[a,b]`-subinterval and a `[b,c]`-subinterval, both good, hence the sum is good by `sum_preservation`. This is the critical step.

So `sum_preservation` IS genuinely needed for transitivity. But note: transitivity of `contemp_equiv` is itself used in `one_class` (line 185-188), which is the cornerstone of the discrete completeness argument. However, `one_class` is currently proved using `contemp_equiv_is_equiv`, which is not yet proved (its transitivity case is sorry). This means the `one_class` theorem as written depends on a sorry chain. But `doets_countermodel_discrete` bypasses this entire chain via the chronicle fallback.

---

## Confidence Level

**High confidence** on:
- No EF game infrastructure in Mathlib applicable to this problem
- `Sigma.Lex.linearOrder` closes carrier_order trivially
- Normal form induction (Approach B) is the correct mechanization strategy
- The current critical path for discrete completeness does NOT require `sum_preservation`
- The downstream sorry chain has three distinct obligations beyond `sum_preservation`

**Medium confidence** on:
- The estimated line count for Approach B (200-350) — could be shorter if the compatibility framework is implicit, or longer if Fin.cons bureaucracy is harder than expected
- The claim that no other Lean file calls `sum_preservation` — based on full grep; if there are files not yet imported/compiled, usage could be hidden

**Low confidence** on:
- Whether a Mathlib-bridging approach using `FirstOrder.Language` infrastructure could shortcut any of the EF game work — the language gap between Mathlib's general first-order framework and this project's monadic FO setup appears significant and would likely cost as much in translation as the direct proof

---

## Appendix: Search Summary

| Search Tool | Query | Result |
|-------------|-------|--------|
| `lean_leanfinder` | EF game back and forth partial isomorphism | `Order.PartialIso` exists but wrong domain |
| `lean_leanfinder` | Ordered sum lexicographic sigma | `Sigma.Lex.linearOrder` confirmed |
| `lean_leansearch` | Ehrenfeucht Fraisse game model equivalence | No EF game infrastructure found |
| `lean_leanfinder` | ElementarilyEquivalent ordered sum | No ordered-sum composition lemma found |
| `lean_local_search` | sum_preservation | Only in NEquivalence.lean (declaration) |
| `lean_local_search` | k_equiv | 3 results, all in NEquivalence.lean |
| Bash grep | KEquivalenceFramework across all .lean files | 12 matches, 0 are proof-body calls |
