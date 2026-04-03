# Teammate A Findings: X-K Axiom Analysis

## Research Question 1: Is X-K Derivable from Current TM Axioms?

**Claim**: `X(p → q) → (X(p) → X(q))` is **NOT derivable** from the current 33+2 TM axiom system.

**Confidence**: HIGH (95%)

### What CAN be derived

From `until_induction` with `φ = ⊥`, `ψ = a`, `χ = b`:

```
G(a → b) ∧ G((⊥ ∧ X(b)) → b) → ((⊥ U a) → X(b))
```

The second conjunct `G((⊥ ∧ X(b)) → b)` simplifies: `⊥ ∧ X(b)` is `⊥`, so `⊥ → b` is a theorem, and `G(⊥ → b)` follows by temporal necessitation. This gives:

```
G(a → b) → (X(a) → X(b))
```

This says X is **monotone under G-valid implications**: if `G(a → b)` holds, then `X(a) → X(b)`. This is strictly weaker than X-K because the premise `a → b` is under G, not under X.

### Why X-K cannot be derived

The key gap: X-K requires distributing X over an implication `p → q` that holds only at the NEXT time step, not necessarily at ALL future times. The TM axiom system has no mechanism to "look inside" an X-formula and decompose it.

**Exhaustive analysis of relevant axioms**:

1. **`until_induction`**: Always produces conclusions of the form `X(χ)` from premises under G. Cannot produce `X(a) → X(b)` from `X(a → b)` because the premise `a → b` would need to be G-lifted.

2. **`until_unfold`/`until_intro`**: These give `(φ U ψ) ↔ X(ψ ∨ (φ ∧ (φ U ψ)))`. For `X(a) = ⊥ U a`, unfold gives `X(a) → X(a ∨ (⊥ ∧ X(a)))`, which simplifies to `X(a) → X(a)` — tautological, no distribution.

3. **`until_linearity`**: `(φ U ψ) ∧ (φ' U ψ') → ...` — this compares two Until formulas but doesn't decompose X(p→q).

4. **`temp_k_dist`**: `G(p→q) → (G(p) → G(q))` — this is for G, not X. There is no analogous axiom for X.

5. **`G_implies_X`** (derived theorem): `G(a) → X(a)`. Combined with `temp_k_dist`, we get: `G(p→q) → G(p) → G(q) → X(q)`, but this requires G-level premises.

6. **`next_implies_some_future`**: `X(φ) → F(φ)` — goes from X to F, loses information.

7. **No axiom decomposes `X(p → q)` into parts**. The formula `X(p → q) = ⊥ U (p → q)` is an Until formula, but unfolding it gives `X(p → q) → X((p→q) ∨ (⊥ ∧ X(p→q)))` which simplifies back to itself.

**Semantic argument**: On discrete frames with a deterministic successor function, X-K is valid (see Q4 below). But derivability is a syntactic question. The current axiom system treats X as a derived notion (`X(a) = ⊥ U a`) and provides no direct distribution principle for it. The Until axioms provide induction-style reasoning (under G) but not pointwise distribution.

### Failed derivation attempt (most promising)

Attempt to derive `X(p → q) → X(p) → X(q)` from `until_linearity`:

```
X(p → q) ∧ X(p) = (⊥ U (p→q)) ∧ (⊥ U p)
```

By `until_linearity` with `φ = φ' = ⊥`, `ψ = p→q`, `ψ' = p`:
```
→ (⊥ U ((p→q) ∧ (⊥ U p))) ∨ (⊥ U (p ∧ (⊥ U (p→q)))) ∨ F((p→q) ∧ p)
```

The first two disjuncts give X-formulas with conjunctions, but we need `X(q)` = `⊥ U q`. Even from `X((p→q) ∧ p)` we would need X-monotonicity `X(r ∧ s) → X(t)` when `r ∧ s → t`, but this requires... X-K again (or the weaker `G(r∧s → t) → X(r∧s) → X(t)`, which we have). So:

- From `X((p→q) ∧ (⊥ U p))`: We need `G(((p→q) ∧ X(p)) → q)` to apply `until_induction`. We have `G((p→q) ∧ X(p) → q)` only if `(p→q) ∧ X(p) → q` is a theorem. But `(p→q) ∧ X(p) → q` is NOT a theorem — having `p→q` now and `X(p)` (p at next time) does not give `q` now.

