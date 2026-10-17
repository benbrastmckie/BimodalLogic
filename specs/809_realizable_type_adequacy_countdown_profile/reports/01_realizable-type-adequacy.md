# Research Report: Realizable-type adequacy of the countdown profile, and the two set-valued gates

- **Task**: 809 - Realizable type adequacy of the countdown profile (the expensive half the countdown-profile round scoped but did not attempt)
- **Started**: 2026-10-16T00:00:00Z
- **Completed**: 2026-10-17T00:00:00Z
- **Effort**: one research round; the adequacy obligation re-costed against in-tree machinery, one new wired probe compiled
- **Dependencies**: 806 (predecessor, the countdown-profile round); 761 (parent, `[BLOCKED]`); 805 (refuted predecessor)
- **Sources/Inputs**:
  - Library, read this session: `FormalSystem/Metalogic/Decidability/RaySummary/{AnchorLayer,Realize,Present,RunLayer,Profile,README}.lean`, `FormalSystem/PlusLanguage/{PlusTruth,Formula,Subformulas}.lean`
  - Library, the decisive finding: `FormalSystem/Metalogic/Decidability/BiLasso/{Annotation,GoodCycle,README}.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean`, `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Predicates,Fulfil,Limits/NoCertificate}.lean`, `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`
  - Probes: `specs/evidence/seam-gluing-ray-product/{closure-profile-gate-rerun,closure-indexed-periodicity,nside-modulus-gate}.lean`
  - Record: `specs/806_set_valued_cell_quotient_index/reports/01_closure-indexed-periodicity-gate.md`
  - Toolchain: `lake env lean` on Lean v4.33.0-rc1, this session
  - lean-lsp MCP: registered and reported reachable, **not consulted**. The evidence tier for every Lean claim below is either a **compiled file** (this round's probe) or a **direct read of the named source line**, never an index lookup; where a claim is neither, it is marked.
- **Artifacts**:
  - `specs/809_realizable_type_adequacy_countdown_profile/reports/01_realizable-type-adequacy.md` (this report)
  - `specs/evidence/seam-gluing-ray-product/realizable-type-adequacy-gap.lean` (the twentieth wired probe, 9 theorems, sorry-free, compiles clean, registered in `scripts/check-evidence-probes.sh`)
- **Standards**: report-format.md, artifact-formats.md, plan-compliance.md (Statement Fidelity), status-markers.md, subagent-return.md

## Executive Summary

- **The adequacy obligation does not need new mathematics, and that is this round's main finding.**
  The forward and backward fulfilment conditions, their decidability, and the two theorems that
  force the `untl`/`snce` clauses from them are **already landed in this tree**, generic over the
  object and with no model, frame or carrier-finiteness hypothesis:
  `RaySummary/Realize.lean`'s `UCoh`/`deferGraph`/`ULive`/`Disch` forward and
  `SCoh`/`bwdDeferGraph`/`SLive`/`DischBwd` backward, with `untl_iff_of_UCoh_ULive` and
  `snce_iff_of_SCoh_SLive`. The countdown profile's adequacy half is a **re-indexing of that
  bundle onto the object-closure product**, not a construction from scratch.
- **But the landed bundle is the WRONG STRENGTH for a cell datum, and the coprime-cycle fixture
  exhibits exactly why.** `ULive` is *universal*: no state begins an infinite eventuality-deferring
  chain. A cell is *existential*: a type is in the cell iff **some** history realizes it. This
  round compiles the separating witness on the fixture the countdown-profile round's gate table was
  run on: a `coh6`-coherent 3-cycle carrying `ev = ⊤ U psi2` at every position and `psi2` at none
  (`Probe809.evRay_unfulfilled`), while `psi2` remains deliverable on the same object through the
  2-cycle exit `a → d → a`. That is a **cycle with an exit under a pending eventuality** — the
  precise mechanism `PlusWitnessFamily/Limits/NoCertificate.lean` identifies as refuting the
  class-level completeness of a thread-universal fulfilment condition at L⁺
  (`not_exists_plusCertifies_pumpTarget`). Transplanting `ULive` onto the product would reject a
  presentation that is realizable.
- **The adequacy gap is now EXHIBITED, not merely scoped.** The predecessor round recorded the
  over-approximation as a property of the *definition* (`coh` imposes no fulfilment clause). A
  plan could rationally have read that as an artefact of a conservative definition that disappears
  once the relation is written properly. The twentieth probe closes that reading on compiled
  ground and puts the unfulfilled cycle inside the profile at every multiple of three
  (`prof6_ev_witness`).
- **Gate 7 (non-circularity) is not the obstruction the predecessor round feared, and gate 8
  (`stab` self-reference) is not a new gate at all.** Both have a settled in-tree resolution
  pattern, used twice already: state the self-referential bit as a **checked condition on the
  candidate datum**, not as a bottom-up computation — `BiLasso/Annotation.lean`'s
  `BoxOracleSound` (a *specification*, deliberately not a construction, which is what "breaks the
  circularity between the truth lemma and the oracle" in its own words) and
  `PlusWitnessFamily/Predicates.lean`'s (C5) `StabFaithful`
  (`⊡φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`, one of six *checked* components). Gate 8 is the
  standing `BoxStabFree` scope line of the whole anchor/run layer, now visible as a gate: both
  `Realize.lean` and the eighteenth probe buy their results at the same place, by excluding `box`
  and `stab` from the closure.
- **The one piece with no in-repo precedent is named and costed**: *generalized-Büchi
  nonemptiness per state on a finite graph* — "does **some** infinite chain from `x` discharge
  **every** eventuality it carries?". `AUFix` (`WitnessFamily/Sharing/Fulfil.lean`) is the
  *universal* `A[g U e]` operator; `Present.lean`'s `live` is plain safety-liveness;
  `GoodCycle.lean` extracts a good cycle *from a genuine history* rather than deciding existence.
  The existential dual `EUFix` is a one-quantifier edit of `AUFix` whose every lemma ports
  (nothing in `step_mono`/`iter`/`lfp` reads the quantifier), but the nested fixpoint on top of it
  is new work and is the recommended first phase.
- **A certificate presentation avoids that algorithm entirely**, and it is the shape this tree
  already uses three times (`Cons`'s eleven fields, `AnchorCons`, `PlusCertifies`'s six
  components): guess the realizable set `R ⊆ ProdState Q φ` and check decidable conditions on it,
  including bounded discharge paths *inside* `R` and the `stab`/`box` biconditionals. §6 states the
  conditions and the dovetailing argument for their adequacy.
- **No gate verdict is changed and no obligation is discharged.** Gate 3 stays CARRIED, gates 1
  and 2 stay NOT ADDRESSED with the compiled n-side qualification, gate 9 stays OPEN, gate 8 stays
  SIDESTEPPED on a `stab`-free fixture. Obligations (b), (c) and (d) are untouched.

## Context & Scope

This is round 1 of the successor record opened after the countdown-profile round discharged the
cheap half of the first standing obligation. The dispatch settles three things on compiled ground
and forbids re-deriving them: closure-indexed eventual periodicity of the countdown over the
object-closure product (the seventeenth probe); the set-valued presentation and its quotient, with
the gate table rebuilt (the predecessor's report); and the profile's survival of its round on the
coprime-cycle fixture (the eighteenth and nineteenth probes). None of those is re-attacked here.

What this round executes: item (1), adequacy, re-costed against the tree rather than against the
predecessor's prose; item (2), the two set-valued gates; and item (3)'s discipline — every carried
verdict is reported as carried.

Scope boundaries honoured and checkable by `git status`: nothing under `FormalSystem/` or `Tests/`
is touched. Two files are written — this report, and one probe under
`specs/evidence/seam-gluing-ray-product/` — plus the probe's registration in
`scripts/check-evidence-probes.sh`, which the dispatch directs. No `ladderRealized`, no
`LadderCons`, no `ladderCons_localRun`, under those names or any others; no `LadderCons` is stated
at all, hence none without the `box`/`stab` clause; no seventh tuple coordinate is proposed; no
positive factorization lemma is stated, sketched or implied.

What is NOT re-attacked, per the dispatch: the finiteness and bound on the SET of cells
(`anchorCells_finite`, `anchorCells_ncard_le`) is settled and untouched; the four refuted index
shapes are not re-derived; the tuple-widening line stays spent.

## Findings

### Codebase Patterns

#### 1. Verified starting state

Every row was checked against the tree this session, at the cited line or declaration. Re-check
cheaply; do not re-derive.

| Claim | How it was verified this session |
|---|---|
| `PlusTruthAt`'s `untl` clause is a **strict** existential: `∃ s, t < s ∧ … ∧ ∀ r, t < r → r < s → …` | `FormalSystem/PlusLanguage/PlusTruth.lean:89-91` read directly; `snce` is the mirror at `s < t` |
| So an eventuality carried forever is **not** realizable: fulfilment is a genuine obligation, not a bookkeeping convenience | same clause; there is no weak-until constructor in `PlusFormula`'s six |
| `.and φ ψ = (φ.imp ψ.neg).neg` and `.neg φ = φ.imp .bot` | `FormalSystem/PlusLanguage/Formula.lean:137,158` — load-bearing for this round's probe, because it fixes which `imp` members the closure of `chi` contains |
| `box` is **one global bit per `□ψ`**, not a per-state bit | `box_mem_tpOf_iff` (`AnchorLayer.lean`): `□ψ ∈ tpOf M φ σ z ↔ ∀ σ' z', ψ ∈ tpOf M φ σ' z'` |
| `stab` is **one bit per (`⊡ψ`, world state)**, i.e. per cell | `stab_mem_tpOf_iff` (`AnchorLayer.lean`): `⊡ψ ∈ tpOf M φ σ z ↔ ∀ σ', σ.state z = σ'.state z → ψ ∈ tpOf M φ σ' z` |
| The forward fulfilment bundle **already exists**, generic over the object | `Realize.lean:117-135`: `UCoh` (the biconditional unfolding across every step), `deferGraph lab step u e = fun x y => lab x u && !(lab x e) && step x y`, `ULive = ∀ q, live (deferGraph …) q = false`, `Disch` (the right-hand side of `LocalRun`'s `untl` field) |
| The backward bundle exists too, **proved outright rather than transported** | `Realize.lean:323-352`: `SCoh`, `bwdDeferGraph` (the same edge on the reversed `step`), `SLive`, `DischBwd` |
| Both bundles are **decidable** | `decidableUCoh`, `decidableULive`, `decidableSCoh`, `decidableSLive` (instances immediately after each definition) |
| Both bundles **force the eventuality clauses** | `untl_iff_of_UCoh_ULive` (`Realize.lean:298`), `snce_iff_of_SCoh_SLive` (`Realize.lean:515`) |
| `live` is a computable greatest fixpoint on a finite carrier, with no parameter | `Present.lean:602-605`: `liveSet G = (pruneStep G)^[Fintype.card Q] Finset.univ`, `live G q = decide (q ∈ liveSet G)`; `live_iff` (`:652`) is `live G q = true ↔ HasChain G q` |
| The whole `Realize.lean` bundle is bought under a **scope line excluding `box` and `stab`** | `PlusFormula.BoxStabFree` (`Subformulas.lean:291`, decidable at `:302`), consumed at `Realize.lean:560,854,875` via `not_box_mem_plusSubformulaClosure` / `not_stab_mem_plusSubformulaClosure` to make `Anchored`'s `box` and `stab` fields vacuous |
| A **language-agnostic** least-fixpoint operator with a stabilization bound exists | `WitnessFamily/Sharing/Fulfil.lean:142-305`, namespace `AUFix`, at an arbitrary `[DecidableEq α]` with a `Finset`-valued `succ` and two `Bool` predicates: `step`, `step_mono`, `iter`, `iter_stab`, `exists_stab`, `lfp`, `lfp_fixed`, `lfp_least`, `mem_lfp_iff`, `lfp_induction`. **It mentions no formula.** |
| `AUFix.step` is the **universal** operator | `:142`: `V.filter (fun v => ∀ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ X))` |
| Good-cycle extraction with an **explicit** length bound exists at the L layer | `BiLasso/GoodCycle.lean`: `untl_propagates_to_end`, `snce_propagates_to_start`, `cycleBound` (`(2k+1)·N`), `exists_good_fwd_cycle`, `exists_good_bwd_cycle`, `fulfilling_of_good_cycles` |
| Fulfilment is stated as a **global two-directional condition** at the L layer | `BiLasso/Annotation.lean:336` `Fulfilling`, with its own docstring: `LocalCoherent`'s temporal clauses "are satisfied by the *greatest* fixpoint … `Fulfilling` selects the *least* fixpoint by demanding a real witness" |
| The circularity resolution for a self-referential bit is **specification, not construction** | `BiLasso/Annotation.lean:356` `BoxOracleSound`, whose docstring says in as many words: "This is a *specification*, not a construction … which is what breaks the circularity between the truth lemma and the oracle" |
| The same resolution is used for `⊡` at L⁺, as a **checked** component | `PlusWitnessFamily/Predicates.lean:283` (C5) `StabFaithful`: `⊡φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u`; `PlusWitnessFamily.lean`'s header: "`PlusCertifies` carries it as one of six *checked* components rather than as a hypothesis the checker never evaluates" |
| A **thread-universal** fulfilment condition at L⁺ is refuted as complete | `PlusWitnessFamily/Limits/NoCertificate.lean:425` `not_exists_plusCertifies_pumpTarget`, bundled at `:440` as `plusCompression_fails_at_pumpTarget` |
| Its named mechanism is **a cycle with an exit under a pending eventuality** | that module's header, "The scope of the failure": "the certificate's own finiteness manufactures a thread that stays in the cycle forever, and (C2') reads that thread as an unfulfilled eventuality even though the countermodel fulfils the eventuality by leaving the cycle" |
| The repo's own prescribed repair is **time-indexed rather than thread-indexed** fulfilment | same header: "The repair is therefore structural … a certificate whose fulfilment obligation is **time-indexed** rather than thread-indexed, so that a cycle with an exit is not read as a cycle without one" |

#### 2. What was put on compiled ground this round

`specs/evidence/seam-gluing-ray-product/realizable-type-adequacy-gap.lean`, namespace `Probe809`.
Compiles under `lake env lean` with no errors and no warnings this session; `#print axioms` on all
nine named theorems reports `[propext, Classical.choice, Quot.sound]`, i.e. **no new axiom**, no
`sorryAx`, no `ofReduceBool` (`native_decide` is deliberately not used). Registered in
`scripts/check-evidence-probes.sh` with a decision-row comment block and a `WIRED` entry, and the
file is tracked by git, which that guard additionally requires.

| Declaration | What it establishes |
|---|---|
| `ev_cycle_witness` | a `coh6`-coherent 3-cycle `(a5, evTa) → (b5, evTb) → (c5, evTc) → (a5, evTa)`; landed **before** every negative statement, as a non-vacuity obligation requires |
| `ev_mem_all` | the eventuality `ev = ⊤ U psi2` is in all three types |
| `psi2_not_mem_all` | its event `psi2` is in none of them |
| `chi_not_mem_all` | the three types falsify gate 6's constraint — the compiled reason the exhibit does not collide with the eighteenth probe's `coh6_no_a_d_a`, whose hypothesis is a `chi`-CARRYING type |
| `evRay_coh` | the forward run of the cycle is a `coh6`-chain at every step |
| `evRay_carries` / `evRay_no_event` | it carries `ev` at every position and delivers `psi2` at none |
| `evRay_unfulfilled` | **the exhibit**: at every position, `ev` is in the label and there is no strictly later position whose label contains `psi2` — the exact negation of `PlusTruthAt`'s `untl` clause and of `Fulfilling` / `PlusThreadFulfilling` |
| `prof6_ev_witness` | the cycle sits in the countdown profile at every multiple of three, so the profile's own membership witnesses include chains of this kind |

How the types were found, recorded because it is cheap to re-derive and expensive to re-discover:
they are the eighteenth probe's non-vacuity types with `ev.neg` replaced by `ev`. Because
`.and`/`.neg` are `imp`-built, that single flip forces `ev.neg ∉ T`, hence `ev.neg.neg ∈ T`, hence
`psi2.neg.imp ev.neg.neg ∈ T`, hence `chi ∉ T` — and the Hintikka biconditionals then hold at every
one of the eighteen members of `plusSubformulaClosure chi`. No search was run.

What the probe deliberately does **not** claim, stated in its own header: `(a5, evTa)` is not
claimed non-realizable. `psi2` needs a pending `a` two pending steps before another pending `a`,
which on this object is the 2-cycle `a → d → a`; a `chi`-free type may enter it, so some *other*
`coh6`-chain out of `(a5, evTa)` may well discharge `ev`. What is exhibited is that local coherence
does not **force** discharge.

#### 3. The adequacy obligation, restated against the tree

The dispatch's wording is: *a coherence relation that computes REALIZABLE types rather than merely
locally coherent ones, with `untl`/`snce` fulfilment*. Against this tree that decomposes into four
separable claims, of which exactly one is new work.

1. **(Carrier.)** The carrier is finite with decidable equality. **Discharged** by the seventeenth
   probe (`ClType`, `ProdState`, `instFintypeProdState`, `instDecEqProdState`).
2. **(Local relation.)** The one-step unfolding of `untl` across a step, as a biconditional.
   **Exists twice**: as the eighteenth probe's `linkPred`, and as `Realize.lean`'s `UCoh` at the
   letter level. The two are the same condition in different notation; `UCoh` additionally has its
   decidability instance and its forcing theorem.
3. **(Fulfilment.)** The discharge of every carried eventuality along the ray. **Exists in two
   inequivalent strengths**, and choosing between them *is* the design question (§4).
4. **(The `box`/`stab` letters.)** **Exists as a settled pattern** (§5), and is the standing
   `BoxStabFree` scope line rather than a new obstruction.

Nothing here is a claim that the obligation is discharged. The point is narrower and more useful:
the obligation's residue is item 3's choice plus one missing algorithm, not a from-scratch build.

#### 4. The strength question, which is the round's substantive finding

Two conditions are in the tree, and they are not interchangeable.

**Universal (`ULive`-shaped).** *No state begins an infinite eventuality-deferring chain.*
Decidable through `live`, with the forcing theorem `untl_iff_of_UCoh_ULive` already proved. It
makes fulfilment automatic along **every** run of the presentation, which is why its forcing
theorem is cheap.

**Existential (cell-shaped).** *This product state lies on **some** bi-infinite chain discharging
every eventuality it carries.* This is what a cell is: `cellAt M φ w z` is the set of closure types
realized at `w` by the histories through `(z, w)`, and `tpOf_mem_cellAt_zero` puts a point's type
in its state's cell — an existential over histories, not a universal.

**The coprime-cycle fixture separates them, and this round compiles the separation.** `evRay` is an
infinite chain in the deferral graph of `ev` — `lab x u` is `ev ∈ T` (`evRay_carries`), `lab x e` is
`psi2 ∈ T` (`evRay_no_event`), and the `step` conjunct is `evRay_coh`. So a `ULive`-shaped
condition on the object-closure product **fails** on this fixture at `ev`, while `psi2` remains
deliverable through the 2-cycle exit. A universal condition therefore rejects a presentation whose
types are realizable.

[NOT COMPILED, and marked as such: the translation of `evRay` into `Realize.lean`'s letter-level
`sig.preds` notation is not performed in the probe, because the probe does not import the
signature machinery. The three facts the translation consumes are each compiled
(`evRay_coh`, `evRay_carries`, `evRay_no_event`); the identification of the product-level
deferral graph with `deferGraph lab step u e` at `Q := ProdState Q5 chi` is an argument.]

This is the same mechanism, on the ladder's own fixture, that `NoCertificate.lean` identifies as
refuting class-level completeness at L⁺: a cycle with an exit under a pending eventuality. That
module's verdict is worth quoting exactly because it forecloses a repair this round might otherwise
have proposed: *"The defect is not a missing bound and no bound repairs it."* So the adequacy
relation for a set-valued cell datum must be the **existential** one. Transplanting `ULive` is not
a conservative simplification; it is the wrong condition.

#### 5. Gates 7 and 8, against the settled in-tree pattern

**Gate 7 (non-circularity / non-vacuity): passed in its definability form, and the form is the
right one.** The eighteenth probe already checks both halves on the fixture — `coh6` is a
computable `Bool` relation built from `(Q5, step5, pend5, lab6, chi)` alone, naming no history, no
`WorldHistory`, no `PlusTruthAt`, no `tpOf` and no `cellAt`, checked mechanically by grep; and
`coh6_cycle_witness` exhibits a non-empty instance before every negative lemma. This round's probe
keeps both properties (its own non-vacuity witness `ev_cycle_witness` lands first, and its
declarations name no history, world, model or cell). What gate 7 does **not** yet cover is the
fulfilment refinement, because none is constructed; a refinement defined as "the types that happen
to be in the cell" would fail gate 7 outright, which is exactly what the gate is for.

**Gate 8 (`stab` self-reference): not a new gate, and it has a settled resolution.** The
predecessor round's framing is that `stab_mem_tpOf_iff` puts the cell on both sides of the datum's
own defining equation, "at definition time rather than proof time". That is correct about a
*bottom-up computation* of the datum and incorrect about the only presentation this tree has ever
used for such a bit. Twice, in two different subtrees, the resolution is the same: **state the
self-referential bit as a checked biconditional on a candidate datum**.

- `BoxOracleSound` is a specification, not a construction, and its own docstring says that is what
  breaks the circularity. The truth lemma is then proved *relative to any oracle meeting it*.
- (C5) `StabFaithful` is the `⊡` analogue, stated on labels — `⊡φ ∈ L i u ↔ ∀ j, share u i j →
  φ ∈ L j u` — and carried as one of six **checked** components of `PlusCertifies`, with
  `plusTruth_iff_mem`'s `stab` case consuming it.
- `AnchorCons` is the same move at the anchor layer, on cells, with `anchorCons_anchorCells`
  proving every model's cells satisfy it and `decidableAnchorConsFin` the decidable twin.

So the set-valued datum's `stab` clause is `⊡ψ ∈ T ↔ ∀ T' ∈ D(x), ψ ∈ T'` **as a condition the
candidate datum must satisfy**, over a finite search space, with no definitional circularity. There
is a real residual obligation, but it is a different one: the condition has to be *discharged for
every model's cells* (the `anchorCons_anchorCells` direction) and *realized by some model* (the
converse, which is the hard half everywhere in this tree).

And the honest qualification, which is the reason gate 8 should be renamed rather than attacked:
`Realize.lean` buys its entire bundle under `BoxStabFree`, which excludes `box` and `stab` from the
closure and makes `Anchored`'s corresponding fields vacuous. The eighteenth probe's
`chi_closure_untl_only` is the same exclusion on the fixture. **The library and the probe
collection sidestep gate 8 at the same place, for the same reason.** Gate 8 is therefore the
standing scope line of the anchor/run layer, now visible as a gate — not a new obstruction
specific to a set-valued presentation. A `stab`-free fixture cannot pass a `stab` gate; it can only
avoid it, and both avoid it.

#### 6. The certificate presentation, which avoids the missing algorithm

Two routes reach an existential fulfilment condition. They should be costed against each other
before either is built, and the plan should pick one.

**Route A — decide it.** Compute, for each product state, whether some infinite chain from it
discharges every eventuality it carries. This is generalized-Büchi nonemptiness per state on a
finite graph: a greatest fixpoint with an inner least fixpoint, one inner pass per eventuality in
the closure. In-repo assets: `AUFix`'s whole API ports to the existential dual `EUFix` by replacing
one `∀ w ∈ succ v` with `∃ w ∈ succ v` — `step_mono`, `iter`, `iter_stab`, `exists_stab`, `lfp`,
`lfp_fixed`, `lfp_least`, `mem_lfp_iff` and `lfp_induction` read only monotonicity in `X`, never the
quantifier. `Present.lean`'s `live`/`liveSet`/`live_iff` supply the outer safety fixpoint pattern on
a `Fintype` carrier, and `ProdState Q φ`'s `Fintype` instance is already compiled.
`GoodCycle.lean`'s `cycleBound` is the explicit length bound for the extraction direction. **What is
missing is the nesting**, and it is genuinely missing: nothing in the tree decides generalized-Büchi
nonemptiness.

**Route B — check it.** Present the datum as a *candidate* realizable set `R ⊆ ProdState Q φ`
together with decidable conditions, in the shape `Cons`'s eleven fields, `AnchorCons` and
`PlusCertifies`'s six components already use:

1. every `x ∈ R` is locally coherent (`locCoh`);
2. every `x ∈ R` has a `coh`-successor and a `coh`-predecessor in `R` (so bi-infinite chains through
   `R` exist);
3. for every `x ∈ R` and every `untl g e` in `x`'s type, a `coh`-path **inside `R`** from `x`
   reaching `e` with `g` on the open interval, of length at most `|R|`;
4. the mirror of (3) backward, for every `snce g e`;
5. the `stab` biconditional of §5, read against `R`'s own fibres;
6. the `box` bits, global by `box_mem_tpOf_iff`, read against `R`.

Conditions (1)-(4) are bounded and decidable with no new algorithm. Their adequacy is a dovetailing
argument: from any `x ∈ R`, round-robin the finitely many eventualities of the closure, discharging
each by (3)/(4) and otherwise stepping by (2); every eventuality is then discharged infinitely
often, so the constructed bi-infinite chain is fulfilling. [NOT COMPILED: the dovetailing argument
is an argument in this report, not a theorem of any file, and the length bound `|R|` in (3) is the
obvious one rather than a derived one.]

Route B's search space is `Finset (ProdState Q φ)`, of size `2^(|Q| · 2^|cl φ|)` — finite and
decidable, which is what an index question asks, and astronomical, which is what a complexity
question would ask and this line does not.

#### 7. What the countdown profile becomes, and what survives

Under either route, the datum is `Prof(k) = (prodPreStep coh_R)^[k] (E ∩ R)` where `coh_R` is `coh`
restricted to `R × R`. Three consequences, each worth stating because each is a place a plan could
go wrong:

- **Eventual periodicity survives verbatim.** The carrier is unchanged and still finite, so the
  seventeenth probe's `prodPreN_eventually_periodic` applies to `coh_R` exactly as to `coh`. This
  is the predecessor round's reason periodicity was the cheap half, and it is still the reason.
- **Every negative result through `coh` transfers to `coh_R`, and no positive result does.** `coh_R`
  is a sub-relation of `coh`, so a separation proved against the larger relation separates against
  the smaller. The eighteenth probe states this discipline for `coh6` and it continues to bind. In
  particular `prof6_separates_gate6_pair` is a negative result and transfers; nothing about gate 6
  needs re-running after the refinement.
- **The restriction does not break the chain-to-ray composition**, which is the one place the
  refinement could have failed. An `untl` obligation carried at an interior position of a
  `coh_R`-chain is, by the link biconditional, either discharged inside the chain or still carried
  at its end with the guard holding throughout — the content of `GoodCycle.lean`'s
  `untl_propagates_to_end` — and (3)/(2) then discharge it beyond the end. The mirror holds backward
  through `snce_propagates_to_start`. [NOT COMPILED: this is the composition argument, stated here so
  a plan can target it as a theorem; the two propagation lemmas it cites are compiled at the L layer
  and are not re-indexed to the product in this tree.]

#### 8. In-repo precedent read correctly, and the limit of the analogy

The predecessor round cited `RaySummary/Profile.lean` as the architectural precedent for a
set-valued datum, with the correct qualification that it summarises finite words. This round adds
the nearer precedent and its own limit.

`PlusWitnessFamily/` is the L⁺-indexed stack with all four of the pieces this obligation needs:
(C1') local coherence, (C2') `PlusThreadFulfilling`, (C3) `PlusBoxFaithful`, (C5) `StabFaithful`,
their decision procedures (`Decide.lean`, `Fulfil.lean`'s `decidablePlusCoherentShareAndFulfilling`)
and an agreement theorem `plusTruth_iff_mem` covering all seven constructor cases. **What transfers**
is the condition set's shape, the oracle-as-checked-component discipline, and the lesson that the
substrate had to carry a succession datum because the naive quantification collapsed the class to
empty (`not_snce_share_congr`, `not_untl_shift_share_congr` refute the two congruences that made
such certificates impossible — refute, not leave unproved, which is what rules out a redesign
reproducing the defect in new spelling).

**What does not transfer**, and must not be read as precedent: (C2') is thread-universal, and
`not_exists_plusCertifies_pumpTarget` shows that class is incomplete. The analogy supplies the
architecture and the warning in the same package, which is the most useful form a precedent can
take.

### External Resources

No web search and no external documentation were consulted, and none is needed: every asset this
round leans on is in-tree, and the one algorithmic gap (§6, Route A) is a textbook construction
whose in-repo substrate is already named. Mathlib was consulted only through the `AUFix`/`live`
callers; no Mathlib lemma is proposed here.

The rate-limited Mathlib search tools (`lean_leansearch`, `lean_loogle`, `lean_leanfinder`,
`lean_state_search`, `lean_hammer_premise`) were **not** used. The round's questions were all of
the form "does this tree already contain X?", which `grep` over `FormalSystem/` answers
authoritatively and a semantic search over Mathlib does not. The one question a search tool could
have answered — whether Mathlib has a generalized-Büchi nonemptiness decision procedure — is not a
blocker, because Route B avoids needing one and Route A's substrate is in-tree.

### Recommendations

Prioritised; owner is the next dispatch on this record unless stated.

1. **Pick Route B (certificate) over Route A (decide) for the first implementation phase**, and say
   so in the plan rather than leaving it to the implementation. Route B needs no new algorithm, its
   conditions are decidable field by field, and its shape is the one three separate subtrees of this
   repo already use. Route A's missing nesting is real work and should not be entered without a
   decision record.
2. **State the existential strength explicitly in whatever is built, and never `ULive`.** §4 is the
   reason. A plan that writes "fulfilment condition" without saying which of the two it means will
   be implemented as the universal one, because the universal one is the one with a landed forcing
   theorem.
3. **Rename gate 8 before attacking it.** It is the standing `BoxStabFree` scope line, not a
   presentation-specific obstruction, and both the library and the probe collection avoid it at the
   same place. The useful next step on `stab` is not a gate but a fixture: a formula whose closure
   contains a `⊡`, on which the checked biconditional of §5 has content. Until such a fixture
   exists, every `stab` verdict in this line is SIDESTEPPED, not passed.
4. **Target the composition theorem of §7 directly.** It is the one new statement the refinement
   needs, its two propagation lemmas are compiled at the L layer, and it is the place the
   restriction to `R` could silently fail.
5. **Port `AUFix` to `EUFix` as a standalone, reusable step**, whichever route is taken. It is a
   one-quantifier edit with every lemma preserved, it is useful to both routes, and doing it
   separately keeps the port reviewable against the original.
6. **Leave obligations (b), (c) and (d) named and unmet**, as the dispatch directs: the
   region-length pumping lemma for `untl`/`snce`-depth-bounded formulas; the next deadline's
   coupling through `Drift`; the `box`/`stab` letters through `box_mem_tpOf_iff` and
   `stab_mem_tpOf_iff`. Gate 9 stays OPEN and gates 1 and 2 stay NOT ADDRESSED.
7. **Do not re-enter the tuple family.** The refinement adds a *restriction of the carrier*, never a
   coordinate; the profile's threshold and period remain facts about the orbit, not index entries.

## Decisions

1. **Report the adequacy obligation as re-costed, not as discharged.** The round's finding is that
   the obligation's residue is a strength choice plus one missing algorithm, with everything else
   landed. Reporting more than that would overstate it; reporting less would leave the next
   dispatch to rediscover `Realize.lean`.
2. **Compile the gap witness rather than argue it.** The predecessor round's over-approximation
   claim read a definition. A plan is entitled to a fact about the fixture before it spends a phase
   on a repair, and the witness cost one short file.
3. **Do not construct any adequate relation this round.** It is the obligation; building it before
   the strength question of §4 is settled in a plan is how the tuple-widening loop was entered, and
   §4's answer was not available until this round.
4. **State gate 8's resolution as a pattern already used twice, and rename the gate.** Discovering
   the `BoxOracleSound`/`StabFaithful` pattern after a definition existed would have invited a
   definition bent to fit a circularity that this tree does not actually have.
5. **Mark every uncompiled step.** Three arguments in this report are marked [NOT COMPILED]: the
   letter-level translation of `evRay` (§4), the dovetailing adequacy of Route B's conditions (§6),
   and the chain-to-ray composition (§7). Each is a target, not a result.
6. **Promote the probe to the collection immediately, not next round.** The predecessor round left
   its deliverable in a task directory and had to schedule the promotion as a recommendation; the
   guard's own header documents the archive-loss failure that invites. This round's probe is in
   `specs/evidence/seam-gluing-ray-product/`, registered, and tracked.
7. **Use `decide` on concrete closure facts only, never `native_decide`.** `native_decide` would add
   `ofReduceBool` and break the no-new-axiom discipline every probe in the collection keeps.

## Risks & Mitigations

- **Risk: "the machinery already exists" is read as "the obligation is cheap".** It is not; the
  existing machinery is the *wrong strength* (§4) and the right strength is missing an algorithm
  (§6). *Mitigation*: §3 splits the obligation into four claims and marks exactly which one is new;
  Recommendation 2 names the failure mode.
- **Risk: a future dispatch transplants `ULive` because it has a landed forcing theorem.** It is the
  cheapest-looking move and it is wrong. *Mitigation*: §4 compiles the separating witness on the
  fixture; `NoCertificate.lean`'s "no bound repairs that" is quoted so the repair that would be
  tried next is foreclosed too.
- **Risk: Route B's conditions are written down and silently weakened** — in particular (3) and (4)
  dropped to "a path somewhere in the carrier" rather than "inside `R`", which is a strictly weaker
  and much easier condition that still type-checks. *Mitigation*: §6 states "inside `R`" in the
  condition text; a plan carrying a `## Lean Challenge Statements` section should pin it.
- **Risk: the probe's exhibit is read as a refutation of the countdown profile.** It is not; it
  refutes a reading of the predecessor round's over-approximation note. *Mitigation*: the probe's
  header says so in its first paragraph and again in "What this does NOT say"; `chi_not_mem_all` is
  the compiled reason it does not collide with `coh6_no_a_d_a`.
- **Risk: gate 8 is marked passed because the pattern that resolves it was found.** The pattern
  resolves the *definitional* circularity only; the two directions of the resulting biconditional
  are the standing hard halves everywhere in this tree, and no fixture in this line has a `⊡` in its
  closure. *Mitigation*: §5's final paragraph and Recommendation 3.
- **Risk: `(a5, evTa)` is cited as a non-realizable type.** It is not claimed to be, and probably is
  realizable through the 2-cycle. *Mitigation*: stated in the probe header, in §2 and in §4.
- **Risk: a seventh mechanism exists that none of this exercises.** The standing lesson binds
  verbatim: a gate probing one coordinate certifies one coordinate only. *Mitigation*: every carried
  verdict in this report is marked carried, and the probe's header restates the lesson.

## Tactic Survey Results

Surveyed against this round's probe. All results are from this session's compiles.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `coh6` coherence of each of the three cycle edges | `decide` | success | the `mkT`-as-`filter` presentation; `decide` is applied to closure-membership and object-graph facts only, never to a goal quantifying over `ClType chi` |
| `ev ∈ evTa.1`, `psi2 ∉ evTa.1`, `chi ∉ evTa.1` (and the `b`/`c` analogues) | `decide` | success | same |
| `evRay_coh` / `evRay_carries` / `evRay_no_event` — case analysis on `k % 3` | `omega` for the three-way split and for each `(k+1) % 3` value, then `rw [show evRay k = … from by simp [evRay, h]]` | success | `omega` decides `k % 3 = 0 → (k+1) % 3 = 1` and its siblings directly; the `show … from by simp` form avoids fighting `if`-reduction under a binder |
| `prof6_ev_witness` — profile membership at every multiple of three | induction on `m`, `rw [show 3*(m+1) = 3*m+1+1+1 by ring]`, three `mem_prof6_succ` applications | success | mirrors the eighteenth probe's `prof6_fibre_a_witness` exactly; the base case is `simp [Prof6, Ea]` |
| the whole file | `lake env lean` | success, first attempt, no errors and no warnings | axioms `[propext, Classical.choice, Quot.sound]` on all nine theorems |
| any goal | `native_decide` | not attempted, deliberately | would add `ofReduceBool`; see Decision 7 |

`lean_multi_attempt` and the rate-limited search tools were not used. Every goal here is either a
`decide` on a concrete finite fixture, a `% 3` case split `omega` settles, or a port of an induction
that already exists in the collection; the round's one genuine search question was "does this tree
already contain a fulfilment condition?", which `grep` answered.

## Context Extension Recommendations

- **Topic**: the parameter-origin rule and gate table for a ladder cell index
  (`context/project/lean4/domain/ladder-counter-observables.md`, in the source store under
  `.claude-extensions.json`'s `source_dir`).
- **Gap**: the predecessor round already recommended adding a "gates specific to a set-valued
  presentation" section for non-circularity and `stab` self-reference. This round narrows that
  recommendation and adds a second one. The narrowing: the `stab` row should record that the gate is
  the standing `BoxStabFree` scope line of the anchor/run layer rather than a presentation-specific
  obstruction, and that the resolution pattern (`BoxOracleSound`, `StabFaithful`, `AnchorCons`) is
  oracle-as-checked-condition. The addition: there is no note anywhere in the context tree recording
  the **universal-versus-existential fulfilment distinction**, which is the single most expensive
  thing to rediscover in this line and the thing a plan is most likely to get wrong by default.
- **Recommendation**: add a short section "fulfilment: two strengths, and which one a cell needs",
  carrying the `ULive` / cell contrast, the `not_exists_plusCertifies_pumpTarget` warning with its
  "no bound repairs that" verdict, and the pointer to `AUFix` as the reusable substrate with its
  existential dual noted as a one-quantifier edit. Must be edited in the source store, not in the
  deployed `.claude/` mirror (`source-store-deploy-boundary.md`); it needs its own commit outside
  this repository and cannot ride this task's scoped commit.
- **Separately**: the deploy-freshness block on this dispatch reports the deployed `.claude/` tree
  STALE for the `core`, `lean` and `typst` extensions. Nothing in this round depended on a
  documented command from those extensions, so it was not a blocker; the remedy is
  `timeout 540 bash .claude/scripts/deploy-headless.sh` and is an operator action, not this task's.

## Appendix

**Probe.** `specs/evidence/seam-gluing-ray-product/realizable-type-adequacy-gap.lean`, namespace
`Probe809`, 9 theorems. Compile command, as in its header:
`lake env lean specs/evidence/seam-gluing-ray-product/realizable-type-adequacy-gap.lean`.
Clean run this session: no errors, no warnings. `#print axioms` on all nine:
`[propext, Classical.choice, Quot.sound]`.

**Registration.** `scripts/check-evidence-probes.sh` gains one boxed decision-row comment block
above the `WIRED` array and one entry inside it,
`"seam-gluing-ray-product/realizable-type-adequacy-gap"`, following the convention of the three
probes that precede it. The file is tracked by git, which the guard additionally requires
(`git ls-files --error-unmatch`). `bash -n` on the edited script passes.

**Declarations leaned on and not touched.** `UCoh`, `deferGraph`, `ULive`, `Disch`,
`untl_iff_of_UCoh_ULive`, `SCoh`, `bwdDeferGraph`, `SLive`, `DischBwd`, `snce_iff_of_SCoh_SLive`,
`Cons`, `cons_localRun`, `BoxStabFree`, `not_box_mem_plusSubformulaClosure`,
`not_stab_mem_plusSubformulaClosure`, `live`, `liveSet`, `live_iff`, `AUFix.{step,step_mono,iter,
iter_stab,exists_stab,lfp,lfp_fixed,lfp_least,mem_lfp_iff,lfp_induction}`, `LocalCoherent`,
`Fulfilling`, `BoxOracleSound`, `untl_propagates_to_end`, `snce_propagates_to_start`, `cycleBound`,
`exists_good_fwd_cycle`, `exists_good_bwd_cycle`, `fulfilling_of_good_cycles`,
`PlusAtomCoherent`, `PlusLocalCoherentShare`, `PlusThreadFulfilling`, `PlusBoxFaithful`,
`PlusTarget`, `StabFaithful`, `plusTruth_iff_mem`, `plusRefutes_of_certifies`,
`not_exists_plusCertifies_pumpTarget`, `plusCompression_fails_at_pumpTarget`,
`not_snce_share_congr`, `not_untl_shift_share_congr`, `box_mem_tpOf_iff`, `stab_mem_tpOf_iff`,
`tpOf_mem_cellAt_zero`, `cellAt_eq_cellAt`, `anchorCells_finite`, `anchorCells_ncard_le`,
`AnchorCons`, `anchorCons_anchorCells`, `decidableAnchorConsFin`, `Rlad`, `Count`, `Drift`,
`ladderFrameAdm_isRegular`, `ladderModel`, `plusSubformulaClosure`, `Profile`, `card_profile`,
`kTypeOf_eq_of_profile_eq`.

**Predecessor records cited and not re-derived.** `closure-indexed-periodicity.lean` (the carrier
and `prodPreN_eventually_periodic`), `closure-profile-gate-rerun.lean` (`coh6`, `Prof6`, the gate
table, `coh6_no_a_d_a`, `chi_closure_untl_only`, `prof6_separates_gate6_pair`,
`prof6_fibre_a_witness`), `nside-modulus-gate.lean` (gate 9, `nside_collides`,
`gate1_gap_separates`), `ladder-joint-index-refutation.lean` (`psi2`, `chi`, `nextPow`, the
coprime-cycle object, gates 1-6), and the predecessor round's report.

**Carried figures.** Every gate verdict reproduced in this report is CARRIED from the eighteenth
and nineteenth probes' headers, read at their cited paths this session and not re-established by
re-running their theorems [CARRIED-UNVERIFIED:
`specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean`, header sections "Gate 1"
through "Gate 9"; `specs/evidence/seam-gluing-ray-product/nside-modulus-gate.lean`, header section
"What is settled"]. The `(2k+1)·N` figure for `cycleBound` and the claim that the
`PlusWitnessFamily` class is non-empty and certifies both stability targets are likewise read, not
re-run [CARRIED-UNVERIFIED: `BiLasso/GoodCycle.lean` header, "The derived bound";
`FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` header, "A tense operator under a `⊡`"].
Every figure about this round's own probe was measured this session.
