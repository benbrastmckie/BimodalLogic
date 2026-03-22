# Teammate A: Antisymmetry Proof Strategy Analysis

**Date**: 2026-03-22
**Task**: 29 - switch_to_reflexive_gh_semantics
**Focus**: Mathematical approaches to proving `canonicalR_antisymmetric`

## Key Findings

### 1. CanonicalR Definition Analysis

`CanonicalR M N` is defined in `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (line 63):

```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

Where `g_content M = {φ | G(φ) ∈ M}`. So `CanonicalR M N` means:
- For all formulas φ, if `G φ ∈ M` then `φ ∈ N`
- Equivalently: every formula asserted to hold at all future times by M actually holds at N

**Mutual inclusion scenario**: If both `CanonicalR M N` and `CanonicalR N M` hold, then:
- `g_content(M) ⊆ N` (every G-formula of M holds at N)
- `g_content(N) ⊆ M` (every G-formula of N holds at M)

**Why this does NOT directly give M = N**: The inclusions involve `g_content` subsets, not M and N themselves. `g_content(M) ⊆ N` is weaker than `M ⊆ N`. A formula `φ ∈ M` without `G φ ∈ M` is not constrained to be in N.

**Under reflexive semantics**: `CanonicalR M M` holds for every MCS M via the T-axiom (G φ → φ means g_content(M) ⊆ M). This is already proven in `canonicalR_reflexive`.

**The antisymmetry challenge**: `CanonicalR M N ∧ CanonicalR N M → M = N` requires showing that no formula can distinguish M from N. This is non-trivial because the mutual inclusion only constrains g-content, not full membership.

### 2. Available MCS Properties

From `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MCSProperties.lean` and `MaximalConsistent.lean`:

**Maximality/Uniqueness properties**:
- `SetMaximalConsistent.negation_complete`: For any MCS M and formula φ, either `φ ∈ M` or `¬φ ∈ M` (but not both).
- `SetMaximalConsistent.implication_property`: Closed under modus ponens.
- `SetMaximalConsistent.closed_under_derivation`: Closed under all derivable consequences.
- `SetMaximalConsistent.neg_excludes`: If `¬φ ∈ M` then `φ ∉ M`.

**Key MCS equality principle**: Two MCSes are equal if and only if they contain the same formulas. Since `Set Formula` equality is `Set.ext`, we have:
```
M = N ↔ ∀ φ, φ ∈ M ↔ φ ∈ N
```

**Important**: There is NO existing theorem in the codebase of the form `canonicalR_antisymmetric : CanonicalR M N → CanonicalR N M → M = N`. This theorem needs to be proven from scratch.

**Lindenbaum lemma**: `set_lindenbaum` extends any consistent set to an MCS. This is used in the Gabbay naming set construction but does not directly give MCS uniqueness.

**MCS equality from mutual g-content inclusion alone is FALSE in general**: Consider two MCSes M and N where M contains extra atomic formulas not related to G. `g_content(M) ⊆ N` and `g_content(N) ⊆ M` would hold if both have empty g-content (possible: if G φ ∉ M for all φ, then g_content(M) = ∅ ⊆ any set). Two different MCSes can both have empty g-content and satisfy the mutual inclusion trivially. Therefore, `canonicalR_antisymmetric` as stated (`CanonicalR M N → CanonicalR N M → M = N`) is **FALSE in general** for arbitrary MCSes.

**Critical realization**: The antisymmetry theorem likely requires additional hypotheses (such as `M ≠ N → ¬CanonicalR N M`) or the proof goes through by contradiction showing `M = N` only in the context of the canonical timeline quotient, not for all MCSes.

### 3. Mathematical Analysis of Antisymmetry Feasibility

#### 3a. Why Simple Mutual Inclusion Fails

The statement `CanonicalR M N → CanonicalR N M → M = N` is **not provable** for arbitrary MCSes because:

**Counterexample sketch**: Let M and N be two distinct MCSes with `g_content(M) = g_content(N) = ∅` (both claim no formula holds at all future times). Then `CanonicalR M N` (∅ ⊆ N) and `CanonicalR N M` (∅ ⊆ M) both hold trivially, but M ≠ N.

