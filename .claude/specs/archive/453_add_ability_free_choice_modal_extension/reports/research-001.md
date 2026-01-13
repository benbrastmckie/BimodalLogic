# Research Report: Task #453

**Task**: Add Ability and Free Choice Modal Extension to Logos
**Date**: 2026-01-12
**Session**: sess_1768271071_5561e4
**Focus**: Semantic characterization and stub architecture for ability and free choice modals

## Executive Summary

This research investigates ability modals ("can", "able to") and free choice modals for integration into the Logos middle layer. The key findings are:

1. **Ability modals** require a distinct semantic treatment from standard circumstantial modals, involving "dependence domains" that track counterfactual agency
2. **Free choice modals** present a well-known puzzle (the Free Choice Permission paradox) with multiple competing semantic solutions
3. **Integration with Logos** should follow the existing extension stub pattern (Epistemic, Normative, Spatial) as an "Agential" or "Ability" extension
4. **Mathlib has no native modal logic support**, requiring custom implementation

---

## 1. Current Logos Architecture

### 1.1 Extension Layer Structure

Logos organizes semantics into extension layers with increasing expressive power:

```
Constitutive Foundation (hyperintensional base)
        |
        v
Explanatory Extension (modal, temporal, counterfactual, causal)
        |
   +----+----+----+
   |    |    |    |
   v    v    v    v
Epistemic  Normative  Spatial  [PROPOSED: Ability/Agential]
   |         |         |
   +---------+---------+
             |
             v
      Agential Extension (multi-agent reasoning)
             |
             v
     Reflection Extension (metacognition)
```

### 1.2 Existing Extension Stubs

