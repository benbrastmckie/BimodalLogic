# Research Report: Task #682

**Task**: 682 - Stability decidability provenance gate
**Started**: 2026-09-27T18:31:00Z
**Completed**: 2026-09-27T18:58:00Z
**Effort**: one research dispatch (orchestrated, seq 1)
**Dependencies**: None
**Sources/Inputs**:
- Held literature: `thomas_1997_languages_automata` (Wolfgang Thomas, *Languages, Automata, and
  Logic*, 1997) — markdown **and** its source PDF, both at
  `~/Projects/Literature/sources/thomas_1997_languages/`;
  `reynolds_2002_axioms_for_branching_time` §6 (`chunk_0024.md`)
- Prior artifacts (not re-derived): `specs/623_decidable_validztime_quasimodel_shiftset_route/reports/01_stability-scope-decidability-findings.md`;
  `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` §1.2-1.4;
  same task's `reports/01_nondeterministic-canonical-model.md` §2.4
- Codebase: `FormalSystem/Semantics/{FrameClassValidity,FrameProperty,DurationClassification,IntNormalForm,IntTransfer,TaskFrame,ShiftSet}.lean`,
  `FormalSystem/PlusLanguage/{PlusValidity,PlusTruth}.lean`,
  `FormalSystem/ProofSystem/Axioms.lean`
- Evidence probe re-run: `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
- Verification: `mcp__lean-lsp__lean_verify` axiom checks against the current build;
  `lake env lean` on a scratch copy of the archived probe
**Artifacts**: - `specs/682_stability_decidability_provenance_gate/reports/01_stability-decidability-provenance-gate.md` (this report)
**Standards**: report-format.md, subagent-return.md

No file under `FormalSystem/` or `Tests/` was changed. The one Lean edit made was to a **scratch
copy** of an archived evidence probe, under the session scratchpad.

## Executive Summary

- **Verdict 1 — AFFIRMATIVE. Rabin's theorem is tied to a held source, and the held source is
  better than a citation: it contains a self-contained proof.** Thomas 1997 §6.3,
  **Theorem 6.20 (Rabin Tree Theorem [Rab69]): "The theory S2S is decidable."** The very next
  sentence supplies the ω-branching case the argument actually needs — "the decidability S2S
  extends to tree models with arbitrary finite and even countable branching (such trees are
  easily embedded in the binary tree)". The paragraph after that sets out, in the source's own
  voice, exactly the unravel-and-embed method the repository's argument performs. The standing
  prohibition in report 623 ("do not cite the MSO argument in library documentation unless
  Rabin's theorem is first tied to a held source") is **discharged**.
- **Verdict 2 — HOLDS for the ⊡-free language, machine-checked; NOT YET LANDED for the language
  the question is actually about.** `FrameClass.ZTime` is exactly `D = ℤ`
  (`validZTime_iff_validInt`, verified sorry-free today) and its histories are exactly the
  bi-infinite walks of a digraph (`mem_HF_iff_adjacent`, likewise). Two residues, both named
  precisely below: (i) the ℤ-normalization is proved for `Formula`, not `PlusFormula`, and the
  generic transport it runs on (`TruthCorr`) is **`Formula`-only by construction**, so it is not
  a matter of instantiating an existing lemma; (ii) of the four frame constraints, only
  *Saturation* is a genuine residue over ℤ, and it is landed as free only on **finite** carriers
  — on the infinite carriers the MSO argument actually builds it rests on an uncompiled
  universal-cover argument.
- **Verdict 3 — NEGATIVE, and sharper than "not obtained": a finite-MODEL certificate is
  refuted, not merely unproven.** `Probe476.fmp_false` re-verified today. No route in the held
  literature yields a finite certificate for this language. What the held literature *does*
  supply is a certificate of a different shape — Thomas's **Theorem 6.18 (Rabin Basis Theorem)**
  guarantees a *regular* (finitely generated, infinite) tree model, obtained effectively — and
  that shape is compatible with `fmp_false`, which kills finite models only. The certificate
  design must supply its own finiteness argument; the held literature names the shape to aim at,
  not the argument.
- **Bit-rot finding, load-bearing for the citation chain.** As stored, the archived
  `fmp_false` probe no longer elaborates: one line predates the `Sat .ZTime = IsRegular ∧ IsZTime`
  split, and `#print axioms` consequently reports **`sorryAx`**. A one-term repair restores
  `[propext, Classical.choice, Quot.sound]`. Anyone re-checking the citation without this repair
  will conclude the repository's machine-refutation is sorried. The repair is recorded verbatim
  below.