This means the theorem statement in the task description must be interpreted carefully. Looking at how it's used in `CanonicalIrreflexivityAxiom.lean` (line 85-89):

```lean
theorem canonicalR_antisymmetric_strict
    (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : CanonicalR M N) (h_NM : CanonicalR N M) : False
```

This is a **strict antisymmetry** (concludes `False`, not `M = N`) using irreflexivity. Under reflexive semantics, the goal is to prove `M = N` from mutual CanonicalR — but this may still be false.

#### 3b. The Correct Statement Under Reflexive Semantics

What is actually needed for the downstream proofs is not `M = N` but rather: **in the canonical timeline quotient, distinct MCSes are strictly ordered**. The antisymmetry property that matters is:

```lean
-- What the call sites actually need:
theorem canonicalR_antisymmetric (h_MN : CanonicalR M N) (h_NM : CanonicalR N M) : M = N
-- OR: the call sites need distinctness witnesses to derive contradiction
```

Looking at `07_enumeration.md` (Pattern B), the call sites use:
```lean
have h_trans := canonicalR_transitive M N M h_mcs h_R h_R'
exact canonicalR_irreflexive M h_mcs h_trans
```

Under reflexive semantics, `canonicalR_transitive M N M h_mcs h_R h_R'` gives `CanonicalR M M`, which is now TRUE (not a contradiction). The replacement needs either:
1. `M = N` (antisymmetry conclusion), then derive contradiction with a distinctness hypothesis
2. A different structural argument

**The key insight**: In the quotient construction, when the code has `CanonicalR M N` and `CanonicalR N M`, it needs to show that `M` and `N` represent the same "time point" (i.e., are in the same equivalence class under the quotient). The quotient is defined precisely to make antisymmetric worlds equal. So `M = N` in the quotient makes sense.

But for **raw MCSes** (before quotienting), antisymmetry `CanonicalR M N → CanonicalR N M → M = N` is likely false. The correct interpretation is that the blocking lemma is needed.

### 4. Gabbay Infrastructure Assessment

The Gabbay infrastructure in `CanonicalIrreflexivity.lean` (~1254 lines) provides:
- `atomFreeSubset M p`: formulas in M not mentioning atom p
- `namingSet M p`: `atomFreeSubset M p ∪ {atom p, H(¬p)}`
- `naming_set_consistent`: The naming set is set-consistent (given `CanonicalR M M`)
- `iterated_deduction`, `iterated_imp_in_mcs`: tools for manipulating derivations in MCSes
- Full IRR-contrapositive argument

**The key theorem for antisymmetry uses this infrastructure**:

The `naming_set_consistent` theorem has signature:
```lean
theorem naming_set_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_R : CanonicalR M M) (p : Atom) :
    SetConsistent (namingSet M p)
```

This produces a consistent naming set. Combined with Lindenbaum, we get an MCS `M' ⊇ namingSet M p` where `atom p ∈ M'` and `H(¬p) ∈ M'`.

**For antisymmetry, the Gabbay infrastructure can be adapted**: Given `CanonicalR M N` and `CanonicalR N M` with `M ≠ N`, we can find a formula that distinguishes them. Since M ≠ N, there exists φ ∈ M such that φ ∉ N (or vice versa). The goal is to derive a contradiction with the mutual CanonicalR conditions.

**However, this requires a different argument structure**:
- The naming set was used to construct a second MCS contradicting `¬CanonicalR M M`
- For antisymmetry, we need: given `CanonicalR M N` and `CanonicalR N M`, show `M = N`
- This is fundamentally different from the irreflexivity proof

### 5. Proof Strategy Recommendations

#### Strategy 1: Blocking Formula Approach (Most Promising)

The real need is: in practice, when the code has `CanonicalR M N` and `CanonicalR N M`, there is also some structural witness that `M ≠ N` (from the context). The strategy is:

```lean
-- Given:
-- h_MN : CanonicalR M N  (g_content M ⊆ N)
-- h_NM : CanonicalR N M  (g_content N ⊆ M)
-- h_ne : M ≠ N

-- Deduce: False (the two conditions are incompatible with M ≠ N)
```

