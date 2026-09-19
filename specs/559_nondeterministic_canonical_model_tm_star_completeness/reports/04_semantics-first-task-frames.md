# Research Report: Task #559 (round 04: semantics first — the task semantics on the manuscript's own terms)

**Task**: 559 - nondeterministic_canonical_model_tm_star_completeness
**Started**: 2026-09-18T23:54:20Z
**Completed**: 2026-09-19T00:13:58Z
**Effort**: one research dispatch (orchestrated, seq 6, `--lit`, user focus: semantics-first round)
**Dependencies**: reports 01-03 of this task and probes 01-03 (not redone); 535 (archived), 533, 536, 537 (landed baseline)
**Sources/Inputs**: - The author's manuscript `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (4554 lines), read directly: lines 469-556 (Introduction), 557-942 (Primitive Worlds), 943-1471 (Possible Worlds, Restricted Modalities, Bimodal Logic, Extensions), 1472-1860 (Tense and Modality, Open Future, Dynamical Systems, Conclusion), 2811-3470 and 3530-3904 (Appendix: Task Semantics), 4086-4410 (Appendix: Soundness and Completeness). All manuscript line numbers below are to that file as read on 2026-09-18. - Codebase: `Syntax/PlusLanguage/Axioms.lean` (the eight stability constructors), `Semantics/PlusLanguage/PlusTruth.lean` (`PlusTruthAt`), `Semantics/StarLanguage/StarTruth.lean` (`StarTruthAt`), `Syntax/StarLanguage/{Formula,Axioms}.lean`, the StarLanguage READMEs. - Literature (held): `thomason_1984` §4 (T×W frames, Kamp frames, neutral frames); reports 01-03's readings of `reynolds_2001`, `reynolds_2002`, `reynolds_2003` are relied on and not repeated. - A compiled Mathlib-only probe (bare `lean`, pinned toolchain, no `lake` process, no `FormalSystem` import).
**Artifacts**: - `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/04_semantics-first-task-frames.md` (this report); - `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/04_semantics-native-general-duration.lean` (600 lines, sorry-free, exit 0)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The user's worry is half right, and the half that is right matters.** Round 03's *ℤ-time
  digraph reading* and its *limit-closure* findings are faithful to the manuscript, which itself
  describes `H_F` over ℤ as the bi-infinite paths of a graph (cut text at 1829) and states limit
  closure in its own words as *upward-directed gluing, which rests on Saturation* (footnote at
  3073). What round 03 got wrong is the **identification of `⊡` with Ockhamist historical
  necessity**. The manuscript distinguishes three restricted modalities (1153, 1182-1183): `⊡`
  over `⟨τ⟩_x` (same world STATE now), `▷` over `|τ⟩_x` (same past), `◁` over `⟨τ|_x` (same
  future). The Ockhamist `□` is `▷`, not `⊡`. Compiled this round: the Ockhamist axiom HN
  (`Pα → □P◇α`; given S5, equivalent to Thomason's AK12) **fails for `⊡`** and holds for `▷` (`hn_stab_refuted`,
  `hn_open`). Any engine borrowed from Reynolds 2003, whose "matching squares" step rests on
  shared pasts, is borrowed from the wrong modality.
- **What `⊡` is, natively: a memoryless (Markov) modality.** Its truth depends on the present
  world state alone — not on the history and not on the time (`stab_state_only`, compiled at an
  arbitrary temporal order, using translation-closure and nothing else). The alternatives through
  a state are all pastes of a past reaching it with a future leaving it (`app:gluing`, 3070); PS
  and US are exactly that. The right classical analogue is the state/path split of CTL* over a
  transition system whose states recur, not a tree.
