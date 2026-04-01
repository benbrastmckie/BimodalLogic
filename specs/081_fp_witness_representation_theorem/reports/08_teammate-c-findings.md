# Report 08 Teammate C: Resolution Ordering and Direct Construction Analysis

## Task

Deep-dive into approach (c) from Report 06 — Direct Construction for F-obligation resolution
in an F-persistence chain. Specifically: can we schedule resolution steps alongside
F-persistence steps in a single chain?

---

## 1. What `temporal_theory_witness_exists` Guarantees

**File**: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`, lines 2212-2244

The seed for `temporal_theory_witness_exists` is:

```
{phi} ∪ temporal_box_seed(M)
```

where `temporal_box_seed(M) = G_theory(M) ∪ box_theory(M)`.

The resulting MCS W satisfies:
1. `phi ∈ W` (resolution)
2. `∀ a, G(a) ∈ M → G(a) ∈ W` (G-theory propagation)
3. `box_class_agree M W` (same modal saturation class)

Note: `G_theory(M) = {G(a) | G(a) ∈ M}` and `box_theory(M)` contains box-formulas.

**Critical observation**: The seed `temporal_box_seed(M)` is a subset of M (by
`temporal_box_seed_subset_mcs`). The seed does NOT include `f_content(M)`. So:

- If `F(psi) ∈ M`, the Lindenbaum extension W may or may not contain `F(psi)`.
- In particular, Lindenbaum can freely add `G(neg(psi))` to W, which kills `F(psi)`.
- The witness W gives `g_content(M) ⊆ W` (by `temporal_witness_g_persistence`), but
  NO guarantee about `f_content(M)`.

**Conclusion**: `temporal_theory_witness_exists` does NOT preserve F-obligations.
Only G-obligations are preserved.

---

## 2. The `forward_temporal_witness_seed` vs `temporal_box_seed`

**File**: `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean`

The bundle-level seed `forward_temporal_witness_seed M psi = {psi} ∪ g_content(M)` is
a SIMPLIFIED version compared to the algebraic-level `{psi} ∪ temporal_box_seed(M)`.

The bundle seed only contains `g_content(M)`, while the algebraic seed also contains
`box_theory(M)`. Both are G-liftable, and both support the same G-lift consistency proof.

Key for our analysis: neither seed includes F-formulas. Both seeds support F-resolution
for ONE formula, but neither preserves other F-obligations.

---

## 3. The DovetailedChain.lean Story: What Was Tried and Why It Failed

**File**: `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean`

The file contains a long design discussion (lines 288-605) documenting the evolution
of the approach. The core narrative is:

### Attempt 1: Naive Dovetailing (lines 140-201)

Built `forward_dovetailed` using:
- `forward_step M h_mcs phi`: extends M with seed `{phi} ∪ temporal_box_seed(M)` if
  `F(phi) ∈ M`, else takes a default step
- Scheduled formula: `schedule_formula n = Denumerable.ofNat Formula (Nat.unpair n).2`
- Chain: `forward_dovetailed M_0 n` = n-th iteration of forward steps

The construction SUCCESSFULLY proves:
- G-propagation: `G(a) ∈ chain(n) → G(a) ∈ chain(n+1)` (from `forward_step_G_agree`)
- g_content inclusion: `g_content(chain(n)) ⊆ chain(n+1)` (from `forward_step_g_content`)
- backward_H coherence: `h_content(chain(n+1)) ⊆ chain(n)` (from g/h duality)

But it FAILS at `forward_F` (lines 287-487, extensive design commentary).

### Why Naive Dovetailing Fails

At step `n = Nat.pair t (encode phi)`, the chain checks if `F(phi) ∈ chain(n)`.
If `F(phi) ∈ chain(n)`, it resolves and gives `phi ∈ chain(n+1)`. Done!

But: `F(phi)` may NOT be in `chain(n)` even though `F(phi) ∈ chain(t)` at the
starting time t (with t ≤ n). Lindenbaum at intermediate steps can add `G(neg(phi))`,
which enters the G-theory of subsequent steps and forces `neg(phi)` everywhere after.

The file states at line 385: "F-formulas do NOT necessarily persist. This was the issue
identified in Task #69."

The file further identifies (lines 557-590): "Lindenbaum can introduce G(neg(phi))
before the scheduler gets to phi." Since Lindenbaum is non-deterministic (via Zorn),
it has no constraint preventing this.

### The Conceptual Barrier (lines 473-479, 535-590)

"F-formulas are NOT G-liftable. The Task #69 counterexample confirms this."

The G-lift argument works for `temporal_box_seed` because every element x has `G(x) ∈ M`,
enabling the chain `L ⊢ neg(phi) → G(L) ⊢ G(neg(phi)) → G(neg(phi)) ∈ M → contradiction`.

For F-formulas: `F(psi) ∈ M` does NOT give `G(F(psi)) ∈ M` in general. (There is no
axiom schema `F(psi) → G(F(psi))`.) So including F-formulas in the seed breaks the
G-lift consistency proof.

### The Proposed Solution (lines 593-605)

The file ends by suggesting: "BUILD THE CHAIN USING constrained_successor_from_seed
(which already exists) BUT MODIFIED to also force resolution of a scheduled formula."

This points directly to the `restricted_forward_chain` infrastructure.

---

## 4. The Restricted Forward Chain: F-Persistence Already Solved

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

The `restricted_forward_chain` construction (lines 2700-2938) achieves F-persistence:

```lean
theorem restricted_forward_chain_f_content_persistence (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    f_content (restricted_forward_chain phi M0 n) ⊆
    restricted_forward_chain phi M0 (n + 1)
```

This means: **if `F(psi) ∈ chain(n)`, then `psi ∈ chain(n+1)`** (strong F-step).

Furthermore, `restricted_forward_chain_forward_F` (line 2930):

```lean
theorem restricted_forward_chain_forward_F (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
    ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m
```

**F-obligations are resolved in ONE step** (at step n+1). This is because the seed
`constrained_successor_seed_restricted` includes f_content as explicit members, and
consistency holds by the F-content consistency theorem (Report 06, Section 3).

### How F-Persistence Works in the Restricted Chain

The `constrained_successor_restricted` uses a seed that includes:
- `g_content(M)` (G-propagation)
- `f_content(M)` re-expressed as deferral disjunctions `{psi ∨ F(psi) | F(psi) ∈ M}`

The consistency of this seed is proven by: supposing inconsistency, extracting the
disjunction violation, and applying G-lift to get `G(neg(psi)) ∈ M`, contradicting `F(psi) ∈ M`.

But there is a restriction: the chain is over `DeferralRestrictedMCS`, meaning each world
is restricted to the deferral closure of a fixed formula phi. This is a completeness
RESTRICTION, not a solution for arbitrary MCS chains.

### The Restriction Limitation

`DeferralRestrictedMCS phi M` means `M ⊆ deferralClosure phi`. The deferral closure
of phi is a finite set containing all "relevant" formulas for proving phi. Outside
this closure, the maximality principle doesn't apply.

For the general completeness theorem, we need chains starting from arbitrary MCS
(not restricted to any particular formula's closure). The restricted chain only handles
the restricted case.

---

## 5. The Core Question: Resolution Ordering in an F-Persistence Chain

### Setup

Suppose we have an F-persistence chain M_0, M_1, M_2, ... where:
- `f_content(M_n) ⊆ M_{n+1}` (strong F-step)
- `g_content(M_n) ⊆ M_{n+1}` (G-propagation)

Given `F(phi) ∈ M_0`, is `phi ∈ M_1`?

**YES by construction**: In the restricted chain, `phi ∈ f_content(M_0)` means
`phi ∈ M_1`. This is exactly `restricted_forward_chain_F_resolves`.

But this doesn't help directly for general (unrestricted) chains, because we need
the underlying consistency of the f_content seed for general MCS.

### Question 4: How Often Is the Combined Seed Inconsistent?

Report 06 §4 shows the combined seed `{phi} ∪ g_content(M) ∪ f_content(M)` can be
inconsistent when `G(F(psi) → neg(phi)) ∈ M`.

Let me analyze this more carefully:

**The inconsistency requires**: `(F(psi) → neg(phi)) ∈ g_content(M)`, i.e., the formula
`F(psi) → neg(phi)` is G-necessitated. This is a SPECIFIC formula saying "if F(psi) then
not phi, always."

**When is this formula absent?** When no G-formula of the form `G(F(psi) → neg(phi))`
is in M. By the G-lift argument, if `G(F(psi) → neg(phi)) ∉ M`, then this constraint
doesn't apply.

**Key insight**: The inconsistency arises from a specific ORDERING constraint embedded
in M. If M contains `F(phi)` and `F(psi)` along with `G(F(psi) → neg(phi))`, then
phi and psi CANNOT be resolved simultaneously. One must come before the other.

The formula `G(F(psi) → neg(phi))` means "at any time where F(psi) holds, phi is false
now." If we put phi at time t, then at time t we cannot have F(psi) — so psi must
appear BEFORE t, at some time s < t. But F(psi) ∈ M_0 means psi at some future time.
If psi comes first (at step s), then `F(psi) ∉ M_s` (since psi is now true, the obligation
is discharged) — and at step t (when phi is resolved), the constraint `G(F(psi) → neg(phi))`
applies: F(psi) is false at t (since psi already appeared), so the implication is
vacuously true.

**This is the temporal order that works**: resolve psi first, then phi. The combined
seed `{psi} ∪ g_content(M_0) ∪ {F(phi)}` IS consistent in the counterexample from
Report 06 (confirmed in §4 of that report).

### The Resolution Ordering is Temporally Determined

**Theorem (Informal)**: For any MCS M with F(phi_1), ..., F(phi_k), there exists a
linear ordering of the phi_i's such that resolving them in that order keeps the combined
seed consistent at each step.

**Argument sketch**: The constraints G(F(phi_j) → neg(phi_i)) define a partial order
on the resolution obligations (i must come after j). Since these constraints are formulas
in M, and M is consistent, the order cannot be circular (otherwise M would be
inconsistent itself: G(F(phi_j) → neg(phi_i)) and G(F(phi_i) → neg(phi_j)) combined
with F(phi_i) and F(phi_j) would force phi_i and phi_j to be resolved with each being
before the other — a contradiction).

**Therefore**: The resolution obligations in any consistent MCS admit a linear order
(a topological sort of the partial order defined by temporal precedence constraints).

---

## 6. The Dovetailing with Temporal Order: What's Feasible

### Approach (c) Direct Construction Revisited

The proposed approach was: at step (i,j) via `Nat.unpair`, resolve the j-th F-obligation
from chain(i). The problem was F-obligations at chain(i) might be gone at step n = Nat.pair(i,j).

**Why this fails**: The dovetailed chain already processed many steps between i and n.
At each intermediate step k, the resolution of some OTHER obligation phi_m could kill
F(phi_j) if `G(F(phi_j) → neg(phi_m)) ∈ chain(k)` — wait, let me check: if phi_m is
resolved at step k (so phi_m ∈ chain(k+1)), and `G(F(phi_j) → neg(phi_m)) ∈ chain(k)`,
then chain(k+1) has phi_m and the G-formula. Does this make F(phi_j) ∈ chain(k+1)?

Actually: if `G(F(phi_j) → neg(phi_m)) ∈ M` and phi_m is resolved, then AFTER the
resolution, at chain(k+1) we have phi_m and G(F(phi_j) → neg(phi_m)). The G-formula
says "at all future times, if F(phi_j) holds, then not phi_m." Since phi_m is now
TRUE at chain(k+1), and the G-formula constrains ALL future times, we get:

At chain(k+1): phi_m ∈ chain(k+1) AND G(F(phi_j) → neg(phi_m)) ∈ chain(k+1) (by G-propagation).
The G-formula applied at chain(k+1): "if F(phi_j) ∈ chain(k+1), then neg(phi_m) ∈ chain(k+1)."
Since neg(phi_m) ∉ chain(k+1) (phi_m ∈ chain(k+1) and MCS consistency), we conclude:
`F(phi_j) ∉ chain(k+1)`.

**This is precisely when F(phi_j) is "killed" by an out-of-order resolution.**

### The Out-of-Order Problem Is Real

If phi_m is resolved before phi_j but `G(F(phi_j) → neg(phi_m)) ∈ M`, then after
phi_m is resolved, F(phi_j) is killed. From that point, phi_j will NEVER appear in
the chain (since neg(phi_j) will be forced by G(neg(phi_j)) ∈ chain(k+1) or similar).

This is NOT a problem for the completeness proof — if `G(F(phi_j) → neg(phi_m)) ∈ M`,
then it is logically FORCED that phi_m appears before phi_j. The resolution order
is semantically determined.

**But for the dovetailed chain, we need to RESPECT this ordering.** Naive dovetailing
(arbitrary scheduling) doesn't respect the ordering.

---

## 7. The Winning Strategy: Order-Respecting Resolution

### Key Insight from the Analysis

The F-obligations in any consistent MCS form a partially ordered set under temporal
precedence constraints (derived from G-formulas). Consistent resolution requires
respecting this partial order.

The `restricted_forward_chain` DOES respect this ordering: it resolves ALL F-obligations
at each step via f_content persistence. This works because:
1. `f_content(M) ⊆ M_{n+1}` — every F-obligation is resolved in one step
2. Multiple obligations are resolved simultaneously — no ordering conflict

The reason multiple simultaneous resolutions are consistent is the F-content consistency
theorem (Report 06, §3): `g_content(M) ∪ f_content(M)` (where f_content contains the
F-FORMULAS themselves, not their witnesses) is consistent. The witnesses are the
ATOMS psi, and those can be added one by one respecting the partial order.

### Concrete Approach for Unrestricted Chains

**Goal**: Build a general (non-restricted) F-persistence chain.

**The missing piece**: The restricted chain uses `constrained_successor_restricted`
which works within `deferralClosure phi`. For the general case, we need
`constrained_successor_general` that works for arbitrary MCS.

**Theorem needed**:

```lean
theorem general_f_content_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (g_content M ∪ {F | ∃ psi, F = Formula.some_future psi ∧
                                              Formula.some_future psi ∈ M})
```

This is exactly Report 06's `f_content_g_content_consistent`. If this holds, then we
can define:

```lean
noncomputable def general_f_persistent_seed (M : Set Formula) : Set Formula :=
  g_content M ∪ { Formula.some_future psi | Formula.some_future psi ∈ M }
```

And prove `SetConsistent (general_f_persistent_seed M)` directly, without restriction
to deferral closure.

**The consistency proof**: Same argument as the restricted case — G-lift + disjunction
property. No restriction to deferral closure is needed.

Once we have `general_f_persistent_seed_consistent`, we can define:

```lean
noncomputable def general_f_persistent_step (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Set Formula :=
  (set_lindenbaum (general_f_persistent_seed M)
    (general_f_persistent_seed_consistent M h_mcs)).choose
```

And prove:
1. `f_content(M) ⊆ general_f_persistent_step M`
   (Because each `F(psi) ∈ M` is in the seed, and the extension includes the seed)
2. `g_content(M) ⊆ general_f_persistent_step M`
   (Because g_content(M) ⊆ general_f_persistent_seed M ⊆ extension)

Wait — step 1 above would give `F(psi) ∈ W` (i.e., `F(psi)` remains in the successor),
not `psi ∈ W`. This gives F-persistence (F-obligations survive), not F-resolution.
F-resolution (getting `psi ∈ W`) requires a separate step.

### Separating F-Persistence from F-Resolution

There are TWO properties needed:

1. **F-persistence**: `F(psi) ∈ M_n → F(psi) ∈ M_{n+1}` (the obligation survives)
2. **F-resolution**: `∃ m > n, psi ∈ M_m` (the obligation is eventually discharged)

The `restricted_forward_chain` achieves BOTH simultaneously (via deferral disjunctions:
`psi ∨ F(psi)` forces one of the two at each step, and the chain's maximality then
forces `psi` to appear at some point).

For unrestricted chains, we need a different mechanism for F-resolution.

---

## 8. Analysis of Question 4: When Is the Combined Seed Consistent?

### The combined seed: `{phi} ∪ g_content(M) ∪ {F(psi) | F(psi) ∈ M}`

From Report 06: This is inconsistent when `G(F(psi) → neg(phi)) ∈ M` for some psi.

**How often does this occur?**

If M is generated from a single formula or a small set, the formula `G(F(psi) → neg(phi))`
would need to be "explicitly present" in M or derivable from M. For generic MCS, this
formula may not be in M at all.

**Key structural observation**: The inconsistency is a SIGN THAT THE RESOLUTION ORDER
IS CONSTRAINED. If `G(F(psi) → neg(phi)) ∈ M`, it means the model requires phi to
come AFTER the last occurrence of F(psi) is discharged (i.e., after psi appears).

For a SIMPLE chain starting from an MCS with finitely many F-obligations and no such
crossing constraints, the combined seed IS consistent, and direct simultaneous resolution
works.

**When are there no crossing constraints?**

If M contains F(phi_1), ..., F(phi_k) and for NO pair (i,j) does M contain a formula
`G(F(phi_j) → neg(phi_i))`, then the combined seed `{phi_1, ..., phi_k} ∪ g_content(M)`
is consistent, and all obligations can be resolved in ONE step.

For general M, the crossing constraints define a DAG of resolution order. In the
worst case, the DAG is a total order and we must resolve one obligation per step.

**Claim**: For any consistent M with F-obligations, there exists at least one phi_i
such that the combined seed `{phi_i} ∪ g_content(M) ∪ {F(phi_j) | j ≠ i, F(phi_j) ∈ M}
∪ other F-formulas` is consistent. This is the first obligation in the topological
ordering.

This gives a computable resolution strategy: at each step, find the "first" unresolved
obligation (by topological order) and resolve it.

---

## 9. Concrete Theorem Statements for the Construction

### Theorem 1: F-Persistence Step (Unrestricted)

```lean
theorem unrestricted_f_persistence_step (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧
      f_content M ⊆ f_content W ∧
      g_content M ⊆ W
```

**Proof strategy**: Let seed = `g_content M ∪ {Formula.some_future psi | Formula.some_future psi ∈ M}`.
By `general_f_content_consistent` (still needs to be proven, but follows from Report 06 §3),
the seed is consistent. Extend to MCS W by set_lindenbaum. Then:
- `g_content M ⊆ W`: seed includes g_content, and extension ⊇ seed
- `f_content M ⊆ f_content W`: for each `F(psi) ∈ M`, we have `F(psi) ∈ seed ⊆ W`,
  so `F(psi) ∈ W`, i.e., `psi ∈ f_content W`

**Status**: Blocked only on `general_f_content_consistent`.

### Theorem 2: Scheduled Resolution in F-Persistent Chain

The key theorem for approach (c):

```lean
theorem scheduled_resolution_works (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧
      phi ∈ W ∧
      g_content M ⊆ W ∧
      ∀ psi, Formula.some_future psi ∈ M →
        psi ∈ W ∨ Formula.some_future psi ∈ W
```

This says: resolving phi gives a W where phi ∈ W, all G-obligations propagate, and
each other F-obligation is either resolved (psi ∈ W) or deferred (F(psi) ∈ W).

**Proof strategy**: This follows the deferral disjunction approach of the restricted chain.
The seed is `{phi} ∪ g_content M ∪ {psi ∨ F(psi) | F(psi) ∈ M}`.

**Consistency of this seed**: 
- `{phi} ∪ g_content M` is consistent (from F(phi) ∈ M, by `forward_temporal_witness_seed_consistent`)
- Adding `psi ∨ F(psi)` for each F(psi) ∈ M: need to show the combined set is consistent

This is the KEY technical question. Unlike adding F(psi) directly (which can conflict),
adding `psi ∨ F(psi)` is a weaker constraint. Does the combined seed remain consistent?

**The answer**: It depends on whether `G(F(psi) → neg(phi)) ∈ M`. If so, then:
- From `phi` (in seed) and `G(F(psi) → neg(phi)) ∈ g_content(M)` (in seed), we get
  a constraint on the seed that forces psi to NOT be resolved at this step.
- But `psi ∨ F(psi)` in the seed with `psi` inconsistent forces `F(psi)` into W.
- So at this step, psi is DEFERRED (F(psi) ∈ W), not resolved. Consistent!

**So the deferral disjunction seed IS consistent** when the resolution formula phi
is fixed and disjunctions allow deferral.

### Theorem 3: Combined Seed with Deferral Disjunctions

The "best possible" seed:

```lean
noncomputable def combined_resolution_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ g_content M ∪ { Formula.or psi (Formula.some_future psi) |
                           psi : Formula // Formula.some_future psi ∈ M }
```

**Claim**: This seed is consistent whenever `F(phi) ∈ M`.

**Proof**: Suppose `L ⊆ combined_resolution_seed M phi` and `L ⊢ bot`.
Filter L into: phi-part, g_content-part, disjunction-part.

Case analysis:
1. If phi ∉ L: All of L is in g_content M ∪ disjunction-set. The g_content part
   is G-liftable. The disjunctions are also in M (since psi ∨ F(psi) follows from
   F(psi) ∈ M by the F-to-disjunction axiom: F(psi) → (psi ∨ F(psi))). Wait —
   does F(psi) → (psi ∨ F(psi)) hold? Yes, trivially. So psi ∨ F(psi) ∈ M for
   each F(psi) ∈ M. All disjunctions are in M. So L ⊆ M is inconsistent, contradicting M.

2. If phi ∈ L: L_rest ⊢ neg(phi). L_rest ⊆ g_content M ∪ disjunction-set.
   If L_rest ⊆ g_content M: G-lift gives G(neg(phi)) ∈ M, contradicting F(phi) ∈ M.
   If L_rest has disjunctions: For each `psi ∨ F(psi)` in L_rest, apply case split.
   Either psi ∈ M or F(psi) ∈ M (trivially true for each disjunction). The derivation
   L_rest ⊢ neg(phi) uses the disjunctions directly. But each disjunction is IN M,
   so L_rest ⊆ M, and from M we can derive neg(phi), which contradicts F(phi) ∈ M.
   Wait: we need L_rest ⊢ neg(phi) in M's context. If L_rest ⊆ M, then by MCS closure,
   neg(phi) ∈ M, i.e., G(neg(phi)) could be derived — no, the derivation gives neg(phi) ∈ M
   directly. But neg(phi) ∈ M contradicts F(phi) ∈ M only if F(phi) = neg(neg(phi)) = phi...
   No, F(phi) = neg(G(neg(phi))), not neg(phi).
   
   CORRECTION: neg(phi) ∈ M and F(phi) = neg(G(neg(phi))) ∈ M are COMPATIBLE. neg(phi)
   means "phi is false NOW" and F(phi) means "phi is true eventually." These coexist.
   
   The CONTRADICTION comes from G(neg(phi)) ∈ M and F(phi) ∈ M. So we need L_rest ⊢ neg(phi)
   to give G(neg(phi)) ∈ M via G-lift, which requires L_rest ⊆ temporal_box_seed M.
   
   But L_rest includes disjunctions `psi ∨ F(psi)`, which are NOT in temporal_box_seed M
   (not G-liftable). So the G-lift argument doesn't directly apply.

**Conclusion**: The combined_resolution_seed consistency proof is NOT straightforward.
The disjunction formulas `psi ∨ F(psi)` break the G-lift argument.

### Theorem 4: The Fundamental Consistency Result Needed

To make approach (c) work without restriction, we need to prove:

```lean
theorem combined_deferral_seed_consistent (M : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent ({phi} ∪ g_content M ∪
      { Formula.or psi (Formula.some_future psi) |
        psi : Formula // Formula.some_future psi ∈ M })
```

**Proof strategy using M's MCS property**:

Suppose the seed is inconsistent. Then finite L ⊆ seed with L ⊢ bot.
Separate: phi-part, g_content-part, disjunction-part.

Key observation: each disjunction `psi ∨ F(psi)` in L is PROVABLE from F(psi) (since
`F(psi) → (psi ∨ F(psi))` is a tautology). So each disjunction is in M (since F(psi) ∈ M
implies the disjunction is derivable, and MCS is closed under derivation).

Therefore the entire L_no_phi ⊆ M. From L_no_phi ⊢ neg(phi) (by deduction from
L ⊢ bot), and L_no_phi ⊆ M, by MCS closure: neg(phi) ∈ M.

But F(phi) = neg(G(neg(phi))) ∈ M is compatible with neg(phi) ∈ M (phi false now,
true eventually). NO CONTRADICTION yet.

We need: G(neg(phi)) ∈ M to get the contradiction. But L_no_phi ⊆ M and L_no_phi ⊢ neg(phi)
doesn't give G(neg(phi)) ∈ M directly — only neg(phi) ∈ M by MCS closure.

**The proof FAILS**: We cannot get G(neg(phi)) from the disjunction-containing context.

---

## 10. The Deep Obstacle: Disjunctions Are Not G-Liftable

This analysis confirms the fundamental barrier identified in Task #69 and DovetailedChain.lean.

The witness seed `{phi} ∪ g_content(M)` works because EVERYTHING in g_content(M) is G-liftable.
The seed `{phi} ∪ temporal_box_seed(M)` works for the same reason.

Any seed that contains F-formulas OR disjunctions involving F-formulas BREAKS the G-lift
argument. This is not a proof technique limitation — it reflects a semantic fact:

**Adding F-obligations to the seed allows the Lindenbaum extension to "remember" that
phi will come later, while the seed is about what's true NOW. The G-lift argument proves
consistency by showing that any failure must propagate into M's G-theory, but F-formulas
are about the FUTURE, not the G-theory.**

---

## 11. Synthesis: What Approach (c) Can and Cannot Do

### What Works

1. **Unrestricted F-persistence** (step A of approach (c)):
   - Seed: `g_content(M) ∪ { F(psi) | F(psi) ∈ M }` IS consistent by Report 06 §3.
   - This gives a chain where F-obligations PERSIST (F(psi) ∈ M_n → F(psi) ∈ M_{n+1}).
   - This does NOT resolve obligations — they persist indefinitely.

2. **Single-step resolution** (step B):
   - Given F(phi) ∈ M, the seed `{phi} ∪ temporal_box_seed(M)` IS consistent.
   - This resolves phi at cost: other F-obligations may be killed.

### What Doesn't Work

3. **Combined persistence + resolution** at the same step:
   - Seed `{phi} ∪ g_content(M) ∪ { F(psi) | F(psi) ∈ M }` is NOT always consistent.
   - This is the combined seed blocker from Report 06 §4.

4. **Deferral disjunctions** (safe alternative):
   - Seed `{phi} ∪ g_content(M) ∪ { psi ∨ F(psi) | F(psi) ∈ M }` — consistency proof FAILS
     because disjunctions are in M (not breaking M), but the G-lift argument doesn't
     apply to derive G(neg(phi)).

### The Most Promising Path

The most promising concrete construction for approach (c) is:

**Use TWO chain types alternating:**
1. An F-persistence chain (using F-content seed): preserves all obligations
2. Resolution steps: periodically extract ONE obligation and resolve it using
   `temporal_theory_witness_exists` from the CURRENT F-persistent chain

The key theorem:

```lean
theorem f_persistence_chain_forward_F (M_0 : Set Formula)
    (h_mcs_0 : SetMaximalConsistent M_0) :
    ∀ phi (h_F : Formula.some_future phi ∈ M_0),
      ∃ n : Nat, ∃ M_n : Set Formula,
        -- M_n is an MCS reachable from M_0 by some forward steps
        reachable M_0 M_n ∧ phi ∈ M_n
```

where `reachable` allows alternating F-persistence and resolution steps.

**But this doesn't give a SINGLE CHAIN** — it gives a tree (or dag) of chains.
Different resolution choices at different steps lead to different chains.

For same-family temporal coherence, we need a SINGLE linear chain where EVERY
obligation from every earlier step is eventually satisfied IN THAT CHAIN.

---

## 12. The Answer to the Core Question

**Q**: Can resolution be scheduled in an F-persistence chain without losing F-obligations?

**A**: NOT with a single linear chain using the existing tools. Here is why:

1. F-persistence requires keeping `F(psi) ∈ M_{n+1}` when `F(psi) ∈ M_n`.
2. Resolution of phi requires `phi ∈ M_{n+1}` from `F(phi) ∈ M_n`.
3. The combined requirement may be inconsistent (Report 06 §4 counterexample).
4. Even with deferral disjunctions, the consistency proof fails.

**The only successful approach** for unrestricted general chains is the restricted
forward chain pattern, which achieves BOTH at each step by:
- Resolving ALL current F-obligations (via deferral disjunctions `psi ∨ F(psi)`)
- The deferral disjunction is IN M (since F(psi) → psi ∨ F(psi) is provable)
- The MCS maximality WITHIN the deferral closure forces one of psi or F(psi)
  into the successor

The critical difference: the restricted chain uses `DeferralRestrictedMCS` maximality
(maximality within a closed finite set of formulas), which is STRONGER than general MCS
for the relevant formulas. This stronger maximality allows choosing psi over F(psi) when
both are available.

For the UNRESTRICTED case, the path forward is:

**Extend `general_f_content_consistent`** (proving it is consistent to include ALL
F-obligations in the seed alongside g_content) and then use the SAME mechanism as
the restricted chain (deferral disjunctions), but prove that eventually every obligation
gets resolved rather than perpetually deferred.

The key additional theorem needed:

```lean
theorem f_content_not_persistently_deferred (M : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M)
    (chain : Nat → Set Formula)
    (h_chain : ∀ n, ForwardChainStep (chain n) (chain (n+1)))
    (h_persist : ∀ n, Formula.some_future phi ∈ chain n) :
    False
```

This says: it's impossible for an F-obligation to persist in ALL steps of a forward
chain without ever being resolved. This would follow from the **compactness argument**
(approach (b) from Report 06): if phi is never resolved, then phi's negation eventually
becomes G-necessary, which contradicts F(phi) persisting.

**Conclusion**: Approach (c) via direct construction reduces to approach (b) compactness
at the final step. The direct construction CAN build a chain with F-persistence, but
proving that obligations are eventually resolved requires a compactness/König-style
argument.

---

## 13. Specific Lean-Ready Theorem Statements

### Statement A (Feasible, likely provable)

```lean
-- The F-content seed is consistent (unrestricted version of restricted chain result)
theorem general_f_content_seed_consistent (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    SetConsistent (g_content M ∪ { f | ∃ psi, f = Formula.some_future psi ∧
                                              Formula.some_future psi ∈ M }) := by
  -- Proof: Same as forward_temporal_witness_seed_consistent but for all F-formulas
  -- If L ⊆ seed and L ⊢ bot:
  -- Case 1 (no F-formula in L): G-lift gives G(bot) ∈ M → contradiction
  -- Case 2 (some F-formula F(psi_j) in L): deduction gives G-lifted contradiction
  --   via disjunction: bot follows from L_G and F(psi_1),...,F(psi_k)
  --   by G-lifting L_G and using T-axiom: G(neg(psi_1) ∨ ... ∨ neg(psi_k)) ∈ M
  --   → some G(neg(psi_j)) ∈ M → contradiction with F(psi_j) ∈ M
  sorry
```

### Statement B (Harder, may need new infrastructure)

```lean
-- Building an F-persistence chain from any MCS
theorem exists_f_persistence_chain (M_0 : Set Formula)
    (h_mcs_0 : SetMaximalConsistent M_0) :
    ∃ chain : Nat → Set Formula,
      chain 0 = M_0 ∧
      (∀ n, SetMaximalConsistent (chain n)) ∧
      (∀ n, g_content (chain n) ⊆ chain (n + 1)) ∧
      (∀ n psi, Formula.some_future psi ∈ chain n →
        Formula.some_future psi ∈ chain (n + 1) ∨ psi ∈ chain (n + 1)) := by
  sorry
```

### Statement C (The crux, needs compactness or König's lemma)

```lean
-- F-obligations are eventually resolved in an F-persistence chain
-- This is the theorem that approach (c) reduces to approach (b)
theorem f_persistence_chain_eventually_resolves
    (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (chain : Nat → Set Formula)
    (h_chain_0 : chain 0 = M_0)
    (h_mcs : ∀ n, SetMaximalConsistent (chain n))
    (h_g_prop : ∀ n, g_content (chain n) ⊆ chain (n + 1))
    (h_f_step : ∀ n psi, Formula.some_future psi ∈ chain n →
      psi ∈ chain (n + 1) ∨ Formula.some_future psi ∈ chain (n + 1)) :
    ∀ t psi, Formula.some_future psi ∈ chain t →
      ∃ s > t, psi ∈ chain s := by
  sorry
```

Statement C is the hardest. The proof would follow from: if phi is never resolved
(deferred at every step), then `G(neg(phi)) ∈ chain(t)` for sufficiently large t
(since neg(phi) is always chosen over F(phi) in the MCS completion, and G-formulas
accumulate). But G(neg(phi)) ∈ chain(t) eventually contradicts F(phi) ∈ chain(t).

This requires formalizing a "persistence implies G-necessity" argument, which
is essentially a compactness/König argument.

---

## 14. Summary and Recommendations

1. **Approach (c) direct construction** does NOT eliminate the need for a deeper argument.
   The F-persistence chain construction (Statement B) is straightforward given
   `general_f_content_seed_consistent` (Statement A). But proving forward_F (Statement C)
   still requires a compactness-style argument.

2. **The restricted forward chain** (already in SuccChainFMCS.lean) is the MOST COMPLETE
   existing implementation. It solves BOTH F-persistence and F-resolution for restricted
   MCS. The restriction to deferral closure is the bottleneck.

3. **The most promising path forward** is to prove `general_f_content_seed_consistent`
   (Statement A above) and then use the SAME construction as `constrained_successor_restricted`
   but without the deferral closure restriction. The `DeferralRestrictedMCS` maximality
   is what forces resolution over deferral. For unrestricted MCS, we need a different
   mechanism to force resolution.

4. **The compactness argument** (approach (b)) is the cleanest path for Statement C.
   If we can show "infinite F-obligation chain is finitely inconsistent," we get
   forward_F without building an explicit chain. This requires Compactness for
   the logic TM, which should be provable from the Lindenbaum machinery.

5. **Recommendation for Phase 3**: Focus on proving `general_f_content_seed_consistent`
   (this is provable and fills a gap in the current development). Then use the compactness
   approach for forward_F, treating the F-persistence chain construction as an intermediate
   step that reduces the problem to: "a chain with F-persistence but no resolution is
   inconsistent."
