#!/usr/bin/env bash
# Compile-check the tracked evidence probes under `specs/evidence/`.
#
# WHAT A PROBE IS.  Each file under the evidence directory below is a machine-checked record of a
# design obstruction: a `sorry`-free Lean file whose theorems REFUTE something the plan for the
# decision layer once proposed.  They are not tests of the layer's behaviour; they are the reasons
# the layer has the shape it has.
#
# WHY THEY NEED A GUARD.  A probe lives under `specs/`, so no Lake target root reaches it and
# `lake build` never compiles it.  Left alone it rots: the definitions it cites drift, and the
# record silently stops meaning what it says.  Worse, a probe that has quietly stopped compiling
# is no longer an obstacle to anyone, so a future change can undo the very decision it records.
# This script is what keeps that from happening -- it is the analogue, for probes, of the C6 rot
# guard in `check-module-invariants.sh`, and uses the same mechanism (`lake env lean` on a file
# outside the build graph).
#
# WHY THE PROBES DO NOT LIVE IN A TASK DIRECTORY.  They used to, under
# `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/`.  When `/todo` archived that task the
# whole directory moved to `specs/archive/`, which `.gitignore` excludes -- so the four probes left
# version control entirely (absent from a fresh clone) and this guard failed on every run against a
# path that no longer existed.  Nothing announced either fact at the time: no gate then reached
# this script.  One does now -- see WIRED INTO CI below.  A probe outlives the task that
# produced it by construction: it records a design obstruction,
# not a unit of work.  It therefore lives in `specs/evidence/`, which is task-independent and
# tracked, exactly as `specs/reviews/` is.  Do not move a probe back under a task directory.
#
# WIRED INTO CI.  This script runs in CI as step id `evidence-probes` in
# `.github/workflows/ci.yml`.  That step carries `continue-on-error: true`, so it does not
# hard-stop the job by itself; the aggregating `Report results` step counts its outcome and exits
# 1 when any counted step failed.  A rotted probe therefore fails CI.  The consequence for
# whoever reads a red run: a failure here is one of exactly three things, and only one of them is
# a fact about a probe -- see THREE DIAGNOSTIC CLASSES below before repairing anything.
#
# WHAT EACH PROBE HOLDS IN PLACE.  See the tables in the WIRED and WIRED_REPO lists below.
#
# TWO ENTRY FORMS.  `WIRED` entries are paths under `specs/evidence/`, which is where a probe
# belongs.  `WIRED_REPO` entries are full repository-relative paths, for the case where a probe
# cannot yet be moved into the collection because other files cite its current path verbatim.
# Both forms are checked identically by `check_probe` below; the second exists only so that a
# probe stranded outside the collection is still guarded rather than left to rot unwatched.
# Prefer `WIRED`: reach for `WIRED_REPO` only with a named blocker recorded beside the entry.
#
# TRACKED, NOT MERELY PRESENT.  A wired probe must be tracked by git, and `check_probe` tests
# this with `git ls-files --error-unmatch` after the presence test.  Presence alone is not a
# guard: `[ -f ]` is satisfied by a gitignored file under `specs/archive/` (see the
# `specs/archive/` line in `.gitignore`), which is exactly what an archival `mv` of a task
# directory produces -- every file under the moved directory leaves version control in that one
# commit while staying on disk for whoever already had it.  A gate testing presence alone then
# stays green on every such machine and fails on every clean checkout (CI included), which is the
# worst combination: the breakage is invisible to the person who caused it.  Consequence for a
# `WIRED_REPO` entry pointing into a task directory: the entry must be re-pointed, or the file
# promoted to `specs/evidence/`, BEFORE that task is archived.  A `FAIL (untracked: ...)` from
# this script means that did not happen.
#
# THREE DIAGNOSTIC CLASSES.  A failing line is exactly one of these, and the label says which:
#
#   `FAIL (does not compile)`  ROT.  The probe cites something that has drifted.  This is the
#                              failure this guard exists to catch.  Repair the citation under the
#                              no-weakening rule; never delete or restate an obstruction to make
#                              it pass.
#   `FAIL (untracked: ...)`    LEFT VERSION CONTROL.  The file is on this disk but absent from a
#                              fresh clone.  Promote it into `specs/evidence/`; see TRACKED, NOT
#                              MERELY PRESENT above.
#   `FAIL (environment: ...)`  ENVIRONMENT.  A `.lake` artifact was absent or half-written, so the
#                              probe's import closure could not be loaded and the probe's own
#                              content was never measured at all.
#
# TRIAGE RULE: a missing-object-file error (`object file '...' of module ... does not exist`) is
# NEVER probe rot and never source rot.  It is an I/O failure of the build tree.  The correct
# response is to re-run once any concurrent `lake build` has finished, or to build the project if
# it is not built -- not to touch a probe.  No probe is repaired, restated, or retired on that
# evidence.  Reading an environment failure as rot is how a single transient `.lake` race once
# became four apparently-rotted probes and a repair record for probes that were never broken.
#
# SERIALIZED AGAINST CONCURRENT BUILDS.  This script holds an `flock` on
# `$REPO_ROOT/.lake/build-guard.lock` for its whole run -- the path
# `.claude/scripts/lake-build-guard.sh` publishes and `scripts/check-module-invariants.sh` takes
# at its `C1: build` block -- because every `lake env lean` invocation below reads `.lake` while
# another guarded build may be rewriting it.  The rationale and the two rejected alternatives are
# recorded at that `C1` block and are not restated here; the in-place detail is in the SHARED
# `.lake` LOCK block further down this file.  The wait is bounded at 600 s and announced on
# stderr the moment it starts.  `PROBE_LOCK_WAIT_S` overrides the bound; it exists so the timeout
# branch can be exercised deliberately and is not a tuning knob.  A caller holding this same lock
# around an invocation of this script would see a bounded, labeled failure rather than a hang.
#
# Usage:
#   bash scripts/check-evidence-probes.sh
#
# Exit status: 0 if every wired probe compiles, 1 otherwise -- including the case where no probe
#   was compile-checked at all because the bounded wait for the shared build lock timed out,
#   which is reported as an ENVIRONMENT-class failure.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

# Collection-relative: each WIRED entry below is a path under `specs/evidence/`, so several
# probe collections can be guarded by the one loop.
EVIDENCE="specs/evidence"

