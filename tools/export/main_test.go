package main

import (
	"bytes"
	"testing"
)

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
