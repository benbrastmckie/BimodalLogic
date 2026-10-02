# Research Report: Task #707

**Task**: 707 - ztime_no_finite_carrier_fmp_context_note
**Started**: 2026-10-02T06:22:04Z
**Completed**: 2026-10-02T07:05:00Z
**Effort**: ~45 minutes (research-only round; no Lean work, no probe compiled, no file outside `specs/` touched)
**Dependencies**: None blocking. Inputs: the 706 round-1 report and its probe; the 703 round-2 report and the 703 round-7 summary (703 is `[COMPLETED]`); the literature sub-index entries for HWZ 2000, Krommes 2020, GKWZ 2003, HVV 2004, HKKM 2019; the GKWZ source PDF
**Sources/Inputs**: - Codebase (`FormalSystem/Semantics/{TaskFrame,IntNormalForm}.lean`, `FormalSystem/Metalogic/Decidability/{BiLasso/README.md,PlusSlicedCertificate.lean,PlusSlicedCertificate/{Frame,Sound}.lean}`, `docs/theorem-index.md`); `specs/706_lplus_finite_model_property_and_completeness/{reports/01_lplus-finite-model-property-research.md,probes/NoFiniteCarrierModel.lean}`; `specs/703_lplus_compression_and_completeness/{reports/02_semantics-first-compression-research.md,summaries/07_lplus-sliced-certificate-and-completeness-summary.md}`; `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`; the deployed logic context (`.claude/context/project/logic/{README.md,domain/*.md,standards/literature-fidelity-policy.md}`), its source store (`~/.config/nvim/agent-system/extensions/formal/`), and `.claude/context/index.json`; the literature corpus under `~/Projects/Literature/sources/` (five documents, read chunk by chunk); the GKWZ source PDF at `~/Documents/literature-staging/gabbay_2003/`, extracted with `pdftotext -layout`
**Artifacts**: - `specs/707_ztime_no_finite_carrier_fmp_context_note/reports/01_ztime-no-finite-carrier-fmp.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Everything the note must carry is already written down and verified; this round locates it,
  checks it, and says where the note goes.** The machine-checked source is
  `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`
  (seven declarations, axioms `[propext, Classical.choice, Quot.sound]`, no `sorry`). Its
  theorems are **not** landed as library declarations — `grep` for `no_finite_carrier`,
  `not_finite_carrier_fmp`, `Probe706` under `FormalSystem/` and `docs/` returns nothing, and
  706 is still `[RESEARCHED]` — so the note cites the probe, exactly as the dispatch says.
- **The design rule is no longer only a rule; since 703 closed it is a landed object.**
  `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/` presents a frame on `ℤ × Fin n`
  via `FrameOver.ofSlicedStep`, proves the carrier infinite
  (`FrameOver.ofSlicedStep_not_finite_worldState`, restated as
  `PlusSlicedCertificate.frame_worldState_not_finite`), and its module header already states
  the finite-carrier obstruction in prose. The note should name these as the rule's embodiment,
  so the next reader finds the code and not just the warning.
- **Both GKWZ theorem numbers verify against the source PDF.** Theorem 5.28 (printed p. 244):
  for `L` in `{K, T, D, K4, S4, KD45, S5}` (n-fold), the decision problem for `L × S5` is in
  coN2EXPTIME — a corollary of Theorem 5.27, which gives `L × S5` the **2-exponential abstract
  fmp**. Theorem 5.32 (printed p. 246): if `C` is a class of transitive frames one of which has
  an ascending ω-type chain, and `L` has an infinite frame with a point seeing every other
  point, then `Log C × L` lacks the **product** fmp; the book's own lead-in reads "the next
  theorem shows that products like K4 × S5 and S4 × S5 do not enjoy the product fmp". So the
  OCR extract is accurate here, the "transitive frames with an ascending ω-type chain" wording
  is the theorem's actual hypothesis (K4 × S5 is its instance), and Krommes's second-hand
  citation is correct. The note may cite both numbers, with page numbers.
- **The one substantive nuance the dispatch did not have:** K4 × S5 lacks the *product* fmp but
  *has* the abstract fmp (5.27), and that is what its decidability rests on. This repository has
  no such relaxation — `PlusValidZTime` quantifies over regular ℤ-frames only, and the refuted
  statement is the fmp for that very class — so the published remedy that applies is the
  *other* GKWZ route, stated on p. 234: "If L does not enjoy the fmp, then we can try to show
  that it is characterized by (in general) infinite models having a certain 'regular structure',
  say, constructed from repeating finite pieces." That sentence, and HWZ's quasimodel as its
  concrete form, is the note's citation for the design rule.
- **The second hazard is real and documented:** Krommes 2020, Theorem 1.1, K4 × S5 and S4 × S5
  are EXPSPACE-complete, listed on the same page as their failure of the product fmp (chunk 33:
  "both lack the finite product model property [Thm 5.32], but are decidable"). The note must
  say in one sentence that FMP failure is not an undecidability result.
- **The time-sliced diagnosis is confirmed from the 703 round-2 text itself**: its §1.3 says
  "the right joint object has period one and no time origin. By S1 and S2 the model is a
  time-homogeneous graph", which `θ` forbids. Its own context-extension section already asked
  for a `ztime-graph-semantics.md`; that file still does not exist, so the sliced correction
  folds into this note as a section.
- **Where the note goes.** Not under `.claude/`: the deployed tree is a disposable artifact. The
  deliverable is `~/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/ztime-no-finite-carrier-fmp.md`,
  plus one `index-entries.json` entry and one README line in the same source store, then
  `bash .claude/scripts/deploy-headless.sh`. The note must not cite task numbers.

## Context & Scope

This is the research phase of a `markdown` task whose deliverable is a single context note.
The dispatch names the content (from the 706 report's Q1.1/Q1.2 and the 703 round-2 report's
graph-semantics recommendation), the literature to cite (five documents), one verification
obligation (GKWZ Theorems 5.28 and 5.32 against the source PDF), and one prohibition (no Lean
work). Research therefore had four jobs:

1. confirm the content against its primary sources and the current tree (in particular, what
   703 landed after the 706 report was written);
2. read the five literature sources far enough to cite them accurately, with fidelity labels;
3. discharge the GKWZ verification;
4. establish the mechanics of writing a context note in this repository (source store, index,
   README, deploy, the task-reference rule, sibling concurrency).

Out of scope: proving anything, landing the probe's theorems, revising any plan.

### Verification labels

| Label | Meaning |
|---|---|
| **[checked]** | Proved in a probe that compiles sorry-free; axioms listed in the source |
| **[landed]** | A declaration in the tree, cited by name and file |
| **[archived]** | A declaration in an archived evidence probe guarded by `scripts/check-evidence-probes.sh` |
| **[verified-pdf]** | Read in the GKWZ source PDF's `pdftotext` output, not only the OCR extract |
| **[literature]** | Read from a corpus chunk whose sub-index entry is `unverified_conversion`; quoted text re-checked for sense but not against a PDF |
| **[argued]** | A paper claim of this report, not machine-checked |

## Findings

### Codebase Patterns

**F1. The machine-checked source, and its status in the tree.** **[checked]**
`specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`
(349 lines) proves, with `#print axioms` giving `[propext, Classical.choice, Quot.sound]`:

