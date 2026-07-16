# Adjudication: the `KampPrior.lean:520` k>=2 residual

**Phase**: 9 (terminal) | **Date**: 2026-07-15 | **Session**: `sess_1784164229_854c1a`
**Verdict**: **The residual STANDS.** No discharge attempted. No Feferman-Vaught. No novel
mathematics. All findings below are machine-checked or quoted verbatim from source.

---

## 1. Executive summary

The plan's Phase 9 asks three questions. All three are answered on evidence:

| Question | Answer |
|---|---|
| Is the `P17-frozen-interface-gap` rationale still factually valid? | **Partly — but it is materially mis-described.** The obstruction is real, but it is not an "interface gap" to be closed. It is an **arity cap**: the frozen producer is unary *because Rabinovich says so*. Its unarity is faithfulness, not a defect. |
| Is task 358 the correct owner? | **No. Impossible.** 358 is abandoned; the whole chain 358 -> 374 -> 376 is dead. The note named a non-existent owner. |
| Can `chain_split` + contentful Prop 4.2 close the zones? | **No — at every zone, not just the interval zones.** Machine-checked, axiom-free. |

The single most important correction: **the prior reading had the defect backwards.** It treated
the unary producer as the broken party ("drops the x/t anchor content") and the arity-4 consumer
as the standard to be met. The paper says the opposite. The arity-4 consumer is the off-paper
party, and closing the "gap" means building the arity-4 realization engine whose non-existence in
the source already caused an abandonment once.

---

## 2. The ownership chain is dead end-to-end

Verified against `specs/state.json` this session:

| Task | Status | Relevance |
|---|---|---|
| **358** `realization_recursion_nf_nvar_exist_all_depths` | **abandoned** | The owner the in-code note named. Superseded by 374. |
| **374** `retire_kampprior_519_522_residual_arms` | completed | Transferred the `:519`/`:522` DoD to spawned follow-up **376**. |
| **376** `arity_general_zone_decomposed_char_engine` | **abandoned** | Abandoned because *"the arity-4 charFib has NO counterpart in Rabinovich's 16 pages... the engine was novel mathematics, and the refutations were the compiler correctly rejecting a false statement"*. |
| **377** (this task) | implementing | `parent_task: 376`. Last live task in the chain. |

The DoD travelled 358 -> 374 -> 376 -> 377. **There is no live successor to defer to.** The plan's
standing instruction to "confirm task 358 is the correct owner" is void.

This staleness is not incidental — it is the same rot this task has been paying for all session
(the 13-month-unread vacuity finding; the already-transcribed Section 5). A stale pointer to an
abandoned owner is exactly what `no-task-references-in-deliverables.md` exists to prevent, and its
stated rationale ("task numbers are renumbered... meaningless to a future reader") is precisely
what happened. The note has been corrected in place to **durable anchors** (declaration names,
file paths, PDF page citations) and now introduces no task numbers at all.

---

## 3. What actually blocks the k>=2 arm (question of fact, answered by inspection)

### 3.1 It is NOT the trichotomy assembly

`kampPrior_case1_trichotomy_assemble` (`KampPrior.lean:250`) is **already general in `k`**:

```lean
(M : OrderedMonadicStructure sig) (k : Nat)
(sub_nf : NormalForm sig (k + 1) 2) (t : M.carrier)
```

Both discharged arms call it at a concrete depth (`... M 0 sub_nf t`, `... M 1 sub_nf t`). The
assembly layer is not the blocker. What is missing is the **per-`k` arm triple**
(`kampArm_{past,diag,future}_k{0,1}`). Confirmed by search: **no `_k2` and no general-`k` arm
exists anywhere in the tree.**

### 3.2 The general-`k` machinery is landed — and it *carries* the gap rather than closing it

The prior note promised that the successor would consume "the landed general-k machinery by name".
That machinery exists: `kampPrior_site_rungK_gate_match` (`KampPrior.lean:948`) is general in `k`
and axiom-clean. But **its own docstring states the verdict**:

> *"**Obligation discipline (carry, do NOT discharge).** `hreal`/`hexcl`/`hslice*`/`hexclSlice*`
> are threaded outward — **discharging `hreal`/`hexcl` requires the un-landed realization
> recursion**"*

Its `hreal` obligation, at every `k`:

```lean
∃ x1 : M.carrier,
  nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
```

— an **arity-4 joint type** over `(x1, w, x, t)`, guarded only by
`(igPtW ...).eval_at M atomMap w`, a **unary point type at `w`**. `kvE2_sepPtW`/`igPtW` are built
from the projections `kvE2_sepProj3`/`kvE2_sepProj4`, so they are **lossy by construction**.

The obligation ledger at `EndIntervalConsumerK.lean:289` names it outright:

> `| 5 | hreal — interior realization, **FULL arity 4** ... | task 358 — realization recursion |`

