# Phase 7 Truth-Lemma Route — Adjudication

- **Task**: 165 (establish_semantic_finite_model_property)
- **Date**: 2026-07-28
- **Session**: sess_1785244791_96fa7d
- **Mode**: `--hard` (H2 anti-analysis, H3 Tier 3 implementation-backed, H4 adversarial
  self-verification, H5 divergence audit — focus prompt names a blocker)
- **Question**: pivot Phase 7's truth lemma to a "branch → BFMCS → existing parametric truth
  lemma" bridge, or continue the bespoke route, or hybridise?
- **Verdict**: **REJECT the pivot. ADOPT a corrected bespoke route — *region labelling*.**
  Reuse the BFMCS coherence predicates as the *design template* only.

---

## 1. Decision

| Option | Verdict | Decisive reason |
|---|---|---|
| **Pivot** (branch labels → MCSs via Lindenbaum → BFMCS → `restricted_parametric_shifted_truth_lemma`) | **Rejected** | Its step 1 is inter-derivable with the goal it is meant to prove (§2.1). Steps 2–4 are, given step 1, already in-tree and free — so the pivot is not a route, it is a restatement. |
| **Continue bespoke** (invent a realisability condition; gap states closed under consequence) | **Adopted, in one specific form** | The "model-side" candidate named in the 2026-07-28i banner. Each region of the carrier takes the state of a **known branch label**. Machine-measured to be available on every open branch the engine produced, *including the one that refuted `GapAdequate`* (§3.2). |
| **Hybrid** | **Adopted for the obligation list and the proof skeleton only** | `FMCS.forward_G`/`backward_H` and `BFMCS.{Forward,Backward}UntilSinceCoherent` are exactly the right obligations, transposed from MCSs to labels; `parametric_shifted_truth_lemma`'s six-case induction is the proof template. No theorem in `Algebraic/` can be *applied* (§2.3). |

The one-sentence statement of the corrected route:

> The gap arm of the branch model's valuation stops being a *policy synthesised from the forced
> set* and becomes *the atom content of a known label chosen per region*, certified by a decidable
> branch-level gate in the family `timeOrderTotal` and `boxAnchoredCheck` already belong to.

This changes no signature. `branchModel b f gapVal` already takes
`gapVal : WorldIndex → Set (BranchTime b) × Set (BranchTime b) → Atom → Prop`
(`Bridge/Valuation.lean`); the corrected policy is a different *inhabitant* of that type, not a
different type.

---

## 2. Why the pivot is refuted

### 2.1 The pivot's step 1 is inter-derivable with the goal (LOUD REFUTATION)

The pivot's step 1 is "each placed label's signed-formula set is consistent; Lindenbaum-extend".
`set_lindenbaum` (`Metalogic/Core/MaximalConsistent.lean:303`) has signature

```lean
theorem set_lindenbaum {fc : FrameClass} (S : Set Formula) (hS : SetConsistent (fc := fc) S) :
```

so the step is gated on `SetConsistent`, a **derivability** notion. Write

