# Research Report: Seriality Performance Under Node-Level Blocking, and the `expandOnce_length_lt` Route

- **Task**: 165 — establish_semantic_finite_model_property (tableau decidability)
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Type**: lean4
- **Session**: sess_1785198629_c14175
- **Mode**: `--hard` (H2 anti-analysis, H3 reference grounding, H4 adversarial self-verification)
- **Focus**: blocker research — 2.6 `serialityRule` performance; `expandOnce_length_lt`
- **Research inputs**: plans/01_tableau-decidability-two-track.md (Phase 2.5/2.6 + BLOCKER block);
  reports/04_blocker-resolution-r5-branchorder-seriality.md (§Q1.4, §Q3.4-Q3.6);
  `.orchestrator-handoff.json` (2026-07-27); `2.6-serialityRule-wip.patch`
- **Reference grounding tier**: Tier 3 (implementation-backed). No load-bearing claim rests on
  literature. Every claim below is either a `file:line` citation or a measurement made in this
  dispatch.
- **Tree state**: the committed tree is **unchanged**. `Tableau.lean` and `TraceCertificate.lean`
  hash to `41470eb63…` / `f8aad8c4c…`, byte-identical to the pre-dispatch blobs; `git status`
  shows only the two pre-existing modifications (`latex/subfiles/04-Metalogic.log`,
  `specs/events.jsonl`) that were dirty on entry. All measurement patches were applied and
  reverted; all scratch `.lean` files were deleted.

---

## Executive summary

**Q1 (seriality performance) is fully resolved, and the diagnosis is not what the handoff
predicted.** The 70x+ blowup is *not* a per-step constant-factor problem to be optimised away by
caching the blocked set. It is a **termination defect**: under node-level blocking, the
*past*-directed half of the serial chain is **unblockable by construction**, so on every
genuinely-open row the engine mints times until the fuel budget is exhausted. The cause is one
line: `ancestorTimes ord t = ord.pastOf t` (`SignedFormula.lean:782-783`). A time freshly minted
by `somePastPos` is a new global minimum, so its `pastOf` is empty, so it has no blocking
candidates, ever.

The fix is four lines. Measured end to end:

| | before 2.6 | 2.6 as patched | 2.6 + fix |
|---|---|---|---|
| `lake build …Decidability.Saturation` | ~8 s | **> 590 s** | **8.5 s** |
| `lake build BimodalTest.TableauConformance` | 37 s | **> 590 s** | **35 s** |
| row `C2 p` (`.Base`, fuel 200) | OPEN, 1 step | STALL, 200 steps, **87 819 ms** | OPEN, 7 steps, **1 ms** |
| row `C3 Gp->p` | OPEN, 3 steps | STALL, 200 steps, **82 380 ms** | OPEN, 11 steps, **3 ms** |
| row `Fp->FFp` | OPEN, 3 steps | STALL, 200 steps, **82 057 ms** | OPEN, 13 steps, **5 ms** |

With the fix, the corpus moves **exactly the 10 rows report 04 §Q3.6 predicted** (`S1`-`S5`,
`K2`-`K6`), in **all four** frame classes — 40 rows, `OPEN [DEFECT]` → `CLOSED`, and **no other
verdict moves anywhere**, including counterexamples `A`/`B` and every control. The `.Discrete`
`K2`/`K3` residual that report 04 §Q3.5 flagged as the one row-pair to chase **closes**; it does
not need documenting as an open defect.

Two of report 04's Phase-7-facing predictions are **refuted by this measurement** (see
Contradiction Log C1, C2): the certificate does **not** have to become a disjunction, and open
branches do **not** all terminate `OPEN-blocked`.

**Q2 (`expandOnce_length_lt`) is resolved, and the previous dispatch's diagnosis was also
wrong.** The obstacle was never higher-order unification and never `filterMap`. It was two
tactic-level facts: (a) `split at h` cannot see inside `(if c then x else y).1`, so the seven
guard `ite`s were never opened — inserting `simp only [apply_ite Prod.fst] at h` opens all of
them; and (b) `first | simp_all | <fallback>` never reaches the fallback, because `simp_all`
*succeeds* whenever it makes progress, even leaving the goal open. Once (a) is fixed the residual
obligation is `¬ l.isEmpty = true → l ≠ []`, which `simp` discharges — no helper lemma of any
shape is required. **Five of the six lemmas in the chain were written and compiled sorry-free in
this dispatch** (exact text in §Q2.3). The sixth, `expandOnceUnblocked_length_lt`, is one
`rcases`-on-the-two-stage-pick away and its exact residual goal state is recorded.

Separately: the lemma as named in the plan is stated about **the wrong function**.
`expandBranchWithFuel` calls `expandOnceUnblockedWithApplied` → `expandOnceUnblocked`
(`Saturation.lean:407`, `Tableau.lean:1929`); nothing on the proof path calls `expandOnce`.

**Q3 (sequencing)**: land 2.6 next, before 2.7 and 2.4, as originally ordered. The fix makes 2.6
cheaper than 2.7, not more expensive, and 2.4's certificate design is *simplified* by what 2.6
now measures.

---

## Q1 — Seriality performance

### Q1.1 Method

`git apply --include='FormalSystem/*' 2.6-serialityRule-wip.patch` applied the WIP cleanly (the
patch also carries `latex/…04-Metalogic.log` and `specs/events.jsonl` noise hunks, which
`--include` skips). Because `Saturation.lean` could not be built with the patch in, the first
measurement used a standalone probe run under `lake env lean`, importing
`…Decidability.Closure` + `…Decidability.TraceCertificate` and re-implementing
`expandBranchWithFuel` with a step counter, copying `registerEventualities`,
`fulfillEventualities`, `estimateBranchDifficulty` and `allocateFuelProportionally` verbatim from
`Saturation.lean:240-345`. The A/B ran **in a single build**: the baseline arm re-states the
pre-2.6 `expandOnceUnblocked` body (`findUnexpandedUnblocked` is semantically unchanged by the
patch — it merely delegates to the new `findUnexpandedUnblockedWith`), and the seriality arm
calls the patched `expandOnceUnblocked` directly.

