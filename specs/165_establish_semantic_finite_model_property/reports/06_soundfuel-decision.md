# `soundFuel'` — Plan-Level Decision (T3 general fuel figure)

- **Task**: 165 (`establish_semantic_finite_model_property`), Phase 4 sub-phase 4.3
- **Type**: lean4, hard mode (H2/H3/H4 contracts active; H5 not triggered)
- **Session**: `sess_1785244791_96fa7d`
- **Date**: 2026-07-28
- **Blocker adjudicated**: "`soundFuel'` is not the general fuel figure" (plan FINDING, 2026-07-28f)
- **Files read (read-only, no `.lean` file modified)**:
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` (1344 lines)
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/TimeTypeBound.lean`
  - `FormalSystem/Metalogic/Decidability/Saturation.lean` (`:585-692`, `:928-990`)
  - `FormalSystem/Metalogic/Decidability/Tableau.lean` (`:1119-1161`, `:1347-1356`)
  - `FormalSystem/Syntax/SubformulaClosure/Closure.lean`
  - `specs/165_.../plans/01_tableau-decidability-two-track.md` (Phase 4, `:955-1280`)

---

## Decision (one line)

**Adopt (b) + (c) in combination, *without* a rename**: keep `soundFuel'`'s name and definition
frozen and re-document it as the explicitly **single-world / label-count** figure; introduce a new
named general figure `worldFuel'` whose value is *exactly* `chain_le_worlds_bounded`'s right-hand
side; restate 4.3's "Done when" against `worldFuel'` and the quantified branch budget. Option (a)
(redefine `soundFuel'`) is rejected; the rename half of (b) is rejected; (c) alone is rejected as
insufficient.

---

## Reference Grounding (H3, Tier 3 — implementation-backed)

The reference here is this repository's own landed Lean source, not a paper. Every claim below is
grounded in a specific declaration.

| Source | Location | Lean Identifier | Type Signature (as landed) | Status |
|--------|----------|-----------------|-----------------------------|--------|
| Fuel.lean | `:136-138` | `soundFuel'` | `(φ : Formula) : Nat`, body `let n := (subformulaClosure φ).card; 2 * n * 2 ^ (2 * n)` | VERIFIED (read) |
| Fuel.lean | `:145` | `soundFuel_le_soundFuel'` | `(φ : Formula) : soundFuel φ ≤ soundFuel' φ` | VERIFIED (read) |
| Fuel.lean | `:454-462` | `chain_le_stock` | `… (hl : ∀ x ∈ run n, x.label ∈ L) … : n ≤ 2 * C.card * L.card` | VERIFIED (read) |
| Fuel.lean | `:1193-1203` | `chain_le_soundFuel'` | `… (hL : L.card ≤ 2 ^ (2 * C.card)) (hφ : C.card = (subformulaClosure φ).card) : n ≤ soundFuel' φ` | VERIFIED (read) |
| Fuel.lean | `:1020-1022` | `worldFinset_card_le` | `(h : WorldWitness C S b) : b.worldFinset.card ≤ S.card + 2 * C.card * b.timeFinset.card` | VERIFIED (read) |
| Fuel.lean | `:1004-1009` | `WorldWitness` | `(C : Finset Formula) (S : Finset WorldIndex) (b : Branch) : Prop` — **invariant, not theorem** | VERIFIED (read) |
| Fuel.lean | `:1059-1076` | `chain_le_worlds_bounded` | `… (hww : WorldWitness C S (run n)) : n ≤ 2 * C.card * ((S.card + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card))` | VERIFIED (read) |
| Fuel.lean | `:1252-1258` | `expandBranchWithFuel_isSome_of_noSplit` | `… branchesUsed + fuel ≤ maxBranches → (expandBranchWithFuel …).isSome = true` | VERIFIED (read) |
| Fuel.lean | `:1292-1304` | `expandBranchWithFuel_isSome_of_stock` | `… (hfuel : 2 * C.card * L.card < fuel) (hbud : branchesUsed + fuel ≤ maxBranches) : …isSome = true` | VERIFIED (read) |
| TimeTypeBound.lean | `:167-174` | `blocking_fires_of_card_lt` | time bound `2 ^ (2 * C.card)` | VERIFIED (read) |
| Fuel.lean | `:569` | `timeFinset_card_le_of_not_blocked` | T2 contraposed: `(run n).timeFinset.card ≤ 2 ^ (2 * C.card)` | VERIFIED (read) |
| Saturation.lean | `:585-594` | `expandBranchWithFuel` | `(maxBranches : Nat := 50000) (branchesUsed : Nat := 0)`, guard `if branchesUsed >= maxBranches then none` | VERIFIED (read) |
| Saturation.lean | `:646, :654` | `.split` arm | `branchesUsed' := branchesUsed + branches.length`, passed identically to **every** arm | VERIFIED (read) |
| Saturation.lean | `:675, :681` | `.splitOrdered` arm | same shape | VERIFIED (read) |
| Saturation.lean | `:930` | `buildTableau` | `initialBranch := [SignedFormula.neg φ Label.initial]` — one world, one time | VERIFIED (read) |
| Tableau.lean | `:1119-1122, :1161` | `orderTrichotomy` | `.branching` over `disjuncts φ ψ`, a **3**-element list | VERIFIED (read) |
| Tableau.lean | `:1351-1354` | `timeLinearity` | `.branchingOrdered` over a **3**-element list | VERIFIED (read) |
| Closure.lean | `:42` | `self_mem_subformulaClosure` | `(phi : Formula) : phi ∈ subformulaClosure phi` | VERIFIED (`lean_local_search` + read) |
| Mathlib | `Init.Data.Nat.Lemmas` | `Nat.le_mul_of_pos_left` | `{n : ℕ} (m : ℕ) (h : 0 < n) : m ≤ n * m` | VERIFIED (`lean_loogle` hit) |