**Sub-strategy**: Use the fact that `CanonicalR M N` in the canonical frame was constructed via `forward_temporal_witness_seed` which puts `ψ ∈ N` as witness for `F(ψ) ∈ M`. The witness `N` was constructed to satisfy `g_content(M) ⊆ N`, but `N` was built from a seed that includes formulas distinguishing it from `M`.

**Concretely**: When the code derives `CanonicalR M N` via seriality (there exists N with `F(¬⊥) ∈ M → CanonicalR M N`), the N is constructed as a Lindenbaum extension of `{¬⊥} ∪ g_content(M)`. To show `N ≠ M`, we need a formula in N not in M. The formula `¬⊥` is in N (from the seed) but might also be in M. A better witness: the Gabbay naming atom `p`.

#### Strategy 2: The Correct Antisymmetry Theorem (Using MCS Maximality)

Actually, there is a clean mathematical proof using the interaction of G and H in reflexive semantics:

**Claim**: If `CanonicalR M N` and `CanonicalR N M` then for all φ, `φ ∈ M ↔ φ ∈ N`.

**Proof sketch**:
- Given `φ ∈ M`, by temp_a axiom `G(P(φ)) ∈ M`
- By `CanonicalR M N`: `P(φ) ∈ N`
- `P(φ) = ¬H(¬φ)`, so `H(¬φ) ∉ N`
- By MCS negation completeness: since `H(¬φ) ∉ N`, we have... this gives us information about N's H-content but not directly `φ ∈ N`

This sketch doesn't immediately close. The G/H interaction via temp_a does give us `g_content(M) ⊆ N`, which we already know. We need something stronger.

**Better approach**: Use temp_a with the mutual condition:
- `φ ∈ M` implies `G(P(φ)) ∈ M` (by temp_a)
- `G(P(φ)) ∈ M` and `CanonicalR M N` implies `P(φ) ∈ N`
- Now need `φ ∈ N` from `P(φ) ∈ N` — but `P(φ) = ¬H(¬φ)`, so `H(¬φ) ∉ N`
- Since `H(¬φ) ∉ N`, by negation completeness `¬H(¬φ) ∈ N` (which is `P(φ)`) — circular
- What's needed: from `CanonicalR N M` and the past content of N

This shows the antisymmetry theorem for arbitrary MCSes is indeed challenging. The standard formulation requires more care.

#### Strategy 3: Don't Prove Antisymmetry, Fix the Call Sites Differently

Given that antisymmetry `CanonicalR M N → CanonicalR N M → M = N` is likely FALSE for arbitrary MCSes (see counterexample above), the correct approach for the call sites is:

**Pattern B replacement**: The call sites that use:
```lean
have h_trans := canonicalR_transitive M N M h_mcs h_R h_R'
exact canonicalR_irreflexive M h_mcs h_trans
```

Under reflexive semantics, this gives a TRUE statement (`CanonicalR M M`). The contradiction must come from a DISTINCTNESS assumption. In practice, these call sites are in contexts where `M ≠ N` is established through naming/seriality arguments.

**Recommended approach per call site**:
- Add a `h_ne : M ≠ N` hypothesis where needed
- Use the Gabbay naming set to produce a distinguishing formula:
  - Choose fresh atom p not in M
  - By Gabbay: N contains atom p but M does not (M is p-free since p is fresh for M)
  - Therefore `M ≠ N`
- For Pattern B: Given `CanonicalR M N` and `CanonicalR N M` and `M ≠ N`, derive contradiction via:
  1. `M ≠ N` means ∃ φ in M not in N (or vice versa)
  2. The seriality witness N was constructed with g_content(M) ⊆ N AND some extra formula
  3. Use that extra formula as a blocking formula to show `¬CanonicalR N M`

#### Strategy 4: Prove the Correct Antisymmetry with Interaction Axioms

Using the temp_b axiom (F(φ) → G(P(φ))) and temp_a (φ → G(P(φ))) together:

**Proposed theorem** (potentially true under reflexive semantics):
```lean
theorem canonicalR_antisymmetric
    (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : CanonicalR M N) (h_NM : CanonicalR N M) : M = N
```

**Proof attempt using mutual G/H content**:

From `CanonicalR M N` and `CanonicalR N M`:
- Step 1: g_content(M) ⊆ N and g_content(N) ⊆ M

Need to show: ∀ φ, φ ∈ M ↔ φ ∈ N.

Given φ ∈ M, want φ ∈ N:
- By temp_a: G(P(φ)) ∈ M, so P(φ) ∈ g_content(M) ⊆ N, so P(φ) ∈ N
- P(φ) = ¬H(¬φ) ∈ N means H(¬φ) ∉ N
- By negation completeness of N: ¬H(¬φ) ∈ N (which is P(φ) — we knew this already)
- We need: from P(φ) ∈ N (i.e., ¬H(¬φ) ∈ N), derive φ ∈ N
- By temp_t_past on N: H(ψ) ∈ N → ψ ∈ N (T-axiom for H)
- But we have ¬H(¬φ) ∈ N, not H(something) ∈ N

The missing link: P(φ) ∈ N means "sometime in the past, φ held." Under reflexive semantics with H(φ) → φ, this would mean φ ∈ N if P(φ) ∈ N... but that's P(φ) → φ which requires the T-axiom for P, NOT just for H.

P(φ) → φ would require: there exists a past time where φ held AND since we're at a reflexive time, that past time includes now. But P(φ) = ¬H(¬φ) not= H(φ). So P(φ) → φ is NOT a theorem.

**Conclusion**: The naive antisymmetry strategy via temp_a does not work directly.

#### Strategy 5: The Hash-Content Approach

Consider: Under reflexive semantics with mutual CanonicalR, show that full membership coincides.

Actually, the following is a correct proof strategy:

Given `CanonicalR M N` and `CanonicalR N M`:

For any formula φ:
- By negation completeness of M: either `φ ∈ M` or `¬φ ∈ M`
- By negation completeness of N: either `φ ∈ N` or `¬φ ∈ N`

Suppose `φ ∈ M` but `φ ∉ N`. Then `¬φ ∈ N`.
- Since `¬φ ∈ N` and by T-axiom for G: `G(¬φ) ∈ N → ¬φ ∈ N` (trivial direction)
- Need G(¬φ) ∈ N for it to be in g_content(N) ⊆ M

But if `G(¬φ) ∉ N`, then `¬G(¬φ) ∈ N` = `F(φ) ∈ N`...

This approach also doesn't cleanly close without additional axioms.

**Revised conclusion**: Simple mutual CanonicalR does NOT imply M = N for arbitrary MCSes. The antisymmetry theorem in the task likely requires a seriality or naming-set witness to be a true theorem.

### 6. The Correct Formulation and Proof Path

After careful analysis, here is the most viable approach:

**What the downstream code actually needs** (based on `07_enumeration.md` patterns):

The 25 call sites need to derive `False` from:
- `CanonicalR M N` and `CanonicalR N M` (in Pattern B)
- Some distinctness condition (implied by context)

**The correct replacement theorem is NOT a pure antisymmetry result** but rather:

```lean
-- VIABLE: When the seriality witness is constructed with a Gabbay naming atom
theorem canonicalR_strict_of_naming_witness
    (M N : Set Formula) (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (p : Atom) (hp_fresh : p ∉ (g_content M).biUnion Formula.atoms)
    (hp_in_N : Formula.atom p ∈ N) (hp_not_in_M : Formula.atom p ∉ M)
    (h_MN : CanonicalR M N) : ¬CanonicalR N M
```

**Or, the antisymmetry as part of the quotient construction**, where distinct equivalence classes have the necessary distinctness witness built in.

