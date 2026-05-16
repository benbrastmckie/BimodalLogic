# Teammate B Findings: Alternative Approaches for Order Atom Transfer

**Task**: 154 — sum_preservation order atom blocker
**Date**: 2026-05-15
**Role**: Teammate B — Alternative approaches and structural analysis
**Session**: sess_1747343000_b2c3d4

---

## Key Findings

### 1. The Exact Nature of the Blocker

The 4 sorry's occur at NEquivalence.lean lines 264, 334, 400, 459, all in the
`| order j₁ j₂ h_ne =>` branch of the atom agreement case for extended
environments. The goal at each sorry is:

```
Fin.cons ⟨i, x⟩ env_M j₁ < Fin.cons ⟨i, x⟩ env_M j₂  ↔
Fin.cons ⟨i, y⟩ env_N j₁ < Fin.cons ⟨i, y⟩ env_N j₂
```

in the lexicographic order on `Σ i, (ms i).carrier`. This goal arises because
after selecting witness `⟨i, x⟩` matched to `⟨i, y⟩`, the proof must establish
**atom agreement** for the entire extended environment before calling the inductive
hypothesis. Atom agreement includes all order atoms between environment positions,
including atoms that compare the new witness position to existing ones.

Case analysis on j₁, j₂ with `Fin.cases`:
- **Both succ**: Reduces to `h_atoms (.order j₁' j₂' h')` — already given. OK.
- **j₁ = 0, j₂ = succ j'**: Requires `⟨i,x⟩ < env_M j' ↔ ⟨i,y⟩ < env_N j'`.
- **j₁ = succ j', j₂ = 0**: Requires `env_M j' < ⟨i,x⟩ ↔ env_N j' < ⟨i,y⟩`.

The mixed cases (new witness vs existing element) cannot be resolved from `h_elem`
because `h_elem` gives 1-variable NF agreement for individual elements in isolation.
**A 1-variable NF does not encode the order relationship between two distinct
elements.** Concrete counterexample: in Z with no predicates, all elements share
the same depth-0 1-variable NF (the empty truth assignment), but `0 < 5` while
`100 > 5`.

### 2. Why `nf_agreement_monotone` Avoids This Problem

`nf_agreement_monotone` (NormalForm.lean:339-421) faces no order atom problem
because it maintains a **shared NF witness** invariant across ALL variables
simultaneously (not per-variable):

```lean
have h_agree_k' := nf_agreement_from_shared_nf M (Fin.cons x env_M)
  N (Fin.cons y env_N) nf_y_k hMx_k hNy_k
```

Here `nf_y_k : NormalForm sig k' (n+1)` is a single NF for the ENTIRE extended
environment (n+1 variables, including the new one and all old ones). When both
`Fin.cons x env_M` and `Fin.cons y env_N` satisfy the SAME `nf_y_k`, the lemma
`nf_agreement_from_shared_nf` gives agreement on ALL depth-k' NFs with n+1
variables — this includes order atoms between all pairs of environment positions,
including between the new variable (position 0) and old variables (positions 1..n).

**The structural property that `nf_agreement_monotone` exploits**: M and N have
the SAME carrier type (both are `OrderedMonadicStructure sig` with structurally
identical carriers). When `x : M.carrier = N.carrier`, the depth-k NF of
`Fin.cons x env_M` and `Fin.cons y env_N` can be compared because they live in
the same type universe.

In the ordered sum case, `ms i` and `ms' i` have DIFFERENT carrier types in
general (`(ms i).carrier ≠ (ms' i).carrier`). The witnesses `x : (ms i).carrier`
and `y : (ms' i).carrier` cannot share a single ordered-sum-level NF directly.
The matched NF `char_a : NormalForm sig k 1` is a 1-variable NF for each
individual element within its own component, NOT a joint NF for the full extended
environment.

---

## Alternative Proof Structures Investigated

### Alternative 1: Restructure with Joint Multi-Variable NF Hypothesis

**Core idea**: Replace the per-element `h_elem` hypothesis in `sum_nf_agree`
with a JOINT n-variable NF agreement hypothesis:

```lean
private noncomputable def sum_nf_agree' (sig : MonadicSignature) :
    ∀ (k : Nat) (I : Type) [inst : LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ...)
    (n : Nat)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ j, (env_M j).1 = (env_N j).1)
    -- REPLACEMENT: joint n-variable NF agreement per component
    (h_joint : ∀ (m : Nat) (hm : m ≤ k) (s : Fin n → ???),
      -- All j map to same component s(j); within each component,
      -- the joint characteristic of the selected elements agrees)
    ...
```

**Problem with this formulation**: The "joint NF for elements in the same
component" requires grouping environment positions by component index and forming
a joint NF for each group. This is substantially more complex than the original
formulation because:
1. Components can have different subsets of environment positions (e.g., positions
   {0, 2, 5} in component i, positions {1, 3} in component j).
2. The joint NF for a group must account for order atoms between positions IN
   that group.
3. The inductive step then extends one group by one element (when the new witness
   lands in component i, the joint NF for that component extends from |group_i| to
   |group_i|+1 variables).

**Assessment**: Technically correct but adds substantial formalization overhead.
The "grouping by component" mechanism requires either a dependent family of
sub-environments or a more complex compatibility predicate. Estimated additional
complexity: 50-100 lines beyond the current approach.

**Is it feasible?** Yes, but the complexity increase is real. The key insight is
that the joint NF for each component-group captures the order relationships between
all elements IN that component. Cross-component order relationships are always
determined by the I-index comparison (which is the same for both sums, since I is
the same), so they do not need separate treatment.

**Recommended implementation variant**: Use the `nf_characteristic` of the
ORDERED SUM at depth k with the current environment (not per-component), and
show the ordered sum's characteristic equals across both sums. This is "Alternative
2" below.

### Alternative 2: Ordered-Sum-Level `nf_agreement_from_shared_nf` (Strongest Alternative)

**Core idea**: Restructure the proof so that at each quantifier step, both
witnesses satisfy the SAME ordered-sum-level NF for the full extended environment.
Then `nf_agreement_from_shared_nf` at the ordered-sum level gives full agreement
(including all order atoms) for free.

**Concretely**: The quantifier step at depth k+1 must produce witness pairs
`⟨i, x⟩` and `⟨i, y⟩` such that:

```
nf_characteristic (orderedSum sig I ms) k (n+1) (Fin.cons ⟨i,x⟩ env_M) =
nf_characteristic (orderedSum sig I ms') k (n+1) (Fin.cons ⟨i,y⟩ env_N)
```

If this holds, then `nf_agreement_from_shared_nf` applied to the ordered sums
gives agreement on ALL depth-k NFs with n+1 variables — resolving every order
atom sorry simultaneously.

**How to achieve this**: The key is to select witnesses using the ORDERED SUM's
own existential transfer (from the depth-(k+1) NF at the sum level), not just
the component's 1-variable existential transfer.

The sum's depth-(k+1) NF characteristic `char_Σ` satisfies:
```
char_Σ.quant_assgn sub_nf = true ↔
  ∃ x, nf_eval_nf (orderedSum ms) k (n+1) (Fin.cons x env_M) sub_nf
```

If by IH (at depth k) we know: for any depth-k NF `φ : NormalForm sig k (n+1)`,
the two sums agree on φ under compatible extended environments, THEN:
```
∃ x, nf_eval_nf (orderedSum ms) k (n+1) (Fin.cons x env_M) sub_nf ↔
∃ y, nf_eval_nf (orderedSum ms') k (n+1) (Fin.cons y env_N) sub_nf
```

**The circularity problem**: To apply the IH, we need compatible extended
environments — but we don't know the witnesses yet. This is circular.

**Resolution via characteristic extraction**: Use `nf_exists_unique` on the
ordered sum itself to get the k-characteristic of the extended environment.
Then use the IH's quantifier transfer to find the matching witness in the other
sum. The witnesses both satisfy the same ordered-sum-level k-NF, giving
`nf_agreement_from_shared_nf`.

However, this requires the IH to be formulated at depth k WITH the environment
already extended — meaning the IH must work for ALL compatible extended
environments (not just the base one). This is exactly what the current `sum_nf_agree`
lemma tries to do. The circularity arises at the "compatibility" condition for
the extended environment.

