# Rank-1 Design Verification — adversarial audit of report 05's `untlNeg`/`snceNeg` proposal

**Mode**: hard-mode adversarial verification (H4) + divergence audit (H5), read-only.
**Session**: `sess_1785337808_19a89c_165v5`.
**Object under verification**: `reports/05_until-tableau-design-research.md` §2.3 (item i, ACTIVE-arm
repair) and §5.2-5.6 (item ii, PASSIVE-arm `guardWitnessed` design).
**Tree state**: verified against the CURRENT tree, after the copy-block deletion recorded in
`summaries/17_phase7-copy-deletion-frameclass-summary.md`. All line numbers below are current.
**Scope read**: `FormalSystem/Metalogic/Decidability/**`, `FormalSystem/Semantics/Truth.lean`,
`Tests/BimodalTest/{UntlSnceCopyProbe,TemporalWitnessProbe,TableauConformance}.lean`,
`specs/165_*/**`. **Not touched**: `FormalSystem/Metalogic/WeakCanonical/**`, `specs/408_*/**`.
No `.lean` file was edited; no `lake build`, no elaboration.

---

## 0. Verdict

**Item (i) — ACTIVE-arm repair: AUTHORIZE, with two amendments. It verifies INDEPENDENTLY of
item (ii)** and may be authorized separately.

**Item (ii) — PASSIVE-arm `guardWitnessed` design: REFUTE as specified.** Three independent
grounds, each with a current-tree citation:

| # | Ground | Where |
|---|---|---|
| **R1** | `guardWitnessed` returns `.notApplicable` for the **whole rule**, suppressing branch 1 — the only emitter of `¬event@t'` at an existing time, which is precisely what the truth-lemma gate row `untlNegFuture` demands. Report 05's "branch 2 is gate-dead ⟹ suppression is free" is a non-sequitur, and it is the same objection report 05 itself used to demote the hard cap from primary to net (§3.1 verdict) | §3.1 |
| **R2** | The **primary termination bound is refuted**. `allFuturePos` (`Tableau.lean:751-757`) propagates `T(G ¬U(e,g))` to every minted time and `negPos` turns it into `F(U(e,g))@z` — a **new `(source, label)` pair at every interpolant**, hence a fresh mint allowance. The subformula-descent argument of §5.3 does not see this channel | §3.2 |
| **R3** | With R2, termination rests **solely** on the `timeCount ≥ 8` net; and the engine's own measured background minting (`UntlSnceCopyProbe` B5 control: `knownTimes` 1 → 44 over 128 steps) drives `timeCount` past 8 within the opening steps. Rank 1 then behaves like rank 2 (arm effectively retired) while paying rank 1's full B1-B9 blast radius | §3.3 |

**Items 4 and 5 (ordering component, blast radius) — CONFIRMED.** `newOrd` as the outer component
is correct **and necessary**; `applyRule_untlNeg_closed` survives the constructor switch; the 31
landed rule proofs survive; two consumers report 05 did not name are benign (§5).

**Recommended path**: land item (i) alone. If a PASSIVE-arm repair is wanted afterwards, the
distinguishing mechanism of rank 1 buys no proved bound and costs gate rows, so **rank 1 collapses
into rank 3** (interpolant + pure cap) — authorize rank 3 or rank 2 explicitly rather than rank 1,
and require the two pre-repair measurements named in §6 first.

---

## 1. Item (i), the third defect — reconstructed against the current tree

### 1.1 The ACTIVE arm as it stands now

`applyRule .untlNeg` is `Tableau.lean:1012-1083`. The copy block is gone (a prohibition comment
occupies `:1052-1063` in its place), so the arm's post-deletion shape is:

* filter `unprocessed`, `:1017-1020` — a target `t'` counts only when **neither** `¬event@t'` nor
  `¬guard@t'` is on the branch;
* ACTIVE guard `:1023` — `futureTimes.isEmpty && 0 < timeOrd.timeCount < 4`;
* `freshTime := branch.nextTime` `:1029`; `newOrd := timeOrd.addFuture l.time freshTime` `:1031`;
* `autoProp := gProps ++ fNegProps ++ modalProps` `:1066` (three families; `untlNegProps` deleted);
* **`branch2 := [¬guard@freshLabel, ¬(.untl event guard)@freshLabel, sf] ++ autoProp`,
  `:1069-1070`** — the sub-term under audit;
* return `(.branching [branch1, branch2], newOrd)` `:1071`.

Mirror for `.snceNeg`: arm `:1091-1153`, ACTIVE guard `:1102`, `newOrd := timeOrd.addPast` `:1109`,
**self-propagated sub-term `¬(.snce event guard)@freshLabel` at `:1139-1140`**, return `:1141`.
The mirror claim is **CONFIRMED**: the two arms are character-for-character time reversals, with
`hProps`/`pNegProps` replacing `gProps`/`fNegProps` and `addPast` replacing `addFuture`.

### 1.2 The ℚ refutation, re-run against the current tree — CONFIRMED

Report 05 §2.2's counterexample survives the copy deletion, and the deletion **strengthens** it
(the report had to argue `untlNegProps` was empty; the block no longer exists).

Carrier `D = ℚ`; `F.WorldState = ℚ`; `TaskRel w d u ⟺ u = w + d`; `τ` the identity total-domain
history; `Om` its shift orbit. Valuation `V(q,e) ⟺ q > 0`, `V(q,g) ⟺ q ∉ {1/n : n ≥ 1}`,
`V(q,x) ⟺ q = 0`, `V(q,y) ⟺ q = −1`.

```
b   = [ F(U(e,g))@(w₀,0),  T(x)@(w₀,0),  T(y)@(w₀,2) ]      sf = F(U(e,g))@(w₀,0)
ord = ⟨[(2,0)]⟩                                              tv 0 = 0,  tv 2 = −1
```

Mechanical re-checks against the current tree, each independently verified:

| Step | Claim | Current-tree evidence |
|---|---|---|
| constraint direction | `(2,0)` means `2 < 0` | `SignedFormula.lean:671-674` — *"Each `(a, b)` means `a < b`"* |
| ACTIVE guard fires | `futureOf 0 = []`, so `futureTimes.isEmpty` | `futureOf` is forward reachability, `SignedFormula.lean:776-777`; the only edge is `2 → 0` |
| `unprocessed = []` | filter of `[]` | `:1017-1020` over `futureTimes = []` |
| `timeCount = 2` | distinct indices in `[(2,0)]` are `{2,0}` | `SignedFormula.lean:788-793` |
| `freshTime = 3` | `maxTime b = 2`, `nextTime = maxTime + 1` | `SignedFormula.lean:371-381` |
| `autoProp = []` | no `T(G·)`, no `F(F·)`, no `□`/`◇` on `b` | `:1033-1051`, `:1065` |
| `OrdWithin` holds | `2, 0 ∈ b.knownTimes` | `Decidable.lean:290`; `knownTimes`, `SignedFormula.lean:349` |
| `b` is carried into every arm | `.branching bss` obligation is `SatState … (br ++ b) ord` | `Decidable.lean:192` |
| `¬U(e,g)@0` is true | any `s > 0` has some `1/n ∈ (0,s)` where `g` fails | `Truth.lean:134-135` |

Both arms then fail, for every admissible `C = tv′ 3` (the ordering forces `C > 0` via
`ordResp`, `Decidable.lean:156`):

* **branch 1** demands `¬e@C`; `e` holds on all of `(0,∞)`.
* **branch 2** demands `¬g@C` — so `C = 1/n` — **and** `¬U(e,g)@(1/n)`. But `U(e,g)@(1/n)` is
  **true**: take `s ∈ (1/n, 1/(n−1))` (any `s > 1` when `n = 1`); `e@s` holds and `(1/n, s)`
  contains no `1/m`, so the guard holds throughout.

The re-choice of `hist` is no escape: `Om` is a shift orbit, so re-choosing `hist` translates the
whole configuration, and `T(x)@0` re-pins the origin relative to the shift while `T(y)@2` fixes
`tv′ 2 < tv′ 0`. **`RuleSound carrierBase .untlNeg` is false via the ACTIVE arm, on the current
tree, with no copy block in play — CONFIRMED (hand-checked).** `snceNeg` follows by time reversal.

One refinement report 05 did not need: partial histories are not a loophole. `Truth.lean:110-127`
records that *"temporal operators quantify over ALL times in D, not just dom(τ)"* and that atoms
are false outside the domain — so the ∃/∀ structure of `untl` is domain-blind, and the identity
history is total anyway.

### 1.3 Does the one-sub-term deletion leave a sound arm? — CONFIRMED

After deletion the arm emits, in each branch, exactly: one witness formula (`¬event@fresh` or
`¬guard@fresh`), the re-included source `sf`, and `autoProp`'s three families. Every one is
justified:

| Emission | Justification | Landed lemma |
|---|---|---|
| `sf` (source, at its own label) | `hst.sat` | — |
| `¬event@fresh` / `¬guard@fresh` | classical split of `¬U(e,g)@A` instantiated at `s := A + d` | `Truth.lean:134-135` |
| `gProps` | `T(G A)@l.time` with `A < d` | `satAt_of_mem_gProps`, `Decidable.lean:1611` |
| `fNegProps` | `F(F ψ)@l.time` with `A < d` | `satAt_of_mem_fNegProps`, `Decidable.lean:1684` |
| `modalProps` | `□`/`◇` time-invariance under `ShiftClosed Om` | `mem_boxDiamondPersistence_label`/`_shape` + `satAt_of_boxForm_time`, `Decidable.lean:1494-1520` |
| rest of `b` under the one-point `tv` update | `fresh = b.nextTime ∉ b`'s times | `satAt_update_nextTime_of_mem`, `Decidable.lean:1547`; `Tableau.not_mem_of_time_nextTime`, `Tableau.lean:2550` |
| new ordering edge `(l.time, fresh)` | `A < s` resp. `A < r < s` | `ordResp_addFuture_update`, `Decidable.lean:1557` |

`NoMaxOrder` is free: `RuleSound` binds `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
[Nontrivial D]` (`Decidable.lean:355-356`), and a nonzero `d` gives `A < A + |d|`. **CONFIRMED.**

### 1.4 "Proof shape identical to `ruleSound_untlPos`" — CONFIRMED WITH ONE QUALIFICATION

`ruleSound_untlPos` is `Decidable.lean:1981-2013`, 33 lines. Its skeleton — `intro` /
`obtain ⟨s, φ, l⟩` / `cases s` / `cases hA : asUntil?` / `simp only [applyRule, hA]` / `refine ⟨_,
…, hist, Function.update tv b.nextTime d, …⟩` / four-way `List.mem_append` dispatch — transfers
verbatim, and **all six helper lemmas above are reused unchanged**, in the same order
(`:2007`, `:2008`, `:2009-2012`, `:2013`, `:1998`).

Qualification: `untlPos` selects branch 1 unconditionally (`List.mem_cons_self`, `:1996`) because
its witness always satisfies arm 1. The repaired `untlNeg` needs a **classical case split** on
`¬e@s` to choose the arm, and must additionally dispatch the PASSIVE arm and the two
`.notApplicable` exits. So: same shape, one extra `by_cases`, plus arms item (i) does not fix.

**Consequence the authorization must state plainly.** `RuleSound` is per rule over **both** arms
(`Decidable.lean:353-361`), so item (i) alone yields **no theorem** and the ledger stays at 31/34.
Report 05 §5.4 says this; the orchestrator should not price item (i) as a ledger advance.

---

## 2. Completeness-deadness of branch 2 — CONFIRMED; and the converse risk it does not cover

### 2.1 The guard really is discarded — CONFIRMED at the exact cited lines

* `IntTruth.lean:610-636`; body line **`:619`** is literally `obtain ⟨s, hrs, hsφ, -⟩ := hT`.
* `DenseTruth.lean:262-293`; body line **`:271`** is literally `obtain ⟨s, hrs, hsφ, -⟩ := hT`.

Both then `refine (hφ w s).2 ?_ hsφ` and dispatch every leaf to a row that denies the **event**:
`untlNeg_spread` (`TemporalGate.lean:395-402`), `regionLabel_untlNeg`, `untlNegRay_low`,
`untlNegRegion_up`, `untlNegRegion_label`. **No guard reasoning appears anywhere in either proof.**
`untlNegFuture` is `TemporalGate.lean:121-126`; the docstring reason is `TemporalGate.lean:31-36`.
Report 05's Finding A is **CONFIRMED** at every cited coordinate.

