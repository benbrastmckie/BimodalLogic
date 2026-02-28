# Research Report: Task #916 (Teammate B -- F-Preserving Seed Approach Explained)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-20
**Focus**: Detailed explanation of the F-preserving seed approach, why G-lifting fails for it, and alternative proof techniques
**Agent**: lean-research-agent (teammate B)
**Session**: sess_1771653700_ae70b8

---

## 1. The F-Preserving Seed Approach Explained

### 1.1 The Problem It Addresses

The two remaining sorries in DovetailingChain.lean are `buildDovetailingChainFamily_forward_F` (line 1621) and `buildDovetailingChainFamily_backward_P` (line 1628). These require proving that existential temporal formulas are witnessed: if `F(psi) in chain(t)`, then `psi in chain(s)` for some `s > t`.

The current chain construction builds each step's MCS from a seed:

```
seed(n+1) = GContent(chain(n))                          -- base case (no witness)
seed(n+1) = {psi_n} union GContent(chain(n))            -- witness case (F(psi_n) alive)
```

where `GContent(M) = {phi | G(phi) in M}` (defined in `TemporalContent.lean`, line 19).

The core obstruction is **Lindenbaum opacity**: `set_lindenbaum` uses Zorn's lemma via `Classical.choose` to extend the seed to an MCS. The resulting MCS is a pure existence claim. Beyond the seed, we know nothing about which formulas it contains. In particular, Lindenbaum may add `G(neg(psi))` to the new MCS, which permanently kills `F(psi) = neg(G(neg(psi)))` and propagates forward via the 4-axiom (`G(phi) -> G(G(phi))`).

The chain processes formula `psi` at step `encodeFormula(psi)`. If `F(psi)` is alive at that step, the witness fires and `psi` appears in `chain(encodeFormula(psi) + 1)`. The proven lemma `witnessForwardChain_coverage_of_le` handles the case `encodeFormula(psi) <= n`. But for the general `forward_F`, when `F(psi) in chain(n)` and `encodeFormula(psi) > n`, `F(psi)` must **persist** through `n+1, n+2, ..., encodeFormula(psi)` -- and Lindenbaum can kill it at any intermediate step.

### 1.2 The Core Idea

The F-preserving seed approach modifies the chain seed at each step to include all live F-formulas from the predecessor:

```
seed(n+1) = GContent(chain(n)) union {F(chi) : F(chi) in chain(n)} union {psi_n if witnessing}
```

Define the **FContent** of an MCS:

```
FContent(M) = {F(chi) : F(chi) in M} = {neg(G(neg(chi))) : neg(G(neg(chi))) in M}
```

Then the seed becomes `GContent(M) union FContent(M) union {psi_n}`.

The key property: since `GContent(M) subset M` (via the T-axiom: `G(phi) -> phi`) and `FContent(M) subset M` (by definition), their union is a subset of M and hence consistent (as a subset of a consistent set). The issue is whether adding the witness `psi_n` preserves consistency.

### 1.3 Why It Resolves Persistence

If the extended seed is consistent and Lindenbaum is applied to it, the resulting MCS contains:

1. **All GContent formulas** -- ensuring forward_G propagation (the G-content seed mechanism)
2. **All FContent formulas** -- ensuring F-formula persistence
3. **The witness psi_n** -- ensuring the one-shot witness mechanism works

Because `F(chi) = neg(G(neg(chi)))` is in the seed, Lindenbaum **cannot** add `G(neg(chi))` to the resulting MCS. Adding `G(neg(chi))` to a set already containing `neg(G(neg(chi)))` produces an inconsistent set, and Lindenbaum (whether Zorn-based or constructive) only extends to consistent supersets. Therefore, `F(chi)` is guaranteed to survive into the next MCS.

