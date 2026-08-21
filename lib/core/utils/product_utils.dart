/// Product-name localization used across the complete shopping flow.
///
/// The English name remains first so search and existing Firestore data keep
/// working, while customers also see the familiar Telugu name everywhere.
class ProductUtils {
  ProductUtils._();

  static const Map<String, String> _teluguNames = <String, String>{
    // Vegetables
    'amaranth': 'తోటకూర',
    'ash_gourd': 'బూడిద గుమ్మడికాయ',
    'asparagus': 'ఆస్పరాగస్',
    'bamboo_shoot': 'వెదురు మొగ్గలు',
    'beetroot': 'బీట్‌రూట్',
    'bitter_gourd': 'కాకరకాయ',
    'bottle_gourd': 'సొరకాయ',
    'brinjal': 'వంకాయ',
    'broccoli': 'బ్రోకలి',
    'cabbage': 'క్యాబేజీ',
    'capsicum': 'క్యాప్సికమ్',
    'carrot': 'క్యారెట్',
    'cauliflower': 'కాలీఫ్లవర్',
    'celery': 'సెలరీ',
    'chow_chow': 'చౌ చౌ',
    'cluster_beans': 'గోరుచిక్కుడు',
    'colocasia': 'చామదుంప',
    'coriander': 'కొత్తిమీర',
    'corn': 'మొక్కజొన్న',
    'cucumber': 'దోసకాయ',
    'curry_leaves': 'కరివేపాకు',
    'dill_leaves': 'సోపు ఆకులు',
    'drumstick': 'మునగకాయ',
    'fenugreek': 'మెంతికూర',
    'french_beans': 'ఫ్రెంచ్ బీన్స్',
    'green_chilli': 'పచ్చిమిర్చి',
    'green_peas': 'పచ్చి బఠాణీలు',
    'ivy_gourd': 'దొండకాయ',
    'kale': 'కేల్ ఆకులు',
    'lettuce': 'లెట్యూస్',
    'mint': 'పుదీనా',
    'mushroom': 'పుట్టగొడుగులు',
    'okra': 'బెండకాయ',
    'onion': 'ఉల్లిపాయ',
    'potato': 'బంగాళాదుంప',
    'pumpkin': 'గుమ్మడికాయ',
    'radish': 'ముల్లంగి',
    'raw_banana': 'అరటికాయ',
    'red_chilli': 'ఎర్ర మిర్చి',
    'ridge_gourd': 'బీరకాయ',
    'snake_gourd': 'పొట్లకాయ',
    'spinach': 'పాలకూర',
    'spring_onion': 'ఉల్లికాడలు',
    'sweet_potato': 'చిలగడదుంప',
    'tomato': 'టమాటా',
    'turnip': 'టర్నిప్',
    'yam': 'కందగడ్డ',
    'zucchini': 'జుక్కిని',

    // Fruits
    'apple': 'ఆపిల్',
    'apricot': 'ఆప్రికాట్',
    'avocado': 'అవకాడో',
    'banana': 'అరటిపండు',
    'blackberry': 'బ్లాక్‌బెర్రీ',
    'blueberry': 'బ్లూబెర్రీ',
    'cherry': 'చెర్రీ',
    'clementine': 'క్లెమెంటైన్',
    'coconut': 'కొబ్బరికాయ',
    'cranberry': 'క్రాన్‌బెర్రీ',
    'custard_apple': 'సీతాఫలం',
    'dates': 'ఖర్జూరాలు',
    'dragon_fruit': 'డ్రాగన్ ఫ్రూట్',
    'fig': 'అంజీర్ పండు',
    'gooseberry': 'ఉసిరికాయ',
    'grapes': 'ద్రాక్ష',
    'guava': 'జామపండు',
    'jackfruit': 'పనసపండు',
    'jamun': 'నేరేడు పండు',
    'kiwi': 'కివీ',
    'lemon': 'నిమ్మకాయ',
    'longan': 'లాంగన్',
    'lychee': 'లిచీ',
    'mango': 'మామిడి',
    'mangosteen': 'మాంగోస్టీన్',
    'mulberry': 'మల్బెర్రీ',
    'muskmelon': 'ఖర్బూజా',
    'orange': 'నారింజ',
    'papaya': 'బొప్పాయి',
    'passion_fruit': 'ప్యాషన్ ఫ్రూట్',
    'peach': 'పీచ్',
    'pear': 'బేరిపండు',
    'persimmon': 'పర్సిమ్మన్',
    'pineapple': 'అనాసపండు',
    'plantain': 'పచ్చి అరటి',
    'plum': 'ప్లమ్',
    'pomegranate': 'దానిమ్మ',
    'pomelo': 'పంపరపనస',
    'rambutan': 'రాంబుటాన్',
    'raspberry': 'రాస్ప్‌బెర్రీ',
    'red_banana': 'ఎర్ర అరటిపండు',
    'sapota': 'సపోటా',
    'soursop': 'లక్ష్మణ ఫలం',
    'star_fruit': 'స్టార్ ఫ్రూట్',
    'strawberry': 'స్ట్రాబెర్రీ',
    'sweet_lime': 'మోసంబి',
    'tangerine': 'టాంజరిన్',
    'tender_coconut': 'లేత కొబ్బరి',
    'watermelon': 'పుచ్చకాయ',
    'wood_apple': 'వెలగపండు',

    // Dairy
    'butter': 'వెన్న',
    'buttermilk': 'మజ్జిగ',
    'cheddar_cheese': 'చెడార్ చీజ్',
    'cheese': 'చీజ్',
    'curd': 'పెరుగు',
    'full_cream_milk': 'ఫుల్ క్రీమ్ పాలు',
    'ghee': 'నెయ్యి',
    'greek_yogurt': 'గ్రీక్ యోగర్ట్',
    'lassi': 'లస్సీ',
    'milk': 'పాలు',
    'organic_milk': 'సేంద్రియ పాలు',
    'salted_butter': 'ఉప్పు వెన్న',
    'toned_milk': 'టోన్డ్ పాలు',
  };

  static String teluguName(String englishName) {
    return _teluguNames[_normalize(englishName)] ?? '';
  }

  static String localizedName(String productName) {
    final String cleanName = productName.trim();
    if (cleanName.isEmpty || RegExp(r'[\u0C00-\u0C7F]').hasMatch(cleanName)) {
      return cleanName;
    }
    final String telugu = teluguName(cleanName);
    return telugu.isEmpty ? cleanName : '$cleanName ($telugu)';
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