### 2.2 Deleting the ACTIVE arm's `F(U)@fresh` is gate-safe — CONFIRMED

`untlNegFuture` (`:121-126`) is a `b.all` over **every** negative `untl` on the branch. Removing
one negative `untl` therefore removes obligations and can only make the row easier. Concretely, the
deleted sub-term was a *source* of gate obligations at every time above `fresh`, never a
*discharge* of one. The gate row cannot consume its presence. **CONFIRMED — no gate row regresses
from item (i).**

Two live instruments already measure this and must be re-pinned (§6):
`TemporalWitnessProbe.lean:194-199` `untlNegStrong` is `untlNegFuture` verbatim modulo helper, and
`:203-211` `untlNegCoDec` is the semantically exact interval form. Both currently read **`true` on
all twelve rows** (`nStr=true nCo=true` in every pinned string, `:445-495`).

### 2.3 The converse risk that item (ii) *does* incur — the pivot of this audit

The question the dispatch asked — *does suppressing passive-arm mints break anything the gate rows
DO consume?* — has a different answer for item (i) than for item (ii).

`untlNegFuture` demands `¬φ` at **every** known future time of every negative `untl`. Trace the
producers: the only rule that places `¬event` at an **existing** future time on account of a
negative `untl` is the PASSIVE arm's **branch 1** (`Tableau.lean:1078`, mirror `:1148`). Under
report 05 §5.2's code, `guardWitnessed` short-circuits to `(.notApplicable, timeOrd)` **before the
arms are constructed**, so branch 1 is suppressed together with branch 2. Every remaining target
`t'` then sits in `futureKnown` with no `¬event@t'`, and `untlNegFuture` reads **false** on that
branch — i.e. `temporalWitnessCheck` (`:356-361`) fails, and with it the hypothesis `hTW` that
**both** truth lemmas bind (`IntTruth.lean:614`, `DenseTruth.lean:267`).

This is developed as R1 in §3.1. It is the load-bearing refutation.

---

## 3. Termination of the `guardWitnessed` design

### 3.1 R1 — the suppression is not free, and report 05 refutes it in its own §3.1

Report 05's inference is: *branch 2 is completeness-dead (Finding A) ⟹ the design's completeness
cost is nil* (§6 table, rank 1 row: *"unchanged — branch 2 was already gate-dead"*). The premise is
true (§2.1) and the conclusion does not follow, because `guardWitnessed` does not suppress branch 2
— it suppresses the **rule**.

Report 05 states the correct principle two sections earlier, against the hard cap
(§3.1 verdict): *"a cap that suppresses the arm entirely also suppresses branch 1, which is the arm
the gate does want and the arm `BX7` closes on. A cap is the right safety net, not the right
primary."* `guardWitnessed` has the identical shape — one `if … then (.notApplicable, timeOrd)`
(§5.2 line (iii)) — and is nonetheless promoted to primary. **The demotion argument applied to the
cap applies verbatim to `guardWitnessed`; report 05 does not apply it.**

Severity is worse than for the cap in one respect and better in another:

* **Worse**: `guardWitnessed` keys on the **guard formula and world**, not on the source formula.
  Two distinct sources `F(U(e₁,g))@t` and `F(U(e₂,g))@t` sharing a guard share one witness, so one
  mint silences both. Semantically the shared witness genuinely discharges both `∃Z` disjuncts, so
  this is not unsound — but the prose in §5.3 (*"one guard-failure witness per `(source formula,
  source label)`"*) does **not** describe the code in §5.2, which is per `(guard, l.world,
  l.time)`. **REFUTED as stated; the code is coarser than its own specification.**
* **Better**: the suppression fires only after a witness exists, so the opening firings survive.

**Verdict R1: REFUTED** — the design's completeness claim is unsupported, and the row at risk has a
live instrument reading `true` today.

### 3.2 R2 — the cross-formula descent dies as claimed, but a NEW channel opens

**The claimed kill is CONFIRMED.** Re-running report 04 §1.6's counterexample against the proposed
guard: `F₁` mints `z₁ ∈ (a,t)` carrying `¬g₁`; `F₂` mints `z₂ ∈ (a,z₁)` carrying `¬g₂`; at step 3
`F₁` finds `z₁ ∈ futureOf a` already carrying `¬g₁`, so `guardWitnessed` is true and the mint is
suppressed **regardless of which target `F₁` is looking at**. `F₂` is suppressed symmetrically at
step 4. Total mints at label `a` ≤ the number of distinct guards among negative `untl`s at `a`.
**Report 05 §5.3's step-3 claim is CONFIRMED.**

**The new channel — G-propagation manufactures fresh source labels.** `allFuturePos`
(`Tableau.lean:751-757`) is `.persistent` and emits `T(ψ)@t'` for **every** `t' ∈
timeOrd.futureOf l.time`, re-firing whenever a new future time appears (it returns
`.notApplicable` only once all are present). So on a branch carrying `T(G(¬U(e,g)))@a`:

```
1.  F(U(e,g))@a fires, mints z₁ ∈ (a,t'),  branch 2 carries ¬g@z₁
2.  allFuturePos at a propagates  T(¬U(e,g))@z₁          (z₁ ∈ futureOf a)
3.  negPos turns it into          F(U(e,g))@z₁            -- A NEW SOURCE LABEL
4.  guardWitnessed for the source at z₁ tests futureOf z₁ = [t'];  ¬g@t' absent → FALSE
5.  it mints z₂ ∈ (z₁,t'), carrying ¬g@z₂ …  and 2-5 repeat at z₂, z₃, …
```

Each interpolant becomes a **new `(source, label)` pair with a fresh mint allowance**, and the
formula never shrinks — `¬U(e,g)` at `z₁` is the *same* formula, not a strict subformula. Report 05
§5.3's *"Primary (saturation)"* bound (*"the mint relation is well-founded on formula size: mint
depth ≤ `depth φ`"*) is therefore **REFUTED**: the descent it needs to exclude is a descent in
labels, driven by a rule the design never inspects.

Report 05 identifies the underlying circularity itself — *"the bound above is indexed by `(source
formula, source label)`, and labels are not a priori bounded — that is a real circularity, and the
subformula-descent argument is what patches it"* (§5.3). The patch is the thing refuted here. The
literature refinement it offers (type-indexed `guardWitnessed`) is explicitly deferred out of the
first landing (§5.3, *"Do not take this strengthening in the first landing"*), so it does not cover
the gap either.

**Verdict R2: the primary bound is REFUTED. Termination rests entirely on the `timeCount ≥ 8`
net**, exactly the position report 05's own "Honest statement of what is not proved" concedes as
the fallback — but now without the primary bound standing behind it.

**One residual channel checked and CLOSED, with a correction to the justification.** Report 05
argues `guardWitnessed` stays true *"forever (expansion is additive, `fs ++ b`)"*. That premise is
**false in general**: `timeLinearity`'s third arm is `branch.identifyTime t₂ t₁` with
`timeOrd.identifyTime t₂ t₁` (`Tableau.lean:1455-1463`), the engine's one non-additive step, and
`TimeOrdering.identifyTime` **drops** constraints collapsing to `(t,t)` (`SignedFormula.lean:700-712`).
The witness could in principle be de-linked from `l.time`. It cannot in fact: `firstIncomparablePair`
(`Tableau.lean:420-427`) selects only pairs unrelated under `futureOf`/`pastOf`, and the interpolant
is joined to `l.time` by a direct edge, so the collapsing case never arises and both the relabelled
witness and the rewritten edge survive. **CONFIRMED benign — but the stated justification is wrong
and should be replaced by this comparability argument.**

**A constructive note the orchestrator should have.** `timeLinearity` also *undoes* Finding C's
obstruction: it takes exactly the incomparable sibling pairs that defeat `blocking_fires_of_card_lt`
(`TimeTypeBound.lean:170-186`, hypothesis `hchain`) and orders them, and it runs until
`firstIncomparablePair = none`. So `TimeChain b ord` (`Fuel.lean:576`), the hypothesis
`timeFinset_card_le_of_not_blocked` (`Fuel.lean:588-596`) needs, is **restorable** by a rule already
in the engine and already proved sound. A real termination theorem for any interpolant design most
plausibly runs `guardWitnessed`-style suppression + `timeLinearity` + type-pigeonhole at
`2^(2·|C|)`, not subformula descent. **UNVERIFIABLE-WITHOUT-BUILD/PROOF** — offered as the
direction, not as a result. Note `timeLinearity` is stage 3 of `expandOnce` and fires only after
stages 1-2 are exhausted, so it does not bound proliferation *during* the untlNeg firings.

### 3.3 R3 — the safety net composes, and that is the problem

The net composes soundly: `timeCount ≥ 8 → (.notApplicable, timeOrd)`, and `SatResult …
.notApplicable = True` (`Decidable.lean:194`), so any suppression is free with respect to 7.2. It
also composes with the existing fuel argument, because refusing to extend the ordering keeps
`expandOnceUnblocked_card_lt` (`Fuel.lean:110-118`) applicable. **CONFIRMED.**

What the net does *not* do is stay a net. The engine's measured background minting, from the
reworked B5 differential gate (`UntlSnceCopyProbe.lean:246-275`), is:

| `k` | 0 | 4 | 8 | 16 | 32 | 64 | 128 |
|---|---|---|---|---|---|---|---|
| triggered `knownTimes` | 2 | 3 | 4 | 6 | 10 | 18 | 34 |
| control (`Until` deleted) | 1 | 3 | 4 | 7 | 12 | 23 | **44** |

Every one of those times is minted by a rule that calls `addFuture`/`addPast`, so each contributes
to `timeOrd.timeCount` (`SignedFormula.lean:788-793`). On this profile the ordering passes 8
distinct indices in the first few tens of steps — after which the PASSIVE arm is suppressed for the
remainder of the run, on every branch. That is the same mechanism that makes the ACTIVE arm
dormant today: `summaries/17` records the ACTIVE arms as *"dormant on every measured row"* behind
`futureTimes.isEmpty && 0 < timeCount < 4`.

**Consequence**: rank 1 would behave, on real branches, like rank 2 (the arm retired) while paying
rank 1's B1-B9 blast radius — including the expensive `sat_untl_neg`/`sat_snce_neg` restatement.

**Confidence: Medium — UNVERIFIABLE-WITHOUT-BUILD.** The inference `knownTimes` growth ⟹
`timeCount` growth is structural but not measured; §6 names the one `#eval` row that settles it.

### 3.4 One further defect in the proposed filter

The interval-form `unprocessed` of §5.2 line (ii) keeps the disjunct `z == t'`:

```lean
&& !(futureTimes.any fun z =>
      (z == t' || (timeOrd.futureOf z).contains t')
      && branch.contains (SignedFormula.neg guard {world := l.world, time := z}))
```

`z == t'` is the **endpoint point-test**, i.e. exactly the defect report 03 §2 refuted and report 04
§1.6 called out — `¬g@t'` does **not** discharge the target, because the semantic disjunct is
`∃Z ∈ (A,t')` over the *open* interval (`Truth.lean:134-135`). The engine's own semantically exact
row, `untlNegCoDec` (`TemporalWitnessProbe.lean:203-211`), uses `strictBefore ord u v` with no
endpoint disjunct. **Report 05's "interval form" is not the interval form**; it is the current
point test with a widening disjunct bolted on. Removing `z == t'` makes the filter correct and
makes the rule fire *more* — a direct trade against R2/R3. Either way it must be a declared
decision, not an inherited artefact.

---

## 4. Ordering component — CONFIRMED, and necessary

Report 04 found the bug; report 05 §5.2 line (iv) fixes it by returning **`newOrd`** as the outer
component. Verified against both rejection guards on the current tree:

* **`expandOnceNoFresh`** (`Tableau.lean:2204-2221`). Its pick rejects a candidate when
  `ruleMintsFreshLabel rule` (`:2210`) or when `newOrd.constraints.length >
  timeOrd.constraints.length` (`:2211`). `ruleMintsFreshLabel` (`Tableau.lean:1744-1746`) does
  **not** list `untlNeg`, so the length test is the only guard — and it reads `applyRule`'s
  **outer** component. With outer `= newOrd` (two edges longer) the rule is correctly skipped;
  with outer `= timeOrd` it would pass, and the pass would take a step minting a time hidden in a
  per-arm ordering. **Report 04's bug is real and report 05's B4 fixes it — CONFIRMED.**
* **`saturateBlocked`** (`Saturation.lean:466-483`). The `.splitOrdered` arm carries the identical
  test at `:467-468`. With B4 in place the arm stays unreachable, as its comment `:469-471`
  asserts; without B4 it becomes reachable and recurses into arms carrying `pair.2 = newOrd`,
  breaking the pass's no-fresh-time invariant. **CONFIRMED.**
* Probe row **B6** (`UntlSnceCopyProbe.lean:281-293`) already pins both halves of this guard —
  the constructor and the outer-ordering growth — so the fix is instrumented before it lands.

**One convention conflict to record.** `timeLinearity`, the only current `.branchingOrdered`
producer, returns the **unchanged** `timeOrd` as its outer component while its arms carry longer
orderings (`Tableau.lean:1455-1463`). B4 makes `untlNeg` adopt the **opposite** convention. Both
are correct for their own rule — `timeLinearity` adds no *time*, only an *edge between existing
times*, so the no-fresh passes should not reject it — but `Saturation.lean:469-471`'s comment
(*"every ordered split does exactly that"*) is already false for `timeLinearity` and would become
half-true after B4. It should be corrected in the same commit. **This is a tenth blast-radius item,
B10, not in report 05's list.**

---

## 5. Blast radius spot-checks

| Item | Verdict | Evidence |
|---|---|---|
| **B6 `applyRule_untlNeg_closed`** under the constructor switch | **CONFIRMED provable, real work** | `RuleResult.emitted` for `.branchingOrdered` is `(bs.map Prod.fst).flatten` (`SubformulaProperty.lean:134-139`, simp lemma `:150-151`) — i.e. the **whole** arms. Since the proposed arms are `[…] ++ branch`, the new obligation over the `branch` part is discharged by the theorem's own hypothesis `hb : ∀ x ∈ b, x.formula ∈ C` (`:1082-1084`). The existing proof (`:1085-1112`) still `simp only`s `Branch.untlNegFormulas`, now a no-op; it needs a new route through `hb`, not a new idea |
| **B5 `sat_untl_neg`/`sat_snce_neg`** | **CONFIRMED, and worse than restatement** | The `.branchingOrdered` case is *already* handled symmetrically (`CountermodelExtraction.lean:806`, `:873`, both `simp [ruleSelfGuarded]`) — the constructor switch alone does not break it. What breaks is the **conclusion**: the proof derives `¬event@t' ∨ ¬guard@t'` from the filter predicate verbatim (`hFilterPred`, `:824-827`; `h_t'_in`, `:828-832`). Under `guardWitnessed` the rule can be `.notApplicable` with **neither** disjunct present, so the statement at `:766-773` is false, not merely restatable. `maxHeartbeats 3200000` at `:836` prices the mirror |
| **The 31 landed `ruleSound_*`** | **CONFIRMED unchanged** | `RuleSound` is per rule (`Decidable.lean:353-361`); no landed proof mentions `untlNeg`/`snceNeg`; `untlPos`/`sncePos` (`:1981`, `:2018`) read only their own arms |
| `findApplicableRule`'s `.branchingOrdered` case | **benign** | `Tableau.lean:1877-1884` returns `some` unconditionally, with no witness or output-presence guard — the same treatment `.branching` gets for a `ruleSelfGuarded` rule (`:1868-1869`). No change in behaviour |
| `expandOnce` / `expandOnceUnblocked` / `pick_extended` | **benign** | `:2133-2135`, `:2179`, `:2433` all already route `.branchingOrdered → .splitOrdered`; `pick_extended` (`:2424-2445`) discharges it by `simp` |
| `appliedEntryRedundant` returns `false` for `.branchingOrdered` (`Saturation.lean:165-177`, the `false` at `:175`), and `AppliedRedundant` (`:186-188`) is *"the hypothesis the truth lemma consumes"* | **CONFIRMED benign — but only for two reasons, both worth recording** | (a) the first disjunct `b.contains f` is satisfied because `untlNeg` re-includes `sf` in every arm; (b) the trace/`Saturation` expansion returns an **empty** `newApplied` for both branching constructors (`:755-763`), so a negative `untl` never enters the applied set. **Neither reason is stated in report 05, and (a) would fail for any variant that stops re-including the source** |
| `ruleSelfGuarded` (`Tableau.lean:1759-1761`) and its docstring (`:1749-1757`) | **CONFIRMED dead/false under item (ii)** | the docstring's *"a target time counts only when neither co-decomposition output is on the branch yet"* is exactly what B2 destroys — report 05 B7 |
| `TemporalGate.lean:34`'s *"stronger than `sat_untl_neg`'s …"* note | **CONFIRMED must be re-worded** | report 05 B8 |

**B10 (new)**: `Saturation.lean:469-471`'s claim about ordered splits, per §4.

---

## 6. Acceptance gates — insufficient as specified

The current instruments are: 29 `#guard_msgs` rows in `TableauConformance.lean` (verified count),
`UntlSnceCopyProbe.lean`'s reworked A/B/C sections (B0-B6, B5′, C1-C5), and
`TemporalWitnessProbe.lean`'s six probe bundles over twelve rows.

**Corrections to report 05 §5.6.**

* **`BX7`/`BX7'` exist and are the right rows** — `TableauConformance.lean:305-313`, both
  `target := "CLOSED"`, guard `an tp tp` (`⊤∧⊤`), which `asUntil?` accepts. **CONFIRMED.**
* **The claim that rows "H, J, M, N" do not exist is REFUTED.** They exist — in
  `Tests/BimodalTest/TemporalWitnessProbe.lean`, rows **H** (`:444-446`), **J** (`:454-456`),
  **M** (`:485-487`), **N** (`:491-493`), plus I, K, L. Report 04 §3.2 checked only
  `TableauConformance.lean`; report 05 repeated the conclusion without widening the search. These
  are precisely the genuine-`Until`/`Since` gate rows, and they are the rows item (ii) endangers.

**Rows that MUST land or be re-measured BEFORE any arm edit**, named:

| # | Row | File | Why it is not optional |
|---|---|---|---|
| **D1** | `applyRule .untlNeg` on `[F(U(e,g))@(w₀,0), T(x)@(w₀,0), T(y)@(w₀,2)]` with `ord = ⟨[(2,0)]⟩`: pin (a) two branches, (b) minted time `3`, (c) branch 2 **contains** `¬U(e,g)@(w₀,3)` | new section D, `UntlSnceCopyProbe.lean` | Converts §1.2 from a hand argument to a fact, and gives item (i) a before/after row. ~3 `#eval`, ~2 s. This is report 05 §7's own recommendation and it is **the gate for item (i)** |
| **D2** | the `.snceNeg` mirror of D1 | same | the mirror claim is currently inferred, not measured |
| **T1** | `TemporalWitnessProbe` rows **H, I, J, K, L, M, N** re-measured, watching `nStr` (= `untlNegFuture`) and `nCo` (= the exact interval form) | `TemporalWitnessProbe.lean:444-495` | The only instrument that can see R1. All seven currently read `nStr=true nCo=true`; a drop to `false` is the completeness regression made visible. **Report 05 §5.6 does not mention this file at all** |
| **T2** | extend B5's `stepTimes` to report `ord.timeCount` alongside `knownTimes`, on both the triggered and control profiles | `UntlSnceCopyProbe.lean:246-275` | Settles R3 — whether `timeCount ≥ 8` fires within the opening steps and silently retires the arm. Without it, B5′ cannot distinguish "no divergence" from "arm dead" |
| **T3** | a firing counter: how many times the PASSIVE arm returns a branching constructor over a fixed-fuel run | new | B5′ (`triggered ≤ control`) reads `true` both when the repair works and when the cap has killed it. This is B5′'s blind spot |
| **B0′** | the repaired ACTIVE arm's `armsA` contains **no** `¬U(e,g)@fresh` | section A, `UntlSnceCopyProbe.lean` | item (i)'s after-row |

`UntlSnceCopyProbe.lean`'s constructor-agnostic `armsB` (`:170-176`) and row **B0** (`:184-186`)
already survive the switch — the hardening described in `summaries/17` is **CONFIRMED adequate**
for the constructor question specifically.

**Answer to the dispatch's item 6**: the 29-row corpus plus the reworked differential B-gate plus
`TemporalWitnessProbe` are **sufficient for item (i)** once D1/D2/B0′ land, and **insufficient for
item (ii)**: T1, T2 and T3 must land first, because R1 and R3 are otherwise invisible to every
existing row.

---

## 7. Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Verdict | Confidence |
|---|---|---|---|---|
| The ACTIVE arm still carries the self-propagated `¬U(e,g)@fresh` after the copy deletion | `Tableau.lean:1069-1070`; mirror `:1139-1140` | Direct read of the current arm bodies | **CONFIRMED** | High |
| `(a,b)` in `TimeOrdering.constraints` means `a < b`, so `ord = ⟨[(2,0)]⟩` leaves `futureOf 0 = []` | `SignedFormula.lean:671-674`, `:776-777` | Definition read + edge trace | **CONFIRMED** | High |
| The ACTIVE guard fires on that configuration (`timeCount = 2`, `freshTime = 3`) | `Tableau.lean:1023`; `SignedFormula.lean:788-793`, `:371-381` | Recomputation against the current definitions | **CONFIRMED** | High |
| `b` is carried into every arm, so `T(x)`/`T(y)` really pin the model | `Decidable.lean:192` — `.branching bss` obligation is `SatState … (br ++ b) ord` | Definition read | **CONFIRMED** | High |
| The ℚ model refutes both arms; `RuleSound carrierBase .untlNeg` is false via the ACTIVE arm alone | §1.2 | Truth sets recomputed from `Truth.lean:134-135`; arm output from `:1022-1071`; shift-orbit robustness argued | **CONFIRMED (hand-checked)**; machine confirmation is row D1 | Medium-High |
| Partial histories are not a loophole in the refutation or the repair | `Truth.lean:110-127` — temporal operators quantify over all of `D` | Docstring + clause read | **CONFIRMED** | High |
| The `snceNeg` mirror claim holds | `Tableau.lean:1091-1153` vs `:1012-1083`, term by term | Side-by-side read | **CONFIRMED** | High |
| Deleting the one sub-term leaves every remaining emission justified | §1.3 table | Emission-by-emission audit against six landed helpers | **CONFIRMED** | High |
| All six helpers exist and are reused verbatim | `Decidable.lean:1547`, `:1557`, `:1611`, `:1684`, `:1494-1520`; `Tableau.lean:2550` | `lean_local_search`-equivalent grep + call-site read in `ruleSound_untlPos` | **CONFIRMED** | High |
| "Proof shape identical to `ruleSound_untlPos`" | `Decidable.lean:1981-2013` | Line-by-line comparison | **CONFIRMED with one qualification** (a classical `by_cases` is added) | High |
| Item (i) yields **no** theorem on its own; the ledger stays 31/34 | `RuleSound` is per rule, `Decidable.lean:353-361` | Statement read | **CONFIRMED** — agrees with report 05 §5.4 | High |
| Both truth lemmas discard the guard at the exact cited lines | `IntTruth.lean:619`, `DenseTruth.lean:271`, both literally `obtain ⟨s, hrs, hsφ, -⟩ := hT` | Direct read of both bodies and all their leaves | **CONFIRMED** | High |
| Deleting `¬U@fresh` cannot regress a gate row | `untlNegFuture` is a `b.all` over negative `untl`s, `TemporalGate.lean:121-126` | Monotonicity of the row in the branch's negative-`untl` set | **CONFIRMED** | High |
| **`guardWitnessed` suppresses branch 1, the only emitter of `¬event@t'`, and so can falsify `untlNegFuture`** | report 05 §5.2 line (iii) short-circuits to `.notApplicable`; branch 1 is `Tableau.lean:1078`; the row is `TemporalGate.lean:121-126`; `hTW` is bound at `IntTruth.lean:614`, `DenseTruth.lean:267` | Control-flow read of the proposed code against the row and the truth lemmas' binder lists | **REFUTES report 05's rank-1 completeness claim** | High |
| Report 05 states the same objection against the hard cap and does not apply it to its own primary mechanism | report 05 §3.1 verdict vs §5.2 line (iii) | Internal cross-read | **CONFIRMED (internal contradiction)** | High |
| The code's suppression key is `(guard, world, source label)`, not `(source formula, source label)` as §5.3's prose says | report 05 §5.2 `guardWitnessed` body | Read of the proposed expression | **REFUTED as specified** (harmless to soundness; the spec is wrong) | High |
| `guardWitnessed` **does** kill report 04 §1.6's same-label cross-formula descent at step 3 | §3.2 re-trace | Re-execution of report 04's counterexample against the guard | **CONFIRMED** | Medium-High |
| **A new descent channel exists: `allFuturePos` + `negPos` create a fresh negative-`untl` source at every minted label** | `Tableau.lean:751-757` (`.persistent`, propagates to **every** `futureOf` time, re-fires as times appear); `negPos` in `allRules`, `Tableau.lean:1511-1530` | Rule-body read + step-by-step trace in §3.2 | **REFUTES report 05 §5.3's primary bound** | Medium-High — **UNVERIFIABLE-WITHOUT-BUILD** (no `#eval` was run) |
| Therefore termination rests solely on `timeCount ≥ 8` | composition of the above with §5.3's own concession | — | **CONFIRMED** | High |
| The `timeCount` net composes soundly with the fuel argument | `Decidable.lean:194`; `Fuel.lean:110-118` | Definition read | **CONFIRMED** | High |
| Background minting drives `timeCount` past 8 in the opening steps, retiring the arm on real branches | B5 profiles, `UntlSnceCopyProbe.lean:246-275`; every mint calls `addFuture`/`addPast` | Measured profile + structural inference | **PLAUSIBLE** | Medium — **UNVERIFIABLE-WITHOUT-BUILD**; row T2 settles it |
| The witness cannot be de-linked by `timeLinearity`'s identification arm | `Tableau.lean:1455-1463`, `:420-427`; `SignedFormula.lean:700-712` | Comparability argument on `firstIncomparablePair` | **CONFIRMED benign** — but report 05's stated reason (*"expansion is additive"*) is **false** and must be replaced | High |
| `timeLinearity` can restore `TimeChain`, re-enabling `blocking_fires_of_card_lt` | `Fuel.lean:576`, `:588-596`; `TimeTypeBound.lean:170-186`; `Tableau.lean:1455-1463` | Hypothesis read + rule read | **PLAUSIBLE, offered as direction only** | Medium — **UNVERIFIABLE-WITHOUT-PROOF** |
| The proposed "interval form" retains the refuted endpoint point-test `z == t'` | report 05 §5.2 line (ii) vs `Truth.lean:134-135` and `untlNegCoDec` (`TemporalWitnessProbe.lean:203-211`) | Side-by-side comparison with the semantically exact row | **REFUTED as stated** | High |
| **Outer component `newOrd` is correct and necessary** | `Tableau.lean:2204-2221` (test at `:2211`), `Saturation.lean:466-483` (test at `:467-468`), `ruleMintsFreshLabel` `:1744-1746` | Guard-by-guard trace with outer `= newOrd` and outer `= timeOrd` | **CONFIRMED — report 05 fixed report 04's bug** | High |
| `timeLinearity` uses the opposite outer-ordering convention, and `Saturation.lean:469-471`'s comment is already false | `Tableau.lean:1463` returns `timeOrd` | Direct read | **CONFIRMED — new item B10** | High |
| `applyRule_untlNeg_closed` survives the constructor switch via `hb` | `SubformulaProperty.lean:134-139`, `:150-151`, `:1082-1112` | `emitted` definition + hypothesis read | **CONFIRMED (provable; proof-work, not a blocker)** | High |
| `sat_untl_neg`'s `.branchingOrdered` case is already handled; what breaks is the **conclusion** | `CountermodelExtraction.lean:806`, `:873`; `hFilterPred` `:824-827` | Proof-body read | **CONFIRMED — stronger than report 05's B5** | High |
| The 31 landed `ruleSound_*` survive unchanged | `Decidable.lean:353-361`; no landed proof reads `untlNeg`'s output | Statement read + grep | **CONFIRMED** | High |
| `appliedEntryRedundant`'s `false` for `.branchingOrdered` is benign | `Saturation.lean:165-177` (`b.contains f` disjunct) and `:755-763` (empty `newApplied`) | Both disjuncts traced | **CONFIRMED benign, for two reasons report 05 does not name** | High |
| The corpus is 29 rows and `BX7`/`BX7'` are at `TableauConformance.lean:305-313` with guard `⊤∧⊤` | `grep -c '#guard_msgs'` = 29; row bodies read | Direct count + read | **CONFIRMED** | High |
| **Rows "H, J, M, N" DO exist** | `TemporalWitnessProbe.lean:444-446`, `:454-456`, `:485-487`, `:491-493` | Row enumeration in the file report 04/05 did not search | **REFUTES report 04 §3.2 and report 05 §5.6** | High |
| `untlNegStrong`/`untlNegCoDec` are live instruments for R1 and currently read `true` on all twelve rows | `TemporalWitnessProbe.lean:194-199`, `:203-211`; pinned strings `:440-495` | Definition read + pinned-output read | **CONFIRMED** | High |
| `BX7`/`BX7'` survive rank 1 (report 05 §5.6) | — | Not re-run; and under R1/R3 the question is moot for the design as specified | **UNVERIFIABLE-WITHOUT-BUILD** | — |
| Whether the repaired ACTIVE arm moves any corpus row | — | Requires the 59-62 s conformance run | **UNVERIFIABLE-WITHOUT-BUILD** | — |
| Report 05's literature grounding (Caleiro–Viganò–Volpe 2013, SV3/Lemma 3.10/§4.3) | corpus chunks `sources/caleiro_2013/` | **Not re-read in this dispatch** — the literature is not load-bearing for either verdict here | **UNVERIFIED (not re-checked)** | — |

### Contradiction Log

**Resolved — internal to report 05, and decisive.** §3.1's verdict rejects the hard cap as primary
because *"a cap that suppresses the arm entirely also suppresses branch 1, which is the arm the gate
does want"*; §5.2 line (iii) then makes `guardWitnessed` primary using the identical
`(.notApplicable, timeOrd)` short-circuit. Precedence applied: **the report's own stated principle
over its ranking**, and both checked against the code (`Tableau.lean:1078`, `TemporalGate.lean:121-126`).
Effect: rank 1's completeness claim falls, and rank 1 loses its advantage over rank 3.

**Resolved — against report 04 §3.2 and report 05 §5.6, on the row-naming question.** Both assert
rows "H, J, M, N" do not exist. They exist in `TemporalWitnessProbe.lean`. Precedence: **an exhibited
file location outranks a negative existential drawn from a search of one file.** Report 04's narrower
point — that the *conformance corpus* rows are `BX7`/`BX7'` — stands and is confirmed here; what
falls is the generalisation to "do not exist".

**Resolved — against report 05 §5.3's additivity justification.** *"Expansion is additive, `fs ++ b`"*
is false of `timeLinearity`'s identification arm (`Tableau.lean:1455-1463`), the engine's one
non-additive step. Precedence: **code over prose.** The conclusion nonetheless survives, by a
different argument (comparability under `firstIncomparablePair`), which is supplied in §3.2. Recorded
because a future variant that changes the ordering edges would break the real argument while the
stated one would still look fine.

**Resolved — against the escalation's own framing of the "third defect" as a proof-shape question.**
Item (i) was dispatched as "does the deletion make the arm sound and is the proof shape reusable".
Both answers are yes, but the finding that matters for sequencing is that **item (i) produces no
theorem** — `RuleSound` is per rule over both arms. Precedence: **the landed statement's shape over
the dispatch's framing.**

**UNRESOLVED — the magnitude of R3.** `UNRESOLVED: whether timeCount crosses 8 early enough to
retire the PASSIVE arm on ordinary branches.` The `knownTimes` profile is measured and every mint
adds an ordering edge, but `timeCount` itself was never `#eval`'d. Downstream risk: **material** —
if the crossing is late, R3 weakens to a caveat and rank 1 remains distinguishable from rank 3 on
behaviour, though R1 and R2 still stand independently. Resolving check not performed: row **T2**
(§6), one `#eval` extension to the existing `stepTimes` profile.

**UNRESOLVED — whether the G-propagation channel fires on any branch the engine actually builds.**
`UNRESOLVED: the §3.2 descent is constructed by hand from two rule bodies; no #eval exhibits it.`
Downstream risk: **bounded** — R2 refutes the *bound*, and a bound that cannot be proved is not
rescued by the channel being rare. Resolving check not performed: an `#eval` on a branch carrying
`T(G(¬U(e,g)))@0` plus a future time, counting mints against fuel.

### Recommendations modified after verification

1. The dispatch opened expecting the ACTIVE and PASSIVE items to stand or fall together. They do
   not: **item (i) verifies completely and independently**, and the only reason to sequence it with
   item (ii) is that neither yields a theorem alone.
2. R1 was not anticipated. It was found by asking the dispatch's own "converse risk" question — *what
   do the gate rows consume?* — and following the producer of `¬event@t'` backwards. The answer put
   report 05 in contradiction with itself, which is a stronger refutation than any external
   counterexample would have been.
3. R2 was found by attacking the weakest sentence in §5.3 (*"labels are not a priori bounded — that
   is a real circularity"*) and looking for a rule that manufactures labelled sources. `allFuturePos`
   supplies it in two steps.
4. The `timeLinearity` observation runs **against** this report's own refutation and is recorded
   anyway: it weakens Finding C's "incomparable siblings defeat blocking" argument and is the most
   plausible route to a real termination theorem for any interpolant design. It is marked
   UNVERIFIABLE-WITHOUT-PROOF rather than promoted.
5. Two blast-radius findings were **added** (B10, the ordering-convention conflict; and the
   `appliedEntryRedundant` analysis) and one was **strengthened** (B5 is a falsified statement, not a
   restatement). Report 05's B1-B9 is otherwise accurate.
6. The acceptance-gate answer changed during the audit: the decisive instrument turned out to
   already exist (`untlNegStrong`/`untlNegCoDec` on rows H-N), in a file report 05's §5.6 never
   mentions.

---

## 8. Authorization, as an executable specification

### Item (i) — AUTHORIZE, land first and alone

**Edit** (anchor on the `branch2 :=` binder inside each ACTIVE arm, not on the line number):

```lean
-- Tableau.lean:1069-1070, BEFORE
let branch2 := [SignedFormula.neg guard freshLabel,
                 SignedFormula.neg (.untl event guard) freshLabel, sf] ++ autoProp
-- AFTER
let branch2 := [SignedFormula.neg guard freshLabel, sf] ++ autoProp

-- Tableau.lean:1139-1140, BEFORE                          (mirror)
let branch2 := [SignedFormula.neg guard freshLabel,
                 SignedFormula.neg (.snce event guard) freshLabel, sf] ++ autoProp
-- AFTER
let branch2 := [SignedFormula.neg guard freshLabel, sf] ++ autoProp
```

**Amendment 1 — probe first.** Land rows **D1**, **D2** (§6) *before* the edit and **B0′** after
it. §1.2 is hand-checked; D1 converts it to a fact for ~2 s of elaboration, exactly as section B did
for report 03 §2.

**Amendment 2 — declare the ledger truth in the commit.** `RuleSound` is per rule over both arms
(`Decidable.lean:353-361`), so this commit fixes a soundness defect and moves the ledger **not at
all** (31/34 before and after). Framing it as progress toward 32 would be false.

**Gate**: the 29-row corpus before and after (~59-63 s), `UntlSnceCopyProbe` sections A and C
re-pinned, `TemporalWitnessProbe` rows H-N re-pinned. Risk direction is under-closing only, which is
what the corpus measures.

### Item (ii) — REFUTE as specified

Do **not** land report 05 §5.2's arm. If the orchestrator still wants a PASSIVE-arm repair:

* **Preferred**: take **rank 2** (retire the PASSIVE arm to `.notApplicable`) with the
  `BX7`/`BX7'` regression declared in advance and measured — one item, and its cost is exactly the
  two corpus rows, visible in a single run. Rank 2 is a strict prefix of every other candidate, so
  nothing done for it is wasted.
* **Otherwise**: take **rank 3** (interpolant + pure `timeCount` cap, with B2's filter corrected by
  **dropping the `z == t'` endpoint disjunct** per §3.4, and B4's outer `newOrd` per §4). Rank 3 is
  what rank 1 degenerates to once `guardWitnessed`'s bound is refuted, and it is honest about the
  cap being the whole mechanism. `guardWitnessed` may be added later as a *performance* filter, but
  it must not be sold as a termination argument.
* **In either case**, rows **T1**, **T2**, **T3** (§6) land **before** the arm edit. T1 is
  non-negotiable: it is the only instrument that can see R1.
