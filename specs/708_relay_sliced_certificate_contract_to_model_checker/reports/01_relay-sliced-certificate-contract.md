# Research Report: Task #708

**Task**: 708 - Relay the sliced certificate contract to the model checker
**Started**: 2026-10-02T13:43:44Z
**Completed**: 2026-10-02T14:20:00Z
**Effort**: ~1 hour, research only; no file outside `specs/708_*/` was written, and nothing under `/home/benjamin/Projects/ModelChecker` was touched
**Dependencies**: 703 (completed 2026-10-02 — the sliced certificate is landed, which changes what this relay says), 706 (its Q7 is the relay's starting text), 701 (completed; the precedent for the deliverable's shape)
**Sources/Inputs**:
- This repository: `specs/706_*/reports/01_lplus-finite-model-property-research.md` (§Q1.4, §Q7); `specs/703_*/summaries/07_lplus-sliced-certificate-and-completeness-summary.md` (the paired-repository read and the corrected point (iv)); `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` (closing record), `PlusSlicedCertificate/{Basic,Stable,Check,Complete,EmbedComplete,FixtureStable,Position}.lean`; `BimodalTools/README.md` (certificate re-verification protocol, joint canonical contract); `BimodalTools/CanonicalWire/Cert.lean` (`decodeOptLassos`); `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` (period-folding caveat); `specs/701_*/summaries/01_*.md` (precedent shape)
- Paired repository, read-only: `specs/TODO.md` entries 200 and 219; `code/src/model_checker/theory_lib/bimodal/docs/{ADEQUACY,TRUST_PIPELINE,ARCHITECTURE,SEARCH_COVERAGE,SETTINGS}.md`; `semantic/{certificate,witness_registry,checker,core,model}.py` (anchors only); repo-wide greps for tail-stability, HOA, finite-graph, D8
- Literature (per-repo sub-index): `babiak_et_al_2015_hanoi_omega_automata_format` (all 16 chunks), `biere_heljanko_junttila_latvala_schuppan_2006_linear_encodings_bounded_ltl` (chunks 4, 16, 17, 64), `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl` (chunks 20-22, 27-28, 30-33); `~/Projects/Literature/SOURCES.md` §D11
**Artifacts**: `specs/708_relay_sliced_certificate_contract_to_model_checker/reports/01_relay-sliced-certificate-contract.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The relay text as filed is one increment stale, in the one place that matters.** Task 703
  closed on 2026-10-02 with the sliced certificate **landed** (`PlusSlicedCertificate`, 24
  modules, four C2-pinned theorems), and its Phase 16 refuted the filed point (4): tail-stability
  is **not** a re-presentation requirement discharged by "move the pre-period into `mid` and
  multiply the period". `exists_tailStable_repr` is false and is stated nowhere
  (`FixtureStable.lean`). What landed is a **liveness-filtered, residue-indexed** demand
  (`Stable.TailStable`) that the *checker* evaluates; of its two failure modes only the pre-period
  (`⊇`) one is repaired by absorption into `mid`, the other (`⊆`) is absorbed by the checker's own
  filter and needs no search-side action, and no theorem says absorption always succeeds. The
  relay must carry the landed form, with declaration names, not the 706 Q7 draft.
- **Points (1), (2), (3), (5) survive and three of them are now theorems or confirmed facts.**
  (1) and (5) are already the paired repository's own positions (no finite-graph schema anywhere;
  decision D8 with structural enforcement) — the relay *confirms* them. (2) is now a landed Lean
  structure whose fields fix the wire extension exactly: per slice an `edge : Fin n → Fin n → Bool`
  and `lab : Fin n → Finset PlusFormula`; three slice segments; `bx`; a `target : PlusGraphPath`
  with its own three segments; `targetTime : ℤ`. (3) is unchanged — no bound on `n`, and the
  embedding theorem `WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`
  makes "the L bounds apply unchanged on `⊡`-free targets" a theorem rather than an expectation.
- **HOA decision: do not express the sliced certificate as a HOA profile or extension; keep the
  canonical-JSON strict extension, and adopt one HOA discipline.** HOA encodes one-sided ω-automata
  with `Inf`/`Fin` acceptance; the certificate is a bi-infinite (`ℤ`-indexed) labelled structure
  whose acceptance is a nine-conjunct decidable predicate (`Check.Certifies`) over a closure, a
  box guess and a target — not an acceptance condition any HOA consumer evaluates. HOA also has no
  canonical byte form, which the existing echo-comparison protocol requires. The discipline worth
  adopting is HOA's capitalised-header rule: a consumer that does not understand a
  semantics-bearing field must **error**, never reinterpret. Concretely: a sliced envelope must
  **omit** `lassos`, because the current checker reads an absent `lassos` as `[]` and rejects
  (structural), whereas a sliced envelope *with* `lassos` present would be silently checked as a
  lasso family. A lossy HOA export of the unrolled window graph is reasonable as a
  visualisation aid, as a non-contract.
- **Published vocabulary maps cleanly, with two corrections to the filing.** The sliced
  certificate is a Hodkinson–Wolter–Zakharyaschev **quasimodel** (Def 12) with explicit states and
  edges — the quasimodel is its quotient by label; a slice is a **state candidate** (Def 6); the
  slice sequence is the **state function** (Def 10); the target path is a **run** (Def 11); the
  lasso family is a **(k,l)-loop** (Biere et al. 2006, §2). Corrections: HWZ's `♯(ϕ)` bounds the
  number of distinct *quasistates*, not the slice width `n` (states with equal labels are distinct
  here, and must be, for `⊡`); and the periodic-state-function result is HWZ **Theorem 24 /
  Lemmas 21, 23** (§5), not Definition 20, which defines "realizes `ψ₁Uψ₂` in `m` steps". Lemma 23's
  conditions 1-3 are the literature counterpart of liveness-plus-`TailStable`. The phrase
  "ultimately periodic" does **not** occur in the Biere text (it says "lasso-shaped", `βγ^ω`,
  "(k,l)-loop", "period `p(π) = k−l+1`"); it is standard automata vocabulary and may be used, but
  not attributed to that paper.
- **What the relay amends on their side, by name**: `specs/TODO.md` entry 200 (blocker paragraphs:
  703 is completed, the branching structure and its conditions exist, what is missing is a
  bound on `n` and the sliced finite model property); `docs/ADEQUACY.md` rows **A3** and
  §7.1(iii-e) (bound shape becomes the tuple `(n, nb, nm, nf)`; divisor caveat carries to
  `nb`/`nf`), §6.1 (the strict wire extension, not yet shipped by either side), and a **new**
  tail-stability item (new information, changes accept/reject logic); `docs/TRUST_PIPELINE.md` "The
  stability modal" (stale: "blocked on four Lean-side results"); entry 219's header comment (limit
  (b) now has a certificate class to cite). Rows **A0, A1, A1-Γ, A2** and §7.4 are **unchanged**.
- **Recommended deliverable shape**: the task-701 precedent — ready-to-file replacement text in
  this task's summary, per amended entry/row, with nothing written in the paired repository.

## Context & Scope

The task relays a contract change to `/home/benjamin/Projects/ModelChecker`, read-only from here.
Its filed description carries five points transcribed from task 706's §Q7, plus a 703-Phase-21
finding (no tail-stability concept on their side) and an added literature scope (the HOA
question). Between 706's filing and this dispatch, task 703 executed the amended plan to
completion, so the relay's source of truth moved from a research design to landed, C2-pinned
code. This report (i) re-verifies each of the five points against the landed tree and the paired
repository's live documents, (ii) answers the HOA question with a recorded decision, (iii) fixes
the published vocabulary, and (iv) names each entry and row the relay amends, with draft text the
plan can carry into a 701-shaped summary.

Constraints honoured: the paired repository was not written to (confirmed by `git status` there
being out of scope; every access was `grep`/`sed`/`cat`); no bound was committed; no
`.orchestrator-handoff.json` was written; sibling tasks 704, 705, 707, 710 are in research this
cycle and this task touches no file they declare.

### Verification labels

- **[landed]** — a declaration present and sorry-free in `FormalSystem/` at HEAD `4252ebe92`.
- **[theirs]** — a statement read verbatim from the paired repository's live files.
- **[literature]** — read from the cited chunk text; the three primary sources carry
  `provenance_fidelity: unverified_summary` in the sub-index, but the chunks read are OCR of the
  papers themselves (titles, section numbers and reference lists present), not hand summaries.
- **[argued]** — this report's own reasoning.

## Findings

### F1 — Point-by-point verification of the five relay points

| # | Filed point | Status after verification | Load-bearing evidence |
|---|---|---|---|
| (1) | Withdraw the finite graph as a contract | **Confirm, not correct.** Already their position, independently reached | **[theirs]** zero hits for `finite graph`, `finite-graph`, `PlusGraphCertificate`, `sliced` repo-wide; `ARCHITECTURE.md` lists fixed-frame finite-digraph checking as a non-goal; `ADEQUACY.md` "Why ℤ-time only" item 1 and "Why the design is deterministic" record the finite-presentation route as refuted. **[landed]** `PlusSlicedCertificate.lean` closing record: finite-carrier FMP refuted unconditionally; `Basic.onePointCertificate` exhibits the finite graph as the one-slice special case |
| (2) | The time-sliced graph is the contract; lasso family is the `i → i` special case; strict extension | **Holds, now with exact field shapes.** | **[landed]** `Basic.lean:280` `PlusSlice n C := {edge : Fin n → Fin n → Bool, lab : Fin n → Finset PlusFormula, lab_sub}`; `Basic.lean:328` `PlusSlicedCertificate Γ Del := {n, n_pos, back, mid, fwd : List (PlusSlice …), back_ne, fwd_ne, bx, target : PlusGraphPath n C, targetTime : ℤ}`; `Basic.lean:140` `PlusGraphPath := {back, mid, fwd : List (Finset PlusFormula × Fin n), back_ne, fwd_ne, label_sub}`. `Embed.lean`'s `WitnessFamily.sliced`: slice width = lasso count, edges `i → i` only. **[theirs]** `ADEQUACY.md` §6.1 names `BimodalTools/README.md` as the wire authority and the six names as an export contract. Neither side has shipped a sliced wire field (703 summary 07, point 2) |
| (3) | Bound is the tuple `(n, nb, nm, nf)`; no bound on `n`; L bounds unchanged on `⊡`-free targets; divisor caveat carries to `nb`/`nf` | **Holds; the `⊡`-free half is now a theorem.** | **[landed]** closing record: "no slice-width bound, no tail-period bound and no complexity claim is proved anywhere"; `EmbedComplete.lean:1492` `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` and `:1422` `sliced_tailStable_of_certifies`. **[theirs]** §7.1(iii-e) already records the single-`n`-versus-triple shape mismatch; `SETTINGS.md:36` states the divisibility caveat; `SEARCH_COVERAGE.md` §4 decides the bounded sweep. See F3 for the one subtlety (common periods under embedding) |
| (4) | Tail-stability is required by the checker; an unstable countermodel is re-presented (pre-period into `mid`, period multiplied) — "the same divisor-period sweep the registry performs for A3" | **Superseded. Relay the landed form.** | **[landed]** `Stable.lean:841` `TailStable` (both conjuncts liveness-filtered, residue-indexed); `FixtureStable.lean` header: `exists_tailStable_repr` is false, "no member of the re-presentation family is tail-stable" for the raw demand; `Position.lean:65-77` the `⊆`/`⊇` dichotomy. **[theirs]** zero occurrences of `tail.{0,3}stab` and of "re-presentation" repo-wide (703 summary 07 point 4, re-confirmed here). See F2 |
| (5) | Never-report-validity stands; an empty search licenses nothing for `⊡` targets | **Confirm, not correct.** Already their decision D8 | **[theirs]** `ADEQUACY.md` §7.4; `ARCHITECTURE.md` "Never Reporting Validity (D8)"; `semantic/core.py:67`, `model.py:27`, `proposition.py:36`; tests pin "not a validity claim". **[landed]** closing record: the sliced FMP is open, not refuted. The literature adds nothing here — see F5 |

### F2 — The landed tail-stability demand, stated for a consumer that has never heard of it

This is the one point that changes their accept/reject logic, and it must be relayed in the
landed form. Everything below is read off `Stable.lean`, `Position.lean`, `FixtureStable.lean` and
the closing record **[landed]**.

- **What the checker computes.** For a sliced certificate `G` the checker computes a *live
  position set* at each window time: positions are `(state, Hintikka type)` pairs over a slice,
  and a position is live iff a forward run and a backward run of the certificate's own labelled
  structure pass through it with every pending eventuality discharged (`Live`, `LiveFix.liveT`,
  `Bridge`). This is a nested greatest/least fixpoint over the finite timed position graph on the
  combined window, not a field of the certificate. Liveness replaces the lasso family's
  all-threads fulfilment (their (C2)) with fulfilment of live positions only.
- **The demand.** With `NB`/`NF` the combined back/forward periods (least common multiples of the
  certificate's and the target path's segment lengths), `TailStable G` is
  `∀ r < NB, ΦBack^NB (liveAt (−NB − r)) ∩ bwdLiveAt (−NB − r) = liveAt (−NB − r)` and the mirror
  `∀ r < NF, ΦFwd^NF (liveAt (NM + NF + r)) ∩ fwdLiveAt (NM + NF + r) = liveAt (NM + NF + r)`:
  transporting the live set one whole period down each tail, filtered by that direction's
  one-directional live set, returns the live set, at **every residue** of the period. It is
  decidable (`decidableTailStable`, synthesized) and costs `NB + NF` transfer applications.
- **Why it is needed.** Forward liveness from the back tail is not periodic in `t` in general (706
  §Q1.4 item 4's four-state example; `Fixture.live_not_determined_by_slice` **[landed]**), so the
  `⊡` clause of the truth lemma must read the live set at a window representative that carries the
  same live set at every time down the tail (`Tail.exists_win_live_eq`). `TailStable` is exactly
  the condition under which that representative exists.
- **The two failure modes, and who repairs each.** (a) **`⊆` failure**: the transfer is a
  reachability relation, so a position that is reachable from a live position but dead in one
  direction lands in the iterate. The checker's **filter** (`∩ bwdLiveAt` / `∩ fwdLiveAt`) removes
  it. *No search-side action.* (b) **`⊇` failure**: a genuinely live position has no live
  predecessor one whole period back because a pre-period shows through the window's edge. *No
  filter repairs this*; it is repaired by **re-presenting** the same frame with the pre-period
  absorbed into `mid` (`FixtureStable.not_mem_L₀_pR` records the witness leaving `L₀` once
  absorbed). This is the only part of the filed point (4) that survives, and it is a `mid`-length
  increase, not a period multiplication.
- **What is not promised.** There is no theorem that absorption always succeeds:
  `exists_tailStable_repr` was asked for by 703's plan and refuted at a named certificate for the
  raw demand (`Fixture.not_tailStable`, for every pre-period and every period multiplier); for the
  filtered demand no general re-presentation lemma is stated either. `TailStable` is "a demand on
  the frame together with its closure" — a per-certificate field of `Certifies`, not a theorem —
  and `FixtureStable.not_tailStable_cert` exhibits a certificate it rejects. So a search that
  finds a countermodel frame and cannot present it tail-stably reports exactly that, and D8 covers
  the gap: nothing is licensed either way.
- **The embedded case is fully covered.** Every certified L-side family yields a tail-stable sliced
  certificate at every residue (`EmbedComplete.sliced_tailStable_of_certifies` **[landed]**), so on
  `⊡`-free targets the demand never rejects anything the lasso contract accepts.
- **Where the filed "divisor-period sweep" analogy stands.** Their registry's exact-modulus folding
  (`witness_registry.py` `wrap`, §7.1(iii-a)) is about *representability* of a period at a
  configured length — a question of `nb'` dividing `nb`. Tail-stability is a different question
  (does liveness wrap faithfully at the configured period). The two compose: the sweep over
  `(nb', nf')` remains the mechanism for exploring periods, and absorption is an increase of `nm`;
  703's summary deliberately declined to equate the two concepts, and the relay should too.

