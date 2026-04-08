# Teammate B Findings: Soundness Sorries + BXCanonical Lean Infrastructure

## Part 1: Soundness.lean Sorries

### Sorry at Line 877: `soundness` theorem, `temporal_duality` case

**Location**: `Theories/Bimodal/Metalogic/Soundness.lean:877`
**Theorem**: `soundness` (the *general*, frame-class-unrestricted soundness theorem)
**Context**: In the `temporal_duality` case of the induction on `DerivationTree`.

**Root Cause**: The general `soundness` theorem is parameterized over an arbitrary
`D : Type` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` but no
density or discreteness constraints. The `temporal_duality` inference rule requires
`derivable_implies_swap_valid` from `SoundnessLemmas.lean`, which has
`[DenselyOrdered D] [Nontrivial D]` in its signature.

**Origin**: This is NOT a leftover from the BX refactor. It is an **architectural
limitation** that predates BX -- the general soundness theorem was never intended to
handle `temporal_duality` without frame constraints. The comments explicitly say
"This sorry is intentional and documents the frame-class restriction."

**Assessment**:
- **Difficulty**: Medium-hard (structural refactoring)
- **Blocks anything critical?**: No. The frame-specific soundness theorems
  (`soundness_dense` at ~line 960, `soundness_dense_valid` at line 904) handle
  `temporal_duality` correctly with `DenselyOrdered D` constraints. The general
  theorem is a convenience wrapper that will always need *some* frame constraints
  for `temporal_duality`.
- **Can it be closed?**: Yes, by one of two approaches:
  1. **Remove the sorry by removing the case**: Restrict `soundness` to derivations
     that don't use `temporal_duality` (add `h_no_td` precondition), or
  2. **Add frame constraints**: Make `soundness` require `[DenselyOrdered D]
     [Nontrivial D]`, which would make it equivalent to `soundness_dense`.
  3. **Prove swap_valid without density**: The actual `axiom_swap_valid` proof
     (lines 466-702) does NOT use `DenselyOrdered` or `Nontrivial` in any case.
     The constraint exists only because it's called from `derivable_valid_and_swap_valid`
     which needs density for `axiom_locally_valid`. If we factor out a standalone
     `derivable_implies_swap_valid_general` that proves swap-validity without
     density, the general `soundness` theorem could handle `temporal_duality`.

**Recommended approach**: Option 3 -- factor `derivable_implies_swap_valid` to not
require density. This is the cleanest solution. The key insight is that `axiom_swap_valid`
is already proved without using density; the constraint is inherited from the combined
`derivable_valid_and_swap_valid` theorem's `axiom_locally_valid` call. A standalone
swap-only induction would avoid this.

**Confidence**: High (the proof structure already exists, just needs factoring)

---

### Sorry at Line 1094: `soundness_discrete_valid` theorem, `temporal_duality` case

**Location**: `Theories/Bimodal/Metalogic/Soundness.lean:1094`
**Theorem**: `soundness_discrete_valid` (discrete-frame soundness for closed derivations)
**Context**: `temporal_duality` case.

**Root Cause**: No `derivable_implies_swap_valid_discrete` exists. The dense version
(`derivable_implies_swap_valid`) requires `[DenselyOrdered D]`, which contradicts
discrete frame constraints.

**Origin**: This is a **gap introduced during the frame-class-specific soundness
extension**. The dense version was built but the discrete analog was never created.

**Assessment**:
- **Difficulty**: Low-medium (same approach as line 877, option 3)
- **Blocks anything critical?**: Not directly -- the BXCanonical completeness proof
  doesn't depend on discrete soundness.
- **Can it be closed?**: Yes, same factoring approach as line 877. A frame-class-free
  `derivable_implies_swap_valid_general` would work for both dense and discrete cases.

**Confidence**: High

---

### Sorry at Line 1151: `soundness_discrete` theorem, `temporal_duality` case

**Location**: `Theories/Bimodal/Metalogic/Soundness.lean:1151`
**Theorem**: `soundness_discrete` (discrete-frame soundness with context)
**Context**: `temporal_duality` case.

**Root Cause**: Identical to line 1094. Same missing `derivable_implies_swap_valid_discrete`.

**Assessment**: Identical to line 1094. Same fix applies.

**Confidence**: High

---

### Summary: All 3 Soundness Sorries Have a Unified Fix

All three sorries share the same root cause: the swap-validity theorem is coupled to
density constraints it doesn't actually need. A single refactoring produces a
`derivable_implies_swap_valid_general` theorem without frame constraints, which closes
all three. The refactoring involves:

1. Create `axiom_swap_valid_general` by copying `axiom_swap_valid` (lines 466-702) and
   removing the `[DenselyOrdered D] [Nontrivial D]` instance parameters (the proof
   body doesn't use them).
2. Create `derivable_swap_valid_general` by mutual induction on derivation height:
   - `axiom` case: `axiom_swap_valid_general`
   - `temporal_duality` case: swap involution + IH
   - `modus_ponens`, `necessitation`, `temporal_necessitation`: existing helper lemmas
   - `weakening`: height decrease
3. Use `derivable_swap_valid_general` in all three sorry locations.

**Estimated effort**: 1-2 hours (mostly mechanical copying and type-checking).

---

## Part 2: Lean Infrastructure for BXCanonical Completeness

### 2.1 TaskModel Structure Requirements

A `TaskModel F` (where `F : TaskFrame D`) requires a single field:
```
valuation : F.WorldState -> Atom -> Prop
```

A `TaskFrame D` requires:
```
WorldState : Type
task_rel : WorldState -> D -> WorldState -> Prop
nullity : forall w u, task_rel w 0 u <-> w = u
compositionality : forall w x y u v, task_rel w x u -> task_rel u y v ->
                   task_rel w (x + y) v
