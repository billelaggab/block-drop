# تقرير لعبة Block Drop

> لعبة Tetris كاملة مبنية بـ Flutter + Flame — وضع ليلي داكن، اتجاه عمودي فقط.

## 1. نظرة عامة

| البند | التفاصيل |
|---|---|
| اسم اللعبة | Block Drop |
| النوع | لعبة ألغاز — سقوط القطع (Tetris-like) |
| نقطة الدخول | `lib/main.dart` ← `lib/app.dart` ← `screens/home_screen.dart` |
| الاتجاه | عمودي فقط (`portraitUp`) |
| الثيم | Material 3 داكن، لون أساسي `0xFF7C3AED`، خلفية `0xFF090D18` |
| الخط | Rubik (Regular / SemiBold 600 / Bold 700) |
| الإصدار | `1.0.0+1` |
| حزمة Dart | `sdk: ^3.13.1` |

## 2. التقنيات والاعتماديات

من ملف `pubspec.yaml`:

| الحزمة | الإصدار | الاستخدام |
|---|---|---|
| `flutter` | SDK | إطار الواجهات |
| `flame` | `^1.38.2` | حلقة اللعبة والرسم على Canvas |
| `shared_preferences` | `^2.5.5` | حفظ الإعدادات والنقاط |
| `audioplayers` | `^6.8.1` | المؤثرات الصوتية والموسيقى |
| `cupertino_icons` | `^1.0.8` | أيقونات iOS |
| `flutter_test` / `flutter_lints` | `^6.0.0` | الاختبار والتحليل |

الأصول المعلنة:

```yaml
assets:
  - assets/UI/
fonts:
  - family: Rubik
```

> ملاحظة: مجلد `assets/UI/` فارغ حالياً، ولا يوجد مجلد `assets/audio/`. الرسم كله عبر Canvas.

## 3. هيكل المشروع

```
lib/
├── app.dart                  # إعداد MaterialApp والثيم الداكن
├── main.dart                 # التهيئة + تثبيت الاتجاه + edgeToEdge
├── game/
│   ├── block_game.dart       # FlameGame: الجاذبية + القفل + الرسم
│   ├── game_board.dart       # منطق اللوحة 10×20 (نقي، بدون UI)
│   ├── game_piece.dart       # القطع الـ7 وأشكالها وألوانها
│   ├── piece_bag.dart        # مولّد 7-bag العادل
│   └── game_screen.dart      # واجهة اللعب: HUD + إيماءات + أزرار
├── screens/
│   ├── home_screen.dart      # الرئيسية + الإحصائيات
│   └── settings_screen.dart  # الإعدادات (4 مفاتيح)
├── services/
│   ├── game_settings.dart    # نموذج الإعدادات
│   ├── settings_service.dart # حفظ/تحميل الإعدادات
│   ├── score_service.dart    # النقاط والإحصائيات
│   ├── sound_service.dart    # المؤثرات والموسيقى
│   └── haptic_service.dart   # الاهتزاز
├── widgets/
│   └── piece_preview.dart    # رسم CustomPaint للقطع
test/
├── game_board_test.dart      # 12 اختباراً للوحة
└── piece_bag_test.dart       # اختبار عدالة التوزيع
docs/
└── GAME_REPORT.md            # هذا التقرير
```

## 4. منطق اللعب الأساسي

### 4.1 اللوحة `GameBoard`

- الأبعاد: **العرض 10 × الارتفاع 20**.
- الشبكة: `List<List<PieceType?>>` بحجم 20×10.
- الظهور (Spawn): في الوسط `x = width ~/ 2 - 2, y = -1`، ويُسمح بوجود خلايا فوق السقف (`y < 0`).
- الطابور القادم: 3 قطع (`nextQueueSize = 3`).

### 4.2 الحركة والدوران