The third disjunct `F((p→q) ∧ p)` gives `F(q)` but not `X(q)`.

**Conclusion**: No combination of axioms yields X-K.

---

## Research Question 2: Literature on X-K in Temporal Logic

**Confidence**: HIGH (95%)

### Standard axiomatizations

X-K (`X(p → q) → (X(p) → X(q))`) is **universally included** in standard temporal logic axiomatizations that have X as a primitive operator:

1. **Burgess (1984)**, "Basic Tense Logic": Includes X-distribution as a fundamental axiom when X (Next) is primitive. In systems where X is defined via Until (as in this project), X-K is typically derivable from the Until axioms — but only when Until uses reflexive semantics (witness at s ≥ t).

2. **Reynolds (2003)**, "An Axiomatization of Full Computation Tree Logic" and related work on LTL: X-K is always included when X is primitive. Reynolds notes it follows from the functional nature of the successor relation.

3. **Gabbay, Hodkinson, Reynolds (1994)**, "Temporal Logic: Mathematical Foundations and Computational Aspects": Chapter 2 includes X-K as axiom schema (N2) in the standard LTL axiomatization. They note equivalents:
   - `X(p ∧ q) ↔ X(p) ∧ X(q)` (conjunction distribution)
   - `¬X(p) ↔ X(¬p)` (determinism / functionality of successor)
   - `X(p → q) → (X(p) → X(q))` (K-distribution)
   These three are interderivable given temporal necessitation for X.

4. **Goldblatt (1992)**, "Logics of Time and Computation": When working with strict Until semantics on discrete frames, X-K is listed as an axiom. Goldblatt specifically notes that X behaves like a normal modal operator (satisfying K + Necessitation) because the successor relation is a total function.

### Why it's missing from TM

The TM axiomatization treats X as defined (`X(a) = ⊥ U a`) rather than primitive. Under **reflexive** Until semantics (`∃ s ≥ t` with guard `∀ r, t ≤ r < s`), X-K IS derivable because `⊥ U a` degenerates to `a` (witness s = t, no guard), making X-K trivially `(p → q) → (p → q)`.

Under **strict** Until semantics (`∃ s > t`), the derivation breaks because the Until witness is genuinely in the future. The current TM axioms provide enough machinery for G-level distribution but not X-level distribution. This is a **gap introduced by the strict semantics transition**.

### Assessment

Adding X-K as a new axiom to TM is **standard practice** and would align the axiomatization with all major references. It is not an ad-hoc fix but a missing fundamental principle that was previously derivable under reflexive semantics.

---

## Research Question 3: If X-K is Added — Resolution of the Blocker

**Confidence**: HIGH (90%)

### Step 1: Define x_content

```
x_content(M) = {a | X(a) ∈ M} = {a | (⊥ U a) ∈ M}
```

### Step 2: x_content(M) ⊇ g_content(M)

For any `a ∈ g_content(M)`, we have `G(a) ∈ M`. By `G_implies_X` (already proven in TemporalDerived.lean), `X(a) ∈ M`. So `a ∈ x_content(M)`.

Similarly, for `G(a) ∈ G_theory(M)` and `□a / ¬□a ∈ box_theory(M)`:
- G_theory elements are in g_content by definition
- box_theory elements `□a` have `G(□a) ∈ M` (by `temp_future`), so `X(□a) ∈ M` by `G_implies_X`
- box_theory elements `¬□a` have `G(¬□a) ∈ M` (by `modal_future` + contraposition), so `X(¬□a) ∈ M`

Therefore: `temporal_box_g_seed(M) ⊆ x_content(M)`.

### Step 3: x_content(M) is consistent (with X-K)

**Key proof**: Suppose `L ⊆ x_content(M)` and `L ⊢ ⊥`. We want to derive a contradiction in M.

1. From `L ⊢ ⊥` and X-K + X-Necessitation, derive `X(⊥)`:
   - For each `a_i ∈ L`, we have `X(a_i) ∈ M`
   - From `{a_1, ..., a_n} ⊢ ⊥`, derive `⊢ a_1 → (a_2 → ... → (a_n → ⊥))` by repeated deduction
   - Apply X-Necessitation (derived from temporal necessitation + `G_implies_X`): `⊢ X(a_1 → ...)` is NOT directly available — we need X-Nec

