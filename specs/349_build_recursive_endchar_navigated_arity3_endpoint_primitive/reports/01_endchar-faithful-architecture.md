# Report 01 — Faithful Rabinovich Architecture for `endChar` (task 349, H5 divergence audit)

- **Task**: 349 — Build the recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Type**: lean4 (hard-mode; H2 anti-analysis, H3 reference grounding, H4 adversarial self-verification, H5 divergence audit)
- **Session**: sess_1783821765_1e384b
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, Cor 5.4 §5; `--lit` active)
- **Sources source-read this session**:
  - Rabinovich 2014 md:199-335 (Lemma 5.1, Lemma 5.3, **Cor 5.4 and its inductive step md:255-271**), md:130-163
  - task-309 `reports/02_endpoint-hook-discharge-research.md` (§1.4, §4, §6)
  - task-349 `plans/01_recursive-endchar-primitive.md`, `handoffs/phase-2-handoff-20260712T015821Z.md`
  - `Base.lean`: `endChar0`/`endChar0_correct` (995/1056), `EndCharCarrier` (1007), `nf3_locus0` (982),
    `seg`/`seg_holds_correct`/`seg_holds_coupled` (1127/1136/1150), `nf_zone_flatten_navigable(_correct)`
    (667/687), `nf_zone_flatten_navigable_brick` (813), `nf_char3_endpoint_tl`/`_correct` (869/885),
    `nf_eval_nf_step_unfold` (1488)
  - `NormalForm.lean:134-159` (the `NormalForm` type definition — decisive)

---

## VERDICT

**The impossibility claim is CONFIRMED-BUT-MISDIRECTED. It refutes the frozen CONTRACT, not the task.**

1. There is **no faithful `NormalForm sig k 4 → NormalForm sig k 3` collapse** — the implementer is
   correct, and this is now proven at the *type-definition* level (not merely by grep).
2. **Rabinovich never performs such a collapse.** Cor 5.4 (md:255-271) is *navigational*: it carries
   the inner suffix-characteristic `F_i` verbatim as the right operand of an `Until` modality
   (`F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`) — the inner characteristic is a **parametric hook threaded
   through the recursion**, never arity-reduced. So the collapse the blocker proved impossible is a
   **strawman**: the faithful construction does not need it.
3. The genuine divergence is that the task-349 contract — *pure `Nat.rec` on `k` with the frozen
   arity-3 carrier `EndCharCarrier sig k = NormalForm sig k 3 → TemporalPred`* — is **mathematically
   ill-typed** for a depth-`k` recursion, because `NormalForm`'s own definition increments arity at
   every depth step. The frozen carrier, not the mathematics, is the blocker.
