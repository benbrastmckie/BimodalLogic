# Teammate A Findings: Chain Constructions with F-Resolution Built In

**Task**: 83 — Close Restricted Coherence Sorries
**Focus**: Tier 2 path analysis — round-robin targeted Lindenbaum extension
**Date**: 2026-04-05

## Key Findings

### 1. Why the Current Approach Fails (Recap)

The deterministic chain `chain(n+1) = x_content(chain(n))` is fully deterministic: no Lindenbaum extension, no choice. The impossibility argument from report 18 is definitive: the set `{F(A), neg(A), X(neg(A)), X(F(A)), ...}` is finitely consistent, extends to an MCS, and the resulting deterministic chain has `neg(A)` at every position. F-resolution cannot be proved after construction because the construction never consults F-obligations.

The dovetailed chain (DovetailedChain.lean) does consult F-obligations via `temporal_theory_witness_with_g_exists`, but its forward_F proof is still sorry because the dovetailed construction uses Lindenbaum extension at each step (not x_content), losing the tight x_content linkage that until_unfold/until_intro require for Until/Since coherence.

**The core tension**: x_content gives determinism and Until/Since coherence but no F-resolution. Lindenbaum extension gives F-resolution but no Until/Since coherence. Published proofs resolve this by building a construction that gets both.

### 2. The Existence Lemma (Goldblatt / Standard Modal Logic)

The standard **existence lemma** in modal logic states: if `diamond(phi) in w` (where w is an MCS), then there exists an MCS `v` accessible from `w` with `phi in v`. The proof constructs the seed set `{phi} union {psi : box(psi) in w}`, shows it is consistent (if not, then `box(neg(phi)) in w`, contradicting `diamond(phi) in w`), and extends via Lindenbaum.

For temporal logic with F (eventually), the analogous lemma is:

**Temporal Existence Lemma**: If `F(phi) in M` (MCS), then there exists an MCS `W` with:
- `phi in W`
- `g_content(M) subset W` (preserves G-obligations)
- `box_class_agree(M, W)` (preserves modal class)

This is exactly `temporal_theory_witness_with_g_exists` in UltrafilterChain.lean (line 2285), which is already proven in the codebase. The seed is `{phi} union G_theory(M) union box_theory(M) union g_content(M)`, consistency is shown via the G-wrapping technique, and `set_lindenbaum` extends it.

**Key point**: This lemma gives a SINGLE witness for a SINGLE F-obligation. It does not by itself give a chain where ALL F-obligations are resolved.

### 3. Published Approaches to Building F-Resolution into Chains

#### 3a. Burgess (1984) — Canonical Frame for Tense Logic

Burgess's approach for tense logics over discrete linear time (Z) works within the canonical model where ALL MCS are worlds. The temporal accessibility relation is not arbitrary — it must be arranged so that the set of worlds forms a linear order. The construction:

1. Start with target MCS M_0
2. Build a chain of MCS indexed by Z
3. At each step, choose the successor MCS to be one that resolves a pending F-obligation while preserving G-content

The key insight: since the canonical model has ALL MCS as potential worlds, there is no shortage of witnesses. The challenge is arranging them linearly while maintaining temporal coherence. Burgess uses the fact that tense logic axioms (TA: phi -> GPphi, TA_dual: phi -> HFphi) force connectivity.

#### 3b. Goldblatt (1992) — Existence Lemma + Enumeration

Goldblatt's approach in "Logics of Time and Computation" (Chapter 8) for temporal logic over discrete orders:

1. Enumerate all formulas: phi_0, phi_1, phi_2, ...
2. Build the chain by induction on N
3. At step n, if the current MCS contains F(phi_k) for some unresolved k, extend to include phi_k as a witness
4. Use the existence lemma to guarantee that the extension is consistent

This is essentially the round-robin approach: cycle through obligations, resolving one at each step.

#### 3c. GHR (1994) — Quasimodel Construction

Gabbay-Hodkinson-Reynolds use a more sophisticated "quasimodel" approach:
1. Build a structure where each point has a "type" (an MCS)
2. Defects (unresolved F-obligations) are identified
3. The construction iterates, patching defects by inserting witness points
4. A limit argument shows all defects are eventually resolved

