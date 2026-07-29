# untlNeg / snceNeg Repair Verification — Adversarial Ruling on the Proposed Co-Decomposition Diff

**Mode**: divergence audit (H5) + adversarial self-verification (H4), read-only.
**Session**: sess_1785337808_19a89c_165v3
**Scope read**: `FormalSystem/Metalogic/Decidability/**`, `FormalSystem/Semantics/Truth.lean`,
`Tests/BimodalTest/{UntlSnceCopyProbe,TableauConformance}.lean`, `specs/165_*/**`.
**Not touched**: `FormalSystem/Metalogic/WeakCanonical/**`, `specs/408_*/**`. No `.lean` file was
edited; no `lake build` and no elaboration was started.

---

## 0. The diff under review

From `.orchestrator-handoff.json`, `blockers[0].proposed_diff_for_the_next_verification_pass`,
replacing the `| t' :: _ =>` PASSIVE arm of `.untlNeg` (`Tableau.lean:1070-1077`; `.snceNeg`
mirror at `:1143-1150`):

```lean
| t' :: _ =>
  let targetLabel := {world := l.world, time := t'}
  let interTime  := branch.nextTime
  let interLabel := {world := l.world, time := interTime}
  let newOrd := (timeOrd.addFuture l.time interTime).addFuture interTime t'
  let branch1 := [SignedFormula.neg event targetLabel, sf]
  let branch2 := [SignedFormula.neg guard interLabel, sf]
  (.branchingOrdered [(branch1 ++ branch, timeOrd), (branch2 ++ branch, newOrd)], timeOrd)
```

Three claimed changes: guard failure moves to a fresh interpolant strictly inside
`(l.time, t')`; `F(U(event,guard))@t'` is dropped from branch 2; return type switches
`.branching` → `.branchingOrdered`.

---

## 1. TERMINATION — **REFUTED as proposed**

### 1.1 The re-fire guard, quoted, and exactly how the diff breaks it

`Tableau.lean:1017-1020`:

```lean
let unprocessed := futureTimes.filter fun t' =>
  let negEvent := SignedFormula.neg event { world := l.world, time := t' }
  let negGuard := SignedFormula.neg guard { world := l.world, time := t' }
  !branch.contains negEvent && !branch.contains negGuard
```

The filter's entire suppression power is that **every** arm the rule emits places one of
`negEvent` / `negGuard` **at `t'` itself**. `Tableau.lean:1749-1755` states this as the reason
`untlNeg`/`snceNeg` need no outer guard: *"a target time counts only when neither
co-decomposition output is on the branch yet"*.

Under the diff, branch 2 places `¬guard` at `interTime`, **not** at `t'`. So on branch 2, `t'`
still satisfies the filter predicate and remains in `unprocessed`.

### 1.2 The divergence is reached, not merely feared — the recursion traced

`expandBranchWithFuel`'s `.splitOrdered` arm re-enters each sub-branch **under that
sub-branch's own ordering** (`Saturation.lean:666-690`, the recursive call at `:680-681` is
`expandBranchWithFuel pair.1.1 (min pair.2 fuel) pair.1.2 …`, i.e. `pair.1.2 = newOrd` for
branch 2). Therefore on the recursive call:

- `timeOrd.futureOf l.time` = `{interTime, t', …}` (both, since `newOrd` carries
  `(l.time, interTime)` and `(interTime, t')`, and `futureOf` is the transitive closure —
  `SignedFormula.lean:776-777`).
- `interTime` is filtered out (it carries `negGuard`).
- **`t'` is not.** The arm fires again, mints `interTime₂ = branch.nextTime`, and repeats.

`sf` is re-included in every arm (`branch1`/`branch2` both contain `sf`), so `findUnexpanded`
keeps selecting it. The loop is unbounded: one fresh time per step, forever, until fuel or
`maxBranches` is hit.

### 1.3 Blocking cannot rescue it

Blocking is the project's only other fresh-time brake, and it is the wrong instrument here.
`expandOnceUnblocked` computes `blocked := blockedTimes b timeOrd fc tracker` and then picks the
**source** formula via `findUnexpandedUnblockedWith b timeOrd fc blocked`
(`Tableau.lean:2159-2160`). The source of this rule is `sf` at label `l` — the **original**
time. Blocking a time removes it as an *expansion source*; it never removes it as a rule's
*target*. `l.time` is the branch root and is never subset-blocked, so the arm keeps firing
regardless of how many interpolants get blocked.

Worse, the interpolants are not even blockable. `isTemporallyBlocked` compares a time's formula
set against its **ancestors** only (`TimeTypeBound.lean:153` `isTemporallyBlocked_of_ancestor`,
`ancestorTimes`), and each new interpolant is minted strictly *below* the previous one, so its
only ancestor is `l.time`. A descending chain never produces an ancestor repeat.