Source-coverage: every load-bearing claim is grounded in at least two reads (the declaration
itself plus its consumer or its docstring), and the two arithmetic claims are cross-checked by
independent algebra below.

---

## 1. Verifying the finding

### 1.1 The finding is correct as stated

`chain_le_soundFuel'` (`Fuel.lean:1193`) hypothesises `hL : L.card ≤ 2 ^ (2 * C.card)` on the
**label** set `L`. T2 (`blocking_fires_of_card_lt`, contraposed as
`timeFinset_card_le_of_not_blocked`) bounds `b.timeFinset.card ≤ 2 ^ (2 * C.card)` — the **time**
set. `Branch.card_labelFinset_le` (`Fuel.lean:500`) gives
`|labels| ≤ |worlds| * |times|`, and `worldFinset_card_le` gives
`|worlds| ≤ |S| + 2*|C|*|times|`, which is `≥ 1` and is `= 1` only when `S` is a singleton and no
non-seed world exists. So `hL` is derivable from T2 exactly when `|worlds| ≤ 1`, i.e. before any
`boxNeg`/`diamondPos` fires. **Confirmed.** `chain_le_soundFuel'` is true (its `hL` is a
hypothesis) but is a single-world statement.

### 1.2 The arithmetic of the "honest general figure" — verified, and it has a clean closed form

Write `c := |C|`, `m := 2 ^ (2*c)`, `s := |S|`, and `F := soundFuel' φ = 2*c*m` (valid under
`chain_le_soundFuel'`'s `hφ : C.card = (subformulaClosure φ).card`).

`chain_le_worlds_bounded`'s RHS is

```
2 * c * ((s + 2 * c * m) * m)
  = (2 * c * m) * (s + 2 * c * m)      -- associativity/commutativity of *
  = F * (s + F)
  = s * F  +  F^2
```

So the general figure is **exactly `soundFuel' φ * (|S| + soundFuel' φ)`** — not merely
"soundFuel' times something". The handoff's estimate ("exceeds `soundFuel'` by roughly a factor of
`2*|C|*2^(2|C|)`") is **confirmed and sharpened**: the ratio is *exactly* `|S| + soundFuel' φ`,
i.e. exactly `|S| + 2*|C|*2^(2|C|)`. For the engine's actual seed (`buildTableau`'s
`initialBranch = [SignedFormula.neg φ Label.initial]`, so `s = 1`) the figure is
`soundFuel' φ * (soundFuel' φ + 1)` — the general fuel figure is, to a `+1`, the **square** of the
single-world figure. That is a fact worth having in a definition rather than re-derived at every
call site, and it is the single strongest argument for introducing a name (below).

### 1.3 The remaining constraints, re-verified from source

