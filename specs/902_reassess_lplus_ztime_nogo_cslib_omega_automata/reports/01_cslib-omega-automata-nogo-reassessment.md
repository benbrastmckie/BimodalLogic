# Research Report: Task #902 — re-assessing the L⁺ ZTime completeness NO-GO against CSLib's deterministic ω-automata

**Task**: 902 - Re-assess the L-plus ZTime completeness NO-GO against CSLib's deterministic omega-automata inventory, including the local fork
**Started**: 2026-11-09T13:05:00Z
**Completed**: 2026-11-09T13:28:32Z
**Effort**: one research dispatch (orchestrated, seq 1)
**Dependencies**: None (prior art: the archived CSLib ω-automata survey; the completeness-programme report)
**Sources/Inputs**:
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` (the report whose NO-GO ground this task re-tests), read this session
- `specs/archive/736_cslib_omega_automata_survey_and_e3_reopen_check/summaries/01_cslib-omega-automata-survey-summary.md` (prior art and its six-item operator hand-off list), read this session
- `~/Projects/cslib` — the local fork (`benbrastmckie/cslib`), branch `main`, HEAD `3bdf16d9f`; working tree inspected directly, build cache used for axiom measurement
- `~/Projects/cslib` git objects for `upstream/main` = `leanprover/cslib` HEAD `1e285fd14` (fetched 2026-11-09 04:47 local); all upstream claims read via `git show upstream/main:<path>`, never from the worktree
- `~/Projects/cslib-pr648` — branch `rebase/pr648-upstream`, HEAD `49a17094a`
- `/home/benjamin/Projects/BimodalLogic/.lake/packages/mathlib` at `79d0395a1825` (tag `v4.33.0-rc1`) — the Mathlib-absence claim re-verified here
- This repository: `lakefile.toml`, `lake-manifest.json`, `lean-toolchain`, `FormalSystem/PlusLanguage/PlusPasting.lean`, `FormalSystem/Metalogic/Expressiveness/SeparationZ/Discharge.lean`, `FormalSystem/Semantics/OrientedForest.lean`
- `gh pr list --repo leanprover/cslib --author benbrastmckie --state all` (read-only GitHub API)
- No literature source was referenced by the dispatch; the literature-extraction protocol does not apply.
**Artifacts**:
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Status vocabulary

*Measured* — an axiom profile obtained this session by `#print axioms` through `lake env lean` against a build cache verified to post-date its sources. *Read* — a declaration or line number read directly from the file this session. *Counted* — a number produced this session by `git`, `find`, `wc`, or a script run here. *Derived* — a paper inference made this session from read material. *Carried* — inherited from a prior record and not re-derived (flagged as such at each use). No claim below is a completeness claim, and nothing here changes any file under `FormalSystem/`, `Tests/`, `lakefile.toml`, or `lake-manifest.json`.

## Executive Summary

