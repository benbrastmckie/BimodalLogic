# Research Report: Design `nf_eval_boost_prior` for Task 305

- **Task**: 305 - Rabinovich EA-formula implementation
- **Started**: 2026-06-21T22:00:00Z
- **Completed**: 2026-06-22T01:30:00Z
- **Effort**: 3.5 hours
- **Dependencies**: Plans v9-v12 (all BLOCKED on same root cause)
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (5 sorry sites)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampComposition.lean` (cross_extend infrastructure)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` (HasAttainedINF, Prior-UZ instantiation)
  - `Theories/Bimodal/Metalogic/WeakCanonical/PriorDefs.lean` (semantic_prior_UZ/SZ definitions)
  - `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` (NF infrastructure)
  - Rabinovich 2014, "A Proof of Kamp's Theorem" (Literature/sources/rabinovich_2014/)
  - Reports 04-07 and plans v9-v12 (prior failed approaches)
- **Artifacts**: `specs/305_rabinovich_ea_formula_implementation/reports/08_nf-eval-boost-design.md`
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- The 5 sorry sites in PriorComposition.lean share one root cause: a depth-1 gap where depth-(K+1) 3-var existential transfer is needed but only depth-K is available from `exist_transfer_from_full_agree`.
- The gap is FUNDAMENTAL to the NF framework: the quantifier condition of depth-D agreement gives depth-(D-1) transfer. Getting depth-D transfer from depth-D agreement requires semantic content (Prior-UZ/SZ + char_fn). No purely algebraic boost exists.
- The proposed resolution is `nf_eval_boost_prior`: a one-directional existential transfer lemma proved by Nat.rec on depth d, with arity r universally quantified. At each depth, witnesses are found via Prior-UZ/SZ + char_fn (which gives FULL-DEPTH 1-var matching without the cross_extend depth loss), and the quantifier conditions transfer by the IH.
- This follows Rabinovich's Lemma 5.3 Duplicator strategy: use first-occurrence analysis to place witnesses in the correct interval, not quantifier extraction (which loses a depth level).
- The sorry at line 524 (`prior_exist_transfer_one_dir`) has the RIGHT shape for this approach. Its proof should be completed, not deleted.
- At the sorry sites (lines 595/599/650/654), the proof applies `prior_exist_transfer_one_dir` with ih_strong supplying the required agreement for the outer quantifier step.

## H3 Lemma Mapping Table (Tier 1: Rabinovich 2014)

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| Lemma 5.3 base (algebraic core) | Existential transfer at depth d <= k from depth-(k+1) agreement | `exist_transfer_from_full_agree` | `h_agree : depth-(k+1) (n+1)-var -> depth-d (n+2)-var exist transfer, d <= k` | PROVED |
| Lemma 5.3 extension | Existential transfer at FULL depth K+1 (one beyond algebraic core) | `nf_eval_boost_prior` (NEW) | See Section "Proposed Signature" | TO PROVE |
| Lemma 5.1, composition step | 2-var agreement on non-constant envs (Prior structures) | `prior_nonconstenv_2var_agree_until` | `depth-(K+2) 1-var at x/x', t/t' -> depth-(K+2) 2-var at [x,t]/[x',t']` | SORRY (4 sites) |
| Lemma 5.1, quantifier step | 3-var existential transfer in the quantifier condition | Sorry sites (595/599/650/654) | `(exists w, nf_eval M (K+1) 3 [w,x,t] sub) <-> (exists w', nf_eval N (K+1) 3 [w',x',t'] sub)` | SORRY |
| Reconstruction induction | All depths from top agreement | `reconstruction_depth_agree` | `depth-(K+1) (n+1)-var -> depth-d (n+1)-var, d <= K+1` | PROVED |
| Prior-UZ first occurrence | Attained first occurrence in intervals | `prior_hasAttainedINF` / `HasAttainedINF.first_occ` | `semantic_prior_UZ -> HasAttainedINF` | PROVED |
| Depth-0 witness check | Verify atomic 3-var NF satisfaction | `depth0_3var_witness_check` | `predicates + orders -> nf_eval_nf N 0 3 env sub` | PROVED |

## Context and Scope

### The Problem