| Declaration | Statement |
|---|---|
| `Probe706.θ_eq_ofFormula` | `θ = ofFormula ψL` (`decide`) — the witness is `⊡`-free |
| `Probe706.not_plusValidZTime_neg_θ` | `¬ PlusValidZTime θ.neg` |
| `Probe706.no_finite_carrier_sat` | no regular ℤ-frame with `Finite WorldState` satisfies `θ` at any history and time |
| `Probe706.no_ofStep_sat` | the same at `FrameOver.ofStep R fwd bwd` for any `[Finite W] [Nonempty W]` |
| `Probe706.not_finite_carrier_fmp` | the finite-carrier fmp statement for L⁺ over ℤ-time is false |
| `Probe706.not_plusValidZTime_neg_θ'`, `no_finite_carrier_sat'`, `not_finite_carrier_fmp_fragment` | the same for `θ'` in the CTL-like fragment |

The probe's own header gives the argument in the order the dispatch wants it recorded. None of
these names exist under `FormalSystem/` or in `docs/theorem-index.md` (grep, this round); 706's
recommendation 2 (land them beside `PlusWitnessFamily/Incompleteness.lean`) has not been
executed and 706 is `[RESEARCHED]`. The note therefore cites the probe file and its compile
command (`lake env lean <path>` from the repository root) as the source, and should say that
the theorems are probe-level, not library-level, so a later reader who lands them updates the
note.

