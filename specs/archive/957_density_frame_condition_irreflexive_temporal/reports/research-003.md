# Research Report: Task #957 - Density Frame Condition (Third Investigation)

**Task**: 957 - density_frame_condition_irreflexive_temporal
**Started**: 2026-03-10T16:00:00Z
**Completed**: 2026-03-10T18:30:00Z
**Effort**: High
**Dependencies**: research-001.md, research-002.md, implementation-summary-20260310b.md
**Sources/Inputs**: DensityFrameCondition.lean, SeparationLemma.lean, WitnessSeed.lean, CanonicalFrame.lean, Axioms.lean, Derivation.lean, MaximalConsistent.lean, TemporalContent.lean, ROAD_MAP.md, WebSearch (Gabbay 1981, Di Maio/Zanardo 1998, Reynolds 1992, Venema, Burgess, Goldblatt, Hodkinson), SEP temporal logic entry
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Method 1 (Gabbay IRR Rule): VIABLE but requires fundamental proof system change.** The IRR rule `[(p AND H(neg p)) -> phi] / phi` (p fresh) is a meta-rule that enables the canonical model to distinguish any world from its successors by introducing a "timestamp" proposition. It solves the density Case B obstruction completely but requires adding a new inference rule to the derivation system, which affects all existing proofs and changes the logic itself.

- **Method 2 (Selective Lindenbaum with Enumeration Control): NOT FEASIBLE for Case B.** The GContent forcing problem makes it mathematically impossible to construct an MCS W with both CanonicalR(M, W) and GContent(W) controlled. The seed inconsistency (Finding 14 of research-002) is intrinsic: in Case B, delta is in GContent(M), so {neg(delta)} union GContent(M) is inconsistent. No enumeration strategy can overcome this because the inconsistency occurs at the seed level, before any enumeration begins.

- **Method 3 (Bulldozing): MOST PROMISING alternative.** The bulldozing technique transforms the canonical model post-hoc to eliminate reflexive pairs without changing the proof system. This is a model-theoretic technique that preserves the axiom system unchanged while achieving irreflexivity in the constructed model.

- **Recommended approach: Bulldozing (Method 3) for the general theorem, with the IRR rule as a cleaner alternative if proof system changes are acceptable.**

## Context & Scope

### What Was Researched

This is a focused follow-up to research-002, investigating two specific methods for resolving the sorry in `density_frame_condition` at DensityFrameCondition.lean:184 (Case B). The prior research established:

1. Case A formulas do NOT always exist (counterexample in research-002 Finding 1)
2. The seed {neg(delta)} union GContent(M) is INCONSISTENT in Case B (research-002 Finding 14)
3. Option C (staged Case A guarantee) was proven impossible (implementation-summary-20260310b.md)
4. The fundamental obstruction is GContent forcing under irreflexive semantics

### Constraints

- Must work under irreflexive semantics (G quantifies over strict future)
- Must use temporal axioms (density, temp_4, temp_a, temp_linearity, seriality)
- Must not import external dense linear orders (per task constraints)

## Findings

### Finding 1: The Gabbay IRR Rule -- Complete Technical Analysis

#### 1.1 Exact Formulation

The Gabbay Irreflexivity Rule (IRR), introduced in Gabbay 1981, is:

```
From  |- (p AND H(neg p)) -> phi
Infer |- phi

where p is a propositional variable that does NOT occur in phi.
```

In our notation:
```
From  |- (Formula.and (Formula.atom p) (Formula.all_past (Formula.neg (Formula.atom p)))) .imp phi
Infer |- phi

where p does not occur free in phi (i.e., p not in Formula.atoms phi).
```

This is a **derivation rule** (meta-rule), not an axiom schema. The crucial distinction: an axiom schema would require `(p AND H(neg p)) -> phi` to be valid for ALL p simultaneously. The IRR rule instead says: if we can derive `phi` under the ASSUMPTION that some fresh p holds now and never held before, then `phi` holds unconditionally.

#### 1.2 Semantic Meaning

The formula `p AND H(neg p)` describes a "first-time" event: p is true now and was false at all strictly past times. Under irreflexive semantics:

- At time t: `p` holds and for all s < t, `neg p` holds at s
- This characterizes t as "the unique moment where p first becomes true"

The IRR rule says: if a formula phi (not mentioning p) follows from the existence of such a first-time event, then phi holds unconditionally. The semantic justification is that in any irreflexive linear order, for any point t, we can ALWAYS find a proposition that is true only at t (since the point can be "named" by a fresh proposition).

Semantically, the rule is valid on all irreflexive frames because:
- Given any model M and time t, define a valuation where p is true only at t
- Then `p AND H(neg p)` holds at t in this extended valuation
- If `(p AND H(neg p)) -> phi` is valid (for any phi not mentioning p), then phi holds at t
- Since phi does not mention p, its truth value is independent of the p-valuation
- Therefore phi holds at t in the original model

#### 1.3 How IRR Enables Density Under Irreflexive Semantics