### F3 — The bound tuple, and one subtlety under embedding

- **[landed]** Nothing bounds `n`; the closing record says the doubly exponential slice width is a
  research finding, not a theorem. The relay must not supply a number, and their search must not
  configure `n` from a formula.
- **[theirs]** Their configuration is the triple `(back, mid, fwd)`; §7.1(iii-e) already names the
  shape mismatch against upstream's single `n`. The amendment is that the upstream shape is now a
  **4-tuple** `(n, nb, nm, nf)` with `n` a new, unbounded search dimension, and that the three
  length settings retain the divisibility caveat on `nb`/`nf` (`mid` carries no periodicity —
  `SEARCH_COVERAGE.md` §3(b), unchanged).
- **Subtlety [argued, from landed statements]**: the embedding `WitnessFamily.sliced` cuts the
  slice sequence "at the family's common periods" — a common multiple of the lassos' individual
  periods, each bounded by `compressionBound`. So the *sliced presentation* of an L countermodel can
  have `nb`, `nf` up to a common multiple of up to `|C| + 1` periods, not `compressionBound` itself.
  This is immaterial to their search: for `⊡`-free targets the lasso contract stays in force and is
  the right encoding; the sliced format is for `⊡` targets. The relay should say "keep the lasso
  contract for `⊡`-free targets; the embedding theorem is the guarantee that the extension loses
  nothing", and not restate the L bound as a sliced-tail bound.

