# Teammate B: Alternative Approaches for BXCanonical Embedding

## Key Findings

1. **The irreducible obstruction is real and structural**: All Lindenbaum-based chain constructions suffer from opacity of `Classical.choose` in `set_lindenbaum`. The chain step `chain(n+1)` provides no structural guarantee about which formulas it contains beyond the seed. This blocks both F-eventuality resolution (finding `m > n` with `phi in chain(m)` when `F(phi) in chain(n)`) and Until step-transfer (pulling `phi U psi` from a successor into the current step).

2. **Direction 1 (Deterministic Chain Hybrid) is architecturally promising but faces a semantic collapse**: Under reflexive semantics, `bot U alpha = alpha` (the half-open guard `[t,s)` with `s = t` is empty, making `bot` vacuously true). This makes the deterministic chain constant, trivially satisfying backward Until coherence but unable to resolve any F-eventualities. A hybrid combining deterministic Until-linking with Lindenbaum F-resolution requires a mechanism to switch between two chain regimes, which has no clean formalization.

3. **Direction 2 (Semantic/Model-Theoretic Completeness) is the most mathematically sound path**: The standard Burgess/Xu/Goldblatt completeness proofs handle temporal coherence semantically via well-founded induction on formula complexity, not syntactically on chain structure. This approach avoids the Lindenbaum opacity entirely. The codebase has substantial reusable infrastructure (truth lemma, canonical frame, MCS properties, BXPoint structure).

4. **Direction 3 (Axiom Strengthening) is feasible but changes the logic**: Adding a next-step axiom `phi AND F(phi U psi) -> phi U psi` would directly close the Until step-transfer sorry, but this axiom is not valid on all reflexive linear orders (only on discrete ones). Adding an Until-induction rule is the standard literature approach (IRR rule from Gabbay/Hodkinson/Reynolds) and does not change the set of valid formulas.

5. **A fourth direction exists: Induction on formula complexity within the truth lemma**: Rather than building a single chain that satisfies all coherence properties simultaneously, prove the truth lemma by well-founded induction on formula complexity, constructing LOCAL witnesses for each formula at each step. This is how Goldblatt (1992) and GHR (1994) actually prove completeness.

---

## Direction 1: Deterministic Chain Hybrid

### Current Deterministic Chain Infrastructure

The codebase has deterministic chain infrastructure in the Boneyard. The key idea of a "deterministic chain" is that successor content is fully determined by predecessor content via `bot U alpha` linking:

```
alpha in chain(n+1) iff (bot U alpha) in chain(n)
```

Under strict semantics, this gives a "next-step" relationship. Under the current reflexive semantics with half-open guard, however:

```
truth_at (bot U alpha) at t
  = exists s, t <= s AND truth_at alpha s AND forall r, t <= r < s -> False
  = exists s, s = t AND truth_at alpha s
  = truth_at alpha t
```

So `bot U alpha = alpha` semantically, making the deterministic chain CONSTANT (every step has the same MCS).

### How the Deterministic Chain Handles Until/Since

Under strict semantics, the deterministic chain provides backward Until coherence because `(phi U psi) in chain(n)` can be decomposed:
- By BX9: `phi OR psi` at `n`
- If `psi` at `n`: done (witness at `n`)
- If `phi` at `n`: then `(phi U psi)` must propagate. BX5 (self-accumulation) gives `(phi AND (phi U psi)) U psi in chain(n)`, so the Until persists forward.

The step-transfer property (`(phi U psi) in chain(n+1) AND phi in chain(n) -> (phi U psi) in chain(n)`) follows from `bot U alpha` content linking: if `phi U psi in chain(n+1)`, then `bot U (phi U psi) in chain(n)`, which equals `phi U psi` under reflexive semantics (collapse). Under strict semantics this would give the "next-step Until" relationship needed.

### What "Combining with Lindenbaum F-resolution" Would Mean

A concrete hybrid construction would be:

1. **Base chain**: Use the deterministic chain for Until/Since backward coherence.
2. **F-resolution overlay**: At each step where `F(phi)` appears and `phi` is not yet resolved, fork the chain to a Lindenbaum extension that includes `phi`.

The fundamental problem: these two requirements conflict. The deterministic chain is constant (under reflexive semantics), so it cannot resolve F-eventualities at all. A non-constant chain cannot use the bot-Until content linking because `bot U alpha = alpha` under reflexive semantics.

### Gaps and Assessment

**Can they be filled?** No, not under reflexive semantics. The deterministic chain hybrid approach is fundamentally blocked by the semantic collapse of `bot U alpha`. The only way to make this work would be to:
- Switch to strict Until semantics (which breaks BX8 soundness), OR
- Add a genuine "next" operator (see Direction 3)

