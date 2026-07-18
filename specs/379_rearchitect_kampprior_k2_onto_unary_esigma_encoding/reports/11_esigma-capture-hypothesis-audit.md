# E[Σ]-capture hypothesis divergence audit — pinning the exact missing hypothesis for the `VVecEA2 → VeeExistsForall` collapse (Phase 10a)

**Task 379, lean4 hard-mode research (H2/H3/H4/H5). Divergence-audit dispatch** (Phase 10 blocked
TWICE on the same seam). READ-ONLY: no `Theories/` edits. Reference-grounding **Tier 1**
(Rabinovich 2014, Def 4.1 / Prop 4.3, cited by PDF page; `.md` corrupt). Adversarial
self-verification pass included (§H4). Session `sess_1784408397_6a5f80`.

**Headline (decision-grade).** The obstruction is real and now exactly localized. The missing
hypothesis is an **E[Σ]-definability/capture** property — the *literal reverse* of the landed
forward lemma `unaryToFormula_correct`, lifted from `UnaryType` to `IntervalType`. Threading it as
an explicit hypothesis makes Phase 10a **BOUNDED and implementable next dispatch as a CONDITIONAL
result**, composing through the already-landed `vvecea2_collapse_of_perClause`. **However**, the
audit finds a second, deeper fact the prior two dispatches did not state: the hypothesis is
**dischargeable only at Phase 13 (ζ)**, and only against a `canonExpand` whose finite formula set
`F` is **closed under the negation engine's output formulas** — a closure that is **not established
in-tree** and that the landed `hcapture` discharge (`HCaptureDischarge.lean`) does **not** provide
(it discharges a `NormalForm`-shaped capture, not a `TL`-formula capture). Net verdict: the bridge
lemma is bounded; the *unconditional* close of β needs one **new prerequisite lemma** (E[Σ]
output-alphabet closure). This converts the hard wall from "inside 10a" to "a named prerequisite +
the ζ discharge" — a strictly better position, but **not** a single revise-and-done for all of β.

---

## H5 divergence table (two strikes on the same seam)

| Strike | Target | Approach attempted | Failure reason (verified) |
|---|---|---|---|
| 1 (Phase 10, plan 09) | `efSat_negation_general` → `VeeExistsForall` | Call `prop42_efSat_negation_general`, flatten via `veeSat_append` | Output-type seam: engine is `VVecEA2`-valued; **no** `VVecEA2 → VeeExistsForall` bridge exists; signature also missing `atomMap/h_surj/h_INF/h_SUP` (Axis 2) |
| 2 (Phase 10a, plan 10) | `vvecea2_collapse_bridge` under `(N,atomMap,h_surj,HasAttainedINF,HasAttainedSUP)` | Discharge per-clause reverse translation `trans`/`htrans` | The four added hyps are **attainment + surjectivity**, not **definability**. Engine clauses carry arbitrary `TL` formulas at endpoints; no hypothesis lets a `TL` formula become a `UnaryType`/`IntervalType`. `vvecea2_collapse_of_perClause` (assembly half) landed green; **10a-i (per-clause collapse) blocked** |

**Root cause (postmortem).** Both strikes are the *same class*: **insufficient hypotheses**. Strike
1 was missing the four engine hypotheses; the revision added them; Strike 2 revealed those four are
the *wrong* four — the reverse collapse needs a **capture/definability** hypothesis, which neither
strike carried. The seam is not a tactic gap; it is a genuine Def 4.1 obstruction that was
*mis-diagnosed as closable by attainment facts*. The audit below states the correct hypothesis and
proves (by tracing the in-tree apparatus) that it is the minimal sufficient one.

---

## Q1 — The EXACT E[Σ]-capture hypothesis (concrete Lean proposition + signature)

### What the engine emits vs. what the target accepts (the shape mismatch, restated precisely)

