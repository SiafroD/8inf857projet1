#!/usr/bin/env python3
"""
Injecte de faux logs réseau dans Elasticsearch pour tester Kibana
en attendant que syslog-ng soit branché.

Usage : python3 generate_fake_logs.py
Aucune dépendance externe (stdlib uniquement).
"""

import json
import random
import urllib.request
from datetime import datetime, timedelta, timezone

ES_URL = "http://localhost:9200"
INDEX = "logs-network-test"     # renomme si tu veux, ex. le même nom que syslog-ng utilisera

N_PER_SCENARIO = 20             # nb de faux logs par scénario
HOURS_SPAN = 6                  # étale les logs sur les X dernières heures


def random_ip(private=True):
    if private:
        return f"192.168.1.{random.randint(2, 250)}"
    return f"{random.randint(1,223)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}"


SCENARIOS = [
    {
        "name": "web_exploit_attempt",
        "message": lambda: f'GET /index.php?exploit=1 HTTP/1.1" 200 {random.randint(500,5000)}',
        "classification": "Attempted Administrator Privilege Gain",
        "priority": 1,
        "status_code": 200,
    },
    {
        "name": "port_scan",
        "message": lambda: f"SCAN detected: {random.randint(20,60)} ports probed in 10s",
        "classification": "Detection of a Network Scan",
        "priority": 2,
        "status_code": None,
    },
    {
        "name": "ssh_bruteforce",
        "message": lambda: f"Failed password for admin from {random_ip(False)} port {random.randint(1024,65000)} ssh2",
        "classification": "Attempted Login Brute Force",
        "priority": 1,
        "status_code": None,
    },
    {
        "name": "sql_injection",
        "message": lambda: f"GET /login.php?user=admin' OR '1'='1 HTTP/1.1\" 500 {random.randint(200,900)}",
        "classification": "Web Application Attack",
        "priority": 1,
        "status_code": 500,
    },
    {
        "name": "data_exfiltration",
        "message": lambda: f"Large outbound transfer: {random.randint(50,900)}MB to external host",
        "classification": "Potential Data Leak",
        "priority": 2,
        "status_code": None,
    },
]


def make_doc(scenario, ts):
    doc = {
        "@timestamp": ts.isoformat(),
        "event": {"scenario": scenario["name"]},
        "source": {"ip": random_ip()},
        "destination": {"ip": random_ip()},
        "snort": {
            "classification": scenario["classification"],
            "priority": scenario["priority"],
        },
        "message": scenario["message"](),
    }
    if scenario["status_code"] is not None:
        doc["http"] = {"response": {"status_code": scenario["status_code"]}}
    return doc


def bulk_insert(docs):
    lines = []
    for doc in docs:
        lines.append(json.dumps({"create": {"_index": INDEX}}))
        lines.append(json.dumps(doc))
    payload = ("\n".join(lines) + "\n").encode("utf-8")

    req = urllib.request.Request(
        f"{ES_URL}/_bulk",
        data=payload,
        headers={"Content-Type": "application/x-ndjson"},
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        result = json.loads(resp.read())
        if result.get("errors"):
            print("⚠️  Certaines insertions ont échoué :")
            for item in result["items"]:
                err = item["index"].get("error")
                if err:
                    print(" -", err)
        else:
            print(f"✅ {len(docs)} faux logs insérés dans l'index '{INDEX}'.")


def main():
    now = datetime.now(timezone.utc)
    docs = []
    for scenario in SCENARIOS:
        for _ in range(N_PER_SCENARIO):
            ts = now - timedelta(seconds=random.randint(0, HOURS_SPAN * 3600))
            docs.append(make_doc(scenario, ts))
    random.shuffle(docs)
    bulk_insert(docs)


if __name__ == "__main__":
    main()