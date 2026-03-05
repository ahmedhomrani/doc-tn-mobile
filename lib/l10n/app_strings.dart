import 'package:flutter/material.dart';

class AppStrings {
  static String of(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    return _translations[locale]?[key] ?? _translations['en']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // ── Welcome Screen ──
      'app_name': 'MediCare',
      'app_tagline':
          'Your personal health companion.\nConsult doctors, track your health,\nmanage your prescriptions.',
      'feature_doctors': 'Top\nDoctors',
      'feature_booking': 'Easy\nBooking',
      'feature_rx': 'Rx\nTracking',
      'get_started': 'Get Started — It\'s Free',
      'already_have_account': 'I already have an account',
      'terms_prefix': 'By continuing, you agree to our ',
      'terms_of_use': 'Terms of Use',
      'privacy_policy': 'Privacy Policy',
      'and': 'and',

      // ── Register Screen ──
      'create_account_title': 'Create an account ✨',
      'create_account_subtitle':
          'Join MediCare and take control of your health',
      'full_name': 'Full Name',
      'email': 'Email Address',
      'phone': 'Phone Number',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'accept_terms_error': 'Please accept the terms to continue',
      'create_account_btn': 'Create Account ✨',
      'already_account_prefix': 'Already have an account? ',
      'sign_in': 'Sign In',

      // ── Login Screen ──
      'login_title': 'Welcome back 👋',
      'login_subtitle': 'Sign in to your MediCare account',
      'forgot_password': 'Forgot password?',
      'login_btn': 'Sign In',
      'or_continue_with': 'or continue with',
      'no_account_prefix': 'Don\'t have an account? ',
      'sign_up': 'Sign Up',

      // ── Home Screen ──
      'welcome_back': 'Welcome back,',
      'user_name': 'Sarah Jenkins',
      'search_hint': 'Find doctors, clinics, drugs...',
      'upcoming': 'UPCOMING',
      'doctor_name': 'Dr. Alisha P.',
      'doctor_specialty': 'Cardiologist • Heart Center',
      'today': 'Today',
      'appointment_time': '10:30 AM',
      'doctors': 'Doctors',
      'meds': 'Meds',
      'records': 'Records',
      'chat': 'Chat',
      'todays_meds': "Today's Meds",
      'see_all': 'See All',
      'vitamin_d3': 'Vitamin D3',
      'vitamin_subtitle': '1 pill • After meal',
      'amoxicillin': 'Amoxicillin',
      'amoxicillin_subtitle': '500mg • Before meal',
      'my_vitals': 'My Vitals',
      'heart_rate': 'Heart Rate',
      'sleep': 'Sleep',
      'now': 'Now',
      'avg': 'Avg',
      'home': 'Home',
      'appts': 'Appts',
      'bpm': 'bpm',
      'hrs': 'hrs',
    },

    'fr': {
      // ── Welcome Screen ──
      'app_name': 'MediCare',
      'app_tagline':
          'Votre compagnon de santé personnel.\nConsultez des médecins, suivez votre\nsanté, gérez vos ordonnances.',
      'feature_doctors': 'Meilleurs\nMédecins',
      'feature_booking': 'Réservation\nFacile',
      'feature_rx': 'Suivi\nRx',
      'get_started': 'Commencer — C\'est Gratuit',
      'already_have_account': 'J\'ai déjà un compte',
      'terms_prefix': 'En continuant, vous acceptez nos ',
      'terms_of_use': 'Conditions d\'utilisation',
      'privacy_policy': 'Politique de confidentialité',
      'and': 'et',

      // ── Register Screen ──
      'create_account_title': 'Créer un compte ✨',
      'create_account_subtitle':
          'Rejoignez MediCare et prenez le contrôle de votre santé',
      'full_name': 'Nom Complet',
      'email': 'Adresse E-Mail',
      'phone': 'Numéro de Téléphone',
      'password': 'Mot de Passe',
      'confirm_password': 'Confirmer le Mot de Passe',
      'accept_terms_error': 'Veuillez accepter les conditions pour continuer',
      'create_account_btn': 'Créer un compte ✨',
      'already_account_prefix': 'Vous avez déjà un compte ? ',
      'sign_in': 'Se connecter',

      // ── Login Screen ──
      'login_title': 'Bon retour 👋',
      'login_subtitle': 'Connectez-vous à votre compte MediCare',
      'forgot_password': 'Mot de passe oublié ?',
      'login_btn': 'Se connecter',
      'or_continue_with': 'ou continuer avec',
      'no_account_prefix': 'Pas de compte ? ',
      'sign_up': 'S\'inscrire',

      // ── Home Screen ──
      'welcome_back': 'Bon retour,',
      'user_name': 'Sarah Jenkins',
      'search_hint': 'Trouver médecins, cliniques, médicaments...',
      'upcoming': 'À VENIR',
      'doctor_name': 'Dr. Alisha P.',
      'doctor_specialty': 'Cardiologue • Centre Cardiaque',
      'today': 'Aujourd\'hui',
      'appointment_time': '10h30',
      'doctors': 'Médecins',
      'meds': 'Médicaments',
      'records': 'Dossiers',
      'chat': 'Chat',
      'todays_meds': 'Médicaments du jour',
      'see_all': 'Voir tout',
      'vitamin_d3': 'Vitamine D3',
      'vitamin_subtitle': '1 comprimé • Après repas',
      'amoxicillin': 'Amoxicilline',
      'amoxicillin_subtitle': '500mg • Avant repas',
      'my_vitals': 'Mes Constantes',
      'heart_rate': 'Fréq. cardiaque',
      'sleep': 'Sommeil',
      'now': 'Maintenant',
      'avg': 'Moy.',
      'home': 'Accueil',
      'appts': 'RDV',
      'bpm': 'bpm',
      'hrs': 'hrs',
    },

