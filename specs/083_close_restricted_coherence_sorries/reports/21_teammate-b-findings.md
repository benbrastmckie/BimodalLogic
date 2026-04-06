# Teammate B Findings: Algebraic, Topological, and Categorical Structures for the Until Transfer Lemma

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-05
**Focus**: Structures from topology, algebra, and category theory that could overcome the Until Transfer Lemma gap

---

## Key Findings

### 1. The Until Operator as a Least Fixed Point (mu-Calculus Perspective)

The most directly relevant mathematical structure is the characterization of Until as a **least fixed point** in the modal mu-calculus. The standard embedding is:

```
phi U psi  =  mu X. psi v (phi ^ OX)
```

where `O` is the next-time operator (called `X` in our formalization). This says: `phi U psi` is the least fixed point of the monotone operator `F(X) = psi v (phi ^ OX)` on the complete lattice of formula-sets (ordered by inclusion).

**Why this matters**: The Until Unfold and Until Intro axioms are exactly the fixed-point unfolding:
- Until Unfold: `(phi U psi) -> X(psi v (phi ^ (phi U psi)))` (the fixed point satisfies the equation)
- Until Intro: `X(psi v (phi ^ (phi U psi))) -> (phi U psi)` (the equation implies the fixed point)

Together these say `phi U psi` is **a** fixed point. The Until Induction axiom provides the **least** fixed point characterization: it says any post-fixed point (invariant satisfying the recursion) is above `phi U psi`.

**Application to the gap**: The key insight is that the least fixed point characterization gives us an **induction principle**. If we can show that the property "is in the Lindenbaum extension" is a post-fixed point of the Until operator's defining functional, we can conclude the Until formula persists. However, this requires working in the Lindenbaum algebra rather than at the MCS level.

**Mathlib availability**: `Mathlib.Order.FixedPoints` provides `OrderHom.lfp` and `OrderHom.gfp` with Knaster-Tarski, plus induction principles. The Lindenbaum algebra `LindenbaumAlg` already has a `BooleanAlgebra` instance (in `BooleanStructure.lean`), so the lattice infrastructure exists.

### 2. Stone Duality: MCSes as Points of a Stone Space

MCSes of TM logic are precisely the ultrafilters of the Lindenbaum algebra `LindenbaumAlg`. By Stone duality, they form a Stone space (compact, Hausdorff, totally disconnected). Each formula `phi` defines a clopen set `[phi] = {M : MCS | phi in M}`.

**Topological reformulation of the problem**: The set `U = {M : MCS | (top U psi) in M}` is a clopen set in the Stone space. The set `S = {M : MCS | M is a valid Lindenbaum extension of temporal_box_g_seed(M_n)}` is a closed set (intersection of clopen sets defined by seed elements). The Until Transfer Lemma asks: is `U intersect S` nonempty?

**Compactness argument**: If `{(top U psi)} union temporal_box_g_seed(M_n)` is finitely consistent (every finite subset is consistent), then by compactness it is consistent, and a Lindenbaum extension containing `(top U psi)` exists.

**Finite consistency approach**: For any finite `L subset temporal_box_g_seed(M_n)`, we need `L union {(top U psi)}` to be consistent. Each element of `L` is G-liftable, but `(top U psi)` is not. However, for a **finite** `L`, we can construct a semantic model: take `M_n` as root, apply `x_content` finitely many times to build a finite prefix of the deterministic chain. In this finite prefix, `(top U psi)` persists (by the sorry-free `until_persists_chain` for deterministic chains), and all elements of `L` hold (because they are in `g_content`). This finite semantic model witnesses consistency of `L union {(top U psi)}`.

**This is a concrete proof strategy.** See Section "Recommended Approach" below.

### 3. The Two-Chain Consistency Argument (Novel Synthesis)

Combining the Stone space / compactness perspective with the existing deterministic chain machinery yields the following argument:

**Claim**: `{(top U psi)} union temporal_box_g_seed(M_n)` is consistent whenever `(top U psi) in M_n`.