| العملية | الدالة | التفاصيل |
|---|---|---|
| يمين / يسار | `moveLeft()` / `moveRight()` | فحص تصادم عبر `_isValid()` |
| نزول ناعم | `stepDown(softDrop: true)` | `+1` نقطة لكل خطوة |
| سقوط فوري | `hardDropDistance()` | `+2 × المسافة` نقطة |
| دوران | `rotate()` | دوران + Wall-Kicks مبسطة |
| إمساك | `hold()` | مرة واحدة لكل قطعة (`canHold`) |
| الشبح | `ghostPiece` | حساب مكان السقوط النهائي |

Wall-Kicks المستخدمة عند فشل الدوران المباشر:

```
(-1, 0), (1, 0), (-2, 0), (2, 0),
(0, -1), (-1, -1), (1, -1)
```

### 4.3 القطع `GamePiece`

- 7 أنواع: `i, o, t, l, j, s, z`.
- القطعة غير قابلة للتغيير (immutable) — أي حركة تنتج نسخة عبر `copyWith`.
- حالات الدوران: `i: 2`, `o: 1`, `t/l/j: 4`, `s/z: 2`.

| النوع | اللون | الكود |
|---|---|---|
| I | سماوي | `0xFF22D3EE` |
| O | أصفر | `0xFFFACC15` |
| T | بنفسجي | `0xFFA855F7` |
| L | برتقالي | `0xFFF97316` |
| J | أزرق | `0xFF3B82F6` |
| S | أخضر | `0xFF22C55E` |
| Z | أحمر | `0xFFEF4444` |

### 4.4 مولّد القطع `PieceBag`

- نظام **7-bag**: كل 7 قطع تحتوي كل الأنواع مرة واحدة ثم خلط عشوائي.
- يمنع التكرار الظالم أو الغياب الطويل لنوع معيّن.

### 4.5 قفل القطعة ومسح الأسطر (مرحلتان)

1. `lockActivePiece()`: يثبّت الخلايا، وإذا أي خلية فوق السقف ← نهاية اللعبة. يجمع الصفوف الممتلئة في `pendingClearRows`.
2. `finishLineClear()` (بعد أنيميشن 0.28 ثانية): يبني شبكة جديدة، يحدّث `lines` و `level = 1 + lines ~/ 10` و `combo++`، يطبّق النقاط، يولّد قطعة جديدة، ويعيد `canHold = true`.

نظام النقاط:

| أسطر | القاعدة × المستوى |
|---|---|
| 1 | `100 × level` |
| 2 | `300 × level` |
| 3 | `500 × level` |
| 4 (Tetris) | `800 × level` |
| كومبو | `+ 50 × (combo - 1) × level` عند `combo > 1` |

### 4.6 السرعة والمستوى

```dart
fallIntervalSeconds = max(80, 800 - (level - 1) * 65) / 1000.0
```

- المستوى 1: 800ms لكل خطوة، ينقص 65ms لكل مستوى حتى حد 80ms.
- المستوى يزيد كل 10 أسطر ممسوحة.

### 4.7 نهاية اللعبة والإيقاف

- النهاية: قفل فوق السقف أو ظهور قطعة في مكان متعارض.
- `canPlay = !isGameOver && !isPaused && !isClearing`.


## 5. محرك اللعبة `BlockGame` (Flame)

| المؤقت | القيمة | الوظيفة |
|---|---|---|
| `_lockDelay` | `0.50s` | مهلة القفل عند ملامسة الأرض |
| `_maxLockResets` | `15` | حد إعادة ضبط المؤقت بالتحريك |
| `_clearDuration` | `0.28s` | مدة أنيميشن مسح الأسطر |
| `_dropFlashDuration` | `0.10s` | وميض الشاشة عند Hard Drop |

سلوك حلقة `update(dt)`:

1. قص `dt` عند `0.1` لتفادي القفزات.
2. إنقاص مؤقت الوميض.
3. إذا `isGameOver` ← إرسال حدث النهاية مرة واحدة ثم توقف.
4. إذا `isPaused` ← توقف.
5. إذا `isClearing` ← تقدّم مؤقت المسح ثم `finishLineClear()` + صوت/اهتزاز + تحديث HUD، **بدون جاذبية أو قفل أثناء المسح**.
6. إذا `isGrounded` ← تقدّم مؤقت القفل ثم قفل.
7. وإلا ← جاذبية حسب `fallIntervalSeconds`.

الأصوات والاهتزاز المرتبطة:

| الحدث | الصوت | الاهتزاز |
|---|---|---|
| Tetris (4 أسطر) | `Sfx.tetris` | `heavy()` |
| مسح عادي | `Sfx.clear` | `strong()` |
| قفل | `Sfx.lock` | `light()` |
| حركة/دوران | `Sfx.move/rotate` | `light()` |
| Hard Drop | `Sfx.drop` | `medium()` |
| Hold | `Sfx.hold` | `medium()` |
| نهاية اللعبة | `Sfx.gameOver` | `heavy()` |

ترتيب الرسم على Canvas:

1. ظل اللوحة + خلفية `0xFF111827` بحواف دائرية 12.
2. الشبكة (خطوط `0xFF243047` بشفافية).
3. البلوكات المثبتة (حواف 4 + لمعة علوية + حد سفلي).
4. الشبح (إذا مفعّل): تعبئة `0.09` وحدود `0.45`.
5. القطعة النشطة.
6. تأثير المسح: وميض أبيض حسب `progress`.
7. وميض السقوط + حد اللوحة الخارجي.

> أثناء `isClearing` لا تُرسم القطعة النشطة ولا الشبح لمنع التداخل البصري.

## 6. واجهة اللعب `GameScreen`

### 6.1 البنية العامة

```
TopBar (SCORE / BEST / LINES / LEVEL + Pause)
PreviewBar (HOLD + NEXT ×3)
Board (Flame GameWidget + Gestures)
GameControls (أزرار سفلية)
Overlays (Pause / GameOver)
```

### 6.2 التحكم بالإيماءات (على اللوحة)

| الإيماءة | الفعل | العتبة |
|---|---|---|
| نقرة `Tap` | تدوير | — |
| سحب أفقي | حركة يمين/يسار | كل `25px` خطوة |
| سحب للأسفل | نزول ناعم | كل `28px` خطوة |
| Flick سريع للأسفل | Hard Drop | سرعة `dy > 1200` وأكبر من الأفقية |

### 6.3 الأزرار السفلية

- أزرار اتجاه + تدوير + سقوط + إمساك.
- زر التكرار: تنفيذ فوري ثم تكرار كل `65ms` بعد تأخير `180ms` مع تصغير مرئي `0.92`.

### 6.4 Overlays ودورة الحياة

- **الإيقاف:** خلفية `0.76` + بطاقة `0xFF111827` + زرّا RESUME / EXIT.
- **النهاية:** النتيجة بخط 36 + `BEST x • LINES y` + زرّا PLAY AGAIN / HOME.
- `WidgetsBindingObserver`: أي حالة `paused/inactive/hidden/detached` ← إيقاف تلقائي.
- `ScoreService.submitGameResult()` تُستدعى مرة واحدة فقط (حماية `_resultSubmitted`).


## 7. الشاشات الأخرى

### 7.1 الرئيسية `HomeScreen`

- تحميل الإعدادات والإحصائيات مع شاشة انتظار.
- اللوجو: مربع متدرج (`0xFF7C3AED → 0xFF22D3EE`) + عنوان `BLOCK DROP` + شعار `FALL • BUILD • CLEAR`.
- بطاقة إحصائيات: `HIGH SCORE / GAMES / LINES`.
- زرّا `PLAY` (مملوء) و `SETTINGS` (محدد).
- تلميح: `Tap to rotate • Swipe to move / Swipe down to drop`.
- بعد العودة من اللعب تُحدَّث الإحصائيات تلقائياً.

### 7.2 الإعدادات `SettingsScreen`

