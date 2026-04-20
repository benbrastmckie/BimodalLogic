# Research Report: Task #93 — Round 47, Teammate A

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Role**: Teammate A — IRR rule deep analysis
**Session**: sess_1776640395_teammate_a_47

---

## Key Findings

### Finding 1: The Current System Does NOT Use IRR (High Confidence, 95%)

The current proof system (`DerivationTree` in `ProofSystem/Derivation.lean`) has exactly **7 inference rules**:
1. `axiom`
2. `assumption`
3. `modus_ponens`
4. `necessitation`
5. `temporal_necessitation`
6. `temporal_duality`
7. `weakening`

There is **no IRR rule** in the base system. The IRR rule lives only in `ConservativeExtension/ExtDerivation.lean` which defines `ExtDerivationTree` — a SEPARATE extended proof system used exclusively for conservative extension proofs, not for BXCanonical completeness.

The `ConservativeExtension/` directory appears to be dead-weight infrastructure: it contains sorry sites for axioms that were "removed in BX" (e.g., `temp_a`, `temp_l`, `density`, `seriality_future`, `seriality_past`) — indicating this module was written for an older axiom system and was never updated to match the current BX axiom set. There are at least 25 `sorry` sites in this module.

### Finding 2: The IRR Rule As Stated (GHR 1994) Does NOT Apply to Reflexive G/H Semantics

The IRR rule from GHR 1994 (Gabbay-Hodkinson-Reynolds) is:
> If ⊢ G(p → Gp) → G(p → ψ), then ⊢ G(p → ψ), where p is fresh

The key precondition `G(p → Gp)` says: atom p, if it ever holds, holds at ALL future times. This characterizes p as a "permanent" atom.

**The IRR rule resolves irreflexivity**: It proves that the CANONICAL model is irreflexive (M ≠ N in `CanonicalR M N`) by constructing a fresh atom p that distinguishes M from its successor. This is needed when G is STRICT (quantifies over s > t), because `g_content(M) ⊆ M` (i.e., `G(phi) ∈ M → phi ∈ M`) is NOT derivable without T-axiom.

Under the CURRENT reflexive semantics:
- `G(phi) ∈ M → phi ∈ M` IS derivable via `temp_t_future` (the T-axiom BX1)
- The canonical relation is REFLEXIVE: `CanonicalR M M` holds by T-axiom
- There is NO irreflexivity gap to close
- **The IRR rule is therefore unnecessary for the current system**

The Lean code explicitly confirms this in `Metalogic.lean`:
> "Under reflexive semantics, G and H quantify over `s ≥ t` and `s ≤ t` respectively (including the current time). This makes the canonical accessibility relation REFLEXIVE: `canonicalR_reflexive` is proven via T-axiom."

### Finding 3: The User's Prior IRR Attempt Was Task 29 (High Confidence, 95%)

The notes in `typst/chapters/06-notes.typ` document the exact history:
```
Task 29: Reflexive (≤) — "IRR proof broken under strict; theoretical analysis"
```

The IRR rule was attempted under strict semantics WITHOUT U/S. The switch to reflexive semantics (which we have now) was specifically motivated by the failure of the IRR approach, along with the mathematical impossibility result from Task 658: "the indexed family construction requires G(phi) → phi for forward coherence; without T-axioms, independent Lindenbaum extensions have no provable coherence."

### Finding 4: Switching to Irreflexive Semantics Would Break the Entire Foundation

The typst notes document a crucial mathematical impossibility:
> "Task 658: independent Lindenbaum extensions cannot be proven coherent without the T-axiom. This is not a proof difficulty — it is a mathematical impossibility."

Under irreflexive semantics (G quantifies over s > t):
- `g_content(M) ⊆ M` is NOT derivable (no T-axiom)
- Forward temporal coherence (F(phi) ∈ M → ∃ s > t, phi ∈ fam.mcs s) cannot be proved using independent Lindenbaum extensions
- The entire `restricted_temporally_coherent` notion would need to be reproved
- All 37 axioms in BX would need their validities reproved under strict semantics
- The axioms BX1 (`temp_t_future`) and BX1' (`temp_t_past`) would become INVALID

The irreflexive system would require:
1. Removing BX1/BX1' (T-axioms for G/H) — they are false under strict semantics
2. Adding seriality axioms (F(top), P(top)) — needed since G(phi) → phi fails
3. Three separate completeness theorems (Base/Dense/Discrete) instead of one
4. Adding the IRR rule to the proof system
5. Reproving ALL soundness results for 37 axioms
6. Reproving temporal coherence without T-axiom

This is estimated at 2000+ LOC of changes and would discard most of the existing 2000+ LOC of sorry-free infrastructure.

### Finding 5: Irreflexive Semantics is "More Expressive" in a Specific Sense

The claim that irreflexive semantics is "more expressive" is technically correct but nuanced:
- Under irreflexive semantics: axioms DN, SF, SP, DF genuinely correspond to frame properties (density, seriality, discreteness)
- Under reflexive semantics: all four axioms are trivially valid (no frame separation)
- So "more expressive" means: **the proof system can axiomatically distinguish frame classes** (dense vs discrete vs base)

However, for the TM project's goal of completeness for a fixed logic, this additional expressiveness is irrelevant: we want one completeness theorem, not three. The reflexive system's "frame class collapse" is a feature for proof engineering (as the notes explicitly state).

