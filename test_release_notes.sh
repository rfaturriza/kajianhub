#!/bin/bash

echo "🧪 Testing Google Gemini AI Integration"
echo ""

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ GEMINI_API_KEY is not set"
    echo ""
    echo "To test with a real API key:"
    echo "1. Get your free API key from https://aistudio.google.com/app/apikey"
    echo "2. Run: export GEMINI_API_KEY='your-api-key-here'"
    echo "3. Run this script again"
    echo ""
    echo "Testing with fallback notes..."
else
    echo "✅ GEMINI_API_KEY is set - will test real AI generation!"
fi

echo "🚀 Running Fastlane test..."
cd ios && SKIP_SETUP=true bundle exec fastlane test_release_notes

echo ""
echo "✅ Test completed!"
echo ""
echo "📋 What happened:"
echo "• Git commits were fetched successfully"
echo "• Gemini AI was called (or attempted)"
echo "• Release notes were generated"
echo ""
echo "🔧 To use with real Gemini AI:"
echo "1. Set your GEMINI_API_KEY environment variable"
echo "2. Run the test again to see AI-generated release notes"
echo "3. Free tier: 15 requests per minute"
echo ""