- **Engine output** (`prop42_efSat_negation_general`, `Prop42NegationGeneral.lean:997-1004`): a
  `VVecEA2` = disjunction of `VecEA2 n` clauses. Each `VecEA2` (`VecEAFormula.lean:252-267`) is
  `endpointLeft.eval_at z0 ∧ endpointRight.eval_at z1 ∧ bracket.holds z0 z1`, where
  `endpointLeft/Right : TemporalPred` and `bracket.pointTypes/segmentTypes : TemporalPred`
  (`VecEAFormula.lean:128-132`). A `TemporalPred` is `⟨formula : Formula⟩` with
  `eval_at N atomMap tp t = temporal_truth N atomMap t tp.formula` (`ExistsForallNF.lean:49-56`).
  The concrete endpoint formulas are `⟨Formula.neg (belowFormula …)⟩` (`:919`),
  `⟨Formula.neg (aboveFormula …)⟩` (`:950`), and the `(middleBracket …).negFix` INF/`K⁺` engine —
  **arbitrary `TL(Until,Since)` formulas**, not `unaryToFormula`-images.
- **Target atomic content** (`ExistsForallFormula`, `ExistsForallFormula.lean:105-114`):
  `pointType : Fin (n+1) → UnaryType` and `intervalType : Fin (n+2) → IntervalType`. Satisfaction is
  `unaryHolds N τ y` (`:62-64`) / `intervalHolds N S y := ∃ τ ∈ S, unaryHolds N τ y` (`:93-95`).
  A `UnaryType := NormalForm (sigE sig F) 0 1` is a **complete** truth assignment to the unary E[Σ]
  predicates **at a single point** — it can only express whether each E[Σ] atom holds at `y`, i.e. a
  Boolean cell.

**Why the mismatch is fundamental.** `temporal_truth N atomMap y A` for a `TL` formula `A` with
`Until`/`Since` depends on truth at **other points**, so it is a function of `y`'s complete unary
type **iff** `A`'s temporal content has already been folded into a **named E[Σ] atom** (Def 4.1,
p.5-6). That is the collapse. It is not derivable from `y`'s type unless `A` (or its truth set) is
E[Σ]-definable.

### The exact hypothesis (state it at the `IntervalType` level)

The correct capture target is an **`IntervalType` (= `Finset UnaryType`)**, not a single `UnaryType`:
a `TL` formula's truth set is a *union* of complete-type cells, exactly what `intervalHolds`
(`∃ τ ∈ S, unaryHolds N τ y`) expresses. The hypothesis is the **literal reverse of
`unaryToFormula_correct`** (`Prop35ExistsForall.lean:75`, which gives `UnaryType → Formula`), lifted
to sets:

```lean
-- E[Σ]-definability / capture of N (the missing hypothesis)
(hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
    ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
```

Equivalently, at the atom-naming level (the `canonExpand` shape, Def 4.1 p.5), for the finite set of
engine-output formulas `A`:

```lean
(hCanon : ∀ A ∈ 𝔈, ∃ hA : A ∈ F,
    ∀ y : N.carrier, N.interp (esigmaPred A hA) y ↔ temporal_truth N atomMap y A)
```

where `𝔈` is the (finite) set of `TL` formulas the negation engine emits. `hCanon ⇒ hCapture` on
`𝔈` by taking `S := {τ : UnaryType | τ (atomKind for esigmaPred A) = true}` and unfolding
`atom_eval_new` (`ESigmaExpansion.lean:122`): `intervalHolds N S y ↔ (esigmaPred A holds at y) ↔
N.interp (esigmaPred A) y ↔ temporal_truth N atomMap y A`.

**This is precisely the "`canonExpand` property" the two handoffs named** — now stated as a concrete,
threadable Lean proposition rather than a slogan. The `∀ A` form (`hCapture`) is the clean, F-membership-free
statement to thread through Phases 10a–12; the `hCanon` form is what discharges it at Phase 13.

---

## Q2 — Availability at Phase 10a: NOT available; must be added as a hypothesis

Exhaustive trace of the relevant apparatus:

| Symbol | File:anchor | Direction | Verdict |
|---|---|---|---|
| `unaryToFormula` / `unaryToFormula_correct` | `Prop35ExistsForall.lean:65,75` | `UnaryType → Formula`, `temporal_truth … (unaryToFormula τ) ↔ unaryHolds N τ` | **Forward only** — the exact reverse is what is missing |
| `translateProp35` / `_correct` | `Prop35Assembly.lean:145,153` | `ExistsForallFormula 1 → Formula` | Forward only |
| `translateVeeProp42` / `_correct` | `Prop42ExistsForall.lean:402,410` | `VeeExistsForall → VVecEA2` | Forward only (the bridge whose *reverse* is blocked) |
| `atom_eval_new` | `ESigmaExpansion.lean:122` | names `A ∈ F` as atom, **on `canonExpand`** | Available **only** on a `canonExpand`; not on generic `N` |
| `hcapture_dischargeable` | `HCaptureDischarge.lean:58` | captures a **`NormalForm σ`** by a fresh atom | **Wrong shape** — captures normal forms, not the engine's `TL` formulas |
| `HasAttainedINF/SUP` | `PriorINF.lean:202,254` | first/last-occurrence attainment | **Attainment, not definability** — cannot capture `A` |

Conclusion: no in-tree lemma provides `hCapture` for a generic `N`, and none is a near-miss that a
tactic could bridge. `unaryToFormula_correct` is the *forward* of the needed statement; the reverse
is genuinely absent. **Phase 10a must take `hCapture` (or `hCanon`) as an explicit hypothesis.**

---

## Q3 — Availability at downstream consumers (Phases 11 γ, 12 δ, 13 ζ)

**Threading through 11 and 12: clean.** Both already carry `N / atomMap / h_surj / h_INF / h_SUP`
uniformly (plan 10, Phases 11-12). Adding `hCapture : ∀ A, ∃ S, …` as one more Prop-valued
hypothesis on `efSat_negation_general` (β, 10b), `veeSat_negation` (γ, 11), and `translate_correct`
(δ, 12) threads with no contradiction — it is a fixed property of `N`, orthogonal to the structural
induction. No consumer *uses* `¬hCapture`, so there is no polarity clash.

**Discharge at Phase 13 (ζ): the decisive finding.** Two facts, both verified:

1. **`canonExpand` is never constructed in the live spine.** Grep over all of `Kamp/*.lean`:
   `canonExpand` appears **only** inside `ESigmaExpansion.lean` (its own definition + theorems). The
   spine (`KampPrior.lean`) imports **only** `ExistsForallNF` from this apparatus — the entire
   β/γ/δ/collapse stack is off-path and is consumed *for the first time* at the Phase 13 ζ rewire,
   which does not exist yet. So `hCapture` is dischargeable **only at ζ**, where the model is (to be)
   built as `canonExpand sig F M (temporal_truth …)` and `atom_eval_new` supplies capture for
   `A ∈ F`.
2. **The discharge needs `F` closed under the engine's output formulas.** `atom_eval_new` names only
   `A ∈ F`. The engine emits compound `TL` formulas (`Formula.neg (belowFormula …)`, `… (aboveFormula …)`,
   `negFix`) built *from* `F`'s atoms but **not members of `F`** in general. For `hCanon` to hold at ζ,
   `F` must contain (up to equivalence) every engine-output formula. That closure is **not established
   in-tree**, and the landed `hcapture_dischargeable` does **not** provide it (it captures a
   `NormalForm σ`, a different object than a `TL` `Formula`).

**Verdict Q3:** `hCapture` threads freely to 11/12 and is *stated* consumable at 13, but its
**unconditional discharge at 13 is gated on an unbuilt `F`-closure lemma**. Everything from 10a to 12
becomes green *conditional on `hCapture`*; ζ cannot remove `sorryAx` until the closure is proved.

---

## Q4 — Rabinovich fidelity (Def 4.1 / Prop 4.3) and the faithful discrepancy

