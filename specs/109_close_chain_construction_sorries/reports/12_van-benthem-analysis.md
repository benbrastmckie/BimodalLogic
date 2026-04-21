# Van Benthem's Result on Irreflexivity and Its Implications for the ProofChecker

**Task**: 109 (Close chain construction sorries)
**Date**: 2026-04-21
**Focus**: Precise analysis of modal undefinability of irreflexivity and reconciliation with the "same validities" claim from Report 11

---

## 1. What "Modally Definable" Means

A class **C** of (Kripke) frames is **modally definable** if there exists a set Sigma of modal formulas such that a frame F belongs to C if and only if every formula in Sigma is valid on F. Formally:

```
C is modally definable  :=  exists Sigma, C = { F | for all phi in Sigma, F |= phi }
```

Here F |= phi means: for every valuation V on F and every world w in F, (F, V), w |= phi.

Examples of modally definable frame classes:
- Reflexive frames: defined by the T-axiom, box(p) -> p
- Transitive frames: defined by the 4-axiom, box(p) -> box(box(p))
- Serial frames: defined by the D-axiom, box(p) -> diamond(p)
- Symmetric frames: defined by the B-axiom, p -> box(diamond(p))

The key question is: **Is the class of irreflexive frames modally definable?**

---

## 2. Van Benthem's Result: Irreflexivity Is Not Modally Definable

### 2.1 The Precise Statement

**Theorem** (van Benthem; see also Blackburn, de Rijke & Venema 2001, Ch. 3):
The class of irreflexive frames -- frames (W, R) where for all w in W, not Rww -- is **not modally definable**. That is, there is no set Sigma of modal formulas such that:

```
F is irreflexive  <=>  F |= Sigma
```

This result holds for the **basic modal language** (with box and diamond, or equivalently with G, H, F, P in the tense setting). It concerns **general frames** (arbitrary binary relations), not specifically linear orders.

### 2.2 The Bounded Morphism Argument

The standard proof uses the fact that modal validity is preserved by surjective bounded morphisms (p-morphisms). A **bounded morphism** f : F -> G between frames (W, R) and (W', R') is a function f : W -> W' such that:

1. **Forth condition**: If Rwv, then R'(f(w))(f(v))
2. **Back condition**: If R'(f(w))(v'), then there exists v with Rwv and f(v) = v'

The key preservation theorem states: if f : F -> G is a surjective bounded morphism and F |= phi, then G |= phi for any modal formula phi.

**Counterexample**: Consider the two-element irreflexive frame:

```
F = ({w1, w2}, {(w1, w2), (w2, w1)})
```

This is irreflexive: neither w1 R w1 nor w2 R w2. Define f : F -> G where G is the one-element frame:

```
G = ({u}, {(u, u)})
```

with f(w1) = f(w2) = u. This is a surjective bounded morphism:
- Forth: w1 R w2 gives f(w1) = u, f(w2) = u, so u R' u. Check.
- Back: u R' u, so given f(w1) = u, we need v with w1 R v and f(v) = u. Take v = w2. Check.

But F is irreflexive while G is reflexive. Since f is a surjective bounded morphism, every modal formula valid on F is also valid on G. Therefore no modal formula can be valid on exactly the irreflexive frames -- if it were valid on every irreflexive frame (including F), it would also be valid on G, which is reflexive.

### 2.3 The Goldblatt-Thomason Perspective

The Goldblatt-Thomason theorem (1975) gives a precise characterization: an elementary class K of frames is modally definable if and only if K is closed under:

1. Surjective bounded morphic images
2. Generated subframes
3. Disjoint unions
4. And **reflects** ultrafilter extensions

The class of irreflexive frames fails condition (1): as shown above, an irreflexive frame can have a reflexive bounded morphic image. It also fails condition (4): the ultrafilter extension of an irreflexive frame can introduce reflexive points (ultrafilters that "see themselves" through the lifted relation).

### 2.4 Scope of the Result

The result is stated for **general Kripke frames** with arbitrary binary relations. It applies to:
- Unimodal logic (single box/diamond)
- Bimodal tense logic (G/H or F/P)
- Any extension with finitely many basic modalities

The result does **not** automatically apply to:
- Extended languages with additional operators (e.g., Until/Since, nominals, the difference operator)
- Restricted frame classes (e.g., frames already known to be transitive and linear)

