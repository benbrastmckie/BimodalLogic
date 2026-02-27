# Research Report 002: Semantic Discrepancies in Completeness Proofs

**Task**: 912 - Review Completeness Proof and Metalogic State
**Focus**: Discrepancies between FMP/BMCS completeness semantics and standard TaskFrame semantics
**Session**: sess_1771544708_98205d
**Date**: 2026-02-19

## 1. Executive Summary

There are **three independent completeness results** in the codebase, each using a different semantic framework. None of them currently establishes completeness over the **standard TaskFrame semantics** (defined in `Semantics/Validity.lean`). The discrepancies fall into two categories: (A) those that are fundamental design differences requiring bridging theorems, and (B) those that are stale documentation errors.

The single most important blocking issue is the **Omega-mismatch** in `Representation.lean`: the standard `valid` definition quantifies box over `Set.univ` (all histories), while the canonical model construction provides a specific `canonicalOmega` (bundle histories only). This makes the final step of `standard_weak_completeness` and `standard_strong_completeness` unprovable as currently stated, resulting in the two `sorry` placeholders in that file.

## 2. The Three Semantic Frameworks

### 2.1 Standard TaskFrame Semantics (`Semantics/`)

**Defined in**: `Semantics/Truth.lean`, `Semantics/Validity.lean`

**Key definitions**:
- `truth_at M Omega tau t phi` -- recursive on formula structure
- `valid phi` -- quantifies over ALL types D, ALL frames F, ALL models M, ALL histories tau, ALL times t, using `Omega = Set.univ`
- `semantic_consequence Gamma phi` -- same quantification, with premise satisfaction
- `satisfiable D Gamma` -- existential: exists F, M, Omega, tau (with tau in Omega), t

**Semantic clauses**:
- `atom p`: `exists (ht : tau.domain t), M.valuation (tau.states t ht) p`
- `bot`: `False`
- `imp phi psi`: `truth_at ... phi -> truth_at ... psi`
- `box phi`: `forall sigma in Omega, truth_at M Omega sigma t phi`
- `all_past phi`: `forall s, s <= t -> truth_at M Omega tau s phi` (REFLEXIVE)
- `all_future phi`: `forall s, t <= s -> truth_at M Omega tau s phi` (REFLEXIVE)

**Critical features**:
1. **Omega parameter**: Box quantifies over a set of admissible histories. For validity, `Omega = Set.univ`.
2. **History-based**: Truth is evaluated at (Model, history, time) triples.
3. **Reflexive temporal operators**: Past includes present, future includes present (using `<=`).
4. **Domain-dependent atoms**: Atoms require `tau.domain t` to be true.
5. **Convex domains**: Histories have convex domains with task-relation respect.
6. **Polymorphic over D**: Validity quantifies over all ordered abelian groups D.

### 2.2 BMCS Completeness Semantics (`Metalogic/Bundle/`)

**Defined in**: `Bundle/BMCSTruth.lean`

**Key definition**: `bmcs_truth_at B fam t phi` -- recursive on formula structure

**Semantic clauses**:
- `atom p`: `Formula.atom p in fam.mcs t` (MCS membership)
- `bot`: `False`
- `imp phi psi`: `bmcs_truth_at ... phi -> bmcs_truth_at ... psi`
- `box phi`: `forall fam' in B.families, bmcs_truth_at B fam' t phi` (BUNDLE-RESTRICTED)
- `all_past phi`: `forall s, s <= t, bmcs_truth_at B fam s phi` (REFLEXIVE)
- `all_future phi`: `forall s, t <= s, bmcs_truth_at B fam s phi` (REFLEXIVE)

**Critical features**:
1. **No Omega parameter**: Box quantifies over bundle families, not histories.
2. **MCS-based, not history-based**: Truth is evaluated at (BMCS, family, time) triples.
3. **Reflexive temporal operators**: Same as standard (using `<=`).
4. **No domain restriction**: Atoms are always evaluated (no domain predicate).
5. **No task relation, no convexity**: These concepts do not exist in BMCS semantics.
6. **Henkin-style restriction**: Box sees only bundle families, not all possible histories.

