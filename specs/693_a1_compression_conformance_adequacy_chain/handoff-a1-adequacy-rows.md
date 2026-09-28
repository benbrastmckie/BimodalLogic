# Handoff: the A1 / A1-Γ / A3 adequacy-chain rows for the ModelChecker repository

**From**: task 693 (A1 compression conformance against the bimodal adequacy chain), in the
BimodalLogic (ProofChecker) repository.
**To**: the ModelChecker repository's own task system — specifically whoever maintains
`code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md` and
`code/src/model_checker/theory_lib/bimodal/docs/TRUST_PIPELINE.md`.

## Read this first: this note is copy, not an edit

The ModelChecker repository **was not edited** by the task that produced this note, and **must not
be edited from this repository**. It is a separate repository with its own task system, its own
gates and its own review. Everything below is proposed replacement text for that repository, to be
applied there, by that repository's own task flow, after that repository's own review. Nothing here
instructs anyone to reach across the repository boundary.

Every declaration below is cited by **fully qualified name**, with at most one file path for
orientation and **no line numbers**. That convention is deliberate: the provenance note in the
upstream document records that line numbers went stale underneath unchanged declaration names while
every gate in both repositories stayed green. The one place a line number appears in this note is
the drift record in section (c), which exists precisely to document that failure and is labelled as
such.

## (a) Replacement rows for `ADEQUACY.md` section 7's component table

Replace the **A1** row, leave **A0** and **A2** unchanged, insert a new **A1-Γ** row after A1, and
replace the **A3** row. The table's existing header is `| | Component | Status |`.

| | Component | Status |
|---|---|---|
| **A1** | Compression: a ℤ-time countermodel yields a certificate with lengths bounded by `f(\|C\|)` | **Partially discharged — the empty-premise, single-conclusion instance is proved.** `exists_witnessFamily_of_not_validZTime` (BimodalLogic, `Metalogic/Decidability/WitnessFamily/Compression/Family.lean`) takes `¬ ValidZTime φ` to a `WitnessFamily [] [φ]` and a target time satisfying exactly (C1)–(C4), with all three segment lengths of every lasso and the target time bounded by `compressionBound [] [φ]`, at most `\|C\| + 1` lassos, and a canonically enumerable box guess `fun χ => decide (χ ∈ S)` for an explicit `S ⊆ C`. The bound factors through the closure size alone: `compressionBound Γ Del = max ((2k+1)·2^k) (2·2^k)` at `k = \|closureOf (Γ ++ Δ)\|`, checked by `rfl`. The pigeonhole is over subformula-set space (`TypeState C`, cardinality `2^\|C\|`), not presentation states, so section 7.1's rejected `exists_annot_of_truth` reduction is superseded rather than patched. Sorry-free; axiom closure `{propext, Classical.choice, Quot.sound}`. **The general `Γ ⊨ σ` form this chain consumes is not covered — see A1-Γ.** Section 7.1. |
| **A1-Γ** | Compression at non-empty premises and multiple conclusions: the same statement with hypothesis `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ` for arbitrary finite `Γ`, and target `Δ` a finite list | **Open, and this is the form (ADEQ) consumes.** A1's landed instance is at `Γ = []`, `Δ = [φ]`; every countermodel example in this repository's `examples.py` has a non-empty premise list, and `MD_CM_1` has `\|Δ\| = 2`. Upstream A1's own parenthetical "(equivalently `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ`)" presupposes a context-conjunction deduction theorem that BimodalLogic does not have; its only landed bridge, `semanticConsequenceIn_nil_iff`, covers `Γ = []` only. The residue is bounded, not open-ended: `Refutes`, `refutes_of_certifies`, `joint_countermodel`, `exists_labelledLasso_of_history_realized`, `compressionBound` and all four `Decidable` instances are already stated at arbitrary `Γ Del`. Section 7.1a. |
| **A3** | Bound realization: configured `back`/`fwd` are common multiples of the compressed family's periods (each bounded by `f(\|C\|)`), and `mid` is at least its mid length — a representability, not a magnitude, condition (precondition: `max_witnesses` is `None` or at least the boxed-subformula count) | **No longer vacuous — live and open, at A1's restricted scope.** `f` now exists: `f(k) = max ((2k+1)·2^k, 2·2^k)`. The `mid` clause is a magnitude condition and is satisfiable at `mid ≥ f(\|C\|)`, since `mid` has no periodicity. The `back`/`fwd` clause remains **open**: the landed theorem bounds segment *lengths*, not minimal periods, so representability against a registry that folds by exact modulus still requires section 7.1(iii-a)'s bounded sweep. The `max_witnesses` precondition is *exactly* matched — the compressed family is `main :: (one witness lasso per boxed closure member its guess sets false)`, so `1 + |{Box members}|` uncapped lassos is precisely what it needs. Section 7.1, section 7.3. |