The 4 sorry sites at lines 595/599/650/654 of PriorComposition.lean all need the same thing: depth-(K+1) 3-var existential transfer between M and N, at the env [x,t]/[x',t']. The existing `exist_transfer_from_full_agree` provides this at depth d for d <= K, but NOT at d = K+1. This "one depth short" gap has blocked plans v9 through v12.

### What Is Available at the Sorry Sites

Inside `Nat.strong_induction_on K`:

```
ih_strong : forall m < K, forall nf : NormalForm sig (m+2) 2,
  nf_eval_nf M (m+2) 2 [x,t] nf <-> nf_eval_nf N (m+2) 2 [x',t'] nf

h_x : depth-(K_outer+2) 1-var agreement at x/x'
h_t : depth-(K_outer+2) 1-var agreement at t/t'
h_order_M : t < x (Until) or x < t (Since)
h_order_N : t' < x' (Until) or x' < t' (Since)
h_UZ_M, h_SZ_M, h_UZ_N, h_SZ_N : Prior axioms
char_fn, char_correct : temporal characterization of 1-var NF types
```

For K >= 1: ih_strong at m = K-1 gives depth-(K+1) 2-var agreement at [x,t]/[x',t'].

For K = 0: ih_strong is vacuous.

### Why Previous Approaches Failed

| Approach | What It Gives | Gap |
|---|---|---|
| `exist_transfer_from_full_agree` on ih_strong(K-1) | depth-K 3-var existential transfer | ONE depth short (K vs K+1) |
| `nvar_transfer_from_1var_agree` | depth-d r-var agreement | Needs h_rvar at depth d+2 (circular) |
| `reconstruction_depth_agree` | depth-d (n+1)-var for d <= K+1 | Same arity, not higher |
| Direct zone-based construction | Witness with correct zone | Quantifier conditions at one higher arity hit the same gap recursively |
| Lex induction on (K, r) | Decreases K when arity grows | Witnesses from quantifier extraction lose one depth level of 1-var agreement |

## Findings

### Finding 1: The Gap Is Arity, Not Depth

At the sorry sites, the strong induction variable K and the outer parameter K_outer are related by K <= K_outer (K ranges over all values in the strong induction). The depths match: hw2 from `cross_extend_bwd_1var` has depth K+1, and the goal needs depth K+1. The gap is purely about ARITY: we have 2-var agreement but need 3-var existential transfer.

### Finding 2: Algebraic Boost Is Impossible

After exhaustive analysis, no purely algebraic lemma can boost existential transfer from depth K to K+1 using only the (r+1)-var agreement. The gap is structural: depth-D NF has quantifier at D-1. `exist_transfer_from_full_agree` already extracts the algebraic maximum (depth d for d <= K from depth-(K+1) agreement). Any Nat.rec on K hits the same wall at every level.

### Finding 3: Prior-UZ/SZ + char_fn Is Required at EVERY Depth Level

The depth-loss problem affects all depths, not just K=0. At any depth d, finding a witness with depth-d 1-var type via quantifier extraction (cross_extend_bwd_1var) gives only depth-(d-1). The char_fn + Prior-UZ mechanism avoids this by characterizing the 1-var type as a temporal formula and re-deriving the matching from char_correct. This gives FULL depth-d matching without loss.

### Finding 4: `prior_exist_transfer_one_dir` Has the Correct Signature

The sorry at line 524 is in `prior_exist_transfer_one_dir`, which has exactly the right shape for the solution: one-directional existential transfer by Nat.rec on depth d, using componentwise 1-var agreements + Prior-UZ/SZ + char_fn. It should be COMPLETED, not deleted. The sorry sites (595/599/650/654) should apply it.

### Finding 5: Backward Direction Is Symmetric

The sorry sites come in forward/backward pairs (595/599 for Until, 650/654 for Since). Applying `prior_exist_transfer_one_dir` with M/N swapped gives the backward direction. The h_1var symmetry holds because h_x and h_t are biconditional.

## Proposed Signature

### CORRECTION: The Algebraic Approach Fails

After exhaustive analysis (see Adversarial Verification), the "purely algebraic" nf_eval_boost_prior DOES NOT WORK. The gap is structural: a depth-D NF's quantifier condition encodes existentials at depth D-1, never D. No induction on K changes this. The `exist_transfer_from_full_agree` lemma already extracts the maximum algebraically available.