**The clean formulation**: The proof should use the following induction statement:

```lean
-- P(k): For all n, for all compatible (env_M, env_N), for all NF φ at depth k with n free vars,
-- nf_eval_nf (orderedSum ms) k n env_M φ ↔ nf_eval_nf (orderedSum ms') k n env_N φ

-- Where "compatible" means:
-- 1. ∀ j, (env_M j).1 = (env_N j).1 (same component indices)
-- 2. nf_characteristic (orderedSum ms) k n env_M = nf_characteristic (orderedSum ms') k n env_N
--    (same k-NF characteristic for the JOINT ordered-sum environments)
```

With this formulation, condition 2 gives `nf_agreement_from_shared_nf`
immediately, resolving all NF evaluations including order atoms. The induction
step must establish that condition 2 holds for extended environments when we
choose witnesses correctly.

**Key insight on condition 2 propagation**: If the two sum environments have the
same k-NF characteristic (condition 2), then by condition 2's quantifier part,
for any realized sub_nf at depth k-1 with n+1 variables, both sums realize it.
The witnesses `x, y` chosen to realize sub_nf both satisfy the SAME depth-(k-1)
ordered-sum NF `sub_nf`. So condition 2 holds for the extended environments —
but only for depth k-1, not depth k.

Wait: this changes the induction. At step k, we need condition 2 at depth k for
the extended environments. But witnesses satisfy `sub_nf` at depth k-1. So we
need the IH at depth k-1 to give us condition 2 at depth k-1 for the extended
environments.

**Final clean statement** (what Doets 1989 actually proves, translated to NF terms):

```lean
theorem sum_nf_char_eq {sig : MonadicSignature} (k : Nat)
    {I : Type} [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ i, k_equiv sig k (ms i) (ms' i))
    (n : Nat)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ j, (env_M j).1 = (env_N j).1)
    (h_char : nf_characteristic (orderedSum sig I ms) k n env_M =
              nf_characteristic (orderedSum sig I ms') k n env_N) :
    ∀ nf, nf_eval_nf (orderedSum sig I ms) k n env_M nf ↔
          nf_eval_nf (orderedSum sig I ms') k n env_N nf
```

With `h_char` as hypothesis, this follows directly from
`nf_agreement_from_shared_nf`. The real work is proving `h_char` holds for the
base environment (n=0, env_M = env_N = Fin.elim0) and propagates through
quantifier steps.

**Assessment**: This is the cleanest alternative and the most likely to work.
It restructures the proof so that the joint ordered-sum NF equality IS the
inductive invariant, eliminating the order atom problem entirely.

### Alternative 3: EF-Game Approach

**Core idea**: Define Ehrenfeucht-Fraisse games for ordered monadic structures,
prove the EF composition lemma for ordered sums.

**Mathlib infrastructure check** (from leansearch):
- `Order.PartialIso` in Mathlib handles pure orders (no predicates) with
  partial isomorphisms, but has no connections to monadic FO or k-types.
- `ModelTheory.PartialEquiv` exists for full classical FO model theory, but is
  for arbitrary (not bounded-depth) partial isomorphisms.
- There is NO Mathlib infrastructure for bounded-depth k-equivalence EF games
  over structures with both predicates and linear orders.

**What would need to be built from scratch** (estimated 400-600 lines):
1. EFPosition type: finite partial isomorphism tracking pairs (a, b) from the
   two structures, respecting predicate agreement and order agreement.
2. WinningStrategy type: function from Spoiler moves to Duplicator responses.
3. Fundamental theorem: k_equiv ↔ Duplicator wins k-round game.
4. Composition lemma: component-wise winning strategies compose into sum strategy.

**Why EF games avoid the order atom problem**: In the EF game, the order atom
comparison is part of the GAME INVARIANT (the partial isomorphism must preserve
order). When Spoiler plays in component i, Duplicator responds in component i
using the component-level winning strategy — which by definition provides an
element that matches all order relationships with previously-played elements
from the SAME component. Cross-component order is handled by the index order
(same in both sums).

