# Teammate A: CanonicalR Usage Audit

## Summary Statistics

- Total files with CanonicalR (word-boundary): 49 non-Boneyard files
- Boneyard files: 6 (noted, not deeply analyzed)
- **Definitional**: 1 file (`CanonicalFrame.lean` — defines `CanonicalR` and `ExistsTask` alias)
- **Structural/Infrastructure**: ~12 files (define CanonicalR-based ordering, transitivity, irreflexivity)
- **Genuinely ExistsTask** (existential accessibility — "there exists a path"): ~22 files
- **Naturally Succ** (immediate one-step, first condition of Succ): ~8 files
- **Naturally CanonicalTask** (multi-step chains, transitive closure): ~6 files
- **Comment/Doc only** (no code usage): ~3 files

**Overall confidence: HIGH** for the definitional layer and structural layer. **MEDIUM** for the upper-level staging files where CanonicalR serves multiple roles.

---

## Core Semantic Distinction

Before per-file details, the critical semantic breakdown:

- **CanonicalR M M'** = `g_content M ⊆ M'` — this is ONE of:
  1. The first condition of `Succ` (Succ = CanonicalR + f_step)
  2. A derived consequence of any CanonicalTask forward chain (CanonicalTask(u,n,v) with n≥1 implies CanonicalR u v)
  3. A direct existential witness ("exists some accessible world") in the canonical model
  4. The ordering relation between MCSs in a preorder structure

- **ExistsTask** is the proposed rename for #3/#4 — when we genuinely mean "there exists temporal accessibility" without knowing the step count.

The confusing factor: in most StagedConstruction files, CanonicalR is used as the *ordering relation* on MCS-points (`a ≤ b := a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs`). This usage is **genuinely ExistsTask** semantics, not Succ-first-condition or CanonicalTask.

---

## Per-File Classification

### Bundle/ (Core Definitions)

#### CanonicalFrame.lean
- **Usage count**: 18 (word-boundary)
- **Nature**: DEFINITIONAL — defines `CanonicalR M M' := g_content M ⊆ M'`, proves transitivity (`canonicalR_transitive`), defines `ExistsTask := CanonicalR` alias
- **Key theorems**: `canonical_forward_F`, `canonical_forward_G`, `canonical_backward_P/H`, `canonicalR_transitive`, `h_content_chain_transitive`
- **Classification**: **Definitional** — this file IS the definition. Rename `CanonicalR` to `ExistsTask` here and update all aliases.
- **Recommended change**: Rename `def CanonicalR` to `def ExistsTask` (or `abbrev ExistsTask`); keep `CanonicalR_past` → `ExistsTask_past` (or `AccessPast`); remove the `abbrev ExistsTask := CanonicalR` line.

#### SuccRelation.lean
- **Usage count**: 8 (word-boundary)
- **Nature**: References `CanonicalR` in theorem statements (`Succ_implies_CanonicalR`) and proof comments
- **Key theorems**: `Succ_implies_CanonicalR : Succ u v → CanonicalR u v` (trivially, since Succ.g_persistence IS CanonicalR)
- **Classification**: **Naturally Succ** — the theorem `Succ_implies_CanonicalR` would become `Succ_implies_ExistsTask`; the proof comment "This is trivially CanonicalR" would read "This is trivially ExistsTask = g_content u ⊆ v"
- **Recommended change**: Rename all `CanonicalR` occurrences to `ExistsTask` in signatures and comments.

#### CanonicalTaskRelation.lean (read first 200 lines)
- **Usage count**: Does not appear to contain `CanonicalR\b` directly in its core theorems (uses `Succ` chains). References CanonicalR conceptually in the header comment via `CanonicalR_chain pattern`.
- **Classification**: **Structural** — pure CanonicalTask (Succ-chain indexed) definition. The module header references `CanonicalR_chain pattern from DovetailedCoverageReach` as a design note only.
- **Recommended change**: Update module doc comment only; no code changes needed.

#### CanonicalIrreflexivity.lean
- **Usage count**: 18
- **Nature**: Proves `¬CanonicalR M M` under irreflexive semantics; under reflexive semantics (Task 29), proves `CanonicalR M M` as a theorem. Contains `@[deprecated]` annotation.
- **Key theorems**: `canonicalR_irreflexive`, `canonicalR_reflexive`, `canonicalR_past_reflexive`
- **Classification**: **Structural** (frame condition on ExistsTask)
- **Recommended change**: Rename all `CanonicalR` to `ExistsTask` in theorem signatures, including `canonicalR_reflexive → existsTask_reflexive`.

#### DirectIrreflexivity.lean
- **Usage count**: 26
- **Nature**: Explores consequences of `CanonicalR M M` (self-loops). Contains closure lemmas, analysis of why direct contradiction from `CanonicalR M M` is impossible.
- **Key theorems**: `canonicalR_closure_temp_a`, `canonicalR_closure_G_closure`; and the reflexive theorem at line ~1207
- **Classification**: **Structural** (frame class property analysis for ExistsTask)
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask` throughout.