**F2. The L-side twin.** **[archived]** `Probe476.fmp_false` in
`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
refutes the finite-`IntPresentation` candidate-list hypothesis for `Formula` with the same
witness `ψ`; its header records the 2026-09-27 drift repair and re-verification. The only
in-tree prose was `FormalSystem/Metalogic/Decidability/BiLasso/README.md` lines 25-37 ("the
remaining route to decidability is the presentation-free witness family, not a finite
presentation"). That README passes `check-task-references.sh` while citing the archived probe's
`specs/archive/476_...` path, which confirms that a *path* containing a task-directory number
is not a forbidden citation (the pattern is `task(s) <sep> N`, see F9).

**F3. The design rule is landed, and the note should say so.** **[landed]** Since the 706
report was written, 703 closed (summary
`specs/703_lplus_compression_and_completeness/summaries/07_lplus-sliced-certificate-and-completeness-summary.md`).
The relevant landed facts, all under `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/`:

- `Frame.lean`: `G.frame h := FrameOver.ofSlicedStep G.stepRel (G.stepRel_fwd h) (G.stepRel_bwd h)`
  on carrier `ℤ × Fin G.n`; `frame_worldState_not_finite` restates
  `FrameOver.ofSlicedStep_not_finite_worldState`; `mem_HF_iff_slicedPath` is
  `FrameOver.ofSlicedStep_mem_HF_iff` at `G`. The file's header says "`FrameOver.ofSlicedStep`
  is therefore not a convenience over `FrameOver.ofStep`; it is the only" construction that fits.
- `Sound.lean` lines 29-35 state the obstruction in prose: "There is a `⊡`-free ℤ-time
  non-validity that no `FrameOver.ofStep` frame satisfies at all, so a certificate presenting a
  finite-carrier frame cannot certify it; the finite data lives in the *fibres*".
- `PlusSlicedCertificate.lean`'s module docstring has a bullet "**the finite carrier.**" saying
  the same, and names `onePointCertificate` as the finite-graph special case "exhibited rather
  than asserted".
- `docs/theorem-index.md` rows 167 and 171: `not_exists_plusCertifies_pumpTarget` (the sharing
  class is incomplete, no bound repairs it) and
  `WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` (every ℤ-time
  non-validity of an embedded `Formula` admits an accepted sliced certificate), both `pcq
  pinned:C2`.

So the note's rule — a ℤ-time certificate class must present an infinite, finitely presented
carrier — has a concrete in-tree referent: `FrameOver.ofSlicedStep` on `ℤ × Fin n`, with
`TaskFrame.saturation_of_fib_finite` (`Semantics/TaskFrame.lean:2222`) discharging *Saturation*
from finite fibres and `TaskFrame.limit_of_succOrder` (`TaskFrame.lean:1591`) discharging *Limit*.
`FrameOver.ofStep` (`Semantics/IntNormalForm.lean:456`) requires `[Finite W]` and routes
*Saturation* through `saturation_of_finite`; that `[Finite W]` requirement is the type-level
reason it can never be the certificate's frame.

**F4. The pumping argument's ingredients, by name.** **[landed]**
`FrameOver.mem_HF_iff_adjacent` (`IntNormalForm.lean:348`, "`H_F` over ℤ is exactly the set of
bi-infinite step-paths") and `FrameOver.worldHistoryOfStepPath` (`:323`) turn the pumped cycle
into a history; `Finite.exists_ne_map_eq_of_infinite` (Mathlib,
`Data/Fintype/Pigeonhole.lean`) is the pigeonhole; `plusBox_const` is the history- and
time-independence of `□` that lets the second conjunct be read at every time; the positive half
uses `ShiftSet` with carrier `ℤ`, `sh w d = w + d`, `p` at `0` only, and
`ShiftSet.total_eq_orbit` for the `⊡` collapse in the fragment variant. All are as the 706 report
Q1.1 lists them; nothing has moved.

**F5. The time-sliced diagnosis, from the 703 round-2 text.** The round-2 report's §1.3 reads:
"the right joint object has **period one and no time origin**. By S1 and S2 the model is a
time-homogeneous graph. A shared period larger than one is an artefact of listing histories as
rows against absolute time." Its S1-S5 (§1.1) are all time-homogeneous statements: S1 (histories
are the step paths), S2 (shift invariance), S3 (`⊡` is state-determined), S4 (fusion and limit
closure), S5 (type-preserving pasting). None is false; what they omit is that a *countermodel*
need not be time-homogeneous, and `θ`'s countermodel cannot be — it needs a time at which `p`
happens once. The 706 report's Q1.2 states the diagnosis in one sentence ("A countermodel to
`θ.neg` must have a time at which something happens once, so its state space cannot be
time-homogeneous and finite"); the note records it with the S1-S5 list so the reader sees which
true facts led there. The round-2 report's own §2.5 (the limit-closure/fairness pumping that
refutes the sharing class) is a *different* obstruction — all-threads fulfilment — and the note
should keep the two apart in one sentence: the carrier obstruction is about *size*, the
fulfilment obstruction is about *which threads must fulfil*; 703 fixed both, by `ℤ × Fin n` and
by liveness-as-fixpoint respectively (`PlusSlicedCertificate.lean` header, two bullets).

**F6. The 703 round-2 context recommendation is still open.** Its "Context Extension
Recommendations" asked for `context/project/logic/domain/ztime-graph-semantics.md` (citing
`mem_HF_iff_adjacent`, `ofStep`, `plusTruthAt_timeShift`, `stab_state_only`, `paste`) and a
`limit-closure-and-fairness.md`. Neither exists in the deployed tree or the source store (`ls`
this round). The dispatch folds the graph-semantics recommendation into this note *with* the
sliced correction; the fairness note remains a separate gap (see Context Extension
Recommendations).

### External Resources

**F7. HWZ 2000 — the quasimodel over `⟨ℤ, <⟩`.** **[literature]** Sub-index fidelity:
`unverified_conversion` via the `pdftotext` last-resort tier; known artifact: angle brackets
dropped (`hf, Ri` for `⟨f, R⟩`). The PDF is present in the source directory
(`hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl.pdf`) for spot checks. What the
chunks say, read directly:

| Object | Where | Content (paraphrased from the chunk) |
|---|---|---|
| type | Def. 5 (chunk 19) | boolean-saturated subset of `subₓ φ` |
| state candidate | Def. 6 (chunk 20) | a set `T` of types agreeing on `sub₀ φ`, plus indexed types for constants; "realizable" if some structure realises it; `♯(φ)` bounds the number of realizable candidates |
| state function | Def. 10 (chunk 21) | a map `f` from the flow `W` to realizable state candidates |
| run | Def. 11 (chunks 21-22) | `r(w) ∈ T_w`, with the `U` and `S` clauses holding along `r` |
| quasimodel | Def. 12 (chunk 22) | `⟨f, R⟩`, `R` a set of runs, every type in every `T_w` on some run; Theorem 14: satisfiable in a model on `F` iff satisfied in a quasimodel over `F` |
| splice | Lemma 17 (chunk 27) | if `f(n) = f(m)`, `n < m`, then `f^{≤n} ∗ f^{>m}` with the spliced runs is again a quasimodel |
| bounded realisation | Lemma 21 (chunk 30) | repeated quasistates are deleted via Lemma 17 until every `U`-formula is realised within a bounded number of steps |
| ultimately periodic form | Lemma 23, Theorem 24 (chunks 31, 33) | `φ` satisfiable over `⟨ℕ, <⟩` iff some `f₁ ∗ f₂^ω` with `|f₁| ≤ ♯(φ)` and `|f₂|` bounded satisfies three checkable conditions |

The introduction (chunk 7) gives the three routes: (1) express "a quasimodel satisfying `φ`
exists" in monadic second-order logic over the flow and use Büchi/Rabin — covers `⟨ℕ, <⟩`,
`⟨ℤ, <⟩`, `⟨ℚ, <⟩`, non-elementary; (2) the explicit, elementary `⟨ℕ, <⟩` analysis above; (3)
a composition method for `⟨ℝ, <⟩` with finite domains. `⟨ℤ, <⟩` is in scope throughout (chunks
4, 7, 14, 25 "The case of `⟨ℤ, <⟩` is similar", 43, 76, 81). The sub-index's relevance mapping
(state candidate = slice/fibre, state function = per-slice labelling, run = target path,
quasimodel = time-sliced certificate, Lemma 17 = the pumping/splice, periodic state function =
tail stability) is consistent with the chunks as read; the note can carry that table with a
"correspondence, not identity" caveat — HWZ's object is first-order temporal and has no `□`/`⊡`.

**F8. Krommes 2020 — FMP failure is not undecidability.** **[literature]** Same conversion
tier and caveat as HWZ. Theorem 1.1 (chunk 5): "The logics K4 × S5, S4 × S5, and SSL are
EXPSPACE-complete", answering Marx's conjecture restated as GKWZ Problem 6.67. Chunk 33's
transfer-results list has the sentence the note needs verbatim in spirit: "The logics K4 × S5
and S4 × S5 both lack the finite product model property [61, Theorem 5.32], but are decidable.
In fact, they are in coN2EXPTIME [61, Theorem 5.28]." Chunk 38 adds the sharp form: "there
exists an X × S5-satisfiable formula φ such that any X × S5-product model of φ is infinite [61,
Theorem 5.32]", against the doubly-exponential *commutator* model that always exists [61,
Theorem 5.27].

**F9. GKWZ 2003 — verification of 5.28 and 5.32 against the source PDF.** **[verified-pdf]**
The sub-index entry is `unverified_conversion` and the source directory holds no PDF, but the
global index's `metadata.json` records
`source_path: /home/benjamin/Documents/literature-staging/gabbay_2003/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics.pdf`
(28 MB, present). `pdftotext -layout` of that file (37,874 lines, scratchpad) gives:

- Printed p. 244, after Theorem 5.27 ("For every logic L in the list K_n, T_n, D_n, K4_n,
  S4_n, KD45_n, S5_n, and every n ≥ 1, the product L × S5 has the 2exponential (abstract)
  fmp"): "**Theorem 5.28.** Suppose L ∈ {K_n, T_n, D_n, K4_n, S4_n, KD45_n, S5_n}. Then the
  decision problem for L × S5 is in coN2EXPTIME." Followed by: "Note, however, that all these
  are about products where one of the components is S5. No filtration argument is known to the
  authors that works for other types of products."
- Printed p. 246: "We have already seen in Section 5.2 that by the quasimodel technique one can
  show not only the fmp, but the stronger product fmp for S5 × S5 ... On the other hand, the
  next theorem shows that products like K4 × S5 and S4 × S5 do not enjoy the product fmp." Then
  the definitions of *infinite ascending chain* and *ascending ω-type chain* ("FrS5 contains
  frames having infinite ascending chains, but none of them have ascending ω-type chains"),
  and: "**Theorem 5.32.** Let C be a class of transitive frames at least one of which contains
  an ascending ω-type chain. Suppose also that L is a Kripke complete unimodal logic having an
  infinite frame (W, R) with a point x ∈ W such that xRy, for all y ∈ W, y ≠ x. Then Log C × L
  does not have the product fmp." The proof's countermodel puts `p` true exactly on the
  diagonal `{(x_n, y_n) : n < ω}` of the product of an ω-type chain with an infinite `L`-frame;
  Figure 5.9's caption: "φ is not satisfiable in any finite product frame, where the first
  component is transitive." The proof formula itself is OCR-garbled in both the extract and the
  `pdftotext` output and must **not** be transcribed into the note.

Conclusions for the note: (i) both numbers are correct as Krommes cites them, and the extract's
"transitive frames with an ascending ω-type chain" wording is the theorem's genuine hypothesis
rather than damage; (ii) the relevant distinction is **product fmp versus abstract fmp**: K4 × S5
loses the former (5.32) and keeps the latter (5.27), and 5.28's bound comes from 5.27. This
repository's refuted property is the fmp relative to regular ℤ-frames — the only frames
`PlusValidZTime` ranges over — so there is no abstract-frame relaxation to retreat to; what
survives is the finitely presented infinite carrier. (iii) **[argued]** The 5.32 countermodel
(something true exactly once along an ω-chain, so that any finite quotient repeats and breaks
it) is the same device as `θ`; the note may say "structurally the same trick" but should not
claim more, since the formula could not be read.

Two further GKWZ passages belong in the note, both **[verified-pdf]** and on printed pp. 234
and 236: "If L does not enjoy the fmp, then we can try to show that it is characterized by (in
general) infinite models having a certain 'regular structure', say, constructed from repeating
finite pieces" and "we may be bound to deal with infinite models. The question then is how to
represent these infinite models as 'regular structures of repeating finite pieces,' if this is
at all possible." That is the design rule in print, two pages before the quasimodel is
introduced for products.

**F10. GKWZ Chapter 11 — the quasimodel method in book form, unmined.** **[literature]**
`metadata.json` records `ingested_at: 2026-08-18T23:36:01Z`, 758 chunks (the dispatch's
"acquired 2026-08-26" is the sub-index registration date, not the global ingest; either way it
predates every certificate-design round). Occurrence counts this round: `grep -c -i quasimodel`
over the chunk files sums to 244 lines in GKWZ against 108 in HWZ (the dispatch's 124 vs 30 are
FTS chunk counts; the ratio is the same). The chapter's content, by chunk: §11.3 "Embedding into
monadic second-order theories" (printed pp. 473-479) defines the K-basic structure, state
function, run, coherent and saturated run, and K-quasimodel (chunks 487-488), proves Lemma 11.22
(satisfiable iff a K-quasimodel exists) and Theorem 11.21 by translating "a K-quasimodel exists"
into MSO (chunk 490); §11.4 opens with "the idea in the elementary decidability proofs is to show
that every quasimodel for a given ... sentence can be converted into another quasimodel for φ
which has a 'periodical' state function, with the period being of some appropriately bounded
length" (chunk 493), and its Lemmas 11.27 and 11.29 are HWZ's Lemmas 17 and 21 restated
(chunks 497-498). §13.2's Theorem 13.6 (chunk 589) gives the MSO route for PTL × S5 and PTL ×
KD45, and §5.2 (chunk 264) explains when a *finite* quasimodel yields a finite product model and
when "quasimodels themselves are usually infinite (since the frame can be infinite)". The
diagnosis the dispatch wants recorded holds: the technique was in the corpus the whole time.

**F11. HVV 2004 — what it actually supports.** **[literature]** Fidelity:
`unverified_conversion` via the column-clustering fallback. The abstract is about
*axiomatizability*: four parameters (unique initial state, synchrony, perfect recall, no
learning), and "Not all settings of these parameters lead to recursively axiomatizable logics".
The *complexity* claims the dispatch attributes to it are in its §2 summary of [HV89, HV88a]
(chunk 2: "the complexity of these logics is completely characterized; ... the subtle interplay
of the parameters can have a tremendous impact on complexity"; chunk 12, Table 1: classes
ranging up to nonelementary time `ex(ad(φ)+1, c|φ|)`, Π¹₁ and co-r.e., the last two meaning "no
recursive axiomatization"). The note should cite HVV 2004 §2/Table 1 as the summary and name
Halpern–Vardi 1989 as the origin, and should describe the relevance accurately: an S5-like
modality over a discrete linear flow, with the perfect-recall/no-learning interactions as the
knob that moves the problem from PSPACE to non-r.e.

**F12. HKKM 2019 — what it bounds.** **[literature]** Same fallback tier. Abstract: Diff × Diff
is non-finitely axiomatisable but axiomatisable by infinitely many Sahlqvist axioms; "the first
examples of products of finitely axiomatisable modal logics that are not finitely axiomatisable,
but axiomatisable by explicit infinite sets of canonical axioms". Relevance is by analogy only:
the 703 round-2 report's Part 1 is titled "The semantics, which is not a product logic", and its
§1.2 records that GKWZ's product quasimodels "presuppose commutativity and Church-Rosser", which
the stability modal lacks. The note should cite HKKM as "what an axiomatisation of a product-like
system can look like" and say in the same sentence that this logic is not a product.

**F13. The vocabulary of the fact.** The two readings the note guards against are both one
sentence each: "the finite-carrier fmp fails, so a finite graph with a large enough `n` will do"
(wrong in kind — `no_ofStep_sat` has no `n`), and "the fmp fails, so decidability is hopeless"
(wrong by Krommes/GKWZ 5.28). A third, which the GKWZ reading surfaced, is "retreat to an
abstract fmp" — unavailable here because the validity notion is tied to regular ℤ-frames.

### Mechanics of the deliverable

**F14. Where the file goes.** `.claude/rules/source-store-deploy-boundary.md` applies: the
deployed `.claude/context/project/logic/domain/` is regenerated from the formal extension's
source store. `.claude-extensions.json` names `source_dir` per extension; the formal extension's
is `/home/benjamin/.config/nvim/agent-system/extensions/formal`, and its
`context/project/logic/domain/` holds the same fifteen files as the deployed copy
(`frame-constraint-landscape.md` is the most recent, committed as "Add lean, logic and
literature context docs written from consumer-repo work"). The deliverable is therefore:

1. `~/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/ztime-no-finite-carrier-fmp.md`;
2. one entry appended to `~/.config/nvim/agent-system/extensions/formal/index-entries.json`,
   in the shape of the `frame-constraint-landscape.md` entry (`path`, `summary`, `category:
   "domain"`, `line_count`, `load_when.agents: ["logic-research-agent", "formal-research-agent"]`,
   `load_when.task_types: ["logic", "formal"]`, `domain: "project"`, `subdomain: "logic"`,
   `topics`);
3. one line in `~/.config/nvim/agent-system/extensions/formal/context/project/logic/README.md`
   under "Domain Files", matching the `frame-constraint-landscape.md` line's form;
4. `bash .claude/scripts/deploy-headless.sh` to regenerate the deployed tree (the dispatch's
   deploy-freshness context already reports `core` and `lean` stale, so a redeploy is due
   regardless).

**F15. Concurrency in the source store.** `~/.config/nvim` is a git repository and is dirty
right now with sibling edits (`agent-system/extensions/core/index-entries.json`,
`agent-system/extensions/lean/index-entries.json`, `core/scripts/orchestrate-cycle-plan.sh`,
`.memory/memory-index.json`, `.claude-extensions.json`). The formal extension's
`index-entries.json` is not among them today, but task 708 and 710 have no declared file scope.
The implementer must re-read `index-entries.json` immediately before editing, append its one
entry with a targeted edit, and stage only its three files by explicit path.

**F16. The task-reference rule.** `.claude/rules/no-task-references-in-deliverables.md` applies
to the note (it is a deliverable outside `specs/`). The pattern
(`scripts/lib/task-reference-patterns.sh`) is `task(s)` followed by a separator and a number;
a `specs/706_.../probes/...lean` path does not match it (`BiLasso/README.md` cites a
`specs/archive/476_...` path and passes the lint). So the note cites the probe by path and the
reports by path, and never writes "task 703 round 2"; it says "an earlier certificate-design
round" or cites `specs/703_lplus_compression_and_completeness/reports/02_semantics-first-compression-research.md`.

**F17. House style for a domain note.** The two models are `frame-constraint-landscape.md`
(H1, one-paragraph purpose, fully qualified Lean names, tables keyed by machine-checked
witness, no frontmatter) and `temporal-logic-patterns.md` (`**Created**`/`**Purpose**`
header). The logic README asks for "sentence letter" rather than "propositional atom", and
`standards/notation-standards.md` spells operators in ASCII words in prose tables (`box`,
`not`) while the Lean-facing notes use the Unicode glyphs in code spans. The
`literature-fidelity-policy.md` in `logic/standards/` governs proof transcription, not
citation; for citation the operative rule is the sub-index's own: label `unverified_*` sources
as such and verify quoted statements against the PDF. F9 did that for GKWZ; the note should
carry fidelity labels for the other four.

## Recommendations

1. **Write the note with these sections, in this order** (durable anchors only, no task
   numbers; ~150-220 lines):
   1. *The fact.* `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` is a ℤ-time non-validity of L and of L⁺
      (`θ.neg`) with no countermodel on any regular ℤ-frame with a finite carrier; the
      stability-modal-free reading ("every history meets `p`, and never twice from the left");
      the fragment variant `θ'`; primitive-syntax forms from the 706 report's appendix.
   2. *The machine-checked source.* The probe path, its compile command, the seven declaration
      names, the axiom list, and the archived L-side twin `Probe476.fmp_false`. One sentence that
      the declarations are probe-level and the note should be updated when they land.
   3. *The pumping argument*, in the probe's order (F4), with the four Lean names.
   4. *Why this is the certificate type, not a bound.* `FrameOver.ofStep` requires `[Finite W]`;
      a certified finite-graph certificate would hand `no_ofStep_sat` a model; no `n`, checker
      clause or liveness formulation repairs it.
   5. *The design rule and its landed embodiment.* The rule in capitals as the dispatch states
      it; then `FrameOver.ofSlicedStep` on `ℤ × Fin n`, `saturation_of_fib_finite`,
      `limit_of_succOrder`, `frame_worldState_not_finite`, and the two theorem-index rows (F3).
   6. *The published counterpart.* GKWZ pp. 234/236 "repeating finite pieces"
      **[verified-pdf]**; HWZ 2000 quasimodel over `⟨ℤ, <⟩` with the correspondence table of
      F7 and the "correspondence, not identity" caveat; GKWZ Chapter 11 as the book form, with
      the diagnosis that it was in the corpus (F10).
   7. *FMP failure is not undecidability.* Krommes Theorem 1.1; GKWZ 5.32 (p. 246) and 5.28
      (p. 244) with the product-vs-abstract distinction and why the abstract retreat is not
      available here (F9); the three wrong readings of F13.
   8. *ℤ-time semantics as a time-sliced graph semantics.* S1-S5 as true, time-homogeneous
      facts; what `θ` adds (a time at which something happens once); the two distinct
      obstructions (carrier size vs all-threads fulfilment) and the two landed answers (F5).
   9. *Secondary literature*, two short paragraphs: HVV 2004 §2/Table 1 as a summary of
      Halpern–Vardi 1989 (F11); HKKM 2019 with the not-a-product caveat (F12).
   10. *Fidelity labels* for every cited source, as in F7-F12.
