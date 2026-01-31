#!/usr/bin/env python3
# Copyright 2025 Ian Lewis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Check for chained redirects in netlify.toml."""

# ruff: noqa: T201

from __future__ import annotations

import fnmatch
import re
import sys
from pathlib import Path

# Maximum length of redirect chain to detect before considering it an infinite loop
MAX_CHAIN_LENGTH = 10

# Regex patterns for parsing redirect fields
FROM_PATTERN = r'from\s*=\s*"([^"]+)"'
TO_PATTERN = r'to\s*=\s*"([^"]+)"'


def parse_redirects(filename: str) -> dict[str, str]:
    """Parse netlify.toml and extract redirect mappings."""
    redirects = {}

    with Path.open(filename, "r", encoding="utf-8") as f:
        content = f.read()

    # Find all redirect blocks (supports both 'from' before 'to' and vice versa)
    # Split on redirect blocks and skip content before first block
    redirect_blocks = re.split(r"\[\[redirects\]\]", content)[1:]

    for block in redirect_blocks:
        # Extract from and to values regardless of order
        from_match = re.search(FROM_PATTERN, block)
        to_match = re.search(TO_PATTERN, block)

        if from_match and to_match:
            redirects[from_match.group(1)] = to_match.group(1)

    return redirects


def find_matching_redirect(path: str, redirects: dict[str, str]) -> str | None:
    """Find a redirect that matches the given path.

    Handles both exact matches and splat patterns (wildcards).
    Returns the target path if a match is found, None otherwise.
    """
    # First check for exact match
    if path in redirects:
        return redirects[path]

    # Check for splat pattern matches
    for from_path, to_path in redirects.items():
        if "*" in from_path:
            # Convert Netlify splat pattern to fnmatch pattern
            # Netlify uses /* for splats, fnmatch uses * for wildcards
            if fnmatch.fnmatch(path, from_path):
                return to_path
            # Also check if the path (potentially with trailing content) would match
            # e.g., "/foo/bar/" should match "/foo/bar/*"
            if from_path.endswith("/*"):
                prefix = from_path[:-1]  # Remove the trailing *
                if path.startswith(prefix) or path == prefix.rstrip("/"):
                    return to_path

    return None


def find_chains(redirects: dict[str, str]) -> list[tuple[str, list[str]]]:
    """Find redirect chains where a redirect target is itself redirected."""
    chains = []
    max_hops = 2  # Minimum hops to consider it a chain

    for from_path, to_path in redirects.items():
        chain = [from_path, to_path]
        current = to_path

        # Follow the chain
        while True:
            next_hop = find_matching_redirect(current, redirects)
            if next_hop is None:
                break
            chain.append(next_hop)
            current = next_hop

            # Prevent infinite loops
            if len(chain) > MAX_CHAIN_LENGTH:
                break

        # If we have a chain (more than 2 hops), record it
        if len(chain) > max_hops:
            chains.append((from_path, chain))

    return chains


def main() -> None:
    """Check for chained redirects and exit with error if any found."""
    repo_root = Path(__file__).parent.parent
    filename = repo_root / "netlify.toml"

    redirects = parse_redirects(str(filename))
    chains = find_chains(redirects)

    if chains:
        print(f"ERROR: Found {len(chains)} chained redirects:", file=sys.stderr)
        print("=" * 80, file=sys.stderr)
        for from_path, chain in chains:
            print(f"Chain starting from: {from_path}", file=sys.stderr)
            for i, path in enumerate(chain):
                prefix = "  -> " if i > 0 else "     "
                print(f"{prefix}{path}", file=sys.stderr)
        print("=" * 80, file=sys.stderr)
        print(
            "Please update these redirects to point directly to their final "
            "destination.",
            file=sys.stderr,
        )
        sys.exit(1)
    else:
        print(f"✓ No chained redirects found (total: {len(redirects)} redirects)")
        sys.exit(0)


if __name__ == "__main__":
    main()