```

A `WorldHistory F` requires:
```
domain : D -> Prop
domain_convex : ...  (convex subset)
states : (t : D) -> domain t -> F.WorldState
respects_task : ...  (compatible with task_rel)
```

**Key challenge**: The BXCanonical model must map BXPoints (MCS) to a TaskFrame/TaskModel
structure. The old `CanonicalConstruction.lean` already does this for a different
canonical model approach using `FMCS` (families of MCS indexed by Int).

### 2.2 Existing Canonical Model Patterns

**`CanonicalConstruction.lean` approach** (old Bundle/FMCS approach):
- `WorldState = Subtype SetMaximalConsistent` (MCS as world states)
- `task_rel`: Forward-only with identity at zero, based on `ExistsTask` (g_content subset)
- D = Int
- WorldHistories: Linearized FMCS chains
- Has a full truth lemma (though for the old axiom system)

**Reusability for BXCanonical**:
- The `WorldState = MCS` pattern is directly reusable
- The task_rel based on g_content is the same as bx_le
- The nullity and compositionality proofs can be adapted
- The old truth lemma structure is the template for the new one

**What's different in BXCanonical**:
- BXCanonical uses `BXPoint` (a wrapper around MCS) instead of raw sets
- The temporal ordering `bx_le` matches `ExistsTask` exactly
- Until/Since semantics are new (old system didn't have U/S truth lemma)

### 2.3 Available MCS Properties

From `MCSProperties.lean`:

| Property | Name | Status |
|----------|------|--------|
| Closed under derivation | `SetMaximalConsistent.closed_under_derivation` | Proved |
| Modus ponens in MCS | `SetMaximalConsistent.implication_property` | Proved |
| Negation completeness | `SetMaximalConsistent.negation_complete` | Proved |
| Theorems in MCS | `theorem_in_mcs` | Proved |
| Neg excludes positive | `SetMaximalConsistent.neg_excludes` | Proved |
| Consistency of pair | `set_consistent_not_both` | Proved |
| G-transitivity | `SetMaximalConsistent.all_future_all_future` | Proved |
| H-transitivity | `SetMaximalConsistent.all_past_all_past` | Proved |

From `MaximalConsistent.lean`:
| Property | Name | Status |
|----------|------|--------|
| Lindenbaum's lemma | `set_lindenbaum` | Proved (uses `zorn_subset_nonempty`) |

### 2.4 BX Axiom MCS Consequences

For each BX axiom, membership in an MCS S gives:

| Axiom | Statement | MCS Consequence |
|-------|-----------|-----------------|
| BX1 | `G(phi) -> phi` | `G(phi) in S => phi in S` (reflexivity of bx_le) |
| BX1' | `H(phi) -> phi` | `H(phi) in S => phi in S` |
| BX2 | `G(phi -> chi) -> (phi U psi -> chi U psi)` | Left monotonicity of Until in MCS |
| BX3 | `G(phi -> psi) -> (chi U phi -> chi U psi)` | Right monotonicity of Until in MCS |
| BX4 | `phi -> G(P(phi))` | `phi in S => G(P(phi)) in S` (connectedness) |
| BX4' | `phi -> H(F(phi))` | `phi in S => H(F(phi)) in S` |
| BX5 | `phi U psi -> (phi /\ phi U psi) U psi` | Self-accumulation: Until enriches its guard |
| BX5' | `phi S psi -> (phi /\ phi S psi) S psi` | Mirror for Since |
| BX6 | `phi U (phi /\ phi U psi) -> phi U psi` | Absorption: prevents infinite deferral |
| BX6' | `phi S (phi /\ phi S psi) -> phi S psi` | Mirror for Since |
| BX7 | `(phi U psi) /\ (chi U theta) -> disjunction` | Linearity of temporal witnesses |
| BX7' | `(phi S psi) /\ (chi S theta) -> disjunction` | Mirror for Since |

**Critical for eventuality resolution**: BX5 + BX6 together ensure that Until-eventualities
are eventually resolved. In the canonical model:
- BX5 says if `phi U psi in S`, then at intermediate MCS points not only does phi hold
  but also `phi U psi` persists
- BX6 prevents the eventuality from being deferred indefinitely by absorbing intermediate
  self-referential witnesses

### 2.5 Zorn's Lemma in Mathlib

**Already used**: `set_lindenbaum` in `MaximalConsistent.lean` already uses
`zorn_subset_nonempty` from `Mathlib.Order.Zorn` (imported at line 6).

Available Zorn variants:
- `zorn_subset_nonempty` -- used for Lindenbaum, works with `Set (Set alpha)` ordered by subset
- `zorn_subset` -- variant without nonemptiness requirement
- `zorn_le` / `zorn_le_0` -- for general preorders
- `IsChain.exists_maxChain` -- Hausdorff's maximality principle

**Chain consistency**: `consistent_chain_union` (in MaximalConsistent.lean) already proves
that the union of a chain of consistent sets is consistent. This is the key ingredient
for applying Zorn.

### 2.6 Eventuality Resolution Strategy

The Until/Since truth lemma has 4 sorries in TruthLemma.lean:
1. `until_iff_mcs` forward (psi not in w): line 241
2. `until_iff_mcs` backward: line 244
3. `since_iff_mcs` forward (psi not in w): line 263
4. `since_iff_mcs` backward: line 265

**Forward direction** (Until, psi not in w):
- We have `phi U psi in w` and `psi not in w`
- By BX5: `(phi /\ phi U psi) U psi in w`
- Need to construct a chain of MCS from w to some v where psi in v
- The eventuality persists along the chain (self-accumulation)
- By BX6 (absorption), the chain must eventually reach psi

**Standard approach**: Build a maximal chain of MCS where `phi U psi` persists but psi
does not yet hold. Show that the maximal element must contain psi (otherwise we could
extend the chain, contradicting maximality). This uses Zorn's lemma.

**Alternative to Zorn for eventuality**:
- Zorn is already available and used for Lindenbaum
- A direct transfinite construction is possible but more complex
- The "step-by-step" Lindenbaum argument in the codebase already uses Zorn internally
- **Recommendation**: Use Zorn directly -- it's the standard and simplest approach

**Backward direction** (Until):
- Given `v >= w` with `psi in v` and `phi` in all `u` with `w <= u < v`
- Need to show `phi U psi in w`
- Uses BX4 (connectedness) and BX7 (linearity)
- **Key idea**: By contradiction. If `phi U psi not in w`, then by MCS negation completeness,
  `neg(phi U psi) in w`. Using BX4 and the structure of the canonical ordering, derive
  a contradiction with the existence of the witness v.

### 2.7 Completeness Theorem (Completeness.lean line 144)

The completeness sorry requires:
1. Constructing a canonical TaskModel from BXPoints
2. Applying the truth lemma to show phi is false at w_0

**Required construction**:
```
D := BXPoint (or some linearization of BXPoint ordering)
WorldState := BXPoint
task_rel w d v := bx_le w v (for appropriate d)
valuation w p := (Formula.atom p) in w.formulas
```

**Problem**: BXPoint ordering `bx_le` is a preorder on an unstructured type, not an
ordered additive group. We need D to be `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

