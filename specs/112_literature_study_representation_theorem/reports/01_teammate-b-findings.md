# Teammate B Findings: Alternative Patterns and Prior Art

**Task**: 112 — Systematic literature study: representation theorem sources
**Role**: Teammate B — Alternative Approaches
**Focus**: Patterns different from the chronicle construction; hybrid approach evidence
**Date**: 2026-04-24

---

## Executive Summary

The five sources collectively provide a rich set of alternative strategies. The most
actionable finding is that **Venema 1993 directly supports the hybrid approach** through
its definably-well-ordered model technique: instead of building the canonical structure to
satisfy Until/Since witnesses from scratch, one builds an auxiliary model over linear
orders that is only definably well-ordered, then replaces it with a well-ordered
equivalent that is first-order equivalent at the relevant quantifier depth. This is the
closest existing parallel to transplanting chronicle witnesses onto an Int chain.

Obendrauf 2024 provides directly transplantable Lean 4 structural patterns. Burgess
1982b and Burgess 1984 both clarify that Until/Since completeness for dense orders
requires the full canonical model (no shortcut), but they also give the precise axiom
list that drives completeness for S+U on linear orders. Thomason 1984 establishes that
the correct architecture for combining S5 with tense logic is the T×W or Kamp-frame
approach — not superposition of unrelated canonical models — which has implications
for whether the BX chronicle construction can cleanly separate the Box case from the
Until/Since case.

---

## Source 1: Burgess 1982b — Axioms for Tense Logic II (Time Periods)

### What This Source Is

A period-based (interval-based) tense logic completeness proof for the system S over
homogeneous valuations in Q and R. The key result (Theorem 4.3): every S-consistent
formula is satisfiable in I(Q). The key technique: reduce period-based satisfaction to
instant-based satisfaction via the correspondence lemma (Claim 4.4).

### Alternative Proof Strategy Found

**The homogeneous valuation reduction technique.** Instead of building the canonical
model directly over periods, Burgess proves completeness by:

1. Using the instant-based completeness theorem for J (dense linear orders) to get a
   valuation V in Q.
2. Showing that V can be chosen with a strong regularity property (condition (4): V(α)
   open and closed at every variable).
3. Constructing W = I(V) in I(Q) and proving the correspondence: an interval ]y,z[
   satisfies β in W iff all instants in (y,z) satisfy β in V (Claim 4.4, proved by
   induction on formula complexity).

**Relevance to BX**: The method separates two concerns: (a) build a simpler instant-based
structure where formulas at points are easy to verify, and (b) lift to the target structure
via a correspondence lemma. This is conceptually analogous to the hybrid approach:
build the Int chain where G/H/Box are already verified, then show that Until/Since
witnesses can be "lifted" from a chronicle-style construction.

**Evidence for hybrid approach**: WEAK SUPPORT. The lifting technique works for
period→instant reduction because the correspondence is inductive on formula complexity.
A hybrid that lifts Until/Since witnesses from the chronicle onto the Int chain would
need an analogous correspondence — but the correspondence would be between two
different MCS families rather than between a homogeneous valuation and its underlying
pointwise valuation. The gap is real, but the structural idea is the same.

### Lean 4 Patterns

None directly — source is a pure paper proof. However, the two-stage structure
(build auxiliary structure with nice properties, lift to target) is a pattern Obendrauf
employs at the Lean level (see Source 3).

**Confidence**: Medium — relevant proof architecture, no Lean specifics.

---

## Source 2: Venema 1993 — Since and Until

### What This Source Is

Finite axiomatizations of SU-logics for well-ordered frames and for (ω,<). The key
innovation: completeness is proved **via expressive completeness**, not via a direct
canonical model construction.

### Alternative Proof Strategy Found — Directly Relevant to BX

**Completeness via definably-well-ordered models (Theorems 4.1–4.2).** The strategy is:

1. Start from a BW-consistent formula φ. By ordinary Lindenbaum, obtain a linear model
   M satisfying φ.
2. Show M is a BW-model, hence definably well-ordered (Lemma 4.1).
3. Apply Doets' theorem (3.8): a definably well-ordered linear model has n-equivalents
   for all n. Specifically, M has a well-ordered n+1-equivalent M' (where n = quantifier
   depth of φ^c).
