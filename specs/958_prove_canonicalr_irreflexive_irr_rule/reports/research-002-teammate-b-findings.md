# Teammate B Findings: IRR Rule and Semantic Approaches

- **Task**: 958 - prove_canonicalr_irreflexive_irr_rule
- **Focus**: IRR rule application, semantic lifting, fixed-point arguments
- **Created**: 2026-03-11
- **Artifacts**: This file
- **Codebase Files Examined**: Derivation.lean, Axioms.lean, Formula.lean, CanonicalFrame.lean, CanonicalTimeline.lean, DensityFrameCondition.lean, IRRSoundness.lean, MCSProperties.lean, SeparationLemma.lean, TemporalContent.lean, ConstructiveFragment.lean, CantorPrereqs.lean, RestrictedFragment.lean (Boneyard)

## Forward Analysis

### What does the IRR rule encode?

The IRR rule (Derivation.lean:149):
```lean
| irr (p : String) (φ : Formula)
    (h_fresh : p ∉ φ.atoms)
    (d : DerivationTree []
      ((Formula.and (Formula.atom p)
        (Formula.all_past (Formula.neg (Formula.atom p)))).imp φ)) :
    DerivationTree [] φ
```

The antecedent `p AND H(neg p)` says: "p is true now, and p was never true at any past time." This is a **self-naming formula** -- it names the current time by using a fresh atom p as a marker. In an irreflexive frame, such a marker always exists: at any time t, define p to be true only at t (this is sound because the irreflexive order ensures t is not in its own strict past).

The IRR rule turns this semantic insight into a syntactic tool: any consequence of "there exists a self-naming atom" is a theorem, provided the conclusion does not mention the naming atom.

### What can be derived from `p AND H(neg p)`?

From the assumption `(p AND H(neg p))`:

1. **temp_a**: `p -> G(P(p))`. Since p holds, `G(P(p))` holds, i.e., `G(neg(H(neg p)))`.
2. **temp_4_past**: `H(neg p) -> H(H(neg p))`. So `H(H(neg p))` holds.
3. **temp_a on H(neg p)**: `H(neg p) -> G(P(H(neg p)))`. So `G(P(H(neg p)))` holds.
4. **Iteration**: By repeating temp_a and temp_4, we get arbitrarily deep nesting.

Crucially, we **cannot** derive `G(neg p)` (p might hold at future times too) or `neg G(p)` without additional information about the future.

### What can be derived via IRR as theorems?

For any formula phi not mentioning p, if `⊢ (p AND H(neg p)) -> phi`, then `⊢ phi` by IRR. However:

- We **cannot** derive `⊢ G(alpha) -> alpha` for arbitrary alpha (the T-axiom) because the derivation `(p AND H(neg p)) -> (G(alpha) -> alpha)` requires extracting alpha from G(alpha) at the current time, which needs G to be reflexive -- the very thing we lack.
- We **cannot** derive `⊢ bot` from `(p AND H(neg p))` because the formula is satisfiable in irreflexive frames.

The IRR rule's power is **indirect**: it enriches the set of theorems, and these theorems constrain what can appear in any MCS.

## Backward Analysis

### What connection is needed for the canonical model level?

To prove `neg CanonicalR(M, M)` for any MCS M, we need to show: there exists phi such that `G(phi) in M` but `phi not_in M`.

Assuming `CanonicalR(M, M)` (i.e., `GContent(M) sube M`), we need to derive a contradiction. The contradiction must come from the combination of:
- Closure properties that `GContent(M) sube M` creates
- Axiom-derived formulas that every MCS contains
- (Potentially) IRR-derived theorems that every MCS contains

### The H-closure derivation

A critical intermediate result (derived in my analysis):

**Claim**: If `CanonicalR(M, M)` and M is MCS, then `HContent(M) sube M` (past-reflexivity follows from future-reflexivity).

**Proof**: Assume `GContent(M) sube M`. For any phi:
1. By temp_a: `phi -> G(P(phi))` is a theorem, so in M.
2. If `phi in M`: `G(P(phi)) in M`, hence `P(phi) in M` (by G-closure).
3. `P(phi) = neg(H(neg phi))`. So `H(neg phi) not_in M`.
4. Contrapositive: `H(neg phi) in M -> phi not_in M`, i.e., `H(neg phi) in M -> neg phi in M`.
5. Substituting psi = neg phi: `H(psi) in M -> psi in M` for psi of the form neg phi.
6. For arbitrary psi: `H(psi) iff H(neg neg psi)` in MCS (via temporal K + double negation theorem). And `H(neg neg psi) in M -> neg neg psi in M -> psi in M` (via double negation in MCS).

