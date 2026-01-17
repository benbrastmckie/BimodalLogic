# Research Report: Task #454

**Task**: 454 - Fix temporal quantification to match paper
**Started**: 2026-01-12T10:00:00Z
**Completed**: 2026-01-12T10:30:00Z
**Effort**: Medium
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- JPL paper: `/home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
- Lean implementation: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`
- Lean implementation: `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Explanatory/Truth.lean`
**Artifacts**:
- This report: `specs/454_fix_temporal_quantification_to_match_paper/reports/research-001.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

1. **Critical Discrepancy Found**: The Lean implementation restricts temporal quantification to `y ∈ τ.domain` (times in the world history's domain), while the paper quantifies over **all times** `y ∈ D` (the entire temporal order).

2. **Two Modules Affected**: Both `Bimodal.Semantics.Truth` and `Logos.SubTheories.Explanatory.Truth` have this issue.

3. **Logical Consequence Also Affected**: Both `valid` and `semantic_consequence` definitions inherit this issue by quantifying over times `t` where `τ.domain t`, rather than all times in `D`.

4. **Recommended Approach**: Change temporal operator semantics to quantify over all times `y : T`, removing the `hy : y ∈ τ.domain` constraint. This requires careful handling of truth evaluation at times outside the history's domain.

## Context & Scope

### Paper Specification

The paper defines temporal semantics at the following key locations:

**Lines 896-897 (main text):**
```latex
($\Past$) $\M,\tau,x \vDash \Past \varphi$ iff $\M,\tau,y \vDash \varphi$ for all $y\in D$ where $y < x$.
($\Future$) $\M,\tau,x \vDash \Future \varphi$ iff $\M,\tau,y \vDash \varphi$ for all $y\in D$ where $x < y$.
```

**Lines 1869-1870 (appendix def:BL-semantics):**
```latex
($\Past$) $\M,\tau,x \vDash \Past \varphi$ iff $\M,\tau,y \vDash \varphi$ for all $y\in D$ where $y < x$.
($\Future$) $\M,\tau,x \vDash \Future \varphi$ iff $\M,\tau,y \vDash \varphi$ for all $y\in D$ where $x < y$.
```

**Key observation**: The quantification is over `y ∈ D` (all times in the temporal order), NOT `y ∈ dom(τ)` (times in the history's domain).

**Lines 924 and 2272-2273 (Logical Consequence):**
```latex
$\Gamma \vDash \varphi$ iff for any model $\M$ of $\BL$, possible world $\tau \in H_{\F}$,
and time $x \in D$, if $\M, \tau, x \vDash \gamma$ for all $\gamma \in \Gamma$,
then $\M, \tau, x \vDash \varphi$.
```

**Key observation**: The quantification over times is `x ∈ D` (all times), not restricted to times in the history's domain.

### Paper's Semantic Rationale

The paper explicitly discusses this design choice at lines 899-919:

> "Whereas the semantics for the metaphysical modals quantify over all possible worlds in $H_\F$, the semantics for the tense operators quantify over all times in $D$. Certain applications may restrict the tense operators to the domain $\dom{\tau}$ for the possible world $\tau$ of evaluation..."

The example (chess game) shows why this matters:
- Game β ends at move 31 with checkmate
- Evaluating `$\past p_w$` at move 47 in β should be TRUE (because checkmate happened at move 31)
- But move 47 is NOT in `dom(β)` since the game ended

The paper notes (line 919):
> "By contrast, every sentence letter is false in $\beta$ at move 47 given that $\beta$ is not defined at move 47."

### Current Lean Implementation

**Bimodal.Semantics.Truth (lines 101-102):**
```lean
| Formula.all_past φ => ∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ
| Formula.all_future φ => ∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ
```

**Logos.SubTheories.Explanatory.Truth (lines 126-137):**
```lean
| Formula.all_past φ =>
    -- HA: true iff A is true at all past times
    ∀ y (hy : y ∈ τ.domain), y < t → truthAt M τ y hy σ idx φ
| Formula.all_future φ =>
    -- GA: true iff A is true at all future times
    ∀ y (hy : y ∈ τ.domain), y > t → truthAt M τ y hy σ idx φ
| Formula.some_past φ =>
    -- PA: true iff A is true at some past time
    ∃ y, ∃ hy : y ∈ τ.domain, y < t ∧ truthAt M τ y hy σ idx φ
| Formula.some_future φ =>
    -- FA: true iff A is true at some future time
    ∃ y, ∃ hy : y ∈ τ.domain, y > t ∧ truthAt M τ y hy σ idx φ
```

**The discrepancy**: Both implementations require `y ∈ τ.domain`, but the paper quantifies over all `y ∈ D`.

## Findings

### Key Technical Challenge

The current implementation's signature for `truth_at` requires a domain membership proof:

```lean
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t) :
    Formula → Prop
