# Phase 11 Potential Obstruction: Is It Surmountable?

**Question**: Phase 11's `expandBranchWithFuel_isSome_of_budget` fails at `.splitOrdered` arm 3.
Are either of the two named unblocking routes viable, and does the task continue on its current
target?

**Verdict, up front**: **SURMOUNTABLE IN PRINCIPLE, BUT NOT WITHIN THE CURRENT PHASE 11 FRAMING.**
Route (b) is viable and I machine-checked the fact that was blocking it. Route (a) is dead. But
route (b) is an *amortized* argument, and the current proof architecture is a *per-step potential*.
Converting one to the other is a redesign of the theorem statement, not a tactic fix — it needs a
human retarget decision. Details and evidence below.

---

## 1. What I machine-checked (new, previously unavailable)

Three lemmas, all verified via `lean_run_code` against the real proof state, consuming only landed
`Fuel.lean` infrastructure (`bfsClosure_complete`, `reachableForward_eq`, `reachableBackward_eq`):

```lean
theorem mem_futureOf_of_mem_constraints (ord : TimeOrdering) (a b : TimeIndex)
    (h : (a, b) ∈ ord.constraints) : b ∈ ord.futureOf a

theorem mem_pastOf_of_mem_constraints (ord : TimeOrdering) (a b : TimeIndex)
    (h : (a, b) ∈ ord.constraints) : a ∈ ord.pastOf b

/-- **Collapse-freedom.** -/
theorem identifyTime_no_collapse (ord : TimeOrdering) (t₁ t₂ : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2)
    (a b : TimeIndex) (h : (a, b) ∈ ord.constraints) :
    (if a == t₂ then t₁ else a) ≠ (if b == t₂ then t₁ else b)
```

**What collapse-freedom says.** `TimeOrdering.identifyTime` drops any constraint collapsing to
`(t,t)` (`SignedFormula.lean:705-711`) — the obvious mechanism by which identification could
*destroy* order information. Collapse-freedom proves that mechanism **never fires on the pairs
`timeLinearity` actually identifies**: a collapse needs `(t₁,t₂)` or `(t₂,t₁)` in the constraint
list, and either would make the pair *comparable*, which `firstIncomparablePair`
(`Tableau.lean:420-427`) excludes by construction. The only residual case is a pre-existing
self-loop `(a,a)`, carried above as the hypothesis `hnsl`.

So **on an incomparable pair, `identifyTime` is a pure renaming**: every edge survives, renamed.

This is exactly the fact Phase 7's G2 clause deliberately avoided needing ("no fact about
`identifyTime`'s output ordering is proved, assumed, or needed"). Avoiding it was right for Phase 7;
route (b) is where it becomes necessary, and it is **true and provable**.

Confirmed empirically alongside the proof:

| Identification | Constraints before → after | Reachability |
|---|---|---|
| `0 ↦ 1`, incomparable | `[(0,3),(3,5),(1,4)]` → `[(1,3),(3,5),(1,4)]` (3 → 3, nothing dropped) | `5 ∈ futureOf 0` before, `5 ∈ futureOf 1` after ✓ |
| `3 ↦ 0`, **comparable** (`(0,3)` is an edge) | `[(0,3),(3,5),(1,4)]` → `[(0,5),(1,4)]` (3 → 2, edge **dropped**) | — |

The contrast is the point: the destructive case exists, and incomparability is precisely what
excludes it.

---

## 2. Route (a) — a lower bound on branch cardinality after identification: **DEAD**

`Branch.identifyTime b src tgt = (b.map relabel).eraseDups` (`SignedFormula.lean:364-367`). The
`map` preserves length exactly; **all** shrinkage comes from `eraseDups`. A merge happens for each
`sf` at time `src` whose relabelled copy is already present at `tgt`.

So the shrinkage `s` is bounded by the number of formulas sitting at `src` — and by nothing else.
That count is bounded only by `|b|`, hence by `|U|`. There is **no lower bound on
`(b.identifyTime t₂ t₁).toFinset.card` in terms of `b.toFinset.card` alone**, because for any `k`
one can have `k` formulas at `src` each twinned at `tgt`, giving `s = k`.

Route (a) as the implementation stated it does not exist. This is a structural reading of the
definition, not a failed proof attempt.

---

## 3. Route (b) — an independent mint bound: **VIABLE**

**The mint guard is real and is not stated via branch growth.** `findApplicableRule`
(`Tableau.lean:1908` and `:1931`) gates every `ruleMintsFreshLabel` rule on
`witnessPresent rule sf branch timeOrd` — in *both* the `.linear` and `.branching` arms, and
*instead of* the output-presence test, never in addition to it. A fresh-label rule fires only when
the branch carries **no witness** for that `sf`.

The bound then runs:

1. A mint for `(rule, sf)` fires only when `witnessPresent = false`.
2. The rule's output *is* the witness (`Tableau.lean:2336` — all eight constructors return a
   syntactic cons whose head is the witness), so immediately after, `witnessPresent = true`.
3. Formulas are never deleted: extensions append, `.branching` arms re-include the source,
   `.splitOrdered` arms 1-2 leave the branch literally unchanged, and arm 3 only *relabels*
   (`eraseDups` merges duplicates, so membership is preserved).
4. **Witness preservation across arm 3** is where collapse-freedom does its work. The branch
   witness is relabelled along with `sf`; the ordering condition `t' ∈ futureOf t` survives because
   every edge survives renamed (§1), so a path maps to a walk of the *same length* and is re-found
   at the same fuel `100`. The degenerate case `ρ(t) = ρ(t')` requires `{t,t'} = {t₁,t₂}`, which
   incomparability excludes.
