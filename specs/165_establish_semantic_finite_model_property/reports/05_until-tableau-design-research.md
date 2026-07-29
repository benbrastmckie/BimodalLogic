# Until/Since Tableau Design Research — resolving the `untlNeg`/`snceNeg` fork

**Mode**: hard-mode design research (H2 lean4 anti-analysis, H3 reference grounding, H4 adversarial
self-verification), read-only.
**Session**: `sess_1785337808_19a89c_165r4`
**Focus**: terminating, sound tableau treatment of Until/Since over general linear time.
**Scope read**: `FormalSystem/Metalogic/Decidability/**`, `FormalSystem/Semantics/{Truth,TaskFrame}.lean`,
`Tests/BimodalTest/{UntlSnceCopyProbe,TableauConformance}.lean`, `specs/165_*/**`.
**Not touched**: `FormalSystem/Metalogic/WeakCanonical/**`, `specs/408_*/**`, `specs/414_*/**`,
`specs/415_*/**`. No `.lean` file was edited; no `lake build` and no elaboration was started.

---

## 0. Executive summary — the fork is resolved, and not in the direction the escalation assumed

Three findings reorder the whole decision. Two are new to this dispatch.

**Finding A (NEW, decisive for the design).** The truth lemma — the *completeness* half of 7.3,
already landed sorry-free in both its `ℤ` and dense versions — **never uses the guard component of
a negative Until.** `Bridge/IntTruth.lean:619` and `Bridge/DenseTruth.lean:271` both open with

```lean
obtain ⟨s, hrs, hsφ, -⟩ := hT
```

discarding the `∀ r ∈ (r,s). ψ@r` component with `-`, and refute the witness by denying `φ` at `s`
alone, via `untlNeg_spread` (`Bridge/TemporalGate.lean:395-402`) whose content is row 1 of the
temporal gate, `untlNegFuture` (`:105-111`): *`F(U(φ,ψ))@(w,t)` denies `φ` at **every** known time
strictly after `t`*. The gate's own docstring says why (`TemporalGate.lean:33-36`): at the target
`s = t'` the guard interval `(r,s)` is **empty**, so *"neither disjunct alone settles the case
`s = t'`, and only `¬φ` at `s` will do."*

**Consequence: branch 2 of `untlNeg` — the guard-failure arm, in every formulation — contributes
nothing whatsoever to the completeness route.** It exists solely to keep the rule *sound*. Every
completeness argument in this repository runs through branch 1. This single fact reprices every
candidate below, and it is the reason the recommendation is not the one the escalation anticipated.

**Finding B (NEW, a fifth defect).** The **ACTIVE** arm of `untlNeg` is *also* unsound, and not
because of its copy block. Its branch 2 asserts `F(U(event,guard))@freshLabel`
(`Tableau.lean:1066-1067`) — the same "propagate the negative Until to another time" defect that
report 03 §2 found in the PASSIVE arm. A refutation over **ℚ** is given in §2.2. It is the exact
dual of report 03 §1.4: that one needed a *discrete* carrier to make the satisfiable region a
maximal point; this one needs a *dense* carrier to make the `¬guard` points accumulate at the
source. **The repair is a one-token deletion and it makes the ACTIVE arm sound outright** (§2.3),
which report 04 did not identify because its scope was the PASSIVE arm only.

**Finding C (confirming report 04, with the mechanism named).** Free interpolants minted for a
PASSIVE-arm target are **pairwise order-incomparable siblings**, and the project's only termination
brake (`isTemporallyBlocked`, via `blocking_fires_of_card_lt`, `Termination/TimeTypeBound.lean:173-186`)
requires an ancestor **chain** (`hchain`). Sibling repeats block nothing. Chaining the interpolants
to restore comparability is **unsound** — it would force an order between two independently-chosen
guard-failure witnesses that the semantics does not license (§3.3). So the divergence is structural,
exactly as report 04 ruled.

**The resolution** is that Finding C's problem is solved not by a *chain* but by a *saturating
witness set*, which is the mosaic method's termination idea in the one form this engine can carry:
**one guard-failure witness per `(source formula, source label)` pair, globally, not per target.**
A single `z` with `A < Z < C'` discharges the `∃z ∈ (A,c).¬g@z` disjunct for **every** later target
`c > z` simultaneously, so the witness set saturates at `|closure|` per label instead of growing per
target. That is the top recommendation (§5), and it *preserves* `BX7`/`BX7'` closure, which the
alternatives do not.

**Finding D (literature, CONFIRMED against a primary source in the corpus).** This is not an
invention. Caleiro–Viganò–Volpe 2013 — whose logic is *this project's shape*, a linear-time
component crossed with an orthogonal S5-like one over the same four order classes — proves
decidability by exactly this route (§1.1): the interpolant is mandatory (saturation condition
**SV3**); it is drawn from a **finite set of types**, giving `2^O(|φ|)`; one cure discharges a whole
downward-closed family of same-formula defects (**Lemma 3.10**); and the paper closes by naming the
one thing a *tableau* realization still needs — *"properly avoiding **the repeated curing of the same
defect**"*. That sentence is the specification for `guardWitnessed` (§5.2), and the gap it names is
precisely where this project is standing.

**Ranked recommendation** (full table in §6):

| Rank | Design | Sound | Terminates | Keeps BX7 | Cost |
|---|---|---|---|---|---|
| **1** | **ACTIVE repair + PASSIVE saturating-witness interpolant + hard-cap safety net** | yes | yes (§5.3) | yes | ~5 coordinated items; **literature-backed** (§1.1) |
| 2 | ACTIVE repair + PASSIVE retirement to `.notApplicable` | yes | trivially | **no** | ~1 item; 2 corpus rows regress |
| 3 | ACTIVE repair + PASSIVE interpolant + pure hard cap (report 04's A3) | yes | yes | yes | bounded completeness, undeclared |
| 4 | Fixpoint/unfolding (LTL-style) | n/a | no | — | needs `X`; does not exist over dense time |
| 5 | Mosaic method as the termination backbone, wholesale | yes | yes | yes | published and correct, but replaces Phases 3-7 |

**Whatever is chosen, do the ACTIVE-arm repair first and alone.** It is one deletion of one
sub-term, it makes half of `RuleSound carrierBase .untlNeg` true, it is gated by the 59 s corpus,
and it carries **zero** design decisions.

---

## 1. Reference grounding — Tier 1 (literature-backed) + Tier 3 (implementation-backed)

Per H3 tier selection: the task cites Reynolds' co-decomposition by name and asks for the dense-time
tableau literature, so this is **Tier 1**, with the engine mapping at Tier 3.

**The `literature-search.sh` helper is degraded and returned nothing:**

```
$ bash .claude/scripts/literature-search.sh "Reynolds tableau until real time"
{"results": [], "degraded": true, "fallback_tier": "none", "query_error": null}
```

**But the corpus itself has the primary source.** Querying `~/Projects/Literature/index.json`
directly resolves a fully chunked copy of

> **C. Caleiro, L. Viganò, M. Volpe**, *On the Mosaic Method for Many-Dimensional Modal Logics*,
> Logica Universalis 7(1), 2013 — chunk directory `sources/caleiro_2013/`, sections §3.1
> (`sec03_31-mosaics.md`), §3.2 (`sec04_32-mosaics-and-satisfiability.md`), §4.2
> (`sec06_42-mosaic-based-tableaux.md`), §4.3 (`sec07_43-decidability-via-mosaics.md`).

**This is the single most relevant source that exists for this task**, because its logic is *this
project's logic shape*: a **linear-time "vertical" component combined with an orthogonal S5-like
"horizontal" component**, parameterised over classes of linear orders (general / dense / discrete /
bounded) — i.e. TM's Until/Since × `□` product, over the same four frame classes. It gives a mosaic
decision procedure at the **basic** branching class (the two components independent), which is
exactly TM's case. It was read directly for this report; the citations below are chunk-grounded.

The corpus also holds Burgess, *Axioms for Tense Logic I: "Since" and "Until"*; the Handbook of
Modal Logic ch. 11 *Temporal Logic*; Gabbay–Hodkinson–Reynolds vols 1-2; and Blackburn–de
Rijke–Venema §7.1-7.2 *Since/Until*. None were needed to settle the design and none were read.

### 1.1 Tier 1 mapping — literature to design decision

| Source | Location | Content, quoted or paraphrased | Design consequence | Status |
|---|---|---|---|---|
| Caleiro–Viganò–Volpe 2013 | `caleiro_2013/sec03_31-mosaics.md`, Def. 3.2-3.3 | A **point** is a subset of a finite subformula-closed, negation-closed sublanguage `Λ`; a **mosaic** is a *pair* of points `(Γ,Δ)` — the types at the two endpoints of an interval | The finite object is a set of **types**, not of time points. Maps onto `Branch.timeType` / `signedStock C` (`TimeTypeBound.lean:70-84`) | **CONFIRMED**, read |
| Caleiro–Viganò–Volpe 2013 | same, Def. 3.5 **(SV3)** | *"if `FA ∈ Γ`, then (i) `A ∈ Δ` or `FA ∈ Δ`; or (ii) **there exist `(Γ,Ω), (Ω,Δ) ∈ S` with `A ∈ Ω`**"* | **The interpolant is mandatory** and is drawn from the *finite* point set. Confirms §3.0's negative result from the other side: splitting the interval is the published mechanism | **CONFIRMED**, read |
| Caleiro–Viganò–Volpe 2013 | same, Def. 3.5 **(SVDns)** | *"there exists `Ω ∈ Points(S)` such that `(Γ,Ω), (Ω,Δ) ∈ S`"* | This **is** `densityRule` (`Tableau.lean:1261-1308`), independently arrived at. Confirms the engine's dense family is the right shape | **CONFIRMED**, read |
| Caleiro–Viganò–Volpe 2013 | `sec04_32-…md`, Def. 3.9 | A **defect** `⟨v, FA⟩` is an eventuality asserted at `v` with no witness above it | Names the object `untlNeg`/`snceNeg` are managing | **CONFIRMED**, read |
| Caleiro–Viganò–Volpe 2013 | `sec04_32-…md`, Lemma 3.10 proof | *"consider a `v′` that is the ≺-**maximal** element of `W` such that `FA ∈ v′` … **By curing the defect `⟨v′, FA⟩`, we will also cure all the defects `⟨w, FA⟩` for `w ≺ v′`**"* | **The saturation principle of §5**: one witness discharges the whole family of same-formula defects below it. Also rehabilitates maximal-target selection, which report 04 §1.4 ruled out for `untlNeg` — the ruling was right for `gapTargets`' mechanism and wrong as a general claim | **CONFIRMED**, read |
| Caleiro–Viganò–Volpe 2013 | `sec07_43-…md`, Thm 4.11 + bound | Satisfiability over `L(C, ())` for `C` a class of linear orders is **decidable**; `\|Λ\| = O(n)`, number of mosaics `O(2^n)`, number of structures `O(2^(2^n))`; coherence and saturation checkable in **polynomial time** | The termination unit is `2^O(\|φ\|)` **types**, matching `TimeTypeBound.lean`'s `2^(2·\|C\|)` exactly | **CONFIRMED**, read |
| Caleiro–Viganò–Volpe 2013 | `sec07_43-…md`, closing paragraph | *"it should also be possible to define a decision procedure for the `C-()`-logics based on the tableau system of Sect. 4.2, by exploiting analyticity of the cut rule in that case and **properly avoiding the repeated curing of the same defect**"* | **The published name for the missing guard.** `guardWitnessed` (§5.2) is exactly "avoid re-curing the same defect". The paper flags this as the open step between its mosaic decidability proof and a *tableau-based* decision procedure — which is precisely where this project stands | **CONFIRMED**, read |
| Caleiro–Viganò–Volpe 2013 | `sec07_43-…md` | Thm 4.11 holds for the **basic** branching class only; interaction between the vertical and horizontal components breaks the translation, and `Λ = F` (the full language) makes the mosaic count infinite | TM's `□` is `Ω`-universal and independent of the temporal component, so TM is in the basic case. But this is the boundary: any future coupling of `□` and `U`/`S` leaves the guaranteed region | **CONFIRMED**, read |
| Reynolds, RTL over the reals (arXiv:cs/9910012); Reynolds AiML 2014 mosaic tableau; his PLTL `[LOOP]`/`[PRUNE]`/`[PRUNE₀]` | not in corpus | mosaics as triples `(A,B,C)` with `B` = types holding strictly between; RTL-SAT PSPACE-complete; PRUNE/LOOP rely on well-founded *discrete* branch extension and are abandoned for mosaics in the real-time setting | Confirms §3.2: fixpoint/loop-check is dead at `.Base`/`.Dense` | **PLAUSIBLE** — relayed from the parallel sweep, venues/titles confirmed, full texts **not read here** |
| Marx–Mikulás–Reynolds TABLEAUX 2000; Reynolds TIME'09; GHR vol. 1 FMP sections; Burgess 1982 (decidability via Rabin's S2S, not FMP) | not in corpus / not read | — | — | **UNVERIFIED** |