### F4 — The HOA question: decision and reasons

Read from the HOA paper's own text **[literature]**: an automaton is a header plus a body; body
states carry labels (Boolean formulas over indexed `AP:`) and acceptance-set marks; `Acceptance: n
acc` with `acc` a Boolean combination of `Inf(s)`/`Fin(s)`; a `Start:` state; runs are ω-sequences
(or trees, for alternation); capitalised header names affect semantics and an unknown one must be
reported as an error, lower-case ones are informative and may be ignored; the format is
extensible through headers and supports streaming. Tool support is Spot, `jhoafparser`, PRISM,
`ltl2dstar`, `ltl3ba`, `ltl3dra`, Rabinizer.

**Decision: a bespoke, canonical-JSON strict extension of the existing lasso envelope — not a
HOA profile.** Reasons, each sufficient on its own:

1. **Wrong kind of object.** A HOA automaton accepts ω-words from a start state; a sliced
   certificate is a `ℤ`-indexed structure with two periodic tails and no start, and its
   acceptance is `Check.Certifies` — nine conjuncts over a closure, a box guess `bx`, a target
   path, a target time and the computed live sets, including `TailStable` and `StabFaithful`. None
   of that is an `Inf`/`Fin` condition over acceptance sets. A HOA consumer given such a file would
   parse it and check nothing that matters; the semantics-bearing content would have to ride in
   headers, which is precisely what HOA says consumers may ignore (lower-case) or must reject
   (capitalised). Either way no existing tool gains a checking capability.