This is the most powerful approach but also the most complex to formalize.

### 4. Recommended Construction: Hybrid Deterministic-Lindenbaum Chain

The key insight for this codebase is that we need a construction that:
- Uses x_content linkage for Until/Since coherence (which is already proven)
- Periodically interrupts with Lindenbaum extensions to resolve F-obligations
- Ensures every F-obligation is eventually resolved

**Proposed Construction: Interleaved Chain**

```
Input: MCS M_0 containing the target formula
Output: chain : Z -> MCS with all F-obligations resolved

Forward direction (n >= 0):
  Enumerate all (position, formula) pairs: (i, phi_j) via Nat.pair

  At step n:
    Let M_n = current chain position
    Let (i, j) = Nat.unpair(n)
    Let phi = decode(j)

    If F(phi) in M_i AND phi not yet witnessed at any position > i:
      -- RESOLVE: Use temporal_theory_witness_with_g_exists to find W
      -- with phi in W, g_content(M_n) subset W, box_class_agree
      chain(n+1) = W
    Else:
      -- DEFAULT: Use x_content for deterministic step
      chain(n+1) = x_content(M_n)
```

**Problem**: This breaks x_content linkage at resolution steps. When chain(n+1) = W (Lindenbaum extension) instead of x_content(chain(n)), the until_unfold/until_intro proof breaks because it relies on:
```
phi in chain(n+1) iff X(phi) in chain(n)
```

### 5. The Real Solution: Two-Layer Construction

After careful analysis, the correct approach is a **two-layer construction** that separates the temporal successor relation from F-resolution:

**Layer 1: Deterministic Chain (already exists)**
```
det_chain(n+1) = x_content(det_chain(n))
```
This gives Until/Since coherence but no F-resolution.

**Layer 2: F-Resolving Subsequence Selection**

Instead of modifying the chain, we observe that the deterministic chain from an MCS M_0 might not resolve F(phi) directly — but we can CHOOSE M_0 to be one where F(phi) WILL be resolved.

**Key Lemma (the mathematical crux)**:

> **F-Resolution Lemma**: For any MCS M and formula phi with F(phi) in M, there exists an MCS M' with:
> - phi in x_content^k(M') for some k > 0
> - g_content(M) subset M'
> - box_class_agree(M, M')
> - x_content(M) = x_content(M')  ... NO, this is too strong.

This does not work because x_content is deterministic — different MCS give different x_content chains.

### 6. The Correct Solution: Non-Deterministic Chain with Targeted Extension

After deeper analysis, the correct construction is:

**Round-Robin Targeted Lindenbaum Chain**

```
chain : N -> MCS
chain(0) = M_0

At step n, let (i, j) = Nat.unpair(n):
  Let phi_j = the j-th formula (via Encodable)
  Let target_pos = i

  If F(phi_j) in chain(target_pos) AND phi_j has not been witnessed:
    -- Build a segment from chain(n) to a witness for phi_j
    -- Use the UNTIL INTRO axiom to maintain Until obligations

    Step A: Find W with phi_j in W, g_content(chain(n)) subset W
            (via temporal_theory_witness_with_g_exists)
    Step B: chain(n+1) = W

  Else:
    chain(n+1) = x_content(chain(n))  -- deterministic step
```

**The critical mathematical fact**: When we do a Lindenbaum extension step (chain(n+1) = W instead of x_content(chain(n))), we need to show that Until obligations from chain(n) transfer to W.

**Lemma needed**: If (phi U psi) in chain(n) and g_content(chain(n)) subset W, then either psi in W or ((phi U psi) in W and phi in W).

**Proof sketch**:
- (phi U psi) in chain(n) implies by until_unfold: X(psi v (phi AND (phi U psi))) in chain(n)
- This means (psi v (phi AND (phi U psi))) in x_content(chain(n))
- But x_content(chain(n)) is NOT necessarily a subset of W
- Instead: G(psi v (phi AND (phi U psi))) may not be in chain(n)

**This is the fundamental difficulty**. The Lindenbaum extension W inherits g_content(chain(n)) (formulas under G), but Until obligations are NOT under G — they are "one-step" obligations via X, not persistent ones via G.

### 7. Resolution: The F_until_equiv Bridge

The axiom `F_until_equiv: F(psi) -> top U psi` converts F-obligations to Until obligations. And `until_induction` provides the inductive structure. The key insight:

If F(phi) in M (an MCS), then by F_until_equiv: `(top U phi) in M`. By until_unfold: `X(phi v (top AND (top U phi))) in M`, which simplifies to `X(phi v (top U phi)) in M`.

So if we take a default x_content step: chain(n+1) = x_content(chain(n)), then `phi v (top U phi) in chain(n+1)`. If phi in chain(n+1), we are done (F-witness found). If not, then `(top U phi) in chain(n+1)`, and the obligation persists.

**The problem**: The obligation persists INDEFINITELY via the impossibility argument. Each step defers: chain(n+k) always has `(top U phi)` but never `phi`.

**The solution in published proofs**: At some step, FORCE phi to appear by choosing a successor that includes phi. The temporal_theory_witness_with_g_exists lemma guarantees such a successor exists. The price is losing x_content linkage at that step.

### 8. Proposed Formalization Strategy

After extensive analysis, the recommended approach for Lean 4 formalization is:

**Construction: Modified Dovetailed Chain with Until Propagation**

The existing DovetailedChain already uses `temporal_theory_witness_with_g_exists` for F-resolution. The gap is proving that Until/Since obligations propagate through Lindenbaum extension steps. The key lemma:

**Until Transfer Lemma**: If (phi U psi) in M and W is a temporal theory witness from M (i.e., g_content(M) subset W and box_class_agree(M, W)), then either:
  (a) psi in W, or
  (b) phi in W and (phi U psi) in W

**Proof**: By until_unfold, X(psi v (phi AND (phi U psi))) in M. This means G(psi v (phi AND (phi U psi))) may or may not be in M. But we have a stronger tool:

From (phi U psi) in M:
- By until_induction with chi = phi U psi:
  - Premise 1: G(psi -> (phi U psi)) — provable (until_intro gives X(psi v ...) -> (phi U psi))
  - Premise 2: G(phi AND X(phi U psi) -> (phi U psi)) — this is the step case
- This gives: (phi U psi) -> X(phi U psi)

Wait — until_induction gives `(phi U psi) -> X(chi)` where chi satisfies certain closure conditions. If we set chi = (phi U psi), we need G(psi -> (phi U psi)) and G(phi AND X(phi U psi) -> (phi U psi)). The second premise IS until_intro. The first requires that psi implies phi U psi, which is not generally true.

**Revised approach**: The correct formulation uses the fact that G(phi U psi -> X(phi U psi)) is derivable from until_unfold + propositional reasoning (when psi does not hold). This gives:

If (phi U psi) in M and psi not in x_content(M), then (phi U psi) in x_content(M).

This is exactly `until_persists_chain` already proven in DeterministicChain.lean. But this only works for x_content steps, not Lindenbaum steps.

### 9. Final Recommended Approach

After this deep analysis, the cleanest path is:

**Option A: Prove forward_F via a non-chain argument (MEDIUM confidence)**

Instead of building F-resolution into the chain, prove it using a compactness/model-theoretic argument:

- If F(phi) in chain(t), show that `{phi} union g_content(chain(t))` is consistent
- By set_lindenbaum, extend to MCS W with phi in W and g_content(chain(t)) subset W
- Show W = chain(s) for some s > t ... but this is false in general (W is a fresh MCS, not necessarily on the chain)

This does not work for the deterministic chain.

**Option B: Replace the deterministic chain entirely (HIGH confidence, 25-40 hours)**

Build a new chain construction that:
1. Uses Lindenbaum extension at EVERY step (like DovetailedChain)
2. Proves Until/Since coherence via the transfer lemma approach
3. Uses round-robin fair scheduling for F-resolution

The concrete construction:

```lean
noncomputable def resolving_chain (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    ℕ → Set Formula
  | 0 => M₀
  | n + 1 =>
    let M_n := resolving_chain M₀ h_mcs n
    let h_mcs_n := resolving_chain_mcs M₀ h_mcs n  -- proved by mutual induction
    let (i, j) := Nat.unpair n
    let phi := Encodable.ofNat Formula j
    if h_F : Formula.some_future phi ∈ M_n then
      -- Resolve: include phi in successor via targeted Lindenbaum
      (targeted_witness_exists M_n h_mcs_n phi h_F).choose
    else
      -- Default: use temporal_theory_witness_with_g_exists with F(top)
      (temporal_theory_witness_with_g_exists M_n h_mcs_n
        (Formula.neg Formula.bot) (contains_F_top h_mcs_n)).choose
```

The key invariants:
1. Every chain element is MCS (from set_lindenbaum)
2. g_content(chain(n)) subset chain(n+1) (from temporal_theory_witness construction)
3. box_class_agree across all elements (from temporal_theory_witness construction)
4. For every F(phi) in chain(n), there exists m > n with phi in chain(m) (from fair scheduling via Nat.unpair)

**What needs proving for Until/Since coherence**:

Forward Until coherence: if (phi U psi) in chain(t), then there exists s > t with psi in chain(s) and phi in chain(r) for all t < r < s.

This follows from: (phi U psi) in chain(t) implies F(psi) in chain(t) (derivable from until_induction). Then by F-resolution (invariant 4), psi in chain(s) for some s > t. For the guard condition (phi at intermediate positions), we need a separate argument using g_content propagation.

**The gap**: Showing phi at intermediate positions. g_content(chain(t)) subset chain(t+1) gives us that G-formulas propagate. But (phi U psi) -> G(phi) is NOT valid — phi only needs to hold until psi does.

**Resolution**: This is where the Until/Since axioms become critical. From (phi U psi) in chain(t):
- By until_unfold: the next step has psi v (phi AND (phi U psi))
- If psi holds at step t+1, done (s = t+1)
- If not, phi AND (phi U psi) at t+1, giving phi at t+1 and the obligation continues

But this reasoning requires x_content linkage, which we don't have in the Lindenbaum chain.

**The fundamental issue persists**: g_content propagation gives phi (under G) at the next step only if G(phi) is in the current step. Until obligations are under X, not G.

### 10. Breakthrough: X-Content Seed Enhancement

The way to resolve this is to enhance the Lindenbaum seed at each step to include not just g_content but also the RELEVANT x_content formulas:

**Enhanced Seed**: At step n, the seed for Lindenbaum extension includes:
```
{target_phi}                         -- F-resolution target (if applicable)
union g_content(chain(n))            -- G-propagation (already in temporal_theory_witness)
union box_theory(chain(n))           -- Modal coherence (already in temporal_theory_witness)
union until_obligations(chain(n))    -- NEW: {psi v (phi AND (phi U psi)) : (phi U psi) in chain(n)}
```

The until_obligations set captures what x_content would give for Until formulas. We need to show this enhanced seed is consistent.

**Consistency argument**:
- g_content(chain(n)) union box_theory(chain(n)) is consistent (already proven)
- Adding target_phi: consistent if F(target_phi) in chain(n) (already proven)
- Adding until_obligations: these are consequences of x_content(chain(n)), and x_content(chain(n)) is consistent (it is an MCS). The question is whether they are consistent WITH g_content and target_phi.

This is the key lemma that needs careful proof. The argument is:
- x_content(chain(n)) is an MCS containing all of until_obligations AND g_content (since G(a) in chain(n) implies a in x_content(chain(n)))
- So `until_obligations union g_content(chain(n)) subset x_content(chain(n))`
- Adding target_phi: if F(target_phi) in chain(n), then F(target_phi) in x_content(chain(n)) (if G propagates F)... wait, F(target_phi) may not propagate through G.

Actually: if F(phi) in chain(n), does G(F(phi)) in chain(n)? Not necessarily. But F(phi) in chain(n) implies X(phi v (top U phi)) in chain(n) (via F_until_equiv + until_unfold). So phi v (top U phi) in x_content(chain(n)). We want to find W with phi in W... but phi might not be consistent with x_content(chain(n)) (that is exactly the impossibility argument).

**However**: The target phi at resolution steps does NOT need to be at the IMMEDIATE next step. It can be at any future step. The round-robin ensures we will eventually try to resolve F(phi) from a position where phi CAN appear.

### Summary Assessment

After extensive analysis across published approaches and the existing codebase:

**The correct construction requires abandoning x_content linkage entirely for the completeness chain**, accepting that Until/Since coherence must be proved through a different mechanism than until_unfold/until_intro (which require X-linkage).

The two viable paths are:

1. **Enhanced Dovetailed Chain** (modify existing DovetailedChain.lean): Prove Until/Since coherence via g_content propagation + an inductive argument that does NOT rely on x_content linkage. This requires the "Until Transfer Lemma" which transfers Until obligations through temporal theory witnesses.

2. **Hybrid Chain**: Use deterministic x_content steps as the default, interrupt with Lindenbaum steps only for F-resolution, and prove that the occasional Lindenbaum interruption does not break Until coherence (because the interrupted step can be "absorbed" into a longer resolution segment).

## Recommended Construction

**Option B (Enhanced Dovetailed Chain)** with the following specific plan:

1. Keep the existing dovetailed chain structure from DovetailedChain.lean
2. Prove the **Until Transfer Lemma**: when W = temporal_theory_witness(M, phi), and (alpha U beta) in M, then either beta in W or (alpha in W and (alpha U beta) in W). The proof uses:
   - g_content(M) subset W (from temporal_theory_witness construction)
   - G(alpha U beta -> (beta v (alpha AND (alpha U beta)))) is NOT in M generally
   - But: the until_unfold gives X(beta v ...) in M, which is in x_content(M). We need this in W. Since g_content(M) subset W, and g_content includes formulas under G, we need G(beta v (alpha AND (alpha U beta))) in M, which requires G(alpha U beta) in M.
   - **If G(alpha U beta) is NOT in M**, the obligation does NOT persist through g_content. This is actually fine: it means the obligation is a "local" one that gets resolved within a bounded number of steps.

3. Prove forward_F using the round-robin argument (already sketched in DovetailedChain)
4. Prove Until coherence using a combination of:
   - The backward induction proof from report 18 (for backward direction)
   - The Until Transfer Lemma for forward direction

## Existing Infrastructure Assessment

| Component | Status | Reusable? |
|-----------|--------|-----------|
| `deterministic_chain` | Complete, sorry-free | YES for backward Until/Since |
| `x_content_mcs`, `y_content_mcs` | Proven | YES |
| `until_persists_chain` | Proven (for x_content steps) | YES for deterministic parts |
| `temporal_theory_witness_with_g_exists` | Proven | YES (core F-resolution) |
| `set_lindenbaum` | Proven (Zorn) | YES |
| `Nat.unpair`, `Encodable Formula` | Available | YES (fair scheduling) |
| DovetailedChain forward_step | Defined | YES (base structure) |
| DovetailedChain forward_F | SORRY | Target to close |
| DeterministicFMCS Until/Since coherence | SORRY | Closable via backward induction |
| `F_until_equiv` axiom | Available | YES (bridges F and Until) |
| `until_unfold` / `until_intro` | Available | YES |

## Confidence Level

**MEDIUM** (60%)

**Justification**:
- The mathematical approach is well-understood from published literature (HIGH confidence that it works mathematically)
- The specific formalization path has a non-trivial gap: the Until Transfer Lemma through Lindenbaum extension steps is not straightforward and may require additional axiom-derived lemmas
- The backward Until/Since closure (via backward induction on the deterministic chain) is HIGH confidence and should be done first regardless
- The existing DovetailedChain infrastructure provides a solid starting point but its forward_F proof gap has resisted 17+ research rounds, suggesting the formalization difficulty is significant
- Estimated effort: 25-40 hours for a complete implementation, with the Until Transfer Lemma being the critical risk item

## References

- Burgess, J. (1984). "Basic Tense Logic" in Handbook of Philosophical Logic, Vol. II
- Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed. CSLI Publications
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1. Oxford University Press
- Reynolds, M. (2003). "An Axiomatization of Full Computation Tree Logic"
- Stanford Encyclopedia of Philosophy: [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- Verbrugge, R. "Completeness by construction for tense logics of linear time" — [PDF](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