# --- WIRED --------------------------------------------------------------------------------
# probe (path under specs/evidence/)                        | the decision it holds in place
# ----------------------------------------------------------|-----------------------------------
# bi-lasso-decision-layer/phase3-scan-bound-is-false         | no bound computed from the lasso's
#                                                           | segment lengths alone can drive a
#                                                           | semantic scan -- this is why the
#                                                           | layer enumerates annotations instead
#                                                           | of evaluating
# bi-lasso-decision-layer/phase7-filtered-frame-is-universal | the filtered frame's one-step
#                                                           | relation is universal, so it carries
#                                                           | no dynamics -- this is why the layer
#                                                           | presents frames rather than
#                                                           | filtering
# bi-lasso-decision-layer/phase12-check-not-compositional    | the `imp` case admits no
#                                                           | compositional reading -- this is why
#                                                           | `check`'s two existentials sit
#                                                           | OUTSIDE any recursion on the formula
# bi-lasso-decision-layer/phase10-origin-anchoring-obstruction | no recurrence of the type at the
#                                                           | point of interest need exist -- this
#                                                           | is what stops `check` being
#                                                           | re-anchored at position 0.
#                                                           | Load-bearing: it is the probe a
#                                                           | future dispatch is most likely to
#                                                           | try to contradict, since anchoring
#                                                           | looks like a cleanup
# stability-modal-substrate/closure-field-is-necessary   | `SharingSkeleton`'s `lift` field is a
#                                                           | genuine obligation, not a defensive
#                                                           | one.  Give the landed (C5) witness
#                                                           | `stabFamily` the no-hopping
#                                                           | succession bundle, changing nothing
#                                                           | else, and `LiftableRaw` becomes
#                                                           | FALSE: `crossPath` is a `Step`-path
#                                                           | no index-identity path tracks.  This
#                                                           | is why `lift` is a field every
#                                                           | producer discharges rather than a
#                                                           | lemma proved once, and it is the
#                                                           | probe a future dispatch is most
#                                                           | likely to try to eliminate, since
#                                                           | the field looks like boilerplate
# frame-constraints-audit/mixed-sign-composition-obstruction | mixed-sign composition (`TotalComp`)
#                                                           | must NOT be added to `def:frame` --
#                                                           | the drift frame `F°` satisfies all
#                                                           | four constraints and fails it, and
#                                                           | `app:drift` needs `F°` for
#                                                           | `cor:no-characterization`.  It also
#                                                           | carries the positive half:
#                                                           | `Completion -> Saturation` holds
#                                                           | UNDER `TotalComp`, which locates the
#                                                           | obstruction exactly
# seam-gluing-ray-product/stab-fibre-is-ray-product         | the `⊡` quantification domain IS the
#                                                           | fibre product of the past-ray and
#                                                           | future-ray spaces over the seam
#                                                           | state (general task frame, and the
#                                                           | ω-sequence form over ℤ) -- this is
#                                                           | the MECHANISM behind the finite-width
#                                                           | refutation (a product of two path
#                                                           | spaces cannot be a finite fibre), not
#                                                           | an escape from it, and every route in
#                                                           | the omega-sequence-decidability round
#                                                           | assumes it
# seam-gluing-ray-product/stab-depth-stratification         | POSITIVE: the `⊡`-value at a state
#                                                           | is computable from a per-state
#                                                           | labelling stratified by `⊡`-depth
#                                                           | (`stratum`), which is exactly what
#                                                           | the landed `atomize` /
#                                                           | `plusTruthAt_iff_atomize` already
#                                                           | supplies -- this licenses R1's
#                                                           | automaton ALPHABET; it bounds and
#                                                           | decides nothing on its own
# seam-gluing-ray-product/finite-graph-stab-summary         | POSITIVE (forward factor, on the
#                                                           | fixture): `⊡(Fp)` at a seam state
#                                                           | is exactly "every forward root path
#                                                           | from that state meets `p`" -- R1's
#                                                           | route-killer test survives at this
#                                                           | cheapest single-operator shape.
#                                                           | Backward dual not separately proved
#                                                           | (symmetric fixture, no new
#                                                           | machinery); decidable witness: on
#                                                           | the total-graph fixture `⊡(Fp)` is
#                                                           | decidably False everywhere
# seam-gluing-ray-product/mosaic-germ-amalgamation          | POSITIVE: R2's amalgamation
#                                                           | precondition is free -- `paste`
#                                                           | (`app:gluing`'s binary case) glues
#                                                           | two mosaics agreeing at a shared
#                                                           | germ, choice-free, with uniqueness.
#                                                           | The `⊡`-saturation decidability
#                                                           | question is fixed as a `Prop`
#                                                           | (`StabSaturated`), proved only in
#                                                           | the same-state corner -- attacked by
#                                                           | name and found VACUOUS by the
#                                                           | mosaic-stab-saturated entry below
# seam-gluing-ray-product/path-quantifier-alternation       | NECESSITY DEMONSTRATED: on the
#                                                           | Phase-3 fixture the existential
#                                                           | (nondeterministic) summary is True
#                                                           | everywhere while `⊡(Fp)` is False
#                                                           | everywhere -- a universal,
#                                                           | complementation-shaped summary is
#                                                           | genuinely required for this
#                                                           | fragment. Discharges the settled
#                                                           | determinization-funding decision's
#                                                           | evidence condition; funds nothing
#                                                           | by itself and begins no
#                                                           | determinization work
# seam-gluing-ray-product/backward-dual-asymmetric-fixture  | POSITIVE (backward factor, on a
#                                                           | TIME-ASYMMETRIC fixture): the
#                                                           | backward stability operator at a
#                                                           | seam state is exactly "every
#                                                           | backward root path from that state
#                                                           | meets the `p`-set", decided by
#                                                           | backward reachability alone and
#                                                           | STATE-DEPENDENTLY -- True at the
#                                                           | `post` states, False at the `x` and
#                                                           | `pre` states. The dual the
#                                                           | finite-graph probe records as
#                                                           | excluded, now on the fixture whose
#                                                           | relation is NOT symmetric under
#                                                           | time reversal, which is where the
#                                                           | finite-width obstruction lives.
#                                                           | Honest limit, in the probe's own
#                                                           | header: that fixture is backward
#                                                           | DETERMINISTIC, so its backward
#                                                           | factor is a singleton and this is
#                                                           | the dual at its easiest instance;
#                                                           | the hard test is a mirror fixture,
#                                                           | filed as a follow-up and discharged
#                                                           | by the mirror-fixture entry below.
#                                                           | No automata
# seam-gluing-ray-product/backward-dual-mirror-fixture      | POSITIVE (backward factor, on the
#                                                           | MIRROR fixture -- time-asymmetric
#                                                           | AND backward-branching, factor 2 at
#                                                           | every spine state): the backward
#                                                           | stability operator at a seam state
#                                                           | is exactly "every backward root path
#                                                           | from that state meets the `p`-set",
#                                                           | decided by backward reachability
#                                                           | alone and STATE-DEPENDENTLY -- True
#                                                           | at the `aft` states, False at the
#                                                           | `x` and `bef` states; two distinct
#                                                           | backward root paths from the state
#                                                           | under test (`two_bwd_paths`,
#                                                           | axiom-free). Discharges E1's "mirror
#                                                           | fixture filed as a follow-up" note
#                                                           | (the entry above). No automata, no
#                                                           | width bound, no complexity claim
# seam-gluing-ray-product/device-selection-probe            | DEVICE-SELECTION (E3): `⊡(Fp)` /
#                                                           | `⊡(Pp)` are device-inert on finite
#                                                           | fixtures (machine-checked:
#                                                           | `allPathsMeet_iff_lasso`,
#                                                           | `detRun_accepts_iff`,
#                                                           | `stab_will_iff_lasso`); pigeonhole-
#                                                           | tier lasso summaries refuted on
#                                                           | infinite fibres
#                                                           | (`not_lasso_sufficient_on_chain`).
#                                                           | Selection on infrastructure +
#                                                           | literature evidence = time-axis
#                                                           | Ramsey (d) via in-tree
#                                                           | `infinite_ramsey_pairs`, framed by
#                                                           | the HWZ/GKWZ MSO-over-<Z,<> route
#                                                           | (c); (a) Safra/Piterman and (b)
#                                                           | Safraless NOT selected (inert on the
#                                                           | shapes; no formalization anywhere;
#                                                           | (b)'s 2005 source WANTED). No
#                                                           | complexity bound. Begins no
#                                                           | substrate work
# seam-gluing-ray-product/cslib-ramsey-port-feasibility     | PORT FEASIBILITY (736): cslib's
#                                                           | `infinite_graph_ramsey` (Ching-Tsun
#                                                           | Chou, upstream
#                                                           | `leanprover/cslib`) compiles on THIS
#                                                           | pin from Mathlib alone, sorry-free,
#                                                           | with no `Cslib.*` import and no
#                                                           | `module`/`public import` preamble --
#                                                           | so the cslib stack is portable in
#                                                           | principle. And it SUBSUMES this
#                                                           | tree's `ForMathlib`
#                                                           | `Nat.exists_strictMono_const_pair_colour`:
#                                                           | `repo_ramsey_from_cslib_ramsey`
#                                                           | derives the in-tree statement from
#                                                           | the ported one through an
#                                                           | unordered/ordered pair bridge and
#                                                           | `Nat.nth`, and the statement
#                                                           | identity is itself machine-checked
#                                                           | (`RepoRamseyStatement` discharged
#                                                           | twice). This is why the ForMathlib
#                                                           | module is NOT redefined as a
#                                                           | corollary: subsumption holds, but
#                                                           | the port plus glue is a net
#                                                           | ADDITION of lines, and the live
#                                                           | consumers in
#                                                           | `RamseyFactorization.lean` need the
#                                                           | curried ordered form. Also records
#                                                           | measured port friction: cslib's
#                                                           | Mathlib rev is 76 commits ahead and
#                                                           | its HEAD commit is the
#                                                           | `restrict`->`domRestrict` rename,
#                                                           | which breaks the first ported line.
#                                                           | Establishes NO portability for
#                                                           | `BuchiCompl.lean`, whose main
#                                                           | theorems are `proof_wanted`
# seam-gluing-ray-product/ktype-summary-substrate-probe     | SUBSTRATE (probe i): the k-type
#                                                           | summary substrate
#                                                           | (`WeakCanonical/KTypeSummary/`,
#                                                           | Buechi's complementation chain in
#                                                           | the monadic k-type idiom over the
#                                                           | Z time axis) run END TO END on a
#                                                           | concrete infinite fibre: explicit
#                                                           | cutting `W z := 2 * z` of the
#                                                           | even-parity block with its three
#                                                           | segment type equations PROVED by
#                                                           | order isomorphism (never by
#                                                           | evaluating `kTypeOf`), the cover
#                                                           | `family_cover` agreeing with it,
#                                                           | the triple confirmed degenerate,
#                                                           | and the central fact: the DISTINCT
#                                                           | odd-parity block cut at the odd
#                                                           | times lies in the SAME family, so
#                                                           | the two blocks have equal k-type at
#                                                           | every depth
#                                                           | (`zFiber_cPar_eq_cOdd`, via
#                                                           | `kTypeOf_zFiber_eq_of_inFamily`);
#                                                           | `family_saturation` and
#                                                           | `target_eq_union_of_families`
#                                                           | instantiated on the
#                                                           | normal-form target. Establishes NO
#                                                           | decidability, NO complexity bound,
#                                                           | NO reduction of any stab condition
#                                                           | to a k-type target (the seam
#                                                           | interface's `Presents` bundle is
#                                                           | cited, not inhabited), and no
#                                                           | k-type DISTINCTNESS
# seam-gluing-ray-product/stab-depth-two-probe              | E2 (probe ii): the depth-2
#                                                           | stratification probe on the
#                                                           | smallest fixture whose depth-1
#                                                           | stab value is STATE-DEPENDENT
#                                                           | (two states a, b; edges a->a,
#                                                           | a->b, b->b; p at b): `stab (F p)`
#                                                           | holds iff the seam state is b
#                                                           | (`stab_will_iff`); both depth-2
#                                                           | shapes `stab F (stab F p)` and
#                                                           | `stab (F p -> stab F p)` computed
#                                                           | DIRECTLY (`depth2_1_iff`,
#                                                           | `depth2_2_iff`: iff the state is
#                                                           | b) and THROUGH THE STRATA over the
#                                                           | atomized model, reading the inner
#                                                           | stab through its depth-1 stratum
#                                                           | (`depth2_via_strata_1/_2`, with
#                                                           | `plusTruthAt_iff_atomize` cited);
#                                                           | the falsifier check
#                                                           | `value_is_function_of_stratum`
#                                                           | is POSITIVE on this fixture. Not a
#                                                           | proof the falsifier cannot exist:
#                                                           | the real test is a fixture with
#                                                           | two states SHARING a depth-1
#                                                           | stratum, filed as a follow-up
# seam-gluing-ray-product/stab-depth-two-shared-stratum     | E2 (probe iii): the follow-up
#                                                           | above, run. Four states a, b, c,
#                                                           | d (edges a->a, a->b, b->b, b->d,
#                                                           | d->b, c->c; p at b), bi-serial by
#                                                           | `Rg_fwd`/`Rg_bwd`, with two
#                                                           | genuinely SHARED depth-1 classes:
#                                                           | {a, c} (`stab (F p)` False) and
#                                                           | {b, d} (True), certified by
#                                                           | `shared_false_stratum` /
#                                                           | `shared_true_stratum`. Five
#                                                           | depth-2 shapes computed directly
#                                                           | and through the strata. The
#                                                           | one-bit falsifier check is
#                                                           | REFUTED for the landed shape
#                                                           | `stab (F p -> stab F p)` on
#                                                           | {a, c}, the mixed shape
#                                                           | `stab (F p -> stab P p)` on
#                                                           | {b, d}, and the past mirror
#                                                           | `stab P (stab F p)` on {b, d}
#                                                           | (`not_function_of_stratum_*`);
#                                                           | it SURVIVES non-vacuously for
#                                                           | `stab F (stab F p)` on both
#                                                           | classes, `stab (P p -> stab F p)`
#                                                           | everywhere, and the landed shape
#                                                           | on {b, d}. Holds in place: the
#                                                           | time-axis route may assume NO
#                                                           | one-bit-per-depth summary; the
#                                                           | per-state label must carry the
#                                                           | closure-indexed alphabet (one
#                                                           | label per stab-subformula,
#                                                           | backward ones included). The
#                                                           | landed probe's positive on its
#                                                           | own fixture is untouched
# seam-gluing-ray-product/presents-is-seam-decidedness      | OBSTRUCTION (737): the
#                                                           | single-family hypothesis bundle
#                                                           | `RaySummary.Presents` is SEAM
#                                                           | DECIDEDNESS, not the MSO
#                                                           | reduction: on the E2 fixture
#                                                           | (transcribed, never imported)
#                                                           | the seam `(stayA c t, t)` is
#                                                           | undecided on `F p` -- `stayA`
#                                                           | refutes it, `jumpB` satisfies
#                                                           | it, both through `(c, a)`
#                                                           | (`seam_undecided`, against the
#                                                           | library's `SeamDecided`) -- so
#                                                           | NO `Presents` inhabitant exists
#                                                           | there for any `sig`, `k`, `T`,
#                                                           | `S` (`no_presents_on_fixture`,
#                                                           | by the library's
#                                                           | `seamDecided_of_presents`).
#                                                           | Holds in place: no decidability
#                                                           | result may be assembled on
#                                                           | `plusStab_iff_seamSummary` as if
#                                                           | `colours` were the MSO
#                                                           | reduction; the consumer must go
#                                                           | through `Hit` and the
#                                                           | hypothesis-free
#                                                           | `plusStab_iff_forall_hit`
#                                                           | (cited, not re-proved). Forward
#                                                           | only (`F p`); nothing about
#                                                           | `⊡(P p)`; `Hit` not computed
# seam-gluing-ray-product/quasistate-does-not-determine-hit | OBSTRUCTION (742, B2b verdict):
#                                                           | the HWZ-verbatim quasistate
#                                                           | shape -- per-time realized
#                                                           | closure types as bare sets plus
#                                                           | the consecutive-type relation
#                                                           | (HWZ 2000 Defs 10-12 over Z, no
#                                                           | product repair) -- does NOT
#                                                           | determine `Hit`: two regular
#                                                           | three-state fixtures (`a→a,
#                                                           | a→b, b→b, d→d, d→b` vs the same
#                                                           | graph without `a→b`; `p` at
#                                                           | `b`; `cl = {p, Fp}`) have equal
#                                                           | quasistates
#                                                           | (`quasiState_A_eq_B`) and equal
#                                                           | pair relations
#                                                           | (`pairRel_A_eq_B`) at every
#                                                           | time, yet different `⊡¬Fp` at
#                                                           | the seam `(stayA, t)`
#                                                           | (`stab_notFp_A`/`_B`), hence
#                                                           | different `Hit` at `k = 1`
#                                                           | through the library's
#                                                           | `plusStab_iff_forall_hit`
#                                                           | (`hit_ne`; headline
#                                                           | `quasistate_does_not_determine_hit`).
#                                                           | Holds in place: no B2b may be
#                                                           | transcribed in the quasistate
#                                                           | shape and fed to
#                                                           | `plusStab_iff_forall_hit`; the
#                                                           | per-model bridge must carry
#                                                           | joint realization through the
#                                                           | seam. Forward only; nothing
#                                                           | about `⊡(P p)`; `Hit` still not
#                                                           | computed
# seam-gluing-ray-product/presented-not-complete            | OBSTRUCTION (verdict on the
#                                                           | ray-product assembly): the
#                                                           | realization hypothesis
#                                                           | `RaySummary.Presented` (the
#                                                           | seam's closure traces are
#                                                           | exactly a finite presentation's
#                                                           | run traces) is NOT a completeness
#                                                           | carrier: on model A of the B2b
#                                                           | verdict probe (transcribed,
#                                                           | never imported; `a→a, a→b, b→b`,
#                                                           | `p` at `b`, `cl = {p, Fp}`) at
#                                                           | the seam `(t, a)` it fails for
#                                                           | EVERY finite `Q`, `lab`, `step`
#                                                           | (`not_presented`), by pumping a
#                                                           | repeated run state (`pump_isRun`)
#                                                           | against the `untl` run condition
#                                                           | through the library's
#                                                           | `clTrace_localRun`. Holds in
#                                                           | place: `Presented` is a soundness
#                                                           | device (B2b's
#                                                           | `Presented (modelOf P)`), never a
#                                                           | completeness one; no decision
#                                                           | procedure for `PlusValidZTime φ`
#                                                           | may proceed by "every refuting
#                                                           | regular ℤ-model has a `Presented`
#                                                           | presentation", and B2b's
#                                                           | consistency conditions must
#                                                           | exclude pumpable
#                                                           | eventuality-deferring run sets
#                                                           | (`presented_localRun`). The
#                                                           | assembly's three missing theorems,
#                                                           | named and NOT in the tree: (C)
#                                                           | Hit-level completeness with a
#                                                           | computable presentation bound;
#                                                           | (S) Hit-level soundness of
#                                                           | refutation (the unfiled B2b
#                                                           | record restated); (W) a
#                                                           | closure-wide quasimodel over all
#                                                           | seams at once. Forward only;
#                                                           | nothing about `⊡(P p)`;
#                                                           | `HitPresented` left OPEN there
#                                                           | (SETTLED on this fixture by
#                                                           | `hit-presented-model-a` below:
#                                                           | satisfiable, with the size exhibited
#                                                           | as a count; general (C) still open)
# seam-gluing-ray-product/hit-presented-model-a             | POSITIVE (requirement (C)'s
#                                                           | satisfiability half): the HIT-level
#                                                           | realization hypothesis
#                                                           | `RaySummary.HitPresented` -- the seam's
#                                                           | realized FAMILY TRIPLES are exactly a
#                                                           | finite presentation's, the Hit-level
#                                                           | hypothesis named in
#                                                           | `presented-not-complete`'s header and
#                                                           | left OPEN there -- is SATISFIABLE on
#                                                           | that probe's model A (transcribed,
#                                                           | never imported; `a→a, a→b, b→b`, `p`
#                                                           | at `b`, `cl = {p, Fp}`) at the seam
#                                                           | `(t, a)` of `stayA` with `φ := Fp`, at
#                                                           | EVERY depth `k ≥ 1`
#                                                           | (`hitPresented_modelA`), by the
#                                                           | rigidity of `RA` (every step path
#                                                           | through the seam is the constant
#                                                           | `a`-path or an `a`-then-`b` jump,
#                                                           | `path_classify`, `splice_classify`),
#                                                           | the truncation of the seam's infinite
#                                                           | ray index to a finite window
#                                                           | (`hitCl_eq_truncated`) and a
#                                                           | two-gadget presentation whose anchored
#                                                           | runs realize exactly that window
#                                                           | (`runTrace_mem_of_isRun`,
#                                                           | `exists_isRun_runTrace`). Holds in
#                                                           | place: the `Presented` refutation does
#                                                           | NOT transfer to the Hit level, because
#                                                           | what `Probe735.not_presented` refutes
#                                                           | is an equality of TRACE sets and this
#                                                           | is an equality of FAMILY-TRIPLE sets --
#                                                           | the two hold side by side on the SAME
#                                                           | fixture, seam and `φ` -- so the route
#                                                           | through requirement (C) is NOT closed
#                                                           | by that verdict, which stands
#                                                           | unchanged. The presentation size is
#                                                           | EXHIBITED in the statement, as a
#                                                           | COUNT: `presentationSize k =
#                                                           | Nat.card (KType (clSig Fp) k)`, so
#                                                           | `card_QA_presentationSize` reads
#                                                           | `presentationSize k + 6` -- a count of
#                                                           | depth-`k` types and nothing else, not
#                                                           | a complexity bound of any kind (by the
#                                                           | library's pigeonhole periodicity, the
#                                                           | Transport.lean cut surgery and the
#                                                           | fixture's `run_subset_middle`). (C)'s
#                                                           | general every-model half stays OPEN,
#                                                           | the (W) run-layer record's. Forward only;
#                                                           | nothing about `⊡(P p)`;
#                                                           | `Decidable (PlusValidZTime φ)` NOT
#                                                           | stated in any form, conditional or
#                                                           | otherwise, and no claim that L⁺ is
#                                                           | decidable, qualified or not; one
#                                                           | fixture, one seam, one `φ`
# seam-gluing-ray-product/b2b-frame-constructor-branching   | MIXED (746, requirement (S)'s carried
#                                                           | prerequisite): the 300-500 line
#                                                           | regular-frame constructor for
#                                                           | "finitely many fibre shapes per time"
#                                                           | is DESCOPED from (S), and its load-
#                                                           | bearing core is proved rather than
#                                                           | discarded. POSITIVE:
#                                                           | `ofSlicedStep_fib_finite`'s `[Finite
#                                                           | W]` is replaceable by two-sided finite
#                                                           | branching on the one-step relation with
#                                                           | no carrier hypothesis at all
#                                                           | (`fib_finite_of_finBranch`,
#                                                           | `saturation_of_finBranch`), two-sided
#                                                           | because `TaskFrame.Fib` at NEGATIVE
#                                                           | durations is the step relation's
#                                                           | preimage and finiteness is not
#                                                           | converse-stable; non-vacuous on a
#                                                           | genuinely infinite slice
#                                                           | (`shift_saturation` over `ℤ`,
#                                                           | `shift_slice_infinite`), a shape
#                                                           | `ofSlicedStep_saturation` cannot state.
#                                                           | REFUTED, twice: the named reset-from-
#                                                           | any-level hazard is real (`Rbad_fwd`
#                                                           | finite, `Rbad_bwd_infinite`, and the
#                                                           | `d = -1` fibre itself infinite,
#                                                           | `Rbad_fib_infinite`), AND the obvious
#                                                           | repair of firing the reset only from
#                                                           | level `0` merely swaps the failing side
#                                                           | (`Rok_bwd` finite, `Rok_fwd_infinite`)
#                                                           | -- an unbounded nondeterministic
#                                                           | deadline is infinite-branching wherever
#                                                           | it fires, so no reset PLACEMENT
#                                                           | rescues it. Holds in place: the
#                                                           | constructor is NOT a dependency of
#                                                           | requirement (S) -- in (S) the
#                                                           | presentation is given and liveness
#                                                           | sits in the `Cons` hypothesis, so
#                                                           | `ofSlicedStep` on the presentation's
#                                                           | own finite `Q` suffices unchanged --
#                                                           | and a successor record inheriting this
#                                                           | must finitize the committed deadline
#                                                           | before two-sided finite branching is
#                                                           | available. What it does NOT do: build
#                                                           | the constructor (no
#                                                           | `ofSlicedStepBranch`, no restatement
#                                                           | of the nine `[Finite W]`-carrying
#                                                           | declarations of `SlicedFrame.lean`, no
#                                                           | `FrameOver`/`IsRegular` instance under
#                                                           | the weaker hypothesis); exhibit a
#                                                           | deferring encoding that DOES have two-
#                                                           | sided finite branching (the design
#                                                           | space is bounded, not closed); touch
#                                                           | `RaySummary` or realize any
#                                                           | presentation. No complexity bound;
#                                                           | `Decidable (PlusValidZTime φ)` NOT
#                                                           | stated in any form
# seam-gluing-ray-product/mosaic-stab-saturated             | VACUOUS, recorded (E4): the landed Probe
#                                                           | 718 StabSaturated predicate is
#                                                           | identically true on EVERY finite mosaic
#                                                           | set, mixed germ states included
#                                                           | (stabSaturated_univ; Smix_mixed +
#                                                           | Smix_stabSaturated on the E2 Bool
#                                                           | fixture), so it is decidable because
#                                                           | constant and the review's literal R2
#                                                           | falsifier is unsatisfiable. The real SH1
#                                                           | content is the witness direction
#                                                           | (StabWitnessedAt): HOLDS on {stayA,
#                                                           | jumpB, stayB}, FAILS on {jumpB, stayB},
#                                                           | both mixed -- finitely checkable only
#                                                           | once the per-mosaic ⊡-value is known,
#                                                           | which on this fixture is R1's
#                                                           | stab_will_iff. Holds in place: R2's
#                                                           | hypothesis is restated as a SYNTACTIC
#                                                           | saturated-set existence theorem with a
#                                                           | bespoke ⊡-fibre interaction condition
#                                                           | (Caleiro 2013 section 4.3: mosaic
#                                                           | decidability does not transfer once the
#                                                           | dimensions interact); R2 neither
#                                                           | promoted nor closed; Handbook ch. 11
#                                                           | sections 5.10-5.11 remain a recorded
#                                                           | residual gap
#                                                           | (specs/literature-index.json,
#                                                           | hodkinson_2006). No complexity claim, no
#                                                           | certificate class, no edit to the Probe
#                                                           | 718 file.
# seam-gluing-ray-product/w-soundness-shape-refuted         | OBSTRUCTION (747, requirement (W)'s
#                                                           | run-layer verdict): requirement (S)'s
#                                                           | construction `modelOf` cannot be the
#                                                           | soundness half of (W) for
#                                                           | `box`/`stab`-bearing L⁺, on two
#                                                           | independent axes. WIDTH: `frameOf` is
#                                                           | `ofSlicedStep` on the presentation's
#                                                           | finite `Q`, so the library's
#                                                           | `no_finite_width_sat` applies verbatim
#                                                           | and EVERY `Cons` model validates
#                                                           | `Φ.neg` (`modelOf_sat_neg_Φ`), a
#                                                           | ℤ-time non-validity
#                                                           | (`not_plusValidZTime_neg_Φ`); the gap
#                                                           | is `modelOf_incomplete`, and no clause
#                                                           | added to `Cons` closes it. COLLAPSE: at
#                                                           | any `Presented` seam whose presentation
#                                                           | marks at most one `now` state (exactly
#                                                           | `Cons.nowUnique`, which (S) needed),
#                                                           | every closure formula satisfies
#                                                           | `ψ ↔ ⊡ψ`
#                                                           | (`stab_iff_of_presented_nowUnique`, via
#                                                           | `exists_spliced_eq` off `seamOmegaEquiv`
#                                                           | and `presented_letter_at_seam`), so no
#                                                           | `⊡`-refutation such as `Fp → ⊡Fp` is
#                                                           | ever witnessed there -- independent of
#                                                           | width. Holds in place: the (W) run
#                                                           | layer is BLOCKED on three named
#                                                           | obligations (RaySummary README, "(W):
#                                                           | what landed and what did not") -- an
#                                                           | infinite-width finitely-branching frame
#                                                           | constructor, a Hit-level per-cell
#                                                           | realization hypothesis (never trace-
#                                                           | level `Presented`), and the bound
#                                                           | `kTypeOf_listSeg_replicate_eventually_
#                                                           | periodic`; the anchor layer
#                                                           | (`RaySummary/AnchorLayer.lean`) does
#                                                           | not depend on any of them. What it does
#                                                           | NOT do: (S) is UNTOUCHED
#                                                           | (`presented_modelOf` is a correct
#                                                           | soundness statement for
#                                                           | `box`/`stab`-free `φ` at one seam);
#                                                           | nothing is a negative decidability
#                                                           | result; nothing about `⊡(Pp)` (forward-
#                                                           | only, no backward Bool-fixture bridge);
#                                                           | nothing about `HitPresented`, which
#                                                           | holds on model A
#                                                           | (`Probe745.hitPresented_modelA`); no
#                                                           | complexity bound; `Decidable
#                                                           | (PlusValidZTime φ)` NOT stated in any
#                                                           | form
# seam-gluing-ray-product/deadline-ladder-branching         | DESIGN VERDICT (requirement (W)'s
#                                                           | run layer, "(W): what landed and what
#                                                           | did not", obligation (i)): the
#                                                           | frame scheme is the DEADLINE LADDER
#                                                           | (thread-indexed unfolding in its
#                                                           | general form: states `(q, c, n)`, the
#                                                           | current deadline counting down
#                                                           | deterministically, the next deadline
#                                                           | drifting by at most one per step, so
#                                                           | no state chooses a deadline), landed
#                                                           | in `RaySummary/RunLayer.lean`. The
#                                                           | probe cites the library and re-proves
#                                                           | nothing: `ladder_fwd`/`ladder_bwd`
#                                                           | (two-sided finite branching for EVERY
#                                                           | finite object, `Rlad_fwd`/`Rlad_bwd`),
#                                                           | `ladder_slice_infinite`
#                                                           | (`Rlad_slice_infinite`), and
#                                                           | `ladder_isRegular`
#                                                           | (`ladderFrame_isRegular`, `Saturation`
#                                                           | from `saturation_of_finBranch`, no
#                                                           | `[Finite W]` on the carrier), so
#                                                           | Probe746's positive half applies to
#                                                           | the ladder unchanged. REFUTES the
#                                                           | capped variant: `capped_carrier_finite`
#                                                           | -- a fixed cap gives the finite slice
#                                                           | `Q × Fin (N+1) × Fin (N+1)`, the
#                                                           | finite-width shape
#                                                           | `not_finite_width_fmp` refutes; a
#                                                           | state-chosen deadline is Probe746's
#                                                           | `Rok`/`Rbad`. Depth `k = 1`. What it
#                                                           | does NOT say: nothing about
#                                                           | realization (phase 2; its first lemma,
#                                                           | the stabilization of realized cells in
#                                                           | the counter pair, is REFUTED by the
#                                                           | twelfth probe
#                                                           | `ladder-cell-refutation.lean`),
#                                                           | nothing about `HitPresented`, nothing
#                                                           | about `⊡(Pp)` (forward-only);
#                                                           | seriality is the object's `fwd`/`bwd`
#                                                           | hypotheses; no complexity bound;
#                                                           | `Decidable (PlusValidZTime φ)` NOT
#                                                           | stated in any form
# seam-gluing-ray-product/node-cell-stabilization           | POSITIVE VERDICT (requirement (W)'s run
#                                                           | layer, "(W): what landed and what did
#                                                           | not", obligation (ii) item 1, on the
#                                                           | one-region fixture): realized cells on
#                                                           | `Limits/NoFiniteWidth.lean`'s `Node`,
#                                                           | for its own witness `Φ` (fallback `D`
#                                                           | not needed), STABILIZE past pre-index 1
#                                                           | (`preCell_stable`); `pre 0` and `pre 1`
#                                                           | DIFFER (`preCell_zero_ne`: the deadline
#                                                           | index is real); the thread index is
#                                                           | INVISIBLE (`postCell_stable`, its `1 ≤
#                                                           | j` hypotheses vacuous on `Node` --
#                                                           | `postCell_subset` has none; bonus
#                                                           | `xCell_stable`). `cellAt` is
#                                                           | `RaySummary/AnchorLayer.lean`'s. The
#                                                           | probe cites the fixture (`hist_canon`,
#                                                           | `canon_*`, `truth_p/Fp/Pp/Xp`, `Φ_true`,
#                                                           | `box_global`, `mem_cellAt_iff`,
#                                                           | `mem_tpOf_iff`) and re-proves nothing.
#                                                           | MECHANISM (branch-time saturation): on a
#                                                           | canonical history every member of `cl Φ`
#                                                           | is a Boolean combination of `s<t`,
#                                                           | `s=t`, `t<s`, `s+1=t`, never of the
#                                                           | thread index, so types depend on the
#                                                           | relative-position class
#                                                           | `{<0},{0},{1},{≥2}` only
#                                                           | (`truth_transfer`, `tpOf_eq_of`); cells
#                                                           | as SETS: `pre 0 ↦ {tp 1}`, `pre (≥1) ↦
#                                                           | {tp 1, tp ≥2}`, `x ↦ {tp 0}`, `post ↦
#                                                           | {tp <0}`. The separator between `pre 0`
#                                                           | and `pre 1` is the non-`⊡` letter `Xp`
#                                                           | as set membership of a second type, NOT
#                                                           | a `⊡`-letter: `⊡Xp ∉ cl Φ` and `⊡¬Xp` is
#                                                           | false at every pre state
#                                                           | (`truth_stabNegXp`), so all four
#                                                           | `⊡`-letters of `cl Φ` agree at `pre 0`
#                                                           | and `pre 1`. Axioms `[propext,
#                                                           | Classical.choice, Quot.sound]` (choice
#                                                           | via `hist_canon`). What it does NOT say:
#                                                           | forward-only, nothing about `⊡(Pp)`; no
#                                                           | bound of any kind (the "1" is where THIS
#                                                           | fixture's cells coincide, not a bound
#                                                           | syntactic in `φ`); no finiteness (`Node`
#                                                           | is infinite-width); no claim that
#                                                           | `⊡`-letters discriminate between
#                                                           | devices; nothing about `HitPresented` or
#                                                           | `PlusValidZTime`; nothing about the
#                                                           | general ladder lemma
# seam-gluing-ray-product/hit-presented-node                | POSITIVE (requirement (C)'s Hit-level
#                                                           | hypothesis on a ⊡-bearing alphabet at an
#                                                           | infinite-width seam, on the one-region
#                                                           | fixture): `HitPresented` holds on
#                                                           | `Limits/NoFiniteWidth.lean`'s `M` at
#                                                           | every pre-seam `(t, pre m)` for its own
#                                                           | witness `Φ` (fallbacks `D`, `⊡Xp` not
#                                                           | needed; 28 closure letters plus `now`)
#                                                           | at every depth `k ≥ 1`
#                                                           | (`hitPresented_node`; the dispatch's
#                                                           | single-index shape
#                                                           | `hitPresented_node_canon`), with the
#                                                           | size `windowN m k + 5`, `windowN m k =
#                                                           | min m (Nat.card (KType (clSig Φ) k) +
#                                                           | 1)`, EXHIBITED in the statement and
#                                                           | bounded uniformly over every seam by
#                                                           | `card_QN_le` -- a count of states and
#                                                           | depth-`k` types, not a complexity bound.
#                                                           | ROUTE: seam classification
#                                                           | (`through_pre`: exactly `m + 1`
#                                                           | canonical histories through `(t, pre
#                                                           | m)`); four relative-position letter
#                                                           | classes (`clTrace_canon_apply`);
#                                                           | containment `run_subset_middle` as a
#                                                           | fixture fact; the library's periodicity
#                                                           | (`kTypeOf_listSeg_replicate_eventually_periodic_bounded`)
#                                                           | and `familyTriples_subset_deleteRun`; a
#                                                           | one-gadget presentation `labN`/`stepN`
#                                                           | whose anchored runs are exactly the
#                                                           | window. BY-PRODUCT `presented_node`:
#                                                           | trace-level `Presented` holds at window
#                                                           | `m`, which is why the negative headline
#                                                           | is FALSE here (finite seam fibre). What
#                                                           | it does NOT say: one fixture, every
#                                                           | pre-seam; does not test the truncation's
#                                                           | necessity -- a Hit-level falsifier needs
#                                                           | an infinite seam fibre; forward-only,
#                                                           | nothing about `⊡(Pp)`; no finiteness
#                                                           | added; no claim that `⊡`-letters
#                                                           | discriminate between devices; nothing
#                                                           | about `PlusValidZTime` or the general
#                                                           | row. Axioms `[propext, Classical.choice,
#                                                           | Quot.sound]` (`stepN` none).
# seam-gluing-ray-product/ladder-cell-refutation            | NEGATIVE VERDICT (requirement (W)'s
#                                                           | run layer, "(W): what landed and what
#                                                           | did not", obligation (ii) item 1,
#                                                           | over a general finite object):
#                                                           | `ladderFrame`'s `fwd`/`bwd`
#                                                           | hypotheses are unsatisfiable on the
#                                                           | full carrier `Q × ℕ × ℕ` for every
#                                                           | object (`no_fwd`, `no_bwd_of_idle` --
#                                                           | the idle state `(q, 1, 0)` has
#                                                           | neither `Rlad`-successor nor
#                                                           | predecessor), so `Adm` is a CARRIER
#                                                           | restriction (here `{x // x.2.1 ∈ Adm
#                                                           | pend x.1}` with `Adm pend q = {c |
#                                                           | pend q = false → c = 0}`, one of
#                                                           | several equally valid shapes) and
#                                                           | `ladderFrame` has no instances; on
#                                                           | the repaired carrier the
#                                                           | stabilization of realized cells in
#                                                           | the counter pair `(c, n)` is FALSE
#                                                           | for every bound on the two-state
#                                                           | object (`cell_ne`: the cells at `(a,
#                                                           | B, B+1)` and `(a, B, B+2)` differ for
#                                                           | every `B`; `exhibited_form_refuted`,
#                                                           | `exists_form_refuted`). MECHANISM:
#                                                           | the current deadline fixes the
#                                                           | region's end at `z + c`, and
#                                                           | `Count`'s idle clause reads `c' = n`,
#                                                           | so the gap `n - c` is observable
#                                                           | through `p U (r ∧ X(p ∧ X r))`, `X χ
#                                                           | := ⊥ U χ`. What it does NOT say:
#                                                           | forward-only witness for a
#                                                           | direction-neutral statement (the
#                                                           | past-looking twin is paper-level, not
#                                                           | machine-checked); no bound of any
#                                                           | kind; no finiteness; nothing about
#                                                           | `HitPresented` or `PlusValidZTime`;
#                                                           | the successor design not chosen
#                                                           | (in-place repair of `ladderFrame` or
#                                                           | a sigma over `Adm` equally valid);
#                                                           | `anchorCells_finite` and
#                                                           | `anchorCells_ncard_le` untouched.
#                                                           | Axioms `[propext, Classical.choice,
#                                                           | Quot.sound]` (`no_bwd_of_idle`
#                                                           | `[propext]`).
# seam-gluing-ray-product/ladder-liveness-forward-only     | FORWARD-ONLY LIVENESS (requirement
#                                                           | (W)'s run layer, "(W): what landed
#                                                           | and what did not", obligation (ii)
#                                                           | item 1, the soundness half, over the
#                                                           | two-state object): the realization
#                                                           | theorem (`LadderCons` with its
#                                                           | `box`/`stab` clause,
#                                                           | `ladderCons_localRun`,
#                                                           | `ladderRealized`) is `[BLOCKED]` on
#                                                           | the open index of which cell a
#                                                           | ladder state has -- every per-cell
#                                                           | soundness statement presupposes it
#                                                           | (`cell_ne`; the `Count` clause makes
#                                                           | the `Q`-projection of a seam fibre a
#                                                           | proper subset of the `Q`-runs; a
#                                                           | per-state labelling collapses `ψ ↔
#                                                           | ⊡ψ`) and so does the acceptance
#                                                           | clause (`stab_mem_tpOf_iff` is per
#                                                           | cell). What IS settled,
#                                                           | machine-checked: an admissible
#                                                           | ladder history can be pending at
#                                                           | every past time (`gPast_isPath`,
#                                                           | `gPast_pending_past`, `gPast_count`
#                                                           | -- backward, `Count true true` grows
#                                                           | the countdown without bound), so
#                                                           | `Cons`'s `ulive` is replaceable by
#                                                           | structural liveness and `slive` is
#                                                           | NOT. What it does NOT say:
#                                                           | forward-only in the sense that the
#                                                           | forward liveness is structural and
#                                                           | the backward one is not -- not a
#                                                           | claim about `⊡(Pp)`; no bound of any
#                                                           | kind; no finiteness; nothing about
#                                                           | `HitPresented` or `PlusValidZTime`;
#                                                           | no library module created; the
#                                                           | successor design -- an index, or the
#                                                           | index-free run-layer half -- not
#                                                           | chosen; `anchorCells_ncard_le`
#                                                           | untouched. Axioms `[propext,
#                                                           | Classical.choice, Quot.sound]`
#                                                           | (`gPast_pending_past`, `gPast_count`
#                                                           | `[propext, Quot.sound]`).
# seam-gluing-ray-product/ladder-cell-index-obstructions    | LADDER CELL INDEX OBSTRUCTIONS
#                                                           | (requirement (W)'s run layer,
#                                                           | "(W): what landed and what did
#                                                           | not", obligation (ii) item 1, the
#                                                           | soundness half, and its cell-index
#                                                           | sub-problem): the
#                                                           | clipped-coordinate index family is
#                                                           | REFUTED at a SECOND coordinate --
#                                                           | the countdown's PARITY, observable
#                                                           | at the region end at distance
#                                                           | exactly `c + 1` because `Count
#                                                           | true true` admits no early
#                                                           | discharge, while `step` is
#                                                           | independent of the counters and
#                                                           | may alternate a tag per pending
#                                                           | step and copy it onto the ending
#                                                           | idle state -- uniformly in the
#                                                           | clip bound (`cell_succ_ne` at
#                                                           | every `c` with `n` FIXED,
#                                                           | `index_collide`,
#                                                           | `ladderIndex_not_factoring`,
#                                                           | `exhibited_form_refuted`,
#                                                           | `exists_form_refuted`; the
#                                                           | mechanism is `truth_phiP`). The
#                                                           | witnessing pair carries EQUAL
#                                                           | next-deadlines and both gaps
#                                                           | saturate the clip, so the gap
#                                                           | coordinate is not what fails --
#                                                           | and the gap-coordinate
#                                                           | refutation's own mechanism
#                                                           | (`cell_ne`) is real and NOT
#                                                           | displaced: it killed a SMALL gap
#                                                           | at LARGE counters, which is why
#                                                           | the gap coordinate is RETAINED. A
#                                                           | gate probing one coordinate
#                                                           | certifies one coordinate: the
#                                                           | earlier one-part gate was sound
#                                                           | and non-vacuous (`gate_separates`
#                                                           | for a clip bound of at least two,
#                                                           | `gate_collides_below_two` below
#                                                           | it, so the clip bound comes from
#                                                           | the FORMULA and never from the
#                                                           | counters) and the candidate it
#                                                           | certified is refuted at a
#                                                           | coordinate it never touched. The
#                                                           | bounded-carrier alternative is
#                                                           | CLOSED (`bounded_ladder_finite`,
#                                                           | `finBranch_eq_ofSlicedStep` by
#                                                           | `rfl`,
#                                                           | `bounded_width_validates_Phi_neg`,
#                                                           | `Phi_neg_not_valid`): its premise
#                                                           | fails at the non-validity the
#                                                           | finite-width limitation exhibits.
#                                                           | Narrow carve-out, stated rather
#                                                           | than suppressed: a bounded carrier
#                                                           | remains available for a target
#                                                           | that DOES have a finite-width
#                                                           | countermodel, per that
#                                                           | limitation's own disclaimer --
#                                                           | what is refuted is the route as
#                                                           | the GENERAL route. What IS landed:
#                                                           | a GATED six-coordinate candidate
#                                                           | (`ladderIndexRes`, with
#                                                           | `gate_gap_separates` and
#                                                           | `gate_parity_separates` at a
#                                                           | SYMBOLIC modulus via
#                                                           | `consec_mod_ne`) and an EXHIBITED
#                                                           | threshold and period
#                                                           | (`iterate_eventually_periodic`,
#                                                           | `reachN_eventually_periodic`),
#                                                           | plus a third gate run one region
#                                                           | out and in the past direction
#                                                           | (`second_region_any_length`,
#                                                           | `second_region_end_tag_achievable`,
#                                                           | `second_region_sets_agree`,
#                                                           | `gap_step_le`,
#                                                           | `gap_region_start_le_one`,
#                                                           | `gap_le_region_age`,
#                                                           | `region_start_beyond_depth`,
#                                                           | `clipped_gap_collides`,
#                                                           | `third_region_any_length`) which
#                                                           | found NO refutation on three
#                                                           | enumerated attempts -- three
#                                                           | attempts on one fixture family,
#                                                           | which is not a proof that the
#                                                           | general factorization holds. What
#                                                           | it does NOT say: NO index is
#                                                           | claimed to factor the cells in any
#                                                           | shape, and the positive
#                                                           | factorization lemma is OPEN and
#                                                           | stated nowhere; no seventh
#                                                           | coordinate; no bound of any kind
#                                                           | and no complexity bound (every
#                                                           | quantity named is a COUNT); no
#                                                           | finiteness added, and
#                                                           | `anchorCells_finite` and
#                                                           | `anchorCells_ncard_le` untouched
#                                                           | -- the SET of cells is still
#                                                           | finite and bounded, only the
#                                                           | computable INDEX is absent;
#                                                           | nothing about `HitPresented`, and
#                                                           | `PlusValidZTime` only in the
#                                                           | non-validity cited; no library
#                                                           | module created and no declaration
#                                                           | added under the main library; the
#                                                           | acceptance clause never dropped
#                                                           | (`stab_mem_tpOf_iff` is that
#                                                           | cell's bit); the successor design
#                                                           | not chosen -- if the gated
#                                                           | candidate falls in turn the
#                                                           | direction on record is a different
#                                                           | presentation of a cell, not a
#                                                           | wider tuple. Axioms `[propext,
#                                                           | Classical.choice, Quot.sound]`
#                                                           | (`gate_gap_separates`,
#                                                           | `gap_le_region_age`,
#                                                           | `region_start_beyond_depth`,
#                                                           | `gate_separates`,
#                                                           | `gate_collides_below_two`
#                                                           | `[propext, Quot.sound]`).
# seam-gluing-ray-product/ladder-residue-index-refutation  | LADDER RESIDUE INDEX REFUTATION (requirement (W)'s run
#                                                           | layer, "(W): what landed and what did not", obligation
#                                                           | (ii) item 1's cell-index sub-problem): the six-coordinate
#                                                           | residue-carrying candidate `ladderIndexRes T P B` --
#                                                           | thresholds and residues on both counters beside the
#                                                           | clipped gap, with its threshold and period EXHIBITED from
#                                                           | the object by `reachN_eventually_periodic` and only the
#                                                           | clip bound from the formula -- is REFUTED at BOTH
#                                                           | object-exhibited parameters, uniformly in the clip bound,
#                                                           | by two mechanisms inside the FIRST region where the
#                                                           | countdown is deterministic. (4) The threshold cannot be
#                                                           | object-derived: over integer time `bot U chi` is `chi` at
#                                                           | the next instant (`truth_nextPow`), so the depth-`(T+1)`
#                                                           | next-chain ending in the idle letter reads whether the
#                                                           | forced first idle state sits at distance exactly `T+1`;
#                                                           | `(q, T, n)` against `(q, T+(P+1), n)` at `n = T+(P+1)+B`
#                                                           | collides for EVERY `(T, P, B)` while their cells differ
#                                                           | (`depth_collision`, `cell_depth_ne`,
#                                                           | `object_only_parameters_refuted`). (5) The exhibited
#                                                           | period is the period of the wrong object: `reachStep`
#                                                           | iterates the FULL step relation, and a formula that
#                                                           | forbids a letter restricts the object to a sub-object with
#                                                           | a different period; on the coprime-cycle object (a 3-cycle
#                                                           | and a 2-cycle sharing `a`) the reach sets are constant
#                                                           | from threshold 4 (`reach5_eventually_constant`, period 1)
#                                                           | while every `d`-free pending walk from `a` to `a` has
#                                                           | length `0 mod 3` (`walk_mod3`), so every modulus coprime
#                                                           | to 3 -- both readings of period 1 -- collides on a pair
#                                                           | that `p U (r AND l_a)` with `top U l_d` in the closure
#                                                           | separates (`period_collision`, `cell5_ne`,
#                                                           | `reach_period_refuted`). The refined parameter-origin rule
#                                                           | is NECESSARY and asserted as nothing more: the threshold
#                                                           | at least the formula's `untl`-nesting depth, the modulus
#                                                           | a multiple of the period of every letter-definable
#                                                           | sub-object. FIXTURE-LEVEL sufficiency on the two-state
#                                                           | object (`qp_cell_eq_of_depth_parity`: box/stab-free
#                                                           | formulas, countdowns at or above the formula-derived `thr`
#                                                           | and of equal parity, any next deadlines) rests on
#                                                           | `qp_forced_path` -- one object path through every pending
#                                                           | state -- which the general object lacks, and is NOT the
#                                                           | factorization lemma. What it withholds: no factorization
#                                                           | lemma in any shape; no seventh coordinate; the three
#                                                           | earlier negatives untouched; no finiteness added; nothing
#                                                           | about `HitPresented`; no library declaration; the
#                                                           | acceptance clause never dropped; the successor design not
#                                                           | chosen. Axioms `[propext, Classical.choice, Quot.sound]`
#                                                           | on the cell theorems, `[propext, Quot.sound]` on
#                                                           | `truth_nextPow`, `depth_collision`, `walk_mod3`,
#                                                           | `pending_run_gen`, `idle_at_gen`.
# seam-gluing-ray-product/ladder-joint-index-refutation     | LADDER JOINT INDEX REFUTATION (requirement (W)'s run
#                                                           | layer, "(W): what landed and what did not", obligation
#                                                           | (ii) item 1's cell-index sub-problem): the SAME
#                                                           | six-coordinate index body, at parameters derived from the
#                                                           | object AND the formula JOINTLY in the sense the
#                                                           | parameter-origin rule states -- `B` from the formula's
#                                                           | `X`- and `snce`-nesting depth, `T` from its `untl`-nesting
#                                                           | depth, `P+1` a multiple of the period of every
#                                                           | LETTER-DEFINABLE sub-object -- is REFUTED, after the
#                                                           | five-part gate is run in full. Gates 1-3 pass
#                                                           | (`gate1_gap_separates`, `gate2_residue_separates`,
#                                                           | `gates_one_two_at_rule_params`,
#                                                           | `second_region_sets_agree`, `third_region_any_length`,
#                                                           | `region_start_beyond_depth`). Gate 4 is DISARMED by a
#                                                           | diagonal that cannot close: the depth-`(T+1)` next-chain
#                                                           | costs `untl`-depth exactly `T+1`
#                                                           | (`untlDepth_phiDepth`), so it lies in the closure of no
#                                                           | formula of `untl`-depth at most `T`
#                                                           | (`gate4_witness_not_in_closure`, `gate4_disarmed`,
#                                                           | `gate4_diagonal_escapes`). Gate 5 is DISARMED at a
#                                                           | rule-admissible modulus: `l_d` names `d` and nothing else
#                                                           | (`lab5_d_only`), so the `d`-free sub-object is
#                                                           | letter-definable with walk lengths the multiples of three
#                                                           | (`dfree_walk_mod3`), the rule forces `3 | P+1`, and BOTH
#                                                           | cells of mechanism (5)'s pair then contain a type lacking
#                                                           | its formula (`gate5_disarmed`), with
#                                                           | `reach_period_refuted` ported and re-run. GATE 6 REFUTES:
#                                                           | on the same object with `d` given the letter of `b`, no
#                                                           | atom distinguishes `d` from `b` (`lab6_d_eq_b`,
#                                                           | `lab6_keep_d_iff_b`), the 3-cycle is cut out by no set of
#                                                           | atoms (`cycle_not_letter_definable`), every letter
#                                                           | restriction keeping it keeps the 2-cycle beside it
#                                                           | (`letter_definable_keeps_two_cycle`) and the full graph's
#                                                           | exhibited period is 1 (`reach5_eventually_constant`), so
#                                                           | `P+1 = 2` is rule-admissible; yet the letter-FREE pattern
#                                                           | `(p AND l_a) AND X X (p AND l_a)`, forbidden at every
#                                                           | position, carves the 3-cycle out (`pred_of_d`,
#                                                           | `succ_of_d`, `chi_forces_dfree`, `chi_ref`) and separates
#                                                           | a pair the index identifies for every `(T, P, B)`
#                                                           | (`period_collision`, `exists_cell_not_phi6`,
#                                                           | `phi6_mem_of_mem_cell`, `cell6_ne`,
#                                                           | `joint_parameters_refuted`,
#                                                           | `rule_derived_parameters_refuted` at `T = thrJ phi6`,
#                                                           | `B = clipJ phi6`, `P+1 = 2`). WHAT SURVIVES: a strictly
#                                                           | stronger NECESSARY condition -- the modulus must be a
#                                                           | multiple of the period of every sub-object the formula's
#                                                           | CLOSURE can carve out, i.e. of the object-closure
#                                                           | product -- which turns the first of the four standing
#                                                           | proof obligations into a necessary condition. What it
#                                                           | withholds: no positive factorization lemma in any shape;
#                                                           | no weakened `ladderRealized`/`LadderCons` substitute and
#                                                           | the `box`/`stab` clause never dropped; no seventh
#                                                           | coordinate; no successor chosen; no finiteness added;
#                                                           | nothing about `HitPresented`; no library declaration.
#                                                           | Axioms `[propext]` on `lab6_d_eq_b`,
#                                                           | `[propext, Quot.sound]` on the arithmetic and depth
#                                                           | theorems, `[propext, Classical.choice, Quot.sound]` on
#                                                           | the cell theorems.
# seam-gluing-ray-product/closure-indexed-periodicity       | CLOSURE-INDEXED EVENTUAL PERIODICITY (the first of the
#                                                           | four standing proof obligations, promoted by the
#                                                           | sixteenth probe's gate 6 from a proof step into a
#                                                           | NECESSARY condition on the index's own parameter): the
#                                                           | cheap half of that obligation, generically in the object
#                                                           | and the formula. Seven theorems:
#                                                           | `iterate_eventually_periodic`,
#                                                           | `prodReachN_eventually_periodic`,
#                                                           | `prodPreN_eventually_periodic`, `prodReach_fst_subset`,
#                                                           | `strict_object_period_one`,
#                                                           | `strict_product_period_three`,
#                                                           | `strict_product_not_period_one`. The decision it holds in
#                                                           | place: a modulus must cover the period of the
#                                                           | OBJECT-CLOSURE PRODUCT, not the object's graph: the two
#                                                           | periods are independent (`strict_object_period_one`,
#                                                           | `strict_product_period_three`,
#                                                           | `strict_product_not_period_one`);
#                                                           | the closure-indexed carrier is finite and both countdown
#                                                           | operators are eventually periodic,
#                                                           | `prodPreN_eventually_periodic`. What it withholds: no
#                                                           | coherence relation is constructed (the product step
#                                                           | relation is a PARAMETER); no modulus is computed or
#                                                           | claimed computable; no adequacy of any product
#                                                           | construction with respect to the truth definition -- the
#                                                           | expensive half of the obligation stays OPEN; no cell
#                                                           | index, no factorization lemma and no part of one; no
#                                                           | library declaration. Axioms `[propext, Classical.choice,
#                                                           | Quot.sound]` on all seven.
# seam-gluing-ray-product/closure-profile-gate-rerun        | CLOSURE-INDEXED COUNTDOWN PROFILE -- GATE TABLE RERUN
#                                                           | (the successor presentation to the four refuted index
#                                                           | shapes: a SET-valued per-state datum over a quotient, not
#                                                           | a wider tuple). The datum is `Prof6 k`, the set of
#                                                           | product states from which a `coh6`-chain of length `k`
#                                                           | reaches the fibre `Ea` over the pending `a` state,
#                                                           | quotiented by the kernel of the profile map; it carries
#                                                           | NO parameter -- no threshold, no modulus, no clip bound.
#                                                           | The decision it holds in place: the datum SURVIVES THIS
#                                                           | ROUND'S GATES on the coprime-cycle fixture, and three of
#                                                           | the nine it does not address at all. Gate 6 is
#                                                           | INTERNALISED -- the letter-free pattern is a subformula,
#                                                           | hence in the closure, hence tracked by the product
#                                                           | (`coh6_liesOver`, `coh6_chi_propagates`, `coh6_no_a_d_a`,
#                                                           | `coh6_chain_a_to_a_mod3`, `prof6_fibre_a_of_mem`,
#                                                           | `prof6_fibre_a_witness`), so the profile separates gate
#                                                           | 6's own pair for EVERY modulus coprime to three with
#                                                           | nothing to choose (`prof6_separates_gate6_pair`). Gate 5
#                                                           | is DISARMED and exhibited: the object's full-graph period
#                                                           | is one from threshold four (`reach5_eventually_constant`)
#                                                           | while the profile's is not one (`prof6_period_not_one`).
#                                                           | Gate 7 is PASSED in its definability form and witnessed
#                                                           | non-vacuous (`coh6_cycle_witness`, landed before every
#                                                           | negative lemma; no history, no world, no cell in any
#                                                           | declaration). Gate 8 is SIDESTEPPED, not passed: the
#                                                           | closure of the constraint has no `box`, `snce` or `stab`
#                                                           | member (`chi_closure_untl_only`), so a `stab` gate cannot
#                                                           | be met on this fixture, only avoided. Gate 4 is disarmed
#                                                           | by construction and by no theorem here -- there is no
#                                                           | threshold parameter to attack, and the depth-(T+1)
#                                                           | witness enlarges the closure rather than escaping a
#                                                           | bound. Gate 3 is CARRIED from the sixteenth probe and
#                                                           | re-run by nothing here. GATES 1 AND 2 ARE NOT ADDRESSED:
#                                                           | gate 1 because this datum reads the countdown only and
#                                                           | the next-deadline-side datum is obligation (c), gate 2
#                                                           | because it reduces to adequacy. Gate 9 is OPEN, raised in
#                                                           | the nineteenth probe. What it withholds: no sufficiency
#                                                           | claim, no factorization lemma, no cell index and no part
#                                                           | of one; no `ladderRealized`/`LadderCons` substitute and
#                                                           | the `box`/`stab` clause never dropped; ADEQUACY IS OPEN
#                                                           | -- `coh6` is LOCAL coherence and over-approximates
#                                                           | realizability, having no fulfilment condition;
#                                                           | obligations (b), (c), (d) not started; no seventh
#                                                           | coordinate and no re-presentation of the profile's
#                                                           | threshold or period as index coordinates; one fixture is
#                                                           | one fixture. Axioms `[propext, Classical.choice,
#                                                           | Quot.sound]` on all eleven.
# seam-gluing-ray-product/nside-modulus-gate                | n-SIDE MODULUS GATE (gate 9, raised against the REFUTED
#                                                           | tuple's n-side coordinates as a candidate shape for the
#                                                           | datum obligation (c) owes). Two Goals, `nside_pair_ne`
#                                                           | and `nside_collides`, plus two gate theorems ported with
#                                                           | their hypotheses unchanged from the sixteenth probe,
#                                                           | `gate1_gap_separates` (`2 <= B`) and
#                                                           | `gate2_residue_separates` (`1 <= P`). The decision it
#                                                           | holds in place: passing gates 1 and 2 does NOT make a
#                                                           | shape adequate as the next-deadline datum. The ported
#                                                           | coordinates do separate those two gates' pairs, re-proved
#                                                           | here rather than inherited by citation; but `(q, c, n)`
#                                                           | and `(q, c, n + (P+1))` collide in the WHOLE
#                                                           | six-coordinate index at every `(T, P, B)` and every
#                                                           | countdown (`nside_collides`), on a pair of genuinely
#                                                           | distinct states (`nside_pair_ne`, this probe's
#                                                           | non-vacuity obligation, landed first). What it withholds:
#                                                           | gate 9's REFUTING half -- a formula on the coprime-cycle
#                                                           | object giving the collided pair different cells -- is NOT
#                                                           | ATTEMPTED, so gate 9 is OPEN, neither passed nor refuted;
#                                                           | no cell is computed, mentioned or claimed; nothing is
#                                                           | coupled to `Drift` and this is NOT obligation (c), only a
#                                                           | gate on a candidate SHAPE for its datum; this is not part
#                                                           | of the eighteenth probe's countdown profile and adds no
#                                                           | coordinate to it, nor identifies the two notations; gate
#                                                           | 1 remains NOT ADDRESSED by the countdown profile and
#                                                           | nothing here changes that; the shape gated here belongs
#                                                           | to a refuted candidate and is gated as a candidate for a
#                                                           | datum, never revived as an index. Axioms `[propext,
#                                                           | Quot.sound]` on `gate1_gap_separates`, `nside_pair_ne`
#                                                           | and `nside_collides`, `[propext, Classical.choice,
#                                                           | Quot.sound]` on `gate2_residue_separates`.
# seam-gluing-ray-product/realizable-type-adequacy-gap     | THE ADEQUACY GAP, EXHIBITED (not merely scoped). The
#                                                           | eighteenth probe records that its coherence relation
#                                                           | `coh6` is LOCAL coherence and over-approximates
#                                                           | realizability; that record reads a DEFINITION (no
#                                                           | fulfilment clause is imposed). This probe exhibits the
#                                                           | over-approximation on the same fixture: `ev_cycle_witness`
#                                                           | is a `coh6`-coherent 3-cycle of closure types carrying
#                                                           | `ev = T U psi2` at every position (`ev_mem_all`) and
#                                                           | `psi2` at none (`psi2_not_mem_all`), so the forward run
#                                                           | `evRay` is a `coh6`-chain (`evRay_coh`) with no fulfilling
#                                                           | time anywhere (`evRay_unfulfilled`) -- the exact negation
#                                                           | of `PlusTruthAt`'s `untl` clause and of `Fulfilling` /
#                                                           | `PlusThreadFulfilling`. `prof6_ev_witness` puts the cycle
#                                                           | in the countdown profile at every multiple of three, so
#                                                           | the profile's own membership witnesses include chains of
#                                                           | this kind. The decision it holds in place: adequacy is a
#                                                           | real gap on the fixture, not an artefact of a conservative
#                                                           | definition, so a plan may not treat it as disappearing
#                                                           | once the relation is "written properly". What it
#                                                           | withholds: `(a5, evTa)` is NOT claimed non-realizable
#                                                           | (`psi2` is satisfiable on this object through the 2-cycle,
#                                                           | which a `chi`-free type may enter); no adequate relation
#                                                           | is constructed or sketched; no gate verdict of the
#                                                           | eighteenth probe is changed and no gate is added; no
#                                                           | clause of `PlusTruthAt` is unfolded and no cell, history,
#                                                           | world or model appears; nothing is a factorization lemma,
#                                                           | a cell index or any part of one. `chi_not_mem_all` is the
#                                                           | compiled reason the exhibit does not collide with
#                                                           | `coh6_no_a_d_a`, whose hypothesis is a `chi`-CARRYING
#                                                           | type. Axioms `[propext, Classical.choice, Quot.sound]` on
#                                                           | all nine theorems.
# seam-gluing-ray-product/realizable-type-certificate       | THE CERTIFICATE PRESENTATION SEPARATES
#                                                           | REALIZABLE-TYPE CANDIDATES FROM MERELY LOCALLY
#                                                           | COHERENT ONES, and ADEQUACY IS STILL NOT DISCHARGED.
#                                                           | The twentieth probe exhibited the adequacy gap; this
#                                                           | one builds the presentation that sees it.
#                                                           | `euStep`/`euIter`/`euLfp` is the EXISTENTIAL dual of
#                                                           | `AUFix`, with its fixpoint API ported one quantifier
#                                                           | at a time (`eu_step_mono`, `eu_lfp_fixed`,
#                                                           | `eu_mem_lfp_iff`, `eu_lfp_least`) and read as a
#                                                           | guarded-path statement by
#                                                           | `eu_mem_lfp_iff_exists_path` -- strictly later, `0 <
#                                                           | n`, so strict until and not weak until.
#                                                           | `au_lfp_ne_eu_lfp_on_exit_graph` compiles the
#                                                           | strength choice: on a four-state cycle with an exit
#                                                           | the UNIVERSAL fixpoint is `{3}` and the EXISTENTIAL
#                                                           | one is `Finset.univ`, so transplanting `ULive` onto
#                                                           | the object-closure product would reject a
#                                                           | presentation that is realizable. `certAdm` conjoins
#                                                           | six decidable fields on a guessed candidate set `R`
#                                                           | -- local coherence, bi-infinity inside `R`,
#                                                           | existential forward discharge through `euLfp R
#                                                           | (succR R)` (`cert_fwd_iff_eu_lfp` puts the "inside
#                                                           | `R`" in a signature), its backward mirror, and the
#                                                           | `stab` and `box` biconditionals, which are PRESENT
#                                                           | and not dropped. `cert_accepts_Rchi` lands a
#                                                           | non-empty instance first; then `coh_accepts_Rev` and
#                                                           | `cert_rejects_Rev`, through the structural
#                                                           | `rev_eu_lfp_empty` and
#                                                           | `eu_lfp_eq_empty_of_no_event`, exhibit a set LOCAL
#                                                           | COHERENCE ACCEPTS AND THE CERTIFICATE REJECTS.
#                                                           | `untl_propagates_along_coh` is the composition
#                                                           | theorem the restriction to `R` could have broken,
#                                                           | and `cohR_le_coh` is the restriction read as a
#                                                           | restriction. `profR_period_three`,
#                                                           | `profR_fibre_a_witness` and
#                                                           | `profR_separates_gate6_pair` show the predecessor
#                                                           | round's gate-6 separation survives the refinement,
#                                                           | for every modulus coprime to three with nothing to
#                                                           | choose. The decision it holds in place: the
#                                                           | fulfilment condition for a CELL datum is EXISTENTIAL
#                                                           | and bounded inside the candidate set, so Route B
#                                                           | (check a guessed set) is open without the missing
#                                                           | algorithm Route A needs, and the universal condition
#                                                           | already landed in the tree is not a conservative
#                                                           | substitute for it. What it withholds: the six
#                                                           | conditions are NOT proved SUFFICIENT for
#                                                           | realizability -- adequacy is not discharged and the
#                                                           | dovetailing argument stays uncompiled in the
#                                                           | research report; this is NOT Route A and nothing
#                                                           | here decides generalized-Buchi nonemptiness, since
#                                                           | no theorem quantifies over the SET of eventualities
#                                                           | a state carries; `(a5, evTa)` is NOT claimed
#                                                           | non-realizable (`psi2` is deliverable through the
#                                                           | 2-cycle exit `a -> d -> a`, which `Rev` excludes by
#                                                           | construction) and the countdown profile is NOT
#                                                           | refuted; `chi_closure_box_snce_stab_free` compiles
#                                                           | why gate 8 is SIDESTEPPED and not passed -- the
#                                                           | closure has no `box`, `snce` or `stab` member, so
#                                                           | conditions (4), (5) and (6) are checked and vacuous,
#                                                           | which is the standing `BoxStabFree` scope line of
#                                                           | the anchor/run layer; gate 3 is CARRIED, gates 1 and
#                                                           | 2 are NOT ADDRESSED with the compiled n-side
#                                                           | qualification, gates 4 and 5 are carried from the
#                                                           | eighteenth probe, gate 9 is OPEN; obligations (b),
#                                                           | (c) and (d) are untouched; eventual periodicity of
#                                                           | the UNRESTRICTED countdown is settled by the
#                                                           | seventeenth probe and is neither re-derived nor
#                                                           | claimed here; no `ladderRealized` and no
#                                                           | `LadderCons` in any form, hence none without the
#                                                           | `box`/`stab` clause, and nothing here is a
#                                                           | factorization lemma, a cell index or any part of
#                                                           | one; no seventh tuple coordinate, and no modulus,
#                                                           | threshold or index is computed or claimed
#                                                           | computable. Axioms `[propext, Classical.choice,
#                                                           | Quot.sound]` on all eighteen theorems.
# seam-gluing-ray-product/backward-determinism-forcing-formula | POSITIVE (forcing formula exists): the
#                                                           | closed L⁺ formula `(q S ⊥) → ⊡(q S ⊥)` --
#                                                           | "yesterday `q` is settled" -- is valid on a
#                                                           | regular ℤ-frame IFF the frame is BACKWARD
#                                                           | DETERMINISTIC (`valid_iff_stepBwdDet`; at the
#                                                           | history level with no regularity hypothesis,
#                                                           | `valid_iff_histBwdDet`, choice-free). Thomason
#                                                           | 1984 §4 Def. 6(2) is rendered as `HistBwdDet`
#                                                           | (one-step, synchronous; `histBwdDet_iterate`
#                                                           | recovers the full clause), CVV Def. 2.5 `Wdc`
#                                                           | as its asynchronous weakening, and
#                                                           | `StepBwdDet` as "unique predecessors"; the
#                                                           | mechanism is `yest_iff` (`φ S ⊥` is `φ` at
#                                                           | `t - 1` on ℤ-time) with the singleton
#                                                           | valuation `|q| = {τ(t - 1)}`. REFUTED on the
#                                                           | backward-branching mirror fixture
#                                                           | (`Probe733Mirror.bdForce_not_valid`,
#                                                           | `not_stepBwdDet`: `histOf 1 (-1)` and `histOf
#                                                           | 0 (-2)` share `aft 1` at `0` and diverge at
#                                                           | `-1`); VALID on the backward-deterministic,
#                                                           | forward-BRANCHING asymmetric fixture
#                                                           | (`Probe719Backward.bdForce_valid`,
#                                                           | `forward_branching`), so it forces backward
#                                                           | and NOT forward determinism. ℤ-specific: on
#                                                           | dense time `q S ⊥` is unsatisfiable and the
#                                                           | formula forces nothing
#                                                           | (`deterministic_not_plusDefinable` is not
#                                                           | contradicted). What it withholds: a
#                                                           | frame-definability theorem, NOT a reduction --
#                                                           | the know-time-do-not-forget reduction is NOT
#                                                           | attempted, no undecidability or complexity
#                                                           | claim is made (Thomason's own T×W tradition is
#                                                           | axiomatizable and Kamp-valid decidable; every
#                                                           | corpus negative needs ≥ 2 informed agents, L⁺
#                                                           | has one); the transfer question is a Stage 0
#                                                           | ruling, pending; the mirror `(q U ⊥) → ⊡(q U
#                                                           | ⊥)` is an uncompiled side remark; `stab`'s
#                                                           | clause and `not_finite_width_fmp` untouched.
#                                                           | Axioms: `[propext, Quot.sound]` on
#                                                           | `valid_iff_histBwdDet`; `[propext,
#                                                           | Classical.choice, Quot.sound]` on
#                                                           | `valid_iff_stepBwdDet`, `bdForce_not_valid`,
#                                                           | `not_stepBwdDet`, `bdForce_valid`;
#                                                           | `forward_branching` axiom-free
# seam-gluing-ray-product/certificate-sufficiency-dovetailing | SUFFICIENCY, SPLIT (the research round's
#                                                           | section-6 claim, resolved): the dovetailing
#                                                           | argument IS a theorem (`exists_dovetail_chain`,
#                                                           | over an arbitrary finite graph;
#                                                           | `forward_chain_of_certAdm` is its forward
#                                                           | instance for the compiled relation, LABELLED
#                                                           | forward-only); condition (3)'s `|R|` bound IS
#                                                           | derived (`eu_mem_lfp_path_le_card`, consumed by
#                                                           | nothing); and the claim that the compiled
#                                                           | certificate's conditions imply realizability IS
#                                                           | REFUTED (`sufficiency_refuted`): `cert_accepts_R3`
#                                                           | accepts the three-member set over
#                                                           | `(⊤ S a1) ∧ (⊤ S a2)` whose member `x0` lies on NO
#                                                           | backward-fulfilling chain
#                                                           | (`no_bwdFulfilling_through_x0`), because
#                                                           | `linkPred` constrains no backward arm and so the
#                                                           | two discharge paths condition (4) supplies cannot
#                                                           | be taken together. The decision it holds in
#                                                           | place: Route B's relation must carry the
#                                                           | strict-since link `linkPredB` (`cohBi`), under
#                                                           | which the certificate IS sufficient
#                                                           | (`realizes_of_certAdm_cohBi`, label-level,
#                                                           | two-sided) at no cost on a `snce`-free closure
#                                                           | (`cohBi_eq_coh_of_snce_free`); the strengthened
#                                                           | certificate accepts a two-arm set (`cert_accepts_R4`,
#                                                           | over `(⊤ U b) ∧ (⊤ S a1)`, every member carrying both
#                                                           | obligations) and the two-sided theorem has a
#                                                           | compiled, non-vacuous instance on it
#                                                           | (`realizes_y0_R4`); a backward
#                                                           | propagation theorem is NOT to be claimed for
#                                                           | `coh`, and `ULive`/`SLive` are NOT the repair
#                                                           | (both arms stay existential). What it withholds:
#                                                           | realizability is label-level only (no
#                                                           | `PlusTruthAt`, `tpOf`, `cellAt`, history, world,
#                                                           | model or cell); no Route A; no
#                                                           | `ladderRealized`/`LadderCons`; no gate verdict
#                                                           | changed, gate 8 still SIDESTEPPED. Axioms
#                                                           | `[propext, Classical.choice, Quot.sound]` on all
#                                                           | seventeen printed theorems.
# seam-gluing-ray-product/no-pending-forever-ray | REGION-INTERIOR (the certified chains of
#                                                           | record): no forward `Rlad` ray is pending
#                                                           | forever -- `Count true true` forces `c' + 1 = c`
#                                                           | along every pending step (`count_pending_step`),
#                                                           | so from countdown `c₀` an idle state is reached
#                                                           | within `c₀ + 1` steps
#                                                           | (`exists_idle_of_rlad_ray`) and an object walk
#                                                           | pending at every forward position is the object
#                                                           | projection of NO `Rlad` history
#                                                           | (`no_rlad_ray_of_pending_forever`). The decision
#                                                           | it holds in place: `coh`/`cohBi` of the
#                                                           | countdown-profile and certificate probes require
#                                                           | `pend` at BOTH endpoints, so every certified
#                                                           | `Realizes`-chain is an all-pending bi-infinite
#                                                           | walk and `realizes_of_certAdm_cohBi` is
#                                                           | label-level sufficiency for the INTERIOR of one
#                                                           | region -- it transfers to the region segments of
#                                                           | a ladder history and never to a ladder history
#                                                           | itself; the ladder datum must compose regions
#                                                           | through idle runs under `Count`/`Drift` (the two
#                                                           | `pend` conjuncts replaced by `Count`/`Drift`
#                                                           | clauses on the counter classes), which is the
#                                                           | COUNTER-LIFT LEMMA, named as the open problem
#                                                           | and proved nowhere. The presentation decision it
#                                                           | accompanies: the cell presentation is a
#                                                           | SET-VALUED per-state datum `D`, the maximum
#                                                           | `certAdm`-certified subset of the carrier `Q ×
#                                                           | ClType φ × K`, with the realization theorem the
#                                                           | fibre equation and the factorization lemma for
#                                                           | `K` its corollary; `K` is a carrier coordinate
#                                                           | whose parameters are outputs of that lemma, and
#                                                           | NO tuple index is stated at any parameters. What
#                                                           | it withholds: no `cellAt`, `HitPresented` or
#                                                           | `PlusValidZTime` in any declaration; no
#                                                           | `LadderCons`/`ladderRealized` in any form;
#                                                           | nothing about the backward direction
#                                                           | (`gPast_isPath` stands); no bound of any kind,
#                                                           | every quantity a count (`c₀ + 1` is a count of
#                                                           | steps); no finiteness added
#                                                           | (`anchorCells_finite`, `anchorCells_ncard_le`
#                                                           | untouched); no gate verdict changed, gate 8
#                                                           | still SIDESTEPPED. Axioms `[propext]` on
#                                                           | `count_pending_step`, `[propext, Quot.sound]` on
#                                                           | `exists_idle_of_rlad_ray` and
#                                                           | `no_rlad_ray_of_pending_forever`.
# seam-gluing-ray-product/counter-lift-gates | THE COUNTER-LIFT GATE TABLE, COMPLETE (the
#                                                           | arithmetic layer, every gate row compiled at
#                                                           | the model layer, and the pin lemma's lift
#                                                           | half): the forward window (`forward_window`:
#                                                           | `|L - n| <= c + j`), the backward constraint
#                                                           | (`backward_constraint`: `n` in
#                                                           | `[c - 1, c + 2s + 1]`, pin `c + s`), region
#                                                           | doubling (`region_doubling`: `L' <= 2L+j+1`,
#                                                           | attained at `j = 1` by `doubling_attained`,
#                                                           | iterated by `iter_doubling` to
#                                                           | `a k + J + 1 <= 2^k (a 0 + J + 1)`), the pins
#                                                           | (`pin_region_start`, `pin_region_end`,
#                                                           | `count_pending_step`), the Lipschitz bound
#                                                           | (`drift_step`, `drift_ray`), the
#                                                           | STATEMENT-SHAPE refutation (no POSITIONWISE
#                                                           | lift exists for ANY finite counter quotient
#                                                           | `K`, any `kappa`, any sound local relation
#                                                           | `R` -- `no_positionwise_lift`: a
#                                                           | Lipschitz-tight history, a class repeat along
#                                                           | its idle climb, and the cut chain whose two
#                                                           | pins are too close for `Drift`), and the pin
#                                                           | lemma's lift half
#                                                           | (`drift_extension_of_pins`: the McShane
#                                                           | extension through a compatible pin family;
#                                                           | `exists_rlad_hist_of_walk`: the lift of an
#                                                           | object walk with its forced countdown). Gate
#                                                           | verdicts, all compiled: SEPARATION at gate 1
#                                                           | (`gate1_cell_ne`), gate 2 (`gate2_cell_ne`),
#                                                           | gate 9-sep (`gate9_sep_cell_ne`) and the
#                                                           | short-idle gate (`short_idle_cell_ne`, with
#                                                           | `short_idle_shape_collides` and
#                                                           | `short_idle_threshold_refuted`); COLLISION at
#                                                           | both DECISION GATES -- gate 9-col
#                                                           | (`gate9_col_cell_eq`) and the gap-shift gate
#                                                           | (`gap_shift_cell_eq`, with the absorber
#                                                           | exhibited as `absorber4`), each an EQUALITY
#                                                           | of `cellAt` values, non-vacuity witnessed
#                                                           | before the equality on both sides. THE
#                                                           | DECISION IT HOLDS IN PLACE: the counter-lift
#                                                           | lemma's completeness half must be stated in
#                                                           | PUMPING form (loops inserted or deleted in
#                                                           | saturated zones, the state at position `0`
#                                                           | kept), never position by position; and with
#                                                           | both decision gates COLLIDING, the ladder
#                                                           | route is NOT closed -- the lemma's two halves
#                                                           | are LICENSED in that pumping form, with
#                                                           | `K`'s parameters `(T, P, B)` as OUTPUTS of
#                                                           | the first repeat of the realizable-type
#                                                           | iteration, never exhibited from the object or
#                                                           | the letters. Licensed is not proved: (S),
#                                                           | (C') and (K1)-(K4) remain the successor
#                                                           | record's obligations. What it withholds: no
#                                                           | `HitPresented` or `PlusValidZTime` in any
#                                                           | declaration; no `LadderCons`/
#                                                           | `ladderRealized`/factorization lemma under
#                                                           | any name; no tuple index at any parameters
#                                                           | (`K` is a carrier coordinate); no seventh
#                                                           | coordinate (neither decision gate exhibited
#                                                           | one); no bound, every quantity a count
#                                                           | (including the gap-shift gate's `T0 = 1` and
#                                                           | `g0 = 1`); no finiteness added; the
#                                                           | `box`/`stab` clause kept; gate 8 SIDESTEPPED
#                                                           | (no `stab` member in any closure), gate 3
#                                                           | CARRIED; the refutation is of a statement
#                                                           | SHAPE, not of the datum. Axioms
#                                                           | `[propext, Quot.sound]` on `iter_doubling`,
#                                                           | `doubling_attained`,
#                                                           | `short_idle_shape_collides`;
#                                                           | `[propext, Classical.choice, Quot.sound]` on
#                                                           | every other headline theorem. No `sorryAx`,
#                                                           | no custom axiom, no `native_decide`.
# seam-gluing-ray-product/ladder-unconstrained-parameter-refutation | THE UNCONSTRAINED-PARAMETER
#                                                           | REFUTATION: the ladder realization
#                                                           | record's factorization and
#                                                           | fibre-equation statements, AS
#                                                           | RECORDED, are FALSE -- not open --
#                                                           | because they quantify over the
#                                                           | counter-quotient parameters
#                                                           | `Tc`/`Tn`/`P`/`B` with NO constraint,
#                                                           | and `CK 0 0 0 0` is a SUBSINGLETON
#                                                           | (`ck_zero_subsingleton`, by `decide`;
#                                                           | inhabited, `ckZero`). From one
#                                                           | separating pair of cells at the same
#                                                           | object state the factorization shape
#                                                           | (`const_shape_refuted_of_separating_pair`)
#                                                           | and the fibre-equation shape
#                                                           | (`realized_shape_refuted_of_separating_pair`)
#                                                           | both fall, for EVERY `kappa` and every
#                                                           | candidate `Dmax`, with no property of
#                                                           | `Dmax` used. The pair is COMPILED, not
#                                                           | assumed: `cell_succ_ne` on the
#                                                           | four-state tag object, ported verbatim
#                                                           | from `ladder-cell-index-obstructions`,
#                                                           | giving the unconditional
#                                                           | `const_shape_refuted` and
#                                                           | `realized_shape_refuted`. Non-vacuity
#                                                           | on both sides:
#                                                           | `separating_pair_nonvacuous`. The
#                                                           | PRESENTATION is untouched -- the
#                                                           | set-valued datum, the fibre equation
#                                                           | over the maximum certified subset and
#                                                           | the factorization lemma as a corollary
#                                                           | all stand; what is refuted is the
#                                                           | statements' FREE quantification over
#                                                           | the parameters, and the repair (a
#                                                           | `ParamsOk` hypothesis carrying
#                                                           | (K1)-(K4)) is a change to a recorded
#                                                           | Challenge statement and is NOT made
#                                                           | here. A gate probing one coordinate
#                                                           | certifies one coordinate: this probe
#                                                           | certifies the parameter quantification
#                                                           | and nothing else. Axioms
#                                                           | `[propext, Classical.choice, Quot.sound]`
#                                                           | on all six headline theorems. No
#                                                           | `sorryAx`, no custom axiom, no
#                                                           | `native_decide`.
# seam-gluing-ray-product/ladder-splice-type-refutation     | THE SPLICE TYPE REFUTATION: the
#                                                           | pumping surgery of the ladder
#                                                           | replacement layer does NOT preserve
#                                                           | the realized closure type, at ANY
#                                                           | distance from the splice point. Half
#                                                           | (ii) of the model-level
#                                                           | truth-transport layer -- repeating an
#                                                           | object cycle of length `l ∣ P + 1`
#                                                           | inside a pending region whose splice
#                                                           | point lies at least `T_c` from `z`
#                                                           | preserves the stab-free part of
#                                                           | `tpOf` at `z` -- is FALSE as stated
#                                                           | (`splice_type_invariance_refuted`,
#                                                           | against the schema
#                                                           | `SpliceTypeInvariance` carrying every
#                                                           | recorded hypothesis). Mechanism: one
#                                                           | splice DUPLICATES the pumped block,
#                                                           | so it ADDS one occurrence of every
#                                                           | object state of that block to the
#                                                           | walk's future, and the nested
#                                                           | eventuality `⊤ U (p ∧ ⊤ U p)` COUNTS
#                                                           | occurrences at unbounded distance --
#                                                           | so the preceding record's
#                                                           | distance-budget-per-nesting-depth
#                                                           | reading was wrong. Three pending/idle
#                                                           | states, walk hitting the `p`-state
#                                                           | EXACTLY ONCE, no region start at all;
#                                                           | seriality DISCHARGED (`fwdS`,
#                                                           | `bwdS`), the path lifted by
#                                                           | `exists_ladderPath_of_walk`, the
#                                                           | spliced path by the landed
#                                                           | `exists_spliced_ladderPath_of_pend_past`,
#                                                           | the divisibility MET through `(K1)`
#                                                           | on a compiled object `2`-cycle
#                                                           | (`two_mem_objCycleLensS`,
#                                                           | `two_dvd_PS_succ`) and `ParamsOk`
#                                                           | discharged at the periodicity
#                                                           | fixpoint's own outputs
#                                                           | (`paramsOkS`). The refutation
#                                                           | SURVIVES THE ITERATED surgery the
#                                                           | residue coordinate needs
#                                                           | (`twoHits_iterate`,
#                                                           | `spliced_rehypotheses`). Non-vacuity
#                                                           | on both sides: both realized types
#                                                           | contain `top`, carried as conjuncts
#                                                           | of `exists_separating_splice`. Half
#                                                           | (i) is UNTOUCHED and the PRESENTATION
#                                                           | is untouched; the probe settles
#                                                           | NOTHING about
#                                                           | `cellAt_const_of_kappa_eq` itself (a
#                                                           | cell quantifies over ALL histories
#                                                           | through a state, this probe compares
#                                                           | two), and nothing about a splice at a
#                                                           | TYPE-RESPECTING block or a type-AWARE
#                                                           | lengthening of the region -- different
#                                                           | constructions, stated nowhere in the
#                                                           | tree. WHY the block is the wrong unit
#                                                           | is itself compiled
#                                                           | (`splice_block_not_type_respecting`):
#                                                           | the pumped block's endpoints carry the
#                                                           | SAME object state and DIFFERENT
#                                                           | realized types, so the object cycle is
#                                                           | not a unit of type-invariance and the
#                                                           | refutation is confined to it by
#                                                           | construction rather than by silence.
#                                                           | No bound, every quantity a count.
#                                                           | Axioms
#                                                           | `[propext, Classical.choice, Quot.sound]`
#                                                           | on all twenty-one printed theorems. No
#                                                           | `sorryAx`, no custom axiom, no
#                                                           | `native_decide`.
# seam-gluing-ray-product/ladder-cell-agreement-refutation  | THE CELL-AGREEMENT CONSTRUCTION
#                                                           | REFUTATION: the ONE construction the
#                                                           | cell-level route to the ladder's
#                                                           | agreement on `kappa`-classes names is
#                                                           | REFUTED. The construction
#                                                           | (`AtomPreservingCountMove`): replace a
#                                                           | ladder path, at a chosen position, by
#                                                           | one through the same object state with
#                                                           | any admissible counter pair there,
#                                                           | preserving the ATOM ROW at every
#                                                           | position -- which is the hypothesis
#                                                           | `tpOf_stabFree_eq_of_lab_eq`, the only
#                                                           | landed way to make two ladder paths
#                                                           | realize the same stab-free type,
#                                                           | carries. Mechanism, compiled in the
#                                                           | library: `cntAt_eq_of_pend_eq` makes
#                                                           | the countdown a function of the PEND
#                                                           | PROFILE alone, so moving `c` means
#                                                           | moving the pend profile; and
#                                                           | `PendFactorsLab` (via
#                                                           | `pendFactorsLab_of_atom`) turns that
#                                                           | into moving an atom row as soon as the
#                                                           | labelling carries the pending bit as
#                                                           | one of its atoms -- which the
#                                                           | realization statement, quantifying
#                                                           | over EVERY `lab`, does not exclude. So
#                                                           | the construction's two requirements are
#                                                           | jointly unsatisfiable
#                                                           | (`atomPreservingCountMove_refutedC`).
#                                                           | Two states (one pending, one idle),
#                                                           | step complete, the pending bit carried
#                                                           | as the atom `p`; seriality DISCHARGED
#                                                           | (`fwdC`, `bwdC`); the walk pending at
#                                                           | every PAST position (the forward-only
#                                                           | liveness regime of
#                                                           | `ladder-liveness-forward-only`), which
#                                                           | leaves the next-deadline register free
#                                                           | of every pin. NON-VACUITY ON BOTH
#                                                           | SIDES, carried as conjuncts of
#                                                           | `exists_refuting_collision`: `ParamsOk`
#                                                           | discharged at the periodicity
#                                                           | fixpoint's own outputs (`paramsOkC`),
#                                                           | a POPULATED `kappa`-collision with
#                                                           | `c ≠ c'` (`kappa_collisionC`, through
#                                                           | the library's `kappa_eq_of_shift`), a
#                                                           | ladder path through EACH of the two
#                                                           | ladder states, and the closure's atom
#                                                           | realized on each side
#                                                           | (`mem_cell_of_gC`). The `n` HALF of the
#                                                           | construction CLOSES (`nxt_free`), so
#                                                           | the obstruction is confined to the `c`
#                                                           | coordinate by construction rather than
#                                                           | by silence. WHAT IS NOT SETTLED: the
#                                                           | obligation `CellLEZeroConstOfKappaEq`
#                                                           | itself is NOT refuted -- a cell is a
#                                                           | set of TYPES over all histories, and
#                                                           | two paths can realize the same closure
#                                                           | type without agreeing on a single atom
#                                                           | row, so a construction that does not
#                                                           | preserve the valuation pointwise is
#                                                           | left entirely open and is stated
#                                                           | nowhere in the tree. Nothing about
#                                                           | `cellAt_const_of_kappa_eq`,
#                                                           | `ladderSound`, `ladderLift` or
#                                                           | `ladderRealized`; the PRESENTATION is
#                                                           | untouched; half (i) and the
#                                                           | atom-valuation agreement are untouched
#                                                           | and both still hold at their own
#                                                           | hypotheses. No bound, every quantity a
#                                                           | count; no device-discrimination claim.
#                                                           | Axioms: `[propext]` on
#                                                           | `pendFactorsLabC`, `fwdC` and `bwdC`,
#                                                           | and `[propext, Quot.sound]` or
#                                                           | `[propext, Classical.choice,
#                                                           | Quot.sound]` on the other fourteen
#                                                           | printed theorems. No `sorryAx`, no
#                                                           | custom axiom, no `native_decide`.
# seam-gluing-ray-product/ladder-cell-obligation-refutation | THE DEPTH-0 CELL OBLIGATION AS
#                                                           | FILED IS REFUTED: the schema
#                                                           | `CellLEZeroConstOfKappaEqPre` (the
#                                                           | library's text with the parameter
#                                                           | conditions' fourth conjunct FROZEN
#                                                           | at `paramsOkK4Pre`, the (K4) that
#                                                           | bounds the gap clip by `dBack`
#                                                           | alone) is FALSE at the object of
#                                                           | `ladder-cell-agreement-refutation`
#                                                           | (two states, one pending and one
#                                                           | idle, step complete, the pending bit
#                                                           | carried as the atom `p`), at the
#                                                           | periodicity fixpoint's own parameter
#                                                           | outputs (`paramsOk_params`), for a
#                                                           | stab-free, `S`-free closure.
#                                                           | Mechanism: the gap coordinate of
#                                                           | `kappa` clips `n - c` at `B`, and
#                                                           | the frozen (K4) admits `B = 2` for
#                                                           | a formula with no `S`; but the cell
#                                                           | reads the next-deadline register
#                                                           | FORWARD through the next region's
#                                                           | pin (`cntAt_eq_nxtAt_of_idle_pend`,
#                                                           | `nxtAt_lipschitz`), so
#                                                           | `nxtAt z ≤ cntAt z + I₁ + L₁ - 1`
#                                                           | for the next idle run `I₁` and the
#                                                           | next region `L₁`, and a `U`-only
#                                                           | formula of bounded `X`-depth
#                                                           | (`chiD`) pins `I₁ = 1`, `L₁ = 2`.
#                                                           | The type carrying `chiD` lies in the
#                                                           | cell at `(q, c, c + 2)` and in NO
#                                                           | type of the cell at
#                                                           | `(q, c, c + 2 + (P + 1))`, while the
#                                                           | two states collide under `kappa`
#                                                           | (`kappa_D`). The gap clip does not
#                                                           | dominate the register's forward
#                                                           | window. Headlines:
#                                                           | `cellLEZeroConstOfKappaEqPre_refuted`
#                                                           | and
#                                                           | `exists_refuting_cell_collision`
#                                                           | (NON-VACUITY ON BOTH SIDES as
#                                                           | conjuncts: `ParamsOkPre` discharged
#                                                           | at the fixpoint's outputs, a populated
#                                                           | collision with `n ≠ n'`, a ladder
#                                                           | path through EACH of the two
#                                                           | states, the closure stab-free, and
#                                                           | the schema refuted at that very
#                                                           | object). WHAT THE REPAIR OF (K4)
#                                                           | ANSWERS, compiled as two positive
#                                                           | facts: the library's (K4) now
#                                                           | bounds `B` by BOTH exactness depths
#                                                           | (`dBack`, `dFwd`) and by `2`;
#                                                           | `not_paramsOkK4_two` (the repaired
#                                                           | (K4) rejects `B = 2` for `chiD`,
#                                                           | whose `dFwd` is `4`) and
#                                                           | `kappa_D_dissolves` (at the
#                                                           | repaired output `Bof = 9` the
#                                                           | specific collision is no longer
#                                                           | one). Neither is a proof of the
#                                                           | obligation under the repaired
#                                                           | predicate. Seriality DISCHARGED
#                                                           | (`fwdC`, `bwdC`). No bound, every
#                                                           | quantity a count. Axioms
#                                                           | `[propext, Classical.choice,
#                                                           | Quot.sound]` on the printed
#                                                           | theorems (a subset on the two
#                                                           | positive facts). No `sorryAx`, no
#                                                           | custom axiom, no `native_decide`.
# seam-gluing-ray-product/ladder-tight-chain-nonliftability | NO FINITE DELETION-DERIVATIVE OF
#                                                           | THE TIGHT DOUBLING CHAIN LIFTS --
#                                                           | the one claim the RaySummary README
#                                                           | recorded as ARGUED rather than
#                                                           | compiled, now compiled, on the
#                                                           | two-state object of
#                                                           | `ladder-cell-agreement-refutation`
#                                                           | and the doubling chain with pins
#                                                           | UNBOUNDED ABOVE (idle at every
#                                                           | `v <= 0` and exactly at `2^j - 2`
#                                                           | for `j >= 1`). The register equals
#                                                           | the POSITION at every pin, so every
#                                                           | gap has Lipschitz slack exactly `0`
#                                                           | (`tightChain_slack_zero`) and there
#                                                           | is no slack anywhere to absorb a
#                                                           | surgery. Headlines:
#                                                           | `tightChain_positive_deletion_does_not_lift`
#                                                           | (for every `a >= 4` and every
#                                                           | `L > 0`, NO ladder path has the
#                                                           | chain's walk with `[a, a + L)`
#                                                           | deleted -- the countdown and the
#                                                           | register both existentially
#                                                           | quantified away, which is the
#                                                           | LIFTING form, not the weaker
#                                                           | register-specific one),
#                                                           | `tightChain_iter_deletion_does_not_lift`
#                                                           | and
#                                                           | `tightChain_deletion_derivative_does_not_lift`
#                                                           | (the latter two carrying `0 < m`:
#                                                           | at `m = 0` the derivative IS the
#                                                           | chain and is a ladder path).
#                                                           | Mechanism: two pins of the DELETED
#                                                           | walk on opposite sides of the
#                                                           | deletion -- the pin at `0` below it
#                                                           | and a pin `2^j - 2 - L` above it --
#                                                           | fall `L` closer while their
#                                                           | countdown difference does not move,
#                                                           | and `pinCompat_of_ladderPath`
#                                                           | (`LadderAgree.lean`) makes pairwise
#                                                           | compatibility NECESSARY for any
#                                                           | ladder path. The carrier's own
#                                                           | arithmetic: no register, type,
#                                                           | parameter condition or certificate
#                                                           | object enters. WHAT IT DOES NOT
#                                                           | SETTLE, reported with it: the step
#                                                           | from non-liftability to a cell
#                                                           | inequality needs a closure formula
#                                                           | whose letters FORCE the realizing
#                                                           | path to be a deletion-derivative of
#                                                           | the chain, which is the open
#                                                           | depth-`0` core itself -- so the
#                                                           | gate's verdict is INCONCLUSIVE and
#                                                           | the reserved name
#                                                           | `cellLE_zero_const_of_kappa_eq` is
#                                                           | claimed by nothing. The
#                                                           | finite-`J` chain is NOT the object:
#                                                           | its last region carries no pin
#                                                           | above it, so it HAS a lifting
#                                                           | deletion-derivative. No bound,
#                                                           | every quantity a count.
# seam-gluing-ray-product/ladder-reps-bound-refutation      | `repsCnt`'S NARROWER BOUND
#                                                           | `Tc + Tn + P + B + 2` IS REFUTED:
#                                                           | the bounded-representative set is
#                                                           | too small for the
#                                                           | bounded-representative lemma, and
#                                                           | the failure runs in two independent
#                                                           | directions. The narrower bound is
#                                                           | FROZEN inside the probe as
#                                                           | `repsCntPre`, with `rkStepBPre`,
#                                                           | `RKbPre` and `RKPre` over it
#                                                           | (verbatim the library's text with
#                                                           | the one range argument as it
#                                                           | stood), because at the widened
#                                                           | library bound `RK` is TRUE at all
#                                                           | three tuples and a refutation
#                                                           | against the library's own `RK`
#                                                           | would not compile -- the same
#                                                           | device as the frozen `ParamsOkPre`
#                                                           | of
#                                                           | `ladder-cell-obligation-refutation`.
#                                                           | Headlines, each `decide`-checked:
#                                                           | `witnessA_not_RKPre` at
#                                                           | `(1, 2, 2, 2)` with
#                                                           | `Count false false 9 5 0` and
#                                                           | `Drift 5 4` (the RESIDUE-COUPLING
#                                                           | direction, worked: the only
#                                                           | in-range pre-step pair is `(6, 2)`
#                                                           | and `Drift 2 b'` cannot reach the
#                                                           | post-step class; the least
#                                                           | admissible first coordinate is `9`,
#                                                           | exactly the narrower bound's own
#                                                           | value, so one place outside
#                                                           | `Finset.range 9`),
#                                                           | `witnessB_not_RKPre` at
#                                                           | `(4, 6, 5, 2)` with
#                                                           | `Count true true 20 11 19` and
#                                                           | `Drift 11 12` (the same mechanism at
#                                                           | a larger modulus), and
#                                                           | `witnessC_not_RKPre` at
#                                                           | `(0, 0, 0, 3)` with
#                                                           | `Count false false 5 2 0` and
#                                                           | `Drift 2 3` -- THE `P = 0` HALF,
#                                                           | the SATURATED-GAP direction with no
#                                                           | residue at all, which locates the
#                                                           | defect in the gap window alone: the
#                                                           | two saturations together demand a
#                                                           | window `B + 2` wide and the
#                                                           | narrower bound pays only `B`.
#                                                           | NON-VACUITY ON BOTH SIDES, PER
#                                                           | TUPLE (`both_sides_A`,
#                                                           | `both_sides_B`, `both_sides_C`):
#                                                           | each tuple also carries its
#                                                           | POSITIVE `RK` at the widened
#                                                           | library definition, discharged by
#                                                           | ONE application of
#                                                           | `rk_of_count_drift` and never by
#                                                           | `decide` -- `decide` over this
#                                                           | predicate is `M^4`-shaped in the
#                                                           | range bound `M`, so the heartbeat
#                                                           | ceiling is the practical limit on
#                                                           | how large a tuple any probe may
#                                                           | name (at tuple B the widened bound
#                                                           | is `34` and `34^4` is infeasible
#                                                           | where `19^4` is merely expensive).
#                                                           | This is also the first use site of
#                                                           | `rk_of_count_drift`. No bound,
#                                                           | upper or lower: every quantity is
#                                                           | a COUNT of candidate pairs.
#                                                           | Axioms: a subset of
#                                                           | `[propext, Classical.choice,
#                                                           | Quot.sound]` on every headline.
#                                                           | No `sorryAx`, no custom axiom, no
#                                                           | `native_decide`.
# seam-gluing-ray-product/ladder-idle-past-interface-decision | THE IDLE-PAST INTERFACE
#                                                           | EXISTENTIAL IS **NOT REFUTED** ON
#                                                           | THE TIGHT DOUBLING CHAIN -- the
#                                                           | decision gate for the unlanded
#                                                           | `exists_ladderPath_at_region_of_idle_past`,
#                                                           | run on the one compiled object that
#                                                           | refutes the `spliceObj`-shaped
#                                                           | conclusion. The chain of
#                                                           | `ladder-tight-chain-nonliftability`
#                                                           | is RE-DERIVED here (a probe is
#                                                           | compiled with `lake env lean` and
#                                                           | sits outside the Lake module graph,
#                                                           | so no probe can import another);
#                                                           | that file is NOT edited or
#                                                           | re-signed. Instance, explicit and
#                                                           | compiled non-vacuous
#                                                           | (`instance_is_in_regime`): pin
#                                                           | `s = 2 = 2^2 - 2`, splice point
#                                                           | `a = 3`, comparison position
#                                                           | `v = 3`, cycle length `l = 1`
#                                                           | (`l <= cntAt tightChain 3 = 2`,
#                                                           | `cT_three`), idle witness `p = 2`.
#                                                           | The chain is idle at every
#                                                           | `v <= 0`, so NO position of it has
#                                                           | a pending-forever past and the
#                                                           | LANDED half
#                                                           | `exists_ladderPath_at_region_of_pend_past`
#                                                           | is VACUOUS on this object -- the
#                                                           | idle-past half is the only half it
#                                                           | exercises. Headline:
#                                                           | `idle_past_interface_witnessed`
#                                                           | (`objAt gW 3 = objAt tightChain 3`
#                                                           | and
#                                                           | `cntAt gW 3 = cntAt tightChain 3 + 1`,
#                                                           | i.e. `3 = 2 + 1`), with
#                                                           | `exists_ladderPath_at_region_on_tightChain_instance`
#                                                           | the same fact in existential shape
#                                                           | AT THE INSTANCE. The witness is the
#                                                           | CASCADE walk, not the splice: it
#                                                           | lengthens the region `3, 4, 5` to
#                                                           | `3, 4, 5, 6` and displaces the
#                                                           | chain's idle positions `2^j - 2`
#                                                           | (`j >= 3`) up to `2^j - 1`, AND
#                                                           | inserts one idle copy into the idle
#                                                           | run at the witness, pushing the past
#                                                           | strictly below it down by `1`. The
#                                                           | plain splice `spliceObj tightChain
#                                                           | 3 1` fails exactly the pin clause:
#                                                           | it raises the region start `2` to
#                                                           | countdown `3` while the pin at `0`
#                                                           | keeps `0`, and
#                                                           | `|3 - 0| = 3 > |2 - 0| = 2`
#                                                           | violates the pairwise condition
#                                                           | `pinCompat_of_ladderPath` proves
#                                                           | NECESSARY for any ladder path
#                                                           | whatsoever. The repaired pin
#                                                           | arithmetic is `cW_pin`/`hpinsW`
#                                                           | (region-start countdown `s + 1` at
#                                                           | the two low pins `-1`, `2`; `s - 1`
#                                                           | at every high pin `2^j - 1`) with
#                                                           | base register `n0 = 1` (`hn0W`).
#                                                           | **NON-GENERALITY, and it is the
#                                                           | point**: `stepC` is TOTAL, so `hw`
#                                                           | discharges by `rfl` and a witness
#                                                           | here pays NONE of the self-loop
#                                                           | cost the general statement pays.
#                                                           | This probe decides REFUTABILITY and
#                                                           | never PROVABILITY, and nothing under
#                                                           | the names
#                                                           | `exists_ladderPath_at_region_of_idle_past`,
#                                                           | `exists_ladderPath_at_region` or
#                                                           | `exists_spliced_ladderPath_of_idle_past`
#                                                           | is landed by it. No bound, every
#                                                           | quantity a count. Axioms: a subset
#                                                           | of `[propext, Classical.choice,
#                                                           | Quot.sound]` on every headline. No
#                                                           | `sorryAx`, no custom axiom, no
#                                                           | `native_decide`.
# seam-gluing-ray-product/one-sided-count-move-refutation   | THE ONE-SIDED COUNT MOVE IS
#                                                           | REFUTED ON THE `◁` SIDE, and the
#                                                           | recorded TWO-SIDED refutation comes
#                                                           | back out of it as a COROLLARY --
#                                                           | NEGATIVE VERDICT on the open-modal
#                                                           | factorization as a route past the
#                                                           | transport wall.  `◁` fixes the
#                                                           | future and varies the past
#                                                           | (`AgreeFrom`); `▷` fixes the past
#                                                           | and varies the future (`AgreeUpTo`).
#                                                           | Both quantifiers fix the FULL ladder
#                                                           | state at the evaluation point, so
#                                                           | what is measured is the ATOM-ROW
#                                                           | RELAXATION ON A HALF-LINE of
#                                                           | `AtomPreservingCountMove`, the
#                                                           | strongest form either projection can
#                                                           | honestly be read as giving.
#                                                           | `futAtomPreservingCountMove_refuted`
#                                                           | kills the `◁`-shaped relaxation
#                                                           | under exactly the hypotheses the
#                                                           | landed `atomPreservingCountMove_refuted`
#                                                           | carries, by
#                                                           | `cntAt_eq_of_pend_eq_fwd` -- a strict
#                                                           | FORWARD-ONLY sharpening of the landed
#                                                           | `cntAt_eq_of_pend_eq`, whose own
#                                                           | proof reads its hypothesis only at
#                                                           | positions at or above the compared
#                                                           | one.  Freeing the whole PAST buys
#                                                           | nothing: the obstruction is entirely
#                                                           | forward.  The `▷` side is
#                                                           | ATTRIBUTED, NOT RE-PROVED: the landed
#                                                           | `exists_spliced_ladderPath_of_pend_past`
#                                                           | already IS a `▷`-shaped count move
#                                                           | (`spliceObj_eq_of_le` holds the object
#                                                           | row at every `v <= a`,
#                                                           | `spliced_at_region` moves the
#                                                           | countdown) and
#                                                           | `ladder-splice-type-refutation` says
#                                                           | it does not preserve the realized
#                                                           | stab-free type.  The pincer: the
#                                                           | counter and the closure's
#                                                           | eventualities read the SAME forward
#                                                           | half-line, so freezing the future
#                                                           | leaves nothing to transport and
#                                                           | freeing it loses the type.  The
#                                                           | two-state object is RE-DERIVED from
#                                                           | `ladder-cell-agreement-refutation` (a
#                                                           | probe is compiled with
#                                                           | `lake env lean` outside the Lake
#                                                           | module graph, so no probe can import
#                                                           | another); that file is NOT edited or
#                                                           | re-signed.  NON-VACUITY IS DISCHARGED
#                                                           | IN THIS FILE, not inherited:
#                                                           | `exists_one_sided_refuting_instance`
#                                                           | pins the walk `gC 3 5`, comparison
#                                                           | position `z = 0` where the state is
#                                                           | PENDING, and target countdown
#                                                           | `3 + 1` against the path's own `3`;
#                                                           | the target is admissible because
#                                                           | `Adm pend q = {c | pend q = false ->
#                                                           | c = 0}` has a false hypothesis at a
#                                                           | pending state, so EVERY countdown is
#                                                           | admissible where the pending bit is
#                                                           | set (`admZeroC`).  The two headlines
#                                                           | `futAtomPreservingCountMove_refutedO`
#                                                           | and `atomPreservingCountMove_refutedO`
#                                                           | carry NO hypotheses.  NO bound and NO
#                                                           | decidability claim, in either
#                                                           | direction; no finite-fibre and no
#                                                           | finite-width assumption; the live
#                                                           | `LadderChain.lean` route's gap to
#                                                           | `CellLEZeroConstOfKappaEq` is NOT a
#                                                           | one-sidedness gap and is untouched.
#                                                           | Axioms: `no axioms` on the two
#                                                           | relaxation lemmas, and a subset of
#                                                           | `[propext, Classical.choice,
#                                                           | Quot.sound]` on every other headline.
#                                                           | No `sorryAx`, no custom axiom, no
#                                                           | `native_decide`.
WIRED=(
  "bi-lasso-decision-layer/phase3-scan-bound-is-false"
  "bi-lasso-decision-layer/phase7-filtered-frame-is-universal"
  "bi-lasso-decision-layer/phase12-check-not-compositional"
  "bi-lasso-decision-layer/phase10-origin-anchoring-obstruction"
  "frame-constraints-audit/mixed-sign-composition-obstruction"
  "stability-modal-substrate/closure-field-is-necessary"
  "seam-gluing-ray-product/stab-fibre-is-ray-product"
  "seam-gluing-ray-product/stab-depth-stratification"
  "seam-gluing-ray-product/finite-graph-stab-summary"
  "seam-gluing-ray-product/mosaic-germ-amalgamation"
  "seam-gluing-ray-product/path-quantifier-alternation"
  "seam-gluing-ray-product/backward-dual-asymmetric-fixture"
  "seam-gluing-ray-product/backward-dual-mirror-fixture"
  "seam-gluing-ray-product/device-selection-probe"
  "seam-gluing-ray-product/cslib-ramsey-port-feasibility"
  "seam-gluing-ray-product/ktype-summary-substrate-probe"
  "seam-gluing-ray-product/stab-depth-two-probe"
  "seam-gluing-ray-product/presents-is-seam-decidedness"
  "seam-gluing-ray-product/quasistate-does-not-determine-hit"
  "seam-gluing-ray-product/presented-not-complete"
  "seam-gluing-ray-product/stab-depth-two-shared-stratum"
  "seam-gluing-ray-product/hit-presented-model-a"
  "seam-gluing-ray-product/b2b-frame-constructor-branching"
  "seam-gluing-ray-product/mosaic-stab-saturated"
  "seam-gluing-ray-product/w-soundness-shape-refuted"
  "seam-gluing-ray-product/deadline-ladder-branching"
  "seam-gluing-ray-product/node-cell-stabilization"
  "seam-gluing-ray-product/hit-presented-node"
  "seam-gluing-ray-product/ladder-cell-refutation"
  "seam-gluing-ray-product/ladder-liveness-forward-only"
  "seam-gluing-ray-product/ladder-cell-index-obstructions"
  "seam-gluing-ray-product/ladder-residue-index-refutation"
  "seam-gluing-ray-product/ladder-joint-index-refutation"
  "seam-gluing-ray-product/closure-indexed-periodicity"
  "seam-gluing-ray-product/closure-profile-gate-rerun"
  "seam-gluing-ray-product/nside-modulus-gate"
  "seam-gluing-ray-product/realizable-type-adequacy-gap"
  "seam-gluing-ray-product/realizable-type-certificate"
  "seam-gluing-ray-product/backward-determinism-forcing-formula"
  "seam-gluing-ray-product/certificate-sufficiency-dovetailing"
  "seam-gluing-ray-product/no-pending-forever-ray"
  "seam-gluing-ray-product/counter-lift-gates"
  "seam-gluing-ray-product/ladder-unconstrained-parameter-refutation"
  "seam-gluing-ray-product/ladder-splice-type-refutation"
  "seam-gluing-ray-product/ladder-cell-agreement-refutation"
  "seam-gluing-ray-product/ladder-cell-obligation-refutation"
  "seam-gluing-ray-product/ladder-tight-chain-nonliftability"
  "seam-gluing-ray-product/ladder-reps-bound-refutation"
  "seam-gluing-ray-product/ladder-idle-past-interface-decision"
  "seam-gluing-ray-product/one-sided-count-move-refutation"
)