### 2.3 FMP Completeness Semantics (`Metalogic/FMP/`)

**Defined in**: `FMP/SemanticCanonicalModel.lean`, `FMP/FiniteWorldState.lean`

**Key definition**: `semantic_truth_at_v2 phi w t psi` -- check if psi is in the closure and modeled by the underlying FiniteWorldState.

**Semantic clauses** (implicit in FiniteWorldState.models):
- Truth is defined as `w.assignment (psi, h_mem) = true` -- a Bool-valued function on the subformula closure.
- There is **no recursive truth definition** -- truth is simply whether the assignment function maps the formula to `true`.
- Box, temporal operators, imp, etc., are all treated uniformly via the truth assignment -- their truth is determined by the **ClosureMaximalConsistent set** from which the world state was built.

**Critical features**:
1. **No Omega parameter at all**: There are no histories in the FMP semantics.
2. **World-state-based, not history-based**: Truth is a property of a single finite world state.
3. **No temporal structure**: Despite the `BoundedTime` parameter in `semantic_truth_at_v2`, time is ignored (`_t` is unused). Truth depends only on the world state.
4. **No task relation**: Task frames do not appear in FMP completeness.
5. **No domain restriction**: No history domains exist.
6. **Restricted to closure**: Only formulas in `closure phi` can be evaluated.
7. **Stale documentation**: The comment in `FiniteWorldState.lean` (lines 81-86) claims TM uses strict temporal semantics (`<` not `<=`), but the actual standard semantics in `Truth.lean` uses reflexive (`<=`). This comment is incorrect and describes a past version.

## 3. Detailed Discrepancy Analysis

### 3.1 The Omega-Mismatch (BLOCKING)

**Location**: `Metalogic/Representation.lean` lines 370-401, 414-435

**Nature**: The standard `valid` definition requires truth with `Omega = Set.univ` (all possible histories). The canonical model construction from BMCS provides truth with `Omega = canonicalOmega B` (only canonical histories from bundle families).

**Why this matters**: `standard_weak_completeness` attempts to show:
```
valid phi -> Nonempty (DerivationTree [] phi)
```
By contraposition: if not derivable, construct countermodel. The countermodel satisfies `phi.neg` at `canonicalOmega B`. But `valid phi` gives truth at `Set.univ`, not at `canonicalOmega B`. The two Omega values are incompatible.

**Why monotonicity fails**: One might hope for `truth_at M Omega1 tau t phi` and `Omega1 subset Omega2` implies `truth_at M Omega2 tau t phi`. This fails because:
- The `box` case is COVARIANT in Omega (more histories = stronger box assumption)
- The `imp` case makes box CONTRAVARIANT in the antecedent
- So truth is neither monotone nor antitone in Omega in general

**Resolution options**:

**(A) Change `valid` to quantify over Omega** (RECOMMENDED):
Replace:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M tau t, truth_at M Set.univ tau t phi
```
With:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M Omega tau (h_mem : tau in Omega) t, truth_at M Omega tau t phi
```
This makes validity quantify over ALL possible Omega sets. Soundness still holds (the proof already works for any Omega). Completeness then follows because the canonical model is a valid instantiation.

**Impact**: Requires updating `Validity.lean`, `Soundness.lean`, and any theorem that uses `valid` or `semantic_consequence`. The soundness proof currently uses `Set.univ` explicitly in several places (axiom validity lemmas, modus ponens case, etc.) but the proofs actually work for arbitrary Omega with minor adjustments.

**(B) Prove that `canonicalOmega` can be extended to `Set.univ`**:
This would require showing that canonical model truth is independent of Omega, which is false in general due to the box case.