#### CanonicalFMCS.lean
- **Usage count**: 24
- **Nature**: Defines `CanonicalMCS` with `le a b := a = b ∨ CanonicalR a.world b.world` as preorder. Key lemmas: `canonicalR_of_lt`, `lt_of_canonicalR`, `lt_of_canonicalR_past`.
- **Classification**: **Genuinely ExistsTask** — the preorder is exactly "exists accessibility path" (one step suffices for the ordering since it's transitively closed). The `CanonicalR a b` condition in the preorder means "there exists temporal access from a to b."
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`; rename `canonicalR_of_lt → existsTask_of_lt`, `lt_of_canonicalR → lt_of_existsTask`.

#### ChainFMCS.lean
- **Usage count**: 37
- **Nature**: The `BoxGRelation` predicate, Diamond persistence through `CanonicalR`, and the FMCS ordering all use `CanonicalR`. Key: `MCSBoxContent_subset_of_CanonicalR`, `CanonicalR_implies_BoxGRelation`, `diamond_persists_CanonicalR`.
- **Classification**: **Genuinely ExistsTask** — all occurrences treat CanonicalR as "accessible in at least one step" (the preorder relation). BoxContent propagating through CanonicalR is a property of the accessibility ordering.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask` throughout.

#### FMCSTransfer.lean
- **Usage count**: 16
- **Nature**: `lt_of_canonicalR`, `lt_of_canonicalR_past` theorems; the CanonicalMCS strict ordering uses CanonicalR.
- **Classification**: **Genuinely ExistsTask** — the ordering is the existential accessibility relation.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`; rename theorems accordingly.

#### CanonicalConstruction.lean
- **Usage count**: 24
- **Nature**: `respects_task` defined using CanonicalR for a duration-indexed relation: `if d > 0 then CanonicalR M.val N.val else if d < 0 then CanonicalR N.val M.val else M = N`.
- **Classification**: **Genuinely ExistsTask** — `respects_task` is used to build a CanonicalTask-compatible relation from CanonicalR. This is the transition from "there exists access" to "there exists n steps." Each usage is the existential accessibility predicate.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask` in function definitions and proofs.

#### ClosedFlagIntBFMCS.lean
- **Usage count**: 2 (both in comments/doc only)
- **Classification**: **Comment-only** — no code usage.
- **Recommended change**: Update comments to `ExistsTask`.

#### ModalWitnessData.lean
- **Usage count**: 3 occurrences of `CanonicalReachable` (different concept), 0 of `CanonicalR\b`
- **Classification**: **Not applicable** — references `CanonicalReachable` (a failed prior approach), not `CanonicalR`.
- **Recommended change**: None.

---

### Canonical/ (Canonical Model Properties)

#### CanonicalTimeline.lean
- **Usage count**: 10
- **Nature**: `BidirectionalR M M' := CanonicalR M M' ∨ CanonicalR_past M M'`; seriality lemmas (`canonical_serial_forward`, `canonical_serial_backward`) proving existence of CanonicalR-successors; density of CanonicalR (if FF(φ) ∈ M, exists intermediate W with CanonicalR M W and F(φ) ∈ W).
- **Classification**: **Genuinely ExistsTask** — all usages express "there exists an accessible world." The density lemma is: given F(F(φ)), there EXISTS a successor with F(φ). Seriality: there EXISTS a successor/predecessor.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`; `CanonicalR_past` → `ExistsTask_past`; `BidirectionalR` is fine as-is if components are renamed.

#### CanonicalIrreflexivityAxiom.lean
- **Usage count**: 11
- **Nature**: Axiom `¬CanonicalR M M`; antisymmetry of CanonicalR (`if CanonicalR M N and CanonicalR N M then False`); strict ordering corollary.
- **Classification**: **Structural** (frame axiom on ExistsTask)
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### CanonicalSerialFrameInstance.lean
- **Usage count**: 14
- **Nature**: Forward and backward seriality witnesses using `canonical_forward_F`/`canonical_backward_P`; strict ordering from CanonicalR; CanonicalR-successor strictly ordered.
- **Classification**: **Genuinely ExistsTask** — seriality: EXISTS a successor. The strict order consequence is a property of ExistsTask.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### ConstructiveFragment.lean
- **Usage count**: 24
- **Nature**: Total preorder via CanonicalR + temp_linearity. Key: `executeForwardStep`/`executeBackwardStep` produce witnesses with `CanonicalR`; linearity theorems (`canonicalR_forward_linear`, `canonicalR_backward_linear`) prove that any two CanonicalR-successors of a common point are comparable.
- **Classification**: **Genuinely ExistsTask** — the total preorder uses CanonicalR as the ordering. Linearity proofs show: if ExistsTask M M1 and ExistsTask M M2, then M1 and M2 are comparable.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`. Rename `canonicalR_forward_linear → existsTask_forward_linear`, etc.

---

### Domain/ (Domain Construction)

#### CanonicalDomain.lean
- **Usage count**: 2 (both in comments only)
- **Classification**: **Comment-only** — no code usage of CanonicalR.
- **Recommended change**: Update comments.

#### DiscreteTimeline.lean
- **Usage count**: 7
- **Nature**: Discusses "immediate successor" = "CanonicalR(M, N) with no W strictly between them." Key: `covers` definition (W covers M if CanonicalR M W and nothing strictly between them); the DF axiom gives immediate successors.
- **Classification**: **Genuinely ExistsTask** — the `covers` and strictness conditions are properties of the ExistsTask accessibility relation, not of specific step counts.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

---

### StagedConstruction/ (Staged Construction Path)

#### CanonicalRecovery.lean
- **Usage count**: 48
- **Nature**: This is the **key bridging file**. It defines:
  - `Succ_implies_CanonicalR` (Succ step → ExistsTask)
  - `Succ_to_CanonicalR` (convenience alias)
  - `canonicalTask_forward_MCS_implies_canonicalR`: chain of length ≥ 1 → ExistsTask
  - Backward direction: ExistsTask → existence of CanonicalTask chain
  - `canonical_forward_F_with_canonicalR`: re-export of F-forward with ExistsTask witness
- **Classification**: **Structural (bridge)** — this file proves that ExistsTask is the derived/existential version of CanonicalTask. It is not naturally Succ or CanonicalTask but specifically relates them. The CanonicalR here IS what should be called ExistsTask.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`. Rename `Succ_to_CanonicalR → Succ_to_ExistsTask`, `canonicalTask_forward_MCS_implies_canonicalR → canonicalTask_forward_implies_existsTask`.

#### CantorPrereqs.lean
- **Usage count**: 22
- **Nature**: Defines `CanonicalR_chain` (reachability chain using CanonicalR steps), `CanonicalR_reachable`, `CanonicalR_chain_backward`. Also seriality/coverage lemmas: every timeline point has a CanonicalR-successor/predecessor.
- **Classification**: **Genuinely ExistsTask** — `CanonicalR_chain` is specifically "n steps of ExistsTask accessibility." The reachability notion is: there EXISTS a chain. The seriality lemmas say: there EXISTS a successor.
- **Note**: `CanonicalR_chain` is similar to `CanonicalTask` but defined separately here for the staged construction. Consider whether `CanonicalR_chain` should be renamed `ExistsTask_chain` or consolidated with `CanonicalTask`.
- **Recommended change**: Replace `CanonicalR` with `ExistsTask` throughout; rename `CanonicalR_chain → ExistsTask_chain`, `CanonicalR_reachable → ExistsTask_reachable`.

#### CantorApplication.lean
- **Usage count**: 19
- **Nature**: Uses CanonicalR for the staged timeline ordering and strict order witnesses. Irreflexivity ensures witnesses are strict. Density: intermediate W with `CanonicalR M W ∧ CanonicalR W N`.
- **Classification**: **Genuinely ExistsTask** — all occurrences are "there exists access," used in the ordering.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### ClosureSaturation.lean
- **Usage count**: 27
- **Nature**: Forward_G and backward_H via CanonicalR; F-forward witness construction; truth lemma infrastructure. Key: `exists W with CanonicalR(M, W) ∧ φ ∈ W` for the F case.
- **Classification**: **Genuinely ExistsTask** — the F-forward witness says "there exists an accessible world." The G/H transfer uses CanonicalR as the accessibility relation.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### DenseTimeline.lean
- **Usage count**: 56
- **Nature**: Dense timeline construction. `densityIntermediateMCS a b h_R h_not_R` defined using `if CanonicalR a.mcs a.mcs then ...` (reflexive case). Density lemmas: given `CanonicalR a b ∧ ¬CanonicalR b a`, there EXISTS intermediate.
- **Classification**: **Genuinely ExistsTask** — all usages are "there exists accessible world" in the density/ordering sense.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### DensityFrameCondition.lean
- **Usage count**: 83 (highest count)
- **Nature**: Core density frame condition: given `CanonicalR M M' ∧ ¬CanonicalR M' M`, there exists W with `CanonicalR M W ∧ CanonicalR W M'`. Also case B (reflexive case: CanonicalR M M').
- **Classification**: **Genuinely ExistsTask** — the density condition is about the ordering/accessibility relation. Every CanonicalR usage is existential accessibility.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`. Rename `density_of_canonicalR → density_of_existsTask`.

#### DFromCantor.lean
- **Usage count**: 2 (comment only)
- **Classification**: **Comment-only**
- **Recommended change**: Update comments.

#### DiscreteSuccSeed.lean
- **Usage count**: 14
- **Nature**: `CanonicalR M (discreteImmediateSucc M h_mcs)` — the discrete immediate successor has CanonicalR from M. Also betweenness: if `CanonicalR M K ∧ CanonicalR K W` where W is the immediate successor, then K = M or K = W.
- **Classification**: **Genuinely ExistsTask** for the "CanonicalR from M to succ" usage; but note: the first condition `CanonicalR M (discreteImmediateSucc M)` could be seen as **Naturally Succ** since discreteImmediateSucc IS the immediate next step. However, the betweenness conditions are frame properties of ExistsTask.
- **Assessment**: Treat as **ExistsTask** since the discrete immediate successor is defined in terms of ExistsTask accessibility, not a Succ pair.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### DovetailedBuild.lean
- **Usage count**: 29
- **Nature**: DovetailedPoint ordering: `a < b := CanonicalR a.mcs b.mcs ∧ ¬CanonicalR b.mcs a.mcs`; `a ≤ b := a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs`. Forward/backward witnesses: `CanonicalR point.mcs (executeForwardStep ...)`.
- **Classification**: **Genuinely ExistsTask** — the ordering relation and witness existence are all existential accessibility.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### DovetailedCompleteness.lean
- **Usage count**: 6
- **Nature**: Seriality (every point has CanonicalR-future/past in the timeline); CanonicalR gives timeline ordering.
- **Classification**: **Genuinely ExistsTask** — seriality: EXISTS successor with ExistsTask.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### DovetailedCoverage.lean
- **Usage count**: 12
- **Nature**: Forward/backward witness existence with CanonicalR; seriality lemmas for dovetailed timeline.
- **Classification**: **Genuinely ExistsTask**
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### DovetailedCoverageReach.lean
- **Usage count**: 15
- **Nature**: Defines `CanonicalR_chain` (n-step CanonicalR reachability), `CanonicalR_reachable`, `CanonicalR_chain_backward`. Seriality: every point has CanonicalR-successor/predecessor.
- **Classification**: **Genuinely ExistsTask** — the chain/reachability is: there EXISTS n steps. The `CanonicalR_chain` here is not CanonicalTask (which is Succ-based) but ExistsTask-based reachability.
- **Recommended change**: Replace `CanonicalR` with `ExistsTask`; rename `CanonicalR_chain → ExistsTask_chain`, etc.

#### DovetailedFMCS.lean
- **Usage count**: 11
- **Nature**: Bridge lemma: `t < t'` in DovetailedTimelineQuot implies `CanonicalR (mcs t) (mcs t')`. Converse: CanonicalR implies ≤.
- **Classification**: **Genuinely ExistsTask** — the bridge shows ordering corresponds to existential accessibility.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### DovetailedTimelineQuot.lean
- **Usage count**: 51
- **Nature**: Large file with extensive CanonicalR usage. DovetailedPoint ordering, density intermediate construction, coverage reach lemmas. Many `CanonicalR p.mcs q.mcs` conditions in ordering/seriality/density proofs.
- **Classification**: **Genuinely ExistsTask** — all usages are existential accessibility in the timeline ordering.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask` throughout.