4. Since M ≡_{n+1} M' and φ^c has depth ≤ n, both M and M' satisfy ∃x φ^c(x). So M'
   is the desired well-ordered model for φ.

**This is an indirect approach that completely bypasses the need for the canonical model
to already live in the right frame class.** The linear model is built first (easy), then
replaced by a model of the correct type using expressive equivalence.

**Direct implication for BX hybrid approach**: This confirms the hybrid strategy is
methodologically sound. The Int chain is the "easy" linear model. The problem is showing
that the Int chain, while not having Until/Since witnesses by construction, is nevertheless
first-order equivalent (at bounded quantifier depth) to a model that does. Venema's
approach shows exactly how to make this argument: establish that the Int chain is
"definably well-ordered" in the appropriate sense, then replace it with a well-ordered
model that has the right Until/Since properties.

**However**, there is a crucial difference: BX is not a pure tense logic. The Box/S5
component means the relevant frame class is not just well-ordered linear orders but
"linear temporal orders × S5 equivalence classes" (task frames in BX terminology). The
Doets equivalence argument does not obviously extend to product frames. This is a
significant open question.

### Lean 4 Patterns

None directly. But the proof decomposition is clean:
- `definably_well_ordered : BW_model → DefinablyWellOrdered`
- `doets_theorem : DefinablyWellOrdered → ∀ n, ∃ wo_model, model ≡_n wo_model`
- Completeness then assembles these.

The separation between "model-building" and "model-replacement" is a pattern that maps
well to Lean's type system.

**Confidence**: High for the until/since-only case. Medium for extension to bimodal BX.

---

## Source 3: Obendrauf 2024 — Lean Formalization of Completeness for CLC

### What This Source Is

A full Lean 4 formalization of soundness and completeness for Coalition Logic with
Common Knowledge (CLC). 6,000 lines of code, sorry-free, available at
https://github.com/kaiobendrauf/cl-lean.

### Lean 4 Structural Patterns — Directly Transplantable

**Pattern 1: Filtered canonical model via finite closure.**

The canonical model S^C is infinite (all maximal consistent sets). For a specific formula
φ, Obendrauf filters through cl(φ) (a finite closure set) to obtain S^f (finite states).
The filtered states are s^f = s ∩ cl(φ). This avoids working directly with the infinite
canonical model.

BX relevance: The BX chronicle also works with a fixed formula. A BX formalization
could build a finite "chronicle closure" cl(φ) for the formula being proved consistent,
filter the chronicle states through this closure, and work entirely within the finite
fragment. This would make the Lean proof easier to close (no need to reason about
infinite MCS families).

**Pattern 2: Typeclass hierarchy for logic extension.**

Obendrauf uses Lean 4 typeclasses to make proofs about CL (the base logic) reusable
for CLK (CL + individual knowledge) and CLC (CL + common knowledge). The
class hierarchy is:
```
Pformula_ax (propositional base)
  CLformula (adds effectivity operator)
  Kformula  (adds individual knowledge)
    Cformula (adds common knowledge)
```

BX relevance: The BX system similarly has layers — the base propositional/tense logic,
the Box operator (S5), and the Until/Since operators. A typeclass hierarchy mirroring
this would allow:
- Proving the tense-only part of the truth lemma generically.
- Reusing it for the full BX truth lemma with Box and Until/Since added.

This pattern would directly address the "parametric truth lemma" design already in the
codebase and could make the BX truth lemma more modular.

**Pattern 3: Three-layer datatype management for formulas over finite sets.**

When reasoning about φ_X (the disjunction of formulas for a set of filtered states),
Obendrauf proves results at three levels: Set, Finset, and List. Proofs go:
1. Prove for List (inductive, ordered, allows case analysis).
2. Lift to Finset.
3. Lift to Set.

