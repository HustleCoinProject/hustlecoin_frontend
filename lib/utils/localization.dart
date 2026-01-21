import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/providers/user_provider.dart';

// Language enum for type safety
enum Language { en, pt }

// Localization keys class for better organization and type safety
class LocalizationKeys {
  // Navigation
  static const String home = 'home';
  static const String leaderboard = 'leaderboard';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String shop = 'shop';
  static const String land = 'land';
  static const String events = 'events';

  // Actions and Buttons
  static const String dailyTap = 'daily_tap';
  static const String watchAd = 'watch_ad';
  static const String quiz = 'quiz';
  static const String dailyQuiz = 'daily_quiz';
  static const String loading = 'loading';
  static const String submit = 'submit';
  static const String submitAnswer = 'submit_answer';
  static const String tap = 'tap';
  static const String logIn = 'log_in';
  static const String signUp = 'sign_up';
  static const String createAccount = 'create_account';
  static const String updateProfile = 'update_profile';
  static const String upgradeLevel = 'upgrade_level';
  static const String dailyReward = 'daily_reward';
  static const String loadingAd = 'loading_ad';

  // Profile and Account
  static const String username = 'username';
  static const String email = 'email';
  static const String emailAddress = 'email_address';
  static const String password = 'password';
  static const String confirmPassword = 'confirm_password';
  static const String changePassword = 'change_password';
  static const String viewEditProfile = 'view_edit_profile';
  static const String currentHustle = 'current_hustle';
  static const String errorLoadingProfile = 'error_loading_profile';
  static const String errorLoadingHustles = 'error_loading_hustles';
  static const String profileUpdatedSuccessfully =
      'profile_updated_successfully';
  static const String passwordsDoNotMatch = 'passwords_do_not_match';

  // Validation Messages
  static const String currentPassword = 'current_password';
  static const String newPassword = 'new_password';
  static const String confirmNewPassword = 'confirm_new_password';
  static const String language = 'language';
  static const String selectYourHustle = 'select_your_hustle';
  static const String enterCurrentPassword = 'enter_current_password';
  static const String enterNewPassword = 'enter_new_password';
  static const String currentPasswordRequired = 'current_password_required';
  static const String passwordsDontMatch = 'passwords_dont_match';
  static const String confirmNewPasswordHint = 'confirm_new_password_hint';

  // Game Elements
  static const String hustleCoin = 'hustle_coin';
  static const String hustleLevel = 'hustle_level';
  static const String level = 'level';
  static const String nextLevel = 'next_level';
  static const String dailyStreak = 'daily_streak';
  static const String processingLevelUpgrade = 'processing_level_upgrade';

  // Greetings and Messages
  static const String welcomeBack = 'welcome_back';
  static const String welcomeToHustleCoin = 'welcome_to_hustle_coin';
  static const String earnByHustlingDaily = 'earn_by_hustling_daily';
  static const String startMyHustle = 'start_my_hustle';
  static const String logInToContinue = 'log_in_to_continue';
  static const String chooseYourNewHustle = 'choose_your_new_hustle';
  static const String selectHustleToReflect = 'select_hustle_to_reflect';
  static const String congratulations = 'congratulations';
  static const String youveBeenPromoted = 'youve_been_promoted';

  // Shop and Items
  static const String boosters = 'boosters';
  static const String boosts = 'boosts';
  static const String keys = 'keys';
  static const String chatBot = 'chat_bot';
  static const String inventory = 'inventory';
  static const String failedToLoadShopItems = 'failed_to_load_shop_items';
  static const String noItemsAvailable = 'no_items_available';
  static const String successfullyPurchased = 'successfully_purchased';
  static const String failedToPurchase = 'failed_to_purchase';
  static const String failedToLoadLeaderboard = 'failed_to_load_leaderboard';

  // Land Map
  static const String back = 'back';
  static const String yourLand = 'your_land';
  static const String selectedLand = 'selected_land';
  static const String sell = 'sell';
  static const String landPurchasedSuccessfully = 'land_purchased_successfully';
  static const String landSoldSuccessfully = 'land_sold_successfully';
  static const String purchaseFailed = 'purchase_failed';
  static const String saleFailed = 'sale_failed';
  static const String landDailyIncomeInfo = 'land_daily_income_info';

  // Land Income Claim
  static const String landIncomeClaimedSuccessfully =
      'land_income_claimed_successfully';
  static const String landIncomeClaimFailed = 'land_income_claim_failed';
  static const String claimReady = 'claim_ready';
  static const String claimCooldown = 'claim_cooldown';
  static const String claimAvailable = 'claim_available';
  static const String nextClaimIn = 'next_claim_in';
  static const String noIncomeAvailable = 'no_income_available';
  static const String landTiles = 'land_tiles';
  static const String readyToClaim = 'ready_to_claim';
  static const String lastClaimedAt = 'last_claimed_at';
  static const String claim = 'claim';
  static const String generatingIncome = 'generating_income';

  // Errors and Validation
  static const String error = 'error';
  static const String statsLoading = 'stats_loading';
  static const String forgotPassword = 'forgot_password';
  static const String dontHaveAccount = 'dont_have_account';
  static const String alreadyHaveAccount = 'already_have_account';
  static const String emailIsRequired = 'email_is_required';
  static const String pleaseEnterValidEmail = 'please_enter_valid_email';
  static const String adNotReadyTryAgain = 'ad_not_ready_try_again';

  // Time and Status
  static const String hrsLeft = 'hrs_left';
  static const String next = 'next';

  // Leaderboard
  static const String you = 'you';
  static const String rankPoints = 'rank_points';
  static const String leaderboardDisclaimer = 'leaderboard_disclaimer';
  static const String top3Rewards = 'top_3_rewards';

  // Access Control
  static const String unlockFeature = 'unlock_feature';
  static const String bronzeKey = 'bronze_key';
  static const String getBronzeKeyMessage = 'get_bronze_key_message';
  static const String keysExpireMessage = 'keys_expire_message';
  static const String getFromShop = 'get_from_shop';
  static const String unlockExcitingFeature = 'unlock_exciting_feature';
  static const String needItemForFeature = 'need_item_for_feature';

