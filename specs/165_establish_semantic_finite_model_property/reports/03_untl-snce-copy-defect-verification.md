# Verification Report: the `untl`/`snce` unconditional-copy defect

**Mode**: adversarial verification (H4) + divergence audit (H5), read-only
**Session**: `sess_1785337808_19a89c_165v2`
**Scope read**: `FormalSystem/Metalogic/Decidability/**`, `FormalSystem/Semantics/**`,
`Tests/BimodalTest/**`, this task's `specs/` artifacts. No `.lean` file was edited; no build was
run; `FormalSystem/Metalogic/WeakCanonical/**` was not read or touched.

---

## Executive verdict

**DEFECT CONFIRMED — AUTHORIZE deletion of the four `untlNegProps`/`snceNegProps` blocks
(group-3 precedent), but ONLY as the unblock for `untlPos`/`sncePos`. Deletion does NOT unblock
`untlNeg`/`snceNeg`: a second, independent unsoundness sits in their PASSIVE arms.**

Three findings, in decreasing order of how much they change the plan:

1. **The copy is genuinely unsound and the four arms are genuinely unprovable** — confirmed, but
   **the counterexample currently recorded in the tree and in the handoff is WRONG**. Its
   `{1/n}` model does not refute `RuleSound carrierBase .untlPos`, because `SatResult`
   re-chooses `tv` from scratch and branch 2 is satisfiable at any `c ≤ 0`. A repaired
   counterexample over `ℤ` (§1.4) does refute it. The right conclusion was reached from wrong
   evidence; the evidence must be replaced before it is cited again.
2. **NEW: the PASSIVE arms of `untlNeg`/`snceNeg` are also unsound** (§2), contradicting the
   isolation claim in `Decidable.lean:1859-1864` and in the handoff's `isolation` field. The
   Reynolds co-decomposition at an *existing* non-adjacent future time is invalid, and an
   adversarial branch that pins that time's interpretation refutes
   `RuleSound carrierBase .untlNeg` without using the copy blocks at all.
3. `densityRule` and the rest of the frame-class-gated family are **not** blocked by this defect
   — confirmed (§3).

---

## 1. Defect reality

### 1.1 What the code actually does

Four arms emit an unconditional copy of every negative Until/Since sitting at the trigger's time
onto a freshly minted time:

| Arm | Copy block | Emission site |
|-----|-----------|---------------|
| `untlPos` | `Tableau.lean:931-937` (`untlNegProps`) | `:940-941` (`autoProp`, both branches) |
| `sncePos` | `Tableau.lean:976-982` (`snceNegProps`) | `:985-986` |
| `untlNeg` ACTIVE | `Tableau.lean:1035-1041` (`untlNegProps`, `usf != sf`) | `:1044-1049` |
| `snceNeg` ACTIVE | `Tableau.lean:1108-1114` (`snceNegProps`, `ssf != sf`) | `:1117-1122` |

The block's only guards are `usf.label.time == l.time` and a syntactic `branch.contains`
de-duplication. It does **not** guard on world (`usf.label.world` is carried through unchanged),
and it does not guard on anything semantic. `Branch.untlNegFormulas`
(`SignedFormula.lean:430-434`) collects every `.neg` `.untl _ guard` with `guard != Formula.top`
— i.e. genuine Untils, `someFuture` in disguise excluded.

The semantics being copied across (`Semantics/Truth.lean:134-135`):

```
untl φ ψ  at t  ≡  ∃ s, t < s ∧ φ@s ∧ ∀ r, t < r → r < s → ψ@r      (strict witness, open guard)
```

This is interval-relative: `¬U(e,g)@a` constrains the interval `(a, ·)` and says nothing about
`(c, ·)` for `c > a`. There is no shift-closure argument, because — unlike `boxDiamondPersistence`
(`Tableau.lean:434-442`), which relabels `□`/`◇` formulas whose truth is `Ω`-universal and
therefore shift-invariant (`ShiftClosed`, `Truth.lean:333-334`) — the claim is evaluated inside
one history. **Confirmed.**

### 1.2 What "unsound" means here, precisely

`RuleSound` (`Verified/Decidable.lean:344-350`) fixes `D, F, M, Om` and then quantifies over
`hist, tv, b, sf, ord` with `sf ∈ b`, `SatState … b ord` and `OrdWithin b ord`. The obligation is
`SatResult` (`:188-194`), and for `.branching` it reads

```
∃ br ∈ bss, ∃ hist tv, SatState M Om hist tv (br ++ b) ord
```

