---
next_project_number: 110
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-04-12T00:00:00Z
task_counts:
  active: 24
  completed: 760
  in_progress: 0
  not_started: 13
  abandoned: 69
  total: 853
technical_debt:
  sorry_count: 140
  sorry_count_note: "Audited 2026-04-12: 140 non-Boneyard (1 active-path at BXCanonical/Completeness.lean:154), 171 Boneyard (includes 107 archived by task 94). Soundness and Decidability are sorry-free."
  publication_path_sorries: 1
  axiom_count: 0
  axiom_count_note: "Zero custom axioms. discrete_Icc_finite_axiom eliminated. f_nesting_boundary/p_nesting_boundary eliminated in task 56."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-04-20. Post-task-93 review: abandoned 89, 87, 74, 75, 76, 82 (superseded by irreflexive switch). Created 106-109. Revised 95 (depends on 109), 104 (narrowed scope).*

**Goal**: Close the 11 chain construction sorries (task 109) for sorry-free `bx_completeness`, archive legacy code, update documentation for irreflexive semantics.

### 1. Critical Path — BXCanonical Completeness

```
93 → 109 → 95
```

1. **93** [COMPLETED] — Close TaskModel embedding sorry (seriality + Nontrivial fix)
2. **109** [NOT STARTED] — Close 11 chain construction sorries (5 RootScopedChain + 6 CanonicalModel) — the hard open problem
3. **95** [NOT STARTED] — Verification audit: #print axioms + sorry classification pass (depends on 109)

### 2. Documentation & Cleanup

4. **106** [NOT STARTED] — Rewrite ROADMAP.md for irreflexive semantics (critical)
5. **107** [NOT STARTED] — Archive dead Quasimodel code (OracleStep + BXCanonical/Boneyard)
6. **108** [NOT STARTED] — Audit SoundnessLemmas.lean sorry sites
7. **105** [NOT STARTED] — Update stale sorry-blocker comments in BXCanonical code
8. **104** [NOT STARTED] — Clean up stale task state and metrics

### 3. Independent Completeness Paths (parallel)

- **998** [RESEARCHING] — FMP redesign for irreflexive temporal semantics
- **68** [RESEARCHED] — Prove dense_completeness_fc via Rat canonical model (needs Rat construction)

### 4. Experimental / Research

- **992** [RESEARCHED] — STSA temporal shift automorphism (algebraic, independent)
- **64** [RESEARCHED] — Critical path review (reference only)

### 5. Deferred

- **18** [BLOCKED] — Dense representation theorem (4 sorries, defer until base is clean)
- **20** [NOT STARTED] — Parametric canonical audit (depends on 18)
- **21** [PLANNED] — Tech debt cleanup (depends on 18)
- **19** [NOT STARTED] — Deprecate old discrete pipeline (low priority)

### 6. Backlog