**The bridge design matches the paper.** Def 4.1 (p.5) expands the alphabet by a fresh **unary**
predicate `A` for each processed `TL(Until,Since)` formula, interpreted in the canonical structure as
`{a | M,a ⊨ A}`; the p.6 collapse note makes a `TL`-over-E[Σ] formula equivalent to an **atomic**
formula. So re-entering an already-processed formula as a *unary E[Σ] atom* — exactly what `hCapture`
asserts — **is** the atom-collapse. Prop 4.3's recursion stays uniformly in the `∨∃∀` object, so the
per-leaf `VVecEA2` output must re-enter as a `∨∃∀` object via this collapse. The Lean design (interpose
the collapse once at the leaf, keep β `VeeExistsForall`-valued) is faithful.

**The faithful discrepancy.** In Rabinovich, `F` (the E[Σ] alphabet at a stage) is **closed by
construction**: it *is* the set of `TL` formulas processed at that stage, so every engine output is
already a named predicate — the collapse is definitional. The Lean apparatus carries `F : Finset Formula`
as an **opaque** parameter with **no closure invariant** tying it to the negation engine's outputs.
That is the exact gap: the paper's `F` is closed under the very formulas `belowFormula`/`aboveFormula`/`negFix`
produce; the Lean `F` is not demonstrably so. Faithful repair = re-establish that closure invariant
(the `hCanon`/`hCapture` discharge), not invent new mathematics.

---

## Q5 — Concrete re-scope recommendation

### Revised Phase 10a signature (thread `hCapture`)

```lean
theorem vvecea2_collapse_bridge {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,          -- NEW: the missing hypothesis
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (v' : VVecEA2) :
    ∃ Φ : VeeExistsForall sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSat N env Φ ↔ v'.holds N atomMap (env 0) (env 1))
```

With `hCapture`, **10a-i is dischargeable**: for each `VecEA2` clause, use `hCapture` on
`endpointLeft.formula`, `endpointRight.formula`, and each `bracket` `pointTypes`/`segmentTypes`
formula to obtain capturing `IntervalType`s; enumerate their completions into `ExistsForallFormula`
disjuncts (point-pins at `z0`/`z1`, interval slots for the bracket segments); assemble the
disjunction via the **already-landed** `vvecea2_collapse_of_perClause` (`VVecEA2Collapse.lean:70`),
supplying `trans`/`htrans` from the per-clause capture. `h_INF`/`h_SUP` remain needed for the
`negFix` (Lemma 5.1) middle-bracket clause's INF/`K⁺` readback.

The same `hCapture` is added to **10b (β), 11 (γ), 12 (δ)** signatures (threaded, not discharged).

### Bounded vs. prerequisite — the honest verdict

**BOUNDED (next dispatch):** the *bridge lemma itself* and β/γ/δ, as **conditional** results with
`hCapture` threaded. This lands green + sorry-free + off-path and retires the Phase 10a `[BLOCKED]`
marker on the bridge.

**PREREQUISITE required for the unconditional close:** a **new** forward-capture / E[Σ]-closure
lemma that discharges `hCapture` at the concrete `canonExpand` used by ζ. This is genuine Def 4.1
content (report 07 R4 crux) and is **not** supplied by `hcapture_dischargeable` (wrong object). Two
faithful shapes for it:

- **(P-a) Output-alphabet closure**: define `F` at the ζ rewire site as closed under the engine's
  formula constructors (`neg`, `belowFormula`, `aboveFormula`, `negFix`), then discharge `hCanon` via
  `atom_eval_new`. This is the faithful "E[Σ] is closed at the stage" invariant.
- **(P-b) Semantic definability lemma**: prove directly that on the ζ `canonExpand`, every
  engine-output `TL` formula's truth set equals some `IntervalType`'s (`intervalHolds`) extension —
  the reverse of `unaryToFormula_correct` at the interval level, established for the specific `𝔈`.

**Recommended plan edit:** keep Phase 10a as the *bounded, hypothesis-threaded* bridge (implementable
now), and insert a **new prerequisite phase** — "Phase 10a-0: E[Σ] output-alphabet capture/closure"
— owning (P-a)/(P-b), scheduled **before Phase 13's discharge** (it may run in parallel with 10a/10b/11/12
since those only *consume* `hCapture` abstractly). Do **not** advertise β as fully closable in one
revise: the reviser should thread `hCapture` everywhere and land 10a–12 green-conditional, with the
unconditional `sorryAx` removal blocked on 10a-0 + ζ.