Two consequences that any counterexample must survive, and which defeated the first refutation
draft (correctly, per the dispatch brief):

* **`tv` is re-chosen wholesale**, not extended. The successor may reinterpret *every* time index,
  including the trigger's. A counterexample may not assume the source time stays where it was.
* **`hist` is re-chosen too**, from `Om`. Since `Om` is fixed by the counterexample's author and
  need only be `ShiftClosed`, this freedom can be reduced to time translation by taking `Om` to be
  the shift orbit of a single total-domain history — see §1.5.

Both the original branch `b` and the emitted arm must be satisfied simultaneously (`br ++ b`), so
`b` can be used to *pin* interpretations. That is the lever the repaired counterexample uses and
the one the recorded counterexample fails to use.

### 1.3 The recorded `{1/n}` counterexample is REFUTED

Recorded at `Verified/Decidable.lean:1841-1857` and in
`.orchestrator-handoff.json` → `blockers[0].counterexample`. Its model: `e'` true exactly on
`{1/n : n ≥ 1}`, `g'` false exactly there, `event` true exactly at `1/2`, `guard` true everywhere,
both signed formulas at `(w, 0)`.

Computing the truth sets in that model:

* `U(e',g')@x` ⟺ `x ∈ (0,1)`. So `¬U(e',g')` holds on **`(-∞,0] ∪ [1,∞)`** — not just at `0`.
* `U(event,guard)@x` ⟺ `x < 1/2`.

The text then asserts "the interpretations of `freshTime` that satisfy either emitted branch are
exactly `(0, 1/2]`". That is only true if `tv(t₀) = 0` is held fixed — which `SatResult` does not
do. Take instead

```
tv'(t₀) = -1,   tv'(freshTime) = -1/2
```

and check branch 2 (`Tableau.lean:911-912` plus the copy) against `br ++ b`:

| Obligation | Value | Holds? |
|---|---|---|
| `ordResp` for `addFuture t₀ fresh` | `-1 < -1/2` | yes |
| `b`: `T(U(event,guard))@t₀` | `U(event,guard)@(-1)`, witness `1/2` | yes |
| `b`: `F(U(e',g'))@t₀` | `¬U(e',g')@(-1)` (`-1 ≤ 0`) | yes |
| `T(guard)@fresh` | guard true everywhere | yes |
| `T(U(event,guard))@fresh` | `-1/2 < 1/2` | yes |
| copied `F(U(e',g'))@fresh` | `¬U(e',g')@(-1/2)` (`-1/2 ≤ 0`) | yes |

Branch 2 is satisfiable, so `SatResult` holds on this input and the model refutes nothing. The
recorded counterexample **fails for exactly the reason the dispatch brief warned about**: the
fresh time is free, and the `¬U(e',g')` region is unbounded below, so both times can be slid into
it together. **Status: REFUTED. The narrative at `Decidable.lean:1841-1857` and the handoff
`counterexample` field must be replaced.**

### 1.4 A repaired counterexample that does refute `RuleSound carrierBase .untlPos`

The fix is to make the region where `b` is satisfiable a **single point that is maximal** in the
`¬U(e',g')` region, so no room is left above it. Discrete time suffices — `RuleSound` quantifies
over all carriers (`Decidable.lean:345`), so a refutation over `ℤ` refutes the statement.

**Carrier and frame.** `D = ℤ`. `F.WorldState = ℤ`, `TaskRel w d u ⟺ u = w + d` (satisfies
`nullity_identity`, `forward_comp` and the converse convention, `TaskFrame.lean:152-182`). `τ` is
the identity history: `domain = univ` (convex), `states t = t`, `respects_task` immediate.
`Om = {WorldHistory.timeShift τ Δ : Δ ∈ ℤ}` — `ShiftClosed` by construction, and every member has
total domain (see §1.5 for why `Set.univ` must NOT be used).

**Valuation** (four atoms; `event = p`, `guard = q`, `e' = r`, `g' = s`):

```
V(n,p) ⟺ n = 5        V(n,q) ⟺ n ≥ 1        V(n,r) ⟺ n ≥ 2        V(n,s) ⟺ n ≠ 1
```

**Derived truth sets** (from `Truth.lean:134-135`):