#### ImmediateStagedBuild.lean
- **Usage count**: 18
- **Nature**: `CanonicalR M (immediateForwardWitnessPoint M h_mcs stage).mcs`; betweenness condition for immediate witnesses; seriality in staged build. Proof that `processImmediateForwardObligation` creates a CanonicalR-successor.
- **Classification**: **Genuinely ExistsTask** — the "immediate" here is about the staged construction, not Succ; the CanonicalR condition is the accessibility ordering.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### IncrementalTimeline.lean
- **Usage count**: 7
- **Nature**: `immediateSuccPoint_canonicalR`; betweenness for immediate successors (K with `CanonicalR M K ∧ CanonicalR K W` is M or W). Comment about `succ(M) := min { K | CanonicalR M K ∧ K ≠ M }`.
- **Classification**: **Genuinely ExistsTask** (same as DiscreteSuccSeed pattern).
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### SeparationLemma.lean
- **Usage count**: 17
- **Nature**: `distinguishing_formula_exists`: if `¬CanonicalR M' M`, there exists beta with G(beta) ∈ M' but beta ∉ M. `intermediate_from_density`: given `CanonicalR M M'` and distinguishing formula, get intermediate W with `CanonicalR M W`.
- **Key insight**: Line 68: `rw [CanonicalR, Set.not_subset]` — this unfolds CanonicalR directly to `g_content M' ⊄ M`. This is the critical definitional usage.
- **Classification**: **Genuinely ExistsTask** — accessibility/ordering conditions. The `rw [CanonicalR, ...]` would need to become `rw [ExistsTask, ...]` or unfold via a definitional simp lemma.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`; ensure `ExistsTask` is defined as `def` (not `abbrev`) or add `@[simp] lemma ExistsTask_def` for the `rw` to work.

#### StagedExecution.lean
- **Usage count**: 70 (very high)
- **Nature**: Largest usage. Contains linearity theorems (same-predecessor/same-successor MCSs are CanonicalR-comparable), F-backward `phi ∈ M' ∧ CanonicalR M M' → F(phi) ∈ M`, and P-backward `phi ∈ M' ∧ CanonicalR M' M → P(phi) ∈ M`.
- **Key theorems**:
  - `backward_F_witness`: φ ∈ M' ∧ CanonicalR M M' → F(φ) ∈ M
  - `backward_P_witness`: φ ∈ M' ∧ CanonicalR M' M → P(φ) ∈ M
  - `forward_reachable_linear`: CanonicalR M M1 ∧ CanonicalR M M2 → M1,M2 comparable
  - `backward_reachable_linear`: CanonicalR M1 M ∧ CanonicalR M2 M → M1,M2 comparable
- **Classification**: **Genuinely ExistsTask** — all usages are existential accessibility conditions. The linearity proofs are structural properties of the ExistsTask ordering.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`. Rename `forward_reachable_linear → existsTask_forward_linear`, etc.

