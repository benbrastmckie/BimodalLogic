---
next_project_number: 90
repository_health:
  overall_score: 92
  production_readiness: improved
  last_assessed: 2026-04-10T00:00:00Z
task_counts:
  active: 21
  completed: 742
  in_progress: 0
  not_started: 10
  abandoned: 68
  total: 821
technical_debt:
  sorry_count: 20
  sorry_count_note: "Audited 2026-03-31: 12 examples/exercises, 1 soundness (temporal_duality, intentional), 2 completeness wiring (bfmcs_from_mcs_temporally_coherent + dense), 2 FMP, 1 SuccChainTruth (intentional), 1 Demo, 1 misc. Task 59 filled 4 soundness sorries."
  publication_path_sorries: 4
  axiom_count: 1
  axiom_count_note: "discrete_Icc_finite_axiom (task 60). f_nesting_boundary/p_nesting_boundary eliminated in task 56."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-04-10. Created tasks 90-95 after review discovered ROAD_MAP.md is stale: T-axiom is present, semantics is reflexive, BX axiom system is complete. Task 89 superseded by 90+92.*

**Goal**: Close BXCanonical completeness via Burgess-Xu Until-induction; archive strict-semantics legacy; zero custom axioms.

### 1. Critical Path — BXCanonical Completeness

```
91 → 90 → 92 → 93 → 95
          ↘ 94
```

1. **91** [NOT STARTED] — Update ROAD_MAP.md to reflect BX reflexive-semantics architecture (prerequisite for accurate research)
2. **90** [COMPLETED] — Research/decide Option A (redefine bx_le via Until-witnesses) vs Option B (Henkin closure) for BXCanonical Until-induction (depends on 91)
3. **92** [RESEARCHED] — Implement Until/Since truth lemma in BXCanonical/Frame.lean (4 sorries; depends on 90)
4. **93** [NOT STARTED] — Close Box sorry at Frame.lean:440 + TaskModel embedding at Completeness.lean:154 (depends on 92)
5. **95** [NOT STARTED] — Verification audit: #print axioms + sorry classification pass (depends on 93)
6. **94** [NOT STARTED] — Archive UltrafilterChain.lean + FrameConditions/Completeness.lean + SuccChainFMCS.lean to Boneyard (depends on 91)
7. **60** [NOT STARTED] — Remove discrete_Icc_finite_axiom (custom axiom, independent)

### 2. Superseded / Legacy

- **89** [RESEARCHED] — Superseded by 90+92. Research round was conducted against stale semantic state.
- **58** [BLOCKED] — Wire completeness to FrameConditions. Abandoned: FrameConditions/Completeness.lean is legacy strict-semantics code to be archived by 94.

### 3. Independent Completeness Paths (parallel)

- **82** [NOT STARTED] — Close 2 FMP TruthPreservation sorries — gives weak completeness
- **68** [RESEARCHED] — Prove dense_completeness_fc via Rat canonical model (independent, needs Rat construction)

### 4. Strict Temporal Extensions Research (parallel track)

```
74 → 75 → 76
      ↘ 998 (FMP strict temporal)
```

- **74** [NOT STARTED] — Research strict vs reflexive temporal semantics
- **75** [NOT STARTED] — Research G'/H' operator extension design (depends on 74)
- **76** [NOT STARTED] — Research unified density/discreteness completeness (depends on 74, 75)
- **998** [RESEARCHING] — FMP redesign for strict temporal (parallel to 75)

### 5. Experimental / Research

- **992** [RESEARCHED] — STSA temporal shift automorphism (algebraic, independent)
- **64** [RESEARCHED] — Critical path review (completed research, reference only)

### 6. Deferred

- **18** [BLOCKED] — Dense representation theorem (4 sorries, defer until base is clean)
- **20** [NOT STARTED] — Parametric canonical audit (depends on 18)
- **21** [PLANNED] — Tech debt cleanup (depends on 18)
- **19** [NOT STARTED] — Deprecate old discrete pipeline (low priority)

### 7. Backlog