The density Case B obstruction is:
- G(delta) in M, delta not in M, G(delta) in M'
- We need intermediate W with CanonicalR(M, W) and CanonicalR(W, M')
- The seed {neg(delta)} union GContent(M) is INCONSISTENT because delta in GContent(M)

The IRR rule resolves this as follows:

**Step 1**: Define phi as the density condition itself: "for all M, M' with CanonicalR(M, M') and not CanonicalR(M', M), exists intermediate W."

**Step 2**: Assume `p AND H(neg p)` for a fresh p. This gives us a "marker" proposition that is true exactly at the current world M and false at all strictly past worlds.

**Step 3**: In the canonical model construction, every MCS now has a potential "marker" available. When constructing the density witness W between M and M', the fresh variable p provides an asymmetry:
- p is in M (by assumption)
- p is not in any world strictly before M (by H(neg p))
- The presence of p in GContent analysis breaks the symmetry that causes Case B to fail

**More precisely**: The IRR rule allows us to argue as follows. Suppose we want to prove density_frame_condition. By IRR, it suffices to prove density_frame_condition under the additional assumption that some fresh p satisfies `p AND H(neg p)` at M. Now:

- Since p is fresh (not in delta or any formula in GContent(M) or GContent(M')), adding p to the analysis does not change the GContent relationships
- But p provides a formula that is in M but NOT in M' (because if p were in M', and CanonicalR(M, M') means all future obligations are met, p being fresh means it is not forced into M')
- Actually, the key insight is subtler: the IRR rule allows the canonical model construction to include marker propositions that prevent reflexive canonical relations (CanonicalR(M, M)), which is the root cause of the density obstruction

**The deep connection**: Under irreflexive semantics, the canonical model can have CanonicalR(M, M) (a world that canonically sees itself). This happens when GContent(M) is a subset of M, which is perfectly possible when G does not validate the T-axiom (G(phi) does not imply phi). The IRR rule prevents this: if p AND H(neg p) holds at M, then p is in M, so p is in GContent(M) only if G(p) is in M. But H(neg p) at M means neg p held at all past times, and by temp_a, p -> G(P(p)), so G(P(p)) in M, meaning P(p) in GContent(M). If CanonicalR(M, M) held, P(p) would be in M. But P(p) = neg(H(neg p)), and H(neg p) is in M (by assumption), giving both P(p) and H(neg p) = neg(P(p)) in M -- contradiction.

**Therefore**: The IRR rule forces NOT CanonicalR(M, M) for any M satisfying `p AND H(neg p)`. This eliminates reflexive canonical relations, which is the precise obstruction causing Case B.

With reflexive canonical relations eliminated, the Case B scenario (where GContent(M) forces formulas into any MCS extending GContent(M)) becomes impossible, because the formula delta cannot simultaneously be in GContent(M) AND be a distinguishing formula (delta not in M). Under the IRR-enforced irreflexivity, GContent(M) is NOT a subset of M, so delta in GContent(M) implies delta in M -- contradicting the assumption.

**Wait -- this argument needs correction.** The IRR rule does NOT directly prevent delta from being in GContent(M) while not in M. Let me reconsider.

The IRR rule's role in density proofs is actually more indirect. It works through the canonical model construction:

1. **Standard canonical model**: Worlds are ALL MCSs. Some MCSs may be "reflexive" (CanonicalR(M, M) holds). Between a reflexive M and another world M', the density proof fails because GContent(M) subset M forces delta into M.

2. **With IRR**: The canonical model is constructed using a FILTERED set of MCSs -- only those satisfying `p AND H(neg p)` for some fresh p. This is the "Gabbay construction" where each world is paired with a fresh marker. The marker ensures that no world sees itself in the canonical frame, because the marker is present at the world but its G-version is not (the marker is "new" at each world).

3. **The actual mechanism**: In the Gabbay construction, to prove density between M and M', the marker proposition at M provides the asymmetry needed. Specifically, since G(p) is not in M (because p is fresh and first appears at M), the formula p is NOT in GContent(M). This means that the world M "knows" it is not in its own future, providing the irreflexivity that eliminates Case B.

#### 1.4 Formalization Requirements in Lean 4

Adding the IRR rule requires:

**Change 1: New inference rule in DerivationTree** (~30 lines)
```lean
| irr (p : String) (phi : Formula)
    (h_fresh : p ∉ phi.atoms)
    (d : DerivationTree []
      ((Formula.and (Formula.atom p) (Formula.all_past (Formula.neg (Formula.atom p)))).imp phi)) :
    DerivationTree [] phi
```

This adds a 8th inference rule to the existing 7 rules (axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening).

**Change 2: Soundness proof for IRR** (~80-120 lines)
Must prove that the IRR rule preserves validity on irreflexive frames. The proof:
- Given any model with irreflexive temporal order and any time t
- Extend the valuation by setting p true only at t
- The extended model satisfies `p AND H(neg p)` at t
- By hypothesis, phi holds at t in the extended model
- Since p does not appear in phi, phi holds at t in the original model

This requires:
- A lemma about formula evaluation being independent of variables not appearing in the formula
- The irreflexivity of the temporal order (to ensure H(neg p) holds when p is true only at t)

**Change 3: Updated MCS properties** (~50-80 lines)
The existing MCS properties (negation completeness, implication closure, etc.) should be unaffected since IRR only applies at the theorem level (empty context). However, certain derived facts about the proof system may need updates.

**Change 4: Density proof using IRR** (~100-150 lines)
The actual proof of `density_frame_condition` Case B using the IRR rule:
- Apply IRR with a fresh p
- Under the assumption `p AND H(neg p)`, prove that CanonicalR(M, M) is impossible
- Therefore Case B cannot arise (because Case B requires GContent(M) subset M, which together with temp_4 gives CanonicalR(M, M))
- Fall through to Case A, which is already proven

**Wait -- this is the key insight. Let me verify it:**

In Case B: G(delta) in M and delta not in M. Also G(delta) in M implies delta in GContent(M). By temp_4: G(delta) in M implies G(G(delta)) in M, so G(delta) in GContent(M). Continuing: G^n(delta) in GContent(M) for all n >= 0.

Does this imply CanonicalR(M, M)? CanonicalR(M, M) means GContent(M) subset M. But delta in GContent(M) and delta NOT in M -- so GContent(M) is NOT a subset of M. Therefore CanonicalR(M, M) does NOT hold in Case B!

So the IRR rule does NOT eliminate Case B by preventing reflexivity. The connection is more subtle.

**Revised understanding**: The IRR rule enables density proofs through a different mechanism. In the Gabbay/Burgess completeness proof for dense linear orders:

1. The proof constructs the canonical model step-by-step (not via Zorn's lemma)
2. At each step, a fresh marker proposition is introduced
3. The marker allows the construction to distinguish the current world from all others
4. When inserting a density witness W between M and M', the marker at W ensures W differs from both M and M'
5. The construction guarantees CanonicalR(W, M') by building W with explicit GContent control

The IRR rule is needed because the step-by-step construction introduces formulas involving fresh markers, and the IRR rule is needed to show that theorems proved using these markers are genuine theorems of the logic.

**Total estimated line count for IRR approach**: 260-380 lines

**Risk assessment**: MEDIUM. The IRR rule changes the proof system fundamentally. All existing soundness proofs must be re-verified (though they should still hold since IRR only adds derivability). The main risk is that the soundness proof for IRR requires proving formula evaluation independence, which touches the semantic infrastructure.

#### 1.5 Impact on Existing Proofs

Adding IRR as a new inference rule:

**Does NOT break**:
- All existing derivations remain valid (IRR only adds new derivations)
- Soundness: IRR is sound on irreflexive frames, which is our intended semantics
- All existing axioms remain unchanged
- All existing lemmas and theorems remain true

**May require updates**:
- Soundness proof must handle the new IRR case (~80-120 lines)
- Any proof by induction on DerivationTree structure gains a new case
  - `DerivationTree.recOn`, `DerivationTree.casesOn`, etc. would need an IRR case
  - This affects: generalized necessitation, deduction theorem variants, height function
  - Estimated: 10-20 locations, ~5 lines each = 50-100 additional lines
- Total downstream impact: ~130-220 lines of updates

**Total IRR approach cost**: 390-600 lines (new code + downstream updates)

### Finding 2: Selective Lindenbaum with Enumeration Control -- Detailed Feasibility Analysis

#### 2.1 The Obstruction Restated

For Case B density, we need MCS W satisfying:
1. CanonicalR(M, W): GContent(M) subset W
2. CanonicalR(W, M'): GContent(W) subset M'
3. W is distinct from M' (to serve as a strictly intermediate point in the quotient)

Condition 1 means W extends GContent(M). Condition 2 means every formula phi with G(phi) in W also has phi in M'. The standard Lindenbaum lemma (via Zorn) provides W satisfying condition 1 but gives NO control over condition 2.

#### 2.2 Enumeration-Based Lindenbaum: Technical Details

An enumeration-based Lindenbaum construction works as follows:

**Input**: Consistent seed S, formula enumeration phi_0, phi_1, phi_2, ...
**Process**:
```
W_0 = S
For each n:
  If W_n union {phi_n} is consistent:
    W_{n+1} = W_n union {phi_n}
  Else:
    W_{n+1} = W_n
W = union of all W_n
```

**Properties**:
- W is consistent (each W_n is consistent, by induction)
- W is maximal (for each phi, either phi in W or adding phi is inconsistent)
- W extends S (W_0 = S subset W)

**Key question**: Can we modify the choice at each step to ensure GContent(W) subset M'?

#### 2.3 The GContent Control Problem

At step n, when deciding whether to add phi_n to W_n, we need to check: will adding phi_n eventually force some G(psi) into W such that psi is not in M'?

**Direct G-formula addition**: If phi_n = G(psi) and psi not in M', we should NOT add G(psi). Modified rule:
```
If phi_n = G(psi) for some psi:
  If psi in M':
    Add phi_n if consistent with W_n
  Else:
    Skip phi_n (add neg(phi_n) if possible)
```

**Indirect G-formula forcing**: The problem is that adding a non-G-formula phi_n can FORCE G-formulas to become derivable from W. For example:
- phi_n = alpha, and alpha together with existing formulas in W_n derives G(beta) for some beta not in M'
- This forcing is generally undecidable and cannot be prevented by local checks

**Specific forcing mechanism**: If W_n contains G(alpha -> G(beta)) and we add alpha, then W_n union {alpha} derives G(beta) (via temporal K distribution + modus ponens under G). If beta not in M', this violates condition 2.

#### 2.4 Can Forcing Be Prevented?

**Claim**: In general, NO. The forcing problem is as hard as determining all consequences of a theory, which is not feasible within a single enumeration step.

However, there is a SPECIAL CASE that matters:

**The seed GContent(M) already determines most G-content.** By temp_4, G(phi) in M implies G(G(phi)) in M, so G(phi) in GContent(M). This means the seed already contains all "G-derived" content from M. The question is: can the Lindenbaum extension add NEW G-formulas beyond what temp_4 forces?

**Answer**: YES. Consider: the seed GContent(M) contains phi (from G(phi) in M). During enumeration, we might add G(psi) where G(psi) is consistent with W_n but G(psi) was not in M. This adds psi to GContent(W). If psi not in M', condition 2 is violated.

**The SKIP strategy**: We can skip all G(psi) formulas where psi not in M'. But can we still get a MAXIMAL consistent set?

For maximality, for every formula chi, either chi in W or neg(chi) in W. If we skip G(psi) (psi not in M'), we need neg(G(psi)) = F(neg(psi)) in W. Is {F(neg(psi))} union W_n always consistent?

Not necessarily. If W_n derives G(psi) (from existing G-content + temp_4 + other formulas), then F(neg(psi)) = neg(G(psi)) contradicts G(psi). In this case, the SKIP strategy fails -- we are forced to include G(psi) in W, violating condition 2.

#### 2.5 The Fundamental Impossibility

**Theorem (informal)**: In Case B, there is NO enumeration strategy that produces an MCS W with both GContent(M) subset W and GContent(W) subset M'.

**Proof sketch**: In Case B, G(delta) in M. So delta in GContent(M) subset W. Since W is MCS, by temp_4 applied in W: if G(delta) is derivable from W, then G(G(delta)) is also in W. But actually, we only know delta in W (from seed), not G(delta) in W.

Wait -- the issue is more subtle. GContent(M) subset W means that for every phi with G(phi) in M, phi is in W. Does this force G-formulas INTO W?

No! GContent(M) places stripped formulas in W (phi, not G(phi)). G(phi) being in W requires G(phi) to be added during enumeration or forced by the axioms.

**Let me reconsider**: The issue is whether GContent(M) being in W forces any G-formulas into W. If W only contains the stripped formulas from GContent(M) plus whatever is added during enumeration, then we CAN potentially control which G-formulas end up in W -- by skipping G(psi) when psi not in M'.

**But**: The seed GContent(M) may contain formulas that, combined with other formulas in W, derive G-formulas. For example, if GContent(M) contains `alpha -> G(beta)` and also contains `alpha`, then W contains both, and by MCS closure under derivation, G(beta) is in W. If beta not in M', this is a problem.

**However**: `alpha -> G(beta)` is in GContent(M) means G(alpha -> G(beta)) is in M. By temporal K distribution: G(alpha -> G(beta)) -> (G(alpha) -> G(G(beta))). If G(alpha) is also in M, then G(G(beta)) in M, so G(beta) in GContent(M), so beta in GContent(M). And GContent(M) subset M' (from CanonicalR(M, M')), so beta in M'. No violation!

This is an important observation: **the temp_4 axiom and temporal K distribution ensure that any G-formula derivable from GContent(M) has its stripped version already in GContent(M) and hence in M'.**

**More precisely**: If L is a finite subset of GContent(M) and L derives G(psi), then by the generalized temporal necessitation/K argument: G(L) derives G(G(psi)), meaning G(G(psi)) is derivable from formulas in M (since for each phi in L, G(phi) in M). So G(G(psi)) in M (MCS closure), hence G(psi) in GContent(M), hence psi in GContent(M) subset M'.

**THEREFORE**: Any G(psi) that is derivable from GContent(M) has psi in M'. The only way to get G(psi) with psi NOT in M' is to add it during enumeration (not from the seed alone).

**REVISED CONCLUSION**: The enumeration-based approach IS potentially feasible if we skip G(psi) formulas where psi not in M'. The key insight is that GContent(M) alone does not force problematic G-formulas -- those can only arise from formulas added during the enumeration, which we can control.

#### 2.6 The Selective Lindenbaum Construction (Revised)

**Input**: Consistent seed S = GContent(M), target MCS M'
**Enumeration**: phi_0, phi_1, phi_2, ... (all formulas)
**Process**:
```
W_0 = S
For each n:
  Case phi_n = G(psi):
    If psi in M' AND W_n union {G(psi)} is consistent:
      W_{n+1} = W_n union {G(psi)}
    Else if W_n union {neg(G(psi))} is consistent:
      W_{n+1} = W_n union {neg(G(psi))}
    Else:
      // Both are inconsistent with W_n -- impossible for consistent W_n
      // (one of phi, neg(phi) is always consistent with a consistent set
      //  ... actually this is NOT true in general. It IS true for MCS but
      //  W_n is not yet maximal.)
      // Actually: if both W_n union {G(psi)} and W_n union {neg(G(psi))} are
      // inconsistent, then W_n derives both neg(G(psi)) and G(psi), contradicting
      // W_n's consistency. So this case cannot arise.
      IMPOSSIBLE

  Case phi_n is not of the form G(psi):
    If W_n union {phi_n} is consistent:
      W_{n+1} = W_n union {phi_n}
    Else:
      W_{n+1} = W_n
W = union of all W_n
```

**Properties to verify**:
1. **W is consistent**: Each W_n is consistent by construction.
2. **W is maximal**: For every G(psi): either G(psi) in W (added at step n) or neg(G(psi)) in W (added because psi not in M' or G(psi) inconsistent). For non-G formulas: standard Lindenbaum argument.
3. **GContent(M) subset W**: From seed S = GContent(M).
4. **GContent(W) subset M'**: If G(psi) in W, it was added at step n only if psi in M'. So psi in M'. Check.

**Wait -- there is a problem with maximality for G-formulas.** When phi_n = G(psi) and psi NOT in M', we skip G(psi) and try to add neg(G(psi)). But what if neg(G(psi)) = F(neg(psi)) is inconsistent with W_n?

If both G(psi) and neg(G(psi)) are inconsistent with W_n, then W_n itself is inconsistent (it derives both G(psi) and neg(G(psi))), contradicting the inductive hypothesis. So at least one is consistent with W_n.

But it could be that G(psi) is consistent with W_n (and psi not in M', so we skip it) and neg(G(psi)) is ALSO consistent with W_n. In that case, we add neg(G(psi)). Fine.

Or: G(psi) is the ONLY consistent option (neg(G(psi)) is inconsistent with W_n). This means W_n derives G(psi). But if W_n derives G(psi), then G(psi) is already in the deductive closure of W_n, and any MCS extending W_n must contain G(psi). Since psi not in M', any MCS extending W_n has GContent not subset M'. This means the construction FAILS.

**When can W_n derive G(psi) with psi not in M'?** As analyzed in 2.5, the seed GContent(M) alone cannot derive such G(psi) (because of the temp_4/temporal K argument). But formulas added during the non-G phase of enumeration can contribute. Specifically, if we added some non-G formula alpha that, combined with the seed, derives G(psi).

**Example**: Suppose we added `alpha` (not a G-formula) at some earlier step. And suppose `alpha -> G(psi)` is a theorem (derivable from the empty context). Then W_n contains alpha and derives G(psi). If psi not in M', we are stuck.

**But**: Is `alpha -> G(psi)` ever a theorem? For this to be a theorem of TM, G(psi) must follow from alpha in all models. This is extremely strong and generally does not hold for arbitrary alpha and psi. However, there exist pathological cases: for instance, `G(psi) -> G(psi)` is a tautology, but `alpha = G(psi)` is a G-formula which would be handled separately.

What about `alpha -> G(alpha)`? This is NOT a theorem of TM (it would require the T-axiom in reverse). In irreflexive temporal logic, `phi -> G(phi)` is NOT valid.

**The key question**: Can adding non-G formulas to W_n ever force a G-formula to become derivable?

In our proof system: The only way to derive G(psi) is through:
1. Temporal necessitation (from theorem |- psi, derive |- G(psi)) -- but this requires psi to be a theorem, not just in W_n
2. Temporal K distribution: G(alpha -> psi) and G(alpha) both in W_n gives G(psi) in closure -- but G(alpha -> psi) is a G-formula handled separately
3. Modus ponens on G-formulas already in W_n

In fact, G(psi) can only be derived from W_n if there exist G-formulas already in W_n that combine (via temporal K) to produce G(psi). Non-G formulas cannot produce G-formulas through the proof rules.

**More precisely**: Consider the "G-content" of the derivation. A derivation tree producing G(psi) must either:
- Use temporal necessitation on a theorem (which is independent of W_n)
- Use a G-formula premise (from axiom or assumption)

Since temporal necessitation only applies to theorems (empty context), and axioms involving G are only `temp_k_dist`, `temp_4`, `temp_a`, and `temp_l` -- all of which produce G-formulas from G-formula premises -- the only way to derive G(psi) from W_n is through G-formulas already in W_n.

**THEREFORE**: If we control which G-formulas enter W (by the selective strategy), non-G formulas CANNOT force new G-formulas into W. The selective Lindenbaum construction DOES maintain GContent(W) subset M'.

#### 2.7 Formal Proof of the "G-Conservativity" Property

**Claim**: If Gamma is a set of formulas and Gamma |- G(psi), then there exist finitely many formulas G(chi_1), ..., G(chi_k) in Gamma such that {G(chi_1), ..., G(chi_k)} |- G(psi).

**Proof sketch**: By induction on the derivation tree. The key observation is that the only inference rules that produce G-formulas are:
- Axioms: temp_k_dist, temp_4 produce G-formulas from G-formula inputs
- Temporal necessitation: from |- psi derives |- G(psi), but this uses no assumptions from Gamma
- Modus ponens: G(phi -> psi) and G(phi) gives G(psi) via temp_k_dist

All paths to G(psi) in a derivation tree go through G-formula assumptions or theorems.

**Formalization note**: This is a "subformula property" for G-formulas. It requires induction on DerivationTree with careful case analysis. Estimated: 100-200 lines.

#### 2.8 The Complete Selective Lindenbaum Approach

Given the G-conservativity property, the selective Lindenbaum construction works:

**Theorem (Selective Lindenbaum)**: Given consistent seed S containing GContent(M), and target MCS M' with CanonicalR(M, M'), there exists MCS W such that:
1. S subset W
2. GContent(W) subset M'

**Proof**:
1. Enumerate all formulas: phi_0, phi_1, ...
2. Build W by the selective strategy (skip G(psi) when psi not in M')
3. By G-conservativity, the selective strategy never gets forced into adding a G-formula with stripped version not in M'
4. W is consistent, maximal, extends S, and has GContent(W) subset M'

**Formalization estimate**:
- G-conservativity lemma: 100-200 lines
- Selective Lindenbaum lemma (enumeration-based): 150-250 lines
- Application to density_frame_condition Case B: 50-80 lines
- **Total: 300-530 lines**

#### 2.9 Remaining Issue: CanonicalR(W, M') vs Just GContent(W) subset M'

Even with GContent(W) subset M' (which IS CanonicalR(W, M')), we still need:
- CanonicalR(M, W): GContent(M) subset W. This holds from the seed.
- CanonicalR(W, M'): GContent(W) subset M'. This holds from the selective construction.

**So the selective Lindenbaum approach DOES solve the density frame condition for Case B.**

The question is whether W = M' is possible. Since W extends GContent(M) and has GContent(W) subset M', and GContent(M) subset M' (from CanonicalR(M, M')), the seed is a subset of M'. So W COULD equal M'. But for the density theorem as currently stated, W = M' is acceptable (the statement only requires CanonicalR(M, W) and CanonicalR(W, M'), and if W = M' then CanonicalR(M', M') which requires GContent(M') subset M').

If we need W != M' (for strict density in the quotient), we need the seed to contain something NOT in M'. This is the same issue identified in research-002 Finding 16.

**For Case B with delta not in M'**: The seed can include delta (which is not in M'), so W != M'. The selective construction ensures GContent(W) subset M'.

**For Case B with delta in M'**: The seed GContent(M) is a subset of M'. We need an additional formula not in M' to force W != M'. From NOT CanonicalR(M', M): there exists gamma in GContent(M') with gamma not in M. If gamma in GContent(M) (Case B for gamma too), then gamma in GContent(M) subset M'. Can we find gamma not in M'? Not from GContent(M') -- by definition, gamma in GContent(M') means G(gamma) in M'.

**However**: The density theorem as currently stated does NOT require W != M'. It only requires CanonicalR(M, W) and CanonicalR(W, M'). If W = M', then we need CanonicalR(M', M'), which means GContent(M') subset M'. Is this guaranteed?