#### StagedTimeline.lean
- **Usage count**: 9
- **Nature**: `StagedPoint.lt` = `CanonicalR a.mcs b.mcs ∧ ¬CanonicalR b.mcs a.mcs`; `StagedPoint.le` = `a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs`. Note at line 137 about reflexive semantics.
- **Classification**: **Genuinely ExistsTask** — the ordering structure.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### TimelineQuotBFMCS.lean
- **Usage count**: 14
- **Nature**: BFMCS coherence using CanonicalR: `forward_G_bfmcs`, `backward_H_bfmcs`, `forward_F_bfmcs`, `backward_P_bfmcs` all via CanonicalR accessibility.
- **Classification**: **Genuinely ExistsTask** — the BFMCS coherence conditions use CanonicalR as the accessibility relation (there EXISTS an accessible world satisfying the property).
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### TimelineQuotCanonical.lean
- **Usage count**: 26
- **Nature**: Bridge lemma `timelineQuot_lt_implies_canonicalR` and its converse; the TimelineQuot BFMCS uses `parametric_canonical_task_rel` which internally uses CanonicalR. Forward/backward truth lemma infrastructure.
- **Classification**: **Genuinely ExistsTask** — the bridge connects timeline ordering to existential accessibility.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`; rename `timelineQuot_lt_implies_canonicalR → timelineQuot_lt_implies_existsTask`.

#### WitnessChainFMCS.lean
- **Usage count**: 1 (comment only)
- **Classification**: **Comment-only**
- **Recommended change**: Update comment.

#### WitnessSeedWrapper.lean
- **Usage count**: 10
- **Nature**: `executeForwardStep`/`executeBackwardStep` produce witnesses with `CanonicalR`; `forwardWitnessPoint_canonicalR`; re-export of `canonical_forward_F` with CanonicalR condition.
- **Classification**: **Genuinely ExistsTask** — the witness construction produces an accessible world (existential).
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

---

### Algebraic/ (Algebraic Completeness Path)

#### ParametricHistory.lean
- **Usage count**: 2
- **Nature**: `respects_task` using CanonicalR in the integer-indexed case: `if d > 0 then CanonicalR...`. Comment about using forward_G via CanonicalR.
- **Classification**: **Genuinely ExistsTask** — the task relation for d > 0 is: "there exists accessibility."
- **Recommended change**: Replace `CanonicalR` with `ExistsTask`.

#### DenseInstantiation.lean
- **Usage count**: 1 (comment only — `task_rel = parametric_canonical_task_rel (uses CanonicalR)`)
- **Classification**: **Comment-only**
- **Recommended change**: Update comment.

#### DiscreteInstantiation.lean
- **Usage count**: 1 (comment only)
- **Classification**: **Comment-only**
- **Recommended change**: Update comment.

#### IntBFMCS.lean
- **Usage count**: 65 (very high — the Int-indexed BFMCS)
- **Nature**: Large file. `successorMCS` returns MCS with `CanonicalR M M'`; `posChain_canonicalR`, `negChain_canonicalR`, `intChainMCS_canonicalR_consecutive`; G-forward via CanonicalR; seriality; density via CanonicalR.
- **Key**: `successorMCS : Σ' (M' : Set Formula), SetMaximalConsistent M' ∧ CanonicalR M M'` and `predecessorMCS` symmetric.
- **Classification**: **Genuinely ExistsTask** — all usages are existential: "there exists a successor MCS with accessibility." The chain construction builds successive worlds where each consecutive pair is ExistsTask-related.
- **Note**: The CanonicalR chain here (pos/neg chain over integers) is NOT the same as CanonicalTask (which is Succ-chain indexed). The intChain uses ExistsTask-accessibility at each step.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`. Rename `successorMCS`, `posChain_canonicalR → posChain_existsTask`, etc.

#### MultiFamilyBFMCS.lean
- **Usage count**: 8
- **Nature**: References CanonicalR for BoxContent propagation and the preorder. Re-uses `MCSBoxContent_subset_of_CanonicalR`.
- **Classification**: **Genuinely ExistsTask**
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### ParametricCanonical.lean
- **Usage count**: 23
- **Nature**: Defines `parametric_canonical_task_rel` using CanonicalR: `if d > 0 then CanonicalR M.val N.val else if d < 0 then CanonicalR N.val M.val`. Key: `task_rel_pos_iff_canonicalR`, `task_rel_neg_iff_canonicalR`.
- **Classification**: **Genuinely ExistsTask** — the parametric task relation is built from ExistsTask accessibility. Positive duration = forward ExistsTask; negative duration = backward ExistsTask.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`. Rename `task_rel_pos_iff_canonicalR → task_rel_pos_iff_existsTask`.

