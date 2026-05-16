# Teammate A Findings: Primary Approach for Order Atom Transfer

**Task**: 154 — sum_preservation order atom blocker
**Date**: 2026-05-15
**Role**: Teammate A — Primary approach (correct mathematical solution)

---

## Key Findings

### 1. Exact Diagnosis: Why the 4 Sorries Cannot Be Closed As-Is

The 4 sorry sites (NEquivalence.lean:264, 334, 400, 459) all occur in the
`| order j₁ j₂ h_ne =>` case within the atom agreement obligation for extended
environments. After case-splitting on `j₁` and `j₂` with `Fin.cases`:

- **Both succ j₁', succ j₂'**: Handled by `h_atoms (.order j₁' j₂' _)`. CLOSABLE.
- **j₁ = 0, j₂ = succ j'**: Requires `⟨i, a⟩ < env_M j' ↔ ⟨i, b⟩ < env_N j'` in Sigma.Lex.
  - Cross-component (i ≠ (env_M j').1): Determined by index comparison alone. Since
    `h_idx j' : (env_M j').1 = (env_N j').1`, this reduces to `i < (env_M j').1 ↔ i < (env_N j').1`,
    which is trivial by rewriting with h_idx. CLOSABLE.
  - Same-component (i = (env_M j').1 = (env_N j').1): Requires
    `a < (env_M j').2 ↔ b < (env_N j').2` within the component ms(i) vs ms'(i). **BLOCKED.**
- **j₁ = succ j', j₂ = 0**: Symmetric to above. **BLOCKED** for the same-component subcase.

So each sorry contains exactly ONE genuinely stuck subcase: same-component order comparison
between the NEW witness (a or b) and an EXISTING environment element.

### 2. Why 1-Variable NF Transfer Is Structurally Insufficient

The current proof selects witness b by: `char_a = nf_characteristic (ms i) k 1 (fun _ => a)`,
then finds b satisfying char_a in ms'(i). This gives: a and b share the same depth-k 1-variable
NF in their respective components.

The fundamental gap: `AtomKind sig 1` contains NO order atoms. The definition at
NormalForm.lean:60 is `order (i j : Fin n) (h : i ≠ j)`. With n=1, Fin 1 = {0} has only one
element, so no distinct pairs (i, j) with i ≠ j exist. Therefore NormalForm sig k 1 encodes
ONLY unary predicate truth values — zero information about the position of an element in the
linear order relative to any other element.

**Concrete counterexample** (adapted from Teammate B and C): Let sig have no predicates,
I = {0} (one component), ms 0 = ms' 0 = (Z, <). Take env_M with (env_M j).2 = 5. The
1-variable NF at any depth k for all integers in Z with no predicates is the same (the empty
truth assignment). So b = 100 satisfies char_a = char_{a=3}. But `3 < 5` while `100 > 5`,
so the order atom fails. The correct choice requires b < 5, information absent from the
1-variable NF.

### 3. How nf_agreement_monotone Avoids This Problem

`nf_agreement_monotone` (NormalForm.lean:339-421) handles the analogous problem for a SINGLE
pair of structures M and N. Its quantifier step at lines 405-420:

```lean
obtain ⟨nf_y_k, hNy_k, _⟩ := nf_exists_unique N k' (n+1) (Fin.cons y env_N)
obtain ⟨x, hMx_k⟩ := (hex_transfer_k nf_y_k).mpr ⟨y, hNy_k⟩
have h_agree_k' := nf_agreement_from_shared_nf M (Fin.cons x env_M)
  N (Fin.cons y env_N) nf_y_k hMx_k hNy_k
```

The key: `nf_y_k` is a depth-k NF for the FULL (n+1)-variable EXTENDED environment
`Fin.cons y env_N`. Both Fin.cons x env_M and Fin.cons y env_N satisfy the SAME NF
nf_y_k. This NF encodes ALL atoms over (n+1) variables, including order atoms between
position 0 (the new witness) and positions 1..n (the old environment elements).
`nf_agreement_from_shared_nf` then gives full atom agreement for free.

In the ordered sum case, the witness b is selected by INDIVIDUAL 1-variable component NF
(not the JOINT ordered-sum (n+1)-variable NF for the full extended environment). So the
joint NF of the extended environments may differ, even though each element individually
has a matching 1-variable NF.

### 4. The Correct Proof Structure: Joint NF Invariant

The mathematically correct fix is to restructure `sum_nf_agree` so the inductive invariant
is the JOINT ordered-sum NF equality for the FULL environment, not per-element 1-variable NFs.

The correct helper lemma to prove (replacing the current sum_nf_agree):

```lean
-- Step 1: trivial consequence of nf_agreement_from_shared_nf
private theorem sum_nf_agree_v2 (sig : MonadicSignature) (k : Nat) :
    ∀ (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (n : Nat)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    -- THE KEY HYPOTHESIS: joint ordered-sum NF equality
    (h_char : nf_characteristic (orderedSum sig I ms) k n env_M =
              nf_characteristic (orderedSum sig I ms') k n env_N)
    (nf : NormalForm sig k n),
    nf_eval_nf (orderedSum sig I ms) k n env_M nf ↔
    nf_eval_nf (orderedSum sig I ms') k n env_N nf

-- Proof of sum_nf_agree_v2: immediate from nf_agreement_from_shared_nf
-- (nf_characteristic_satisfies gives both sides satisfy their resp. char NF,
--  h_char identifies them, nf_agreement_from_shared_nf concludes)

-- Step 2: the substantive work
private theorem sum_char_eq (sig : MonadicSignature) (k : Nat) :
    ∀ (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ m, m ≤ k → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (n : Nat)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ j, (env_M j).1 = (env_N j).1)
    -- INDUCTIVE HYPOTHESIS: joint NF equality holds at depth k for CURRENT env
    -- (this is what gets established for n=0 base case and propagated)
    (h_char_base : nf_characteristic (orderedSum sig I ms) k n env_M =
                   nf_characteristic (orderedSum sig I ms') k n env_N),
    -- CONCLUSION: joint NF equality holds at depth k-1 for extended env
    -- (needed for quantifier transfer at depth k+1)
    ...
```

### 5. Why the Joint NF Equality Propagates Through Quantifier Steps

The joint NF equality `h_char : nf_characteristic (orderedSum ms) k n env_M = nf_characteristic (orderedSum ms') k n env_N` decomposes as:

- **Atom part**: `atom_assgn` of both chars are equal. This is because h_char implies agreement on all atoms via `nf_agreement_from_shared_nf` → `atom_agreement_from_nf`. This includes the same-component order atoms for OLD env elements.

- **Quantifier part**: `quant_assgn` of both chars are equal. This means: for each depth-(k-1) sub-NF φ with n+1 free variables, `(∃ x in orderedSum ms, nf_eval_nf ... (Fin.cons x env_M) φ) ↔ (∃ y in orderedSum ms', nf_eval_nf ... (Fin.cons y env_N) φ)`.

For the quantifier transfer at depth k+1 (going from depth k NF equality to depth k-1 NF equality for extended environments):
- Given witness x = ⟨i, a⟩ in orderedSum ms satisfying φ at depth k-1
- Need to find y = ⟨i, b⟩ in orderedSum ms' satisfying the SAME φ at depth k-1
- The component k-equivalence gives: ms(i) ≡_k ms'(i)
- The 1-variable component NF transfer finds b with the same 1-var depth-k NF as a
- BUT: the EXTENDED ENVIRONMENTS `Fin.cons ⟨i,a⟩ env_M` and `Fin.cons ⟨i,b⟩ env_N`
  must have matching joint (n+1)-variable NFs at depth k-1

This is where the argument becomes recursive but non-circular: we need the depth-(k-1)
joint NF equality for the extended environments, which follows from IH at depth k-1
applied to the extended environments.

The key: at depth k-1 for n+1 variables, we need the IH to state that the joint NF
equality holds for COMPATIBLE EXTENDED environments. The compatibility condition for the
extended environment (after adding ⟨i,a⟩ and ⟨i,b⟩) is:
1. `h_idx` for the extended env: holds since new elements have same index i
2. joint NF equality at depth k-1 for the extended env: THIS IS WHAT WE'RE PROVING

The resolution: the induction must be structured differently. Rather than taking h_char as
an INPUT hypothesis, the correct approach is an induction that PROVES h_char.

### 6. The Correct Induction Structure

Following the pattern of `nf_agreement_monotone` exactly, the correct induction is:

**Theorem `sum_char_agree`**: By induction on k, for all I, ms, ms', n, env_M, env_N:
IF (a) h_comp holds (component k-equivalence) AND (b) h_idx holds (same component indices)
THEN `nf_characteristic (orderedSum ms) k n env_M = nf_characteristic (orderedSum ms') k n env_N`

The proof by induction on k:

**Base case k=0**: The char at depth 0 with n variables is `fun a => decide (atom_eval (orderedSum ms) env_M a)`. For the two chars to be equal, we need for each atom a: `atom_eval (orderedSum ms) env_M a ↔ atom_eval (orderedSum ms') env_N a`.

- Predicate atoms (pred p j): `(ms (env_M j).1).interp p (env_M j).2 ↔ (ms' (env_N j).1).interp p (env_N j).2`. Since (env_M j).1 = (env_N j).1 by h_idx, and the 0-variable k-equiv of ms(i) and ms'(i) gives 0-NF agreement, which includes predicate values for elements (via the 1-var quantifier in the 0-NF). Wait: the 0-variable NF agreement does NOT directly give predicate values for specific elements.

**CRITICAL ISSUE WITH BASE CASE**: Even at k=0, for n>0, the base case requires predicate and order atom agreement for OLD environment elements, which requires:
- Predicate: `(ms (env_M j).1).interp p (env_M j).2 ↔ (ms' (env_N j).1).interp p (env_N j).2`
- Order (same-component): `(env_M j₁).2 < (env_M j₂).2 ↔ (env_N j₁).2 < (env_N j₂).2` in ms(i) vs ms'(i)

These cannot be derived from the 0-variable k-equiv alone (which is a sentence about the WHOLE structure, not about specific elements).

**The resolution for sum_preservation (n=0 starting point)**: The sentence-level result (n=0) starts with the EMPTY environment. At n=0, there are no atoms in AtomKind sig 0 (no Fin 0 elements to plug in). So the base case for n=0 is trivially true. The quantifier steps extend from n=0 to n=1, then n=1 to n=2, etc.

At n=0→1: The new witness ⟨i,a⟩ extends the empty environment. With n=1 free variable, AtomKind sig 1 has only predicate atoms (no order atoms since Fin 1 has only one element). So the atom agreement for extended n=1 environments only requires predicate agreement, which IS derivable from the 1-variable component NF (which encodes exactly predicate truth values).

At n=1→2: The new witness adds a SECOND free variable. Now AtomKind sig 2 has order atoms between positions 0 and 1. For same-component pairs, this requires cross-element order agreement — the first time the sorry is actually blocking.

**Key observation**: The quantifier steps in `sum_nf_agree` go n → n+1 at each recursive call. The sorry cases occur at n=1→2 and beyond. For the n=0→1 case (first quantifier step in `sum_preservation` called with n=0), there are NO order atoms. The sorry cases are for the SECOND and subsequent quantifier steps.

### 7. The Correct Invariant for the Joint NF Approach

For the joint NF approach to work, the induction hypothesis must be stated as:

"For environments (env_M, env_N) where the joint ordered-sum NF at depth k is ALREADY EQUAL (this is an INPUT hypothesis, not what we're proving), the joint ordered-sum NF at depth k-1 for any EXTENDED environment (where the new witness is selected by JOINT NF matching in the ordered sum at depth k) is also equal."

But we need to establish the joint NF equality for the BASE ENVIRONMENT first (n=0, k=0 to k=target). This is a separate lemma:

**Sentence-level lemma** (n=0): By induction on k, component k-equivalence implies the ordered sums have equal k-type (0-variable NF equality). This is exactly `sum_preservation`, but proved by direct induction on k using 1-variable component NF transfer (which works because n=0→n=1 has no order atoms).

**Multi-variable extension** (n>0): Given the n=0 result, extend to n>0 environments using the same technique as `nf_agreement_monotone` but applied to the ordered sums.

The cleanest approach separates these two parts:

```
STEP A: sum_preservation_sentence (k : Nat):
  ∀ I, ms, ms', (∀ i, k_equiv sig k (ms i) (ms' i)) →
  k_equiv sig k (orderedSum sig I ms) (orderedSum sig I ms')

  Proof by induction on k using 1-variable component NF transfer.
  This works because: only n=0→n=1 is needed, and n=1 has no order atoms.

STEP B: Apply nf_agreement_monotone to the ordered sums.
  Given STEP A: the ordered sums are k-equivalent as 0-variable NFs.
  sum_preservation IS this step.
```

Wait: STEP A is exactly `sum_preservation` itself. So this is circular if the proof method requires STEP A as an input.

### 8. The Non-Circular Proof (Induction on k Only)

The non-circular proof must establish, by induction on k:

```
P(k): For all I, ms, ms', n, env_M, env_N,
  (h_comp: ∀ m ≤ k, ∀ i, 0-var m-NF agreement for ms(i) vs ms'(i))
  (h_idx: ∀ j, (env_M j).1 = (env_N j).1)
  (h_atoms: ∀ a : AtomKind sig n, atom_eval (orderedSum ms) env_M a ↔ atom_eval (orderedSum ms') env_N a)
  →
  ∀ nf : NormalForm sig k n,
  nf_eval_nf (orderedSum ms) k n env_M nf ↔ nf_eval_nf (orderedSum ms') k n env_N nf
```

Notice: **h_atoms is included as an INPUT hypothesis**. This is the KEY CHANGE.

With h_atoms as input, the atom agreement case (including order atoms) is given, not proved.
The inductive step only needs to handle the QUANTIFIER transfer.

For the quantifier transfer: given ⟨i, a⟩ in orderedSum ms satisfying sub_nf (depth k-1, n+1 vars),
find ⟨i, b⟩ in orderedSum ms' satisfying sub_nf. Then apply IH at depth k-1 with the extended
environments to get full NF agreement.

The IH at k-1 requires:
1. h_comp at depth k-1 (available from h_comp since m ≤ k-1 ≤ k)
2. h_idx for extended environment (provable: new element has same index i)
3. **h_atoms for the EXTENDED environment** (includes order atoms for the new witness vs old elements)

This brings us back to the same problem: h_atoms for the extended environment requires
same-component order agreement for the new witness vs old elements.

### 9. Resolution: The Correct Witness Selection

The correct witness selection must ensure h_atoms holds for the EXTENDED environment. To achieve this,
witness b must be chosen such that `b < (env_N j).2 ↔ a < (env_M j).2` for all same-component j.

This requires: find b in ms'(i) such that:
- b has the same predicate values as a (given by 1-var NF transfer — already done)
- For each existing same-component env element (env_M j).2 with (env_M j).1 = i:
  `b < (env_N j).2 ↔ a < (env_M j).2` in their respective components

The existence of such b is guaranteed if ms(i) ≡_{k+1} ms'(i) at the MULTI-VARIABLE level:
specifically, the (s+1)-variable NF agreement where s = number of existing env elements in
component i. This multi-variable NF agreement captures the order relationships.

**Why component k-equivalence gives multi-variable transfer**: The 0-variable k-equivalence
of ms(i) and ms'(i) implies (by `nf_agreement_monotone` applied to the COMPONENT structures)
that any two environments with matching joint k-variable NFs in ms(i) and ms'(i) agree on all
k-variable NF sentences. In particular: for any joint environment `(env_{M,i})` in ms(i)
and `(env_{N,i})` in ms'(i) with matching s-variable NFs, the quantifier transfer at depth k
works in all s+1 variables simultaneously.

But we need: given the existing same-component elements have matching joint NFs (inductive hypothesis),
FIND b such that the EXTENDED same-component environment has matching joint NFs. This uses the
(k+1)-variable component NF transfer.

### 10. The Correct Implementation: What to Prove

The proof of `sum_nf_agree` requires the following KEY LEMMA about component-level environments:

```lean
-- Given: ms(i) ≡_{k+1} ms'(i) (component k+1-equivalence)
-- Given: existing elements (env_M j).2 and (env_N j).2 for same-component j have matching
--        joint s-variable depth-k NFs in ms(i) and ms'(i) respectively
-- Given: new element a in ms(i)
-- Conclude: there exists b in ms'(i) such that the extended (s+1)-variable joint NF matches

lemma component_extend_joint_nf
    {sig : MonadicSignature} {i : I}
    (k : Nat) (s : Nat)
    (ms_i : OrderedMonadicStructure sig)
    (ms'_i : OrderedMonadicStructure sig)
    (h_equiv : k_equiv sig (k+1) ms_i ms'_i)
    (env_i : Fin s → ms_i.carrier)
    (env_i' : Fin s → ms'_i.carrier)
    (h_char : nf_characteristic ms_i k s env_i = nf_characteristic ms'_i k s env_i')
    (a : ms_i.carrier) :
    ∃ (b : ms'_i.carrier),
      nf_characteristic ms_i k (s+1) (Fin.cons a env_i) =
      nf_characteristic ms'_i k (s+1) (Fin.cons b env_i')
```

This lemma is derivable using:
1. `nf_agreement_from_shared_nf` on the components (using h_char to get full s-var NF agreement)
2. Component k+1-equivalence's quantifier part: ∃ b satisfying sub-NF of the (k+1)-NF
3. `nf_agreement_monotone` on the components: the extended (s+1)-var depth-k NF chars match

Actually, this is exactly the pattern of `nf_agreement_monotone` applied to the component pair
(ms_i, ms'_i) with the s-variable induction! The `nf_agreement_monotone` theorem already proves:
from depth-k NF agreement for `env_i` in ms_i and `env_i'` in ms'_i (given by h_char via
`nf_agreement_from_shared_nf`), it derives depth-(k-1) NF agreement for any EXTENDED environment
by using the depth-k quantifier transfer.

Wait: `nf_agreement_monotone` takes h_agree_k as AGREEMENT ON ALL DEPTH-k n-VARIABLE NFs.
Given h_char (the specific characteristic NF is equal), h_agree_k follows from
`nf_agreement_from_shared_nf`. Then `nf_agreement_monotone` (applied with m = k-1) gives:
for any extended environment `Fin.cons x env_i`, there exists `y` in ms'_i such that
`nf_eval_nf ms_i (k-1) (s+1) (Fin.cons x env_i) sub_nf ↔ nf_eval_nf ms'_i (k-1) (s+1) (Fin.cons y env_i') sub_nf`.

BUT: we need MORE than just the sub_nf transfer — we need the ENTIRE (s+1)-variable NF
characteristic to match. `nf_agreement_monotone` gives this via its induction structure: the
witnesses x and y satisfy the SAME depth-(k-1) (s+1)-variable NF.

---

## Recommended Approach

**The correct proof requires strengthening `sum_nf_agree` to maintain a COMPONENT-LEVEL JOINT NF INVARIANT** across the inductive calls.

The revised `sum_nf_agree` should carry:

```
OLD h_elem (insufficient):
  ∀ (m : Nat) (hm : m ≤ k) (j : Fin n) (nf_j : NormalForm sig m 1),
    nf_eval_nf (ms ((env_M j).1)) m 1 (fun _ => (env_M j).2) nf_j ↔
    nf_eval_nf (ms' ((env_N j).1)) m 1 (fun _ => (env_N j).2) nf_j

NEW h_joint (sufficient):
  ∀ (i : I),
    let js_i := {j : Fin n | (env_M j).1 = i}  -- same-component positions
    let s_i := Fintype.card js_i
    ∀ (env_Mi : Fin s_i → (ms i).carrier)
    (env_Ni : Fin s_i → (ms' i).carrier)
    -- restriction of env_M to component i ↔ env_Mi
    -- restriction of env_N to component i ↔ env_Ni
    (h_restrict_M : ...)
    (h_restrict_N : ...),
    nf_characteristic (ms i) k s_i env_Mi =
    nf_characteristic (ms' i) k s_i env_Ni
```

This invariant captures: for each component i, the JOINT NF characteristic of all existing
environment elements in component i is equal across the two sides. This is stronger than
per-element 1-variable NF agreement and encodes order relationships between same-component elements.

**The witness selection using this invariant**:

When adding new witness ⟨i, a⟩ in component i:
1. Extract the existing same-component sub-environment: env_Mi : Fin s_i → (ms i).carrier
2. Use `nf_agreement_from_shared_nf` on components (from h_joint for index i) to get full
   s_i-variable NF agreement for ms(i) vs ms'(i) at depth k
3. Use the depth-(k+1) component quantifier: find b in ms'(i) such that Fin.cons b env_Ni
   satisfies the same depth-k (s_i+1)-variable NF as Fin.cons a env_Mi in ms(i)
4. With matching (s_i+1)-variable joint NFs, `nf_agreement_from_shared_nf` gives order atom
   agreement between b and all same-component elements: `b < (env_Ni j).2 ↔ a < (env_Mi j).2`

Step 3 uses: `nf_agreement_monotone` (NormalForm.lean:339-421) applied to the COMPONENT PAIR
(ms i, ms' i), using the depth-k s_i-variable NF agreement (from step 2) to transfer the
depth-k quantifier for the (s_i+1)-variable extended environment.

**Why this is the same pattern as `nf_agreement_monotone`**: `nf_agreement_monotone` proves
monotonicity of NF agreement for a pair (M, N) where M and N are both `OrderedMonadicStructure sig`
with their own carriers. Here, (ms i, ms' i) plays the role of (M, N), and the component-level
s_i-variable environment plays the role of `env`. The theorem applies directly because ms(i) and
ms'(i) are `OrderedMonadicStructure sig`.

### Concrete Implementation Strategy

**Phase 3 (revised)**: Rewrite `sum_nf_agree` with the following invariant change:

Replace `h_elem` (1-variable per-element agreement) with `h_joint` (joint NF agreement per
component). The key steps:

1. **Define `component_env` helper**: Given `env_M : Fin n → (orderedSum sig I ms).carrier` and
   index `i : I`, extract the sub-environment `env_Mi : Fin (count_component env_M i) → (ms i).carrier`
   consisting of all env positions in component i, in order.

2. **State `sum_nf_agree_v3`** with h_joint replacing h_elem:
   ```lean
   private noncomputable def sum_nf_agree_v3 ... (h_joint : ∀ (i : I), nf_characteristic (ms i) k (count_component env_M i) (component_env env_M i) = nf_characteristic (ms' i) k (count_component env_N i) (component_env env_N i)) ...
   ```

3. **Handle the order atom sorry in the quantifier step** using `nf_agreement_monotone` on
   the component pair. After finding b via the (s+1)-variable joint NF transfer:
   - `nf_agreement_from_shared_nf` on components gives order atom agreement
   - This closes `b < (env_Ni j).2 ↔ a < (env_Mi j).2`

4. **Establish h_atoms from h_joint**: atom agreement (h_atoms) for the CURRENT environment
   follows from h_joint + cross-component index comparison. This replaces the need to carry
   h_atoms as a separate hypothesis.

5. **Establish h_joint for the EXTENDED environment**: after adding ⟨i, a⟩ / ⟨i, b⟩,
   the new h_joint at depth k-1 for the extended environment (component i now has s_i+1 elements)
   follows from the matching (s_i+1)-variable joint NF found in step 3.

**Estimated additional lines**: 100-150 lines for the restructured proof.

---

## Evidence / Examples

### Why the restructured invariant works for the base case of sum_preservation

`sum_preservation` calls `sum_nf_agree_v3` with n=0, env_M = env_N = Fin.elim0. At n=0:
- No same-component elements exist (s_i = 0 for all i)
- h_joint: `nf_characteristic (ms i) k 0 Fin.elim0 = nf_characteristic (ms' i) k 0 Fin.elim0`
- This is equivalent to: `k_type_of sig k (ms i) = k_type_of sig k (ms' i)`, i.e., the component
  k-equivalence hypothesis h_comp
- So h_joint for n=0 IS h_comp (the given hypothesis). Base case h_joint is trivially established.

### The first quantifier step (n=0→1) with the new invariant

After adding new witness ⟨i, a⟩ / ⟨i, b⟩ (first env element, both in component i):
- s_i goes from 0 to 1
- Need: `nf_characteristic (ms i) k 1 (fun _ => a) = nf_characteristic (ms' i) k 1 (fun _ => b)`
- This is exactly the 1-variable component NF equality between a and b
- Since a and b are found by matching their 1-variable depth-k NF (char_a), this holds
- Note: at n=1, AtomKind sig 1 has NO order atoms, so the chars agree on all atoms
- The new h_joint for extended env (n=1) holds. No order atoms needed.

### The second quantifier step (n=1→2) with the new invariant

After adding second witness ⟨j, c⟩ / ⟨j, d⟩:
- If i ≠ j: c and d are in a DIFFERENT component from the first pair. h_joint for component j
  goes from 0 to 1 variable (same as first step: 1-var NF matching suffices). No order atoms.
  h_joint for component i stays at 1 variable (unchanged). Order atom between env_M(0) and
  env_M(1) is cross-component: determined by index comparison → OK.
- If i = j: c and d are in the SAME component as the first pair.
  - h_joint for component i goes from 1 to 2 variables.
  - Need: `nf_characteristic (ms i) k 2 (fun v => if v = 0 then c else a) = nf_char (ms' i) k 2 (fun v => if v = 0 then d else b)`
  - The existing h_joint gives `nf_char (ms i) k 1 (fun _ => a) = nf_char (ms' i) k 1 (fun _ => b)`
  - From this, `nf_agreement_from_shared_nf` on components at depth k with 1 variable
  - Apply `nf_agreement_monotone` on components at depth k+1 (from component k+1-equiv) to extend
    from 1-variable to 2-variable: find d such that `nf_char (ms i) k 2 [c, a] = nf_char (ms' i) k 2 [d, b]`
  - The 2-variable NF includes the order atom `c < a` and `a < c` — these are encoded in the NF
    and matched by the 2-variable NF equality, giving `c < a ↔ d < b`. **ORDER ATOM CLOSED.**

---

## Confidence Level

**High confidence**:
- The 4 sorry cases are not closable with the current `sum_nf_agree` formulation. This is
  structurally provable: `AtomKind sig 1` has no order atoms, so 1-variable NF transfer
  encodes zero order information.
- The joint NF invariant approach is mathematically correct. It mirrors `nf_agreement_monotone`
  exactly, applied to component pairs instead of arbitrary structure pairs.
- The `nf_agreement_monotone` and `nf_agreement_from_shared_nf` theorems in NormalForm.lean
  are exactly the tools needed to implement the correct witness selection.
- The base case (n=0, h_joint = h_comp) is trivially established.
- The first quantifier step (n=0→1) requires no order atoms and is handled by 1-variable NF
  matching (which is already implemented correctly).

**Moderate confidence**:
- The formalization of `component_env` (extracting the sub-environment per component) requires
  handling an indexing structure. In Lean 4, this can be done via `Fin.filter` or by defining
  a mapping from component positions to global positions. The exact Lean syntax may require
  some experimentation, but the mathematics is clear.
- The `count_component` helper (counting how many env positions are in each component) is a
  Finset cardinality computation; with finite n, this is computable.
- The connection between the global extended environment and the component-level extended
  environment requires careful bookkeeping of index bijections.

**Lower confidence**:
- The exact number of lines required. The component sub-environment machinery may add 50-80
  lines of infrastructure beyond the core proof logic. Total estimate: 150-250 lines.
- Whether `nf_agreement_monotone` can be applied to components WITHOUT restructuring its
  signature. Currently it takes `(M : OrderedMonadicStructure sig) (env_M : Fin n → M.carrier)`
  — this matches component structures directly, so there should be no issue.

**Overall**: The mathematical path to closing all 4 sorries is clear and uses existing
infrastructure. This is a proof-engineering challenge, not a mathematical obstacle. The
implementation requires restructuring `sum_nf_agree` with the joint NF invariant, but the
restructured proof follows a well-established pattern (nf_agreement_monotone) applied to
components.

---

## Recommended Next Steps for the Implementation Agent

1. **Define `component_env` and `count_component` helpers** in NEquivalence.lean:
   ```lean
   -- Count how many env positions land in component i
   def count_component {I : Type} [DecidableEq I] {ms : I → OrderedMonadicStructure sig}
       {n : Nat} (env_M : Fin n → (orderedSum sig I ms).carrier) (i : I) : Nat :=
     (Finset.univ.filter (fun j => (env_M j).1 = i)).card

   -- Extract the sub-environment for component i
   noncomputable def component_env {I : Type} [DecidableEq I] {ms : I → OrderedMonadicStructure sig}
       {n : Nat} (env_M : Fin n → (orderedSum sig I ms).carrier) (i : I) :
       Fin (count_component env_M i) → (ms i).carrier := ...
   ```

2. **Restate `sum_nf_agree`** with `h_joint` replacing `h_elem`, and with `h_atoms` derived
   from h_joint rather than being a separate hypothesis:
   - h_atoms follows from h_joint via `atom_agreement_from_nf` applied to components
     (for predicate atoms) and index comparison (for cross-component order atoms).
   - Same-component order atoms for OLD env elements follow from h_joint (the joint NF encodes
     pairwise order between same-component elements).

3. **In the quantifier step**, replace the 1-variable component NF transfer with:
   - Extract same-component sub-environment from env_M and env_N
   - Use `nf_agreement_from_shared_nf` on component (from h_joint for component i)
   - Apply `nf_agreement_monotone` on component pair to get (s_i+1)-variable NF agreement
   - Extract b from the matched joint NF (via `nf_exists_unique` on the component)
   - Establish h_joint for the extended environment using the new matched joint NF

4. **Close the order atom sorry** in each case: once the witness b is found via the joint NF
   matching (step 3), the order atom case follows from `nf_agreement_from_shared_nf` applied
   to the component pair with the (s_i+1)-variable joint NF.

This approach resolves all 4 sorry sites simultaneously with a single correct witness
selection mechanism. No new axioms, no sorry deferrals, no EF game infrastructure needed.
