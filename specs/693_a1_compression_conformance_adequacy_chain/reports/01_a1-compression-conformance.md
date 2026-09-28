# Research Report: A1 Compression Conformance Against the Bimodal Adequacy Chain

- **Task**: 693 - A1 compression conformance adequacy chain
- **Started**: 2026-09-28T00:00:00Z
- **Completed**: 2026-09-28T00:00:00Z
- **Effort**: ~3 hours (research only)
- **Dependencies**: None blocking. Concurrent sibling task 685 owns
  `FormalSystem/Metalogic/Decidability/WitnessFamily/{Decide,Closure,README.md}`,
  `WitnessFamily.lean` and `docs/theorem-index.md`; this research read those files and wrote none.
- **Sources/Inputs**:
  - Upstream (read-only, not edited):
    `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`
    (certificate section 1, ADEQ section 7, section 7.1, section 7.3),
    `.../docs/TRUST_PIPELINE.md` (A-component table, "What remains" tables),
    `.../bimodal/examples.py` (countermodel example inventory)
  - This repository: `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/`
    (`Types`, `Cycle`, `Fulfil`, `Extract`, `Family`, `Enumerate`, `Assembly`, `README.md`),
    `WitnessFamily/{Basic,Predicates,Agreement,Decide}.lean`,
    `FormalSystem/Semantics/{Validity,IntTransfer}.lean`, `FormalSystem/Syntax/Atom.lean`,
    `lakefile.toml`, `scripts/lean-citation-seeds.txt`, `scripts/lean-citation-manifest.json`,
    `scripts/export-lean-citations.py`, `scripts/check-module-invariants.sh` (C35)
  - Tooling: `lean_verify` (axiom closure), `lean_run_code` (`rfl` check and `#eval`),
    `scripts/export-lean-citations.py --seeds <scratch> --stdout` (seed-resolution dry run)
- **Artifacts**:
  - `specs/693_a1_compression_conformance_adequacy_chain/reports/01_a1-compression-conformance.md`
- **Standards**: report-format.md, subagent-return.md, status-markers.md

## Executive Summary

- **Verdict on A1: NOT discharged as the chain consumes it, but no longer "route named, not
  built".** `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime` proves
  A1's full content — including the `f(|C|)` bound and the main-lasso-carries-the-refuting-point
  clause — for the **empty-premise, single-conclusion** instance only. The upstream row's text is
  now factually wrong in both directions: the route *is* built, and A1 is *not* open in the sense
  of "unattempted".
- **Certificate notions agree exactly.** `WitnessFamily.Certifies` is
  `LocalCoherentLab ∧ FulfillingLab ∧ BoxFaithful ∧ Target t`, and each conjunct matches upstream
  (C1)/(C2)/(C3)/(C4) clause for clause — same guards, same biconditionals, same unconstrained
  atoms, same `L₀`-only target. No count-only coincidence; see Findings 1.
- **The scope caveat is decisive, and it resolves against closure.** Every one of the 13 `_CM_`
  (countermodel) examples in the consumer's own `examples.py` has a **non-empty** premise list,
  and `MD_CM_1` additionally has a two-element conclusion list. The chain therefore consumes the
  general `Γ ⊨ σ` form, so A1 is not closed and the residue must be stated as its own obligation.
- **The stated obstruction to the general case is over-stated.** `Compression/Assembly.lean` and
  `Compression/README.md` say the general finite-premise case "needs a context-conjunction
  deduction theorem and the tree has none". That is true of one *route* (reduce `Γ ⊨ σ` to
  `⊨ ⋀Γ → σ`), not of the obstruction: every downstream component is already general in `Γ Del`,
  including `exists_labelledLasso_of_history_realized`, `Refutes`, `refutes_of_certifies` and all
  four `Decidable` instances. Three mechanical generalizations, not a deduction theorem, stand
  between the landed result and the general form. See Findings 2c.
- **A3 is newly live-and-open, not vacuous and not discharged.** `f` now exists and is checked to
  factor through `|C|` alone (`compressionBound Γ Del = fBound (closureOf (Γ ++ Del)).card` by
  `rfl`). The `mid` clause becomes a satisfiable magnitude condition; the `back`/`fwd`
  representability clause remains open exactly as section 7.1(iii-a) says. The `max_witnesses`
  precondition is *exactly* matched by the construction, though the theorem's stated count bound
  is weaker than the construction supports.
- **"Absence decided by verified code" is supported as mathematics, not as practice.**
  `validZTime_iff_noCertifiedCandidate` plus `Compression.decidableValidZTime` make it a theorem
  (empty-premise case). But `cands` is non-executable at the smallest interesting closures
  (measured: `|C| = 2` gives `B = 20`, candidate count ≈ `2^360`), there is no `lean_exe` for it,
  and "no certified candidate" is a different quantifier from any single Z3 UNSAT call.

## Context & Scope

This is a verdict-first conformance research task, not an implementation task. It compares the
landed compression theorem in this repository against obligation A1 of the companion ModelChecker
repository's bimodal adequacy chain, and states precisely what is and is not closed.

Constraints honored:

- **The ModelChecker repository was not edited.** It was read only. The upstream row text is
  produced as hand-off copy in Recommendations, for that repository's own task system to apply.
- **No file in this repository was edited either.** This is the research phase; the seed/manifest
  work below was validated against a scratchpad copy of the seed list and is proposed, not
  applied, so `scripts/lean-citation-manifest.json` stays byte-current and C35 stays green.
- **Declarations are cited by fully qualified name.** Line numbers appear only as a derived
  convenience, exactly as `scripts/lean-citation-manifest.json`'s own `note` field prescribes.
