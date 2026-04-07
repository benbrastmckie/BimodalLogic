# Teammate D Findings: Critical Analysis and Gap Detection

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Role**: Devil's Advocate (Teammate D)
**Session**: sess_1775590000_d4f1a2
**Artifact**: 30

---

## 0. Executive Summary

After reading all 29 prior reports, the full codebase (axioms, semantics, chain constructions, finite deferral infrastructure, decidability module), I conclude:

1. **The quasimodel approach (Teammate A) will fail for THIS logic** -- Section 1.5 of Report 24 already proved this rigorously. The strict Until semantics with reflexive G creates an X-vs-G mismatch that no quasimodel detour can overcome. Published quasimodel proofs (Burgess 1984, GHR 1994) use reflexive temporal semantics EVERYWHERE (G, H, U, S all reflexive), not the mixed semantics of this project.

2. **The F-nesting depth induction (Teammate B) is doomed by G-regeneration** -- see detailed analysis below. The induction measure does not decrease globally because G regenerates F-obligations at every time step.

3. **The tuple-based construction (Teammate C / user) relocates the difficulty to "duration resolution" without solving it** -- the hard part is Step 7, and it faces the same fundamental constraint satisfaction problem that all other approaches face.

4. **The decidability path is a dead end** -- zero sorries but trivially so; the module uses `Classical.em` for "decidability" and has no actual proof extraction linking tableau results to derivability.

5. **The fundamental obstacle is precisely identified**: in a logic with strict Until and reflexive G over Z, the formula `neg(psi)` being in every chain position does NOT syntactically entail `G(neg(psi))` in any chain position, because `G(neg(psi))` at time t requires `neg(psi)` at all s >= t, including t itself, while the chain membership `neg(psi) in chain(s)` for all s > t gives a meta-level universal statement that cannot be internalized without either (a) forward_F itself, or (b) a fundamentally different model construction.

6. **The ONLY viable path**: abandon the single-chain paradigm entirely. Either (a) build Until witnesses directly into the model construction (a TRUE quasimodel, not the failed version from Report 24, but one that abandons x_content linkage and uses a different Until formulation), or (b) find a clever instantiation of `until_induction` that does not require `G(neg(psi))`. Option (b) has a specific concrete form that may work -- see Section 6.

---

## 1. Root Cause Deep Analysis

### 1.1 The Exact Mathematical Obstruction

The problem is precisely this inference gap:

```
HAVE:   neg(psi) in chain(s) for all s > t    (meta-level universal quantification)
NEED:   G(neg(psi)) in chain(t)                (object-level formula membership)
```

In standard completeness proofs for temporal logic, this inference is justified by a "backward G" lemma: if phi holds at all future positions in the canonical model, then G(phi) holds at the current position. This backward G lemma is proven by contraposition: if G(phi) is not at position t, then neg(G(phi)) = F(neg(phi)) is at position t, so by forward_F there exists s > t with neg(phi) at s, contradicting the assumption.

**The circularity**: backward_G requires forward_F. Forward_F requires backward_G (to derive the contradiction that closes the proof-by-contradiction).

### 1.2 Why This Circularity Is Not Present in Standard Literature

In standard completeness proofs (Burgess 1984, GHR 1994, Reynolds 2003, Goldblatt 1992), the circularity is broken by one of:

**(A) Reflexive Until semantics**: When U is reflexive (phi U psi at t means exists s >= t with psi(s)...), psi in chain(t) RESOLVES F(psi) at t. The chain never needs to "look ahead" -- if F(psi) is at t and psi is already at t, done. This eliminates many deferral scenarios.

**(B) Different model construction**: Non-deterministic models (Burgess), step-by-step construction with fair scheduling (GHR), or filtration-based approaches that build the entire model at once rather than incrementally.

**(C) Well-founded induction on formula complexity**: Reynolds (2003) proves forward_F by strong induction on psi's complexity. At each level, backward_G is available for simpler formulas. The key: in standard formulations, the dependency `forward_F(psi) -> backward_G(neg(psi)) -> forward_F(neg(neg(psi)))` does NOT increase complexity because `neg(neg(psi))` is SIMPLIFIED to `psi` (using double negation elimination at the formula level). But in this Lean formalization, `neg` is DEFINED as `phi.imp bot`, so `neg(neg(psi)) = (psi.imp bot).imp bot`, which is structurally LARGER than `psi`.

### 1.3 The Lean-Specific Amplification

