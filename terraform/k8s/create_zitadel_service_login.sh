#!/usr/bin/env bash
# Create a per-app ZITADEL service account for headless auth (register users +
# email-code login + OIDC finalize), print its key and usage instructions.
#
#   ./create_zitadel_service_login.sh <service_name>
#
# Roles granted: IAM_LOGIN_CLIENT (Session API + OIDC auth-request finalize)
#                ORG_USER_MANAGER (create/verify end-users in the default org)
#
# Auth: uses an existing admin service-account key (default ~/.zitadel/terraform-key.json)
# to mint a token and create the new account. Deps: bash, curl, openssl, python3 (stdlib).
#
# Config via env (all optional except the arg):
#   ZITADEL_URL         default https://zitadel.iconicompany.com
#   ZITADEL_ADMIN_KEY   default ~/.zitadel/terraform-key.json   (must be IAM_OWNER)
#   ZITADEL_KEY_OUT     default ./.zitadel/<service>-key.json
#   ZITADEL_RESOLVE_IP  optional, e.g. 212.22.94.191 (adds curl --resolve if DNS is flaky)
#   ZITADEL_ORG_ROLES   default ORG_USER_MANAGER
#   ZITADEL_IAM_ROLES   default IAM_LOGIN_CLIENT
set -euo pipefail

SERVICE="${1:-}"
if [ -z "$SERVICE" ]; then echo "usage: $0 <service_name>" >&2; exit 1; fi

ZITADEL_URL="${ZITADEL_URL:-https://zitadel.iconicompany.com}"
ADMIN_KEY="${ZITADEL_ADMIN_KEY:-$HOME/.zitadel/terraform-key.json}"
KEY_OUT="${ZITADEL_KEY_OUT:-./.zitadel/${SERVICE}-key.json}"
RESOLVE_IP="${ZITADEL_RESOLVE_IP:-}"
ORG_ROLES="${ZITADEL_ORG_ROLES:-ORG_USER_MANAGER}"
IAM_ROLES="${ZITADEL_IAM_ROLES:-IAM_LOGIN_CLIENT}"

for c in curl openssl python3; do command -v "$c" >/dev/null || { echo "missing dependency: $c" >&2; exit 1; }; done
[ -f "$ADMIN_KEY" ] || { echo "admin key not found: $ADMIN_KEY" >&2; exit 1; }

HOST="$(printf '%s' "$ZITADEL_URL" | sed -E 's#^https?://([^/:]+).*#\1#')"
CURL=(curl -sS --max-time 30)
[ -n "$RESOLVE_IP" ] && CURL+=(--resolve "$HOST:443:$RESOLVE_IP")

jget() { python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('$1',''))"; }
b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }

# --- 1. mint admin token (JWT profile) -------------------------------------
KID="$(python3 -c "import json;print(json.load(open('$ADMIN_KEY'))['keyId'])")"
SUB="$(python3 -c "import json;print(json.load(open('$ADMIN_KEY'))['userId'])")"
NOW="$(date +%s)"
HDR="$(printf '{"alg":"RS256","kid":"%s","typ":"JWT"}' "$KID" | b64url)"
PL="$(printf '{"iss":"%s","sub":"%s","aud":"%s","iat":%s,"exp":%s}' "$SUB" "$SUB" "$ZITADEL_URL" "$NOW" "$((NOW+300))" | b64url)"
SIG="$(printf '%s.%s' "$HDR" "$PL" | openssl dgst -sha256 -sign <(python3 -c "import json;print(json.load(open('$ADMIN_KEY'))['key'])") -binary | b64url)"
TOKEN="$("${CURL[@]}" -X POST "$ZITADEL_URL/oauth/v2/token" \
  -d grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer \
  -d "assertion=$HDR.$PL.$SIG" \
  -d "scope=openid urn:zitadel:iam:org:project:id:zitadel:aud" | jget access_token)"
[ -n "$TOKEN" ] || { echo "failed to obtain admin token (check ZITADEL_ADMIN_KEY / connectivity)" >&2; exit 1; }
AUTH=(-H "Authorization: Bearer $TOKEN" -H "content-type: application/json")

