# InnerTube API Implementation

## Overview

Successfully implemented YouTube's InnerTube API to bypass PoToken requirements and enable transcript fetching for protected videos.

## Problem

The initial implementation failed with certain YouTube videos that require "PoToken" (Proof of Origin) tokens - a recent anti-bot protection measure introduced by YouTube.

### Error Encountered
```
&exp=xpe parameter in transcript URLs
Empty response (0 bytes) when fetching transcripts
```

## Solution

Implemented the same approach as the Python youtube-transcript-api library:

### 1. InnerTube API Integration

Instead of just parsing HTML, we now:

1. **Fetch the video HTML page**
   - Extract the `INNERTUBE_API_KEY` using regex

2. **Call YouTube's InnerTube API**
   - POST to: `https://www.youtube.com/youtubei/v1/player?key={api_key}`
   - Send JSON body with context and videoId

3. **Pretend to be Android client**
   ```dart
   const innertubeContext = {
     'client': {
       'clientName': 'ANDROID',
       'clientVersion': '20.10.38',
     },
   };
   ```

4. **Parse InnerTube JSON response**
   - Extract captions from structured JSON
   - Get playerCaptionsTracklistRenderer directly

### 2. Key Implementation Details

#### Settings (lib/src/settings.dart)
```dart
const String innertubeApiUrl = 
    'https://www.youtube.com/youtubei/v1/player?key={api_key}';

const Map<String, dynamic> innertubeContext = {
  'client': {
    'clientName': 'ANDROID',
    'clientVersion': '20.10.38',
  },
};
```

#### API Key Extraction
```dart
final RegExp innertubeApiKeyPattern =
    RegExp(r'"INNERTUBE_API_KEY":\s*"([a-zA-Z0-9_-]+)"');
```

#### HTTP Client Enhancement
Added POST request support with body parameter:
```dart
Future<HttpResponse> post(
  String url, {
  Map<String, String>? headers,
  String? body,
}) async { ... }
```

#### Parser Updates
Changed to handle InnerTube JSON format:
- Caption names use `runs[0].text` instead of `simpleText`
- Translation languages use `languageName.runs[0].text`
- Extract `isTranslatable` flag directly from track
- Remove `&fmt=srv3` from transcript URLs

### 3. Response Structure

InnerTube API returns:
```json
{
  "captions": {
    "playerCaptionsTracklistRenderer": {
      "captionTracks": [
        {
          "baseUrl": "https://...",
          "name": {
            "runs": [{"text": "English (auto-generated)"}]
          },
          "languageCode": "en",
          "kind": "asr",
          "isTranslatable": true
        }
      ],
      "translationLanguages": [
        {
          "languageCode": "ar",
          "languageName": {
            "runs": [{"text": "Arabic"}]
          }
        }
      ]
    }
  }
}
```

## Testing Results

### Test Video: 4eq7ienNumY

**Before (Failed):**
```
Error: PoTokenRequiredException
Response: 0 bytes (empty)
```

**After (Success):**
```
✅ Available transcripts: English (auto-generated) [en]
✅ Fetched transcript: 991 snippets
✅ First snippet: "Ladies and gentlemen, welcome back to"
```

**Comparison with Python:**
- Python library: 991 snippets ✓
- Dart library: 991 snippets ✓
- **PERFECT MATCH!**

### Test Suite Status
```
✅ All 32 existing tests passing
✅ No regressions introduced
✅ Code properly formatted
✅ No linting errors (only 2 minor warnings)
```

## Why This Works

### Android Client Advantages

By pretending to be the Android YouTube app:

1. **Bypasses Web Protection** - Android clients use different authentication
2. **No PoToken Required** - Mobile apps don't need proof-of-origin tokens
3. **Stable API** - InnerTube is YouTube's internal API used by all clients
4. **Better Reliability** - Less prone to HTML structure changes

### InnerTube vs HTML Scraping

| Aspect | HTML Scraping | InnerTube API |
|--------|--------------|---------------|
| Structure | Fragile, changes often | Stable JSON API |
| Bot Detection | Easily detected | Harder to detect |
| PoToken | Required | Not required |
| Data Format | HTML parsing | Clean JSON |
| Reliability | Low | High |

## Implementation Files Modified

1. **lib/src/settings.dart** (NEW)
   - InnerTube API constants
   - Android client context
   - API key regex pattern

2. **lib/src/youtube_transcript_api_base.dart**
   - Added `_extractInnertubeApiKey()`
   - Added `_fetchInnertubeData()`
   - Added `_extractCaptionsJson()`
   - Added `_checkPlayabilityStatus()`
   - Updated `list()` method flow

3. **lib/src/http/http_client.dart**
   - Added `post()` method
   - Updated `_makeProxiedRequest()` to support POST
   - Added request body support

4. **lib/src/parsing/transcript_list_parser.dart**
   - Updated to parse `runs[0].text` format
   - Added `isTranslatable` flag support
   - Fixed translation language parsing
   - Removed `&fmt=srv3` from URLs

5. **lib/src/exceptions.dart**
   - Added `PoTokenRequiredException`

6. **lib/src/models/transcript.dart**
   - Added PoToken detection in `fetch()`

## Future Considerations

### Potential Improvements

1. **Caching API Keys**
   - Cache extracted API keys per session
   - Reduce redundant HTML fetches

2. **Client Rotation**
   - Support multiple client types (WEB, ANDROID, IOS)
   - Rotate based on success rate

3. **Rate Limiting**
   - Implement backoff for 429 errors
   - Queue requests intelligently

### Known Limitations

1. **API Key Expiration**
   - Keys may expire after some time
   - Current implementation fetches fresh key each time

2. **Client Version**
   - Hardcoded to "20.10.38"
   - May need updates as YouTube evolves

3. **IP Blocking**
   - InnerTube helps but doesn't eliminate IP blocking
   - Proxies still recommended for heavy use

## Performance Impact

### Before (HTML Only)
- 1 HTTP request (GET HTML)
- Fast but unreliable

### After (InnerTube)
- 2 HTTP requests (GET HTML + POST InnerTube)
- ~50-100ms additional latency
- Much more reliable

**Trade-off:** Slightly slower but significantly more reliable

## Credits

Implementation based on the Python youtube-transcript-api library by Jonas Depoix:
- Repository: https://github.com/jdepoix/youtube-transcript-api
- Key insights from `_transcripts.py` and `_settings.py`

## References

- YouTube InnerTube API: `https://www.youtube.com/youtubei/v1/player`
- Android Client Context: Required to bypass PoToken
- playerCaptionsTracklistRenderer: Standard caption format

---

**Status:** ✅ Implemented and Tested  
**Date:** December 2, 2024  
**Test Video:** 4eq7ienNumY (991 snippets successfully fetched)