2. **Canonical bytes.** The joint contract (`BimodalTools/README.md` "The joint canonical
   contract") is one certificate, one byte string, with the Lean printer and parser proved inverse
   (`CanonicalWire.parse_print`) and their `assert_echo_matches_sent` comparing echoed bytes to sent
   bytes. HOA has no canonical byte form (free whitespace, optional headers, state naming), so the
   echo protocol would have to be redefined, and the round-trip theorem redone, for no checking
   gain.
3. **"Strict extension" is a requirement, and HOA would be a replacement.** The lasso family is
   the degenerate sliced certificate (`Embed.lean`); the existing JSON must remain the special case
   byte-for-byte. A HOA profile cannot contain the current JSON.
4. **Labels are closure formulas, not atomic propositions.** HOA state labels are Boolean formulas
   over `AP:` indices; one could index the closure and label each state with a conjunction, but
   `bx`, `premises`/`conclusions`, `time` and the per-slice edge matrix have no HOA slot. The
   per-slice `edge` could be encoded as transitions of the unrolled window graph (states
   `(t, w)`), and the tails as cycles — a faithful **one-sided** picture of each tail, but not of the
   bi-infinite whole.

**What is taken from HOA.** Its header discipline, as a rule for the extension: *a consumer that
does not understand a semantics-bearing field must error, never silently reinterpret.* Applied here
**[landed]**: `CanonicalWire/Cert.lean` `decodeOptLassos` reads an absent `lassos` as `[]`, which
the structural check then **rejects**; unknown envelope keys are skipped. Therefore a sliced
envelope must **omit** `lassos` entirely (its data lives under a new key, say `slices`), so that a
lasso-only checker rejects it structurally rather than checking a `lassos` array as a deterministic
family while ignoring the slices. Carrying both keys in one document is the one encoding that
must be forbidden by the contract.

**Optional non-contract export.** A lossy HOA rendering of the unrolled window graph (one file
per tail direction, states `(t, w)`, labels the closure atoms, no acceptance) is a reasonable
*visualisation* aid via Spot's `autfilt`/`dot` output, and is explicitly not a certificate.

### F5 — Published vocabulary for the relay, verified against the chunk text

| This repository's term | Published term | Where, verbatim | Note |
|---|---|---|---|
| lasso family; lasso `(back)^ω mid (fwd)^ω` | **(k,l)-loop**; **lasso-shaped path** `βγ^ω`; **period** `p(π) = k − l + 1`; `LoopConstraints`, `InLoop` | Biere et al. 2006, §1 (chunk 4), §2 (chunk 16: "π = (s₀…s_{l−1})(s_l…s_k)^ω such that 0 < l ≤ k and s_{l−1} = s_k"), Def 5.1 (chunk 64) | One-sided; the bi-lasso is the two-sided analogue. "Ultimately periodic" is **not** in the text; it is standard elsewhere (their own report 218 sources it to "Ultimately periodic words of rational ω-languages") and may be used unattributed to Biere |
| time slice | **state candidate** `⟨T, T^con⟩` (Def 6); **quasistate** when inside a quasimodel (Def 12) | HWZ 2000 chunk 20, 22 | A quasistate is a *set of types*; our slice also fixes `n` named states and an edge matrix. The quasimodel is the quotient of the sliced certificate by label |
| slice sequence `back/mid/fwd` | **state function** `f : W → candidates` (Def 10); periodic form `f₁ ∗ f₂^ω` | chunk 21; Theorem 24 (chunk 33) | HWZ is over `⟨N,<⟩` with "the case of `⟨Z,<⟩` similar" (chunk 25) |
| target path `PlusGraphPath` | **run** `r` with the `U`/`S` clauses (Def 11) | chunk 21-22 | Exact match, including both `U` and `S` clauses |
| sliced certificate | **quasimodel** `⟨f, R⟩` (Def 12), with the condition "every type in every quasistate lies on some run" | chunk 22 | That condition is our liveness: a position is live iff a run passes through it |
| slice width `n` | — | — | **Not** HWZ's `♯(ϕ)` (chunk 20: `♯(ϕ)` = number of distinct *realizable state candidates*, `♭(ϕ) = 2^{|sub_x ϕ|}` = number of types). Two states with the same label are one type but two states here, and must be, since `⊡` quantifies over histories through a *state* |
| pumping / `exists_window_eq` | **Lemma 17** (splice: `f(n) = f(m)` ⇒ `f^{≤n} ∗ f^{>m}` is a quasimodel) | chunk 28 | Exact match in shape |
| liveness + `TailStable` | **Lemma 23**, conditions 1-3 on `f₁ ∗ f₂^ω` (suitable adjacent types in both directions along the window; every `U`-eventuality realized within `l₁ + l₂ − i` steps); **Theorem 24** (§5, "periodical state function, with the period being of some bounded length", chunk 28) | chunks 31-33 | The filing attributes this to **Def 20**; Def 20 (chunk 30) defines "`r` realizes `ψ₁Uψ₂` in `m` steps". Cite Theorem 24 / Lemmas 21, 23 |
| `⊆`/`⊇` dichotomy | Def 22 **suitable pair** (one-step `U`-coherence) is what reachability sees; fulfilment is what it does not | chunk 31 | Matches `Position.lean`'s explanation of why `ΦFwd` is reachability-only |

**Limit of the certifying literature (froleyks 2024, time2019, sosy-lab D11)** — not re-read this
round; the dispatch's characterisation stands: it is about certificate **soundness** (does the
checker's acceptance imply the property), never about **completeness of a certificate class**.
The relay therefore uses it only for the exchange-format argument (F4) and says nothing from it
about point (5).

### F6 — What the relay amends on their side, precisely

| Their artifact | Current state **[theirs]** | Amendment | Kind |
|---|---|---|---|
| `specs/TODO.md` entry 200, blocker paragraphs | Says 703 is `not_started`, gated on 696; expects "a compression bound" and "the verified side's branching structure"; "no L-plus compression subtree at all yet" | 703 is **completed** (2026-10-02); the branching structure is `PlusSlicedCertificate` with `Certifies` (nine conjuncts); soundness `Sound.plusRefutes_of_certifies`, relative completeness `Complete.exists_plusSlicedCertificate_of_tailStable_countermodel`, embedding `WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`; what is **still missing** is any bound on `n` and the sliced finite model property; the status remains BLOCKED on those, for a sharper reason; the certificate datatype to adopt is the sliced one, as a strict extension; tail-stability is a new accept/reject criterion | Replacement paragraphs (keep the shape-mechanism and temporal-asymmetry-correction paragraphs verbatim, as 701 did) |
| `docs/ADEQUACY.md` row **A3** and §7.1(iii-e) | Bound shape: upstream single `n` vs their triple | Upstream shape is now `(n, nb, nm, nf)`: three lengths with the divisor caveat on `nb`/`nf`, plus a slice width `n` with **no proved bound** and not to be configured from a formula; for `⊡`-free targets the L row stands unchanged and the lasso contract remains the encoding | Row note + (iii-e) rewrite |
| `docs/ADEQUACY.md` §6.1 wire contract | Lasso envelope, six frozen names | Add the sliced envelope as a **strict extension** (new key, `lassos` omitted — F4 rule); state that neither side has shipped it and that the lasso envelope is unchanged byte-for-byte | New subsection, "not yet shipped" |
| `docs/ADEQUACY.md` new item (suggest §7.5 or a row **A4**) | No tail-stability concept | Tail-stability as in F2: what the checker computes, the demand, the two failure modes and who repairs each, what is not promised, the embedded case, and its relation to representability | **New information** |
| `docs/ADEQUACY.md` rows A0, A1, A1-Γ, A2; §7.4 | — | **Unchanged.** §7.4 may add one sentence: for L⁺ targets containing `⊡`, ground (i) holds with no proved finite model property at all | Confirmation |
| `docs/TRUST_PIPELINE.md` "The stability modal" and the "In this repository" row | "Blocked on four Lean-side results"; "requires re-proving Lemma 2 and redesigning (C3)"; decidability "paper-level only" | The Lean side has re-proved the histories characterization (`Frame.mem_HF_iff_slicedPath`), replaced (C3) by `BoxLiveFaithful` + (C3b), and added (C5) `StabFaithful`; the MSO/Rabin paragraph stands as the only decidability route; the "honest ceiling" item 3 wording ("open, but routed") stays, with the route now named | Rewrite of the section's middle paragraphs |
| `specs/TODO.md` entry 219 / `examples.py` THEORY-LIMITS header | Limit (b): no certificate class for the schema | Limit (b) wording stands (no general `⊡` completeness), but the class to cite is now `PlusSlicedCertificate`, non-vacuous on `⊡`-free targets by the embedding theorem; whether any `⊡` instance is now certified is **sibling task 704's question** — do not assert it | Minor citation amendment, gated on 704 |
| `docs/SEARCH_COVERAGE.md` | Bounded sweep over `(back', fwd')`, `mid` fixed | Unchanged; note that absorption of a pre-period is a `mid` increase and composes with the sweep | Confirmation |

### Codebase Patterns

- The 701 precedent carries ready-to-file replacement text inside this repository's summary, with
  dangling-citation checks on both sides before filing; this task should reuse that structure and
  its check list (`specs/701_*/summaries/01_*.md` §"Verification Snapshot").
- Their citation convention is **fully qualified declaration name, never `file:line`**
  (entry 219, "cite every upstream result by FULLY QUALIFIED DECLARATION NAME"); the relay text
  should cite `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.*` names and the
  theorem-index rows, not line anchors.
- Their wire parser (`semantic/certificate.py:563`) reads `raw.get("lassos", [])` — the same
  absent-reads-as-empty behaviour as `decodeOptLassos`, so the F4 rule (omit `lassos` in a sliced
  envelope) produces a structural rejection on **both** re-checkers today.

### External Resources

- Babiak et al. 2015 (HOA): structure, header discipline, acceptance grammar, tool support — read in
  full (16 chunks).
- Biere, Heljanko, Junttila, Latvala, Schuppan 2006: (k,l)-loop definition, lasso-shaped `βγ^ω`,
  period and `d`-unrolling for PLTL (Def 5.1, Prop 5.2).
- Hodkinson, Wolter, Zakharyaschev 2000: Defs 6, 7, 10, 11, 12, 20, 22; Lemmas 17, 21, 23; Theorem 24;
  `⟨Z,<⟩` treated as "similar" throughout.
- `~/Projects/Literature/SOURCES.md` §D11: sosy-lab verification witnesses, recorded as a
  consult-online resource; not fetched this round.

## Recommendations

1. **Relay the landed point (4), not the filed one.** The implementation phase's text for the new
   ADEQUACY item and for entry 200 must use F2's statement, with declaration names
   (`PlusSlicedCertificate.TailStable`, `decidableTailStable`, `Stable.fwdLiveAt`/`bwdLiveAt`,
   `FixtureStable.not_tailStable_cert`, `EmbedComplete.sliced_tailStable_of_certifies`), and must
   say plainly that absorption is the known repair for the `⊇` mode only and is not proved
   sufficient.
2. **Record the HOA decision in the relay and in this repository's wire documentation.** One
   paragraph in `BimodalTools/README.md`'s re-verification protocol section when the sliced
   envelope is specified: canonical-JSON strict extension; `lassos` omitted in a sliced envelope;
   optional lossy HOA export for visualisation only. (Owner: the task that ships the envelope — not
   this one, which writes nothing outside `specs/`.)
3. **Deliverable shape = task 701's.** Summary sections: "ModelChecker entry 200 — ready-to-file
   replacement paragraphs"; "ADEQUACY.md — row A3 and §7.1(iii-e) amendment"; "ADEQUACY.md — §6.1
   sliced envelope (not yet shipped)"; "ADEQUACY.md — new tail-stability item"; "TRUST_PIPELINE.md
   — stability-modal section rewrite"; "entry 219 — citation amendment (gated on 704)"; plus a
   dangling-citation check of every Lean name against the live tree and every path against the
   live paired repository, as 701 did.
4. **Draft the sliced envelope's field list in the relay, labelled "proposed, unshipped".**
   Mirror the Lean fields exactly, as the lasso contract does: top level `target` (unchanged),
   `bx` (unchanged), `n`, `slices: {back: [<slice>…], mid: […], fwd: […]}` with `<slice> =
   {edge: [[bool…]…] (n×n), lab: [<label>…] (length n)}`, and `path: {back: [[<label>, state]…],
   mid: […], fwd: […]}`; `target.time` is `targetTime`. Key order frozen in that sequence. No
   `lassos` key. Say explicitly that this is a proposal for the two repositories to pin together,
   and that `check_certificate` does not read it today.
5. **Use published vocabulary with the two corrections of F5**: say "(k,l)-loop / lasso-shaped"
   for the current contract, "quasimodel with named states" for the sliced one, "state function",
   "run", "Lemma 23 / Theorem 24 periodic state function" for the tail condition, and do not call
   `n` "`♯(ϕ)`".
6. **Do not commit any bound.** The relay carries `(n, nb, nm, nf)` as a shape, the L bound for
   `⊡`-free targets under the lasso contract, and nothing for `n`.
7. **Gate the entry-219 amendment on task 704's outcome** (certificate non-vacuity on `⊡`
   targets); file it as conditional text.