# --- WIRED_REPO ---------------------------------------------------------------------------
# Repository-relative probe paths, for probes that cannot (yet) live under `specs/evidence/`.
#
# probe (repository-relative path)                          | the decision it holds in place
# ----------------------------------------------------------|-----------------------------------
# specs/archive/476_box_faithful_small_model_theorem/       | the finite model property FAILS at
#   evidence/fmp-hypothesis-is-false.lean                   | ZTime for EVERY candidate list --
#                                                           | `fmp_false` exhibits one formula no
#                                                           | finite `IntPresentation` satisfies
#                                                           | but which is ZTime-satisfiable.  This
#                                                           | is why the decision layer presents
#                                                           | finite GENERATORS of infinite regular
#                                                           | models rather than searching for a
#                                                           | finite model, and why no finite-model
#                                                           | certificate may be assumed available
#
# WHY THIS ONE IS NOT UNDER `specs/evidence/`.  It should be, by the convention in this file's
# header, and this is a DEFERRED MOVE with a named blocker -- not an exemption.  Three files
# outside the current writable scope cite the probe by its archive path verbatim
# (`FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`,
# `FormalSystem/Metalogic/Decidability/BiLasso/README.md`, and
# `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`), so moving the file would break
# those citations in the same edit.  Move it when those three sites can be updated together.
#
# NOTE ON VERSION CONTROL.  `.gitignore` excludes `specs/archive/`, so this file survives in
# version control only because it was tracked before it was archived; a *new* file at that path
# would not be.  `git add` on it needs `git add -u`, since plain `git add` refuses an
# ignore-matching pathspec.  That fragility is a further reason to complete the move.
WIRED_REPO=(
  "specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean"
)

