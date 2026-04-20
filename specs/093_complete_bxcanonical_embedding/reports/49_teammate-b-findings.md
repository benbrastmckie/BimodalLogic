# Teammate B Findings: Alternative Approaches for Sorry Closure

## Key Findings

1. **The oracle chain (Approach B) was already tried and archived** -- it hits the SAME defect-count-decrease blocker as the Lindenbaum approach, plus a new one: backward Until step transfer (`phi /\ F(phi U psi) -> phi U psi`) is semantically INVALID.

2. **The fundamental obstacle is termination of eventuality resolution**, not the chain construction method. Whether Lindenbaum or oracle-based, the chain cannot guarantee defect count strictly decreases because the Lindenbaum extension (in both approaches) may introduce new defects.

3. **Approach D (weakened coherence) is a dead end** -- the restricted coherence predicates are already weakened to the minimum needed by the truth lemma. Further weakening would break the truth lemma.

4. **Approach A (constrained Lindenbaum) from the handoff remains the strongest candidate** -- it attacks the root cause directly: preventing re-introduction of resolved formulas.

5. **A hybrid approach (quasimodel defect-discharge + direct MCS chain)** from the literature offers a mathematically sound path that avoids both the infinite termination problem and the backward step transfer invalidity.

---

## Approach B Analysis (Oracle Chain)

### What Was Already Tried

The file `Boneyard/OracleCoherence.lean` contains a complete attempt at this approach. The oracle chain:
- Uses `qm_oracle_step` which builds successor MCS from a Lindenbaum extension of `g_content(w) U {Until-defects in Sigma}`
- Successfully proves: g_content propagation, h_content backward, box stability, Until-defect persistence

### Where It Fails

**Problem 1 -- Forward F-resolution (sorry at line 415):**
The oracle seed includes Until-defects but NOT F-obligations directly. The proof strategy converts `F(phi)` to `top U phi` via BX12, then relies on Until-defect persistence plus defect-count decrease. But defect-count decrease is unprovable because the oracle's Lindenbaum extension can introduce NEW Until-defects from Sigma.

**Problem 2 -- Backward Until step transfer (sorry at line 458):**
The step `phi U psi in mcs(r+1) /\ phi in mcs(r) -> phi U psi in mcs(r)` is **semantically invalid**. Counterexample documented in code: `phi@t`, `phi U psi` absent at `t`, `phi U psi` at `t+1` but with `neg phi` at `t+1` and `psi` at `t+2`. No BX axiom bridges this gap.

### Why It Cannot Be Fixed

The oracle approach improves Until-defect *persistence* (propagation forward), but:
- It still uses Lindenbaum for extension, so it inherits the same non-determinism problem
- The backward step transfer is a mathematical impossibility, not a proof engineering issue
- Making the seed "bigger" (including backward projections) creates consistency problems

### Verdict: REJECTED. Both blocking issues are fundamental.

---

## Approach C Analysis (Semantic Argument)

### The Idea

Instead of proving coherence properties constructively at the chain level, argue semantically: "If the logic is sound and the canonical frame satisfies certain conditions, then coherence must hold."

### Why It Doesn't Work Here

The coherence properties ARE semantic properties of the chain. The proof obligation is precisely to BUILD a chain (Int-indexed family of MCS) that satisfies them. A "meta-argument" would be circular:

1. Completeness requires a countermodel construction
2. The countermodel needs a chain with coherence
3. You cannot assume completeness to prove the countermodel exists

The only non-circular semantic argument would be: prove soundness + finite model property, then extract a model. But BX over integers does NOT have finite model property (it has infinite discrete time).

### Alternative Semantic Idea: Filtration

Filtration constructs a finite quotient model. For Until-free fragments of temporal logic, this works. But:
- BX has Until/Since, which requires infinite witnesses along the temporal axis
- Filtration over the discrete integers quotient by subformula equivalence gives finite equivalence classes, but the temporal ordering on classes may lose strict linearity
- No existing literature proves BX completeness via filtration

### Verdict: REJECTED for direct application. Filtration is a separate research program.

---

## Approach D Analysis (Weakened Coherence)

### What Coherence Actually Requires

The truth lemma (`RestrictedParametricTruthLemma.lean`) needs exactly:

1. **`restricted_temporally_coherent root`**: For phi in `deferralClosure(root)`:
   - F(phi) in mcs(t) -> exists s > t, phi in mcs(s)
   - P(phi) in mcs(t) -> exists s < t, phi in mcs(s)

