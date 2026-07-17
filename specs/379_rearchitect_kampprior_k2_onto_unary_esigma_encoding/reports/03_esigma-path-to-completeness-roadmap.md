# Path to Full Kamp Completeness (`completeness_discrete` → zero live sorry)

**Scope:** READ-ONLY research. No Lean files edited. Baseline is the tree as of task 381 v2
completion (build floor **1765 jobs**, per `specs/381_.../summaries`). `lake build` was not
re-run; the axiom/proof-term facts below are triangulated from the byte-identical axiom audit
committed in task 381 and the machine-checked proof-term-walk probes committed in task 379
(`specs/379_.../reports/01_arity-growth-sizing-probe.lean`, `02_consumption-walk-probe.lean`,
both EXIT 0), plus grep/decl-reachability checks and a fresh read of the Rabinovich PDF.

**Headline:** The single remaining on-path hole (`KampPrior.lean:562`) is **not a missing
lemma**. Task 379 already adjudicated (machine-checked) that discharging it in the present
architecture requires off-paper novel mathematics (an arity-4 realization engine /
Feferman–Vaught composition) that Rabinovich never incurs. The faithful path to zero sorry is a
**prerequisite re-architecture** onto Rabinovich's E[Σ] unary-alphabet expansion (Def 4.1). That
program has a cheap, decisive **GO/NO-GO gate** that must run first.

---

## 1. Live sorry / axiom inventory of the completeness spine

**Main theorem:** `Bimodal.Metalogic.BXCanonical.completeness_discrete` —
`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:275`.

**Proof-term axiom set** (from the in-file audit block at `Completeness.lean:341–372`, confirmed
byte-identical by task 381 after every archival batch):
```
propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound
```
`Classical.choice`, `propext`, `Quot.sound` are standard; `Lean.ofReduceBool`/`Lean.trustCompiler`
come from `native_decide` in the Syntax layer (not sorry-related). The **sole `sorryAx`
contributor** traces:

```
completeness_discrete
 → countermodel_discrete_reynolds_v2 → …no_gaps_discrete_model_surgery
 → US_expressively_complete_over_prior → kamp_prior_expressive_completeness
 → nf_characterizable_temporal_prior → nf_nvar_exist_all_depths  ← the sorry lives here
```
Probe 02 (`02_consumption-walk-probe.lean`) walked 14,466 transitive deps and confirmed this
chain is value-reached, and that `no_gaps_discrete_model_surgery` itself carries `sorryAx`.

### The one live, on-path sorry

| Site | Decl | Statement it stubs | Rabinovich correspondence | On `completeness_discrete` proof term? |
|---|---|---|---|---|
| **`KampPrior.lean:562`** | `nf_nvar_exist_all_depths`, the `\| _k + 2 =>` arm | For `sub_nf : NormalForm sig (k+3) 2` (k≥2), produce a Prior/TL formula equivalent to the depth-(k+1) arity-2 existential Hintikka type | **Prop 3.5** (p.5) realized on the wrong object; the k≥2 arm is where the repo's arity-growth encoding forces an **arity-4 joint type** absent from the paper | **YES — this is the blocker.** Value-reached for every input formula of quantifier depth ≥ 2 (`k := psi.quantifier_depth` is arbitrary at `kamp_prior_expressive_completeness`). |

Note: the sibling arm `KampPrior.lean:571` (`| _n + 2 =>`) is **not** a sorry — it is
`absurd hn2 (by omega)`, a genuine discharge of the arity-≥2 domain restriction (`hn : n ≤ 1`).
The doc-comment line refs `:361`/`:364` in `Completeness.lean:358,369` are **stale**
(pre-refactor); the current single site is `:562`.

### The two EANegation sorries — OFF the proof-term path

| Site | Enclosing decl | Statement | Rabinovich | On proof term? |
|---|---|---|---|---|
| `EANegation.lean:1090` | `neg_bracket_is_vbracket` (thm @ `:834`) | Backward direction of the BracketFormula-level negation biconditional, n≥1, `β₀(r₀)` case | **Prop 4.2** (closure under negation, ≤2 free vars, p.6/§5) at the raw BracketFormula level | **NO** |
| `EANegation.lean:1249` | `neg_partialBracketExist_is_vbracket` (thm @ `:1129`) | Same, partial-bracket variant | Prop 4.2 | **NO** |