**(C) Use a restricted validity notion** (NOT RECOMMENDED):
Define `valid_canonical` that only quantifies over canonical-like Omega. This weakens the completeness claim.

### 3.2 History-Based vs MCS-Based Semantics

**Nature**: Standard semantics uses `(Model, History, Time)` triples with explicit domains, convexity, and task relations. BMCS uses `(BMCS, Family, Time)` triples with MCS membership.

**Bridge**: `Representation.lean` successfully bridges this gap via:
- `canonicalFrame B`: TaskFrame with `WorldState = {S : Set Formula // SetMaximalConsistent S}`, trivial task relation
- `canonicalModel B`: Valuation checks atom membership in MCS
- `canonicalHistory B fam hfam`: Universal domain, states map `t -> fam.mcs t`
- `canonical_truth_lemma`: `phi in fam.mcs t <-> truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t phi`

**Status**: The truth lemma is PROVEN (no sorry). The bridge works for `canonicalOmega`, but breaks at the final step due to Omega-mismatch (see 3.1).

### 3.3 Trivial Task Relation

**Nature**: The canonical frame uses `task_rel = fun _ _ _ => True`, which satisfies nullity and compositionality trivially. This is a valid TaskFrame but does not reflect the structure of non-trivial task frames.

**Assessment**: This is NOT a discrepancy for completeness. Completeness only requires constructing ONE model where the formula is true/false. The trivial task relation is a legitimate choice. The task relation only constrains which histories are well-formed (via `respects_task`), but with a trivial relation, ALL histories are well-formed.

### 3.4 FMP Truth vs Standard Truth

**Nature**: FMP `semantic_truth_at_v2` is a completely different kind of truth:
- It is a **static world-state property** (does the assignment make the formula true?)
- It has **no temporal structure** (the time parameter is ignored)
- It has **no modal quantification** (no Omega, no histories)
- It only works for **formulas in the closure**

**Assessment**: FMP completeness proves a fundamentally different statement:
```lean
(forall w : SemanticWorldState phi, semantic_truth_at_v2 phi w ... phi) -> derives phi
```
This says: "if phi is true in all finite world states (defined by closure truth assignments), then phi is provable." This is closer to a **propositional completeness** result restricted to the subformula closure. It does NOT establish completeness over TaskFrame semantics.

**Bridge needed**: To connect FMP to standard completeness, one would need to show that `valid phi` implies `semantic_truth_at_v2 phi w ... phi` for all `w`. This requires building finite world states from arbitrary TaskFrame models, which is precisely the FMP direction (if satisfiable, then finite-model satisfiable). The FMP result is valuable as a standalone finite model property but does not directly contribute to standard completeness.

### 3.5 Stale Documentation: Strict vs Reflexive Temporal Operators

**Location**: `FMP/FiniteWorldState.lean` lines 81-86

**The comment states**:
```
NOTE: Temporal reflexivity (H phi -> phi, G phi -> phi) is intentionally NOT included
because TM logic uses strict temporal semantics where these axioms are not valid.
The temporal operators quantify over strictly less/greater times:
- `all_past phi` holds iff phi holds at all s < t (excluding t)
- `all_future phi` holds iff phi holds at all s > t (excluding t)
```

