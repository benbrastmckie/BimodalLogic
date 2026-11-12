# Research Report: Task #899

**Task**: 899 - The stability cluster's (past-type, future-type) set is a full product
**Started**: 2026-11-12T02:01:34Z
**Completed**: 2026-11-12T02:08:04Z
**Effort**: medium (implementation is a single file edit plus one theorem-index row; the proof is
already written and compiles)
**Dependencies**: None
**Sources/Inputs**: - Codebase (`FormalSystem/PlusLanguage/PlusPasting.lean`,
`FormalSystem/OpenLanguage/OpenClasses.lean`,
`FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`,
`FormalSystem/Metalogic/Expressiveness/SeparationZ/Discharge.lean`,
`FormalSystem/Metalogic/AuxiliaryAtoms.lean`, `docs/theorem-index.md`,
`scripts/check-module-invariants.sh`), compiled probes via `lake env lean`
**Artifacts**: - `specs/899_stability_cluster_type_product_lemma/reports/01_stability-cluster-type-product.md`
- `specs/899_stability_cluster_type_product_lemma/probes/01_type-product.lean` (compiles clean)
- `specs/899_stability_cluster_type_product_lemma/probes/02_sepz-plug-point.lean` (compiles clean)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The target lemma is already proved.** A complete, sorry-free, warning-free formalization of
  the product statement — plus three companion results — compiles against the current tree. Both
  probe files are in `specs/899_stability_cluster_type_product_lemma/probes/`. The proof route is
  exactly the one the task description names: `paste` + `paste_agreeUpTo` + `paste_agreeFrom` +
  the semantic `PastDet`/`FutDet` predicates. No new infrastructure, no Mathlib search, no new
  lemma about `TaskFrame` is needed.
- **The declared `file_scope` is import-infeasible and must be corrected.**
  `FormalSystem/PlusLanguage/PlusPasting.lean` cannot see `PastDet`, `FutDet` or `stabClass`:
  those live strictly downstream of it. Siting the lemma there would create an import cycle.
  Correct home: `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`.
- **The architectural framings in the task description are forward-looking, not present
  consumptions.** There is no Auxiliary-Atoms *automaton* in the tree (`AuxiliaryAtoms.lean` is a
  derivation-rule soundness proof, `aa_sound_int` / `aa_sound_ztime`), and
  `separationOver_ztime` is today consumed only by `tr` / `exists_translation_ztime`. The lemma
  *creates* a new `SepClauses`-shaped plug point for `separationOver_ztime`; it is not currently
  "the exact point" at which that theorem is consumed. Both claims should be softened in the
  eventual docstring rather than asserted.
- **Recommended approach**: land four declarations in `OpenFutureElimination.lean` — two type
  definitions, the product theorem, the state-congruence corollary, and the `SepClauses`-fed
  corollary — then add one `docs/theorem-index.md` row whose Axioms cell reads the *measured*
  `[propext, Quot.sound]`, not `pcq`.

## Context & Scope

Researched: what the task's informal statement ("the set of pairs (past-type, future-type)
realized by histories through `τ.state t` at `t` equals the product of the set of realized
past-types and the set of realized future-types") becomes as a Lean 4 statement over this tree's
own vocabulary; where it can legally be sited; whether the route named in the task description
actually works; and what repository gates a new declaration plus theorem-index row must clear.

Constraints honoured: zero-debt (no `sorry`, no axiom, no vacuous definition); H3 reference
grounding (Tier 3, implementation-backed — no literature source is referenced by this task, see
"Literature source" below); H4 adversarial verification (every load-bearing claim below carries a
named verification method and a confidence tag); H2 (a compiling proof, not an analysis, is the
deliverable of this research phase).

**Literature source**: none referenced by the task description. The Literature Extraction
Protocol does not apply. The closest adjacent literature is GHR vol. 1 Theorem 10.2.9 (Gabbay
separation over `ℤ`), already discharged in-tree as `separationOver_ztime`; the product lemma
itself is formalization-native and has no paper counterpart, so its theorem-index Paper-label
cell is `—`.