**Attribution of the co-decomposition to Reynolds** rests on in-tree comments alone
(`Tableau.lean:1006-1013`) and no bibliographic source was located: **UNVERIFIED**. Note the mosaic
literature's own name for the mechanism is *defect curing*, not co-decomposition.

### 1.2 Tier 3 mapping — source-to-implementation

| Source | Location in source | Lean identifier | Type signature / definition | Status |
|---|---|---|---|---|
| Until semantics | `Semantics/Truth.lean:134-135` | `TruthAt … (Formula.untl φ ψ)` | `∃ s, t < s ∧ TruthAt … s φ ∧ ∀ r, t < r → r < s → TruthAt … r ψ` | CONFIRMED, read |
| Since semantics | `Semantics/Truth.lean:136-137` | `TruthAt … (Formula.snce φ ψ)` | exact mirror (`s < t`, `s < r < t`) | CONFIRMED, read |
| Soundness obligation | `Verified/Decidable.lean:354-360` | `RuleSound (C : CarrierProp) (r : TableauRule) : Prop` | `∀ D … C D → ∀ F M Om hist tv b sf ord, sf ∈ b → SatState … → OrdWithin b ord → SatResult M Om b (applyRule r sf b ord).1 (applyRule r sf b ord).2` | CONFIRMED, read |
| `.notApplicable` is free | `Verified/Decidable.lean:194` | `SatResult … \| .notApplicable, _ => True` | `True` | CONFIRMED, read |
| `.branchingOrdered` obligation | `Verified/Decidable.lean:193` | `SatResult … \| .branchingOrdered brs, _` | `∃ p ∈ brs, ∃ hist tv, SatState M Om hist tv p.1 p.2` (outer ordering **ignored**) | CONFIRMED, read |
| Carrier property (Base) | `Verified/Decidable.lean:243` | `carrierBase : CarrierProp` | `fun _ => True` | CONFIRMED, read |
| Truth-lemma gate row 1 | `Bridge/TemporalGate.lean:105-111` | `untlNegFuture (b : Branch) (ord : TimeOrdering) : Bool` | every `⟨.neg, .untl φ _, ⟨w,t⟩⟩ ∈ b` forces `b.hasNegAt φ ⟨w,v⟩` for all `v ∈ futureKnown b ord t` | CONFIRMED, read |
| Gate consumption | `Bridge/TemporalGate.lean:395-402` | `untlNeg_spread` | `temporalWitnessCheck b ord = true → ⟨.neg,.untl φ ψ,⟨w,t⟩⟩ ∈ b → v ∈ b.knownTimes → strictBefore ord t v = true → b.hasNegAt φ ⟨w,v⟩ = true` | CONFIRMED, read |
| Guard discarded (ℤ) | `Bridge/IntTruth.lean:610-636` | `branchTruthAt_untl_neg` | body line `:619` is `obtain ⟨s, hrs, hsφ, -⟩ := hT` | CONFIRMED, read |
| Guard discarded (dense) | `Bridge/DenseTruth.lean:262-293` | `branchTruthAt_untl_neg_dense` | body line `:271` is `obtain ⟨s, hrs, hsφ, -⟩ := hT` | CONFIRMED, read |
| Termination measure | `Termination/Fuel.lean:110-118` | `expandOnceUnblocked_card_lt` | `… = .extended nb → b.toFinset.card < nb.toFinset.card` | CONFIRMED, read |
| Label bound | `Termination/Fuel.lean:588-594` | `timeFinset_card_le_of_not_blocked` | conditional on `findBlockedTime b ord tracker = none` | CONFIRMED, read (via report 04) |
| Blocking needs a **chain** | `Termination/TimeTypeBound.lean:173-186` | `blocking_fires_of_card_lt` | hypothesis `hchain : … t₁ ∈ ancestorTimes ord t₂ ∨ t₂ ∈ ancestorTimes ord t₁` | CONFIRMED, read |
| Interpolant `ordResp` helper | `Verified/Decidable.lean:1590-1596` | `ordResp_addFuture_addFuture_update` | over `((ord.addFuture t b.nextTime).addFuture b.nextTime t').constraints` | CONFIRMED via report 04 §2.2 |
| Reynolds co-decomposition | — (named in `Tableau.lean:1006-1013` comments) | — | no bibliographic citation exists in-tree | **UNVERIFIED — Tier 1 gap** |

**Source-coverage note (H3 no-single-source rule).** Every load-bearing claim below is cross-checked
against at least two independent reads — the rule body *and* the definition it is measured against
(`SatResult`, `TruthAt`, or the gate) — never against a single site. The one exception is the
attribution of the co-decomposition to Reynolds, which rests on an in-tree comment alone and is
marked UNVERIFIED throughout.

### 1.3 Literature Proof Structure — Caleiro–Viganò–Volpe 2013, and where each step lands here

The decidability proof this design borrows from, step by step, with the Lean translation note for
each. **Only steps 3-5 are being borrowed; steps 1-2 and 6 already have engine counterparts and are
listed to show that the borrowing is local.**

| # | Step in the source | Statement | Lean/engine counterpart | Translation note |
|---|---|---|---|---|
| 1 | Def. 3.2 | A **point** is `Γ ⊆ Λ` closed under `(L1)` sign-completeness, `(L2)` conjunction, `(L3)` `∀`-reflexivity | `Branch.timeType`; `TableauClosed C` (`SubformulaProperty.lean`) | The engine's branch types are *partial* (a branch may leave a formula undecided at a label — `Decidable.lean:118-121`), where a point is *total*. This is why the engine needs the truth-lemma gates and the mosaic method does not |
| 2 | Def. 3.3 | A **vertical mosaic** `(Γ,Δ)` satisfies `(V1)-(V4)`: `G`/`H` transfer and persist across the pair | `boxTemporal`, the `gProps`/`hProps` propagation families | Already present, already proved sound |
| 3 | Def. 3.5 **SV3/SV4** | An eventuality at an endpoint is either discharged at the other endpoint or **split by an interpolant point `Ω`** | the PASSIVE arm of `untlNeg`/`snceNeg` | **This is the fork.** SV3(ii) is the interpolant arm of §5.2 |
| 4 | Def. 3.5 **SVDns / SVUdsc / SVDdsc** | class-specific splitting: density, upward/downward discreteness | `densityRule` (`Tableau.lean:1261-1308`); `priorUZ`/`priorSZ`/`z1Rule` | Term-by-term correspondence; `densityRule` is landed and proved |
| 5 | Lemma 3.10 + Thm 4.11 | Cure at the ≺-maximal defect carrier; the cure set is finite because points are; hence decidable at `2^O(\|φ\|)` | **not present** — the engine's only brake is ancestor-blocking (`TimeTypeBound.lean:173-186`) | **The gap.** §5.3's `guardWitnessed` is the tableau-side realization; §4.3's *"avoiding the repeated curing of the same defect"* is its specification |
| 6 | §4.2 | A sound and complete tableau system, with `CutR` supplying totality of the point sets | the engine, minus `CutR` | The engine has no cut rule; it reaches totality through the gate checks instead. This is why its completeness story is conditional where the paper's is not, and it is **pre-existing**, not caused by anything in this fork |

