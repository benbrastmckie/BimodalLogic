# Verdict: RECONCILE — the Phase-7 negation unblock does NOT need `conjInterleave`

**Task 382 — read-and-adjudicate probe. Deliverable: this verdict report.** No `Theories/` edits;
`lake build` unaffected; every Rabinovich citation is by PDF page only (the companion `.md`/`.md.bak`
transcription is corrupt and was never opened).

## Verdict (one line)

**RECONCILE.** Rabinovich's own Proposition 4.2 proof (Section 5, PDF p.7) negates an arbitrary-pin
two-free-variable `∃∀`-object by **splitting its single ordered chain at the two pinned points into
three consecutive pieces** and negating each independently, reassembling by **disjunction** — not by
the order-preserving interleaving / conjunction-closure stack proposed in task 379's
`reports/06_phase4-unblock-construction.md`. Both sub-engines the split needs already exist in the
repo, sorry-free. The `~870–1230`-line `conjInterleave`+`veeConj`+general-negation stack of report-06
is a heavier reinvention of a proof Rabinovich never gives; the faithful transcription is roughly
**`~350–550` lines** and eliminates report-06's highest-risk novel-combinatorics item entirely.

---

## Part A — Rabinovich's actual proof methods (PDF-page-cited ground truth)

### A1. Definition 3.1 — the `∃∀`-object has ARBITRARY pins (PDF p.4)

An `∃∀`-formula is `ψ(z_0,…,z_m) := ∃x_n…∃x_1∃x_0 [ (⋀_{k=0}^m z_k = x_{i_k}) ∧ (x_n>…>x_1>x_0) ∧
⋀_{j=0}^n α_j(x_j) ∧ ⋀_{j=1}^n (∀y)^{<x_j}_{>x_{j-1}} β_j(y) ∧ (∀y)_{>x_n} β_{n+1}(y) ∧ (∀y)^{<x_0}
β_0(y) ]`, **with `i_0,…,i_m ∈ {0,…,n}` arbitrary** (PDF p.4). The free variables pin to *any* points
of the chain; the two caps `β_0` (before `x_0`) and `β_{n+1}` (after `x_n`) are ordinary content.
**Nothing in Def 3.1 restricts pins to endpoints or caps to trivial.**

### A2. Lemma 3.2(1) — asserted "clear", no proof given (PDF p.4)