Once the diagnosis was in hand, everything was re-measured **end to end against the real
`buildTableau` and the real conformance corpus**, which is the authoritative result.

### Q1.2 The measured hotspot is a non-terminating chain, not a slow step

The A/B at `.Base`, fuel 200, 15 corpus rows:

| row | plain | 2.6 as patched |
|---|---|---|
| `C1 p->p` | CLOSED 1 step 0 ms | CLOSED 1 step 0 ms |
| `C2 p` | OPEN 1 step 0 ms | **STALL 200 steps, len 266, 68 times, 87 819 ms** |
| `C3 Gp->p` | OPEN 3 steps 0 ms | **STALL 200 steps, len 268, 67 times, 82 380 ms** |
| `C5 K_G` | CLOSED 8 steps 1 ms | CLOSED 8 steps 1 ms |
| `S1`-`S5` | OPEN | **CLOSED, 1-6 steps, ≤ 1 ms** |
| `K0`-`K3` | K0/K1 CLOSED, K2/K3 OPEN | **all CLOSED, 1-9 steps, ≤ 1 ms** |
| `A Gp->GGp` | CLOSED 10 steps 1 ms | CLOSED 10 steps 1 ms |
| `Fp->FFp` | OPEN 3 steps 0 ms | **STALL 200 steps, len 269, 68 times, 82 057 ms** |

Read this carefully: **every row seriality is *supposed* to fix is fast and correct.** The cost
lands entirely on rows that are genuinely open, where seriality has nothing to contribute and
never stops. 68 distinct times inside a 200-step budget is one new time every three steps, all
the way to fuel exhaustion.

### Q1.3 Why the chain does not block — the root cause, traced

Step-by-step trace of `C2` (the bare atom `p`) under the patched engine, printing the blocked set
and the ordering at every step:

```
0:  len=1  nT=1  blocked=[]        stage1=NONE->serial  times=[0]        ord=[]
2:  len=4  nT=2  blocked=[]        stage1=rule          times=[1,0]      ord=[(0,1)]
4:  len=6  nT=3  blocked=[]        stage1=rule          times=[2,1,0]    ord=[(2,0),(0,1)]
5:  len=7  nT=3  blocked=[1]       stage1=NONE->serial  times=[2,1,0]    ord=[(2,0),(0,1)]
10: len=14 nT=5  blocked=[2,1]     stage1=rule          times=[4,3,2,1,0]
                                   ord=[(4,3),(3,2),(2,0),(0,1)]
16: len=22 nT=7  blocked=[4,3,2,1] ord=[(6,5),(5,4),(4,3),(3,2),(2,0),(0,1)]
25: len=34 nT=10 blocked=[7,6,5,4,3,2,1]
                                   ord=[(9,8),(8,7),(7,6),(6,5),(5,4),(4,3),(3,2),(2,0),(0,1)]
```

The shape is unmistakable. `(0,1)` is the *future* witness minted from `T(F⊤)@0`; it is blocked
by step 5 and never causes trouble again — the future direction works exactly as report 04 §Q3.5
described. `(2,0)` is the **past** witness minted from `T(P⊤)@0`, and from there the ordering
grows `(3,2), (4,3), (5,4), (6,5), (7,6), (8,7), (9,8), …` without bound. The blocked set grows
too, but it **always excludes the newest time**: `[1] → [2,1] → [3,2,1] → …`.

The reason is `ancestorTimes`:

```lean
-- SignedFormula.lean:782-783
def ancestorTimes (ord : TimeOrdering) (t : TimeIndex) (fuel : Nat := 100) : List TimeIndex :=
  ord.pastOf t fuel
```

consumed by `isTemporallyBlockedSaturated` (`Tableau.lean:1649-1655`) as the *only* source of
blocking candidates. A time minted by `somePastPos` is placed strictly *before* everything on the
branch, so `ord.pastOf t = []`, so `(ancestorTimes ord t).any … = false` unconditionally. Blocking
is a past-directed loop check; a past-*growing* chain has no ancestors, by construction. Seriality
then serves that unblocked time, `somePastPos` mints its predecessor, and the loop repeats.

**This is a pre-existing latent defect in the blocking predicate that 2.6 merely exposes.** It
was invisible before because nothing else drove sustained past-directed generation from a
saturated label, and it was invisible to report 04 because the prototype it measured still
carried the *branch-level* halt — which terminated the whole branch at step 5, the moment time 1
blocked, before the past chain could get going. Sub-phase 2.5 removed that halt (plan:456-462).

### Q1.4 The per-step cost, quantified — it is real but secondary

Measured on the growing `C2` branch under the unfixed engine:

| after n steps | `len` | `nT` | `blockedTimes` | stage-1 scan | seriality-stage scan |
|---|---|---|---|---|---|
| 20 | 27 | 8 | 1 ms | 1 ms | 0 ms |
| 40 | 54 | 15 | 9 ms | 0 ms | 0 ms |
| 60 | 81 | 21 | 26 ms | 0 ms | 1 ms |

`blockedTimes` dominates and grows roughly as `len^2.2`, consistent with its cost model
`O(|T| · |b|² · |rules|)`: `Tableau.lean:1639-1641` filters `knownTimes` through
`isTemporallyBlockedSaturated`, which runs `timeSaturated` (`1566-1569`) per surviving ancestor
pair, and `timeSaturated` runs `isExpanded` — a `findApplicableRule` sweep over ~33 rules — per
formula at that time.

