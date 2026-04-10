# Teammate C (Critic) Findings: Task 89

## Key Findings

### 1. The 4 Frame.lean Sorries Are Accurately Described

Verified: Frame.lean contains exactly 4 `sorry` tactics at lines 653, 675, 690, 704, corresponding to the four named definitions in the task description:
- `bx_until_eventuality_resolution` (line 632, sorry at 653)
- `bx_until_backward` (line 664, sorry at 675)
- `bx_since_eventuality_resolution` (line 683, sorry at 690)
- `bx_since_backward` (line 697, sorry at 704)

Line numbers match the task description (which cited 653, 675, 690, 704). No drift from task 88's deletion of CanonicalEmbedding.lean -- that file was in the same directory but its removal did not shift these line numbers (separate file).

### 2. The "Completeness.lean:160 Closes Automatically" Claim Is MISLEADING

The task description says "Completeness.lean:160 closes automatically when these 4 are resolved." This is **seriously misleading**:

- **BXCanonical/Completeness.lean:154** has a sorry for `bx_completeness`. This sorry depends on the 4 Frame.lean sorries *but also* on additional unsolved problems: building a canonical TaskModel from BXPoints and proving G/H truth lemma cases that require "non-constant histories visiting multiple BXPoints" (per the comment at line 150).
- Closing the 4 Frame.lean sorries would resolve the Until/Since cases of the truth lemma (TruthLemma.lean references all 4), but **not** the completeness sorry itself.
- The BXCanonical completeness is furthermore a **separate module** from the main `completeness_over_Int` path. It is imported only by `Metalogic.lean` as a library module -- it is NOT on the critical path described in ROAD_MAP.md.

**The main critical path** runs through `dovetailed_bundle_validity_implies_provability` in `FrameConditions/Completeness.lean`, which has its own sorries at lines 491-498 (step transfer + forward Until/Since coherence). These are **completely different sorries** from the BXCanonical Frame.lean ones.

### 3. The BXCanonical Module Is NOT on the Critical Completeness Path

ROAD_MAP.md clearly states the critical path is:
```
completeness_over_Int
  -> dovetailed_bundle_validity_implies_provability
       -> backward_until/since_coherent (sorry: step transfer)
       -> forward_until_since_coherent (sorry)
```

The BXCanonical module (`Frame.lean`, `TruthLemma.lean`, `Completeness.lean`) is a **parallel, independent** canonical model construction. Its 4 Frame.lean sorries and 1 Completeness.lean sorry represent a **different approach** to completeness -- the "direct BXPoint canonical frame" approach vs. the "dovetailed chain + restricted coherence" approach that ROAD_MAP.md identifies as active.

**Critical question**: Why are we investing 40-80 hours on a non-critical-path module?

### 4. The X-vs-G Mismatch Analysis

The task claims the X-vs-G mismatch is "confirmed fundamental (6 rounds, 99% confidence)." Let me scrutinize this:

**What's well-established**: `phi U psi in w` does NOT imply `G(phi U psi) in w`. No single axiom achieves this. The reasoning is sound: `G` distributes over conjunction (from BX1+temp_4+necessitation) but Until is not conjunction.

**What's NOT established rigorously**: Whether a *non-obvious multi-step derivation* combining BX4 (`phi -> G(P(phi))`), BX5 (self-accumulation), BX7 (linearity), and BX10 (`phi U psi -> F(psi)`) could achieve the needed propagation. The dead-end documentation describes failed *proof strategies*, not formal impossibility proofs.

**A true countermodel argument would look like**: Construct two MCS w, v with `bx_le w v` (i.e., `g_content(w) subset v`) where `phi U psi in w`, `psi notin w`, but the guard fails at some intermediate u. Such a countermodel would definitively prove the 4 sorries are not closable by pure MCS reasoning alone. I found no such countermodel in the documentation.

