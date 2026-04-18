# Research Report: Task #93 - Round 38

**Task**: Complete BXCanonical embedding
**Date**: 2026-04-17
**Mode**: Team Research (4 teammates)
**Session**: sess_1776473397_281229
**Focus**: Language design tradeoffs for completeness -- Until/Since inclusion, strict vs weak G/H semantics

## Summary

All four teammates converge on a decisive answer: **do not change the language or semantics**. The difficulty in proving completeness is not caused by Until/Since being in the language or by reflexive G/H semantics. It is caused by the BX11-fold chain construction -- a codebase-specific innovation with no literature basis that introduces perpetual deferral. The fix is to replace this construction with deterministic round-robin chains using already-proved sorry-free primitives (`self_resolving_fwd_step`, `defect_bwd_step`). The language is fixed by the published paper "The Construction of Possible Worlds" (Brast-McKie 2025), making simplification out of scope regardless.

## Key Findings

### 1. Until/Since Are Fixed by the Paper (Unanimous, HIGH confidence)

The project formalizes a specific published paper with Until (U) and Since (S) as primitive operators in the BX axiom system. 22 of 37 BX axioms involve U/S directly (BX2-BX12). Removing them would invalidate the paper formalization. This is not a design choice -- it is a constraint.

### 2. Removing Until/Since: Partial Simplification but Core Blocker Remains (A, C)

**What would simplify**: The `restricted_backward_until_since_coherent` (buc) and `restricted_forward_until_since_coherent` (fuc) sorry sites would become vacuously true -- these predicates quantify over `phi U psi in subformulaClosure(root)`, which is empty without U/S constructors.

**What would NOT simplify**: The `restricted_temporally_coherent` (tc) sorry and its underlying depth-0 forward_F obstruction. F-eventuality discharge (`F(psi) in chain(n)` -> witness `s > n` with `psi in chain(s)`) is required even without Until. The BX11 perpetual deferral problem is about F-formulas, not U/S specifically. Without Until, F would need to be primitive, and the same chain construction problem applies.

**Blast radius**: Removing U/S destroys ~800-1200 LOC of sorry-free infrastructure including `hintikka_chain_exists`, SubformulaClosure temporal closure properties (155 LOC proved in Round 36), BX12 bridge lemmas, and the entire quasimodel oracle construction path.

**Verdict**: Net negative. 2/3 reachable sorries become vacuous but new F/P coherence sorries replace them, the core blocker persists, and the solution path is destroyed.

### 3. Strict G/H Semantics Would Actively Hurt (Unanimous, HIGH confidence)

The current reflexive G (`forall s, t <= s -> ...`) is essential to the proof infrastructure:
- **BX1** (`G(phi) -> phi`) is valid only under reflexive semantics and used throughout
- **BX4** (`phi -> P(F(phi))`) depends on reflexivity (`t <= t`)
- **bx_le reflexivity** (`g_content(M) subset M` from BX1) underpins the entire Frame.lean infrastructure
- **The Boneyard directory** `StrictSemanticsLegacy/` contains direct evidence: strict semantics was tried and abandoned

Switching to strict G/H would invalidate ~2000+ LOC of active-path code, require redesigning the axiom system (drop BX1, modify BX8), and would NOT eliminate the forward_F obstruction.

### 4. The Real Problem: BX11 Fold Chain Construction (Unanimous, HIGH confidence)

**Root cause diagnosis**: The `enriched_fwd_step` (BX11 fold) only guarantees "some formula resolves at each step" -- not that any specific formula is ever resolved. This is a non-standard technique not found in any temporal logic completeness literature (Burgess 1984, Reynolds 2003, Gabbay-Hodkinson-Reynolds 1994).

**The fix is already proved**: `self_resolving_fwd_step` (RootScopedChain.lean:1961-1996) given `F(psi) in M`, directly places `psi in M'` with F-persistence and g_content propagation. Fully sorry-free. `defect_bwd_step` (lines 1717-1764) is the symmetric backward primitive. Also sorry-free.

**Literature alignment**: The standard technique (Burgess, Reynolds, GHR) uses deterministic round-robin scheduling -- enumerate eventualities, cycle through them, resolve each at its turn. This maps directly to `self_resolving_fwd_step`.

### 5. Path Forward: Plan v37 With Round-Robin Chain Fix (B, C, D)

The plan architecture (oracle + quasimodel-backed BFMCS) is correct. The specific implementation should:

1. **Priority 1**: Close `dd_bfmcs_restricted_tc` (line 1517) directly using already-proved G/H propagation lemmas -- simplest sorry, ~50-100 LOC
2. **Priority 2**: Replace eventuality chains with round-robin using `self_resolving_fwd_step` -- closes 5 dead-code sorries (1413, 1457, 1464, 2196, 2289)
3. **Priority 3**: Build oracle + quasimodel BFMCS for Until/Since coherence -- closes buc (1522) and fuc (1527)
4. **Priority 4**: Fix `defect_bwd_chain` non-resolving step (~20 LOC quick win)

Estimated remaining effort: 600-900 LOC, 1-2 implementation rounds.

## Synthesis

### Conflicts Resolved

**Conflict 1**: Teammate A says removing U/S eliminates 2/3 sorries (buc, fuc become vacuous). Teammate C says this gives no net simplification because new F/P coherence sorries replace them.

**Resolution**: Both are technically correct. A correctly identifies that the specific buc/fuc predicates become vacuous. C correctly identifies that the remaining tc sorry (plus new F/P coherence obligations) require the same eventuality discharge mechanism. The net effect is that removing U/S changes the problem surface without reducing the core difficulty. Combined with the ~800-1200 LOC blast radius and paper constraint, this path is clearly negative-ROI.

**Conflict 2**: Teammate A identifies `defect_fwd_step_choice_singleton` (line 2161-2170) as a potential path for fuc. Teammate B recommends full round-robin chain replacement. Teammate D recommends oracle + quasimodel.

**Resolution**: These are complementary, not competing. The singleton path is a special case of the round-robin approach. The oracle/quasimodel path addresses buc/fuc coherence which requires structural Until propagation beyond what round-robin alone provides. Priority ordering: tc first (quick win), then round-robin chains (eventualities), then oracle (coherence).

### Gaps Identified

1. **Plan v37 Phase 1 blocker**: The extended seed consistency proof was blocked in the implementation attempt (Round 37 summary). The G-lift technique fails for seeds containing Until formulas. This specific proof engineering challenge is not addressed by any language change -- it requires a novel consistency argument within the existing framework.

2. **Backward Until coherence**: The step-transfer property `(phi U psi) in chain(n+1) AND phi in chain(n) -> (phi U psi) in chain(n)` remains unproved. Teammates A and B suggest BX5+BX6 (self-accumulation + absorption) may provide this, but no concrete proof sketch is given. This is the key remaining mathematical question.

3. **Int extension**: Converting finite quasimodel chains to Int-indexed FMCS has not been attempted. Teammate D estimates 200-400 LOC.

### Recommendations

1. **Do not change the language or semantics** -- the question is definitively answered
2. **Execute Plan v37** with the priority ordering from Finding 5
3. **Start with `dd_bfmcs_restricted_tc`** (line 1517) as a quick win to build momentum
4. **Mark `enriched_fwd_step` / BX11-fold approaches as dead code** to prevent future research waste
5. **Focus the next implementation attempt** on the seed consistency proof for the oracle, using the insight that `self_resolving_fwd_step` avoids the BX11 fold entirely

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: S/U and strict/weak analysis | completed | high |
| B | Alternative proof systems and literature | completed | high |
| C | Critic: gaps and blind spots | completed | high |
| D | Strategic horizons and project alignment | completed | high |

## References

### Literature
- Burgess (1982/1984): Axioms for Tense Logic I: "Since" and "Until"
- Reynolds (2003): Axiomatization of full computation tree logic
- Gabbay-Hodkinson-Reynolds (1994): Temporal Logic: Mathematical Foundations
- Finger-Gabbay (1996): Combining Temporal Logic Systems
- Marx-Venema (1997): Multi-Dimensional Modal Logic

### Codebase
- `Theories/Bimodal/Syntax/Formula.lean` -- Formula type with U/S constructors
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- 37 BX axioms
- `Theories/Bimodal/Semantics/Truth.lean` -- Reflexive G/H semantics
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Sorry sites
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` -- Sorry-free quasimodel framework
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- Sorry-free witnesses

### Prior Reports
- specs/093_complete_bxcanonical_embedding/reports/37_team-research.md (round 37)
- specs/093_complete_bxcanonical_embedding/reports/17_round-robin-chain-history.md (19 failed approaches)
- specs/093_complete_bxcanonical_embedding/summaries/37_bxcanonical-embedding-summary.md (Phase 1 blockers)