- **Gate recommendation.** Decidability of the target is **not known**. It is a five-step paper
  argument whose one *recalled* ingredient is now *held*, and whose other four steps remain
  unverified. That is a real improvement in provenance and no improvement in certainty. The
  downstream design line is not closed — Verdict 3 already obliges it to supply its own
  finiteness argument either way — but it must not be started on the premise that it is
  formalizing a known-decidable target.

## Context & Scope

Three verdict questions, each requiring a cited source rather than a recollection, gating the
stability-modal decision-procedure line. The scope is deliberately narrow: establish provenance
and check an assumption against landed code. No new mathematics was attempted, and no claim below
is offered at a higher confidence than its evidence supports. The status vocabulary is the one
report 03 of the completeness research established and this report keeps: *machine-checked*
(verified against the current build during this dispatch), *landed* (a theorem in the tree,
cited by name and line), *paper* (an argument written out in a prior report, not machine-checked),
*held* (backed by a source in the literature corpus), *recalled* (a literature fact with no held
source).

## Literature Proof Structure

**Source**: Wolfgang Thomas, *Languages, Automata, and Logic* (1997), §6 "Automata and MSO-Logic
on Infinite Trees". Held at
`~/Projects/Literature/sources/thomas_1997_languages/Thomas_1997_Languages_Automata_Logic.md`,
with the source PDF alongside it. Global index id `thomas_1997_languages_automata`;
`provenance_fidelity: verified_conversion`, `word_ratio: 1.0`, combining marks checked.

**Strategy**: automata-theoretic. MSO sentences over the infinite binary tree are converted to
tree automata; emptiness of those automata is decided by a game argument; decidability of the
theory follows, and transfers to modal logics by unravelling-and-embedding.

### Step Map

1. **Tree automata** (§6.1, Def. 6.1-6.4) — Muller / Rabin / Streett / Rabin-chain (parity) tree
   automata, run trees, acceptance along every path.
2. **Complementation / determinacy** (§6.2, Thm. 6.16) — effective determinacy of Rabin-chain
   games, following the game-theoretic route of Büchi, Gurevich-Harrington, Emerson-Jurdziński,
   Mostowski, McNaughton, Zielonka. This is the chapter's self-contained substitute for Rabin's
   own complementation proof.
3. **Basis Theorem** (§6.2, **Thm. 6.18**, "Rabin Basis Theorem, cf. [Rab72]") — for Rabin-chain
   tree automata, emptiness is decidable, **and any nonempty `T_ω(A)` contains a regular tree,
   whose generating finite automaton `B` is obtained effectively**.
4. **MSO-to-automaton** (§6.3, Thm. 6.19) — an MSO sentence yields an input-free tree automaton
   with a successful run iff the sentence holds in the tree structure.
5. **Rabin Tree Theorem** (§6.3, **Thm. 6.20**) — "The theory S2S is decidable."
6. **Countable branching** (§6.3, immediately after Thm. 6.20) — "the decidability S2S extends to
   tree models with arbitrary finite and even countable branching (such trees are easily embedded
   in the binary tree)."
7. **Modal-logic transfer** (§6.3, the paragraph after Thm. 6.20) — a Kripke structure over `n`
   atoms unravels to a `{0,1}^n`-valued tree; the tree embeds prefix-preservingly into the binary
   tree (`v` reached by successors `i₁ … i_l` is coded `1^{i₁}0 1^{i₂}0 … 1^{i_l}0`); the
   embedding's range is a set parameter `P₀`; satisfiability of the modal logic reduces to
   `∃X₀ … ∃X_n φ(X₀, …, X_n)` in `T`, decidable by Thm. 6.20. The chapter names the modal
   µ-calculus and CTL* as instances.
8. **Regular models** (§6.3, same paragraph) — "if a formula of such a logic is satisfiable …
   then, by Rabin's Basis Theorem 6.18, also a regular tree model can be guaranteed. Such regular
   models originate from finite graphs (the generating automata)."

### Dependencies

- Step 5 depends on steps 3 and 4. Step 4 depends on step 2.
- Steps 6 and 7 depend on step 5. Step 8 depends on step 3 and step 7.
- The repository's own argument (report 03 §1.3) depends on steps 5, 6 and 7 — and the
  certificate question (Verdict 3) depends on step 8.