- **`buildTableau_isSome` at the default budget is still false.** `expandBranchWithFuel`'s first
  line is `if branchesUsed >= maxBranches then none` with `maxBranches := 50000`
  (`Saturation.lean:590, :594`), and `buildTableau` (`:931`) calls it at the default. No fuel
  figure rules that out. **Any 4.3 deliverable must quantify `maxBranches`.** Confirmed.
- **Engine edits forbidden** (wave-3 territory contract). The decision below requires none: it
  adds definitions and theorems to `Fuel.lean` only.
- **`WorldWitness` is an invariant, not a theorem** (`Fuel.lean:1000-1003`: deriving it is a
  36-case induction over `applyRule`). `chain_le_worlds_bounded` carries it as `hww`, so
  `worldFuel'` inherits it. **The decision does not discharge it**, and the amended "Done when"
  must say so rather than let it hide inside a named figure. This is a residual the handoff did
  not name and it is the honest cost of option (c)'s "restate against `chain_le_worlds_bounded`".

---

## 2. Adjudication

### 2.1 Reject (a) — redefine `soundFuel'` to carry a world factor

Four independent reasons, in decreasing weight:

1. **It silently destroys a landed theorem's content.** `chain_le_soundFuel'`'s docstring
   (`:1170-1178`) claims "This is the theorem that earns it": the point is that `chain_le_stock`'s
   bound `2*|C|*|L|` at the T2 label figure is *literally equal to* `soundFuel' φ` — no slack.
   Redefine `soundFuel'` to `F*(s+F)` and that theorem becomes a loose inequality with a factor
   `s+F` of slack, and its docstring becomes false. The theorem stays green; its *meaning* is
   destroyed. That is the worst possible failure mode for a formalization: a green build with a
   lying docstring.
2. **It is a semantic change under a stable name.** `soundFuel'` is explained as `2n·2^(2n)` in
   the module docstring, in `soundFuel_le_soundFuel'`'s docstring, and in **17 places** in the
   plan. A reader of any of those, or of the git history, would read a different number under the
   same name.
3. **The single-world figure is independently useful and would be lost.** `boxNeg`/`diamondPos`
   are the only world-minting rules (`Fuel.lean:935`); for a modal-operator-free `φ` neither ever
   fires, `|worlds| = 1`, and `soundFuel'` is the *true* bound, quadratically-exponentially better
   than the general one. Discarding the name forecloses the "modal-free ⟹ single world" corollary
   that Track A will want for the propositional/temporal fragment.
4. **It buys nothing that a new name does not.** Every consumer of a "general" figure is written
   from scratch (there are none yet — see 2.3), so there is no call-site churn to save.

### 2.2 Reject the *rename* half of (b); accept its *document + new figure* half

Renaming `soundFuel'` forces renaming two landed, green, sorry-free theorems
(`soundFuel_le_soundFuel'`, `chain_le_soundFuel'`) and editing 17 plan references, for **zero**
mathematical content. Under H6 convergence discipline and the plan's own preserved-assets stance,
that is churn. The misreading the rename would prevent is prevented just as well — and more
durably — by the docstring, which `Fuel.lean:1180-1191` **already contains** in the sharpest
possible form. The remedy for a name that is right-but-narrow is documentation, not a rename.

What (b) is right about is that the general figure deserves a **name of its own**.

### 2.3 Reject (c) alone — necessary but not sufficient

`chain_le_worlds_bounded` is a **chain-length** bound. 4.3's deliverable is a **fuel figure**: a
`Nat` a caller passes to `expandBranchWithFuel`. The consuming theorem
`expandBranchWithFuel_isSome_of_stock` takes `hfuel : 2 * C.card * L.card < fuel` — a caller needs
a named, computable `Nat` to instantiate `fuel` with. Against a bare five-factor expression, every
downstream consumer (Phase 7 Track A decidability, and any `#eval`-side sanity row) re-inlines
`2 * C.card * ((S.card + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card))` by hand. Worse, a
"Done when" phrased against an inline expression is not mechanically checkable — which is exactly
the failure mode that produced this blocker.

`grep -rn "soundFuel'" --include=*.lean` outside `Fuel.lean` returns **nothing**: there are no
external consumers yet. That is precisely why the naming decision must be made *now*, before
Phase 7 hard-codes an expression.

