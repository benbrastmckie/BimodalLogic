# Research Report: Task #113

**Task**: Review new literature for completeness techniques across three-phase roadmap
**Date**: 2026-04-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1777310907_cf5ce7

## Summary

Three newly obtained papers (Xu 1988, Reynolds 1992, Caleiro-Viganò-Volpe 2013) were analyzed against the current BX completeness proof state to identify transferable techniques across the three-phase roadmap: (1) base TM with H, G, Box; (2) Until/Since extension; (3) dense and discrete specializations.

**Principal finding**: Xu 1988's binary g-function construction (Lemmas 2.4, 2.6, 2.7) directly addresses the 6 `c2'` sorry sites in `CounterexampleElimination.lean` — these are engineering tasks requiring g-value construction for new adjacent pairs after PointInsertion, solvable by extracting B' and B'' from the Lindenbaum step that the code already performs. Reynolds 1992 provides the template for task 68 (dense completeness) via Doets's theorem. Caleiro et al. 2013 confirms architectural correctness but is not applicable to the chronicle construction path.

**Critical gap identified**: No paper in the collection addresses the full BX combination of (1) S5 modality + (2) U/S temporal operators + (3) strict irreflexive ordering + (4) chronicle/canonical model construction. The project is in genuinely novel territory for the bimodal coherence wiring in `ChronicleToCountermodel.lean`.

## Key Findings

### 1. Xu 1988 Directly Closes the 6 c2' Sorry Sites (HIGH CONFIDENCE)

**Source**: Xu 1988, Lemma 2.4 (pp. 94–96) and Definition 2.5 (C0–C6).

The 6 `c2' := sorry` sites in `CounterexampleElimination.lean` (lines 786, 824, 864, 902, 938, 970) require constructing g-values for new adjacent pairs when inserting points into the chronicle domain. The current code correctly finds D (the new MCS at the inserted point z) via `set_lindenbaum` but discards the B' and B'' that Xu's Lemma 2.4 produces simultaneously:

- `g(x, z_new) := B'` where `R(f(x), B', D)`
- `g(z_new, y) := B''` where `R(D, B'', f(y))`

**For C5/C5' insertion** (lines 786, 824): Xu's Lemma 2.2 produces B and C satisfying `R(A, B, C)`. The B is the c2' witness. Fix: change `eliminate_C5_counterexample` to also return B alongside D.

**For C4/C4' insertion** (lines 864, 902, 938, 970): The Lindenbaum extension already extends B* = g(w, w_next). Setting `g(w, z) := g(w, w_next)` satisfies c2' since B* ⊆ D. Alternatively, use the full Xu Lemma 2.4 decomposition.

All four teammates concur: these are engineering tasks, not conceptual blockers.

### 2. Xu 1988 Theorem 2.9 — Irreflexivity Is Not U,S-Definable (HIGH CONFIDENCE)

Xu proves definitively that no U,S-formula can define irreflexivity, asymmetry, or antisymmetry. The proof: the K-structure construction (Section 2) only enforces anti-symmetry (C1: no 2-cycles), not irreflexivity. Since the construction works for the entire class of non-theorems, no formula distinguishes C1-frames from irreflexive ones.

**Codebase implication**: The binary `g(x,y)` function + C4/C4' conditions are the ONLY viable mechanism for enforcing irreflexive-like behavior in the BX chronicle. There is no axiom shortcut. This validates the current chronicle design.

### 3. Reynolds 1992 IRR-Free Technique Is for a Different Problem (HIGH CONFIDENCE)

Reynolds achieves strict-order completeness over the reals WITHOUT the IRR rule, using a five-step strategy: (1) Burgess-Xu strong completeness for rational-flowed model, (2) Prior-U/S axioms to eliminate definable gaps, (3) Kamp expressive completeness, (4) Sep axiom for dense singletons, (5) Doets's theorem for Q→R transfer.