The Lean formalization uses `Formula.neg phi = phi.imp Formula.bot`. This means:
- `sizeof(neg(psi)) = sizeof(psi) + 2` (imp + bot)
- `sizeof(neg(neg(psi))) = sizeof(psi) + 4`
- The dependency chain `forward_F(psi) -> backward_G(neg(psi)) -> forward_F(neg(neg(psi)))` STRICTLY INCREASES formula size

This is not just a proof engineering problem -- it's a fundamental interaction between the formula representation and the proof strategy. In a pen-and-paper proof, we identify `neg(neg(psi))` with `psi` via DNE. In Lean, they are syntactically distinct formulas.

**Could we quotient formulas by logical equivalence?** In principle yes, but this would require rebuilding the entire MCS infrastructure over equivalence classes of formulas, which is an enormous refactoring effort (estimated 3000+ lines).

### 1.4 What x_content Actually Does

`x_content(M) = {phi | X(phi) in M} = {phi | (bot U phi) in M}`

This is the "next-step content" -- formulas that hold at the immediate successor. The chain `chain(n+1) = x_content(chain(n))` means each position is the next-step projection of the previous one.

**Key property**: `phi in chain(n+1)` iff `X(phi) in chain(n)`.

**Key non-property**: `phi in chain(n+1)` does NOT imply `G(phi) in chain(n)`. The next-step operator X is strictly weaker than the always-future operator G.

This is the root of everything.

---

## 2. Critique of Quasimodel Approach (Teammate A's Angle)

### 2.1 Report 24 Already Proved It Fails

Section 1.5 of Report 24 provides a rigorous analysis showing that Until persistence breaks through quasimodel detours. The argument is:

1. If `(phi U psi) in chain(n)` and the chain takes a detour to witness W (not x_content(chain(n))):
2. `until_unfold` gives `X(psi or (phi and (phi U psi))) in chain(n)`
3. So `psi or (phi and (phi U psi)) in x_content(chain(n))`
4. But W only contains `g_content(chain(n))`, NOT `x_content(chain(n))`
5. `(phi U psi)` would need `G(phi U psi) in chain(n)` to be in g_content -- not derivable

### 2.2 GHR 1994 Does NOT Apply to This Logic

The GHR quasimodel construction works for logics where:
- Temporal operators are ALL strict or ALL reflexive
- The logic does not combine Until with reflexive G in a way that creates the X-vs-G mismatch

TM as formalized here has:
- **Reflexive** G and H (quantify over s >= t / s <= t, with T-axioms `temp_t_future`, `temp_t_past`)
- **Strict** Until and Since (witness at s > t / s < t)

This mixed semantics is non-standard. The standard references (Burgess 1984, GHR 1994, Goldblatt 1992) use either:
- All reflexive (Burgess): G, H, U, S all use >= / <=
- All strict (pre-Burgess): G, H use > / <, no Until/Since

### 2.3 Could a Modified Quasimodel Work?

A quasimodel that abandons x_content linkage and uses a different mechanism for Until would need to:
1. Track Until obligations explicitly in the construction
2. Ensure Until witnesses exist within the same family
3. Maintain modal coherence (box-class agreement)

This is essentially building a new completeness proof from scratch, not adapting GHR. Estimated effort: 2000-4000 lines (not 1000-2000 as previously estimated).

### 2.4 The "50-60% success probability" Is Unjustified

Report 29 assigns 50-60% probability to the quasimodel approach. This is too optimistic given:
- Report 24 Section 1.5 already proved the standard approach fails
- The mixed semantics is non-standard and not covered by any published proof
- The effort estimate is severely underestimated
- No concrete construction has been proposed that avoids the X-vs-G mismatch

**Revised estimate: 20-30% probability of success, 2000-4000 lines.**

---

## 3. Critique of F-Nesting Depth Induction (Teammate B's Angle)

### 3.1 The G-Regeneration Problem

Consider `G(F(p))`. This has F-depth 1. At time t, if `G(F(p)) in chain(t)`:
- By `temp_t_future`: `F(p) in chain(t)` (since G is reflexive and includes the present)
- At time t+1: `G(F(p)) in chain(t+1)` (by forward_G, which is sorry-free)
- So `F(p) in chain(t+1)` again

The F-obligation `F(p)` is REGENERATED at every time step. Even if we resolve `F(p)` at time t (finding some s > t with `p in chain(s)`), the obligation reappears at t+1, t+2, etc.

For the forward_F proof, this means: even if we prove forward_F for all formulas of F-depth < k, when we try to prove forward_F for a formula of F-depth k, the proof may need to invoke forward_F for a formula of the SAME F-depth (because G regenerates the obligation at the next time step).

