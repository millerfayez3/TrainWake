/**
 * TrainWake Web Portal - Egyptian National Railways (ENR) Stations Data
 * 92 Authenticated Stations across Cairo, Delta, Canal, and Upper Egypt
 */

const ENR_STATIONS = [
  { "id": "alexandria_misr", "nameAr": "الإسكندرية (محطة مصر)", "nameEn": "Alexandria (Misr)", "region": "alex", "latitude": 31.1925, "longitude": 29.9056, "routeIds": ["alex_cairo"] },
  { "id": "sidi_gaber", "nameAr": "سيدي جابر", "nameEn": "Sidi Gaber", "region": "alex", "latitude": 31.2185, "longitude": 29.9392, "routeIds": ["alex_cairo"] },
  { "id": "kafr_el_dawwar", "nameAr": "كفر الدوار", "nameEn": "Kafr El Dawwar", "region": "delta", "latitude": 31.1340, "longitude": 30.1287, "routeIds": ["alex_cairo"] },
  { "id": "abu_hummud", "nameAr": "أبو حمص", "nameEn": "Abu Hummud", "region": "delta", "latitude": 31.1017, "longitude": 30.3090, "routeIds": ["alex_cairo"] },
  { "id": "damanhour", "nameAr": "دمنهور", "nameEn": "Damanhour", "region": "delta", "latitude": 31.0375, "longitude": 30.4694, "routeIds": ["alex_cairo"] },
  { "id": "itay_el_baroud", "nameAr": "إيتاي البارود", "nameEn": "Itay El Baroud", "region": "delta", "latitude": 30.8876, "longitude": 30.6629, "routeIds": ["alex_cairo"] },
  { "id": "kafr_el_zayat", "nameAr": "كفر الزيات", "nameEn": "Kafr El Zayat", "region": "delta", "latitude": 30.8239, "longitude": 30.8174, "routeIds": ["alex_cairo"] },
  { "id": "tanta", "nameAr": "طنطا", "nameEn": "Tanta", "region": "delta", "latitude": 30.7871, "longitude": 31.0011, "routeIds": ["alex_cairo", "delta"] },
  { "id": "birket_el_saba", "nameAr": "بركة السبع", "nameEn": "Birket El Saba", "region": "delta", "latitude": 30.6385, "longitude": 31.0827, "routeIds": ["alex_cairo"] },
  { "id": "quesna", "nameAr": "قويسنا", "nameEn": "Quesna", "region": "delta", "latitude": 30.5593, "longitude": 31.1444, "routeIds": ["alex_cairo"] },
  { "id": "banha", "nameAr": "بنها", "nameEn": "Banha", "region": "cairo", "latitude": 30.4632, "longitude": 31.1818, "routeIds": ["alex_cairo"] },
  { "id": "toukh", "nameAr": "طوخ", "nameEn": "Toukh", "region": "cairo", "latitude": 30.3541, "longitude": 31.1995, "routeIds": ["alex_cairo"] },
  { "id": "qalyub", "nameAr": "قليوب", "nameEn": "Qalyub", "region": "cairo", "latitude": 30.1830, "longitude": 31.2057, "routeIds": ["alex_cairo"] },
  { "id": "shubra_el_kheima", "nameAr": "شبرا الخيمة", "nameEn": "Shubra El Kheima", "region": "cairo", "latitude": 30.1264, "longitude": 31.2464, "routeIds": ["alex_cairo"] },
  { "id": "cairo_ramses", "nameAr": "القاهرة (رمسيس)", "nameEn": "Cairo (Ramses)", "region": "cairo", "latitude": 30.0636, "longitude": 31.2464, "routeIds": ["alex_cairo", "cairo_aswan", "canal"] },
  
  { "id": "giza", "nameAr": "الجيزة", "nameEn": "Giza", "region": "cairo", "latitude": 30.0055, "longitude": 31.2052, "routeIds": ["cairo_aswan"] },
  { "id": "badrashin", "nameAr": "البدرشين", "nameEn": "Badrashin", "region": "cairo", "latitude": 29.8519, "longitude": 31.2588, "routeIds": ["cairo_aswan"] },
  { "id": "ayat", "nameAr": "العياط", "nameEn": "Ayat", "region": "cairo", "latitude": 29.6200, "longitude": 31.2505, "routeIds": ["cairo_aswan"] },
  { "id": "wasta", "nameAr": "الواسطى", "nameEn": "Wasta", "region": "upper", "latitude": 29.3387, "longitude": 31.2051, "routeIds": ["cairo_aswan"] },
  { "id": "beni_suef", "nameAr": "بني سويف", "nameEn": "Beni Suef", "region": "upper", "latitude": 29.0734, "longitude": 31.0978, "routeIds": ["cairo_aswan"] },
  { "id": "biba", "nameAr": "ببا", "nameEn": "Biba", "region": "upper", "latitude": 28.9103, "longitude": 31.0116, "routeIds": ["cairo_aswan"] },
  { "id": "fashn", "nameAr": "الفشن", "nameEn": "Fashn", "region": "upper", "latitude": 28.8239, "longitude": 30.9004, "routeIds": ["cairo_aswan"] },
  { "id": "maghagha", "nameAr": "مغاغة", "nameEn": "Maghagha", "region": "upper", "latitude": 28.6508, "longitude": 30.8415, "routeIds": ["cairo_aswan"] },
  { "id": "beni_mazar", "nameAr": "بني مزار", "nameEn": "Beni Mazar", "region": "upper", "latitude": 28.5029, "longitude": 30.8001, "routeIds": ["cairo_aswan"] },
  { "id": "mattai", "nameAr": "مطاي", "nameEn": "Mattai", "region": "upper", "latitude": 28.4168, "longitude": 30.7797, "routeIds": ["cairo_aswan"] },
  { "id": "samalut", "nameAr": "سمالوط", "nameEn": "Samalut", "region": "upper", "latitude": 28.3120, "longitude": 30.7441, "routeIds": ["cairo_aswan"] },
  { "id": "minya", "nameAr": "المنيا", "nameEn": "Minya", "region": "upper", "latitude": 28.1130, "longitude": 30.7495, "routeIds": ["cairo_aswan"] },
  { "id": "abu_qurqas", "nameAr": "أبو قرقاص", "nameEn": "Abu Qurqas", "region": "upper", "latitude": 27.9304, "longitude": 30.7674, "routeIds": ["cairo_aswan"] },
  { "id": "mallawi", "nameAr": "ملوي", "nameEn": "Mallawi", "region": "upper", "latitude": 27.7324, "longitude": 30.8406, "routeIds": ["cairo_aswan"] },
  { "id": "deir_mawas", "nameAr": "دير مواس", "nameEn": "Deir Mawas", "region": "upper", "latitude": 27.6409, "longitude": 30.8492, "routeIds": ["cairo_aswan"] },
  { "id": "dairut", "nameAr": "ديروط", "nameEn": "Dairut", "region": "upper", "latitude": 27.5562, "longitude": 30.8078, "routeIds": ["cairo_aswan"] },
  { "id": "qusiya", "nameAr": "القوصية", "nameEn": "Qusiya", "region": "upper", "latitude": 27.4418, "longitude": 30.8170, "routeIds": ["cairo_aswan"] },
  { "id": "manfalut", "nameAr": "منفلوط", "nameEn": "Manfalut", "region": "upper", "latitude": 27.3134, "longitude": 30.9675, "routeIds": ["cairo_aswan"] },
  { "id": "assiut", "nameAr": "أسيوط", "nameEn": "Assiut", "region": "upper", "latitude": 27.1824, "longitude": 31.1843, "routeIds": ["cairo_aswan"] },
  { "id": "abu_tig", "nameAr": "أبو تيج", "nameEn": "Abu Tig", "region": "upper", "latitude": 27.0425, "longitude": 31.3197, "routeIds": ["cairo_aswan"] },
  { "id": "sedfa", "nameAr": "صدفا", "nameEn": "Sedfa", "region": "upper", "latitude": 26.9749, "longitude": 31.3653, "routeIds": ["cairo_aswan"] },
  { "id": "tema", "nameAr": "طما", "nameEn": "Tema", "region": "upper", "latitude": 26.9115, "longitude": 31.4394, "routeIds": ["cairo_aswan"] },
  { "id": "tahta", "nameAr": "طهطا", "nameEn": "Tahta", "region": "upper", "latitude": 26.7686, "longitude": 31.4994, "routeIds": ["cairo_aswan"] },
  { "id": "maragha", "nameAr": "المراغة", "nameEn": "Maragha", "region": "upper", "latitude": 26.6974, "longitude": 31.5975, "routeIds": ["cairo_aswan"] },
  { "id": "sohag", "nameAr": "سوهاج", "nameEn": "Sohag", "region": "upper", "latitude": 26.5516, "longitude": 31.6961, "routeIds": ["cairo_aswan"] },
  { "id": "menshaw", "nameAr": "المنشأة", "nameEn": "Menshaw", "region": "upper", "latitude": 26.4714, "longitude": 31.8025, "routeIds": ["cairo_aswan"] },
  { "id": "girga", "nameAr": "جرجا", "nameEn": "Girga", "region": "upper", "latitude": 26.3387, "longitude": 31.8907, "routeIds": ["cairo_aswan"] },
  { "id": "baliana", "nameAr": "البلينا", "nameEn": "Baliana", "region": "upper", "latitude": 26.2307, "longitude": 31.9996, "routeIds": ["cairo_aswan"] },
  { "id": "abu_tesht", "nameAr": "أبو تشت", "nameEn": "Abu Tesht", "region": "upper", "latitude": 26.1189, "longitude": 32.0963, "routeIds": ["cairo_aswan"] },
  { "id": "farshout", "nameAr": "فرشوط", "nameEn": "Farshout", "region": "upper", "latitude": 26.0594, "longitude": 32.1472, "routeIds": ["cairo_aswan"] },
  { "id": "naga_hammadi", "nameAr": "نجع حمادي", "nameEn": "Naga Hammadi", "region": "upper", "latitude": 26.0487, "longitude": 32.2415, "routeIds": ["cairo_aswan"] },
  { "id": "deshna", "nameAr": "دشنا", "nameEn": "Deshna", "region": "upper", "latitude": 26.1235, "longitude": 32.4764, "routeIds": ["cairo_aswan"] },
  { "id": "qena", "nameAr": "قنا", "nameEn": "Qena", "region": "upper", "latitude": 26.1668, "longitude": 32.7237, "routeIds": ["cairo_aswan"] },
  { "id": "qus", "nameAr": "قوص", "nameEn": "Qus", "region": "upper", "latitude": 25.9142, "longitude": 32.7634, "routeIds": ["cairo_aswan"] },
  { "id": "luxor", "nameAr": "الأقصر", "nameEn": "Luxor", "region": "upper", "latitude": 25.6980, "longitude": 32.6450, "routeIds": ["cairo_aswan"] },
  { "id": "esna", "nameAr": "إسنا", "nameEn": "Esna", "region": "upper", "latitude": 25.2934, "longitude": 32.5552, "routeIds": ["cairo_aswan"] },
  { "id": "edfu", "nameAr": "إدفو", "nameEn": "Edfu", "region": "upper", "latitude": 24.9782, "longitude": 32.8747, "routeIds": ["cairo_aswan"] },
  { "id": "kalabsha", "nameAr": "كلابشة", "nameEn": "Kalabsha", "region": "upper", "latitude": 24.6062, "longitude": 32.9351, "routeIds": ["cairo_aswan"] },
  { "id": "kom_ombo", "nameAr": "كوم أمبو", "nameEn": "Kom Ombo", "region": "upper", "latitude": 24.4727, "longitude": 32.9463, "routeIds": ["cairo_aswan"] },
  { "id": "daraw", "nameAr": "دراو", "nameEn": "Daraw", "region": "upper", "latitude": 24.4071, "longitude": 32.9312, "routeIds": ["cairo_aswan"] },
  { "id": "aswan", "nameAr": "أسوان", "nameEn": "Aswan", "region": "upper", "latitude": 24.0924, "longitude": 32.9009, "routeIds": ["cairo_aswan"] },

  { "id": "shebin_el_qanater", "nameAr": "شبين القناطر", "nameEn": "Shebin El Qanater", "region": "delta", "latitude": 30.3125, "longitude": 31.3326, "routeIds": ["delta"] },
  { "id": "minya_el_qamh", "nameAr": "منيا القمح", "nameEn": "Minya El Qamh", "region": "delta", "latitude": 30.5135, "longitude": 31.3533, "routeIds": ["delta"] },
  { "id": "zagazig", "nameAr": "الزقازيق", "nameEn": "Zagazig", "region": "delta", "latitude": 30.5898, "longitude": 31.5039, "routeIds": ["delta", "canal"] },
  { "id": "hehia", "nameAr": "ههيا", "nameEn": "Hehia", "region": "delta", "latitude": 30.6698, "longitude": 31.5901, "routeIds": ["delta"] },
  { "id": "abu_kabeer", "nameAr": "أبو كبير", "nameEn": "Abu Kabeer", "region": "delta", "latitude": 30.7303, "longitude": 31.6705, "routeIds": ["delta"] },
  { "id": "faqous", "nameAr": "فاقوس", "nameEn": "Faqous", "region": "delta", "latitude": 30.7337, "longitude": 31.8016, "routeIds": ["delta"] },
  
  { "id": "abu_hammad", "nameAr": "أبو حماد", "nameEn": "Abu Hammad", "region": "canal", "latitude": 30.5367, "longitude": 31.6669, "routeIds": ["canal"] },
  { "id": "ismailia", "nameAr": "الإسماعيلية", "nameEn": "Ismailia", "region": "canal", "latitude": 30.5972, "longitude": 32.2707, "routeIds": ["canal"] },
  { "id": "qantara_west", "nameAr": "القنطرة غرب", "nameEn": "Qantara West", "region": "canal", "latitude": 30.8541, "longitude": 32.3142, "routeIds": ["canal"] },
  { "id": "port_said", "nameAr": "بورسعيد", "nameEn": "Port Said", "region": "canal", "latitude": 31.2589, "longitude": 32.3023, "routeIds": ["canal"] },
  { "id": "suez", "nameAr": "السويس", "nameEn": "Suez", "region": "canal", "latitude": 29.9723, "longitude": 32.5350, "routeIds": ["canal"] },

  { "id": "shibin_el_kom", "nameAr": "شبين الكوم", "nameEn": "Shibin El Kom", "region": "delta", "latitude": 30.5529, "longitude": 31.0090, "routeIds": ["delta"] },
  { "id": "menouf", "nameAr": "منوف", "nameEn": "Menouf", "region": "delta", "latitude": 30.4660, "longitude": 30.9329, "routeIds": ["delta"] },
  { "id": "ashmoun", "nameAr": "أشمون", "nameEn": "Ashmoun", "region": "delta", "latitude": 30.3015, "longitude": 30.9788, "routeIds": ["delta"] },
  
  { "id": "mit_ghamr", "nameAr": "ميت غمر", "nameEn": "Mit Ghamr", "region": "delta", "latitude": 30.7183, "longitude": 31.2562, "routeIds": ["delta"] },
  { "id": "zifta", "nameAr": "زفتى", "nameEn": "Zifta", "region": "delta", "latitude": 30.7135, "longitude": 31.2427, "routeIds": ["delta"] },
  { "id": "samanoud", "nameAr": "سمنود", "nameEn": "Samanoud", "region": "delta", "latitude": 30.9575, "longitude": 31.2435, "routeIds": ["delta"] },
  { "id": "mahalla_el_kubra", "nameAr": "المحلة الكبرى", "nameEn": "Mahalla El Kubra", "region": "delta", "latitude": 30.9734, "longitude": 31.1623, "routeIds": ["delta"] },
  { "id": "talkha", "nameAr": "طلخا", "nameEn": "Talkha", "region": "delta", "latitude": 31.0505, "longitude": 31.3785, "routeIds": ["delta"] },
  { "id": "mansoura", "nameAr": "المنصورة", "nameEn": "Mansoura", "region": "delta", "latitude": 31.0373, "longitude": 31.3852, "routeIds": ["delta"] },
  { "id": "shirbin", "nameAr": "شربين", "nameEn": "Shirbin", "region": "delta", "latitude": 31.1895, "longitude": 31.5284, "routeIds": ["delta"] },
  { "id": "kafr_saad", "nameAr": "كفر سعد", "nameEn": "Kafr Saad", "region": "delta", "latitude": 31.3323, "longitude": 31.6705, "routeIds": ["delta"] },
  { "id": "damietta", "nameAr": "دمياط", "nameEn": "Damietta", "region": "delta", "latitude": 31.4239, "longitude": 31.8123, "routeIds": ["delta"] },
  
  { "id": "kafr_el_sheikh", "nameAr": "كفر الشيخ", "nameEn": "Kafr El Sheikh", "region": "delta", "latitude": 31.1118, "longitude": 30.9419, "routeIds": ["delta"] },
  { "id": "desouk", "nameAr": "دسوق", "nameEn": "Desouk", "region": "delta", "latitude": 31.1350, "longitude": 30.6480, "routeIds": ["delta"] },
  { "id": "qallin", "nameAr": "قلين", "nameEn": "Qallin", "region": "delta", "latitude": 31.0664, "longitude": 30.9324, "routeIds": ["delta"] }
];