## Findings

### Codebase Patterns

**1. The two agreement predicates and the pasting lemmas are exactly as needed, with the
orientation that makes the proof one line each.** Verified by direct read of
`FormalSystem/PlusLanguage/PlusPasting.lean`:

```
AgreeFrom τ σ t  :=  ∀ s, t ≤ s → τ.state s = σ.state s        -- line 243
AgreeUpTo τ σ t  :=  ∀ s, s ≤ t → τ.state s = σ.state s        -- line 247
paste_agreeFrom ρ σ t hsame : AgreeFrom (paste ρ σ t hsame) σ t  -- line 259
paste_agreeUpTo ρ σ t hsame : AgreeUpTo (paste ρ σ t hsame) ρ t  -- line 271
```

The pasted history's *first* argument supplies the past and its *second* the future, and both
agreement lemmas are oriented with the pasted history on the left — which is the orientation
`PastDet`/`FutDet` consume without a `.symm`. Confidence: **High** (direct source read, plus the
compiled probe, which would have failed on either a wrong orientation or a wrong argument order).

**2. `PastDet` / `FutDet` are stated as invariance under exactly those two predicates.** Verified
by direct read of `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` lines
165-174:

```
PastDet F φ := ∀ (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration),
                 AgreeUpTo τ σ t → (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ)
FutDet  F φ := ∀ (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration),
                 AgreeFrom  τ σ t → (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ)
```

That module's own docstring (lines 110-116) records why these are semantic rather than syntactic:
the separated forms the Dedekind-complete separation theorem returns are future-determined
without being syntactically pure. The task's insistence on the *semantic* predicates is therefore
correct and not interchangeable with `IsPurePast` / `IsPureFuture`. Confidence: **High** (module
docstring plus the two bridge theorems `pastDet_of_isPurePast` / `futDet_of_isPureFuture` at lines
177-184).

**3. The "stability cluster" is already named: `stabClass`.** Verified by direct read of
`FormalSystem/OpenLanguage/OpenClasses.lean` line 73:
`stabClass τ x : Set (WorldHistory F) := {σ | τ.state x = σ.state x}`. That file's docstring
already asserts the *history-level* product fact and names its witness:

> `paste_mem_openFutureClass_inter_openPastClass` — ... It is why `⟨τ⟩_x` is the *product* of the
> open pasts and the open futures at `x`

So this task is the **formula-level (type-level) image** of a product statement whose
history-level form is already in the tree (`OpenClasses.lean` line 145). The new lemma should
cite that precedent rather than restate the geometry. Confidence: **High** (two independent
sources: the file docstring at line 46 and the theorem at line 145, both read directly).

**4. The declared `file_scope` is import-infeasible.** `OpenFutureElimination.lean` imports
`FormalSystem.OpenLanguage`, which imports `FormalSystem.OpenLanguage.OpenClasses`, which imports
`FormalSystem.PlusLanguage.PlusPasting`. The chain is therefore
`PlusPasting → OpenClasses → OpenLanguage → OpenFutureElimination`, and `PlusPasting.lean` sits
*upstream* of both `PastDet`/`FutDet` and `stabClass`. Verification method: a compiled probe
importing only `FormalSystem.PlusLanguage.PlusPasting` and `#check`ing both names:

```
error(lean.unknownIdentifier): Unknown identifier `FormalSystem.Metalogic.Expressiveness.PastDet`
error(lean.unknownIdentifier): Unknown identifier `FormalSystem.OpenLanguage.stabClass`
```

Confidence: **High** (compiled negative result, corroborated by reading all four `import` lines).

**5. There is no Auxiliary-Atoms automaton in the tree.** `FormalSystem/Metalogic/AuxiliaryAtoms.lean`
contains the Reynolds §7 *rule-soundness* development: `aaRun`, `aaState`, `aaStep`, `aaExcl`,
`aaAnte`, `aaModel`, `aaIdx_*`, and the three soundness theorems `aa_sound_int`,
`aa_sound_ztime`, `aa_reflectTime_sound_ztime`. A repo-wide grep for `automaton|automata` over
`FormalSystem/` returns only four hits, every one of them a docstring *disclaimer* that no
automaton is built (`Decidability/RaySummary/Profile.lean` lines 50 and 71,
`RaySummary/Periodic.lean` line 65, `MintBound/GapPotential.lean` line 78). Confidence: **High**
(grep over the library plus a declaration-level read of `AuxiliaryAtoms.lean`).

