# Research Report: Task #93

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-15
**Mode**: Team Research (4 teammates)

## Summary

Four teammates independently analyzed the proposed **bilateral pairs** approach — working with ⟨V, F⟩ pairs where V tracks verified (true) formulas and F tracks falsified formulas, with negation closure (φ ∈ F iff ¬φ ∈ V), MP closure, and implication closure. The team reaches **unanimous consensus (90%+ confidence)**: bilateral pairs are **mathematically isomorphic to the existing MCS (maximally consistent set) approach** in classical logic and provide **zero new proof leverage** for the forward_F blocker.

The core argument: a balanced pair ⟨V, F⟩ with the proposed closure properties satisfies (1) V is consistent, (2) for every φ, either φ ∈ V or ¬φ ∈ V (by negation closure + excluded middle from Peirce's law). This is exactly `SetMaximalConsistent`. Conversely, every MCS M yields a balanced pair via V = M, F = {φ | ¬φ ∈ M}. The correspondence is bijective. The forward_F problem — that `.choose` in `set_lindenbaum` is unconstrained and can perpetually defer ψ into F(ψ) via BX11 Case 3 — is unchanged by relabeling MCS as bilateral pairs.

**Plan v18 (ordered-discharge chain with never-resolved count)** remains the recommended path at 55-65% confidence. Two low-cost pre-attempts (fold-order trick and BX12 approach) were identified as worth trying first (5 hours total).

## Key Findings

### Primary Approach Analysis (from Teammate A)

**Bilateral pairs = MCS (definitional equivalence)**. The balanced pair ⟨V, F⟩ with negation closure, MP closure, and totality is exactly an MCS M with V = M and F = complement(M). The `negation_complete` property of `SetMaximalConsistent` already provides the bilateral structure implicitly. No new mathematical content.

**Same Lindenbaum obstruction**: The balanced pair extension still requires `.choose` to pick an extension. BX11's three-way disjunction (Cases 1, 2, 3 in `enriched_fwd_fold_with_witness`, RootScopedChain.lean:284-360) applies unchanged — Case 3 can displace target under F regardless of whether the chain is built from MCS or bilateral pairs.

**Zero-gain re-implementation**: 20-40 hours to redefine BXPoint, bx_le, bx_modal_equiv, and canonical frame infrastructure for mathematically identical objects.

**Specific technical observation**: The bilateral proposal's claim that "explicit falsity sets help control what ends up in the chain" conflates *visibility* of false formulas with *control* over which formulas become true. Having F(ψ) explicitly in F₁ simply means ¬F(ψ) ∈ V₁ — already captured by ¬F(ψ) ∈ M₁ in the MCS framework.

### Literature and Alternatives (from Teammate B)

**No published classical tense logic completeness proof uses bilateral pairs** for eventuality witnesses. Literature survey results:

1. **Rumfitt/Restall bilateral semantics**: Proof-theoretic (assertion/denial for propositional connectives). No temporal extensions. No completeness technique applicable to forward_F.

2. **Belnap-Dunn four-valued modal logic** (Odintsov-Wansing, BK/BS4): Uses paired semantics (R⁺, R⁻) per modal operator. Completeness proofs exist for paraconsistent/four-valued logics only. BX uses classical excluded middle — adopting four-valued semantics would require full redesign (~100+ hours).

3. **Nelson's N4 + temporal extensions**: Bilateral via strong negation. No Lean 4 formalization found. Eventuality witnesses still require Lindenbaum — same gap.

4. **Quasimodel approach with defect tracking**: The most developed "bilateral-flavored" construction for temporal logic — already implemented in this codebase (Quasimodel/ directory, 2,289 lines sorry-free). Successfully closed Until/Since sorries. Forward_F faces the same nondeterminism obstacle in quasimodels.

**Key insight**: The existing quasimodel infrastructure IS the closest thing to bilateral reasoning in the codebase — it tracks defects (unresolved eventualities) explicitly. The forward_F problem is orthogonal to bilateral framing.

### Critic Analysis (from Teammate C)

**Seven critical issues identified**:

1. **Balanced pair = MCS bijection**: Formally proved. Given balanced ⟨V, F⟩ with the four closure properties, V is an MCS. Given MCS M, ⟨M, {φ | ¬φ ∈ M}⟩ is balanced. The correspondence is identity under relabeling.

2. **"Constructive-friendly" claim is vacuous**: TM has Peirce's law (`Axioms.lean:81`), making the logic fully classical. Lindenbaum's lemma requires excluded middle regardless. There is no constructive content to exploit.

3. **Bilateral falsity of temporal operators reduces to classical truth**: M,τ,x ⊨⁻ F(ψ) iff ∀s > x, M,τ,x ⊨⁻ ψ — which is M,τ,x ⊨⁺ G(¬ψ). No new semantic leverage for F-eventuality resolution.

4. **Consistency of V ∩ F**: Classical logic requires V ∩ F = ∅ (no formula both true and false). This is automatic from negation closure + consistency — but means the bilateral pair is fully determined by V alone, confirming the MCS equivalence.

5. **Implication closure is derivable**: The proposed "if ¬φ ∈ V or ψ ∈ V then φ → ψ ∈ V" follows from deductive closure + classical negation. This is not a new property.

6. **Infrastructure cost is prohibitive**: ~1000+ lines of Frame.lean + TruthLemma.lean + quasimodel infrastructure would need rewriting for zero mathematical gain.

7. **The forward_F problem is structural, not representational**: The issue is that `.choose` in the step function is unconstrained. Changing the *representation* of consistent sets (MCS vs bilateral pairs) does not constrain the choice. Only changing the *construction* (as Plan v18 proposes) can.

### Strategic Horizons (from Teammate D)

**Bilateral pairs as a design lens, not a construction tool**: The never-resolved count in Plan v18 IS a bilateral partition of F-obligations into (pending, resolved). Bilateral terminology may clarify the invariant without requiring new definitions.

**Two low-cost pre-attempts before committing to Plan v18** (5 hours total):
1. **Fold-order trick** (2h): Process target LAST in BX11 fold. Case 3 puts the LEFT operand under F — if target is always rightmost, Case 3 cannot fire for target. May be a zero-cost fix.
2. **Approach 21 via BX12** (3h): `F(ψ) → ⊤Uψ` by BX12, then leverage `bx_until_eventuality_resolution` (proved, sorry-free). Obstacles: produces abstract BXPoints not chain indices.

**Strategic assessment**: Full bilateral semantics (200-400h) has value as a separate research project studying constructive/intuitionistic extensions of TM — but is an entirely different project, not a path to closing task 93.

**Plan v18 remains correct**: 55-65% confidence, ~24 hours, ~30 theorem re-proofs. The bilateral framing adds zero probability of success.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| None | All 4 teammates reached the same conclusion: bilateral pairs ≅ MCS, no help for forward_F |

No conflicts to resolve — this is one of the strongest team consensuses across all 19 research rounds for task 93.

### Gaps Identified

1. **Fold-order trick unvalidated**: Teammate A and D both identify processing target LAST in the BX11 fold as potentially preventing Case 3 displacement. This is the lowest-cost intervention (2 hours) and has not been tested. **Requires focused investigation.**

2. **BX12 approach (Approach 21) unvalidated**: Teammate D identifies `F(ψ) → ⊤Uψ` via BX12 as a way to leverage the proved `bx_until_eventuality_resolution`. The obstacle (abstract BXPoints vs chain indices) needs concrete analysis. **Requires focused investigation.**

3. **Bilateral semantics as future work**: All teammates note bilateral/four-valued semantics could be interesting for constructive extensions of TM, but this is out of scope for task 93.

### Recommendations

**Immediate (reject proposal)**: Do NOT pursue bilateral pairs for task 93. The approach is mathematically equivalent to the current MCS framework and provides no new proof leverage for forward_F.

**Short-term (5 hours)**: Before committing to the full Plan v18 chain replacement, try two low-cost interventions:
1. **Fold-order trick** (2h): Modify `enriched_fwd_fold_with_witness` so target is processed LAST. If BX11 Case 3 cannot fire for the rightmost operand, this is a zero-infrastructure-cost fix.
2. **BX12 approach** (3h): Use `F(ψ) → ⊤Uψ` via BX12 to reduce forward_F to the proved `bx_until_eventuality_resolution`.

**Fallback (24 hours)**: If both short-term interventions fail, proceed with Plan v18 (ordered-discharge chain with never-resolved count).

**Future work**: Bilateral semantics for TM as a separate research module (`BilateralBXCanonical`) — potentially publication-worthy for studying constructive/paraconsistent extensions. Estimated 200-400 hours. Not for task 93.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach analysis (bilateral pairs deep dive) | completed | High (90% bilateral = MCS) |
| B | Literature review and alternatives | completed | High (90% no help in literature) |
| C | Critic — gaps, problems, showstoppers | completed | High (90%+ bilateral ≅ MCS formally) |
| D | Horizons — strategic direction | completed | High (90% bilateral won't fix forward_F) |

## References

### Key Source Files
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 6 sorry sites (lines 1275, 1306, 1313, 1366, 1371, 1376)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — `SetMaximalConsistent.negation_complete` (bilateral structure implicit in MCS)
- `Theories/Bimodal/Semantics/Truth.lean` — current unilateral semantics
- `Theories/Bimodal/ProofSystem/Axioms.lean:81` — Peirce's law (classical logic)

### Literature
- Rumfitt, I. (2000). "Yes and No." *Mind* 109, 781-823. (Bilateral assertion/denial)
- Restall, G. (2005). "Multiple Conclusions." (Bilateral sequent calculus)
- Odintsov, S., Wansing, H. (2017). "Modal logics with Belnapian truth values." (BK/BS4 four-valued modal)
- Nelson, D. (1949). "Constructible falsity." (N3/N4 strong negation)
- Belnap, N. (1977). "A useful four-valued logic." (FDE)
- Burgess, J.P. (1984). "Basic tense logic." (BX classical temporal completeness)
- Goldblatt, R. (1992). "Logics of Time and Computation." (Bulldozing technique)

### Prior Task 93 Artifacts Referenced
- Report 18: Team research (Strategy C invalid, ordered-discharge recommended)
- Report 17: Round-robin chain history (19 failed approaches)
- Plan v18: Ordered-discharge chain replacement (current plan)