BX relevance: The BX truth lemma needs to reason about intersections and unions of
formula sets along the chain. The three-layer datatype approach avoids ad hoc
conversions between Set and Finset in the middle of inductive proofs. The BX
formalization could adopt this pattern explicitly.

**Pattern 4: Inductive predicate for multi-step paths (C_path).**

The common knowledge path is an inductive proposition with base case `done` (one-hop)
and recursive case `next` (extend path from front). This differs from the "build path
from back" approach in Agotnes-Alechina. The key advantage: pattern-matching in Lean
is cleaner when the inductive structure matches the direction of reasoning.

BX relevance: The BX omega-chain is built inductively (n → n+1). The truth lemma
induction on the chain could follow the same front-extension pattern. This might clarify
the forward_G / backward_H cases where the current implementation is sorry-site-heavy.

**Pattern 5: Generic canonical model parameterized by proof of consistency.**

```lean
def canonical_model_CL [Nonempty agents] [Pformula_ax form] [CLformula agents form]
    (hnpr : ¬ ⊢ (⊥ : form)) : modelCL agents
```

The consistency proof `hnpr` is a parameter, not assumed globally. This makes the
canonical model construction valid for any consistent extension of CL.

BX relevance: The BX completeness proof similarly needs a consistency assumption to
extract the canonical model. Parameterizing by `hnpr : ¬ ⊢ (⊥ : BXFormula)` (or by
the specific consistent formula) would match this pattern and make the Lean term more
robust.

**Confidence**: High for all five patterns — these are directly applicable regardless of
which proof strategy is chosen for BX.

---

## Source 4: Burgess 1984 — Basic Tense Logic (Chapter II.2)

### What This Source Is

A comprehensive survey of tense logic, including completeness proofs, period-based tense
logic, and the Until/Since section (Section 4A). This is the foundational reference for
the axioms used in the BX proof system.

### Alternative Proof Strategy Found

**Separation-based completeness for U,S (Section 4A).** Burgess describes the strategy
for proving completeness of the U,S-axioms over dense orders: instead of building a
canonical model that directly witnesses U and S, one proves expressive completeness
first ({U,S} is temporally complete over continuous orders, Theorem 4.5), then uses
this to replace any first-order formula with an equivalent SU-formula for the purposes
of the completeness argument.

This is the same strategy Venema uses (expressive completeness → axiomatic completeness)
but described from Burgess's perspective. The separation property (Lemma 4.7) is the
key technical step: any SU-formula can be separated into a truth-functional compound
of pure-past, pure-present, and pure-future SU-formulas.

**Key technical detail**: Separation is specifically proved for the case of a single S
within the scope of a U (and its mirror image). The equivalence used is:
- U(p, q ∧ S(r,t)) is equivalent to a more complex pure formula.
- The proof uses that the frame is complete (every set with an upper bound has a
  supremum), which enables the construction of a supremum as the "witness time" for S
  inside U.

**BX implication**: The BX chronicle's C5/C5' conditions are exactly the conditions
needed to guarantee Until/Since witnesses. The challenge identified in report 15 (the
g-function gap and guard convention mismatch) corresponds precisely to the failure to
establish that Until/Since can be witnessed within the canonical structure. Burgess's
approach goes around this by using expressive completeness — but this requires density
or completeness of the underlying linear order. For BX (which needs to work on
discrete or sparse frames), this particular approach is not available in its standard form.

**Completeness proof method used by Burgess for simple G/H tense logic (Section 2):**

The standard approach is an explicit Lindenbaum + saturated model construction
(pp. 1016+). The completeness proof for L_0 over the class of all frames builds a
canonical model (W*, R*) where W* = all MCS, R*(Γ, Δ) iff G-closure of Γ ⊆ Δ. This
is the Int chain approach already in the BX codebase, and Burgess confirms it works
for G/H without density requirements.

**Confidence**: High for the claim that the chronicle approach is necessary for Until/Since
and that the Int chain is sufficient for G/H alone.

---

## Source 5: Thomason 1984 — Combinations of Tense and Modality (Chapter II.3)

### What This Source Is