### 3.2 The Specific Failure Mode

Define F-depth:
- F-depth(atom) = 0
- F-depth(imp A B) = max(F-depth(A), F-depth(B))
- F-depth(box A) = F-depth(A)
- F-depth(G A) = F-depth(A)
- F-depth(H A) = F-depth(A)
- F-depth(U A B) = max(F-depth(A), F-depth(B))
- F-depth(S A B) = max(F-depth(A), F-depth(B))
- F-depth(F(A)) = F-depth(A) + 1 (where F = neg . G . neg)

Now trace the dependency for `forward_F(psi)` where psi has F-depth k:
1. Assume `F(psi) in chain(t)`, psi never appears
2. Need `G(neg(psi)) in chain(t)` for contradiction
3. `G(neg(psi)) in chain(t)` requires backward_G for `neg(psi)`
4. backward_G for `neg(psi)` requires `forward_F(neg(neg(psi)))`
5. `neg(neg(psi)) = (psi.imp bot).imp bot`
6. F-depth(neg(neg(psi))) = F-depth((psi.imp bot).imp bot) = max(F-depth(psi.imp bot), 0) = max(F-depth(psi), 0) = F-depth(psi) = k

So `forward_F(neg(neg(psi)))` has the SAME F-depth as `forward_F(psi)`. **The induction does not make progress.**

### 3.3 Could We Use a Combined Measure?

What if we use (F-depth, formula-size) lexicographically? Then:
- F-depth(neg(neg(psi))) = F-depth(psi) (same)
- sizeof(neg(neg(psi))) = sizeof(psi) + 4 (LARGER)

The size component goes UP. No well-founded measure based on (F-depth, size) can decrease at each step.

What about (F-depth, number of negations modulo 2)? This is ad hoc and does not form a well-founded order.

### 3.4 The Real Issue: neg(neg(psi)) Is Not psi

In classical logic on paper, `neg(neg(psi))` is logically equivalent to `psi`. We can prove `neg(neg(psi)) <-> psi` as a theorem. But `forward_F(neg(neg(psi)))` and `forward_F(psi)` are DIFFERENT statements because the chain membership `neg(neg(psi)) in chain(s)` is different from `psi in chain(s)`.

True, if psi in chain(s) then neg(neg(psi)) in chain(s) (by DNE in MCS). And vice versa. So `forward_F(neg(neg(psi)))` is EQUIVALENT to `forward_F(psi)`. But that makes the induction CIRCULAR, not progress -- you need forward_F(psi) to prove forward_F(psi).

### 3.5 Verdict

**F-nesting depth induction cannot work** for THIS formalization. The dependency chain maps forward_F(psi) to forward_F(neg(neg(psi))), which has the same F-depth and is logically equivalent (hence not simpler by any measure). This is a genuine circularity, not an induction.

**Probability of success: 5-10%.** The only way it could work is if someone discovers a fundamentally new measure that decreases through the dependency, and 29 reports have not found one.

---

## 4. Critique of Tuple-Based Construction (Teammate C / User's Approach)

### 4.1 Overview of the Approach

The user proposes building a model from tuples (Sigma, Lambda, Psi, Tasks) where:
- Sigma is a set of formulas (the "world")
- Lambda is a maximal consistent extension
- Psi is the set of subformulas being tracked
- Tasks record F/P obligations with assigned durations

### 4.2 Step 2 (Boolean Unpacking): Just Lindenbaum Under a Different Name

The user says "boolean unpacking" resolves disjunctions. But resolving disjunctions in a consistent way IS Lindenbaum extension. For each `A or B`, you must choose A or B while maintaining consistency. This is exactly what Lindenbaum's lemma does (using Zorn's lemma or equivalent).

The key question is not WHETHER disjunctions get resolved, but whether the resolution is COMPATIBLE with temporal obligations. And this is precisely where all previous approaches fail.

### 4.3 Step 4 (Task Generation): Does the Process Terminate?

The user claims "this process must end because formulas have finite complexity." But:

1. Step 4 generates tasks from F/P subformulas in the tuple
2. Step 6 propagates G/H formulas, adding NEW formulas to tuples
3. These new formulas may contain F/P subformulas
4. These new F/P subformulas generate NEW tasks (returning to Step 4)

The user performs Step 4 before Step 6, but after Step 6, the formula set has CHANGED. The construction must iterate Steps 4 and 6 until a fixed point is reached. Does this iteration terminate?

**It does terminate** if we restrict to subformulas of the original goal. The subformula closure is finite, so only finitely many new formulas can appear. But the argument needs to be made carefully: G(chi) propagation adds chi, which is a subformula, and chi's F/P subformulas are also subformulas of the original goal.

