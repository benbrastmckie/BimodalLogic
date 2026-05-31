"""
Public oracle API for bimodal TM countermodel generation.

This module provides the top-level API:
    find_countermodel(formula_json, ...) -> StructuredCountermodel | None
    find_countermodels_batch(formulas_json, ...) -> list[StructuredCountermodel | None]

Progressive deepening: tries (N=2,M=2) -> (N=2,M=3) -> (N=3,M=3) -> (N=3,M=4) -> (N=4,M=4).
Returns the first countermodel found, or None if all bounds exhausted or timeout.

This module is fully implemented in Phase 3.
"""

from __future__ import annotations
import time
import threading
from typing import Optional

from .formula import Formula, parse_formula_json
from .countermodel import StructuredCountermodel, extract_countermodel
from .encoding import FrameEncoder


# Progressive deepening schedule: (N_worlds, M_steps)
DEEPENING_SCHEDULE = [
    (2, 2),
    (2, 3),
    (3, 3),
    (3, 4),
    (4, 4),
]


def find_countermodel(
    formula_json: dict,
    max_N: int = 4,
    max_M: int = 4,
    timeout_ms: int = 5000,
) -> Optional[StructuredCountermodel]:
    """
    Attempt to find a countermodel for the given formula using progressive deepening.

    The oracle uses quantifier-free finite instantiation encoding to enumerate
    all possible frame structures up to (N worlds, M time steps). It tries
    increasingly larger bounds until a countermodel is found or all bounds
    are exhausted within the timeout.

    Args:
        formula_json: Formula AST dict (bmlogic-bench format, 'formula_ast' field)
        max_N: Maximum number of worlds to try (default 4)
        max_M: Maximum number of time steps to try (default 4)
        timeout_ms: Total timeout in milliseconds (default 5000ms = 5s)

    Returns:
        StructuredCountermodel if a countermodel is found, None otherwise.
        Returns None on timeout or if formula is valid (no countermodel exists at these bounds).
    """
    try:
        formula = parse_formula_json(formula_json)
    except (ValueError, TypeError) as e:
        raise ValueError(f"Failed to parse formula JSON: {e}") from e

    deadline = time.monotonic() + timeout_ms / 1000.0

    for N, M in DEEPENING_SCHEDULE:
        if N > max_N or M > max_M:
            continue
        remaining_ms = max(0, int((deadline - time.monotonic()) * 1000))
        if remaining_ms <= 0:
            break

        cm = _find_countermodel_at_bounds(formula, N, M, remaining_ms)
        if cm is not None:
            return cm

    return None


def _find_countermodel_at_bounds(
    formula: Formula,
    N: int,
    M: int,
    timeout_ms: int,
) -> Optional[StructuredCountermodel]:
    """
    Try to find a countermodel at exactly (N worlds, M time steps).

    Returns a StructuredCountermodel if SAT, None if UNSAT or timeout.
    """
    import z3

    encoder = FrameEncoder(N, M)
    atoms = list(formula.atoms())
    # Filter out synthetic atoms used for top/bot derivations
    atoms = [a for a in atoms if not a.startswith("__")]

    solver = z3.Solver()
    solver.set("timeout", timeout_ms)

    # Add frame axiom constraints
    frame_constraints = encoder.frame_constraints()
    for c in frame_constraints:
        solver.add(c)

    # Add negation of formula (we want the formula to be FALSE at some point)
    # We quantify over a specific history and time point
    # The formula is false at sigma=0 (first history), t=0 (first time step)
    falsifying_history = 0
    falsifying_time = 0

    truth_expr = encoder.truth(formula, atoms, falsifying_history, falsifying_time)
    solver.add(z3.Not(truth_expr))

    result = solver.check()
    if result == z3.sat:
        model = solver.model()
        return extract_countermodel(model, encoder, formula, atoms, falsifying_history, falsifying_time)
    return None


def find_countermodels_batch(
    formulas_json: list[dict],
    max_N: int = 4,
    max_M: int = 4,
    timeout_ms: int = 5000,
) -> list[Optional[StructuredCountermodel]]:
    """
    Find countermodels for a batch of formulas.

    Each formula gets timeout_ms budget independently.

    Args:
        formulas_json: List of formula AST dicts
        max_N: Maximum number of worlds
        max_M: Maximum number of time steps
        timeout_ms: Per-formula timeout in milliseconds

    Returns:
        List of StructuredCountermodel or None, one per input formula.
    """
    results = []
    for formula_json in formulas_json:
        try:
            cm = find_countermodel(formula_json, max_N=max_N, max_M=max_M, timeout_ms=timeout_ms)
            results.append(cm)
        except Exception:
            results.append(None)
    return results
