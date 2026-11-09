# Research Report: Task #903 — does a deterministic Muller automaton suffice for the Auxiliary-Atoms rule and the ban/lull mechanism at ZTime?

**Task**: 903 - Muller sufficiency for the Auxiliary-Atoms rule and the ban/lull mechanism at ZTime
**Started**: 2026-11-09T14:16:51Z
**Completed**: 2026-11-09T14:39:00Z
**Effort**: one research dispatch (orchestrated, seq 1); paper only, no Lean work
**Dependencies**: None (prior art: the L⁺ ZTime completeness-programme report; the CSLib ω-automata NO-GO re-assessment)
**Sources/Inputs**:
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` — read in full this session (Findings 2.3, 2.4, 2.5, the 21-row ingredient table, the verdict)
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` — read in full this session (Findings 1b/1c/1d, Finding 2's costing, (O1)-(O4), Risks)
- `specs/879_.../probes/01_target-statements.lean` — `aaStep`, `aaExcl`, `aaAnte`, and the `aaFwd`/`aaBwd` constructors read verbatim this session
- Literature (held, read this session): Reynolds 2001, *An Axiomatization of Full Computation Tree Logic* — `sec02` (Theorem 2), `sec04` (§9, the three languages, the automaton, `θ_A`, `χ₁`), `sec05` (§10.1-§10.2, §11 the idea of banning, `ζ_L`), `sec06` (§11.1 lulls, §12 chronicles, K0-K5D, Lemma 13, §12.1 pioneers), `sec07`/`sec08` (lull-length uses)
- `~/Projects/cslib` (local fork, `benbrastmckie/cslib`, HEAD `3bdf16d9f`) — `Cslib/Computability/Automata/DA/Basic.lean` (the `Muller` structure and its `ωAcceptor`), `DA/MullerClosure.lean` (read in full), `DA/Conversions.lean` (read in full); `git grep` over `upstream/main` = `leanprover/cslib` `1e285fd14`
- This repository: `FormalSystem/PlusLanguage/Formula.lean` (the `PlusFormula` constructors and derived temporal operators), `FormalSystem/PlusLanguage/PlusLCSchema.lean:136` (`gle`)
- Mathlib lookup skipped: no Lean target (`file_scope` for this task is `[]`, `task_type` is `formal`, not lean4-routed)
**Artifacts**:
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md` (this report)
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal
**Domains**: logic (primary: the Auxiliary-Atoms rule's interface, the expressibility of acceptance conditions in L⁺, Reynolds' chronicle clauses), math (secondary: ω-automata acceptance-condition expressiveness on a fixed state space)

## Status vocabulary

*Read* — a line or declaration read directly from the named file this session. *Held* — a literature fact read this session in a held source. *Derived* — a paper inference performed this session, stated with its argument. *Carried* — inherited from a prior record and not re-derived (flagged at each use). No claim below is a completeness claim; nothing under `FormalSystem/`, `Tests/`, `lakefile.toml` or `lake-manifest.json` was touched, no `require` was added, and no Lean code was run.

## Executive Summary

- **The answer is split, and the split is the finding.** A deterministic Muller automaton **suffices for the Auxiliary-Atoms rule** — fully, with no residual cost — and **does not suffice for the ban/lull mechanism**. The AA rule carries no acceptance condition at all, so it is acceptance-condition-agnostic; Reynolds' banned list is indexed by the *accepting pairs* of the automaton and is pair-shaped by construction.
- **The AA half, settled by reading `θ_A`.** Reynolds' `θ_A` (§9, held) and this repository's `aaAnte` (read) are the same object: an initial-state atom, a transition clause `(s ∧ Ĉc) → AX p(s,c)`, and mutual exclusivity of the state atoms. Neither contains any acceptance condition, and neither do the `aaFwd`/`aaBwd` side conditions. Acceptance enters only as a *separate formula* over the fresh atoms, inside `φ⁺`. Because `p : Atom → ℕ → Atom` is a function, **determinism is the entire demand the rule makes on the automaton**, and a DMA is deterministic. Both acceptance conditions live in the same `{GF, FG}` Boolean fragment of the fresh-atom language, both expressible from `someFuture`/`allFuture` (read) and mirrored by `reflectTime`. On this half the dispatch's premise is confirmed exactly as stated.
- **The ban/lull half, settled by reading the chronicle definition.** A chronicle carries `bl : T → (C × {1,…,K})*` where, in Reynolds' own words, "`K`, recall, is the number of **accepting pairs** of `A`" (held, §12). Clause K4A conditions a banned entry `(c,p)` on a lull during which *no colour in `V_p`* appeared; K4B orders entries by "the order of `V_p`s ceasing to appear"; the look-ahead formula is `ζ_L = χ₁ ∨ ⋁_j X((¬v_{p₁} ∧ … ∧ ¬v_{p_j}) U γ_{c_j})`. Every one of these is a function of a *single* pair `(U_p, V_p)` per index. Reynolds states the dependence outright: "**The simple form of the Rabin acceptance criteria is the key to guiding our construction**" (held, §9).
- **The structural reason, stated once.** The banned list is a device for discharging a **conjunction of per-index obligations with no walk-dependent choice**. `¬Rabin` is exactly that: `⋀_i (GF v_i ∨ FG ¬u_i)`, and for each `i` the mechanism's two options are "keep `V_i` alive" (the default) and "ban `U_i`" (a uniform fallback, no internal choice). `¬Muller` is a conjunction of **disjunctions**: `⋀_{F ∈ 𝓕} (GF v_F ∨ ⋁_{s∈F} FG ¬s)`, where `v_F := ⋁_{s∉F} s`. The fallback now requires choosing *which* `s ∈ F` to starve, the right choice is walk-dependent, and the canonical device for making it is the latest-appearance record — i.e. precisely the construction the deferred conversion supplies. Derived, §2.2.
- **The naive repair is not merely incomplete, it is unsound, and a two-state example proves it.** Take `Q = {a,b}` and `𝓕 = {{a,b}}` (the DMA for "both `a` and `b` recur"). The pair-enumeration repair gives pairs `{({a}, ∅), ({b}, ∅)}`, so `χ₁' = GF a ∨ GF b`, which is **valid** on every word over a finite state space; hence `¬Eχ₁'` is unsatisfiable and `φ⁺'` is inconsistent — while `φ⁺` is consistent, because the DMA's complement is nonempty (any word with `infOcc = {a}`). The same example shows **no** Rabin condition on `{a,b}` has accepted-`infOcc`-family `{{a,b}}`, so Muller is strictly more expressive than Rabin on a fixed state space and the LAR state-space blowup is unavoidable in general. Derived, §2.3. This is strictly stronger than the incompleteness `DA/Conversions.lean`'s own docstring records ("the avoidance set `State \ F` may not enforce the exact `infOcc = F` condition").
- **Verdict: (O1) does not vanish; it is preserved, its ground is sharpened, and its target is narrowed to one declaration.** The dispatch's second branch fires: `Muller.toRabin_exists` (`DA/Conversions.lean:112`, `proof_wanted`) is the single highest-value gap in either CSLib tree. Its value is no longer conjectural — the ban/lull mechanism is the named consumer. `Rabin.toParity_exists` (`:89`) is *not* on the critical path, because `Parity.toRabin_language_eq` is already proved (read) and the ban mechanism consumes Rabin, not parity.
- **One genuine saving falls out: (O2) collapses to nothing, under a composition order this report names.** 902 costed the indexed conjunctive product at 100-150 lines of new Rabin closure code. If the cut product is taken **on the Muller side first** and determinized **once** afterwards, that work disappears: `Muller.exists_iSup` (fork, `DA/MullerClosure.lean:125`, proved, measured clean) is already exactly the finite indexed union of existentially-DMA-recognizable languages that the cut product needs. Net: the automaton-side gap drops from two items to one. Derived, §3.
- **Forensic note on the record.** Reynolds' Theorem 2 cites "[McNaughton, 1966], and [Safra, 1988]" for a *Rabin* conclusion (held, §2). McNaughton's theorem lands in **Muller**. The Muller→Rabin step is therefore silently absorbed into Reynolds' Theorem 2 — which is exactly the step CSLib defers, and exactly the step this task has now shown to be load-bearing rather than cosmetic.

## Context & Scope

The dispatch asks one question: on paper, does a deterministic Muller automaton suffice (a) for the Auxiliary-Atoms rule and (b) for the ban/lull mechanism at ZTime? It supplies the ground on which it expects the answer to be yes — Muller acceptance is as expressible by state-valued fresh atoms as Rabin's is — and names the stake both ways: if Muller suffices, the fork's already-proved `IsRegular.iff_da_muller` *is* the determinization the architecture needs and (O1) vanishes; if Rabin is genuinely needed, `Muller.toRabin_exists` becomes the single highest-value gap in either CSLib tree.

Scope honoured as the dispatch specifies: no Lean source, nothing under `FormalSystem/` or `Tests/`, no `require` on CSLib, no completeness claim, no change to `lakefile.toml` or `lake-manifest.json`. No Lean process was started; `lean-lsp` was reported `registered`/`reachable` and was not the right instrument, because every question here is a question about what a *formula* and a *definition* say. CSLib was read as a read-only reference (`git grep`, direct file read), as the standing recommendation requires.

Not redone: the architecture itself. Report 879 owns it and its Findings 2.3 (the until-form schema), 2.4 (the separation-consumption point and the cut product) and 2.5 (the stage table) are built on as read. The inventory, axiom profiles and dependency-cost assessment of 902 are likewise taken as read; nothing in them is re-measured, because this task's question is not an inventory question.

**Deploy-freshness note.** The dispatch records this repository's deployed `.claude/` tree as stale for six extensions including `core` and `formal`. No deployed command or instruction was relied on beyond the Mathlib-lookup gate's resolution table, whose outcome here is forced by `file_scope = []` under either version. No redeploy was run and none is needed for this dispatch.

## Domain Analysis

**Logic (primary).** The decisive question is what the Auxiliary-Atoms rule's antecedent actually says, and what Reynolds' chronicle clauses actually quantify over. Both are answered by reading a formula and a definition, not by computing anything. The secondary logical content is expressibility: which acceptance conditions can be written in the fresh-atom language over state-valued atoms, with L⁺'s `F`/`G` along a history and the `reflectTime` mirror.

**Math (secondary).** One genuinely mathematical core: the relative expressiveness of Muller and Rabin acceptance *on a fixed state space*, and whether the shape of `¬Rabin` versus `¬Muller` admits the same finite bookkeeping device. §2.3's two-state example settles both.

**No physics content.**

## Findings

### 0. The two objects the question turns on, read verbatim

**(a) The Auxiliary-Atoms antecedent.** Reynolds §9 (held) defines, in the third (fresh-atom) language:

> `θ_A := s₀ ∧ AG ⋀_{s∈Q, c∈ecl(φ)} ((s ∧ Ĉc) → AX p(s,c)) ∧ AG ⋀_{s≠r∈Q} ¬(r ∧ s)`

and the probe's `aaAnte` (read, `specs/879_.../probes/01_target-statements.lean:40-55`) is the same object with `⊡G≤` for `AG` and the evaluation point for the root:

```lean
def aaStep (Q : List Atom) (k : ℕ) (a : ℕ → PlusFormula) (p : Atom → ℕ → Atom) : PlusFormula :=
  PlusFormula.stab (PlusFormula.gle (listAnd (Q.map fun b => bigAnd k fun i =>
    ((PlusFormula.atom b).and (a i)).imp
      (PlusFormula.stab (PlusFormula.next (PlusFormula.atom (p b i)))))))

def aaAnte (b₀ : Atom) (Q : List Atom) (k : ℕ) (a : ℕ → PlusFormula) (p : Atom → ℕ → Atom) :
    PlusFormula :=
  (PlusFormula.atom b₀).and ((aaStep Q k a p).and (aaExcl Q))
```

The `aaFwd` constructor's side conditions (read, same file) are `hb : b₀ ∈ Q`, `hp : ∀ b ∈ Q, ∀ i < k, p b i ∈ Q`, `hsl : ∀ i < k, StateLocal (a i)`, `hfresh`, `hexh : ⊢ bigOr k a`, `hexcl`. **Not one of these mentions an acceptance condition**, and `aaAnte` has no component that could carry one.

**(b) The chronicle.** Reynolds §12 (held) defines a chronicle as `(T, <, ≡, λ, bl, x₀)` with

> `bl : T → (C × {1,…,K})*` (where `K`, recall, is the number of accepting pairs of `A`)

and clauses K4A, K4B, K5B, K5D governing it. K4A: "If `(c,p)` occurs in `bl(x)` then … there is a lull in unbanning reaching its `e_H`th step below `x` such that no colour in `V_p` appears between the start of the lull and `x`". K4B: "If `(d,q)` precedes `(c,p)` in `bl(x)` then the most recent appearance of `V_q` (if any) below `x` is below (or equal to) the most recent appearance of `V_p`". And §11's look-ahead formula, over a banned list `L = [(c₁,p₁),…,(c_m,p_m)]`:

> `ζ_L = χ₁ ∨ X((¬v_{p₁}) U γ_{c₁}) ∨ … ∨ X((¬v_{p₁} ∧ … ∧ ¬v_{p_m}) U γ_{c_m})`

with `v_i = ⋁_{s∈V_i} s` and `u_i = ⋁_{s∈U_i} s`, and the acceptance formula

> `χ₁ = ⋁_{i=1}^{K} (FG ¬v_i ∧ GF u_i)`.

`χ₁` is the automaton's acceptance condition and it lives **outside** `θ_A`, in `φ⁺ = θ_A ∧ φ ∧ ¬Eχ₁`. The architecture's transposition (879 §2.5 stage A, carried) is `φ⁺ := clockAnte q ∧ θ_f ∧ θ_b ∧ φ ∧ ⊡¬χ₁` at the anchor.

This separation — the run in `θ_A`, the acceptance in `χ₁` — is the whole reason the question splits.

### 1. The AA rule: Muller suffices, with nothing left over

Three facts, each independently sufficient to make the AA rule acceptance-condition-agnostic:

**1.1 The rule's interface is a deterministic transition structure and nothing else.** The data the rule takes is `(b₀, Q, k, a, p)`: an initial state atom, a finite state-atom list, an alphabet size, the alphabet letters, and `p : Atom → ℕ → Atom`. That `p` is a *function* is the determinism requirement, and it is the only requirement: nondeterminism would force the step clause to read `(b ∧ aᵢ) → ⊡X ⋁_{b'} b'`, which does not pin the run as a function of the prefix and so defeats what Reynolds' Lemma 13 establishes ("the atoms do reflect the states of `A` as it reads the `ecl(φ)` versions of the labels along branches", held, §12). A DMA — `structure Muller extends DA` in CSLib (read, `DA/Basic.lean:106`) — is deterministic. Read + held.

