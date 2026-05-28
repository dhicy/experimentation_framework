"""
IndodaxAPILibrary
=================
Custom Robot Framework library providing:
  - Advanced JSON field validation
  - Numeric range assertions
  - Schema structure checks
  - Response timing utilities
  - Logging helpers
"""

import json
import time
import re
from datetime import datetime
from robot.api import logger
from robot.api.deco import keyword


class IndodaxAPILibrary:
    """Custom keyword library for Indodax API automation."""

    ROBOT_LIBRARY_VERSION = "1.0.0"
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    # ──────────────────────────────────────────────────────────────
    # JSON / Response Structure
    # ──────────────────────────────────────────────────────────────

    @keyword("Response Should Contain Key")
    def response_should_contain_key(self, response_json: dict, key: str):
        """Assert that a parsed JSON dict contains *key*."""
        assert key in response_json, (
            f"Expected key '{key}' not found in response. "
            f"Available keys: {list(response_json.keys())}"
        )
        logger.info(f"✅ Key '{key}' found in response.")

    @keyword("Response Should Contain Keys")
    def response_should_contain_keys(self, response_json: dict, *keys):
        """Assert all *keys* exist in *response_json*."""
        missing = [k for k in keys if k not in response_json]
        assert not missing, (
            f"Missing keys in response: {missing}. "
            f"Available keys: {list(response_json.keys())}"
        )
        logger.info(f"✅ All expected keys present: {list(keys)}")

    @keyword("Nested Key Should Exist")
    def nested_key_should_exist(self, response_json: dict, *path):
        """Walk a dotted path of keys and assert each level exists."""
        current = response_json
        traversed = []
        for key in path:
            assert isinstance(current, dict) and key in current, (
                f"Key '{key}' not found at path {' -> '.join(traversed) or 'root'}. "
                f"Current level keys: {list(current.keys()) if isinstance(current, dict) else type(current)}"
            )
            current = current[key]
            traversed.append(key)
        logger.info(f"✅ Nested path exists: {' -> '.join(path)}")
        return current

    # ──────────────────────────────────────────────────────────────
    # Numeric Assertions
    # ──────────────────────────────────────────────────────────────

    @keyword("Value Should Be Positive Number")
    def value_should_be_positive_number(self, value, field_name: str = "value"):
        """Assert *value* (string or numeric) is > 0."""
        try:
            num = float(value)
        except (TypeError, ValueError):
            raise AssertionError(
                f"'{field_name}' = '{value}' is not numeric."
            )
        assert num > 0, f"'{field_name}' = {num} is not positive (expected > 0)."
        logger.info(f"✅ '{field_name}' = {num} is positive.")

    @keyword("Value Should Be Non Negative Number")
    def value_should_be_non_negative_number(self, value, field_name: str = "value"):
        """Assert *value* is >= 0."""
        try:
            num = float(value)
        except (TypeError, ValueError):
            raise AssertionError(f"'{field_name}' = '{value}' is not numeric.")
        assert num >= 0, f"'{field_name}' = {num} is negative."
        logger.info(f"✅ '{field_name}' = {num} is non-negative.")

    @keyword("Value Should Be Within Range")
    def value_should_be_within_range(self, value, min_val, max_val, field_name: str = "value"):
        """Assert min_val <= value <= max_val."""
        num = float(value)
        lo, hi = float(min_val), float(max_val)
        assert lo <= num <= hi, (
            f"'{field_name}' = {num} is out of range [{lo}, {hi}]."
        )
        logger.info(f"✅ '{field_name}' = {num} is within [{lo}, {hi}].")

    @keyword("High Should Be Greater Than Or Equal To Low")
    def high_should_be_gte_low(self, high, low, pair: str = ""):
        """Assert high >= low for OHLC-style data."""
        h, l = float(high), float(low)
        assert h >= l, (
            f"High ({h}) is less than Low ({l}) for pair '{pair}'. "
            "Data integrity failure."
        )
        logger.info(f"✅ High ({h}) >= Low ({l}) for '{pair}'.")

    @keyword("Last Price Should Be Between High And Low")
    def last_price_should_be_between_high_and_low(self, last, high, low, pair: str = ""):
        """Assert low <= last <= high."""
        la, h, l = float(last), float(high), float(low)
        assert l <= la <= h, (
            f"Last price ({la}) is outside [Low={l}, High={h}] for '{pair}'."
        )
        logger.info(f"✅ Last ({la}) is between High ({h}) and Low ({l}) for '{pair}'.")

    @keyword("Ask Should Be Greater Than Or Equal To Bid")
    def ask_should_be_gte_bid(self, ask, bid, pair: str = ""):
        """Assert order-book ask >= bid (no crossed spread)."""
        a, b = float(ask), float(bid)
        assert a >= b, (
            f"Ask ({a}) < Bid ({b}) for '{pair}' — crossed spread detected!"
        )
        logger.info(f"✅ Ask ({a}) >= Bid ({b}) for '{pair}'.")

    # ──────────────────────────────────────────────────────────────
    # List / Array Assertions
    # ──────────────────────────────────────────────────────────────

    @keyword("List Should Not Be Empty")
    def list_should_not_be_empty(self, lst, field_name: str = "list"):
        """Assert list has at least one element."""
        assert isinstance(lst, list) and len(lst) > 0, (
            f"'{field_name}' is empty or not a list."
        )
        logger.info(f"✅ '{field_name}' has {len(lst)} items.")

    @keyword("List Length Should Be At Least")
    def list_length_should_be_at_least(self, lst, min_length: int, field_name: str = "list"):
        """Assert list has >= min_length elements."""
        assert isinstance(lst, list) and len(lst) >= int(min_length), (
            f"'{field_name}' length {len(lst)} < minimum {min_length}."
        )
        logger.info(f"✅ '{field_name}' length = {len(lst)} (>= {min_length}).")

    @keyword("Order Book Entry Should Have Valid Structure")
    def order_book_entry_should_have_valid_structure(self, entry, side: str = ""):
        """Each order book entry must be [price, volume] with numeric values."""
        assert isinstance(entry, list) and len(entry) == 2, (
            f"Order book {side} entry has invalid structure: {entry}. Expected [price, volume]."
        )
        for i, val in enumerate(entry):
            try:
                float(val)
            except (TypeError, ValueError):
                raise AssertionError(
                    f"Order book {side} entry index {i} is not numeric: '{val}'."
                )
        logger.info(f"✅ Order book {side} entry {entry} is valid.")

    # ──────────────────────────────────────────────────────────────
    # String / Format Assertions
    # ──────────────────────────────────────────────────────────────

    @keyword("Value Should Not Be Empty String")
    def value_should_not_be_empty_string(self, value, field_name: str = "field"):
        """Assert value is a non-empty string."""
        assert isinstance(value, str) and value.strip() != "", (
            f"'{field_name}' is empty or not a string: '{value}'."
        )
        logger.info(f"✅ '{field_name}' = '{value}' is non-empty string.")

    @keyword("Timestamp Should Be Recent")
    def timestamp_should_be_recent(self, timestamp, max_age_seconds: int = 300):
        """Assert Unix timestamp is within max_age_seconds of now."""
        ts = int(timestamp)
        now = int(time.time())
        diff = abs(now - ts)
        assert diff <= int(max_age_seconds), (
            f"Timestamp {ts} is {diff}s away from now ({now}). "
            f"Max allowed age: {max_age_seconds}s."
        )
        logger.info(f"✅ Timestamp {ts} is recent (diff={diff}s).")

    @keyword("Pair Name Should Match Convention")
    def pair_name_should_match_convention(self, pair_name: str):
        """Assert pair name is lowercase alphanumeric (e.g. btcidr, ethidr)."""
        pattern = r'^[a-z0-9]+$'
        assert re.match(pattern, pair_name), (
            f"Pair name '{pair_name}' does not match convention (lowercase alphanumeric)."
        )
        logger.info(f"✅ Pair name '{pair_name}' matches convention.")

    # ──────────────────────────────────────────────────────────────
    # Logging Utilities
    # ──────────────────────────────────────────────────────────────

    @keyword("Log Response Summary")
    def log_response_summary(self, response_json: dict, pair: str = "", endpoint: str = ""):
        """Log a human-readable summary of a response to the Robot report."""
        summary_lines = [
            f"{'='*60}",
            f"  Endpoint : {endpoint or 'N/A'}",
            f"  Pair     : {pair or 'N/A'}",
            f"  Timestamp: {datetime.now().isoformat()}",
            f"{'='*60}",
        ]
        if isinstance(response_json, dict):
            for k, v in list(response_json.items())[:10]:
                summary_lines.append(f"  {k}: {v}")
        logger.info("\n".join(summary_lines))

    @keyword("Log Pairs Count")
    def log_pairs_count(self, pairs_list: list):
        """Log total number of trading pairs returned."""
        count = len(pairs_list)
        logger.info(f"📊 Total trading pairs returned: {count}")
        return count

    @keyword("Extract Field From Response")
    def extract_field_from_response(self, response_json: dict, field: str):
        """Return value of *field* from response dict, with helpful error."""
        assert field in response_json, (
            f"Field '{field}' not found. Available: {list(response_json.keys())}"
        )
        value = response_json[field]
        logger.info(f"📌 Extracted '{field}' = '{value}'")
        return value
