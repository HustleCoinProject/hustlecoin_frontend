# First-Time User Tutorial Guide

## Overview
The app now includes a first-time user tutorial/onboarding system that guides new users through the main features of the home page.

## What's Implemented

### Tutorial Highlights
The tutorial shows 5 key features in sequence:

1. **HC Balance** (Top-Left)
   - Shows user's HustleCoin balance
   - Displays value in Kwanza (Kz)
   - Explains how to earn more HC

2. **Left Task Buttons** 
   - Daily Tap, Watch Ad, and Quiz buttons
   - Tasks that earn HustleCoins
   - Explains these are the main earning methods

3. **Right Premium Features**
   - Land, Safe Lock, and Events buttons
   - Premium features that require HC or special access
   - Explains advanced functionality

4. **Get Paid Button** (Bottom Center)
   - Wallet icon in bottom navigation
   - Explains how to request rewards
   - Converts HC to real money

5. **Profile Page** (Bottom Navigation)
   - User profile icon
   - Update profile info and hustle stats
   - View inventory

## How It Works

### Automatic Display
- Tutorial shows automatically on first app launch
- Uses SharedPreferences to track completion
- Won't show again after user completes or skips it

### User Controls
- **Tap anywhere** to move to next step
- **Skip button** (top-right) to dismiss tutorial
- **Dark overlay** focuses attention on highlighted feature

## Testing the Tutorial

### To Reset Tutorial (Show Again)
Add this code temporarily in your app (e.g., in a debug menu):

```dart
import 'package:hustlecoin/services/tutorial_service.dart';

// Call this to reset
await TutorialService.resetTutorial();
```

Or manually clear SharedPreferences:
1. Uninstall and reinstall the app
2. Or clear app data from device settings

### To Disable Tutorial
Comment out the tutorial check in `_HomeScreenState.initState()`:

```dart
// WidgetsBinding.instance.addPostFrameCallback((_) {
//   _checkAndShowTutorial();
// });
```

## Files Modified

1. **pubspec.yaml** - Added `tutorial_coach_mark: ^1.2.11` package
2. **lib/services/tutorial_service.dart** - New service to track tutorial state
3. **lib/features/home/home_screen.dart** - Tutorial implementation
4. **lib/features/home/widgets/top_bar.dart** - Added key for HC balance
5. **lib/features/home/widgets/bottom_nav_bar.dart** - Added keys for navigation items

## Customization

### Change Tutorial Content
Edit the `_createTutorialTargets()` method in `home_screen.dart` to modify:
- Text content
- Alignment of tooltips
- Order of steps
- Styling

### Add More Steps
1. Create a new `GlobalKey` in `_HomeScreenState`
2. Attach the key to the widget you want to highlight
3. Add a new `TargetFocus` in `_createTutorialTargets()`

### Style Customization
In `_showTutorial()` method, modify:
- `colorShadow` - Background overlay color
- `opacityShadow` - Overlay transparency (0.0 - 1.0)
- `paddingFocus` - Space around highlighted element

## Package Documentation
For more customization options, see: [tutorial_coach_mark](https://pub.dev/packages/tutorial_coach_mark)
