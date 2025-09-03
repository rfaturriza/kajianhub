# Automated Release Notes with Google Gemini AI

This Fastfile has been enhanced to automatically generate release notes using Google Gemini AI, which offers a generous free tier.

## Features

- 🤖 **AI-Generated Release Notes**: Uses Google Gemini AI to analyze git commits and generate user-friendly release notes
- 📝 **Smart Commit Analysis**: Automatically fetches commits since the last tag
- 🔄 **Fallback System**: Uses default release notes if API is unavailable
- 🆓 **Free Service**: Gemini AI offers generous free tier (15 requests per minute)

## Setup

### 1. Get Gemini API Key (Free)

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key

### 2. Set Environment Variable

```bash
# Temporary (current session only)
export GEMINI_API_KEY='your-api-key-here'

# Permanent (add to ~/.zshrc)
echo 'export GEMINI_API_KEY="your-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

### 3. Quick Setup Script

```bash
./setup_gemini.sh
```

## Usage

### Test Release Notes Generation

```bash
cd ios
SKIP_SETUP=true bundle exec fastlane test_release_notes
```

### Production Releases (now with AI-generated notes)

```bash
# Patch release
bundle exec fastlane production_patch

# Minor release
bundle exec fastlane production_minor

# Major release
bundle exec fastlane production_major
```

### Internal Releases (still use default notes)

```bash
bundle exec fastlane internal_patch
bundle exec fastlane internal_minor
bundle exec fastlane internal_major
```

## How It Works

1. **Commit Collection**: The system gets all commits since the last git tag
2. **AI Processing**: Sends commits to Google Gemini AI with a prompt to generate user-friendly release notes
3. **Formatting**: Returns formatted bullet points focused on user-facing changes
4. **Fallback**: If API fails, uses sensible default release notes

## Example Output

Instead of generic "Automated release via Fastlane", you'll get:

```text
• Enhanced Ustadz feature with improved profile management
• Added full-screen image viewing in gallery sections
• Improved distance calculation for mosque locations
• Fixed custom schedule handling in Kajian events
• General performance improvements and bug fixes
```

## Cost

Google Gemini AI offers a generous free tier that should cover most mobile app release cycles:

- **Free Tier**: 15 requests per minute
- **Perfect for releases**: Most apps release much less frequently than this limit

## Troubleshooting

- **No API Key**: System will use fallback release notes
- **API Error**: Check your API key and internet connection
- **Empty Commits**: Returns default improvement notes

## Security

- API key is stored as environment variable (not in code)
- Only commit messages are sent to Gemini (no sensitive code)
- Fallback ensures releases work even without API access

## Why Gemini over DeepSeek?

- ✅ **Reliable Free Tier**: Google's commitment to free AI access
- ✅ **Better Availability**: More stable service
- ✅ **High Quality**: Gemini 1.5 Flash produces excellent results
- ✅ **Google Integration**: Better support and documentation