---

## 3. Reconciliation: "Not Modally Definable" vs "Same Validities"

### 3.1 The Two Claims

Report 11 (Teammate B) stated:

> "For basic tense logic (G/H only), irreflexive and reflexive validities are identical. Completeness for one immediately gives completeness for the other."

Van Benthem's result states:

> The class of irreflexive frames is not modally definable.

**These claims are NOT contradictory.** They concern different things.

### 3.2 The Key Distinction

**Modal definability** asks: Can we find a set of formulas that *characterizes exactly* the irreflexive frames? That is, can we find Sigma such that F |= Sigma *if and only if* F is irreflexive?

**Same validities** asks: Is the set of formulas valid on *all* frames identical to the set of formulas valid on all *irreflexive* frames? That is, does Log(All) = Log(Irr)?

These are logically independent questions!

- **Definability** requires a *biconditional*: F is irreflexive <=> F |= Sigma
- **Same validities** requires only an *equality of logics*: {phi | all F |= phi} = {phi | all irreflexive F |= phi}

### 3.3 Why Both Are True Simultaneously

**Claim A (van Benthem)**: The class of irreflexive frames is not modally definable.

This means: there is no set of modal formulas whose validity *characterizes* irreflexivity. Specifically, any modal formula valid on all irreflexive frames is also valid on some reflexive frames (and indeed on all frames, as we show below).

**Claim B (Same validities for basic Kt)**: The logic Kt of all frames equals the logic of all irreflexive frames.

This is stated in Venema's temporal logic chapter: "Connectedness and irreflexivity do not yield any extra validities" over basic tense logic Kt. More precisely: for the basic tense language with G, H (and their duals F, P), a formula phi is valid on all frames if and only if it is valid on all irreflexive frames.

**Why these are compatible**: Claim A says we cannot *define* the irreflexive frames using modal formulas. Claim B says there is no modal formula that *separates* the two classes (valid on one but not the other). These say the same thing from complementary angles:

- Because no modal formula can distinguish irreflexive from reflexive frames (Claim B), there is certainly no set of formulas that characterizes exactly the irreflexive ones (Claim A).
- Conversely, because irreflexive frames are not modally definable (Claim A), and because every irreflexive frame validates at least the formulas valid on all frames, the only possibility is that the two sets of validities coincide exactly.

### 3.4 The Formal Argument for Same Validities

The proof that Log(All) = Log(Irr) in the basic tense language proceeds as follows:

**Direction 1** (trivial): Log(All) is contained in Log(Irr). If phi is valid on all frames, it is valid on all irreflexive frames (since irreflexive frames are frames).

**Direction 2** (the interesting direction): Log(Irr) is contained in Log(All). Suppose phi is NOT valid on all frames, i.e., there exists a frame F, a valuation V, and a world w such that (F, V), w |/= phi. We need to show phi is also not valid on all irreflexive frames.

The standard technique is to construct, from any pointed model (M, w), a bisimilar pointed model (M', w') where M' is based on an irreflexive frame. This is done by "unraveling" the model into a tree. The tree unraveling of any Kripke model produces a model based on an irreflexive frame (paths in a tree have a strict prefix ordering, which is irreflexive), and the unraveling is bisimilar to the original. Since bisimilar models satisfy the same modal formulas, if (M, w) |/= phi then (M', w') |/= phi, and M' is irreflexive.

For the tense logic case (with both forward and backward modalities G and H), one uses the **zig-zag** or **two-way unraveling** technique to produce an irreflexive frame that is bisimilar in both the forward and backward directions.

### 3.5 Why This Is "Not the Rule"

Venema notes that this coincidence of validities "is not the rule in modal logics." In general, a frame condition that is not modally definable *can* still yield extra validities. The classic example:

- The McKinsey formula box(diamond(p)) -> diamond(box(p)) is not valid on all frames
- But it is valid on all frames satisfying: for all x, exists y, Rxy and (for all z, Ryz implies z = y) (i.e., every point has an R-successor that is an R-terminal)
- This frame condition is not modally definable, yet it generates a genuine extra validity

For irreflexivity in basic tense logic, the coincidence happens because the unraveling technique works particularly well: every frame can be "unraveled" into an irreflexive one while preserving all modal information.

---