## Decisions

- **D1. Source of truth for the relay is the landed tree at HEAD, not 706 §Q7.** 706's text was
  correct as a design and is superseded on point (4) by 703's Phase 16-20 results.
- **D2. HOA: no.** Recorded with four independent reasons (F4); one HOA discipline adopted (error
  on unrecognised semantics-bearing content), which fixes the `lassos`-omission rule.
- **D3. The relay confirms (1) and (5) rather than arguing them**, per the 703 Phase 21 finding
  re-verified here.
- **D4. No literature extraction protocol was run**; the sources were read for vocabulary and for
  the exchange-format question, which is what the dispatch asked.
- **D5. The sosy-lab page was not fetched**; it is cited as recorded in SOURCES.md §D11 only.
- **D6. No `.orchestrator-handoff.json` is written**; the outcome returns through
  `.return-meta.json`.
- **D7. No user decision is raised.** Every choice here is inferable from the artifacts; the one
  judgement call (HOA) is recorded with reasons and is reversible at the shipping task.

## Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | The paired repository builds its stability-modal extension against 706 §Q7's point (4) (re-presentation always succeeds) | High | Recommendation 1; the relay states the refutation by name |
| R2 | A sliced envelope is sent with `lassos` present and is silently accepted as a lasso family by an older checker | High | F4 rule: `lassos` omitted; contract text forbids both keys in one document; both re-checkers already reject an absent/empty `lassos` |
| R3 | Entry 200's `dependencies` array names ModelChecker-local numbers unrelated to this repository's tasks (their own flag) | Low | Out of scope; keep their flag paragraph verbatim |
| R4 | Sibling task 704 changes what can be said about `⊡` non-vacuity before the relay is filed | Medium | Recommendation 7: conditional text for entry 219 |
| R5 | Lean names cited in the relay are renamed by the C23/C26 gate disposals of later tasks | Low | 701-style dangling-citation check at filing time |
| R6 | The literature sub-index entries are `unverified_summary`; a cited definition number is wrong | Low | Every definition/lemma number above was read from the chunk text and quoted; Def 20 vs Theorem 24 was caught this way |