**6. `separationOver_ztime`'s only present consumer is the translation.** It is defined at
`SeparationZ/Discharge.lean` line 150 and referenced from `Expressiveness.lean`,
`OpenFutureElimination.lean` (docstrings) and `SeparationZ/Computable.lean`; the theorem it feeds
is `tr` / `exists_translation_ztime`. The reusable component for this task is the *clause-list*
half, `sepZ_sepClauses φ F hreg hz : SepClauses F (sepZ φ)` (line 109), which the compiled probe
`02_sepz-plug-point.lean` shows plugs directly into the new lemma. Confidence: **High** (grep
for every `separationOver_ztime` occurrence plus a compiled instantiation).

### External Resources

No Mathlib search was required: the proof uses only `Set.image`, `Set.prod` (`×ˢ`),
`and_congr_right`, `List.mem_map` and `le_rfl`, all of which the compiled probes exercise
successfully. Consequently no `lean_leansearch` / `lean_loogle` / `lean_leanfinder` call was
made — this is reported rather than concealed, since H2's forbidden conclusion list bars claiming
"Mathlib likely has a lemma" *without* searching; here no Mathlib lemma is being claimed at all.

Repository gates a new declaration + theorem-index row must clear, read from
`scripts/check-module-invariants.sh` and `docs/theorem-index.md`'s "How to read a row":

| Gate | What it asserts | Consequence for this task |
|------|-----------------|---------------------------|
| C2 | Axiom sets pinned for indexed theorems; the Axioms column is generated from the baseline, never typed | New row's Axioms cell must be the measured value; baseline must be regenerated |
| C15 (second assertion) | Every theorem-index row is anchored at its declaration; Paper-label pinned in `docs/reference/paper-definitions-of-record.md` | Paper label is `—` (formalization-native), matching `ofutP_or_iff`'s own precedent |
| C16 | env_linter batch incl. `docBlame` | Every new `def`/`theorem` needs a docstring |
| C23 | No `lemma` declarations | Use `theorem` |
| `lean4.md` vacuity rule | No `def X := True`, no `noncomputable` `Decidable`-valued decl | Not triggered: the type definitions are plain `Set`-valued `def`s and compile computably |

Confidence: **High** for the C2/C15 rows (`docs/theorem-index.md` lines 14-19 state the
generated-not-typed rule verbatim and name the regeneration command
`bash scripts/check-module-invariants.sh`); **Medium** for C16/C23 (read from the check script's
own header comments at lines 3536 and 4103, not from an executed run of the check against a
candidate edit).

### Recommendations

**R1 — Site the lemma in `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`, not
in `FormalSystem/PlusLanguage/PlusPasting.lean`, and amend `file_scope` accordingly.**
[VERIFIED: PASS -- a probe importing only `FormalSystem.PlusLanguage.PlusPasting` and `#check`ing
`PastDet` and `stabClass` fails with two `unknownIdentifier` errors (`lake env lean`), while the
full four-declaration body compiles clean under
`import FormalSystem.Metalogic.Expressiveness.OpenFutureElimination`
(`specs/899_stability_cluster_type_product_lemma/probes/01_type-product.lean`, `lake env lean`,
exit 0, no diagnostics)]

Rationale beyond the hard import constraint: `OpenFutureElimination.lean` already owns `PastDet`,
`FutDet`, `SepClauses`, `OfutP`/`OpastP` and the two `*_or_iff` eliminations that use the very
same `paste`-across-the-seam argument. The product lemma is the set-level restatement of
`ofutP_or_iff`'s `→` half and belongs beside it.