- **Three compiled invariances say what the language with `⊡` can and cannot see**, each at every
  temporal order `D` and with no frame axiom (that `F × D` is again a task frame needs its
  Saturation, which stays on paper from report 03 §3.2):
  1. *It cannot see that a state recurs.* Truth is preserved by the projection from the clock
     product `F × D` (`clock_invariance`), whose histories never revisit a state
     (`clock_no_recurrence`). The manuscript's motivating feature — chess positions recur
     (646-652, 1025-1029) — is invisible to L and to L⁺.
  2. *It cannot see durations.* Truth is invariant under re-timing each history by an arbitrary
     order automorphism of `D` (`repar_invariance`). Duration-indexed principles are therefore not
     expressible in L⁺ at all; cross-history synchrony is exactly what the stored-time registers of
     L⋆ add (the manuscript's drift frame, 3720-3769, is an instance).
  3. *Limit adds no validity beyond Nullity.* `F × D` satisfies Limit as soon as `⇒₀` is the
     identity in `F` (`clock_limit`), and Compositionality and Seriality are inherited
     (`clock_comp`, `clock_serial`).
- **The semantics-native statement of the whole problem (paper, short).** For every translation-
  and paste-closed bundle `H`, the all-histories set of the frame read off `H` is the
  **topological closure of `H`** in `W^D` (product topology, `W` discrete). All-histories
  semantics is bundled semantics restricted to *closed* bundles; limit closure is literally
  closure; Saturation is the compactness substitute that gives a closed path space the Extension
  property when `W` is infinite (it is free for finite `W`, `cor:saturation-finite`, 2866). A
  complete system must axiomatise closedness, and an engine must build a bundle that is already
  closed for the closure formulas.
- **A native naming rule, compiled: name the world STATE.** Because sentence letters denote sets
  of world states (952-953), a fresh letter can always be made to name the present state. The
  rule "from `⊢ (q ∧ ⋀_ψ NOM_q(ψ)) → φ`, `q` fresh, infer `⊢ φ`" is sound frame by frame at every
  `D` with no frame axiom (`state_name_sound`). It replaces round 03's clock/IRR rule, which names
  a *time* and sits badly with the manuscript's "durations are strictly exogenous" (953) and its
  exclusion of temporal predicates from the object language (817). Like the clock rule it is also
  sound on translation-closed bundles (paper: the same proof), so it does not derive any `LC_n`.
- **The manuscript states no proof system or completeness claim for `⊡` over all task frames.**
  Its live text omits the restricted modals (1210) and calls a logic for L⋆ "outside the scope"
  (1466). Its commented-out `def:TM-stability` (3775-3794) is, schema for schema, the repository's
  `PlusAxiom` stability block; its commented-out remark (3832) says "whether **TM**⁺ is complete
  over all task frames remains open". **Reports 01-02 answer that question negatively.** The
  author should know this before the remark is ever restored.
- **Task 560: unchanged** (`plus_incomplete_base` with BLC). Follow-on tasks are revised below;
  no completeness theorem is stated anywhere, and nothing here licenses one.

## Context & Scope

The dispatch's `User focus` asked for a semantics-first round with five deliverables: (1) what the
task semantics is and is for, on the manuscript's terms, with line numbers; (2) a contrast with
Ockhamist trees, bundled trees, T×W and Kamp frames, saying where round 03 respects or distorts
the semantics; (3) what the manuscript itself says about a proof system and completeness for `⊡`
and the starred language, compared with the repository; (4) semantics-native leads; (5) a revised
table and recommendations. Standing constraints carried over: research only, no change under
`FormalSystem/` or `Tests/`, no `lake build`, probes import Mathlib only, never a sorried
completeness theorem, every unchecked claim labelled, every literature claim tied to a held source
or labelled recalled; reports 01-03 not redone.

**Status vocabulary.** *Compiled*: a theorem of probe 04, which (unlike probes 01-03) mirrors
`PlusTruthAt` over an **arbitrary totally ordered abelian group** `D` with a duration-indexed
relation `R : D → W → W → Prop` and `H_F` = all total histories; no frame axiom is assumed unless
the theorem names it. *Paper*: an argument written out here. *UNVERIFIED*: a sketch. *Recalled*: a
literature fact without a held source.

## Findings

### 1. What the task semantics is, and what it is for (manuscript, with line numbers)

**1.1 The diagnosis it answers.** Prior's world states answer two questions at once, *when* a
sentence is true and *what* configuration obtains; "since the position-marker and the
configuration are one and the same, no configuration can occupy two positions, which is why the
same world state cannot recur in any strict history" (721-722). That rules out chess positions
recurring and transposed move orders (646-652, 699-704). Montague and Kaplan separate when from
what by making both worlds and times primitive, at the cost of either trivialising the perpetuity
principles (`⊠`, "necessarily always", 750-797) or invalidating them and then restoring them by a
model constraint (*Abundance*) that commits one to temporal absolutism or to instrumentalism about
worlds (832-937). The task semantics separates the roles at the level of primitives instead
(723-725).

**1.2 The primitives.**

- *World states* `W`: "instantaneous maximal possible configurations of the system under study"
  (949); primitive here, defined elsewhere (footnote at 948). Sentence letters denote **sets of
  world states**, so "durations are strictly exogenous to the interpretation of the sentence
  letters … this fact plays a critical role in validating the perpetuity principles" (952-953).
- *Durations* `D`: a nontrivial totally ordered abelian group (956). Durations, not times, carry
  the order and the group structure (950); a duration is a "time" only relative to a possible
  world, and "the choice of origin is arbitrary" (951, 1048).
- *Task relation* `w ⇒_x u`: "what is dynamically possible for the system" (970), extended to
  negative durations by the reflection convention (964). Task frames are labelled transition
  systems, "non-deterministic dynamical systems" (1005).

**1.3 The four frame axioms and their stated motivation** (985-991, restated 2837-2840): tasks
"compose through intermediate world states, where no world state is a dead end in either
direction, distinct world states are instantaneously separated, and no world state is missing
wherever compatible constraints converge" (991).

| Axiom | Manuscript's role for it | Lines |
|---|---|---|
| Compositionality (iff) | `R_{x+y} = R_x ∘ R_y`, the Chapman-Kolmogorov shape; composing direction gives gluing of convex histories at a shared point, factoring direction gives nonempty segments | 985, 974-975, 3070-3096, 2962-2968 |
| Seriality | no dead ends either way; with `D` unbounded, time neither begins nor ends; nonempty fibres | 986, 2967, 1020 fn |
| Limit | `⋂_{x>0}(w)_x = {w}`; yields Nullity `w ⇒₀ w` and its converse, hence `⇒₀ = id`; the task topology is T1 | 987, 2852-2860, 1671, 2896-2909 |
| Saturation | "secures a common candidate" when the nested constraints on a new time have no least member, "as when `z` is a limit of times in `X`"; a ball-space (spherical-completeness) condition; gives the Extension Theorem and *Occurrence*; "not needed" when a nearest assignment exists; free and choice-free for finite `W` | 996-1003, 2840-2844, 3024-3032, 3038-3050, 3056-3064, 2866-2875 |

The manuscript's own statement of **limit closure** is the footnote to `app:gluing` (3073-3074):
"Gluing along an *upward directed* family of domains rests on *Saturation* rather than on
composition alone … The upward directed case genuinely requires *Saturation*", with a `D = ℚ`
counterexample in which a Zeno chain of convex histories has no value at the limit time. Report
02's mechanism ("Saturation yields limit closure") is the manuscript's footnote, rediscovered.

**1.4 Possible worlds are constructed, and `H_F` is maximal.** A possible world is a partial
history with total domain (1020, 2926-2932); every partial history extends to one (1021, 3038);
"every world state occurs at some time in some world history, thereby excluding idle world states"
(1022, 3056). Strictly, a possible world is a translation class `[τ]_F`, but "it is `H_F` that
will play an important role in the semantics" (1041-1050). Against bundles the manuscript is
explicit: "Rather than ensuring axiomatizability by adding a freely chosen bundle of histories as
a further component of the models, `H_F` is the maximal set of possible worlds determined by a
task frame" (1775). The dispatch's "bundled semantics is a different semantics" is the author's
own position.

**1.5 Translation closure and relative time.** `H_F` is closed under translation because the task
relation is indexed by durations and not by times (`app:auto_existence`, 3178-3188; 1274-1277);
translation preserves truth because letters denote state sets (3193-3209). MF "answers to no
constraint on task frames beyond indexing the task relation by durations rather than fixed times"
(1277), and the footnote at 1279 says what would go wrong otherwise. This is the manuscript's
replacement for *Abundance*: time-shifted worlds exist by construction, so no temporal absolutism
and no redundant primitive worlds (1039, 1137).

**1.6 The reading of `□`.** `□` is metaphysical necessity, "the strongest objective modality"
(524, 1135, 1209), S5 (1146-1150), quantifying over all of `H_F` at the same time coordinate
(1061). It is **not** historical necessity: the metaphysical modals range over "all possible
worlds, including those that bear no relation to the actual past from our present perspective"
(520), which is why `sometimes φ → ◇φ` holds in the Alvin example (515-522). It is also **not**
Montague's primitive `⊠` "necessarily always" (750), which the manuscript rejects because it makes
the perpetuity principles instances of T (776-797). Extensionally the two coincide here —
`□φ → □△φ` is P3 (1307) — but that is a *derived* consequence of translation closure (1129-1131),
which is the point of the construction. Semantically `□` is the universal modality over all
(history, time) points.

**1.7 The stability modal and the open future.** `⊡φ` holds at `(τ, x)` iff `φ` holds at `x` in
every `σ ∈ ⟨τ⟩_x = {σ ∈ H_F : σ(x) = τ(x)}` (1153-1155, restated 3545-3549). Its monomodal logic
is S5; `⊡φ → △φ` is invalid "since stability at one time constrains no other"; `φ → ⊡φ` is valid
for non-temporal `φ` (footnote 1158-1161). It defines *will/could always/eventually* (1163-1171).
The manuscript then introduces two *further* restricted modalities (1179-1198), the open-future
and open-past operators (macros `\Openfuture`, `\Openpast`: a box with `▷`, respectively `◁`,
superimposed; written `▷` and `◁` in this report): `▷` over
`|τ⟩_x` (agree with `τ` at all `y ≤ x`) and `◁` over `⟨τ|_x` (agree at all `y ≥ x`), with
`|τ⟩_x ⊆ ⟨τ⟩_x`, `⟨τ|_x ⊆ ⟨τ⟩_x`, `|τ⟩_x ∩ ⟨τ|_x = {τ}`, and `|τ⟩` narrowing as time advances
(1197-1198). Constructed worlds make these sets *definable*; primitive worlds would need
accessibility relations "constrained rather than determined" (1194-1199). All restricted modals
are then set aside (1210).

The open future is located "in the task relation … so that both `w ⇒_x u` and `w ⇒_x v`"
(1561), not in a partial order of times; TL is kept (1537-1541). "The openness of the future
consists not in the existence of incomparable future times but in the absence of any possible
world which is designated as the *actual* world" (1539); no actual world `@` and no present state
`#` is posited (1636-1647). Branching time is rejected because it reintroduces the Peircean
difficulties or collapses back to a history parameter (1544-1555).

**1.8 Store and recall.** L⋆ adds stored-time registers `↓ⁱ/↑ⁱ` **and stored-world registers**
(1456-1464), generalising Vlach's now/then; they are motivated by `(Sea)` and `(Det)`
(1577-1583), which compare histories through the present state *at one stored future time*. The
appendix semantics suppresses the world registers (3546-3547). "Extending **TM** to provide a logic
for the resulting language is outside the scope of the present paper" (1466).

**1.9 The dynamical-systems reading.** Every task frame is a non-deterministic dynamical system
(Nullity, Compositionality, Interpolation; 1663-1671); Williamson's semantics evaluates at world
states directly and is confined to deterministic systems (1690-1719), where exactly one history
passes through each state (`lem:deterministic-singleton`, 3559). For nondeterministic frames the
manuscript's own state-level evaluation is `def:state-set` on *Flow* frames (3670-3714): on the
drift frame `⊡` is idle although the frame is not deterministic (3720-3748), so no set of L⁺
sentences defines determinism (3755-3769), while `(Det)` with registers does (3743-3747). The
conclusion says the possible worlds are "the labeled runs of `F`, where the branching tree of
states is not posited but may be recovered by unfolding" (1764), that individual worlds are linear
as in LTL while the worlds through a state branch as in CTL, with `□` universal rather than
state-relativised (1784-1786), and (in text now cut) that for finite `W` and `D = ℤ`, `H_F` "is a
shift of finite type … possible worlds [are] the bi-infinite paths through that graph"
(1829-1836).

### 2. Contrast with Ockhamist trees, bundled trees, T×W and Kamp frames

Sources for the right-hand columns: `thomason_1984` §4 Definitions 6, 9, 10 and axioms AK0-AK13
(held); Reynolds 2002 §8 as read in report 03 (held).

| Feature | Task frames (manuscript) | Ockhamist / bundled trees | T×W, Kamp, neutral frames |
|---|---|---|---|
| Primitive | world states, durations, task relation; worlds constructed | moments in a tree order; histories = maximal chains (or a chosen bundle) | worlds and times primitive; `≈_t` a primitive family of equivalences |
| Same configuration twice | yes (1025-1029) | no — a moment is its position | times cannot recur; a neutral-frame slice can be `≈` to an earlier one (Thomason p. 149, "history repeating itself") |
| Root, tree order | none; `D` unbounded both ways (1020 fn); "task frames distinguish no initial world state" (1813) | tree, often rooted in the CTL* setting | none |
| Divergence in the past | yes: histories through a state share neither past nor future | never: the past of a moment is unique | never: `w ≈_t w'` and `t' < t` imply `w ≈_{t'} w'` (Def. 6 (2); Def. 10 (5)) |
| What fixes the alternatives at a time | the present **state** (`⟨τ⟩_x`) | the shared **past** | the primitive `≈_t`, downward closed in `t` |
| Time | a group acting by translation; `H_F` translation-closed; `□` sees all translates | no group; no translation | one linear order (T×W) or one per world (Kamp); no translation |
| History set | maximal, determined by the frame (1775) | all maximal chains, or a bundle | a primitive set `W` |
| Atoms | sets of states ⇒ `p → ⊡p` | sets of moments ⇒ `p → □p` for the Ockhamist `□` | Def. 7 proviso ⇒ AK13 |

**What is genuinely shared.**

- S5 for the restricted modality; atoms non-contingent under it (AS / AK13).
- Evaluation at (history, point) with linear time inside each history — the manuscript endorses
  the Ockhamist evaluation discipline against the Peircean one (677-686, 1555).
- *Limit closure of the full history set.* In a tree, a chain of moments lies on a branch; here an
  upward-directed family of convex histories extends to a world by Saturation (3073). This is why
  the Burgess/Thomason formula transposes (report 02) and why `LC_n` is valid (report 03).
- *Fusion (paste) closure.* This is not shared with trees in general but with CTL* structures
  (the fusion/suffix/limit triple of Emerson-Halpern, as the task description reports it; the held
  copy is an unverified summary and was not re-read this round): translation-closure is suffix closure
  two-sided, paste-closure is fusion closure, limit closure is closedness (§4.1 below).

**What is not shared, and what it costs.**

- **`⊡` is not the Ockhamist `□`.** The Ockhamist modality is the manuscript's `▷`. On a tree a
  moment determines its past, so "same moment" and "same past" coincide and the distinction
  disappears; on a task frame it does not. Compiled: `hnStab := P p → ⊡ P ⟐ p` is refuted on a
  three-state ℤ-frame (`hn_stab_refuted`; the frame's Compositionality is `R3_comp`, Saturation
  by finiteness, Limit automatic over ℤ), while the same principle holds for `▷` at every `D`
  (`hn_open`), and `⟨τ⟩_x ⊇ |τ⟩_x` (`stab_imp_open`). HN is Reynolds 2003's interaction axiom (report 03's reading) and is
  equivalent, given S5, to Thomason's AK12 (`◇Pφ → P◇φ`, read through OCR); the task-frame neutral structure fails Thomason's one-way
  completion condition (Def. 10 (5)).
