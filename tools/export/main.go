package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
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
			// TODO: use new lexer
			// p.Content = string(lex([]byte(p.Content)))
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