## Context Extension Recommendations

- **Topic**: cross-repository relay tasks (BimodalLogic → ModelChecker).
  **Gap**: the 701 shape (ready-to-file text in the summary, dangling-citation checks on both
  sides, name-not-line citations, read-only constraint) is documented only inside task artifacts.
  **Recommendation**: a short `context/patterns/paired-repository-relay.md` capturing the
  deliverable shape, the citation convention, and the "confirm vs. correct vs. introduce"
  triage used in F1.
- **Topic**: wire-format extension discipline.
  **Gap**: the "omit the key an unaware consumer would reinterpret" rule derived in F4 is not
  recorded anywhere this repository's wire documentation points to.
  **Recommendation**: add it to `BimodalTools/README.md` when the sliced envelope is specified
  (Recommendation 2).

## Appendix

### Searches

- Paired repository, repo-wide (`--exclude-dir=.git`): `tail-stab|tail stab|tail_stab` (0 hits);
  `Hanoi|\bHOA\b` (0); `finite graph|finite-graph|PlusGraphCertificate|sliced|time-slice` (0);
  `\bD8\b` in `*.md` and `semantic/*.py` (D8 = never report validity); `ultimately periodic|
  eventually periodic` (report 218, archive 184/186 only).
- This repository: `substrate lessons` (→ task 701); `structure PlusSlice|PlusSlicedCertificate|
  PlusGraphPath`; `def TailStable|TailStableRaw`; `exists_tailStable_repr|not_tailStable_cert`;
  `theorem exists_plusSlicedCertificate_*`; `def Certifies`; `lassos` in
  `BimodalTools/CanonicalWire/Cert.lean`.
