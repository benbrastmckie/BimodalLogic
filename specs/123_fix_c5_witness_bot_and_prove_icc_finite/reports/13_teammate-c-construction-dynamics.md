# Teammate C: Construction Dynamics That Prevent omega + omega*

Task: 123 | Date: 2026-05-12

## 1. C4 Counterexample Elimination and the Gap

C4 counterexamples handle DENSITY: for adjacent (x, y) where `neg(U(eta, xi)) in f(x)` and `eta in f(y)`, a midpoint z = (x+y)/2 is inserted with `xi.neg in f(z)` (CounterexampleElimination.lean:2867-3183). At the limit, `limit_satisfies_c4` (ChronicleConstruction.lean:741) generalizes this to ALL pairs x < y (not just adjacent), providing z between x and y. This is used to prove density in the dense case (`limit_dom_dense_from_F'T`, ChronicleToCountermodel.lean:189) with eta=top, xi=bot.

In the discrete case where `U(T,bot) in limit_f(x)` for all x, the C4 mechanism still operates. For any two limit_dom points x < y, if `neg(U(eta, xi)) in limit_f(x)` and `eta in limit_f(y)`, a point is inserted between them. But this does NOT by itself prevent omega + omega*, because the gap scenario places NO limit_dom points in the gap -- C4 only fires when both endpoints exist.

## 2. C5 for U(T,bot): The Bot-Guard Forcing

The construction-specific property that prevents omega + omega* is the bot-guard from C5 elimination of `U(top, bot)`.

When `U(top, bot) in f(x)` (which holds at every domain point by `h_discrete`), the C5 walk (CounterexampleElimination.lean:668) produces a witness y with:
- `top in f(y)` (the event)
- `bot in g(a,b)` for all adjacent pairs (a,b) between x and y (the guard)

At stage N+1 processing the C5 counterexample for U(T,bot) at point x:

1. The witness y enters dom(N+1) (CounterexampleElimination.lean:738-810 for base case, 911-965 for condition-i case, 966-onwards for split case)
2. `bot in g_{N+1}(a,b)` for adjacent pairs between x and y
3. `adj_g_mem_limit_f` (ChronicleConstruction.lean:1367) propagates: for any w in limit_dom with a < w < b, bot in limit_f(w)
4. `bot_not_in_mcs` gives contradiction: no MCS contains bot

Therefore: NO limit_dom point can exist between x and the C5-bot witness y. This means `succ(x) = y` in the limit domain -- the C5-bot witness IS the immediate successor.

## 3. Why Condition (i) Cannot Fire for U(T,bot)

For U(T,bot), xi = bot, eta = top. Condition (i) at CounterexampleElimination.lean:858 checks:

```
conj(bot, U(top, bot)) in f(x') AND bot in g(start, x')
```

The first conjunct requires `bot in f(x')`, which contradicts C0 (f(x') is an MCS, so bot is not in it). Therefore condition (i) NEVER fires for C5-bot counterexamples. The walk always takes the split path or base case, and the witness is always a NEW point (midpoint or beyond-max), never a reused existing domain point.

This means `witness_not_old` (CounterexampleElimination.lean:656) always holds, and the witness enters at exactly stage N+1.

## 4. Adjacent Pairs Straddling a Hypothetical Gap

In the omega + omega* scenario, orbit points {s^n(a)} converge to L from below, and above-orbit points converge to L from above. Consider adjacent dom(N) points x (orbit) and y (above-orbit) straddling the gap.

At stage M when the C5-bot counterexample at x was processed (M <= N):
- The witness z enters dom(M+1) with x < z and bot in every g-interval between x and z
- z is in dom(M+1) subset dom(N)
- Since x and y are adjacent in dom(N), and z in dom(N) with x < z, we have z <= y
- If z < y: z is between adjacent x, y in dom(N), contradiction with adjacency
- Therefore z = y, and succ(x_sub) = y_sub

This means: for each orbit point x adjacent to an above-orbit point y in dom(N), succ(x) = y. The orbit does NOT accumulate at a gap -- each orbit step crosses directly to the next dom(N) point.

## 5. The Stage Induction Eliminates omega + omega*

The proof that omega + omega* is impossible is implicit in `succ_reaches_dom_N` (ChronicleToCountermodel.lean:1160). By induction on N:

- At dom(0) = {0}: trivially connected
- At dom(N+1): at most one new point enters. Case analysis on whether the new point is between old points (IH + orbit convexity) or at the boundary (bot-guard forcing)

The key insight is that every new point entering at stage N+1 is connected to existing dom(N) points via finitely many succ steps, because the bot-guard from C5 processing ensures succ steps skip no gaps.

## 6. Prior-UZ Does NOT Help

Report 12 (12_prior-uz-gap-closure.md) established conclusively: Prior-UZ with any formula phi reduces to either (a) U(T,bot) = next_top (trivial, already known), or (b) a distinguishing formula that may not exist for constant-model MCSs. The gap argument must use construction-specific properties (the bot-guard from C5 elimination), not abstract order-theoretic reasoning.

## 7. The Remaining Sorry

The sorry at ChronicleToCountermodel.lean:1645 is in `succ_cofinal`, which uses a real-analysis convergence argument. The stage induction approach in `succ_reaches_dom_N` (line 1160) bypasses this entirely, but currently has its own sorry at line 1645 for the boundary case where L <= pred(b).val. Plan v10 restructures the proof to avoid convergence altogether, using direct Nat.rec induction where the bot-guard forcing argument handles boundary cases.