**R2 — Land these four declarations, in this order, with the bodies as compiled.**
[VERIFIED: PASS -- all four compile sorry-free and warning-free via
`timeout 900 lake env lean specs/899_stability_cluster_type_product_lemma/probes/01_type-product.lean`
(exit 0, empty output)]

```lean
def pastType (M : TaskModel F) (A : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula := {φ | φ ∈ A ∧ PlusTruthAt M σ t φ}

def futType (M : TaskModel F) (B : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula := {ψ | ψ ∈ B ∧ PlusTruthAt M σ t ψ}

def typePair (M : TaskModel F) (A B : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula × Set PlusFormula := (pastType M A σ t, futType M B σ t)

theorem typePair_image_stabClass [F.IsRegular]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (A B : List PlusFormula)
    (hA : ∀ φ ∈ A, PastDet F φ) (hB : ∀ ψ ∈ B, FutDet F ψ) :
    (fun σ => typePair M A B σ t) '' stabClass τ t
      = ((fun σ => pastType M A σ t) '' stabClass τ t)
        ×ˢ ((fun σ => futType M B σ t) '' stabClass τ t)
```

plus `typePair_image_stabClass_state_congr` (the realized set depends only on `τ.state t`) and
`typePair_image_stabClass_of_sepClauses` (a `SepClauses F L` hypothesis supplies both `hA` and
`hB` via `L.map Prod.fst` / `L.map Prod.snd`). The exact proof bodies are in probe 01; the plan
should transcribe them rather than re-derive. The `⊆` direction is three lines; the `⊇` direction
is the `paste ρ σ t hsame` construction with `paste_agreeUpTo`/`paste_agreeFrom` feeding
`hA`/`hB` through `and_congr_right`.

**R3 — Add exactly one `docs/theorem-index.md` row, for `typePair_image_stabClass`, with Paper
label `—`, Frame class `—`, and Axioms cell `[propext, Quot.sound]` — not `pcq`.**
[VERIFIED: PASS -- `#print axioms` measured under `lake env lean`:
`'typePair_image_stabClass' depends on axioms: [propext, Quot.sound]`;
`typePair_image_stabClass_state_congr` and `typePair_image_stabClass_of_sepClauses` likewise
`[propext, Quot.sound]`; only the `sepZ`-instantiated form reaches
`[propext, Classical.choice, Quot.sound]` (= `pcq`)]

This is the gate check that matters most for the deliverable: `docs/theorem-index.md`'s own
"How to read a row" states the Axioms column "is generated from those baselines, never typed", so
a hand-typed `pcq` would be both wrong and caught. The row must also be accompanied by a C2
baseline regeneration (`bash scripts/check-module-invariants.sh`). Frame class is `—` because the
theorem is class-generic: it needs `[F.IsRegular]` only (for `paste`), never `IsZTime`.

**R4 — State the architecture claims in the docstring as the design intent they are, not as
present consumptions.** [No compiled gate applicable]

Specifically: do *not* write that this lemma "initializes the forward and backward Auxiliary-Atoms
automata" (no automaton exists — Finding 5) or that it is "the exact point at which
`separationOver_ztime` is consumed" (its present consumer is `tr` — Finding 6). Write instead
that it supplies the state-level datum such an initialization would read, and that
`typePair_image_stabClass_of_sepClauses` is the slot a separated clause list — including the one
`separationOver_ztime` returns — plugs into. This matters under
`.claude/rules/no-record-versioning-in-deliverables.md`-adjacent discipline and under C14's
status-claim tripwires: an overstated docstring claim about a consumer that does not exist is a
status claim.

**R5 — Add a non-vacuity note (or, better, a counterexample-shaped remark) showing `hA`/`hB` are
load-bearing.** [VERIFIED: FAIL -- no compiled gate was run against this recommendation; C36
(non-vacuity of certificate classes) was inspected and does **not** cover plain semantic theorems
of this shape, so no existing gate decides it. Revised to: treat it as a plan-time obligation
rather than a research-phase claim, scoped to a docstring remark with the argument sketch below,
and explicitly *not* as a new Lean declaration unless the planner judges the countermodel cheap]

