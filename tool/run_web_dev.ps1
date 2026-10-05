# Run the app in Chrome against the dev backend:  .\tool\run_web_dev.ps1
#
# Port 5000 is fixed on purpose: the dev API allows browser calls from http://localhost:<port>,
# and YouTube sign-in needs http://localhost:5000/oauth/youtube listed as an authorized
# redirect URI on the Google OAuth web client. Extra arguments go to `flutter run`.
param(
    [int]$Port = 5000,
    [string]$Api = "https://api.dev.xeasify.com"
)
flutter run -d chrome --web-port $Port --dart-define=API_BASE_URL=$Api @args