This is correct but not the hard part.

### 4.4 Step 5 (Transitive Closure): The Duration Consistency Problem

Task(A, x, B) means "starting from tuple A, after x time steps, we reach tuple B." The transitive closure requires:

If Task(A, x, B) and Task(B, y, C), then Task(A, x+y, C).

**The danger**: What if Task(A, x1, B) and Task(A, x2, B) with x1 != x2? Then the same pair (A, B) has two different durations. The transitive closure may then produce Task(A, x1+y, C) and Task(A, x2+y, C) for different total durations reaching C.

This is not inherently contradictory -- it just means there are multiple paths. But when we try to build a LINEAR model (a function from Z to tuples), we must assign a SINGLE time to each tuple. If tuple B must be both x1 steps and x2 steps after tuple A, and B appears at some time t_B, then t_A must be both t_B - x1 and t_B - x2, which is impossible if x1 != x2.

### 4.5 Step 7 (Duration Resolution): The Actual Hard Part

The user acknowledges this is "the hard part." Let me be specific about what makes it hard.

Given a set of tasks Task(A_i, x_i, B_i), we need to find an embedding f: Tuples -> Z such that:
- f(B_i) - f(A_i) = x_i for all tasks
- The temporal ordering constraints are satisfied

This is a system of difference constraints. Such systems are solvable iff the constraint graph has no negative-weight cycles.

**Can negative-weight cycles arise?** Consider:
- Task(A, 2, B): f(B) = f(A) + 2
- Task(B, 3, C): f(C) = f(B) + 3 = f(A) + 5
- Task(C, -6, A): f(A) = f(C) - 6 = f(A) + 5 - 6 = f(A) - 1

This gives f(A) = f(A) - 1, a contradiction. But can such cycles arise from the construction? Tasks come from F/P obligations: Task(A, x, B) where x > 0 (F-tasks) or x < 0 (P-tasks). A cycle of F-tasks (all positive durations) cannot have negative total weight. But a cycle mixing F-tasks and P-tasks could.

**The real question**: Does the consistency of the initial MCS guarantee that the difference constraint system is satisfiable? This is NOT obvious and would need a detailed proof. The user's construction assumes it can be done but does not prove it.

### 4.6 The Ordering Problem

Even if individual difference constraints are satisfiable, the embedding must also satisfy:
- If G(chi) in tuple A at time t, then chi in tuple at time s for all s >= t
- If Until(phi, psi) in tuple A at time t, then there exists s > t with psi in tuple at s and phi in all intermediate tuples

These are NOT difference constraints -- they are universal and existential constraints over infinite intervals. The finite tuple set must be "unrolled" into an infinite Z-indexed model, and the unrolling must preserve these quantified properties.

This is where the approach reconnects to the original problem. The unrolling from finite tuples to Z is essentially building a model from MCS-like objects -- which is exactly the completeness proof we're trying to construct.

### 4.7 Verdict

The tuple-based construction is a plausible framework but **relocates the fundamental difficulty to Step 7 (duration resolution) without solving it**. The hard mathematical content -- showing that temporal obligations can be simultaneously satisfied in a linear model over Z -- is exactly the content of the forward_F proof. The approach provides a different organizational structure but does not provide a new mathematical insight that breaks the circularity.

**Probability of success: 25-35%.** The approach could work if the duration constraint system is provably satisfiable (which requires showing that MCS consistency implies constraint graph acyclicity), but this has not been demonstrated.

---

## 5. The Fundamental Obstacle

### 5.1 What Is Really Going On

The fundamental obstacle is a gap between two levels of reasoning:

- **Meta-level**: "For all s > t, neg(psi) in chain(s)" -- a statement in the metalanguage about set membership at every position
- **Object-level**: "G(neg(psi)) in chain(t)" -- a statement about a SPECIFIC formula being a member of a SPECIFIC set

Converting meta-level universal quantification to object-level G-membership is the heart of the problem. In standard completeness proofs, this conversion is justified by the "Truth Lemma" -- but the Truth Lemma ASSUMES temporal coherence (including forward_F), creating the circularity.

### 5.2 Why This Is Not a Bug -- It Is the Actual Mathematical Content

The theorem IS true (soundness is sorry-free, so the logic is sound, and the semantic argument works). The difficulty is purely in the SYNTACTIC direction: showing that the proof system is strong enough to derive all valid formulas.

