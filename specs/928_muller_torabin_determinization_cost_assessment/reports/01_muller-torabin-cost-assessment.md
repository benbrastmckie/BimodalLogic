# Research Report: Task #928 — costing `Muller.toRabin_exists`, and deciding where it would live

**Task**: 928 - Muller to Rabin determinization cost assessment
**Started**: 2026-11-14T05:59:00Z
**Completed**: 2026-11-14T06:20:00Z
**Effort**: one research dispatch (orchestrated, seq 2)
**Dependencies**: None (prior art: the archived NO-GO reassessment, the Muller-sufficiency report, the completeness-programme report)
**Sources/Inputs**:

*Lean trees, read this session*
- `~/Projects/cslib` (the local CSLib fork), branch `main`, HEAD `3bdf16d9f`, `lean-toolchain` = `leanprover/lean4:v4.33.0-rc1`, Mathlib pinned at `169c26b52a38b704fad2c009372d76844a059bdf`. Files read in full or in part: `Cslib/Computability/Automata/DA/Conversions.lean`, `.../DA/Basic.lean`, `.../DA/Rabin.lean`, `.../DA/Parity.lean`, `.../DA/MullerClosure.lean`, `.../DA/Concat.lean`, `.../DA/BuchiChar.lean`, `Cslib/Computability/Languages/OmegaRegularLanguage.lean`, `Cslib/Foundations/Data/OmegaSequence/InfOcc.lean`
- `/home/benjamin/Projects/BimodalLogic/lakefile.toml`, `lake-manifest.json`, `lean-toolchain` (Lean `v4.33.0-rc1`, Mathlib `79d0395a` = tag `v4.33.0-rc1`)
- Compiled probes: `lean_run_code` against this repository's Mathlib, and `lake env lean` against the fork's build cache on a scratchpad file outside both trees (no `.lean` file written or edited in either tree)

*Literature, held corpus*
- Thomas 1997, *Languages, Automata, and Logic* — §6.1, Theorem 6.5 and Remark 6.6 (`/home/benjamin/Projects/Literature/sources/thomas_1997_languages/`, PDF held)
- Thomas 2003, *Automata and Reactive Systems*, ch. 3 — Safra's construction and Theorem 3.11 (`.../thomas_2003_reactive/Thomas_2003_ch03_deterministic_omega.md`)
- Zielonka 1998, *Infinite Games on Finitely Coloured Graphs* — §4.1, the LAR memory (`.../zielonka_1998/`; marked UNVERIFIED, scan source, OCR degraded)
- Piterman 2007, *From Nondeterministic Büchi and Streett Automata to Deterministic Parity Automata* — §3 and its footnote 3 on the index appearance record (`.../piterman_2007/`)

*Project record*
- `specs/archive/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md`
- `specs/archive/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md`
- `specs/archive/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` (row 16)
- `specs/ROADMAP.md` (the `require` ruling and the §§7–15 formalization ruling)

**Artifacts**:
- `specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md` (this report)

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The construction wanted is neither Safra's nor Piterman's.** Both are *determinization* constructions, taking a **nondeterministic** Büchi (or Streett) automaton to a deterministic one. `Muller.toRabin_exists` takes a **deterministic** Muller automaton as input: there is no nondeterminism left to remove. The construction of record is the **appearance-record** one — Büchi's "order-vector with hit", equivalently the Gurevich–Harrington *later appearance record* — given in full at Thomas 1997 §6.1, Theorem 6.5, with its key invariant at Remark 6.6. This corrects 879 row 16, which records the held construction as "Safra/Piterman".
- **The choice matters specifically for the pair-indexed consumer.** The LAR route's Rabin pairs are indexed by *hit position*, i.e. by a recency order on states — which is literally what Reynolds' clause K4B orders banned entries by ("the order of `V_p`s ceasing to appear"). Safra's pairs are indexed by Safra-tree **node names** with a "!" marking (Thomas 2003, Theorem 3.11), an index set carrying no recency order at all. For the automaton alone the two are interchangeable; for the ban/lull mechanism they are not.
- **Order-of-magnitude cost: ~1,000 lines (range 800–1,200) in one new file in the fork**, on a basis of measured in-tree comparables — `DA/Concat.lean` is 762 lines for the structurally nearest construction (enlarged state space, run-tracking invariant, `infOcc` transfer, one language-equality theorem), and the LAR's core invariant is strictly harder than concat's slot tracking. The landed same-state-space conversions (`Rabin.lean` 235, `Parity.lean` 193) are the wrong anchor and would understate it by roughly 5×.
- **The cost estimate on record understates the job.** The fork's own docstring (`DA/Conversions.lean:96-111`) proposes "enumerate all accepting sets as Rabin pairs" on the **same state space**, `2^|Q|` pairs. That construction is not merely incomplete but unsound, and the state space must grow to `|Q|! × |Q|`.
- **Siting: the fork, and no `require` is entailed.** `Muller.toRabin_exists` is `proof_wanted` at `~/Projects/cslib/Cslib/Computability/Automata/DA/Conversions.lean:112`; the fork is the only tree where the statement typechecks today. Siting it in this repository instead would first require porting ~956 lines of already-proved CSLib code (measured). Proving it in the fork changes nothing in this repository's `lakefile.toml` or `lake-manifest.json` and does not make the `require` question live — that question becomes live only when this repository's *Lean code* consumes the lemma, which (O4) says is not now.
- **(O1) and (O3) are independent, and (O1) alone unblocks the completeness line.** (O3) is not introduced by `toRabin_exists`: it is introduced by `IsRegular` itself (`OmegaRegularLanguage.lean:39`, an `∃ (State : Type) …`) and inherited by the already-landed `iff_da_muller` (`:440`). Proving `toRabin_exists` in the natural existential form therefore leaves (O3) exactly where it stands. For a `Prop`-valued completeness statement classical extraction suffices, so discharging (O1) alone is enough; (O3) binds only the decidability front, and discharging it means restating landed upstream code, not this lemma.
- **Guardrail (f) fires, partially and precisely.** The corpus holds the construction at full rigour (state set, initial state, transition relation, acceptance chain) but **not** the proof of its key invariant: Thomas states Remark 6.6 with "one verifies the following claim". The single hardest Lean obligation is exactly the step the corpus leaves unproved.

