# Research Report: Tarski-Lindenbaum Construction for Temporal Logic with Durations -- Algebraic Approach

**Task**: 962 - Algebraic Structure of Sign-Free Task Frame
**Started**: 2026-03-14T12:00:00Z
**Completed**: 2026-03-14T14:30:00Z
**Effort**: High
**Dependencies**: Task 700 (Algebraic Representation), research_sign_elimination
**Sources/Inputs**: Codebase (Algebraic/ module, TaskFrame.lean, CanonicalFrame.lean, WorldHistory.lean, Axioms.lean), prior research (research_sign_elimination/reports/research-001.md), web search (tense algebras, Jonsson-Tarski BAOs, Galois connections), mathematical knowledge (Stone duality, modal algebra, tense logic)
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- The Lindenbaum algebra L is a Boolean algebra (already implemented sorry-free in `BooleanStructure.lean`). The operators G* and H* are interior operators on L (already implemented in `InteriorOperators.lean`). This gives L the structure of a **tense algebra** (Boolean algebra with operators, in the Jonsson-Tarski sense).
- The dual operators F* = neg o G* o neg and P* = neg o H* o neg are **conjugate** in the Jonsson-Tarski sense: `a inf F*(b) = bot iff P*(a) inf b = bot`. This conjugacy is the algebraic encoding of the converse axiom `temp_a: phi -> G(P phi)`.
- The canonical relation `CanonicalR(M, M') = GContent(M) subseteq M'` on ultrafilters arises from the **relational lifting** of G*: given ultrafilter U, the set `G*^{-1}(U) = {a in L : G*(a) in U}` is a **filter** (not necessarily ultra), and `CanonicalR(U, V) iff G*^{-1}(U) subseteq V`.
- Duration group actions on UF(L) can be formulated sign-free using the **orbit groupoid** construction, but full compositionality for non-functional relations requires either (a) restricting to non-negative durations only, or (b) requiring the relation to be functional (genuine group action).
- **Shift-closure is automatic**: if a history tau respects_task, then the shifted history tau_Delta also respects_task because `(t + Delta) - (s + Delta) = t - s`. No sign-case reasoning is needed.
- The recommended algebraic formulation for Lean 4 uses restricted compositionality plus a converse mixin, matching the findings of the prior sign-elimination research.

## Context & Scope

### Research Questions

This report addresses seven interrelated questions about extending the Tarski-Lindenbaum construction to temporal logic with durations, focusing on algebraic methods to eliminate sign-case reasoning.

### Existing Codebase State

The `Theories/Bimodal/Metalogic/Algebraic/` module already implements:
- `LindenbaumQuotient.lean`: Quotient L = Formula / ProvEquiv (sorry-free)
- `BooleanStructure.lean`: BooleanAlgebra instance on L (sorry-free)
- `InteriorOperators.lean`: G*, H*, Box* as InteriorOp on L (sorry-free)
- `UltrafilterMCS.lean`: Bijection MCS <-> Ultrafilter L (sorry-free)
- `AlgebraicRepresentation.lean`: Consistency <-> Satisfiability (sorry-free)

The canonical frame (`CanonicalFrame.lean`) defines:
- `CanonicalR M M' := GContent M subseteq M'` (future accessibility)
- `CanonicalR_past M M' := HContent M subseteq M'` (past accessibility)

### What Is Missing

The existing algebraic module does NOT yet connect:
1. The interior operators G*, H* to the canonical relations CanonicalR, CanonicalR_past
2. The conjugacy between F* and P* (the Jonsson-Tarski tense structure)
3. Duration-parameterized task relations to the algebraic operators
4. The adjunction/Galois connection between the "G-filter" construction and ultrafilter extension

## Findings

### 1. Algebraic Structure of the Canonical Frame: Tense Algebras

**Definition (Tense Algebra).** A *tense algebra* is a tuple (B, F, P) where:
- B is a Boolean algebra
- F, P : B -> B are unary operators (existential/possibility modalities)
- F and P are *conjugate* in the Jonsson-Tarski sense:
  `a inf F(b) = bot  iff  P(a) inf b = bot`     (Conjugacy)

The *dual necessity operators* are G = neg o F o neg and H = neg o P o neg.