**The actual semantics** (in `Truth.lean` lines 118-119):
```lean
| Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
| Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

These use `<=` (reflexive), NOT `<` (strict). The proof system includes T-axioms for both temporal operators (`temp_t_future`, `temp_t_past`), and soundness proves them valid using reflexive semantics.

**Assessment**: This comment is STALE from a pre-Task-658 version when strict semantics were used. It should be updated or removed. The `IsLocallyConsistent` definition itself does not include temporal reflexivity, which is correct -- local consistency only checks propositional and modal axioms, not temporal axioms (temporal coherence is handled at the history/family level instead).

### 3.6 BMCS Truth Lemma vs Representation Truth Lemma

**Nature**: There are two truth lemmas in the codebase:
1. `bmcs_truth_lemma` in `Bundle/TruthLemma.lean`: `phi in fam.mcs t <-> bmcs_truth_at B fam t phi`
2. `canonical_truth_lemma` in `Representation.lean`: `phi in fam.mcs t <-> truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t phi`

Both are proven (no sorry). The difference is that (1) uses the BMCS-specific truth predicate while (2) uses the standard `truth_at` from `Semantics/Truth.lean`. The Representation truth lemma (2) is the one that bridges to standard semantics, but it breaks at the Omega step.

### 3.7 canonicalOmega is NOT Shift-Closed

**Location**: `Representation.lean` line 127

**Nature**: `canonicalOmega B` contains only histories of the form `canonicalHistory B fam hfam` for families in the bundle. Time-shifting such a history produces a history whose states at time `t` are `fam.mcs (t + delta)`, which is generally a DIFFERENT history (not equal to any `canonicalHistory B fam' hfam'`).

**Assessment**: Shift-closure is required for `time_shift_preserves_truth` (used in soundness proofs for MF and TF axioms). It is NOT required for the completeness direction. The lack of shift-closure in canonicalOmega is therefore correct and intentional.

## 4. What Each "Completeness" Actually Proves

### 4.1 FMP Completeness (`fmp_weak_completeness`)
- **Statement**: If phi is true at all `SemanticWorldState phi` (finite closure-based truth assignments), then phi is provable.
- **Status**: SORRY-FREE
- **Standard completeness?**: NO. Uses its own truth notion unrelated to TaskFrame semantics.
- **Value**: Establishes finite model property; useful for decidability.

### 4.2 BMCS Completeness (`bmcs_weak_completeness`, `bmcs_strong_completeness`)
- **Statement**: If phi is true in all BMCS at all families and times, then phi is provable.
- **Status**: SORRY-FREE (in this file). Inherits axiom dependency from `fully_saturated_bmcs_exists_int`.
- **Standard completeness?**: NO. Uses `bmcs_truth_at` which quantifies box over bundle families, not TaskFrame histories.
- **Value**: Full Henkin-style completeness over BMCS semantics.

### 4.3 Standard Completeness (`standard_weak_completeness`, `standard_strong_completeness`)
- **Statement**: If phi is valid/a semantic consequence in standard TaskFrame semantics, then phi is provable/derivable.
- **Status**: TWO SORRIES due to Omega-mismatch.
- **Standard completeness?**: INTENDED, but not yet achieved.
- **Value**: This is the target result.

## 5. Resolution Path

### 5.1 Recommended Approach: Modify `valid` to Quantify Over Omega

**Step 1**: Change `valid` in `Validity.lean`:
```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

**Step 2**: Change `semantic_consequence` similarly:
```lean
def semantic_consequence (Gamma : Context) (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    (forall psi in Gamma, truth_at M Omega tau t psi) ->
    truth_at M Omega tau t phi
```

**Step 3**: Update soundness proofs. The main `soundness` theorem in `Soundness.lean` currently instantiates `Omega = Set.univ`. With the new definition, it needs to work for arbitrary Omega. Key changes:
- Axiom validity lemmas need `Omega` parameter and `h_mem : tau in Omega`
- Modal axiom proofs (T, 4, B, 5, K) that use universal quantification over histories need `h_mem`
- MF and TF axioms need `ShiftClosed Omega` -- BUT validity quantifies over ALL Omega, so the proof needs to work for non-shift-closed Omega too. **This is the critical question**.

**Step 3 analysis -- MF and TF under arbitrary Omega**:

The MF axiom states: `Box phi -> Box (G phi)`. Currently proved using time-shift:
- Assume `Box phi` at `(M, tau, t)` with `Omega = Set.univ`: for ALL histories sigma, phi at (sigma, t).
- For any sigma at any s >= t, use `time_shift sigma (s-t)` as witness: phi at `(time_shift sigma (s-t), t)` by hypothesis, then by `time_shift_preserves_truth`, phi at `(sigma, s)`.

