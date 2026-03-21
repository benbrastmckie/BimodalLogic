# Teammate A Findings: BFMCS Domain Conflation Audit

**Task**: 28 - correct_bfmcs_domain_conflation
**Date**: 2026-03-21
**Focus**: Primary implementation approaches and patterns
**Analyst**: lean-research-agent (teammate-a)

---

## Key Findings

### 1. Current State: Where is the W=D Conflation?

The W=D conflation has **two distinct manifestation sites** in the active codebase:

#### Site 1: `DirectMultiFamilyBFMCS.lean` (Bundle/DirectMultiFamilyBFMCS.lean)

**File**: `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean`

This is the v4 construction for discrete completeness (used by `construct_bfmcs_from_mcs_Int_v4`). It builds a `BFMCS Int` but the domain `Int` appears only as the FMCS indexing type — each family is `FMCS Int` built via `intFMCS_basic`. The conflation occurs in the family structure:

```lean
structure DirectClosedFamily where
  root : CanonicalMCS                       -- W: a world state
  root_in_closed : root ∈ discreteClosedMCS M0
  toFMCS : FMCS Int                         -- D = Int (correct)
  toFMCS_eq : toFMCS = intFMCS_basic root.world root.is_mcs
```

The FMCS domain is correctly `Int`. However, the **modal saturation argument** treats `CanonicalMCS` as if it plays the role of time index D — the cross-family modal coherence (`directFamilies_modal_forward` at t≠0 and `directFamilies_modal_backward` at t≠0) has 4 remaining sorries precisely because the `discreteClosedMCS M0` set is defined over `CanonicalMCS` (worlds), not `Int` (time). The coverage properties are stated at `CanonicalMCS` level but the BFMCS families are indexed by `Int`.

#### Site 2: `MultiFamilyBFMCS.lean` (Algebraic/MultiFamilyBFMCS.lean)

**File**: `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`

This file contains two **explicitly marked dead-end constructions**:

1. `singletonCanonicalBFMCS : BFMCS CanonicalMCS` — directly conflates W=D by using `CanonicalMCS` as the BFMCS domain parameter. The file header states:

   > **Domain Confusion**: CanonicalMCS is the domain of **world states** (W), NOT the duration domain (D). Using CanonicalMCS as BFMCS indexing type creates degenerate mcs(w) = w.world

2. `canonical_modal_backward` — has a `sorry` (line 595) that **cannot be eliminated** due to the same W=D conflation. The singleton approach requires `phi in t.world → Box phi in t.world`, which is false in modal logic.

Both are marked "DEAD END" with architectural explanations. They are not used in any active completeness proof but their `sorry` status contributes to the project's sorry count.

#### Site 3: `TimelineQuotBFMCS.lean` (StagedConstruction/TimelineQuotBFMCS.lean)

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean`

This file uses **correct architecture**: the BFMCS is built over `CanonicalMCS` (modal domain) with `TimelineQuot` providing temporal structure separately. The key comment from the file:

> **Key Insight: Dual Domain Architecture**
> - **Temporal domain**: TimelineQuot (dense linear order from Cantor)
> - **Modal domain**: CanonicalMCS (all maximal consistent sets)
> - **BFMCS**: Over CanonicalMCS with modal saturation via closedFlags

However, the BFMCS here is `BFMCS CanonicalMCS` (not `BFMCS TimelineQuot`), which means it is **not a complete correction** — the temporal domain and the BFMCS domain are still separate, with modal coherence handled at CanonicalMCS level.

---

### 2. The Core Architectural Problem

The BFMCS structure is:
```lean
structure BFMCS where
  families : Set (FMCS D)
  ...
```

where `D` is the **FMCS indexing type** (temporal domain). The conflation occurs when:

- For **dense completeness**: The BFMCS should have `D = TimelineQuot` (with `DenselyOrdered`) so that the completeness theorem can instantiate `valid_dense` which quantifies over all `D` with `DenselyOrdered D`.
- For **discrete completeness**: The BFMCS should have `D = Int` (with `SuccOrder`) so that `valid_discrete` can be instantiated.

**Current broken state** in `DenseCompleteness.lean` (line 173-178, 187-191):
```lean
-- Truth lemma is proven for BFMCS Int, NOT for BFMCS TimelineQuot:
theorem canonical_truth_lemma_int
    (B : BFMCS Int) (h_tc : B.temporally_coherent) ...
