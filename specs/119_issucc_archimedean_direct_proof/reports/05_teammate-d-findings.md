# Teammate D Findings: Principled Path Synthesis

- **Task**: 119 - Prove IsSuccArchimedean via direct connectivity extraction
- **Teammate**: D (Principled Path Synthesis)
- **Round**: 5
- **Date**: 2026-05-10
- **Session**: sess_1778454477_cdc6ef

## Executive Summary

After a comprehensive reading of Burgess 1982, Reynolds 1992, Venema 1993, Xu 1988, Doets 1989, and the full ProofChecker codebase, I synthesize the mathematically correct completeness architecture for the hierarchy Base TM / Dense TM / Discrete TM / Complete TM. The core recommendation is:

**The codebase conflates two distinct concerns: the FRAME CLASS (ordered abelian group) and the COMPLETENESS PROOF STRATEGY (Burgess chronicle + transfer). The mathematically virtuous path is to separate them, following the literature's actual architecture.**

The key finding: **AddCommGroup in the `valid` definition is orthogonal to the completeness proof strategy.** Reynolds and Burgess prove completeness for classes of linear orders (arbitrary, dense, discrete, Dedekind-complete). AddCommGroup is a SPECIALIZATION that RESTRICTS the frame class. Completeness for the restricted class follows as a corollary of completeness for the broader class, provided the broader class's logic is a SUBSET of the restricted class's logic.

## 1. What Is the Right Axiom System for Each Level?

### 1.1 Burgess J0 (= Base TM)

Burgess's system J0 consists of:
- **7 axiom schemas** (A1a-A7a) plus their mirror images (A1b-A7b) = 14 schema families
- **Rules**: Substitution, Modus Ponens, Temporal Generalization (from phi infer G(phi) and H(phi))

Xu 1988 simplified this to **6 axiom schemas** (merging A1a+A2a into a combined monotonicity schema (1), using (3)/(4) for enrichment, dropping A4a, and retaining (7)/(8)/(9)/(10)/(11) from the linear extension). The "Burgess-Xu system" in the literature usually means Xu's streamlined 6-axiom version.

**Our codebase's BX system**: Contains 43 axiom constructors organized into 5 layers. The core temporal layer has the Burgess-Xu axioms (BX2/BX3 = monotonicity, BX4 = connectedness, BX5 = self-accumulation, BX6 = absorption, BX7 = linearity, BX13 = enrichment, BX14 = separation, BX10 = until-implies-F, BX11 = temporal linearity, BX12 = F-Until bridge). Plus propositional, S5 modal, modal-temporal interaction, and the uniformity axioms.

**What is NOT in Burgess J0 but IS in our system**:
- The 4 uniformity axioms (discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd)
- The S5 modal axioms (modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist)
- The modal-temporal interaction axioms (modal_future, temp_future)
- Seriality axioms BX1/BX1' (serial_future/past) -- these replace Burgess's implicit no-endpoints assumption

**Key observation**: The uniformity axioms are NOT part of Burgess's J0. They are sound on ordered abelian groups but NOT on all linear orders. They belong in a layer ABOVE the base system, specifically in the "Discrete TM" extension.

### 1.2 Dense TM

**Burgess**: J0 + density axiom `F'(top)` (= `K+(top)` in Reynolds notation = "there is no immediate successor").

**Reynolds US/R**: Burgess-Xu + density (`K+(top)`, `K-(top)`) + no endpoints (`F(top)`, `P(top)`) + Prior-U + Prior-S + Sep.

**Our codebase**: The dense case currently uses the base BX system without any explicit density axiom. The completeness proof for dense orders (in `dd_countermodel_chronicle_dense`) works because the Burgess chronicle construction produces a model on the rationals directly -- Cantor's theorem gives an order isomorphism from any countable dense linear order without endpoints to Q.