# --- DEFERRED -----------------------------------------------------------------------------
# `spike-untl-unfolding-and-fwd-obstruction` is deliberately NOT wired.  It no longer compiles:
# it cites `FrameClass.Discrete` and `TaskFrame.trivialFrame`, both gone from the current
# frame-class API.  Its subject is the frame-class mismatch between `FrameClass.Base` and
# `FrameClass.Discrete`, and it asserts results about a `filteredStep_fwd` that the frame-class
# uniformity work is expected to change.  Wiring it now would freeze a question that is still
# open.  When that work lands, repair it under the same no-weakening rule as the wired probes
# (track the API; never delete or restate an obstruction to make it pass), then wire it in.
DEFERRED=("bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction")

# --- SHARED `.lake` LOCK --------------------------------------------------------------------
# LOCKED AGAINST CONCURRENT `.lake` WRITERS.
#
# `check_probe` below invokes `lake env lean` once per wired entry, and every one of those
# invocations READS `.lake`: the oleans of the whole import closure the probe pulls in.  An
# unserialized read races any guarded `lake build` rewriting those same artifacts on this tree.
# The reader can observe the window in which a tail module's olean has been removed and not yet
# rewritten, and Lean then reports `object file '...' of module ... does not exist`.  That is an
# I/O failure of the environment, not a fact about the probe, yet it arrives on the same stderr a
# rotted probe would use.  A reader takes the WRITER'S exclusive lock here rather than a shared
# one: `lake env` is not audited as provably write-free, and both existing users of this lock
# path take it exclusively.
#
# The lock is `$REPO_ROOT/.lake/build-guard.lock` -- the path `.claude/scripts/lake-build-guard.sh`
# publishes in its own header as a stable convention, and the same path
# `scripts/check-module-invariants.sh` takes at its `C1: build` block.  An advisory lock is keyed
# on the path, not on the binary that opened it, so this script and that deployed guard exclude
# each other with no reference from this repository into the disposable, regenerated `.claude/`
# tree: no probe for the guard's presence, no call into it, and unchanged behaviour in a clone
# with no agent system deployed at all, where the lock is simply uncontended.
#
# Acquired ONCE for the whole run and never released with `flock -u`: the fd is held until this
# process exits, which is what makes the verdicts below describe one consistent library snapshot
# rather than one independently-raced snapshot per probe, and what lets every `check_probe` call
# inherit the protection for free.  The cost is that a concurrent guarded build waits for this
# run; that is the intended trade -- a slower green in place of a spurious red -- and the same
# accepted cost `check-module-invariants.sh` already pays.
#
# The two alternatives to a bounded wait -- probe for the guard and call it when present, and
# refuse to run when concurrency is detected -- are recorded as rejected at
# `check-module-invariants.sh`'s `C1` block and are not re-litigated here.
#
# `PROBE_LOCK_WAIT_S` overrides the bounded wait.  It exists so the timeout branch can be
# exercised deliberately; it is a test affordance, not a tuning knob.  Default: 600 s.
# --------------------------------------------------------------------------------------------
PROBE_LOCK_WAIT_S="${PROBE_LOCK_WAIT_S:-600}"
REPO_ROOT="$(pwd)"
LOCK_FILE="$REPO_ROOT/.lake/build-guard.lock"
mkdir -p "$REPO_ROOT/.lake"
PROBE_LOCK_OK=1
if command -v flock >/dev/null 2>&1; then
  exec {PROBE_LOCK_FD}<>"$LOCK_FILE"
  if ! flock -n "$PROBE_LOCK_FD"; then
    echo "check-evidence-probes: waiting on the shared build lock ($LOCK_FILE, up to ${PROBE_LOCK_WAIT_S}s)" >&2
    if ! flock -w "$PROBE_LOCK_WAIT_S" "$PROBE_LOCK_FD"; then
      PROBE_LOCK_OK=0
    fi
  fi
