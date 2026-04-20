# Teammate C Findings: Risks of Removing BX1/BX1' Serial Axioms

**Task**: 93 — Complete BXCanonical Embedding
**Role**: Critic — risks and blind spots of removing serial axioms
**Date**: 2026-04-20

---

## Key Findings

### 1. BX1/BX1' Are Already "Removed" in Practice — But Their Consequences Are Not

The most important discovery: the codebase already treats the system as if BX1/BX1'
were NOT reflexivity axioms. The axiom comments explicitly state:

```
-- Under irreflexive semantics, bx_le is NOT reflexive.
-- G(φ) → φ is no longer valid.
```

And `bx_le_refl` is already **sorry'd** in `Frame.lean` (line 205). The sorry comment
says "Under irreflexive semantics, bx_le is NOT reflexive." This means BX1 has
**already been reinterpreted from G(φ)→φ (reflexivity) to ⊤→F(⊤) (seriality)**.

The axioms in `Axioms.lean` are `serial_future` and `serial_past`, which assert
`⊤ → F(⊤)` and `⊤ → P(⊤)`. These are NOT the same as `G(φ) → φ` (T-axiom for G).

**Conclusion**: The system already has seriality-only axioms, NOT reflexivity. The
question is not whether removing BX1 is safe — it is whether the existing codebase
correctly handles the consequences of having seriality-but-not-reflexivity.

### 2. g_content_subset_self is the Central Sorry

The most critical sorry in the completeness proof chain is `g_content_subset_self`:

```lean
-- Under irreflexive semantics, g_content(M) ⊆ M does NOT hold (BX1 removed).
theorem g_content_subset_self {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
    g_content M ⊆ M := by sorry
```

And its mirror `h_content_subset_self`. These appear in `CanonicalModel.lean`
(lines 205–213) and `RootScopedChain.lean` (lines 631–663).

**Why this matters**: Under a reflexive G (i.e., G(φ)→φ as an axiom), we would have
`g_content(M) = {φ | G(φ) ∈ M} ⊆ M` because G(φ)→φ is an axiom so any MCS containing
G(φ) also contains φ. Under strictly irreflexive semantics with only seriality
(⊤→F(⊤)), this implication **fails**: G(φ) ∈ M does NOT force φ ∈ M.

### 3. What BX1 (Seriality) Does Accomplish in the Codebase

The seriality axiom `⊤ → F(⊤)` (i.e., `serial_future`) is used precisely to prove
`g_content_set_consistent` in `Frame.lean` (lines 148–162):

```lean
-- Seriality: ⊤ → F(⊤) is derivable, where F(⊤) = ¬G(¬⊤)
have h_serial : DerivationTree [] ((Formula.bot.imp Formula.bot).imp
  (Formula.some_future (Formula.bot.imp Formula.bot))) :=
  DerivationTree.axiom [] _ Axiom.serial_future
```

The proof shows: if G(⊥) ∈ S, then ¬G(¬⊤) = F(⊤) would have to be in S (by
seriality), but we also derive G(¬⊤) ∈ S from G(⊥), giving a contradiction.
This proves g_content(S) is consistent. That proof works **correctly** under
existing seriality axioms.

Similarly `h_content_set_consistent` works (lines 168–195) using `serial_past`.

**Conclusion**: Seriality is correctly used for the consistency proof.
The problem is that consistency is NOT the same as subset.

### 4. The Chain Construction Critically Depends on g_content_subset_self

The forward chain induction (`fwd_chain_g_content_trans` in `CanonicalModel.lean`,
lines 223–237) contains the base case:

```lean
| zero =>
    -- Under irreflexive semantics, g_content_subset_self is sorry'd
    exact g_content_subset_self (fwd_chain M₀ h₀ 0).property
```

This says: g_content(chain(m)) ⊆ chain(m). Without this, the inductive proof
that g_content propagates through the chain **breaks at the base case**.
The entire Int-indexed canonical chain's ordering properties rest on this sorry.

The inductive step (m < n) uses `temp_4` (G(φ)→G(G(φ))), which is sound. But
the base case (m = n) requires reflexivity, not just seriality.

### 5. The Until/Since Backward Direction Has a Related Problem

In `TruthLemma.lean`, there are two sorry'd theorems:

```lean
theorem until_backward_refl_mcs (w : BXPoint) (φ ψ : Formula)
    (h_ψ : ψ ∈ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas := by sorry

theorem since_backward_refl_mcs (w : BXPoint) (φ ψ : Formula)
    (h_ψ : ψ ∈ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas := by sorry
```

The comments explicitly say "Under irreflexive semantics, ψ → (φ U ψ) is NOT
axiomatically valid (no reflexive witness)." This is CORRECT — with irreflexive
Until semantics, the witness s must be strictly greater than t. If ψ holds at t,
there is no witness at t itself. So `ψ → φ U ψ` is genuinely not provable. These
sorries are **correctly identified as irresolvable without semantic redesign**.

### 6. The Frame-Theoretic Coherence Problem

In `Frame.lean`, `bx_le` is defined as:
```lean
def bx_le (w v : BXPoint) : Prop := g_content w.formulas ⊆ v.formulas
```

And `bx_le_refl` says g_content(w) ⊆ w.formulas, which is exactly
`g_content_subset_self`. The sorry at line 202 is the **same gap** as in
CanonicalModel.lean, just at the frame level rather than the chain level.

**The canonical ordering bx_le is NOT reflexive under irreflexive semantics.**
This creates a fundamental problem for the completeness proof structure,
which assumes a preorder (reflexive + transitive) for the canonical frame.

### 7. What Would BX1 as G(φ)→φ Accomplish

If BX1 were instead the temporal T-axiom `G(φ) → φ` (reflexivity for G),
then `g_content_subset_self` would be trivially provable: any MCS containing
G(φ) would contain φ via MP on the T-axiom. This would repair:
- `bx_le_refl`
- `g_content_subset_self` and `h_content_subset_self`
- `fwd_chain_g_content_trans` base case
- `bwd_chain_h_content_trans` base case
- Until/Since backward reflexive cases (ψ → φ U ψ is valid under reflexive Until)

But adding G(φ)→φ would change the semantics from irreflexive to reflexive G,
requiring a different soundness proof for temporal axioms.

---

## Gaps and Risks

### Risk 1: Seriality Cannot Substitute for Reflexivity in the Chain Construction

BX1 as `⊤ → F(⊤)` proves that g_content is **consistent** (as a set), but does
NOT prove that g_content is a **subset** of the MCS. These are fundamentally
different claims. The sorry-annotated comments in the codebase already document this
explicitly. Any approach claiming seriality is sufficient for the chain construction
must explain how to bridge the consistency-vs-subset gap.

### Risk 2: The Completeness Proof Architecture May Need a Different Canonical Model

The standard canonical model for tense logics on linear orders uses either:
- **Reflexive semantics**: bx_le is reflexive (from G(φ)→φ), making the chain
  construction straightforward.
- **Irreflexive semantics with seriality**: The canonical model must be built
  as an ω+ω* chain (forward and backward), but the MCS nodes are NOT self-related
  under bx_le. The "same-node" case in truth lemma induction must be handled
  by a DIFFERENT argument — one that shows the given MCS appears at some position
  in the chain, not that the ordering is reflexive.

The current architecture assumes a reflexive preorder but has sorry'd the reflexivity
step. Removing BX1/BX1' without redesigning this architecture will leave the same
sorries in place.

### Risk 3: The Until/Since Truth Lemma Has a Semantics Mismatch

The `until_backward_refl_mcs` sorry is NOT just a proof gap — it reflects a genuine
semantic incompatibility. Under irreflexive Until:
- Semantically: `φ U ψ` at t requires a strict future witness s > t
- Canonically: ψ ∈ w does NOT entail `φ U ψ` ∈ w (no reflexive witness)

This means the truth lemma for Until (`⊨ φ U ψ ↔ MCS contains φ U ψ`) would have
a false backward direction. One of the biconditionals needed for completeness
simply does not hold under the current semantics + axioms combination.

### Risk 4: Removing BX1/BX1' Does Not Simplify Anything

The seriality axioms `⊤→F(⊤)` and `⊤→P(⊤)` are already the WEAKER axioms
(compared to G(φ)→φ). The current system already uses seriality-not-reflexivity.
"Removing" BX1 would mean removing these seriality axioms, which would break even
the `g_content_set_consistent` proof (which relies on seriality to derive a
contradiction from G(⊥) ∈ S). That proof is one of the WORKING parts of the codebase.

