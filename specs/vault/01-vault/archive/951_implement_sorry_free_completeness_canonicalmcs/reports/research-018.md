# Research Report: Task #951 (research-018)

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Started**: 2026-03-01T12:00:00Z
**Completed**: 2026-03-01T14:30:00Z
**Effort**: 2.5 hours
**Dependencies**: BidirectionalReachable.lean (sorry-free), CanonicalFrame.lean (sorry-free), CanonicalCompleteness.lean (sorry-free fragmentFMCS)
**Sources/Inputs**: Codebase (TaskFrame.lean, WorldHistory.lean, Truth.lean, Soundness.lean, Axioms.lean, Representation.lean, BidirectionalReachable.lean, CanonicalCompleteness.lean, DovetailingChain.lean, TemporalCoherentConstruction.lean), ROAD_MAP.md, Mathlib lookup, web research
**Artifacts**: - this report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- The current canonical frame uses `task_rel := fun _ _ _ => True` (trivial) and `D = Int`, requiring `[AddCommGroup Int] [LinearOrder Int] [IsOrderedAddMonoid Int]` which Int satisfies natively. The user's directive bans this trivial task_rel.
- The BidirectionalQuotient already has `LinearOrder`. It does NOT have `AddCommGroup` or `IsOrderedAddMonoid` -- and it CANNOT, in general, because it is a quotient of MCSes under a syntactic preorder with no algebraic structure.
- **Key insight**: The correct approach is to use the BidirectionalQuotient as the WORLD domain (not time domain), and construct a SEPARATE time domain D with AddCommGroup structure. The standard approach in tense logic completeness is: worlds = MCSes, time domain = the ordered set structure, task_rel = derived from the canonical accessibility relation.
- **Proposed unified construction**: Use `D = BidirectionalQuotient` (which has LinearOrder) as both world states AND as a "difference monoid" by defining `task_rel w d u` iff `w ≤ u` and `u` is `d` steps from `w` in the quotient ordering. The group operation comes from the Grothendieck construction on the quotient's order-theoretic structure.
- **Alternative (recommended)**: Keep `D = Int` but define a NON-TRIVIAL `task_rel` from the canonical accessibility relation, using the chain embedding `Int -> BidirectionalFragment` to give semantic content to "taking time x".

## Context & Scope

### What was researched

This research addresses the fundamental question of how to construct ALL elements of the canonical TaskFrame from pure syntax -- specifically:

1. How to produce `AddCommGroup D` from MCS properties alone
2. How to produce non-trivial `task_rel` from MCS properties
3. What the exact dependency map is for where these structures are used
4. How classical canonical model constructions handle this problem
5. How to ensure neutrality with respect to density/discreteness extensions

### Constraints from the user

The following are BANNED:
- Two-level validity hierarchy (TemporalFrame vs TaskFrame)
- Trivial `task_rel` definitions (`fun _ _ _ => True`)
- Weakening semantics because completeness "doesn't need" certain properties
- Any trivial definitions

The canonical frame MUST satisfy:
- `[AddCommGroup D]`
- `[LinearOrder D]`
- `[IsOrderedAddMonoid D]`
- Non-trivial `task_rel`

## Findings

### 1. Precise Dependency Map: Where Algebraic Structure Is Used

#### TaskFrame.lean (line 84)
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**What uses what**:
- `0 : D` -- used in nullity (requires `Zero D`, part of `AddCommGroup`)
- `(+) : D → D → D` -- used in compositionality (requires `Add D`, part of `AddCommGroup`)
- `(≤) : D → D → Prop` -- used in WorldHistory.respects_task (requires `LinearOrder`)
- `(-) : D → D → D` -- used in WorldHistory.respects_task and time_shift (requires `Sub D`/`Neg D`, part of `AddCommGroup`)