The content of the forward_F proof is essentially: "the discrete TM proof system with Until Induction is strong enough to prevent infinite deferral of F-obligations." This is a non-trivial property of the axiom system, not a trivial consequence of the definitions.

### 5.3 Is There a Published Proof for Exactly This Logic?

I have carefully checked the references cited in the codebase and reports:

- **Burgess (1984)**: Proves completeness for tense logic with Until/Since over REFLEXIVE semantics. Does NOT use strict Until with reflexive G.
- **GHR (1994)**: Proves completeness for temporal logic with Until/Since, but again with uniform semantics (either all strict or all reflexive). The quasimodel construction assumes detour-compatible Until propagation.
- **Reynolds (2003)**: Hierarchical completeness for propositional temporal logic. Uses induction on formula complexity, which works because neg(neg(psi)) is identified with psi at the formula level.
- **Goldblatt (1992)**: Standard textbook treatment. Reflexive semantics throughout.
- **Venema (2007)**: Handbook chapter. Does not specifically address the mixed strict-Until / reflexive-G combination.

**No published proof covers exactly TM's mixed semantics** (reflexive G/H with strict U/S over Z with S5 modal). This combination appears to be novel to this project.

### 5.4 Is the Logic Actually Complete?

Yes, almost certainly. The semantic argument works: if F(psi) is at time t in any model, then psi must occur at some s > t (by the semantics of F under reflexive interpretation, F(psi) = neg(G(neg(psi))) means not all s >= t have neg(psi), so some s >= t has psi; since G is reflexive, this includes s = t; but F(psi) specifically means psi at some s > t under... wait).

Actually, let me re-check the semantics carefully:

```
G(phi) at t  iff  for all s >= t, phi at s    (reflexive)
F(phi) at t  iff  neg(G(neg(phi))) at t
             iff  not (for all s >= t, neg(phi) at s)
             iff  exists s >= t, phi at s       (REFLEXIVE F!)
```

So `F(phi)` includes the possibility that phi holds at t ITSELF. But:

```
(top U psi) at t  iff  exists s > t, psi at s and for all r with t < r < s, top at r
                  iff  exists s > t, psi at s     (STRICT Until)
```

So `F(psi)` is WEAKER than `top U psi`:
- `F(psi)` says: psi at some s >= t (includes present)
- `(top U psi)` says: psi at some s > t (strictly future)

The axiom `F_until_equiv: F(psi) -> (top U psi)` converts reflexive-F to strict-Until. Is this sound?

`F(psi)` at t means exists s >= t with psi(s). If s > t, then `top U psi` holds (take witness s). If s = t, then psi holds now, and we need a STRICTLY FUTURE witness for Until. But psi now does NOT guarantee psi in the strict future.

**WAIT -- Is `F_until_equiv` sound under the current mixed semantics?**

If `F(psi)` holds and the witness is s = t (psi at t), then `(top U psi)` needs psi at some s > t. But we only have psi at t, not at any s > t.

Let me re-read the axiom file... The comment says:

> Semantically valid because both express "psi holds at some future time >= t"

But Until uses STRICT `t < s`, so they do NOT express the same thing. `F(psi)` says psi at some s >= t. `(top U psi)` says psi at some s > t.

**THIS IS A POTENTIAL SOUNDNESS BUG.** If `F_until_equiv` is unsound, that would be a fundamental issue.

However, Report 28 Section 5.4 already identified this: "Under mixed semantics (reflexive G/H, strict U/S): F(psi) = neg(G(neg(psi))) means psi at some s >= t (includes present). (top U psi) means psi at some s > t (strict future only). So F(psi) -> (top U psi) is FALSE when the F-witness is t itself."

But then the report says: "F_until_equiv unsoundness is primarily a SOUNDNESS problem." And Report 29 Section 3.6 says the scoped impact is that within the syntactic completeness proof, F_until_equiv is valid because it is an axiom of the proof system.

Wait -- if `F_until_equiv` is unsound, then the logic itself has unsound axioms, which means the completeness theorem is vacuously easier (more formulas are provable than valid, so there are fewer valid-but-unprovable formulas). But it also means the soundness theorem has a bug.

Let me check if soundness is truly sorry-free for this axiom...

Actually, the key question is: does the codebase's `Soundness.lean` prove `F_until_equiv` sound? If the soundness proof is sorry-free and proves all axioms sound, then either `F_until_equiv` IS sound (and my analysis above is wrong), or the soundness proof has a subtle error.

The most likely resolution: F might be defined differently than I think. Let me check. In the axiom file, `F(psi) = some_future psi = neg(all_future(neg(psi)))`. And `all_future` uses `>=` (reflexive). So `F(psi)` at t means exists s >= t with psi(s). This DOES include s = t.