  // Payout
  static const String getPaid = 'get_paid';
  static const String selectPayoutMethod = 'select_payout_method';
  static const String phoneNumber = 'phone_number';
  static const String accountHolderName = 'account_holder_name';
  static const String multicaixaExpressDetails = 'multicaixa_express_details';
  static const String cryptoDetails = 'crypto_details';
  static const String walletAddress = 'wallet_address';
  static const String cryptoNetwork = 'crypto_network';
  static const String selectNetwork = 'select_network';
  static const String enterWalletAddress = 'enter_wallet_address';
  static const String selectBank = 'select_bank';
  static const String enterFullName = 'enter_full_name';
  static const String enterBankName = 'enter_bank_name';
  static const String payoutAmount = 'payout_amount';
  static const String requestPayout = 'request_payout';
  static const String phoneNumberRequired = 'phone_number_required';
  static const String accountHolderNameRequired =
      'account_holder_name_required';
  static const String networkRequired = 'network_required';
  static const String walletAddressRequired = 'wallet_address_required';
  static const String amountRequired = 'amount_required';
  static const String enterValidAmount = 'enter_valid_amount';
  static const String rewardsHistory = 'rewards_history';
  static const String noRewardsHistory = 'no_rewards_history';
  static const String noPayoutRequests = 'no_payout_requests';

  // Settings
  static const String credits = 'credits';
  static const String general = 'general';
  static const String gameplay = 'gameplay';
  static const String about = 'about';
  static const String pushNotifications = 'push_notifications';
  static const String pushNotificationsDesc = 'push_notifications_desc';
  static const String soundEffects = 'sound_effects';
  static const String soundEffectsDesc = 'sound_effects_desc';
  static const String hapticFeedback = 'haptic_feedback';
  static const String hapticFeedbackDesc = 'haptic_feedback_desc';
  static const String autoCollectRewards = 'auto_collect_rewards';
  static const String autoCollectRewardsDesc = 'auto_collect_rewards_desc';
  static const String creditsDesc = 'credits_desc';
  static const String appVersion = 'app_version';

  // Credits
  static const String founderVisionary = 'founder_visionary';
  static const String development = 'development';
  static const String leadDeveloper = 'lead_developer';
  static const String madeWithLove = 'made_with_love';

  // Events
  static const String noEventsYet = 'no_events_yet';
  static const String eventsComingSoon = 'events_coming_soon';
  static const String comingSoon = 'coming_soon';

  // Safe Lock
  static const String safeLock = 'safe_lock';
  static const String safeLockSavings = 'safe_lock_savings';
  static const String lockYourHcForRewards = 'lock_your_hc_for_rewards';
  static const String minimumRewardGuaranteed = 'minimum_reward_guaranteed';
  static const String yourBalance = 'your_balance';
  static const String lockedAmount = 'locked_amount';
  static const String locked = 'locked';
  static const String timeRemaining = 'time_remaining';
  static const String claimRewards = 'claim_rewards';
  static const String depositAmount = 'deposit_amount';
  static const String enterHcAmount = 'enter_hc_amount';
  static const String depositToSafeLock = 'deposit_to_safe_lock';
  static const String addMoreTimerResets = 'add_more_timer_resets';
  static const String depositingAgainResetsTimer =
      'depositing_again_resets_timer';
  static const String howItWorks = 'how_it_works';
  static const String safeLockInfo1 = 'safe_lock_info_1';
  static const String safeLockInfo2 = 'safe_lock_info_2';
  static const String safeLockInfo3 = 'safe_lock_info_3';
  static const String safeLockInfo4 = 'safe_lock_info_4';
  static const String safeLockInfo5 = 'safe_lock_info_5';
  static const String success = 'success';
  static const String congratulationsExclaim = 'congratulations_exclaim';
  static const String returned = 'returned';
  static const String reward = 'reward';
  static const String youReceivedAnItem = 'you_received_an_item';
  static const String newBalance = 'new_balance';
  static const String awesome = 'awesome';
  static const String pleaseEnterValidAmount = 'please_enter_valid_amount';
  static const String insufficientBalance = 'insufficient_balance';

  // Tutorial
  static const String tutorialHcBalanceTitle = 'tutorial_hc_balance_title';
  static const String tutorialHcBalanceDesc = 'tutorial_hc_balance_desc';
  static const String tutorialEarnTasksTitle = 'tutorial_earn_tasks_title';
  static const String tutorialEarnTasksDesc = 'tutorial_earn_tasks_desc';
  static const String tutorialPremiumFeaturesTitle =
      'tutorial_premium_features_title';
  static const String tutorialPremiumFeaturesDesc =
      'tutorial_premium_features_desc';
  static const String tutorialGetPaidTitle = 'tutorial_get_paid_title';
  static const String tutorialGetPaidDesc = 'tutorial_get_paid_desc';
  static const String tutorialProfileTitle = 'tutorial_profile_title';
  static const String tutorialProfileDesc = 'tutorial_profile_desc';
  static const String tutorialWelcomeTitle = 'tutorial_welcome_title';
  static const String tutorialWelcomeDesc = 'tutorial_welcome_desc';
  static const String tutorialPlayGamesTitle = 'tutorial_play_games_title';
  static const String tutorialPlayGamesDesc = 'tutorial_play_games_desc';
  static const String tutorialLetsStart = 'tutorial_lets_start';

  // Upgrade Popup
  static const String levelUpgrade = 'level_upgrade';
  static const String current = 'current';
  static const String required = 'required';
  static const String days = 'days';
  static const String fee = 'fee';
  static const String stillNeed = 'still_need';

  // Games
  static const String miniGames = 'mini_games';
  static const String gameRunnerTitle = 'game_runner_title';
  static const String gameSnakeTitle = 'game_snake_title';
  static const String gameSeagullTitle = 'game_seagull_title';
  static const String gamePongTitle = 'game_pong_title';
  static const String runnerInstruction = 'runner_instruction';
  static const String snakeInstruction = 'snake_instruction';
  static const String seagullInstruction = 'seagull_instruction';
  static const String pongInstruction = 'pong_instruction';
  static const String gameBalloonPopTitle = 'game_balloon_pop_title';
  static const String balloonPopInstruction = 'balloon_pop_instruction';
  static const String play = 'play';
  static const String playAgain = 'play_again';
  static const String tapToJump = 'tap_to_jump';
  static const String swipeToMove = 'swipe_to_move';
  static const String tapToFlap = 'tap_to_flap';
  static const String serve = 'serve';
  static const String rematch = 'rematch';
  static const String exit = 'exit';
  static const String startGame = 'start_game';
  static const String gameOver = 'game_over';
  static const String score = 'score';
  static const String youWin = 'you_win';
  static const String aiWins = 'ai_wins';
  static const String firstTo5 = 'first_to_5';
  static const String winner = 'winner';
  static const String goal = 'goal';
  static const String winMatch = 'winMatch';
  static const String playGames = 'playGames';

