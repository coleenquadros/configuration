{{
"access": "proxy",
"editable": false,
"jsonData": {{
    "tlsSkipVerify": {tlsSkipVerify},
    "httpHeaderName1": "Authorization"
}},
"name": "{name}",
"orgId": 1,
"secureJsonData": {{
    "httpHeaderValue1": "Bearer {{{{{{ vault('app-sre/creds/kube-configs/{cluster}', 'token') }}}}}}"
}},
"type": "prometheus",
"url": "{url}",
"version": 1
}}
