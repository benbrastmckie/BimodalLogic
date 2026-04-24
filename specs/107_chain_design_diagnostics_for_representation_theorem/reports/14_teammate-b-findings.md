# Teammate B Findings: How to Wire the Completeness Theorem

## 1. Current Completeness Statement

`bx_completeness` (Completeness.lean, line 128-150):

```lean
theorem bx_completeness (phi : Formula) :
    valid phi -> Nonempty (DerivationTree [] phi)
```

**What it says**: If phi is valid (true in all models), then phi is derivable from the empty context.

**What it quantifies over**: `valid phi` expands to:

```lean
forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
  (F : TaskFrame D) (M : TaskModel F)
  (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
  (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
  truth_at M Omega tau t phi
```

This quantifies over ALL temporal types D (with ordered abelian group structure and Nontrivial), ALL TaskFrame models, ALL shift-closed Omega sets, and ALL histories/times.

**Proof strategy**: Contrapositive. Assumes not derivable, gets {neg phi} consistent, extends to MCS via Lindenbaum, builds countermodel via `dd_countermodel_chronicle`, then contradicts `valid phi`.

**Existential witness**: `dd_countermodel_chronicle` produces:

```lean
exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
  (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
  (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
  (tau : WorldHistory F) (_ : tau in Omega) (t : D),
  not (truth_at TM Omega tau t phi)
```

The witness is `D = Rat`, with the ParametricCanonicalTaskFrame, the ShiftClosedParametricCanonicalOmega, and the parametric_to_history of the shifted chronicle FMCS at the root point 0.

## 2. Current Soundness Statement

`soundness` (Soundness.lean, line 982-1050):

```lean
theorem soundness (Gamma : Context) (phi : Formula) :
    DerivationTree Gamma phi ->
    (D : Type) -> [AddCommGroup D] -> [LinearOrder D] -> [IsOrderedAddMonoid D] ->
    [Nontrivial D] -> (F : TaskFrame D) -> (M : TaskModel F) ->
    (Omega : Set (WorldHistory F)) -> (h_sc : ShiftClosed Omega) ->
    (tau : WorldHistory F) -> (h_mem : tau in Omega) -> (t : D) ->
    (h_ctx : forall psi in Gamma, truth_at M Omega tau t psi) ->
    truth_at M Omega tau t phi
```

**What it says**: If phi is derivable from Gamma, then phi is a semantic consequence of Gamma.

**What class of models**: It quantifies over ALL temporal types D (with `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial`), ALL `TaskFrame D`, ALL `TaskModel F`, ALL shift-closed Omega sets. It does NOT restrict to any specific frame class.

**Key observation**: Soundness works for ANY model satisfying the structural requirements. There is no restriction to "TaskFrame models" beyond the structural axioms (nullity_identity, forward_comp, converse). The temporal semantics (G, H, Until, Since) only depend on the linear order of D, not on the TaskFrame structure at all. The TaskFrame is needed only for the Box modality (which quantifies over WorldHistories).

**Specialization for empty context**: When Gamma = [], soundness gives:

```
DerivationTree [] phi -> forall D F M Omega h_sc tau h_mem t, truth_at M Omega tau t phi
```

which is exactly `valid phi` (modulo uncurrying).

## 3. How Completeness and Soundness Combine

The combination gives the **adequacy theorem**:

```
Derivable empty phi  <->  valid phi
```

where:
- Forward direction (soundness): `DerivationTree [] phi -> valid phi` -- follows from `soundness` with empty context.
- Backward direction (completeness): `valid phi -> Nonempty (DerivationTree [] phi)` -- this is `bx_completeness`.

**Critical observation**: The completeness direction is already stated correctly. It says validity over ALL TaskFrame models implies derivability. Since `valid` quantifies over all D, all TaskFrame D, etc., any single countermodel in any D suffices to refute validity. The contrapositive builds one countermodel (over Rat) and this is enough.

### What "completeness for all strict linear orders" would mean

If we wanted to state "valid on all strict linear orders implies derivable", we would need a notion of truth that does NOT involve TaskFrame/WorldHistory/Omega. Something like:

```lean
def truth_at_lo (D : Type) [LinearOrder D] (V : Atom -> Set D) (phi : Formula) (t : D) : Prop :=
  | atom p => t in V p
  | bot => False
  | imp phi psi => truth_at_lo D V phi t -> truth_at_lo D V psi t
  | box phi => truth_at_lo D V phi t      -- box collapses (single-history)
  | all_past phi => forall s < t, truth_at_lo D V phi s
  | all_future phi => forall s, t < s -> truth_at_lo D V phi s
  | untl phi psi => exists s, t < s and truth_at_lo D V psi s and forall r, t <= r -> r < s -> truth_at_lo D V phi r
  | snce phi psi => exists s, s < t and truth_at_lo D V psi s and forall r, s < r -> r <= t -> truth_at_lo D V phi r
```

But this is a single-history semantics where Box trivializes. The full bimodal semantics REQUIRES the TaskFrame + WorldHistory structure for Box to be nontrivial.