**Proposition.** The Lindenbaum algebra L with G_quot and H_quot (from `InteriorOperators.lean`) is a tense algebra (with F = neg o G o neg and P = neg o H o neg being the diamond/possibility operators).

*Proof sketch.* We need to verify the conjugacy condition. Using the definitions F = neg o G o neg and P = neg o H o neg, and the fact that L is a Boolean algebra:

```
a inf F(b) = bot
iff  a inf (neg (G (neg b))) = bot           (definition of F)
iff  a le G(neg b)                            (Boolean: a inf c^c = bot iff a le c)  (*)
iff  G(neg b) le neg a -> a le G(neg b)       (just restating)
```

The key question is whether `a le G(neg b)` is equivalent to `P(a) inf b = bot`.

```
P(a) inf b = bot
iff  (neg (H (neg a))) inf b = bot           (definition of P)
iff  b le H(neg a)                            (Boolean complement duality)
```

So the conjugacy condition reduces to:
```
a le G(neg b)  iff  b le H(neg a)
```

or equivalently (substituting c = neg b, d = neg a):
```
neg d le G(c)  iff  neg c le H(d)
```

By Boolean duality (neg d le G(c) iff neg G(c) le d iff F(neg c) le d):
```
F(neg c) le d  iff  P(neg d) le c
```

This is exactly the **converse axiom** `temp_a` in algebraic form. The axiom `temp_a: phi -> G(P phi)` states that `[phi] le G*(P*([phi]))` in the Lindenbaum algebra, which gives:
```
[phi] le G*([P phi]) = G*(neg(H*(neg [phi])))
```

In the quotient algebra, this becomes `a le G(neg(H(neg a)))` for all a, which gives half of the Galois connection. The other half follows from the dual axiom (derivable via temporal duality): `phi -> H(F phi)`, giving `a le H(neg(G(neg a)))`.

Together, these two axioms establish the conjugacy of F and P. QED (sketch).

**Key equations for G*, H* corresponding to frame axioms:**

| Axiom | Name | Algebraic Equation |
|-------|------|-------------------|
| `G phi -> phi` | temp_t_future (reflexivity) | `G*(a) le a` (deflationary) |
| `H phi -> phi` | temp_t_past (reflexivity) | `H*(a) le a` (deflationary) |
| `G phi -> G(G phi)` | temp_4 (transitivity) | `G*(a) le G*(G*(a))` (combined with T: idempotent) |
| `phi -> G(P phi)` | temp_a (converse) | `a le G*(neg(H*(neg a)))` (unit of adjunction) |
| `G(phi -> psi) -> (G phi -> G psi)` | temp_k_dist | G* preserves finite meets |
| `phi -> H(F phi)` | derived (converse dual) | `a le H*(neg(G*(neg a)))` (counit of adjunction) |

### 2. Natural Transformations: The G-Preimage as a Filter Map

**Definition.** For an ultrafilter U on L, define:
```
G_inv(U) = {a in L : G*(a) in U}
```

**Proposition.** G_inv(U) is a proper filter on L (not necessarily an ultrafilter).

*Proof.*
- **Contains top**: G*(top) = top (G preserves top, since G(True) <-> True). Since U is an ultrafilter, top in U, so top in G_inv(U).
- **Upward closed**: If a in G_inv(U) and a le b, then G*(a) in U. By monotonicity of G*, G*(a) le G*(b), so by upward closure of U, G*(b) in U, hence b in G_inv(U).
- **Closed under meets**: If a, b in G_inv(U), then G*(a) and G*(b) in U. Since G* preserves meets (from temp_k_dist + temporal necessitation): G*(a inf b) = G*(a) inf G*(b). Since U is closed under meets, G*(a) inf G*(b) in U, so G*(a inf b) in U, hence a inf b in G_inv(U).
- **Proper**: bot not in G_inv(U) since G*(bot) le bot (by deflationary property) and bot not in U. Actually, we need: G*(bot) = bot. This follows from G being a normal operator: G*(bot) le bot by deflationary property (T-axiom), and bot le G*(bot) by monotonicity from bot le bot (vacuous). So G*(bot) = bot, and bot not in U, so bot not in G_inv(U). QED.