The EF game approach avoids the order atom problem because it doesn't need to
construct "atom agreement for extended environments" explicitly — the partial
isomorphism maintains this invariant automatically.

**Assessment**: Mathematically clean but enormously expensive. ~500+ lines of
new infrastructure with no reuse value elsewhere in the codebase. NOT RECOMMENDED
unless the NF-induction approaches all fail.

### Alternative 4: Quantifier-Free Reduction

**Core idea**: Prove sum_preservation first for quantifier-free formulas
(where no witness selection is needed), then extend to full k-equivalence using
`doets_lemma_1_1`.

**Analysis**: At depth 0 (quantifier-free), the NF for n free variables is
`AtomKind sig n → Bool`. For sentences (n=0), `AtomKind sig 0` is empty, so
the result is vacuous. For n > 0, the order atoms do appear (between the n
free variables), but no quantifier is involved — so there is no "new witness
selection" step. The order atom problem only arises because we EXTEND environments
during the quantifier step.

**Why this doesn't help**: The depth-0 case with n > 0 is NOT the base case of
the induction. The induction in `sum_nf_agree` starts at k=0 and proceeds to
k+1. At each step, the key obligation is the quantifier transfer (finding
witnesses), which is where order atoms cause problems. Proving the depth-0
base case doesn't bypass the inductive step.

Furthermore, `doets_lemma_1_1` gives formula truth from NF agreement, but the
NF agreement itself (at depth k, with n free variables) is what we're trying to
prove. The quantifier-free reduction doesn't break the induction.

**Assessment**: NOT a viable alternative. The order atom problem is intrinsic
to the inductive step, not the base case.

### Alternative 5: Multi-Variable NF Transfer via Component Sub-Environments

**Core idea**: Extract the sub-environment within each component and use
multi-variable NF transfer (not 1-variable) to select witnesses that preserve
order with existing same-component elements.

For component i, let `sub_env_M_i : Fin m_i → (ms i).carrier` be the
restriction of `env_M` to positions with component index i (where m_i is the
count of such positions). When adding a new witness `x` in component i, find
`y` in `(ms' i).carrier` such that the (m_i + 1)-variable NF of
`Fin.cons x sub_env_M_i` in `ms i` equals the (m_i + 1)-variable NF of
`Fin.cons y sub_env_M_i'` in `ms' i`.

This selection ensures `x` and `y` have the SAME order relationships with all
existing same-component environment elements (since the multi-variable NF encodes
all pairwise order atoms between variables in the same component).

**How to find such y**: Use the component (k+1)-equivalence (which is available
from `h_comp` at level k+1). The component k+1-equiv gives the same quantifier
assignment for m_i-variable NFs: `∃ x, nf_eval_nf (ms i) k 1 ... ↔ ∃ y, ...`.
But we need (m_i + 1)-variable transfer, not just 1-variable.

**The missing lemma**: The component k+1-equivalence gives sentence-level (n=0)
NF agreement. To get multi-variable (n > 0) transfer, we need the same "NF
agreement implies formula agreement" bridge — but now at the component level,
not the sum level. This is exactly `nf_agreement_monotone` applied to the
component pair.

**But nf_agreement_monotone requires a SHARED k-NF**: To apply
`nf_agreement_monotone` to `(ms i, sub_env_M_i)` and `(ms' i, sub_env_M_i')`,
we need these two to agree on all depth-k NFs with m_i variables. This is
not directly given by the component k_equiv (which is at n=0).

**Resolution**: This is exactly the same problem recursively — we need multi-
variable NF agreement at the component level, which requires its own induction.
But for COMPONENTS (single structures with their own carrier), multi-variable NF
agreement from sentence-level NF agreement is provable by `nf_agreement_monotone`!

**The critical insight**: `nf_agreement_monotone` already handles this case:
given `k_equiv sig k (ms i) (ms' i)` (sentence-level, n=0 agreement), we can
apply `nf_agreement_monotone` at the COMPONENT level to get NF agreement for any
n with any compatible environments. But the "compatible environments" for
components requires that the COMPONENT environments have matching depth-k NF
characteristics (n-variable) — which is itself the inductive claim at the
component level.

