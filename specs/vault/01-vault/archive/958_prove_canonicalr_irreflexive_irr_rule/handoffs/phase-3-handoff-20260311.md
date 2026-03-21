# Phase 3 Handoff: Extended MCS and Naming Set Consistency

## Immediate Next Action

Resolve the mathematical gap in the conservative extension proof strategy before implementing Phase 3-5 code. The gap is in the **final contradiction step** of the irreflexivity proof.

## Current State

### Completed (builds, zero sorries)
- **Phase 1**: `Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean` -- ExtAtom, ExtFormula, embedFormula, fresh_not_in_embedFormula_atoms, embedAtom_mem_embedFormula_atoms_iff, embedFormula_injective
- **Phase 2**: `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` -- ExtAxiom, ExtDerivationTree (with IRR taking ExtAtom), embedAxiom, embedDerivation

### Blocked: Phase 3-5

The conservative extension infrastructure (Phases 1-2) is complete and correct. The block is on Phases 3-5 which require proving the irreflexivity theorem using this infrastructure.

## The Mathematical Gap

### The Standard Proof (Goldblatt/BdRV)
1. Assume CanonicalR(M, M), i.e., GContent(M) ⊆ M.
2. Pick p globally fresh for M (so atoms(M) ∩ {p} = empty).
3. Naming set N = M ∪ {atom(p), H(neg(p))} is consistent.
4. Extend N to MCS M'. So M ⊆ M'.
5. GContent(M) ⊆ M ⊆ M'. So CanonicalR(M, M').
6. neg(atom(p)) ∈ M (freshness + negation completeness).
7. neg(atom(p)) ∈ M ⊆ M'. atom(p) ∈ M' (naming set). CONTRADICTION.

### Why It Fails in F (With String Atoms)
- Step 2 is impossible: atoms(M) = String for every MCS M.
- atomFreeSubset(M, p) ⊊ M for every p.
- Steps 5 and 7 fail (M ⊄ M').

### Conservative Extension (F+ with ExtAtom = String + Unit, q = Sum.inr ())
- Step 2 replacement: q is "globally fresh" for embed '' M (since q ∉ (embedFormula phi).atoms for ALL phi).
- Naming set: embed '' M ∪ {atom(q), H(neg(q))}.
- embed '' M ⊆ M'_ext (all of M is q-free, so atomFreeSubset = embed '' M). FIXES step 5.
- **PROBLEM AT STEP 7**: neg(atom(q)) ∉ embed '' M. So we cannot get neg(atom(q)) ∈ M'_ext via inclusion. The original proof gets neg(atom(p)) ∈ M' because M ⊆ M', but neg(q) is not in embed '' M because q = Sum.inr () is never in the range of embedAtom = Sum.inl.

### Approaches Tried to Resolve the Gap

1. **GContent/HContent duality**: Requires full F+-MCS infrastructure (deduction theorem, negation completeness, MCS closure, Lindenbaum for ExtFormula). Even with this infrastructure, the duality gives neg(q) ∈ M_ext (a DIFFERENT MCS), not neg(q) ∈ M'_ext. Getting the contradiction requires both atom(q) and neg(q) in the SAME MCS.

2. **Construct M_ext with G(neg(q))**: Define seed S = embed '' M ∪ {neg(q), G(neg(q))}. Show S is F+-consistent. Extend to M_ext. Then G(neg(q)) ∈ M_ext → neg(q) ∈ GContent_Ext(M_ext). For CanonicalR_Ext(M_ext, M'_ext), need GContent_Ext(M_ext) ⊆ M'_ext. This requires neg(q) ∈ M'_ext -- circular.

3. **Add neg(q) to naming set**: N = embed '' M ∪ {atom(q), H(neg(q)), neg(q)} is INCONSISTENT ({atom(q), neg(q)} derives bot).

4. **Direct proof-theoretic argument**: Tried various routes using seriality, density, temp_a, temp_4 to derive contradiction from GContent(M) ⊆ M without the naming argument. No clean contradiction found.

5. **Full F+ standalone irreflexivity**: The same atomFreeSubset problem applies to F+-MCSs that contain q-mentioning formulas. The naming argument only works for MCSs where the naming atom is globally fresh.

## Key Decisions Made

1. The conservative extension infrastructure (ExtFormula, ExtDerivation) is correct and useful.
2. The embedDerivation function correctly handles the IRR case (using embedAtom_mem_embedFormula_atoms_iff).
3. The first sorry (GContent ⊆ M' at line 1245) IS fixed by the conservative extension.
4. The second sorry (final contradiction at line 1328) requires a mathematical insight not yet identified.

## What NOT to Try

- Adding neg(q) to the naming set (inconsistent)
- Full F+ standalone irreflexivity without controlling q-mentioning formulas
- Trying to prove CanonicalR_Ext(M_ext, M'_ext) for arbitrary Lindenbaum extensions (uncontrollable q-mentioning G-formulas)

## Critical Context

1. The block is MATHEMATICAL, not implementational. The F+-MCS infrastructure could be built but the final contradiction step needs a different approach.
2. Possible resolution: a substitution-based argument where the contradiction is derived in the proof system (not at the set/model level).
3. Alternative: the semantic soundness meta-argument mentioned in research-005.md Appendix as a fallback.
4. The existing CanonicalIrreflexivity.lean has the naming set consistency proof working -- only the main theorem has sorries.
5. All new code is in ConservativeExtension/ -- no existing files modified.

## References

- Plan: specs/958_prove_canonicalr_irreflexive_irr_rule/plans/implementation-002.md
- Research: specs/958_prove_canonicalr_irreflexive_irr_rule/reports/research-005.md (Parts 5-8 detail the mathematical difficulty)
- Existing partial proof: Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean (lines 1245, 1328)