**Proposition.** `CanonicalR(U, V) iff G_inv(U) subseteq V` (where we identify MCSs with ultrafilters via the bijection from `UltrafilterMCS.lean`).

*Proof.* Under the bijection, M = ultrafilterToSet(U) and M' = ultrafilterToSet(V).
- CanonicalR(M, M') = GContent(M) subseteq M'
- GContent(M) = {phi : G phi in M}
- In terms of quotients: [phi] in G_inv(U) iff G*([phi]) = [G phi] in U iff G phi in M.
- And [phi] in V iff phi in M'.
- So GContent(M) subseteq M' iff G_inv(U) subseteq V (modulo the quotient identification). QED.

**The map G_inv thus lifts to**: G_inv : UF(L) -> Filt(L), and the canonical relation is the composition:
```
CanonicalR(U, V)  iff  G_inv(U) subseteq V  iff  V extends G_inv(U)
```

### 3. The Adjunction F* adj H* (via Conjugacy)

The classical result from tense logic and Boolean algebras with operators (see Jonsson-Tarski 1951, Goldblatt 1992) is:

**Theorem (Conjugacy = Relational Converse).** In a tense algebra (B, F, P), the conjugacy condition
```
a inf F(b) = bot  iff  P(a) inf b = bot
```
is equivalent, under Stone duality, to the frame condition that the relation R_F (induced by F) and the relation R_P (induced by P) are converses of each other: R_F = R_P^{-1}.

In the ProofChecker setting:
- R_F = CanonicalR (defined by GContent)
- R_P = CanonicalR_past (defined by HContent)
- The converse property CanonicalR(M, M') iff CanonicalR_past(M', M)

This converse property is exactly what `temp_a` (and its dual) ensures at the algebraic level.

**The G* / H* relationship is NOT an adjunction in the order-theoretic sense** (i.e., it is NOT the case that G*(a) le b iff a le H*(b)). This would give:
```
a le G*(b)  iff  H*(a) le b    -- FALSE in general
```

This fails because G* and H* are BOTH deflationary (G*(a) le a AND H*(a) le a), so they go in the same direction. In a Heyting algebra, an adjunction a le G(b) iff H(a) le b would make G inflationary and H deflationary (or vice versa), which is not the case here.

Instead, the correct relationship is the **conjugacy** between their duals F* and P*:
```
a inf F*(b) = bot  iff  P*(a) inf b = bot
```

This can be equivalently written as:
```
F*(b) le neg a  iff  b le neg P*(a)   -- i.e., F*(b) le c iff b le H*(c)
```
where we use the Boolean algebra structure to negate. So the adjunction is:
```
F* left-adjoint-to H*    (i.e., F*(b) le c iff b le H*(c))
```
and dually:
```
P* left-adjoint-to G*    (i.e., P*(a) le c iff a le G*(c))
```

**Proposition.** In the Lindenbaum algebra of TM logic, we have:
- P* dashv G* (P* is left adjoint to G*): `P*(a) le b iff a le G*(b)`
- F* dashv H* (F* is left adjoint to H*): `F*(a) le b iff a le H*(b)`

*Proof sketch.* From temp_a: `phi -> G(P phi)`, we get `[phi] le G*(P*([phi]))` for all [phi]. Setting a = [phi], this gives `a le G*(P*(a))`, which is the unit of the adjunction P* dashv G*. The counit P*(G*(a)) le a follows from the composition of T-axioms: P*(G*(a)) = neg(H*(neg(G*(a)))) le neg(neg(G*(a))) = G*(a) le a (using H* deflationary, then G* deflationary).

For F* dashv H*: the unit is `a le H*(F*(a))` which follows from the dual of temp_a (derivable: `phi -> H(F phi)`), and the counit follows by symmetry. QED (sketch).

**Important caveat**: These adjunctions hold in the quotient algebra but use the Boolean complement in an essential way. They are NOT Galois connections in the Heyting algebra sense; they are specific to the Boolean (classical) setting.

### 4. Duration as a Group Action on the Algebra

The user asks about extending from a single G* to a family {G*_d : d in D} parameterized by durations. In the current TM logic, G is NOT parameterized by duration -- there is a single G ("always in the future") operator, not "at duration d in the future".

However, at the semantic level, the duration structure exists:
- The task relation `task_rel : W -> D -> W -> Prop` is parameterized by d in D
- The canonical relation CanonicalR does NOT depend on d (it is duration-independent, as found in the prior research)

This means the algebraic operators G* and H* on L already capture the duration-independent structure. The duration parameterization appears at the FRAME level (Stone dual), not the ALGEBRA level.

**The group action on UF(L).**

Define, for each d in D:
```
sigma_d(U) = {V in UF(L) : CanonicalR_d(U, V)}
```
where CanonicalR_d is the task relation at duration d.

Due to **duration independence** (found in prior research, Section 4 property SH4):
```
CanonicalR_d(U, V) for d > 0  iff  CanonicalR(U, V)    -- same for all positive d
CanonicalR_0(U, V)            iff  U = V                -- identity at d = 0
CanonicalR_d(U, V) for d < 0  iff  CanonicalR(V, U)    -- converse for negative d
```

So the "group action" on UF(L) is:
```
sigma_d = { (U, V) : CanonicalR(U, V) }     for d > 0
sigma_0 = { (U, U) : U in UF(L) }           identity
sigma_d = { (U, V) : CanonicalR(V, U) }     for d < 0
```

This is NOT a genuine group action (sigma is a relation, not a function, and the composition sigma_d o sigma_e = sigma_{d+e} fails for mixed signs as shown in the prior research). It IS a **relational monoid action** of the positive cone D+ = {d in D : d ge 0}, with the negative cone obtained by converse.

### 5. Shift-Closure: Automatic from Definitions

**Proposition.** If tau : D -> UF(L) is a history respecting task relations (i.e., CanonicalR_d(tau(s), tau(t)) whenever s le t and d = t - s), then the shifted history tau_Delta(t) := tau(t + Delta) also respects task relations.

*Proof.* For s le t in the shifted domain, we need CanonicalR_{t-s}(tau_Delta(s), tau_Delta(t)):
```
CanonicalR_{t-s}(tau(s + Delta), tau(t + Delta))
```
Since s le t implies s + Delta le t + Delta, and (t + Delta) - (s + Delta) = t - s, this follows immediately from tau's respects_task property applied to (s + Delta) and (t + Delta). QED.

**This is already implemented** in `WorldHistory.lean` as `time_shift` (lines 236-258). The proof is clean and sign-free because:
1. The duration `(t + Delta) - (s + Delta)` simplifies to `t - s` by group algebra
2. The order `s + Delta le t + Delta` follows from `s le t` and order-compatibility
3. No sign-case reasoning is needed

**Key insight**: Shift-closure is a TRIVIAL consequence of the group structure of D. It does not depend on the specific form of task_rel, only on the fact that `respects_task` uses the difference `t - s` as the duration parameter.

### 6. The Construction Without Sign Cases: The Orbit Groupoid

**Definition (Orbit Groupoid).** Given a set W and a preorder R on W, define the groupoid Orbit(W, R) as follows:
- Objects: elements of W
- Morphisms from w to u:
  - A morphism exists iff R(w, u) or R(u, w) or w = u
  - Composition: R is transitive, and converse composes with converse
- The equivalence relation: w ~ u iff R(w, u) and R(u, w)

For the canonical model with CanonicalR (which is a preorder, hence reflexive and transitive), this gives a groupoid where:
- R(w, u) gives a "positive morphism" from w to u
- R(u, w) gives a "negative morphism" from w to u (or equivalently a positive morphism from u to w)
- Identity: R(w, w) (from reflexivity)

**The sign-free task relation** via the groupoid is:
```
task_rel(w, d, u) :=
  there exists a morphism from w to u in Orbit(W, R)
  AND the "direction" of the morphism matches the sign of d
```

But this is just a reformulation of the sign-based definition, not an elimination of sign cases. The signs are encoded in the morphism direction.

**True sign-free formulation** (the user's suggestion item 6):

Define an equivalence relation on W x D:
```
(w, d) ~ (u, e)  iff  task_rel(w, e - d, u)
```

If task_rel satisfies nullity and compositionality, this is indeed an equivalence relation:
- Reflexive: (w, d) ~ (w, d) iff task_rel(w, 0, w) (nullity)
- Symmetric: (w, d) ~ (u, e) iff task_rel(w, e-d, u) iff task_rel(u, d-e, w) (converse)
- Transitive: (w, d) ~ (u, e) and (u, e) ~ (v, f) gives task_rel(w, e-d, u) and task_rel(u, f-e, v), hence task_rel(w, f-d, v) (compositionality), so (w, d) ~ (v, f).

The quotient (W x D) / ~ is a **translation groupoid**: the group D acts on it by translation on the second component, `g . [(w, d)] = [(w, d - g)]`, and the task relation is recovered as:
```
task_rel(w, d, u)  iff  [(w, 0)] ~ [(u, d)]  iff  [(w, 0)] = [(u, d)] in the quotient
```

**This eliminates sign cases entirely** at the cost of working in the quotient space. The translation groupoid formulation is elegant but requires:
1. Full compositionality (which fails for non-functional relations, as shown in prior research)
2. The converse property (which we have from temp_a)
3. Nullity (which we have)

**For the canonical model**, where full compositionality fails due to non-functionality, this groupoid construction cannot be directly applied. The orbit groupoid with restricted (non-negative) compositionality gives a CATEGORY (not a groupoid) -- morphisms compose only in the "forward" direction.

### 7. Concrete Algebraic Formulation for Lean 4

Based on the analysis, here is the recommended Lean 4 formalization:

**Level 1: The Tense Algebra (extending existing Algebraic/ module)**

```lean
/-- A tense algebra: Boolean algebra with conjugate pair (F, P). -/
structure TenseAlgebra (alpha : Type*) extends BooleanAlgebra alpha where
  /-- Future possibility operator -/
  F_op : alpha -> alpha
  /-- Past possibility operator -/
  P_op : alpha -> alpha
  /-- F preserves joins (additive/normal) -/
  F_sup : forall a b, F_op (a sup b) = F_op a sup F_op b
  F_bot : F_op bot = bot
  /-- P preserves joins (additive/normal) -/
  P_sup : forall a b, P_op (a sup b) = P_op a sup P_op b
  P_bot : P_op bot = bot
  /-- Conjugacy: a inf F(b) = bot iff P(a) inf b = bot -/
  conjugacy : forall a b, a inf F_op b = bot <-> P_op a inf b = bot
```

The derived necessity operators:
```lean
def G_op (a : alpha) : alpha := compl (F_op (compl a))
def H_op (a : alpha) : alpha := compl (P_op (compl a))
```

From conjugacy, the adjunctions P_op dashv G_op and F_op dashv H_op follow.

**Level 2: The Canonical Frame (extending existing Algebraic module)**

```lean
/-- Canonical relation from an interior operator on a Boolean algebra. -/
def canonicalRelFromInterior [BooleanAlgebra L] (G : InteriorOp L)
    (U V : Ultrafilter L) : Prop :=
  forall a, G.toFun a in U.carrier -> a in V.carrier
```

This connects G_interior and H_interior to CanonicalR and CanonicalR_past.

**Level 3: The Task Frame (restricted compositionality)**

```lean
/-- TaskFrame with restricted compositionality (recommended). -/
structure TaskFrame' (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  forward_compositionality : forall w u v x y,
    0 le x -> 0 le y ->
    task_rel w x u -> task_rel u y v -> task_rel w (x + y) v

/-- Optional converse mixin. -/
class HasConverse {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (F : TaskFrame' D) where
  converse : forall w u d, F.task_rel w d u <-> F.task_rel u (-d) w
```

**Mathlib structures involved:**
- `BooleanAlgebra` (Mathlib.Order.BooleanAlgebra) -- already used
- `ClosureOperator` (Mathlib.Order.ClosureOperator) -- dual of InteriorOp
- `GaloisConnection` (Mathlib.Order.GaloisConnection) -- for F dashv H
- `Rel.GaloisConnection` (Mathlib.Order.Rel.GaloisConnection) -- for relational version
- `AddAction` / `VAdd` (Mathlib.Algebra.Group.Action.Defs) -- for genuine group actions
- `Ultrafilter` (Mathlib.Order.Filter.Ultrafilter) -- Mathlib's ultrafilter (different from project's custom)

**Note on Mathlib's Ultrafilter vs Project's**: The project defines its own `Ultrafilter` in `UltrafilterMCS.lean` as a structure with carrier set + axioms. Mathlib's `Ultrafilter` is a subtype of `Filter`. The two are isomorphic but not identical. Future work could align them using Mathlib's `Ultrafilter.map` for the group action.

**There is NO Mathlib notion of "relational group action"** or "group action on a relation". The closest concepts are:
- `MulAction G X` for genuine (functional) group actions
- `Rel alpha beta` with relational composition `Rel.comp`
- The concept would need to be defined fresh in the project

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | Medium | The algebraic formulation is D-agnostic; works regardless of how D is constructed |
| Product Domain Temporal Trivialization | Low | Not relevant to algebraic structure |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Algebraic Verification Path | PAUSED | This research directly advances it; tense algebra + conjugacy provide the missing temporal structure |
| D Construction from Canonical Timeline | ACTIVE | The algebraic formulation is compatible: D emerges from syntax, then tense algebra structure is instantiated |
| Indexed MCS Family Approach | ACTIVE | The G-preimage filter construction (Finding 2) gives the algebraic underpinning of FMCS coherence conditions |
| Representation-First Architecture | CONCLUDED | The algebraic representation theorem (already sorry-free) provides the foundation for this extension |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Tense algebra (BAO with conjugate pair) | Section 1 | No | new_file |
| Jonsson-Tarski conjugacy condition | Section 1 | No | new_file |
| G-preimage filter construction | Section 2 | No | extension |
| F dashv H adjunction in Boolean algebras | Section 3 | Partial (InteriorOperators.lean) | extension |
| Duration independence in canonical model | Section 4 | Partial (prior research) | extension |
| Orbit groupoid construction | Section 6 | No | new_file |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `tense-algebras.md` | `lattice-theory/` | Tense algebras, conjugacy, adjunctions F/H/G/P | Medium | No |
| `canonical-frame-algebraic.md` | `algebra/` | G-preimage, ultrafilter-filter maps, canonical relation | Medium | No |

**Rationale**: These concepts are specialized to the algebraic verification path (currently PAUSED). If the strategy becomes ACTIVE, context files would accelerate development.

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| Algebraic/README.md | Future Extension section | Summary of tense algebra structure, conjugacy, adjunctions | Low | No |

### Summary

- **New files needed**: 0 (concepts are not yet needed by active strategies)
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 0

## Decisions

1. **The G*/H* relationship is conjugacy, not order-theoretic adjunction.** The adjunction is between the diamond operators: F* dashv H* and P* dashv G*. This uses Boolean negation essentially.

2. **The canonical relation arises from the G-preimage filter.** CanonicalR(U, V) = G_inv(U) subseteq V, where G_inv maps ultrafilters to filters.

3. **Full compositionality requires functional relations.** The orbit groupoid construction eliminates sign cases but requires full compositionality, which fails for non-functional relations (the canonical model's CanonicalR is not functional). Therefore, the restricted compositionality formulation is correct.

4. **Shift-closure is trivially automatic.** It follows from (t+Delta)-(s+Delta) = t-s and requires no sign reasoning or algebraic structure beyond the additive group.

5. **The tense algebra formulation is the right abstraction level.** It captures the temporal axioms algebraically (conjugacy from temp_a, interior from T+4, normality from K-distribution) without committing to a specific duration type D.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Mathlib lookup tools were unavailable | Used web search + mathematical knowledge; recommendations may not perfectly align with current Mathlib API |
| The tense algebra approach is on the PAUSED strategy | Findings are documented for when the strategy becomes ACTIVE |
| The orbit groupoid requires full compositionality | Clearly documented as a limitation; restricted compositionality recommended instead |
| Custom Ultrafilter type vs Mathlib Ultrafilter | Identified as future alignment opportunity; not blocking |

## Appendix

### A. Detailed Proof: Conjugacy from temp_a

The axiom `temp_a: phi -> G(P phi)` gives, in the Lindenbaum algebra:
```
[phi] le G_quot(P_quot([phi]))
```
where P_quot = neg_quot o H_quot o neg_quot (past possibility).

Setting a = [phi] and b = [psi], we need to show:
```
a inf F_quot(b) = bot  iff  P_quot(a) inf b = bot
```

Forward direction (a inf F(b) = bot implies P(a) inf b = bot):
- a inf F(b) = bot means a le neg(F(b)) = G(neg b) = G_quot(neg_quot(b))
- From temp_a: a le G(P(a)), so P(a) le ... [requires careful derivation]
- Actually, this requires the full derivation using the proof system's axioms.

The key derived theorem needed is the **tense converse theorem**:
```
Derives (phi.and (psi.some_future)) bot  iff  Derives (phi.sometime_past.and psi) bot
```
which is the syntactic form of conjugacy.

### B. Relationship to Prior Sign-Elimination Research

The prior research (`research_sign_elimination/reports/research-001.md`) established:
1. Full compositionality requires functional relations (Finding, Section 9)
2. Restricted compositionality is the correct formulation (Recommendation 1)
3. The converse property is an optional mixin (Recommendation 2)
4. Duration independence holds in the canonical model (Finding, Section 7)
5. The current d < 0 => False approach is sound (Recommendation 5)

This report extends those findings with:
1. The algebraic underpinning via tense algebras and Jonsson-Tarski conjugacy
2. The precise adjunction structure F* dashv H* and P* dashv G*
3. The G-preimage filter construction connecting algebra to canonical frame
4. The orbit groupoid as the "ideal" sign-free formulation (with its limitations)
5. Concrete Lean 4 structures for the tense algebra approach

### C. Search Queries Used

**Codebase exploration:**
- Glob: `Theories/**/*.lean`
- Grep: `task_rel`, `CanonicalR`, `Lindenbaum`, `ultrafilter`, `BooleanAlgebra`, `InteriorOp`, `G_quot`, `H_quot`, `temp_a`, `temp_t_future`, `converse`, `sign`
- Read: TaskFrame.lean, BooleanStructure.lean, InteriorOperators.lean, UltrafilterMCS.lean, AlgebraicRepresentation.lean, LindenbaumQuotient.lean, WorldHistory.lean, CanonicalFrame.lean, Axioms.lean, ROAD_MAP.md, prior research report

**Mathlib lookup (failed due to network):**
- lean_leansearch: "Boolean algebra with interior operator modal algebra"
- lean_loogle: "BooleanAlgebra ?a -> OrderDual"
- lean_leanfinder: "group action on set of ultrafilters of a Boolean algebra"
- lean_local_search: "ClosureOperator", "MulAction", "GaloisConnection"

**Web search:**
- "tense algebra Boolean algebra operators temporal logic Galois connection G H adjoint"
- "Mathlib ClosureOperator GaloisConnection group action ultrafilter Lean 4"
- "tense algebra adjoint F H P G modal operators Boolean algebra conjugate Jonsson Tarski"
- "groupoid of ultrafilters tense logic canonical model relational group action sign-free formulation"
- "tense algebra conjugate pair definition F P Boolean algebra meet zero condition algebraic semantics"

**Web fetch (failed due to 403):**
- nLab temporal logic page
- arXiv:2308.08664 (tense operators on Boolean algebras)

### D. Key References

- Jonsson, B. and Tarski, A. (1951, 1952). "Boolean Algebras with Operators." American Journal of Mathematics. The foundational paper on BAOs and conjugacy.
- Goldblatt, R. (1992). "Logics of Time and Computation." CSLI Lecture Notes. Standard reference for tense logic and canonical model constructions.
- Blackburn, P., de Rijke, M., and Venema, Y. (2001). "Modal Logic." Cambridge University Press, Chapter 5. Algebraic semantics for modal logic.
- Von Karger, B. "Temporal Algebra." Mathematical Structures in Computer Science. Derives temporal logic axioms from Galois connection postulates.
- [arXiv:2308.08664](https://arxiv.org/html/2308.08664) - "On the structure of modal and tense operators on a Boolean algebra"
- [Modes of Adjointness](https://link.springer.com/article/10.1007/s10992-012-9266-y) - Adjunctions in modal logic
- [Mathlib Rel.GaloisConnection](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Order/Rel/GaloisConnection.html) - Relational Galois connections in Mathlib
- [nLab: temporal logic](https://ncatlab.org/nlab/show/temporal+logic) - Adjunctions F dashv H, P dashv G