**Assessment**: This alternative is essentially equivalent to Alternative 2
(joint ordered-sum NF equality), specialized to components. It leads to the same
restructuring: the inductive invariant must be a JOINT multi-variable NF
characteristic equality, not per-element 1-variable NF matching.

---

## The Structural Analysis: Why 1-Variable NF Matching Is Insufficient

All the analysis above converges on a single structural diagnosis:

**Root cause**: The current `sum_nf_agree` hypothesis `h_elem` gives 1-variable
NF agreement for each environment position independently:
```lean
h_elem : ∀ j, nf_characteristic (ms ((env_M j).1)) k 1 (fun _ => (env_M j).2) =
              nf_characteristic (ms' ((env_N j).1)) k 1 (fun _ => (env_N j).2)
```

(paraphrased — the actual hypothesis is NF evaluation agreement, equivalent
to characteristic equality via `nf_agreement_from_shared_nf`)

1-variable NFs do NOT encode order relationships between distinct elements.
They only capture predicate profiles and individual quantifier reachability
("from element x, which elements are reachable in 1 step, 2 steps, etc.").

**What IS needed**: A joint (n+1)-variable NF agreement that captures order
relationships between ALL pairs of environment positions. This requires the
hypothesis to be:
```lean
h_joint : nf_characteristic (orderedSum sig I ms) k n env_M =
          nf_characteristic (orderedSum sig I ms') k n env_N
```

This is a STRICTLY STRONGER hypothesis than the current h_atoms + h_elem
combination, and it eliminates all order atom problems at once.

---

## Why `nf_agreement_monotone` Avoids the Problem: The Structural Property

`nf_agreement_monotone` works within a SINGLE pair of structures (M, N) with a
SINGLE shared k-NF for the FULL environment:

```lean
have h_agree_k' := nf_agreement_from_shared_nf M (Fin.cons x env_M)
  N (Fin.cons y env_N) nf_y_k hMx_k hNy_k
```

The structural property exploited: **both new witnesses x and y satisfy the same
NF `nf_y_k` at depth k for the FULL (n+1)-variable environment**. Because `nf_y_k`
is a depth-k NF for ALL n+1 variables together, it encodes:
- All predicate atoms for all n+1 positions (including position 0 = new witness)
- All order atoms between all pairs of positions (including 0 vs 1..n)
- All quantifier assignments for all depth-(k-1) NFs with n+2 variables

The key is that `nf_y_k` is found by calling `nf_exists_unique N k' (n+1)
(Fin.cons y env_N)`, which computes the NF for the JOINT environment (y together
with env_N). The matching `x` is found via `hex_transfer_k nf_y_k`, which finds
x such that `Fin.cons x env_M` also satisfies `nf_y_k`.

In `sum_nf_agree`, we DON'T have this: the element `b` is found by matching the
INDIVIDUAL 1-variable characteristic of `a` in component `i`, NOT by matching
the full ordered-sum (n+1)-variable characteristic. So `a` and `b` agree on
their individual NFs, but the JOINT environment characteristics may differ.

---

## Recommended Approach

**Alternative 2 (restructured) is the recommended approach**: Replace the current
`sum_nf_agree` with a lemma that takes the joint ordered-sum NF equality as its
inductive hypothesis, rather than per-element 1-variable NF agreement.

**Concrete implementation plan**:

**Step 1**: Define the cleaned-up lemma:

```lean
private theorem sum_nf_agree_v2 (sig : MonadicSignature) (k : Nat) :
    ∀ (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ i, k_equiv sig k (ms i) (ms' i))
    (n : Nat)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ j, (env_M j).1 = (env_N j).1)
    -- The key hypothesis: joint ordered-sum NF equality
    (h_char : nf_characteristic (orderedSum sig I ms) k n env_M =
              nf_characteristic (orderedSum sig I ms') k n env_N)
    (nf : NormalForm sig k n),
    nf_eval_nf (orderedSum sig I ms) k n env_M nf ↔
    nf_eval_nf (orderedSum sig I ms') k n env_N nf
```