### 2.4 The adopted combination

1. **`soundFuel'`: frozen.** Name unchanged, body unchanged. Its docstring gains one sentence
   naming it *the single-world (label-count) figure*, pointing at `worldFuel'` for the general
   case. No theorem is renamed or restated.
2. **New general figure `worldFuel'`**, defined so it is *definitionally* the chain bound:

   ```
   worldFuel' (φ : Formula) (s : Nat) : Nat := (s + soundFuel' φ) * soundFuel' φ
   ```

   with `s` the seed-world count. By §1.2 this equals
   `2 * c * ((s + 2*c*m) * m)` on the nose when `c = (subformulaClosure φ).card`, so the bridging
   theorem is `ring`/`Nat`-arithmetic, not an estimate. At the engine's own seed, `s = 1`.
3. **Bridging theorems**, all in `Fuel.lean`, all consuming already-landed results:
   - `soundFuel'_pos : 0 < soundFuel' φ` (via `Finset.card_pos` and the verified
     `self_mem_subformulaClosure`);
   - `soundFuel'_le_worldFuel' : soundFuel' φ ≤ worldFuel' φ s` (via the verified
     `Nat.le_mul_of_pos_left` and `soundFuel'_pos`);
   - `chain_le_worldFuel'` — `chain_le_worlds_bounded` restated at the named figure, i.e. the same
     hypotheses (including `hww : WorldWitness C S (run n)`) plus
     `hφ : C.card = (subformulaClosure φ).card`, concluding `n ≤ worldFuel' φ S.card`.
4. **4.3's "Done when" restated** against `worldFuel'` + a quantified branch budget (see §3).

This combination is the only one that (i) preserves every landed asset and its docstring's truth,
(ii) gives downstream a name to consume, and (iii) keeps the two genuinely different figures
distinguishable — which the mathematics demands, since one is the square of the other.

---

## 3. What 4.3's deliverable becomes

The composition target is the `worldFuel'`-instantiated form of the already-landed
`expandBranchWithFuel_isSome_of_stock`. The label-count side matches exactly:

```
|L| ≤ (s + 2*c*m) * m   ⟹   2 * c * |L| ≤ 2*c*(s + 2*c*m)*m = F*(s+F) = worldFuel' φ s
```

so the hypothesis a caller must supply is a *label-set* cardinality bound in the two dimensions,
which `worldFinset_card_le` and `timeFinset_card_le_of_not_blocked` jointly supply. No new
mathematics is needed for this step — only instantiation.

The honest, checkable 4.3 terminus is therefore:

> `expandBranchWithFuel_isSome_at_worldFuel'`: for a `NoSplit` invariant `P` confining formulas to
> `C` and labels to `L`, with `|L| ≤ (s + 2*|C|*2^(2|C|)) * 2^(2|C|)`,
> `hφ : C.card = (subformulaClosure φ).card`, `worldFuel' φ s < fuel`, and the branch budget
> hypothesis, `expandBranchWithFuel … |>.isSome = true`.

with the three residuals stated explicitly rather than hidden: `WorldWitness` assumed (not
derived), `NoSplit` assumed (the branching arms), and `maxBranches` quantified (never the default).

---

## 4. Composition with residual 3 (the branching budget) — a correction to the handoff

The handoff states that because `branchesUsed` increments by `branches.length` rather than `1`,
"the linear invariant `branchesUsed + fuel ≤ maxBranches` must be restated as a **tree-shaped**
budget". **Source inspection contradicts this, in the favourable direction.**

In both split arms (`Saturation.lean:646` and `:675`), `branchesUsed'` is a `let` bound **once,
before** the fold, and `:654` / `:681` pass that same `branchesUsed'` to **every** sibling. The
fold's accumulator (`acc`) carries only the `Option` result — **no counter**. Siblings therefore do
**not** accumulate each other's usage: `branchesUsed` at any node is the sum, along the single
root-to-node **path**, of `1` per extending step and `branches.length` per split. The budget is
**path-shaped, not tree-shaped**.

Consequently the correct generalisation is still linear, with a branching-factor coefficient:

```
branchesUsed + β * fuel ≤ maxBranches,    β := 3
```

Preservation, checked against the source at each arm (incoming fuel matched as `fuel + 1`, so
every recursive call gets `≤ fuel = fuel₀ - 1`):

