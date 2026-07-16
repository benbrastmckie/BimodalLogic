# Phase 5 Summary: Section 5 correspondence guard; Prop 4.2 closed at the attained carrier

- **Task**: 377 - transcribe_rabinovich_faithful_nf_encoding
- **Phase**: 5 of 9 (single-phase dispatch; Phases 6-9 not started)
- **Plan**: `plans/02_section5-exists-carrier-rebase.md`
- **Status**: [COMPLETED]
- **Session**: sess_1784164229_854c1a

## What was accomplished

Phase 5 was scoped as "wiring plus a guard — no new mathematics", and it stayed that way.

### 1. The correspondence guard is live and CI-protected

New module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Section5Correspondence.lean`, imported
from `NfMultiAnchorBridge.lean` and therefore reachable from `Theories/Bimodal.lean`. It carries
the page-cited table mapping Rabinovich's Section 5 onto the in-tree names that already
transcribe it:

| Rabinovich (PDF page) | In-tree name | Location |
|---|---|---|
| Lemma 5.3 (p.8) | `negChainOn_iff` | `EANegationFix/OnBuilder.lean:159` |
| Lemma 5.1 (pp.9-10) | `BracketFormula.negFix_iff` | `EANegationFix/NegFix.lean:669` |
| Cor 5.4 (p.9) | `negBoundedRightFix_iff` + `negBoundedLeftFix_iff` | `EANegationFix/BoundedFix.lean:449`, `:768` |
| `Aᵢ`/`Bᵢ` split + closing induction (pp.10-11) | `negFixList` via `concatPin` + pinned `conjFull` | `EANegationFix/NegFix.lean:424` |
| Prop 4.2 / 4.3 De Morgan (p.6) | `VVecEA2.negFix_iff` | `EANegationFix/VecEANegFix.lean:164` |

The guard exists because this transcription was discoverable by `grep` for thirteen months and was
nonetheless re-planned from scratch — the research H3 table marked six present, sorry-free rows
ABSENT. A finding recorded only in a report gets re-derived; a reachable module breaks the build.

### 2. `prop42_contentful_of_attained` — sorry-free, axiom-clean

```
theorem prop42_contentful_of_attained (M) (atomMap)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap) (v : VVecEA2) :
    Prop42Contentful M atomMap v :=
  ⟨v.negFix, fun z0 z1 hlt => VVecEA2.negFix_iff M atomMap h_INF h_SUP v z0 z1 hlt⟩
```

This is v1 Phase 7's milestone — "the milestone the whole faithful path has been missing" —
reached by wiring, not transcription. `#print axioms` gives exactly
`{propext, Classical.choice, Quot.sound}`, no `sorryAx`. Landed as a new module;
`Prop42Contentful.lean` was not edited (it deliberately avoids `EANegationClosure`).

### 3. The live sorry at `Lemma53.lean:339` is retired

`lemma53` is now sorry-free. Its hypothesis was restated `HasDefinableINF` → `HasAttainedINF`,
and the `n ≥ 2` arm — the printed inductive step — is discharged from `negChainOn_iff`, which
already transcribes exactly that induction. The bridge was bookkeeping, not mathematics: both
`allTopBracket P` and `chainAllTrue Ps` are the same structure literal
(`{pointTypes := ·, segmentTypes := fun _ => ⊤}`), so `List.ofFn` plus a `Fin`-cast connects
them. Supporting lemmas added and reusable downstream: `allTopBracket_congr`,
`chainAllTrue_eq_allTopBracket`, `chainAllTrue_ofFn_iff_allTopBracket`,
`VBracketFormula.toVVecEA2` (+ `toVVecEA2_holds`), `allTopBracket_succ_lt`,
`negChainOn_holds_of_not_lt`.

**The sanctioned fallback was not needed.** The general statement is NOT re-homed to Phase 7.

### 4. Annotations and report correction

`OnBuilder.lean`, `NegFix.lean`, `VecEANegFix.lean` annotated in place with a guard pointer and a
one-line carrier delta. **Docstrings only — no proof body, statement, or hypothesis altered.**
Three `chunk_00NN` citations pointing into the corrupt `.md` conversion were re-cited by PDF page.
Five ABSENT rows plus the eq (5.2) UNVERIFIED row in `reports/01_faithful-nf-encoding-ruling.md`
were corrected, with the old text quoted verbatim and refuted rather than silently rewritten.

## What the carrier excludes (the extended non-vacuity rule)