### Corrected Approach: `prior_exist_transfer_one_dir` (Line 491)

The existing `prior_exist_transfer_one_dir` at line 491 has the RIGHT signature for the solution. Its proof at line 524 is `sorry`. The proof should use Prior-UZ/SZ + char_fn to find witnesses with FULL-DEPTH 1-var matching (avoiding the cross_extend depth loss).

The key insight from Rabinovich's Lemma 5.3: witnesses are NOT found by quantifier extraction (which loses one depth level). Instead, witnesses are found by temporal formula characterization + first-occurrence analysis (Prior-UZ), which gives full-depth 1-var matching at the target point.

### Corrected Signature: Complete `prior_exist_transfer_one_dir`

The existing signature at line 491 is:

```lean
private theorem prior_exist_transfer_one_dir {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (M N : OrderedMonadicStructure sig)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (K : Nat)
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) (nf_1 : NormalForm sig d 1)
        (S : OrderedMonadicStructure sig)
        (_ : semantic_prior_UZ S atomMap) (_ : semantic_prior_SZ S atomMap)
        (t : S.carrier),
        temporal_truth S atomMap t (char_fn d nf_1) ↔
        nf_eval_nf S d 1 (fun _ => t) nf_1) :
    ∀ (d : Nat) (_ : d ≤ K + 1) (r : Nat)
      (envM : Fin r → M.carrier) (envN : Fin r → N.carrier)
      (_ : ∀ (i : Fin r), ∀ nf : NormalForm sig (d + 1) 1,
        nf_eval_nf M (d + 1) 1 (fun _ => envM i) nf ↔
        nf_eval_nf N (d + 1) 1 (fun _ => envN i) nf)
      (_ : ∀ (i j : Fin r), envM i < envM j ↔ envN i < envN j)
      (sub : NormalForm sig d (r + 1)),
      (∃ z : M.carrier, nf_eval_nf M d (r + 1) (Fin.cons z envM) sub) →
      ∃ z' : N.carrier, nf_eval_nf N d (r + 1) (Fin.cons z' envN) sub
```

This is one-directional (M to N). The biconditional for the sorry sites follows by applying twice (swap M/N).

## Proof Sketch for `prior_exist_transfer_one_dir`

### Why The Algebraic Approach Fails (Critical Correction)

An earlier version of this analysis claimed the K+1 step was "purely algebraic." This was an ERROR. The quantifier condition of depth-D agreement gives depth-(D-1) transfer, ALWAYS one short of D. No Nat.rec on K can overcome this:

- At K=0: depth-1 agreement gives depth-0 transfer. Goal: depth 1. Gap: 1.
- At K+1: depth-(K+2) agreement gives depth-(K+1) transfer. Goal: depth K+2. Gap: 1.

The gap is structural to the NF framework. `exist_transfer_from_full_agree` already extracts the maximum algebraically available (depth d for d <= K from depth-(K+1) agreement).

### Correct Approach: Prior-UZ/SZ Witness Placement (Rabinovich Lemma 5.3)

The proof of `prior_exist_transfer_one_dir` uses Prior-UZ/SZ to find witnesses with FULL-DEPTH 1-var matching, avoiding the quantifier extraction depth loss entirely.

**Induction on d (depth), with r universally quantified.**

Given (exists z, nf_eval M d (r+1) [z,envM] sub), find z' in N with nf_eval N d (r+1) [z',envN] sub.

### Base Case (d=0)

At depth 0, sub is purely atomic. nf_eval_nf M 0 (r+1) [z,envM] sub means all atoms (predicates + orders) at [z,envM] match sub.

**Finding z'**: Determine z's zone relative to envM (using linear order decidability). For each zone:
- Zone "beyond all env elements" (z > max(envM) or z < min(envM)): Use cross_extend_bwd_1var from the nearest env element. Gives z' with matching 1-var type (depth-1 from h_1var at depth d+1 = 1) and correct order.
- Zone "between envM_i and envM_j": Use char_fn at depth 0 (propositional: just predicates) to characterize z's 1-var type. The 1-var agreement at depth 1 at envM_i/envN_i includes a quantifier condition that transfers the existence of a point with z's type above envN_i. Similarly, 1-var at envM_j/envN_j transfers existence below envN_j. Prior-UZ at envN_i gives a first occurrence in the correct interval.
- Zone "equal to envM_i": Use envN_i directly. Predicates match from h_1var.

