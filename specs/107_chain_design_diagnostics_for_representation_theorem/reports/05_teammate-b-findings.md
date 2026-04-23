# Teammate B Findings: Verbrugge 2004 Literature Study

**Task**: 107 - Chain design diagnostics for representation theorem
**Date**: 2026-04-23
**Focus**: Extract the "step-by-step" / "C_adequate" method from Verbrugge et al. 2004
**Source**: `literature/Verbrugge_2004_Completeness_by_construction.md`

---

## 1. What Is the "Step-by-Step Method" / "C_adequate Method"?

**Confidence**: HIGH

The step-by-step method is an alternative to Segerberg's filtration+bulldozing approach for proving completeness of tense logics. Instead of building the full canonical model (which is "rather messy" -- their words) and then transforming it into a linear order, it **constructs the model directly**, point by point, ensuring the desired structural properties hold at every stage.

**How it differs from Segerberg/filtration**:

| Aspect | Segerberg (filtration) | Step-by-step (Verbrugge) |
|--------|----------------------|--------------------------|
| Starting point | Full canonical model | Empty model (single root point) |
| Strategy | Build everything, then cut down | Build only what's needed |
| Linear order | Obtained by bulldozing non-linear canonical structure | Built linearly from the start |
| Witness insertion | Implicit in canonical model | Explicit point insertion at each stage |
| F-resolution | Proven by model structure | Ensured by construction at each stage |

**What makes it "constructive"**: The model is built incrementally. At each stage, you have a finite linearly ordered set of MCS-labeled points satisfying conditions (a)-(b). You then inspect one formula and insert new witness points if needed. The construction converges in omega steps (or finitely, for C_adequate).

The **C_adequate** variant restricts attention to MCS that are maximal consistent **within a finite adequate set Sigma** (Definition 5). This makes the state space finite (only finitely many Sigma-MCS exist), enabling stronger convergence arguments and decidability results. The "C" stands for the finiteness constraint.

## 2. How Does Verbrugge Build the Linear Order?

**Confidence**: HIGH

The construction is **growing** -- points are inserted between existing ones or at the ends. It is NOT fixed omega-indexed.

### For Lin (Theorem 1 -- strong completeness):

**Stage 0**: Create root point t* with MCS extending Sigma union {neg phi}.

