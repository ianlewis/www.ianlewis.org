package main

import (
	"testing"
)

var lexerTestCases = map[string]struct {
	input    string
	expected []lexeme
}{
	"empty": {
		input: "",
		expected: []lexeme{
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
	"text": {
		input: "some text\n\nanother paragraph",
		expected: []lexeme{
			{
				typ:  lexText,
				val:  "some text\n",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexText,
				val:  "\n",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexText,
				val:  "another paragraph",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
	"section": {
		input: "some text\n-----------",
		expected: []lexeme{
			{
				typ:  lexText,
				val:  "some text\n",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexSectionAdornment,
				val:  "-----------",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
	"link citation": {
		input: "[some link]",
		expected: []lexeme{
			{
				typ:  lexLinkText,
				val:  "some link",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
	"link with URL": {
		input: "[some link](http://www.google.com)",
		expected: []lexeme{
			{
				typ:  lexLinkText,
				val:  "some link",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexLinkURL,
				val:  "http://www.google.com",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
	"comment": {
		input: ".. this is a comment",
		expected: []lexeme{
			{
				typ:  lexComment,
				val:  "this is a comment",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
	"directive no args no opt no body": {
		input: ".. funcname::\n",
		expected: []lexeme{
			{
				typ:  lexDirectiveName,
				val:  "funcname",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
	"directive args only": {
		input: ".. funcname:: arg1 arg2\n",
		expected: []lexeme{
			{
				typ:  lexDirectiveName,
				val:  "funcname",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveArg,
				val:  "arg1",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveArg,
				val:  "arg2",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
	"directive args opts only": {
		input: ".. funcname:: arg1 arg2\n    :key1: key1 val\n    :key2: key2 val\n",
		expected: []lexeme{
			{
				typ:  lexDirectiveName,
				val:  "funcname",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveArg,
				val:  "arg1",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveArg,
				val:  "arg2",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveOptName,
				val:  "key1",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveOptVal,
				val:  "key1 val",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveOptName,
				val:  "key2",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveOptVal,
				val:  "key2 val",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
	"directive": {
		input: ".. funcname:: arg1 arg2\n    :key1: key1 val\n    :key2: key2 val\n\n    this is the body\n    this is more body",
		expected: []lexeme{
			{
				typ:  lexDirectiveName,
				val:  "funcname",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveArg,
				val:  "arg1",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveArg,
				val:  "arg2",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveOptName,
				val:  "key1",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveOptVal,
				val:  "key1 val",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveOptName,
				val:  "key2",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveOptVal,
				val:  "key2 val",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexDirectiveBody,
				val:  "    this is the body\n    this is more body",
				opts: map[int]interface{}{},
			},
			{
				typ:  lexEOF,
				val:  "",
				opts: map[int]interface{}{},
			},
		},
	},
}

func collect(ch chan lexeme) []lexeme {
	var lexemes []lexeme
	for l := range ch {
		lexemes = append(lexemes, l)
	}
	return lexemes
}

func equal(i1, i2 []lexeme) bool {
	if len(i1) != len(i2) {
		return false
	}
	for k := range i1 {
		if i1[k].typ != i2[k].typ {
			return false
		}
		if i1[k].val != i2[k].val {
			return false
		}
	}
	return true
}

func TestLexer(t *testing.T) {
	for name, tc := range lexerTestCases {
		tc := tc
		t.Run(name, func(t *testing.T) {
			l := newLexer(tc.input)
			defer l.drain()
			if got, want := collect(l.output), tc.expected; !equal(got, want) {
				t.Errorf("%s: got\n\t%+v\nexpected\n\t%v", name, got, want)
			}
		})
	}
}

/*
func TestLexer(t *testing.T) {
	cases := map[string]struct {
		input  []byte
		output []byte
	}{
		"code-block": {
			input: []byte(`begin

.. code-block:: golang

    func main() {
        fmt.Println("Hello World")
    }

end`),
			output: []byte(`begin

` + "```" + `golang
func main() {
    fmt.Println("Hello World")
}
` + "```" + `

end`),
		},
		"code-block eof": {
			input: []byte(`begin

.. code-block:: golang

    func main() {
        fmt.Println("Hello World")
    }
`),
			output: []byte(`begin

` + "```" + `golang
func main() {
    fmt.Println("Hello World")
}
` + "```" + `

`),
		},

		"code-block blank lines": {
			input: []byte(`begin

.. code-block:: golang

    func main() {
        fmt.Println("Hello World")

        fmt.Println("Hello World")
    }

end`),
			output: []byte(`begin

` + "```" + `golang
func main() {
    fmt.Println("Hello World")

    fmt.Println("Hello World")
}
` + "```" + `

end`),
		},
		"sourcecode": {
			input: []byte(`begin

.. sourcecode:: golang

    func main() {
        fmt.Println("Hello World")
    }

end`),
			output: []byte(`begin

` + "```" + `golang
func main() {
    fmt.Println("Hello World")
}
` + "```" + `

end`),
		},
		"note": {
			input: []byte(`begin

.. note::

    this is a
    multi-line note

end`),
			output: []byte(`begin

> this is a
> multi-line note

end`),
		},
	}

	for name, tc := range cases {
		tc := tc
		t.Run(name, func(t *testing.T) {
			if out := lex(tc.input); bytes.Compare(out, tc.output) != 0 {
				t.Fatalf("want:\n%q\n\ngot:\n%q\n", string(tc.output), string(out))
			}
		})
	}
}
*/