- Sibling task 685's declared file scope was read but not written.

All Lean declarations below live in namespace `FormalSystem.Metalogic.Decidability` unless
otherwise qualified.

## Findings

### 1. Question 1 — does the landed theorem instantiate A1, and do the condition sets agree?

**Answer: yes on the condition sets (exactly), and yes on A1's content — at restricted scope.**

**1a. The certificate datatype matches.** Upstream section 1 defines a certificate as a pair
`𝒲 = (bx, ⟨Λ₀, …, Λ_k⟩)` with a target time `t₀ ∈ ℤ`, over `C := closureOf (Γ ++ Δ)`, each
`Λᵢ = (backᵢ, midᵢ, fwdᵢ)` a triple of lists of subsets of `C` with `backᵢ ≠ []`, `fwdᵢ ≠ []`,
`mid` possibly empty, decoded by the three-segment scheme. The landed types agree field for field:

| Upstream section 1 | Landed declaration |
|---|---|
| `Λᵢ = (backᵢ, midᵢ, fwdᵢ)`, `backᵢ ≠ []`, `fwdᵢ ≠ []`, labels `⊆ C` | `LabelledLasso` fields `back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`label_sub` |
| the decoding (back left of `0`, mid on `[0, |mid|)`, fwd from `|mid|` on) | `LabelledLasso.lab`, via `Periodic.unrollOf` |
| `𝒲 = (bx, ⟨Λ₀, …, Λ_k⟩)` | `WitnessFamily` fields `bx`/`lassos`/`lassos_ne` |
| `L₀`, the lasso the target is read on | `WitnessFamily.main` `= WitnessFamily.L WitnessFamily.mainIdx`, `mainIdx = 0` |

**1b. The four conditions agree clause for clause, not merely in count.** Each landed conjunct was
read against the corresponding upstream clause:

| Upstream | Landed | Clause-level agreement |
|---|---|---|
| **(C1)** Local coherence | `WitnessFamily.LocalCoherentLab` | `⊥ ∉ Lᵢ(t)` unconditional in both; `imp` biconditional guarded by `Formula.imp a b ∈ closureOf (Γ ++ Del)`; `box` biconditional against `bx χ` guarded by `Formula.box χ ∈ …`; `untl` one-step unfolding at `t + 1` guarded by `Formula.untl g e ∈ …`; `snce` mirror at `t - 1` guarded by `Formula.snce g e ∈ …`. Atoms unconstrained in both, deliberately, for the same stated reason (the atom case of the agreement lemma is `Iff.rfl`). |
| **(C2)** Fulfilment | `WitnessFamily.FulfillingLab` | Both are two symmetric clauses over **all** `i, t, g, e` (not closure-restricted), both demand `∃ s > t` (resp. `s < t`) with `e ∈ Lᵢ(s)` and `g ∈ Lᵢ(r)` for every strictly-between `r`. The interval guard is present on both sides. |
| **(C3)** Box faithfulness | `WitnessFamily.BoxFaithful` | Identical: `∀ χ, □χ ∈ closureOf (Γ ++ Del) → (bx χ = true ↔ ∀ i ∀ t, χ ∈ L i t)`. |
| **(C4)** Target | `WitnessFamily.Target` | Identical, and read on lasso `0` only: `(∀ γ ∈ Γ, γ ∈ main t) ∧ (∀ σ ∈ Del, σ ∉ main t)`. |

`WitnessFamily.Certifies t` is exactly the conjunction of those four, in that order. So the
dispatch's premise — that the landed `Certifies` *is* upstream (C1)–(C4) — is confirmed.

**1c. `compressionBound` serves as A1's `f`, and this was checked rather than inferred.**
`compressionBound Γ Del = max (cycleBoundC (closureOf (Γ ++ Del))) (midBoundC (closureOf (Γ ++ Del)))`,
with `cycleBoundC C = (2 * C.card + 1) * 2 ^ C.card` and `midBoundC C = 2 * 2 ^ C.card`. Both
factors read only `C.card`, so the bound is a function of the closure **size** alone. Verified by
running, against the live tree:

```lean
def fBound (k : Nat) : Nat := max ((2 * k + 1) * 2 ^ k) (2 * 2 ^ k)
example (Γ Del : Context) :
    compressionBound Γ Del = fBound (closureOf (Γ ++ Del)).card := rfl   -- accepted