2. **Write it to the source store, not to `.claude/`** (F14), register it in
   `index-entries.json` and the logic README, redeploy, and check the deployed copy appears
   under `.claude/context/project/logic/domain/`.
3. **Run `bash .claude/scripts/check-task-references.sh <note path>` before committing** (F16),
   and stage only the three source-store files by explicit path (F15).
4. **Do not transcribe GKWZ's 5.32 proof formula** (OCR-garbled in both extractions); cite the
   theorem statement and Figure 5.9's caption instead (F9).
5. **Do not state a complexity for this logic.** The 706 report commits to no bound; Krommes's
   EXPSPACE result is about K4 × S5, which this logic is not. The note records that FMP failure
   and decidability are independent questions, nothing more.
6. **Leave `limit-closure-and-fairness.md` as a separate follow-up** (F6), cross-referenced
   from section 8 of the note.

## Decisions

- **D1. The GKWZ verification is discharged in this round, not deferred to implementation.**
  Both theorem numbers and the two "repeating finite pieces" sentences were read in the
  `pdftotext` output of the source PDF named by the global index; page numbers are from the
  printed running heads. The implementer may cite them without re-verifying.
- **D2. The note cites the probe, not landed declarations**, because none are landed (F1); it
  says so explicitly so the citation can be upgraded later.