**Simplest workable approach for call sites**: In each call site where Pattern B appears:
1. The context already has a formula φ that justifies `M ≠ N` (e.g., the seriality witness was constructed with F(ψ) ∈ M, so ψ ∈ N, and we need to show ψ ∉ M via negation completeness and the T-axiom argument)
2. Use `canonicalR_H_neg_exclusion` (from `DirectIrreflexivity.lean`) which shows: `CanonicalR M M → atom p ∈ M → H(¬p) ∉ M`
3. Under reflexive semantics with mutual CanonicalR, after establishing M = N (if true), the contradiction comes from the naming set

**The Most Practical Strategy for Task 29**:

Since the existing `naming_set_consistent` proof (in `CanonicalIrreflexivity.lean`) proves consistency given `CanonicalR M M`, and since under reflexive semantics `CanonicalR M M` is always true, the naming set is always consistent. This means:

For any MCS M and any atom p, the naming set `atomFreeSubset(M, p) ∪ {p, H(¬p)}` is consistent. Via Lindenbaum, extend to MCS M'. Then:
- `atom p ∈ M'`
- `H(¬p) ∈ M'`
- By T-axiom (H(¬p) → ¬p): `¬p ∈ M'`
- Both `p ∈ M'` and `¬p ∈ M'` → contradiction

**Wait**: this is the proof of `canonicalR_irreflexive` that was valid under reflexive semantics but is now FALSE (since CanonicalR M M is TRUE). The naming set construction contradicts itself by producing both p and ¬p in M'. This means the naming set actually IS inconsistent under reflexive semantics for any atom p where ¬p is derivable from g-free formulas of M.

**Critical insight**: The proof in `CanonicalIrreflexivity.lean` (`naming_set_consistent`) actually proves consistency of the naming set under the ASSUMPTION `h_R : CanonicalR M M`. Since under reflexive semantics this assumption is always true, the naming set is always consistent. The extension to M' with p and H(¬p), plus T-axiom giving ¬p, would be a contradiction only if H(¬p) → ¬p (which is the T-axiom for H). So there's a contradiction: p ∈ M' and ¬p ∈ M'.

**This shows**: The naming_set_consistent theorem under reflexive semantics actually derives a contradiction by itself (via T-axiom)! The proof works by:
1. For fresh atom p: atomFreeSubset(M, p) = M (all of M is p-free since p is fresh)
2. namingSet = M ∪ {p, H(¬p)}
3. This set is consistent (by naming_set_consistent applied to reflexive assumption)
4. Extend to MCS M' ⊇ namingSet
5. M' contains: p (atom p) AND H(¬p)
6. By T-axiom: H(¬p) → ¬p, so ¬p ∈ M'
7. Both p and ¬p in M' — contradiction!

BUT WAIT: step 2 says namingSet = M ∪ {p, H(¬p)} is consistent. Step 6 applies T-axiom to get ¬p ∈ M'. Then M' contains p and ¬p — contradiction. This means naming_set_consistent is actually proving the naming set is consistent when in fact it's NOT consistent (because T-axiom + H(¬p) gives ¬p, and p is also present). So **naming_set_consistent under reflexive semantics should be FALSE for fresh atoms p**.

Looking at the proof: `naming_set_consistent` takes `h_R : CanonicalR M M` as hypothesis. Under strict semantics, this was a "extra" assumption that enabled the IRR rule to fire. Under reflexive semantics, this assumption is always true, but the conclusion (naming set is consistent) is now WRONG. The proof must have a gap.

The gap: The proof uses IRR to derive a contradiction when the naming set is assumed inconsistent, concluding consistency. Under reflexive semantics, the proof should FAIL because IRR itself uses `H(¬p)` in the naming set, and the T-axiom allows deriving `¬p` from `H(¬p)`. So if we try to derive a contradiction with the naming set, we succeed by: atomFreeSubset (=M) is consistent. Adding p: M ∪ {p} is consistent (p is fresh). Adding H(¬p): M ∪ {p, H(¬p)} derives ¬p (via T-axiom from H(¬p)) and p is present → inconsistent.

So the naming set is INCONSISTENT under reflexive semantics (for fresh p). This means `naming_set_consistent` either has a gap or requires the axiom `¬CanonicalR M M` which is now false.