## Context & Scope

The dispatch asks for an assessment, in four parts, of the single `proof_wanted` that the archived record names as load-bearing for the L⁺ ZTime completeness line: which construction is actually wanted, what a Lean proof would cost on this project's toolchain, where it should live, and whether discharging it is enough on its own.

Constraints observed: no proof of `Muller.toRabin_exists` was attempted; no `.lean` file was written or edited in either tree (the compiled probes below ran on a scratchpad file outside both repositories, via `lake env lean` and `lean_run_code`); no edit to `lakefile.toml` or `lake-manifest.json`, and no `require` was added in any form; no part of the Reynolds engine's §§7–15 was formalized; no completeness claim is made here.

Settled inputs, taken as given and not re-litigated: `Rabin.toParity_exists` is off the critical path; (O2) is discharged for free under the union-on-the-Muller-side-then-determinize-once ordering; the ban/lull mechanism's banned list is pair-indexed and a Muller family does not present as a pair family without a walk-dependent choice.

Blocked tools (`lean_diagnostic_messages`, `lean_file_outline`) were not called.

## Findings

### Finding 1 — The construction of record: appearance records, not Safra and not Piterman

**1.1 The lemma is not a determinization at all.** `Muller.toRabin_exists` (`DA/Conversions.lean:112-115`, read) is

```
proof_wanted Muller.toRabin_exists
    {State Symbol : Type*} [Fintype State] [DecidableEq State]
    (a : Muller State Symbol) :
    ∃ (S : Type) (_ : Finite S) (da : DA.Rabin S Symbol), language da = language a
```

Its input `a : Muller State Symbol` is a `DA` — `structure Muller … extends DA State Symbol` (`DA/Basic.lean:106`, read), and `DA` extends `FLTS` with a total transition function, `run' da xs (n+1) = δ (run' da xs n) (xs n)` (`DA/Basic.lean:47-53`, read). The automaton is already deterministic. **Safra 1988 and Piterman 2006/2007 both solve a different problem**: nondeterministic Büchi (Piterman: also Streett) to a deterministic Rabin or parity automaton. Thomas 2003 states Safra's result as "A Büchi automaton with n states is transformed by the Safra construction into a deterministic Rabin automaton" (Theorem 3.11, held, read). There is no nondeterminism in `a` for either construction to remove. **879 row 16's parenthetical "held: Safra/Piterman in corpus" is therefore a misattribution** as to this lemma; it is accurate only about the *composite* NBA→DRA step, which this lemma is not.

**1.2 What is held, and at what rigour.** Thomas 1997 §6.1 gives the construction in full:

> **Theorem 6.5** For any Muller tree automaton one can construct an equivalent Rabin chain tree automaton.

with the data structure named explicitly — "This data structure was introduced by Büchi [Bü83] under the name 'order-vector with hit'. The idea is to keep a record of the states in the order of their 'last visits' (as in the 'later appearance record' LAR of Gurevich-Harrington [GH82]), together with a pointer to the position where the last change in this record occurred (the 'hit position')" — and the three construction components given concretely: state set (order-vectors over `Q = {1,…,n}` with hit position), initial state (`(2…n 1)`), transitions (shift the new state to the right, hit = its old position), and the acceptance chain `E₁ ⊆ F₁ ⊆ … ⊆ Eₙ ⊆ Fₙ` with

> `Eᵢ` is the set of order-vectors with hit `< i` or of order-vectors with hit `i` such that the entries from position `i` onwards do not form a set in `F`; … `Fᵢ` is the union of `Eᵢ` with the set of all order-vectors with hit `i` such that the entries from position `i` onwards do form a set in `F`.

The pivot is Remark 6.6: `In(j₀j₁j₂…) = F` with `|F| = k` iff the order-vector sequence satisfies (1) only finitely often the hit is `< (n−k)+1`, and (2) infinitely often the hit is `(n−k)+1` with the entries at positions `(n−k)+1 … n` forming exactly `F`.

**Rigour gap, named (guardrail (f)).** Thomas introduces Remark 6.6 with "In general, one verifies the following claim" and gives **no proof of it**. The construction is held; its correctness invariant is held only as a statement. Zielonka 1998 §4.1 defines the LAR as a transition system but in a *game-memory* setting and with badly degraded OCR (the corpus entry is marked UNVERIFIED, scan source); it does not supply the automaton-level invariant either. Piterman 2007 mentions the *index* appearance record only in a footnote, and for Rabin/Streett→parity, not Muller→Rabin. **Nothing in the corpus proves Remark 6.6.** That is precisely the obligation that dominates the Lean cost in Finding 2.