### 3.3 The gap in one line: producer/consumer char arity

| Party | Declaration | Binder |
|---|---|---|
| **Consumer** (gate) | `kampPrior_site_rungK_gate_match` (`KampPrior.lean:951`) | `charF : (j : Nat) -> NormalForm sig j `**`1`**` -> Formula` |
| **Producer** (supply) | `kampPrior_hreal_supply` (`InteriorHrealSupplyK.lean:64`) | `charFib : (j : Nat) -> NormalForm sig j `**`4`**` -> Formula` |

`kampPrior_hreal_supply` *does* discharge an arity-4 realizer — but only inside the **de-folded
arity-4 "Fib" architecture** (`igPtWFib`/`igEpLFib`/`igEpRFib`/`igFoldBitFib`/`charFib`). And it is:

- **UNWIRED** — consumed by no gate anywhere (search confirms only prose/probe references);
- **machine-confirmed CIRCULAR** on its intended route (`InteriorGateGeneralK.lean:1541`);
- **refuted at fiber level** (`ExteriorPinnedProbeM1K.lean:816`).

That `charFib` is the exact "arity-4 charFib" for which task 376 was abandoned.

---

## 4. The arity cap: why this is not a missing lemma (PDF, by page)

Rabinovich, *A Proof of Kamp's Theorem* (2014), caps arity everywhere the method touches:

| Source | Verbatim | Cap |
|---|---|---|
| **Def 3.1, p.4** | *"with all `α_j`, `β_j` quantifier free formulas with **one variable** over Σ"* | point/interval types: **1 variable** |
| **Lemma 3.2(2), p.4** | *"Every ∃∀-formula is equivalent to a conjunction of ∃∀-formulas with **at most two free variables**."* | **<= 2 free variables** |
| **Def 4.1, p.5** | *"We denote by E[Σ] the set of **unary** predicate names Σ ∪ {A | A is a TL(Until,Since)-formula over Σ}"* | expansion atoms: **unary** |

**There is no arity-4 joint type anywhere in the 16 pages.** Lemma 3.2(2) exists *precisely* to
reduce to <=2 free variables so that joint types over many points are never needed. And Prop 4.3
(p.6) makes composition **structural** — induction over *formulas*, with processed depth folded
into the signature as a unary E[Σ]-atom (Def 4.1) — which is exactly why Rabinovich **never needs
Feferman-Vaught**.

**Therefore the frozen producer's unarity is FAITHFULNESS, not a gap.** `kvE2_sepPtW` is unary
because Def 3.1/Def 4.1 say it must be. The complaint that it "drops the x/t anchor content"
reframes obedience to the paper as a defect. The arity-4 consumer is the off-paper party.

---

## 5. The `chain_split` probe (plan task 3) — EXECUTED, and it answers cleanly

Probe: `reports/05_chain-split-arity4-nonapplicability-probe.lean`. Compiles, **exit 0**, verdict
theorems **axiom-free** (`[propext, Quot.sound]` — no `sorryAx`, no `Classical.choice`).

`chain_split` is correct and axiom-free. Its gluing is licensed by one stated precondition, quoted
from its own header:

> *"There is NO conjunct joining non-adjacent points. So a Def 3.1 formula's constraint graph is a
> **PATH**, and cutting at an anchor separates it into components sharing only the cut vertex.
> Gluing is then unconditional."*

The gate obligation violates that precondition. `AtomKind` (`NormalForm.lean:60`) is

```lean
| order (i j : Fin n) (h : i ≠ j) : AtomKind sig n
```

— an order atom for **every ordered pair**. At `n = 4` over the env `[x1, w, x, t]` that is the
**complete graph K₄** (12 order atoms), not a path. A cut at the anchor `w` (index 1) leaves the
edges x1<->x, x1<->t and w<->t **intact across the cut**, so it separates nothing.

Machine-checked, both directions:

| Theorem | Statement | Meaning |
|---|---|---|
| `nf4_not_pathShaped` | `¬ PathShaped (nfCouples 4)` | The gate's arity-4 obligation is **not** path-shaped -> `chain_split` has no purchase. |
| `nf2_pathShaped` | `PathShaped (nfCouples 2)` | Rabinovich's faithful arity (Lemma 3.2(2) cap) **is** path-shaped -> `chain_split` works there, and only there. |

**Important correction to the dispatch's framing.** The dispatch suggested trying `chain_split` on
the *non-interval* zones (1,2,4,5) on the theory that interval zone 3 already discharges. The
landed code is the reverse: in `kampPrior_hreal_supply`, the **non-interval** zones are the ones
already discharged (`igZPastX`/`igZFutT` via `bracketEndChar_kvFib_realize_{pastX,futT}`;
`igZAtX`/`igZAtW`/`igZAtT` via char literal + `hcharFibSound`), while the **interval** zones
`igZXW`/`igZWT` ride the carried seams `hIntL`/`hIntR`. Either way the zone partition is
**irrelevant to the obstruction**: every zone's fiber is arity-4, so `chain_split` is
non-applicable at all seven. The probe stops at the boundary, as directed.

