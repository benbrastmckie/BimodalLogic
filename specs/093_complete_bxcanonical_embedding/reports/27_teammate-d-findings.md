# Teammate D Findings: Horizons -- ROAD_MAP Updates and Long-Term Strategy

**Task**: 93 -- Complete BXCanonical embedding
**Date**: 2026-04-16
**Role**: Horizons researcher (ROAD_MAP audit + strategic assessment)

---

## 1. ROAD_MAP Staleness Audit

The ROAD_MAP at `specs/ROAD_MAP.md` was last updated 2026-04-13 (task 103 rewrite). Since then, significant code changes have occurred. Here is a comprehensive line-by-line audit.

### 1.1 Sorry Line Numbers Are Wrong

The ROAD_MAP sorry inventory table (lines 24-29) lists:

| ROAD_MAP says | Actual (current code) | Status |
|---|---|---|
| `RootScopedChain.lean:1275` | `RootScopedChain.lean:1321` | **SHIFTED +46 lines** |
| `RootScopedChain.lean:1306` | `RootScopedChain.lean:1352` | **SHIFTED +46 lines** |
| `RootScopedChain.lean:1313` | `RootScopedChain.lean:1359` | **SHIFTED +46 lines** |
| `RootScopedChain.lean:1366` | `RootScopedChain.lean:1412` | **SHIFTED +46 lines** |
| `RootScopedChain.lean:1371` | `RootScopedChain.lean:1417` | **SHIFTED +46 lines** |
| `RootScopedChain.lean:1376` | `RootScopedChain.lean:1422` | **SHIFTED +46 lines** |

All 6 sorry line numbers are off by +46 lines. This is a consistent offset suggesting ~46 lines were added earlier in the file between 2026-04-13 and now.

### 1.2 Module Line Counts Are Wrong

ROAD_MAP line 249 states: **"Total BXCanonical module: 3,473 lines across 13 files, 1 sorry."**

**Actual current state:**

| File | ROAD_MAP lines | Actual lines | Delta |
|------|---------------|-------------|-------|
| BXCanonical.lean (aggregator) | (not listed) | 28 | NEW |
| CanonicalChain.lean | 157 | 157 | same |
| **CanonicalModel.lean** | **not listed** | **498** | **NEW FILE** |
| Completeness.lean | 163 | 152 | -11 |
| Frame.lean | 673 | 673 | same |
| **OrderedSeedConsistency.lean** | **not listed** | **255** | **NEW FILE** |
| **RootScopedChain.lean** | **not listed** | **1454** | **NEW FILE** |
| TruthLemma.lean | 320 | 320 | same |
| Filtration/DefectChain.lean | 137 | 137 | same |
| Filtration/SigmaOrdering.lean | 179 | 179 | same |
| Quasimodel/Construction.lean | 887 | 887 | same |
| Quasimodel/EnrichedClosure.lean | 158 | 158 | same |
| Quasimodel/HintikkaPoint.lean | 166 | 166 | same |
| Quasimodel/LocusControl.lean | 47 | 47 | same |
| Quasimodel/Realization.lean | 444 | 444 | same |
| Quasimodel/SubformulaClosure.lean | 114 | 114 | same |
| **TOTAL** | **3,473 (13 files)** | **5,669 (16 files)** | **+2,196 lines, +3 files** |

Three files are entirely missing from the ROAD_MAP import graph:
- `CanonicalModel.lean` (498 lines) -- the BFMCS bridge from chains to countermodel
- `OrderedSeedConsistency.lean` (255 lines) -- BX11 ordered seed consistency
- `RootScopedChain.lean` (1,454 lines) -- the chain construction with all 6 sorry sites

These 3 files represent **39% of the BXCanonical codebase** and contain ALL active sorry sites.

### 1.3 Sorry Inventory Is Internally Contradictory

- Line 17: "There are **6 sorries** blocking `bx_completeness`, all in `RootScopedChain.lean`"
- Line 427: "There is exactly **1 sorry** on the active completeness path, inside `Completeness.lean`"

The ROAD_MAP simultaneously claims 6 sorries and 1 sorry. The actual state:
- **Completeness.lean**: **0 sorries** (the sorry at line 154 was resolved via `dd_countermodel`)
- **RootScopedChain.lean**: **6 sorries** (the leaf sorries that `dd_countermodel` depends on)
- **Active-path total**: **6 sorries**, all in RootScopedChain.lean

The "1 sorry at Completeness.lean:154" language at line 427 is stale -- that sorry was resolved but delegated to RootScopedChain.lean. The top-level summary at line 17 is correct.

