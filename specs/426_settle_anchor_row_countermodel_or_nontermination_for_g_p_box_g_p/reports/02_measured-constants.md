# Measured constants for the anchor row `(G p) → □(G p)`

Every figure below was produced in this implementation session by `lake env lean` on a scratch
file against the working tree at `3ff158bad`, not read off a docstring or the prior report. The
scratch sources are reproduced verbatim in §7 so each number can be re-derived.

**Bottom line**: every value the research report asserted reproduces exactly. Hypothesis **(a) —
budget, already satisfied** is confirmed for the anchor formula; the fuel ceiling is **25**;
`decide φ = .invalid` with `getCountermodel?.isSome = true`. Phases 2-4 are cleared to proceed.

Throughout, `p : Formula := .atom (Atom.mkBase "p")`, `gp := Formula.allFuture p`,
`φ := gp.imp gp.box`, `ψ := Formula.someFuture gp` (`= F (G p)`), frame class `.Base`.

## 1. Verdict on the anchor formula φ = `(G p) → □(G p)`

| Probe | Measured | Research asserted | Agree |
|---|---|---|---|
| `(d.isValid, d.isInvalid, d.isFuelExhausted, d.isExtractionFailed, d.isUndecided)` where `d = decide φ` | `(false, true, false, false, false)` | same | yes |
| `(decide φ).getCountermodel?.isSome` | `true` | `true` | yes |
| `(subformulaClosure φ).card` | `8` | `8` | yes |
| `soundFuel φ` | `2048` | `2048` | yes |

Command: §7.1 (`M1.lean`).

## 2. The fuel ceiling, bracketed from both sides

`buildTableau φ n .Base` evaluated at every `n ∈ [0, 40]` and at `45, 50, 60, 80, 100, 200, 400,
1000` (§7.2, `M2.lean`):

| `n` range | Result |
|---|---|
| `0 … 24` (25 values, all tested) | `none` |
| `25 … 40, 45, 50, 60, 80, 100, 200, 400, 1000` | `hasOpen` with open-branch length **40** at every value |

* **Largest `n` returning `none`: 24.**
* **Smallest `n` returning `.hasOpen`: 25.**
* The open-branch length is **stationary at 40** across every tested `n ≥ 25`, out to 1000.

So the ceiling is **25**, bracketed from both sides rather than merely observed from above.

## 3. Attributing the sub-ceiling `none` to a specific stage

`buildTableau` can return `none` by three distinct routes: fuel exhaustion inside
`expandBranchWithFuel`, that function's `branchesUsed >= maxBranches` guard, and the
"still not saturated after the post-blocking pass" arm (`Saturation.lean:1182`). Splitting the
stages by hand (§7.3, `M3.lean`) — calling `expandBranchWithFuel ib n TimeOrdering.empty .Base`
directly on `ib = [SignedFormula.neg φ Label.initial]`, then `findUnexpanded` on its `.inr`
payload:

| fuel | `expandBranchWithFuel` | `findUnexpanded` on its output |
|---|---|---|
| 1, 5, 10, 15, 20, 22, 23, 24 | `none` | — |
| 25, 26, 30, 50, 100, 1000 | open, `\|b\| = 37` | `some _` (not yet saturated) |

Two facts follow, and they are the ones Phases 2 and 4 rest on:

1. **The sub-25 `none` is genuine fuel exhaustion inside `expandBranchWithFuel`**, not the
   unsaturated arm — the inner loop never returns at all below 25.
2. It is also not the `maxBranches` arm. Re-running the inner loop at `n ∈ {20, 23, 24, 25}` with
   `maxBranches := 1000000000` (20 000× the 50 000 default) leaves the answers unchanged —
   `none, none, none, open |b|=37` (§7.4, `M4.lean`). The only budget that moves the outcome is
   fuel.
3. At and above 25 the inner loop hands back a 37-formula branch that is blocked but **not**
   saturated; `buildTableau`'s `saturateBlocked` post-pass carries it to the certified
   40-formula branch. The `.hasOpen` constructor's fourth field is
   `findUnexpanded openBranch … = none` (`Saturation.lean:75`), so the reported refutation is
   proof-carrying, not a give-up.

## 4. Headroom against the proved bounds

With `|subformulaClosure φ| = 8` (measured, §1):

| Figure | Value for this φ | Ratio to the measured 25 |
|---|---|---|
| measured ceiling | 25 | 1× |
| `soundFuel φ` (`Saturation.lean:1210`, capped runtime default) | 2 048 | ~82× |
| `soundFuel' φ` (`Fuel.lean:155`, uncapped single-world figure) | 1 048 576 | ~4.2×10⁴ |
| `worldFuel' φ 1` (`Fuel.lean:2616`, general figure) | 1 099 512 676 352 (≈1.1×10¹²) | ~4.4×10¹⁰ |