**Verification:** `grep` for external references to both decl names returns **zero consumers**
outside `EANegation.lean` itself. The on-path realization of Prop 4.2 is the **sorry-free**
`VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:177`), consumed via
`Section5Correspondence.lean:120` and `NfMultiAnchorBridge/AggregateOffDiagK1.lean:1233`. So
`:1090`/`:1249` are superseded bare versions that compile but are never consumed. The
"three-strikes, do not touch" flag is correct and they are **not** obstacles to zero on-path sorry.

### Everything else

The compiled tree contains many other sorries (e.g. `TruthLemma.lean`
431/448/483/497/540/556, `ChronicleToCountermodel.lean` ×6, `StaviCompleteness.lean` ×3,
`CaseAnalysis.lean` ×8, `Bundle/SuccRelation.lean` ×6, `OrderedSum.lean:56`, `Frame.lean:205`,
`Transfer.lean:1270`, `LindenbaumQuotient`, `InteriorOperators`). **None is on the
`completeness_discrete` proof term** — they live in dead/superseded/alternative-path files; the
proof-term walk in probe 02 confirms the single chain. They are out of scope for driving
`completeness_discrete` to zero.

**Bottom line for §1:** exactly **one** sorry blocks `completeness_discrete` —
`KampPrior.lean:562`.

---

## 2. The k≥2 E[Σ] hole — what it is and why it is re-architecture, not a lemma

### The obstruction, machine-established (task 379, `rfl`-checked)

`NormalForm sig (k+1) n` is definitionally
`(AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)` — its quantifier-assignment
component's **domain grows arity `n → n+1` per depth descent**. Any evaluator (`nf_eval_nf`) is
*forced* by the type to read sub-NFs at arity `n+1`. Entering at the live arity-2 point
(`NormalForm sig k 2`), two descents (k=2) reach **arity 4** (`Fin.cons y (Fin.cons x env)`).
This arity-4 joint type over `(x₁, w, x, t)` is part of what the k=2 **statement means**, so no
arm proof can avoid it. k=0 (max arity 2) and k=1 (max arity 3) land precisely *because* arity 4
is unreachable below k=2 — the arm boundary and the arity-4 emergence are one event.

### Why the paper never has this

Rabinovich (verified against PDF pp. 4–6):
- **Def 3.1 (p.4):** the ∃∀-formula object is `∃xₙ…∃x₀` with strict ordering `xₙ > … > x₀`,
  **unary QF point types** `αⱼ(xⱼ)`, and **interval types** `βⱼ` on `(x_{j-1}, xⱼ)`. Free vars
  `z₀…z_m` are *pinned* to existentials by indices `i₀…i_m ∈ {0..n}` — they are **not**
  independent arity.
- **Lemma 3.2(2) (p.4):** every ∃∀-formula ≡ a conjunction of ∃∀-formulas with **at most two
  free variables**. This cap is *why joint types over many points are never needed.*
- **Def 4.1 (p.5):** `E[Σ] := Σ ∪ {A | A a TL(Until,Since)-formula over Σ}` — a **unary
  predicate alphabet expansion**; each already-processed TL formula becomes a new **atom**
  (quantifier depth 0) interpreted as `{a | M,a ⊨ A}`.
- **p.6 collapse note:** a TL formula over E[Σ] predicates is equivalent to one over Σ, hence to
  an **atomic formula** in the canonical expansion — this is how processed depth drops to an atom
  instead of accumulating.
- **Prop 4.3 (p.6):** every FO formula ≡ disjunction of ∃∀-formulas, by **structural induction
  over the FORMULA**; the Negation case uses Lemma 3.2(2)+Prop 4.2, the ∃ case uses Lemma 3.4.

**The divergence in one line:** the repo's `nf_characterizable_temporal_prior` inducts over
**depth k** (re-entering `nf_nvar_exist_all_depths … k 1`, arity growing), whereas Rabinovich
inducts over **formula structure** with depth folded into the E[Σ] alphabet (arity capped at 2 by
Lemma 3.2(2)). The arity-4 obstruction is the direct symptom of the missing signature expansion:
with nowhere to fold processed depth *into*, it accumulates as joint arity.

### What the k=0/k=1 arm machinery already provides

All of the following operate on the **current** `NormalForm`/`nf_eval_nf` object and discharge
the `| 1 =>` case for k∈{0,1}:

