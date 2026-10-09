# Run the app in Chrome against the dev backend:  .\tool\run_web_dev.ps1
#
# Build settings come from config/dev.json (copy config/dev.example.json; not committed):
# API_BASE_URL, and FACEBOOK_APP_ID / FACEBOOK_CLIENT_TOKEN for Instagram / Facebook sign-in.
# Without the file only the API address is set.
#
# Port 5000 is fixed on purpose: the dev API allows browser calls from http://localhost:<port>,
# and YouTube sign-in needs http://localhost:5000/oauth/youtube listed as an authorized
# redirect URI on the Google OAuth web client. Extra arguments go to `flutter run`.
param(
    [int]$Port = 5000,
    [string]$Api = "https://api.dev.xeasify.com"
)
$config = Join-Path $PSScriptRoot "..\config\dev.json"
if (Test-Path $config) {
    flutter run -d chrome --web-port $Port --dart-define-from-file=$config @args
} else {
    Write-Host "config/dev.json not found: Instagram / Facebook sign-in will be disabled."
    flutter run -d chrome --web-port $Port --dart-define=API_BASE_URL=$Api @args
}