---

## 6. Ownership recommendation

Assessed against the actual obstruction, not convenience:

| Candidate | Verdict |
|---|---|
| **358** | **Impossible** — abandoned. |
| **376** | **Impossible** — abandoned, and abandoned *for this exact defect*. |
| **378** `rebase_section5_onto_faithful_dedekind_carrier` | **Mis-homing.** 378 is scoped to the **Section 5** carrier rebase. `:520` lives in the **Section 3/4** machinery (∃∀-formulas, Prop 4.2/4.3 composition). Related program, wrong scope. Do not file it here. |
| **375** `kamp_completeness_final_assembly_axiom_audit` | **No.** An audit of the final assembly. `:520` needs a re-architecture, not an audit. 375 will *observe* this residual (its `#print axioms` will show `sorryAx`), but cannot retire it. |
| **361** `strong_completeness_architecture_and_weak_terminus_gap_analysis` | **No.** Strong-completeness architecture; different scope. |

**Recommendation: a NEW owner task.** It must be scoped to *re-architecting the k>=2 path onto the
faithful unary E[Σ]-atom encoding of Def 4.1 (p.5) / Prop 4.3 (p.6), so that the arity-4 obligation
never arises*, and it must contain:

1. **A non-goal, stated up front**: do NOT discharge `hreal` at arity 4. That is the abandoned
   engine. Any plan that reaches for it is repeating 376.
2. **The faithful target**: fold processed depth into the signature as a **unary** E[Σ]-atom, per
   Def 4.1, so composition is structural (Prop 4.3) and `charF` stays arity-1 end-to-end.
3. **A retirement/quarantine ledger for the arity-4 Fib stack** (`charFib`, `igPtWFib`,
   `igEpLFib`, `igEpRFib`, `igFoldBitFib`, `kampPrior_hreal_supply`) — landed, unwired, circular,
   fiber-refuted. It should be excised or Boneyarded, not consumed.
4. **A hard prohibition on Feferman-Vaught**, with the reason recorded: Rabinovich never needs it
   (Prop 4.3 makes composition structural), so reaching for it is novel mathematics.
5. **Sequencing after 378** — both are parts of the same faithful-transcription program, and 378's
   faithful-carrier work is the natural substrate.

Until such a task exists, the residual is **UNOWNED**, and the corrected in-code note says exactly
that rather than re-pointing at a dead successor.

---

## 7. Verification gates (recorded verbatim)

| Gate | Result |
|---|---|
| `#print axioms nf_nvar_exist_all_depths` | `[propext, sorryAx, Classical.choice, Quot.sound]` — **identical to Phase 1's baseline**. `sorryAx` persists; success criterion (its disappearance) **NOT met**, as expected. |
| `#print axioms completeness_discrete` | `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — `sorryAx` present. **The DoD's terminal check is NOT met.** |
| `#print axioms kampPrior_case1_arm_k0` | `[propext, Classical.choice, Quot.sound]` — clean (preserved). |
| `#print axioms kampPrior_case1_arm_k1` | `[propext, Classical.choice, Quot.sound]` — clean (preserved). |
| `#print axioms kampPrior_site_rungK_gate_match` | `[propext, Classical.choice, Quot.sound]` — clean (it *carries* obligations, hence axiom-clean). |
| Tactic-position sorry census over `Kamp/` | **5 = baseline.** 3 live gate (`KampPrior:520`, `EANegation:1090`, `:1249`) + 2 dead in `Boneyard/` (`EndpointNegation:160`, `FOToVEA:118`). **No new sorries.** |
| Full `lake build` | **EXIT 0, 1766 jobs** — matches baseline. |
| Probe `05_chain-split-arity4-nonapplicability-probe.lean` | **EXIT 0**, verdicts axiom-free. |

Amended sorry gate honored: permitted live sorries are exactly `KampPrior:520`,
`EANegation:1090`, `EANegation:1249`. **None added.** `EANegation:1090`/`:1249` were **not
touched** (standing three-strikes prohibition). No files deleted; no declarations excised.

---

## 8. Bottom line

`KampPrior.lean:520` stands, and now stands **for a stated, machine-checked reason** rather than a
pointer to an abandoned task. The k>=2 arm is gated on an **arity-4 joint realization that has no
counterpart in Rabinovich's 16 pages**. The obstruction is **architectural, not a missing lemma**:
discharging it in the present architecture requires the very engine whose absence from the source
already caused an abandonment. The faithful route — Def 4.1's unary E[Σ]-atoms and Prop 4.3's
structural composition — is a re-architecture, and it needs an owner that does not yet exist.

The correct outcome of this phase was to find that out and say so, with the evidence attached.
