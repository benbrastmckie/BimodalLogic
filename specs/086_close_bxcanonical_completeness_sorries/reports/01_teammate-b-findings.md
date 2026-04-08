# Teammate B Findings: FMP Bridge to Full Completeness

## Key Findings

### 1. FMP Theorem Statement (Exact Type Signature)

The FMP theorem (`mcs_finite_model_property` at `FMP/FMP.lean:193-198`) states:

```lean
theorem mcs_finite_model_property (phi : Formula)
    (h_not_provable : ¬Nonempty (DerivationTree [] phi)) :
    ∃ (S : ClosureMCSBundle phi), phi ∉ S.carrier ∧
    Finite (FilteredWorld phi)
```

**What this says**: If phi is not provable, there exists a ClosureMCSBundle (a closure-restricted MCS) where phi is not a member, and the filtered world type is finite.

**What this does NOT say**: It does NOT produce a TaskModel. It does NOT produce a world history, a valuation, or a semantic evaluation. It operates purely at the proof-theoretic level (MCS membership), not at the semantic level (truth_at).

### 2. FMP Model Type vs TaskModel

The FMP produces a `ClosureMCSBundle phi` -- a `Set Formula` with proof that it is a `RestrictedMCS`. The filtered model infrastructure consists of:

- `FilteredWorld phi` (`Filtration.lean:152`): quotient of `ClosureMCSBundle phi` by membership agreement on closure formulas
- `RefinedFilteredTaskFrame D phi` (`Filtration.lean:191`): a `TaskFrame D` with `WorldState = FilteredWorld phi` and a universal-at-nonzero task relation
- `FiniteFilteredTaskFrame D phi` (`FiniteModel.lean:153`): a `FiniteTaskFrame D` wrapping the above

**Critical observation**: A `TaskFrame D` exists but there is NO `TaskModel` built from it. A TaskModel requires:
- A `valuation : WorldState -> Atom -> Prop` (maps world states to atomic truth)
- A `WorldHistory F` and `Omega` set to evaluate `truth_at`

The FMP does NOT construct any of these. It only proves MCS membership facts.

### 3. Sorry Status in FMP Path

**Confirmed: 0 sorries in the FMP directory** (`Theories/Bimodal/Metalogic/Decidability/FMP/`).

All 7 files are sorry-free:
- `ClosureMCS.lean` -- closure MCS infrastructure (sorry-free)
- `Filtration.lean` -- filtration equivalence and quotient (sorry-free)
- `FiniteModel.lean` -- finiteness proof (sorry-free)
- `TruthPreservation.lean` -- MCS truth preservation (sorry-free)
- `FMP.lean` -- main FMP theorem (sorry-free)
- `DenseFMP.lean` -- dense specialization (sorry-free, delegates to FMP)
- `DiscreteFMP.lean` -- discrete specialization (sorry-free, delegates to FMP)

### 4. The FMP-to-Completeness Gap

The logical chain for completeness via FMP is:

```
valid phi
  → (by contrapositive) ¬provable phi → ¬valid phi
  → FMP: ¬provable → ∃ ClosureMCSBundle with phi ∉ S.carrier
  → NEED: ClosureMCSBundle → ∃ TaskModel M, ∃ Omega, ∃ tau, ∃ t, ¬truth_at M Omega tau t phi
  → therefore: ¬valid phi
```

The gap is step 3: **converting MCS non-membership into semantic falsity**. This is precisely the "truth lemma" -- the assertion that `phi ∈ S.carrier ↔ truth_at M Omega tau t phi` for some canonical model M.

**The FMP path has EXACTLY the same gap as the BXCanonical path**: both need a truth lemma connecting MCS membership to semantic truth. The FMP path just works with closure-restricted MCS instead of full MCS.

### 5. What "Bridging" Actually Requires

To bridge FMP to completeness, we need:

#### Step A: Canonical TaskModel from Filtered Frame
Build a `TaskModel` on `RefinedFilteredTaskFrame D phi`:
- Define `valuation : FilteredWorld phi → Atom → Prop` as `filteredWorldMem phi (Formula.atom a) h_clos w`
- This is straightforward IF atoms are in the closure (they always are for subformulas of phi)