All four figures were measured, not computed by hand: `soundFuel φ` in §1, and `soundFuel' φ` /
`worldFuel' φ 1` by `#eval` in §7.8 (`M8.lean`). They agree with the closed forms
`soundFuel' φ = 2 * 8 * 2^16` and `worldFuel' φ 1 = (1 + soundFuel' φ) * soundFuel' φ` on the
measured closure card of 8. Nothing in `Fuel.lean` is falsified or even stressed by this
formula — there is no bound to repair and no figure to raise.

## 5. The non-terminating neighbour ψ = `F (G p)`

`buildTableau ψ n .Base` (§7.5, `M5.lean`):

| fuel | 10 | 25 | 50 | 100 | 200 | 500 | 1000 | 2048 | 4096 |
|---|---|---|---|---|---|---|---|---|---|
| result | none | none | none | none | none | none | none | none | none |

`decide ψ` = `(false, false, true, false, true)` — `.fuelExhausted`, `isUndecided`,
`getCountermodel?.isSome = false`.

But the stage split (§7.6-7.7, `M6.lean`/`M7.lean`) shows the `none` is **not** fuel exhaustion:

| fuel | 10 | 25 | 50 | 100 | 200 | 500 | 1000 | 2048 | 4096 |
|---|---|---|---|---|---|---|---|---|---|
| `expandBranchWithFuel` | none | open `\|b\|=21` | 21 | 21 | 21 | 21 | 21 | 21 | 21 |
| `findUnexpanded` on it | — | `some _` | `some _` | `some _` | `some _` | `some _` | `some _` | `some _` | `some _` |

The inner loop succeeds at every fuel from 25 upward and returns the **same 21-formula branch**.
The branch is stationary; raising fuel provably cannot change it. `buildTableau` then falls into
its last arm and returns `none`.

The residue, read off directly at fuel 25, 100 and 4096 (identical at all three):

* **before** `saturateBlocked`: `findUnexpanded` points at the signed formula
  `neg (imp (untl ⊤ (imp p ⊥)) ⊥)` at `{world := 0, time := 4}` — i.e. `F(G p) @ (0,4)`;
* **after** `saturateBlocked` (branch grown 21 → 25): it points at
  `pos (untl ⊤ (imp p ⊥))` at `{world := 0, time := 4}` — i.e. `T(F ¬p) @ (0,4)`.

That is an unfulfilled eventuality at a **blocked** time. Blocking has stopped the engine minting
new times while `untlPos` remains applicable, so the `findUnexpanded … = none` certificate can
never be produced at any fuel. This is hypothesis (b), realised — on `F(G p)`, not on the anchor
formula.

Note the constructor misattribution this exposes, recorded for a follow-up and **not** worked
here: `DecisionProcedure.lean:194` maps every `buildTableau = none` to `.fuelExhausted`, so on
`F(G p)` the reported constructor says fuel was exhausted when §5's table shows none was.

## 6. Rows A and C — the inputs Phase 3 needs

Measured (§7.7, `M7.lean`), `.Base`, tuple shape as in §1:

| Row | Formula | tuple | `getCountermodel?.isSome` |
|---|---|---|---|
| A | `(¬F p) → □(¬F p)` | `(false, true, false, false, false)` | `true` |
| C | `(¬P p) → □(¬P p)` | `(false, true, false, false, false)` | `true` |

Both decide `.invalid` with a countermodel, matching the research. Both are currently pinned in
`CrossWorldPropagationProbe.lean` only through `isValid`, which reads `false` under `.invalid`,
`.fuelExhausted` and `.extractionFailed` alike — the blindness Phase 3 closes.

## 7. Reproduction sources

Each file is run with `lake env lean <file>`; no `lake build` is required while the `.olean` tree
is current. Every file opens with:

```lean
import FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax FormalSystem.Metalogic.Decidability
def p : Formula := .atom (Atom.mkBase "p")
def gp : Formula := Formula.allFuture p
def phi : Formula := gp.imp gp.box
def psi : Formula := Formula.someFuture gp
```

### 7.1 `M1.lean` — verdict, countermodel, closure size

```lean
#eval let d := decide phi
      (d.isValid, d.isInvalid, d.isFuelExhausted, d.isExtractionFailed, d.isUndecided)
#eval (decide phi).getCountermodel?.isSome
#eval (FormalSystem.Syntax.subformulaClosure phi).card
#eval soundFuel phi
```

Output: `(false, true, false, false, false)` / `true` / `8` / `2048`.

### 7.2 `M2.lean` — ceiling bracket

```lean
def probe (f : Formula) (n : Nat) : String :=
  match buildTableau f n .Base with
  | none => "none"
  | some (.allClosed bs) => s!"closed {bs.length}"
  | some (.hasOpen ob _ _ _) => s!"hasOpen {ob.length}"

#eval (List.range 41 ++ [45, 50, 60, 80, 100, 200, 400, 1000]).map (fun n => (n, probe phi n))
```

