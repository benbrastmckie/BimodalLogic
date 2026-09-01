# Verification Evidence: Task #516 (finalized metalogic documentation)

Per-claim evidence ledger. Every theorem name, file path, and status word written into
`README.md`, `FormalSystem/Metalogic.lean`, or `docs/project-info/implementation-status.md`
during this task must trace to a line below. Format: `claim | command run | result`.

## Tooling baseline (pre-edit)

- Full pass/fail verdict set of `bash scripts/check-module-invariants.sh` | `bash scripts/check-module-invariants.sh` | PASS: B0, C1 (lake build + BimodalTest), C2, C3, C4, C5, C8, C9, C10, C11, C12, C13, C14 (both sub-checks), C15. FAIL: **C6 only** — 4 unreachable live modules absent from `scripts/module-invariants-manifest.txt` (`FormalSystem.Metalogic.SpWitness`, `FormalSystem.Metalogic.TMCompletenessReduction`, `FormalSystem.Metalogic.Z1Countermodel`, `FormalSystem.Semantics.LexCarrier`) — pre-existing, per plan Overview/Research Integration, not a target of this task. TODO (non-exit-affecting): C9D, 138 task-number citations under `docs/` — out of scope. **This is the Phase 1 baseline** Phase 5 compares against; the expected/accepted failing-check set is `{C6}` and nothing else.
- `scripts/typst-status-counts.sh --json` counts | `bash scripts/typst-status-counts.sh --json` | `axiom_count=45, rule_count=7, base_count=37, dense_only_count=2, discrete_only_count=3, dedekind_only_count=3, sorry_total=4, sorry_total_excl_boneyard=0, sorry_algebraic=0, sorry_bxcanonical=0, sorry_bundle=0, sorry_weakcanonical=4, sorry_weakcanonical_excl_boneyard=0, sorry_other=0, stamp_commit=24d34c82b, stamp_date=2026-09-01`. Phase 5 must reproduce this byte-identically (task changes no count).

## Theorem-name and location re-verification

- `galoisClosed_mod` exists at `FormalSystem/Semantics/Correspondence/Galois.lean` | `grep -n galoisClosed_mod FormalSystem/Semantics/Correspondence/Galois.lean` | line 139: `theorem galoisClosed_mod (S : Set Formula) : GaloisClosed (Mod S) := mod_th_mod S`. Namespace `FormalSystem.Semantics`. Statement: every `Mod S` is Galois-closed (the "axiomatizable ⟺ Galois-closed" organizing equivalence).
- `galoisClosed_of_indicator` exists at same file | `grep -n galoisClosed_of_indicator FormalSystem/Semantics/Correspondence/Galois.lean` | line 158: `theorem galoisClosed_of_indicator {K : Set TaskFrame} (φ : Formula) ...` — the single-formula indicator mechanism. Namespace `FormalSystem.Semantics`.
- `galoisClosed_sat_dense` exists at `FormalSystem/Semantics/Correspondence/Indicator.lean` | `grep -n galoisClosed_sat_dense FormalSystem/Semantics/Correspondence/Indicator.lean` | line 133: `theorem galoisClosed_sat_dense : ...` — `Sat .Dense` is Galois-closed. Namespace `FormalSystem.Semantics`.
- `galoisClosed_isDiscrete` exists at same file | `grep -n galoisClosed_isDiscrete FormalSystem/Semantics/Correspondence/Indicator.lean` | line 151: `theorem galoisClosed_isDiscrete : ...` — `{F | F.IsDiscrete}` is Galois-closed. This is the **bare structural clause** `TaskFrame.IsDiscrete`, not the Hölder-to-`ℤ` narrowing `FrameClass.Sat FrameClass.Discrete` (see negative-result entries below, which are about the *narrowing* and are a different, non-closed class). Namespace `FormalSystem.Semantics`.
- `validOn_nextTop_iff` exists at same file | `grep -n "validOn_nextTop_iff\b" FormalSystem/Semantics/Correspondence/Indicator.lean` | line 90: `theorem validOn_nextTop_iff (F : TaskFrame) : ...` — indicator biconditional, `X⊤` indicates immediate successors.
- `validOn_nextTop_iff_isDiscrete` exists at same file | `grep -n validOn_nextTop_iff_isDiscrete FormalSystem/Semantics/Correspondence/Indicator.lean` | line 113: `theorem validOn_nextTop_iff_isDiscrete (F : TaskFrame) : ...` — same, against the guarded `TaskFrame.IsDiscrete` predicate.
- `sat_dedekind_ssubset_mod_axiomSet` exists at `FormalSystem/Metalogic/Independence/RationalWitness.lean` | `grep -n sat_dedekind_ssubset_mod_axiomSet FormalSystem/Metalogic/Independence/RationalWitness.lean` | line 181: `theorem sat_dedekind_ssubset_mod_axiomSet : {F : TaskFrame \| FrameClass.Sat FrameClass.Dedekind F} ⊂ Semantics.Mod (AxiomSet FrameClass.Dedekind)`. Docstring states explicitly: "Equivalently: `Sat .Dedekind` is not Galois-closed, since its `Mod (Th ·)` closure contains the witness [`ratStaticFrame`]." **Property proved: Galois-closedness of the model class `Sat .Dedekind`, not compactness of the consequence relation** — see C1 note below.
- `sat_discrete_ssubset_mod_axiomSet` exists at `FormalSystem/Metalogic/Independence/LexIntWitness.lean` | `grep -n sat_discrete_ssubset_mod_axiomSet FormalSystem/Metalogic/Independence/LexIntWitness.lean` | line 242: `theorem sat_discrete_ssubset_mod_axiomSet : {F : TaskFrame \| FrameClass.Sat FrameClass.Discrete F} ⊂ Semantics.Mod (AxiomSet FrameClass.Discrete)`. Docstring: "`Sat .Discrete` — the ℤ-time narrowing — is **not** Galois-closed. Contrast `Semantics.galoisClosed_isDiscrete`, which shows that the paper's bare Discrete class *is*." Witness frame: `lexIntStaticFrame`.
- `kampPriorExpressiveCompleteness` exists at `FormalSystem/Metalogic/WeakCanonical/Kamp/KampPrior.lean` | `grep -n kampPriorExpressiveCompleteness FormalSystem/Metalogic/WeakCanonical/Kamp/KampPrior.lean` | line 672: `noncomputable def kampPriorExpressiveCompleteness {sig : MonadicSignature} ... (psi : MonadicFormula sig 1) : { A : Formula // ∀ (M : OrderedMonadicStructure sig) (_h_prior_UZ : SemanticPriorUZ M atomMap) (_h_prior_SZ : SemanticPriorSZ M atomMap) (t : M.carrier), eval M (fun _ => t) psi ↔ TemporalTruth M atomMap t A }`. **Declared as `noncomputable def`, not `theorem`** — the Sigma-type packages the equivalent formula together with its correctness proof. File docstring: "every `MonadicFormula sig 1` has an equivalent `Formula` (using only U,S) on Prior structures. Same type signature as `uSExpressivelyCompleteOverPrior`." Scope: **Prior structures** (`OrderedMonadicStructure` + `SemanticPriorUZ`/`SemanticPriorSZ` hypotheses), not TM and not all task frames. Namespace `FormalSystem.Metalogic.WeakCanonical.Kamp`.