**Proof sketch**:
1. Let `L = {a_1, ..., a_k}` be any finite subset of `temporal_box_g_seed(M_n)`.
2. Each `a_i` satisfies `G(a_i) in M_n` (this is the G-liftability property of the seed).
3. Consider the deterministic chain rooted at `M_n`: `D(0) = M_n, D(m+1) = x_content(D(m))`.
4. Since `G(a_i) in M_n = D(0)`, by forward_G_int (sorry-free), `a_i in D(m)` for all `m >= 1`.
5. Since `(top U psi) in M_n = D(0)`, by `until_persists_chain` (sorry-free), `(top U psi) in D(m)` for all `m` until `psi` appears.
6. In particular, `(top U psi) in D(1)` (taking `m = 1`, since if `psi in D(1)` then `top U psi in D(1)` anyway by F_until_equiv and the fact that `F(psi) in D(1)` follows from... wait, we need to be more careful).

Actually, step 6 needs refinement. Let us consider two cases:
- **Case A**: `psi in D(1) = x_content(M_n)`. Then certainly `{(top U psi)} union L` is consistent, because `psi -> (top U psi)` is derivable (instantiate Until Intro), and the set `{psi} union L` has a model (since each `a_i in D(1)` and `psi in D(1)`, and `D(1)` is an MCS, hence consistent).
- **Case B**: `psi not in D(1)`. Then by `until_persists_chain`, `(top U psi) in D(1)`. Also each `a_i in D(1)` (by G-propagation). So `{(top U psi), a_1, ..., a_k} subset D(1)`, and since `D(1)` is consistent (it is an MCS), the set `{(top U psi)} union L` is consistent.

In both cases, `{(top U psi)} union L` is consistent. Since `L` was an arbitrary finite subset of `temporal_box_g_seed(M_n)`, the full set `{(top U psi)} union temporal_box_g_seed(M_n)` is **finitely consistent**.

**By compactness** (which holds in our system -- if a set is finitely consistent, it is consistent), `{(top U psi)} union temporal_box_g_seed(M_n)` is consistent. Therefore any Lindenbaum extension of `temporal_box_g_seed(M_n)` can be arranged to include `(top U psi)`.

### 4. Compactness in the Formalization

The compactness theorem for propositional logic says: a set `S` is consistent if and only if every finite subset of `S` is consistent. In our formalization:

- `SetConsistent S` means there is no finite derivation of `bot` from elements of `S`.
- By definition, `SetConsistent S` is equivalent to: for all finite lists `L` with elements from `S`, `L` does not derive `bot`.
- This is **already** a finitary condition. Every derivation tree is finite, so it only uses finitely many premises.

Therefore, `SetConsistent({(top U psi)} union temporal_box_g_seed(M_n))` is equivalent to: for every finite `L subset {(top U psi)} union temporal_box_g_seed(M_n)`, `L` does not derive `bot`. This is precisely finite consistency.

**No additional compactness theorem is needed.** The consistency predicate is inherently finitary. The argument in Section 3 directly proves `SetConsistent` because any finite derivation of `bot` from the seed would use only finitely many seed elements, all of which coexist consistently in the deterministic chain step `D(1)`.

### 5. Lattice-Theoretic Fixed Points (Knaster-Tarski)

The Knaster-Tarski approach to the Until operator would work as follows:

Define the operator `Phi : P(Formula) -> P(Formula)` by:
```
Phi(X) = {phi U psi | psi in X or (phi in X and phi U psi in X)}
```

The set of formulas in an MCS that have the form `phi U psi` is a fixed point of an appropriately defined operator on the lattice of subsets of formulas. The Until Induction axiom guarantees the least fixed point property.

However, **this does not directly help** with the transfer problem. The issue is not about characterizing which Until formulas hold in a given MCS, but about ensuring a specific Until formula survives a Lindenbaum extension. The lattice-theoretic viewpoint is subsumed by the consistency argument in Section 3.

### 6. Category Theory: Functorial View of Chain Construction

The passage `M_n -> M_{n+1}` via `forward_step` can be viewed as an endofunctor on the category of MCSes-in-a-box-class (with morphisms being inclusion of g_content). However, this functorial perspective does not immediately help because:

- The chain is not a colimit (each step involves a non-canonical Lindenbaum extension choice).
- Coalgebraic methods (Kurz, Venema) model Until via predicate liftings and final coalgebras, but these are semantic frameworks -- they do not directly produce syntactic consistency proofs.
- The GHR quasimodel approach (Section 8.3 of the gap report) is essentially a category-theoretic construction (a directed graph of MCSes with path extraction), but it requires a fundamentally different architecture than the current incremental chain.