**Stage n+1**: Take care of formula phi_n (from a fixed enumeration where each formula appears infinitely often). For each point t in T_n:
- If neg G(phi_n) is in Gamma_t AND no witness exists yet to the right of t, then:
  - By Lemma 4, there exists Delta with Gamma_t prec Delta and neg(phi_n) in Delta
  - Insert a new point u as immediate successor of t, with Gamma_u = Delta
  - The non-branching property (Lemma 3) guarantees Delta prec Gamma_{t'} for the existing successor t' of t, preserving linearity

**Key structural fact**: New points are inserted **between** existing points. The non-branching-to-the-future property of the prec relation ensures that the newly inserted MCS fits into the existing linear order. This is the critical difference from the project's current approach, which builds a fixed omega-indexed chain.

### For Q (Theorem 3 -- completeness w.r.t. rationals):

- **Even stages**: Handle F-resolution (same as Lin)
- **Odd stages**: Handle density -- insert a new point between every pair of successive points (using Lemma 5: density of prec for Q-MCS)

### For D (Theorem 5 -- discrete structures):

- **Even stages**: Handle F-resolution (same as Lin)
- **Odd stages**: Assign immediate successors and predecessors to each point not yet having them, using Lemma 6 to construct a "maximal" successor seed

## 3. What Are "Adequate Sets" (Definition 4)?

**Confidence**: HIGH

An adequate set Sigma is a finite, recursively closed set of formulas. For Z-adequacy:

1. **Subformula closed**: if phi in Sigma, all subformulas of phi are in Sigma
2. **Single negation closed**: if phi in Sigma and phi is not a negation, then neg phi in Sigma
3. **Contains G(bot) and H(bot)**: ensures seriality can be discussed
4. **G-deferral closure**: if G(phi) in Sigma and phi is not of the form neg G(psi), then G(neg G(phi)) in Sigma; symmetric for H

### Relationship to project's closures:

| Verbrugge adequate set | Project equivalent | Match? |
|------------------------|-------------------|--------|
| Subformula closed | `subformulaClosure` | YES |
| Negation closed | `closureWithNeg` | YES |
| Contains G(bot), H(bot) | `serialityFormulas` in `deferralClosure` | PARTIAL -- project uses F_top/P_top not G(bot)/H(bot) |
| G-deferral closure (G(neg G(phi))) | Not explicitly present | NO |

The project's `deferralClosure` extends `closureWithNeg` with:
- F/P deferral disjunctions: {chi or F(chi) | F(chi) in closureWithNeg}
- Until/Since deferral disjunctions
- Seriality formulas

Verbrugge's adequate set instead adds `G(neg G(phi))` closure. This is a **different** kind of closure with a different purpose: it ensures that whenever the construction needs to handle neg G(phi), the formula FG(phi) = neg G(neg G(phi)) is available in Sigma. The project's `deferralClosure` does NOT include this G-deferral closure.

**Critical insight**: The project's `extendedDeferralClosure` is close to an adequate set but lacks the `G(neg G(phi))` entries. Adding these would be straightforward and could enable the C_adequate finite state space arguments.

### Role of finiteness:

Lemma 7 proves that the minimal adequate set containing any finite set of formulas is itself finite. Since there are only finitely many maximal consistent subsets of a finite set, the state space of possible MCS labels is finite. This enables:
- Pigeonhole arguments for convergence
- The "maximal Gamma_r" / "minimal Gamma_l" construction in Theorem 6
- Decidability as a corollary

## 4. How Does Verbrugge Handle F-Resolution (neg G(psi) Obligations)?

**Confidence**: HIGH

This is the **central question** for the project's sorry sites. The answer differs significantly between Lin (Section 3) and Z (Section 4).

### For Lin (Theorem 1, infinite MCS):

F-resolution is handled by **formula enumeration with infinite repetition**. Each formula appears infinitely often in the enumeration. At stage n+1:
1. Find the maximal point t with neg G(phi_n) in Gamma_t
2. If no witness exists yet (phi_n holds at all points beyond t), INSERT a new point u immediately after t with neg(phi_n) in Gamma_u
3. The non-branching property guarantees u fits into the linear order

**There is no convergence problem** because each formula gets infinitely many chances. The union T = union of T_n satisfies all obligations.

### For Z (Theorem 6, finite adequate sets):

This is where the construction becomes more sophisticated. The proof has three phases:

**Phase 1 (Stage 0-1)**: Create root t_0. Then find "maximal" Gamma_r (containing max G-formulas, min H-formulas among all successors) and "minimal" Gamma_l (max H-formulas, min G-formulas among all predecessors). This bounds the G/H-formula variation.

**Phase 2 (Stages 2+, finite)**: Treat those neg G-formulas phi where neg G(phi) in Gamma_l but G(phi) in Gamma_r. For each such formula, insert witness points between t_l and t_r. The crucial argument is case (a) vs case (b):

- **Case (a)**: neg G(neg G(phi)) in Gamma_t (i.e., FG(phi) in Gamma_t). A new point t' > t with neg(phi) AND G(phi) in Gamma_{t'} can be introduced. The proof shows this is possible by contradiction using axiom Z1: G(G(phi) -> phi) -> (FG(phi) -> G(phi)). If the seed {neg phi, G(phi)} union g_content(M) were inconsistent, we could derive G(G(phi) -> phi), and Z1 would give G(phi) in Gamma_t, contradicting neg G(phi).

- **Case (b)**: neg G(neg G(phi)) NOT in Gamma_t. This leads to contradiction: either G(neg G(phi)) in Gamma_l (contradicts G(phi) in Gamma_r via seriality) or neg G(neg G(phi)) not in Sigma (requires phi = neg G(psi), which creates a symmetric contradiction).

**Phase 3 (Infinite extension)**: After the finite middle part is complete, extend both ends to infinity. Since Gamma_r is "maximal" in G-formulas, all its successors have identical G/H content. The remaining neg G-formulas are handled **cyclically**: with k neg G-formulas in Gamma_r, cycle through them in order. This works because:
- Each formula gets resolved every k steps
- G-formulas are identical at all points beyond Gamma_r
- The finite adequate set bounds the number of distinct MCS