### 7.3 `M3.lean` — two-stage split on φ

```lean
def stage (f : Formula) (n : Nat) : String :=
  let ib : Branch := [SignedFormula.neg f Label.initial]
  match expandBranchWithFuel ib n TimeOrdering.empty .Base with
  | none => "inner: none (fuel exhausted in expandBranchWithFuel)"
  | some (.inl _) => "inner: closed"
  | some (.inr (ob, ord, _)) =>
      match findUnexpanded ob (timeOrd := ord) (fc := .Base) with
      | none => s!"inner: open |b|={ob.length}, findUnexpanded = none (SATURATED)"
      | some _ => s!"inner: open |b|={ob.length}, findUnexpanded = some _ (not saturated)"

#eval [1,5,10,15,20,22,23,24,25,26,30,50,100,1000].map (fun n => (n, stage phi n))
```

### 7.4 `M4.lean` — excluding the `maxBranches` arm

```lean
def innerBigBudget (f : Formula) (n : Nat) : String :=
  let ib : Branch := [SignedFormula.neg f Label.initial]
  match expandBranchWithFuel ib n TimeOrdering.empty .Base
          (maxBranches := 1000000000) with
  | none => "none"
  | some (.inl _) => "closed"
  | some (.inr (ob, _, _)) => s!"open |b|={ob.length}"

#eval [20, 23, 24, 25].map (fun n => (n, innerBigBudget phi n))
```

Output: `[(20, "none"), (23, "none"), (24, "none"), (25, "open |b|=37")]`.

### 7.5 `M5.lean` — `F (G p)` under `buildTableau`

```lean
#eval [10,25,50,100,200,500,1000,2048,4096].map (fun n => (n, probe psi n))
#eval let d := decide psi
      (d.isValid, d.isInvalid, d.isFuelExhausted, d.isExtractionFailed, d.isUndecided)
#eval (decide psi).getCountermodel?.isSome
```

### 7.6 `M6.lean` — the residue's identity, before and after `saturateBlocked`

```lean
def stage2 (f : Formula) (n : Nat) : String :=
  let ib : Branch := [SignedFormula.neg f Label.initial]
  match expandBranchWithFuel ib n TimeOrdering.empty .Base with
  | none => "inner none"
  | some (.inl _) => "inner closed"
  | some (.inr (ob, ord, _)) =>
      let pre := match findUnexpanded ob (timeOrd := ord) (fc := .Base) with
                 | none => "none" | some sf => s!"some {repr sf}"
      let post := match saturateBlocked ob n ord .Base with
                  | none => "sat: none"
                  | some (.inl _) => "sat: closed"
                  | some (.inr (sb, so)) =>
                      let r := match findUnexpanded sb (timeOrd := so) (fc := .Base) with
                               | none => "none (SATURATED)"
                               | some sf => s!"some {repr sf}"
                      s!"sat |b|={sb.length}, findUnexpanded = {r}"
      s!"inner open |b|={ob.length}; pre-post-pass findUnexpanded = {pre}; {post}"

#eval [25, 100, 4096].map (fun n => (n, stage2 psi n))
```

### 7.7 `M7.lean` — `F (G p)` stationarity, and rows A and C

```lean
def innerLen (f : Formula) (n : Nat) : String :=
  let ib : Branch := [SignedFormula.neg f Label.initial]
  match expandBranchWithFuel ib n TimeOrdering.empty .Base with
  | none => "none"
  | some (.inl _) => "closed"
  | some (.inr (ob, ord, _)) =>
      let sat := match findUnexpanded ob (timeOrd := ord) (fc := .Base) with
                 | none => "none" | some _ => "some"
      s!"|b|={ob.length}, fU={sat}"

#eval [10,25,50,100,200,500,1000,2048,4096].map (fun n => (n, innerLen psi n))

def rowA : Formula := (Formula.someFuture p).neg.imp ((Formula.someFuture p).neg.box)
def rowC : Formula := (Formula.somePast p).neg.imp ((Formula.somePast p).neg.box)

#eval let d := decide rowA
      ((d.isValid, d.isInvalid, d.isFuelExhausted, d.isExtractionFailed, d.isUndecided),
       d.getCountermodel?.isSome)
#eval let d := decide rowC
      ((d.isValid, d.isInvalid, d.isFuelExhausted, d.isExtractionFailed, d.isUndecided),
       d.getCountermodel?.isSome)
```

### 7.8 `M8.lean` — the proved figures at this φ

```lean
import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel
#eval soundFuel' phi      -- 1048576
#eval worldFuel' phi 1    -- 1099512676352
```

## 8. Divergences from the research report

**None.** Every asserted value reproduced. Phases 2-4 may proceed on these numbers.
