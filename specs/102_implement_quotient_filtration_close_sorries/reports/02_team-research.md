# Research Report: Task #102 (Round 2)

**Task**: 102 - Implement defect-discharge chain and close Until/Since sorries
**Date**: 2026-04-11
**Mode**: Team Research (4 teammates)
**Session**: sess_1775931033_60d2fd

## Summary

Team research investigated 4 angles of the mathematical blocker preventing closure of 10 Until/Since sorries (4 Frame.lean, 6 Realization.lean). The root cause — `bx_le := g_content ⊆` being a non-total preorder — is confirmed with high confidence and is **architectural, not incidental**. Standard temporal logic completeness proofs (Burgess 1984, Goldblatt 1992, BdRV 2001) do NOT use g_content inclusion as the canonical ordering. Three viable paths forward were identified and ranked.

## Key Findings

### Primary Approach Analysis (Teammate A)

**Finding A1**: The 4 Frame.lean sorry signatures all use `bx_le u v ∧ ¬bx_le v u` as the guard condition. `bx_lt` (TruthLemma.lean:212) is defined as exactly this. The `until_iff_mcs` / `since_iff_mcs` theorems in TruthLemma.lean state biconditionals with `bx_lt` guards.

**Finding A2**: `until_iff_mcs` and `since_iff_mcs` are NOT consumed by anything downstream — they are only defined and referenced in comments. Modifying their statements is safe with zero downstream cascade.