**Correct architecture**: Dense TM = Base TM + `F'(bot)` (density axiom, equivalent to `K+(top)` in Reynolds's notation: "for all future points, there is a still-closer one"). This axiom is `neg U(top, bot)` = "there is no immediate successor", or equivalently `G(F(top))` = "always in the future, there is a further future point". For our strict semantics, density is `neg (untl top bot)`.

### 1.3 Discrete TM

**Burgess**: J0 + discreteness axiom `G'(bot) /\ H'(bot)` (= `U(top,bot) /\ S(top,bot)` = "there exist immediate successors and predecessors everywhere").

**Reynolds US/Z**: Burgess-Xu + discreteness (`U(top,bot)`, `S(top,bot)`) + no endpoints (`F(top)`, `P(top)`) + **Prior-UZ** (`Fp -> U(p, neg p)`) + **Prior-SZ** (`Pp -> S(p, neg p)`).

**Venema BN**: BW + D, where BW = B + W, and B = Burgess system, W = `Fp -> U(p, neg p)`, D = discreteness `F(top) -> U(top,bot)`.

**Our codebase**: Uses BX + 4 uniformity axioms (discrete_symm, discrete_propagate). Does NOT include Prior-UZ.

**Critical discovery (from Round 4 analysis, confirmed here)**: The uniformity axioms are STRICTLY WEAKER than Prior-UZ. The counterexample is Z x Z with lexicographic order: this is a uniformly discrete ordered abelian group satisfying all four uniformity axioms, but Prior-UZ fails on it. Therefore:

**The current axiom system for discrete TM is INCOMPLETE for Z-models.** Adding Prior-UZ is necessary for completeness.

### 1.4 Complete TM (ℝ)

**Reynolds US/R**: Burgess-Xu + density + no endpoints + Prior-U + Prior-S + Sep.

**Our codebase**: Not yet implemented.

### 1.5 Summary Table

| Level | Axioms beyond base | Frame class | Complete for |
|-------|-------------------|-------------|-------------|
| Base TM | (none beyond BX + modal) | All linear orders | All linear orders |
| Dense TM | density: `neg U(top,bot)` | Dense linear orders | Q (via Cantor iso) |
| Discrete TM | discreteness: `U(top,bot) /\ S(top,bot)` + uniformity (4) + **Prior-UZ + Prior-SZ** | Archimedean discrete orders (= Z) | Z (via Reynolds/Venema) |
| Complete TM | density + Prior-U + Prior-S + Sep | Dedekind-complete orders | R (via Doets transfer) |

## 2. What Is the Right Completeness Proof Strategy for Each Level?

### 2.1 Base TM: Burgess construction on countable linear orders

**Strategy**: Given a BX-consistent formula phi, construct a countable linear model X via the Burgess omega chain construction. The model is built on rational coordinates (as a countable dense subset of R), with MCS labels at each point and DCS labels on intervals, satisfying conditions C0-C5.

**Status in codebase**: The chronicle construction in `ChronicleConstruction.lean` implements this. The construction produces `limit_dom` (a subset of Q) with `limit_f` (MCS labeling) and `limit_g` (DCS labeling).

### 2.2 Dense TM: Burgess + Cantor isomorphism to Q

**Strategy**: Start with the base construction. The limit model is countable, dense (because the chronicle inserts points densely into Q), and without endpoints. By Cantor's theorem, any countable dense linear order without endpoints is order-isomorphic to Q. Compose with the model labeling to get a model on Q.

**Status in codebase**: DONE (sorry-free). `dd_countermodel_chronicle_dense` implements this path.

### 2.3 Discrete TM: THE CRITICAL CASE

This is where the four approaches diverge:

**Approach A (current codebase attempt)**: Burgess chronicle -> limit_dom -> prove IsSuccArchimedean -> order isomorphism to Z -> model on Z. Blocked by IsSuccArchimedean.

**Approach B (Reynolds Section 10)**: Add Prior-UZ to axiom system -> Burgess chronicle -> limit model satisfies Prior-UZ -> contemporaneous equivalence classes have no gaps (Theorem 4 of Reynolds) -> apply discrete Doets transfer theorem (Theorem 9 of Reynolds) -> k-equivalent model on Z -> transfer formula.

**Approach C (Venema 1993 Theorem 4.3)**: Add axiom W (= Prior-UZ) -> Burgess construction -> BW-model is definably well-ordered (Lemma 4.1) -> apply Doets theorem (Theorem 3.8) -> k-equivalent well-ordered model -> add discreteness to get Z-model.

**Approach D (no transfer, direct)**: Prove IsSuccArchimedean directly from the omega chain construction properties, without adding any new axiom.

### 2.4 Complete TM: Burgess + Prior-U/S + Sep + Doets transfer to R

**Strategy (Reynolds Sections 4-9)**:
1. Burgess-Xu gives a rational-flowed model (Corollary 1)
2. Prior-U/S ensure "no definable gaps" (Theorem 4)
3. Sep ensures "dense singletons" in quotient by contemporaneous equivalence (Theorem 5)
4. Apply Doets theorem (Theorem 6): k-equivalent real-flowed model exists
5. Transfer formula

**Status in codebase**: Not implemented. Would require Prior-U, Prior-S, Sep axioms and Doets transfer.

## 3. Where Does AddCommGroup Enter?

### 3.1 In the Literature: NOWHERE

Burgess, Reynolds, Xu, Venema, and Doets work exclusively with linear orders. They never mention groups, addition, or translation invariance. The completeness theorems are:
- phi is satisfiable in **some linear order** (Burgess J0)
- phi is satisfiable in **Q** (dense case)
- phi is satisfiable in **Z** (discrete case, with Prior-UZ)
- phi is satisfiable in **R** (continuous case, with Prior-U/S/Sep)

None of these require the frame to be a group.

### 3.2 In the Codebase: EVERYWHERE

The `valid` definition in `Validity.lean` requires:
```
∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
```

The `TaskFrame` structure in `TaskFrame.lean` requires:
```
(D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

This means validity quantifies over ALL ordered abelian groups, not just linear orders. The task frame's `converse` axiom (`task_rel w d u <-> task_rel u (-d) w`) uses the group inverse, and `forward_comp` uses addition.

### 3.3 The Relationship Between Group Frames and Order Frames

**Key theorem (implicit in the codebase)**: If phi is valid on all linear orders, then phi is valid on all ordered abelian groups (because every ordered abelian group IS a linear order).

**Contrapositive**: If phi is NOT valid on some ordered abelian group, then phi is not valid on all linear orders.

**Consequence for completeness**: If we prove `BX |- phi iff phi is valid on all LINEAR ORDERS`, then we automatically get `BX |- phi implies phi is valid on all ORDERED ABELIAN GROUPS`. The converse (completeness for the group class) follows because the group class is a SUBCLASS: if phi is consistent with BX, then phi has a model on some linear order X (by Burgess). If X happens to be Q or Z or R, these are themselves ordered abelian groups, so phi has a group model.

**Therefore**: The AddCommGroup constraint in `valid` is COMPATIBLE with the Burgess completeness strategy. We do NOT need to restructure `valid`. The chain of reasoning is:
1. BX is complete for linear orders (Burgess-Xu Theorem 1)
2. Q, Z, R are ordered abelian groups
3. For dense case: consistent phi has Q-model = abelian group model
4. For discrete case: consistent phi has Z-model = abelian group model (with Prior-UZ)
5. For continuous case: consistent phi has R-model = abelian group model (with Prior-U/S/Sep)

### 3.4 Can We Prove Completeness WITHOUT AddCommGroup in valid?

**Answer**: We do not NEED to remove AddCommGroup from `valid`. The completeness theorems target SPECIFIC groups (Q for dense, Z for discrete, R for complete), all of which satisfy AddCommGroup. So completeness for the group-frame class follows from completeness for the specific target groups.

**But**: The current `valid_discrete` definition adds `IsSuccArchimedean` as a constraint. This is the root cause of the current difficulty. The question is whether IsSuccArchimedean is the RIGHT constraint, or whether something else (Prior-UZ soundness) would be more appropriate.

## 4. The Doets Transfer Theorem: What It Actually Says

### 4.1 Statement (Reynolds Theorem 6, adapted)

**Doets's theorem for dense orders without endpoints**: Suppose M is a temporal structure in a finite language whose flow of time is countable, dense, and without endpoints. Suppose further that for any contemporaneous equivalence relation ~ on M:
- (D1) the ~-classes do not end in gaps, and
- (D2) if M/~ is densely ordered, then M/~ has a dense set of singletons.

Then for all k < omega, there is a temporal structure with flow of time the real numbers satisfying the same monadic first-order sentences of quantifier depth at most k as M does.

**Doets's theorem for discrete orders without endpoints** (Reynolds Theorem 9): Suppose M is a temporal structure in a finite language whose flow of time is countable, discrete, and without endpoints. Suppose further that for any contemporaneous equivalence relation ~ on M, the ~-classes do not end in gaps.

Then for all k < omega, there is a temporal structure with flow of time the integers satisfying the same monadic first-order sentences of quantifier depth at most k as M does.

### 4.2 Can Doets Transfer Replace IsSuccArchimedean?

**YES, completely.** The Doets transfer gives k-equivalence between the limit model and Z (for the discrete case). For weak completeness (satisfiability of a single formula), k-equivalence for sufficiently large k suffices: the formula phi has a first-order table phi^c of bounded quantifier depth n. If the limit model satisfies exists x, phi^c(x), and the Z-model is (n+1)-equivalent to the limit model, then the Z-model also satisfies exists x, phi^c(x), giving a Z-model of phi.

**The key requirement**: The limit model must satisfy D1 (no gaps at equivalence class boundaries). For dense orders, Reynolds shows this follows from Prior-U/Prior-S (Theorem 4). For discrete orders, Reynolds shows this follows from Prior-UZ (using the discrete version of the argument, Theorem 9's proof at the end of Section 10).

### 4.3 Does Our Codebase's `valid` Definition Require an ACTUAL Z-Model?

**YES, it does.** The `valid_discrete` definition quantifies:
```
∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
```

This means completeness must produce a model on a type D satisfying all these constraints. The Doets transfer produces a model on Z (= Int in Lean), which satisfies ALL of these constraints via Mathlib instances. So the Doets transfer IS compatible with the `valid_discrete` definition -- we just need to produce a model on Int, which is what the transfer gives us (up to k-equivalence, which suffices for a single formula).

## 5. The Mathematically Virtuous Path

### 5.1 Why Prior-UZ Is Necessary

The current axiom system for discrete TM includes 4 uniformity axioms but NOT Prior-UZ. As shown in the Round 4 analysis:

- Z x Z_lex satisfies all BX axioms + all 4 uniformity axioms but NOT Prior-UZ
- Therefore BX + uniformity is INCOMPLETE for Z
- Prior-UZ is INDEPENDENT of BX + uniformity
- Prior-UZ IS valid on Z (Int has IsSuccArchimedean, which gives well-ordering above any point, which gives the minimum witness needed for Prior-UZ)

**Mathematical fact**: Prior-UZ is a THEOREM of "the US-logic of Z" (Reynolds proves this). Any complete axiomatization for Z must include it (or something from which it is derivable). The current axiom system is provably incomplete for the discrete case.

### 5.2 The Hierarchy of Axiom Dependencies

```
Base TM (= Burgess J0):
  BX axioms (monotonicity, enrichment, self-accumulation, absorption, linearity)
  + S5 modal + interaction + seriality
  COMPLETE FOR: all linear orders

Dense TM:
  Base TM + neg U(top,bot) (density: no immediate successor)
  COMPLETE FOR: Q (countable dense linear orders without endpoints)
  PROOF: Burgess chronicle + Cantor isomorphism

Discrete TM:
  Base TM + U(top,bot) /\ S(top,bot) (discreteness)
  + uniformity axioms (sound on ordered abelian groups, expressing uniform step size)
  + Prior-UZ: Fp -> U(p, neg p)  [NEW, REQUIRED]
  + Prior-SZ: Pp -> S(p, neg p)  [NEW, REQUIRED]
  COMPLETE FOR: Z
  PROOF: Burgess chronicle + Venema definable well-ordering + Doets discrete transfer

Complete TM:
  Dense TM + Prior-U + Prior-S + Sep
  COMPLETE FOR: R
  PROOF: Burgess chronicle + Reynolds no-gaps + Doets dense transfer
```

### 5.3 What Should Change in the Codebase

**MINIMUM CHANGE (recommended)**:

1. **Add Prior-UZ and Prior-SZ as axioms** in `Axioms.lean` (2 new constructors).

2. **Prove soundness of Prior-UZ on Int** in `Soundness.lean`. The proof: Given `Fp` at time t (Int), there exists s > t with p(s). Let s0 = min{u > t | p(u)}. This minimum exists because {u in Z | u > t and p(u)} is a nonempty subset of the well-ordered set {u in Z | u > t}. Then U(p, neg p) at t with witness s0: p(s0) holds, and for all u with t < u < s0, p(u) does not hold (by minimality), so neg p(u) holds.

3. **Restructure discrete completeness** to use the Venema/Reynolds strategy:
   - The limit model satisfies Prior-UZ (because it satisfies all axioms, including the newly added Prior-UZ)
   - By Venema Lemma 4.1 (adapted to discrete): every definable subset has a minimum (definable well-ordering)
   - By Reynolds Theorem 9 (discrete Doets): the limit model is k-equivalent to Z for all k
   - Transfer the formula to a Z-model (= Int-model)

4. **Remove IsSuccArchimedean from valid_discrete** (or keep it but derive it as a consequence of the completeness theorem rather than requiring it as an assumption on the frame class). Actually, IsSuccArchimedean should STAY in valid_discrete because it describes the correct frame class (ordered abelian groups isomorphic to Z). The completeness proof just needs to produce a model on Int, which has IsSuccArchimedean as a Mathlib instance.

5. **Remove the limitDomSubtype_isSuccArchimedean sorry entirely.** It is no longer needed because the completeness proof does not construct an order isomorphism from limit_dom to Z. Instead, it uses Doets transfer to get a k-equivalent Z-model.

### 5.4 Formalization Cost Assessment

| Component | Difficulty | Estimated LOC | Notes |
|-----------|-----------|---------------|-------|
| Prior-UZ/SZ axiom constructors | Trivial | 20 | 2 new constructors in Axioms.lean |
| Soundness of Prior-UZ on Int | Easy | 50-80 | Uses Nat.find or well-ordering of N |
| Venema Lemma 4.1 (definable well-ordering from W) | Medium-Hard | 150-250 | Stavi connective argument |
| Reynolds Theorem 9 (discrete Doets transfer) | Hard | 300-500 | Requires k-equivalence machinery |
| Integration with completeness | Medium | 100-150 | Rewire dd_countermodel_chronicle_nondense |
| **Total** | | **620-1000** | |

Compare to the current approach (proving IsSuccArchimedean for limit_dom directly): **UNKNOWN / possibly impossible** based on 20+ research rounds.

### 5.5 The Doets Transfer: What Must Be Formalized

The discrete Doets transfer (Reynolds Theorem 9) is simpler than the dense version (Reynolds Theorem 6) because:
- No separability argument needed (Sep axiom not required)
- The "very good" / "good" structure analysis is simpler for discrete orders
- The key argument reduces to: if the limit model has no gap at any contemporaneous equivalence class boundary, then every element is in the same equivalence class, which means the whole model is "very good", hence "good" (k-equivalent to an interval of Z).

Reynolds's proof of Theorem 9 is remarkably short (less than a page). The key step: in a discrete order without endpoints, if ~-classes never end at gaps, then every two adjacent elements (in the successor sense) must be in the same class. This is because the class of element a includes succ(a): if not, the class of a would end at the "gap" between a and succ(a), but there IS no gap -- succ(a) is the immediate successor, and the class boundary would be AT succ(a), which means the class ends at a definite point, not at a gap. So all elements are equivalent, meaning the whole model is one class, hence "very good", hence "good".

**This is the key simplification**: In the discrete case, the Doets transfer is almost trivial once you have "no gaps at class boundaries." The hard part is proving "no gaps at class boundaries" from Prior-UZ, which is Reynolds's adaptation of his Sections 5-6 arguments to the discrete setting.

## 6. What Does Xu 1988 Add?

Xu's primary contribution is:

1. **Simplified axiom set**: Reduced Burgess's 7+7 axiom schemas to 6+6 (4 base axioms shared across all frame classes, plus frame-specific axioms). The "missing" axiom A4a is derivable from the others.

2. **General (non-linear) completeness**: Extended Burgess's results to non-linear frames (transitive frames, left-connected frames). This is relevant for branching time logics but not for our linear-time setting.

3. **Incompleteness results (Section 4)**: Showed that many natural axiom sets are INCOMPLETE for their intended frame classes when using U,S instead of G,H. Key examples:
   - Transitivity (FFp -> Fp) does NOT derive U(p,q) -> U(p,U(p,q)) (the accumulation axiom)
   - Right-connectedness plus S-accumulation do NOT derive the linearity axiom (10)
   - Some axiom sets with U(top,bot) (discreteness) + transitivity + circulation are consistent but have NO frames at all

**Relevance to our project**: Xu's incompleteness results (Theorems 4.1-4.11) provide useful NEGATIVE guidance: they tell us which axiom combinations are insufficient. In particular, Xu's Theorem 4.6 shows that `{FFp->Fp, U(top,bot), FFGp->p}` is consistent but frame-less. This is a warning about discrete axiom systems: adding U(top,bot) without the right accompanying axioms can lead to pathological systems.

## 7. What Does Burgess 1984 Add?

The file `Burgess_1984_Basic_Tense_Logic.md` in the repository appears to be the Bull/Segerberg chapter on basic modal logic from the Handbook of Philosophical Logic, not the Burgess chapter on basic tense logic. The relevant Burgess survey would be "Basic Tense Logic" (Handbook of Philosophical Logic, Vol. II, pp. 89-133, 1984). The key content from that survey:

- Systematic treatment of axiom systems for G,H tense logics
- Canonical model construction for various frame classes
- The relationship between temporal axioms and first-order frame conditions
- Extension to U,S with references to Burgess 1982

For our purposes, the primary references remain Burgess 1982 (the completeness proof) and Xu 1988 (the simplified axiom system).

## 8. Definitive Recommendation

### The Mathematically Correct Architecture

```
                    Base TM
                   /       \
              Dense TM    Discrete TM
                   \       /
                 Complete TM
```

Each level adds axioms that RESTRICT the frame class. Each has a SELF-CONTAINED completeness proof following the same template:
1. Burgess chronicle construction -> countable model
2. Frame-class-specific properties of the model (density, discreteness, etc.)
3. Transfer to target frame (Q, Z, or R) via Cantor isomorphism or Doets transfer
4. The transfer target is an ordered abelian group, satisfying AddCommGroup

### Immediate Action: Fix Discrete TM Completeness

The ONE change that unblocks the project is:

1. **Add Prior-UZ and Prior-SZ to the axiom system** as discrete-specific axioms (not base axioms).
2. **Prove soundness on Int** (straightforward from well-ordering of positive integers).
3. **Use Venema's argument** to show the limit model has no definable gaps.
4. **Use the simplified discrete Doets transfer** (Reynolds Theorem 9, which is nearly trivial in the discrete case once no-gaps is established) to get a k-equivalent Z-model.
5. **Remove the IsSuccArchimedean sorry** -- it is no longer needed.

This is the mathematically principled path. It follows what Burgess, Reynolds, Venema, and Xu actually proved, rather than trying to establish a structural property (IsSuccArchimedean for limit_dom) that the literature never needed.

### The Uniformity Axioms: Should They Stay?

The four uniformity axioms (discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd) are SOUND on ordered abelian groups. They express that "if there is an immediate successor somewhere, there is one everywhere, and the step size is uniform." These are GENUINELY NEEDED for soundness of the modal-temporal interaction axioms on ordered abelian group frames. They are NOT needed for Burgess-style completeness on abstract linear orders, but they ARE part of the correct axiom system for the specific frame class of ordered abelian groups.

**Recommendation**: Keep them, but recognize they are weaker than Prior-UZ. Prior-UZ must be added independently. The uniformity axioms serve a different purpose (they are about the interaction between the group structure and the temporal operators, not about the absence of definable gaps).

### The AddCommGroup Question: Leave It

The AddCommGroup constraint in `valid` is CORRECT for the project's purposes (formalizing task frames as ordered abelian groups). The completeness proofs target specific groups (Q, Z, R) that satisfy AddCommGroup. There is no need to generalize `valid` to arbitrary linear orders -- that would be a different (and much harder) project.

## 9. Detailed Analysis of Doets's Discrete Transfer

### 9.1 Why It Is Simpler Than Expected

Reynolds's proof of Theorem 9 (discrete Doets transfer) occupies less than one page and proceeds as follows:

**Setup**: M is a countable discrete temporal structure without endpoints, and for any contemporaneous equivalence relation ~ on M, the ~-classes do not end in gaps.

**Define goodness**: M is "good" if there exists N equivalent_k to M with flow an interval of Z. M is "very good" if for all t <= u in M, the substructure M|[t,u] is good.

**Lemma 14**: If N is countable and very good, then N is good. (Proof: All finite structures are good. For infinite N, partition into finite intervals using a Z-indexed sequence, each interval is good by very goodness, and k-equivalence is preserved under lexicographic sums.)

**Define ~_M**: a ~_M b iff M|[a,b] (or M|[b,a]) is very good.

**Lemma 15**: ~_M is a contemporaneous equivalence relation.

**The punch line**: If M is not good, then M has at least two ~-classes. By the gap condition, no class ends at a gap. In a discrete order, a class that doesn't end at a gap must end at a definite point -- i.e., include its endpoint. But if class of a ends at a definite point c (includes c but not succ(c)), then M|[c, succ(c)] is good (it's a finite structure!), which means c ~_M succ(c), contradicting succ(c) not being in c's class. So there is only ONE class, meaning all of M is one class, meaning M is very good, meaning M is good. Contradiction.

### 9.2 What "No Gaps at Class Boundaries" Requires

The gap condition (D1 of Doets's theorem) requires: for any contemporaneous equivalence relation ~ on M, the ~-classes do not end in gaps.

In a discrete order, "ending in a gap" means: the class is bounded above but its supremum is not in the model. In a discrete order without endpoints, this can ONLY happen if there is a "jump" -- an element a in one class whose successor succ(a) is in a different class, but the class of a does not include succ(a). But this is impossible because M|[a, succ(a)] is a finite (2-element) structure, which is trivially good, so a ~_M succ(a).

**Wait -- this seems to prove D1 trivially for discrete orders!** If M is discrete and without endpoints, and every finite substructure is good (which it is, since any finite discrete order is k-equivalent to a finite interval of Z for large enough k), then ~_M classes cannot end at gaps because adjacent elements are always equivalent.

### 9.3 Does This Mean We Don't Even Need Prior-UZ?

NO. The subtlety is that the equivalence relation ~ is defined relative to a specific k. Different k values give different equivalence relations. The contemporaneous equivalence relation in Doets's theorem ranges over ALL first-order definable equivalence relations, not just ~_M for a specific k.

But actually, reading Reynolds more carefully: in the discrete case, his Theorem 9 requires only condition D1 (no gaps at class boundaries), not D2 (dense singletons in quotient). And his proof shows that D1 holds TRIVIALLY in discrete orders because finite structures are always good. The Prior-UZ axiom is used to ensure the MODEL is discrete (by ruling out "accumulation points" where the order looks locally dense).

**Revised understanding**: For the discrete case, the Doets transfer argument is:
1. The Burgess chronicle on a BX+discrete-consistent formula produces a countable discrete model M without endpoints.
2. M is discrete BECAUSE the formula is consistent with discreteness axioms U(top,bot) /\ S(top,bot).
3. In any discrete countable order without endpoints, condition D1 holds trivially (as argued above).
4. Therefore Doets Theorem 9 applies, giving k-equivalence to Z.

**But**: Step 2 is where Prior-UZ enters. Without Prior-UZ, the model produced by the Burgess construction is a general linear order -- it is NOT necessarily discrete. The discreteness axioms in the LOGIC force the model to be discrete, but only if the logic is strong enough. With just BX + U(top,bot), the model IS discrete (U(top,bot) forces every point to have an immediate successor). The question is whether it is discrete in the RIGHT way -- i.e., whether every two points are connected by finitely many successor steps. This is EXACTLY IsSuccArchimedean.

### 9.4 The Resolution

The Doets transfer for discrete orders works like this:
1. Build Burgess model M on Q with all chronicle properties.
2. M satisfies U(top,bot) (discreteness) -- every point in limit_dom has an immediate successor within limit_dom.
3. M satisfies Prior-UZ -- if added as an axiom. This ensures "no definable gaps."
4. The Doets argument: define ~_M for a fixed k. Show M is good by the argument in 9.1-9.2.

The key realization: **In step 3, Prior-UZ is what ensures that limit_dom does not have "Z + Z" type gaps.** Without Prior-UZ, limit_dom could be Z + Z + Z + ... (infinitely many copies of Z concatenated), which IS a discrete linear order where every point has an immediate successor, but where IsSuccArchimedean fails.

Prior-UZ eliminates this possibility: in a model where Prior-UZ holds and U(top,bot) holds, for any a < b with b = succ^k(a) for some k, the model MUST be locally finite between a and b. The "gap" between copies of Z is a DEFINABLE gap (definable by the formula isolating elements of different copies), and Prior-UZ rules out definable gaps.

## 10. Open Question: Do the Uniformity Axioms Already Imply Prior-UZ on Ordered Abelian Groups?

The counterexample Z x Z_lex shows that uniformity axioms do NOT imply Prior-UZ on general discrete linear orders. But Z x Z_lex is NOT a "uniformly discrete ordered abelian group" in the sense our axioms intend -- or is it?

Let's check:
- Z x Z_lex IS an ordered abelian group (addition is componentwise, order is lexicographic)
- It IS discrete: succ((a,b)) = (a, b+1). The immediate successor exists everywhere.
- `U(top,bot)` holds everywhere (the immediate successor (a,b+1) exists for all (a,b))
- `U(top,bot) -> S(top,bot)` holds (pred((a,b)) = (a, b-1))
- `U(top,bot) -> G(U(top,bot))` holds (every point has an immediate successor)
- `U(top,bot) -> H(U(top,bot))` holds (same reason)

So Z x Z_lex satisfies ALL four uniformity axioms. And Prior-UZ FAILS on it: let p be true exactly on elements with first coordinate >= 1. At (0,0), Fp holds (e.g., (1,0) is in the future). But U(p, neg p) at (0,0) requires a witness s > (0,0) with p(s) and neg p between (0,0) and s. The first element of {s | p(s)} above (0,0) is (1, -infinity), which doesn't exist -- the set {(1,b) | b in Z} has no minimum. So there is no first point where p holds, and U(p, neg p) cannot be satisfied (any candidate witness (1,b) has (1, b-1) below it where p holds, not neg p).

**Conclusion confirmed**: The uniformity axioms do NOT imply Prior-UZ, even on ordered abelian groups. Prior-UZ must be added as a separate axiom.

## 11. Final Verdict

**The mathematically correct path is clear: ADD Prior-UZ and Prior-SZ to the discrete axiom system, and use the Venema/Reynolds proof strategy (definable well-ordering + Doets discrete transfer) instead of trying to prove IsSuccArchimedean for limit_dom.**

This is not a hack or a shortcut. It is what the literature actually does. Reynolds's US/Z axiomatization INCLUDES Prior-UZ. Venema's BN axiomatization INCLUDES axiom W (= Prior-UZ). The only reason the current codebase doesn't include it is that it was trying to prove completeness with a weaker axiom system -- but that axiom system is provably incomplete for Z.

The IsSuccArchimedean sorry is not a formalization gap. It is a MATHEMATICAL IMPOSSIBILITY: the current axiom system (BX + 4 uniformity axioms without Prior-UZ) is INCOMPLETE for the frame class of Archimedean discrete ordered abelian groups (= Z). No completeness proof can exist without strengthening the axiom system.
