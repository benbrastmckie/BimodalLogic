# Task 376 — Intended Model Class: is (ℚ,<) in classical Kamp's target class?

**Session**: sess_1784138518_4af6d5 · **Agent**: lean-research-hard-agent (H2/H3/H4) · **Date**: 2026-07-15
**Mode**: lean4 `--hard --lit` · reference grounding **Tier 1** (literature-backed)
**Focus**: intended model class — is `(ℚ,<)` in classical Kamp's target class?
**Machine artifact**: `specs/376_arity_general_zone_decomposed_char_engine/reports/04_intended-model-class-probe.lean`
— compiled `lake env lean`, **exit 0**. Six theorems, all sorry-free and axiom-clean
(`#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`).

---

## VERDICT: **(ℚ,<) is NOT in the target class — but that does NOT make Route C free.**

Three findings, in descending order of confidence:

1. **(ℚ,<) is definitively outside classical Kamp's class, and this is NECESSARY, not convenience.**
   PDF-verified from the primary source. `{U,S}` is *provably not* expressively complete over ℚ —
   it is the textbook counterexample, not a neglected corner.

2. **The repo's real hypothesis is not Dedekind-completeness at all — it is `semantic_prior_UZ`,
   which is a DISCRETENESS condition and is strictly stronger.** I proved (compiled, axiom-clean)
   that `semantic_prior_UZ` forces immediate successors, hence **no densely-ordered flow satisfies
   it — killing ℚ *and* ℝ, for every `atomMap`**. This matters because report 05 correctly observes
   that ℝ is Dedekind-complete *and* homogeneous, so a Dedekind-completeness hypothesis would NOT
   have killed the refutation. The repo's actual hypothesis does.

3. **The over-generalization is real, and localized to exactly ONE declaration** —
   `bracketEndChar_kvFib_step_complete` (`InteriorGateGeneralK.lean:1776`) is the only link in the
   chain that carries **no** `h_UZ`/`h_SZ`. Its caller has them in scope and uses them four lines
   later. So the free `∀ M` the refutations exploit is a **dropped hypothesis at one binder**, not
   a property of the theorem.

**But the honest blocker**: `h_UZ`/`h_SZ` alone kills *dense* flows, not every *anchor-non-rigid*
flow. The hypothesis that provably kills the refutation's transport leg is **Archimedean
discreteness** — and `ReynoldsBridge.lean` **deliberately avoids `IsSuccArchimedean`** (`:8`, `:61`,
`:344`). That is Route C's real cost, and it is not zero.

**Route C is not free, and it is not dead. It is viable iff `limitdom` can be shown Archimedean
(or iff local rigidity on `(x,t)` suffices). That is the decisive next probe — one phase.**

---

## Q1 — What model class does classical Kamp's theorem actually require?

**Answer: Dedekind-complete flows (or the slightly wider "only isolated gaps"). Necessary, not
convenience. (ℚ,<) sits strictly OUTSIDE.**

All citations below are **PDF-verified this session** against
`sources/gabbay_1994/…_Temporal_Logic_Foundations_Vol1.pdf`, cited by **printed page**. This
**clears the `provenance_fidelity: null` hazard** flagged in `specs/literature-index.json` for the
`gabbay_1994_*` section entries: I did not rely on the unverified `.md` conversions for any
load-bearing claim — I read the source PDF. The `.md` claims I spot-checked matched.