  // Level Benefits
  static const String levelBenefits = 'level_benefits';
  static const String multiplierTitle = 'multiplier_title';
  static const String multiplierDesc = 'multiplier_desc';
  static const String landTitle = 'land_title';
  static const String landDesc = 'land_desc';
  static const String legacyTitle = 'legacy_title';
  static const String legacyDesc = 'legacy_desc';
  static const String closeDialog = 'close_dialog';
}

// Translation maps
class _Translations {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      // Navigation
      LocalizationKeys.home: 'Home',
      LocalizationKeys.leaderboard: 'Leaderboard',
      LocalizationKeys.profile: 'Profile',
      LocalizationKeys.settings: 'Settings',
      LocalizationKeys.shop: 'Shop',
      LocalizationKeys.land: 'Land',
      LocalizationKeys.events: 'Events',

      // Actions and Buttons
      LocalizationKeys.dailyTap: 'DAILY TAP',
      LocalizationKeys.watchAd: 'WATCH AD',
      LocalizationKeys.quiz: 'QUIZ',
      LocalizationKeys.dailyQuiz: 'Daily Quiz',
      LocalizationKeys.loading: 'LOADING',
      LocalizationKeys.submit: 'Submit',
      LocalizationKeys.tutorialPlayGamesTitle: 'Play & Earn',
      LocalizationKeys.tutorialPlayGamesDesc:
          'Play mini-games to earn extra HustleCoins (HC) while your tasks are on cooldown!',
      LocalizationKeys.submitAnswer: 'Submit Answer',
      LocalizationKeys.tap: 'TAP',
      LocalizationKeys.logIn: 'Log In',
      LocalizationKeys.signUp: 'Sign Up',
      LocalizationKeys.createAccount: 'Create Account',
      LocalizationKeys.updateProfile: 'Update Profile',
      LocalizationKeys.upgradeLevel: 'Upgrade Level',
      LocalizationKeys.dailyReward: 'Daily Reward',
      LocalizationKeys.loadingAd: 'LOADING AD',

      // Profile and Account
      LocalizationKeys.username: 'Username',
      LocalizationKeys.email: 'Email',
      LocalizationKeys.emailAddress: 'Email Address',
      LocalizationKeys.password: 'Password',
      LocalizationKeys.confirmPassword: 'Confirm Password',
      LocalizationKeys.changePassword: 'Change Password',
      LocalizationKeys.viewEditProfile: 'View/Edit Profile',
      LocalizationKeys.currentHustle: 'Current Hustle',
      LocalizationKeys.errorLoadingProfile: 'Error loading profile',
      LocalizationKeys.errorLoadingHustles: 'Error loading hustles',
      LocalizationKeys.profileUpdatedSuccessfully:
          'Profile updated successfully!',
      LocalizationKeys.passwordsDoNotMatch: 'Passwords do not match',
      LocalizationKeys.currentPassword: 'Current Password',
      LocalizationKeys.newPassword: 'New Password',
      LocalizationKeys.confirmNewPassword: 'Confirm New Password',
      LocalizationKeys.language: 'Language',
      LocalizationKeys.selectYourHustle: 'Select your hustle',
      LocalizationKeys.enterCurrentPassword: 'Enter current password',
      LocalizationKeys.enterNewPassword: 'Enter new password',
      LocalizationKeys.currentPasswordRequired:
          'Current password is required to change password',
      LocalizationKeys.passwordsDontMatch: 'Passwords don\'t match',
      LocalizationKeys.confirmNewPasswordHint: 'Confirm new password',

      // Game Elements
      LocalizationKeys.hustleCoin: 'Hustle Coin',
      LocalizationKeys.hustleLevel: 'HUSTLE LEVEL',
      LocalizationKeys.level: 'Level',
      LocalizationKeys.nextLevel: 'NEXT LEVEL',
      LocalizationKeys.dailyStreak: '🔥 Daily Streak',
      LocalizationKeys.processingLevelUpgrade: 'Processing level upgrade...',

      // Greetings and Messages
      LocalizationKeys.welcomeBack: 'Welcome Back!',
      LocalizationKeys.welcomeToHustleCoin: 'Welcome to Hustle Coin',
      LocalizationKeys.earnByHustlingDaily: 'Earn by Hustling Daily!',
      LocalizationKeys.startMyHustle: 'START MY HUSTLE',
      LocalizationKeys.logInToContinue: 'Log in to continue your hustle.',
      LocalizationKeys.chooseYourNewHustle: 'Choose Your New Hustle',
      LocalizationKeys.selectHustleToReflect:
          'Select a hustle to reflect your new status',
      LocalizationKeys.congratulations: '🎉 CONGRATULATIONS! 🎉',
      LocalizationKeys.youveBeenPromoted: 'You\'ve been promoted to Level',

      // Shop and Items
      LocalizationKeys.boosters: 'Boosters',
      LocalizationKeys.boosts: 'Boosts',
      LocalizationKeys.keys: 'Keys',
      LocalizationKeys.chatBot: 'Chat Bot',
      LocalizationKeys.inventory: 'Inventory',
      LocalizationKeys.failedToLoadShopItems: 'Failed to load shop items',
      LocalizationKeys.noItemsAvailable: 'No items available',
      LocalizationKeys.successfullyPurchased: 'Successfully purchased',
      LocalizationKeys.failedToPurchase: 'Failed to purchase',
      LocalizationKeys.failedToLoadLeaderboard: 'Failed to load leaderboard',

      // Land Map
      LocalizationKeys.back: 'Back',
      LocalizationKeys.yourLand: 'Your Land (Res 8)',
      LocalizationKeys.selectedLand: 'Selected Land (Res 8)',
      LocalizationKeys.sell: 'Sell',
      LocalizationKeys.landPurchasedSuccessfully:
          'Land purchased successfully!',
      LocalizationKeys.landSoldSuccessfully: 'Land sold successfully!',
      LocalizationKeys.purchaseFailed: 'Purchase failed',
      LocalizationKeys.saleFailed: 'Sale failed',
      LocalizationKeys.landDailyIncomeInfo:
          'Purchasing land gives 50 HC daily income that you can claim every 24 hours',

      // Land Income Claim
      LocalizationKeys.landIncomeClaimedSuccessfully:
          'Land income claimed successfully!',
      LocalizationKeys.landIncomeClaimFailed: 'Failed to claim land income',
      LocalizationKeys.claimReady: 'Ready!',
      LocalizationKeys.claimCooldown: 'Cooldown',
      LocalizationKeys.claimAvailable: 'Available to claim',
      LocalizationKeys.nextClaimIn: 'Next claim in',
      LocalizationKeys.noIncomeAvailable: 'No income to claim yet',
      LocalizationKeys.landTiles: 'land tiles',
      LocalizationKeys.readyToClaim: 'ready to claim',
      LocalizationKeys.lastClaimedAt: 'Last claimed',
      LocalizationKeys.claim: 'Claim',
      LocalizationKeys.generatingIncome: 'generating income...',