Lemma 3.2 (all three parts) is introduced by the single sentence **"It is clear that"** (PDF p.4).
Rabinovich gives **no** proof of part (1) ("conjunction of `∃∀`-formulas ≡ disjunction of
`∃∀`-formulas"). The combinatorial content he waves away is exactly the disjunction over relative
orderings (interleavings) of two ordered witness chains. So report-06's order-preserving-interleaving
construction is not a *reinvention of a different method* — it is the one method that makes 3.2(1)
true, spelled out. It is faithful **as a rendering of Lemma 3.2(1)**; the question is whether the
**negation case** actually needs it (Part B: it does not).

### A3. Lemma 3.4 conjunction-closure step (PDF p.5)

"The set of `∨∃∀` formulas is closed under disjunction, conjunction, and existential quantification.
**Proof. By (1) and (3) of Lemma 3.2 and distributivity.**" (PDF p.5.) Conjunction-closure of `∨∃∀`
= distribute `∧` over `∨`, then apply Lemma 3.2(1) per pair. Footnote 2 (PDF p.5) records that
`∨∃∀` is **not** closed under negation without the `E[Σ]` expansion (the `P Until Q` truth-table
example), motivating Def 4.1's TL-definable-predicate atoms.

### A4. Proposition 4.2's ACTUAL proof — a three-way chain SPLIT, negated by DISJUNCTION (PDF p.7)

This is the decisive text. Let `ψ(z_0,z_1)` be `∃x_n…∃x_0[z_0=x_m ∧ z_1=x_k ∧ (x_0<…<x_n) ∧
⋀α_j(x_j) ∧ ⋀(∀y)^{<x_j}_{>x_{j-1}}β_j ∧ (∀y)^{<x_0}β_0 ∧ (∀y)_{>x_n}β_{n+1}]` with **arbitrary**
`m,k`. Rabinovich (PDF p.7):

- **Case `k=m`** (`z_0=z_1`): `ψ ≡ z_0=z_1 ∧ ψ'(z_0)` with `ψ'` a **one-free-variable** `∃∀`. By
  **Prop 3.5** `ψ' ≡` a `TL(Until,Since)` formula `A'`, and `¬ψ ≡ z_0<z_1 ∨ z_1<z_0 ∨ ∃x_0[z_0=x_0
  ∧ z_1=x_0 ∧ ¬A'(x_0)]` — a `∨∃∀`. No interleaving, no conjunction closure.
- **Case `k≠m`, w.l.o.g. `m<k`**: `ψ` is equivalent to the **conjunction of three formulas** (PDF
  p.7):
  1. `ψ_0(z_0)` — the chain `x_0<…<x_m` with `α_0..α_m`, `β_1..β_m`, and the **before-cap** `β_0`;
     a **one-free-variable** `∃∀` (free var `z_0=x_m` at the *right* end).
  2. `ψ_1(z_1)` — the chain `x_k<…<x_n` with `α_k..α_n`, `β_{k+1}..β_n`, and the **after-cap**
     `β_{n+1}`; a **one-free-variable** `∃∀` (free var `z_1=x_k` at the *left* end).
  3. `φ(z_0,z_1)` — the **middle** chain `z_0=x_m<x_{m+1}<…<x_k=z_1` with `α_m..α_k`, `β_{m+1}..β_k`
     and **NO caps**; a **two-free-variable** `∃∀` with **both pins at its own endpoints**.
- "The first two formulas are `∃∀`-formulas with one free variable. Therefore, (by **Prop 3.5**) they
  are equivalent to `TL(Until,Since)` formulas. Hence, their negations are equivalent … to atomic
  (and hence to `∃∀`) formulas." (PDF p.7.)
- "Therefore, it is sufficient to show that the negation of the **third** formula is equivalent … to
  a disjunction of `∃∀`-formulas. This is stated in the following **Lemma 5.1**." (PDF p.7.)

`¬ψ = ¬(ψ_0 ∧ ψ_1 ∧ φ) = ¬ψ_0 ∨ ¬ψ_1 ∨ ¬φ` — a **disjunction** (trivial reassembly). The negation
of a *single* two-free-var object needs **no conjunction closure at all**.

### A5. Lemma 5.1 — the endpoint-pinned, cap-free middle-piece negation (PDF pp.7–11)

Lemma 5.1 negates exactly `∃x_0…∃x_n[z_0=x_0<…<x_n=z_1 ∧ ⋀α_j(x_j) ∧ ⋀(∀y)^{<x_j}_{>x_{j-1}}β_j(y)]`
(eq. 5.1, PDF p.7): `z_0` = **left endpoint** `x_0`, `z_1` = **right endpoint** `x_n`, and **no
caps**. Its proof is an induction on `n` (Lemma 5.3, Cor. 5.4, INF/`K⁺` machinery, PDF pp.8–11) that
**internally** uses "the set of `∨∃∀` formulas is closed under conjunction, disjunction and `∃`"
(PDF p.8, p.11). **This is the only place conjunction-closure enters Prop 4.2 — and the repo has
already discharged the entire Lemma 5.1 obligation sorry-free** via the legacy `VecEA2`/`VVecEA2`
engine (`Section5Correspondence.prop42_contentful_of_attained`, `VVecEA2.negFix_iff`), wired at
`Prop42ExistsForall.lean:435` (`prop42_veeSat_negation`). So Lemma 5.1's internal conjunction-closure
is **not a new obligation**.

### A6. Prop 4.3 negation case — where conjunction-closure genuinely lives (PDF p.6)

Prop 4.3's structural-induction Negation case (PDF p.6): (i) if `φ` is an `∃∀`-formula, by **Lemma
3.2(2)** `φ ≡ ⋀_iψ_i` (≤2-free-var), so `¬φ ≡ ∨_i¬ψ_i` (**disjunction**; each `¬ψ_i` a `∨∃∀` by Prop
4.2) — **no conjunction closure**; (ii) **only** if `φ` is itself a **disjunction** `∨_iφ_i` does
`¬φ ≡ ⋀_i¬φ_i` invoke Lemma 3.4 conjunction-closure. Conjunction-closure is therefore a property of
the **AND/`¬∨` connective case**, *separate* from the single-object negation the Phase-7 blocker is
about — and `Prop43.lean:151` already lists "**and**: requires a complete conjunction closure (Lemma
3.2(1) as an iff)" as its **own** distinct blocker, independent of negation.

