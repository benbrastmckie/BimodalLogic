# Research Report: Task #398

**Task**: Port causal semantics to recursive-semantics.md
**Date**: 2026-01-12
**Focus**: Adapting sn-article.tex causal semantics to Logos 3-place task relation

## Summary

The sn-article.tex paper provides a sophisticated causal semantics based on a 2-place task relation with closeness ordering. The key challenge is adapting this to the Logos framework's 3-place task relation (with duration parameter). The existing recursive-semantics.md already contains counterfactual semantics and the core frame infrastructure needed for causal extension.

## Formal Definitions from sn-article.tex

The causal semantics depends on a hierarchy of formal concepts. The following definitions are extracted from sn-article.tex and presented in dependency order (each term is defined before it is used).

### State Space Foundations (Lines 420-436)

**Modalised state space**: An ordered triple `S = <S, sqsubseteq, P>` where:
- `S` is a set of *states*
- `sqsubseteq` is the *parthood relation* forming a complete lattice over S
- `P` is a nonempty set of *possible states* where every part of a possible state is possible

**Complete lattice**: A partial order `<S, sqsubseteq>` where every subset X has a least upper bound.

**Fusion**: The least upper bound of X, written `bigsqcup X`. For two states: `s.t = bigsqcup{s, t}`.

**Compatible states**: States s and t are *compatible* iff their fusion is possible: `s o t := s.t in P`.

**World states**: `W := {s in P : t sqsubseteq s whenever t o s}` - all maximal possible states.

### Proposition Theory (Lines 441-503)

**Contents**: `C_S = {X in S : X = closure(X)}` where `closure(X) = {bigsqcup Y in S : nonempty Y subseteq X}`.

**S-proposition**: An ordered pair `<V, F>` where V and F are contents, the pair is both:
- *Exclusive*: states in V are incompatible with states in F
- *Exhaustive*: every possible state is compatible with some state in V or F

**Verifiable propositions**: `P_S^+` - propositions where there is a possible state in V.

**Exact verifiers**: `|A|^+` - the set of states that exactly verify sentence A.

**Exact falsifiers**: `|A|^-` - the set of states that exactly falsify sentence A.

**Inexact verifiers**: `[A]^+ = [|A|^+]` where `[X] = {t in S : s sqsubseteq t for some s in X}` (states including a verifier as part).

**Inexact falsifiers**: `[A]^- = [|A|^-]` (states including a falsifier as part).

### Propositional Operations (Lines 473-487)

**Inclusion**: `P sqsubseteq Q := P and Q = Q` (conjunctive-parthood - P is included in Q).

**Logical remainder**: `P - Q := bigwedge{R in P_S : R sqsubseteq P and R not sqsubseteq Q}` - the strongest proposition included in P but not in Q.

**Inversion**: `P/Q := (P - Q) and not Q` - replacing Q in P with its negation. Used to model the "non-occurrence of the effect."

### Closeness Ordering (Lines 538-591)

**Ordered state space**: An ordered triple `S = <S, sqsubseteq, preceq>` where:
- `<S, sqsubseteq>` is a complete lattice
- `preceq` is a *weak closeness relation* satisfying the constraints below

**Weak closeness**: `t preceq_s r` means "s is at least as likely to transition to t as to r."

The closeness relation must satisfy:
1. *Reflexivity*: `t preceq_s t` for all s, t
2. *Transitivity*: `t preceq_s q` whenever `t preceq_s r` and `r preceq_s q`
3. *Totality*: `t preceq_s q` or `q preceq_s t` for all s, t, q
4. *Inaccessibility*: impossible states are at furthest distance from and to all states
5. *Stability*: `s.t` is impossible whenever s is impossible

**Impossible state**: A state s where `t preceq_s s` for all t (at furthest distance from itself).

**Strict closeness**: `t prec_s q := q not preceq_s t` - s is strictly more likely to transition to t than to q.

**Closest state**: `s mapsto t := forall q in S (t preceq_s q)` - t is among the states closest to s.

**Task relation**: `s -> t := exists q in S (t prec_s q)` - there is a task from s to t (t is accessible from s).

**Accessible states**: `(s) := {t in S : s -> t}` - states to which s could transition.

**Expected states**: `[s] := {t in S : s mapsto t}` - states closest to s.

**Possible states**: `P := {s in S : s -> s}` - states accessible to themselves.

