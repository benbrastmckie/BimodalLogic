# Research Report: Task #86 — Close BXCanonical Completeness Sorries

**Task**: 86 — Close BXCanonical completeness sorries via Until-witness ordering or FMP bridge
**Date**: 2026-04-08
**Mode**: Team Research (3 teammates, Opus model)
**Session**: sess_1775687052_a4931b

## Executive Summary

Three teammates investigated the two proposed approaches (Until-witness bx_le redefinition, FMP bridge) plus critical analysis and novel approaches. **Both original approaches are non-viable**, but the research uncovered **three alternative paths** ranked by confidence:

1. **Fragment completeness** (80% confidence): Prove completeness for the {⊥, →, □, G, H}-fragment, avoiding Until/Since entirely. G/H/Box truth lemma is already proved.
2. **Decidability route** (60% confidence): If the decision procedure is sorry-free, then soundness + decidability = completeness. Avoids canonical models entirely.
3. **Derive Until-induction from BX5+BX6+BX7** (confidence varies): A purely proof-theoretic challenge. If successful, closes all 4 Frame.lean sorries via the standard Burgess proof technique.

## Key Findings

### 1. bx_le Redefinition Is NOT Viable (ALL teammates, HIGH confidence)

The G truth lemma at `TruthLemma.lean:124-132` FORCES bx_le to be equivalent to g_content inclusion:
- `bx_G_forward` (Frame.lean:192-195) IS LITERALLY `h_le h_G` — the definition of bx_le
- The backward direction constructs witnesses via Lindenbaum on `{¬φ} ∪ g_content(w)`, producing MCS that satisfy bx_le by construction
- Any redefinition must be provably equivalent, providing zero benefit
- Redefining would break 300+ lines of proved G/H/Box truth lemma infrastructure

**Verdict**: Approach 1 from the task description is definitively ruled out.

### 2. FMP Bridge Is NOT Viable (Teammates B and C, HIGH confidence)

The FMP path has 0 sorries but operates entirely at MCS-membership level, not semantic-model level:
- `fmp_completeness` (Correctness.lean:100-103) proves: `(∀ S : ClosureMCSBundle φ, φ ∈ S.carrier) → Nonempty (DerivationTree [] φ)` — this is MCS-completeness, NOT semantic completeness
- Bridging to `valid φ → provable φ` requires a truth lemma connecting MCS membership to `truth_at` — which requires the SAME Until/Since eventuality resolution that blocks BXCanonical
- An FMP bridge would need MORE code than closing BXCanonical directly (canonical TaskModel construction + WorldHistory + Omega/ShiftClosed construction on top of the same Until/Since work)
- TruthPreservation.lean handles bot/negation/implication/box/G/H but has NO Until/Since lemmas at all

**Verdict**: Approach 2 from the task description is definitively ruled out as primary. FMP has value for decidability (already realized) but not for bypassing the Until/Since problem.

### 3. The Problem Reduces to TWO Root Blockers (Teammate C, HIGH confidence)

The 5 sorry sites have a clear dependency structure:
- **Root blocker 1**: `bx_until_eventuality_resolution` (Frame.lean:562) — forward Until
- **Root blocker 2**: `bx_until_backward` (Frame.lean:584) — backward Until
- **Mirror 1**: `bx_since_eventuality_resolution` (Frame.lean:599) — mirror of root 1
- **Mirror 2**: `bx_since_backward` (Frame.lean:613) — mirror of root 2
- **Downstream**: `bx_completeness` (Completeness.lean:144) — depends on all 4 above

Closing root blockers 1-2 automatically closes mirrors 3-4 (by symmetry). Sorry #5 requires additional model embedding work even if #1-4 are closed.

### 4. The Fundamental Obstacle Is g_content/Until Mismatch (ALL teammates)

All three teammates independently confirmed the same root cause: `φ U ψ ∈ w` does NOT imply `G(φ U ψ) ∈ w`, so Until formulas do not propagate forward through the g_content ordering (bx_le). BX4 gives `G(P(φ U ψ)) ∈ w`, meaning `P(φ U ψ) ∈ u` for all `u ≥ w`, but P gives a BACKWARD witness — we lose control of where the witness is.

This is the identical obstacle identified across tasks 83, 84, and 85. The BXCanonical architecture doesn't escape it; it merely reformulates it in terms of bx_le ordering.

### 5. Until-Induction Is the Missing Piece (Teammate A, MEDIUM-HIGH confidence)

The standard Burgess/Goldblatt completeness proof uses Until-induction as a primitive axiom:
```
G(ψ → χ) ∧ G((φ ∧ X(χ)) → χ) → ((φ U ψ) → χ)
```
This was removed in the BX refactoring and replaced by BX5 (self-accumulation) + BX6 (absorption) + BX7 (linearity). These three axioms are semantically equivalent to Until-induction on linear orders, so Until-induction IS derivable from BX5+BX6+BX7 in principle. However, no derivation has been carried out.

**Note**: Under reflexive semantics, X(α) = α (as proved in task 85), so Until-induction simplifies to:
```
G(ψ → χ) ∧ G((φ ∧ χ) → χ) → ((φ U ψ) → χ)
```
which is: "if ψ implies χ everywhere, and φ∧χ implies χ everywhere, then (φ U ψ) implies χ." This is a form of temporal induction without next-step operators.