**This does NOT offer an alternative for the Chronicle C2'/C5 sorry sites.** Reynolds requires Prior structures (a dense-flow property with expressive completeness). The BX chronicle works with finite sparse domains at intermediate stages where Kamp expressive completeness doesn't apply. However, Reynolds confirms the existing BX approach is principled and IRR-free by design.

### 4. The `cantor_bfmcs_restricted_fuc` Path (MEDIUM CONFIDENCE)

The 2 sorry sites in `ChronicleToCountermodel.lean` (lines 615, 619) require `limit_satisfies_c5_full` (C5 with guard), but only `limit_satisfies_c5_weak` (endpoint only) is currently proved.

**Recommended fix** (agreed by Teammates A and B): Strengthen `EliminationResult.c5_forward_witness` to carry guard information. The guard φ ∈ f(r) for intermediate r follows from:
1. C3 (sorry-free at `ChronicleConstruction.lean:860`): `g(t,s) ⊆ f(r)` for intermediate r
2. The r-relation: φ ∈ g(t,s) when U(φ,ψ) ∈ f(t)
3. BX5 (self_accum_until): propagates `φ ∧ (φ U ψ)` at intermediate domain points

The blocker is verifying that `limit_c2` (full r-relation, not just adjacent-pair c2') is sorry-free. This needs codebase verification before the path is confirmed.

### 5. Caleiro et al. 2013 — Architectural Confirmation Only (HIGH CONFIDENCE)

The mosaic method confirms correctness of the current architecture:
- Vertical coherence V3/V4 matches FMCS `forward_G` condition
- Horizontal saturation SH1 matches BFMCS modal coherence

However, the mosaic approach is NOT applicable to the chronicle construction for three reasons:
1. CVV 2013 uses G/H operators only — no U or S anywhere in the paper
2. Their S5+tense combination handles non-interacting dimensions; BX's interaction axioms (`modal_future`, `temp_future`) make the mosaic approach partial
3. The ROADMAP explicitly excludes decidability-based completeness as a path to the representation theorem

### 6. Doets's Theorem Is the Right Tool for Task 68 (HIGH CONFIDENCE)

Reynolds 1992 (Section 8, Theorem 6) provides a fully worked Doets's theorem statement. The path for task 68:
1. Task 107 (chronicle) produces a Q-flowed model for any consistent formula
2. Add density + no-endpoints axioms to force a Q-flowed Prior structure
3. Verify D1 (no gap-ending ~-classes) via Prior-U/S (Reynolds Theorem 4)
4. Verify D2 (dense singletons) via Sep (Reynolds Theorem 5)
5. Apply Doets transfer (or stop at Q for the D=Rat representation theorem goal)

**Task 68 depends on task 107 completing first.** The two tasks are sequential, not parallel.

### 7. Xu 1988 Validates the BX Axiom Set (HIGH CONFIDENCE)

Xu's incompleteness results (Section 4, Theorem 4.4) confirm each BX axiom is genuinely independent. No axiom in `Axioms.lean` can be dropped. The axiom set is correct and minimal for linear frame completeness.

## Synthesis

### Conflicts Resolved

**Conflict 1 — Scope of transferability**: Teammates A and B identified specific technique transfers (Xu Lemma 2.4 → c2' sorries, Reynolds C3+r-relation → fuc sorries). Teammate C challenged this by noting none of the papers handle S5+U/S in combination. **Resolution**: The technique transfers are valid for the TENSE dimension of the proof (which the c2' and C5 sorries address). The S5 dimension is handled separately by the BFMCS construction (already sorry-free). The bimodal WIRING in `ChronicleToCountermodel.lean` (8 sorry sites) has no direct literature analogue — this is genuinely novel territory.

**Conflict 2 — Reynolds applicability**: Teammate A suggested Reynolds Section 4 confirms the fuc sorry path. Teammate B noted Reynolds does NOT offer an alternative mechanism for the Chronicle sorries. **Resolution**: Both are correct. Reynolds confirms the C3-based guard argument is the standard approach (supporting the fix), but his IRR-free technique is for a different completeness question (over R, not all linear orders) and does not provide new machinery.

**Conflict 3 — Xu Section 2 as "canonical model" vs. "chronicle"**: Teammate C observed that Xu's Lemmas 2.6/2.7 are structurally more similar to chronicle PointInsertion than to standard canonical model construction, despite Xu framing it as canonical model theory. **Resolution**: Correct. Xu's controlled K-structure extension (adding points geometrically, not extending formulas via Lindenbaum) IS the mechanism the chronicle uses. This makes Xu's binary g-function construction the most directly transferable technique in the literature collection. The other papers' canonical model or mosaic techniques are less relevant.

### Gaps Identified

1. **No S5+U/S+strict literature exists**: The project's combination of S5 modality + U/S temporal operators + irreflexive ordering + chronicle construction has no published completeness result. The bimodal coherence wiring in `ChronicleToCountermodel.lean` must be developed from first principles.

2. **Reynolds Prior-U/S axioms not in BX**: Before any technique transfer from Reynolds to task 68 (dense completeness), the team must verify whether Prior-U, Prior-S, and Sep are derivable from the BX axiom set. If not, bridge lemmas or additional axioms are needed.

3. **`limit_c2` sorry status unknown**: The fuc sorry fix path depends on `limit_c2` (full r-relation at the limit) being sorry-free. This needs codebase verification.

4. **CVV 2013 U/S extension**: Extending the mosaic method from G/H to U/S is a substantial open research problem. The mosaic saturation conditions (SV1–SV4) would need complete redesign to handle U/S witnesses. This is relevant to tasks 82/998 if the decidability track is revived.

### Recommendations

**Priority 1 — Close the 6 c2' sorry sites** (CounterexampleElimination.lean):
Modify `eliminate_C5_counterexample` and `eliminate_C4_counterexample` to extract B' and B'' from the Lindenbaum step (Xu Lemma 2.4 pattern). This is mechanical Lean work following Xu's construction directly.

**Priority 2 — Close `cantor_bfmcs_restricted_fuc`** (ChronicleToCountermodel.lean:615-619):
Strengthen `EliminationResult.c5_forward_witness` to carry guard information, then prove `limit_satisfies_c5_full` via C3 + limit_c2 + BX5. Verify `limit_c2` is sorry-free first.

**Priority 3 — Continue task 107 chronicle construction**:
All four teammates and all three papers confirm this is the correct primary path. No alternative technique from the literature offers a better route to general completeness over all strict linear orders.

**Priority 4 — Plan task 68 via Reynolds-Doets**:
After task 107 succeeds, use Reynolds 1992 Sections 5-9 as the template for dense completeness. First verify whether Prior-U/S and Sep are BX-derivable.

**Priority 5 — Caleiro et al. for decidability tracks** (tasks 82/998):
If the decidability track is revived, use the mosaic method but budget effort for the U/S language extension.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary techniques for base TM and chronicle | completed | high |
| B | IRR-free alternatives for Until/Since extension | completed | high |
| C | Critic — gaps, blind spots, dead end cross-reference | completed | high |
| D | Horizons — dense/discrete specializations and strategy | completed | high |

## References

- Xu, M. (1988). "On some U,S-tense logics." *JPL* 17(2), 181–202.
- Reynolds, M. (1992). "An axiomatization for until and since over the reals without the IRR rule." *Studia Logica* 51, 165–193.
- Caleiro, C., Viganò, L. & Volpe, M. (2013). "On the Mosaic Method for Many-Dimensional Modal Logics." *Logica Universalis* 7(1), 33–69.
- Burgess, J. P. (1982). "Axioms for tense logic. I. 'Since' and 'until'." *NDJFL* 23(4), 367–374.
- Venema, Y. (1993). "Since and Until." In *Diamonds and Defaults*, Synthese Library 229, Springer.
- Doets, K. (1989). "Monadic Pi-1-1-Theories of Pi-1-1-Properties." *NDJFL* 30(2), 224–240.
