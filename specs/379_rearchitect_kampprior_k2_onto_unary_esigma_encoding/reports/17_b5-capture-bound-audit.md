# Report 17 — B5 Capture-Bound Mismatch: Adversarial Divergence Audit

**Task:** 379 (lean4, hard mode) · **Mode:** H5 divergence audit + H4 adversarial verification ·
**Scope:** read-only; no `.lean` file modified · **Session:** sess_1784446774_b4ac7c

## Verdict (first paragraph)

**B5 is PARTIALLY-CONFIRMED — the blocker identifies a real, currently-absent piece of
infrastructure (engine-output `∈ F` membership) but MIS-DIAGNOSES its nature and
OVER-SCOPES the fix.** The load-bearing sub-claim — "the unbounded `hCapture : ∀ A : Formula, …`
is mathematically FALSE on `canonExpand`, therefore the whole uniform negation+translate stack must
be **re-derived** under an `𝔈`-bounded hypothesis plus new membership infrastructure" — is a
**true-but-irrelevant premise driving a non-sequitur conclusion.** The `∀ A : Formula` binding is an
**over-strong signature, never instantiated at any temporally-reaching `A ∉ F`.** Machine-checked
enumeration of every direct capture application site in the stack shows capture is fed **only** three
kinds of formula: (a) named atoms `.atom a` (already captured membership-free, hypothesis-free, by
`capType`/`atomEmit_capType_iff`); (b) `(translateProp35 …).neg`; (c) bracket point/segment/endpoint
`TemporalPred.formula` fields. The offending "untl-reaching-outside-`F`" counterexample that makes the
universal false is a formula the **blocker constructed** to refute the universal — the stack **never
feeds it**. The genuine residual work is therefore NOT a re-derivation but: (1) weaken the capture
hypothesis in ~5 signatures from `∀ A : Formula` to `∀ A ∈ F` (F is already a parameter in scope;
`esigmaCapture_canonExpand` already discharges that form with `𝔈 := F`); (2) prove one family of
engine-output closure lemmas (`(translateProp35 …).neg ∈ F` and the three bracket-formula
memberships); (3) mechanically thread membership at the ~7 application sites. This is the classification
the plan's OWN risk table already recorded (`plans/17…:224` — "Plumbing, not a 10P re-open"), which the
Phase-13e blocker write-up **contradicts** by escalating to "multi-file re-derivation." The one genuine
deep risk the blocker correctly flags but buries — whether F is **closable** under `translateProp35`
readback without alphabet circularity — is a **single decidable probe**, and its outcome (not the
universal's falsity) is what actually determines B5's severity. Recommended next action: a
1-phase probe proving/refuting the ~4 closure lemmas before any stack change.

---

## Reference Grounding (H3, Tier 3 — implementation-backed, Rabinovich Thm 4.4 literature anchor)

Every load-bearing claim below is cited to `file:line` read this dispatch (not from memory).

| Source | Location | Lean Identifier | Signature / fact | Status |
|--------|----------|-----------------|------------------|--------|
| Prop43Translate.lean | :552-558 | `translate_correct` | binds `hCapture : ∀ A : Formula, ∃ S, ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A` | VERIFIED read |
| Prop43Translate.lean | :569 | (δ atom case) | ONLY direct `hCapture` app in δ is `hCapture (.atom a)`, `a` from `h_surj p` | VERIFIED read |
| VeeSatNegation.lean | :99-106 | `veeSat_negation` | binds unbounded `hCapture`; applies it **never** — threads to β only | VERIFIED read |
| EFSatNegationGeneral.lean | :377-386 | `efSat_negation_general` | binds unbounded `hCapture`; threads to pair/diagonal/existence | VERIFIED read |
| EFSatNegationGeneral.lean | :282, :321 | `efSat_negation_diagonal/_existence` | ONLY direct apps: `hCapture (translateProp35 … ξ).neg`, `hCapture (translateProp35 … (pinFirst ξ)).neg` | VERIFIED read |
| ZetaUniformExtract.lean | :638-649 | `translate_uniform` | binds functional `capFn : Formula → IntervalType` + `∀ A, intervalHolds N (capFn A) y ↔ …` | VERIFIED read |
| ZetaUniformExtract.lean | :654-661 | (uniform δ atom case) | atoms use `atomEmit_capType_iff` / `capType p` — **no `hCapFn`, no `h_surj`, no membership** | VERIFIED read |
| ZetaUniformExtract.lean | :65-90 | `capType`, `intervalHolds_capType` | total `capType p`; `intervalHolds N (capType p) y ↔ N.interp p y` proven **generically over every N**, membership-free | VERIFIED read |
| ZetaUniformExtract.lean | :135,168,292,295,306-312 | (uniform leaves) | ONLY direct `capFn`/`hCapFn` apps: `(translateProp35 …).neg`, bracket `.pointTypes/.segmentTypes/.endpoint*.formula` | VERIFIED read |
| ESigmaCapture.lean | :207-219 | `esigmaCapture_canonExpand` | yields `∀ A ∈ 𝔈, ∃ S, …` for `𝔈 ⊆ F`; capture routes through `esigmaPred A hA`, `hA : A ∈ F` | VERIFIED read |
| ESigmaCapture.lean | :204-205 | (doc) | "a TL formula with genuine temporal reach outside F is not a union of complete-1-type cells" | VERIFIED read |
| ExistsForallNF.lean | :49-51 | `TemporalPred` | `structure TemporalPred where formula : Formula` — bare Formula, no `∈ F` witness | VERIFIED read |
| ExistsForallNF.lean | :53-57 | `TemporalPred.eval_at` | `= temporal_truth M atomMap t tp.formula` **definitionally** | VERIFIED read |
| Prop35Assembly.lean | :145-151 | `translateProp35` | `= translateEF1 … (efPointTP …) (efIntervalSetTP …)` — genuinely temporal (until/since walk) | VERIFIED read |
| plans/17….md | :224 | (risk table) | "relax the β/γ/δ `hCapture` argument to `∀ A ∈ 𝔈` (or `∀ A ∈ F`)… Plumbing, not a 10P re-open." | VERIFIED read |

---

## 1. Is the unbounded `hCapture` binding load-bearing at unbounded strength? — NO

Exhaustive, machine-checked enumeration (grep for every `hCapture (` / `capFn (` / `hCapFn (`
application, cross-read against each site) of **every place capture is consumed** in the whole stack:

| Site (file:line) | Formula fed to capture | Kind |
|------------------|------------------------|------|
| Prop43Translate.lean:569 (δ, non-uniform) | `.atom a`, `a` from `h_surj p` | **named atom** |
| ZetaUniformExtract.lean:654-661 (δ, uniform) | *(none — uses `capType p`)* | **atom, hypothesis-free** |
| EFSatNegationGeneral.lean:282 (diagonal) | `(translateProp35 atomMap h_surj ξ).neg` | readback·neg |
| EFSatNegationGeneral.lean:321 (existence) | `(translateProp35 atomMap h_surj (pinFirst ξ)).neg` | readback·neg |
| ZetaUniformExtract.lean:135 (diagonal, uniform) | `(translateProp35 atomMap h_surj ξ).neg` | readback·neg |
| ZetaUniformExtract.lean:168 (existence, uniform) | `(translateProp35 atomMap h_surj (pinFirst ξ)).neg` | readback·neg |
| ZetaUniformExtract.lean:292 (pair, uniform) | `(vc.bracket.pointTypes i).formula` | bracket TemporalPred |
| ZetaUniformExtract.lean:295 (pair, uniform) | `(vc.bracket.segmentTypes j).formula` | bracket TemporalPred |
| ZetaUniformExtract.lean:306-312 (pair, uniform) | `vc.endpointLeft/Right.formula` | bracket TemporalPred |

Everything else that mentions `hCapture`/`capFn` (VeeSatNegation.lean:116,137; EFSatNegationGeneral.lean:392,395,398;
ZetaUniformExtract.lean:382,385,388,508,701,704,707,729; Prop43Translate.lean:595,596,601,602,613,617) is
**threading the hypothesis to a sub-call**, never applying it. `veeSat_negation` (γ) applies capture
**zero** times directly.

**Conclusion (Q1):** The `∀ A : Formula` quantifier is **never instantiated at an arbitrary formula.**
It is only ever instantiated at (a) named atoms and (b) `translateProp35`-readbacks-negated and (c)
bracket `.formula` fields — all **engine-constructed, all determined by the input `φ`.** The binding is
an over-strong signature adopted as a proving convenience (it lets the leaves apply capture without
tracking *which* formula they feed). It is **not** load-bearing at unbounded strength. The genuinely
arbitrary `A` never appears.

Note the strongest single piece of evidence: the **uniform δ atom case (translate_uniform:654-661)
already discharges atom capture with ZERO hypothesis**, via the total membership-free function
`capType p` and the generic `intervalHolds_capType` (ZetaUniformExtract:74-90). This is a live,
sorry-free demonstration that capture at engine-constructed objects does **not** require the threaded
`∀ A` hypothesis — the analogous move for the readback/bracket objects is exactly the cheaper path.

---

## 2. Is the "unbounded form is mathematically FALSE" claim correct? — TRUE-BUT-IRRELEVANT

The narrow claim is **correct**: on `canonExpand … atomMap`, the universal
`∀ A : Formula, ∃ S, ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A` is false. Take
`A := untl p q` with temporal reach outside `F`; its truth at `y` is not determined by `y`'s complete
1-type over `F`, so no union of `UnaryType sig F` cells (which is exactly what `intervalHolds N S`
ranges over, ESigmaCapture:204-205) realizes the biconditional. Capture provably requires `A ∈ F`,
because `esigmaCapture_canonExpand` (ESigmaCapture:207-219) routes through `esigmaPred A hA` with
`hA : A ∈ F` — the fresh atom naming `A` is what makes `A`'s truth type-determined even when `A` is
temporal.

**But this counterexample is not among the formulas the stack feeds** (Section 1). It is a formula the
blocker **constructed** to falsify the universal. The wire never needs the universal; it needs only the
restriction of capture to the fed set {named atoms} ∪ {`(translateProp35 …).neg`} ∪ {bracket
`.formula`}. Whether **that** restriction holds is contingent entirely on one separate question — are
the fed formulas `∈ F`? — and is **independent of the universal's falsity.**

**Counterexample-to-the-blocker (refuting the inference, not the premise):** The named-atom fragment is
a live, sorry-free proof that a fed sub-class is captured with no `∈ F` threading at all (`capType`,
generic over `N`). The inference "universal false ⇒ re-derive stack" would equally condemn the atom
case, which is nonetheless already discharged. Hence the inference is invalid; the falsity of the
universal carries **no** information about the dischargeability of the restriction actually used.

**Conclusion (Q2):** No `A` the stack actually feeds is inherently non-capturable. Capturability of the
fed formulas is entirely contingent on the `∈ F` closure question (Section 3), which the blocker's
"mathematically FALSE" argument does not address.

---

## 3. Cheapest resolution path

Capture at ζ is discharged by `esigmaCapture_canonExpand`, which delivers the **`∀ A ∈ F` form**
(set `𝔈 := F`, `h𝔈 := subset_rfl`). So the entire task reduces to making the stack **consume the
`∀ A ∈ F` form** and proving the fed formulas are `∈ F`.

### Option (a) — 𝔈-bounded restatement + membership plumbing  **[recommended, single closure-lemma family + mechanical re-thread]**

1. **Signature weakening (mechanical, ~5 decls).** Change the capture hypothesis in
   `translate_uniform` (:638), `efSat_negation_general_uniform` (:368), `veeSat_negation_uniform` (:489),
   `efSat_negation_pair/_diagonal/_existence_uniform` (:336/:121/:152), and the non-uniform mirrors
   (Prop43Translate:557, VeeSatNegation:104, EFSatNegationGeneral:277/316/377) from
   `∀ (A : Formula), P A` to `∀ A ∈ F, P A`. `F : Finset Formula` is **already a section variable in
   scope in every one of these files** (`variable {F : Finset Formula}`), so no new parameter is
   introduced. `capFn` stays a total function; only the *proof obligation* is bounded.
2. **Engine-output closure lemmas (the one genuinely new artifact, ~4 lemmas).** Prove:
   - `translateProp35_mem_F : (translateProp35 atomMap h_surj ξ) ∈ F` (and hence `.neg ∈ F` if F is
     `.neg`-closed, or add `.neg` to F's closure);
   - `bracket_pointType_formula_mem_F`, `bracket_segmentType_formula_mem_F`,
     `endpoint_formula_mem_F` for the `vc.bracket.*/.endpoint*` TemporalPreds.
3. **Thread membership at the ~7 application sites** (EFSatNegationGeneral:282,321;
   ZetaUniformExtract:135,168,292,295,306-312): supply the membership proof as the extra `∈ F`
   argument. The leaves' internal proof bodies are otherwise **unchanged**.

This matches the plan's own risk classification (plans/17…:224) and Phase-10P's interface note.
`TemporalPred` carrying no `∈ F` witness (the blocker's objection) is **not** an obstruction under this
option: membership is supplied **externally** by the closure lemmas of step 2, keyed on the *known
structure* of `translateProp35`/`vc.bracket`, not read off the `TemporalPred` record.

**Surface:** 1 new file (`ZetaEngineClosure.lean`, ~4 lemmas + F-closure def) + edits to 5 signatures
+ 7 call-sites. **Single phase** *if* the closure lemmas hold; see the gating probe below.

### Option (b) — full re-derivation of the uniform stack (the blocker's proposal)

Re-derive `translate_uniform` + the entire negation stack under an `𝔈`-bounded hypothesis with
membership threaded through a *reworked* `TemporalPred` (carrying an `∈ F` field) and De-Morgan
closure. **Multi-file, multi-phase (~600-1000 lines), redundant:** it rebuilds proof bodies that
Option (a) leaves untouched. Justified **only** if Option (a)'s closure lemmas are false and F cannot
be closed without restructuring the bracket carriers. Not recommended as the first move.

### Option (c) — capType-style direct capture of readbacks (Subtype path)  **[attractive but blocked by temporality]**

Generalize `capType` (which captures *predicates* membership-free) to a total
`capTypeReadback : (readback object) → IntervalType` proven generic over `N`, bypassing both `𝔈` and
`∈ F`. **Verdict: does not work for the readback/bracket formulas as-is.** `capType` succeeds because
`N.interp p y` is a function of `y`'s complete 1-type; but `translateProp35 … ξ` is genuinely temporal
(`translateEF1` walks the type-chain with until/since, Prop35Assembly:145-151), so its truth at `y` is
**not** a function of `y`'s F-type unless the formula `∈ F`. Direct membership-free capture therefore
collapses back into the `∈ F` requirement. Option (c) is viable **only** for the sub-fragment whose
truth is F-type-local (which is exactly the atom fragment already handled). Documented here to close it
off, not to pursue.

### Gating probe (do this FIRST — it decides the verdict's severity)

Prove or refute, as a ~1-phase off-path probe, the four `∈ F` closure lemmas of Option (a)(2) for the
completeness F. The **real** open risk (which the blocker correctly senses but misattributes to the
universal's falsity) is **F-closure circularity**: `F` indexes the E[Σ] alphabet
(`esigmaPred A` for `A ∈ F`), and `translateProp35` reads *back into* formulas over the naming atoms
(`atomMap = oldPred ∘ g`, 13a). If F is closable under readback with bounded temporal depth (the
standard Fischer-Ladner-style argument, which Rabinovich's construction presumably guarantees), Option
(a) lands as plumbing and **B5 is effectively refuted-as-stated.** If F is *not* closable without
enlargement that changes the alphabet, the deeper restructure is real and **B5 is confirmed.** Either
way the probe — not the universal counterexample — is the decision procedure.

---

## 4. Verdict

**B5 PARTIALLY-CONFIRMED.** Real gap (engine-output `∈ F` membership infra is genuinely absent —
confirmed: no closure/membership lemma exists for `translateProp35`/bracket outputs, grep-verified).
**But the blocker over-scopes the remedy and mis-attributes the obstruction:**

- The "unbounded form is mathematically FALSE" premise is TRUE but IRRELEVANT — the offending `A` is
  never fed; the `∀ A : Formula` binding is an over-strong signature, not a load-bearing requirement.
- The proposed remedy ("re-derive the whole uniform stack + new membership infrastructure") is heavier
  than necessary. The cheaper executable path (**Option (a)**: weaken 5 signatures to `∀ A ∈ F` +
  one engine-output-closure lemma family + mechanical membership threading at ~7 sites) is exactly the
  classification the plan's own risk table recorded, and is contradicted by the 13e write-up.
- The genuine residual risk is **F-closure circularity**, resolvable by a single 1-phase probe of the
  ~4 closure lemmas — **that probe, not the universal's falsity, is what determines whether B5 collapses
  to plumbing (refuted-as-stated) or stands as a real restructure (confirmed).**

**Actionable recommendation for the next planning round:** insert ONE probe phase — "prove
`(translateProp35 …).neg ∈ F` and the three bracket-`.formula` memberships for the completeness F"
— BEFORE any signature change. Green probe ⇒ execute Option (a) as a single plumbing phase and retire
`:562`. Red probe (F not closable) ⇒ escalate to Option (b) with the circularity as the documented
root cause. Do **not** open Option (b) speculatively on the strength of the universal counterexample.

---

## Adversarial Self-Verification (H4)

I actively attempted to REFUTE B5 and to find the cheapest executable path (not to agree). The
decisive refuting evidence is the exhaustive application-site enumeration (Section 1) plus the live
membership-free `capType` atom discharge (`translate_uniform:654-661`), which together break the
blocker's "universal false ⇒ re-derive" inference.

| Claim | Source / Counterexample | Verdict |
|-------|-------------------------|---------|
| The unbounded `∀ A` hypothesis is never instantiated at arbitrary `A` | Exhaustive grep of `hCapture (`/`capFn (`/`hCapFn (` apps cross-read: only `.atom a`, `(translateProp35 …).neg`, bracket `.formula` (Prop43Translate:569; EFSatNegationGeneral:282,321; ZetaUniformExtract:135,168,292,295,306-312) | **CONFIRMED** |
| Atom capture needs no hypothesis and no membership | `capType`/`intervalHolds_capType` generic over N (ZetaUniformExtract:65-90); uniform δ atom case discharges with zero hyps (:654-661) | **CONFIRMED (lean-read)** |
| The unbounded universal is mathematically false on canonExpand | ESigmaCapture:204-205 + `esigmaPred A hA` requiring `A ∈ F` (:207-219) | **CONFIRMED (blocker correct on the narrow point)** |
| …but that counterexample `A` is fed by the stack | No site feeds an arbitrary/temporal-outside-F `A` (Section 1 enumeration) | **REFUTED — counterexample is not fed** |
| No engine-output `∈ F` closure/membership lemma currently exists | grep of Prop35Assembly / ZetaUniformExtract / EFSatNegationGeneral for `∈ F`/closure returned only doc-comments, no lemma | **CONFIRMED (blocker correct: infra absent)** |
| Capture requires the fed formulas `∈ F` (or F-type-local) | `esigmaCapture_canonExpand` routes through `esigmaPred A hA`, `hA : A ∈ F` (ESigmaCapture:207-219); `translateProp35` is temporal (Prop35Assembly:145-151), so not F-type-local unless `∈ F` | **CONFIRMED** |
| Fix requires re-deriving the whole stack (blocker) | Option (a): `F` already in scope as `variable {F}` in all 5 files; leaves apply capture only at closure-lemma-covered sites; internal proofs unchanged | **REFUTED — plumbing suffices IF closure lemmas hold** |
| Weakening to `∀ A ∈ F` is a clean drop-in | `esigmaCapture_canonExpand` already yields the `∀ A ∈ 𝔈` form with `𝔈 := F` | **CONFIRMED (discharge side); PARTIAL (consume side needs the ~4 closure lemmas — unproven this dispatch)** |
| Direct capType-style capture (Option c) avoids membership | Temporality of `translateProp35` defeats F-type-locality; collapses back to `∈ F` | **REFUTED (option closed off)** |
| F is closable under readback without circularity | NOT verified this dispatch — `atomMap = oldPred ∘ g` / F-indexes-alphabet interaction unread at depth | **UNVERIFIED — this is the gating probe; Low confidence either way** |

**Contradiction Log.** One contradiction surfaced and is **resolved**: plan risk table
(plans/17…:224, "Plumbing, not a 10P re-open") vs the Phase-13e blocker write-up ("multi-file
re-derivation… new planning round"). Resolution via source precedence (machine-checked code > prose
assessment): the code evidence (Section 1 enumeration + `capType` precedent) supports the risk table's
"plumbing" classification over the blocker's escalation, **conditional on** the closure lemmas holding.
The blocker and the risk table are reconcilable: they disagree only on whether the ~4 closure lemmas
hold, which neither party proved — hence the gating probe.

**Uncertain claim flagged (not from instinct — explicitly deferred):** whether the ~4 engine-output
`∈ F` closure lemmas are TRUE for the completeness F is **not established** this dispatch (would require
reading the F-construction at the spine and the 13a `atomMap` reconciliation at depth). This is the
single load-bearing unknown; the verdict is structured so that this probe — not the universal
counterexample — is the decision procedure. No recommendation is made to weaken any correctness
statement or add `sorry`.

**H2/anti-analysis note:** this is a read-only H5 audit, not a lemma-discovery dispatch; the "verified
mathlib candidate within 30% of calls" bar is N/A (no mathlib lemma bears on a bespoke local
encoding). The equivalent grounding — machine-read local signatures at every load-bearing claim — was
met: 14 `file:line`-cited source reads, zero claims from memory.

## Memory Candidates

1. *(pattern)* In the Kamp/E[Σ] capture stack, an `hCapture : ∀ A : Formula, …` hypothesis is an
   over-strong signature — capture is only ever applied at named atoms (`capType`, membership-free),
   `(translateProp35 …).neg`, and bracket `TemporalPred.formula` fields. The dischargeable form is
   `∀ A ∈ F`; `F` is already a section `variable` in every stack file.
2. *(anti-pattern)* "The universal `∀ A` capture is false, so the stack must be re-derived" is a
   non-sequitur: the falsity witness (untl-outside-F) is never fed. Always enumerate actual application
   sites before concluding a hypothesis is undischargeable.
