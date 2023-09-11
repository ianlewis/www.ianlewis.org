package main

import (
	"strings"
)

func stateLinkText(l *lexer) stateFn {
	for {
		n, err := l.next()
		if err != nil {
			l.emitNonEmpty(lexText)
			return nil
		}

		if n == '\n' {
			l.emitNonEmpty(lexText)
			return stateText
		}

		if n == ']' {
			i := l.thisLexeme(lexLinkText)
			i.val = strings.Trim(i.val, "[]")
			l.emitLexeme(i)

			r, err := l.peek()
			if err != nil {
				return nil
			}
			if r == '(' {
				return stateLinkURL
			}
			return stateText
		}
	}
}

func stateLinkURL(l *lexer) stateFn {
	for {
		n, err := l.next()
		if err != nil {
			l.emitNonEmpty(lexText)
			return nil
		}

		if n == '\n' {
			l.emitNonEmpty(lexText)
			return stateText
		}

		if n == ')' {
			i := l.thisLexeme(lexLinkURL)
			i.val = strings.Trim(i.val, "()")
			l.emitLexeme(i)
			return stateText
		}
	}
}
