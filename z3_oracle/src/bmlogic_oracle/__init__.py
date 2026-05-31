"""
bmlogic_oracle: Z3-based countermodel generator for bimodal TM logic.

This package uses quantifier-free finite instantiation encoding to efficiently
find countermodels for invalid bimodal TM formulas. It generates StructuredCountermodels
as negative training signal for BimodalHarness MCTS training.

Public API:
    - formula.py: parse_formula_json(), Formula dataclass hierarchy
    - encoding.py: FrameEncoder, encode_formula()
    - countermodel.py: StructuredCountermodel, extract_countermodel()
    - oracle.py: find_countermodel(), find_countermodels_batch()
    - provider.py: Z3OracleProvider (BimodalHarness OracleProvider protocol)
"""

__version__ = "0.1.0"

from .formula import (
    Formula,
    Atom,
    Neg,
    And,
    Or,
    Box,
    Until,
    Since,
    Top,
    Bot,
    Imp,
    Iff,
    Diamond,
    parse_formula_json,
)

from .oracle import find_countermodel, find_countermodels_batch

__all__ = [
    "__version__",
    # Formula types
    "Formula",
    "Atom",
    "Neg",
    "And",
    "Or",
    "Box",
    "Until",
    "Since",
    "Top",
    "Bot",
    "Imp",
    "Iff",
    "Diamond",
    # Parsing
    "parse_formula_json",
    # Oracle API
    "find_countermodel",
    "find_countermodels_batch",
]