## 4. What About Linear Orders?

### 4.1 Linear Irreflexive Frames

On **linear orders**, the situation is more nuanced.

A strict linear order (L, <) and its reflexive closure (L, <=) are interdefinable from the underlying order: x < y iff x <= y and x /= y, and x <= y iff x < y or x = y. So from the perspective of the *mathematical structure*, there is no difference.

However, from the perspective of **what the modal operators mean**, there is a difference:

- G(phi) at t under reflexive semantics: phi holds at t and at all s > t
- G(phi) at t under strict semantics: phi holds at all s > t (but NOT necessarily at t)

The formula G(p) -> p is valid on (L, <=) but not on (L, <). They interpret the *same operator symbol* G differently.

### 4.2 Is the Class of Irreflexive Linear Frames Modally Definable?

No. The class of irreflexive linear frames is still not modally definable in the basic tense language, for the same reason: a bounded morphism from an irreflexive linear frame can produce a reflexive frame. However, a subtlety: the image of a *linear* frame under a bounded morphism need not be linear. So the Goldblatt-Thomason argument requires care when restricted to linear frames.

The more relevant fact is the specific result for temporal logic: the basic tense logic of all linear orders equals the basic tense logic of all strict linear orders. That is:

```
{phi | all linear (L, <=) |= phi} = {phi | all strict linear (L, <) |= phi}
```

This follows from the same unraveling argument: any linear order can be unraveled into a strict ordering while preserving tense-logical content, and conversely, any strict linear order has the same tense-logical theory as its reflexive closure.

### 4.3 The Unraveling Argument for Linear Orders

For linear orders specifically, there is a simpler argument than general unraveling. Given a strict linear order (L, <) and a counterexample to phi at some point t, we need to show phi also fails on some reflexive linear order. We can take the same underlying set L with the relation <=. The truth of any basic tense formula (using only G, H, F, P) at t is the same under < and <= -- this is because:

Wait, this is actually false! G(p) -> p is valid under <= but not under <. So the logics of *individual frames* differ. What is true is that the **logics of the frame classes** coincide.

The correct argument: given any (L, <) model where phi fails, we can construct a (<=-based) model where phi also fails, and vice versa. The technique involves modifying the valuation appropriately when switching between < and <=. This is non-trivial and relies on the specific properties of linear orders and the limited expressiveness of basic tense logic.

---

## 5. What About Until/Since?

### 5.1 Until/Since Are More Expressive

The Until and Since operators are strictly more expressive than G, H, F, P. Kamp's theorem (1968) shows that on continuous strict linear orders, Until/Since have the full expressive power of first-order monadic logic over the ordering.

This extra expressiveness changes the definability picture significantly.

### 5.2 Strict vs Reflexive Until: Different Validities

Report 11 correctly identified this: the valid formulas of Until/Since differ between reflexive and irreflexive semantics.

**Key example**: Under reflexive Until (witness s >= t), the formula:

```
psi -> (phi U psi)     (BX8: Until introduction)
```

is valid: take witness s = t. The guard [t, t) is empty, so vacuously satisfied.

Under strict Until (witness s > t), this formula is NOT valid: we need a strictly future witness, and merely having psi at the current time does not provide one.

**Another example**: Under reflexive Until, the formula:

```
(phi U psi) -> F(psi)
```

is NOT valid when the witness is s = t (then psi holds at t, but F(psi) requires a *strictly future* witness -- this is an issue only with irreflexive G). Under strict Until, this formula IS valid because the witness is already strictly future.

These differences mean that **the "same validities" result does NOT extend to the Until/Since language**. The logic of reflexive Until on linear orders and the logic of strict Until on linear orders are genuinely different.

### 5.3 Can Irreflexivity Be Characterized with Until/Since?

In a sense, yes -- indirectly. The Until operator on strict orders validates different formulas than on reflexive orders, so the *axiom system* must differ. Venema (1993) showed how to axiomatize strict Until/Since by modifying the Burgess-Xu axioms.