**Assessment**: Category theory does not provide a shortcut here. The concrete consistency argument in Section 3 is more direct and formalizable.

### 7. The Verbrugge "Completeness by Construction" Method

Verbrugge (in work with de Jongh and others from the Amsterdam school) developed a "step-by-step" method for completeness of tense logics over discrete structures. The key idea: at each construction step, handle only formulas from a **finite** set of "relevant formulas" (the subformula closure of the target formula). This guarantees that Until obligations are tracked because they appear in the finite relevant set.

**Relevance**: This method works because the finite relevant set is closed under subformulas, so Until unfold lands in the relevant set and is automatically tracked. In our formalization, we work with all formulas (not a finite relevant set), which is why tracking is harder. However, the Verbrugge approach suggests an alternative architecture: restrict attention to a finite set of formulas and build the chain with respect to that set.

**Assessment**: Adopting the Verbrugge method would require significant architectural changes. The consistency argument in Section 3 is more compatible with the existing codebase.

### 8. Published Approaches Comparison

| Approach | Until Handling | Architecture Match | Formalization Cost |
|----------|---------------|-------------------|-------------------|
| Burgess (1984) | Global canonical model | Poor (needs full model) | Very High |
| GHR (1994) quasimodels | Path extraction from graph | Poor (different architecture) | Very High |
| Goldblatt (1992) | Reflexive semantics (avoids problem) | N/A (wrong semantics) | N/A |
| Verbrugge step-by-step | Finite relevant set tracking | Medium (needs restructuring) | High |
| Reynolds (2003) mosaics | Mosaic decomposition | Poor (for discrete case) | Very High |
| **Two-chain consistency (Section 3)** | **Deterministic chain witness** | **Excellent (uses existing code)** | **Low** |

---

## Recommended Approach

### The Two-Chain Consistency Argument

**Strategy**: Prove `SetConsistent({(top U psi)} union temporal_box_g_seed(M_n))` by showing every finite subset is realized in the deterministic chain `D(1) = x_content(M_n)`.

**Detailed proof outline**:

1. **Setup**: Given `(top U psi) in M_n` and `psi not in M_n`. Let `L` be any finite list of elements from `{(top U psi)} union temporal_box_g_seed(M_n)` such that (toward contradiction) `L |- bot`.

2. **Partition `L`**: Write `L = L_seed union L_until` where `L_seed subset temporal_box_g_seed(M_n)` and `L_until` is either empty or `{(top U psi)}`.

3. **If `L_until` is empty**: Then `L = L_seed subset temporal_box_g_seed(M_n)`, and `L |- bot` contradicts `SetConsistent(temporal_box_g_seed(M_n))` which is already proven (it is used in `temporal_theory_witness_with_g_consistent`).

4. **If `L_until = {(top U psi)}`**: Then `L_seed |- neg(top U psi)` (by deduction theorem). We need to show this is impossible.

5. **Key step**: Every element of `L_seed` is in `D(1) = x_content(M_n)`:
   - Elements of `g_content(M_n)`: If `G(a) in M_n`, then `a in x_content(M_n)` because `g_content subset x_content`.
   - Elements of `G_theory(M_n)`: If `G(a) in M_n`, then `G(a) in x_content(M_n)` because `G(G(a)) in M_n` (by temp_4), so `G(a) in x_content(M_n)`.
   - Elements of `box_theory(M_n)`: Box formulas propagate via `box_in_x_content` and related lemmas.

6. **Also** `(top U psi) in D(1)`:
   - If `psi in D(1)`: Then `top U psi in D(1)` (derivable from `psi -> (top U psi)` via Until Intro).
   - If `psi not in D(1)`: Then by `until_persists_chain` (sorry-free), `(top U psi) in D(1)`.

7. **Contradiction**: `L_seed union {(top U psi)} subset D(1)`, and `D(1)` is an MCS (hence consistent). But `L_seed union {(top U psi)} |- bot`, contradicting consistency of `D(1)`.

8. **Conclusion**: `{(top U psi)} union temporal_box_g_seed(M_n)` is consistent. Therefore the Lindenbaum extension that produces `M_{n+1}` can be seeded with `(top U psi)` included.

### Implementation Plan

