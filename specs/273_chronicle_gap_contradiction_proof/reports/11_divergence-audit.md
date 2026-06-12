# Divergence Audit: Task 273

**Date**: 2026-06-12
**Session**: sess_1781193902_83bc5c
**Purpose**: Identify the specific formalization mistakes that have deflected 5+ proof attempts on the backward direction of the negation closure / 2-var existence formula.

---

## 1. Verdict on the Prime Suspect: Rank/Depth Drop

### The Literature

Three composition results are in play, and they have DIFFERENT depth behavior:

**Doets 1989 Lemma 1.4** (p. 227):
> If for all i in I, m(i) =^n m'(i), then Sigma_{i in I} m(i) =^n Sigma_{i in I} m'(i).

**Same n on both sides. No rank drop.** This composes ordered sums pointwise -- each summand is n-equivalent to a corresponding summand, and the ordered sums are n-equivalent.

**Doets 1989 Lemma 1.5** (p. 227):
> Suppose I and J are ordered sets with m(i) for i in I and m'(j) for j in J, such that (*) (I, {i|m(i) |= sigma}) =^n (J, {j|m'(j) |= sigma}) for sigma the set of n-characteristics. Then Sigma_{i in I} m(i) =^n Sigma_{j in J} m'(j).

**Same n. No rank drop.** But requires n-equivalence of the INDEX STRUCTURES (I and J), not just pointwise.

**Libkin 2004 Lemma 3.7** (p. 62-66 of extract):
> If L_1^{<=a} equiv_k L_2^{<=b} and L_1^{>=a} equiv_k L_2^{>=b}, then (L_1, a) equiv_{k-1} (L_2, b).

**DROP from k to k-1.** This composes by splitting at a NAMED point and deduces equivalence with that point as a new constant. Naming costs one round.

### Why the Distinction Matters

The Libkin rank drop occurs because naming a point in an EF game costs one round. In the NormalForm framework, our NfComposition.lean theorem `nf_3var_from_1var_nfs` asks a question that corresponds to the Doets setting (pointwise composition), NOT the Libkin setting (naming a new constant). Specifically:

**Our theorem** (NfComposition.lean:39-55):
```lean
theorem nf_3var_from_1var_nfs :
    forall (k : Nat) (y1 x1 t1 y2 x2 t2 : M.carrier)
    (h_y : nf_characteristic M (k + 1) 1 (fun _ => y1) =
           nf_characteristic M (k + 1) 1 (fun _ => y2))
    (h_x : nf_characteristic M (k + 1) 1 (fun _ => x1) =
           nf_characteristic M (k + 1) 1 (fun _ => x2))
    (h_t : nf_characteristic M (k + 1) 1 (fun _ => t1) =
           nf_characteristic M (k + 1) 1 (fun _ => t2))
    (h_ord : ...matching orders...),
    nf_characteristic M k 3 (Fin.cons y1 (Fin.cons x1 (fun _ => t1))) =
    nf_characteristic M k 3 (Fin.cons y2 (Fin.cons x2 (fun _ => t2)))
```

This IS correctly stated with a depth offset: depth-(k+1) data on 1-var NFs produces depth-k conclusion on 3-var NFs. The "+1" on the hypotheses is the "budget" that covers the quantifier step.

### Verdict: The same-depth claim in report 10 is WRONG in its reasoning but the THEOREM STATEMENT is actually correct

Report 10 (adversarial verification, lines 440-445) claimed "no rank drop" because "variables are already named." This reasoning is wrong -- the issue is not about naming but about the quantifier induction step. But the theorem statement `nf_3var_from_1var_nfs` already HAS the offset: it uses depth-(k+1) hypotheses and a depth-k conclusion. **The offset is the "+1" in `nf_characteristic M (k + 1) 1`.**

So the prime suspect (same-depth composition) is NOT the root cause. The theorem is correctly stated.

### The REAL problem

The real problem is in the **quantifier step of the composition proof** (NfComposition.lean:106,108). The goal state at the sorry (from lean_goal) is:

```
Given: z witnessing sub4 at (z, y1, x1, t1) in context 1
Goal:  exists z', z' witnessing sub4 at (z', y2, x2, t2) in context 2
```

With hypotheses giving depth-(k+2) 1-var NF agreements for y1/y2, x1/x2, t1/t2.

The transfer requires finding a single z' that simultaneously matches z's relationship to ALL THREE points y2, x2, t2. The depth-(k+2) 1-var NF of y1 encodes which depth-(k+1) 2-var NFs exist at (z,y1), giving z' with same 2-var NF at (z',y2). Similarly for x and t. But these yield THREE DIFFERENT witness points z', z'', z''', not a single one.

This is NOT a depth offset problem. It is the **witness merging problem**: the composition lemma for ordered sums works by the Doets game argument (the second player responds in the SAME summand), which is available only when the structure is literally an ordered sum. In NfComposition, the environment (y,x,t) does not decompose the model into an ordered sum -- y is just a point in the linear order, and the model is not partitioned into summands indexed by a 3-element set.

---

## 2. How the Published Hard Direction Really Works

### Rabinovich 2014 -- Structure of the Proof

Rabinovich's proof of Kamp's theorem (Theorem 4.4) proceeds:

1. **Proposition 4.3**: Every FO formula is equivalent (over Dedekind complete chains) to a disjunction of vec{E}A-formulas.
2. **Proposition 4.2** (Closure under negation): The negation of vec{E}A-formulas with at most two free variables is equivalent to a disjunction of vec{E}A-formulas.
3. **Theorem 4.4**: By Prop 4.3 + Prop 3.5 (vec{E}A to TL translation).

The proof of **Proposition 4.2** is in Section 5 (pages 7-11). This is the HARD direction. Its structure:

**Step 1**: Decompose psi(z0, z1) into three conjuncts: psi_0(z_0), psi_1(z_1), and phi(z_0, z_1) where phi is an interval formula (Definition 3.1 form with z_0 < x_1 < ... < x_n = z_1).

**Step 2** (Lemma 5.1): Show that the negation of interval formulas of the form (5.1) is equivalent to a disjunction of vec{E}A-formulas. This is the core.

**Step 3** (Lemma 5.3): Key induction -- negation of conjunction of bounded-interval conditions is equivalent to a vec{V}{E}A formula, using:
- INF formula (equation 5.2): locates the infimum r_0 of {z in (z_0, z_1) | P_1(z)}, which is definable by a vec{E}A formula using K^+(P_1)(r_0).
- Case analysis: interval empty, r_0 = z_0, r_0 in (z_0, z_1).
- Recursive reduction: each case reduces to a shorter interval or smaller number of conditions.

**Step 4** (Corollary 5.4): Handles the bounded existential quantification.

**Step 5** (Lemma 5.1 proof): Case analysis on which "boundary violation" causes the negation to hold:
- Case 1: endpoint property fails -- handled by atomic/vec{E}A formulas
- Case 2: interval condition fails below z_0 -- handled by Corollary 5.4
- Case 3: alpha_0(z_0) holds AND boundary property fails AND there exists a violation point -- handled by INF formula + recursive negation

### Critical observation: Rabinovich NEVER uses a general n-var composition lemma

The Rabinovich proof works entirely within the vec{E}A formula framework. The vec{E}A formulas have a built-in ordered structure: they explicitly name n existential witnesses in order (x_n > ... > x_1 > x_0) with interval conditions along each consecutive pair. The negation closure works by case analysis on WHERE the negation first manifests, using:

1. **Dedekind completeness** to locate boundary points (inf/sup of definable sets)
2. **K^+ and K^-** operators to characterize these boundary points
3. **Induction on the number of existential witnesses** (n), not on quantifier depth
4. **Boolean closure of vec{E}A formulas** under disjunction, conjunction, and existential quantification (Lemma 3.4)