By induction on the chain steps: if `F(psi) in chain(n)`, then `F(psi)` is in the seed for `chain(n+1)`, so `F(psi) in chain(n+1)`. Repeating this, `F(psi) in chain(k)` for all `k >= n`. In particular, `F(psi) in chain(encodeFormula(psi))`, so the witness fires and `psi in chain(encodeFormula(psi) + 1)`.

This eliminates the persistence gap entirely.

### 1.4 What Changes in the Codebase

The modification is localized to the chain definition `dovetailForwardChainMCS` (lines 519-537 in DovetailingChain.lean). Currently:

```lean
noncomputable def dovetailForwardChainMCS ... :
    Nat -> { M : Set Formula // SetMaximalConsistent M }
  | 0 => sharedBaseMCS base h_base_cons
  | n + 1 =>
    let prev := dovetailForwardChainMCS base h_base_cons n
    match decodeFormula n with
    | none =>
      let h_gc := dovetail_GContent_consistent prev.val prev.property
      let h := set_lindenbaum (GContent prev.val) h_gc
      ...
    | some psi =>
      if h_F : Formula.some_future psi in prev.val then
        let h_seed := forward_temporal_witness_seed_consistent prev.val prev.property psi h_F
        let h := set_lindenbaum (ForwardTemporalWitnessSeed prev.val psi) h_seed
        ...
      else
        let h_gc := dovetail_GContent_consistent prev.val prev.property
        let h := set_lindenbaum (GContent prev.val) h_gc
        ...
```

The modified version would replace every seed with:

```
seed = GContent(prev.val) union FContent(prev.val) union {psi_n if witnessing}
```

This requires a new seed definition (`FPreservingSeed` or similar), a new consistency lemma, and updates to the Lindenbaum calls. Approximately 60-70% of existing lemmas transfer with minor signature adjustments (they depend on `GContent subset chain(n+1)`, which remains true since `GContent` is a subset of the extended seed).

---

## 2. The Consistency Conjecture

### 2.1 Precise Statement

**Conjecture**: If M is an MCS with `F(psi) in M`, then:

```
{psi} union GContent(M) union {F(chi) : F(chi) in M, chi != psi}
```

is consistent.

Equivalently (since `F(psi) in M` and we can include it):

```
{psi} union GContent(M) union FContent(M)
```

is consistent, where `FContent(M) = {F(chi) : F(chi) in M}`.

Note: `F(psi) in FContent(M)` already, and `{psi, F(psi)}` is consistent (F(psi) = neg(G(neg(psi))) says "not always neg(psi)", which is compatible with psi being true). So the conjecture can be stated with or without the exclusion `chi != psi`.

### 2.2 Why the Conjecture Is Plausible

**Argument 1 (Subset of M plus psi)**: The set `GContent(M) union FContent(M)` is a subset of M (GContent via T-axiom, FContent by definition). It is therefore consistent. Adding `psi` to a consistent set might introduce inconsistency, but only if the existing set derives `neg(psi)`. We know from `forward_temporal_witness_seed_consistent` that `GContent(M)` alone does not derive `neg(psi)`. The question is whether the addition of `FContent(M)` enables a derivation of `neg(psi)` that was previously impossible.

**Argument 2 (Independence heuristic)**: F-formulas are of the form `neg(G(neg(chi)))`. These are NEGATIVE statements about G-formulas -- they say "G(neg(chi)) is not the case", i.e., "it is not the case that neg(chi) holds at all future times". These negative statements are logically independent of GContent formulas (which are positive: "phi holds because G(phi) holds"). Adding negative G-information to positive G-information should not, in general, enable new derivations about an unrelated formula psi.

**Argument 3 (No counterexample found)**: Despite extensive analysis across 5 research rounds and 3 independent teammates, no concrete counterexample has been constructed. A counterexample would require an MCS M, a formula psi with F(psi) in M, and a finite derivation from GContent formulas plus F-formulas to neg(psi).

### 2.3 Why the Conjecture Might Be False