### Mapping to the repository's argument

| Report 03 §1.3 step | What the held source supplies |
|---|---|
| 1. countable model property | nothing — repository-internal, paper-level |
| 2. pass to the oriented-forest cover | nothing — repository-internal, paper-level (§1.2) |
| 3. root each tree ⇒ countably branching rooted tree | step 6 (countable branching admissible) + step 7 (the unravel-and-embed template) |
| 4. MSO-definability of the truth clauses | step 7 as a template; the clauses themselves are repository-internal, paper-level |
| 5. "decidable by Rabin's theorem (recalled)" | **step 5 — Theorem 6.20, held, with a self-contained proof in §6.1-6.2** |

### Potential formalization challenges

- Step 4 (the MSO translation of `U`, `S`, `⊡` and `□` at a walk-with-marked-time `(P, x)`) is
  where the argument's real content sits, and nothing held performs it for this language.
- Step 7's coding is stated for propositional Kripke structures with atoms valued in
  `{0,1}^n`. The repository's atoms are state-valued, which is what makes Reynolds 2002 §6's
  "no trace of futurity" hypothesis hold here (report 03 §1.4) — so the template applies, but
  that match is an argument, not an inheritance.

## Findings

### Codebase Patterns

Everything in this subsection was checked against the current tree during this dispatch. Axiom
checks were run with `lean_verify` against the existing build; each returned
`["propext", "Classical.choice", "Quot.sound"]` with no warnings and no `sorryAx`.

**The interpretation of the tag.** `FormalSystem/Semantics/FrameClassValidity.lean:151-155`:

```lean
@[reducible]
def FrameClass.Sat : FrameClass → TaskFrame → Prop
  | .Base, F => F.IsRegular
  | .Dense, F => F.IsRegular ∧ F.IsDense
  | .ZTime, F => F.IsRegular ∧ F.IsZTime
  | .RTime, F => F.IsRegular ∧ F.IsRTime
```

and `FormalSystem/Semantics/FrameProperty.lean:184-186`:

```lean
def TaskFrame.IsZTime (F : TaskFrame) : Prop :=
  ∃ (_ : SuccOrder F.Duration) (_ : PredOrder F.Duration),
    IsSuccArchimedean F.Duration ∧ IsPredArchimedean F.Duration
```

The tag is interpreted by `IsZTime`, **not** by the bare `IsDiscrete` clause — that choice is
made deliberately and argued at `FrameProperty.lean:141` and `FrameClassValidity.lean:120-125`,
precisely to stop `soundness_ztime` silently widening the class. So the worry the question
raises — "a wider class of discrete orders" — is the one the definition was written to exclude.

**`D` is exactly `ℤ`.** `FormalSystem/Semantics/IntTransfer.lean:335`,
`validZTime_iff_validInt : ValidZTime φ ↔ ValidInt φ` — *machine-checked*, sorry-free. It runs on
`intIso : D ≃+o ℤ` (`Semantics/DurationClassification.lean:319`), the *additive* order
isomorphism; the order-only `orderIsoIntOfLinearSuccPredArch` is explicitly recorded as
insufficient, because durations add. Degenerate carriers are excluded by construction:
`TemporalOrder` (`Semantics/TemporalOrder.lean:83-93`) carries `[nontrivial : Nontrivial carrier]`
as a field, so the one-point duration group — on which `SuccOrder`/`PredOrder`/Archimedean would
hold vacuously — is not a `TemporalOrder` at all.

**Histories are exactly the bi-infinite walks.** `Semantics/IntNormalForm.lean:348`:

```lean
theorem mem_HF_iff_adjacent (F : FrameOver intOrder) [F.IsRegular] (f : ℤ → F.WorldState) :
    (∃ τ : WorldHistory F, τ.path = f) ↔ IsStepPath F f
```

*machine-checked*, sorry-free. `IsStepPath` is a bi-infinite `f : ℤ → WorldState` stepping
between consecutive times. Together with `taskRel_eq_iter` (`⇒_d` is the `d`-fold iterate of the
one-step relation at every `d : ℤ`), this is the mirror's "all bi-infinite walks of a digraph",
on the nose.

**Which frame axioms are residue over ℤ.** `Semantics/IntNormalForm.lean:434-456`,
`FrameOver.ofStep`, whose docstring tabulates the source of every field, and whose
`ofStep_isRegular` is *machine-checked*, sorry-free:

| Frame constraint | Source over ℤ |
|---|---|
| Compositionality | free — `iter_add` |
| reflection | free — `ofStepRel` is symmetric in its sign-guarded conjuncts by construction |
| Limit | automatic — `TaskFrame.limit_of_succOrder`, ℤ is a `SuccOrder` |
| **Seriality** | **the one genuine obligation** — exactly bi-seriality (`fwd`, `bwd`) |
| **Saturation** | `TaskFrame.saturation_of_finite` — **the carrier is finite** |

`ofStep`'s signature is `{W : Type} [Finite W] [Nonempty W]`. The finiteness is there for
Saturation and nothing else.

**The ⊡-language shares the tag but not the normalization.**
`FormalSystem/PlusLanguage/PlusValidity.lean:98` and `:111`:

```lean
def PlusValidIn (fc : ProofSystem.FrameClass) (φ : PlusFormula) : Prop :=
  PlusValidOnFrames fc.Sat φ
…
def PlusValidZTime (φ : PlusFormula) : Prop := PlusValidIn ProofSystem.FrameClass.ZTime φ
```

— the same `FrameClass.Sat`, so everything said above about the *frame class* transfers verbatim.
But there is no `plusValidZTime_iff_plusValidInt` anywhere in the tree, and the reason is
structural rather than incidental: `PlusLanguage/PlusTruth.lean:42` and `:261` both record that
`TruthCorr` — the generic relational transport that `truthAt_map` and hence
`validZTime_iff_validInt` are a one-line instance of — **is `Formula`-only**. The L⁺ carrier
normalization is therefore new work (generalize `TruthCorr` to `PlusFormula`, or run a direct
induction whose `stab` case quantifies over histories through a state), not an instantiation.

**The refuted small-model hypothesis, re-verified.** `Probe476.fmp_false`
(`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean:151`):

```lean
theorem fmp_false (cands : Formula → List IntPresentation) :
    ¬ (∀ φ : Formula, ¬ ValidZTime φ →
        ∃ P ∈ cands φ, ∃ w : Fin P.card, SatAtState P w φ.neg)
```

with witness `ψ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`, satisfiable in the ℤ-carrier shift-set frame and
satisfiable in no finite `IntPresentation` at any history and time. It is a refutation of the
**finite model property itself** at ZTime for the ⊡-free language — for *every* candidate list —
not merely of one candidate-generation scheme.

### External Resources

**Thomas 1997, the cited sentences.** Independently re-extracted from the source PDF with
`pdftotext`, not only read off the stored markdown:

> `Theorem 6.20 (Rabin Tree Theorem [Rab69]) The theory S2S is decidable.`
>
> `… the decidability S2S extends to tree models with arbitrary finite and even countable
> branching (such trees are easily embedded in the binary tree).`
>
> `Theorem 6.18 (Rabin Basis Theorem, cf. [Rab72]) For Rabin chain tree automata, the emptiness
> problem "T_ω(A) = ∅" is decidable, and any nonempty set T_ω(A) contains a regular tree (whose
> generating automaton B is obtained effectively from A).`
>
> `… if a formula of such a logic is satisfiable … then, by Rabin's Basis Theorem 6.18, also a
> regular tree model can be guaranteed. Such regular models originate from finite graphs (the
> generating automata).`

and the chapter's own abstract: "a self-contained proof of the 'Rabin Tree Theorem'".

The complexity remark, same chapter (§3, on the MSO-to-automaton conversion):

> `… the time complexity of any algorithm converting MSO-formulas (even FO[S,<]-formulas) to
> equivalent finite automata cannot be bounded by an elementary function` (attributed there to
> Meyer and Stockmeyer, via [AHU74]).

**A disambiguation hazard that must not be transferred.** The repository sub-index
`specs/literature-index.json` carries an entry `thomas_1997` whose hazard field reads
"provenance_fidelity: no_source_pdf — no PDF exists to verify against. Treat as
PROVISIONAL/orienting only; do not use for load-bearing claims." **That is a different
document**: `thomas_1997` is
`sources/thomas_1997/Thomas_1997_EF_Games_Composition_Monadic.md` (EF games / composition
method). The document cited here is `thomas_1997_languages_automata` =
`sources/thomas_1997_languages/Thomas_1997_Languages_Automata_Logic.md`, a separate directory with
its own 478 KB source PDF and `provenance_fidelity: verified_conversion`. Two Thomas 1997 entries,
one hazard, and the hazard attaches to the other one.