#### SaturatedChain.lean
- **Usage count**: 26
- **Nature**: Saturated chain BFMCS. The witness MCS has `CanonicalR M.world witness.world`; seriality; density via CanonicalR. Key: `saturated_chain_has_successor` uses `canonical_forward_F` and CanonicalR.
- **Classification**: **Genuinely ExistsTask** — existential witness/successor existence.
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### SeparatedHistory.lean
- **Usage count**: 6
- **Nature**: `respects_task` for the separated history BFMCS; uses CanonicalR via the linking lemma `timelineQuot_lt_implies_canonicalR`.
- **Classification**: **Genuinely ExistsTask**
- **Recommended change**: Replace all `CanonicalR` with `ExistsTask`.

#### SeparatedTaskFrame.lean
- **Usage count**: 4
- **Nature**: Comment-level references to CanonicalR for the task relation.
- **Classification**: **Comment-level** (mostly)
- **Recommended change**: Update comments.

#### CanonicalEmbedding.lean
- **Usage count**: 2 (comment-level: `canonical_forward_F: ∃ W with CanonicalR M W ∧ φ ∈ W`)
- **Classification**: **Comment-only**
- **Recommended change**: Update comments.

#### CanonicalQuot.lean
- **Usage count**: 9
- **Nature**: Discussion of CanonicalR as preorder vs. ExistsTask directly. Key quote (line 48-68): explains why reflexive closure of CanonicalR is used (CanonicalR is irreflexive, not a preorder itself). The `ExistsTask` alias already mentioned here.
- **Classification**: **Structural** — explains the relationship between CanonicalR and ExistsTask in the context of the quotient construction.
- **Recommended change**: Update to use `ExistsTask` consistently.