With arbitrary Omega, the proof breaks because `time_shift sigma (s-t)` may not be in Omega. The MF and TF axiom proofs REQUIRE `ShiftClosed Omega` or `Omega = Set.univ`.

**Resolution for MF/TF**: Either:
- (a) Add `ShiftClosed Omega` to `valid` definition -- but then canonical model must provide shift-closed Omega, which it currently does not.
- (b) Keep `Omega = Set.univ` in `valid` but change `satisfiable` to use `Set.univ` too -- then the Omega-mismatch goes away, but the canonical model must show truth at `Set.univ`.
- (c) Restructure the canonical model to produce shift-closed Omega.

**Option (b) seems most promising**: Change `satisfiable` to always use `Set.univ`:
```lean
def satisfiable (D : Type*) [...] (Gamma : Context) : Prop :=
  exists (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    forall phi in Gamma, truth_at M Set.univ tau t phi
```

Then the completeness proof needs `truth_at M Set.univ tau t phi.neg`, which requires the canonical truth lemma to work with `Omega = Set.univ` instead of `canonicalOmega`. This means the box case in `canonical_truth_lemma` must relate MCS membership to quantification over ALL histories, not just canonical ones.

**This brings back the classical completeness challenge**: The box backward case needs "if phi is true at ALL histories at time t, then Box phi in the MCS." With `Set.univ`, there are non-canonical histories in the quantification, and the IH does not apply to them.

### 5.2 Alternative Approach: Omega-Parameterized Validity with Shift-Closure

Define:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

**Soundness**: All axiom proofs go through because shift-closure provides the needed `time_shift_preserves_truth`.

**Completeness**: Need to construct a shift-closed Omega containing the canonical histories. This is possible by taking the shift-closure of `canonicalOmega`:
```lean
def shiftClosedOmega (B : BMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
  { sigma | exists fam hfam delta, sigma = time_shift (canonicalHistory B fam hfam) delta }
```

This is shift-closed by construction. But the truth lemma must be reproved for this larger Omega, and the box case becomes harder again: sigma in `shiftClosedOmega` may be a shifted canonical history, and the IH may not directly apply.

### 5.3 Pragmatic Path Forward

Given the analysis, the most tractable resolution is:

1. **Keep `valid` with `Set.univ`** (current definition)
2. **Prove a "truth monotonicity for negation" lemma**: For the specific formula `phi.neg`, if `truth_at M (canonicalOmega B) tau t phi.neg`, then `not (truth_at M Set.univ tau t phi)`. This works because:
   - `phi.neg = phi.imp bot`
   - `truth_at M Set.univ tau t phi.neg` = `truth_at M Set.univ tau t phi -> False`
   - If `truth_at M (canonicalOmega B) tau t phi.neg`, then `truth_at M (canonicalOmega B) tau t phi -> False`
   - If `truth_at M Set.univ tau t phi`, then truth_at at any sub-Omega...

   **This does not work** because truth_at is not monotone in Omega (due to the box case in subformulas).

3. **The real pragmatic path**: Accept that the Omega parameter is a fundamental design issue, and resolve it by choosing option (5.1.b) -- using `Set.univ` everywhere and proving a truth lemma for `Set.univ`. This requires a different canonical model construction where the box case works for all histories, not just canonical ones. This is a standard challenge in modal logic completeness that can be resolved by ensuring the canonical model has the property that truth at any history at time t only depends on the MCS at time t (not on the whole history structure). Since the canonical valuation is defined as MCS membership and the task relation is trivial, all histories with the same state at time t will agree on truth of all formulas -- making the box case work.