**Fidelity caveat on the citation, stated so it is not discovered later.** The conversion drops
`fi`/`fl` ligatures systematically ("nite" for "finite", "denable" for "definable") and renders
citation keys with a trailing bracket only ("Rab69]"). This is cosmetic and uniform; it affects no
quoted sentence's meaning, and every sentence quoted above was re-extracted from the PDF
independently. No mathematical symbol garbling of the kind recorded for `rabinovich_2014` was
observed in the cited passages, which are prose.

**Reynolds 2002 §6 (held), corroboration and two caveats.**

> `The propositional branching-time logics mentioned are (almost) all decidable. This follows from
> the decidability of the full monadic second-order theory of the class of all trees as shown in
> [12]. … The complexity of the procedure here is unclear.`
>
> `Interestingly, this decidability proof does not work for the Ockhamist logic without the
> no-trace-of-futurity assumption on valuations of atoms.`
>
> `… CTL* has a decision procedure of double-exponential time complexity [9].`

Two things follow. First, the held corpus independently confirms that the tree-MSO route yields
**no complexity bound** — the source says so in its own voice. Second, the no-trace-of-futurity
hypothesis is satisfied here (atoms are state-valued: report 03 §1.4), so the route is not blocked
on that count. The CTL* double-exponential figure is an *upper* bound for CTL*; CTL*'s lower bound
is not in the held corpus, so report 01 §2.4's CTL* embedding gives **no held lower bound** for
this language either.

### The Three Verdicts

#### Verdict 1 — Rabin's theorem: TIED TO A HELD SOURCE

**AFFIRMATIVE.** Cite as: Thomas, *Languages, Automata, and Logic* (1997), §6.3, Theorem 6.20
(Rabin Tree Theorem), with the countable-branching extension in the sentence immediately
following, and a self-contained proof of the theorem in §6.1-6.2. Corpus id
`thomas_1997_languages_automata`.

Three things make this a stronger result than "the citation exists":

1. The held source **proves** the theorem (game-theoretic route), so the tree is not depending on
   an unread 1969 paper.
2. The held source supplies the **ω-branching** case explicitly. Report 03 §1.3 step 5 needs MSO
   over the ω-branching tree, not S2S; the sentence after Theorem 6.20 covers "arbitrary finite
   and even countable branching".
3. The held source supplies the **method** of steps 3-4, not just the theorem of step 5: the
   unravel-into-a-labelled-tree, embed-prefix-preservingly-into-the-binary-tree, quantify-over-the-
   embedding's-range template is written out there for propositional modal logics.

What this does **not** establish, and must be said in the same breath: it replaces one *recalled*
ingredient with a *held* one. Steps 1-4 of report 03 §1.3 remain paper-level and uncompiled. The
decidability of the target is not thereby known; its provenance is repaired, its certainty is not.

#### Verdict 2 — `FrameClass.ZTime` vs. "exactly `D = ℤ`, all bi-infinite walks of a digraph"

**HOLDS as stated for the ⊡-free language, and is machine-checked. Two residues for the language
the decidability question is about.**

Holding, with landed evidence:

- *Exactly `D = ℤ`, not a wider class of discrete orders*: `validZTime_iff_validInt`. The tag is
  interpreted by `IsZTime`, not `IsDiscrete`, and the narrowing is deliberate and documented.
  `Nontrivial` is a `TemporalOrder` field, so no degenerate carrier sneaks in.
- *All bi-infinite walks of a digraph*: `mem_HF_iff_adjacent` plus `taskRel_eq_iter`. `H_F` over ℤ
  is exactly the bi-infinite step-paths, and the task relation is exactly the iterate of the
  one-step relation.
- *"Digraph" is the right word for the frame data*: of the four constraints, Compositionality and
  Limit are automatic over ℤ and reflection is free, so a `FrameOver intOrder` is a digraph plus
  the two residual conditions below.

Residue A — **Saturation on infinite carriers**. `ofStep` discharges Saturation from
`saturation_of_finite` and therefore carries `[Finite W]`. The MSO argument builds a *countable*
model (step 1) and passes to a *countable* cover (step 2); at those carriers Saturation is not
free in the tree. It is covered only by report 03 §1.2's universal-cover/oriented-forest argument
(*paper*, uncompiled). That argument is load-bearing in exactly the direction needed: it converts
"refutable somewhere in the wide class of doubly serial digraphs" into "refutable inside
`Sat .ZTime`", which is what lets the MSO decidability of the wide class descend to the narrow
one. Without it, decidability of the wider class does not by itself decide `ValidZTime`.

