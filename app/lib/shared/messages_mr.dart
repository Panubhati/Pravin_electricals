import 'strings.dart';

/// Messages that come from deep in the app (the shop's rules, backups, Check
/// my data) are written in English where they are made. They are put into
/// Marathi here, at the moment they are shown, by matching the English
/// sentence. Numbers, names and bill numbers in the sentence are kept.
///
/// Each entry: an English pattern (a RegExp matching the whole message) and
/// the Marathi text, where $1, $2... are the parts the pattern captured.
/// A message with no pattern stays English (rare, mostly programming errors).
const messagePatternsMr = <(String, String)>[
  // Billing and returns
  (r'Credit sale needs a customer', r'उधार विक्रीसाठी ग्राहक हवा'),
  (r'Payments must add up to the invoice total', r'पैशांची बेरीज बिलाच्या एकूण इतकी हवी'),
  (r'Invoice has no lines', r'बिलात एकही वस्तू नाही'),
  (r'Invoice number (.+) already exists on this device\.', r'बिल क्रमांक $1 या फोनवर आधीच आहे.'),
  (r'Bill (.+) is already cancelled\.', r'बिल $1 आधीच रद्द झाले आहे.'),
  (r'Some of bill (.+) has already been returned\. Return the rest instead of cancelling\.',
      r'बिल $1 मधील काही माल आधीच परत आला आहे. रद्द करण्याऐवजी उरलेला माल परत घ्या.'),
  (r'Choose what is being returned\.', r'काय परत येत आहे ते निवडा.'),
  (r'Only a bill with a customer can be refunded to their account\.', r'ग्राहक असलेल्या बिलाचेच पैसे त्यांच्या खात्यात परत देता येतात.'),
  (r'Refund amounts cannot be negative\.', r'परतीची रक्कम उणे असू शकत नाही.'),
  (r'That credit note number was just used\. Please try again\.', r'तो क्रेडिट नोट क्रमांक आत्ताच वापरला. पुन्हा प्रयत्न करा.'),
  (r'(.+) is listed twice\.', r'$1 दोनदा आहे.'),
  (r'(.+): "(.+)" is not a valid quantity\.', r'$1: "$2" हे योग्य नग नाहीत.'),
  (r'(.+): the quantity must be more than 0\.', r'$1: नग 0 पेक्षा जास्त हवेत.'),
  (r'The refund must add up to (.+)\.', r'परतीची बेरीज $1 हवी.'),
  // Purchases
  (r'Supplier invoice (.+) was already entered\.', r'पुरवठादार बिल $1 आधीच नोंदवले आहे.'),
  (r'Supplier invoice number is required', r'पुरवठादाराचा बिल क्रमांक हवा'),
  (r'Purchase (.+) is already cancelled\.', r'खरेदी $1 आधीच रद्द झाली आहे.'),
  (r'Purchase has no lines', r'खरेदीत एकही वस्तू नाही'),
  // Items, stock, people
  (r'Item name is required', r'वस्तूचे नाव हवे'),
  (r'Name is required', r'नाव हवे'),
  (r'Enter a name\.', r'नाव टाका.'),
  (r'Enter the shop name\.', r'दुकानाचे नाव टाका.'),
  (r'Variant name is required', r'प्रकाराचे नाव हवे'),
  (r'Unit name is required', r'युनिटचे नाव हवे'),
  (r'Unit "(.+)" already exists', r'युनिट "$1" आधीच आहे'),
  (r'Barcode (.+) is already used by another item', r'बारकोड $1 दुसऱ्या वस्तूला आधीच आहे'),
  (r'The base unit cannot be removed', r'मूळ युनिट काढता येत नाही'),
  (r'The pricing unit cannot be removed', r'किमतीचे युनिट काढता येत नाही'),
  (r'The base unit cannot be changed', r'मूळ युनिट बदलता येत नाही'),
  (r'Rate cannot be negative', r'दर उणे असू शकत नाही'),
  (r'GST rate cannot be negative', r'GST दर उणे असू शकत नाही'),
  (r'Minimum stock cannot be negative', r'किमान स्टॉक उणे असू शकत नाही'),
  (r'Counted quantity cannot be negative', r'मोजलेले नग उणे असू शकत नाहीत'),
  (r'Adjustment cannot be zero', r'बदल शून्य असू शकत नाही'),
  (r'A reason is required', r'कारण हवे'),
  (r'Credit limit cannot be negative', r'उधार मर्यादा उणे असू शकत नाही'),
  (r'GSTIN must be 15 letters and digits\.', r'GSTIN 15 अक्षरे-अंकांचा हवा.'),
  (r'State code must be 2 digits \(for example 27 for Maharashtra\)\.', r'राज्य कोड 2 अंकी हवा (उदा. महाराष्ट्रासाठी 27).'),
  (r'UPI ID should look like shop@bank\.', r'UPI ID shop@bank असा असावा.'),
  (r'The stock for this sale could not be found\.', r'या विक्रीचा स्टॉक सापडला नाही.'),
  // PINs and staff
  (r'PIN must be 4 to 6 digits\.', r'PIN 4 ते 6 अंकी हवा.'),
  (r'A user named "(.+)" already exists\.', r'"$1" नावाचा वापरकर्ता आधीच आहे.'),
  (r'The owner cannot be removed\.', r'मालकाला काढता येत नाही.'),
  // Backup and restore
  (r'Could not make a backup\. Try again\.', r'बॅकअप घेता आला नाही. पुन्हा प्रयत्न करा.'),
  (r'Could not make a backup: (.+)', r'बॅकअप घेता आला नाही: $1'),
  (r'The data kept changing while backing up\. Try again\.', r'बॅकअप घेताना माहिती बदलत राहिली. पुन्हा प्रयत्न करा.'),
  (r'The phone is out of storage space\. Free some space and try again\. Your current data was not changed\.',
      r'फोनमध्ये जागा संपली. थोडी जागा मोकळी करा आणि पुन्हा प्रयत्न करा. तुमची आत्ताची माहिती बदलली नाही.'),
  (r'The phone is out of storage space\. Free some space and try again\.',
      r'फोनमध्ये जागा संपली. थोडी जागा मोकळी करा आणि पुन्हा प्रयत्न करा.'),
  (r'Could not restore the backup: (.+)\. Your current data was not changed\.',
      r'बॅकअप परत आणता आला नाही: $1. तुमची आत्ताची माहिती बदलली नाही.'),
  (r'Could not write the backup file: (.+)', r'बॅकअप फाइल लिहिता आली नाही: $1'),
  (r'The backup did not match your data, so it was not used\. \((.+)\)', r'बॅकअप तुमच्या माहितीशी जुळला नाही, म्हणून वापरला नाही. ($1)'),
  (r'This backup file is damaged and cannot be used\.', r'ही बॅकअप फाइल खराब आहे, वापरता येत नाही.'),
  (r'This backup has no shop in it\.', r'या बॅकअपमध्ये दुकान नाही.'),
  (r'This is not a backup made by this app, or the file is damaged\.', r'हा या ॲपचा बॅकअप नाही, किंवा फाइल खराब आहे.'),
  (r'This is not a backup made by this app\.', r'हा या ॲपचा बॅकअप नाही.'),
  (r'This backup was made by a newer version of the app\. Update the app first, then restore\.',
      r'हा बॅकअप ॲपच्या नवीन आवृत्तीने बनवला आहे. आधी ॲप अपडेट करा, मग परत आणा.'),
  (r'That file is empty\.', r'ती फाइल रिकामी आहे.'),
  (r'You have not made a backup yet\.', r'तुम्ही अजून बॅकअप घेतलेला नाही.'),
  (r'Your last backup was (\d+) days ago\.', r'तुमचा शेवटचा बॅकअप $1 दिवसांपूर्वी घेतला होता.'),
  (r'The date of your last backup looks wrong \(the phone clock may have been changed\)\. Please back up again\.',
      r'शेवटच्या बॅकअपची तारीख चुकीची दिसते (फोनचे घड्याळ बदलले असेल). कृपया पुन्हा बॅकअप घ्या.'),
  // Wi-Fi sync
  (r'This phone is not on a Wi-Fi network\.', r'हा फोन Wi-Fi वर नाही.'),
  (r"This phone was removed from the shop\. Pair it again from the owner's phone\.",
      r'हा फोन दुकानातून काढला आहे. मालकाच्या फोनवरून पुन्हा जोडा.'),
  (r"This pairing code has expired or was already used\. Show a new one on the owner's phone\.",
      r'हा जोडणी कोड जुना झाला किंवा आधीच वापरला. मालकाच्या फोनवर नवीन कोड दाखवा.'),
  (r"This message was not made with this shop's key", r'हा संदेश या दुकानाच्या चावीने बनवलेला नाही'),
  (r"The two phones' clocks differ by more than (\d+) minutes, or the message is old",
      r'दोन्ही फोनच्या घड्याळात $1 मिनिटांपेक्षा जास्त फरक आहे, किंवा संदेश जुना आहे'),
  (r'The other phone sent "(.+)", which this app does not know\. Update the app on both phones\.',
      r'दुसऱ्या फोनने "$1" पाठवले, जे या ॲपला माहीत नाही. दोन्ही फोनवर ॲप अपडेट करा.'),
  (r'A phone needs a name', r'फोनला नाव हवे'),
  (r'This shop already has 26 phones', r'या दुकानात आधीच 26 फोन आहेत'),
  // Check my data
  (r'(.+): stock is (.+) \(below zero\)\.', r'$1: स्टॉक $2 (शून्याखाली).'),
  (r"Bill (.+) is dated in the future \(was the phone's clock wrong\?\)\.", r'बिल $1 ची तारीख पुढची आहे (फोनचे घड्याळ चुकले होते का?).'),
  (r'Series (.+): numbers (\d+) to (\d+) should be (\d+) bills but (\d+) exist\.',
      r'मालिका $1: क्रमांक $2 ते $3 म्हणजे $4 बिले हवीत, पण $5 आहेत.'),
  (r'Supplier bill (.+) from (.+) was entered (\d+) times\. Cancel the extra one\.',
      r'$2 चे पुरवठादार बिल $1 हे $3 वेळा नोंदवले आहे. जास्तीचे रद्द करा.'),
  (r'Cancelled purchase (.+) was not fully reversed \(stock or the supplier account\)\.',
      r'रद्द केलेली खरेदी $1 पूर्ण उलटली नाही (स्टॉक किंवा पुरवठादाराचे खाते).'),
  (r'Bill (.+?), (.+): (.+) sold but (.+) left stock\.', r'बिल $1, $2: $3 विकले पण स्टॉकमधून $4 कमी झाले.'),
  (r'Purchase (.+?), (.+): (.+) bought but (.+) added to stock\.', r'खरेदी $1, $2: $3 घेतले पण स्टॉकमध्ये $4 वाढले.'),
  (r'Credit note (.+?), (.+): (.+) returned but (.+) went back into stock\.', r'क्रेडिट नोट $1, $2: $3 परत आले पण स्टॉकमध्ये $4 गेले.'),
  (r'Purchase (.+): (.+) should be owed to the supplier, but their account shows (.+) in (\d+) entries\.',
      r'खरेदी $1: पुरवठादाराला $2 देणे हवे, पण त्यांचे खाते $4 नोंदींमध्ये $3 दाखवते.'),
  (r'Purchase (.+?), (.+): a line does not equal quantity x rate\.', r'खरेदी $1, $2: एक ओळ नग × दर इतकी नाही.'),
  (r'(.+): stock was (taken out|added) \((.+)\) for a (bill|purchase|returned) line that does not exist\.',
      r'$1: अस्तित्वात नसलेल्या ओळीसाठी स्टॉक बदलला ($3).'),
  (r'(.+): (\d+) "(.+)" stock movement\(s\) have the wrong direction or no quantity\.',
      r'$1: $2 "$3" स्टॉक नोंदींची दिशा चुकीची आहे किंवा नग नाहीत.'),
  (r'(.+): an account entry \((.+)\) points at a (.+) that does not exist\.', r'$1: खात्यातील नोंद ($2) अस्तित्वात नसलेल्या $3 कडे आहे.'),
  (r'(.+): (\d+) "(.+)" account entr(y|ies) with the wrong sign\.', r'$1: $2 "$3" खाते नोंदींचे चिन्ह चुकीचे आहे.'),
  (r'(.+) is a (customer|supplier) but has (\d+) account entries of the other kind\.',
      r'$1 हा $2 आहे पण त्याच्या खात्यात दुसऱ्या प्रकारच्या $3 नोंदी आहेत.'),
  (r'There should be exactly one owner but there are (\d+)\.', r'मालक एकच हवा, पण $1 आहेत.'),
  (r'The owner has no PIN set\.', r'मालकाचा PIN ठेवलेला नाही.'),
  (r'The database file reports a problem: (.+)', r'माहितीच्या फाइलमध्ये अडचण: $1'),
  (r'(\d+) record\(s\) point at something that no longer exists \(for example (.+)\)\.',
      r'$1 नोंदी अस्तित्वात नसलेल्या गोष्टीकडे आहेत (उदा. $2).'),
  (r'Bill (.+?): (.+)', r'बिल $1: $2'),
  (r'Credit note (.+?): (.+)', r'क्रेडिट नोट $1: $2'),
];

final _compiled = [for (final (p, t) in messagePatternsMr) (RegExp('^$p\$'), t)];

/// [english] in the screen language. Unknown messages stay English.
String localizeMessage(String english) {
  if (S.lang != AppLang.mr) return english;
  for (final (re, template) in _compiled) {
    final m = re.firstMatch(english);
    if (m == null) continue;
    var out = template;
    for (var i = m.groupCount; i >= 1; i--) {
      out = out.replaceAll('\$$i', m.group(i) ?? '');
    }
    return out;
  }
  return english;
}