Therefore `HContent(M) sube M`, i.e., `CanonicalR_past(M, M)`.

**Caveat**: Step 6 requires deriving `H(psi) -> H(neg neg psi)` as a theorem, which needs temporal K distribution and temporal necessitation of double negation. This should be provable from the axiom system but involves syntactic manipulation of the derived `neg` operator. The syntactic complexity of `neg(neg phi) != phi` in our formula representation (since `neg phi = phi -> bot`) makes this non-trivial to formalize.

## Proof Attempt 1: IRR-Based (Direct)

### Strategy
Use IRR to derive a theorem phi_0 such that `phi_0 in M` contradicts `CanonicalR(M, M)`.

### Attempt

Choose a fresh atom p. Consider deriving:
```
⊢ (p AND H(neg p)) -> phi_0
```
where `phi_0` does not mention p and `phi_0 in M` + `CanonicalR(M,M)` gives contradiction.

**Problem**: Any formula phi_0 not mentioning p that is derivable from `(p AND H(neg p))` is ALSO derivable from just the axioms (without IRR). The reason is that `(p AND H(neg p))` provides information about p, and if the conclusion doesn't mention p, the information about p is "projected out." The only way the p-information helps is if it creates interactions through temporal operators that affect p-free formulas.

**Specific attempt**: Derive `⊢ (p AND H(neg p)) -> neg G(H(neg p))`.
- Under `(p AND H(neg p))`, assume `G(H(neg p))` for contradiction.
- From temp_a: `p -> G(P(p))`. So `G(P(p))` holds, i.e., `G(neg H(neg p))`.
- From `G(H(neg p))` and `G(neg H(neg p))`: `G(H(neg p) AND neg H(neg p))` by G-distribution.
- `H(neg p) AND neg H(neg p)` is a contradiction. So `G(bot)`.
- From seriality `F(neg bot)` and `G(bot)`: contradiction (via G-distribution producing bot in a future world that seriality guarantees exists).
- So `neg G(H(neg p))` is derivable from `(p AND H(neg p))`.

**But**: The conclusion `neg G(H(neg p))` mentions p! So we cannot apply IRR here.

This can be reformulated: `neg G(H(neg p)) = F(neg H(neg p)) = F(P(p))`. Still mentions p.

**Assessment**: I could not find a p-free phi_0 that is derivable from `(p AND H(neg p))` and contradicts `CanonicalR(M, M)`. The IRR rule's direct application faces a **projection barrier**: the useful consequences of `(p AND H(neg p))` all mention p.

### Verdict: BLOCKED without additional insight.

## Proof Attempt 2: Semantic Lifting

### Strategy
Use the truth lemma to establish that the canonical model's satisfaction relation matches MCS membership, then argue that a reflexive point in the canonical frame validates too many formulas.

### Attempt

Assume the truth lemma holds:
```
phi in M  iff  M |= phi  (in the canonical model)
```

If `CanonicalR(M, M)`:
- `M |= G(phi)` implies `M |= phi` for all phi (since M is its own successor).
- By truth lemma: `G(phi) in M -> phi in M`, which is just `GContent(M) sube M` (the assumption).
- Also (from H-closure derivation above): `H(phi) in M -> phi in M`.

Now consider atom p. Either `p in M` or `neg p in M`.

**Case p in M**: By H-closure, `H(neg p) in M -> neg p in M`, contradicting `p in M`. So `H(neg p) not_in M`. Therefore `neg H(neg p) in M`, i.e., `P(p) in M`. This is consistent.

**Case neg p in M**: Similarly `P(p) not_in M`, `H(neg p) in M`. Consistent.

In neither case does `(p AND H(neg p)) in M`. This is expected: at a reflexive point, no self-naming formula holds.

