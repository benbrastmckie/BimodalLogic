# Research Report: Task #486

**Task**: Add Abilities box to middle layer TikZ diagram
**Date**: 2026-01-13
**Focus**: Conduct research about what logical operators are most natural to include alongside ability modals and free choice modals, explaining how these are different, and what other operators it would be good to include.

## Summary

This research investigates the logical operators appropriate for an Abilities extension in the Logos framework, distinguishing ability modals from free choice modals and identifying additional operators that should be included.
The key finding is that ability modals and free choice modals address fundamentally different aspects of agency: ability modals concern what an agent can bring about through their capacities, while free choice modals concern the distribution of permission over alternatives.
Based on the Logos architecture and academic literature, the recommended operators for the Abilities box are: ability operators (Can, Able, Cannot), free choice operators (FP, FF), STIT operators (stit_a, dstit_a), and a joint ability operator (Can_{a,b}).

## Findings

### 1. Ability Modals vs. Free Choice Modals: Key Differences

#### Ability Modals

Ability modals express what an agent can bring about through their own capacities.
They have stronger truth conditions than pure circumstantial possibility modals:

| Aspect | Ability Modal | Circumstantial Modal |
|--------|---------------|---------------------|
| **Focus** | Agent's intrinsic capacities | External circumstances |
| **Example** | "John can lift 100kg" | "It is possible to lift 100kg" |
| **Truth conditions** | Requires agent's choice leads to outcome | Requires some accessible world with outcome |
| **Distribution over disjunction** | Does NOT generally distribute | Distributes classically |

