# The Until Transfer Lemma Gap: A Self-Contained Exposition

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-05
**Type**: Research report (mathematical exposition)

---

## 1. Preliminaries: Definitions and Notation

This section introduces all definitions needed to state and understand the Until Transfer Lemma gap. The formalization lives in a Lean 4 codebase formalizing bimodal logic TM (Tense + Modality), combining S5 modal logic with linear temporal logic under **strict** (irreflexive) temporal semantics.

### 1.1. Formulas

The formula type (`Bimodal.Syntax.Formula`) is an inductive type with eight constructors:

```
Formula ::= atom(a)        -- propositional atom
           | bot            -- falsum
           | imp(phi, psi)  -- implication
           | box(phi)       -- modal necessity (S5)
           | all_past(phi)  -- H(phi): "phi at all strictly past times"
           | all_future(phi)-- G(phi): "phi at all strictly future times"
           | untl(phi, psi) -- phi U psi: "phi holds until psi becomes true"
           | snce(phi, psi) -- phi S psi: "phi has held since psi was true"
```

Derived operators:
- **Negation**: `neg(phi) = phi -> bot`
- **Conjunction**: `and(phi, psi) = neg(phi -> neg(psi))`
- **Disjunction**: `or(phi, psi) = neg(phi) -> psi`
- **Next**: `X(phi) = bot U phi` (strict next-step)
- **Previous**: `Y(phi) = bot S phi` (strict previous-step)
- **Some future**: `F(phi) = neg(G(neg(phi)))` (existential future)
- **Some past**: `P(phi) = neg(H(neg(phi)))` (existential past)

**Critical**: Under strict temporal semantics, `G(phi)` quantifies over all times *strictly* after the current time. The T-axiom `G(phi) -> phi` is **not** valid. This distinguishes the system from reflexive temporal logics and is the source of many difficulties.

### 1.2. Maximal Consistent Set (MCS)

A set `M` of formulas is a **set-maximal consistent set** (`SetMaximalConsistent M`) if:

1. **Consistent** (`SetConsistent M`): There is no finite list `L` of formulas in `M` such that `L |- bot`.
2. **Maximal**: For every formula `phi` not in `M`, the set `M union {phi}` is inconsistent.

Key properties of an MCS `M`:
- **Negation completeness**: For every formula `phi`, either `phi in M` or `neg(phi) in M`.
- **Closure under derivation**: If `L subset M` and `L |- phi`, then `phi in M`.
- **Implication property**: If `phi -> psi in M` and `phi in M`, then `psi in M`.

### 1.3. Content Extractors

Given a set `M` of formulas, the following extract subsets of formulas appearing under specific operators. These are defined in `Bimodal.Metalogic.Bundle.TemporalContent`.

| Name | Definition | Lean identifier |
|------|-----------|-----------------|
| `g_content(M)` | `{phi \| G(phi) in M}` | `g_content` |
| `h_content(M)` | `{phi \| H(phi) in M}` | `h_content` |
| `f_content(M)` | `{phi \| F(phi) in M}` | `f_content` |
| `p_content(M)` | `{phi \| P(phi) in M}` | `p_content` |
| `x_content(M)` | `{phi \| X(phi) in M}` | `x_content` |
| `y_content(M)` | `{phi \| Y(phi) in M}` | `y_content` |
| `u_content(M)` | `{(phi,psi) \| (phi U psi) in M}` | `u_content` |
| `s_content(M)` | `{(phi,psi) \| (phi S psi) in M}` | `s_content` |

The critical relationships:
- `g_content(M) subset x_content(M)`: If `G(phi) in M` then `X(phi) in M` (provable from `G(phi) -> X(phi)`).
- `x_content(M)` is strictly larger than `g_content(M)`: A formula can be "true at the next time" without being "true at all future times."

### 1.4. x_content is an MCS

**Theorem** (`x_content_mcs`): If `M` is an MCS, then `x_content(M)` is an MCS.

This uses two axioms:
- **X-K** (`x_k_dist`): `X(phi -> psi) -> (X(phi) -> X(psi))` -- X distributes over implication.
- **X-Det** (`x_det`): `neg(X(phi)) -> X(neg(phi))` -- X is deterministic (exactly one successor).