### 1.4 Task Cross-References Are Stale

| Task | ROAD_MAP says | Actual status | Issue |
|------|-------------|---------------|-------|
| 93 | [IMPLEMENTING] | [RESEARCHED] (per TODO.md) / "researching" (per state.json) | **Wrong status** |
| 103 | [NOT STARTED] | **Archived/Completed** (not in active state.json or TODO.md) | **Stale -- task completed** |
| 94 | [PLANNING] | **Archived/Completed** (not in active state.json or TODO.md) | **Stale -- task completed** |
| 82 | [NOT STARTED] | [NOT STARTED] | Correct |
| 68 | [RESEARCHED] | [RESEARCHED] | Correct |

### 1.5 Non-BXCanonical Sorry Count Is Stale

TODO.md header says `sorry_count: 140` (audited 2026-04-12). Actual non-Boneyard non-Examples count: **7** active `sorry` sites (6 in RootScopedChain + 1 in legacy SuccRelation.lean). The 140 figure likely includes legacy files; the distinction between "active-path" and "total non-Boneyard" needs clarification.

### 1.6 Description in ROAD_MAP Line 810

"Task 93: Close RootScopedChain.lean 6 sorries (chain replacement approach) -- **6 active-path sorries**" -- the description "chain replacement approach" is stale. After 26 rounds of research, the approach is undetermined. No viable chain replacement has been identified.

---

## 2. New Dead Ends to Document

The following dead ends emerged from research rounds 24-26 and should be appended to the ROAD_MAP Dead Ends section:

### Dead End 22: Defect Re-Entry in Enriched Chain (Perpetual Deferral)

**Source**: Report 26 (defect-reentry-analysis.md)

The enriched chain with `enriched_fwd_step` gives only a DISJUNCTIVE guarantee: at each step, for each sigma-formula chi, either chi in chain(n+1) OR F(chi) in chain(n+1). The Lindenbaum extension (`.choose` in `set_lindenbaum`) may place chi outside the MCS while keeping F(chi). This means previously-resolved formulas can RE-ENTER the defect set.

Concrete counterexample scenario: 2 formulas where BX11 ordering perpetually favors chi over psi. At psi's scheduled step, the fold changes the witness from psi to chi (Case 3 of BX11). Psi is never placed in any chain state. The existing `rr_fwd_chain` CANNOT prove `forward_F`.

### Dead End 23: G(F(chi)) Non-Derivability Blocking Persistent-Carry Seed

**Source**: Reports 24-26

For the enriched seed `{target} union g_content(M) union f_carry(M)` to be consistent, we need to show that g_content(M) cannot derive the negation of any F-formula in M. This requires `G(neg chi) notin M` whenever `F(chi) in M`. While this follows from `F(chi) in M` implying `neg G(neg chi) in M` (by MCS maximality), the deeper issue is that `G(F(chi))` does NOT follow from `F(chi)`. Without `G(F(chi)) in M`, the formula `F(chi)` cannot propagate through g_content to future chain points. This is the root cause of the forward_F gap.

### Dead End 24: Non-Enriched Chain F-Obligation Loss

**Source**: Report 24, Finding 4

The non-enriched chain (using `fwd_succ` with seed `{target} union g_content(M)`) guarantees target resolution at each step but LOSES other F-obligations. If F(psi) is present at step n but psi is not the target at step n, F(psi) may not persist to step n+1. This was initially considered a "feature" (only unresolved obligations matter), but it means F-obligations can vanish before their scheduled resolution step, making forward_F trivially true for lost formulas but impossible to prove for surviving ones.

### Dead End 25: Quasimodel BXPoint-to-Int Bridging Gap

**Source**: Report 25 (bfmcs-quasimodel-witnesses.md)

The quasimodel infrastructure (2,289 lines, sorry-free) solves eventuality at the BXPoint level via `bx_until_eventuality_resolution`. However, these witnesses are abstract BXPoints, not indices in the Int-indexed chain. The restricted parametric truth lemma requires temporal coherence at Int indices. Bridging BXPoint witnesses to Int chain indices requires the chain to contain the witness BXPoints at specific indices, which is exactly the forward_F problem restated. The quasimodel does NOT provide a shortcut.

### Dead End 26: Semantic Coherence Circularity

**Source**: Reports 24-25

The restricted truth lemma requires `restricted_temporally_coherent root` as a hypothesis, which IS forward_F restricted to `deferralClosure(root)`. Using the truth lemma to derive forward_F creates a circular dependency. The "perpetual deferral implies G(neg psi)" argument requires the truth lemma to interpret G, but the truth lemma requires forward_F.