4. **A faithful, buildable, guard-respecting construction exists**: an **arity-general internal
   recursion** on `k` in which each depth step flattens the arity-`(n+1)` inner existential with the
   **navigable brick** (Rabinovich's `β_i Until F_i`), keeping every deeper witness a *bracket*
   witness so the **free-anchor count stays ≤ 2** while the *env arity* legitimately climbs. The
   consumer-facing `endChar : NormalForm sig k 3 → TemporalPred` (arity 3) is preserved as the
   arity-3 instance of the general helper, so `EndCharCarrier` need not change at the interface.

**Recommendation: `/revise 349`** to (a) replace the *pure-arity-3-`Nat.rec`* internal recursion with
an **arity-general helper** `endCharRec`, (b) rescope Phases 2-3 from "arity-4→3 collapse bridge"
(a non-object) to "**arity-general navigable brick** + arity-general atom base + arity-general endpoint
builder", and (c) keep `endChar0` (base) and `seg` (β_i segment) verbatim. Do **not** adopt the
handoff's Option 3 (hook-parametric `endChar`) *as the primitive*: it is green but **non-convergent**
— it re-defers `innerConv` to the caller, repeating the 4-strike churn report 02 diagnosed.

---

## 1. The decisive type-level fact (why the frozen carrier is ill-typed)

`NormalForm.lean:134-136`:

```lean
def NormalForm (sig : MonadicSignature) : Nat → Nat → Type
  | 0,     n => AtomKind sig n → Bool
  | k + 1, n => (AtomKind sig n → Bool) × (NormalForm sig k (n + 1) → Bool)
```

The quantifier component of a depth-`(k+1)` arity-`n` normal form is
`.2 : NormalForm sig k (n + 1) → Bool` (`NormalForm.quant_assgn`, :157-159). **The modal-depth step
increments the arity by exactly one.** Therefore `nf_eval_nf_step_unfold` (Base.lean:1488, `Iff.rfl`)
unfolds

```lean
nf_eval_nf M (k+1) 3 (zoneEnv3 w a b) qnf ↔
  (∀ atom, atom_eval M (zoneEnv3 w a b) atom ↔ qnf.1 atom = true) ∧
  (∀ sub : NormalForm sig k 4,                       -- ARITY 4, by the NormalForm definition
     (∃ w', nf_eval_nf M k 4 (Fin.cons w' (zoneEnv3 w a b)) sub) ↔ qnf.2 sub = true)
```

A depth-`k` recursion carrier fixed at arity 3 (`EndCharCarrier sig k`) **cannot** consume `sub` at
arity 4. This is not a tactic gap and not an accident of the assets — it is forced by the type of
`NormalForm`. **The recursion is arity-general by definition.** The 349 plan's Phase 2 tried to bridge
this with a truth-preserving `NormalForm sig k 4 → NormalForm sig k 3` collapse; no such term exists
(the arity-4 evaluation `[w',w,a,b]` constrains four positions + their order; arity-3 encodes three) —
the implementer's impossibility proof is **correct**. The error is upstream: **do not collapse; carry
the higher arity and navigate.**

## 2. What Rabinovich actually does (Cor 5.4 — navigate, never collapse)

Corollary 5.4 (md:255-271). Define the chain by **downward recursion on the chain index**:

```
F_n := α_n
F_{i-1} := α_{i-1} ∧ (β_i Until F_i)
```

and (md:263) `∃ z ∈ (z0,z1). [α0,β1,α1,…,αn](z0,z)` iff `F0(z0)` and there is an increasing sequence
`x1 < … < xn` in `(z0,z1)` with `Fi(xi)`. Inductive step `n ↦ n+1` (md:267-271): from
`F0(z0)` and a sequence `x1<…<x_{n+1}`, the IH gives `y1 ∈ (z0, x_{n+1})` with
`[α0,β1,…,(αn ∧ β_{n+1} Until α_{n+1})](z0, y1)`; `y1` then satisfies `αn ∧ β_{n+1} Until α_{n+1}`,
so there is `y2 > y1` with `α_{n+1}(y2)` and `β_{n+1}` holding along `(y1,y2)`.

**Two faithfulness facts read directly off the source:**

- **The inner characteristic `F_i` is carried verbatim as the right operand of `Until`** — it is a
  *parameter of the enclosing modality*, never reduced to a lower-arity object. This is exactly the
  hook shape the Lean assets already use: `nf_zone_flatten_navigable`'s `pastEnd`/`futureEnd`
  (Base.lean:670) and `nf_char3_endpoint_tl`'s `innerConv` (Base.lean:871). **Rabinovich's method is
  hook-carrying / navigational, not collapsing.** (Answers central question 1.)
- **The ≤2-free-variable cap is maintained *because of* the navigation, not despite it.** The
  witnesses `x1<…<xn` are *never simultaneously free*: each is introduced one at a time as a *bound*
  point of an `Until`, with only `z0` and the current point free (Notation 5.2, md:219; the whole
  purpose of Cor 5.4 is to re-express an `n`-witness `∃∀` block — naively `n` free variables — with
  ≤2 free variables via nested `Until`). The **env arity of the Lean NF ≠ the free-anchor count**:
  env positions beyond the 2 anchors are *bracket witnesses* bound by the enclosing `Until`/`Since`.

**Consequence for report 02 §1.4.** Report 02 phrased the primitive as "recursion on `k`, **arity
capped at 3**". That conflates *env arity* (which legitimately climbs with modal depth — §1) with
*free-anchor count* (which is the real Rabinovich ≤2 cap, G4). The corrected primitive is **arity
GENERAL, free-anchors ≤2**. The "arity capped at 3" phrasing is the seed the 349 contract inherited
and froze into `EndCharCarrier`.

## 3. The faithful, buildable architecture (exact Lean shapes)

Recursion on modal depth `k`; the arity index `n` is a *free parameter of the motive* that climbs
`3 → 3+k` toward the base. No `Nat.rec` on a fixed-arity carrier; instead `Nat.rec` with a Π-motive
`(n : Nat) → NormalForm sig k n → TemporalPred`.

### 3.1 Definition (internal helper; consumer interface unchanged)

```lean
-- generalize endChar0 / nf3_locus0 to arbitrary arity (pure depth-0 atom layer)
noncomputable def endCharN0 (atomMap) (h_surj) : {n : Nat} → NormalForm sig 0 n → TemporalPred

-- generalize nf_char3_endpoint_tl to arbitrary arity n (currently hardcodes zoneEnv3 / arity 3)
noncomputable def nf_endpoint_tl_gen (atomPart : Formula)
    (innerConv : NormalForm sig k (n+1) → Formula) (q : NormalForm sig (k+1) n) : TemporalPred

-- the arity-general recursion on k (arity index n climbs at each step)
noncomputable def endCharRec (atomMap) (h_surj) :
    (k : Nat) → {n : Nat} → NormalForm sig k n → TemporalPred
  | 0,     n, qnf => endCharN0 atomMap h_surj qnf
  | k + 1, n, qnf =>
      nf_endpoint_tl_gen
        (atomPartN atomMap h_surj qnf.1)                     -- arity-n atom layer at the anchors
        (fun sub => (navBrickForm (endCharRec k (n+1)) sub)) -- innerConv = brick over the IH at arity n+1
        qnf

-- consumer-facing entry (frozen EndCharCarrier PRESERVED as the arity-3 instance)
noncomputable def endChar (k : Nat) : EndCharCarrier sig k := fun qnf => endCharRec atomMap h_surj k qnf
```

`navBrickForm (rec : NormalForm sig k (n+1) → TemporalPred) sub` is the **arity-general navigable
brick** applied to `sub`: it flattens `∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub` into the
five navigated zones (`nf_zone_flatten_navigable` generalized from arity 3 to arity `n+1`), using
`rec` = the depth-`k` IH as `pastEnd`/`futureEnd`, keeping `w'` a **bracket** witness. **This is the
genuinely-new load-bearing object** (the arity-3 brick exists at Base.lean:667/813; the arity-`(n+1)`
brick does not) — the "~300-500 line core" report 02 §4.2 predicted, and it is a *generalization of an
already-green proof*, not new mathematics.

### 3.2 Correctness (the exact statement that threads `k→k+1` and bottoms at `k=0`)

```lean
theorem endCharRec_correct (M) (atomMap) (h_surj) :
    ∀ (k : Nat) {n : Nat} (qnf : NormalForm sig k n)
      (env : Fin n → M.carrier)
      (h_nav : NavResidual M env),          -- generalizes endChar0_correct's h_res (§3.3)
    (endCharRec atomMap h_surj k qnf).eval_at M atomMap (env 0) ↔
      nf_eval_nf M k n env qnf
```

- **Base `k = 0`**: `endCharN0`-correctness = generalized `endChar0_correct` (Base.lean:1056). The
  `w`-locus predicate layer is read locally; the anchor/order layer at the other `n-1` positions is
  the residual `h_nav` (the arity-general `h_res`). Sorry-free by the existing `endChar0_correct`
  method, generalized over `n`.
- **Step `k+1`**: `nf_endpoint_tl_gen`-correctness = generalized `nf_char3_endpoint_tl_correct`
  (Base.lean:885). Its `h_atom` is the atom layer; its **`h_inner`** — for each
  `sub : NormalForm sig k (n+1)`, `temporal_truth (env 0) (innerConv sub) ↔
  ∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub` — is discharged by the **brick**
  (`nf_zone_flatten_navigable_correct` generalized to arity `n+1`), whose own `h_past`/`h_fut` hooks
  **are exactly `endCharRec_correct k (n+1)`** — the IH at the incremented arity. The bounded-interior
  zone rides `seg` via `seg_holds_coupled` (Base.lean:1150). **This closes: the IH is consumed at the
  arity the step produces.**

### 3.3 Why this respects every guard (the ≤2-free-anchor invariant, adversarially checked)

The brick navigates `w'` relative to the **2 active anchors** of the current step; the other `n-1`
env positions are *frozen bracket witnesses* from the enclosing navigation (Rabinovich introduces
witnesses outermost-first via nested `Until`; the Lean modal nesting matches). Hence:

- **G1** (no arity-1 collapse): the atom layer is honest arity-`n`; no flat arity-1 term.
- **G2/G4** (free anchors ⊆ {x,t}, ≤2; `w` never a third free anchor): the *formula* `endCharRec k n
  qnf` has ≤2 free anchors; every `w'` and every deeper env position is a **bracket witness** bound by
  an `Until`/`Since`. Env arity climbing to `3+k` is *witness depth*, not free anchors — this is the
  distinction §2 establishes and the type-definition (§1) forces.
- **G3** (non-trivial segment): the bounded interior uses `seg` (Base.lean:1127), interval type
  `endChar qnf` (never `TemporalPred.top`).
- **G5** (manual bridges): `h_inner` discharge is the manual `constructor`/`intro` composition already
  used in `seg_holds_coupled` (Base.lean:1157-1162) and `nf_zone_flatten_navigable_correct`
  (Base.lean:700-706); no `simp`/`omega`/`aesop` shortcut of a chain step.
- **FORBIDDEN `nf_char3_deeper_split`**: **not used**. It grows the anchor set to `{y,x,t}` (report 02
  §4.1); the brick instead keeps `w'` a bracket witness. This is the whole point of choosing the brick.

## 4. H3 Lemma-Mapping Table (Tier 1, Rabinovich 2014)

| Paper concept (Rabinovich 2014) | Paper location | Lean identifier | Lean location | Status |
|---|---|---|---|---|
| `F_i` chain, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` — inner char carried as `Until` hook, **no collapse** | md:255-263 | `nf_char3_endpoint_tl` (hook `innerConv`) / `nf_zone_flatten_navigable` (hooks `pastEnd`/`futureEnd`) | Base.lean:869 / 667 | **Available** (arity-3 only); step relies on these hook shapes |
| Cor 5.4 inductive step `n↦n+1`: navigate one witness via nested `Until`, ≤2 free vars | md:267-271 | brick-flatten of `∃w'` keeping `w'` a bracket witness | (target) `navBrickForm` = arity-general `nf_zone_flatten_navigable` | **TO BUILD** (arity-`(n+1)` generalization of Base.lean:667/687) |
| `β_i` non-trivial interior segment holding along `(x_i, x_{i+1})` | md:255-271, md:154-157 | `seg` / `seg_holds_correct` / `seg_holds_coupled` | Base.lean:1127 / 1136 / 1150 | **Available**, consume verbatim (G3) |
| `F_n := α_n` base of the chain recursion | md:255 | `endChar0` / `endChar0_correct` (via `h_res` residual) | Base.lean:995 / 1056 | **Available**; generalize to arity `n` → `endCharN0` |
| depth-`(k+1)` arity-`n` evaluation unfolds to atom layer + arity-`(n+1)` inner `∃w'` | (Lean type fact) | `nf_eval_nf_step_unfold`; `NormalForm` def | Base.lean:1488; NormalForm.lean:134 | **Available** (`Iff.rfl`); the type-level proof arity climbs (§1) |
| ≤2 free-variable cap (Notation 5.2); witnesses bound one-at-a-time | md:219, md:130 | guard G2/G4; `zoneEnv3_arity_invariant` | Base.lean:545 (cited) | Binding invariant; **held by navigation, not by arity-3 freeze** |
| **The recursive navigated endpoint primitive** (report 02 §1.4, *corrected to arity-general*) | md:255-271 | `endCharRec` / `endCharRec_correct` (+ arity-3 entry `endChar`) | (target) Base.lean additive | **TO BUILD** — §3; the deliverable |

## 5. H5 Divergence Audit

### 5.1 Divergence table

| Target (single) | Churn count | Last-attempted approach | Failure reason |
|---|---|---|---|
| off-diagonal navigated arity-3 endpoint char / `(x,t)` coupling | strike 1-4 (per report 02 §5) | 305 P11b projection, 307 P3/P7, 309 P6 — hook-parametric deferral | deferred the coupling one interface out each time |
| same, as "recursive endChar primitive" | strike 5 (309 revise → task 349) | 349 P1 green (`nf_eval_nf_step_unfold`); P2 declared **structurally impossible** | tried arity-4→3 **collapse**; correct but *misdirected* — collapse is a non-object AND not what Rabinovich does |

Churn on this target is now **5 strikes**. This report is the dedicated H5 audit dispatch for strike 5.

### 5.2 Root cause of the strike-5 divergence

Two *correct* local facts were composed into a *wrong* global conclusion:

1. (True) No faithful `NormalForm sig k 4 → NormalForm sig k 3` collapse exists.
2. (True) `nf_char3_deeper_split` is forbidden (grows anchors).
3. (False conclusion) "Therefore the recursive primitive is structurally impossible."

The missing premise: **Rabinovich never collapses** (§2) — the arity-`(n+1)` inner existential is
*flattened by navigation* (the brick), not collapsed. The 349 plan mis-scoped Phase 2 as an
"arity-4→3 brick-witness-collapse bridge" — a self-contradiction (the brick *flattens*, it does not
*collapse*; Base.lean:804 even says the residuals are "**never arity-collapsed**"). The frozen arity-3
`EndCharCarrier` (inherited from report 02 §1.4's "arity capped at 3" phrasing, §2) made the correct
navigational recursion untypable, so the implementer — correctly unable to type it — concluded
impossibility. **The contract, not the mathematics, is the blocker.**

### 5.3 Sorry inventory (task-349 live path)

| Identifier | Current state | Type / obligation | Why stuck |
|---|---|---|---|
| `endChar` / `endChar_correct` | **not defined** (349 P2 [BLOCKED]) | `NormalForm sig k 3 → TemporalPred` by pure `Nat.rec` | contract froze arity 3; depth recursion needs arity general (§1) |
| `endCharRec` / `endCharRec_correct` | not yet designed | arity-general recursion on `k` | the corrected target (§3); this report supplies the signature |
| `nf_eval_nf_step_unfold` (Base.lean:1488) | **green, sorry-free** | `Iff.rfl` step-unfold | stable citation point; no change needed |

No `sorry` was landed (349 P1 is green; P2 correctly refused a vacuous/`sorry` placeholder — good).

### 5.4 Type-mismatch analysis

| Consumer/step needs | Existing supplier gives | Mismatch → resolution |
|---|---|---|
| step consumes `sub : NormalForm sig k 4` from `qnf : NormalForm sig (k+1) 3` `.2` | frozen carrier `NormalForm sig k 3 → TemporalPred` (arity 3) | arity 4 vs 3 → **arity-general carrier** `endCharRec k {n}` (§3.1) |
| `h_inner`: char of `∃w', nf_eval_nf M k 4 (Fin.cons w' env) sub` | arity-3 brick `nf_zone_flatten_navigable` (Base.lean:667) | arity 3 vs 4 → **arity-`(n+1)` brick** `navBrickForm` (§3.1) |
| brick `h_past`/`h_fut` at arity `n+1` | — | discharged by **IH `endCharRec_correct k (n+1)`** (§3.2) — closes the recursion |
| anchor/order layer at the `n-1` non-witness positions | `endChar0`'s `h_res` (arity 3) | arity 3 vs `n` → **arity-general `NavResidual`/`h_nav`** (§3.3), generalizing `h_res` |

### 5.5 Corrected lean-ready targets (exact signatures the next dispatch should attempt)

1. `endCharN0 : {n} → NormalForm sig 0 n → TemporalPred` + `_correct` (generalize `endChar0`/`nf3_locus0`/`endChar0_correct` over `n`).
2. `nf_endpoint_tl_gen` + `_correct` (generalize `nf_char3_endpoint_tl`/`_correct` from `zoneEnv3`/arity-3 to arity-`n`).
3. `navBrickForm` = arity-`(n+1)` `nf_zone_flatten_navigable` + `_correct` (**the load-bearing new core**; generalize Base.lean:667/687, keep `w'` a bracket witness, ≤2 active anchors).
4. `endCharRec : (k) → {n} → NormalForm sig k n → TemporalPred` via `Nat.rec` with Π-motive; `endCharRec_correct` by induction on `k` (base = 1, step = 2 with `h_inner` discharged by 3 + `seg_holds_coupled`, IH at arity `n+1`).
5. `endChar (k) : EndCharCarrier sig k := endCharRec … k` — **the frozen arity-3 interface, preserved** as the arity-3 instance; downstream (309 hooks `h_quant`/`h_past`/`h_fut`/`h_diag`) cite this unchanged.

---

## Adversarial Self-Verification (H4)

Claim Verification Bar applied to every load-bearing claim. `Verification Method` uses lean4 domain
values (`source read of type/signature`, `literature read`, `Iff.rfl type fact`).

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `NormalForm sig (k+1) n` `.2` is at arity `n+1` (depth step increments arity) | NormalForm.lean:134-136, :157-159 | source read of type definition | High |
| Step-unfold produces arity-4 inner `∃w'` from arity-3 `qnf` | Base.lean:1488-1497 (`Iff.rfl`) | Iff.rfl type fact | High |
| No faithful `NormalForm sig k 4 → NormalForm sig k 3` collapse (impossibility CONFIRMED) | 349 plan P2; forced by §1 type fact (arity-4 constrains 4 positions+order) | source read + type reasoning | High |
| Rabinovich carries `F_i` as an `Until` hook, never collapses arity | Rabinovich md:255-263, 267-271 | literature read | High |
| ≤2 free-var cap is *navigational* (witnesses bound one-at-a-time), distinct from env arity | Rabinovich md:219 (Notation 5.2), md:130; NormalForm.lean:134 | literature + source read | High |
| Existing Lean assets already use the hook shape (`innerConv`, `pastEnd`/`futureEnd`) | Base.lean:871, 670 | source read of signature | High |
| `nf_char3_endpoint_tl_correct.h_inner` is exactly the arity-4 inner obligation of the step | Base.lean:893-895 vs 1494-1495 | source read of both signatures | High |
| Brick `h_past`/`h_fut` = the IH one depth down (arity-3 case) | Base.lean:692-697 (docstring: "the recursion IH at k≥1, the Phase-1 base at k=0") | source read | High |
| Arity-general recursion CLOSES: step's `h_inner` discharged by IH at arity `n+1` via the brick | §3.2 synthesis; brick's hooks = IH shape (row above), generalized over `n` | analytic composition of source-read signatures | Medium-High |
| Env arity climbs to `3+k` at base; base is a pure depth-0 atom layer (finite, no tower) | NormalForm.lean:134 (depth-0 = `AtomKind sig n → Bool`); `endChar0`/`endCharN0` | source read | High |
| ≤2 free anchors held at the *formula* level despite climbing env arity | `zoneEnv3_arity_invariant` (Base.lean:545, cited); Rabinovich md:219 | source read + literature | Medium-High |
| Consumer `EndCharCarrier` (arity 3) preserved as arity-3 instance of `endCharRec` | `EndCharCarrier` (Base.lean:1007) is a type abbrev = `NormalForm sig k 3 → TemporalPred` | source read | High |
| Handoff Option 3 (hook-parametric `endChar`) is non-convergent (re-defers `innerConv`) | report 02 §5 (4-strike deferral pattern); handoff Option 3 text | literature read + reasoning | Medium-High |
| `navBrickForm` (arity-`n+1` brick) is genuinely new (arity-3 brick exists, arity-4+ does not) | Base.lean:667/813 (arity 3); 349 plan P2 grep (no arity-4 flatten) | source read + grep cross-ref | High |
| The arity-general generalization is buildable (generalize green proofs, not new math) | `endChar0_correct`, `nf_char3_endpoint_tl_correct`, `nf_zone_flatten_navigable_correct` all sorry-free | source read | Medium |

**Adversarial challenge to the recommended signature (does it thread `k→k+1` and bottom at `k=0`?).**
Attempted refutation: "the arity climbs unboundedly → non-terminating tower." *Refuted*: recursion is
structural on `k` (strictly decreasing); `n` is a motive parameter that climbs to a *finite* `3+k` at
the base `k=0`, where `NormalForm sig 0 n = AtomKind sig n → Bool` is a pure atom layer with no further
recursion. Termination is on `k` alone; `n` never blocks it. Second challenge: "the brick needs an
arity-4 char, which needs arity-5, …". *Refuted*: the brick is a *within-depth-`k`* flatten of the
`∃w'` witness; its endpoint hooks are `endCharRec k (n+1)` — same depth `k`, one higher arity — and
that is discharged by the **induction hypothesis at `(k, n+1)`**, already available in a `k`-induction.
No fresh depth descent inside the brick. The recursion closes. Third challenge: "≤2 cap violated by
the climbing env arity". *Refuted* by the env-arity-vs-free-anchor distinction (§2, §3.3), which is
forced by the `NormalForm` type itself (§1) and matches Rabinovich's one-witness-at-a-time navigation.

**Contradiction Log.**
- *349 plan/handoff "structurally impossible" vs. this report "buildable".* **Resolved** by precedence
  "actual Lean type > prose blocker note": the impossibility is *narrowly true for the collapse* but
  the collapse is not the faithful route (Rabinovich navigates, §2). No contradiction on the collapse
  fact; the divergence is the unstated premise that a depth-`k` recursion must stay arity-3 — refuted
  by NormalForm.lean:134. Downstream risk if ignored: a 6th strike re-attempting collapse or
  re-deferring via Option 3.
- *report 02 §1.4 "arity capped at 3" vs. this report "arity general".* **Resolved**: §1.4 conflated
  env arity with free-anchor count; the Rabinovich ≤2 cap is on free anchors (md:219), which the
  arity-general construction respects. report 02's *mechanism* (brick + non-trivial segment) is
  correct and adopted verbatim; only its arity phrasing is corrected.

**Forbidden-output check.** No "mathlib likely has this" (codebase-internal; every asset cited with
`file:line`, all source-read this session). No `sorry`-deferral, no vacuous-`def`, no axiom
introduction recommended — the recommendation is a concrete sorry-free construction with axioms pinned
to `[propext, Classical.choice, Quot.sound]`. `nf_char3_deeper_split` explicitly avoided (brick
instead). Guards G1-G5 carried and checked (§3.3).

**Recommendations modified after verification.** The handoff's **Option 3 (hook-parametric `endChar`)
is downgraded from "the only green path" to "green but non-convergent — do NOT adopt as the
primitive"**: it re-defers `innerConv` to the caller, which is the exact 4-strike deferral report 02
diagnosed. The convergent path is the arity-general closed recursion (§3), which *discharges*
`innerConv` internally via the brick + IH. The 349 plan's Phase 2/3 framing ("arity-4→3 collapse
bridge") is **refuted and corrected** to "arity-general navigable brick" (§5.5).

---

## Memory Candidates

1. *(lean4, Kamp/Rabinovich)* In this `NormalForm` encoding, the modal-depth recursion **increments
   env arity by one at each step** (`NormalForm sig (k+1) n`.2 : `NormalForm sig k (n+1) → Bool`,
   NormalForm.lean:134). A depth-`k` recursion carrier fixed at a single arity is therefore ill-typed;
   navigated-endpoint recursions must be **arity-general**, with the free-anchor count (not the env
   arity) held ≤2 by the navigable brick. Distinguish *env arity* (witness depth) from *free-anchor
   count* (the Rabinovich ≤2 cap).
2. *(lean4, proof architecture)* Rabinovich Cor 5.4 is **navigational, not collapsing**: the inner
   suffix-characteristic `F_i` is carried verbatim as an `Until` hook. A blocker that proves "arity-`m`
   → arity-`m-1` collapse is impossible" is a **strawman** if the faithful source navigates — check the
   source's recursion shape (hook-carrying vs. reducing) before declaring structural impossibility.
