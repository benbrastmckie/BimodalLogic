# Task 363 — Restate depth≥1 fiber-marking interface & re-probe G1/G2: research

**Task**: 363 `restate_depth1_fibermarking_interface_and_reprobe_g1g2` (lean4)
**Status entering**: researched (only `reports/01_spawn-analysis.md`; no plan yet)
**Session**: sess_1784036998_a5fcb0
**Date**: 2026-07-14
**Purpose**: identify precisely what remains toward an implementation plan (v01) and full
implementation of the interface restatement + re-probe, grounded against the three sorry-free
countermodel probes in `ExteriorPinnedProbeM1K.lean`.

---

## 0. Executive summary

The general-depth (m≥1) fiber-marking interface underlying task 358's G1/G2 supply is
machine-refuted FALSE by three sorry-free probes. All three exploit ONE defect (D7): **every
fiber-marking channel in both legs keys a marked fiber only by data that is depth-0 (atom) or
arity-1 (fresh projection) — none reads the fiber's depth-≥1 inner marking.** A "doppelgänger-tail"
fake fiber `s*` differs from an honest fiber ONLY in that discarded depth-1 layer, so it is
indistinguishable in the interface yet has no pinned realization.

Central architectural finding (not in the spawn analysis): **`igFoldBit`
(`InteriorGateGeneralK.lean:318`) cannot be modified.** It is pinned byte-for-byte to the frozen
private carrier `bracketEndChar_kv` via the `rfl` bridge `bracketEndChar_kv_succ_eq`
(`InteriorGateGeneralK.lean:339-351`) and is consumed by the whole interior interface (KampPrior,
EndIntervalConsumerK, ExteriorPinnedConverseK). Redefining it reopens the frozen carrier — a
constraint the plan must respect. This rules out the naïve reading of approach (a) ("carry pinned
coordinates through `igFoldBit`"): the interior fix must live at the **consumer/binder seam**
(an added antecedent on the rows 5-6 obligations), not inside `igFoldBit`.

Recommended approach: **(b) a decidable depth-graded fiber-consistency guard**, added as a new
conjunct to `kvE_futAdmissible`/`kvE_pastAdmissible` (exterior leg) and as a new **antecedent** on
the rows 5-6 `_hreal`/interior obligations (interior leg). This excludes `s*`/`qnfG1` from the
hypothesis population of BOTH legs, so the probes' hypothesis-side assemblies (`m1_sigma_adm`,
guard-identity) become unprovable and the countermodel dissolves — which is exactly the DoD
("re-run the EXISTING probes; confirm the doppelgänger no longer applies"). Approach (a) in its
pure form is model-dependent (pinned realization is not a decidable function of the qnf) and
collides with the frozen `igFoldBit`; it is retained only as the conceptual target that (b)
realizes syntactically, and as the escalation framing if (b) cannot separate fake from honest
without breaking honest realizers.

---

## 1. Defect anatomy (D7), keyed to file:line

### 1.1 The three fiber-marking channels — all depth-0 or arity-1

| Channel | Definition | What it reads | Depth of read |
|---------|-----------|---------------|---------------|
| atom-fiber guard | `nfk_dropFresh` = `nf0_dropFresh sub.atom_assgn` (`NfEFold.lean:578`) | depth-0 atom 4-type of the tail | depth 0 only |
| zone key | `nfk_zoneSpec` = `nf0_zoneSpec sub.atom_assgn` (`NfEFold.lean:586`); `nf0_zoneSpec` (`NfEFold.lean:153`) | order coupling of fresh var vs env, off the atom layer | depth 0 only |
| fresh projection | `nfk_projFresh` = `nfk_take …1` (`CarrierKv.lean:82`); `nfk_take` succ branch existentially collapses `.2` (`CarrierKv.lean:73-76`) | arity-1 (single fresh var) type, `.2` marking existentially projected | arity-1 collapse |

Every consumer keys fibers through some subset of exactly these three:

- **Exterior admissibility** `kvE_futAdmissible` (`ExteriorNegationK.lean:86-98`): conjunct 1 reads
  `nf0_zoneSpec σ.1`; conjunct 2 is the atom-fiber guard `nfk_dropFresh s = σ.1 ∨ ¬σ.2 s`
  (`:89-90`); conjuncts 3-4 read fibers only through `kvE_subBit` keyed by `(zoneSpec, χ : NF k 1)`
  — i.e. zone + arity-1. No conjunct reads the depth-≥1 inner marking.
- **Exterior slice key** `kvE_futSliceEq` (`ExteriorPinnedConverseK.lean:667-672`): `σ'.1 = σ.1` +
  three `kvE_fiberZoneList` equalities. `kvE_fiberZoneList` (`ExteriorFiberK.lean:238-240`) filters
  the fiber by `nfk_zoneSpec s = zs4` — zone only. (The lists carry full NF *objects*, so the
  exterior key does retain fiber identity; see §1.3 for why this leg still fails.)
- **Interior gate** `igFoldBit` (`InteriorGateGeneralK.lean:318-332`): reads each marked depth-`k`
  arity-4 sub only through the pair `(nf0_zoneSpec ∘ atom_assgn, nfk_projFresh)` — the arity-1 F1
  channel. `igOffFiber` (`:303-304`) uses the atom guard `nf0_dropFresh (atom_assgn sub) ≠ qnf.1`.

**D7 restated precisely**: the doppelgänger fake and the honest fiber have **identical atom
layers at every arity** and **identical zone specs**, and **identical arity-1 fresh projections**.
They differ ONLY in the depth-1 inner `.2` marking. Since no channel reads that layer, the interface
cannot separate them.

### 1.2 The doppelgänger `s*` and its evasions (probe file, keyed)

- `s* := nf_characteristic M1M 1 5 [22, 25, 15, 2, 21]` (`ExteriorPinnedProbeM1K.lean:100-101`),
  honest fiber `s° := nf_characteristic M1M 1 5 [22, 25, 15, 2, 18]` (`:738-739`). Difference:
  t-slot `21` vs `18`.
- **Atom evasion** (`m1_sstar_dropFresh`, `:352-397`): `nfk_dropFresh s* = m1tau.1`. The 4-types of
  `[25,15,2,21]` and `[25,15,2,18]` coincide (both: t-slot above `15`, above `2`, below `25`, ¬P).
  Verified independently: even the *full* atom 5-types of `[22,25,15,2,21]` and `[22,25,15,2,18]`
  coincide (`22` sits above the t-slot in both, `22>21` and `22>18`); so **no atom-layer read of any
  arity separates them** — the difference is purely in `.2`.
- **Zone evasion** (`m1_sstar_zone`, `:260-275`): both sit in `kvE_futGapZone`.
- **Arity-1 projection evasion** (`m1_take2_eq` `:751-766`, `m1_projFresh_eq` `:799-803`): the arity-2
  prefix takes of `s*` and `s°` coincide (both realized at prefix `[22,25]`, identified by
  `nf_eval_unique`), so `nfk_projFresh (τ⊕s*) = nfk_projFresh τ`. The take is a **prefix** take, and
  the doppelgänger difference lives in the **suffix** (t-slot, last variable), so no prefix take of
  arity < 5 sees it either.
- **Free-env realized** (`m1_sstar_freeEnv`, `:113-114`): `nf_eval_nf M1M 1 5 [22,25,15,2,21] s*` —
  `s*` is a genuine, internally consistent type of a real tuple.
- **Not pinned-realizable** (`m1_sstar_not_pinned`, `:133-225`): for every `z, x1''`, `s*` is NOT
  realized at `[z, x1'', 15, 2, 18]`. `s*`'s depth-1 marking marks inner types `e_b`/`e_c` that,
  re-anchored to the honest tail `[·,15,2,18]`, demand a point in `(21,22)` and a P-point above `22`
  — both impossible. **The inconsistency is relational** (fake-vs-honest-tail), not intrinsic:
  `s*` is a legitimate type of its OWN tuple, but cannot be pinned over the ambient's tail.

### 1.3 The two consumer seams, why each fails