So the two effects multiply: an unbounded step count times a per-step cost that grows
quadratically in a branch that is itself growing. That is where 70x becomes 10 000x. But note the
direction of the argument: **capping the step count removes both**, whereas caching `blockedTimes`
would only have made a non-terminating loop non-terminate more cheaply.

### Q1.5 The chosen design — bidirectional, creation-ordered blocking

**Exact code shape.** In `Tableau.lean`, immediately before `isTemporallyBlockedSaturated`
(currently line 1649):

```lean
/--
The times `t` may be blocked *against*: order-related times that were created **earlier**.

`ancestorTimes` alone is `ord.pastOf t` (`SignedFormula.lean:782`), which is the right candidate
set only for chains that grow into the future. A time minted by `somePastPos` is placed strictly
before everything on the branch, so its `pastOf` is empty and it can never be blocked — and
`serialityRule` demands a predecessor at *every* label, so the past-directed chain
`T(P⊤)@t ⟶ t' ⟶ t'' ⟶ …` runs to fuel exhaustion. Measured before this repair: the bare atom `p`
at `.Base` consumed all 200 fuel, reaching 266 formulas over 68 times in 88 s; after it, 7 steps
in 1 ms.

The `t' < t` filter is what keeps the added arm well-founded: fresh times are minted at
`Branch.nextTime = maxTime + 1` (`SignedFormula.lean:363`), so numeric index order **is** creation
order, and a time can only be blocked by one created strictly before it. Without the filter a time
and its own future witness could block each other.

`ancestorTimes` is retained unfiltered, so this arm is purely additive: no candidate the previous
predicate considered is dropped. (Measured: with this change and seriality *off*, the entire
four-class corpus, `CertificateProbe` and `TimeOrderProbe` are unmoved.)
-/
def blockCandidates (ord : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  ancestorTimes ord t ++ (ord.futureOf t).filter (fun t' => t' < t)
```

and the one-line change to the predicate:

```lean
def isTemporallyBlockedSaturated (b : Branch) (t : TimeIndex) (ord : TimeOrdering)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty) : Bool :=
  (blockCandidates ord t).any fun t_anc =>        -- was: (ancestorTimes ord t).any
    b.isSubsetBlocked t t_anc
      && allEventualitiesFulfilledOrDuplicated tracker t t_anc
      && timeSaturated b t_anc ord fc
```

That is the whole fix. Nothing else in the WIP patch changes.

**Soundness.** The added arm is the exact dual of the existing one. Blocking's story is "expanding
*from* `t` cannot produce anything `t_anc` does not already offer, so identify `t` with `t_anc` in
the extracted model" — a claim about type containment plus the ancestor being finished, neither of
which is directionally asymmetric. The asymmetry in the current code is an artifact of
`ancestorTimes` being defined for the future-directed existentials only. The `t' < t` filter
supplies the well-foundedness the identification argument needs (Phase 7.1 gets a strictly
decreasing creation index to induct on, in both directions).

**Predicted corpus timing — measured, not predicted.** `lake build
FormalSystem.Metalogic.Decidability.Saturation` **8.5 s** with the full inline `#eval` smoke suite
passing (`PASS FC1`-`FC9`, `PL1`-`PL5`, `AN1`-`AN8`, `FA1`-`FA5`, zero `FAIL`); `lake build
BimodalTest.TableauConformance` **35 s**. Baselines are ~8 s and 37 s. The conformance build is
marginally *faster* than baseline, because ten rows per class now close early instead of exploring
to saturation.

### Q1.6 Corpus movement — exactly report 04 §Q3.6's prediction, and nothing else

11 `#guard_msgs` blocks report a mismatch, and every one is an intended re-pin:

| block | lines | what moved |
|---|---|---|
| `.Base` table | `TableauConformance.lean:397` | `S1`-`S5`, `K2`-`K6`: `OPEN [DEFECT]` → `CLOSED` |
| `.Dense` table | `:427` | same 10 rows |
| `.Discrete` table | `:459` | same 10 rows |
| `.Dedekind` table | `:492` | same 10 rows |
| `TimeOrderProbe` W1-W7 | `:734, 739, 744, 749, 755, 760, 766` | `knownTimes`/`constraints`/`incomparable` grow (serial witness times); `total` unchanged for W1-W4, and W5/W6 flip `true` → `false` |

Unmoved: every control (`C1`, `C2`, `C3`, `C5`, `C4`), both counterexamples (`A`, `B` — `B` still
closes at its per-row fuel 100000 in the dense classes), `BX7`/`BX7'`/`BX10`/`BX10'`/`BX11`/`BX11'`,
`R1`/`R2`/`R3`, and **`CertificateProbe` — which passes unchanged**.

Note the `TimeOrderProbe` movement is the signal 2.8 was built to produce: plan:352-360 records
that the probe deliberately pins `knownTimes` alongside the verdict "so 2.5's expected
`knownTimes` change is visible as a distinct signal from 2.7's expected `total` flip". The W5/W6
`total` regression from `true` to `false` is expected and benign — seriality adds times that
`timeLinearity` (sub-phase 2.7) has not yet been built to order. **2.7's done-criterion is
unchanged in kind but its baseline moves**: after 2.6, W1-W7 must *all* flip to `total=true`,
not just W1-W4.

### Q1.7 The candidate directions from the dispatch brief, scored against measurement