As noted by [Kenny (1976)](https://www.semanticscholar.org/paper/Human-Abilities-and-Dynamic-Modalities-Kenny/eba3132393058e7b88c79b2044ddf0c5678838d7) and elaborated by [Santorio](https://onlinelibrary.wiley.com/doi/10.1111/nous.12546), ability entails circumstantial possibility but not vice versa.
The key semantic insight is that abilities involve a "dependence domain" where the outcome depends on the agent's choice holding fixed what the agent cannot control.

The failure of distribution over disjunction for ability modals is illustrated by this example: An agent has the ability to pick a card from a deck.
But from this, it does not follow that they have the ability to pick *this particular card* or the ability to pick *that particular card*--they cannot predict which card they will get.
This contrasts sharply with permission modals.

#### Free Choice Modals

Free choice modals concern the distribution of permission over disjunctive alternatives.
The [Free Choice Permission paradox](https://link.springer.com/article/10.1007/s11229-005-6196-z) (Kamp 1973) notes that:

- Intuitively: "You may have an apple or a pear" implies "You may have an apple" AND "You may have a pear"
- But in standard modal logic: May(A or B) is equivalent to May(A) or May(B), not the conjunction

The paradox arises because standard deontic logic treats permission as existential quantification over ideal worlds.
[Recent approaches](https://academic.oup.com/jigpal/article/31/3/574/6586013) solve this by:
1. Treating disjunction as introducing alternatives (rather than standard boolean OR)
2. Using relating semantics where permission operates over each alternative
3. Leveraging hyperintensional semantics (as in Logos) where the permitted state mereologically decomposes

**Key Distinction**: Free choice is about permission over alternatives; ability is about capacity to bring about outcomes.
An agent may be permitted to do something they cannot do (no ability), or able to do something they are not permitted to do (prohibition despite ability).

### 2. Recommended Operators for Abilities Extension

Based on the existing Logos architecture (from GLOSSARY.md and recursive-semantics.md) and academic literature, the following operators are recommended:

#### 2.1 Ability Operators

| Symbol | Name | Definition | Source |
|--------|------|------------|--------|
| `Can_a` | Specific Ability | "Agent a can bring about A" (given current circumstances) | STIT + Dependence |
| `Able_a` | Generic Ability | "Agent a has the dispositional ability to A" | Kenny (1976) |
| `Cannot_a` | Inability | "Agent a cannot bring about A" | Negation of Can_a |

**Semantic note**: Specific ability (Can_a) is circumstance-dependent; generic ability (Able_a) concerns dispositions that persist across circumstances.

#### 2.2 Free Choice Operators

| Symbol | Name | Definition | Source |
|--------|------|------------|--------|
| `FP` | Free Permission | "A is freely permitted (each disjunct is permitted)" | von Wright, Kamp |
| `FF` | Free Prohibition | "A is freely forbidden" | Dual of FP |

**Semantic note**: Free choice permission addresses the paradox by ensuring May(A or B) implies May(A) and May(B).
Logos's hyperintensional semantics provides a natural solution: the permitted state mereologically decomposes into parts verifying each disjunct.

#### 2.3 STIT Operators (Optional but Valuable)

STIT ("Sees To It That") logic, developed by Belnap and Perloff, provides a rigorous framework for agency with branching time.
From [recent work on temporal STIT](https://arxiv.org/html/2510.22175), the key operators are:

| Symbol | Name | Definition | Source |
|--------|------|------------|--------|
| `stit_a` | Agentive STIT | "Agent a sees to it that A" | Belnap & Perloff |
| `dstit_a` | Deliberative STIT | "Agent a deliberately sees to it that A" (excludes settled outcomes) | Horty |

**Semantic framework**: STIT uses choice functions C : Agent x Time -> Partition(Histories).
At each moment, an agent's choice partitions the set of histories passing through that moment into equivalence classes.
[The Dynamic Logic of Agency](https://link.springer.com/article/10.1007/s10849-009-9105-x) shows STIT can be reconstructed from more basic dynamic logic operators.

#### 2.4 Goal-Oriented and Teleological Modals

| Symbol | Name | Definition | Source |
|--------|------|------------|--------|
| `Tele` | Teleological Necessity | "Given goal G, A is necessary" | Kratzer |
| `Prio` | Priority Modal | "A is better than alternatives given priorities" | Portner |

**Note**: These operators express what is necessary/possible *given a goal*.
[Teleological modality](http://bcopley.com/wp-content/uploads/copley.teleological.modals.2010.talk_.pdf) concerns means-end reasoning: "To achieve G, you must do A."
This connects to Logos's planning and reasoning applications.

### 3. Relationship to Existing Logos Extensions

The Abilities extension fits naturally within the Logos architecture as a middle extension:

```
Explanatory Extension (modal, temporal, counterfactual)
           |
           v
    +-----------+
    | Abilities |  <-- NEW
    | Extension |
    +-----------+
           |
           v
    Agential Extension (multi-agent)
           |
           v
    Reflection Extension (metacognition)
```

**Dependencies**:
- Abilities requires the Explanatory Extension (for temporal operators and counterfactual reasoning)
- Abilities is naturally used alongside the Normative Extension (for obligation-ability interactions)
- The Agential Extension extends Abilities with agent-indexing

### 4. Operators Already in GLOSSARY.md

The GLOSSARY.md already documents these Agential Extension operators:

**Ability Operators**:
- `Can_a` - "Agent a can bring about A"
- `Able_a` - "Agent a has the dispositional ability to A"
- `Cannot_a` - "Agent a cannot bring about A"

**Free Choice Operators**:
- `FP` - "A is freely permitted"
- `FF` - "A is freely forbidden"
- `Ch` - "Choice among alternatives"

**Agential Concepts**:
- Choice function, Dependence domain, Capacity assignment
- STIT logic reference

### 5. Operators to Consider Adding

Beyond what's in GLOSSARY.md, consider:

| Symbol | Name | Rationale |
|--------|------|-----------|
| `stit_a` | Agentive STIT | Standard logic of agency; reconstructible from Can_a |
| `dstit_a` | Deliberative STIT | Distinguishes deliberate action from settled outcomes |
| `Can_{a,b}` | Joint Ability | Multi-agent ability for coordination |
| `Tele_G` | Teleological | Goal-oriented necessity for planning |

## Recommendations

### For TikZ Diagram

Add an "Abilities" box to the middle layer with these operators:

```
┌────────────────────────────────────────┐
│            Abilities                    │
│  (ability, free choice, agency)         │
│                                         │
│  Can_a    - specific ability            │
│  Able_a   - generic ability             │
│  FP       - free choice permission      │
│  stit_a   - sees to it that             │
│  Ch       - choice set                  │
└────────────────────────────────────────┘
```

### For README.md Overview

Update the ASCII diagram to include the Abilities box in the middle extensions row, positioned alongside Epistemic, Normative, and Spatial.

### Symbol Recommendations for TikZ

Use compact notation for the diagram:
- Ability: `Can_a`, `Able_a`
- Free choice: `FP`, `Ch`
- STIT: `stit_a` (optional; more specialized)

## Distinctions Clarified

### Ability Modal vs. Free Choice Modal

| Property | Ability Modal (Can_a) | Free Choice Modal (FP) |
|----------|----------------------|------------------------|
| **Domain** | Agent capacities | Permission scope |
| **Question answered** | "What can agent a bring about?" | "Which alternatives are permitted?" |
| **Distribution over OR** | Does NOT distribute | DOES distribute (the key insight) |
| **Relation to deontic** | Independent | Subset of deontic modality |
| **Frame structure** | Choice functions, dependence domains | Permission accessibility, alternatives |

### Why Both Are Needed

1. **Ability without permission**: Agent can do X but is forbidden (akrasia scenarios)
2. **Permission without ability**: Agent may do X but cannot (physical incapacity)
3. **Free choice about abilities**: May choose which ability to exercise (combines both)

## References

### Academic Sources
- [Kenny (1976)](https://www.semanticscholar.org/paper/Human-Abilities-and-Dynamic-Modalities-Kenny/eba3132393058e7b88c79b2044ddf0c5678838d7) - "Human Abilities and Dynamic Modalities" - foundational work on ability modals
- [Santorio](https://onlinelibrary.wiley.com/doi/10.1111/nous.12546) - "Ability as Dependence Modality" - relationship between ability and circumstantial modals
- [Kamp (1973)](https://link.springer.com/article/10.1007/s11229-005-6196-z) - Free choice permission paradox
- [Belnap & Perloff](https://dl.acm.org/doi/abs/10.1007/s10849-009-9119-4) - STIT logic foundations
- [STIT with Temporal and Deontic Operators](https://arxiv.org/html/2510.22175) - Recent discrete-time STIT logic
- [Dynamic Logic of Agency](https://link.springer.com/article/10.1007/s10849-009-9105-x) - Reconstruction of STIT from dynamic logic
- [Free Choice Permission and Relating Semantics](https://academic.oup.com/jigpal/article/31/3/574/6586013) - Recent semantic approaches
- [Kratzer's Modality Framework](https://web.mit.edu/fintel/fintel-2006-modality.pdf) - Modal base and ordering source approach
- [Teleological Modals](http://bcopley.com/wp-content/uploads/copley.teleological.modals.2010.talk_.pdf) - Goal-oriented modality

### Project Sources
- GLOSSARY.md - Existing operator definitions
- recursive-semantics.md - Formal semantic specifications
- 00-Introduction.tex - Current TikZ diagram

## Next Steps

1. Update the TikZ diagram in 00-Introduction.tex to add an Abilities box in the middle layer
2. Update the ASCII diagram in README.md to include Abilities alongside other middle extensions
3. Consider whether to include STIT operators explicitly or treat them as derivable from Can_a
4. Verify consistency with recursive-semantics.md Agential Extension section