**1.3 Theorem 6.5 is stated for tree automata; the part that matters is word-level.** The construction and Remark 6.6 both speak only of a *state sequence* `j₀j₁j₂…` along a path and its `In(·)`. Nothing in either is tree-specific. For CSLib's `DA.Muller`/`DA.Rabin` the path is the unique run `a.run xs`, and `In(·)` is `(a.run xs).infOcc`. Transposing it is a restriction, not a generalization.

**1.4 Why the choice matters for the pair-indexed consumer rather than for the automaton alone.** Three routes reach a DRA for an ω-regular language:

| Route | Steps | Landed today | Pairs are indexed by |
|---|---|---|---|
| **A (LAR)** | `iff_da_muller` (landed, proved) + Muller→Rabin via appearance record | half | **hit position** `i ∈ {1,…,n}`, a recency order |
| B (Safra) | NBA → DRA directly | nothing | Safra-tree **node names** with a "!" marking |
| C (Piterman) | NBA → DPA directly, then `Parity.toRabin_language_eq` (landed, proved) | half | parity colours, via the landed conversion |

For the *automaton* the three are interchangeable — all deliver a DRA for the same language. For the *consumer* they are not. The ban/lull mechanism's banned list and its ordering clause were **re-read first-hand this session** against Reynolds 2001 (previously carried from 903; the three sub-claims are now individually grounded):

| Sub-claim | Verdict | First-hand citation |
|---|---|---|
| (i) the banned list has the shape `bl : T → (C × {1,…,K})*` | **CONFIRMED** (shape); the Kleene-star glyph itself is OCR-garbled | `reynolds_2001/sec10_…md:56-58` (§12, chronicle definition) renders the signature as `bl : T -* (<0(C x{1,...,K}))`, the sequence operator mangled by the scan; `sec09_…md:239` (§11) pins the reading in prose — "`[(c1, p1), . . ., (c_m, p_m)]` is a finite sequence from `C x {1, . . ., K}`" |
| (ii) `K` is the number of accepting pairs | **CONFIRMED**, verbatim | `sec10_…md:57-58`: "(where K, recall, is the number of accepting pairs of A)" |
| (iii) K4B orders entries by recency of last appearance | **CONFIRMED**, verbatim, with one wording correction | `sec10_…md:79-83` (§12), clause K4B: "If `(d, q)` precedes `(c, p)` in `bl(x)` then: 1) the most recent appearance of `Vq` (if any) below `x` is below (or equal to) the most recent appearance of `Vp`; and 2) if there is no appearance of `Vp` before `x` then there is no appearance of `Vq` before `x`." Corroborated at `sec11_…md:264` (§14, used in the limit argument) and `sec10_…md:342-344` (§13): "The order of listing these new banned pairs … is determined by which `Vp` came up least recently in the past: the least recent ones go into the list first." |

One **wording correction** falls out of the re-read: the phrase "the order of `V_p`s ceasing to appear", carried into this report as if it were K4B's own text, is not K4B — it is §11's *motivating* remark at `sec09_…md:228-230` ("The actual order of listing of pairs (as specified in a clause K4B below) is not exactly the order of being put in the list. It turns out to be easier to reason with an equally effective order based on the order of `Vps` ceasing to appear"). K4B itself (quoted above) states the same order from the other direction, by *most recent appearance*. The two are the same order read forwards and backwards, so the finding's substance is unaffected — but the quotation is now attributed to its actual clause. §13 additionally states the ordering's *purpose* as reflecting "a conditionality on the banning" (`sec10_…md:346`), which is why the order is load-bearing for the mechanism rather than cosmetic: an unbanning removes all later-listed pairs, so the index order controls what survives. Route A's pair index *is* a recency order on states: pair `i` fires exactly when the hit settles at position `i`, i.e. when the last `n−i+1` states are the ones still recurring. Route B's index set is a set of Safra-tree node names (read, Thomas 2003: `Eₖ` = trees without node `k`, `Fₖ` = trees with node `k` marked "!"); the "!" marking records a breakpoint event, not a last-appearance order, and node names carry no canonical order relative to which K4B's clause could be read. Route A therefore hands the ban mechanism a pair family whose index order is already the order K4B needs; routes B and C do not.

Routes B and C additionally **discard landed work**: both bypass `IsRegular.iff_da_muller` (`OmegaRegularLanguage.lean:440`, proved via the Choueka decomposition — read), which is the single largest already-paid item on the automaton side. And both have correctness proofs at least as hard as the LAR's: Safra's requires the full tree-surgery invariant; Piterman's is an optimization of Safra's.

### Finding 2 — Size and shape of a Lean proof on this project's toolchain

**2.1 The statement to aim at is stronger than the `proof_wanted`, and costs nothing extra.** Rather than proving the existential directly, state the construction as data, in the same shape as the landed conversions (`Parity.toRabin` + `Parity.toRabin_language_eq`, `DA/Parity.lean:99,134`, read):

```
def Muller.toRabinLAR (a : Muller State Symbol) :
    Rabin ((Fin (Fintype.card State) ≃ State) × Fin (Fintype.card State)) Symbol
theorem Muller.toRabinLAR_language_eq (a : Muller State Symbol) :
    language a.toRabinLAR = language a
```

and derive the existential. **Measured** (probe B, `lake env lean` against the fork, exit 0): the derivation is a single term, `⟨_, inferInstance, toRabinLAR a, h a⟩`.

**2.2 Carrier.** Two encodings were probed.