* `U(p,q)@a` ⟺ `0 ≤ a ≤ 4`. (Sole `p`-witness is `5`; `(a,5)` must avoid `0`, so `a ≥ 0`.)
* `U(r,s)@x` ⟺ `x ≥ 1`. (For `x ≥ 1` take the witness `max(x+1,2)`, empty guard interval. For
  `x ≤ 0` every `r`-witness is `≥ 2 > 1 > x`, so `1 ∈ (x,y)` and `s@1` is false.)

**Branch.** `b = [T(U(p,q))@(w₀,t₀), F(U(r,s))@(w₀,t₀)]` with `t₀ = 0`, `sf` the first,
`ord = TimeOrdering.empty`. `OrdWithin` holds vacuously (`Decidable.lean:318-320`). `SatState`
holds with `tv(0) = 0`: `U(p,q)@0` ✓, `¬U(r,s)@0` ✓, `ordResp` vacuous, `histMem` constant.

**Rule output.** `asUntil?` accepts (guard is an atom, `Tableau.lean:313-317`).
`freshTime = b.nextTime = 1` (`SignedFormula.lean:380`), `newOrd = addFuture 0 1`. `gProps`,
`fNegProps`, `modalProps` are all empty (no `G`, no `F(F·)`, no `□`/`◇` on the branch), and
`untlNegProps = [F(U(r,s))@(w₀,1)]`. So

```
branch1 = [T(p)@(w₀,1), F(U(r,s))@(w₀,1)]
branch2 = [T(q)@(w₀,1), T(U(p,q))@(w₀,1), F(U(r,s))@(w₀,1)]
```

**Both successors are unsatisfiable.** Write `A = tv'(0)`, `C = tv'(1)` in the absolute
coordinates of `hist'(w₀)`. Carrying `b` forces `0 ≤ A ≤ 4` and `A ≤ 0`, hence **`A = 0`**;
`ordResp` on `newOrd` forces `C ≥ 1`.

| Arm | Requires | Conflict |
|---|---|---|
| branch 1 | `p@C` ⟹ `C = 5`; copied `¬U(r,s)@C` ⟹ `C ≤ 0` | contradiction |
| branch 2 | `U(p,q)@C` ⟹ `C ≤ 4`; copied `¬U(r,s)@C` ⟹ `C ≤ 0`; but `C ≥ 1` | contradiction |

A satisfiable branch is mapped to two unsatisfiable ones. **`RuleSound carrierBase .untlPos` is
false.** And the copy is precisely the culprit: delete `untlNegProps` and branch 1 is satisfied by
`A = 0, C = 5` (`p@5` ✓, `ordResp 0 < 5` ✓).

`sncePos` follows by the time-reversal mirror of this model (`snce`'s clause, `Truth.lean:136-137`,
is the exact mirror); the ACTIVE arms carry the same block with the `usf != sf` restriction, which
only requires a second negative Until on the branch alongside the source — the copy block is
otherwise identical.

### 1.5 Rescues attempted, and why each fails

| Attempted rescue | Outcome |
|---|---|
| **Shift-closure**, as for `□`/`◇` | Not available. `ShiftClosed Om` (`Truth.lean:333-334`) makes `□` behave universally across times; `U` is evaluated inside one history (`Truth.lean:134`) and is not `Ω`-universal. `boxDiamondPersistence`'s soundness argument does not transfer. |
| **`hist'` freedom** — pick a different history | Reduced to translation by choosing `Om` = shift orbit of one total-domain history. All constraints in §1.4 are stated between `A` and `C` in one history, and translation preserves `A < C` and all atom relations. |
| **Domain restriction** — pick a history with a bounded domain, killing `r` above `5` and making `¬U(r,s)@5` vacuously true | **This one works if `Om = Set.univ`**, and it is a real trap: with `I = (-∞,5]` branch 1 becomes satisfiable. It is closed by choosing `Om` as the shift orbit of the total-domain identity history — legitimate, since `Om` is fixed by the counterexample's author and only `ShiftClosed` is required. Any future formalization of this counterexample must not use `Set.univ`. |
| **Interval-endpoint bookkeeping** (half-open vs open guard) | No effect. The guard interval is open at both ends (`t < r → r < s`) and the witness strict; the counterexample never places a witness at an endpoint. |
| **An existing guard in the copy block** | None exists. The only guards are `label.time == l.time` and the syntactic `branch.contains` de-dup (`Tableau.lean:933,936`). Note the block does not even guard on world equality. |
| **`branch.contains` de-dup rescuing the case** | No: `F(U(r,s))@(w₀,1)` is not on the branch, so the copy is emitted. |
| **The `timeCount < 4` guard** (`Tableau.lean:1006,1080`) | Applies to the ACTIVE arms only; it bounds fresh-time chains and does not touch the copy's semantics. `untlPos`/`sncePos` have no such guard at all. |