**This is the key insight the project is missing**: The Verbrugge construction for Z handles F-resolution by:
1. Finding maximal/minimal endpoints that BOUND the G/H variation
2. Doing a FINITE number of insertions in the middle
3. Cycling through defects in the infinite tail

### For D with respect to Z circle Z (Theorem 7):

The middle part construction may now produce **infinite** stretches (N + Z circle n + N*) because inserted witnesses may themselves need witnesses. But Lemma 10 guarantees the seeds are consistent. The proof handles four sub-cases and introduces a "round" structure where unresolved formulas get another chance in the next round.

## 5. How Does Verbrugge Handle Multiple Temporal Obligations?

**Confidence**: HIGH

When resolving one neg G(psi), other obligations are preserved because:

1. **G-content propagation**: The new point u has Gamma_t prec Gamma_u, meaning all G-formulas of Gamma_t are in Gamma_u. Since neg G(phi) for other formulas is logically implied by neg G(phi) at predecessors (Lemma 2.4(b): neg G(phi) propagates backward), all neg G obligations at t are automatically present at u.

2. **The non-branching insertion**: When u is inserted between t and t' (its former successor), the linear order is preserved. Conditions (a)-(d) from Theorem 1 continue to hold for the expanded T_{n+1} because:
   - (a) is permanent (root point never changes)
   - (b) follows from prec being compatible with the linear order
   - (c) and (d) for old points: their witnesses are still present
   - For new points: they inherit all obligations from their predecessors

3. **For Z (finite adequate sets)**: The "maximal" Gamma_r and "minimal" Gamma_l ensure that after the middle part is built, the infinite extension only needs to handle a FIXED set of neg G-formulas. The cyclic resolution in Phase 3 rotates through all of them, guaranteeing each gets resolved.

**Contrast with project**: The project's BX11 fold (Case 3 obstruction) is precisely the problem of resolving one formula while losing control of another. Verbrugge avoids this entirely by:
- Not using the BX11 fold at all
- Instead using DIRECT point insertion via Lemma 4 (existence of prec-successor with neg phi)
- The non-branching property handles ordering, not BX11 linearity

## 6. Key Insight for Discrete Structures (Z)

**Confidence**: HIGH

The C_adequate method works for Z because:

1. **Finite adequate set Sigma** bounds the state space to finitely many Sigma-MCS
2. **Maximal/minimal endpoints** (Gamma_r, Gamma_l) bound the G/H-formula variation to a finite region
3. **Finite middle part**: Between Gamma_l and Gamma_r, only finitely many insertions are needed (because there are finitely many neg G/neg H formulas that differ between Gamma_l and Gamma_r)
4. **Cyclic infinite extension**: Beyond the endpoints, the same neg G-formulas repeat. Cycling through k defects in k steps resolves all of them

The redefined prec relation (Definition 6) is crucial:
- Gamma prec Delta iff: for each G(phi) in Gamma, both phi AND G(phi) in Delta; for each H(phi) in Delta, both phi AND H(phi) in Gamma
- This builds in transitivity explicitly (since GG(phi) may not be in Sigma)
- The project's g_content corresponds to the forward direction of this relation

**Key difference**: Verbrugge's prec propagates G-formulas AND their G-wrappings (G(phi) in Gamma implies both phi AND G(phi) in Delta). The project's g_content only propagates the unwrapped formula (G(phi) in M gives phi in successor). This difference is compensated by the project's use of Axiom temp_4 (G(phi) -> GG(phi)) to derive GG(phi) in M and hence G(phi) in the successor via g_content. But for the finite adequate set, Verbrugge avoids needing GG(phi) in Sigma by building transitivity into the definition of prec.

## 7. Does Verbrugge Handle Until/Since Directly?

**Confidence**: HIGH

**No.** The paper handles only G, H, F, P. Until and Since are NOT part of the language.

The axiom systems presented (Lin, P, D, Q, R, Z) use only:
- G (always in the future) and H (always in the past)
- F = neg G neg and P = neg H neg (existential duals)
- Box = H and phi and G (always)

There is no Until or Since operator. The paper notes its lineage to Segerberg 1971 and Burgess 2002, but Burgess's Until/Since work (1982, "Axioms for tense logic I") is NOT covered.

### Adaptation needed for Until/Since:

1. **Adequate set extension**: The adequate set definition would need additional closure conditions for Until/Since:
   - If (phi U psi) in Sigma, then phi, psi in Sigma
   - If (phi U psi) in Sigma, then psi or (phi and (phi U psi)) in Sigma (unfolding)
   - The project's `untilDeferralSet` and `sinceDeferralSet` already provide this

2. **Additional step conditions**: Beyond (c) and (d) from Theorem 1, we need:
   - (e) if (phi U psi) in Gamma_t, then exists t' >= t with psi in Gamma_{t'} and phi in Gamma_s for all t <= s < t'
   - (f) symmetric for Since
   - These are the `restricted_forward_until_since_coherent` and `restricted_backward_until_since_coherent` predicates in the project

3. **Witness insertion for Until**: When (phi U psi) in Gamma_t but no witness exists, we need to insert a chain of points where phi holds, ending with a point where psi holds. This is bounded by the adequate set (finitely many distinct MCS can appear).

4. **Interaction with G-resolution**: An Until obligation (phi U psi) creates both a G-like obligation (eventually psi) and a maintaining obligation (phi holds until then). The maintaining obligation resembles the G-propagation but with a termination condition.

## 8. How Does the Proof Handle the BACKWARD Direction (H/P)?

**Confidence**: HIGH

The backward direction is treated as **symmetric** to the forward direction. In Theorem 1, condition (d) is explicitly stated as analogous to (c):

> "We will just show how this is done for (c): (d) is analogous."

The same insertion strategy works in reverse:
- For neg H(phi) in Gamma_t, find Delta with Delta prec Gamma_t and neg phi in Delta
- Insert as an immediate predecessor
- Non-branching-to-the-past (from axiom L2) ensures the insertion preserves linearity

For Z (Theorem 6), the backward direction is handled by:
- The "minimal" Gamma_l (dual of "maximal" Gamma_r)
- The cyclic extension leftward is symmetric to the rightward extension
- The proof explicitly states: "That Gamma_r was chosen maximal means that, if Gamma_r prec Gamma, then Gamma_r and Gamma contain exactly the same G- and H-formulae."

**Project implication**: The project currently lacks `preserving_bwd_step` (confirmed in 03_team-research.md). This is a genuine gap, but the construction should be symmetric to `preserving_fwd_step`. The backward chain uses `bwd_pred` which constructs an H-content successor but does NOT preserve P-obligations (the backward analog of F-obligations).

---

## Algorithm Summary: Step-by-Step Construction (Pseudocode)

### For Z (Theorem 6, C_adequate):

```
INPUT: Finite Phi, formula phi with Phi not-proves-Z phi
OUTPUT: Model on Z satisfying Phi union {neg phi}

1. COMPUTE Sigma = minimal Z-adequate set containing Phi union {neg phi}
   -- Sigma is FINITE (Lemma 7)

2. STAGE 0: Create root t_0
   Gamma_0 = maximal Z-consistent subset of Sigma extending Phi union {neg phi}

3. STAGE 1: Find maximal and minimal endpoints
   Gamma_r = among all Delta with Gamma_0 prec Delta,
             choose one with MAX G-formulas and MIN H-formulas
   Gamma_l = among all Delta with Delta prec Gamma_0,
             choose one with MAX H-formulas and MIN G-formulas
   Create t_r > t_0, t_l < t_0

4. STAGES 2+: Finite middle part construction
   FOR EACH neg G(phi) such that neg G(phi) in Gamma_l AND G(phi) in Gamma_r:
     LET t = maximal point with neg G(phi) in Gamma_t
     LET u = successor of t (with G(phi) in Gamma_u)
     IF neg G(neg G(phi)) in Gamma_t:                     -- Case (a)
       INSERT t' between t and u with neg(phi), G(phi) in Gamma_{t'}
       -- Possible by Z1 contradiction argument
       -- neg G(phi) never needs treatment again (G(phi) in Gamma_{t'})
     ELSE:                                                 -- Case (b)
       DERIVE CONTRADICTION (impossible case)

5. SYMMETRIC for neg H formulas (dual of step 4)

6. INFINITE EXTENSION (rightward):
   -- Gamma_r is maximal: all successors have same G/H content
   -- Let {neg G(phi_1), ..., neg G(phi_k)} be the neg G-formulas in Gamma_r
   -- Cycle: at step i, resolve phi_{(i mod k)+1}
   -- This produces omega copies: ..., Gamma_r, Delta_1, Delta_2, ...
   -- where each Delta_i resolves one defect and preserves others

7. SYMMETRIC infinite extension leftward

8. RESULT: Linear order isomorphic to Z with MCS labels
```

