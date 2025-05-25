---
layout: post
title: "Flask で LDAP でパスワード変更アプリを作る"
date: 2011-07-08 13:06:23 +0000
permalink: /jp/flask-ldapchangepw
blog: jp
tags: python flask ldap python_ldap
render_with_liquid: false
locale: ja
---

この間、会社で少し大きくなって、利用するツールが少し増えつつありますので、
ユーザー管理を統一するために、LDAPサーバーを使うようになりました。

思ったより面倒だったんですが、LDAPを使うと色なサービスで同じ ユーザー名とパスワードが使えるので便利です。今のところ、 Redmine
サーバー、 Wiki、社内ライブラリのリポジトリーサーバー などに使っています。

ただし、LDAPは同じユーザー名とパスワードが使えますが、ユーザーが 自分でパスワードを変更させるには何か用意しないといけません。
というわけで、Flask のLDAPパスワード変更アプリを作ってみた。

Flask は Python で当然ながら、WSGI に普通に対応していますので、 かなり便利です。

さって、どうやるのか。 Python プロジェクトなので、当然ながら、
[virtualenv](/jp/virtualenv-pip-fabric) を使います。仮想環境に `Flask` と
`python-ldap` をインストールします。

`Flask` はミニフレームワークで、 データベース、フォーム処理の機能を 持っていませんので、 `wtforms` も使います。

`python-ldap` をインストールするには、 `OpenLDAP` のクライアントライブラリの ヘッダーファイルが必要です。

```text
$ # OpenLDAP のクライアントライブラリをインストール
$ apt-get install libldap2-dev libsasl2-dev ...
$ mkvirtualenv ldapchangepw ... (ldapchangepw)
$ pip install Flask wtforms python-ldap
... Successfully installed Flask Werkzeug ... wtforms python-ldap
Cleaning up...
```

インストールした後にアプリケーションを開発していきます。アプリケーションを 全部一つの Python ファイル
`ldapchangepw.py` に書き込みます。

まずは、Flask のアプリケーションインスタンスを用意します。

```python
# (略
from flask import Flask

DEBUG = True
LDAP_USE_LDAPS=False
LDAP_HOST='localhost'
LDAP_PORT=389

app = Flask(__name__)

# このモジュールからデフォールト設定を搭載する。
app.config.from_object(__name__)

# FLASK_SETTINGSの環境変数にファイルパスを設定すると、
# アプリケーション設定を外部ファイルからでも搭載できる # ようにしておく。設定していなかったら、無視
app.config.from_envvar('FLASK_SETTINGS', silent=True)
```

次に、リクエストが来る時に、LDAPへのコネクションを用意します。ここで Flask のグローバルスレッドローカルオブジェクト g
を使います。g
はリクエスト以外のリクエストデータを突っ込む場所と考えばいいです。リクエストが終われば、Flaskはこのオブジェクトを毎回クリアするので使うのが他のグローバルオブジェクトに突っ込むより割と安心です。

```python
# (略
import ldap from flask import g

# ...

def connect_ldap():
    return ldap.initialize("%s://%s:%s" % (
        'ldaps' if app.config['LDAP_USE_LDAPS'] else 'ldap',
        app.config['LDAP_HOST'],
        app.config['LDAP_PORT'], ))

@app.before_request
def before_request():
    g.ldap = connect_ldap()

@app.after_request
def after_request(response):
    g.ldap.unbind() return response
```

次はパスワード変更フォームを作ります。`wtforms`はここだけに使うので、このライブラリを使うのがどうかなと思いますが、やっぱりパスワード変更でセキュリティの面があるから予想外の入力バグを防ぐために導入しました。