### What changed, in one line each

- **A1** moves from *"Open. Route named, not built."* to **partially discharged**: the
  empty-premise, single-conclusion instance is proved, sorry-free, with `f` supplied.
- **A1-Γ** is new: it carries the residue A1 no longer covers, so the chain's own consumed form is
  recorded as an obligation in its own right rather than being silently folded into A1.
- **A3** moves from *"Vacuous until A1 supplies `f`"* to **live and open**: `f` now exists, the
  `mid` clause is satisfiable by magnitude, the `back`/`fwd` clause remains open, and the
  `max_witnesses` precondition turns out to be exactly — not approximately — what the landed
  compressed family needs.

## (b) Accompanying edits the same upstream pass should make

1. **`ADEQUACY.md` section 7.1's "A1 is recorded as open. It is not asserted…" paragraph, and its
   "The one candidate … examined and rejected" subsection.** Both need rewriting. The
   `exists_annot_of_truth` rejection stands as *history* and should be kept as such, but all three
   of the reasons it was rejected for are now met by a **different** declaration,
   `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`: its hypothesis is
   presentation-free, its bound factors through the closure size alone, and its pigeonhole runs
   over subformula-set space (`FormalSystem.Metalogic.Decidability.TypeState`, cardinality
   `2^|C|`) rather than over presentation states. So the earlier route is **superseded, not
   patched** — the refuted small-model hypothesis is not repaired, it is no longer needed.

2. **`ADEQUACY.md` section 7.1's conditions (i)–(iii) status.** Condition (ii) is now discharged.
   Condition (i) is discharged **for the carrier** — the ℤ-time-to-ℤ normalization, via
   `FormalSystem.Semantics.validZTime_iff_validInt` — but **not for the premise context**: the
   consequence-form analogue of that normalization was never written. Condition (iii) is unchanged.

