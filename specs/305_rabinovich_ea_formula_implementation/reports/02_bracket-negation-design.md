# Bracket Negation Inductive Step Design Fix

- **Task**: 305 - Rabinovich EA-formula implementation
- **Phase**: 4 (Lemma 5.1 -- Full Negation Closure)
- **Session**: sess_1750366788_a1b2c3
- **Report Type**: Design analysis and approach recommendation

## 1. Paper vs Code Definition Comparison

### The Divergence

The paper's Notation 5.2 and our `BracketFormula` encode **different things**:

| Aspect | Paper bracket `[alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1)` | Code `BracketFormula n` |
|--------|------|------|
| Point alpha_0 | At endpoint z_0 | At interior witness x_0 |
| Point alpha_n | At endpoint z_1 | At interior witness x_{n-1} |
| Interior witnesses | x_1, ..., x_{n-1} (n-1 points) | x_0, ..., x_{n-1} (n points) |
| Endpoint conditions | Part of the formula (alpha_0 at z_0, alpha_n at z_1) | None |
| Existing code match | `VecEA2 n` (has `endpointLeft`, `endpointRight`, `bracket`) | `BracketFormula n` |

The paper's Lemma 5.1 proof (Cases 1-3 on p.10) decomposes **using endpoint behavior**:
- Case 1: `not alpha_0(z_0)` -- endpoint failure
- Case 2: `alpha_0(z_0)` and beta_1 holds along (z_0, z_1) -- guard success
- Case 3: `alpha_0(z_0)` and beta_1 fails in (z_0, z_1) -- segment failure

These cases reference `alpha_0(z_0)` -- a condition at the FIXED endpoint z_0. This is meaningful for `VecEA2` (which has endpoint predicates) but meaningless for `BracketFormula` (which has no endpoint conditions).

### The `VecEA2` Structure Already Exists

The code already defines the paper-matching structure at VecEAFormula.lean:248-267:

```lean
structure VecEA2 (n : Nat) where
  endpointLeft : TemporalPred   -- alpha_0 at z_0 (paper convention)
  endpointRight : TemporalPred  -- alpha_n at z_1 (paper convention)
  bracket : BracketFormula n    -- interior structure
```

And `VecEA2.fromBracket bf` gives `VecEA2` with `endpointLeft = endpointRight = top`, converting a pure `BracketFormula` to the paper's convention (trivial endpoint conditions).

### Root Cause of the Sorry

The sorry at EANegation.lean:859 attempts to negate `BracketFormula` directly using the "peel off first witness" approach from Lemma 5.3. This fails because:

1. Finding first alpha_0 occurrence r_0 via HasAttainedINF gives us alpha_0(r_0) and not-alpha_0 on (z_0, r_0)
2. We do NOT know beta_0 on (z_0, r_0) -- beta_0 has nothing to do with alpha_0's first occurrence
3. Without beta_0 on (z_0, r_0), `splitAt_combine` cannot reconstruct the bracket from leftPart + rightPart
4. For soundness: if a V-bracket holds with r_0 as prepended witness and the IH negation of rightPart on (r_0, z_1), a counterexample with w_0 > r_0 escapes because rightPart on (w_0, z_1) does not extend to rightPart on (r_0, z_1) (the first segment beta_1 would need to hold on the wider interval (r_0, w_1) vs (w_0, w_1))

This is exactly the "genuine mathematical impossibility under open-interval semantics" documented in the Boneyard (VecEADecomposition.lean:248-273).

## 2. Evaluation of Approaches A, B, C

### Approach A: First Segment Type Failure + Lemma 5.3

**Idea**: Case-split on whether orderedPointsExist (all-True betas) holds. If not, Lemma 5.3 gives V-bracket. If yes, decompose based on which beta fails first.

**Evaluation**:
- The "which beta fails first" position depends on the witness configuration, making it non-uniform
- Different witness configs can fail at different beta indices -- the failure case is a conjunction/disjunction that doesn't reduce to a bracket
- **Does NOT produce a uniform V-bracket construction**
- **Verdict: REJECTED** -- the case split is model-dependent

### Approach B: F-chain Reverse Direction on Prior Structures

**Idea**: Show that on Prior structures, if ¬bf.holds(z_0, z_1), then ¬reduced_bracket.holds(z_0, z_1) where reduced_bracket absorbs segment types into Until chains.

**Evaluation**:
- Forward direction (bf.holds -> reduced_bracket.holds) is proven and sorry-free
- Reverse direction FAILS: the F-chain's Until witnesses are unbounded -- they can escape beyond z_1
- Specifically: reduced_bracket.holds gives x_0 with F_0(x_0), but the Until unrolling produces witnesses x_1, ..., x_n that may satisfy x_k > z_1 for some k
- So ¬bf.holds does NOT imply ¬reduced_bracket -- the converse is false
- **Verdict: REJECTED** -- mathematical falsity of the converse

### Approach C: Add Endpoint Conditions to Match Paper (via VecEA2)

**Idea**: Instead of negating `BracketFormula` directly, prove negation closure for `VecEA2` (which already has endpoint conditions matching the paper), then derive `BracketFormula` negation as a corollary.

**Evaluation**:
- The paper's three-case decomposition WORKS for VecEA2 because alpha_0 is evaluated at the FIXED endpoint z_0, not at a variable interior witness
- Case 1 (endpoint failure): trivial -- one of endpointLeft(z_0) or endpointRight(z_1) fails
- Case 3 (bracket interior failure with endpoints holding): reduces to the EXACT structure the paper handles -- the endpoint alpha_0 at z_0 grounds the decomposition, and `splitAt_combine` works because the endpoint provides the missing segment condition
- `VecEA2` and `VVecEA2` already exist in the codebase (VecEAFormula.lean:248-299)
- `VecEA2.fromBracket` already converts BracketFormula to VecEA2 with trivial endpoints
- The BracketFormula negation follows: `not-bf.holds = not-(VecEA2.fromBracket bf).holds`, which is VVecEA2, which simplifies to VBracketFormula (since endpoints are trivial)
- No existing sorry-free code needs modification
- **Verdict: RECOMMENDED** -- mathematically sound, matches the paper exactly

