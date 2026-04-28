import 'package:flutter/material.dart';

enum ToolCategory {
  file, text, media, downloader, ai, codeEditor,
  developer, utility, networking, system, business, lifestyle,
  creator, student, productivity, gaming, finance,
}
class ToolItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final ToolCategory category;
  final String routeName;
  final bool needsGemini;
  final bool needsClaude;
  final bool isOffline;
  const ToolItem({
    required this.id, required this.name, required this.description,
    required this.icon, required this.category, required this.routeName,
    this.needsGemini = false, this.needsClaude = false, this.isOffline = true,
  });
}

class ToolsData {
  static const List<ToolItem> all = [
    // ══════════════════════════════════════════
    // FILE TOOLS
    ToolItem(id:'text_to_pdf', name:'Text to PDF', description:'Text file ya typed text ko PDF banao', icon:Icons.picture_as_pdf_outlined, category:ToolCategory.file, routeName:'/text-to-pdf'),
    ToolItem(id:'pdf_to_text', name:'PDF to Text', description:'PDF ka text extract karo', icon:Icons.text_snippet_outlined, category:ToolCategory.file, routeName:'/pdf-to-text'),
    ToolItem(id:'image_to_pdf', name:'Image to PDF', description:'Multiple images ko PDF mein convert karo', icon:Icons.image_outlined, category:ToolCategory.file, routeName:'/image-to-pdf'),
    ToolItem(id:'pdf_to_images', name:'PDF to Images', description:'PDF ke har page ko image banao', icon:Icons.burst_mode_outlined, category:ToolCategory.file, routeName:'/pdf-to-images'),
    ToolItem(id:'folder_to_zip', name:'Folder to ZIP', description:'Poora folder ZIP mein pack karo', icon:Icons.folder_zip_outlined, category:ToolCategory.file, routeName:'/folder-to-zip'),
    ToolItem(id:'folder_to_jar', name:'Folder to JAR', description:'Poora folder JAR file mein pack karo', icon:Icons.inventory_2_outlined, category:ToolCategory.file, routeName:'/folder-to-jar'),
    ToolItem(id:'zip_extract', name:'ZIP Extract', description:'ZIP file extract karo kisi bhi folder mein', icon:Icons.unarchive_outlined, category:ToolCategory.file, routeName:'/zip-extract'),
    ToolItem(id:'jar_extract', name:'JAR Extract', description:'JAR file extract karo kisi bhi folder mein', icon:Icons.open_in_new_outlined, category:ToolCategory.file, routeName:'/jar-extract'),
    ToolItem(id:'file_rename_batch', name:'Batch Rename', description:'Multiple files ek saath rename karo', icon:Icons.drive_file_rename_outline, category:ToolCategory.file, routeName:'/file-rename-batch'),
    ToolItem(id:'pdf_password', name:'PDF Password', description:'PDF pe password lagao ya hatao', icon:Icons.lock_outline, category:ToolCategory.file, routeName:'/pdf-password'),
    ToolItem(id:'zip_password', name:'ZIP/JAR Password', description:'ZIP ya JAR pe password lagao ya hatao', icon:Icons.security_outlined, category:ToolCategory.file, routeName:'/zip-password'),
    ToolItem(id:'file_password', name:'File Encrypt', description:'Audio/Video file ko password se encrypt karo', icon:Icons.enhanced_encryption_outlined, category:ToolCategory.file, routeName:'/file-password'),
    ToolItem(id:'zip_compressor', name:'ZIP Compressor', description:'5 levels: No / Fastest / Normal / Ultra / Max', icon:Icons.compress_outlined, category:ToolCategory.file, routeName:'/zip-compressor'),
    ToolItem(id:'file_info', name:'File Info Viewer', description:'File ki puri jankari: size, codec, bitrate sab', icon:Icons.info_outline, category:ToolCategory.file, routeName:'/file-info'),
    ToolItem(id:'link_generator', name:'Link Generator', description:'File upload karo, download link + expiry milegi', icon:Icons.link_outlined, category:ToolCategory.file, routeName:'/link-generator', isOffline:false),
    ToolItem(id:'pdf_merger', name:'PDF Merger', description:'Multiple PDFs ko ek mein merge karo', icon:Icons.merge_outlined, category:ToolCategory.file, routeName:'/pdf-merger'),
    ToolItem(id:'pdf_splitter', name:'PDF Splitter', description:'PDF ke pages alag alag karo', icon:Icons.call_split_outlined, category:ToolCategory.file, routeName:'/pdf-splitter'),
    ToolItem(id:'pdf_watermark', name:'PDF Watermark', description:'PDF par custom text/logo watermark lagao', icon:Icons.branding_watermark_outlined, category:ToolCategory.file, routeName:'/pdf-watermark'),
    ToolItem(id:'pdf_rotate', name:'PDF Rotate', description:'PDF pages rotate karo agar scan galat ho gaya', icon:Icons.rotate_right_outlined, category:ToolCategory.file, routeName:'/pdf-rotate'),
    ToolItem(id:'excel_to_pdf', name:'Excel to PDF', description:'Spreadsheet files ko PDF mein convert karo', icon:Icons.table_chart_outlined, category:ToolCategory.file, routeName:'/excel-to-pdf'),
    // TEXT TOOLS
    ToolItem(id:'find_replace', name:'Find & Replace', description:'File mein word dhundho aur replace karo', icon:Icons.find_replace_outlined, category:ToolCategory.text, routeName:'/find-replace'),
    ToolItem(id:'case_converter', name:'Case Converter', description:'UPPER / lower / Title / Sentence case', icon:Icons.text_fields_outlined, category:ToolCategory.text, routeName:'/case-converter'),
    ToolItem(id:'word_counter', name:'Word Counter', description:'Real-time character/word/line counting', icon:Icons.format_list_numbered_outlined, category:ToolCategory.text, routeName:'/word-counter'),
    ToolItem(id:'base64', name:'Base64 Encoder', description:'Text/File ko Base64 mein encode/decode karo', icon:Icons.code_outlined, category:ToolCategory.text, routeName:'/base64'),
    ToolItem(id:'lorem_ipsum', name:'Lorem Ipsum Gen', description:'Designers ke liye dummy text generate karo', icon:Icons.notes_outlined, category:ToolCategory.text, routeName:'/lorem-ipsum'),
    ToolItem(id:'morse_code', name:'Morse Code', description:'Text to Morse aur Morse to Text', icon:Icons.radio_outlined, category:ToolCategory.text, routeName:'/morse-code'),
    ToolItem(id:'list_sort', name:'List Alphabetizer', description:'Kisi bhi list ko A-Z sort karo', icon:Icons.sort_outlined, category:ToolCategory.text, routeName:'/list-sort'),
    ToolItem(id:'upside_down_text', name:'Upside Down Text', description:'Text ulta karo social media pe maze ke liye', icon:Icons.flip_outlined, category:ToolCategory.text, routeName:'/upside-down'),
    ToolItem(id:'sql_formatter', name:'SQL Formatter', description:'Raw SQL queries ko beautify karo', icon:Icons.storage_outlined, category:ToolCategory.text, routeName:'/sql-formatter'),
    ToolItem(id:'regex_tester', name:'Regex Tester', description:'Regular expressions test karo', icon:Icons.search_outlined, category:ToolCategory.text, routeName:'/regex-tester'),
    ToolItem(id:'word_cloud', name:'Word Cloud', description:'Text se visual word cloud art banao', icon:Icons.cloud_outlined, category:ToolCategory.text, routeName:'/word-cloud'),
    ToolItem(id:'html_to_markdown', name:'HTML to Markdown', description:'Web content ko markdown format mein convert karo', icon:Icons.transform_outlined, category:ToolCategory.text, routeName:'/html-to-md'),
    // MEDIA TOOLS
    ToolItem(id:'media_converter', name:'Media Converter', description:'MP1/MP2/MP3/MP4 koi bhi format mein convert', icon:Icons.swap_horiz_outlined, category:ToolCategory.media, routeName:'/media-converter'),
    ToolItem(id:'noise_remover', name:'Noise Remover', description:'Audio se background noise hatao', icon:Icons.noise_control_off_outlined, category:ToolCategory.media, routeName:'/noise-remover'),
    ToolItem(id:'volume_booster', name:'Volume Booster', description:'Audio ki volume badhao', icon:Icons.volume_up_outlined, category:ToolCategory.media, routeName:'/volume-booster'),
    ToolItem(id:'bass_booster', name:'Bass Booster', description:'Audio mein bass badhao', icon:Icons.graphic_eq_outlined, category:ToolCategory.media, routeName:'/bass-booster'),
    ToolItem(id:'slowed_reverb', name:'Slowed + Reverb', description:'Audio slow karo + reverb add karo', icon:Icons.blur_on_outlined, category:ToolCategory.media, routeName:'/slowed-reverb'),
    ToolItem(id:'video_compressor', name:'Video Compressor', description:'Video compress karo: 144p to 4K quality', icon:Icons.video_settings_outlined, category:ToolCategory.media, routeName:'/video-compressor'),
    ToolItem(id:'image_editor', name:'Image Editor', description:'Crop, Rotate, Filters, Text, Watermark aur zyada', icon:Icons.photo_filter_outlined, category:ToolCategory.media, routeName:'/image-editor'),
    ToolItem(id:'image_upscaler', name:'Image Upscaler', description:'AI se quality badhao: 2x / 4x / 8x', icon:Icons.hd_outlined, category:ToolCategory.media, routeName:'/image-upscaler', needsGemini:true, isOffline:false),
    ToolItem(id:'image_expand', name:'Image Expand', description:'AI se borders badhao, generative fill', icon:Icons.expand_outlined, category:ToolCategory.media, routeName:'/image-expand', needsGemini:true, isOffline:false),
    ToolItem(id:'video_to_gif', name:'Video to GIF', description:'MP4 ko high-quality GIF mein convert karo', icon:Icons.gif_box_outlined, category:ToolCategory.media, routeName:'/video-to-gif'),
    ToolItem(id:'audio_joiner', name:'Audio Joiner', description:'Do ya teen audio files ko ek mein merge karo', icon:Icons.merge_outlined, category:ToolCategory.media, routeName:'/audio-joiner'),
    ToolItem(id:'bg_remover', name:'Background Remover', description:'AI se image ka background remove karo', icon:Icons.auto_fix_high_outlined, category:ToolCategory.media, routeName:'/bg-remover', needsGemini:true, isOffline:false),
    ToolItem(id:'video_frame', name:'Video Frame Capture', description:'Video se high-quality screenshots extract karo', icon:Icons.photo_camera_outlined, category:ToolCategory.media, routeName:'/video-frame'),
    ToolItem(id:'batch_video_to_mp3', name:'Batch Video to MP3', description:'Ek saath 10-20 videos ko MP3 mein convert karo', icon:Icons.queue_music_outlined, category:ToolCategory.media, routeName:'/batch-video-mp3'),
    ToolItem(id:'color_palette', name:'Color Palette', description:'Image se hex color codes extract karo', icon:Icons.palette_outlined, category:ToolCategory.media, routeName:'/color-palette'),
    ToolItem(id:'metadata_stripper', name:'Metadata Stripper', description:'Images/videos se GPS/Camera info delete karo', icon:Icons.no_photography_outlined, category:ToolCategory.media, routeName:'/metadata-stripper'),
    ToolItem(id:'batch_image_compressor', name:'Batch Image Compress', description:'50+ images ka size ek click mein kam karo', icon:Icons.photo_size_select_small_outlined, category:ToolCategory.media, routeName:'/batch-image-compress'),
    ToolItem(id:'bulk_image_resizer', name:'Bulk Image Resizer', description:'Folder ki saari images ek saath resize karo', icon:Icons.aspect_ratio_outlined, category:ToolCategory.media, routeName:'/bulk-image-resize'),
    ToolItem(id:'gif_maker', name:'GIF Maker', description:'Video ya multiple images se GIF banao', icon:Icons.animation_outlined, category:ToolCategory.media, routeName:'/gif-maker'),
    ToolItem(id:'circular_crop', name:'Circular Crop', description:'Profile picture ke liye circle mein crop karo', icon:Icons.radio_button_checked_outlined, category:ToolCategory.media, routeName:'/circular-crop'),
    ToolItem(id:'collage_maker', name:'Photo Collage', description:'2-4 images ko ek frame mein set karo', icon:Icons.grid_on_outlined, category:ToolCategory.media, routeName:'/collage-maker'),
    ToolItem(id:'meme_generator', name:'Meme Generator', description:'Popular templates par text daal kar memes banao', icon:Icons.sentiment_very_satisfied_outlined, category:ToolCategory.media, routeName:'/meme-gen'),
    ToolItem(id:'instagram_grid', name:'Instagram Grid Maker', description:'Photo ko 3x3 grids mein kato Instagram ke liye', icon:Icons.grid_view_outlined, category:ToolCategory.media, routeName:'/insta-grid'),
    ToolItem(id:'blur_bg', name:'Blur Background', description:'AI se background ko DSLR jaisa blur karo', icon:Icons.blur_circular_outlined, category:ToolCategory.media, routeName:'/blur-bg', needsGemini:true, isOffline:false),
    ToolItem(id:'ocr_tool', name:'OCR - Image to Text', description:'Image par likha text copy karke nikalo', icon:Icons.document_scanner_outlined, category:ToolCategory.media, routeName:'/ocr', needsGemini:true, isOffline:false),
    // DOWNLOADER TOOLS
    ToolItem(id:'yt_downloader', name:'YouTube Downloader', description:'Video (144p-4K) + Audio MP3 download', icon:Icons.play_circle_outline, category:ToolCategory.downloader, routeName:'/yt-downloader', isOffline:false),
    ToolItem(id:'fb_downloader', name:'Facebook Downloader', description:'Facebook Video + Audio download', icon:Icons.facebook_outlined, category:ToolCategory.downloader, routeName:'/fb-downloader', isOffline:false),
    ToolItem(id:'twitter_downloader', name:'Twitter/X Downloader', description:'Twitter/X Video + Audio download', icon:Icons.alternate_email_outlined, category:ToolCategory.downloader, routeName:'/twitter-downloader', isOffline:false),
    ToolItem(id:'wa_status', name:'WhatsApp Status Saver', description:'Status video + audio save karo', icon:Icons.chat_outlined, category:ToolCategory.downloader, routeName:'/wa-status'),
    ToolItem(id:'insta_downloader', name:'Instagram Downloader', description:'Video / Reels / Stories + Audio download', icon:Icons.camera_alt_outlined, category:ToolCategory.downloader, routeName:'/insta-downloader', isOffline:false),
    ToolItem(id:'terabox_downloader', name:'Terabox Downloader', description:'Terabox link se file download karo', icon:Icons.cloud_download_outlined, category:ToolCategory.downloader, routeName:'/terabox-downloader', isOffline:false),
    ToolItem(id:'pinterest_downloader', name:'Pinterest Downloader', description:'Video / Image / Audio download', icon:Icons.interests_outlined, category:ToolCategory.downloader, routeName:'/pinterest-downloader', isOffline:false),
    ToolItem(id:'telegram_downloader', name:'Telegram Downloader', description:'Telegram link se file/video/audio download', icon:Icons.send_outlined, category:ToolCategory.downloader, routeName:'/telegram-downloader', isOffline:false),
    // AI TOOLS
    ToolItem(id:'ai_chat', name:'AI Chat', description:'Koi bhi sawaal poochho - Gemini Flash', icon:Icons.chat_bubble_outline, category:ToolCategory.ai, routeName:'/ai-chat', needsGemini:true, isOffline:false),
    ToolItem(id:'ai_text_writer', name:'AI Text Writer', description:'Content / Essay / Story / Blog generate karo', icon:Icons.edit_note_outlined, category:ToolCategory.ai, routeName:'/ai-text-writer', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_image_gen', name:'AI Image Generator', description:'Text likho, image generate hogi - Gemini', icon:Icons.auto_awesome_outlined, category:ToolCategory.ai, routeName:'/ai-image-gen', needsGemini:true, isOffline:false),
    ToolItem(id:'ai_code_helper', name:'AI Code Helper', description:'Code explain / fix / generate karo - Claude', icon:Icons.terminal_outlined, category:ToolCategory.ai, routeName:'/ai-code-helper', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_audio_transcribe', name:'AI Audio Transcribe', description:'Audio file do, text mil jaayega - Claude', icon:Icons.mic_outlined, category:ToolCategory.ai, routeName:'/ai-audio-transcribe', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_pdf_summarizer', name:'AI PDF Summarizer', description:'PDF upload karo, summary milegi - Claude', icon:Icons.summarize_outlined, category:ToolCategory.ai, routeName:'/ai-pdf-summarizer', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_translator', name:'AI Translator', description:'Koi bhi language mein translate karo', icon:Icons.translate_outlined, category:ToolCategory.ai, routeName:'/ai-translator', needsClaude:true, isOffline:false),
    ToolItem(id:'yt_analyzer', name:'YouTube Analyzer', description:'AI video dekh ke summary / Q&A batayega', icon:Icons.analytics_outlined, category:ToolCategory.ai, routeName:'/yt-analyzer', needsGemini:true, isOffline:false),
    ToolItem(id:'ai_fix_anything', name:'AI Fix Anything', description:'Kuch bhi bol do - Claude AI theek karega', icon:Icons.build_circle_outlined, category:ToolCategory.ai, routeName:'/ai-fix-anything', needsClaude:true, isOffline:false),
    ToolItem(id:'voice_assistant', name:'Voice Assistant', description:'Voice se poochho app ke baare mein', icon:Icons.record_voice_over_outlined, category:ToolCategory.ai, routeName:'/voice-assistant', isOffline:false),
    ToolItem(id:'gender_change', name:'Gender Change AI', description:'AI se male to female / female to male', icon:Icons.face_outlined, category:ToolCategory.ai, routeName:'/gender-change', needsGemini:true, isOffline:false),
    ToolItem(id:'ai_resume', name:'AI Resume Maker', description:'Details dalo, Claude professional resume likhega', icon:Icons.assignment_outlined, category:ToolCategory.ai, routeName:'/ai-resume', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_grammar', name:'AI Grammar Fixer', description:'Hinglish/English text grammatically correct banao', icon:Icons.spellcheck_outlined, category:ToolCategory.ai, routeName:'/ai-grammar', needsClaude:true, isOffline:false),
    ToolItem(id:'image_to_prompt', name:'Image to Prompt', description:'Image se AI prompt generate karo', icon:Icons.image_search_outlined, category:ToolCategory.ai, routeName:'/image-to-prompt', needsGemini:true, isOffline:false),
    ToolItem(id:'ai_social_bio', name:'AI Social Bio', description:'Instagram/X ke liye AI bio generate karo', icon:Icons.person_outline, category:ToolCategory.ai, routeName:'/ai-social-bio', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_keyword_gen', name:'AI Keyword Gen', description:'YouTube/Blog ke liye tags/keywords nikalo', icon:Icons.tag_outlined, category:ToolCategory.ai, routeName:'/ai-keyword-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'image_to_recipe', name:'Image to Recipe', description:'Fridge ki photo kheencho, AI recipe batayega', icon:Icons.restaurant_menu_outlined, category:ToolCategory.ai, routeName:'/image-to-recipe', needsGemini:true, isOffline:false),
    ToolItem(id:'ai_website_builder', name:'AI Website Builder', description:'Wireframe photo kheencho, HTML/CSS code milega', icon:Icons.web_outlined, category:ToolCategory.ai, routeName:'/ai-website-builder', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_doc_translator', name:'AI Doc Translator', description:'Pura PDF/Doc upload karo, AI translate karega', icon:Icons.translate_outlined, category:ToolCategory.ai, routeName:'/ai-doc-translator', needsClaude:true, isOffline:false),
    ToolItem(id:'git_helper', name:'Git Command Helper', description:'Bolo kya karna hai, AI git command likhega', icon:Icons.merge_type_outlined, category:ToolCategory.ai, routeName:'/git-helper', needsClaude:true, isOffline:false),
    ToolItem(id:'api_doc_gen', name:'API Doc Generator', description:'JSON response se professional Markdown docs banao', icon:Icons.description_outlined, category:ToolCategory.ai, routeName:'/api-doc-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_lyrics_writer', name:'AI Lyrics Writer', description:'Kisi bhi topic par lyrics/poem likhao', icon:Icons.music_note_outlined, category:ToolCategory.ai, routeName:'/ai-lyrics', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_object_remover', name:'AI Object Remover', description:'Photo se koi bhi cheez ya insan remove karo', icon:Icons.auto_fix_normal_outlined, category:ToolCategory.ai, routeName:'/ai-object-remover', needsGemini:true, isOffline:false),
    // CODE EDITORS
    ToolItem(id:'python_editor', name:'Python Editor', description:'Syntax highlight + Find/Replace + Run', icon:Icons.code_outlined, category:ToolCategory.codeEditor, routeName:'/python-editor'),
    ToolItem(id:'java_editor', name:'Java Editor', description:'Syntax highlight + Find/Replace', icon:Icons.coffee_outlined, category:ToolCategory.codeEditor, routeName:'/java-editor'),
    ToolItem(id:'cpp_editor', name:'C++ Editor', description:'Syntax highlight + Find/Replace', icon:Icons.memory_outlined, category:ToolCategory.codeEditor, routeName:'/cpp-editor'),
    ToolItem(id:'js_editor', name:'JavaScript Editor', description:'Syntax highlight + Find/Replace + Run', icon:Icons.javascript_outlined, category:ToolCategory.codeEditor, routeName:'/js-editor'),
    ToolItem(id:'html_editor', name:'HTML/CSS Editor', description:'Syntax highlight + Live Preview', icon:Icons.html_outlined, category:ToolCategory.codeEditor, routeName:'/html-editor'),
    ToolItem(id:'php_editor', name:'PHP Editor', description:'Syntax highlight + Find/Replace', icon:Icons.php_outlined, category:ToolCategory.codeEditor, routeName:'/php-editor'),
    ToolItem(id:'kotlin_editor', name:'Kotlin Editor', description:'Syntax highlight + Find/Replace', icon:Icons.android_outlined, category:ToolCategory.codeEditor, routeName:'/kotlin-editor'),
    ToolItem(id:'shell_editor', name:'Shell/Bash Editor', description:'Syntax highlight + Find/Replace + Run', icon:Icons.terminal_outlined, category:ToolCategory.codeEditor, routeName:'/shell-editor'),
    ToolItem(id:'json_editor', name:'JSON/YAML Editor', description:'Syntax highlight + Format + Validate', icon:Icons.data_object_outlined, category:ToolCategory.codeEditor, routeName:'/json-editor'),
    ToolItem(id:'xml_editor', name:'XML Editor', description:'Syntax highlight + Find/Replace + Format', icon:Icons.code_outlined, category:ToolCategory.codeEditor, routeName:'/xml-editor'),
    // DEVELOPER TOOLS
    ToolItem(id:'hash_gen', name:'Hash Generator', description:'MD5 / SHA-1 / SHA-256 hash nikalo', icon:Icons.tag_outlined, category:ToolCategory.developer, routeName:'/hash-gen'),
    ToolItem(id:'device_info', name:'Device Info Pro', description:'RAM, CPU, Battery, Sensors ki full report', icon:Icons.phone_android_outlined, category:ToolCategory.developer, routeName:'/device-info'),
    ToolItem(id:'jwt_debugger', name:'JWT Debugger', description:'JSON Web Tokens decode aur verify karo', icon:Icons.key_outlined, category:ToolCategory.developer, routeName:'/jwt-debugger'),
    ToolItem(id:'color_contrast', name:'Color Contrast Check', description:'WCAG accessibility ke hisab se contrast check karo', icon:Icons.contrast_outlined, category:ToolCategory.developer, routeName:'/color-contrast'),
    ToolItem(id:'cron_gen', name:'Cron Expression Gen', description:'Linux cron jobs schedule code generate karo', icon:Icons.schedule_outlined, category:ToolCategory.developer, routeName:'/cron-gen'),
    ToolItem(id:'webhook_tester', name:'Webhook Tester', description:'URL par GET/POST request bhej kar response dekho', icon:Icons.webhook_outlined, category:ToolCategory.developer, routeName:'/webhook-tester', isOffline:false),
    ToolItem(id:'csv_json', name:'CSV / JSON Converter', description:'CSV to JSON aur JSON to CSV convert karo', icon:Icons.swap_horiz_outlined, category:ToolCategory.developer, routeName:'/csv-json'),
    ToolItem(id:'base_converter', name:'Base Converter', description:'Decimal / Binary / Octal / Hex conversion', icon:Icons.calculate_outlined, category:ToolCategory.developer, routeName:'/base-converter'),
    ToolItem(id:'aes_encrypt', name:'AES Encryption', description:'Text ko AES-256 encrypted code mein badlo', icon:Icons.lock_person_outlined, category:ToolCategory.developer, routeName:'/aes-encrypt'),
    ToolItem(id:'deep_link_tester', name:'Deep Link Tester', description:'Android app deep links test karo', icon:Icons.link_outlined, category:ToolCategory.developer, routeName:'/deep-link'),
    ToolItem(id:'steganography', name:'Steganography', description:'Image ke andar secret text hide karo', icon:Icons.hide_image_outlined, category:ToolCategory.developer, routeName:'/steganography'),
    ToolItem(id:'color_picker', name:'Color Picker', description:'Screen par touch karke Hex/RGB code nikalo', icon:Icons.colorize_outlined, category:ToolCategory.developer, routeName:'/color-picker'),
    ToolItem(id:'password_gen', name:'Password Generator', description:'Ultra-secure passwords symbols ke saath banao', icon:Icons.password_outlined, category:ToolCategory.developer, routeName:'/password-gen'),
    ToolItem(id:'password_meter', name:'Password Strength', description:'Password kitna strong hai live check karo', icon:Icons.bar_chart_outlined, category:ToolCategory.developer, routeName:'/password-meter'),
    ToolItem(id:'apk_extractor', name:'APK Extractor', description:'Installed apps ka APK extract karke save karo', icon:Icons.android_outlined, category:ToolCategory.developer, routeName:'/apk-extractor'),
    ToolItem(id:'disposable_email', name:'Disposable Email Check', description:'Email temporary ya fake hai ya nahi check karo', icon:Icons.email_outlined, category:ToolCategory.developer, routeName:'/disposable-email', isOffline:false),
    ToolItem(id:'percentage_calc', name:'Percentage Calculator', description:'Discount, Tip, aur Profit/Loss calculation', icon:Icons.percent_outlined, category:ToolCategory.developer, routeName:'/percent-calc'),
    ToolItem(id:'sci_calculator', name:'Scientific Calculator', description:'Basic se advanced math functions', icon:Icons.calculate_outlined, category:ToolCategory.developer, routeName:'/sci-calculator'),
    // NETWORKING TOOLS
    ToolItem(id:'dns_lookup', name:'DNS Lookup', description:'Domain ke A/AAAA/MX/TXT records nikalo', icon:Icons.dns_outlined, category:ToolCategory.networking, routeName:'/dns-lookup', isOffline:false),
    ToolItem(id:'port_scanner', name:'Port Scanner', description:'IP/website ke open ports check karo', icon:Icons.router_outlined, category:ToolCategory.networking, routeName:'/port-scanner', isOffline:false),
    ToolItem(id:'ping_test', name:'Ping Tester', description:'Server latency aur response time check karo (Gamers ke liye)', icon:Icons.network_check_outlined, category:ToolCategory.networking, routeName:'/ping-test', isOffline:false),
    ToolItem(id:'whois_lookup', name:'WHOIS Lookup', description:'Domain ka owner, registration date check karo', icon:Icons.manage_search_outlined, category:ToolCategory.networking, routeName:'/whois', isOffline:false),
    ToolItem(id:'ssl_checker', name:'SSL Checker', description:'Website ka SSL certificate valid hai ya nahi', icon:Icons.https_outlined, category:ToolCategory.networking, routeName:'/ssl-checker', isOffline:false),
    ToolItem(id:'ip_finder', name:'IP Finder', description:'Local aur Public IP address dikhao', icon:Icons.language_outlined, category:ToolCategory.networking, routeName:'/ip-finder', isOffline:false),
    ToolItem(id:'speed_test', name:'Speed Test', description:'Internet download/upload speed check karo', icon:Icons.speed_outlined, category:ToolCategory.networking, routeName:'/speed-test', isOffline:false),
    ToolItem(id:'mac_lookup', name:'MAC Address Lookup', description:'MAC address se device manufacturer pata lagao', icon:Icons.devices_outlined, category:ToolCategory.networking, routeName:'/mac-lookup', isOffline:false),
    ToolItem(id:'redirect_checker', name:'Redirect Checker', description:'Link kitne domains se redirect ho kar jaati hai', icon:Icons.open_in_browser_outlined, category:ToolCategory.networking, routeName:'/redirect-checker', isOffline:false),
    ToolItem(id:'web_to_pdf', name:'Web to PDF', description:'Kisi bhi URL ko PDF/screenshot mein convert karo', icon:Icons.print_outlined, category:ToolCategory.networking, routeName:'/web-to-pdf', isOffline:false),
    ToolItem(id:'proxy_checker', name:'Proxy/VPN Checker', description:'Connection kitna secure hai check karo', icon:Icons.vpn_lock_outlined, category:ToolCategory.networking, routeName:'/proxy-checker', isOffline:false),
    // SYSTEM TOOLS
    ToolItem(id:'storage_analyzer', name:'Storage Analyzer', description:'Pie chart mein dekho kaunsa folder space leta hai', icon:Icons.donut_large_outlined, category:ToolCategory.system, routeName:'/storage-analyzer'),
    ToolItem(id:'junk_cleaner', name:'Junk Cleaner', description:'Khali folders scan karke delete karo', icon:Icons.cleaning_services_outlined, category:ToolCategory.system, routeName:'/junk-cleaner'),
    ToolItem(id:'battery_info', name:'Battery Surgeon', description:'Battery health, temperature, voltage detail', icon:Icons.battery_full_outlined, category:ToolCategory.system, routeName:'/battery-info'),
    ToolItem(id:'sensor_feed', name:'Sensor Live Feed', description:'Accelerometer/Gyroscope/Magnetometer live data graph', icon:Icons.sensors_outlined, category:ToolCategory.system, routeName:'/sensor-feed'),
    ToolItem(id:'sound_meter', name:'Sound Meter (dB)', description:'Microphone se aas-paas ka noise level measure karo', icon:Icons.hearing_outlined, category:ToolCategory.system, routeName:'/sound-meter'),
    ToolItem(id:'compass', name:'Compass & Leveler', description:'Direction aur surface level phone sensors se check karo', icon:Icons.explore_outlined, category:ToolCategory.system, routeName:'/compass'),
    ToolItem(id:'secure_notes', name:'Secure Notes', description:'AES-256 encrypted notes, fingerprint se khulenge', icon:Icons.note_alt_outlined, category:ToolCategory.system, routeName:'/secure-notes'),
    ToolItem(id:'invisible_vault', name:'Invisible Vault', description:'Private photos/docs jo gallery mein nahi dikhenge', icon:Icons.visibility_off_outlined, category:ToolCategory.system, routeName:'/invisible-vault'),
    ToolItem(id:'file_shredder', name:'Secure File Shredder', description:'Files delete karo jo kabhi recover na ho sakein', icon:Icons.delete_forever_outlined, category:ToolCategory.system, routeName:'/file-shredder'),
    ToolItem(id:'wifi_qr', name:'WiFi QR Generator', description:'Bina password dikhaye WiFi connect karwao', icon:Icons.wifi_outlined, category:ToolCategory.system, routeName:'/wifi-qr'),
    ToolItem(id:'fake_call', name:'Fake Call Generator', description:'Boring situations se nikalne ke liye fake call schedule karo', icon:Icons.call_outlined, category:ToolCategory.system, routeName:'/fake-call'),
    ToolItem(id:'sos_flashlight', name:'SOS Flashlight', description:'Emergency mein SOS Morse flashlight + police siren', icon:Icons.flashlight_on_outlined, category:ToolCategory.system, routeName:'/sos-flashlight'),
    ToolItem(id:'anti_theft', name:'Anti-Theft Alarm', description:'Phone uthane ya jeb se nikalte hi alarm bajega', icon:Icons.alarm_outlined, category:ToolCategory.system, routeName:'/anti-theft'),
    // UTILITY / LIFESTYLE
    ToolItem(id:'qr_suite', name:'QR & Barcode Suite', description:'QR generate (Text/WiFi/URL) + scan karo', icon:Icons.qr_code_outlined, category:ToolCategory.utility, routeName:'/qr-suite'),
    ToolItem(id:'unit_converter', name:'Unit Converter', description:'Length/Weight/Temp/Currency sab convert karo', icon:Icons.straighten_outlined, category:ToolCategory.utility, routeName:'/unit-converter'),
    ToolItem(id:'link_vault', name:'Link Vault', description:'Links save karo, auto-detect platform + download', icon:Icons.bookmarks_outlined, category:ToolCategory.utility, routeName:'/link-vault'),
    ToolItem(id:'temp_notes', name:'Temporary Notes', description:'In-app scratchpad bina file save kiye', icon:Icons.sticky_note_2_outlined, category:ToolCategory.utility, routeName:'/temp-notes'),
    ToolItem(id:'direct_whatsapp', name:'Direct WhatsApp Chat', description:'Bina number save kiye WhatsApp message bhejo', icon:Icons.message_outlined, category:ToolCategory.utility, routeName:'/direct-wa'),
    ToolItem(id:'vcard_gen', name:'VCard Generator', description:'Scan karte hi contact save ho jaye wala QR banao', icon:Icons.contact_page_outlined, category:ToolCategory.utility, routeName:'/vcard-gen'),
    ToolItem(id:'auto_typer', name:'Auto-Typer / Expander', description:'/addr jaise shortcuts se full text expand karo', icon:Icons.keyboard_outlined, category:ToolCategory.utility, routeName:'/auto-typer'),
    ToolItem(id:'download_manager', name:'Download Manager', description:'App ke andar saare downloads aur history dekho', icon:Icons.download_outlined, category:ToolCategory.utility, routeName:'/download-manager'),
    ToolItem(id:'reverse_image', name:'Reverse Image Search', description:'Image upload karke original source dhundho', icon:Icons.image_search_outlined, category:ToolCategory.utility, routeName:'/reverse-image', isOffline:false),
    ToolItem(id:'bmi_calculator', name:'BMI Calculator', description:'Height aur Weight se health status batao', icon:Icons.monitor_weight_outlined, category:ToolCategory.lifestyle, routeName:'/bmi'),
    ToolItem(id:'age_calculator', name:'Age Calculator', description:'DOB se exact years/months/days nikalo', icon:Icons.cake_outlined, category:ToolCategory.lifestyle, routeName:'/age-calc'),
    ToolItem(id:'world_clock', name:'World Clock', description:'Ek timezone se dusre mein time convert karo', icon:Icons.access_time_outlined, category:ToolCategory.lifestyle, routeName:'/world-clock'),
    ToolItem(id:'medicine_reminder', name:'Medicine Reminder', description:'Simple alarm jo dawai lene ka time yaad dilaye', icon:Icons.medication_outlined, category:ToolCategory.lifestyle, routeName:'/medicine-reminder'),
    ToolItem(id:'rto_checker', name:'Vehicle Info (RTO)', description:'Gaadi ka number daal kar details check karo', icon:Icons.directions_car_outlined, category:ToolCategory.lifestyle, routeName:'/rto-checker', isOffline:false),
    ToolItem(id:'emi_calculator', name:'EMI Calculator', description:'Loan ki EMI calculate karo', icon:Icons.attach_money_outlined, category:ToolCategory.business, routeName:'/emi-calc'),
    ToolItem(id:'gst_calculator', name:'GST / VAT Calculator', description:'Tax inclusive aur exclusive amounts calculate karo', icon:Icons.receipt_long_outlined, category:ToolCategory.business, routeName:'/gst-calc'),
    ToolItem(id:'invoice_gen', name:'Invoice Generator', description:'PDF format mein business invoice generate karo', icon:Icons.receipt_outlined, category:ToolCategory.business, routeName:'/invoice-gen'),
    ToolItem(id:'crypto_tracker', name:'Crypto Live Tracker', description:'Top 10 cryptocurrencies ki live price dekho', icon:Icons.currency_bitcoin_outlined, category:ToolCategory.business, routeName:'/crypto-tracker', isOffline:false),
    ToolItem(id:'mp3_autotagger', name:'MP3 Auto-Tagger', description:'AI se audio files ke missing metadata fill karo', icon:Icons.sell_outlined, category:ToolCategory.media, routeName:'/mp3-autotagger', needsGemini:true, isOffline:false),
    // SPECIAL / MISSING TOOLS
    ToolItem(id:'secret_vault', name:'Secret Calculator', description:'Normal calculator dikhega, PIN se hidden files khulenge', icon:Icons.calculate_outlined, category:ToolCategory.system, routeName:'/secret-vault'),
    ToolItem(id:'reel_toolkit', name:'Reel/Shorts Toolkit', description:'Auto caption, subtitle, ratio 16:9 to 9:16 convert', icon:Icons.video_collection_outlined, category:ToolCategory.media, routeName:'/reel-toolkit'),
    ToolItem(id:'ai_workflow', name:'AI Workflow Builder', description:'Drag & drop: Image to Compress to Rename to Upload', icon:Icons.account_tree_outlined, category:ToolCategory.ai, routeName:'/ai-workflow', needsGemini:true, isOffline:false),
    ToolItem(id:'smart_workspace', name:'Smart Workspaces', description:'YouTube/Study Setup - ek click mein multiple tools ready', icon:Icons.workspaces_outlined, category:ToolCategory.utility, routeName:'/smart-workspace'),
    ToolItem(id:'share_kit', name:'One-Click Share Kit', description:'Compress + Rename + Convert + Upload ek click mein', icon:Icons.rocket_launch_outlined, category:ToolCategory.utility, routeName:'/share-kit'),
    ToolItem(id:'scan_to_pdf', name:'Scan to PDF', description:'Camera se photo kheencho, auto scan + PDF + share', icon:Icons.document_scanner_outlined, category:ToolCategory.file, routeName:'/scan-to-pdf'),
    ToolItem(id:'universal_opener', name:'Universal File Opener', description:'Unknown file - app suggest karega Convert/Extract/View', icon:Icons.folder_open_outlined, category:ToolCategory.file, routeName:'/universal-opener'),
    ToolItem(id:'app_lock', name:'App Lock', description:'PIN ya Fingerprint se poori app lock karo', icon:Icons.lock_outlined, category:ToolCategory.system, routeName:'/app-lock'),
    ToolItem(id:'favicon_downloader', name:'Favicon Downloader', description:'Kisi bhi URL ka icon high resolution mein download karo', icon:Icons.language_outlined, category:ToolCategory.networking, routeName:'/favicon-downloader', isOffline:false),
    ToolItem(id:'source_viewer', name:'Source Code Viewer', description:'Kisi bhi website ka HTML code phone par read/save karo', icon:Icons.source_outlined, category:ToolCategory.networking, routeName:'/source-viewer', isOffline:false),
    ToolItem(id:'graph_plotter', name:'Graph Plotter', description:'Math equations ka graph generate karo', icon:Icons.show_chart_outlined, category:ToolCategory.developer, routeName:'/graph-plotter'),
    ToolItem(id:'robots_finder', name:'Robots.txt Finder', description:'SEO ke liye robots.txt aur sitemap dhundho', icon:Icons.policy_outlined, category:ToolCategory.networking, routeName:'/robots-finder', isOffline:false),
    ToolItem(id:'dominant_color', name:'Image Dominant Color', description:'Photo mein sabse zyada kaunsa rang hai, Hex code nikalo', icon:Icons.format_color_fill_outlined, category:ToolCategory.media, routeName:'/dominant-color'),

    // ══════════════════════════════════════════
    // CREATOR AI TOOLS
    ToolItem(id:'ai_caption_gen', name:'AI Caption Generator', description:'Post/Reel ke liye viral captions Gemini se banao', icon:Icons.closed_caption_outlined, category:ToolCategory.creator, routeName:'/ai-caption-gen', needsGemini:true, isOffline:false),
    ToolItem(id:'ai_hashtag_gen', name:'AI Hashtag Generator', description:'Topic dalo, trending hashtags AI generate karega', icon:Icons.tag_outlined, category:ToolCategory.creator, routeName:'/ai-hashtag-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_thumbnail_text', name:'AI Thumbnail Text', description:'YouTube thumbnail ke liye catchy titles generate karo', icon:Icons.image_outlined, category:ToolCategory.creator, routeName:'/ai-thumbnail-text', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_script_writer', name:'AI Script Writer', description:'Reels/YouTube ke liye full scripts Claude se banao', icon:Icons.movie_creation_outlined, category:ToolCategory.creator, routeName:'/ai-script-writer', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_hook_gen', name:'AI Hook Generator', description:'3-second reel hooks jo attention pakdein', icon:Icons.bolt_outlined, category:ToolCategory.creator, routeName:'/ai-hook-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'viral_hook_gen', name:'Viral Hook Generator', description:'High-CTR hooks multiple formats mein generate karo', icon:Icons.trending_up_outlined, category:ToolCategory.creator, routeName:'/viral-hook-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'hook_script_caption', name:'Hook+Script+Caption Combo', description:'Ek click mein hook, full script aur caption sab milega', icon:Icons.auto_awesome_motion_outlined, category:ToolCategory.creator, routeName:'/hook-script-caption', needsClaude:true, isOffline:false),
    ToolItem(id:'yt_title_checker', name:'YouTube Title Score', description:'Title likho, AI CTR score aur suggestions dega', icon:Icons.grade_outlined, category:ToolCategory.creator, routeName:'/yt-title-checker', needsClaude:true, isOffline:false),
    ToolItem(id:'yt_desc_writer', name:'YouTube Desc Writer', description:'AI se SEO-optimized YouTube descriptions banao', icon:Icons.description_outlined, category:ToolCategory.creator, routeName:'/yt-desc-writer', needsClaude:true, isOffline:false),
    ToolItem(id:'content_calendar', name:'Content Calendar AI', description:'Topic batch karo, 30-day posting calendar generate karo', icon:Icons.calendar_month_outlined, category:ToolCategory.creator, routeName:'/content-calendar', needsClaude:true, isOffline:false),
    ToolItem(id:'reel_ideas', name:'30 Reel Ideas Generator', description:'Ek click mein 30 trending reel ideas apne niche ke liye', icon:Icons.videocam_outlined, category:ToolCategory.creator, routeName:'/reel-ideas', needsClaude:true, isOffline:false),
    ToolItem(id:'caption_rewrite', name:'Caption Rewrite AI', description:'Boring captions ko viral style mein rewrite karo', icon:Icons.edit_outlined, category:ToolCategory.creator, routeName:'/caption-rewrite', needsClaude:true, isOffline:false),
    ToolItem(id:'caption_by_mood', name:'Caption by Mood', description:'Mood select karo - happy/sad/motivational - caption ready', icon:Icons.mood_outlined, category:ToolCategory.creator, routeName:'/caption-by-mood', needsClaude:true, isOffline:false),
    ToolItem(id:'trending_caption_bank', name:'Caption Bank', description:'Categorized ready-to-use captions ka local vault', icon:Icons.collections_bookmark_outlined, category:ToolCategory.creator, routeName:'/caption-bank'),
    ToolItem(id:'hashtag_vault', name:'Hashtag Vault', description:'Niche-wise hashtag packs save karo aur copy karo', icon:Icons.bookmarks_outlined, category:ToolCategory.creator, routeName:'/hashtag-vault'),
    ToolItem(id:'comment_reply_gen', name:'Comment Reply AI', description:'Comments ka smart reply AI se generate karo', icon:Icons.comment_outlined, category:ToolCategory.creator, routeName:'/comment-reply-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'dm_reply_templates', name:'DM Reply Templates', description:'Common DMs ke liye ready reply templates save karo', icon:Icons.mark_chat_read_outlined, category:ToolCategory.creator, routeName:'/dm-reply-templates'),
    ToolItem(id:'sponsor_pitch', name:'Sponsor Pitch Writer', description:'Brands ko bhejne ke liye professional pitch AI se banao', icon:Icons.handshake_outlined, category:ToolCategory.creator, routeName:'/sponsor-pitch', needsClaude:true, isOffline:false),
    ToolItem(id:'brand_deal_reply', name:'Brand Deal Reply', description:'Brand collaboration emails ke smart replies banao', icon:Icons.business_center_outlined, category:ToolCategory.creator, routeName:'/brand-deal-reply', needsClaude:true, isOffline:false),
    ToolItem(id:'niche_finder', name:'Niche Finder AI', description:'Apne interest batao, profitable niches AI suggest karega', icon:Icons.search_outlined, category:ToolCategory.creator, routeName:'/niche-finder', needsClaude:true, isOffline:false),
    ToolItem(id:'content_repurpose', name:'Content Repurpose Tool', description:'Ek content ko multiple platforms ke liye format karo', icon:Icons.loop_outlined, category:ToolCategory.creator, routeName:'/content-repurpose', needsClaude:true, isOffline:false),
    ToolItem(id:'series_planner', name:'Series Content Planner', description:'Episode-by-episode content series plan banao', icon:Icons.playlist_play_outlined, category:ToolCategory.creator, routeName:'/series-planner', needsClaude:true, isOffline:false),
    ToolItem(id:'auto_hashtag_packs', name:'Auto Hashtag Packs', description:'Category choose karo - AI 30 hashtags pack dega', icon:Icons.local_offer_outlined, category:ToolCategory.creator, routeName:'/auto-hashtag-packs', needsClaude:true, isOffline:false),
    ToolItem(id:'channel_growth', name:'Channel Growth Checklist', description:'YouTube/Instagram growth ke liye AI-powered checklist', icon:Icons.checklist_outlined, category:ToolCategory.creator, routeName:'/channel-growth', needsClaude:true, isOffline:false),
    ToolItem(id:'brand_kit', name:'Brand Kit Saver', description:'Logo colors, fonts, tone - sab ek jagah save karo', icon:Icons.palette_outlined, category:ToolCategory.creator, routeName:'/brand-kit'),
    ToolItem(id:'hook_analyzer', name:'Hook Analyzer', description:'Apna hook paste karo, AI rate aur improve karega', icon:Icons.analytics_outlined, category:ToolCategory.creator, routeName:'/hook-analyzer', needsClaude:true, isOffline:false),
    ToolItem(id:'audience_persona', name:'Audience Persona Builder', description:'Target audience ka detailed persona AI se banao', icon:Icons.people_outline, category:ToolCategory.creator, routeName:'/audience-persona', needsClaude:true, isOffline:false),
    ToolItem(id:'poll_ideas', name:'Poll Ideas Generator', description:'Engagement badhane ke liye audience poll ideas', icon:Icons.poll_outlined, category:ToolCategory.creator, routeName:'/poll-ideas', needsClaude:true, isOffline:false),
    ToolItem(id:'reel_script_topic', name:'Reel Script by Topic', description:'Topic do, AI full reel script format mein likhega', icon:Icons.article_outlined, category:ToolCategory.creator, routeName:'/reel-script-topic', needsClaude:true, isOffline:false),
    ToolItem(id:'trend_notes', name:'Trend Notes Board', description:'Trending topics notes karo, baad mein content banao', icon:Icons.sticky_note_2_outlined, category:ToolCategory.creator, routeName:'/trend-notes'),

    // ══════════════════════════════════════════
    // STUDENT AI TOOLS
    ToolItem(id:'ai_notes_summarizer', name:'AI Notes Summarizer', description:'Long notes paste karo, AI short summary banayega', icon:Icons.summarize_outlined, category:ToolCategory.student, routeName:'/ai-notes-summarizer', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_homework_helper', name:'AI Homework Helper', description:'Homework question likho, AI step-by-step solve karega', icon:Icons.school_outlined, category:ToolCategory.student, routeName:'/ai-homework-helper', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_quiz_gen', name:'AI Quiz Generator', description:'Topic dalo, AI MCQ quiz automatically banayega', icon:Icons.quiz_outlined, category:ToolCategory.student, routeName:'/ai-quiz-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_explain_simple', name:'AI Explain Simple', description:'Koi bhi topic simple language mein samjhao', icon:Icons.lightbulb_outlined, category:ToolCategory.student, routeName:'/ai-explain-simple', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_mcq_maker', name:'AI MCQ Maker', description:'Notes se multiple choice questions automatically banao', icon:Icons.checklist_rtl_outlined, category:ToolCategory.student, routeName:'/ai-mcq-maker', needsClaude:true, isOffline:false),
    ToolItem(id:'math_step_helper', name:'Math Step Helper', description:'Math problem likho, AI har step explain karega', icon:Icons.functions_outlined, category:ToolCategory.student, routeName:'/math-step-helper', needsClaude:true, isOffline:false),
    ToolItem(id:'flashcard_maker', name:'Flashcard Maker', description:'Topic se AI-generated flashcards banao aur revise karo', icon:Icons.style_outlined, category:ToolCategory.student, routeName:'/flashcard-maker', needsClaude:true, isOffline:false),
    ToolItem(id:'exam_countdown', name:'Exam Countdown Board', description:'Exams ki dates add karo, countdown dekho', icon:Icons.event_outlined, category:ToolCategory.student, routeName:'/exam-countdown'),
    ToolItem(id:'study_timer', name:'Study Timer (Pomodoro)', description:'Focus sessions + breaks timer for students', icon:Icons.timer_outlined, category:ToolCategory.student, routeName:'/study-timer'),
    ToolItem(id:'formula_vault', name:'Formula Vault', description:'Subject-wise formulas save karo aur search karo', icon:Icons.calculate_outlined, category:ToolCategory.student, routeName:'/formula-vault'),
    ToolItem(id:'notes_to_quiz', name:'Notes to Quiz AI', description:'Apne notes upload karo, AI quiz banayega', icon:Icons.quiz_outlined, category:ToolCategory.student, routeName:'/notes-to-quiz', needsClaude:true, isOffline:false),
    ToolItem(id:'revision_planner', name:'Revision Alarm Planner', description:'Topics ke liye smart revision schedule aur alarms', icon:Icons.alarm_outlined, category:ToolCategory.student, routeName:'/revision-planner'),
    ToolItem(id:'essay_writer', name:'Essay Writer AI', description:'Topic aur word limit dalo, AI essay likhega', icon:Icons.edit_note_outlined, category:ToolCategory.student, routeName:'/essay-writer', needsClaude:true, isOffline:false),
    ToolItem(id:'study_schedule', name:'Study Schedule Builder', description:'Subjects aur time dalo, AI schedule bana de', icon:Icons.calendar_today_outlined, category:ToolCategory.student, routeName:'/study-schedule', needsClaude:true, isOffline:false),
    ToolItem(id:'vocab_builder', name:'Vocabulary Builder', description:'Daily new words, definitions aur example sentences', icon:Icons.abc_outlined, category:ToolCategory.student, routeName:'/vocab-builder'),
    ToolItem(id:'speech_practice', name:'Speech Practice Reader', description:'Text likho, padhne ke liye teleprompter mode', icon:Icons.record_voice_over_outlined, category:ToolCategory.student, routeName:'/speech-practice'),
    ToolItem(id:'homework_planner', name:'Homework Planner', description:'Daily assignments track karo, deadlines manage karo', icon:Icons.task_alt_outlined, category:ToolCategory.student, routeName:'/homework-planner'),
    ToolItem(id:'interview_practice', name:'Interview Practice Q&A', description:'AI interviewer se mock interview practice karo', icon:Icons.question_answer_outlined, category:ToolCategory.student, routeName:'/interview-practice', needsClaude:true, isOffline:false),
    ToolItem(id:'topic_explainer', name:'Topic Explainer AI', description:'Kisi bhi concept ko 5 levels of difficulty mein samjho', icon:Icons.school_outlined, category:ToolCategory.student, routeName:'/topic-explainer', needsClaude:true, isOffline:false),
    ToolItem(id:'career_path', name:'Career Path Explorer', description:'Interests batao, AI best career paths suggest karega', icon:Icons.explore_outlined, category:ToolCategory.student, routeName:'/career-path', needsClaude:true, isOffline:false),

    // ══════════════════════════════════════════
    // PRODUCTIVITY TOOLS
    ToolItem(id:'saved_prompts', name:'Saved Prompts Hub', description:'Best AI prompts save karo, ek click mein use karo', icon:Icons.bookmark_outlined, category:ToolCategory.productivity, routeName:'/saved-prompts'),
    ToolItem(id:'long_msg_shortener', name:'Long Message Shortener', description:'Bada text paste karo, AI short summary nikale', icon:Icons.compress_outlined, category:ToolCategory.productivity, routeName:'/long-msg-shortener', needsClaude:true, isOffline:false),
    ToolItem(id:'reply_gen', name:'Smart Reply Generator', description:'Chat screenshot ya message se smart reply suggest karo', icon:Icons.reply_outlined, category:ToolCategory.productivity, routeName:'/reply-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'idea_gen', name:'Idea Generator AI', description:'Category select karo - reel/post/business ideas milein', icon:Icons.tips_and_updates_outlined, category:ToolCategory.productivity, routeName:'/idea-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'daily_planner_ai', name:'Daily Planner AI', description:'Kaam likho, AI priority-based schedule bana de', icon:Icons.today_outlined, category:ToolCategory.productivity, routeName:'/daily-planner-ai', needsClaude:true, isOffline:false),
    ToolItem(id:'prompt_improver', name:'Prompt Improver', description:'Weak prompt likho, AI use best version mein upgrade kare', icon:Icons.upgrade_outlined, category:ToolCategory.productivity, routeName:'/prompt-improver', needsClaude:true, isOffline:false),
    ToolItem(id:'task_breakdown', name:'Task Breakdown AI', description:'Bada kaam likho, AI use small steps mein tod de', icon:Icons.account_tree_outlined, category:ToolCategory.productivity, routeName:'/task-breakdown', needsClaude:true, isOffline:false),
    ToolItem(id:'focus_timer', name:'Focus Session Timer', description:'Pomodoro timer + session stats + streak counter', icon:Icons.timer_outlined, category:ToolCategory.productivity, routeName:'/focus-timer'),
    ToolItem(id:'routine_maker', name:'Routine Maker', description:'Morning/night routine checklist banao aur track karo', icon:Icons.wb_sunny_outlined, category:ToolCategory.productivity, routeName:'/routine-maker'),
    ToolItem(id:'habit_streak', name:'Habit Streak Counter', description:'Daily habits track karo, streak maintain karo', icon:Icons.local_fire_department_outlined, category:ToolCategory.productivity, routeName:'/habit-streak'),
    ToolItem(id:'water_reminder', name:'Water Reminder', description:'Hydration reminders set karo, daily intake track karo', icon:Icons.water_drop_outlined, category:ToolCategory.productivity, routeName:'/water-reminder'),
    ToolItem(id:'random_decision', name:'Spin Wheel Decider', description:'Options likho, spin wheel randomly decide kare', icon:Icons.casino_outlined, category:ToolCategory.productivity, routeName:'/spin-wheel'),
    ToolItem(id:'mini_journal', name:'Mini Journal', description:'Daily thoughts, mood aur notes ek jagah likhte raho', icon:Icons.menu_book_outlined, category:ToolCategory.productivity, routeName:'/mini-journal'),
    ToolItem(id:'second_brain', name:'Second Brain Vault', description:'Ideas, notes, links auto-organize karke save karo', icon:Icons.psychology_outlined, category:ToolCategory.productivity, routeName:'/second-brain'),
    ToolItem(id:'voice_diary', name:'Voice Diary to Text', description:'Bolkar diary likho, AI text mein convert karega', icon:Icons.mic_none_outlined, category:ToolCategory.productivity, routeName:'/voice-diary', needsGemini:true, isOffline:false),
    ToolItem(id:'custom_prompt_lib', name:'Custom Prompt Library', description:'Category-wise prompt templates banao aur manage karo', icon:Icons.library_books_outlined, category:ToolCategory.productivity, routeName:'/custom-prompt-lib'),
    ToolItem(id:'goal_tracker_ai', name:'Goal Tracker AI', description:'Goals set karo, AI progress predictions aur tips dega', icon:Icons.flag_outlined, category:ToolCategory.productivity, routeName:'/goal-tracker-ai', needsClaude:true, isOffline:false),
    ToolItem(id:'mind_dump', name:'Mind Dump Organizer', description:'Sab kuch likho, AI categories aur priorities bana de', icon:Icons.hub_outlined, category:ToolCategory.productivity, routeName:'/mind-dump', needsClaude:true, isOffline:false),
    ToolItem(id:'day_starter_ai', name:'My Day Starter AI', description:'App open karo, AI aaj ke liye focus plan suggest kare', icon:Icons.alarm_on_outlined, category:ToolCategory.productivity, routeName:'/day-starter-ai', needsClaude:true, isOffline:false),
    ToolItem(id:'night_review_ai', name:'Night Review AI', description:'Din ka summary aur kal ka plan AI se banao', icon:Icons.nights_stay_outlined, category:ToolCategory.productivity, routeName:'/night-review-ai', needsClaude:true, isOffline:false),
    ToolItem(id:'procrastination_killer', name:'Procrastination Killer', description:'5-minute start timer - sirf shuru karo, baaki ho jaega', icon:Icons.directions_run_outlined, category:ToolCategory.productivity, routeName:'/procrastination-killer'),
    ToolItem(id:'weekly_reset', name:'Weekly Reset Planner', description:'Sunday reset: week review + agla week plan', icon:Icons.restart_alt_outlined, category:ToolCategory.productivity, routeName:'/weekly-reset'),
    ToolItem(id:'mood_based_music', name:'Mood Music Suggester', description:'Mood batao, AI songs/genres suggest karega', icon:Icons.music_note_outlined, category:ToolCategory.productivity, routeName:'/mood-music', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_email_writer', name:'Auto Email Writer', description:'Bullet points dalo, AI professional email likhega', icon:Icons.email_outlined, category:ToolCategory.productivity, routeName:'/ai-email-writer', needsClaude:true, isOffline:false),
    ToolItem(id:'life_stats', name:'Life Stats Dashboard', description:'Screen time, tasks, habits - productivity overview', icon:Icons.dashboard_outlined, category:ToolCategory.productivity, routeName:'/life-stats'),
    ToolItem(id:'convo_summarizer', name:'Conversation Summarizer', description:'Long chat paste karo, AI key points nikale', icon:Icons.format_list_bulleted_outlined, category:ToolCategory.productivity, routeName:'/convo-summarizer', needsClaude:true, isOffline:false),
    ToolItem(id:'morning_dashboard', name:'Morning Dashboard', description:'Battery, storage, tasks, notes - ek screen par sab', icon:Icons.space_dashboard_outlined, category:ToolCategory.productivity, routeName:'/morning-dashboard'),

    // ══════════════════════════════════════════
    // GAMING TOOLS
    ToolItem(id:'sensitivity_notes', name:'Sensitivity Notes', description:'Game-wise sensitivity settings save karo', icon:Icons.tune_outlined, category:ToolCategory.gaming, routeName:'/sensitivity-notes'),
    ToolItem(id:'game_session_timer', name:'Game Session Timer', description:'Gaming session track karo, breaks yaad dilao', icon:Icons.sports_esports_outlined, category:ToolCategory.gaming, routeName:'/game-session-timer'),
    ToolItem(id:'clip_reminder', name:'Clip Recorder Reminder', description:'Ek tap se reminder ki good play record karo', icon:Icons.videocam_outlined, category:ToolCategory.gaming, routeName:'/clip-reminder'),
    ToolItem(id:'squad_planner', name:'Squad Planner', description:'Team members, schedules aur strategies plan karo', icon:Icons.group_outlined, category:ToolCategory.gaming, routeName:'/squad-planner'),

    // ══════════════════════════════════════════
    // FINANCE TOOLS
    ToolItem(id:'expense_tracker', name:'Expense Tracker', description:'Roz ka kharcha note karo, category-wise report dekho', icon:Icons.account_balance_wallet_outlined, category:ToolCategory.finance, routeName:'/expense-tracker'),
    ToolItem(id:'upi_qr_save', name:'UPI QR Save', description:'Multiple UPI QR codes save karo ek jagah', icon:Icons.qr_code_2_outlined, category:ToolCategory.finance, routeName:'/upi-qr-save'),
    ToolItem(id:'profit_calc', name:'Profit Calculator', description:'Cost aur selling price se profit/loss instantly nikalo', icon:Icons.trending_up_outlined, category:ToolCategory.finance, routeName:'/profit-calc'),
    ToolItem(id:'budget_planner', name:'Monthly Budget Planner', description:'Income aur expenses set karo, budget track karo', icon:Icons.savings_outlined, category:ToolCategory.finance, routeName:'/budget-planner'),
    ToolItem(id:'income_tracker', name:'Income Tracker', description:'Multiple income sources track karo monthly', icon:Icons.payments_outlined, category:ToolCategory.finance, routeName:'/income-tracker'),
    ToolItem(id:'savings_goal', name:'Savings Goal Tracker', description:'Goal set karo, daily savings track karo', icon:Icons.flag_circle_outlined, category:ToolCategory.finance, routeName:'/savings-goal'),
    ToolItem(id:'subscription_reminder', name:'Subscription Reminder', description:'Netflix, Spotify jaisi subscriptions renewal remind karo', icon:Icons.notifications_outlined, category:ToolCategory.finance, routeName:'/subscription-reminder'),
    ToolItem(id:'debt_payoff', name:'Debt Payoff Planner', description:'Loans list karo, fastest payoff plan AI se banao', icon:Icons.money_off_outlined, category:ToolCategory.finance, routeName:'/debt-payoff'),
    ToolItem(id:'freelance_quote', name:'Freelance Quote Builder', description:'Client ka kaam dekho, AI rate suggest karega', icon:Icons.request_quote_outlined, category:ToolCategory.finance, routeName:'/freelance-quote', needsClaude:true, isOffline:false),
    ToolItem(id:'pricing_tool', name:'Pricing Suggestion Tool', description:'Market rates dalo, AI pricing strategy suggest kare', icon:Icons.price_change_outlined, category:ToolCategory.finance, routeName:'/pricing-tool', needsClaude:true, isOffline:false),
    ToolItem(id:'profit_margin', name:'Profit Margin Calc', description:'Cost, price aur tax se exact margin calculate karo', icon:Icons.percent_outlined, category:ToolCategory.finance, routeName:'/profit-margin'),
    ToolItem(id:'bill_reminder', name:'Bill Due Reminder', description:'Bijli, rent, EMI - sab bills ka reminder set karo', icon:Icons.receipt_long_outlined, category:ToolCategory.finance, routeName:'/bill-reminder'),
    ToolItem(id:'savings_challenge', name:'Savings Challenge Planner', description:'52-week ya custom savings challenges track karo', icon:Icons.workspace_premium_outlined, category:ToolCategory.finance, routeName:'/savings-challenge'),
    ToolItem(id:'side_hustle_ai', name:'Side Hustle Ideas AI', description:'Skills batao, AI income ideas suggest karega', icon:Icons.lightbulb_outlined, category:ToolCategory.finance, routeName:'/side-hustle-ai', needsClaude:true, isOffline:false),
    ToolItem(id:'growth_kpi', name:'Growth KPI Board', description:'Business metrics aur KPIs track karo', icon:Icons.bar_chart_outlined, category:ToolCategory.finance, routeName:'/growth-kpi'),

    // ══════════════════════════════════════════
    // BUSINESS AI TOOLS
    ToolItem(id:'ai_ad_copy', name:'AI Ad Copy Writer', description:'Product details dalo, AI ad copy ready karega', icon:Icons.campaign_outlined, category:ToolCategory.business, routeName:'/ai-ad-copy', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_product_desc', name:'AI Product Description', description:'Product ke liye SEO-friendly descriptions banao', icon:Icons.inventory_outlined, category:ToolCategory.business, routeName:'/ai-product-desc', needsClaude:true, isOffline:false),
    ToolItem(id:'ai_sales_reply', name:'AI Sales Reply Gen', description:'Customer inquiry ka persuasive reply AI se banao', icon:Icons.support_agent_outlined, category:ToolCategory.business, routeName:'/ai-sales-reply', needsClaude:true, isOffline:false),
    ToolItem(id:'quotation_maker', name:'Quotation Maker', description:'Client ke liye professional quotation PDF banao', icon:Icons.format_quote_outlined, category:ToolCategory.business, routeName:'/quotation-maker'),
    ToolItem(id:'client_templates', name:'Client Message Templates', description:'Common client messages ke ready-to-use templates', icon:Icons.message_outlined, category:ToolCategory.business, routeName:'/client-templates'),
    ToolItem(id:'meeting_summarizer', name:'Meeting Notes AI', description:'Meeting notes paste karo, AI action items nikale', icon:Icons.meeting_room_outlined, category:ToolCategory.business, routeName:'/meeting-summarizer', needsClaude:true, isOffline:false),
    ToolItem(id:'brand_name_gen', name:'Brand Name Generator', description:'Niche aur keywords dalo, AI brand names suggest kare', icon:Icons.branding_watermark_outlined, category:ToolCategory.business, routeName:'/brand-name-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'offer_gen', name:'Offer Generator AI', description:'Product/service ke liye irresistible offers banao', icon:Icons.local_offer_outlined, category:ToolCategory.business, routeName:'/offer-gen', needsClaude:true, isOffline:false),
    ToolItem(id:'lead_tracker', name:'Lead Tracker Notes', description:'Potential clients track karo, follow-up remind karo', icon:Icons.person_search_outlined, category:ToolCategory.business, routeName:'/lead-tracker'),
    ToolItem(id:'sales_script', name:'Sales Script Writer', description:'Product ke liye AI-powered sales script generate karo', icon:Icons.record_voice_over_outlined, category:ToolCategory.business, routeName:'/sales-script', needsClaude:true, isOffline:false),
    ToolItem(id:'order_tracker', name:'Order Tracker', description:'Orders status, delivery dates track karo locally', icon:Icons.local_shipping_outlined, category:ToolCategory.business, routeName:'/order-tracker'),
    ToolItem(id:'mini_crm', name:'Mini CRM Notes', description:'Customers ki details, history aur notes manage karo', icon:Icons.contacts_outlined, category:ToolCategory.business, routeName:'/mini-crm'),
    ToolItem(id:'customer_reply', name:'Customer Reply Templates', description:'FAQs ke liye instant reply templates save karo', icon:Icons.chat_outlined, category:ToolCategory.business, routeName:'/customer-reply'),
    ToolItem(id:'price_list', name:'Price List Creator', description:'Products/services ka formatted price list banao', icon:Icons.list_alt_outlined, category:ToolCategory.business, routeName:'/price-list'),

    // ══════════════════════════════════════════
    // PRIVACY TOOLS (under system)
    ToolItem(id:'panic_button', name:'Panic Button', description:'Emergency mein ek tap se private screens instantly hide', icon:Icons.warning_outlined, category:ToolCategory.system, routeName:'/panic-button'),
    ToolItem(id:'decoy_notes', name:'Decoy Notes', description:'Fake notes screen jo privacy mode mein dikhta hai', icon:Icons.note_outlined, category:ToolCategory.system, routeName:'/decoy-notes'),
    ToolItem(id:'time_lock_notes', name:'Time Lock Notes', description:'Note likho jo sirf set time par khulega', icon:Icons.lock_clock_outlined, category:ToolCategory.system, routeName:'/time-lock-notes'),
    ToolItem(id:'one_time_notes', name:'One-Time View Notes', description:'Note read karo, automatically delete ho jaega', icon:Icons.visibility_off_outlined, category:ToolCategory.system, routeName:'/one-time-notes'),
    ToolItem(id:'pin_log', name:'PIN Attempt Log', description:'Wrong PIN attempts locally log karo kaun khola', icon:Icons.fingerprint_outlined, category:ToolCategory.system, routeName:'/pin-log'),
    ToolItem(id:'vault_search', name:'Vault Search', description:'Saare encrypted notes aur vaults mein search karo', icon:Icons.manage_search_outlined, category:ToolCategory.system, routeName:'/vault-search'),
    ToolItem(id:'private_task', name:'Private Task Board', description:'Hidden to-do list PIN se protected', icon:Icons.task_outlined, category:ToolCategory.system, routeName:'/private-task'),
    ToolItem(id:'disguised_folder', name:'Disguised Folder Names', description:'Private folders ko innocent names se disguise karo', icon:Icons.folder_special_outlined, category:ToolCategory.system, routeName:'/disguised-folder'),
    ToolItem(id:'secure_clipboard', name:'Secure Clipboard Clearer', description:'Sensitive copied text instantly clipboard se clear karo', icon:Icons.content_cut_outlined, category:ToolCategory.system, routeName:'/secure-clipboard'),

    // ══════════════════════════════════════════
    // NEW MEDIA TOOLS
    ToolItem(id:'image_to_webp', name:'Image to WebP', description:'JPEG/PNG images ko fast-loading WebP mein convert karo', icon:Icons.image_outlined, category:ToolCategory.media, routeName:'/image-to-webp'),
    ToolItem(id:'audio_cutter', name:'Audio Cutter', description:'Audio file se specific part kato aur save karo', icon:Icons.content_cut_outlined, category:ToolCategory.media, routeName:'/audio-cutter'),
    ToolItem(id:'story_resizer', name:'Story Size Resizer', description:'Content ko Instagram/WhatsApp story 9:16 size mein resize', icon:Icons.aspect_ratio_outlined, category:ToolCategory.media, routeName:'/story-resizer'),
    ToolItem(id:'meme_caption_overlay', name:'Meme Caption Overlay', description:'Image par bold meme-style text overlay add karo', icon:Icons.format_quote_outlined, category:ToolCategory.media, routeName:'/meme-caption-overlay'),
    ToolItem(id:'audio_to_mp3', name:'Audio to MP3 Extractor', description:'Any audio/video se MP3 format extract karo', icon:Icons.audio_file_outlined, category:ToolCategory.media, routeName:'/audio-to-mp3'),
    ToolItem(id:'photo_burst_cleaner', name:'Photo Burst Cleaner', description:'Burst/duplicate photos scan karo aur clean karo', icon:Icons.auto_delete_outlined, category:ToolCategory.media, routeName:'/photo-burst-cleaner'),
    ToolItem(id:'doc_scanner', name:'Document Scanner', description:'Camera se documents scan karo, PDF banao', icon:Icons.document_scanner_outlined, category:ToolCategory.media, routeName:'/doc-scanner'),

    // ══════════════════════════════════════════
    // DEVICE / SYSTEM POWER TOOLS
    ToolItem(id:'clipboard_manager', name:'Clipboard Manager', description:'Copied items save karo, history dekho, pin karo', icon:Icons.copy_all_outlined, category:ToolCategory.system, routeName:'/clipboard-manager'),
    ToolItem(id:'large_files', name:'Large Files Detector', description:'50MB+ files dhundho, storage free karo', icon:Icons.find_in_page_outlined, category:ToolCategory.system, routeName:'/large-files'),
    ToolItem(id:'notif_history', name:'Notification History', description:'Dismiss ho gayi notifications dobara dekho', icon:Icons.notifications_active_outlined, category:ToolCategory.system, routeName:'/notif-history'),
    ToolItem(id:'duplicate_contact', name:'Duplicate Contact Finder', description:'Duplicate phone contacts scan karo aur merge karo', icon:Icons.person_off_outlined, category:ToolCategory.system, routeName:'/duplicate-contact'),
    ToolItem(id:'unused_apps', name:'Unused Apps Detector', description:'Apps jo months se use nahi, unhe list karo', icon:Icons.apps_outage_outlined, category:ToolCategory.system, routeName:'/unused-apps'),
    ToolItem(id:'battery_charge_history', name:'Battery Charge History', description:'Charging patterns aur health trends dekho', icon:Icons.battery_charging_full_outlined, category:ToolCategory.system, routeName:'/battery-charge-history'),
    ToolItem(id:'notif_organizer', name:'Notification Organizer', description:'Notifications ko apps ke hisab se sort aur filter karo', icon:Icons.filter_list_outlined, category:ToolCategory.system, routeName:'/notif-organizer'),
    ToolItem(id:'screenshot_search', name:'Screenshot OCR Search', description:'Gallery screenshots mein text search karo', icon:Icons.image_search_outlined, category:ToolCategory.system, routeName:'/screenshot-search', needsGemini:true, isOffline:false),
    ToolItem(id:'permission_checker', name:'Permission Checker', description:'Kaunsi app kya access kar rahi hai sab dekho', icon:Icons.admin_panel_settings_outlined, category:ToolCategory.system, routeName:'/permission-checker'),
    ToolItem(id:'quick_copy_templates', name:'Quick Copy Templates', description:'Often-used text templates ek tap mein copy karo', icon:Icons.copy_outlined, category:ToolCategory.system, routeName:'/quick-copy-templates'),
    ToolItem(id:'phone_specs', name:'Phone Specs Dashboard', description:'Full hardware specs - CPU, RAM, GPU, display info', icon:Icons.smartphone_outlined, category:ToolCategory.system, routeName:'/phone-specs'),
    ToolItem(id:'network_checker', name:'Network Stability Checker', description:'Internet connection stability aur packet loss check karo', icon:Icons.network_check_outlined, category:ToolCategory.system, routeName:'/network-checker', isOffline:false),
    ToolItem(id:'old_downloads', name:'Old Downloads Cleaner', description:'3+ month purane downloads scan karo aur clean karo', icon:Icons.cleaning_services_outlined, category:ToolCategory.system, routeName:'/old-downloads'),
    ToolItem(id:'contact_backup', name:'Contact Backup Export', description:'Saare contacts VCard/CSV mein export karo', icon:Icons.import_export_outlined, category:ToolCategory.system, routeName:'/contact-backup'),

    // ══════════════════════════════════════════
    // INTERNET / WEB TOOLS
    ToolItem(id:'data_usage_tracker', name:'Data Usage Tracker', description:'App-wise internet data usage monitor karo', icon:Icons.data_usage_outlined, category:ToolCategory.networking, routeName:'/data-usage', isOffline:false),
    ToolItem(id:'wifi_speed_log', name:'WiFi Speed Log', description:'Har din ka internet speed history save karo', icon:Icons.wifi_tethering_outlined, category:ToolCategory.networking, routeName:'/wifi-speed-log', isOffline:false),
    ToolItem(id:'website_screenshot', name:'Website Screenshot', description:'URL dalo, AI screenshot save karega locally', icon:Icons.screenshot_outlined, category:ToolCategory.networking, routeName:'/website-screenshot', isOffline:false),

    // ══════════════════════════════════════════
    // FUN / LIFESTYLE TOOLS
    ToolItem(id:'stylish_text', name:'Stylish Text Generator', description:'Normal text ko fancy Unicode fonts mein convert karo', icon:Icons.font_download_outlined, category:ToolCategory.lifestyle, routeName:'/stylish-text'),
    ToolItem(id:'random_username', name:'Random Username Maker', description:'Unique, creative usernames instantly generate karo', icon:Icons.alternate_email_outlined, category:ToolCategory.lifestyle, routeName:'/random-username'),
    ToolItem(id:'truth_dare', name:'Truth or Dare Gen', description:'Friends ke saath Truth or Dare questions generate karo', icon:Icons.casino_outlined, category:ToolCategory.lifestyle, routeName:'/truth-dare'),
    ToolItem(id:'daily_motivation', name:'Daily Motivation Widget', description:'Personalized motivational quote har subah milega', icon:Icons.self_improvement_outlined, category:ToolCategory.lifestyle, routeName:'/daily-motivation'),
    ToolItem(id:'emergency_pack', name:'Emergency Pack', description:'ICE contacts, SOS note, battery saver tips ek jagah', icon:Icons.emergency_outlined, category:ToolCategory.lifestyle, routeName:'/emergency-pack'),
    ToolItem(id:'trip_splitter', name:'Trip Expense Splitter', description:'Group trip ka kharcha equal split karo', icon:Icons.group_outlined, category:ToolCategory.lifestyle, routeName:'/trip-splitter'),
    ToolItem(id:'digital_locker', name:'Digital Locker', description:'Important IDs, documents info locally secure save karo', icon:Icons.lock_outlined, category:ToolCategory.lifestyle, routeName:'/digital-locker'),
    ToolItem(id:'packing_ai', name:'Packing AI Checklist', description:'Destination batao, AI packing list suggest karega', icon:Icons.luggage_outlined, category:ToolCategory.lifestyle, routeName:'/packing-ai', needsClaude:true, isOffline:false),
    ToolItem(id:'quick_notes_pad', name:'Quick Notes Floating Pad', description:'Kahin bhi quick notes lene ke liye fast notepad', icon:Icons.note_add_outlined, category:ToolCategory.lifestyle, routeName:'/quick-notes-pad'),
    ToolItem(id:'duplicate_photo', name:'Duplicate Photo Cleaner', description:'Gallery ki duplicate photos dhundho aur delete karo', icon:Icons.photo_library_outlined, category:ToolCategory.lifestyle, routeName:'/duplicate-photo'),
    // ══════════════════════════════════════════
    // NEW TEXT TOOLS (from text.txt)
    ToolItem(id:'text_tone_detector', name:'Text Tone Detector', description:'Text ka tone detect karo — formal, casual, angry, happy', icon:Icons.mood_outlined, category:ToolCategory.text, routeName:'/text-tone'),
    ToolItem(id:'reading_time_calc', name:'Reading Time Calculator', description:'Text paste karo, kitna time lagega padhne mein', icon:Icons.timer_outlined, category:ToolCategory.text, routeName:'/reading-time'),
    ToolItem(id:'simple_paraphrase', name:'Simple Paraphrase Tool', description:'Sentence ko alag words mein rewrite karo', icon:Icons.sync_alt_outlined, category:ToolCategory.text, routeName:'/paraphrase'),
    ToolItem(id:'speech_pace_checker', name:'Speech Pace Checker', description:'Apni speech ka pace check karo — WPM calculate karo', icon:Icons.record_voice_over_outlined, category:ToolCategory.text, routeName:'/speech-pace'),
    // ══════════════════════════════════════════
    // NEW STUDENT TOOLS (from text.txt)
    ToolItem(id:'study_session_gen', name:'Study Session Generator', description:'Topic dalo, AI study session plan banayega', icon:Icons.menu_book_outlined, category:ToolCategory.student, routeName:'/study-session'),
    ToolItem(id:'memory_quiz_maker', name:'Memory Recall Quiz Maker', description:'Notes se quick recall quiz banao memory test ke liye', icon:Icons.quiz_outlined, category:ToolCategory.student, routeName:'/memory-quiz'),
    ToolItem(id:'random_topic_picker', name:'Random Learning Topic Picker', description:'Random educational topic spin karo aur seekho', icon:Icons.casino_outlined, category:ToolCategory.student, routeName:'/random-topic'),
    // ══════════════════════════════════════════
    // NEW PRODUCTIVITY TOOLS (from text.txt)
    ToolItem(id:'brainstorm_board', name:'Brainstorm Board', description:'Ideas dump karo, organize karo, connect karo', icon:Icons.lightbulb_outline, category:ToolCategory.productivity, routeName:'/brainstorm'),
    ToolItem(id:'focus_task_picker', name:'Focus Task Picker', description:'Overwhelmed ho? Ek random important task pick karo', icon:Icons.center_focus_strong_outlined, category:ToolCategory.productivity, routeName:'/focus-task'),
    ToolItem(id:'daily_question_prompt', name:'Daily Question Prompt', description:'Har din ek naya thought-provoking question milega', icon:Icons.help_outline, category:ToolCategory.productivity, routeName:'/daily-question'),
    // ══════════════════════════════════════════
    // NEW CREATOR TOOLS (from text.txt)
    ToolItem(id:'writing_prompt_spinner', name:'Writing Prompt Spinner', description:'Writers ke liye random creative writing prompts', icon:Icons.draw_outlined, category:ToolCategory.creator, routeName:'/writing-prompt'),
    ToolItem(id:'hook_word_bank', name:'Hook Word Bank', description:'Viral hooks ke liye power words ka full bank', icon:Icons.bolt_outlined, category:ToolCategory.creator, routeName:'/hook-words'),
    ToolItem(id:'thumbnail_keyword_board', name:'Thumbnail Keyword Board', description:'YouTube thumbnails ke liye best keywords aur phrases', icon:Icons.image_search_outlined, category:ToolCategory.creator, routeName:'/thumbnail-keywords'),
    ToolItem(id:'content_challenge_7day', name:'7-Day Content Challenge', description:'7 din ka daily content challenge track karo', icon:Icons.emoji_events_outlined, category:ToolCategory.creator, routeName:'/7day-challenge'),
    ToolItem(id:'reel_shot_checklist', name:'Reel Shot Checklist', description:'Reel shoot se pehle sab ready hai? checklist', icon:Icons.checklist_outlined, category:ToolCategory.creator, routeName:'/reel-checklist'),
    ToolItem(id:'niche_topic_roulette', name:'Niche Topic Roulette', description:'Spin karo aur apne niche mein random topic pao', icon:Icons.rotate_right_outlined, category:ToolCategory.creator, routeName:'/niche-roulette'),
    ToolItem(id:'series_episode_counter', name:'Series Episode Counter', description:'Apni content series ke episodes track karo', icon:Icons.format_list_numbered_outlined, category:ToolCategory.creator, routeName:'/series-counter'),
    ToolItem(id:'cta_phrase_picker', name:'CTA Phrase Picker', description:'Best Call-to-Action phrases library se pick karo', icon:Icons.ads_click_outlined, category:ToolCategory.creator, routeName:'/cta-picker'),
    // ══════════════════════════════════════════
    // NEW FILE / SYSTEM TOOLS (from text.txt)
    ToolItem(id:'old_media_sorter', name:'Old Media Sorter', description:'6+ month purani photos/videos date-wise sort karo', icon:Icons.photo_album_outlined, category:ToolCategory.system, routeName:'/old-media-sorter'),
    ToolItem(id:'folder_color_tags', name:'Folder Color Tags', description:'Folders ko color tags se organize karo', icon:Icons.folder_special_outlined, category:ToolCategory.file, routeName:'/folder-color-tags'),
    ToolItem(id:'temp_file_cleaner', name:'Temporary File Cleaner', description:'App cache aur temp files scan kar ke clean karo', icon:Icons.cleaning_services_outlined, category:ToolCategory.system, routeName:'/temp-cleaner'),
    ToolItem(id:'file_share_history', name:'File Share History Log', description:'Kaunsi file kab share ki — poora history dekho', icon:Icons.history_outlined, category:ToolCategory.system, routeName:'/share-history'),
    ToolItem(id:'storage_trend_tracker', name:'Storage Trend Tracker', description:'Storage usage ka weekly trend chart dekho', icon:Icons.trending_up_outlined, category:ToolCategory.system, routeName:'/storage-trend'),
    ToolItem(id:'rename_by_date', name:'Rename by Date Tool', description:'Files ko automatically date se rename karo', icon:Icons.drive_file_rename_outline, category:ToolCategory.file, routeName:'/rename-by-date'),
    // ══════════════════════════════════════════
    // NEW LIFESTYLE TOOLS (from text.txt)
    ToolItem(id:'habit_reflection', name:'Habit Reflection Helper', description:'Apni habits review karo — kya achha kya bura', icon:Icons.self_improvement_outlined, category:ToolCategory.lifestyle, routeName:'/habit-reflect'),
    ToolItem(id:'decision_coin', name:'Decision Coin with Reasons', description:'Coin toss + reasons dono sides ke liye', icon:Icons.flaky_outlined, category:ToolCategory.lifestyle, routeName:'/decision-coin'),
    ToolItem(id:'privacy_checklist', name:'Privacy Checklist', description:'Phone privacy audit karo — sab secure hai?', icon:Icons.privacy_tip_outlined, category:ToolCategory.lifestyle, routeName:'/privacy-checklist'),
    ToolItem(id:'hidden_reminder_labels', name:'Hidden Reminder Labels', description:'Private reminders jo sirf tum dekh sako', icon:Icons.label_outlined, category:ToolCategory.lifestyle, routeName:'/hidden-reminders'),
    ToolItem(id:'mood_check_tracker', name:'Mood Check Tracker', description:'Apna daily mood log karo aur pattern dekho', icon:Icons.sentiment_satisfied_outlined, category:ToolCategory.lifestyle, routeName:'/mood-tracker'),
    ToolItem(id:'grocery_tick_list', name:'Grocery Quick Tick List', description:'Market jaate waqt fast grocery checklist', icon:Icons.shopping_cart_outlined, category:ToolCategory.lifestyle, routeName:'/grocery-list'),
    ToolItem(id:'lost_found_notes', name:'Lost & Found Notes', description:'Kho jaane wali important cheezein note karo', icon:Icons.search_outlined, category:ToolCategory.lifestyle, routeName:'/lost-found'),
    ToolItem(id:'app_use_privacy_notes', name:'App Use Privacy Notes', description:'Kaunsa app kab use kiya — personal privacy log', icon:Icons.app_settings_alt_outlined, category:ToolCategory.lifestyle, routeName:'/app-privacy-notes'),
    ToolItem(id:'backup_password_hints', name:'Backup Password Hint Vault', description:'Password hints safely store karo — actual password nahi', icon:Icons.vpn_key_outlined, category:ToolCategory.lifestyle, routeName:'/password-hints'),
    // ══════════════════════════════════════════
    // NEW FINANCE / UTILITY TOOLS (from text.txt)
    ToolItem(id:'weekend_budget_planner', name:'Weekend Budget Planner', description:'Weekend ka budget plan karo — outing, food, fun', icon:Icons.weekend_outlined, category:ToolCategory.finance, routeName:'/weekend-budget'),
    ToolItem(id:'queue_number_tracker', name:'Queue Number Tracker', description:'Bank/hospital queue number track karo', icon:Icons.queue_outlined, category:ToolCategory.utility, routeName:'/queue-tracker'),
  ];
  static List<ToolItem> byCategory(ToolCategory category) =>
      all.where((t) => t.category == category).toList();
  static ToolItem? byId(String id) {
    try { return all.firstWhere((t) => t.id == id); } catch (_) { return null; }
  }
  static List<ToolItem> search(String query) {
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((t) =>
        t.name.toLowerCase().contains(q) ||
        t.description.toLowerCase().contains(q) ||
        t.category.name.toLowerCase().contains(q)).toList();
  }

  static Map<ToolCategory, String> categoryNames = {
    ToolCategory.file: 'File Vault',
    ToolCategory.text: 'Text Tools',
    ToolCategory.media: 'Media Studio',
    ToolCategory.downloader: 'Downloader',
    ToolCategory.ai: 'AI Lab',
    ToolCategory.codeEditor: 'Code Editors',
    ToolCategory.developer: 'Dev Shack',
    ToolCategory.utility: 'Utility',
    ToolCategory.networking: 'Networking',
    ToolCategory.system: 'System Tools',
    ToolCategory.business: 'Business',
    ToolCategory.lifestyle: 'Lifestyle',
    ToolCategory.creator: 'Creator Empire',
    ToolCategory.student: 'Student Hub',
    ToolCategory.productivity: 'Productivity',
    ToolCategory.gaming: 'Gamer Zone',
    ToolCategory.finance: 'Money Tools',
  };
  static Map<ToolCategory, IconData> categoryIcons = {
    ToolCategory.file: Icons.folder_outlined,
    ToolCategory.text: Icons.text_snippet_outlined,
    ToolCategory.media: Icons.perm_media_outlined,
    ToolCategory.downloader: Icons.download_outlined,
    ToolCategory.ai: Icons.auto_awesome_outlined,
    ToolCategory.codeEditor: Icons.code_outlined,
    ToolCategory.developer: Icons.developer_mode_outlined,
    ToolCategory.utility: Icons.build_outlined,
    ToolCategory.networking: Icons.wifi_outlined,
    ToolCategory.system: Icons.phone_android_outlined,
    ToolCategory.business: Icons.business_outlined,
    ToolCategory.lifestyle: Icons.favorite_outline,
    ToolCategory.creator: Icons.movie_creation_outlined,
    ToolCategory.student: Icons.school_outlined,
    ToolCategory.productivity: Icons.rocket_launch_outlined,
    ToolCategory.gaming: Icons.sports_esports_outlined,
    ToolCategory.finance: Icons.account_balance_wallet_outlined,
  };
}