**Amended by** specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md, 2026-11-09: (O1) is settled as a split — a deterministic Muller automaton suffices for the Auxiliary-Atoms rule (which carries no acceptance condition) and does not suffice for the ban/lull mechanism (whose banned list is indexed by the automaton's accepting pairs), so (O1) is preserved with its ground sharpened rather than vanishing, and `Muller.toRabin_exists` is the single highest-value `proof_wanted` in either tree. (O2) is discharged for free under a named composition order (union on the Muller side first, determinize once afterwards, via the already-proved `Muller.exists_iSup`), so the obstruction count drops from four components to three. The report's outcome — a located obstruction, "do not `require` anything now" — is otherwise unchanged.

- **The NO-GO's stated ground is overturned; the NO-GO itself stands on a relocated, far narrower obstruction.** "Deterministic ω-automata are absent from Mathlib" is *re-verified true of Mathlib* (`Mathlib/Computability/` at `79d0395a` has DFA, NFA, EpsilonNFA, RegularExpressions, MyhillNerode and **zero** matches for Buchi/Büchi/Muller/Rabin/ω-regular). But as a statement about the reachable Lean ecosystem it is wrong: **CSLib upstream already carries the whole ω-regular closure lattice including complementation**, and the local fork carries **McNaughton determinization to Muller, proved, sorry-free, with a measured-clean axiom profile**. The MSO analogy that the NO-GO rests on therefore does not transfer.
- **What actually blocks a Lean proof is now three specific items, not "Mathlib has no ω-automata".** (i) Determinization to **Rabin or parity** is `proof_wanted` even in the fork — `Muller.toRabin_exists` and `Rabin.toParity_exists`, `DA/Conversions.lean:112` and `:89`; the fork's own source comment states that `IsRegular.iff_da_rabin` and `IsRegular.iff_da_parity` are consequently unavailable. (ii) The **indexed conjunctive product with a nameable initial state** is absent from both trees. (iii) Every determinization result in the fork is existential over `Type` (`∃ (State : Type) (_ : Finite State) (da : …)`), whereas the Auxiliary-Atoms rule needs the automaton as *nameable syntax*.
- **Deliverable (2), the decisive question, splits in two and the dispatch's framing of it is a category error that must be corrected.** The "full-product / pasting lemma" the architecture consumes at its single separation-consumption point is a **TaskFrame semantics** fact (the stability cluster's type set is `PT(w₀) × FT(w₀)`), not an automata-theory fact. CSLib cannot supply it in any version; it is absent in-tree and is this repository's own obligation. Its compiled cores are landed and measured clean (`paste`, `paste_agreeUpTo`, `paste_agreeFrom`, `truth_congr_agreeUpTo`, `truth_congr_agreeFrom`). Separately, the *automaton-side* indexed product with conjunctive acceptance **is** genuinely absent from both upstream and fork — and is **cheap**, because `Rabin.toStreett_language_eq` (complement, proved) plus `prod_run_infOcc_fst`/`_snd` (proved) plus Rabin's existential-over-pairs acceptance reduce it to a preimage-lift argument of the order of 100-150 lines.
- **The dependency-cost picture is the inverse of the dispatch's framing.** The **fork** is on `leanprover/lean4:v4.33.0-rc1` — *the same toolchain as this project* — and its Mathlib pin `169c26b5` is a **strict descendant** of this project's `79d0395a`, **76 commits ahead and 0 behind**, four days later, inside the same release. **Upstream** is on `v4.36.0-rc2` with Mathlib `887bb849`, three toolchain releases away. Consuming upstream-only material is the *expensive* option; consuming the fork is a 76-commit Mathlib fast-forward within one toolchain. The compile cost of the ω-automata layer is bounded: **51 Cslib modules, 8,526 lines**, containing **no** `Cslib.Logics.*`.
- **Two dispatch premises are factually wrong and are corrected here.** `prod_run_eq` is **fork-only**, not upstream (upstream `DA/Prod.lean` carries only `prod` and `prod_mtr_eq`, the latter about `mtr` over a finite `List`, not `run` over an ω-sequence). And the fork is not merely "~4717 commits ahead": it is **4717 ahead and 235 behind** `upstream/main`, and the fork worktree **lacks** `OmegaSequence/Topology.lean` (which the dispatch lists as part of the infrastructure it would consume) along with twelve other modules upstream has since added.
- **Upstreaming instead is the right recommendation but has no track record yet.** All eight fork-only DA modules are the operator's own work (`Copyright (c) 2026 Benjamin Brast-McKie`), so upstreaming is entirely within the operator's control, and `IsRegular.iff_da_muller` fills a `proof_wanted` **upstream itself wrote** — the single most upstreamable item in the tree. Against that: of 11 PRs from this author to `leanprover/cslib`, **zero are merged** (8 closed unmerged, 3 open: #648, #649, #662), and **none** of them is the ω-automata material, which has never been offered upstream.
- **Prior art discharges deliverable (1) partially and deliverables (2)-(4) not at all.** The archived survey's own hand-off item (e) is the standing "port nothing, no `require`" recommendation; its rejection ground ("76 Mathlib commits divergent") is re-measured here as 76 commits *forward only, same toolchain*, which is a materially different and cheaper proposition than "divergent". Its claims that survive re-verification are named individually in Finding 1.

## Context & Scope

The dispatch re-tests exactly one premise of the completeness-programme report's verdict: that the deterministic ω-automaton the Reynolds engine needs is unavailable, on the ground that it is "absent from Mathlib" and therefore in the same refusal class as the MSO route. The architecture itself was not re-derived — the report owns it, and this report builds on its Findings 2.4 (the separation-consumption point) and 3 (the 21-row ingredient table) as read.

Constraints honoured: ZTime only; nothing under `FormalSystem/` or `Tests/` touched; no edit to `lakefile.toml` or `lake-manifest.json`; no `require` added; no completeness claim made. The only Lean execution was two read-only `lake env lean` probe runs in the session scratchpad, measuring axiom profiles against pre-existing build caches. `lean-lsp` was available (`registered`/`reachable`) but was not needed: every claim here is a file-level or build-level fact, re-derived by `git`, direct file read, or `#print axioms`, which is the stronger evidence tier.

Both blocked MCP tools (`lean_diagnostic_messages`, `lean_file_outline`) were avoided.

## Domain Analysis

The question is an *inventory and trust* question with one genuinely mathematical core. The inventory half is mechanical: which declarations exist, where, with what axiom profile, under which toolchain. The mathematical core is deliverable (2): what the architecture's single separation-consumption point actually demands of an automaton construction, and whether a binary product with a run-decomposition lemma can discharge it. The answer turns on the quantifier structure of the acceptance conditions — Rabin's `∃ pair ∈ pairs`, Streett's `∀ pair ∈ pairs` — which is what makes finite unions of DRAs cheap and finite intersections of DRAs not, and which is why the architecture's "universal non-acceptance in every component" is the cheap direction once stated correctly.

## Findings

### 0. What the prior art discharges, and what it does not

The archived survey's summary was read in full. Its six-item operator hand-off list, assessed against this task's four deliverables:

| Hand-off item | Bears on | Discharged? |
|---|---|---|
| (a) stale `Nat.nth` note in `InfiniteRamseyPairs.lean` | nothing here | not relevant |
| (b) two stale `ROADMAP.md` E3 sentences | the record, not this assessment | not relevant |
| (c) three context-extension recommendations (`proof_wanted` as a trust surface; an `external-library-port-assessment.md` pattern; a literature stem-collision pass) | method | **still open**; this report re-uses (c)'s first idea and extends it (see Context Extension Recommendations) |
| (d) three WANTED literature sources (Kupferman–Vardi FOCS 2005; Grädel–Thomas–Wilke 2002; Hodkinson–Reynolds §§5.10-5.11 bodies) | the paper proof, not the Lean route | **still open**, untouched here |
| (e) "port nothing; treat cslib as a read-only reference", with the `require` dissent rejected on the ground that it would drag this tree 76 Mathlib commits forward | **deliverable (4)** | **partially discharged, and its ground is re-measured** — see Finding 4 |
| (f) `file_scope` drift in `state.json` | nothing here | not relevant |

What the prior art **does** discharge: parts of deliverable (1). Three of its claims re-verified true this session, by direct read rather than carry-over:

1. `IsRegular.iff_da_muller` is `proof_wanted` upstream and proved in the fork. **Re-verified**, with current line numbers: upstream `OmegaRegularLanguage.lean:261` (`proof_wanted`), fork `:440` (theorem, with `of_da_muller` at `:305` and `to_da_muller` at `:409`). The survey cited `:259`/`:440` against an older upstream head; the upstream line has moved by two, the fork line has not.
2. `NA/BuchiCompl.lean` remains a non-resource. **Re-verified**: `complement_language_sub`, `complement_language_sup`, `complement_language_eq` are `proof_wanted` at lines **293, 321, 328**, exactly as the survey recorded. The file's 16 other declarations are real, but the three naming theorems emit nothing. A `grep -c sorry` of 0 on that file is still a false negative.
3. The shared-Ramsey-core claim: `buchiFamily_cover` applying `infinite_graph_ramsey`. **Re-verified in both trees** — upstream `Congruences/BuchiCongruence.lean:122` (applying `infinite_graph_ramsey` at `:129`), fork `:118` (at `:125`). The fork additionally applies `infinite_graph_ramsey` a second time at `:334`.

What the prior art **does not** discharge:

- **Deliverable (2) entirely.** The survey predates the completeness-programme report and never asks the pasting-lemma question. Its device-level reasoning is about the Ramsey core of Büchi complementation, not about the initialisation of a clock-anchored product automaton.
- **Deliverable (3) entirely.** The survey's verdict is about E3's device selection on the seam-gluing front. The NO-GO it is being asked to re-test did not exist yet.
- **The decisive half of deliverable (4).** The survey's rejection ground is a Mathlib-divergence count. That count is re-measured here and its *character* changes (Finding 4): the divergence is a one-directional fast-forward inside a single toolchain release, not a divergence, and the fork's toolchain now *matches* this project's while upstream's does not.
- **Deliverable (1)'s Rabin/Streett/Parity rows.** The survey's inventory predates `DA/Rabin.lean`, `DA/Parity.lean`, `DA/Conversions.lean`, `DA/MullerClosure.lean`, `DA/BuchiChar.lean`, and `NA/Emptiness.lean` as a question; it reports none of them.

### 1. Deliverable (1): the verified inventory

Every row re-derived this session. **Upstream** = present in `git show upstream/main:<path>` at `1e285fd14`. **Fork-only** = present in the `~/Projects/cslib` worktree at `3bdf16d9f` and absent upstream. **Axioms** = measured this session by `#print axioms` via `lake env lean` against the fork's build cache (oleans 2026-07-27 11:24-11:25, every relevant source mtime ≤ 11:20:41, so the cache is consistent with the sources); `·3` abbreviates `[propext, Classical.choice, Quot.sound]`, the standard Mathlib three, and **no** measured declaration depends on `sorryAx` or any custom axiom.

#### 1a. The ω-sequence and ω-language substrate

| Ingredient | Declaration | Where | Status | Axioms |
|---|---|---|---|---|
| ω-word type | `ωSequence` (a `structure` with a `FunLike ℕ α` instance, **not** a bare function) | `Foundations/Data/OmegaSequence/Defs.lean:34,39` | upstream | — |
| infinity set | `infOcc` and API | `OmegaSequence/InfOcc.lean` | upstream | — |
| flattening, prefixes, temporal ops | `Flatten`, `Init`, `Temporal` | `OmegaSequence/{Flatten,Init,Temporal}.lean` | upstream | — |
| ω-word topology | `OmegaSequence/Topology.lean` | — | **upstream only; ABSENT from the fork worktree** | — |
| ω-regularity | `IsRegular p := ∃ (State : Type) (_ : Finite State) (na : NA.Buchi State Symbol), language na = p` | `Languages/OmegaRegularLanguage.lean:37` (fork `:40`) | upstream | — |
| universe polymorphism of the witness | `isRegular_iff` | `:51` (fork `:54`) | upstream | ·3 |

#### 1b. Deterministic acceptance types

| Ingredient | Declaration | Where | Status | Axioms |
|---|---|---|---|---|
| deterministic automaton | `DA` (extends `FLTS`), `run'`, `run`, `run_zero`, `run_succ`, `mtr_extract_eq_run` | `Automata/DA/Basic.lean:37,47,53,56,61,66` | upstream | — |
| DBA | `Buchi` + `ωAcceptor` instance | `DA/Basic.lean:91,99` | upstream | — |
| DMA | `Muller` + `ωAcceptor` instance | `DA/Basic.lean:106,115` | upstream | — |
| DFA-as-`DA` | `FinAcc` + `Acceptor` instance | `DA/Basic.lean:73,84` | upstream | — |
| DBA = ω-limit of a DFA | `buchi_eq_finAcc_omegaLim` | `DA/Buchi.lean:26` | upstream | — |
| **DRA** | `Rabin` (`pairs : Set (Set State × Set State)`) + `ωAcceptor` instance: `∃ pair ∈ pairs, infOcc ∩ pair.1 = ∅ ∧ (infOcc ∩ pair.2).Nonempty` | `DA/Rabin.lean:57,67` | **fork-only** | no axioms (structure) |
| **DSA** | `Streett` + `ωAcceptor` instance: `∀ pair ∈ pairs, (infOcc ∩ pair.2).Nonempty → (infOcc ∩ pair.1).Nonempty` | `DA/Rabin.lean:87,97` | **fork-only** | no axioms (structure) |
| **DPA** | `Parity` + `ωAcceptor` instance (needs `[Finite State]`) | `DA/Parity.lean:69,79` | **fork-only** | no axioms (structure) |
| genuinely missing upstream | Rabin, Streett, Parity — **none** present at `1e285fd14` | — | **missing upstream** | — |

#### 1c. Products, closure, and conversions — the rows deliverable (2) turns on

| Ingredient | Declaration | Where | Status | Axioms |
|---|---|---|---|---|
| binary `DA` product | `DA.prod` | `DA/Prod.lean:27` | upstream | none |
| product transition over a finite `List` | `prod_mtr_eq` | `DA/Prod.lean:34` | upstream | ·3 |
| product **run** over an ω-sequence | `prod_run_eq : (da1.prod da2).run xs n = (da1.run xs n, da2.run xs n)` | `DA/Prod.lean:41` | **fork-only** (dispatch places this upstream; **wrong**) | ·3 |
| product `infOcc` projections | `prod_run_infOcc_fst`, `prod_run_infOcc_snd` (`Prod.fst '' infOcc(prod run) = infOcc(run₁)`, needs both `[Finite]`) | `DA/MullerClosure.lean:41,60` | **fork-only** | ·3 each |
| DBA binary **intersection** | `Buchi.inter` (counter construction) + `Buchi.inter_language_eq` | `DA/BuchiClosure.lean:189,444` | **fork-only** | ·3 |
| DBA binary union | `Buchi.union` + `union_language_eq` | `DA/BuchiClosure.lean:44,54` | **fork-only** | ·3 |
| DBA not closed under complement | `Buchi.not_closed_complement`, with witness `Buchi.infOftenOne` | `DA/BuchiClosure.lean:135,84` | **fork-only** | ·3 |
| DMA binary union | `Muller.union` + `union_language_eq` | `DA/MullerClosure.lean:83,91` | **fork-only** | ·3 |
| DMA finite **union** lift | `Muller.exists_iSup`, `Muller.exists_iSup_univ` (both existential over `Type`) | `DA/MullerClosure.lean:125,146` | **fork-only** | ·3 each |
| **DMA / DRA / DSA / DPA finite INTERSECTION, or any indexed product** | — | — | **GENUINELY MISSING from both trees** | — |
| DBA → DRA | `Buchi.toRabin` + `toRabin_language_eq` (one pair `(∅, accept)`) | `DA/Rabin.lean:112,123` | **fork-only** | ·3 |
| DBA → DMA | `Buchi.toMuller` + `toMuller_language_eq` | `DA/BuchiChar.lean:76,88` | **fork-only** | ·3 |
| DRA → DMA | `Rabin.toMuller` + `toMuller_language_eq` | `DA/Rabin.lean:154,163` | **fork-only** | ·3 |
| DRA ↔ DSA duality (**complement**) | `Rabin.toStreett_language_eq : language a.toStreett = (language a)ᶜ`; `Streett.toRabin_language_eq` likewise | `DA/Rabin.lean:189,217` | **fork-only** | ·3 each |
| DPA → DRA | `Parity.toRabin` + `toRabin_language_eq` | `DA/Parity.lean:99,134` | **fork-only** | ·3 |
| **DMA → DRA** | `Muller.toRabin_exists` | `DA/Conversions.lean:112` | **`proof_wanted` in the fork; emits nothing** | — |
| **DRA → DPA** (LAR) | `Rabin.toParity_exists` | `DA/Conversions.lean:89` | **`proof_wanted` in the fork; emits nothing** | — |

#### 1d. The ω-regular closure lattice and determinization

| Ingredient | Declaration | Where | Status | Axioms |
|---|---|---|---|---|
| `⊥`, `⊤` | `IsRegular.bot`, `.top` | upstream `:82,94` | upstream | — |
| binary sup / inf | `IsRegular.sup`, `.inf` | upstream `:110,131` | upstream | ·3 (`inf` measured) |
| **finite indexed sup / inf** | `IsRegular.iSup`, `IsRegular.iInf` (`{I} [Finite I] {s : Set I}`) | upstream `:151,165` | upstream | ·3 each |
| prefix concatenation, ω-power | `IsRegular.hmul`, `.omegaPow` | upstream `:179,188` | upstream | — |
| Büchi normal form | `IsRegular.eq_fin_iSup_hmul_omegaPow` | upstream `:196` | upstream | — |
| Ramsey cover | `fin_cover_saturates`, `fin_cover_saturates_compl`, `buchiFamily_cover` | upstream `:225,241`, `BuchiCongruence.lean:122` | upstream | — |
| **complementation** | `IsRegular.compl` | upstream `:250` | **upstream, PROVED** | ·3 |
| DMA language is ω-regular | `IsRegular.of_da_muller` | fork `:305` | **fork-only** | ·3 |
| ω-regular ⇒ ∃ DMA (Choueka route) | `IsRegular.to_da_muller` | fork `:409` | **fork-only** | ·3 |
| **McNaughton** | `IsRegular.iff_da_muller` | upstream `:261` **`proof_wanted`**; fork `:440` **theorem** | **fork-only proof** | ·3 |
| `IsRegular.iff_da_rabin`, `iff_da_parity` | — | — | **absent from both**; the fork's own source comment (`OmegaRegularLanguage.lean`, after `:440`) names them as blocked on the two `DA/Conversions.lean` `proof_wanted`s | — |
| Choueka machinery | `chouekaLang`, `chouekaLang_regular`, `chouekaLang_omega_power_eq_omega_limit` | `DA/Choueka.lean:65,221,459` | **fork-only** | ·3 |
| concat automaton | `DA.concat` (noncomputable), `concat_language_eq` | `DA/Concat.lean:136,720` | **fork-only** | ·3 |
| DBA emptiness | `language_nonempty_iff`, `language_eq_bot_iff` | `NA/Emptiness.lean:147,153` | **fork-only** | — |
| DBA characterisation of DMA | `Muller.dba_recognizable_iff_closedUnderSuperloops` and two halves | `DA/BuchiChar.lean:132,159,175` | **fork-only, all three `proof_wanted`** | — |
| NBA complementation (named) | `complement_language_{sub,sup,eq}` | `NA/BuchiCompl.lean:293,321,328` | **fork-only, all three `proof_wanted`** | — |

**Sorry census, fork-only modules** (counted this session): `sorry` = **0** in every one of `DA/{Rabin,Parity,Choueka,MullerClosure,BuchiClosure,BuchiChar,Concat,Conversions,Prod}`, `NA/{BuchiCompl,Emptiness}`, and `Languages/OmegaRegularLanguage.lean`. `proof_wanted` = 3 in `DA/BuchiChar.lean`, 2 in `DA/Conversions.lean`, 3 in `NA/BuchiCompl.lean`, 0 elsewhere. The "reported sorry-free" claim in the dispatch is **confirmed by measurement**: 32 declarations profiled, all `·3` for theorems and axiom-free for structures, `lake env lean` exit 0, no `sorryAx` anywhere.

**`proof_wanted` is a trust surface distinct from `sorry`.** It elaborates and discards, adding nothing to the environment. A zero `sorry` count on `DA/Conversions.lean` and `NA/BuchiCompl.lean` is therefore literally true and completely uninformative — those two files together contribute **five** named-but-absent theorems. `#print axioms` cannot detect them either, because there is no constant to profile. The only reliable detector is a `grep '^proof_wanted'` census, which is why one is given above.

#### 1e. Corrections to the dispatch's own inventory

| Dispatch claim | Verified status |
|---|---|
| `DA` at `DA/Basic.lean:37`, `Buchi` at `:91`, `Muller` at `:106`, upstream | **correct**, exactly |
| `DA.prod` **with `prod_run_eq`** in `DA/Prod.lean`, upstream | **wrong**: upstream has `prod` + `prod_mtr_eq` only; `prod_run_eq` is fork-only |
| Buchi complementation and the `IsRegular` closure lattice upstream | **correct** (`IsRegular.compl` upstream `:250`, proved) |
| `OmegaSequence` infrastructure `InfOcc, Flatten, Init, Temporal, Topology` | **correct of upstream; `Topology.lean` is ABSENT from the fork worktree** |
| upstream lacks McNaughton; `proof_wanted` at `OmegaRegularLanguage.lean:261` | **correct**, exactly |
| upstream has no Rabin, Streett or Parity | **correct** |
| fork adds `Rabin`/`Streett` + `ωAcceptor` + four `_language_eq` conversion theorems | **correct**, all four measured clean |
| fork adds `Parity` with `Parity.toRabin_language_eq` | **correct** |
| fork adds Choueka, `chouekaLang_regular`, `chouekaLang_omega_power_eq_omega_limit` | **correct** |
| fork adds DMA finite-union closure via the product automaton (`MullerClosure.lean`) | **correct** — note **union**, not intersection |
| fork proves `IsRegular.iff_da_muller`, both directions, Choueka route ported from `ctchou/AutomataTheory` | **correct** (the fork's own docstring names the port source) |
| fork-only `DA/{Concat,Conversions,BuchiChar,BuchiClosure}`, `NA/{BuchiCompl,Emptiness}` | **correct**; `Conversions` is `proof_wanted`-only and `BuchiCompl`'s three naming theorems likewise |
| fork ~4717 commits ahead of upstream | **incomplete**: `git rev-list --left-right --count upstream/main...HEAD` = **235 4717** — 4717 ahead **and 235 behind** |
| `cslib-pr648` is on `rebase/pr648-upstream` and carries only the upstream DA set | **correct** (HEAD `49a17094a`, DA tree = `{Basic, Buchi, Congr, Prod, ToNA}`, `iff_da_muller` `proof_wanted` at `:260`); additionally it is on `v4.34.0-rc1`, a third toolchain, and also lacks `Topology.lean` |
| this project's `lake-manifest.json` lists only mathlib, batteries, aesop, Qq, proofwidgets, Cli, plausible, LeanSearchClient, importGraph | **correct**; no CSLib entry, and no `require` on it in `lakefile.toml` |

The 235-commit lag matters: upstream has added, since the fork's merge base, `Foundations/Data/OmegaSequence/Topology.lean`, `Languages/SafetyLiveness.lean`, `Languages/{KleeneAlgorithm, RegularExpressions, Slice, SyntacticMonoid, LanguageHom}.lean`, `Languages/Congruences/{Basic, MyhillCongruence}.lean`, `Automata/NA/{Preimage, Reverse}.lean`, `Automata/TwoWayNA/{Basic, ComplToNA, OfNA}.lean`, and `Automata/EpsilonNA/{OfRegularExpression, ThompsonConstruction}.lean` — none of which is in the fork worktree. `SafetyLiveness.lean` is directly on-topic for the report's observation that the violation language "is not a safety language"; the fork does not have it.

### 2. Deliverable (2): the full-product / pasting lemma at the separation-consumption point

The architecture's single separation-consumption point, as the completeness-programme report states it (its Finding 2.4): initialise the forward automaton with the **product over `pt ∈ PT(w₀)`** of the `pt`-indexed automata, with its initial state a function of `γ_{colour(w₀)}` so that the fresh-atom formula `θ_f` can *state* it, and **require universal non-acceptance in every component**. The report's own ingredient table records the enabling lemma as row 8, "Full-product lemma at the cut", status **missing (derived)**, proposal `[P7 stability_cluster_type_product_lemma]`, to be proved "from `paste`, `paste_agreeUpTo/From`".

**The dispatch's question contains a category error, and correcting it is the first half of the answer.** Row 8 is not an automata-theory lemma. Its content is that the stability cluster's realised `(past-type, future-type)` set is the **full Cartesian product** `PT(w₀) × FT(w₀)` — a statement about `WorldHistory`, `TaskFrame.IsRegular`, and free pasting at a state. No version of CSLib, upstream or fork, contains or could contain it: CSLib has no notion of a task frame, a world history, or a hue. Asking whether the fork "has the full-product / pasting lemma" is therefore not answerable as posed; the honest answer is that it is **this repository's own obligation and is absent in-tree**.

Verified in-tree this session, with measured axiom profiles:

| Declaration | Where | Axioms (measured) |
|---|---|---|
| `paste` | `FormalSystem/PlusLanguage/PlusPasting.lean:136` | `[propext, Quot.sound]` |
| `paste_agreeFrom` | `PlusPasting.lean:259` | `[propext, Quot.sound]` |
| `paste_agreeUpTo` | `PlusPasting.lean:271` | `[propext, Quot.sound]` |
| `truth_congr_agreeFrom` (hypothesis `IsPureFuture φ`) | `PlusPasting.lean:281` | `[propext]` |
| `truth_congr_agreeUpTo` (hypothesis `IsPurePast φ`) | `PlusPasting.lean:306` | `[propext]` |
| `paste_valid` | `PlusPasting.lean:334` | `·3` |
| `separationOver_ztime` | `Metalogic/Expressiveness/SeparationZ/Discharge.lean:93` | `·3` |
| `saturation_of_orientedForest` | `Semantics/OrientedForest.lean:134` | `·3` |
| **the full-product lemma itself** | — | **absent**: a grep for `full_product`/`fullProduct`/`type_product`/`pastType`/`futureType`/`clusterType` over `FormalSystem/**/*.lean` returns **nothing** |

So row 8 stands exactly as the report left it: derived on paper, unproved in Lean, cores landed and clean.

**The second half of the answer is the automaton-side construction, and here the dispatch's premise is right: `DA.prod` plus `prod_run_eq` is strictly weaker than what the step needs, and the gap is real in both trees.** Precisely what is missing, and precisely what is present:

*What the step needs.* An indexed family `A : PT(w₀) → DRA` over a finite index set, folded into **one** deterministic automaton whose (a) state type is explicit, (b) initial state is a function of `colour(w₀)` alone, and (c) language is `⋂_{pt} L(A_pt)ᶜ`, i.e. the complement of the finite union of the component violation languages. (c) is the correct reading of "universal non-acceptance in every component", and getting the direction right is what makes the construction cheap rather than expensive.

*What is present.* `DA.prod` is **binary** and gives the state type `State1 × State2`. `prod_run_eq` (fork-only) decomposes the product run pointwise but says nothing about acceptance. `prod_run_infOcc_fst`/`_snd` (fork-only) relate the product run's infinity set to the components' by image under the projections, under `[Finite]` on both. `Buchi.inter`/`inter_language_eq` (fork-only) is a binary **DBA** intersection — but the architecture's language is explicitly not DBA-recognizable (it carries liveness via `untl` *and* needs the complement, and `Buchi.not_closed_complement` is proved in the fork). `Muller.exists_iSup`/`exists_iSup_univ` (fork-only) is a finite **union** lift, and is existential over `Type`. At the *language* level, `IsRegular.iInf` and `IsRegular.compl` give finite intersection and complementation — **both upstream, both proved** — so the *closure property* is already available with no fork dependency at all; what is unavailable is a *named automaton realising it*.

*What it would cost.* Much less than the gap's description suggests, because of the quantifier structure. Rabin acceptance is `∃ pair ∈ pairs`, so on the binary product with each component's pairs lifted by preimage (`(Prod.fst ⁻¹' E, Prod.fst ⁻¹' F)` and the `snd` analogue) and `pairs := fstLift '' a1.pairs ∪ sndLift '' a2.pairs`, the product DRA accepts iff **some** component accepts — the finite **union** of DRA languages is a DRA. The only lemma needed is the image/preimage transfer `(infOcc(prod run) ∩ Prod.fst ⁻¹' F).Nonempty ↔ (Prod.fst '' infOcc(prod run) ∩ F).Nonempty`, which is a one-line `Set` fact composed with the already-proved `prod_run_infOcc_fst`. Then **the complement is already proved**: `Rabin.toStreett_language_eq : language a.toStreett = (language a)ᶜ`, which is exactly "universal non-acceptance", delivered as a DSA on the *same state space*. Finally the finite-index lift mirrors `Muller.exists_iSup`'s 25-line `Set.ncard` induction. Estimate: a `Rabin.union`/`union_language_eq` pair plus a `Rabin.exists_iSup` lift, **of the order of 100-150 lines**, all of it inside the fork's existing idiom with every supporting lemma already proved and measured clean. The expensive-looking dual — a finite *intersection* of DRAs as a DRA — is not what the step needs and should not be attempted.

*What remains expensive even then, and this is the real obstruction.* The construction above folds DRAs that must already exist. They do not. The chain is: the violation language is ω-regular (**entirely absent — not even stated in-tree**) → `∃` DMA (fork, `iff_da_muller`, **proved**) → `∃` DRA (`Muller.toRabin_exists`, **`proof_wanted` in the fork**) → union/complement (**missing, cheap, as costed above**). The second arrow is the break. And one step further out, even a DRA obtained existentially is not yet usable: the AA rule needs the automaton as *syntax* — `θ_f` must name the initial state and the transition table to encode the run in fresh state-valued atoms — whereas `iff_da_muller` and `Muller.toRabin_exists` both deliver `∃ (State : Type) (_ : Finite State) (da : …)`. Extracting a concrete `Fin n` indexing from `Finite State` is classical, which is harmless for a `Prop`-valued completeness statement but makes `θ_f` non-computable, and would be fatal on the decidability front, which needs an algorithm. That is a friction cost to budget, not a refutation.

### 3. Deliverable (3): the revised verdict on the Lean route for T3

**The NO-GO stands. Its stated ground does not.**

The ground under re-test, quoted from the completeness-programme report's verdict: "Mathlib at this pin has no ω-automata and no determinization … The same obstruction blocks the MSO decidability route and is refused there outright." And its ingredient table row 16: "Deterministic Rabin automaton for the violation language — **not formalizable at this Mathlib pin**; standing refusal".

What survives:

- **The Mathlib half is re-verified true, and upgraded from carried to measured.** The report flags this claim `[CARRIED-UNVERIFIED]` from two prior records. Checked directly this session against `.lake/packages/mathlib` at `79d0395a` (tag `v4.33.0-rc1`): `Mathlib/Computability/` contains `DFA.lean`, `NFA.lean`, `EpsilonNFA.lean`, `RegularExpressions.lean`, `MyhillNerode.lean`, `Language.lean` and the Turing-machine and recursion-theory files, and a case-insensitive grep over all of `Mathlib/` for `buchi|büchi|omega-regular|ωregular|MullerAutomaton|RabinAutomaton` returns **zero files**. Mathlib has no ω-automata. The tag can be removed.

What does not survive:

- **The inference from "absent from Mathlib" to "not formalizable at this pin" is invalid, and the MSO analogy breaks.** The MSO refusal rests on there being no formalization of the needed material anywhere reachable. That is false here. CSLib **upstream** carries the ω-regular closure lattice *including complementation* — `IsRegular.compl`, proved, together with `sup`, `inf`, `iSup`, `iInf`, `hmul`, `omegaPow`, the Büchi normal form, and the Ramsey cover. The **fork** carries McNaughton determinization to Muller, proved in both directions, sorry-free, with a measured axiom profile of exactly the standard three. Row 16's "not formalizable at this Mathlib pin" is therefore wrong on its own terms, and wrong in a way that *favours* the pin: the fork is on `v4.33.0-rc1`, the same toolchain as this project (Finding 4).
- **The "standing refusal" cannot be inherited.** The refusal was entered against opening an ω-automata determinization *project*. There is no such project to open: the determinization exists, by the operator's own hand, and the residual work is a 100-150-line closure lemma plus one `proof_wanted`.

The replacement verdict, stated as a located obstruction:

> **NO-GO on a Lean proof of T1, T2 or T3 today — on a relocated obstruction with four named components, none of which is "Mathlib has no ω-automata".**
>
> **(O1) Determinization to Rabin or parity is unproved everywhere.** `Muller.toRabin_exists` (`DA/Conversions.lean:112`) and `Rabin.toParity_exists` (`:89`) are `proof_wanted` in the fork; the fork's own source states that `IsRegular.iff_da_rabin` and `IsRegular.iff_da_parity` are blocked on them. The fork's docstrings put the cost at an exponential pair blowup (DMA→DRA, `2^|Q|` pairs) and the LAR permutation construction (DRA→DPA, state space `|State| × k! × k`). **Settled:** a DMA suffices for the Auxiliary-Atoms rule, which carries no acceptance condition, and does not suffice for the ban/lull mechanism, whose banned list is indexed by the automaton's accepting pairs (Reynolds 2001 §12, `bl : T → (C × {1,…,K})*`). `Muller.toRabin_exists` is therefore load-bearing, and is the single highest-value `proof_wanted` in either tree. `Rabin.toParity_exists` is off the critical path: the ban mechanism consumes Rabin, not parity, and `Parity.toRabin_language_eq` is already proved, so of the two `proof_wanted`s named above only the first matters. Settled by `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md`.
>
> **(O2) Discharged — no longer an obstruction.** The cut product is a finite indexed **union** over `PT(w₀)` of the component violation languages, not an intersection, and `Muller.exists_iSup` (fork `DA/MullerClosure.lean:125`, proved) already supplies exactly that: from a pointwise family of existentially-DMA-recognizable languages it delivers the existentially-DMA-recognizable union. Taking the composition order as **union on the Muller side first, determinize once afterwards** means the 100-150-line Rabin-side closure item costed in Finding 2 is never needed — no new code is required. `PT(w₀)` finite is carried from `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` §2.4 and not re-derived here. Settled by `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md` §3.
>
> **(O3) The determinized automaton arrives as an existential over `Type`, not as syntax.** The AA rule needs the transition table to build `θ_f`. Classical extraction is available and harmless for a `Prop`, but makes `θ_f` non-computable and does not transfer to the decidability front.
>
> **(O4) Nothing in CSLib touches the rest.** The ω-regularity of the violation language is not stated anywhere in-tree, let alone proved. Items 17-21 of the report's ingredient table — consistency of `φ⁺`, ban preservation with `LCU`, two-sided universal non-acceptance, fair scheduling, the two-sided truth lemma — are the paper proof and are untouched by any of this. So are P1 (`LCU` declared and valid), P2-P4 (the carrier, the AA rules, the extended system), P5 (the universal cover), P6 (invariance without base *Saturation*), P7 (the full-product lemma, Finding 2), and P8 (the linear bridge). **The CSLib finding removes one item from a 21-row table and does not shorten the critical path.**

**What this changes in the record.** The report's row 16 should read: *"Deterministic ω-automaton for the violation language — ω-automata, the ω-regular closure lattice and Büchi complementation are landed in CSLib upstream; McNaughton determinization to Muller is landed, sorry-free, in the local CSLib fork, which is on this project's own Lean toolchain. Determinization to Rabin or parity is `proof_wanted` even in the fork, the indexed conjunctive product is absent from both trees (≈100-150 lines to add), and the determinized automaton arrives existentially over `Type`. Not a Mathlib-absence refusal; a located and costed gap."* The verdict sentence "Mathlib at this pin has no ω-automata and no determinization" should keep its first clause and lose the inference drawn from it. The dispatch's recommendation 6 in the report ("do not file … any ω-automata determinization project") should be narrowed: do not file a *determinization* project, which is largely done; the question is whether to depend on it.

**Not an overturn of the GO on T3 as a paper programme.** That verdict is untouched and unaffected: it never depended on the automaton being formalizable.

### 4. Deliverable (4): the dependency-cost assessment — recommendation only, not acted on

Re-verified baseline: this project `require`s only `mathlib` (`lakefile.toml:45-48`, `rev = "v4.33.0-rc1"`), and `lake-manifest.json` resolves nine packages — mathlib `79d0395a`, plausible, LeanSearchClient, importGraph, proofwidgets, aesop, Qq, batteries, Cli. **No CSLib.** Toolchain `leanprover/lean4:v4.33.0-rc1`.

#### 4a. The measured cost of each option

| | **Option A: `require` the fork** | **Option B: `require` upstream only** |
|---|---|---|
| Target | `benbrastmckie/cslib` `main` @ `3bdf16d9f` | `leanprover/cslib` `main` @ `1e285fd14` |
| Its Lean toolchain | **`v4.33.0-rc1` — identical to this project's** | `v4.36.0-rc2` — **three releases ahead** |
| Its Mathlib pin | `169c26b5`, dated 2026-07-20 | `887bb849` |
| Mathlib move required of this tree | **76 commits forward, 0 backward** (strict descendant of `79d0395a`, 4 days later, inside the same tag's window; `git describe` = `master-2026-07-19-3-g169c26b52a3`) | a full toolchain jump `v4.33.0-rc1` → `v4.36.0-rc2`, plus the Mathlib move that entails |
| Compile cost of the ω-automata layer | **51 Cslib modules, 8,526 lines** (transitive import closure of the nine ω-automata seeds, computed this session) | smaller, but delivers less |
| `Cslib.Logics.*` in that closure | **none** — verified; the fork's 500-file `Cslib/Logics/` tree, including a 139-file / 52,470-line `Logics/Bimodal/` parallel formalization of this project's own subject matter, is **not** imported by the ω-automata layer | n/a |
| Repository size carried in the manifest | 708 `.lean` files, 244,339 lines under `Cslib/` | 299 `.lean` files |
| Review status of what you depend on | **unreviewed by upstream**; 4717 commits ahead **and 235 behind**; the eight fork-only DA modules have never been offered upstream | upstream-reviewed |
| Determinization | **`iff_da_muller` PROVED** | **`proof_wanted` at `:261`** — unavailable |
| Rabin / Streett / Parity | present | **absent entirely** |
| Recurring sync cost | real: a 235-commit lag already exists and will grow; a fork that is simultaneously ahead and behind must be rebased, not fast-forwarded | upstream's own cadence, which this project would then have to track across toolchains |

#### 4b. Assessment

**Option B does not solve the problem.** Upstream has no Rabin, no Streett, no Parity, and no determinization — `iff_da_muller` is `proof_wanted`. Everything the architecture would actually consume beyond the closure lattice is fork-only. And Option B is the *more* expensive of the two on the only axis that has ever blocked a CSLib dependency here: it demands a three-release toolchain jump, where Option A demands none. The archived survey's rejection ground — "it would drag *this* tree 76 Mathlib commits forward" — was measured against the fork and is re-measured here as **76 commits forward, zero backward, four days, same toolchain release**. That is a fast-forward inside one release window, not a divergence. The ground is weaker than it reads, and it is the *wrong* ground to apply to Option B, which is far worse by the same metric.

**Option A's real cost is not the toolchain and not the line count; it is the trust surface.** 8,526 lines in 51 modules, with no `Cslib.Logics.*` in the closure, is a modest import graph, and the axiom profiles are measured clean. What is not modest: `require`ing the fork puts this project's build on a 244,339-line tree whose dominant content is a *competing* 52,470-line bimodal-logic formalization by the same author, carrying a permanent 235-commit rebase debt against an upstream that has reviewed none of it, in order to obtain roughly 2,500 lines of ω-automata — of which the one indispensable item (`iff_da_muller`) still does not reach a Rabin automaton, and of which the item the architecture most needs (the indexed conjunctive product) is absent.

**Recommendation, stated and not acted on: do not `require` either, and upstream the material instead.** The case for upstreaming is unusually strong:

- **It is entirely within the operator's control.** All eight fork-only DA modules carry `Copyright (c) 2026 Benjamin Brast-McKie. Authors: Benjamin Brast-McKie`. Nothing needs anyone's permission to submit.
- **`IsRegular.iff_da_muller` fills a `proof_wanted` upstream itself wrote.** Upstream's `OmegaRegularLanguage.lean` is Ching-Tsun Chou's, and the stub at `:261` is Chou's own statement of what is wanted. A sorry-free proof of a library's own `proof_wanted`, in the library's idiom, on the library's types, is the most upstreamable artifact there is. Submit `DA/Choueka.lean`, `DA/Concat.lean`, `DA/MullerClosure.lean` and the `of_da_muller`/`to_da_muller`/`iff_da_muller` block as one PR.
- **The Rabin/Streett/Parity layer is a natural second PR** — `DA/Rabin.lean` and `DA/Parity.lean` are 235 and 193 lines, each conversion carrying a measured-clean `_language_eq`, and upstream has nothing in that space.
- **Two modules are not candidates and should not be submitted**: `DA/Conversions.lean` (`proof_wanted` only — it declares nothing) and `NA/BuchiCompl.lean` (its three naming theorems are `proof_wanted`; the file is a non-resource, as the archived survey already found and this session re-confirmed at lines 293/321/328). `DA/BuchiChar.lean` is a partial candidate: `Buchi.toMuller_language_eq` is proved, its three characterisation theorems are not.

**The honest counterweight, which must be stated.** Upstreaming has **no track record here**. Of 11 PRs from this author to `leanprover/cslib`, **zero are merged**: 8 closed unmerged (#629, #630, #633, #635, #636, #637, #642, #647) and 3 open (#648, #649, #662). The closed ones read as supersession chains rather than rejections (#647 → #648; #635/#636/#637; #629 → #630 → #633), so this is not evidence that the material would be refused — but it is evidence that **nothing has landed yet, and that an upstream-first plan has an unbounded and so far unrealised latency**. None of the eleven is the ω-automata material; it has never been submitted.

**Therefore the recommendation, in order:**

1. **Settled: (O1) was settled on paper, before any dependency decision.** `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md` determined that a deterministic **Muller** automaton suffices for the AA rule, which carries no acceptance condition, and does not suffice for the ban/lull mechanism, whose banned list is pair-indexed. So the fork's `iff_da_muller` is *not* the determinization the architecture needs end-to-end, and the dependency question remains hypothetical rather than becoming live: `Muller.toRabin_exists` is the single highest-value `proof_wanted` in either tree.
2. **Submit the determinization block upstream** (Choueka + Concat + MullerClosure + `iff_da_muller`), as the one item with a `proof_wanted` invitation already in place.
3. **Do not `require` anything now.** Neither option is justified while (O4) stands: CSLib removes one row from a 21-row table and shortens no critical path. A `require` decision belongs after P1-P8 have landed and the automaton is the last thing left, not before.
4. **If a dependency ever becomes necessary and upstream has not merged, prefer Option A over Option B** — on the measured ground that the fork matches this project's toolchain and the Mathlib move is a 76-commit fast-forward, where upstream demands a three-release jump and still lacks determinization. This reverses the direction the archived survey's `require` dissent was rejected in, and it is a reversal of *ground*, not of the standing "do not `require` now" conclusion, which this report reaffirms.
5. **Keep treating CSLib as a read-only reference in the meantime**, which is what the archived survey recommended and what this task did.

## Recommendations

Stated as recommendations and not acted on. Nothing here was executed by this task.

1. **Settled: (O1) was settled on paper, before any dependency decision** — a deterministic **Muller** automaton suffices for the AA rule and does not suffice for the ban/lull mechanism, whose banned list is pair-indexed. The fork's already-proved `iff_da_muller` is therefore *not* the determinization the architecture needs end-to-end. Detail: Finding 3 (O1), Finding 4b recommendation 1, and `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md`.
2. **Amend the completeness-programme report's row 16 and its verdict sentence** — keep "Mathlib has no ω-automata" (now re-verified, tag removable) and drop the inference "therefore not formalizable at this pin". Replacement text is given verbatim in Finding 3 under "What this changes in the record". Narrow that report's recommendation 6 from "file no ω-automata determinization project" to "file no *determinization* project — it is largely done; the live question is whether to depend on it".
3. **Do not `require` CSLib now, in either form.** Reaffirms the archived survey's standing conclusion, on a re-measured ground (Finding 4a/4b). What changes is the ground a future `require` would be judged on, not the present answer.
4. **Submit the determinization block upstream** (`DA/Choueka.lean`, `DA/Concat.lean`, `DA/MullerClosure.lean`, and the `of_da_muller`/`to_da_muller`/`iff_da_muller` block) as one PR — it fills a `proof_wanted` upstream itself wrote. A second PR for `DA/Rabin.lean` + `DA/Parity.lean`. Do **not** submit `DA/Conversions.lean` or `NA/BuchiCompl.lean`, which declare nothing. Caveat recorded in Finding 4b: 0 of 11 prior PRs from this author are merged, so this path has unbounded latency and is not a substitute for (1).
5. **If a dependency ever becomes necessary and upstream has not merged, prefer the fork over upstream** — the fork matches this project's toolchain (`v4.33.0-rc1`) and its Mathlib pin is a 76-commit fast-forward, where upstream demands a three-release toolchain jump and still lacks determinization entirely.
6. **Withdrawn, not re-filed.** The ≈100-150-line (O2) closure lemma — a `Rabin.union` / `union_language_eq` pair plus a `Rabin.exists_iSup` finite-index lift, costed in Finding 2 — is not needed at all under the union-on-the-Muller-side-then-determinize-once ordering that `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md` §3 names, because `Muller.exists_iSup` already supplies the union for free. `Muller.compl` and `Muller.inter` are cheap but off the critical path and are deliberately not filed either.
7. **Keep P7 (the full-product lemma) owned in-tree and unchanged** — Finding 2 confirms it is a TaskFrame semantics obligation that no CSLib version can discharge. Its compiled cores are landed and measured clean; the report's row 8 stands exactly as written.
8. **File the three context extensions** through the source store resolved from `.claude-extensions.json`, via `/meta` — see Context Extension Recommendations below. The first of them was already recommended by the archived survey and remains unimplemented.

## Decisions

- **The dispatch's deliverable (2) question is answered in two parts rather than yes/no**, because its premise conflates a TaskFrame semantics lemma with an automata construction. Both halves are answered; the conflation is named.
- **The NO-GO's outcome is preserved and its ground is replaced.** A located obstruction is a complete outcome by the dispatch's own terms, and that is what is delivered: four named components (O1-O4) in place of one wrong inference.
- **Axiom profiles were measured, not inferred.** Both build caches were checked to post-date their sources before any `#print axioms` output was trusted; the fork's oleans (2026-07-27 11:24-11:25) post-date every relevant source mtime (≤ 11:20:41), and each in-tree olean post-dates its own source.
- **`proof_wanted` was censused separately from `sorry`**, because neither `grep sorry` nor `#print axioms` can see it. Five named-but-absent theorems across `DA/Conversions.lean` and `NA/BuchiCompl.lean` would otherwise have been counted as landed.
- **Upstream claims were read through `git show upstream/main:<path>`, never from the fork worktree**, so that no fork modification could be mistaken for upstream content. This is how the `prod_run_eq` misattribution was caught.
- **The upstreaming recommendation is stated with its own counter-evidence** (0 of 11 PRs merged) rather than as an unqualified preference. A recommendation whose latency is unbounded is reported as such.
- **No `require`, no `lakefile.toml` edit, no `lake-manifest.json` edit, no change under `FormalSystem/` or `Tests/`.** The two Lean runs were read-only probes in the session scratchpad.

## Risks & Mitigations

- **Risk: (O1) may be a presentational requirement rather than a real one.** If a deterministic Muller automaton suffices for the AA rule, the fork's `iff_da_muller` already *is* the determinization the architecture needs, and (O1) vanishes — which would make the revised verdict materially more favourable than stated. *Mitigation*: this is flagged as the cheapest open question in the whole assessment and is recommendation 1 above. It is a paper question about Reynolds' Lemma 13/26 and the expressibility of `infOcc ∈ accept` by state-valued atoms, settleable without any Lean work. **Discharged, negatively.** `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md` settles this: the expressibility argument is sound and `iff_da_muller` does suffice for the AA rule, but the AA rule was never the binding constraint — the ban/lull mechanism's banned list is pair-indexed and does not present as a Muller family without a walk-dependent choice only an LAR can make. (O1) does not vanish; its ground is sharpened rather than removed.
- **Risk: the fork's build cache could have masked a regression.** The oleans are 3.5 months old. *Mitigation*: every relevant source mtime was checked to precede them, and the last commit touching the DA tree (`d5b6da261`, 2026-07-27 11:20:37) precedes the oleans by four minutes. The cache is consistent with the sources, and that was verified before the measurement was trusted, not after. A full `lake build` of the fork was not run and is not claimed.
- **Risk: the 100-150-line estimate for (O2) is a derived estimate, not a measurement.** *Mitigation*: it is grounded in named, read, already-proved lemmas (`prod_run_infOcc_fst/snd`, `Rabin.toStreett_language_eq`) and in a read 25-line precedent for the finite-index lift (`Muller.exists_iSup`). No attempt was made to write the lemma, which would have required touching the fork.
- **Risk: `#print axioms` is being over-read.** It measures the axiom profile of a constant and does **not** trace declaration dependencies, nor detect `proof_wanted`. *Mitigation*: it is used here only for its actual purpose, with the `proof_wanted` census supplied separately and the dependency question handled by import-closure computation instead.
- **Risk: the `gh` PR data is a point-in-time snapshot.** *Mitigation*: dated (2026-11-09) and reported as counts with PR numbers, so it is re-checkable.
- **Risk: `ωSequence` is a `structure`, not `ℕ → α`.** Any future interoperation would need wrapping at the boundary, and the architecture's words are over ℤ (split at the cut into two ω-halves — which is compatible, since the report's design already performs that split, and cslib's one-sidedness is therefore an alignment rather than a gap). CSLib has no bi-infinite sequence type; a grep for `ZSequence`/`biInfinite`/`ℤ →` over `Cslib/` returns only unrelated hits (a multi-tape Turing machine's tapes, and the fork's own `Logics/Bimodal` material). *Mitigation*: stated, not costed; it does not arise until a `require` exists.
- **Risk: this report could be read as licensing a `require`.** It does not. Recommendation 3 reaffirms "do not `require` now". What changes is the *ground* on which a future `require` would be judged, not the present conclusion.

## Tactic Survey Results

- Not applicable (no tactic survey performed). This dispatch investigated no proof goal: every deliverable is an inventory, trust-surface, or dependency-cost question, answered by direct file read, `git` measurement, import-closure computation, and `#print axioms`. No tactic was attempted, no `lean_multi_attempt` call was made, and no goal state was opened. Recording a survey here would be fabrication.

## Context Extension Recommendations

- **Topic**: `proof_wanted` as a trust surface distinct from `sorry`.
  **Gap**: `.claude/context/project/lean4/domain/metadata-trust-surfaces.md` covers extension rows, registries and command kinds, but not the fact that `proof_wanted` elaborates and discards, so that a zero `sorry` count and a clean `#print axioms` are *both* blind to it. This session found **five** named-but-absent theorems (`DA/Conversions.lean` ×2, `NA/BuchiCompl.lean` ×3) that neither detector sees, in a tree whose own dispatch described it as "all reported sorry-free". The archived survey raised the same recommendation and it remains unimplemented.
  **Recommendation**: add a `proof_wanted` subsection to `metadata-trust-surfaces.md` naming `grep -c '^proof_wanted'` as the only reliable detector, and stating that a module consisting entirely of `proof_wanted` declares nothing.

- **Topic**: assessing an external Lean library as a candidate dependency.
  **Gap**: no pattern file covers the mechanics this task had to invent — read upstream claims through `git show upstream/main:<path>` rather than a fork worktree (which is how the `prod_run_eq` misattribution surfaced); measure `--left-right --count` in **both** directions (which is how the 235-commit lag surfaced); compare `lean-toolchain` **before** Mathlib revs (which is what inverted the cost ordering); verify a build cache post-dates its sources before trusting `#print axioms`; and compute the *import closure* of the target modules rather than the repository's line count (8,526 vs 244,339 lines — a 29× difference in the honest number).
  **Recommendation**: create `.claude/context/project/lean4/patterns/external-library-dependency-assessment.md` with that checklist. The archived survey recommended an `external-library-port-assessment.md`; this is the same need, now with a worked instance.

- **Topic**: where a verdict's *ground* can be re-tested independently of its *outcome*.
  **Gap**: nothing in `context/standards/` names the pattern this task instantiates — a prior verdict is correct in outcome and wrong in its stated reason, and the correct report preserves the outcome while replacing the reason and saying so explicitly.
  **Recommendation**: a short subsection in the report-format or status-markers standard distinguishing "outcome overturned" from "ground overturned, outcome preserved", so that a reader of a later record is not misled into thinking a NO-GO was lifted.

Per the source-store/deploy boundary rule, all three belong in the source store resolved from `.claude-extensions.json`'s `source_dir`, filed via `/meta`, not hand-authored under `.claude/**`.

## Appendix

### Commands run (all read-only)

```
# divergence, both directions — the 235-commit lag
git -C ~/Projects/cslib rev-list --left-right --count upstream/main...HEAD      # => 235  4717
git -C ~/Projects/cslib merge-base upstream/main HEAD                          # => f36649cff2c9…

# upstream content read without touching the fork worktree
git -C ~/Projects/cslib ls-tree -r --name-only upstream/main -- Cslib/Computability/Automata …
git -C ~/Projects/cslib show upstream/main:Cslib/Computability/Automata/DA/Prod.lean
git -C ~/Projects/cslib show upstream/main:Cslib/Computability/Languages/OmegaRegularLanguage.lean

# toolchain before Mathlib
cat ~/Projects/cslib/lean-toolchain                                            # v4.33.0-rc1
git -C ~/Projects/cslib show upstream/main:lean-toolchain                      # v4.36.0-rc2
cat /home/benjamin/Projects/BimodalLogic/lean-toolchain                        # v4.33.0-rc1

# Mathlib rev distance, measured in the project's own checkout
git -C .lake/packages/mathlib rev-list --left-right --count 79d0395a1825^{commit}...169c26b5…
                                                                               # => 0  76
git -C .lake/packages/mathlib describe --tags 169c26b5…        # master-2026-07-19-3-g169c26b52a3

# build-cache consistency, checked before any measurement was trusted
stat -c '%y' ~/Projects/cslib/.lake/build/lib/lean/Cslib/Computability/Automata/DA/*.olean
stat -c '%y' ~/Projects/cslib/Cslib/Computability/Automata/DA/*.lean

# axiom profiles: 32 cslib declarations, 8 in-tree declarations
lake env lean <scratchpad>/axiom-probe.lean     # in ~/Projects/cslib, exit 0
lake env lean <scratchpad>/intree-probe.lean    # in BimodalLogic,     exit 0

# proof_wanted census (neither grep sorry nor #print axioms sees these)
grep -c '^proof_wanted' Cslib/Computability/Automata/DA/{Conversions,BuchiChar}.lean
grep -n '^proof_wanted' Cslib/Computability/Automata/NA/BuchiCompl.lean   # 293, 321, 328

# Mathlib-absence claim, re-verified rather than carried
ls .lake/packages/mathlib/Mathlib/Computability/
grep -rli 'buchi|büchi|omega-regular|ωregular|MullerAutomaton|RabinAutomaton' Mathlib/   # 0 files

# import closure, not repository size
python3 <transitive-import scan over 9 omega-automata seeds>   # 51 modules, 8,526 lines, no Cslib.Logics.*

# upstreaming track record
gh pr list --repo leanprover/cslib --author benbrastmckie --state all --json number,state,mergedAt
```

### Searches not used, and why

No `lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_state_search` or `lean_hammer_premise` call was made, and no rate limit was touched. Every question this dispatch had to answer was a question about *which files and declarations exist in two named git trees, under which toolchain, with which axiom profile*. Mathlib-wide semantic search cannot answer any of those, and `lean_local_search` indexes this project rather than CSLib. The evidence tier used (direct `git show`, direct file read, `#print axioms` against a verified-consistent cache, `git rev-list` counts) is strictly stronger than an LSP-backed name lookup would have been, so this is a deliberate choice rather than a degradation. `lean-lsp` was reported `registered`/`reachable` and was simply not the right instrument.

### Line-number index for the claims above

CSLib fork (`~/Projects/cslib` @ `3bdf16d9f`): `DA/Prod.lean` 27/34/41 · `DA/Rabin.lean` 57/67/87/97/112/123/154/163/179/189/211/217 · `DA/Parity.lean` 69/79/99/134 · `DA/MullerClosure.lean` 41/60/83/91/105/113/125/146 · `DA/BuchiClosure.lean` 44/54/84/135/189/444 · `DA/BuchiChar.lean` 76/88/132/159/175 · `DA/Choueka.lean` 65/221/459 · `DA/Concat.lean` 136/720 · `DA/Conversions.lean` 89/112 · `NA/BuchiCompl.lean` 293/321/328 · `NA/Emptiness.lean` 147/153 · `Languages/OmegaRegularLanguage.lean` 40/54/305/409/440 · `Languages/Congruences/BuchiCongruence.lean` 118/125/334.

CSLib upstream (`leanprover/cslib` @ `1e285fd14`): `DA/Basic.lean` 37/47/53/73/84/91/99/106/115 · `DA/Buchi.lean` 26 · `DA/Prod.lean` 27/34 · `Languages/OmegaRegularLanguage.lean` 37/51/82/94/110/131/151/165/179/188/196/225/241/250/261 · `Languages/Congruences/BuchiCongruence.lean` 122/129.

This repository (`d4dc3d5ff`): `FormalSystem/PlusLanguage/PlusPasting.lean` 136/259/271/281/306/334/350 · `FormalSystem/Metalogic/Expressiveness/SeparationZ/Discharge.lean` 93 · `FormalSystem/Semantics/OrientedForest.lean` 134 · `lakefile.toml` 45-48.

### References

- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` — the completeness-programme report; its Finding 2.4 (separation-consumption point), its 21-row ingredient table (row 8 = the full-product lemma, row 16 = the automaton), and the verdict this task re-tests
- `specs/archive/736_cslib_omega_automata_survey_and_e3_reopen_check/summaries/01_cslib-omega-automata-survey-summary.md` — prior art and its six-item operator hand-off list
- `specs/archive/736_cslib_omega_automata_survey_and_e3_reopen_check/reports/01_cslib-omega-automata-survey.md` — the survey's own 737-line report (not re-read this session; cited for provenance only)
- `.claude/context/project/lean4/patterns/dependency-tracing.md` — why `#print axioms` cannot answer a dependency question, which is why import closure was computed instead
- `.claude/context/project/lean4/domain/metadata-trust-surfaces.md` — the trust-surface file the first context-extension recommendation extends
