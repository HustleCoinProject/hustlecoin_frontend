import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/state/all_states.dart';

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
    },
  };
}

// Localization provider that gets the user's language
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
