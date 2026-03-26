# Teammate C Findings: G-Box Interaction Mathematical Rigor

**Focus**: Determine if G(phi) -> Box(G(phi)) is derivable in TM logic

**Date**: 2026-03-26

## Key Findings

### 1. G(phi) -> Box(G(phi)) is NOT Derivable in TM Logic

**Verdict: NO** - This formula is not derivable, and I provide both:
- A syntactic argument (derivation impossibility)
- A semantic countermodel

### 2. Semantic Countermodel

In bundle semantics:
- `G(phi)` at (fam, t) means: forall s >= t, phi holds at (fam, s) — within the SAME family
- `Box(G(phi))` at (fam, t) means: forall fam' in bundle, G(phi) holds at (fam', t) — across ALL families

**Countermodel Construction**:

Consider a bundle with two families fam1, fam2, time domain Int, and atomic proposition p:

```
Family fam1:
  p is TRUE at all times t >= 0
  p is FALSE at all times t < 0

Family fam2:
  p is FALSE at all times t >= 1
  p is TRUE at all times t < 1
```

At (fam1, t=0):
- G(p) is TRUE: p holds at all s >= 0 in fam1
- Box(G(p)) is FALSE: In fam2 at t=0, G(p) is false because p is false at t=1

Therefore: G(p) is true but Box(G(p)) is false at (fam1, 0).

This shows G(phi) -> Box(G(phi)) is **semantically invalid**.

### 3. Syntactic Derivation Impossibility

**Why the derivation fails**:

The TM proof system has these relevant components:

**Axioms**:
- MF: `Box(phi) -> Box(G(phi))` (modal-future)
- TF: `Box(phi) -> G(Box(phi))` (temporal-future)
- MT: `Box(phi) -> phi` (modal T/reflexivity)

**Inference Rules**:
- Necessitation: `|- phi ==> |- Box(phi)` (only for THEOREMS)
- Temporal Necessitation: `|- phi ==> |- G(phi)` (only for THEOREMS)

**The fundamental obstacle**:

Necessitation only applies to **theorems** (formulas derivable from empty context). We CANNOT derive Box(G(phi)) from G(phi) because:

1. G(phi) is a contingent fact — it depends on the evaluation point
2. Contingent facts are not theorems
3. The necessitation rule `|- phi ==> |- Box(phi)` requires phi to be a theorem
4. There is no axiom or rule that allows: `G(phi) -> Box(G(phi))`

**Attempted derivation chains (all fail)**:

**Attempt 1: Use MF backwards**
- MF says: Box(phi) -> Box(G(phi))
- We would need: G(phi) -> Box(phi) first
- But this is also not derivable (same problem)

**Attempt 2: Use TF**
- TF says: Box(phi) -> G(Box(phi))
- This gives G(Box(phi)) from Box(phi), not Box(G(phi)) from G(phi)
- Wrong direction entirely

**Attempt 3: Use S5 properties**
- S5 collapse: Diamond(Box(phi)) -> Box(phi)
- Modal B: phi -> Box(Diamond(phi))
- Neither provides G(phi) -> Box(G(phi))

**Attempt 4: Compose MF and TF**
- From Box(phi): MF gives Box(G(phi)), TF gives G(Box(phi))
- But we start with G(phi), not Box(phi)
- To use these axioms, we'd need to "lift" G(phi) to Box(something) first

## Axiom Analysis

### MF Axiom: `Box(phi) -> Box(G(phi))`

- **Direction**: Modal to Modal-Temporal
- **Semantic meaning**: Necessary truths remain necessary at all future times
- **Why it doesn't help**: Requires Box(phi) as input, but we have G(phi)

### TF Axiom: `Box(phi) -> G(Box(phi))`

- **Direction**: Modal to Temporal-Modal
- **Semantic meaning**: Necessary truths will always be necessary
- **Why it doesn't help**: Same issue — requires Box(phi) as input

### What Would Be Needed

To derive G(phi) -> Box(G(phi)), we would need an axiom like:
- "GM" (hypothetical): `G(phi) -> Box(G(phi))` — "global facts are necessary"

This axiom would express: "If phi holds at all future times in my family, then phi holds at all future times in ALL families."

**This is NOT part of TM logic**, and for good reason:
- Different families represent different possible worlds/histories
- They can have completely different futures
- Making G-facts modal would collapse the bundle structure

## Derivation Attempt

**Goal**: Derive `[] |- G(phi) -> Box(G(phi))`

**Available tools**:
1. Axioms: K, S, EFQ, Peirce, MT, M4, MB, M5, MK, TK, T4, TA, TL, T-future, T-past, MF, TF, linearity
2. Rules: modus ponens, necessitation (theorems only), temporal necessitation (theorems only), weakening

**Best attempt**:

```
1. Assume G(phi)                          [hypothesis for conditional]
2. ??? -> Box(G(phi))                     [need something to give Box(G(phi))]
3. No axiom provides Box(G(phi)) from G(phi) alone
4. Necessitation requires a THEOREM, not an assumption
5. STUCK - cannot proceed
```

**The gap is fundamental**: There is no rule or axiom that introduces Box when starting from a temporal formula G(phi).

## Semantic Justification

**Why G -> Box(G) SHOULD be invalid**:

The semantic interpretation of TM logic involves:
- Bundles of histories (families)
- Each family has its own temporal evolution
- Box quantifies over families (modal accessibility)
- G quantifies over time within a single family

The formula G(phi) -> Box(G(phi)) would require:
"If phi holds at all my future times, then phi holds at all future times in every possible history."

This conflates:
- Local temporal facts (within one family)
- Global modal facts (across all families)

**Philosophically**: Just because I know my future, doesn't mean I know everyone's future.

## Confidence Level

**Very High (95%)**

- The semantic countermodel is explicit and verifiable
- The syntactic argument follows directly from the rule structure
- The philosophical interpretation is coherent with TM's intended semantics
- No existing lemma in the codebase suggests this is derivable

## Implications for Cross-Family F Transfer

The non-derivability of G(phi) -> Box(G(phi)) has direct consequences:

**The cross-family transfer problem**:
- We need: phi in fam'.mcs s (for some fam' in bundle, s > t) implies F(phi) in fam.mcs t
- Contrapositive: not(F(phi)) in fam.mcs t implies phi not in fam'.mcs s for all fam', s > t
- This requires: G(not(phi)) in fam.mcs t implies not(phi) in fam'.mcs s

**The gap**:
- We have G(not(phi)) in fam.mcs t
- To transfer to fam', we would need Box(G(not(phi))) in fam.mcs t
- This requires G(not(phi)) -> Box(G(not(phi))), which is NOT derivable

**Conclusion**: The cross-family F transfer is blocked precisely because G-facts don't lift to Box-facts.

## Verdict

**G(phi) -> Box(G(phi)) is NOT derivable in TM logic.**

- **Semantic**: Countermodel exists with two families having divergent futures
- **Syntactic**: No axiom or inference rule produces Box from G without starting from Box
- **Philosophical**: Local temporal knowledge doesn't imply global modal knowledge

This represents a **fundamental limitation** of the TM axiom system for cross-family reasoning, not a gap in the implementation.