---

## Findings — H3 lemma-mapping table (capture hypothesis and anchors)

| Source (Rabinovich PDF / concept) | Prop / Location | Lean identifier | Type signature (abbrev.) | Status |
|---|---|---|---|---|
| Def 4.1 p.5, fresh unary atom `A` | atom names processed `TL` formula | `esigmaPred`, `sigE` | `Formula → (sigE sig F).preds`; `preds := sig.preds ⊕ {A // A ∈ F}` | exists (`ESigmaExpansion.lean:63,69`) |
| Def 4.1 p.5, `{a | M,a⊨A}` interp | canonical expansion | `canonExpand` | `… (sat : Formula → M.carrier → Prop) → OrderedMonadicStructure (sigE sig F)` | exists; **never built in live spine** (`:100`) |
| p.6 collapse note | atom reads back as truth set | `atom_eval_new` | `atom_eval (canonExpand …) env (.pred (esigmaPred A hA) i) ↔ sat A (env i)` | exists, `Iff.rfl` (`:122`) |
| Prop 3.5 atomic layer (FORWARD) | `UnaryType → Formula` capture | `unaryToFormula_correct` | `temporal_truth N atomMap t (unaryToFormula τ) ↔ unaryHolds N τ t` | exists (`Prop35ExistsForall.lean:75`) |
| **Def 4.1 REVERSE (missing)** | **`TL` formula → `IntervalType` capture** | **`hCapture` (proposed)** | `∀ A, ∃ S : IntervalType sig F, ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A` | **to-build / hypothesis** |
| partial interval type | `Finset UnaryType`, `∃τ∈S, unaryHolds` | `IntervalType`, `intervalHolds` | `abbrev IntervalType := Finset (UnaryType …)`; `intervalHolds N S y := ∃ τ ∈ S, unaryHolds N τ y` | exists (`ExistsForallFormula.lean:87,93`) |
| Def 4.1 `hcapture` (NormalForm) | NORMALFORM capture (not TL) | `hcapture_dischargeable` | `∃ sat, ∀ σ:NormalForm, sat (Aσ σ) (env anchor) ↔ ∃x, nf_eval …` | exists but **wrong object** (`HCaptureDischarge.lean:58`) |
| engine output shape | `VVecEA2` w/ arbitrary `TL` endpoints | `prop42_efSat_negation_general` | emits `(negLeftClauseTL).disj (middleBracket.negFix) |>.disj (negRightClauseTL)` | exists (`Prop42NegationGeneral.lean:997-1004,919,950`) |
| assembly half (landed) | per-clause → disjunction | `vvecea2_collapse_of_perClause` | takes `trans`/`htrans`, yields `VeeExistsForall` bridge | exists, green (`VVecEA2Collapse.lean:70`) |
| attainment (NOT definability) | first/last occurrence | `HasAttainedINF/SUP` | `first_occ/last_occ : ∀ P z0 z1, …` | exists; insufficient for capture (`PriorINF.lean:202,254`) |

---

## H4 — Adversarial self-verification

Applied the Claim Verification Bar to every load-bearing claim; then tried to **refute** the proposed
`hCapture`.

### Claim verification table

