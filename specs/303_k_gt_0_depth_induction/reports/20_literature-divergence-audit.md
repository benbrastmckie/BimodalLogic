# Literature Divergence Audit: Rabinovich 2014 vs Lean Proof Architecture

**Task**: 303
**Date**: 2026-06-19
**Purpose**: Systematic structural audit identifying WHERE and WHY the Lean proof diverges from Rabinovich 2014, with a minimal refactoring specification to restore alignment.

---

## Section 1: Rabinovich's Proof Architecture (from the paper)

### 1.1 Overall Logical Flow

Rabinovich proves Kamp's Theorem (Theorem 2.1) via:

```
Theorem 4.4 (Kamp's Theorem)
  |
  +-- Proposition 4.3 (FOMLO -> V-EA formulas)
  |     Proof by structural induction on FOMLO formulas:
  |       Atomic: immediate
  |       Disjunction: immediate
  |       Negation: uses Proposition 4.2 (the hard part)
  |       Exists: Lemma 3.4
  |
  +-- Proposition 3.5 (V-EA formulas with 1 free var -> TL)
        Direct mapping: interval decomposition -> nested Until/Since
```

### 1.2 The Hard Part: Proposition 4.2 (Closure under Negation)

**Statement** (Prop 4.2, p. 6): "The negation of EA-formulas with at most two free variables is equivalent over Dedekind complete chains to a disjunction of EA-formulas."

**Reduction** (Section 5, p. 7): Given an EA-formula psi(z_0, z_1) with free variables z_0, z_1, where z_0 = x_m and z_1 = x_k in the ordered existential sequence x_0 < ... < x_n:

- If k = m: psi is equivalent to z_0 = z_1 AND psi'(z_0), where psi' is a 1-free-variable EA-formula. Its negation is a V-EA formula (via Prop 3.5, since TL formulas' truth tables are EA, and their negations are also TL, hence also EA).
- If k != m (WLOG m < k): psi decomposes into three parts:
  1. psi_0(z_0) -- an EA-formula with one free variable
  2. psi_1(z_1) -- an EA-formula with one free variable
  3. phi(z_0, z_1) -- the two-variable core (Equation 5.1)

The negation of psi is then a disjunction of negations of each part. Parts (1) and (2) are handled by Prop 3.5. Part (3) reduces to Lemma 5.1.

### 1.3 Lemma 5.1 (The Core Interval Splitting Lemma)

**Statement** (Lemma 5.1, p. 7): The negation of

```
exists x_0 ... exists x_n [(z_0 = x_0 < ... < x_n = z_1)
  AND bigwedge alpha_j(x_j) AND bigwedge (forall y in (x_{j-1}, x_j)) beta_j(y)]   (5.1)
```

is equivalent (over Dedekind complete chains) to a disjunction of EA-formulas.

**Proof by induction on n** (the number of internal existential witnesses, NOT quantifier depth).

**What decreases**: n (the number of existentially quantified variables between z_0 and z_1).

**Base case**: n = 0. Formula (5.1) with z_0 = x_0 < x_0 = z_1 reduces to z_0 < z_1 AND alpha_0(z_0) AND alpha_0(z_1) AND (forall y in (z_0, z_1)) beta_1(y). The negation is a Boolean combination of atomic/universal formulas, each expressible as V-EA.

**Inductive step**: Uses case analysis on what can go wrong with the pattern (pp. 9-11):

- **Case 1**: not alpha_0(z_0) OR K+(not beta_1)(z_0) -- endpoint failure. The negation is trivially V-EA.
- **Case 2**: alpha_0(z_0) AND beta_1 holds everywhere in (z_0, z_1) -- guard succeeds but no witness for x_1. Equivalent to negating a sub-formula with one fewer free variable (handled by Corollary 5.4).
- **Case 3**: alpha_0(z_0) AND not K+(not beta_1)(z_0) AND exists x in (z_0, z_1) with not beta_1(x). This is the KEY case. It introduces a new point z = inf{x in (z_0, z_1) : not beta_1(x)} via the INF formula (5.2-5.3), then decomposes the interval at z:
  - Left sub-interval: A_i^-(z_0, z) = [alpha_0, beta_1, ..., alpha_i](z_0, z)
  - Right sub-interval: A_i^+(z, z_1) = [alpha_i, beta_{i+1}, ..., alpha_{n+1}](z, z_1)

The negation becomes a conjunction of negated sub-interval formulas, each involving FEWER existential witnesses than the original. By the IH, each negated sub-formula is V-EA. By Lemma 3.4 (closure under conjunction), the conjunction is V-EA.

### 1.4 Lemma 5.3 (All beta_i = True)

**Statement**: not (exists x_1 ... exists x_n in (z_0, z_1) with P_i(x_i)) is V-EA over Dedekind complete chains.

**Proof by induction on n** (number of predicates).

**What decreases**: n.

**Base case**: not (exists x_1 in (z_0, z_1) with P_1(x_1)) = (forall y in (z_0, z_1)) not P_1(y). This is V-EA.

**Inductive step** (n -> n+1): If P_1 doesn't occur in (z_0, z_1), done (O_{n+1} should be equivalent). Otherwise, let r_0 = inf{z in (z_0, z_1) : P_1(z)}. The INF formula (5.2) defines r_0 as a V-EA formula. Then:
- Subcase r_0 = z_0: O_{n+1}(P_1, ..., P_{n+1}, z_0, z_1) should be equivalent to O_n(P_2, ..., P_n, z_0, z_1).
- Subcase r_0 in (z_0, z_1): O_{n+1} should be equivalent to O_n(P_2, ..., P_n, r_0, z_1).

Both reduce to O_n (one fewer predicate), which is V-EA by IH.

### 1.5 Corollary 5.4

**Statement** (Corollary 5.4, p. 9):
1. not (exists z in (z_0, z_1)) [alpha_0, beta_1, ..., alpha_n](z_0, z) is V-EA over Dedekind complete chains.
2. Mirror for right endpoint.

**Proof**: Define F_n := alpha_n, F_{i-1} := alpha_{i-1} AND (beta_i Until F_i). Then [alpha_0, ..., alpha_n](z_0, z) holds iff F_0(z_0) holds and there's an increasing sequence x_1 < ... < x_n in (z_0, z_1) with F_i(x_i). The negation reduces to not F_0(z_0) OR O_n(F_1, ..., F_n, z_0, z_1) via Lemma 5.3.

### 1.6 Key Insight: What Rabinovich's Proof Does NOT Do

**Rabinovich does NOT prove composition by transferring existential witnesses between structures.** Instead:

1. He works WITHIN a single structure (the Dedekind complete chain).
2. He proves closure under negation by syntactic manipulation: showing that the negation of an EA formula can be rewritten as a V-EA formula.
3. The proof is entirely about formula manipulation, not about cross-structure equivalence.
4. No "Prior structures" or "Prior axioms" appear. Dedekind completeness is used only via the INF construction.

---

## Section 2: The Lean Proof Architecture (from the code)

### 2.1 Overall Structure

The Lean proof takes a fundamentally different approach:

```
completeness_discrete (KampPrior.lean)
  |
  +-- kamp_mutual_induction (KampMutualInduction.lean)
  |     Mutual induction on k (quantifier depth):
  |       CharPart(k): every 1-var NF has a temporal characteristic formula
  |       ExistPart(k): for all n >= 1, (n+1)-var existentials are temporally characterizable
  |
  |     CharPart(0): nf_depth0_char_formula (sorry-free)
  |     CharPart(k+1): from CharPart(k) + ExistPart(k) via nf_characterizable_temporal_prior_classical
  |     ExistPart(0): sorry-free for all n
  |     ExistPart(k+1): via existPart_succ_n1_bypass (KampBypass.lean)
  |
  +-- Doets Lemma 1.1 (NormalForm.lean: doets_lemma_1_1)
        Bridge: NF agreement -> formula truth agreement
```

### 2.2 The Induction Parameter

**Lean inducts on k (quantifier depth / NF depth)**, NOT on n (number of existential witnesses in an interval decomposition).

At each depth k, the proof must show:
- **CharPart(k)**: Each depth-k 1-var NF has a characteristic temporal formula correct on Prior structures.
- **ExistPart(k)**: For each n >= 1 and each (n+1)-var depth-k NF sub_nf, there exists a temporal formula A such that temporal_truth M t A <-> exists x, nf_eval_nf M k (n+1) (Fin.cons x (fun _ => t)) sub_nf.

### 2.3 The ExistPart(k+1) at n=1 (The Blocked Code)

`existPart_succ_n1_bypass` (KampBypass.lean, line 421) handles ExistPart(k+1) at n=1 (2-variable existentials). For k=0, it dispatches to `existPart_succ_n1_bypass_k0` (sorry-free). For k >= 1 (the `succ k'` case, line 480):

1. Case-splits on satisfiability of sub_nf.
2. For the satisfiable case, case-splits on the order zone (Until/Since/Eq).
3. **Until zone** (t < x, line 610-673): Constructs a formula `(char_kp1 nf_t0) AND ((char_kp1 nf_x0) U top)`. The forward direction (formula -> exists x) uses `prior_2var_transfer_until` from PriorComposition.lean.
4. **Since zone** (line 676-740): Mirror with `prior_2var_transfer_since`.
5. **Eq zone** (line 741-880): Uses `ih_exist` at arity 3 (sorry-free).

### 2.4 The Sorry Positions

**File: PriorComposition.lean**

1. **`nvar_transfer_from_1var_agree`** (line 381-462): 2 sorrys at lines 459, 462.
   - Goal: from componentwise 1-var NF agreement + order matching + Prior-UZ/SZ + CharPart, derive depth-d r-var NF agreement.
   - Sorry: the quantifier step (finding matched witness with correct order relative to ALL env components).

2. **`prior_nonconstenv_2var_agree_until`** (line 483-559): 2 sorrys at lines 554, 559.
   - Goal: from depth-(K+2) 1-var agreement at x/x' and t/t' + orders + Prior + CharPart, derive depth-(K+2) 2-var agreement at [x,t]/[x',t'].
   - Sorry: quantifier step -- finding 3-var witnesses with matching NF type.

3. **`prior_nonconstenv_2var_agree_since`** (line 562-614): 2 sorrys at lines 610, 614.
   - Mirror of above for Since zone.

**File: NfCharFormula.lean**

4. **`nf_exist_backward_prior`** (line 503-542): 1 sorry at line 542.
   - DEPRECATED: Not on the critical path. Dead code (marked as such in comments).

5. **`nf_2var_exist_formula_prior`** (line 616-657): 1 sorry at line 657.
   - DEPRECATED: The `k >= 2` branch is dead code (the general case is handled by `kamp_mutual_induction`).

### 2.5 The Live Sorry Dependency Chain

```
completeness_discrete
  <- kamp_mutual_induction
     <- existPart_succ (KampMutualInduction.lean line 307)
        <- existPart_succ_n1_bypass (KampBypass.lean line 421)
           <- prior_2var_transfer_until (PriorComposition.lean line 618)
              <- prior_nonconstenv_2var_agree_until (PriorComposition.lean line 483) *** SORRY ***
           <- prior_2var_transfer_since (PriorComposition.lean line 652)
              <- prior_nonconstenv_2var_agree_since (PriorComposition.lean line 562) *** SORRY ***
```

The 2 sorrys in `nvar_transfer_from_1var_agree` are NOT on the critical path (this theorem is not called by anything on the main chain). The 4 sorrys in `prior_nonconstenv_2var_agree_until/since` ARE the blockers.

### 2.6 What the Live Sorrys Ask For

All 4 live sorrys have the same shape. In `prior_nonconstenv_2var_agree_until` (line 554):

```
-- Given:
--   h_x: depth-(K+2) 1-var agreement at x/x', on Prior structures
--   h_t: depth-(K+2) 1-var agreement at t/t', on Prior structures
--   h_order_M: t < x, h_order_N: t' < x'
--   char_fn/char_correct: CharPart formulas at all depths d <= K+1
--   w: M.carrier with nf_eval_nf M (K+1) 3 [w,x,t] sub_nf
-- Find:
--   w': N.carrier with nf_eval_nf N (K+1) 3 [w',x',t'] sub_nf
```

This is the **cross-structure 3-var existential transfer on non-constant environments**. It asks: given a witness w in M with a certain 3-var NF type relative to (x, t), find a witness w' in N with the same 3-var NF type relative to (x', t').

---

## Section 3: Point-by-Point Divergence Analysis

| # | Rabinovich Step | Paper Reference | Lean Equivalent | Location | Correspondence | Gap? |
|---|----------------|-----------------|-----------------|----------|----------------|------|
| 1 | EA-formula definition (Def 3.1) | p.4 | Not present | N/A | **Missing** | No -- not needed; the Lean proof uses NormalForm directly |
| 2 | Closure properties (Lemma 3.2) | p.4 | Not present | N/A | **Missing** | No -- closure is implicit in NF theory |
| 3 | V-EA closure (Lemma 3.4) | p.5 | Not present | N/A | **Missing** | No |
| 4 | V-EA -> TL conversion (Prop 3.5) | p.5 | `nf_characterizable_temporal_prior_classical` | NfCharFormula.lean:662 | **Approximate** | No -- the Lean version is more general (arbitrary NFs, not just EA) |
| 5 | Canonical expansion (Def 4.1) | p.5-6 | `nf_eval_nf` + `temporal_truth` | NormalForm.lean:198, Table.lean | **Approximate** | No -- different formalism, same idea |
| 6 | **Prop 4.2 (negation closure)** | p.6 | **No direct equivalent** | N/A | **Missing** | **YES** -- this is THE divergence |
| 7 | Prop 4.3 (FOMLO -> V-EA) | p.6 | `kamp_mutual_induction` | KampMutualInduction.lean:405 | **Approximate** | Indirect -- the Lean proof replaces structural induction on FOMLO formulas with induction on NF depth |
| 8 | Theorem 4.4 (Kamp's Theorem) | p.6 | `completeness_discrete` | KampPrior.lean | Approximate | No |
| 9 | Lemma 5.1 (interval splitting) | p.7-11 | **Not present** | N/A | **Missing** | **YES** -- the Lean proof tries to achieve the same goal via cross-structure transfer instead of syntactic negation closure |
| 10 | INF formula (Eq. 5.2-5.3) | p.8, 10 | Not present | N/A | **Missing** | **YES** -- INF is the mechanism for introducing splitting points using Dedekind completeness |
| 11 | Lemma 5.3 (all beta = True) | p.8 | Not present | N/A | **Missing** | **YES** |
| 12 | Corollary 5.4 | p.9 | Not present | N/A | **Missing** | **YES** |
| 13 | Case 1-3 decomposition | p.9-10 | Zone analysis in KampBypass.lean | KampBypass.lean:341-360 | **Approximate** | Partial -- Lean has zone splits but uses them for cross-structure transfer, not syntactic negation |
| 14 | A_i^-/A_i^+ splitting (p.10) | p.10 | Not present | N/A | **Missing** | **YES** |
| 15 | Induction on n (existentials) | p.7-11 | Induction on k (depth) | KampMutualInduction.lean | **Fundamentally different** | **YES** -- the wrong induction parameter |
| 16 | Dedekind completeness (INF) | p.8 | Prior-UZ/SZ axioms | PriorDefs.lean:22-39 | **Approximate** | Partial -- Prior axioms are weaker/different from Dedekind completeness; they provide first/last occurrence, not infimum |
| 17 | Single-structure formula manipulation | throughout | Cross-structure NF transfer | PriorComposition.lean | **Fundamentally different** | **YES** -- the root architectural divergence |

---

## Section 4: Root Cause Identification

### Root Cause 1: Wrong Proof Method (Cross-Structure Transfer vs Syntactic Negation)

**What the Lean code does**: The Lean proof attempts to show that cross-structure existential transfer is possible on Prior structures: if M and N have matching 1-var NF types at corresponding points, then multi-var existentials can be transferred between M and N.

**What Rabinovich does**: Rabinovich works within a SINGLE structure. He never transfers witnesses between structures. Instead, he shows that the NEGATION of an interval-decomposition formula can be REWRITTEN as a V-EA formula, which is then converted to temporal logic via Proposition 3.5.

**Why the Lean choice fails**: Cross-structure transfer of multi-var existentials requires showing that ANY witness w in one structure has a counterpart w' in the other with the same multi-var NF type. On non-constant environments [x, t] with x != t, this requires placing w' in the correct "zone" relative to x' and t'. The between-zone (t' < w' < x') is the hard case: the witness must have correct predicates AND correct existential realization profile at the lower depth, AND the correct position relative to both x' and t'. The code has been stuck on this for 10+ dispatches because:

1. 1-var NF agreement at each point does NOT determine 2-var NF agreement on non-constant envs (counterexample documented in NfComposition.lean).
2. The Prior-UZ/SZ axioms provide first/last occurrence, but finding a witness with BOTH correct NF type AND correct position requires an argument that the Lean proof doesn't have.

**What would need to change**: Abandon the cross-structure transfer approach entirely. Instead, implement Rabinovich's negation closure argument within a single structure.

### Root Cause 2: Wrong Induction Parameter (Depth k vs Witness Count n)

**What the Lean code does**: Inducts on k (NF depth / quantifier depth). At each k, must handle ALL arities simultaneously.

**What Rabinovich does**: In the critical Lemma 5.1, inducts on n (the number of existentially quantified witness points between the two endpoints z_0 and z_1). The depth of the formula is NOT the induction parameter.

**Why the Lean choice fails**: Inducting on k forces the proof to handle the full quantifier complexity at each step. The existential transfer at depth k+1 requires knowledge about depth-k quantifier conditions, which in turn depend on depth-(k-1), etc. This creates an unbounded tower of dependencies. In contrast, Rabinovich's induction on n reduces the number of witnesses by 1 at each step (by splitting the interval at the INF point), keeping the proof structurally simple.

**What would need to change**: Rewrite the core argument to induct on n (interval witness count) rather than k (depth). This is a fundamental architectural change.

### Root Cause 3: Missing Normal Form for Intervals (EA-Formulas)

**What the Lean code does**: Uses `NormalForm sig k n` (Doets-style n-characteristics) as the sole normal form. These encode quantifier depth and variable count but NOT interval structure.

**What Rabinovich does**: Uses EA-formulas (exists-forall formulas, Definition 3.1) as a normal form for intervals. These directly encode the interval decomposition: witness points partition an interval, with types at points and along sub-intervals.

**Why the Lean choice fails**: Doets normal forms are excellent for the bridge theorem (Lemma 1.1) and for depth-based reasoning. But they do NOT encode the interval structure that Rabinovich's proof manipulates. Without EA-formulas, there is no way to express the key operations: splitting an interval at a new point, reducing the witness count, or taking the negation of an interval-typed formula.

**What would need to change**: Either:
(a) Define EA-formulas as a new type in Lean and prove the equivalence to NF, or
(b) Find a way to encode the interval-splitting argument directly in terms of NFs.

Option (b) is what the Lean code has been trying to do, unsuccessfully. Option (a) is the faithful translation.

---

## Section 5: Refactoring Specification

### 5.1 Option A: Full Literature Alignment (Recommended)

This option implements Rabinovich's proof faithfully.

#### 5.1.1 New Definitions Needed

**EA-Formula Type** (new file: `EAFormula.lean`)
```lean
/-- Exists-forall formula over signature sig.
    Represents an interval decomposition with n+1 witness points. -/
structure EAFormula (sig : MonadicSignature) where
  n : Nat  -- number of internal witness points
  alphas : Fin (n + 2) → MonadicFormula sig 1  -- point types (alpha_j)
  betas : Fin (n + 1) → MonadicFormula sig 1   -- interval types (beta_j)
  -- free variable positions: z_0 = x_{i_0}, z_1 = x_{i_1}
  freevar_pos : Fin 2 → Fin (n + 2)
```

**EA-Formula Evaluation** (in `EAFormula.lean`)
```lean
noncomputable def ea_eval (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (ea : EAFormula sig) : Prop :=
  ∃ (xs : Fin (ea.n + 2) → M.carrier),
    xs (ea.freevar_pos 0) = z0 ∧
    xs (ea.freevar_pos 1) = z1 ∧
    (∀ i j, i < j → xs i < xs j) ∧
    (∀ j, eval_1var M (xs j) (ea.alphas j)) ∧
    (∀ j, ∀ y, xs j < y → y < xs (j + 1) → eval_1var M y (ea.betas j))
```

**V-EA Formula** (in `EAFormula.lean`)
```lean
def VEAFormula (sig : MonadicSignature) := List (EAFormula sig)

def vea_eval (M : OrderedMonadicStructure sig) (z0 z1 : M.carrier)
    (vea : VEAFormula sig) : Prop :=
  ∃ ea ∈ vea, ea_eval M z0 z1 ea
```

Estimated: ~200 lines

#### 5.1.2 Closure Properties (Lemma 3.2, 3.4)

**File**: `EAFormulaClosure.lean`

Theorems:
- `ea_conj_to_vea`: Conjunction of two EA-formulas is a V-EA formula.
- `vea_closed_disj`: V-EA closed under disjunction.
- `vea_closed_conj`: V-EA closed under conjunction.
- `vea_closed_exists`: V-EA closed under existential quantification.

Estimated: ~300 lines

#### 5.1.3 V-EA to TL Conversion (Proposition 3.5)

**File**: `EAToTL.lean`

Theorem:
```lean
theorem vea_1var_to_tl (vea : VEAFormula sig) (h : has_one_freevar vea) :
    ∃ A : Formula, ∀ M t, temporal_truth M atomMap t A ↔ vea_eval_1var M t vea
```

Proof: Direct construction using nested Until/Since as in paper (p. 5).

Estimated: ~250 lines

#### 5.1.4 INF Formula (Equation 5.2-5.3)

**File**: `INFFormula.lean`

```lean
def inf_formula (P : Formula) : Formula :=
  -- z_0 < r_0 < z_1 AND (forall y in (z_0, r_0)) not P(y)
  -- AND (P(r_0) OR K+(P)(r_0))
  -- Expressed in TL using Until/Since
```

Theorem:
```lean
theorem inf_formula_correct (M : OrderedMonadicStructure sig)
    (h_dc : DedekindComplete M)
    (z0 z1 : M.carrier) (h : z0 < z1)
    (P_holds : ∃ z ∈ Set.Ioo z0 z1, P_eval M z) :
    ∃ r0, z0 < r0 ∧ r0 ≤ z1 ∧ ... -- defines r0 as infimum
```

Note: This requires Dedekind completeness, not Prior axioms. The Lean formalization currently uses Prior-UZ/SZ instead. For discrete structures (the current formalization's target), Dedekind completeness holds trivially, and Prior-UZ/SZ may suffice. But the INF construction is cleaner and more faithful.

Estimated: ~200 lines

#### 5.1.5 Lemma 5.3 (All betas True)

**File**: `EANegationBase.lean`

```lean
theorem neg_ea_all_betas_true (n : Nat)
    (Ps : Fin n → MonadicFormula sig 1) (z0 z1 : M.carrier) :
    ¬(∃ x_1 ... x_n in (z0, z1), P_i(x_i)) ↔ vea_eval ... O_n
```

Proof by induction on n, using INF formula.

Estimated: ~300 lines

#### 5.1.6 Corollary 5.4

**File**: `EANegationCorollary.lean`

```lean
theorem neg_partial_ea_vea (ea : EAFormula sig) :
    -- ¬∃z, ea_eval M z0 z z1 ea is V-EA
```

Proof using Lemma 5.3 + F_i := alpha_i AND (beta_{i+1} Until F_{i+1}).

Estimated: ~200 lines

#### 5.1.7 Lemma 5.1 (Full Negation Closure)

**File**: `EANegationFull.lean`

```lean
theorem neg_ea_is_vea (ea : EAFormula sig) :
    ¬(ea_eval M z0 z1 ea) ↔ vea_eval M z0 z1 (neg_ea_to_vea ea)
```

Proof by induction on n, with 3 cases (endpoint failure, guard success, INF splitting).

Estimated: ~500 lines

#### 5.1.8 Proposition 4.2 and 4.3

**File**: `FOMLOToVEA.lean`

```lean
theorem fomlo_to_vea (phi : MonadicFormula sig n) :
    ∃ vea : VEAFormula sig, ∀ M env, eval M env phi ↔ vea_eval ...
```

Proof by structural induction, using Lemma 5.1 for negation.

Estimated: ~200 lines

#### 5.1.9 Summary

| Component | New/Modified | Estimated Lines |
|-----------|-------------|----------------|
| EAFormula.lean | New | ~200 |
| EAFormulaClosure.lean | New | ~300 |
| EAToTL.lean | New | ~250 |
| INFFormula.lean | New | ~200 |
| EANegationBase.lean | New | ~300 |
| EANegationCorollary.lean | New | ~200 |
| EANegationFull.lean | New | ~500 |
| FOMLOToVEA.lean | New | ~200 |
| KampPrior.lean | Modified (rewire) | ~50 |
| **Total new code** | | **~2200** |

**Existing code preserved**: ALL existing sorry-free code (NormalForm.lean, doets_lemma_1_1, nf_characterizable_temporal_prior_classical, charPart_zero/succ, existPart_zero, KampBypass k=0 case, etc.) remains intact. The EA machinery provides an ALTERNATIVE path to Kamp's theorem that replaces the sorry-containing PriorComposition.lean path.

**Existing code deleted/deprecated**: PriorComposition.lean's sorry-containing theorems (`prior_nonconstenv_2var_agree_until/since`, `nvar_transfer_from_1var_agree`). The sorry-free infrastructure in PriorComposition.lean (exist_transfer_from_full_agree, reconstruction_depth_agree, etc.) may still be useful.

### 5.2 Option B: Minimal Patch (Prior Composition Fix)

This option keeps the current architecture and tries to close the PriorComposition.lean sorrys.

**What must be proved**: For the Until zone (t < x), given:
- depth-(K+2) 1-var agreement at x/x' and t/t'
- w in M with nf_eval_nf M (K+1) 3 [w,x,t] sub_nf
- Prior-UZ/SZ on both M and N
- CharPart formulas at depths d <= K+1

Find w' in N with nf_eval_nf N (K+1) 3 [w',x',t'] sub_nf.

**Zone analysis for w relative to x and t** (5 cases):
1. w < t: Use cross_extend_bwd from h_t. Get w' with depth-K 2-var agreement at [w,t]/[w',t']. But this gives depth K, not K+1, and only 2-var, not 3-var.
2. w = t: Use t' directly. Need to show [t',x',t'] satisfies sub_nf.
3. t < w < x: THE HARD CASE. Must find w' with t' < w' < x' AND matching 3-var NF.
4. w = x: Use x' directly.
5. x < w: Use cross_extend_bwd from h_x.

**For Case 3**: The approach would need:
- Use CharPart at depth K+1 to get a temporal formula A_w characterizing w's 1-var type.
- A_w holds at w, which is strictly between t and x.
- On M, by Prior-UZ, there is a FIRST occurrence of A_w above t. Call it w_first. Then w_first <= w < x.
- On N, by Prior-UZ applied to the same formula A_w (which has the same temporal semantics), there is a first occurrence of A_w above t'. Call it w'. Then t' < w'.
- Show w' < x' (this is the hard part -- Prior-UZ gives first occurrence but does not bound it).

**Why this is hard**: Even if w' has the right 1-var type, we need it to have the right ORDER relative to x' (w' < x'). The Prior-UZ axiom guarantees a first occurrence above t', but this first occurrence could be AT or ABOVE x'. There is no structural guarantee that w' < x'.

**Status**: This approach has been attempted for 10+ dispatches without success. The fundamental issue is that 1-var NF agreement at individual points does not determine relative position, and the Prior axioms do not provide the right tool for zone placement.

**Recommendation**: Option B is likely not viable. The 10+ failed attempts confirm that cross-structure transfer on non-constant environments is the wrong abstraction for this problem.

### 5.3 Option C: Hybrid (EA Negation in NF Framework)

This option encodes Rabinovich's negation closure argument within the existing NF framework, without introducing EA-formulas as a separate type.

**Key insight**: The Lean proof already has CharPart (temporal characterization of each 1-var NF type). Rabinovich's Case 3 introduces a splitting point via INF and reduces n. In the NF framework, this corresponds to: given a 2-var NF sub_nf at depth k+1 with endpoints [x, t] in the Until zone, the quantifier condition asks about 3-var NFs. The negation of the 2-var EA pattern can be expressed as a V-EA formula via:

1. **Case 1** (not alpha_0(t) or K+(not beta_1)(t)): the endpoint t fails the pattern. This is directly expressible in TL.
2. **Case 2** (beta_1 holds everywhere in (t, x)): no witness for x_1. Reduces to a 1-var existential (Corollary 5.4 analog).
3. **Case 3**: Introduce z = first point above t where beta_1 fails (via Prior-UZ applied to neg(beta_1)). This splits the interval into [t, z] and [z, x], each with FEWER witnesses.

**How to implement in NF framework**: Instead of transferring witnesses cross-structure, work WITHIN each structure to show that the existential (or its negation) is TL-expressible. This is exactly what the KampBypass k=0 case already does (VecEA decomposition). The k>0 case needs the same treatment but with depth induction.

**New theorem needed**:
```lean
theorem neg_2var_exist_is_tl (k : Nat)
    (char_fn : ∀ d, d ≤ k → NormalForm sig d 1 → Formula)
    (char_correct : ...)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k+1) 2) :
    ∃ A : Formula, ∀ M h_UZ h_SZ t,
      (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
      (temporal_truth M atomMap t A ↔
       ¬∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf)
```

**Proof sketch** (by induction on k, then on the "witness structure" encoded in sub_nf):
- Extract the zone (Until/Since/Eq) from sub_nf's atom assignment.
- For the Until zone (x > t):
  - The 2-var existential asks: "exists x > t with specific predicates AND specific depth-k quantifier conditions."
  - Case 1: If the pattern requires predicates at t that don't match parent_atoms, the existential is trivially false. Formula: True (negation is True).
  - Case 2: If the interval type beta_1 = char_fn(...) holds everywhere above t (i.e., Box(char_fn(...))), there's no "first failure point." The existential reduces to a 1-var condition.
  - Case 3: There exists a first failure of beta_1 above t (via Prior-UZ). Split the interval there. Apply IH with fewer witnesses.

This approach avoids cross-structure transfer entirely and works within a single structure, matching Rabinovich's method.

**Estimated effort**:
- ~400 lines for the single-structure negation closure theorem
- ~200 lines for INF/splitting point construction using Prior-UZ
- ~100 lines for rewiring KampBypass to use the new theorem
- ~50 lines for cleanup of PriorComposition.lean sorrys

**Total**: ~750 lines of new code, no new types, minimal infrastructure change.

---

## Section 6: Minimal Refactoring Plan

**Recommended approach**: Option C (Hybrid). It is the smallest change that restores literature alignment while preserving all existing infrastructure.

### Phase 1: Prior-UZ Splitting Point (INF analog)

**Prerequisite**: None.
**Files affected**: New file `Kamp/PriorSplitting.lean` (~200 lines).
**What**: Define and prove correct a "splitting point" theorem: given that a temporal formula A holds somewhere in (t, x), Prior-UZ gives a FIRST occurrence s of A in (t, x) (or at x). This is the analog of Rabinovich's INF formula for Prior structures.

```lean
theorem prior_first_above (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (t x : M.carrier) (h : t < x)
    (A : Formula) (h_exists : ∃ s, t < s ∧ s ≤ x ∧ temporal_truth M atomMap s A) :
    ∃ s, t < s ∧ s ≤ x ∧ temporal_truth M atomMap s A ∧
      ∀ r, t < r → r < s → temporal_truth M atomMap r A.neg
```

**Whether existing sorry-free code is affected**: No.

### Phase 2: Single-Structure 2-var Existential TL Characterization

**Prerequisite**: Phase 1.
**Files affected**: New file `Kamp/SingleStructureExist.lean` (~400 lines).
**What**: Prove that the 2-var existential (exists x, nf_eval_nf M (k+1) 2 ...) is TL-characterizable on Prior structures, by working WITHIN a single structure. Induction on k, then case analysis on the interval structure (Rabinovich's Cases 1-3). Uses Phase 1 for the splitting point.

```lean
theorem single_structure_exist_part (k : Nat)
    (char_fn : ∀ d, d ≤ k → NormalForm sig d 1 → Formula)
    (char_correct : ...)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k+1) 2) :
    ∃ A : Formula, ∀ M h_UZ h_SZ t,
      (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
      (temporal_truth M atomMap t A ↔
       ∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf)
```

**Whether existing sorry-free code is affected**: No.

### Phase 3: Rewire KampBypass k>0 Case

**Prerequisite**: Phase 2.
**Files affected**: `Kamp/KampBypass.lean` (~100 lines modified).
**What**: Replace the `prior_2var_transfer_until/since` calls in `existPart_succ_n1_bypass` (lines 646, 713) with calls to `single_structure_exist_part`. This eliminates the dependency on PriorComposition.lean's sorry-containing theorems.

The key change: instead of the current approach (find a reference structure M0, then transfer the existential cross-structure), use `single_structure_exist_part` to directly characterize the existential within each structure independently.

**Whether existing sorry-free code is affected**: The k=0 case (existPart_succ_n1_bypass_k0) is NOT affected. Only the k>0 (succ k') branch of existPart_succ_n1_bypass is modified.

### Phase 4: Cleanup PriorComposition.lean

**Prerequisite**: Phase 3 (must verify no remaining callers).
**Files affected**: `Kamp/PriorComposition.lean` (~50 lines).
**What**: Mark the sorry-containing theorems (`prior_nonconstenv_2var_agree_until/since`, `nvar_transfer_from_1var_agree`) as deprecated or delete them. Keep the sorry-free infrastructure (`exist_transfer_from_full_agree`, `reconstruction_depth_agree`, `depth0_agree_from_higher`, `cross_2nd_1var_from_2var`, `prior_second_1var_from_2var_until/since`).

**Whether existing sorry-free code is affected**: No sorry-free theorems are modified; only sorry-containing ones are removed.

### Dependency Order

```
Phase 1 (PriorSplitting.lean)
    |
    v
Phase 2 (SingleStructureExist.lean) -- uses Phase 1
    |
    v
Phase 3 (KampBypass.lean modification) -- uses Phase 2
    |
    v
Phase 4 (PriorComposition.lean cleanup) -- verification only
```

### Summary

| Phase | Type | Lines | Files | Sorry-free code affected? |
|-------|------|-------|-------|---------------------------|
| 1 | New code | ~200 | 1 new | No |
| 2 | New code | ~400 | 1 new | No |
| 3 | Modification | ~100 | 1 existing | No (only sorry-dependent branch) |
| 4 | Cleanup | ~50 | 1 existing | No (only sorry-containing code removed) |
| **Total** | | **~750** | 2 new + 2 modified | **No** |

---

## Appendix A: Adversarial Self-Verification

### Challenged Claims

1. **Claim**: "Rabinovich does NOT prove composition by transferring witnesses between structures."
   - **Verification**: Confirmed by re-reading Sections 3-5. Every theorem is stated and proved within a single structure class (Dedekind complete chains). The phrase "cross-structure" does not appear. The proof works by syntactic manipulation of formulas (EA to V-EA), not by semantic transfer between models.
   - **Status**: VERIFIED.

2. **Claim**: "The wrong induction parameter (depth k vs witness count n) is a root cause."
   - **Verification**: The Lean proof's CharPart/ExistPart induction on k is NOT inherently wrong -- it is a valid proof strategy. However, the difficulty arises specifically in ExistPart(k+1) where the cross-structure transfer approach fails. If the single-structure approach (Option C) is used, the induction on k should work fine, because within a single structure the quantifier conditions at depth k+1 can be handled via CharPart at depth k.
   - **Revised assessment**: The induction on k is not the root cause per se. It is the COMBINATION of induction on k WITH cross-structure transfer that creates the problem. Induction on k with single-structure negation closure (Option C) should work.
   - **Status**: REVISED.

3. **Claim**: "Option B (patching PriorComposition) is not viable."
   - **Verification**: 10+ dispatch attempts have failed. The fundamental issue (1-var agreement doesn't determine zone placement) has been documented with counterexamples. However, it is possible that a sufficiently clever use of Prior-UZ/SZ could close the gap.
   - **Counter-argument**: If Prior-UZ gives the first occurrence of a CharPart formula above t, and we can show this first occurrence is below x (using the fact that x itself satisfies a different CharPart formula), then zone placement IS possible. The question is whether the first occurrence of A_w above t' is necessarily below x'. This requires showing that x' does NOT satisfy A_w (which follows from x and x' having different 1-var types from w and w'). So Option B may actually be viable IF the argument is structured correctly.
   - **Status**: PARTIALLY REVISED -- Option B might work but requires a specific insight about type separation. Option C remains more reliable.

4. **Claim**: "Option C requires ~750 lines."
   - **Verification**: This is an estimate based on the complexity of similar proofs in the codebase (KampBypass k=0 is ~500 lines, KampBypassUntil/Since are ~400 lines each). The single-structure approach is simpler than cross-structure transfer, so 750 lines is plausible. However, the INF/splitting point construction (Phase 1) could be shorter (~100 lines) or longer (~300 lines) depending on the formalization details.
   - **Status**: PLAUSIBLE but uncertain (range: 500-1000 lines).

### Uncertain Claims

- **Confidence 70%**: Option C will succeed without introducing new sorry positions.
- **Confidence 90%**: Option A would succeed but is too large for a single task dispatch.
- **Confidence 50%**: Option B could be made to work with the type-separation insight.

### Recommendations Modified After Verification

1. Added note that induction on k is not the root cause in isolation; it is the combination with cross-structure transfer.
2. Added note that Option B might be viable via type separation, but remains higher risk.
3. Option C remains the recommendation, with the caveat that Phase 2 (the main theorem) may be harder than estimated if the case analysis becomes complex.