**1.2 Acceptance is expressible, and expressible in exactly the same fragment for both types.** CSLib's Muller acceptance is `(a.run xs).infOcc ∈ a.accept` with `accept : Set (Set State)` (read, `DA/Basic.lean:106-118`). For a finite `Q`, `infOcc = F` is

> `(⋀_{s∈F} GF s) ∧ (⋀_{s∉F} FG ¬s)`,

so Muller acceptance is the finite disjunction `⋁_{F ∈ 𝓕}` of those, and CSLib's Rabin acceptance `∃ pair ∈ pairs, infOcc ∩ pair.1 = ∅ ∧ (infOcc ∩ pair.2).Nonempty` (read, 902 Finding 1b) is `⋁_{(E,F)} ((⋀_{s∈E} FG ¬s) ∧ (⋁_{s∈F} GF s))`. **Both use only `GF` of an atom and `FG` of a negated atom, Boolean-combined.** Neither has any expressive advantage over the other in the fresh-atom language; the dispatch's premise is exactly right. In L⁺ both shapes are available: `someFuture φ := untl top φ` and `allFuture φ := (someFuture φ.neg).neg` (read, `Formula.lean:140,146`), and since the `Q` atoms are state-valued, `GF b` along a history `τ` at the anchor says precisely that `b` holds at infinitely many future times of `τ`, i.e. `b ∈ infOcc` of the run along `τ`. The backward automaton's mirror conditions come from `reflectTime` (read, `Formula.lean:218`). Derived + read.