### For D w.r.t. Z circle Z (Theorem 7):

Same as above but:
- Step 4 may require MULTIPLE ROUNDS (not finite in one pass)
- Inserted witnesses may themselves need witnesses (creating Z circle n structure)
- Lemma 10 guarantees seed consistency at each insertion
- Extension produces Z circle Z structure (Z copies of Z)

---

## Key Differences from Current Project Approach

| Aspect | Project (dd_chain) | Verbrugge (step-by-step) |
|--------|-------------------|--------------------------|
| Chain structure | Fixed omega-indexed, built once | Growing, points inserted between existing ones |
| Successor construction | {seed} union g_content(M) via Lindenbaum | Direct MCS via Lemma 4, prec relation |
| F-resolution strategy | BX11 fold (enriched_fwd_exists) with disjunctive result | Direct point insertion at maximal defect point |
| Convergence mechanism | F-preservation + hoped-for eventual resolution | Finite adequate set bounds + maximal/minimal endpoints + cyclic resolution |
| State space | Infinite (full MCS) | Finite (Sigma-MCS) for Z; infinite for Lin |
| Key axiom used | BX11 (temporal linearity) for fold | Z1/Z2 (induction axioms) for case (a); non-branching for insertion |
| Backward direction | bwd_pred (no P-preservation) | Symmetric to forward |
| Until/Since | In language, creates sorry sites | NOT in language |
| Linearity | Assumed by construction (integer index) | Proven at each step (non-branching property) |

### Critical architectural difference:

The project builds the chain **all at once** using a fixed recursive definition (fwd_chain_of_sigma), then tries to prove properties (F-resolution) about the completed chain. Verbrugge builds the chain **incrementally**, adding points specifically to satisfy unsatisfied obligations. The Verbrugge approach makes F-resolution trivial by construction -- each point is inserted precisely TO resolve a specific obligation.

The project's approach runs into BX11 Case 3 obstruction because the enriched fold is a **black box** that may resolve the wrong formula. Verbrugge avoids this entirely by using Lemma 4 directly (which gives a specific successor with the needed neg phi), not the BX11 linearity axiom.

---

## Adaptation Required for BX (Until/Since, Reflexive Semantics, S5 Modal)

### 1. Until/Since Extension (MAJOR)

Verbrugge handles only G/H/F/P. Adding Until/Since requires:

**Adequate set extension**: Add closure condition:
- If (phi U psi) in Sigma, add phi, psi, psi or (phi and (phi U psi))
- If (phi S psi) in Sigma, add phi, psi, psi or (phi and (phi S psi))
- The project's `extendedDeferralClosure` already computes this

**Step conditions**: Add Until/Since witness insertion (bounded by |Sigma|):
- For (phi U psi) in Gamma_t without witness: insert finite chain phi, phi, ..., phi, psi
- BX10 (U-unfolding: phi U psi <-> psi or (phi and F(phi U psi))) provides the step-by-step decomposition
- BX5 (U-induction) provides the termination argument (bounded by |Sigma| via pigeonhole on Sigma-MCS)

**Confidence**: MEDIUM-HIGH. The extension is non-trivial but follows standard patterns from Burgess 1982. The project already has `bx_until_step` infrastructure in the Quasimodel directory.

### 2. Reflexive Semantics

The project uses reflexive temporal semantics (G(phi) -> phi axiom, temp_t). Verbrugge uses strict ordering (irreflexive). This affects:

- The prec relation: project's g_content gives G(phi) in M implies phi in successor. Reflexivity gives phi in M as well. This is COMPATIBLE with Verbrugge's approach.
- The step-by-step construction: inserting a new point u between t and t' works the same way. The reflexive semantics means G(phi) in Gamma_t implies phi in Gamma_t, which is already guaranteed by MCS properties.

**Confidence**: HIGH. Reflexivity is a simplification, not a complication.