| direction | verdict |
|---|---|
| (a) cheaper global-quiescence check | **Rejected as the fix.** Stage-1 scan measured at 0-1 ms/step vs `blockedTimes` at 26 ms/step; it is not the hotspot. |
| (b) memoize/incrementalize the quiescence test | **Rejected as the fix, retained as a reserve.** `blockedTimes` *is* the per-step hotspot (§Q1.4), but with the chain bounded the corpus is already at baseline speed. Caching it across the steps of one branch is a measured ~26 ms/step lever available if 2.7 or Phase 4 pushes cost back up. Do not spend a dispatch on it now. |
| (c) fire seriality once per label | **Refuted.** Does not bound the chain: each firing creates the next label, which has not been served. |
| (d) bound serial-chain length via the blocking predicate | **Adopted — this is the fix.** The measurement shows blocking bounds the *future* chain already and cannot bound the *past* chain at all until `blockCandidates` exists. |
| (e) restrict seriality targets to G/H/F/P scope | **Rejected.** Report 04 §Q3.2 measured `K2` needing `G(F⊤)` rather than `F⊤` as its premise, i.e. the rule must fire at every label; and the fix removes the motive. |
| handoff's own suggestion (b): suppress seriality where a successor already exists | **Rejected.** Would not terminate — every new endpoint lacks a successor. Also unnecessary. |
| handoff's own suggestion (c): re-measure the 24/24 fuel requirement | **Done. Fuel 200 suffices**, unchanged; all four class tables hit target at `conformanceFuel = 200` with no per-row override beyond row B's pre-existing one. |

---

## Q2 — `expandOnce_length_lt`

### Q2.1 The lemma is stated about a function the proof path never calls

`expandBranchWithFuel` — the only expansion loop Phase 4.3's `buildTableau_isSome` reasons about —
calls `expandOnceUnblockedWithApplied` (`Saturation.lean:407`), an inert wrapper that delegates to
`expandOnceUnblocked` (`Tableau.lean:1929`). The post-blocking pass `saturateBlocked` calls
`expandOnceNoFresh` (`Saturation.lean:680`). The bare `expandOnce` is reached only from
`expandOnceWithApplied` (`Tableau.lean:1916`, itself an inert wrapper with no live caller) and
from `CancellableExpansion.lean:138`, a runtime-only mirror outside every proof path.

**The lemma must be stated for `expandOnceUnblocked`.** This is a plan text correction, not a
scope change: the three functions share a byte-identical result tail, so the supporting lemmas are
shared and only the outermost statement differs.

### Q2.2 Why the four previous attempts failed — and it was not unification

Reproduced exactly. `unfold applyRule at h; repeat' split at h` leaves ~15 goals whose hypothesis
is still an unopened `(if c then (RuleResult.notApplicable, ord) else (RuleResult.persistent …,
ord)).1 = RuleResult.persistent fs`. **`split` cannot see through the `Prod.fst` projection**, so
the seven `if newFormulas.isEmpty then … else …` guards are never opened, and the goal that
survives *looks* like a statement about `filterMap` because the guard that discharges it is still
sealed inside the `ite`.

Inserting `simp only [apply_ite Prod.fst] at h` into the loop opens all of them, and the surviving
hypothesis is the guard itself: `¬ (List.filterMap … ).isEmpty = true`. The obligation is then
`¬ l.isEmpty = true → l ≠ []`, i.e. `List.isEmpty_eq_true`, which plain `simp` closes. **No
`filterMap` lemma, and no helper of any shape, is needed.** The 14 `.persistent` return sites
break down as: 7 guarded by `if newFormulas.isEmpty` (`Tableau.lean:443, 541, 550, 559, 599, 673,
717`), 6 literal singletons `[newSf]` (`:1138, 1148, 1165, 1184, 1200, 1220`), and 1 syntactic cons
`witness :: gProps` (`:1129`, `densityRule`). Post-2.6 there is a 15th, seriality's
`if outs.isEmpty then … else .persistent outs` (`:1234` in the patched file), of the first kind.

A second, independent trap accounts for the "helper compiles but does not fire" symptom: a closer
written as `first | simp_all | <fallback>` **never reaches the fallback**, because `simp_all`
reports success whenever it makes any progress, even when it leaves the goal open. Both of the
prior dispatch's failure descriptions are consistent with this.

The fresh-label `.linear` case needs no `filterMap` reasoning either: all eight
`ruleMintsFreshLabel` constructors (`Tableau.lean:1439-1442`) return a **syntactic cons whose head
is the witness** — `(.linear (witness :: …))` at `:485, 530, 590, 630, 661, 705` and
`(.branching [branch1 ++ autoProp, branch2 ++ autoProp])` at `:762, 807` with
`branch1 = [SignedFormula.pos event freshLabel]`. `List.cons_ne_nil` closes each.

### Q2.3 The lemma chain, as compiled in this dispatch

Five of six links were written and **compiled sorry-free** against the live tree (elaboration
~80 s for the first three, which each sweep 36 constructors; ~10 s for the rest). Text below is
verbatim from the compiling scratch file.

```lean
theorem applyRule_persistent_ne_nil
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fs : List SignedFormula}
    (h : (applyRule rule sf b ord).1 = RuleResult.persistent fs) : fs ≠ [] := by
  unfold applyRule at h
  repeat' first
    | split at h
    | simp only [apply_ite Prod.fst] at h
  all_goals (try (injection h with h))
  all_goals first
    | (simp_all; done)
    | (subst h; simp_all)

theorem applyRule_fresh_linear_ne_nil
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fs : List SignedFormula}
    (hfresh : ruleMintsFreshLabel rule = true)
    (h : (applyRule rule sf b ord).1 = RuleResult.linear fs) : fs ≠ [] := by
  cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
    (unfold applyRule at h
     repeat' first
       | split at h
       | simp only [apply_ite Prod.fst] at h)
  all_goals (try (injection h with h))
  all_goals first
    | (simp_all; done)
    | (subst h; simp_all)

theorem applyRule_fresh_branching_ne_nil
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {bss : List (List SignedFormula)}
    (hfresh : ruleMintsFreshLabel rule = true)
    (h : (applyRule rule sf b ord).1 = RuleResult.branching bss) :
    ∀ fs ∈ bss, fs ≠ [] := by
  -- identical tactic block to the previous lemma
```