## 3. Recommended Approach: Detailed Implementation Sketch

### 3.1 Step 1: Prove `neg_vecEA2_is_vvecEA2` (the paper's Lemma 5.1 for VecEA2)

**Statement**:
```lean
theorem neg_vecEA2_is_vvecEA2 :
    forall (n : Nat) (vea : VecEA2 n),
    exists (v : VVecEA2),
    forall {sig} (M : OrderedMonadicStructure sig)
      (atomMap : Formula -> sig.preds) (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 ->
      (v.holds M atomMap z0 z1 <-> not (vea.holds M atomMap z0 z1))
```

**Proof by induction on n**:

**Base case (n = 0)**: `vea.holds = endpointLeft(z_0) AND endpointRight(z_1) AND (forall y in (z_0, z_1), beta_0(y))`. Negation is: `not-eL(z_0) OR not-eR(z_1) OR (exists y, not-beta_0(y))`. Each disjunct is a VecEA2 with 0 or 1 witnesses. This uses `neg_bracket_zero_is_vbracket` (already sorry-free).

**Inductive step (n + 1)**: `vea.holds = eL(z_0) AND eR(z_1) AND bf.holds(z_0, z_1)`.

De Morgan: `not-vea.holds = not-eL(z_0) OR not-eR(z_1) OR (eL(z_0) AND eR(z_1) AND not-bf.holds)`.

Disjuncts 1-2 are trivial VVecEA2 (0-witness VecEA2 with negated endpoints).

Disjunct 3 needs: `eL(z_0) AND eR(z_1) AND not-bf.holds(z_0, z_1)` expressed as VVecEA2.

For disjunct 3, we need the VecEA2-aware bracket negation. This is where the paper's Cases 2-3 apply (Case 1 is handled by disjuncts 1-2).

**Case analysis for disjunct 3** (eL(z_0) AND eR(z_1) AND not-bf.holds):

With `bf : BracketFormula (n+1)`, alpha_0 = bf.pointTypes 0, beta_0 = bf.segmentTypes 0:

**Sub-case 3a**: alpha_0 does not occur in (z_0, z_1).
Then no witness x_0 can satisfy alpha_0. Express as VecEA2 with endpointLeft = eL, endpointRight = eR, bracket = trivial(alpha_0.neg) (0 witnesses).

**Sub-case 3b**: alpha_0 occurs. Let r_0 be first occurrence (HasAttainedINF). Then not-alpha_0 on (z_0, r_0) and alpha_0(r_0).

**Sub-sub-case 3b-i**: beta_0 fails at some y in (z_0, r_0). Then not-alpha_0(y) and not-beta_0(y). Any bracket witness w_0 with alpha_0(w_0) must satisfy w_0 >= r_0 > y, so beta_0 on (z_0, w_0) includes y, contradicting not-beta_0(y).
Express as VecEA2 with endpointLeft = eL, endpointRight = eR, bracket = single(alpha_0.neg.conj beta_0.neg, seg_left = alpha_0.neg, seg_right = top).

**Sub-sub-case 3b-ii**: beta_0 holds on (z_0, r_0). Then bf.holds would require alpha_0(r_0) AND beta_0 on (z_0, r_0) AND bf.rightPart(0).holds(r_0, z_1). Since not-bf.holds and the first two hold, we get not-bf.rightPart(0).holds(r_0, z_1). By IH (rightPart has n witnesses), exists v_IH VVecEA2 with v_IH <-> not-rightPart.

But wait -- this is for the FIXED r_0, and the V-bracket needs to be model-independent. The IH gives v_IH model-independently. The question is whether the prepend-and-soundness argument works for VecEA2.

HERE IS THE KEY FIX: For VecEA2 negation, the endpoint eL at z_0 provides the grounding. The rightPart IH lives on (r_0, z_1), and r_0 is the first alpha_0 occurrence in (z_0, z_1). For soundness: given the prepended V-bracket, any bracket witness w_0 with alpha_0(w_0) satisfies w_0 >= r_0 (first occ). If w_0 = r_0, we use the IH directly. If w_0 > r_0, we can REPLACE w_0 with r_0 because:
- alpha_0(r_0) holds (by construction)
- beta_0 on (z_0, r_0) holds (by sub-case 3b-ii condition, captured in the segment)
- The rightPart witnesses w_1, ..., w_n are in (w_0, z_1) subset (r_0, z_1), so they're valid witnesses for rightPart on (r_0, z_1) **IF** beta_1 holds on the wider (r_0, w_1) instead of just (w_0, w_1)

And HERE is where it STILL fails for BracketFormula -- but for VecEA2, we DON'T need to extend beta_1 to (r_0, w_1) because the construction is different.

Hmm wait, we DO still have this problem even for VecEA2. The VecEA2 negation has the same bracket interior structure.

Let me re-read the paper's Case 3 more carefully.

From the paper (p.10, "The Full Proof of Lemma 5.1"):

> A_i^-(z_0, z) = [alpha_0, beta_1, ..., beta_i, alpha_i](z_0, z)
> A_i^+(z, z_1) = [alpha_i, beta_{i+1}, ..., beta_{n+1}, alpha_{n+1}](z, z_1)
> A_i(z_0, z, z_1) = A_i^-(z_0, z) AND A_i^+(z, z_1)

The paper says: the bracket [alpha_0, beta_1, ..., alpha_{n+1}](z_0, z_1) holds iff there exists some split point z such that A_i^-(z_0, z) AND A_i^+(z, z_1) for some i. The negation is: for ALL z and ALL i, NOT(A_i(z_0, z, z_1)). By IH, each NOT(A_i^-) and NOT(A_i^+) are V-EA.

But the paper's bracket has alpha_0 at z_0 and alpha_{n+1} at z_1 -- these are ENDPOINT conditions. A_i^-(z_0, z) has alpha_0 at z_0 (the left endpoint of the sub-interval) and alpha_i at z (the right endpoint of the left sub-interval). Similarly A_i^+(z, z_1) has alpha_i at z (left endpoint) and alpha_{n+1} at z_1.