### 1.4 densityRule's guard does not transfer

The live guard is **not** `existingIntermediates` (that name survives only in comments at
`Tableau.lean:1283, 1726, 1738, 1858`); it is a maximal-gap-target filter,
`Tableau.lean:1303-1308`:

```lean
let gapTargets := futureTimes.filter fun t' =>
  (timeOrd.futureOf t').isEmpty
    && !(futureTimes.any fun t'' => (timeOrd.futureOf t'').contains t')
```

It works because `densityRule` gives its interpolant the edge `fresh < t'`
(`Tableau.lean:1313`), so `futureOf fresh ∋ t'` is non-empty and `fresh` is **never itself
maximal** — it can never become a target, and the admissible-gap set shrinks monotonically.

That trick is unavailable to `untlNeg`. Its semantic obligation is `∀ c > a`, not "at some
maximal `c`". Restricting targets to ord-maximal future times would drop the co-decomposition at
intermediate times, and the obligation genuinely does **not** propagate downward: `¬e@c` at a
maximal `c` says nothing about an intermediate `c' < c` where `e@c'` may hold with `g` true
throughout `(a,c')`, which would make `U(e,g)@a` true.

### 1.5 What the formal termination theory does and does not say

No **proved** theorem breaks, and it is important to say why rather than to claim safety.
The only totality theorem is `expandBranchWithFuel_isSome_of_noSplit` (`Fuel.lean:1271-1277`),
and it is conditional on `NoSplit` (`Fuel.lean:1250-1254`), which explicitly excludes **both**
branching constructors:

```lean
∧ (∀ bs, (expandOnceUnblocked b ord fc tr).1 ≠ ExpansionResult.split bs)
∧ (∀ bs, (expandOnceUnblocked b ord fc tr).1 ≠ ExpansionResult.splitOrdered bs)
```

Branching runs are named as an outstanding obligation (`Fuel.lean:74-79`), and
`buildTableau_isSome` is recorded as **false as an unconditional statement**
(`Fuel.lean:80-86`; `Saturation.lean:1380-1381`).

So the damage is not "a theorem goes red". It is twofold and worse:

1. **Operationally**, every branch carrying a non-`top`-guarded `F(U(e,g))` with a known future
   time now runs to `.fuelExhausted` (`DecisionProcedure.lean:193-194`) instead of saturating.
2. **Structurally**, the diff destroys the premise any future branching-termination argument
   must rest on. The whole finite-universe measure is
   `expandOnceUnblocked_card_lt` (`Fuel.lean:110`) bounded by `U`, whose finiteness comes from
   `timeFinset_card_le_of_not_blocked : b.timeFinset.card ≤ 2 ^ (2 * C.card)`
   (`Fuel.lean:588-594`) — which holds only when blocking fires. §1.3 shows blocking never fires
   on this chain, so the label bound `hL : L.card ≤ 2 ^ (2 * C.card)` (`Fuel.lean:1216`) becomes
   unobtainable for exactly the branches this rule touches.

### 1.6 Minimal amendment for the re-fire guard — necessary, and **not sufficient**

The narrow fix is to widen the filter from "`¬guard` at `t'`" to "`¬guard` at some `z` with
`l.time < z ≤ t'`", i.e. replace the second conjunct with

```lean
!(futureTimes.any fun z =>
    (z == t' || (timeOrd.futureOf z).contains t')
    && branch.contains (SignedFormula.neg guard { world := l.world, time := z }))
```

This is sound (suppression never emits, so it cannot violate `RuleSound`) and it does stop
**single-formula** divergence: after the mint, `t'` is discharged by `interTime`, and
`interTime` is discharged by itself.

**It does not stop cross-formula divergence, and this is the decisive point.** With two distinct
negated Untils `F(U(e₁,g₁))@a` and `F(U(e₂,g₂))@a` on one branch:

- `F₁` fires at `t`, mints `z₁ ∈ (a,t)` carrying `¬g₁@z₁`.
- `z₁ ∈ futureOf a`, and for `F₂` no `z ∈ (a, z₁]` carries `¬g₂`, so `F₂` fires at `z₁` and mints
  `z₂ ∈ (a, z₁)` carrying `¬g₂@z₂`.
- `z₂` is now unprocessed for `F₁`, which mints `z₃ ∈ (a, z₂)`. And so on, strictly downward,
  without bound.

Blocking cannot cut this chain (§1.3): each `zₙ`'s only ancestor is `a`. `timeLinearity` cannot
either — it is stage 3 of `expandOnce` (`Tableau.lean:2115-2123`) and runs only when *nothing*
else applies, which never happens while the arm keeps firing.

