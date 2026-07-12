# Report 07 — Primary-Source Faithfulness Deep-Check: `endChar` vs Rabinovich 2014

- **Task**: 349 — build recursive `endChar : (k) → EndCharCarrier sig k` + `endChar_correct`
  (navigated arity-3 endpoint primitive)
- **Mode**: `--hard` (H2/H3/H4/H5), `--lit`. Reference tier: **Tier 1** (literature-backed, lean4 strict)
- **Session**: sess_1783841542_df767b
- **Authority**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
  (read in full, 1–495; cited as `md:NNN`). **Where a prior report conflicts with the paper, the
  paper wins and the conflict is flagged (§6).**
- **Lean read this session**: `NavigatedEndChar.lean` (`endChar`/`endCharStep`/`navPieceForm`/
  `navPiece_reduce`/`endChar_correct` frozen spec), `Base.lean:667/687/995/1007/1056/1127`,
  `CarrierK1V.lean:1–98`, `Lemma32Reduction.lean:535`, and the machine-checked negative guardrails
  `endCharN0_correct_world_local_obstruction` / `endCharN0_correct_infeasible` (via report 03 +
  Base.lean).

---

## 0. Verdict up front

**UNFAITHFUL.** The recursive single-point carrier

```lean
abbrev EndCharCarrier (sig) (k) : Type := NormalForm sig k 3 → TemporalPred   -- Base.lean:1007
```

— a `TemporalPred` (closed object read at **one** world `w` via `.eval_at M atomMap w`) produced by
recursion on `k` at anchor-arity 3 — **has no counterpart in Rabinovich's proof**. It applies
Rabinovich's single-point collapse (Proposition 3.5, `md:137`, precondition **exactly one free
variable**) to an object with **two** explicit anchors `{x,t}` (two free variables). Rabinovich's
recursion carrier through the entire hard part of the proof (§5) is the **Prop-valued two-endpoint
interval formula** `[α0,β1,…,αn](z0,z1)` (`md:219`), which keeps **both** endpoints explicit as free
variables and is **never read at one point** until the free-variable count drops to one.