5. Therefore each `(rule, sf)` mints at most once: **`#mints ≤ 8·|U|`, absolutely**, with no
   reference to branch growth.

From there the whole circularity unwinds:

- `#identifications ≤ |knownTimes|₀ + #mints` (each identification drops `|knownTimes|` by ≥1, each
  mint raises it by 1) — **absolute**;
- `total shrinkage ≤ #identifications × |U|` — **absolute**;
- `#extensions ≤ |U| + total shrinkage` — **absolute**.

Path length is bounded. **The circularity is genuinely broken.**

**Marked uncertain**: step 4 is argued, not machine-checked, and needs case work over all eight
fresh-label rules (the two modal ones are trivial — their witness sits at the *same* time as `sf`,
so time identification moves both together; the six temporal ones need the reachability transport).
Step 3's "formulas are never deleted" is read off the rule shapes and is consistent with the landed
`expandOnceUnblocked_card_lt` / `expandOnceUnblocked_split_card_lt`, but I did not prove it.

---

## 4. Why this still does not rescue Phase 11 as framed

**Collapse-freedom does not repair the potential.** It is a fact about the *ordering*; the
obstruction is about *branch cardinality*. I re-derived the circularity independently rather than
taking the implementation's word for it. For any linear potential

```
Ψ = A·(|U| − |b|) + B·|knownTimes| + C·|incompPairs|,    A,B,C ≥ 0
```

strict decrease at every arm requires simultaneously:

- **mint step** (`|b|` up by `k ≥ 1`, `knownTimes` up 1, up to ~`2·Tmax` new incomparable pairs):
  `A·k > B + C·p_mint`, so `A > B + C·p_mint`;
- **arm 3** (`|b|` down by `s`, `knownTimes` down ≥1, the up-to-`2·Tmax` pairs involving `t₂` all
  vanish): `B + C·p_arm3 > A·s`.

`p_mint` and `p_arm3` are both ≈ `2·Tmax`, so the `C` terms cancel out rather than rescuing
anything, leaving `B + 2CTmax > A·s > A > B`. Since **`s` is unbounded** (§2, up to `|U|`), no
choice of `A,B,C` satisfies both. This reproduces the implementation's finding exactly and confirms
it is circular rather than unlucky — and confirms that `hT` (which only caps `Tmax`, i.e. the `C`
and `B` terms' *value*) does not touch the problem.

**The mismatch.** Route (b)'s bound is *amortized*: total shrinkage over a whole run is bounded even
though per-step shrinkage is not. A per-step potential cannot express that. Using route (b) requires
the induction to carry how many mints have already happened — and that is **not a function of the
state `(b, ord)`**.

**`maxTime` is not a usable proxy** — I checked this specifically, because it would be the obvious
escape. `Branch.nextTime = maxTime + 1`, so mints raise `maxTime`; but arm 3 identifies `t₂` into
`t₁` where `t₂` may be the maximum and `t₁ < t₂`, so identification can *lower* `maxTime` and a
freshly-minted index can be reused later. There is no monotone history-free counter available.

---

## 5. Third framings considered

| Framing | Verdict |
|---|---|
| Carry an explicit mint/identification budget as a theorem parameter, exactly as `branchesUsed` already is | **The viable route.** Not `NoSplit` (permits every split constructor), not vacuous (real runs mint finitely). But it is a *new hypothesis callers must discharge*, structurally like `hT`. |
| Multiset / ordinal measure instead of a `Nat` weighting | Does not help: the problem is that arm 3 *returns* budget to a component, which no well-ordering of the same two components fixes. |
| Quotient the branch count by future identifications | Not expressible — depends on identifications not yet made. |
| Change the engine so arm 3 does not shrink the branch | Would work, but is an **engine change**, outside `file_scope` and against the frozen-defaults constraint. |

---

## 6. Verdict and recommendation

**SURMOUNTABLE IN PRINCIPLE — via route (b) — BUT NOT AS PHASE 11 IS FRAMED.**

What is *not* true: that `expandBranchWithFuel` admits no totality proof. It does; the run is
genuinely finite and §3 shows why.

What *is* true: the current statement — totality at a fuel figure computed from `(b, ord)` alone,
proved by a per-step potential — **cannot be closed**, and no amount of tactic work will change
that. §4 is a proof about the shape of the argument, not a report of a failed attempt.

**This is a retarget decision requiring human approval**, and it is the second one on this task. The
work it implies is roughly:

1. **Witness preservation** (~3 phases): the eight-rule case analysis of §3 step 4, resting on the
   three lemmas already machine-checked in §1.
2. **Restatement** (~1 phase): give `expandBranchWithFuel_isSome_of_budget` an explicit mint budget
   parameter, in the shape `branchesUsed`/`maxBranches` already establishes.
3. **Amortized induction** (~2-3 phases): the counting of §3, then the terminus.

That is comparable in size to everything landed so far. The alternative — accepting a carried mint
bound as a hypothesis, in the shape `hT` already has — is much cheaper but pushes the same
discharge obligation onto task 412.

**Recommendation**: put the choice to the user rather than assume it. Nothing here invalidates the
landed phases 1-10, which remain sorry-free and green.

## 7. Note for the consuming task

Unchanged from the prior dispatch: `buildTableauAt_isSome_of_budget` is **not landed**, and task 412
must not yet be planned against it. The Phase 3 assets (`BudgetedTableau`, `buildTableauAt`,
`BudgetedTableau.upgrade`) remain available and sorry-free.