A survey of combining modal operators (historical necessity / S5) with tense operators
(G,H,F,P). The central theoretical frameworks are T×W frames, Kamp frames, and
neutral frames.

### Alternative Architectural Approach to Combining S5 with Linear Tense Logic

**The T×W framework (Definition 6).** A T×W frame is (W, T, <, ~) where T is linearly
ordered and ~_t is a family of equivalence relations on W such that: if w ~_t w' and
t' < t then w ~_{t'} w'. Satisfaction: Box φ at (t,w) iff φ at (t,w') for all w' ~_t w.

This directly models "historical necessity" — what is necessary at time t is what holds
in all worlds that share the past up to t.

**For BX, this is architecturally different from the chronicle approach:**

- The chronicle builds a single linear sequence of MCS with a separate modality
  component encoded via the g-function.
- The T×W approach would build a 2D structure: a linear time axis T × a world set W,
  with truth conditions treating tense and modality independently within each world.
- Thomason notes (p. 147): T×W validity is essentially first-order, hence recursively
  axiomatizable. The completeness proofs for T×W should use Gabbay's techniques.

**Kamp frames (Definition 9)** are more liberal: each world w has its own local linear
ordering F(w) = (T_w, <_w), and ~_t is defined on the union of all T_w's. This allows
worlds to have different temporal structures, which is closer to BX's task frame model
where different worlds (tasks) have their own temporal components.

