# Research Report: Task #865 — the TM⁺ + LC candidate system and the Reynolds automaton obstruction

**Task**: 865 - tm_plus_lc_axiomatization_and_automaton_obstruction
**Started**: 2026-11-05T07:44:00Z
**Completed**: 2026-11-05T08:05:00Z
**Effort**: one research dispatch (orchestrated, seq 1)
**Dependencies**: 864 (landed `lcN` and the ω-chain kernel; `[COMPLETED]`), 866 (the MSO/open-modal verdict; `[COMPLETED]`)
**Sources/Inputs**:
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`, read in full (sections 1.1-1.4, 2.1-2.3, 3.1-3.4, 4, 5, 6, appendix, including the derived amendment to section 1.3)
- `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`, read in full
- `specs/864_land_lc_schema_limit_closure_soundness/summaries/01_lc-schema-limit-closure-soundness-summary.md`
- Codebase, read this session: `FormalSystem/Metalogic/NamingRules.lean` (module docstring and `clock_irr_sound`/`irr_sound` statements), `FormalSystem/Semantics/HistoryMorphism.lean` (`TwoWayBounded`, `exists_preimage_step_neg`, the discrete-time lift narrative), `FormalSystem/OpenLanguage/OpenTruth.lean` (`stab_iff_ofut_opast`, `stab_iff_opast_ofut`, `ofut_opast_to_stab`), `FormalSystem/OpenLanguage/OpenClasses.lean`, `FormalSystem/PlusLanguage/PlusPasting.lean` (`AgreeFrom`/`AgreeUpTo`, `paste`, `paste_agreeFrom`, `paste_agreeUpTo`, `truth_congr_agreeFrom`, `truth_congr_agreeUpTo`, `paste_valid`, `paste_valid'`), `FormalSystem/PlusLanguage/Formula.lean` (`IsPureFuture`, `IsPurePast`), `FormalSystem/PlusLanguage/PlusLCSchema.lean`, `FormalSystem/PlusLanguage/PlusOmegaChain.lean`, `FormalSystem/PlusLanguage/PlusReversal.lean` (`plusValidIn_reflectTime`), `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` (`SeparationOver`, `SepClauses`, `sepForm`), `FormalSystem/Semantics/TaskFrame.lean` and `FormalSystem/Semantics/FrameProperty.lean` (the Saturation route inventory), `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean`, `docs/theorem-index.md`, `specs/ROADMAP.md`
- No new literature acquired. Reynolds 2001/2002/2003 are used only as already summarised in report 03; nothing below adds a literature claim of its own.
**Artifacts**: - `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md` (this report)
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal
**Domains**: logic (primary: the candidate axiom system, the naming rules, the completeness engine), math (secondary: the carrier-construction impossibility and the Saturation obligation, both order/graph-theoretic)

## Status vocabulary

*Compiled* — a theorem of this repository's library, read this session. *Probe* — compiled in
`specs/evidence/`, not in the library. *Derived* — a paper derivation performed this session.
*Paper* — a paper-level claim inherited from report 03 or 866 and not re-derived. *Recalled* — a
literature fact with no held source. No claim below is a completeness claim, and nothing here is
verified in Lean beyond what is labelled *compiled*.

## Executive Summary

- **The one-sided/two-sided mismatch is real but is not the binding obstruction, and it is
  cheaper to clear than report 03 records.** Anchoring is supplied by the clock rule, which is
  landed at **every** frame class (`clock_irr_sound` takes an arbitrary `fc`, compiled); the cut
  it names is `⊡`-rigid, so it is the same cut for every history of a cluster. Backward limit
  closure is one corollary of `plusValidIn_reflectTime` applied to `lcN_plusValidZTime`, not a new
  proof. And the structural fact that makes two *one-sided* automata sufficient is already
  compiled: `stab_iff_ofut_opast` / `stab_iff_opast_ofut` (`⊡φ ↔ ▷◁φ ↔ ◁▷φ`).
- **Verdict on the research question: a doubled (two one-sided) automaton is sufficient in shape,
  and no genuinely bi-infinite ℤ-automaton is needed — conditional on separation at ZTime.** The
  stability cluster's set of (past-type, future-type) pairs is a **full product**
  (derived, from compiled `paste` plus `truth_congr_agreeUpTo`/`truth_congr_agreeFrom`), so under
  `SeparationOver TaskFrame.IsZTime` a point's hue is a function of that pair, a colour is the
  product of its admissible past-types and future-types, and a bad emergent history is bad in
  exactly **one** direction. The acceptance condition therefore factorizes at the named cut.
  `SeparationOver TaskFrame.IsZTime` is an explicit unformalized hypothesis in this tree and its
  task (`867`) is `[NOT STARTED]`; it is the gate on this whole architecture.