- Literature chunks: Biere — `(k, l)-loop|LoopConstraints|InLoop|ultimately periodic|lasso`; HWZ —
  `Definition 1[0-9]|Definition 2[0-9]|Lemma 17|Lemma 23|Theorem 24|state function|state
  candidate|periodic|hZ, <i`.

### Files read

This repository: `specs/706_*/reports/01_*.md` (lines 1-60, 158-247, 401-520);
`specs/703_*/summaries/07_*.md` (1-200); `specs/703_*/plans/02_*.md` (372-386);
`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` (all);
`PlusSlicedCertificate/Basic.lean` (140-153, 280-349); `Stable.lean` (722-861); `Check.lean`
(565-595); `Complete.lean` (558-570); `EmbedComplete.lean` (1383-1425, 1492-1540);
`FixtureStable.lean` (8-100); `Position.lean` (60-80); `BimodalTools/README.md` (76-130,
202-250); `BimodalTools/CanonicalWire/Cert.lean` (372-392);
`WitnessFamily/README.md` (28-65); `specs/701_*/summaries/01_*.md` (headings, 87-112);
`.claude/context/formats/report-format.md`.

Paired repository (read-only): `specs/TODO.md` (entries 200, 219); `docs/ADEQUACY.md` (3-35,
444-507, 606-660, 690-752, 869-911); `docs/TRUST_PIPELINE.md` (300-390); `docs/ARCHITECTURE.md`
(263-290); `docs/SEARCH_COVERAGE.md` (headings, 84-120); `docs/SETTINGS.md` (36, 42, 230);
`semantic/witness_registry.py` (20-45, 125-132); `semantic/certificate.py` (43, 173, 177, 563);
`semantic/checker.py` (1-23); `semantic/{core,model,proposition}.py` (D8 anchors).

Literature: `babiak_et_al_2015_hanoi_omega_automata_format/chunk_0001-0016.md`;
`biere_…_2006_…/chunk_{0004,0016,0017,0064}.md`; `hodkinson_wolter_zakharyaschev_2000_…/
chunk_{0020,0021,0022,0028,0030,0031,0032,0033}.md`; `~/Projects/Literature/SOURCES.md` (1066-1072).