`prop42_contentful_of_attained` is Prop 4.2 **restricted to attained structures**. It is **not**
Rabinovich's Prop 4.2 over all Dedekind complete chains. The strengthening chain:

```
Rabinovich's Dedekind completeness < HasDedekindINF (faithful) < HasDefinableINF < HasAttainedINF
                                                                                   ^ what is landed
```

`hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`, axiom-clean, preserved) machine-proves the
*weaker* `HasDefinableINF` is already too strong — it deletes the paper's disjunct (2) — so
`HasAttainedINF` is *a fortiori* too strong. `OnBuilder.lean` admits the deviation in its own
docstring. Concretely excluded: `ℝ` with `P₁ = {x | x > 0}`, `z₀ = 0` — Dedekind complete, handled
by the paper via disjunct (2), not covered here.

**`BracketFormula.negFix_iff` is INF-anchored and is NOT a refutation of the three-strikes ruling
on the model-independent Prop 4.2 backward direction — it confirms that ruling's diagnosis.**

## Verification results

| Gate | Result |
|---|---|
| `lake build …Kamp.Section5Correspondence` | **EXIT 0** (1001 jobs) |
| `#print axioms prop42_contentful_of_attained` | **`{propext, Classical.choice, Quot.sound}`** — no `sorryAx` |
| `#print axioms lemma53` (regression check) | **`{propext, Classical.choice, Quot.sound}`** — no `sorryAx` |
| `#print axioms hasDefinableINF_excludes_kplus` | axiom-clean — preserved asset intact |
| Failed-vacuity check | **EXECUTED, both halves** — control compiles EXIT 0, refutation fails EXIT 1 |
| Tactic-position sorry census over `Kamp/` | 5 total; `Lemma53.lean:339` **retired** |
| Reachability (import-graph walk) | **238 modules, up exactly 1**; walker validated vs live+dead controls |
| Full `lake build` | **EXIT 0, 1765 jobs — up exactly 1, as predicted** |
| Vacuous definitions | 0 |
| New axioms | 0 |

### Failed-vacuity check, recorded verbatim

The all-`⊤` witness that discharges the *vacuous* shape from no hypotheses, offered against
`Prop42Contentful`, does **not** typecheck:

```
error: Type mismatch
  topVVec_holds M atomMap z0 z1
has type
  VVecEA2.holds M atomMap topVVec z0 z1
but is expected to have type
  VVecEA2.holds M atomMap topVVec z0 z1 ↔ ¬VVecEA2.holds M atomMap v z0 z1
```

The mismatch **is** the finding: it is the gap between "some block holds here" (vacuous, free) and
"this block is equivalent to `¬v`, uniformly" (contentful). Both halves are recorded reproducibly
in `reports/04_prop42-failed-vacuity-probe.lean`, whose control half is compiler-checked.

**Limit of this check**: it establishes the *shape* is non-vacuous. It says nothing about the
*carrier* — that is the separate obligation discharged in prose above and in the module docstring.

## Findings for the orchestrator

1. **HIGH — the gate "no live `sorryAx` outside `KampPrior.lean:520`" is factually wrong at
   baseline.** `EANegation.lean:1090` and `:1249` are live and were **already live at the Phase 4
   baseline** (verified by running the import-graph walker on a worktree at commit `341c4906e`:
   237 modules, `EANegation` LIVE). Phase 4's claim that `Lemma53.lean:339` was the only live sorry
   was incomplete. Phase 5 introduced none and retired one. Both are the model-independent Prop 4.2
   backward direction — the ruled-**unfixable** three-strikes target — so they were correctly not
   attempted. **The gate must be amended** to name them, or it will fail every future dispatch on a
   pre-existing, prohibited-to-fix condition.
2. **INFO — Phase 7 scope reduced.** The bridge closed, so lemma53's general statement is not
   re-homed. Phase 7 should not budget for it.
3. **INFO — reusable primitives.** `VBracketFormula.toVVecEA2` is the lift Phase 7's faithful
   `Oₙ` (which must be `VVecEA2`, per the upheld canary) will need. Reuse, don't rebuild.

## Plan deviations

None. All six Phase 5 checklist items executed as written. The one sanctioned fallback was
available but not needed.

## Preserved assets (verified untouched)

`hasDefinableINF_excludes_kplus` and the Basis (not deleted, re-verified axiom-clean);
`KampPrior.lean:520` (task 358's gate, not touched); all `EANegationFix/` theorems (docstring
annotations only); `Kamp/Boneyard/*` (untouched). No file deleted; no declaration excised.