```python
# (略
import wtforms
from wtforms import validators

# ...

class PasswordChangeForm(wtforms.Form):
    username = wtforms.TextField(u'ユーザ名',
        [validators.Required(message=u'ユーザ名を入力してください')])
    oldpassword = wtforms.PasswordField(u'現在のパスワード',
        [validators.Required(message=u'現在のパスワードを入力してください')])
    password = wtforms.PasswordField(u'パスワード',
        [validators.Required(message=u'パスワードを入力してください')])
    password2 = wtforms.PasswordField(u'パスワード確認',
        [validators.EqualTo('password',
             message=u'パスワードと確認用パスワードは一致しません。')])
```

次はパスワード変更ロジックを実装します。まずはフォームを表示する部分を実装します。ここでFlaskの`render_template`関数を使って Jinja2 テンプレートをレンダーします。

```python
# (略
from flask import render_template

# ...

@app.route('/', methods=['GET', 'POST'])
def index():
    form = PasswordChangeForm(request.form)
    if request.method == 'POST':
        # ...
    return render_template('index.html', form=form)
```

次はフォームのPOSTデータを受け取って、検証してからLDAPのパスワード変更を行います。

```python
# (略
import ldap
from flask import request, flash, g

# ...

if form.validate():
    # Find user
    try:
        # LDAP ユーザーを検索
        search_results = g.ldap.search_s(
            app.config['LDAP_BASEDN'],
            ldap.SCOPE_SUBTREE,
            app.config['LDAP_SEARCH_FILTER'],
            [app.config['LDAP_LOGIN_FIELD']],
        )
    except ldap.LDAPError,e:
        search_results=[]
        if not isinstance(e, ldap.NO_SUCH_OBJECT):
            raise

    # config で設定したログインフィールドでユーザーを探る
    user_dn = None
    for dn, data in search_results:
        field = data.get(app.config['LDAP_LOGIN_FIELD'])
        if not isinstance(field, list):
            field = [field]
        for item in field:
            if item == request.form['username']:
                user_dn = dn
                break
    if user_dn:
        changed=False
        try:
            # ユーザーとしてログインする。
            # LDAP サーバーでユーザーは自分のパスワードを変更できるように設定しないといけません
            g.ldap.simple_bind_s(user_dn, request.form['oldpassword'])

            # パスワード変更を行う
            result_code, result = g.ldap.passwd_s(user_dn, None, request.form['password'])
            if result_code == ldap.RES_EXTENDED:
                changed=True

        except ldap.LDAPError,e:
            # ...
```

合わせてこんな感じです。

```python
# (略
import ldap
from flask import request, render_template, flash, g

# ...

@app.route('/', methods=['GET', 'POST'])
def index():
    form = PasswordChangeForm(request.form)
    if request.method == 'POST':
        if form.validate():
            # Find user
            try:
                # LDAP ユーザーを検索
                search_results = g.ldap.search_s(
                    app.config['LDAP_BASEDN'],
                    ldap.SCOPE_SUBTREE,
                    app.config['LDAP_SEARCH_FILTER'],
                    [app.config['LDAP_LOGIN_FIELD']],
                )
            except ldap.LDAPError,e:
                search_results=[]
                if not isinstance(e, ldap.NO_SUCH_OBJECT):
                    raise

            # ログインフィールドでユーザーを探る
            user_dn = None
            for dn, data in search_results:
                field = data.get(app.config['LDAP_LOGIN_FIELD'])
                if not isinstance(field, list):
                    field = [field]
                for item in field:
                    if item == request.form['username']:
                        user_dn = dn
                        break
            if user_dn:
                changed=False
                try:
                    # ユーザーとしてログインする。
                    # LDAP サーバーでユーザーは自分のパスワードを変更できるように設定しないといけません
                    g.ldap.simple_bind_s(user_dn, request.form['oldpassword'])

                    # パスワード変更を行う
                    result_code, result = g.ldap.passwd_s(user_dn, None, request.form['password'])
                    if result_code == ldap.RES_EXTENDED:
                        changed=True

                except ldap.LDAPError,e:
                    if isinstance(e, ldap.INVALID_CREDENTIALS):
                        app.logger.warning(e, {
                            'type': 'password_mismatch',
                            'username': request.form.get('username'),
                            'user_agent': str(request.user_agent),
                            'route': list(request.access_route),
                        })
                    if isinstance(e, ldap.UNWILLING_TO_PERFORM):
                        app.logger.error(e, {
                            'type': 'permission_denied',
                            'username': request.form.get('username'),
                            'user_agent': str(request.user_agent),
                            'route': list(request.access_route),
                        })

                if changed:
                    flash(u"パスワード変更しました！ 反映するまで少し時間かかりますので、ご承知ください。", "info")
                    app.logger.info("success", {
                        'type': 'success',
                        'username': request.form.get('username'),
                        'user_agent': str(request.user_agent),
                        'route': list(request.access_route),
                    })
                else:
                    flash(u"ユーザー名かパスワードは誤りがあります。", "error")

            else:
                flash(u"ユーザー名かパスワードは誤りがあります。", "error")
                app.logger.warning("warning", {
                    'type': 'user_not_found',
                    'username': request.form.get('username'),
                    'user_agent': str(request.user_agent),
                    'route': list(request.access_route),
                })
    return render_template('index.html', form=form)
```