- **Exterior leg (rows 8-11, G2)** — `kvE_probeM1_sliceId_NOGO` (`:679-696`). The full hypothesis
  side is satisfiable: `m1_sigma_adm` (`:487-552`) proves `σ = τ⊕s*` is admissible (the `s*`
  augmentation survives all four conjuncts precisely because they only read atom/zone/arity-1);
  `hend/hgap/hocc` all hold in P-eliminated semantic (free-env) form. The **conclusion fails**
  (`m1_no_marked_mate`, `:430-449`): `kvE_futSliceEq` forces gap-**list** equality, so any mate `σ'`
  must carry `s*` in its gap list; being qnf-marked, `σ'` must realize `s*` pinned at its endpoint —
  refuted by `m1_sstar_not_pinned`. Here the key already carries full fiber identity; the defect is
  that **admissibility admits `σ` containing the unpinnable `s*`** as if it were a real gap fiber.
- **Interior leg (rows 5-6, G1)** — `kvE_probeM1_interiorHreal_NOGO` (`:884-892`) and
  `kvE_probeM1_interiorGuard_identical` (`:899-905`). The fake ambient `qnfG1 := m1qnf ⊕ m1sigma`
  (`:813-814`) satisfies `igFoldBit qnfG1 = igFoldBit m1qnf` (`m1_qnfG1_foldBit_eq`, `:821-842`)
  because `m1sigma`'s `(zone, projFresh)` pair is already contributed by honestly-marked `τ`. Hence
  the `igPtW` guard is **literally identical** for every rendering `(charBase, charK)`
  (`:899-905`), while `qnfG1.2 m1sigma = true` (`:887`) and `m1sigma` has no pinned realization over
  `[·,15,2,18]` (`m1_sigma_not_pinned4`, `:848-852`). So the row-5 `_hreal` conclusion is FALSE at
  `qnfG1` whenever its guard is satisfiable — and the guard is satisfiable exactly when the honest
  one is (they are equal).

**One defect, two seams.** Both are the arity-1/atom-only keying of a layer whose distinguishing
content is depth-1. Fixing the keying at the rungK-binder / consumer seam resolves both.

---

## 2. Approach adjudication

### 2.1 Constraint that reshapes the choice: `igFoldBit` is frozen

`igFoldBit` is written with an explicit `Decidable` instance chosen byte-for-byte to make
`bracketEndChar_kv_succ_eq` a `rfl` against the frozen private `kv_body`/`bracketEndChar_kv`
(`InteriorGateGeneralK.lean:310-351`). It is consumed by `KampPrior.lean:959-1001`,
`EndIntervalConsumerK.lean:120-163`, `ExteriorPinnedConverseK.lean:1250-1256`. **Any change to
`igFoldBit`'s body breaks the `rfl` bridge and reopens the frozen carrier** — out of scope and
forbidden. Therefore:

- Approach **(a)** "carry the fiber's full pinned coordinates through the binder" **cannot** be
  implemented by refining `igFoldBit`'s projection. Pinned realizability is model-dependent and thus
  not expressible as the `NormalForm → Bool` gate `igFoldBit` must remain. A finer *prefix* take
  also fails (§1.2: the doppelgänger difference is in the suffix, not the prefix).
- The only frozen-respecting surface for the interior leg is the **consumer obligation** (rows 5-6),
  which task 358 must discharge: add an **antecedent** guard there restricting the qnf population.

### 2.2 Candidate (a): anchored / pinned item rendering

- **What changes**: the marking datum would carry the fiber pinned to the ambient tail
  (`∃ x1, nf_eval_nf M (m+1) 4 [x1,w,x,t] σ`) instead of the projected summary.
- **Blockers**: (i) model-dependence — cannot enter `igFoldBit` (must stay decidable syntax); (ii)
  frozen `igFoldBit` cannot be touched anyway; (iii) the exterior slice key already carries full
  identity, so "finer rendering" does not remove `s*` there.
- **Defeats both fakes?** Only if pushed all the way into a semantic obligation at the consumer seam
  — at which point it is operationally identical to (b)'s interior antecedent. Pure (a) is not
  separately implementable.
- **Verdict**: not viable as a standalone syntactic interface; conceptual target only.

### 2.3 Candidate (b): depth-graded fiber-consistency guard — RECOMMENDED

