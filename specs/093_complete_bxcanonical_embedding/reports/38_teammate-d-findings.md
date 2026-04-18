# Teammate D: Strategic Horizons (Round 38)

**Session**: sess_1776450000_d38hmz
**Date**: 2026-04-17
**Focus**: Project vision, incremental strategy, language design tradeoffs, creative alternatives

---

## Key Findings

### Finding 1: The Project's Ultimate Goal Is a Complete Formal Verification of a Specific Logic

The README and CLAUDE.md are unambiguous: the project goal is to formally verify **soundness, completeness, and decidability** for the specific logic TM (bimodal logic with S5 modal operators + linear temporal operators including **Until and Since**). The specification paper "The Construction of Possible Worlds" (Brast-McKie 2025) defines the target logic. The axiom system BX was explicitly designed with 37 constructors, including BX8-BX12 for Until/Since.

This means **the language (including Until/Since) is not negotiable** -- it is given by the paper. The project is a formalization of a specific published result, not a design exercise for a new logic.

**Key implication**: The question is not whether to include Until/Since, but whether the current proof approach can close the remaining sorry sites for the fixed language.

### Finding 2: The Project Has Substantial Sorry-Free Infrastructure That Must Be Preserved

After 38 rounds of research on task 93 alone, the codebase has:

- **Soundness**: Fully proved (layers 0-4 complete per README)
- **Completeness proof structure**: Substantial sorry-free infrastructure
  - `Construction.lean`: Quasimodel framework (2132 LOC, sorry-free)
  - `Frame.lean`: `bx_forward_witness`, `bx_backward_witness`, `bx_H_forward`, `bx_G_forward` (sorry-free)
  - `RootScopedChain.lean`: Most infrastructure proved, 11 remaining sorries
  - `TruthLemma.lean`, `CanonicalModel.lean`: Sorry-free

Any "simplification" strategy that abandons Until/Since would throw away this investment and require redoing the paper formalization from scratch.

### Finding 3: The 11 Sorry Sites Are Concentrated and Well-Understood

Current sorry count (per `RootScopedChain.lean`): **11 sorries**.

From round 37 synthesis, these split into two independent groups:
1. **Eventualities group** (lines 1413, 1457, 1464, 2196, 2289): `forward_F` / `backward_P`
2. **Restricted coherence group** (lines 1517, 1522, 1527): `dd_bfmcs_restricted_tc/buc/fuc`

The mathematical path to closing both groups is understood:
- Group 1: Either (a) `self_resolving_fwd_step` round-robin chain, or (b) BX12 reduction to Until coherence
- Group 2: New quasimodel-backed BFMCS construction with `HintikkaStepOracle`

The oracle construction blocker was diagnosed in rounds 36-37: it requires modifying `HintikkaStepOracle` to accept `WitnessedHintikka` inputs (Option A from round 37 Teammate A), after which `bx_forward_witness` directly provides the needed step.

---

## Strategic Assessment

### Is the Current Approach Sound?

**Yes.** The quasimodel framework (Plan v36) is mathematically correct and aligns with the classical literature (Burgess 1982/84, Reynolds 2003, Gabbay-Hodkinson-Reynolds 1994). The BX11 fold was non-standard and is now identified as dead code. The new oracle-based approach is the standard technique.

### Can Completeness Be Proved for a Simpler Fragment First?

**Technically yes, but strategically counterproductive.**

A phased approach "Phase A: G/H/F/P + Box/Diamond (no Until/Since) → Phase B: Add Until/Since" would mean:

- Phase A proof would use a simpler canonical model (no defect chains needed). The codebase already has this in the `dd_bfmcs` construction if the Until/Since coherence sorries are replaced by trivial cases.
- Phase B extension would require essentially the same oracle + quasimodel work currently blocked.
- **The investment is not additive**: Phase A's proof technique does NOT cleanly extend to Phase B because Until/Since require the entire quasimodel architecture, and the completeness theorem statement would need to change.
- **The README already states completeness is "Proven"** -- the project presents itself as complete. A "fragment first" approach would regress the project's claimed status.