### 6. Fragment Completeness Is 80% Viable NOW (Teammate C)

The G/H/Box truth lemma is ALREADY complete in BXCanonical:
- `G_iff_mcs` — proved
- `H_iff_mcs` — proved
- `box_iff_mcs` — proved
- `atom_iff_mcs`, `bot_iff_mcs`, `imp_iff_mcs` — proved

Completeness for the {⊥, →, □, G, H}-fragment only requires the model embedding (sorry #5), NOT the Until/Since eventuality resolution (sorries #1-4). This gives a partial but mathematically valuable result as a stepping stone.

### 7. Decidability Route May Give Full Completeness (Teammate C, 60% confidence)

If the decision procedure in `Decidability/DecisionProcedure.lean` is sorry-free:
- Soundness: `⊢ φ → ⊨ φ` (sorry-free, proved)
- Decidability: for any φ, either `⊢ φ` or `⊢ ¬φ` (need to verify)
- Completeness follows: if `⊨ φ` and `¬⊢ φ`, then by decidability `⊢ ¬φ`, by soundness `⊨ ¬φ`, contradicting `⊨ φ`

**This needs investigation**: check whether DecisionProcedure.lean is sorry-free and whether decidability is stated in the right form.

## Synthesis

### Conflicts Resolved

#### Conflict 1: Primary Recommendation

| Teammate | Recommendation |
|----------|---------------|
| A | Derive Until-induction from BX5+BX6+BX7, falling back to re-adding it as axiom |
| B | Do not pursue FMP bridge; focus on BXCanonical directly |
| C | Fragment completeness (80%), then decidability route (60%) |

**Resolution**: All three agree the two original approaches (bx_le redefine, FMP bridge) are dead. The disagreement is on what to do instead:
- Teammate A's suggestion (derive Until-induction) is the mathematically purest but hardest path
- Teammate C's suggestions (fragment completeness, decidability route) are pragmatic stepping stones
- These are COMPLEMENTARY, not conflicting: fragment completeness now, decidability investigation, then Until-induction derivation for the full result

### Gaps Identified

1. **Decidability status not verified** — DecisionProcedure.lean sorry count is unknown. This is the highest-priority investigation.
2. **Model embedding (sorry #5)** is needed for fragment completeness even without Until/Since. No teammate attempted this.
3. **Until-induction derivability from BX5+BX6+BX7** is an open proof-engineering challenge with no prior attempt.

## Recommendations (Priority Order)

### 1. IMMEDIATE: Audit DecisionProcedure.lean (1 hour)

Check if `Decidability/DecisionProcedure.lean` is sorry-free. If yes, `soundness + decidability = completeness` gives FULL completeness as a ~100-line composition, bypassing ALL canonical model sorries. This is the highest-ROI investigation.

### 2. SHORT-TERM: Fragment Completeness for {⊥, →, □, G, H} (4-8 hours)

Prove completeness for the temporal-modal fragment without Until/Since. Requires:
- Constructing canonical TaskModel from BXPoints (sorry #5)
- Using existing G/H/Box truth lemma (already proved)
- Independent mathematical value as first mechanized completeness for S5+tense logic

### 3. MEDIUM-TERM: Derive Until-Induction from BX5+BX6+BX7 (8-16 hours)

Purely proof-theoretic challenge. If successful, closes all 4 Frame.lean sorries via standard Burgess technique. Fallback: re-add Until-induction as axiom (sound, pragmatic).

### 4. DO NOT PURSUE

- **bx_le redefinition**: Breaks G/H infrastructure, zero benefit (forced by definition)
- **FMP bridge**: Same Until/Since obstacle plus more work
- **Algebraic completeness**: Stale infrastructure, high cost
- **Direct proof of Frame.lean sorries**: Structurally blocked by g_content/Until mismatch

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|-----------------|
| A | Until-witness bx_le redefinition | completed | Proved bx_le redefinition forced by G truth lemma; identified Until-induction as key missing piece; provided Zorn-based proof sketch (blocked) |
| B | FMP bridge to completeness | completed | Proved FMP operates at MCS-membership not semantic level; confirmed 0 FMP sorries; showed bridge requires SAME Until/Since work plus more |
| C | Critical analysis + novel paths | completed | Sorry census (5 BXCanonical, 0 FMP, 0 Soundness); fragment completeness path (80%); decidability route (60%); proved direct proof structurally blocked |

## References

### Key Files
- `BXCanonical/Frame.lean:541-613` — 4 sorry sites (root blockers + mirrors)
- `BXCanonical/Completeness.lean:144` — 1 sorry (model embedding)
- `BXCanonical/TruthLemma.lean:124-132` — G truth lemma (forces bx_le = g_content)
- `Decidability/FMP/Correctness.lean:100-103` — fmp_completeness (MCS-completeness)
- `Decidability/DecisionProcedure.lean` — NOT YET AUDITED
- `Metalogic/Soundness.lean` — sorry-free soundness
- `ProofSystem/Axioms.lean:177-184` — BX7 linearity axiom

### Prior Research
- Task 85 reports 01 (team: x_content triviality, Burgess-Xu 4 invalid) and 02 (X/Y archival)
- Task 83 report 24 (quasimodel study), 30 (pull-before-push), 35 (Burgess-Xu 4 — now invalidated)
- Task 84 report 04 (G-lift incompatibility — definitive)