- **Core idea**: add a decidable, model-independent predicate `kvE_futFiberConsistent`
  (working name) on a fiber `s : NormalForm sig (k+1) 4` (or on the `(qnf, s)` pair) that reads the
  **depth-≥1 inner marking** and rejects fibers whose inner types are jointly unsatisfiable with
  being pinned over the ambient's tail profile. `s*` fails it (its `e_b`/`e_c` inner marks contradict
  a gap-fiber pinned over `[·,15,2,18]`); honest gap fibers pass it.
- **Exterior leg — what concretely changes**:
  - Strengthen `kvE_futAdmissible` (`ExteriorNegationK.lean:86`) and `kvE_pastAdmissible`
    (`ExteriorNegationPastK.lean:152`) with the new conjunct.
  - **Mandatory downstream repair**: re-prove `kvE_futRealizer_admissible`
    (`ExteriorNegationK.lean:124-…`) and its past mirror — honest realizers must still be admissible,
    else the whole exterior correctness chain (ExteriorNegationK → ExteriorFiberK →
    ExteriorPinnedConverseK → ExteriorGateAssembleK → EndIntervalConsumerK) breaks. This is the main
    risk surface and the reason for a machine probe before landing.
  - Effect on the probe: `m1_sigma_adm` (`:487-552`) becomes **unprovable** (`s*` fails the new
    conjunct), so `kvE_probeM1_sliceId_NOGO`'s hypothesis side collapses — the countermodel no longer
    applies.
- **Interior leg — what concretely changes**:
  - Add the consistency predicate as an **antecedent** to the rows 5-6 obligations
    (`EndIntervalConsumerK.lean:119-130` `_hreal`/`_hexcl`; the mirrored KampPrior supply shape),
    e.g. "for every marked `σ`, `kvE_futFiberConsistent qnf σ`". `igFoldBit` is untouched.
  - Effect on the probe: `qnfG1` marks the inconsistent `m1sigma`, so it fails the new antecedent;
    the interior `_hreal` obligation is no longer required to hold at `qnfG1`. Re-express
    `kvE_probeM1_interiorHreal_NOGO` against the restated obligation: the hypothesis side (which now
    includes the consistency antecedent) is unsatisfiable at `qnfG1`, so the NO-GO contradiction
    dissolves.
- **Defeats both fakes?** Yes — both fakes are the SAME `s*`/`m1sigma`, and the predicate rejects it
  in whichever population it appears (exterior admissible set, interior marked set).
- **Generality to m≥2 (matters for task 358, general-m)**: the predicate must be depth-recursive
  (checking inner-marking consistency at each depth), not hardcoded for m=1. This is the principal
  design risk and the reason Phase 1 is a machine probe on the m=1 cast BEFORE any production edit.

### 2.4 Recommendation

**Adopt (b), a depth-graded fiber-consistency guard**, implemented as: (i) a new conjunct in
`kvE_futAdmissible`/`kvE_pastAdmissible` for the exterior leg, and (ii) a new antecedent on the
rows 5-6 interior obligations for the interior leg — `igFoldBit` untouched. Prototype and
machine-validate the predicate on the existing m=1 cast (task-360 "probe before landing"
precedent) BEFORE editing production. If the predicate cannot simultaneously (reject `s*`) and
(keep every honest realizer admissible) without model-dependence, escalate to [BLOCKED] (§5.4).

---

## 3. Frozen-boundary map

### 3.1 FROZEN — MUST NOT touch or reopen

