# Research Report 03 — Task 350: Rabinovich Grounding of Remaining Construction + API/File-Division Refactor

- **Task**: 350 — off-diagonal k=1 aggregate quantEndSeg construction and armCorrectness hooks
- **Type**: lean4 (hard mode; `--lit` active, SUBINDEX_PRESENT)
- **Agent**: lean-research-hard-agent
- **Scope**: research only — NO source or plan edits (a separate reviser dispatch consumes this report)
- **Reference tier (H3)**: Tier 1 (literature-backed) — Rabinovich 2014 "A Proof of Kamp's Theorem",
  `/home/benjamin/Projects/Literature/sources/rabinovich_2014/chunk_00NN.md`
- **Driver plan**: `plans/02_offdiag-k1-aggregate-discharge.md` (Phases 11-17 remaining; 10b-ii units 2+ pending)
- **Citation rule (from sub-index hazard note)**: cite the PDF **by chunk / paper page**, never the
  paraphrase `md:NN` lines. Displayed equations are dropped in the text extract, so equation *shapes*
  below are reconstructed from surrounding prose + the codebase's landed forms and flagged where the
  extract is lossy.

---

## 1. Rabinovich Decomposition of the Remaining Construction

Each remaining construction is mapped to its exact Rabinovich anchor with the load-bearing statement
quoted from the chunk. The paper's Section 5 (Prop 4.2 / Lemma 5.1 / 5.3 / Cor 5.4) grounds the
negation stack; Section 7 (Lemmas 7.6, 7.8, 7.10, Def 7.13) grounds the exterior *navigated*
carriers and the past→future mirror. **Section 7 is the strongest and currently under-cited anchor
for the exterior work** — see §1.5 and §2.

### 1.1 `negFix` general recursion (Phase 10b-ii units 2+) — Lemma 5.1, Cases 1-3 + A_i/B_i split (chunk_0015 / _0016 / _0017)

Rabinovich Lemma 5.1 (chunk_0013): "The negation of any formula of the form … where α_i, β_i are
quantifier free, is equivalent (over Dedekind complete chains) to a disjunction of →∃∀-formulas."
Notation 5.2 abbreviates the fixed formula as `[α0, β1, …, αn−1, βn, αn](z0, z1)`.

The proof (chunk_0015) splits on three cases, and — critically for the codebase's gate design —
**the case conditions ride into the disjuncts** (chunk_0016): "For each of these cases we construct a
∨→∃∀ formula `Cond_i` … and show that if `Cond_i` holds, then ¬[…] is equivalent to a ∨→∃∀ formula
`Form_i`. Hence ¬[…] is equivalent to `∨_i [Cond_i ∧ Form_i]`."

- **Case 1** (chunk_0015/_0016): `¬α0(z0) ∨ K⁺(¬β1)(z0)` → `Form_1 = True`. "already explicitly
  described by the ∨→∃∀ formula … equivalent to True."
- **Case 2** (chunk_0016): `α0(z0) ∧ (∀z ∈ (z0,z1)) β1`. Then ¬[…] ≡ "there is no z ∈ (z0,z1) such
  that `[α1, β2, …, βn, αn](z, z1)`. **By Corollary 5.4(2)** this is expressible by a ∨→∃∀ formula."
- **Case 3** (chunk_0016): `α0(z0) ∧ ¬K⁺(¬β1)(z0) ∧ (∃x ∈ (z0,z1)) ¬β1(x)`. The pin is
  `r0 = inf{z ∈ (z0,z1) | ¬β1(z)}`, definable by `INF^{¬β1}(z0, z, z1)` (eq. 5.3, chunk_0016). The
  negation reduces (chunk_0017) via an **A_i/B_i split at r0** with the boundary simplifications
  (a)-(e), proved by induction on n on **strictly smaller brackets**, glued by conjunction/∃-closure.