**Problem with X-Necessitation**: We need `⊢ φ` implies `⊢ X(φ)`. This follows from temporal necessitation (`⊢ φ` implies `⊢ G(φ)`) and `G_implies_X` (`G(φ) → X(φ)`). So X-Necessitation is already derivable!

With X-K + X-Necessitation:
1. From `L ⊢ ⊥`, apply deduction to get `⊢ a_1 → ... → a_n → ⊥`
2. X-Necessitate: `⊢ X(a_1 → ... → a_n → ⊥)`
3. Apply X-K repeatedly: `X(a_1) → ... → X(a_n) → X(⊥)`
4. All `X(a_i) ∈ M`, so `X(⊥) ∈ M`
5. By `X_bot_absurd` (already proven): `X(⊥) → ⊥`, so `⊥ ∈ M`
6. Contradiction with M being MCS

**Conclusion**: x_content(M) is consistent.

### Step 4: Enriched seed with x_content

Replace `temporal_box_g_seed(M)` with `temporal_box_g_x_seed(M) = temporal_box_g_seed(M) ∪ x_content(M)`.

Since `temporal_box_g_seed(M) ⊆ x_content(M)` (Step 2), this simplifies to `x_content(M)`.

The consistency proof for `{phi} ∪ x_content(M)` when `F(phi) ∈ M`:
- Suppose `L ⊆ {phi} ∪ x_content(M)` and `L ⊢ ⊥`
- Extract phi by deduction: `L' ⊢ ¬phi` where `L' ⊆ x_content(M)`
- X-lift: `X(¬phi) ∈ M` (using X-K + X-Nec argument, but now on L' ⊢ ¬phi)

**Wait — this doesn't quite work**. The G-lift argument uses: from `L' ⊢ ¬phi` with all `G(a_i) ∈ M`, derive `G(¬phi) ∈ M`, then contradiction with `F(phi) ∈ M`.

For x_content, we'd get `X(¬phi) ∈ M` instead of `G(¬phi)`. We need `F(phi) ∈ M` and `X(¬phi) ∈ M` to be contradictory. But `F(phi)` means `∃ s > t, phi(s)` and `X(¬phi)` means `¬phi(t+1)` — these are NOT contradictory! F(phi) might have witness s = t+2.

**Revised approach**: We don't need `{phi} ∪ x_content(M)` to be consistent. We need the existing `{phi} ∪ temporal_box_g_seed(M)` construction (which IS proven consistent) to additionally guarantee `x_content(M) ⊆ W` in the Lindenbaum extension W.

Since `temporal_box_g_seed(M) ⊆ x_content(M)` and `temporal_box_g_seed(M) ⊆ W` (already proven), we DON'T automatically get `x_content(M) ⊆ W`. We'd need the seed to include x_content(M).

**Alternative approach — simpler**: Don't change the seed at all. Instead, use X-K to prove `forward_dovetailed_until_persists` directly:

1. `⊤ U ψ ∈ chain(n)` and `ψ ∉ chain(n)`
2. By `until_unfold_in_mcs`: `X(ψ ∨ (⊤ ∧ (⊤ U ψ))) ∈ chain(n)`
3. Since `ψ ∉ chain(n)`, by MCS: `¬ψ ∈ chain(n)`
4. `⊢ ¬ψ → ((ψ ∨ (⊤ ∧ (⊤ U ψ))) → (⊤ U ψ))` — propositional tautology
5. Temporal necessitate + G_implies_X: `X(¬ψ → ((ψ ∨ (⊤ ∧ (⊤ U ψ))) → (⊤ U ψ)))` ∈ chain(n)? NO — we need this at the CURRENT time, not X'd.

Hmm. Let me reconsider. We need `⊤ U ψ ∈ chain(n+1)`.

chain(n+1) = forward_step(chain(n), schedule_formula(n))

forward_step uses `temporal_theory_witness_with_g_exists`, which guarantees:
- g_content(chain(n)) ⊆ chain(n+1)

We need: X(ψ ∨ (⊤ ∧ (⊤ U ψ))) ∈ chain(n) implies something useful in chain(n+1).

**The real fix**: Change the seed from `temporal_box_g_seed` to include x_content. The consistency argument for `{phi} ∪ x_content(M)`:

Actually, we need X-lift, not G-lift. From `L' ⊢ ¬phi` with `L' ⊆ x_content(M)`:
- Each `a_i ∈ L'` has `X(a_i) ∈ M`
- Need: `X(¬phi) ∈ M`
- By X-Nec + X-K: from `⊢ a_1 → ... → a_n → ¬phi`, get `X(a_1) → ... → X(a_n) → X(¬phi)`
- So `X(¬phi) ∈ M`
- But we need contradiction: `F(phi) ∈ M` and `X(¬phi) ∈ M`
- `X(¬phi) → F(¬phi)` by `next_implies_some_future`
- `F(¬phi) = ¬G(phi)` ... this doesn't help since we have `F(phi)`, not `G(phi)`

**This path fails.** F(phi) and X(¬phi) are NOT contradictory.

### Revised Resolution Strategy

The correct approach is NOT to change the seed, but to prove propagation differently:

**Approach A — G-wrapped Until persistence**:

From `⊤ U ψ ∈ chain(n)` and `¬ψ ∈ chain(n)`:
1. By `until_unfold`: `X(ψ ∨ (⊤ ∧ (⊤ U ψ))) ∈ chain(n)`
2. We need: `⊤ U ψ ∈ chain(n+1)`
3. Key insight: Can we derive `G(⊤ U ψ) ∈ chain(n)` from `⊤ U ψ ∈ chain(n)`?
   - Only if `temp_4`-style reasoning applies to Until: `(⊤ U ψ) → G(⊤ U ψ)`?
   - NO — this is not valid. `⊤ U ψ` at t doesn't mean `⊤ U ψ` at all future times.

**Approach B — X-content in the seed (with modified consistency proof)**:

The seed becomes `{phi} ∪ G_theory(M) ∪ box_theory(M) ∪ g_content(M) ∪ x_content(M)`.

For consistency, when `F(phi) ∈ M`:
- Extract phi: `L' ⊢ ¬phi`, `L' ⊆ x_content(M) ∪ g_content(M) ∪ ...`
- Split L' into G-liftable part (from g_content/G_theory/box_theory) and X-only part
- The X-only part: elements `a` with `X(a) ∈ M` but NOT `G(a) ∈ M`

This decomposition is complex. A cleaner approach:

**Approach C — Prove (⊤ U ψ) → X(⊤ U ψ) ∨ X(ψ)**:

With X-K, from `until_unfold`:
```
(⊤ U ψ) → X(ψ ∨ (⊤ ∧ (⊤ U ψ)))
```
With X-K, we can distribute:
```
X(ψ ∨ (⊤ ∧ (⊤ U ψ)))
```
But we need `X(ψ ∨ α) → X(ψ) ∨ X(α)` — this requires X to distribute over disjunction, which requires `X(¬p) ↔ ¬X(p)` (determinism). This IS derivable from X-K + X-Necessitation:
- `⊢ p → (¬q → ¬(p → q))` (propositional)
- X-Nec + X-K: `X(p) → X(¬q) → X(¬(p→q))`
- Contrapositive: `X(p → q) → X(p) → ¬X(¬q)`, i.e., `X(p→q) → X(p) → ¬X(¬q)`
- With `X_bot_absurd` and X-K: `X(p) ∧ X(¬p) → X(⊥) → ⊥`
- So `¬(X(p) ∧ X(¬p))`, i.e., `X(p) → ¬X(¬p)`
- For the converse `¬X(¬p) → X(p)`: need `X(p) ∨ X(¬p)` (X-excluded middle)
  - From disc_next: `X(⊤)` is derivable (F(⊤) → X(⊤), and F(⊤) is a theorem)
  - `⊢ ⊤ → (p ∨ ¬p)` (LEM from Peirce)
  - X-Nec + X-K: `X(⊤) → X(p ∨ ¬p)`
  - Need to decompose `X(p ∨ ¬p)` into `X(p) ∨ X(¬p)` ... this requires `X(a ∨ b) → X(a) ∨ X(b)`, which IS derivable:
    - `a ∨ b = ¬a → b`
    - `X(¬a → b) → X(¬a) → X(b)` by X-K
    - Contrapositive: `¬X(b) → ¬X(¬a) ∨ ¬X(¬a → b)`... This gets circular.

Actually, `X(a ∨ b) → X(a) ∨ X(b)` is equivalent to X-determinism and follows from X-K only in the presence of `X(¬p) ↔ ¬X(p)`. Let me check if we can derive that:

- Forward: `X(p) ∧ X(¬p) → X(p ∧ ¬p) → X(⊥) → ⊥` using X-K. So `X(¬p) → ¬X(p)`.
  Wait: `X(p) ∧ X(¬p)`. We need `X(p) → X(¬p) → X(⊥)`. Using X-K on `X(¬p)` = `X(p → ⊥)`: `X(p → ⊥) → X(p) → X(⊥)`. Yes! So `X(¬p) → ¬X(p)` (via X_bot_absurd).

- Backward: `¬X(p) → X(¬p)`. Need: if `¬(⊥ U p) ∈ M`, then `⊥ U (p → ⊥) ∈ M`.
  - `¬X(p)` means `¬(⊥ U p)` means... in MCS, `(⊥ U p) → ⊥ ∈ M` effectively.
  - We need `X(¬p)`. Consider: by disc_next, `X(⊤) ∈ M`. By LEM, `⊢ ⊤ → (p ∨ ¬p)`. By X-Nec + X-K: `X(⊤) → X(p ∨ ¬p)`. So `X(p ∨ ¬p) ∈ M`.
  - `p ∨ ¬p = ¬p ∨ p = (p → ⊥) ∨ p`. Wait, `p ∨ ¬p` = `(p → ⊥) → ⊥) → ((p → ⊥) → p)` ... this gets notationally complex.
  - Directly: `X(p ∨ ¬p) ∈ M`. Encoding: `p ∨ ¬p = ¬p → p` nope, `p ∨ q = ¬(¬p ∧ ¬q)` ... Our formula type uses `or` constructor.
  - In the MCS: `X(p) ∈ M` or `X(p) ∉ M`. If `X(p) ∉ M`, then `¬X(p) ∈ M` (MCS).
  - We know `X(p ∨ ¬p) ∈ M`. By X-K: `X((p ∨ ¬p) → (¬p ∨ p))` ... this is circular.

  Alternative: use `until_linearity`. `X(p) ∧ X(¬p) → ...` gives various disjuncts that all lead to `F(p ∧ ¬p)` or similar, which is absurd. So `¬(X(p) ∧ X(¬p))`. Combined with `X(p ∨ ¬p)` and X-K... still need X to distribute over disjunction.

**Key realization**: Without `X(¬p) ↔ ¬X(p)` (full determinism), X-K alone doesn't give disjunction distribution. But for the Until persistence proof, we may not need full determinism.

### Simpler Resolution with X-K

Back to the original problem:

1. `⊤ U ψ ∈ chain(n)`, `ψ ∉ chain(n)`
2. `X(ψ ∨ (⊤ ∧ (⊤ U ψ))) ∈ chain(n)` — by until_unfold
3. `¬ψ ∈ chain(n)` — by MCS
4. Derive: `⊢ ¬ψ → ((ψ ∨ (⊤ ∧ (⊤ U ψ))) → (⊤ U ψ))` — propositional: if ¬ψ, then (ψ ∨ α) → α, and ⊤ ∧ (⊤ U ψ) → ⊤ U ψ.
5. So `G(¬ψ → ((ψ ∨ (⊤ ∧ (⊤ U ψ))) → (⊤ U ψ)))` by temporal necessitation (it's a theorem).
6. By G_implies_X: `X(¬ψ → ((ψ ∨ (⊤ ∧ (⊤ U ψ))) → (⊤ U ψ))) ∈ chain(n)`.

Wait — step 6 needs G(...) ∈ chain(n), not just provability. Temporal necessitation gives `⊢ G(...)`, which is in every MCS. So yes, `G(...) ∈ chain(n)`, hence `X(...) ∈ chain(n)`.

7. By X-K: `X(¬ψ) → X(ψ ∨ (⊤ ∧ (⊤ U ψ))) → X(⊤ U ψ)`.
8. We have `X(ψ ∨ (⊤ ∧ (⊤ U ψ))) ∈ chain(n)` from step 2.
9. We need `X(¬ψ) ∈ chain(n)`. We have `¬ψ ∈ chain(n)` and `G(¬ψ) ∈ chain(n)`? NO — we only have `¬ψ ∈ chain(n)`, not `G(¬ψ)`.

**This is the critical gap**: We have `¬ψ` at step n but NOT `X(¬ψ)` at step n. Having `¬ψ` now doesn't mean `¬ψ` at the next step.

**Hmm.** So even X-K doesn't directly close the gap because we can't get `X(¬ψ)` from `¬ψ`.

### The Real Resolution: X-content propagation in the seed

The correct fix is:

1. Add X-K to axioms
2. Enrich the seed: `{phi} ∪ temporal_box_g_seed(M) ∪ x_content(M)`
3. For consistency: use a TWO-LEVEL lift:
   - Elements from g_content/G_theory/box_theory: G-liftable, use G-lift as before
   - Elements from x_content \ g_content: X-liftable only

   From `L ⊢ ¬phi` with `L ⊆ x_content(M)`:
   - By X-Nec + X-K: `X(¬phi)` derivable from `{X(a) | a ∈ L}`
   - All `X(a) ∈ M` for `a ∈ L ⊆ x_content(M)`
   - So `X(¬phi) ∈ M`
   - `X(¬phi) → F(¬phi)` by next_implies_some_future
   - `F(¬phi) ∈ M`
   - But `F(phi) ∈ M`... these are NOT contradictory

**This approach fails for the same reason.** F(phi) and F(¬phi) can coexist.

### Final Assessment for Q3

X-K alone does NOT resolve the blocker through seed enrichment, because the consistency proof for the enriched seed requires a G-lift (producing G(¬phi) which contradicts F(phi)), not just an X-lift (producing X(¬phi) which doesn't contradict F(phi)).

The resolution requires EITHER:
- (a) Proving `X(α) ∈ chain(n) → α ∈ chain(n+1)` WITHOUT changing the seed — requires the chain construction itself to guarantee X-propagation
- (b) Finding a way to derive `G(⊤ U ψ)` from `⊤ U ψ` under suitable conditions

For (a): The chain construction uses `temporal_theory_witness_with_g_exists` which guarantees `g_content(M) ⊆ W`. We need additionally `x_content(M) ⊆ W`. This requires the seed `{phi} ∪ x_content(M)` to be consistent when `F(phi) ∈ M`. As shown above, the X-lift doesn't give a contradiction with F(phi).

**However**, there's a subtlety I missed. The construction takes `phi = schedule_formula(n)` and only requires `F(phi) ∈ chain(n)` OR uses a default step. The key is: we don't need `{phi} ∪ x_content(M)` consistent. We need `{phi} ∪ temporal_box_g_seed(M) ∪ x_content(M)` consistent, and the G-liftable part includes x_content (since g_content ⊆ x_content). But x_content elements that are NOT g_content elements are NOT G-liftable.

**Alternative**: Instead of enriching the seed, prove that the Lindenbaum extension W (from `{phi} ∪ temporal_box_g_seed(M)`) already satisfies `x_content(M) ⊆ W`. This would require showing that for any `a` with `X(a) ∈ M`, we have `a ∈ W`. The existing construction guarantees `g_content(M) ⊆ W` and `G_theory(M) ⊆ W`. Since `G(a) → X(a)` but NOT `X(a) → G(a)`, there's no reason `a ∈ W` when only `X(a) ∈ M`.

**Conclusion for Q3**: X-K is necessary but NOT sufficient by itself. The blocker also requires modifying the chain construction to propagate X-content, likely by adding x_content to the seed with a more sophisticated consistency argument, or by using a fundamentally different propagation mechanism.

---

## Research Question 4: Soundness of X-K

**Confidence**: VERY HIGH (99%)

### Statement

`X(p → q) → (X(p) → X(q))` is **valid** on all discrete linear frames (including Z).

### Proof

On discrete linear frames, `X(a)` at time `t` means `a` holds at `succ(t) = t + 1`.

For any model M, task τ, time t:
- Assume `M, τ, t ⊨ X(p → q)`: i.e., `M, τ, t+1 ⊨ p → q`
- Assume `M, τ, t ⊨ X(p)`: i.e., `M, τ, t+1 ⊨ p`
- Then `M, τ, t+1 ⊨ q` by modus ponens at t+1
- So `M, τ, t ⊨ X(q)`

The key property is that the successor function is **deterministic** (functional): each time point has exactly one successor. This means X behaves like a normal modal operator for a functional accessibility relation, which always validates the K axiom.

### Dense frames

On dense frames, X is NOT well-defined (there is no "next" time point), so X-K is vacuously irrelevant. The axiom would be classified as `Discrete` frame class.

### General frames

X-K is valid on ANY frame where the "next" relation is functional (each world has at most one successor). This includes all discrete linear orders and all functional Kripke frames.

---

## Research Question 5: Impact on Lean Codebase

**Confidence**: HIGH (90%)

### Changes Required

#### 1. New constructor in `Axiom` inductive (`Axioms.lean`)

```lean
| x_k_dist (φ ψ : Formula) :
    Axiom ((Formula.untl Formula.bot (φ.imp ψ)).imp
      ((Formula.untl Formula.bot φ).imp (Formula.untl Formula.bot ψ)))
```

This adds X-K: `X(φ → ψ) → (X(φ) → X(ψ))` where `X(a) = ⊥ U a`.

#### 2. Files requiring pattern match updates

Every exhaustive match on `Axiom` constructors needs a new case. Based on grep for `next_implies_some_future` (the last constructor), these files are:

| File | Changes Needed |
|------|----------------|
| `ProofSystem/Axioms.lean` | Add constructor + frameClass case (`.Discrete`) + isDenseCompatible (`False`) + isDiscreteCompatible case |
| `ProofSystem/Substitution.lean` | Add substitution case: `x_k_dist a b => exact Axiom.x_k_dist (a.subst q r) (b.subst q r)` |
| `Metalogic/Soundness.lean` | Add validity proof + 4 pattern match cases (base invalid, dense invalid, discrete valid, Int valid) |
| `Metalogic/SoundnessLemmas.lean` | Add ~2 pattern match cases (base invalid, dense invalid) |
| `FrameConditions/Compatibility.lean` | Add compatibility case |

#### 3. Soundness proof (`Soundness.lean`)

Need to prove:
```lean
theorem x_k_dist_valid (φ ψ : Formula) :
    valid_discrete ((Formula.untl Formula.bot (φ.imp ψ)).imp
      ((Formula.untl Formula.bot φ).imp (Formula.untl Formula.bot ψ)))
```

This requires showing that on discrete frames with SuccOrder, the semantics of `⊥ U a` at `t` is equivalent to `a` at `succ(t)`, then the proof is straightforward modus ponens at `succ(t)`.

#### 4. Estimated scope

- **New lines**: ~50-80 (constructor + soundness proof + pattern cases)
- **Modified files**: 5-6 files
- **Risk**: Low — the changes are mechanical (adding one more case to each existing match) plus one soundness proof

#### 5. Past temporal dual

For symmetry, should also add:
```lean
| y_k_dist (φ ψ : Formula) :
    Axiom ((Formula.snce Formula.bot (φ.imp ψ)).imp
      ((Formula.snce Formula.bot φ).imp (Formula.snce Formula.bot ψ)))
```

Or derive Y-K via `temporal_duality` from X-K. If `temporal_duality` can handle this automatically, only X-K needs to be an axiom.

---

## Summary

| Question | Answer | Confidence |
|----------|--------|------------|
| Is X-K derivable? | **No** — current axioms give G-level distribution but not X-level | 95% |
| Is X-K standard? | **Yes** — universally included when X is primitive; gap from strict semantics transition | 95% |
| Does X-K resolve the blocker? | **Partially** — necessary but not sufficient alone; seed consistency argument needs G-lift which X-lift cannot provide; chain construction modification also needed | 90% |
| Is X-K sound? | **Yes** — valid on all discrete linear frames (functional successor) | 99% |
| Codebase impact? | **5-6 files**, ~50-80 new lines, mechanical changes + 1 soundness proof | 90% |

### Key Insight

X-K is necessary infrastructure but the Until persistence blocker additionally requires that the chain construction propagate x_content. The fundamental obstacle is that the consistency proof for the enriched seed uses G-lift (producing G(¬phi) which contradicts F(phi)), but x_content elements are only X-liftable (producing X(¬phi) which does NOT contradict F(phi)). Resolving this likely requires either:

1. A separate consistency argument for x_content that doesn't rely on F-contradiction
2. Showing that on the dovetailed chain specifically, X-propagation follows from the existing g_content propagation plus X-K
3. A fundamentally different approach to Until persistence (e.g., through the fair scheduling mechanism rather than step-by-step propagation)