- **The binding obstruction is the one `NamingRules.lean` already records — AA's carrier — and it
  is intrinsic, not an artefact of the chosen construction.** Derived here: a surjective
  `TwoWayBounded` preimage in which every state has at most one one-step predecessor forces the
  **base** frame to be past-deterministic (two lines from the compiled
  `exists_preimage_step_neg`). So no two-way-bounded preimage of a past-branching frame is an
  in-tree; the path record must be carried as **state data**, and the two-layer carrier shape
  `coneR` uses — a verbatim layer supplying predecessor lifting, a path-recorded layer supplying
  the recursion — is forced. Doubling does not touch this and adds the mirror obligation.
- **A route to the Saturation obligation that `NamingRules.lean` does not consider: split by
  layer.** On the verbatim layer, fibres restrict to base fibres and base Saturation applies; on
  the path-recorded layer, directed paths are unique and report 03 section 1.2's oriented-forest
  argument applies. The **one missing ingredient is section 1.2's oriented-forest Saturation
  lemma, which is uncompiled** — and that same lemma is the prerequisite of the MSO route's cover
  step. One Lean task unblocks both fronts.
- **The ZTime axiomatizability reading is CORRECTED, not confirmed.** Report 03 section 1.3's
  "decidable, hence recursively axiomatizable, leaving only a natural system open" is **not
  available**: 866 located a live gap (G1) in step 1 of that very argument, and section 1.3 is a
  paper sketch resting additionally on a recalled theorem. So the ZTime question is still about
  **existence**, not only naturalness. The landed `decidableValidZTime` does not supply it either
  — it is at base `Formula`, which has no `⊡`.
- **Two defects in the landed record of the candidate system.** `PlusLCSchema.lean`'s docstring
  says "`LCU` is the `n = 1` instance of `lcN`"; it is not — report 03's `LCU` is the until-form
  with two parameters and the `untl` connective, while `lcN` at `n = 1` is the F-form with one
  parameter. And the landed `omega_chain` dropped the source probe's segment-property parameter
  `P`, which is exactly the hook report 03 section 2.3 names as `LCU`'s compiled semantic core. The
  candidate system's until-form ingredient is therefore neither landed nor correctly recorded.
- **No completeness claim is made at any class. No library change is proposed by this report**;
  four follow-on tasks are proposed in Recommendations.

## Context & Scope

The dispatch asked three things: (i) whether the located obstruction to transposing Reynolds'
construction can be cleared, with a precisely located verdict or a refutation as an acceptable
outcome; (ii) whether report 03 section 1.3's reading of ZTime axiomatizability is right, since it
decides whether the ZTime question is about existence or only naturalness; (iii) a report, with no
library change and no completeness claim.

Constraints honoured: nothing under `FormalSystem/` or `Tests/` was touched; no `lake build` was
run; no completeness or decidability claim is stated; the finite model property is **not** assumed
(report 03 denies it and 866 gives direct evidence that `▷` reads exactly what subtree-type
folding discards); every claim carries an evidence tier.

Scope deliberately **not** entered: Base, Dense and RTime completeness (open with the obstruction
already located in report 03 section 1.4, untouched here); acquisition of Reynolds 2005, Zanardo
1991 or Di Maio–Zanardo 1998 (report 03's recommendation 3 asks for them; this dispatch had no
literature budget and makes no claim that needs them); and the ladder/RaySummary decidability
front, which is a different engine with a different refutation record.

## Domain Analysis

**Logic (primary).** The question is about a proof system (which rules and schemata), about the
shape of a completeness construction (hues, colours, bans, an automaton), and about a definability
hypothesis (separation). The decisive logical facts are the `⊡ = ▷◁` factorization and the
pasting axiom.

**Math (secondary; order and graph theory).** Two of the three load-bearing results are not
logical at all. The impossibility result in finding 3 is a two-line argument about surjections with
a predecessor-lifting property. The Saturation route in finding 4 is an argument about uniqueness
of directed paths in an oriented forest and about how fibres of a two-layer carrier restrict to
each layer. Both would sit in `Semantics/`, not in `Metalogic/`.

**No physics content.** Dynamical-systems vocabulary (orbits, limit sets) would describe the
ω-chain's limit histories, but the repository's own `omega_limit` is a splice-limit construction
over an order, not a flow, and nothing is gained by importing the vocabulary.

## Findings

### 1. The candidate system's ingredient inventory, as it actually stands today

Report 03 proposes, at ZTime: **TM⁺ + `LC_n` + `LCU` + the clock rule + the transposed
Auxiliary-Atoms rule (and its mirror)**. Audited against the library this session:

| Ingredient | Status | Evidence |
|---|---|---|
| `LC_n`, validity at ZTime | **landed** | `lcN_plusValidZTime` (compiled), for every `n ≥ 1`, arbitrary parameters |
| `LC_n`, validity at Base | open and unclaimed | `PlusLCSchema.lean` docstring says so explicitly; report 03 section 2.2's Zorn argument is paper |
| mirror `LC_n` (backward limit closure) | **one corollary away** | `plusValidIn_reflectTime` is compiled at an arbitrary `FrameClass`; applied to `lcN_plusValidZTime` it gives `(lcN n α).reflectTime` at ZTime. Derived; not declared anywhere |
| `LCU` (the until-form) | **not landed, and misrecorded** | see finding 2 |
| clock rule | **landed, at every class** | `clock_irr_sound (fc : FrameClass) ...` (compiled) |
| plain irreflexivity rule | **landed, at every class** | `irr_sound` (compiled), a corollary of the above |
| AA⊡ forward | **not landed; obstruction recorded** | `NamingRules.lean` module docstring; see findings 3-4 |
| AA⊡ backward (mirror) | not landed | the mirror of the above, with the mirror obstruction |
| the pasting axiom PS | **landed as an axiom** | `paste_valid`, `paste_valid'` (compiled), with `IsPureFuture`/`IsPurePast` side conditions |
| `⊡φ ↔ ▷◁φ ↔ ◁▷φ` | **landed** | `stab_iff_ofut_opast`, `stab_iff_opast_ofut` (compiled, `[F.IsRegular]` only) |

Two things in this table were not expected from report 03 and change the cost estimate for the
doubled engine downward: the clock rule is landed at **every** frame class rather than at ZTime,
and the backward half of the limit-closure ingredient costs a corollary rather than a proof,
because `ℤ` is reflection-symmetric and the reflection transport is already compiled at an
arbitrary frame class.

### 2. `LCU` is misrecorded, and its compiled core left the library

Report 03 section 2.3 defines

```
LCU := ⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))
```

— **two** parameters, and the `untl` connective in both antecedent and consequent. The landed
`lcN` at `n = 1` is

```
lcN 1 α := ⊡G≤(⟐α₀ → ⟐F⟐α₀) → ⟐G≤(⟐α₀ → F⟐α₀)
```

— **one** parameter, `someFuture` only, no `untl`. `PlusLCSchema.lean`'s docstring nonetheless
states "**`LCU` is the `n = 1` instance of `lcN`** ... and is not given a declaration of its own
here" (read this session). These are different formulas, and the identification is wrong.

This is not only a naming slip. Report 03 section 2.3 says `LCU`'s semantic core is
`omega_chain` instantiated with the **segment property** `P k η s s' := "⟐β throughout (s, s']"`,
and the source probe carries that parameter with its own stability hypothesis
(`specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` lines 659-684: `P : ℕ → (ℤ → W)
→ ℤ → ℤ → Prop` and `hP`). The landed `omega_chain` **has no `P`** — the port recorded it as "the
probe's unused segment-property parameter" and dropped it. It is unused by `lcN`; it is exactly
what `LCU` needs. So the until-form's core is in `specs/evidence/` and not in the library, and a
reader of `PlusLCSchema.lean` is told the ingredient is present when it is not.

Why this matters for the engine rather than only for the ledger: L⁺ has both `untl` and `snce` as
primitives (seven constructors), and a Reynolds-style construction must fulfil until-commitments
*and* since-commitments. The F-form schema does not discharge an until-commitment's guard. A
doubled engine over L⁺ needs the until-form **and** its since-mirror; today it has neither.

### 3. The AA carrier obstruction is intrinsic (derived; the key negative result)

`NamingRules.lean` records that AA needs "a two-way-bounded-morphic preimage whose forward cone is
a **tree**", that `coneR` (the forward-cone unravelling: one verbatim copy plus one copy of each
state per path by which it is reached) supplies it, and that `FrameOver.ofReflectiveRegular`'s
*Saturation* obligation at that carrier is discharged by none of the available routes. It leaves
open whether a better carrier would avoid the obligation. **It would not.**

**Claim (derived).** Let `D` be a temporal order, `F' F : FrameOver D` regular, and
`f : F'.WorldState → F.WorldState` **surjective** with `TwoWayBounded f`. Suppose every state of
`F'` has at most one `x`-predecessor for some fixed `x`. Then every state of `F` has at most one
`x`-predecessor.

*Proof.* Let `v : F.WorldState` and let `u₁, u₂` be `x`-predecessors of `v`. Pick `a` with
`f a = v`. The compiled `TwoWayBounded.exists_preimage_step_neg` gives `c₁, c₂` with
`F'.TaskRel cᵢ x a` and `f cᵢ = uᵢ`. By hypothesis `c₁ = c₂`, so `u₁ = f c₁ = f c₂ = u₂`. ∎