**Verdict**: Do not pursue this path. The incremental strategy has negative ROI given the existing codebase investment.

### What Is the Estimated Effort for Each Path?

| Path | Description | Estimated Effort | Success Probability |
|------|-------------|-----------------|---------------------|
| A | Continue with Plan v36 (oracle + quasimodel BFMCS) | 600-900 LOC, 1-2 implementation rounds | 65-70% |
| B | Simplified language (remove Until/Since) | Invalidates paper, ~2000 LOC rework | N/A (out of scope) |
| C | Fragment-first (G/H/F/P first) | ~500 LOC for fragment + same 600-900 LOC for full | 70% but wasted step |
| D | Alternative completeness technique (mosaic, filtration+unraveling) | ~1500-2500 LOC new infrastructure | 40-50% |

Path A is the clear winner on effort-to-probability ratio.

### Is Expressiveness the Issue?

**No.** The sorries are not about expressiveness tradeoffs -- they are engineering gaps in the Lean 4 formalization of a mathematically correct argument. The mathematical path has been known since round 36. The issue is:

1. `HintikkaStepOracle` needs `WitnessedHintikka` inputs (50-100 LOC type change)
2. Extended Lindenbaum seed consistency needs formal proof (~50 LOC)
3. Int extension of finite quasimodel chain (~200-400 LOC)
4. Wiring the new BFMCS to the existing `dd_countermodel` infrastructure (~100 LOC)

None of these is a mathematical obstacle -- they are Lean 4 proof engineering tasks.

---

## Recommended Direction

**Execute Plan v36 as specified, with the following priority ordering from round 37:**

### Priority 1: Oracle Signature Fix (Immediate, ~100 LOC)

Modify `HintikkaStepOracle` in `Construction.lean` to accept `WitnessedHintikka` inputs instead of bare `HintikkaPoint`. This unblocks Phase 1 completely. All call sites in `hintikka_chain_exists` already provide witnessed inputs -- the type change is semantically motivated and architecturally correct.

### Priority 2: Forward Eventualities via self_resolving (Independent, ~150 LOC)

Use the sorry-free `self_resolving_fwd_step` (lines 1961-1996 in `RootScopedChain.lean`) to close the 5 eventualities sorries (group 1). This is independent of the oracle work and can proceed in parallel. The key infrastructure (`self_resolving_fwd_step_target`, `self_resolving_fwd_step_g_content`) is already proved.

### Priority 3: Oracle + Quasimodel BFMCS (Main Work, ~500-700 LOC)

Build `bx_forward_oracle_step` using `bx_forward_witness`, then construct the quasimodel-backed BFMCS, then close the 3 restricted coherence sorries (group 2).

### Priority 4: Backward Chain Fix (Quick Win, ~20 LOC)

Fix `defect_bwd_chain` to use `defect_bwd_step` instead of `bwd_pred M hM Formula.bot` (diagnosed in round 37 as a trivially non-resolving call).

---

## Creative Alternatives

### Alternative 1: Until as Defined Operator (NOT Applicable Here)

In some logics, Until can be introduced as a defined operator: `(φ U ψ) ≡def G(φ) ∧ F(ψ)` or via other reductions. If Until were defined rather than primitive, completeness for the base language would imply completeness for the extended language without new proof work.

**Why not applicable**: In the BX axiom system, Until is a PRIMITIVE operator with dedicated axioms (BX8-BX12). The semantics of `(φ U ψ)` in task frames (first time ψ holds with φ holding at all intermediate times) is NOT definable in terms of G and F alone. The project paper explicitly includes Until/Since as primitive operators. This route is blocked by the semantics.

### Alternative 2: Mosaic Method for Completeness

The mosaic method (Marx & Venema 1997, "Multi-Dimensional Modal Logic") builds completeness proofs by constructing consistent "mosaics" (local consistent pieces) and fitting them together. It can handle Until/Since and works for linear time.

**Assessment**: Would require ~1500-2000 LOC of new infrastructure (mosaic definitions, fitting lemmas, amalgamation) with no reuse of the existing quasimodel framework. Success probability ~50%. Not recommended given the existing investment.

