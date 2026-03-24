#!/usr/bin/env python3
# Copyright 2026 Ian Lewis
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

"""Check if this is a special date."""

from __future__ import annotations

import argparse
import sys
from datetime import datetime, timezone
from pathlib import Path

import yaml


def get_special_dates(profile_path: Path, current_year: int) -> list[datetime]:
    """Extract special dates from the profile.yaml file."""
    with profile_path.open("r", encoding="utf-8") as f:
        profile_data = yaml.safe_load(f)
        special_profiles = profile_data.get("special", [])

        special_dates: list[datetime] = []
        for profile in special_profiles:
            # add start and end dates to the list of special dates
            start_date_str = profile.get("start")
            end_date_str = profile.get("end")

            # NOTE: We need to include the current year in the date string to parse it
            #       correctly, since the profile.yaml file only contains month and day
            #       (MM-DD). Parsing without the year in Python is ambiguous and can
            #       lead to incorrect results, due to leap years etc.
            if start_date_str:
                special_dates.append(
                    datetime.strptime(
                        f"{current_year}-{start_date_str}",
                        "%Y-%m-%d",
                    ).replace(
                        tzinfo=timezone.utc,
                    ),
                )
            if end_date_str:
                special_dates.append(
                    datetime.strptime(
                        f"{current_year}-{end_date_str}",
                        "%Y-%m-%d",
                    ).replace(
                        tzinfo=timezone.utc,
                    ),
                )

        return special_dates


def main() -> None:
    """Check if the current date is a special date."""
    parser = argparse.ArgumentParser(
        prog="check-special-dates",
        description=(
            "Check whether a given date matches any special dates "
            "defined in profile.yaml."
        ),
    )
    parser.add_argument(
        "--date",
        type=lambda s: datetime.strptime(s, "%Y-%m-%d").replace(
            tzinfo=timezone.utc,
        ),
        default=datetime.now(timezone.utc),
        help="The current date to check against the special dates (default: now)",
    )
    parser.add_argument(
        "PATH",
        type=Path,
        help="Path to the profile.yaml file to check for special dates",
    )

    args = parser.parse_args()

    special_dates = get_special_dates(args.PATH, current_year=args.date.year)

    for special_date in special_dates:
        if args.date.month == special_date.month and args.date.day == special_date.day:
            print(f"Today ({args.date.strftime('%Y-%m-%d')}) is a special date!")  # noqa: T201
            sys.exit(0)

    print(f"Today ({args.date.strftime('%Y-%m-%d')}) is not a special date.")  # noqa: T201
    sys.exit(1)


if __name__ == "__main__":
    main()