| Declaration | Location | Why frozen |
|-------------|----------|-----------|
| `igFoldBit` | `InteriorGateGeneralK.lean:318` | byte-for-byte pinned to frozen carrier via `bracketEndChar_kv_succ_eq` rfl |
| `bracketEndChar_kv_succ_eq`, `igBody`, `igOffFiber`, `igFoldBit_iff`, `bracketEndChar_kv_succ_holds_iff` | `InteriorGateGeneralK.lean:286-413` | defeq bridge to frozen private `kv_body` |
| `bracketEndChar_kv` (private carrier) | `CarrierKv.lean` | frozen production carrier |
| `kampPrior_site_rung0_match` (k=0), `kampPrior_site_rung1_match` (k=1) | `KampPrior.lean:830-874` | unconditional k≤1 rungs, unrefuted |
| `bracketEndChar_kv_correct_zero_prior`, `bracketEndChar_kv_correct_one_prior` | (imported) | k=0/k=1 correctness |
| `kampPrior_case1_arm_k0` | KampPrior (k=0 arm) | frozen, unrefuted |
| `kvE_hsliceFut_supply_zero` | `ExteriorPinnedConverseK.lean:1301` | task-360 m=0 supply, landed |
| `kvE_hexclSliceFut_supply_zero` | `ExteriorPinnedConverseK.lean:1242` | task-360 m=0 supply, landed |
| `kvE_futSliceId_of_end_zero` / past mirror, `kvE_futSliceUnique_zero` | ExteriorPinnedConverseK / PastK | task-360 m=0 kernels |
| `kvE_fiberZoneList`, `kvE_fiber`, `kvE_minPick`, `nfk_take`, `nfk_projFresh`, `nfk_dropFresh`, `nfk_zoneSpec`, `nf0_zoneSpec` | ExteriorFiberK / CarrierKv / NfEFold | shared infra consumed by frozen k=0/k=1; do not re-signature (may add NEW helpers alongside) |

**Guard rail**: the k=0 and k=1 layers are unconditional and unrefuted. The new conjunct/antecedent
must be **inert at k=0** (m=0) — i.e. the m=0 supply theorems (`kvE_hsliceFut_supply_zero` etc.) must
continue to type and prove unchanged. Design the predicate so it is trivially true at depth 0 (where
the fiber has no depth-≥1 inner marking), preserving the frozen m=0 discharge.

### 3.2 IN-SCOPE to modify / add

| Target | Location | Change |
|--------|----------|--------|
| `kvE_futAdmissible` | `ExteriorNegationK.lean:86` | add depth-graded conjunct |
| `kvE_pastAdmissible` | `ExteriorNegationPastK.lean:152` | add mirror conjunct |
| `kvE_futRealizer_admissible` (+ past) | `ExteriorNegationK.lean:124` | re-prove with new conjunct (honest realizers stay admissible) |
| rows 5-6 interior obligations `_hreal`/`_hexcl` | `EndIntervalConsumerK.lean:119-130`; mirrored KampPrior supply shape | add consistency antecedent |
| exterior binders rows 8-11 (`_hsliceFut`/`_hexclSliceFut` etc.) | `EndIntervalConsumerK.lean:141-168` | may need re-statement to thread the strengthened admissibility |
| NEW consistency predicate `kvE_futFiberConsistent` (+ past) | new leaf or ExteriorFiberK/Negation sibling | the depth-graded guard itself |
| `ExteriorPinnedProbeM1K.lean` | probe leaf (imported by nothing — confirmed) | re-probe target; safe to edit |

### 3.3 Import / territory notes

- `ExteriorPinnedProbeM1K.lean` is a true leaf: **no file imports it** (verified by grep). Safe to
  edit for the re-probe, or add a sibling probe module.
- Modifying `kvE_futAdmissible` propagates through ExteriorFiberK → ExteriorPinnedConverseK →
  ExteriorBracketAssembleK → ExteriorGateAssembleK → EndIntervalConsumerK → KampPrior. Full-chain
  `lake build` required at land time; scoped builds per module during phases.

---

## 4. Re-probe protocol (Definition of Done)

The DoD is: re-run `kvE_probeM1_sliceId_NOGO`, `kvE_probeM1_interiorHreal_NOGO`,
`kvE_probeM1_interiorGuard_identical` against the restated interface and confirm the doppelgänger
countermodel no longer applies to EITHER leg. Concretely, "no longer applies" means:

### 4.1 Exterior leg (G2)

- **Target**: with the strengthened `kvE_futAdmissible`, prove `kvE_futAdmissible m1sigma = false`
  (the fake is now inadmissible). This makes the old `m1_sigma_adm` unprovable and the old NO-GO
  theorem non-instantiable.
- **Honest-preservation check**: prove that every honest gap fiber used in the probe
  (`nf_characteristic M1M 1 5 (Fin.cons r m1env4)` for `r ∈ (18,25)`, and the self/ray witnesses)
  still satisfies the new conjunct, so `kvE_futRealizer_admissible` still fires. A passing result =
  honest σ still admissible, fake σ not.