- **8** [RESEARCHED] — Genuine truth_at completeness (publication quality, 12-20h)
- **39** [RESEARCHED] — Preorder semantics study (theoretical)
- **953** [RESEARCHED] — Bilateral proof system (55-90h)
- **949** [RESEARCHED] — Update Demo.lean (cosmetic)
- **619** [RESEARCHED] — Agent system architecture upgrade (meta, blocked on GitHub #16803)

## Tasks

---

### 91. Update ROAD_MAP.md to reflect BX reflexive-semantics architecture
- **Effort**: 2-4 hours
- **Status**: [COMPLETED]
- **Language**: meta
- **Priority**: high
- **Dependencies**: None
- **Created**: 2026-04-10
- **Related**: Tasks 90, 92, 94
- **Research**: [01_bx-reflexive-roadmap-research.md](091_update_roadmap_bx_reflexive/reports/01_bx-reflexive-roadmap-research.md)
- **Plan**: [01_bx-reflexive-roadmap-plan.md](091_update_roadmap_bx_reflexive/plans/01_bx-reflexive-roadmap-plan.md)
- **Summary**: [01_bx-reflexive-roadmap-summary.md](091_update_roadmap_bx_reflexive/summaries/01_bx-reflexive-roadmap-summary.md)

**Description**: Rewrite `specs/ROAD_MAP.md` to match the actual codebase. The current roadmap describes a strict-semantics architecture (post task 81) that no longer matches the code: it claims the T-axiom was removed, that Until/Since are strict, and that `UltrafilterChain.lean` is the active completeness path. Verify against current code: (1) `temp_t_future`/`temp_t_past` are BX1/BX1' in `ProofSystem/Axioms.lean:117-122`; (2) `Semantics/Truth.lean:126-131` uses reflexive ≤/≥ for all temporal operators; (3) X/Y exist only as dead definitional abbreviations in `Syntax/Formula.lean:330-334`; (4) `Metalogic.lean` imports `BXCanonical`, not `UltrafilterChain`. Document: the BX axiom system and each axiom's role, the canonical model construction in `BXCanonical`, the actual remaining sorries (4 in `Frame.lean` for U/S, 1 Box at `Frame.lean:440`, 1 embedding at `Completeness.lean:154`), and the Burgess-Xu Until-induction technique as the path forward. **Do this first** so downstream research/planning agents have an accurate baseline.

---

### 90. Research: Option A (redefine bx_le via Until-witnesses) vs Option B (Henkin closure)
- **Effort**: 4-8 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-04-10
- **Summary**: Delivered decision artifact: reject Option A, adopt Burgess-Xu Until-induction on unchanged bx_le. Phase 1 lean-lsp probes proved global and interval linearity non-derivable from BX7+BX11+BX12 (metalogic/object-logic bridge gap). Task 92 unblocked with concrete direction; scope fenced from task 93.
- **Artifacts**:
  - [01_team-research.md](090_research_bx_le_redefinition/reports/01_team-research.md)
  - [01_bx_le_decision-plan.md](090_research_bx_le_redefinition/plans/01_bx_le_decision-plan.md)
  - [02_bx_le_linear_diagnostic.md](090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md)
  - [03_task92_recommendation.md](090_research_bx_le_redefinition/reports/03_task92_recommendation.md)
  - [01_bx_le_decision-summary.md](090_research_bx_le_redefinition/summaries/01_bx_le_decision-summary.md)
- **Language**: lean4
- **Priority**: high
- **Dependencies**: Task 91 (accurate roadmap)
- **Created**: 2026-04-10
- **Related**: Tasks 89 (supersedes), 92

**Description**: Research and decide the approach for closing the 4 Until/Since truth-lemma sorries in `BXCanonical/Frame.lean` (lines 653, 675, 690, 704). The BX axiom system already contains everything Burgess 1982 / Xu 1988 needed: BX5 (self_accum_until), BX6 (absorb_until), BX7 (linear_until), BX10 (until_F: (φUψ)→F(ψ)), BX11 (temp_linearity), BX12 (F_until_equiv), BX4 (connect_future), and T (temp_t_future). The blocker is a mismatch between the canonical ordering `bx_le := g_content ⊆` (Frame.lean:61) and the Until-witness ordering given by BX7. **Option A**: redefine `bx_le` via Until-witnesses and prove equivalence with the g_content definition using BX10 + BX12 + BX4 + T. **Option B**: keep `bx_le := g_content ⊆` and Henkin-enrich the MCS closure with Until witnesses (Burgess 1984 style). Deliverable: a report in `specs/090_research_bx_le_redefinition/reports/` comparing the two on (i) proof complexity, (ii) impact on the Box-direction argument, (iii) impact on TaskModel embedding, (iv) recommended choice with justification. Supersedes task 89 — its research was conducted against a stale semantic state.

---

### 92. Implement Burgess-Xu Until/Since truth lemma in BXCanonical/Frame.lean
- **Effort**: 13-23 hours (revised from 8-16h per team research round 02)
- **Status**: [PLANNED]
- **Language**: lean4
- **Priority**: high
- **Dependencies**: Task 90 (approach decision, completed)
- **Created**: 2026-04-10
- **Related**: Tasks 89 (supersedes), 90, 93
- **Artifacts**:
  - [01_inherited-from-task90.md](092_implement_bx_until_truth_lemma/reports/01_inherited-from-task90.md)
  - [02_team-research.md](092_implement_bx_until_truth_lemma/reports/02_team-research.md)
  - [02_burgess-xu-until-plan.md](092_implement_bx_until_truth_lemma/plans/02_burgess-xu-until-plan.md)

**Description**: Close the 4 Until/Since truth-lemma sorries in `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`: `bx_until_eventuality_resolution` (line 653), `bx_until_backward` (line 675), `bx_since_eventuality_resolution` (line 690), `bx_since_backward` (line 704). Per task 90 decision ([03_task92_recommendation.md](090_research_bx_le_redefinition/reports/03_task92_recommendation.md)), use **Burgess-Xu Until-induction** on the unchanged `bx_le := g_content ⊆` ordering. Do NOT redefine `bx_le` (Option A is structurally infeasible) and do NOT attempt a preliminary `bx_le_linear` lemma (the Phase 1 lean-lsp diagnostic confirmed global and interval linearity are not derivable from BX7+BX11+BX12 due to the object-logic/metalogic bridge gap). Construct the trajectory directly: BX10 to get F(ψ), BX12 for the vacuous-guard Until form, BX7 `linear_until` to pick the earliest ψ-witness, BX5 self-accumulation + BX6 absorption for guard persistence, BX9 `until_elim` for the current-time case, BX4 `connect_future` for the backward direction (propagate ¬(φUψ) forward along `w`, not backward from `v`). Mirrors apply for Since via the primed axioms. Rewrite misleading "linearity gap" comments at `Frame.lean:647-651` and `:674`. Scope fence: does NOT close `Frame.lean:440` or `Completeness.lean:154` (task 93). No new axioms needed.

---

### 93. Complete BXCanonical canonical model embedding
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: high
- **Dependencies**: Task 92
- **Created**: 2026-04-10
- **Related**: Tasks 92, 95

**Description**: Close the remaining two BXCanonical sorries after task 92: (1) Box-direction sorry at `BXCanonical/Frame.lean:440` via the standard canonical-model argument for modal Box using `bx_modal_equiv`; (2) TaskModel embedding sorry at `BXCanonical/Completeness.lean:154` constructing a `TaskModel` from the BXPoint canonical frame. Once closed together with task 92, `completeness_over_Int` becomes sorry-free through `BXCanonical`, and the top-level completeness theorem's `#print axioms` should list only `propext`, `Classical.choice`, `Quot.sound`.

---

### 94. Archive strict-semantics legacy code to Boneyard
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: medium
- **Dependencies**: Task 91
- **Created**: 2026-04-10
- **Related**: Tasks 58 (closes), 91

**Description**: Move the legacy strict-semantics completeness code to `Boneyard/StrictSemanticsLegacy/` with a README explaining its history. Files: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (~67 sorries), `Theories/Bimodal/FrameConditions/Completeness.lean` (~54 sorries), `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` (~29 sorries), `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (~61 sorries). These were written under strict temporal semantics (strict G/H, strict U/S) before the codebase reverted to reflexive BX semantics; their sorry count reflects architectural incompatibility, not real mathematical gaps. Update any importers (`Metalogic.lean` already points to `BXCanonical`). Mechanically drops ~210 sorries from the non-Boneyard count. Update `state.json.technical_debt` to reflect new counts. Also formally closes task 58 (which was blocked on this legacy path). Do after task 91 so the Boneyard README can cite the authoritative roadmap.

---

### 95. Verification audit: #print axioms + sorry classification pass
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: medium
- **Dependencies**: Task 93
- **Created**: 2026-04-10
- **Related**: Tasks 60, 93

**Description**: Verification pass to confirm no corners cut on the representation and completeness theorems. (1) Run `#print axioms` on `BXCanonical.completeness` and `discrete_completeness_fc`; confirm output is exactly `{propext, Classical.choice, Quot.sound}`. (2) Grep `Theories/Bimodal/Metalogic/Soundness.lean` and `SoundnessLemmas.lean` for real `sorry` tactics vs `sorry` in docstrings (`Soundness.lean` shows 4 grep hits all inside doc comments; `SoundnessLemmas.lean` shows 37 hits that must be classified). (3) Confirm `soundness`, `soundness_dense`, `soundness_discrete` all build and list only standard axioms. (4) Audit custom axiom list: expected `{discrete_Icc_finite_axiom}` (task 60); confirm no others. (5) Produce an audit report at `specs/reviews/completeness-audit-{DATE}.md`.

---

### 89. Close 4 Frame.lean eventuality resolution sorries via quasimodel or Henkin construction
- **Effort**: 40-80 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Priority**: high
- **Dependencies**: None (independent of task 88 CanonicalEmbedding)
- **Created**: 2026-04-10
- **Related**: Tasks 88, 86, 85, 83
- **Research**: [01_team-research.md](specs/089_close_frame_lean_eventuality_sorries/reports/01_team-research.md)

**Description**: Close 4 Frame.lean eventuality resolution sorries (bx_until_eventuality_resolution:653, bx_until_backward:675, bx_since_eventuality_resolution:690, bx_since_backward:704) via quasimodel (GHR 1994) or Henkin fair scheduling construction. The X-vs-G mismatch is confirmed fundamental (6 rounds, 99% confidence): no BX axiom bridges φ U ψ membership to G(φ U ψ) membership, so eventualities must be resolved by model construction rather than ordering propagation. Requires 4-8h research spike into quasimodel viability (task 83 linearization issues), then 30-40h implementation. Downstream: Completeness.lean:160 closes automatically when these 4 are resolved.

---

---

### 87. Full representation theorem with Until/Since via enriched chain construction in Bundle/
- **Effort**: 40-60 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Task 86 (USF fragment completeness)
- **Created**: 2026-04-09
- **Related**: Tasks 83 (archived), 84 (archived), 85, 86, 58

**Description**: Prove the full representation theorem for TM with Until/Since operators via the enriched-Succ chain with dovetailed scheduling over subformula closure in Bundle/. The only viable path to full Until/Since forward coherence after 39+ research rounds. Key components: combined_F_seed_consistent lemma, enriched chain builder, backward Until direction via BX6 absorption, forward_F by construction. Estimated 600-1000 LOC, 70-85% confidence. See task 83 reports 38-39, task 86 report 05 for detailed analysis.

---

---

### 82. Close FMP TruthPreservation Sorries
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: high
- **Dependencies**: None
- **Created**: 2026-04-02

**Description**: Close the 2 FMP TruthPreservation sorries (`mcs_all_future_closure` at line 263 and `mcs_all_past_closure` at line 281) in `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean`. The sorry comments incorrectly claim TM uses strict semantics. The actual codebase (`Truth.lean`) uses reflexive semantics (`t ≤ s`, not `t < s`), and `temp_t_future`/`temp_t_past` ARE axioms (Axioms.lean:290,304). Proofs parallel to `mcs_box_closure` (TruthPreservation.lean:188-203). Closing these completes the FMP path giving **weak completeness of TM**.

---

---

### 74. Research strict vs reflexive temporal semantics for TM logic
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Language**: formal
- **Priority**: high
- **Created**: 2026-03-31
- **Related**: Tasks 75-77, 998 (strict temporal extensions track)

**Description**: Research and compare strict temporal semantics (G/H quantify over s > t / s < t) versus reflexive semantics (s ≥ t / s ≤ t) for TM logic completeness. Key questions:

1. **Canonical model construction**: Does strict semantics simplify F/P witness construction? Under strict semantics, F(φ) at t means ∃s > t, φ(s) — the present is excluded, potentially avoiding the Lindenbaum extension issue where G(neg φ) can kill F(φ) witnesses.

2. **Axiom implications**: The temp_t_future (Gφ → φ) and temp_t_past (Hφ → φ) axioms are ONLY valid under reflexive semantics. Under strict semantics, these would be removed. How does this affect the proof system?

3. **Literature survey**: Survey existing literature on tense logics with both strict and reflexive operators (Kt, Kt.Li, Prior's tense logics).

4. **Completeness path**: Determine if strict semantics provides a simpler path to completeness or if reflexive semantics with FMP workaround is preferable.

---

### 75. Research G'/H' operator extension design for TM logic
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Language**: formal
- **Priority**: high
- **Created**: 2026-03-31
- **Dependencies**: Task 74
- **Related**: Tasks 74, 76-77, 998 (strict temporal extensions track)

**Description**: Design the extension of TM logic with strict temporal operators G'/H' alongside existing reflexive G/H. Key design decisions:

1. **Formula syntax extension**:
   - Option A: Add G'/H' as new primitives in Formula type
   - Option B: Define G'/H' as derived operators (G' φ := G φ ∧ ¬φ)
   - Tradeoffs: Primitives are cleaner for semantics; definitions simplify conservative extension proof

2. **Axiom schemas**: Determine axioms for strict operators:
   - Distribution: G'(φ → ψ) → (G'φ → G'ψ)
   - Interaction with reflexive: G ↔ (φ ∧ G'), H ↔ (φ ∧ H')
   - Strict seriality: Gφ → Fφ (from NoMaxOrder)
   - Strict density: G'G'φ → G'φ (from DenselyOrdered)

3. **Conservative extension proof**: Show that for formulas without G'/H', derivability in extended system iff derivability in base system.

4. **Modal interaction**: Verify G'/H' interact correctly with S5 modal operators □/◇.

---

### 76. Research unified density/discreteness completeness paths
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Language**: formal
- **Priority**: high
- **Created**: 2026-03-31
- **Dependencies**: Tasks 74, 75
- **Related**: Tasks 68, 998 (dense/discrete completeness)

**Description**: Research unified approach to density and discreteness completeness under both strict and reflexive semantics. Key questions:

1. **Dense completeness**:
   - Current blocker: dense_completeness_fc sorry (Int is not dense)
   - Path A: Rat canonical model construction
   - Path B: Strict semantics may simplify (density axiom documented for strict)
   - Analyze which approach is more tractable

2. **Discrete completeness**:
   - Current: Reduces to Int completeness (sorry-free reduction)
   - Blocker: discrete_Icc_finite_axiom (custom axiom, task 60)
   - Path: SuccOrder-based approach vs quotient approach

3. **Unified framework**:
   - Can density and discreteness share canonical model infrastructure?
   - ParametricRepresentation already parametric over D — extend to support both

4. **Base logic completeness**:
   - Is base logic (no density/discreteness axioms) complete?
   - If incomplete, what minimal extension is needed?

---







### 68. Prove dense_completeness_fc via Rat canonical model
- **Effort**: 6-10 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task #72
- **Parent Task**: #58
- **Research**: [83_spawn-analysis.md](058_wire_completeness_to_frame_conditions/reports/83_spawn-analysis.md)

**Description**: Eliminate the sorry in dense_completeness_fc (FrameConditions/Completeness.lean line 121) by constructing a canonical model over Rat. Int cannot be used because Int is not densely ordered. Rat is countable, aligning with existing Lindenbaum/countable MCS machinery.

---



### 64. Critical path review: algebraic analysis of completeness obstacles
- **Effort**: Research task
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Research**:
  - [01_critical-path-analysis.md](064_critical_path_review/reports/01_critical-path-analysis.md)
  - [02_team-research.md](064_critical_path_review/reports/02_team-research.md)

**Description**: Multi-agent review of the critical path tasks (58-60) for accuracy, identification of gaps, and algebraic strategy analysis. Key findings:

**Sorry inventory correction**: Actual sorry count is 25 (not 98 per ROADMAP). SuccChain sorries (24) removed in task 56. Perpetuity bridge (16) all proven. Publication-path sorries: 9 (tasks 58+59 only). The ROADMAP Class A/B distinction is moot — the SuccChain approach was abandoned.

**TODO.md accuracy**: Task descriptions are accurate on locations and content. Task 59 is incorrectly marked as dependent on 58 — it's parallelizable. Task 58's description understates the obstacle: the real blocker is temporal coherence construction, not wiring.

**Central obstacle**: `construct_bfmcs` requires `B.temporally_coherent` proof. The deprecated implementation depends on the false `f_nesting_is_bounded`. The entire 5,300-line sorry-free algebraic path reduces to this single callback.

**Algebraic resolution strategies identified**:
- **(A) Zorn on R_G-chains**: Maximal chains through R_□-class exist; challenge is matching order type of D.
- **(B) Temporal shift automorphism**: Define τ on Lindenbaum algebra; FMCS = {τᵗ(U)}. Challenge: G is not invertible.
- **(C) Restricted chain + σ-duality** (recommended): Forward chain is sorry-free; use σ-duality for backward chain; dovetail into FMCS over ℤ. Shortest path leveraging existing infrastructure.

**STSA status**: Typeclass and LindenbaumAlg instance are fully sorry-free (TenseS5Algebra.lean, 350 lines). The STSA representation theorem (task 992) is a reorganization of existing code, not on critical path but provides the elegant algebraic framing.

**Custom axiom inventory**: Only `discrete_Icc_finite_axiom` remains (task 60). The `f_nesting_boundary` and `p_nesting_boundary` axioms were eliminated in task 56.

---

### 60. Remove discrete_Icc_finite_axiom
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Task 59

**Description**: Eliminate the custom axiom discrete_Icc_finite_axiom (FrameConditions/Completeness.lean line 187). Either prove the finiteness of DiscreteTimelineQuot intervals directly, or restructure the discrete completeness proof to avoid needing it. Research-heavy task.

---

### 58. Wire completeness to FrameConditions
- **Effort**: 4-6 hours
- **Status**: [BLOCKED]
- **Language**: lean4
- **Dependencies**: Task #85
- **Research**:
  - [63_team-research.md](058_wire_completeness_to_frame_conditions/reports/63_team-research.md) — Team research: seed consistency proof techniques (4 teammates)
  - [65_team-research.md](058_wire_completeness_to_frame_conditions/reports/65_team-research.md) — Team research: BRS blocker analysis - theorem is FALSE, bypass recommended
- **Plan**: [17_greedy-extension.md](058_wire_completeness_to_frame_conditions/plans/17_greedy-extension.md) — 4-phase greedy extension approach

**Description**: Wire completeness to FrameConditions. Post-tasks 83/84 status: wiring is DONE — `completeness_over_Int`, `discrete_completeness_fc`, and `dovetailed_bundle_validity_implies_provability` are structurally complete. Remaining sorries: (1) `forward_until_since_coherent` (3 sites, blocked by G-lift incompatibility — see task 85), (2) backward step transfer (6 sites, same root cause), (3) `dense_completeness_fc` (1 site, needs Rat canonical model — see task 68). Task 82 (FMP) provides weak completeness independently.

---

### 39. Study preorder semantics conformance with Task Semantics specifications
- **Effort**: 3h
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Plan**: [01_conformance-validation-plan.md](039_study_preorder_semantics_conformance/plans/01_conformance-validation-plan.md)
- **Reports**:
  - [01_teammate-a-findings.md](039_study_preorder_semantics_conformance/reports/01_teammate-a-findings.md) — Primary TaskFrame axiom analysis
  - [01_teammate-b-findings.md](039_study_preorder_semantics_conformance/reports/01_teammate-b-findings.md) — G-atom analysis and alternative approaches
  - [02_team-synthesis.md](039_study_preorder_semantics_conformance/reports/02_team-synthesis.md) — Team synthesis (updated with both teammates)
  - [03_parametric-taskframe-research.md](039_study_preorder_semantics_conformance/reports/03_parametric-taskframe-research.md) — ParametricCanonicalTaskFrame and W/D separation
  - [04_unification-implementation-research.md](039_study_preorder_semantics_conformance/reports/04_unification-implementation-research.md) — Two-layer unification analysis and implementation roadmap

**Description**: Study the implications of the preorder semantics which has been accepted to avoid the fresh G-atom proofs in order to determine whether the result still conforms to the specifications required by the Task Semantics.

---

### 21. Clean up technical debt from tasks 9-20
- **Effort**: 3-5 hours
- **Status**: [PLANNED]
- **Language**: lean4
- **Dependencies**: Tasks 15, 18
- **Plan**: [01_tech-debt-cleanup-plan.md](021_technical_debt_cleanup/plans/01_tech-debt-cleanup-plan.md) — 6 phases: axiom elimination, dead-code resolution, documentation
- **Research**:
  - [01_tech-debt-audit.md](021_technical_debt_cleanup/reports/01_tech-debt-audit.md) — comprehensive 4-agent parallel audit of all code from tasks 9-20
  - [02_team-research.md](021_technical_debt_cleanup/reports/02_team-research.md) — synthesized team research: axiom classification, derivation priorities, action plan
  - [02_teammate-a-findings.md](021_technical_debt_cleanup/reports/02_teammate-a-findings.md) — axiom semantic validity analysis
  - [02_teammate-b-findings.md](021_technical_debt_cleanup/reports/02_teammate-b-findings.md) — axiom proof dependencies and derivation paths
  - [02_teammate-c-findings.md](021_technical_debt_cleanup/reports/02_teammate-c-findings.md) — frame condition theory analysis

**Description**: Pay down technical debt accumulated across the metalogic refactoring track (tasks 9-20). Systematic cleanup in 4 phases: (1) **Dead code removal** — delete redundant lemmas in CanonicalTaskRelation.lean (iter_F_succ_eq, CanonicalTask_neg_succ_nat, 3 unused accessors), unused helpers in TimelineQuotBFMCS.lean (6 items), deprecated dead-end code in AlgebraicBaseCompleteness.lean (2 items). (2) **Deprecation marking** — mark discreteTaskFrame/denseTaskFrame as deprecated in DurationTransfer.lean, evaluate CanonicalRecovery.lean compat wrappers. (3) **Bridge assessment** — evaluate ClosedFlagIntBFMCS.lean bridge for simplification, assess downstream usage of compat wrappers, document dovetailing gap resolution path. (4) **Deferred items** — re-audit after tasks 18-20 complete to capture final debt state. Note: Tasks 18 (researching), 19 (not started), and 20 (not started) may introduce or resolve additional debt.

---

### 20. Audit and update parametric canonical infrastructure
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Tasks 15, 18
- **Research (task 6)**:
  - [19_role-in-representation-theorems.md](006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md) §2.2–2.3, §7 open question 3 — current duration-coarse relation vs duration-precise alternatives, question of parametric unification
  - [18_dense-three-place-task-relation.md](006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md) §4.3 — unified TaskFrame view showing both discrete/dense cases instantiate the same structure

**Description**: Review ParametricCanonical.lean, ParametricTruthLemma.lean, and ParametricRepresentation.lean. Determine whether the parametric infrastructure can be refactored to accept a generic task_rel parameter (not hardcoded duration-coarse relation), enabling both CanonicalTask and DenseTask as instantiations. If feasible, refactor; otherwise document the relationship between parametric (base) and specialized (discrete/dense) paths.

---

### 19. Deprecate old discrete pipeline
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Task 15
- **Research (task 6)**:
  - [20_succ-based-bypass-of-covering-lemma.md](006_canonical_taskframe_completeness/reports/20_succ-based-bypass-of-covering-lemma.md) §7 — side-by-side old vs new pipeline diagrams, explicit list of what is bypassed
  - [19_role-in-representation-theorems.md](006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md) §3.3 — current discrete pipeline and the SuccOrder blocker it gets replaced by

**Description**: Once discrete completeness is proved via Succ-chains (task 15), deprecate the old quotient-based pipeline: DiscreteTimelineElem, DiscreteTimelineQuot, SuccOrder/PredOrder construction attempt, and the orderIsoIntOfLinearSuccPredArch pathway. Mark files as deprecated with doc comments pointing to the new Succ-chain approach. Tasks 989 (discrete algebraic completeness) and 974 (SuccOrder) are superseded by tasks 10-15 and can be marked [EXPANDED].

---

### 18. Complete dense representation theorem via DenseTask
- **Effort**: 6-7 hours
- **Status**: [BLOCKED]
- **Language**: lean4
- **Dependencies**: Tasks 17, 27, 30, 31
- **Research (task 6)**:
  - [18_dense-three-place-task-relation.md](006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md) §5 — replacing CanonicalR with DenseTask in the dense setting, truth condition restatement
  - [19_role-in-representation-theorems.md](006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md) §3.2, §6 dense table — full wiring of dense representation pipeline, use of timelineQuot_instantiate_dense to close the domain mismatch
- **Research**:
  - [01_dense-representation-research.md](018_dense_representation_theorem_completion/reports/01_dense-representation-research.md)
  - [02_team-research.md](018_dense_representation_theorem_completion/reports/02_team-research.md) — team research: blocker analysis, domain confusion, correct approach
  - [05_team-research.md](018_dense_representation_theorem_completion/reports/05_team-research.md) — team research run 2: 7 real sorries, revised 4-phase plan A-D, no closure operator needed
  - [13_post-task27-analysis.md](018_dense_representation_theorem_completion/reports/13_post-task27-analysis.md) — post-task27: 4 localized sorries in j>0 termination, DovetailedTimelineQuot integration
- **Plan**: [04_dense-representation-v4.md](018_dense_representation_theorem_completion/plans/04_dense-representation-v4.md) — v4: post-task27 using DovetailedTimelineQuot, 3 remaining phases
- **Summary**: [03_implementation-summary.md](018_dense_representation_theorem_completion/summaries/03_implementation-summary.md) — Phases 1-2 complete (v3), plan revised for phases 3-5

**Description**: Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ into the unconditional dense representation theorem: valid_dense φ → ⊢_dense φ. Instantiate parametric truth lemma with D=TimelineQuot (which carries DenselyOrdered). Use timelineQuot_instantiate_dense to instantiate valid_dense at D=TimelineQuot. Resolves the Task 988 blocker via the DenseTask framework.

---

### 8. Establish genuine truth_at completeness theorems for TM logic
 **Effort**: 12-20 hours
 **Status**: [RESEARCHED]
 **Language**: lean4
 **Dependencies**: Task #1007
 **Research**:
  - [01_completeness-architecture.md](008_genuine_truth_at_completeness/reports/01_completeness-architecture.md)
  - [02_completeness-blockers.md](008_genuine_truth_at_completeness/reports/02_completeness-blockers.md)
  - [03_team-research.md](008_genuine_truth_at_completeness/reports/03_team-research.md)
  - [04_team-research.md](008_genuine_truth_at_completeness/reports/04_team-research.md)
 **Plan**: [03_revised-completeness-plan.md](008_genuine_truth_at_completeness/plans/03_revised-completeness-plan.md)

**Description**: Establish genuine completeness theorems for base, dense, and discrete TM logic using the official `truth_at` semantics over `TaskFrame D` with convex `WorldHistory` structures — not the internal `satisfies_at` substitute. The existing parametric infrastructure (ParametricCanonicalTaskFrame, ParametricTruthLemma, ParametricRepresentation) is already sorry-free and correctly uses `truth_at` with `domain = True` (trivially convex). The core open problem is constructing a multi-family `BFMCS D` satisfying both modal coherence (modal_backward requires multiple families, not singleton) and temporal coherence (forward_F/backward_P — linear chain constructions via Lindenbaum extension cannot satisfy these because F-witnesses escape the chain). CanonicalFMCS over CanonicalMCS solves F/P trivially but CanonicalMCS lacks AddCommGroup/LinearOrder. The gap is bridging sorry-free CanonicalMCS results to a concrete D (Int for base/discrete, Rat for dense). Supersedes tasks 997, 988, 989 in approach (those tasks remain as they track the individual completeness legs).

---

### 998. Redesign FMP filtration for strict temporal semantics
- **Effort**: TBD (estimated 4-8 hours)
- **Status**: [RESEARCHING]
- **Language**: lean4
- **Priority**: high
- **Related**: Tasks 74-77 (strict temporal extensions research track)

**Description**: Redesign the FMP (Finite Model Property) filtration for strict temporal semantics. The 2 sorry'd theorems in `Decidability/FMP/TruthPreservation.lean` — `mcs_all_future_closure` (line 263) and `mcs_all_past_closure` (line 281) — are deprecated because the temporal T-axiom (`Gφ → φ`) is NOT valid under strict semantics. `filtration_all_future_forward` and `filtration_all_past_forward` depend on them. The FMP module is separate from the main decidability pipeline (`decide` is sorry-free), but completing it formally proves the finite model property. Resolution options: (A) restrict FMP statement to serial frames where temporal seriality holds, (B) redesign filtration to avoid temporal reflexivity entirely, (C) prove the filtered model satisfies a weaker correctness property sufficient for the FMP theorem. Note: `mcs_finite_model_property` in `FMP.lean` does NOT directly use these sorry'd lemmas, so the impact is localized to `filtration_all_future_forward`/`backward`.

---


### 992. Implement Shift-Closed Tense S5 Algebra representation theorem
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [01_stsa-algebraic-analysis.md](992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md)

**Description**: Implement the Shift-Closed Tense S5 Algebra (STSA) representation theorem. Define STSA as a Lean structure extending BooleanAlgebra with box, G, H, sigma operators and interaction axioms. Lift temporal duality sigma from swap_temporal to the Lindenbaum quotient. Prove LindenbaumAlg is an STSA instance by wiring existing pieces (BooleanStructure, InteriorOperators, UltrafilterMCS). Restructure ParametricRepresentation into unified STSA representation theorem. Research report 001 provides complete algebraic analysis with ~80% of formalization already existing.

---


### 953. Refactor proof system to bilateral system
- **Effort**: 55-90 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Priority**: medium
- **Research**: [research-001.md](specs/953_refactor_proof_system_to_bilateral/reports/research-001.md), [research-002.md](specs/953_refactor_proof_system_to_bilateral/reports/research-002.md), [research-003.md](specs/953_refactor_proof_system_to_bilateral/reports/research-003.md)

**Description**: Refactor the TM proof system from a unilateral system (single judgment `Γ ⊢ φ`) to a bilateral system with dual judgments: acceptance (`Γ ⊢⁺ φ`) and rejection (`Γ ⊢⁻ φ`). The bilateral system makes the dual roles of assertion and denial explicit, with rules governing how acceptance and rejection interact across all connectives and operators. Key design: keep Formula type unchanged (Option A), add BilateralDeriv alongside existing DerivationTree with a proven equivalence bridge. Several current axioms (ex_falso, peirce, modal_t, temp_t_future, temp_t_past) become structural rules in the bilateral system. The existing signed formula infrastructure in the decidability module provides the blueprint.

**Research summary (research-003)**: Cost-benefit analysis recommends deferring bilateral refactor until higher-priority tasks (981: axiom debt, 951: completeness) progress. Benefits are primarily theoretical (assertion/denial duality, tableau alignment); existing unilateral system is adequate. Parallel-system approach (Option A) minimizes risk.

**Implementation approach**: Parallel bilateral system with equivalence bridge — not a replacement. Phase 1: bilateral infrastructure (BilateralContext, BilateralDeriv). Phase 2: prove equivalence with unilateral system. Phase 3: bilateral metalogic (MCS, FMCS, completeness). Phase 4: bilateral decidability integration.

---

### 949. Update Demo.lean for current bimodal logic state
- **Effort**: Small (~2 hours)
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [research-001.md](specs/949_update_demo_lean_bimodal_logic/reports/research-001.md)

**Description**: Update Theories/Bimodal/Examples/Demo.lean given the current state of the bimodal logic. The demo file should reflect the current API and showcase the working features of the bimodal logic implementation.

---

### 619. Migrate skills to native context:fork isolation
- **Effort**: 3 hours
- **Status**: [PLANNING]
- **Researched**: 2026-02-17
- **Language**: meta
- **Created**: 2026-01-19
- **Researched**: 2026-01-28
- **Planned**: 2026-01-19
- **Blocked on**: GitHub anthropics/claude-code #16803 (context:fork runs inline instead of forking)
- **Research**: [research-001.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-001.md), [research-006.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-006.md), [research-007.md](specs/619_agent_system_architecture_upgrade/reports/research-007.md)
- **Plan**: [implementation-002.md](specs/archive/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: Migrate all delegation skills from manual Task tool invocation to native `context: fork` frontmatter. Skills to migrate: skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta. Implementation plan has 3 phases: (1) verify bug fix with test skill, (2) migrate skill-researcher as pilot, (3) migrate remaining skills. Current workaround (Task tool delegation) continues to work. **Unblock when**: GitHub #16803 is closed AND fix verified locally. Last checked: 2026-02-17 — still OPEN (v2.1.32).