### Evolution Theory (Lines 606-614)

**Discrete evolution**: An assignment `tau: Z -> S` of integer times to states where `tau(n) -> tau(n+1)` for all n (each state is accessible from its predecessor).

**Expected evolution**: A discrete evolution where `tau(n) mapsto tau(n+1)` for all n (each successor is among the closest states).

**E_S**: The set of all expected evolutions over the ordered state space S.

**Expected evolutions at a state**: `<s>_x = {tau in E_S : tau(x) = s}` - expected evolutions occupying state s at time x.

**Subevolution**: `delta sqsubseteq tau := forall x in Z (delta(x) sqsubseteq tau(x))` - delta is a part of tau at every time.

**Expected subevolution**: `delta sqsubseteq* tau := (delta in E_S) and (delta sqsubseteq tau)` - delta is both expected and a subevolution of tau.

### Causal Context (Lines 617-621)

**Ordered model**: A tuple `M = <S, sqsubseteq, preceq, |*|>` where:
- `<S, sqsubseteq, preceq>` is an ordered state space
- `|*|: Lit -> P_S` is an interpretation assigning propositions to sentence letters

**Context**: `c = <x, y, beta>` where:
- `x in Z` is the *time of the cause*
- `y > x` is the *time of the effect*
- `beta: Z -> P_S^+` specifies the *background assumptions* at each time

**Background assumptions**: A function `beta: Z -> P_S^+` assigning verifiable propositions to times. Intuitively, what is assumed to be true at each time in the causal context.

## Causal Semantics: The Three-Condition Truth Clause (Line 626)

Using all the definitions above, the semantics for the causal connective `A circleright B` ("A causes B") is:

**(circleright) M,c |= A circleright B iff:**

### Condition (1): Background Inclusion

`|A| sqsubseteq beta(x)` and `|B| sqsubseteq beta(y)`

The cause's proposition is included in the background at the time of cause, and the effect's proposition is included in the background at the time of effect.