**What the source does *not* supply**: a termination argument for a *tableau* over a partial-type
branch structure. Thm 4.11 decides satisfiability by enumerating mosaic structures, not by running
the tableau; §4.3's closing paragraph is explicit that the tableau-based procedure is a further step.
So step 5's Lean form is genuinely owed by this project and cannot be transcribed.

---

## 2. The ACTIVE arm — a fifth unsound site, and a one-token repair

### 2.1 What the ACTIVE arm emits today

`Tableau.lean:1022-1069`. Reached when `unprocessed = []` **and** `futureTimes.isEmpty` **and**
`0 < timeOrd.timeCount < 4` (`:1023`). It mints `freshTime := branch.nextTime`, sets
`newOrd := timeOrd.addFuture l.time freshTime`, and returns

```lean
branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp
branch2 := [SignedFormula.neg guard freshLabel,
            SignedFormula.neg (.untl event guard) freshLabel, sf] ++ autoProp
(.branching [branch1, branch2], newOrd)
```

with `autoProp := gProps ++ fNegProps ++ untlNegProps ++ modalProps` (`:1068`). `untlNegProps`
(`:1053-1058`) is the copy block report 04 §4 already authorized for deletion.

### 2.2 A refutation of `RuleSound carrierBase .untlNeg` through the ACTIVE arm, using **no** copy block

The dual of report 03 §1.4. That refutation needed a **discrete** carrier so the satisfiable region
was a single maximal point. This one needs a **dense** carrier so the `¬guard` points accumulate at
the source and every one of them satisfies the Until.

**Carrier and frame.** `D = ℚ`. `F.WorldState = ℚ`, `TaskRel w d u ⟺ u = w + d` — satisfies
`nullity_identity`, `forward_comp` and the converse convention (`TaskFrame.lean:152-190`), and
`ℚ` is `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial`. `τ` is the identity
total-domain history; `Om` is its shift orbit (`ShiftClosed` by construction — and **not**
`Set.univ`, per report 03 §1.5's recorded constraint).

**Valuation.** Atoms `e, g, x, y`:

```
V(q,e) ⟺ q > 0        V(q,g) ⟺ q ∉ {1/n : n ≥ 1}
V(q,x) ⟺ q = 0        V(q,y) ⟺ q = −1
```

**Branch and ordering.**

```
b   = [ F(U(e,g))@(w₀,0),  T(x)@(w₀,0),  T(y)@(w₀,2) ]      sf = F(U(e,g))@(w₀,0)
ord = ⟨[(2,0)]⟩                                              tv 0 = 0,  tv 2 = −1
```

`OrdWithin` holds — both `0` and `2` occur in `b` (`SignedFormula.lean:349`). `SatState` holds:
`ordResp` is `−1 < 0` ✓; `x@0` ✓; `y@(−1)` ✓; and `¬U(e,g)@0` ✓ — any candidate witness `s > 0`
has `e@s`, but `(0,s)` contains some `1/n` where `g` fails, so no witness survives.

**The ACTIVE arm fires.** `futureOf 0 = []` (no forward edge from `0`), so `futureTimes.isEmpty`;
`timeCount ⟨[(2,0)]⟩ = 2` (`SignedFormula.lean:788-792`), so `0 < 2 < 4`. `freshTime = maxTime+1 = 3`
(`SignedFormula.lean:380`). `gProps`, `fNegProps`, `modalProps` are all empty (no `G`, no `F(F·)`,
no `□`/`◇` on the branch); `untlNegProps` is empty because its only candidate is `sf` itself and the
block requires `usf != sf` (`:1054`). **So the copy block plays no part in this refutation.**

**Both arms fail.** Write `A = tv′ 0`, `C = tv′ 3`. `T(x)@0` pins `A = 0`; `T(y)@2` pins
`tv′ 2 = −1`; `ordResp` on `newOrd` forces `C > 0`.

| Arm | Requires | Truth in the model |
|---|---|---|
| branch 1 | `¬e@C` with `C > 0` | `e` holds on all of `(0,∞)` — **fails** |
| branch 2 | `¬g@C`, i.e. `C = 1/n`; **and** `¬U(e,g)@(1/n)` | `U(e,g)@(1/n)` is **true**: pick `s ∈ (1/n, 1/(n−1))` (for `n = 1`, any `s > 1`); `e@s` ✓ and `(1/n,s)` contains no `1/m`, so `g` holds throughout — **fails** |

A satisfiable branch is mapped to two unsatisfiable ones. **`RuleSound carrierBase .untlNeg` is
false via the ACTIVE arm.** The `hist` re-choice is no escape: `Om` is a shift orbit, so re-choosing
`hist` is a uniform translation, and `T(x)` re-pins the origin under it. `snceNeg` follows by the
time-reversal mirror.

**Calibration.** Hand-checked against `Truth.lean:134-135`, `Decidable.lean:188-194` and the arm
body; **not** machine-checked. Same calibration as report 03 §2, which was subsequently pinned by
`UntlSnceCopyProbe` section B. A probe is named in §7.

### 2.3 The repair: delete one sub-term, and the ACTIVE arm becomes sound

```lean
-- BEFORE (Tableau.lean:1066-1067)
let branch2 := [SignedFormula.neg guard freshLabel,
                 SignedFormula.neg (.untl event guard) freshLabel, sf] ++ autoProp
-- AFTER
let branch2 := [SignedFormula.neg guard freshLabel, sf] ++ autoProp
```

**Soundness proof sketch, complete.** `D` is a `Nontrivial` `LinearOrder` `AddCommGroup` with
`IsOrderedAddMonoid`, so some `d > 0` exists and `A + d > A` — `NoMaxOrder` is free and needs no
carrier property. Put `s := A + d`.

* If `¬e@s`: take `tv′ := Function.update tv freshTime s`. Branch 1 holds.
* Else `e@s`. `¬U(e,g)@A` instantiated at `s` gives `¬(e@s ∧ ∀r ∈ (A,s). g@r)`, hence
  `∃ r ∈ (A,s). ¬g@r`. Take `tv′ := Function.update tv freshTime r`. Branch 2 holds, and `r > A`
  discharges `ordResp` on `addFuture l.time freshTime`.

`freshTime = branch.nextTime ∉ b`'s times (`Tableau.not_mem_of_time_nextTime`), so the one-point
update leaves `b` satisfied; `ordResp_addFuture_update` (`Decidable.lean`, landed) discharges the
new constraint. `autoProp` is discharged exactly as for `ruleSound_untlPos`: `gProps` by
`satAt_of_mem_gProps` (`T(G A)@A` ⟹ `A@C` since `C > A`), `fNegProps` by `satAt_of_mem_fNegProps`,
`modalProps` by `mem_boxDiamondPersistence_shape`/`_label` — **all four helpers already landed**
(handoff `do_not_reattempt`).

**This is the same proof shape as `ruleSound_untlPos`, which went green on the first attempt once
its copy block was gone.** Estimated cost: one green commit, ~60-90 lines for the pair.

**Blast radius: minimal.** No fresh time is added or removed; `newOrd` is unchanged; the constructor
stays `.branching`; `ruleMintsFreshLabel` (`Tableau.lean:1741-1744`, which does **not** list
`untlNeg`) is unaffected because the ordering-length test at `Tableau.lean:2207` already covers this
arm. `applyRule_untlNeg_closed` (`SubformulaProperty.lean:1082`) gets a **strictly smaller** emitted
set, so it survives with at most a `simp` adjustment. `sat_untl_neg` reads the `unprocessed` filter,
not the arm output (report 04 §3.1), so it is untouched.

**This repair is independent of every PASSIVE-arm decision below and should land first, alone.**

---

## 3. Candidate evaluation

Throughout: `A = tv l.time`, `C' = tv t'`, `A < C'` (from `SatState.lt_of_mem_futureOf`,
`Decidable.lean:999`). The semantic content the PASSIVE arm owes is, from `Truth.lean:134-135`,

> **(★)** `¬U(e,g)@A` and `A < C'` give exactly `¬e@C' ∨ ∃Z ∈ (A,C'). ¬g@Z`.

### 3.0 A negative result that prunes the search space

**There is no sound PASSIVE arm whose emitted labels are all already on the branch.**

Proof: report 03 §2's model (`ℤ`, `e` true exactly at `3`, `g` false exactly at `1`, `x` pinning
`tv 1 = 3`) refutes every arm-set drawn from `{¬e@t', ¬g@t', ¬U(e,g)@t'}` — at `C' = 3` both
`e` and `g` are true, so any conjunction containing `¬e@t'` or `¬g@t'` fails, and the only remaining
arm is the empty one. And the empty arm is `.branching [[…], []]`, which can never close, so a rule
containing it has **zero** closure power. Hence: **sound + closes ⟹ mints a fresh label.** ∎

This is what makes the fork genuinely a fork rather than a bug hunt, and it is why candidate (d) —
"restate the rule so its targets are drawn from a saturating set of existing times" — is **refuted
as stated**. The `∃Z` disjunct cannot be expressed as a constraint on the *order* alone, because the
ordering language (`TimeOrdering`, a list of strict pairs, `SignedFormula.lean:685-690`) has no
existential and no negation; asserting "some point of `(A,C')` fails `g`" requires a label to hang
`¬g` on.

### 3.1 Candidate (a) — the hard cap (report 04's item A3)

**Soundness**: trivially sound. Refusing to fire returns `.notApplicable`, which `SatResult` reads as
`True` (`Decidable.lean:194`). **Any** suppression is free with respect to 7.2.