// Predefined Simulation Routes with Real Egyptian Waypoints
const SIM_ROUTES = {
  "cairo_alex": {
    nameAr: "القاهرة ➔ الإسكندرية (Misr Express)",
    nameEn: "Cairo ➔ Alexandria (Misr Express)",
    distanceKm: 208,
    typicalSpeedKmH: 120,
    stations: [
      { id: "cairo_ramses", nameAr: "القاهرة (رمسيس)", nameEn: "Cairo (Ramses)", km: 0, lat: 30.0636, lng: 31.2464 },
      { id: "banha", nameAr: "بنها", nameEn: "Banha", km: 45, lat: 30.4632, lng: 31.1818 },
      { id: "tanta", nameAr: "طنطا", nameEn: "Tanta", km: 86, lat: 30.7871, lng: 31.0011 },
      { id: "damanhour", nameAr: "دمنهور", nameEn: "Damanhour", km: 147, lat: 31.0375, lng: 30.4694 },
      { id: "sidi_gaber", nameAr: "سيدي جابر", nameEn: "Sidi Gaber", km: 204, lat: 31.2185, lng: 29.9392 },
      { id: "alexandria_misr", nameAr: "الإسكندرية (محطة مصر)", nameEn: "Alexandria (Misr)", km: 208, lat: 31.1925, lng: 29.9056 }
    ]
  },
  "cairo_assiut": {
    nameAr: "القاهرة ➔ أسيوط (Upper Egypt Line)",
    nameEn: "Cairo ➔ Assiut (Upper Egypt Line)",
    distanceKm: 375,
    typicalSpeedKmH: 105,
    stations: [
      { id: "cairo_ramses", nameAr: "القاهرة (رمسيس)", nameEn: "Cairo", km: 0, lat: 30.0636, lng: 31.2464 },
      { id: "giza", nameAr: "الجيزة", nameEn: "Giza", km: 10, lat: 30.0055, lng: 31.2052 },
      { id: "beni_suef", nameAr: "بني سويف", nameEn: "Beni Suef", km: 124, lat: 29.0734, lng: 31.0978 },
      { id: "minya", nameAr: "المنيا", nameEn: "Minya", km: 247, lat: 28.1130, lng: 30.7495 },
      { id: "mallawi", nameAr: "ملوي", nameEn: "Mallawi", km: 292, lat: 27.7324, lng: 30.8406 },
      { id: "assiut", nameAr: "أسيوط", nameEn: "Assiut", km: 375, lat: 27.1824, lng: 31.1843 }
    ]
  },
  "cairo_giza": {
    nameAr: "القاهرة ➔ الجيزة (Express Rapid Test)",
    nameEn: "Cairo ➔ Giza (Express Rapid Test)",
    distanceKm: 10,
    typicalSpeedKmH: 70,
    stations: [
      { id: "cairo_ramses", nameAr: "القاهرة (رمسيس)", nameEn: "Cairo", km: 0, lat: 30.0636, lng: 31.2464 },
      { id: "giza", nameAr: "الجيزة", nameEn: "Giza", km: 10, lat: 30.0055, lng: 31.2052 }
    ]
  }
};