| Fact | Verbatim | Printed page |
|---|---|---|
| The positive theorem | "**Theorem 10.3.21** The language {U, S} is expressively complete over Dedekind complete time." | **p.391** |
| Its separation basis | "**Theorem 10.3.20** (separation theorem) Over Dedekind complete time, each wff in the language with {U, S} is equivalent to a separated wff." | **p.391** |
| ℚ explicitly excluded | "However, Until and Since are **not expressively complete for the rationals**" | **p.225** |
| The general failure | "**Lemma 12.4.2** In general linear time, {U, S} is **not** expressively complete." | **p.419** |
| The exact boundary | "**Lemma 12.4.1** Over flows of time with only isolated gaps, {U, S} is expressively complete." + "**Kamp's pioneering theorem is then a special case of this lemma.**" | **p.419** |
| Dedekind = gapless | "Dedekind complete orders, then, are those without gaps." | ch12 p.1 |
| Where ℚ sits | "nowhere in the rationals is there a gap of any order at all" (⟹ ℚ's gaps are all **unranked**, hence **not isolated**; "a zero-order gap is just an isolated gap") | ch12 p.2 |

**Reading.** The exact class where `{U,S}` is expressively complete is *flows with only isolated
gaps* (Lemma 12.4.1, p.419); Dedekind-complete (= gapless) is the special case Kamp proved.
ℚ has gaps, and **none of them is of any order** — so none is isolated. ℚ therefore falls outside
even the wider class, and p.225 states the failure outright.

**Necessity is settled by construction, not by silence**: Gabbay ch12 exists *solely* to add the
Stavi connectives `U',S'` to recover completeness over gapped time. If Dedekind-completeness were a
convenience, that chapter would be unnecessary. Lemma 12.4.2 (p.419) exhibits a flow with a single
non-isolated gap on which a Stavi connective is inexpressible in `{U,S}`.

**Cross-check (independent, 2nd source)**: this repo's own `StaviCompleteness.lean` header states
`stavi_expressive_completeness` is "GHR93 Theorem 9.3.1: {U,S,U',S'} is expressively complete for
**ALL** linear orders" — and that **the completeness chain bypasses it** in favour of
`kamp_prior_expressive_completeness`. The repo has *already decided* not to target general linear
orders. H3 source-coverage minimum met (GHR PDF + repo declaration).

> **A caution report 05 is right about, which I confirm and sharpen.** Dedekind-completeness alone
> would NOT have saved the seam: **(ℝ,<) is Dedekind-complete and still order-homogeneous** fixing
> `(-∞,t]`. So "restrict to Dedekind-complete flows" is the *wrong* Route C. Fortunately that is not
> the repo's hypothesis — see Q2.

---

## Q2 — What does THIS REPO's theorem actually quantify over?

**Answer: YES, the seam's `∀ M` range is WIDER than the theorem needs. The leak is at exactly one
declaration.**

### The range itself is unrestricted

`OrderedMonadicStructure` (`MonadicFO.lean:103-105`) carries **`LinearOrder` and nothing else** — no
density, discreteness, Dedekind-completeness, succ/pred, or rigidity. A free
`∀ M : OrderedMonadicStructure sig` therefore ranges over ℚ, ℝ, ℤ, ℤ+ℤ, Suslin lines.

### But the chain is NOT free — it carries `semantic_prior_UZ`/`SZ`

| Declaration | `M` binder | Carries `h_UZ`/`h_SZ`? |
|---|---|---|
| `kamp_prior_expressive_completeness` | `KampPrior.lean:654` | **YES** (`:655-656`) |
| `US_expressively_complete_over_prior` | `PriorExpressiveness.lean:352` | **YES** (byte-identical motive) |
| `bracketEndChar_kvExtFib_correct_prior` | `ExteriorGateAssembleK.lean:571` | **YES** (`:572`) |
| `kampPrior_site_rungKFib_gate_match` | `KampPrior.lean:1070` | **YES** (`:1071`) |
| `EndIntervalCorrectPrior` motive | `EndIntervalConsumerK.lean:118` | **YES** (`:119`) |
| **`bracketEndChar_kvFib_step_complete`** | **`InteriorGateGeneralK.lean:1776`** | **NO — free `∀ M`** |
| `bracketEndChar_kvFib_step_correct` | `InteriorGateGeneralK.lean:2323` | **NO** (dead leaf, 0 consumers) |

**This is the statement-level over-generalization, and it is one binder wide.** Report 03's claim
that "EGA:571, IGGK:1776, KampPrior:1070 — all quantify `M` freely" is **two-thirds incorrect**:
EGA:571 and KampPrior:1070 *do* carry `h_UZ`/`h_SZ` (I read them verbatim). Only **IGGK:1776** is
genuinely free. Report 03's refutation is therefore valid **as a statement about IGGK:1769**, and
invalid as a statement about the theorem the project is proving.

### `semantic_prior_UZ` is a DISCRETENESS condition — compiled proof

`semantic_prior_UZ` (`PriorDefs.lean:22-28`) = "every future occurrence of ψ has a **first**
occurrence", quantified over **all `ψ : Formula`**. Since `Formula.neg φ = φ.imp bot`
(`Syntax/Formula.lean:115`) and `temporal_truth _ _ _ .bot = False` (`Table.lean:187`),
instantiating `ψ := ⊤` collapses the "ψ.neg holds strictly between" clause to `False` — so the
first occurrence must have **empty open interval**, i.e. be an **immediate successor**:

```lean
theorem prior_UZ_forces_immediate_successor …   -- compiled, axiom-clean
    (h_UZ : semantic_prior_UZ M atomMap) (t : M.carrier) (hne : ∃ s, t < s) :
    ∃ s, t < s ∧ ∀ r, t < r → r < s → False

theorem prior_UZ_fails_on_dense …               -- compiled, axiom-clean
    [DenselyOrdered M.carrier] [NoMaxOrder M.carrier] (t : M.carrier) :
    ¬ semantic_prior_UZ M atomMap
```

**Consequences**, both interpretation-independent (they hold for *every* `atomMap`):
- **(ℚ,<) fails `semantic_prior_UZ`.** The non-vacuity witness of all three refutations is
  **outside the model class of every seam that carries `h_UZ`/`h_SZ`**, and outside the top-level
  target's class.
- **(ℝ,<) also fails it** — so the repo's hypothesis is strictly stronger than Dedekind-completeness
  and closes the ℝ hole report 05 identified.

This **refutes a contrary claim** raised during this dispatch ("UZ/SZ are the *definable*-first-
occurrence surrogate; they are satisfiable on ℚ, so they do not exclude dense flows"), which was
inferred from the doc comment at `PriorExpressiveness.lean:337` ("relativized from Dedekind
completeness to `semantic_prior_UZ/SZ`"). The comment describes the *proof technique*; it does not
license the model class. **Resolved by compiled probe** (precedence: compiled Lean source > doc
comment). Corroborated independently by `completeness_discrete`'s own proof
(`Completeness.lean:283-300`), which uses `Axiom.prior_UZ` to derive `U(⊤,⊥)` and **refute the
dense case** — the repo already treats prior-UZ as a discreteness principle.

### The top-level target

`completeness_discrete` (`Completeness.lean:275-276`) : `valid_discrete φ → Derivable
FrameClass.Discrete [] φ`. And `valid_discrete` (`Validity.lean:180-186`) quantifies over
`[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]` — **the
Archimedean discreteness bundle**, instantiated at **ℤ** (`Transfer.lean:1221 refine ⟨ℤ, …⟩`).
ℤ is discrete and Dedekind-complete — exactly Gabbay Theorem 10.2.10 ("{U,S} is expressively
complete over **integer** time", ch10 p.9).

**So the intended class is ℤ-like, at both ends of the chain. The seam in the middle ranges over
every linear order. That gap is the whole story.**

---

## Q3 — Would Route C preserve the top-level theorems? **Tiered — and this is the deliverable.**

### Tier 1 — thread `h_UZ`/`h_SZ` into `IGGK:1769`. **Cost: ZERO.**

The sole live path into `bracketEndChar_kvFib_step_complete` is **`ExteriorGateAssembleK.lean:724`**,
inside `bracketEndChar_kvExtFib_correct_prior` — which **binds `h_UZ`/`h_SZ` at `:572` and already
uses them at `:682`, `:695`, `:727`, `:743`**. They are live local hypotheses three lines from the
call. Passing them costs nothing. (`bracketEndChar_kvFib_step_correct` at `:2311` and
`kampPrior_site_rungKFib_gate_match` at `:1058` have **zero consumers** — dead leaves;
`endInterval_correct` likewise, per `NfMultiAnchorBridge.lean:52` "Both are acyclic **leaves**".)

**What Tier 1 buys**: the `(ℚ,<)` witness — the *stated* non-vacuity leg of **all three**
refutations (reports/02 `hchar_eq`, reports/03 `htransport`/`hSym`) — becomes **unsatisfiable**.
No frozen surface is touched. This is **restoring a hypothesis the parent already has**, not
narrowing the theorem.

**What Tier 1 does NOT buy**: discreteness ≠ rigidity. A discrete, non-Archimedean flow
(e.g. ℚ-many ℤ-blocks) can satisfy `h_UZ`/`h_SZ` under a coarse interpretation *and* admit
anchor-fixing automorphisms permuting interior blocks. **Tier 1 removes the counterexample; it does
not prove the seam dischargeable.**

### Tier 2 — add `[IsSuccArchimedean]`. **Provably kills the refutation — but the live consumer cannot supply it.**

```lean
theorem archimedean_forces_anchor_rigidity …    -- compiled, axiom-clean
    [LinearOrder α] [SuccOrder α] [IsSuccArchimedean α]
    (f : α ≃o α) (x : α) (hfx : f x = x) (y : α) (hxy : x ≤ y) : f y = y

theorem no_cross_render_automorphism_of_archimedean … : w' = w0
```

An automorphism fixing anchor `x` fixes **every** point above `x` (`α(succ^[n] x) = succ^[n] (α x)`).
So no `α` fixes `x,t` while moving `w0 ↦ w' ≠ w0`: **report 03's `hSym`/`htransport` is
unsatisfiable**, and report 03's refutation of the existential seam **collapses**.

**The blocker**: `ReynoldsBridge.lean` exists *specifically to avoid* `IsSuccArchimedean` —
`:8` "bypasses `succ_embed_surjective` and the `IsSuccArchimedean` requirement"; `:342` "NOT
IsSuccArchimedean"; `:344` "This does NOT require `IsSuccArchimedean` for `LimitDomSubtype`". The
sole live instantiation is `limitdom_monadic_structure` (`ReynoldsBridge.lean:354-356`, SuccOrder +
PredOrder + Countable + NoMax + NoMin — **not** Archimedean), consumed at `:361`.
`limitdom_semantic_prior_UZ` (`:247`) **is** proved, so **Tier 1 is discharged at the live site
today; Tier 2 is not.**

### Disagreement with report 05 (compiled-backed; its claim was flagged MEDIUM and invited attack)

Report 05 (`05_expressive-gap-hypothesis.md:245-251`) argues route C's real requirement is
**per-`qnf` render-uniqueness at depth k+2**, "strictly stronger than discreteness", because two
distinct points can share a depth-(k+2) characteristic even in (ℤ,<).

**Its premise is right; its conclusion conflates two different seam forms.**

- **`∀ w` form** (reports/02): two co-characteristic renders ⟹ the binder yields iff at **both**
  ⟹ `crossRender_from_two_iffs` fires. **No automorphism needed.** Report 05 is **correct** here,
  and render-uniqueness *is* what this form would need. But this form is **already dead** — it was
  refuted in reports/02 and is not the surviving candidate.
- **`∃ w` form** (reports/03's candidate — which reports/03 verified *elaborates* and discharges all
  7 exclusion sites byte-for-byte): the existential asserts the iff **only at the one witness it
  names**. Two co-characteristic renders give **one** iff, not two — the diagonal cannot be built.
  Report 03 therefore needed `hSym` (the automorphism transport) to manufacture the second iff, and
  said so explicitly. **Anchor-rigidity — not render-uniqueness — is what the `∃` form needs, and
  Archimedean discreteness supplies it (compiled above).**

So **render-uniqueness is not Route C's requirement** for the live candidate design. Route C's
requirement is **anchor-rigidity**, which is *weaker* than render-uniqueness and *implied by* the
Archimedean bundle `valid_discrete` already carries. Report 05's claim (2) does not kill Route C.

### Answering the coordinator's question directly

> Do the live call sites instantiate the seam only at flows satisfying per-`qnf` render-uniqueness
> at depth k+2?

**No — and they do not need to.** Render-uniqueness is the `∀ w` form's requirement, and that form
is already dead. The live sites instantiate at `limitdom_monadic_structure`, which supplies
`semantic_prior_UZ`/`SZ` (`ReynoldsBridge.lean:247`) but **not** `IsSuccArchimedean` (by explicit
design). The hypothesis Route C actually needs is **anchor-rigidity on `(x,t)`**.

**Therefore Route C is neither free nor dead. The decisive question is narrow and answerable:**

> **Can `LimitDomSubtype` be shown Archimedean — or does the seam need only *local* rigidity between
> the anchors `x` and `t` (which holds whenever `t = succ^[n] x`), rather than global Archimedean?**

The local variant is promising and materially cheaper: my `archimedean_forces_anchor_rigidity`
only ever applies the induction *between* `x` and the render `w`, and the seam always has
`x < w < t` (`IGGK:1786-1791`). A **local** hypothesis `∃ n, t = succ^[n] x` would suffice and may be
dischargeable at `limitdom` without the global ℤ-isomorphism that `ReynoldsBridge` bypassed.
**This is the ~1-phase probe the plan should run before committing to any route.**

---

## Reference grounding (Tier 1)

| Source | Prop / Location | Lean Identifier | Type Signature / fact | Status |
|---|---|---|---|---|
| GHR 1994 | Thm 10.3.21, **p.391** | `kamp_prior_expressive_completeness` (`KampPrior.lean:648`) | `{U,S}` exp. complete over **Dedekind complete** time | **PDF-verified**; repo analogue relativized to `h_UZ`/`h_SZ` |
| GHR 1994 | Thm 10.3.20, **p.391** | — | separation over Dedekind complete time | **PDF-verified** |
| GHR 1994 | **p.225** | — | "Until and Since are **not** expressively complete for the rationals" | **PDF-verified** — kills ℚ |
| GHR 1994 | Lemma 12.4.2, **p.419** | — | `{U,S}` not exp. complete in general linear time | **PDF-verified** — necessity |
| GHR 1994 | Lemma 12.4.1, **p.419** | — | only-isolated-gaps ⟹ complete; "Kamp's … theorem is a special case" | **PDF-verified** — exact boundary |
| GHR 1994 | Thm 10.2.10, ch10 **p.9** | `completeness_discrete` (`Completeness.lean:275`) | `{U,S}` exp. complete over **integer** time | **PDF-verified**; repo instantiates ℤ (`Transfer.lean:1221`) |
| GHR 1994 | ch12 **p.1-2** | — | Dedekind complete = gapless; ℚ's gaps are **unranked**, hence not isolated | **PDF-verified** |
| Repo | `PriorDefs.lean:22-28` | `semantic_prior_UZ` | `∀ t ψ, (∃ s>t, truth s ψ) → ∃ s>t, truth s ψ ∧ ∀ r∈(t,s), truth r ψ.neg` | Read-confirmed |
| This report | — | `prior_UZ_forces_immediate_successor` | `h_UZ → ∃ s, t < s ∧ ∀ r, t<r → r<s → False` | **compiled, axiom-clean** |
| This report | — | `prior_UZ_fails_on_dense` | `[DenselyOrdered][NoMaxOrder] → ¬ semantic_prior_UZ` | **compiled, axiom-clean** — kills ℚ **and** ℝ |
| This report | — | `archimedean_forces_anchor_rigidity` | `[SuccOrder][IsSuccArchimedean] (f : α ≃o α), f x = x → x ≤ y → f y = y` | **compiled, axiom-clean** |
| This report | — | `no_cross_render_automorphism_of_archimedean` | kills report 03's `hSym` | **compiled, axiom-clean** |
| Repo | `Validity.lean:180-186` | `valid_discrete` | `[SuccOrder][PredOrder][IsSuccArchimedean][IsPredArchimedean][Nontrivial]` | Read-confirmed |
| Repo | `ExteriorGateAssembleK.lean:571-572` | `bracketEndChar_kvExtFib_correct_prior` | `(M) (h_UZ) (h_SZ)` — **carries them**; used `:682,695,727,743` | Read-confirmed — corrects report 03 |
| Repo | `InteriorGateGeneralK.lean:1776` | `bracketEndChar_kvFib_step_complete` | `(M : OrderedMonadicStructure sig) (x t : M.carrier)` — **free `∀ M`** | Read-confirmed — **the leak** |
| Repo | `ReynoldsBridge.lean:8,61,342,344` | `limitdom_is_good` | "does NOT require `IsSuccArchimedean`" | Read-confirmed — **Tier 2 blocker** |
| Repo | `ReynoldsBridge.lean:247` | `limitdom_semantic_prior_UZ` | `semantic_prior_UZ (limitdom_monadic_structure …)` | Read-confirmed — Tier 1 discharged today |
| Repo | `StaviCompleteness.lean:9-17` | `stavi_expressive_completeness` | general-linear-order result **bypassed**, not on chain | Read-confirmed |

---

## Adversarial Self-Verification

Attacking hardest the claim that **Route C is free** — per the dispatch mandate, since the cost of
being wrong is a narrowed theorem that no longer proves what the project wants. **I did not clear
Route C as free; the attack succeeded in part and the verdict is tiered accordingly.**

| Claim | Source/Counterexample |
|---|---|
| Kamp's theorem requires Dedekind-completeness; ℚ is outside | GHR Thm 10.3.21 **p.391** + "not expressively complete for the rationals" **p.225** + Lemma 12.4.2 **p.419**. All read from the source PDF, not the `provenance_fidelity: null` `.md`. Confidence: **High** (3 independent passages, PDF-verified) |
| Necessity, not convenience | Ch.12 exists solely to add Stavi connectives for gapped time; Lemma 12.4.2 (**p.419**) exhibits a flow with one non-isolated gap where a Stavi connective is `{U,S}`-inexpressible. Confidence: **High** |
| **ATTACK: Dedekind-completeness would not kill the refutation — (ℝ,<) is Dedekind-complete AND homogeneous** (report 05) | **SUSTAINED, and it defeats the naive Route C.** But it does not defeat mine: `prior_UZ_fails_on_dense` (compiled) kills ℝ too, because the repo's hypothesis is discreteness, not Dedekind-completeness. The correct frame is prior-UZ. Confidence: **High** (compiled) |
| `semantic_prior_UZ` excludes ℚ and ℝ for every `atomMap` | `prior_UZ_fails_on_dense`, compiled `lake env lean` exit 0, `#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`. Interpretation-independent (ψ := ⊤). Confidence: **High** |
| **ATTACK: "UZ/SZ are satisfiable on ℚ; they don't exclude dense flows"** (raised this dispatch from `PriorExpressiveness.lean:337`) | **REFUTED** by `prior_UZ_fails_on_dense`. Precedence applied: compiled Lean source > doc comment. Independently corroborated by `Completeness.lean:283-300`, which uses `prior_UZ` to refute the dense case. Confidence: **High** |
| The over-generalization is one binder wide (IGGK:1776) | Binders read verbatim: EGA:571-572 **has** `h_UZ`/`h_SZ`; KampPrior:1070-1071 **has** them; IGGK:1776 **does not**. Confidence: **High** (direct source read) |
| **ATTACK: report 03 states all three binders are free** | **REFUTED for 2 of 3.** EGA:571 and KampPrior:1070 carry `h_UZ`/`h_SZ` (verbatim read, and EGA *uses* them at `:682,695,727,743`). Report 03's refutation is sound about IGGK:1769 and overstated about the theorem. Precedence: direct source read > prior report. Confidence: **High** |
| Tier 1 (`h_UZ`/`h_SZ` into IGGK:1769) costs zero | Sole live caller EGA:724 sits inside a decl binding them at `:572` and using them at `:727`. Other callers (IGGK:2311, KampPrior:1058, `endInterval_correct`) have **zero consumers** — dead leaves (`NfMultiAnchorBridge.lean:52`). Confidence: **High** |
| **ATTACK: Tier 1 alone rescues the seam** | **REFUTED — by me.** `h_UZ` gives discreteness, not rigidity. ℚ-many-ℤ-blocks is discrete, can satisfy UZ/SZ under a coarse interp, and admits anchor-fixing automorphisms. Tier 1 removes the *stated* witness; it does not prove dischargeability. **This is why the verdict is not "Route C is free".** Confidence: **Medium** (the block model is argued, not compiled — the honest residual) |
| Archimedean discreteness kills the transport leg | `archimedean_forces_anchor_rigidity` + `no_cross_render_automorphism_of_archimedean`, compiled, axiom-clean. Confidence: **High** |
| **ATTACK: report 05 — "discreteness does NOT rescue route C; its real requirement is per-`qnf` render-uniqueness at depth k+2"** | **PARTLY SUSTAINED, conclusion REFUTED.** Premise correct (co-characteristic renders exist at bounded depth in ℤ) and it does kill the **`∀ w`** form — but that form is already dead. The surviving **`∃ w`** form asserts the iff at only ONE named witness, so two co-characteristic renders yield one iff and the diagonal cannot be built; report 03 accordingly needed `hSym`. The `∃` form needs **anchor-rigidity**, which is *weaker* than render-uniqueness and *is* implied by the Archimedean bundle. Report 05 flagged this claim MEDIUM and invited attack. Confidence: **Medium-High** (compiled rigidity result; the form-distinction is read directly from reports/03 §"existentialSeam_refuted_of_render_symmetry") |
| **ATTACK: Tier 2 is therefore free** | **REFUTED — the decisive negative finding.** `ReynoldsBridge.lean:8,61,342,344` shows `IsSuccArchimedean` is **deliberately avoided** for `LimitDomSubtype`; the sole live instantiation (`:354-356,361`) has SuccOrder/PredOrder but not Archimedean. So the live consumer **cannot discharge Tier 2 today**. Confidence: **High** (four explicit in-file statements) |
| Live top-level target is ℤ-like | `completeness_discrete` → `valid_discrete` (`Validity.lean:181`, Archimedean bundle) → instantiated at ℤ (`Transfer.lean:1221`). Confidence: **High** |

**Contradiction Log.**

1. **Sub-agent claim ("UZ/SZ satisfiable on ℚ, don't exclude dense flows") vs. this report.**
   RESOLVED against the sub-agent by precedence rank 1 (directly-read/compiled Lean source >
   doc-comment-derived summary). The sub-agent inferred model-class permissiveness from
   `PriorExpressiveness.lean:337`'s description of a *proof technique*. `prior_UZ_fails_on_dense`
   settles it.
2. **Report 03 ("EGA:571, IGGK:1776, KampPrior:1070 — all quantify `M` freely") vs. this report.**
   RESOLVED against report 03 by precedence rank 1 (direct source read). Two of the three carry
   `h_UZ`/`h_SZ`. This does **not** overturn report 03's REFUTED verdict *for IGGK:1769*, which
   stands; it relocates its scope.
3. **Report 05 (claim 2, render-uniqueness) vs. this report.** RESOLVED by **level separation**, not
   by overruling: report 05's claim is true of the `∀ w` form and false of the `∃ w` form. Both
   reports are correct about different seam signatures. No contradiction remains.
4. **UNRESOLVED CONTRADICTION: Tier-2 Route C requires `IsSuccArchimedean` vs. `ReynoldsBridge`
   deliberately not proving it.**
   *Downstream risk*: if `limitdom` is **not** Archimedean and no local-rigidity substitute exists,
   Route C cannot be discharged at the live consumer, and the route decision collapses to (A)/(B) —
   i.e. a frozen-surface edit. If it **is** (or local rigidity suffices), Route C is the cheapest
   route by a wide margin and reports/03's existential design is revived intact.
   *Resolving check, not yet performed*: a ~1-phase probe attempting either (i)
   `IsSuccArchimedean LimitDomSubtype`, or (ii) the weaker local hypothesis `∃ n, t = succ^[n] x`
   on the seam's anchors, discharged at `limitdom_monadic_structure`.

**Residual (non-compiled) legs, disclosed.** (a) The ℚ-many-ℤ-blocks model showing Tier 1 is
insufficient is argued, not compiled — it only *widens* the verdict's caution, so it cannot produce
a false clearance. (b) I did not run `#print axioms` on the production chain; sorry-reachability
claims come from source reading plus `Completeness.lean`'s own audit block. (c) Note that block's
line numbers are **stale**: it cites `KampPrior.lean:361/364`, but the live sorries are at
**`:519`/`:522`** (same theorem, `nf_nvar_exist_all_depths`).

---

## What this means for the plan (actionable)

1. **Do not accept "the theorem must cover (ℚ,<)".** It provably must not — `{U,S}` is not
   expressively complete over ℚ (GHR **p.225**), and the repo's own `semantic_prior_UZ` excludes
   every dense flow (compiled). Excluding ℚ is **not** a loss of generality.
2. **Reframe the three refutations.** They are not a deep truth about the char seam. They exploit a
   **dropped hypothesis at one binder** (`IGGK:1776`), which the caller has in scope and uses four
   lines later. Report 03's Frozen-Constraint Assessment is sound *about IGGK:1769* and overstated
   *about the theorem*.
3. **Land Tier 1 unconditionally — it is free and strictly reduces the `∀ M` range**: thread
   `(h_UZ) (h_SZ)` from `EGA:572` into `bracketEndChar_kvFib_step_complete`. No frozen surface, one
   live call site, hypotheses already in scope. This invalidates the stated non-vacuity witness of
   **all three** refutations.
4. **Then run the decisive ~1-phase probe** (this is the gate on the route decision):
   `IsSuccArchimedean LimitDomSubtype`, **or** the weaker local hypothesis `∃ n, t = succ^[n] x`.
   - **Succeeds** ⟹ Route C is live and cheapest; reports/03's existential design (which already
     *elaborates* and discharges all 7 exclusion sites) is revived — `hSym` becomes unsatisfiable.
   - **Fails** ⟹ Route C is dead at the live consumer; the decision is (A) vs (B), and report 05's
     literature argument for (A) ("give the formula its anchor") should carry.
5. **Do not pursue render-uniqueness as Route C's hypothesis.** It is the `∀ w` form's requirement,
   and that form is already dead. The `∃ w` form needs only anchor-rigidity — strictly weaker.
6. **Untouched**: Phase-2 green milestone and the Phase-1 CLEARED soundness result. This dispatch
   wrote only specs-side artifacts; no production `.lean` file was modified.

## References

- `specs/376_.../reports/04_intended-model-class-probe.lean` — this session's compiled artifact
  (6 theorems, sorry-free, axiom-clean)
- `sources/gabbay_1994/…_Temporal_Logic_Foundations_Vol1.pdf` — printed pp. 225, 391, 419 + ch12 pp.1-2
  (**all PDF-verified this session**, clearing the `provenance_fidelity: null` hazard)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorDefs.lean:22-39` (`semantic_prior_UZ`/`SZ`)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:1776` (the leak)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean:571-572,724`
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:8,61,247,342-344,354-361`
- `Theories/Bimodal/Semantics/Validity.lean:180-186`; `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:275`
- `specs/376_.../reports/02_split-seam-certification.md`, `03_existential-w-seam.md`, `05_expressive-gap-hypothesis.md`