| Encoding | `Fintype`/`Finite` instance | Measured result |
|---|---|---|
| `(Fin \|Q\| ≃ Q) × Fin \|Q\|` | `inferInstance` | **fails** in CSLib's current import closure; **succeeds** after adding `public import Mathlib.Data.Fintype.Perm` (probe A, exit 0). The needed instance is `Equiv.instFintype`, located in `Mathlib.Data.Fintype.Perm` (measured via `#eval` over the environment in this repository's Mathlib). |
| `{l : List Q // l.Nodup ∧ ∀ q, q ∈ l}` | hand-rolled | No instance; requires a length-is-card lemma plus a pointwise-`getD` injection. Probe attempted and **not completed** within this dispatch. |

The `Equiv` encoding is the right one: finiteness is free, `Fin.cycleRange : Fin n → Equiv.Perm (Fin n)` exists in this Mathlib (checked, `#check` succeeded) and is the natural shape for the shift, and no `Inhabited` side condition is needed. The cost is one new Mathlib import in a library that minimizes them.

**2.3 Acceptance target: go to Rabin directly, not via parity.** Thomas's `E₁ ⊆ F₁ ⊆ … ` chain is already a Rabin condition in CSLib's exact shape (`Rabin.Accepts` is `∃ pair ∈ pairs, infOcc ∩ pair.1 = ∅ ∧ (infOcc ∩ pair.2).Nonempty`, `DA/Rabin.lean:67-72`, read). **Measured** (probe C, exit 0): the chain-indexed pairs elaborate as a plain `Set` comprehension

```
{ p | ∃ i : Fin (Fintype.card State),
    p = ({ v | v.2 < i ∨ (v.2 = i ∧ suffixSet v ∉ a.accept) },
         { v | v.2 < i ∨ (v.2 = i ∧ suffixSet v ∈ a.accept) }) }
```

with **no** `Decidable (· ∈ a.accept)` instance and **no** `color : State → ℕ` function. Routing through `Parity` instead would need `color` — a *function*, hence a decidable membership test on `a.accept : Set (Set State)` — and then the landed `Parity.toRabin_language_eq`. Direct-to-Rabin is both cheaper and (see Finding 4) strictly friendlier to (O3).

**2.4 What the induction is on.** Not a structural induction. The proof is a two-sided `Filter.atTop` stabilization argument:

- **(→)** Let `F = (a.run xs).infOcc`, `k = |F|`, `n = |Q|`. Eventually only `F`-states are visited; after that point each visit moves an `F`-state to the right end, so after every member of `F` has been visited once more, the last `k` positions of the order vector are exactly `F` **forever**, and the non-`F` states occupy a frozen prefix of length `n−k`. Hence the hit is eventually `≥ n−k+1` (Remark 6.6(1)). Every member of `F` recurs, so the member sitting at position `n−k+1` is visited again, which puts the hit exactly at `n−k+1` — infinitely often (Remark 6.6(2)).
- **(←)** Uniqueness: `infOcc` is determined by the run, and the conditions in Remark 6.6 pin `k` and then `F`, so the converse follows from (→) applied to the actual `infOcc`.

The induction that does appear is an induction on `n − k` (how far the frozen prefix extends) inside the stabilization step, and a `Nat`-indexed "visit all of `F` once more" argument built from `Set.Finite.eventually_all`.

**2.5 What it can stand on.** All measured present in this repository's Mathlib (`lean_run_code`, all `#check`s succeeded) and reachable from the fork's import closure:

- Mathlib: `List.Nodup`, `List.Nodup.erase`, `List.idxOf`, `List.mem_erase_of_ne`, `List.length_erase`, `List.Perm`, `List.perm_cons_erase`, `Nodup.not_mem_erase`, `Fin.cycleRange`, `Fin.cycleRange_of_gt`, `Fin.cycleRange_of_le`, `Equiv.instFintype` (needs the new import), `Set.Finite.eventually_all`, `Filter.extraction_of_frequently_atTop`, `Nat.frequently_atTop_iff_infinite`
- CSLib, landed and proved: `ωSequence.infOcc` and its toolkit — `mem_infOcc`, `infOcc_finite`, `infOcc_nonempty`, `frequently_in_finite_type`, `frequently_iff_strictMono`, `strictMono_of_infinite` (`Foundations/Data/OmegaSequence/InfOcc.lean`, 112 lines, read in full); `DA.run`/`run_zero`/`run_succ` (`DA/Basic.lean:53-64`); `Parity.toRabin_language_eq` (not needed on the direct-to-Rabin route); `Muller.exists_iSup` (`DA/MullerClosure.lean:125`) for the downstream fold

**2.6 What it would have to build.** The entire LAR layer: carrier, step, hit, the frozen-prefix invariant, Remark 6.6 in both directions, the pair family, and the acceptance transfer. One near-miss exists and is **private**: `eventually_mem_infOcc` (`DA/Concat.lean:643-654`, read) — "in a finite-state run, the current state is eventually always one that occurs infinitely often" — is exactly the first step of the (→) direction, measured at 12 lines of proof. It would need to be promoted out of `Concat.lean` or re-proved.

**2.7 Order-of-magnitude line count, with its basis.** Measured in-tree comparables (`wc -l`, `~/Projects/cslib`, this session):