**1.3 The size difference does not matter where this rule is used.** Muller's acceptance formula has up to `2^{|Q|}` disjuncts of size `|Q|`, against Rabin's `|pairs|` disjuncts. But the DMA→DRA conversion itself is costed by the fork's own docstring at "exponential blowup in the number of pairs (bounded by `2^|Q|`)" (read, `DA/Conversions.lean`), so the blowup is relocated, not avoided. For a `Prop`-valued completeness statement only finiteness is load-bearing, and this architecture's automaton is already non-computable by (O3) regardless (carried, 902 Finding 2). Derived.

**Conclusion of this finding.** A deterministic Muller automaton suffices for the Auxiliary-Atoms rule, forward and backward, at ZTime, exactly as a Rabin automaton does, with no residual cost and no change to the rule.

### 2. The ban/lull mechanism: Muller does not suffice

#### 2.1 The mechanism is pair-indexed by construction, and Reynolds says so

Every component of the banning apparatus is a function of a *single* pair `(U_p, V_p)` per index `p`:

| Component | What it reads | Source |
|---|---|---|
| `bl : T → (C × {1,…,K})*` | `K` = the number of **accepting pairs** of `A` | held, §12 |
| K4A (when an entry may stand) | a lull in which no colour in `V_p` appeared | held, §12 |
| K4B (the entry ordering) | the order in which the `V_p`s ceased to appear | held, §12 |
| K5D (what may enter) | the current colour only | held, §12 |
| `ζ_L` (the look-ahead) | `χ₁` and the `v_{p_j}` | held, §11 |
| Lemma 17 (the LC consumer) | `β` = "no colour in `V_{p₁},…,V_{p_m}, V_q`" | carried, 879 §2.3 |
| the basic intent | "avoid a fullpath on which some colour in some `U_i` occurs infinitely often while colours in the corresponding `V_i` occur only finitely often" | held, §11 |

