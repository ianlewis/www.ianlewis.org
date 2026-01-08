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

"""Check if there are posts with recent publish dates."""

from __future__ import annotations

import argparse
import re
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

# Regex pattern for extracting date from front matter
DATE_PATTERN = re.compile(r"^date:\s*(.+)$")


def parse_post_date(post_file: Path) -> datetime | None:
    """Extract and parse the date from a Jekyll post's front matter."""
    try:
        with Path.open(post_file, "r", encoding="utf-8") as f:
            in_front_matter = False
            for line in f:
                # Check for front matter delimiters
                if line.strip() == "---":
                    if not in_front_matter:
                        in_front_matter = True
                        continue

                    # End of front matter
                    break

                if in_front_matter:
                    match = DATE_PATTERN.search(line)
                    if match:
                        date_str = match.group(1).strip()
                        # Remove quotes if present (both single and double)
                        date_str = date_str.strip("'\"")
                        # Parse the date string
                        # Jekyll supports various date formats, common one is:
                        # YYYY-MM-DD HH:MM:SS +/-TTTT
                        try:
                            # Try parsing with timezone
                            return datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S %z")
                        except ValueError:
                            try:
                                # Try without timezone (assume UTC)
                                dt = datetime.strptime(
                                    date_str,
                                    "%Y-%m-%d %H:%M:%S",
                                ).replace(tzinfo=timezone.utc)
                                return dt.replace(tzinfo=timezone.utc)
                            except ValueError:
                                try:
                                    # Try date only (assume midnight UTC)
                                    dt = datetime.strptime(
                                        date_str,
                                        "%Y-%m-%d",
                                    ).replace(tzinfo=timezone.utc)
                                    return dt.replace(tzinfo=timezone.utc)
                                except ValueError:
                                    print(  # noqa: T201
                                        f"Warning: Could not parse date '{date_str}'"
                                        f"in {post_file}",
                                        file=sys.stderr,
                                    )
                                    return None
    except (FileNotFoundError, PermissionError) as e:
        print(f"Warning: Error reading {post_file}: {e}", file=sys.stderr)  # noqa: T201
        return None

    return None


def find_recent_posts(
    post_dirs: list[Path],
    hours: int = 24,
) -> list[tuple[Path, datetime]]:
    """Find posts with publish dates within the last N hours.

    This checks if any posts have a publish date that falls between
    (now - N hours) and now. This is useful for scheduled deploys
    to only publish when there are posts that should now be visible.

    Note: Posts with future dates (beyond now) are automatically excluded
    by the upper bound check (post_date <= now).
    """
    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(hours=hours)
    recent_posts = []

    for post_dir in post_dirs:
        if not post_dir.exists():
            continue

        for post_file in post_dir.glob("*.md"):
            post_date = parse_post_date(post_file)
            # Check if post date is in the range [cutoff, now]
            # This excludes both old posts (before cutoff) and future posts (after now)
            if post_date and cutoff <= post_date <= now:
                recent_posts.append((post_file, post_date))

    return recent_posts


def main() -> None:
    """Check for posts with recent publish dates and exit with appropriate code."""
    parser = argparse.ArgumentParser(
        prog="check-recent-posts",
        description="Checks for recently published posts.",
    )
    parser.add_argument(
        "--hours",
        type=int,
        default=24,
        help="Number of hours to look back for recent posts (default: 24)",
    )
    parser.add_argument(
        "PATH",
        type=Path,
        nargs="+",
        help="Path(s) to search for posts.",
    )

    args = parser.parse_args()

    recent_posts = find_recent_posts(list(set(args.PATH)), args.hours)

    if recent_posts:
        print(  # noqa: T201
            f"Found {len(recent_posts)} post(s) with publish date(s) "
            f"within the last {args.hours} hours:",
        )
        for post_file, post_date in sorted(recent_posts, key=lambda x: x[1]):
            print(f"  - {post_file}: {post_date.isoformat()}")  # noqa: T201
        sys.exit(0)
    else:
        print(f"No posts found with publish dates within the last {args.hours} hours.")  # noqa: T201
        sys.exit(1)


if __name__ == "__main__":
    main()
