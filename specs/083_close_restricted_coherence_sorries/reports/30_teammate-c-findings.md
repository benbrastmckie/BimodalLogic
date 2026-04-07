# Teammate C Findings: Root Cause Analysis and the Tuple-Based Construction

**Task**: 83 -- Close Restricted Coherence Sorries
**Author**: Teammate C (Root Cause Analysis + New Construction Method)
**Date**: 2026-04-07

---

## 1. Precise Formalization of the Tuple Construction

### 1.1 Definitions

**Definition 1 (Signed Formula).** A *signed formula* is a pair (phi, s) where phi is a Formula and s in {+, -}. We write +phi for (phi, +) (asserted/true) and -phi for (phi, -) (denied/false).

**Definition 2 (Tuple).** A *tuple* is a pair T = (X, Y) where X, Y are finite sets of Formula such that:
- **Negation closure**: If neg(psi) in X then psi in Y, and if neg(psi) in Y then psi in X.
- **Consistency**: X is (set-)consistent, i.e., no finite subset of X derives bot.
- **Non-contradiction**: X and Y are disjoint (no formula appears in both).

Here X is the "verifier set" (formulas asserted true) and Y is the "falsifier set" (formulas asserted false).

**Remark on negation closure.** The user's description says "if neg(psi) in X then psi in Y." This is a *downward* closure principle: asserting neg(psi) true forces psi false. Combined with consistency of X, we get that X and Y never conflict: if psi in X and neg(psi) in X, then X derives bot (via psi, psi -> bot yields bot), contradicting consistency.

**Definition 3 (Boolean Unpacking).** Given a tuple T = (X, Y), *boolean unpacking* exhaustively decomposes boolean connectives:

Verifier rules (phi in X):
- If phi = psi -> chi in X: branch into (X + neg(psi), Y + psi) or (X + chi, Y) (these correspond to the two ways the implication can be true)
- If phi = neg(psi -> chi) in X (equivalently phi = (psi -> chi) -> bot): add psi to X, add chi to Y (the only way neg(psi -> chi) is true: psi true AND chi false)
- If phi = box(psi) in X: no boolean action (modal, handled later)
- If phi = all_future(psi) in X: no boolean action (temporal, handled later)
- If phi = all_past(psi) in X: no boolean action (temporal, handled later)
- If phi = untl(psi, chi) in X: no boolean action (temporal, handled later)
- If phi = snce(psi, chi) in X: no boolean action (temporal, handled later)
- Atoms and bot are irreducible.

Falsifier rules (phi in Y):
- If phi = psi -> chi in Y: add psi to X, add neg(chi) to X (equivalently add chi to Y) (the only way an implication is false: antecedent true AND consequent false)
- If phi = box(psi) in Y (i.e., neg(box(psi)) is effectively asserted): this is diamond(neg(psi)), handled in modal branching
- If phi = all_future(psi) in Y: this is some_future(neg(psi)), i.e., F(neg(psi)), handled in temporal task generation
- If phi = all_past(psi) in Y: this is some_past(neg(psi)), i.e., P(neg(psi)), handled in temporal task generation
- If phi = untl(psi, chi) in Y: this means neg(psi U chi), which is H'(neg(chi)) or (neg(chi)) S (neg(psi) and neg(chi)) -- complex, handled specially

**Important precision**: Since the logic uses imp/bot as primitives and neg(phi) = phi -> bot, "and" and "or" are derived. The unpacking rules above cover the primitive cases. Derived connectives unpack through their definitions:
- phi.and psi = neg(phi -> neg(psi)) = (phi -> (psi -> bot)) -> bot, which is imp(imp(phi, imp(psi, bot)), bot) in X
- phi.or psi = neg(phi) -> psi = imp(imp(phi, bot), psi) in X

The user's stated aim to "avoid upward closure" and "always reduce complexity" is satisfied: each unpacking step decomposes a formula into strict subformulas. This ensures termination of the boolean unpacking phase.

**Definition 4 (Consistent Tuple after Boolean Saturation).** A tuple Lambda = (X, Y) is *boolean-saturated* if:
- Every implication in X has been branched
- Every negated implication has been decomposed
- Negation closure is maintained throughout

After boolean saturation, X contains only atoms, bot, and formulas headed by box, all_future, all_past, untl, snce (plus their negations, which reduce to duals).

### 1.2 Timelines and the Collection kappa

**Definition 5 (Timeline Sigma).** A *timeline* Sigma is a partial function from Z (the integers) to boolean-saturated tuples:
- Sigma : Z -> Tuple (partial, defined on some domain)
- Lambda_x denotes Sigma(x), the tuple at time x
- Sigma must satisfy *temporal linkage*: for consecutive defined positions x, x+1, the x_content relationship holds (see Step 4)