And Reynolds states the dependence directly, in §9: "**The simple form of the Rabin acceptance criteria is the key to guiding our construction.**" That sentence is the primary evidence that the pair shape is load-bearing rather than presentational, and it is the sentence this task was commissioned to test against the expressibility fact. The expressibility fact is true (§1.2) and does not touch it, because the expressibility fact is about `χ₁` and the banned list is not about `χ₁`.

#### 2.2 The structural reason: `¬Rabin` is a choice-free conjunction; `¬Muller` is not

The banned list's job is to make `χ₁` false along every fullpath, including emergent ones, using a finite device maintained during a construction that bifurcates. Write out what that requires in each case.

**Rabin.** `¬χ₁ = ⋀_{i=1}^{K} (GF v_i ∨ FG ¬u_i)`. For each index `i` there are exactly two ways to discharge the obligation, and the mechanism has both: the default is that `V_i` keeps appearing (`GF v_i`); the fallback, triggered when `V_i` has been absent for a lull, is to ban the colours in `U_i`, which forces `FG ¬u_i`. **The fallback has no internal choice** — `U_i` is a single set and all of it is banned. The only interaction the mechanism must manage is *between* indices, and that is what the list's order and the unban-truncation rule handle ("record bannings in a certain order and remove all later listed pairs when we unban a pair", held, §11).

**Muller.** With `v_F := ⋁_{s∉F} s`, the Muller acceptance condition is `χ₁^{M} = ⋁_{F ∈ 𝓕} (FG ¬v_F ∧ ⋀_{s∈F} GF s)` — the "finitely often" half collapses to a single `FG ¬v_F` with avoid-set `Q \ F`, but the "infinitely often" half is a **conjunction of `|F|` separate `GF`-clauses** and does not collapse to a single `GF u`. Hence

> `¬χ₁^{M} = ⋀_{F ∈ 𝓕} (GF v_F ∨ ⋁_{s∈F} FG ¬s)`.

The fallback for index `F` is now itself a disjunction: starve *some* `s ∈ F`. Three consequences, each fatal to a verbatim transposition:

1. **The choice must be made, and the mechanism has no place to record it.** A banned entry would have to be a triple `(colour, F, s)` rather than a pair `(colour, p)`, and K4B's ordering (by the order in which avoid-sets ceased to appear) would need a second, independent ordering over the `s`-choices.
2. **The right choice is walk-dependent.** Two walks through the same constructed prefix can have `infOcc` differing inside the same `F`, so no choice fixed at a construction point is correct for every walk extending it. This is the same difficulty Reynolds' bifurcation paragraph identifies for colours — and his answer there is to make banning *conditional* and revisable. A second conditional dimension requires a second revision discipline, which is new mathematics, not a transcription.
3. **The canonical device for making the choice is the latest-appearance record** — track the order in which states were last visited, and read `infOcc` off the LAR's hit position. That is exactly the construction `DA/Conversions.lean` defers (read: `Rabin.toParity_exists`'s docstring names the LAR and the `|State| × k! × k` blowup). So the "redesign the ban mechanism for Muller" route is not an alternative to the deferred conversion; it is the deferred conversion, relocated into the least-formalized part of the engine (stages C-F of 879's table, all `paper`). Derived.

The general principle, stated once: **the banned list is a device for discharging a conjunction of per-index obligations with no walk-dependent choice, and `¬Rabin` is the unique acceptance-condition negation of that shape among the three candidates.** `¬Streett` is a bare disjunction (`∃ i` to force), which has the dual problem — the choice of `i` is walk-dependent. `¬Muller` is a conjunction of disjunctions, which has both. Derived.

#### 2.3 The naive pair-enumeration repair is unsound, not merely incomplete — a two-state proof

The obvious repair is to run Reynolds' mechanism verbatim on a derived pair family. For a Muller family `𝓕` over `Q`, the natural candidate is

> `I := {(F,s) : F ∈ 𝓕, s ∈ F}`, with `U_{(F,s)} := {s}` and `V_{(F,s)} := Q \ F`,

which satisfies Reynolds' normalisation `U ∩ V = ∅` (held, §9). The resulting `χ₁' = ⋁_{F ∈ 𝓕} ⋁_{s ∈ F} (FG ¬v_F ∧ GF s)` accepts every word the DMA accepts, so `¬Eχ₁'` *would* deliver universal non-acceptance. But it accepts strictly more — `L(χ₁') = {w : ∅ ≠ infOcc(w) ⊆ F for some F ∈ 𝓕}` — and over-banning is not free. Reynolds warns of exactly this: "banning too much will frustrate our efforts to make sure that eventualities are satisfied along branches" (held, §11). The failure is concrete:

> **Counterexample.** `Q = {a,b}`, `𝓕 = {{a,b}}` — the DMA accepting exactly the words in which both `a` and `b` recur. Then `I = {({a}, ∅), ({b}, ∅)}` since `Q \ F = ∅`, so `v_F = ⊥` and
> `χ₁' = (FG ¬⊥ ∧ GF a) ∨ (FG ¬⊥ ∧ GF b) ≡ GF a ∨ GF b`.
> Over a finite state space `infOcc` is nonempty, so `χ₁'` is **valid**: every word satisfies it. Hence `¬Eχ₁'` is unsatisfiable and `φ⁺' = θ_A ∧ φ ∧ ¬Eχ₁'` is inconsistent — while `φ⁺` is consistent, because the DMA's complement is nonempty (take any word with `infOcc = {a}`). Lemma 7 fails. Derived.