Residue B — **the ℤ-normalization is not proved for `PlusFormula`**, and this is the sharper of
the two. `PlusValidZTime` uses the same `FrameClass.Sat .ZTime`, so the *frame-class* half of the
assumption transfers verbatim and needs no new work. But `validZTime_iff_validInt` is stated for
`Formula`, and the generic transport it is an instance of (`TruthCorr`) is `Formula`-only by
construction. So for the language with the stability modal, "exactly `D = ℤ`" is currently a
reasonable expectation rather than a landed theorem.

Net: the mirror's assumption is **not** the defect the question anticipated. The repository's
class is, if anything, *narrower* than the mirror's (it adds Saturation), and the "wider class of
discrete orders" possibility is closed by a machine-checked theorem. The real gaps are the two
named above, and both are pre-existing rather than newly discovered.

#### Verdict 3 — a finite certificate from held literature

**NEGATIVE for a usable finite certificate, and the negative is stronger than "not obtained".**

Three findings, in order of decisiveness:

1. **A finite-model certificate is impossible, not merely unavailable.** `Probe476.fmp_false`,
   re-verified today: `ψ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` is satisfiable over the ℤ-shift-set frame
   and satisfiable in no finite `IntPresentation` at any history and time, for *every* candidate
   list. So the ZTime logic lacks the finite model property outright. This applies a fortiori to
   the language with `⊡`, since L embeds in L⁺ with truth preserved (`plusTruthAt_ofFormula`, the
   truth-transfer bridge named in `PlusValidity.lean`). Report 03's cautious "a regular tree does
   not *obviously* fold to a finite digraph" is therefore upgradable: in general it **cannot**.
2. **The held literature does supply a finite certificate — of the wrong shape to be inherited,
   but the right shape to imitate.** Thomas Theorem 6.18 guarantees that a nonempty Rabin-chain
   tree-automaton language contains a *regular* tree whose generating finite automaton is obtained
   effectively; combined with Theorem 6.19, a satisfiable MSO sentence has a finitely *generated*
   model. Thomas himself calls the consequence "the so-called finite model property", but what is
   finite there is the *generator*, not the model. That is exactly the distinction `fmp_false`
   turns on, and exactly the distinction the existing BiLasso device already respects.
3. **Nothing held closes the gap for this language, and no bound is inherited.** The MSO
   translation of this language's truth clauses (report 03 §1.3 step 4) is performed nowhere held,
   so the automaton whose emptiness would carry the certificate does not yet exist. On complexity:
   Thomas records the MSO-to-automaton conversion as **not elementarily bounded** (Meyer-Stockmeyer),
   and Reynolds 2002 §6 says of the tree route "The complexity of the procedure here is unclear."
   On hardness: report 01 §2.4's CTL* embedding is *paper*, and the held corpus carries CTL*'s
   double-exponential *upper* bound but not its lower bound — so there is no held lower bound
   either.

Operative answer to the question as posed: **no**. The certificate design must supply its own
finiteness argument. It inherits a target shape (finite presentation of an infinite regular
model), a closed door (finite models, by `fmp_false`), and no bound in either direction.

### Recommendations

1. **Discharge report 623's recommendation 3.** The MSO argument may now be cited in library
   documentation, in this form: *decidability at ℤ-time for the language with `⊡` is a paper-level
   argument (report 03 §1.3) resting on Rabin's Tree Theorem, for which the held source is Thomas
   1997 §6.3 Theorem 6.20; four of the argument's five steps are not machine-checked.* Citing the
   theorem is now sanctioned; citing the *conclusion* as established is not.
2. **Repair the archived `fmp_false` probe, or annotate it.** The repository cites
   `Probe476.fmp_false` as machine-refuted in at least
   `FormalSystem/Metalogic/Decidability/WitnessFamily.lean:39` and in the records the
   documentation-recording task has just corrected. As stored, the probe reports `sorryAx`. Either
   land the one-term repair in the archived evidence file, or add a header note recording it. The
   repair is the whole of the change (line 70):

   ```lean
   -- before (no longer elaborates; #print axioms reports sorryAx)
   have := hv S.frame (TaskFrame.isZTime_of_instances _) S.model (S.hist (0:ℤ)) (0:ℤ)
   -- after (re-verified: [propext, Classical.choice, Quot.sound])
   have := hv S.frame ⟨S.frame_isRegular, TaskFrame.isZTime_of_instances _⟩ S.model (S.hist (0:ℤ)) (0:ℤ)
   ```

   This is not a defect in the result. It is drift: the probe predates `Sat .ZTime` becoming the
   conjunction `IsRegular ∧ IsZTime`, and passes a bare `IsZTime` witness where a pair is now
   required. Note this dispatch changed only a scratch copy; the archived file is untouched.