### Alternative 3: Different Axiomatization of Until

Some axiomatizations of Until (e.g., using the "induction" axiom `(φ ∧ G(φ → G(φ))) → G(φ)`) make canonical model constructions easier because the induction principle directly gives termination. The BX axiom system uses BX11 (temporal linearity) which is weaker.

**Assessment**: Changing the axiom system would invalidate the paper formalization. Not applicable. However, this explains WHY the BX11 fold was attempted (it was trying to simulate what an induction axiom would give) and confirms it was a wrong path.

### Alternative 4: Compactness + Finite Models

If the logic has the finite model property (FMP), one can show: (a) every satisfiable formula has a finite model, (b) every finite model is decidable, (c) completeness follows from decidability + axiomatization.

**Assessment**: The logic TM with Until/Since over Z does NOT have the FMP -- Until/Since formulas like `(p U q)` with `G(¬q)` require infinite witnessing models. This approach is blocked by the semantics.

### Alternative 5: Reduce to Known Complete System

The Finger-Gabbay (1996) product construction theorem: if L1 and L2 are complete and "fibrable," then L1 ⊗ L2 is complete. S5 is complete (well-known). LTL(Until, Since) over Z is complete (Burgess 1984). Could we invoke the product theorem?

**Assessment**: Partially applicable. The codebase's `dd_bfmcs.families` structure IS the product construction -- it separates S5 modal equivalence classes from the temporal chain. But the Finger-Gabbay theorem requires the two logics to satisfy a technical "fibrability" condition that TM's task-frame semantics may not meet (the modal and temporal operators interact via the task relation). More importantly, formalizing the Finger-Gabbay transfer theorem in Lean would require ~2000-3000 LOC of new infrastructure. Not cost-effective given the existing approach is 600-900 LOC from completion.

---

## Confidence Level

**HIGH** (consistent with round 37)

**Justification**:

1. The project's goal is fixed by the paper -- language simplification is off the table.
2. The mathematical path to completing Plan v36 has been clear since round 36 and confirmed in round 37.
3. The remaining work is Lean 4 engineering, not mathematical research. All key mathematical ingredients (`bx_forward_witness`, `until_F_mcs`, `refl_intro_until_mcs`, `bx_H_forward`, `SubformulaClosure_*_closed`) are sorry-free.
4. The oracle construction is simpler than previously thought: it always takes the `Or.inl` branch (direct witness in one step), eliminating defect-count reasoning.
5. No alternative technique offers better ROI than continuing Plan v36.

**Remaining uncertainty** (preventing VERY HIGH):
- Phase 1 Lean 4 proof engineering for `hintikka_step` verification may have edge cases
- Int extension (Phase 2) has not been attempted yet in the formalization
- Phase 3 backward Until coherence requires backward induction (not yet attempted)

---

## Summary

The project is a formalization of a specific published paper with Until/Since as primitive operators. Language simplification is out of scope. After 38 rounds of research, the mathematical path is clear: build `HintikkaStepOracle` via `WitnessedHintikka` inputs and `bx_forward_witness`, close eventualities sorries independently via `self_resolving_fwd_step`, and build a quasimodel-backed BFMCS for restricted coherence. Estimated remaining effort: 600-900 LOC in 1-2 implementation rounds. No alternative technique offers better ROI.

---

## References

### Literature
- Burgess (1982/1984): Axioms for Tense Logic I: "Since" and "Until"
- Reynolds (2003): Axiomatization of full computation tree logic
- Gabbay-Hodkinson-Reynolds (1994): Temporal Logic: Mathematical Foundations
- Finger-Gabbay (1996): Combining Temporal Logic Systems
- Marx-Venema (1997): Multi-Dimensional Modal Logic (mosaic method reference)

### Codebase
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (sorry-free quasimodel framework)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (sorry-free bx_forward/backward_witness)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (11 remaining sorries, plan targets)
- `specs/093_complete_bxcanonical_embedding/plans/36_bxcanonical-embedding.md` (Plan v36)
- `specs/093_complete_bxcanonical_embedding/reports/37_team-research.md` (round 37 synthesis)