**Derived terms:**
- **Augmented cause**: The background `beta(x)` when condition (1) is satisfied (the cause's verifiers are part of what is assumed at x)
- **Inverted effect**: `beta(y)/|B|` - the background at the time of effect with the effect inverted (modeling non-occurrence of effect)

### Condition (2): Production

For all `s in beta(x)^+` and `tau in <s>_x`, there is some `delta sqsubseteq* tau` where `delta(y) in [B]^+` and for every `gamma sqsubseteq* delta`, if `gamma(y) in [B]^+`, then `gamma(x) in [A]^+`.

**Reading**: Every expected evolution from the augmented cause has an expected subevolution reaching the effect. Minimal subevolutions that reach the effect must include the cause, ensuring the cause makes a "substantial contribution."

### Condition (3): Difference-Making

For every `t in (beta(y)/|B|)^+` and `lambda in <t>_y`, if `lambda(x) in [A]^+`, then there is some `d sqsubseteq lambda(x)` where `d in [A]^+` and `omega(y) in [B]^+` for all `omega in <d>_x`.

**Reading**: Non-occurrence of effect is either due to non-occurrence of cause, or presence of a preventer. If the inverted effect is verified and the cause inexactly verified, there must be a sub-part of the cause whose expected evolutions all verify the effect.

## Key Concepts Summary Table

| Source Concept | Definition | Logos Adaptation |
|----------------|------------|------------------|
| **Closeness ordering** | `t preceq_s r` means s at least as likely to transition to t as to r | Already implicit in task relation constraints |
| **Expected evolution** | `tau: Z -> S` where `tau(n) mapsto tau(n+1)` (closest states) | Adapt to use 3-place task relation with duration |
| **Subevolution** | `delta sqsubseteq tau` iff `delta(x) sqsubseteq tau(x)` for all x | Same definition applies |
| **Expected subevolution** | `delta sqsubseteq* tau` = `(delta in E_S)` and `(delta sqsubseteq tau)` | Same definition applies |
| **Causal context** | `c = <x, y, beta>` with time of cause, time of effect, background assumptions | Needs definition in Logos |
| **Background assumptions** | `beta: Z -> P_S^+` assigns propositions to times | New frame component |
| **Augmented cause** | `beta(x)` with cause verifiers included | Derived concept |
| **Inverted effect** | `P/Q = (P - Q) and not Q` | Uses existing propositional operations |

## Target: recursive-semantics.md Structure

The existing document has:

1. **Constitutive Foundation**: Bilateral propositions, exact/inexact verifiers/falsifiers
2. **Explanatory Extension**: Task relation, world-histories, counterfactual conditional

The causal semantics should be added to the **Explanatory Extension** section, as it builds on:
- The task relation (s =>_d t)
- World-histories (tau: X -> W)
- Exact/inexact verifiers ([A]^+, |A|^+)
- Propositional operations (-, /, and, or, not)

## Key Adaptation: 2-Place to 3-Place Task Relation

**Source (sn-article.tex)**: Uses 2-place `s -> t` (task from s to t)

**Target (Logos)**: Uses 3-place `s =>_d t` (task from s to t of duration d)

**Adaptation Strategy**:
1. Expected evolutions become: `tau: X -> W` where `tau(x) =>_{y-x} tau(y)` for `x <= y`
2. Notation `<s>_x = {tau in E_S : tau(x) = s}` becomes evolutions at world-state level
3. Duration implicitly tracked by `(y - x)` in the temporal domain D

## Existing Resources in recursive-semantics.md

The following can be reused without duplication:

| Resource | Location | Usage for Causation |
|----------|----------|---------------------|
| **Bilateral propositions** | Lines 199-215 | Verifiers/falsifiers for cause and effect |
| **World-history** | Lines 283-289 | Expected evolutions (maximal possible evolutions = world-histories) |
| **Task relation** | Lines 251-278 | Core constraint on state transitions |
| **Counterfactual** | Lines 384-398 | Counterfactual tests in condition (3) |
| **Temporal domain** | Lines 250-251 | Time of cause x, time of effect y |

## Missing Resources Requiring Addition

1. **Closeness ordering on states**: Define `s preceq t` (not just on world-states)
2. **Expected states function**: `[s] = {t in S : s mapsto t}` (closest states to s)
3. **Evolutions (partial)**: Functions `tau: X -> S` (not just maximal/world-histories)
4. **Expected subevolution relation**: `delta sqsubseteq* tau`
5. **Causal context structure**: `c = <x, y, beta>`
6. **Background assumption function**: `beta: D -> P^+` (propositions at times)
7. **Propositional inversion**: `P/Q = (P - Q) and not Q`
8. **Propositional subtraction/remainder**: `P - Q` (already implicitly available)

## Insertion Point

The causal semantics should be added **after the Counterfactual Conditional section (line 411)** and **before the Bimodal Interaction Principles section (line 412)**. This positions it:
- After the counterfactual foundation it builds on
- Before the derived principles
- Within the Explanatory Extension as a modal/temporal operator

## Proposed Section Structure

```markdown
#### Causal Conditional (circleright)

##### Frame Extensions
[Closeness ordering, expected states, evolutions, expected subevolutions]

##### Causal Context
[Context structure: time of cause, time of effect, background assumptions]

##### Semantic Clause
[Three conditions with full formal definitions]

##### Intuitive Readings
[Plain-language explanation of each condition]

##### Derived Notions
[Augmented cause, inverted effect]
```

## Recommendations

1. **Add closeness ordering as primitive**: Extend the Core Frame to include closeness preorder on states (or derive from task relation if possible)

2. **Define evolutions before world-histories**: Currently world-histories are defined directly. Define general evolutions first, then world-histories as maximal evolutions.

3. **Add background assumptions to evaluation context**: The current evaluation context is (M, tau, x, sigma, i_vec). Causal evaluation requires extending this with beta or treating it as a separate evaluation mode.

4. **Define propositional operations**: Explicitly define subtraction (P - Q) and inversion (P/Q) in the Constitutive Foundation, as they're needed for causal semantics.

5. **Preserve counterfactual integration**: The causal semantics uses counterfactual reasoning in condition (3). Ensure compatibility with existing counterfactual definition.

## References

- sn-article.tex, lines 420-645: Formal definitions for causal semantics
- recursive-semantics.md: Target document structure
- Brast-McKie, "Counterfactual Worlds" (JPL): Evolution/world-history theory

## Next Steps

1. Add closeness ordering and evolution definitions to frame
2. Define causal context structure
3. Add propositional subtraction/inversion operations
4. Write the three-condition causal semantics clause
5. Add intuitive explanations for each condition
6. Verify compatibility with existing counterfactual semantics