But `(top U psi)` requires s > t strictly. So `F(psi) -> (top U psi)` requires: if psi at some s >= t, then psi at some s > t. This is NOT valid in general (psi could hold only at t).

HOWEVER -- there is the `seriality_future` axiom: `neg(G(bot))`, which says there exists some s >= t with neg(bot) = top. Under reflexive semantics, this is trivially true (s = t works). So seriality does not help.

There is also `discreteness_forward`: which ensures next steps exist. And `disc_next`: F(top) -> X(top), meaning if there is any future time, there is a next time.

**Critical check needed**: Is `F_until_equiv` actually sound in the task frame semantics? The soundness proof being sorry-free would confirm this. Let me trace the soundness proof.

Actually, on reflection, I think the resolution may be that Under the FULL axiom system (including seriality, discreteness, Until introduction), `F(psi) -> (top U psi)` IS derivable even without being an axiom, because:
- `F(psi)` means exists s >= t with psi(s)
- If s = t: psi holds now. By discreteness, time t+1 exists. By `temp_a`, `psi -> G(P(psi))`, so at t+1 we have `P(psi)`. But P(psi) means psi at some s <= t+1, which includes t. This does not give us psi at t+1.

Actually, F(psi) -> (top U psi) may be valid specifically because of how it interacts with discreteness: in a discrete order, if F(psi) holds at t, there's some s >= t with psi(s). If s > t, we have the strict future witness. If s = t, we need to show (top U psi) at t. Under reflexive semantics with T-axiom, G(phi) at t includes phi at t. So F(psi) at t with witness s = t means psi at t. For (top U psi) to hold at t, we need some s > t with psi(s) -- which we DON'T have.

So I maintain that F_until_equiv may be unsound under the current semantics. But the soundness proof IS sorry-free. This means either:
1. I'm making an error in my analysis
2. The soundness proof has a subtle bug that passes Lean's type checker
3. The semantics of F is different than I think

**CONFIRMED**: I checked `Soundness.lean` and found that `F_until_equiv_valid` (line 757) has a `sorry` at line 770. The comment reads: "SEMANTIC GAP: Under reflexive semantics, F(psi) includes present but Until requires strict future. This axiom is not valid under the new semantics when the only witness is the present time."

Furthermore, `P_since_equiv_valid` has the same sorry at line 786.

**This means `F_until_equiv` IS unsound under the current mixed semantics.** The axiom is in the proof system but cannot be proven sound. This has cascading implications:

1. The `F_to_until_in_chain` theorem in `FiniteDeferral.lean` (which converts F(psi) to (top U psi)) relies on this unsound axiom. If we remove the axiom, this conversion fails, and the entire finite deferral approach collapses.

2. The completeness proof, even if we close forward_F, would prove completeness with respect to a proof system that includes an unsound axiom. The completeness theorem would state "if phi is valid in all discrete task models, then phi is provable" -- but the proof system proves MORE than what is valid (because it includes an unsound axiom). So the completeness direction (valid implies provable) would be trivially true (anything valid is provable since even invalid things are provable). But SOUNDNESS (provable implies valid) would be FALSE.

3. **The forward_F problem may be an artifact of the unsound axiom.** With F_until_equiv, the proof system derives things like "F(psi) implies (top U psi)," which may not be semantically true. The forward_F theorem says that if F(psi) is in the chain, then psi appears at some strictly future position. But if F(psi) only means "psi at some s >= t" (including t), then psi at t should be sufficient -- but it is NOT sufficient for the UNTIL formula (top U psi) derived via F_until_equiv.

**This is potentially THE fundamental issue.** The mixed semantics creates an inconsistency between the reflexive F operator and the strict Until operator, and `F_until_equiv` papers over it with an unsound axiom. The forward_F problem may be a symptom of this deeper issue.

**Recommendation**: Before continuing with ANY approach to forward_F, resolve the F_until_equiv soundness issue. Options:
- (a) Make Until reflexive (exists s >= t) to match F -- this makes F_until_equiv sound
- (b) Make G/H strict (s > t / s < t) to make F strict -- then F and Until both use strict future
- (c) Remove F_until_equiv and find an alternative completeness strategy that does not convert between F and Until
- (d) Add a stronger seriality axiom that ensures: if F(psi) holds, then psi holds at some STRICTLY future time (this would make F effectively strict even though G is reflexive)

---

## 6. A Potentially Viable Path: Direct Until Induction Without G(neg psi)