```

To match the paper, we need to evaluate truth at times `t` where `t ∉ τ.domain`. The paper handles this by making atoms false outside the domain:

**Line 892 (atom semantics):**
```latex
($p_i$) $\M,\tau,x \vDash p_i$ iff $x \in \dom{\tau}$ and $\tau(x) \in |p_i|$.
```

This means:
- If `x ∉ dom(τ)`, then `τ(x)` is undefined, so `p_i` is **false**
- Logical connectives proceed normally
- Temporal operators quantify over ALL times

### Files Requiring Modification

1. **`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`**
   - Remove `ht : τ.domain t` parameter from `truth_at`
   - Change atom case to check domain membership
   - Change temporal operators to quantify over all times

2. **`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`**
   - Update `valid` to quantify over all times (not just `τ.domain t`)
   - Update `semantic_consequence` similarly
   - Update `satisfiable` similarly

3. **`/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Explanatory/Truth.lean`**
   - Same changes as Bimodal version
   - Also update `some_past`, `some_future`, `since`, `until`, `rcall` operators

4. **`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean`**
   - May need helper to get state-or-nothing at arbitrary time

5. **Downstream files using `truth_at`**:
   - `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean`
   - `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
   - `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/Perpetuity/**.lean`
   - Any file that calls `truth_at` or uses `⊨` notation

### Impact on Time-Shift Theorems

The `TimeShift` section in Truth.lean contains critical theorems for proving MF/TF axioms:
- `time_shift_preserves_truth`
- `exists_shifted_history`

These will need to be re-proven with the new signature. The proofs should be similar but without domain membership proof threading.

### Verification Needed

After implementation, verify:
1. Perpetuity principles (SP1, SP2) still hold
2. MF and TF axioms still provable
3. No regressions in existing theorems

## Decisions

1. **Remove domain membership from truth_at signature** - This is the cleanest approach matching the paper exactly.

2. **Handle atoms by checking domain membership inline** - Use `if ht : τ.domain t then M.valuation (τ.states t ht) p else False`.

3. **Quantify temporal operators over all T** - Replace `∀ y (hy : τ.domain y)` with `∀ y : T`.

4. **Update validity to quantify over all times** - Replace `∀ t (ht : τ.domain t)` with `∀ t : T`.

## Recommendations

### Implementation Order

1. **Phase 1: Core Changes**
   - Modify `truth_at` in Bimodal.Semantics.Truth
   - Update validity definitions in Bimodal.Semantics.Validity
   - Fix all compilation errors in Bimodal module

2. **Phase 2: Downstream Fixes**
   - Update Metalogic soundness proofs
   - Update Perpetuity theorem proofs
   - Update any other dependent files

3. **Phase 3: Logos Module**
   - Apply same changes to Logos.SubTheories.Explanatory.Truth
   - Update dependent Logos files

4. **Phase 4: Verification**
   - Run full `lake build`
   - Verify all existing theorems still compile
   - Check perpetuity principles SP1/SP2

### New Type Signature

**Proposed:**
```lean
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : T) : Formula → Prop
  | Formula.atom p =>
    if ht : τ.domain t then M.valuation (τ.states t ht) p else False
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t φ → truth_at M τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), truth_at M σ t φ
  | Formula.all_past φ => ∀ (s : T), s < t → truth_at M τ s φ
  | Formula.all_future φ => ∀ (s : T), t < s → truth_at M τ s φ
```

**Note on Box**: The box operator should also lose its domain constraint `hs : σ.domain t`, since validity quantifies over all times.

## Risks & Mitigations

### Risk 1: Breaking Existing Proofs
**Impact**: High - Many theorems depend on current signature
**Mitigation**: Incremental changes with compilation checks after each file

### Risk 2: Performance of Domain Check
**Impact**: Low - Single decidable check per atom evaluation
**Mitigation**: Lean optimizes `if h : P then ... else ...` well

### Risk 3: Subtle Semantic Changes
**Impact**: Medium - Changing quantification scope is significant
**Mitigation**: The paper explicitly specifies this behavior; we're correcting to match

### Risk 4: Time-Shift Proofs May Need Restructuring
**Impact**: Medium - These are complex proofs
**Mitigation**: The core insight (time-shift preserves truth) should remain valid; only proof mechanics change

## Appendix

### Search Queries Used
- Grep for `Past|Future|τ\.dom` in Logos directory
- Grep for `Consequence|Valid|valid` in Logos directory
- Manual reading of paper sections

### Key Paper References
- Lines 896-897: Temporal operator semantics (main text)
- Lines 1862-1872: def:BL-semantics (appendix)
- Line 924: Logical consequence (main text)
- Lines 2272-2273: def:logical-consequence (appendix)
- Lines 899-919: Discussion of domain restriction design choice
- Line 892: Atom semantics with domain check

### Current Implementation References
- `Bimodal.Semantics.Truth`: lines 95-102
- `Bimodal.Semantics.Validity`: lines 58-61, 77-81
- `Logos.SubTheories.Explanatory.Truth`: lines 103-145, 206-222