| Decl / file | Role |
|---|---|
| `kampPrior_case1_trichotomy_assemble` (`KampPrior.lean:250`) | General-in-k assembly of the three-way (past/diag/future) `Formula.or` split via `kampPrior_site_trichotomy`. **Already general in k** — not the blocker. |
| `kampPrior_case1_arm_k0` (`:271`) | k=0 arm; M-independent, no hooks (over task-350 k=0 triple). |
| `kampPrior_case1_arm_k1` (`:301`) | k=1 arm; M-independent, no gate/provider obligations. |
| `AggregateOffDiagK1.lean`, `AggregateHookDischarge.lean`, `AggregatePointMergeK1.lean`, `ExteriorNavPastK1.lean`, `ExteriorNavFutK1.lean` (all `NfMultiAnchorBridge/`) | The k=1 off-diagonal / hook / point-merge / exterior-navigation machinery that supplies the k=1 arm triple; consumes the sorry-free `VVecEA2.negFix_iff` (Prop 4.2). |

**What is missing for general k:** *not* the assembly layer (general already) and *not* a `_k2`
arm lemma to be written. What is missing is that the k≥2 arm's `hreal` obligation is an
**arity-4 realization** (`∃x1, nf_eval_nf M (k+1) 4 …`) that the faithful unary producers
(`kvE2_sepPtW`/`igPtW`, lossy arity-1 projections) cannot supply, and whose only known supplier
(`kampPrior_hreal_supply`, arity-4) is machine-confirmed **circular**
(`InteriorGateGeneralK.lean:1541`) and **fiber-refuted** (archived
`ExteriorPinnedProbeM1K.lean:816`). Building it means proving novel mathematics — prohibited.
Hence the arm is correctly left as the `_k+2` residual with **OWNER: none**.

---

## 3. The task 381 deferred B1 follow-up — relationship to the k≥2 work

**B1** = the `kvExtFib_*`/Fib sub-DAG split: `igFoldBitFib` (`InteriorGateGeneralK.lean:1349`),
`igEpLFib` (`:1356`), `igEpRFib` (`:1365`), `igPtWFib` (`:1388`), consumed by the live private
theorem `kvExtFib_gate_henv` (`ExteriorGateAssembleK.lean:495`, via `simp only [igEpLFib]` /
`[igEpRFib]` / `[igPtWFib]`) and mirrored at `KampPrior.lean:1139–1211`.

**Key distinction that resolves the apparent contradiction:** task 381 B1 found these Fib decls
are *proof-term consumed by live-**closure** declarations* (i.e. compiled files:
`kvExtFib_gate_henv`, the `KampPrior` mirror). Task 379 §5 found the same stack is *0/5 reached by
`completeness_discrete`'s proof term*. Both are true: **"in the compiled build" ≠ "on the
`completeness_discrete` proof term."** `kvExtFib_gate_henv` compiles and is part of the k≥2 gate
apparatus, but the k≥2 gate is exactly the arity-4 engine that `completeness_discrete` does
**not** consume (the `_k+2` arm is `sorry`, so nothing below it is reached).

**Relationship to k≥2:** B1 is the arity-4 abandoned-engine cleanup. It **neither blocks nor
enables** the faithful k≥2 re-architecture:
- It is not a prerequisite: the re-architecture (Section 4) builds a new spine and does not touch
  the Fib DAG.
- It becomes **trivial and wholesale** *after* the re-architecture: once the structural E[Σ] path
  lands and `nf_nvar_exist_all_depths`/its `_k+2` arm dissolves, the entire arity-4 apparatus
  (`kvExtFib_gate_henv`, the Fib decls, `InteriorGateGeneralK`, `ExteriorGateAssembleK`,
  `kampPrior_hreal_supply`) becomes dead-and-uncompiled and can be archived in one pass.
- Attempting B1 first is optional pre-cleanup only. Because the decls are genuinely consumed by
  compiling files, a clean archive today needs cascading proof-term-reachability splits of
  `ExteriorGateAssembleK`/`KampPrior` — real surgery for zero completeness benefit.
  **Recommendation: defer B1 to post-re-architecture Boneyard hygiene** (owned by task 359), not
  before.

---

## 4. Reusable faithful assets — map to the remaining path