---

### Boneyard/ (Noted, Not Deep Analysis)

The following boneyard files contain `CanonicalR` and are deprecated:

- `Boneyard/Task956_IntRat/BidirectionalReachable.lean`
- `Boneyard/Task994_DovetailedQuot/DovetailedFMCS.lean`
- `Boneyard/Task994_DovetailedQuot/DovetailedTimelineQuot.lean`
- `Boneyard/Task956_StrictDensity/DensityFrameCondition_StrictAttempt.lean`
- `Boneyard/Task956_IntRat/CanonicalChain.lean`
- `Boneyard/Task956_IntRat/CanonicalCompleteness.lean`
- `Boneyard/Task956_IntRat/DenseQuotient.lean`
- `Boneyard/Task956_IntRat/FragmentCompleteness.lean`
- `Boneyard/Task956_IntRat/RestrictedFragment.lean`

These are deprecated code and can be updated last (or renamed as a batch). All usages will follow the same ExistsTask pattern as the active code.

---

## Cross-Cutting Observations

### 1. The `CanonicalR` vs `ExistsTask` Confusion

`CanonicalR` is used uniformly for what is semantically "ExistsTask" across all non-Bundle files. The name `CanonicalR` suggests a relation specific to the canonical model, but the concept is universal temporal accessibility. `ExistsTask` better reflects: "there exists a temporal task (path) connecting these two worlds."

