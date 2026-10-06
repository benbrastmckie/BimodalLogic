# Research Report: Task #736

**Task**: 736 - Cslib omega-automata survey and E3 reopen check
**Started**: 2026-10-05T19:55:00Z
**Completed**: 2026-10-05T21:40:00Z
**Effort**: Large (hard mode, four-part scope)
**Dependencies**: None
**Sources/Inputs**:
- `~/Projects/cslib/` working tree at `3bdf16d9f`, and `upstream/main` at `ea16de32af9cd93796505668672297df9c422052` (fetched fresh this dispatch)
- This repository's Mathlib at `79d0395a`; cslib's at `169c26b5`
- Direct elaboration via `lake env lean` in both trees (`#print axioms`, environment-presence probes)
- `~/Projects/Literature/index.json` (13,701 chunk records / 319 documents), `specs/literature-index.json`, `~/Projects/cslib/references.bib`, `~/Projects/cslib/specs/literature-index.json`
- lean-lsp MCP: index `unavailable` this dispatch; **evidence tier for all absence claims is a grep sweep over Mathlib source, not an LSP lookup** (see Decisions)

**Artifacts**:
- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/reports/01_cslib-omega-automata-survey.md` (this report)
- `specs/evidence/seam-gluing-ray-product/cslib-ramsey-port-feasibility.lean` (probe, compiles sorry-free)
- `scripts/check-evidence-probes.sh` (one appended `WIRED` entry + doc block; 35 insertions, 0 deletions)
- `specs/literature-index.json` (13 new entries, 2 hazards recorded on pre-existing entries)

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The dispatch's central premise is false where it matters most.** `BuchiCompl.lean` does **not**
  carry candidate (b)'s core. Its three main theorems — `complement_language_sub`,
  `complement_language_sup`, `complement_language_eq` — are `proof_wanted`, which emits no
  declaration at all. Machine-checked: `#print axioms` on `complement_language_eq` fails with
  *unknown constant*, and an environment probe reports `present=false` for all three. A
  `grep -c sorry` returns 0 on that file, so the sorry-count is a **false negative** as a
  completeness measure for cslib. The file's own docstring calls the backward direction "of Very
  High difficulty and ... left as a future proof obligation." Under the zero-debt policy
  `complementNA` is not a resource.

- **But two results the dispatch never mentions are the real assets, and they are stronger.**
  (1) `Cslib.ωLanguage.IsRegular.compl` — ω-regular languages are closed under complementation,
  i.e. Büchi's 1962 theorem's hard half — is **proved UPSTREAM**, sorry-free, axiom-clean.
  (2) `Cslib.ωLanguage.IsRegular.iff_da_muller` — **McNaughton's theorem**, NBA ↔ deterministic
  Muller — is **proved in the fork** (upstream leaves it `proof_wanted`). So **Büchi determinization
  does exist in Lean**, by the Büchi/Choueka route rather than Safra/Piterman.

- **Ramsey over the time axis IS the Büchi complementation core — now machine-checked, not
  conjectured.** `IsRegular.compl`'s proof goes through `buchiFamily_cover`, which colours a pair
  of time points `{i,j}` by the congruence class of the *segment* `xs.extract i j`, applies
  `infinite_graph_ramsey`, and extracts a monochromatic strictly-monotone time sequence. Its own
  docstring: "does not depend on any details of `na.BuchiCongruence` other than that it is of
  finite index." That is candidate (d)'s device exactly. **E3's LOW-confidence (c)/(d)
  shared-Ramsey-core claim is RAISED to High** on this evidence.

- **This repository already independently built the same device, on the MSO side.**
  `RamseyFactorization.lean` applies `infinite_ramsey_pairs` to
  `fun a b => kTypeOf sig k (segZ sig c a b)` — a pair of times coloured by the monadic *k-type* of
  the segment between them — over `MonadicFO.lean`'s monadic logic on linear orders. That is the
  composition method. So (c) and (d) are not two candidates in this tree; they are one device
  already in use.

- **Verdict: (i) KEEP candidate (d). E3's selection stands — with its reasons substantially
  rewritten.** Two of E3's four rejection grounds do not survive, but neither failure favours a
  different candidate: (b) is unavailable *in Lean* and (c)'s MSO↔automata discharge is
  unformalized *anywhere*, while (d)'s one non-trivial ingredient is in-tree, proved, axiom-clean,
  and has a live consumer. A Lake `require` on cslib is **not** recommended; neither is porting.

- **The ForMathlib duplication question is settled, and machine-checked.** cslib's
  `infinite_graph_ramsey` **strictly subsumes** this tree's
  `Nat.exists_strictMono_const_pair_colour` — the probe derives the in-tree statement from a
  port of cslib's and checks the statement identity by discharging one shared type twice.
  **It should nonetheless NOT be redefined as a corollary**: subsumption is a fact about
  statements, and here the port plus glue is a net *addition* of lines.

## Context & Scope

Four parts, per the dispatch: (A) cslib inventory and port assessment; (B) literature gap closure
and sub-index wiring; (C) one compiling evidence probe, gated; (D) an explicit verdict on whether
probe E3's device selection should be reopened.

**Every claim about cslib below was re-verified by direct file read and by elaboration during this
dispatch.** Nothing is carried over from the task description, and three of the description's
specific claims turned out to be wrong (recorded in Decisions).

**Boundary honoured.** Nothing under `FormalSystem/Metalogic/Decidability/RaySummary/` was touched;
task 711's plan was not read for revision purposes and not edited; no follow-on task was spawned.
No complexity bound, upper or lower, is claimed anywhere in this report or in the probe.

## Findings

### Reference grounding: Tier 1 (literature-backed) — lemma-level mapping

The task is literature-backed on two axes (the Büchi/McNaughton/Ramsey mathematics, and E3's own
cited sources), so the 5-column lemma mapping table is required and is given first.

