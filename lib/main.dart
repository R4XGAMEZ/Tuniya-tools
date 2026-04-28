import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'services/settings_service.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/all_tools_screen.dart';
import 'screens/placeholder_tool_screen.dart';
// ─── Implemented tool screens ───────────────────────────────────────────────
import 'screens/text_to_pdf_screen.dart';
import 'screens/pdf_to_text_screen.dart';
import 'screens/image_to_pdf_screen.dart';
import 'screens/zip_extract_screen.dart';
import 'screens/folder_to_zip_screen.dart';
import 'screens/pdf_merger_screen.dart';
import 'screens/pdf_splitter_screen.dart';
import 'screens/batch_rename_screen.dart';
import 'screens/file_info_screen.dart';
import 'screens/zip_compressor_screen.dart';
import 'screens/case_converter_screen.dart';
import 'screens/word_counter_screen.dart';
import 'screens/find_replace_screen.dart';
import 'screens/base64_screen.dart';
import 'screens/lorem_ipsum_screen.dart';
import 'screens/morse_code_screen.dart';
import 'screens/list_sort_screen.dart';
import 'screens/upside_down_screen.dart';
import 'screens/sql_formatter_screen.dart';
import 'screens/regex_tester_screen.dart';
import 'screens/word_cloud_screen.dart';
import 'screens/html_to_markdown_screen.dart';
// ─── Media Studio screens ────────────────────────────────────────────────────
import 'screens/media/video_compressor_screen.dart';
import 'screens/media/video_to_gif_screen.dart';
import 'screens/media/video_frame_screen.dart';
import 'screens/media/audio_joiner_screen.dart';
import 'screens/media/volume_booster_screen.dart';
import 'screens/media/bass_booster_screen.dart';
import 'screens/media/slowed_reverb_screen.dart';
import 'screens/media/noise_remover_screen.dart';
import 'screens/media/batch_video_mp3_screen.dart';
import 'screens/media/color_palette_screen.dart';
import 'screens/media/circular_crop_screen.dart';
import 'screens/media/collage_maker_screen.dart';
import 'screens/media/metadata_stripper_screen.dart';
import 'screens/media/batch_image_compress_screen.dart';
import 'screens/media/dominant_color_screen.dart';
// ─── AI Tool screens ─────────────────────────────────────────────────────────
import 'screens/ai/ai_chat_screen.dart';
import 'screens/ai/ai_text_writer_screen.dart';
import 'screens/ai/ai_image_gen_screen.dart';
import 'screens/ai/ai_code_helper_screen.dart';
import 'screens/ai/ai_pdf_summarizer_screen.dart';
import 'screens/ai/ai_translator_screen.dart';
import 'screens/ai/ai_fix_anything_screen.dart';
import 'screens/ai/ai_resume_screen.dart';
import 'screens/ai/ai_grammar_screen.dart';
import 'screens/ai/ai_social_bio_screen.dart';
import 'screens/ai/ai_keyword_gen_screen.dart';
// ─── v5 Developer / Utility screens (merged in v8) ───────────────────────────
import 'screens/base_converter_screen.dart';
import 'screens/color_picker_screen.dart';
import 'screens/csv_json_converter_screen.dart';
import 'screens/hash_generator_screen.dart';
import 'screens/list_alphabetizer_screen.dart';
import 'screens/password_generator_screen.dart';
import 'screens/password_strength_screen.dart';
import 'screens/percentage_calculator_screen.dart';
import 'screens/bmi_calculator_screen.dart';
import 'screens/age_calculator_screen.dart';
import 'screens/scientific_calculator_screen.dart';
// ─── Text Tools screens (v9 complete) ─────────────────────────────────────
import 'screens/text_tone_detector_screen.dart';
import 'screens/reading_time_calc_screen.dart';
import 'screens/simple_paraphrase_screen.dart';
import 'screens/speech_pace_checker_screen.dart';
// ─── Gamer Zone screens ────────────────────────────────────────────────────
import 'screens/gaming/sensitivity_notes_screen.dart';
import 'screens/gaming/game_session_timer_screen.dart';
import 'screens/gaming/clip_reminder_screen.dart';
import 'screens/gaming/squad_planner_screen.dart';
// ─── Student screens (v11 merge) ─────────────────────────────────────────────
import 'screens/student/ai_notes_summarizer_screen.dart';
import 'screens/student/ai_homework_helper_screen.dart';
import 'screens/student/ai_quiz_gen_screen.dart';
import 'screens/student/ai_explain_simple_screen.dart';
import 'screens/student/ai_mcq_maker_screen.dart';
import 'screens/student/math_step_helper_screen.dart';
import 'screens/student/flashcard_maker_screen.dart';
import 'screens/student/exam_countdown_screen.dart';
import 'screens/student/study_timer_screen.dart';
import 'screens/student/formula_vault_screen.dart';
import 'screens/student/essay_writer_screen.dart';
import 'screens/student/study_schedule_screen.dart';
import 'screens/student/vocab_builder_screen.dart';
import 'screens/student/speech_practice_screen.dart';
import 'screens/student/homework_planner_screen.dart';
import 'screens/student/interview_practice_screen.dart';
import 'screens/student/topic_explainer_screen.dart';
import 'screens/student/career_path_screen.dart';
import 'screens/student/study_session_screen.dart';
import 'screens/student/memory_quiz_maker_screen.dart';
import 'screens/student/random_topic_picker_screen.dart';
import 'screens/student/notes_to_quiz_screen.dart';
import 'screens/student/revision_planner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  // Init settings
  await SettingsService().init();
  runApp(const TuniyaToolsApp());
}
class TuniyaToolsApp extends StatelessWidget {
  const TuniyaToolsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TUNIYA TOOLS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    // Core screens
    switch (name) {
      case '/':
        return _route(const IntroScreen());
      case '/home':
        return _route(const HomeScreen());
      case '/settings':
        return _route(const SettingsScreen());
      case '/all-tools':
        return _route(const AllToolsScreen());
    }
    // All tool routes — extract tool id from route name (e.g. '/text-to-pdf' → 'text_to_pdf')
    // Map route names to tool IDs
    final toolRouteMap = <String, String>{
      '/text-to-pdf': 'text_to_pdf',
      '/pdf-to-text': 'pdf_to_text',
      '/image-to-pdf': 'image_to_pdf',
      '/pdf-to-images': 'pdf_to_images',
      '/folder-to-zip': 'folder_to_zip',
      '/folder-to-jar': 'folder_to_jar',
      '/zip-extract': 'zip_extract',
      '/jar-extract': 'jar_extract',
      '/file-rename-batch': 'file_rename_batch',
      '/pdf-password': 'pdf_password',
      '/zip-password': 'zip_password',
      '/file-password': 'file_password',
      '/zip-compressor': 'zip_compressor',
      '/file-info': 'file_info',
      '/link-generator': 'link_generator',
      '/pdf-merger': 'pdf_merger',
      '/pdf-splitter': 'pdf_splitter',
      '/pdf-watermark': 'pdf_watermark',
      '/pdf-rotate': 'pdf_rotate',
      '/excel-to-pdf': 'excel_to_pdf',
      '/find-replace': 'find_replace',
      '/case-converter': 'case_converter',
      '/word-counter': 'word_counter',
      '/base64': 'base64',
      '/lorem-ipsum': 'lorem_ipsum',
      '/morse-code': 'morse_code',
      '/list-sort': 'list_sort',
      '/upside-down': 'upside_down_text',
      '/sql-formatter': 'sql_formatter',
      '/regex-tester': 'regex_tester',
      '/word-cloud': 'word_cloud',
      '/html-to-md': 'html_to_markdown',
      '/text-tone': 'text_tone_detector',
      '/reading-time': 'reading_time_calc',
      '/paraphrase': 'simple_paraphrase',
      '/speech-pace': 'speech_pace_checker',
      '/media-converter': 'media_converter',
      '/noise-remover': 'noise_remover',
      '/volume-booster': 'volume_booster',
      '/bass-booster': 'bass_booster',
      '/slowed-reverb': 'slowed_reverb',
      '/video-compressor': 'video_compressor',
      '/image-editor': 'image_editor',
      '/image-upscaler': 'image_upscaler',
      '/image-expand': 'image_expand',
      '/video-to-gif': 'video_to_gif',
      '/audio-joiner': 'audio_joiner',
      '/bg-remover': 'bg_remover',
      '/video-frame': 'video_frame',
      '/batch-video-mp3': 'batch_video_to_mp3',
      '/color-palette': 'color_palette',
      '/metadata-stripper': 'metadata_stripper',
      '/batch-image-compress': 'batch_image_compressor',
      '/bulk-image-resize': 'bulk_image_resizer',
      '/gif-maker': 'gif_maker',
      '/circular-crop': 'circular_crop',
      '/collage-maker': 'collage_maker',
      '/meme-gen': 'meme_generator',
      '/insta-grid': 'instagram_grid',
      '/blur-bg': 'blur_bg',
      '/ocr': 'ocr_tool',
      '/mp3-autotagger': 'mp3_autotagger',
      '/yt-downloader': 'yt_downloader',
      '/fb-downloader': 'fb_downloader',
      '/twitter-downloader': 'twitter_downloader',
      '/wa-status': 'wa_status',
      '/insta-downloader': 'insta_downloader',
      '/terabox-downloader': 'terabox_downloader',
      '/pinterest-downloader': 'pinterest_downloader',
      '/telegram-downloader': 'telegram_downloader',
      '/ai-chat': 'ai_chat',
      '/ai-text-writer': 'ai_text_writer',
      '/ai-image-gen': 'ai_image_gen',
      '/ai-code-helper': 'ai_code_helper',
      '/ai-audio-transcribe': 'ai_audio_transcribe',
      '/ai-pdf-summarizer': 'ai_pdf_summarizer',
      '/ai-translator': 'ai_translator',
      '/yt-analyzer': 'yt_analyzer',
      '/ai-fix-anything': 'ai_fix_anything',
      '/voice-assistant': 'voice_assistant',
      '/gender-change': 'gender_change',
      '/ai-resume': 'ai_resume',
      '/ai-grammar': 'ai_grammar',
      '/image-to-prompt': 'image_to_prompt',
      '/ai-social-bio': 'ai_social_bio',
      '/ai-keyword-gen': 'ai_keyword_gen',
      '/image-to-recipe': 'image_to_recipe',
      '/ai-website-builder': 'ai_website_builder',
      '/ai-doc-translator': 'ai_doc_translator',
      '/git-helper': 'git_helper',
      '/api-doc-gen': 'api_doc_gen',
      '/ai-lyrics': 'ai_lyrics_writer',
      '/ai-object-remover': 'ai_object_remover',
      '/python-editor': 'python_editor',
      '/java-editor': 'java_editor',
      '/cpp-editor': 'cpp_editor',
      '/js-editor': 'js_editor',
      '/html-editor': 'html_editor',
      '/php-editor': 'php_editor',
      '/kotlin-editor': 'kotlin_editor',
      '/shell-editor': 'shell_editor',
      '/json-editor': 'json_editor',
      '/xml-editor': 'xml_editor',
      '/hash-gen': 'hash_gen',
      '/device-info': 'device_info',
      '/jwt-debugger': 'jwt_debugger',
      '/color-contrast': 'color_contrast',
      '/cron-gen': 'cron_gen',
      '/webhook-tester': 'webhook_tester',
      '/csv-json': 'csv_json',
      '/base-converter': 'base_converter',
      '/aes-encrypt': 'aes_encrypt',
      '/deep-link': 'deep_link_tester',
      '/steganography': 'steganography',
      '/color-picker': 'color_picker',
      '/password-gen': 'password_gen',
      '/password-meter': 'password_meter',
      '/apk-extractor': 'apk_extractor',
      '/disposable-email': 'disposable_email',
      '/percent-calc': 'percentage_calc',
      '/sci-calculator': 'sci_calculator',
      '/dns-lookup': 'dns_lookup',
      '/port-scanner': 'port_scanner',
      '/ping-test': 'ping_test',
      '/whois': 'whois_lookup',
      '/ssl-checker': 'ssl_checker',
      '/ip-finder': 'ip_finder',
      '/speed-test': 'speed_test',
      '/mac-lookup': 'mac_lookup',
      '/redirect-checker': 'redirect_checker',
      '/web-to-pdf': 'web_to_pdf',
      '/proxy-checker': 'proxy_checker',
      '/storage-analyzer': 'storage_analyzer',
      '/junk-cleaner': 'junk_cleaner',
      '/battery-info': 'battery_info',
      '/sensor-feed': 'sensor_feed',
      '/sound-meter': 'sound_meter',
      '/compass': 'compass',
      '/secure-notes': 'secure_notes',
      '/invisible-vault': 'invisible_vault',
      '/file-shredder': 'file_shredder',
      '/wifi-qr': 'wifi_qr',
      '/fake-call': 'fake_call',
      '/sos-flashlight': 'sos_flashlight',
      '/anti-theft': 'anti_theft',
      '/qr-suite': 'qr_suite',
      '/unit-converter': 'unit_converter',
      '/link-vault': 'link_vault',
      '/temp-notes': 'temp_notes',
      '/direct-wa': 'direct_whatsapp',
      '/vcard-gen': 'vcard_gen',
      '/auto-typer': 'auto_typer',
      '/download-manager': 'download_manager',
      '/reverse-image': 'reverse_image',
      '/bmi': 'bmi_calculator',
      '/age-calc': 'age_calculator',
      '/world-clock': 'world_clock',
      '/medicine-reminder': 'medicine_reminder',
      '/rto-checker': 'rto_checker',
      '/emi-calc': 'emi_calculator',
      '/gst-calc': 'gst_calculator',
      '/invoice-gen': 'invoice_gen',
      '/crypto-tracker': 'crypto_tracker',
      '/secret-vault': 'secret_vault',
      '/reel-toolkit': 'reel_toolkit',
      '/ai-workflow': 'ai_workflow',
      '/smart-workspace': 'smart_workspace',
      '/share-kit': 'share_kit',
      '/scan-to-pdf': 'scan_to_pdf',
      '/universal-opener': 'universal_opener',
      '/app-lock': 'app_lock',
      '/favicon-downloader': 'favicon_downloader',
      '/source-viewer': 'source_viewer',
      '/graph-plotter': 'graph_plotter',
      '/robots-finder': 'robots_finder',
      '/dominant-color': 'dominant_color',
      // ─── Student Zone ────────────────────────────────────────────────────
      '/ai-notes-summarizer': 'ai_notes_summarizer',
      '/ai-homework-helper': 'ai_homework_helper',
      '/ai-quiz-gen': 'ai_quiz_gen',
      '/ai-explain-simple': 'ai_explain_simple',
      '/ai-mcq-maker': 'ai_mcq_maker',
      '/math-step-helper': 'math_step_helper',
      '/flashcard-maker': 'flashcard_maker',
      '/exam-countdown': 'exam_countdown',
      '/study-timer': 'study_timer',
      '/formula-vault': 'formula_vault',
      '/essay-writer': 'essay_writer',
      '/study-schedule': 'study_schedule',
      '/vocab-builder': 'vocab_builder',
      '/speech-practice': 'speech_practice',
      '/homework-planner': 'homework_planner',
      '/interview-practice': 'interview_practice',
      '/topic-explainer': 'topic_explainer',
      '/career-path': 'career_path',
      '/study-session': 'study_session_gen',
      '/memory-quiz': 'memory_quiz_maker',
      '/random-topic': 'random_topic_picker',
      '/notes-to-quiz': 'notes_to_quiz',
      '/revision-planner': 'revision_planner',
      // ─── Text extra ──────────────────────────────────────────────────────
      '/list-alpha': 'list_alphabetizer',
      // ─── Gamer Zone ──────────────────────────────────────────────────────
      '/sensitivity-notes': 'sensitivity_notes',
      '/game-session-timer': 'game_session_timer',
      '/clip-reminder': 'clip_reminder',
      '/squad-planner': 'squad_planner',
      // ─── Creator Zone (coming soon) ──────────────────────────────────────
      '/ai-caption-gen': 'ai_caption_gen',
      '/ai-hashtag-gen': 'ai_hashtag_gen',
      '/ai-thumbnail-text': 'ai_thumbnail_text',
      '/ai-script-writer': 'ai_script_writer',
      '/ai-hook-gen': 'ai_hook_gen',
      '/viral-hook-gen': 'viral_hook_gen',
      '/hook-script-caption': 'hook_script_caption',
      '/yt-title-checker': 'yt_title_checker',
      '/yt-desc-writer': 'yt_desc_writer',
      '/content-calendar': 'content_calendar',
      '/reel-ideas': 'reel_ideas',
      '/caption-rewrite': 'caption_rewrite',
      '/caption-by-mood': 'caption_by_mood',
      '/caption-bank': 'caption_bank',
      '/hashtag-vault': 'hashtag_vault',
      '/comment-reply-gen': 'comment_reply_gen',
      '/dm-reply-templates': 'dm_reply_templates',
      '/sponsor-pitch': 'sponsor_pitch',
      '/brand-deal-reply': 'brand_deal_reply',
      '/niche-finder': 'niche_finder',
      '/content-repurpose': 'content_repurpose',
      '/series-planner': 'series_planner',
      '/auto-hashtag-packs': 'auto_hashtag_packs',
      '/channel-growth': 'channel_growth',
      '/brand-kit': 'brand_kit',
      '/hook-analyzer': 'hook_analyzer',
      '/audience-persona': 'audience_persona',
      '/poll-ideas': 'poll_ideas',
      '/reel-script-topic': 'reel_script_topic',
      '/trend-notes': 'trend_notes',
      // ─── Productivity Zone (coming soon) ─────────────────────────────────
      '/saved-prompts': 'saved_prompts',
      '/long-msg-shortener': 'long_msg_shortener',
      '/reply-gen': 'reply_gen',
      '/idea-gen': 'idea_gen',
      '/daily-planner-ai': 'daily_planner_ai',
      '/prompt-improver': 'prompt_improver',
      '/task-breakdown': 'task_breakdown',
      '/focus-timer': 'focus_timer',
      '/routine-maker': 'routine_maker',
      '/habit-streak': 'habit_streak',
      '/water-reminder': 'water_reminder',
      '/spin-wheel': 'spin_wheel',
      '/mini-journal': 'mini_journal',
      '/second-brain': 'second_brain',
      '/voice-diary': 'voice_diary',
      '/custom-prompt-lib': 'custom_prompt_lib',
      '/goal-tracker-ai': 'goal_tracker_ai',
      '/mind-dump': 'mind_dump',
      '/day-starter-ai': 'day_starter_ai',
      '/night-review-ai': 'night_review_ai',
      '/procrastination-killer': 'procrastination_killer',
      '/weekly-reset': 'weekly_reset',
      '/mood-music': 'mood_music',
      '/ai-email-writer': 'ai_email_writer',
      '/life-stats': 'life_stats',
      '/convo-summarizer': 'convo_summarizer',
      '/morning-dashboard': 'morning_dashboard',
      // ─── Finance Zone (coming soon) ──────────────────────────────────────
      '/expense-tracker': 'expense_tracker',
      '/upi-qr-save': 'upi_qr_save',
      '/profit-calc': 'profit_calc',
      '/budget-planner': 'budget_planner',
      '/income-tracker': 'income_tracker',
      '/savings-goal': 'savings_goal',
      '/subscription-reminder': 'subscription_reminder',
      '/debt-payoff': 'debt_payoff',
      '/freelance-quote': 'freelance_quote',
      '/pricing-tool': 'pricing_tool',
      '/profit-margin': 'profit_margin',
      '/bill-reminder': 'bill_reminder',
      '/savings-challenge': 'savings_challenge',
      '/side-hustle-ai': 'side_hustle_ai',
      '/growth-kpi': 'growth_kpi',
      // ─── Business Zone (coming soon) ─────────────────────────────────────
      '/ai-ad-copy': 'ai_ad_copy',
      '/ai-product-desc': 'ai_product_desc',
      '/ai-sales-reply': 'ai_sales_reply',
      '/quotation-maker': 'quotation_maker',
      '/client-templates': 'client_templates',
      '/meeting-summarizer': 'meeting_summarizer',
      '/brand-name-gen': 'brand_name_gen',
      '/offer-gen': 'offer_gen',
      '/lead-tracker': 'lead_tracker',
      '/sales-script': 'sales_script',
      '/order-tracker': 'order_tracker',
      '/mini-crm': 'mini_crm',
      '/customer-reply': 'customer_reply',
      '/price-list': 'price_list',
      // ─── Privacy Zone (coming soon) ──────────────────────────────────────
      '/panic-button': 'panic_button',
      '/decoy-notes': 'decoy_notes',
      '/time-lock-notes': 'time_lock_notes',
      '/one-time-notes': 'one_time_notes',
      '/pin-log': 'pin_log',
      '/vault-search': 'vault_search',
      '/private-task': 'private_task',
      '/disguised-folder': 'disguised_folder',
      '/secure-clipboard': 'secure_clipboard',
      // ─── Media extra (coming soon) ────────────────────────────────────────
      '/image-to-webp': 'image_to_webp',
      '/audio-cutter': 'audio_cutter',
      '/story-resizer': 'story_resizer',
      '/meme-caption-overlay': 'meme_caption_overlay',
      '/audio-to-mp3': 'audio_to_mp3',
      '/photo-burst-cleaner': 'photo_burst_cleaner',
      '/doc-scanner': 'doc_scanner',
      // ─── Phone Tools (coming soon) ────────────────────────────────────────
      '/clipboard-manager': 'clipboard_manager',
      '/large-files': 'large_files',
      '/notif-history': 'notif_history',
      '/duplicate-contact': 'duplicate_contact',
      '/unused-apps': 'unused_apps',
      '/battery-charge-history': 'battery_charge_history',
      '/notif-organizer': 'notif_organizer',
      '/screenshot-search': 'screenshot_search',
      '/permission-checker': 'permission_checker',
      '/quick-copy-templates': 'quick_copy_templates',
      '/phone-specs': 'phone_specs',
      '/network-checker': 'network_checker',
      '/old-downloads': 'old_downloads',
      '/contact-backup': 'contact_backup',
      '/data-usage': 'data_usage',
      '/wifi-speed-log': 'wifi_speed_log',
      // ─── Misc (coming soon) ───────────────────────────────────────────────
      '/website-screenshot': 'website_screenshot',
      '/stylish-text': 'stylish_text',
      '/random-username': 'random_username',
      '/truth-dare': 'truth_dare',
      '/daily-motivation': 'daily_motivation',
      '/emergency-pack': 'emergency_pack',
      '/trip-splitter': 'trip_splitter',
      '/digital-locker': 'digital_locker',
      '/packing-ai': 'packing_ai',
      '/quick-notes-pad': 'quick_notes_pad',
      '/duplicate-photo': 'duplicate_photo',
      '/brainstorm': 'brainstorm',
      '/focus-task': 'focus_task',
      '/daily-question': 'daily_question',
      '/writing-prompt': 'writing_prompt',
      '/hook-words': 'hook_words',
      '/thumbnail-keywords': 'thumbnail_keywords',
      '/7day-challenge': '7day_challenge',
      '/reel-checklist': 'reel_checklist',
      '/niche-roulette': 'niche_roulette',
      '/series-counter': 'series_counter',
      '/cta-picker': 'cta_picker',
      '/old-media-sorter': 'old_media_sorter',
      '/folder-color-tags': 'folder_color_tags',
      '/temp-cleaner': 'temp_cleaner',
      '/share-history': 'share_history',
      '/storage-trend': 'storage_trend',
      '/rename-by-date': 'rename_by_date',
      '/habit-reflect': 'habit_reflect',
      '/decision-coin': 'decision_coin',
      '/privacy-checklist': 'privacy_checklist',
      '/hidden-reminders': 'hidden_reminders',
      '/mood-tracker': 'mood_tracker',
      '/grocery-list': 'grocery_list',
      '/lost-found': 'lost_found',
      '/app-privacy-notes': 'app_privacy_notes',
      '/password-hints': 'password_hints',
      '/weekend-budget': 'weekend_budget',
      '/queue-tracker': 'queue_tracker',
    };
    // ─── Implemented screens ──────────────────────────────────────
    switch (name) {
      case '/text-to-pdf':    return _route(const TextToPdfScreen());
      case '/pdf-to-text':    return _route(const PdfToTextScreen());
      case '/image-to-pdf':   return _route(const ImageToPdfScreen());
      case '/zip-extract':    return _route(const ZipExtractScreen());
      case '/folder-to-zip':  return _route(const FolderToZipScreen());
      case '/pdf-merger':     return _route(const PdfMergerScreen());
      case '/pdf-splitter':   return _route(const PdfSplitterScreen());
      case '/file-rename-batch': return _route(const BatchRenameScreen());
      case '/file-info':      return _route(const FileInfoScreen());
      case '/zip-compressor': return _route(const ZipCompressorScreen());
      case '/case-converter':  return _route(const CaseConverterScreen());
      case '/word-counter':    return _route(const WordCounterScreen());
      case '/find-replace':    return _route(const FindReplaceScreen());
      case '/base64':          return _route(const Base64Screen());
      case '/lorem-ipsum':     return _route(const LoremIpsumScreen());
      case '/morse-code':      return _route(const MorseCodeScreen());
      case '/list-sort':       return _route(const ListSortScreen());
      case '/upside-down':     return _route(const UpsideDownScreen());
      case '/sql-formatter':   return _route(const SqlFormatterScreen());
      case '/regex-tester':    return _route(const RegexTesterScreen());
      case '/word-cloud':      return _route(const WordCloudScreen());
      case '/html-to-md':           return _route(const HtmlToMarkdownScreen());
      case '/text-tone':            return _route(const TextToneDetectorScreen());
      case '/reading-time':         return _route(const ReadingTimeCalcScreen());
      case '/paraphrase':           return _route(const SimpleParaphraseScreen());
      case '/speech-pace':          return _route(const SpeechPaceCheckerScreen());
      // ─── Media Studio routes ──────────────────────────────────────
      case '/video-compressor':     return _route(const VideoCompressorScreen());
      case '/video-to-gif':         return _route(const VideoToGifScreen());
      case '/video-frame':          return _route(const VideoFrameScreen());
      case '/audio-joiner':         return _route(const AudioJoinerScreen());
      case '/volume-booster':       return _route(const VolumeBoosterScreen());
      case '/bass-booster':         return _route(const BassBoosterScreen());
      case '/slowed-reverb':        return _route(const SlowedReverbScreen());
      case '/noise-remover':        return _route(const NoiseRemoverScreen());
      case '/batch-video-mp3':      return _route(const BatchVideoToMp3Screen());
      case '/color-palette':        return _route(const ColorPaletteScreen());
      case '/circular-crop':        return _route(const CircularCropScreen());
      case '/collage-maker':        return _route(const CollageMakerScreen());
      case '/metadata-stripper':    return _route(const MetadataStripperScreen());
      case '/batch-image-compress':   return _route(const BatchImageCompressScreen());
      case '/dominant-color':       return _route(const DominantColorScreen());
      // ─── AI Tool routes ───────────────────────────────────────────
      case '/ai-chat':          return _route(const AiChatScreen());
      case '/ai-text-writer':   return _route(const AiTextWriterScreen());
      case '/ai-image-gen':     return _route(const AiImageGenScreen());
      case '/ai-code-helper':   return _route(const AiCodeHelperScreen());
      case '/ai-pdf-summarizer':return _route(const AiPdfSummarizerScreen());
      case '/ai-translator':    return _route(const AiTranslatorScreen());
      case '/ai-fix-anything':  return _route(const AiFixAnythingScreen());
      case '/ai-resume':        return _route(const AiResumeScreen());
      case '/ai-grammar':       return _route(const AiGrammarScreen());
      case '/ai-social-bio':    return _route(const AiSocialBioScreen());
      case '/ai-keyword-gen':   return _route(const AiKeywordGenScreen());
      // ─── v5 Developer / Utility routes (merged in v8) ────────────────
      case '/base-converter':       return _route(const BaseConverterScreen());
      case '/color-picker':         return _route(const ColorPickerScreen());
      case '/csv-json':             return _route(const CsvJsonConverterScreen());
      case '/hash-gen':             return _route(const HashGeneratorScreen());
      case '/list-alpha':           return _route(const ListAlphabetizerScreen());
      case '/password-gen':         return _route(const PasswordGeneratorScreen());
      case '/password-meter':       return _route(const PasswordStrengthScreen());
      case '/percent-calc':         return _route(const PercentageCalculatorScreen());
      case '/bmi':                  return _route(const BmiCalculatorScreen());
      case '/age-calc':             return _route(const AgeCalculatorScreen());
      case '/sci-calculator':       return _route(const ScientificCalculatorScreen());
      // ─── Gamer Zone ──────────────────────────────────────────────────────
      case '/sensitivity-notes':    return _route(const SensitivityNotesScreen());
      case '/game-session-timer':   return _route(const GameSessionTimerScreen());
      case '/clip-reminder':        return _route(const ClipReminderScreen());
      case '/squad-planner':        return _route(const SquadPlannerScreen());
      // ─── Student routes (v11 merge) ──────────────────────────────────
      case '/ai-notes-summarizer':  return _route(const AiNotesSummarizerScreen());
      case '/ai-homework-helper':   return _route(const AiHomeworkHelperScreen());
      case '/ai-quiz-gen':          return _route(const AiQuizGenScreen());
      case '/ai-explain-simple':    return _route(const AiExplainSimpleScreen());
      case '/ai-mcq-maker':         return _route(const AiMcqMakerScreen());
      case '/math-step-helper':     return _route(const MathStepHelperScreen());
      case '/flashcard-maker':      return _route(const FlashcardMakerScreen());
      case '/exam-countdown':       return _route(const ExamCountdownScreen());
      case '/study-timer':          return _route(const StudyTimerScreen());
      case '/formula-vault':        return _route(const FormulaVaultScreen());
      case '/essay-writer':         return _route(const EssayWriterScreen());
      case '/study-schedule':       return _route(const StudyScheduleScreen());
      case '/vocab-builder':        return _route(const VocabBuilderScreen());
      case '/speech-practice':      return _route(const SpeechPracticeScreen());
      case '/homework-planner':     return _route(const HomeworkPlannerScreen());
      case '/interview-practice':   return _route(const InterviewPracticeScreen());
      case '/topic-explainer':      return _route(const TopicExplainerScreen());
      case '/career-path':          return _route(const CareerPathScreen());
      case '/study-session':        return _route(const StudySessionScreen());
      case '/memory-quiz':          return _route(const MemoryQuizMakerScreen());
      case '/random-topic':         return _route(const RandomTopicPickerScreen());
      case '/notes-to-quiz':        return _route(const NotesToQuizScreen());
      case '/revision-planner':     return _route(const RevisionPlannerScreen());
    }
    if (toolRouteMap.containsKey(name)) {
      final toolId = toolRouteMap[name]!;
      return _route(PlaceholderToolScreen(toolId: toolId));
    }
    // 404 fallback
    return _route(const HomeScreen());
  }

  PageRoute _route(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