This is not merely an analytic judgment: the codebase has **already machine-proved** that no
single-world object can inhabit the frozen target (`endCharN0_correct_infeasible`, a concrete
2-point countermodel derives `False`), and has **already built the faithful replacement carrier**
`BracketEndCharCarrier := NormalForm sig k 3 → VecEA2 1` (`CarrierK1V.lean:52`), green at `k=0`. The
recurring four-strike obstruction is caused by work **regressing back onto the refuted single-point
`EndCharCarrier`/`navPieceForm` line** (report 05's `h_res` re-freeze) instead of committing to the
already-endorsed two-anchor bracket carrier. The refuted `navPieceForm_correct` is the exact
unfaithful shape (§5).

The `h_res` residual (report 05) is a **Lean artifact with no analogue in Rabinovich** (§3.3, §4).

---

## 1. Faithful reconstruction of Rabinovich's recursion carrier and free-variable discipline

### 1.1 The three free-variable regimes (the load-bearing discipline)

Rabinovich's normal form is the `→∃∀`-formula (Definition 3.1, `md:109–111`): a prefix of `n+1`
existential quantifiers over **bound** witness points, all `αj, βj` quantifier-free **with one
variable**, and `m+1` **free** variables `z0,…,zm`. Three distinct operations happen at three
distinct free-variable counts, and **the operation and the carrier's shape are determined by the
count**:

| Free vars | Operation | Paper (md:) | Carrier shape at this stage |
|---|---|---|---|
| any `n` | reduce to a **conjunction** of ≤2-free pieces | **Lemma 3.2(2)**, `md:119` | conjunction of `≤2`-free `→∃∀` formulas |
| exactly **2** | **negation / navigation** (the hard part, §5) | **Prop 4.2** `md:165`; §5 `md:195–335` | `[α0,β1,…,αn](z0,z1)` — **Prop over 2 explicit endpoints** |
| exactly **1** | **collapse to a temporal formula** | **Prop 3.5**, `md:137` | closed `TL(Until,Since)` formula, read at one point |

- **Lemma 3.2(2)** (`md:119`): "Every `→∃∀`-formula is equivalent to a conjunction of `→∃∀`-formulas
  with **at most two free variables**." The reduction target is a **conjunction of ≤2-free pieces**,
  each keeping its (up to two) endpoints explicit.
- **Proposition 3.5** (`md:137`): "Every `∨→∃∀`-formula with **one free variable** is equivalent to a
  `TL(Until,Since)` formula." This is the **only** place a single-point temporal formula is produced,
  and its precondition is **exactly one free variable**.
- **Proposition 4.2** (`md:165`): "The negation of `→∃∀`-formulas **with at most two free variables**
  is equivalent … to a disjunction of `→∃∀`-formulas." The negation/closure step — the whole content
  of §5 — operates at **two** free variables and returns a **two-free-variable** object. It never
  collapses to one point here.

### 1.2 §5: the interval formula keeps BOTH endpoints explicit throughout

Notation 5.2 (`md:219`) fixes the two-free-variable object as `[α0,β1,α1,…,αn−1,βn,αn](z0,z1)`.
Unpacked (Cor 5.4 proof, `md:263`): there is an increasing sequence `z0 < x1 < ⋯ < xn < z1` with
`αi(xi)` at the **bound** intermediate points `xi` and `βi` holding along each open sub-interval.
`z0` and `z1` are the **enclosing pair**; they are explicit free variables of the formula **at all
times**. The `xi` witnesses are **bound**, one at a time, as endpoints of nested `Until`s.

- **Lemma 5.3** (`md:225`): the negated point-chain is `On(P1,…,Pn,z0,z1)` — again a Prop with the
  **two endpoints `z0,z1` as free variables**.
- **Lemma 5.1 / Figure 1** (`md:297–299`): a split introduces a bound `z` giving
  `B2(z0,z,z1) := [α0,β1,α1,β2,β2](z0,z) ∧ [β2,β2,α2,β3,α3](z,z1)` — **two adjacent two-endpoint
  interval formulas** sharing the bound endpoint `z`. Even a split object is a conjunction of
  2-endpoint pieces, never a single-point read of a many-anchor object.
- **§7 Definition 7.13** (`md:451`) is the decisive generalization: a `(z0,z1,…,zk,∞)-→∃∀` formula
  is **by definition a conjunction `⋀_{i≤k} ϕi`** where each `ϕi` is a `(zi,zi+1)-→∃∀` formula
  (2 adjacent endpoints). A `k`-anchor object is **decomposed into adjacent 2-endpoint pieces**; each
  piece keeps its two endpoints explicit. **Rabinovich never characterizes a ≥2-free-variable object
  by reading a single closed formula at one point.**

### 1.3 Navigation = re-anchoring, never a third free variable

In Lemma 5.3's inductive step (`md:231–247`), navigation computes `r0 = inf{z ∈ (z0,z1) | P1(z)}`
(exists by Dedekind completeness, `md:233`), which is **definable by a `∨→∃∀` formula**
`INF(z0,r0,z1,P1)` (`md:245`), and then **recurses with `On(P2,…,Pn, r0, z1)`** (`md:237`): the past
endpoint `z0` is **replaced by** `r0`. The new point `r0` is **existentially bound**
(`(∃r0)_{z0}^{z1}[INF(z0,r0,z1,P1) ∧ On(P2,…,Pn,r0,z1)]`, `md:245`) and **instantly becomes the new
endpoint**. The free-variable count stays **exactly 2**. Case 3 of Lemma 5.1 (`md:301–303`) does the
same with `INF^{¬β1}`. Ordering of a bound witness against the enclosing endpoint is supplied by the
`Until`/`Since` modality (`md:79`); ordering against non-adjacent anchors is transitive
(`md:267–273`). **There is no free-standing per-witness residual and no third free anchor anywhere in
§5.**

### 1.4 The overall recursion carrier

Combining §1.1–§1.3: the object Rabinovich carries at every step of the hard recursion (Prop 4.2 /
§5, and its §7 generalization Def 7.13) is a **Prop-valued interval formula with its (≤2) endpoints
explicit as free variables**. The single-point temporal formula (`TemporalPred` analog) is produced
**once**, at Proposition 3.5, and **only** when exactly one free variable remains. Theorem 4.4
(`md:185–187`) then assembles the final one-free-variable result.

---

## 2. Our Lean construction (what it actually is)

| Lean object | File:line | Shape |
|---|---|---|
| `EndCharCarrier := NormalForm sig k 3 → TemporalPred` | Base.lean:1007 | **single-world** map; `TemporalPred` read via `.eval_at M atomMap w` |
| `endChar 0 = endChar0`; `endChar (k+1) = endCharStep (endChar k)` | NavigatedEndChar.lean:329 | recursion on `k`, arity **fixed at 3** (2 anchors `{x,t}` beyond `w`) |
| `endCharStep rec qnf = ⟨formula_conjList (endChar0…qnf.1 :: map (fun sub ⇒ nf_quant_clause_tl (navPieceForm rec sub) (qnf.2 sub)) …)⟩` | NavigatedEndChar.lean:313 | produces a **single closed `Formula`** wrapped as `TemporalPred` |
| `navPieceForm rec sub = Formula.or (bracketBuildLeft (seg rec q3)(rec q3)) (bracketBuildRight …)` | NavigatedEndChar.lean:196 | **closed `Formula`**, `rec : NormalForm sig k 3 → TemporalPred` fixed **before** `x,t` |
| `endChar_correct` (FROZEN, step **[BLOCKED]**) with `h_res` | NavigatedEndChar.lean:263–270 | `(endChar k qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w x t) qnf`, gated by `h_res` |
| `navPieceForm_correct` (**NOT landed**, the 4th-strike blocker) | NavigatedEndChar.lean:222–236, 510–512 | stuck goal `temporal_truth M atomMap w (navPieceForm rec sub) ↔ ∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub` |
| `nfEval_le2_reduction` (Lemma 3.2(2)) | Lemma32Reduction.lean:535 | GREEN; `nf_eval_nf M k n env qnf ↔ nfEvalRHS …` (arity `n` → conjuncts of anchor-arity ≤3) |
| `nf_zone_flatten_navigable(_correct)` | Base.lean:667/687 | GREEN; **Prop-valued, `x,t` explicit on both sides** |
| **faithful carrier** `BracketEndCharCarrier := NormalForm sig k 3 → VecEA2 1` | CarrierK1V.lean:52 | 2 anchors `{x,t}` **explicit** endpoints, `w` a bracket witness; green at `k=0` |

The decisive type fact: `TemporalPred.eval_at tp w` is a function of the **single** world `w` only.
`endChar k qnf : TemporalPred`, so `endChar k qnf` is a function of `w` alone — yet its target
`nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` reads `M.interp p x` and `M.interp p t` (positions 1,2). A
function of `w` cannot be biconditional to a function of `w,x,t` for arbitrary `x,t`. This is
**machine-proved** in-tree: `endCharN0_correct_world_local_obstruction` forces the RHS to be
independent of `env` at positions ≥1, and `endCharN0_correct_infeasible` derives `False` from a
concrete 2-point countermodel (report 03, "Root Cause"). **No single-world base exists at all.**

---

## 3. Faithfulness map

| # | Lean construct | Claims to implement (Rabinovich §/lemma, md:) | Faithful? | Divergence |
|---|---|---|---|---|
| 1 | `EndCharCarrier := … → TemporalPred` (single-world carrier), `endChar` recursion | the §5 recursion carrier (Prop 4.2 navigation, `md:165`) collapsed to Prop 3.5 form (`md:137`) | **UNFAITHFUL** | Rabinovich's §5 carrier is a **2-free-variable Prop** `[…](z0,z1)` (`md:219`); the single-point `TemporalPred` collapse (Prop 3.5) is used at **1** free variable, `md:137`. This carrier applies the 1-free collapse at **2** anchors. In-tree machine-refuted (`endCharN0_correct_infeasible`). **Point of departure = the carrier TYPE.** |
| 2 | `endChar_correct` with residual `h_res` (NavigatedEndChar.lean:263) | "the anchor layer is supplied by the enclosing bracket" | **UNFAITHFUL (artifact)** | Rabinovich has **no** per-object anchor-predicate residual. The only anchor constraint is `α0(z0)` at the **single origin** (`md:263`, `md:285` Case 1). His second endpoint `z1` is a genuine **explicit free variable**, not an externally-pinned residual. `h_res` exists only to neutralize the anchors the single-point carrier cannot read — a symptom of divergence #1, not a Rabinovich construct. |
| 3 | arity-3 cap (guard G4) + `nfEval_le2_reduction` | **Lemma 3.2(2)** ≤2-free reduction (`md:119`) | **FAITHFUL** | `nfEval_le2_reduction` (Lemma32Reduction.lean:535, GREEN) reduces arity-`n` to conjuncts of anchor-arity ≤3 (≤2 anchors + witness). Correct realization of `md:119`. The cap itself is faithful; the divergence is what the *carrier* built on top of it (#1). |
| 4 | `navPieceForm` def + `seg` + `bracketBuild*` | §5 navigation/interval-split (Lemma 5.1/5.3, `md:225/297`) as a **closed converter** | **UNFAITHFUL (as a `Formula`-valued converter)** | `navPieceForm rec sub : Formula` fixes `rec : NormalForm sig k 3 → TemporalPred` **before** the anchors `x,t`. `seg`/`bracketBuild*` (navigation, interior) mirror the right *pieces*, but wrapping them in a **closed `Formula` read at one `w`** re-commits divergence #1. Rabinovich's `On`/`[…](z0,z1)` are **Props with `z0,z1` explicit**, not closed formulas. |
| 5 | `navPieceForm_correct` (the 4th-strike blocker) | a Prop-3.5-style one-point ↔ equivalence | **UNFAITHFUL (a non-theorem)** | Target: `temporal_truth M atomMap w (navPieceForm rec sub) ↔ ∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub` (NavigatedEndChar.lean:510). LHS is a **closed formula at one world `w`**; RHS is a **≥2-free-variable object** (anchors `x,t` at positions 2,3). **Rabinovich NEVER asserts an equivalence of this shape.** His one-point equivalences (Prop 3.5, `md:137`) are at **exactly one** free variable; here there are two anchors. **This is the unfaithfulness, precisely located.** |
| 6 | `nf_zone_flatten_navigable(_correct)` | §5 two-endpoint navigated merge / Cor 5.4 (`md:255`) | **FAITHFUL** | Prop-valued, `x,t` explicit on **both** sides (Base.lean:687). This **is** Rabinovich's `[…](z0,z1)` (`z0,z1 = x,t`). It is already green and immune to parameter-independence. |
| 7 | `BracketEndCharCarrier := … → VecEA2 1` (CarrierK1V.lean:52) | Prop 3.5 two-anchor bracket / §5 carrier | **FAITHFUL (the correct carrier)** | 2 anchors `{x,t}` are **fixed explicit endpoints** (`z0,z1`), `w` a bracket witness; correctness `BracketCarrierCorrect` keeps `x,t` explicit on both sides (CarrierK1V.lean:62–68). Green at `k=0` (`bracketEndChar_k0(_correct)`). |

---

## 4. VERDICT on the `endChar` primitive: **UNFAITHFUL**

**Exact point of departure.** The type declaration `EndCharCarrier := NormalForm sig k 3 →
TemporalPred` (Base.lean:1007). By fixing the recursion output as a `TemporalPred` (single-world
predicate) while the anchor-arity is 3 (two anchors `{x,t}` beyond the read point `w`), it commits
the construction to a **Proposition-3.5 collapse at two free variables** — an operation Rabinovich
performs only at **one** free variable (`md:137`). Everything downstream (`navPieceForm`, `h_res`,
the four refutations) is a consequence of this one type-level decision.

**What Rabinovich's faithful carrier is instead.** A **Prop-valued object with its two endpoints
explicit** — `[α0,β1,…,αn](z0,z1)` (`md:219`) / `On(P1,…,Pn,z0,z1)` (`md:225`), realized in-tree by
the already-green `nf_zone_flatten_navigable_correct` (Base.lean:687, `z0,z1 = x,t`) and installed as
a recursion carrier by `BracketEndCharCarrier := NormalForm sig k 3 → VecEA2 1` (CarrierK1V.lean:52).
The single-point `TemporalPred` is produced **only** at the ≤1-free-variable base (Prop 3.5).

**Why the obstruction is recurring (H5 root cause).** The four strikes
(`navBrickForm` → `navMultiAnchorForm` → `navPieceForm` → `navPieceForm_correct`) are **the same
non-theorem four times**: each keeps the single-point `→ TemporalPred` carrier and re-patches the
anchor layer differently (single-anchor read; multi-anchor navigation; reduce-first; `h_res`
pinning). The invariant defect — a one-point object asked to characterize a ≥2-free-variable object
— survives every patch because it lives in the **carrier type**, not in any converter's internals.
The in-tree machine refutation `endCharN0_correct_infeasible` proves no such single-world object
exists; the endorsed replacement `BracketEndCharCarrier` already exists and is green at `k=0`. The
fourth strike is a **regression** onto a line the codebase had already abandoned (CarrierK1V.lean:19:
"has **no counterpart in Rabinovich's proof** and is provably FALSE in free-anchor form").

---

## 5. The faithful Lean primitive (what `endChar`/the recursion should carry)

**Carry a two-endpoint Prop, collapse to a closed formula only at ≤1 free variable.**

1. **Recursion carrier = `BracketEndCharCarrier sig k := NormalForm sig k 3 → VecEA2 1`**
   (CarrierK1V.lean:52), whose correctness target keeps both anchors explicit
   (CarrierK1V.lean:62–68):
   ```lean
   (carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
   ```
   This is Rabinovich's `[…](z0,z1)` with `z0,z1 = x,t` (`md:219`); `w` is the bound bracket witness
   (`∃xi`, `md:263`). **No `h_res`** — `x,t` are explicit free variables, exactly as `z0,z1` are in
   the paper.

2. **Step builder** = `nf_zone_flatten_navigable_correct` (Base.lean:687, the faithful merge, `x,t`
   explicit) for the two-endpoint navigation, with `seg`/`bracketBuild*` supplying the β-segment
   interior (Fig 1, `md:299`) and re-anchoring (Lemma 5.3, `md:237`); the depth-`k` `VecEA2 1` hook
   is the IH. Apply `nfEval_le2_reduction` (Lemma 3.2(2), `md:119`) **first** to hold arity ≤3.

3. **Collapse to a closed `TemporalPred`/`Formula` only at the base** (`k=0`, ≤1 free locus via
   `nf_3var_bracket_xyt`/`char_k1`), the Proposition 3.5 point (`md:137`).

**Why this dissolves the parameter-independence obstruction.** The carrier is a function of `x,t`
**throughout** (a `VecEA2 1` whose `.holds M atomMap x t` reads both anchors), matching the
`x,t`-non-constant target. There is never a `Formula`/`TemporalPred` fixed before `x,t`, so the
constant-vs-non-constant refutation (report 04) **cannot form**, and `h_res` becomes **unnecessary**
(the second endpoint is a real free variable, not an external residual). This is the same conclusion
the in-tree comments (CarrierK1V.lean:19–53) and report 03 reached from a full-PDF read; it has been
**green at `k=0` and not yet regressed**, unlike the single-point line.

**Impact on tasks 349 / 350 / 309.**
- **349**: the frozen `EndCharCarrier := … → TemporalPred` and the `navPieceForm`/`h_res` line must
  be **retired from the live path** (they are already flagged "abandoned/off the live path" in
  CarrierK1V.lean:42/48). The deliverable carrier must be `BracketEndCharCarrier` (VecEA2, 2 anchors
  explicit). `nfEval_le2_reduction`, `nf_zone_flatten_navigable(_correct)`, `seg`, `bracketBuild*`,
  and the `endChar0`/`nf_3var_bracket_xyt` base are all **preserved and reused**. Do **not** attempt
  `navPieceForm_correct` (a machine-checked non-theorem) — mark that line `[BLOCKED]`/superseded.
- **350**: any consumer expecting a `TemporalPred`-valued `endChar k` must instead consume the
  `VecEA2 1`-valued bracket carrier and take the `TemporalPred` **only at the top-level
  one-free-variable extraction** (Prop 3.5 / Theorem 4.4, `md:185`). Re-plan around the two-anchor
  correctness signature `BracketCarrierCorrect`.
- **309** (Kamp completeness parent): the FOMLO→TL translation should perform the single-point
  collapse **once**, at the end (Theorem 4.4, `md:187`), on the one-free-variable result — not per
  recursion step. The recursion stays Prop-valued/two-endpoint. This aligns 309's architecture with
  the paper's Prop 3.5 / Prop 4.2 / §5 division of labor.

---

## 6. Conflicts with prior reports (paper is authority)

- **Report 05 (§0, §3.1–3.2) — CONFLICT.** Report 05 reads the paper's free-variable discipline
  **correctly** (its §1 reconstruction and §4 table match `md:119/137/165/219`), but then **preserves
  the single-point `EndCharCarrier := … → TemporalPred`** and rescues it with `h_res`, calling `h_res`
  "the ≤2-free-anchor discipline made concrete." **Per the paper this is wrong**: Rabinovich keeps
  `z1` as an **explicit free variable** of a Prop (`md:219`), not as an externally-pinned residual on
  a single-point object. Report 05's own §5 row 6 flags "residual-threading" as an unproven gate; the
  paper explains **why it cannot be threaded** — there is no such construct in Rabinovich, and the
  in-tree `endCharN0_correct_infeasible` proves the single-world base impossible. Report 05's rescue
  is a continuation of the divergence, and the 4th strike (`navPieceForm_correct`) is its predicted
  failure. **Flag: report 05's architectural conclusion (keep single-point carrier + `h_res`)
  contradicts the paper; its paper reconstruction is sound.**
- **Report 02 (§Q4 target 1) — SUPERSEDED-BY-PAPER.** Report 02 correctly identifies the root as
  single-anchor-vs-multi-anchor and recommends a `Formula`-valued **multi-anchor navigating
  characteristic** (`navMultiAnchorForm`, hooks = full eval). Report 04 machine-refuted that (still a
  closed converter fixed before anchors). The paper shows why: the fix is **not** a cleverer
  `Formula`-valued converter but a **Prop-valued two-endpoint carrier** (`md:219`) — report 02's own
  §Q4 target 4 (apply Lemma 3.2(2) and stay Prop-valued at arity ≤3) is the faithful branch; targets
  1–2 are not. **Flag: report 02 targets 1–2 diverge; target 4 + the `nf_zone_flatten_navigable`
  template (its own H3 table, "Faithful") is correct.**
- **Report 01 (arity-general single-anchor closes, Medium-High) — REFUTED** by report 02's H4 and by
  the paper (a single-point object cannot certify a 2-free-variable target, `md:137` vs `md:219`).
- **Report 03 + `CarrierK1V.lean:19–53` — CONFIRMED by the paper.** Their conclusion (single-point
  carrier has no Rabinovich counterpart; the faithful carrier is the two-anchor
  bracket/`VecEA2 1`) is exactly what the primary source supports. This report **endorses and
  re-grounds** it against `md:119/137/165/219/225/451`.
- **"Report 06" — DOES NOT EXIST.** The delegation asked to cross-reference `01/02/04/05/06`; the
  reports directory contains only `01–05`. Flagged so the omission is not mistaken for an oversight.

---

## 7. Adversarial self-verification (H4)

### 7.1 Claim Verification Table

| # | Claim | Source / Counterexample | Verification method | Confidence |
|---|---|---|---|---|
| 1 | Prop 3.5 collapse precondition is **exactly one** free variable | `md:137` "Every `∨→∃∀`-formula with one free variable is equivalent to a `TL` formula" | literature read (direct quote) | High |
| 2 | §5 negation/navigation operates at **two** free variables, keeping `z0,z1` explicit | `md:165` (Prop 4.2 "at most two free variables"); `md:219` (`[…](z0,z1)`); `md:225` (`On(…,z0,z1)`) | literature read | High |
| 3 | A `k`-anchor object is a **conjunction of adjacent 2-endpoint pieces**, never a one-point read | `md:451` (Def 7.13); `md:297–299` (Fig 1 `B2`) | literature read | High |
| 4 | Navigation re-anchors an endpoint (`z0 ↦ r0`), `r0` existentially bound; no third free variable | `md:233–247` (Lemma 5.3 Case 2/3) | literature read | High |
| 5 | Rabinovich has **no** per-object anchor-predicate residual; only `α0(z0)` at one origin | `md:263`, `md:285` (Case 1) — absence of any such construct across §5/§7 | literature read (absence) | Medium-High |
| 6 | `EndCharCarrier := … → TemporalPred` is a single-world map (arity-3, 2 anchors beyond `w`) | Base.lean:1007; `TemporalPred.eval_at tp w` is a function of `w` only | source read of type signature (`lean_local_search` hit + Explore extraction) | High |
| 7 | No single-world base can inhabit the frozen target (machine-proved, not analytic) | `endCharN0_correct_infeasible` (concrete 2-point countermodel ⇒ `False`); `endCharN0_correct_world_local_obstruction` (report 03 Root Cause; axioms `[propext, Classical.choice, Quot.sound]`) | source read of green negative-guardrail theorems | High |
| 8 | `navPieceForm_correct` target = closed formula at one `w` ↔ arity-4 (anchors `x,t`) object | NavigatedEndChar.lean:510–512 stuck goal; `navPieceForm : … → Formula` (line 196) | source read of frozen goal + def signature | High |
| 9 | Faithful two-anchor carrier `BracketEndCharCarrier` exists and is green at `k=0`, `x,t` explicit | CarrierK1V.lean:52/62/73/87 (`bracketEndChar_k0(_correct)`, `BracketCarrierCorrect`) | source read of def + theorem signatures | High |
| 10 | `nf_zone_flatten_navigable_correct` carries `x,t` explicitly on both sides (= faithful `[…](z0,z1)`) | Base.lean:687 (five-zone Prop, `x t` explicit params) | source read of def/theorem signature | High |
| 11 | `nfEval_le2_reduction` faithfully realizes Lemma 3.2(2) (arity-`n` → anchor-arity ≤3 conjuncts) | Lemma32Reduction.lean:535 (GREEN, `induction k`); docstring cites `md:119` | source read of theorem signature + proof body | High |
| 12 | `h_res` has no Rabinovich analogue (it is a Lean artifact of the single-point carrier) | claim #5 (absence) + the fact `h_res` pins positions 1,2 of `zoneEnv3 w x t` (NavigatedEndChar.lean:263–270) | analytic composition of #5 + source read | Medium-High |
| 13 | The 4 strikes are the same non-theorem (carrier-type defect, not converter-internal) | reports 01/02/04/05 all keep `→ TemporalPred`; each patches the anchor layer differently; #7 shows the wall is type-level | analytic (cross-report) + #6/#7 | Medium-High |

### 7.2 Contradiction log

- **Report 05 "keep single-point carrier + `h_res` is faithful" vs paper "carrier is 2-endpoint
  Prop; no residual analogue".** Precedence: **primary source > prior report analysis** (H3 tier-1
  authority) **and machine-checked green asset > analysis**. Resolution: report 05's *paper
  reconstruction* is retained (it is correct); its *architectural conclusion* is **rejected** — the
  paper (`md:219` vs `md:137`) plus the in-tree machine refutation (`endCharN0_correct_infeasible`)
  show `h_res` cannot substitute for an explicit second free variable. **Resolved, no residual
  ambiguity.**
- **Report 02 targets 1–2 (Formula-valued multi-anchor converter) vs report 04 refutation vs paper.**
  Precedence: machine-checked refutation (report 04) + paper. Resolution: the faithful branch is
  report 02's **target 4** (stay Prop-valued, arity ≤3 via Lemma 3.2(2)) — consistent with the paper
  and with `BracketEndCharCarrier`. **Resolved.**
- **No UNRESOLVED contradictions.** Every load-bearing claim is grounded in a specific `md:` line or
  a named green Lean asset (§7.1). No claim rests on instinct.

### 7.3 Forbidden-output check

No "mathlib likely has this" (every claim cites `md:NNN` or `file.lean:line`, read this session). No
`sorry`/vacuous/axiom recommendation. No single-anchor-reshape recommendation (that is the refuted
line). The recommendation is a concrete carrier-type change to an **already-green, in-tree** asset
(`BracketEndCharCarrier`), not a deferral or new bridge to spawn.

### 7.4 Recommendations modified after verification

- Elevated from "report 05's `h_res` is the fix" to **"`h_res` is the artifact; the carrier type is
  the defect"** after grounding `md:219` (explicit `z1`) against the single-point carrier and the
  machine refutation #7.
- Confirmed `nfEval_le2_reduction`, `nf_zone_flatten_navigable(_correct)`, `seg`, `bracketBuild*`,
  `endChar0`/`nf_3var_bracket_xyt` are **preserved** (faithful pieces); only the single-point
  **carrier/converter wrapper** (`EndCharCarrier → TemporalPred`, `navPieceForm(_correct)`) is
  retired.

---

## 8. Memory candidates

1. *(lean4, Kamp/Rabinovich)* Rabinovich 2014 enforces a strict free-variable discipline: Lemma
   3.2(2) reduces to a conjunction of ≤2-free pieces (`md:119`); Prop 4.2/§5 does negation/navigation
   **only at 2** free variables, keeping both endpoints `(z0,z1)` explicit as a **Prop**
   (`md:165/219/225`); Prop 3.5 collapses to a single-point temporal formula **only at 1** free
   variable (`md:137`). A Lean recursion carrier that is `TemporalPred`-valued (single-world) at
   anchor-arity ≥2 collapses at the wrong free-variable count and is a non-theorem
   (machine-refutable). The faithful carrier is Prop-valued with anchors explicit
   (`VecEA2`/`nf_zone_flatten_navigable`).
2. *(lean4, audit method)* A recurring obstruction that survives every converter re-architecture but
   lives in the **carrier's type** is diagnosable by asking: does the produced object's arity of free
   dependence (here: a function of `w` only) match the target's (here: `w,x,t`)? If a residual
   hypothesis (`h_res`) is introduced solely to pin the mismatched free variables, the residual is
   the artifact and the type is the defect — check for a machine-checked infeasibility guardrail
   (`endCharN0_correct_infeasible`) before attempting another converter.
3. *(lean4, Rabinovich §7)* Def 7.13 (`md:451`) is the sharpest witness that a many-anchor object is a
   **conjunction of adjacent 2-endpoint pieces**, never a one-point read — the go-to citation when a
   formalization proposes reading a ≥2-free-variable characteristic at a single world.

---

## 9. Verification status

- Reference tier: **Tier 1** applied; 5-column-equivalent faithfulness map present (§3), all rows
  cited to `md:` or `file.lean:line`.
- Adversarial verification (H4): **triggered**; Claim Verification Table (13 rows) + Contradiction
  Log + Forbidden-output check (§7). No unresolved contradiction.
- H5 divergence audit: root cause = single-point carrier type applying the Prop-3.5 collapse at 2
  free variables; the 4 strikes are one non-theorem re-patched. Corrected lean-ready target = adopt
  `BracketEndCharCarrier` (CarrierK1V.lean:52), retire `navPieceForm_correct`.
- Zero-debt: no `sorry`/axiom recommended; the retired line is marked `[BLOCKED]`/superseded, not
  stubbed.
</content>
</invoke>
