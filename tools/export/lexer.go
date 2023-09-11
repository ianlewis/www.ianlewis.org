package main

import (
	"fmt"
	"io"
	"reflect"
	"runtime"
	"unicode/utf8"
)

type stateFn func(*lexer) stateFn

func (f stateFn) String() string {
	return runtime.FuncForPC(reflect.ValueOf(f).Pointer()).Name()
}

type lexemeType int

const (
	lexError lexemeType = iota
	lexEOF

	lexSectionAdornment // A heading underline bar

	lexLinkText
	lexLinkURL

	lexComment // An rst comment

	lexDirectiveName    // An rst directive name
	lexDirectiveArg     // An rst directive argument
	lexDirectiveOptName // An rst directive option name
	lexDirectiveOptVal  // An rst directive option value
	lexDirectiveBody    // An rst directive body

	lexText // plain text
)

const (
	lexoptHeadingLvl = iota
)

type lexeme struct {
	typ  lexemeType
	val  string
	opts map[int]interface{}
}

func (i lexeme) String() string {
	switch i.typ {
	case lexEOF:
		return "EOF"
	case lexError:
		return i.val
	}
	if len(i.val) > 10 {
		return fmt.Sprintf("%.10q...", i.val)
	}
	return fmt.Sprintf("%q", i.val)
}

func newLexer(input string) *lexer {
	l := lexer{
		input:  input,
		output: make(chan lexeme, 25),
	}
	go l.run()
	return &l
}

type lexer struct {
	input  string
	start  int
	pos    int
	closed bool
	output chan lexeme
}

func (l *lexer) run() {
	for state := stateText; state != nil; {
		state = state(l)
	}
	l.emit(lexEOF)
	l.closed = true
	close(l.output)
}

func (l *lexer) next() (rune, error) {
	if l.pos >= len(l.input) {
		return 0, io.EOF
	}

	r, width := utf8.DecodeRuneInString(l.input[l.pos:])
	l.pos += width
	return r, nil
}

func (l *lexer) peek() (rune, error) {
	r, err := l.next()
	if err != nil {
		return 0, err
	}
	l.backup()
	return r, nil
}

func (l *lexer) skipWhitespace() error {
	defer l.ignore()
	for {
		r, err := l.next()
		if err != nil {
			return err
		}
		if r != ' ' && r != '\t' {
			l.backup()
			return nil
		}
	}
}

func (l *lexer) thisLexeme(typ lexemeType) lexeme {
	i := lexeme{
		typ:  typ,
		val:  l.input[l.start:l.pos],
		opts: map[int]interface{}{},
	}
	l.start = l.pos
	return i
}

func (l *lexer) emitLexeme(i lexeme) {
	l.output <- i
}

func (l *lexer) emit(typ lexemeType) {
	l.emitLexeme(l.thisLexeme(typ))
}

func (l *lexer) emitNonEmpty(typ lexemeType) {
	i := l.thisLexeme(typ)
	if len(i.val) > 0 {
		l.emitLexeme(i)
	}
}

func (l *lexer) ignore() {
	l.start = l.pos
}

func (l *lexer) backup() {
	if !l.closed && l.pos > 0 {
		_, w := utf8.DecodeLastRuneInString(l.input[:l.pos])
		l.pos -= w
	}
}

func (l *lexer) drain() {
	for range l.output {
	}
}