### 2. Key Pattern: `rw [CanonicalR, Set.not_subset]`

In `SeparationLemma.lean` and `ConstructiveFragment.lean`, the code rewrites `¬CanonicalR M M'` to `g_content M ⊄ M'` via:
```lean
rw [CanonicalR, Set.not_subset] at h
```
For this to work after renaming, `ExistsTask` must be defined as `def` (unfolding) rather than `abbrev`, or a `@[simp] lemma ExistsTask_def : ExistsTask M M' ↔ g_content M ⊆ M'` must be added.

### 3. `CanonicalR_chain` vs `CanonicalTask`

There are **two** chain-reachability constructs:
- `CanonicalR_chain` (in `DovetailedCoverageReach.lean`, `CantorPrereqs.lean`) — n steps of `ExistsTask`
- `CanonicalTask` (in `Bundle/CanonicalTaskRelation.lean`) — n steps of `Succ`

These are semantically different: `ExistsTask`-chains allow any transitive accessibility; `CanonicalTask`-chains require exactly `Succ` at each step (which is stricter). On rename, `CanonicalR_chain → ExistsTask_chain` to distinguish from `CanonicalTask`.

### 4. No File Uses CanonicalR as "Naturally Succ"

Contrary to initial expectations, **no file** uses `CanonicalR` where `Succ` would be more appropriate. The `Succ` relation is consistently separate from `CanonicalR`. The relationship is captured by `Succ_implies_CanonicalR` (in SuccRelation.lean and CanonicalRecovery.lean). No usage site conflates the two.