**Therefore**: Completeness for "all strict linear orders" would only make sense for the temporal fragment (without Box). For the full bimodal logic, completeness must be stated relative to TaskFrame models, which is exactly what `bx_completeness` does.

## 4. The Representation Theorem

### What it is

The "representation theorem" in this codebase is the parametric representation infrastructure in `Algebraic/ParametricRepresentation.lean`. It says:

For any BFMCS (bundled family of MCS) satisfying the coherence conditions (temporal coherence, forward/backward Until/Since coherence), the parametric canonical construction produces a TaskFrame model where the truth lemma holds.

More precisely, the pipeline is:

1. **BFMCS** (abstract data): families of MCS indexed by D, with box-coherence
2. **Coherence conditions**: restricted_temporally_coherent, restricted_backward_until_since_coherent, restricted_forward_until_since_coherent
3. **Parametric canonical construction**: ParametricCanonicalTaskFrame D, ParametricCanonicalTaskModel D, ShiftClosedParametricCanonicalOmega
4. **Restricted truth lemma**: For formulas in subformulaClosure(root), truth at a point in the parametric model corresponds to membership in the MCS

### How it relates to completeness

The completeness proof has this structure:

```
MCS M containing neg phi
  -> chronicle construction (Burgess) -> BFMCS over Rat
  -> coherence proofs (sorry sites here)
  -> parametric representation -> TaskFrame model over Rat
  -> restricted truth lemma -> phi false at evaluation point
  -> contradiction with valid phi
```

The "representation theorem" is step 4: it converts an abstract BFMCS into a concrete TaskFrame model. It is NOT a separate theorem about embedding arbitrary linear orders into TaskFrame models. It is an internal mechanism within the completeness proof.

### Relationship to "every MCS is satisfiable"

The representation theorem effectively says: for every MCS A (extended to a BFMCS via the chronicle), there exists a TaskFrame model satisfying exactly the formulas in A at some point. This IS the representation theorem: consistent sets are satisfiable.

## 5. Soundness for General Linear Orders

### Current situation

Soundness is already stated for general models. The `soundness` theorem quantifies over ALL D with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`, `Nontrivial D`. This includes:
- Int (discrete)
- Rat (dense, the chronicle's domain)
- Real (complete)
- Any other ordered abelian group

The temporal operators (G, H, Until, Since) are evaluated purely in terms of the linear order on D. They do not use the TaskFrame structure at all. The TaskFrame is only used for Box evaluation.

### Is separate "strict linear order" soundness needed?

No. The current soundness theorem already covers every strict linear order. When we instantiate D = Rat, F = ParametricCanonicalTaskFrame, etc., the soundness theorem applies. The countermodel produced by `dd_countermodel_chronicle` is already a valid TaskFrame model (by construction), so soundness applies to it.

### The AddCommGroup requirement

The codebase requires `AddCommGroup D` (not just `LinearOrder D`). This is because:
1. WorldHistory.time_shift uses addition: `time_shift sigma Delta` shifts by Delta
2. ShiftClosed needs this group structure
3. The MF and TF axioms (modal-temporal interaction) require time-shift invariance

This is NOT a limitation. Every dense linear order without endpoints embeds into an ordered abelian group (via Hahn embedding or direct construction). The BX axiom system is designed for this class of structures.

## 6. Guard Convention Compatibility

### The codebase semantics (Truth.lean)

Until uses **A2 guard convention**: strict witness, half-open guard [t, s):

```lean
| untl phi psi => exists s : D, t < s and truth_at M Omega tau s psi and
    forall r : D, t <= r -> r < s -> truth_at M Omega tau r phi
```

Since uses strict witness, half-open guard (s, t]:

```lean
| snce phi psi => exists s : D, s < t and truth_at M Omega tau s psi and
    forall r : D, s < r -> r <= t -> truth_at M Omega tau r phi