- **The native interaction principle is two-way pasting, not one-way completion.** `⟨τ⟩_x` is the
  set of all pastes `past ⌢_x future` of a half-history reaching `τ(x)` with one leaving it
  (`app:gluing`). That rectangle (Markov) property is PS; US is its iterate along `U`. There is no
  analogue in trees (pasts are unique) and only a one-sided analogue in Kamp frames (Thomason's
  formula (17), Fig. 1).
- **`⊡`-truth is a function of the state alone** (`stab_state_only`, compiled at every `D`): same
  state at *any* two times of *any* two histories, same verdict on every `⊡φ`. In a tree the
  corresponding statement is about a moment, which never recurs. This makes `{⟦⊡φ⟧}` an algebra of
  *state propositions* and the logic two-sorted in the CTL* sense (state formulas: letters, `⊡φ`,
  `□φ`, Booleans; path formulas: the rest) — natively, not by analogy. The manuscript's
  `def:state-set` (3670) is that split on Flow frames.

**Round-03 borrowings, one by one.**

| Round-03 item | Respects or distorts | Reason |
|---|---|---|
| ℤ-time `H_F` = bi-infinite walks of a doubly serial digraph | respects | the manuscript says the same (1829-1836); CTL* structures are state-based, not trees |
| `LC_n`, `omega_limit`, `omega_chain` | respects | the ℤ case of upward-directed gluing (3073); better named *closure* (§4.1) |
| two-way bounded morphisms (`tw_invariance`) | respects | the natural morphism of a duration-indexed transition system with converse; forth and back at every duration, negative included |
| clock product | respects as a tool, distorts as a picture | it is a task frame and the projection preserves truth (now compiled at every `D`); but its states carry an absolute date and never recur — it is the *abundant two-dimensional model* of 832-937 rebuilt inside the task semantics. What it proves is a limitation of L⁺ (§3.3, item 1), not a feature of the intended models |
| IRR / clock naming rule | sound, but against the grain | it names a *time* within each `⊡`-cluster; the manuscript keeps times out of the object language (817) and out of truth conditions (953). The state-naming rule of §4.3 is the native counterpart |
| AA rule via forward-cone unravelling | distorts | one-directional, rooted at the evaluation point, tree-making, ℤ-only; usable as a ZTime proof device and nothing more |
| universal cover / oriented forest / MSO over trees (1.2-1.3) | tool only | "the branching tree … may be recovered by unfolding" (1764) licenses unfolding as a derived object; it discards recurrence and exists only at ℤ |
| Reynolds-2003-style engine at Base (hues, colours, matching squares + IRR + LC) | **distorts** | that proof is for the past-sharing modality; HN fails for `⊡`; only the LC ingredient transfers |
| "No language extension is recommended" (Decision 5) | at odds with the manuscript's direction | the manuscript introduces registers precisely because L⁺ is too weak (1466, 1532, 1626), and the repository's own TM⋆ README names "needs nominals, which L⋆ has none of" as an obstruction; see §4.3 |
| per-class table headed by an automaton obstruction | reframed | the obstruction is native and class-independent: emergent histories are the *closure* of the intended bundle (§4.1-4.2) |

