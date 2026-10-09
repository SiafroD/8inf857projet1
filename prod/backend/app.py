"""Boréal Outillage — the shop's small backend: a DB-backed login and product
search. Every request is logged to syslog-ng, so the login and the search box
become log sources the SOC can watch.

The queries are parameterised, so the app is not itself injectable: an injection
attempt is recorded (the payload shows in the log), not executed. The lab is
about detecting the attempt, not about being vulnerable.
"""
import logging
import logging.handlers
import os
import time

import psycopg
from flask import Flask, jsonify, request
from werkzeug.security import check_password_hash, generate_password_hash

DSN = "host=db dbname=shop user=app password=app_pw"

log = logging.getLogger("backend")
log.setLevel(logging.INFO)
# <PRI>backend: <msg> — syslog-ng reads "backend" as the program name (measured).
syslog = logging.handlers.SysLogHandler(address=(os.environ.get("SYSLOG_HOST", "syslog-ng"), 514))
syslog.ident = "backend: "
log.addHandler(syslog)
log.addHandler(logging.StreamHandler())  # also to stdout, for `podman logs`


def db():
    return psycopg.connect(DSN)


def client_ip():
    # nginx has already put the real client address in X-Forwarded-For.
    return request.headers.get("X-Forwarded-For", request.remote_addr)


def seed():
    # The one account the login scenario targets. admin / azerty123: weak on
    # purpose. Idempotent, so a restart does not fail.
    for attempt in range(30):
        try:
            with db() as c:
                c.execute(
                    "INSERT INTO users (username, pw_hash) VALUES (%s, %s) "
                    "ON CONFLICT (username) DO NOTHING",
                    ("admin", generate_password_hash("azerty123")),
                )
            return
        except psycopg.OperationalError:
            time.sleep(2)
    raise SystemExit("database never came up")


app = Flask(__name__)


@app.get("/api/health")
def health():
    return {"ok": True}


@app.post("/api/login")
def login():
    auth = request.authorization
    if auth:
        user, password = auth.username, auth.password
    else:
        user, password = request.form.get("u"), request.form.get("p")
    with db() as c:
        row = c.execute("SELECT pw_hash FROM users WHERE username = %s", (user,)).fetchone()
    if row and check_password_hash(row[0], password or ""):
        log.info("login success for %s from %s", user, client_ip())
        return {"ok": True}
    log.warning("login failed for %r from %s", user, client_ip())
    return {"ok": False}, 403


@app.get("/api/search")
def search():
    q = request.args.get("q", "")
    log.info("search %r from %s", q, client_ip())
    with db() as c:
        rows = c.execute(
            "SELECT name, price FROM products WHERE name ILIKE %s ORDER BY name",
            (f"%{q}%",),
        ).fetchall()
    return jsonify([{"name": n, "price": float(p)} for n, p in rows])


if __name__ == "__main__":
    seed()
    # ponytail: Flask's own server, fine for a lab; a real deploy would use gunicorn.
    app.run(host="0.0.0.0", port=8000)