**Step 2**: The proof of `sum_nf_agree_v2` is immediate:
```lean
intro ... h_char nf
exact nf_agreement_from_shared_nf
  (orderedSum sig I ms) env_M (orderedSum sig I ms') env_N
  (nf_characteristic (orderedSum sig I ms) k n env_M)
  (nf_characteristic_satisfies ...)
  (h_char ▸ nf_characteristic_satisfies ...)
  nf
```

**Step 3**: The real work moves to proving the joint NF equality:

```lean
private theorem sum_char_eq (sig : MonadicSignature) (k : Nat) :
    ∀ (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ i, k_equiv sig k (ms i) (ms' i))
    (n : Nat)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ j, (env_M j).1 = (env_N j).1)
    -- Inductive hypothesis: joint NF equality at lower depth (k-1) for extended envs
    -- (This is the strengthened IH for the induction on k)
    ...,
    nf_characteristic (orderedSum sig I ms) k n env_M =
    nf_characteristic (orderedSum sig I ms') k n env_N
```

**Step 4**: Prove `sum_char_eq` by induction on k:

- **Base case k=0**: The characteristic at depth 0 is `AtomKind sig n → Bool`.
  For n=0: no atoms exist, both are the empty function (equal trivially).
  For n > 0: atoms include order and predicate atoms. Need to show
  `atom_eval (orderedSum ms) env_M a ↔ atom_eval (orderedSum ms') env_N a`
  for all a.
  - Predicate atoms: `(ms (env_M j).1).interp p (env_M j).2 ↔ (ms' (env_N j).1).interp p (env_N j).2`.
    Since `h_idx j` gives same component index and component 0-equiv gives same
    predicate truth values (0-equiv = same depth-0 NF = same atom truth assignments
    for 1-var NFs), this follows from `h_comp (env_M j).1` at depth 0.
  - Order atoms (SAME component: `(env_M j₁).1 = (env_M j₂).1`): Requires
    `(env_M j₁).2 < (env_M j₂).2 ↔ (env_N j₁).2 < (env_N j₂).2` within
    the same component. **This is the fundamental gap** — it is NOT provable
    from component k_equiv alone (which is sentence-level).
  - Order atoms (DIFFERENT component): Follows immediately from `h_idx`.

**Key observation for base case n > 0**: For the INITIAL environments (before any
quantifier extension), same-component order is an ASSUMPTION we must carry into
the induction. This is the missing piece in the current approach.

**Step 5**: For `sum_preservation` (the target, n=0), the initial environment
is `Fin.elim0` (empty). With n=0:
- No order atoms or predicate atoms in `AtomKind sig 0` (all require Fin n ≠ ∅).
- Base case is trivial.
- Inductive step: the only atoms in the extended environments arise from quantifier
  steps. After selecting witnesses `⟨i, x⟩` and `⟨i, y⟩`, the extended env
  has n=1 free variable. With n=1: order atoms are `x < x` type (comparing the
  same variable to itself, but `h_ne` says they're different positions — impossible
  with only 1 variable). So FOR THE FIRST QUANTIFIER STEP (n=0 → n=1), there
  are NO order atoms. The problem only appears at n=2 and beyond.

**Critical realization**: The order atom problem in `sum_nf_agree` occurs for
the SECOND and subsequent quantifier steps (when there are already existing
environment elements). The FIRST quantifier step (extending from empty to 1
variable) has no order atoms because `AtomKind sig 1` has no order atoms
(order atoms require `i ≠ j` with `i, j : Fin 1`, impossible).

**This suggests a simpler fix**: The current `sum_nf_agree` lemma attempts to
handle all n simultaneously. But if we observe that:
1. `sum_preservation` is called with n=0 (empty environment)
2. The first quantifier step goes from n=0 to n=1 (no order atoms)
3. The second quantifier step goes from n=1 to n=2 (first order atoms appear)

At n=2, the two environment positions have indices `(env_M 0).1` and `(env_M 1).1`.
If they're in DIFFERENT components, order is determined by index comparison (equal
in both sums). If in the SAME component, the same-component order is needed.

**For same-component case at n=2**: The pair of witnesses `(a₀, a₁)` in `ms i`
and `(b₀, b₁)` in `ms' i` must have the same pairwise order. The component
k-equivalence gives JOINT 2-variable NF agreement for ANY environments with
matching 2-variable NFs — but the witnesses were selected by 1-variable NF
matching (independently), not jointly.

