# Research Report: Task #812

**Task**: Evaluate architectural alignment between semantic_weak_completeness and semantics validity
**Date**: 2026-02-02
**Focus**: Does semantic_weak_completeness prove completeness for the SAME validity notion defined in semantics?
**Session ID**: sess_1770027719_3a1291

## Summary

**Critical Finding**: `semantic_weak_completeness` proves completeness for a DIFFERENT validity notion than the one defined in `Validity.lean`. The semantics defines validity as truth in ALL TaskModels; `semantic_weak_completeness` proves completeness for truth in SemanticWorldStates (FMP-internal models). These are fundamentally different semantic domains, and the gap between them is architectural, not a matter of missing lemmas.

**Recommendation**: The user's concern is valid. Using `semantic_weak_completeness` as THE completeness result effectively redefines what "validity" means for this logic. The report evaluates options for proceeding.

---

## 1. The Two Validity Notions

### 1.1 Semantics Validity (Truth.lean + Validity.lean)

**Definition** (`Validity.lean:61-64`):
```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

**What this quantifies over**:
- **D**: ANY totally ordered abelian group (Int, Rat, Real, custom types)
- **F: TaskFrame D**: ANY task frame with WorldState type and histories
- **M: TaskModel F**: ANY model = frame + valuation (WorldState -> String -> Prop)
- **tau: WorldHistory F**: ANY function from time to world states
- **t: D**: ANY time point

**Key property**: This is unconstrained universal quantification over all possible semantic structures. There is no connection to the proof system, MCS construction, or finite models.

### 1.2 FMP-Internal Validity (SemanticCanonicalModel.lean)

**Definition** (`SemanticCanonicalModel.lean:356-358`):
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

**Where `semantic_truth_at_v2` is** (`SemanticCanonicalModel.lean:256-258`):
```lean
def semantic_truth_at_v2 (phi : Formula) (w : SemanticWorldState phi)
    (_t : BoundedTime (temporalBound phi)) (psi : Formula) : Prop :=
  exists h_mem : psi in closure phi, (SemanticWorldState.toFiniteWorldState w).models psi h_mem
```

**And `FiniteWorldState.models` is** (`FiniteWorldState.lean:136-137`):
```lean
def models (w : FiniteWorldState phi) (psi : Formula) (h : psi in closure phi) : Prop :=
  w.assignment (psi, h) = true
```

**What this quantifies over**:
- **w: SemanticWorldState phi**: Quotient of (FiniteHistory, BoundedTime) pairs
- **FiniteWorldState phi**: Truth assignment on closure that is locally consistent
- **Truth**: Boolean membership in the assignment (NOT recursive semantic evaluation)

**Key property**: This is constrained quantification over finite, MCS-derived structures. Truth is defined as assignment lookup, NOT as recursive evaluation via `truth_at`.

---

## 2. The Fundamental Difference

### 2.1 How Truth Works in Each System

**Semantics Truth** (`Truth.lean:108-114`):
```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M tau s phi
```

**FMP Truth** (`FiniteWorldState.lean:136-137`):
```lean
def models (w : FiniteWorldState phi) (psi : Formula) (h : psi in closure phi) : Prop :=
  w.assignment (psi, h) = true
