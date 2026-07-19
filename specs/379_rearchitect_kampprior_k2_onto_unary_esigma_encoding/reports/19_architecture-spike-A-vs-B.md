# Architecture Spike: Option A (infinite E[Σ]) vs Option B (semantic-collapse capture)

- **Task**: 379, Phase 13e-1 (comparative architecture spike feeding `/revise` → plan v19)
- **Agent**: lean-research-hard-agent (H2+H3+H4)
- **Reference tier**: Tier 1 (literature-backed, strict) — Rabinovich, *A Proof of Kamp's Theorem* (2014)
- **Binding**: NO Feferman–Vaught, NO novel mathematics, exact faithfulness to Rabinovich. Source = PDF pages + `chunk_00NN.md` only (companion `.md` corrupt).
- **Untouched**: `EANegation.lean:1090/:1249`; `KampPrior.lean` (`:562`); k≥2 anchor `nf_nvar_exist_all_depths` (`| _k + 2` arm). No task-number pointers in `Theories/**/*.lean`.
- **Probe landed (off-path, green, axiom-clean)**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/OptionBLocalityProbe.lean`.

## RECOMMENDATION (up front): **A** — with B ruled out as a NO-GO, and A gated by a de-risking first phase

- **Option B is a NO-GO** (machine-checked, not a proof gap). The semantic capture Option B needs —
  a `capFn : Formula → IntervalType sig F` capturing a readback's truth set without `∈ F` — is
  **false** for genuine-temporal-reach readbacks under the current `IntervalType`. Proved this
  dispatch: `capFn_forces_local` (probe) shows any `IntervalType` capture forces the captured
  formula's truth to be 1-type-local; readback `Until`/`Since` chains are provably non-local.
  Making B work requires redesigning `IntervalType` to carry order/temporal structure — the same
  machinery Option A introduces — i.e. novel machinery, forbidden by the binding.
- **Option A is the only faithful path.** It is literally Rabinovich Def 4.1 (E[Σ] = *all* TL(U,S)
  formulas over Σ, infinite), requires **no invented mathematics**, and — decisively — its blast
  radius is **contained to the `WeakCanonical/Kamp/` track**: `sigE` never reaches
  `BXCanonical/Completeness.lean` or `Decidability/` (grep-verified, both empty), so the
  completeness/decidability/FMP spine is **not** at risk. The cost is large but structural, not
  mathematical.
- **A is large.** It is a foundational re-encoding (remove the `Fintype preds` requirement baked
  into `MonadicSignature`; re-represent unary types by per-formula finite atom sets rather than
  `Finset.univ` enumeration). Recommend proceeding via a **de-risking Phase 1** that decouples the
  type-representation from `Finset.univ` for a single formula BEFORE committing to the full
  refactor; that phase is the honest go/no-go gate on A's true difficulty. There is no third
  faithful option (finite-F is refuted by `not_readbackClosed`), so if the gate fails the only
  fallback is escalation.

---

## H3 Reference Grounding — 5-column mapping table (PDF-page-cited)

| Rabinovich PDF page | Repo construct | Obligation | Faithful? | Note |
|---|---|---|---|---|
| **Def 4.1, p.5** (chunk_0011): E[Σ] = Σ ∪ {A \| A a TL(U,S)-formula over Σ} — **infinite**; canonical expansion interprets every A ∈ E[Σ] | `sigE sig F` = `sig.preds ⊕ {A // A ∈ F}`, finite `F` (`ESigmaExpansion.lean:63`) | Alphabet indexes the readback atoms | **NO (finite-F departure)** | Rabinovich's E[Σ] is infinite; repo indexes by finite `F`. **Option A restores the infinite index** (faithful); **Option B keeps finite `F`** (departure retained). |
| **Def 4.1 collapse note, p.6** (chunk_0011): "if A is a TL(U,S) formula over E[Σ] predicates it is equivalent to a TL(U,S) formula over Σ, hence to an **atomic** formula in the canonical expansion" | `canonExpand` interp of fresh atom = `sat A` (`ESigmaExpansion.lean:104-106`); `canonExpand_atom_named` (`ESigmaCapture.lean:187`) | Readback is an atom of the expansion | **partial** | The collapse works **because E[Σ] is infinite** — every TL formula is *already* an atom. On finite `F` the collapse target atom must be `∈ F` (`esigmaPred A hA`). This is precisely the seam both options attack. |
| **Def 3.1, p.4** (chunk_0009): ∃∀-formula; all αⱼ,βⱼ **quantifier-free unary** over Σ | `UnaryType sig F := NormalForm (sigE sig F) 0 1`; `IntervalType := Finset UnaryType` (`ExistsForallFormula.lean:57,87`) | Point/interval types are unary (arity-1) | **YES (as far as it goes)** | αⱼ,βⱼ are *local* quantifier-free unary conditions. `intervalHolds` (`:93`) is `∃τ∈S, unaryHolds` = a **union of complete-1-type cells** — a purely point-local truth set. This locality is the Option-B ceiling. |
| **Prop 3.5, p.5** (chunk_0010): every ∨∃∀-formula with one free var ≡ a TL(U,S) formula | `translateProp35` (`Prop35Assembly.lean:145`), `LiftPair.lean` `charType`/`skelDisjunct` | Readback ∃∀-object → TL formula | **YES (but over-encoded)** | Repo proves this by enumerating `Finset.univ : Finset (UnaryType)` — "type = finite disjunction over ALL 1-types". Faithful *content*, but the **`Finset.univ` finiteness is stronger than Rabinovich needs** (each formula mentions finitely many atoms; Rabinovich never enumerates the whole alphabet). This over-encoding is exactly what an infinite E[Σ] (Option A) must unwind. |
| **Prop 4.2/4.3, p.6** (chunk_0012): ¬(∨∃∀) ≡ ∨∃∀ in the expansion by **all** TL-definable predicates; structural induction | `VVecEA2.negFix_iff` (`VecEANegFix.lean:164`), `prop42_contentful_of_attained` (`Section5Correspondence.lean:115`) | De Morgan fold of the negation | **partial (attained carrier)** | Landed but lives in the `VVecEA2`/bracket `(z₀,z₁)` world and produces a `VVecEA2` witness, **not** an `IntervalType`. Does NOT bridge "readback truth set = IntervalType" (the Option-B need). "in the expansion by **all** TL predicates" again = infinite E[Σ]. |
| **Thm 4.4, p.6** (chunk_0012): φ ≡ ⋁ᵢ φᵢ (finite, Prop 4.3), each φᵢ →Prop 3.5→ TL | `translateProp35` consumers at ζ sites (`ZetaUniformExtract.lean:135,168`) | Readback lands "in the alphabet" | **NO (as finite-F)** | In Rabinovich the readback is automatically an atom of the (infinite) expansion; needs no `∈ F`. Requiring `translateProp35 ξ ∈ F` for finite `F` has no Thm 4.4 counterpart (refuted by `not_readbackClosed`). |

---

## Option A — Infinite-alphabet E[Σ] (blast-radius mapping)

### A2 (crux, stated first because it is dispositive)

**`MonadicSignature` structurally REQUIRES `Fintype preds` and `DecidableEq preds` as instance
fields** (`MonadicFO.lean:41-44`):

```lean
structure MonadicSignature where
  preds : Type
  [fintypePreds : Fintype preds]
  [decEqPreds : DecidableEq preds]
```

Consequence: an infinite-alphabet signature is **not constructible as a `MonadicSignature` at all**.
`sigE` itself (`ESigmaExpansion.lean:63-66`) supplies `fintypePreds := inferInstance`; with an
infinite index type that `inferInstance` fails and `sigE` does not typecheck. The atom/normal-form
layer is downstream of this field:
- `AtomKind sig n` `Fintype`/`DecidableEq` instances (`NormalForm.lean` ~94, ~63) consume
  `Fintype/DecidableEq sig.preds`.
- `NormalForm sig k n := AtomKind sig n → Bool`; its `Fintype × DecidableEq` proof relies on
  `Fintype (AtomKind sig n → Bool)`, i.e. on `Fintype/DecidableEq sig.preds`.
- `atomKind_card`/`normalForm_card` compute `Fintype.card sig.preds` — meaningless if infinite.

So `NormalForm`/`AtomKind` do **not** admit an infinite alphabet: finiteness is baked into the
type-class layer. Option A is therefore not "re-index a parameter" but "**remove the `Fintype preds`
requirement and re-encode everything that used it**."

### A1 (load-bearing sites — where finiteness of `F` / `Fintype (sigE sig F).preds` is load-bearing)

**Containment (the good news, verified this dispatch).** `sigE` occurs **only** under
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` (25 live files + Boneyard). It is **absent** from
`BXCanonical/` (incl. `Completeness.lean`/`completeness_discrete`) and **absent** from
`Decidability/` (incl. all of `Decidability/FMP/*`). The spine reaches the Kamp track only through
the arity converter `nf_nvar_exist_all_depths` (`KampPrior.lean:361/364`), stated over the **base**
signature `NormalForm sig k n`, not over `sigE`. **The E[Σ] alphabet is a purely internal
implementation detail of the Kamp negation/readback track; it never leaks into the completeness or
decidability spine.**

The single load-bearing chain:
```
UnaryType sig F := NormalForm (sigE sig F) 0 1        -- ExistsForallFormula.lean:57
IntervalType sig F := Finset (UnaryType sig F)         -- ExistsForallFormula.lean:87
```
`Fintype (UnaryType sig F)` unfolds to `Fintype (sigE sig F).preds = Fintype (sig.preds ⊕ {A // A ∈ F})`
— finite precisely because `F : Finset Formula`. Every model-enumeration site below is a
`Finset.univ` over `UnaryType` (or tuples of it) and breaks the moment `F` is infinite:

- `IntervalType.lean:70` — `(Finset.univ : Finset (UnaryType sig F))` (interval-type enumeration).
- `ESigmaCapture.lean:92,95` — `Finset.univ.filter (fun τ => τ a₀ = true)` feeding `intervalHolds`.
- `ZetaUniformExtract.lean:66` — `Finset.univ.filter …`.
- **`LiftPair.lean:101,246,596,869`** — `(Finset.univ : Finset (Fin (K+1) → UnaryType sig F))`
  skeleton disjunction (`charType:58`, `skelDisjunct`, `skelR_sat`, `liftPair_forward/backward`).
  **The heaviest single consumer.**
- `Prop43Translate.lean:344` — `(Finset.univ : Finset (Fin (m+1) → UnaryType sig F)).filter …`.
- `ConjInterleave.lean` — `Fintype`-enumeration + `Finset.card_image_le` (679/682).

`DecidableEq`-dependent: every `τ a₀ = true` membership test relies on
`DecidableEq (AtomKind (sigE sig F) 1)` ⇒ `DecidableEq (sigE sig F).preds`. `Finset`-subtype
membership: `esigmaPred`/`oldPred`/`canonExpand` pattern-match `Sum.inr ⟨A, hA⟩` with the
proof-carrying `hA : A ∈ F` that makes `{A // A ∈ F}` a `Fintype`.

### A3 (LOC + risk + hardest obligation)

- **Files**: ~26 live `WeakCanonical/Kamp/*` (every `sigE` consumer) + 2 foundational
  (`MonadicFO.lean`, `NormalForm.lean`). Decidability/FMP: **0**.
- **Declarations**: order of **60–100+** (the `UnaryType`/`intervalHolds`/`charType`/`skel*`/
  `liftPair_*`/`Prop43Translate` cluster alone is dozens).
- **LOC churn estimate**: **~1,500–3,000+ lines rewritten** (re-proving committed green machinery
  under a new type representation), high risk — this rewrites landed, axiom-clean assets.
- **Spine/decidability risk**: **LOW** — containment proven (`sigE` never reaches the spine).
- **Single hardest obligation**: replacing the **`Fintype (UnaryType sig F)` model-enumeration** in
  `LiftPair.lean` (`charType`/`skelDisjunct`/`liftPair_forward`/`liftPair_backward`) and
  `Prop43Translate.lean`. The Rabinovich construction turns a semantic 1-type into a *finite
  disjunction over all realizable unary types* and proves forward/backward equivalence by `Finset`
  enumeration. Without `Fintype (sigE sig F).preds`, `UnaryType` is an infinite function space,
  `Finset.univ` does not exist, and "type = finite disjunction of atoms" has no finite syntactic
  form — the finiteness is what makes a semantic type expressible as a `MonadicFormula` at all. The
  faithful fix is to carry **per-formula finite atom sets** (each Rabinovich formula mentions
  finitely many atoms) instead of total assignments to the whole alphabet. That is the foundational
  re-encoding; it is the de-risking gate below.

---

## Option B — Semantic-collapse capture (truth-lemma seam)

### B1 (the semantic capture obligation, precisely)

The ζ consumers take capture as an undischarged parameter. Functional form
(`ZetaUniformExtract.lean:124-129,155-160,246-251`):
```lean
(capFn  : Formula → IntervalType sig F)
(hCapFn : ∀ (A : Formula) (y : N.carrier),
            intervalHolds N (capFn A) y ↔ temporal_truth N atomMap y A)
```
Existential form actually consumed at the ζ leaves (`EFSatNegationGeneral.lean:277-278,316-317`):
```lean
hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
             ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A
```
Option B must discharge this **for `A = (translateProp35 atomMap h_surj ξ).neg`** (and, in the
arity-2 bridge, the bracket point/segment/endpoint `.formula`s) — exactly the genuine-temporal-reach
readbacks. Grounding in the p.6 collapse note (chunk_0011): a TL formula over E[Σ] ≡ an atom of the
canonical expansion. On finite `F` that atom must be `esigmaPred A` with `A ∈ F` — the very
requirement B wants to eliminate.

### B2 (does landed machinery already supply the bridge? — NO)

- **`VVecEA2.negFix_iff`** (`VecEANegFix.lean:164/177`): De Morgan fold `v.negFix.holds ↔ ¬ v.holds`
  on attained structures. Produces a `VVecEA2` witness at the `(z₀,z₁)` pair level — **not** an
  `IntervalType`. No movement toward "readback truth set = IntervalType".
- **`prop42_contentful_of_attained`** (`Section5Correspondence.lean:115`): pure wiring
  `⟨v.negFix, … negFix_iff …⟩`; product is a `VVecEA2` `v'`, again not an interval capture. Also
  carrier-restricted to `HasAttainedINF`/`SUP` (strictly stronger than the paper's Dedekind
  completeness — `hasDefinableINF_excludes_kplus`, `Lemma53.lean:282`).
- **`nf_eval_efold`** (`NfEFold.lean:102`; `nf_eval_efold_zero_iff` is `Iff.rfl` to `nf_eval_nf` at
  depth 0): explicitly off the live path; an internal 1-type/segment evaluator. Does not relate a
  readback's truth set to any `IntervalType`.

Every ζ negation theorem threads `capFn`/`hCapFn` as an **undischarged hypothesis**
(`EFSatNegationGeneral.lean:272,311` docstrings: "`hCapture` threaded, never discharged"). None
*builds* a `capFn` for readbacks. **The bridge is NOT re-assembly of landed lemmas** — the missing
step ("a readback Until/Since chain's truth set IS a union of complete-1-type cells") is exactly
what report R1 (`ESigmaCapture.lean:203-205`) says is **false**.

### B3 (prototype the seam — machine-checked RED)

`IntervalType sig F := Finset (UnaryType sig F)` and `intervalHolds N S y := ∃ τ ∈ S, unaryHolds N τ y`
with `unaryHolds` = atom-wise agreement at the single point `y` (`unaryHolds_iff`). So
`intervalHolds N S y` factors through the E[Σ]-1-type of `y` alone. Landed this dispatch in
`OptionBLocalityProbe.lean` (green, axioms `[propext, Classical.choice, Quot.sound]`, no `sorry`):

- `unaryHolds_local` / `intervalHolds_local`: two points sharing every E[Σ] atom at `Fin 1` are
  **indistinguishable** by any `IntervalType` — an `IntervalType` can only express point-local
  (union-of-1-type-cell) truth sets.
- **`capFn_forces_local`** (the RED core): if any `S : IntervalType sig F` satisfies the ζ obligation
  `intervalHolds N S y ↔ temporal_truth N atomMap y A` for all `y`, then `temporal_truth · A` is
  forced 1-type-local. **Contrapositive**: any readback whose truth distinguishes two
  1-type-equal points (every genuine-temporal-reach `Until`/`Since` chain — provably not a
  subformula of the input, `ZetaEngineClosure.lean:49`) is capturable by **no** `IntervalType sig F`,
  **for any `F`**.

The `capFn : Formula → IntervalType sig F` signature type-checks against the consumers (it is the
consumer signature verbatim), but the obligation is **unsatisfiable** for the fed readbacks. This is
the identical wall to the refuted finite-FL path (`not_readbackClosed`, `ZetaReadbackClosure.lean:178`),
now proven at the semantic (truth-set) level rather than the syntactic (`∈ F`) level.

- **LOC + risk**: to make B work you must change `IntervalType` from `Finset UnaryType` to a type
  carrying order/temporal structure so `intervalHolds` can express non-local truth sets — i.e.
  rebuild the interval layer AND everything routing through it (`ExistsForallFormula`, `efSat`,
  `LiftPair`, the whole `Kamp` negation stack). That is **≥ Option A's cost** and introduces
  **novel machinery** (an order-aware interval semantics with no direct Rabinovich counterpart at
  Def 3.1). **Hardest single obligation**: give `intervalHolds` genuine `Until`/`Since` reach while
  keeping the finite decidability the spine's Kamp interface assumes — which is self-defeating,
  since the finiteness *is* the locality that fails. **NO-GO under the no-novel-math binding.**

---

## Comparison Table

| Dimension | Option A — infinite E[Σ] | Option B — semantic-collapse capture |
|---|---|---|
| **Faithfulness (PDF)** | **Highest.** Literally Def 4.1 p.5 (E[Σ] = all TL(U,S) formulas over Σ, infinite) + p.6 collapse. No invented math. | **Fails as stated.** Wants the p.6 collapse on a *finite* `F`; the collapse is enabled *by* infinity. Achieving it needs an order-aware `IntervalType` with no Def-3.1 counterpart. |
| **Blast radius (files/decls)** | ~26 `Kamp/*` + `MonadicFO.lean` + `NormalForm.lean`; **60–100+ decls**. Decidability/FMP: 0. Contained to Kamp track (grep-verified). | To actually discharge: rebuild `IntervalType`/`intervalHolds` + all consumers ≈ the same ~26 `Kamp/*` files + `ExistsForallFormula` core. |
| **LOC estimate** | **~1,500–3,000+** rewritten (re-prove committed machinery under per-formula finite-atom representation). | **≥ A**, plus it is novel (not transcription). If left "as stated" (no `IntervalType` change): **0 lines of valid progress** — obligation is false (`capFn_forces_local`). |
| **Hardest single obligation** | Replace `Fintype (UnaryType)` `Finset.univ` model-enumeration in `LiftPair.lean`/`Prop43Translate.lean` with per-formula finite atom sets ("type = finite disjunction of atoms" without a total `Finset.univ`). | Give `intervalHolds` genuine temporal reach while keeping finite decidability — self-defeating; the finiteness is the locality that fails. Novel semantics = binding violation. |
| **Spine/decidability risk** | **LOW.** `sigE` never reaches `BXCanonical/`/`Decidability/`; spine interface is `nf_nvar_exist_all_depths` over base `sig`. | **N/A** (path is a NO-GO). Were it forced, changing `IntervalType` touches every `efSat` consumer, higher coupling. |
| **Reuse of landed assets** | **Low.** Committed `UnaryType`/`IntervalType`/`LiftPair`/capture proofs are rewritten. `canonExpand` semantic core + `translateProp35`/negation *shape* survive. | **Low and misleading.** `negFix_iff`/`prop42_contentful` reused but they do not touch capture; the capture core (`intervalCapture_of_atomNamed`) is exactly what must be discarded. |
| **Verdict** | **Faithful, large, spine-safe — the recommended path (gated).** | **NO-GO** (machine-checked false; or a bigger, novel rebuild). |

---

## /revise Scope for plan v19 (recommended option: A)

**Framing**: Option A is faithful and spine-safe but is a foundational re-encoding of the Kamp
type-representation. Structure v19 so the hardest obligation is a **go/no-go gate in Phase 1**,
before rewriting the 26-file consumer surface.

**Phase 1 (DE-RISKING GATE — one bounded implement dispatch, ~150–350 lines, off live path).**
Prototype the per-formula-finite-atom representation of a unary type on a *single* readback,
without touching committed files:
- New off-path module (e.g. `Kamp/InfAlphabetProbe.lean`) defining a candidate `UnaryTypeFin` that
  carries a **finite `Finset (AtomKind …)`** the formula mentions (partial assignment), plus its
  `intervalHolds`-analog, and proving the Prop-3.5 "type = finite disjunction of atoms" equivalence
  for ONE `translateProp35 ξ` **without `Finset.univ`** over the whole alphabet.
- **Success criterion (the gate)**: this equivalence builds sorry-free and axiom-clean. If it does
  NOT close without re-introducing a full-alphabet `Finset.univ`, **STOP and escalate** — that is
  the machine-checked signal that A's re-encoding is intractable and no faithful path remains.
- **File**: new probe only. No edits to `MonadicFO.lean`/`NormalForm.lean`/live `Kamp/*` yet.

**Phase 2 (foundational type-class change).** Remove `[fintypePreds]` from `MonadicSignature`
(`MonadicFO.lean:43`); thread finiteness as an explicit per-formula hypothesis where currently
implicit. Re-derive `AtomKind`/`NormalForm` instances (`NormalForm.lean`) under the new discipline.
Scoped, foundational, must build the two foundational files green before proceeding.

**Phase 3 (re-index `sigE`).** Change `sigE`'s fresh part from `{A // A ∈ F}` to the full `Formula`
type (infinite E[Σ]); update `esigmaPred`/`canonExpand`/`ESigmaCapture` so `esigmaPred A` needs no
`hA : A ∈ F`. This is where `not_readbackClosed`/`ReadbackClosed` become *vacuous* (readbacks are
automatically atoms) — delete the `ZetaReadbackClosure`/`ZetaEngineClosure` RED probes.

**Phase 4 (re-encode the enumeration surface).** Rewrite `LiftPair.lean` /
`Prop43Translate.lean` / `IntervalType.lean` / `ConjInterleave.lean` off `Finset.univ` onto the
Phase-1 per-formula representation. Largest phase; split per file.

**Phase 5 (re-wire ζ consumers).** `ZetaUniformExtract` / `EFSatNegationGeneral`: the capture
obligation is discharged directly (readback is an atom), removing the `hCapture`/`capFn`
parameters. Confirm `KampPrior` interface (`nf_nvar_exist_all_depths`) and `completeness_discrete`
unchanged (they never saw `sigE`).

**First bounded implement dispatch**: **Phase 1 only** (the gate). It is off the live path,
~150–350 lines, sorry-free-or-escalate, and decides whether the ~1,500–3,000-line A refactor is
worth starting. Do not authorize Phases 2–5 until Phase 1 is green.

---

## Adversarial Self-Verification (H4)

I tried to refute my own blast-radius and LOC estimates and the two verdicts before publishing.

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `MonadicSignature` requires `Fintype`+`DecidableEq` on `preds` as fields ⇒ infinite alphabet not constructible | `MonadicFO.lean:41-44` verbatim | Direct source read | **High** |
| `sigE` is confined to `WeakCanonical/Kamp/`; absent from `BXCanonical/` and `Decidability/` (spine-safe) | `grep -rln sigE` on both trees returned empty; only `Kamp/*` hits | `lean_local_search`-class grep, run this dispatch | **High** |
| Spine interface is `nf_nvar_exist_all_depths` over base `sig`, not `sigE` | `Completeness.lean:357,369`; `KampPrior.lean:361/364`; `KampPrior` has no `sigE`/`IntervalType`/`UnaryType` refs | grep of `KampPrior.lean` (empty) + `Completeness.lean` refs | **High** |
| `intervalHolds` is 1-type-local ⇒ captures only union-of-1-type-cell truth sets | `capFn_forces_local`, `intervalHolds_local` (OptionBLocalityProbe.lean) | **Machine-checked** — built green, axioms `[propext, Classical.choice, Quot.sound]`, no `sorry` | **High** |
| Readback Until/Since chains are non-local (distinguish 1-type-equal points) ⇒ uncapturable by any `IntervalType` | `ZetaEngineClosure.lean:49` (readbacks not subformulas); `ESigmaCapture.lean:203-205` (R1); `not_readbackClosed` (unbounded `numUntl`) | Committed lemmas + probe contrapositive | **High** |
| Landed `negFix_iff`/`prop42_contentful`/`nf_eval_efold` do NOT build a `capFn` for readbacks | `VecEANegFix.lean:164`, `Section5Correspondence.lean:115`, `NfEFold.lean:102` — all produce `VVecEA2`/internal, thread `capFn` undischarged | Source read of each decl + ζ consumers | **High** |
| Option A LOC ~1,500–3,000+, ~60–100 decls | Extrapolated from ~26 files × committed proof density; `LiftPair`/`Prop43Translate` clusters | **Estimate** — file/decl counts are grep-solid; line counts are projected | **Medium** |
| Option B, if forced via `IntervalType` redesign, is ≥ A and novel | Inference: temporal-reach interval semantics has no Def-3.1 counterpart | Reasoning from Def 3.1 (αⱼ,βⱼ quantifier-free unary) | **Medium-High** |

### Refutation attempts (steelman each verdict's opposite)

- **Tried to save Option B**: "the ζ consumers only feed *finitely many* input-derived readbacks, so
  maybe each specific one's truth set happens to be 1-type-local in `canonExpand`." Refuted:
  `capFn_forces_local` is model-general; and the ζ engine's readbacks are synthesized U/S chains
  with reach beyond input subformulas (`ZetaEngineClosure.lean:49`), so on any model with two
  1-type-equal points of differing future they are non-local. A specific model where they collapse
  would be a *semantic accident*, not a discharge of the `∀ N` obligation the consumers state.
- **Tried to shrink Option A**: "keep `sigE` finite but only enlarge `F` to the input-derived
  readback closure." That is the finite-FL path already **refuted** in report 18 / `not_readbackClosed`
  (alphabet strict-mono, no fixpoint). Not a distinct cheaper A.
- **Tried to inflate Option A's spine risk** (to force "escalate" over "A"): searched `BXCanonical/`
  and `Decidability/` for `sigE`/`UnaryType`/`IntervalType` — empty. The containment holds, so the
  spine-risk dimension genuinely favors A; I could not manufacture spine risk.
- **Tried "both-costly-escalate" as the recommendation**: rejected because B is not merely costly —
  it is machine-checked *false* as stated. Presenting it as a co-equal costly option would misstate
  the finding. A is the only faithful path; the honest recommendation is A **with** the Phase-1
  gate that surfaces its true cost within one dispatch (and escalates if the gate fails).

### Contradiction Log
- **Apparent tension**: Option B was framed in the handoff as "preserves the finite `sigE sig F` /
  decidability spine; needs a truth-lemma-level bridge, not a Finset closure." **Resolution**
  (precedence: machine-checked probe > handoff framing): the truth-lemma bridge B needs is
  `capFn_forces_local`-refuted for temporal-reach readbacks; B preserves the finite spine only by
  NOT discharging the obligation. No UNRESOLVED contradiction — the framing's premise is what the
  probe falsifies.

### Recommendations modified after verification
- Downgraded B from "costly alternative" to **NO-GO** after the probe made the ceiling a theorem.
- Upgraded A's standing from "large, cross-cutting, high risk" (report 18's framing) to "large but
  **spine-safe and contained**" after verifying `sigE` never reaches the spine — the single most
  decision-relevant correction this dispatch.
- Added the **Phase-1 de-risking gate** so the recommendation of A is not an open-ended commitment:
  one bounded dispatch decides go/no-go, with escalation as the defined failure branch.

## References
- Rabinovich (2014), *A Proof of Kamp's Theorem*: Def 3.1 (p.4), Lemma 3.2/3.4/Prop 3.5 (p.5),
  **Def 4.1 (p.5)** + collapse note (p.6), Prop 4.2/4.3, Thm 4.4 (p.6); chunks 0009–0012.
  Companion `.md` corrupt — not used. PDF `Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
- Probe (this dispatch, off-path, green, axiom-clean): `OptionBLocalityProbe.lean`
  (`unaryHolds_local`, `intervalHolds_local`, `capFn_forces_local`).
- Foundational: `MonadicFO.lean:41` (`MonadicSignature`), `NormalForm.lean` (`AtomKind`,
  `NormalForm`, cards).
- Kamp seam: `ESigmaExpansion.lean:63` (`sigE`), `ExistsForallFormula.lean:57,87,93`
  (`UnaryType`/`IntervalType`/`intervalHolds`), `ESigmaCapture.lean:81,187,207` (capture),
  `ZetaEngineClosure.lean` / `ZetaReadbackClosure.lean:178` (`not_readbackClosed`).
- Landed Option-B candidates (do NOT bridge capture): `VecEANegFix.lean:164`,
  `Section5Correspondence.lean:115`, `NfEFold.lean:102`.
- Spine interface: `Completeness.lean:357,369`, `KampPrior.lean:361/364` (`nf_nvar_exist_all_depths`).
- Prior grounding: report 18 (`18_readback-closed-finite-fl-rescope.md`).