**Concern 1 (Interaction via axioms)**: The temporal axioms create non-trivial relationships between formulas. For instance, `temp_a: phi -> G(P(phi))` connects arbitrary formulas to G-formulas. Through chains of axiom applications, GContent formulas and F-formulas could interact in ways that derive neg(psi).

**Concern 2 (Specificity)**: The conjecture asks about ALL MCSes M simultaneously. Even if it holds for "generic" MCSes, there might be pathological MCSes with specific formula combinations that create inconsistency.

**Concern 3 (Non-trivial seed size)**: FContent(M) can be infinite (there are infinitely many F-formulas in a typical MCS). While consistency is a finitary notion (an inconsistency requires a finite derivation, hence finitely many formulas from the seed), the infinite potential seed makes exhaustive analysis difficult.

---

## 3. Why G-Lifting Fails

### 3.1 The G-Lifting Technique

The existing proof of `forward_temporal_witness_seed_consistent` (lines 398-459 in DovetailingChain.lean) uses a technique I call **G-lifting**. Here is the structure:

1. **Assume inconsistency**: Suppose `{psi} union GContent(M)` is inconsistent, so some finite `L subset {psi} union GContent(M)` derives bot.

2. **Separate psi**: Partition L into `{psi}` (if present) and `L_filt` (formulas from GContent). By the deduction theorem: `L_filt derives neg(psi)`.

3. **G-lift**: Apply `generalized_temporal_k` to get `G(L_filt) derives G(neg(psi))`, where `G(L_filt) = [G(chi_1), ..., G(chi_k)]` maps each `chi_i` to `G(chi_i)`.

4. **Close in M**: Since each `chi_i in GContent(M)`, we have `G(chi_i) in M` by definition. By MCS closure under derivation: `G(neg(psi)) in M`.

5. **Contradict**: `F(psi) = neg(G(neg(psi))) in M` and `G(neg(psi)) in M` contradicts MCS consistency.

The crucial step is Step 3: `generalized_temporal_k` transforms `[chi_1, ..., chi_k] derives phi` into `[G(chi_1), ..., G(chi_k)] derives G(phi)`. This works because:

- `generalized_temporal_k` (defined in `GeneralizedNecessitation.lean`, line 152) is built by induction on the context: it uses the deduction theorem to extract each hypothesis, applies temporal necessitation, and then uses `temp_k_dist: G(phi -> psi) -> (G(phi) -> G(psi))` to re-introduce it.

- The key property: for each `chi_i in L_filt`, we know `chi_i in GContent(M)`, which by definition means `G(chi_i) in M`. So after G-lifting, all hypotheses `G(chi_i)` are in M.

### 3.2 Where G-Lifting Fails for the Extended Seed

Now consider the extended seed `{psi} union GContent(M) union FContent(M)`. Suppose this is inconsistent. Some finite `L` subset of the seed derives bot. After separating psi by deduction: `L_filt derives neg(psi)`, where `L_filt` contains formulas from both GContent(M) and FContent(M).

Partition `L_filt` into:
- `L_G = {chi_1, ..., chi_k}` -- formulas from GContent(M), meaning `G(chi_i) in M`
- `L_F = {F(alpha_1), ..., F(alpha_m)}` -- formulas from FContent(M), where `F(alpha_j) = neg(G(neg(alpha_j))) in M`

The derivation is: `[chi_1, ..., chi_k, F(alpha_1), ..., F(alpha_m)] derives neg(psi)`.

Attempt to G-lift: apply `generalized_temporal_k` to get:

```
[G(chi_1), ..., G(chi_k), G(F(alpha_1)), ..., G(F(alpha_m))] derives G(neg(psi))
```

**Step 4 fails here.** For the GContent formulas, `G(chi_i) in M` by definition -- this works. But for the F-formulas, we would need:

```
G(F(alpha_j)) = G(neg(G(neg(alpha_j)))) in M
```