**Definition 6 (Timeline Collection kappa).** kappa is a set of timelines, representing different "possible worlds" connected by the modal accessibility relation. Every timeline in kappa shares the same box-class (formulas under box are the same across all timelines at any given time).

### 1.3 Consistency

A tuple T = (X, Y) is *consistent* if X is set-consistent in the sense of the TM proof system: no finite subset of X derives bot.

**Critical observation**: The user says "consistency references the first set X." This is correct: Y is determined by X via negation closure plus the formulas that have been placed there by unpacking rules. Consistency of T reduces to consistency of X.

---

## 2. Worked Example: phi = F(p) and diamond(F(q)) and G(r)

### 2.1 Step 1: Initial Tuple

phi = F(p).and (diamond(F(q)).and (G(r)))

Expanding derived connectives:
- F(p) = neg(G(neg(p))) = neg(all_future(p -> bot)) = (all_future(imp(p, bot))).imp bot
- diamond(F(q)) = neg(box(neg(F(q)))) = neg(box(F(q) -> bot))
- G(r) = all_future(r)
- phi = neg(F(p) -> neg(diamond(F(q)) -> neg(G(r)))) ... (deeply nested)

The initial tuple:
- Lambda_0 = ({phi}, {neg(phi)})
- Since neg(phi) = phi -> bot, and phi is in X, we add phi -> bot to Y by negation closure? No -- negation closure says: if neg(psi) in X then psi in Y. Here phi in X, neg(phi) in Y. We must check: neg(phi) in Y means... actually Y starts with {neg(phi)} which is just the formula (phi -> bot).

Let me restart with the user's simpler notation. We work with a higher-level representation where we track the intended truth values:

**X = {F(p), diamond(F(q)), G(r)}** (all three conjuncts are true)
**Y = {}** initially; negation closure adds nothing yet since no negated formula appears in X.

This is consistent because {F(p), diamond(F(q)), G(r)} is consistent (it is satisfiable by any model with a future p-witness, a world with a future q-witness, and r holding at all future times).

### 2.2 Step 2: Boolean Unpacking

No boolean connectives to unpack at top level -- F(p), diamond(F(q)), and G(r) are all modal/temporal. Lambda_0 is already boolean-saturated (at the top level).

Result: Sigma is a timeline with Lambda_0 placed at position 0.
Sigma = {0 -> ({F(p), diamond(F(q)), G(r)}, {})}

### 2.3 Step 3: Modal Branching

diamond(F(q)) in X of Lambda_0 means: there exists some world where F(q) holds.

This generates a NEW timeline Sigma' in kappa with a new initial tuple:
- Lambda'_0 = ({F(q)}, {})
- Lambda'_0 is placed at position 0 in Sigma'

Additionally: any box(chi) in Lambda_0 would propagate chi to Lambda'_0. In our example, there are no box-formulas in Lambda_0, so no propagation yet.