The proof works by X-lifting: if `L |- phi` and each `X(a_i) in M` for `a_i in L`, then `X(phi) in M`. Consistency follows from `X(bot)` being refutable. Maximality follows from X-Det: if `phi not in x_content(M)` then `X(phi) not in M`, so `neg(X(phi)) in M`, so `X(neg(phi)) in M` (by X-Det), so `neg(phi) in x_content(M)`.

**y_content is symmetric**: `y_content(M)` is an MCS when `M` is, using Y-K and Y-Det axioms.

### 1.5. The Deterministic Chain

The **deterministic chain** (`deterministic_chain`) assigns an MCS to every integer, starting from a root MCS `M_0`:

```
chain(0) = M_0
chain(n+1) = x_content(chain(n))       for n >= 0
chain(-(n+1)) = y_content(chain(-n))   for n >= 0
```

Since `x_content` and `y_content` preserve MCS-ness, every chain element is an MCS. The chain is entirely deterministic: there are no choices or Lindenbaum extensions involved.

**Lean identifier**: `DeterministicChain.deterministic_chain`

### 1.6. The Dovetailed Chain

The **dovetailed chain** (`forward_dovetailed`) is an alternative construction that resolves F-obligations via Lindenbaum extension. At each step `n+1`, it:

1. Takes the current MCS `chain(n)`.
2. Selects a target formula `psi = schedule_formula(n)` via fair scheduling (using `Nat.unpair` for dovetailing).
3. If `F(psi) in chain(n)`, applies `temporal_theory_witness_with_g_exists` to obtain a new MCS `W` such that:
   - `psi in W` (the F-obligation is resolved)
   - `g_content(chain(n)) subset W` (G-formulas propagate)
   - `box_class_agree(chain(n), W)` (modal formulas agree)
   - `G(a) in chain(n) -> G(a) in W` (G-theory agreement)
4. Sets `chain(n+1) = W`.

**Lean identifier**: `DovetailedChain.forward_dovetailed`

### 1.7. temporal_theory_witness_with_g_exists

This is the key existence lemma for constructing successors that resolve F-obligations.

**Theorem** (`temporal_theory_witness_with_g_exists`): If `M` is an MCS and `F(phi) in M`, then there exists an MCS `W` such that:
1. `phi in W`
2. For all `a`, `G(a) in M -> G(a) in W` (G-theory agreement)
3. `box_class_agree(M, W)` (modal coherence)
4. `g_content(M) subset W`

**Construction**: The seed for Lindenbaum extension is `{phi} union temporal_box_g_seed(M)`, where:

```
temporal_box_g_seed(M) = G_theory(M) union box_theory(M) union g_content(M)
```

- `G_theory(M) = {G(a) | G(a) in M}` -- G-wrapped formulas from M
- `box_theory(M) = {Box(a) | Box(a) in M} union {neg(Box(a)) | Box(a) not in M}`
- `g_content(M) = {a | G(a) in M}` -- formulas under G

**Consistency proof**: The seed `{phi} union temporal_box_g_seed(M)` is consistent because every element `x` of `temporal_box_g_seed(M)` is **G-liftable**: `G(x) in M`. If the seed were inconsistent, then some `L subset temporal_box_g_seed(M)` would give `L |- neg(phi)`. By G-lifting (since each `G(a_i) in M` for `a_i in L`), we get `G(neg(phi)) in M`. But `F(phi) in M` means `neg(G(neg(phi))) in M`, contradicting consistency of `M`.

This is the **G-lift argument**, and it is the central technique in the completeness proof.

### 1.8. Until/Since Axioms

The relevant axioms for the Until operator (all in the discrete extension):

| Axiom | Statement | Lean identifier |
|-------|-----------|-----------------|
| **Until Unfold** | `(phi U psi) -> X(psi or (phi and (phi U psi)))` | `Axiom.until_unfold` |
| **Until Intro** | `X(psi or (phi and (phi U psi))) -> (phi U psi)` | `Axiom.until_intro` |
| **Until Induction** | `G(psi -> chi) and G((phi and X(chi)) -> chi) -> ((phi U psi) -> X(chi))` | `Axiom.until_induction` |
| **F-Until Equiv** | `F(psi) -> (top U psi)` | `Axiom.F_until_equiv` |