**Where round 03 framed the problem in a way the manuscript would reject.** (i) Treating the
problem as "full Ockhamist/CTL* completeness transposed", with `⊡` in the role of historical
necessity. (ii) Proposing, as part of the candidate *system*, a rule whose content is that a time
can be named cluster-wise. (iii) Reading task frames through their tree unfoldings as if the tree
were the model. None of this invalidates a compiled result of round 03; it changes which of them
belong in a candidate system and which are proof devices.

### 3. What the manuscript says about a proof system and completeness, against the repository

**3.1 Inventory.**

| Manuscript item | Lines | Status in manuscript | Repository |
|---|---|---|---|
| **TM** (S5 + BX + MF) and **TM**_Z, **TM**_D, **TM**_R; strong completeness at Base and Dense, weak at ℤ and ℝ; strong fails at ℤ, ℝ | 1223-1273, 1381-1413, 4099-4161, 4369-4387 | live; "verified in the Lean 4 repository" | landed (533, 536) |
| Soundness: only MF and TR proved in the text | 4186-4346 | live | landed |
| Decidability of **TM** | 1791, 1800 | "still-open"; decision procedure with verified soundness, no decidability theorem | matches |
| `⊡`, `▷`, `◁`, nomic `⊞` semantics | 1153-1210 | live; then "I will omit further consideration" | `⊡` only (`PlusTruthAt`); `▷`, `◁`, `⊞` not formalised |
| S5 for `⊡`; `⊡φ → △φ` invalid; `φ → ⊡φ` for non-temporal `φ` | 1158-1161 | footnote | `stab_*`, `atom_stab`, state-locality fragment |
| *Determined* `φ → ⊡φ`; sound over frames validating it, complete over Deterministic frames; the two classes share a logic | 1517-1534, 1769-1774, 4381 | live, cited to the repository | landed (537) |
| Drift frame, `cor:no-characterization` | 3720-3769 | live, marked `% CHECK` | referenced in `Metalogic/Independence/RealTranslationFrame.lean` and `Metalogic/Deterministic/Validity.lean` (not audited this round) |
| `def:TM-stability`: SK, ST, S5 (`⟐φ → ⊡⟐φ`), MS, AS, PS, US with pure-future / pure-past side conditions | 3775-3794 | **commented out** ("too much for this paper") | `PlusAxiom`: `stab_k`, `stab_t`, `stab_5`, `box_stab`, `atom_stab`, `paste`, `untl_paste` — the same seven, plus `stab_4` |
| Soundness proof of PS and US by `app:gluing` | 3811-3816 | commented out | `Semantics.paste_valid`, `untl_dstab_valid` |
| "whether **TM**⁺ is complete over all task frames remains open" | 3832 | **commented out** | **answered: no** (reports 01-02; ZTime compiled in the mirror, Base with two paper steps) |
| Registers `↓ⁱ/↑ⁱ` and world registers; a logic for L⋆ "outside the scope" | 1456-1466 | live | time registers in `StarTruthAt`; TM⋆ sound; completeness OPEN, never stated |
| `(Det)`, `Det±` definability of determinism | 1577-1583, 3839-3867, 3873-3888 (last commented out) | live / commented | landed |