Two lines, and it uses nothing but a compiled lemma — which exists because in a task frame `step`
quantifies over **all** durations, negative ones included, so predecessor lifting is not an extra
field but `step` at `-x` read through `reflection`.

**Consequence.** Tree-ness in the graph-theoretic sense (unique parent) and the predecessor
lifting that `⊡`-invariance needs are **jointly available only over past-deterministic base
frames**. Branching is the whole point of the nondeterministic setting, so the two cannot be had
together. It follows that:

1. AA's recursion cannot be carried by the preimage's edge structure. It must be carried by
   **state data** — the path record — which is precisely what `coneR` does.
2. The two-layer shape of `coneR` is **forced**, not a convenience: the verbatim layer exists to
   supply predecessor lifting (`inl u → inr (v, h)` whenever `u → v`), and the path-recorded layer
   exists to supply the recursion. Any construction meeting both requirements has this shape.
3. The *Saturation* obligation attaches to the stratified carrier and cannot be dodged by choosing
   a better preimage. It is the real obstruction.
4. **The mirror argument applies to the mirror rule.** The backward AA needs unique *successors*
   from the anchor, and `step` at `+x` with surjectivity forces the base to be future-deterministic
   by the same two lines. So a "bowtie" carrier (in-tree below the anchor spine, out-tree above) is
   equally unavailable graph-theoretically, and the doubled construction must stratify in **both**
   directions.

**This relocates the difficulty.** The dispatch's framing — "that mismatch is the whole
difficulty" — is not right. The one-sidedness mismatch is a question about *anchoring and
acceptance*, and finding 5 answers it affirmatively. The carrier obstruction is a question about
*the preimage*, it is present already in the one-sided forward case, and doubling neither helps
nor hurts it beyond adding the mirror copy.

### 4. A route to the Saturation obligation, by splitting on the layer (derived; paper)

`NamingRules.lean` names three routes and finds none applicable. The inventory is in fact larger —
`saturation_of_finite`, `saturation_of_subsingleton`, `saturation_of_permissive`,
`saturation_of_eq`, `saturation_of_fib_subsingleton`, `saturation_of_fib_finite` in
`Semantics/TaskFrame.lean` and `saturation_of_deterministic` in `Semantics/FrameProperty.lean` —
but none of the three not considered helps either: the path-recorded layer's fibres are neither
subsingletons nor finite, and the relation is neither permissive nor an equality. The correct
reading of the record is its own last sentence: *discharging Saturation for a path-recording
relation directly is left open*. Here is a route.

The carrier is `W ⊕ (W × List W)` with: `inl` a verbatim copy; `inl u → inr (v, h)` whenever
`u → v`; `inr (u, h) → inr (v, h')` iff `u → v` and `h' = u :: h`; and **nothing leaves `inr`**.
Split a directed family `S` of nonempty fibres and segments:

- **All members anchored in `inl`.** Because nothing leaves `inr`, a directed path from an `inl`
  state that stays in `inl` is a base path, so `Fib(inl a, x) ∩ inl = inl(Fib_base(a, x))` and the
  same for segments. The family's restriction to `inl` is a directed family of base fibres and
  segments, so **base Saturation** gives a point of `⋂ S ∩ inl`.
- **Some member anchored in `inr`.** Within `inr` each state has a unique `inr`-predecessor (`h'`
  determines it), so directed paths inside `inr` are unique and the layer is an **oriented
  forest**. Report 03 section 1.2's five-step argument then applies verbatim: segments are
  subsingletons, members of a directed family have a common sign, and a duration-minimal
  representative is contained in every member. Because nothing leaves `inr`, every member meeting
  the `inr`-anchored one is contained in `inr`, so the argument is not disturbed by the other
  layer.
- **Mixed families.** Directedness supplies a member inside every pairwise intersection; if any
  such member is `inr`-anchored the second case applies, and otherwise the first does.

**The single missing ingredient is report 03 section 1.2's oriented-forest Saturation lemma**,
which is *paper* and was flagged in report 03's own risk list as possibly gapped. Everything else
in the split is bookkeeping about a two-layer carrier. That lemma is **also** the prerequisite of
the cover step that the MSO route (report 03 section 1.2, used by 866 findings 3-4) rests on. One
Lean task — oriented-forest Saturation, stated against the literal `Saturation` definition —
unblocks the AA carrier and the MSO cover at once. This is the highest-value single item this
report found.

Honest statement of residual risk: the split above is a *strategy*, derived at paper level this
session, not a proof. The mixed-family case is the one I would expect to cost real work, because
"directedness supplies a member inside every pairwise intersection" has to be applied to the
literal `DirectedFamily` predicate, and segments are intersections of two fibres whose anchors may
sit in different layers.