**The issue**: The truth lemma approach shows that `CanonicalR(M, M)` is LOCALLY consistent at M -- no single formula yields a contradiction. The contradiction must come from a GLOBAL property of the proof system (the IRR rule ensures that certain things are provable that can't be proved without it).

### The substitution argument (literature approach)

From Blackburn, de Rijke, Venema (2001), the standard approach uses **named models** or **substitution**:

If `CanonicalR(M, M)`, define `Gamma = { psi : psi in M and p not_in psi.atoms }` for a chosen atom p. Show that `Gamma cup {p, H(neg p)}` is consistent:

- Suppose not. Then `Gamma, p, H(neg p) ⊢ bot`.
- By deduction theorem: `Gamma ⊢ (p AND H(neg p)) -> bot`.
- Since Gamma is p-free, this derivation doesn't need p-specific axioms.
- By a careful analysis using IRR: this would mean `Gamma ⊢ bot`, contradicting M's consistency.

Actually, the argument is: `Gamma ⊢ (p AND H(neg p)) -> bot` means `⊢ (p AND H(neg p)) -> neg(bigwedge Gamma)` (for some finite subset). By IRR: `⊢ neg(bigwedge Gamma)`. But `bigwedge Gamma sube M`, so `bigwedge Gamma` is consistent. Contradiction.

Then extend `Gamma cup {p, H(neg p)}` to an MCS M'. M' agrees with M on all p-free formulas. But `p in M'` and `H(neg p) in M'`, and `CanonicalR(M, M)` implies `CanonicalR(M, M')` (since GContent(M) is p-free and sube M cap p-free = Gamma sube M'). So CanonicalR(M, M'). Now at M': `H(neg p) in M'` and `CanonicalR_past(M, M')` (from our H-closure derivation applied to M') gives... wait, this needs more careful analysis.

**Assessment**: This approach is the most PROMISING but requires:
1. A careful consistency argument for `Gamma cup {p, H(neg p)}`.
2. The consistency argument ITSELF uses IRR in a crucial way.
3. Formalization would need ~100-200 lines.

### Verdict: MOST PROMISING, needs careful formalization.

## Proof Attempt 3: Fixed Point Contradiction

### Strategy
If `CanonicalR(M, M)`, M is a "fixed point" of the canonical relation. In a dense ordering, argue that fixed points cannot exist.

### Attempt

If `CanonicalR(M, M)`: `GContent(M) sube M`. By the H-closure derivation, also `HContent(M) sube M`.

From density_of_canonicalR (CanonicalTimeline.lean:134): if `F(phi) in M` and M is MCS, then there exists W with `CanonicalR(M, W)` and `F(phi) in W`.

From seriality: `F(neg bot) in M`. By density: exists W with `CanonicalR(M, W)` and `F(neg bot) in W`.

From canonical_forward_reachable_linear: M, W, M are forward-reachable from M. By linearity: `CanonicalR(W, M)` or `CanonicalR(M, W)` or `W = M` (as sets).

If `W = M`: W is the same MCS, no new information.
If `W != M`: There exists a formula alpha with `alpha in W` but `alpha not_in M` (or vice versa). If `CanonicalR(M, W)` and `CanonicalR(W, M)`: by transitivity `CanonicalR(M, M)` (already known) and `CanonicalR(W, W)`. This gives a two-element "loop" but not a contradiction.

**Problem**: The density and seriality arguments produce witnesses, but these witnesses might all collapse back to M or form loops. Without a way to show that witnesses must be STRICTLY different, the argument stalls.

The Boneyard documents this exact blocker (RestrictedFragment.lean:434-444):
> When an MCS is G-closed, its canonical F-witnesses may return the same MCS, producing a singleton quotient where NoMaxOrder fails.

### Verdict: FAILS without additional machinery (the IRR rule is needed to break the fixed-point).

## Key Lemmas Found

### Existing lemmas (with signatures from codebase):

1. **`CanonicalR`** (CanonicalFrame.lean:63):
   `def CanonicalR (M M' : Set Formula) : Prop := GContent M ⊆ M'`

2. **`GContent`** (TemporalContent.lean:25):
   `def GContent (M : Set Formula) : Set Formula := {phi | Formula.all_future phi ∈ M}`

3. **`canonical_forward_F`** (CanonicalFrame.lean:122):
   From `F(psi) in M` (MCS), exists W (MCS) with `CanonicalR M W` and `psi in W`.

4. **`theorem_in_mcs`** (MaximalConsistent.lean:482):
   If `⊢ phi` and M is MCS, then `phi in M`.

5. **`set_mcs_implication_property`** (MCSProperties.lean:150):
   If `(phi -> psi) in M` and `phi in M` (MCS), then `psi in M`.

6. **`set_mcs_negation_complete`** (MCSProperties.lean:174):
   For MCS M: `phi in M` or `neg phi in M`.

7. **`set_consistent_not_both`** (MCSProperties.lean:331):
   If M is set-consistent, `phi in M` and `phi.neg in M` gives False.

8. **`not_G_implies_F_neg`** (SeparationLemma.lean:100):
   If `G(beta) not_in M` (MCS), then `F(neg beta) in M`.

9. **`density_of_canonicalR`** (CanonicalTimeline.lean:134):
   If `F(phi) in M` (MCS), exists W with `CanonicalR M W` and `F(phi) in W`.

10. **`irr_sound_dense_at_domain`** (IRRSoundness.lean:232):
    IRR rule is sound on dense irreflexive linear orders for domain-inhabited times.

11. **`DerivationTree.irr`** (Derivation.lean:149):
    The IRR rule as a constructor of DerivationTree.

### Missing lemmas needed:

1. **`H_closure_from_G_closure`**: If `GContent(M) sube M` then `HContent(M) sube M`. Needs temp_a + classical reasoning about double negation in temporal contexts. Estimated ~50-80 lines.

2. **`G_conjunction_distribution`**: `G(phi)` and `G(psi)` implies `G(phi AND psi)`. Needed for combining G-formulas in the IRR derivation. May partially exist via temp_k_dist. Estimated ~30-50 lines.

3. **`canonicalR_irreflexive`**: The target theorem. Estimated ~100-200 lines depending on approach.

## Recommended Approach

### Primary recommendation: Substitution-based proof using IRR (Approach 2, semantic lifting variant)

The standard proof from the modal logic literature (Goldblatt, Blackburn-de Rijke-Venema) proceeds:

1. **Assume** `CanonicalR(M, M)` for MCS M.
2. **Choose** a fresh atom p. Define `Gamma_p = { psi in M : p not_in psi.atoms }`.
3. **Show** `Gamma_p cup {p, H(neg p)}` is consistent (this is where IRR is used contrapositively).
4. **Extend** to MCS M' via Lindenbaum.
5. **Show** `CanonicalR(M, M')` (since GContent(M) only contains p-free formulas and these are in M' via Gamma_p).
6. **Derive contradiction**: At M', both `p in M'` and `H(neg p) in M'`. By temp_a + G-closure (transferred from M) + CanonicalR(M, M'): `P(p) in M'`. But `P(p) = neg H(neg p)`, contradicting `H(neg p) in M'`.

Wait -- step 6 needs `CanonicalR(M', M')`, not just `CanonicalR(M, M')`. The G-closure is a property of M, not M'. Let me reconsider.

Actually, the contradiction in step 6 should use:
- `CanonicalR(M, M')` means `GContent(M) sube M'`.
- `CanonicalR(M, M)` means `GContent(M) sube M`.
- At M: by temp_a, `p in M -> G(P(p)) in M`. But p might not be in M.
  If `p not_in M`: `neg p in M`. `neg p` is p-free? No! `neg p = p -> bot` mentions p.

Hmm, `neg p` is `Formula.imp (Formula.atom p) Formula.bot`, which has `p in atoms`. So `neg p not_in Gamma_p`. This complicates the argument.

**Revised approach**: The proof must handle the p-containing formulas carefully. The key insight is that `GContent(M)` might contain formulas mentioning p. But if we choose p "fresh enough," the G-content restricted to p-free formulas is what matters.

### Alternative recommendation: Direct IRR-derived theorem approach

If the substitution argument proves too complex to formalize, consider:

1. Derive specific theorems via IRR that constrain MCS behavior.
2. Show these theorems collectively force `GContent(M) not_sube M`.

For example, for each atom q, use IRR with a different fresh atom p (where `p != q` and `p not_in G(q).atoms = q.atoms`) to derive:
```
⊢ (p AND H(neg p)) -> (G(q) -> q)    [if derivable]
```
But as analyzed, this is NOT derivable from `(p AND H(neg p))` alone.

### Fallback recommendation: Axiom addition

If neither approach works within reasonable effort, consider adding an axiom that directly forces irreflexivity:
```
| irr_axiom (φ : Formula) : Axiom (φ.all_future.imp φ |>.neg)
```
This says `neg(G(phi) -> phi)`, i.e., it's not always the case that G(phi) implies phi. But this is too strong -- it says `G(phi) AND neg phi` is consistent, which is wrong.

A better axiom would be scheme-based, but this risks proof debt. **Not recommended** per the zero-debt policy.

## Detailed Analysis: Why Direct Axiom Approach (Strategy A from research-001) Fails

Research-001 suggested trying direct axioms first. Here is why it fails:

Assume `CanonicalR(M, M)`. For any atom p:
- Case p in M: by temp_a + G-closure, `P(p) in M`. This is consistent.
- Case neg p in M: by temp_a on neg p + G-closure, `P(neg p) in M`. Also consistent.

No single axiom instantiation yields contradiction because:
- `G(bot) not_in M` (from seriality + G-closure): just says G(bot) is not in M, expected.
- `G(phi) in M -> phi in M` for all phi: this is the T-axiom, not a theorem, but consistent as an MCS-level property.
- seriality + density + temp_4 all produce more MCS-related formulas but never ones that contradict G-closure.

The core issue: `CanonicalR(M, M)` is **syntactically consistent** with all axiom instances. It is ONLY inconsistent when combined with the IRR rule (a meta-rule, not an axiom).

## Confidence Level

**Medium-Low** with justification:

- The substitution-based approach (Proof Attempt 2) is theoretically correct per the literature (Goldblatt, Blackburn-de Rijke-Venema).
- However, formalizing it in Lean requires careful handling of:
  1. The consistency of `Gamma_p cup {p, H(neg p)}` using IRR contrapositively.
  2. The relationship between p-free and p-containing formulas in MCS membership.
  3. The syntactic complexity of our `neg` and `and` as derived operators.
- I could not produce a complete, self-contained proof sketch that avoids all pitfalls.
- Estimated implementation effort: **200-400 lines** of new Lean code, with significant proof engineering required.
- Risk of encountering additional syntactic obstacles during formalization.

## Summary of Approaches

| Approach | Status | Key Blocker |
|----------|--------|-------------|
| Direct axiom (Strategy A) | **FAILS** | G-closure is syntactically consistent with axioms; IRR needed |
| IRR direct theorem (Attempt 1) | **BLOCKED** | Projection barrier: useful consequences mention p |
| Semantic lifting + substitution (Attempt 2) | **MOST PROMISING** | Needs careful consistency argument using IRR contrapositively |
| Fixed point / density (Attempt 3) | **FAILS** | F-witnesses can collapse to same MCS |
| H-closure intermediate | **DERIVED** | CanonicalR(M,M) implies CanonicalR_past(M,M) via temp_a |

## Appendix: The H-Closure Derivation (Full Detail)

Assume `CanonicalR(M, M)`, i.e., for all phi: `G(phi) in M -> phi in M`.

**Goal**: For all psi: `H(psi) in M -> psi in M`.

**Step 1**: From temp_a (`phi -> G(P(phi))`) applied to arbitrary alpha:
- `alpha in M -> G(P(alpha)) in M -> P(alpha) in M` (by G-closure).
- `P(alpha) = neg(H(neg alpha))`. So `H(neg alpha) not_in M`.
- Contrapositive: `H(neg alpha) in M -> alpha not_in M -> neg alpha in M`.

**Step 2**: For arbitrary psi, let alpha = neg psi:
- `H(neg(neg psi)) in M -> neg(neg psi) not_in M -> neg(neg(neg psi)) in M`.
- Wait, this gives `H(psi') in M -> ...` for psi' = neg(neg psi), not psi.

**Step 3**: We need `H(psi) iff H(neg neg psi)` in MCS.
- Theorem: `psi -> neg neg psi` (double negation introduction, derivable from prop_k + peirce).
- By temporal necessitation and duality: `H(psi -> neg neg psi)` is a theorem.
- Wait, temporal necessitation gives G, not H. By temporal duality: from `⊢ G(phi)`, get `⊢ H(swap phi)`. With appropriate swap, get `⊢ H(psi -> neg neg psi)`.
- By temp_k_dist (past version, derivable via duality): `H(psi -> neg neg psi) -> (H(psi) -> H(neg neg psi))`.
- So `H(psi) -> H(neg neg psi)` is a theorem.
- Similarly, `neg neg psi -> psi` (double negation elimination, from peirce) gives `H(neg neg psi) -> H(psi)`.

**Step 4**: Combining:
- `H(psi) in M -> H(neg neg psi) in M` (by Step 3).
- Let alpha = neg psi in Step 1: `H(neg(neg psi)) in M -> neg psi not_in M -> ... `
  Wait, Step 1 gives: `H(neg alpha) in M -> neg alpha in M`.
  With alpha = neg psi: `H(neg(neg psi)) in M -> neg(neg psi) in M`.
  And `neg(neg psi) in M -> psi in M` (by double negation elimination in MCS).
- Combining: `H(psi) in M -> H(neg neg psi) in M -> neg neg psi in M -> psi in M`.

This completes the H-closure proof. QED.

**Formalization note**: This derivation requires:
- `temp_4_past` (already exists in MCSProperties.lean)
- Double negation introduction/elimination as theorems (should exist or be derivable from peirce + ex_falso)
- Past-temporal K distribution (derivable via temporal duality from temp_k_dist)
- Chaining these through `set_mcs_implication_property` and `theorem_in_mcs`