### 3. S5 Modal Component

The project combines temporal logic with S5 modal logic (Box operator). Verbrugge's construction is purely temporal. The S5 component needs:

- Box stability: Box(phi) in chain(t) iff Box(phi) in M_0. The project ALREADY has this (`box_stable_dd_chain`, sorry-free).
- Modal witnesses: For Diamond(phi) in M, need a different world-history with phi. The project handles this via `bx_modal_witness` and the BFMCS family construction. This is ORTHOGONAL to the temporal chain construction.

**Confidence**: HIGH. The modal component is already sorry-free in the project. It does not interact with the temporal chain construction.

### 4. Integer Indexing vs. Growing Construction

The project uses a fixed Z-indexed chain. Verbrugge's construction grows. Two adaptation paths:

**Path A (Adapt to growing)**: Replace `fwd_chain_of_sigma` with an incremental construction that can insert points. This requires a fundamentally different data structure (e.g., a tree flattened to a list) rather than Nat-indexed recursion. MAJOR refactoring.

**Path B (Adapt Verbrugge to fixed indexing)**: Use the Phase 3 insight (cyclic resolution on fixed chain) with the Phase 1-2 insights (maximal/minimal endpoints, finite middle). The infinite tail IS omega-indexed in Verbrugge. The key adaptation is:
1. At step 0, find Gamma_r (maximal in G-formulas) among the reachable successors
2. At steps 1 to k, resolve each neg G-formula that differs between M_0 and Gamma_r
3. At steps k+1 onward, cycle through all remaining defects every k steps

**Path B is more compatible with the existing codebase.** The key change: replace the generic `preserving_fwd_step` with a TWO-PHASE construction:
- Phase 1: Finite prefix resolving all "gap-crossing" obligations
- Phase 2: Cyclic tail resolving all remaining defects

**Confidence**: MEDIUM. Path B preserves the project's integer-indexed architecture while incorporating Verbrugge's convergence insight.

---

## Confidence Levels Summary

| Finding | Confidence |
|---------|-----------|
| Step-by-step method description | HIGH |
| Growing vs. fixed construction | HIGH |
| Adequate sets and relationship to deferralClosure | HIGH |
| F-resolution mechanism for Lin | HIGH |
| F-resolution mechanism for Z (C_adequate) | HIGH |
| Multiple obligation preservation | HIGH |
| Discrete structure (Z) key insight | HIGH |
| Until/Since NOT handled by Verbrugge | HIGH |
| Backward direction is symmetric | HIGH |
| Adaptation path for Until/Since | MEDIUM-HIGH |
| Adaptation Path B (fixed indexing with Verbrugge insights) | MEDIUM |

---

## Concrete Recommendations for Task 107

### Immediate Actions

1. **Add G(neg G(phi)) closure** to `extendedDeferralClosure` -- this enables the Z1/Z2 contradiction argument from Verbrugge's case (a)

2. **Implement "maximal successor" selection**: Find Gamma_r among Sigma-MCS reachable from M_0 that maximizes G-formulas. This bounds the problem.

3. **Implement cyclic resolution for the infinite tail**: Once Gamma_r is established, the remaining defects form a FIXED finite list. Cycle through them every k steps. This replaces the `preserving_fwd_step` with a more structured step function.

### The Single Most Important Insight

Verbrugge's construction avoids the BX11 fold entirely. It uses **Lemma 4** (direct existence of a successor with neg phi, via Lindenbaum) rather than BX11 linearity for F-resolution. The project's BX11 fold (Cases 1/2/3) introduces non-determinism that cannot be controlled. By switching to direct Lemma 4 insertion -- which the project already has as `forward_temporal_witness_seed_consistent` -- the Case 3 obstruction disappears.

The convergence argument then comes from the FINITE adequate set: there are only finitely many Sigma-MCS, so the chain must eventually cycle through all defect resolutions. This is exactly the pigeonhole argument that was dismissed in prior research as "defect count does not decrease" -- but in Verbrugge's framework, it DOES decrease because:
1. The maximal/minimal endpoints bound which defects exist
2. Each resolution in the finite middle part is PERMANENT (the witness point has G(phi), so no point beyond it has neg G(phi) as a defect)
3. The cyclic tail handles the remaining fixed set of defects mechanically