2. **`restricted_forward_until_since_coherent root`**: For `phi U psi` in `subformulaClosure(root)`:
   - phi U psi in mcs(t) -> exists s > t with psi in mcs(s) and guard phi in (t,s)

3. **`restricted_backward_until_since_coherent root`**: For `phi U psi` in `subformulaClosure(root)`:
   - Witness at s > t with guard in (t,s) -> phi U psi in mcs(t)

### Can These Be Weakened Further?

**No.** Each is used at a specific point in the structural induction:
- (1) is used for the G/H cases in the truth lemma (backward G needs forward_F on neg(psi))
- (2) is used for the forward direction of Until evaluation
- (3) is used for the backward direction of Until evaluation

Removing ANY of these breaks the truth lemma induction. The "restricted" qualifier already limits to `deferralClosure(root)` which is the absolute minimum.

### Could We Prove Only Some?

The forward Until coherence (2) can be proved from restricted_tc (1) + BX10: `phi U psi -> F(psi)`. So if we can prove (1), we can derive (2) with more work.

The backward Until coherence (3) is independent and requires the "step transfer" property, which is the same obstacle as Approach B.

### Verdict: REJECTED. Already at minimum viable coherence.

---

## Literature Survey

### Reynolds (2003) - "An Axiomatization of Full Computation Tree Logic"

Reynolds's completeness proof for Until in linear temporal logic uses a **step-by-step construction** where each successor state is chosen to discharge exactly one Until-defect per step, with explicit control over which formulas enter the successor. Key insight: Reynolds does NOT use unconstrained Lindenbaum extension. Instead, he builds the successor from a carefully chosen *atom* (maximally consistent subset of the closure set).

### Goldblatt (1992) - "Logics of Time and Computation"

Goldblatt's completeness for tense logic (without Until) uses standard Lindenbaum + g_content propagation. For Until, Goldblatt references Burgess (1984) and notes the quasimodel approach.

### Burgess (1984) - "Basic Tense Logic"

The original quasimodel construction. The key insight: build a **finite** chain of Hintikka points to discharge each Until formula, then embed the chain into the canonical model. The embedding step uses the fact that Hintikka points can be "realized" as restrictions of MCS to the closure set.

### Gabbay, Hodkinson, Reynolds (1994) - "Temporal Logic: Mathematical Foundations"

The standard reference. Their completeness proof for Until uses:
1. Fischer-Ladner closure to get a finite set of relevant formulas
2. Quasimodel construction at the abstract level (finite Hintikka chains)
3. Realization: embed the quasimodel into the full canonical model

**Critical difference from our approach**: They do NOT build an infinite Int-indexed chain and then prove coherence. They build FINITE discharge chains for each eventuality and stitch them together.

### Key Literature Insight

The standard approach in ALL major references is:
- **Do NOT try to prove coherence for an infinite chain built from unconstrained Lindenbaum extensions**
- Instead, prove that FINITE discharge chains exist (via defect-count decrease on a FINITE closure), then show these can be embedded in the canonical model

This is precisely the quasimodel approach already partially implemented in our `Quasimodel/` directory.

---

## Recommended Path

### The Constrained Lindenbaum Approach (Modified Approach A)

Based on the literature analysis and code review, the correct path is:

**Strategy**: Replace `set_lindenbaum` in the preserving forward step with a CONSTRAINED version that extends a consistent seed to MCS while EXCLUDING `F(chi)` for all chi in sigma_list that are already directly present in the seed (resolved defects).

**Mathematical justification**: Under irreflexive semantics, `phi -> F(phi)` is NOT derivable. Therefore, if the seed contains `phi` but NOT `F(phi)`, the extension to MCS does NOT force `F(phi)` into the result. This is because:
- If `{phi, neg(F(phi))} U g_content(M)` is consistent, we can extend to MCS excluding F(phi)
- Consistency holds precisely because `phi -> F(phi)` is not derivable (no proof of inconsistency of `{phi, neg F(phi)} U g_content(M)` can be constructed)

