<div dir="rtl" align="right">

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
</div>
<div dir="rtl" align="right">

## ✨ لماذا Block Drop؟

<table>
  <tr>
    <td>🧩 <b>لعب أصيل</b><br/>القطع السبع الكلاسيكية مع تدوير سلس وخاصية الإمساك</td>
    <td>👻 <b>قطعة الشبح</b><br/>معاينة مكان السقوط لاتخاذ قرارات أسرع وأدق</td>
  </tr>
  <tr>
    <td>🎒 <b>توزيع عادل</b><br/>نظام 7-bag يضمن ظهور كل القطع بإنصاف</td>
    <td>⏱️ <b>إحساس احترافي</b><br/>مهلة قفل ذكية وأنيميشن مسح مرضٍ</td>
  </tr>
  <tr>
    <td>📳 <b>تفاعلية كاملة</b><br/>اهتزاز ومؤثرات لكل حركة وقفل ومسح</td>
    <td>🌙 <b>تصميم ليلي</b><br/>واجهة داكنة أنيقة بخط Rubik المميز</td>
  </tr>
</table>

---

## 🚀 ابدأ اللعب

### المتطلبات

- تثبيت [Flutter SDK](https://docs.flutter.dev/get-started/install) إصدار 3.13 أو أحدث

### التثبيت والتشغيل

```bash
# استنساخ المشروع
git clone https://github.com/billelaggab/block-drop.git
cd block-drop

# تثبيت الاعتماديات
flutter pub get

# تشغيل اللعبة
flutter run
```

### التحقق من الجودة

```bash
flutter analyze   # فحص الكود
flutter test      # تشغيل الاختبارات
```

---
</div>

<div dir="rtl" align="right">

## 🎮 كيف تلعب؟

### التحكم

| الحركة | الطريقة |
|:------:|:-------:|
| 👆 نقرة | تدوير القطعة |
| ↔️ سحب أفقي | تحريك يمين ويسار |
| ⬇️ سحب للأسفل | نزول سريع |
| ⚡ سحبة قوية للأسفل | إسقاط فوري |

> الأزرار السفلية تدعم **الضغط المستمر** للتحريك المتكرر.

### القطع

<p>
  <img src="https://img.shields.io/badge/I-22D3EE?style=flat" alt="I" />
  <img src="https://img.shields.io/badge/O-FACC15?style=flat" alt="O" />
  <img src="https://img.shields.io/badge/T-A855F7?style=flat" alt="T" />
  <img src="https://img.shields.io/badge/L-F97316?style=flat" alt="L" />
  <img src="https://img.shields.io/badge/J-3B82F6?style=flat" alt="J" />
  <img src="https://img.shields.io/badge/S-22C55E?style=flat" alt="S" />
  <img src="https://img.shields.io/badge/Z-EF4444?style=flat" alt="Z" />
</p>

### النقاط

| الإنجاز | النقاط |
|:------:|:------:|
| سطر واحد | 100 × المستوى |
| سطرين | 300 × المستوى |
| ثلاثة أسطر | 500 × المستوى |
| 🔥 أربعة أسطر Tetris | 800 × المستوى |
| 🔗 سلسلة الكومبو | مكافأة إضافية |

> كل 10 أسطر ترفع **المستوى** وتزيد **السرعة**.

---
</div>

<div dir="rtl" align="right">

## 🏗️ نظرة للمطورين

```
lib/
├── app.dart                 # الثيم والإعداد العام
├── game/                    # المحرك والمنطق والواجهة
│   ├── block_game.dart      # حلقة اللعبة والرسم (Flame)
│   ├── game_board.dart      # منطق اللوحة النقي
│   ├── game_piece.dart      # القطع والأشكال
│   ├── piece_bag.dart       # التوزيع العادل
│   └── game_screen.dart     # واجهة اللعب
├── screens/                 # الرئيسية والإعدادات
├── services/                # الصوت والنقاط والاهتزاز
└── widgets/                 # معاينة القطع
```

**المعمارية:** منطق اللعب (`GameBoard`) منفصل تماماً عن الرسم (`BlockGame`) — نظيف وقابل للاختبار.

📝 **التقارير الكاملة في مجلد `docs`:**

- `GAME_REPORT.md` — التقرير التقني الشامل
- `DEVELOPMENT_PROPOSALS.md` — مقترحات التطوير وخارطة الطريق

---

## ⚙️ الإعدادات

| الخيار | الوصف |
|:------:|:-----:|
| 🔊 المؤثرات الصوتية | أصوات الحركة واللعب |
| 🎵 الموسيقى | موسيقى خلفية |
| 📳 الاهتزاز | ردود لمسية |
| 👻 قطعة الشبح | إظهار مكان السقوط |

---

## 🤝 المساهمة

نرحب بمساهماتكم! افتح Issue أو أرسل Pull Request على:

🔗 https://github.com/billelaggab/block-drop.git

---

<p align="center">
  <b>صُنع بـ 💜 باستخدام Flutter + Flame</b>
  <br/>
  ⭐ إذا أعجبتك اللعبة، لا تنسَ منحنا نجمة على GitHub
</p>

</div>