**The key principle for BX** (from Thomason's Section 4, p. 148, axiom AK12):

    OP φ → P O φ

reads: "if it is possible that something was the case, then at some earlier time it was
possible". This is exactly the backwards version of the BX Box interaction with the
tense operators. Kamp's axiom system (AK0–AK13 + RK0–RK3) gives a sound but
incomplete axiomatization of Kamp frames — incompleteness is exhibited by formula
(17), whose validity in Kamp frames requires diagram completion (interpolation between
any two worlds that share a past point).

**Implications for BX completeness architecture:**

1. BX is closer to a T×W frame (shared linear time, with S5 equivalence at each time
   point) than to a Kamp frame (per-world timelines). This means the BX completeness
   proof should be easier than Kamp completeness.

2. The T×W approach suggests a canonical model where states are pairs (MCS, world),
   rather than just MCS along a single line. This is the chronicle's implicit structure
   (the g-function encodes which "worlds" are accessible at each time point).

3. Thomason confirms (p. 147) that T×W validity is recursively axiomatizable. The
   methods referenced are Gabbay's irreflexivity techniques, which are precisely what
   enables the completeness proof for dense/complete linear orders (as discussed in
   Venema and Burgess 1984).

4. The BX chronicle construction is attempting to do what T×W canonical models
   should do: maintain both the temporal sequence and the modal accessibility
   simultaneously. The g-function gap (never updated in the omega-chain) corresponds
   to the failure to properly maintain the ~_t component of the T×W structure.

### Evidence for / Against Hybrid Approach

**Against**: The hybrid approach treats the Int chain (temporal backbone) and the chronicle
(modal/Until witness provider) as separable components. Thomason's analysis suggests
they are NOT cleanly separable: the validity of BX axioms like AK12 (OP φ → P O φ)
depends on the interaction between the temporal and modal dimensions simultaneously.
If the Int chain is built without awareness of the modal structure, then transplanting
chronicle witnesses onto it requires checking that the combined structure satisfies all
the interaction axioms.

**For**: Thomason's T×W frame analysis also shows that T×W validity is "essentially
first-order" — meaning once you have the first-order equivalence between the easy
structure and the target structure, modal truth transfers automatically (because Box is
defined via ~_t, which is a first-order condition). This supports the Venema strategy:
build the Int chain (easy), then show first-order equivalence to a proper task frame,
and modal truth comes for free.

**Confidence**: High for the architectural analysis. Medium for the implication that
first-order equivalence suffices for the modal transfer in BX.

---

## Synthesis: Evidence for the Hybrid Approach

The hybrid approach from report 15 is: use the Int chain for G/H/Box (already
sorry-free), transplant chronicle-style Until/Since witnesses.

**Supporting evidence:**

1. **Venema 1993** (strong): The definably-well-ordered → well-ordered equivalence
   strategy is a published instance of exactly this approach. Build an "easy" model
   (definably well-ordered linear model), then replace with a "correct" model (actually
   well-ordered) that is first-order equivalent. Applied to BX: build the Int chain
   (easy), replace with a model that actually has Until/Since witnesses (chronicle-based),
   show first-order equivalence at bounded depth.

2. **Burgess 1984, Section 4A** (supporting): Until/Since completeness for dense orders
   uses the full force of expressive completeness — there is no shortcut that avoids
   constructing proper Until/Since witnesses. This confirms that the Int chain alone
   (without witness machinery) is genuinely insufficient for Until/Since. A hybrid
   approach must actually provide witnesses.

3. **Thomason 1984** (mixed): Confirms that the temporal and modal components
   interact non-trivially in ways that cannot be cleanly separated. However, for T×W
   frames (BX's architecture), the interaction is axiomatized explicitly, and the
   first-order nature of T×W frames means first-order equivalence transfers modal truth.

4. **Obendrauf 2024** (supporting Lean engineering): The filtered canonical model
   pattern shows that it is feasible to work with a finite fragment and avoid the
   complexity of the full infinite canonical structure. This supports constructing a
   "local" chronicle witness for each Until/Since formula in cl(φ) rather than a global
   g-function.

**Against the hybrid approach:**

1. **Thomason 1984** (mixed): The T×W structure requires joint satisfaction conditions.
   The hybrid transplants witnesses from one construction to another; whether the
   combined structure satisfies the joint conditions (Box × Until interactions) needs proof.

2. **No source gives a direct example of the transplant mechanism.** The closest is
   Venema's model-replacement strategy, but Venema replaces the entire model, not
   just one component.

---

## Recommendations for Task 107

### High Confidence

1. **The Int chain is sufficient for G/H/Box.** This is confirmed by both Burgess 1984
   (Int chain = standard G/H canonical model) and the existing sorry-free code.

2. **Until/Since requires witness machinery.** Burgess 1984 Section 4A and Venema 1993
   both confirm there is no shortcut: proper Until/Since completeness requires either
   (a) a canonical model that directly provides witnesses, or (b) a model-replacement
   argument using expressive/definable equivalence.

3. **Obendrauf's filtered canonical model + typeclass hierarchy patterns** should be
   evaluated for the BX Lean formalization regardless of proof strategy. They reduce
   complexity and improve reusability.

### Medium Confidence

4. **The Venema model-replacement strategy is the most promising alternative to the
   chronicle.** Build the Int chain (already working), then use an analog of Doets'
   theorem to replace it with a model that has Until/Since witnesses. The open question
   is whether Doets' theorem extends to the bimodal BX setting.

5. **The T×W framing (Thomason 1984)** suggests that the g-function in the chronicle
   should be understood as encoding the ~_t accessibility relation at each time point.
   Fixing the g-function (the Layer 1 problem from report 15) is equivalent to properly
   maintaining the ~_t component through the omega-chain.

### Low Confidence

6. **Full separation between temporal and modal components** is unlikely to work for
   BX completeness, because Thomason shows the interaction axioms create genuine
   dependencies. Any clean architectural separation must still verify that the combined
   structure satisfies all interaction axioms.

---

## Summary Table

| Source | Alternative Strategy | Lean Patterns | Hybrid Evidence | Confidence |
|--------|---------------------|---------------|-----------------|------------|
| Burgess 1982b | Two-stage lift (instant→period) | None | Weak support (structural analogy) | Medium |
| Venema 1993 | Definably-well-ordered → WO replacement | Clean proof decomposition | Strong support | High |
| Obendrauf 2024 | Filtered canonical model; typeclass hierarchy | 5 directly transplantable patterns | Indirect (Lean engineering) | High |
| Burgess 1984 | Separation property; expressive completeness | None | Confirms Until/Since needs witnesses | High |
| Thomason 1984 | T×W frame architecture | None | Mixed (shows interaction constraint) | High |