      // Errors and Validation
      LocalizationKeys.error: 'Error',
      LocalizationKeys.statsLoading: 'Stats loading...',
      LocalizationKeys.forgotPassword: 'Forgot Password?',
      LocalizationKeys.dontHaveAccount: 'Don\'t have an account?',
      LocalizationKeys.alreadyHaveAccount: 'Already have an account?',
      LocalizationKeys.emailIsRequired: 'Email is required',
      LocalizationKeys.pleaseEnterValidEmail: 'Please enter a valid email',
      LocalizationKeys.adNotReadyTryAgain:
          'Ad is not ready yet. Please try again in a moment.',

      // Time and Status
      LocalizationKeys.hrsLeft: 'hrs left',
      LocalizationKeys.next: 'Next',

      // Leaderboard
      LocalizationKeys.you: 'You',
      LocalizationKeys.rankPoints: 'Rank Points',
      LocalizationKeys.leaderboardDisclaimer:
          'Weekly Challenge • Resets Monday (AO Time)',
      LocalizationKeys.top3Rewards: '🏆 Top 3 Players Win Rewards!',

      // Access Control
      LocalizationKeys.unlockFeature: 'Unlock Feature',
      LocalizationKeys.bronzeKey: 'Bronze Key',
      LocalizationKeys.getBronzeKeyMessage:
          'Get your Bronze Key from the shop to unlock this exciting feature!',
      LocalizationKeys.keysExpireMessage: 'Keys give you 3 hours of access.',
      LocalizationKeys.getFromShop: 'get from shop',
      LocalizationKeys.unlockExcitingFeature: 'unlock this exciting feature',
      LocalizationKeys.needItemForFeature:
          'You need a {item} for this feature.',

      // Payout
      LocalizationKeys.getPaid: 'Claim Prize',
      LocalizationKeys.selectPayoutMethod: 'Select Prize Delivery',
      LocalizationKeys.phoneNumber: 'Phone Number',
      LocalizationKeys.accountHolderName: 'Account Holder Name',
      LocalizationKeys.multicaixaExpressDetails: 'Multicaixa Express Details',
      LocalizationKeys.cryptoDetails: 'Crypto Transfer Details',
      LocalizationKeys.walletAddress: 'Wallet Address',
      LocalizationKeys.cryptoNetwork: 'Network',
      LocalizationKeys.selectNetwork: 'Select Network',
      LocalizationKeys.enterWalletAddress: 'Enter your wallet address',
      LocalizationKeys.enterFullName: 'Enter your full name',
      LocalizationKeys.payoutAmount: 'Prize Value (HC)',
      LocalizationKeys.requestPayout: 'Claim Prize',
      LocalizationKeys.phoneNumberRequired: 'Phone number is required',
      LocalizationKeys.accountHolderNameRequired:
          'Account holder name is required',
      LocalizationKeys.networkRequired: 'Network is required',
      LocalizationKeys.walletAddressRequired: 'Wallet address is required',
      LocalizationKeys.amountRequired: 'Amount is required',
      LocalizationKeys.enterValidAmount: 'Enter a valid amount',
      LocalizationKeys.rewardsHistory: 'Rewards History',
      LocalizationKeys.noRewardsHistory: 'No Rewards History',
      LocalizationKeys.noPayoutRequests:
          'You haven\'t made any payout requests yet.',

      // Settings
      LocalizationKeys.credits: 'Credits',
      LocalizationKeys.general: 'GENERAL',
      LocalizationKeys.gameplay: 'GAMEPLAY',
      LocalizationKeys.about: 'ABOUT',
      LocalizationKeys.pushNotifications: 'Push Notifications',
      LocalizationKeys.pushNotificationsDesc:
          'Receive notifications about rewards',
      LocalizationKeys.soundEffects: 'Sound Effects',
      LocalizationKeys.soundEffectsDesc: 'Enable in-app sound effects',
      LocalizationKeys.hapticFeedback: 'Haptic Feedback',
      LocalizationKeys.hapticFeedbackDesc: 'Vibration on button presses',
      LocalizationKeys.autoCollectRewards: 'Auto-Collect Rewards',
      LocalizationKeys.autoCollectRewardsDesc:
          'Automatically collect available rewards',
      LocalizationKeys.creditsDesc: 'View app credits and attribution',
      LocalizationKeys.appVersion: 'App Version',

      // Credits
      LocalizationKeys.founderVisionary: 'Founder & Visionary',
      LocalizationKeys.development: 'DEVELOPMENT',
      LocalizationKeys.leadDeveloper: 'Lead Developer',
      LocalizationKeys.madeWithLove: 'Made with ❤️',

      // Events
      LocalizationKeys.noEventsYet: 'No Events Yet',
      LocalizationKeys.eventsComingSoon:
          'Exciting events are coming soon!\nStay tuned for updates.',
      LocalizationKeys.comingSoon: 'Coming Soon',

      // Safe Lock
      LocalizationKeys.safeLock: 'Safe Lock',
      LocalizationKeys.safeLockSavings: 'Safe Lock Savings',
      LocalizationKeys.lockYourHcForRewards:
          'Lock your HC for 7 days and earn rewards!',
      LocalizationKeys.minimumRewardGuaranteed:
          'Minimum reward: 30 HC + possible item bonus',
      LocalizationKeys.yourBalance: 'Your Balance:',
      LocalizationKeys.lockedAmount: 'Locked Amount:',
      LocalizationKeys.locked: 'Locked',
      LocalizationKeys.timeRemaining: 'Time Remaining:',
      LocalizationKeys.claimRewards: 'Claim Rewards',
      LocalizationKeys.depositAmount: 'Deposit Amount',
      LocalizationKeys.enterHcAmount: 'Enter HC amount',
      LocalizationKeys.depositToSafeLock: 'Deposit to Safe Lock',
      LocalizationKeys.addMoreTimerResets: 'Add More (Timer Resets)',
      LocalizationKeys.depositingAgainResetsTimer:
          '⚠️ Depositing again will reset the 7-day timer',
      LocalizationKeys.howItWorks: 'How It Works',
      LocalizationKeys.safeLockInfo1: 'Deposit HC and lock it for 7 days',
      LocalizationKeys.safeLockInfo2: 'Timer resets if you deposit again',
      LocalizationKeys.safeLockInfo3: 'Earn rewards based on your activity',
      LocalizationKeys.safeLockInfo4: 'Active users may receive bonus items',
      LocalizationKeys.safeLockInfo5: 'Minimum 30 HC reward guaranteed',
      LocalizationKeys.success: 'Success!',
      LocalizationKeys.congratulationsExclaim: '🎉 Congratulations! 🎉',
      LocalizationKeys.returned: 'Returned:',
      LocalizationKeys.reward: 'Reward:',
      LocalizationKeys.youReceivedAnItem: 'You received an item!',
      LocalizationKeys.newBalance: 'New Balance:',
      LocalizationKeys.awesome: 'Awesome!',
      LocalizationKeys.pleaseEnterValidAmount: 'Please enter a valid amount',
      LocalizationKeys.insufficientBalance: 'Insufficient balance',

