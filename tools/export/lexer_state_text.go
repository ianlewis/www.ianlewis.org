package main

import (
	"strings"
)

func stateText(l *lexer) stateFn {
	// Start of a new line
	if strings.HasPrefix(l.input[l.pos:], "..") {
		return stateDots
	}

	r, err := l.peek()
	if err != nil {
		return nil
	}
	if isHeadingPunc(r) {
		return stateHeading
	}

	for {
		// TODO: Handle links
		n, err := l.next()
		if err != nil {
			l.emitNonEmpty(lexText)
			return nil
		}

		if n == '\n' {
			l.emitNonEmpty(lexText)
			return stateText
		}
	}
}