3. **`TRUST_PIPELINE.md`'s A-component table, A1 and A3 rows.** The same two updates as section (a)
   above. Additionally, that table's A3 row states A3 in the **wrong form**: it reads "configured
   lengths ≥ `f(|C|)`", the *magnitude* form, while `ADEQUACY.md` section 7's own A3 row states the
   *representability* form and explicitly says the magnitude form "can be false even when the
   underlying family exists". `TRUST_PIPELINE.md`'s row therefore contradicts both `ADEQUACY.md`
   and the three independent warnings the ProofChecker repository carries on this point (in
   `Compression/README.md`'s "The bound is a grid, not a magnitude", the same section of
   `Compression/Family.lean`'s module header, and `Compression/Assembly.lean`'s "The bound is a
   grid, and a consumer that folds by modulus needs to know"). Replace it with the
   representability form.

4. **`TRUST_PIPELINE.md`'s "In the Lean development" table, the "Compression (A1) and the verified
   bounded enumerator" row.** Its claim that "absence can be decided by verified code rather than
   by trusting Z3's UNSAT" is now **a theorem at restricted scope** — see
   `FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate` and
   `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`, with finiteness from
   `FormalSystem.Metalogic.Decidability.cands` and completeness from
   `FormalSystem.Metalogic.Decidability.mem_cands_of_bounded`. It is **not** a practical
   replacement, and the row should say so rather than implying a live capability. The measured
   numbers, taken by `#eval` on the live tree:

   | `φ` | `\|closureOf ([] ++ [φ])\|` | `compressionBound [] [φ]` |
   |---|---|---|
   | `p` | 1 | 6 |
   | `□p` | 2 | 20 |
   | `p U □p` | 3 | 56 |

   The candidate count is roughly `(2^k)^{3B(1+k)}`, so ≈`2^360` already at `|C| = 2`, against the
   ModelChecker repository's own exhaustive A2-triangle enumeration topping out at 10,485,760
   candidates at `nb = nf = 2`. There is also **no `lean_exe` target** that runs the enumerator:
   the ProofChecker repository's `lakefile.toml` declares fourteen executables, and the closest,
   `BimodalTools.CheckCertificateMain`, checks a *supplied* certificate (the soundness direction).
   `Compression.decidableValidZTime` is deliberately a `def`, not a global `instance`.

## (c) Citation-convention hand-off, and one already-drifted anchor

The ProofChecker repository now seeds the twenty-three declarations this conformance argument turns
on into `scripts/lean-citation-seeds.txt`, from which `scripts/lean-citation-manifest.json` is
generated and gate C35 (`scripts/check-module-invariants.sh`) keeps byte-current. Consequently the
fourteen `WitnessFamily/`-and-`Compression/` citations in the upstream documents can, and should,
move to the `name` + manifest convention the manifest's own `note` field prescribes, instead of
carrying `file.lean:NNN` anchors.

**Drift record (the one place this note gives a line number, as evidence of the failure mode).**
`ADEQUACY.md` currently cites `Agreement.lean:232` for
`FormalSystem.Metalogic.Decidability.WitnessFamily.joint_countermodel`. That anchor is stale: the
live keyword line is 248. The declaration's name never changed, and no gate in either repository
went red. This is exactly why the rows in section (a) cite names.

## (d) Two caveats that travel with the claims

1. **Verified absence is a theorem at restricted scope, not a replacement for trusting Z3 UNSAT.**
   The two sides quantify differently: the Lean criterion quantifies over the whole segment-length
   grid `[0, B]³` (that is what `cands` sweeps), whereas a Z3 UNSAT verdict is at **one** configured
   `(back, mid, fwd)`. Bridging a single UNSAT verdict to "no certified candidate on the grid" still
   needs A2 **and** A3's representability clause, and A3's `back`/`fwd` clause is open (section (a)).
   Add to that the absent executable and the candidate counts in (b)(4). The verified-absence
   *route* is proved to exist; it does not yet displace trusting Z3 UNSAT for any live example.

2. **The A1-Γ residue is bounded, not open-ended — and no effort estimate is promised.** The reason
   it is bounded is that `FormalSystem.Metalogic.Decidability.WitnessFamily.Refutes`,
   `FormalSystem.Metalogic.Decidability.WitnessFamily.refutes_of_certifies`,
   `FormalSystem.Metalogic.Decidability.WitnessFamily.joint_countermodel`,
   `FormalSystem.Metalogic.Decidability.exists_labelledLasso_of_history_realized`,
   `FormalSystem.Metalogic.Decidability.compressionBound` and all four `Decidable` instances are
   **already stated at arbitrary `Γ Del`**, so the general form needs a re-parameterization and one
   transfer lemma rather than a deduction-theorem development. What is genuinely `Γ = []`-specific
   is three things: the entry point's carrier normalization (the consequence analogue of
   `FormalSystem.Semantics.validZTime_iff_validInt`, built on
   `FormalSystem.Semantics.truthAt_map` at a fixed aligned triple),
   `FormalSystem.Metalogic.Decidability.WitnessFamily.Target`'s premise clause, and the
   φ-specialization of `closureSubsetsOf` / `rawLabelledLassos` / `IsLabelledLasso` /
   `boundedLassos` / `cands`. "Bounded" is a read of the live signatures, **not** a completed proof:
   the consequence-form carrier normalization has not been written, and nothing here should be read
   as a claim that the general form compiles or that a schedule has been committed to.

## Provenance

The verdict, the measurements and the row text above come from
`specs/693_a1_compression_conformance_adequacy_chain/reports/01_a1-compression-conformance.md` in
the BimodalLogic (ProofChecker) repository (Findings 1–5, Recommendations 1–2). Axiom closure of
every landed declaration cited: `{propext, Classical.choice, Quot.sound}`, sorry-free.
