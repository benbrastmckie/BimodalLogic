# TM+/TM Conservativity Bridge — Research Report

**Task**: 413 — Formalize the TM+ over TM conservativity bridge in Lean 4
**Task type**: lean4
**Session**: sess_1787618565_717c84_413
**Dispatch**: 5
**Date**: 2026-08-24

---

## 1. Headline Findings

1. **The task's two anchor premises are stale.** `\label{thm:ConservativeExtension}` no longer
   exists in the paper — it was deleted on 2026-08-14. The `cor:tm-completeness` footnote the
   task description quotes ("parametric variant of the semantics… shift-closed set of
   histories… strand construction") also does not exist in the live paper or in the pinned
   record. The task's own ANCHORS stamp is dated 2026-08-10 and was correct then.

2. **The specific proof the task asks for is refuted, not merely hard.** The task says "prove
   that TM+ derivability of a translated BL-formula yields TM derivability." That is the
   *forward* direction of CEB/CEF/CED/CEC. The paper's own final revision of
   `thm:ConservativeExtension` — the one deleted — states that the forward direction **fails**
   for CEB and CEF and is **open** for CED and CEC. Only the *backward* direction (TM ⊢ φ ⟹
   TM+ ⊢ tr φ) holds unconditionally. Both failure witnesses are reproducible against this
   repository's actual axiom set (§4).

3. **The backward direction is a clean, achievable, zero-sorry deliverable**, and it is the
   substance of everything else the task asks for (BL Formula type, TM axiom set, TM derivation
   trees, translation). Three of the four rows can be closed with assets already in the tree;
   the fourth (Discrete/CEF) has one genuine open sub-obligation (§6).

4. **Four foundational lemmas were prototyped and compile clean** against the live tree via
   `lean_run_code` — including the load-bearing `tr(swapBL φ) = swapTemporal (tr φ)`
   commutation lemma that the temporal-duality rule needs (§7).

**Recommendation**: re-scope to the backward direction plus a machine-checked *refutation
scaffold* for the forward direction, and route the anchor staleness to the user before any
plan is written. Do **not** attempt the forward direction as stated — it would require a
`sorry` on a false statement, which the zero-debt gate forbids.

---

## 2. Anchor Verification (run per task instruction)

`bash scripts/check-paper-definitions.sh` was run against
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`. Result: **case (b)
with two drifted anchors and six dangling anchors**:

| Anchor | State |
|---|---|
| `def:strongest` | DRIFTED ("strongest objective **normal** modal operator" → "strongest objective modal operator") |
| `thm:exist` | DRIFTED (same word dropped) |
| `def:frame#Compositionality`, `def:frame#Seriality`, `def:frame#Limit`, `def:frame#Spherical` | DANGLING |
| `thm:s4`, `thm:sym` | DANGLING |

None of these are consumed by this task. But two anchors this task *does* depend on were
checked directly against the paper source:

### 2.1 `thm:ConservativeExtension` — **DOES NOT RESOLVE**

```
$ grep -c -i "conservat" /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex
0
$ grep -n "CEB\|CEF\|CED\|CEC" .../possible_worlds.tex
2829:%   - The single prose occurrence PRECEDING the coinage of the term...   [unrelated]
```

The word "conservative" does not appear anywhere in the live paper. Bisecting the paper repo's
history: the last commit carrying `\label{thm:ConservativeExtension}` precedes **c0116d04
(2026-08-14, "midway on appendix")**, which is the first commit with zero occurrences. The
theorem, its four rows, and its proof were all deleted there.

This is independently corroborated inside this repository: `typst/chapters/p2-frame-classes.typ`
carries `// CONFIRM(paper): a conservative-extension theorem for the tense-primitive subsystem
is stated (successor of the deleted thm:ConservativeExtension).` and `typst/SYNC-MAP.md`
whitelists `thm:ConservativeExtension` as a "deliberate negative-resolution" citation. The
paper's live text at line 180-182 of that chapter now says the tense-primitive subsystem and
"establishing a proof-system conservativity theorem relating it to the full system, is that
subsystem's own future result rather than part of this book's system."

### 2.2 `cor:tm-completeness` — resolves, but **not with the content the task attributes to it**

The live text matches the pinned record at `specs/paper-definitions-of-record.md` (sha256
`68e3ea9a…`) exactly — the checker reports no drift. Its full content is four completeness rows
for **BL⁺ systems only** (TM⁺ strongly complete over all task frames; TM⁺_d strongly complete
over dense; TM⁺_f weakly complete over ℤ-time; TM⁺_c weakly complete over dense-and-complete),
plus one footnote reading in full:

> These results, together with the soundness of the corresponding systems, have been
> established in the Lean 4 repository for this paper, and so their proofs are not reproduced
> here.

There is **no** mention of a parametric semantics, shift-closed history sets, a strand
construction, `cor:occurrence`, or the Compositionality/Seriality/Spherical transfer
obligations. `grep -i "strand\|shift-closed\|parametric variant"` over the paper returns
nothing. The corollary also makes **no claim about TM at all** — so the premise that this
bridge "supplies the missing step in the paper's `cor:tm-completeness` route" no longer holds
as stated: the live route does not pass through TM.

**Consequence for the task's citation rule.** The instruction "cite by `\label` only" cannot be
satisfied for `thm:ConservativeExtension`. The mathematics below is therefore cited to the
**last paper revision that carried the theorem** (`58c7c0c0^:JPL/possible_worlds.tex`,
2026-08-12), explicitly flagged as historical, plus the live, resolving anchors that survive
(`def:BLplus-language`, `def:BLplus-defined`, `thm:BLplus-PastFuture`, `def:TMplus`,
`def:TMplus-f`, `def:TMplus-d`, `def:TMplus-c`, `def:BX`, `def:S5`) and the informal `\S
sub:Logic` TM axiomatization, which **is** live.

---

## 3. Literature Proof Structure

**Source**: `thm:ConservativeExtension` [Conservative Extension] as of the paper revision
immediately preceding commit `58c7c0c0` (2026-08-12), and its live successor context in
`\S sub:Logic` (TM axiomatization) and `def:TMplus`/`def:TMplus-{f,d,c}` (TM⁺ axiomatization).

**Strategy**: directional. Backward by structural embedding; forward by counterexample per row.

### 3.1 The two languages

`def:BL-language` (live, `\S sub:Logic`, line 1180):

> `BL = ⟨SL, ⊥, →, □, H, G⟩` with `φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | Hφ | Gφ`

(The paper writes `\Past`/`\Future` for the *universal* H/G and `\past`/`\future` for the
existential P/F. Getting this backwards transcribes a different logic.)

`def:BLplus-language` (live): `BL⁺ = ⟨SL, ⊥, →, □, since, until⟩`, with H/G/P/F all *derived*
(`def:BLplus-defined`, `thm:BLplus-PastFuture`).

### 3.2 TM (live, `\S sub:Logic` lines 1183-1204)

> the *Logic of Tense and Modality* **TM** is the smallest extension of **CPL** closed under all
> instances of the following axiom and rule schemata

| Key | Schema |
|---|---|
| MP | `φ, φ → ψ ⊢ ψ` |
| MN | if `⊢ φ` then `⊢ □φ` |
| MK | `□(φ→ψ) → (□φ → □ψ)` |
| MT | `□φ → φ` |
| M5 | `◇□φ → □φ` |
| MF | `□φ → □Gφ` |
| TD | if `⊢ φ` then `⊢ φ⟨P|F⟩` (interchange all H and G) |
| TK | `G(φ→ψ) → (Gφ → Gψ)` |
| T4 | `Gφ → GGφ` |
| TB | `F⊤` |
| TA | `φ → G P φ` |
| TL | `(Fφ ∧ Fψ) → [F(Fφ ∧ ψ) ∨ F(φ ∧ ψ) ∨ F(φ ∧ Fψ)]` |

Extensions (live, `\S sub:Extension`): **TM_f** = TM + **DF** `(Hφ ∧ φ ∧ F⊤) → F(Hφ)`;
**TM_d** = TM + **DN** `GGφ → Gφ`; **TM_c** = TM + **CO** `△(Hφ → F Hφ) → (Hφ → Gφ)`;
**TM_dc** = minimal extension of both.

Note TM has **no** primitive temporal necessitation rule; `⊢ φ ⟹ ⊢ Gφ` is derivable from
MN + MF + MT (necessitate, then `□φ → □Gφ → Gφ`). This matters when translating: TM's rules to
simulate are exactly MP, MN, TD.

### 3.3 Step map of the deleted theorem

1. **Backward, all four rows** — "Each backward direction holds by embedding BL into BL⁺
   (`thm:BLplus-PastFuture`): every axiom and rule of TM is directly contained in, or derivable
   from, S5, BX, and TMP-MF, so every TM-derivation carries over to a TM⁺-derivation, and
   similarly DF, DN, and CO each embed into the correspondingly complete extension."
2. **CEB forward — FAILS.** Witness **(Sp)** `:= □φ_DF ∨ □ψ_DN`. TM⁺ ⊢ (Sp) because `X⊤ → φ_DF`
   and `¬X⊤ → ψ_DN` are BL⁺-valid, weak completeness of TM⁺ turns them into theorems, and
   TMP-NB (`X⊤ → □X⊤`) with M5 gives `⊢ □X⊤ ∨ □¬X⊤`; necessitation and distribution then yield
   (Sp). No instance of (Sp) is a TM-theorem: TM is sound on a disjoint two-fibre structure (a
   ℤ-fibre and an ℝ-fibre, □ read globally over both) falsifying a variable-sharing instance at
   every point. Corrected target is CEB* over `TM* := TM + (Sp)`, presented as a repair target,
   not asserted.
3. **CEF forward — FAILS unconditionally.** TMP-Z1 is *by definition* an axiom of
   BX_f ⊆ TM⁺_f (`def:TMplus-f`) and is itself a BL-formula, so TM⁺_f ⊢ Z1 trivially. But
   TM_f = TM + DF is sound over *every* discrete frame, and Z1 is unsound over non-Archimedean
   discrete orders such as ℤ ×_lex ℤ, so soundness rules out TM_f ⊢ Z1.
4. **CED, CEC forward — OPEN.** No counterexample analogous to the CEB/CEF witnesses is known
   for CED. CEC inherits that openness plus an independent doubt: whether TMP-CO alone
   axiomatizes the same BL⁺-logic as the full Reynolds triple is itself open.

### 3.4 Dependencies

- Step 1 depends on nothing outside the two axiom sets. It is the only step this repository can
  discharge purely proof-theoretically.
- Step 2 depends on TM⁺ weak completeness *and* a semantics + soundness for the **BL-side** TM
  system (to get TM ⊬ (Sp)). The repository has the former; it has no BL-side semantics at all.
- Step 3 depends only on a BL-side soundness theorem over the discrete class plus a
  non-Archimedean countermodel. Tasks 421/422/425 in this repository are building exactly that
  carrier.
- Step 4 is open in the source; nothing to formalize.

### 3.5 Formalization challenges per step

| Step | Lean difficulty |
|---|---|
| 1 (backward) | Low-to-medium. Structural recursion over TM derivations; one commutation lemma; one missing DF derivation (§6). |
| 2 (CEB forward fails) | High. Needs a whole BL-side semantics + soundness + a two-fibre task frame. Out of proof-theoretic scope. |
| 3 (CEF forward fails) | Medium-high, and *cheaper* than step 2 — `Axiom.z1` is already in the tree and is already in the image of the translation (§4.2). Still needs BL-side soundness. |
| 4 | Nothing to do (open in the source). |

---

## 4. Why the Requested Direction Is Refutable in *This* Repository

The paper's two failure witnesses are not abstract — both are directly instantiated by this
repository's `FormalSystem/ProofSystem/Axioms.lean`.

### 4.1 CEB witness is live at `FrameClass.Base`

`Axiom.discrete_box_necessity` is the paper's TMP-NB (`X⊤ → □X⊤`), and
`Axiom.minFrameClass` assigns it **`.Base`** (it falls through the `| _ => .Base` catch-all;
only `density`, `dense_indicator`, `prior_UZ`, `prior_SZ`, `z1`, `prior_U_gap`, `prior_S_gap`,
`sep` are non-Base). `Axiom.modal_5_collapse` is M5, also Base. So the (Sp) derivation the
paper sketches is available in `⊢[FrameClass.Base]` verbatim, given the repository's own
`completeness_*` results for the two BL⁺-valid conditionals.

### 4.2 CEF witness is live at `FrameClass.Discrete` and is *already in the image of `tr`*

```lean
| z1 (φ : Formula) :
    Axiom ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture))
```
(`Axioms.lean:347`, `minFrameClass = .Discrete`.)

Every operator here is `allFuture`/`someFuture`/`imp` — i.e. `z1 φ = tr (Z1 φ')` for the obvious
BL formula `Z1`. So `⊢[Discrete] tr(Z1)` holds by a one-line axiom invocation, while
`TM_f ⊢ Z1` is exactly what soundness over ℤ ×_lex ℤ refutes. The forward direction for the
Discrete row is therefore false **by construction of this repository's own axiom set**, with no
appeal to completeness at all.

**Zero-debt consequence.** Writing `theorem forward : ⊢[fc] tr φ → BL.Derivable fc [] φ` and
discharging it with `sorry` would place a `sorry` on a statement that is provably false. That is
not deferred debt; it is an unsound placeholder. Per the zero-debt policy this is not an
acceptable Option-B deferral, and the sub-goal must be marked **[BLOCKED]** for user review
rather than attempted.

---

## 5. Repository Asset Inventory

All names below were verified by direct source read; the paths are `file:line`.

### 5.1 BL⁺ side (target of the translation)

| Asset | Location | Note |
|---|---|---|
| `Formula` (BL⁺) | `FormalSystem/Syntax/Formula.lean:76` | `atom \| bot \| imp \| box \| untl \| snce`; guard-first argument order |
| `allFuture`, `allPast`, `someFuture`, `somePast` | `Formula.lean:163-176` | G/H/F/P derived per `def:BLplus-defined` |
| `always` (△) | `Formula.lean:476` | `Hφ ∧ φ ∧ Gφ` |
| `co` | `Formula.lean:506` | the paper's CO as a named abbreviation |
| `swapTemporal` | `Formula.lean:667` | swaps `untl`↔`snce` |
| `swap_temporal_all_future`, `swap_temporal_all_past` | `Formula.lean:731,737` | **the bridge lemmas the TD translation needs** |
| `Axiom` | `ProofSystem/Axioms.lean:99` | 45 constructors |
| `FrameClass` + `Axiom.minFrameClass` | `Axioms.lean:519,586` | `Base ≤ {Dense ≤ Dedekind, Discrete}` |
| `DerivationTree` | `ProofSystem/Derivation.lean:93` | 7 rules incl. `necessitation`, `temporal_necessitation`, `temporal_duality` |
| `Derivable` (Prop) | `ProofSystem/Derivable.lean:69` | `Nonempty (DerivationTree fc G p)` |

### 5.2 TM axiom-by-axiom discharge table (Base row)

| TM item | BL⁺ discharge | Status |
|---|---|---|
| CPL | `Axiom.prop_k`, `prop_s`, `ex_falso`, `peirce` | direct |
| MP | `DerivationTree.modus_ponens` | direct |
| MN | `DerivationTree.necessitation` | direct |
| MK | `Axiom.modal_k_dist` | direct |
| MT | `Axiom.modal_t` | direct |
| M5 | `Axiom.modal_5_collapse` (`◇□φ → □φ`) | direct |
| MF | `Axiom.modal_future` (`□φ → □Gφ`) | **exact syntactic match** |
| TD | `DerivationTree.temporal_duality` + commutation lemma (§7) | verified compiling |
| TK | `Theorems.TemporalDerived.gDistribution` (`TemporalDerived.lean:259`) | derived, sorry-free |
| T4 | `Theorems.TemporalDerived.gTransitivity` (`TemporalDerived.lean:274`) | derived, sorry-free |
| TB (`F⊤`) | `Axiom.serial_future` (`⊤ → F⊤`) + MP on `⊤`; cf. `ContextualProofs.serial_future_ctx:294` | one step |
| TA | `Axiom.connect_future` (`φ → G P φ`) | **exact syntactic match** |
| TL | `Axiom.temp_linearity` | same 3 disjuncts, **different order/association** — needs a propositional reshuffle |

The TL mismatch is the only friction in the Base row. Paper: `F(Fφ∧ψ) ∨ F(φ∧ψ) ∨ F(φ∧Fψ)`.
Repo (`Axioms.lean:253`): `F(φ∧ψ) ∨ (F(φ∧Fψ) ∨ F(Fφ∧ψ))`. Routine `orElim`/`orIntro` plumbing
from `Theorems/Propositional/`.

### 5.3 Extension-row discharge table

| Row | TM-side extra axiom | BL⁺ target class | Discharge | Status |
|---|---|---|---|---|
| CEB | — | `Base` | §5.2 | closable now |
| CED | DN `GGφ → Gφ` | `Dense` | `Axiom.density φ` — **literally the same formula** (`Axioms.lean:358`) | one line |
| CEC | CO | `Dedekind` | `Theorems.DedekindDerived.co_derived {fc} (h_fc : Dedekind ≤ fc) (φ) : ⊢[fc] Formula.co φ` (`DedekindDerived.lean:372`) | exists, sorry-free |
| CEF | DF `(Hφ ∧ φ ∧ F⊤) → F(Hφ)` | `Discrete` | **nothing in tree** | **OPEN — see §6** |

### 5.4 Structural prior art (do not reuse the content, do reuse the shape)

`FormalSystem/Boneyard/ConservativeExtension/{ExtFormula,ExtAxiom,ExtDerivation,Lifting}.lean`
is a mirrored-type + `embedAxiom`/`embedDerivation` skeleton. It is `#exit`-guarded and **never
compiled**, and its content is a *fresh-atom* extension (`ExtAtom := Atom ⊕ Unit`), not the
BL/BL⁺ language conservativity — `typst/SYNC-MAP.md:361` records this misattribution and its
correction. Its architecture (parallel `Axiom` inductive, parallel `DerivationTree`, one
recursive `embedDerivation`) is nonetheless the right template for this task.

### 5.5 Repository health

One live `sorry` repo-wide outside `Boneyard/`
(`WeakCanonical.countermodel_discrete`, per `FormalSystem/Metalogic.lean:37`). The four
`completeness_*` theorems (`BXCanonical/Completeness.lean:256,297`,
`StrongCompleteness.lean:380`) are sorry-free.

---

## 6. The One Open Sub-Obligation: DF at `FrameClass.Discrete`

To close CEF's *backward* direction, the bridge must produce
`⊢[FrameClass.Discrete] tr(DF φ)`, i.e.

```
⊢[Discrete] (Hφ ∧ φ ∧ F⊤) → F(Hφ)
```

Nothing in the tree proves this. Two routes:

**Route A — syntactic (recommended).** Semantically DF holds because at the immediate successor
`s` of `t`, every time `< s` is `≤ t`, so `Hφ ∧ φ` at `t` yields `Hφ` at `s`. The syntactic
pieces exist:
- `Theorems.DiscreteUnfolding.succIndicator : ⊢[Discrete] Formula.next Formula.top`
  (`DiscreteUnfolding.lean:85`) — `X⊤` is already a Discrete theorem.
- `Axiom.until_F` with guard `⊥` gives `X ψ → F ψ` at Base.
- The remaining step `Hφ ∧ φ → X(Hφ)` is the past-dual of the one-step unfolding in
  `unfoldForward`/`unfoldTableForward` (`DiscreteUnfolding.lean:106,245`). Past duals are
  **free**: `DerivationTree.temporal_duality` is a primitive rule applying to any theorem at any
  frame class, so no past-mirrored axiom is needed.

Estimated one focused phase. This is the single largest unknown in the plan and should be
budgeted its own dispatch.

**Route B — semantic (fallback, not recommended).** `tr(DF)` is valid over ℤ-time, so
`completeness_discrete` (`BXCanonical/Completeness.lean:297`) delivers derivability. This works
and is sorry-free, but it makes a proof-theoretic bridge depend on the completeness machinery
the bridge is supposed to feed — a presentational regression the paper explicitly wanted to
avoid. Keep it only as a scope-rescue if Route A stalls.

---

## 7. Prototype Verification (compiled against the live tree)

The following snippet was run through `lean_run_code` against `FormalSystem.Syntax.Formula` and
returned **`{"success": true, "diagnostics": []}`** — zero errors, zero warnings:

```lean
inductive BLFormula : Type where
  | atom : Atom → BLFormula
  | bot : BLFormula
  | imp : BLFormula → BLFormula → BLFormula
  | box : BLFormula → BLFormula
  | allPast : BLFormula → BLFormula
  | allFuture : BLFormula → BLFormula
  deriving Repr, DecidableEq

def swapBL : BLFormula → BLFormula
  | atom a => atom a | bot => bot
  | imp φ ψ => imp φ.swapBL ψ.swapBL
  | box φ => box φ.swapBL
  | allPast φ => allFuture φ.swapBL
  | allFuture φ => allPast φ.swapBL

def tr : BLFormula → Formula
  | atom a => Formula.atom a | bot => Formula.bot
  | imp φ ψ => Formula.imp φ.tr ψ.tr
  | box φ => Formula.box φ.tr
  | allPast φ => Formula.allPast φ.tr
  | allFuture φ => Formula.allFuture φ.tr

theorem swapBL_involution (φ : BLFormula) : φ.swapBL.swapBL = φ := by
  induction φ <;> simp_all [swapBL]

/-- THE load-bearing lemma for translating TM's TD rule. -/
theorem tr_swapBL (φ : BLFormula) : (φ.swapBL).tr = (φ.tr).swapTemporal := by
  induction φ with
  | atom a => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp [tr, swapBL, Formula.swapTemporal, ih1, ih2]
  | box _ ih => simp [tr, swapBL, Formula.swapTemporal, ih]
  | allPast _ ih => simp [tr, swapBL, Formula.swap_temporal_all_past, ih]
  | allFuture _ ih => simp [tr, swapBL, Formula.swap_temporal_all_future, ih]

/-- Range lemmas: `tr` never produces a top-level `untl` / `snce`. -/
theorem tr_ne_untl (φ : BLFormula) (a b : Formula) : φ.tr ≠ Formula.untl a b := by
  cases φ <;> simp [tr, Formula.allPast, Formula.allFuture, Formula.somePast,
    Formula.someFuture, Formula.neg, Formula.top]

theorem tr_ne_snce (φ : BLFormula) (a b : Formula) : φ.tr ≠ Formula.snce a b := by
  cases φ <;> simp [tr, Formula.allPast, Formula.allFuture, Formula.somePast,
    Formula.someFuture, Formula.neg, Formula.top]
```

`tr_swapBL` is the step that makes TM's TD rule translatable: `tr(swapBL(Gφ)) = allPast(tr φ) =
swapTemporal(allFuture (tr φ)) = swapTemporal(tr (Gφ))`, closing by
`Formula.swap_temporal_all_future`. Without it the TD case of the embedding does not typecheck.

**Injectivity of `tr` is a real but bounded obligation.** A first attempt at
`Function.Injective tr` by `induction … <;> simp_all` left exactly eight goals: four are direct
IH applications (`box/box`, `allPast/allPast`, `allFuture/allFuture`, `imp/imp`), and four are
shape clashes (`imp` vs. `allPast`/`allFuture` in either order) that the two range lemmas above
discharge once orientation is fixed (`(tr_ne_snce _ _ _ h.1.symm).elim`). A recognizer-based
`untr : Formula → Option BLFormula` was also tried and is **not** recommended: overlapping match
patterns block `simp [untr]` from reducing. Injectivity is not needed for the backward
direction; it is needed only if faithfulness is stated as a biconditional.

---

## 8. Proposed Lean Design

### 8.1 Module layout

Keep the base language in its own namespace so nothing shadows the existing `Formula` /
`Axiom` / `DerivationTree`:

```
FormalSystem/BaseLanguage/Formula.lean      -- FormalSystem.BaseLanguage.Formula (BLFormula)
FormalSystem/BaseLanguage/Axioms.lean       -- .Axiom, .Axiom.minFrameClass  (reuses ProofSystem.FrameClass)
FormalSystem/BaseLanguage/Derivation.lean   -- .DerivationTree, .Derivable, ⊢ᴮᴸ notation
FormalSystem/BaseLanguage/Translation.lean  -- tr, swapBL, tr_swapBL, range/injectivity lemmas
FormalSystem/Metalogic/Conservativity.lean  -- the bridge theorems
FormalSystem/BaseLanguage.lean              -- aggregator, imported from FormalSystem.lean
```

Alternative considered and rejected: adding `Syntax/BLFormula.lean` + `ProofSystem/BLAxioms.lean`
into the existing directories. That spreads one self-contained cluster across three trees and
makes the "which `Formula`?" question harder at every call site.

### 8.2 Reuse `FrameClass`, do not clone it

Parameterize the BL-side `DerivationTree` by the *existing* `ProofSystem.FrameClass` so the
bridge is one statement rather than four:

```lean
theorem translate {fc : FrameClass} {Γ : BaseLanguage.Context} {φ : BLFormula} :
    BaseLanguage.DerivationTree fc Γ φ →
    ProofSystem.DerivationTree fc (Γ.map tr) (tr φ)
```

with the BL-side `Axiom.minFrameClass` sending `DF ↦ .Discrete`, `DN ↦ .Dense`,
`CO ↦ .Dedekind`, everything else `↦ .Base`. Rows CEB/CEF/CED/CEC are then the four
instantiations, and the Prop-level corollary is

```lean
theorem derivable_translate {fc} {Γ} {φ} :
    BaseLanguage.Derivable fc Γ φ → ProofSystem.Derivable fc (Γ.map tr) (tr φ)
```

**Fidelity caveat to record in the plan.** The repository's `Dedekind` class admits the `Dense`
axioms (`Dense ≤ Dedekind`), so `⊢[Dedekind]` corresponds to the paper's **TM⁺_dc**, not to
TM⁺_c. There is no repository class for "complete but not dense". The CEC row as landed will
therefore read `TM_dc ⟶ TM⁺_dc`. Say so explicitly rather than letting a reader infer TM_c.

### 8.3 Shape of the TD case

`temporal_duality` applies only at the empty context on both sides, so the recursion is:

```lean
| .temporal_duality φ d =>
    (tr_swapBL φ) ▸ ProofSystem.DerivationTree.temporal_duality (tr φ) (translate d)
```

Same for `necessitation`. `modus_ponens`, `assumption`, `weakening` are structural. The `axiom`
case is the per-axiom table of §5.2/§5.3 plus the `minFrameClass` side condition, dischargeable
by `decide` (`FrameClass` is finite with `DecidableEq` and a `DecidableRel` instance,
`Axioms.lean:531`).

### 8.4 Composing with totality-based validity

The task asks that statements "compose with the totality-based validity." The bridge as designed
touches no semantics: `translate` is a function between two `DerivationTree` types. Whatever
semantic refactor lands, the composition is

```
BL-validity over C  ⟸[BL soundness, not yet built]  ⊢ᴮᴸ[fc] φ  ⟶[translate]  ⊢[fc] tr φ  ⟸[completeness_*]  BL⁺-validity over C
```

The bridge is the middle arrow only. Nothing needs re-phrasing when the validity definition
changes, provided no `Semantics.*` import is introduced into `BaseLanguage/`. Recommend making
"`BaseLanguage/` imports nothing from `FormalSystem/Semantics/`" an explicit plan invariant.

---

## 9. Tactic Survey Results

No live proof goals exist yet (no target file), so `lean_multi_attempt` /
`lean_hammer_premise` had nothing to attach to. What was measured instead is the tactic profile
of the prototypes actually run through `lean_run_code`:

| Goal | Tactic | Result | Config |
|---|---|---|---|
| `swapBL_involution` | `induction … <;> simp_all [swapBL]` | success | one-liner |
| `tr_swapBL` (the TD bridge) | per-case `simp` | success | needs `Formula.swap_temporal_all_future` / `_all_past` explicitly |
| `tr_ne_untl` / `tr_ne_snce` | `cases … <;> simp [unfoldings]` | success | must unfold `allPast/allFuture/somePast/someFuture/neg/top` |
| `Function.Injective tr` | `induction … <;> simp_all [unfoldings]` | partial (8 residual goals) | closable with IH + range lemmas; see §7 |
| `untr`-recognizer route | `simp [untr]` | fail | overlapping match patterns block reduction — **do not use** |

Expected profile for the bulk of the work: this is **term-mode `DerivationTree` construction**,
not tactic search. `aesop`/`omega`/`norm_num`/`linarith` have no purchase. The two tactics that
do carry weight are `decide` (for every `minFrameClass ≤ fc` side condition) and
`simp only [Formula.swapTemporal, Formula.allFuture, …]` (for the commutation and unfolding
steps). The propositional plumbing (`orElim`, `andIntro`, `deductionTheorem`, `impTrans`) should
be pulled from `Theorems/Propositional/` and `Theorems/Combinators.lean` rather than re-derived.

---

## 10. Risks and Open Items

| # | Item | Severity | Disposition |
|---|---|---|---|
| R1 | `thm:ConservativeExtension` deleted from the paper (2026-08-14) | **blocking for citation** | Surface to user. The task's "cite by `\label` only" rule cannot be met; this report cites the last revision carrying it plus live surviving anchors. |
| R2 | The task's quoted `cor:tm-completeness` footnote does not exist | **blocking for premise** | Surface to user. The live corollary makes no claim about TM, so "supplies the missing step in the `cor:tm-completeness` route" is no longer accurate as written. |
| R3 | The requested forward direction is **false** (CEB, CEF) | **blocking for that sub-goal** | Mark [BLOCKED]. Do not `sorry` it — the statement is refutable, not merely unproven. |
| R4 | DF at `FrameClass.Discrete` not in tree | medium | §6 Route A; budget its own phase. Route B is the rescue. |
| R5 | TL disjunct order mismatch paper↔repo | low | Propositional reshuffle. |
| R6 | `Dedekind` in this repo = paper's TM⁺_dc, not TM⁺_c | low, but a fidelity claim | Record explicitly in plan and in the theorem docstring. |
| R7 | Injectivity/faithfulness of `tr` | low | Bounded (§7). Only needed if faithfulness is stated biconditionally. |
| R8 | Coordination with tasks 421/422/425 | low | Those build the non-Archimedean discrete carrier that a future CEF-forward *refutation* would consume. Name the connection in the plan; do not depend on them. |

---

## 11. Recommended Scope

Deliverable A — **the bridge** (fully achievable, zero sorry):
1. `BaseLanguage/Formula.lean` — `BLFormula` with primitive `box`/`allPast`/`allFuture`,
   `swapBL`, `DecidableEq`, `Countable`, reusing the existing `Atom`.
2. `BaseLanguage/Axioms.lean` — TM's 12 schemata/rules + DF/DN/CO, with `minFrameClass`.
3. `BaseLanguage/Derivation.lean` — `DerivationTree` mirroring the 7-rule shape (TM's TD rule is
   `swapBL`, not `swapTemporal`), `Derivable`, notation.
4. `BaseLanguage/Translation.lean` — `tr`, `tr_swapBL`, range lemmas, `tr_injective`.
5. `Metalogic/Conservativity.lean` — `translate` and `derivable_translate`, plus the four named
   row corollaries `ceb_backward`, `cef_backward`, `ced_backward`, `cec_backward`.
6. The DF derivation at `Discrete` (§6 Route A) — its own phase.

Deliverable B — **the refutation record** (documentation, not proof):
7. A module docstring in `Metalogic/Conservativity.lean` recording, with the repository's own
   `Axiom.z1` and `Axiom.discrete_box_necessity` as evidence, that the converse direction is
   refuted for the Base and Discrete rows and open for the other two — so that no future
   dispatch re-attempts it. Cite the deleted-theorem provenance, not a live `\label`.

**Explicitly out of scope**: the forward direction; any BL-side semantics or soundness theorem;
the two-fibre and ℤ ×_lex ℤ countermodels. Each is a separate task if the user wants a
machine-checked *refutation* rather than a documented one.

---

## 12. Sources

- Live paper: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` —
  `\S sub:Logic` (TM axiomatization, lines 1180-1204), `\S sub:Extension` (DF/DN/CO),
  `def:BLplus-language`, `def:BLplus-defined`, `thm:BLplus-PastFuture`, `def:S5`, `def:BX`,
  `def:TMplus`, `def:TMplus-{f,d,c}`, `cor:tm-completeness`.
- Historical: `git show 58c7c0c0^:JPL/possible_worlds.tex` (2026-08-12) —
  `thm:ConservativeExtension` and its proof, deleted at `c0116d04` (2026-08-14).
- Pinned record: `specs/paper-definitions-of-record.md` (`cor:tm-completeness`, sha256
  `68e3ea9a…`, verified unchanged by `scripts/check-paper-definitions.sh`).
- In-repo corroboration of the deletion: `typst/chapters/p2-frame-classes.typ:180-182`,
  `typst/SYNC-MAP.md:361,394-411`.
- Lean tree: `FormalSystem/Syntax/Formula.lean`, `FormalSystem/ProofSystem/{Axioms,Derivation,
  Derivable}.lean`, `FormalSystem/Theorems/{TemporalDerived,DedekindDerived,DiscreteUnfolding,
  ContextualProofs}.lean`, `FormalSystem/Metalogic/BXCanonical/Completeness.lean`,
  `FormalSystem/Boneyard/ConservativeExtension/`.
- Prototype verification: four `lean_run_code` runs against the live tree (§7).