---

## Part B — The three cross-check answers

### Cross-check (1): is `EndpointPinnedCapTrivial` a repo artifact or a real Rabinovich feature?

**Repo-internal `VecEA2`-translation artifact — confirmed.** Rabinovich's Def 3.1 (A1, PDF p.4) and
his Prop 4.2 statement (`ψ(z_0,z_1)` with arbitrary `z_0=x_m`, `z_1=x_k`, real caps `β_0`/`β_{n+1}`;
PDF p.7) carry **arbitrary pins and contentful caps**. The repo's `EndpointPinnedCapTrivial`
(`Prop42ExistsForall.lean:75-86`: `pinLeft : ψ.pin 0 = 0`, `pinRight : ψ.pin 1 = Fin.last ψ.n`,
`capTrivialLeft/Right`) is strictly narrower, and the module docstring (`:22-28`) states the reason
outright: "We do **not** extend `VecEA2` to carry caps — that would be canonical-form machinery
beyond Rabinovich." The endpoint-pin+trivial-cap shape is precisely the class Rabinovich isolates as
his **middle piece `φ`** (A4/A5) after splitting off the caps and interior-pin content into the two
one-free-var end pieces. It is a real *sub-case* of Rabinovich's proof, not his Prop 4.2 object.

### Cross-check (2): can `augTarget` be re-stated to land its 2 free variables at chain endpoints?

**No — and it does not need to.** `augTarget`/`pairProject` (`ExistsForallLemmas.lean:129-141,
349-351`) is Lemma 3.2(2)'s **≤2-free-var arity reduction**; its 2-free-var pieces genuinely pin at
**interior** points, and forcing them to endpoints is not equivalence-preserving: a piece with an
interior lower pin `z_0=x_{i_0}` (`i_0>0`) carries **existential** point-witnesses `x_0<…<x_{i_0-1}`
*below* `z_0` (each asserting some `α`), and a single **universal** cap cannot encode "there exist
points below `z_0` satisfying `α`" (symmetrically above the upper pin). So a general re-target loses
content. **But cross-check (2) is the wrong lever:** Rabinovich does not re-target the reduction — he
**splits each already-produced arbitrary-pin object at its two pins** (A4). The below-pin and
above-pin existential content becomes the two **one-free-variable** end pieces `ψ_0`, `ψ_1` (negated
via Prop 3.5), and only the genuinely endpoint-pinned cap-free **middle** goes to the existing
engine. The split is equivalence-preserving precisely because it keeps the existential end-content as
first-class one-free-var objects instead of trying to fold it into caps.

### Cross-check (3): does report-06's interleaving match Rabinovich's Prop 4.2 shape?

**No — it is a heavier reinvention of the wrong lemma for this case.** report-06 §3 routes the
arbitrary-pin negation through `efSat_negation_general` → `veeConj` (§2) → `conjInterleave` (§1,
~500–650 lines), asserting (§3 step 3) that the per-object negations are re-assembled "by §2
(`veeConj_iff`), iterated — … the closed-under-conjunction (Lemma 3.4) step the paper invokes in the
negation case." **This misreads Section 5.** Rabinovich negates a single two-free-var object as
`¬ψ_0 ∨ ¬ψ_1 ∨ ¬φ` — a **disjunction**, reassembled by `veeSat_append`; there is no `⋀_i N_i` to
combine, hence no `veeConj`/`conjInterleave` in the single-object negation (A4). `conjInterleave`
(Lemma 3.2(1)) does resurface elsewhere — inside Lemma 5.1 (already discharged, A5) and in Prop 4.3's
*`¬∨` / AND* connective case (A6, a **separate** blocker) — but **not** in the negation of the
`pairProject` object that is the stated Phase-7 blocker (`reports/06...md` lead paragraph). The
order-preserving *interleaving of two independent chains* (unknown relative order → enumerate all
merges) is strictly harder than what Section 5 requires: a *split of one chain at two known points*
(fixed order `below < x_m < middle < x_k < above` → no enumeration), which is the same
"glue-along-shared-pins" already implemented sorry-free in `ExistsForallLemmas.gluedChain`
(`:579-688`).