So the repair does not merely fail to characterise the Muller language (which is what `DA/Conversions.lean`'s docstring already records: "the avoidance set `State \ F` may not enforce the exact `infOcc = F` condition; Muller acceptance requires *equality*, not just nonemptiness"); it **breaks the construction's first step**. That is a strictly stronger negative than the docstring's, and it is the reason the conversion needs a state-space blowup rather than a cleverer pair choice.

The same example settles the expressiveness question, which is what makes the blowup unavoidable:

> **Strictness.** No Rabin condition over the state space `{a,b}` has accepted-`infOcc`-family `{{a,b}}`. Suppose `{a,b}` is accepted via pair `(U_i, V_i)`: then `{a,b} ∩ V_i = ∅` forces `V_i = ∅`, and `{a,b} ∩ U_i ≠ ∅` gives some `s ∈ U_i`, say `a`. But then `{a} ∩ V_i = ∅` and `a ∈ {a} ∩ U_i`, so `{a}` is accepted too — and `{a} ∉ 𝓕`. Derived.

`𝓕 = {{a,b}}` is not an exotic family: it is `GF a ∧ GF b`, the simplest generalized-Büchi condition, and it *is* Streett-expressible (pairs `({a}, Q)`, `({b}, Q)`). So the Muller/Rabin gap on a fixed state space opens at the very first non-trivial conjunction of liveness requirements, and the architecture's violation language — which 879 §2.4 describes as carrying liveness via `untl` and needing per-commitment realisation — is precisely where such conjunctions arise. Derived.

**The Rabin/Streett duality does not rescue it.** `Streett.toRabin_language_eq : language a.toRabin = (language a)ᶜ` and its converse are proved in the fork (read, 902 Finding 1c), but they are *complementation* theorems. If the violation language were a DSA, its `toRabin` is a DRA for the **complement** — the good language — whereas the ban mechanism needs a DRA for the **violation** language. Derived + read.

#### 2.4 Nothing in this is specific to ZTime, and the two-sidedness only doubles it

At ZTime the architecture runs two one-sided, clock-anchored automata, each reading an ω-half-word from the cut (carried, 879 §2.4), so each is an ordinary ω-automaton and the acceptance-type question is the ordinary one. The ZTime transposition requires "two-sided banned lists (one per automaton), lulls in both directions" (carried, 879 §2.5 stage C), so the pair-shape requirement applies **twice**, once per automaton, with the backward one's conditions mirrored by `reflectTime`. The ZTime-specific ingredients — the `LCU` segment guard, the full-product lemma, the cut initialisation — are orthogonal to the acceptance type and are untouched by this report.

### 3. One genuine saving: (O2) collapses, under a named composition order

902 Finding 2 costed (O2) — "the indexed conjunctive product with a nameable initial state" — at 100-150 lines of new Rabin closure code (`Rabin.union`/`union_language_eq` plus a `Rabin.exists_iSup` finite-index lift), on the correct observation that the architecture needs the complement of the finite **union** of the component violation languages, not their intersection. That estimate stands for the Rabin side. But it is avoidable entirely, by ordering the two steps the other way:

> **Union first on the Muller side, determinize once afterwards.** The cut product is a finite indexed union over `pt ∈ PT(w₀)` of the `pt`-indexed component violation languages (carried, 879 §2.4; `PT(w₀)` is finite, being a set of types over a finite closure). `Muller.exists_iSup` (read, fork `DA/MullerClosure.lean:125`; proved, measured clean per 902) has exactly that signature: from `∀ i ∈ s, ∃ (State) (_ : Finite State) (da : Muller State Symbol), language da = p i` it delivers `∃ (State) (_ : Finite State) (da : Muller State Symbol), language da = ⨆ i ∈ s, p i`. So the union is already available, for free, with no new code; the single Muller→Rabin conversion is then applied once, to the folded DMA, rather than `|PT(w₀)|` times to the components.

Consequence: **the automaton-side gap drops from two items to one.** Under this ordering (O2) is discharged by already-landed fork code and `Muller.toRabin_exists` is the sole remaining automaton-side obligation. Derived + read.

Two smaller observations in the same register, recorded because they are cheap and because they bound what Muller buys:

- **Muller complementation is free on the same state space** (`accept := a.acceptᶜ`, a three-line theorem needing no `[Finite]`, since `¬(infOcc ∈ 𝓕) ↔ infOcc ∈ 𝓕ᶜ` by definition), and **Muller intersection is the `∨ → ∧` edit of `Muller.union`** (read: `Muller.union`'s `accept := {S | Prod.fst '' S ∈ a1.accept ∨ Prod.snd '' S ∈ a2.accept}`, with `union_language_eq` proved by `rw [prod_run_infOcc_fst, prod_run_infOcc_snd]` — the intersection proof is the same two rewrites after `mem_inf` for `mem_sup`). Neither exists in either tree (verified this session by `grep` over `Cslib/Computability/` for `Muller.compl`/`Muller.inter`/`Muller.iInf`: no hits; and upstream has no `MullerClosure.lean` at all). **Neither is on the critical path**, given §3's union-first ordering and §2's negative — they are recorded so that a future reader does not re-derive them, not recommended as work.
- **`Rabin.toParity_exists` (`DA/Conversions.lean:89`) is not on the critical path.** `Parity.toRabin_language_eq` is proved (read, fork `DA/Parity.lean:134`), and the ban mechanism consumes Rabin. A DPA for the violation language would therefore also serve, via the proved direction; a DRA directly is enough. So of the two `proof_wanted`s in that file, exactly one matters.

### 4. The verdict

> **Muller suffices for the Auxiliary-Atoms rule. It does not suffice for the ban/lull mechanism. (O1) is preserved, with its ground sharpened from "determinization is unproved" to "the banned list is pair-indexed and a Muller family does not present as a pair family without a walk-dependent choice that only an LAR can make".**
>
> The dispatch's second branch therefore fires: **`Muller.toRabin_exists` (fork `DA/Conversions.lean:112`, `proof_wanted`) is the single highest-value gap in either CSLib tree**, and its value is now established rather than conjectural — the ban/lull mechanism is its named consumer, and §2.3's two-state example shows no cheaper substitute exists.
>
> Two corrections to the surrounding record follow. **(O1)'s "this may be a presentational preference rather than a real need" is withdrawn as to the ban mechanism and confirmed as to the AA rule** — the expressibility argument it rests on is sound and simply does not reach the banned list. And **(O2) is removed from the obstruction list**, discharged for free by `Muller.exists_iSup` under §3's union-first ordering.
>
> **(O3) and (O4) are untouched.** The determinized automaton still arrives as `∃ (State : Type) (_ : Finite State) (da : …)` rather than as nameable syntax; and the ω-regularity of the violation language is still not stated anywhere in-tree, so the chain's *first* arrow remains entirely absent. The CSLib finding still removes one row from a 21-row ingredient table and shortens no critical path.
>
> **Nothing here bears on the GO for T3 as a paper programme**, which never depended on the automaton being formalizable, and nothing here is a completeness claim.

**What this does to the dependency question.** The dispatch's framing was that Muller sufficiency would make the CSLib dependency question "live rather than hypothetical", because `iff_da_muller` would already be the needed determinization. It is not: `iff_da_muller` lands in Muller, and the ban mechanism needs Rabin, so the fork does not today contain the determinization the architecture consumes. 902's recommendation 3 ("do not `require` anything now") is therefore reinforced rather than re-opened, on a second independent ground: there is now a *mathematical* reason not to depend on the fork for this, not merely a trust-surface reason.

**The research alternative, named and not recommended.** A design that avoids determinization altogether — an explicit progress-measure argument replacing the automaton — is 879's P9 open question and remains the only route to a Lean proof that does not pass through `Muller.toRabin_exists`. One tempting shortcut should be recorded as closed: because the automaton reads *colour* words and colours already carry the hues, it is natural to hope the nondeterminism determinization exists to remove is already resolved by the labelling, so that a DRA could be built directly with one Rabin pair per until-commitment (`V_c` = "commitment `c` discharged", `U_c` = `Q`). It is not: the truth of a future-directed closure formula `γ̄` at a position still depends on the word beyond that position, which is exactly 879 §2.4's "handled by Rabin acceptance (guess and verify, then determinise)". The guess is what forces determinization. Derived; recorded so the hope is not re-entertained.

### Cross-Domain Synthesis

The logical and the automata-theoretic content meet at one seam, and the question was whether they meet at one seam or two. They meet at one: the Auxiliary-Atoms rule is the interface between the proof system and the automaton, and that interface carries *only* a deterministic transition table. Everything about acceptance is pushed across into the object language as a formula, where Muller and Rabin are indistinguishable because both live in the `{GF, FG}` Boolean fragment. So on the logic side, the acceptance type is genuinely invisible.

The ban/lull mechanism is not on that seam at all. It is a *combinatorial* device internal to the construction, and it is parameterised by the acceptance condition's syntactic shape rather than by its extension — it needs a finite list of indices each naming one liveness witness set and one starvation set. That is a property of the acceptance *presentation*, not of the language, which is why an expressibility argument (about the language) cannot settle it and why reading the chronicle definition does.

The two-state example ties the halves together. `𝓕 = {{a,b}}` is expressible in L⁺ as `GF a ∧ GF b` with no difficulty whatsoever — the logic side sees nothing — and is provably not Rabin-expressible on `{a,b}`, so the combinatorial side sees an unbridgeable gap. One family, invisible to one domain and fatal to the other: that is the whole content of the split verdict.

## Decisions

1. **The question is answered as a split rather than a yes or no**, because the two consumers the dispatch names have different interfaces to the automaton, and reporting one answer for both would misreport whichever half it suppressed. Both halves are answered, with their own grounds.
2. **The ban/lull half is settled on a primary source rather than by reconstruction.** Reynolds' chronicle definition and his own sentence "The simple form of the Rabin acceptance criteria is the key to guiding our construction" are quoted from the held text, and the structural argument of §2.2 is offered as the explanation of that sentence, not as a substitute for it.
3. **A concrete two-state countermodel is given rather than an appeal to the known Muller/Rabin strictness.** The example does double duty — it refutes the naive repair by making `φ⁺` inconsistent, and it proves the expressiveness strictness that makes a state-space blowup unavoidable — and it is small enough to check by hand, which an appeal to a textbook fact would not be.
4. **(O2) is reported as discharged rather than as re-costed.** 902's 100-150-line estimate is correct for the Rabin-side union and is not disputed; what changes is that the union need not be taken on the Rabin side at all. The saving is attributed to a composition order, which is the actual content, rather than to a new lemma.
5. **`Rabin.toParity_exists` is explicitly taken off the critical path**, on the proved `Parity.toRabin_language_eq`. Leaving both `proof_wanted`s named as equally blocking would have overstated the gap by a factor of two.
6. **The direct-DRA shortcut is recorded as closed rather than omitted.** It is the first thing a reader of §1 will think of, and leaving it unaddressed would invite a future task to re-derive the refutation.
7. **No `user_decision` is raised.** The dispatch framed this as a decidable paper question with both branches pre-costed, and the answer follows from the held source and the derived example. The only preference-shaped question downstream — whether to invest in `Muller.toRabin_exists` upstream, in the fork, or not at all — is 902's recommendation 4 and is not re-opened here; this report only raises that item's priority, which is a finding, not a choice.
8. **No library change, no `require`, no Lean execution, and no completeness claim** lands from this task.

## Recommendations

1. **Amend report 902's (O1) and its matching Risks bullet.** (O1)'s parenthetical — "*Unless* a DMA suffices … so this may be a presentational preference rather than a real need. Settling that is the cheapest thing anyone could do to this verdict" — should be replaced by: *"Settled: a DMA suffices for the Auxiliary-Atoms rule, which carries no acceptance condition, and does not suffice for the ban/lull mechanism, whose banned list is indexed by the automaton's accepting pairs (Reynolds 2001 §12, `bl : T → (C × {1,…,K})*`). `Muller.toRabin_exists` is therefore load-bearing, and is the single highest-value `proof_wanted` in either tree."* Its Risks bullet ("(O1) may be a presentational requirement rather than a real one") is discharged negatively and should say so.
2. **Remove (O2) from report 902's obstruction list**, replacing it with the §3 note: the cut product is a finite indexed union, `Muller.exists_iSup` already supplies it, and the composition order is union-on-the-Muller-side-then-determinize-once. The 100-150-line Rabin closure item (902's recommendation 6) should be withdrawn, not re-filed.
3. **Amend report 879's ingredient row 16 and its verdict's third paragraph** to name the ban/lull mechanism as the consumer that forces Rabin. Row 16's current replacement text (supplied by 902) says determinization to Rabin or parity "is `proof_wanted` even in the fork" without saying why Rabin is wanted; that gap is what made this task necessary, and the row should now read that the Auxiliary-Atoms rule needs only determinism while the banned list needs the pair shape. The verdict's "(O1) … determinization to Rabin or parity is `proof_wanted`" should narrow to Rabin alone, on `Parity.toRabin_language_eq`.
4. **File one CSLib-side item, not two**: a *named* Muller→Rabin construction via the latest-appearance record, `Muller.toRabinLAR : Muller State Symbol → Rabin (LAR State) Symbol` with a `language_eq`, in place of the existential `Muller.toRabin_exists` as currently stated. The named form is what the architecture actually needs — (O3) is alive precisely because `∃ (State : Type) …` cannot be written into `θ_f` — so proving the existential as stated would leave (O3) exactly where it is. Do not file `Muller.inter`, `Muller.compl`, `Rabin.union`, `Rabin.exists_iSup`, or `Rabin.toParity_exists`: §3 shows the first four are off the path and §3's last bullet shows the fifth is.
5. **Do not re-open the `require` question.** 902's recommendation 3 stands and is strengthened: the fork does not contain the determinization the architecture consumes, so a dependency on it today would not shorten the automaton-side path at all.
6. **Leave 879's P9 owning the progress-measure alternative**, with §4's last paragraph appended as a closed sub-question (the colour-word labelling does not resolve the guess, so a direct DRA construction is not available).
7. **Do not file any task that rests on Muller sufficiency for the ban mechanism.** The negative is the operative half of this report, and the positive half (the AA rule) was never the binding constraint.

## Risks & Mitigations

- **Risk: the structural argument of §2.2 is an argument about Reynolds' *particular* banned list, not a proof that no finite device can discharge `¬Muller`.** It is not such a proof, and does not claim to be — a redesigned mechanism with an LAR-like second dimension is conceivable. *Mitigation*: §2.2's point 3 states exactly that, and names the cost: the redesign is the LAR relocated into stages C-F of 879's table, all of which are `paper` and none of which has a landed Lean ingredient. The claim made is that the redesign is not cheaper than the conversion, not that it is impossible.
- **Risk: §2.3's counterexample refutes the naive pair enumeration, which is not the only candidate repair.** *Mitigation*: the strictness half of §2.3 closes the general case — no pair family over the *same* state space can express `𝓕 = {{a,b}}` — so every repair must enlarge the state space, which is what "needs an LAR" means.
- **Risk: §3's saving depends on `PT(w₀)` being finite and on the composition order being legitimate.** `PT(w₀)` finite is carried from 879 §2.4 (a set of types over a finite closure) and not re-derived here; the order's legitimacy is the trivial fact that complementing the union of the component violation languages is the same requirement as universal non-acceptance in every component, which 902 Finding 2 already establishes. *Mitigation*: both dependencies are named; if `PT(w₀)` were infinite the cut initialisation would already have failed for a different reason, which 879 would have recorded.
- **Risk: the claim that `χ₁` lies outside `θ_A` rests on reading `φ⁺`'s shape.** *Mitigation*: both `θ_A` (held, §9) and `aaAnte` (read, the probe) were read verbatim and are quoted in §0; `φ⁺ = θ_A ∧ φ ∧ ¬Eχ₁` is Reynolds' own, in the same section.
- **Risk: `Muller.exists_iSup`'s proved status is carried from 902's axiom measurement, not re-measured.** *Mitigation*: the declaration and its proof were read directly this session in `DA/MullerClosure.lean` (a complete `Set.ncard` induction, no `sorry`, no `proof_wanted`); the axiom *profile* is carried and flagged, and nothing in §3 depends on the profile rather than on the proof existing.
- **Risk: this report is read as overturning 879's GO on T3.** It does not touch it. *Mitigation*: stated in §4's last bullet and here.
- **Risk: it is read as lifting the standing "do not `require` CSLib" conclusion.** It reinforces it. *Mitigation*: recommendation 5.

## Tactic Survey Results

Not applicable: no proof goal was opened. This dispatch is a paper question by its own terms ("PAPER QUESTION, no Lean work"), answered by reading two formulas, one structure definition, one set of chronicle clauses, and by deriving a two-state counterexample. No Lean process was started, no tactic was attempted, and no `lean_multi_attempt` call was made. Recording a survey here would be fabrication.

## Appendix

### Evidence tier by claim

| Claim | Tier |
|---|---|
| `θ_A` and `aaAnte` carry no acceptance condition; `p` is a function | held (Reynolds §9) + read (the probe) |
| `aaFwd`/`aaBwd` side conditions mention no acceptance condition | read (the probe) |
| Muller and Rabin acceptance both lie in the `{GF, FG}` Boolean fragment; both expressible in L⁺ via `someFuture`/`allFuture` and mirrored by `reflectTime` | derived + read (`Formula.lean:140,146,218`) |
| `Muller.accept : Set (Set State)`; acceptance is `infOcc ∈ accept` | read (fork/upstream `DA/Basic.lean:106-118`) |
| `bl : T → (C × {1,…,K})*` with `K` = the number of accepting pairs; K4A/K4B/K5B/K5D; `ζ_L`; `χ₁ = ⋁_i (FG ¬v_i ∧ GF u_i)` | held (Reynolds §9, §11, §12) |
| "The simple form of the Rabin acceptance criteria is the key to guiding our construction" | held (Reynolds §9, verbatim) |
| `¬Rabin` is a choice-free conjunction; `¬Muller` is a conjunction of disjunctions; `¬Streett` a bare disjunction | derived |
| Pair-enumeration of a Muller family makes `φ⁺` inconsistent (`Q={a,b}`, `𝓕={{a,b}}`) | derived |
| No Rabin condition over `{a,b}` has accepted-`infOcc`-family `{{a,b}}` | derived |
| `Muller.exists_iSup` is a proved finite indexed union of existentially-DMA-recognizable languages | read (fork `DA/MullerClosure.lean:125`); axiom profile carried from 902 |
| `Muller.toRabin_exists` and `Rabin.toParity_exists` are `proof_wanted`; the LAR and the `2^{|Q|}` pair blowup are the fork's own cost statements | read (fork `DA/Conversions.lean`, in full) |
| `Parity.toRabin_language_eq`, `Rabin.toStreett_language_eq`, `Streett.toRabin_language_eq` proved | read (fork, via 902 Finding 1c line index) |
| No `Muller.compl`/`Muller.inter`/`Muller.iInf` in either tree; upstream has no `MullerClosure.lean` | read (`grep` over `Cslib/Computability/`, `git grep upstream/main`) |
| Reynolds' Theorem 2 cites McNaughton (Muller) and Safra (Rabin) for a Rabin conclusion | held (Reynolds §2, verbatim) |
| `PT(w₀)` is finite; the cut product is a finite indexed union; the separation-consumption point | carried (879 §2.4) |
| (O3), (O4), the 21-row table, the fork's toolchain match | carried (902 Findings 2-4) |

### Locators

- Reynolds 2001, `/home/benjamin/Projects/Literature/sources/reynolds_2001/`: `sec02_a.md:86` (Theorem 2) · `sec04_sec-9-…md:93-135` (the automaton, `θ_A`, `χ₁`) · `sec05_sec-10-…md:120-122` (hues/colours in `U_i`/`V_i`), `:181-250` (§11 banning, `ζ_L`) · `sec06_111-lulls-…md:1-48` (lulls), `:49-110` (§12 chronicle, K0-K5D), `:106-120` (Lemma 13)
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/probes/01_target-statements.lean:40-55` (`aaStep`, `aaExcl`, `aaAnte`), `:69-84` (`aaFwd`, `aaBwd`)
- CSLib fork (`~/Projects/cslib` @ `3bdf16d9f`): `Cslib/Computability/Automata/DA/Basic.lean:106-118` (`Muller`, its `ωAcceptor`) · `DA/MullerClosure.lean:41,60` (`prod_run_infOcc_fst/snd`), `:83,91` (`Muller.union`, `union_language_eq`), `:105,113` (`Muller.empty`), `:125,146` (`exists_iSup`, `exists_iSup_univ`) · `DA/Conversions.lean:89,112` (the two `proof_wanted`s and their cost docstrings)
- This repository: `FormalSystem/PlusLanguage/Formula.lean:140,146,218` (`someFuture`, `allFuture`, `reflectTime`) · `FormalSystem/PlusLanguage/PlusLCSchema.lean:136` (`gle`)
- `specs/902_…/reports/01_cslib-omega-automata-nogo-reassessment.md` Findings 1b-1d (the inventory), 2 (the (O2) costing), 3 ((O1)-(O4)), 4b (the dependency assessment), Risks bullet 1 (the question this task answers)
