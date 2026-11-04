# Research Report: Task #854

**Task**: 854 - Is the open-future modal ▷ definable in L⁺? (Path A gate on the L^▷ language ruling)
**Started**: 2026-11-04T21:02:04Z
**Completed**: 2026-11-04T21:40:00Z
**Effort**: 1 research round (one compiled-live probe, ~310 lines; literature cross-check against four held sources)
**Dependencies**: None (833 is not needed for anything here; the probe imports only `FormalSystem.OpenLanguage`)
**Sources/Inputs**: - Codebase (`FormalSystem/OpenLanguage/*`, `FormalSystem/PlusLanguage/PlusPasting.lean`, `PlusTruth.lean`, `Semantics/TaskFrame.lean`, `Semantics/FrameProperty.lean`, `Semantics/FrameClassValidity.lean`, `Metalogic/Independence/StabUndefinable.lean`), lean-lsp MCP (local compile via `lean` with `LEAN_PATH`), literature briefing (`--lit`): Gabbay–Hodkinson–Reynolds 1994 vol. 1 ch. 9, 10, 12; Gabbay–Hodkinson–Reynolds 1993; Rabinovich 2014; task 559's description and probe 05
**Artifacts**: - `specs/854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md` (this report)
- `specs/854_open_future_modal_lplus_definability/probes/01_ofut-elimination-and-translation.lean` (compiled-live, exit 0, no sorry, no warnings)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **VERDICT: SPLIT BY FRAME CLASS, and the split is the finding.**
  - **At `.ZTime` and `.RTime` (the Dedekind-complete temporal orders): POSITIVE.** ▷ and ◁ are
    L⁺-definable, uniformly in their argument: there is a translation `tr : OpenFormula → PlusFormula`
    with `OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr φ)` at every model, world and time over every
    regular ℤ-time frame, and likewise over every regular ℝ-time frame (with a different `tr`).
    The Lean half — the elimination `▷(α ∨ β) ↔ α ∨ ⊡β` for past-determined `α` and
    future-determined `β`, its CNF form, and the recursive translation conditional on a separation
    hypothesis — is **compiled-live** (probe 01). The paper half is **Gabbay's Separation Theorem**
    (GHR vol. 1, Thm 10.2.9 over ℤ; Thm 10.3.20 over Dedekind-complete flows), a held source,
    applied with `□ψ`/`⊡ψ` as propositional leaves.
  - **At `.Base` and `.Dense`: OPEN, with the obstruction located exactly.** The only general
    ▷-elimination available goes through separation, and **U/S is not separable over ℚ-time**:
    separation implies expressive completeness (GHR Thm 9.3.1, held) and U/S is not expressively
    complete over the rationals (Rabinovich 2014, held; GHR vol. 1 §12.4 gives the gap-order reason).
    ℚ is a `TemporalOrder`, so no translation obtained this way is valid at `.Dense` or `.Base`.
    Whether ▷ is nonetheless definable there — by a ▷-specific elimination that does not need full
    separation — or provably not — by a ℚ-time (or ℚ ×ₗ ℤ-time) separating pair — is not settled
    and is the single open item this task leaves.
- **The dispatch's expected negative fixture cannot work.** `sinkFrame` is a ℤ-time frame, and on
  every ℤ-time frame ▷φ coincides with an L⁺ formula; no bisimulation separation on `sinkFrame`,
  or on any `.ZTime` frame, can exhibit undefinability. A negative answer, if one exists, lives
  on a non-Dedekind-complete duration.
- **Consequences for consumers** (routed in §Decisions): at ZTime the LANGUAGE RULING is
  notational — L^▷ over ℤ says exactly what L⁺ over ℤ says — so 559's (n1)–(n2) survive at ZTime
  only as restatements, the separate L^▷ proof-system programme (856) is unnecessary *at ZTime
  and RTime*, and the Stage 1 retarget question is answered negatively there at no further cost.
  At Base/Dense none of this follows; 856's rationale is intact only for those classes and is
  gated on the open item.