### 4.2 Interior leg (G1)

- **Target**: re-express the interior obligation with the consistency antecedent, and prove the fake
  ambient fails it: `¬ kvE_futFiberConsistent m1qnfG1 m1sigma` (or the qnf-level guard is
  unsatisfiable at `qnfG1`). Then the analogue of `kvE_probeM1_interiorHreal_NOGO` no longer exhibits
  a satisfiable-hypothesis / false-conclusion pair.
- **Guard-identity note**: `kvE_probeM1_interiorGuard_identical` states `igFoldBit qnfG1 = igFoldBit
  m1qnf` — this remains TRUE (igFoldBit is frozen and unchanged). That is EXPECTED and not a
  regression: the fix does not separate `qnfG1` from `m1qnf` at `igFoldBit`; it separates them at the
  NEW consistency antecedent one layer out. The passing result is: the *combined* hypothesis side
  (guard ∧ consistency) is now unsatisfiable at `qnfG1`, even though `igFoldBit` alone still cannot
  tell them apart.

### 4.3 What a passing (GO) result looks like

A NEW sorry-free probe module (or edited `ExteriorPinnedProbeM1K.lean`) that proves, against the
restated production defs:

1. `kvE_futAdmissible m1sigma = false` (exterior fake excluded);
2. every honest probe fiber still admissible (honest population preserved);
3. `¬ (restated interior antecedent holds at (qnfG1, m1sigma))` (interior fake excluded);
4. the m=0 layer certificates (`kvE_hsliceFut_supply_zero` etc.) still build unchanged.

All four sorry-free, full `lake build` green.

### 4.4 What a FAIL (NO-GO → [BLOCKED]) looks like

Either (i) no decidable conjunct rejects `s*` without also rejecting an honest realizer (predicate
is model-dependent or over/under-strong), or (ii) rejecting `s*` requires reading data the frozen
`igFoldBit` withholds and there is no consumer-seam antecedent that task 358 could discharge. Then
return [BLOCKED] with the structured escalation (§5.4).

---

## 5. Proposed plan skeleton (v01)

Verification bar for EVERY phase: `lake build` (scoped per module; full at land) green, **zero
sorry / zero vacuous def** (per `.claude/rules/lean4.md`), k=0/k=1 frozen layers untouched
(diff-verified). Each phase ≈ one agent run.

### Phase 1 — Design & machine-probe the depth-graded predicate (probe-before-landing)
- Define candidate `kvE_futFiberConsistent` (decidable, depth-recursive, inert at depth 0) in a
  NON-production probe/sibling module.
- On the existing m=1 cast, prove: `kvE_futFiberConsistent … m1sstar/m1sigma = false` AND
  `kvE_futFiberConsistent … (honest gap/self/ray fibers) = true`.
- **GO gate**: predicate separates fake from honest on both the exterior `s*` and the interior
  `qnfG1` cast, decidably and model-independently. If NO-GO here → Phase 4 escalation, no production
  edit made.

### Phase 2 — Land the exterior conjunct + re-prove realizer admissibility
- Add the conjunct to `kvE_futAdmissible` (`ExteriorNegationK.lean:86`) and `kvE_pastAdmissible`.
- Re-prove `kvE_futRealizer_admissible` (+ past) so honest realizers stay admissible.
- Rebuild the exterior chain (ExteriorFiberK → ExteriorPinnedConverseK → ExteriorGateAssembleK →
  EndIntervalConsumerK). Confirm m=0 supply theorems (`kvE_hsliceFut_supply_zero`,
  `kvE_hexclSliceFut_supply_zero`) still build unchanged.
- **Verify**: scoped builds green; frozen m=0 lemmas intact.

### Phase 3 — Land the interior antecedent on rows 5-6
- Add the consistency antecedent to the interior `_hreal`/`_hexcl` obligations
  (`EndIntervalConsumerK.lean:119-130` and the mirrored KampPrior supply shape). `igFoldBit`
  untouched; the `bracketEndChar_kv_succ_eq` rfl bridge must still hold (diff-check
  `InteriorGateGeneralK.lean` is unmodified).