This requires `F(alpha_j) -> G(F(alpha_j))` to be derivable, i.e., `neg(G(neg(alpha_j))) -> G(neg(G(neg(alpha_j))))`. This is exactly the principle **F -> GF**, which states that if a formula is eventually true, then it is always eventually true.

**F -> GF is NOT derivable in TM logic with reflexive temporal semantics.** Semantically, `F(phi)` says "phi holds at some time >= t". If phi holds at exactly time t (the present), then at time t+1, `F(phi)` requires phi to hold at some time >= t+1, which is not guaranteed. So `F(phi)` can hold at t without holding at t+1, making `G(F(phi))` (phi holds at all times >= t and for each such time there is a further time where phi holds) a strictly stronger statement.

This was confirmed by Teammate A (research-005, Section 2.4), Teammate C (research-005, Section 3.1), and research-003-teammate-c (earlier round).

### 3.3 The Failure Is Fundamental, Not Technical

The G-lifting failure is not an artifact of the specific proof strategy -- it reflects a genuine structural asymmetry in the logic:

- **G-formulas are G-liftable**: If `chi in GContent(M)`, then `G(chi) in M`. The definition of GContent ensures this. G-lifting can always "wrap" GContent formulas in G.

- **F-formulas are NOT G-liftable**: `F(chi) in M` does NOT imply `G(F(chi)) in M`. F-formulas contain NEGATIVE information about G (they assert the absence of a G-formula). G-lifting requires mapping each hypothesis to a G-wrapped version that is provably in M, and this mapping does not exist for F-formulas.

The proof technique for `forward_temporal_witness_seed_consistent` fundamentally relies on the fact that ALL non-psi formulas in the seed are from GContent. The technique cannot extend to seeds containing formulas outside GContent, regardless of how the proof is restructured.

### 3.4 Formal Summary of the Obstruction

Let `M` be an MCS, `psi` a formula with `F(psi) in M`.

**What works**: `{psi} union GContent(M)` is consistent.
- Proof: Suppose inconsistent. By deduction, `GContent(M) derives neg(psi)`. G-lift: `{G(chi) : chi in GContent(M)} derives G(neg(psi))`. Each `G(chi) in M`. By MCS closure, `G(neg(psi)) in M`. Contradicts `F(psi) in M`. QED.

**What fails**: `{psi} union GContent(M) union FContent(M)` is consistent.
- Attempted proof: Suppose inconsistent. By deduction, `GContent(M) union FContent(M) derives neg(psi)`. G-lift: `{G(chi) : chi in GContent(M)} union {G(F(alpha)) : F(alpha) in FContent(M)} derives G(neg(psi))`. For `G(chi)`, we have `G(chi) in M`. But for `G(F(alpha))`, we need `G(F(alpha)) in M`, which requires `F -> GF`. **BLOCKED.**

---

## 4. Alternative Proof Techniques

### 4.1 Semantic/Model-Theoretic Argument

**Idea**: Instead of proving consistency syntactically (showing no derivation of bot exists), construct a Kripke model satisfying the seed and appeal to soundness.

**Approach**: Given MCS M with F(psi) in M, construct a Kripke model (W, R, V) and a world w such that:
- w satisfies psi
- w satisfies all of GContent(M)
- w satisfies all of FContent(M)

If such a model exists, then `{psi} union GContent(M) union FContent(M)` is satisfiable, hence consistent (by soundness).

**Construction sketch**: Since M is an MCS, it has a model by existing completeness results (the sorry-free `bmcs_representation` theorem gives a BMCS model for M). In this model, let w0 be the world corresponding to M. Since `F(psi) in M`, there exists a world w1 with `w0 R w1` and `psi` true at w1. Does w1 satisfy GContent(M) and FContent(M)?

- **GContent(M) at w1**: For each `chi in GContent(M)`, we have `G(chi) in M`, so chi holds at ALL R-successors of w0, including w1. Yes, GContent(M) is satisfied at w1.

