# Fraud Detection App with Social Media Monitoring

A Flutter mobile application with integrated search automation bot for monitoring social media platforms to detect potential fraud, scams, and misinformation.

## Features

### Mobile App Features
- Risk warning and alerts for known fraudulent activities
- Directory of wanted individuals involved in fraud
- Latest news and alerts about scams
- Information verification tools
- Social Media Monitoring via automation bots

### Automation Bot Features
- Automatically searches Facebook or YouTube for specified keywords
- Takes screenshots of search results
- Supports headless operation for server-side execution
- Exposes functionality through a REST API for mobile integration
- Saves screenshots with timestamps for easy reference

## Project Structure

```
frauddetection/
├── lib/                    # Flutter app source code
│   ├── backend/            # Backend services
│   │   └── services/       # API services including bot_service.dart
│   └── frontend/           # UI components
│       ├── models/         # Data models
│       └── screens/        # App screens including bot_screen.dart
├── server/                 # Python backend for bot automation
│   ├── bot_service.py      # Flask API service
│   ├── config.py           # Server configuration
│   └── Dockerfile          # Docker setup for server
├── bot_search_automation.py       # PyAutoGUI-based automation script
├── bot_search_automation_selenium.py  # Selenium-based automation script
└── requirements.txt        # Python dependencies
```

## Setup and Installation

### Mobile App (Flutter)

1. Install Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Clone this repository
3. Install dependencies:
```bash
flutter pub get
```
4. Run the app:
```bash
flutter run
```

### Automation Bot Server

#### Option 1: Local Development

1. Install Python 3.9+ from [python.org](https://www.python.org/downloads/)
2. Install the required libraries:
```bash
pip install -r requirements.txt
```
3. Run the Flask server:
```bash
cd server
python bot_service.py
```

#### Option 2: Docker Deployment

1. Install Docker and Docker Compose
2. Build and run the container:
```bash
docker-compose up --build
```

The server will be available at http://localhost:5000

## Usage

### Mobile App

1. Launch the app on your device
2. Navigate to the "Giám Sát MXH" (Social Media Monitor) section
3. Select a platform (Facebook or YouTube)
4. Enter keywords to search for
5. Tap "Start Bot" to begin monitoring
6. View results in the app as they become available

### Direct Bot Usage

Run the script from the command line with your desired parameters:

```bash
python bot_search_automation_selenium.py --platform facebook --keywords "keyword1" "keyword2" --scroll 2 --headless
```

#### Command Line Arguments

- `--platform`: Platform to search on (`facebook` or `youtube`) - default: `facebook`
- `--keywords`: Space-separated list of keywords to search for (required)
- `--search-delay`: Delay in seconds after searching before taking screenshot - default: `3`
- `--screenshot-delay`: Delay in seconds between searches - default: `2`
- `--scroll`: Number of times to scroll down for each search - default: `0`
- `--headless`: Run in headless mode (no browser UI)
- `--wait-login`: Time in seconds to wait for manual login - default: `15`

## Integration with Existing Projects

To integrate the social media monitoring bot with your own Flutter application:

1. Copy the server/ directory and Python bot files
2. Add the lib/backend/services/bot_service.dart file to your project
3. Create a UI for interacting with the bot service
4. Configure the API endpoint in bot_service.dart
5. Run the server as described in the setup section

## License

This project is licensed under the MIT License - see the LICENSE file for details.