### 5. No "Naturally CanonicalTask" Usage

Similarly, no file uses `CanonicalR` where `CanonicalTask` (the integer-indexed Succ-chain) would be more appropriate. `CanonicalTask` is cleanly defined in its own module and not confused with `CanonicalR`.

---

## Summary Statistics (Revised)

| Category | Files | Total Usages |
|----------|-------|--------------|
| Definitional | 1 | 18 |
| Structural (frame properties, ordering) | 5 | ~90 |
| Genuinely ExistsTask | 38 | ~680 |
| Comment-only | 5 | ~12 |
| **Total (non-Boneyard)** | **49** | **~800** |

The dominant pattern is **Genuinely ExistsTask** (38 files, ~680 usages). The rename is semantically clean and uniform.

---

## Recommended Rename Strategy

1. **Rename `CanonicalR` → `ExistsTask` in `CanonicalFrame.lean`** (the definition file). Remove the `abbrev ExistsTask := CanonicalR` alias since `ExistsTask` becomes the primary name.

2. **Add backward-compat alias** (optional): `abbrev CanonicalR := ExistsTask` temporarily to ease migration.

3. **Update `SuccRelation.lean`**: Rename `Succ_implies_CanonicalR → Succ_implies_ExistsTask`.

4. **Update `CanonicalRecovery.lean`**: Rename bridge theorems.

5. **Batch-update all remaining files**: sed-replace `CanonicalR\b` → `ExistsTask` is safe for almost all files. The exceptions that need careful review:
   - Files using `rw [CanonicalR, ...]` (SeparationLemma.lean, ConstructiveFragment.lean)
   - `CanonicalR_chain` definitions → `ExistsTask_chain`
   - `CanonicalR_past` → `ExistsTask_past`
   - `CanonicalR_reachable` → `ExistsTask_reachable`
   - `CanonicalR_backward_chain` → `ExistsTask_backward_chain`

6. **Boneyard**: Update last, as batch.

---

## Confidence Level

**HIGH** — The audit reveals a strikingly uniform pattern: `CanonicalR` is used exclusively as the existential temporal accessibility relation (`ExistsTask`) throughout the codebase. There are no cases where `CanonicalR` should become `Succ` or `CanonicalTask` instead. The rename `CanonicalR → ExistsTask` is semantically clean and can be performed by systematic search-and-replace with only five edge cases requiring manual review (the `rw [CanonicalR, ...]` sites and the `_chain`/`_reachable` type definitions).