- **8** [RESEARCHED] — Genuine truth_at completeness (publication quality, 12-20h)
- **39** [RESEARCHED] — Preorder semantics study (theoretical)
- **953** [RESEARCHED] — Bilateral proof system (55-90h)
- **949** [RESEARCHED] — Update Demo.lean (cosmetic)
- **619** [RESEARCHED] — Agent system architecture upgrade (meta, blocked on GitHub #16803)

## Tasks

---

### 109. Close chain construction sorries for sorry-free completeness
- **Effort**: 20-40 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: critical
- **Created**: 2026-04-20
- **Dependencies**: 93
- **Description**: Close the 11 active-path sorry sites that are the sole remaining obstacle to a sorry-free `bx_completeness` theorem. These form a dependency diamond rooted in the irreflexive semantics redesign of the canonical chain construction.

#### Sorry Sites

**CanonicalModel.lean (6 sorries) — seed consistency and g/h_content identity:**

| # | Line | Theorem | Issue |
|---|------|---------|-------|
| 1 | 56 | `enriched_seed_consistent` | `g_content(M) ∪ f_carry(M)` consistent — relied on `g_content(M) ⊆ M` via BX1 (removed) |
| 2 | 101 | `fwd_succ_f_carry` | F-carry preservation at non-resolving steps — **genuinely unprovable** as stated (non-resolving branch seeds with `g_content(M)` only) |
| 3 | 117 | `enriched_past_seed_consistent` | `h_content(M) ∪ p_carry(M)` consistent — mirror of #1, relies on BX1' (removed) |
| 4 | 167 | `bwd_pred_p_carry` | P-carry preservation at non-resolving steps — mirror of #2, **genuinely unprovable** |
| 5 | 207 | `g_content_subset_self` | `g_content(M) ⊆ M` — **genuinely false** under irreflexive semantics (requires G(phi)->phi) |
| 6 | 213 | `h_content_subset_self` | `h_content(M) ⊆ M` — mirror of #5, **genuinely false** |

**RootScopedChain.lean (5 sorries) — chain coherence:**

| # | Line | Theorem | Issue |
|---|------|---------|-------|
| 7 | 1065 | `fwd_chain_forward_F` | F-resolution: prove F(phi) eventually resolved via well-founded induction on defect count. Blocked by BX11 perpetual deferral — `.choose` can indefinitely defer any specific formula. |
| 8 | 1092 | `dd_bfmcs_restricted_tc` (fwd) | Restricted temporal coherence, backward chain F-case |
| 9 | 1099 | `dd_bfmcs_restricted_tc` (bwd) | Restricted temporal coherence, P-resolution direction |
| 10 | 1107 | `dd_bfmcs_restricted_buc` | Backward Until/Since coherence — requires step transfer property blocked under Lindenbaum chains |
| 11 | 1114 | `dd_bfmcs_restricted_fuc` | Forward Until/Since coherence — depends on restricted_tc + BX10/BX12 Until propagation |

#### Dependency Structure

```
CanonicalModel (redesign)
├── g_content_subset_self (#5,#6) ─── genuinely false, need alternative
├── enriched_seed_consistent (#1,#3) ── need seriality-based consistency proof
└── f/p_carry preservation (#2,#4) ─── need chain redesign (enriched seeds)
         │
         ▼
fwd_chain_forward_F (#7) ─── needs F-preservation + termination argument
         │
         ▼
restricted_tc (#8,#9) ─── forward/backward temporal coherence
         │
    ┌────┴────┐
    ▼         ▼
restricted_buc (#10)  restricted_fuc (#11)
```

#### Root Cause

Under irreflexive semantics (task 93), BX1 (`G(phi) -> phi`) was removed. This breaks `g_content(M) ⊆ M`, which was the foundation of:
- Seed consistency proofs (g_content ∪ f_carry ⊆ M, hence consistent)
- F-carry preservation (non-resolving step could include f_carry because it was ⊆ M)
- Chain ordering base cases (fwd_chain_g_content_trans at m=n=0)

The chain construction needs a fundamental redesign. Two genuinely unprovable theorems (fwd_succ_f_carry, bwd_pred_p_carry) and two genuinely false theorems (g_content_subset_self, h_content_subset_self) must be replaced, not just proved.

#### Known Approaches (from 50+ research rounds)

1. **Defect-driven chain with well-founded induction**: Track active F-defects (`{phi | F(phi) in chain(n), phi not in chain(n)}`). If the chain resolves one defect per step via BX11 fold, the defect set decreases. Blocked by: `.choose` opacity — no proof that a *specific* formula is resolved.

2. **Enriched Lindenbaum seed**: Seed with `g_content(M) ∪ f_carry(M)` instead of bare `g_content(M)`. Requires proving the enriched seed is consistent without `g_content ⊆ M`. Potential via seriality: `T -> F(T)` gives non-emptiness, and `f_carry(M) ⊆ M` (since F(chi) ∈ M implies F(chi) is in M).

3. **Quasimodel BFMCS bridge**: Use the existing quasimodel infrastructure (finite Hintikka chains with defect discharge) to construct a witness, then bridge to the Int-indexed FMCS family. Gap: `HintikkaStepOracle` is never constructed; finite-to-Int bridge is missing.

4. **Deterministic chain construction**: Replace Lindenbaum-based non-deterministic chains with deterministic X/Y-content chains. Requires well-ordering of formulas and explicit enumeration. Substantial rewrite.

#### Key Insight for Enriched Seed Path

`f_carry(M) ⊆ M` is trivially true (by definition, `f_carry(M) = {phi ∈ M | ∃ chi, phi = F(chi)}`). So `g_content(M) ∪ f_carry(M)` is consistent iff it doesn't derive `⊥`. The standard proof lifts a contradiction to `G(neg(psi))` for some `psi` in the seed. For `g_content` elements this works (they are `G(chi)`). For `f_carry` elements `F(chi)`, we need `G(neg(F(chi)))` ∈ M, which is equivalent to `H(neg(F(chi)))` via modal equivalence — this may or may not be available.

#### Definition of Done

- All 11 sorry sites closed or replaced with sorry-free alternatives
- `bx_completeness` theorem compiles with `#print axioms` showing only `{propext, Classical.choice, Quot.sound}`
- `lake build` passes with no new sorry sites on the active completeness path
- If chain construction is redesigned, existing API surface preserved where possible

---

### 108. Audit SoundnessLemmas.lean sorry sites
- **Effort**: 3-5 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: high
- **Created**: 2026-04-20
- **Description**: Audit 28 sorry occurrences in SoundnessLemmas.lean. Classify each as closeable under irreflexive semantics, genuinely blocked, or in block-commented sorry'd theorem. Close straightforward ones. Document blocked ones.

---

### 107. Archive dead Quasimodel code to Boneyard
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: high
- **Created**: 2026-04-20
- **Description**: Move OracleStep.lean (25 sorries, orphaned), OracleCoherence.lean (14 sorries), and RoundRobinChain.lean (5 sorries) from BXCanonical to main Boneyard/. Remove from build chain. Net reduction ~44 sorry occurrences. Add README.

---

### 106. Rewrite ROADMAP.md for irreflexive semantics
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Language**: markdown
- **Priority**: critical
- **Created**: 2026-04-20
- **Description**: ROADMAP says "fully reflexive" throughout but semantics is now irreflexive. Rewrite Overview, update sorry inventory line numbers, update axiom tables (BX1/BX1' -> seriality, BX8/BX8' removed, BX2 reformulated), document task 93 outcome and remaining CanonicalModel sorry cluster.

---

### 105. Update stale sorry-blocker comments in BXCanonical code
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: high
- **Created**: 2026-04-12
- **Related**: Tasks 93, 102

**Description**: Update stale sorry-blocker comments in BXCanonical code files. (1) Completeness.lean:149-153 lists Until/Since and Frame.lean X-vs-G mismatch as remaining blockers — these are now resolved by tasks 98+102. (2) Frame.lean:440-441 says "For now, sorry the full modal equivalence" but the proof is now complete. (3) BXCanonical.lean:20 says "sorry for full completeness" — should note only TaskModel embedding remains. (4) Verify no other stale sorry references in the 13 BXCanonical files. Also update X/Y operator docstrings in Formula.lean:328-334 (reference stale strict semantics).

---

### 104. Clean up stale task state and metrics
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Language**: meta
- **Priority**: medium
- **Created**: 2026-04-12

**Description**: Clean up remaining stale task state after post-task-93 review (which abandoned 89, 87, 74, 75, 76, 82): (1) Update task 60 to remove dependency on nonexistent task 59 and reassess `discrete_Icc_finite_axiom` status. (2) Fix state.json `technical_debt` metrics: update `sorry_count`, `publication_path_sorries` to reflect current state (11 active-path sorries). (3) Update TODO.md frontmatter metrics to match.

---

### 93. Close TaskModel embedding sorry (sole remaining active-path sorry)
- **Effort**: 4-8 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-04-20
- **Summary**: Added Nontrivial D to validity definitions, closed 2 serial axiom sorries + 2 bonus sorries, fixed OracleStep build failures. Net -2 sorries, lake build clean.
- **Language**: lean4
- **Priority**: critical
- **Dependencies**: None (tasks 90, 92, 98, 102 completed)
- **Created**: 2026-04-10
- **Related**: Tasks 92, 95, 102
- **Research**:
  - [01_taskmodel-embedding.md](specs/093_complete_bxcanonical_embedding/reports/01_taskmodel-embedding.md)
  - [02_team-research.md](specs/093_complete_bxcanonical_embedding/reports/02_team-research.md)
  - [03_team-research.md](specs/093_complete_bxcanonical_embedding/reports/03_team-research.md)
  - [093_complete_bxcanonical_embedding/reports/17_round-robin-chain-history.md]
  - [093_complete_bxcanonical_embedding/reports/19_team-research.md]
  - [093_complete_bxcanonical_embedding/reports/20_bilateral-submaximal.md]
  - [21_team-research.md](specs/093_complete_bxcanonical_embedding/reports/21_team-research.md)
  - [093_complete_bxcanonical_embedding/reports/22_team-research.md]
  - [093_complete_bxcanonical_embedding/reports/23_team-research.md]
  - [25_bfmcs-quasimodel-witnesses.md](specs/093_complete_bxcanonical_embedding/reports/25_bfmcs-quasimodel-witnesses.md)
  - [26_defect-reentry-analysis.md](specs/093_complete_bxcanonical_embedding/reports/26_defect-reentry-analysis.md)
  - [27_team-research.md](specs/093_complete_bxcanonical_embedding/reports/27_team-research.md)
  - [093_complete_bxcanonical_embedding/reports/28_depth-zero-base-case.md]
  - [093_complete_bxcanonical_embedding/reports/31_forward-f-blocker.md]
  - [093_complete_bxcanonical_embedding/reports/33_team-research.md]
  - [093_complete_bxcanonical_embedding/reports/37_team-research.md]
  - [093_complete_bxcanonical_embedding/reports/38_team-research.md]
  - [093_complete_bxcanonical_embedding/reports/42_team-research.md]
- **Plan**:
    - [02_bxcanonical-embedding.md](specs/093_complete_bxcanonical_embedding/plans/02_bxcanonical-embedding.md)
    - [04_bxcanonical-embedding.md](specs/093_complete_bxcanonical_embedding/plans/04_bxcanonical-embedding.md)
    - [05_bxcanonical-embedding.md](specs/093_complete_bxcanonical_embedding/plans/05_bxcanonical-embedding.md)
    - [06_bxcanonical-embedding.md](specs/093_complete_bxcanonical_embedding/plans/06_bxcanonical-embedding.md)
    - [08_bxcanonical-embedding.md](specs/093_complete_bxcanonical_embedding/plans/08_bxcanonical-embedding.md)
    - [11_bxcanonical-embedding.md](specs/093_complete_bxcanonical_embedding/plans/11_bxcanonical-embedding.md)
    - [13_bxcanonical-embedding.md](specs/093_complete_bxcanonical_embedding/plans/13_bxcanonical-embedding.md)
    - [14_bxcanonical-embedding.md](specs/093_complete_bxcanonical_embedding/plans/14_bxcanonical-embedding.md)
  - [093_complete_bxcanonical_embedding/plans/15_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/16_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/17_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/18_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/21_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/22_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/23_bxcanonical-embedding.md]
- **Summary**:
  - [093_complete_bxcanonical_embedding/summaries/23_bxcanonical-embedding-summary.md]
  - [093_complete_bxcanonical_embedding/summaries/27_bxcanonical-embedding-summary.md]
  - [093_complete_bxcanonical_embedding/plans/27_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/28_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/29_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/30_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/32_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/summaries/32_bxcanonical-embedding-summary.md]
  - [093_complete_bxcanonical_embedding/plans/33_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/35_bxcanonical-embedding.md]
  - [36_teammate-a-findings.md](specs/093_complete_bxcanonical_embedding/reports/36_teammate-a-findings.md)
  - [093_complete_bxcanonical_embedding/plans/36_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/37_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/38_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/39_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/41_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/42_bxcanonical-embedding.md]
  - [093_complete_bxcanonical_embedding/plans/48_bxcanonical-embedding.md]

**Description**: Close the sole remaining BXCanonical sorry: TaskModel embedding at `BXCanonical/Completeness.lean:154`. This constructs a `TaskModel` from the BXPoint canonical frame. The Box-direction sorry (Frame.lean:440) was closed by task 102. All 4 Until/Since sorries (Frame.lean:653, 675, 690, 704) were closed by tasks 90+92+98+102. Once this sorry is closed, `bx_completeness` becomes sorry-free, and `#print axioms` should list only `propext`, `Classical.choice`, `Quot.sound`. The TaskModel embedding must use non-constant histories (constant histories collapse G to identity — see ROAD_MAP.md anti-pattern #12).

---

### 95. Verification audit: #print axioms + sorry classification pass
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: medium
- **Dependencies**: Tasks 93, 109
- **Created**: 2026-04-10
- **Related**: Tasks 60, 93, 109

**Description**: Verification pass to confirm sorry-free completeness after task 109 closes the chain construction sorries. (1) Run `#print axioms` on `bx_completeness`; confirm output is exactly `{propext, Classical.choice, Quot.sound}` with no `sorry` dependency. (2) Classify all `sorry` occurrences in `Soundness.lean` and `SoundnessLemmas.lean` (real sorry vs docstring/comment). (3) Confirm `soundness`, `soundness_dense`, `soundness_discrete` build with only standard axioms. (4) Audit for any custom Lean `axiom` declarations (expected: possibly `discrete_Icc_finite_axiom` per task 60). (5) Produce audit report at `specs/reviews/completeness-audit-{DATE}.md`. Depends on task 109 for full completeness verification.

---

### 89. Close 4 Frame.lean eventuality resolution sorries via quasimodel or Henkin construction
- **Effort**: 40-80 hours
- **Status**: [ABANDONED]
- **Abandoned**: 2026-04-20
- **Reason**: Fully superseded by completed tasks 90+92+98+102 which closed all 4 Frame.lean sorries.
- **Language**: lean4
- **Priority**: high
- **Dependencies**: None (independent of task 88 CanonicalEmbedding)
- **Created**: 2026-04-10

---

---

### 87. Full representation theorem with Until/Since via enriched chain construction in Bundle/
- **Effort**: 40-60 hours
- **Status**: [ABANDONED]
- **Abandoned**: 2026-04-20
- **Reason**: Bundle/ enriched chain approach superseded by BXCanonical path (task 109). Bundle/ has 14 sorry sites referencing removed BX1.
- **Language**: lean4
- **Dependencies**: Task 86 (USF fragment completeness)
- **Created**: 2026-04-09

---

---

### 82. Close FMP TruthPreservation Sorries
- **Effort**: 1-2 hours
- **Status**: [ABANDONED]
- **Abandoned**: 2026-04-20
- **Reason**: Description assumes reflexive semantics and temp_t_future/temp_t_past axioms which were removed in task 93 (irreflexive switch). Subsumed by task 998 (FMP redesign for irreflexive semantics).
- **Language**: lean4
- **Priority**: high
- **Created**: 2026-04-02

---

---

### 74. Research strict vs reflexive temporal semantics for TM logic
- **Effort**: 4-6 hours
- **Status**: [ABANDONED]
- **Abandoned**: 2026-04-20
- **Reason**: Question answered by task 93: switched to irreflexive semantics with BX1/BX1' replaced by seriality axioms.
- **Language**: formal
- **Priority**: high
- **Created**: 2026-03-31

---

### 75. Research G'/H' operator extension design for TM logic
- **Effort**: 4-6 hours
- **Status**: [ABANDONED]
- **Abandoned**: 2026-04-20
- **Reason**: Moot: semantics settled on irreflexive in task 93. G'/H' extension not needed since G/H now use strict quantification directly.
- **Language**: formal
- **Priority**: high
- **Created**: 2026-03-31
- **Dependencies**: Task 74

---

### 76. Research unified density/discreteness completeness paths
- **Effort**: 4-6 hours
- **Status**: [ABANDONED]
- **Abandoned**: 2026-04-20
- **Reason**: Framed around strict-vs-reflexive question resolved by task 93 (irreflexive switch). Dense completeness continues independently as task 68.
- **Language**: formal
- **Priority**: high
- **Created**: 2026-03-31
- **Dependencies**: Tasks 74, 75

---







### 68. Prove dense_completeness_fc via Rat canonical model
- **Effort**: 6-10 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task #72
- **Parent Task**: #58
- **Research**: [83_spawn-analysis.md](058_wire_completeness_to_frame_conditions/reports/83_spawn-analysis.md)

**Description**: Eliminate the sorry in dense_completeness_fc (FrameConditions/Completeness.lean line 121) by constructing a canonical model over Rat. Int cannot be used because Int is not densely ordered. Rat is countable, aligning with existing Lindenbaum/countable MCS machinery.

**Hint**: BX5 self-accumulation (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population — it propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`. Use Cantor-domain chain construction over a countable dense order, with interval-filling for Until guards.

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

**Hint**: BX5 self-accumulation (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population — it propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`. Use Cantor-domain chain construction over a countable dense order, with interval-filling for Until guards.

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

**Hint (dense leg)**: BX5 self-accumulation (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population — it propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`. Use Cantor-domain chain construction over a countable dense order, with interval-filling for Until guards.

---

### 998. Redesign FMP filtration for strict temporal semantics
- **Effort**: TBD (estimated 4-8 hours)
- **Status**: [RESEARCHED]
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

