#!/bin/bash

echo "🚀 Setting up Google Gemini AI for Release Notes Generation"
echo ""
echo "To use Gemini AI for generating release notes, you need to:"
echo ""
echo "1. Get a free API key from Google AI Studio:"
echo "   Visit: https://aistudio.google.com/app/apikey"
echo "   - Sign in with your Google account"
echo "   - Click 'Create API Key'"
echo "   - Copy the generated API key"
echo ""
echo "2. Set the environment variable:"
echo "   export GEMINI_API_KEY='your-api-key-here'"
echo ""
echo "3. For permanent setup, add to your ~/.zshrc:"
echo "   echo 'export GEMINI_API_KEY=\"your-api-key-here\"' >> ~/.zshrc"
echo "   source ~/.zshrc"
echo ""
echo "4. Test the release notes generation:"
echo "   cd ios && bundle exec fastlane test_release_notes"
echo ""
echo "📝 Note: Without the API key, the system will use fallback release notes."
echo "🆓 Gemini offers a generous free tier with 15 requests per minute!"
echo ""

# Check if API key is already set
if [ -n "$GEMINI_API_KEY" ]; then
    echo "✅ GEMINI_API_KEY is already set!"
else
    echo "❌ GEMINI_API_KEY is not set yet."
fi
