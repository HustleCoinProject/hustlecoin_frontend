# Frontend Hustle Format Update Summary

## Overview
Updated the HustleCoin frontend to handle the new hustle API format where hustles are returned as key-value pairs instead of simple strings.

## Key Changes

### 1. **New Utility Functions** (`lib/utils/hustle_utils.dart`)
Created helper functions to handle the new hustle format:
- `getHustleKey()` - Extracts English hustle name (for internal use)
- `getHustleDisplayName()` - Extracts localized display name (for UI)
- `getCurrentHustleKey()` - Safely handles both old and new formats for keys
- `getCurrentHustleDisplayName()` - Safely handles both old and new formats for display
- `getCurrentHustleImagePath()` - Gets correct image path using the key

### 2. **Data Model Updates** (`lib/state/all_states.dart`)

#### User Model
- Changed `currentHustle` from `String` to `dynamic` to handle both formats

#### LevelStatus Model  
- Changed `currentHustle` from `String` to `dynamic` to handle both formats

#### API Repository Updates
- `getAllHustles()`: Now returns `Map<String, Map<String, String>>` instead of `Map<String, List<String>>`
- `getAvailableHustles()`: Now returns `Map<String, String>` instead of `List<String>`
- `selectHustle()`: Updated to send hustle key (English name) to server
- `register()`: Updated to send hustle key (English name) to server
- `updateProfile()`: Updated to send hustle key (English name) to server

#### Provider Updates
- `allHustlesProvider`: Updated return type to match new API format
- `availableHustlesProvider`: Updated return type to match new API format

### 3. **UI Component Updates**

#### Edit Profile Screen (`lib/edit_profile.dart`)
- Updated hustle selector dropdown to show localized names but store keys
- Updated background image to use hustle key
- Updated initialization to handle both old and new formats

#### Home Screen (`lib/home_screen.dart`)
- Updated background image to use hustle key for image path
- Updated hustle display text to use localized display name
- Updated level upgrade flow to handle new hustle object format

#### Select Hustle Screen (`lib/select_hustle.dart`)
- Updated to handle hustle objects with key-value pairs
- Updated API calls to use hustle keys
- Updated success messages to show localized names

#### Signup Screen (`lib/signup.dart`)
- Updated to handle new hustle format from getAllHustles API
- Updated registration to send hustle key to server
- Updated UI to display localized names but use keys internally

#### Other Screens
- **Shop** (`lib/shop.dart`): Updated background image to use hustle key
- **Quiz** (`lib/quiz.dart`): Updated background image to use hustle key  
- **Leaderboard** (`lib/leaderboard.dart`): Updated background image to use hustle key

## Backward Compatibility
- All changes maintain backward compatibility with the old string format
- Helper functions safely handle both old and new formats
- Gradual migration approach ensures no breaking changes

## Key Benefits
1. **Internationalization**: Hustles can now display in different languages while maintaining English keys for consistency
2. **File Compatibility**: Image file names remain consistent using English keys
3. **API Consistency**: Database still stores English hustle names for compatibility
4. **User Experience**: Users see localized hustle names based on their language preference

## Updated API Endpoints Handled
- ✅ `GET /api/hustles/all`
- ✅ `GET /api/hustles/available` 
- ✅ `GET /api/hustles/level-status`
- ✅ `POST /api/hustles/level-upgrade`
- ✅ `GET /api/users/me`
- ✅ `POST /api/users/register`
- ✅ `PUT /api/users/profile`

## Testing Recommendations
1. Test hustle selection during signup with both English and Portuguese languages
2. Test profile editing with hustle changes
3. Test level upgrades and hustle selection
4. Verify image loading works correctly with hustle keys
5. Test backward compatibility with any cached old format data

## Notes for Future Development
- Always use hustle keys (English names) for:
  - API calls to server
  - Image file paths
  - Internal data storage
- Always use hustle display names (localized) for:
  - UI text shown to users
  - Success/error messages
  - Any user-facing content