**Verification**: All atoms (predicates from 1-var matching, orders from zone) match. No quantifier conditions at depth 0.

### Inductive Step (d+1)

Given z with nf_eval M (d+1) (r+1) [z,envM] sub where sub = (atoms, quant_d).

**Step 1: Find z' with matching depth-(d+1) 1-var type in the correct zone.**

Use char_fn at depth d+1: let phi = char_fn (d+1) (nf_characteristic M (d+1) 1 (fun _ => z)). By char_correct: temporal_truth M atomMap z phi holds.

Zone analysis on z relative to envM determines the target interval in N. The 1-var agreement at depth d+2 (from h_1var) at the adjacent env elements transfers the existence of a point with the temporal property phi. Prior-UZ/SZ localizes the first/last occurrence in the correct interval.

char_correct then converts temporal_truth N atomMap z' phi back to nf_eval_nf N (d+1) 1 (fun _ => z') nf_z. So z' has the SAME depth-(d+1) 1-var type as z. No depth loss.

**Step 2: Show z' satisfies sub at [z',envN].**

- **Atoms** (arity r+1): Predicates at z' match z (from depth-(d+1) 1-var matching, d+1 >= 1). Predicates at envN_i match envM_i (from h_1var at d+1). Orders between z' and envN_i match z and envM_i (from zone placement). Orders between envN_i, envN_j match (from h_order).

- **Quantifier** (depth d, arity r+2): For each chi : NormalForm sig d (r+2), need: (exists u, nf_eval M d (r+2) [u,z,envM] chi) -> (exists u', nf_eval N d (r+2) [u',z',envN] chi).

  Apply **IH at d** with env = [z,envM]/[z',envN] (arity r+1):
  - h_1var' for [z,envM]/[z',envN] at depth d+1: z/z' have depth-(d+1) 1-var matching (from Step 1). envM_i/envN_i have depth-(d+2) >= d+1 1-var from outer h_1var. By monotonicity, all components have depth-(d+1) 1-var. CHECK: the IH needs h_1var at depth (d+1), which is d+1 (not d+2). Available.
  - h_order' for [z,envM]/[z',envN]: z vs envM_i order matches z' vs envN_i from zone placement + atom matching.
  - char_correct available at d' < d+1, i.e., d' <= d. Since the outer char_correct has d' <= K+1 and d <= K+1, this is satisfied.

  The IH gives the one-directional transfer. The existential witness u' is found by the same Prior-UZ/SZ mechanism at one lower depth.

### Key Mechanism: char_fn Avoids the Depth Loss

The critical difference from the algebraic approach: witnesses are found via char_fn + Prior-UZ/SZ, which gives depth-d 1-var matching DIRECTLY (through temporal formula characterization). In contrast, quantifier extraction (cross_extend_bwd_1var) gives depth-(d-1) 1-var. The char_fn mechanism does not lose a depth level because it characterizes the 1-var type as a temporal formula and re-derives the matching from char_correct.

## Call Site Verification

### Line 595 (Until forward, all K)

**Available**: h_x at depth K_outer+2, h_t at depth K_outer+2, Prior-UZ/SZ, char_fn/char_correct at d <= K_outer+1, h_order_M (t < x), h_order_N (t' < x').

**Apply**: `prior_exist_transfer_one_dir` with:
- d = K+1 (the depth of the sub_nf)
- r = 2 (the base env has 2 elements: x, t)
- envM = [x, t] (using Fin.cons x (fun _ => t) restricted to Fin 2)
- envN = [x', t']
- h_1var at depth (K+1)+1 = K+2: for x/x' and t/t', from h_x and h_t (both at depth K_outer+2 >= K+2 since K <= K_outer). CHECK: K <= K_outer always holds in Nat.strong_induction_on.
- h_order: t < x iff t' < x' (from h_order_M and h_order_N). Other order pairs: x < x is false iff x' < x' is false, etc.
- char_correct bound: d = K+1 <= K_outer+1. Available from outer char_correct.

