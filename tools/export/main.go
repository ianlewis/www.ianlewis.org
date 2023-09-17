package main

import (
	"bytes"
	"context"
	"database/sql"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
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

func pandocConvert(content, from, to string) (string, error) {
	cmd := exec.Command("pandoc", "-f", from, "-t", to, "-")
	var out bytes.Buffer
	cmd.Stdout = &out

	stdin, err := cmd.StdinPipe()
	if err != nil {
		return "", err
	}
	defer stdin.Close()

	if err := cmd.Start(); err != nil {
		return "", err
	}

	io.WriteString(stdin, content)
	stdin.Close()
	if err := cmd.Wait(); err != nil {
		return "", err
	}

	return out.String(), nil
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
		filePath := filepath.Join(baseDir, p.Locale, "_posts", p.PubDate.Format("2006-01-02")+"-"+p.Slug+".md")
		fmt.Println(filePath)

		// Replace windows newlines with unix newlines.
		p.Content = strings.Replace(p.Content, "\r\n", "\n", -1)

		if p.MarkupType == "rst" {
			// Replace sourcecode directives.
			p.Content = strings.Replace(p.Content, ".. sourcecode::", ".. code-block::", -1)
			content, err := pandocConvert(p.Content, "rst", "commonmark")
			if err != nil {
				panic(err)
			}
			p.Content = content
		}

		f := CheckVal(os.Create(filePath))

		// Add FrontMatter
		fmt.Fprint(f, "---\n")
		fmt.Fprint(f, "layout: post\n")
		fmt.Fprintf(f, "title: %q\n", p.Title)
		fmt.Fprintf(f, "date: %s\n", p.PubDate.Format("2006-01-02 15:04:05 +0000"))
		fmt.Fprintf(f, "permalink: /%s/%s\n", p.Locale, p.Slug)
		fmt.Fprintf(f, "blog: %s\n", p.Locale)
		if len(p.Tags) > 0 {
			fmt.Fprintf(f, "tags: %s\n", strings.Join(p.Tags, " "))
		}
		fmt.Fprint(f, "render_with_liquid: false\n")
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
	FROM
		blog_post
    WHERE
		active = true;`

	rows, err := tx.QueryContext(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

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

	rows.Close()

	for _, p := range posts {
		tags, err := getTags(ctx, tx, p.ID)
		if err != nil {
			return nil, fmt.Errorf("gettings tags for %d: %w", p.ID, err)
		}
		p.Tags = tags
	}

	return posts, err
}

func getTags(ctx context.Context, tx *sql.Tx, id int64) ([]string, error) {
	q := `SELECT 
		blog_tag.name
	FROM
		blog_post
	INNER JOIN
 		blog_post_tags
	ON
		blog_post_tags.post_id = blog_post.id
	INNER JOIN
		blog_tag
	ON
		blog_post_tags.tag_id = blog_tag.id
	WHERE
			blog_post.active = true
		AND
			blog_post.id = ?`

	rows, err := tx.QueryContext(ctx, q, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tags []string
	for rows.Next() {
		select {
		case <-ctx.Done():
			return nil, ctx.Err()
		default:
		}
		var tag string
		if err := rows.Scan(&tag); err != nil {
			return nil, err
		}
		tags = append(tags, tag)
	}

	return tags, nil
}