`cases rule` **before** unfolding is load-bearing in the last two: it discharges the 28 non-fresh
constructors from `hfresh : false = true` and keeps `unfold applyRule` off them entirely.

```lean
theorem findApplicableRule_extending_ne_nil
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {rule : TableauRule} {ord' : TimeOrdering} {fs : List SignedFormula}
    (h : findApplicableRule sf b ord fc = some (rule, RuleResult.linear fs, ord')
       ∨ findApplicableRule sf b ord fc = some (rule, RuleResult.persistent fs, ord')) :
    fs ≠ [] := by
  rcases h with h | h <;>
    (unfold findApplicableRule at h
     obtain ⟨r, _, hr⟩ := List.exists_of_findSome?_eq_some h
     repeat' split at hr)
  all_goals simp_all
  all_goals first
    | exact applyRule_fresh_linear_ne_nil (by assumption) (congrArg Prod.fst (by assumption))
    | exact applyRule_persistent_ne_nil (congrArg Prod.fst (by assumption))
    | (intro hnil; subst hnil; simp_all)
```

Three details are load-bearing and were each found by measurement:
- `FrameClass` must be written `ProofSystem.FrameClass` inside
  `namespace FormalSystem.Metalogic.Decidability`, or the binder resolves to the wrong constant.
- `List.exists_of_findSome?_eq_some` is the right entry point
  (`Init/Data/List/Find.lean:46`, verified present in the pinned v4.33.0-rc1 toolchain).
  `List.findSome?_eq_some_iff` also exists (`:65`) but yields a three-way list decomposition that
  is strictly more work here.
- `rcases h` **before** unfolding, so `res` is already `.linear fs` / `.persistent fs` when the
  splits run; deferring it leaves six goals `simp_all` cannot touch.
- `congrArg Prod.fst (by assumption)` is what converts the split's
  `applyRule rule sf b ord = (res, ord')` into the `.1`-form the applyRule lemmas want. `simp_all`
  cannot do this because the equation is inaccessible-named.

```lean
theorem findApplicableSerialRule_ne_nil                     -- needed only after 2.6
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {rule : TableauRule} {ord' : TimeOrdering} {fs : List SignedFormula}
    (h : findApplicableSerialRule sf b ord = some (rule, RuleResult.persistent fs, ord')) :
    fs ≠ [] := by
  unfold findApplicableSerialRule serialityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil, applyRule] at h
  by_cases hE : ([SignedFormula.pos Syntax.Formula.top.someFuture sf.label,
                  SignedFormula.pos Syntax.Formula.top.somePast sf.label].filter
                    (fun f => !b.contains f)).isEmpty = true
  · simp only [hE, if_pos] at h; simp at h
  · simp only [hE, if_false, Bool.false_eq_true] at h
    simp at h
    obtain ⟨-, hres, -⟩ := h
    rw [← hres]
    simpa using hE
```

`by_cases` rather than `split` here: the guard sits in a `match` *scrutinee*, which `split at h`
does not reach.

### Q2.4 The one remaining link, with its exact residual goal

```lean
theorem expandOnceUnblocked_length_lt
    {b nb : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    b.length < nb.length
```

The straightforward attempt (`unfold`, then the same `split` / `apply_ite Prod.fst` loop, then
`injection h with h; subst h; simp only [List.length_append, Nat.lt_add_left_iff_pos,
List.length_pos_iff]` and the three `exact`s) reduces to **exactly two** goals, both of this shape:

```
heq✝ : (match findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with
        | some sf => findApplicableRule sf b ord fc
        | none => match List.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                                     && (findApplicableSerialRule sf b ord).isSome) b with
                  | some sf => findApplicableSerialRule sf b ord
                  | none => none)
       = some (fst✝, RuleResult.linear a✝, newOrd✝)
h : ExpansionResult.extended (a✝ ++ b) = ExpansionResult.extended nb
⊢ List.length b < List.length nb
```

The hypothesis is about the **two-stage pick as a whole**, so `by assumption` cannot find the
`findApplicableRule …  = some …` the previous lemma wants. The remedy is to destructure the pick
*before* touching `h`, which turns `heq✝` into the single-stage form:

```lean
  unfold expandOnceUnblocked at h
  rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
  · rcases hser : List.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableSerialRule sf b ord).isSome) b with _ | sf2
    · simp [hpick, hser] at h
    · rcases hfa : findApplicableSerialRule sf2 b ord with _ | ⟨r, res, o⟩
      · simp [hpick, hser, hfa] at h
      · cases res <;> simp [hpick, hser, hfa] at h <;>
          [skip; skip; skip; skip]   -- .notApplicable / .linear / .branching / .persistent
        -- the two surviving arms close with
        --   findApplicableSerialRule_ne_nil hfa  (seriality only ever returns .persistent)
  · -- symmetric, with findApplicableRule_extending_ne_nil
```

This is bookkeeping, not mathematics: ~30 lines, no new facts. **Pre-2.6 the seriality branch does
not exist and the proof is roughly half that length** — which is the reason for the sequencing
recommendation in §Q3.

### Q2.5 The lemma the downstream consumer actually needs is *stronger*, and comes free