### 5. The doubled automaton is sufficient in shape (derived, on compiled ground; conditional)

Two one-sided automata anchored at a named cut suffice; no bi-infinite ℤ-automaton is required.
Three steps.

**(a) The cut is nameable and is `⊡`-rigid (compiled).** `clock_irr_sound` licenses assuming a
fresh atom `q` holding at exactly one time of every history, with that time rigid under `⊡`, at an
**arbitrary** frame class. So "the anchor" is a definable, cluster-uniform notion. This is the
device report 03 section 4 said would be needed, and it is landed, which section 4 could not
assume.

**(b) The cluster's type set is a full product (derived, from compiled lemmas).** Fix a model `M`,
a history `τ`, a time `t`, and a finite closure `Cl(φ)`. For `σ ∈ stabClass τ t` write
`pt(σ) := {ψ ∈ Cl(φ) : PastDet F ψ, PlusTruthAt M σ t ψ}` and
`ft(σ) := {ψ ∈ Cl(φ) : FutDet F ψ, PlusTruthAt M σ t ψ}` — the **semantic** determinacy
predicates, which is the shape `SepClauses` uses and which `pastDet_of_isPurePast` /
`futDet_of_isPureFuture` supply from syntactic purity. Then

```
{ (pt σ, ft σ) : σ ∈ stabClass τ t }  =  { pt σ : σ ∈ stabClass τ t } × { ft σ : σ ∈ stabClass τ t }.
```

*Proof.* `⊆` is trivial. For `⊇`, take `σ₁, σ₂ ∈ stabClass τ t` and form `paste σ₁ σ₂ t`. It lies
in `stabClass τ t`, `paste_agreeUpTo` with the definition of `PastDet` gives
`pt(paste) = pt(σ₁)`, and `paste_agreeFrom` with the definition of `FutDet` gives
`ft(paste) = ft(σ₂)`. ∎ Every lemma used is compiled; `[F.IsRegular]` is the only frame
hypothesis, and it enters only through `paste`. The operator-level form of the same fact is
the compiled `stab_iff_ofut_opast` / `stab_iff_opast_ofut`, and the object-language form is the
pasting axiom `paste_valid`.

**(c) Hence the acceptance condition factorizes — conditional on separation.** Assume
`SeparationOver TaskFrame.IsZTime`: every L⁺ formula is equivalent on regular ZTime frames to a
separated CNF `⋀ᵢ (αᵢ ∨ βᵢ)` with `αᵢ` past-determined and `βᵢ` future-determined
(`SeparationOver`, `SepClauses`, `sepForm`). The separated shape is exactly the "`⊡`/`□` leaves"
shape report 03 section 4 asked for: the syntactic predicates `IsPurePast`/`IsPureFuture` treat
`box` and `stab` as **leaves for any argument**, and `SepClauses` asks only for the weaker
semantic `PastDet`/`FutDet`, so the clause parameters may be `⊡`/`□`-headed and need not be
syntactically pure at all (`pastDet_of_isPurePast`'s own docstring records that the converse
fails, which is why the semantic predicate is the one used). Then:

1. A point's hue is a function of `(pt, ft)` together with the `⊡`/`□`-leaf values, and the latter
   are **constant on the cluster** (they depend on the state at `t` alone).
2. By (b), the colour at a state is the **full product** of its admissible past-types and
   admissible future-types. There is no correlation to maintain between the two halves.
3. Therefore a walk realizes an admissible hue **iff** its past realizes an admissible past-type
   and its future realizes an admissible future-type, and the two checks are independent. A bad
   emergent history is bad in exactly one direction.
4. So the bi-infinite acceptance condition splits at the cut into a backward one-sided condition
   and a forward one-sided condition. Two one-sided automata — the forward AA⊡ run above the clock
   zero and its mirror below — label every state of the clock product exactly once, with the
   matching condition at the cut being a single shared initial state. The ban fixpoint lives on
   **pairs** (backward state, forward state) at the cut, which is a product of finite state sets,
   not a new kind of fixpoint.

**The gate.** `SeparationOver TaskFrame.IsZTime` is an explicit named hypothesis standing for GHR
Theorem 10.2.9 and is **not formalized in this tree** (the module says so); its task, 867, is
`[NOT STARTED]`. Without it, step (c) has no CNF to split and the factorization in (b) does not by
itself determine the hue — (b) is about types of pure formulas, and separation is what reduces an
arbitrary formula to those. **Separation is the gate on the doubled architecture, and this is the
first consumer of 867 that is not an expressiveness result.**

