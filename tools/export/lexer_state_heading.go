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

func stateHeading(l *lexer) stateFn {
	r, _ := l.next()

	for {
		// TODO: Handle links
		n, err := l.next()
		if err != nil {
			l.emitNonEmpty(lexSectionAdornment)
			return nil
		}

		if n != r {
			l.emitNonEmpty(lexText)
			return stateText
		}

		if n == '\n' {
			l.emitNonEmpty(lexSectionAdornment)
			return stateText
		}
	}
}