- **D3. The landed sliced certificate is named as the rule's embodiment** (F3) even though the
  dispatch text predates 703's closure; a context note that stated the rule without pointing to
  `FrameOver.ofSlicedStep` would send the next designer back into the design space.
- **D4. HVV 2004 is cited for what it contains** — a summary table of Halpern–Vardi 1989's
  complexity results and its own axiomatizability results — rather than as the source of the
  complexity results (F11).
- **D5. No `.orchestrator-handoff.json` is written**; the outcome is returned through
  `.return-meta.json` only.
- **D6. No user decision is raised.** Every choice above is inferable from the artifacts.

## Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | The note is written under `.claude/context/...` and wiped at the next deploy | High | Recommendation 2; the implementation plan's first phase should name the source-store path verbatim |
| R2 | A sibling (708/710, no file scope) edits the formal `index-entries.json` concurrently | Medium | Re-read before editing; targeted append; explicit-path staging (F15) |
| R3 | The note cites "task N" phrasing and the write-time hook blocks it | Low | F16; run the lint before commit |
| R4 | The note overstates HWZ's quasimodel as identical to the sliced certificate | Medium | Carry the correspondence table with the "correspondence, not identity" caveat; HWZ is first-order temporal with no `□`/`⊡` |
| R5 | The probe drifts and the note's compile command fails later | Low | The note cites the probe's own header, which records its last re-verification; 706's recommendation to land or guard the probe stands |
| R6 | Deploy regenerates `.claude/` while another dispatch reads it | Low | Deploy once, at the end of implementation, after the three source files are committed |