- **FContent(M) at w1**: For each `F(alpha) in M`, is `F(alpha)` true at w1? F(alpha) at w0 means there exists w2 with `w0 R w2` and alpha at w2. But `F(alpha)` at w1 requires a w3 with `w1 R w3` and alpha at w3. These are different existence claims. There is no guarantee that the witness w2 for w0 is accessible from w1.

**The problem**: F-formulas at w0 do not automatically transfer to F-formulas at w1. This is exactly the `F -> GF` non-derivability, now stated model-theoretically.

**Refinement**: Instead of using w1 (the F(psi) witness), look for a world w that is an R-successor of w0 AND satisfies F(alpha) for all F(alpha) in M. In the canonical model (all MCSes as worlds), such a world would be an MCS extending `{psi} union GContent(M) union FContent(M)`. But the existence of such an MCS is precisely what we are trying to prove.

**Assessment**: The semantic approach recasts the problem in model-theoretic language but does not avoid the core difficulty. The argument becomes circular: we need the consistency conjecture to find the model, and we want the model to prove the consistency conjecture.

### 4.2 Compactness + Pairwise Consistency Argument

**Idea**: Show that every FINITE subset of `{psi} union GContent(M) union FContent(M)` is consistent, and appeal to compactness (which is trivially satisfied here since derivations are already finitary).

**Approach**: Show that for any finite `S = {psi, chi_1, ..., chi_k, F(alpha_1), ..., F(alpha_m)}` where chi_i in GContent(M) and F(alpha_j) in FContent(M), the set S is consistent.

**Key insight**: All formulas in S except psi are in M (GContent formulas are in M via T-axiom, FContent formulas are in M by definition). So `{chi_1, ..., chi_k, F(alpha_1), ..., F(alpha_m)} subset M` is consistent (as a subset of a consistent set).

Now, can adding psi make this inconsistent? If so, then `{chi_1, ..., chi_k, F(alpha_1), ..., F(alpha_m)} derives neg(psi)`. Since all hypothesis formulas are in M and M is an MCS closed under derivation: `neg(psi) in M`.

**Now the argument branches:**

**Branch A**: Show directly that `neg(psi) not in M` when `F(psi) in M`. But this is FALSE in general. `neg(psi) in M` and `F(psi) in M` can coexist: "psi is false now but will be true at some future time." This is the whole point of `F` -- it talks about future times, not the present.

**Branch B**: Show that `neg(psi)` cannot be derived from the finite subset `{chi_1, ..., chi_k, F(alpha_1), ..., F(alpha_m)}` even though `neg(psi)` may be in M. This is a more refined claim: the SPECIFIC derivation path must go through the finite subset, and we need to show no such path exists.

The difficulty with Branch B: the finite subset is a subset of M, and M does contain `neg(psi)` (potentially). So the formulas `{chi_1, ..., chi_k, F(alpha_1), ..., F(alpha_m)}` together with all of M's formulas DO derive `neg(psi)`. The question is whether the FINITE subset alone suffices.

**Analysis of derivation structure**: If `{chi_1, ..., chi_k, F(alpha_1), ..., F(alpha_m)} derives neg(psi)`, then there is a derivation tree using only these formulas as assumptions plus axioms and inference rules. The derivation could use:
- Propositional reasoning (prop_k, prop_s, peirce, ex_falso)
- Modal axioms (modal_t, modal_4, etc.)
- Temporal axioms (temp_k_dist, temp_4, temp_a, temp_t_future, etc.)
- Modus ponens
- Temporal/modal necessitation (only on theorems, not on hypotheses)

The F-formulas `F(alpha_j) = neg(G(neg(alpha_j)))` interact with G-formulas through the temporal axioms. The question is whether these interactions can produce neg(psi).

**Key observation**: The G-lifting proof fails because it tries to apply `generalized_temporal_k` to the ENTIRE derivation. But maybe we can apply it to a SUBDERIVATION -- the part that only uses GContent formulas -- and handle the F-formulas separately.