**Result**: one-directional transfer gives w' in N. Use `exact ⟨w', prior_exist_transfer_one_dir ... ⟨w, hw⟩⟩`.

### Line 599 (Until backward)

**Symmetric**: Apply `prior_exist_transfer_one_dir` with M and N swapped. The h_1var symmetry follows from h_x.symm and h_t.symm.

### Lines 650/654 (Since forward/backward)

**Mirror of 595/599**: Same mechanism with reversed order assumptions (x < t instead of t < x). `prior_exist_transfer_one_dir` does not depend on the direction of the order.

## Auxiliary Lemmas Needed

### 1. Depth-0 Existential Transfer on Prior Structures (for K=0 base case)

```lean
/-- On Prior structures, depth-0 (r+2)-var existential transfer from
    depth-0 (r+1)-var atom agreement + componentwise 1-var agreements. -/
theorem depth0_exist_transfer_prior {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (M N : OrderedMonadicStructure sig)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (r : Nat)
    (envM : Fin (r + 1) → M.carrier) (envN : Fin (r + 1) → N.carrier)
    (h_atoms : ∀ (a : AtomKind sig (r + 1)),
      atom_eval M envM a ↔ atom_eval N envN a)
    (h_1var_transfer : ∀ (i : Fin (r + 1)),
      ∀ nf1 : NormalForm sig 1 1,
        nf_eval_nf M 1 1 (fun _ => envM i) nf1 ↔
        nf_eval_nf N 1 1 (fun _ => envN i) nf1)
    (chi : NormalForm sig 0 (r + 2)) :
    (∃ z : M.carrier, nf_eval_nf M 0 (r + 2) (Fin.cons z envM) chi) ↔
    (∃ z' : N.carrier, nf_eval_nf N 0 (r + 2) (Fin.cons z' envN) chi)