- **One new validity worth recording**: `▷φ⁺ ↔ ⊡φ⁺` for pure-future `φ⁺` (`ofutP_of_futDet`),
  the open-future modal collapses onto stability on pure-future arguments, on every regular frame.

## Context & Scope

**The question, as dispatched.** ▷ is interpreted over `|τ⟩_x`, the worlds agreeing with the
world of evaluation at every time `≤ x` (`OpenTruthAt`, `ofut_iff`). Is there a translation
`t : OpenFormula → PlusFormula` agreeing with `OpenTruthAt` on the ▷-fragment? Validity
(`OpenValid`, `PlusValid`) quantifies over **every** regular task frame, and a task frame's
`Duration` is any nontrivial totally ordered abelian group (`TemporalOrder`): ℤ, ℚ, ℝ, lexicographic
products, and so on. So "definable in L⁺" has a class-indexed reading — definable over the frames of
`FrameClass.fc` — and the answer turns out to depend on it.

**What the tree already had, and what it did not.** Every landed result (`ofut_of_stab`,
`not_openValid_stab_of_ofut`, `hnStab_refuted_sinkFrame`, `hnOpen_openValid`, 833's `⊡ ↔ ▷◁`)
separates *operators*; none separates *languages*, as the dispatch says. What the tree had and the
dispatch did not name is the exact apparatus a positive answer needs:

- `PlusLanguage.paste` (`PlusPasting.lean`): on every regular frame, two worlds sharing a state at
  `t` paste to a world `ρ|(-∞,t] ⌢ σ|(t,∞)`, with `paste_agreeUpTo` and `paste_agreeFrom`.
  Regularity enters here and nowhere else (Compositionality across the seam).
- `IsPurePast` / `IsPureFuture` with `truth_congr_agreeUpTo` / `truth_congr_agreeFrom`: syntactically
  pure formulas see only one side of the present, with `□ψ` and `⊡ψ` admitted as leaves of both
  because `□ψ` is history-independent and `⊡ψ` depends on the present state alone
  (`stab_state_only`).

Put together: ▷ reads the whole past of the history and quantifies over its futures; pasting says
the futures available at `t` depend on the present state alone; so ▷ can be eliminated from any
formula that has been **separated** into past-determined and future-determined parts. That is
exactly what Gabbay's Separation Theorem supplies — and exactly what it does not supply over ℚ.

**Scope.** Expressiveness only. No completeness or decidability claim is made or implied anywhere
in this report; the Stage 1 remark in §Decisions is the expressiveness fact that there is nothing
to retarget onto, not a decidability statement. No file under `FormalSystem/` or `Tests/` was
touched.

## Findings

### Codebase Patterns

**F1. The ▷-elimination, compiled-live** (`probes/01_ofut-elimination-and-translation.lean`,
namespace `Probe854R01`; exit 0, no sorry, no warnings, against the repository's own oleans).

Semantic purity is used rather than the syntactic predicates, because the ℝ-time separated forms
are not syntactically pure (see F3):

```
PastDet F φ := ∀ M τ σ t, AgreeUpTo τ σ t → (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ)
FutDet  F φ := ∀ M τ σ t, AgreeFrom τ σ t → (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ)
```

with `pastDet_of_isPurePast`, `futDet_of_isPureFuture` from the landed congruence lemmas. The
elimination, on every regular frame, for `α` past-determined and `β` future-determined:

| Declaration | Statement | Mechanism |
|---|---|---|
| `ofutP_or_iff` | `▷(α ∨ β) ↔ α ∨ ⊡β` | `→`: for `σ ∈ ⟨τ⟩_t`, `paste τ σ t ∈ \|τ⟩_t`; on it `α` reads as on `τ`, `β` as on `σ`. `←`: `\|τ⟩_t ⊆ ⟨τ⟩_t` and `PastDet` |
| `opastP_or_iff` | `◁(α ∨ β) ↔ ⊡α ∨ β` | the mirror, pasting `σ`'s past onto `τ`'s future |
| `ofutP_sepForm_iff`, `opastP_sepForm_iff` | `▷ ⋀ᵢ(αᵢ ∨ βᵢ) ↔ ⋀ᵢ(αᵢ ∨ ⊡βᵢ)` and the mirror | `▷` distributes over `∧` |
| `ofutP_of_pastDet` | `▷ψ⁻ ↔ ψ⁻` | 559 (n2)'s rigidity schema, semantic half |
| `ofutP_of_futDet` | `▷φ⁺ ↔ ⊡φ⁺` | **new**: ▷ collapses onto ⊡ on pure-future arguments |

**F2. The translation, conditional on separation** (same probe). `SeparationOver P` says: every
L⁺ formula is equivalent, on every regular frame satisfying `P`, to a CNF `sepForm L` whose
clauses are (past-determined ∨ future-determined). Given `hsep : SeparationOver P`,
`tr hsep : OpenFormula → PlusFormula` is homomorphic on the seven shared constructors and sends
`▷φ` to `ofutElim L` (`⋀ᵢ(αᵢ ∨ ⊡βᵢ)`) and `◁φ` to `opastElim L` for a chosen separated form `L`
of `tr φ`. Then:

- `openTruthAt_iff_tr`: `OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr hsep φ)` on every regular
  `P`-frame, at every model, world and time — by induction on `φ` generalizing `τ` and `t`,
  exactly as `openTruthAt_ofPlus`, with the two new cases being F1's CNF eliminations.
- `openValidOnFrames_iff_tr`, and the instances `openValidIn_ztime_iff_tr` (for
  `SeparationOver TaskFrame.IsZTime`) and `openValidIn_rtime_iff_tr` (for
  `SeparationOver TaskFrame.IsRTime`): L^▷-validity at the class is L⁺-validity of the translation.

Axioms (`#print axioms`): `[propext, Classical.choice, Quot.sound]` for the elimination and
translation theorems — choice enters only through the case split on `α` that the disjunctive
statement forces (`PlusFormula.or α β` is `¬α → β` and `PlusTruth.or_iff` is classical) and,
in `tr`, through choosing a separated form; `paste` itself is choice-free, and the split-free
instance `ofutP_of_futDet` reports `[propext, Quot.sound]`.

**F3. Why semantic purity, not `IsPurePast`.** Gabbay's ℤ-separated forms are Boolean
combinations of atoms, U-only and S-only formulas (GHR Lemma 10.2.8's "syntactically separated"),
which with leaves become `IsPureFuture` / `IsPurePast` `PlusFormula`s directly. The
Dedekind-complete forms (GHR Def. 10.3.3) are stated in the extended language with `K⁺q := ¬U(⊤,¬q)`
and `K⁻q := ¬S(⊤,¬q)` as connectives, and allow `K⁻` inside an "`U(A,B)` without `S`" component.
Re-expanded into U/S, such a component contains `S` and is **not** `IsPureFuture`, though it is
future-determined (GHR Lemma 10.3.4). The probe's `FutDet` is the notion that survives this; the
ℝ-time instantiation therefore goes through `FutDet`/`PastDet` directly, not through the syntactic
predicates.

**F4. The in-tree undefinability template does not apply at ZTime.** `StabUndefinable.lean`
proves `⊡Fp` is not L-definable with a `TruthCorr` relating a permissive ℤ-frame to a deterministic
one. The analogous move for ▷ against L⁺ would need a `TruthCorr`-style relation closed under the
`⊡` back-and-forth at **every** time along related histories; F2 shows that on any ℤ-frame such a
relation preserves ▷φ for every φ, so no ℤ-time pair can separate. In particular the dispatch's
fixture `sinkFrame` (a `FrameOver intOrder`) is ruled out as a separator.

### External Resources

All held in the literature corpus; chunk paths under `/home/benjamin/Projects/Literature/sources/`.

- **GHR 1994 vol. 1, Thm 10.2.9 (Separation Theorem over ℤ)** — `gabbay_1994/ch1001_*.md`:
  "Each wff in the language with {U, S} is equivalent, over the integer flow of time, to a
  separated wff", proved by the eight eliminations of Lemma 10.2.3 and induction on junction depth
  (Lemma 10.2.8). The proof is a syntactic rewriting procedure; the separated wff is "a boolean
  combination of atoms, wffs U(E, F) with E and F built without using S and wffs S(E, F) with E
  and F built without using U". Credited there to Gabbay 1989a. **Held.**
- **GHR 1994 vol. 1, Thm 10.3.20 (Separation over Dedekind-complete time)** —
  `gabbay_1994/ch1004_*.md`: "Over Dedekind complete time, each wff in the language with {U, S} is
  equivalent to a separated wff", in the extended language of Def. 10.3.3 (§10.3.1,
  `ch1002_*.md`; §10.3.2, `ch1005_*.md`). The auxiliary atom `c` is interpreted "true everywhere"
  for plain flows. **Held.** Covers `.RTime` (dense ∧ Dedekind complete) and, redundantly, `.ZTime`.
- **GHR 1994 vol. 1, Def. 9.2.3 and Thm 9.3.1** — `gabbay_1994/ch901_*.md`, `ch902_*.md`: pure
  past / pure future are **semantic** notions over a class 𝒯 (truth at `t` invariant under
  changing the valuation off the past, resp. off the future), and "L has the separation property
  over 𝒯 implies that L is expressively complete over 𝒯" (P, F definable). Thm 9.3.4 is the
  converse over linear time. **Held.** This is what makes the probe's semantic `SeparationOver`
  comparable to the literature's notion, and what refutes it over ℚ.
- **Rabinovich 2014, *A Proof of Kamp's Theorem*, §7** — `rabinovich_2014/chunk_0023.md`: "The
  temporal logic with the modalities Until and Since is not expressively complete for FOMLO over
  the rationals." **Held** (not an UNVERIFIED entry). Together with Thm 9.3.1 (contrapositive):
  U/S does not have the separation property over ℚ.
- **GHR 1994 vol. 1, §12.4** — `gabbay_1994/ch1201_*.md`, `ch1202_*.md`: Lemma 12.4.1, U/S is
  expressively complete over flows with only isolated gaps; Lemma 12.4.2, not in general (a flow
  with a single non-isolated gap); "nowhere in the rationals is there a gap of any order at all",
  and the connective `γ_π⁺` is not U/S-expressible by an argument that replaces "rational numbers
  in an interval" by alternating `p`-intervals. **Held** — the mechanism behind the ℚ failure.
  Same content in GHR 1993 §4 (`gabbay_1993/sec03_*.md`, Lemmas 2–3), marked UNVERIFIED in the
  briefing; the 1994 chapter is the one cited.
- **Repository docstrings** (`FrameProperty.lean`): `IsZTime` picks out exactly the ℤ-time
  durations ("the Archimedean discrete orders are exactly ℤ-time"); `IsRTime` is dense ∧ complete;
  `IsQTime` exists and ℚ is a `TemporalOrder`.

**The paper step, stated so it can be audited (UNVERIFIED in Lean, routine).** Fix a regular
frame `F` with `IsZTime` (resp. `IsRTime`), a model `M`, a world `τ`. For an L⁺ formula `φ`, read
each maximal `□ψ`/`⊡ψ` subformula and each atom as a propositional leaf, giving a U/S formula `φ̂`.
(i) The leaf valuation along `τ`, `v(a)(s) := PlusTruthAt M τ s a`, is a valuation over
`F.Duration`, which is order-isomorphic to ℤ (resp. is a Dedekind-complete flow), and
`PlusTruthAt M τ t φ ↔ ⟦φ̂⟧ᵥ(t)` by induction, since `PlusTruthAt`'s `untl`/`snce` clauses are
GHR's `U`/`S` clauses with the guard–event order swapped (`untl ψ φ` is `U(φ, ψ)`). (ii) Thm 10.2.9
(resp. 10.3.20) gives a separated `ψ̂` with `⟦φ̂⟧ᵥ ↔ ⟦ψ̂⟧ᵥ` for every valuation, hence for `v`.
(iii) Substituting the leaves back and putting the Boolean combination into CNF, each clause is
(past-literals ∨ future-literals) with a leaf literal placed on either side; past-side disjunctions
are `PastDet` and future-side ones `FutDet` (syntactically pure at ZTime; by GHR Lemma 10.3.4 at
RTime). This is `SeparationOver TaskFrame.IsZTime` (resp. `IsRTime`), and F2 does the rest.
Nothing in (i)–(iii) depends on the frame beyond the duration's order type, and the leaf step is
sound because `⊡ψ`/`□ψ` are both `PastDet` and `FutDet` (`stab_state_only`; the `box` clause).

### Recommendations

**R1. Record the verdict as class-split, not binary**, in 559 and the ROADMAP: positive at
`.ZTime`/`.RTime`, open at `.Base`/`.Dense`. A binary "positive" would overstate (it fails to
transfer to ℚ-time) and a binary "inconclusive" would hide a settled, consequential half.

**R2. Do not spend anything further on a ℤ-time separation** (`sinkFrame` or any other
`FrameOver intOrder`): F4. Any future negative attempt must be on a non-Dedekind-complete
duration — ℚ (the `IsQTime` class) is the natural first choice, ℚ ×ₗ ℤ the natural second (a
discrete flow whose gaps are dense, the group-shaped analogue of GHR Lemma 12.4.2's flow).

**R3. The open item, as a follow-on research task** (proposed; not filed here). "Is ▷ L⁺-definable
over ℚ-time task frames?" Two routes, to be run against each other:
- *Negative*: an L⁺ formula φ whose `▷φ` is not U/S-definable over ℚ-time. `▷φ` is always
  definable in first-order monadic logic by a Feferman–Vaught/Shelah composition argument over
  the ordered sum `τ|≤t ⌢ f` (recalled, not held — label it so), while U/S ⊊ FOMLO over ℚ; the
  candidate is therefore a Stavi/`γ_π⁺`-type property surfacing in `▷φ`. The L⁺-invariance half
  must be a genuine bisimulation over ℚ-time task frames, with the `⊡` back-and-forth closed at
  every time, in the `TruthCorr` style of `StabUndefinable.lean` (the only in-tree template).
- *Positive*: a ▷-specific elimination that does not need full separation — e.g. one that
  separates only the clauses that `▷`'s universal quantification actually touches. No such
  argument is known to this round.
A precisely located obstruction (which GHR elimination fails over ℚ, on which model pair) is a
complete outcome for that task.

**R4. A sorry-free path to a fully machine-checked ZTime verdict exists and is sizeable**:
formalize GHR Lemmas 10.2.1–10.2.8 for `PlusFormula` over `IsZTime` frames (the eight
eliminations plus the junction-depth induction), discharging `SeparationOver TaskFrame.IsZTime`
and making `tr` an executable translation. Propose as an implementation task only if a consumer
needs the executable translation; the verdict itself does not need it.

**R5. For 856**: do not enter at the Base class on the strength of this verdict; at ZTime/RTime
there is nothing for it to do (see Decisions D3). If the Base/Dense item resolves positively,
856 is unnecessary at every class; if negatively, 856's rationale is confined to Base/Dense.

## Decisions

- **D1. The verdict is stated per frame class.** The dispatch asked for a single answer; the
  honest answer is class-dependent, and both halves are consequential. Hedging either into
  "inconclusive" is exactly what the dispatch forbade.
- **D2. The negative fixture is abandoned, with a reason.** `sinkFrame` and every `.ZTime` frame
  are excluded as separators by F2/F4. This closes 559's (P0b) reading "a bisimulation-style
  separation; sinkFrame is the natural fixture".
- **D3. Routing to consumers.**
  - **559 (n3), (P0b)**: at ZTime/RTime, ▷ *is* L⁺-definable, so (n1)–(n2) survive there only as
    restatements, as 559 itself anticipated; (n2)'s rigidity schema `▷ψ⁻ ↔ ψ⁻` is `ofutP_of_pastDet`,
    and the companion `▷φ⁺ ↔ ⊡φ⁺` is `ofutP_of_futDet`. At Base/Dense (n3) stays open.
  - **559 (P0c)**: unaffected (an invariance result for ▷/◁, not a definability one).
  - **559 (P0d)** (LC_n in ▷-form at ZTime): by `openValidIn_ztime_iff_tr` the ▷-form is equivalent
    at ZTime to an L⁺ formula, so its validity is an L⁺ question; the forward-splice argument 559
    names is still the way to settle it. Not done here.
  - **856** (L^▷ proof system): HARD-GATED, and the gate now reads: unnecessary at ZTime and
    RTime (L^▷ is notation for L⁺ there); undecided at Base/Dense pending R3. Do not enter.
  - **ROADMAP Stage 1 retarget**: answered negatively at ZTime at no further cost — there is no
    expressive gain to retarget onto, since over ℤ every L^▷ formula is an L⁺ formula under an
    effective translation (Gabbay's procedure is syntactic). This is an expressiveness statement;
    no decidability or completeness claim is made.
  - **ROADMAP Stage 2 / 833**: unaffected; `⊡ ↔ ▷◁` remains true and useful at every class.
- **D4. Semantic purity over syntactic purity in the probe** (F3), so that the same Lean theorem
  serves both the ℤ and the ℝ instantiations.
- **D5. Literature discipline.** Four held sources are cited by chunk; the GHR 1993 chunks
  (UNVERIFIED) are not relied on where the 1994 chapter says the same; the one recalled claim
  (Feferman–Vaught composition for `▷φ`'s FOMLO-definability) is labelled recalled and used only
  to shape R3, never as a result.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| The paper step (leaf abstraction + CNF rearrangement) hides a gap | It is written out in three auditable sub-steps under External Resources; each is an induction or a propositional rewriting; `⊡`/`□` leaves are justified by landed lemmas (`stab_state_only`, `box_iff`). R4 names the formalization that would remove it entirely. |
| GHR's ℤ theorem is about the integer flow, not an `IsZTime` duration | `IsZTime` durations are order-isomorphic to ℤ (repo docstring, `FrameProperty.lean`), and U/S truth is order-invariant; `PlusTruthAt`'s temporal clauses use only `<`. |
| RTime forms are not syntactically pure (F3) | The probe uses semantic `PastDet`/`FutDet`; GHR Lemma 10.3.4 supplies determinedness of the separated components. |
| Misreading the open half as a soft positive | R1 and D3 state it as open with the obstruction (no separation over ℚ) and name both candidate routes; nothing in F1–F2 applies at Dense/Base. |
| The dispatch's consumers expect a binary gate | D3 routes each consumer explicitly by class; the `user_decision` on `.return-meta.json` surfaces the one genuine programme choice. |
| `Classical.choice` in the elimination lemma read as a weakness | It is forced by the disjunctive statement (`or` is `¬α → β`); the split-free instances are choice-free, and `paste` is choice-free. |

## Tactic Survey Results

Not applicable in the LeanHammer sense: every goal in the probe closed on the first substantive
attempt with structural term proofs (`forall_congr'`, `imp_congr_right`, `Iff.trans`), `rw` with
the clause lemmas, and one `by_cases`. No `simp`/`omega`/`aesop` candidates were needed or tried.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `▷(α ∨ β) ↔ α ∨ ⊡β` (`ofutP_or_iff`) | `rw [or_iff, stab_iff]` + `by_cases` + term proof | success | `paste`, `paste_agreeUpTo`, `paste_agreeFrom`, `agreeUpTo_equivalence` |
| CNF elimination (`ofutP_sepForm_iff`) | structural recursion on the clause list + `rw` | success | `ofutP_and`, `and_iff`, `ofutP_or_iff` |
| translation (`openTruthAt_iff_tr`) | `induction φ generalizing τ t` (the `openTruthAt_ofPlus` pattern) | success | `Classical.choose_spec`, CNF lemmas |
| class-validity transfer | `haveI` on the regularity conjunct + term proof | success | `openTruthAt_iff_tr` |

## Context Extension Recommendations

- **Topic**: separation theorems and expressive completeness of U/S by flow class (ℤ, ℝ, isolated-gap flows, ℚ), and what each means for a modal-temporal product like L⁺/L^▷.
- **Gap**: `context/project/logic/` has Kripke-semantics orientation but nothing on Gabbay separation or the Kamp/Stavi boundary, which this task shows is the exact hinge for every "is operator X definable" question over the repository's general `TemporalOrder`.
- **Recommendation**: add `context/project/logic/domain/separation-and-expressive-completeness.md`
  with the four held citations above, the ℤ/ℝ/ℚ status table, the "leaves" technique for `□`/`⊡`,
  and the F3 caveat about syntactic versus semantic purity.

## Appendix

**Search queries used**
- `literature-search.sh "separation theorem pure past pure future Boolean combination"` → GHR ch. 10 chunks (Thm 10.2.9).
- `literature-search.sh "rationals expressively complete until since"` → reynolds_1994, rabinovich_2014.
- `grep` across held chunks for `rational`, `Theorem 9.3`, `Dedekind`, `isolated gap`.
- Codebase: `grep` for `stab_state_only`, `IsPureFuture`, `truth_congr_agreeFrom`, `paste_agreeUpTo`, `IsZTime`, `FrameClass.Sat`.
- lean-lsp: not used for search; the probe was compiled directly against the oleans (the guard confirmed `FormalSystem.OpenLanguage` and `PlusPasting` up to date, 1210 jobs cached).

**Compile command (exit 0)**
```
LP=.lake/build/lib/lean; for d in .lake/packages/*/.lake/build/lib/lean; do LP="$LP:$d"; done
LEAN_PATH="$LP" ~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/bin/lean \
  specs/854_open_future_modal_lplus_definability/probes/01_ofut-elimination-and-translation.lean
```

**References**
- D. M. Gabbay, I. M. Hodkinson, M. A. Reynolds, *Temporal Logic: Mathematical Foundations and Computational Aspects*, vol. 1 (1994): Def. 9.2.3, Thm 9.3.1, Thm 9.3.4, Lemmas 10.2.1–10.2.8, Thm 10.2.9, Def. 10.3.3, Lemma 10.3.4, Thm 10.3.20, Lemmas 12.4.1–12.4.2.
- A. Rabinovich, *A Proof of Kamp's Theorem* (2014), §7.
- D. M. Gabbay, I. M. Hodkinson, M. A. Reynolds, *Temporal expressive completeness in the presence of gaps* (1993), §4 (UNVERIFIED chunk; corroborated by the 1994 chapter).
- Task 559's description, items (g), (h), (n), (P0b); probe 05 (`⊡ ↔ ▷◁`).
- `FormalSystem/PlusLanguage/PlusPasting.lean`, `FormalSystem/OpenLanguage/OpenTruth.lean`, `FormalSystem/Metalogic/Independence/StabUndefinable.lean`.