`buildTableau_isSome` (Phase 4.3, plan:622-628) needs a well-founded progress measure over
`expandBranchWithFuel`. `b.length < nb.length` is **not sufficient on its own**: `List.length` has
no upper bound, since `fs ++ b` may re-add formulas already present, so strict length increase
does not bound the step count. What bounds it is *set* growth against the finite signed closure ×
label set — i.e.

```lean
theorem expandOnceUnblocked_adds_new
    {b nb : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    b ⊆ nb ∧ ∃ g ∈ nb, g ∉ b
```

`b ⊆ nb` is immediate from `nb = fs ++ b` (non-destructive expansion, `Tableau.lean:1723-1726`).
The existential is what the guards already give, in strictly usable form: the non-fresh `.linear`
and `.branching` guards are `fs.all branch.contains = false` and
`bss.any (fun fs => fs.all branch.contains) = false` (`Tableau.lean:1549, 1571`), each of which
yields a **specific** `g ∈ fs` with `g ∉ b` — not merely `fs ≠ []`. For the fresh-label rules the
new formula is the witness at `Branch.nextWorld` / `Branch.nextTime`, which is off-branch by
freshness. So this stronger statement is available from the *same* case analysis at essentially
the same cost, and it is the one Phase 4.3 can actually consume.

**Recommendation**: prove `expandOnceUnblocked_length_lt` as the plan names it — it is cheap once
the chain above exists, it is what the plan's text promises, and it is a useful sanity lemma — but
add `expandOnceUnblocked_adds_new` alongside it and point Phase 4.3 at the latter. Do not
substitute one for the other silently; per `.claude/rules/plan-compliance.md` the addition is
recorded here so the implementer executes it as written rather than re-deriving.

---

## Q3 — Sequencing

**Land 2.6 next. Order is unchanged: 2.8 → 2.5 → 2.6 → 2.7 → 2.4.** Reasons, in order of weight:

1. **The blocker is dissolved, and 2.6 is now the cheapest of the three remaining sub-phases.**
   Step 0 is `git apply --include='FormalSystem/*'
   specs/165_establish_semantic_finite_model_property/2.6-serialityRule-wip.patch`; step 1 is the
   four-line `blockCandidates` change in §Q1.5; step 2 is re-pinning 11 `#guard_msgs` blocks.
   Everything else in the sub-phase is already written and already green.
2. **2.7 depends on 2.6's output.** 2.7's done-criterion is "`timeOrderTotal` holds of every open
   certificate" and "the W1-W7 rows pinned in 2.8 flip" (plan:553-554). Seriality changes which
   times exist on those branches — measured: W1-W4 gain six times each, W5/W6 go from `total=true`
   to `total=false`. Landing 2.7 first would tune `timeLinearity` against a time structure 2.6 then
   replaces, which is precisely the churn the plan's execution order was set to avoid.
3. **2.4's design is *simplified* by 2.6, not complicated by it** — see Contradiction Log C1.
   Deferring 2.4 until after 2.6 was already the plan's decision ("Depends on 2.5 and 2.6",
   plan:575) and remains correct.
4. `expandOnce_length_lt` should be folded into the 2.6 dispatch, **after** the seriality change
   lands, because `findApplicableSerialRule_ne_nil` and the seriality arm of the pick are part of
   the final statement. Proving it now against the pre-2.6 engine means re-proving it after.

---

## Adversarial Self-Verification