kappa = {Sigma, Sigma'} so far.

### 2.4 Step 4: Temporal Task Generation

**From Lambda_0 in Sigma:**

- F(p) in Lambda_0 generates **Task(Lambda_0, x, Lambda''_0)** where x > 0 (some strictly future position) and Lambda''_0 is generated from {p}:
  - Lambda''_0 = ({p}, {})
  - This means: at some future time x, we need p to be true
  - Task record: Task(Lambda_0, x, Lambda''_0) with constraint x > 0

- G(r) in Lambda_0: this is a UNIVERSAL temporal formula, handled in Step 6 (propagation), not task generation.

- diamond(F(q)) already handled in modal branching.

**From Lambda'_0 in Sigma':**

- F(q) in Lambda'_0 generates **Task(Lambda'_0, y, Lambda'''_0)** where y > 0 and Lambda'''_0 = ({q}, {}):
  - Task record: Task(Lambda'_0, y, Lambda'''_0) with constraint y > 0

### 2.5 Step 5: Transitive Closure

Currently we have:
- Task(Lambda_0, x, Lambda''_0) with x > 0 in Sigma
- Task(Lambda'_0, y, Lambda'''_0) with y > 0 in Sigma'

Reflexive closure adds: Task(Lambda_0, 0, Lambda_0), Task(Lambda''_0, 0, Lambda''_0), etc.

Transitivity: If we later add more tasks, they compose. For now, the task graph is simple.

### 2.6 Step 6: Universal Propagation

**G(r) in Lambda_0 in Sigma**: Add r to ALL Lambda_y in Sigma for y >= 0.

So Lambda''_0 (at position x > 0) gets r added: Lambda''_0 becomes ({p, r}, {}).

Also: for all positions y >= 0 in Sigma, the tuple at y must contain r.

If box(chi) were in Lambda_0: chi would be added to ALL tuples in ALL timelines in kappa. In our example, no box-formulas.

### 2.7 Step 7: Duration Resolution

In this simple example, we need to assign a concrete integer to x (the F(p)-witness position).

The constraint is simply x > 0, i.e., x >= 1. Choose x = 1.

Timeline Sigma becomes:
- Position 0: ({F(p), diamond(F(q)), G(r)}, {})
- Position 1: ({p, r}, {}) (the F(p) witness, with G(r) propagated)
- All positions y >= 0: must contain r (from G(r) propagation)

Timeline Sigma' becomes:
- Position 0: ({F(q)}, {})
- Position 1: ({q}, {}) (the F(q) witness)

This is trivially satisfiable -- no conflicting constraints.

### 2.8 Step 8: Closure

Close kappa under time-shifts. Sigma shifted by +1 gives the same Sigma starting from position -1 perspective. Under the S5 modal accessibility (which is universal across kappa), box-formulas in any timeline propagate to all timelines.

**Final model**: kappa = {Sigma, Sigma'} with the above assignments.

---

## 3. Duration Resolution Analysis (THE HARD PART)

### 3.1 The Constraint Satisfaction Problem

After Steps 1-6, we have:
- A collection of timelines kappa = {Sigma_1, ..., Sigma_k}
- Within each Sigma_i, a set of tuples Lambda_{i,0}, Lambda_{i,1}, ... placed at positions 0, 1, 2, ...
- A set of Task constraints: Task(Lambda_a, d, Lambda_b) meaning Lambda_b must be placed at exactly d positions after Lambda_a within its timeline
- Duration variables: each d is an integer variable subject to sign constraints (d > 0 for F-tasks, d < 0 for P-tasks)

The constraints form a system:
- For each F(psi) in Lambda_a: Task(Lambda_a, d_psi, Lambda_b) with d_psi > 0
- For each P(psi) in Lambda_a: Task(Lambda_a, d_psi, Lambda_b) with d_psi < 0
- Transitive closure: Task(A, d1, B) and Task(B, d2, C) implies Task(A, d1+d2, C)

### 3.2 When Can Constraints Be Inconsistent?

**Case 1: Simple chains.** If Lambda_0 has F(psi1) generating task to Lambda_1 (at d1 > 0), and Lambda_1 has F(psi2) generating task to Lambda_2 (at d2 > 0), then Lambda_2 is at position d1 + d2 > 0 from Lambda_0. No conflict possible -- all constraints point the same direction.

**Case 2: Forward-backward interaction.** If Lambda_0 has F(psi) generating Lambda_1 at d1 > 0, and Lambda_0 has P(chi) generating Lambda_2 at d2 < 0, and Lambda_1 has P(theta) generating Lambda_2 at d3 < 0, we need:
- d2 = d1 + d3
- d1 > 0, d2 < 0, d3 < 0
- So d2 = d1 + d3. Since d3 < 0 and d1 > 0, d2 = d1 + d3 could be positive or negative depending on magnitudes.
- Constraint: d2 < 0 requires d1 + d3 < 0, i.e., |d3| > d1.

This is satisfiable: choose d1 = 1, d3 = -2, giving d2 = -1 < 0. Check.

**Case 3: Cyclic constraints.** The ONLY way constraints can become inconsistent is through a cycle:
- Task(A, d1, B), Task(B, d2, C), Task(C, d3, A) requires d1 + d2 + d3 = 0
- But each d_i has a sign constraint (> 0 or < 0)
- If ALL are > 0: sum > 0, contradiction with = 0
- If ALL are < 0: sum < 0, contradiction with = 0
- If MIXED: may or may not sum to 0

**Key question**: Can the tuple construction produce cyclic task constraints with contradictory sign requirements?

### 3.3 Analysis of Cycle Formation

A cycle Task(A, d1, B), Task(B, d2, A) requires d1 + d2 = 0. But d1 > 0 (F-task from A to B) and d2 > 0 (F-task from B to A) gives d1 + d2 > 0, contradiction. Similarly for both P-tasks.

**However**, if d1 > 0 (F-task from A to B) and d2 < 0 (P-task from B to A), then d1 + d2 = 0 is satisfiable: d2 = -d1. This is not a contradiction -- it just means A and B are at the same position, which contradicts d1 > 0 (they must be at different positions). Wait: d1 + d2 = 0 means the offset from A back to A is 0, which is correct (reflexivity). The issue is that d1 > 0 says B is strictly AFTER A, and d2 < 0 says A is strictly BEFORE B, which is consistent (both say B is after A). But we also need d2 = -d1, meaning the P-task from B to A has duration -d1. This is fine: it says A is at d1 steps before B, which is exactly what d1 > 0 says.

So 2-cycles between F and P tasks are always satisfiable.

**What about 3-cycles?** Task(A, d1, B), Task(B, d2, C), Task(C, d3, A) with d1 + d2 + d3 = 0. If d1, d2 > 0 (both F-tasks) and d3 < 0 (P-task), we need d3 = -(d1 + d2) < 0, which is satisfied automatically. So this is always satisfiable too.

**General principle**: As long as we can freely choose the magnitudes of the duration variables (subject only to sign constraints), the system is satisfiable. The constraint graph is a system of *difference constraints* (constraints of the form x_j - x_i > 0 or x_j - x_i < 0), which is always satisfiable over Z when the directed graph of > 0 constraints is acyclic.

**Is the constraint graph acyclic?** An F-task from A to B means position(B) > position(A). A P-task from A to B means position(B) < position(A). A cycle of purely > constraints is impossible (would require position(A) > position(A)). A cycle of purely < constraints is impossible. A mixed cycle: position(A) > position(B) > position(C) > position(A) would be a contradiction, but position(A) > position(B) > position(C) < position(A) is fine.

**The real constraint**: The directed graph where A -> B means "B is strictly after A" (from F-tasks) must be a DAG (no directed cycles). The undirected constraint graph can have cycles (F forward, P backward between the same nodes) without issue.

**Claim**: The task generation process never creates a directed cycle of F-constraints. Proof sketch: Each F(psi) in Lambda_a generates a task to Lambda_b where Lambda_b is generated from {psi}, and complexity(psi) < complexity(F(psi)). By well-founded induction on the total complexity of formulas driving the tasks, the F-constraint graph is acyclic.

**Wait -- this is not quite right.** After universal propagation (Step 6), NEW formulas are added to tuples, and these can generate NEW tasks. This is the critical issue addressed in Section 4.

### 3.4 The Constraint Satisfaction is a System of Difference Constraints

Formally, for each tuple Lambda_i in a timeline, let pos(Lambda_i) be its integer position. The constraints are:
- pos(Lambda_b) - pos(Lambda_a) > 0 for each F-task from Lambda_a to Lambda_b
- pos(Lambda_b) - pos(Lambda_a) < 0 for each P-task from Lambda_a to Lambda_b

This is equivalent to: for each F-task, pos(Lambda_b) >= pos(Lambda_a) + 1; for each P-task, pos(Lambda_b) <= pos(Lambda_a) - 1.

This is a system of difference constraints, solvable by Bellman-Ford in polynomial time. The system is satisfiable if and only if the constraint graph has no positive-weight cycle (under the standard transformation to shortest-path problems).

**A positive-weight cycle** corresponds to a chain of constraints that collectively require position(A) > position(A), i.e., a contradiction. In our setting, this would be a sequence of F-tasks forming a directed cycle: Lambda_0 -F-> Lambda_1 -F-> ... -F-> Lambda_0, requiring pos(Lambda_0) < pos(Lambda_1) < ... < pos(Lambda_0).

### 3.5 Can Universal Propagation Create F-Cycles?

Consider: Lambda_a has G(F(psi)). By G-propagation, F(psi) is added to Lambda_b for all b >= a. Each Lambda_b now generates a task for F(psi). But each such task points to a NEW tuple (generated from {psi}), not back to Lambda_a. So no cycle is formed.

However, if the F(psi) witness Lambda_c has G(F(theta)) (from Step 6 propagation), and the F(theta) witness Lambda_d has a formula that eventually leads back to Lambda_a ... this requires Lambda_a to be reachable from its own F-descendants, which would require a P-task somewhere, not an F-task. So the F-directed graph remains acyclic.

**Conclusion**: The duration resolution problem IS always satisfiable, assuming the tuple generation terminates (addressed in Section 4).

---

## 4. Critical Gaps and Termination Issues

### 4.1 Does Universal Propagation Create an Infinite Chain of Tasks?

**The critical example**: Suppose G(F(psi)) is in Lambda_0.

Step 6 propagates F(psi) to ALL Lambda_y for y >= 0.

Each such Lambda_y generates a task for F(psi), requiring a witness tuple Lambda'_y with psi at some position > y.

Now, does Lambda'_y itself contain G(F(psi))? **Not necessarily** -- Lambda'_y was generated from {psi}, and psi need not contain G(F(psi)). So the chain of generated tasks is:
- From Lambda_0: F(psi) -> witness at some position > 0
- From Lambda_1: F(psi) -> witness at some position > 1
- From Lambda_2: F(psi) -> witness at some position > 2
- ...

This is an infinite family of tasks, but they can ALL be satisfied by a single witness at position y+1 for each Lambda_y. More importantly: the FORMULAS involved have bounded complexity. The only formulas driving task generation are subformulas of the original phi plus their negations. Since phi is finite, the subformula closure is finite.

**However**: the number of TUPLES can be infinite because the same formula F(psi) at different positions generates different task instances. The question is whether we can handle this.

### 4.2 Termination of Tuple Generation

The user claims "this process terminates because formulas have finite complexity." Let us verify:

**Step 2 (Boolean unpacking)**: Each unpacking step reduces formula complexity. Terminates.

**Step 3 (Modal branching)**: Each diamond(psi) generates a new timeline from {psi}, where complexity(psi) < complexity(diamond(psi)). The branching is bounded by the number of diamond-subformulas. Terminates.

**Step 4 (Temporal task generation)**: Each F(psi) generates a task with target {psi}, where complexity(psi) < complexity(F(psi)). Each P(psi) similarly. Bounded by temporal subformulas. Terminates.

**Step 6 (Universal propagation)**: Here is the concern. G(chi) in Lambda_x adds chi to all Lambda_y for y >= x. If chi itself contains temporal operators, these generate NEW tasks:
- If chi = F(theta): generates task with target {theta}. complexity(theta) < complexity(F(theta)) < complexity(G(F(theta))).
- If chi = G(eta): adds G(eta) to Lambda_y, which adds eta to all Lambda_z for z >= y. Nested G just propagates further.
- If chi = box(alpha): adds alpha to all timelines (handled in Step 8).

**Key insight**: The formulas that appear at ANY position in ANY tuple are always subformulas of the original phi (or their negations, under negation closure). This is because:
- Boolean unpacking produces subformulas
- Modal branching extracts inner formulas from diamond (subformulas)
- Temporal task generation extracts inner formulas from F/P (subformulas)
- Universal propagation extracts inner formulas from G/H/box (subformulas)

The subformula closure of phi is finite. Therefore:
- The number of DISTINCT tuple types is bounded (at most 2^|subformulaClosure(phi)|)
- The number of distinct timelines is bounded (by the number of diamond-subformulas)
- The number of distinct task types is bounded (by the number of F/P-subformulas)

**The process terminates** with respect to the generation of new tuple types and task types. The infinite family of task INSTANCES (from G(F(psi)) propagation) is handled by the duration resolution step, which assigns concrete integer positions.

### 4.3 The Subtle Issue: Until and Since

The user's proposal handles F/P tasks explicitly but does not clearly address Until and Since.

For phi U psi in Lambda_x:
- Semantically: there exists s > x with psi at s, and phi holds at all r with x < r < s.
- This is MORE COMPLEX than F(psi): it requires phi to hold at all intermediate positions.

**Proposed handling**: Treat Until as generating a COMPOUND task:
- Task(Lambda_x, d, Lambda_y) where Lambda_y contains psi, AND
- For all z with x < z < x+d: Lambda_z must contain phi

This is a constraint involving ALL intermediate positions, not just the endpoint. The duration resolution must ensure that phi appears in every intermediate tuple.

**The difficulty**: After universal propagation, phi may or may not persist. If phi is a simple atom, it can be added to intermediate tuples. If phi is complex (e.g., phi itself has temporal obligations), the intermediate tuples may need their own task generation, creating a cascade.

**The user's approach via Until axioms**: The F_until_equiv axiom converts F(psi) to (top U psi). So the construction could work with Until as the primary temporal existential. The until_unfold axiom X(psi or (phi and (phi U psi))) then provides the step-by-step resolution.

**Gap**: The user's proposal does not detail how Until persistence is maintained through the construction. This is precisely the same problem that blocks the deterministic chain approach (see Report 28, Section 1). The Until obligation must be carried forward until its witness appears, and each step must verify that the guard phi holds.

### 4.4 Gap: Interaction Between Modal and Temporal Obligations

The user's Steps 3 and 4 generate modal branches and temporal tasks independently. But consider:

box(F(psi)) in Lambda_0 means: in EVERY timeline, F(psi) must hold at position 0.

After Step 3 propagates box-content to all timelines, each timeline gets F(psi). After Step 4, each timeline needs an F(psi)-witness. These witnesses are independent across timelines.

But what about diamond(G(psi))? This generates a new timeline where G(psi) holds. G(psi) then propagates psi to all future positions in that timeline. This is handled correctly.

What about G(diamond(psi))? This propagates diamond(psi) to all future positions. Each position then generates a new timeline (or shares an existing one with the right box-class). The number of timelines is bounded by 2^|subformulaClosure(phi)| (since timelines are distinguished by their box-class, which is a subset of the subformula closure).

**Gap identified**: The user's proposal does not address how many timelines are needed and whether the generation terminates. However, as argued above, the bound by the subformula closure ensures finiteness.

---

## 5. Comparison with Existing Approaches

### 5.1 Standard Lindenbaum/Henkin Construction

The standard approach:
1. Start with a consistent set {phi}
2. Extend to an MCS M_0 via Lindenbaum's lemma (Zorn's lemma)
3. Build a canonical model where worlds are MCSes

**Difference from the tuple approach**: Lindenbaum produces an MCS containing ALL formulas (not just subformulas of phi). The tuple approach stays within the subformula closure, avoiding the need for Lindenbaum's lemma and giving finite models directly.

**Critical difference**: In the Lindenbaum approach, the MCS is infinite and non-constructive. The deterministic chain chain(n+1) = x_content(chain(n)) is fully determined but the forward_F property is not provable (the push/pull mismatch). The tuple approach avoids this by constructing witnesses FIRST (Step 4) before assembling the timeline.

### 5.2 Quasimodel Approach (GHR 1994)

The quasimodel approach:
1. Build a set of "types" (MCS-like objects restricted to subformula closure)
2. Equip with a successor function and F-witness pointers
3. Verify local consistency and eventuality resolution
4. Unravel the quasimodel into a linear model

**Similarity**: The tuple construction is essentially a REINVENTION of the quasimodel approach, with different terminology:
- "Tuple" = "type" or "atom" in quasimodel terminology
- "Task" = "eventuality pointer" or "fulfilling function"
- "Timeline" = "run" or "path" through the quasimodel
- "Duration resolution" = "unraveling" the quasimodel into a linear order

**Key difference**: The user's approach adds a novel element: explicit integer duration assignments via constraint satisfaction (Step 7). The standard quasimodel unraveling constructs the linear order by concatenating type sequences, without assigning integer timestamps. The constraint satisfaction formulation is cleaner for the bimodal setting where task frames require integer durations.

### 5.3 Filtration

Filtration takes an existing (possibly infinite) model and collapses it to a finite model by identifying states that agree on the subformula closure.

**Difference**: Filtration requires a MODEL to start with. The tuple approach builds the model from scratch. Filtration is typically used to prove the Finite Model Property given completeness, not to prove completeness itself.

### 5.4 What Is Genuinely New

1. **The two-phase approach**: Witnesses first (Steps 3-4), then assembly (Steps 5-7). This directly addresses the push/pull mismatch because witnesses are PULLED (F-obligations actively seek witnesses) rather than relying on a PUSH construction to accidentally produce them.

2. **Constraint satisfaction framing**: The duration resolution as a system of difference constraints over Z is a clean formulation that leverages well-known algorithms (Bellman-Ford) to verify satisfiability. This is new in the context of temporal logic completeness.

3. **Integration with task frame semantics**: The tuple construction directly targets the task frame structure (world states, task relation with duration type D), rather than building a generic Kripke frame and then equipping it with a task relation post hoc.

---

## 6. Detailed Assessment of Duration Resolution (Step 7)

### 6.1 Formal Problem Statement

**Given**: A finite set of tuple instances T = {Lambda_1, ..., Lambda_n} within a timeline Sigma, with task constraints:
- For each F-obligation: pos(Lambda_j) - pos(Lambda_i) >= 1 (strict future)
- For each P-obligation: pos(Lambda_j) - pos(Lambda_i) <= -1 (strict past)
- For each G-propagation: chi must appear in all Lambda_k with pos(Lambda_k) >= pos(Lambda_i)
- For each H-propagation: chi must appear in all Lambda_k with pos(Lambda_k) <= pos(Lambda_i)

**Find**: An assignment pos : {Lambda_1, ..., Lambda_n} -> Z satisfying all constraints.

### 6.2 The Difference Constraint System

The F and P constraints form a system of difference constraints. Introduce a variable t_i for each Lambda_i. The constraints are:
- t_j - t_i >= 1 for each F-task from Lambda_i to Lambda_j
- t_i - t_j >= 1 for each P-task from Lambda_i to Lambda_j (equivalently t_j - t_i <= -1)

This is a classic system of difference constraints, solvable iff the constraint graph has no positive-weight cycle.

**Claim**: The constraint graph has no positive-weight cycle.

**Proof**: A positive-weight cycle would be a sequence i_1, i_2, ..., i_k, i_1 with:
- Sum of weights >= 1 (where each F-edge contributes +1 and each reverse-P-edge contributes +1)

But each edge i_j -> i_{j+1} represents either an F-task (Lambda_{i_j} has F(psi) witnessed at Lambda_{i_{j+1}}) or a P-task (Lambda_{i_{j+1}} has P(chi) witnessed at Lambda_{i_j}, contributing a reversed edge). In either case, the edge goes from a tuple containing an existential temporal formula to the tuple containing the witness, with the witness having strictly lower complexity.

Wait -- this argument about complexity is not quite right. The witness tuple Lambda_b for F(psi) contains psi (a subformula of F(psi)), but Lambda_b may also contain propagated formulas (from Step 6) that are NOT subformulas of the original formula driving the task. However, propagated formulas do not create new tasks on their own -- only the original formulas in the initial tuple do.

**Actually, propagated formulas DO create new tasks.** If G(F(theta)) is in Lambda_0, then F(theta) is propagated to all Lambda_y with y >= 0. Each such F(theta) creates a task. But the task target is generated from {theta}, which has lower complexity than G(F(theta)). The key insight is that task generation is driven by formulas from the subformula closure of the ORIGINAL formula phi, and each level of task generation decreases complexity within this closure.

**Refined argument**: Define the *task depth* of a formula as:
- task_depth(atom) = task_depth(bot) = 0
- task_depth(imp phi psi) = max(task_depth(phi), task_depth(psi))
- task_depth(box phi) = task_depth(phi) (modal branching, not temporal tasks)
- task_depth(all_future phi) = task_depth(phi) (universal, not a task)
- task_depth(all_past phi) = task_depth(phi) (universal, not a task)
- task_depth(untl phi psi) = 1 + max(task_depth(phi), task_depth(psi))
- task_depth(snce phi psi) = 1 + max(task_depth(phi), task_depth(psi))

Note: F(psi) = neg(G(neg(psi))) = (all_future(psi -> bot)) -> bot. This has task_depth = task_depth(psi -> bot) = task_depth(psi). So F does not increase task depth under this measure!

This measure does not work. Let me try temporal depth instead.

The REAL measure is just formula complexity (number of connectives). F(psi) has higher complexity than psi. When we generate a task from F(psi), the witness contains psi, which has strictly lower complexity. If G(F(psi)) propagates F(psi) to later positions, the tasks generated from those F(psi) instances still point to witnesses containing psi.

No task from psi will point BACK to a tuple containing F(psi) via an F-constraint, because psi has lower complexity and task generation only adds formulas from its own subformula closure (which does not include F(psi)).

**Therefore**: The F-constraint graph is a DAG (no directed F-cycles), and the difference constraint system is always satisfiable. QED.

### 6.3 The G/H Propagation Compatibility

The G/H propagation adds formulas to tuples but does not change the constraint structure for duration resolution. It adds requirements of the form "chi must be in Lambda_k for all k >= i", which is a constraint on the CONTENT of tuples, not on their POSITIONS.

This content constraint is satisfiable if the tuple Lambda_k is consistent after adding chi. Consistency is guaranteed by the G-axiom: if G(chi) is in an MCS M, then chi is in M (by temp_t_future: G(phi) -> phi under reflexive semantics), and G(chi) is in x_content(M) (by temp_4: G(phi) -> G(G(phi)), plus the deterministic chain linkage G(phi) -> X(G(phi)) which is derivable from temp_4 + G -> X). So chi appears in all successors of M.

**Key point**: Under the reflexive semantics (G(phi) -> phi is an axiom), universal propagation is automatically compatible with the MCS structure. This is a significant advantage of the reflexive semantics choice.

---

## 7. Assessment of Feasibility for Lean Formalization

### 7.1 What Already Exists

The codebase already has:
- MCS theory (MaximalConsistent.lean, MCSProperties.lean): Lindenbaum's lemma, deductive closure, negation completeness -- all sorry-free
- Subformula closure (SubformulaClosure.lean): finite, decidable membership
- Content extractors (TemporalContent.lean): g_content, x_content, etc. with MCS preservation
- Deterministic chain (DeterministicChain.lean): sorry-free chain construction with x_content linkage
- Modal saturation (ModalSaturation.lean): box-class agreement
- Task frame semantics (TaskFrame.lean, Truth.lean): fully specified

### 7.2 What Would Need to Be Built

1. **Tuple type** (~100 lines): A structure (X : Finset Formula, Y : Finset Formula) with consistency and negation closure. This is essentially a `RestrictedMCS` restricted to the subformula closure, which already exists in `RestrictedMCS.lean`.

2. **Boolean unpacking** (~200 lines): An algorithm that decomposes boolean connectives. This is essentially a signed tableau construction. Could be built from scratch or adapted from `Decidability/Tableau.lean` if it exists.

3. **Task generation** (~150 lines): Extract F/P/Until/Since formulas and generate witness obligations. Straightforward given existing content extractors.

4. **Duration resolution** (~300 lines): Formalize the difference constraint system and prove satisfiability. This requires:
   - A graph type with weighted edges
   - Bellman-Ford or a simpler acyclicity argument
   - The key lemma: F-constraint graph is a DAG

5. **Universal propagation** (~200 lines): Propagate G/H/box content. Uses existing MCS properties.

6. **Truth lemma** (~500 lines): The most substantial piece. Prove that the constructed model satisfies the original formula. This would follow the pattern of the existing `ParametricTruthLemma` but for the new construction.

7. **Completeness wiring** (~100 lines): Connect the construction to the completeness theorem.

**Total estimate**: 1500-2000 lines of new Lean code.

### 7.3 Key Proof Obligations

1. **Consistency preservation**: Every tuple produced by the construction is consistent.
2. **Witness existence**: Every F/P obligation has a witness tuple.
3. **Duration satisfiability**: The difference constraint system has a solution.
4. **Truth lemma**: Formulas in a tuple are true at the corresponding model position.
5. **Modal coherence**: Box-class agreement across timelines.

### 7.4 Comparison with Fixing forward_F Directly

The alternative is to close the 4 sorries in DeterministicFMCS.lean (forward_F, backward_P, and two derived). This would require ~300-500 lines if a viable approach exists, but 29 research rounds have not found one.

The tuple construction is more work (1500-2000 lines) but has a KNOWN path to completion (it is essentially the quasimodel approach, which is proven in the literature). The risk is implementation complexity, not mathematical uncertainty.

---

## 8. Summary and Confidence Assessment

### What Works in the User's Proposal

1. **The witness-first philosophy is correct.** Building witnesses (F/P) before assembling the timeline directly addresses the push/pull mismatch that blocks the deterministic chain.

2. **The constraint satisfaction framing is clean.** Duration resolution as a system of difference constraints is the right abstraction for assigning integer positions.

3. **Termination is guaranteed** by the finiteness of the subformula closure.

4. **The F-constraint graph is acyclic**, ensuring satisfiability of the duration assignment.

### What Needs More Work

1. **Until/Since handling is underspecified.** The proposal focuses on F/P but Until/Since require intermediate-position constraints (not just endpoint constraints). These are more complex and need explicit treatment.

2. **The interaction between universal propagation and task generation needs careful ordering.** Must propagation happen before task generation, or iteratively? The answer is iteratively (to a fixed point), but the fixed-point argument needs formalization.

3. **The truth lemma is the hardest part**, as always. The construction must be designed so that the truth lemma proof goes through inductively on formula complexity. The reflexive semantics help (G(phi) -> phi gives the T-axiom base case for free).

4. **The relationship to existing codebase infrastructure needs mapping.** Much of what the tuple construction needs already exists (MCS theory, subformula closure, content extractors). The question is whether the existing infrastructure can be reused or must be rebuilt.

### Confidence Level: MEDIUM

- **Mathematical correctness**: HIGH confidence. The approach is essentially the quasimodel approach (GHR 1994), which is known to work.
- **Novel element (constraint satisfaction)**: HIGH confidence. Difference constraints over Z are well-understood.
- **Lean formalization feasibility**: MEDIUM confidence. 1500-2000 lines is substantial, and the truth lemma always has surprising complications.
- **Comparison with alternatives**: The decidability-based completeness path (Teammate B's recommendation from Report 29) should be investigated first, as it could bypass all canonical model / tuple / quasimodel machinery entirely. If that path has too many sorries, the tuple construction is the next best option.

### Relationship to the Push/Pull Root Cause

The user's proposal directly resolves the push/pull mismatch identified by Teammate D:
- **Push** (deterministic chain): x_content determines the next MCS. F-witnesses must "happen to appear" in the pushed chain. They may not.
- **Pull** (tuple construction): F-obligations explicitly pull their witnesses into the construction. Every F(psi) generates a task that ensures psi appears at some future position. The construction is designed so that pulls are always satisfiable.

This is exactly the insight that makes quasimodel constructions work: build the witnesses in, rather than hoping they emerge from a deterministic process.