**What this does not do.** It does not clear finding 3's carrier obstruction, which is upstream of
every automaton question; it does not supply the until-form ingredient of finding 2; and it says
nothing at Base, Dense or RTime, where separation fails or is unavailable (`SeparationOver` is
false over dense flows, as its own docstring records).

### 6. The ZTime axiomatizability reading: corrected

The dispatch asked whether report 03 section 1.3's reading holds, "since it determines whether this
task's question at ZTime is about existence or only about naturalness". **It does not hold as
stated, and the question at ZTime is still about existence.** Three independent reasons:

1. **G1 is live inside the argument.** 866 finding 6 locates a gap in step 1 itself: the
   equivalence between truth in the ambient digraph and truth in the induced countable
   sub-digraph must hold at *every* walk of the sub-digraph, including walks never in the closed
   witness set; but the sub-digraph depends on the witness set and the witnesses needed depend on
   the sub-digraph's walks, and the fixpoint is not obviously reached. 866 calls this the weakest
   link in section 1.3 and says any attempt at rigour starts there. I read the amended section 1.3
   this session and agree: the amendment notes that step 1's stated justification ("state-local
   truth is shift-invariant, so one witness per state suffices") "was never actually needed for
   `⊡` either", which means step 1 currently has **no** stated justification that survives, only a
   countability conclusion that 866 argues survives the loss of the economy.
2. **Section 1.3 is a paper argument resting on a recalled theorem.** Rabin's theorem is recalled,
   not held; report 03 labels the section "paper, Medium-High" on its own account. G2 (forest
   versus tree) is repairable by a standard new-root coding but is not carried out.
3. **The landed decidability is a different result.** `Compression.decidableValidZTime` and
   `ZTimeProvability.decidableDerivableZTime` are at base `Formula`, whose constructors do not
   include `stab`. Neither extends to L⁺, so neither supplies a recursive axiomatization of the
   L⁺ ZTime validities.

`docs/theorem-index.md` states the position correctly today and should not be changed by this
report: TM⁺ is incomplete at Base (`plus_incomplete_base`, compiled) and "completeness of any
recursive extension of TM⁺ is open at every frame class". The amendment that is owed is to report
03 section 1.3's *consequence* sentence — "the open question is only a *natural* system" — which
866's R3 already proposes and which this finding independently confirms is the sentence at fault.

### Cross-Domain Synthesis

The three findings compose into one picture, and the composition is what makes the verdict
precise rather than a list of difficulties.

The **logical** content of the setting is that `⊡` factors (`⊡ = ▷◁ = ◁▷`, compiled) because the
**order-theoretic** content is that histories through a state paste freely at that state. Both are
one fact seen twice. That fact is benign for the automaton question — it is exactly why two
one-sided automata suffice and a bi-infinite automaton is unnecessary — and it is **hostile** for
the carrier question, because free pasting at a state is past-branching *and* future-branching,
and that is the hypothesis under which finding 3's two-line argument forbids a tree-shaped
two-way-bounded preimage.