---

## 3. Strategic Assessment

### 3.1 Current State Summary

After 26 rounds of research (14+ team research rounds, 2 solo deep-dives, multiple implementation attempts), the situation is:

- **6 sorry sites** remain in RootScopedChain.lean
- **All 6** trace to the same root cause: `rr_fwd_chain_forward_F`
- **The existing chain construction** has been proven UNABLE to resolve forward_F (Report 26)
- **21+ dead ends** document blocked approaches
- **5,669 lines** of BXCanonical infrastructure, ~99.9% sorry-free
- **The mathematical obstruction is identified**: G(F(chi)) does not follow from F(chi), preventing syntactic eventuality propagation through g_content chains

### 3.2 Viable Long-Term Approaches

**Approach A: Modified Chain Construction (New Chain Type)**
- Replace `enriched_fwd_step` with a demand-driven step that resolves a specific target per step
- Key challenge: must avoid defect re-entry while preserving all F-obligations
- Requires a monotonic well-founded measure (not yet identified)
- Confidence: 30-40%
- Effort: 10-20 hours pen-and-paper + 40-80 hours Lean

**Approach B: Full Canonical Model Restructuring**
- Abandon the Int-indexed chain entirely
- Build the BFMCS directly from the quasimodel infrastructure
- Use BXPoint-level eventuality resolution (already sorry-free) as the primary mechanism
- Key challenge: bridging abstract BXPoint witnesses to a concrete linear ordering on D
- Confidence: 25-35%
- Effort: 60-120 hours total (major architectural change)

**Approach C: Semantic Argument (Published Proof Techniques)**
- Follow Goldblatt 1992 or Burgess 1984 more closely
- These proofs handle F-eventuality SEMANTICALLY via the full canonical model, not syntactically via chain construction
- Key challenge: the current Lean infrastructure is designed around syntactic chain construction; a semantic approach would require significant refactoring
- Confidence: 40-50% (highest, as it follows published proofs)
- Effort: 40-80 hours

**Approach D: Pen-and-Paper First**
- Before any more Lean implementation, produce a complete pen-and-paper proof of forward_F
- Identify the exact mathematical argument that published proofs use
- Then translate to Lean
- Confidence: N/A (meta-approach)
- Effort: 8-20 hours pen-and-paper

**Recommendation**: Approach D (pen-and-paper first) is the CORRECT next step. 26 rounds of automated research have exhaustively mapped the obstacle space without finding a viable path. Human mathematical insight is needed before more Lean implementation. Approach C (following published proofs more closely) has the highest confidence once the mathematical argument is understood.

### 3.3 Should the Project Be Abandoned?

**No.** The project has 5,669 lines of sorry-free canonical model infrastructure, a complete truth lemma, and sorry-free soundness. The forward_F problem is disproportionately difficult but is a single mathematical obstruction, not a fundamental architectural failure. The quasimodel infrastructure (Until/Since closure) is a genuine achievement. Abandonment would waste significant correct work.

---

## 4. Code Metrics (Current)

| Metric | ROAD_MAP value | Actual value |
|--------|---------------|-------------|
| BXCanonical files | 13 | 16 |
| BXCanonical lines | 3,473 | 5,669 |
| Active-path sorries | 1 (at Completeness.lean:154) | 6 (all at RootScopedChain.lean) |
| Completeness.lean sorries | 1 | 0 |
| RootScopedChain.lean sorries | (not mentioned) | 6 |
| Non-Boneyard non-Examples sorries | 140 | 7 |
| Dead ends documented | 21 | 21 (need 5 more: 22-26) |
| Research rounds for task 93 | (not tracked in ROAD_MAP) | 26+ |
| New files since ROAD_MAP | 0 | 3 (CanonicalModel, OrderedSeedConsistency, RootScopedChain) |

---

## 5. Publication Readiness Assessment

### 5.1 What Is Publishable Now

Even without closing forward_F, the project has publishable partial results:

1. **Complete soundness** (sorry-free): All 37 BX axioms are sound on reflexive linear temporal frames.

2. **Until/Since eventuality resolution** (sorry-free): The Hintikka-set quasimodel with defect-discharge construction (2,289 lines) is a novel formalization technique. It closes the 4 hardest Frame.lean sorries via well-founded recursion on sigma-restricted defect count.

3. **Truth lemma** (sorry-free): Full formula-induction truth lemma connecting MCS membership to semantic truth for all 8 formula constructors (atom, bot, imp, box, G, H, U, S).