| Arm | `branchesUsed` | recursive `fuel` | invariant after |
|-----|----------------|------------------|-----------------|
| `.extended` (`:623`) | `u + 1` | `fuel₀ - 1` | `u + 1 + 3(fuel₀-1) = u + 3·fuel₀ - 2 ≤ mb` ✓ |
| `.split` (`:646, :653`) | `u + k`, `k ≤ 3` | `min alloc fuel ≤ fuel₀ - 1` | `u + k + 3(fuel₀-1) ≤ u + 3·fuel₀` ✓ (needs `k ≤ 3`) |
| `.splitOrdered` (`:675, :680`) | same | same | same ✓ |

and the guard `branchesUsed' < maxBranches` follows because the T3 fuel hypothesis forces
`fuel ≥ 1`, hence `β * fuel ≥ 3 > 0`.

`β = 3` is verified from the rule set, not assumed: every `.branching` result in `Tableau.lean` is
a 2-element list except `orderTrichotomy` (`:1161`), which maps over `disjuncts φ ψ` — a
**3**-element list (`:1119-1122`) — and the only `.branchingOrdered`, `timeLinearity` (`:1351`),
is a **3**-element list. `expandOnceUnblocked` maps over these without changing length
(`Tableau.lean:2109-2110`).

This composes with the fuel decision **multiplicatively by 3 only**: the residual-3 target is
`branchesUsed + 3 * fuel ≤ maxBranches`, which *implies* the currently-landed
`branchesUsed + fuel ≤ maxBranches`, so `expandBranchWithFuel_isSome_of_noSplit` needs no
weakening — the stronger hypothesis is what the split arms will consume. It does **not** interact
with the choice of `worldFuel'` at all, which is the second reason to keep the fuel figure a
standalone name: the budget hypothesis and the fuel hypothesis stay orthogonal.

(Practical note, unchanged: `3 * worldFuel' φ 1` vastly exceeds `50000` for any nontrivial `φ`, so
`buildTableau_isSome` at the engine default remains false. Nothing here reopens it.)

---

## 5. Adversarial Self-Verification (H4)

Re-read of the draft with an adversarial mandate. Each load-bearing claim was challenged for a
documented reason it might *not* hold.

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|---------------------|------------|
| `soundFuel' φ = 2n·2^(2n)`, `n = |subformulaClosure φ|` | `Fuel.lean:136-138` | direct read of the definition | High |
| `chain_le_worlds_bounded` RHS `= soundFuel' φ * (|S| + soundFuel' φ)` when `|C| = n` | `Fuel.lean:1070` + algebra in §1.2 | independent re-derivation, two groupings agree | High |
| Ratio is *exactly* `|S| + 2|C|·2^(2|C|)`, not merely "about" | §1.2 | exact factorisation `F(s+F)`; no inequality used | High |
| `hL` in `chain_le_soundFuel'` is unreachable from T2 once a world is minted | `Fuel.lean:1180-1191`, `worldFinset_card_le` `:1022` | docstring + the bound it cites; `|worlds| = 1` is the only escape | High |
| No `.lean` consumer of `soundFuel'` outside `Fuel.lean` | `grep -rn "soundFuel'" --include=*.lean` returned only `Fuel.lean` | repo-wide grep | High |
| `WorldWitness` is assumed, not derived — `worldFuel'` inherits it | `Fuel.lean:1000-1003` ("stated as an invariant rather than derived … 36-case induction") | direct read; `chain_le_worlds_bounded:1069` carries `hww` | High |
| Split arms do **not** accumulate sibling `branchesUsed` (path-shaped, not tree-shaped) | `Saturation.lean:646` (`let` outside fold), `:654` (same `branchesUsed'` to every arm), `:647-664` (`acc` is `Option`, no counter) | direct read of both split arms; **contradicts the handoff's framing** — see Contradiction Log | High |
| Max branching factor `β = 3` | `Tableau.lean:1119-1122` (3 disjuncts), `:1161`, `:1351-1354` (3 arms); all other `.branching` sites are 2-element literals | enumerated every `.branching`/`.branchingOrdered` construction site via grep, then read the two 3-arm ones | Medium-High — grep over `Tableau.lean` was exhaustive for these constructors, but `β` is a *census*, and a rule added later could break it. Mitigation recorded in the plan amendment: state `β` as a hypothesis `hβ : branches.length ≤ 3`, not a literal. |
| `branchesUsed + 3*fuel ≤ maxBranches` is preserved by all three arms | table in §4 | arithmetic checked arm-by-arm against the recursive call sites | Medium-High — not machine-checked; it is a *target* for the next dispatch, not a landed result, and is labelled as such |
| Engine seed has one world (`s = 1`) | `Saturation.lean:930` | direct read of `initialBranch` | High |
| `self_mem_subformulaClosure` exists (for `soundFuel'_pos`) | `Closure.lean:42` | `lean_local_search` hit + read | High |
| `Nat.le_mul_of_pos_left : (m) (h : 0 < n) : m ≤ n * m` | `Init.Data.Nat.Lemmas` | `lean_loogle` verified type signature | High |
| `buildTableau_isSome` at default `maxBranches` remains false | `Saturation.lean:590, :594, :931` | direct read; unchanged by this decision | High |
| Rejecting (a) does not lose anything provable | §2.1 | challenged: could a *single* redefined name serve both? No — `chain_le_soundFuel'`'s equality-tightness is the content of that theorem, and one name cannot be both tight figures | High |