**Verification of the plan's `A_i/B_i pin split` faithfulness (chunk_0017 — explicitly requested).**
chunk_0017 states the split ingredients exactly: `(a): ¬A_i` is ∨→∃∀ for `i = 1..n`; `(b): ¬B_i` is
∨→∃∀ for `i = 2..n`, with `B1 := B1⁻ ∧ B1⁺` and `Bn+1 := Bn+1⁻ ∧ Bn+1⁺`; `(c): ¬B1⁻` and `¬Bn+1⁺` by
the induction basis; `(d): INF^{¬β1}(z) ∧ ¬B1⁺(z,z1) ≡ INF^{¬β1}(z)` ("if `INF^{¬β1}(z)` then for no
`x>z` does `β1` hold along `[z,x)`"); `(e): INF^{¬β1}(z) ∧ ¬Bn+1⁻(z0,z) ≡ INF^{¬β1}(z) ∧ (β1 holds on
(z0,z) ∧ ¬Bn+1⁻(z0,z))`. The closure of ∨→∃∀ under ∧/∨/∃ (Lemma 3.4) then finishes.
**Verdict: the plan's design-note-2 characterization is FAITHFUL** — `bf.holds ⟺ ∨_i A_i(r0) ∨ ∨_i
B_i(r0)` (r0 = i-th witness / r0 interior to segment i), negation = conjunction of `¬A_i`/`¬B_i^±` by
IH on strictly smaller brackets, glued via a pinned-concatenation builder + `conjFull` + the (d)/(e)
simplifications. One nuance to preserve (below): `B_i` factors as `Bi⁻ ∧ Bi⁺` (a left/right product
across the pin), so `¬B_i = ¬Bi⁻ ∨ ¬Bi⁺` — the negation is a **disjunction over the two sides**, and
the concatPin builder must handle each side, with (d)/(e) collapsing the pin-adjacent factor.

- **Lean target**: `BracketFormula.negFix` + `negFix_iff` (EANegationFix.lean, Phase 10b-ii).
  Case 2 already re-routed (Phase 10b-i, landed) to the **anchored** `negBoundedLeftFixAnchored`
  (the moving-left-endpoint `(z,z1)` form = Cor 5.4(2)); Case 3 gluing = landed `concatPin`
  (Phase 10b-ii unit 1). Templates = landed `negFixOne` (n=1) shapes {A, B1, B2, B3, B4, B4′}.
- **G5 note**: chunk_0016's `Cond_i` gates are the reason the gate-free 4-list is ℤ-refuted
  (landed `NegFixGateProbe.caseB4_holds`); keep the manual bridges.

### 1.2 De Morgan fold `VecEA2/VVecEA2.negFix` (Phase 11) — Prop 4.2 / Prop 4.3 (chunk_0012)

Prop 4.2 (chunk_0012): "The negation of →∃∀-formulas with at most two free variables is equivalent
over Dedekind complete chains to a disjunction of →∃∀-formulas." Prop 4.3's negation step is the
De Morgan fold itself: "If ϕ is a disjunction of →∃∀ formulas ϕ_i, then ¬ϕ is equivalent to the
**conjunction of ¬ϕ_i**. … Since ∨→∃∀ formulas are closed under conjunction (Lemma 3.4), we obtain
that ¬ϕ is equivalent to a disjunction of →∃∀ formulas."

- This is precisely `VVecEA2.negFix := foldr VVecEA2.conjFull` over the per-disjunct `VecEA2.negFix`.
- `VecEA2.negFix` per-disjunct 3-way split `¬el ∨ ¬er ∨ ¬bracket` is the Lemma 3.2(2) two-free-var
  split (chunk_0009 Lemma 3.2(2): "Every →∃∀-formula is equivalent to a conjunction of →∃∀-formulas
  with at most two free variables") composed with Prop 4.2 per conjunct. The endpoint legs `¬el`/`¬er`
  are one-free-variable negations (atomic in the canonical TL expansion — chunk_0011); the bracket leg
  is `BracketFormula.negFix` (§1.1). **Anchor is exact and already correctly cited in the plan table.**

### 1.3 Point-channel merges (0,1)/(0,2) (Phase 12) — Lemma 3.2(2) collapse (chunk_0009)

The w=x and w=t channels collapse a free anchor onto another via `renameNF` + the landed gated
`agg_rename_fixpoint_of_eval`. Rabinovich grounding is Lemma 3.2(2)'s "at most two free variables"
reduction (chunk_0009): when the witness coincides with an anchor, the arity-3 env `[w,x,t]` collapses
to the fixed-anchor `nf_eval_nf M 1 2 [x,t]`, characterized by the landed depth-1 fold. This is a
**codebase-mechanical** step, not a distinct paper lemma; the paper anchor is the tie-collapse forced
by Def 3.1 (sub-index known-correction: "coincident witnesses merge to one slot whose type is the
CONJUNCTION of the tied types"). **Verdict: correctly grounded; Lemma 3.2(2) is the right anchor,
not Cor 5.4.**

### 1.4 The final `aggPop1` assembly + `kampArm_{past,future}_k1` (Phase 16) — Cor 5.4 "all order patterns" + Lemma 3.4 closure

`aggPop1 = foldr VVecEA2.conjFull` over `Finset.univ`, `negFix` on bit-false qnf, is the population
match: for every qnf, `(∃w, nf_eval …) ↔ sub_nf.2 qnf`. The conjunction-of-per-qnf-clauses is
Lemma 3.4 closure under ∧ (chunk_0010); the per-qnf clause for a *present* qnf is a positive ∨→∃∀
(the carrier), for an *absent* qnf its `negFix` (Prop 4.2). The arm wrapper
`translateRight/Left` supplies the `∃x, x<t ∧ …` navigation = one-free-variable existential closure
(Lemma 3.4 closure under ∃, chunk_0010). **Anchor exact.**

### 1.5 Exterior navigated carriers (Phases 13-15) — Section 7: Lemma 7.6 (gluing), Lemma 7.10 / Prop 3.5 (fold), Lemma 7.8 (past/future mirror)

This is the piece whose plan citation ("Prop 3.5 device") is **weakest and should be strengthened**.
The exterior construction has three distinct paper ingredients, all in Section 7:

1. **The one-free-variable fold to a single `TemporalPred`** (the `endpointLeft`/`endpointRight` at x
   / t). Prop 3.5 (chunk_0010): "Every →∃∀-formula with one free variable is equivalent to a
   TL(Until, Since) formula … Let A_i, B_i be temporal formulas equivalent to α_i, β_i … ψ is
   equivalent to the conjunction of …". Lemma 7.10 (chunk_0023) is the one-sided `(z0, ∞)` version:
   "`[α0, β1, …, αn, βn+1](z0, ∞)` over canonical TL(Until,K⁻)-expansions is equivalent to a
   TL(Until,K⁻) formula. Proof: by a straightforward formalization as in Proposition 3.5." **This is
   the exact device** that folds the w-dependent fibers (atoms at w; zones v<w, v=w, w<v<x) into one
   navigated predicate at x.
2. **The ∃w gluing across the pin at x** — Lemma 7.6 (chunk_0021, currently UNCITED by the plan):
   "If ϕ1 is a (z0,z1)-∨→∃∀ formula and ϕ2 is a (z1,z2)-∨→∃∀ formula, then `(∃z1)_{z0}^{z2}(ϕ1 ∧ ϕ2)`
   is a (z0,z2)-∨→∃∀ formula." This is precisely the "distribute the w-independent parts out of the
   ∃w, glue the w-package to the (x,t) content at the pin x" move. Def 7.13 (chunk_0023) gives the
   multi-anchor `(z0, z1, …, zk, ∞)-∨→∃∀` conjunction form the carrier lives in.
3. **The past→future mirror** — Lemma 7.8 (chunk_0022): "(1) ¬[…](z0,z1) is equivalent over the
   canonical **TL(Since, K⁺)**-expansions … to a (z0,z1)-∨→∃∀-formula. (2) Dually … over the
   canonical **TL(Until, K⁻)**-expansions …". chunk_0023: "In the proof of Cor 5.4(1) we used
   Lemma 5.3 and **Until** modality … Cor 5.4(2) is dual and holds for **Since,K⁺**-expansions."
   → **past-exterior (w<x) = Since-navigated (TL(Since,K⁺), Lemma 7.8(1)); future-exterior (t<w) =
   Until-navigated (TL(Until,K⁻), Lemma 7.8(2))**. The mirror in Phases 13-15 is exactly this duality;
   citing Lemma 7.8 makes "the Since/Until navigation" a named, page-anchored claim rather than an
   informal one.

**Recommendation to the reviser**: add Lemma 7.6, 7.8, 7.10 (chunks 0021-0023) to the H3 mapping
table row for Phases 13-15, replacing the bare "Prop 3.5 device / Lemma 3.2(2)+Prop 3.5" entry.

### 1.6 Cleaner-source note

No alternate source is *cleaner* than Rabinovich for any remaining piece — Rabinovich is the
constructive proof the codebase transcribes. Gabbay-Hodkinson-Reynolds separation (chunk_0018) and
Hodkinson's game proof [6] (chunk_0019) are **less** suitable: they use "unusual back-and-forth
games" / "complicated inductive assertions" (chunk_0019) and separation transformations that "contain
many rules … not easy to follow" over Dedekind-complete chains (chunk_0018). Kamp's thesis [8]
(">100 pages", chunk_0018) is background only. Keep Rabinovich as the single ground truth.

---

## 2. Exterior-Carrier Structure (the ~1,500-line chunk) — 6 named sub-lemmas, dependency-ordered

Decomposition of Phases 13-15 following Rabinovich Section 7 (Lemma 7.10 fold, Lemma 7.6 gluing,
Lemma 7.8 duality). Each sub-lemma is one bounded dispatch. Names are proposals.

| # | Sub-lemma | Statement shape | Rabinovich anchor | Depends on | Est. lines |
|---|-----------|-----------------|-------------------|-----------|-----------|
| **E1** | `extZoneFiber_k1` (fiber kit) | `nf_eval_depth1_fold_iff` at n=3, env `[w,x,t]`, partitions the depth-1 layer into monadic clauses over the 7 order-consistent zones of w<x<t (`v<w, v=w, w<v<x, v=x, x<v<t, v=t, t<v`); + `extZone_consistent_*` falsity for inconsistent order channels | Lemma 3.2(2) split (chunk_0009); Def 7.13 multi-anchor form (chunk_0023) | landed `nf_eval_depth1_fold_iff`, `agg2_zone_consistent_*` | ~250-350 |
| **E2** | `navPackLeft` (Since-navigated w-package) | folds the w-dependent fibers (atoms at w; zones v<w, v=w, w<v<x) into a single `endpointLeft : TemporalPred` at x; bit-true inner fibers = arrangement slots in the fold, bit-false = exclusion segments / negated Since-lits | **Lemma 7.10 / Prop 3.5** one-free-var fold to TL(Since,K⁺) (chunks 0010, 0023) | E1 | ~300-400 |
| **E3** | `navDistribLeft` (w-independent distribution) | `v=x char → endpointLeft conjunct`; `x<v<t fibers → (x,t) bracket slots + exclusion segment`; `v=t, t<v, atoms at t → endpointRight` — the peeling that avoids both refutations (no joint-depth-1 re-fibering; no single predicate carrying t-reads) | Lemma 7.6 gluing decomposition (chunk_0021) | E1, E2 | ~200-300 |
| **E4** | `CExtPast(_correct)` (past carrier + iff) | `(CExtPast qnf).holds M atomMap x t ↔ ∃ w, w < x ∧ nf_eval_nf M 1 3 [w,x,t] qnf` under `x<t`; the **∃w glue across the pin at x** | **Lemma 7.6** `(∃z1)(ϕ1∧ϕ2)` closure (chunk_0021); Lemma 7.8(1) TL(Since,K⁺) (chunk_0022) | E2, E3; may consume Phase-11 `negFix` for bit-false inner fibers | ~300-400 |
| **E5** | `CExtFut(_correct)` (future mirror) | `t<w` channel: Until-navigated `navPackRight`/`navDistribRight` + `CExtFut` + iff (mirror statement) | Lemma 7.8(2) TL(Until,K⁻) duality (chunk_0022) | E4 (mirror), E1 | ~350-450 |
| **E6** | `extDuality` (optional shared duality) | a genuine order-reversal lemma so E5 consumes E1-E4 by duality rather than duplicating; land ONLY if a clean `M`-reversal is available, else E5 duplicates the shapes | Lemma 7.8 "dual … proved similarly" (chunk_0022) | E1-E4 | ~100-200 (or 0) |

**Adjudication gate (R3, unchanged from plan)**: E1 must land the single-fiber probe (one bit-true +
one bit-false inner fiber, one concrete qnf, end-to-end) BEFORE E2 generalizes; on failure mark
[BLOCKED] with the exact fiber + qnf pattern. **Dependency order: E1 → E2 → E3 → E4 → E5 (→ E6).**

---

## 3. File-Division / API Refactor

### 3.1 `EANegationFix.lean` (2,237 ln, still growing by ~1,000+ for negFix recursion + De Morgan fold)

The file's own `/-! -/` section headers already mark clean, import-linear seams (verified). Downstream
it has **exactly one consumer**: `NfMultiAnchorBridge.lean` line 78 (one import line). The import DAG
is linear: `VecEAClosure → {VecEAConjFull, EANegation, EANegationClosure} → EANegationFix`. This makes
a split **zero-churn**: relocate declarations into a subdirectory and leave `EANegationFix.lean` as a
thin re-export shim that `import`s all leaves — the aggregator line and every proof stay unchanged.

**Proposed split** (new `Kamp/EANegationFix/` subdirectory; current line ranges → new files):

| New file | Exports (current EANegationFix line range) | Rabinovich layer | Imports |
|----------|--------------------------------------------|------------------|---------|
| `EANegationFix/OnBuilder.lean` | witness-combination kit + `negChainOn(_iff)` (56-253) | Lemma 5.3 (chunk_0014) | `VecEAConjFull`, `EANegation`, `EANegationClosure` |
| `EANegationFix/BoundedFix.lean` | temporal-pred Until/Since builders, `chainAllTrue`, Until/Since folds, list-form bracket bridges, `negBounded{Right,Left}Fix(_iff)` (254-1102) | Cor 5.4(1)/(2) (chunks 0014-0015) | `OnBuilder` |
| `EANegationFix/BoundedFixAnchored.lean` | anchored folds + `negBounded{Right,Left}FixAnchored(_iff)` (1103-1577) | Cor 5.4 anchored (Case 2 consumer, chunk_0016) | `BoundedFix` |
| `EANegationFix/ConcatPin.lean` | `bracketOf_append_pin_holds_iff`, `BracketFormula.concatPin(_holds_iff)`, `VBracketFormula.concatPin(_holds_iff)` (1578-1689) | Lemma 7.6 gluing / Case-3 pin (chunks 0017, 0021) | `BoundedFix` |
| `EANegationFix/NegFixOne.lean` | n=1 instance `bracketOne`, `negFix1*`, `negFixOne_cover/_iff`, `NegFixGateProbe.*` ℤ counterexample (1690-2236) | Lemma 5.1 n=1 + gate necessity (chunks 0015-0016) | `BoundedFixAnchored`, `ConcatPin` |
| `EANegationFix/NegFix.lean` | **(pending)** general `BracketFormula.negFix(_iff)` recursion, Cases 1-3, A_i/B_i split, (d)/(e) | Lemma 5.1 full (chunks 0016-0017) | `NegFixOne`, `ConcatPin`, `BoundedFixAnchored`, `VecEAConjFull` |
| `EANegationFix/VecEANegFix.lean` | **(pending)** `VecEA2.negFix`, `VVecEA2.negFix(_iff)` De Morgan fold | Prop 4.2 / 4.3 (chunk_0012) | `NegFix`, `VecEAConjFull` |
| `EANegationFix.lean` (**shim**) | `import`s all seven leaves above; keeps the namespace | — | all leaves |

**Import DAG (acyclic, linear)**:
`OnBuilder → BoundedFix → {BoundedFixAnchored, ConcatPin} → NegFixOne → NegFix → VecEANegFix →
(shim) EANegationFix → NfMultiAnchorBridge`.

**Cyclic-import risk: NONE**, provided (a) the shim is import-only (leaves never import the shim), and
(b) no `EANegationFix/*` leaf imports any `NfMultiAnchorBridge/*` aggregate module — the negation kit
is order-generic and must stay upstream of the aggregate carriers. E4's "may consume Phase-11 negFix
for bit-false inner fibers" respects this (aggregate imports negation, never the reverse).

**Sequencing constraint (H8-critical)**: apply this split as its **own mechanical phase (R1) BEFORE**
landing the pending `NegFix.lean` / `VecEANegFix.lean` content — otherwise those ~1,000 lines land into
an already-2,237-line file and the split becomes a larger move later. The split as-scoped is a pure
relocation of already-green, sorry-free proofs (no proof rewriting), satisfying the "do not rewrite
landed proofs beyond moving them" constraint.

### 3.2 Exterior-carrier files (Phases 13-15, not yet written)

Because these files do not yet exist, build them **directly as a small DAG** (no move cost) rather than
one `AggregateExteriorK1.lean` that would reach ~1,500 lines:

| File | Exports | Imports |
|------|---------|---------|
| `NfMultiAnchorBridge/ExteriorFiberKitK1.lean` | E1 (zone fibering + consistency falsity) | `AggregateHookDischarge`, `CarrierKv` |
| `NfMultiAnchorBridge/ExteriorNavPastK1.lean` | E2/E3/E4 (Since-navigated past carrier) | `ExteriorFiberKitK1`, `EANegationFix` (shim) |
| `NfMultiAnchorBridge/ExteriorNavFutK1.lean` | E5 (Until-navigated future mirror) + optional E6 | `ExteriorNavPastK1` |

Cyclic risk: none (all import upstream negation/aggregate leaves only).

### 3.3 Naming convention (for a consistent API surface)

- **Directory placement**: order-generic VecEA/negation kit lives directly under `Kamp/`; anchor-bridge
  / aggregate carriers under `Kamp/NfMultiAnchorBridge/`. (Matches the existing split.)
- **Rabinovich-lemma-named modules**: negation-stack files named for their paper layer (`OnBuilder`
  = Lemma 5.3, `BoundedFix` = Cor 5.4, `NegFix` = Lemma 5.1, `VecEANegFix` = Prop 4.2). Keep the
  established identifier style: `<object>Fix` for fixed-formula negations, `_iff` for the biconditional,
  `Anchored` suffix for the moving-endpoint α-parametrized variants, `negChain*`/`negBounded*`/`negFix*`
  prefixes preserved (all already landed under these names — do not rename).
- **Exterior carriers**: `CExtPast`/`CExtFut` for the per-qnf carriers; `navPack{Left,Right}` /
  `navDistrib{Left,Right}` / `extZoneFiber` for the internal kit, mirroring the delivered `agg2*` house
  style. `_correct` for carrier iffs.
- **Frozen files are OUT OF SCOPE for any refactor**: `SharedWitness.lean` (12,800 ln), `SubBracket2V`,
  `OuterGate`, `ExteriorBracket`, `ExteriorZoneTriage`, `ExteriorNegation(K)`, `ExteriorNegationPast(K)`
  (G6/frozen). `SharedWitness.lean` being the single largest file is a separate, later concern —
  **not** task 350's territory (it carries the 89 known-dangling citations noted in the sub-index).

---

## 4. Phase Re-Division Recommendation (feeds a plan revision)

Re-cut of Phases 11-17 into H8-sized units (~100-500 output lines each; one bounded dispatch per unit),
interleaving the two refactor phases. `10b-ii-2` = the currently-pending negFix general recursion.

| Phase | One-line goal | Target file | Est. lines | Depends on | Rabinovich anchor |
|-------|---------------|-------------|-----------:|-----------|-------------------|
| **10b-ii-2** | `BracketFormula.negFix` recursion Cases 1-3 + A_i/B_i split + (d)/(e) + `negFix_iff` | `EANegationFix.lean` (pre-split) OR `EANegationFix/NegFix.lean` (post-R1) | ~500-700 (declare seam: 10b-ii-2a Cases 1-2, 2b Case 3+iff) | landed 10b-i, 10b-ii-1 | Lemma 5.1 (chunks 0016-0017) |
| **R1 (refactor)** | Pure move: split `EANegationFix.lean` → `EANegationFix/` DAG + re-export shim | 7 new leaves + shim | ~0 net (relocate ~2,900 ln) | 10b-ii-2 landed green | §3.1 |
| **11** | `VecEA2.negFix` + `VVecEA2.negFix(_iff)` De Morgan fold | `EANegationFix/VecEANegFix.lean` | ~200-300 | R1 | Prop 4.2/4.3 (chunk_0012) |
| **12a** | point-channel merge variant (0,1), carrier + iff | `AggregatePointMergeK1.lean` (new) | ~200-350 | (wave-1, parallel) | Lemma 3.2(2) (chunk_0009) |
| **12b** | point-channel merge variant (0,2), carrier + iff | `AggregatePointMergeK1.lean` | ~200-350 | 12a | Lemma 3.2(2) (chunk_0009) |
| **13 (E1)** | 7-zone fiber kit + single-fiber R3 probe + consistency falsity | `ExteriorFiberKitK1.lean` (new) | ~250-350 | 11 | Lemma 3.2(2), Def 7.13 (chunks 0009, 0023) |
| **14a (E2)** | Since-navigated w-package `navPackLeft` | `ExteriorNavPastK1.lean` (new) | ~300-400 | 13 | Lemma 7.10 / Prop 3.5 (chunks 0010, 0023) |
| **14b (E3)** | w-independent distribution `navDistribLeft` | `ExteriorNavPastK1.lean` | ~200-300 | 14a | Lemma 7.6 (chunk 0021) |
| **14c (E4)** | `CExtPast(_correct)` + ∃w pin glue + 3-bot falsity | `ExteriorNavPastK1.lean` | ~300-400 | 14b | Lemma 7.6, 7.8(1) (chunks 0021-0022) |
| **15 (E5)** | future mirror `CExtFut(_correct)` (Until-navigated) + optional `extDuality` | `ExteriorNavFutK1.lean` (new) | ~350-450 (seam: 15a package, 15b carrier) | 14c | Lemma 7.8(2) (chunk 0022) |
| **R2 (optional)** | if exterior files overran, no move needed (already split by 3.2); fold into 13-15 | — | 0 | — | §3.2 |
| **16a** | zone-classifier totality (arity 3) + per-qnf dispatcher `C(qnf)` + clause iff | `AggregateOffDiagK1.lean` (new) | ~300-400 | 11, 12b, 15 | Cor 5.4 all-patterns (chunks 0014-0015) |
| **16b** | `aggPop1(_correct)` conjFull-fold + `kampArm_{past,future}_k1(_correct)` + shape certs | `AggregateOffDiagK1.lean` | ~250-400 | 16a | Lemma 3.4 closure (chunk 0010) |
| **17** | full-DoD audit (6 lemmas), guard/axiom checks, Base.lean doc-hooks, summary | `Base.lean` (docstring), summary | ~audit | 16b | — |

**Net change vs. plan v2**: inserts **R1** (the negation-kit split) between the negFix recursion and
the De Morgan fold; retargets Phases 11/13-15 onto the new file DAG (§3.1/§3.2); pre-splits 12/14/15/16
at declared seams; and upgrades the Phase 13-15 Rabinovich anchor from "Prop 3.5 device" to the named
Section-7 lemmas (7.6 / 7.8 / 7.10). R1 is a mechanical move phase (H9-friendly: green before, green
after, no proof edits).

---

## Adversarial Self-Verification (H4)

Re-read the draft with adversarial mandate; every load-bearing Rabinovich mapping and refactor claim
checked against the actual chunk or a codebase fact.

### Claim Verification Table

| Claim | Source / Counterexample | Verification method | Verdict |
|-------|-------------------------|---------------------|---------|
| Lemma 5.1 negation output is `∨_i [Cond_i ∧ Form_i]` (gates ride in) | chunk_0016: "equivalent to `∨_i [Cond_i ∧ Form_i] which is a ∨→∃∀ formula`" | direct quote | **High** |
| Case 2 of Lemma 5.1 is discharged by **Cor 5.4(2)** (not 5.4(1)) | chunk_0016 Case 2: "By Corollary 5.4(2) this is expressible" | direct quote | **High** |
| A_i/B_i pin split (plan design-note-2) is faithful; `B_i = Bi⁻ ∧ Bi⁺`, negation splits over sides, (d)/(e) collapse pin factor | chunk_0017 (a)-(e), "B1 := B1⁻ ∧ B1⁺ and Bn+1 := Bn+1⁻ ∧ Bn+1⁺" | direct quote of (a)-(e) | **High** (nuance surfaced: `¬B_i` is a two-sided disjunction) |
| De Morgan fold = conjunction of per-disjunct negations via Lemma 3.4 | chunk_0012: "¬ϕ ≡ conjunction of ¬ϕ_i … closed under conjunction (Lemma 3.4)" | direct quote | **High** |
| Point merges (0,1)/(0,2) anchor is Lemma 3.2(2), not Cor 5.4 | chunk_0009 Lemma 3.2(2) "at most two free variables"; plan table already lists 3.2(2)+3.5 | quote + plan cross-check | **High** |
| Exterior `endpointLeft/Right` fold = Prop 3.5 / Lemma 7.10 one-free-var → TL | chunk_0010 Prop 3.5; chunk_0023 Lemma 7.10 "as in the proof of Proposition 3.5" | direct quote | **High** |
| Exterior ∃w gluing across pin x = **Lemma 7.6** `(∃z1)(ϕ1∧ϕ2)` closure (currently uncited by plan) | chunk_0021 Lemma 7.6 verbatim | direct quote; grep of plan shows no 7.6 citation | **High** (this is the report's main grounding upgrade) |
| past-exterior = Since/TL(Since,K⁺) [Lemma 7.8(1)]; future-exterior = Until/TL(Until,K⁻) [7.8(2)] | chunk_0022 Lemma 7.8(1)/(2); chunk_0023 "Cor 5.4(1) used Until … 5.4(2) is dual … Since,K⁺" | direct quote | **High** |
| `EANegationFix.lean` has exactly one downstream consumer (one import line) | `grep -rln Kamp.EANegationFix` → only `NfMultiAnchorBridge.lean:78` | `lean_local_search`-class grep hit | **High** |
| Import DAG is linear/acyclic; split is zero-churn; shim keeps aggregator line unchanged | grep of imports for VecEAConjFull/EANegation/EANegationClosure/EANegationFix | grep of `^import` lines in each file | **High** |
| Section-header line ranges (56/125/254/1103/1578/1690/2046) map to the proposed leaves | `grep -nE "^/-! "` on EANegationFix.lean | direct grep output | **High** |
| Rabinovich is the cleanest source; GHR-separation / Hodkinson-game are messier | chunk_0018 "many rules … not easy to follow"; chunk_0019 "unusual back-and-forth games" | direct quote | **High** |
| `SharedWitness.lean` (12,800 ln) is the biggest file but out of task-350 scope | plan Non-Goals (frozen list) + sub-index hazard note (89 dangling cites there) | plan + sub-index cross-check | **High** |

### Could-not-ground / flagged mappings

- **Displayed-equation shapes are extract-lossy.** The text extract drops every displayed formula
  (sub-index hazard note; e.g. Def 3.1 / Lemma 5.1 read "of the form:" then blank; eq. 5.3 `INF^{¬β1}`
  is partially mangled as `INF ¬β1(z0,z,z1)`). I ground each construction on the **surrounding prose +
  the landed Lean form**, which agree, but the *exact quantifier decorations* of `[α0,β1,…](z0,z1)` and
  `INF^{¬β1}` cannot be lifted verbatim from the extract — the implementer must read the PDF
  (`Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`) for the precise displayed equations before encoding
  Case-3's `INF^{¬β1}` gate. Flagged as **Medium confidence on equation typography only**; the
  structural mappings above are High.
- **E6 `extDuality`** is proposed as *optional* precisely because I could not confirm a clean
  order-reversal lemma exists in the codebase for `M`; chunk_0022 only says the dual is "proved
  similarly", which in Lean often means duplication rather than a reusable duality. Left as a
  land-if-available with duplication fallback — **not asserted as groundable**.
- **`renameNF` gated-collapse mechanism for (0,1)/(0,2)** rests on the landed
  `agg_rename_fixpoint_of_eval` being rename-generic; I did not re-open that proof this dispatch, so the
  "same technique, new instances" claim is **Medium** (inherited from plan/report-02, not
  re-verified here).

No contradictions found between the chunks and the plan's mappings; the only *additions* are the
Section-7 lemma upgrades (7.6/7.8/7.10) for the exterior carriers, which strengthen rather than
contradict the existing "Prop 3.5 device" citation.

---

## Memory Candidates

1. Rabinovich 2014's exterior/navigated carrier machinery is grounded in **Section 7** (Lemma 7.6
   gluing `(∃z1)(ϕ1∧ϕ2)`, Lemma 7.8 Since/Until duality, Lemma 7.10 one-sided fold), not just Prop 3.5
   — the navigated-fold + pin-glue pattern for any `∃w` exterior carrier should cite 7.6/7.8/7.10.
2. When a growing Lean kit file has a **single downstream import**, splitting it into a subdirectory DAG
   with a re-export shim is zero-churn — apply the split as its own mechanical phase BEFORE landing the
   next large tranche, not after.

## Report Metadata

- **Report path**: `specs/350_.../reports/03_rabinovich-grounding-and-api-division.md`
- **Chunks read (ground truth)**: rabinovich_2014 chunks 0009-0023.
- **Files inspected (structure only, no edits)**: `EANegationFix.lean` (section headers, imports),
  `NfMultiAnchorBridge.lean` (import block), Kamp dir `wc -l`, plan v2 (full).
- **Verdict**: all remaining constructions grounded to specific Rabinovich lemmas; exterior anchor
  upgraded; refactor is zero-churn and cycle-free; phase table re-cut to H8 sizes with R1 inserted.