The proof does NOT need:
- Feferman-Vaught composition for NormalForms
- Transfer of witnesses between different environments
- The `nf_3var_from_1var_nfs` theorem at all

### What replaces composition in Rabinovich's argument

Where our formalization needs composition (to show that a 3-var NF at (y,x,t) is determined by 2-var projections), Rabinovich's proof sidesteps this entirely by:

1. Working with vec{E}A formulas that already encode the ordered witness structure
2. Using the INF/SUP definability (Lemma 5.3) to locate critical points
3. Using Dedekind completeness / Prior-UZ/SZ to ensure these critical points exist
4. Recursing on the interval structure, not on NormalForm depth

The vec{E}A formula `[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)` encodes:
- n witnesses x_1 < ... < x_n in (z_0, z_1)
- Each x_i satisfies alpha_i
- Each interval (x_{i-1}, x_i) satisfies a universal condition beta_i

Its negation is handled by finding WHERE the first violation occurs, not by transferring NF-witnesses between contexts.

---

## 3. Divergence Table

| Object | Our Formalization | Literature | Status | Consequence |
|--------|------------------|------------|--------|-------------|
| **NormalForm sig k n** | Recursive: depth-0 = atom assignment, depth-(k+1) = atoms + (NF sig k (n+1) -> Bool) | Doets n-characteristic: conjunction of all rank-n sentences in n free variables | MATCHES | Correct isomorphism (doets_lemma_1_1 bridges them) |
| **P1(k)** | For each depth-k arity-1 NF, exists temporal Formula A equivalent on Prior structures | Rabinovich Prop 3.5 + Prop 4.3: every vec{E}A formula with one free var is equivalent to a TL formula | MATCHES | P1 at all depths follows from the literature |
| **P2(k)** | For each depth-k arity-2 NF sub_nf, exists Formula A such that A(t) iff exists x with nf_eval_nf M k 2 (x,t) sub_nf, on Prior structures | Rabinovich: vec{E}A formulas with 2 free vars have negations equivalent to disjunctions of vec{E}A formulas (Prop 4.2) | **STRONGER** | Our P2(k) asks for a formula characterizing a SINGLE 2-var NF class. Rabinovich only needs that the negation of a vec{E}A formula is equivalent to a DISJUNCTION of vec{E}A formulas. Our statement is strictly stronger -- it asks for each NF class individually, while Rabinovich gets disjunctions. However, this is not a problem: if P2(k) holds, Rabinovich's result follows. The issue is that P2(k) requires more than what Rabinovich's proof technique directly provides. |
| **Composition** (nf_3var_from_1var_nfs) | Depth-k 3-var NF from depth-(k+1) 1-var NFs + order, proved by induction on k with quantifier witness transfer | Doets 1.4: ordered sum composition preserves n-equivalence (but requires the model to BE an ordered sum). Libkin 3.7: composition at a split point with rank drop. | **DIFFERENT** | Our theorem requires witness transfer in a model that is NOT an ordered sum. Doets 1.4 requires the model to be literally partitioned into ordered summands. Our setting has named points in a linear order, not a partition into summands. The proof strategy (find z' in context 2 matching z in context 1) requires a game argument that Doets 1.4/1.5 provides for ordered sums but that does NOT directly transfer to our setting. |
| **Backward proof strategy** | Extract witness from Until/Since formula, use composition to recover full 2-var NF | Rabinovich: locate INF/SUP of definable sets, case-split on boundary behavior, recurse on interval structure | **DIFFERENT** | Our backward proof tries to use composition to bridge from 1-var NF data to 2-var NF data. Rabinovich never needs this bridge -- he works entirely within vec{E}A formulas. |
| **nf_exist_formula_nested** | Builds nested Until/Since encoding the FULL sub_nf including quantifier conditions via interval witnesses | Rabinovich Notation 5.2: bracket notation for vec{E}A formulas, no nested temporal formula construction needed | **DIFFERENT** | Our formula construction tries to encode NormalForm quantifier conditions as nested temporal formulas. Rabinovich's vec{E}A formulas are ALREADY in the right form -- they don't need to encode NFs, because the proof works at the formula level, not the NF level. |
| **Prior-UZ/SZ usage** | Used in backward direction to extract witnesses from formula truth | Rabinovich: Dedekind completeness gives INF/SUP existence; Prior-UZ/SZ is our replacement for this | MATCHES (modulo DC vs Prior) | Correct usage pattern |

---

## 4. The Corrected Target

### Architecture Change Required

The fundamental problem is that our proof is structured as:

```
NF induction (on depth k) -> composition -> backward formula direction
```

But the published proof (Rabinovich) is structured as:

```
Formula induction (on vec{E}A structure) -> negation closure -> Kamp's theorem
```

These are different proof architectures. The NF-based approach requires a composition lemma that is genuinely hard (witness merging across environments). The formula-based approach avoids composition entirely by working with vec{E}A formulas that already encode the ordered witness structure.

### The Corrected Statements

**Option A: Follow Rabinovich faithfully (recommended)**

Replace `nf_2var_exist_formula_prior` and the entire NfComposition approach with:

1. **vec{E}A formula type**: Define a type representing vec{E}A formulas (as in Def 3.1), or encode them as a subset of existing `Formula`.

2. **Closure lemma** (Lemma 3.4): vec{V}{E}A formulas are closed under disjunction, conjunction, and existential quantification.

3. **Negation closure** (Proposition 4.2): The negation of a vec{E}A formula with at most 2 free variables is equivalent to a disjunction of vec{E}A formulas over Dedekind complete chains (or Prior structures).

4. **Kamp's theorem** (Theorem 4.4): Every FOMLO formula with one free variable is equivalent to a TL(Until,Since) formula over Dedekind complete chains (or Prior structures).

The key lemma that replaces our sorry chain is Lemma 5.1: the negation of an interval formula is equivalent to a vec{V}{E}A formula. Its proof uses:
- INF definability (Lemma 5.3, equation 5.2)
- Corollary 5.4 (bounded existential negation)  
- Case analysis on boundary violations
- Induction on n (number of interval witnesses), NOT on k (quantifier depth)

**Option B: Fix the NF approach by proving the composition lemma**

If we want to keep the NF-based approach, the composition lemma `nf_3var_from_1var_nfs` must be proved. The quantifier step requires:

Given z witnessing sub4 at (z, y1, x1, t1), find z' witnessing sub4 at (z', y2, x2, t2).