```

The file explicitly documents: "The gap is that the truth lemma is proven for `D = Int` (or CanonicalMCS), while the `valid_dense` definition quantifies over all `D` with `DenselyOrdered D`."

---

### 3. What `specs/006` Reports 17-20 Prescribe

Reading reports 17-20 in `specs/006_canonical_taskframe_completeness/reports/`:

**Report 17** (`17_three-place-canonical-task-relation.md`): Prescribes replacing the two-place `CanonicalR` with a three-place `CanonicalTask(u, n, v)` for discrete completeness. The duration type D = ℤ is made intrinsic to the canonical construction via Succ chains.

**Report 18** (`18_dense-three-place-task-relation.md`): Prescribes the `DenseTask(u, q, v)` relation via Cantor isomorphism for dense completeness. The duration type D = ℚ (= TimelineQuot modulo isomorphism).

**Report 19** (`19_role-in-representation-theorems.md`): Prescribes that:
- For **dense completeness**: Build BFMCS directly over `D = TimelineQuot` using `timelineQuotFMCS`, prove truth lemma for `D = TimelineQuot` (DenselyOrdered), then instantiate `valid_dense` with `D = TimelineQuot`.
- For **discrete completeness**: Build `D = ℤ` directly via Succ-chain construction, bypassing the SuccOrder-on-quotient pipeline entirely.

**Report 20** (`20_succ-based-bypass-of-covering-lemma.md`): Prescribes the Succ-based bypass for discrete completeness, avoiding the `discrete_Icc_finite_axiom` blocker. The proposed pipeline:

```
MCSes → f_content/p_content → Succ relation → CanonicalTask (inductive on ℤ)
      → TaskFrame ℤ → BFMCS construction → Truth lemma → Discrete completeness
```

---

### 4. Task 22 Research Report 03 Recommendation is Wrong

The task description specifically calls out that "Task 22 research report 03 recommendation to 'use CanonicalMCS domain' is wrong for non-base logics." This is confirmed by:

1. `FMCSDef.lean` (lines 27-37) documents: "The construction `FMCS CanonicalMCS` serves the TruthLemma proof but is NOT a standard temporal model" and has "only Preorder structure (not the LinearOrder needed for TaskFrame semantics)"

2. `MultiFamilyBFMCS.lean` header (lines 19-38): Explicitly marks `singletonCanonicalBFMCS : BFMCS CanonicalMCS` as a "DEAD END" with explanation that `modal_backward` is mathematically impossible with that domain choice.

3. `DenseCompleteness.lean` (lines 59-60): "**Blocker 3**: CanonicalMCS has Preorder but NOT AddCommGroup/LinearOrder. The ParametricCanonicalTaskFrame requires these typeclasses."

The "use CanonicalMCS domain" recommendation is valid ONLY for the **base completeness** proof (which is sorry-free). It fails for dense completeness (needs `DenselyOrdered`) and discrete completeness (needs `SuccOrder`/`PredOrder`).

---

## Recommended Approach

### For Dense Completeness

The W=D conflation fix requires building `BFMCS TimelineQuot` (not `BFMCS CanonicalMCS` or `BFMCS Int`):

**Correct architecture** (per reports 18-19):
1. Use `timelineQuotFMCS` (already exists in `TimelineQuotCanonical.lean`) as the base FMCS with `D = TimelineQuot`
2. Construct `BFMCS TimelineQuot` with families indexed by `TimelineQuot`
3. Modal saturation via `timelineQuotClosedFlags` pattern (already partially in `TimelineQuotBFMCS.lean`)
4. Prove truth lemma for `D = TimelineQuot` using the parametric infrastructure
5. Instantiate `valid_dense` with `D = TimelineQuot` (which has `DenselyOrdered` instance)

**Key gap to fill**: The modal coherence in `TimelineQuotBFMCS.lean` currently works at the `CanonicalMCS` level (for a `BFMCS CanonicalMCS`), not at the `TimelineQuot` level. The fix is to build the BFMCS families as `FMCS TimelineQuot` instead of the current separation.

**Warning**: The `CanonicalEmbedding.lean` approach (building `BFMCS Rat` via Cantor isomorphism transfer) has `sorry` at lines 295-323 for the forward_F/backward_P witnesses. This approach has the correct `D = Rat`, but transferring temporal coherence through the Cantor isomorphism is non-trivial.

### For Discrete Completeness

The W=D conflation fix requires building `BFMCS Int` where families have proper modal coherence — the current `directMultiFamilyBFMCS` has the right domain (`Int`) but unproven modal coherence at `t ≠ 0`:

**Correct architecture** (per reports 17, 20):
1. Define `f_content`, `p_content` in `TemporalContent.lean`
2. Define `Succ(u, v)` relation (G-persistence + F-step) — **NOT** raw CanonicalR
3. Define `CanonicalTask(u, n, v)` inductively from Succ
4. Build `FMCS Int` families where the chain is a Succ-chain (not arbitrary Lindenbaum chain)
5. Prove modal coherence using Succ-chain structure (cross-family coherence via F-step tracking)
6. Bypass `discrete_Icc_finite_axiom` entirely

**Key insight**: The current `directFamilies_modal_forward` and `directFamilies_modal_backward` sorries at `t ≠ 0` arise precisely because `intFMCS_basic` uses arbitrary Lindenbaum extensions, not Succ-chains. Succ-chains have the F-step condition that makes modal coherence tractable.

---

## Evidence/Examples

### Code Location: `DirectMultiFamilyBFMCS.lean:207-258` (modal_forward sorry)

```lean
theorem directFamilies_modal_forward ... : φ ∈ fam'.mcs t := by
  ...
  · subst h0
    -- At t = 0: uses discreteClosedMCS saturation (works)
    sorry  -- Line 255: cross-family at t=0 still problematic
  · -- At t ≠ 0: chains may be completely disjoint
    sorry  -- Line 258: fundamental: chains indexed by Int diverge