However, the question "can a formula in the Until/Since language define the class of irreflexive frames?" is subtle. The standard frame definability theory applies to *normal modal logics*, and Until/Since are not normal modalities (they don't distribute over implication in the standard way). The Goldblatt-Thomason theorem in its standard form does not directly apply to Until/Since.

What matters for the ProofChecker is not abstract definability but concrete axiomatizability, addressed in the next section.

### 5.4 The Interaction Between G/H and U/S Semantics

The ProofChecker faces a specific design choice: should G/H and U/S use the same reflexivity convention?

| Convention | G/H | U/S | Comment |
|-----------|-----|-----|---------|
| Fully reflexive (`until` branch) | <= | <= | Burgess/Xu standard. BX1 (G(phi)->phi) is an axiom. |
| Fully irreflexive (A2, current `irr_until`) | < | < (strict witness) | BX8 (psi -> phi U psi) fails. BX1 replaced by seriality. |
| B1 hybrid (Report 10 recommendation) | < | <= (reflexive witness) | BX8 restored. BX10 weakened to BX10'. |

The B1 hybrid is the key insight from Report 10: by decoupling the reflexivity of G/H from that of U/S, we can maintain irreflexive G/H (for philosophical fidelity) while restoring the crucial BX8 axiom (for proof-theoretic tractability).

---

## 6. The IRR Rule and Non-Standard Axiomatization

### 6.1 Gabbay's Irreflexivity Rule

Because irreflexivity cannot be captured by a modal *axiom*, Gabbay (1981) introduced a non-standard *inference rule*:

**IRR Rule**: If |- p /\ H(not p) -> phi, where p does not occur in phi, then |- phi.

Intuitively: if phi follows from the assumption that "p holds now but never held before" (which characterizes the "current time" in an irreflexive setting), and phi does not depend on the specific choice of p, then phi holds unconditionally.

The IRR rule is **sound** on irreflexive frames and serves as the proof-theoretic counterpart to the semantic condition of irreflexivity.

### 6.2 Venema's Generalization: Non-xi Rules

Venema (1993, "Derivation Rules as Anti-Axioms") generalized the IRR rule to a class of "non-xi rules" that can axiomatize frame classes defined by *negative* first-order conditions (like irreflexivity: for all x, not Rxx). His metatheorem states:

> If Lambda is a derivation system with Sahlqvist axioms, and Lambda+ extends Lambda with non-xi rules, then Lambda+ is strongly sound and complete with respect to the class of frames determined by the axioms and rules.

This provides a general completeness result for logics that include irreflexivity-like conditions, using rules rather than axioms.

### 6.3 Reynolds' Alternative: Axioms Without IRR

Reynolds (1992, "An axiomatization for until and since over the reals without the IRR rule") showed that for the specific case of Until/Since over the real numbers with strict ordering, the IRR rule can be avoided entirely. Instead, Reynolds uses an infinite axiom scheme that achieves the same effect through purely axiomatic means.

The key insight: on dense linear orders like the reals, the extra expressiveness of Until/Since provides enough machinery to encode the consequences of irreflexivity without a non-standard rule. This is specific to dense orders and does not generalize to all linear orders.

### 6.4 Does the IRR Rule Overcome the Definability Issue?

Yes, in the sense that matters. The "definability issue" (van Benthem) says: no *axiom* (formula scheme added to the logic) can characterize irreflexive frames. But the IRR *rule* (an inference rule) can. The distinction is:

- **Axiom**: phi is added as a theorem of the logic. The axiom is *valid on* the target frames.
- **Rule**: "from |- phi, infer |- psi" is added as a valid inference. The rule is *sound for* the target frames but is not itself a formula.

Van Benthem's result says we cannot find a *formula* that characterizes irreflexivity. It does NOT say we cannot find an *inference rule* that forces irreflexivity. Gabbay's IRR rule demonstrates that we can.

For the ProofChecker, this means: **van Benthem's result does NOT prevent axiomatizing the irreflexive frames.** It only prevents axiomatizing them using standard modal axioms alone. Non-standard rules (IRR) or sufficiently expressive operators (Until/Since with appropriate axioms) can overcome the limitation.

---

## 7. Frame-Completeness vs Completeness

### 7.1 The Distinction

Two notions of completeness are relevant:

**Completeness** (with respect to a class C of frames):
Every formula valid on all frames in C is provable.

```
For all phi: (for all F in C, F |= phi) implies |- phi
```

**Frame-completeness**:
The logic L is complete with respect to a *specific* class of frames C, in the strong sense that the theorems of L are *exactly* the formulas valid on C.

```
|- phi  if and only if  for all F in C, F |= phi
```

### 7.2 Van Benthem's Result Concerns Definability, Not Completeness

Van Benthem's result that irreflexivity is not modally definable is about **frame definability**: whether a class of frames can be *picked out* by modal formulas. This is related to, but distinct from, completeness.

Specifically:
- A logic can be **complete** with respect to the class of irreflexive frames even though that class is not modally **definable**.
- What "not modally definable" means is that no set of modal formulas *characterizes* the class (valid on exactly those frames and no others).
- But a logic can have theorems that are valid on the irreflexive frames -- as long as those theorems are also valid on some non-irreflexive frames.

For basic Kt: the logic is complete with respect to all frames AND complete with respect to all irreflexive frames -- because these classes have the same validities.

### 7.3 For the ProofChecker's Situation

The ProofChecker is not trying to define the class of irreflexive frames using modal formulas. It is trying to:

1. Fix a specific semantic convention (irreflexive G/H on linear orders)
2. Find an axiom system that is sound and complete with respect to this convention
3. Prove completeness formally in Lean 4

Van Benthem's result does not obstruct any of these goals. What it tells us is that the axiom system for irreflexive semantics cannot consist *solely* of standard modal axiom schemas -- it will need either:
- Non-standard rules (like IRR), or
- Additional operators (like Until/Since) that provide enough expressiveness, or
- The observation that for basic G/H, the same axiom system (Kt) works for both reflexive and irreflexive semantics

---

## 8. Implications for the ProofChecker Project

### 8.1 The Current Situation

| Branch | G/H Semantics | U/S Semantics | BX1 | BX8 | Status |
|--------|---------------|---------------|-----|-----|--------|
| `until` | Reflexive (<=) | Reflexive (<=) | G(phi)->phi (T-axiom) | psi -> phi U psi | 5 sorries from complete |
| `irr_until` | Irreflexive (<) | Strict (s > t) | Seriality | REMOVED (unsound) | Structurally blocked |
| B1 proposal | Irreflexive (<) | Reflexive (<=) | Seriality | psi -> phi U psi | Recommended by Report 10 |

### 8.2 What Van Benthem's Result Tells Us

1. **For basic G/H (without U/S)**: The "same validities" result means that any axiom system complete for all frames (with basic tense operators) is automatically complete for irreflexive frames. The T-axiom G(phi) -> phi is NOT needed for completeness with respect to irreflexive frames -- but it IS needed if we want to prove completeness with respect to *reflexive* frames specifically.

2. **For the full language with U/S**: The validities differ between reflexive and irreflexive semantics, so a single axiom system cannot be complete for both. The `until` branch (reflexive) and the B1 proposal (irreflexive G/H, reflexive U/S) genuinely need different axiom systems.

3. **The IRR rule is not needed** for the ProofChecker's purposes: the Burgess-Xu axiom system (with appropriate modifications for the semantic convention) provides a finitary axiomatization without non-standard rules. The Until/Since operators provide sufficient expressiveness to distinguish the semantic conventions through different axiom schemas (BX8 vs no BX8, BX10 vs BX10').

