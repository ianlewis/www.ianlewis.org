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

import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple


def parse_redirects(filename: str) -> Dict[str, str]:
    """Parse netlify.toml and extract redirect mappings."""
    redirects = {}

    with open(filename, "r") as f:
        content = f.read()

    # Find all redirect blocks
    pattern = r'\[\[redirects\]\]\s+from\s*=\s*"([^"]+)"\s+to\s*=\s*"([^"]+)"'
    matches = re.findall(pattern, content)

    for from_path, to_path in matches:
        redirects[from_path] = to_path

    return redirects


def find_chains(redirects: Dict[str, str]) -> List[Tuple[str, List[str]]]:
    """Find redirect chains where a redirect target is itself redirected."""
    chains = []

    for from_path, to_path in redirects.items():
        chain = [from_path, to_path]
        current = to_path

        # Follow the chain
        while current in redirects:
            next_hop = redirects[current]
            chain.append(next_hop)
            current = next_hop

            # Prevent infinite loops
            if len(chain) > 10:
                break

        # If we have a chain (more than 2 hops), record it
        if len(chain) > 2:
            chains.append((from_path, chain))

    return chains


def main():
    """Check for chained redirects and exit with error if any found."""
    repo_root = Path(__file__).parent.parent
    filename = repo_root / "netlify.toml"

    redirects = parse_redirects(str(filename))
    chains = find_chains(redirects)

    if chains:
        print(f"ERROR: Found {len(chains)} chained redirects:", file=sys.stderr)
        print("=" * 80, file=sys.stderr)
        for from_path, chain in chains:
            print(f"\nChain starting from: {from_path}", file=sys.stderr)
            for i, path in enumerate(chain):
                prefix = "  -> " if i > 0 else "     "
                print(f"{prefix}{path}", file=sys.stderr)
        print("\n" + "=" * 80, file=sys.stderr)
        print(
            "\nPlease update these redirects to point directly to their final destination.",
            file=sys.stderr,
        )
        sys.exit(1)
    else:
        print(f"✓ No chained redirects found (total: {len(redirects)} redirects)")
        sys.exit(0)


if __name__ == "__main__":
    main()