So the manuscript contains **no conjecture, sketch or stated open problem about a complete system
for `⊡` over all task frames in its live text**. The only statement is the commented-out remark at
3832. Nothing in the manuscript anticipates limit-closure axioms.

**3.2 Divergences between manuscript and formalisation.**

1. `stab_4` is an extra constructor. It is derivable from K, T and the manuscript's S5 schema, so
   the theorem sets agree; it costs one arm per recursion. Harmless; worth a docstring note.
2. `StarTruthAt` has time registers only. That matches `def:BLstar-semantics` (3546-3547), which
   suppresses the world registers, but not the language of §Extensions (1460-1461). No result of
   the manuscript uses a world register.
3. The `⊡` clause is now checked against the manuscript source, which report 02 could not do
   (`def:BLstar-semantics` was LIVE-UNPINNED): lines 1155 and 3549 read "`M,σ,x ⊨ φ` for all
   `σ ∈ ⟨τ⟩_x`", which is `PlusTruthAt`'s `.stab` arm verbatim. In `StarTruthAt` the register
   vector is passed unchanged to `σ`, as at 3549.
4. Docstring line references have drifted: `Axioms.lean` cites "paper line 1108 / 1118 / 1119";
   the clause is now at 1153-1155 and the footnote at 1158-1161. Cite the labels
   (`def:BLstar-semantics`, the footnote to `($\Stability$)`) instead of line numbers.
5. `modal_future` in TM⋆ is restricted to recall-free `φ` (`Axioms.lean:426`); the manuscript has
   no TM⋆, so there is nothing to compare, but the restriction is forced: registers break
   translation invariance.
6. The manuscript's pure-future condition ("every occurrence of `S` lies within the scope of some
   `□` or `⊡`", 3777) is `IsPureFuture` (report 02 checked the leaves).

**3.3 What the three invariances say about the manuscript's own claims.**

1. *Recurrence is invisible to L and L⁺* (`clock_invariance` + `clock_no_recurrence`, compiled;
   Saturation of `F × D` on paper, report 03 §3.2). The manuscript motivates task frames by
   recurrence and transposition; its object languages cannot express either. This is not an error
   in the manuscript — it never claims otherwise — but it bears on what a "complete system for
   `⊡`" can be about, and it is the exact sense in which the clock product is a legitimate tool.