**CONCLUSION**: The `naming_set_consistent` function in the codebase is actually taking `h_R : CanonicalR M M` and INCORRECTLY concluding consistency under reflexive semantics. This is fine under strict semantics where `CanonicalR M M` is an extra assumption (and is actually false/unnecessary), but under reflexive semantics this creates an inconsistency.

## Summary and Proof Strategy Recommendations

### What We Actually Need

1. **Remove** the incorrect `canonicalR_irreflexive_axiom`
2. **Replace** Pattern B call sites with antisymmetry-based arguments
3. **The correct replacement** depends on the calling context

### The Viable Proof Structure for canonicalR_antisymmetric

Looking at the call sites more carefully: Pattern B always has a `h_ne : M ≠ N` (or equivalent) in context. The theorem should be:

```lean
-- CORRECT: Cannot be proved without distinctness
-- The mutual CanonicalR does NOT force M = N for arbitrary MCSes
-- INSTEAD: prove False from CanonicalR M N, CanonicalR N M, and some structural distinctness
```

The practical approach for each call site:
- Pattern A: Replace `canonicalR_irreflexive M h_mcs h_R` with the proof that the construction produces a Lindenbaum witness M' with p ∈ M' and ¬p ∈ M' (via T-axiom) — showing M' is inconsistent — contradicting M ≠ N.
- Pattern B: Use `Set.Subset.antisymm` for sets and show `M ⊆ N` and `N ⊆ M` if the structure admits it.

### The Most Direct Path Forward

Based on this analysis, the most practical approach is:

1. **For call sites where `M = N` is the goal**: Prove `M = N` via `Set.Subset.antisymm` combined with the MCS maximality: if `g_content(M) ⊆ N` and `g_content(N) ⊆ M`, and both are MCSes with the same G-closure, use a structural induction or the Lindenbaum construction to show they share all formulas. This likely requires additional axioms about the canonical frame structure.

2. **For call sites where `False` is the goal from `CanonicalR M N` and `CanonicalR N M`**: The correct approach is NOT antisymmetry but rather: use the context's distinctness witness and the naming set argument.

3. **Simplest working replacement**: Accept that `canonicalR_antisymmetric : CanonicalR M N → CanonicalR N M → M = N` may be UNPROVABLE for arbitrary MCSes, and instead fix each call site individually using the specific distinctness witness available in that context.

## Confidence Level

**Medium** with the following caveats:

- **High confidence**: The analysis that `CanonicalR M N ∧ CanonicalR N M → M = N` is false for arbitrary MCSes (counterexample with empty g-content).
- **High confidence**: The existing `naming_set_consistent` proof is taking `h_R : CanonicalR M M` as a parameter that was originally an "extra" hypothesis under strict semantics, and may not function correctly under reflexive semantics where this is always true.
- **Medium confidence**: The Gabbay infrastructure CAN be adapted for antisymmetry arguments but requires careful identification of distinctness witnesses in each call site.
- **Low confidence**: That a single clean `canonicalR_antisymmetric` theorem will handle all 25 call sites without per-site adjustments.

## Recommended Next Steps

1. **Verify the counterexample**: Construct two explicit MCSes with `g_content(M) = g_content(N) = ∅` and verify they satisfy mutual CanonicalR but are distinct.

2. **Audit each Pattern B call site**: Identify what distinctness witness is available in each context (the F-witness, the seriality construction, etc.).

3. **Consider a stronger form**: `canonicalR_antisymmetric` with extra hypothesis `hM_serial : Formula.some_future Formula.top ∈ M` or similar seriality condition that forces the Lindenbaum witnesses to be distinguishable.

4. **Explore the MCS equality via h_content**: There may be a proof using the interaction of g_content and h_content under reflexive semantics — the temp_b axiom `F(φ) → G(P(φ))` connects future witnessing to past content in a way that might force M = N.

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - CanonicalR definition and transitivity
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Full Gabbay infrastructure (1254 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` - Closure lemmas under CanonicalR(M,M)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - Current antisymmetric_strict theorem
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS properties
- `/home/benjamin/Projects/ProofChecker/specs/029_switch_to_reflexive_gh_semantics/reports/07_enumeration.md` - Call site patterns