### 1.6 Reachability

Reachability is what upgraded the group-3 defect from curiosity to defect
(`Decidable.lean:1952-1967`), so it is worth being precise about what it does and does not decide
here.

* **For the proof obligation, reachability is irrelevant.** `RuleSound` quantifies over all `b`,
  `sf`, `ord` satisfying `SatState` + `OrdWithin` (`Decidable.lean:344-350`). §1.4 exhibits such a
  triple. The theorem is false and unprovable regardless of what the engine schedules. This is the
  fact that blocks Phase 7, and it needs no probe. **CONFIRMED.**
* **For the engine's verdicts, the copy is reachable by inspection.** The root branch for
  `U(p,q) → U(r,s)` is `F(imp …)@(w₀,0)`; `impNeg` yields `T(U(p,q))@(w₀,0)` and
  `F(U(r,s))@(w₀,0)` at the same time index, which is exactly the branch of §1.4, and expansion is
  additive so nothing removes the negative Until before `untlPos` fires (`untlNeg` is persistent,
  re-including `sf`, `Tableau.lean:1056,1059`). **CONFIRMED by code reading.**
* **Whether that yields a wrong verdict is UNVERIFIABLE-WITHOUT-BUILD.** Emitting a false formula
  onto a branch does not by itself close it. Per the group-3 lesson (`Decidable.lean:1968-1974`),
  the measurement must use `isInvalid` / `getCountermodel?`, never `isValid` alone. That probe is
  named in §5.

---

## 2. NEW FINDING — the PASSIVE arms are also unsound

`Decidable.lean:1859-1864` and the handoff's `isolation` field both assert that the PASSIVE arm
"emits no such block, returns `timeOrd` unchanged, and is sound; it is provable today". **That
claim is refuted.**

**The arm** (`Tableau.lean:1053-1060`, past mirror `:1126-1133`): for the first unprocessed
`t' ∈ timeOrd.futureOf l.time` — a *transitive* closure, not a direct-edge filter
(`SignedFormula.lean:760-777`) — it emits

```
branch1 = [F(event)@t', sf]
branch2 = [F(guard)@t', F(U(event,guard))@t', sf]
```

**The semantic fact it needs is false.** For `a < c`, `¬U(e,g)@a` implies only

```
¬e@c  ∨  ∃ z ∈ (a,c). ¬g@z
```