---

## Part C — RECONCILE: the concrete smaller construction for task 383

Task 383 should transcribe Rabinovich Section 5 (PDF p.7) — the chain split — **not** report-06's
§1/§2. All signatures below are in the repo's real vocabulary; each reused engine is cited to
`file:line` and is already sorry-free.

### Reused, already-verified assets (no new work)

| Asset | Location | Role in the split |
|-------|----------|-------------------|
| `efSat`, `ExistsForallFormula` fields (`n`,`pin`,`pointType`,`intervalType`) | `ExistsForallFormula.lean:81-111` | object under negation |
| `prop42_veeSat_negation` (endpoint-pinned, `HasAttainedINF/SUP`) | `Prop42ExistsForall.lean:435-445` | negate the **middle** piece `φ` |
| `EndpointPinnedCapTrivial` | `Prop42ExistsForall.lean:75-86` | hypothesis discharged for `splitMiddle` |
| `translateProp35` / `translateProp35_correct` (`ExistsForallFormula sig F 1 → Formula`, `↔ efSat`) | `Prop35Assembly.lean:84-97` | negate the two **end** pieces `ψ_0`,`ψ_1` |
| `translateVeeProp35` / `_correct` | `Prop35Assembly.lean:373-395` | `∨∃∀` lift of the end-piece route |
| `gluedChain` + `gluedChain_strictMono/_between/_pointType/_before/_after` | `ExistsForallLemmas.lean:579-688` | template for the split **backward** (gluing) direction |
| `VVecEA2.disj` / `disj_holds`, `VVecEA2.trivialTrue` | `VecEAFormula.lean:282-286`, `VecEAConjFull.lean:542` | disjunctive reassembly `¬ψ_0∨¬ψ_1∨¬φ`; trivial caps of `splitMiddle` |
| `veeSat_append` | `VeeExistsForall.lean:69` | `∨∃∀` disjunction closure |

### D1 — chain-split decomposition (~150–250 lines)

```lean
/-- Below piece: 1-free-var `∃∀` on x₀..x_m with the before-cap `β₀`, free var pinned to the
    RIGHT endpoint x_m. -/
def splitBelow {sig F} (ψ : ExistsForallFormula sig F 2) : ExistsForallFormula sig F 1

/-- Above piece: 1-free-var `∃∀` on x_k..x_n with the after-cap `β_{n+1}`, free var pinned to the
    LEFT endpoint x_k. -/
def splitAbove {sig F} (ψ : ExistsForallFormula sig F 2) : ExistsForallFormula sig F 1

/-- Middle piece: endpoint-pinned, cap-free 2-free-var `∃∀` on x_m..x_k (caps set to
    `UnaryType` top so `EndpointPinnedCapTrivial` holds). -/
def splitMiddle {sig F} (ψ : ExistsForallFormula sig F 2) : ExistsForallFormula sig F 2

theorem splitMiddle_endpointPinned {sig F} (N) (ψ : ExistsForallFormula sig F 2)
    (hpin : ψ.pin 0 ≤ ψ.pin 1) : EndpointPinnedCapTrivial N (splitMiddle ψ)

/-- Section 5 (PDF p.7) decomposition, ordered-pin case. Backward direction glues the three
    sub-chains at the shared pinned endpoints x_m, x_k — same technique as `gluedChain`. -/
theorem efSat_split {sig F} (N) (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2)
    (hpin : ψ.pin 0 ≤ ψ.pin 1) :
    efSat N env ψ ↔
      efSat N ![env 0] (splitBelow ψ) ∧
      efSat N ![env 0, env 1] (splitMiddle ψ) ∧
      efSat N ![env 1] (splitAbove ψ)
```

Notes: (a) a small `wlog`/symmetry wrapper normalizes `ψ.pin 0 > ψ.pin 1`, and the degenerate
`ψ.pin 0 = ψ.pin 1` (`k=m`) case reduces to a single `splitMiddle`-free 1-free-var object per
Rabinovich's `k=m` branch (A4). (b) The backward direction reuses `gluedChain`'s "glue along shared
pins" — but with only THREE pieces in FIXED order, so **no interleaving enumeration** is ever formed.

### D2 — single arbitrary-pin object negation → `VVecEA2` witness (~120–220 lines)