### 4.3 Partial G-Lifting with F-Formula Elimination

**Idea**: Instead of G-lifting the entire derivation, analyze its structure to separate GContent and FContent contributions.

**Approach**: Suppose `{chi_1, ..., chi_k, F(alpha_1), ..., F(alpha_m)} derives neg(psi)`. By the deduction theorem applied repeatedly, we can extract the F-formulas:

```
{chi_1, ..., chi_k} derives F(alpha_1) -> (F(alpha_2) -> ... -> (F(alpha_m) -> neg(psi))...)
```

Let `Phi = F(alpha_1) -> (F(alpha_2) -> ... -> (F(alpha_m) -> neg(psi))...)`. Then `{chi_1, ..., chi_k} derives Phi`.

Now G-lift: `{G(chi_1), ..., G(chi_k)} derives G(Phi)`. All `G(chi_i) in M` by definition of GContent. By MCS closure: `G(Phi) in M`.

By the T-axiom: `G(Phi) -> Phi`, so `Phi in M`.

`Phi = F(alpha_1) -> (F(alpha_2) -> ... -> (F(alpha_m) -> neg(psi))...)`. Since `F(alpha_1) in M`, by modus ponens: `F(alpha_2) -> ... -> (F(alpha_m) -> neg(psi))... in M`. Repeating for all F-formulas: `neg(psi) in M`.

So we have shown: if `{psi} union GContent(M) union FContent(M)` is inconsistent, then `neg(psi) in M`.

**But we already knew this!** If any subset of M derives `neg(psi)`, and M is closed under derivation, then `neg(psi) in M`. The question is whether `neg(psi) in M` leads to a contradiction.

**Does it?** We have `F(psi) in M`, and potentially `neg(psi) in M`. These are consistent: "psi is false now, but true at some future time." So `neg(psi) in M` does NOT contradict `F(psi) in M`.

**But** we also proved that `{psi} union GContent(M)` is consistent (the existing lemma). If `neg(psi) in M`, does that contradict `{psi} union GContent(M)` being consistent? No! `neg(psi) in M` but `neg(psi)` might not be in `GContent(M)`. For `neg(psi) in GContent(M)`, we would need `G(neg(psi)) in M`, but `F(psi) in M` means `G(neg(psi)) not in M`. So `neg(psi)` is NOT derivable from GContent(M) alone, which is exactly what `forward_temporal_witness_seed_consistent` proves.

**The gap**: We showed that if the extended seed is inconsistent, then `neg(psi)` is derivable from `GContent(M) union FContent(M)`. We know it is NOT derivable from `GContent(M)` alone. The question is whether FContent(M) provides the extra derivation power to reach `neg(psi)`.

This is the SAME question restated. The partial G-lifting technique does not break the circularity.

### 4.4 Direct Derivation-Theoretic Analysis

**Idea**: Analyze what kinds of formulas can be derived from `GContent(M) union FContent(M)` to show `neg(psi)` cannot be among them.

**Approach**: Characterize the deductive closure of `GContent(M) union FContent(M)`.

GContent(M) consists of formulas chi such that `G(chi) in M`. These formulas have no specific syntactic form -- chi can be any formula.

FContent(M) consists of formulas `neg(G(neg(alpha)))` for various alpha. These have a specific syntactic form: they are negations of G-formulas.

The question is: what new derivations does adding `{neg(G(neg(alpha_j)))}` to a set of arbitrary formulas enable?

In propositional logic, adding `neg(A)` to a context enables reasoning about A being false. Specifically, if the context already derives `A`, then adding `neg(A)` produces inconsistency. But if A is not derivable, `neg(A)` is "inert" in the sense that it only blocks derivations that would otherwise produce A.