| المفتاح | الوصف | مفتاح التخزين |
|---|---|---|
| Sound Effects | أصوات الحركة واللعب | `settings_sound` |
| Music | الموسيقى الخلفية | `settings_music` |
| Haptic Feedback | الاهتزاز أثناء اللعب | `settings_haptics` |
| Ghost Piece | إظهار مكان السقوط | `settings_ghost` |

- حفظ فوري عند التبديل + حفظ عند الإغلاق وإرجاع النتيجة.
- `PopScope(canPop: false)` لاعتراض زر الرجوع وضمان الحفظ.

## 8. الخدمات

### 8.1 `ScoreService` (SharedPreferences)

| المفتاح | المحتوى |
|---|---|
| `high_score` | أعلى نتيجة |
| `games_played` | عدد الجولات |
| `total_lines` | مجموع الأسطر |

- `submitGameResult(score, lines)`: تزيد المباريات والأسطر دائماً، وتعيد `true` إذا رقم قياسي جديد.

### 8.2 `SoundService` (audioplayers)

- 8 مؤثرات: `move, rotate, drop, lock, clear, tetris, hold, gameOver` من `audio/*.wav`.
- موسيقى `audio/music.mp3` بوضع `loop` وصوت `0.30`.
- 4 مشغلات مؤثرات بالتناوب بوضع `lowLatency`.
- **الحالة الحالية: صامت فعلياً** — يُستدعى `init()` بدون `assetsAvailable: true` ولا توجد ملفات صوتية في المشروع.

### 8.3 `HapticService`

`light()` ← `selectionClick`، `medium()` ← `lightImpact`، `strong()` ← `mediumImpact`، `heavy()` ← `heavyImpact`، مع مفتاح `enabled`.

### 8.4 `PiecePreview`

- `CustomPaint` يرسم الشكل الأول للقطعة مع توسيط تلقائي وحد أقصى `17.0` لحجم الخلية.
- يعرض `—` عند `type == null`.

## 9. الاختبارات

| الملف | التغطية |
|---|---|
| `test/game_board_test.dart` | الأبعاد، النزول، Hard Drop، Hold مرة واحدة، Reset، مسح 1/2/3/4 أسطر، الحفاظ على الصفوف العلوية، المستوى كل 10 أسطر |
| `test/piece_bag_test.dart` | كل 7 قطع متتالية تحتوي كل الأنواع (20 كيساً ببذرة ثابتة) |

```bash
flutter analyze
flutter test
flutter run
```

## 10. نقاط القوة

1. فصل ممتاز: `GameBoard` منطق نقي بدون Flame/Flutter وقابل للاختبار.
2. نظام مسح من مرحلتين مع أنيميشن يمنع أخطاء الفهارس.
3. `7-bag` عادل يمنع الظلم في التوزيع.
4. Lock Delay مع حد `15` يوازن بين المرونة ومنع المماطلة.
5. إيقاف تلقائي عند تصغير التطبيق وحماية من تسجيل النتيجة مرتين.
6. دعم كامل للإيماءات والأزرار مع زر تكرار احترافي.

## 11. الملاحظات وفرص التحسين

| # | الملاحظة | الاقتراح |
|---|---|---|
| 1 | لا توجد ملفات صوتية والصوت معطّل برمجياً | إضافة `assets/audio/` وتمرير `assetsAvailable: true` وإعلانها في `pubspec.yaml` |
| 2 | `assets/UI/` فارغ | إضافة صور/أيقونات أو إزالة الإعلان |
| 3 | `README.md` قالب افتراضي | تحديثه بتعليمات اللعب والتشغيل |
| 4 | Wall-Kicks مبسّط وليس SRS كاملاً | تطبيق جدول SRS الرسمي |
| 5 | لا مشاركة نتيجة أو إنجازات | إضافة مشاركة النتيجة وعداد وقت وإنجازات |

---

*وُلّد هذا التقرير من قراءة الكود المصدري في `lib/` و `test/` و `pubspec.yaml`.*

