"""
BimodalHarness OracleProvider protocol implementation.

This thin wrapper around oracle.py implements the OracleProvider interface
expected by BimodalHarness for discovery via entry points.

The entry point is registered in pyproject.toml as:
  [project.entry-points."bimodal_harness.oracle_providers"]
  z3_oracle = "bmlogic_oracle.provider:Z3OracleProvider"
"""

from __future__ import annotations
from typing import Optional

from .oracle import find_countermodel, find_countermodels_batch
from .countermodel import StructuredCountermodel


class Z3OracleProvider:
    """
    OracleProvider implementation using Z3-based countermodel search.

    Implements the BimodalHarness OracleProvider protocol:
      - is_valid(formula_json) -> bool | None  (True=valid, False=invalid, None=unknown)
      - find_countermodel(formula_json, ...) -> StructuredCountermodel | None

    The Z3 oracle provides:
      - SOUND: if it returns a countermodel, the formula IS invalid (no false positives)
      - INCOMPLETE: may return None for invalid formulas (bounded search)

    Usage:
        from bmlogic_oracle.provider import Z3OracleProvider
        oracle = Z3OracleProvider()
        cm = oracle.find_countermodel(formula_ast)
        if cm is not None:
            print("Formula is invalid, countermodel found")
    """

    def __init__(
        self,
        max_N: int = 4,
        max_M: int = 4,
        timeout_ms: int = 5000,
    ):
        """
        Initialize the Z3 oracle provider.

        Args:
            max_N: Maximum number of worlds (default 4)
            max_M: Maximum number of time steps (default 4)
            timeout_ms: Per-formula timeout in milliseconds (default 5000ms)
        """
        self.max_N = max_N
        self.max_M = max_M
        self.timeout_ms = timeout_ms

    def find_countermodel(
        self,
        formula_json: dict,
        timeout_ms: Optional[int] = None,
    ) -> Optional[StructuredCountermodel]:
        """
        Find a countermodel for the given formula.

        Args:
            formula_json: Formula AST dict (bmlogic-bench 'formula_ast' format)
            timeout_ms: Override timeout (uses instance default if None)

        Returns:
            StructuredCountermodel if formula is invalid (at these bounds),
            None if no countermodel found within bounds/timeout.
        """
        t = timeout_ms if timeout_ms is not None else self.timeout_ms
        return find_countermodel(
            formula_json,
            max_N=self.max_N,
            max_M=self.max_M,
            timeout_ms=t,
        )

    def is_valid(self, formula_json: dict) -> Optional[bool]:
        """
        Check if a formula is valid (no countermodel exists).

        Returns:
            False if a countermodel is found (definitely invalid)
            None if no countermodel found (may be valid or incomplete search)
            Never returns True (bounded search cannot prove validity)
        """
        cm = self.find_countermodel(formula_json)
        if cm is not None:
            return False
        return None  # Unknown: may be valid or just not found within bounds

    def find_countermodels_batch(
        self,
        formulas_json: list[dict],
        timeout_ms: Optional[int] = None,
    ) -> list[Optional[StructuredCountermodel]]:
        """
        Find countermodels for a batch of formulas.

        Args:
            formulas_json: List of formula AST dicts
            timeout_ms: Per-formula timeout override

        Returns:
            List of StructuredCountermodel or None, one per input formula.
        """
        t = timeout_ms if timeout_ms is not None else self.timeout_ms
        return find_countermodels_batch(
            formulas_json,
            max_N=self.max_N,
            max_M=self.max_M,
            timeout_ms=t,
        )