**Solutions**:
1. **Use D = Int**: Embed BXPoints into Int-indexed histories (like CanonicalConstruction.lean)
2. **Use D = BXPoint with a linearization**: Problematic -- BXPoint has no natural group structure
3. **Use D = Ordinal or some well-ordered type**: Possible but complex

**Recommended**: Follow the existing pattern in `CanonicalConstruction.lean` using D = Int.
Create FMCS-like families by linearizing the BXPoint preorder into Int-indexed chains.
Each chain becomes a WorldHistory.

### 2.8 Canonical Model Embedding Architecture

**Step 1**: Define canonical TaskFrame with D = Int
```
CanonicalBXTaskFrame : TaskFrame Int where
  WorldState := BXPoint
  task_rel w d v := (d >= 0 /\ bx_le w v) \/ (d = 0 /\ w = v)
```
(Or use the simpler forward-only pattern from CanonicalConstruction.lean)

**Step 2**: Define canonical TaskModel
```
CanonicalBXTaskModel : TaskModel CanonicalBXTaskFrame where
  valuation w p := (Formula.atom p) in w.formulas
```

**Step 3**: Define WorldHistories as linearized chains of BXPoints
- For each BXPoint w_0, construct a history that visits w_0 at time 0
- The chain of MCS along the bx_le ordering provides the temporal structure
- Domain = all of Int (full domain, as done in CanonicalConstruction.lean)