**Phase 1**: Prove that `temporal_box_g_seed(M_n) subset x_content(M_n)` (i.e., every element of the seed is in the deterministic successor).

Required lemmas:
- `g_content_subset_x_content`: Already known (`g_content(M) subset x_content(M)` from `G(a) -> X(a)`).
- `G_theory_subset_x_content`: `G(a) in M -> G(a) in x_content(M)` from temp_4 (`G(a) -> G(G(a)) -> X(G(a))`).
- `box_theory_subset_x_content`: `Box(a) in M -> Box(a) in x_content(M)` from temporal interaction axioms.

**Phase 2**: Prove `(top U psi) in x_content(M_n)` when `(top U psi) in M_n` (regardless of whether `psi in M_n` or not). This follows from Until Unfold: `(top U psi) -> X(psi v (top U psi))`, so `psi v (top U psi) in x_content(M_n)`, and in either disjunct `(top U psi) in x_content(M_n)`.

Wait -- this needs care. If `psi in x_content(M_n)`, we need `(top U psi) in x_content(M_n)`. This requires `psi -> (top U psi)` to be derivable. Is it?

Actually, `psi -> (top U psi)` should follow from Until Intro: `X(psi v (top ^ (top U psi))) -> (top U psi)`. Hmm, that gives `(top U psi)` from `X(...)`, not from `psi` directly. Let me reconsider.

The formula `psi -> F(psi)` is derivable (from seriality: there exists a next instant, and `psi` at that instant or... actually under strict semantics, `psi -> F(psi)` is NOT valid because `F(psi)` requires `psi` at a strictly future time).

**Correction**: If `psi in x_content(M_n)`, we do NOT necessarily get `(top U psi) in x_content(M_n)`. However, what we need is merely that `{(top U psi)} union L_seed` is consistent, where `L_seed subset x_content(M_n)`. Since `x_content(M_n)` is consistent (it is an MCS), and `psi in x_content(M_n)` implies `neg(top U psi) not in x_content(M_n)` (because `psi -> neg(neg(top U psi))` would require... hmm, this is not straightforward either).

**Revised approach**: Instead of showing `(top U psi) in x_content(M_n)`, show directly that `L_seed |- neg(top U psi)` leads to a contradiction by using `x_content(M_n)` as a witness. Since `L_seed subset x_content(M_n)` and `x_content(M_n)` is consistent, `L_seed` cannot derive anything contradicting `x_content(M_n)`. We need that `neg(top U psi) not in x_content(M_n)`.

**Claim**: `neg(top U psi) not in x_content(M_n)` when `(top U psi) in M_n`.

**Proof**: By Until Unfold, `(top U psi) in M_n` gives `X(psi v (top ^ (top U psi))) in M_n`. Since `top ^ alpha = alpha` in an MCS, this gives `X(psi v (top U psi)) in M_n`. Therefore `psi v (top U psi) in x_content(M_n)`.

Now, by negation completeness of `x_content(M_n)` (which is an MCS), either `(top U psi) in x_content(M_n)` or `neg(top U psi) in x_content(M_n)`.

If `neg(top U psi) in x_content(M_n)`, then since `psi v (top U psi) in x_content(M_n)` and `neg(top U psi) in x_content(M_n)`, the disjunction resolves to `psi in x_content(M_n)`. But that is fine -- `psi` and `neg(top U psi)` can coexist (under strict semantics, `top U psi` means `psi` at a strictly future time, so having `psi` now and `neg(top U psi)` is consistent if there is no future `psi`).

So `neg(top U psi)` CAN be in `x_content(M_n)`. This means `x_content(M_n)` is not a valid witness for the case where `neg(top U psi) in x_content(M_n)`.

**This invalidates the simple two-chain argument.** We need a more careful approach.

### Revised Strategy: Enhanced Seed with Finite Consistency via Semantic Models

The issue is that `x_content(M_n)` might contain `neg(top U psi)`. But we can use a **semantic** argument:

For any finite `L_seed subset temporal_box_g_seed(M_n)`, we build a **finite semantic model** where both `L_seed` and `(top U psi)` are all true:

1. Start with `M_n` as an MCS where `(top U psi)` holds and each `G(a_i) in M_n` for `a_i in L_seed`.
2. Apply `x_content` repeatedly: `D(0) = M_n, D(1), D(2), ...`
3. By `until_persists_chain`, `(top U psi)` stays in every `D(m)` until `psi` appears.
4. By the semantics of `top U psi`, there exists some `D(k)` with `psi in D(k)` (this is the F-resolution -- but wait, this is what we are trying to prove! The deterministic chain does NOT necessarily resolve `F(psi)`).

This circularity shows we cannot use the deterministic chain to build the semantic model.

**Alternative**: Use the consistency of `M_n` itself as the witness. Since `(top U psi) in M_n` and `L_seed subset g_content(M_n) union G_theory(M_n) union box_theory(M_n)`, and each of these is a subset of `M_n`, we have `L_seed union {(top U psi)} subset M_n`. Since `M_n` is consistent, `L_seed union {(top U psi)}` is consistent.

**Wait -- this is the correct argument!** Let me verify:

- `g_content(M_n) = {a | G(a) in M_n}`. Is `g_content(M_n) subset M_n`? Only if `G(a) -> a` is valid. Under strict semantics, it is NOT. So `g_content(M_n)` is NOT necessarily a subset of `M_n`.

This fails. `g_content` extracts the content under `G`, but under strict semantics, `G(a) in M` does not imply `a in M`.

### Final Revised Strategy: The X-Content Embedding

Here is the corrected argument:

**Claim**: `{(top U psi)} union temporal_box_g_seed(M_n)` is consistent when `(top U psi) in M_n`.

**Proof**: We show every finite subset is consistent by embedding into `x_content(M_n)`, with a twist.

For `a in g_content(M_n)`: `G(a) in M_n` implies `X(a) in M_n` (from `G -> X`), so `a in x_content(M_n)`.
For `G(a) in G_theory(M_n)`: `G(a) in M_n` implies `G(G(a)) in M_n` (by temp_4), so `X(G(a)) in M_n`, so `G(a) in x_content(M_n)`.
For `Box(a) in box_theory(M_n)`: `Box(a) in M_n` implies `Box(Box(a)) in M_n` (by modal_4), so `X(Box(a)) in M_n` (from `Box(a) -> G(Box(a)) -> X(Box(a))` using modal_future + temp axioms), so `Box(a) in x_content(M_n)`.
For `neg(Box(a)) in box_theory(M_n)`: Similarly propagates via `neg(Box(a)) -> G(neg(Box(a)))` (from `dia(a) -> G(dia(a))` using S5 + temporal axioms).

So `temporal_box_g_seed(M_n) subset x_content(M_n)`.

For `(top U psi)`: By Until Unfold, `psi v (top U psi) in x_content(M_n)`. If `(top U psi) in x_content(M_n)`, done. If not, then `psi in x_content(M_n)`.

**Case 1**: `(top U psi) in x_content(M_n)`. Then `{(top U psi)} union temporal_box_g_seed(M_n) subset x_content(M_n)`, and `x_content(M_n)` is consistent (it is an MCS). Done.

**Case 2**: `(top U psi) not in x_content(M_n)`, hence `neg(top U psi) in x_content(M_n)` and `psi in x_content(M_n)`. Now we need to show `{(top U psi)} union L_seed` is consistent for `L_seed subset temporal_box_g_seed(M_n)`.

In this case, suppose toward contradiction that `L_seed |- neg(top U psi)`. Since `L_seed subset x_content(M_n)` and `x_content(M_n)` is closed under derivation, `neg(top U psi) in x_content(M_n)`. This is actually consistent with our assumption! The issue is that `neg(top U psi)` being derivable from `L_seed` means `{(top U psi)} union L_seed` is indeed inconsistent.

**So Case 2 is problematic.** We cannot guarantee consistency in this case.

But wait: does Case 2 actually arise? If `(top U psi) in M_n`, can `neg(top U psi) in x_content(M_n)`?

`x_content(M_n) = {a | X(a) in M_n}`. So `neg(top U psi) in x_content(M_n)` iff `X(neg(top U psi)) in M_n`.

From `(top U psi) in M_n`, Until Unfold gives `X(psi v (top U psi)) in M_n`. By X-Det, either `X(neg(top U psi)) in M_n` or `neg(X(neg(top U psi))) in M_n`, i.e., `X(top U psi) in M_n`. Combined with `X(psi v (top U psi)) in M_n`:

If `X(neg(top U psi)) in M_n` and `X(psi v (top U psi)) in M_n`, then by X-K distribution:
`X(neg(top U psi) ^ (psi v (top U psi))) in M_n`, which simplifies to `X(psi ^ neg(top U psi)) in M_n`.

Is `psi ^ neg(top U psi)` consistent? Yes, under strict semantics: `psi` holds now, and `top U psi` fails (no future time with `psi`), which is consistent if `psi` is true now but never again in the strict future.

So Case 2 can occur. The two-chain argument does not work as stated.

---

## Revised Recommended Approach: Enriched Seed with Direct Consistency Proof

After the analysis above, I recommend a **different strategy** that avoids the x_content embedding entirely.

### The G-Box-Until Seed Consistency Theorem

**Goal**: Prove `SetConsistent({(top U psi)} union {target} union temporal_box_g_seed(M_n))` directly.

**Method**: Modify the existing G-lift argument to handle the single additional non-G-liftable formula `(top U psi)`.

**Key lemma needed**: If `L subset temporal_box_g_seed(M_n)` and `L |- (top U psi) -> neg(target)`, then derive a contradiction.

By the deduction theorem: `L |- neg(target) v neg(top U psi)`, i.e., `L |- neg(target ^ (top U psi))`.

G-lifting `L` gives `G(neg(target ^ (top U psi))) in M_n`, i.e., `G(neg(target) v neg(top U psi)) in M_n`.

We need to show this contradicts `F(target) in M_n` and `(top U psi) in M_n`. But `G(neg(target) v neg(top U psi))` says "at all future times, either target fails or top U psi fails." This is weaker than `G(neg(target))` alone.

If we also know `F(target) in M_n`, can we derive a contradiction?

`F(target) in M_n` means there exists a future time where `target` holds. At that time, `neg(target)` fails, so `neg(top U psi)` must hold (by the G-formula). But this only says `top U psi` fails at some future time -- it does not contradict `(top U psi) in M_n` (present time).

**This approach also fails** for the same fundamental reason: strict semantics decouples present from future.

### The Architectural Solution: Modified Forward Step

Given that purely syntactic consistency arguments are blocked by the G-lift obstruction, the most promising approach combines insights from the literature:

**Modify `forward_step` to use `x_content` as the base, with Lindenbaum extension only for the target formula.**

Define:
```
forward_step'(M_n, target) =
  if F(target) in M_n then
    Lindenbaum_extension({target} union x_content(M_n))   -- if consistent
  else
    x_content(M_n)
```

**Key question**: Is `{target} union x_content(M_n)` consistent when `F(target) in M_n`?

Since `x_content(M_n)` is already an MCS, `{target} union x_content(M_n)` is consistent iff `target in x_content(M_n)` or `neg(target) not in x_content(M_n)`.

If `F(target) in M_n`, does `F(target)` propagate to `x_content(M_n)`? We need `X(F(target)) in M_n`, i.e., `F(target) in x_content(M_n)`. From the axiom `F(target) -> (top U target) -> X(target v (top U target))`, we get `target v (top U target) in x_content(M_n)`, which gives `target in x_content(M_n)` or `F(target) in x_content(M_n)` (since `top U target` implies `F(target)`).

**If target in x_content(M_n)**: No Lindenbaum extension needed! Just use `x_content(M_n)`.

**If F(target) in x_content(M_n) but target not in x_content(M_n)**: Then `neg(target) in x_content(M_n)` (by maximality). So `{target} union x_content(M_n)` is inconsistent. We CANNOT add target to `x_content(M_n)`.

**But this is exactly the deterministic chain problem**: `x_content` alone cannot resolve F-obligations.

So this modified step has the same problem as before for F-resolution. The whole point of the dovetailed chain was to escape `x_content`.

---

## Final Assessment and Recommendation

### Core Difficulty

The Until Transfer Lemma gap is fundamentally about the **incompatibility between two requirements**:

1. **F-resolution** requires Lindenbaum extension beyond `x_content` (to inject new formulas).
2. **Until persistence** requires staying close to `x_content` (where Until Unfold lands).

No algebraic, topological, or categorical structure can magically resolve this tension within the current incremental chain architecture. The G-lift argument is the only available syntactic consistency technique, and Until formulas are provably not G-liftable.