| Asset | Location | Rabinovich | Role in the re-architected path |
|---|---|---|---|
| **Prop 3.5 chain, right/future** — `VecEA2.translateRight` / `VVecEA2.translateRight` (+`_correct`) | `NfToVecEA.lean:413,447,451` | Prop 3.5 (p.5): `A_k ∧ (B_{k+1} Until(…))` chain | The faithful `Until`-nesting builder. Survives; it is the target shape the new Prop 3.5 must produce. Reuse directly where the new ∃∀ object matches. |
| **Prop 3.5 chain, left/past** — `VecEA2.translateLeft` / `VVecEA2.translateLeft` (+`_correct`) | `VecEATranslation.lean:515,541,549` | Prop 3.5 (p.5): the `A_k ∧ (B_{k-1} Since(…))` mirror | Same; the `Since`-nesting mirror. Survives. |
| **Prop 4.2** — `VVecEA2.negFix_iff` (also `VecEA2.negFix_iff`, `BracketFormula.negFix_iff`) | `EANegationFix/VecEANegFix.lean:177,77`; `NegFix.lean:688` | Prop 4.2 (p.6/§5): closure under negation, ≤2 free vars, over Dedekind-complete chains | **Sorry-free, on-path today.** The negation-closure engine Prop 4.3's Negation case needs. Re-target to the new ∃∀ object; likely the least-changed asset. |
| **Prop 4.2 packaged instance** — `Prop42Contentful` + its sorry-free instance | `Prop42Contentful.lean:139,281` | Prop 4.2 / Lemma 5.1 | Ready-made contentful Prop 4.2 packaging for the structural induction. |
| **NfEFold vocabulary** — `NormalFormEFold`, `EAtomDom`, `ZoneSpec`, `zoneHolds`, `efold_of_nf1` (`NfEFold.lean`) | reached 7/14 by proof term (probe 01) | Partial Def 4.1 zone/atom vocabulary | **Vocabulary adopted at the k=1 gate; semantics NOT.** `nf_eval_efold` and the general-k bridge `nf_eval_nfk_iff_efold` are axiom-clean but **retain arity n+1** (`NfEFold.lean:608–613`) — they are fiber-splitting, *not* an arity cap. **Do not treat as the migration target** (task 379 Attack 2: this is the single most dangerous wrong turn — clean axioms + inviting name, buys nothing for arity). Reuse the *zone/E-atom vocabulary* only; the fold *evaluator* must be replaced by the real E[Σ] expansion. |

---

## 5. Rabinovich grounding for the remaining holes

Primary source `rabinovich_2014` at
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
**Cite by PDF page only** — the companion `.md` is corrupt (inverts `k≠m`→`k=m` at md:199, drops
all displayed equations); per `specs/literature-index.json`, 89 in-code `md:NN` citations dangle
and must not be trusted. Pages 4–6 read directly.

| Remaining hole | Rabinovich anchor | Faithfulness gap (repo vs paper) |
|---|---|---|
| `KampPrior.lean:562` (`_k+2` arm) | **Prop 3.5, p.5** (realized) on top of **Def 3.1, p.4** (the object) | Repo realizes Prop 3.5 on `NormalForm sig k n`, a **Hintikka n-type** — no ordered existential prefix, no unary α point types, no β interval layer. It is not Def 3.1's object. Lemma 3.2(2) is a theorem about the Hintikka type but a **non-theorem** about Def 3.1's ∃∀-formula. This mismatch is the root of the arity growth. |
| The E[Σ] hole (root) | **Def 4.1, p.5** + collapse note p.6 | **No signature expansion exists in the repo.** `MonadicSignature` (`MonadicFO.lean:41`) is fixed (`preds : Type` + `[Fintype]`). `EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1` keeps depth k at the *same* sig — a lossy projection, not Def 4.1's alphabet expansion. Task 330's audit (`NavigatedSpine.lean:43`) independently reached this. |
| Structural composition | **Prop 4.3, p.6** | Repo inducts over **depth k**; Rabinovich inducts over **formula structure** with depth→atom. No Feferman–Vaught composition is used or permitted in the paper — composition is structural *because* of the expansion. |
| `EANegation:1090/1249` (off-path) | **Prop 4.2, p.6/§5** | Superseded; faithful sorry-free `VVecEA2.negFix_iff` already on-path. No gap on the live path. |