```

**Critical observation**: FMP truth does NOT recursively evaluate `box` or temporal operators. It just looks up a boolean. The boolean is set based on MCS membership, which respects the T-axiom (`box psi -> psi`) but does NOT require `psi` to hold at all histories.

### 2.2 The Box Operator Gap

**Semantics**: `box phi` means `phi` is true at ALL histories `sigma : WorldHistory F`.

**FMP**: `box phi` is "true" iff the MCS that generated the world state contains `box phi`. This MCS containment follows from proof-theoretic reasoning (derivability + consistency), NOT from checking all histories.

**Why this matters**: A formula could be:
- Valid in the FMP sense (no MCS makes it false)
- But FALSE in some arbitrary TaskModel where the valuation doesn't correspond to any MCS

### 2.3 Concrete Example

Consider `box (atom "p")`:

**FMP evaluation**:
- Take any SemanticWorldState w
- w is derived from some ClosureMaximalConsistent set S
- `semantic_truth_at_v2 phi w t (box (atom "p"))` holds iff `box (atom "p") in S` (plus closure membership)
- MCS properties ensure this respects T-axiom but NOT that "p" is true at all histories

**Semantics evaluation**:
- `truth_at M tau t (box (atom "p"))` requires:
- For ALL histories sigma, there exists ht such that tau.domain t and M.valuation(...) p
- This is a universal quantification over ALL possible histories in the frame

---

## 3. Is the Bridge Provable?

### 3.1 The Bridge Statement

To use `semantic_weak_completeness` for semantics validity, we need:
```
valid phi -> (forall w : SemanticWorldState phi, semantic_truth_at_v2 phi w ... phi)
```

This is what `weak_completeness` in `FiniteStrongCompleteness.lean` attempts to prove with a sorry at line 130.

### 3.2 Why the Bridge is Blocked

The sorry comment at lines 114-130:
```lean
-- The FMP semantic_weak_completeness gives: FMP-internal validity -> derivability
-- We need: general validity -> FMP-internal validity
-- This bridge is proven for propositional operators but blocked for modal/temporal
-- (see mcs_world_truth_correspondence in ConsistentSatisfiable.lean)
```

**The obstruction for `box`**:
1. General validity gives: for all M, tau, t, if M is ANY TaskModel, then `truth_at M tau t phi`
2. FMP-internal validity needs: for all w : SemanticWorldState, `w.models phi h_mem`
3. SemanticWorldState is built from MCS, which only contains formulas derivable/consistent with the logic
4. General validity at ALL TaskModels doesn't immediately tell us about MCS-derived structures

**The gap is semantic, not technical**: We cannot prove that truth in all (unconstrained) models implies membership in all (proof-theoretically constrained) MCS without assuming completeness itself.

### 3.3 Could We Prove the Reverse Direction?

Can we prove: FMP-internal validity -> semantics validity?

This would require showing that if `phi` holds at all SemanticWorldStates, then `phi` holds at all TaskModels. But:
- TaskModels include pathological valuations not representable by any MCS
- TaskModels include infinite time domains (SemanticWorldState uses BoundedTime)
- TaskModels include histories that don't respect any consistency condition

So the reverse direction is also blocked.

---

## 4. Implications for the Project

### 4.1 What semantic_weak_completeness Actually Proves

`semantic_weak_completeness` proves:
> If phi is true at every SemanticWorldState (finite, MCS-derived structure), then phi is derivable.

This is a valid theorem. It establishes completeness for a specific class of finite models.

### 4.2 What It Does NOT Prove

It does NOT prove:
> If phi is true at every TaskModel (per Validity.lean definition), then phi is derivable.

The gap is that TaskModels are unconstrained, while SemanticWorldStates are proof-theoretically derived.

### 4.3 The User's Concern is Valid

The user wrote:
> "What I don't want is to redefine completeness to concern something besides the definition of validity included in the semantics."

This concern is correct. `semantic_weak_completeness` redefines validity to mean "true at all SemanticWorldStates" rather than "true at all TaskModels per `valid` in Validity.lean".

---

## 5. Options for Proceeding

### Option A: Accept the FMP-Internal Completeness as Primary

**What this means**: Accept that the logic is complete with respect to FMP-internal validity, document that semantics validity completeness requires additional work.

**Pros**:
- Sorry-free result available now
- FMP-internal validity is mathematically interesting (finite model property)
- Matches how many modal logic implementations handle completeness

**Cons**:
- Does not prove completeness for the `valid` definition in Validity.lean
- Conceptually conflates two different semantic notions
- User explicitly does not want this

### Option B: Change the Semantics Definition

**What this means**: Modify `valid` in Validity.lean to match what `semantic_weak_completeness` proves.

**Specific change**:
```lean
-- Instead of quantifying over all TaskModels
def valid (phi : Formula) : Prop :=
  forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w ... phi