**However**: The practical evidence is strong. 12 dead ends across 6+ months of investigation is compelling empirical evidence. The mismatch between g_content-based ordering (universal quantification over G-formulas) and Until witnesses (existential eventuality resolution) is a genuine structural gap in canonical model theory for Until/Since logics. This is well-known in the literature -- Burgess (1984) uses Until-induction specifically to bridge this gap.

### 5. Are the 12 Dead Ends Really Dead?

Reviewed each dead end in ROAD_MAP.md:

| # | Dead End | Truly Dead? | Notes |
|---|----------|-------------|-------|
| 1 | CoherentZChain | Yes | Forward/backward asymmetry is fundamental |
| 2 | f_preserving_seed sub-case A | Yes | Vacuous implication, no contradiction extractable |
| 3 | omega_true_dovetailed_forward_F | Yes | Lindenbaum freedom is genuine |
| 4 | Bundle-level temporal coherence | Yes | G/H are single-history by definition |
| 5 | Fuel-based recursion | Yes | Persistence count unbounded even for bounded formula set |
| 6 | Bidirectional Temporal Witness | Yes | H-theory not G-liftable |
| 7 | Combined F-seed chain | Yes | G doesn't distribute over disjunction |
| 8 | Constant-history canonical | Yes | G collapses to identity -- provably impossible |
| 9 | Flatten reduction | Yes | alpha doesn't imply G(alpha) for non-theorems |
| 10 | FMP bridge | Mostly | FMP gives decidability, not representation theorem |
| 11 | Proof-theoretic Case B | Yes | Contextual necessitation gap is real |
| 12 | Constant-history CanonicalEmbedding | Yes | Subsumed by #8 |

**Observation**: Dead ends 8 and 12 are essentially the same blocker. Dead ends 3 and 7 both stem from Lindenbaum extension freedom. The 12 "dead ends" are really about 8-9 distinct obstacles. This doesn't change the conclusion, but inflates the count.

**Could any be revived?** Dead end #10 (FMP bridge) is the most interesting. The FMP module is sorry-free and gives decidability. While it cannot directly give the representation theorem, one could potentially use FMP to establish completeness-as-a-fact and separately pursue the canonical model for structural reasons. This reframing would change the task scope.

## Gaps Identified

### Gap 1: BXCanonical vs Main Path Confusion

The task description does not mention that BXCanonical is an independent module from the main completeness path. Someone reading the task could reasonably think these 4 sorries are blocking the main `completeness_over_Int` result. They are not. The main completeness has its own Until/Since coherence sorries in `FrameConditions/Completeness.lean:491-498`.

### Gap 2: Closing Frame.lean Does Not Close BXCanonical/Completeness.lean

Even if all 4 Frame.lean sorries are closed, BXCanonical/Completeness.lean:154 requires:
1. A canonical TaskModel construction embedding BXPoints into a TaskFrame
2. G/H truth lemma for non-constant histories
3. The 4 eventuality resolution lemmas (Frame.lean sorries)

Only (3) is addressed by task 89. Items (1) and (2) are unmentioned in the task.

### Gap 3: No Formal Impossibility Proof for X-vs-G Mismatch

The "99% confidence" claim is based on failed attempts, not a formal proof. A countermodel (two MCS with appropriate properties) would make this 100%.

### Gap 4: Quasimodel/Henkin Approach Not Validated

The task title mentions "quasimodel or Henkin construction" but no research has validated whether these approaches work for this specific axiom set (BX1-BX12 with reflexive Until/Since). Quasimodel constructions (GHR 1994) typically apply to different temporal operators.

### Gap 5: Since Cases Are Mirror of Until but Not Verified

The task assumes `bx_since_eventuality_resolution` and `bx_since_backward` are exact mirrors. While the axiom set has Since mirrors (BX4', BX5', etc.), the proof infrastructure (h_content vs g_content) needs verification. Past-direction arguments sometimes differ subtly due to asymmetric definitions.

## Assumptions Challenged

### "These sorries should be prioritized"