**Confidence**: 5%. This direction is a dead end under reflexive semantics.

---

## Direction 2: Semantic/Model-Theoretic Completeness

### What a Semantic Completeness Proof Looks Like

The standard semantic completeness proof for temporal logics over linear orders (Burgess 1984, Goldblatt 1992, Gabbay/Hodkinson/Reynolds 1994) follows a fundamentally different structure from what the current codebase attempts.

**Current approach (Henkin/Canonical Model)**:
1. Build a SINGLE canonical model (BFMCS indexed by Int)
2. Prove ALL coherence properties of this model simultaneously
3. Apply truth lemma to the model

**Standard semantic approach (Goldblatt/GHR)**:
1. Given consistent `phi`, extend `{neg phi}` to MCS `M_0`
2. Prove truth lemma by INDUCTION on formula complexity
3. For each formula and each MCS in the chain, construct witnesses ON DEMAND
4. The "model" is not built up-front but constructed incrementally during the induction

The critical difference: the semantic approach does NOT require building a chain satisfying all coherence properties simultaneously. Instead, it proves:

> For every formula `psi` of complexity `<= n`, and every MCS `w` in the canonical frame, if `psi in w` then `psi` is true at `w` in the canonical interpretation, and if `psi not in w` then `psi` is false.

The base cases (atom, bot, imp, box) are standard. The inductive step for `G(psi)`:
- Forward: `G(psi) in w` implies for all `v >= w`, `psi in v`. By IH (complexity of `psi` < complexity of `G(psi)`), `psi` is true at `v`. Done.
- Backward: If `psi` is true at all `v >= w`, need `G(psi) in w`. Contrapositive: if `G(psi) not in w`, then `F(neg psi) in w`. Need a witness `v >= w` with `neg psi in v`. This is where `bx_forward_witness` is used, and the IH gives `neg psi` is true at `v`, contradicting `psi` true at `v`.

The inductive step for `phi U psi`:
- Forward: `phi U psi in w` means (by BX10) `F(psi) in w`, so exists `v >= w` with `psi in v`. Need to show `phi` holds on the interval `[w, v)`. By BX5 (self-accumulation), `phi AND (phi U psi)` holds at intermediate points. By IH on `phi`, `phi` is true. By IH on `phi U psi` (same complexity, but the witness chain is getting shorter -- this requires a secondary induction on the DISTANCE to the witness), the guard is maintained.
- Backward: If there exists `v >= w` with `psi` true at `v` and `phi` true on `[w, v)`, need `phi U psi in w`. This is the step-transfer direction. By IH, `psi in v` and `phi in u` for all `u in [w, v)`. Use BX8 (`psi -> phi U psi`) at `v`, then propagate backward using BX axioms.

**Key insight**: The backward direction for Until uses the FORMULA ITSELF at the witness point (BX8 gives `phi U psi` at `v` from `psi in v`), then propagates backward step by step. This does NOT require controlling Lindenbaum choices -- it uses the existing chain structure and BX axiom properties of MCS.

### How This Differs from the Current Approach

The current approach tries to build a single Int-indexed chain satisfying:
1. `restricted_temporally_coherent` (F/P resolution: strict `t < s`)
2. `restricted_backward_until_since_coherent`
3. `restricted_forward_until_since_coherent`

All three must hold SIMULTANEOUSLY on the SAME chain. The Lindenbaum opacity makes proving (1) impossible because `chain(n+1) = set_lindenbaum(seed).choose` gives no guarantee that `phi` (with `F(phi) in chain(n)`) lands in `chain(n+1)`.

The semantic approach instead proves these properties DURING the truth lemma induction. When the IH needs a witness for `F(phi)`, it constructs one via `bx_forward_witness` (sorry-free in Frame.lean). The witness is an abstract BXPoint, not a chain index. The truth lemma maps this BXPoint to a point in the model.

### What Existing Infrastructure Can Be Reused

Substantial infrastructure already exists:

| Component | Status | Reuse |
|-----------|--------|-------|
| `BXPoint`, `bx_le`, `bx_modal_equiv` | Sorry-free | Direct reuse |
| `bx_le_refl`, `bx_le_trans` | Sorry-free | Direct reuse |
| `bx_forward_witness`, `bx_backward_witness` | Sorry-free | Central to semantic approach |
| `bx_modal_witness` | Sorry-free | Direct reuse |
| `bx_until_eventuality_resolution` | Sorry-free | Central to Until forward |
| `bx_since_eventuality_resolution` | Sorry-free | Central to Since forward |
| `g_content_closed_derivation` | Sorry-free | Used in G backward |
| `h_content_closed_derivation` | Sorry-free | Used in H backward |
| `imp_iff_mcs`, `bot_not_in_mcs` | Sorry-free | Truth lemma base cases |
| MCS properties (negation_complete, etc.) | Sorry-free | Throughout |
| Quasimodel infrastructure (2,289 lines) | Sorry-free | Eventuality resolution |
| ParametricCanonicalTaskFrame/Model | Sorry-free | Model construction |

**What would need to be NEW**:
1. A different truth lemma structure (by induction on formula complexity, not by separate coherence proofs)
2. A model construction that maps BXPoints to WorldHistory elements without requiring Int-indexed chains
3. Handling the Until backward direction without step-transfer

### Literature Precedent

**Primary references**:
- **Goldblatt (1992)**: "Logics of Time and Computation", Chapter 6. Proves completeness for Until-Since logics over linear orders using the filtration method combined with formula-complexity induction.
- **Gabbay, Hodkinson, Reynolds (1994)**: "Temporal Logic: Mathematical Foundations and Computational Aspects", Vol. 1. Section 6.4 proves completeness for Until over various frame classes using step-by-step canonical model construction with IRR (irreflexivity) rule for strict semantics.
- **Reynolds (2003)**: "An axiomatization of full computation tree logic" (extends the approach to branching time)

**Key technique from Goldblatt**: The "mosaic" or "tile" method constructs finite pieces of the model locally, then assembles them using compactness/ultraproduct. For a finitely axiomatized logic, this reduces to the finite model property proof.

**Key technique from GHR**: The IRR (irreflexivity rule) allows handling strict temporal operators. Under reflexive semantics (our case), IRR is not needed, simplifying the proof significantly.

### Concrete Proof Sketch for the Semantic Approach

Given MCS `M_0` with `neg phi in M_0`:

1. **Define canonical model**: The "world" at point `w : BXPoint` at time `t : D` is the MCS obtained by Lindenbaum extension from a suitable seed. But instead of building this globally, define it LOCALLY for each formula evaluation.

2. **Alternative**: Use the existing `ParametricCanonicalTaskFrame` but with a DIFFERENT family construction. Instead of a single Int-indexed chain, use the collection of ALL BXPoints as the world-set, with the canonical ordering `bx_le`.

   The key issue: this requires mapping BXPoints to a `WorldHistory (ParametricCanonicalTaskFrame D)`. A WorldHistory assigns a world-state to each time `t : D`. We need a single WorldHistory `tau` such that `truth_at M Omega tau t phi` corresponds to `phi in tau(t)`.

   The existing parametric infrastructure already does this: `parametric_to_history` maps an `FMCS D` to a `WorldHistory`. What we need is an FMCS where the MCS at each time step has the right properties.

3. **The semantic twist**: Instead of building the FMCS first and proving coherence after, BUILD the FMCS by induction on the truth lemma proof itself.

   More concretely: define `truth_equiv(fam, root)` as "for all subformulas `psi` of `root`, `psi in fam.mcs t iff truth_at M Omega (parametric_to_history fam) t psi`". Then prove `truth_equiv` by induction on formula complexity.

   But this is CIRCULAR: `truth_at` depends on the model, which depends on the FMCS, which depends on the truth lemma...

4. **Breaking the circularity**: The standard approach uses ABSTRACT canonical truth:
   - Define `canonical_truth(w, phi) := phi in w.formulas` for BXPoints
   - Prove `canonical_truth` respects all connectives by induction
   - The "model" is the canonical frame itself, not a concrete TaskModel
   - The TaskModel embedding is constructed AFTER the truth lemma is proved

   This is essentially what the current TruthLemma.lean attempts, but it requires the coherence properties on the chain.

5. **The right level of abstraction**: What we actually need is to show that given `neg phi in M_0`, there exist `D`, `F`, `TM`, `Omega`, `tau`, `t` such that `not (truth_at TM Omega tau t phi)`. The parametric representation theorem (`fully_restricted_parametric_representation_from_neg_membership`) already provides this IF we can supply the three coherence properties.

   So the question reduces to: can we construct a BFMCS over Int that satisfies restricted temporal coherence, restricted backward Until/Since coherence, and restricted forward Until/Since coherence?

### A Specific Semantic Approach: Induction on Subformula Depth

Instead of proving coherence for the WHOLE chain, prove it formula-by-formula:

**Claim**: For the `dd_bfmcs` construction, restricted temporal coherence can be proved by induction on the F-nesting depth within `deferralClosure(root)`.

**Base case**: If `phi` has no temporal subformulas, then `F(phi) in chain(n)` implies `phi in chain(n)` by BX1 (reflexivity: `G(neg phi) -> neg phi`, contrapositive gives `phi -> F(phi)`, and MCS contains exactly one of `phi` and `neg phi`). Wait -- this isn't quite right. `F(phi) in chain(n)` does NOT directly give `phi in chain(n)`.

However, `F(phi) in chain(n)` with `phi in deferralClosure(root)` means `phi in sigma_list`. The `fwd_chain_of_sigma` construction targets `phi` at round-robin step `schedule(k) = phi` for some `k >= n`. At that step, if `F(phi) in chain(k)`, then `chain(k+1)` is built from the seed `{phi} union g_content(chain(k))`, which includes `phi`. So `phi in chain(k+1)`.

**The gap**: We need `F(phi) in chain(k)`, i.e., the F-obligation must PERSIST from step `n` to step `k`. This is exactly `fwd_chain_F_persistent`, which IS proved sorry-free. So the argument works!

Wait -- let me re-examine. `fwd_chain_F_persistent` is proved, but only for `fwd_chain_of_sigma`, not for the full `dd_chain` which combines forward and backward chains. And the coherence requires STRICT `t < s`, while the construction gives `m > n` in Nat terms that must be translated to `t < s` in Int terms.

Let me trace through more carefully. The dd_chain is defined as:
- For `t - s >= 0`: use `fwd_chain_of_sigma(N, sigma_list, (t-s).toNat)`
- For `t - s < 0`: use `bwd_chain_of_sigma(N, sigma_list, (s-t).toNat)`

For the forward direction of restricted_tc (F resolution), when `t - s >= 0`:
1. `F(phi) in fam.mcs t = fwd_chain_of_sigma(N, sigma_list, (t-s).toNat)`
2. `fwd_chain_F_persistent` ensures `F(phi)` persists forward to step `k` for any `k >= (t-s).toNat`
3. At the round-robin step `k` where `schedule(k) = phi`, `fwd_succ_resolves` gives `phi in fwd_chain(k+1)` (when `F(phi) in fwd_chain(k)`)
4. Setting `s_new = (k+1 : Nat) + s`, we get `phi in fam.mcs s_new`
5. And `s_new = k + 1 + s > t` (since `k >= (t-s).toNat >= t - s`, so `k + 1 + s > t`)

**THIS IS THE PROOF OF `fwd_chain_forward_F`!**

The missing piece in the existing code is precisely the combination of:
1. `fwd_chain_F_persistent` (proved)
2. `schedule_surjective_above` (proved) -- ensures `phi` appears in the schedule
3. `fwd_succ_resolves` (proved) -- the step targeting `phi` resolves it when `F(phi)` is present

Let me re-read the sorry site more carefully to understand why this wasn't already done.

### Re-examining `fwd_chain_forward_F`

The sorry at line 1111 has this signature:

```lean
private theorem fwd_chain_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (φ : Formula) (h_phi : φ ∈ sigma_list)
    (h_F : Formula.some_future φ ∈ (fwd_chain_of_sigma M₀ h₀ sigma_list n).val) :
    ∃ m, n < m ∧ φ ∈ (fwd_chain_of_sigma M₀ h₀ sigma_list m).val
```

The `fwd_chain_of_sigma` is a preserving chain, not the simple `fwd_chain`. Let me check its definition.

Looking at the code around lines 1068-1083, `fwd_chain_of_sigma` uses `preserving_fwd_step` (which uses the BX11 fold and defect-step choice). The `preserving_fwd_step_F_preserved` proves F-persistence for this chain.

The simple approach would be:
1. By `schedule_surjective_above(phi, n)`, get `k >= n` with `schedule(k) = phi`
2. By `fwd_chain_F_persistent`, `F(phi) in chain(k)`
3. The `preserving_fwd_step` at step `k` should resolve `phi` when `schedule(k) = phi` and `F(phi) in chain(k)`

But does `preserving_fwd_step` actually RESOLVE `phi` at the scheduled step? Let me look at how `fwd_chain_of_sigma` uses the schedule... This depends on what `preserving_fwd_step` does: it uses the BX11 fold `defect_step_choice_early` which resolves SOME defect but not necessarily the scheduled one.

