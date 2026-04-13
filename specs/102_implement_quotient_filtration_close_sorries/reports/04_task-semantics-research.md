# Research Report: Task Semantics and Canonical Model Construction

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Session**: sess_1776050388_e1bc22
- **Focus**: Study task semantics, TaskRel, WorldHistory, and how to define a canonical task relation from which world histories follow automatically

## 1. How the Semantics Defines Task Frames and the Three-Place Task Relation

### 1.1 TaskFrame Structure (TaskFrame.lean)

The `TaskFrame D` structure is parameterized by a temporal duration type `D` (a totally ordered abelian group) and consists of:

```
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

The three-place task relation `task_rel w d u` means: starting from world state `w`, executing a task of duration `d` can result in world state `u`. Three axioms constrain it:

1. **Nullity identity**: `task_rel w 0 u <-> w = u` -- zero-duration tasks are identity.
2. **Forward compositionality**: For non-negative durations `x, y >= 0`, tasks compose: if `task_rel w x u` and `task_rel u y v`, then `task_rel w (x+y) v`.
3. **Converse**: `task_rel w d u <-> task_rel u (-d) w` -- temporal symmetry.

### 1.2 Key Derived Properties

- **Nullity** (reflexivity): `task_rel w 0 w` (trivially from nullity_identity).
- **Backward compositionality**: Derived from forward_comp + converse for non-positive durations.

### 1.3 The Role of Duration Type D

The temporal type `D` generalizes to any ordered additive commutative group. For the canonical model construction, `D = Int` (discrete integer time) is the natural choice for BX completeness. The key constraint is that `D` must provide a total linear order compatible with addition.

## 2. How World Histories Are Derived from the Task Relation

### 2.1 WorldHistory Structure (WorldHistory.lean)

A `WorldHistory F` for task frame `F` consists of:

```
structure WorldHistory (F : TaskFrame D) where
  domain : D -> Prop
  convex : forall x z, domain x -> domain z -> forall y, x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall s t (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

This is a function from a **convex** subset of the time domain to world states, constrained to respect the task relation.

### 2.2 The Fundamental Connection: task_rel Determines Admissible Histories

The `respects_task` constraint is the bridge: for any two times `s <= t` in the domain, the states at `s` and `t` must be related by `task_rel` with duration `t - s`. This means:

- The task relation DETERMINES which sequences of states can form valid histories.
- Given any task frame, the set of all valid world histories is fully determined by `task_rel`.
- The set of admissible histories (`Omega`) used in the box modality is any shift-closed subset of the universe of all valid histories.

### 2.3 Truth Evaluation (Truth.lean)

Truth is defined at `(M, Omega, tau, t)` tuples:

```
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | bot => False
  | imp phi psi => truth_at ... phi -> truth_at ... psi
  | box phi => forall sigma in Omega, truth_at ... sigma t phi
  | all_past phi => forall s <= t, truth_at ... tau s phi
  | all_future phi => forall s, t <= s -> truth_at ... tau s phi
  | untl phi psi => exists s >= t, truth_at ... tau s psi /\ forall r, t <= r -> r < s -> truth_at ... tau r phi
  | snce phi psi => exists s <= t, truth_at ... tau s psi /\ forall r, s < r -> r <= t -> truth_at ... tau r phi
```

Key observations for Until/Since:
- **Until** `phi U psi`: witness `s >= t` with `psi` at `s`, and guard `phi` on the **open left** interval `[t, s)`.
- **Since** `phi S psi`: witness `s <= t` with `psi` at `s`, and guard `phi` on the **open right** interval `(s, t]`.
- Temporal operators quantify over ALL times in D (not just the history's domain).

## 3. The Canonical Model: BXPoint Structure and Current Ordering

### 3.1 BXPoint and bx_le (Frame.lean)

The canonical model uses maximal consistent sets (MCS):

```
structure BXPoint where
  formulas : Set Formula
  is_mcs : SetMaximalConsistent formulas
```

The canonical temporal ordering is:

```
def bx_le (w v : BXPoint) : Prop := g_content w.formulas <= v.formulas
```

This means: `bx_le w v` iff for all `phi`, `G(phi) in w => phi in v`. Properties:
- **Reflexive** (from BX1: `G(phi) -> phi`)
- **Transitive** (from temp_4: `G(phi) -> G(G(phi))`)
- **NOT total** -- this is the root cause of all sorry gaps

### 3.2 The Non-Totality Problem

`bx_le` is NOT total: two MCS can have `G(p) in w, p not in v` AND `G(q) in v, q not in w`. BX11 (temporal linearity: `F(phi) /\ F(psi) -> F(phi /\ F(psi)) \/ F(psi /\ F(phi))`) constrains F-witnesses to be linearly ordered, but this does NOT force `g_content` inclusion to be total.

### 3.3 Where bx_le Totality Would Be Needed

The 4 Frame.lean sorries use the guard condition `bx_le u v /\ not bx_le v u` to express strict ordering. For the eventuality resolution proof, we need: for intermediate `u` between `w` and `v`, show `phi in u`. The proof obtains a backward witness `u'` with `phi in u'` but cannot lift `phi` to `u` because `bx_le u' u` only propagates G-content. If `bx_le` were total on the interval `[w, v]`, we could derive the result.

## 4. The Core Challenge: Defining a Canonical Task Relation

### 4.1 What Is Required

To build a proper semantic countermodel, we need to construct:

1. **WorldState**: The type of world states in the canonical frame.
2. **task_rel**: A three-place relation `task_rel w d u` satisfying nullity_identity, forward_comp, and converse.
3. **World histories**: Functions from convex time domains to world states, automatically constrained by `task_rel`.

The canonical task relation must be defined so that:
- The truth lemma holds: `phi in w.formulas <-> truth_at M Omega tau t phi` for appropriate `(tau, t)`.
- Until/Since witnesses can be constructed (the guard property must be provable).

### 4.2 Approach A: Direct BXPoint-Based Frame (Current Approach)

The current approach implicitly treats BXPoints as world states with `bx_le` as the temporal ordering. But this does NOT give a TaskFrame directly because:
- `task_rel` needs a duration parameter `d : D`, not just an ordering.
- The BXPoints form a preorder, not a linear order.

The truth lemma is proved at the MCS level without constructing an explicit TaskFrame. The Until/Since cases delegate to `bx_until_eventuality_resolution` etc. which are sorry'd.

### 4.3 Approach B: Constructing a Canonical TaskFrame with Integer Time

**Key insight from the focus prompt**: Instead of trying to prove the sorry lemmas within the abstract MCS framework, we should construct an actual `TaskFrame Int` where:

1. **WorldState** = `BXPoint` (or a filtration thereof).
2. **task_rel w d u** is defined in terms of `bx_le` and integer offsets along a canonical chain.
3. **World histories** follow automatically from the `TaskFrame` definition.

The critical question is: HOW to define `task_rel w d u` on BXPoints?

#### Option 1: Chain-Based task_rel

Given the defect-discharge chain infrastructure already built, define:

```
task_rel w d u :=
  if d >= 0 then
    exists a chain w = v_0, v_1, ..., v_k = u with bx_le v_i v_{i+1}
    and k = d (chain length equals duration)
  else
    task_rel u (-d) w (by converse)
```

This gives:
- **nullity_identity**: `task_rel w 0 u` means chain of length 0, so `w = u`. Check.
- **forward_comp**: Concatenation of chains. Check.
- **converse**: By definition. Check.

But this requires the world states to be arranged in chains (i.e., the BXPoints must form a collection of linearly ordered chains). This is exactly what the quasimodel construction tries to achieve but fails due to non-totality of `bx_le`.

#### Option 2: Quotient/Filtration-Based task_rel

Instead of using all BXPoints, work with a **finite** quotient:

1. Fix a target formula `phi_0`.
2. Let `Sigma = enrichedClosure phi_0`.
3. World states = `HintikkaPoint Sigma` (finite set -- there are at most `2^|Sigma|` of them).
4. The temporal ordering on HintikkaPoints is `hintikka_step` (which IS directional and partially encodes Until propagation).
5. Define `task_rel h d h'` via chains of `hintikka_step`.

This avoids the bx_le totality problem because HintikkaPoints live in a finite world where combinatorial arguments can establish totality.

**Problem**: Lifting back to BXPoints requires the realization lemma, which is exactly where the current proofs get stuck.

#### Option 3: Direct Linear Embedding (Most Promising)

For a given formula `phi_0` and MCS `w_0` containing `neg phi_0`:

1. Build a **single world history** as a sequence of BXPoints `..., w_{-2}, w_{-1}, w_0, w_1, w_2, ...` indexed by integers.
2. Define `task_rel w_i d w_j := (j = i + d)` -- the task relation is simply the integer index relation.
3. This trivially satisfies all TaskFrame axioms.
4. The chain construction uses defect-discharge to ensure Until/Since witnesses exist at appropriate integer positions.
5. The guard property is trivially satisfied because the integer ordering IS total.

This is the standard "dovetail chain" construction from Burgess 1984. The key challenge is constructing the sequence `w_i` such that:
- `bx_le w_i w_{i+1}` for all `i`.
- For every Until formula `phi U psi in w_i` with `psi not in w_i`, there exists `j > i` with `psi in w_j` and `phi in w_k` for all `i <= k < j`.
- Similarly for Since going backward.

This is exactly the defect-discharge chain construction that already has scaffolding in `Construction.lean` and `DefectChain.lean`.

## 5. How Option 3 Resolves the Sorry Gaps

### 5.1 The Key Difference

The current proof attempts to prove the guard property for **arbitrary** BXPoints `u` satisfying `bx_le w u` and `not bx_le v u`. This requires showing `phi in u` for any such `u`, which is impossible because `bx_le` does not control non-G-formula membership.

Option 3 sidesteps this entirely: the guard is only required for points **in the constructed chain**, where it can be ensured by construction.

### 5.2 Impact on Frame.lean Sorries

The 4 Frame.lean sorry signatures quantify over arbitrary intermediate BXPoints:

```
forall u : BXPoint, bx_le w u -> bx_le u v /\ not bx_le v u -> phi in u.formulas
```

With Option 3, these signatures would need to be modified (or the proof restructured) so that:
- Instead of quantifying over all BXPoints, we quantify over chain members.
- Or we prove these lemmas for the specific BXPoints in the constructed chain.

### 5.3 Impact on TruthLemma.lean

The TruthLemma currently uses `bx_until_eventuality_resolution` and `bx_until_backward` at their sorry-bearing signatures. If we change the approach to a chain-based construction, the truth lemma would be proved differently:
- Instead of abstractly characterizing Until/Since in terms of `bx_le` intervals, we directly construct the chain-based canonical model and prove truth via the chain structure.

### 5.4 Impact on Realization.lean

The 6 Realization.lean sorries have the same root cause. Under Option 3, they would either:
- Be closed by the same chain construction, or
- Be deleted and replaced by the new chain-based proof.

## 6. Existing Infrastructure and Gaps

### 6.1 Available Infrastructure

| File | Content | Status |
|------|---------|--------|
| `SigmaOrdering.lean` | `sigma_le`, `sigma_strict`, `sigma_equiv` | Complete, 179 lines |
| `DefectChain.lean` | `sigma_defect_count`, `defect_step_phi`, `defect_step_F_psi` | Complete, 137 lines |
| `Construction.lean` | `hintikka_step`, `UntilDefect`, `defect_count`, `QuasimodelChain` | Complete, 350+ lines |
| `Realization.lean` | Enriched seed consistency, bigconj helpers, partial proofs | Partial (6 sorries) |
| `LocusControl.lean` | Delegation wrappers to Realization.lean | Partial (delegates to sorried functions) |
| `Frame.lean` | Core canonical model (BXPoint, bx_le, witnesses) | Partial (4 sorries) |
| `TruthLemma.lean` | Truth lemma for all formula cases | Complete modulo Frame.lean sorries |

### 6.2 What Is Missing for Option 3

1. **Chain construction**: A procedure that, given `w_0 : BXPoint`, builds a bi-infinite chain `(w_i)_{i in Z}` where:
   - `bx_le w_i w_{i+1}` for all `i`.
   - Every Until/Since defect is discharged within finitely many steps.

2. **TaskFrame instance**: Wrap the chain into a `TaskFrame Int` with `task_rel w_i d w_j := (j = i + d)`.

3. **Truth lemma over the chain**: Prove `phi in w_i.formulas <-> truth_at M Omega tau i phi` where `tau` is the canonical history derived from the chain.

4. **Integration**: Either modify Frame.lean/TruthLemma.lean signatures or build a parallel proof path.

### 6.3 Feasibility Assessment

The chain construction is the standard Burgess approach. The defect-discharge infrastructure (DefectChain.lean, Construction.lean) provides the decreasing measure. The main remaining work is:

1. **Forward chain step**: Given `w_i`, construct `w_{i+1}` with `bx_le w_i w_{i+1}` and with all Until-defects either discharged or propagated (with defect count non-increasing). This uses `bx_forward_witness` (already proved) + Lindenbaum extension.

2. **Backward chain step**: Mirror for Since. Uses `bx_backward_witness` (already proved).

3. **Valuation and Omega construction**: Build the TaskModel and shift-closed history set.

## 7. Detailed Analysis of the Guard Property

### 7.1 Why the Guard Is Trivial in a Linear Chain

In the semantic truth definition, Until is:

```
phi U psi at (tau, t) iff exists s >= t, psi at (tau, s)
  and forall r, t <= r < s -> phi at (tau, r)
```

In a chain-based canonical model with integer time, the times `t, r, s` are integers and the states at those times are determined by the chain. The guard `phi at (tau, r)` for `t <= r < s` is over **specific chain members** `w_r`, not arbitrary BXPoints. So the guard becomes:

```
forall r : Int, t <= r < s -> phi in w_r.formulas
```

This is exactly what the defect-discharge construction ensures: at each chain step, either `psi` arrives (discharge) or `phi` is maintained (propagation from `phi U psi in w_r` via BX9).

### 7.2 Why the Current Formulation Cannot Work

The current Frame.lean formulation:

```
forall u : BXPoint, bx_le w u -> bx_le u v /\ not bx_le v u -> phi in u.formulas
```

quantifies over ALL BXPoints `u` between `w` and `v` in the `bx_le` preorder. This is far stronger than needed for semantics, and is unprovable because:
- There are BXPoints `u` with `bx_le w u` and `bx_le u v` that have nothing to do with the Until formula (they were constructed for unrelated Lindenbaum extensions).
- The guard formula `phi` need not be in `u.formulas` for such unrelated `u`.

### 7.3 Resolution Strategy

The resolution is to NOT prove these universal guard lemmas. Instead:
1. Construct the canonical chain directly.
2. Prove truth at chain members.
3. The guard property is a consequence of chain construction, not a precondition.

This means either:
- **(a)** Modifying Frame.lean/TruthLemma.lean to use chain-based proofs (breaking the current sorry signatures).
- **(b)** Proving the sorry signatures by constructing the chain WITHIN the sorry proof body and using the chain to establish the universal guard (which would require showing that every `u` between `w` and `v` in `bx_le` is "chain-equivalent" to some chain member -- essentially proving interval totality, which is the original problem).

Option (a) is clearly more viable.

## 8. Recommended Approach

### 8.1 The Canonical Chain Construction

Given a target formula `phi_0` and an MCS `w_0` with `neg phi_0 in w_0`:

**Forward direction**: Build `w_1, w_2, ...` by iterating:
1. Collect all Until-defects at `w_i`.
2. If no defects, set `w_{i+1} = w_i` (self-loop via reflexivity of bx_le).
3. If defects exist, pick the highest-priority defect `phi U psi`.
4. Construct `w_{i+1}` via Lindenbaum extension of the seed:
   ```
   g_content(w_i) union {psi}  (if psi is the next discharge target)
   g_content(w_i) union {phi, phi U psi}  (if propagating)
   ```
5. The defect count is non-increasing, and eventually every defect is discharged.

**Backward direction**: Mirror for Since, building `w_{-1}, w_{-2}, ...`

### 8.2 The Canonical TaskFrame

```
WorldState := BXPoint  (or just the chain members)
task_rel w_i d w_j := (j = i + d)
```

Nullity, compositionality, and converse are trivial by integer arithmetic.

### 8.3 The Canonical History

The chain IS the world history:
```
domain := Set.univ  (or some convex subset)
states i := w_i
respects_task: task_rel w_s (t-s) w_t follows from j = i + (j-i)
```

### 8.4 What Changes in the Codebase

1. **New file**: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean`
   - Chain construction with defect-discharge
   - TaskFrame Int instance from the chain
   - WorldHistory from the chain
   - Truth lemma at chain members

2. **Modified**: `Completeness.lean`
   - Use CanonicalChain to build the countermodel
   - Replace sorry with chain-based construction

3. **Frame.lean sorries**: Two options:
   - (a) Close them using the chain (requires proving universal guard from chain totality -- still hard).
   - (b) Bypass them: restructure TruthLemma.lean to use the chain directly instead of through Frame.lean intermediaries.

4. **Realization.lean sorries**: Same treatment -- either close via chain or bypass.

Option (b) for both Frame.lean and Realization.lean is cleaner: build the proof from scratch using the chain, and leave the sorry'd lemmas as dead code (or delete them).

## 9. Connection to Existing Plan Phases

### 9.1 What the Current Plan Gets Right

- Phase 1 (SigmaOrdering) and Phase 2 (DefectChain) are completed and provide useful infrastructure.
- The defect-discharge idea is correct.

### 9.2 What the Current Plan Gets Wrong

- Attempting to prove universal guard properties over arbitrary BXPoints (Phases 3-5).
- Trying to close Frame.lean sorries at their current signatures (requires bx_le interval totality).
- The sigma_strict approach was correctly abandoned but the replacement (BX7 direct proof) has the same fundamental problem.

### 9.3 Recommended Plan Revision

1. **Accept** that the Frame.lean sorry signatures are too strong (universal quantification over arbitrary BXPoints).
2. **Build** the canonical chain construction directly (using existing DefectChain infrastructure).
3. **Prove** the truth lemma over the chain (bypassing Frame.lean intermediaries).
4. **Complete** the completeness theorem via the chain-based countermodel.
5. **Optionally** close Frame.lean sorries as corollaries of the chain construction (if needed for other consumers).

## 10. Summary

The fundamental insight is that the three-place task relation `task_rel w d u` in the standard semantics is inherently **linear** (it operates along a single world history). The current proof attempts to establish Until/Since properties over the **non-linear** preorder of all BXPoints, which is algebraically impossible. The resolution is to construct a linear canonical chain and define `task_rel` as the integer-indexed chain relation, from which world histories and their truth properties follow automatically by the standard semantic definitions.