**`Fintype` faithfulness tension (highest-risk unknown):** Def 4.1's E[Σ] is countably infinite,
but `MonadicSignature` requires `Fintype` (load-bearing via `normalForm_fintype`,
`NormalForm.lean:166`). Prop 4.3 adds only finitely many atoms per stage, so a **finite
stage-indexed** expansion is *plausible* but unproven. This is the pivot of the whole program.

---

## 6. Phased path-to-full-completeness roadmap

Legend: **[RE-ARCH]** = prerequisite re-architecture (no new theorem content per se,
structural); **[NEW]** = genuine new proof content; **[CLEANUP]** = archival, off critical path.

> Strategic note: **do not attempt to discharge `KampPrior.lean:562` in the present
> architecture** (task 379 verdict; three prior attempts died on exactly this). The path below
> dissolves the arm rather than filling it.

### Phase A — E[Σ] feasibility gate  **[decisive prerequisite; ~1 agent-run]**
- **Touches:** new probe under `specs/379_.../reports/` (no `Theories/` edits).
- **Realizes:** Def 4.1 (p.5) under the `Fintype` constraint.
- **Content:** define `sigE (sig) (F : Finset Formula) : MonadicSignature` as `sig.preds ⊕ F`
  with derived `Fintype`/`DecidableEq` (must typecheck); define the canonical expansion of an
  `OrderedMonadicStructure`; state and prove the **one arity-preserving descent**:
  `depth-(k+1) obligation over sig at arity n  ↔  depth-k obligation over (sigE sig F) at arity n`
  (arity **n**, not n+1).
- **GO** iff that theorem states and proves sorry-free at equal arity both sides. **NO-GO** on
  unavoidable `n+1`, underivable `Fintype`, or an `F` that must be infinite.
- **Dependency:** none. **This is the gate; everything after is conditional on GO.**
- **If NO-GO:** escalate to **[BLOCKED]** for user review on a `MonadicSignature` redesign (a
  legitimate structural escalation — *not* a sorry deferral). A NO-GO here is a successful, cheap
  refutation, not a failure.

### Phase B — E[Σ] expansion layer  **[RE-ARCH / NEW foundation]** (conditional on A=GO)
- **Touches:** new module(s) under `Kamp/` (e.g. `ESigmaExpansion.lean`); `MonadicFO.lean` (only
  if the gate showed the expansion must be a first-class operation).
- **Realizes:** Def 4.1 (p.5) + p.6 collapse-to-atom note.
- **Content:** the stage-indexed finite expansion + canonical-expansion semantics + the
  atom-collapse lemma (TL-over-E[Σ] ≡ atom).
- **Depends on:** A.

### Phase C — Def 3.1 ∃∀-formula object  **[NEW]**
- **Touches:** new type (the ordered-existential-prefix / unary-α / β-interval object of
  Def 3.1), replacing `NormalForm sig k n` on the completeness spine.
- **Realizes:** Def 3.1 (p.4).
- **Depends on:** B (atoms drawn from E[Σ]).

### Phase D — Lemma 3.2 + Lemma 3.4  **[NEW]**
- **Realizes:** Lemma 3.2(1)(2)(3) (p.4) and Lemma 3.4 closure (∨, ∧, ∃) (p.5), on the Phase-C
  object. **3.2(2)'s ≤2-free-variable cap is the load-bearing arity bound** — the whole point.
- **Depends on:** C.

### Phase E — Prop 3.5 (∨∃∀, one free var → TL)  **[NEW, heavy reuse]**
- **Touches:** the faithful replacement for `nf_nvar_exist_all_depths` on the Phase-C object.
- **Realizes:** Prop 3.5 (p.5) — the `A_k ∧ (B_{k+1} Until …)` / `Since` mirror chains.
- **Reuse:** `VVecEA2.translateRight`/`translateLeft` (+`_correct`) — the chain builders already
  match the target shape.
- **Depends on:** C, D.

### Phase F — Prop 4.2 (closure under negation, ≤2 free vars)  **[reuse / re-target]**
- **Realizes:** Prop 4.2 (p.6/§5).
- **Reuse:** `VVecEA2.negFix_iff` / `Prop42Contentful` (sorry-free) re-targeted to the Phase-C
  object.
- **Depends on:** C, D.

### Phase G — Prop 4.3 (structural induction over formulas)  **[NEW, the crux]**
- **Touches:** the faithful replacement for `nf_characterizable_temporal_prior` — induction over
  **formula structure**, not depth; processed content becomes an E[Σ] **atom** at each step (so
  **no arity growth, no per-k arms, no arity-4 obligation ever arises**).
