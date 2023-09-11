package main

var headingChars = []rune{
	'=', '-', '`', ':', '\'', '"', '~', '^', '_', '*', '+', '#', '<', '>',
}

func isHeadingPunc(r rune) bool {
	for _, h := range headingChars {
		if r == h {
			return true
		}
	}
	return false
}

// TODO: ignore document titles (section adornment on top and bottom)

func stateHeading(l *lexer) stateFn {
	r, _ := l.next()

	for {
		n, err := l.next()
		if err != nil {
			l.emitNonEmpty(lexSectionAdornment)
			return nil
		}

		if n != r {
			if r == '`' {
				// Maybe this is a link?
				l.backup()
				l.backup()
				l.emitNonEmpty(lexText)
				return stateLinkText
			}
			l.emitNonEmpty(lexText)
			return stateText
		}

		if n == '\n' {
			l.emitNonEmpty(lexSectionAdornment)
			return stateText
		}
	}
}