**Challenge**: These 4 sorries are in BXCanonical, which is NOT on the main completeness path. The main path (`completeness_over_Int` via dovetailed chains) has its own 3 sorries in `FrameConditions/Completeness.lean:491-498`. If the goal is "zero sorries on the completeness path" (as stated in TODO.md), task 89 does not advance that goal.

**Possible counter**: BXCanonical may represent a *cleaner* or *more publishable* completeness proof, worth developing independently. But the task description doesn't make this case.

### "40-80 hours is a reasonable estimate"

**Challenge**: Given 12 dead ends over 6+ months, and the task proposing approaches (quasimodel, Henkin) that haven't been validated for this axiom system, 40-80 hours seems optimistic. The research spike alone (4-8h) could reveal another dead end. A more honest estimate might be 40-80 hours *if the approach works*, with a 30-50% probability of needing yet another approach.

### "Completeness.lean:160 closes automatically"

**Challenge**: This is false. Line 160 in BXCanonical/Completeness.lean is `bx_completeness' φ h`, which calls `bx_completeness` at line 124, which has a sorry at line 154. That sorry requires TaskModel construction and G/H truth lemma beyond the 4 Frame.lean sorries.

### "Independent of task 88"

**Challenge**: Correct -- task 88 deleted CanonicalEmbedding.lean which was separate. But the task IS dependent on the BX axiom system being correct and complete for the intended semantics. If the axiom system is incomplete (which is NOT ruled out by the dead-end analysis), these sorries may be unprovable.

## Questions That Should Be Asked

1. **Why is BXCanonical being prioritized over the main dovetailed chain path?** The main completeness theorem (`completeness_over_Int`) goes through `FrameConditions/Completeness.lean`, not BXCanonical. What is the strategic value of closing BXCanonical sorries?

2. **Are the BX axioms (BX1-BX12) actually complete for the intended semantics?** Has a manual completeness proof been verified in the literature for this exact axiom set with reflexive Until/Since? If not, these sorries might be *mathematically* unprovable.

3. **Should this task be merged with or coordinated with the main completeness path?** The `forward_until_since_coherent` sorry in `FrameConditions/Completeness.lean:498` is the same fundamental problem (Until/Since eventuality resolution) but in a different technical context (dovetailed chains vs BXPoints). A solution to one might inform the other.

4. **What is the relationship between `bx_le` linearity and Until eventuality resolution?** The Frame.lean comments suggest bx_le linearity is needed. Is this actually true, or is it an artifact of the specific proof strategy? Could the guard quantification be weakened?

5. **Has anyone checked whether BX6 (absorption) + BX7 (linearity) together give a form of Until-induction?** BX6 prevents infinite deferral, BX7 linearizes competing eventualities. Their combination might yield an induction principle sufficient for the guard propagation, even without a named "Until-induction" axiom.

6. **Is there a finite model property argument that bypasses the canonical construction entirely?** The FMP module is sorry-free. Could the BXCanonical completeness be established via FMP + transfer, avoiding the canonical model construction?

## Confidence Level

**Overall confidence in the task as described: LOW (35%)**

- The task correctly identifies 4 real sorries at accurate line numbers.
- The task seriously misleads about downstream impact (Completeness.lean:160 does NOT close automatically).
- The task does not acknowledge that BXCanonical is off the main completeness path.
- The proposed approaches (quasimodel/Henkin) are unvalidated for this setting.
- The effort estimate is optimistic given the history of dead ends.
- The strategic value proposition is unclear: why invest 40-80h on a non-critical module?

**Recommendation**: Before investing implementation effort, the task description should be corrected to:
1. Acknowledge BXCanonical is a separate module from the main completeness path
2. Remove the false claim about Completeness.lean:160
3. Articulate the strategic value (e.g., "cleaner completeness proof for publication" vs "blocking the main completeness result")
4. Consider whether the 40-80h would be better spent on the 3 sorries in `FrameConditions/Completeness.lean:491-498` which ARE on the critical path