**Termination**: unconditional. `timeOrd.timeCount < K` bounds the times this rule can add by `K`,
so the branch's `Finset` stays inside the finite universe and `expandOnceUnblocked_card_lt`
(`Fuel.lean:110`) does its work. This is the mechanism the ACTIVE arm already uses at `K = 4`
(`Tableau.lean:1023`, `:1097`), with the trade owned in its own comment at `:1026-1029`.

**Completeness w.r.t. 7.2/7.3**: this is where the escalation's framing needs correcting.

* **7.2 (`RuleSound`) loses nothing.** Not one of the 34 obligations mentions completeness.
* **7.3's `allClosed → valid` direction loses nothing** — it *is* 7.2.
* **7.3's `valid → allClosed` direction**: this is the direction a cap could damage, and the
  honest answer is that **it damages far less than it appears to, because the gate it must feed is
  already stronger than the cap.** The direction runs through the truth lemma, whose hypothesis is
  `temporalWitnessCheck b ord = true` (12 rows, `TemporalGate.lean:356-361`), whose row 1
  `untlNegFuture` demands `¬φ` at **every** known future time. A branch that took branch 2 at any
  target fails row 1 outright, capped or not. So the cap removes branches that the gate was already
  going to reject.

**What completeness theorem survives a cap** (the escalation asked for this precisely):

> `valid_iff_allClosed` is *not* obtainable as an unconditional iff by any of these designs, and
> that was true before this dispatch. What is obtainable is the **conditional** form:
> `buildTableau (¬φ) = allClosed → valid φ` (7.2, unconditional), together with
> `buildTableau (¬φ) = hasOpen b ∧ temporalWitnessCheck b ord ∧ regionLabelCheck b ord ∧ … → ¬ valid φ`
> — the shape `not_validDense_of_hasOpen` / `exists_countermodel_dense` already have (handoff
> `do_not_reattempt`). The `Decidable` instances of 7.3 then need the gates discharged for the
> branches the engine actually builds, which is the standing `carry_forward` obligation
> (`regionLabelCheck` reports **false** on real engine branches; `temporalWitnessCheck` is twelve
> rows). **A cap on `untlNeg` does not add a new obstruction to that; it lands inside one that
> already exists.**

**Blast radius**: one `&&` clause in one filter, per rule. `sat_untl_neg`/`sat_snce_neg`
(`CountermodelExtraction.lean:766`, `:841`) read the `unprocessed` filter verbatim
(`hFilterPred`, `:820-826`), so a cap added *outside* the filter leaves them green; a cap added
*inside* it forces their restatement. **Add it outside.**

**Interaction with the 26 proved rules**: none. No other rule reads `untlNeg`'s filter.

**Verdict**: sound, terminating, cheap, honest — but **as a sole mechanism it is rank 3**, because a
cap that suppresses the arm entirely also suppresses branch 1, which is the arm the gate *does*
want and the arm `BX7` closes on. A cap is the right **safety net**, not the right **primary**.

### 3.2 Candidate (b) — fixpoint / unfolding with a loop check

**Refuted on the semantics, not on cost.** The LTL/CTL unfolding is
`U(e,g) ≡ e ∨ (g ∧ X U(e,g))` — it consumes a `next` operator. `Formula`
(`Syntax/Formula.lean`) has six constructors, `atom / bot / imp / box / untl / snce`
(`DenseTruth.lean:62-64`), and **no `X`**; and `TruthAt`'s `untl` clause quantifies over a general
`s : D` with a strict `t < s` (`Truth.lean:134`), which over a densely-ordered carrier has no
immediate successor to unfold into. The repeating-state loop check terminates because the LTL
tableau's nodes are *states* in a discrete sequence; there is no sequence here.

**Confirmed against the literature.** Reynolds' PLTL tableau rules `[LOOP]`, `[PRUNE]`, `[PRUNE₀]`
rely on well-founded *discrete* branch extension (bounded label repetition along a sequence), and
for real-numbers time he abandons them and switches to **mosaics** (AiML 2014 tableau is
mosaic-based). Status: **PLAUSIBLE** — relayed, venues confirmed, full texts not read here (§1.1).
This is consistent with, and independently entailed by, the syntactic argument above, which is
CONFIRMED.

**What *does* transfer**: exactly the discrete-time instances already carved out as separate rules —
`priorUZ` / `priorSZ` / `z1Rule`, gated on `.Discrete` (handoff `blockers[1]`), whose semantic
content (`prior_UZ_is_valid : F φ → U(φ, ¬φ)`) is already proved in
`SoundnessLemmas/FrameClassVariants.lean`. Over `.Discrete` the immediate successor exists, `(A, succ A)`
is empty, and **`¬U(e,g)@A ⟹ ¬e@(succ A)`** — a sound, non-branching, non-minting rule. That is the
only place unfolding has purchase, and it is already scoped.

**Verdict**: not available at `.Base`. Rank 4. Do not spend budget here.

### 3.3 Candidate (d) — targets drawn from a saturating set; ordering constraints instead of minted times

**Refuted as stated by §3.0** (the ordering language has no existential). But the *idea* underneath —
"find a set that saturates" — is correct, and §5 is its correct form. Two sub-variants, both refuted,
recorded so they are not re-attempted:

**(d-i) Fire only at ord-adjacent targets.** Restrict `unprocessed` to `t'` with no known time
strictly between `l.time` and `t'`. Does **not** help: adjacency in `ord` says nothing about the
carrier, `tv` is arbitrary, and `(A,C')` is non-empty in `ℚ` regardless. This is a re-run of the
adjacency invariant the handoff's `do_not_do_instead` already declined for the third time, and the
declination stands.

**(d-ii) Chain the interpolants so blocking fires.** Mint `z₂` *below* `z₁` with the edge
`(z₂,z₁)` recorded, making the interpolants an `ancestorTimes` chain so
`blocking_fires_of_card_lt` (`TimeTypeBound.lean:173-186`) applies at `2^(2|C|)`. **Unsound.**
`RuleSound` is a *per-step* obligation: at the step that mints `z₂`, `SatState` already fixes
`tv z₁` with `¬g₁@(tv z₁)`, and the arm would demand `Z₂ ∈ (A, tv z₁)` with `¬g₂@Z₂`. But
`¬U(e₂,g₂)@A` licenses only `∃Z₂ ∈ (A,C')`, which may lie **above** `tv z₁`. Minting above `z₁`
fails symmetrically. **The two witnesses are independently chosen and no order between them is
licensed** — which is precisely why they are incomparable siblings, and therefore precisely why
blocking cannot see them. Finding C's problem and the obvious fix to it are the same fact.

### 3.4 Candidate (e) — the mosaic method as termination backbone

Two readings, with different verdicts.

**(e-wholesale) Replace the tableau with a mosaic decision procedure.** Correct and published:
Caleiro–Viganò–Volpe 2013 Thm 4.11 (`caleiro_2013/sec07_43-…md`) decides satisfiability for
`L(C, ())` over any class `C` of linear orders, with `|Λ| = O(n)`, `O(2^n)` mosaics, `O(2^(2^n))`
structures, and coherence/saturation checkable in polynomial time. **Refuted on blast radius, not on
correctness**: it replaces `applyRule`, `expandOnceUnblocked`, `Saturation`,
`CountermodelExtraction` and both truth lemmas — discarding Phases 3-7 entirely, including the 26
proved `RuleSound` theorems and the sorry-free truth lemma. Rank 5. **But it is the right thing to
know exists**, because it is the fallback if the tableau route is ever abandoned, and because its
frame-class parameterisation (`SVDns` for dense, `SVUdsc`/`SVDdsc` for discrete — `sec03_31-…md`
Def. 3.5) is a term-by-term match for this engine's `densityRule` / `priorUZ` / `priorSZ` family.

**(e-local) Borrow the mosaic *saturation* idea for the interpolant set only.** This is the
recommendation, and §5 states it. The transferable content, now literature-grounded (§1.1):

1. *The interpolant is mandatory* — **SV3**(ii) requires `(Γ,Ω),(Ω,Δ) ∈ S` with `A ∈ Ω`. This is
   §3.0's negative result seen from the completeness side.
2. *The finite object is the set of **types**, not of points* — `Points(S) ⊆ 𝒫(Λ)`, so
   `2^O(|φ|)`. The engine's counterpart already exists: `signedStock C` has cardinality `2·|C|`
   (`TimeTypeBound.lean:81-84`) and a time type is an element of its powerset, giving `2^(2·|C|)`
   (`:22-27`).
3. *One cure discharges a downward-closed family* — Lemma 3.10: cure at the ≺-maximal carrier of the
   defect and *"we will also cure all the defects `⟨w, FA⟩` for `w ≺ v′`"*. **This is the saturation
   principle of §5.**
4. *A tableau realization needs one extra thing, and the paper names it*: §4.3's closing sentence,
   *"properly avoiding the repeated curing of the same defect"*. That is `guardWitnessed`.

What the repository lacks is only (3)+(4) as a Lean argument — it has (2) already, and (1) is what
report 03 §2 discovered independently.

**One caveat, taken from the source and not glossed.** Thm 4.11 is proved for the **basic** branching
class `D = ()`, where the vertical (linear-time) and horizontal (S5) components are independent, and
the paper is explicit that the argument *"does not extend to the logics `L(C,D)` for `D ≠ ()`"*
because interaction between the components breaks the model-to-mosaic translation. TM sits inside
the safe region — `□` quantifies over a shift-closed `Ω` (`Truth.lean:131`) independently of the
temporal index, which is exactly what makes `boxDiamondPersistence` sound. **But this is the
boundary**, and it should be recorded: any future rule coupling `□` with `U`/`S` leaves the region
where a mosaic bound is known to exist.

---

## 4. Literature reconciliation — what was asked, what was found, what is still open