4. **Canonical frame construction** (sorry-free): BXPoint frame with `bx_le` ordering, reflexivity, transitivity, S5 modal equivalence, and all witness lemmas.

5. **Completeness modulo forward_F**: The theorem `bx_completeness` is complete except for the 6 forward_F-related sorries. This is a clearly documented and well-understood gap.

### 5.2 Publication Strategy

**Option 1: Full completeness paper** (requires closing forward_F)
- Standard publication in a formal methods or theorem proving venue
- Comparable to existing Lean formalizations of modal logics
- Estimated additional effort: 40-120 hours (uncertain)

**Option 2: Partial result + infrastructure paper**
- Publish the Until/Since closure technique as a novel contribution
- Document the forward_F obstruction as an open problem
- Venue: ITP, CPP, or LICS workshop
- Ready NOW (modulo writing)

**Option 3: Extended abstract + repository**
- Publish the repository with documentation
- Focus on the 5,669-line sorry-free infrastructure
- Venue: Lean Together, ICMS, or similar workshop

**Recommendation**: Option 2 is the pragmatic choice. The Until/Since closure via defect-discharge is a genuine contribution regardless of forward_F's resolution. Option 1 remains the long-term goal.

---

## 6. Specific ROAD_MAP.md Update Recommendations

### 6.1 Sections to Update

1. **Lines 17-31 (sorry summary table)**: Fix all 6 line numbers (+46 offset). Remove the "Completeness.lean:154" entry (no longer sorry). Add note that Completeness.lean is sorry-free.

2. **Lines 194-249 (Module Import Graph)**: Add CanonicalModel.lean, OrderedSeedConsistency.lean, RootScopedChain.lean to the import graph. Update total to "5,669 lines across 16 files, 6 sorries."

3. **Lines 425-431 (Active-Path Sorry Inventory)**: Rewrite. The sole sorry is NOT in Completeness.lean. All 6 are in RootScopedChain.lean. Completeness.lean delegates to `dd_countermodel` which depends on the 6 RootScopedChain sorries.

4. **Lines 679-701 (Task 93: Progress and Infrastructure)**: Update to reflect 26+ rounds of research, the proven impossibility of the existing chain construction, and the 5 new dead ends.

5. **Lines 773-797 (Recommended Priority Order)**: Update task 93 description. Remove "chain replacement approach" and replace with "requires new mathematical approach, pen-and-paper work recommended."

6. **Lines 799-818 (Task Cross-Reference)**: Remove tasks 103 and 94 (completed/archived). Fix task 93 status. Add note about 26 research rounds.

### 6.2 Sections to Add

1. **New section: "Forward_F Obstruction (Task 93)"**: A dedicated section explaining the mathematical obstruction, the 26 rounds of research, the 5 new dead ends (22-26), and the recommended next steps.

2. **New section: "Publication Readiness"**: What is publishable now vs. what requires forward_F closure.

### 6.3 Dead Ends to Append

Append dead ends 22-26 (described in section 2 above) to the existing Dead Ends section.

### 6.4 Priority Ordering Changes

- Task 93 should be marked as requiring pen-and-paper mathematical work before further Lean implementation
- Tasks 104 and 105 (cleanup) should be elevated since they are actionable regardless of forward_F
- A new task for ROAD_MAP update (incorporating these findings) should be created

---

## 7. Key Findings Summary

1. **ROAD_MAP is significantly stale**: Wrong sorry line numbers (+46), wrong module counts (3,473 vs 5,669), missing 3 files (39% of BXCanonical), internally contradictory sorry inventory, stale task cross-references for 103 and 94 (completed but listed as not started/planning).

2. **5 new dead ends (22-26)**: Defect re-entry, G(F(chi)) non-derivability, non-enriched F-loss, quasimodel bridging gap, semantic circularity. All establish that the existing chain construction CANNOT prove forward_F.

3. **Strategic recommendation**: Pen-and-paper proof before more Lean implementation. Follow published proof techniques (Goldblatt 1992) more closely for the semantic eventuality argument. Do NOT abandon the project.

4. **Publishable partial result exists**: The Until/Since defect-discharge construction is a novel contribution independent of forward_F.

5. **Actual sorry state**: 6 sorries in RootScopedChain.lean (not 1 in Completeness.lean as ROAD_MAP section 2 claims). Completeness.lean is sorry-free. BXCanonical is 5,669 lines across 16 files.

6. **Long-term confidence**: 40-50% that Approach C (following published semantic proofs) will succeed, pending pen-and-paper mathematical analysis. 30-40% for modified chain construction. Combined probability of eventually closing forward_F: ~60-70%.