| Claim | Source / counterexample probe | Verification method | Confidence |
|---|---|---|---|
| Engine clauses carry arbitrary `TL` formulas at endpoints | `⟨Formula.neg (belowFormula …)⟩`, `⟨… aboveFormula⟩`, `negFix` | file read `Prop42NegationGeneral.lean:919,950,997-1004`; `VecEA2.holds` `VecEAFormula.lean:262` | High |
| Target atomic content is `UnaryType`/`IntervalType` (point-local) | complete NF assignment at one point | file read `ExistsForallFormula.lean:57,62,87,93` | High |
| Forward capture exists; reverse does not | `unaryToFormula_correct` forward; grep finds no `Formula → UnaryType` | `lean_local_search`-style grep + file read `Prop35ExistsForall.lean:75` | High |
| `atom_eval_new` gives capture only on `canonExpand` | `Iff.rfl` gated on `canonExpand` constructor | file read `ESigmaExpansion.lean:122` | High |
| `canonExpand` never built in live spine; β/γ/δ off-path | grep `canonExpand` = only `ESigmaExpansion.lean`; `KampPrior` imports only `ExistsForallNF` | grep across `Kamp/*.lean`; `KampPrior.lean:1` imports | High |
| `hcapture_dischargeable` is wrong object (NormalForm, not TL formula) | its `σ : NormalForm sig k (n+1)`, not `A : Formula` | file read `HCaptureDischarge.lean:58-74` | High |
| `HasAttainedINF/SUP` are attainment, not definability | `first_occ`/`last_occ` shape | file read `PriorINF.lean:202-212,254-264` | High |
| `hCapture` interval-level is the right target (not single `UnaryType`) | `TL` truth set = union of complete-type cells; single type = one cell | reasoned from `intervalHolds = ∃τ∈S` vs `unaryHolds` | High |
| Discharge needs `F` closed under engine outputs | `atom_eval_new` names only `A ∈ F`; engine outputs are compound `TL`, not in `F` | reasoned from `atom_eval_new` + engine output constructors | Medium-High |
| `hCapture` threads to 11/12 without contradiction | fixed property of `N`, orthogonal to induction; no `¬hCapture` use | reasoned from plan 10 Phase 11/12 signatures | Medium-High |

### Refutation attempts against `hCapture`

- **R1 — Is `hCapture` TOO STRONG (unsatisfiable / over-constrains `N`)?** As an *unconditional* `∀ A`
  over ALL formulas it IS too strong for a generic `N` (a `TL` formula with unbounded modal depth need
  not be E[Σ]-definable). **Mitigation:** it is only ever *discharged* on the ζ `canonExpand` and only
  for the **finite** engine-output set `𝔈 ⊆ F` (the `hCanon` form). As a *threaded hypothesis* on
  10a–12 it is harmless (never discharged there). So the honest statement to thread is the `∀ A` form
  for uniformity, but the discharge obligation is the finite `hCanon`. **Not fatally too strong, but
  the report must flag that the `∀ A` form is discharged only via F-closure — hence the prerequisite.**
  Confidence the mitigation is correct: High.
- **R2 — Is `hCapture` VACUOUS (trivially true, hence proving nothing)?** No. `intervalHolds N S y`
  ranges over a `Finset` of complete types; matching it to an arbitrary `temporal_truth … A` is exactly
  the collapse content. It is provably *false* for an `N` that is not E[Σ]-saturated (e.g. `N` where a
  fresh atom is interpreted arbitrarily, unrelated to any `TL` truth set). So it carries real content.
  Confidence: High.
- **R3 — Is it UNAVAILABLE at a consumer (thread breaks)?** It threads to 11/12 (they carry the same
  `N`-hypotheses; adding one Prop is uniform). The genuine unavailability is at **13 (ζ)** as an
  *unconditional* fact — which is why the report recommends a **prerequisite phase**, not a claim that
  ζ is free. This is the load-bearing caveat, stated explicitly. Confidence: Medium-High (ζ rewire not
  yet built, so the discharge cannot be machine-checked today — flagged as the residual).
- **R4 — Could the single-`UnaryType` form (as the handoffs wrote it) work instead, avoiding intervals?**
  No. `∀ A, ∃ τ : UnaryType, ∀ y, unaryHolds N τ y ↔ temporal_truth … A` forces `A`'s truth set to be
  a **single** complete-type cell — false whenever `A`'s extension spans ≥2 cells (generic). The
  interval (`Finset`) form is necessary and is why Phases 3-9 built `IntervalType`. **Correction to the
  prior handoffs' hypothesis shape.** Confidence: High.

### Contradiction log