### 8.3 The Recommended Path (Reinforcing Reports 10-11)

**Phase 1**: Complete reflexive completeness on the `until` branch (5 sorries, estimated 28-43 hours). This is a straightforward formal verification task with no conceptual obstacles.

**Phase 2**: Adapt to irreflexive G/H using the B1 convention:
- Change G/H truth conditions from <= to <
- Replace BX1 (T-axiom G(phi)->phi) with seriality axioms
- Replace BX10 (phi U psi -> F(psi)) with BX10' (phi U psi -> psi \/ F(psi))
- Keep BX8 (psi -> phi U psi) -- sound under reflexive U/S
- Adapt the chain construction (enriched seeds for F-resolution under irreflexive G)

Van Benthem's result provides *theoretical reassurance* for this approach: the basic tense-logical infrastructure (G/H completeness) transfers freely between reflexive and irreflexive semantics. The adaptation work is concentrated in the Until/Since-specific parts of the proof.

### 8.4 Correcting Report 11's Claim

Report 11 stated: "For basic tense logic (G/H only), irreflexive and reflexive validities are identical. Completeness for one immediately gives completeness for the other."

This is **correct** for the basic tense language. The phrasing could be more precise:

> For the basic tense language (G, H, F, P without Until/Since), the set of valid formulas is the same whether we evaluate over all frames, all reflexive frames, or all irreflexive frames. Therefore, any axiom system complete for the basic tense logic Kt is simultaneously complete for the class of all frames, the class of reflexive frames, and the class of irreflexive frames -- but this tells us nothing about the Until/Since language, where the validities genuinely differ.