### Recommended Path: GHR-Style Global Construction (Confidence: High)

The mathematically sound resolution is to adopt a **global canonical model construction** as used by Gabbay-Hodkinson-Reynolds and Burgess. In this approach:

1. **Build a directed graph** where nodes are MCSes in the same box class as `M_0`, and edges represent the temporal successor relation (`M Succ W` iff `g_content(M) subset W`).
2. **Extract omega-paths** through this graph using Konig's lemma or Zorn's lemma.
3. **Until persistence** is a property of the Succ relation itself (by Until Unfold + the definition of Succ via x_content), not of an incremental construction.
4. **F-resolution** is handled by the graph's richness: for any MCS with `F(psi)`, the temporal witness lemma provides an edge to an MCS containing `psi`.

**Formalization cost**: Moderate. The existing `temporal_theory_witness_with_g_exists` provides the edge construction. The main new work is:
- Define the Succ relation on MCSes
- Prove it satisfies Until persistence (straightforward from x_content)
- Extract paths using the existing deterministic chain as a backbone, with F-patching at designated steps
- Show the resulting path satisfies all coherence conditions

**Mathlib resources**: `Mathlib.Order.FixedPoints` for any fixed-point arguments, `Mathlib.Data.Nat.Pairing` (already imported) for dovetailing, `Mathlib.Order.BooleanAlgebra` (already used) for the Lindenbaum algebra.

### Alternative Path: Hybrid Deterministic + Bundle Approach (Confidence: Medium)

Use the deterministic chain (sorry-free Until persistence) as the base family in the BFMCS bundle, and add separate witness families for each F-obligation:

1. For each `F(psi) in M_0`, construct a separate shifted deterministic chain rooted at a witness MCS containing `psi`.
2. The BFMCS bundle already supports multiple families -- add these witness families.
3. Temporal coherence of the bundle follows from: base family has G/H/Until/Since coherence; F-resolution is provided by the witness families; box class agreement is already proven.

**This avoids the Until Transfer Lemma entirely** by not requiring a single chain to satisfy both Until persistence and F-resolution simultaneously.

---

## Evidence/Examples

### Evidence for Global Construction Viability

The existing codebase already has most infrastructure:
- `temporal_theory_witness_with_g_exists` (edge construction)
- `forward_dovetailed_forward_G`, `forward_dovetailed_backward_H` (G/H coherence, sorry-free)
- `until_persists_chain` (Until persistence for deterministic chains, sorry-free)
- `box_class_agree` (modal agreement, sorry-free)
- `construct_deterministic_bfmcs` in `DeterministicFMCS.lean` (bundle construction pattern)

### Evidence Against Simple Algebraic Fix

The analysis in Sections 3-5 above demonstrates that:
- The two-chain consistency argument fails because `neg(top U psi)` can appear in `x_content(M_n)`.
- The enhanced seed idea fails because Until formulas are not G-liftable.
- Lattice-theoretic fixed points do not address the seed consistency problem.
- Category-theoretic abstractions add complexity without solving the core issue.

### Key References

1. Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*. Oxford University Press. -- Global canonical model with quasimodels.
2. Burgess, J. (1984). "Basic tense logic." In *Handbook of Philosophical Logic*, pp. 89-133. -- Canonical model for Until temporal logic.
3. Venema, Y. "Temporal Logic" (chapter). -- Fixed-point characterization of Until, completeness.
4. Verbrugge, R. "Completeness by construction for tense logics of linear time." -- Step-by-step method for discrete tense logics.
5. Mathlib `Mathlib.Order.FixedPoints` -- Knaster-Tarski formalization with `OrderHom.lfp`/`gfp`.

---

## Confidence Level

**High confidence** that:
- Simple algebraic/topological/categorical fixes cannot resolve the Until Transfer Lemma within the current incremental architecture.
- The G-lift argument is fundamentally incompatible with Until formulas under strict semantics.
- A global canonical model (GHR-style) or hybrid bundle approach is needed.

**Medium confidence** that:
- The hybrid deterministic + bundle approach (Alternative Path) can work within the existing architecture with moderate changes.
- The GHR-style global construction can be formalized in Lean 4 with the existing Mathlib infrastructure.

**Low confidence** that:
- Any purely syntactic trick (without architectural change) can make the current `forward_step` preserve Until formulas.