#### Step B: World History and Omega
- Need a `WorldHistory (RefinedFilteredTaskFrame D phi)` -- a function `D → FilteredWorld phi` with task_rel properties
- Need an `Omega` set and `ShiftClosed Omega` proof
- The key question: what does the world history look like for a closure MCS?

#### Step C: Truth Lemma for Filtered Model
Prove `phi ∈ S.carrier ↔ truth_at M Omega tau t phi` for all formulas in the closure.

This truth lemma requires handling EVERY formula constructor:
- **atom**: By definition of canonical valuation (easy)
- **bot**: Trivial (neither side holds)
- **imp**: MCS implication property (proved in `TruthPreservation.lean`)
- **box**: Modal witness construction -- need to show that for every WorldHistory in Omega, the formula holds. This requires the Omega set to be constructed from the box-content of the MCS.
- **all_future (G)**: Need temporal forward direction. For `G phi ∈ S`, need `truth_at ... tau s phi` for all `s >= t`. This requires the world history to map future times to MCS where phi holds.
- **all_past (H)**: Mirror of G.
- **untl (Until)**: `phi U psi ∈ S` iff `∃ s >= t, truth_at ... tau s psi ∧ ∀ r ∈ [t,s), truth_at ... tau r phi`. This requires EXACTLY the eventuality resolution that is sorry'd in BXCanonical/Frame.lean.
- **snce (Since)**: Mirror of Until.

### 6. Until/Since Handling in FMP TruthPreservation

`TruthPreservation.lean` handles:
- Bot (line 85-106): proven
- Negation consistency (line 111-131): proven
- Implication (line 137-175, 164-378): both directions proven
- Box forward (line 231-239): proven
- Box transitivity (line 210-225): proven
- All_future/All_past transitivity (line 256-293): proven

**Until and Since are NOT handled at all in TruthPreservation.lean**. There are no Until/Since lemmas. The archived comment at line 247 notes that T-axiom dependent code was removed, and the temporal forward direction (G phi ∈ S → phi ∈ S) was also archived because it assumed the T-axiom.

### 7. Could Completeness Be Stated Over ClosureMCSBundle?

The existing `fmp_completeness` in `Correctness.lean:100-103` already does this:

```lean
theorem fmp_completeness (φ : Formula) :
    (∀ (S : FMP.ClosureMCSBundle φ), φ ∈ S.carrier) →
    Nonempty (DerivationTree [] φ)
```

This IS a completeness theorem, but for a different notion of "validity" -- one based on MCS membership rather than semantic truth. The standard completeness theorem needs:

```lean
theorem completeness (φ : Formula) : valid φ → Nonempty (DerivationTree [] φ)
```

where `valid` quantifies over ALL TaskModels with ALL temporal types D.

To bridge these, we need:
```lean
theorem valid_implies_all_mcs (φ : Formula) : valid φ → ∀ (S : ClosureMCSBundle φ), φ ∈ S.carrier
```

This is the semantic → proof-theoretic direction, which is EXACTLY what the truth lemma provides.

## FMP-to-Completeness Gap Analysis

### Gap Structure

```
[PROVED] ¬provable phi → ∃ ClosureMCSBundle with phi ∉ S.carrier    (FMP.lean)
[PROVED] ClosureMCSBundle → FilteredWorld is Finite                   (FiniteModel.lean)
[PROVED] RefinedFilteredTaskFrame D phi : TaskFrame D                  (Filtration.lean)
[PROVED] MCS membership respects filtration equivalence                (TruthPreservation.lean)
[PROVED] MCS implication, box, negation completeness properties        (TruthPreservation.lean)

[MISSING] Canonical TaskModel construction on FilteredWorld
[MISSING] WorldHistory construction from MCS chain
[MISSING] Omega and ShiftClosed construction
[MISSING] Truth lemma: atom, bot, imp cases (straightforward)
[MISSING] Truth lemma: box case (requires modal Omega construction)
[MISSING] Truth lemma: G/H cases (requires temporal ordering on MCS chain)
[MISSING] Truth lemma: Until/Since cases (HARD - same difficulty as BXCanonical)
```

### Root Cause

The gap between FMP and full completeness is IDENTICAL to the BXCanonical gap. Both paths require:

1. **A canonical temporal ordering on MCS** that correctly reflects Until/Since semantics
2. **Eventuality resolution** for Until/Since: given `phi U psi ∈ S`, find a witness time where psi holds with phi guarding all intermediate times