The caveat about Until/Since was already noted in Report 11 and is the crux of the matter for the ProofChecker.

---

## 9. Summary of Key Points

| Question | Answer |
|----------|--------|
| Is irreflexivity modally definable? | **No** (van Benthem). No set of modal formulas characterizes exactly the irreflexive frames. |
| Does this prevent axiomatizing irreflexive logics? | **No**. Non-standard rules (IRR) or expressive operators (U/S) can overcome the limitation. |
| Are Kt validities the same on reflexive and irreflexive frames? | **Yes** (for basic G/H/F/P). The logics coincide. |
| Are Until/Since validities the same? | **No**. BX8 is valid under reflexive U/S but not under strict U/S. |
| Is this a contradiction? | **No**. "Not definable" and "same validities" are compatible (Section 3). |
| Does the IRR rule help? | **Not needed** for ProofChecker. The BX axiom system with U/S is expressive enough. |
| What about linear orders? | The same-validities result holds for basic tense logic on linear orders. |
| Impact on ProofChecker strategy? | **None negative**. Van Benthem's result is compatible with and even supports the recommended approach. |

---

## References

### Primary Sources

- van Benthem, J. F. A. K. (1983). *Modal Logic and Classical Logic*. Bibliopolis, Naples. [Irreflexivity undefinability result]
- Blackburn, P., de Rijke, M., and Venema, Y. (2001). *Modal Logic*. Cambridge University Press. [Ch. 3: bisimulation and undefinability; Ch. 5: frame definability and Goldblatt-Thomason]
- Goldblatt, R., and Thomason, S. K. (1975). "Axiomatic classes in propositional modal logic." In *Algebra and Logic*, Springer. [Goldblatt-Thomason theorem]
- Venema, Y. (1993). "Derivation rules as anti-axioms in modal logic." *Journal of Symbolic Logic* 58(3):1003-1034. [Non-xi rules, IRR generalization, strict ordering axiomatization]
- Reynolds, M. (1992). "An axiomatization for until and since over the reals without the IRR rule." *Studia Logica* 51:165-193. [IRR-free axiomatization for dense orders]
- Gabbay, D. M. (1981). "An irreflexivity lemma with applications to axiomatizations of conditions on tense frames." In *Aspects of Philosophical Logic*, ed. U. Monnich, Reidel. [Original IRR rule]

### Handbook Chapters and Surveys

- Blackburn, P., and van Benthem, J. (2007). "Modal Logic: A Semantic Perspective." In *Handbook of Modal Logic*, Elsevier. [https://staff.fnwi.uva.nl/j.vanbenthem/hml-blackburnvanbenthem.pdf](https://staff.fnwi.uva.nl/j.vanbenthem/hml-blackburnvanbenthem.pdf)
- Venema, Y. (2001). "Temporal Logic." Chapter 10 in *Handbook of Philosophical Logic*, 2nd edition. [https://staff.fnwi.uva.nl/y.venema/papers/TempLog.pdf](https://staff.fnwi.uva.nl/y.venema/papers/TempLog.pdf) [Same validities result for Kt; strict ordering discussion]
- Goranko, V., and Otto, M. (2007). "Model Theory of Modal Logic." In *Handbook of Modal Logic*, Elsevier. [https://www2.mathematik.tu-darmstadt.de/~otto/papers/mlhb.pdf](https://www2.mathematik.tu-darmstadt.de/~otto/papers/mlhb.pdf)
- Stanford Encyclopedia of Philosophy. "Temporal Logic." [https://plato.stanford.edu/entries/logic-temporal/](https://plato.stanford.edu/entries/logic-temporal/)

### Project Context

- Report 10: Reflexive Until evaluation, B1 convention analysis
- Report 11: Team research synthesis, "same validities" claim, two-phase strategy
- Burgess (1982/84): Reflexive Until/Since axiom system
- Xu (1988): Completeness for reflexive Until/Since on linear orders