2. *Durations are invisible to L⁺* (`repar_invariance`, compiled). This is the general form of
   the drift-frame phenomenon: `cor:no-characterization` holds because L⁺ sees each history only
   up to order-preserving re-timing. Whether `repar_invariance` implies that corollary outright is
   UNVERIFIED (the drift frame's histories are not all re-timings of translations); the mechanism
   is the same.
3. *For L⋆ both invariances must be re-examined.* Re-timing invariance fails (the manuscript's
   3743-3747). Clock-projection invariance plausibly holds, since lifts keep times fixed:
   UNVERIFIED.

### 4. Semantics-native leads

#### 4.1 All-histories semantics = closed bundles (paper)

Let `H ⊆ W^D` be translation-closed and paste-closed with every state occurring, and define
`w ⇒_x v` iff some `ρ ∈ H` has `ρ(0) = w`, `ρ(x) = v` (`x ≥ 0`). Then:

1. `F_H` satisfies Compositionality (compose: translate and paste at the middle time; factor: read
   off the middle state), Seriality, and `⇒₀ = id`.
2. Every *finite* partial history of `F_H` is a restriction of a member of `H` (paste the
   witnesses of consecutive pairs).
3. Hence `H_{F_H} = {τ : every finite restriction of τ is realised in H}` = the closure of `H` in
   `W^D` with the product topology over discrete `W`. Conversely every `H_F` is closed, because
   membership is a condition on pairs of times.
4. Limit is then free by clocking (`clock_limit`, compiled). What is *not* free is the Extension
   property for infinite partial histories: for finite `W` it follows from compactness of `W^D`
   (or from `cor:saturation-finite`); for infinite `W` it is what Saturation buys, and the
   manuscript's `ℚ` example (3074) is a closed path space without it.

Consequences.

- The coarsened/bundle countermodels of reports 01-02 are *dense, non-closed* bundles
  (`evFalse` is dense in all sequences). Incompleteness of the current axioms is: PS and US say
  "paste-closed", MF says "translation-closed", and nothing says "closed".
- `LC_n` and BLC are instances of closedness visible to the language. Whether the visible
  instances are exhausted by `LC_n` is the completeness question, restated.
- **What Saturation contributes as validities** is therefore: nothing at ZTime (report 03 §1.2);
  at the other classes, exactly the difference between closed bundles with and without the
  Extension property at Zeno limits. Whether that difference is visible to L⁺ is OPEN; the Base
  validity proof of BLC (report 02 §2, step 4) uses it.
- **What Limit contributes as validities**: nothing beyond `⇒₀ ⊆ id` (compiled modulo Saturation
  of the product, which is on paper). In particular the Limit obligation disappears from report
  02's dense-countermodel sketch: build any frame with Nullity and clock it.

#### 4.2 The canonical-frame obligation, stated natively (paper)

Take maximal consistent sets `Γ` of a candidate logic. The *state* of `Γ` is its set of state
formulas, equivalently its `⊡`-theory; `W_c` is the set of such states. Durations are invisible
(§3.3), so the engine may choose `D` and the clock freely, as the landed engines already do (their
states are pairs ⟨index, time⟩, manuscript 3823).

- A *perfectly coherent chronicle* is a map `c : D → MCS` whose `U/S` memberships are witnessed
  along `c` exactly. For such `c`, the state trace `st ∘ c` determines `c` (induction on formulas:
  letters and `⊡`-formulas are read off the state, `U/S` off the trace). So "one MCS per
  (history, time)" is automatic; states need not and must not be MCSs — making them MCSs is what
  forces *Determined* and is why the four landed engines give `⊡ = id`.
- Let `𝒞` be a translation-closed family of perfectly coherent chronicles with `⟐`- and
  `□`-witnesses, and `H = {st ∘ c : c ∈ 𝒞}`. The frame read off `H` has `H_F = cl(H)` (4.1).
  **The truth lemma holds iff every `τ ∈ cl(H)` is the state trace of a perfectly coherent
  chronicle.** That is the entire difficulty, at every class, and it is not about trees or
  automata.
- The failure mode is precise: a state containing an inevitability `⊡Fα` together with
  `⊡G(¬α → ⟐(¬α-continuation))` admits, in the closure, a trace that postpones `α` forever. A
  task frame can enforce only conditions on *pairs* of times (that is what 2-determinedness
  means), so inevitabilities must be enforced by a progress measure carried in the state, or
  excluded by the logic. `LC_n` is the axiom that makes the logic agree with the closure; ranks or
  budgets in the state (report 02's `eR` used them negatively) are the constructive device.
- **Frame axioms are not the obstacle at any class** for a finite-colour construction: finitely
  many states with a reflexive-transitive one-step relation give Compositionality, Seriality and
  Nullity over any `D`; clocking gives Limit (compiled) and keeps Saturation (projection to
  `cor:saturation-finite`, paper). Report 03's table confined candidate (i) to ZTime on
  frame-axiom grounds; that restriction is lifted. What remains class-specific is the order type
  seen by `U/S`: over dense time the closure contains traces that switch at densely many times.

#### 4.3 A sound rule that names a world state (compiled)

`NOM_q(ψ) := (⟐ψ → □(q → ⟐ψ)) ∧ (⊡ψ → □(q → ⊡ψ))` and
`nomAnte q Ψ := q ∧ ⋀_{ψ ∈ Ψ} NOM_q(ψ)` for a finite list `Ψ`.

- **`state_name_sound`**: if `nomAnte q Ψ → φ` holds at every point of every model on a frame and
  `q` does not occur in `φ`, then `φ` holds at every point of every model on that frame. Any `D`,
  no frame axiom, `Ψ` arbitrary. Proof: reinterpret `q` as `{τ(t)}` (`nameV`), use
  `stab_state_only` for the clauses and `TD_fresh` to forget `q`. Because it is frame-by-frame, it
  is sound at Base, Dense, ZTime and RTime at once.
- It is the hybrid-logic nominal axiom `E(i ∧ ψ) → A(i → ψ)` weakened to what a *state* name can
  carry: a state fixes the `⊡`-theory, not the history. `□` alone suffices in the consequent
  because `□` already reaches every (history, time) point by translation.
- It is also sound on translation-closed bundles (same proof), so it cannot derive `LC_n`; like
  round 03's clock rule it is an ingredient independent of closure. **Whether any naming rule is
  needed for completeness is OPEN**; in Reynolds' proofs IRR serves the past-sharing structure
  that `⊡` lacks.
- Language-extension form (UNVERIFIED lead): a *state register* — store the present state, test
  "the present state is the stored one" — makes `NOM` an axiom instead of a rule, makes
  recurrence expressible (which §3.3 shows L⁺ cannot), and supplies the nominals whose absence the
  TM⋆ README names as an obstruction. It is closer to the manuscript's primitives than its own
  stored-*world* registers. Cost and conservativity not assessed.

#### 4.4 Round-03 results that survive as native tools

- `tw_invariance` and its general-`D` shadow `clock_invariance`: the frame-morphism notion.
- `omega_limit`, `omega_chain`, `lcN_valid_full`: closure over ℤ.
- `clock_irr_sound`, `irr_sound`: sound, kept as proof devices; superseded in any candidate
  *system* by `state_name_sound` until a need for time-naming is shown.
- `aa_expand`, the oriented-forest argument, the MSO translation: ZTime proof devices only.

### 5. Revised per-class table

| Class | Candidate system | Soundness | Completeness | Engine |
|---|---|---|---|---|
| **ZTime** | TM⁺_Z + `LC_n` + `LCU`; optionally the state-naming rule | `LC_n` compiled in the ℤ mirror; state-naming compiled at every `D`; against `PlusTruthAt` not yet | CONJECTURED; validities decidable (report 03, paper, rests on recalled Rabin) | a closed bundle presented by a countable digraph all of whose bi-infinite walks are traces of coherent chronicles; progress measures in the state; AA/cone and clock devices available |
| **Base** | TM⁺ + `LC_n`; optionally state-naming | `LC_n` paper (Zorn + `extension`); state-naming compiled | OPEN; r.e. status open | closed chronicle bundle (4.2); the Reynolds-2003 blueprint does **not** transfer beyond LC (HN fails) |
| **Dense** | TM⁺_D + `LC_n` + an unknown until-form | as Base; `LCU` invalid (report 03 sketch) | OPEN | finite-colour × clock frames exist (Limit compiled, Saturation paper); closure contains densely switching traces |
| **RTime** | as Dense + PU, SEP | as Dense | OPEN | none; Doets route linear-only |
| **L⋆, any class** | TM⋆ + closure schemata; state register as a possible extension | TM⋆ sound (landed) | OPEN, never stated | none; re-timing invariance fails, so synchrony must be handled |

### Recommendations

1. **Task 560: keep report 02's rescope** —
   `plus_incomplete_base : PlusValid blc ∧ ¬ PlusDerivable FrameClass.Base [] blc`, ZTime as a
   corollary, with report 03's refinement (state the validity half through a general
   maximal-partial-history lemma). Add to its README rows the one-line reading of §4.1: the
   coarsened countermodel is a dense non-closed bundle. When it lands it settles the manuscript's
   commented-out remark at 3832 in the negative; the manuscript's live text is unaffected.
2. **Follow-on task A (lean4, implementable now; revises report 03's task A)**: the clock product
   and its invariance in `FormalSystem`, transcribing probe 04 Part R (`clock_hist_iff`,
   `clock_comp`, `clock_serial`, `clock_limit`, `clock_invariance` port line for line; they use no
   choice) plus Saturation of the product (paper, report 03 §3.2). Deliverable theorems: the four
   frame axioms for `F × D` from Compositionality, Seriality, `⇒₀ ⊆ id` and Saturation of `F`;
   `PlusTruthAt` invariance; corollaries "no L⁺ formula expresses recurrence" and "Limit is idle
   given Nullity". Add `repar_invariance` (Part S) as the general form of the drift-frame lemma.
3. **Follow-on task A′ (lean4, small)**: validity preservation of the state-naming rule against
   `PlusTruthAt`. Its two ingredients are a fresh-letter lemma and `Semantics.stab_state_only`,
   which is already landed for arbitrary histories and times (`PlusTruth.lean:331`). **No
   constructor** is added to `PlusDerivationTree`.
4. **Follow-on task B (research, next round of this task)**: work §4.2 at ZTime without trees.
   Targets: (a) a precise definition of "closed for a finite closure set" and of state-carried
   progress measures; (b) decide whether `LC_n` makes every closure trace of the canonical bundle
   coherent, or locate the first formula shape where it fails; (c) decide whether any naming rule
   is used. Read Reynolds 2001 §9-§15 for the banning mechanism only, and the held
   Emerson-Halpern for fusion/suffix/limit closure; Reynolds 2005, Zanardo 1991 and Di
   Maio-Zanardo 1998 remain unacquired and unused.
5. **Follow-on task C (markdown/docs, small)**: replace manuscript line-number citations in
   `Syntax/PlusLanguage/Axioms.lean` and `PlusTruth.lean` docstrings by label citations; pin
   `def:BLstar-semantics` in `docs/reference/paper-definitions-of-record.md` from lines 3544-3554;
   record that `▷`, `◁`, `⊞` and the world registers are manuscript operators without a
   formalisation.
6. Do not add any constructor to `PlusAxiom` or `PlusDerivationTree` before task B reports.

## Decisions

1. `⊡` is not treated as Ockhamist historical necessity from here on; the Ockhamist modality is
   the manuscript's `▷`. HN and every proof step resting on shared pasts are out.
2. The clock/IRR rule is demoted from candidate-system ingredient to proof device; the
   state-naming rule is the naming ingredient of record, with "is any naming rule needed?" open.
3. The obstruction of record is "every trace in the closure of the canonical bundle must be
   coherent" (§4.2), replacing report 03's "two-sided automaton".
4. Report 03's restriction of finite-colour engines to ZTime on frame-axiom grounds is lifted.
5. Report 03's Decision 5 is softened: a *state register* is recorded as a native language
   extension worth assessing; no extension is recommended yet.
6. No `user_decision` is raised. The one item for the author's attention — the manuscript's
   commented-out remark at 3832 is now false — is reported, not asked.

## Risks & Mitigations

- **Risk**: probe 04's `TD`/`Hist` departs from `PlusTruthAt`/`WorldHistory`. **Mitigation**: the
  clauses are `PlusTruthAt`'s verbatim with `F.Duration := D`; `Hist` quantifies over `x ≤ y`
  only, which under the reflection convention is `respects_task` for all pairs. Tasks A and A′
  re-prove against the repository.
- **Risk**: §4.1 is on paper. **Mitigation**: each step is two lines; the only nontrivial use is
  pasting finitely many witnesses. It is a reformulation, not a premise of any compiled result.
- **Risk**: "Limit adds no validity" leans on Saturation of `F × D`, on paper since report 03.
  **Mitigation**: the argument is that members of a directed family share one clock coordinate and
  project to a directed family in `F`; task A compiles it.
- **Risk**: the verdict "HN fails" is read as a verdict on all of Reynolds 2003. **Mitigation**:
  it is not; `LC_n` transfers and is compiled. Only the past-sharing parts of that *proof* are
  ruled out.
- **Risk**: the manuscript changes (it carries many `% CHECK` and `NEW CHANGE` marks) and line
  numbers drift again. **Mitigation**: every citation above also names a label or a quotable
  phrase.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| group identities in clock coordinates (`c + y = c + x + (y - x)`, `a.2 = a.2 - x + x`) | `abel` | success | after `show` to expose the projections |
| translating strict inequalities by `c` | `lt_sub_iff_add_lt`, `sub_lt_iff_lt_add`, `simpa using` | success | `add_lt_add_right` not needed |
| `(y + c) - (x + c) = y - x` | `rw [add_sub_add_right_eq_sub]` | success | — |
| order-automorphism bookkeeping in `repar_invariance` | `f.lt_iff_lt`, `f.lt_symm_apply`, `f.symm_apply_lt`, `f.apply_symm_apply` | success | `OrderIso` API |
| `e = d` from "`|e - d| < x` for all `x > 0`" | `by_contra`, `abs_pos`, `sub_ne_zero`, `lt_irrefl` | success | — |
| singleton valuation membership | `simpa [nameV] using` | success | after a `have` with the unfolded type |
| three-state frame, case analysis | `rintro` patterns on the two disjuncts, `omega` for the integer side conditions | success | `deriving DecidableEq` on the state type |
| whole file | bare `lean` | success first compile | only `linter.unusedSectionVars` warnings, silenced by option |

## Context Extension Recommendations

- **Topic**: what L⁺ can see. **Gap**: no context note or module doc records that L and L⁺ are
  blind to state recurrence and to durations, that `⊡`-truth is a function of the state at every
  temporal order, or that `⊡` is the manuscript's `⟨τ⟩_x` modality and not its `▷`.
  **Recommendation**: a section in the README of the module task A creates, cross-referenced from
  `Semantics/PlusLanguage/README.md` and from `Metalogic/Independence/README.md` beside the notes
  proposed in reports 01-03.
- **Topic**: manuscript correspondence. **Gap**: `def:BLstar-semantics` unpinned; docstrings cite
  drifting line numbers. **Recommendation**: task C.

## Appendix

- Probe 04 index (`probes/04_semantics-native-general-duration.lean`, namespace `Probe559d`):
  - Truth: `Fm`, `DModel`, `TD`, `and_iff`, `dstab_iff`, `somePast_iff`
  - P: `Hist`, `fullD`, `shiftD`, `hist_shift`, `shift_shift_neg`, `TD_shift`, `stab_state_only`
  - Q: `Fm.fresh`, `TD_fresh`, `conj`, `conj_iff`, `nomClause`, `nomAnte`, `nameV`,
    `state_name_sound`
  - R: `clockP`, `liftC`, `lift_hist`, `clock_hist_iff`, `clock_no_recurrence`, `clock_comp`,
    `clock_serial`, `RrD`, `LimitD`, `clock_limit`, `clock_invariance`
  - S: `reparB`, `repar_invariance`
  - T: `S3`, `R3`, `V3`, `σ3`, `ρ3`, `σ3_hist`, `ρ3_hist`, `R3_comp`, `hnStab`,
    `hn_stab_refuted`, `hn_open`, `stab_imp_open`
- `#print axioms` (scratch copy): `clock_hist_iff`, `clock_limit`, `clock_invariance`: `propext`
  only. `TD_shift`, `stab_state_only`, `state_name_sound`, `repar_invariance`, `hn_stab_refuted`,
  `hn_open`, `R3_comp`: `propext`, `Classical.choice`, `Quot.sound`.
- Compile command: bare `lean` from `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1`, with
  `LEAN_PATH` set to `.lake/packages/*/.lake/build/lib/lean`. Exit 0, no warnings, about 15 s.
- Not compiled anywhere: §4.1; §4.2; Saturation of `F × D`; clock-projection invariance for L⋆;
  the implication from `repar_invariance` to `cor:no-characterization`; soundness of the
  state-naming rule on bundles (same proof, not written).
- Literature locators: `thomason_1984/sec05_4-the-technical-side-of-historical-neces.md` lines
  12-23 (T×W), 66-72 (Kamp frames), 83-105 (AK0-AK13), 170-186 (neutral frames and the
  "history repeating itself" remark), 52-56 (Burgess: T×W validity is r.e. "since it is
  essentially first-order" — an argument that does not transfer, because `H_F` is not a primitive
  of the frame).