The correct proof strategy (from Doets's game argument): z falls in one of the intervals determined by (y1, x1, t1). By h_ord, the same interval structure exists around (y2, x2, t2). The depth-(k+1) 1-var NF hypothesis for the relevant boundary point(s) ensures the interval in context 2 has the same "interval type" as in context 1, so a z' with the right properties exists.

But this argument requires formalizing:
- The interval decomposition of the model at the named points
- The fact that the depth-(k+1) 1-var NF encodes all depth-k 2-var existentials (this is what the "+1" buys)
- A witness existence argument within each interval

This is a substantial proof (estimated 400-600 lines) that has been attempted and failed 5 times. The failures stem from the witness merging problem: getting three separate z' witnesses (one per boundary point) and needing to merge them into one.

**Option C: Hybrid -- use the existing master_induction but route through Rabinovich for P2(k+1)**

Keep P1(k) via master_induction (already sorry-free). For P2(k+1), instead of proving the backward direction of `nf_exist_formula_nested`, prove it by:
1. Translating the 2-var existence statement to a vec{E}A formula
2. Using Rabinovich's negation closure (Prop 4.2) to show it's a vec{V}{E}A formula
3. Using Prop 3.5 to translate back to TL(U,S)

This requires formalizing vec{E}A formulas and Prop 4.2, but avoids the composition lemma entirely.

### Proof Skeleton Mapped to Published Lemmas

For Option A (recommended):

| Step | Our File | Published Lemma | Content |
|------|----------|----------------|---------|
| 1 | New: VecEAFormula.lean | Def 3.1 | Define vec{E}A formula type |
| 2 | New: VecEAClosure.lean | Lemma 3.4 | Closure under disjunction, conjunction, exists |
| 3 | New: VecEATranslation.lean | Prop 3.5 | vec{V}{E}A -> TL(U,S) translation |
| 4 | New: INFFormula.lean | Eq 5.2, Lemma 5.3 | INF definability and interval negation |
| 5 | New: NegationClosure.lean (replace) | Prop 4.2 | Negation closure for 2-var vec{E}A |
| 6 | Existing: KampPrior.lean | Theorem 4.4 | Main result |

---

## 5. Postmortem: The 5 Deflections

### Deflection 1: Initial nf_exist_formula backward direction
**Mistake**: Assumed that the backward direction of `nf_exist_formula` (the simple Until/Since encoding) would work. It doesn't because the formula only encodes the 1-var NF of the witness x, not the full 2-var NF at (x,t).
**Root cause**: Conflation of 1-var NF with 2-var NF. The 1-var NF of x does not determine the 2-var NF of (x,t).

### Deflection 2: char_k vs char_{k+1} for interval witnesses  
**Mistake**: Used depth-k characteristic formulas for interval witnesses when depth-(k+1) was needed. The depth-k formula doesn't encode enough information to recover 2-var NFs via composition.
**Root cause**: Depth bookkeeping error. The composition requires the "+1" budget from the hypotheses.

### Deflection 3: nf_exist_formula_nested with guard encoding
**Mistake**: Tried to encode negative interval conditions (sub_nf.2(ssn)=false for interval ssn) in the guard of the Until formula. This was too strong -- it blocked legitimate witnesses.
**Root cause**: Misunderstanding of what negative conditions mean. sub_nf.2(ssn)=false means no y has the FULL 3-var NF ssn, not that no y has compatible predicates.

### Deflection 4: The composition lemma (nf_3var_from_1var_nfs)
**Mistake**: Stated the composition lemma and proved the base case and atom part, but the quantifier step requires witness merging (finding a single z' matching z's relationship to all three boundary points simultaneously). Multiple approaches tried (Options A, B, C in handoffs) all failed at the merging step.
**Root cause**: The theorem is TRUE but requires a sophisticated game-theoretic argument (Doets 1.4/1.5 style) that has not been successfully formalized. The argument requires showing that the model decomposes into intervals at the named points, and using the interval-wise IH. This is essentially reimplementing Doets's proof, which is the HARD direction that Rabinovich's entire paper is designed to simplify.

### Deflection 5: Cycling between composition fix and formula fix
**Mistake**: After the composition lemma failed, attempts alternated between fixing the formula (nf_exist_formula_nested tweaks) and fixing the composition (new hypotheses, new induction structures). Each fix addressed one symptom but exposed another.
**Root cause**: The fundamental architecture is wrong. The NF-based backward proof requires either (a) a working composition lemma (which is Doets's game argument and is hard to formalize) or (b) a completely different proof strategy (Rabinovich's formula-based approach). Tweaking within the existing architecture cannot solve the problem.

### Common Thread

All 5 deflections share the same root cause: **the formalization tries to prove the backward direction of an NF-to-formula correspondence by extracting NF data from formula truth, which requires composition to bridge between the formula's encoding (1-var NFs of witnesses) and the target (n-var NFs of tuples)**. This composition bridge is the exact content that Doets's game argument (or Rabinovich's negation closure) provides, and it has not been successfully formalized.

The published proofs avoid this bridge in two ways:
1. **Doets**: Proves composition directly via EF games (Lemma 1.4/1.5), but this is a substantial game-theoretic argument
2. **Rabinovich**: Sidesteps composition entirely by working with vec{E}A formulas that already encode the ordered witness structure, and proves negation closure by INF/SUP localization + case analysis

Our formalization needs to commit to one of these strategies rather than mixing NF-based and formula-based approaches.
