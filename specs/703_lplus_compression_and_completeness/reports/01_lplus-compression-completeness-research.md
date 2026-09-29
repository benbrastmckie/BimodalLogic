# Research Report: L⁺ Compression and Completeness

**Task**: 703 - lplus_compression_and_completeness
**Started**: 2026-09-29T16:20:00Z
**Completed**: 2026-09-29T17:05:00Z
**Effort**: ~45 minutes (research round; RESEARCH-FIRST dispatch)
**Dependencies**: 695 (landed), 696 (landed, `completed`); an unfiled `trans_refl` follow-on proposed by 699 Part A
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/**`, `FormalSystem/PlusLanguage/**`, `scripts/check-module-invariants.sh`, `docs/theorem-index.md`); lean-lsp MCP (`lean_local_search`); prior task artifacts (699 Part A/B, 700 survey + addendum + cross-repo note); literature corpus (`~/Projects/Literature/sources/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics/`)
**Artifacts**: - `specs/703_lplus_compression_and_completeness/reports/01_lplus-compression-completeness-research.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **O1 — `LiftableRaw` IS decidable.** The decision procedure does not degrade to a
  semi-decision procedure. But the route the survey guessed ("finite-graph simulation") is
  **sound and incomplete**: the lifting path may need unbounded lookahead into the state path's
  future and past, so a step-local simulation decides a strictly stronger predicate. The complete
  method is a subset construction (bi-infinite language inclusion) on `2^(Fin n)`, plus a
  compactness step. A cheaper alternative is recommended below: enumerate a *decidable
  certificate* of liftability instead of deciding `LiftableRaw` itself.
- **O2 — the general case is reachable through `liftable_of_spliceClosed`, not through a new
  pigeonhole.** The recommended construction sets `trans := transIdOf` (no hopping) and arranges
  the index set to be splice-closed, which `liftable_of_spliceClosed` converts into a constant
  lift. The pigeonhole the survey anticipated is already in the tree, discharged, as
  `exists_cofinal_value`. `transFull` is *not* available: it reinstates the very reading that
  made the certificate class empty for `⊡`-over-tense targets.
- **O3 — the bound is neither `|closure| + 1` nor `|closure| × window`.** It is singly
  exponential in `|closure|`, of the order `2^|closure| × window`. The reason is structural: a
  (C5) witness index is *itself* an index, and it needs its own witnesses at every other time, so
  the accounting is a saturation over closure-types, not a count of failing closure members. The
  paired repository's search-bound expectations must be reset accordingly.
- **O4 — GKWZ's product-undecidability results do not bound this combination, and the closest
  product reading is decidable.** GKWZ Theorem 6.68 gives `PTL × S5_m` decidable for every `m`;
  Theorem 6.71 gives non-elementary complexity for `PTL × S5₂` (Halpern–Vardi 1989). More
  decisively, this repository's frames are not product frames: the stability modal fails both
  left commutativity and the Church–Rosser property against the temporal relation.
- **Structural finding that reframes the task's size.** This is not a transcription. The
  `Formula`-side theorem produces a `WitnessFamily` (no branching substrate, four conditions);
  the L⁺ target is a `PlusSharingWitnessFamily` (skeleton + six conditions). **No sharing-side
  compression theorem exists anywhere in the tree**, on either side. The task must build `rep`,
  `trans`, `trans_refl`, `lift`, (C0) and (C5) with no precedent.
- **Recommendation**: proceed. Zero sorries is achievable. No sorry-deferral or axiom route is
  proposed or needed.

## Context & Scope

The task is to prove the L⁺ twin of
`FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`. The dispatch made
the round RESEARCH-FIRST and named four obligations (O1–O4) that must be answered before a plan
is written. This report answers all four, records the structural findings that bear on plan
shape, and names the acceptance-gate edits.

Scope boundaries honoured: soundness is untouched. `PlusSharingWitnessFamily.plusTruth_iff_mem`
(`PlusWitnessFamily/Agreement.lean:183`) and `...plusRefutes_of_certifies` (`:413`) are read but
not proposed for change; both are C2-pinned and must survive with their statements unchanged.

### Corrections to inherited assumptions

Two path claims in the dispatch description need correcting before a plan cites them.

1. `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Family.lean:165` **does not
   exist**. There is no `PlusWitnessFamily/Compression/` directory. The `rw
   [validZTime_iff_validInt]` at line 165 is in the `Formula`-side file,
   `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean:165`. The substance
   of the prerequisite claim is unaffected and confirmed: that rewrite is Step 0, and
   `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt`
   (`FormalSystem/PlusLanguage/PlusIntTransfer.lean:188`) is its only L⁺ counterpart. It is
   landed.
2. Task 696 is `completed`, and `trans_refl` **was declared** as a skeleton field
   (`WitnessFamily/Sharing/Skeleton.lean:684`, mirrored at
   `PlusWitnessFamily/Basic.lean:246`). The 699 Part A follow-on that would drop it was never
   filed as a numbered task. Its interaction with this task is resolved below under Decisions.

## Findings

### F1 — The target is a sharing family; the `Formula`-side theorem produces a non-sharing one

`exists_witnessFamily_of_not_validZTime` (`WitnessFamily/Compression/Family.lean:153`) produces a
`WitnessFamily [] [φ]` — a box guess plus a list of labelled lassos, no branching substrate. It
discharges four conditions: (C1) local coherence, (C2) fulfilment, (C3) box faithfulness, (C4)
the target.

The L⁺ target is `PlusSharingWitnessFamily Γ Del`, which `extends PlusWitnessFamily` with eleven
further fields (`PlusWitnessFamily/Basic.lean:220-249`): three `rep` segments, two non-emptiness
facts, `rep_idem`, three `trans` segments, three length-agreement facts, `trans_refl`, and
`lift`. It must satisfy **six** conditions, adding (C0) `PlusAtomCoherent` and (C5)
`StabFaithful`.

A grep for any construction of a sharing family from a countermodel returns nothing on either
side. `WitnessFamily/Sharing/Specialize.lean` is the only bridge, and it is the *diagonal*
instance (`rep = id`, so `share u i j ↔ i = j`). That route is provably unavailable here: at the
diagonal, `PlusLanguage.stab_iff_of_deterministic` collapses `⊡φ ↔ φ`, so a diagonal family
certifies only targets on which that collapse holds.

**Consequence for plan sizing.** The `Formula`-side `Compression/` subtree is 2,284 lines across
seven files, none of it transcribed to L⁺, and a faithful transcription would still leave `rep`,
`trans`, `trans_refl`, `lift`, (C0) and (C5) undischarged. Task 700's estimate that this is the
largest single piece of the programme is confirmed and, if anything, understated.

### F2 — (O1) `LiftableRaw` is decidable; simulation is the wrong argument

`LiftableRaw` (`Sharing/Skeleton.lean:316-322`):

```
∀ σ : ℤ → Fin n, (∀ u, stepOf … u (σ u) (σ (u+1))) →
  ∃ τ : ℤ → Fin n, (∀ u, transOf … u (τ u) (τ (u+1))) ∧ (∀ u, shareOf … u (σ u) (τ u))
```

**The structure that makes it decidable.** `repOf` and `transMatOf` both decode through
`Periodic.unrollOf`, so `u ↦ (rep u, transMat u)` is eventually periodic in both directions —
period `|repBack|` strictly left of the origin, period `|repFwd|` at or past `|repMid|`, with a
finite transient `[0, |repMid|)`. `Sharing/Window.lean`'s `rep_congr_back` / `rep_congr_fwd` and
`transRaw_congr_back` / `transRaw_congr_fwd` are that fact, already proved.

Because `shareOf u i j` is `rep u i = rep u j`, and `stepOf u i j` is
`∃ i', rep u i = rep u i' ∧ rep (u+1) i' = rep (u+1) j`, the `Step` relation depends only on the
pair of `share`-classes. So `LiftableRaw` says exactly:

> every bi-infinite class-sequence realized by a `Step`-path is also realized by a `trans`-path.

That is **language inclusion between two bi-infinite (ℤ-indexed) regular path languages over
finite, eventually-bi-periodic graphs**, which is decidable.

**Why the survey's guessed route is not the argument.** A step-local simulation would ask for a
relation letting the lifting path choose `τ (u+1)` from `τ u` and the observed class. Inclusion
does not require that: `τ` is chosen knowing all of `σ`, including arbitrarily far future and
past. A simulation is therefore *sound but incomplete* — it decides a strictly stronger
predicate, and a plan that discharges O1 "by finite-graph simulation on the periodic index set"
would be proving the wrong theorem. This is an argument from the shape of the quantifiers, not a
machine-checked fact; a probe is recommended in the plan's first phase if the route is taken.

**The complete procedure.**

1. Determinize the `trans` side by subset construction. For a class-sequence `c`, track
   `S_{u+1} = { j : rep (u+1) j = c_{u+1} ∧ ∃ i ∈ S_u, transOf u i j }`. The `−∞` initial set is
   the limit of iterating one full backward period on the finite lattice `2^(Fin n)`, attained
   after at most `2^n` periods since the iteration is monotone on a finite lattice.
2. Pair it with the `Step`-side class automaton and decide emptiness of the product over the
   finitely many time phases (`|repBack| + |repMid| + |repFwd|` of them).
3. Correctness needs one compactness step: a class-sequence has a matching `trans`-path iff every
   finite interval has a matching segment. Mathlib supplies this as
   `nonempty_sections_of_finite_cofiltered_system` (verified present:
   `Mathlib/CategoryTheory/CofilteredSystem.lean`), or it can be done by a direct König argument
   on `Fin n`.

State space `≤ n · 2^n` per phase. So: decidable, exponential in `n`.

**Recommended alternative — do not decide it at all.** The enumerator does not have to enumerate
raw `(rep, trans)` data and then decide `LiftableRaw`. It can enumerate the data *together with a
decidable structural certificate* that implies `lift`. Three such certificates already exist in
the tree:

| Certificate | Location | Hypothesis | Decidable by finite check? |
|---|---|---|---|
| `liftable_of_full` | `Skeleton.lean:332` | `transMat` full at every time | yes (`transMatOf_full` from a listed-matrix check) |
| `liftable_of_spliceClosed` | `Skeleton.lean:483` | `SpliceClosedRaw` + `trans` reflexive | yes — see below |
| `liftable_of_constant_below` / `_above` | `Skeleton.lean:561` / `:594` | discrete on one side of a cut, totally shared on the other | yes |

`SpliceClosedRaw` (`Skeleton.lean:455`) quantifies `∀ u : ℤ` and `∀ v : ℤ`, but both collapse:
the set `{ rep v : v < u }` is finite and computable, because `rep` takes at most
`|repBack| + |repMid| + |repFwd|` distinct values in total. So `SpliceClosedRaw` is decidable by a
finite check over the phases.

**Record for O1**: *`Liftable` is decidable; the decision procedure does not degrade. The
honest residual risk is cost, not computability, and it is O3's risk rather than O1's.*

### F3 — (O2) the general liftable `trans`, and why `transFull` is unavailable

The compression gets to choose `trans`. Three candidate choices, and only one survives.

**`transFull` (free succession) — ruled out.** `liftable_of_transFullOf` discharges `lift` in one
term, which is why every pre-redesign producer uses it. But with `trans` full, (C1')'s `untl` and
`snce` clauses quantify over the whole `share`-class at the arrival time, which is precisely the
pre-redesign reading `PlusWitnessFamily.lean:88-96` records as having made the certificate class
**empty** for instances of `(g S e) → ⊡(g S e)` and `Fp → (¬p → ⊡Fp)`. The cheapest liftability
certificate is unavailable exactly for the targets this task exists to certify. This should be
stated in the plan as a closed option, not left for an implementation phase to rediscover.

**`transId` (no hopping) — recommended.** With `trans u i j ↔ i = j`, a thread never changes
index, so (C1')'s two branching clauses degenerate to one-position conditions and the only
cross-index conditions left are (C0) and (C5). `liftable_of_spliceClosed` then discharges `lift`
provided the index set is splice-closed, and it does so with a **constant** lifting path, whose
only `trans` demand is reflexivity — which `transId` satisfies by `transId_refl`.

This downgrades O2's risk materially. Task 700's F6 read the two landed lifts' use of constant
threads as "the easy case" and predicted the general case would need "a periodicity argument at
the combined window". The periodicity argument is already in the tree: `exists_cofinal_value`
(`Skeleton.lean:461`, `private` to that file, so reached only through the public
`liftable_of_spliceClosed`) is the pigeonhole, and that lemma already composes it with
two-sided splicing to produce the constant lift for an *arbitrary* splice-closed producer. The
remaining obligation is not a new pigeonhole; it is **arranging splice closure by construction**.

**What splice closure costs.** `SpliceClosedRaw` asks: for any two indices naming the same state
at `u`, there is an index copying the first strictly before `u` and the second from `u` on. This
is Emerson–Halpern **fusion closure** (699 Part B's identification), read on the constructed
`rep` data. Two things follow.

- It is a condition on the *combinatorial* datum only, so spliced indices can be added freely at
  the substrate level.
- It is **not** free from the countermodel. `WorldHistory` is a subtype of `PartialHistory`
  (`Semantics/PartialHistory.lean:423`) whose `respects_task` field is stated **unconditionally**
  — for all pairs of times, not only consecutive ones (`PartialHistory.lean:74`). So splicing two
  histories of an arbitrary task frame at a common state does **not** automatically yield a
  history. The label row of a spliced index therefore has to be justified condition by condition
  at the seam rather than inherited from a spliced countermodel history.

**Fallback if the seam obligation proves expensive**: prove `lift` bespoke for the compressed
`trans`, by the subset-construction reasoning of F2 specialized to the constructed data. This is
strictly more work and should be the plan's contingency, not its first phase.

### F4 — (O3) the lasso-count bound is exponential, not `|closure| × window`

This is the finding most likely to change downstream expectations, so the argument is given in
full.

**The demand.** (C5) (`PlusWitnessFamily/Predicates.lean:283-286`):

```
StabFaithful S : ∀ i u φ, stab φ ∈ plusClosureOf (Γ ++ Del) →
  (stab φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u)
```

The `→` direction is what soundness consumes; it is cheap, and it is free if `share` is defined
as agreement of labels on the atoms and `stab`-formulas of the closure, because `⊡` is
state-determined (`PlusLanguage.PlusTruth.stab_state_only`). The `←` direction, contraposed, is
what completeness must supply:

```
stab φ ∉ S.L i u  →  ∃ j, S.share u i j ∧ φ ∉ S.L j u
```

a witness **at that same time `u`**, in the same `share`-class.

**Why `|closure| + 1` does not transfer.** The `Formula`-side bound comes from `PlusBoxFaithful`'s
global shape (`Predicates.lean:202-204`): `bx χ = true ↔ ∀ i t, χ ∈ W.L i t`. A failing box guess
needs *one* witness position, anywhere, so one witness lasso per failing boxed closure member
suffices. (C5) has no such freedom: the witness is pinned to `u`.

**Why `|closure| × window` also does not transfer.** Suppose one adds one witness lasso per
`(φ, u)` pair with `u` ranging over the combined window. Each witness is *itself an index of the
family*. (C5) is quantified over **all** `i`, so each witness index now generates its own demands
at every other window time, against its own `share`-class — and the main lasso need not be in
that class. The construction is a **saturation**, not a one-round count. The survey's `|closure| ×
window` estimate is the first round of that saturation.

**Where the saturation closes, and the resulting bound.** Three facts bound it.

1. The demand is per `share`-class, not per index: `stabFaithful_share_congr`
   (`Predicates.lean:305`) makes the `stab`-labels constant on a class.
2. The demand is periodic: `stabFaithful_iff_window` (`Decide.lean:754`) collapses (C5) to the
   combined window `Finset.Ico (-2·NB) (NM + 2·NF)` (`Window.lean:188-195`), so only
   `W := 2·NB + NM + 2·NF` times matter.
3. The saturation closes at the number of distinct **closure-types**, not at the number of
   closure members, because two indices with the same type row are interchangeable for every one
   of the six conditions.

So the honest closed form is of the order

```
n = lassos.length  ≤  2^|plusClosureOf (Γ ++ Del)|  ×  W  ×  (|stabPart(closure)| + 1)
```

i.e. **singly exponential in `|closure|`**, with `W` a second multiplicative factor. Since
`n = S.lassos.length` by construction (`Basic.lean:222`), the index count and the lasso count are
the same number, so this is simultaneously the substrate width and the lasso-count bound.

**Second cost driver, not previously recorded.** `SharingWindow`'s `NB` and `NF` must be common
multiples of the representative-cycle lengths *and* of every lasso's label-cycle lengths
(`Window.lean:107-113`). If the compression leaves segments at differing lengths, `NB` and `NF`
are a least common multiple over up to `n` lengths, which is super-exponential in the segment
bound. **Mitigation, and it is cheap**: have the compression pad every cycle to one common
length by repetition, so `NB = NF = compressionBound`. The plan should make this an explicit
construction invariant rather than leaving it to emerge.

**Confidence.** The negative half is solid: the `|closure| + 1` accounting provably does not
transfer, for the reason given, and `|closure| × window` provably does not close the saturation.
The positive half — that `2^|closure| × W` is attainable — is an upper bound from the
type-saturation argument, not a proof that no sharper construction exists. It should be recorded
as the working bound and revisited if a phase finds a better one.

### F5 — (O4) product-undecidability does not bound this combination

Task 700 posed O4 and correctly recorded (`notes/01_sequence-addendum.md:53-58`) that 699 Part B
never addressed it: a grep of 699's entire artifact set for GKWZ, "product", or the four authors
returns only Dov Gabbay's irreflexivity rule, which is unrelated. O4 was therefore open. It is
answered here from the source.

**Source and fidelity caveat.** `~/Projects/Literature/sources/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics/`
(758 chunks). `specs/literature-index.json:343-351` flags it
`fidelity: unverified_conversion`, `provenance_fidelity: no_source_pdf`. Theorem numbers and
statements below are cited by the book's own numbering, as that entry's `citation_rule` requires,
but **any statement relied on in a proof must be checked against the source PDF first**.

**The positive results that cover the configuration O4 worried about.**

- **Theorem 6.68** — `L × S5_m` (and `L × KD45_m`) are decidable for `L` among `K_g`, `T`,
  `K4_g`, `S4_g`, `KD45_g`, `S5_g`, `PDL`, `PTL`, `Log{(ℕ,<)}`. This is exactly a linear-time
  factor with *m interacting S5 modalities* — the shape O4 named — and it is decidable.
- **Theorem 6.69** — the same for `L` among `K4.3`, `Log{(ℚ,<)}`, `Lin`, `Log_lin(ℚ)`.
- **Theorem 6.71** — satisfiability for `L × S5₂` is **not in ELEM**; for `PTL × S5₂` this is
  Halpern and Vardi 1989. So the configuration is decidable but non-elementary.

**Where undecidability actually starts**, for the boundary the plan should record:

- **Theorem 8.22** — `L₁ × L₂ × L₃` is undecidable for any Kripke-complete `L_i` with
  `K4(k) ⊆ L_i ⊆ S5`. Three dimensions kill it.
- **Theorem 7.25** — `L × K4` and `L × S4` are undecidable for `L` among `PTL`, `PDL`, `CPDL`,
  and others. A *transitive but not symmetric* second factor kills it.
- **Theorems 7.5, 7.17, 7.19** — products of two linear orders are undecidable.

So the decidable side is reached precisely by the second factor being an equivalence, which is
what both of this repository's modalities are.

**The decisive point: these frames are not product frames.** GKWZ's product frames validate left
and right commutativity and the Church–Rosser property (`chunk_0246`: `com^l = ◇₁◇₂p → ◇₂◇₁p`,
`com^r`, `chr = ◇₁□₂p → □₂◇₁p`), and every undecidability proof in Chapters 7 and 8 encodes a
grid or a tiling using exactly those. Take the 2-frame whose points are `(history σ, time t)`,
with `R₁` temporal within a history and `R_⊡` given by `σ.state t = τ.state t`:

- *Left commutativity fails.* From `(σ,t) R₁ (σ,s) R_⊡ (τ,s)` one would need a `ρ` agreeing with
  `σ` at `t` and equal to `τ`; but `τ` agrees with `σ` only at `s`.
- *Church–Rosser fails.* From `(σ,t) R₁ (σ,s)` and `(σ,t) R_⊡ (τ,t)` one would need
  `σ.state s = τ.state s`, which branching denies.

By contrast the *other* modality **is** product-like: `box φ` is `∀ σ, PlusTruthAt M σ t φ`
(`PlusTruth.lean:88`), so `R_□` is the universal relation on histories at each time, and both
`com` and `chr` hold for `(R₁, R_□)`. That pair is just a linear factor with the universal
modality, and GKWZ's Theorem 6.68 list already contains universal-modality enrichments of the
first factor.

**Answer for the record.** *No GKWZ product-undecidability result bounds this repository's
combination.* The two S5-like modalities are **nested** (`R_⊡ ⊆ R_□`, since `R_□` is universal),
not independent product factors, so they generate no grid; and the stability modal is not in
product position with time at all. The closest product reading, `PTL × S5₂`, is decidable
(Theorem 6.68) though non-elementary (Theorem 6.71). GKWZ §9.1's relativized products —
which `chunk_0441` notes retain commutativity and Church–Rosser only between coordinate 1 and the
others — are the nearest structural analogue and are "decidable and often finitely
axiomatizable". The on-point positive results remain the Ockhamist ones 699 Part B already
recorded: Gurevich–Shelah for Ockhamist validity and Burgess 1980 for Peircean validity.

**The one residual warning worth carrying.** Theorem 6.71's non-elementarity is a *lower bound on
the decision problem itself*, independent of certificate design. It is consistent with, and
corroborates, F4's exponential bound. It does not threaten the compression theorem.

### F6 — Acceptance-gate surfaces, located

- **`docs/theorem-index.md`**: one new row, in the format of line 147 (the `Formula`-side
  compression theorem's row: `| — | statement | fully-qualified name | file | ZTime | pcq
  pinned:C2 |`). Paper label is `—`; this result is formalization-native.
- **`scripts/check-module-invariants.sh`**: two edits, both required or C2 fails.
  1. Add one `#print axioms <new theorem>` line to the `AX_SRC` heredoc (lines 1056-1074).
  2. Add the matching `'<name>' depends on axioms: [propext, Classical.choice, Quot.sound]` line
     to the `AXIOM_BASELINE` heredoc (lines 1033-1052), in the **same order**, since the check is
     a whole-string equality.
  3. Update the pass message at line 1086 from "all eighteen pinned axiom sets" to "nineteen".
     This is easy to miss and does not fail the gate, but leaves the message wrong.

### External Resources

- Gabbay, Kurucz, Wolter and Zakharyaschev, *Many-Dimensional Modal Logics: Theory and
  Applications* (2003). Theorems 6.68, 6.69, 6.71, 7.5, 7.17, 7.19, 7.24, 7.25, 8.22; §5.1
  product axioms; §6.6 products with multimodal S5; §9.1 relativized products. Corpus fidelity
  `unverified_conversion` / `no_source_pdf`.
- Halpern and Vardi 1989, via GKWZ Theorem 6.71, for the non-elementary lower bound on
  `PTL × S5₂`.
- Emerson and Halpern 1986, via 699 Part B, for R-generability = suffix + fusion + limit closure,
  which is what `SpliceClosedRaw` instantiates.
- Mathlib: `nonempty_sections_of_finite_cofiltered_system` (verified present) for the compactness
  step; `Finite.exists_infinite_fiber` (verified present) if a bespoke pigeonhole is needed.

### Recommendations

1. **Take the `transId` + splice-closure route.** Construct the compressed family with
   `trans := transIdOf`, discharge `lift` by `liftable_of_spliceClosed`, and make splice closure
   of the index set a construction invariant. Do not attempt `transFull`.
2. **Do not put a `Decidable (LiftableRaw …)` instance on the critical path.** It is provable but
   exponential and it is not what the compression theorem needs. If the enumerator later needs
   it, add it then, and add it by subset construction rather than by simulation.
3. **Pad all cycle lengths to one common value** in the compression, so the combined window
   periods `NB`, `NF` are the compression bound rather than a least common multiple.
4. **State the bound as exponential in the theorem itself**, not as a commented estimate. A
   theorem carrying `n ≤ f(|closure|)` for an explicit exponential `f` is honest and consumable;
   an unbounded family is not enumerable.
5. **Sequence the plan so (C5) is designed first, not last.** The (C5) saturation determines the
   index count, which determines the lasso list, which determines every other field. Phasing it
   after the lasso construction would mean rebuilding.
6. **Sorry-free throughout.** Nothing in this analysis requires a placeholder or a new axiom.
   Every obligation identified is a finite construction or a bounded induction. If a phase does
   find itself unable to close a goal, the correct response is plan decomposition, not deferral.

## Decisions

- **D1 — O1 is answered YES.** The record should say: `Liftable` is decidable, by bi-infinite
  language inclusion via subset construction, not by simulation. The decision procedure does not
  degrade to a semi-decision procedure. The contingency 700 prepared for ("compression proved,
  procedure still semi-decision") does not arise.
- **D2 — O2 is answered.** The general case is reached through `liftable_of_spliceClosed` with a
  constant lift, not through a new pigeonhole. The construction obligation is splice closure of
  the index set, and the non-trivial part of it is that `WorldHistory.respects_task` is an
  all-pairs condition, so fusion closure is not inherited from the countermodel.
- **D3 — O3 is answered, and the answer is worse than the survey's estimate.** The bound is
  singly exponential in `|closure|`, of the order `2^|closure| × W`. Neither `|closure| + 1` nor
  `|closure| × window` survives. This must be relayed to the paired repository, superseding the
  warning in `specs/archive/700_lplus_completeness_programme_survey/notes/02_cross-repo-handoff.md:68-77`,
  which left `|closure| × window` as the working estimate.
- **D4 — O4 is answered NO.** No GKWZ product-undecidability result bounds this combination, for
  two independent reasons (nesting rather than product position; failure of commutativity and
  Church–Rosser for the stability modal against time). O4 does not change the target.
- **D5 — the `trans_refl` interaction is resolved and is not a blocker.** The unfiled 699 Part A
  follow-on would drop `FormalSystem.Metalogic.Decidability.SharingSkeleton.trans_refl` (and its
  mirror `...PlusSharingWitnessFamily.trans_refl`) as a skeleton-wide field, replacing it with a
  per-producer existential. The recommended route needs `trans` reflexivity only as a hypothesis
  of `liftable_of_spliceClosed`, and supplies it locally from `transId_refl`. So this task's
  construction is compatible with the field either way. **The plan should state its dependency by
  these fully-qualified declaration names and must not invent a task number for the unfiled
  follow-on.**
- **D6 — no `.orchestrator-handoff.json` is written.** This is a research dispatch; the outcome
  is returned through `.return-meta.json` only.

## Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | The splice-closure seam obligation (F3) turns out to be as expensive as a bespoke `lift` proof | Medium-high | Phase the plan so the seam conditions are proved before the rest of the family is built; keep the subset-construction `lift` as a declared contingency rather than discovering it mid-phase |
| R2 | The exponential bound (F4) makes the enumerator impractical even though the theorem is true | Medium | The theorem is the deliverable and remains correct; record the bound honestly in the statement and relay it to the paired repository rather than tuning it silently |
| R3 | The combined window's `NB`/`NF` become a least common multiple over `n` cycle lengths | Medium | Pad all cycles to one length as a construction invariant (Recommendation 3); this is cheap if done from the start and expensive to retrofit |
| R4 | GKWZ theorem numbers cited from an `unverified_conversion` corpus | Low-medium | Check any statement against the source PDF before a proof relies on it; nothing in the recommended construction depends on a GKWZ theorem, only the O4 record does |
| R5 | The subtree is large (F1) and a single implementation dispatch overruns | Medium | Size phases to one agent run each per the plan-format standard; (C5) first (Recommendation 5) |
| R6 | Concurrent siblings (701, 650) touch shared files | Low | Both have undeclared `file_scope`; re-read before editing, stage only this task's hunks, never a directory `git add` |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This round opened no proof goals: the obligations
  were design and decidability questions answered by reading the landed substrate and the
  literature, not by attempting tactics against an open goal. The one place a probe would add
  value — F2's claim that a step-local simulation is incomplete for `LiftableRaw` — is
  recommended above as a first-phase probe rather than attempted here, because it needs a
  constructed counterexample skeleton rather than a tactic call.

## Context Extension Recommendations

- **Topic**: Bi-infinite (ℤ-indexed) regular path languages and their decision procedures.
  **Gap**: `context/project/lean4/` has no note on the subset-construction idiom for
  eventually-bi-periodic path languages, which this repository now needs in at least two places
  (`LiftableRaw`, and any future `Liftable`-deciding enumerator).
  **Recommendation**: add `context/project/logic/domain/biinfinite-path-languages.md` recording
  the phase decomposition, the subset construction, the compactness step and the Mathlib lemma
  that discharges it.
- **Topic**: The product-modal-logic boundary for this repository's modal signature.
  **Gap**: O4's answer is now settled but lives only in this report. A future task asking the
  same question would re-derive it.
  **Recommendation**: add a short `context/project/logic/domain/product-logic-boundary.md`
  recording F5's three bullets — the two S5-like modalities are nested, the stability modal is not
  in product position, and the closest product reading is decidable but non-elementary — with the
  GKWZ theorem numbers and the fidelity caveat.

## Appendix

### Searches and lookups used

- `lean_local_search`: `nonempty_sections_of_finite` (3 hits, both Mathlib lemmas confirmed
  present); `exists_infinite_fiber` (3 hits, `Finite.exists_infinite_fiber` confirmed present).
- Repository greps: `PlusSharingWitnessFamily`, `exists_witnessFamily_of_not_validZTime`,
  `Liftable|liftable`, `trans_refl`, `plusValidZTime_iff_plusValidInt`, `AXIOM_BASELINE`,
  `combinedWindow|def window|structure SharingWindow`, `structure WorldHistory|respects_task`.
- Corpus greps over the GKWZ source: `undecidab`, `PTL.*S5`, `Theorem 7\.[0-9]*\.` + `undecid`,
  `Theorem 8\.[0-9]*\.` + `undecid`, `Church-Rosser|commutativity`.

### Files read

| File | Why |
|---|---|
| `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` | The theorem being mirrored, and Step 0 |
| `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` | `SharingSkeleton`, `LiftableRaw`, the four sufficient conditions, `total_eq_thread` |
| `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Window.lean` | The combined window and the periodicity congruences |
| `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Specialize.lean` | Why the diagonal route cannot serve (C5) |
| `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Basic.lean` | `PlusSharingWitnessFamily`, `n = lassos.length` |
| `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean` | (C1'), (C3), (C4), (C5) and their consequences |
| `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` | `plusTruth_iff_mem`, the `stab` case, `PlusCertifies` |
| `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean` | The (C5) window collapse |
| `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` | The record of why the L⁺ analogue was previously false |
| `FormalSystem/PlusLanguage/PlusTruth.lean` | `PlusTruthAt`'s `box` and `stab` clauses |
| `FormalSystem/Semantics/PartialHistory.lean` | `WorldHistory`, and `respects_task`'s all-pairs form |
| `scripts/check-module-invariants.sh` | The C2 baseline and its heredoc pair |
| `docs/theorem-index.md` | The row format for the new theorem |

### Prior-task material consulted

`specs/archive/700_lplus_completeness_programme_survey/` (report, addendum, cross-repo note,
plan, summary) and `specs/archive/699_invariance_clause_audit_and_ockhamist_grounding/` (report
Parts A and B, proposals) were read in full via a delegated read. The O4 gap 700's addendum
records at `notes/01_sequence-addendum.md:53-58` is confirmed and is closed by F5 above.