```

**Root cause**: `intFMCS_basic` builds `mcs : Int → Set Formula` as an arbitrary Lindenbaum chain indexed by Int. At `t ≠ 0`, different chains rooted at different `CanonicalMCS` members produce unrelated MCS values — there is no structural reason for cross-family modal coherence. The fix is Succ-chains where F-step condition forces F-obligations to propagate deterministically.

### Code Location: `MultiFamilyBFMCS.lean:198-310` (singletonCanonicalBFMCS dead end)

```lean
noncomputable def singletonCanonicalBFMCS : BFMCS CanonicalMCS where
  ...
  modal_backward := fun fam hfam phi t h_all => by
    ...
    sorry  -- Line 310: MATHEMATICALLY IMPOSSIBLE without S5 for single world
```

**Root cause**: `BFMCS CanonicalMCS` means `fam.mcs : CanonicalMCS → Set Formula` where `mcs t = t.world`. Modal_backward requires `phi in t.world → Box phi in t.world`, which is false (violates Kripke semantics: `{Diamond(p), neg(p)}` is consistent).

### Code Location: `TimelineQuotBFMCS.lean:73-78` (correct dual-domain architecture)

```lean
-- Key Insight: Dual Domain Architecture
-- - Temporal domain: TimelineQuot (dense linear order from Cantor)
-- - Modal domain: CanonicalMCS (all maximal consistent sets)
-- - BFMCS: Over CanonicalMCS with modal saturation via closedFlags
```

This is correct for the modal dimension but still conflates the separation needed for dense completeness: the temporal domain and BFMCS domain must be unified as `TimelineQuot` for the `valid_dense` instantiation to work.

### Code Location: `DenseCompleteness.lean:43-44` (domain mismatch documented)

```
The gap is that the truth lemma is proven for `D = Int` (or CanonicalMCS), while
the `valid_dense` definition quantifies over all `D` with `DenselyOrdered D`.
```

---

## Confidence Level

**High** on the diagnosis:
- The W=D conflation sites are clearly documented within the files themselves (`FMCSDef.lean:27-37`, `MultiFamilyBFMCS.lean:19-38`, `DenseCompleteness.lean:43-77`)
- The "dead end" constructions are explicitly marked and explained
- The `sorry` locations match the architectural mismatch exactly

**Medium** on the fix approach:
- The specs/006 reports (17-20) prescribe the correct architecture clearly
- The infrastructure in `TimelineQuotBFMCS.lean` and `CanonicalEmbedding.lean` points toward the right direction
- The Succ-based bypass for discrete is well-specified in report 20
- However, the concrete Lean 4 implementation of Succ-chain FMCS is **not yet started** (no `SuccRelation.lean` or `CanonicalTask.lean` file exists)
- The `CanonicalEmbedding.lean` approach has unresolved sorries for F/P witnesses under Cantor transfer

**Low** on the implementation difficulty estimate for dense case:
- The `forward_F`/`backward_P` for `FMCS TimelineQuot` via Cantor transfer (in `CanonicalEmbedding.lean`) has sorries that "can be recovered" per research but the specific Lean proof steps are not clear
- Temporal coherence transfer through order isomorphisms requires careful Lean 4 proof work

---

## Summary of Conflation Sites

| File | Type | Domain Used | Correct Domain | Status |
|------|------|-------------|----------------|--------|
| `Bundle/DirectMultiFamilyBFMCS.lean` | Discrete BFMCS | `BFMCS Int` (correct) but modal coverage at `CanonicalMCS` level | `BFMCS Int` with Succ-chain families | 4 sorries (t≠0 modal coherence) |
| `Algebraic/MultiFamilyBFMCS.lean` | Dead-end | `BFMCS CanonicalMCS` | N/A (dead end, W=D conflation) | 2 sorries (modal_backward, canonical_modal_backward) |
| `StagedConstruction/TimelineQuotBFMCS.lean` | Dense proto | `BFMCS CanonicalMCS` for modal + `TimelineQuot` separately | `BFMCS TimelineQuot` (unified) | Incomplete wiring for completeness |
| `Algebraic/CanonicalEmbedding.lean` | Dense attempt | `BFMCS Rat` (correct domain) | Same | 2 sorries (F/P witnesses under Cantor transfer) |

The most actionable targets are:
1. **Dense completeness**: Unify `TimelineQuotBFMCS` construction to use `D = TimelineQuot` throughout (or complete `CanonicalEmbedding.lean` F/P witness proofs for `D = Rat`)
2. **Discrete completeness**: Implement Succ-based bypass (reports 17/20) with new files `SuccRelation.lean` and `CanonicalTask.lean`