| Question from the escalation | Answer | Status |
|---|---|---|
| Mosaic saturation bound over linear orders | `\|Λ\| = O(n)`, `O(2^n)` mosaics, `O(2^(2^n))` structures; coherence + saturation poly-time; decidable for every class `C` of linear orders (Caleiro–Viganò–Volpe 2013 Thm 4.11) | **CONFIRMED**, read |
| What plays the role of the finite saturating set | The set of **points** (= types) over the finite closure `Λ`, and the sets of mosaics over them | **CONFIRMED**, read |
| How published systems bound fresh interpolants | They do not mint points at all: SV3(ii) demands the splitting point **already be in the finite structure**. In a tableau realization the counterpart is "avoid re-curing the same defect" (§4.3, verbatim) | **CONFIRMED**, read |
| Reynolds' PRUNE/LOOP: does it transfer to dense time? | No. Discrete-only; he switches to mosaics for RTL | **PLAUSIBLE** (relayed; not read here). Independently entailed by §3.2's syntactic argument, which is CONFIRMED |
| Reynolds' RTL mosaic shape / PSPACE-completeness | mosaics as triples `(A,B,C)`, `B` = types strictly between; RTL-SAT PSPACE-complete; reals need a "shuffle" tactic and a level-`n` hierarchy for Dedekind completeness | **PLAUSIBLE** (relayed; not read here). **Relevant to the `.Dedekind` frame class, not to this fork** |
| FMP for U/S over general linear orders | Burgess 1982 obtains decidability via Rabin's S2S, **not** via an FMP | **PLAUSIBLE** (relayed; not read here) |
| Marx–Mikulás–Reynolds TABLEAUX 2000; Reynolds TIME'09; GHR vol. 1 FMP sections | not readable in this dispatch | **UNVERIFIED** |
| Attribution of the co-decomposition to Reynolds | no bibliographic source located; the mosaic literature calls the mechanism *defect curing* | **UNVERIFIED** |

**Nothing still open changes the recommendation.** The two `UNVERIFIED` rows are attribution and
`.Dedekind`-class detail; the `PLAUSIBLE` rows all point the same way as arguments in this report
that are independently CONFIRMED. The one row that *would* have forced a re-think — "some published
system decomposes `¬U` at existing points without an interpolant" — is contradicted by SV3(ii),
which is CONFIRMED and read, and by §3.0, which is a proof rather than a survey.

---

## 5. TOP RECOMMENDATION — saturating-witness interpolant, with a hard-cap safety net

Three items, landed in this order, each with its own gate.

### 5.1 Item 1 (land first, alone) — the ACTIVE-arm repair

**Assumes the concurrent cycle-7 dispatch has already deleted the two remaining copy blocks**
(`untlNegProps` at `Tableau.lean:1053-1058` with its use at `:1068`; `snceNegProps` at `:1126-1131`
with its use at `:1141`), which report 04 §6 authorized separately. Line numbers below shift by that
deletion; anchor on the `branch2 :=` binder inside each ACTIVE arm rather than on the line number.

**The remaining edit is one sub-term per rule** (§2.3):

* delete `SignedFormula.neg (.untl event guard) freshLabel` from the ACTIVE `branch2`
  (`Tableau.lean:1066-1067` pre-shift); mirror `.snce` (`:1139-1140` pre-shift).

**This edit is new and is not covered by the copy-block authorization.** The copy block and this
sub-term are different defects: the copy block relabels *other* negative Untils onto the fresh time,
whereas this sub-term relabels *the source itself*. Deleting the first does not touch the second, and
§2.2's refutation uses only the second.

**Gate**: the 29-row conformance corpus, before and after (59 s — measured, per the handoff's
process lesson), plus `UntlSnceCopyProbe` sections A and C re-pinned. Risk is under-closing only.
**Then prove `RuleSound carrierBase .untlNeg`'s ACTIVE half** — but note it is not a separate theorem;
see 5.4.

### 5.2 Item 2 — the PASSIVE arm, Lean-ready

Replacing `Tableau.lean:1013-1021` (the filter) and `:1070-1077` (the arm). `.snceNeg` is the exact
time reversal (`addPast`, `pastOf`, `pastKnown`).

```lean
| .untlNeg, .neg, φ =>
    match asUntil? φ with
    | some (event, guard) =>
      let futureTimes := timeOrd.futureOf l.time
      -- (i) A guard-failure witness for THIS source, anywhere above l.time.
      --     ONE such witness discharges the ∃z disjunct for EVERY target above it,
      --     so the witness set saturates at one per (source formula, source label).
      let guardWitnessed : Bool :=
        futureTimes.any fun z =>
          branch.contains (SignedFormula.neg guard { world := l.world, time := z })
      -- (ii) A target counts only when neither disjunct is already discharged for it.
      --      The guard half is an INTERVAL test (report 04 §1.6), not a point test.
      let unprocessed := futureTimes.filter fun t' =>
        !branch.contains (SignedFormula.neg event { world := l.world, time := t' })
        && !(futureTimes.any fun z =>
              (z == t' || (timeOrd.futureOf z).contains t')
              && branch.contains (SignedFormula.neg guard { world := l.world, time := z }))
      match unprocessed with
      | [] =>
        if futureTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4 then
          -- ACTIVE arm, repaired per §2.3 (body unchanged otherwise)
          …
        else (.notApplicable, timeOrd)
      | t' :: _ =>
        -- (iii) SATURATION GUARD + SAFETY NET. Either is sufficient for termination;
        --       both are sound, because suppression returns .notApplicable (SatResult = True).
        if guardWitnessed || timeOrd.timeCount ≥ 8 then
          (.notApplicable, timeOrd)
        else
          let targetLabel : Label := { world := l.world, time := t' }
          let interTime  := branch.nextTime
          let interLabel : Label := { world := l.world, time := interTime }
          let newOrd := (timeOrd.addFuture l.time interTime).addFuture interTime t'
          let branch1 := [SignedFormula.neg event targetLabel, sf] ++ branch
          let branch2 := [SignedFormula.neg guard interLabel, sf] ++ branch
          -- .branchingOrdered is FORCED: the arms carry DIFFERENT orderings, and
          -- .branching shares one across all arms (Tableau.lean:2129-2130).
          -- The OUTER component MUST be newOrd, not timeOrd (report 04 §2.5).
          (.branchingOrdered [(branch1, timeOrd), (branch2, newOrd)], newOrd)
    | none => (.notApplicable, timeOrd)
```

Four differences from the diff report 04 refuted, each load-bearing:

1. **`guardWitnessed`** — new. The saturation guard. This is the item that fixes termination.
2. **Interval-form `unprocessed`** — report 04 §1.6's amendment, now *necessary but no longer
   asked to be sufficient*.