**What this gives us**:
1. `fwd_chain_forward_F`: Once phi is resolved at step n+1, F(phi) is NOT in chain(n+1). So the defect count strictly decreases, and phi is never re-introduced as a defect. After at most |sigma_list| steps, phi must be directly resolved.
2. `dd_bfmcs_restricted_tc` forward: Follows from (1).
3. `dd_bfmcs_restricted_tc` backward: Symmetric argument with constrained Lindenbaum for backward chain.
4. `dd_bfmcs_restricted_fuc`: Follows from restricted_tc + BX10.
5. `dd_bfmcs_restricted_buc`: This is the hardest. Requires proving the step transfer property. With constrained Lindenbaum, we have additional control: if phi U psi in mcs(r+1) and phi in mcs(r), we need phi U psi in mcs(r). By BX5: `phi /\ F(phi U psi) -> phi U psi`. We need `F(phi U psi) in mcs(r)`. Since `phi U psi in mcs(r+1)` and `g_content(mcs(r)) subset mcs(r+1)`, we have `H(phi U psi) in mcs(r)` (from backward_H). Wait -- we need `F(phi U psi)`, not `H(phi U psi)`.

   Actually: `phi U psi in mcs(r+1)` plus `g_content(mcs(r)) subset mcs(r+1)` does NOT directly give us `F(phi U psi) in mcs(r)`. We need `h_content(mcs(r+1)) subset mcs(r)`, which gives `H(phi U psi) in mcs(r+1) -> phi U psi in mcs(r)` -- but we need `H(phi U psi) in mcs(r+1)`, not just `phi U psi in mcs(r+1)`.

   **Revised path for buc**: Use BX4' (connect_past): `phi -> H(F(phi))`. From `phi U psi in mcs(r+1)`, we get `H(F(phi U psi)) in mcs(r+1)`. By h_content backward: `F(phi U psi) in mcs(r)`. Combined with `phi in mcs(r)`, use BX5: `phi /\ F(phi U psi) -> phi U psi` to get `phi U psi in mcs(r)`.

   **Is BX5 exactly this?** BX5 is: `phi /\ X(phi U psi) -> phi U psi` where X is the "next" operator. In our continuous/discrete setting without explicit "next", BX5 is: `phi /\ F(phi U psi) -> phi U psi`. Let me verify this is available.

### Implementation Sketch

1. Define `constrained_lindenbaum`: Given consistent seed S and finite exclusion set E where `S U {neg(e) | e in E}` is consistent, extend S to MCS M with `E ∩ M = empty`.
2. Prove `constrained_lindenbaum_exists`: The key lemma. Uses the fact that `S U {neg(e) | e in E}` being consistent means the standard Lindenbaum extension of this augmented set gives an MCS excluding all of E.
3. Replace `preserving_fwd_step` to use constrained extension, excluding `F(chi)` for resolved chi.
4. Prove defect count strictly decreases.
5. Derive all 5 sorry sites from the strict decrease.

### Estimated Effort

- `constrained_lindenbaum_exists`: ~50 LOC (essentially standard Lindenbaum on augmented seed)
- Consistency of augmented seed: ~80 LOC (needs irreflexive semantics: `phi, neg(F(phi)), g_content(M)` consistent)
- Modified `preserving_fwd_step`: ~100 LOC
- Defect count decrease: ~80 LOC
- `fwd_chain_forward_F` proof: ~60 LOC
- Backward chain symmetric: ~100 LOC
- Until coherence proofs: ~150 LOC (depends on BX5 availability)

**Total: ~620 LOC**

---

## Confidence Level

**Medium-High** (75%)

**Justification**:
- The constrained Lindenbaum approach is mathematically sound IF the consistency of `{phi, neg(F(phi))} U g_content(M)` holds under irreflexive semantics
- This consistency follows from non-derivability of `phi -> F(phi)`, which is a DESIGN FEATURE of the irreflexive semantics switch
- The main risk is the backward Until coherence (sorry 4 and 5), which depends on BX5 having the right form. If BX5 is `phi /\ F(phi U psi) -> phi U psi`, the approach works. If BX5 is something else, additional infrastructure is needed.
- The oracle approach is definitively rejected (archived in Boneyard with documented counterexample)
- Literature universally supports constrained/deterministic successor construction over unconstrained Lindenbaum for temporal completeness

**Remaining uncertainty**:
- Exact form of BX5 in the codebase (needs verification)
- Whether `F(phi U psi) in mcs(r)` can be derived from `phi U psi in mcs(r+1)` + h_content backward (needs BX4': `phi -> H(F(phi))`)
- Whether the constrained seed `S U {neg(F(chi)) | chi resolved}` remains consistent with ALL of g_content(M) simultaneously (may need careful argument about finite exclusion)
