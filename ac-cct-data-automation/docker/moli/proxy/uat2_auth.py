"""Adds the uat2 Basic-auth header, and only for uat2.aircanada.com.

Moli cannot answer an HTTP auth challenge, so the proxy does it. Only uat2 is decrypted (allow_hosts in the
compose file); every other host is tunnelled untouched, so the login never reaches ad or tracking sites.
UAT2_USER / UAT2_PASS come from the environment and are never logged.
"""
import base64
import os

from mitmproxy import http

HOST = "uat2.aircanada.com"
_TOKEN = base64.b64encode(f"{os.environ['UAT2_USER']}:{os.environ['UAT2_PASS']}".encode()).decode()


def request(flow: http.HTTPFlow) -> None:
    if flow.request.pretty_host == HOST:
        flow.request.headers["Authorization"] = f"Basic {_TOKEN}"