The only terminator actually available in this codebase is a **hard cap** of the shape the
ACTIVE arm already uses — `timeOrd.timeCount > 0 && timeOrd.timeCount < 4`
(`Tableau.lean:1023`, `:1097`), whose own comment owns the trade at `:1026-1029`
(*"limit fresh time point creation to prevent runaway chains"*). Applying the same cap to the
passive arm's interpolant sub-arm terminates it, but buys **bounded completeness only** — a new
acceptance criterion the corpus does not currently express.

---

## 2. SOUNDNESS OF THE PROPOSED ARMS — **CONFIRMED for the arms; two consumer defects**

### 2.1 The semantics is on the diff's side

`Truth.lean:134-135`:

```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M Omega τ s φ ∧
    ∀ r : D, t < r → r < s → TruthAt M Omega τ r ψ
```

Negating at `A` and instantiating at any `C' > A` gives exactly
`¬φ@C' ∨ ∃ Z ∈ (A,C'). ¬ψ@Z`. The diff's two arms are literally those two disjuncts. The
current arm's second disjunct (`¬ψ@C' ∧ ¬U(φ,ψ)@C'`) is a different, stronger, and false claim —
the refutation stands as recorded (`Decidable.lean:2187-2197`).

`snce` is the exact mirror (`Truth.lean:136-137`), so `addPast` / `pastOf` transposition is
correct.

### 2.2 The proof obligation and its helpers already exist

`SatResult` for the constructor (`Decidable.lean:193`):

```lean
| .branchingOrdered brs, _ => ∃ p ∈ brs, ∃ hist tv, SatState M Om hist tv p.1 p.2
```

Two facts matter. The second component is **ignored** (`_`), and `hist`/`tv` are re-chosen
**wholesale**. So:

- **Arm 1** is discharged with `(hist, tv)` unchanged against `timeOrd`. Correct pairing: this
  arm adds no time.
- **Arm 2** is discharged with `tv' := Function.update tv branch.nextTime Z`, where `Z` is the
  semantic witness from §2.1. Correct pairing: it must carry the extended ordering.

The key helper is **already landed and its statement matches the diff's `newOrd` character for
character** — `ordResp_addFuture_addFuture_update` (`Decidable.lean:1590-1596`):

```lean
∀ p ∈ ((ord.addFuture t b.nextTime).addFuture b.nextTime t').constraints,
  Function.update tv b.nextTime d p.1 < Function.update tv b.nextTime d p.2
```

with `hlt : tv t < d` and `hlt' : d < tv t'` — exactly `A < Z < C'`. Supporting pieces also
landed: `satAt_update_nextTime_of_mem` (`:1546`), `OrdWithin.nextTime_not_mem` (`:321`),
`SatState.lt_of_mem_futureOf` (`:999`, supplying `tv l.time < tv t'`), and
`mem_knownTimes_of_mem_futureOf`. **The soundness half of this repair is genuinely cheap.**

### 2.3 The `.branchingOrdered` switch is necessary and the orderings are right

`.branching`'s consumer appends each arm to `b` and passes **one** ordering to all arms
(`Tableau.lean:2129-2130`); `.branchingOrdered`'s arms are used as complete replacement branches
with per-arm orderings (`:2131-2133`, `Saturation.lean:666-690`). Since arm 1 needs `timeOrd`
and arm 2 needs `newOrd`, the switch is forced, and the diff correctly writes `++ branch` on
both arms.

### 2.4 The handoff's "`.branchingOrdered` previously had NO consumer" is **REFUTED**

It has six, and two of them impose real obligations:

| Consumer | Site | Obligation / effect under the diff |
|---|---|---|
| `expandOnce` / `expandOnceUnblocked` | `Tableau.lean:2131-2133`, `:2177` | arms must be complete branches — diff satisfies |
| `expandBranchWithFuel` | `Saturation.lean:666-690` | recurses under `pair.1.2` — diff satisfies |
| `expandOnceNoFresh` | `Tableau.lean:2201-2218` | **BROKEN — see §2.5** |
| `saturateBlocked` | `Saturation.lean:467-483` | **BROKEN — see §2.5** |
| `appliedEntryRedundant` | `Saturation.lean:165-176` | returns `false`; harmless (see below) |
| `findApplicableRule` | `Tableau.lean:1875-1882` | no guard; docstring becomes false (§2.6) |
| `sat_untl_neg` / `sat_snce_neg` | `CountermodelExtraction.lean:806`, `:873` | already have a `.branchingOrdered` case — survives |