So the setting's defining structural feature cuts both ways, and it cuts in the direction the
dispatch did not expect: the thing that makes the one-sidedness mismatch tractable is the thing
that makes the carrier intractable. A construction cannot improve both at once by choosing a
different preimage; it can only pay for the carrier (finding 4's layer split) and then collect the
factorization for free (finding 5).

One further composition worth recording: the **same** uncompiled lemma — oriented-forest
Saturation — sits under the AA carrier (finding 4) and under the MSO cover step that 866's verdict
rides on. Two apparently independent fronts, the proof-theoretic one and the decidability one,
bottom out in one order-theoretic fact about oriented forests. That is the cheapest thing in this
area to make real.

### Recommendations

Prioritized. None of these is a completeness claim and none is proposed for this task.

1. **R1 — file it; lean4; highest value.** Oriented-forest *Saturation*: every oriented forest
   (directed paths unique between any two nodes) satisfies the literal `TaskFrame.Saturation`.
   Report 03 section 1.2's five steps against the literal definition, as a `Semantics/` lemma
   beside the existing `saturation_of_*` family. Unblocks both the AA carrier route (finding 4)
   and the MSO cover step; independent of separation, of Rabin, and of the ladder front. The
   natural home is next to `saturation_of_fib_finite`, and the natural statement takes the
   path-uniqueness hypothesis explicitly rather than a forest structure.
2. **R2 — file it; lean4; small and purely corrective.** Fix the `LCU` record and restore the
   segment-property parameter. Three parts: correct `PlusLCSchema.lean`'s docstring claim that
   `LCU` is `lcN` at `n = 1`; restore `omega_chain`'s segment-property parameter `P` with its
   stability hypothesis (the probe has both, lines 659-684 of the evidence file); and state the
   backward `LC_n` as the one-line `plusValidIn_reflectTime` corollary of `lcN_plusValidZTime`,
   since the doubled engine needs it and it costs a corollary. Declaring the until-form `LCU`
   itself is a larger step and should wait for R1 and 867.
3. **R3 — do not file yet; gated.** The doubled AA⊡ rule (forward plus mirror, one shared initial
   state at the clock zero) and its soundness at ZTime. Gated on R1, because the carrier's
   *Saturation* obligation is what stops it, and informed by 867, because the ban architecture
   consumes separation. Filing it before R1 would reproduce the blocker `NamingRules.lean` already
   records.
4. **R4 — do not file.** The MSO decidability result, following 866's R2 for the same reason
   (Mathlib has no ω-automata, MSO, or Rabin tree theorem). Additionally, G1 should be repaired on
   paper before any formalization of section 1.3 is contemplated; that repair is 866's R4 and
   remains the right next step for anyone pursuing the decidability reading.
5. **R5 — documentation, cheap.** Amend report 03 section 1.3's closing sentence ("the open
   question is only a *natural* system") rather than leaving it to be read off as settled. 866's
   R3 proposes the same amendment from the open-modal side; finding 6 here is a second,
   independent reason for it. `docs/theorem-index.md` needs no change.

## Decisions

1. **The research question is answered affirmatively for the doubled automaton and negatively for
   the framing.** A doubled (two one-sided, clock-anchored) automaton is sufficient in shape, and
   no bi-infinite ℤ-automaton is needed; but the one-sidedness mismatch is not "the whole
   difficulty", and the binding obstruction is the AA carrier. Both halves are recorded as the
   verdict rather than only the positive one.
2. **The carrier obstruction is recorded as intrinsic, with a proof.** Finding 3's two-line
   argument is the reason `NamingRules.lean`'s record is not an artefact of `coneR`. Recorded as
   *derived*, since it is not compiled; it is two lines from a compiled lemma and R1's task could
   carry it in passing.
3. **Separation at ZTime is named as the gate on the doubled architecture.** Finding 5(c) does not
   go through without it, and 867 is `[NOT STARTED]`. Decided to state this as a gate rather than
   to hedge finding 5's verdict, because steps (a) and (b) are compiled and only (c) is
   conditional.
4. **Report 03 section 1.3's consequence sentence is corrected, not confirmed.** The ZTime question
   is about existence. Decided to say so plainly and to attribute the located gap to 866's finding
   6 rather than re-deriving it.
5. **The `LCU` misidentification is reported as a defect of record, not as a reason to doubt
   `lcN`.** `lcN_plusValidZTime` is compiled and stands; what is wrong is the docstring's claim
   about a *different* formula and the absence of the segment-property hook.
6. **No `user_decision` is raised.** The three questions the dispatch asked are answered from
   artifacts and the library; nothing here needs a preference the artifacts cannot infer, and no
   external cost is incurred by any recommendation except R1, which is an ordinary Lean task.
7. **No library change and no completeness claim lands from this task**, as the dispatch requires.
   R1-R3 are filed as their own tasks or not at all.

## Risks & Mitigations

- **Risk**: finding 4's layer split has a gap in the mixed-family case. *Mitigation*: stated as a
  strategy, not a proof, with the mixed case named as the expensive one; R1 is scoped to the
  oriented-forest lemma alone, which is the prerequisite either way and is valuable independently
  of whether the split closes.
- **Risk**: finding 5(c) is read as establishing that the doubled engine works. It is not — it
  establishes that the *acceptance condition* factorizes, which removes one obstacle (the need for
  a bi-infinite automaton) and leaves the carrier obstacle and the ban construction untouched.
  *Mitigation*: the "what this does not do" paragraph in finding 5 and decision 1.
- **Risk**: finding 3's impossibility is read as refuting the AA transposition outright. It does
  not: it refutes the existence of a *graph-theoretically* tree-shaped two-way-bounded preimage,
  and `coneR` is not one — it carries the tree structure in state data. The conclusion is that
  `coneR`'s shape is forced, hence the Saturation obligation is unavoidable, not that AA⊡ is
  unsound or unreachable. *Mitigation*: stated explicitly in finding 3's consequence 2 and in
  decision 2.
- **Risk**: the one-sided factorization of finding 5 is confused with the one-sided `▷`/`◁`
  factorization that was **refuted** as a route on the decidability front (the ladder/RaySummary
  transport condition, where all six refutation mechanisms survive the factorization). These are
  different consumers: there the factorization was asked to crack a pointwise type-transport
  condition and failed; here it is asked only to split an acceptance condition at a named cut.
  *Mitigation*: stated here, so that the ROADMAP's ruling and this finding are not read as
  contradicting each other. Nothing in finding 5 claims anything about type transport.
- **Risk**: separation at ZTime turns out to be harder to formalize than its status as a cited
  theorem suggests, stranding R3 indefinitely. *Mitigation*: R1 and R2 are independent of it, and
  R3 is explicitly gated rather than filed.
- **Risk**: the finite model property is inferred from any of this. Nothing here establishes it;
  report 03 denies it and 866 gives direct evidence against the subtree-folding route.
  *Mitigation*: stated in Context & Scope.

## Appendix

### Evidence tier by claim

| Claim | Tier |
|---|---|
| `clock_irr_sound` / `irr_sound` hold at an arbitrary `FrameClass` | compiled |
| `⊡φ ↔ ▷◁φ ↔ ◁▷φ` on every regular task frame | compiled |
| `paste_valid` / `paste_valid'` (PS) with `IsPureFuture`/`IsPurePast` side conditions | compiled |
| `IsPureFuture`/`IsPurePast` treat `box`/`stab` as leaves for any argument | compiled |
| `truth_congr_agreeFrom` / `truth_congr_agreeUpTo` | compiled |
| `lcN_plusValidZTime`; `.Base` open and unclaimed | compiled (the former); docstring (the latter) |
| `plusValidIn_reflectTime` at an arbitrary `FrameClass` | compiled |
| `TwoWayBounded.exists_preimage_step_neg` (predecessor lifting from `step` at `-x`) | compiled |
| `SeparationOver` is an unformalized named hypothesis, false over dense flows | compiled (the definition), docstring (the status) |
| Landed ZTime decidability is at base `Formula`, no `⊡` | compiled (constructor list) |
| The cluster's `(past-type, future-type)` set is a full product | derived (finding 5b) |
| Unique-predecessor + `TwoWayBounded` + surjectivity ⇒ past-deterministic base | derived (finding 3) |
| `coneR`'s two-layer shape is forced | derived (finding 3, consequence 2) |
| Layer-split route to *Saturation* at the path-recording carrier | derived, strategy only (finding 4) |
| Acceptance factorizes at the named cut; two one-sided automata suffice | derived, conditional on separation (finding 5c) |
| `LCU` ≠ `lcN 1`; `omega_chain` dropped `P` | verified this session (definitions read side by side) |
| G1 and G2 in report 03 section 1.3 | derived by 866, inherited here |
| Oriented-forest *Saturation* (report 03 section 1.2) | paper, uncompiled |
| Rabin's theorem; undecidability of MSO over ℝ; Gabbay separation over ℤ | recalled |

### Locators

- `FormalSystem/Metalogic/NamingRules.lean` — module docstring section "The Auxiliary-Atoms
  expansion, and where it stops" (the recorded obstruction); `clock_irr_sound`, `irr_sound`
- `FormalSystem/Semantics/HistoryMorphism.lean` — `TwoWayBounded` (`forth`, `step`),
  `exists_preimage_step_neg`, the discrete-time lift narrative
- `FormalSystem/OpenLanguage/OpenTruth.lean` — `stab_to_ofut_opast`, `ofut_opast_to_stab`,
  `stab_iff_ofut_opast`, `stab_iff_opast_ofut`
- `FormalSystem/PlusLanguage/PlusPasting.lean` — `AgreeFrom`/`AgreeUpTo`, `paste`,
  `paste_agreeFrom`/`paste_agreeUpTo`, `truth_congr_agreeFrom`/`truth_congr_agreeUpTo`,
  `paste_valid`, `paste_valid'`
- `FormalSystem/PlusLanguage/Formula.lean` — `IsPureFuture`, `IsPurePast` and their `reflectTime`
  transports
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` — `lcAnte`, `lcCons`, `lcN`,
  `lcN_plusValidInt`, `lcN_plusValidZTime`; the `LCU` sentence in the module docstring
- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` — `omega_limit`, `intOrder_omega_cofinal`,
  `omega_chain` (no segment-property parameter)
- `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` — the probe's `omega_chain`
  with `P` and `hP`
- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` — `SepClauses`, `sepForm`,
  `SeparationOver`, `pastDet_of_isPurePast`, `futDet_of_isPureFuture`
- `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/Semantics/FrameProperty.lean` — the seven
  `saturation_of_*` routes
- `specs/559_.../reports/03_axiomatizability-rules-engine.md` — sections 1.2 (the cover and
  oriented-forest Saturation), 1.3 (the five MSO steps and the amendment), 2.3 (`LCU`), 3.3 (AA⊡),
  4 (the located obstruction)
- `specs/866_.../reports/01_mso-route-open-modals.md` — findings 3-6 (the open modals, the step-1
  amendment, G1, G2), finding 8 (Mathlib has nothing to build the MSO step on)