**The fix**: When selecting the second witness in the same component, use the
2-variable component characteristic (including order between the pair) to guide
witness selection, not just the 1-variable individual characteristic.

---

## Concrete Resolution: Revised Witness Selection Procedure

The 1-variable witness selection procedure in the current proof:
```
char_a := nf_characteristic (ms i) k 1 (fun _ => a)
b such that nf_eval_nf (ms' i) k 1 (fun _ => b) char_a
```

This only ensures `a` and `b` have the same 1-variable component NF. When
environment has existing elements in component i (positions env_M j₁, env_M j₂,
...), we need a MULTI-variable witness selection:

**Revised selection (for component i)**: Let `S_i = {j | (env_M j).1 = i}` be
the set of existing environment positions in component i, with elements
`a_j₁, a_j₂, ...` (from `ms i`) and `b_j₁, b_j₂, ...` (from `ms' i`). When
adding a new element `a` in component i, find `b` such that the
`(|S_i|+1)`-variable NF of `(a, a_j₁, a_j₂, ...)` in `ms i` equals the
`(|S_i|+1)`-variable NF of `(b, b_j₁, b_j₂, ...)` in `ms' i`.

This revised selection preserves:
- Predicate truth for `a` vs `b` (captured in the multi-var NF)
- Order between `a` and existing same-component elements (captured in order atoms
  of the multi-var NF)
- Quantifier reachability from `a` relative to the component group (captured in
  quantifier assignment of the multi-var NF)