Here, `A_j = G(neg(alpha_j))`. Can `GContent(M)` derive `G(neg(alpha_j))`? If `neg(alpha_j) in GContent(M)`, i.e., `G(neg(alpha_j)) in M`, then yes. But `G(neg(alpha_j)) in M` contradicts `F(alpha_j) in M` (since `F(alpha_j) = neg(G(neg(alpha_j)))`). So `neg(alpha_j) not in GContent(M)`, meaning `GContent(M)` does NOT contain `neg(alpha_j)`, hence does NOT trivially derive `G(neg(alpha_j))`.

However, `GContent(M)` might derive `G(neg(alpha_j))` through a chain of axiom applications. For instance, if `GContent(M)` contains formulas from which `neg(alpha_j)` is derivable, then by G-lifting, `G(neg(alpha_j))` is derivable from `{G(chi) : chi in GContent(M)}`, and by T-axiom collapse, from GContent(M) plus a G-lifting step. But actually, if `GContent(M) derives neg(alpha_j)`, then by G-lifting `{G(chi) : chi in GContent(M)} derives G(neg(alpha_j))`, and all `G(chi) in M`, so `G(neg(alpha_j)) in M`, contradicting `F(alpha_j) in M`.

**Therefore**: `GContent(M)` does NOT derive `neg(alpha_j)` for any `F(alpha_j) in FContent(M)`.

This means `G(neg(alpha_j))` is NOT derivable from `GContent(M)`. Adding `neg(G(neg(alpha_j)))` to GContent(M) does not create the pattern `{A, neg(A)}`, so no direct inconsistency arises from this addition.

But what about INDIRECT derivations? Can `neg(G(neg(alpha_1)))` together with GContent formulas derive something that, combined with `neg(G(neg(alpha_2)))`, produces a new derivation? This is where the analysis becomes combinatorially complex. The temporal axioms (particularly `temp_a: phi -> G(P(phi))` and `temp_k_dist: G(phi -> psi) -> (G(phi) -> G(psi))`) create chains of inference that could link F-formulas and GContent formulas in non-obvious ways.

### 4.5 The Subformula Property Argument (Speculative)

**Idea**: If the logic had a subformula property for derivations, we could analyze which formulas appear as intermediate steps in any derivation from the extended seed and show `neg(psi)` cannot be reached.

**Problem**: The Hilbert-style proof system used in this project does NOT have a subformula property. Modus ponens can introduce arbitrary formulas via lemma application, and temporal/modal necessitation can wrap formulas in operators. A cut-free sequent calculus for TM logic might have such a property, but this would require an entirely different proof system formalization.

### 4.6 The "All F-formulas Are Independent of GContent" Conjecture (Strongest Sufficient Condition)

**Idea**: Show that for ANY formula theta, if `GContent(M)` does not derive theta, then `GContent(M) union FContent(M)` does not derive theta either. This would be a strong independence result.

**Why it would suffice**: Since `GContent(M)` does not derive `neg(psi)` (by the existing `forward_temporal_witness_seed_consistent` proof), the extended seed would also not derive `neg(psi)`, making `{psi} union GContent(M) union FContent(M)` consistent.

**Why it might be true**: F-formulas are of the form `neg(G(neg(alpha)))`. In model-theoretic terms, they assert the existence of a future time where alpha holds. This is "future-looking" information that does not constrain the PRESENT state. GContent formulas are also "future-looking" (they encode what must hold at all future times). But GContent already encodes MAXIMAL information about the future -- if something is derivable from GContent, it was derivable from the G-formulas of M. The F-formulas add only negative constraints (certain G-formulas are absent), which should not enable new positive derivations.

**Why it might be false**: The F-formulas could interact with axioms to produce derivations. For example, `neg(G(neg(alpha)))` with `G(neg(alpha) -> beta)` (from GContent if `neg(alpha) -> beta in GContent(M)`) could potentially interact, though the exact derivation structure is unclear.

**Assessment**: This is the strongest sufficient condition but also the hardest to prove. It would require a deep analysis of the proof-theoretic structure of TM logic.

### 4.7 Constructive Lindenbaum with Priority Enumeration

