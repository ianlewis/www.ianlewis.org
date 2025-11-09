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

"""Check if there are posts with publish dates within the last 24 hours."""

import re
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import List, Tuple

# Regex pattern for extracting date from front matter
DATE_PATTERN = r'^date:\s*(.+)$'


def parse_post_date(post_file: Path) -> datetime | None:
    """Extract and parse the date from a Jekyll post's front matter."""
    try:
        with open(post_file, 'r', encoding='utf-8') as f:
            in_front_matter = False
            for line in f:
                # Check for front matter delimiters
                if line.strip() == '---':
                    if not in_front_matter:
                        in_front_matter = True
                        continue
                    else:
                        # End of front matter
                        break
                
                if in_front_matter:
                    match = re.match(DATE_PATTERN, line, re.MULTILINE)
                    if match:
                        date_str = match.group(1).strip()
                        # Remove quotes if present
                        date_str = date_str.strip('"').strip("'")
                        # Parse the date string
                        # Jekyll supports various date formats, common one is:
                        # "YYYY-MM-DD HH:MM:SS +/-TTTT"
                        try:
                            # Try parsing with timezone
                            return datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S %z')
                        except ValueError:
                            try:
                                # Try without timezone (assume UTC)
                                dt = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
                                return dt.replace(tzinfo=timezone.utc)
                            except ValueError:
                                try:
                                    # Try date only (assume midnight UTC)
                                    dt = datetime.strptime(date_str, '%Y-%m-%d')
                                    return dt.replace(tzinfo=timezone.utc)
                                except ValueError:
                                    print(f"Warning: Could not parse date '{date_str}' in {post_file}", file=sys.stderr)
                                    return None
    except Exception as e:
        print(f"Warning: Error reading {post_file}: {e}", file=sys.stderr)
        return None
    
    return None


def find_recent_posts(repo_root: Path, hours: int = 24) -> List[Tuple[Path, datetime]]:
    """Find posts with publish dates within the last N hours."""
    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(hours=hours)
    recent_posts = []
    
    # Check all posts in en, jp, and til directories
    post_dirs = [
        repo_root / 'en' / '_posts',
        repo_root / 'jp' / '_posts',
        repo_root / 'til' / '_posts',
    ]
    
    for post_dir in post_dirs:
        if not post_dir.exists():
            continue
        
        for post_file in post_dir.glob('*.md'):
            post_date = parse_post_date(post_file)
            if post_date:
                # Check if the post date is in the past but within the last N hours
                if cutoff <= post_date <= now:
                    recent_posts.append((post_file, post_date))
    
    return recent_posts


def main():
    """Check for posts with recent publish dates and exit with appropriate code."""
    repo_root = Path(__file__).parent.parent
    
    # Default to 24 hours, but can be overridden via command line
    hours = 24
    if len(sys.argv) > 1:
        try:
            hours = int(sys.argv[1])
        except ValueError:
            print(f"Error: Invalid hours argument '{sys.argv[1]}'", file=sys.stderr)
            sys.exit(2)
    
    recent_posts = find_recent_posts(repo_root, hours)
    
    if recent_posts:
        print(f"Found {len(recent_posts)} post(s) with publish date(s) within the last {hours} hours:")
        for post_file, post_date in sorted(recent_posts, key=lambda x: x[1]):
            relative_path = post_file.relative_to(repo_root)
            print(f"  - {relative_path}: {post_date.isoformat()}")
        sys.exit(0)
    else:
        print(f"No posts found with publish dates within the last {hours} hours.")
        sys.exit(1)


if __name__ == '__main__':
    main()