`appliedEntryRedundant`'s `false` arm is **not** a live break: only `.persistent` results
contribute to the applied set (`Saturation.lean:766` returns `newApplied`; `:754` and `:763`
return `[]`), and `untlNeg` is never `.persistent`, so no `untlNeg` formula ever enters the
applied set to be tested. Its docstring at `:172-175` ("it has no live dependents") stays true.

### 2.5 **Consumer defect A — the outer ordering is understated. This is a real bug in the diff.**

The diff returns `timeOrd` as `applyRule`'s second component while hiding two new constraints
and a fresh time inside arm 2's paired ordering. Two guards read exactly that component:

`Tableau.lean:2206-2208` (`expandOnceNoFresh`):
```lean
if ruleMintsFreshLabel rule then none
else if newOrd.constraints.length > timeOrd.constraints.length then none
```
`Saturation.lean:468-469` (`saturateBlocked`):
```lean
if newOrd.constraints.length > timeOrd.constraints.length then
  some (.inr (b, timeOrd))  -- Reject: would create new time point
```

With `timeOrd` returned, both tests are **false**, and `untlNeg` is reachable from
`findApplicableRule`, which is the picker `expandOnceNoFresh` uses (`Tableau.lean:2203-2204`).
So the post-blocking pass — whose stated purpose is to finish work *"without extending the time
structure the blocking decision was made against"* (`Tableau.lean:2186-2187`) — would mint a
fresh time. `Saturation.lean:471-474`'s recorded invariant, *"this arm is unreachable from
`expandOnceNoFresh`, whose pick rejects any rule that lengthens the constraint list and every
ordered split does exactly that"*, becomes **false**. (It is true today only because
`timeLinearity` is reached through `findApplicableLinearityRule`, which `expandOnceNoFresh` does
not call.)

**Amendment**: return `newOrd`, not `timeOrd`, as the second component:

```lean
(.branchingOrdered [(branch1 ++ branch, timeOrd), (branch2 ++ branch, newOrd)], newOrd)
```

This is free with respect to `RuleSound`, because `SatResult`'s `.branchingOrdered` clause
ignores the second component (`Decidable.lean:193`).

### 2.6 Consumer defect B — dead guard and two false docstrings

Under the diff, control for `untlNeg`/`snceNeg` moves from the `.branching` arm of
`findApplicableRule` (`Tableau.lean:1864-1874`, which consults `ruleSelfGuarded` at `:1870`) to
the `.branchingOrdered` arm (`:1875-1882`, unguarded). Operationally identical — both return
`some (rule, result, newOrd)` — but:

- `ruleSelfGuarded` (`Tableau.lean:1757-1759`) maps **only** `.untlNeg`/`.snceNeg` to `true`, so
  it becomes dead code with no live call path.