**Idea**: Bypass the consistency conjecture entirely by using a constructive (formula-by-formula) Lindenbaum that processes F-formulas from the predecessor BEFORE their negations.

**Mechanism**:
1. Enumerate all formulas: phi_0, phi_1, phi_2, ...
2. Reorder the enumeration so that all F-formulas from the predecessor appear first.
3. In the constructive Lindenbaum, at each step add phi_n or neg(phi_n) to maintain consistency.
4. Since F(chi) appears before G(neg(chi)) = neg(F(chi)) in the enumeration, and F(chi) is consistent with the seed (it is in the predecessor MCS), F(chi) is added. Later, G(neg(chi)) is rejected because it contradicts the already-added F(chi).

**Advantage**: No need for the consistency conjecture -- F-preservation is guaranteed by the enumeration ordering.

**Disadvantage**: Requires building an entirely new Lindenbaum construction in Lean. The existing `set_lindenbaum` uses Zorn and is deeply integrated into the codebase. The new construction needs:
- A custom enumeration function
- A proof that the formula-by-formula union is consistent at each step
- A proof that the limit is maximal
- A proof that the limit is an MCS (negation-complete)

The Boneyard file `TemporalLindenbaum.lean` (1147 lines) attempted something similar and failed at the maximality proof (`maximal_tcs_is_mcs`, 6 sorries). The failure there was at a different point (Zorn-based maximalization after Henkin base), but it demonstrates the difficulty of alternative Lindenbaum constructions.

**Assessment**: This approach is sound in principle but carries high implementation risk (30-50 hours, HIGH risk).

---

## 5. Confidence Assessment

| Finding | Confidence |
|---------|------------|
| The F-preserving seed approach correctly addresses persistence | HIGH (95%) |
| G-lifting fails for the extended seed | HIGH (98%) -- demonstrated by the F -> GF non-derivability |
| The consistency conjecture is plausible | MEDIUM (55%) -- no counterexample but no proof path |
| Semantic argument avoids the obstacle | LOW (25%) -- recasts the problem without resolving it |
| Partial G-lifting breaks the circularity | LOW (15%) -- reduces to the same question |
| Constructive Lindenbaum with priority enumeration works in principle | HIGH (85%) -- but implementation risk is high |
| The independence conjecture (Section 4.6) is true | MEDIUM (50%) -- strongest sufficient condition, hardest to prove |

### Overall Assessment

The F-preserving seed approach is mathematically well-motivated and would cleanly resolve the persistence problem IF the extended seed consistency can be proven. The standard G-lifting proof technique is insufficient for this conjecture, and all alternative techniques analyzed here either restate the problem in different terms or require deep proof-theoretic analysis that is beyond the scope of current tooling.

The most promising concrete next step remains the time-boxed investigation recommended in research-005: allocate 8-12 hours to attempt a proof (or find a counterexample) of the consistency conjecture, possibly via the derivation-theoretic analysis of Section 4.4 or the independence argument of Section 4.6. If this effort does not succeed, the fallback is sorry debt documentation.

---

## 6. References

### Project Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- Chain construction (1654 lines, 2 sorries at lines 1621, 1628)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- GContent/HContent definitions (28 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` -- generalized_temporal_k (G-lifting technique)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` -- set_lindenbaum (Zorn-based)

### Prior Research
- `/home/benjamin/Projects/ProofChecker/specs/916_implement_fp_witness_obligation_tracking/reports/research-005.md` -- Synthesis report (Path 1 description)
- `/home/benjamin/Projects/ProofChecker/specs/916_implement_fp_witness_obligation_tracking/reports/research-006.md` -- Constraint enumeration and Section 4.3 analysis
- `/home/benjamin/Projects/ProofChecker/specs/916_implement_fp_witness_obligation_tracking/reports/research-005-teammate-b-findings.md` -- Original teammate B findings (constructive Lindenbaum and literature)