| File | Lines | What it buys |
|---|---|---|
| `DA/Concat.lean` | **762** | **nearest structural analogue**: new enlarged state space, run-tracking invariant, `infOcc` transfer lemmas, one language-equality theorem |
| `DA/Choueka.lean` | 472 | one characterization theorem with run-surgery/pumping |
| `DA/BuchiClosure.lean` | 455 | closure lattice |
| `DA/Rabin.lean` | 235 | **four** same-state-space conversions with language equalities (~55 lines each, docs included) |
| `DA/Parity.lean` | 193 | **one** same-state-space conversion (def + helper + `language_eq`, ≈95 lines with docs) |
| `DA/MullerClosure.lean` | 155 | product `infOcc` transfer (2 lemmas ≈ 40 lines) + union + `exists_iSup` |
| `Foundations/…/InfOcc.lean` | 112 | the whole `infOcc` toolkit |

Decomposition, each item anchored to one of those:

| Item | Lines | Anchor |
|---|---|---|
| Carrier + `Fintype` + step/hit API | 60–100 | carrier free (probe A); API comparable to one `Rabin.lean` conversion (~55), more combinatorial |
| LAR run ↔ source run tracking | 40–80 | `Concat.lean`'s `hpersist`-style tracking lemmas, ~60 lines each (measured) |
| **Remark 6.6, both halves** | **250–450** | no in-tree analogue; `Concat.lean`'s comparable stabilization block (`eventually_mem_infOcc` + `concat_slot_infOcc_eq` + persistence) measures ~120 lines for a strictly easier invariant |
| Converse / uniqueness | 60–120 | — |
| Pair family + acceptance transfer + `language_eq` | 100–160 | `Parity.toRabin_language_eq` ≈60 lines of proof for a much simpler translation |
| Existential derivation | ~10 | **measured**: one term, compiles (probe B) |
| CSLib-style module docs | 80–120 | `Conversions.lean` 117 lines of which ~60 are docs; `Parity.lean` 193 of which ~90 |

Sum before slippage: 600–1,040, with the dominant uncertainty in Remark 6.6.

> **Estimate: ~1,000 lines, range 800–1,200, in one new file.** Same order as `Concat.lean` (762, measured) and larger; roughly 5× the landed same-state-space conversions, which are the wrong anchor. In orchestrated terms, 4–7 implementation phases.

**2.8 The estimate on record is wrong in kind, not only in size.** `DA/Conversions.lean:96-111` (read) proposes the DRA "with state space `State` and Rabin pairs `{(State \ F, F) | F ∈ a.accept}`", `2^|Q|` pairs, calling the conversion "straightforward … but requires state-space type-lifting for a clean formalization". Its own docstring already hedges ("the avoidance set `State \ F` may not enforce the exact `infOcc = F` condition"). The archived Muller-sufficiency report's two-state example (`Q = {a,b}`, `𝓕 = {{a,b}}`) shows the proposal is *unsound*, and that no Rabin condition on a fixed `{a,b}` has that accepted-`infOcc` family at all. So: the state space must grow to `|Q|! × |Q|`, not stay at `|Q|`; and the work is a stabilization proof, not pair enumeration. The docstring would need rewriting as part of landing the lemma.

**2.9 Automation outlook.** The fork's own `infOcc` proofs use explicit `frequently_atTop` / `filter_upwards` / `Set.Finite.eventually_all` reasoning, with `grind` used only for arithmetic and finishing (read, `InfOcc.lean`, `Concat.lean`). `omega`, `decide` and `simp` do not reach `Filter.atTop` stabilization goals. No tactic shortcut should be budgeted for item 3 of the table above.

### Finding 3 — Siting: the fork, and no `require` is entailed

**3.1 Where the declarations actually are** (all read this session, fork at `3bdf16d9f`):

| Declaration | File:line | Status |
|---|---|---|
| `Muller.toRabin_exists` | `Cslib/Computability/Automata/DA/Conversions.lean:112` | `proof_wanted` |
| `Rabin.toParity_exists` | `Cslib/Computability/Automata/DA/Conversions.lean:89` | `proof_wanted` (off the critical path) |
| `IsRegular.iff_da_muller` | `Cslib/Computability/Languages/OmegaRegularLanguage.lean:440` | proved |
| `IsRegular.to_da_muller` | `Cslib/Computability/Languages/OmegaRegularLanguage.lean:409` | proved |
| `Parity.toRabin_language_eq` | `Cslib/Computability/Automata/DA/Parity.lean:134` | proved |
| `Muller.exists_iSup` | `Cslib/Computability/Automata/DA/MullerClosure.lean:125` | proved |

**3.2 The fork is the only tree where the statement typechecks today.** `DA.Muller` and `DA.Rabin` exist in neither Mathlib nor this repository. The minimal import closure needed to *state* the lemma here, measured by `wc -l` on the fork:

`Acceptors/Acceptor.lean` 39 + `Acceptors/OmegaAcceptor.lean` 38 + `Foundations/Semantics/FLTS/Basic.lean` 58 + `Foundations/Data/OmegaSequence/Defs.lean` 96 + `Foundations/Data/OmegaSequence/InfOcc.lean` 112 + `Foundations/Data/Nat/Segment.lean` 255 + `Automata/DA/Basic.lean` 123 + `Automata/DA/Rabin.lean` 235 = **956 lines**, plus `Cslib.Init`.

Siting in `FormalSystem/ForMathlib/` would therefore mean duplicating ~956 lines of already-proved third-party code before writing a line of the actual proof, and would fork the maintenance of that code. `ForMathlib/`'s stated remit (CLAUDE.md: "Mathlib-shaped extensions intended for upstreaming") does not fit either: the lemma is CSLib-shaped, not Mathlib-shaped.

**3.3 What siting in the fork WOULD commit this repository to.** Nothing in its build. Concretely:

- `lakefile.toml` has exactly one `[[require]]`, `mathlib` at `rev = "v4.33.0-rc1"` (read). `lake-manifest.json` lists `mathlib, plausible, LeanSearchClient, importGraph, proofwidgets, aesop, Qq, batteries, Cli` — **no cslib** (measured). Proving a lemma in a different repository changes neither file.
- The commitment is **maintenance of a fork**, which already exists and is already being maintained: the fork is at Lean `v4.33.0-rc1` with Mathlib `169c26b5`, while this repository is at Lean `v4.33.0-rc1` with Mathlib `79d0395a` (both measured). Same toolchain, **different Mathlib revisions** — a reconciliation that any future `require` would have to perform, and that proving the lemma neither creates nor worsens.
- CSLib's own gates: the module system (`module` / `public import` / `@[expose] public section`), Mathlib's standard linter set, docstring requirements. One specific, pleasant consequence: `Conversions.lean:59` currently carries `set_option linter.privateModule false` with the comment that the module "consists exclusively of `proof_wanted` statements, which are elaborated and discarded"; landing a real declaration there removes the need for that opt-out.
- One new Mathlib import (`Mathlib.Data.Fintype.Perm`) in a library that keeps its Mathlib surface small — a small upstream-acceptability consideration, not a blocker.

**3.4 What it would NOT commit this repository to.** No `require`; no change to `lakefile.toml` or `lake-manifest.json`; no dependency of `FormalSystem` on CSLib; no upstream PR (that is a separate, user-only action under `pr-prohibition.md`); and no re-opening of the ruling that the `require` question is not to be re-opened on §§7–15's account.

**3.5 Is a `require` decision entailed by proving it there? No.** A `require` becomes necessary only when this repository's *Lean code* consumes the lemma. It cannot, today: (O4) stands — the ω-regularity of the violation language is not stated anywhere in-tree, and items 17–21 of 879's table plus P1–P8 are all upstream of the automaton. The standing recommendation "do not `require` anything now" is untouched by proving the lemma, and is in fact reinforced: a proved lemma sitting in the fork is strictly better evidence for a *later* `require` decision than an unproved one, and costs nothing while the decision waits.

### Finding 4 — (O3) interaction: independent of (O1), and inherited from further upstream

**4.1 (O3) does not originate at `toRabin_exists`.** It originates at the definition of ω-regularity itself (`OmegaRegularLanguage.lean:39`, read):

```
def IsRegular (p : ωLanguage Symbol) :=
  ∃ (State : Type) (_ : Finite State) (na : NA.Buchi State Symbol), language na = p
```

and is inherited by `IsRegular.to_da_muller` (`:409-424`, read), whose proof `obtain`s its components out of existentials and rebuilds a new existential. `iff_da_muller` (`:440`) is therefore already in existential-over-`Type` form, and it is **landed and proved** in that form.

**4.2 Consequence for the question asked.** A proof of `Muller.toRabin_exists` in its natural existential form **leaves (O3) exactly where it stands** — it neither introduces nor removes it. Even the stronger explicit-data form recommended in Finding 2.1 removes (O3) only *from this step*: the DMA feeding it still arrives as `∃ (State : Type) …`, so `θ_f` still cannot name the transition table without classical extraction.

**4.3 Therefore (O1) and (O3) need not be discharged together — for the completeness line.** Classical extraction of a `Fin n` indexing from `Finite State` is sound and lives inside a `Prop`, so for a `Prop`-valued completeness statement the automaton side is unblocked by (O1) alone. (O3) binds the **decidability** front, which needs a computable `θ_f`. The two fronts can be separated.

**4.4 And (O3) is not discharged by changing this lemma.** Discharging it means restating `IsRegular` and `iff_da_muller` in explicit-data form (a bundled `Σ`-type or structure carrying a `Fin n`-indexed automaton) — a change to landed, proved upstream code in a different file, strictly larger than (O1) and with its own ripple through the closure lattice. It is a separate obligation, not a rider on this one.

**4.5 One measured point where the choice in Finding 2.3 helps.** Targeting Rabin directly keeps the pairs a `Set` comprehension needing no `Decidable (· ∈ a.accept)` (probe C, exit 0). Targeting Parity would force `color : S → ℕ`, a *function*, hence a decidability requirement on `a.accept : Set (Set State)` — i.e. it would add a second, independent source of non-computability on top of the one (O3) already names. Direct-to-Rabin is the (O3)-friendlier target as well as the cheaper one.

### Recommendations

