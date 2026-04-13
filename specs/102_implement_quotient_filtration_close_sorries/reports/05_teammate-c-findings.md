# Research Report: Critic Analysis - Gaps and Assumptions

- **Task**: 102 - Close remaining 4 Frame.lean sorries
- **Role**: Teammate C - Critic
- **Artifact**: 05_teammate-c-findings.md
- **Date**: 2026-04-12

---

## Key Findings

- The Frame.lean sorry signatures quantify over ALL BXPoints in a bx_le interval, which is
  strictly stronger than what the semantics requires and almost certainly unprovable as stated.
- Path 1 (Until induction axiom) is the highest-risk approach: the axiom was deliberately removed
  and re-adding it changes the proof system with unknown completeness implications.
- Path 2 (chain-based bypass) is the most mathematically sound but carries substantial
  implementation risk in the TaskModel embedding step.
- Path 3 (totality on relevant intervals) conflates a proof strategy with a definition change and
  is likely unsound.
- A fourth path exists and deserves evaluation: weakening the sorry signatures to match what
  semantics actually needs (chain-restricted guards).

---

## Critique of Each Path

### Path 1: Add Until Induction Axiom Back to BX

**The axiom in question**:
`G(ψ → χ) ∧ G((φ ∧ χ) → G(χ)) → ((φ U ψ) → χ)`

**Sufficiency critique (MEDIUM concern)**:

The axiom would provide exactly the induction schema needed to prove guard properties. The
forward direction of `bx_until_eventuality_resolution` needs: given `φ U ψ ∈ w` and a witness
`v` with `ψ ∈ v`, show `φ ∈ u` for all `bx_le w u` with `bx_lt u v`. The Until induction
axiom with `χ := G(¬(φ U ψ) ∨ φ)` or similar would give this. So it is sufficient in
principle.

**Why it was removed (HIGH concern)**:

The axiom was removed during the BX5/BX6 refactor. This was not accidental: BX5
(self-accumulation) and BX6 (absorption) together replace the induction axiom at the
semantic level, providing eventuality resolution without a full induction schema. Adding it
back creates redundancy. More critically: the axiom is valid only on Noetherian (well-founded)
orderings where the induction terminates. On dense or non-discrete linear orders, the Until
induction schema in the form above is NOT valid. BX5+BX6 are valid on ALL linear orders
including dense ones. Adding the Until induction axiom back would restrict the frame class,
breaking the "valid on all linear orders" property claimed in Axioms.lean.

**Interaction with completeness (HIGH concern)**:

The codebase explicitly claims all BX axioms are sound on all linear orders. The Until
induction axiom is sound only on discrete/well-founded orders. Adding it would:
(a) break the `Axiom.frameClass` function which returns `Base` for all axioms,
(b) require adding a `Discrete` frame class variant for the new axiom,
(c) require updating all soundness proofs that rely on "all axioms are Base."

This is not a localized change. It cascades through the entire proof system.

**Verdict**: Path 1 solves the immediate problem but introduces unsoundness on dense orders
and requires architectural changes to the axiom system. It is fixing a symptom by breaking
a design invariant. **Confidence this approach is correct: 15%.**

---

### Path 2: Chain-Based Completeness Bypass

**The idea**: Build a canonical model directly from a defect-discharge chain indexed by
integers, prove truth on the chain, and bypass Frame.lean's universal-quantifier sorries
entirely.

**Mathematical soundness (HIGH confidence)**:

This is the standard Burgess 1984 / Goldblatt 1992 approach. The integers provide a total
order by construction, so the guard condition `∀ r : Int, w ≤ r < v → φ ∈ chain[r]` is
provable because the chain is built to satisfy it. The sorries are unprovable as stated
because they quantify over "junk" BXPoints that exist in the Lindenbaum construction but
have no semantic role. The chain bypasses this cleanly.

**Infrastructure availability (MEDIUM concern)**:

`Construction.lean` and `DefectChain.lean` provide defect-discharge infrastructure.
`SigmaOrdering.lean` provides sigma ordering. The scaffolding exists. However, prior round
3 research established that Phases 1-4b are complete. The GAP is in the TaskModel
embedding: how to construct a `TaskModel` from a finite/infinite chain of BXPoints such
that the box modality (S5 modal component) is correctly handled. The world history must
be compatible with the shift-closed set `Omega` of histories.

**Key unresolved gap (HIGH concern)**:

The chain-based approach builds a linear sequence `(w_i)_{i : Int}` of BXPoints. The
`TaskFrame` requires `WorldState`, `task_rel w d u` satisfying three axioms. The trivial
`task_rel w_i d w_j := (j = i + d)` works. BUT the box modality `□φ` requires a
separate set `Omega` of admissible histories, and the truth lemma for `□` must read:
`□φ at (Omega, tau, t)` iff `∀ sigma ∈ Omega, φ at (Omega, sigma, t)`. For the truth
lemma of the canonical model, `□φ ∈ w_i` should correspond to `□φ` being true at
position `i` in the chain. This requires constructing `Omega` such that each world
state `w_i` is in a history `sigma ∈ Omega` where `sigma(i) = w_i` and all S5-accessible
worlds at position `i` also satisfy `φ`. The construction of `Omega` is non-trivial and
was noted as unresolved in the round 3 synthesis ("no one fully worked out how to
construct a TaskModel from a finite chain").

**Risk of parallel completeness divergence (HIGH concern)**:

The current codebase has TruthLemma.lean complete for G, H, Box, atom, bot, imp cases.
Building a parallel chain-based truth lemma risks creating two incompatible routes to
completeness: the existing MCS-based route (which uses Frame.lean) and the new chain-based
route. If both exist, maintenance cost doubles. If the chain-based route is the only
intended path, then Frame.lean and TruthLemma.lean become dead code -- but they are
significant investments (~600+ lines each).

**Verdict**: Path 2 is mathematically correct and high-confidence for the temporal
component, but the TaskModel/box-modality embedding is a genuine open problem. Without
resolving this gap, the chain closes the Until/Since sorries but may not actually complete
the completeness theorem. **Confidence in partial success (Until/Since): 70%.
Confidence in full completeness: 40%.**

---

### Path 3: Restructure bx_le to Be Total on Relevant Intervals

**The claim**: Make `bx_le` total on "relevant intervals" (the interval [w, v] where w
has `φ U ψ` and v is the ψ-witness).

**Definitional problem (CRITICAL)**:

`bx_le` is defined as `g_content w.formulas ⊆ v.formulas`. This is a semantic definition
derived from the axiom BX1 (T-reflexivity). Changing it to be total requires either:
(a) restricting which BXPoints exist (changing the canonical model domain), or
(b) changing the ordering relation itself.

Option (a): Restricting BXPoints to a subset where the ordering is total would be a
quotient construction (identifying BXPoints by their g_content intersection with some
finite set Sigma). This is the filtration/quotient approach, not "totality on intervals."

Option (b): Changing `bx_le` breaks everything downstream: all existing lemmas about
`bx_le` (bx_G_forward, bx_G_backward, bx_modal_witness, etc.) use the current definition.

**What "relevant" means (UNCLEAR)**:

The proposal says "relevant intervals." But relevance depends on which formula is being
proved, which changes at each application. A definition of `bx_le` that is total only for
some instances and partial for others is not a well-defined relation. What is actually
being suggested is either (a) restricting to a quotient where totality holds universally,
or (b) a proof strategy that avoids the non-total cases -- neither of which is "totality
on relevant intervals" as a property of the existing `bx_le`.

**Semantics impact (HIGH concern)**:

The Soundness theorem uses `bx_le` as the canonical temporal ordering. If `bx_le` is
modified to be total, the soundness proof must be re-verified because the new ordering
may not coincide with the semantic accessibility relation on all task frames.

**Verdict**: Path 3 conflates two distinct things: a proof strategy ("prove the sorry by
finding a total sub-ordering") and a definition change ("make bx_le total"). As a proof
strategy it reduces to the chain-based approach (Path 2). As a definition change it
breaks the existing infrastructure and requires re-proving soundness. The name "Path 3"
suggests a distinct approach, but mathematically it is either a variant of Path 2 or
unsound. **Confidence this is a valid distinct path: 10%.**

---

## Missing Alternatives

### Alternative A: Weaken the Sorry Signatures

The current signatures quantify over ALL BXPoints `u` with `bx_le w u` and `bx_lt u v`.
The semantics (Truth.lean) only requires the guard over times `r` within a SINGLE world
history -- not all BXPoints in the bx_le preorder. The sorry signatures are over-specified.

The fix: change the sorry signatures in Frame.lean to quantify only over chain members, not
arbitrary BXPoints. Specifically:

```
-- Current (too strong, unprovable):
∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
  ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas

-- Weakened (matches semantics):
∃ (n : Nat) (chain : Fin n → BXPoint),
  chain 0 = w ∧ ψ ∈ (chain (n-1)).formulas ∧
  (∀ i : Fin n, bx_le (chain i.val) (chain i.val.succ)) ∧
  (∀ i : Fin n, i.val < n - 1 → φ ∈ (chain i.val).formulas)
```

This matches Truth.lean's existential world history structure: the chain IS the history
`tau`, and the guard condition is over chain members only.

**Risk**: TruthLemma.lean's Until case uses the current signatures. Changing them requires
updating TruthLemma.lean. This is work, but it is CORRECT work -- it aligns the
signatures with the semantics rather than making the canonical model overly abstract.

**Confidence this works**: 60-70%. The main risk is that TruthLemma.lean's Until case
needs careful reworking to use the chain structure instead of abstract bx_le intervals.

### Alternative B: Derive Until Induction Without New Axioms

The round 3 synthesis identified the derived theorem `φ U ψ → ψ ∨ (φ ∧ F(φ U ψ))` from
BX1 + BX9. This is a one-step unfolding. The backward direction `ψ ∨ (φ ∧ F(φ U ψ)) → φ U ψ`
was flagged as unverified.

If the backward direction holds, then `φ U ψ ↔ ψ ∨ (φ ∧ F(φ U ψ))` gives an inductive
characterization of Until without a new axiom. The TruthLemma could be reformulated:
instead of `bx_until_eventuality_resolution`, the Until case uses the unfolding equivalence
directly, with the F-case reducing to a bx_le witness (already proved).

**This is worth time-boxing**: 3-5 hours to verify the backward direction and attempt
the TruthLemma reformulation. Low cost, potentially closes all 4 sorries if it works.

### Alternative C: Separate S5 and Temporal Completeness

The box modality and temporal operators are proved in the same canonical model. The
difficulties are all in the temporal component. A cleaner architecture would prove:

1. Temporal completeness separately on linear orders (using chain-based model, no box).
2. S5 completeness separately (using Kripke models, no temporal operators).
3. Combine via the product frame construction (standard for multi-modal logics).

This is longer-term restructuring but eliminates the source of interaction complexity.
Not viable for the current task but worth noting as a design direction.

---

## Root Cause Analysis

**The real problem is an architectural mismatch, not a missing axiom or tactic.**

The Frame.lean sorries fail because the canonical model for BX was designed with
**information-theoretic ordering** (`bx_le = g_content inclusion`) while the semantics
uses **positional ordering** (world history index). These are not the same:

- `bx_le w v` means "every G-invariant at w holds at v" -- a safety/invariant property.
- The semantics needs `w` and `v` to be at positions `t` and `s` in a single linear
  history -- a positional property.

Any MCS `w` can be `bx_le`-related to infinitely many MCSs that are semantically
unrelated (they exist for different Lindenbaum extensions of different seeds). The sorry
signatures ask about ALL such `bx_le`-related points, which is impossibly strong.

**Should we fix symptoms or causes?**

The symptoms are the 4 Frame.lean sorries. The cause is the mismatch between information-
theoretic ordering and positional ordering. Fixing symptoms (trying to prove the sorries
as stated) requires either:
(a) Adding an axiom that restricts the class of models (risky, as in Path 1), or
(b) Accepting unprovability and proving something weaker (Alternative A above).

Fixing the cause requires restructuring the canonical model to use positional ordering
(Path 2 / Alternative A). This is more work but produces a correct and maintainable proof.

**The prior round 3 analysis (03_team-research.md) correctly identified this** as an
information-theoretic vs. positional ordering mismatch. The current task's three paths
are all attempts to patch the symptom. None of them address the cause cleanly.

**Assumption validation**: Are the Frame.lean sorries actually unprovable?

The analysis in CanonicalChain.lean (lines 18-56) argues unprovability and presents
three possible fixes. Round 3 research assigned 80% confidence to unprovability. No
one has produced a formal non-provability proof (that would require a model-theoretic
argument showing the sorry statement fails in some MCS configuration). However, the
argument is convincing: the sorry statement requires `φ ∈ u.formulas` for an arbitrary
`u` with `bx_le w u ∧ bx_lt u v`, but `φ` need not be a G-formula, so `bx_le` cannot
propagate it. The formula `φ` appears in the guard of `φ U ψ` -- it is a "liveness"
formula, not a "safety" formula. There is no BX axiom that turns liveness formulas
into G-content. The assumption is well-founded but not formally proved.

---

## Confidence Level

| Claim | Confidence |
|-------|------------|
| Frame.lean sorries are unprovable as currently stated | HIGH (80%) |
| Path 1 (Until induction axiom) is sound on all linear orders | LOW (15%) |
| Path 2 (chain-based bypass) correctly closes Until/Since component | HIGH (70%) |
| Path 2 fully closes all 4 Frame.lean sorries including box case | MEDIUM (40%) |
| Path 3 (bx_le totality) is a coherent distinct approach | LOW (10%) |
| Alternative A (weaken signatures) is viable | MEDIUM-HIGH (65%) |
| Alternative B (inductive reformulation via unfolding) is viable | MEDIUM (40%) |
| Root cause is positional vs information-theoretic ordering mismatch | HIGH (90%) |

## Recommendation

The team should NOT attempt Path 1. It breaks soundness on dense orders and cascades
through the axiom system.

Path 3 is not a coherent path; it either reduces to Path 2 or is unsound.

Path 2 is the right mathematical approach but carries a genuine open gap in the
TaskModel/box-modality embedding. This gap should be explicitly investigated before
committing to Path 2.

Alternative A (weakening sorry signatures) is the cheapest fix that aligns the code with
the mathematical reality. It is less elegant than a complete chain-based proof but avoids
the TaskModel embedding problem. It should be evaluated seriously alongside Path 2.

**Recommended order of investigation**:
1. Alternative B: 3-5h time-box on the inductive unfolding (cheap, could solve everything).
2. Alternative A: If B fails, weaken signatures and update TruthLemma (moderate work, high confidence).
3. Path 2: If A proves awkward, commit to full chain-based bypass (most work, highest confidence in end result).