```lean
/-- Prop 4.2 on a SINGLE arbitrary-pin two-free-var `∃∀`-object (the `pairProject` output), via the
    Section-5 chain split. Output shape mirrors `prop42_veeSat_negation` (a `VVecEA2` witness). -/
theorem prop42_efSat_negation_general {sig F} (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (ψ : ExistsForallFormula sig F 2) :
    ∃ v' : VVecEA2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (v'.holds N atomMap (env 0) (env 1) ↔ ¬ efSat N env ψ)
```

Proof shape: `efSat_split` ⇒ `¬efSat ψ ↔ ¬efSat(splitBelow) ∨ ¬efSat(splitMiddle) ∨ ¬efSat(splitAbove)`;
`¬splitMiddle` via `prop42_veeSat_negation` (singleton `VeeExistsForall` `[splitMiddle ψ]` with
`splitMiddle_endpointPinned`); `¬splitBelow`, `¬splitAbove` via `translateProp35` → `Formula.neg` →
realize the negated one-free-var TL formula as a single-point `VVecEA2` endpoint clause; combine the
three with `VVecEA2.disj`. Inherit `HasAttainedINF/SUP` exactly as `prop42_veeSat_negation` does.

**Residual construction risk (the one genuinely new small piece):** realizing `¬(translateProp35 …)`
(a one-free-var TL `Formula`) as a `VVecEA2`/`∃∀` endpoint clause — Rabinovich's "atomic in the
`E[Σ]` expansion" step (A4, PDF p.7). The `atomMap`/`h_surj` surjectivity already used by
`atomAt`/`atom_literal` (`Prop43.lean:75-90`) supplies the alphabet; budget ~40–80 lines and treat as
the item to typecheck first. This is the correct place for any construction-time confirmation — it is
**not** combinatorial.

### D3 — wire into Phase 7 (~30–60 lines)

Replace the Phase-7 Prop 4.3 negation-case call that currently hands `pairProject` output to the
endpoint-only `prop42_veeSat_negation` with `prop42_efSat_negation_general`. The per-object negations
combine by **disjunction** (`VVecEA2.disj` / `veeSat_append`), matching Prop 4.3's atom-negation
sub-case (A6) — **no conjunction closure required in the negation case.**

### Size comparison

| Route | Components | Lines | Highest risk |
|-------|-----------|-------|--------------|
| **report-06 (rejected)** | `conjInterleave` §1 + `veeConj` §2 + general negation §3 | **~870–1230** | novel order-preserving interleaving enumeration (no scaffolding) |
| **RECONCILE (this verdict)** | `efSat_split` D1 + `prop42_efSat_negation_general` D2 + wire D3 | **~350–550** | small "TL-formula-as-`∃∀`-atom" realization (D2 residual, ~40–80 lines) |

### Explicit scope boundary for task 383 (and what it does NOT need)

- Task 383 builds **only** D1–D3 (the negation case). It does **not** build `conjInterleave` or
  `veeConj`.
- `conjInterleave` (Lemma 3.2(1) conjunction closure) remains a **real but separate** obligation for
  the **AND / `¬∨` connective case** of Prop 4.3 (A6; `Prop43.lean:151`). It should be scoped and
  sequenced as its own task if/when the AND case is attempted — not smuggled into the negation
  unblock. This verdict does not re-open or re-scope that separate item; it only removes it from the
  negation-case critical path.

---

## Compliance / constraints

- `git status --short Theories/` empty at read-time and at write-time; **no `Theories/` file created
  or edited**. `lake build` behavior unaffected (this task wrote only under `specs/382_.../`).
- No scratch `.lean` was needed: every proposed signature is a composition of already-verified
  declarations, each cited to `file:line`; the one residual construction item (D2's TL-formula
  realization) is explicitly flagged for typecheck at the start of task 383 rather than asserted.
- Every Rabinovich reference is by PDF page (Def 3.1 p.4; Lemma 3.2 p.4; Lemma 3.4 + footnote 2 p.5;
  Prop 4.2 statement p.6; Prop 4.2 proof + three-way split + Lemma 5.1 p.7; Lemma 5.3/Cor 5.4/INF
  pp.8–11; Prop 4.3 negation case p.6). The corrupt `.md`/`.md.bak` transcription was never opened.
```