else
  echo "check-evidence-probes: flock not found on PATH; compile-checking probes unserialized" >&2
fi
if [ "$PROBE_LOCK_OK" -ne 1 ]; then
  echo "FAIL (environment: timed out after ${PROBE_LOCK_WAIT_S}s waiting for the shared build lock"
  echo "      $LOCK_FILE)"
  echo
  echo "No probe was compile-checked.  This is an ENVIRONMENT failure in the sense named in the"
  echo "header's THREE DIAGNOSTIC CLASSES: the measurement never reached any probe's content, so"
  echo "no probe is to be repaired, restated, or retired on this evidence.  Re-run once the"
  echo "concurrent build holding the lock has finished."
  exit 1
fi

failures=0
env_failures=0
echo "Evidence probes (compile-checked outside the build graph)"
echo "========================================================="

# --- THE THIRD DIAGNOSTIC CLASS: ENVIRONMENT ------------------------------------------------
# A compile failure here has three possible causes, and conflating them is expensive.  ROT: the
# probe cites a declaration that has drifted, which is what this guard exists to catch.
# LEFT VERSION CONTROL: `FAIL (untracked: ...)`, handled above.  ENVIRONMENT: `lake env lean`
# reads `.lake` for every module in the probe's import closure, and if one of those artifacts is
# absent or half-written -- a concurrent build that outran the lock above, or a project that was
# simply never built -- Lean reports a missing object file.  The measurement then never reached
# the probe's own content at all.  Reporting that as rot is what once turned a single transient
# `.lake` race into four apparently-rotted probes and a repair record for probes that were never
# broken; naming the class is what keeps that from recurring.
#
# DELIBERATELY NARROW.  This predicate matches the missing-object-file shape and the adjacent
# OS-level artifact-absent shape under `.lake/`, and nothing else.  Every unmatched failure falls
# through to `FAIL (does not compile)` by construction: a missed environment failure costs one
# re-run, while genuine rot mislabelled as an environment failure is excused and never repaired.
# Widen this only against a measured error shape, never speculatively.
probe_env_failure() {
  local out="$1"
  # Lean's module loader: `error: object file '<path>' of module <Module> does not exist`.
  # Anchored on the phrase, not on any module name: the observed race named four different tail
  # modules on four consecutive entries.
  if printf '%s\n' "$out" | grep -q "object file '.*' of module .* does not exist"; then
    return 0
  fi
  # The OS reporting the same absence directly, as a never-built or mid-rewrite tree produces.
  # Both halves are required: a bare `no such file or directory` naming no `.lake/` path is not
  # evidence of an environment failure.
  if printf '%s\n' "$out" | grep -qi 'no such file or directory' &&
     printf '%s\n' "$out" | grep -q '\.lake/'; then
    return 0
  fi
  return 1
}