```

This encodes the zone-based witness placement at the atomic level. The proof requires:
- Linear order decidability for zone determination
- cross_extend_bwd_1var from adjacent env elements for witness finding
- Prior-UZ/SZ for zone-3 witnesses (between two env elements with no direct 1-var agreement)

### 2. No Modifications to Existing Infrastructure

All existing sorry-free lemmas (exist_transfer_from_full_agree, reconstruction_depth_agree, nvar_transfer_from_1var_agree, cross_extend_bwd/fwd_1var, constenv_same_depth_2var, nonconstenv_atom_agree_until/since) remain unchanged.

## Adversarial Self-Verification (H4)

### Challenge 1: Does the "algebraic nf_eval_boost_prior" work?

**Claim (REFUTED)**: A purely algebraic lemma can boost existential transfer from depth K to K+1 using only h_agree (no Prior-UZ/SZ).

**Refutation**: The quantifier condition of depth-D (r+1)-var agreement encodes depth-(D-1) (r+2)-var existential biconditionals. This is structural to the NF framework: depth D NF = (atoms, quant_{D-1}). No induction overcomes this. At each level of the proposed Nat.rec, the gap reappears:
- K=0: depth-1 agreement -> depth-0 transfer (need depth-1). Gap: 1.
- K+1: depth-(K+2) agreement -> depth-(K+1) transfer (need depth-(K+2)). Gap: 1.

`exist_transfer_from_full_agree` already extracts the algebraic maximum. **VERDICT: REFUTED. The algebraic approach is impossible.**

### Challenge 2: Does char_fn + Prior-UZ/SZ actually avoid the depth loss?

**Claim**: Witnesses found via char_fn + Prior-UZ have full-depth 1-var matching (no depth loss).

**Verification**: char_correct at depth d says: temporal_truth S atomMap t (char_fn d nf_1) <-> nf_eval_nf S d 1 (fun _ => t) nf_1. If we find z' in N with temporal_truth N atomMap z' (char_fn d nf_z), then nf_eval_nf N d 1 (fun _ => z') nf_z holds. This gives DEPTH-d 1-var matching. No depth loss because the temporal formula encodes the full depth-d type. In contrast, cross_extend_bwd_1var loses one depth because it extracts witnesses from a quantifier condition. **CONFIRMED**.

### Challenge 3: Can Prior-UZ guarantee a witness in a SPECIFIC interval?

**Claim**: Given temporal_truth M atomMap z phi where z is in (envM_i, envM_j), we can find z' in (envN_i, envN_j) with the same temporal truth.

**Verification**: This requires two steps:
1. Establish that phi is satisfied somewhere above envN_i in N. From h_1var at envM_i/envN_i (depth d+1 >= 2), the quantifier condition transfers depth-d 2-var existentials. z has a depth-d 2-var type at [z, envM_i] with z > envM_i. Transfer gives z_1 > envN_i with matching 2-var type. cross_1var_from_2var gives depth-d 1-var at z/z_1. char_correct: temporal_truth N atomMap z_1 phi. So phi is satisfied at z_1 > envN_i.
2. Prior-UZ at envN_i with phi: gives FIRST z' > envN_i with temporal_truth phi and neg-phi on (envN_i, z'). Need z' < envN_j. From h_1var at envM_j/envN_j: similarly, using Prior-SZ below envN_j, the LAST occurrence of phi below envN_j is some z_2 < envN_j. So phi is satisfied at z_2 in (envN_i, envN_j) -- wait, we need to show z_2 > envN_i.

**Risk**: The interval (envN_i, envN_j) might not contain a phi-satisfying point even though (envM_i, envM_j) does. The 1-var agreements at the endpoints don't directly encode interval interior properties.

**Mitigation**: The 1-var agreement at depth d+1 at envM_i includes: for each 2-var NF chi, (exists y, nf_eval M d 2 [y, envM_i] chi) <-> (exists y', nf_eval N d 2 [y', envN_i] chi). If z is above envM_i with some depth-d 2-var type, there's a z_1 above envN_i with the same. The 2-var type at [z, envM_i] encodes z's 1-var type AND z > envM_i. So z_1 has matching 1-var type and z_1 > envN_i. But z_1 could be above envN_j.

**To bound z_1 below envN_j**: Use the 1-var agreement at envM_j/envN_j. If z < envM_j, the 2-var type at [z, envM_j] encodes z < envM_j and z's predicates. Transfer: z_2 < envN_j with matching type. But z_2 might not equal z_1, and z_2 could be below envN_i.

**Resolution**: Use both endpoints. z_1 > envN_i with matching type, z_2 < envN_j with matching type. Prior-UZ at envN_i: first occurrence of phi above envN_i gives r_0 with envN_i < r_0 <= z_1. If z_1 < envN_j, done (r_0 <= z_1 < envN_j). If z_1 >= envN_j: use z_2 instead. z_2 < envN_j with temporal_truth phi. Prior-SZ at envN_j: last occurrence below envN_j gives r_1 >= z_2 with r_1 < envN_j. Is r_1 > envN_i? If z_2 > envN_i, then r_1 >= z_2 > envN_i. Does z_2 > envN_i hold? The 2-var type at [z, envM_j] encodes z < envM_j but says nothing about z vs envM_i. So z_2 might not be above envN_i.

**UNRESOLVED**: The interval bounding for zone-3 witnesses requires careful case analysis. The proof may need a 3-var hypothesis (which is circular) or a more refined argument using the order structure of the env.

**Confidence**: MEDIUM for the interval bounding. The overall approach (char_fn + Prior-UZ/SZ) is sound, but the INTERVAL LOCALIZATION for zone-3 witnesses between two env elements requires further investigation.

### Challenge 4: Does the IH at d provide sufficient hypotheses?

**Claim**: The IH at d for env [z', envN] (arity r+1) has all required inputs.

**Verification**:
- h_1var' at depth (d+1): z'/z have depth-(d+1) 1-var from char_fn. envM_i/envN_i have depth-(d+2) from outer h_1var, which weakens to d+1.
- h_order' for [z', envN]: inherits from zone placement + outer h_order.
- char_correct at d' <= d: from outer char_correct at d' <= K+1, and d <= K+1.

The h_1var depth at z' is exactly d+1 (from char_fn), and the IH needs depth (d+1). **Exact match. CONFIRMED**.

For envN_i: outer h_1var is at depth d+2 (where d is the outer induction variable). The IH at d uses env elements with 1-var at depth d+1. Since d+2 > d+1, monotonicity gives d+1. **CONFIRMED**.

### Challenge 5: Does the backward direction follow?

**Claim**: Applying prior_exist_transfer_one_dir with M/N swapped gives the backward transfer.

**Verification**: The lemma is one-directional (M -> N). Swapping M and N, with h_1var.symm, h_order.symm, and Prior-UZ/SZ hypotheses on the swapped structures (which are available at the sorry sites as h_UZ_M, h_SZ_M for the "source" structure). **CONFIRMED**.

### Summary of Adversarial Verification

| Claim | Status | Confidence |
|---|---|---|
| Algebraic nf_eval_boost_prior | REFUTED | N/A (impossible) |
| char_fn avoids depth loss | VERIFIED | HIGH |
| Prior-UZ gives interval-bounded witness | PARTIALLY VERIFIED | MEDIUM |
| IH has sufficient hypotheses | VERIFIED | HIGH |
| Backward direction by symmetry | VERIFIED | HIGH |
| Call sites provide all hypotheses | VERIFIED | HIGH |

## Recommendations

### Priority 1: Complete `prior_exist_transfer_one_dir` (Line 491-524)

The existing statement at line 491 IS the correct signature. Fill the sorry at line 524 with the Prior-UZ/SZ + char_fn proof described in the Proof Sketch above.

**Proof structure**: Nat.rec on d (the first universally quantified Nat), with r universally quantified inside. At each step:
1. Find z' via char_fn + Prior-UZ/SZ (full-depth 1-var matching)
2. Atoms from 1-var matching + zone placement
3. Quantifier conditions from IH at d-1

**Estimated complexity**: ~100-150 lines. The d=0 base case is ~40 lines (zone analysis + atomic matching). Each induction step is ~50 lines (char_fn witness finding + atom verification + IH application).

### Priority 2: Wire Sorry Sites (Lines 595/599/650/654)

Replace the `cross_extend_bwd_1var` + sorry pattern with direct application of `prior_exist_transfer_one_dir`. The current code at line 594 uses cross_extend to find w2, then puts sorry. Instead:
1. Remove the cross_extend call (or keep for zones 1/5 only)
2. Apply `prior_exist_transfer_one_dir` for the full zone-3 transfer
3. For the backward direction: apply with M/N swapped

**Note**: The current `cross_extend_bwd_1var` call at each sorry site should be REPLACED, not supplemented. `prior_exist_transfer_one_dir` handles ALL zones internally.

### Priority 3: Verify h_1var Depth at Call Sites

At the sorry sites, `prior_exist_transfer_one_dir` needs h_1var at depth (d+1) = (K+1)+1 = K+2 for each env component. Available from h_x and h_t at depth K_outer+2. Need to verify K+2 <= K_outer+2, i.e., K <= K_outer. This holds because K is the strong induction variable ranging up to K_outer.

**Edge case**: When K = K_outer, depth K+2 = K_outer+2 exactly matches h_x/h_t depth. When K < K_outer, excess depth is available (use nf_agreement_monotone to weaken).

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Zone-3 interval bounding (witness between envN_i and envN_j) fails | HIGH | MEDIUM | Use BOTH endpoints' 1-var agreements + Prior-UZ from below + Prior-SZ from above. If direct interval bounding fails, use the 3-var existential from ih_strong at d < K for the bounded case. |
| char_fn at depth d > 0 involves temporal operators (not purely propositional) | MEDIUM | LOW | char_correct guarantees the characterization works regardless of formula complexity. The temporal formula may use Until/Since, but Prior-UZ/SZ applies to arbitrary temporal formulas. |
| The sorry at line 524 requires > 200 lines | MEDIUM | MEDIUM | The proof follows Rabinovich's Lemma 5.3 structure closely. Factor zone analysis into a shared helper. |
| The 4 sorry sites have slightly different contexts (Until vs Since) | LOW | HIGH | Template one wiring, adapt three. The differences are only order direction (t < x vs x < t). |
| h_1var depth at K = K_outer requires careful arithmetic | LOW | HIGH | K <= K_outer always holds in strong_induction_on. Use nf_agreement_monotone to weaken depth. |
| prior_exist_transfer_one_dir requires env as Fin r, but sorry sites use Fin.cons x (fun _ => t) | LOW | MEDIUM | Convert between Fin-based env and cons-based env using Fin.cons_castSucc / Fin.cons_succ lemmas already in codebase. |