**Why this is feasible**: The component k-equivalence `h_comp i : k_equiv sig k
(ms i) (ms' i)` gives sentence-level NF agreement. By `nf_agreement_monotone`
applied to the COMPONENT pair (ms i, ms' i), we get NF agreement for ANY number
of free variables with matching depth-k characteristics. In particular: if the
existing same-component elements in the two sums have matching multi-variable NFs
(inductive hypothesis for the component pair), then the component pair also
matches at depth k for any additional query.

**However**: The component elements' multi-variable NF matching is an INDUCTIVE
HYPOTHESIS that must be maintained across quantifier steps. This requires
reformulating `sum_nf_agree` with the `h_joint` hypothesis (as in Alternative 1).

---

## Confidence Assessment

**High Confidence**:
- The order atom sorry cannot be closed with the current `sum_nf_agree`
  formulation. This is a structural gap, not a missing tactic.
- `nf_agreement_monotone` avoids the problem by using joint ordered-sum-level NF
  equality as its invariant (via `nf_agreement_from_shared_nf`).
- The fix requires either: (a) replacing per-element h_elem with joint h_char as
  the inductive hypothesis (Alternative 2 / "sum_char_eq" approach), or (b)
  using multi-variable component NF matching for witness selection (revised
  witness selection procedure).
- EF games (Alternative 3) would work but cost 450-600 lines of new
  infrastructure with no other use case.
- Quantifier-free reduction (Alternative 4) does not address the problem.

**Moderate Confidence**:
- Alternative 2 (joint ordered-sum NF equality as inductive hypothesis) is
  implementable in 100-200 additional lines beyond the current approach.
- The "revised witness selection" approach (tracking component sub-environments)
  is more complex but achieves the same goal through a different mechanism.
- Both approaches converge on the same mathematical content: the inductive
  invariant must include ORDER RELATIONSHIPS between same-component environment
  elements, not just individual element NF profiles.

**Lower Confidence**:
- Exact line count for Alternative 2 implementation. The `nf_characteristic`
  equality approach may interact unexpectedly with how `orderedSum` unfolds its
  lexicographic order in practice. Lean's definitional equality checker may
  need hints for the `Sigma.Lex.linearOrder` instance.

---

## Recommended Approach

**Recommendation**: Restructure `sum_nf_agree` using the joint ordered-sum NF
characteristic equality as the inductive invariant (Alternative 2). This approach:

1. **Eliminates all 4 order atom sorries simultaneously** by replacing them with
   a single hypothesis `h_char` from which `nf_agreement_from_shared_nf` resolves
   everything.

2. **Moves the proof obligation** from "close the order atom sorries" to "prove
   joint NF equality propagates through quantifier steps." The latter is a
   well-posed induction with clear structure.

3. **For the sentence-level case (n=0)**, the base case of joint NF equality is:
   - k=0, n=0: trivial (no atoms exist)
   - Inductive step (k→k+1, n=0): the quantifier part decomposes by component
     index. For each component i, the witnesses `⟨i, a⟩` and `⟨i, b⟩` satisfy
     sub_nf in the respective sums IFF the component allows it. With only 1
     environment position after extension (from n=0 to n=1), there are NO order
     atoms (AtomKind sig 1 has no order atoms). So the joint NF equality for
     the extended 1-variable environment reduces to predicate atom agreement
     and quantifier assignment agreement — both of which follow from the
     component k-equivalence and the 1-variable witness selection (which is
     CORRECT for 1 variable because there are no order atoms to worry about).

4. **For deeper quantifier steps (n=2, 3, ...)**: the inductive hypothesis at
   depth k-1 for the n-variable environment (with h_char at depth k-1) gives
   the needed agreement. The new witnesses can then be selected using the
   component k-equivalence applied at the (n+1)-variable extended environment
   level — which requires the joint NF equality at depth k for the n-variable
   base environment.

**The proof IS feasible** because:
- At n=0 → n=1: no order atoms, 1-variable witness selection works perfectly.
- At n=1 → n=2: first order atom appears. But the inductive hypothesis at depth
  k for n=1 gives joint NF equality for the 1-variable environment. Using this,
  the 2-variable extended environment's joint NF can be computed component-wise
  (cross-component order is index-determined; same-component order is within-
  component which is given by the component's nf_agreement_monotone at n=2).
- The same pattern continues for n → n+1: the joint NF equality at depth k for
  n variables enables computing joint NF equality at depth k-1 for n+1 variables,
  which is what the IH provides at the next step.

**Estimated implementation complexity**: 150-250 additional lines to replace the
current `sum_nf_agree` with `sum_char_eq` (proving joint NF equality) plus
`sum_nf_agree_v2` (trivial application of `nf_agreement_from_shared_nf`).

---

## Evidence and Examples

**Example showing 1-variable NF matching is insufficient (order atoms)**:

Consider signature with no predicates (p = 0), k = 1, I = {0, 1} (two components).
Let ms 0 = ms' 0 = (Z, <) (the integers). Let ms 1 = ms' 1 = (Z, <).
These are trivially 1-equivalent (identical structures).

Now suppose env_M = [⟨0, 0⟩, ⟨0, 5⟩] (positions 0, 1 both in component 0,
with elements 0 and 5 from Z). The current proof would:
- Find b₀ such that nf_char (ms 0) k 1 (fun _ => 0) = nf_char (ms' 0) k 1 (fun _ => b₀).
  Since all integers have the same 1-var NF at depth 1 in (Z, <) with no predicates,
  b₀ = 100 would work (same NF as 0).
- Find b₁ such that nf_char (ms 0) k 1 (fun _ => 5) = nf_char (ms' 0) k 1 (fun _ => b₁).
  Again, b₁ = 200 would work.

Now env_N = [⟨0, 100⟩, ⟨0, 200⟩]. The order atom `.order 0 1 h_ne` asks:
env_M 0 < env_M 1 ↔ env_N 0 < env_N 1
⟨0, 0⟩ < ⟨0, 5⟩ ↔ ⟨0, 100⟩ < ⟨0, 200⟩
true ↔ true — coincidentally OK!

But if b₀ = 100 and b₁ = 50 (still valid by 1-var NF matching), we'd have:
⟨0, 0⟩ < ⟨0, 5⟩ ↔ ⟨0, 100⟩ < ⟨0, 50⟩
true ↔ false — FALSE!

This confirms 1-variable NF matching is insufficient. With the joint 2-variable
NF equality hypothesis, we'd require nf_char (ms 0) k 2 [0, 5] = nf_char (ms' 0)
k 2 [100, 50], which forces b₀ and b₁ to have the SAME relative order as 0 and
5 — so b₀ < b₁ would be required, ruling out b₁ = 50.