No unresolved contradictions. One tension resolved by precedence (direct file evidence > handoff
prose): the two handoffs proposed the capture at the **`UnaryType`** level
(`∃ τ : UnaryType, unaryHolds N τ y ↔ temporal_truth y A`); the code shows a `TL` truth set is
generally a union of cells, so the faithful target is **`IntervalType`** (R4). Resolution: thread
`hCapture` at the `IntervalType` level. Recorded here and in Q1.

### Recommendations modified after verification

- Elevated the hypothesis from `UnaryType`-level (handoffs) to **`IntervalType`-level** (R4).
- Split the verdict into **BOUNDED (bridge, conditional)** + **PREREQUISITE (F-closure discharge)** —
  the prior "just determine the hypothesis" framing understated the ζ discharge obligation.
- Flagged that the landed `hcapture` discharge does **not** transfer (wrong object) — closing a likely
  future mis-step.

---

## Direct answers (for the reviser)

- **Q1:** `hCapture : ∀ A : Formula, ∃ S : IntervalType sig F, ∀ y, intervalHolds N S y ↔
  temporal_truth N atomMap y A` — the interval-level reverse of `unaryToFormula_correct`. (Atom-level
  discharge form: `hCanon`, `N.interp (esigmaPred A hA) y ↔ temporal_truth … A` for `A ∈ F`.)
- **Q2:** Not available in-tree; `unaryToFormula_correct` is forward-only, `atom_eval_new` needs
  `canonExpand`, `hcapture_dischargeable` is the wrong object, attainment ≠ definability. Add as a hypothesis.
- **Q3:** Threads cleanly to 11/12; **dischargeable only at 13 (ζ)** against a `canonExpand` with `F`
  closed under engine outputs — a closure **not yet built**. `canonExpand` is currently never
  constructed in the live spine.
- **Q4:** Design is faithful to Def 4.1/Prop 4.3 (collapse once at the leaf). Discrepancy: Rabinovich's
  `F` is closed-by-construction; the Lean `F` is an opaque parameter with no closure invariant — the
  faithful missing piece.
- **Q5:** **BOUNDED** to land the bridge + β/γ/δ as **conditional** results next dispatch (thread
  `hCapture`, discharge 10a-i via `hCapture` + `vvecea2_collapse_of_perClause`). **PREREQUISITE**: a
  new E[Σ] output-alphabet capture/closure lemma (P-a or P-b) to discharge `hCapture` unconditionally
  at ζ. Not a single revise-and-done for the whole β; it is a revise-and-done for the *bridge*, plus a
  named prerequisite for the *close*.

## Key anchors (quick reference)

- Missing hypothesis target: `intervalHolds`/`IntervalType` (`ExistsForallFormula.lean:87,93`); reverse
  of `unaryToFormula_correct` (`Prop35ExistsForall.lean:75`).
- Discharge machinery (canonExpand): `atom_eval_new`/`canonExpand`/`esigmaPred`
  (`ESigmaExpansion.lean:122,100,69`) — **not yet instantiated in the spine**.
- Engine output: `prop42_efSat_negation_general` (`Prop42NegationGeneral.lean:997-1004,919,950`);
  clause shape `VecEA2.holds` (`VecEAFormula.lean:262`); `TemporalPred` (`ExistsForallNF.lean:49-56`).
- Landed assembly half to compose through: `vvecea2_collapse_of_perClause` (`VVecEA2Collapse.lean:70`).
- Wrong-object trap: `hcapture_dischargeable` captures `NormalForm σ`, not `TL` `Formula`
  (`HCaptureDischarge.lean:58`).
- Live spine sorry retired at ζ: `KampPrior.lean:562`; spine imports only `ExistsForallNF`.
- Rabinovich PDF pp.5-6 (Def 4.1 + collapse note), p.6 (Prop 4.3 ¬-case). Cite by page; `.md` corrupt.

**Durable-anchor note:** the eventual `Theories/` module headers must cite Rabinovich PDF pages and
sibling module names, never task numbers (per `no-task-references-in-deliverables.md`). Task numbers
in this `specs/` report are permitted.