The argument sketch the remark should carry: take `A := [β]` for a `β` that is future-determined
but not past-determined. Then `pastType M A ·` *is* the future-type function, so the right-hand
side becomes the full square of a single image, while the left-hand side is confined to its
diagonal — the equality fails as soon as two distinct values are realized in `stabClass τ t`.
Confidence in the sketch: **Medium** (reasoned from the definitions, not yet machine-checked; a
concrete countermodel over `intOrder` was not constructed).

## Decisions

- **Two separate lists `A B : List PlusFormula` with pointwise hypotheses is the primary shape**,
  with the `SepClauses F L` clause-pair form as a derived corollary over `L.map Prod.fst` /
  `L.map Prod.snd`. Reason: the past-type and the future-type are indexed independently in the
  intended consumer (a forward automaton reads future-determined formulas, a backward one reads
  past-determined formulas), and nothing in the product statement pairs the `i`-th past formula
  with the `i`-th future one. The clause-pair corollary exists precisely so `separationOver_ztime`
  / `sepZ` plug in without reshaping.
- **The type is `Set PlusFormula`, not a `List Bool` or a `Finset`.** A `Bool`-valued type would
  need `Decidable (PlusTruthAt M σ t φ)`, which is unavailable in general and whose classical
  inhabitant would force `noncomputable` — and a `noncomputable` decidability-flavoured
  declaration is the exact vacuity trap `rules/lean4.md` prohibits and whose worked instance
  `OpenFutureElimination.lean`'s own docstring records. The `Set`-valued form compiles computably
  as a plain `def`.
- **`stabClass τ t` is the index set on both sides of the product**, rather than
  `openPastClass`/`openFutureClass` on the factors. This is what makes the statement non-trivial:
  the `⊇` direction is where `paste` and `[F.IsRegular]` are consumed.