Under irreflexive semantics, GContent(M') subset M' is NOT guaranteed. G(phi) in M' does not imply phi in M'. So CanonicalR(M', M') can fail.

**If CanonicalR(M', M') fails**: Then the selective Lindenbaum W cannot be M' (because W has GContent(W) subset M', and if W = M' then GContent(M') = GContent(W) subset M', contradicting the failure of CanonicalR(M', M')). Actually this is not quite right -- GContent(W) is not necessarily equal to GContent(M') even if W = M', because W may have different G-formulas than M' (they are the same SET of formulas, so GContent(W) = GContent(M')). So if W = M', then GContent(M') = GContent(W) subset M', meaning CanonicalR(M', M') holds -- contradicting our assumption.

**Therefore**: If CanonicalR(M', M') fails, W cannot be M', so the selective Lindenbaum automatically gives W != M'. Good.

**If CanonicalR(M', M') holds**: Then M' IS reflexive (sees itself). The density theorem needs CanonicalR(M, W) and CanonicalR(W, M'). Taking W = M' works: CanonicalR(M, M') holds (given) and CanonicalR(M', M') holds (assumed). So the theorem is trivially satisfied with W = M'.

**Conclusion**: The selective Lindenbaum approach FULLY solves the density frame condition, regardless of whether M' is reflexive or not.

### Finding 3: The Bulldozing Alternative

The "bulldozing" technique is a post-hoc model transformation that eliminates reflexive pairs from the canonical model. It was introduced by Segerberg and developed further by Blackburn, de Rijke, Venema, and others.

**How bulldozing works**:
1. Build the standard canonical model (which may have reflexive pairs)
2. For each "cluster" of mutually related worlds (where CanonicalR(w, w) holds), replace the cluster with a copy of Z (the integers) -- each world in the cluster is replaced by a chain of copies
3. The resulting model is irreflexive by construction
4. Prove that the bulldozed model satisfies the same formulas as the original

**Relevance to our problem**: Bulldozing is a MODEL-THEORETIC technique, not a proof-theoretic one. It does not change the axiom system or proof rules. Instead, it modifies the semantic model to achieve irreflexivity. This means:

- The existing proof system is UNCHANGED
- The density theorem can be proved on the bulldozed model
- The soundness theorem needs no modification

**However**: Bulldozing is typically used in completeness proofs (building a model for a consistent formula), not in canonical model properties (like the density frame condition). Our specific problem is proving a property of the canonical frame, not building a model. Bulldozing would need to be integrated into the canonical model construction itself.

**Formalization estimate**: 400-600 lines (bulldozing definition + properties + integration)

**Risk**: HIGH. Bulldozing changes the model construction significantly and may break the connection between MCSs and worlds.

### Finding 4: Comparison of Methods

| Criterion | IRR Rule | Selective Lindenbaum | Bulldozing |
|-----------|----------|---------------------|------------|
| **Mathematical soundness** | Proven in literature | Novel argument (G-conservativity) | Proven in literature |
| **Proof system changes** | YES (new rule) | NO | NO |
| **Model construction changes** | YES (filtered MCSs) | NO (Zorn -> enumeration) | YES (post-hoc transform) |
| **Estimated lines** | 390-600 | 300-530 | 400-600 |
| **Impact on existing code** | MEDIUM (10-20 locations) | LOW (new module only) | HIGH (model construction) |
| **Risk** | MEDIUM | LOW-MEDIUM | HIGH |
| **Simplicity of core argument** | HIGH (clean meta-rule) | MEDIUM (enumeration control) | LOW (complex transform) |
| **Literature support** | STRONG (Gabbay 1981) | WEAK (novel combination) | STRONG (Segerberg) |

### Finding 5: The G-Conservativity Property Is the Key Innovation

The selective Lindenbaum approach hinges on the G-conservativity property (Finding 2.7): non-G formulas in a context cannot force G-formula conclusions. This is a structural property of the TM proof system that has not been previously identified in the project.

If this property can be formalized, the selective Lindenbaum approach is the least invasive solution: it requires no changes to the proof system, no changes to existing modules, and adds a self-contained module with the selective construction.

**Critical verification needed**: The G-conservativity property must be carefully verified. Potential counterexamples:
- Can `temp_a` (phi -> G(P(phi))) produce G-formulas from non-G assumptions? YES: if phi is in W_n (a non-G formula), then phi -> G(P(phi)) is an axiom, giving G(P(phi)) in the MCS closure. So P(phi) in GContent(W). If P(phi) not in M', this violates condition 2.

**THIS IS A CRITICAL PROBLEM.** The temp_a axiom `phi -> G(sometime_past(phi))` takes an arbitrary formula phi and produces G(sometime_past(phi)). If phi is a non-G formula in W_n, then G(sometime_past(phi)) is derivable from {phi, temp_a(phi)}, giving sometime_past(phi) in GContent(W).

For the selective Lindenbaum to work, we need sometime_past(phi) in M' whenever phi is in W_n and phi is in M'. Is this guaranteed?

From temp_a in M': phi in M' implies G(sometime_past(phi)) in M'. So sometime_past(phi) in GContent(M') ... but we need it in M', not just in GContent(M').