The guard failure lies strictly *between* `a` and `c`; the arm instead places it *at* `c` and adds
`¬U(e,g)@c`, which is the same interval-relative propagation as the copy defect. Concretely, with
`e` true exactly at `3` and `g` false exactly at `1` over `ℤ`: `¬U(e,g)@0` holds, yet at `c = 3`
both `e@3` and `g@3` are true, so branch 1 and branch 2 both fail. (The same model also shows
branch 2's second conjunct is independently wrong: `¬g@1` holds while `U(e,g)@1` is **true**.)

**A refutation of `RuleSound carrierBase .untlNeg` that uses no copy block.** Same frame and `Om`
as §1.4; atoms `e, g, x` with `V(n,e) ⟺ n = 3`, `V(n,g) ⟺ n ≠ 1`, `V(n,x) ⟺ n = 3`.

```
b   = [ F(U(e,g))@(w₀,0),  T(x)@(w₀,1) ]        sf = F(U(e,g))@(w₀,0)
ord = ⟨[(0,1)]⟩                                  tv(0) = 0,  tv(1) = 3
```

`OrdWithin` holds (both indices occur in `b`, `SignedFormula.lean:349`). `SatState` holds:
`U(e,g)@a ⟺ a ∈ {1,2}`, so `¬U(e,g)@0` ✓; `x@3` ✓; `ordResp 0 < 3` ✓. `futureOf 0 = [1]`, and `1`
is unprocessed (`Tableau.lean:1000-1003`), so the PASSIVE arm fires with `t' = 1` and `ord`
unchanged. In the successor, `b` pins `C = tv'(1) = 3` (the only `x`-point) and forces `A ≤ 0`.
Then branch 1 needs `¬e@3` (false) and branch 2 needs `¬g@3` (false). **Both arms fail;
`RuleSound carrierBase .untlNeg` is false via the PASSIVE arm, independently of the copy.**

The pinning formula `T(x)@t₁` is not exotic: `someFuturePos` on `T(F x)@t₀` produces exactly that
shape with exactly that ordering constraint.

**Unified diagnosis.** Every site that asserts `F(U(e,g))` at a time other than the label it was
derived at is unsound. That is five sites, not four: the four copy blocks, plus
`Tableau.lean:1059` and `:1132` (branch 2 of each PASSIVE arm).

**Calibration.** This is a hand-checked semantic argument against cited definitions, not a
machine-checked refutation. It should be pinned by a Lean probe before it is treated as settled
(§5), exactly as `BoxNegPreservationProbe.lean` pinned the group-3 step.

---

## 3. Blast radius

**Blocked by the copy defect (§1)**: `untlPos`, `sncePos`, and the ACTIVE arms of `untlNeg` /
`snceNeg`. These are the only four consumers of the copy helpers — verified exhaustively:
`untlNegProps` / `snceNegProps` occur at `Tableau.lean:932, 940, 977, 985, 1036, 1044, 1109, 1117`
and nowhere else; `Branch.untlNegFormulas` / `snceNegFormulas` have no other call site in
`Tableau.lean`.

**Additionally blocked by the passive-arm defect (§2)**: `untlNeg`, `snceNeg`. Because `RuleSound`
is stated per rule and each rule owns both arms, these two rules carry **two independent**
obstructions.

**Assembly impact**: `untlPos`, `untlNeg`, `sncePos`, `snceNeg` are all `.Base` rules
(`Verified/RuleSpec.lean:177-178, 269`), so they are members of `allRulesForFC` at *every* frame
class. The assembly `∀ r ∈ allRulesForFC fc, RuleSound _ r` is unreachable at every frame class
until both defects are repaired. 23 of 36 rules are proved
(`Decidable.lean`, `theorem ruleSound_*`); no `sorry` appears in the file.

**NOT blocked — the frame-class-gated family, `densityRule` first: CONFIRMED.** `densityRule`
(`Tableau.lean:1261-1308`) emits `(.persistent (witness :: gProps), newOrd)`. Its propagation
family is `T(G A) → T(A)` at the interpolant only — a universal that *is* preserved forward, since
`t < freshTime` — plus its own `T(ψ)` witness. It contains no `untlNegProps`/`snceNegProps` block
(confirmed by the exhaustive grep above) and it does not call the copy helpers. Its outstanding
obligation is the Dense carrier property for `ordResp` on the doubled `addFuture`
(`Tableau.lean:1296`), which is orthogonal. The same holds for `priorUZ`/`priorSZ`
(`:1101-1118`, pure `.persistent` same-label additions) and `z1Rule` (`:1120-1136`, same-label).
`denseIndicatorClosure` is already proved (`Decidable.lean:1817`).

---

## 4. Fix shape

### 4.1 For `untlPos` / `sncePos` — deletion, group-3 precedent. **Authorize.**

Delete `untlNegProps` (`Tableau.lean:931-937`) and `snceNegProps` (`:976-982`) and drop them from
the `autoProp` concatenations at `:940` and `:985`. After deletion the remaining families are
`gProps` (`T(G A)@t → T(A)@fresh`, sound since `t < fresh`), `fNegProps`
(`F(F A)@t → F(A)@fresh`, sound in the same direction) and `modalProps` (the `□`/`◇` relabelling,
whose soundness is already discharged for the four landed fresh-time existentials). Branch 1 is
then satisfied by interpreting `freshTime` as the Until's own witness, and the rules become
provable by the shape the four fresh-time existentials already established. This matches the
handoff's `required_behaviour` and the precedent recorded at `Decidable.lean:1887-1894`.

The same two blocks must also be deleted from the ACTIVE arms (`:1035-1041`, `:1108-1114`), but
see §4.2 — that does not by itself unblock those two rules.

**Guarded-copy alternative — rejected.** For the copy to be sound one needs
`¬U(e',g')@A → ¬U(e',g')@C` for the freshly chosen `C > A`, which holds only when no `e'`-witness
survives above `C` with an unbroken guard — a semantic condition on the model, not on the branch.
No syntactic guard computable from `(branch, ord)` expresses it. Deletion is the minimal sound
change.

**Under-closing risk**: deletion can only make branches *harder* to close, so the risk is
STALLED/OPEN where CLOSED is expected — precisely the direction the conformance corpus measures
(§5).

### 4.2 For `untlNeg` / `snceNeg` — deletion is necessary but NOT sufficient. **Do not authorize a
"delete and prove" phase for these two.**

Deleting the ACTIVE-arm copies leaves the PASSIVE-arm defect (§2) intact, and `RuleSound` is per
rule. Candidate repairs, none of them mechanical:

1. **Interpolating co-decomposition** (the semantically correct rule). Replace branch 2 with:
   mint `z` fresh, `newOrd = (ord.addFuture t z).addFuture z t'`, emit `[F(guard)@z, sf]`. This is
   the true disjunction `¬e@t' ∨ ∃z ∈ (t,t'). ¬g@z`. It converts the PASSIVE arm into a
   fresh-time producer, which brings termination and blocking consequences of exactly the kind
   `densityRule`'s gap-selection comment documents at `Tableau.lean:1262-1285` — that rule already
   diverged once for this reason. Completeness must be re-argued, not assumed.
2. **Reuse-before-mint variant**: branch over the existing times in `(t,t')` with `F(guard)@z`,
   minting only when none exists. Cheaper on termination, but the branching factor grows with the
   ordering and the soundness argument still needs the mint case.
3. **Weaken `RuleSound`** with an adjacency/interval invariant ("no `D`-time strictly between
   ord-adjacent tableau times"). This is not an invariant of the construction — `tv` is arbitrary
   and nothing forces it — so it would have to be *added* to `SatState` and re-established by
   every rule. Recorded for completeness; not recommended.

**Recommendation**: authorize §4.1 now as its own phase (it is small, precedented, and gated), and
spawn a separate design task for `untlNeg`/`snceNeg` that begins by *pinning §2 with a probe*
before choosing among 1-3. Do not fold the two together.

---

## 5. Conformance corpus coverage, and the probes needed first

`Tests/BimodalTest/TableauConformance.lean` — 843 lines, 29 `#guard_msgs` blocks. Rows exercising
Until/Since: `BX10 U->F` (`:302`), `BX10' S->P` (`:304`), the two BX11 linearity rows (`:307-312`),
`Z1 priorUZ` / `Z2 priorSZ` (`:337-339`), and the two Dedekind gap rows (`:360-363`).

**Every one of those rows targets `CLOSED`** — they are valid formulas expected to close. This
means:

* **The corpus DOES gate the under-closing direction** that deletion risks. If deleting the copies
  breaks closure of `U(p,q) → F(p)` or the BX11 rows, the corpus catches it. Deletion is therefore
  adequately gated as an acceptance test, and §4.1 can proceed on the existing corpus.
* **The corpus does NOT cover the over-closing direction for Until/Since.** No row asserts that an
  *invalid* Until formula fails to close. So the corpus cannot currently distinguish "the copy is
  unsound" from "the copy is harmless in practice", and it would not have caught the defect.

**New probe rows needed (before, or alongside, the fix):**

1. **Verdict row — invalid Until.** Add `U(p,q) → U(r,s)` (satisfiable-branch shape of §1.4) with
   the expectation that it is **not** valid, asserted via `isInvalid` / `getCountermodel?` and
   **never** via `isValid` alone (`Decidable.lean:1968-1974` is explicit that `isValid = false`
   conflates "judged invalid" with `extractionFailed`).
2. **Step probe — `UntlPosPreservationProbe.lean`**, modelled on `BoxNegPreservationProbe.lean`:
   apply `applyRule .untlPos` directly to `[T(U(p,q))@(w₀,t₀), F(U(r,s))@(w₀,t₀)]` and pin that the
   emitted `autoProp` contains `F(U(r,s))@(w₀,freshTime)`. This pins the *step*, which is what §1.4
   argues about, and is cheap.
3. **Step probe — `UntlNegPassiveProbe.lean`** for §2: apply `applyRule .untlNeg` to
   `[F(U(e,g))@(w₀,0), T(x)@(w₀,1)]` with `ord = ⟨[(0,1)]⟩` and pin that the PASSIVE arm fires with
   `t' = 1` and emits `[F(e)@(w₀,1), sf]` / `[F(g)@(w₀,1), F(U(e,g))@(w₀,1), sf]`. This is the
   measurement that converts §2 from a hand argument into a fact.
4. **Optional, highest value**: formalize the §1.4 countermodel as a Lean theorem
   `¬ RuleSound carrierBase .untlPos`, in the style of the existing
   `addFuture_nextTime_cycle_unsatisfiable` (`Decidable.lean:253`). The project already proves
   negative results this way, and it would prevent a third wrong counterexample from being
   recorded.

---

## Adversarial Self-Verification

Every load-bearing claim below was cross-checked against at least two sources (the rule code and
the semantics/obligation definitions); no claim rests on a single read.

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Verdict | Confidence |
|---|---|---|---|---|
| The four arms copy `F(U(e',g'))` unconditionally across times | `Tableau.lean:931-937, 976-982, 1035-1041, 1108-1114`; guards are only `label.time == l.time` + `branch.contains` | Exhaustive grep for `untlNegProps\|snceNegProps\|untlNegFormulas\|snceNegFormulas` over `Tableau.lean` (8 hits, 4 arms) + direct read | CONFIRMED | High |
| Until is interval-relative; no shift-closure argument exists | `Truth.lean:134-135` (strict witness, open guard, single history) vs `ShiftClosed` at `:333-334` and `boxDiamondPersistence` at `Tableau.lean:434-442` | Definition read + contrast with the `□`/`◇` argument | CONFIRMED | High |
| `SatResult` re-chooses `hist` AND `tv` wholesale, not as an extension | `Decidable.lean:188-194` (`∃ hist tv, SatState … (br ++ b) ord`) | Definition read | CONFIRMED | High |
| **The recorded `{1/n}` counterexample does not refute `RuleSound .untlPos`** | Witness: `tv'(t₀) = -1`, `tv'(fresh) = -1/2` satisfies branch 2 ++ `b`; `¬U(e',g')` holds on all of `(-∞,0]`, not only at `0` | Recomputed both truth sets from `Truth.lean:134`; checked all six obligations of branch 2 (table in §1.3) | **REFUTED** (the claim, not the defect) | High |
| The defect is nonetheless real: `RuleSound carrierBase .untlPos` is false | §1.4 model over `ℤ`: `p@{5}`, `q@[1,∞)`, `r@[2,∞)`, `s@ℤ∖{1}`; `b` forces `A = 0`, `ordResp` forces `C ≥ 1`, both arms need `C ≤ 0` | Truth sets recomputed from `Truth.lean:134`; rule output recomputed from `Tableau.lean:902-941`; `nextTime` from `SignedFormula.lean:380`; `OrdWithin` from `Decidable.lean:279-280, 318-320`; frame constructibility from `TaskFrame.lean:152-182` | CONFIRMED (hand-checked) | High |
| Deleting the copy repairs that counterexample | Without `untlNegProps`, branch 1 is satisfied by `A = 0, C = 5` | Direct recheck of branch 1's obligations | CONFIRMED | High |
| Domain-restricted histories would rescue branch 1 if `Om = Set.univ` | With `I = (-∞,5]`, `¬U(r,s)@5` holds vacuously; closed by taking `Om` = shift orbit of a total-domain history | Adversarial self-attack on §1.4; `ShiftClosed` at `Truth.lean:333`; convexity/domain semantics at `WorldHistory.lean` header and `Truth.lean:130` | CONFIRMED (constraint on the fix, recorded) | High |
| **The PASSIVE arms are ALSO unsound** — contradicts `Decidable.lean:1859-1864` | §2 model: `e@{3}`, `g@ℤ∖{1}`, `x@{3}`; `b` pins `C = 3`, both arms need `¬e@3` or `¬g@3`, both false | Arm code `Tableau.lean:1053-1060`; `futureOf` transitivity `SignedFormula.lean:760-777`; `unprocessed` filter `Tableau.lean:1000-1003`; `OrdWithin` recheck | CONFIRMED (hand-checked); **machine confirmation pending — see §5 probe 3** | Medium-High |
| Reachability of the copy in the engine | Root `F(U(p,q) → U(r,s))` → `impNeg` → both formulas at time `0`; additive expansion (`Decidable.lean:1958-1961`) keeps the negative Until | Code reading only | CONFIRMED for the step | High |
| The copy produces a wrong *verdict* on a concrete formula | Would require running `buildTableau`/`decide` | Not performed (read-only constraint) | UNVERIFIABLE-WITHOUT-BUILD | — |
| Reachability is irrelevant to the *proof obligation* | `RuleSound` quantifies over all `b, sf, ord` with `SatState` + `OrdWithin` (`Decidable.lean:344-350`) | Definition read | CONFIRMED | High |
| `densityRule` is NOT blocked by this defect | `Tableau.lean:1261-1308` emits `(.persistent (witness :: gProps), newOrd)`; no copy block; `G`-universals are preserved forward | Exhaustive grep (no `untlNegProps` outside the four arms) + full read of the rule body | CONFIRMED | High |
| `untl*`/`snce*` are `.Base` and hence in `allRulesForFC` at every frame class | `Verified/RuleSpec.lean:177-178, 269` | Direct read | CONFIRMED | High |
| 23 of 36 rules proved, no `sorry` in `Decidable.lean` | `grep -c '^theorem ruleSound_'` = 23; `grep sorry` = empty | Grep | CONFIRMED | High |
| Conformance corpus has 29 `#guard_msgs`, and every Until/Since row targets `CLOSED` | `TableauConformance.lean:302, 304, 307-312, 337-339, 360-363`; 843 lines | Grep + row inspection | CONFIRMED (the brief said 27 rows; the file has 29 blocks) | High |
| No corpus row pins the over-closing direction for Until/Since | No `OPEN`/countermodel target among the U/S rows | Grep over row targets | CONFIRMED | Medium-High (grep-based; a full row-by-row read was not performed) |

### Contradiction Log

**Contradiction 1 — RESOLVED.** The tree (`Decidable.lean:1841-1857`) and the handoff assert a
`{1/n}` counterexample; this report finds it satisfiable on branch 2. Precedence ranking: an
explicit satisfying assignment checked against the primary definitions (`Truth.lean:134`,
`Decidable.lean:188-194`) outranks a prose argument that implicitly holds `tv(t₀)` fixed where the
definition re-quantifies it. Resolution: the recorded counterexample is wrong; the conclusion it
was offered for is nevertheless right, on the replacement evidence in §1.4.

**Contradiction 2 — RESOLVED AGAINST THE TREE.** `Decidable.lean:1859-1864` and the handoff's
`isolation` field assert the PASSIVE arm "is sound; it is provable today". §2 exhibits a
counterexample. Precedence: an explicit refuting instance outranks an unproved soundness assertion
— and note the assertion was never tested, since `untlNeg` owns both arms and so was never
attempted. Residual risk: the refutation is hand-checked. Resolving check not yet performed:
probe 3 of §5 (`UntlNegPassiveProbe`), or a Lean proof of `¬ RuleSound carrierBase .untlNeg`.

**Contradiction 3 — RESOLVED (bookkeeping).** The dispatch brief and the handoff say "27-row
conformance corpus"; the file contains 29 `#guard_msgs` blocks. Not load-bearing for any verdict;
recorded so the acceptance gate is described accurately.

### Recommendations modified after verification

* The pre-verification expectation "delete the four copies, then all four rules become provable"
  is **narrowed** to `untlPos`/`sncePos` only (§4.2).
* "Confirm the passive arms are not implicated" (brief item 4) is **inverted**: they are
  implicated, by a separate defect.
* A constraint on any future formalization was added that did not exist before: the countermodel
  must fix `Om` to a shift orbit of total-domain histories, never `Set.univ`, or the
  domain-restriction escape reopens it (§1.5).

---

## Final verdict

**DEFECT CONFIRMED + AUTHORIZE: deletion of the `untlNegProps` / `snceNegProps` blocks from all
four arms (`Tableau.lean:931-937, 976-982, 1035-1041, 1108-1114`, with the corresponding
`autoProp` concatenations at `:940, :985, :1044, :1117`), gated on the existing conformance
corpus, scoped as the unblock for `untlPos` and `sncePos` only.**

With three binding conditions:

1. **Replace the evidence.** The `{1/n}` counterexample at `Decidable.lean:1841-1857` and in the
   handoff's `blockers[0].counterexample` is refuted (§1.3) and must be replaced by §1.4 before it
   is cited again. It is currently a false statement sitting in the source tree.
2. **Do not scope `untlNeg`/`snceNeg` into this fix.** They carry a second, independent
   unsoundness in their PASSIVE arms (§2). Deletion leaves them unprovable. They need a design
   dispatch that starts by pinning §2 with a probe and then chooses among the three repairs in
   §4.2.
3. **Add the over-closing probes** of §5 (at minimum items 2 and 3, the two step probes). The
   existing corpus gates the under-closing direction that deletion risks, which is why deletion
   may proceed on it — but it would not have caught this defect, and it will not catch the next
   one of the same family.

**Status of the one claim this report could not settle**: whether the reachable copy produces a
wrong verdict on a concrete formula is UNVERIFIABLE-WITHOUT-BUILD under this dispatch's read-only
constraint. It does not affect the authorization — the proof obligation is refuted independently
of reachability (§1.6) — but it is the measurement a future dispatch should run if the engine's
answers, rather than its provability, are the question.