The FMP path adds finiteness (which is nice for decidability) but does NOT help with the truth lemma. The truth lemma difficulty is intrinsic to the logic, not to the model size.

## Concrete Bridge Plan

### Option 1: Direct FMP Bridge (Effort: HIGH, same as fixing BXCanonical)

Build the full canonical model on the filtered frame:
1. Define canonical valuation on `FilteredWorld phi` via MCS membership (~50 lines, easy)
2. Construct world histories by Zorn's lemma on MCS chains (~200-400 lines, medium)
3. Prove truth lemma for atom/bot/imp/box/G/H (~200-300 lines, medium)
4. Prove truth lemma for Until/Since (~300-500 lines, HARD -- eventuality resolution)
5. Wire up completeness theorem (~50 lines, easy)

Total: ~800-1300 lines. The Until/Since case is the blocker, same as BXCanonical.

### Option 2: Weak Completeness (Bypass Until/Since)

If the logic were restricted to the Until/Since-free fragment (G, H, box only), the FMP bridge would be straightforward. But the full logic includes Until/Since, and completeness must handle them.

### Option 3: Alternative Completeness Statement

Prove completeness relative to MCS membership, not semantic truth:

```lean
theorem mcs_completeness (phi : Formula) :
    (∀ (S : ClosureMCSBundle phi), phi ∈ S.carrier) → Nonempty (DerivationTree [] phi)
```

This is already proved (`fmp_completeness` in Correctness.lean). However, it is NOT equivalent to standard semantic completeness (`valid phi → provable phi`) without the truth lemma.

### Option 4: Restructure Around BXCanonical (Recommended)

The BXCanonical approach (`BXCanonical/Frame.lean`, `BXCanonical/TruthLemma.lean`, `BXCanonical/Completeness.lean`) is the right architecture for full completeness. Its sorry sites are:

| Sorry | File:Line | Description |
|-------|-----------|-------------|
| `bx_until_eventuality_resolution` | Frame.lean:562 | Forward Until: find witness with guard |
| `bx_until_backward` | Frame.lean:584 | Backward Until: derive membership from witness |
| `bx_since_eventuality_resolution` | Frame.lean:599 | Forward Since (mirror of Until) |
| `bx_since_backward` | Frame.lean:613 | Backward Since (mirror of Until) |
| `bx_completeness` | Completeness.lean:144 | Main theorem (blocked on model embedding + above) |

These 5 sorries are tightly scoped. The FMP path would require building ALL the same infrastructure PLUS the model construction, adding more work not less.

## Effort Estimate

| Path | Lines of Code | Difficulty | Until/Since Solved? |
|------|---------------|------------|---------------------|
| FMP Bridge (full) | 800-1300 | High | Must solve same problem |
| BXCanonical sorries | 300-600 | High | Must solve same problem |
| FMP as weak completeness | 0 (already proved) | Done | No (only MCS-completeness) |

**Key insight**: The FMP bridge requires MORE total work than closing the BXCanonical sorries, because it needs all the same Until/Since work PLUS canonical model construction that BXCanonical already has.

## Confidence

**High confidence** in the following assessment:
- The FMP path cannot bypass the Until/Since difficulty
- The FMP `fmp_completeness` is already a valid (weaker) completeness theorem
- The BXCanonical path is closer to full completeness than an FMP bridge would be
- Both paths are blocked on the same mathematical problem: eventuality resolution from BX5+BX6+BX7

**Medium confidence** on effort estimates (could be 50% higher due to unforeseen complications in the truth lemma).

## Recommendation

**Do NOT pursue the FMP bridge for full completeness.** The FMP path:

1. Already provides MCS-completeness (`fmp_completeness` in Correctness.lean, sorry-free)
2. Cannot avoid the Until/Since eventuality resolution problem
3. Would require MORE total code than closing BXCanonical sorries
4. Duplicates infrastructure that BXCanonical already has

Instead, the task should focus on the BXCanonical sorry sites directly (Teammate A's approach). The FMP's contribution is already realized: it gives decidability and MCS-completeness. Full semantic completeness requires the canonical model truth lemma, which is the BXCanonical path.

The FMP could theoretically be used as a "finite witness" approach if someone found a way to define truth_at directly on ClosureMCSBundle without going through the full canonical model construction. But this would require inventing a novel semantic framework -- the standard approach goes through canonical models.