- **Realizes:** Prop 4.3 (p.6): Atomic / Disjunction / Negation (via 3.2(2)+4.2) / ∃ (via 3.4).
- **Depends on:** B, C, D, E, F. **This phase is what makes the `_k+2` arm disappear** rather than
  be filled.

### Phase H — Re-wire the spine and retire the sorry  **[RE-ARCH]**
- **Touches:** `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior`,
  `no_gaps_discrete_model_surgery`, and by transitivity `completeness_discrete`
  (`Completeness.lean:275`). Delete the entire `nf_nvar_exist_all_depths` `match` (arms + the
  `_k+2 sorry` at `:562`).
- **Realizes:** Thm 4.4 (p.6) = Prop 4.3 + Prop 3.5.
- **Verification:** `#print axioms completeness_discrete` no longer lists `sorryAx`.
- **Depends on:** G.

### Phase I — Archive the arity-4 apparatus + Boneyard hygiene  **[CLEANUP, off critical path]**
- **Touches:** the now-dead Fib DAG (`InteriorGateGeneralK`, `ExteriorGateAssembleK`,
  `kvExtFib_gate_henv`, `igFoldBitFib`/`igEpL/RFib`/`igPtWFib`, `kampPrior_hreal_supply`), plus
  the two dead reach-in files task 381 left (`Prop43.lean`, `NavigatedEndChar.lean`) after
  resolving the `Boneyard/Prop43.lean` namesake collision. This subsumes and makes trivial the
  deferred B1. **Owned by task 359** (`boneyard_archive_hygiene_no_live_imports`).
- **Depends on:** H (only after the arity-4 path is provably dead does clean wholesale archival
  replace cascading splits).

**Prerequisite re-architecture vs. genuine new content:** A (gate), B, H are structural
prerequisites; C, D, E, F, G are genuine new proof content (E and F carry heavy reuse). I is
cleanup. The gate (A) is the single decision point on which the entire GO-side program depends.

**Task ownership of the phases:** Phases A–H fall within this task
(`rearchitect_kampprior_k2_onto_unary_esigma_encoding`). Phase I is owned by task 359
(`boneyard_archive_hygiene_no_live_imports`). The final `#print axioms` audit that confirms the
whole chain is sorry-free is owned by task 375 (`kamp_completeness_final_assembly_axiom_audit`,
`deps:[379]`).

---

## Key file/line anchors (quick reference)

- `completeness_discrete` — `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:275`; axiom
  audit `:341–372`.
- Sole on-path sorry — `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:562`
  (`nf_nvar_exist_all_depths` `_k+2` arm; full rationale `:507–561`).
- Arm machinery — `KampPrior.lean:250` (trichotomy_assemble), `:271` (arm_k0), `:301` (arm_k1);
  k=1 support in
  `NfMultiAnchorBridge/{AggregateOffDiagK1,AggregateHookDischarge,AggregatePointMergeK1,ExteriorNavPastK1,ExteriorNavFutK1}.lean`.
- Off-path EANegation sorries — `EANegation.lean:1090` (`neg_bracket_is_vbracket`), `:1249`
  (`neg_partialBracketExist_is_vbracket`); zero external consumers.
- On-path Prop 4.2 — `EANegationFix/VecEANegFix.lean:177` (`VVecEA2.negFix_iff`).
- Prop 3.5 chains — `NfToVecEA.lean:413/447` (right), `VecEATranslation.lean:515/541` (left).
- NfEFold vocabulary — `Kamp/NfEFold.lean` (reuse zone/atom vocab only; **not**
  `nf_eval_efold`/`nf_eval_nfk_iff_efold`).
- B1 Fib DAG — `NfMultiAnchorBridge/InteriorGateGeneralK.lean:1349–1388`, consumer
  `ExteriorGateAssembleK.lean:495`.
- `MonadicSignature` (`Fintype` constraint) — `MonadicFO.lean:41`; `normalForm_fintype` —
  `NormalForm.lean:166`.
- Prior machine-checked evidence — `specs/379_.../reports/01_k2-sizing-verdict.md`,
  `01_arity-growth-sizing-probe.lean`, `02_consumption-walk-probe.lean`; task 381 summaries under
  `specs/381_.../summaries/`.
- Rabinovich PDF — `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (cite by page; `.md` is corrupt).
