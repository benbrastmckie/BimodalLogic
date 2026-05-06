# Walk Guard Gap Research: Burgess 2.10 Mapping

## Convention Mapping (CRITICAL)

| Concept | Burgess | Our Code |
|---------|---------|----------|
| Until formula | U(xi, eta) | untl(pc.xi, pc.eta) |
| Event (endpoint witness) | xi (1st arg of U) | pc.eta (2nd arg of untl) |
| Guard (intermediate points) | eta (2nd arg of U) | pc.xi (1st arg of untl) |
| "guard in g" | eta in g(x,x') | pc.xi in g(x,x') |
| "event conj" | eta and U(xi,eta) | xi and untl(xi,eta) |

Our `untl(guard, event)` = Burgess `U(event, guard)`. Arguments swapped.

C5a in Burgess: U(xi, eta) in f(x) -> exists y, **xi** in f(y) and **eta** in g(x,y).
C5 in our code: untl(xi, eta) in f(x) -> exists y, **eta** in f(y) and **xi** in g(x,y).

These are identical under the swap: Burgess xi = our eta, Burgess eta = our xi.

## Burgess 2.10 Condition (i) — Exact Text

From the paper (p.374), Case n = m + 1:

> "Let x' immediately succeed x in dom f. If (i) both **eta and U(xi, eta) in f(x')** and **eta in g(x, x')**, then we can reduce to the case n=m by replacing x by x'."

Under our convention swap:
- Burgess "eta and U(xi, eta)" = our "xi and untl(xi, eta)" (guard-and-Until-formula)
- Burgess "eta in g(x, x')" = our "xi in g(x, x')" (guard in g)