- **Verify**: `KampPrior.lean` + `EndIntervalConsumerK.lean` build green; interior gate defeq intact.

### Phase 4 — Re-probe (DoD) + wrap-up
- Re-run/re-express the three probes against restated defs (§4): prove exterior fake inadmissible,
  interior fake fails antecedent, honest population preserved, m=0 unchanged. All sorry-free.
- Full `lake build` green. Commit; set status to reflect GO (interface restated, both legs' probes
  confirm countermodel no longer applies).

### Phase 4′ (fallback) — [BLOCKED] escalation
- Taken if Phase 1 or Phase 4 shows neither (a) nor (b) closes green. Return [BLOCKED] with:
  goal states reached, the exact conjunct(s) tried, why honest-preservation OR fake-exclusion failed,
  and whether the obstruction is model-dependence (pure (a) needed) or a frozen-`igFoldBit` wall. No
  sorry, no vacuous def, no forcing a proof against the live countermodel.

**Sizing note**: Phases 2 and 3 each touch a distinct leg/territory (exterior negation chain vs
interior consumer seam) and are independently buildable — good parallel/serial phase boundaries.
Phase 1 is the critical GO/NO-GO gate and must precede any production edit.

---

## 6. Interaction with task 358

Once 363 lands (GO), task 358 gains the following, and its plan v3 dovetails:

- **G2 (exterior rows 8-11)** — `_hsliceFut`/`_hexclSliceFut` supply at general m (task 358 Phase 7).
  With `s*`-class fakes excluded from `kvE_futAdmissible`, the slice-identification conclusion
  ("∃ admissible slice-equal qnf-marked mate") becomes a TRUE statement: every admissible σ over the
  strengthened predicate is pinned-consistent, so its gap-listed fibers ARE pinned-realizable and the
  mate exists. `kvE_probeM1_sliceId_NOGO` no longer refutes it. Phase 7's slice-identification /
  uniqueness kernels (R3) are re-keyed to the strengthened admissibility.
- **G1 (interior rows 5-6)** — `kampPrior_hreal_supply` at general depth (task 358 Phase 8). With the
  consistency antecedent on the obligation, the supply need only cover pinned-consistent marked σ; the
  fake `qnfG1` is outside the population, so `hreal` (`∃ x1, nf_eval … [x1,w,x,t] σ`) is provable.
  `kvE_probeM1_interiorHreal_NOGO` no longer refutes it.
- **Downstream**: 358 Phase 9 (arm rewrite, retires `KampPrior.lean:361`) depends on Phases 7-8;
  Phase 10 (:364 arity lift) on Phase 9 — both proceed unchanged from plan v3 once G1/G2 land.
- **Resume point**: `/implement 358` at Phase 7 (G2), which consumes 363's restated interface; Phase 8
  follows once Phase 7's shared uniqueness/readback kernel lands.
- **Contract for 358**: the EXACT shape of 363's predicate (conjunct signature + interior antecedent)
  determines how Phase 7/8's obligations are stated. 363 should record the final predicate signature
  in its summary so 358's planner keys to it (genuine implementation-detail dependency, per spawn
  analysis §Dependency Reasoning).

---

## 7. Risks & open questions for the planner

1. **Predicate adequacy at m≥2** (highest risk): the m=1 cast validates the shape; generality to the
   depth-recursive case is the open target. Phase 1 must probe the recursive definition, not a
   hardcoded m=1 check.
2. **Honest-realizer preservation**: re-proving `kvE_futRealizer_admissible` is the load-bearing
   correctness obligation; if the new conjunct is too strong it breaks the exterior chain.
3. **m=0 inertness**: the conjunct must be trivially true at depth 0 to keep the frozen task-360 m=0
   supply intact.
4. **Frozen `igFoldBit` wall**: the interior fix is confined to the consumer antecedent; confirm task
   358's Phase-8 supply can actually discharge that antecedent (else the fix merely relocates the
   obstruction). Worth a quick feasibility check in Phase 1.
5. **Past/Future symmetry**: every change has a `past` mirror (`kvE_pastAdmissible`,
   `kvE_pastSliceEq`, ExteriorPinnedConversePastK); keep them in lockstep.
