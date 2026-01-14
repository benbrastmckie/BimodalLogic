# Research Report: Task #421

**Task**: Look up formal term definitions and revise research report
**Date**: 2026-01-12
**Focus**: Extracting formal definitions from sn-article.tex for terms used in task 398 research

## Summary

This report extracts all formal definitions from sn-article.tex for the terms of art used in the task 398 research report (research-001.md). The definitions are organized by conceptual dependency so they can be introduced in proper order.

## Findings

### Foundation: State Spaces (Lines 420-436)

These definitions underpin all subsequent concepts:

| Term | Definition (from sn-article.tex) |
|------|-----------------------------------|
| **Modalised state space** | An ordered triple `S = <S, sqsubseteq, P>` where S is a set of *states*, `sqsubseteq` is the *parthood relation* forming a complete lattice over S, and P is a nonempty set of *possible states* where every part of a possible state is possible (line 420) |
| **Complete lattice** | A partial order `<S, sqsubseteq>` where every subset X has a least upper bound (line 423) |
| **Fusion** | The least upper bound of X, written `s.t = bigsqcup{a,b}` for two states (line 426) |
| **Compatible states** | States s and t are *compatible* iff `s.t` is possible, i.e., `s o t := s.t in P` (line 435) |
| **World states** | `W := {s in P : t sqsubseteq s whenever t o s}` - all maximal possible states (line 436) |

### Propositions (Lines 441-503)

| Term | Definition |
|------|------------|
| **Contents** | `C_S = {X in S : X = closure(X)}` where `closure(X) = {bigsqcup Y in S : nonempty Y in X}` (lines 445-446) |
| **S-proposition** | An ordered pair `<V, F>` that is both *exclusive* (states in V incompatible with states in F) and *exhaustive* (every possible state compatible with some state in V or F) (lines 452-453) |
| **Verifiable proposition** | `P_S^+` - propositions with a possible state in V (line 455) |
| **Exact verifiers** | `|A|^+` - the set of states that exactly verify A (line 503) |
| **Inexact verifiers** | `[A]^+ = [|A|^+]` where `[X] = {t in S : s sqsubseteq t for some s in X}` (line 503) |
| **Exact falsifiers** | `|A|^-` - the set of states that exactly falsify A |
| **Inexact falsifiers** | `[A]^- = [|A|^-]` (line 503) |

### Propositional Operations (Lines 473-487)

| Term | Definition |
|------|------------|
| **Inclusion** | `P sqsubseteq Q := P and Q = Q` (conjunctive-parthood) (line 473) |
| **Logical remainder** | `P - Q := bigwedge{R in P_S : R sqsubseteq P and R not sqsubseteq Q}` - strongest proposition included in P but not Q (line 475) |
| **Inversion** | `P/Q := (P - Q) and not Q` - replacing Q in P with its negation (line 485) |

### Closeness Ordering (Lines 538-555)

| Term | Definition |
|------|------------|
| **Ordered state space** | An ordered triple `S = <S, sqsubseteq, preceq>` where `<S, sqsubseteq>` is a complete lattice and `preceq` is a *weak closeness relation* (line 540) |
| **Weak closeness** | `t preceq_s r` means "s is at least as likely to transition to t as to r" (line 539) |
| **Closeness constraints** | (1) *Reflexivity*: `t preceq_s t`; (2) *Transitivity*: `t preceq_s q` when `t preceq_s r` and `r preceq_s q`; (3) *Totality*: `t preceq_s q` or `q preceq_s t`; (4) *Inaccessibility*: impossible states at furthest distance; (5) *Stability*: `s.t` impossible when s impossible (lines 543-547) |
| **Strict closeness** | `t prec_s q := q not preceq_s t` - s more likely to transition to t than q (line 554) |
| **Impossible state** | A state s where `t preceq_s s` for all t (i.e., at furthest distance from itself) (line 550) |

### Tasks and Accessibility (Lines 569-591)

| Term | Definition |
|------|------------|
| **Task** | There is a task from s to t (written `s -> t`) iff `exists q in S (t prec_s q)` - t is accessible from s (line 570) |
| **Closest state** | `s mapsto t := forall q in S (t preceq_s q)` - t is among the states closest to s (line 584) |
| **Accessible states** | `(s) := {t in S : s -> t}` (line 589) |
| **Expected states** | `[s] := {t in S : s mapsto t}` - states closest to s (line 590) |
| **Possible states** | `P := {s in S : s -> s}` - states accessible to themselves (line 595) |

### Evolutions (Lines 606-614)

