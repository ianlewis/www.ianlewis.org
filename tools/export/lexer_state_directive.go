package main

import (
	"strings"
)

func stateDots(l *lexer) stateFn {
	// Ignore ".."
	l.next()
	l.next()
	l.ignore()

	// Ignore next whitespace.
	if err := l.skipWhitespace(); err != nil {
		return nil
	}

	for {
		r, err := l.next()
		if err != nil {
			l.emitNonEmpty(lexComment)
			return nil
		}

		if r == '\n' {
			l.emitNonEmpty(lexComment)
			return stateText
		}

		// TODO: implement footnotes && citations
		// TODO: Do I need to implement auto-numbered footnotes?
		// https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html#footnotes

		if strings.HasPrefix(l.input[l.pos:], "::") {
			l.emitNonEmpty(lexDirectiveName)
			return stateDirectiveColon
		}
	}
}

func stateDirectiveColon(l *lexer) stateFn {
	// Ignore ".."
	l.next()
	l.next()
	l.ignore()

	// Ignore next whitespace.
	if err := l.skipWhitespace(); err != nil {
		return nil
	}

	return stateDirectiveArg
}

func stateDirectiveArg(l *lexer) stateFn {
	for {
		r, err := l.next()
		if err != nil {
			l.emitNonEmpty(lexDirectiveArg)
			return nil
		}

		if r == ' ' {
			// Don't include the space.
			l.backup()
			l.emitNonEmpty(lexDirectiveArg)

			// Ignore next whitespace.
			if err := l.skipWhitespace(); err != nil {
				return nil
			}

			return stateDirectiveArg
		}

		if r == '\n' {
			// Don't include the newline.
			l.backup()
			l.emitNonEmpty(lexDirectiveArg)

			// Skip the newline.
			l.next()
			l.ignore()

			return stateDirectiveOptBody
		}
	}
}

func stateDirectiveOptBody(l *lexer) stateFn {
	for {
		r, err := l.next()
		if err != nil {
			return nil
		}
		if r == '\n' {
			l.ignore()
			return stateDirectiveBody
		}
		if r == ' ' || r == '\t' {
			// We should be able to safely ignore this.
			l.ignore()
			continue
		}
		if r == ':' {
			l.backup()
			l.ignore()
			return stateDirectiveOpt
		}

		// unexpected character
		l.emit(lexError)
		return nil
	}
}

func stateDirectiveOpt(l *lexer) stateFn {
	// Skip ':'
	l.next()
	l.ignore()

	for {
		r, err := l.next()
		if err != nil {
			return nil
		}
		if r == ':' {
			l.backup()
			l.emitNonEmpty(lexDirectiveOptName)

			// Skip ':'
			l.next()
			l.ignore()

			return stateDirectiveOptVal
		}
		if r == '\n' {
			l.emit(lexError)
			return nil
		}
	}
}

func stateDirectiveOptVal(l *lexer) stateFn {
	// Ignore next whitespace.
	if err := l.skipWhitespace(); err != nil {
		return nil
	}
	for {
		r, err := l.next()
		if err != nil {
			return nil
		}
		if r == '\n' {
			l.backup()
			l.emitNonEmpty(lexDirectiveOptVal)

			// Skip '\n'
			l.next()
			l.ignore()

			return stateDirectiveOptBody
		}
	}
}

func stateDirectiveBody(l *lexer) stateFn {
	// Find indent.
	for {
		// Start of a new line.
		r, err := l.next()
		if err != nil {
			l.emitNonEmpty(lexDirectiveBody)
			return nil
		}

		if r == '\n' {
			l.emitNonEmpty(lexDirectiveBody)
			return stateText
		}

		for {
			r, err := l.next()
			if err != nil {
				l.emitNonEmpty(lexDirectiveBody)
				return nil
			}
			if r == '\n' {
				break
			}
		}
	}
}