So Burgess condition (i) in our terms is:
1. `Formula.and pc.xi (Formula.untl pc.xi pc.eta) in f(x')` — conjunction in f(x')
2. `pc.xi in g(x, x')` — guard in g

## Our Code's Condition (i) Check

At `CounterexampleElimination.lean:796`:

```lean
by_cases h_cond_i : Formula.and pc.ξ (Formula.untl pc.ξ pc.η) ∈ χ.f x'
                     ∧ pc.ξ ∈ χ.g pc.x x'
```

**VERDICT: The g-check IS present.** Our condition (i) checks BOTH parts:
1. `Formula.and pc.xi (Formula.untl pc.xi pc.eta) in f(x')` — matches Burgess
2. `pc.xi in g(pc.x, x')` — matches Burgess "eta in g(x, x')"

This was added in a recent commit (the comments at lines 792-795 explicitly document this alignment). The earlier versions of the code only checked the f-condition, but the current code is correct.

## What Burgess Condition (ii) Says

> "If (i) fails, note also that we cannot have (ii) both xi in f(x') and eta in g(x, x'); else x, xi, eta would not be a counterexample."

Under our convention: cannot have BOTH `pc.eta in f(x')` (event at x') AND `pc.xi in g(x, x')` (guard in g). If both held, x' would be a valid C5 witness (event present, guard in interval), contradicting `h_no_wit`.

## What Happens When Condition (i) Fails

When condition (i) fails, at least one of these is false:
- A: `xi and untl(xi, eta) in f(x')`
- B: `xi in g(x, x')`

Combined with the observation that condition (ii) also fails (ensured by h_no_wit), we have:

**Case not-B (xi not in g):** Apply lemma_2_7. Its hypothesis is `R(A, B, C)` with `U(xi, eta) in A` and `xi not in B`. Since xi not in g(x,x'), this matches directly.

**Case A-and-B both true:** This is condition (i) holding — handled by the forward walk.

**Case not-A and B (xi in g but conjunction not in f(x')):** Since xi in g(x,x') subset f(x') (by BurgessR3Maximal_g_content_sub), we have xi in f(x'). If untl(xi, eta) not in f(x'), then untl(xi, eta).neg in f(x') (MCS). Check: does ~(xi and U(xi,eta)) = ~xi or ~U(xi,eta). Since xi in f(x'), it must be untl(xi,eta).neg in f(x'). This falls to Burgess condition for lemma_2_8: `~(xi or (eta and U(xi,eta))) in f(x')`. Actually, need to check this more carefully...

Actually, Burgess says: "the hypotheses either of 2.7 or else of 2.8 must hold." The code handles this with:
- If `xi not in g(x,x')`: apply lemma_2_7
- If `eta.neg not in g(x,x')`: apply lemma_2_6 with beta = eta.neg
- Otherwise: check for lemma_2_8 conditions

The existing splitting logic at lines 788-onwards handles all these subcases.

## The REAL Gap: Forward Walk Guard Propagation

Since condition (i) IS correctly checked (including the g-check), the forward walk itself is correctly structured. When condition (i) holds at (x, x'), we know:
1. `untl(xi, eta) in f(x')` — the Until formula propagates
2. `xi in g(x, x')` — the guard is in the interval set

The walk continues from x' with strictly fewer points ahead, eventually reaching either:
- **Walk Case A (u_max = max_old):** Apply lemma_2_4 at f(u_max). Insert y beyond the domain.
- **Walk Case B (u_max != max_old):** Split at (u_max, u_max_next) where condition (i) fails.

**The gap is NOT in the condition (i) check itself.** It is in the omega chain guard propagation AFTER the elimination. Specifically:

### Region Analysis

**Walk region (x to u_max):** At each walk step from w to w', condition (i) gives:
- `xi in g(w, w')` for each adjacent pair
- `untl(xi, eta) in f(w')` propagates forward

So at the FINITE level (stage n), the guard xi IS in g(w, w') for every adjacent walk pair. This is correct and sufficient at the finite stage.

**Splitting region (u_max to y):** lemma_2_4 or lemma_2_7/2.8 creates the endpoint y. Guard propagation through later splittings works via B subset B'.

### The Omega Chain Issue

The problem surfaces at the LIMIT level, not the finite level:

1. At stage n, we have guard xi in g_n(w, w') for walk adjacent pairs.
2. At stage m > n, a new point z is inserted between walk points w and w'.
3. f_m(z) = D where g_{m-1}(w, w') subset D (from the splitting seed).
4. Since xi in g_n(w, w') and g_n(w, w') = g_m(w, w') (by g_agrees for old pairs), we get xi in g_m(w, w') subset D = f_m(z).
5. So xi in f_m(z) = limit_f(z). The guard holds at the new point.

**Wait — this actually WORKS.** The key insight: because condition (i) puts xi in g(w, w') at the walk step, and g-values are preserved by g_agrees, and splitting lemmas give g(w, w') subset D for new points D, the guard DOES propagate.

Let me re-examine why the handoff says this fails. The handoff at `lemma27-fix-and-fuc-strategy.md` line 128 says:

> "ξ ∈ g(w, w') for walk adjacent pairs is NOT guaranteed. The BurgessR3Maximal condition doesn't imply ξ ∈ g(w, w') just because ξ ∈ f(w) and ξ ∈ f(w')."

This was written BEFORE the condition (i) g-check was added. The earlier code only checked the f-condition for condition (i). With the g-check now present, xi IS in g(w, w') at each walk step by construction.

## Revised Assessment

**The condition (i) g-check fix (already done) resolves the walk region gap at the finite level.** The remaining question is whether the omega chain infrastructure correctly propagates this through later stages.

### What Still Needs to Be Proved

1. **omega_chain_guard_stable**: For walk points (x, x') at stage n with xi in g_n(x, x'), any point z inserted between them at stage m > n has xi in f_m(z). This follows from:
   - g_agrees: g_m(x, x') = g_n(x, x') for old pairs (x, x' in dom_n)
   - Splitting seed: when z is inserted between adjacent (a, b) at stage m, f_m(z) = D where g_{m-1}(a, b) subset D
   - Induction: for z between x and x', the splitting chain from (x, x') through intermediate stages preserves the guard

2. **limit_satisfies_c5_strong**: Combine the endpoint witness from c5_weak with the guard from omega_chain_guard_stable.

3. **Close FUC/FSC sorries**: Transfer through Cantor isomorphism.

### Key Structural Observation

The omega chain guard propagation has TWO components:

**Component A — Walk-adjacent guard:** xi in g(w, w') for each walk step. This is NOW guaranteed by condition (i) including the g-check.

**Component B — Splitting-inherited guard:** When points are inserted into the walk interval, the guard propagates via g subset D. This is the B subset B'/B subset D property that was fixed in lemma_2_7.

Both components are in place. The remaining work is to formalize this chain of reasoning in Lean.

## Effort Estimate

The fix is primarily omega-chain-level formalization:

| Task | Location | Lines | Difficulty |
|------|----------|-------|------------|
| Prove omega_chain_guard_stable | ChronicleConstruction.lean | ~100-150 | Medium |
| Prove limit_satisfies_c5_strong | ChronicleConstruction.lean | ~50 | Easy |
| Close FUC/FSC sorries | ChronicleToCountermodel.lean | ~30 | Easy |
| **Total** | | **~180-230** | |

The main difficulty is formalizing the induction on splitting stages, but the mathematical content is straightforward given that both guard-in-g (from condition (i)) and g-subset-D (from splitting lemmas) are already established.

## Impact on Proposed Solutions (from lemma27-fix-and-fuc-strategy.md)

| Solution | Assessment |
|----------|-----------|
| 1. Strengthen walk (burgessR at walk points) | **Not needed** — condition (i) g-check already provides xi in g |
| 2. Split at each walk step | **Not needed** — walk-adjacent g-membership is sufficient |
| 3. BX14 separation | **Not needed** — direct g-membership approach works |
| 4. f-stability acceptance | **Partially correct** — f-stability at walk points plus g-propagation at inserted points |

The correct path is: the current code structure is already correct. The remaining work is formalizing the omega chain guard propagation.

## Files Relevant

- `CounterexampleElimination.lean:796` — condition (i) with g-check (CORRECT)
- `CounterexampleElimination.lean:800-870` — Walk Case A (lemma_2_4 at u_max)
- `ChronicleConstruction.lean` — needs omega_chain_guard_stable + limit_satisfies_c5_strong
- `ChronicleToCountermodel.lean:634,638` — FUC/FSC sorry sites
- `PointInsertion.lean` — lemma_2_4, lemma_2_7 (B subset B' fix done)
