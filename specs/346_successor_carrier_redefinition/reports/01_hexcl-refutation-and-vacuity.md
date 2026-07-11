# Report 07 — hexcl Enrichment Derivability Check (Task 335, Phase C escalation)

- **Verdict**: **NO-GO** — and the obstruction is deeper than the fold interface.
- **Date**: 2026-07-11, session sess_1783723095_edd5a7_335 (verification fork)
- **Question**: can an enriched fold variant (`kvE2_outer_fold_frag'`) thread the realized
  bracket's segment content at `x1` into the `hexcl` callback so the negative-sub exclusion
  becomes derivable under `hfrag`?
- **Answer**: no. Two independent refutations, each sufficient.

## Refutation 1 (decisive): the landed fragment predicate is UNREALIZABLE — Phase B is vacuous as stated

Definition-level chain (all verified at HEAD `60c46caa6`):

1. `nf_eval_nf` quant layer (`Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean:198`,
   `k+1` case) is a **full biconditional over ALL sub-forms with unrestricted witness**:
   `∀ sub_nf, (∃ x, nf_eval_nf M k _ (Fin.cons x env) sub_nf) ↔ quant_assignment sub_nf = true`.
   A realized `qnf : NormalForm sig 2 3` therefore has `qnf.2` equal to the **exact
   characteristic table** of depth-1 realizations — every realized depth-1 4-var form must be
   marked `true`.
2. `nf_exists_unique` (`NormalForm.lean:276-283`): for EVERY point `x1`, the characteristic
   form `nf_characteristic M 1 4 [x1,w,x,t]` is realized (`nf_characteristic_satisfies`).
3. With `x < w < t` (forced in the soundness conclusion context), the characteristic forms at
   `x1 := w`, `x1 := x`, `x1 := t` are **pairwise distinct** — their atom layers differ on
   order atoms whose truth values the biconditional pins to the env: `.order ⟨2⟩⟨0⟩` (= `x < x1`)
   is true for `x1=w`, false for `x1=x`; `.order ⟨0⟩⟨3⟩` (= `x1 < t`) is true for `x1=w`, false
   for `x1=t`. So **at least three distinct σ are realized** in any model where the conclusion
   could hold.
4. `kvE2_sepFragment` (`OuterGate.lean:191`) demands `kvE2_sepPos qnf = [σ0]` where
   `kvE2_sepPos` (`SharedWitness.lean:193`) filters **ALL** of `Finset.univ` by `qnf.2` — a
   GLOBAL single positive bit. By (1)-(3), any realized `qnf` has ≥ 3 positive bits.

**Consequence**: `hfrag → ¬ nf_eval_nf M 2 3 [w,x,t] qnf` whenever `x < w < t`. The landed
Phase B theorem `bracketEndChar_kvE2_sound_two_prior_frag` (commit `c508e2a48`) is green and
axiom-clean but its conclusion is **false in every model**, hence its hypothesis set
(`.holds` + `hfrag` + `hexcl`) is jointly unsatisfiable — `hexcl` can NEVER be discharged, by
any enrichment, because no model exists in which all the other premises hold and `hexcl` is true.

The intended N2 fragment ("single-positive-sub") is plausibly the **interior**-singleton
`kvE2_sepPosI qnf = [σ0]` (`SharedWitness.lean:211` — positives among interior-arranged subs
only, exterior-arrangement positives unconstrained). The landed `kvE2_sepFragment` is a
mis-formalization of that verdict. This should be surfaced loudly: 309 must NOT consume the
Phase B theorem as-is.

## Refutation 2 (independent): even under the repaired (interior-singleton) fragment, hexcl is inexpressible in the bracket vocabulary

- The satisfiable-set argument: at the `hexcl` goal (`False` from
  `{hptW, hσneg : qnf.2 σ = false, hreal}` — probe transcript, commit `da50f596c`), take
  `σ := nf_characteristic M 1 4 [x1,w,x,t]` (any realized negative). EVERY fact threadable
  from `h_holds` (segment forms, endpoint types, witness clauses — all TRUE in `M`) is
  **consistent** with `hreal` (they hold in the same model simultaneously). `False` is not
  derivable from a satisfiable set. The only non-model fact is the syntactic bit
  `qnf.2 σ = false`; contradicting it needs a completeness-direction fact "realized ⇒ marked",
  which is the statement under proof (circular) or a model-independent structural constraint
  on `qnf.2` (gate clauses) — and gate-legal tables with unmarked realizable exterior/sibling
  types exist.
- Consumer-side category mismatch (obligation 2): `kvE2_sepSegForm_excludes`
  (`SharedWitness.lean:6683`) concludes at the **inner** bits level
  (`kvE2_sepBits σ zs χ = false`), i.e. it excludes inner `(zs,χ)` content of a *given* σ. It
  cannot contradict `hreal` for a characteristic σ, whose inner layer *agrees with the model*
  (depth-0/1 `nf_exists_unique`). The segment-form route targets the wrong layer entirely.
- Info ceiling (obligation 3): `bracketEndChar_kv_factors` (`CarrierKv.lean:422`) certifies
  the bracket factors through (outer zone, projected 1-type). Distinct
  `σ ≠ σ'` sharing `nfk_projFresh` exist (the recurring F4/O4 wall); an exclusion clause over
  the `charK` channel that kills a negative sibling also kills the positive one. Exterior
  arrangements (`x1 < x`, `x1 > t`, at-point ties) are constrained by the bracket only through
  the endpoint 1-types — nothing separates two beyond-`t` continuations realizing different
  depth-1 types. **The factors refutation applies to the enrichment** (obligation 3 answered:
  the realized-bracket content is itself only base/projected 1-type information over `(x,t)`).
- Obligations 4 (blast radius) and 5 (witness-point case) are moot given the above.

## Where hexcl consumption sits (obligation 1, for the record)

- Original fold: `SharedWitness.lean:10117` (hypothesis), `:10191` (consumption —
  `by_contra` in the outer quant layer forward direction). Frag fold: `:12547` / `:12615`.
- `h : (kvE2_sepBody …).holds M atomMap x t` IS in theorem scope at the consumption point, so
  threading is *syntactically* trivial — the refutations above are semantic, not plumbing.

## Honest bottom line and recommended route

1. The **successor carrier redefinition** (task 321 verdict N2's named successor:
   bit-compatibility filtering of the interleaving enumeration, O4 record SW:6763-6770;
   equivalently the 330-audit-sanctioned Prop 4.3 navigated exterior-completeness route,
   Rabinovich pp. 6-7) is the only remaining path to a non-vacuous k=2 gate. No fold-interface
   change reaches it.
2. That successor must ALSO redefine the fragment predicate (interior-singleton via
   `kvE2_sepPosI`, not global `kvE2_sepPos`) and re-state the Phase B soundness half against
   it. Recommend annotating `bracketEndChar_kvE2_sound_two_prior_frag` +
   `kvE2_sepFragment` with a VACUITY NOTE (comment-only) so no consumer (esp. task 309)
   builds on the unrealizable fragment.
3. 330-audit fallback remains available: interior + boundary fragment via task 326 +
   `epL`/`epR`/`ptW`, deferring exterior-navigated completeness (this is what the landed
   ⇐ completeness half + interior kit already deliver).

## Verdict JSON

See `.blocker-research-4.json` (verdict NO-GO, `additive_only` n/a, no spawn task proposed —
successor requires its own task with user-visible scope).