### Finding 6: The 5 Sorry Sites Are Structural, Not Axiom Gaps

Reading `RootScopedChain.lean` lines 1090–1160, the 5 sorry sites are:

| Location | Theorem | Root Cause |
|----------|---------|-----------|
| Line 1111 | `fwd_chain_forward_F` | BX11 fold resolves opaque witness; no finite termination argument |
| Line 1138 | `dd_bfmcs_restricted_tc` (backward case) | Backward chain lacks symmetric preserving-step infrastructure |
| Line 1145 | `dd_bfmcs_restricted_tc` (P case) | Same as above |
| Line 1153 | `dd_bfmcs_restricted_buc` | Until/Since transfer requires deterministic step (g-content-only chains) |
| Line 1160 | `dd_bfmcs_restricted_fuc` | Depends on restricted_tc + Until propagation (BX10/BX12) |

None of these are axiom gaps that the IRR rule would address. The IRR rule closes the IRREFLEXIVITY gap in canonical models; these sorry sites are about TEMPORAL COHERENCE of Int-indexed chains. These are entirely different proof obligations.

---

## Recommended Approach

**Do NOT switch to irreflexive semantics.** This would:
1. Invalidate BX1/BX1' (T-axioms), which are used throughout the codebase
2. Require reproving 37+ soundness theorems
3. Require the IRR rule in the proof system (major surgery)
4. Require 3 completeness theorems instead of 1
5. Not address the actual sorry sites (temporal chain coherence)

**Do NOT attempt IRR under the current reflexive system.** The IRR rule addresses irreflexivity, which is already solved by the T-axiom. Applying IRR here would be solving the wrong problem.

**The actual problem is temporal chain coherence.** The 5 sorry sites are blocked by the architecture of the `dd_chain` construction:
- `fwd_chain_forward_F`: opaque BX11 witness means no termination argument
- `restricted_tc` backward direction: no `preserving_bwd_step`
- `restricted_buc/fuc`: need Until-step transfer property not provided by Lindenbaum chains

The best path forward (consistent with round 46 synthesis) is one of:
- **Quasimodel chain concatenation**: Use the sorry-free `Construction.lean` (887 LOC) and `OracleStep.lean` infrastructure already built
- **Goldblatt-style restructure**: Use the full canonical frame rather than a single Int-indexed chain

---

## Evidence/Examples

### Evidence A: IRR Is In ConservativeExtension Only (Dead Code Path)
`ConservativeExtension/ExtDerivation.lean` line 82-83:
> "Includes all inference rules from the base system plus the IRR rule with `ExtAtom` (allowing `Sum.inr ()` as the fresh atom)."

But `ExtDerivationTree` is NEVER imported by `BXCanonical/`. Confirmed by checking imports in `RootScopedChain.lean` — no `ConservativeExtension` import.

### Evidence B: Prior IRR Attempt History
`typst/chapters/06-notes.typ` table at line ~305:
```
Task 29 | Reflexive (≤) | "IRR proof broken under strict; theoretical analysis"
```

### Evidence C: Reflexive Semantics Solves Canonical Reflexivity
`Metalogic.lean` preamble:
> "REFLEXIVE: `canonicalR_reflexive` is proven via T-axiom."

`TemporalCoherence.lean` line 306:
```lean
theorem BFMCS.temporally_coherent_implies_restricted (B : BFMCS D) (root : Formula)
    (h_tc : B.temporally_coherent) : B.restricted_temporally_coherent root
```
This theorem already exists — restricted coherence follows from full coherence. The problem is proving full (or restricted) coherence for the `dd_chain` construction.

### Evidence D: Mathematical Impossibility Without T-Axiom
`typst/chapters/06-notes.typ` (Task 658 entry):
> "The decisive finding (Task 658): independent Lindenbaum extensions cannot be proven coherent without the T-axiom. This is not a proof difficulty — it is a mathematical impossibility."

### Evidence E: BX1/BX1' Are Load-Bearing
`ProofSystem/Axioms.lean` lines 115-123:
```lean
/-- BX1: Temporal T (future): `G(φ) → φ` (reflexivity of future). -/
| temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)

/-- BX1': Temporal T (past): `H(φ) → φ` (reflexivity of past). -/
| temp_t_past (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)
```

These appear in soundness proofs and are used in `qm_oracle_seed_subset_mcs` (OracleStep.lean line 76) to prove the oracle seed is a subset of the current MCS.

---

## Confidence Level

- **Finding 1** (IRR not in base system): High, 95% — directly confirmed by reading `Derivation.lean`
- **Finding 2** (IRR does not apply to reflexive semantics): High, 95% — follows from T-axiom + canonical reflexivity
- **Finding 3** (prior attempt was Task 29): High, 95% — documented in `06-notes.typ`
- **Finding 4** (switching semantics would break everything): High, 90% — follows from mathematical impossibility result Task 658 + code impact analysis
- **Finding 5** (irreflexive = more expressive in specific sense): Medium, 80% — standard result in tense logic
- **Finding 6** (sorry sites are structural, not axiom gaps): High, 90% — confirmed by reading each sorry site

**Overall assessment**: Switching to irreflexive semantics is NOT recommended. The IRR rule does not address the actual sorry sites. The blockers are architectural (Int-indexed chain temporal coherence) and require a different construction strategy.