      // Tutorial
      LocalizationKeys.tutorialHcBalanceTitle: 'Your HC Balance',
      LocalizationKeys.tutorialHcBalanceDesc:
          'This shows your HustleCoin (HC) balance and potential prize value in Kwanza. Complete tasks to earn more HC!',
      LocalizationKeys.tutorialEarnTasksTitle: 'Earn HC Tasks',
      LocalizationKeys.tutorialEarnTasksDesc:
          'Tap these buttons to complete tasks and earn HustleCoins! Daily Tap, Watch Ads, and Play Quiz are great ways to earn.',
      LocalizationKeys.tutorialPremiumFeaturesTitle: 'Premium Features',
      LocalizationKeys.tutorialPremiumFeaturesDesc:
          'Access premium features here! Explore Land, Safe Lock for storing HC, and Events for special opportunities.',
      LocalizationKeys.tutorialGetPaidTitle: 'Claim Prizes',
      LocalizationKeys.tutorialGetPaidDesc:
          'Once you\'ve earned enough HC, tap here to claim your prizes!',
      LocalizationKeys.tutorialProfileTitle: 'Your Profile',
      LocalizationKeys.tutorialProfileDesc:
          'Tap here to update your profile information, check your hustle stats, and view your inventory of items!',
      LocalizationKeys.tutorialWelcomeTitle: 'You\'re All Set!',
      LocalizationKeys.tutorialWelcomeDesc:
          'Start earning HustleCoins and build your hustle empire!',
      LocalizationKeys.tutorialLetsStart: 'Let\'s Start.',

      // Upgrade Popup
      LocalizationKeys.levelUpgrade: 'Level {level} Upgrade',
      LocalizationKeys.current: 'Current',
      LocalizationKeys.required: 'Required',
      LocalizationKeys.days: 'days',
      LocalizationKeys.fee: 'fee',
      LocalizationKeys.stillNeed: 'Still need',

      // Games
      LocalizationKeys.miniGames: 'Play Games to Earn HC',
      LocalizationKeys.gameRunnerTitle: 'Hustle Run',
      LocalizationKeys.gameSnakeTitle: 'Retro Snake',
      LocalizationKeys.gameSeagullTitle: 'Seagull Scramble',
      LocalizationKeys.gamePongTitle: 'Pixel Pong',
      LocalizationKeys.runnerInstruction: 'Dodge obstacles and collect coins!',
      LocalizationKeys.snakeInstruction:
          'Classic snake game. Eat food to grow!',
      LocalizationKeys.seagullInstruction: 'Tap to fly and avoid collisions',
      LocalizationKeys.pongInstruction:
          'Beat the AI in this classic tennis game',
      LocalizationKeys.gameBalloonPopTitle: 'Balloon Pop',
      LocalizationKeys.balloonPopInstruction:
          'Pop balloons to score points! Don\'t let them fly away.',
      LocalizationKeys.play: 'PLAY',
      LocalizationKeys.playAgain: 'PLAY AGAIN',
      LocalizationKeys.tapToJump: 'Tap to Jump',
      LocalizationKeys.swipeToMove: 'Swipe to Move',
      LocalizationKeys.tapToFlap: 'Tap to Flap',
      LocalizationKeys.serve: 'SERVE',
      LocalizationKeys.rematch: 'REMATCH',
      LocalizationKeys.exit: 'EXIT',
      LocalizationKeys.startGame: 'START GAME',
      LocalizationKeys.gameOver: 'GAME OVER',
      LocalizationKeys.score: 'Score',
      LocalizationKeys.youWin: 'YOU WIN!',
      LocalizationKeys.aiWins: 'AI WINS!',
      LocalizationKeys.firstTo5: 'FIRST TO 5',
      LocalizationKeys.winner: 'WINNER',
      LocalizationKeys.goal: 'Goal',
      LocalizationKeys.winMatch: 'Win Match',
      LocalizationKeys.playGames: 'PLAY GAMES',