3. **Do not start the downstream design tasks on a "known decidable" premise.** Verdict 3 already
   obliges them to supply their own finiteness argument, so the decidability question does not
   gate them technically — but it does gate how their goals should be stated. Their framing should
   be "construct a decision procedure", not "formalize a known-decidable target".
4. **If the ℤ-normalization for L⁺ is wanted, the shape of the work is known.** Generalize
   `Semantics.TruthCorr` from `Formula` to `PlusFormula` (the `stab` case quantifies over
   histories through a state, which `Aligned` supports in both directions since it comes from an
   isomorphism), then `plusValidZTime_iff_plusValidInt` follows the existing
   `validZTime_iff_validInt` proof line for line. This is a sorry-free target; nothing here
   suggests otherwise.
5. **Aim the certificate design at finite presentation, not finite models.** Thomas Theorem 6.18
   is the template worth reading before the witness-structure redesign: a finite generating
   automaton for an infinite regular model is exactly the object `fmp_false` leaves available.

## Decisions

- **Verdict 1 recorded as affirmative on the strength of one held source.** A second corroborating
  held source (Reynolds 2002 §6) exists but routes through Gurevich-Shelah, which is *not* held;
  it is reported as corroboration, not as an independent tie.
- **`thomas_1997`'s hazard is judged not to apply**, on the evidence that the two entries name
  different files in different directories, and that the cited document has a source PDF that was
  read during this dispatch.
- **Verdict 3 is reported as negative for the operative question and positive for a secondary
  one**, rather than flattened to a single word. Reporting only "no finite certificate" would have
  discarded the Basis Theorem finding, which is the most directly usable thing this dispatch
  found for the downstream design.
- **The probe bit-rot is reported as a finding rather than silently repaired in place.** The
  dispatch forbids changes under `FormalSystem/` and `Tests/`; `specs/archive/` is neither, but
  editing an archived evidence file is outside a research dispatch's remit and would also collide
  with the shared-working-tree concurrency in effect. Recommendation 2 hands it on.
- **No claim of decidability is made.** Verdict 1's affirmative concerns provenance only.

## Risks & Mitigations

- **Risk**: Verdict 1 is read as "the target is now known decidable." **Mitigation**: stated three
  times, in the summary, in Verdict 1 itself, and in Recommendation 1 — provenance repaired,
  certainty unchanged; four of five steps remain uncompiled.
- **Risk**: the `thomas_1997` hazard is later applied to the wrong entry and the citation is
  pulled. **Mitigation**: the two entries, their paths, and their differing fidelity fields are
  recorded side by side in External Resources above.
- **Risk**: someone re-checks `Probe476.fmp_false`, sees `sorryAx`, and concludes the repository's
  fmp refutation is unsound. **Mitigation**: Recommendation 2 records the cause and the exact
  repair, and the repaired axiom list.
- **Risk**: Verdict 2's residue B (no L⁺ carrier normalization) is mistaken for a defect in the
  ZTime tag. **Mitigation**: the tag is shared between L and L⁺ (`PlusValidIn` is `PlusValidOnFrames
  fc.Sat`); only the normalization theorem is language-specific, and Recommendation 4 sizes the
  work.
- **Risk**: report 03 §1.2 (Saturation idle at ZTime) is treated as landed because this report
  cites it. **Mitigation**: it is labelled *paper* at every mention, and its load-bearing direction
  is spelled out in Residue A.

## Tactic Survey Results

Not applicable — no proof goals were attempted in this dispatch, so no tactic survey was
performed. The verification work done instead was axiom-checking of landed theorems and one probe
re-run; it is recorded below.