Every load-bearing claim was re-derived against source or re-measured in this dispatch. Claims
inherited from report 04 or the handoff were treated as **hostile** and re-tested; three did not
survive.

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| The 2.6 blowup is a per-step cost problem fixable by caching `blockedTimes` (handoff `what_is_needed` (a); plan:527-530) | Measured: `C2 p` consumes all 200 fuel and reaches 68 times. Caching a step cannot bound a non-terminating loop. | **REFUTED** |
| `ancestorTimes ord t = ord.pastOf t` is the only blocking-candidate source | `SignedFormula.lean:782-783`; `Tableau.lean:1649-1655` | **CONFIRMED** (source read) |
| A `somePastPos`-minted time has empty `pastOf`, hence no blocking candidates | Traced: `blocked` = `[1] → [2,1] → [3,2,1] → …`, never containing the newest time; ordering grows `(3,2),(4,3),(5,4),…` | **CONFIRMED** (measured) |
| "Node-level blocking does bound the chain — each new time is blocked within a step or two" (handoff `why_stuck`) | Same trace: the *future* witness (time 1) blocks at step 5; the *past* chain never blocks at any depth. | **REFUTED** (half true: future only) |
| `blockCandidates` fixes it | `lake build …Saturation` 590 s+ → **8.5 s**; `lake build BimodalTest.TableauConformance` 590 s+ → **35 s** | **CONFIRMED** (measured, real `buildTableau`) |
| The fix moves exactly `S1`-`S5`, `K2`-`K6` in all four classes and nothing else | Full corpus diff: 11 `#guard_msgs` mismatches = 4 class tables (those 10 rows only) + 7 `TimeOrderProbe` rows; `CertificateProbe` passes; `A`, `B`, all controls unmoved | **CONFIRMED** (measured) |
| `blockCandidates` alone (seriality off) is verdict-neutral | Reverted the seriality patch, kept `blockCandidates`, rebuilt: `lake build BimodalTest.TableauConformance` exit 0, **zero** `#guard_msgs` mismatches, 32.7 s | **CONFIRMED** (measured) |
| Report 04 §Q3.5: with seriality on, *every* genuinely-open row terminates `OPEN-blocked`, never `OPEN-sat` | `CertificateProbe` reports `fullySaturated=true applied=0 orphans=0` for **both** `◇p` and the genuinely-open `G p → p`, with seriality on (`TableauConformance.lean:679-687`) | **REFUTED** — see C1 |
| Report 04 §Q3.5: the `.Discrete` `K2`/`K3` residual must be chased or documented | `.Discrete` table: `K2`-`K6` all read `CLOSED target=CLOSED` | **REFUTED** — no residual |
| Report 04 §Q3.4: globally-last scheduling hits 24/24 at fuel 200 | Reproduced end to end with the real `saturateBlocked` post-pass in, which the report's prototype lacked; `conformanceFuel = 200` unchanged | **CONFIRMED** |
| `expandOnce` is what Phase 4.3's proof path calls | `Saturation.lean:407` calls `expandOnceUnblockedWithApplied`; `Tableau.lean:1929` delegates to `expandOnceUnblocked`. `expandOnce` has no live proof-path caller | **REFUTED** — see C2 |
| The `expandOnce_length_lt` obstruction is higher-order unification of a `filterMap` helper (handoff, plan:386-388) | Reproduced the 15 residual goals, then dissolved them with `simp only [apply_ite Prod.fst] at h`. Residual obligation is `¬ l.isEmpty = true → l ≠ []`. A hand-written `filterMap` helper was tried and is **not needed**. | **REFUTED** |
| All 8 `ruleMintsFreshLabel` rules return a syntactic cons | `Tableau.lean:485, 530, 590, 630, 661, 705` (`.linear (witness :: …)`); `:762, 807` (`.branching [branch1 ++ …, branch2 ++ …]`, `branch1 = [SignedFormula.pos event freshLabel]`) | **CONFIRMED** (source read) |
| All 14 `.persistent` return sites give `fs ≠ []` | 7 × `if newFormulas.isEmpty` (`:443, 541, 550, 559, 599, 673, 717`), 6 × `[newSf]` (`:1138, 1148, 1165, 1184, 1200, 1220`), 1 × `witness :: gProps` (`:1129`) | **CONFIRMED** (source read) |
| `applyRule_persistent_ne_nil`, `applyRule_fresh_linear_ne_nil`, `applyRule_fresh_branching_ne_nil`, `findApplicableRule_extending_ne_nil`, `findApplicableSerialRule_ne_nil` all compile sorry-free | `lake env lean` on the live tree: no errors, no `sorry` warnings; only `linter.unusedTactic` notes | **CONFIRMED** (compiled) |
| `List.exists_of_findSome?_eq_some` exists in the pinned toolchain | `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/src/lean/Init/Data/List/Find.lean:46` | **CONFIRMED** (source read) |
| `b.length < nb.length` suffices for `buildTableau_isSome` | `nb = fs ++ b` may duplicate formulas, so length is unbounded above and cannot bound the step count | **REFUTED** — see §Q2.5 |
| The committed tree is unchanged at the end of this dispatch | `git hash-object` on both touched files matches the pre-dispatch blobs (`41470eb63…`, `f8aad8c4c…`); `git status --porcelain` shows only the two pre-existing dirty files | **CONFIRMED** |

### Contradiction Log

**C1 — report 04 §Q3.5 (and the plan revision it drove) vs. measurement of the real pipeline.**
Report 04 states that after seriality lands, "no open branch is ever fully saturated in the
`findUnexpanded = none` sense", and the plan's revision item 5 (plan:38-40) consequently changes
Phase 7.1's hypothesis and 2.4's certificate to a **disjunction**
(`findUnexpanded … = none ∨ blocked`, plan:560-562). Measured with 2.6 + the fix in:
`CertificateProbe` reports `fullySaturated=true applied=0 orphans=0 appliedRedundant=true` for
`◇p` **and** for the genuinely-open row `G p → p`.