**Finding A3**: F(psi) is derivable at every intermediate point u between w and v: `bx_le u v` and `psi in v` gives `H(F(psi)) in v` (BX4'), then `F(psi) in u` via `bx_H_forward`. This is a critical enabler for BX7-based approaches.

**Finding A4**: A BX7-based direct proof strategy has the mathematical ingredients present (F(psi) at intermediates, BX7 linearity, BX9 elimination) but the disjunct analysis is incomplete — which of BX7's three disjuncts applies has not been fully worked out.

### Alternative Approaches (Teammate B)

**Finding B1**: The Until-induction axiom existed historically (removed at commit `1d9bd6160`, task 83 phase 1, when switching from strict to reflexive Until/Since semantics). It was discrete-only, requiring the X (next-time) operator. No sound reflexive variant was identified — the step case requires `G(chi)` (chi at ALL future times), which is too strong for general reflexive linear orders.

**Finding B2**: Standard literature completeness proofs either work in a finite model where the ordering is total by construction (Burgess, Goldblatt, BdRV) or use induction axioms (Reynolds). The codebase's `bx_le := g_content ⊆` is non-standard.

**Finding B3**: Extensive reusable infrastructure exists for a finite linear model: `HintikkaPoint`, `sigma_signature`, `defect_count`, `hintikka_step`, `hintikka_step_target_decrease`, `enriched_seed_consistent_until`. Estimated 30-50h for the finite model approach.

**Finding B4**: Rewriting bx_le has 159 occurrences across 8 files and would require reverifying the fully-proved G/H truth lemma. Cost/risk ratio is poor.

### Critic Analysis (Teammate C)

**Finding C1 (CRITICAL)**: The plan's Phase 3 fallback sub-strategy confuses Sigma membership (set-theoretic: `G(phi) ∈ enrichedClosure(target)`) with MCS membership (logical: `G(phi) ∈ u'.formulas`). These are completely different. `G(phi)` being tracked by Sigma does NOT mean `G(phi)` holds at any particular BXPoint. **This is a confirmed error in the plan.**

**Finding C2**: The backward direction cannot work by simple contradiction. Having `phi ∈ u` (from guard) and `¬(phi U psi) ∈ u` is perfectly consistent — it just means the Until formula fails starting from u. The current enriched-seed approach constructs the right intermediate point but no contradiction is derivable.

**Finding C3**: The 6 Realization.lean sorries are INDEPENDENT implementations, not wrappers around Frame.lean. They use the quasimodel chain approach, not the Frame.lean approach. Closing Frame.lean does NOT automatically close them. Either (a) delete Realization.lean implementations and delegate to Frame.lean, or (b) close them independently.

**Finding C4**: Replacing `¬bx_le v u` with `sigma_strict Sigma u v` in Frame.lean makes the signatures EASIER to prove but HARDER for callers to use. TruthLemma.lean callers provide `bx_lt` (= `bx_le ∧ ¬bx_le`), but sigma_strict is WEAKER than bx_lt. A bridge lemma or truth lemma restatement is needed — this is a potential showstopper for Phase 4.

### Strategic Horizons (Teammate D)

**Finding D1**: The 4 Frame.lean sorries reduce to 2 independent problems — Until forward + Until backward. Since mirrors automatically via h_content/g_content duality.

**Finding D2**: If the approach involves building a finite linear model, that same construction could potentially close the TaskModel embedding sorry (Completeness.lean:154) as well, reducing remaining active-path sorries from 2 to 1.

**Finding D3**: Suggested investigation order: (1) Spend 2-3h on Until-induction as derived theorem (cheap, high reward if it works), (2) continue current plan, (3) fallback to bx_le replacement.

## Synthesis

### Conflicts Resolved

**Conflict 1: Realization.lean dependency**
- Teammates A and D claim Realization.lean sorries "delegate to Frame.lean" / "close automatically"
- Teammate C demonstrates they are independent implementations with independent sorries
- **Resolution**: Teammate C is correct. The Realization.lean sorries must be either (a) deleted and replaced with Frame.lean calls, or (b) closed independently. Option (a) is simpler and is the recommended path after Frame.lean is closed.

**Conflict 2: Recommended approach**
- Teammate A recommends BX7-based direct proof (medium-high confidence)
- Teammate B recommends finite linear model (75% confidence)
- Teammate C is skeptical of all current approaches
- Teammate D recommends investigating Until-induction first
- **Resolution**: The approaches are not mutually exclusive. A staged investigation is recommended (see below). Teammate A's BX7 approach is the highest-reward if the disjunct analysis works out, but it is unproven. Teammate B's finite model is the highest-confidence fallback.

**Conflict 3: sigma_strict viability**
- All teammates agree sigma_strict creates a bridge problem at the TruthLemma level
- **Resolution**: The sigma_strict approach should NOT be pursued as the primary path. It weakens Frame.lean signatures but creates equal problems at the TruthLemma level.

### Gaps Identified

1. **BX7 disjunct analysis**: Teammate A identifies BX7 as having the right ingredients but the case analysis is incomplete. Which of BX7's three disjuncts applies when combining `(phi U psi)` at u' with `(⊤ U psi)` at u? This is the critical unresolved question.

2. **Until-induction derivability**: Can `phi U psi → phi ∨ (phi ∧ F(phi U psi))` be derived from BX5+BX6+BX9+BX10? This would give a "next step" property without the X operator. No teammate fully investigated this.

3. **Backward direction strategy**: All teammates agree the backward direction cannot work by contradiction. No viable alternative proof strategy was identified. The backward direction may need a fundamentally different approach (e.g., constructive derivation of `phi U psi` from the witness and guard).

### Consolidated Recommendations (Ranked)

#### Rank 1: BX7 Direct Proof [Time-boxed 4h investigation]

**Confidence**: Medium (50% success probability, but cheap to investigate)

Investigate whether BX7 (`linear_until`) can close the forward direction:
1. Apply BX7 to `(phi U psi)` at u' (backward witness) and `(⊤ U psi)` at u (from F(psi))
2. Analyze which disjunct applies and whether it gives `phi ∈ u`
3. If successful: closes forward direction, backward direction may follow

This costs 4h of investigation with 50% chance of closing all sorries directly. If it fails, nothing is lost.

#### Rank 2: Finite Linear Model Construction [Highest confidence fallback]

**Confidence**: High (80%)

Build an independent finite model from defect-discharge chains:
1. Define `FiltrationModel` as a finite list of BXPoints with position-based ordering
2. Ordering is total by construction (position in chain)
3. Guard is trivial (all points are chain members, BX9 gives phi at each)
4. Prove truth lemma directly in the finite model
5. Bypass Frame.lean entirely OR modify Frame.lean to use finite model witnesses

**Bonus**: Same construction may close TaskModel embedding sorry (task 93).

**Cost**: 30-50h new code, but uses extensive existing infrastructure.

#### Rank 3: Replace bx_le Ordering [Nuclear option]

**Confidence**: Very High (95%)

Replace `bx_le := g_content ⊆` with a chain-constructed linear ordering. All points in the model are chain members, making the guard trivial.

**Cost**: ~500 lines rewritten across 8 files, 20+h. Requires reverifying G/H truth lemma.

Only pursue if Ranks 1-2 both fail.

### NOT Recommended

- **sigma_strict guard weakening**: Creates equal bridge problems at TruthLemma level (all teammates agree)
- **Until-induction axiom restoration**: No sound reflexive variant (Teammate B confirmed)
- **Direct witness construction**: Same bx_le propagation gap (Teammate B confirmed)
- **Rewriting bx_le definition**: Cost/risk too high vs finite model alternative (Teammate B)

## Plan Revision Recommendations

The current plan (01_defect-discharge-implementation.md) should be revised:

1. **Phase 3 (Guard Extension)**: Replace with "BX7 Investigation" — time-boxed 4h attempt at BX7 direct proof
2. **Phase 3 fallback**: Replace enrichedClosure-based argument with finite linear model construction
3. **Phase 4**: If BX7 succeeds, close Frame.lean sorries directly. If finite model, restructure to bypass Frame.lean
4. **Phase 5**: Delete Realization.lean independent implementations and delegate to Frame.lean, rather than attempting to close them independently
5. **Fix plan error**: Remove claim about Sigma membership implying MCS membership (Finding C1)
6. **Fix dependency assumption**: Realization.lean sorries are NOT automatic from Frame.lean (Finding C3)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary Approach | completed | medium-high | BX7 direct proof strategy; F(psi) derivability; until_iff_mcs not consumed downstream |
| B | Alternatives | completed | medium-high | Literature cross-reference; Until-induction history; finite model infrastructure inventory |
| C | Critic | completed | medium-low | Sigma/MCS confusion error; backward contradiction impossibility; Realization independence |
| D | Horizons | completed | medium | Until/Since symmetry (2 not 4 problems); TaskModel bonus; investigation ordering |

## References

- Burgess 1982/84: "Basic Tense Logic" — defect-discharge chain construction
- Goldblatt 1992: "Logics of Time and Computation" Ch. 5 — filtration approach
- Blackburn, de Rijke, Venema 2001: "Modal Logic" Ch. 4 — filtration for FMP
- Reynolds 2003: "An Axiomatization of Full CTL" — induction axiom approach
- Git commit `1d9bd6160`: Until-induction axiom removal (task 83 phase 1)
- Git commit `a34643e49`: Until-induction with G-wrapped premises (task 83)