#### WorldHistory.lean (line 69)
```lean
structure WorldHistory ... (F : TaskFrame D) where
  ...
  respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

**What uses what**:
- `(≤)` on D -- comparing times for ordering
- `(-)` on D -- computing duration between times
- `(+)` on D -- in time_shift: `z + delta`
- `neg` on D -- in inverse time_shift: `(-delta)`
- Convexity uses `(≤)` only
- `add_le_add_right` -- order compatibility (IsOrderedAddMonoid)
- `add_sub_add_right_eq_sub` -- group identity used in time_shift.respects_task

#### Truth.lean (line 112-119)
```lean
def truth_at ... : Formula → Prop
  | Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

**What uses what**:
- `(≤)` on D only -- temporal operators quantify over ordered times
- No `(+)`, `(-)`, or `0` directly in truth definition
- Time-shift preservation uses full group structure

#### Soundness.lean
- `le_refl` -- temporal T-axiom validity
- `le_trans` -- temporal 4-axiom validity
- `add_le_add_right` and `add_sub` -- MF/TF axiom validity (via time_shift)
- `le_total` -- temporal linearity axiom validity
- Full group structure (add, sub, neg) used in time_shift_preserves_truth

#### Representation.lean (line 98-102)
```lean
def canonicalFrame (B : BFMCS Int) : TaskFrame Int where
  WorldState := CanonicalWorldState B
  task_rel := fun _ _ _ => True        -- *** TRIVIAL -- BANNED ***
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial
```

This is exactly what the user has banned.

### 2. Analysis: Why Trivial task_rel Was Used

The current code uses trivial task_rel for a specific reason: the completeness proof never needs to reason about task_rel semantically. The truth lemma relates MCS membership to truth_at, and:

- Temporal operators (G, H) quantify over ALL times in D, not just domain times
- Atoms check domain membership, but with universal domain (`fun _ => True`)
- Box quantifies over histories in Omega
- The task relation only appears in `WorldHistory.respects_task`, which is satisfied trivially

The completeness proof never constructs a history where `respects_task` would fail because:
1. All domains are universal (`fun _ => True`)
2. The task relation is `True`, so respects_task is trivially satisfied
3. No axiom in the system DIRECTLY refers to task_rel in its validity proof

**However**, this is precisely the "illness" the user identifies. The semantics is DESIGNED so that task_rel carries meaning -- it encodes the possible state transitions under tasks of given duration. A trivial task_rel says "any state can be reached from any state in any time", which is semantically vacuous.

### 3. What the Standard Tense Logic Literature Does

In classical tense logic (Kt and extensions), the canonical model construction is:

**Standard Approach** (Goldblatt 1992, Blackburn et al. 2001):
1. **Worlds** = all maximal consistent sets
2. **Accessibility relation** R(w, w') iff GContent(w) ⊆ w' (for future) and HContent(w) ⊆ w' (for past)
3. **Time domain** = The set of worlds itself, ordered by R
4. **Group structure** = NOT constructed from syntax in standard tense logic

The crucial observation: **Standard tense logic does NOT use an abelian group time domain**. Standard Kripke frames for tense logic use a bare relational structure (W, R) where R is a binary relation (often a preorder or linear order). The "abelian group" requirement is SPECIFIC to the JPL paper's task semantics.

In standard completeness proofs:
- The canonical frame IS the set of MCSes with the canonical relation
- No quotient is needed for basic Kt (the canonical relation can be a preorder)
- For linear tense logics (Kt + linearity), the step-by-step method (Bull 1966) or filtration is used
- The time domain does NOT need group structure for completeness

### 4. The Fundamental Tension

The JPL paper's task semantics requires `D = <D, +, ≤>` to be a totally ordered abelian group. This is stronger than what standard tense logic needs. The reason is the task relation:
- `task_rel w d u` means "state u is reachable from state w by a task of duration d"
- Duration d has additive semantics: composing tasks of duration x and y gives duration x+y
- Nullity: zero-duration task is identity
- This is intrinsically algebraic

**The question is**: Does the LOGIC (the axioms) force the canonical time domain to have group structure, or does the group structure come from the INTENDED semantics?

Answer: **The axioms alone do not force group structure.** The axioms are:
- Propositional axioms (no temporal content)
- S5 modal axioms (no temporal content beyond the box)
- Temporal G/H axioms: T (reflexivity), 4 (transitivity), A (connectedness), L (temporal introspection)
- MF, TF (modal-temporal interaction via time-shift)
- Linearity (linear ordering of time)

None of these axioms reference `(+)`, `(-)`, or `0` on the time domain. They only use `(≤)`. The group structure is needed for:
1. WorldHistory.respects_task (compositionality of tasks)
2. WorldHistory.time_shift (shift by delta, using (+))
3. Soundness of MF and TF (using time_shift_preserves_truth)

But for COMPLETENESS (the converse direction), we need to CONSTRUCT a model satisfying these. The model needs group structure on D. The axioms don't hand us this structure -- we must build it.

### 5. Proposal: Non-Trivial task_rel with D = BidirectionalQuotient

#### 5.1 The BidirectionalQuotient Already Has LinearOrder

The codebase already proves (BidirectionalReachable.lean, line 784):
```lean
noncomputable instance instLinearOrderBidirectionalQuotient :
    LinearOrder (BidirectionalQuotient M₀ h_mcs₀)
```

This provides `LinearOrder D` for free if we set `D = BidirectionalQuotient M₀ h_mcs₀`.

#### 5.2 The Problem: No AddCommGroup on BidirectionalQuotient

The BidirectionalQuotient is a quotient of MCSes by the preorder `CanonicalR w₁ w₂ ∧ CanonicalR w₂ w₁`. It has:
- A linear order (proven)
- Successor/predecessor operations `quotientSucc`/`quotientPred` (proven)

But it does NOT have:
- A zero element (which MCS would be "zero"?)
- An addition operation (how to "add" two MCSes?)
- Negation (what is the "inverse" of an MCS?)

These operations have no natural syntactic interpretation. The quotient is an ordered set, not an ordered group.

#### 5.3 Construction A: Grothendieck-Style Group Completion

**Idea**: Embed the BidirectionalQuotient into its Grothendieck group (group of formal differences).

Given a linearly ordered set (S, ≤), we can construct:
- `D = S × S / ~` where `(a, b) ~ (c, d)` iff `a + d = b + c` (in an appropriate sense)
- But this requires a cancellative monoid structure on S, which we don't have

**Obstacle**: The BidirectionalQuotient is not a monoid. It is only a linearly ordered set.

**Alternative**: If we could define a "distance function" `d(a, b)` on the quotient taking values in some group, we could use that group as D. But defining such a distance function requires the quotient to have more structure.

#### 5.4 Construction B: Free Abelian Group with Order (Dedekind Completion Style)

**Idea**: Start with BidirectionalQuotient (linearly ordered), embed into a free ordered abelian group.

Given a linearly ordered set L with a distinguished element e, define:
- `D = Z` (the integers)
- Define an order-preserving embedding `f : L → Z` by choosing a chain enumeration

**This is essentially what the current code does** (using Int), except with trivial task_rel. The improvement is to make task_rel non-trivial.

### 6. RECOMMENDED APPROACH: D = Int with Non-Trivial task_rel

#### 6.1 Core Idea

Keep `D = Int` (which satisfies all algebraic requirements), but define `task_rel` using the chain embedding from Int to BidirectionalFragment:

```
task_rel w d u ≡ ∃ (chain : Int → BidirectionalFragment),
  chain_is_monotone chain ∧
  chain(0).world = w.val ∧
  chain(d).world = u.val
```

Or more precisely, define task_rel to encode the canonical accessibility via temporal distance:

```
task_rel w d u ≡
  (d ≥ 0 → CanonicalR w.val u.val) ∧
  (d < 0 → CanonicalR u.val w.val) ∧
  (d = 0 → w = u)  -- strengthened nullity
```

Wait -- this last version is too strong (d = 0 → w = u would make nullity fail for the general case). Let me refine.

#### 6.2 Refined Non-Trivial task_rel

The canonical interpretation of `task_rel w d u` is:

> "Starting from world-state w, executing a task of duration d results in world-state u, where the temporal ordering of world states respects the sign of d."

In the canonical model, world states are MCSes. The canonical task relation should encode:

```lean
def canonicalTaskRel (w : CanonicalWorldState B) (d : Int) (u : CanonicalWorldState B) : Prop :=
  if d ≥ 0 then CanonicalR w.val u.val
  else CanonicalR u.val w.val
```

Let me verify the axioms:

**Nullity** (`task_rel w 0 w`): When d = 0, we need `CanonicalR w.val w.val`, which holds by `canonicalR_reflexive`.

**Compositionality** (`task_rel w x u ∧ task_rel u y v → task_rel w (x+y) v`): We need to verify this for all sign combinations of x and y:

Case 1: x ≥ 0, y ≥ 0, so x+y ≥ 0.
Have: `CanonicalR w u` and `CanonicalR u v`. Need: `CanonicalR w v`.
This holds by `canonicalR_transitive`.

Case 2: x ≥ 0, y < 0, x+y ≥ 0.
Have: `CanonicalR w u` and `CanonicalR v u`. Need: `CanonicalR w v`.
This does NOT follow from transitivity alone. We need w ≤ v ≤ u, which requires that v is between w and u in the CanonicalR ordering. But CanonicalR w u and CanonicalR v u don't imply CanonicalR w v. They only tell us w ≤ u and v ≤ u. By totality, either w ≤ v or v ≤ w. We need w ≤ v. But we CANNOT derive this.

**This approach FAILS for compositionality in the mixed-sign case.**

#### 6.3 Revised Non-Trivial task_rel (Quantitative)

The problem with 6.2 is that CanonicalR is too coarse -- it doesn't track "how far apart" two MCSes are. We need a quantitative notion of temporal distance.

**Use the chain embedding**: In CanonicalCompleteness.lean, we build a chain `c : Int → BidirectionalFragment`. This chain assigns each integer a position in the fragment. If `c(i) = w` and `c(i+d) = u`, then "the duration from w to u is d".

```lean
def canonicalTaskRel (c : Int → BidirectionalFragment M₀ h_mcs₀)
    (w : CanonicalWorldState B) (d : Int) (u : CanonicalWorldState B) : Prop :=
  ∃ i : Int, c(i).world = w.val ∧ c(i + d).world = u.val
```

**Nullity**: When d = 0, `c(i + 0) = c(i)`, so `c(i).world = w.val ∧ c(i).world = u.val` requires w = u. But nullity only requires `task_rel w 0 w`, which is satisfied by choosing i such that `c(i).world = w.val`. This works if w is in the image of c.

**Compositionality**: If `∃ i, c(i) = w ∧ c(i+x) = u` and `∃ j, c(j) = u ∧ c(j+y) = v`, then we need i+x = j (so that the "u" matches). If the chain is injective on worlds, then c(i+x).world = u.val and c(j).world = u.val implies i+x = j (since the chain visits each MCS at most once in the quotient). Then c(i+x+y) = c(j+y) = v, giving `∃ i, c(i) = w ∧ c(i+(x+y)) = v`.

**This works, but requires the chain to be injective** (i.e., different integers map to different equivalence classes in the quotient).

#### 6.4 The Canonical Chain

The canonical chain `c : Int → BidirectionalFragment` maps each integer to a fragment element. For this to work with task_rel, we need:

1. **Monotonicity**: `i ≤ j → c(i) ≤ c(j)` (i.e., `CanonicalR c(i).world c(j).world`)
2. **Surjectivity on the image**: Every world state in any canonical history is in the image of c (at least, every world state we need for the truth lemma)
3. **Injectivity on the quotient**: If `c(i).world = c(j).world` then `i = j` (in the quotient sense)

Conditions 1 and 2 are already required by the current construction (CanonicalCompleteness.lean builds such chains). Condition 3 may or may not hold depending on the chain construction.

**Problem**: The current chain construction uses `quotientSucc` and `quotientPred`, which may not produce distinct quotient elements at every step. If `quotientSucc(q) = q` for some q (a fixed point), the chain stalls and maps multiple integers to the same fragment element.

**Whether this happens**: If there exists an MCS M such that `GContent(M) = M` (i.e., M is "temporally saturated"), then `fragmentGSucc` applied to M produces a Lindenbaum extension of `GContent(M) = M`, which might equal M itself. For such an M, `quotientSucc` is a fixed point, and the chain stalls.

**Can GContent(M) = M?** Yes: any MCS that contains exactly the theorems would have `G(phi) ∈ M` iff `phi` is a theorem, and every theorem is in M. So `GContent(M) ⊆ M`, and by reflexivity `M ⊆ GContent(M)` would require `phi ∈ M → G(phi) ∈ M`, which is the axiom `phi → G(phi)` (temporal necessitation for G). TM has temporal necessitation as a rule (`⊢ phi` implies `⊢ G(phi)`), so for theorems this holds. But for non-theorems in M, `G(phi) ∈ M` would require `⊢ phi → G(phi)`, which TM does NOT have.

So for a non-trivial MCS (containing non-theorems), `GContent(M) ≠ M`, and the chain should not stall. But this needs careful proof.

#### 6.5 The Recommended Construction

The recommended approach is a two-part construction:

**Part 1: Define the canonical TaskFrame**

```
WorldState := { S : Set Formula // SetMaximalConsistent S }  -- MCSes
D := Int
task_rel w d u :=
  -- Non-trivial: relates temporal distance to CanonicalR
  (d ≥ 0 → CanonicalR^d w.val u.val) ∧
  (d < 0 → CanonicalR^(-d) u.val w.val)
```

where `CanonicalR^n` is the n-fold iteration of the successor relation.

Actually, this still has the compositionality problem for mixed signs.

**Part 2: Simplified but non-trivial approach**

The simplest non-trivial task_rel that satisfies all requirements:

```lean
def canonicalTaskRel (w : CanonicalWorldState B) (d : Int) (u : CanonicalWorldState B) : Prop :=
  if d ≥ 0 then CanonicalR w.val u.val
  else CanonicalR u.val w.val
```

For compositionality, we need:
- Case x ≥ 0, y ≥ 0: transitivity (works)
- Case x < 0, y < 0: transitivity backwards (works)
- Case x ≥ 0, y < 0, x+y ≥ 0: Need `CanonicalR w v` from `CanonicalR w u` and `CanonicalR v u`. By totality (bidirectional_totally_ordered), either `CanonicalR w v` or `CanonicalR v w`. If `CanonicalR v w`, then combined with `CanonicalR w u` we get `CanonicalR v u` (which we already have), but also combined with `CanonicalR v u` we might get `v = w` or `v` between. **We cannot derive the direction we need from totality alone.**

**This approach is UNSOUND for compositionality.**

### 7. DEEPER ANALYSIS: What Compositionality Actually Requires

The compositionality axiom `task_rel w x u ∧ task_rel u y v → task_rel w (x+y) v` with the sign-based definition has a fundamental problem: knowing the signs of x and y tells us the DIRECTION of the CanonicalR relationship, but not the QUANTITATIVE distance. The duration d doesn't just encode direction -- it encodes magnitude.

**Correct approach**: The task_rel must track both direction AND magnitude. This means it must use the chain embedding.

### 8. DEFINITIVE PROPOSAL: Chain-Based Non-Trivial task_rel

Given a chain embedding `chain : Int → BidirectionalFragment M₀ h_mcs₀` that is:
- Monotone: `i ≤ j → chain(i) ≤ chain(j)` (CanonicalR respecting)
- Order-reflecting on its image (for injectivity on quotient)

Define:

```lean
-- WorldState = image of chain (MCSes visited by the chain)
-- ChainWorldState = { w : CanonicalWorldState B // ∃ i, chain(i).world = w.val }

-- task_rel using chain positions
def chainTaskRel (w : ChainWorldState) (d : Int) (u : ChainWorldState) : Prop :=
  ∀ i : Int, chain(i).world = w.val.val → chain(i + d).world = u.val.val
```

**Nullity**: `chainTaskRel w 0 w` holds because `chain(i+0) = chain(i)`.

**Compositionality**: From `chainTaskRel w x u` and `chainTaskRel u y v`:
For any i with `chain(i) = w`, `chain(i+x) = u` (from first). Then for j = i+x, `chain(j) = u`, so `chain(j+y) = v` (from second). Thus `chain(i+x+y) = chain(i+(x+y)) = v`, giving `chainTaskRel w (x+y) v`.

**This works IF the chain is injective on quotient classes** (so that `chain(i).world = chain(j).world` implies i = j, ensuring the universal quantifier in the definition is well-behaved).

Actually, let me reconsider. The universal quantifier `∀ i` may be too strong. If there are multiple chain positions mapping to the same world w, the requirement that ALL such positions have the same successor is a non-trivial constraint.

**Better formulation** (existential):

```lean
def chainTaskRel (w : ChainWorldState) (d : Int) (u : ChainWorldState) : Prop :=
  ∃ i : Int, chain(i).world = w.val.val ∧ chain(i + d).world = u.val.val
```

Nullity: `∃ i, chain(i) = w ∧ chain(i) = w` -- works if w is in the image.

Compositionality: From `∃ i, chain(i) = w ∧ chain(i+x) = u` and `∃ j, chain(j) = u ∧ chain(j+y) = v`:
We get i with chain(i) = w and chain(i+x) = u, and j with chain(j) = u and chain(j+y) = v.
Need: i+x = j. This requires that u appears at a unique chain position, i.e., the chain visits each quotient element at most once.

If the chain is injective, then chain(i+x) = chain(j) implies i+x = j, and we get chain(i+x+y) = chain(j+y) = v. Works.

### 9. Feasibility of Injective Chains

Is the chain `Int → BidirectionalFragment` injective?

The current construction uses `quotientSucc` and `quotientPred` iteratively. For injectivity, we need `quotientSucc(q) ≠ q` for all q (no fixed points in the successor).

**Claim**: `quotientSucc(q) > q` for all q (strict increase).

Proof sketch: `quotientSucc(q) = Lindenbaum(GContent(w))` for some representative w of q. We need `q < quotientSucc(q)`, i.e., `CanonicalR w.world (quotientSucc w).world` AND NOT `CanonicalR (quotientSucc w).world w.world`.

We have `CanonicalR w.world (quotientSucc w).world` by construction (GContent ⊆ Lindenbaum extension).

But we may also have `CanonicalR (quotientSucc w).world w.world` (GContent of the successor ⊆ w), which would make them preorder-equivalent (same quotient class).

**When does this happen?** When `GContent(Lindenbaum(GContent(w))) ⊆ w`. This means: for any phi, `G(phi) ∈ Lindenbaum(GContent(w))` implies `phi ∈ w`. Since `GContent(w) ⊆ Lindenbaum(GContent(w))`, we have `G(phi) ∈ w → G(phi) ∈ Lindenbaum(GContent(w))` trivially. But the Lindenbaum extension may contain NEW G-formulas not in w.

**Can the Lindenbaum extension introduce new G-formulas?** Yes -- the Lindenbaum extension is maximal, so for every formula phi, either phi or neg(phi) is in it. In particular, for any G(psi) not in GContent(w), either G(psi) or neg(G(psi)) is in the extension. If G(psi) ends up in the extension, it creates a new obligation.

**Key question**: Can we ensure the chain is strictly monotone?

This is related to whether every MCS has a STRICT successor -- i.e., whether the temporal order has no endpoints. The axiom `F(neg bot)` (some_future of top, proven in `mcs_has_F_top`) guarantees every MCS has a future witness. Similarly `P(neg bot)` guarantees a past witness. These witnesses are STRICTLY in the future/past because `F(phi)` (existential) and `G(phi)` (universal) interact: if the chain stalled (quotientSucc = id), then every `F(phi)` obligation would be satisfied at the current time, meaning the MCS would need `phi` for every `F(phi) ∈ M`. But `F(neg bot) ∈ M` and `neg bot ∈ M` (the latter being a theorem), so this is trivially satisfiable -- no contradiction from stalling at this level.

**Deeper analysis needed**: Whether the chain can stall is a non-trivial question that depends on whether `GContent(Lindenbaum(GContent(w))) ⊆ w` can hold for a non-trivial w. This is essentially asking whether the sequence `GContent^n(w)` stabilizes.

### 10. Extensibility Analysis: Discrete vs Dense

**For TM (base logic)**: The canonical construction should produce a time domain that is:
- Linearly ordered (proven)
- Has group structure (needs construction)
- Neither necessarily discrete nor necessarily dense

**For TM + discreteness axioms** (e.g., `∃ succ, ∀ x, x < succ(x) ∧ ¬∃ y, x < y < succ(x)`):
- The canonical time domain should specialize to a discrete ordered group
- The canonical choice would be Z (integers)

**For TM + density axioms** (e.g., `∀ x y, x < y → ∃ z, x < z < z < y`):
- The canonical time domain should specialize to a dense ordered group
- The canonical choice would be Q (rationals)

**The base construction must be neutral**: It should not force either discreteness or density. The BidirectionalQuotient is naturally neither -- it's a countable linearly ordered set that could be either, depending on the axioms present in the MCSes.

**Int as D**: Using Int as D pre-commits to discreteness. This is fine for the current logic (which doesn't have density axioms), but prevents extension to dense time. However, the user says: "the logic can be extended in both of these directions, though the resulting extensions cannot then be consistently combined." So for the BASE logic, we need D to be neutral.

**Resolution**: For the base logic, the BidirectionalQuotient itself (as D) would be most neutral. But it lacks group structure. For practical purposes, Int works because the base logic is COMPATIBLE with discrete time (it just doesn't FORCE it).

### 11. The Torsor Perspective

There is an elegant mathematical perspective: the BidirectionalQuotient acts as a **G-torsor** (homogeneous space) for some group G.

A G-torsor is a set X with a free transitive G-action. Given any two points x, y in X, there is a unique g in G with g.x = y. This g is the "difference" y - x.

If the BidirectionalQuotient is a G-torsor for G = Z, then:
- The group Z acts on the quotient by iterated successor/predecessor
- The action is transitive (every element is reachable from every other)
- The action is free (different integers give different elements) -- this is the injectivity condition

**If the quotient is a Z-torsor, then D = Z works with non-trivial task_rel.**

The question reduces to: Is the successor operation on the BidirectionalQuotient free (i.e., does iterating quotientSucc n times always produce a strictly new element)?

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Constant Witness Family | HIGH | Confirms that time-varying families are essential; chain-based task_rel requires non-stalling chain |
| Single-Family BFMCS modal_backward | MEDIUM | Confirms multi-family bundles needed; chain construction is per-family |
| CanonicalReachable/CanonicalQuotient Stack | HIGH | Previous quotient approach failed for different reasons (backward_P witnesses not future-reachable). BidirectionalReachable solves this. |
| Non-Standard Validity (BFMCS/FMP) | HIGH | Must use standard validity. The proposed chain-based task_rel preserves standard validity. |
| Cross-Origin Coherence Proofs | LOW | Not on critical path; chain construction avoids cross-origin issues |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family Approach | ACTIVE | Chain-based task_rel builds on this -- each FMCS family becomes a canonical history with chain-indexed world states |
| Representation-First Architecture | CONCLUDED | Chain-based task_rel extends this: the representation now includes non-trivial task structure |
| Algebraic Verification Path | PAUSED | Free abelian group embedding could provide alternative D construction |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Chain-based task_rel | Section 8 | No | new_file |
| G-torsor structure on canonical quotient | Section 11 | No | new_file |
| Compositionality proof for sign-based relations | Section 7 | No | extension |
| Extensibility to discrete/dense time | Section 10 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `canonical-task-relation.md` | `math/` | How to construct non-trivial task_rel from canonical accessibility | High | No (research-level, not actionable yet) |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| None identified | - | - | - | - |

### Summary

- **New files needed**: 1 (deferred until approach is finalized)
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 1

## Decisions

1. **D = Int is acceptable for now** because the base logic is compatible with discrete time and Int satisfies all algebraic requirements.
2. **task_rel must be non-trivial** per the user's directive. The chain-based formulation (Section 8) is the only approach that satisfies compositionality.
3. **Chain injectivity is the key open question** that determines whether the chain-based task_rel works.
4. **The BidirectionalQuotient cannot directly serve as D** because it lacks AddCommGroup structure, and there is no natural way to define addition on MCS equivalence classes.
5. **For extensibility to dense time**, D = Int would need to be replaced by D = Q (or similar). This can be deferred to when density axioms are added.

## Risks & Mitigations

### Risk 1: Chain stalls (quotientSucc fixed point)
**Severity**: HIGH -- if the chain has fixed points, the chain-based task_rel fails
**Mitigation**: Prove that quotientSucc is strictly increasing. This likely requires showing that Lindenbaum extensions of GContent always introduce genuinely new G-formulas.
**Fallback**: If chain stalls, use a more refined chain construction that dovetails with F/P witness placement to ensure progress.

### Risk 2: Compositionality requires injectivity
**Severity**: MEDIUM -- the existential formulation of chain-based task_rel needs injectivity for compositionality
**Mitigation**: Either prove injectivity or use the universal formulation (∀ i), which doesn't need injectivity but may be harder to satisfy.
**Fallback**: Use a weaker form of compositionality that's still sufficient for soundness.

### Risk 3: Non-trivial task_rel complicates WorldHistory construction
**Severity**: MEDIUM -- canonical histories need to respect the non-trivial task_rel
**Mitigation**: Chain-based task_rel is designed so that chain-indexed histories automatically satisfy respects_task by construction.
**Fallback**: Add additional chain properties to ensure respects_task.

### Risk 4: Soundness may depend on properties the construction doesn't provide
**Severity**: LOW -- soundness is already proven for arbitrary D with the given typeclasses. The construction only needs to provide instances.
**Mitigation**: Verify that Int's existing instances suffice.

## Appendix

### Search Queries Used

1. Lean: `lean_leansearch "ordered additive commutative group from linear order free construction"`
2. Lean: `lean_loogle "Antisymmetrization ?a (· ≤ ·)"`
3. Lean: `lean_leansearch "Grothendieck group of ordered monoid linear order"`
4. Lean: `lean_leanfinder "free ordered abelian group over a linearly ordered set"`
5. Lean: `lean_loogle "FreeAbelianGroup, LinearOrder"`
6. Web: `canonical model tense logic completeness time domain group structure Burgess Goldblatt`
7. Web: `canonical model tense logic completeness ordered abelian group time domain construction from maximal consistent sets`
8. Web: `"perpetuity calculus" "task semantics" ordered abelian group canonical model completeness "task frame" temporal logic`
9. Web: `tense logic Kt completeness canonical frame linear order quotient maximal consistent sets preorder`
10. Web: `Goldblatt "Logics of Time and Computation" canonical model construction tense linear frame abelian group time integers`
11. Web: `Blackburn de Rijke Venema "Modal Logic" canonical model tense logic linear time totality quotient construction completeness proof`
12. Web: `tense logic completeness "use the quotient" OR "antisymmetrization" OR "preorder to linear order" canonical frame construction maximal consistent sets`

### Mathlib Lookup Results

- `LinearOrderedAddCommGroup`: Structure combining LinearOrder + AddCommGroup + compatibility
- `Antisymmetrization`: Mathlib provides PartialOrder on quotient; LinearOrder when input is total
- `FreeAbelianGroup`: Exists in Mathlib as abelianization of FreeGroup, but no ordered version
- `Algebra.GrothendieckAddGroup`: Exists in Mathlib for AddCommMonoid, produces AddCommGroup

### References

- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
- Kamp, H. (1968). *Tense Logic and the Theory of Linear Order*. PhD thesis, UCLA.
- Stanford Encyclopedia of Philosophy: [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- Imperial College London: [Canonical Models for Normal Logics](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf)
- Open Logic Project: [Completeness and Canonical Models](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/completeness.pdf)