Resolution, by precedence (measurement of the shipped engine over a prototype measurement):
report 04's prototype made seriality visible to the saturation test; the **as-implemented** design
deliberately keeps `serialityRule` out of `allRulesForFC` (`Tableau.lean` patch, "Seriality is
scheduled, not prioritised"), and `findUnexpanded` reads `findApplicableRule`, which reads
`allRulesForFC`. So `findUnexpanded = none` remains reachable and means "no *ordinary* rule
applies". **The certificate does not have to become a disjunction.**

Two consequences the implementer must carry:
- **2.4 is simpler than the plan says.** Keep the single-conjunct
  `saturated : findUnexpanded openBranch (timeOrd := …) (fc := fc) = none`. The `fc` field repair
  (report 04 §Q1.3) stands unaffected and is still needed.
- **Phase 7.1 gains a fidelity obligation, not a hypothesis change.** `findUnexpanded = none` no
  longer implies "seriality-saturated". The truth lemma reads a branch on which every label may
  still be owed `T(F⊤)`/`T(P⊤)`. This is harmless for a model built over a serial order — the
  omitted formulas are true at every point of any serial frame — but it must be *stated* in the
  truth lemma's preamble rather than assumed. Record it; do not change the certificate to hide it.

**C2 — plan/report naming vs. the call graph.** The plan and report 04 §Q1.4 both name
`expandOnce_length_lt`. The proof path calls `expandOnceUnblocked`. Resolution: source precedence
(`Saturation.lean:407` → `Tableau.lean:1929`). The plan text is corrected in the delta below; the
supporting lemma chain is shared, so this costs nothing.

**C3 — handoff's `what_is_needed` (a) vs. §Q1.4.** The handoff's suspicion that `blockedTimes` is
the inner-loop hotspot is *correct on its own terms* (26 ms/step at `len=81`, dominating both
scans) but is not the cause of the failure and not the fix. Both statements are recorded: the fix
is §Q1.5; the caching lever is retained as a quantified reserve in §Q1.7 row (b). No contradiction
survives — the handoff mis-ranked, it did not mis-measure.

### Recommendations modified after verification

- Direction (b) (memoize `blockedTimes`) was the leading candidate on entry and was **demoted**
  from "the fix" to "a measured reserve" after §Q1.2 showed the step count, not the step cost, is
  what runs away.
- The `filterMap` helper lemma the plan and handoff both call for was **written, compiled, and
  then deleted** — once `apply_ite Prod.fst` opens the guards it has nothing to prove.
- The Phase 7.1 / 2.4 certificate disjunction was **withdrawn** on the strength of
  `CertificateProbe`, and replaced by a narrower Phase 7.1 documentation obligation (C1).

---

## Recommended plan delta

Execute in this order. Nothing below needs re-deriving.

### 1. Sub-phase 2.6 — unblock and land (one dispatch)

1. `git apply --include='FormalSystem/*' specs/165_establish_semantic_finite_model_property/2.6-serialityRule-wip.patch`
   (the `--include` is required: the patch also carries `latex/subfiles/04-Metalogic.log` and
   `specs/events.jsonl` noise hunks).
2. Insert `blockCandidates` and change the one line in `isTemporallyBlockedSaturated` exactly as
   given in **§Q1.5**, docstring included. Location: `Tableau.lean`, immediately before the
   current line 1649.
3. Re-pin the four class-table `#guard_msgs` blocks (`TableauConformance.lean:397, 427, 459, 492`):
   `S1`-`S5` and `K2`-`K6` become `CLOSED target=CLOSED` with the `[DEFECT]` marker removed. Row
   notes stay; they now describe why the rows close rather than why they do not. Consider
   rewording `S1`'s note ("no rule creates the required successor") — `serialityRule` now does.
4. Re-pin the seven `TimeOrderProbe` blocks (`:734, 739, 744, 749, 755, 760, 766`) to their new
   `knownTimes`/`constraints`/`incomparable`/`total` values. Add an in-file note that W5/W6 flip
   `total=true → false` because seriality mints times `timeLinearity` (2.7) does not yet order,
   and that **2.7's done-criterion is now "all seven flip to `total=true`"**, not "W1-W4 flip".
5. Replace the **BLOCKER** block at plan:497-536 with a resolution note recording: the root cause
   (`ancestorTimes` is past-only; the past chain is unblockable), the four-line fix, and the
   before/after table in the Executive summary.
6. Amend the 2.6 checkbox text (plan:479-495) to name `blockCandidates` as part of the sub-phase,
   and record that the `.Discrete` `K2`/`K3` residual **closed** rather than needing documentation.
7. Verification gate: `lake build FormalSystem.Metalogic.Decidability.Saturation` ≤ 15 s with zero
   `FAIL` in the inline suite; `lake build BimodalTest.TableauConformance` ≤ 45 s, exit 0.

### 2. `expandOnce_length_lt` — fold into the same dispatch, after step 1

8. Add, in `Tableau.lean` after `expandOnceNoFresh`, the five lemmas of **§Q2.3** verbatim (they
   compile), then `expandOnceUnblocked_length_lt` via the `rcases`-on-the-pick skeleton of
   **§Q2.4**, plus `expandOnceUnblocked_adds_new` of **§Q2.5**.
9. Correct plan:371-372 and plan:381-389: the lemma is `expandOnceUnblocked_length_lt`, not
   `expandOnce_length_lt` (`expandOnce` has no proof-path caller — `Saturation.lean:407`,
   `Tableau.lean:1929`); the `filterMap` helper is a **refuted** diagnosis, and the actual
   obstruction was `split`'s inability to see through `Prod.fst`. Point Phase 4.3 (plan:622-628)
   at `expandOnceUnblocked_adds_new` as the progress measure, with the length lemma as a corollary.
10. Add `set_option maxHeartbeats 2000000` in scope for the two 36-constructor sweeps (measured
    ~80 s of elaboration for the three `applyRule`-level lemmas — acceptable, but above the
    default budget).

### 3. Sub-phase 2.4 — simplify before it is written

11. Amend plan:555-575: `hasOpen`'s `saturated` field stays a **single conjunct**
    `findUnexpanded openBranch (timeOrd := timeOrdering) (fc := fc) = none`. Delete the
    `∨ (findBlockedTime …).isSome` disjunct. Reason: `CertificateProbe` measures literal full
    saturation reachable on open branches with seriality on, because `serialityRule` is outside
    `allRulesForFC` and therefore outside `findUnexpanded` (Contradiction Log C1). The `fc` field
    repair and the applied-set deletion are unaffected.
12. Amend plan:38-40 (revision item 5) and the Phase 7.1 text: replace the hypothesis change with a
    **documentation obligation** — the truth lemma must state that `findUnexpanded = none` means
    "no ordinary rule applies", so a saturated branch may still be owed `T(F⊤)`/`T(P⊤)` at every
    label; these are true at every point of any serial frame, so the extracted model is unaffected,
    but the gap must be named rather than assumed.

### 4. Phase 3 — one line

13. `serialityRule` gates to `.Base` and is excluded from `allRulesForFC`, as already planned
    (plan:584-588). Add `blockCandidates` to nothing — it is not a rule and does not enter
    `ruleFrameClass` / `mem_allRulesForFC_iff`.

---

## Artifacts

- This report: `specs/165_establish_semantic_finite_model_property/reports/05_seriality-performance-and-length-lemma.md`
- The WIP patch is unchanged and still applies cleanly:
  `specs/165_establish_semantic_finite_model_property/2.6-serialityRule-wip.patch`
- No source file was left modified. Verified by `git hash-object` against the pre-dispatch blobs.