Current stubs in `Theories/Logos/SubTheories/`:
- **Epistemic/** (`Epistemic.lean`) - Knowledge/belief operators K, B
- **Normative/** (`Normative.lean`) - Obligation/permission operators O, P
- **Spatial/** (`Spatial.lean`) - Location operators Here, Somewhere, Everywhere, Near
- **Foundation/** - Complete hyperintensional base with mereological state space
- **Explanatory/** - Modal/temporal/counterfactual with full syntax implementation

Each stub follows the pattern:
```lean
/-!
# Logos.{Extension} - Layer N ({Extension} Extension)

This layer extends Core TM logic with {extension} operators:
- Operator list with symbols

**Status**: Planned for future development
**Prerequisites**: {dependencies}
**Estimated Timeline**: {estimate}

See: docs/Research/layer-extensions.md Section N
-/

namespace Logos.SubTheories.{Extension}
  -- Implementation notes as comments
  -- Extension points documented
end Logos.SubTheories.{Extension}
```

---

## 2. Ability Modals: Semantic Theory

### 2.1 Distinction from Circumstantial Modals

Ability modals ("can", "able to") are related to but distinct from circumstantial modals. According to Santorio (2024, "Ability as Dependence Modality"):

- **Circumstantial modals**: Express what is possible given relevant facts about circumstances
  - Example: "Hydrangeas can grow in this region" (given soil, water, light)

- **Ability modals**: Express what an agent can bring about through their own capacities
  - Example: "Ben can hit the target" (given Ben's skill)

Key insight: Ability attributions involve a "dependence domain" - possibilities where we keep facts about the agent fixed but vary facts about other agents/circumstances.

### 2.2 Kratzer's Modal Base Framework

Standard modal semantics (Kratzer 1977, 1981, 2012) parameterizes modals by:

| Parameter | Function | Description |
|-----------|----------|-------------|
| **Modal base** f | w -> Set(Prop) | Assumptions validated by domain worlds |
| **Ordering source** g | w -> Set(Prop) | Priorities inducing ordering on domain |

For ability modals, the modal base should include:
- Facts about the agent's intrinsic capacities
- Facts about the agent's available options/choices
- Exclusion of facts about other agents' interventions

### 2.3 STIT Semantics for Ability

STIT (Sees To It That) logic provides a complementary framework:

| Operator | Reading | Semantics |
|----------|---------|-----------|
| **[a stit] p** | Agent a sees to it that p | p holds across all histories in a's choice |
| **[a cstit] p** | Chellas stit | S5-type necessity over choice cells |
| **[a dstit] p** | Deliberative stit | p in choice AND p not settled |

STIT frame structure:
- **Moments**: Temporal points in branching structure
- **Histories**: Maximal branches through moments
- **Choice function**: Partitions histories into "choice cells" per agent

### 2.4 Proposed Ability Operators for Logos

| Operator | Symbol | Reading |
|----------|--------|---------|
| **Ability** | Can_a(p) | Agent a can bring about p |
| **Inability** | Cannot_a(p) | Agent a cannot bring about p |
| **Generic ability** | Able_a(p) | Agent a has the general ability for p |
| **Specific ability** | Can_a,c(p) | Agent a can bring about p in context c |

### 2.5 Proposed Frame Extensions

The Ability frame would extend the Explanatory Extension with:

```
AbilityFrame := CoreFrame + {
  Agents : Set Agent          -- Set of agents
  Choices : Agent -> Time -> Partition(Histories)  -- Choice function
  Capacities : Agent -> Set(Prop)  -- Agent-intrinsic capacities
}
```

### 2.6 Truth Conditions for Ability

Proposed truth condition following the dependence modal approach:

> M, tau, x, sigma |- Can_a(p) iff
> there exists history h in Choices(a, x)(tau) such that M, h, x, sigma |- p
> AND for all worlds w in the dependence domain D_a(tau, x):
>   if the same choice is made, p holds in w

This captures that ability requires:
1. The agent has a choice leading to p (existential)
2. This holds robustly across the dependence domain (stability)

---

## 3. Free Choice Modals: Semantic Theory

### 3.1 The Free Choice Permission Paradox

The paradox (Kamp 1973) concerns the inference:

```
May(p or q)
-----------
May(p) and May(q)
```

This inference is intuitively valid:
- "You may take an apple or a pear" implies both "You may take an apple" and "You may take a pear"

But it is NOT valid in standard modal logic:
- diamond(p or q) does NOT entail diamond(p) and diamond(q)

### 3.2 Ross's Paradox (Related)

Ross (1941) observed that imperatives behave unexpectedly with disjunction:

- "Post this letter" does NOT entail "Post this letter or burn it"
- But in standard deontic logic: O(p) entails O(p or q)

### 3.3 Competing Solutions

| Approach | Key Idea | Proponents |
|----------|----------|------------|
| **Pragmatic** | Free choice is a conversational implicature | Grice-inspired |
| **Alternative-based** | Disjunction introduces alternatives {p,q}; modals quantify over alternatives | Kratzer & Shimoyama, Aloni, Simons |
| **Two-dimensional** | Disjunction has different 2D character; free choice is semantic | Fusco 2015 |
| **Neglect-zero** | Cognitive bias avoids empty witness sets | Aloni 2022 |
| **Hyperintensional** | Use truthmaker semantics for permission | Fine-inspired, Anglberger & Korbmacher |
| **Inquisitive** | Independence inferences from inquisitive semantics | Booth 2024 |

### 3.4 Hyperintensional Approach (Most Compatible with Logos)

Given Logos's truthmaker-based Constitutive Foundation, the hyperintensional approach to free choice permission is most natural:

> Free choice permission: P(A or B) holds iff
> there is a state s verifying (A or B) in all permitted ways,
> AND this state decomposes into parts verifying A and verifying B separately

This leverages the mereological state space already present in Logos.

### 3.5 Proposed Free Choice Operators

| Operator | Symbol | Reading |
|----------|--------|---------|
| **Free permission** | FP(p) | p is freely permitted (choice available) |
| **Free prohibition** | FF(p) | p is freely forbidden |
| **Choice set** | Ch(p,q,...) | Choice among p, q, ... |

---

## 4. Integration Architecture

### 4.1 Position in Extension Hierarchy

Two reasonable positions for ability/free choice modals:

**Option A: Agential Extension** (Recommended)
- Place ability modals in the existing Agential Extension placeholder
- Requires at least one middle extension (Epistemic, Normative, or Spatial)
- Emphasizes multi-agent reasoning

**Option B: New "Ability Extension"** (Middle layer)
- Create parallel to Epistemic/Normative/Spatial
- Independent of those extensions
- Emphasizes the modal character of ability

Given that ability modals concern agent capacities and choices, Option A (Agential Extension) is recommended.

### 4.2 Dependency Diagram

```
                    Explanatory Extension
                           |
         +-----------------+------------------+
         |                 |                  |
    Epistemic         Normative          Spatial
    (B_a, K_a)        (O, P)            (Here, Near)
         |                 |                  |
         +--------+--------+---------+--------+
                  |                  |
            Agential (ability)   [other combinations]
            (Can_a, FP)
                  |
            Reflection
            (I, I_K, I_Can)
```

### 4.3 Stub Implementation Pattern

Following the existing stubs, create:

**File**: `Theories/Logos/SubTheories/Agential/Agential.lean`

```lean
/-!
# Logos.Agential - Agential Extension

This layer extends Core TM logic with agential operators for
ability and free choice reasoning:

## Ability Operators
- Ability: Can_a (agent a can bring about)
- Inability: Cannot_a (agent a cannot bring about)
- Generic ability: Able_a (dispositional ability)
- Specific ability: Can_a,c (context-relative ability)

## Free Choice Operators
- Free permission: FP (freely permitted choice)
- Free prohibition: FF (freely forbidden)
- Choice set: Ch (choice among alternatives)

## Frame Extension

The agential frame extends the core frame with:
- **Agent set** A = set of agents
- **Choice function** C : A -> T -> Partition(H)
- **Capacity assignment** K : A -> Set(Prop)
- **Dependence relation** D : A -> World -> Set(World)

## Operators

| Operator | Notation | Reading |
|----------|----------|---------|
| **Ability** | Can_a(p) | "Agent a can bring about p" |
| **Generic** | Able_a(p) | "Agent a has the ability to p" |
| **Free Permission** | FP(p) | "p is freely permitted" |
| **Choice** | Ch(p,q) | "Choice between p and q" |

## Key Axioms (Tentative)

| Axiom | Schema | Name |
|-------|--------|------|
| Can_a(p) -> diamond(p) | Ability implies possibility | A1 |
| Can_a(p or q) -> Can_a(p) or Can_a(q) | Ability free choice | A2 |
| FP(p or q) -> FP(p) and FP(q) | Permission free choice | A3 |
| box(p) -> Can_a(p) | Necessity implies ability | A4 (debatable) |

**Status**: Planned for future development
**Prerequisites**: Explanatory Extension, at least one middle extension
**Estimated Timeline**: TBD

See: docs/Research/layer-extensions.md Section 6
-/

namespace Logos.SubTheories.Agential
  -- Agential Extension implementation to be added

  -- Extension point: Formula type will extend Core.Syntax.Formula
  -- Extension point: Semantics will use Agent set and Choice function
  -- Extension point: Frame will add dependence relation for ability modals

  -- Design Decision: Should ability require STIT-style branching time,
  -- or can it be captured with simpler possible-worlds semantics?

  -- Open Question: How do ability and deontic permission interact?
  -- Can_a(p) and P(p) vs Can_a(p) and O(not p)
end Logos.SubTheories.Agential
```

### 4.4 Documentation Updates Required

1. **layer-extensions.md**: Add Section 6 detail for Agential Extension
2. **recursive-semantics.md**: Add semantic clauses for ability/free choice operators
3. **IMPLEMENTATION_STATUS.md**: Update to reflect new stub
4. **ROADMAP.md**: Include Agential Extension timeline
5. **GLOSSARY.md**: Add terms (ability modal, free choice permission, STIT, etc.)

---

## 5. Other Potential Middle Layer Extensions

The task notes that "there are many other potential extensions that could be added to the middle layer." Beyond the existing Epistemic, Normative, Spatial, and proposed Agential:

### 5.1 Teleological Extension
- **Goal operators**: Goal_a(p), Intend_a(p)
- **Means-end reasoning**: Means(a, p) for achieving q
- Relates to planning and decision theory

### 5.2 Causal Extension (Partial - already in Explanatory)
- The causal operator is already in Explanatory Extension
- Could be extended with:
  - **Causal enablement**: Enables(p, q)
  - **Causal prevention**: Prevents(p, q)
  - **Causal contribution**: Contributes(p, q)

### 5.3 Aspectual Extension
- **Temporal aspect operators**: Progressive, Perfective
- Interaction with temporal operators H, G, P, F
- Relevant for process modeling

### 5.4 Dynamic Extension
- **Action operators**: [a]p (after action a, p holds)
- Dynamic logic style reasoning
- Could subsume some ability modal content

### 5.5 Hypothetical Extension
- **Supposition operators**: Suppose(p, q)
- **Imagination operators**: Imagine_a(p)
- Already touched on in Reflection Extension

---

## 6. Mathlib and Lean Resources

### 6.1 Mathlib Modal Logic Support

**Finding**: Mathlib has **no native modal logic support**. Search results for modal-related terms returned only:
- Category theory actions (MonoidalLeftAction, SlashAction)
- Group actions (domain actions)
- No Kripke frames, no accessibility relations, no modal operators

### 6.2 Implications for Implementation

All modal logic infrastructure must be custom-built, which is already the approach in:
- `Bimodal/Syntax/Formula.lean` - Custom Formula inductive type
- `Bimodal/Semantics/Frame.lean` - Custom frame structures
- `Bimodal/Semantics/Truth.lean` - Custom truth definitions

The Agential Extension will follow this pattern with custom types for:
- Agent indices
- Choice functions
- Dependence relations

### 6.3 Potentially Useful Mathlib Resources

- **Set theory**: For defining agent sets, choice partitions
- **Order theory**: For defining orderings on worlds (ability gradation)
- **Lattice theory**: Already used in Foundation for mereological state space

---

## 7. Recommendations

### 7.1 Immediate Actions (Stub Creation)

1. Create `Theories/Logos/SubTheories/Agential/Agential.lean` with stub following existing pattern
2. Add brief entries for potential future extensions in documentation
3. Update `layer-extensions.md` Section 6 with Agential Extension details

### 7.2 Design Decisions Required

| Decision | Options | Recommended |
|----------|---------|-------------|
| Extension name | Agential vs Ability | Agential (broader scope) |
| Position | Middle layer vs Agential layer | Agential layer (uses middle extensions) |
| Branching | Full STIT branching vs simpler | Simpler first, extend later |
| Free choice | Pragmatic vs semantic | Hyperintensional/semantic (fits Logos) |

### 7.3 Future Research Needs

1. **Detailed frame conditions** for ability operators specific to Logos task semantics
2. **Interaction axioms** between ability and existing operators (modal, temporal, counterfactual)
3. **Proof-theoretic characterization** of ability logic (axiom schemas, inference rules)
4. **Connection to causal operator** - ability may require causal reasoning

---

## 8. References

### Academic Literature

- Santorio, P. (2024). "Ability as Dependence Modality". *Nous*.
- Fusco, M. (2015). "Deontic Modality and the Semantics of Choice". *Philosophers' Imprint*.
- Kratzer, A. (1977, 1981, 2012). Works on modal semantics and conversational backgrounds.
- Kamp, H. (1973). "Free Choice Permission". *Proceedings of the Aristotelian Society*.
- Ross, A. (1941). "Imperatives and Logic". *Theoria*.
- Belnap, N., Perloff, M., & Xu, M. (2001). *Facing the Future: Agents and Choices in Our Indeterminist World*.
- Aloni, M. (2022). "Logic and Conversation: the case of free choice". *Semantics & Pragmatics*.

### Web Resources

- [Stanford Encyclopedia: Logic and Action](https://plato.stanford.edu/entries/logic-action/)
- [Stanford Encyclopedia: Deontic Logic](https://plato.stanford.edu/entries/logic-deontic/)
- [Supercover Semantics for Deontic Action Logic](https://link.springer.com/article/10.1007/s10849-018-09279-8)
- [Hyperintensional Deontic Logic](https://www.academia.edu/19065379/Hyperintensional_Deontic_Logic)

### Logos Documentation

- `Theories/Logos/docs/research/layer-extensions.md`
- `Theories/Logos/docs/research/recursive-semantics.md`
- `Theories/Logos/SubTheories/Epistemic/Epistemic.lean` (template)
- `Theories/Logos/SubTheories/Normative/Normative.lean` (template)
- `Theories/Logos/SubTheories/Spatial/Spatial.lean` (template)

---

## Next Steps

1. **Planning**: Create implementation plan specifying:
   - Exact file structure for Agential Extension
   - Documentation updates required
   - Order of stub creation

2. **Implementation**: Execute plan to create stubs and update documentation

3. **Validation**: Verify `lake build` succeeds with new stub files