- **The state-congruence companion is kept despite being cheap** (it needs neither `[F.IsRegular]`
  nor the determinedness hypotheses — it follows from `stabClass`'s definition alone). It is the
  declaration that literally says "state-level datum", which is the task's architectural point,
  and its cheapness should be stated in its docstring rather than hidden.

## Risks & Mitigations

- **Risk**: the plan re-derives its own decomposition and lands a weaker same-named statement
  (e.g. dropping the `×ˢ` for a one-directional `⊆`, or specialising `A`/`B` to syntactically pure
  formulas). **Mitigation**: the plan should carry a `## Lean Challenge Statements` section
  pinning `typePair_image_stabClass`'s full signature verbatim from probe 01, so
  `lean-challenge-snapshot.sh --check` has something to compare against;
  `.claude/rules/plan-compliance.md`'s Statement Fidelity clause then applies.
- **Risk**: `file_scope` is not amended and the implementer attempts `PlusPasting.lean`, hits the
  import wall, and "solves" it by moving `PastDet`/`FutDet` upstream. **Mitigation**: R1 is
  explicit, and the move is independently undesirable — `OpenFutureElimination.lean`'s docstring
  (lines 110-116) justifies those predicates' placement, and `LeafAbstraction.lean` and
  `OpenFutureUndefinable.lean` both consume them from there.
- **Risk**: the theorem-index row's Axioms cell is typed as `pcq` by analogy with neighbouring
  rows. **Mitigation**: R3 carries the measured value and the measurement command; the
  `[propext, Quot.sound]` profile is genuinely unusual in this ledger and will look like an error
  to a reviewer who does not read the measurement.
- **Risk**: C16's `docBlame` fails the build because one of the three new `def`s ships without a
  docstring. **Mitigation**: probe 01 already carries docstrings on all four declarations;
  transcribe them.
- **Risk (concurrency)**: tasks 905 and 906 are dispatched this same cycle with no declared
  `file_scope`. `docs/theorem-index.md` is a known shared surface (the audit verdict for this task
  lists 80+ `overlaps-open` rows, nearly all of them sharing exactly that file). **Mitigation**:
  per the dispatch's Territory block, re-read `docs/theorem-index.md` immediately before editing,
  stage only this task's own hunk, and treat a foreign modification as a sibling's in-flight edit
  rather than a regression.

## Tactic Survey Results

No `lean_multi_attempt` survey was performed: the proof was developed directly as a compiled
probe, which is strictly stronger evidence than a tactic-candidate sweep. The table records what
was actually measured.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `(fun σ => typePair …) '' stabClass τ t = … ×ˢ …`, `⊆` half | `rintro ⟨σ, hσ, rfl⟩; exact ⟨⟨σ, hσ, rfl⟩, ⟨σ, hσ, rfl⟩⟩` | success | none |
| same, `⊇` half: membership of the pasted history in `stabClass τ t` | `exact hρ.trans (paste_agreeUpTo ρ σ t hsame t le_rfl).symm` | success | `paste_agreeUpTo` |
| `pastType M A (paste ρ σ t hsame) t = pastType M A ρ t` | `ext φ; exact and_congr_right fun hmem => hA φ hmem M _ ρ t (paste_agreeUpTo …)` | success | `PastDet`, `paste_agreeUpTo`, `and_congr_right` |
| `futType M B (paste ρ σ t hsame) t = futType M B σ t` | `ext ψ; exact and_congr_right fun hmem => hB ψ hmem M _ σ t (paste_agreeFrom …)` | success | `FutDet`, `paste_agreeFrom`, `and_congr_right` |
| closing `(pastType …, futType …) = p` | `rw [h1, h2, show … = p.1 from hp1, show … = p.2 from hp2]` | success (first attempt `rw [← hp1, ← hp2]` failed: "Did not find an occurrence of the pattern `p.1`") | relies on structure-eta for `(p.1, p.2) = p` |
| `stabClass τ t = stabClass τ' t` from `τ.state t = τ'.state t` | `ext σ; exact ⟨fun hs => h.symm.trans hs, fun hs => h.trans hs⟩` | success | none (no `[F.IsRegular]`, no determinedness) |
| `SepClauses`-fed hypothesis discharge | `obtain ⟨c, hc, rfl⟩ := List.mem_map.mp hφ; exact (hL c hc).1` | success | `List.mem_map` |

## Adversarial Self-Verification

- **Claim**: "the task's named proof route works." **Method**: the route was not argued, it was
  compiled — `lake env lean` on probe 01, exit 0, empty diagnostics, all four declarations
  sorry-free. **Confidence**: High (compiled artifact plus a direct read of all four cited
  lemma signatures).
- **Claim**: "`PlusPasting.lean` cannot host the lemma." **Method**: compiled negative probe
  (two `unknownIdentifier` errors) corroborated by reading the four-link import chain in the
  source. Two independent sources agree. **Confidence**: High.
- **Claim**: "no Auxiliary-Atoms automaton exists." **Method**: repo-wide grep for
  `automaton|automata` over `FormalSystem/` (4 hits, all docstring disclaimers that no automaton
  is built), plus a declaration-level listing of `AuxiliaryAtoms.lean` (25 declarations, all
  rule-soundness machinery), plus the four `docs/theorem-index.md` rows mentioning
  Auxiliary-Atoms (all soundness/closure results). Three independent sources, no conflicting
  evidence. **Confidence**: High.
- **Claim**: "the Axioms cell is `[propext, Quot.sound]`." **Method**: `#print axioms` on each
  declaration under `lake env lean`. Single authoritative source, but it is the same mechanism
  the C2 baseline itself uses, and the two probes agree with each other. **Confidence**: High.
- **Claim**: "`hA`/`hB` are load-bearing." **Method**: inspection of the proof term's dependency
  structure only — the hypotheses are consumed in `h1`/`h2`, which the closing `rw` depends on.
  No countermodel was constructed, and no gate exists that decides it (C36 covers certificate
  classes, not semantic theorems of this shape). **Confidence**: Medium. This is the one claim in
  the report that is not cross-checked, and R5 records it as a plan-time obligation rather than a
  settled finding.
- **Contradiction found and resolved**: the task description's `file_scope`
  (`PlusPasting.lean`) conflicts with the import graph. Resolution by the H4 precedence ranking —
  directly-read Lean source and a compiled probe outrank a prose task description — yields R1.
  No `UNRESOLVED CONTRADICTION` remains.

## Context Extension Recommendations

- **Topic**: import-direction feasibility as a task-creation-time check.
  **Gap**: `.claude/context/project/lean4/patterns/plan-authoring-gate-collisions.md` covers gate
  collisions but nothing covers the cheaper and more common failure seen here — a task whose
  declared `file_scope` sits *upstream* of the vocabulary its own description names, which no
  existing check catches and which only becomes visible when an implementer hits an
  `unknownIdentifier`.
  **Recommendation**: add a short "Import-Direction Feasibility" section to
  `.claude/context/project/lean4/patterns/plan-authoring-gate-collisions.md` prescribing the
  two-line `#check` probe used in Finding 4 as a standard research-phase step whenever a task
  description names identifiers from more than one module.

## Appendix

**Searches and reads performed** (all local; no rate-limited Mathlib search tool was needed):

- `grep` for `PastDet|FutDet` across `--include=*.lean` (3 files)
- `grep` for `separationOver_ztime` across `--include=*.lean` (15 occurrences, 6 files)
- `grep` for `agreeUpTo_equivalence|agreeFrom_equivalence`, `stabClass`, `×ˢ`, `automaton|automata`
- bounded `Read`/`sed -n` of `PlusPasting.lean` (lines 92-140, 240-330), `OpenClasses.lean`
  (lines 1-220), `OpenFutureElimination.lean` (lines 100-200, 240-360),
  `SeparationZ/Discharge.lean` (lines 105-155), `docs/theorem-index.md` (lines 1-40 and the four
  Auxiliary-Atoms rows), `scripts/check-module-invariants.sh` (check-header comments)
- declaration-level listing of `FormalSystem/Metalogic/AuxiliaryAtoms.lean`
- `jq` read of `specs/evidence/audit-verdicts/899.json` (86 verdicts; the sole shared path across
  the overlap rows is `docs/theorem-index.md`, which is a ledger-contention signal, not a
  semantic duplication signal)

**Compiled probes**

| Probe | Command | Result |
|-------|---------|--------|
| `probes/01_type-product.lean` | `timeout 900 lake env lean …` | exit 0, no diagnostics; 4 declarations |
| `probes/02_sepz-plug-point.lean` | `timeout 900 lake env lean …` | exit 0, no diagnostics; adds the `sepZ`-instantiated corollary |
| scratch scope probe | `lake env lean` on a `PlusPasting`-only import | 2 `unknownIdentifier` errors (the intended negative result) |

**Axiom measurements** (`#print axioms`)

```
typePair_image_stabClass              : [propext, Quot.sound]
typePair_image_stabClass_state_congr  : [propext, Quot.sound]
typePair_image_stabClass_of_sepClauses: [propext, Quot.sound]
typePair_image_stabClass_sepZ         : [propext, Classical.choice, Quot.sound]   -- = pcq
```

**References**

- `FormalSystem/PlusLanguage/PlusPasting.lean` — `pasteFun`, `paste`, `AgreeUpTo`, `AgreeFrom`,
  `paste_agreeUpTo`, `paste_agreeFrom`
- `FormalSystem/OpenLanguage/OpenClasses.lean` — `stabClass`, `openFutureClass`, `openPastClass`,
  `paste_mem_openFutureClass_inter_openPastClass`
- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` — `PastDet`, `FutDet`,
  `SepClauses`, `ofutP_or_iff`, `opastP_or_iff`
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Discharge.lean` — `sepZ`, `sepZ_sepClauses`,
  `separationOver_ztime`
- `docs/theorem-index.md` — "How to read a row" (the generated-not-typed Axioms rule)
- GHR vol. 1, Theorem 10.2.9 — the separation theorem `separationOver_ztime` discharges (cited
  here for orientation only; no claim in this report rests on it)