### 6.1 The Key Observation

The `until_induction` axiom is:
```
G(psi -> chi) and G((phi and X(chi)) -> chi) -> ((phi U psi) -> X(chi))
```

The existing approach instantiates with chi = bot, getting:
```
G(psi -> bot) and G((phi and X(bot)) -> bot) -> ((phi U psi) -> X(bot))
```

This requires `G(neg(psi)) in chain(t)`, which requires backward_G, which requires forward_F.

### 6.2 Alternative Instantiation

What if we choose chi more carefully? Specifically, let chi = (top U psi). Then:

```
G(psi -> (top U psi)) and G((top and X(top U psi)) -> (top U psi)) -> ((top U psi) -> X(top U psi))
```

Premise 1: `G(psi -> (top U psi))`. Is this in chain(t)?

`psi -> (top U psi)` is NOT generally derivable under strict semantics. `psi` at time s does not imply `(top U psi)` at time s, because `(top U psi)` requires a STRICTLY FUTURE witness. (`psi` now does not give a strictly future time with psi.)

Wait -- actually, there IS `until_intro`: `X(psi or (phi and (phi U psi))) -> (phi U psi)`. If psi holds now, then at the previous time, `X(psi or ...)` holds, giving `(phi U psi)` at the previous time. But we need `(top U psi)` at the CURRENT time, not the previous time.

Under reflexive G: `G(psi -> (top U psi))` means for all s >= t, `psi -> (top U psi)` at s. Since this is not derivable, premise 1 fails.

### 6.3 Another Instantiation: chi = neg(top U psi)

Let chi = neg(top U psi). Then:

```
G(psi -> neg(top U psi)) and G((top and X(neg(top U psi))) -> neg(top U psi)) -> ((top U psi) -> X(neg(top U psi)))
```

Premise 1: `G(psi -> neg(top U psi))`. This says: at all future times, psi implies not(top U psi). Under our assumption that psi never appears (for the contradiction), this is vacuously true at all future times. But we need it IN THE MCS, not just semantically true. Since psi not in chain(s) for s > t means neg(psi) in chain(s), we have `psi -> anything` is in chain(s) (by ex falso from psi and neg(psi)). So `psi -> neg(top U psi)` is in chain(s) for all s > t.

But we need `G(psi -> neg(top U psi)) in chain(t)`, which requires the meta-to-object conversion again.

### 6.4 The Finite Periodic Approach (Restated)

Despite Report 29 dismissing the cycle approach, there IS a potentially viable variant:

**Key idea**: Instead of building a full truth lemma for the periodic model, use the cycle to construct a FINITE derivation.

Given the pigeonhole cycle with positions i < j where restrictedTheory(t+i) = restrictedTheory(t+j):

1. Let k = j - i (cycle length)
2. neg(psi) in chain(t+r) for ALL r >= 1
3. (top U psi) in chain(t+r) for ALL r >= 0
4. The restricted theories repeat with period k starting from position t+i

Now, consider the `until_induction` axiom applied WITHIN the deferral closure. The restricted theory at t+i equals the restricted theory at t+j = t+i+k. This means that WITHIN the deferral closure, the chain has returned to exactly the same state.

The question becomes: can we derive a contradiction from the fact that a restricted theory repeats while (top U psi) persists and psi is absent?

**The answer might be yes** if we can show: the axiom of Until Induction, applied over the FINITE cycle, produces a derivation that contradicts (top U psi) being in the cycle.

Specifically, in the cycle, every formula in deferralClosure that is in chain(t+i) is also in chain(t+i+k) (by restricted theory equality). The CONVERSE also holds. So for any formula chi in deferralClosure:

```
chi in chain(t+i) iff chi in chain(t+i+k) iff chi in chain(t+i+2k) iff ...
```

This periodicity, combined with the x_content linkage, means: for formulas IN the deferral closure, the chain is periodic. And in a periodic chain, any F-obligation that is not resolved within one period is never resolved.

The derivation of the contradiction would go:
1. (top U psi) in chain(t+i) (known)
2. psi not in chain(t+i+r) for any r = 1, ..., k (by assumption)
3. By periodicity, psi not in chain(t+i+r) for any r >= 1
4. Therefore, in the periodic sub-chain, (top U psi) is never resolved
5. But the axioms of TM prevent this...

Step 5 is still the gap. The axioms prevent it SEMANTICALLY (in any model), but we need a SYNTACTIC derivation.

### 6.5 The Real Hope: Finite Model Property Applied to the Cycle

Here is perhaps the most promising angle that has not been fully explored:

The FMP infrastructure in `Decidability/FMP/` is sorry-free. If the FMP can be applied to the restricted periodic model, we get:
1. A finite model where (top U psi) is "true" (in the sense of the FMP truth preservation)
2. psi is false at all positions in this finite model
3. The semantics of Until in the finite model contradicts (1) and (2)

The gap: FMP truth preservation for Until (`TruthPreservation.lean`) may not cover the temporal cases. Let me check.

Actually, the FMP is about showing that if a formula has a model, it has a FINITE model. It goes from "valid in all models" to "valid in all finite models." This is NOT directly about the completeness proof.

### 6.6 Summary: Where the Light Is

The most promising paths, ranked by my assessment:

1. **Direct syntactic cycle contradiction** (30-40%): Use the pigeonhole cycle + a careful instantiation of Until Induction over the FINITE cycle to derive a contradiction without needing full backward_G. This requires a new idea about which chi to use in Until Induction.

2. **Formula quotient approach** (20-30%): Define an equivalence relation on formulas (identifying logically equivalent formulas like psi and neg(neg(psi))), rebuild the key infrastructure over equivalence classes, and then use Reynolds-style induction on F-depth. This is correct in principle but requires enormous refactoring.

3. **Abandon mixed semantics** (40-50% conditional on feasibility): Switch to either fully reflexive or fully strict semantics. Under fully reflexive semantics, published completeness proofs (Burgess 1984) apply directly. Under fully strict semantics, the Reynolds hierarchy applies. The difficulty is that the codebase has been built around mixed semantics and switching would require reworking soundness and many derived theorems.

4. **True quasimodel (NOT the Report 24 version)** (20-30%): Build a completeness proof from scratch using a completely new model construction that does not rely on x_content chains.

---

## 7. Confidence Levels Summary

| Approach | Success Probability | Effort (LOC) | Key Failure Mode |
|----------|-------------------|--------------|------------------|
| Quasimodel (GHR-style, Teammate A) | 20-30% | 2000-4000 | X-vs-G mismatch through detours (proven in Report 24) |
| F-nesting depth induction (Teammate B) | 5-10% | 200-400 | neg(neg(psi)) has same F-depth as psi; no progress |
| Tuple-based construction (Teammate C) | 25-35% | 1500-3000 | Duration constraint satisfaction = forward_F in disguise |
| Decidability path (Report 29) | 0% | N/A | Module uses Classical.em, not real proof extraction |
| Cycle contradiction + novel chi | 30-40% | 500-1000 | Need new idea for Until Induction instantiation |
| Semantic switch to uniform semantics | 40-50% | 2000-5000 | Massive refactoring, possible regression cascade |

---

## 8. Recommendations

### 8.1 Immediate: Verify F_until_equiv Soundness

The potential unsoundness of `F_until_equiv` under mixed semantics (Section 5.5) should be verified or refuted IMMEDIATELY. If it is unsound, the entire axiom system needs revision, which changes the nature of the forward_F problem entirely.

### 8.2 Short-Term: Explore Novel Until Induction Instantiations

Systematically enumerate possible chi instantiations in Until Induction that could work within the finite deferral cycle. The cycle provides a finite context where certain G-statements might be derivable without full backward_G.

### 8.3 Medium-Term: Consider Semantic Unification

If the forward_F problem remains intractable under mixed semantics, seriously consider switching to uniform reflexive semantics (where published proofs exist). The cost is high but the success probability is also high.

### 8.4 Correction to Prior Reports

**Reports 28 and 29 both claim "soundness is sorry-free." This is FALSE.**

`Soundness.lean` contains the following sorries:
- `F_until_equiv_valid` (line 770): sorry with explicit comment about semantic gap
- `P_since_equiv_valid` (line 786): same issue
- `soundness_discrete_valid` (line 1472): sorry for `temporal_duality` case
- `soundness_discrete` (line 1529): same `temporal_duality` sorry
- `soundness` (lines 1182-1206): 25 sorries for all extension axioms
- Multiple additional sorries throughout

The `F_until_equiv` soundness sorry is NOT merely an infrastructure gap -- it reflects a genuine unsoundness of this axiom under the current mixed semantics (reflexive G with strict Until). This is the most critical finding of this analysis.

### 8.5 DO NOT Pursue

- F-nesting depth induction (proven non-viable above)
- Decidability-based completeness (the module is a shell, not a real decision procedure)
- Any approach that requires "neg(neg(psi)) has lower complexity than psi" (false in this formalization)
- Any approach that relies on `F_until_equiv` without first resolving its soundness status