**Step 4**: Define Omega as the set of all canonical histories

**Step 5**: Prove truth lemma for the canonical model (connects to TruthLemma.lean results)

---

## Recommended Approach Summary

### Soundness Sorries (Lines 877, 1094, 1151)

**Single unified fix**: Factor `derivable_implies_swap_valid` to remove density requirement.

1. Create `SoundnessLemmas.lean` additions:
   - `axiom_swap_valid_general` (no density constraints)
   - `derivable_swap_valid_general` (induction on height, swap-only)
2. Use in all three sorry locations
3. **Confidence: HIGH** -- the proof content exists, just needs refactoring

### BXCanonical Completeness Sorries (TruthLemma.lean lines 241, 244, 263, 265 + Completeness.lean line 144)

**Phased approach**:

1. **Until/Since forward (eventuality resolution)** -- Difficulty: HARD
   - Use Zorn to build maximal chain where `phi U psi` persists
   - Show max element must contain psi (via BX5 + BX6)
   - Reuse existing `zorn_subset_nonempty` infrastructure
   - **Confidence: MEDIUM** -- standard in the literature but non-trivial in Lean

2. **Until/Since backward** -- Difficulty: MEDIUM
   - Proof by contradiction using BX4 + BX7
   - **Confidence: MEDIUM-HIGH** -- cleaner proof structure

3. **Canonical model embedding** (Completeness.lean) -- Difficulty: MEDIUM
   - Follow CanonicalConstruction.lean pattern with D = Int
   - **Confidence: MEDIUM-HIGH** -- template exists

---

## Open Questions

1. **Can the eventuality resolution avoid Zorn?** The standard proof uses Zorn, and since
   it's already available in the codebase, there seems no reason to avoid it. But a direct
   construction using formula complexity metrics might be simpler in Lean if the formulas
   are countable (which they are -- Formula is countably generated).

2. **Do we need full D = Int, or can we use a simpler domain?** For the completeness theorem,
   we just need to show validity implies derivability. The canonical model only needs to
   provide a countermodel for non-derivable formulas. Using D = Int with full domain (as in
   CanonicalConstruction.lean) is the simplest approach.

3. **Is the BXPoint preorder enough, or do we need antisymmetry?** The bx_le ordering is
   reflexive and transitive but potentially not antisymmetric (distinct BXPoints may be
   bx_le-equivalent). The TruthLemma.lean already uses `bx_lt` (strict ordering) for the
   Until guard, which handles this correctly.

4. **Does `bx_modal_witness` (Frame.lean line 358-499) have any remaining sorry?** No --
   the modal witness construction is fully proved, including the S5 negative introspection
   argument for the backward direction of modal equivalence.

5. **For the soundness refactoring (line 877 fix), does the `temporal_duality` case in
   `derivable_swap_valid_general` need `axiom_locally_valid`?** No -- the temporal_duality
   case only needs: (a) swap_valid of the sub-derivation (from IH), and (b) validity of
   the sub-derivation (from IH via the involution lemma). It does NOT need axiom_locally_valid.
   The key insight is that the combined `derivable_valid_and_swap_valid` bundles validity +
   swap-validity because temporal_duality needs both, but a swap-only proof can use the
   involution to recover one from the other within the induction.

   **CORRECTION**: Actually, `derivable_swap_valid_general` alone is NOT sufficient.
   The `temporal_duality` case for swap-validity needs `(phi.swap).swap = phi is valid`,
   which requires knowing that phi itself is valid (from the IH's validity component).
   So we still need the *combined* induction proving both `is_valid` and `is_valid swap`.
   But the `axiom` base case for validity doesn't need density if we separate the density
   axiom cases. Since `isDenseCompatible` is always True and there are no density axioms
   in the base BX system, `axiom_locally_valid` can also be proved without density for
   the base axioms. The only axiom that would need density is the density axiom (GG -> G),
   which is not in the BX system.

   **Revised conclusion**: The combined induction CAN be done without density because
   all BX axioms are universally valid (no frame constraints needed). The density constraint
   in the existing code comes from supporting the density extension axiom, which isn't
   relevant to the base BX system.