Note that `X(chi) = bot U chi` in the conclusions.

**Until Unfold** says: if `phi U psi` holds now, then at the next instant either `psi` holds (resolution) or both `phi` holds and `phi U psi` continues (deferral). In MCS terms: if `(phi U psi) in M`, then `X(psi or (phi and (phi U psi))) in M`, hence `psi or (phi and (phi U psi)) in x_content(M)`.

**F-Until Equiv** bridges the existential future operator with Until: `F(psi)` is equivalent to `top U psi` (where `top = neg(bot)`). The reverse direction (`top U psi -> F(psi)`) is derived from Until Induction.

### 1.9. forward_F Property

The **forward_F** property for an Int-indexed family of MCSes `{M_t}_{t in Z}` states:

> For all `t in Z` and formulas `psi`, if `F(psi) in M_t`, then there exists `s > t` such that `psi in M_s`.

This is the semantic requirement that every eventuality obligation is eventually fulfilled within the same family. It is one of four coherence conditions for a "Fully Modal Coherent Structure" (FMCS):

1. **forward_G**: `G(phi) in M_t` and `s > t` implies `phi in M_s` (proven sorry-free)
2. **backward_H**: `H(phi) in M_t` and `s < t` implies `phi in M_s` (proven sorry-free)
3. **forward_F**: `F(phi) in M_t` implies `exists s > t, phi in M_s` (**sorry**)
4. **backward_P**: `P(phi) in M_t` implies `exists s < t, phi in M_s` (**sorry**)

### 1.10. Until Coherence

**Forward Until coherence**: If `(phi U psi) in M_n` and `psi not in M_{n+1}`, then `phi in M_{n+1}` and `(phi U psi) in M_{n+1}`.

This is proven sorry-free for the deterministic chain (`until_persists_chain`) because `chain(n+1) = x_content(chain(n))`, so the Until Unfold axiom directly gives the disjunction in `x_content(chain(n)) = chain(n+1)`.

---

## 2. The Deterministic Chain: What It Achieves

The deterministic chain construction proves the following properties **sorry-free**:

### 2.1. G and H Coherence (Sorry-Free)

- **forward_G_int**: `G(phi) in chain(n)` and `n < m` implies `phi in chain(m)`.

  *Proof*: By `temp_4` (`G(phi) -> G(G(phi))`), G-formulas persist one step: `G(phi) in chain(n)` gives `G(G(phi)) in chain(n)`, hence `G(phi) in x_content(chain(n)) = chain(n+1)`. By induction, `G(phi)` persists to all future positions. Then `phi in g_content(chain(m-1)) subset x_content(chain(m-1)) = chain(m)`.

- **backward_H_int**: Symmetric, using `y_content`, `temp_4_past`, and boundary crossing via `YG_implies_self` and `XH_implies_self`.

### 2.2. Until/Since Persistence (Sorry-Free)

- **until_persists_chain**: If `(phi U psi) in chain(n)` and `psi not in chain(n+1)`, then both `phi in chain(n+1)` and `(phi U psi) in chain(n+1)`.

  *Proof sketch*: By Until Unfold, `X(psi or (phi and (phi U psi))) in chain(n)`. Since `chain(n+1) = x_content(chain(n))`, the disjunction `psi or (phi and (phi U psi))` is in `chain(n+1)`. Since `psi not in chain(n+1)`, negation completeness gives `neg(psi) in chain(n+1)`, so the disjunction resolves to `phi and (phi U psi) in chain(n+1)`.

  **Why this works**: The proof critically depends on `chain(n+1) = x_content(chain(n))`. The Until Unfold axiom produces an X-formula, which lands directly in `x_content`. The deterministic chain's definitional equality `chain(n+1) = x_content(chain(n))` makes this immediate.

- **since_persists_chain**: Symmetric for `phi S psi` in the backward direction.

### 2.3. Box Class Agreement (Sorry-Free)