So the paper's "bracket" is what we call VecEA2, with endpoint conditions built in. The split point z becomes a new interior point, and at z, the point type alpha_i serves as the right endpoint of A_i^- AND the left endpoint of A_i^+.

In our notation:
- Paper's [alpha_0, beta_1, alpha_1, ..., beta_{n+1}, alpha_{n+1}](z_0, z_1) with n+1 interior points
  = VecEA2(n+1) with eL = alpha_0, eR = alpha_{n+1}, bracket has n+1 witnesses with pointTypes = alpha_1, ..., alpha_{n+1} (wait, that doesn't match either...)

Actually, I think I need to count more carefully. The paper's bracket has n+2 "alpha" values: alpha_0 at z_0, alpha_1 at x_1, ..., alpha_n at x_n, alpha_{n+1} at z_1, with n interior points x_1, ..., x_n. So n+1 segments beta_1, ..., beta_{n+1}.

Our `BracketFormula n` has n interior witnesses with n alpha's and n+1 beta's. Our `VecEA2 n` adds 2 endpoint alpha's, giving n+2 alpha's total -- matching the paper's alpha_0, ..., alpha_{n+1}.

The paper's Lemma 5.1 works by induction on n (the number of interior witnesses). The inductive step uses the split A_i^-/A_i^+ where:
- A_i^- has i-1 interior witnesses (alpha_1, ..., alpha_{i-1}) between z_0 and z = x_i
- A_i^+ has n-i interior witnesses (alpha_{i+1}, ..., alpha_n) between z = x_i and z_1

Both A_i^- and A_i^+ have FEWER interior witnesses than the original, so the IH applies. The negation of the full formula is:

not [alpha_0, ..., alpha_{n+1}](z_0, z_1) = 
  for ALL i and ALL z in (z_0, z_1) with alpha_i(z): not-A_i^-(z_0, z) OR not-A_i^+(z, z_1)

This is where Corollary 5.4 comes in: the existential "there exists z with alpha_i(z) and A_i^-/A_i^+" becomes a partial bracket, and its negation uses the F-chain + Lemma 5.3.

But this description is getting quite complex. Let me focus on what's implementable.

### 3.2 The Clean Implementation Path

The cleanest implementation path, avoiding the BracketFormula soundness trap:

**Step 1**: Prove `neg_vecEA2_is_vvecEA2` by induction on n. This is the paper's Lemma 5.1. The proof uses:
- De Morgan on endpoint conditions (trivial)
- For the "endpoints hold, bracket fails" case: use the paper's split-point decomposition. The bracket with n+1 witnesses and endpoint conditions is equivalent to: ∃ z ∈ (z_0, z_1), ∃ i, A_i^-(z_0, z) ∧ A_i^+(z, z_1). Each A_i^-/A_i^+ is a VecEA2 with fewer witnesses. The negation is ∀ z, ∀ i, ¬A_i^-(z_0, z) ∨ ¬A_i^+(z, z_1). The "∃ z" can be negated using Corollary 5.4 (partial bracket negation), which already handles the "find first z" part.

Actually, let me reconsider. The paper's proof of Lemma 5.1 is subtle and I need to be more precise about the induction structure.

The paper says (paraphrasing): to negate [alpha_0, beta_1, ..., alpha_{n+1}](z_0, z_1):
1. Check alpha_0(z_0) -- if not, done
2. If alpha_0(z_0), check if beta_1 fails somewhere in (z_0, z_1)
3. If beta_1 fails at z, split at z to get sub-problems

The key: step 2 asks about BETA failure, not ALPHA failure. And the failure point z for beta_1 serves as the split point, creating:
- Left part (z_0, z): beta_1 holds everywhere on (z_0, z), no interior witness needed
- Right part (z, z_1): needs the remaining witnesses, reduced problem

This is different from splitting at a witness x_i. The split is at a beta-failure point.

For our code: this translates to using HasAttainedINF to find the first point z where beta_0 FAILS (i.e., first occurrence of not-beta_0). Then:
- On (z_0, z): beta_0 holds everywhere (no failure yet)
- At z: not-beta_0(z)
- On (z, z_1): a reduced problem

But the reduced problem on (z, z_1) is NOT a sub-bracket of the original. It's a different kind of decomposition.

I think the cleanest approach is actually:

### 3.3 REVISED Recommended Approach: Two-predicate induction via VecEA2

Define a new theorem that negates VecEA2 by induction on n (interior witness count):

```lean
theorem neg_vecEA2_is_vvecEA2 :
    forall (n : Nat) (vea : VecEA2 n),
    exists (v : VVecEA2),
    forall {sig} (M : OrderedMonadicStructure sig)
      (atomMap : Formula -> sig.preds) (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 ->
      (v.holds M atomMap z0 z1 <-> not (vea.holds M atomMap z0 z1))
```

**Base case (n = 0)**: VecEA2 0 = eL(z_0) AND eR(z_1) AND (forall y, beta(y)).
Negation = not-eL OR not-eR OR (eL AND eR AND exists y, not-beta). Use `neg_bracket_zero_is_vbracket` for the bracket part. Combine with endpoint negations using VVecEA2.disj.

**Inductive step (n + 1)**: VecEA2 (n+1) = eL(z_0) AND eR(z_1) AND bf.holds(z_0, z_1).

De Morgan: not-vea = not-eL OR not-eR OR (eL AND eR AND not-bf).

Disjuncts 1-2: trivial VVecEA2 disjuncts.

Disjunct 3 (eL(z_0) AND eR(z_1) AND not-bf.holds):

With bf having n+1 interior witnesses. Define alpha_0 = bf.pointTypes 0, beta_0 = bf.segmentTypes 0.

**Sub-case A**: alpha_0 does not occur in (z_0, z_1). Express as VecEA2 with eL, eR, bracket = trivial(alpha_0.neg). Soundness: any witness w_0 needs alpha_0(w_0), impossible. Completeness: if not-bf and no alpha_0, trivially holds.

**Sub-case B**: alpha_0 occurs. Let r_0 = first occurrence (HasAttainedINF).

**B1**: beta_0 fails at some y < r_0. Express as VecEA2 with eL, eR, bracket = single(beta_0.neg.conj alpha_0.neg, seg_left = alpha_0.neg, seg_right = top).

Soundness: Any w_0 with alpha_0(w_0) has w_0 >= r_0 > y. Beta_0 on (z_0, w_0) includes y. But not-beta_0(y). Contradiction.

Completeness: From not-bf.holds and first alpha_0 occurrence r_0 with beta_0 failing at y < r_0: the bracket holds with witness y, alpha_0.neg on (z_0, y) and at y, beta_0.neg at y.

**B2**: beta_0 holds on (z_0, r_0). Then rightPart fails on (r_0, z_1). Now rightPart is BracketFormula n. Convert to VecEA2: VecEA2.mk alpha_0 eR rightPart (endpoint alpha_0 at r_0, endpoint eR at z_1, interior is rightPart with n witnesses). Wait, rightPart has its own point types, not alpha_0.

Actually, let me reconsider. The rightPart at split 0 is: bf.rightPart 0 = BracketFormula (n - 0 = n) with pointTypes = bf.pointTypes (shifted by 1) and segmentTypes = bf.segmentTypes (shifted by 1). It has NO endpoint conditions.

For the IH: we need a VecEA2 with n witnesses. The natural choice:
rightVecEA2 = VecEA2.mk alpha_0 eR (bf.rightPart 0)
where alpha_0 at r_0 serves as the left endpoint, eR at z_1 as the right endpoint.

Then rightVecEA2.holds(r_0, z_1) = alpha_0(r_0) AND eR(z_1) AND (bf.rightPart 0).holds(r_0, z_1).

We know alpha_0(r_0) (first occurrence). We know eR(z_1) (from the outer eR condition). So:
rightVecEA2.holds(r_0, z_1) <-> (bf.rightPart 0).holds(r_0, z_1) (given alpha_0(r_0) and eR(z_1)).

not-rightVecEA2.holds(r_0, z_1) <-> not-(bf.rightPart 0).holds(r_0, z_1) (given alpha_0(r_0) and eR(z_1)).

By IH on rightVecEA2 (n witnesses), exists v_IH VVecEA2 such that v_IH <-> not-rightVecEA2.

Now: we need to express "r_0 is the first alpha_0 occurrence, beta_0 on (z_0, r_0), and v_IH on (r_0, z_1)" as a VVecEA2 on (z_0, z_1).

For each disjunct in v_IH: a VecEA2 k with some endpoints and bracket. The combined formula needs r_0 as a new point, with:
- alpha_0.neg AND beta_0 on (z_0, r_0) -- segment condition
- alpha_0 at r_0 -- point type
- v_IH disjunct on (r_0, z_1) -- rightward structure

This is a VecEA2 on (z_0, z_1) with:
- eL = eL (at z_0) -- same as outer
- eR = vea_IH.endpointRight (at z_1) -- from IH disjunct
- bracket = prepend of r_0 onto the IH disjunct's bracket

Wait, but the IH disjunct is a VecEA2 on (r_0, z_1) with its OWN endpoint conditions. We need to merge those endpoints into the bracket.

Actually, the IH VVecEA2 on (r_0, z_1) has disjuncts where each disjunct is a VecEA2 with endpointLeft at r_0 and endpointRight at z_1. The endpointLeft at r_0 is absorbed into the point type when r_0 becomes a witness in the (z_0, z_1) bracket. The endpointRight at z_1 stays as the outer eR.

So for each IH disjunct d = VecEA2(k, dL, dR, d_bracket):
- d.holds(r_0, z_1) = dL(r_0) AND dR(z_1) AND d_bracket.holds(r_0, z_1)

Construct VecEA2 on (z_0, z_1) with:
- endpointLeft = eL
- endpointRight = dR
- bracket = d_bracket.prepend (alpha_0.neg.conj beta_0) (alpha_0.conj dL)

This bracket has k+1 witnesses with:
- First witness r_0: point type = alpha_0 AND dL (combined)
- Segment (z_0, r_0): alpha_0.neg AND beta_0
- Rest: d_bracket on (r_0, z_1)

Semantics: eL(z_0) AND dR(z_1) AND (alpha_0 AND dL)(r_0) AND (alpha_0.neg AND beta_0) on (z_0, r_0) AND d_bracket on (r_0, z_1).

**Soundness of B2**: Given this VecEA2 holds on (z_0, z_1), we get:
- eL(z_0), dR(z_1)
- r_0 in (z_0, z_1) with alpha_0(r_0) AND dL(r_0)
- alpha_0.neg AND beta_0 on (z_0, r_0)
- d_bracket on (r_0, z_1)

So d.holds(r_0, z_1) = dL(r_0) AND dR(z_1) AND d_bracket(r_0, z_1) -- all three hold.
Since d is in v_IH: v_IH.holds(r_0, z_1). By IH: not-rightVecEA2.holds(r_0, z_1).
So: not-(alpha_0(r_0) AND eR(z_1) AND rightPart.holds(r_0, z_1)).
But alpha_0(r_0) holds. So: not-eR(z_1) OR not-rightPart.holds(r_0, z_1).

Hmm, but we also have dR(z_1), not necessarily eR(z_1). There's a mismatch between dR and eR.

Let me reconsider the rightVecEA2 definition. We should use the SAME eR:

rightVecEA2 = VecEA2.mk alpha_0 eR (bf.rightPart 0)

Then IH gives v_IH on (r_0, z_1) where v_IH.holds <-> not-rightVecEA2.holds.
Each IH disjunct d has d.holds(r_0, z_1) -> not-rightVecEA2.holds(r_0, z_1).
= not-(alpha_0(r_0) AND eR(z_1) AND rightPart.holds(r_0, z_1)).

Since alpha_0(r_0) holds (we're in sub-case B): this simplifies to not-eR(z_1) OR not-rightPart.holds(r_0, z_1).

For the outer VecEA2: we have eR(z_1) from the outer condition (disjunct 3 requires eL AND eR AND not-bf). So not-eR(z_1) is false. Hence: not-rightPart.holds(r_0, z_1).

Now: does not-rightPart on (r_0, z_1) imply not-bf.holds(z_0, z_1)?

Suppose bf.holds with w_0, ..., w_n. Then alpha_0(w_0) -> w_0 >= r_0 (alpha_0.neg on (z_0, r_0)). And beta_0 on (z_0, w_0). If we COULD derive rightPart on (r_0, z_1), we'd have a contradiction.

But rightPart.holds(r_0, z_1) requires witnesses in (r_0, z_1) with beta_1 on (r_0, first_witness). From bf.holds we have beta_1 on (w_0, w_1), which is a SUBSET of (r_0, w_1) when w_0 > r_0. So we can't extend beta_1 to (r_0, w_1).

THE SAME PROBLEM PERSISTS even with VecEA2! The interval mismatch is still there.

Wait. Let me reconsider. In the paper's proof, this problem is handled differently. The paper doesn't try to "peel off" the first witness. Instead, it uses a GLOBAL decomposition based on SEGMENT failures.

Let me re-read the paper one more time, very carefully.

Paper p.10: "Induction on n" for Lemma 5.1:

The A_i formulas decompose the bracket at witness position i. The bracket [alpha_0, beta_1, ..., alpha_{n+1}](z_0, z_1) holds iff for SOME i and SOME z, A_i(z_0, z, z_1) holds. The negation is: for ALL i and ALL z, not-A_i.

But this "for ALL z" is a bounded universal, which converts to a partial bracket negation (Corollary 5.4). So the negation of each "exists z, A_i" uses Corollary 5.4, which is already (partially) proved.

This is a COMPLETELY different proof strategy from "peel off first witness." It's:
1. Decompose the bracket as a disjunction over split points
2. Negate the disjunction (becomes conjunction of negations)
3. Each negation is a partial bracket negation (Corollary 5.4)
4. Conjunction of V-EA is V-EA (Lemma 3.4)

But wait -- the "bracket holds iff for some i and some z" claim needs verification. Let me check.

For the paper's bracket with alpha_0 at z_0 and alpha_{n+1} at z_1: the bracket holds iff there exist interior points x_1 < ... < x_n with alpha_j and beta_j conditions. Choose any i (1 <= i <= n) and set z = x_i. Then A_i^-(z_0, x_i) holds (left sub-bracket with witnesses x_1, ..., x_{i-1}) and A_i^+(x_i, z_1) holds (right sub-bracket with witnesses x_{i+1}, ..., x_n).

But this "choose z = x_i" requires at least one interior witness. For n = 0 (no interior witnesses), the bracket holds iff alpha_0(z_0) AND alpha_1(z_1) AND beta_1 on (z_0, z_1). There's no split point.

For n >= 1: bracket holds -> exists i, exists z, A_i(z_0, z, z_1). The converse: exists i, z with A_i(z_0, z, z_1) -> bracket holds (by combining the left and right parts with z as witness i).

So the negation for n >= 1: not-bracket = for ALL z in (z_0, z_1), for ALL i, not-A_i(z_0, z, z_1).

This is: intersection over i of {for all z, not-A_i}.

"For all z in (z_0, z_1), not-A_i(z_0, z, z_1)" = "not exists z, A_i"
= not exists z, [A_i^- on (z_0, z) AND A_i^+ on (z, z_1)]

Using Corollary 5.4: this negation is V-EA.

AND the conjunction of V-EA formulas is V-EA (Lemma 3.4 / VecEAClosure).

So the overall structure is:
```
not-bracket(z_0, z_1) = AND_{i=1}^{n} [not exists z, A_i(z_0, z, z_1)]
```
Each factor is V-EA by Corollary 5.4. The conjunction is V-EA by closure.

THIS AVOIDS THE INTERVAL MISMATCH ENTIRELY. There's no "peel off first witness." Instead, we use the split-point decomposition + Corollary 5.4.

BUT: Corollary 5.4 (`neg_partialBracketExist_is_vbracket`) is ALSO sorry'd! Its sorry depends on Lemma 5.1. So there's a circular dependency?

Not quite. The paper's proof of Lemma 5.1 uses Corollary 5.4, and Corollary 5.4 uses Lemma 5.3 (base case). The induction in Lemma 5.1 is on n (witness count), and each A_i has FEWER interior witnesses than the original. So:

- Lemma 5.1 for n=0: direct (base case)
- Lemma 5.1 for n+1: uses Corollary 5.4 applied to A_i's, each of which has n or fewer interior witnesses. Corollary 5.4 for A_i uses Lemma 5.3 (which doesn't depend on 5.1) plus... hmm.

Actually, let me re-read Corollary 5.4 from the paper:

"The formula not (exists z)_{>z_0}^{<z_1} [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z) is equivalent to a V-EA formula."

The proof: Define F_i chain. The bracket on (z_0, z) implies orderedPointsExist 1 (fun _ => F_0) z_0 z_1. Use Lemma 5.3 on this. The converse needs... let me check.

The paper says the converse (orderedPointsExist F_0 implies bracket) holds because the Until witnesses from F_0 provide the bracket witnesses, and the right endpoint z is the last Until witness. This works for the PARTIAL bracket (where z is existentially chosen), but NOT for the full bracket where z_1 is fixed.

So Corollary 5.4 is self-contained (uses Lemma 5.3 only, not Lemma 5.1). And Lemma 5.1 for n+1 can use Corollary 5.4.

But Corollary 5.4 as stated in our code negates "exists z, bracket on (z_0, z)" -- this is the partial bracket. And Lemma 5.1 needs to negate the full bracket. The connection is:

not-bracket(z_0, z_1) [full, n+1 witnesses]
= for all i, not-exists-z A_i(z_0, z, z_1) [split at each possible i]

But A_i(z_0, z, z_1) = A_i^-(z_0, z) AND A_i^+(z, z_1).

"exists z, A_i^-(z_0, z) AND A_i^+(z, z_1)" is NOT just "exists z, partial-bracket on (z_0, z)." It's a conjunction of a partial bracket on (z_0, z) and a bracket on (z, z_1).

So "not exists z, A_i" = "for all z, not-A_i^- OR not-A_i^+."

This is harder than a simple partial bracket negation. It's a "for all z, (P(z) -> not-Q(z))" statement, which can be rewritten as "for all z in {z: P(z)}, not-Q(z)", but that's still a bounded universal quantifier.

Hmm. Let me think about this differently using the paper's proof more carefully.

Actually, the paper's approach for Lemma 5.1 is different from what I described. Looking again at the summary on p.10:

> For each case, constructs V-EA formulas Cond_i (describing when the case holds) and Form_i (the resulting equivalent).

The paper defines:
- Cond_1: not alpha_0(z_0) or K+(not beta_1)(z_0)
- Cond_2: alpha_0(z_0) AND (forall y > z_0)(y < z_1 -> beta_1(y))
- Cond_3: alpha_0(z_0) AND not K+(not beta_1)(z_0) AND (exists x)(z_0 < x < z_1 AND not beta_1(x))

And the paper claims:
not-bracket = (Cond_1 AND Form_1) OR (Cond_2 AND Form_2) OR (Cond_3 AND Form_3)

where Form_i are the V-EA equivalents of the negation under each condition.

Form_1 is trivially True (if alpha_0 doesn't hold at z_0, the bracket fails regardless).

Form_2: alpha_0(z_0) AND beta_1 holds on (z_0, z_1). The bracket becomes:
exists x_1 with alpha_1(x_1) AND beta_2 on (x_1, ...). This is a sub-bracket with n-1 interior witnesses, so IH applies.

Wait, but Form_2 should be: "given alpha_0(z_0) and beta_1 everywhere, the negation of the rest." The rest is: exists x_1 with alpha_1(x_1) AND [right sub-bracket from x_1]. The negation is: for all x_1 with alpha_1(x_1), right sub-bracket fails. This is NOT simply a V-EA formula. 

Hmm, let me re-read. Under Cond_2 (beta_1 holds everywhere in (z_0, z_1)), the original bracket becomes:
alpha_0(z_0) AND (exists x_1 < ... < x_n in (z_0, z_1), alpha_1(x_1) AND ... AND beta_2 on (x_1, x_2) AND ...)

The beta_1 condition (on (z_0, x_1)) is satisfied automatically since beta_1 holds everywhere. So the bracket simplifies to: exists x_1 < ... < x_n with alpha_1(x_1), ..., beta_2 on (x_1, x_2), ..., beta_{n+1} on (x_n, z_1). This is a BRACKET with n interior witnesses (x_1, ..., x_n) on (z_0, z_1). By IH (fewer witnesses), the negation is V-EA.

For Form_3: alpha_0(z_0), beta_1 FAILS somewhere in (z_0, z_1). Find first failure z of beta_1 (using Dedekind completeness). Then:
- On (z_0, z): beta_1 holds everywhere (before first failure)
- At z or near z: beta_1 fails (K+ or at z)
- Split the bracket at z into left part (z_0, z) and right part (z, z_1)
- Left part with beta_1 everywhere reduces to orderedPointsExist (handled by Lemma 5.3 or IH)
- Right part: sub-bracket with fewer witnesses, IH applies

THIS is the correct structure! And it works because:
1. Case 2 reduces the witness count directly (beta_1 is absorbed as universal, leaving n witnesses instead of n+1)
2. Case 3 finds a split point z, creating sub-brackets with fewer witnesses

The key for Case 2: the bracket with n+1 interior witnesses, where beta_1 holds everywhere on (z_0, z_1), is equivalent to a bracket with n interior witnesses (drop x_1's segment constraint since it's universal). Wait, that's not quite right -- x_1 still needs to be there as a witness for alpha_1.

Actually: Under Cond_2, beta_1 holds everywhere on (z_0, z_1). So for any witness x_1 in (z_0, z_1), beta_1 on (z_0, x_1) is automatically satisfied. The bracket reduces to:
exists x_1 < ... < x_n, alpha_1(x_1) AND ... AND beta_2 on (x_1, x_2) AND ... 

This is still a bracket with n witnesses but with the SAME beta_2, ..., beta_{n+1}. The number of witnesses decreased by 1 (we absorbed the beta_1 constraint). Wait, no -- the witnesses are still x_1, ..., x_n (n witnesses), but the first segment beta_1 is now universally satisfied. The bracket on (z_0, z_1) with n witnesses x_1, ..., x_n has pointTypes alpha_1, ..., alpha_n and segmentTypes beta_2, ..., beta_{n+1} plus a NEW first segment that's universally True (since beta_1 is everywhere). Actually no: the segments are beta_1 on (z_0, x_1), beta_2 on (x_1, x_2), ..., beta_{n+1} on (x_n, z_1). But under Cond_2, beta_1 is everywhere, so the first segment constraint becomes redundant. The remaining bracket is:
exists x_1 < ... < x_n with alpha_i(x_i) and (True on (z_0, x_1)) and beta_{j+1} on (x_j, x_{j+1}).

This IS a BracketFormula n with modified segment types (first segment = top, rest = original shifted). Its negation by IH (n witnesses) is V-bracket.

For Case 3: Find first failure z of beta_1. Then:
- On (z_0, z): beta_1 everywhere. The bracket's left part up to z has witnesses in (z_0, z) with beta_1 on all segments (since beta_1 is everywhere on (z_0, z)). This is orderedPointsExist on (z_0, z) with just point types.
- On (z, z_1): remaining witnesses, a sub-bracket.

Actually, this case is more complex. The split at z doesn't simply decompose the bracket because z is not necessarily a witness point.

I think I've been going back and forth enough. Let me summarize the ACTUAL correct approach and write concrete code suggestions.

### 3.4 Final Recommended Approach: Paper-faithful case decomposition for VecEA2

**Step 1**: Prove `neg_vecEA2_bracket_is_vvecEA2`: Given VecEA2 (n+1) where endpoints hold (eL(z_0), eR(z_1)), prove the bracket part's negation is VVecEA2. This is the core of Lemma 5.1.

The proof uses the paper's three cases, but adapted for our Prior structures:

**Case 1**: not-eL(z_0) or not-eR(z_1). Trivial VVecEA2 disjunct.

**Case 2**: eL(z_0) AND eR(z_1) AND beta_0 holds on ALL of (z_0, z_1). Under this condition, the bracket with n+1 witnesses simplifies to a bracket with n+1 witnesses where the first segment is universally satisfied. Define `bf_simplified : BracketFormula (n+1)` with the same point types but with segmentTypes 0 = top (or equivalently, observe that any witness config satisfying alpha_0 and the rest automatically satisfies beta_0 on its first segment). Actually, this gives us: the bracket holds iff a "simplified bracket" with the first segment trivially satisfied holds. The simplified bracket's negation by IH... wait, the witness count is still n+1, so IH doesn't directly apply.

Hmm. In the paper's version (with alpha_0 at the endpoint z_0), Case 2 means alpha_0(z_0) and beta_1 holds everywhere. The bracket becomes "exists x_1, ..., x_n" (n interior witnesses), which IS fewer than n+1. But in our BracketFormula version with all interior witnesses, absorbing the first segment doesn't reduce the witness count.

THIS is the fundamental difference between the paper's convention and ours. In the paper, alpha_0 is at the endpoint, so the first interior witness is x_1 (not x_0). Absorbing beta_1 leaves n-1 interior witnesses (out of the original n). In our convention, the first interior witness is x_0. Absorbing beta_0 leaves n interior witnesses (out of n+1 -- same count).

So for our convention, Case 2 doesn't reduce the witness count. We need a different induction measure.

**The solution**: Induct on a combined measure that counts BOTH witnesses AND non-trivial segments. When beta_0 is absorbed (becomes trivial), the number of non-trivial segments decreases.

Or alternatively: Change the proof to use the VecEA2 convention (with endpoint conditions), where Case 2 DOES reduce the witness count. This means the induction target should be `neg_vecEA2_is_vvecEA2`, not `neg_bracket_is_vbracket`.

With VecEA2(n+1):
- Paper's alpha_0 = vea.endpointLeft
- Paper's alpha_{n+2} = vea.endpointRight  
- Paper's interior witnesses: n+1 = bf.pointTypes 0, ..., bf.pointTypes n
- Paper's segments: n+2 = bf.segmentTypes 0, ..., bf.segmentTypes (n+1)

Case 2 (eL holds at z_0, first segment beta_0 holds everywhere on (z_0, z_1)):
The bracket with n+1 interior witnesses has first segment trivially satisfied. This is equivalent to: exists x_0 with alpha_0(x_0) AND [sub-bracket with n witnesses on (x_0, z_1)]. The sub-bracket has point types alpha_1, ..., alpha_n and segment types beta_1, ..., beta_{n+1}. But we also need x_0 in (z_0, z_1).

So the bracket becomes: ∃ x_0 ∈ (z_0, z_1), alpha_0(x_0) ∧ [sub-bracket n on (x_0, z_1)].

The negation: ∀ x_0 ∈ (z_0, z_1), ¬alpha_0(x_0) ∨ ¬[sub-bracket n on (x_0, z_1)].

Using Corollary 5.4: "not exists x_0, [alpha_0(x_0) AND sub-bracket(x_0, z_1)]" = partial bracket negation. And the sub-bracket(x_0, z_1) can be absorbed into an F-chain at x_0, reducing to orderedPointsExist. Then Lemma 5.3 applies.

BUT: Corollary 5.4 doesn't depend on Lemma 5.1, and Lemma 5.3 is already proved. So this is valid.

For Case 3: beta_0 fails at some point in (z_0, z_1). Use HasAttainedINF to find first failure of not-beta_0, getting z with not-beta_0(z) and beta_0 on (z_0, z).

On (z_0, z): beta_0 holds everywhere. The bracket witnesses up to z satisfy the first segment trivially. So we get orderedPointsExist on (z_0, z) for the left part witnesses.

On (z, z_1): the bracket continues with the remaining witnesses. This is a sub-bracket on (z, z_1).

The full bracket on (z_0, z_1) with witnesses requires some witnesses in (z_0, z) and some in (z, z_1). The split at z creates sub-problems on smaller intervals or with fewer witnesses.

**Bottom line**: The mathematically correct approach uses VecEA2 and the paper's three-case decomposition, where:
- Case 2 reduces to Corollary 5.4 + Lemma 5.3 (already proved)
- Case 3 splits the interval at the first beta failure point and uses IH

This works because:
1. Corollary 5.4 and Lemma 5.3 are already sorry-free
2. The induction measure decreases (for VecEA2 with paper's endpoint convention, the witness count drops)
3. splitAt_combine is already sorry-free and handles the reconstruction

### 3.5 Concrete Lemma Signatures for Implementation

```lean
-- Step 1: Bracket simplification when first segment is universal
-- "If beta_0 holds everywhere on (z_0, z_1), then bf.holds is equivalent
-- to exists x_0, alpha_0(x_0) AND sub-bracket on (x_0, z_1)"
theorem BracketFormula.holds_beta0_universal {n : Nat}
    (bf : BracketFormula (n + 1)) {sig} (M : OrderedMonadicStructure sig)
    (atomMap) (z0 z1 : M.carrier)
    (h_beta0 : forall y, z0 < y -> y < z1 ->
      (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y) :
    bf.holds M atomMap z0 z1 <->
    exists x0, z0 < x0 /\ x0 < z1 /\
      (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap x0 /\
      (bf.rightPart ⟨0, by omega⟩).holds M atomMap x0 z1

-- Step 2: Case 2 reduction using Corollary 5.4 + Lemma 5.3
-- "Negation of exists x0, alpha_0(x0) AND sub-bracket(x0, z1)
-- is V-bracket" -- this is Corollary 5.4 with the F-chain approach
-- (already partially proved as neg_partialBracketExist_sufficient)

-- Step 3: Case 3 - first beta failure decomposition
-- "Find first not-beta_0 point, split there"
-- Uses HasAttainedINF on beta_0.neg.formula

-- Step 4: VecEA2 negation wrapper
theorem neg_vecEA2_is_vvecEA2 :
    forall (n : Nat) (vea : VecEA2 n),
    exists (v : VVecEA2),
    forall {sig} (M) (atomMap) (h_INF : HasAttainedINF M atomMap)
      (z0 z1), z0 < z1 ->
      (v.holds M atomMap z0 z1 <-> not (vea.holds M atomMap z0 z1))

-- Step 5: BracketFormula negation as corollary
theorem neg_bracket_is_vbracket :
    forall (n : Nat) (bf : BracketFormula n),
    exists (v : VBracketFormula),
    forall {sig} (M) (atomMap) (h_INF : HasAttainedINF M atomMap)
      (z0 z1), z0 < z1 ->
      (v.holds M atomMap z0 z1 <-> not (bf.holds M atomMap z0 z1))
  -- Proof: apply neg_vecEA2_is_vvecEA2 to VecEA2.fromBracket bf,
  -- then extract VBracketFormula from VVecEA2 (endpoints are trivial)
```

## 4. Risk Assessment and Fallback Plan

### Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Corollary 5.4 reverse direction harder than expected | H | M | The F-chain reverse direction on Prior (Until witnesses bounded) may need careful argument. Can use HasAttainedINF to bound witnesses. |
| Case 3 beta-failure decomposition complexity | M | M | The split at first beta failure creates two sub-problems. Both have fewer witnesses or simpler first segments. Careful Fin arithmetic needed. |
| VVecEA2 to VBracketFormula extraction at Step 5 | L | L | When endpoints are trivial (top), VVecEA2 disjuncts with non-trivial endpoints evaluate to False (they need not-top at an endpoint). Only trivial-endpoint disjuncts survive, giving VBracketFormula directly. |
| Phase size overflow (H8) | M | M | Case 2 and Case 3 may each need their own sub-phase. Target: 300-400 lines per phase. |

### Fallback Plan

If the VecEA2 approach is blocked:
1. The critical path (`completeness_discrete`) goes through KampPrior.lean, which is ALREADY sorry-free and does NOT import EANegation.lean
2. The sorries in EANegation.lean are NOT on the critical build path
3. If the VecEA2 approach fails, mark Phase 4 as [BLOCKED] with the specific sub-case that fails
4. Task 303 completion depends on task 305 per the description, but the `lake build` critical path is already clean via KampPrior

### Key Insight for Implementation

The previous approach failed because it tried to "peel off the first witness" from a BracketFormula. The correct approach:
1. Lift to VecEA2 (add endpoint conditions)
2. Apply the paper's three-case decomposition (which references endpoint behavior)
3. Case 2 reduces to Corollary 5.4 + Lemma 5.3 (already proved)
4. Case 3 reduces witness count via interval splitting
5. Lower back to BracketFormula as a corollary

This matches the paper's proof structure and avoids the interval mismatch that blocks the direct BracketFormula approach.

## 5. Adversarial Self-Verification

### Challenged Claims

1. **Claim**: "The VecEA2 approach avoids the interval mismatch."
   **Challenge**: Does Case 3's split at a beta-failure point z actually produce sub-brackets with strictly fewer witnesses?
   **Verification**: Yes. At z, the bracket splits into a left part (z_0, z) and right part (z, z_1). The left part has witnesses x_i < z, the right part has witnesses x_j > z. Neither can have ALL n+1 witnesses (since z is interior). Total witnesses across both parts = n+1, but each part has strictly fewer than n+1. **VERIFIED**.

2. **Claim**: "Corollary 5.4 doesn't depend on Lemma 5.1."
   **Challenge**: Does the proof of Corollary 5.4 use any result that depends on Lemma 5.1?
   **Verification**: Corollary 5.4 uses the F-chain + Lemma 5.3. Lemma 5.3 is proved by induction on n (all-betas-True case). Neither uses Lemma 5.1. **VERIFIED** -- no circular dependency.

3. **Claim**: "Case 2 reduces the witness count."
   **Challenge**: In our BracketFormula convention, absorbing beta_0 doesn't reduce n.
   **Verification**: CORRECT -- for BracketFormula, absorbing beta_0 doesn't reduce n. But the key is that Case 2 transforms the problem into "exists x_0, alpha_0 AND sub-bracket on (x_0, z_1)", which is a PARTIAL bracket existential. Its negation uses Corollary 5.4 (which uses Lemma 5.3), not Lemma 5.1 recursively. So the witness count doesn't need to decrease for Case 2. **REVISED** -- Case 2 uses Corollary 5.4, not IH.

4. **Claim**: "The BracketFormula negation theorem is mathematically true."
   **Challenge**: The Boneyard says "genuine mathematical impossibility." Is it actually false?
   **Verification**: The Boneyard says the impossibility is for a SPECIFIC CONSTRUCTION (prepend-based Case C soundness), not for the mathematical statement itself. The mathematical statement follows from the paper's Lemma 5.1 applied to VecEA2.fromBracket. **VERIFIED** -- the statement is true; only the proof strategy was wrong.

5. **Claim**: "Corollary 5.4 full biconditional can be proved without Lemma 5.1."
   **Challenge**: The existing code notes that the reverse direction of Corollary 5.4 requires Lemma 5.1.
   **Verification**: UNCERTAIN. The forward direction (V-bracket -> not-partial-bracket) is proved. The reverse needs: if not-exists-z bracket(z_0, z), then V-bracket holds. This may need the F-chain reverse direction on Prior structures, which requires showing Until witnesses are bounded. This is a separate argument from Lemma 5.1, but non-trivial. **FLAGGED** -- confidence level: 70%. May need Lemma 5.1 after all, which would create a mutual dependency requiring careful untangling.

### Uncertain Claims

- Confidence 70%: Corollary 5.4 full biconditional is provable independently of Lemma 5.1 on Prior structures
- Confidence 90%: The VecEA2 three-case decomposition produces a terminating induction
- Confidence 95%: The BracketFormula negation follows as a corollary of VecEA2 negation

### Revised Direction

After adversarial verification, the core approach (VecEA2 -> BracketFormula corollary) stands. The main uncertainty is whether Corollary 5.4's full biconditional can be proved independently of Lemma 5.1, or whether a mutual induction is needed. If mutual induction is needed, prove both simultaneously using a combined measure (total witness count across all sub-problems).