```

### The chronicle's C5 condition

The chronicle's `limit_satisfies_c5_weak` only proves the WEAK version: there exists a witness y > x with eta in f(y). It does NOT prove the full guard condition (xi at intermediate points).

From ChronicleConstruction.lean line 444-446:
> "The full guard condition (xi at intermediate points) requires the interval function g, which is handled in the integration phase. Here we prove the weaker version: a witness y with eta in f(y) exists."

### The BFMCS coherence conditions

The `restricted_forward_until_since_coherent` (TemporalCoherence.lean) uses:

For Until: `exists s : D, t < s and psi in fam.mcs s and forall r : D, t <= r -> r < s -> phi in fam.mcs r`

For Since: `exists s : D, s < t and psi in fam.mcs s and forall r : D, s < r -> r <= t -> phi in fam.mcs r`

This matches the A2 convention exactly (half-open [t,s) for Until, half-open (s,t] for Since).

### Mismatch analysis

There IS a gap between what the chronicle proves (weak C5: just witness existence) and what coherence requires (full guard at intermediates). The chronicle's `chronicle_bfmcs_restricted_fuc` bridges this gap, but it is currently sorry'd (ChronicleToCountermodel.lean line 374).

**Burgess's convention**: Burgess 1982 uses open intervals (x, y) for the guard. The codebase uses half-open [t, s). Since the chronicle is built over Rat (dense), the difference is:
- Burgess: forall z, x < z < y -> phi in f(z)
- Codebase: forall r, t <= r < s -> phi in fam.mcs r

The codebase includes the current point t in the guard (t <= r), while Burgess excludes it (x < z). This matters because:
- In the codebase: `phi U psi in mcs(t)` requires `phi in mcs(t)` as part of the guard
- In Burgess: `phi U psi in f(x)` does not require `phi in f(x)` explicitly

However, `phi U psi in mcs(t)` with MCS implies `phi in mcs(t)` by the axiom `phi U psi -> phi or psi` (BX9/until_elim). So the extra obligation at t is automatically satisfied when the current point has the Until formula. This means the conventions are compatible in practice.

## 7. Nontrivial Requirement

### What Nontrivial means

`[Nontrivial D]` requires D to have at least two distinct elements. For an ordered group, this implies `NoMaxOrder` and `NoMinOrder` (every element has a strict successor and predecessor).

### Does the chronicle's Rat domain satisfy this?

Yes, trivially. The chronicle is built over `Rat`, and `Rat` is `Nontrivial` (it has 0 and 1). The `Nontrivial Rat` instance is provided by Mathlib.

### Does the chronicle domain have at least two elements?

The limit domain always contains 0 (by `zero_mem_limit_dom`). But the question is about Rat as a whole, not the limit domain. The countermodel uses D = Rat, not D = limit_dom. The limit_dom is just the set of "interesting" points. The semantics evaluates truth at ALL rational numbers (the extended_limit_f covers all of Rat by falling back to M0 for non-domain points).

### Seriality

The seriality axioms (top -> F(top), top -> P(top)) require that for every t, there exist s > t and r < t. This holds in Rat because Rat has `NoMaxOrder` and `NoMinOrder` (both follow from `Nontrivial` on an ordered group). The soundness proofs for `serial_future_axiom_valid` and `serial_past_axiom_valid` use `exists_gt` and `exists_lt`, which are provided by Nontrivial.

## Summary: The Logical Chain

The complete logical chain for the adequacy theorem:

1. **Soundness** (sorry-free): `DerivationTree Gamma phi -> semantic_consequence Gamma phi`
   - Proved by induction on derivation trees
   - Works for ALL D with the required structure, ALL TaskFrame models
   - Specializes to: `DerivationTree [] phi -> valid phi`

2. **Completeness** (has sorry sites): `valid phi -> Nonempty (DerivationTree [] phi)`
   - Contrapositive: not derivable -> not valid
   - Step 1: {neg phi} consistent (sorry-free, `neg_consistent_of_not_derivable`)
   - Step 2: Extend to MCS via Lindenbaum (sorry-free)
   - Step 3: Build chronicle over Rat (sorry sites in C5/C5' satisfaction)
   - Step 4: Convert to BFMCS (sorry sites in coherence proofs)
   - Step 5: Parametric representation -> TaskFrame model (sorry-free)
   - Step 6: Restricted truth lemma -> phi false at root (sorry-free)
   - Step 7: Instantiate valid phi at the countermodel -> contradiction (sorry-free)

3. **Adequacy**: `Derivable empty phi <-> valid phi`
   - Forward: soundness (sorry-free)
   - Backward: completeness (sorry sites in steps 3-4)

### What does NOT need to change

- The completeness statement is already correct as stated
- The soundness statement is already general enough
- The validity definition already covers all ordered abelian groups
- No "soundness for general linear orders" is needed separately
- No separate "representation theorem" statement is needed beyond the existing parametric infrastructure

### What needs to be proved (the sorry sites)

All remaining sorry sites are in the chronicle -> BFMCS -> coherence pipeline:
- Chronicle FMCS coherence (G/H propagation): `chronicle_fmcs.forward_G`, `chronicle_fmcs.backward_H`, `box_stable_in_chronicle_fmcs`
- Chronicle BFMCS restricted coherence: `chronicle_bfmcs_restricted_tc`, `chronicle_bfmcs_restricted_buc`, `chronicle_bfmcs_restricted_fuc`
- Chronicle construction: `counterexample_enum`, `counterexample_enum_surjective`, `limit_satisfies_c5_weak` (if used with full guard), `limit_satisfies_c5'_weak`

These are ALL internal to the chronicle-to-countermodel pipeline. The outer logical chain is sound.

## Design Recommendation

**Option A (current approach) is correct**: Keep the existing completeness format. The statement `valid phi -> Nonempty (DerivationTree [] phi)` is the right one. It quantifies `valid` over all TaskFrame models (which includes all ordered abelian groups as temporal domains). The witness is D = Rat with the chronicle-based construction. No format change is needed.

**Option B (contrapositive)** is logically equivalent and is in fact how the proof works internally. The current code already uses the contrapositive structure inside `bx_completeness`. There is no reason to change the statement.

**There is no need for a "completeness for all strict linear orders" statement** separate from the existing one, because the existing `valid` already quantifies over all strict linear orders (via the D parameter).