All chain elements agree on modal formulas: `Box(phi) in chain(n) iff Box(phi) in chain(m)` for all `n, m`. This uses `temp_future` (`Box(phi) -> G(Box(phi))`) and the temporal duality for `Box(phi) -> H(Box(phi))`.

### 2.4. What the Deterministic Chain Cannot Prove

The deterministic chain **cannot** prove `forward_F`:

> If `F(psi) in chain(t)`, then there exists `s > t` such that `psi in chain(s)`.

The chain `chain(n+1) = x_content(chain(n))` is fully determined by the initial MCS `M_0`. There is no mechanism to inject `psi` into the chain at any particular step.

---

## 3. The F-Resolution Problem: Why forward_F Fails for Deterministic Chains

### 3.1. The Impossibility Argument

**Claim**: There exist MCSes `M_0` such that `F(psi) in M_0` but `psi not in chain(n)` for all `n >= 1`, where `chain` is the deterministic chain rooted at `M_0`.

**Proof**: Consider the set of formulas:

```
S = { F(A), neg(A), X(neg(A)), X(X(neg(A))), X(X(X(neg(A)))), ... }
    union { X(F(A)), X(X(F(A))), X(X(X(F(A)))), ... }
```

where `A` is some propositional atom. Every finite subset of `S` is consistent (a model with `A` true at some sufficiently distant future time satisfies any finite subset). By compactness (or direct Lindenbaum extension), `S` extends to an MCS `M_0`.

In this MCS:
- `F(A) in M_0` (eventuality obligation exists)
- `neg(A) in M_0`, so `A not in chain(0) = M_0`
- `X(neg(A)) in M_0`, so `neg(A) in x_content(M_0) = chain(1)`, so `A not in chain(1)`
- `X(X(neg(A))) in M_0`, so `X(neg(A)) in chain(1)`, so `neg(A) in chain(2)`, so `A not in chain(2)`
- And so on for all `n`.

The F-obligation `F(A) in M_0` is never resolved in the deterministic chain. The set is consistent because `F(A)` does not commit to *when* `A` will be true; it only says "at some strictly future time." The deterministic chain `x_content^n(M_0)` is locked into a particular future where `A` is always false.

### 3.2. Why F-Persistence Also Fails

One might hope that `F(A)` persists through the chain (i.e., `F(A) in chain(n)` for all `n >= 0`), which would enable a resolution at some later step via a modified construction. But even `F(A)` persistence is not guaranteed for the deterministic chain.

`F(A) = neg(G(neg(A)))`. Whether `F(A) in chain(n)` depends on whether `G(neg(A)) not in chain(n)`. Since `chain(n+1) = x_content(chain(n))`, new G-formulas can appear: `G(neg(A))` might enter `chain(n)` for some `n > 0` even though it was not in `chain(0)`.

However, by the counterexample above, we can also arrange `X^n(F(A)) in M_0` for all `n`, which forces `F(A)` to be in every chain position. Even with F-persistence, the deterministic chain still cannot resolve the obligation because the mechanism for putting `A` into the chain is absent: `x_content` is fully determined by the previous step.

---

## 4. The Dovetailed Chain and Its Gap

### 4.1. Construction Overview

The dovetailed chain addresses the F-resolution problem by using **Lindenbaum extension** at each step instead of deterministic `x_content`. At step `n+1`:

1. Fair scheduling selects a target formula `psi = schedule_formula(n)`.
2. If `F(psi) in chain(n)`, apply `temporal_theory_witness_with_g_exists` to get an MCS `W` with `psi in W` and `g_content(chain(n)) subset W`.
3. Set `chain(n+1) = W`.

The key feature: when `F(psi) in chain(n)`, the Lindenbaum extension is seeded with `{psi} union temporal_box_g_seed(chain(n))`, and the G-lift argument proves this seed is consistent. The resulting `W` contains `psi` (obligation resolved) and `g_content(chain(n))` (G-formulas propagate).

### 4.2. What Is Proven Sorry-Free

The dovetailed chain achieves the following sorry-free:

- **Every step is MCS**: `forward_dovetailed_mcs`
- **G-theory propagation**: `G(a) in chain(n) -> G(a) in chain(n+1)` via `forward_step_G_agree`
- **g_content propagation**: `g_content(chain(n)) subset chain(n+1)` via `forward_step_g_content`
- **Forward G coherence**: `G(phi) in chain(n), n < m -> phi in chain(m)` via `forward_dovetailed_forward_G`
- **Backward H coherence**: `H(phi) in chain(m), n < m -> phi in chain(n)` via `forward_dovetailed_backward_H`
- **Box class agreement**: `box_class_agree(M_0, chain(n))` for all `n`
- **Fair scheduling surjectivity**: For every formula `psi` and position `t`, there exists `n >= t` with `schedule_formula(n) = psi` (`schedule_formula_hits`)
- **Forward F resolution** (conditional on Until persistence): If Until persistence holds, then `forward_dovetailed_forward_F` is proven

### 4.3. What Is NOT Proven: The Sorry

The single remaining sorry is:

**`forward_dovetailed_until_persists`**: If `(top U psi) in chain(n)` and `psi not in chain(n)`, then `(top U psi) in chain(n+1)`.

This sorry blocks `forward_dovetailed_forward_F`, which is the theorem that makes the whole construction work. The proof of `forward_F` uses Until persistence as follows:

1. `F(psi) in chain(t)` implies `(top U psi) in chain(t)` by `F_until_equiv`.
2. By Until persistence (the sorry), `(top U psi)` remains in the chain until `psi` appears.
3. Fair scheduling gives `n >= t` with `schedule_formula(n) = psi`.
4. If `psi` has not appeared by step `n`, then `(top U psi) in chain(n)`, hence `F(psi) in chain(n)`.
5. `forward_step` resolves: `psi in chain(n+1)`.

Without Until persistence, the chain may lose `(top U psi)` at some intermediate step, and the F-obligation evaporates before the scheduler targets it.

---

## 5. The Until Transfer Lemma -- Precise Statement

### 5.1. What Must Be Proven

**Until Transfer Lemma** (the sorry): Let `M_n = forward_dovetailed(M_0, h_mcs_0, n)`. If:
- `(top U psi) in M_n`
- `psi not in M_n`

Then: `(top U psi) in M_{n+1}`.

Here `top = neg(bot)` and `M_{n+1} = forward_step(M_n, h_mcs_n, schedule_formula(n))`.

### 5.2. What the Axioms Give

By **Until Unfold** applied to `(top U psi) in M_n`:

```
X(psi or (top and (top U psi))) in M_n
```

Since `top and (top U psi)` simplifies (top is always true in an MCS, so `top and alpha = alpha` in an MCS), this gives:

```
X(psi or (top U psi)) in M_n
```

Therefore:

```
psi or (top U psi) in x_content(M_n)
```

Since `psi not in M_n`, and MCS negation completeness gives `neg(psi) in M_n`, the formula `X(neg(psi))` may or may not be in `M_n`. What matters is the disjunction: in `x_content(M_n)`, we have `psi or (top U psi)`. If `psi not in x_content(M_n)`, then `(top U psi) in x_content(M_n)`.

But even if `(top U psi) in x_content(M_n)`, this does **not** mean `(top U psi) in M_{n+1}`, because **M_{n+1} is not x_content(M_n)**.

### 5.3. Where the Proof Breaks

`M_{n+1}` is a **Lindenbaum extension** of the seed `{target} union temporal_box_g_seed(M_n)`, where `target` is the resolution formula for the current scheduling step.

The seed `temporal_box_g_seed(M_n)` consists of:
- `G_theory(M_n) = {G(a) | G(a) in M_n}` -- G-wrapped formulas
- `box_theory(M_n)` -- modal formulas and their negations
- `g_content(M_n) = {a | G(a) in M_n}` -- formulas under G

**The formula `(top U psi)` is in `x_content(M_n)` but NOT in `g_content(M_n)`** (in general).

For `(top U psi)` to be in `g_content(M_n)`, we would need `G(top U psi) in M_n`. But `(top U psi) -> G(top U psi)` is **not derivable**: semantically, `top U psi` at time `t` means "`psi` holds at some `s > t` and `top` holds for all `t < t' < s`", whereas `G(top U psi)` means "at all `u > t`, `top U psi` holds at `u`." These are independent properties.