- Its docstring `:1749-1755` ("*a target time counts only when neither co-decomposition output
  is on the branch yet*") becomes false — that is precisely the property §1.1 shows the diff
  destroys.
- `:1878-1881` ("*every arm that adds no formula, which is every arm of the only rule that
  produces this constructor*") becomes false: `untlNeg`'s arms add formulas.

### 2.7 Subformula closure — survives, with a proof repair, and the reason is not the obvious one

`RuleResult.emitted` is **not** uniform across constructors
(`SubformulaProperty.lean:134-139`):

```lean
| .branching bss => bss.flatten
| .branchingOrdered bs => (bs.map Prod.fst).flatten
```

so switching constructor turns `applyRule_untlNeg_closed` (`SubformulaProperty.lean:1082-1084`)
from "the added formulas stay in `C`" into "**the whole post-rule branch** stays in `C`" — which
the module docstring at `:94-100` records as the intended stronger reading for
`.branchingOrdered`. It is still provable: the hypothesis `hb : ∀ x ∈ b, x.formula ∈ C` covers
the `++ branch` members, and the genuinely new formulas are subformulas of `sf.formula`. Note
the handoff's expectation that the lemma *"should survive unchanged"* is wrong — the proof body
(the `simp only [RuleResult.emitted]` chain at `:1086-1090`) must be extended to route the
`++ branch` members through `hb`. Dropping `F(U(e,g))@t'` only shrinks the new-formula side and
makes it easier.

---

## 3. COMPLETENESS DIRECTION

### 3.1 The saturation lemmas: survive syntactically, become unreachable, and break under the §1.6 amendment

`sat_untl_neg` (`CountermodelExtraction.lean:766-773`) concludes

```lean
∀ t' ∈ timeOrd.futureOf t,
  ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b ∨ ⟨.neg, guard, ⟨w, t'⟩⟩ ∈ b
```

and derives it **entirely from the `unprocessed` filter's shape**, not from the arm's output —
see the `hFilterPred` construction at `:820-826`, which rebuilds the filter predicate verbatim.

Consequences, in order of severity:

1. **Diff as proposed (filter untouched)**: both theorems stay green. But their hypothesis
   `findUnexpanded b = none` is now unobtainable on any branch the arm touches (§1.2), so they
   become vacuous in practice. The countermodel extraction path silently stops producing.
2. **Diff plus the §1.6 amendment (filter widened)**: the conclusion becomes **false** — the
   branch carries `¬guard` at an interpolant, not at `t'`. Both theorems must be restated as
   `… ∨ ∃ z, ⟨.neg, guard, ⟨w,z⟩⟩ ∈ b ∧ z ∈ timeOrd.futureOf t ∧ t' ∈ timeOrd.futureOf z`, and
   re-proved. Both carry `set_option maxHeartbeats 3200000` (`CountermodelExtraction.lean:835`);
   these are not cheap.
3. There is a live downstream consumer: `TemporalGate.lean:34` records that its gate is
   *"stronger than `sat_untl_neg`'s `F(φ)@t' ∨ F(ψ)@t'`"* — the restatement propagates there.

### 3.2 The corpus rows named in the handoff **do not exist**

The handoff says *"Rows H, J, M, N (`U(p,q) → q` and `S(p,q) → q`) are the ones this arm
drives."* No such row IDs are in the pinned tables (`TableauConformance.lean:385-409` and the
three per-class tables at `:415`, `:445`, `:477`). The Until/Since rows are:

| Row | Formula | Site | Drives |
|---|---|---|---|
| `BX10 U->F` | `U(p,q) → F p` | `:302-303` | `untlPos` (Until is positive) |
| `BX10' S->P` | `S(p,q) → P p` | `:304-305` | `sncePos` |
| `BX7 lin-until` | `(U(p,⊤) ∧ U(q,⊤)) → (U(p∧q,⊤∧⊤) ∨ …)` | `:306-309` | **`untlNeg`** |
| `BX7' lin-since` | past mirror | `:310-313` | **`snceNeg`** |
| `Z1/Z2` | `F p → U(p,¬p)` / `P p → S(p,¬p)` | `:337-340` | Discrete only |

`BX7`/`BX7'` are the real gate: negating their consequent yields three `F(U(·,⊤∧⊤))` triggers
whose guard is `⊤∧⊤`, not `Formula.top`, so `asUntil?` accepts and the passive arm fires.
`BX10`/`BX10'` put the Until positively in the antecedent and do **not** exercise this arm.

### 3.3 The 29 rows + the existing probe are **necessary but not sufficient**

Three independent gaps:

1. **The probe breaks silently.** `UntlSnceCopyProbe.lean:144-147` destructures with
   `| .branching bss => bss | _ => []`. Under the diff `resB.1` is `.branchingOrdered`, so
   `armsB = []`, and row B1 (`:150-152`, expects `2`) fails while rows B2 (`:159-161`) and B4
   (`:174-178`) read `true`/`false` **vacuously**. B4 in particular would flip to `false` and be
   misread as "defect repaired" when it actually means "the matcher stopped matching".
2. **All Until/Since corpus rows target `CLOSED`.** The probe's own header states this at
   `UntlSnceCopyProbe.lean:15-17`: the corpus *"gates the under-closing direction only"*.
   Nothing in it measures step counts or time counts.
3. **Non-termination is not observable as a row change on the OPEN rows.** A diverging branch
   surfaces as `.fuelExhausted` (`DecisionProcedure.lean:193-194`), and `isValid = false`
   conflates that with `extractionFailed`.

**Additional probe rows required, stated precisely** (all in `UntlSnceCopyProbe.lean` section B,
on the existing `bB` / `srcB` / `ordB` at `:130-138`):

- **B1′** — re-pin `armsB` against `.branchingOrdered`:
  `def armsB := match resB.1 with | .branchingOrdered bs => bs.map Prod.fst | _ => []`,
  then `#eval armsB.length` → `2`.
- **B2′** — the mint is real and is strictly inside:
  `#eval (resB.1 matches .branchingOrdered _) && armsB.any (·.any (·.label.time == 2))` → `true`.
- **B3′** — the outer ordering now reports growth (pins §2.5's amendment):
  `#eval resB.2.constraints.length > ordB.constraints.length` → `true`.
- **B4′** — the defect is gone: no arm carries both `¬g@1` and `¬U(e,g)@1`
  (the current B4 body at `:176-178`) → `false`.
- **B5 (NEW, the row that would have caught §1.2)** — a bounded re-fire counter: run
  `expandBranchWithFuel bB k ordB .Base` for a small fixed `k` and `#eval` the resulting
  branch's `Branch.knownTimes.length`, pinned to a **fixed** number. Divergence shows up as a
  number that grows with `k`.
- **B6 (NEW, pins §2.5)** — `#eval (expandOnceNoFresh bB ordB .Base).1 matches .splitOrdered _`
  → `false`, i.e. the post-blocking pass still mints nothing.
- **C-section re-measure** — rows C2/C3/C5 (`isInvalid` / `getCountermodel?.isSome` /
  `isFuelExhausted`) must be re-taken: a fresh-time producer changes fuel consumption, and C5 is
  the row that reads `.fuelExhausted` directly.

Without **B5**, the acceptance gate cannot distinguish "repair landed" from "repair landed and
the engine now diverges".

---

## 4. THE REMAINING COPY BLOCKS

### 4.1 They are in a different arm and the diff does not touch them

`untlNegProps` (`Tableau.lean:1053-1058`) and `snceNegProps` (`:1126-1131`) live inside the
**ACTIVE** arm — the `futureTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4`
branch at `:1023` / `:1097` — consumed at `:1061` and `:1134`. The proposed diff edits only the
`| t' :: _ =>` PASSIVE arm. So the copies are neither helped nor harmed by it directly.

### 4.2 They remain load-bearing for the unsoundness, and are deletable by the **same** argument

They are counted among the five unsound sites at `Decidable.lean:2183-2185`. The argument that
killed the `untlPos`/`sncePos` copies applies verbatim (`Decidable.lean:2201-2204`): a guarded
copy is unavailable because soundness would need `¬U(e',g')@A → ¬U(e',g')@C` for a freshly
chosen `C > A`, *"a semantic condition on the model that no syntactic guard computable from
`(branch, ord)` expresses"*. The ACTIVE arm mints `freshTime` **above** `l.time`
(`:1029-1031`) exactly as `untlPos` does, so the counterexample transfers with no change.
Deletion can only make branches harder to close, so its only risk is under-closing — the
direction the 29-row corpus measures directly.

**Verdict: deletable now, by the argument already carried in report 03. Necessary for
`RuleSound carrierBase .untlNeg` regardless of what happens to the passive arm.**

### 4.3 Under the diff they become **harder to test**, not more dangerous

The ACTIVE arm is reachable only when `futureTimes.isEmpty`. Under the diff the passive arm mints
times into `futureOf l.time`, so that precondition becomes strictly harder to reach and the
copies' behaviour becomes correspondingly harder to isolate in a probe.

### 4.4 Land them **separately, and first**

Bundling the copy deletion with the passive-arm rewrite in one `Tableau.lean` rebuild would make
any corpus regression **unattributable** between two independent causes. The `untlPos`/`sncePos`
precedent is the model to copy: corpus measured green before, edit, corpus measured green after,
zero rows changed, 59 s. Do the same here, alone.

---

## 5. Adversarial Self-Verification

Every load-bearing claim, its evidence, and what would falsify it.

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| The `unprocessed` filter tests both outputs **at `t'`**, and the diff removes `¬guard` from `t'` | `Tableau.lean:1017-1020` vs. the diff's `branch2 := [neg guard interLabel, sf]` | Direct read of the filter and the proposed body | High — CONFIRMED |
| The recursion re-enters branch 2 under `newOrd`, so `t'` is still in `futureOf l.time` and still unfiltered | `Saturation.lean:666-690`, recursive call `expandBranchWithFuel pair.1.1 … pair.1.2` at `:680-681`; `futureOf` is transitive, `SignedFormula.lean:776-777` | Trace of the consumer + closure definition | High — CONFIRMED |
| Blocking cannot suppress the arm: it blocks *sources*, and the source is `l.time` | `Tableau.lean:2159-2160` (`findUnexpandedUnblockedWith … blocked`); `TimeTypeBound.lean:153` (ancestors only) | Read of the picker and of the blocking predicate | High — CONFIRMED |
| `densityRule`'s live guard is `gapTargets` (maximal, unfilled), not `existingIntermediates`; and it does not transfer | `Tableau.lean:1303-1308` (code), `:1283, 1726, 1738, 1858` (stale comments), `:1313` (the `fresh < t'` edge) | Direct read; the handoff's `existingIntermediates` reference is to a name no longer in code | High — CONFIRMED (handoff wording corrected) |
| No proved termination theorem breaks, because all of them assume `NoSplit` | `Fuel.lean:1250-1254`, `:1271-1277`; outstanding item at `:74-79` | Read of the hypothesis | High — CONFIRMED |
| The finite-universe premise `b.timeFinset.card ≤ 2^(2*C.card)` is conditional on blocking firing | `Fuel.lean:588-594` `timeFinset_card_le_of_not_blocked (hnb : findBlockedTime … = none)` | Read of the hypothesis | High — CONFIRMED |
| The §1.6 widened filter stops single-formula but **not** cross-formula divergence | Constructed two-formula trace in §1.6; no code forbids two `F(U(·,·))` at one label — `BX7` (`TableauConformance.lean:306-309`) puts **three** on one branch | Hand-constructed counterexample against the amended guard | Medium — the descent is a semantic argument, not a measured run; **B5 would settle it** |
| The two emitted arms are semantically sound | `Truth.lean:134-135`; negation at `A` with `A < C'` yields exactly the two disjuncts | Definitional unfolding of `TruthAt` | High — CONFIRMED |
| `SatResult` re-chooses `hist`/`tv` wholesale and ignores the outer ordering | `Decidable.lean:193` — `\| .branchingOrdered brs, _ => ∃ p ∈ brs, ∃ hist tv, SatState M Om hist tv p.1 p.2` | Direct read | High — CONFIRMED |
| The needed `ordResp` helper is already proved and matches `newOrd` exactly | `Decidable.lean:1590-1596`, conclusion over `((ord.addFuture t b.nextTime).addFuture b.nextTime t').constraints` | Read of the theorem statement | High — CONFIRMED |
| Returning `timeOrd` as the outer component defeats two fresh-time rejection guards | `Tableau.lean:2206-2208`; `Saturation.lean:468-469`; invariant claimed at `Saturation.lean:471-474` and `Tableau.lean:2196-2199` | Read of both guards + the picker at `Tableau.lean:2203-2204` | High — CONFIRMED |
| `.branchingOrdered` did **not** previously lack consumers | Six sites tabulated in §2.4 | Grep + read of each | High — REFUTES the handoff's claim |
| `appliedEntryRedundant`'s `false` arm is harmless because `untlNeg` never enters the applied set | `Saturation.lean:766` (`.persistent` returns `newApplied`) vs `:754`, `:763` (return `[]`) | Read of all arms of `expandOnceWithApplied` | High — CONFIRMED |
| `applyRule_untlNeg_closed` needs a **proof repair**, contra the handoff's "should survive unchanged" | `SubformulaProperty.lean:134-139` (`emitted` is constructor-dependent), `:94-100` (docstring), `:1082-1090` (the lemma + proof body) | Read of `emitted` and the lemma | High — CONFIRMED (handoff expectation corrected) |
| `sat_untl_neg`/`sat_snce_neg` read the filter, not the arm, so the diff-as-proposed leaves them green but vacuous | `CountermodelExtraction.lean:766-773` (statement), `:820-833` (derivation from `hFilterPred`) | Read of the full proof | High — CONFIRMED |
| Corpus rows "H, J, M, N" **do not exist**; `BX7`/`BX7'` are the real gate | `TableauConformance.lean:385-409`, `:302-313` | Enumeration of the pinned tables | High — REFUTES the handoff's row naming |
| `UntlSnceCopyProbe` section B breaks silently under the constructor switch | `UntlSnceCopyProbe.lean:144-147` matches `.branching` only; rows at `:150-178` | Read of the destructuring | High — CONFIRMED |
| The ACTIVE-arm copy blocks are deletable by the `untlPos`/`sncePos` argument | `Tableau.lean:1053-1058`, `:1126-1131`, `:1029-1031` (mints above `l.time`); `Decidable.lean:2201-2204` | Structural comparison with the deleted blocks | High — CONFIRMED |
| The diff, once amended, would still compile / the corpus would stay green | — | Not attempted: read-only dispatch, no build | **UNVERIFIABLE-WITHOUT-BUILD** |
| The exact number of corpus rows that flip under the amended repair | — | Requires the 59 s conformance run | **UNVERIFIABLE-WITHOUT-BUILD** |

### Contradiction Log

**Resolved.** The handoff's `blockers[0]` names `densityRule`'s guard as `existingIntermediates`
and describes the repair as *"plausibly on the `existingIntermediates` shape"*. That identifier
is not live code (`Tableau.lean:1283, 1726, 1738, 1858` are comments only); the live guard is
`gapTargets` (`:1303-1308`). Precedence: **code over prose.** The correction matters
substantively — `gapTargets` works by making the interpolant non-maximal and therefore never a
target, and §1.4 shows that mechanism is unavailable to `untlNeg` because its obligation is
universal over future times. So the handoff's suggested repair direction was resting on a
mechanism that does not transfer.

**Resolved.** The handoff states `.branchingOrdered` *"previously had NO consumer"*. Refuted by
six sites (§2.4). Precedence: **grep over recollection.** Two of those consumers
(`expandOnceNoFresh`, `saturateBlocked`) are broken by the diff.

**Resolved.** The handoff asserts `applyRule_untlNeg_closed` *"should survive unchanged"*.
Refuted by `RuleResult.emitted`'s constructor-dependent definition
(`SubformulaProperty.lean:134-139`). Precedence: **definition over expectation.**

### Recommendations modified after verification

1. The initial reading of the escalation was that termination was the only open question and the
   `.branchingOrdered` switch was routine. Verification found the switch carries **three**
   further obligations (§2.5 outer ordering, §2.6 dead guard + false docstrings, §2.7 `emitted`
   proof repair), one of which is a genuine bug in the diff.
2. The §1.6 "minimal amendment" was initially going to be the whole ruling. Constructing the
   two-formula descent (§1.6) demoted it to necessary-but-insufficient and forced the hard-cap
   conclusion.
3. The copy-block question was initially expected to be "delete in the same edit". Verification
   changed this to **separate and first**, on attributability grounds (§4.4).

---

## 6. FINAL VERDICT — **REFUTE the diff as proposed**

The diff is **not authorized**. Two independent reasons, either sufficient:

1. **Termination fails and is not minimally repairable.** The re-fire guard breaks (§1.1-1.2),
   blocking cannot substitute (§1.3), `densityRule`'s mechanism does not transfer (§1.4), and
   the natural filter amendment leaves cross-formula descent unbounded (§1.6).
2. **The diff contains a concrete bug independent of termination**: returning `timeOrd` as
   `applyRule`'s second component defeats the two fresh-time rejection guards at
   `Tableau.lean:2206-2208` and `Saturation.lean:468-469` (§2.5).

The **soundness** half of the proposal is correct and is not the problem: the arms match the
semantics exactly (§2.1), and the discharging helper is already proved with a
character-for-character matching statement (§2.2). That is worth preserving for whoever
implements the eventual repair.

### What IS authorized, now, as its own commit

**Delete the two remaining copy blocks and nothing else**:

- `Tableau.lean:1053-1058` — the `untlNegProps` block, and its use at `:1061`
  (`autoProp := gProps ++ fNegProps ++ modalProps`).
- `Tableau.lean:1126-1131` — the `snceNegProps` block, and its use at `:1134`
  (`autoProp := hProps ++ pNegProps ++ modalProps`).

Gate: the 29-row conformance corpus, measured **before and after** (59 s), plus
`UntlSnceCopyProbe` sections A and C re-pinned. Risk is under-closing only, which is exactly what
the gate measures. This is necessary for `RuleSound carrierBase .untlNeg`/`.snceNeg` under any
future passive-arm design, and it carries zero new design decisions.

Do **not** bundle it with anything else (§4.4).

### What the passive-arm repair would require, if pursued later

Not a one-file edit. The minimum viable package is five coordinated items:

| # | Item | Site |
|---|---|---|
| A1 | Widen the `unprocessed` filter to the half-open interval `(l.time, t']` (§1.6 code) | `Tableau.lean:1017-1020` |
| A2 | Return `newOrd`, not `timeOrd`, as `applyRule`'s second component | the diff's last line |
| A3 | Add an interpolant cap of the `timeOrd.timeCount < 4` shape — A1 alone does not stop cross-formula descent | new, modelled on `Tableau.lean:1023` |
| A4 | Restate + re-prove `sat_untl_neg` / `sat_snce_neg` with the interval-existential conclusion; repair `applyRule_untlNeg_closed` / `_snceNeg_closed` for `emitted`'s `.branchingOrdered` clause | `CountermodelExtraction.lean:766`, `:841`; `SubformulaProperty.lean:1082`, `:1114` |
| A5 | Correct `ruleSelfGuarded` and the two false docstrings; re-pin probe section B per §3.3 (B1′-B4′, **B5**, B6) | `Tableau.lean:1749-1759`, `:1878-1881`; `UntlSnceCopyProbe.lean:144-178` |

A3 buys **bounded completeness only** — the same trade the ACTIVE arm already made and
documented at `Tableau.lean:1026-1029`. That is a new acceptance criterion and should be
declared explicitly before the work starts, not discovered afterwards.

**A3 is the item to challenge first in any follow-up plan.** If a terminating, unbounded-complete
formulation exists, it is not visible from this codebase's current machinery, and the honest
alternative to A3 is to leave `RuleSound carrierBase .untlNeg`/`.snceNeg` open and route 7.2's
remaining budget to the six discrete/Dedekind rules in `blockers[1]`, which are blocked only on a
design decision and whose semantic content is already proved in the tree.