3. **`timeCount ≥ 8`** — the safety net (report 04's A3), demoted from primary mechanism to backstop.
4. **outer `newOrd`** — report 04 §2.5's bug fix. Free w.r.t. `RuleSound`, because
   `SatResult`'s `.branchingOrdered` clause ignores the second component (`Decidable.lean:193`).

`F(U(event,guard))@t'` is **dropped** from branch 2, per report 03 §2 and report 04 §2.1.

### 5.3 Termination argument — stated precisely

**What saturates**: for each pair `(source signed formula, source label)`, the set of guard-failure
witnesses on the branch. It saturates at **one**.

**Why**: after the mint, `interTime ∈ timeOrd.futureOf l.time` (the edge `(l.time, interTime)` is in
`newOrd`, and `futureOf` is the transitive closure, `SignedFormula.lean:776-777`) and
`branch2` carries `¬guard@interTime`. So `guardWitnessed` is `true` on that sub-branch **forever**
(expansion is additive, `fs ++ b`), and this source never mints again. On `branch1` nothing is
minted at all, and `t'` is permanently discharged by `¬event@t'`.

**Why the cross-formula descent dies.** Report 04 §1.6's counterexample traced: `F₁` mints `z₁ ∈ (a,t)`
carrying `¬g₁`; `F₂` then fires at `z₁` and mints `z₂ ∈ (a,z₁)` carrying `¬g₂`; `z₂` is unprocessed
for `F₁`, which mints `z₃`; and so on. Under `guardWitnessed`, step 3 does not happen: at that point
`z₁ ∈ futureOf a` already carries `¬g₁`, so `F₁`'s mint is suppressed globally regardless of which
target it is looking at. `F₂` is suppressed by `z₂` symmetrically. **Total mints at label `a` ≤ the
number of distinct negative Untils at `a` ≤ `|C|`.** The `BX7` case — three `F(U(·,⊤∧⊤))` on one
branch, which report 04 §5 named as the shape that defeats interval-widening filters — mints
**exactly three** times and stops.

**The finite measure.** Two independent bounds, either sufficient:

* *Primary (saturation).* A minted `interTime` carries exactly one formula, `¬guard`, whose
  Until-content is a **strict subformula** of the source's. So the mint relation is well-founded on
  formula size: mint depth ≤ `depth φ`, breadth ≤ `|C|` per label, giving at most `|C|^(depth φ)`
  minted times. Finite, and independent of blocking.
* *Backstop (the cap).* `timeCount ≥ 8` bounds the arm's contribution unconditionally, which keeps
  `Fuel.lean`'s existing `expandOnceUnblocked_card_lt` / finite-universe argument
  (`Fuel.lean:110-118`, `:588-594`) applicable without a new ingredient.

**The literature's refinement, and the residual circularity it removes.** The bound above is indexed
by `(source formula, source **label**)`, and labels are not a priori bounded — that is a real
circularity, and the subformula-descent argument is what patches it. Caleiro–Viganò–Volpe index by
**type** instead: a defect is `⟨v, FA⟩` where `v`'s content is a *point* `Γ ⊆ Λ`, and the finite set
is `Points(S) ⊆ 𝒫(Λ)`, giving `2^O(|φ|)` outright with no circularity.

**Optional strengthening (type-indexed `guardWitnessed`)**: widen the suppression from "some `z ∈
futureOf l.time` carries `¬guard`" to "some time whose *type* already exhibits this defect-cure
pair has been cured". The engine has the machinery — `Branch.timeType` and `timeTypeFinset`
(`TimeTypeBound.lean`) — and the bound then falls out of `2^(2·|C|)` directly.

* **Soundness cost: zero.** More suppression is more `.notApplicable`, and `SatResult`
  `.notApplicable = True` (`Decidable.lean:194`).
* **Completeness cost: real but bounded.** Two labels with the same type are *not* the same instant,
  and the ordering distinguishes them; a cure at one does not place a witness in the other's
  interval. So type-indexing can suppress a genuinely needed cure. **Do not take this strengthening
  in the first landing.** Take the label-indexed form (§5.2), which is what the acceptance rows
  measure, and hold type-indexing in reserve for the case where B5b shows growth.

**Honest statement of what is *not* proved.** The primary bound is a design argument, not a Lean
theorem; the repository's landed termination results all assume `NoSplit` (`Fuel.lean:1250-1254`)
and so cover neither branching constructor today (report 04 §1.5 — CONFIRMED). Note in particular
that the escalation's premise *"the FMP context may already bound branch size"* is **false for the
branches this rule touches**: the label bound `timeFinset_card_le_of_not_blocked`
(`Fuel.lean:588-594`) is conditional on `findBlockedTime … = none`, and §Finding C shows blocking
never fires on free interpolants. **The backstop cap is therefore what makes this recommendation
safe today**, without a new termination theorem. If the backstop is later removed, the primary bound
must be proved first — and the literature-backed way to prove it is the type-indexed form.

### 5.4 Soundness — and one important structural note

`RuleSound` is stated **per rule**, over both arms (`Decidable.lean:354-360`). So there is no
"ACTIVE half" theorem: `ruleSound_untlNeg` becomes provable only when **both** items 1 and 2 have
landed. The two-commit sequence is for attributability (report 04 §4.4), not for two theorems.

The obligation, arm by arm:

| Arm | Witness | Discharging lemma |
|---|---|---|
| ACTIVE branch 1/2 | `Function.update tv freshTime s` (resp. `r`) | `ordResp_addFuture_update`, `satAt_update_nextTime_of_mem` — landed |
| PASSIVE branch 1 | `tv` unchanged, paired with `timeOrd` | direct; `SatState.append` — landed |
| PASSIVE branch 2 | `Function.update tv interTime Z`, `Z` from (★) | **`ordResp_addFuture_addFuture_update`** (`Decidable.lean:1590-1596`) — landed, and its statement matches `newOrd` character for character (report 04 §2.2) |
| suppressed cases | — | `SatResult … .notApplicable = True` (`Decidable.lean:194`) |

`A < C'` for the PASSIVE case comes from `SatState.lt_of_mem_futureOf` (`Decidable.lean:999`) with
`t' ∈ timeOrd.futureOf l.time`. **The soundness half is genuinely cheap** — report 04 §2.2's
assessment, which this report confirms and does not revise.

### 5.5 Blast radius — the full list, with report 04's five items reconciled

| # | Item | Site | Status vs. report 04 |
|---|---|---|---|
| B1 | ACTIVE `branch2` drops `¬U`; copy blocks deleted | `Tableau.lean:1053-1058, 1066-1068, 1126-1131, 1139-1141` | **NEW** — report 04 did not identify the ACTIVE `¬U` defect |
| B2 | `unprocessed` widened to the interval form | `Tableau.lean:1013-1021`, `:1086-1094` | = report 04 A1 |
| B3 | `guardWitnessed` saturation guard + `timeCount` net | new | supersedes report 04 A3; the cap is demoted to a net |
| B4 | outer component `newOrd` | the arm's last line | = report 04 A2 |
| B5 | `sat_untl_neg`/`sat_snce_neg` restated: conclusion becomes `… ∨ ∃ z, ¬guard@z ∧ z ∈ futureOf t ∧ t' ∈ futureOf z` | `CountermodelExtraction.lean:766`, `:841` (`maxHeartbeats 3200000` at `:835`) | = report 04 A4; **forced by B2**, expensive |
| B6 | `applyRule_untlNeg_closed` / `_snceNeg_closed` re-proved for `emitted`'s `.branchingOrdered` clause (`(bs.map Prod.fst).flatten` — whole branches, routed through `hb`) | `SubformulaProperty.lean:134-139`, `:1082`, `:1114` | = report 04 A5/§2.7 |
| B7 | `ruleSelfGuarded` (`Tableau.lean:1757-1759`) becomes dead; docstrings at `:1749-1755` and `:1878-1881` become false | `Tableau.lean` | = report 04 §2.6 |
| B8 | `TemporalGate.lean:34`'s note that its gate is *"stronger than `sat_untl_neg`'s `F(φ)@t' ∨ F(ψ)@t'`"* must be re-worded after B5 | `TemporalGate.lean:34` | **NEW** |
| B9 | `expandOnceNoFresh` / `saturateBlocked` invariants re-verified under B4 | `Tableau.lean:2206-2208`, `Saturation.lean:468-474` | = report 04 §2.5; **B4 repairs them** |

**Interaction with the 26 proved rules: none.** No landed `ruleSound_*` theorem mentions `untlNeg`,
`snceNeg`, `ruleSelfGuarded`, or their filters; `RuleSound` is per rule; and the two copy helpers
`Branch.untlNegFormulas` / `snceNegFormulas` have no call site outside the four `untl`/`snce` arms
(report 03 §3, exhaustive grep). `untlPos`/`sncePos` were proved *after* their copy blocks were
deleted and do not read `untlNeg`'s output.

### 5.6 Acceptance gates

**Corpus**: all 29 `#guard_msgs` rows of `Tests/BimodalTest/TableauConformance.lean`, measured
**before** and **after** each of the two commits (59 s per run). The rows this arm drives are
`BX7 lin-until` (`:306-309`) and `BX7' lin-since` (`:310-313`) — **not** "H, J, M, N", which do not
exist (report 04 §3.2, REFUTES the handoff). `BX10`/`BX10'` (`:302-305`) exercise `untlPos`/`sncePos`
and should be unchanged.

**Why `BX7` survives this design and does not survive candidate 2.** `BX7`'s guard is `⊤∧⊤`, not
`Formula.top`, so `asUntil?` accepts it and the arm fires. Branch 2 emits `¬(⊤∧⊤)@interTime`, which
closes by `andNeg` **wherever `interTime` is placed** — the interpolant's freedom costs nothing when
the guard is a tautology. Branch 1 emits `¬(p∧q)@t'` at the *existing* target, which is where the
closure against the antecedent's witnesses happens. **Both arms close, and the closure is by the
same route as today.** Under candidate 2 (PASSIVE retirement) branch 1 is never emitted at an
existing time and `BX7`/`BX7'` regress.

**New probe rows** — `Tests/BimodalTest/UntlSnceCopyProbe.lean`, on the existing `bB`/`srcB`/`ordB`
(`:130-138`). Report 04 §3.3's list, **corrected and extended**:

| Row | Statement | Expected |
|---|---|---|
| **B0′ (NEW, item 1's gate)** | `armsB` destructured for the ACTIVE arm on a `futureTimes`-empty branch contains **no** `¬U(e,g)@fresh` | `false` |
| B1′ | `def armsB := match resB.1 with \| .branchingOrdered bs => bs.map Prod.fst \| _ => []`; `#eval armsB.length` | `2` |
| B2′ | `#eval (resB.1 matches .branchingOrdered _) && armsB.any (·.any (·.label.time == 2))` | `true` |
| B3′ | `#eval resB.2.constraints.length > ordB.constraints.length` | `true` (pins B4) |
| B4′ | no arm carries both `¬g@1` and `¬U(e,g)@1` (current B4 body, `:174-178`) | `false` |
| **B5 (the row report 04 named as decisive)** | `expandBranchWithFuel bB k ordB .Base` for two fixed `k` (say 20 and 40); `#eval` the result's `Branch.knownTimes.length` | **the same fixed number for both `k`** — divergence shows as a number that grows with `k` |
| **B5b (NEW, the saturation row)** | on a branch with **two** negative Untils at one label, `Branch.knownTimes.length` after saturation | a fixed number ≤ `2 + 2` — pins §5.3's "one mint per source" |
| B6 | `#eval (expandOnceNoFresh bB ordB .Base).1 matches .splitOrdered _` | `false` (pins B4/B9) |
| C2/C3/C5 | re-measure `isInvalid` / `getCountermodel?.isSome` / `isFuelExhausted` | re-pin; a fresh-time producer changes fuel |

**Without B5 and B5b the gate cannot distinguish "repair landed" from "repair landed and the engine
diverges".** They are the acceptance criterion, not an extra.

**Note the existing probe breaks silently** under the constructor switch: `:144-147` matches
`.branching` only, so `armsB = []` and rows B1/B2/B4 read vacuously (report 04 §3.3 — CONFIRMED).
B1′ must land in the same commit as the arm.

---

## 6. Ranked candidates — full comparison

| | Design | Sound? | Termination: what decreases / saturates | 7.2 | 7.3 `→` (completeness) | Blast radius | Keeps 29/29? |
|---|---|---|---|---|---|---|---|
| **1** | **§5**: ACTIVE repair + saturating-witness interpolant + cap net | **yes** (§5.4) | witness set saturates at 1 per `(source, label)`; mint tree well-founded on subformula size; `timeCount` net makes it unconditional | `ruleSound_untlNeg`/`_snceNeg` **provable** → 34/34 | unchanged — branch 2 was already gate-dead (§0 Finding A) | B1-B9 (§5.5); B5 is the expensive item | **yes** (§5.6) |
| 2 | ACTIVE repair + PASSIVE → `.notApplicable` | yes | trivially: rule adds ≤1 time per label, only when `futureTimes` empty | provable → 34/34 | strictly worse: `¬event@t'` never reaches an existing time, so `untlNegFuture` is harder to satisfy | **1 item** (delete the arm + item 1) | **no** — `BX7`/`BX7'` regress |
| 3 | ACTIVE repair + interpolant + **pure** cap (report 04 A3) | yes | hard `timeCount < K` only | provable → 34/34 | bounded completeness, and the bound is undeclared | B1,B2,B4-B9 | probably, at `K` large enough — untested |
| 4 | Fixpoint/unfolding + loop check | n/a | n/a | — | — | — | requires `X`; **does not exist** at `.Base` (§3.2) |
| 5 | Mosaic method wholesale | yes | mosaic set saturates at `2^O(\|φ\|)` (Caleiro–Viganò–Volpe 2013 Thm 4.11, **read**) | discards 26 proved rules | rebuilt from scratch | replaces Phases 3-7 | rebuilt |

**If the orchestrator wants the cheapest path to 34/34 and is willing to lose two corpus rows to an
honest unsoundness fix, take rank 2 — but declare the corpus regression in advance.** Otherwise take
rank 1. Rank 1 is a superset of rank 2's work plus items B2-B8, so **rank 2 is a valid checkpoint on
the way to rank 1** and nothing done for it is wasted.

---

## 7. If the top choice is deferred — what must still be recorded

Two facts belong in the tree regardless of which candidate is authorized, because they are currently
**false statements sitting in source**:

1. `Verified/Decidable.lean`'s section on `untlNeg`/`snceNeg` records **two** obstructions (the
   ACTIVE copy block and the PASSIVE co-decomposition). There are **three**: the ACTIVE arm's own
   `¬U(e,g)@fresh` (§2.2) is independent of both, and is refuted only over a **dense** carrier.
   The record should note the discrete/dense duality explicitly, since the recorded ACTIVE-arm
   counterexample-hunting lesson ("make the satisfiable region a single maximal point, which
   requires a discrete carrier") points the wrong way for this one.
2. `Tableau.lean:1749-1755`'s `ruleSelfGuarded` docstring — *"a target time counts only when neither
   co-decomposition output is on the branch yet"* — is the property every candidate except rank 2
   destroys, and report 04 §1.1 already showed it is what makes the current filter work at all.

**Recommended probe to pin §2.2 before any edit**: a new section D in `UntlSnceCopyProbe.lean`
applying `applyRule .untlNeg` to `[F(U(e,g))@(w₀,0), T(x)@(w₀,0), T(y)@(w₀,2)]` with
`ord = ⟨[(2,0)]⟩`, pinning that the ACTIVE arm fires (2 branches), mints time `3`, and that branch 2
contains `¬U(e,g)@(w₀,3)`. Three `#eval` rows, ~2 s. That converts §2.2 from a hand argument into a
fact, exactly as section B did for report 03 §2.

---

## 8. Adversarial Self-Verification

Every load-bearing claim, the evidence, the method, and what would falsify it.

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Verdict | Confidence |
|---|---|---|---|---|
| The truth lemma's negative-Until case **discards the guard** and refutes the witness by `¬φ@s` alone | `Bridge/IntTruth.lean:619` and `Bridge/DenseTruth.lean:271`, both literally `obtain ⟨s, hrs, hsφ, -⟩ := hT` | Direct read of both proof bodies + the four leaves each dispatches to | **CONFIRMED** | High |
| The gate row the negative case consumes is `untlNegFuture` = "deny the event at every known future time", and it has **no** guard alternative | `Bridge/TemporalGate.lean:105-111` (definition), `:395-402` (`untlNeg_spread`), `:356-361` (`temporalWitnessCheck` = 12 rows) | Definition read + consumption-lemma read | **CONFIRMED** | High |
| Therefore branch 2 of `untlNeg` is completeness-dead in **both** the `ℤ` and dense truth lemmas | Composition of the two rows above; both truth lemmas take `hTW : temporalWitnessCheck b ord = true` (`IntTruth.lean:612`, `DenseTruth.lean:264`) | Cross-check of both binder lists | **CONFIRMED** | High |
| The gate's own docstring gives the reason: at `s = t'` the guard interval is empty | `TemporalGate.lean:33-36` | Direct read | **CONFIRMED** | High |
| `.notApplicable` makes any suppression free w.r.t. `RuleSound` | `Verified/Decidable.lean:194` — `\| .notApplicable, _ => True` | Definition read | **CONFIRMED** | High |
| **The ACTIVE arm is unsound, independently of the copy block**, refuted over `ℚ` | §2.2 model: `e` on `(0,∞)`, `g` off exactly at `{1/n}`, `x` pinning `A=0`, `y` pinning the ordering; both arms fail | Truth sets recomputed from `Truth.lean:134-135`; arm output recomputed from `Tableau.lean:1022-1069`; `nextTime` from `SignedFormula.lean:380`; `timeCount` from `:788-792`; `futureOf` from `:776`; `OrdWithin` from `:349`; frame from `TaskFrame.lean:152-190` | **CONFIRMED (hand-checked)**; machine confirmation pending — §7 probe | Medium-High |
| `untlNegProps` is empty in that refutation, so the copy block plays no part | `Tableau.lean:1054` requires `usf != sf`, and `sf` is the branch's only negative Until | Direct read of the block's guard | **CONFIRMED** | High |
| Deleting `¬U(e,g)@freshLabel` makes the ACTIVE arm **sound** | §2.3 proof: pick `s = A+d` (`d > 0` exists by `Nontrivial` + ordered group); either `¬e@s` or `∃r ∈ (A,s). ¬g@r` by instantiating `¬U(e,g)@A` at `s` | Definitional unfolding of `Truth.lean:134-135`; helper availability checked against the handoff's landed list | **CONFIRMED** | High |
| `NoMaxOrder` is free and needs no carrier property | `RuleSound` binds `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` (`Decidable.lean:355`); a nonzero `d` gives `A < A + \|d\|` | Binder read + one-line order argument | **CONFIRMED** | High |
| **There is no sound PASSIVE arm using only existing labels** | §3.0: report 03 §2's `ℤ` model kills every arm-set over `{¬e@t', ¬g@t', ¬U@t'}`; the empty arm has zero closure power | Enumeration of the arm-sets against one refuting model | **CONFIRMED** | Medium-High (rests on report 03 §2's model, itself hand-checked and probe-pinned) |
| The ordering language cannot express the `∃Z` disjunct | `TimeOrdering` is `{ constraints : List (TimeIndex × TimeIndex) }` with `addFuture`/`addPast` as the only builders (`SignedFormula.lean:685-690`) | Definition read | **CONFIRMED** | High |
| Chaining interpolants to make blocking fire is **unsound** | §3.3(d-ii): `RuleSound` is per step; at the mint of `z₂`, `tv z₁` is already fixed by `SatState`, and `¬U(e₂,g₂)@A` does not license `Z₂ < tv z₁` | Per-step reading of `RuleSound` (`Decidable.lean:354-360`) against (★) | **CONFIRMED** | Medium-High |
| Blocking requires a **chain**, and free interpolants are incomparable siblings | `TimeTypeBound.lean:173-186` hypothesis `hchain`; under the refuted diff `newOrd` adds only `(a,zᵢ)` and `(zᵢ,t')`, so `zᵢ`, `zⱼ` are unrelated | Hypothesis read + edge-set computation | **CONFIRMED** (agrees with report 04 §1.3) | High |
| `guardWitnessed` stops report 04 §1.6's cross-formula descent | §5.3 re-traces the exact 3-step descent; step 3 is suppressed because `z₁ ∈ futureOf a` already carries `¬g₁` | Re-execution of report 04's own counterexample against the new guard | **CONFIRMED** | Medium-High — **B5/B5b are the resolving measurement** |
| One witness discharges the `∃Z` disjunct for every later target | (★) with `Z` fixed: `Z ∈ (A,C')` for **every** `C' > Z` | Direct from `Truth.lean:134-135` | **CONFIRMED** | High |
| `BX7`/`BX7'` survive rank 1 because their guard is `⊤∧⊤` and branch 2 closes wherever the interpolant lands | `TableauConformance.lean:306-313`; `asUntil?` rejects `Formula.top` but not `⊤∧⊤` (`Tableau.lean:313-317`, and report 04 §3.2) | Row read + matcher read | **PLAUSIBLE** — the closure of `¬(⊤∧⊤)` was not re-run | Medium — **UNVERIFIABLE-WITHOUT-BUILD** |
| `BX7`/`BX7'` regress under rank 2 | Same reasoning inverted: branch 1 is never emitted at an existing time | Same | **PLAUSIBLE** | Medium — **UNVERIFIABLE-WITHOUT-BUILD** |
| Corpus rows "H, J, M, N" do not exist; `BX7`/`BX7'` are the gate | `TableauConformance.lean:306-313` vs. the handoff's row naming | Row enumeration (independently re-checked here) | **CONFIRMED** — REFUTES the handoff, agreeing with report 04 §3.2 | High |
| The existing probe section B breaks silently under a constructor switch | `UntlSnceCopyProbe.lean:144-147` matches `.branching` only; rows at `:150-178` | Direct read | **CONFIRMED** | High |
| `sat_untl_neg`/`sat_snce_neg` must be restated once the filter widens | They derive their conclusion from the filter predicate, not the arm (`CountermodelExtraction.lean:820-826`) | Read of the derivation (via report 04 §3.1, re-checked against the statement at `:766-773`) | **CONFIRMED** | High |
| No landed `RuleSound` theorem is invalidated | `RuleSound` is per rule (`Decidable.lean:354-360`); `untlNegFormulas`/`snceNegFormulas` have no call site outside the four arms | Statement read + report 03 §3's exhaustive grep | **CONFIRMED** | High |
| A hard cap costs **less** completeness than it appears, because the gate it feeds is already stronger | `untlNegFuture` demands `¬φ` at every known future time; a branch-2 branch fails it capped or not | Gate definition vs. arm output | **CONFIRMED** | Medium-High |
| `valid_iff_allClosed` is not obtainable unconditionally under **any** candidate, and was not before | `regionLabelCheck` reports **false** on real engine branches (handoff `carry_forward`); `temporalWitnessCheck` is 12 undischarged rows | Handoff + gate read | **CONFIRMED** | Medium-High |
| No proved termination theorem breaks under any candidate, because all assume `NoSplit` | `Fuel.lean:1250-1254`, `:1271-1277`; `buildTableau_isSome` false unconditionally (`:80-86`) | Hypothesis read (via report 04 §1.5) | **CONFIRMED** | High |
| `literature-search.sh` is degraded — but the corpus is **not** empty | `{"results": [], "degraded": true, "fallback_tier": "none"}` from the helper vs. a direct `jq` query on `~/Projects/Literature/index.json` resolving `sources/caleiro_2013/` in four chunks | Both run; the helper's failure is a tooling defect, not an absent corpus | **CONFIRMED** | High |
| The interpolant is **mandatory** in the published method, not an artefact of this engine | Caleiro–Viganò–Volpe 2013, Def. 3.5 **SV3**(ii) (`caleiro_2013/sec03_31-mosaics.md`) | Direct read of the saturation condition | **CONFIRMED** | High |
| The finite saturating object is the set of **types**, bounded `2^O(\|φ\|)` | ibid. Def. 3.2, Def. 3.4; Thm 4.11 + bound (`sec07_43-decidability-via-mosaics.md`) | Direct read | **CONFIRMED** | High |
| One cure discharges the whole downward-closed family of same-formula defects — the saturation principle of §5 | ibid. Lemma 3.10 proof (`sec04_32-…md`): *"By curing the defect `⟨v′, FA⟩`, we will also cure all the defects `⟨w, FA⟩` for `w ≺ v′`"* | Direct read | **CONFIRMED** | High |
| A tableau realization additionally needs a re-curing guard, and the source names it | ibid. §4.3 closing paragraph: *"properly avoiding the repeated curing of the same defect"* | Direct read | **CONFIRMED** | High |
| `SVDns` is `densityRule` and `SVUdsc`/`SVDdsc` are the discrete family | ibid. Def. 3.5 vs. `Tableau.lean:1261-1308` and the `priorUZ`/`priorSZ` pair | Side-by-side comparison of the conditions | **CONFIRMED** | Medium-High (structural correspondence, not a formal translation) |
| The published decidability result covers TM's shape (linear time × orthogonal S5, basic branching class) but **not** a coupled one | ibid. `sec07_43-…md`: *"does not extend to the logics `L(C,D)` for `D ≠ ()`"*; TM's `□` quantifies over `Ω` independently of `t` (`Truth.lean:131`) | Read of the caveat + the semantics | **CONFIRMED** | Medium-High |
| The escalation's premise that the FMP context "may already bound branch size" is **false** for the branches this rule touches | `timeFinset_card_le_of_not_blocked` is conditional on `findBlockedTime … = none` (`Fuel.lean:588-594`), and blocking never fires on incomparable interpolants | Hypothesis read + Finding C | **CONFIRMED** — REFUTES the escalation's premise | High |
| Reynolds' `[PRUNE]`/`[LOOP]` are discrete-only and he switches to mosaics for RTL; RTL-SAT is PSPACE-complete | arXiv:cs/9910012, AiML 2014 — titles/venues confirmed, full texts **not read here** | Relayed from the parallel sweep | **PLAUSIBLE** | Medium — independently entailed by §3.2's CONFIRMED syntactic argument |
| Burgess 1982 gets decidability via Rabin's S2S, not via an FMP | relayed | Not read here | **PLAUSIBLE** | Low-Medium |
| Reynolds is the source of the co-decomposition | in-tree comments only (`Tableau.lean:1006-1013`) | No bibliographic source located; the mosaic literature calls it *defect curing* | **UNVERIFIED** | — |
| Marx–Mikulás–Reynolds TABLEAUX 2000, Reynolds TIME'09, GHR vol. 1 FMP sections | — | Not readable in this dispatch | **UNVERIFIED** | — |
| Rank 1 compiles / the corpus stays green | — | Not attempted: read-only dispatch, no build | **UNVERIFIABLE-WITHOUT-BUILD** | — |
| The exact number of corpus rows that move under rank 1 | — | Requires the 59 s conformance run | **UNVERIFIABLE-WITHOUT-BUILD** | — |

### Contradiction Log

**Resolved — against report 04's scope, not its ruling.** Report 04 §4.1-4.2 states the ACTIVE arm's
only problem is its copy block, and that deletion is *"necessary for `RuleSound carrierBase .untlNeg`
regardless of what happens to the passive arm."* §2.2 exhibits a second, independent ACTIVE-arm
defect. Precedence: **an explicit refuting instance outranks a scope-limited assessment.** Report 04's
ruling is not contradicted — it authorized the copy deletion and said it was *necessary*, which
remains true; it did not claim it was *sufficient* for the ACTIVE arm, and this report shows it is not.
Residual risk: §2.2 is hand-checked. Resolving check not yet performed: the §7 section-D probe.

**Resolved — against the escalation's framing of "what is lost".** The dispatch brief asks whether
bounded completeness is *"sufficient for the task's actual target (decidability via FMP), given the
FMP context may already bound branch size"*. The answer found is different from the question's
premise: what bounds the relevant completeness is not branch size but the **truth-lemma gate**, which
is a stronger, already-undischarged condition (`untlNegFuture`). Precedence: **the landed proof's
binder list over the plan's prose.** Effect: the cap's cost is smaller than reports 03/04 priced it,
and the *primary* termination mechanism should nonetheless not be the cap, because a cap suppresses
branch 1 as well as branch 2 and branch 1 is the arm the gate and `BX7` both want.

**Resolved — against the handoff's `existingIntermediates` suggestion, confirming report 04 §1.4.**
`densityRule`'s live guard is the maximal-gap filter `gapTargets` (`Tableau.lean:1303-1308`), and it
works because its interpolant gets the edge `fresh < t'` and is therefore never itself maximal. Not
transferable to `untlNeg`, whose obligation is universal over future times. Precedence: **code over
prose.** Independently re-checked here; report 04's correction stands.

**Resolved — the literature question, and it went the design's way.** This was logged mid-dispatch
as `UNRESOLVED: whether the saturating-witness device of §5.2 is the one published systems use`. It
is now **resolved and CONFIRMED** against a primary source read directly from the corpus
(Caleiro–Viganò–Volpe 2013, §3.1/§3.2/§4.3): the interpolant is mandatory (SV3(ii)), the finite
object is the type set (`2^O(|φ|)`), one cure discharges a downward-closed family (Lemma 3.10), and
the paper's own closing sentence specifies the missing tableau-side guard as *"properly avoiding the
repeated curing of the same defect"*. Precedence applied: **a primary source read in full outranks a
relayed summary, and both outrank the degraded search helper's empty result.** The helper's failure
would have caused this to be recorded as an open literature gap; a direct `jq` query on the index
refuted the "no corpus" reading.

**Resolved — against report 04 §1.4's generalisation, though not against its ruling.** Report 04
concluded that maximal-target selection *"does not transfer"* to `untlNeg` because its obligation is
`∀c > a` rather than "at some maximal `c`". That is correct **about `gapTargets`' mechanism** (making
the interpolant non-maximal so it can never become a target) and it is what refuted the diff. But as
a general claim about maximal selection it is too strong: Lemma 3.10 cures at the ≺-**maximal**
carrier of a defect precisely *because* the obligation is downward-closed, so one cure settles the
whole family. Precedence: **a published proof outranks an inference from one rule's mechanism.**
Effect on the ruling: none — report 04's REFUTE of the diff stands; what changes is that the
direction it closed off has a legitimate variant, and §5 is that variant.

**Unresolved — attribution only.** `UNRESOLVED: whether the "Reynolds co-decomposition" named
throughout the tree corresponds to a specific published rule of Reynolds', or is this project's own
name for what the mosaic literature calls defect curing.` Downstream risk: **cosmetic** — a comment
naming the wrong author. The resolving check not performed: locating Marx–Mikulás–Reynolds
TABLEAUX 2000 or Reynolds TIME'09, neither of which is in the corpus.

### Recommendations modified after verification

1. The dispatch opened expecting to rank the hard cap (a) against the interpolant repair. Reading the
   truth lemma's *body* (not just its binder list) inverted the frame: **branch 2 is completeness-dead**,
   which demotes the "bounded completeness" objection to the cap from decisive to secondary, and
   simultaneously demotes the cap from primary mechanism to safety net.
2. The ACTIVE arm was expected to need only the copy deletion (report 04 §4.2's explicit finding).
   Attempting to write its soundness proof surfaced §2.2, which is a **third** independent defect and
   a **one-token** repair. This is now item 1 and should land before anything else.
3. Candidate (d) was expected to be the interesting one ("targets from a saturating set"). §3.0 turned
   it into a **negative result** — no sound existing-label-only arm exists — which is what forced the
   recommendation toward a *witness*-saturating rather than a *target*-saturating design.
4. `guardWitnessed` was arrived at by re-running report 04 §1.6's own counterexample against candidate
   guards until one killed it. It is not a variant of the interval filter; it is a **global**
   condition, and that is the whole of why it works.
5. The literature was expected to be unavailable — the search helper reported the corpus degraded and
   empty. **Querying the index directly refuted that**, and the source it surfaced
   (Caleiro–Viganò–Volpe 2013) is not merely relevant but is a decision procedure for *this
   project's exact logic shape*. The tier was raised from 3 to 1 and §5 went from own-proof to
   literature-backed. **Process note for the next dispatch: when `literature-search.sh` reports
   `degraded`, query `~/Projects/Literature/index.json` with `jq` before concluding the corpus is
   empty.**
6. The escalation asked whether bounded completeness is acceptable *"given the FMP context may
   already bound branch size"*. Checking that premise **refuted it** (`Fuel.lean:588-594` is
   conditional on blocking firing, and blocking is exactly what does not fire here), which promoted
   the hard cap from "possibly redundant" to "the only thing making the recommendation safe today".