**Key insight**: With a trivial task relation and universal domains, ALL world histories are just arbitrary functions from Int to CanonicalWorldState. For any such history sigma, `truth_at M Set.univ sigma t phi` depends only on `sigma.states t` (for formulas not containing box) and on all possible states at time t (for the box case). Since every MCS appears as a canonical world state, the box quantification over Set.univ is equivalent to quantification over all MCS -- which is exactly what `canonicalOmega` provides (since each family's time-t state is an MCS, and there's a family for every needed MCS).

**The missing step**: Prove that for any history sigma (with trivial task relation, universal domain), there exists a canonical history tau in canonicalOmega such that `sigma.states t = tau.states t` for the relevant time t. Then truth at (sigma, t) equals truth at (tau, t) for box-free formulas, and for the box case, the universality of the bundle handles it.

## 6. Effort Estimates

| Task | Effort | Risk |
|------|--------|------|
| Fix stale FMP documentation comment | 5 min | None |
| Option 5.1.b: Change satisfiable to Set.univ + reprove truth lemma | 2-3 days | Medium -- box case for Set.univ is the challenge |
| Option 5.2: Shift-closed Omega approach | 3-5 days | High -- reprove truth lemma for larger Omega |
| Option 5.3 pragmatic: Prove truth depends only on state at t | 1-2 days | Low-Medium -- needs careful proof that truth_at with trivial task rel depends on state-at-t |
| Update soundness for modified valid (if needed) | 1-2 days | Low -- proofs mostly carry over |

## 7. Recommendations

1. **Immediate**: Fix the stale documentation in `FMP/FiniteWorldState.lean` (lines 81-86) to reflect reflexive semantics.

2. **Priority**: Resolve the Omega-mismatch. The recommended approach is to prove a **"truth at trivial frame depends only on states"** lemma: in the canonical model with trivial task relation, `truth_at M Omega sigma t phi` depends only on `{sigma'.states t | sigma' in Omega}` (the set of states reachable at time t via histories in Omega). Since `canonicalOmega` covers ALL MCS states at every time (one canonical history per family, and families are closed under the modal coherence), and since `Set.univ` with the canonical model only adds histories whose states-at-t are already covered, the two should be equivalent.

3. **Architecture**: Consider whether the Omega parameter should be part of the frame definition rather than threaded through every semantic definition. The JPL paper defines validity with respect to a model `(F, Omega, V)` where `Omega` is fixed, not quantified over.

4. **FMP**: The FMP completeness result is valuable for finite model property and decidability, but should not be conflated with standard completeness. Consider renaming or documenting it more clearly as "completeness over finite closure truth assignments."

## 8. Files Examined

| File | Path | Relevance |
|------|------|-----------|
| Standard truth | `Theories/Bimodal/Semantics/Truth.lean` | Official truth definition |
| Standard validity | `Theories/Bimodal/Semantics/Validity.lean` | Official validity (uses Set.univ) |
| TaskFrame | `Theories/Bimodal/Semantics/TaskFrame.lean` | Official frame structure |
| TaskModel | `Theories/Bimodal/Semantics/TaskModel.lean` | Official model structure |
| WorldHistory | `Theories/Bimodal/Semantics/WorldHistory.lean` | Official history structure |
| FMP completeness | `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` | FMP truth + completeness |
| FMP world states | `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` | Stale documentation found |
| FMP bounded time | `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean` | FMP time domain |
| BMCS structure | `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` | Bundle definition |
| BMCS truth | `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` | BMCS truth predicate |
| BMCS completeness | `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | BMCS completeness theorems |
| Representation | `Theories/Bimodal/Metalogic/Representation.lean` | Bridge to standard semantics (2 SORRIES) |
| Soundness | `Theories/Bimodal/Metalogic/Soundness.lean` | Standard soundness (sorry-free) |
| Legacy completeness | `Theories/Bimodal/Metalogic/Completeness.lean` | MCS properties, no sorry |
| Indexed MCS Family | `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` | Family structure |
| Temporal coherence | `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` | TC definition |