Since `(top U psi)` is not in the seed, the Lindenbaum extension is free to place either `(top U psi)` or its negation into `M_{n+1}`. Nothing in the construction forces `(top U psi)` to survive.

### 5.4. Formal Characterization of the Gap

The proof obligation reduces to showing:

> `(top U psi)` is consistent with `{target} union temporal_box_g_seed(M_n)`

where `target` is the resolution formula for step `n+1`. If this consistency held, we could include `(top U psi)` in the seed and the Lindenbaum extension would preserve it.

But proving this consistency requires a **G-lift argument for Until formulas**, and Until formulas are not G-liftable. Specifically: if `L subset temporal_box_g_seed(M_n)` and `L |- neg(top U psi)`, we need to derive a contradiction. The G-lift technique gives `G(neg(top U psi)) in M_n`. But `G(neg(top U psi)) in M_n` and `(top U psi) in M_n` are **not contradictory under strict semantics**: `G(neg(top U psi))` says "at all future times, `top U psi` fails," while `(top U psi)` says "at the current time, `psi` will eventually hold." Under strict semantics (where `G` excludes the current time), both can coexist.

Formally: `(top U psi) in M_n` means `neg(top U psi) not in M_n`. But `G(neg(top U psi)) in M_n` does NOT imply `neg(top U psi) in M_n` because the T-axiom `G(alpha) -> alpha` is invalid under strict semantics.

**This is the fundamental obstruction.** The G-lift argument, which is the sole consistency technique available for the Lindenbaum seed, cannot handle Until formulas because Until formulas are not G-liftable.

---

## 6. Why g_content Propagation Is Insufficient

### 6.1. What g_content Gives

The dovetailed chain guarantees `g_content(M_n) subset M_{n+1}`. This means: if `G(phi) in M_n`, then `phi in M_{n+1}`.

### 6.2. Why This Does Not Help Until

The Until formula `(top U psi)` satisfies `(top U psi) in x_content(M_n)` but to get it into `g_content(M_n)`, we need `G(top U psi) in M_n`.

The natural attempt: from `(top U psi) in M_n`, derive `G(top U psi) in M_n`.

This would require a theorem of the form:

```
(top U psi) -> G(top U psi)
```

But this is **semantically false**. Counter-model: a timeline where `psi` is true at time 2 and false everywhere else. At time 0, `top U psi` holds (psi holds at time 2). At time 1, `top U psi` holds (psi holds at time 2). At time 3, `top U psi` fails (psi is false at all future times). So `G(top U psi)` fails at time 0.

### 6.3. The X vs G Distinction

The crucial asymmetry:
- **Until Unfold produces X-formulas**: `(phi U psi) -> X(psi or (phi and (phi U psi)))`. The `X` is a **one-step** operator.
- **g_content captures G-formulas**: `g_content(M) = {phi | G(phi) in M}`. The `G` is a **universal future** operator.

`X` and `G` are fundamentally different under strict semantics:
- `X(phi) in M` means `phi` at the immediately next time.
- `G(phi) in M` means `phi` at all strictly future times.

The deterministic chain uses `x_content` (capturing X), so Until Unfold lands directly in the next step. The dovetailed chain uses `g_content` (capturing G), so Until Unfold's X-output falls outside the propagation mechanism.

### 6.4. The Deferral Case in Detail

When `(top U psi) in M_n` and `psi not in M_n`, the Until Unfold deferral case gives:

```
top and (top U psi) in x_content(M_n)
```

Since `top` is always in an MCS, this reduces to `(top U psi) in x_content(M_n)`.

For the deterministic chain, `chain(n+1) = x_content(chain(n))`, so `(top U psi) in chain(n+1)`. Done.

For the dovetailed chain, `chain(n+1)` is a Lindenbaum extension that contains `g_content(chain(n))` but not necessarily `x_content(chain(n))`. The formula `(top U psi)` is in `x_content` but not `g_content`, so it may not survive the step.

---

## 7. The Enhanced Seed Idea and Its Status

