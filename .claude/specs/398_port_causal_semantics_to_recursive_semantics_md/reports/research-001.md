# Research Report: Task #398

**Task**: Port causal semantics to recursive-semantics.md
**Date**: 2026-01-12
**Focus**: Adapting sn-article.tex causal semantics to Logos 3-place task relation

## Summary

The sn-article.tex paper provides a sophisticated causal semantics based on a 2-place task relation with closeness ordering. The key challenge is adapting this to the Logos framework's 3-place task relation (with duration parameter). The existing recursive-semantics.md already contains counterfactual semantics and the core frame infrastructure needed for causal extension.

## Findings

### Source: sn-article.tex Causal Semantics (Lines 626-646)

The causal semantics uses the connective `A circleright B` ("A causes B") with a three-condition truth clause:

**(circleright) M,c |= A circleright B iff:**

1. **Background inclusion**: |A| sqsubseteq beta(x) and |B| sqsubseteq beta(y)
   - The cause's verifiers are part of background assumptions at time of cause (x)
   - The effect's verifiers are part of background assumptions at time of effect (y)

2. **Production**: For all s in beta(x)^+ and tau in `<s>_x`, there is some delta sqsubseteq* tau where delta(y) in [B]^+ and for every gamma sqsubseteq* delta, if gamma(y) in [B]^+ then gamma(x) in [A]^+
   - Every expected evolution from the augmented cause has an expected subevolution reaching the effect
   - Minimal subevolutions ensure the cause makes a "substantial contribution"

3. **Difference-making**: For every t in (beta(y)/|B|)^+ and lambda in <t>_y, if lambda(x) in [A]^+, then there is some d sqsubseteq lambda(x) where d in [A]^+ and omega(y) in [B]^+ for all omega in <d>_x
   - Non-occurrence of effect is either due to non-occurrence of cause, or presence of a preventer

### Key Concepts Requiring Definition

| Source Concept | Description | Logos Adaptation |
|----------------|-------------|------------------|
| **Closeness ordering** | s ~_preceq t means s is more likely to transition to t than to other states | Already implicit in task relation constraints |
| **Expected evolution** | Assignment tau: Z -> S where tau(n) mapsto tau(n+1) (closest states) | Adapt to use 3-place task relation with duration |
| **Subevolution** | delta sqsubseteq tau iff delta(x) sqsubseteq tau(x) for all x | Same definition applies |
| **Expected subevolution** | delta sqsubseteq* tau = (delta in E_S) and (delta sqsubseteq tau) | Same definition applies |
| **Causal context** | c = <x, y, beta> with time of cause, time of effect, background assumptions | Needs definition in Logos |
| **Background assumptions** | beta: Z -> P_S^+ assigns propositions to times | New frame component |
| **Augmented cause** | beta(x) with cause verifiers included | Derived concept |
| **Inverted effect** | P/Q = (P - Q) and not-Q | Uses existing propositional operations |

### Target: recursive-semantics.md Structure

The existing document has:

1. **Constitutive Foundation**: Bilateral propositions, exact/inexact verifiers/falsifiers
2. **Explanatory Extension**: Task relation, world-histories, counterfactual conditional

The causal semantics should be added to the **Explanatory Extension** section, as it builds on:
- The task relation (s =>_d t)
- World-histories (tau: X -> W)
- Exact/inexact verifiers ([A]^+, |A|^+)
- Propositional operations (-, /, and, or, not)

### Key Adaptation: 2-Place to 3-Place Task Relation

**Source (sn-article.tex)**: Uses 2-place `s -> t` (task from s to t)

**Target (Logos)**: Uses 3-place `s =>_d t` (task from s to t of duration d)

**Adaptation Strategy**:
1. Expected evolutions become: tau: X -> W where tau(x) =>_{y-x} tau(y) for x <= y
2. Notation <s>_x = {tau in E_S : tau(x) = s} becomes evolutions at world-state level
3. Duration implicitly tracked by (y - x) in the temporal domain D

### Existing Resources in recursive-semantics.md

The following can be reused without duplication:

| Resource | Location | Usage for Causation |
|----------|----------|---------------------|
| **Bilateral propositions** | Lines 199-215 | Verifiers/falsifiers for cause and effect |
| **World-history** | Lines 283-289 | Expected evolutions (maximal possible evolutions = world-histories) |
| **Task relation** | Lines 251-278 | Core constraint on state transitions |
| **Counterfactual** | Lines 384-398 | Counterfactual tests in condition (3) |
| **Temporal domain** | Lines 250-251 | Time of cause x, time of effect y |

### Missing Resources Requiring Addition

1. **Closeness ordering on states**: Define s ~_preceq t (not just on world-states)
2. **Expected states function**: [s] = {t in S : s mapsto t} (closest states to s)
3. **Evolutions (partial)**: Functions tau: X -> S (not just maximal/world-histories)
4. **Expected subevolution relation**: delta sqsubseteq* tau
5. **Causal context structure**: c = <x, y, beta>
6. **Background assumption function**: beta: D -> P^+ (propositions at times)
7. **Propositional inversion**: P/Q = (P - Q) and not-Q
8. **Propositional subtraction/remainder**: P - Q (already implicitly available)

### Insertion Point

The causal semantics should be added **after the Counterfactual Conditional section (line 411)** and **before the Bimodal Interaction Principles section (line 412)**. This positions it:
- After the counterfactual foundation it builds on
- Before the derived principles
- Within the Explanatory Extension as a modal/temporal operator

### Proposed Section Structure

```markdown
#### Causal Conditional (circleright)

[Frame extensions: closeness, evolutions, causal context]

[Semantic clause with three conditions]

[Intuitive reading of each condition]

[Derived notions: augmented cause, inverted effect]
```

## Recommendations

1. **Add closeness ordering as primitive**: Extend the Core Frame to include closeness preorder on states (or derive from task relation if possible)

2. **Define evolutions before world-histories**: Currently world-histories are defined directly. Define general evolutions first, then world-histories as maximal evolutions.

3. **Add background assumptions to evaluation context**: The current evaluation context is (M, tau, x, sigma, i_vec). Causal evaluation requires extending this with beta or treating it as a separate evaluation mode.

4. **Define propositional operations**: Explicitly define subtraction (P - Q) and inversion (P/Q) in the Constitutive Foundation, as they're needed for causal semantics.

5. **Preserve counterfactual integration**: The causal semantics uses counterfactual reasoning in condition (3). Ensure compatibility with existing counterfactual definition.

## References

- sn-article.tex, lines 560-700: Causal semantics source
- recursive-semantics.md: Target document structure
- Brast-McKie, "Counterfactual Worlds" (JPL): Evolution/world-history theory

## Next Steps

1. Add closeness ordering and evolution definitions to frame
2. Define causal context structure
3. Add propositional subtraction/inversion operations
4. Write the three-condition causal semantics clause
5. Add intuitive explanations for each condition
6. Verify compatibility with existing counterfactual semantics