## Absence claims (constrain wording)

- No `CompactDedekind` declaration anywhere under `FormalSystem/` outside `Boneyard/` | `grep -rn CompactDedekind FormalSystem/ --include='*.lean' \| grep -v Boneyard` | 3 hits, all **prose mentions inside docstrings** (`Metalogic.lean:116`, `Metalogic/StrongCompleteness.lean:77,462`) stating that no such definition/theorem exists — zero actual `def`/`theorem CompactDedekind` declarations. Confirms the open-problem framing.
- No `StrongCompletenessDedekind`, `SatisfiableDedekindSet`, or `ModelExistenceDedekind` symbol under `FormalSystem/` outside `Boneyard/` | `grep -rn '<name>' FormalSystem/ --include='*.lean' \| grep -v Boneyard` (each name) | zero hits for all three.

## Axiom checks (live-tool, not copied from prior text)

- `kampPriorExpressiveCompleteness` axiom set | `mcp__lean-lsp__lean_verify` on `FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness` | `{"axioms":["propext","Classical.choice","Quot.sound"],"warnings":[]}` — matches the module's own docstring claim ("k≥2 ... sorry-free ... `[propext, Classical.choice, Quot.sound]`"), independently confirmed live.
- `galoisClosed_sat_dense` axiom set (Galois-closure positive result) | `mcp__lean-lsp__lean_verify` on `FormalSystem.Semantics.galoisClosed_sat_dense` | `{"axioms":["propext","Classical.choice","Quot.sound"],"warnings":[]}`.
- Sorry-free corroboration: `check-module-invariants.sh` C3 above confirms structural sorry inventory is ZERO across all of `FormalSystem/` (Boneyard excluded) as of this baseline, which covers both files above.

## C5 disclaimer (verbatim, for reuse)

Transcribed verbatim from `FormalSystem/Semantics/Correspondence/README.md`'s module table (also present, in equivalent form, in `Galois.lean`'s own `## Non-goals` docstring section):

> closed-form characterizations of `Mod (AxiomSet .Discrete)` and `Mod (AxiomSet .Dedekind)` are open and not promised.

`Galois.lean`'s own docstring phrasing (functionally identical, cites the paper's `TM+_f`/`TM+_c` notation instead of the Lean `AxiomSet` tags): "closed-form characterizations of Mod(TM+_f) and Mod(TM+_c) are OPEN and not promised — evidence: no variable-free BL+ sentence separates Z from Z ×ₗ Z or Q from R, and sep has no correspondent." **The `README.md`/table phrasing (`Mod (AxiomSet .Discrete)` / `Mod (AxiomSet .Dedekind)`) is the one to reuse in deliverable prose**, since it names the in-tree Lean tags the plan's other claims also use, rather than the paper's `TM+_f`/`TM+_c` shorthand.

## C1 grounding (two different facts about Dedekind, never merged)

- Fact A (proved, positive-by-negation): `sat_dedekind_ssubset_mod_axiomSet` proves `Sat .Dedekind` (the model class) is **not Galois-closed** — a fact about axiomatizability/definability of the model class.
- Fact B (open): Dedekind compactness / strong completeness is **unresolved** — no `CompactDedekind` definition and no refuting theorem exist anywhere in the tree (confirmed absent above). This is a fact about the consequence relation, not about Galois-closedness of the model class.
- These are different properties of the same frame class (`FrameClass.Dedekind`). Confirmed via `FormalSystem/Metalogic/StrongCompleteness.lean:77` and `:462`, which state the absence-of-refutation framing for Fact B independently of Fact A.

## Existing document context (for insertion-point and non-duplication checks)

- `docs/project-info/implementation-status.md`'s existing `Metalogic/Independence/` row (line 72): `| `Metalogic/Independence/` | ✅ | Three independence results |` — does not yet name `sat_dedekind_ssubset_mod_axiomSet` or `sat_discrete_ssubset_mod_axiomSet` by name; Phase 4 extends this row's notes cell per the plan rather than adding a duplicate row.
