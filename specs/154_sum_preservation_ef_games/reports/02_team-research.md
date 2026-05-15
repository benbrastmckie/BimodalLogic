# Team Research Report: Task #154

**Task**: sum_preservation via Ehrenfeucht-Fraisse games (Doets Lemma 1.4)
**Date**: 2026-05-15
**Mode**: Team Research (4 teammates)
**Session**: sess_1778879761_8fd87d_t154

## Summary

All four teammates converge on normal form induction as the correct proof strategy — EF games have no Mathlib infrastructure and would cost 450-700 lines of new code, while normal form induction uses the existing `NormalForm.lean` infrastructure (nf_eval_nf, nf_exists_unique, nf_characteristic, nf_agreement_from_shared_nf) for an estimated 250-400 lines. The `carrier_order := sorry` embedded in the type signature is a genuine structural blocker that requires interface refactoring (defining `orderedSum` with Mathlib's `Sigma.Lex.linearOrder`) before any proof work can begin — the fix itself is trivial but must be Phase 1 with build verification.

The Critic (Teammate C) raises an important scope correction: the task description claims downstream sorries (`no_gaps_discrete`, `contemp_equiv_is_equiv` transitivity, `finite_structures_good`) are closable here, but they are NOT direct consequences of sum_preservation. `finite_structures_good` requires Doets Theorem 1.1 (k-type realizability by Z-intervals), which is a separate theorem that uses sum_preservation as a prerequisite but needs additional constructive content. `no_gaps_discrete` requires a separate well-founded induction argument not analyzed in any report. Task 154 should be scoped to three deliverables: (1) carrier_order refactoring, (2) sum_preservation proof, (3) doets_lemma_1_4 as corollary.

Strategically (Teammate D), the Reynolds pipeline is the right long-term primary path — it aligns with the canonical Reynolds 1994 literature, enables the dense case via doets_lemma_1_5, and produces cleaner module architecture. However, task 153 (succ_cofinal, 4-8h) remains the faster route to sorry-free `bx_completeness` if speed is paramount.

## Key Findings

### Primary Approach (from Teammate A)

Teammate A provides a detailed proof sketch for normal form induction. The proof structure mirrors `nf_agreement_monotone` (NormalForm.lean:339-421):

1. **carrier_order**: Trivially closable via `Sigma.Lex.linearOrder` from `Mathlib.Data.Sigma.Order`. Define `orderedSum` as a named `OrderedMonadicStructure` with the lexicographic order.

2. **Base case (k=0)**: Vacuous — `AtomKind sig 0` is uninhabited (no predicates or order atoms with `Fin 0` variable indices). Both sums satisfy the unique empty truth assignment trivially.

3. **Inductive step (k→k+1)**: For each realized sub_nf with 1 free variable, find a corresponding witness in the other sum using component k-equivalence. The atom part decomposes: predicate atoms evaluate per-component, order atoms compare by index (cross-component) or within-component order. The quantifier part uses `nf_exists_unique` to find characteristic-matching witnesses.

4. **Key gap identified**: Sentence-level k_equiv (0 free variables) does not directly give transfer of NF formulas with free variables. The bridge requires maintaining "compatible environments" — pairs of environments with matching component indices and matching within-component NF characteristics.

**Estimated effort**: 135-275 lines.

### Alternative Approaches (from Teammate B)

- **EF games (Approach A)**: No Mathlib infrastructure exists. `Order.PartialIso` handles pure orders only; `ModelTheory.PartialEquiv` is for full FO, not bounded-depth k-equivalence. Cost: 450-700 lines from scratch with no reuse potential.
- **Direct k-type computation (Approach C)**: Circular — computing `k_type_of (Σ M_i)` must unfold `nf_eval_nf`, which is defined by induction on k, reducing to the same argument.
- **Circumventing sum_preservation**: The chronicle fallback already provides discrete completeness. `sum_preservation` is not on the *current* critical path — it's needed to *activate* the Reynolds pipeline as the primary path.
- **Nothing currently calls `KEquivalenceFramework.sum_preservation`**: All downstream theorems are themselves sorry. Proving sum_preservation makes them in-principle closable but they need separate proof work.

### Gaps and Shortcomings (from Critic, Teammate C)

1. **Proof complexity underestimated**: The "compatible environments" framework requires tracking multi-element, multi-component relational invariants. At n≥2 free variables, same-component order atoms need the PAIR of elements to have matching depth-(k-1) NF — genuinely recursive and harder than described. Revised estimate: **250-400 lines**.

2. **carrier_order sorry is in the TYPE, not just the proof body**: The `carrier_order := sorry` makes `atom_eval` use a sorry'd linear order. Any proof against the current signature is semantically unsound. Refactoring to `orderedSum` with proper Lex order must be Phase 1, build-verified before proof work.

3. **Downstream sorries do NOT auto-close**:
   | Sorry | Closable by sum_preservation? | Actually needs |
   |-------|-------------------------------|----------------|
   | `finite_structures_good` | NO | Doets Theorem 1.1 (separate) |
   | `contemp_equiv_is_equiv` trans. | PARTIALLY | sum_preservation + finite_structures_good |
   | `no_gaps_discrete` | NO | Well-founded induction (unanalyzed) |
   | `very_good_implies_good` | PARTIALLY | sum_preservation + Doets Thm 1.1 + Reynolds Lemma 16 |
   | `chronicle_is_good` | NO | Needs very_good_implies_good |

4. **`finite_structures_good` IS dependent on sum_preservation** (contra Report 01 which says independent): Doets Theorem 1.1 uses induction on structure size with sum_preservation to combine smaller pieces. But it requires additional constructive content beyond sum_preservation alone.

5. **Fin.cons bookkeeping**: De Bruijn environment extension creates type mismatches between sum-level environments (`Fin (n+1) → Σ i, (ms i).carrier`) and component-level environments (`Fin (n+1) → (ms i).carrier`). Transport lemmas and dependent coercions add 30-60 additional lines.

### Strategic Horizons (from Teammate D)

- **Reynolds pipeline is the right long-term primary**: Aligns with Reynolds 1994 literature, enables dense case (doets_lemma_1_5), produces cleaner module architecture.
- **Both paths have comparable publication value**: The main publishable result is sorry-free `bx_completeness`, not the specific pipeline. Either path reaches it.
- **Designate Reynolds as primary once both exist**: Archive chronicle discrete path to Boneyard (per task 130 plan). Transfer.lean already designed for this swap.
- **Task 153 is faster (4-8h)** if publication timing matters. Task 154-155 is higher quality (20-30h total including downstream).
- **Infrastructure enables dense case**: `doets_lemma_1_5` builds directly on sum_preservation. The dense completeness path (task 18, now abandoned) could be revisited via the Doets-Reynolds framework.
- **Potential Mathlib contribution**: MonadicFO + NormalForm + k-equivalence infrastructure could be extracted as a Mathlib PR for formalized model theory.

## Synthesis

### Conflicts Resolved

1. **Effort estimate (A: 135-275 vs C: 250-400)**: Resolved in favor of C's higher estimate. Teammate A's estimate does not account for the multi-element same-component order atom case at n≥2 variables, nor the Fin.cons transport bureaucracy. **Adopted estimate: 250-400 lines** for the sum_preservation proof body, plus 20-30 lines for carrier_order infrastructure.

2. **carrier_order: trivial vs blocker**: Both are correct at different levels. The mathematical fix (using `Sigma.Lex.linearOrder`) is trivial (10-20 lines). But the *structural* fix (refactoring the typeclass field signature) must happen first and requires build verification. **Resolution**: Phase 1 is carrier_order refactoring + build verification; Phase 2 is the proof.

3. **Scope of downstream sorries**: Report 01 implied these are closable here. Critic correctly identifies they are NOT. **Resolution**: Narrow task 154 scope to three deliverables only.

### Gaps Identified

1. **No formal definition of "compatible environments"**: All reports describe the concept informally but none provides a concrete Lean `Prop` definition. The implementer must formalize this during Phase 2.

2. **`no_gaps_discrete` unanalyzed**: No report provides a proof strategy for this downstream sorry. Requires separate research.

3. **`finite_structures_good` proof strategy unclear**: Requires Doets Theorem 1.1 (every finite structure's k-type realized by Z-interval). This is an inductive construction on structure size using sum_preservation — substantial additional work not scoped here.

4. **Infinite index set handling**: The proof must work for arbitrary `I`, not just finite. For any fixed `n`, the n free variables touch at most n components, so this should be manageable but needs verification.

### Recommendations

**Task 154 Scope (narrowed)**:
1. **Phase 1**: Define `orderedSum` with proper `Sigma.Lex.linearOrder`. Refactor `KEquivalenceFramework.sum_preservation` field signature and `doets_lemma_1_4`/`doets_lemma_1_5` in OrderedSum.lean. Build verification.
2. **Phase 2**: Prove `sum_preservation` via normal form induction with compatible environments.
3. **Phase 3**: Close `doets_lemma_1_4` as corollary of the instance field.

**Out of scope** (separate follow-up tasks):
- `finite_structures_good` (Doets Theorem 1.1)
- `contemp_equiv_is_equiv` transitivity
- `no_gaps_discrete`
- `very_good_implies_good` (Reynolds Lemma 16)
- `chronicle_is_good`

**Estimated effort**: 8-12 hours (280-430 lines total).

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: NF induction proof sketch | completed | high |
| B | Alternatives: EF games, circumvention, Mathlib | completed | high |
| C | Critic: scope, complexity, carrier_order blocker | completed | high |
| D | Horizons: strategic alignment, publication value | completed | high |

## References

- Doets 1987: "Completeness and Definability" thesis, Chapter 1 (Sections 1.6-1.7: normal forms, k-types, Lemma 1.4)
- Doets 1989: "Monadic Π₁¹-Theories" Lemma 1.4 (sum preservation)
- Reynolds 1994: "Axiomatising U and S over integer time" Sections 4-6 (Reynolds pipeline, Lemma 16, Theorem 15)
- Mathlib: `Sigma.Lex.linearOrder` in `Mathlib.Data.Sigma.Order`
- Codebase: `NormalForm.lean` (nf_eval_nf, nf_exists_unique, nf_characteristic, nf_agreement_monotone, nf_agreement_from_shared_nf)