    'ar': {
      // ── Welcome Screen ──
      'app_name': 'ميديكير',
      'app_tagline':
          'رفيقك الصحي الشخصي.\nاستشر الأطباء، تابع صحتك،\nأدر وصفاتك الطبية.',
      'feature_doctors': 'أفضل\nالأطباء',
      'feature_booking': 'حجز\nسهل',
      'feature_rx': 'تتبع\nالدواء',
      'get_started': 'ابدأ الآن — مجاناً',
      'already_have_account': 'لدي حساب بالفعل',
      'terms_prefix': 'بالمتابعة، أنت توافق على ',
      'terms_of_use': 'شروط الاستخدام',
      'privacy_policy': 'سياسة الخصوصية',
      'and': 'و',

      // ── Register Screen ──
      'create_account_title': 'إنشاء حساب ✨',
      'create_account_subtitle': 'انضم إلى ميديكير وتحكم في صحتك',
      'full_name': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'phone': 'رقم الهاتف',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'accept_terms_error': 'يرجى قبول الشروط للمتابعة',
      'create_account_btn': 'إنشاء حساب ✨',
      'already_account_prefix': 'لديك حساب بالفعل؟ ',
      'sign_in': 'تسجيل الدخول',

      // ── Login Screen ──
      'login_title': 'مرحباً بعودتك 👋',
      'login_subtitle': 'سجّل دخولك إلى حساب ميديكير',
      'forgot_password': 'نسيت كلمة المرور؟',
      'login_btn': 'تسجيل الدخول',
      'or_continue_with': 'أو تابع باستخدام',
      'no_account_prefix': 'ليس لديك حساب؟ ',
      'sign_up': 'إنشاء حساب',

      // ── Home Screen ──
      'welcome_back': 'مرحباً بعودتك،',
      'user_name': 'سارة جنكينز',
      'search_hint': 'ابحث عن أطباء، عيادات، أدوية...',
      'upcoming': 'القادم',
      'doctor_name': 'د. عليشا ب.',
      'doctor_specialty': 'طبيبة قلب • مركز القلب',
      'today': 'اليوم',
      'appointment_time': '10:30 صباحاً',
      'doctors': 'أطباء',
      'meds': 'أدوية',
      'records': 'سجلات',
      'chat': 'دردشة',
      'todays_meds': 'أدوية اليوم',
      'see_all': 'عرض الكل',
      'vitamin_d3': 'فيتامين د3',
      'vitamin_subtitle': 'حبة واحدة • بعد الأكل',
      'amoxicillin': 'أموكسيسيلين',
      'amoxicillin_subtitle': '500 ملغ • قبل الأكل',
      'my_vitals': 'مؤشراتي الحيوية',
      'heart_rate': 'معدل ضربات القلب',
      'sleep': 'النوم',
      'now': 'الآن',
      'avg': 'متوسط',
      'home': 'الرئيسية',
      'appts': 'المواعيد',
      'bpm': 'نبضة/د',
      'hrs': 'ساعات',
    },
  };
}