```

**Pros**:
- Achieves alignment between semantics and completeness proof
- Sorry-free

**Cons**:
- User explicitly does not want to change semantics
- Loses the classical "truth in all models" definition
- SemanticWorldState is formula-dependent (valid becomes non-uniform)

### Option C: Add Accessibility Relation to Semantics

**What this means**: Modify the box semantics from S5-style (all histories) to Kripke-style (accessible histories).

**Specific change** to `Truth.lean:112`:
```lean
-- Current:
| Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
-- Changed to:
| Formula.box phi => forall (sigma : WorldHistory F), accessible tau sigma -> truth_at M sigma t phi
```

Where `accessible` would be part of the TaskFrame structure.

**Pros**:
- Standard approach in modal logic completeness proofs
- Accessibility can be defined to match MCS containment
- Could enable completeness for the semantics validity

**Cons**:
- Major semantics change (user does not want semantics changes)
- Would require reworking soundness proofs
- Changes the logic being axiomatized

### Option D: Accept Sorries as Architectural Limitation

**What this means**: Keep the current architecture, document that `weak_completeness` requires a sorry that represents an architectural gap, not an implementation bug.

**Specific approach**:
- Keep `semantic_weak_completeness` as the sorry-free result
- Keep `weak_completeness` with its sorry, documented as architectural
- Create wrapper types/theorems that make the distinction clear

**Pros**:
- Honest documentation of the situation
- No semantics changes required
- Preserves both validity notions

**Cons**:
- Repository has a sorry that cannot be removed without architectural change
- Conceptual complexity for users

### Option E: Prove Completeness via Different Method

**What this means**: Instead of FMP approach, use a different completeness proof that works for unrestricted TaskModels.

**Possible approaches**:
- Henkin-style construction with general structures
- Ultraproduct methods
- Direct canonical model over unrestricted time domain

**Pros**:
- Would prove completeness for the actual `valid` definition
- Conceptually clean

**Cons**:
- Significant new work
- May introduce its own sorries
- Not guaranteed to succeed

---

## 6. Recommendation

Based on the user's constraint ("do not redefine completeness to concern something other than the semantics validity"), the options reduce to:

1. **Option D (Accept Sorries)**: Keep both validity notions, document the gap
2. **Option E (Alternative Proof)**: Attempt a different completeness proof

**Recommended Path**: Option D with clear documentation.

**Rationale**:
- The user explicitly does not want semantics changes (rules out B, C)
- The user does not want completeness redefined (rules out A)
- Option E is high-risk/high-effort with uncertain outcome
- Option D honestly represents the mathematical situation

**Specific Implementation**:
1. Keep `semantic_weak_completeness` as the FMP completeness result
2. Rename/reorganize to make clear it's for FMP-internal validity
3. Document `weak_completeness` sorry as architectural (not implementation gap)
4. Create clear user-facing documentation explaining the two validity notions
5. If desired later, Option E can be pursued as a separate research effort

---

## 7. Detailed Analysis: Why the Gap Cannot Be Closed

### 7.1 The T-Axiom is Necessary but Not Sufficient

`semantic_weak_completeness` works because:
- FiniteWorldState respects the T-axiom: if `box psi` is in the assignment, then `psi` is
- This is checked by `IsLocallyConsistent` at lines 88-104 of FiniteWorldState.lean

But the T-axiom only says `box psi -> psi`. It does NOT say:
- `box psi` iff `psi` holds at all histories
- If `psi` holds at some history, then `box psi` fails

The FMP construction satisfies T locally but doesn't model universal history quantification.

### 7.2 Box Semantics is the Fundamental Issue

The definition at `Truth.lean:112`:
```lean
| Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
```

This quantifies over ALL `sigma : WorldHistory F`, which is an uncountable set for typical frames. There's no way to verify this by examining a finite MCS-derived structure.

### 7.3 Temporal Operators Have Similar Issues

`all_past` and `all_future` quantify over ALL times in D:
```lean
| Formula.all_past phi => forall (s : D), s <= t -> truth_at M tau s phi
| Formula.all_future phi => forall (s : D), t <= s -> truth_at M tau s phi
```

For D = Int or Real, this is infinite quantification. BoundedTime only handles finitely many times.

---

## 8. Conclusion

**Answer to the research question**: No, `semantic_weak_completeness` does NOT prove completeness for the validity notion defined in `Validity.lean`. It proves completeness for a different, FMP-internal validity notion.

**The architectural mismatch**:
- Semantics validity: truth in ALL TaskModels (unconstrained)
- FMP completeness: truth in ALL SemanticWorldStates (MCS-derived, finite)

**The gap is not closeable** without changing semantics because:
- Box semantics quantifies over all histories (uncountable for typical frames)
- MCS-derived world states only capture finite, proof-theoretically coherent structures

**Recommendation**: Accept Option D - document the gap clearly, keep both notions, mark the sorry as architectural.

---

## References

- `Theories/Bimodal/Semantics/Truth.lean` - truth_at definition (lines 108-114)
- `Theories/Bimodal/Semantics/Validity.lean` - valid definition (lines 61-64)
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - semantic_weak_completeness (lines 356-413)
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - FiniteWorldState.models (lines 136-137)
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - weak_completeness with sorry (lines 109-131)
- `specs/812_canonical_model_completeness/reports/research-003.md` - Previous research on validity notions