| Term | Definition |
|------|------------|
| **Discrete evolution** | An assignment `tau: Z -> S` where `tau(n) -> tau(n+1)` for all n in Z (line 606) |
| **Expected evolution** | A discrete evolution where `tau(n) mapsto tau(n+1)` for all n (line 607) |
| **E_S** | The set of all expected evolutions over ordered state space S (line 613) |
| **<s>_x** | `{tau in E_S : tau(x) = s}` - expected evolutions occupying state s at time x (line 613) |
| **Subevolution** | `delta sqsubseteq tau := forall x in Z (delta(x) sqsubseteq tau(x))` - delta is a part of tau at every time (line 614) |
| **Expected subevolution** | `delta sqsubseteq* tau := (delta in E_S) and (delta sqsubseteq tau)` (line 614) |

### Causal Context (Lines 617-621)

| Term | Definition |
|------|------------|
| **Ordered model** | A tuple `M = <S, sqsubseteq, preceq, |*|>` where `<S, sqsubseteq, preceq>` is an ordered state space and `|*|: Lit -> P_S` is an interpretation (line 617) |
| **Context** | `c = <x, y, beta>` with *time of cause* x, *time of effect* y > x, and *background assumptions* beta (line 618) |
| **Background assumptions** | `beta: Z -> P_S^+` - assigns verifiable propositions to times (line 618) |

### Causal Semantics (Lines 626-643)

| Term | Definition |
|------|------------|
| **(circleright)** | The causal conditional `A circleright B` is true at M,c iff conditions (1), (2), (3) hold (line 626) |
| **Condition (1)** | `|A| sqsubseteq beta(x)` and `|B| sqsubseteq beta(y)` - cause and effect included in background assumptions |
| **Condition (2)** | For all `s in beta(x)^+` and `tau in <s>_x`, there is `delta sqsubseteq* tau` where `delta(y) in [B]^+` and for every `gamma sqsubseteq* delta`, if `gamma(y) in [B]^+` then `gamma(x) in [A]^+` |
| **Condition (3)** | For every `t in (beta(y)/|B|)^+` and `lambda in <t>_y`, if `lambda(x) in [A]^+`, then there is `d sqsubseteq lambda(x)` where `d in [A]^+` and `omega(y) in [B]^+` for all `omega in <d>_x` |
| **Augmented cause** | The background assumption at time of cause `beta(x)` when condition (1) is satisfied (line 630) |
| **Inverted effect** | The result of inverting the effect in the background at time of effect: `beta(y)/|B|` (line 631) |

## Terms Used in research-001.md Requiring Definition

The following terms are used in research-001.md but need explicit definitions:

1. **sqsubseteq** (parthood) - used without defining the complete lattice structure
2. **beta(x)^+** - notation for exact verifiers of beta(x), needs prior definition of propositions
3. **<s>_x** - expected evolutions at state s and time x, needs evolution machinery
4. **delta sqsubseteq* tau** - expected subevolution, needs subevolution definition first
5. **[A]^+** and **|A|^+** - inexact vs exact verifiers, needs proposition theory
6. **P/Q** (inversion) - needs remainder and negation defined first
7. **s mapsto t** - closest state relation, needs closeness ordering first

## Recommendations

### Order of Definitions for Revised research-001.md

To ensure all terms are defined before use, the report should introduce concepts in this order:

1. **State Space Foundations**
   - States (S), parthood (sqsubseteq), complete lattice
   - Fusion (s.t), compatibility, possibility

2. **Proposition Theory**
   - Contents, S-propositions, verifiability
   - Exact verifiers |A|^+, exact falsifiers |A|^-
   - Inexact verifiers [A]^+, inexact falsifiers [A]^-

3. **Propositional Operations**
   - Inclusion (P sqsubseteq Q)
   - Logical remainder (P - Q)
   - Inversion (P/Q)

4. **Closeness Ordering**
   - Weak closeness (preceq)
   - Strict closeness (prec)
   - Closest state (mapsto)
   - Task relation (->)

5. **Evolution Theory**
   - Discrete evolution (tau: Z -> S)
   - Expected evolution (E_S)
   - Evolutions at a state (<s>_x)
   - Subevolution (sqsubseteq)
   - Expected subevolution (sqsubseteq*)

6. **Causal Context**
   - Ordered model (M)
   - Context (c = <x, y, beta>)
   - Background assumptions (beta)

7. **Causal Semantics**
   - Conditions (1), (2), (3)
   - Augmented cause
   - Inverted effect

## References

- sn-article.tex, lines 420-645: All formal definitions extracted from source
- research-001.md: Target document for revision

## Next Steps

1. Revise research-001.md to add a "Formal Definitions" section before the main findings
2. Ensure the three-condition causal semantics clause uses only defined notation
3. Update the "Key Concepts Requiring Definition" table to use the precise definitions
4. Add explicit line references to sn-article.tex for each definition
