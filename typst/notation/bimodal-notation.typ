// ============================================================================
// bimodal-notation.typ
// Notation module for Bimodal TM logic documentation
//
// Provides notation for the bimodal logic combining S5 modality and
// linear temporal operators.
//
// Imports shared notation from shared-notation.typ
//
// Notation reconciliation with the Logos manual: two potential collisions
// were checked against
// ~/Projects/Logos/Theory/typst/manual/notation/basic-notation.typ.
// Resolution:
//   1. Task-arrow glyph (`taskto`, below): Bimodal already uses the
//      double-arrow-with-duration-subscript glyph matching chapter 02;
//      this stays the book-wide task-transition arrow.
//   2. `Dur` (line ~37 below) vs Logos duration conventions: already
//      aligned (both use a duration-type symbol distinct from world-state
//      symbols); no change needed.
// ============================================================================

#import "shared-notation.typ": *

// ============================================================================
// Formula Syntax (Bimodal-specific)
// ============================================================================

// --- Temporal Operators ---
#let allpast = $H$
#let allfuture = $G$
#let somepast = $P$
#let somefuture = $F$

// --- Combined Temporal (always/sometimes triangles) ---
// Using filled triangles for visual distinction
#let always = $triangle.stroked.t$
#let sometimes = $triangle.stroked.b$

// --- Temporal Swap Operation ---
#let swap = $chevron.l S chevron.r$

// ============================================================================
// Semantics (Bimodal-specific)
// ============================================================================

// --- Frame Structure ---
#let taskframe = $cal(F)$
#let Dur = $cal(D)$
#let worldstate = $W$
#let taskrel = $R$

// Task relation arrow: w => x => u means w transitions to u with duration x
#let taskto(x) = $arrow.r.double.long_#x$

// --- Model Structure ---
// model is imported from shared-notation.typ
#let valuation = $V$

// --- World History ---
#let history = $tau$
#let althistory = $sigma$
#let domain = $"dom"$
#let histories = $H$

// --- Truth Relation ---
#let satisfies = $tack.r.double$
#let notsatisfies = $tack.r.double.not$
#let truthat(m, t, x, phi) = $#m, #t, #x #satisfies #phi$

// ============================================================================
// Proof Theory (Bimodal-specific extensions)
// ============================================================================

// --- Derivability ---
// proves and ctx are imported from shared-notation.typ
#let derivable(gamma, phi) = $#gamma #proves #phi$

// --- Validity ---
#let valid(phi) = $#proves #phi$
#let framevalid(f, phi) = $#f #satisfies #phi$

// ============================================================================
// Metalanguage Connectives
// ============================================================================

// Metalanguage biconditional (distinct from object language iff) - italic style
#let Iff = math.italic("iff")

// Overset: place text above a symbol (for duration over arrows)
#let overset(base, top) = $limits(#base)^#top$

// Time-shift relation with subscript/superscript stacking (LaTeX-style)
#let timeshift(sub, sup) = $limits(approx)_#sub^#sup$

// ============================================================================
// Lean Identifier Commands
// ============================================================================

#let leanTaskRel = raw("TaskRel")
#let leanTimeShift = raw("timeShift")
#let leanRespTask = raw("respects_task")
#let leanConvex = raw("convex")
#let leanDomain = raw("domain")
#let leanStates = raw("states")
#let leanNullityIdentity = raw("nullity_identity")
#let leanComp = raw("comp")
#let leanForwardComp = raw("forward_comp")
#let leanConverse = raw("converse")
#let leanSerial = raw("serial")
#let leanLimit = raw("limit")
#let leanSpherical = raw("spherical")
#let leanNullityDerived = raw("nullity")  // derived theorem, not a field: TaskRel w 0 w
