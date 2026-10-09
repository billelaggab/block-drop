<div dir="rtl">

# 🧱 Block Drop

**لعبة ألغاز بأسلوب Tetris — سريعة، ممتعة، وتسبب الإدمان.**

> اسقط القطع • ابنِ الصفوف • امسح الأسطر • حطّم رقمك القياسي

<p>
  <img src="https://img.shields.io/badge/Flutter-3.13-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Flame-1.38-EE5A24?logo=flame&logoColor=white" alt="Flame" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-4CAF50" alt="Platform" />
</p>

🔗 **المستودع:** https://github.com/billelaggab/block-drop.git

---

## ✨ المميزات

🧩 **لعب أصيل** — القطع السبع الكلاسيكية مع تدوير سلس وخاصية الإمساك Hold.

👻 **قطعة الشبح** — معاينة مكان السقوط النهائي لاتخاذ قرارات أسرع وأدق.

🎒 **توزيع عادل** — نظام 7-bag يضمن ظهور كل القطع بإنصاف دون ظلم.

⏱️ **إحساس احترافي** — مهلة قفل ذكية وأنيميشن مسح مرضٍ مع وميض الإسقاط.

📳 **تفاعلية كاملة** — اهتزاز ومؤثرات صوتية لكل حركة وقفل ومسح.

🌙 **تصميم ليلي أنيق** — واجهة داكنة بخط Rubik مع إحصائيات محفوظة.

---

## 🚀 التشغيل

**المتطلب:** تثبيت [Flutter SDK](https://docs.flutter.dev/get-started/install) إصدار 3.13 أو أحدث.

```bash
git clone https://github.com/billelaggab/block-drop.git
cd block-drop
flutter pub get
flutter run
```

للتحقق من الجودة:

```bash
flutter analyze
flutter test
```

---

## 🎮 طريقة اللعب

**التحكم بالإيماءات:**

- 👆 **نقرة** — تدوير القطعة
- ↔️ **سحب أفقي** — تحريك يمين ويسار
- ⬇️ **سحب للأسفل** — نزول سريع
- ⚡ **سحبة قوية للأسفل** — إسقاط فوري Hard Drop

الأزرار السفلية تدعم **الضغط المستمر** للتحريك المتكرر.

**القطع:** سبع قطع كلاسيكية بألوان مميزة — سماوي 🩵 وأصفر 💛 وبنفسجي 💜 وبرتقالي 🟧 وأزرق 💙 وأخضر 💚 وأحمر ❤️.

**النقاط:** سطر واحد 100 نقطة، سطران 300، ثلاثة 500، وأربعة أسطر Tetris تمنح 800 🔥 — كلها مضروبة في المستوى، مع مكافأة إضافية لسلاسل الكومبو 🔗. كل 10 أسطر ترفع المستوى وتزيد السرعة 📈.

---

## 🏗️ للمطورين

```
lib/
├── app.dart              # الثيم والإعداد العام
├── game/                 # المحرك والمنطق والواجهة
├── screens/              # الرئيسية والإعدادات
├── services/             # الصوت والنقاط والاهتزاز
└── widgets/              # معاينة القطع
```

منطق اللعب (`GameBoard`) منفصل تماماً عن الرسم (`BlockGame`) — معمارية نظيفة وقابلة للاختبار 🧪.

📝 **التقارير الكاملة في مجلد `docs`:** التقرير التقني `GAME_REPORT.md` ومقترحات التطوير `DEVELOPMENT_PROPOSALS.md`.

**الإعدادات المتاحة:** المؤثرات الصوتية 🔊 والموسيقى 🎵 والاهتزاز 📳 وقطعة الشبح 👻 — كلها قابلة للتبديل من شاشة الإعدادات.

---

## 🤝 المساهمة

نرحب بمساهماتكم! افتح Issue أو أرسل Pull Request على المستودع:

🔗 https://github.com/billelaggab/block-drop.git

<p align="center">
  <b>صُنع بـ 💜 باستخدام Flutter + Flame</b>
  <br/>
  ⭐ إذا أعجبتك اللعبة، لا تنسَ منحنا نجمة على GitHub
</p>

</div>

