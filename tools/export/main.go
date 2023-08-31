package main

import (
	"bytes"
	"context"
	"database/sql"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

// Check checks the error and panics if not nil.
func Check(err error) {
	if err != nil {
		panic(err)
	}
}

// CheckVal checks the error and panics if not nil.
func CheckVal[T any](val T, err error) T {
	if err != nil {
		panic(err)
	}
	return val
}

func newMySQL(addr, dbName, user, password string) (*sql.DB, error) {
	db, err := sql.Open("mysql", mySQLDSN(addr, dbName, user, password, nil))
	if err != nil {
		return nil, fmt.Errorf("failed connecting to MySQL: %v", err)
	}
	db.SetConnMaxLifetime(10 * time.Second)
	db.SetMaxIdleConns(0)

	return db, nil
}

// mySQLDSN returns a formatted DNS for connecting to MySQL
func mySQLDSN(mysqlAddr, mysqlDB, mysqlUser, mysqlPassword string, options map[string]string) string {
	user := mysqlUser
	if mysqlPassword != "" {
		user += ":" + mysqlPassword
	}
	parameters := map[string]string{
		"charset":      "utf8",
		"loc":          "UTC",
		"parseTime":    "true",
		"timeout":      "5s",
		"readTimeout":  "1s",
		"writeTimeout": "5s",
	}
	for k, v := range options {
		parameters[k] = v
	}

	var params []string
	for k, v := range parameters {
		params = append(params, k+"="+v)
	}

	return fmt.Sprintf("%s@tcp(%s)/%s?%s", user, mysqlAddr, mysqlDB, strings.Join(params, "&"))
}

func main() {
	fs := flag.NewFlagSet("root", flag.ContinueOnError)
	mysqlAddr := fs.String("mysql-addr", "127.0.0.1:3306", "The mysql server address.")
	mysqlUser := fs.String("mysql-user", "homepage", "The mysql username.")
	mysqlPassword := fs.String("mysql-password", "", "The mysql password.")
	mysqlDB := fs.String("mysql-database", "homepage", "The mysql database name.")

	if err := fs.Parse(os.Args[1:]); err != nil {
		os.Exit(1)
	}

	args := fs.Args()
	baseDir := "."
	if len(args) > 0 {
		baseDir = args[0]
	}

	db := CheckVal(newMySQL(*mysqlAddr, *mysqlDB, *mysqlUser, *mysqlPassword))

	ctx := context.Background()
	posts := CheckVal(getPosts(ctx, db))

	for _, p := range posts {
		p.Content = strings.Replace(p.Content, "\r\n", "\n", -1)

		if p.MarkupType == "rst" {
			// Convert posts to markdown
			fmt.Println("lexing...")
			p.Content = string(lex([]byte(p.Content)))
		}

		filePath := filepath.Join(baseDir, p.Locale, "_posts", p.PubDate.Format("2006-01-02")+"-"+p.Slug+".md")
		f := CheckVal(os.Create(filePath))

		// Add FrontMatter
		fmt.Fprint(f, "---\n")
		fmt.Fprint(f, "layout: post\n")
		fmt.Fprintf(f, "title: %q\n", p.Title)
		fmt.Fprintf(f, "date: %s\n", p.PubDate.Format("2006-01-02 15:04:05 +0000"))
		fmt.Fprintf(f, "permalink: /%s/%s\n", p.Locale, p.Slug)
		fmt.Fprintf(f, "blog: %s\n", p.Locale)
		fmt.Fprint(f, "---\n")
		fmt.Fprint(f, "\n")

		// Print the post content
		fmt.Fprint(f, p.Content)
	}
}

// BlogPost is a blog post
type BlogPost struct {
	ID         int64
	Slug       string
	Title      string
	Lead       *string
	Content    string
	MarkupType string
	Locale     string
	Tags       []string
	PubDate    *time.Time
	CreateDate *time.Time
	UpdateDate *time.Time
}

func getPosts(ctx context.Context, db *sql.DB) ([]*BlogPost, error) {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()

	q := `SELECT
		id,
		slug,
		title,
		` + "`lead`" + `,
		content,
		markup_type,
		locale,
		pub_date,
		create_date,
		update_date
	from blog_post
    WHERE active = true;`

	rows, err := tx.QueryContext(ctx, q)
	if err != nil {
		return nil, err
	}

	var posts []*BlogPost
	for rows.Next() {
		select {
		case <-ctx.Done():
			return nil, ctx.Err()
		default:
		}
		var p BlogPost
		if err := rows.Scan(
			&p.ID,
			&p.Slug,
			&p.Title,
			&p.Lead,
			&p.Content,
			&p.MarkupType,
			&p.Locale,
			&p.PubDate,
			&p.CreateDate,
			&p.UpdateDate,
		); err != nil {
			return nil, err
		}
		posts = append(posts, &p)
	}

	return posts, err
}

func lex(input []byte) []byte {
	l := lexer{
		input:  input,
		output: make(chan byte),
	}
	go l.run()
	var output []byte
	for b := range l.output {
		output = append(output, b)
	}
	return output
}

type lexer struct {
	input  []byte
	pos    int
	output chan byte
}

func (l *lexer) run() {
	for state := stateText; state != nil; {
		state = state(l)
	}
	close(l.output)
}

func (l *lexer) next() (byte, error) {
	if l.pos >= len(l.input) {
		return 0, io.EOF
	}
	b := l.input[l.pos]
	l.pos++
	return b, nil
}

func (l *lexer) peek() (byte, error) {
	if l.pos >= len(l.input) {
		return 0, io.EOF
	}
	return l.input[l.pos], nil
}

func (l *lexer) emit(b []byte) {
	for i := range b {
		l.output <- b[i]
	}
}

func (l *lexer) backup() {
	if l.pos > 0 {
		l.pos--
	}
}

type stateFn func(*lexer) stateFn

var (
	codeBlock   = []byte(".. code-block::")
	sourceBlock = []byte(".. sourcecode::")
	noteBlock   = []byte(".. note::")
)

func stateText(l *lexer) stateFn {
	for {
		if l.pos+len(codeBlock) < len(l.input) && bytes.Compare(l.input[l.pos:l.pos+len(codeBlock)], codeBlock) == 0 {
			l.pos += len(codeBlock)
			return stateCodeBlock
		}

		if l.pos+len(sourceBlock) < len(l.input) && bytes.Compare(l.input[l.pos:l.pos+len(sourceBlock)], sourceBlock) == 0 {
			l.pos += len(sourceBlock)
			return stateCodeBlock
		}

		if l.pos+len(noteBlock) < len(l.input) && bytes.Compare(l.input[l.pos:l.pos+len(noteBlock)], noteBlock) == 0 {
			l.pos += len(noteBlock)
			return stateNoteBlock
		}

		b, err := l.next()
		if err != nil {
			return nil
		}
		l.emit([]byte{b})
	}
}

func stateLink(l *lexer) stateFn {
	// TODO: parse links
	return stateText
}

func stateCodeBlock(l *lexer) stateFn {
	// Read the language.
	var lang []byte

	// Read off the spaces between the code-block def and language.
	for {
		next, err := l.next()
		if err != nil {
			return nil
		}
		if next == byte(' ') {
			continue
		}
		if next == byte('\n') {
			break
		}
		lang = append(lang, next)
		break
	}

	// Read off the rest of the language name.
	for {
		next, err := l.next()
		if err != nil {
			return nil
		}
		if next == byte('\n') {
			break
		}
		lang = append(lang, next)
	}

	// Read off starting blank lines
	var blockIndent int
	for {
		next, err := l.next()
		if err != nil {
			return nil
		}
		if next == byte('\n') {
			// Discard any blank lines.
			blockIndent = 0
			continue
		}
		if next == byte(' ') || next == byte('\t') {
			blockIndent++
			continue
		}

		// Encountered a normal character.
		l.backup()
		break
	}

	l.emit([]byte("```"))
	l.emit(lang)
	l.emit([]byte("\n"))

	defer l.emit([]byte("```\n\n"))

	// Consume the rest of the code-block.
	indent := blockIndent
	var buf []byte
	var lines [][]byte
	for {
		next, err := l.next()
		if err != nil {
			return nil
		}
		if next == byte('\n') {
			lines = append(lines, buf)
			if len(buf) != 0 {
				for i := range lines {
					l.emit(lines[i])
					l.emit([]byte("\n"))
				}
				lines = nil
			}
			buf = nil
			indent = 0
			continue
		}
		if len(buf) == 0 {
			if next == byte(' ') || next == byte('\t') {
				if indent < blockIndent {
					indent++
					continue
				}
				buf = append(buf, next)
				continue
			} else if indent != blockIndent {
				l.backup()
				break
			}
		}

		buf = append(buf, next)
	}

	return stateText
}

func stateNoteBlock(l *lexer) stateFn {
	// TODO: handle note blocks
	l.emit(noteBlock)
	return stateText
}