1. **Record the construction of record as the appearance-record route (Thomas 1997 §6.1 Theorem 6.5 + Remark 6.6), and correct 879 row 16's "Safra/Piterman" attribution.** Safra and Piterman solve the nondeterministic problem; this lemma's input is deterministic. — [VERIFIED: PASS — `DA/Basic.lean:37-53,106` read, confirming `Muller extends DA` with a total transition function; Thomas 2003 Theorem 3.11 read, confirming Safra's input is a Büchi (nondeterministic) automaton]
2. **If and when the lemma is attempted, state it as data (`Muller.toRabinLAR` + `_language_eq`) and derive the existential, targeting Rabin directly rather than via Parity.** — [VERIFIED: PASS — `lake env lean` probe B against the fork, exit 0: the derivation `⟨_, inferInstance, toRabinLAR a, h a⟩` typechecks; probe C, exit 0: the chain-indexed pairs elaborate with no `Decidable` instance]
3. **Use the `(Fin |Q| ≃ Q) × Fin |Q|` carrier and add `public import Mathlib.Data.Fintype.Perm`.** — [VERIFIED: FAIL then PASS — probe A against the fork **failed** (`failed to synthesize instance … Fintype ((Fin (Fintype.card State) ≃ State) × Fin (Fintype.card State))`) under CSLib's current import closure, and under the closure plus `Mathlib.Logic.Equiv.Fintype`; the instance `Equiv.instFintype` was then located in `Mathlib.Data.Fintype.Perm` by an environment `#eval` in this repository's Mathlib, and probe A re-run with that import **passed**, exit 0. Recommendation revised accordingly: the carrier is correct, but it is not free — it costs one new Mathlib import in a library that minimizes them.]
4. **Budget ~1,000 lines (800–1,200), one new file in the fork, 4–7 implementation phases; do not anchor on the landed same-state-space conversions.** — [VERIFIED: PASS — `wc -l` over `~/Projects/cslib/Cslib/Computability/Automata/DA/` and `Foundations/Data/OmegaSequence/` this session: `Concat.lean` 762, `Choueka.lean` 472, `BuchiClosure.lean` 455, `Rabin.lean` 235, `Parity.lean` 193, `MullerClosure.lean` 155, `InfOcc.lean` 112]
5. **Site it in the fork. Do not file a port of CSLib's ω-automata stack into this tree.** — [VERIFIED: PASS — minimal statement closure measured at 956 lines across 8 files; this repository's `lake-manifest.json` measured to contain no `cslib` entry]
6. **Do not open the `require` question on this lemma's account.** Proving it in the fork entails no `require`; the question becomes live only when this repository's Lean code consumes it, which (O4) places well downstream. — [No compiled gate applicable]
7. **Treat (O1) and (O3) as separable.** Discharging (O1) unblocks the automaton side of the `Prop`-valued completeness line on its own; (O3) binds the decidability front and is discharged by restating `IsRegular`/`iff_da_muller`, not by changing this lemma. — [VERIFIED: PASS — `OmegaRegularLanguage.lean:39` and `:409-424` read, confirming `IsRegular` is itself existential-over-`Type` and that `to_da_muller` destructs and rebuilds existentials]
8. **Before any attempt, budget the reconstruction of Remark 6.6's proof as original work.** The corpus states it and does not prove it. — [No compiled gate applicable]

## Decisions

- **The construction of record is the appearance-record (LAR / "order-vector with hit") route**, not Safra's and not Piterman's. Decided on the ground that the lemma's input is already deterministic (read) and that the corpus holds exactly this construction for exactly this conversion (Thomas 1997 Theorem 6.5, read).
- **The target acceptance type is Rabin directly, not Rabin-via-Parity.** Decided on two measured grounds: the Rabin-chain pairs need no decidability instance (probe C), and the parity route would add a second non-computability source on top of (O3).
- **The estimate is pitched as an order of magnitude with an explicit in-tree anchor** (`Concat.lean` at 762 lines) rather than as a point figure. The dominant uncertainty is named and localized: Remark 6.6's two halves, 250–450 of the 800–1,200.
- **Siting is decided for the fork**, on the measured 956-line port cost and on the fact that the statement does not typecheck in this tree at all.
- **No `require` is proposed, assessed as necessary, or acted on.** Finding 3 assesses the question and leaves the standing ruling in force.
- **879 row 16's "held: Safra/Piterman in corpus" is recorded as a misattribution as to this lemma**, and as accurate only about the composite NBA→DRA step.
- **Guardrail (f) is answered as a partial fire**: the construction is held at the rigour needed to cost it; its invariant's *proof* is not held, and that gap is named rather than papered over with a from-memory reconstruction.

## Risks & Mitigations