```

This closes the second of the three conditions upstream section 7.1 names for a genuine
reduction: "(ii) a bound depending only on `|closureOf (Γ ++ Δ)|`, obtained by compressing over
subformula-set space (pigeonhole `2^|C|`) rather than presentation states (pigeonhole `P.card`)".
The pigeonhole is over `TypeState C = {S : Finset Formula // S ∈ C.powerset}`, whose cardinality
`natCard_typeState` fixes at `2 ^ C.card` — subformula-set space, exactly as prescribed.
Condition (i) ("hypothesis is `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ` rather than truth in
a presented model") is met for the carrier — the hypothesis is `¬ ValidZTime φ`, an arbitrary
ℤ-time model, with no `IntPresentation` anywhere in the subdirectory — but **not** for the premise
context; see Finding 2.

**1d. What the landed theorem delivers beyond (C1)–(C4).** `exists_witnessFamily_of_not_validZTime`
carries four extra conjuncts, all consumed by `mem_cands_of_bounded` and none decoration:

1. all three segment lengths of every lasso `≤ compressionBound [] [φ]`;
2. `W.lassos.length ≤ (closureOf ([] ++ [φ])).card + 1`;
3. the canonical enumerable box guess: `∃ S ⊆ closureOf ([] ++ [φ]), W.bx = fun χ => decide (χ ∈ S)`;
4. `0 ≤ t ∧ t ≤ (compressionBound [] [φ] : ℤ)` — the target time is itself bounded.

Conjunct 4 is a **strengthening** relative to upstream section 1, which places `t₀ ∈ ℤ` with no
bound. Conjunct 3 is what escapes the enumerability trap that `BiLasso/Assembly.lean` records as
fatal for `IntPresentation.val`.

**1e. A1's "whose main lasso carries the refuting point" clause is met.** In the proof, the main
lasso is `Λ₀` obtained from `exists_labelledLasso_of_history_realized` at the refuting history and
time, with `Λ₀.lab i₀ = typeAtM M [] [φ] τ t₀` and `0 ≤ i₀ ≤ Λ₀.nm`; `Target i₀` is discharged
from precisely that equation. The refuting point is carried on lasso `0`, in the interior of the
`mid` segment.

**1f. Axiom closure, verified independently.** `lean_verify` on the live tree reports
`["propext", "Classical.choice", "Quot.sound"]` with no warnings for each of
`exists_witnessFamily_of_not_validZTime`, `validZTime_iff_noCertifiedCandidate`,
`Compression.decidableValidZTime` and `decidableSemanticConsequenceNil`. The dispatch's claim is
confirmed rather than taken on trust.

### 2. Question 2 — the scope caveat, resolved

**Answer: the chain needs the general `Γ ⊨ Δ` form. A1 is NOT closed. The residue is stated as its
own obligation in Recommendations.**

**2a. Three independent pieces of evidence that the general form is what is consumed.**

1. **(ADEQ)'s own statement** (upstream section 7) begins "If some `σ ∈ Δ` is not a ℤ-time
   consequence of `Γ` — i.e. `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ`". `Γ` is a free
   parameter, not fixed empty.
2. **The certificate definition** (upstream section 1) fixes `C := closureOf (Γ ++ Δ)` and (C4)
   requires `∀ γ ∈ Γ. γ ∈ L₀(t₀)`. With `Γ = []` that clause is vacuous, so the empty-premise
   instance exercises none of it.
3. **The consumer's own test inventory is decisive.** In
   `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/examples.py`, **all 13**
   countermodel examples (`EX_CM_1`, `MD_CM_1`–`MD_CM_6`, `TN_CM_1`–`TN_CM_2`, `BM_CM_1`–`BM_CM_4`)
   have non-empty premise lists; zero have `_premises = []`. `MD_CM_1` additionally has
   `_conclusions = ['\\Box A', '\\Box B']`, i.e. `|Δ| = 2`. The empty-premise single-conclusion
   instance A1 now covers is instantiated by **none** of the examples for which (ADEQ) is the
   operative claim.

**2b. A1's own recorded statement contains the gap.** Upstream section 7.1 quotes A1 as
*"if `¬ ValidZTime ψ` (**equivalently** `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ`) then …"*.
That parenthetical equivalence is not available in this tree: it needs a context-conjunction
deduction theorem. The only landed bridge is `semanticConsequenceIn_nil_iff`, which proves
`SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ` — the `Γ = []` case only. So the upstream A1 text
silently presupposes the very step that is missing, which is why the gap is easy to overlook.

**2c. The obstruction is smaller than the tree's own docstrings claim — a correction worth
propagating.** `Compression/Assembly.lean`'s `decidableSemanticConsequenceNil` docstring and
`Compression/README.md`'s "What is out of scope" both say the general case "needs a
context-conjunction deduction theorem and the tree has none — so it is out of scope here rather
than merely unproved". That diagnosis is right about the *reduction* route and wrong about the
*direct* route. Read against the live signatures:

- `SemanticConsequenceIn fc Γ φ` unfolds to `ConsequenceOnFrames fc.Sat Γ φ`, which is **local**
  consequence at a point: `∀ F, fc.Sat F → ∀ M τ t, (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ`.
  Its negation is therefore literally a point where all of `Γ` holds and `φ` fails — the same
  shape as `Refutes Γ [φ]`.
- `Refutes` and `WitnessFamily.refutes_of_certifies` (via `WitnessFamily.joint_countermodel`) are
  already stated at **arbitrary** `Γ Del`. The soundness half needs nothing.
- The four `Decidable` instances in `WitnessFamily/Decide.lean`
  (`decidableLocalCoherentLab`, `decidableFulfillingLab`, `decidableBoxFaithful`,
  `decidableTarget`, composed as `decidableCertifies`) are already at arbitrary `Γ Del`.
- `exists_labelledLasso_of_history_realized` and `exists_labelledLasso_of_history` — the entire
  compression geometry, the pigeonhole, the good cycles, the fulfilment transfer, and
  `compressionBound` itself — are already stated at arbitrary `(Γ Del : Context)`. Nothing in
  `Types.lean`, `Cycle.lean`, `Fulfil.lean` or `Extract.lean` is `Γ = []`-specific.

What is actually `Γ = []`-specific is exactly three things:

1. **The entry point.** `exists_witnessFamily_of_not_validZTime` starts from `¬ ValidZTime φ` and
   normalizes the carrier with `validZTime_iff_validInt`. The general case needs the consequence
   analogue of that carrier normalization. `truthAt_map` — the transport lemma
   `validZTime_iff_validInt` is built from — is stated per-formula at a **fixed** aligned
   `(σ, σ', t)` triple, so it applies simultaneously to every `γ ∈ Γ` and to `σ` at the same
   point. The consequence-form normalization is a direct adaptation of
   `validZTime_iff_validInt`'s existing proof, not new mathematics.
2. **`Target`'s premise clause.** In the landed proof `htgt` discharges the premise half with
   `absurd hγ List.not_mem_nil`. For general `Γ` it becomes the mirror of the conclusion half
   already written two lines below it: `mem_typeAtM.mpr ⟨self_mem_closureOf (…), htrue γ⟩`.
3. **`Enumerate.lean`'s φ-specialization.** `closureSubsetsOf`, `rawLabelledLassos`,
   `IsLabelledLasso`, `boundedLassos`, `cands` and their six companion lemmas all take
   `(φ : Formula)` and use `closureOf ([] ++ [φ])`. `ListEnumC.ofLen`/`upTo` are already generic.
   Re-parameterizing to `(Γ Del : Context)` over `closureOf (Γ ++ Del)` is mechanical.

This matters for planning: the residue is a bounded re-parameterization plus one transfer lemma,
not a deduction-theorem development. It also means the multi-conclusion case (`MD_CM_1`) comes
free with the same re-parameterization, since `Del` is already a `Context` everywhere downstream.

**2d. What is genuinely out of scope and stays so.** The stability modal `⊡` — `ValidZTime` is
stated for `FormalSystem.Syntax.Formula`, which has no `⊡`; `⊡` lives only in
`FormalSystem.PlusLanguage.Formula`. This is independent of A1 and unchanged.

### 3. Question 3 — does A3 realization now hold?

**Answer: A3 is newly live-and-open. It is no longer vacuous, and it is not discharged. Its two
clauses have different statuses, and its precondition is now exactly matched.**

A3 is a condition on the **consumer's configuration**, so it cannot be a theorem in this
repository. What this repository can supply is `f`, plus a precise statement of what the bound
does and does not license. Clause by clause:

**3a. The `mid` clause — "and `mid` is at least its mid length" — becomes satisfiable by
magnitude.** `exists_witnessFamily_of_not_validZTime` bounds every lasso's `mid.length` by
`compressionBound [] [φ]`, and upstream section 7.1 itself records that `mid` has no periodicity
and never participates in the modulus-folding gap (`docs/SEARCH_COVERAGE.md` section 3(b)). So
configuring `mid ≥ compressionBound` discharges this clause. This half of A3 is now
satisfiable-in-principle.

**3b. The `back`/`fwd` clause — "common multiples of the compressed family's periods" — remains
open, and the landed work sharpens *why*.** The theorem bounds segment **lengths**, not
**periods**: `|back|` is *a* period of the decoded label function (`lab_sub_back_length`), but no
minimal-period statement is proved, so the strongest available form is "the family is representable
at configured back `= |back|` exactly, for some `|back| ≤ B`". Against a consumer whose
`WitnessRegistry.wrap()` folds by exact modulus, that is precisely the sweep requirement of
upstream section 7.1(iii-a) — unbuilt. This repository states the same conclusion in three places,
independently and in its own voice: `Compression/README.md`'s "The bound is a grid, not a
magnitude", the identical section in `Compression/Family.lean`'s header, and
`Compression/Assembly.lean`'s "The bound is a grid, and a consumer that folds by modulus needs to
know". `cands` sweeps every triple in `[0, B]³` for exactly this reason. So: A3's back/fwd clause
is now *precisely formulable* (it has an `f`) and *open* (it needs iii-a).

**3c. The `max_witnesses` precondition is exactly matched — a positive finding.** Upstream states
the precondition as "`max_witnesses` is `None`, or at least the boxed-subformula count", and
section 7.1(iii-b) describes the represented space as "`1 + |{Box members}|` lassos when
`max_witnesses` is uncapped". The landed construction builds
`lassos = Λ₀ :: (boxedPart C \ S).toList.map wit` — the main lasso, plus **one witness lasso per
boxed closure member the guess sets false**. Since `boxedPart C` is exactly
`{χ | Formula.box χ ∈ C}` (`mem_boxedPart`), the family's lasso count is
`1 + |boxedPart C \ S| ≤ 1 + |boxedPart C|` = one plus the boxed-subformula count. The upstream
precondition is therefore exactly, not approximately, what the landed family needs.

**3d. But the theorem's *stated* count bound is weaker than its construction supports.** The
statement gives `W.lassos.length ≤ (closureOf ([] ++ [φ])).card + 1`, because the proof's `hcard`
step deliberately weakens through `boxedPart_subset_closureOf`. To *cite* the exact match in 3c,
upstream would need a bound of the form `≤ (boxedPart (closureOf ([] ++ [φ]))).card + 1`, which
the existing proof already establishes and then throws away. This is a statement change with no
new mathematics.

**3e. One unproved-but-available lemma the represented space needs.** The landed count can be
strictly *smaller* than `1 + |boxedPart C|` (only false-guessed boxes get a witness lasso), while
the consumer allocates a fixed `1 + |{Box members}|` lassos. Padding the family up to the fixed
size preserves all four conditions — padding with copies of `Λ₀` works, because `BoxFaithful`'s
forward direction already puts every `χ` with `bx χ = true` in every label of every lasso,
including the main one, so the added lassos cannot falsify (C3)'s `←` direction, and (C1)/(C2) are
per-lasso and already hold of `Λ₀`. This padding lemma does not exist in the tree. It is the one
small thing section 7.1(iii-b)'s "state and check the represented space" needs from the Lean side.

**3f. An upstream internal inconsistency worth reporting.** `TRUST_PIPELINE.md`'s A-component
table states A3 as "Bound realization: configured lengths **≥ `f(|C|)`**" — the magnitude form.
`ADEQUACY.md` section 7's own A3 row states the representability form and explicitly says the
magnitude form "can be false even when the underlying family exists". `TRUST_PIPELINE.md`'s row
is the wrong form and contradicts both `ADEQUACY.md` and this repository's three warnings. It
should be corrected in the same pass as the A1/A3 rows.

### 4. Question 4 — is "absence decided by verified code rather than by trusting Z3 UNSAT" now supported?

**Answer: supported as mathematics, for the empty-premise case. Not supported as a practical
replacement for Z3 UNSAT, and not supported as a claim about *this* consumer's UNSAT verdicts.**

The upstream claim (`TRUST_PIPELINE.md`, "In the Lean development" table) is: "because the
candidate space at the bound is finite and enumeration completeness is already proved there,
**absence can be decided by verified code rather than by trusting Z3's UNSAT** — which dominates
proving this repository's encoder correct."

**4a. The mathematical content is now in place.** Three landed pieces, all sorry-free at the
three-axiom closure:

- **Finiteness**: `cands φ : List (WitnessFamily [] [φ])` is a `List`, finite by construction —
  `closureSubsetsOf` flat-mapped over `ListEnumC.upTo (boundedLassos φ (compressionBound [] [φ]))`.
- **Enumeration completeness**: `mem_cands_of_bounded` — any family meeting the three side
  conditions the compression theorem delivers is a member, with all three consumed.
- **The decision**: `validZTime_iff_noCertifiedCandidate` reduces `ValidZTime φ` to
  "no `W ∈ cands φ` certifies at any `t ∈ Finset.Icc 0 (compressionBound [] [φ])`", both
  quantifiers over finite objects; `Compression.decidableValidZTime` is `decidable_of_iff` on it,
  and `decidableSemanticConsequenceNil` lifts it to `SemanticConsequenceIn FrameClass.ZTime [] σ`.

So "absence is decidable by verified code" is now a **theorem** rather than a route — at
empty-premise single-conclusion scope. Before this work, `cands`-style finiteness existed only in
`BiLasso/`, whose decision procedure is *conditional* on a finite-model-property hypothesis that
`Probe476.fmp_false` refutes; the unconditional statement is new.

**4b. It is not executable, and the gap is not marginal.** Measured on the live tree via `#eval`:

| `φ` | `|closureOf ([] ++ [φ])|` | `compressionBound [] [φ]` |
|---|---|---|
| `p` | 1 | 6 |
| `□p` | 2 | 20 |
| `p U □p` | 3 | 56 |

`Assembly.lean`'s own cost estimate is `~(2^k)^{3B(1 + k)}`. At `k = 1, B = 6` that is `2^36`
(~7e10); at `k = 2, B = 20` it is `2^360` (~2e108); at `k = 3, B = 56` it is `2^2016`. For
reference, the consumer's own exhaustive A2-triangle enumeration tops out at 10,485,760 candidates
at `nb = nf = 2`. So the verified enumerator is beyond execution at the *second* smallest
interesting closure. The cost is the literature's own — [GKWZ] 2003 section 6.5 gives an
EXPSPACE-hardness lower bound for `PTL × S5` — which is exactly why `Assembly.lean` says
"`Decidable` is the deliverable" and disclaims any complexity reading.

**4c. There is no executable to consume it.** `lakefile.toml` declares 14 `lean_exe` targets;
`BimodalTools.CheckCertificateMain` checks a *supplied* certificate (the soundness direction) and
there is no enumerator binary. `Compression.decidableValidZTime` is also a `def`, not an
`instance`, deliberately.

**4d. The quantifiers differ, so this does not validate any particular Z3 UNSAT verdict.** The
Lean criterion quantifies over the whole grid `[0, B]³` (via `cands`). A Z3 UNSAT verdict is at
**one** configured `(back, mid, fwd)`. Bridging a single UNSAT to "no certified candidate on the
grid" still needs A2 (encoding completeness) **and** A3's representability clause. The landed work
changes nothing about A2, and section 3b above shows A3's back/fwd clause is still open. So
`TRUST_PIPELINE.md`'s claim should be read as: the verified-absence *route* is now proved to
exist, at restricted scope; it does not yet displace trusting Z3 UNSAT for any live example.

### 5. Citation-manifest findings

**5a. None of the relevant declarations is currently seeded.** `scripts/lean-citation-seeds.txt`
contains 63 names; zero mention `Compression`, and none of `WitnessFamily.LocalCoherentLab`,
`FulfillingLab`, `BoxFaithful`, `Target`, `Certifies`, `LabelledLasso`, `joint_countermodel` or
`refutes_of_certifies` appears. So every declaration this conformance argument turns on is
currently cited by upstream **only** by `file.lean:NNN` — the exact failure mode C35 exists to
prevent.

**5b. The gap predates this task.** `ADEQUACY.md` already cites, by line number and unseeded,
`WitnessFamily/Basic.lean:76` (`LabelledLasso`), `Basic.lean:104` (`lab`), `Basic.lean:117`,
`Agreement.lean:65`/`:109`/`:203`/`:232` (`joint_countermodel`), `Decide.lean:192`/`:212`
(`scan_forward`/`scan_backward`), `Decide.lean:335`/`:743`/`:809`/`:865`, and
`Examples.lean:275`. Four of these have already moved relative to the document: the manifest dry
run resolves `joint_countermodel` at `Agreement.lean:248`, not `:232`.

**5c. A validated seed block exists.** A 23-name addition was dry-run through
`scripts/export-lean-citations.py --seeds <scratchpad copy> --stdout`: exit 0, 86 of 86 names
resolved, zero unresolved. Two names needed correcting during the dry run — `LabelledLasso` and
`LabelledLasso.lab` sit directly in `FormalSystem.Metalogic.Decidability`, **not** nested under
`WitnessFamily` — which is itself a reason to seed them rather than let a consuming document guess
the namespace. The block and its regeneration procedure are in Recommendations. Nothing under
`scripts/` was modified, so `scripts/lean-citation-manifest.json` remains byte-current and C35
remains green.

## Decisions

- **A1 is reported as partially discharged, not discharged.** The dispatch's conditional
  deliverable ("if A1 is discharged, the updated row text …") does not strictly fire. The row text
  is supplied anyway, because the current row's "Open. Route named, not built" is now factually
  wrong and leaving it unchanged is the worse error.
- **The residue is stated as its own obligation** (proposed name **A1-Γ**) rather than folded into
  A1's row, per the dispatch's instruction that "if the general form is needed, A1 is NOT closed
  and the residue must be stated as its own obligation".
- **No file outside `specs/693_.../` was written.** In particular `scripts/lean-citation-seeds.txt`
  and `scripts/lean-citation-manifest.json` were left untouched (dry run only, in the scratchpad),
  and the ModelChecker repository was read-only throughout.
- **The `Compression/Assembly.lean` and `Compression/README.md` "needs a deduction theorem" claim
  is recorded as over-stated**, with the three actual residue items enumerated, rather than
  repeated. Correcting those two docstrings is proposed as implementation work; note that
  `WitnessFamily/README.md` is in sibling task 685's declared file scope and
  `Compression/README.md` is not.
- **Declaration citations are by fully qualified name throughout**, with line numbers only as a
  derived convenience in section 5b where drift itself is the subject.

## Recommendations

Prioritized. Items 1–2 are hand-off to the ModelChecker repository (no edits here or there);
items 3–6 are work in this repository.

### 1. Upstream row text — `ADEQUACY.md` section 7 component table (hand-off, do not apply here)

Replace the A1 row, keep A2 unchanged, replace the A3 row, and add one new row. Proposed text:

> | **A1** | Compression: a ℤ-time countermodel yields a certificate with lengths bounded by `f(\|C\|)` | **Partially discharged — the empty-premise, single-conclusion instance is proved.** `exists_witnessFamily_of_not_validZTime` (BimodalLogic, `Metalogic/Decidability/WitnessFamily/Compression/Family.lean`) takes `¬ ValidZTime φ` to a `WitnessFamily [] [φ]` and a target time satisfying exactly (C1)–(C4), with all three segment lengths of every lasso and the target time bounded by `compressionBound [] [φ]`, at most `\|C\| + 1` lassos, and a canonically enumerable box guess `fun χ => decide (χ ∈ S)` for an explicit `S ⊆ C`. The bound factors through the closure size alone: `compressionBound Γ Del = max ((2k+1)·2^k) (2·2^k)` at `k = \|closureOf (Γ ++ Δ)\|`, checked by `rfl`. The pigeonhole is over subformula-set space (`TypeState C`, cardinality `2^\|C\|`), not presentation states, so section 7.1's rejected `exists_annot_of_truth` reduction is superseded rather than patched. Sorry-free; axiom closure `{propext, Classical.choice, Quot.sound}`. **The general `Γ ⊨ σ` form this chain consumes is not covered — see A1-Γ.** Section 7.1. |
> | **A1-Γ** | Compression at non-empty premises and multiple conclusions: the same statement with hypothesis `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ` for arbitrary finite `Γ`, and target `Δ` a finite list | **Open, and this is the form (ADEQ) consumes.** A1's landed instance is at `Γ = []`, `Δ = [φ]`; every countermodel example in this repository's `examples.py` has a non-empty premise list, and `MD_CM_1` has `\|Δ\| = 2`. Upstream A1's own parenthetical "(equivalently `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ`)" presupposes a context-conjunction deduction theorem that BimodalLogic does not have; its only landed bridge, `semanticConsequenceIn_nil_iff`, covers `Γ = []` only. The residue is bounded, not open-ended: `Refutes`, `refutes_of_certifies`, `joint_countermodel`, `exists_labelledLasso_of_history_realized`, `compressionBound` and all four `Decidable` instances are already stated at arbitrary `Γ Del`. Section 7.1a. |
> | **A3** | Bound realization: configured `back`/`fwd` are common multiples of the compressed family's periods (each bounded by `f(\|C\|)`), and `mid` is at least its mid length — a representability, not a magnitude, condition (precondition: `max_witnesses` is `None` or at least the boxed-subformula count) | **No longer vacuous — live and open, at A1's restricted scope.** `f` now exists: `f(k) = max ((2k+1)·2^k, 2·2^k)`. The `mid` clause is a magnitude condition and is satisfiable at `mid ≥ f(\|C\|)`, since `mid` has no periodicity. The `back`/`fwd` clause remains **open**: the landed theorem bounds segment *lengths*, not minimal periods, so representability against a registry that folds by exact modulus still requires section 7.1(iii-a)'s bounded sweep. The `max_witnesses` precondition is *exactly* matched — the compressed family is `main :: (one witness lasso per boxed closure member its guess sets false)`, so `1 + |{Box members}|` uncapped lassos is precisely what it needs. Section 7.1, section 7.3. |

Accompanying edits the same pass should make upstream:

- `ADEQUACY.md` section 7.1's "**A1 is recorded as open. It is not asserted…**" paragraph and its
  "The one candidate … examined and rejected" subsection both need rewriting: the
  `exists_annot_of_truth` rejection stands as history, but all three of its stated reasons are now
  met by a *different* declaration (presentation-free hypothesis; `|C|`-only bound;
  subformula-set-space pigeonhole in place of the refuted small-model hypothesis).
- `ADEQUACY.md` section 7.1's condition (ii) is now discharged and condition (i) is discharged for
  the carrier but not for the premise context; (iii) is unchanged.
- `TRUST_PIPELINE.md`'s A-component table: the A1 and A3 rows need the same updates, **and** its
  A3 row's "configured lengths ≥ `f(|C|)`" is the wrong (magnitude) form and should be replaced
  with the representability form (Finding 3f).
- `TRUST_PIPELINE.md`'s "In the Lean development" table, "Compression (A1) and the verified
  bounded enumerator" row: the "absence can be decided by verified code" claim is now a theorem at
  restricted scope but is **not** a practical replacement — `cands` is ~`2^360` candidates already
  at `|C| = 2`, there is no `lean_exe` for it, and its grid quantifier is not any single Z3 call's
  quantifier (Finding 4).

### 2. Upstream should switch these citations to names plus the manifest (hand-off)

`ADEQUACY.md` currently cites `Agreement.lean:232` for `joint_countermodel`; the live keyword line
is 248. Rather than re-anchoring by hand, the fourteen `WitnessFamily/`-and-`Compression/`
citations should move to the `name` + manifest convention the manifest's own `note` prescribes,
once item 3 lands.

### 3. Add the validated seed block (this repository, implementation work)

Append to `scripts/lean-citation-seeds.txt`, then regenerate and re-gate. All 23 names were dry-run
resolved (exit 0, 86/86):

```
## Certificate conditions (C1)-(C4)
FormalSystem.Metalogic.Decidability.WitnessFamily.LocalCoherentLab
FormalSystem.Metalogic.Decidability.WitnessFamily.FulfillingLab
FormalSystem.Metalogic.Decidability.WitnessFamily.BoxFaithful
FormalSystem.Metalogic.Decidability.WitnessFamily.Target
FormalSystem.Metalogic.Decidability.WitnessFamily.Certifies
FormalSystem.Metalogic.Decidability.LabelledLasso
FormalSystem.Metalogic.Decidability.LabelledLasso.lab
FormalSystem.Metalogic.Decidability.WitnessFamily.joint_countermodel
FormalSystem.Metalogic.Decidability.WitnessFamily.refutes_of_certifies
FormalSystem.Metalogic.Decidability.WitnessFamily.Refutes

## Compression: the A1 candidate
FormalSystem.Metalogic.Decidability.cycleBoundC
FormalSystem.Metalogic.Decidability.midBoundC
FormalSystem.Metalogic.Decidability.compressionBound
FormalSystem.Metalogic.Decidability.exists_labelledLasso_of_history_realized
FormalSystem.Metalogic.Decidability.exists_labelledLasso_of_history
FormalSystem.Metalogic.Decidability.boxedPart
FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime
FormalSystem.Metalogic.Decidability.cands
FormalSystem.Metalogic.Decidability.mem_cands_of_bounded
FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate
FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime
FormalSystem.Metalogic.Decidability.semanticConsequenceIn_nil_iff
FormalSystem.Metalogic.Decidability.decidableSemanticConsequenceNil
```

Then, in order — the manifest is generated and must never be hand-edited:

```
python3 scripts/export-lean-citations.py
bash scripts/check-module-invariants.sh --no-build    # C35 must stay green
```

Seeding `Decide.lean`'s `scan_forward`/`scan_backward` would close the rest of section 5b's
line-cited set, but `WitnessFamily/Decide.lean` is in sibling task 685's declared file scope;
coordinate rather than racing it. Adding names to the seed list touches only `scripts/`, so it
does not itself collide.

### 4. Name the bound's factorization through `|C|` (this repository, one declaration)

Upstream's A1 row wants an `f` of the closure size, but `compressionBound`'s signature reads
`(Γ Del : Context)`. A named `def` plus a `theorem` in `Compression/Extract.lean` — the equation
holds by `rfl`, as checked in Finding 1c — gives upstream something to cite by name instead of a
prose claim about what the definition unfolds to.

### 5. Strengthen the two statements that are weaker than their own proofs (this repository)

- `exists_witnessFamily_of_not_validZTime`'s lasso-count conjunct: state
  `≤ (boxedPart (closureOf ([] ++ [φ]))).card + 1`, which the existing `hcard` step already
  establishes before weakening through `boxedPart_subset_closureOf`. This is what makes the
  `max_witnesses` precondition citable (Finding 3d). `mem_cands_of_bounded` and
  `validZTime_iff_noCertifiedCandidate` consume the weaker bound, so either keep both forms or
  weaken at the one call site.
- Add the padding lemma of Finding 3e, so a family can be presented at exactly
  `1 + |boxedPart C|` lassos. This is what section 7.1(iii-b)'s "state and check the represented
  space" needs from the Lean side.

### 6. Correct the two "needs a deduction theorem" docstrings (this repository)

`Compression/Assembly.lean`'s `decidableSemanticConsequenceNil` docstring and
`Compression/README.md`'s "What is out of scope" should say what Finding 2c establishes: the
deduction theorem is needed only for the *reduction* route, and the direct route's residue is the
three items enumerated there. As written, the docstrings overstate the obstruction and would steer
a future planner away from the cheap path. Prefer scoping this to `Compression/README.md` and
`Compression/Assembly.lean`; `WitnessFamily/README.md` is sibling-owned.

## Risks & Mitigations

- **Risk: the A1-Γ residue is under-estimated.** Finding 2c is a read of signatures, not a
  completed proof; the consequence-form carrier normalization in particular was not written. If
  `truthAt_map`'s instance binders do not thread as cleanly as `validZTime_iff_validInt`'s
  do, item 1 of the residue could grow. **Mitigation**: the A1-Γ row text above claims only that
  the residue is "bounded, not open-ended" and enumerates the already-general declarations by
  name; it does not promise an effort estimate. A planner should prove the normalization lemma
  first and re-scope on the result.
- **Risk: the padding lemma of Finding 3e turns out to need a side condition.** The argument given
  is sound but was not machine-checked. **Mitigation**: it is recommended as work, not asserted as
  a fact, and nothing in the proposed row text depends on it.
- **Risk: the upstream row text goes stale before it is applied.** The line numbers in
  `ADEQUACY.md` have already drifted once (Finding 5b). **Mitigation**: the proposed row text
  cites declarations by fully qualified name only, with one file path for orientation and no line
  numbers; item 3 puts the names under C35 so future drift fails a gate.
- **Risk: a reader takes "absence is decidable by verified code" as operational.** **Mitigation**:
  Finding 4 and the item 1 note pair the theorem with the measured candidate counts and the
  absence of any `lean_exe`, so the restriction travels with the claim.
- **Risk: concurrent edits from sibling task 685.** Its scope includes
  `WitnessFamily/{Decide,Closure}.lean`, `WitnessFamily.lean`, `WitnessFamily/README.md` and
  `docs/theorem-index.md`. **Mitigation**: this research wrote nothing; every recommendation above
  is scoped away from those five paths, and item 3's Decide.lean extension is explicitly deferred
  to coordination.

## Tactic Survey Results

- Not applicable (no tactic survey performed). This is a conformance-and-scope audit of landed,
  sorry-free declarations; no open proof goal was under investigation, so the LeanHammer portfolio
  survey and `lean_multi_attempt` testing had nothing to run against. The one Lean execution
  performed was a positive check that a definitional equation holds by `rfl` (Finding 1c), plus
  four `#eval`s (Finding 4b) and four `lean_verify` axiom-closure checks (Finding 1f).

## Context Extension Recommendations

- **Topic**: The cross-repository obligation-conformance workflow — how a BimodalLogic declaration
  is checked against a ModelChecker adequacy obligation, and what "discharged" requires.
- **Gap**: `.claude/context/project/lean4/tools/comparator-guide.md` covers the Comparator trust
  model (what a green result does and does not certify), but nothing covers the *documentary*
  side: that upstream obligations are consumed at a general parameterization while landed Lean
  theorems often arrive at a restricted instance, that the restriction must be reported as its own
  obligation rather than glossed, and that the citation manifest plus C35 is the mechanism for
  keeping the two repositories' references from drifting.
- **Recommendation**: add
  `.claude/context/project/lean4/patterns/cross-repo-obligation-conformance.md`, recording: the
  restricted-instance-versus-consumed-form check (with this task's `Γ = []` case as the worked
  example); the "read the consumer's own test inventory to settle which form is consumed" move
  that decided Question 2; the seed-then-regenerate-then-C35 procedure for manifest additions; and
  the standing prohibition on editing the companion repository from here.

## Appendix

### Verification commands run

- `lean_verify` on `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`,
  `…validZTime_iff_noCertifiedCandidate`, `…Compression.decidableValidZTime`,
  `…decidableSemanticConsequenceNil` — each returned
  `{"axioms":["propext","Classical.choice","Quot.sound"],"warnings":[]}`.
- `lean_run_code`: the `fBound` `rfl` check of Finding 1c (accepted, no diagnostics), and the four
  `#eval`s of Finding 4b.
- `python3 scripts/export-lean-citations.py --seeds <scratchpad seed copy> --stdout` — exit 0,
  "86 seeded name(s) resolved". Run against a scratchpad copy; `scripts/` was not modified.

### Upstream anchors consulted

`ADEQUACY.md` section 1 (certificate and (C1)–(C4)), section 2 ((SOUND) obligation table),
section 5.2 (window widths), section 7 ((ADEQ) statement, `max_witnesses` precondition, A0/A1/A2/A3
table), section 7.1 (A1, the rejected `exists_annot_of_truth` reduction, conditions (i)–(iii),
residue items (iii-a)–(iii-e)), section 7.2 (A0), section 7.3 (A2 and the A2-triangle test).
`TRUST_PIPELINE.md`: the A-component table, "The standing test for A2", and both "What remains"
tables. `examples.py`: the `_CM_`/`_TH_` example inventory.

### Terminology map used when comparing the two sides

| Upstream name | Landed declaration |
|---|---|
| certificate `(𝒲, t₀)` | `WitnessFamily Γ Del` together with a target time `t : ℤ` |
| `Λᵢ` | `LabelledLasso (closureOf (Γ ++ Del))` |
| `Lᵢ` | `WitnessFamily.L i`, i.e. `(lassos.get i).lab` |
| `L₀` | `WitnessFamily.main` |
| `bx` | `WitnessFamily.bx` |
| `C` | `closureOf (Γ ++ Del)` |
| (C1) / (C2) / (C3) / (C4) | `LocalCoherentLab` / `FulfillingLab` / `BoxFaithful` / `Target` |
| (C1)–(C4) bundled | `WitnessFamily.Certifies` |
| `f` | `compressionBound`, which equals `max ((2k+1)·2^k) (2·2^k)` at `k = |C|` |