- **G** (the goal): `hasOpen (buildTableau φ) → ¬ valid φ`
- **P** (the pivot's step 1, in its weakest sufficient form): `hasOpen (buildTableau φ) → SetConsistent {φ.neg}`

Then:

- **P ⟹ G** is already fully in tree. `exists_mcs_with_negation` (`Decidability/FMP/FMP.lean:63`)
  turns non-derivability into an MCS containing `φ.neg`; `countermodel_dense`
  (`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:829`) takes
  `(A : Set Formula) (h_mcs : SetMaximalConsistent A) (φ) (h_neg_in : φ.neg ∈ A)
  (h_box_dense : Formula.box nextTop.neg ∈ A)` and produces the countermodel. **The branch plays no
  part.** Its order, its labels, its saturation, `BranchOrder`, `Embed`, `Interpolate` — all
  unused. So the pivot's steps 2, 3 and 4 are not work to be done; they are work already done, for
  a different input.
- **G ⟹ P** holds by in-tree soundness. If `{φ.neg}` were inconsistent then `⊢ φ.neg.neg`, hence
  `⊨ φ.neg.neg` by soundness, hence `φ.neg` is unsatisfiable — contradicting the countermodel G
  supplies.

So **P and G are inter-derivable**, and P is not a weaker obligation than G. The pivot's step 1 is
the whole problem wearing MCS clothing. Every route from "this tableau branch is open and
saturated" to "its formulas are Hilbert-consistent" runs through a model for that branch: that is
the classical shape of the Hintikka/model-existence lemma, and it is what Phase 7 is trying to
build. Contrapositively, P asks for `⊢ φ ⟹ the tableau closes` — completeness of the tableau
relative to the Hilbert calculus — whose only non-circular proof in the absence of a cut-elimination
argument is via model existence.

A second, independent obstacle sits on the same step even if consistency were granted:
`countermodel_dense` additionally requires `Formula.box nextTop.neg ∈ A` (`□¬U(⊤,⊥)`, the density
flag). Seeding Lindenbaum with `{φ.neg, □¬U(⊤,⊥)}` needs *that pair* consistent, an obligation the
pivot's four steps do not mention.

### 2.2 The pivot's step 3 rests on a false premise about `forward_F`

The delegation calls `forward_F` "the genuine unknown". It is not an obligation of the truth lemma
at all.

```lean
-- FormalSystem/Metalogic/Bundle/FMCSDef.lean:103
structure FMCS (fc : FrameClass := FrameClass.Base) where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (fc := fc) (mcs t)
  forward_G : forall t t' phi, t < t' -> Formula.allFuture phi ∈ mcs t -> phi ∈ mcs t'
  backward_H : forall t t' phi, t' < t -> Formula.allPast phi ∈ mcs t -> phi ∈ mcs t'
```

Four fields; no `forward_F`, no `backward_P`. Those live in the `Prop`
`BFMCS.RestrictedTemporallyCoherent` (`Bundle/TemporalCoherence.lean:308`), which both truth
lemmas take as **`_h_rtc`** — a leading underscore, i.e. *unused in the proof body*
(`RestrictedParametricTruthLemma.lean:119`, `ParametricTruthLemma.lean:379`). The reason is
syntactic: `Formula` has no `G`/`H`/`F`/`P` constructors —
`someFuture φ := untl φ ⊤`, `allFuture φ := (someFuture φ.neg).neg` (`Syntax/Formula.lean:131-161`)
— so the induction has exactly six cases (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) and every
temporal obligation lands on `h_buc`/`h_fuc`.

The real obligations, verbatim (`Bundle/TemporalCoherence.lean:541`), are strictly *stronger* than
`forward_F` (take `ψ := ⊤` to recover it):

```lean
def BFMCS.ForwardUntilSinceCoherent (B : BFMCS (fc := fc) D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl φ ψ ∈ fam.mcs t →
      ∃ s : D, t < s ∧ φ ∈ fam.mcs s ∧ ∀ r : D, t < r → r < s → ψ ∈ fam.mcs r) ∧ ...
```

Note also that `restricted_parametric_shifted_truth_lemma` takes the **unrestricted** `h_buc`/
`h_fuc`; only `fully_restricted_parametric_shifted_truth_lemma`
(`RestrictedParametricTruthLemma.lean:286`) takes the `subformulaClosure root`-guarded versions,
and that is the one the live Chronicle consumer actually uses. So the pivot's step 3 both
mis-names the obligation and understates it.

### 2.3 No theorem in `Algebraic/` can be applied to a branch model

Both truth lemmas hardwire the model: their conclusion is

```lean
    φ ∈ fam.mcs t ↔
    TruthAt (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametricToHistory fam) t φ
```

and `ParametricCanonicalTaskFrame.WorldState = { M : Set Formula // SetMaximalConsistent M }`
(`Algebraic/ParametricCanonical.lean:70,207`). The branch model's world states are
`W × (Set ι × Set ι)` (`Bridge/Omega.lean`, `regionFrame`). They are not the same frame and there
is no transport between them short of the MCS route already refuted in §2.1. **Reuse is of the
design, never of the theorem.**

### 2.4 Chronicle has no finite-seed entry point

`omegaChain`'s base case is hard-wired to `singletonChronicle A`
(`Chronicle/ChronicleConstruction.lean:70,283`), and `singletonChronicle` occurs nowhere outside
that file — there is no `omegaChainFrom`/`omegaChainOfChronicle`. The generalisation is shallow
(`eliminatePotentialCounterexample` accepts any `Chronicle` with `c0 ∧ c2' ∧ NoGuardAccumulation`,
and `omega_chain_dom_mono_le`/`omega_chain_f_agrees_le` already give seed survival), but it does
not help: a seed chronicle's `f` must be MCS-valued, so §2.1 applies unchanged.

Chronicle's own `forward_F` witness, for the record, comes from the ω-chain limit, not from any
finite datum: `limit_F_resolution` (`ChronicleConstruction.lean:771`) finds `y ∈ LimitDom`, and the
witness is `iso ⟨y, hy⟩ - offset` where `iso` is a Cantor order-isomorphism
`LimitDomSubtype ≃o ℚ` (`ChronicleToCountermodelBasic.lean:355`). Totality of the MCS assignment on
ℚ comes from that isomorphism, not from defining MCSs at fresh points. A finite branch offers no
analogue.

---

## 3. Why the corrected bespoke route is the one to take

### 3.1 What the `GapAdequate` refutation actually rules out

`gapAdequate_insufficient` (`Bridge/Valuation.lean:654`) shows that the gap's state must be closed
under the propositional consequences of its forced set
`{χ : T(Gχ) below} ∪ {χ : T(Hχ) above} ∪ {χ : T(□χ)}`, and that a *forced set* is not so closed.

That is a fact about **forced sets**, not about **label contents**. A saturated branch is
propositionally closed *at each label* — that is precisely what `sat_imp_pos`
(`Bridge/PropSaturation.lean:91`) says, and `sat_box_grid_of_check`
(`Bridge/BoxSaturation.lean:566`) says the box content reaches every label. So:

> Give a region the atom content of a **known label** rather than of its **forced set**, and the
> closure the refutation demands is supplied by saturation, for free.

On the refuting shape itself: with `T(□p)` and `T(□(p→q))` on the branch, `sat_box_grid` puts
`T(p)` and `T(p→q)` at *every* label; `sat_imp_pos` then forces `F(p)` or `T(q)` at each label, and
openness rules out `F(p)`. So `T(q)` sits at every label, and a region carrying a label's atoms
makes `p → q` **true**. The 2026-07-28i DO-NOT-RE-ATTEMPT entry bans "any atom-wise gap policy read
off the branch's `T(G·)`/`T(H·)`/`T(□·)` facts". The label policy is atom-wise but is **not** read
off those facts — it is read off a chosen label — so it is outside the banned family. It is equally
not either refuted copy policy: those choose the source point by *position* (the adjacent placed
point), which is what breaks the non-reflexive `G`/`H` demands; this chooses by *content*, and the
choice is validated by a check.

### 3.2 Probe: the required labels exist on every branch the engine builds

Two probe files were written and run (`lake env lean`, unregistered scratch files, full contents in
§6). Both are re-runnable.

**Probe 1 — stationary labels.** A label `l` is *G-reflexive* if every `T(Gχ)` at `l` is accompanied
by `T(χ)` at `l`, dually *H-reflexive*. A region state must be both (a region is an interval; its
own `G`/`H` demands look at points inside the same region).

| Row | Formula | Class | Result |
|---|---|---|---|
| A | `(□p ∧ ◇q) → r` | Base | `OPEN \|W\|=2 \|T\|=7 \|labels\|=14 stationary=14` |
| B | `(□p ∧ ◇Gq) → r` | Base | `OPEN \|W\|=2 \|T\|=7 \|labels\|=14 stationary=13` |
| C | `(□p ∧ ◇q) → r` | Dense | `OPEN \|W\|=2 \|T\|=10 \|labels\|=20 stationary=20` |
| D | `(□p ∧ □(p→q)) → r` | Base | `OPEN \|W\|=1 \|T\|=4 \|labels\|=4 stationary=4` |
| E | `Gp → p` | Base | `OPEN \|W\|=1 \|T\|=4 \|labels\|=4 stationary=3` |
| F | `¬(Fp → p)` | Base | `OPEN \|W\|=1 \|T\|=4 \|labels\|=4 stationary=4` |

Row E is the discriminating one: exactly the label carrying `T(Gp)` with no `T(p)` fails, as it
should. The check is not vacuous.

**Probe 2 — region fill.** Strengthen to: does each known world contain a label that *absorbs*
every `G`-demand and every `H`-demand raised anywhere in that world, plus every `□`-demand on the
branch, carries no `F(·)` of any of them, and is G- and H-reflexive? Such a label can serve as the
state of **every** non-placed point of the carrier in its world at once — a fortiori of each
individual gap region and of both rays.

| Row | Result |
|---|---|
| A | `gDem=[4,1] hDem=[4,1] boxDem=4 fillPerWorld=[7,7]` |
| B | `gDem=[4,3] hDem=[4,1] boxDem=4 fillPerWorld=[7,3]` |
| C (Dense) | `gDem=[4,1] hDem=[4,1] boxDem=4 fillPerWorld=[10,10]` |
| D (the refuting shape) | `gDem=[8] hDem=[8] boxDem=12 fillPerWorld=[4]` |
| E (`Gp → p`) | `gDem=[1] hDem=[0] boxDem=0 fillPerWorld=[2]` |
| F (`¬(Fp → p)`) | `gDem=[0] hDem=[0] boxDem=0 fillPerWorld=[4]` |

Every world of every open branch measured has **at least two** fill labels. Row D — the branch
whose shape kills `GapAdequate` — has all four of its labels qualifying against 28 demands.

**Honest bound on what this shows.** `absorbs` uses *branch-wide* demands, an over-approximation of
any single region's demand, so passing it is stronger than necessary; a branch that failed it would
not thereby be refuted. The probe does not check the `untl`/`snce` guard conditions, does not check
negative (`F`-side) demands at gap points beyond `hasNegAt` at the chosen label, and is not a proof
that a gate of this shape suffices for the induction. It establishes that the route is **not dead
on arrival** on the branches that killed the previous two interfaces — which is exactly the
question five prior dispatches did not ask before proving.

### 3.3 A strictly easier first milestone: ℤ has no interior gaps

`valid` quantifies over the carrier:

```lean
-- FormalSystem/Semantics/Validity.lean:79
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] ...
```

So **one** carrier refutes validity. `finOrderEmbInt` (`Bridge/Embed.lean:76`) is the `Nat`-cast,
`fun i => (i.val : ℤ)`, so `finiteOrderEmbInt` places `n` branch times at `0, 1, …, n-1` — a
**contiguous** block. Between consecutive placed points of a contiguous ℤ placement there are no
integers at all: every interior gap region is *empty*, and the only non-placed points are the two
rays. That removes the dense-gap problem entirely from the `Base` and `Discrete` instances and
leaves one ray state per world to justify — which is exactly what Probe 2's fill label supplies.

`ValidDense` (ℚ) and `ValidDedekindDense` (ℝ) keep the genuinely dense interior gaps and stay
harder. The plan should not treat all four instances as one milestone.

---

## 4. Asset inventory under the decision (P4)

**Load-bearing, unchanged.**

| Asset | Location | Role after the pivot decision |
|---|---|---|
| `Termination/*` (all of Phases 4/4.3, `Fuel.lean`, `orderDual_holds`) | `Verified/Termination/` | Unchanged; `buildTableau_isSome` still feeds 7.3 |
| `branchOrderValid`, `BranchOrder`, `timeOrderTotal`, `branchLT_*` | `Bridge/BranchOrder.lean` | The finite linear order that gets placed |
| `finOrderEmbInt`, `finiteOrderEmbInt`, `embed_finite_to_dense/int` | `Bridge/Embed.lean` | Placement; §3.3 promotes the ℤ half |
| `TemporalCarrier`, `exists_monotone_placement`, `exists_region_placement` | `Bridge/Carrier.lean` | Unchanged |
| `regionCode`, `SameRegion`, `regionExtend`, all `InterpInvariant*` | `Bridge/Interpolate.lean` | **Fully load-bearing** — region-constancy is exactly what a per-region label state delivers |
| `regionFrame`, `regionHistory`, `regionOmega`, `truthAt_box_iff`, `truthAt_box_iff_base` | `Bridge/Omega.lean` | Unchanged |
| `placedCode`, `IsPlacedCode`, `regionValuation`, `regionModel`, `branchPlacedVal`, `branchModel`, `truthAt_atom_placed`, `truthAt_atom_gap` | `Bridge/Valuation.lean` | Unchanged, **including `branchModel`'s `gapVal` parameter** |
| whole `sat_*` family, `boxAnchoredCheck`, `sat_box_grid_of_check`, `timeOrderConverse`, `knownTime_trichotomy` | `Bridge/BoxSaturation.lean` | Unchanged; §3.1 makes `sat_box_grid` load-bearing in a new way |
| `sat_imp_pos` | `Bridge/PropSaturation.lean` | Promoted: it is *why* a label's content is propositionally closed |

**Retired — kept in tree as refutation documentation, not deleted.**

| Asset | Location | Status |
|---|---|---|
| `GapDemands`, `gapDemands_trivial` | `Bridge/Valuation.lean` | Retired (vacuous), already documented as such |
| `GapAdequate`, `branchGapVal`, `branchGapVal_gapAdequate` | `Bridge/Valuation.lean` | Retired as *the* gap obligation; `gapAdequate_insufficient` is the citation |
| `leftCopyGap`, `rightCopyGap`, `not_leftCopy_gapAdequate`, `not_rightCopy_gapAdequate` | `Bridge/Valuation.lean` | Retired; they bound the design space and must stay |
| `branchTruth` | `CountermodelExtraction.lean:263` | Still owed a demotion/deletion (Phase 7.1's original text); unaffected by this decision |

No file is deleted and no signature changes. The retirement is of *inhabitants*, not of types.

---

## 5. Adversarial Self-Verification (H4)

### Claim Verification Table

| Claim | Source / Counterexample | Verification method | Confidence |
|---|---|---|---|
| `set_lindenbaum` requires `SetConsistent` | `Metalogic/Core/MaximalConsistent.lean:303` | Signature read verbatim | High |
| `countermodel_dense` needs only an MCS `A` with `φ.neg ∈ A` and `□¬U(⊤,⊥) ∈ A` — the branch is not an input | `Chronicle/ChronicleToCountermodelBasic.lean:829` | Signature read verbatim by subagent | High |
| P (branch⇒consistency) and G (the Phase 7 goal) are inter-derivable | Constructed argument, §2.1; uses in-tree soundness (`Metalogic/Soundness`) and `exists_mcs_with_negation` (`FMP/FMP.lean:63`) | Derivation, not machine-checked | Medium-High — the P⟹G half is machine-grounded in existing signatures; the G⟹P half is a two-line soundness argument I did not formalise |
| `FMCS` has no `forward_F` field | `Bundle/FMCSDef.lean:103-121` | Structure read verbatim | High |
| `_h_rtc`/`_h_tc` are unused in both truth lemmas | `RestrictedParametricTruthLemma.lean:119`, `ParametricTruthLemma.lean:379` — leading underscore | Signature read verbatim | High |
| The obligations are `h_buc`/`h_fuc`, strictly stronger than `forward_F` | `Bundle/TemporalCoherence.lean:489,541`; `someFuture φ = untl φ ⊤` (`Syntax/Formula.lean:131`) | Definitions read verbatim | High |
| No `omegaChainFrom`; base case hard-wired to `singletonChronicle` | `ChronicleConstruction.lean:70,283`; grep shows no other occurrence | Grep + read | High |
| The truth lemmas hardwire `ParametricCanonicalTaskModel`, whose world states are MCS subtypes | `ParametricCanonical.lean:70,207`; `ParametricTruthLemma.lean:108` | Read verbatim | High |
| Stationary (G- and H-reflexive) labels exist on rows A–F | Probe 1, §6.1 | `lake env lean`, `#eval`, re-runnable | High (measured) |
| Every world of every measured open branch has ≥2 fill labels, incl. row D with 4/4 against 28 demands | Probe 2, §6.2 | `lake env lean`, `#eval`, re-runnable | High (measured) |
| Fill labels sufficing for the *whole induction* | — | **Not verified.** `absorbs` over-approximates, and no `untl`/`snce` guard condition was checked | **Low — flagged as the mandatory first sub-phase** |
| `finOrderEmbInt` is contiguous, so ℤ placements have empty interior gaps | `Bridge/Embed.lean:76-80` (`fun i => (i.val : ℤ)`) | Read verbatim | High |
| `valid` quantifies over all carriers | `Semantics/Validity.lean:79` | Read verbatim | High |
| A `TemporalCarrier FrameClass.Base ℤ` instance exists | Only `Base ℚ`, `Dense ℚ`, `Discrete ℤ`, `Dedekind ℝ` are registered (`Bridge/Carrier.lean:136-164`) | Read | **Claim corrected**: it does *not* exist; §3.3's ℤ route needs the instance added. Cheap (`FrameConditionFor Base`), but it is a task, not a given |

### Contradiction Log

**C1 — resolved.** The delegation states "P3 forward_F from finite saturation: the genuine
unknown". `FMCSDef.lean:103` shows no such field and both truth lemmas take the coherence predicate
as an unused underscore argument. **Precedence**: machine-readable source over prose framing. The
delegation's framing is superseded; the real unknown is `h_fuc`/`h_buc`.

**C2 — resolved.** The 2026-07-28i banner bans "any atom-wise gap policy". The recommended route is
atom-wise. **Precedence**: the ban's own stated scope — "read off the branch's
`T(G·)`/`T(H·)`/`T(□·)` facts" — and its stated mechanism (non-closure of the *forced set*). A
label's content is not a forced set and is propositionally closed by `sat_imp_pos`. The ban is
carried forward verbatim in the plan with an explicit scope note rather than weakened.

**C3 — unresolved, low downstream risk.** Whether a per-region gate (weaker than Probe 2's
branch-wide `absorbs`) is what the induction actually needs is open. Resolving check not performed:
running the induction's `untl` case against a region-labelled model. This is precisely why the
amended plan makes 7.1a a probe sub-phase, not a proof sub-phase.

### Recommendations modified after verification

1. The `TemporalCarrier FrameClass.Base ℤ` instance was assumed present; it is not. §3.3 and the
   plan's 7.1c now carry it as explicit work.
2. An earlier draft recommended the ℤ route as *the* route. Corrected: it is the route for
   `valid`/`ValidDiscrete` only; `ValidDense`/`ValidDedekindDense` keep dense interior gaps and are
   separated into their own sub-phase.

---

## 6. Probe artifacts (reproducible)

Both files are unregistered scratch artifacts under the session scratchpad, run with
`lake env lean <abs path>` from the repo root (~60 s each). Neither imports
`Chronicle/CounterexampleElimination.lean`. Neither modifies any existing `.lean` file.

### 6.1 `StationaryLabelProbe.lean` — key definitions

```lean
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BoxSaturation

/-- `G χ` unfolds to `(U(¬χ, ⊤)) → ⊥`; recover `χ`. -/
def gInner : Formula → Option Formula
  | .imp (.untl (.imp c .bot) t) .bot => if t == Formula.top then some c else none
  | _ => none

/-- `H χ` unfolds to `(S(¬χ, ⊤)) → ⊥`; recover `χ`. -/
def hInner : Formula → Option Formula
  | .imp (.snce (.imp c .bot) t) .bot => if t == Formula.top then some c else none
  | _ => none

example : gInner (Formula.allFuture p) = some p := by native_decide
example : hInner (Formula.allPast p)   = some p := by native_decide

def gReflexive (b : Branch) (l : Label) : Bool :=
  b.all fun sf =>
    if sf.sign == .pos && sf.label == l then
      match gInner sf.formula with
      | some c => b.hasPosAt c l
      | none => true
    else true
-- hReflexive: identical with hInner

def knownLabels (b : Branch) : List Label :=
  b.knownWorlds.flatMap fun w => b.knownTimes.map fun t => ⟨w, t⟩

def stationaryLabels (b : Branch) : List Label :=
  (knownLabels b).filter fun l => gReflexive b l && hReflexive b l
```

Measured output, in row order A, B, C, D, E, F:

```
"OPEN |W|=2 |T|=7  |labels|=14 stationary=14 gStat=14 hStat=14"
"OPEN |W|=2 |T|=7  |labels|=14 stationary=13 gStat=13 hStat=14"
"OPEN |W|=2 |T|=10 |labels|=20 stationary=20 gStat=20 hStat=20"
"OPEN |W|=1 |T|=4  |labels|=4  stationary=4  gStat=4  hStat=4"
"OPEN |W|=1 |T|=4  |labels|=4  stationary=3  gStat=3  hStat=4"
"OPEN |W|=1 |T|=4  |labels|=4  stationary=4  gStat=4  hStat=4"
```

### 6.2 `RegionFillProbe.lean` — key definitions

```lean
def gDemands (b : Branch) (w : WorldIndex) : List Formula :=
  b.filterMap fun sf =>
    if sf.sign == .pos && sf.label.world == w then gInner sf.formula else none
-- hDemands: identical with hInner
def boxDemands (b : Branch) : List Formula :=
  b.filterMap fun sf => if sf.sign == .pos then boxInner sf.formula else none

/-- `l` absorbs every G-, H- and box-demand of its own world, and carries no `F(·)` of any. -/
def absorbs (b : Branch) (l : Label) : Bool :=
  let ds := gDemands b l.world ++ hDemands b l.world ++ boxDemands b
  ds.all fun c => b.hasPosAt c l && !(b.hasNegAt c l)

def fillLabels (b : Branch) (w : WorldIndex) : List Label :=
  (b.knownTimes.map fun t => (⟨w, t⟩ : Label)).filter fun l =>
    absorbs b l && gReflexive b l && hReflexive b l
```

Measured output, in row order A, B, C, D, E, F (plus two rows that CLOSED and are therefore
uninformative: `Gp → GGp`, `(Gp ∧ Fq) → F(p ∧ q)`):

```
"OPEN |W|=2 |T|=7  gDem=[4, 1] hDem=[4, 1] boxDem=4  fillPerWorld=[7, 7]"
"OPEN |W|=2 |T|=7  gDem=[4, 3] hDem=[4, 1] boxDem=4  fillPerWorld=[7, 3]"
"OPEN |W|=2 |T|=10 gDem=[4, 1] hDem=[4, 1] boxDem=4  fillPerWorld=[10, 10]"
"OPEN |W|=1 |T|=4  gDem=[8]    hDem=[8]    boxDem=12 fillPerWorld=[4]"
"OPEN |W|=1 |T|=4  gDem=[1]    hDem=[0]    boxDem=0  fillPerWorld=[2]"
"OPEN |W|=1 |T|=4  gDem=[0]    hDem=[0]    boxDem=0  fillPerWorld=[4]"
"CLOSED"
"CLOSED"
```

---

## 7. New DO-NOT-RE-ATTEMPT entries generated by this adjudication

1. **Branch labels → MCSs via `set_lindenbaum`**, in any form, as a route to the truth lemma. The
   consistency hypothesis is inter-derivable with the goal (§2.1). This bans the whole family, not
   just the four-step version adjudicated here.
2. **Seeding Chronicle from the branch** (a finite `Chronicle`, an `omegaChainFrom`, a finite
   prescribed-order family of MCSs). Same refutation: the seed must be MCS-valued.
3. **Treating `forward_F`/`RestrictedTemporallyCoherent` as an obligation to discharge.** It is
   passed as `_h_rtc` and unused; budgeting for it is budgeting for nothing.
4. **Applying `parametric_shifted_truth_lemma` or `restricted_parametric_shifted_truth_lemma` to a
   branch model.** Both hardwire `ParametricCanonicalTaskModel`, whose world states are MCS
   subtypes; the branch model's are `W × (Set ι × Set ι)`. Reuse the *shape*, never the theorem.
5. **Treating all four `Decidable` instances as one milestone.** ℤ placements are contiguous and
   have empty interior gaps; ℚ/ℝ placements do not. They are different problems.