**THIS IS THE CORE ISSUE.** The `preserving_fwd_step` does NOT target `schedule(n)` specifically. It resolves whichever defect the BX11 fold happens to prioritize. The `fwd_succ` (simple chain) DOES target `schedule(n)`, but `fwd_succ` does not preserve F-obligations for non-target formulas (dead end #24).

So the semantic approach CANNOT directly close `fwd_chain_forward_F` as currently formulated, because the preserving chain does not guarantee resolution of a specific target.

However, a REDESIGNED chain that alternates between `fwd_succ` (targeting specific formulas) and F-preservation steps could work. This is essentially the hybrid approach.

### Assessment of Direction 2

**Confidence**: 40-60%, depending on whether the chain can be redesigned.

The semantic approach is mathematically correct (it's how the standard proofs work), but translating it into the existing codebase architecture requires either:
1. **Redesigning the chain construction** to guarantee specific-target resolution while maintaining F-persistence (challenging but possible), OR
2. **Replacing the BFMCS-based proof architecture** with a direct semantic truth lemma (major refactor, ~1000+ new lines, but most infrastructure is reusable)

**Critical observation**: The `fwd_succ` chain (simple, non-preserving) DOES resolve `phi` at step `k` when `schedule(k) = phi` and `F(phi) in chain(k)`. The issue is that `fwd_succ` does NOT preserve F-obligations for OTHER formulas. But the `fwd_chain_F_persistent` proof works for the `fwd_chain_of_sigma` (preserving chain), not for the simple `fwd_chain` (using `fwd_succ`).

**A potential solution**: Prove F-persistence for the simple `fwd_chain` (using `fwd_succ`). At non-resolving steps, `fwd_succ` includes `f_carry` (proved: `fwd_succ_f_carry`). At resolving steps, `fwd_succ` uses `forward_temporal_witness_seed` which includes `g_content(M)`. Now, `F(chi) in M` does NOT imply `F(chi) in g_content(M)` (because `G(F(chi))` is not guaranteed to be in `M`). This is exactly dead end #23.

So the simple chain also fails for F-persistence at resolving steps. Both chain types have this problem.

---

## Direction 3: Axiom Strengthening

### Current Axiom System

The BX system has 37 axioms (4 propositional + 5 S5 modal + 26 BX temporal + 2 interaction). The system is sound for all reflexive linear temporal orders.

### What Specific Axioms Would Be Needed

**Option 3A: Until Induction Rule (IRR-style)**

The Gabbay/Hodkinson/Reynolds approach uses the IRR (irreflexivity) rule:

```
If p AND G(p -> X(p)) -> G(p) is valid and p does not occur in phi,
then phi is a theorem.
```

Adapted for Until:

```
If G(phi -> (phi U psi -> ((phi AND (phi U psi)) U psi))) is derivable,
then (phi U psi) -> (phi U psi) can be strengthened with induction.
```

More precisely, an **Until induction rule** would be:

```
From: G(chi -> psi OR (phi AND chi)) derives chi -> (phi U psi)
```

This says: if `chi` is a "loop invariant" (at each point, either `psi` holds and we're done, or `phi AND chi` holds and the invariant continues), then `chi -> (phi U psi)`.

This is derivable in BX + next-step operator but NOT in BX alone.

**Option 3B: Next-Step Operator (Discrete Axioms)**

Adding a genuine next-step operator `X` with:
- `X(phi) <-> bot U_strict phi` (strict Until)
- `X(phi OR psi) <-> X(phi) OR X(psi)`
- `G(phi) -> phi AND X(G(phi))` (G unfolding)

Under reflexive semantics, `bot U phi = phi` (as shown above), so a separate `X` operator with strict semantics would be needed. This would be a SEPARATE connective in the Formula type, NOT definable from the existing Until.

**Impact**: Adding `X` as a primitive would:
1. Require a new constructor in `Formula` (currently: atom, bot, imp, box, all_future, all_past, untl, snce)
2. Require new truth clause in `Truth.lean`
3. Require new axioms for `X` (necessitation, distribution, interaction with G/U)
4. Require new soundness proofs
5. Fundamentally change the logic from "S5 + Until/Since on arbitrary linear orders" to "S5 + Until/Since on DISCRETE linear orders"

**Option 3C: Minimal Addition -- F-resolution Axiom**

A weaker addition:

```
F(phi) AND G(F(phi) -> F(phi)) -> phi  -- incorrect, too strong
```

Actually, what we need is:

```
G(F(phi) -> phi OR F(phi)) -> G(F(phi) -> phi)  -- Loeb-style
```

This is reminiscent of Loeb's axiom for provability logic. It says: if F(phi) always leads to phi-or-F(phi), then F(phi) leads to phi. Under the standard temporal semantics this IS valid (by well-foundedness of the temporal order... but wait, our temporal order is NOT well-founded -- Int has no minimum).

Actually, on Int, the temporal order IS well-ordered in the forward direction (from any point, there are infinitely many future points, but the forward direction is isomorphic to Nat from that point). So a forward-Loeb axiom might be sound.

But this would need careful verification and does NOT follow from the existing BX axioms.

### Would Adding "Next" Change the Logic Substantially?

Yes. Adding a genuine next-step operator changes the frame class from "all linear orders" to "discrete linear orders" (where every point has an immediate successor and predecessor). This is a substantial change:

- The BX system is complete for ALL linear temporal orders (dense, discrete, mixed)
- Adding X makes the logic complete only for DISCRETE orders
- This excludes dense orders like Q and R

However, the project's completeness goal is specifically over `Int` (a discrete order), so this restriction might be acceptable for the current theorem.

### Is There a Minimal Addition That Doesn't Change Expressiveness?

**The IRR rule** is the standard answer. It's not an axiom but a RULE:

```
If phi is derived using only atoms not in the language of the target theorem,
then phi is a theorem.
```

More precisely, IRR (from GHR 1994):

```
From: p AND G(p -> alpha) -> G(p)    [where p is fresh]
Infer: alpha
```

This rule does NOT change the set of valid formulas (it's an admissible rule). It provides exactly the induction principle needed for temporal reasoning.

In the Lean formalization, this would be a new constructor in `DerivationTree`:

```lean
| irr_rule (Γ : Context) (φ : Formula) (p : Atom)
    (h_fresh : p does not occur in Γ or φ)
    (h_deriv : DerivationTree Γ ((atom p).and (((atom p).imp φ).all_future).imp (atom p).all_future)) :
    DerivationTree Γ φ
```

**Impact of IRR**:
1. Does NOT change the set of theorems (admissible rule)
2. Does NOT change the frame class
3. Soundness proof requires showing the rule is valid
4. Would require updating the existing soundness proof
5. Would directly provide the Until step-transfer needed

**Assessment**: IRR is the cleanest option that closes the gap without changing the logic.

### Assessment of Direction 3

**Confidence for IRR rule**: 70%. This is well-studied in the literature and provides exactly what's needed. The main risk is the soundness proof for IRR under reflexive semantics (most literature covers strict semantics).

**Confidence for next-step operator**: 30%. Changes the logic too much.

**Confidence for F-resolution axiom**: 20%. Not well-studied, soundness unclear.

---

## Direction 4 (Not Listed): Formula-Complexity Induction in the Truth Lemma

### The Core Idea

Rather than proving the three coherence properties on the BFMCS and then applying a generic truth lemma, restructure the completeness proof as follows:

1. Build the `dd_bfmcs` chain as currently done (this is sorry-free except for the coherence proofs)
2. Prove the truth lemma by STRONG INDUCTION on formula complexity, where:
   - The G/H cases construct witnesses using `bx_forward_witness` / `bx_backward_witness`
   - The Until/Since forward cases use `bx_until_eventuality_resolution` / `bx_since_eventuality_resolution`
   - The Until/Since backward cases use BX8 at the witness point and backward propagation via BX axioms
3. The model construction maps the abstract BXPoint witnesses back to chain indices

### Why This Might Work

The key observation: the existing sorry-free infrastructure (Frame.lean, Quasimodel/) proves eventuality resolution and witness existence for ABSTRACT BXPoints. The problem is only in mapping these back to the Int-indexed chain.

But for the truth lemma, we don't actually NEED the witnesses to be on the same chain family. We need them to be in the BFMCS (some family). The `dd_bfmcs` has families for ALL modal-equivalent MCS, shifted by any Int offset. So any BXPoint `v` that is modal-equivalent to `M_0` can be placed in some family of `dd_bfmcs`.

**Concretely**: Given `F(phi) in fam.mcs t`, we need `phi in fam.mcs s` for some `s > t`. Instead of requiring this on the SAME family (which is the chain), we could:
1. Use `bx_forward_witness` to get a BXPoint `v` with `phi in v` and `bx_le (fam.mcs t viewed as BXPoint) v`
2. This `v` is modal-equivalent to `fam.mcs t` (because `bx_le` preserves box-formulas in BXPoints on the same chain)
3. Create a NEW family containing `v` at position `s = t + 1`

Wait -- but `restricted_temporally_coherent` requires the witness `s` to be in the SAME family. The families in `dd_bfmcs` are parameterized by `(N, s)` where `N` is a modal-equivalent MCS of `M_0`. The chain at each family is determined by `N`. An arbitrary BXPoint `v` may not appear at any index of any family.

### Alternative: Bypass the BFMCS Entirely

Instead of using `dd_bfmcs` -> `fully_restricted_parametric_representation_from_neg_membership`, construct the countermodel DIRECTLY:

1. Given MCS `M_0` with `neg phi in M_0`
2. Build a custom `TaskModel` and `WorldHistory` directly from the BXPoint canonical frame
3. Use the existing truth lemma (`TruthLemma.lean`) which is proved for the BXPoint frame

The issue: `TruthLemma.lean` proves truth correspondence for BXPoints, but the BFMCS/parametric machinery is needed to embed BXPoints into a `TaskModel` satisfying the `WorldHistory` interface.

Looking at `Completeness.lean:140-143`:
```lean
obtain ⟨D, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
    dd_countermodel M hM_mcs φ h_neg_in
```

The `dd_countermodel` produces the countermodel. It uses `ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel`, `ShiftClosedParametricCanonicalOmega`, and `fully_restricted_parametric_representation_from_neg_membership`.

The `fully_restricted_parametric_representation_from_neg_membership` requires the three coherence properties. Is there a version that doesn't?

Looking at `RestrictedParametricTruthLemma.lean`, the truth lemma is proved assuming restricted coherence. If we could prove a truth lemma WITHOUT requiring these coherence properties (by building them into the induction), we'd bypass the sorry sites entirely.

### Assessment

**Confidence**: 35-50%. This requires either:
- Restructuring the parametric truth lemma to use formula-complexity induction (moderate refactor)
- Building a completely new truth lemma that doesn't go through BFMCS coherence (larger effort)

The key advantage: it leverages ALL the existing sorry-free infrastructure.

---

## Direction 5 (Not Listed): Modifying Frame Conditions

### Could the Problem Be Approached from the Semantics Side?

The `valid` definition quantifies over ALL `D : Type` with `LinearOrderedAddCommGroup`. The completeness theorem proves validity implies derivability.

One approach: instead of proving completeness over arbitrary `D`, prove it specifically for `D = Int` (which is the only frame class the canonical model uses anyway).

Under `D = Int`:
- The temporal order is discrete (every point has an immediate successor/predecessor)
- Well-ordering arguments work (Nat is well-ordered, so forward segments of Int are)
- The "next point" is `t + 1`, the "previous point" is `t - 1`

For discrete `D = Int`, the F-resolution argument becomes:

> If `F(phi) in chain(n)`, then at some future step `m > n`, `phi in chain(m)`.

On Int, "some future step" can be reached by iterating `+ 1`. If at EACH step, either `phi` appears or `F(phi)` persists, then by well-ordering of Nat, `phi` must eventually appear (otherwise `F(phi)` persists forever, which would mean `G(neg phi)` holds, contradicting `F(phi)`).

**Wait**: `F(phi)` persisting forever does NOT mean `G(neg phi)` holds! `F(phi) = neg G(neg phi)`, so `F(phi)` persisting means `neg G(neg phi)` is in every MCS on the chain. This is consistent with `phi` never appearing (if `phi` is always deferred to the future).

But in a well-ordered sequence, if `F(phi)` is in chain(n) for all n, and at each step `chain(n+1)` is an MCS extending `g_content(chain(n))`, then...

Actually, `F(phi) in chain(n) for all n >= N` is semantically consistent. There's no contradiction. This is exactly the perpetual deferral scenario (dead end #22).

### Modified Frame: Saturation Condition

Add a frame condition: the temporal order must be "phi-saturated" -- for every `F(phi)` at time `t`, there exists `s > t` with `phi` at `s`. This is just temporal coherence restated as a frame condition.

This doesn't help -- it's circular (we're trying to PROVE this property).

### Modified Validity: Restrict to Omega-Regular Models

Instead of quantifying over ALL models, quantify over "canonical" models where every F-eventuality is eventually resolved. This changes the definition of `valid` and would require re-proving soundness.

Not recommended -- changes the logic.

### Assessment

**Confidence**: 10%. Modifying frame conditions doesn't address the core issue.

---

## Recommended Approach

### Primary Recommendation: IRR Rule Addition (Direction 3C)

**Rationale**: The IRR rule is the standard mechanism for handling temporal induction in completeness proofs. It is:
1. ADMISSIBLE (does not change the set of theorems)
2. Well-studied in the literature (GHR 1994, Chapter 6)
3. Provides exactly the induction principle needed for Until step-transfer
4. Does not change the frame class

**Implementation sketch**:
1. Add `irr_rule` constructor to `DerivationTree` (~10 lines)
2. Prove soundness of IRR under reflexive semantics (~50-100 lines)
3. Use IRR to prove Until step-transfer in the canonical chain (~100-200 lines)
4. The step-transfer directly closes `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc`
5. For `fwd_chain_forward_F` and `dd_bfmcs_restricted_tc`, IRR provides the induction principle to show that F-eventualities cannot be permanently deferred

**Risk**: Soundness of IRR under reflexive semantics needs verification. Most literature covers strict semantics. Under reflexive semantics, the fresh atom `p` in IRR interacts with `G(p) -> p` (from BX1), which may affect the proof.

### Secondary Recommendation: Semantic Truth Lemma Refactor (Direction 2/4)

If IRR is not viable under reflexive semantics:

1. Restructure the truth lemma to use formula-complexity induction
2. At each inductive step, construct witnesses using the existing sorry-free BXPoint infrastructure
3. Map witnesses back to BFMCS families using modal equivalence and shift-closure
4. This avoids requiring coherence as a pre-condition and instead proves it as a consequence of the induction

**Estimated effort**: 800-1200 lines of new code, with ~80% of existing infrastructure reusable.

### NOT Recommended: Direction 1 (Deterministic Chain Hybrid)

The semantic collapse of `bot U alpha = alpha` under reflexive semantics makes this a dead end.

---

## Evidence and Examples

### Evidence for IRR Viability

The BX system is modeled on Burgess 1982 / Xu 1988. The completeness proof in Xu 1988 uses a technique equivalent to IRR (induction on formula complexity in the truth lemma). The IRR rule was explicitly formulated by Gabbay (1981) and extensively studied in GHR 1994.

### Evidence for Semantic Approach Viability

The existing sorry-free infrastructure proves:
- `bx_forward_witness`: F(psi) in w => exists v >= w with psi in v
- `bx_until_eventuality_resolution`: phi U psi in w, psi not in w => exists v >= w with psi in v and phi in w

These are exactly the witnesses needed for the semantic truth lemma. The gap is ONLY in mapping these witnesses back to the Int-indexed chain.

### Evidence Against Deterministic Hybrid

The calculation `bot U alpha = alpha` under reflexive semantics is elementary and verified in the ROAD_MAP (section "X/Y Operator Status"). This collapse is fundamental and cannot be worked around.

---

## Confidence Levels

| Direction | Confidence | Effort (LOC) | Risk |
|-----------|------------|------------|------|
| 1: Deterministic Hybrid | 5% | N/A | Dead end under reflexive semantics |
| 2: Semantic Truth Lemma | 45% | 800-1200 | Major refactor, but mathematically sound |
| 3A: IRR Rule | 70% | 200-400 | Soundness under reflexive semantics needs verification |
| 3B: Next Operator | 30% | 500-800 | Changes the logic substantially |
| 4: Formula-Complexity Induction | 40% | 600-1000 | Requires restructuring parametric truth lemma |
| 5: Frame Condition Modification | 10% | N/A | Circular / changes the logic |

**Overall recommendation priority**: 3A (IRR) > 2 (Semantic) > 4 (Induction) > 3B (Next) > others

---

## Appendix: The Exact Coherence Requirements

For reference, the three coherence properties that `dd_countermodel` requires:

**1. `restricted_temporally_coherent root`**: For all families `fam` in the BFMCS:
- Forward: `F(phi) in fam.mcs t` and `phi in deferralClosure(root)` implies `exists s > t, phi in fam.mcs s`
- Backward: `P(phi) in fam.mcs t` and `phi in deferralClosure(root)` implies `exists s < t, phi in fam.mcs s`

**2. `restricted_backward_until_since_coherent root`**: For all families `fam`:
- If `phi U psi in subformulaClosure(root)` and there exists a witness `s >= t` with `psi in fam.mcs s` and `phi in fam.mcs r` for all `r in [t, s)`, then `phi U psi in fam.mcs t`
- Symmetric for Since

**3. `restricted_forward_until_since_coherent root`**: For all families `fam`:
- If `phi U psi in subformulaClosure(root)` and `phi U psi in fam.mcs t`, then there exists `s >= t` with `psi in fam.mcs s` and `phi in fam.mcs r` for all `r in [t, s)`
- Symmetric for Since

Note the asymmetry: temporal coherence uses STRICT `<`, while Until/Since coherence uses reflexive `<=`. This matches the semantics (G quantifies `t <= s`, Until has witness `t <= s` with guard `[t, s)`).