### Risk 5: Frame Correspondence Confusion

BX1/BX1' as seriality axioms correspond to the frame property that every point has
a strict future (no maximal element) and a strict past (no minimal element). This is
exactly the property of Int (the integers). The logic without seriality is valid on
ALL linear orders including those with endpoints. The canonical model for the
weaker logic (without seriality) would be valid on, say, {0, 1, 2, ...} (Nat),
which has a minimum. Embedding such a canonical model into Int requires EXTRA work
showing the canonical model maps into an endpoint-free linear order.

---

## Critical Observations

### Observation A: The Real Blocker Is Reflexivity, Not Seriality

The central sorry sites in the completeness chain are all caused by one missing
piece: `g_content M ⊆ M` (equivalently: `G(φ) ∈ M → φ ∈ M` for every MCS M).
This requires the temporal T-axiom `G(φ) → φ`, NOT seriality `⊤ → F(⊤)`.
The axiom system has seriality but not temporal-T. This gap was created when the
system transitioned from reflexive to irreflexive semantics for G.

### Observation B: Two Architectural Paths, Neither Simple

**Path 1 — Add temporal T-axiom**: Add `G(φ) → φ` back as an axiom (alongside
the existing seriality axioms). This repairs `g_content_subset_self` and
`bx_le_refl`. BUT this changes the semantics: the temporal T-axiom is only valid
on models where every time point is in its own future (reflexive temporal order).
Under strictly irreflexive G semantics (as currently used), G(φ)→φ is NOT valid.
This would require switching to non-strict (reflexive) G semantics throughout.

**Path 2 — Redesign canonical model**: Build a canonical model where the
"reflexive" cases in the truth lemma are handled without bx_le reflexivity.
Concretely: the truth lemma for F(ψ) uses a forward witness (already proved);
the backward direction of Until needs a different approach — perhaps using
the BX9 axiom (φ U ψ → φ ∨ ψ) combined with the fact that the canonical
model chain provides a suitable temporal structure. This path requires more
fundamental redesign but stays consistent with irreflexive semantics.

### Observation C: The enriched_seed_consistent Sorry Is Also Blocking

`enriched_seed_consistent` in `CanonicalModel.lean` (line 54) says:
"Under irreflexive semantics, g_content(M) ⊆ M no longer follows from BX1.
Consistency needs to be proved via seriality + MCS properties. Sorry'd pending
Phase 2 redesign."

This sorry is explicitly noted as a design problem, not a proof technique problem.
The seed `g_content(M) ∪ f_carry(M)` needs to be consistent. Under reflexive
semantics, both g_content(M) ⊆ M and f_carry(M) ⊆ M, so the union is a subset
of M (which is consistent). Under irreflexive semantics, neither subset relationship
holds automatically.

### Observation D: Two Active Completeness Paths, Both Blocked

The CanonicalModel.lean comment (lines 459–472) documents that the active path is:
`bx_completeness → dd_countermodel (RootScopedChain.lean)`.

The `RootScopedChain.lean` also uses `g_content_subset_self` in its chain
construction (lines 631–635, 659–663), meaning even the "active" completeness
path is blocked by the same reflexivity gap.

---

## Confidence Level

**High confidence** on the core finding: BX1/BX1' in their current form (as
seriality axioms `⊤→F(⊤)`) are already present and correctly used for the
consistency proofs. Removing them would break even the working parts.

**High confidence** on the gap identification: The root cause of the central
sorry sites (`g_content_subset_self`, `h_content_subset_self`, `bx_le_refl`,
`until_backward_refl_mcs`, `since_backward_refl_mcs`) is the absence of the
temporal T-axiom `G(φ)→φ`, not a problem with the seriality axioms.

**Medium confidence** on the architectural paths: The two repair paths (add
temporal-T vs. redesign canonical model) both require substantial work. Which
is more tractable depends on the intended semantics (reflexive vs. irreflexive G),
which is a design decision not fully resolvable from the codebase alone.

**Key recommendation**: Do NOT remove BX1/BX1'. They are already the weaker
seriality forms, already correctly placed, and already needed for the working
parts of the proof. The sorry sites require either (a) adding G(φ)→φ as an
axiom and switching to reflexive G semantics, or (b) redesigning the canonical
model to avoid reflexivity of bx_le in the truth lemma induction.