| Declaration | Method | Result |
|---|---|---|
| `FormalSystem.Semantics.validZTime_iff_validInt` | `lean_verify` | `[propext, Classical.choice, Quot.sound]`, no warnings |
| `FormalSystem.Semantics.FrameOver.mem_HF_iff_adjacent` | `lean_verify` | `[propext, Classical.choice, Quot.sound]`, no warnings |
| `FormalSystem.Semantics.FrameOver.ofStep_isRegular` | `lean_verify` | `[propext, Classical.choice, Quot.sound]`, no warnings |
| `Probe476.fmp_false` (as archived) | `lake env lean` | **fails**: `synthInstanceFailed` at line 70; `[propext, sorryAx, Classical.choice, Quot.sound]` |
| `Probe476.fmp_false` (scratch copy, one-term repair) | `lake env lean` | `[propext, Classical.choice, Quot.sound]` |

## Context Extension Recommendations

- **Topic**: distinguishing *finite model* from *finite presentation* in this development's
  decidability vocabulary.
  **Gap**: `fmp_false` refutes the former; the BiLasso device, the witness families, and Thomas's
  Basis Theorem all supply the latter. Existing documentation uses "finite model property" for
  both, and Thomas 1997 does too, which is how the conflation propagates.
  **Recommendation**: a short section in
  `.claude/context/project/lean4/domain/` (or the `Decidability/README.md` in-tree) fixing the two
  terms and recording that `fmp_false` closes one and leaves the other open.
- **Topic**: corpus entries that share an author-year id stem.
  **Gap**: `thomas_1997` and `thomas_1997_languages_automata` differ in fidelity, and the sub-index
  carries a hazard for only one of them. A reader matching on "Thomas 1997" gets the wrong answer
  half the time.
  **Recommendation**: note in `context/project/literature/domain/literature-index.md` that ids are
  matched whole, never by stem, and that a hazard attaches to an id rather than to an author-year.

## Appendix

**Searches and probes used.**

- `grep` over `specs/` and the repository for `Rabin`, `MSO`, `monadic`, `fmp_false`,
  `Probe476`, `FrameClass`, `IsZTime`, `ofStep`, `TruthCorr`.
- Python scan of `~/Projects/Literature/index.json` (11947 entries) for
  `S2S|SnS|SωS|infinite tree|second-order.*tree|Rabin.*1969|decidability of the (monadic|second)`
  over id/title/summary/bib_key/reason/authors/path — 4 hits, of which
  `thomas_1997_languages_automata` is the one that carries the theorem.
- `pdftotext` re-extraction of `Thomas_1997_Languages_Automata_Logic.pdf` to confirm the four
  quoted passages against the source rather than against the stored markdown.
- `lean_verify` axiom checks (table above) and two `lake env lean` runs of the `fmp_false` probe
  (as-archived, and a scratch copy with the one-term repair).

**Files read, by path.**

- `FormalSystem/Semantics/FrameClassValidity.lean` (`FrameClass.Sat`, `sat_intro`)
- `FormalSystem/Semantics/FrameProperty.lean` (`IsDiscrete`, `IsZTime`)
- `FormalSystem/Semantics/TemporalOrder.lean` (`structure TemporalOrder`, the `Nontrivial` field)
- `FormalSystem/Semantics/DurationClassification.lean` (`intIso`, `archimedean_of_succ`)
- `FormalSystem/Semantics/IntNormalForm.lean` (`mem_HF_iff_adjacent`, `ofStep`, the field table)
- `FormalSystem/Semantics/IntTransfer.lean` (`truthAt_map`, `validZTime_iff_validInt`)
- `FormalSystem/Semantics/TaskFrame.lean` (`FrameOver.IsRegular` and its four constraints)
- `FormalSystem/Semantics/ShiftSet.lean` (`frame_isRegular`, used in the probe repair)
- `FormalSystem/PlusLanguage/PlusValidity.lean`, `FormalSystem/PlusLanguage/PlusTruth.lean`
- `FormalSystem/ProofSystem/Axioms.lean` (`inductive FrameClass`, the order and its regression
  `example`s)
- `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`

**Literature passages cited.**

- `~/Projects/Literature/sources/thomas_1997_languages/Thomas_1997_Languages_Automata_Logic.md`
  — Theorem 6.18 (Basis Theorem), Theorem 6.20 (Rabin Tree Theorem), the countable-branching
  sentence, the modal-logic transfer paragraph, the non-elementary conversion remark; and the
  chapter abstract's self-contained-proof claim.
- `~/Projects/Literature/sources/reynolds_2002_axioms_for_branching_time/chunk_0024.md` — §6,
  "Decision procedures".