| Source (whole doc_id / citation) | Proposition / location | Lean identifier | Type signature (as elaborated) | Status |
|---|---|---|---|---|
| Ramsey (infinite, exponent 2); `doets_1987` ch. 7 pp. 89–93 is the in-tree citation | Infinite Ramsey for pairs, finitely many colours | `Cslib.infinite_graph_ramsey` | `∀ {Vertex Color : Type*} [Finite Color] (color : Finset Vertex → Color) [Infinite Vertex], ∃ c : Color, ∃ s : Set Vertex, s.Infinite ∧ ∀ e : Finset Vertex, e.card = 2 → ↑e ⊆ s → color e = c` | **PROVED**, upstream+fork; axioms `[propext, Classical.choice, Quot.sound]` |
| same | same, ℕ-specialised, curried/ordered colouring | `Nat.exists_strictMono_const_pair_colour` | `∀ {C : Type} [Finite C] (c : ℕ → ℕ → C), ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, ∀ i j, i < j → c (g i) (g j) = τ` | **PROVED in-tree**, sorry-free; **corollary of the row above** (machine-checked by this task's probe) |
| Büchi 1962, complementation; `thomas_1997_languages_automata` §I (handbook treatment) | ω-regular languages closed under complement | `Cslib.ωLanguage.IsRegular.compl` | `∀ {Symbol : Type} [Inhabited Symbol] {p : ωLanguage Symbol}, p.IsRegular → pᶜ.IsRegular` | **PROVED, UPSTREAM**; axiom-clean |
| Büchi congruence / Ramsey factorization; `thomas_1997_languages_automata` | Finite-index congruence family covers all ω-words | `Cslib.Automata.NA.Buchi.buchiFamily_cover` | `⨆ i, na.buchiFamily i = ⊤` (needs `[Inhabited Symbol] [Finite State]`) | **PROVED, upstream+fork**; axiom-clean. **Uses `infinite_graph_ramsey` on segment classes** |
| same | The family saturates the accepted language | `Cslib.Automata.NA.Buchi.buchiFamily_saturation` | saturation of `language na` by `buchiFamily` | **PROVED**, axiom-clean |
| same | Congruence has finite index when the state type is finite | `Cslib.Automata.NA.Buchi.buchiCongruence_fin_index` | `[Finite State] → Finite (Quotient na.BuchiCongruence.eq)` | **PROVED**, axiom-clean |
| McNaughton 1966; Choueka 1974 decomposition route | ω-regular ↔ deterministic-Muller recognizable | `Cslib.ωLanguage.IsRegular.iff_da_muller` | `∀ {Symbol : Type} [Inhabited Symbol] {p : ωLanguage Symbol}, p.IsRegular ↔ ∃ (State : Type) (_ : Finite State) (da : DA.Muller State Symbol), language da = p` | **PROVED, FORK-ONLY** (upstream: `proof_wanted`); axiom-clean |
| same, forward direction | ω-regular ⇒ DMA | `Cslib.ωLanguage.IsRegular.to_da_muller` | `p.IsRegular → ∃ State, _, da : DA.Muller State Symbol, language da = p` | **PROVED, FORK-ONLY**; axiom-clean |
| Kupferman–Vardi 2001 §5.2 (`kupferman_vardi_2001_weak_alternating`) | Rank-based NBA complementation, the *construction* | `Cslib.Automata.NA.Buchi.complementNA` | `Buchi State Symbol → Buchi (ComplState State) Symbol` | **DEFINED only**, fork-only; axiom-clean as a definition |
| Kupferman–Vardi 2001 §5.2, Lemma 5.2 forward | Soundness of the rank construction | `Cslib.Automata.NA.Buchi.complement_language_sub` | `∀ a, language (complementNA a) ≤ (language a)ᶜ` | **`proof_wanted` — NOT PROVED, no declaration exists** (`present=false`) |
| Kupferman–Vardi 2001 §5.2, Lemma 5.2 backward | Completeness of the rank construction | `..complement_language_sup` | `∀ a, (language a)ᶜ ≤ language (complementNA a)` | **`proof_wanted`**; docstring: "Very High difficulty ... future proof obligation" |
| same, combined | Correctness of the rank construction | `..complement_language_eq` | `∀ a, language (complementNA a) = (language a)ᶜ` | **`proof_wanted`** |
| Safra 1988 / Piterman 2007 (`loding_pirogov_2019_...`, `piterman_2007_...`) | Büchi determinization via Safra/Piterman | — | — | **ABSENT from cslib entirely**; `DA/Conversions.lean` says so explicitly: "This is NOT Piterman's 2006 theorem" |
| `thomas_2003_ch03`; LAR construction | DRA → DPA via latest appearance record | `Cslib.Automata.DA.Rabin.toParity_exists` | — | **`proof_wanted`** (`present=false`) |
| `thomas_2003_ch03` | DMA → DRA | `Cslib.Automata.DA.Muller.toRabin_exists` | — | **`proof_wanted`** (`present=false`) |
| Landweber / Muller characterization | DBA-recognizable ↔ closed under superloops | `..Muller.dba_recognizable_iff_closedUnderSuperloops` | — | **`proof_wanted`** (3 of them in `DA/BuchiChar.lean`) |
| `baier_katoen_2008_part04` Def. 5.35 / Thm 5.37 | LTL → GNBA with correctness | `Cslib/Logics/LTL/Semantics/GNBA/Correctness.lean` (805 lines) | — | **PROVED, FORK-ONLY**, sorry-free, no `proof_wanted` |
| Zielonka 1998 (`zielonka_1998_infinite_games`); cited by cslib as `[GradelThomasWilke2002]` | Parity/Rabin acceptance conversions, easy directions | `Buchi.toRabin_language_eq`, `Rabin.toMuller_language_eq`, `Rabin.toStreett_language_eq`, `Streett.toRabin_language_eq`, `Parity.toRabin_language_eq` | language-equality lemmas | **PROVED, FORK-ONLY** (all 5); axiom-clean |
| Esparza–Křetínský–Sickert Master Theorem (`esparza_kretinsky_sickert_2020_...`), formalized by `brunner_seidl_sickert_2019_verified_ltl_to_dra` | Safraless LTL → deterministic Rabin, **verified** | — (Isabelle/HOL, Archive of Formal Proofs) | — | **PROVED, but in Isabelle/HOL — not Lean.** Not a resource under zero-debt; decisive as feasibility evidence |

### (A) cslib inventory and port assessment

#### A.1 Environment facts, re-verified

| Fact | This repository | cslib |
|---|---|---|
| `lean-toolchain` | `leanprover/lean4:v4.33.0-rc1` | `leanprover/lean4:v4.33.0-rc1` — **identical** |
| Mathlib resolved rev | `79d0395a` (2026-07-16, "chore: bump toolchain to v4.33.0-rc1") | `169c26b5` (2026-07-20, **"refactor: rename restrict to domRestrict (#25980)"**) |
| Mathlib rev distance | — | **76 commits, cslib ahead** |
| Fork vs upstream | — | **4,717 commits ahead, 155 behind**; merge-base `f36649cff` |
| `batteries` rev | `31a49105` | `2c810760` — also divergent |

The toolchain match is real and the dispatch is right about it. The Mathlib match is **not**: the
two trees are 76 Mathlib commits apart, and cslib's pinned Mathlib HEAD *is itself a rename*
(`Set.restrict` → `Set.domRestrict`) that breaks ported cslib code on this pin. This is measured,
not conjectured — see Part C.

The fork being **155 commits behind upstream** produces a third provenance category the dispatch
does not have: files that exist upstream but are **absent from the local fork working tree**
(`NA/Preimage.lean`, `NA/Reverse.lean`, all three `TwoWayNA/*`,
`Languages/Congruences/{Basic,MyhillCongruence}.lean`, `Languages/{LanguageHom,SafetyLiveness,Slice,SyntacticMonoid}.lean`
— 1,270 lines in total). The dispatch lists several of these as "IN UPSTREAM", which is correct, but
they cannot be read from the local checkout without `git show upstream/main:`.

#### A.2 Provenance and completeness inventory

54 files, 10,126 lines, across the four relevant subtrees of the local fork working tree:

| Provenance | Files | LOC |
|---|---|---|
| `upstream` (byte-identical to `ea16de32a`) | 14 | 1,009 |
| `upstream+fork` (exists upstream, locally modified) | 17 | 3,254 |
| **`FORK-ONLY`** (absent from `upstream/main`) | 23 | **5,863** |
| *(additionally)* `UPSTREAM-ONLY`, absent from the local tree | 11 | 1,270 |

By subtree: `Computability/Automata` 33 files / 5,183 LOC; `Computability/Languages` 8 / 2,046;
`Foundations/Combinatorics` 1 / 147; `Logics/LTL` 12 / 2,750 (**entirely fork-only — upstream has no
`Cslib/Logics/LTL` and no `Cslib/Logics/{Bimodal,Temporal}` at all**; upstream `Cslib/Logics` holds
only `HML`, `LinearLogic`, `Modal`, `Propositional`).

**`sorry` count: 0 in all 54 files.** That number is misleading and must not be used alone.
**`proof_wanted` count: 8, in 3 files, all FORK-ONLY:**

| File | Provenance | LOC | `proof_wanted` | What is unproved |
|---|---|---|---|---|
| `Automata/NA/BuchiCompl.lean` | FORK-ONLY | 331 | **3** | the entire correctness of the rank-based complementation |
| `Automata/DA/BuchiChar.lean` | FORK-ONLY | 181 | **3** | the Landweber/Muller DBA characterization, both directions + iff |
| `Automata/DA/Conversions.lean` | FORK-ONLY | 117 | **2** | DRA→DPA (LAR) and DMA→DRA |

Upstream's only `proof_wanted` in these trees is `IsRegular.iff_da_muller` — **which the fork
proves**. So the fork's net effect on completeness is: it closed McNaughton, and opened eight new
gaps, all of them at the mathematically hard directions (determinization-adjacent conversions,
rank-construction correctness, the Landweber characterization). That pattern is corroborated by
`schewe_varghese_2014_determinising_parity_automata` and `vardi_2007_buchi_complementation_saga`:
these are the hard directions in the literature too, not oversights.

#### A.3 Axiom profiles (`#print axioms`, elaborated this dispatch in cslib)

Every declaration below: **`[propext, Classical.choice, Quot.sound]`, no `sorryAx`.**

`Cslib.infinite_graph_ramsey`, `Cslib.infinite_pigeonhole_principle`,
`Cslib.Automata.NA.Buchi.buchiFamily_cover`, `..buchiFamily_saturation`,
`..buchiCongruence_fin_index`, `Cslib.ωLanguage.IsRegular.compl`, `..IsRegular.to_da_muller`,
`..IsRegular.of_da_muller`, `..IsRegular.iff_da_muller`,
`Cslib.Automata.DA.Buchi.toRabin_language_eq`, `..Rabin.toMuller_language_eq`,
`..Rabin.toStreett_language_eq`, `..Streett.toRabin_language_eq`, `..Parity.toRabin_language_eq`,
`Cslib.Automata.NA.Buchi.complementNA`, `..withBot_fin_nonincreasing_stabilizes`.

And the negative control, same environment: `complement_language_sub`, `complement_language_sup`,
`complement_language_eq`, `Rabin.toParity_exists`, `Muller.toRabin_exists`,
`Muller.dba_recognizable_iff_closedUnderSuperloops` → **`present=false`** (no declaration), while
`iff_da_muller`, `to_da_muller`, `compl`, `complementNA`, `infinite_graph_ramsey` →
`present=true`. (An earlier run of this probe reported `false` for `iff_da_muller`/`compl` because
I had omitted `OmegaRegularLanguage` from the probe's imports; the table above is the corrected run
with the import present.)

#### A.4 What `IsRegular.compl` actually proves, and why it is the load-bearing find

`IsRegular` is NBA-recognizability:
`∃ (State : Type) (_ : Finite State) (na : NA.Buchi State Symbol), language na = p`.

`IsRegular.compl`'s proof, **identical upstream and in the fork**, is five lines:

```
obtain ⟨State, h_fin, na, rfl⟩ := h
have : Finite (Quotient na.BuchiCongruence.eq) := buchiCongruence_fin_index
have h_sat := buchiFamily_saturation (na := na)
have h_cov := buchiFamily_cover (na := na)
apply IsRegular.fin_cover_saturates_compl h_sat h_cov
```

and `buchiFamily_cover`'s proof is where the device lives:

```
let color (t : Finset ℕ) : Quotient na.BuchiCongruence.eq :=
  if h : t.Nonempty then ⟦ xs.extract (t.min' h) (t.max' h) ⟧ else ⟦ [] ⟧
obtain ⟨b, ns, h_ns, h_color⟩ := infinite_graph_ramsey color
obtain ⟨f, h_mono, rfl⟩ := strictMono_of_infinite h_ns
```

**The colour of a pair of time points is the finite-alphabet summary of the interval between
them**, and Ramsey over pairs of times then yields a strictly monotone `f` with every consecutive
segment in one class. The theorem's own docstring states the abstraction: it "does not depend on
any details of `na.BuchiCongruence` other than that it is of finite index."

This is candidate (d), verbatim, and it is the proof of Büchi complementation closure. It is also
exactly the shape the task's own constraints force: over the **time axis**, with a **finite
alphabet of per-interval summaries**, never over states.

#### A.5 `InfiniteGraphRamsey.lean` vs `ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`

**Verdict: cslib's theorem SUBSUMES this tree's, strictly. The in-tree module should NOT be
redefined as a corollary.**

| | cslib `Cslib.infinite_graph_ramsey` | in-tree `Nat.exists_strictMono_const_pair_colour` |
|---|---|---|
| Vertex type | arbitrary, `[Infinite Vertex]` | fixed `ℕ` |
| Colour universe | `Type*` | `Type` (monomorphic) |
| Colouring shape | `Finset Vertex → Color` (**unordered**) | `ℕ → ℕ → C` (**curried, ordered**) |
| Witness shape | `s : Set Vertex`, `s.Infinite` | `g : ℕ → ℕ`, `StrictMono g` |
| LOC | 147 (file), 203 (closure incl. cslib lint infra) | 160 |

Subsumption holds and is **machine-checked by this task's probe**: `repo_ramsey_from_cslib_ramsey`
derives the in-tree statement from a port of cslib's, through exactly two glue steps — the
unordered→ordered pair bridge (`min'`/`max'` on a two-element `Finset`) and the monotone
enumeration of an infinite `Set ℕ` (`Nat.nth`). The probe then writes the in-tree statement once as
`RepoRamseyStatement` and discharges that one type twice, from each side, so statement identity is
checked by the elaborator rather than by eye.

The converse fails and cannot be repaired: recovering an arbitrary `Vertex` from the ℕ-specialised
form needs a bijection with ℕ, which `[Infinite Vertex]` does not supply.

**Three reasons not to act on the subsumption:**

1. **It costs lines rather than saving them.** 147 ported lines + ~45 lines of glue (the probe's
   `pair_min'_max'` plus the `Nat.nth` step) replaces a self-contained 160-line module. Net
   addition.
2. **The live consumers need the curried ordered form.**
   `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean` instantiates
   `infinite_ramsey_pairs` **twice with opposite orientations** —
   `fun a b => kTypeOf sig k (segZ sig c (a : ℤ) (b : ℤ))` and
   `fun a b => kTypeOf sig k (segZ sig c (-(b : ℤ)) (-(a : ℤ)))`. Each would need the bridge applied
   separately, re-paying the glue at every use site.
3. **The rev skew is real.** The ported file is `grind`-heavy and written against a Mathlib 76
   commits newer; the probe had to replace cslib's `grind` calls with explicit terms and the
   `⋂ m < n` bookkeeping with a direct antitone chain.

**One actionable in-tree correction found, independent of cslib.**
`InfiniteRamseyPairs.lean`'s docstring says `Mathlib.Data.Nat.Nth` "is not in this project's built
cache, so `Nat.nth` is deliberately not used." **That is now stale**: all 8,268 Mathlib modules are
built here, `Mathlib/Data/Nat/Nth.olean` is present, and this task's probe uses `Nat.nth`
successfully. The stated reason for the module's bespoke `Nat.Subtype.ofNat` enumeration no longer
holds. This is a docstring-accuracy fix, not a mathematical one; it is **not** a reason to rewrite
the module, and I did not touch it (out of this task's scope).

#### A.6 Port cost, and style/pin friction

Import-closure cost, computed by transitive import walk over cslib sources:

| Port target | Cslib modules | Cslib LOC | External modules pulled in |
|---|---|---|---|
| `infinite_graph_ramsey` alone | 3 | **203** (147 maths + 56 lint/style infra) | 8 (6 Mathlib + `Batteries.Tactic.Lint.Basic` + `Lean.Message`) |
| `BuchiCongruence` (the Ramsey core) | 35 | **4,944** | 20 Mathlib |
| `IsRegular.compl` / `iff_da_muller` (McNaughton) | **47** | **7,526** | 29 (incl. `Mathlib.Computability.{DFA,Language,RegularExpressions}`) |

The McNaughton closure is the whole `LTS`/`FLTS`/`ωSequence`/`Language`/`Automata` stack —
`Foundations/Semantics/LTS/Basic.lean` (373), `Foundations/Data/OmegaSequence/Init.lean` (529),
`DA/Concat.lean` (762), `DA/Choueka.lean` (472), and 43 more. **This is not a port; it is adopting a
second library.**

**Style friction, concretely.** Every cslib file opens with `module`, uses `public import`, and
wraps its content in `@[expose] public section`; this tree uses plain `import` and no module system.
The non-Mathlib leaves of even the smallest closure (`Cslib.Init`, `Cslib/Foundations/Lint/Basic.lean`,
56 lines) are a custom `@[env_linter]` plus `Mathlib.Init`/`Mathlib.Tactic.Common` re-exports — pure
style infrastructure. The probe demonstrates these are **droppable without loss**: the ported theorems
compile here with plain `import`, no `module` preamble, and no `Cslib.*` dependency at all.

**Pin friction, measured.** The first line of the first ported proof failed:

```
error(lean.invalidField): Invalid field `domRestrict`: the environment does not contain
`Function.domRestrict` ...
```

because cslib's pinned Mathlib HEAD *is* `refactor: rename restrict to domRestrict (#25980)`.
`Set.Infinite.diff` is additionally deprecated here in favour of `Set.Infinite.sdiff`. Both fixes
are one token — the point is that a 4-day, 76-commit skew already produced one hard break inside
147 lines, and the McNaughton closure is fifty times that size.

#### A.7 Port assessment — recommendation

**Port nothing now.** Specifically:

- **Do not port the McNaughton/complementation stack.** 7,526 lines across 47 modules, against a
  Mathlib 76 commits off, for a result whose output is a deterministic acceptor **over states** —
  and the pigeonhole-over-states route is already refuted
  (`Probe732Device.not_lasso_sufficient_on_chain`;
  `...PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`). The substrate must work over the
  time axis. This port would buy the wrong axis at the highest price.
- **Do not port `InfiniteGraphRamsey.lean`.** Subsumption is real, the port is feasible (proved by
  the probe), and it still costs more lines than it saves — see A.5.
- **Do not port `BuchiCompl.lean`.** Its correctness theorems do not exist.

**DISSENT, recorded as the dispatch permits.** A Lake `require` on cslib would avoid every line of
port cost and the entire rev-skew problem *for cslib's own code*. I do **not** recommend it, and the
reason is not stylistic: `require` would force **this** repository onto cslib's Mathlib `169c26b5`,
moving this tree 76 Mathlib commits forward as a side effect of a dependency edit — including the
`restrict`→`domRestrict` rename, which this tree's own sources would then have to absorb. The
dependency is cheaper than the port only if one ignores which repository pays. I note the
possibility and reject it on that ground.

**What I would recommend instead, if anything:** treat cslib as a **read-only reference** — exactly
what this report and its probe do. The cross-reference precedent already exists in this repository
(commit `1291e165a`, "record cslib premise check as a cross-reference, no dependency edge").

### (B) Literature gathering and index wiring

**Harvest from cslib yielded almost nothing, and revealed a defect in cslib.**
`~/Projects/cslib/references.bib` has 97 entries; the dispatch-named stems `Thomas1990`,
`VardiWolper1986`, `GHR94`, `HodkinsonReynolds2006`, `Gore1999`, `GPSS1980`, `Pnueli1977`,
`Hopcroft2006` are all present — **as metadata only, with no PDFs**. cslib's own
`specs/literature-index.json` (34 entries) contains **zero** omega-automata documents; it is
entirely modal/intuitionistic logic.

Worse: the fork's omega-automata files **cite six keys that have no `references.bib` entry at
all** — `[GradelThomasWilke2002]`, `[BaierKatoen2008]`, `[KupfermanVardi2001]`,
`[KupfermanVardi1998]`, `[Thomas2003]`, `[Zielonka1998]` (each `grep -c` = 0). These are dangling
citations in cslib, not a source of literature for this repository.

**The real finding: the sources were already in the GLOBAL corpus, unwired.** The gaps the dispatch
named are mostly a *wiring* problem, not an acquisition problem. 13 entries added to
`specs/literature-index.json` (93 → 106), **nothing converted and nothing re-ingested**:

| Dispatch-named gap | Outcome | Wired doc_id (whole) |
|---|---|---|
| Piterman 2006/2007, NBA/Streett → DPA | **CLOSED** — was in global corpus | `piterman_2007_nondeterministic_buchi_streett_to_deterministic_parity` (48 chunks) + `piterman_2007_buchi_streett` (1 chunk, `verified_conversion`) |
| Safra 1988, "On the Complexity of ω-Automata" | **CLOSED IN SUBSTANCE** (the 1988 paper itself absent) | `loding_pirogov_2019_determinization_buchi_safra_muller_schupp` — presents Safra's construction |
| Thomas 1990, "Automata on Infinite Objects" | **CLOSED IN SUBSTANCE** (1990 chapter absent) | `thomas_2003_ch01`, `thomas_2003_ch03` — and cslib actually cites `[Thomas2003]`, not `[Thomas1990]` |
| Grädel–Thomas–Wilke 2002 | **NOT CLOSED** — absent from global corpus; still WANTED | `zielonka_1998_infinite_games` wired as the corpus-available counterpart (cslib also cites `[Zielonka1998]` directly) |
| Baier–Katoen 2008 ch. 4 | **ALREADY IN CORPUS — not re-ingested**, per instruction | `baier_katoen_2008_part04` (pre-existing) |
| Kupferman–Vardi, "Safraless Decision Procedures", FOCS 2005 | **NOT CLOSED** — absent from global corpus; still WANTED | — (but see the next table: the *formalization* of the Safraless route is in corpus) |
| Hodkinson–Reynolds, HbML §5.10–5.11 bodies | **NOT CLOSED** — `hodkinson_2006` is a 3-page truncation; its pre-existing acquisition-blocker hazard stands | — |

Four further entries wired because this task's findings made them load-bearing:

| doc_id | Why wired |
|---|---|
| `brunner_seidl_sickert_2019_verified_ltl_to_dra` | **Verdict-critical.** ITP 2019; a complete **Isabelle/HOL** formalisation of the Esparza–Křetínský–Sickert Master Theorem LTL→DRA translation, archived in the Archive of Formal Proofs. A *Safraless* construction verified end-to-end in a proof assistant |
| `esparza_kretinsky_sickert_2020_unified_translation_ltl_omega_automata` | the Master Theorem that the above formalises — route (b)'s mathematics, read directly |
| `tsai_fogarty_vardi_tsay_2014_state_of_buchi_complementation`, `vardi_2007_buchi_complementation_saga` | the rank-based vs **Ramsey-based** vs slice-based complementation landscape — the published frame for A.4's finding |
| `schewe_2009_buchi_complementation`, `schewe_varghese_2014_determinising_parity_automata`, `yan_2008_lower_bounds` | published counterparts of cslib's eight `proof_wanted` gaps. `yan_2008_lower_bounds` is held **for provenance only** and must never be cited as a complexity bound here |

**The identity hazard was respected, and three new instances were found and recorded.** All ids
above were matched **whole** against the global index; no author-year stem matching was used
anywhere. A stem-collision audit of the whole sub-index turned up three unrecorded collisions:

| Stem | Colliding whole ids | Nature | Action |
|---|---|---|---|
| `piterman_2007` | `piterman_2007_nondeterministic_buchi_streett_to_deterministic_parity` (48 chunks, fidelity **unset**) vs `piterman_2007_buchi_streett` (1 chunk, **`verified_conversion`**) | apparently one paper, two directories, divergent fidelity — the `thomas_1997` pattern exactly | **hazard written on BOTH new entries**, mirroring each other |
| `vardi_1996` | `vardi_1996_automata_ltl` (**`verified_conversion`**) vs `vardi_1996_automata-theoretic-ltl` (**`no_source_pdf`**) — different directories, **opposite** fidelity verdicts | pre-existing sub-index entry carried **no** hazard | **hazard recorded on the existing `vardi_1996_automata_ltl` entry** |
| `vardi_wolper_1986` | `vardi_wolper_1986_automata_verification` (file-level) vs `vardi_wolper_1986` (directory-level record, same directory) | parent/child records, both `verified_conversion` — no fidelity divergence, but not interchangeable | **hazard recorded on the existing entry** |

The pre-existing `thomas_1997` / `thomas_1997_languages_automata` hazard was left exactly as it
stands and was honoured in use: the (c)/(d) resolving check below cites
**`thomas_1997_languages_automata`** ("Languages, Automata, and Logic", `verified_conversion`, source
PDF present), never `thomas_1997` ("EF Games, the Composition Method...", `no_source_pdf`,
hazard-carrying). The dispatch's own description spells the id `thomas_1997_languages_automata`
while the briefing shows the *directory* as `sources/thomas_1997_languages`; the doc_id is the
former and the directory the latter, and both are correct in their own register.

**Validation.** `specs/literature-index.json`: valid JSON, 106 entries, **0 orphans** (every
doc_id resolves whole in the global index), **0 unresolvable paths** on disk, **0 duplicate
doc_ids**, **0 entries missing `doc_id`**, 40 hazard-carrying entries. **RESULT: PASS.**
A re-run of `literature-coverage-delta.sh` on the topic query leaves 4 candidates, of which 3 are
off-topic (matched on "games") and 1 is the `vardi_wolper_1986` duplicate-id record now covered by
the hazard above — i.e. the ω-automata coverage delta is closed.

### (C) Lean feasibility probe

`specs/evidence/seam-gluing-ray-product/cslib-ramsey-port-feasibility.lean`, four parts:

1. **Port.** `infinite_pigeonhole_principle` and `infinite_graph_ramsey`, statements transcribed
   verbatim (up to the `restrict`/`domRestrict` rename), compiling on this pin **from Mathlib
   alone** — no `Cslib.*` import, no `module`/`public import`/`@[expose] public section`, no cslib
   lint infrastructure.
2. **Subsumption.** `repo_ramsey_from_cslib_ramsey` derives the in-tree statement from the ported
   theorem via the unordered→ordered pair bridge and `Nat.nth`.
3. **Statement identity, machine-checked.** `RepoRamseyStatement` is written once and discharged
   twice — once by `Nat.exists_strictMono_const_pair_colour`, once by
   `repo_ramsey_from_cslib_ramsey`. Had the statements drifted in any argument, implicit or
   instance, one ascription would fail to elaborate.
4. **Axiom profiles.** All three: `[propext, Classical.choice, Quot.sound]`. No `sorryAx`.

The header states what the probe establishes **and** what it refuses to claim: not that the port
*should* be made (feasibility ≠ advisability); not a faithful line-by-line transcription of cslib's
*proofs* (the `⋂ m < n` bookkeeping and the `grind` calls were replaced — stated plainly, with the
strength-equality noted); not portability of anything else in cslib, and specifically not of
`BuchiCompl.lean`; and no complexity bound and no device discrimination.

**Gate wiring.** `scripts/check-evidence-probes.sh` was **re-read immediately before editing** (still
at `e8cfcd868`, still 13 `WIRED` entries — unchanged since my first read) and then **appended to
only**: one array entry plus its doc block, `35 insertions, 0 deletions`. No existing entry or
comment was altered.

**Collection run — the gate:**

```
PASS  all 17 wired probe(s) compile
GATE EXIT: 0
```

All 13 pre-existing `WIRED` probes PASS, all 3 `WIRED_REPO` probes PASS, the new probe PASSES, the
one `DEFERRED` probe SKIPs as before.

### (D) The verdict on E3

**(i) KEEP candidate (d), the time-axis Ramsey-coloured summary. E3's selection stands.**
Its *reasons*, however, need substantial rewriting, and two of its four grounds do not survive.

#### E3's rejection grounds, re-audited one by one

| E3 ground | Verdict | Evidence |
|---|---|---|
| "Mathlib carries zero ω-automata, Büchi, parity or Rabin infrastructure at the pin" | **CONFIRMED** | Grep sweep of all 8,268 Mathlib source files: **zero** hits on `Buchi`/`Büchi`/`Buechi`/`OmegaLanguage`/`omegaLanguage`/`OmegaRegular`/`Rabin`/`Streett`/`ParityAutomaton`/`MullerAutomaton`/`Safra`/`Piterman`/`omegaAccept`/`OmegaAcceptor`. Mathlib has `DFA`/`NFA`/`EpsilonNFA`/`MyhillNerode`/`RegularExpressions` — **finite words only**. Also **no Ramsey theorem declaration** (Hindman and Hales–Jewett mention Ramsey theory only in prose) and **no MSO** |
| "no formalization of Safra or Piterman determinization exists in ANY proof assistant" | **LITERALLY TRUE, but it no longer supports the conclusion drawn from it** | cslib has no Safra and no Piterman — `DA/Conversions.lean` says so itself. **But** (a) cslib **proves McNaughton's theorem** (`IsRegular.iff_da_muller`), so determinization to a deterministic Muller acceptor *is* available in Lean by the Büchi/Choueka route; and (b) `brunner_seidl_sickert_2019_verified_ltl_to_dra` is a complete **Isabelle/HOL** formalisation of a *Safraless* LTL→DRA translation, in the Archive of Formal Proofs. "Nobody has formalized this" is no longer a reason to reject (a) or (b) |
| *(dispatch's premise)* "`BuchiCompl.lean` IS candidate (b)'s core, already formalized in Lean" | **FALSE** | `complement_language_sub`/`sup`/`eq` are `proof_wanted`; `present=false`; `#print axioms` → unknown constant. The backward direction is self-described "Very High difficulty ... left as a future proof obligation" |
| "(c)'s discharge theorem (Büchi's theorem) has no Lean formalization" | **PARTIALLY FALSIFIED — in the ω-automata half only** | cslib **proves upstream** that ω-regular languages are closed under complementation (`IsRegular.compl`) and **proves in the fork** McNaughton. **But cslib has ZERO MSO**: a grep for `MSO`/`MonadicSecondOrder`/`monadic second`/`second-order`/`SecondOrder` across all of `Cslib/` returns nothing. The MSO syntax, its semantics, and the MSO↔ω-regular translation — which is the bulk of Büchi's theorem — remain unformalized in Lean. (c)'s discharge is still not citable |
| "(c) and (d) are plausibly the same mathematics in two wrappers ... Low-confidence background" | **RAISED to High, machine-checked** | See below |

#### The (c)/(d) shared-Ramsey-core claim: confidence RAISED, from Low to High

E3's named resolving check was Thomas 1997 "Languages, Automata, and Logic"
(**`thomas_1997_languages_automata`** — `verified_conversion`, source PDF present; *not*
`thomas_1997`). Both that source and `BuchiCongruence.lean` now bear on it, and they agree:

- `IsRegular.compl` — Büchi complementation closure — is proved **through**
  `buchiFamily_cover` + `buchiFamily_saturation`.
- `buchiFamily_cover` is proved **by applying `infinite_graph_ramsey`** to a colouring that
  assigns, to a pair of time points `{i,j}`, the congruence class of the **segment** `xs.extract i j`.
- Its docstring states the abstraction explicitly: the argument "does not depend on any details of
  `na.BuchiCongruence` other than that it is of finite index."
- Everything on that chain is sorry-free, `proof_wanted`-free, and axiom-clean.

So Büchi complementation **is** Ramsey over the time axis with a finite alphabet of per-interval
summaries. That is no longer "plausibly the same mathematics"; it is the same theorem's proof.
**Confidence: High, machine-checked.**

#### A finding E3's frame did not contain: this tree already built the device, on the MSO side

This is the most consequential new fact, and it came from this repository, not cslib:

- `FormalSystem/Metalogic/Expressiveness/MonadicFO.lean` defines `MonadicSignature` and
  De Bruijn-indexed **monadic first-order formulas over linear orders** (`atom p i`, `lt i j`).
- `FormalSystem/Metalogic/WeakCanonical/NEquivalence.lean` defines `KType`, `kTypeOf`, `KEquiv` —
  Ehrenfeucht–Fraïssé **k-types**.
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean` (836 lines) applies
  `infinite_ramsey_pairs` — the alias of `Nat.exists_strictMono_const_pair_colour` — to
  `fun a b => kTypeOf sig k (segZ sig c (a : ℤ) (b : ℤ))`: **a pair of times coloured by the monadic
  k-type of the segment between them**, over ⟨ℤ,<⟩, in both orientations.

That is the **composition method** (Shelah/Thomas) — the MSO-side route to what E3 called route (c),
and it discharges through **Ramsey**, not through Büchi's theorem. Structurally it is the *same
colouring device* as cslib's `buchiFamily_cover`, with the congruence class replaced by the k-type.

**Consequence for the verdict.** (c) and (d) are not two candidates to choose between in this tree.
The Ramsey-coloured-interval-summary device is (d); it is simultaneously the engine of the tree's
own (c)-flavoured MSO development; and it is independently the engine of cslib's proof of Büchi
complementation. Three routes, one device, already in the tree, already proved.

#### Why the surviving falsifications do not move the selection

Two of E3's grounds failed — but neither failure favours a different candidate:

- **(b) Safraless.** Its Lean core is `proof_wanted`, so it is not a resource here. Its one complete
  formalization is Isabelle/HOL in the AFP: decisive as feasibility evidence, **not portable**, and
  under the zero-debt policy ("proved, in Lean, sorry-free, and portable to this pin") not a
  resource. Choosing (b) would mean *starting* the formalization that cslib began and left at
  "Very High difficulty".
- **(c) MSO over ⟨ℤ,<⟩.** The automata half of its discharge is now available in Lean; the MSO half
  and the correspondence are unformalized **anywhere**. cslib has no MSO at all. So (c)'s discharge
  theorem still cannot be cited.
- **(a) Safra/Piterman.** Now technically reachable in Lean via McNaughton rather than Safra — but
  at 7,526 lines across 47 modules on a 76-commit-divergent Mathlib, and what it delivers is a
  deterministic acceptor **over states**. The pigeonhole-over-states route is refuted
  (`Probe732Device.not_lasso_sufficient_on_chain`;
  `...NoFiniteWidth.not_finite_width_fmp`), and `Probe732Device` already established that the probed
  `⊡(Fp)`/`⊡(Pp)` shapes are device-inert. Highest price, wrong axis, no discrimination.
- **(d) Ramsey-coloured summary.** One non-trivial ingredient; **in-tree, proved, sorry-free,
  axiom-clean** (`[propext, Classical.choice, Quot.sound]`); absent from Mathlib (confirmed); with a
  **live consumer** already depending on it in exactly the shape it has; and now independently
  corroborated as the Büchi complementation core.

**This is verdict (i), which the dispatch names as a complete and valid outcome. It is not a
blockage and not a failure.** Nothing here licenses or requires a `/revise 711`.

#### What this verdict does NOT claim

No complexity bound, upper or lower. No claim that `⊡(Fp)`/`⊡(Pp)` discriminate between devices —
`Probe732Device` settled that they do not, and nothing here disturbs it. No claim that candidate (d)
is *adequate* beyond the probed shapes; this task re-examined the *selection evidence*, not the
substrate. No claim that cslib's results are unavailable in principle — they are available, by port,
at the costs tabulated in A.6. No claim about the correctness of cslib's own proofs beyond what
`#print axioms` and the absence of `sorryAx`/`proof_wanted` certify in cslib's own build.

## Decisions

1. **Treat `proof_wanted` as the primary completeness measure for cslib, not `sorry`.** A
   `sorry`-grep returns 0 across all 54 files while 8 main theorems are unproved. Recorded as an
   issue (`false-negative-verification`, severity `costly`) when found.
2. **Degrade absence claims to a grep sweep and say so.** `lean_local_search` returned
   `index: unavailable`, under which an empty result is *not* proof of absence. All Mathlib-absence
   claims in this report rest on a 14-pattern grep over 8,268 source files — stronger evidence for
   absence than an LSP query, and labelled as such rather than presented as an LSP result.
3. **Correct three claims in the task description rather than inherit them.** (a) `BuchiCompl.lean`
   does not carry a proved complementation. (b) The two repositories do *not* share a Mathlib pin —
   76 commits apart. (c) Several files the description lists as upstream
   (`TwoWayNA/*`, `Congruences/{Basic,MyhillCongruence}`, `Languages/{LanguageHom,SafetyLiveness,Slice,SyntacticMonoid}`,
   `NA/{Preimage,Reverse}`) are absent from the **local** fork, which is 155 commits behind.
4. **Report the port assessment as "port nothing", with the dependency dissent recorded and
   rejected on a stated ground** (a `require` would drag *this* tree 76 Mathlib commits forward),
   rather than silently omitting the alternative the dispatch invited as a dissent.
5. **Do not act on the Ramsey subsumption.** Subsumption is proved and machine-checked; acting on
   it would add lines and re-pay glue at each of two orientation-specific use sites.
6. **Record identity hazards on pre-existing entries where the audit found them unrecorded**
   (`vardi_1996_automata_ltl`, `vardi_wolper_1986_automata_verification`), rather than only on the
   13 entries added. Additive field writes; no information removed.
7. **Wire, never re-ingest.** Every literature gap closed was closed by adding a sub-index
   reference to a document already converted in the global corpus. Nothing was converted,
   downloaded, or re-ingested.

## Adversarial Self-Verification

Every load-bearing claim re-challenged against the Claim Verification Bar. For a Lean claim the
verification method is elaboration, never a docstring.

| Claim | Source / counterexample sought | Verification method | Confidence |
|---|---|---|---|
| `BuchiCompl.lean`'s complementation correctness is unproved | Challenged: could `proof_wanted` still register a usable declaration? **No** | Elaboration: `#print axioms ..complement_language_eq` → *unknown constant*; environment probe → `present=false` for all three | **High** |
| cslib's ω-automata files are `sorry`-free | Challenged: is a 0 `sorry`-count meaningful here? **No** — it is a false negative | `grep -c sorry` = 0 on all 54 files, **but** `proof_wanted` = 8 in 3 files. Both numbers reported together | **High** (and the naive reading explicitly refuted) |
| `IsRegular.compl` is proved **upstream** | Challenged: is the fork's version the only proved one? **No** | Read `git show upstream/main:...OmegaRegularLanguage.lean` — real 7-line `by` block at line 248, identical to the fork's; upstream `proof_wanted` sweep returns only `iff_da_muller` | **High** |
| McNaughton (`iff_da_muller`) is **fork-only** | Challenged: present upstream? **No** | Upstream line 259 is `proof_wanted IsRegular.iff_da_muller`; the fork has a proved `theorem` | **High** |
| All claimed-proved declarations are axiom-clean | Challenged: any hidden `sorryAx`? **No** | `#print axioms` on 16 declarations in cslib's own build: all `[propext, Classical.choice, Quot.sound]` | **High** |
| `buchiFamily_cover` colours pairs of **times** by **interval** summaries | Challenged: is this my reading of a docstring, or the proof? **The proof** | Read the proof body: `color t := ⟦xs.extract (t.min' h) (t.max' h)⟧` then `infinite_graph_ramsey color` then `strictMono_of_infinite` | **High** |
| Mathlib at this pin has no ω-automata / Ramsey / MSO | Challenged: LSP said nothing — is that absence? **Not admissible**; replaced | Grep sweep, 14 vocabulary patterns × 8,268 source files, zero hits; `grep '^theorem.*[Rr]amsey'` → empty; MSO patterns → empty | **High** (grep tier, stated) |
| cslib has no MSO and no Safra/Piterman | Challenged: different naming? Searched 5 MSO spellings and 4 determinization spellings | Grep over all of `Cslib/`: MSO patterns → zero; determinization hits are all **prose or `proof_wanted`**, incl. `Conversions.lean`'s own "This is **not** Piterman's 2006 determinization theorem" | **High** |
| cslib's Ramsey theorem subsumes the in-tree one | Challenged: is the derivation real, or a statement I eyeballed as equal? | **Compiled**: `repo_ramsey_from_cslib_ramsey`, plus `RepoRamseyStatement` discharged twice (once per side). Gate exit 0 | **High** |
| The converse derivation is impossible | Challenged: any route from ℕ-specialised to general `Vertex`? | Type-level: `[Infinite Vertex]` gives no bijection with ℕ. **Not machine-checked** — a negative existence claim about proofs | **Medium** (argued, flagged as such in the probe header) |
| Mathlib rev skew is 76 commits and breaks a port | Challenged: is the break hypothetical? **No, observed** | `git log` on both revs + `git rev-list --count` = 76; and the actual compile error `invalidField: domRestrict` on the first ported line | **High** |
| Port closures are 203 / 4,944 / 7,526 lines | Challenged: closure walk correct? | Transitive import walk over cslib sources, `public import` aware; cslib leaves (`Cslib.Init`, lint) counted and separately identified as style-only | **Medium-High** (one script, not cross-checked against `lake`'s own graph) |
| `brunner_seidl_sickert_2019` is an **Isabelle/HOL** formalization of a **Safraless** LTL→DRA | Challenged: is this a paper *about* verification, or a formalization? | Read the source chunks: "The described Isabelle/HOL development is archived in the Archive of Formal Proofs"; "We provide a formalisation of [19] in Isabelle" | **High** |
| 13 named gaps/sources resolve whole in the global index | Challenged: stem-matched by accident? | Whole-id dict lookup against 13,701 global records; 0 orphans on re-validation; stem-collision audit run deliberately and found 3 collisions | **High** |
| `Nat.Nth` is now available here (in-tree docstring stale) | Challenged: olean present but unusable? **No** | `Mathlib/Data/Nat/Nth.olean` present; all 8,268 Mathlib oleans built; **and** the probe compiles using `Nat.nth` | **High** |
| (c)/(d) share a Ramsey core — confidence **raised** | Challenged: am I conflating "Büchi complementation is Ramsey-based" with "route (c) is"? | **Partially.** What is High is that complementation **is** the Ramsey-over-time device (proof-level). That route **(c)** reduces to it is *not* established: MSO↔automata is unformalized. Stated at that precision in the verdict, not overclaimed | **High** on the core; **Medium** on (c)'s reduction |

### Contradiction log

**Resolved — dispatch description vs. source.** The description asserts `BuchiCompl.lean` "IS
candidate (b)'s core — the Kupferman-Vardi rank construction — already formalized in Lean."
Precedence ranking: direct elaboration of the current source outranks a prose summary, and the
dispatch itself instructs "RE-VERIFY at research time, do not trust this summary."
**Resolution:** the *construction* (`complementNA`) is formalized; its *correctness* is not
(`proof_wanted` ×3, `present=false`). The description is right about the definition and wrong about
the result. Resolved in favour of the elaborator.

**Resolved — dispatch description vs. manifests on the Mathlib pin.** The description says cslib is
"on the SAME Lean toolchain as this repository" and gives both Mathlib revs. The toolchain claim is
true; the revs differ by 76 commits. **Resolution:** no contradiction in the description's letter —
it states both revs — but its framing ("same toolchain") invites the inference that ports are
pin-neutral, which the `domRestrict` break falsifies. Recorded as port friction rather than as a
description error.

**Resolved — my own first environment probe.** An early presence check reported
`IsRegular.iff_da_muller` and `IsRegular.compl` as `present=false`, contradicting a successful
`#print axioms` on both moments earlier. **Resolution:** my probe file omitted
`import ...OmegaRegularLanguage`. Re-run with the import: `present=true`. The `#print axioms` result
was correct and the presence probe was my error; the corrected run is what A.3 reports, and the
false reading is disclosed there rather than quietly dropped.

**No unresolved contradictions.**

### Recommendations modified after verification

1. **The verdict's *reasons* were rewritten mid-task, though not its conclusion.** My working draft
   had "KEEP (d), E3's grounds confirmed." Verification falsified two of E3's four grounds
   (McNaughton exists in Lean; a Safraless construction is verified in Isabelle). The conclusion
   survived on *different* evidence — (d)'s ingredient is in-tree and proved while (b)'s and (c)'s
   are not — and the report now says so explicitly rather than resting on grounds that do not hold.
2. **"Redefine `ForMathlib` Ramsey as a corollary" was dropped** after the subsumption compiled.
   Subsumption turned out to be true *and* non-actionable: the line count and the two
   orientation-specific consumers both argue against it. Had I stopped at the mathematics I would
   have recommended the opposite of what the code supports.
3. **"BuchiCompl.lean is the load-bearing asset" was inverted.** The load-bearing assets are
   `IsRegular.compl` (upstream) and `iff_da_muller` (fork) — neither mentioned in the dispatch — and
   `BuchiCompl.lean` is not an asset at all.
4. **A Lake `require` was considered seriously and rejected on a stated ground**, not dismissed by
   fiat as the dispatch's framing would have permitted.
5. **Two hazard writes were added to pre-existing entries** beyond the task's literal scope, because
   the stem-collision audit the identity-hazard instruction implies surfaced unrecorded collisions
   with *opposite fidelity verdicts* — the precise failure mode the hazard convention exists to
   prevent.

## Literature Proof Structure

**Source**: Büchi 1962 complementation, as presented in
`thomas_1997_languages_automata` ("Languages, Automata, and Logic", `verified_conversion`, source
PDF present) — E3's own named resolving check for the (c)/(d) question.

**Strategy**: complementation of an NBA without determinization, via a finite-index right
congruence on finite words plus Ramsey over pairs of positions.

**Step map** (with the Lean identifier that discharges each step, and its status):

| # | Literature step | Lean identifier | Status |
|---|---|---|---|
| 1 | Define the Büchi congruence `u ≈ v`: same state-pairs reachable, and same state-pairs reachable *via an accepting state* | `Cslib.Automata.NA.Buchi.BuchiCongruence` | PROVED (right-congruence laws discharged) |
| 2 | Show it has **finite index** when the state type is finite | `buchiCongruence_fin_index` | PROVED |
| 3 | Form the family `[u]·[v]^ω` over pairs of classes | `buchiFamily` | PROVED (`mem_buchiFamily`) |
| 4 | **Ramsey step**: every ω-word lies in some family member — colour the pair `{i,j}` by the class of the segment `xs.extract i j`, apply infinite Ramsey for pairs, take the monochromatic monotone time sequence | `buchiFamily_cover`, via `Cslib.infinite_graph_ramsey` + `strictMono_of_infinite` | **PROVED** — this is the step that *is* candidate (d) |
| 5 | Show the family **saturates** the accepted language (each member is inside it or disjoint from it) | `buchiFamily_saturation` | PROVED |
| 6 | Conclude: a finite saturating cover of ω-regular pieces makes the complement ω-regular | `IsRegular.fin_cover_saturates_compl` → `IsRegular.compl` | **PROVED, upstream** |
| 7 | *(separate route, same congruence family)* ω-regular ⇒ deterministic Muller, by Choueka decomposition `p = ⨆ i, l i · (m i)^ω` | `IsRegular.to_da_muller` → `iff_da_muller` | **PROVED, fork-only** |

**Lean translation considerations.** Step 4 is the only step requiring a theorem absent from
Mathlib, and it is the only one this repository already owns independently
(`Nat.exists_strictMono_const_pair_colour`, in the curried ordered form; cslib's is the unordered
`Finset` form — this task's probe bridges them). Steps 1–3 and 5–7 need the full `LTS`/`ωSequence`/
`ωLanguage` stack, which is where the 7,526-line port cost sits. **The expensive steps are the
automata bookkeeping; the mathematically distinctive step is the cheap one, and it is already here.**

**Note on the alternative lineage.** `thomas_1997` (the *other* Thomas 1997 — EF games and the
composition method; `no_source_pdf`, hazard-carrying, cite with care) is the lineage of this
repository's `MonadicFO`/`NEquivalence`/`RamseyFactorization` cluster, which performs step 4's
analogue with monadic **k-types** in place of congruence classes and needs no automata at all.

## Tactic Survey Results

Tactics were exercised only inside the Part C probe, against this pin. Recorded because the results
are themselves port-friction evidence.

| Goal / step | Tactic tried | Result | Note |
|---|---|---|---|
| `infinite_pigeonhole_principle` body | cslib's term proof with `s.domRestrict f` | **FAIL** `invalidField` | cslib's Mathlib renamed `restrict`→`domRestrict`; one-token fix to `s.restrict f` |
| same, final conjuncts | cslib's `grind` | replaced by `intro x hx; exact hx.1 / hx.2` | explicit terms chosen over `grind` across a 76-commit skew |
| `Set.Infinite.diff` in `goodSelection_exists` | `Set.Infinite.diff` | **deprecation warning** | switched to `Set.Infinite.sdiff` |
| good-selection chain antitonicity | cslib's `⋂ m < n` induction with `grind [GoodSelection]` | replaced by direct `induction n` + `Nat.lt_or_ge` case split | equal strength, smaller surface; disclosed in the probe header |
| `infinite_graph_ramsey` final pair case | cslib's `grind [Finset.pair_comm, Finset.coe_insert, Finset.coe_singleton]` | replaced by `rcases Nat.lt_or_ge` + `rw [Finset.pair_comm, ...]` | compiles |
| `({a,b} : Finset ℕ).min'/max'` on `a < b` | `simp` / `omega` | insufficient | hand-proved via `le_antisymm` + `Finset.min'_le`/`le_min'`/`max'_le`/`le_max'` (`pair_min'_max'`) |
| monotone enumeration of an infinite `Set ℕ` | `Nat.nth` + `Nat.nth_strictMono` + `Nat.nth_mem_of_infinite` | **PASS** | contradicts the in-tree docstring's claim that `Nat.Nth` is unavailable here |
| `({a,b} : Finset ℕ).Nonempty` | `⟨_, by simp⟩` | **FAIL** (metavariable) | explicit witness `⟨Nat.nth (· ∈ s) i, by simp⟩` |

**Net**: cslib's *statements* ported cleanly; cslib's *tactic scripts* did not, and every `grind` call
in the ported fragment was replaced. For a 147-line file that is cheap; extrapolated across the
7,526-line McNaughton closure it is the dominant cost and the main argument against porting.

## Context Extension Recommendations

- **Topic**: `proof_wanted` as a trust surface distinct from `sorry`.
  **Gap**: `context/project/lean4/patterns/dependency-tracing.md` and the lean4 rules cover `sorry`
  and `#print axioms`, but nothing records that `proof_wanted` emits **no declaration**, so both a
  `sorry`-grep and `#print axioms` register it as clean while the result does not exist. This task
  lost time to exactly that.
  **Recommendation**: add a subsection to `context/project/lean4/domain/metadata-trust-surfaces.md`
  — "What a zero `sorry`-count does not certify" — naming `proof_wanted`, `axiom`, `native_decide`,
  and `@[implemented_by]`, with the environment-presence probe (`(← getEnv).find? name`) as the
  check that settles it.

- **Topic**: auditing an external Lean library as a *port* candidate.
  **Gap**: no context file describes the procedure this task had to invent — provenance split
  against `upstream/main`, `proof_wanted` sweep, axiom profiling, transitive import-closure
  costing, and Mathlib-rev-skew measurement including "is the dependency's pinned HEAD itself a
  renaming commit?"
  **Recommendation**: add `context/project/lean4/patterns/external-library-port-assessment.md`
  with that checklist and the closure-walk script.

- **Topic**: stem-collision auditing of the literature sub-index.
  **Gap**: `context/project/literature/domain/literature-index.md` states the ids-matched-whole rule
  and documents the `thomas_1997` example, but nothing *audits* for new collisions. This task found
  three unrecorded ones, one with opposite fidelity verdicts.
  **Recommendation**: add a stem-collision pass to `literature-audit.sh` (group sub-index ids by
  author-year stem; flag any group where members lack a `hazard` and their global
  `provenance_fidelity` values differ).

## Appendix

### Search queries and sweeps used

- Mathlib absence sweep: 14 patterns (`Buchi`, `Büchi`, `Buechi`, `OmegaLanguage`, `omegaLanguage`,
  `OmegaRegular`, `Rabin`, `Streett`, `ParityAutomaton`, `MullerAutomaton`, `Safra`, `Piterman`,
  `omegaAccept`, `OmegaAcceptor`) over 8,268 files; plus `Ramsey`/`ramsey` declaration grep; plus
  `MonadicSecondOrder`/`monadic second`.
- cslib sweeps: `proof_wanted`, `sorry`, `determiniz|Safra|Piterman|LAR|latestAppearance`,
  `MSO|MonadicSecondOrder|monadic second|second-order|SecondOrder`,
  `infinite_graph_ramsey|infinite_pigeonhole_principle`, `strictMono_of_infinite`,
  citation-key extraction `\[[A-Z][A-Za-z]+[0-9]{4}[a-z]?\]`.
- Provenance: `git cat-file -e upstream/main:<path>` + `git diff --quiet upstream/main -- <path>`
  per file; `git ls-tree -r --name-only upstream/main` for the upstream-only set.
- Elaboration: `lake env lean` on scratch files in cslib (`#print axioms` ×16; `run_cmd` environment
  presence probe ×10) and in this tree (the probe, 4 compile iterations).
- Literature: whole-id dict lookup over 13,701 global records; keyword regex
  `omega|automat|buchi|büchi|determiniz|safra|piterman|parity|rabin|streett|muller|mso|monadic|ramsey|complementation|infinite object`
  over global titles+ids; stem-collision audit of all 106 sub-index entries;
  `literature-coverage-delta.sh --query`.

### Key file references

- `~/Projects/cslib/Cslib/Computability/Languages/OmegaRegularLanguage.lean:286` — `IsRegular.compl`
  (upstream line 248)
- `~/Projects/cslib/Cslib/Computability/Languages/OmegaRegularLanguage.lean:440` —
  `IsRegular.iff_da_muller` (upstream line 259: `proof_wanted`)
- `~/Projects/cslib/Cslib/Computability/Languages/Congruences/BuchiCongruence.lean:118` —
  `buchiFamily_cover`; the Ramsey call is at line 125
- `~/Projects/cslib/Cslib/Foundations/Combinatorics/InfiniteGraphRamsey.lean:123` —
  `infinite_graph_ramsey`
- `~/Projects/cslib/Cslib/Computability/Automata/NA/BuchiCompl.lean:293,321,328` — the three
  `proof_wanted` declarations
- `~/Projects/cslib/Cslib/Foundations/Data/OmegaSequence/InfOcc.lean:82` —
  `strictMono_of_infinite` (pure `Nat.nth`)
- `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean:134` —
  `Nat.exists_strictMono_const_pair_colour` (stale `Nat.Nth` note at line 36)
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean:73,358,360` — the alias
  and the two orientation-specific instantiations
- `FormalSystem/Metalogic/Expressiveness/MonadicFO.lean:62` — `MonadicSignature`
- `FormalSystem/Metalogic/WeakCanonical/NEquivalence.lean:73` — `kTypeOf`
- `specs/evidence/seam-gluing-ray-product/cslib-ramsey-port-feasibility.lean` — this task's probe
- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` — E3, the probe re-audited here