# One check, both entry forms: $1 is the label printed, $2 the file to compile.
check_probe() {
  local label="$1" file="$2"
  printf '  %-62s ' "$label"
  if [ ! -f "$file" ]; then
    echo "FAIL (missing: $file)"
    failures=$((failures + 1))
    return
  fi
  # Presence is not enough: a gitignored file (e.g. under `specs/archive/`) satisfies `-f` on
  # every machine that has it on disk and is absent from every fresh clone.  See TRACKED, NOT
  # MERELY PRESENT in the header.
  if ! git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
    echo "FAIL (untracked: $file -- present on disk but not in version control; a fresh clone has no such file)"
    failures=$((failures + 1))
    return
  fi
  local out
  if out=$(lake env lean "$file" 2>&1); then
    echo "PASS"
  elif probe_env_failure "$out"; then
    echo "FAIL (environment: absent or half-written .lake artifact -- NOT probe rot; never measured)"
    printf '%s\n' "$out" | sed 's/^/        /'
    env_failures=$((env_failures + 1))
    failures=$((failures + 1))
  else
    echo "FAIL (does not compile)"
    printf '%s\n' "$out" | sed 's/^/        /'
    failures=$((failures + 1))
  fi
}

for probe in "${WIRED[@]}"; do
  check_probe "$probe" "$EVIDENCE/$probe.lean"