# --- 2. create machine user -------------------------------------------------
RESP="$("${CURL[@]}" "${AUTH[@]}" -X POST "$ZITADEL_URL/management/v1/users/machine" \
  -d "{\"userName\":\"$SERVICE\",\"name\":\"$SERVICE service account\",\"description\":\"Headless auth service account for $SERVICE\"}")"
USER_ID="$(printf '%s' "$RESP" | jget userId)"
[ -n "$USER_ID" ] || { echo "create machine user failed: $RESP" >&2; exit 1; }
echo "created service user '$SERVICE' (userId=$USER_ID)"

# --- 3. grant org + instance roles -----------------------------------------
ORG_JSON="$(python3 -c "import json,sys;print(json.dumps({'userId':sys.argv[1],'roles':sys.argv[2].split(',')}))" "$USER_ID" "$ORG_ROLES")"
IAM_JSON="$(python3 -c "import json,sys;print(json.dumps({'userId':sys.argv[1],'roles':sys.argv[2].split(',')}))" "$USER_ID" "$IAM_ROLES")"
"${CURL[@]}" "${AUTH[@]}" -X POST "$ZITADEL_URL/management/v1/orgs/me/members" -d "$ORG_JSON" >/dev/null && echo "granted org roles: $ORG_ROLES"
"${CURL[@]}" "${AUTH[@]}" -X POST "$ZITADEL_URL/admin/v1/members" -d "$IAM_JSON" >/dev/null && echo "granted instance roles: $IAM_ROLES"

# --- 4. create JSON key, save to file --------------------------------------
RESP="$("${CURL[@]}" "${AUTH[@]}" -X POST "$ZITADEL_URL/management/v1/users/$USER_ID/keys" -d '{"type":"KEY_TYPE_JSON"}')"
mkdir -p "$(dirname "$KEY_OUT")"
printf '%s' "$RESP" | python3 -c "import sys,json,base64;d=json.load(sys.stdin);open('$KEY_OUT','wb').write(base64.b64decode(d['keyDetails']))"
chmod 600 "$KEY_OUT"

# --- 5. instructions --------------------------------------------------------
cat <<EOF

================================================================================
 ZITADEL service account '$SERVICE' is ready.
================================================================================
 Key file : $KEY_OUT   (chmod 600 — gitignore it, never commit)
 Base URL : $ZITADEL_URL
 Roles    : $ORG_ROLES (register/verify users) + $IAM_ROLES (sessions + OIDC finalize)

 1) Get a service access token (JWT profile):
    POST $ZITADEL_URL/oauth/v2/token
      grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer
      assertion=<RS256 JWT: iss=sub=key.userId, aud=$ZITADEL_URL, kid=key.keyId>
      scope=openid urn:zitadel:iam:org:project:id:zitadel:aud
    -> use access_token as 'Authorization: Bearer ...' below.

 2) Register an end-user:
    POST /v2/users/human   {"username":"u@x.com","profile":{...},
                            "email":{"email":"u@x.com","sendCode":{}}}   # returnCode:{} = code in response
    POST /v2/users/{userId}/email/verify   {"verificationCode":"<code>"}
    POST /v2/users/{userId}/otp_email      {}      # enable email-code factor

 3) Login by email code (Session API):
    POST  /v2/sessions  {"checks":{"user":{"loginName":"u@x.com"}},
                         "challenges":{"otpEmail":{"sendCode":{}}}}      # -> sessionId, sessionToken
    PATCH /v2/sessions/{sessionId}  {"sessionToken":"..",
                         "checks":{"otpEmail":{"code":"<code>"}}}        # -> authenticated (no password)

 4) Tokens: use the session directly, OR finalize an OIDC auth request for the
    app's own OIDC client (POST /v2/oidc/auth_requests/{id} {"session":{...}}).

 Full TS example & notes: see baas/docs/auth-zitadel.md
================================================================================
EOF
