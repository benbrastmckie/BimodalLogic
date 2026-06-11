# Report 09: Negation Closure Blocker Research

**Task**: 273 | **Date**: 2026-06-11 | **Session**: sess_1781193902_83bc5c
**Blocker**: Single sorry in `nf_characterizable_temporal_prior` k>=1 case (KampPrior.lean:149)

## Root Cause

The sorry is NOT an incidental gap — it is the core difficulty of Kamp's theorem,
relocated by the Phase 1 architecture deviation.

A `NormalForm sig (k+1) 1` is a pair: an atom assignment on 1 variable PLUS a Boolean
for each `NormalForm sig k 2` recording whether `∃ x, nf_eval_nf M k 2 (Fin.cons x env) sub_nf`
holds (NormalForm.lean:134-136, 198-207). To characterize a depth-(k+1) arity-1 NF
temporally, one must express each of these **2-variable existence statements** (and their
negations) as temporal formulas evaluated at `t`.

The induction on `k` at fixed arity 1 (the architecture chosen in the deviation) provides
an IH about **arity-1** depth-k NFs only. But the quantifier step needs characterizations
of **arity-2** depth-k NFs, which recursively contain arity-3 depth-(k-1) NFs, and so on —
Doets normal forms trade depth for arity. The IH is structurally too weak, and no
within-architecture strengthening works at bounded arity: characterizing
"∃x with a given multi-variable NF relative to existing points" is exactly the
generalized existential transfer (GHR93 Proposition 7) that blocked plans v12–v16.

Conclusion: the NF-enumeration shortcut postponed, but did not avoid, the Rabinovich
pipeline. The k>=1 case requires the full FO-to-temporal theorem.

## Existing Infrastructure

Sorry-free and directly reusable:

| Component | Location | Status |
|-----------|----------|--------|
| `NormalForm`, `nf_eval_nf`, `nf_characteristic`, `nf_exists_unique`, `doets_lemma_1_1` | NormalForm.lean | sorry-free |
| `nf_to_formula : NormalForm sig k n → MonadicFormula sig n`, `nf_to_formula_correct` | NormalForm.lean:705-722 | sorry-free — **the key bridge** |
| `formula_conjList/disjList` + iff lemmas, `nf_depth0_char_formula` + correctness | Separation/KampTranslation.lean | sorry-free |
| `semantic_prior_UZ/SZ` (attained first/last occurrences) | PriorDefs.lean | definitions |
| k=0 case, `kamp_prior_expressive_completeness` modulo the one sorry | Kamp/KampPrior.lean | sorry-free |

Partially present (Phase 1 scaffolding):

| Component | Location | Status |
|-----------|----------|--------|
| `TemporalPred`, `IntervalPattern`, `IntervalPattern.holds`, `VEF`, `VEF.disj_holds` | Kamp/ExistsForallNF.lean | defined + disj proved |
| `translateEF1`, `buildRight`, `buildLeft` | Kamp/ExistsForallNF.lean:213-258 | **defined, NO correctness proof** |
| `VEF.closed_conj` (Lemma 3.2.1), `VEF.closed_ex` (Lemma 3.4) | claimed in file header | **NOT present in file body** |

## Recommended Path

Prove the direct Rabinovich Theorem 4.4 relativized to Prior structures:

```lean
noncomputable def rabinovich_fo_to_temporal_prior
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔ eval M (fun _ => t) psi }
```

Then the sorry fills in ~10 lines via the `nf_to_formula` bridge:

```lean
| succ k _ih =>
    obtain ⟨A, hA⟩ := rabinovich_fo_to_temporal_prior atomMap h_surj (nf_to_formula nf)
    exact ⟨A, fun M hUZ hSZ t =>
      (hA M hUZ hSZ t).trans (nf_to_formula_correct M (fun _ => t) nf)⟩
```

No rewiring of `kamp_prior_expressive_completeness` or downstream consumers is needed;
the NF enumeration becomes a thin wrapper (harmless redundancy).

### Considered and rejected

1. **Small-k instances only**: `GoodStructuresModelSurgery.lean` calls
   `US_expressively_complete_over_prior` with arbitrary constructed formulas
   (φ, Ψ, Ψ', right_gap_class_formula) — quantifier depths are not bounded.
2. **Strengthened IH (simultaneous arity-n induction)**: equals GHR93 Prop 7
   n-variable existential transfer; this is the documented wall from plans v12–v16.
3. **Direct 2-var special-casing**: 2-var depth-k NFs contain 3-var depth-(k-1)
   NFs; the regress only terminates through interval-decomposition normal forms.

## Phased Decomposition

The plan v17 phases 2–5 were skipped by the deviation but are exactly what is needed.
Restore them with these refinements:

| Phase | Content | New file | Est. lines | Risk |
|-------|---------|----------|-----------|------|
| A (=v17 Ph2) | `translateEF1_correct` (Prop 3.5): Until/Since chain semantics for `buildRight`/`buildLeft`, by induction on the pair list | Kamp/Translation.lean | 400–600 | Medium: list-index bookkeeping |
| B (=v17 Ph3) | Prior INF lemmas: first-occurrence (from `semantic_prior_UZ`) and last-occurrence (from `semantic_prior_SZ`) for TL-definable predicates; no K+ disjunct needed (attainment) | Kamp/PriorINF.lean | 200–300 | Low |
| C1 (=v17 Ph4 part) | `VEF.closed_conj` (Lemma 3.2.1, witness-sequence merge) and `VEF.closed_ex` (Lemma 3.4) — claimed in ExistsForallNF.lean header but missing | Kamp/ExistsForallNF.lean | 300–500 | Medium: witness interleaving case analysis |
| C2 (=v17 Ph4 core) | Negation closure: Lemma 5.3 (induction on predicate count, via Prior INF), Cor 5.4, Lemma 5.1 (induction on segments, 3 cases per Rabinovich pp. 9–11) | Kamp/NegationClosure.lean | 600–1000 | **High: the critical phase** |
| D (=v17 Ph5) | Prop 4.3 relativized (structural induction on `MonadicFormula`: atomic/or/not/ex) + Theorem 4.4 + fill the sorry via `nf_to_formula` bridge | Kamp/KampPrior.lean | 400–600 | Medium |

Dependency order: A, B independent; C1 after A; C2 after B, C1; D after C2.

## Effort Estimate

Total: **1900–3000 lines** (the handoff's 1000–2000 was optimistic; it omitted the
missing VEF closure lemmas and translation correctness).

**Does NOT fit a single implementation dispatch.** Recommend: revise plan (v18)
restoring phases 2–5 with the decomposition above and the ~10-line sorry-fill as a
final phase; execute with one dispatch per phase (C2 may need two).
