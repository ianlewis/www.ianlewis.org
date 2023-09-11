package main

import (
	"strings"
)

func stateLinkText(l *lexer) stateFn {
	// TODO: Do I need to implement other kinds of backtick markup?

	// Ignore the first backtick.
	_, err := l.next()
	if err != nil {
		return nil
	}

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

		if n == '<' {
			// TODO: check if there is a prior space character.
			l.backup()
			i := l.thisLexeme(lexLinkText)
			i.val = strings.Trim(i.val, "` ")
			l.emitLexeme(i)
			return stateLinkURL
		}

		if n == '`' {
			l.backup()
			i := l.thisLexeme(lexLinkText)
			i.val = strings.Trim(i.val, "`")
			l.emitLexeme(i)

			return stateLinkEnd
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

		if n == '>' {
			i := l.thisLexeme(lexLinkURL)
			i.val = strings.Trim(i.val, "<>")
			l.emitLexeme(i)
			return stateLinkEnd
		}
	}
}

func stateLinkEnd(l *lexer) stateFn {
	r, err := l.next()
	if err != nil {
		return nil
	}

	if r != '`' {
		l.emit(lexError)
		return nil
	}

	r2, err := l.next()
	if err != nil {
		return nil
	}
	if r2 != '_' {
		l.emit(lexError)
		return nil
	}

	l.ignore()
	return stateText
}