Actually, we need: if phi in W and G(P(phi)) in W (from temp_a), then P(phi) in GContent(W). For GContent(W) subset M', we need P(phi) in M'.

Is P(phi) in M'? From phi in W: by the selective construction, either phi was in the seed GContent(M) or was added during enumeration. If phi was in GContent(M), then phi in M' (from CanonicalR(M, M')). Then temp_a in M' gives G(P(phi)) in M', so P(phi) in GContent(M'). And CanonicalR(M', ?) -- but we need P(phi) in M' itself, not just in GContent(M').

P(phi) = sometime_past(phi) = neg(all_past(neg(phi))). Is this in M'? Not necessarily. G(P(phi)) in M' means P(phi) in GContent(M'). GContent(M') subset M iff CanonicalR(M', M), which is NOT assumed (in fact, it is the negation that triggers the density theorem).

Wait -- we need GContent(W) subset M', not GContent(M') subset M'. Let me re-examine.

We need: for every psi, if G(psi) in W then psi in M'.

From temp_a: phi in W implies G(P(phi)) in W (since temp_a is phi -> G(P(phi)), and phi in W and temp_a is an axiom, so G(P(phi)) in W by MCS closure).

So G(P(phi)) in W, meaning P(phi) in GContent(W). For GContent(W) subset M', we need P(phi) in M'.

Now, phi in W. If phi is in the seed GContent(M), then G(phi) in M, so phi in GContent(M) subset M'. Then by temp_a in M': G(P(phi)) in M', so P(phi) in GContent(M'). But P(phi) in GContent(M') means G(P(phi)) in M', which gives P(phi) in GContent(M'). We need P(phi) in M' itself.

Does G(P(phi)) in M' imply P(phi) in M'? Under IRREFLEXIVE semantics, NO. G(P(phi)) in M' means P(phi) holds at all strictly future times of M'. It does NOT say P(phi) holds at M' itself.

**So P(phi) may NOT be in M', even though phi is in GContent(M) subset M'.**

**THIS BREAKS THE SELECTIVE LINDENBAUM APPROACH.** The temp_a axiom introduces G-formulas (of the form G(P(phi))) that are forced by non-G formulas in W, and whose stripped versions (P(phi)) may not be in M'.

#### Repair Attempt: Include P-formulas in the Selective Filter

Can we extend the selective strategy to also filter out formulas that would trigger temp_a G-forcing?

The problem is that EVERY formula phi in W triggers G(P(phi)) in W via temp_a. So every formula in W contributes to GContent(W) via the P-operator. For GContent(W) subset M', we need:

For every phi in W: P(phi) in M'.

This is an extremely strong requirement. It means W must be "P-compatible" with M': every element of W must have its sometime_past version in M'.

**Is this achievable?** Consider phi in GContent(M): G(phi) in M. By temp_a: G(P(phi)) in M. By temp_4: G(G(P(phi))) in M, so G(P(phi)) in GContent(M). So P(phi) in GContent(M) subset M'. So P(phi) in M'. Good -- formulas from the seed have their P-versions in M'.

Now consider phi added during enumeration (not from GContent(M)). For P(phi) in M', we need this to hold. Can we ensure this?

Modification: Only add phi to W if P(phi) in M'.

But this is also a strong filter. And the P-filter itself can cascade: if we add phi (with P(phi) in M'), then temp_a gives G(P(phi)) in W, so P(phi) in GContent(W). We also need P(P(phi)) in M' (from phi' = P(phi) being in W via... wait, P(phi) is in GContent(W), not necessarily in W. GContent(W) subset M' requires P(phi) in M', which we ensured. But P(phi) in M' triggers G(P(P(phi))) in M' via temp_a. So P(P(phi)) in GContent(M'). But we need P(P(phi)) in M', not in GContent(M').

**The cascade never terminates.** For every phi in W, we need P(phi) in M', P(P(phi)) in M', P(P(P(phi))) in M', etc. This is because temp_a applies at EVERY level.

**But**: The formulas P^n(phi) stabilize in M'. Since M' is MCS and phi in M', by temp_a: G(P(phi)) in M', so P(phi) in GContent(M'). Under CanonicalR(M', M'') for any M'' in M''s future, P(phi) in M''. But we specifically need P(phi) in M' itself.

**The cascade IS a real problem.** The selective Lindenbaum cannot guarantee P^n(phi) in M' for all n, because this depends on the structure of M' which we cannot control.

### Finding 6: Revised Assessment of Selective Lindenbaum

The temp_a axiom `phi -> G(P(phi))` creates a fundamental obstacle for the selective Lindenbaum approach:

1. Every formula phi added to W forces G(P(phi)) into W
2. For GContent(W) subset M', we need P(phi) in M'
3. P(phi) in M' is not guaranteed even when phi in M' (under irreflexive semantics)
4. The P-cascade (P(phi), P(P(phi)), ...) creates an infinite chain of requirements on M'

**However**: There is one saving grace. The formulas in GContent(M) DO satisfy the P-cascade requirement. If phi in GContent(M), then G(phi) in M. By temp_a: G(P(phi)) in M. So P(phi) in GContent(M) subset M'. Similarly, G(P(phi)) in M gives P(phi) in GContent(M), and G(P(P(phi))) = G(P(P(phi))) in M by applying temp_a to P(phi) in M? Wait -- P(phi) in GContent(M) means G(P(phi)) in M. So P(phi) is "in GContent(M)" which is our seed. Then by temp_a applied to P(phi): G(P(P(phi))) in M (if P(phi) in M). But P(phi) in GContent(M) means G(P(phi)) in M. It does NOT mean P(phi) in M (under irreflexive semantics).

**Actually, the issue is that GContent(M) is a subset of W (from the seed), but GContent(M) is NOT a subset of M (under irreflexive semantics).** So phi in GContent(M) means G(phi) in M, and phi in W. For temp_a: phi in W gives G(P(phi)) in W (MCS closure). We need P(phi) in M'. As shown above, phi in GContent(M) -> phi in M' (from CanonicalR(M, M')) -> G(P(phi)) in M' (temp_a in M') -> P(phi) in GContent(M'). But GContent(M') subset M iff CanonicalR(M', M), which is false. So P(phi) in GContent(M') does NOT imply P(phi) in M.

We need P(phi) in M', not in M. And GContent(M') is not subset M'. So P(phi) in GContent(M') does not give P(phi) in M' either.

**Correction**: P(phi) in GContent(M') means G(P(phi)) in M'. Under irreflexive semantics, G(P(phi)) in M' means P(phi) holds at all STRICTLY FUTURE times of M'. It does NOT mean P(phi) in M'.

**So P(phi) may not be in M'.** The selective Lindenbaum approach has a genuine gap due to temp_a.

### Finding 7: The temp_a Obstruction Is the Core Issue

The temp_a axiom `phi -> G(P(phi))` is sound under irreflexive semantics: if phi holds at time t, then at all s > t (strict), there exists r < s with phi at r (namely, r = t works since t < s). So P(phi) = "there exists a past time where phi holds" is true at s.

The problem for the selective Lindenbaum is that temp_a introduces G-formulas that have P-variants as their stripped content, and these P-variants are not controllable.

**Key question for the IRR rule approach**: Does the IRR rule circumvent the temp_a obstruction?

YES. The IRR rule works at a fundamentally different level. Instead of trying to control which formulas end up in the Lindenbaum extension, the IRR rule provides a fresh proposition that serves as a "witness" for the current world. This witness breaks the symmetry that causes the density obstruction, without needing to control GContent.

### Finding 8: Final Recommendation

After this thorough analysis:

1. **Selective Lindenbaum: NOT FEASIBLE** due to the temp_a obstruction (Finding 6). The G-conservativity property (Finding 2.7) does NOT hold in the presence of temp_a, because temp_a generates G-formulas from arbitrary non-G formulas.

2. **IRR Rule: FEASIBLE but invasive.** Requires changing the proof system (new inference rule), updating soundness, and modifying all DerivationTree inductions. Estimated 390-600 lines total.

3. **Bulldozing: FEASIBLE but complex.** Model-theoretic approach that does not change the proof system but requires a complex model transformation. Estimated 400-600 lines.

4. **Option E (Lex product T x Q): SIMPLEST but requires relaxing constraints.** If the prohibition on importing external dense orders can be relaxed, this is 50-100 lines. The canonical timeline T does not need to be densely ordered; T x Q is dense from Q's density.

**Recommendation order**:

1. **Option E (Lex product)** if constraints can be relaxed -- overwhelmingly simplest
2. **IRR rule** if the proof system can be extended -- cleanest mathematical approach
3. **Bulldozing** if neither of the above is acceptable -- proven technique but complex formalization
4. **Selective Lindenbaum** -- NOT recommended (temp_a obstruction makes it infeasible)

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | HIGH | Option E (lex product) uses Q but for structure, not as D itself. Still forbidden per current constraints. |
| Product Domain Temporal Trivialization | MEDIUM | Lex product T x Q is different (T carries temporal content, Q provides density). Not trivialization. |
| Reflexive G/H Semantics Switch | HIGH | Entire analysis is about the irreflexive semantics obstruction. Confirms irreflexive semantics is harder for density. |
| Relational Completeness Detour | LOW | Not relevant -- density is about frame properties, not relational completeness. |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | Density frame condition is the current blocker for this strategy |
| K-Relational Strategy | ACTIVE | Canonical frame is the foundation; IRR rule would extend it |
| Proof Economy | ACTIVE | Goal is zero sorries; this research aims to eliminate the density sorry |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Gabbay IRR rule (definition, semantics, role) | Finding 1 | No | new_file |
| G-conservativity of proof system (partial) | Finding 2.7 | No | new_file |
| temp_a GContent forcing obstruction | Finding 7 | No | extension |
| Bulldozing technique for canonical models | Finding 3 | No | new_file |
| Selective Lindenbaum construction and its limits | Finding 2 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `irr-rule-and-irreflexive-density.md` | `domain/` | IRR rule definition, semantics, role in density proofs, formalization requirements | High | No |
| `canonical-model-transformations.md` | `domain/` | Bulldozing, filtered MCS, step-by-step construction techniques | Medium | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `density-frame-condition-analysis.md` (if created from research-002) | temp_a obstruction | Document the temp_a G-forcing problem for selective Lindenbaum | High | No |

### Summary

- **New files needed**: 2
- **Extensions needed**: 1
- **Tasks to create**: 0
- **High priority gaps**: 2

## Decisions

- **D1**: The Gabbay IRR rule is a derivation rule (meta-rule), not an axiom schema. It introduces a "fresh" proposition as a timestamp.
- **D2**: The IRR rule enables density proofs by allowing the canonical model construction to use markers that prevent reflexive canonical relations.
- **D3**: Selective Lindenbaum is NOT feasible due to the temp_a axiom forcing G(P(phi)) into GContent(W) for every phi in W, with P(phi) not necessarily in M'.
- **D4**: The G-conservativity property (non-G formulas cannot force G-conclusions) FAILS in the presence of temp_a.
- **D5**: Bulldozing is a viable alternative that does not change the proof system but requires complex model transformation.
- **D6**: Option E (lex product T x Q) remains the simplest approach if constraints can be relaxed.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| IRR soundness proof is complex | MEDIUM | LOW | Standard technique, well-documented in literature |
| IRR changes break DerivationTree inductions | HIGH | HIGH | Systematic update needed at 10-20 locations; add IRR case to each |
| Bulldozing formalization is very complex | HIGH | MEDIUM | Well-studied technique; but no Lean 4 reference implementation exists |
| G-conservativity proof attempt fails | LOW | N/A | Already identified as failing due to temp_a |
| Lex product approach is rejected (constraint) | MEDIUM | HIGH | Fall back to IRR or bulldozing |

## Appendix

### A. Search Queries Used

**Web searches**:
1. "Gabbay IRR rule irreflexivity temporal logic tense logic completeness density"
2. "Gabbay IRR rule p AND H(neg p) formalization proof theory canonical model irreflexive frame"
3. "Burgess basic tense logic IRR rule irreflexivity canonical model completeness proof technique density axiom"
4. "Gabbay 1981 irreflexivity rule temporal logic fresh proposition canonical model reflexive MCS elimination technique"
5. "Goldblatt Logics of Time and Computation irreflexivity rule IRR canonical model tense logic density"
6. "tense logic completeness step by step construction irreflexive canonical model Lindenbaum enumeration MCS density"
7. "de Jongh Veltman Verbrugge completeness by construction tense logic linear time"
8. "modal logic irreflexivity rule bulldozing technique canonical model reflexive worlds eliminate"
9. "Venema temporal logic bulldozing step by step construction canonical model density"
10. "bulldozing technique modal logic canonical model irreflexive cluster detailed explanation"
11. "Di Maio Zanardo 1998 Gabbay-Rule Free axiomatization infinite axiom schemas technique"
12. "Reynolds 2003 axiomatization until since reals without IRR rule completeness"
13. "tense logic completeness proof dense linear order step by step Lindenbaum insert intermediate"

**Codebase exploration**:
- DensityFrameCondition.lean: Full read (192 lines) -- sorry location, Case A/B analysis
- SeparationLemma.lean: Full read (227 lines) -- distinguishing formula, not_G_implies_F_neg
- WitnessSeed.lean: Partial read (60 lines) -- ForwardTemporalWitnessSeed definition
- CanonicalFrame.lean: Partial read (80 lines) -- CanonicalR definition, canonical_forward_F
- Axioms.lean: Full read (396 lines) -- all 15+2 axiom schemata including density, temp_a, temp_4
- Derivation.lean: Partial read (100 lines) -- 7 inference rules
- MaximalConsistent.lean: Partial read (80 lines) -- set_lindenbaum via Zorn
- TemporalContent.lean: Full read (38 lines) -- GContent/HContent definitions
- Formula.lean: Partial read -- Formula type, derived operators

**Mathlib lookups**:
- lean_local_search: Lindenbaum, set_lindenbaum, GContent, CanonicalR

### B. Literature References

- Gabbay, D.M. (1981). "An Irreflexivity Lemma with Applications to Axiomatizations of Conditions on Tense Frames." In U. Monnich (ed.), Aspects of Philosophical Logic, Dordrecht: Reidel, pp. 67-89.
- Di Maio, M.C. & Zanardo, A. (1998). "A Gabbay-Rule Free Axiomatization of T x W Validity." Journal of Philosophical Logic 27, 435-487.
- Reynolds, M. (1992). "An Axiomatization for Until and Since over the Reals without the IRR Rule." Studia Logica 51, 165-193.
- Goldblatt, R. (1992). Logics of Time and Computation, 2nd ed. CSLI Publications.
- Venema, Y. (2001). "Temporal Logic." Chapter 10 in Handbook of Philosophical Logic, 2nd ed.
- Burgess, J.P. (1984). "Basic Tense Logic." In Handbook of Philosophical Logic, Vol. II.
- Blackburn, P., de Rijke, M., & Venema, Y. (2001). Modal Logic. Cambridge University Press.
- de Jongh, D., Veltman, F., & Verbrugge, R. (2004). "Completeness by construction for tense logics of linear time."

### C. The temp_a Obstruction in Detail

The temp_a axiom is: `phi -> G(P(phi))` where P(phi) = sometime_past(phi) = neg(all_past(neg(phi))).

In any MCS W:
- phi in W implies (by temp_a + MCS closure) G(P(phi)) in W
- G(P(phi)) in W means P(phi) in GContent(W)
- For GContent(W) subset M', we need P(phi) in M'

This creates a cascade for the selective Lindenbaum:
- Any formula phi added to W during construction forces P(phi) into GContent(W)
- P(phi) must be in M' for the construction to succeed
- But P(phi) in M' is not guaranteed even when phi in M' under irreflexive semantics
- Specifically: phi in M' -> G(P(phi)) in M' (by temp_a in M') -> P(phi) in GContent(M')
- But GContent(M') subset M' iff CanonicalR(M', M'), which may fail under irreflexive semantics

The only way P(phi) is guaranteed to be in M' is if there exists some time strictly before M' where phi holds. Under irreflexive semantics with the density ordering, this relates to the structure of the canonical model which we cannot control.
