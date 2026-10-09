#!/usr/bin/env python3
"""
Génère de faux logs (5 types d'attaque + trafic normal) et les envoie dans Elasticsearch.

Usage : python3 generate_fake_logs.py
Aucune dépendance externe.
"""

import json
import random
import urllib.request
from datetime import datetime, timedelta, timezone

ES_URL = "http://localhost:9200"
INDEX = "logs-network-test"
HOURS = 6            # les logs sont répartis au hasard sur les X dernières heures
N_PER_ATTACK = 20    # nombre de logs par type d'attaque
N_NORMAL = 300       # nombre de logs de trafic normal


def ip():
    return f"192.168.1.{random.randint(2, 250)}"


def external_ip():
    return f"{random.randint(1, 223)}.{random.randint(0, 255)}.{random.randint(0, 255)}.{random.randint(1, 254)}"


# Attaques : nom -> (message, classification Snort, priorité, code HTTP ou None)
ATTACKS = {
    "web_exploit_attempt": (
        lambda: f'GET /index.php?exploit=1 HTTP/1.1" 200 {random.randint(500, 5000)}',
        "Attempted Administrator Privilege Gain", 1, 200),
    "port_scan": (
        lambda: f"SCAN detected: {random.randint(20, 60)} ports probed in 10s",
        "Detection of a Network Scan", 2, None),
    "ssh_bruteforce": (
        lambda: f"Failed password for admin from {external_ip()} port {random.randint(1024, 65000)} ssh2",
        "Attempted Login Brute Force", 1, None),
    "sql_injection": (
        lambda: f"GET /login.php?user=admin' OR '1'='1 HTTP/1.1\" 500 {random.randint(200, 900)}",
        "Web Application Attack", 1, 500),
    "data_exfiltration": (
        lambda: f"Large outbound transfer: {random.randint(50, 900)}MB to external host",
        "Potential Data Leak", 2, None),
}

# Trafic normal : nom -> (message, code HTTP ou None, IP de destination)
NORMAL = {
    "normal_web": (
        lambda: f'GET /index.html HTTP/1.1" 200 {random.randint(300, 20000)}',
        200, "192.168.1.200"),
    "normal_ssh": (
        lambda: f"Accepted publickey for deploy from {ip()} port {random.randint(1024, 65000)} ssh2",
        None, "192.168.1.10"),
    "normal_dns": (
        lambda: "DNS query for example.com (A) answered NOERROR",
        None, "192.168.1.1"),
    "normal_backup": (
        lambda: f"Backup transfer: {random.randint(1, 30)}MB to internal backup server",
        None, "192.168.1.50"),
}


def make_doc(name, kind, message, status, classification=None, priority=None, dest=None):
    seconds_ago = random.randint(0, HOURS * 3600)
    doc = {
        "@timestamp": (datetime.now(timezone.utc) - timedelta(seconds=seconds_ago)).isoformat(),
        "event": {"scenario": name, "kind": kind},
        "source": {"ip": ip()},
        "destination": {"ip": dest or ip()},
        "message": message,
    }
    if classification:
        doc["snort"] = {"classification": classification, "priority": priority}
    if status:
        doc["http"] = {"response": {"status_code": status}}
    return doc


def send(docs):
    lines = []
    for d in docs:
        lines.append(json.dumps({"create": {"_index": INDEX}}))
        lines.append(json.dumps(d))
    req = urllib.request.Request(
        f"{ES_URL}/_bulk",
        data=("\n".join(lines) + "\n").encode("utf-8"),
        headers={"Content-Type": "application/x-ndjson"},
        method="POST",
    )
    result = json.loads(urllib.request.urlopen(req).read())
    if result["errors"]:
        errors = [i["create"]["error"] for i in result["items"] if "error" in i["create"]]
        print(f"{len(errors)} erreurs, par exemple : {errors[0]}")
    else:
        print(f"{len(docs)} logs envoyés dans '{INDEX}'.")


def main():
    docs = []

    for name, (message, classification, priority, status) in ATTACKS.items():
        for _ in range(N_PER_ATTACK):
            docs.append(make_doc(name, "alert", message(), status, classification, priority))

    for _ in range(N_NORMAL):
        name = random.choice(list(NORMAL))
        message, status, dest = NORMAL[name]
        docs.append(make_doc(name, "event", message(), status, dest=dest))

    random.shuffle(docs)
    send(docs)


if __name__ == "__main__":
    main()