      // Level Benefits
      LocalizationKeys.levelBenefits: 'LEVEL BENEFITS',
      LocalizationKeys.multiplierTitle: 'MULTIPLIER',
      LocalizationKeys.multiplierDesc: 'Boosts HC earnings from all tasks.',
      LocalizationKeys.landTitle: 'LAND',
      LocalizationKeys.landDesc: 'Unlocks more plots for your empire.',
      LocalizationKeys.legacyTitle: 'LEGACY',
      LocalizationKeys.legacyDesc: 'Access exclusive high-tier hustles.',
      LocalizationKeys.closeDialog: '[ CLOSE ]',
    },

    'pt': {
      // Navigation
      LocalizationKeys.home: 'Início',
      LocalizationKeys.leaderboard: 'Classificação',
      LocalizationKeys.profile: 'Perfil',
      LocalizationKeys.settings: 'Configurações',
      LocalizationKeys.shop: 'Loja',
      LocalizationKeys.land: 'Terra',
      LocalizationKeys.events: 'Eventos',

      // Actions and Buttons
      LocalizationKeys.dailyTap: 'TOQUE DIÁRIO',
      LocalizationKeys.watchAd: 'VER ANÚNCIO',
      LocalizationKeys.quiz: 'QUIZ',
      LocalizationKeys.dailyQuiz: 'Quiz Diário',
      LocalizationKeys.loading: 'CARREGANDO',
      LocalizationKeys.submit: 'Enviar',
      LocalizationKeys.tutorialPlayGamesTitle: 'Jogue e Ganhe',
      LocalizationKeys.tutorialPlayGamesDesc:
          'Jogue minijogos para ganhar HustleCoins (HC) extras enquanto suas tarefas estão em recarga!',
      LocalizationKeys.submitAnswer: 'Enviar Resposta',
      LocalizationKeys.tap: 'TOCAR',
      LocalizationKeys.logIn: 'Entrar',
      LocalizationKeys.signUp: 'Cadastrar',
      LocalizationKeys.createAccount: 'Criar Conta',
      LocalizationKeys.updateProfile: 'Atualizar Perfil',
      LocalizationKeys.upgradeLevel: 'Subir de Nível',
      LocalizationKeys.dailyReward: 'Recompensa Diária',
      LocalizationKeys.loadingAd: 'CARREGANDO ANÚNCIO',

      // Profile and Account
      LocalizationKeys.username: 'Nome de usuário',
      LocalizationKeys.email: 'Email',
      LocalizationKeys.emailAddress: 'Endereço de Email',
      LocalizationKeys.password: 'Senha',
      LocalizationKeys.confirmPassword: 'Confirmar Senha',
      LocalizationKeys.changePassword: 'Alterar Senha',
      LocalizationKeys.viewEditProfile: 'Ver/Editar Perfil',
      LocalizationKeys.currentHustle: 'Trabalho Atual',
      LocalizationKeys.errorLoadingProfile: 'Erro ao carregar perfil',
      LocalizationKeys.errorLoadingHustles: 'Erro ao carregar trabalhos',
      LocalizationKeys.profileUpdatedSuccessfully:
          'Perfil atualizado com sucesso!',
      LocalizationKeys.passwordsDoNotMatch: 'As senhas não coincidem',
      LocalizationKeys.currentPassword: 'Senha Atual',
      LocalizationKeys.newPassword: 'Nova Senha',
      LocalizationKeys.confirmNewPassword: 'Confirmar Nova Senha',
      LocalizationKeys.language: 'Idioma',
      LocalizationKeys.selectYourHustle: 'Selecione seu trabalho',
      LocalizationKeys.enterCurrentPassword: 'Digite a senha atual',
      LocalizationKeys.enterNewPassword: 'Digite a nova senha',
      LocalizationKeys.currentPasswordRequired:
          'Senha atual é obrigatória para alterar a senha',
      LocalizationKeys.passwordsDontMatch: 'As senhas não coincidem',
      LocalizationKeys.confirmNewPasswordHint: 'Confirme a nova senha',

      // Game Elements
      LocalizationKeys.hustleCoin: 'Hustle Coin',
      LocalizationKeys.hustleLevel: 'NÍVEL DE TRABALHO',
      LocalizationKeys.level: 'Nível',
      LocalizationKeys.nextLevel: 'PRÓXIMO NÍVEL',
      LocalizationKeys.dailyStreak: '🔥 Sequência Diária',
      LocalizationKeys.processingLevelUpgrade:
          'Processando upgrade de nível...',

      // Greetings and Messages
      LocalizationKeys.welcomeBack: 'Bem-vindo de Volta!',
      LocalizationKeys.welcomeToHustleCoin: 'Bem-vindo ao Hustle Coin',
      LocalizationKeys.earnByHustlingDaily: 'Ganhe Trabalhando Diariamente!',
      LocalizationKeys.startMyHustle: 'COMEÇAR MEU TRABALHO',
      LocalizationKeys.logInToContinue:
          'Faça login para continuar seu trabalho.',
      LocalizationKeys.chooseYourNewHustle: 'Escolha Seu Novo Trabalho',
      LocalizationKeys.selectHustleToReflect:
          'Selecione um trabalho para refletir seu novo status',
      LocalizationKeys.congratulations: '🎉 PARABÉNS! 🎉',
      LocalizationKeys.youveBeenPromoted: 'Você foi promovido para o Nível',

      // Shop and Items
      LocalizationKeys.boosters: 'Impulsionadores',
      LocalizationKeys.boosts: 'Impulsos',
      LocalizationKeys.keys: 'Chaves',
      LocalizationKeys.chatBot: 'Robô de Chat',
      LocalizationKeys.inventory: 'Inventário',
      LocalizationKeys.failedToLoadShopItems: 'Falha ao carregar itens da loja',
      LocalizationKeys.noItemsAvailable: 'Nenhum item disponível',
      LocalizationKeys.successfullyPurchased: 'Comprado com sucesso',
      LocalizationKeys.failedToPurchase: 'Falha na compra',
      LocalizationKeys.failedToLoadLeaderboard:
          'Falha ao carregar classificação',

      // Land Map
      LocalizationKeys.back: 'Voltar',
      LocalizationKeys.yourLand: 'Sua Terra (Res 8)',
      LocalizationKeys.selectedLand: 'Terra Selecionada (Res 8)',
      LocalizationKeys.sell: 'Vender',
      LocalizationKeys.landPurchasedSuccessfully: 'Terra comprada com sucesso!',
      LocalizationKeys.landSoldSuccessfully: 'Terra vendida com sucesso!',
      LocalizationKeys.purchaseFailed: 'Falha na compra',
      LocalizationKeys.saleFailed: 'Falha na venda',
      LocalizationKeys.landDailyIncomeInfo:
          'Comprar terra dá renda diária de 50 HC que você pode reivindicar a cada 24 horas',

      // Land Income Claim
      LocalizationKeys.landIncomeClaimedSuccessfully:
          'Renda da terra reivindicada com sucesso!',
      LocalizationKeys.landIncomeClaimFailed:
          'Falha ao reivindicar renda da terra',
      LocalizationKeys.claimReady: 'Pronto!',
      LocalizationKeys.claimCooldown: 'Tempo de Espera',
      LocalizationKeys.claimAvailable: 'Disponível para reivindicar',
      LocalizationKeys.nextClaimIn: 'Próxima reivindicação em',
      LocalizationKeys.noIncomeAvailable: 'Ainda não há renda para reivindicar',
      LocalizationKeys.landTiles: 'lotes de terra',
      LocalizationKeys.readyToClaim: 'pronto para reivindicar',
      LocalizationKeys.lastClaimedAt: 'Última reivindicação',
      LocalizationKeys.claim: 'Reivindicar',
      LocalizationKeys.generatingIncome: 'gerando renda...',

      // Errors and Validation
      LocalizationKeys.error: 'Erro',
      LocalizationKeys.statsLoading: 'Carregando estatísticas...',
      LocalizationKeys.forgotPassword: 'Esqueceu a Senha?',
      LocalizationKeys.dontHaveAccount: 'Não tem uma conta?',
      LocalizationKeys.alreadyHaveAccount: 'Já tem uma conta?',
      LocalizationKeys.emailIsRequired: 'Email é obrigatório',
      LocalizationKeys.pleaseEnterValidEmail:
          'Por favor, insira um email válido',
      LocalizationKeys.adNotReadyTryAgain:
          'Anúncio não está pronto ainda. Tente novamente em um momento.',

      // Time and Status
      LocalizationKeys.hrsLeft: 'horas restantes',
      LocalizationKeys.next: 'Próximo',

      // Leaderboard
      LocalizationKeys.you: 'Você',
      LocalizationKeys.rankPoints: 'Pontos de Ranking',
      LocalizationKeys.leaderboardDisclaimer:
          'Desafio Semanal • Reinicia Segunda (Horário AO)',
      LocalizationKeys.top3Rewards: '🏆 Top 3 Ganham Prêmios!',

      // Access Control
      LocalizationKeys.unlockFeature: 'Desbloquear Recurso',
      LocalizationKeys.bronzeKey: 'Chave de Bronze',
      LocalizationKeys.getBronzeKeyMessage:
          'Obtenha sua Chave de Bronze na loja para desbloquear este recurso incrível!',
      LocalizationKeys.keysExpireMessage: 'As chaves dão 3 horas de acesso.',
      LocalizationKeys.getFromShop: 'obter na loja',
      LocalizationKeys.unlockExcitingFeature:
          'desbloquear este recurso incrível',
      LocalizationKeys.needItemForFeature:
          'Você precisa de uma {item} para este recurso.',

      // Payout
      LocalizationKeys.getPaid: 'Reclamar Prêmio',
      LocalizationKeys.selectPayoutMethod: 'Selecionar Entrega de Prêmio',
      LocalizationKeys.phoneNumber: 'Número de Telefone',
      LocalizationKeys.accountHolderName: 'Nome do Titular',
      LocalizationKeys.multicaixaExpressDetails:
          'Detalhes do Multicaixa Express',
      LocalizationKeys.cryptoDetails: 'Detalhes da Transferência Cripto',
      LocalizationKeys.walletAddress: 'Endereço da Carteira',
      LocalizationKeys.cryptoNetwork: 'Rede',
      LocalizationKeys.selectNetwork: 'Selecionar Rede',
      LocalizationKeys.enterWalletAddress: 'Digite o endereço da sua carteira',
      LocalizationKeys.enterFullName: 'Digite seu nome completo',
      LocalizationKeys.enterBankName: 'Digite o nome do banco',
      LocalizationKeys.payoutAmount: 'Valor do Prêmio (HC)',
      LocalizationKeys.requestPayout: 'Reclamar Prêmio',
      LocalizationKeys.phoneNumberRequired: 'Número de telefone é obrigatório',
      LocalizationKeys.accountHolderNameRequired:
          'Nome do titular da conta é obrigatório',

      LocalizationKeys.networkRequired: 'Rede é obrigatória',
      LocalizationKeys.walletAddressRequired:
          'Endereço da carteira é obrigatório',
      LocalizationKeys.amountRequired: 'Valor é obrigatório',
      LocalizationKeys.enterValidAmount: 'Digite um valor válido',
      LocalizationKeys.rewardsHistory: 'Histórico de Recompensas',
      LocalizationKeys.noRewardsHistory: 'Sem Histórico de Recompensas',
      LocalizationKeys.noPayoutRequests:
          'Você ainda não fez nenhum pedido de pagamento.',

      // Settings
      LocalizationKeys.credits: 'Créditos',
      LocalizationKeys.general: 'GERAL',
      LocalizationKeys.gameplay: 'JOGO',
      LocalizationKeys.about: 'SOBRE',
      LocalizationKeys.pushNotifications: 'Notificações Push',
      LocalizationKeys.pushNotificationsDesc:
          'Receber notificações sobre recompensas',
      LocalizationKeys.soundEffects: 'Efeitos Sonoros',
      LocalizationKeys.soundEffectsDesc: 'Ativar efeitos sonoros no aplicativo',
      LocalizationKeys.hapticFeedback: 'Feedback Tátil',
      LocalizationKeys.hapticFeedbackDesc: 'Vibração ao pressionar botões',
      LocalizationKeys.autoCollectRewards: 'Auto-Coletar Recompensas',
      LocalizationKeys.autoCollectRewardsDesc:
          'Coletar automaticamente recompensas disponíveis',
      LocalizationKeys.creditsDesc: 'Ver créditos e atribuições do aplicativo',
      LocalizationKeys.appVersion: 'Versão do App',

      // Credits
      LocalizationKeys.founderVisionary: 'Fundador e Visionário',
      LocalizationKeys.development: 'DESENVOLVIMENTO',
      LocalizationKeys.leadDeveloper: 'Desenvolvedor Principal',
      LocalizationKeys.madeWithLove: 'Feito com ❤️',

      // Events
      LocalizationKeys.noEventsYet: 'Ainda Sem Eventos',
      LocalizationKeys.eventsComingSoon:
          'Eventos emocionantes em breve!\nFique atento às atualizações.',
      LocalizationKeys.comingSoon: 'Em Breve',

      // Safe Lock
      LocalizationKeys.safeLock: 'Cofre Seguro',
      LocalizationKeys.safeLockSavings: 'Poupança de Cofre Seguro',
      LocalizationKeys.lockYourHcForRewards:
          'Bloqueie seu HC por 7 dias e ganhe recompensas!',
      LocalizationKeys.minimumRewardGuaranteed:
          'Recompensa mínima: 30 HC + possível bônus de item',
      LocalizationKeys.yourBalance: 'Seu Saldo:',
      LocalizationKeys.lockedAmount: 'Valor Bloqueado:',
      LocalizationKeys.locked: 'Bloqueado',
      LocalizationKeys.timeRemaining: 'Tempo Restante:',
      LocalizationKeys.claimRewards: 'Reivindicar Recompensas',
      LocalizationKeys.depositAmount: 'Valor do Depósito',
      LocalizationKeys.enterHcAmount: 'Digite a quantidade de HC',
      LocalizationKeys.depositToSafeLock: 'Depositar no Cofre Seguro',
      LocalizationKeys.addMoreTimerResets:
          'Adicionar Mais (Temporizador Reinicia)',
      LocalizationKeys.depositingAgainResetsTimer:
          '⚠️ Depositar novamente reiniciará o temporizador de 7 dias',
      LocalizationKeys.howItWorks: 'Como Funciona',
      LocalizationKeys.safeLockInfo1: 'Deposite HC e bloqueie por 7 dias',
      LocalizationKeys.safeLockInfo2:
          'O temporizador reinicia se você depositar novamente',
      LocalizationKeys.safeLockInfo3:
          'Ganhe recompensas com base na sua atividade',
      LocalizationKeys.safeLockInfo4:
          'Usuários ativos podem receber itens bônus',
      LocalizationKeys.safeLockInfo5: 'Recompensa mínima de 30 HC garantida',
      LocalizationKeys.success: 'Sucesso!',
      LocalizationKeys.congratulationsExclaim: '🎉 Parabéns! 🎉',
      LocalizationKeys.returned: 'Devolvido:',
      LocalizationKeys.reward: 'Recompensa:',
      LocalizationKeys.youReceivedAnItem: 'Você recebeu um item!',
      LocalizationKeys.newBalance: 'Novo Saldo:',
      LocalizationKeys.awesome: 'Incrível!',
      LocalizationKeys.pleaseEnterValidAmount:
          'Por favor, insira um valor válido',
      LocalizationKeys.insufficientBalance: 'Saldo insuficiente',

      // Tutorial
      LocalizationKeys.tutorialHcBalanceTitle: 'Seu Saldo HC',
      LocalizationKeys.tutorialHcBalanceDesc:
          'Isso mostra seu saldo de HustleCoin (HC) e valor potencial de prêmio em Kwanza. Complete tarefas para ganhar mais HC!',
      LocalizationKeys.tutorialEarnTasksTitle: 'Tarefas para Ganhar HC',
      LocalizationKeys.tutorialEarnTasksDesc:
          'Toque nesses botões para completar tarefas e ganhar HustleCoins! Toque Diário, Ver Anúncios e Quiz são ótimas formas de ganhar.',
      LocalizationKeys.tutorialPremiumFeaturesTitle: 'Recursos Premium',
      LocalizationKeys.tutorialPremiumFeaturesDesc:
          'Acesse recursos premium aqui! Explore Terra, Cofre Seguro para armazenar HC e Eventos para oportunidades especiais.',
      LocalizationKeys.tutorialGetPaidTitle: 'Reclamar Prêmios',
      LocalizationKeys.tutorialGetPaidDesc:
          'Quando você tiver ganhado HC suficiente, toque aqui para reclamar seus prêmios!',
      LocalizationKeys.tutorialProfileTitle: 'Seu Perfil',
      LocalizationKeys.tutorialProfileDesc:
          'Toque aqui para atualizar suas informações de perfil, verificar suas estatísticas de trabalho e ver seu inventário de itens!',
      LocalizationKeys.tutorialWelcomeTitle: 'Você Está Pronto!',
      LocalizationKeys.tutorialWelcomeDesc:
          'Comece a ganhar HustleCoins e construa seu império de trabalho!',
      LocalizationKeys.tutorialLetsStart: 'Vamos Começar.',

      // Upgrade Popup
      LocalizationKeys.levelUpgrade: 'Atualização de Nível {level}',
      LocalizationKeys.current: 'Atual',
      LocalizationKeys.required: 'Necessário',
      LocalizationKeys.days: 'dias',
      LocalizationKeys.fee: 'taxa',
      LocalizationKeys.stillNeed: 'Ainda precisa',

      // Games
      LocalizationKeys.miniGames: 'Jogue para Ganhar HC',
      LocalizationKeys.gameRunnerTitle: 'Corrida Hustle',
      LocalizationKeys.gameSnakeTitle: 'Cobra Retro',
      LocalizationKeys.gameSeagullTitle: 'Disputa de Gaivotas',
      LocalizationKeys.gamePongTitle: 'Pong Pixel',
      LocalizationKeys.runnerInstruction:
          'Desvie de obstáculos e colete moedas!',
      LocalizationKeys.snakeInstruction:
          'Clássico jogo da cobrinha. Coma para crescer!',
      LocalizationKeys.seagullInstruction: 'Toque para voar e evite colisões',
      LocalizationKeys.pongInstruction:
          'Vença a IA neste clássico jogo de tênis',
      LocalizationKeys.gameBalloonPopTitle: 'Estourar Balões',
      LocalizationKeys.balloonPopInstruction:
          'Estoure balões para pontuar! Não deixe eles voarem.',
      LocalizationKeys.play: 'JOGAR',
      LocalizationKeys.playAgain: 'JOGAR NOVAMENTE',
      LocalizationKeys.tapToJump: 'Toque para Pular',
      LocalizationKeys.swipeToMove: 'Deslize para Mover',
      LocalizationKeys.tapToFlap: 'Toque para Voar',
      LocalizationKeys.serve: 'SACAR',
      LocalizationKeys.rematch: 'REVANCHE',
      LocalizationKeys.exit: 'SAIR',
      LocalizationKeys.startGame: 'INICIAR JOGO',
      LocalizationKeys.gameOver: 'FIM DE JOGO',
      LocalizationKeys.score: 'Pontuação',
      LocalizationKeys.youWin: 'VOCÊ VENCEU!',
      LocalizationKeys.aiWins: 'IA VENCEU!',
      LocalizationKeys.firstTo5: 'PRIMEIRO A 5',
      LocalizationKeys.winner: 'VENCEDOR',
      LocalizationKeys.goal: 'Objetivo',
      LocalizationKeys.winMatch: 'Vencer Partida',
      LocalizationKeys.playGames: 'JOGAR',

      // Level Benefits
      LocalizationKeys.levelBenefits: 'BENEFÍCIOS DE NÍVEL',
      LocalizationKeys.multiplierTitle: 'MULTIPLICADOR',
      LocalizationKeys.multiplierDesc: 'Aumenta ganhos de HC em todas tarefas.',
      LocalizationKeys.landTitle: 'TERRA',
      LocalizationKeys.landDesc: 'Desbloqueia mais lotes para seu império.',
      LocalizationKeys.legacyTitle: 'LEGADO',
      LocalizationKeys.legacyDesc: 'Acesse trabalhos exclusivos de alto nível.',
      LocalizationKeys.closeDialog: '[ FECHAR ]',
    },
  };
}

// Localization provider that gets the user's language from the server
final localizationProvider = Provider<String>((ref) {
  final user = ref.watch(userControllerProvider).value;
  return user?.language.toLowerCase() ?? 'en';
});

// Helper function to get localized text
String getLocalizedText(String key, WidgetRef ref) {
  final currentLanguage = ref.watch(localizationProvider);
  final translations =
      _Translations.translations[currentLanguage] ??
      _Translations.translations['en']!;
  return translations[key] ?? key;
}

// Extension for easy access to localized strings
extension LocalizationExtension on WidgetRef {
  String t(String key) {
    return getLocalizedText(key, this);
  }
}