### 7.1. The Proposal

Include Until obligations in the Lindenbaum seed. Specifically, define an enhanced seed:

```
enhanced_seed(M) = temporal_box_g_seed(M) union { (top U psi) | (top U psi) in M and psi not in M }
```

If this enhanced seed is consistent (when combined with the resolution formula `{target}`), then the Lindenbaum extension preserves all active Until obligations.

### 7.2. Why Consistency Fails

The G-lift argument requires that every element `x` of the seed satisfies `G(x) in M`. For `(top U psi)` in the seed, we need `G(top U psi) in M`. As shown in Section 6.2, this is not derivable from `(top U psi) in M`.

Suppose we try to prove `{target} union enhanced_seed(M)` is consistent by contradiction. Assume `L |- bot` where `L subset {target} union enhanced_seed(M)`. Partition `L` into:
- `L_seed subset temporal_box_g_seed(M)` -- elements that ARE G-liftable
- `L_until` -- elements of the form `(top U psi_i)` that are NOT G-liftable

If `L_until` is nonempty, the G-lift argument cannot proceed. We need `G(neg(target)) in M` to derive a contradiction with `F(target) in M`, but the derivation `L_seed union L_until |- bot` only gives us `L_seed |- (neg of conjunction of L_until) or neg(target)`. G-lifting `L_seed` gives `G(rhs) in M`, but `rhs` involves negations of Until formulas, not a clean `neg(target)`.

### 7.3. Alternative Consistency Arguments

**Until Induction argument**: The Until Induction axiom states:

```
G(psi -> chi) and G((phi and X(chi)) -> chi) -> ((phi U psi) -> X(chi))
```

One could try to instantiate this with specific `chi` to derive information about Until formulas. However, this axiom gives `X(chi)` as output, not information about Until persistence. It was explored and found insufficient because the premise `G(psi -> chi)` requires a universal G-statement that is unavailable.

**Modified chain with x_content base**: One could define `chain(n+1)` as a Lindenbaum extension of `x_content(M_n) union {target}`. But `x_content(M_n)` is already an MCS (hence maximal), so `x_content(M_n) union {target}` is inconsistent unless `target in x_content(M_n)`. This reduces to the deterministic chain and loses the ability to resolve F-obligations.

**F-persistence tracking**: Instead of preserving Until formulas, preserve F-formulas directly: include `{F(psi) | F(psi) in M_n}` in the seed. But `F(psi) = neg(G(neg(psi)))`, and for the G-lift argument we need `G(F(psi)) = G(neg(G(neg(psi)))) in M_n`. There is no axiom guaranteeing `G(neg(G(neg(psi)))) in M_n` when `F(psi) in M_n`. So F-formulas are also not G-liftable.

### 7.4. Assessment

The enhanced seed idea is blocked at the consistency proof stage. All known variants of the idea encounter the same obstruction: the G-lift argument is the only available technique for proving seed consistency, and Until/F-formulas are not G-liftable.

---

## 8. What Published Proofs Do Differently

### 8.1. Burgess (1984)

Burgess's completeness proof for Until temporal logic uses a **filtration/canonical model** approach where the canonical model is built from all MCSes simultaneously, with the temporal ordering defined by the Succ relation. F-obligations are resolved by the **canonical model's own structure**: since the model contains all MCSes as worlds, for any MCS `M` with `F(psi) in M`, there exists another MCS `W` in the model with `psi in W` and `M Succ W` (by the temporal witness lemma). Burgess does not need to build a single chain and prove F-persistence within it.

### 8.2. Goldblatt (1992)

Goldblatt's approach in *Logics of Time and Computation* uses a similar canonical model construction with all MCSes as worlds. The accessibility relation is defined globally. The key difference from our setting: Goldblatt works with **reflexive** temporal semantics (where `G(phi) -> phi` is valid), which eliminates the strict-semantics gap that makes G-lifting insufficient for Until formulas.

### 8.3. Gabbay, Hodkinson, Reynolds (GHR, 1994)

The GHR approach in *Temporal Logic: Mathematical Foundations and Computational Aspects* uses **quasimodels** (sometimes called "runs" or "histories"). The construction:

1. Build a labeled graph where nodes are MCSes and edges represent the temporal successor relation.
2. Extract maximal paths (runs) through this graph.
3. Show that each run satisfies all coherence conditions, including Until/F-resolution.

The critical insight: GHR's construction does not try to build a single chain incrementally. Instead, it constructs the entire model globally and then extracts paths. F-obligations are resolved because the global model contains witnesses, and Until persistence is a property of paths through the pre-existing model, not of an incremental construction.

### 8.4. Why Our Approach Differs

Our formalization builds chains **incrementally** (step by step) rather than constructing a global canonical model. This approach was chosen because:

1. It maps naturally to the FMCS/BFMCS structure needed for the parametric truth lemma.
2. It avoids the complexity of building and reasoning about a global canonical model in Lean.
3. The deterministic chain works perfectly for G/H coherence.

However, the incremental approach creates the Until Transfer problem: at each step, we must choose a single successor MCS, and Until formulas from the previous step may not survive the Lindenbaum extension. The global approaches of Burgess, Goldblatt, and GHR avoid this by having all witnesses available simultaneously.

---

## 9. Summary of the Obstruction

The Until Transfer Lemma gap is located at exactly one sorry:

**File**: `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean`
**Theorem**: `forward_dovetailed_until_persists` (line ~585)
**Symmetric sorry**: `backward_dovetailed_since_persists` (line ~979)

The obstruction is:

1. **Until Unfold produces X-formulas**: `(phi U psi) -> X(disjunction)`.
2. **The dovetailed chain propagates g_content, not x_content**: `g_content(M_n) subset M_{n+1}` but `x_content(M_n)` is not related to `M_{n+1}`.
3. **Until formulas are not G-liftable**: `(phi U psi) in M` does NOT imply `G(phi U psi) in M`, so Until formulas cannot enter `g_content`.
4. **The G-lift argument is the only consistency technique**: Without G-liftability, there is no known way to include Until formulas in the Lindenbaum seed while maintaining provable consistency.
5. **Strict semantics removes the T-axiom safety net**: Under reflexive semantics, `G(alpha) -> alpha` would allow `G(neg(top U psi)) in M` to contradict `(top U psi) in M`. Under strict semantics, these can coexist.

The upstream consequence: `forward_dovetailed_forward_F` (which proves forward_F for the dovetailed chain) depends on `forward_dovetailed_until_persists` and inherits the sorry. This propagates to `deterministic_forward_F` and `deterministic_backward_P` in `DeterministicFMCS.lean`, which are the only two sorries blocking the completeness theorem.

---

## 10. Possible Resolution Paths

### 10.1. Global Canonical Model (GHR-Style)

Replace the incremental chain construction with a global canonical model where:
- Worlds = all MCSes in the box class of `M_0`
- Temporal successor = Succ relation
- Extract integer-indexed paths for FMCS construction

This avoids the Until Transfer problem entirely because Until persistence is a property of the Succ relation, not of incremental seed consistency. **Cost**: Major architectural change; requires building the Succ relation machinery and path extraction in Lean.

### 10.2. Hybrid Chain: Deterministic Base + F-Patching

Use the deterministic chain (which has sorry-free Until persistence) as the base, then patch F-obligations by switching families:
- For each unresolved `F(psi)` at time `t`, construct a witness family where `psi` appears at some `s > t`.
- Use the BFMCS bundle structure to include all needed families.

**Challenge**: This requires proving that the witness family agrees on modal formulas with the base family, which is already proven (`box_class_agree`). The question is whether the parametric completeness machinery supports this "family switching" approach. This is essentially what the current BFMCS bundle already does for modal formulas.

### 10.3. Enriched Deterministic Chain

Modify the deterministic chain to resolve F-obligations at certain steps by replacing `x_content(chain(n))` with a witness MCS when an F-obligation is targeted. This is essentially the dovetailed chain but starting from a deterministic base. The Until Transfer problem reappears at the modified steps.

### 10.4. Task Decomposition

Mark `forward_F` as requiring a fundamentally different proof approach (global canonical model) and create a separate task for that architectural change, with the current incremental chain providing all other coherence properties.