### Contradiction Log

**Resolved.** The handoff states residual 3 requires a *tree-shaped* budget; §4 concludes the
budget is *path-shaped* (linear with coefficient `β = 3`). Precedence ranking applied: **direct
source reading of `Saturation.lean:646-664` and `:675-690` outranks the prose characterisation in
the handoff**, since the handoff's claim is an inference from "`branchesUsed` increments by
`branches.length` not 1" (true) to "the budget is tree-shaped" (does not follow, because the
increment is not accumulated across siblings). Both cited line ranges were read in full. Resolution
recorded in the plan amendment so the next implementer does not build a tree-shaped invariant they
do not need. This is a *loosening* of a constraint, so the failure mode of being wrong is a proof
that does not close, not an unsound theorem.

### Recommendations modified after verification

1. **`β` stated as a hypothesis, not a literal `3`.** Initially the plan amendment said
   `branchesUsed + 3 * fuel ≤ maxBranches` with `3` baked in. Verification rated the `β = 3`
   census Medium-High (a future rule could add a 4-arm result), so 4.3d's task text now asks for
   the bound to enter as a hypothesis on `branches.length`, with `3` recorded as the currently
   measured value and its two witnesses cited.
2. **`WorldWitness` promoted from footnote to an explicit "Done when" clause.** The first draft let
   `worldFuel'` quietly inherit `hww`. Since `WorldWitness` is *not* a theorem, a "Done when" that
   does not name it would let a future dispatch claim 4.3 complete on a figure that assumes its
   own world bound. Named as residual 4 in the amendment.
3. **`worldFuel'` parameterised by `s : Nat`, not specialised to `1`.** Specialising would have
   made `chain_le_worldFuel'` unable to consume `chain_le_worlds_bounded`'s universally-quantified
   `S`. The engine's `s = 1` is recorded as a note, not baked into the definition.

No forbidden verification outputs are present: no claim of the form "Mathlib likely has this"
appears; no type-mismatch claim is made without the corresponding signature read; the two Mathlib
names used (`Nat.le_mul_of_pos_left`, `Finset.card_pos`) are verified or standard-and-cited.

---

## 6. Zero-debt statement

Nothing in this decision requires `sorry`, an axiom, a vacuous definition, or an engine edit. The
new material is one definition, one arithmetic identity, two one-line order lemmas, and one
restatement of an already-proved theorem. The three residuals (`WorldWitness`, `NoSplit`,
`maxBranches`) remain **named hypotheses**, exactly as `Fuel.lean` already carries them — the
decision does not convert any of them into debt, and equally does not pretend to discharge them.

## 7. Files to be touched by the next implementation dispatch

- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` — additions only
  (`worldFuel'`, `worldFuel'_eq`, `soundFuel'_pos`, `soundFuel'_le_worldFuel'`,
  `chain_le_worldFuel'`, and the instantiated `expandBranchWithFuel_isSome_at_worldFuel'`), plus a
  docstring sentence on `soundFuel'` and a module-docstring status update. Estimated ~120-200 lines.
- No other file. The engine (`Saturation.lean`, `Tableau.lean`) is **not** touched.