## Context Extension Recommendations

- **Topic**: Limit closure and fairness — why a finite, fulfilment-closed structure cannot
  present a limit-closed branching model with a pending eventuality.
  **Gap**: Still absent (recommended by the 703 round-2 report; the sharing-class refutation
  `not_exists_plusCertifies_pumpTarget` is landed but has no context note).
  **Recommendation**: a separate `context/project/logic/domain/limit-closure-and-fairness.md`,
  cross-referenced from this note's section 8, citing `PlusWitnessFamily/Limits/NoCertificate.lean`
  and Reynolds 2001 §1.
- **Topic**: Literature verification workflow for OCR-damaged book extracts.
  **Gap**: The sub-index marks GKWZ `unverified_conversion` and the source directory has no PDF,
  but the global `metadata.json` names the staging PDF; nothing in the literature context says
  to look there or that `pdftotext -layout` on it is reliable for theorem statements.
  **Recommendation**: one paragraph in
  `context/project/literature/patterns/agent-exploration.md` on resolving `source_path` from
  `metadata.json` and verifying with `pdftotext` before citing.
- **Topic**: Probing with `lake env lean` (already recommended twice).
  **Gap**: unchanged.

## Appendix

### Verification commands

```
PDF=~/Documents/literature-staging/gabbay_2003/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics.pdf
pdftotext -layout "$PDF" gkwz.txt
grep -n "Theorem 5.32\|Theorem 5.28\|Theorem 5.27" gkwz.txt     # lines 12902, 13037, 13163
grep -n -i "repeating finite pieces" gkwz.txt                  # lines 12498, 12516
```