- **Risk: the 800–1,200 estimate's dominant term is the one item with no in-tree comparable.** Remark 6.6's stabilization proof could run well past 450 lines; Lean proofs over `Filter.atTop` with a frozen-prefix invariant are notorious for this. *Mitigation*: the estimate is stated as an order of magnitude, its decomposition is published so the overrun would be localized rather than diffuse, and the nearest measured analogue (`Concat.lean`'s ~120-line stabilization block for a strictly easier invariant) is named so a future attempt can calibrate against a real number rather than this one.
- **Risk: Thomas 1997's Theorem 6.5 is stated for tree automata.** If the word-case transposition hides a subtlety, the construction would need re-derivation. *Mitigation*: Remark 6.6 and the construction both quantify only over a state sequence `j₀j₁j₂…` and its `In(·)` (read); nothing in either mentions branching. The transposition restricts rather than generalizes. Residual risk judged low but not zero, and the PDF is held for a page-image check before any attempt.
- **~~Risk: the Reynolds §11/§12 quotations grounding Finding 1.4 are carried, not re-read.~~ RETIRED.** All three sub-claims were re-read first-hand against the held Reynolds 2001 chunks and are now cited by chunk file and line in Finding 1.4's sub-claim table: the `bl` signature's shape (§12, `sec10_…md:56-58`, corroborated in prose at `sec09_…md:239`), `K` as the number of accepting pairs (§12, `sec10_…md:57-58`, verbatim), and K4B's recency ordering (§12, `sec10_…md:79-83`, verbatim). No `CARRIED-UNVERIFIED` marker remains on this finding. **Residual, narrower risk**: the chunks are scan-derived OCR, and the Kleene-star/finite-sequence operator in the `bl` signature is garbled in every occurrence (`<0`, `` `0 ``, `<'` across `sec10_…md:56`, `:183`, `:189` and `sec11_…md:16`). The operator's *reading* is fixed by §11's prose gloss ("a finite sequence from `C x {1,...,K}`"), not by the glyph, so the shape stands; a page-image check of §12's definition would retire even the glyph-level doubt and was not performed. One carried *wording* error was found and corrected: "the order of `V_p`s ceasing to appear" is §11's motivating remark, not K4B's own text.
- **Risk: the fork and this repository sit on different Mathlib revisions** (`169c26b5` vs `79d0395a`, both measured). A lemma proved in the fork is not automatically available under this repository's pin. *Mitigation*: this is a pre-existing condition of the fork, not created by the lemma, and it binds only at `require` time — which Finding 3.5 places well downstream. Both trees are on the same Lean toolchain (`v4.33.0-rc1`, measured), so the reconciliation is a Mathlib-rev bump, not a toolchain migration.
- **Risk: the compiled probes validate shapes, not proofs.** Probes A–C establish that the carrier is finite, that the existential follows from the data form, and that the pairs elaborate — they establish nothing about Remark 6.6. *Mitigation*: stated plainly here and in the probe table; no probe result is presented as evidence about the hard item.

## Tactic Survey Results

No proof goal was attacked (guardrail (a): no proof of `Muller.toRabin_exists` was attempted), so the tactic-portfolio survey does not apply in its usual form. What was run instead were elaboration probes, recorded here on the same footing:

| Goal | Probe | Result | Config |
|---|---|---|---|
| Mathlib API for an order-vector encoding exists on this toolchain | `lean_run_code`, 14 `#check`s (`List.Nodup.erase`, `List.idxOf`, `List.perm_cons_erase`, `Set.Finite.eventually_all`, `Filter.extraction_of_frequently_atTop`, …) | success | this repository's Mathlib `79d0395a` |
| `Nodup.not_mem_erase` is the right name | `lean_run_code` + `exact?` | success | `exact Nodup.not_mem_erase h` |
| `Fin.cycleRange` and its two orientation lemmas exist | `lean_run_code`, `#check` | success | — |
| `Fintype ((Fin \|Q\| ≃ Q) × Fin \|Q\|)` by `inferInstance`, in CSLib | probe A, `lake env lean` on the fork | **fail**, then **success** | fails bare and with `Mathlib.Logic.Equiv.Fintype`; succeeds with `Mathlib.Data.Fintype.Perm` |
| Explicit-data form discharges the existential `proof_wanted` | probe B, `lake env lean` on the fork | success, exit 0 | one term, `⟨_, inferInstance, toRabinLAR a, h a⟩` |
| Chain-indexed Rabin pairs elaborate without `Decidable`/`color` | probe C, `lake env lean` on the fork | success, exit 0 | `Set` comprehension over `Fin (Fintype.card State)` |
| List-based carrier is `Finite` | ad hoc `lean_run_code` | **not completed** | abandoned in favour of the `Equiv` carrier |

## Context Extension Recommendations

- **Topic**: acceptance-condition conversions for ω-automata and which of them are determinizations.
- **Gap**: the project's Lean context (`context/project/lean4/`) has no note distinguishing *determinization* (NBA → deterministic, Safra/Piterman/Muller–Schupp) from *acceptance-condition conversion* on an already-deterministic automaton (appearance records). The conflation is already in the record — 879 row 16, the task title, and the fork's own `Rabin.toParity_exists` docstring, which correctly flags "**Note**: This is NOT Piterman's 2006 theorem" precisely because the confusion is natural.
- **Recommendation**: a short `context/project/lean4/domain/omega-automata-conversions.md` giving the three-column table of Finding 1.4 plus the one-sentence discriminator ("is the input nondeterministic?"), so the distinction does not have to be re-derived each time the topic resurfaces.

## Appendix

**Probe files** (scratchpad, outside both repositories, no `.lean` written or edited in either tree):
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/9c85f8d4-b30f-4cda-a0cf-7af1bfedd4db/scratchpad/lar_probe4.lean` — probes A, B, C as finally passing, exit 0 under `lake env lean` in `~/Projects/cslib`
- `.../lar_probe.lean`, `.../lar_probe2.lean`, `.../lar_probe3.lean` — the failing intermediates recorded in Recommendation 3

**Corpus searches run**: `literature-search.sh` on "latest appearance record" (0 results), "appearance record" (hit: `piterman_2007`), "Muller condition Rabin condition", "Zielonka tree" (0 results), "index appearance". Direct `grep -i "appearance record"` over `thomas_2003_reactive/`, `thomas_1997_languages/`, `zielonka_1998/`, `piterman_2007/`, `loding_pirogov_2019_…/`, `schewe_varghese_2014_…/`.

**Primary passages located** (not re-typed here; cited by path and line in Finding 1.2):
- `thomas_1997_languages/Thomas_1997_Languages_Automata_Logic.md:1975` (Theorem 6.5), `:2004` (Remark 6.6), `:1982-1986` (the data structure and its attribution to Büchi [Bü83] and Gurevich–Harrington [GH82]), `:2332` (the construction read as supplying game memory)
- `thomas_2003_reactive/Thomas_2003_ch03_deterministic_omega.md:501-513` (the Safra-specific Muller→Rabin pairs), `:511` (Theorem 3.11)
- `zielonka_1998/Zielonka_1998_Infinite_Games_Coloured_Graphs.md:814` (LAR memory definition; OCR degraded, entry marked UNVERIFIED)
- `piterman_2007/chunk_0016.md:6` (index appearance record, footnote only)

**Tool note**: `lean_diagnostic_messages` and `lean_file_outline` are blocked and were not called.