done

for probe in "${WIRED_REPO[@]}"; do
  check_probe "$probe" "$probe"
done

for probe in "${DEFERRED[@]}"; do
  printf '  %-62s ' "$probe"
  if [ -f "$EVIDENCE/$probe.lean" ]; then
    echo "SKIP (deferred: frame-class uniformity work)"
  else
    echo "SKIP (deferred; file absent)"
  fi
done

wired_total=$(( ${#WIRED[@]} + ${#WIRED_REPO[@]} ))

echo
if [ "$failures" -eq 0 ]; then
  echo "PASS  all $wired_total wired probe(s) compile"
  exit 0
fi
echo "FAIL  $failures of $wired_total wired probe(s) failed"
if [ "$env_failures" -gt 0 ]; then
  echo "      $env_failures of those are ENVIRONMENT failures (absent or half-written .lake artifact), not probe rot"
fi
echo
echo "A probe failing means a recorded design obstruction no longer compiles."
echo "Do NOT delete the probe or weaken its statements to make this pass: repair the"
echo "citation drift, or -- if the obstruction genuinely no longer holds -- say so"
echo "explicitly and revisit the decision the probe was holding in place."
echo "A 'FAIL (untracked: ...)' means the record has left version control (typically an"
echo "archival mv into the gitignored specs/archive/): promote the file into specs/evidence/,"
echo "or delete the entry if the library now carries the result under lake build -- never"
echo "force-track it under specs/archive/."
echo "A 'FAIL (environment: ...)' means the measurement never reached the probe's own content: a"
echo ".lake artifact was absent or half-written, so Lean could not load the probe's import"
echo "closure.  No probe is to be repaired, restated, or retired on that evidence.  Re-run once"
echo "any concurrent lake build has finished; if it persists with no other build running, the"
echo "project is not built -- run lake build."
exit 1