Running heads around those lines: "244 Chapter 5. Products of modal logics: introduction"
(line 13015), "5.3. The finite model property 245" (13068), "246 ... introduction" (13122),
"5.3. The finite model property 247" (just after Theorem 5.32's proof opens), "234 ... introduction"
(before line 12498).

### Searches

- Repository: `no_finite_carrier`, `not_finite_carrier_fmp`, `Probe706` (no hits under
  `FormalSystem/`, `docs/`, `scripts/check-evidence-probes.sh`); `PlusSlicedCertificate`,
  `ofSlicedStep`, `frame_worldState_not_finite`, `saturation_of_fib_finite`,
  `limit_of_succOrder`, `mem_HF_iff_adjacent`, `ofStep`; `finite model|fmp|presentation-free`
  in `BiLasso/README.md`; state.json status of 703, 706, 707, 708, 710.
- Context: `.claude/context/index.json` entries with `project/logic/domain` paths (15, none
  about ℤ-time or fmp); source-store `index-entries.json` entry for
  `frame-constraint-landscape.md`; `ls` of both `logic/domain/` directories for `ztime*`.
- Literature chunks: HWZ 1, 7, 19-22, 27, 30-31, 33, 43 and a grep for `⟨ℤ, <⟩`; Krommes 5, 33,
  38 and greps for `5.32|5.28|EXPSPACE|finite product model property`; GKWZ 13 (contents), 261,
  264, 272, 275-277, 487-498, 589 and greps for `quasimodel`, `product fmp`, `Theorem 5.32`;
  HVV 1-2, 12 and greps for `HV89|complexity|nonelementary`; HKKM 1.
- Tools: `bash .claude/scripts/literature-search.sh --toc <doc>` (returns a JSON array of
  chunks, not a `.results` object); `bash .claude/scripts/check-task-references.sh` on
  `BiLasso/README.md` (PASS, 0 occurrences).

### Files read

| File | Why |
|---|---|
| 706 `reports/01_...` (summary, Q1.1-Q1.4, recommendations, context recommendations, appendix) | The content the note records |
| 706 `probes/NoFiniteCarrierModel.lean` (whole) | The machine-checked source; declaration names and header argument |
| 703 `reports/02_...` (§1.1, §1.3, §2.5, context recommendations) | The time-homogeneous diagnosis and the still-open graph-semantics note |
| 703 `summaries/07_...` (overview, what changed) | What landed after 706 was written |
| `PlusSlicedCertificate.lean`, `PlusSlicedCertificate/{Frame,Sound}.lean` headers | The rule's landed embodiment |
| `Semantics/TaskFrame.lean:2205-2235`, `IntNormalForm.lean:340-360, 440-470` | `saturation_of_fib_finite`, `mem_HF_iff_adjacent`, `ofStep` and its `[Finite W]` |
| `BiLasso/README.md`, archived `fmp-hypothesis-is-false.lean` header | The pre-existing prose and the L-side twin |
| `logic/README.md`, `domain/{frame-constraint-landscape,temporal-logic-patterns}.md`, `standards/{literature-fidelity-policy,notation-standards}.md` | House style and conventions |
| `index-entries.json` (formal), `.claude-extensions.json`, `rules/source-store-deploy-boundary.md`, `rules/no-task-references-in-deliverables.md`, `scripts/lib/task-reference-patterns.sh` | Deliverable mechanics |
| `specs/literature-index.json` (five entries) | Fidelity labels |
| GKWZ `metadata.json`; `pdftotext` output of the staging PDF | The verification |