最後に、パスワード変更はセキュリティ的に危ないことなので、しっかりログをとります。 後でプログラムで解析できるようにJSON形式で保存します。

```python
#========= Logging ================

class SafeJSONEncoder(simplejson.JSONEncoder):
    """
    日付などをエンコードできる JSONEncoder
    """
    def default(self, o):
        if isinstance(o, (datetime.datetime, datetime.date, datetime.time)):
            return o.isoformat()
        elif isinstance(o, decimal.Decimal):
            return int(o) if o % 1 == 0 else float(str(o))
        else:
            return super(SafeJSONEncoder, self).default(o)

class JSONFormatter(logging.Formatter):
    """
    ログメッセージを JSON にする Formatter
    """
    def format(self, record):
        return "%s %s %s" % (
            time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(record.created)), # 19 chars
            ("[%s]" % record.levelname).rjust(9), # 9 chars
            simplejson.dumps({
                "msg": record.msg if isinstance(record.msg, basestring) else repr(record.msg),
                "levelname": record.levelname,
                "args": record.args,
                "created": record.created,
            }), #msg starts at pos #30
        )

if not app.debug:
    app.logger.setLevel(logging.INFO)

    # 本番ログイング
    if app.config['LOG_FILE']:
        # ログファイルのローテーション設定
        from logging.handlers import RotatingFileHandler
        handler = RotatingFileHandler(
            app.config['LOG_FILE'],
            maxBytes=app.config['LOG_BACKUP_SIZE'],
            backupCount=app.config['LOG_BACKUP_COUNT']
        )
        handler.setFormatter(JSONFormatter())
        handler.setLevel(logging.INFO)
        app.logger.addHandler(handler)

        @app.after_request
        def flush_log(response):
            handler.flush()
            return response

    # エラーログをメールで管理者に飛ばす
    if (app.config['SMTP_HOST'] and app.config['SMTP_PORT'] and
            app.config['SERVER_EMAIL'] and app.config['ADMIN_MAIL']):
        mail_handler = logging.SMTPHandler(
            "%s:%s" % (app.config['SMTP_HOST'], app.config['SMTP_PORT']),
            app.config['SERVER_EMAIL'],
            app.config['ADMIN_MAIL'],
            '[ldapchangepw] Error'
        )
        mail_handler.setLevel(logging.ERROR)
        app.logger.addHandler(mail_handler)
else:
    app.logger.handlers[0].setFormatter(JSONFormatter())
```

もちろん、ウェブアプリのベストプラクティスが適用されるので、HTTPSを使ったりしないといけませんが、
このアプリで割と安心ユーザーにでLDAPパスワードを変更させられます。コードはBitbucketにアップしているので、是非ご覧ください。

[`https://bitbucket.org/beproud/ldapchangepw/overview`](https://bitbucket.org/beproud/ldapchangepw/overview)
