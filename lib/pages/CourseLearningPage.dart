// lib/pages/course_learning_page.dart
import 'package:flutter/material.dart';

/// -----------------------------------------------------------
/// CourseLearningPage
/// شاشة متابعة الكورس بعد الاشتراك
/// - وحدات -> دروس
/// - كل نوع درس يفتح صفحة كاملة (فيديو / PDF / MCQ / صح وخطأ / امتحان نهائي)
/// - بيانات Static للعرض فقط، استبدل بالـ API لاحقًا
/// -----------------------------------------------------------

class CourseLearningPage extends StatefulWidget {
  final _EnrolledCourse course;

  const CourseLearningPage({super.key, required this.course});

  /// للاستخدام السريع:
  /// Navigator.push(context,
  ///   MaterialPageRoute(builder: (_) => CourseLearningPage.demo()));
  factory CourseLearningPage.demo() => CourseLearningPage(course: _demoCourse);

  @override
  State<CourseLearningPage> createState() => _CourseLearningPageState();
}

class _CourseLearningPageState extends State<CourseLearningPage> {
  int _expandedIndex = 0; // أول وحدة مفتوحة

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final c = widget.course;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        isDark ? const Color(0xFF050708) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          titleSpacing: 0,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                c.specialty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(.7),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'معلومات الكورس',
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => _showCourseInfo(context, c),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: _CourseHeaderSummary(course: c),
              ),

              // قائمة المحتوى
              Expanded(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(16, 4, 16, 24), // Safe with nav
                  itemCount: c.sections.length + 1, // + الامتحان النهائي
                  itemBuilder: (context, index) {
                    if (index == c.sections.length) {
                      return _FinalExamCard(
                        exam: c.finalExam,
                        onTap: () => _openLessonPage(context, c.finalExam),
                      );
                    }

                    final sec = c.sections[index];
                    final expanded = index == _expandedIndex;

                    return _SectionCard(
                      section: sec,
                      index: index,
                      expanded: expanded,
                      onHeaderTap: () {
                        setState(() {
                          _expandedIndex = expanded ? -1 : index;
                        });
                      },
                      onLessonTap: (lesson) => _openLessonPage(context, lesson),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLessonPage(BuildContext context, _LessonItem lesson) {
    if (lesson.locked) return;

    Widget page;

    switch (lesson.type) {
      case _LessonType.video:
        page = VideoLessonPage(lesson: lesson, course: widget.course);
        break;
      case _LessonType.pdf:
        page = PdfLessonPage(lesson: lesson, course: widget.course);
        break;
      case _LessonType.mcq:
        page = McqLessonPage(lesson: lesson, course: widget.course);
        break;
      case _LessonType.trueFalse:
        page = TrueFalseLessonPage(lesson: lesson, course: widget.course);
        break;
      case _LessonType.exam:
        page = FinalExamPage(lesson: lesson, course: widget.course);
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _showCourseInfo(BuildContext context, _EnrolledCourse c) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.title,
                style:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text('المحاضر: ${c.instructor}',
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                'صالح حتى: ${c.expiry}',
                style: TextStyle(
                    fontSize: 12, color: Colors.red.shade600),
              ),
              const SizedBox(height: 10),
              Text(
                c.description,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================== SUMMARY BAR =====================

class _CourseHeaderSummary extends StatelessWidget {
  final _EnrolledCourse course;
  const _CourseHeaderSummary({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;
    final percent = (course.progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medical_information_rounded, color: p),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متابعة تقدمك في الكورس',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: course.progress,
                    minHeight: 5,
                    backgroundColor:
                    theme.colorScheme.surfaceVariant.withOpacity(.4),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14),
              ),
              Text(
                'ينتهي ${course.shortExpiry}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ===================== SECTIONS & LESSONS =====================

class _SectionCard extends StatelessWidget {
  final _CourseSection section;
  final int index;
  final bool expanded;
  final VoidCallback onHeaderTap;
  final ValueChanged<_LessonItem> onLessonTap;

  const _SectionCard({
    required this.section,
    required this.index,
    required this.expanded,
    required this.onHeaderTap,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onHeaderTap,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: p.withOpacity(.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: p,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${section.items.length} عناصر تعليمية',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) const Divider(height: 1),
          if (expanded)
            Column(
              children: section.items
                  .map(
                    (lesson) => _LessonTile(
                  lesson: lesson,
                  onTap: () => onLessonTap(lesson),
                ),
              )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final _LessonItem lesson;
  final VoidCallback onTap;

  const _LessonTile({required this.lesson, required this.onTap});

  IconData get _icon {
    switch (lesson.type) {
      case _LessonType.video:
        return Icons.play_circle_fill_rounded;
      case _LessonType.pdf:
        return Icons.picture_as_pdf_rounded;
      case _LessonType.mcq:
        return Icons.quiz_rounded;
      case _LessonType.trueFalse:
        return Icons.checklist_rtl_rounded;
      case _LessonType.exam:
        return Icons.workspace_premium_rounded;
    }
  }

  Color _color(BuildContext context) {
    final p = Theme.of(context).colorScheme.primary;
    switch (lesson.type) {
      case _LessonType.video:
        return Colors.redAccent;
      case _LessonType.pdf:
        return Colors.blueAccent;
      case _LessonType.mcq:
        return Colors.deepPurple;
      case _LessonType.trueFalse:
        return Colors.teal;
      case _LessonType.exam:
        return p;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = _color(context);

    return InkWell(
      onTap: lesson.locked ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: c.withOpacity(.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: c, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lesson.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.textTheme.bodySmall?.color
                          ?.withOpacity(.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (lesson.completed)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 18)
            else if (lesson.locked)
              const Icon(Icons.lock_outline_rounded,
                  color: Colors.grey, size: 16)
            else
              Text(
                '${lesson.minutes}د',
                style: const TextStyle(fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}

class _FinalExamCard extends StatelessWidget {
  final _LessonItem exam;
  final VoidCallback onTap;

  const _FinalExamCard({required this.exam, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.withOpacity(.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  exam.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color:
                    theme.textTheme.bodySmall?.color?.withOpacity(.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onTap,
            child: const Text('ابدأ', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

/// ===================== DETAIL PAGES =====================

class VideoLessonPage extends StatelessWidget {
  final _LessonItem lesson;
  final _EnrolledCourse course;

  const VideoLessonPage({super.key, required this.lesson, required this.course});

  @override
  Widget build(BuildContext context) {
    final url = lesson.youtubeUrl ?? 'رابط YouTube سيتم إضافته لاحقًا';
    return _BasicLessonScaffold(
      title: lesson.title,
      subtitle: course.title,
      icon: Icons.play_circle_fill_rounded,
      color: Colors.redAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_outline,
                    size: 56, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'سيتم هنا دمج مشغل YouTube أو Vimeo في النسخة النهائية.\n'
                'رابط الفيديو الحالي (placeholder):\n$url',
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class PdfLessonPage extends StatelessWidget {
  final _LessonItem lesson;
  final _EnrolledCourse course;

  const PdfLessonPage({super.key, required this.lesson, required this.course});

  @override
  Widget build(BuildContext context) {
    return _BasicLessonScaffold(
      title: lesson.title,
      subtitle: course.title,
      icon: Icons.picture_as_pdf_rounded,
      color: Colors.blueAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 4),
          Text(
            'معاينة ملف الـ PDF ستظهر هنا.\n'
                'يمكنك لاحقًا ربط Viewer أو فتح الملف من رابط حقيقي.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 16),
          Placeholder(fallbackHeight: 180),
        ],
      ),
    );
  }
}

class McqLessonPage extends StatelessWidget {
  final _LessonItem lesson;
  final _EnrolledCourse course;

  const McqLessonPage({super.key, required this.lesson, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _BasicLessonScaffold(
      title: lesson.title,
      subtitle: course.title,
      icon: Icons.quiz_rounded,
      color: Colors.deepPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نموذج بسيط لأسئلة MCQ (ثابتة للعرض). لاحقًا ستأتي من الـ API.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          ...List.generate(3, (i) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سؤال ${i + 1}: نص مختصر للسؤال الطبي هنا.',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ...List.generate(4, (j) {
                      return Row(
                        children: [
                          Radio<int>(
                            value: j,
                            groupValue: null,
                            onChanged: (_) {},
                          ),
                          Expanded(
                            child: Text(
                              'اختيار ${j + 1}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              child: const Text('إنهاء الاختبار (ديمو)'),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'في النسخة الفعلية سيتم حساب الدرجة وتخزينها لهذا المستخدم.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class TrueFalseLessonPage extends StatelessWidget {
  final _LessonItem lesson;
  final _EnrolledCourse course;

  const TrueFalseLessonPage(
      {super.key, required this.lesson, required this.course});

  @override
  Widget build(BuildContext context) {
    return _BasicLessonScaffold(
      title: lesson.title,
      subtitle: course.title,
      icon: Icons.checklist_rtl_rounded,
      color: Colors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أسئلة صح / خطأ (ديمو). يمكنك لاحقًا جلبها من لوحة التحكم.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          ...List.generate(4, (i) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'عبارة طبية رقم ${i + 1} هنا.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('صح'),
                    ),
                    const SizedBox(width: 4),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('خطأ'),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              child: const Text('إنهاء التمرين (ديمو)'),
            ),
          ),
        ],
      ),
    );
  }
}

class FinalExamPage extends StatelessWidget {
  final _LessonItem lesson;
  final _EnrolledCourse course;

  const FinalExamPage({super.key, required this.lesson, required this.course});

  @override
  Widget build(BuildContext context) {
    return _BasicLessonScaffold(
      title: lesson.title,
      subtitle: course.title,
      icon: Icons.workspace_premium_rounded,
      color: Colors.amber[800] ?? Colors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'هذا هو الامتحان النهائي للكورس.\n'
                '- سيتم عرض عدد كبير من أسئلة MCQ.\n'
                '- حساب النتيجة.\n'
                '- تحديد النجاح/الرسوب.\n'
                '- تفعيل شهادة وساعات CME.\n\n'
                'هنا ديمو فقط بدون منطق حقيقي.',
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
          SizedBox(height: 16),
          Placeholder(
            fallbackHeight: 160,
          ),
        ],
      ),
    );
  }
}

/// ========= Shared scaffold for detail pages =========

class _BasicLessonScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget child;

  const _BasicLessonScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(.7),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===================== MODELS & DEMO =====================

class _EnrolledCourse {
  final String title;
  final String instructor;
  final String specialty;
  final String description;
  final String expiry;
  final String shortExpiry;
  final double progress;
  final List<_CourseSection> sections;
  final _LessonItem finalExam;

  const _EnrolledCourse({
    required this.title,
    required this.instructor,
    required this.specialty,
    required this.description,
    required this.expiry,
    required this.shortExpiry,
    required this.progress,
    required this.sections,
    required this.finalExam,
  });
}

class _CourseSection {
  final String title;
  final List<_LessonItem> items;
  const _CourseSection({required this.title, required this.items});
}

enum _LessonType { video, pdf, mcq, trueFalse, exam }

class _LessonItem {
  final String title;
  final String subtitle;
  final _LessonType type;
  final int minutes;
  final bool locked;
  final bool completed;
  final String? youtubeUrl;

  const _LessonItem({
    required this.title,
    required this.subtitle,
    required this.type,
    this.minutes = 5,
    this.locked = false,
    this.completed = false,
    this.youtubeUrl,
  });
}

/// ديمو كورس طبي
final _demoCourse = _EnrolledCourse(
  title: 'Basic ECG Interpretation for Residents',
  instructor: 'د. أحمد المصري',
  specialty: 'باطنة قلبية',
  description:
  'برنامج تدريبي للأطباء والممارسين عن قراءة ECG من الأساسيات حتى الحالات الحرجة، '
      'مع اختبارات بعد كل وحدة وامتحان نهائي يمنح شهادة وساعات CME. الاشتراك سنوي.',
  expiry: '31 ديسمبر 2026 (الاشتراك صالح لمدة سنة من تاريخ التفعيل)',
  shortExpiry: '2026-12-31',
  progress: 0.32,
  sections: [
    _CourseSection(
      title: 'الوحدة 1: أساسيات كهربائية القلب',
      items: [
        _LessonItem(
          title: 'مقدمة في ECG ومكونات الجهاز',
          subtitle: 'فيديو تعريفي • سيتم استبدال الرابط بـ YouTube',
          type: _LessonType.video,
          minutes: 8,
          youtubeUrl: 'https://youtu.be/demo_ecg_intro',
        ),
        _LessonItem(
          title: 'PDF: موجات P-QRS-T والقياسات الأساسية',
          subtitle: 'ملخص بصري للطبيب',
          type: _LessonType.pdf,
          minutes: 3,
        ),
        _LessonItem(
          title: 'MCQ: أساسيات ECG',
          subtitle: '10 أسئلة اختيار من متعدد',
          type: _LessonType.mcq,
          minutes: 6,
        ),
        _LessonItem(
          title: 'صح أم خطأ: مفاهيم أساسية',
          subtitle: '5 عبارات سريعة',
          type: _LessonType.trueFalse,
          minutes: 4,
        ),
      ],
    ),
    _CourseSection(
      title: 'الوحدة 2: اضطرابات النظم الشائعة',
      items: [
        _LessonItem(
          title: 'الرجفان الأذيني على ECG',
          subtitle: 'أمثلة عملية سريرية',
          type: _LessonType.video,
          minutes: 10,
          youtubeUrl: 'https://youtu.be/demo_afib',
        ),
        _LessonItem(
          title: 'PDF: جداول اضطرابات النظم',
          subtitle: 'مرجع سريع',
          type: _LessonType.pdf,
          minutes: 4,
        ),
        _LessonItem(
          title: 'MCQ: اضطرابات النظم',
          subtitle: '8 أسئلة',
          type: _LessonType.mcq,
          minutes: 7,
        ),
      ],
    ),
    _CourseSection(
      title: 'الوحدة 3: ECG في الطوارئ',
      items: [
        _LessonItem(
          title: 'STEMI vs NSTEMI',
          subtitle: 'فيديو: كيف لا تفوت الجلطة الحادة',
          type: _LessonType.video,
          minutes: 12,
          youtubeUrl: 'https://youtu.be/demo_stemi',
        ),
        _LessonItem(
          title: 'PDF: خوارزمية ألم الصدر',
          subtitle: 'Flowchart للطوارئ',
          type: _LessonType.pdf,
          minutes: 3,
        ),
        _LessonItem(
          title: 'MCQ: حالات حرجة',
          subtitle: '12 سؤال سيناريو',
          type: _LessonType.mcq,
          minutes: 9,
        ),
        _LessonItem(
          title: 'صح أم خطأ: Red Flags',
          subtitle: 'لا تتجاهل هذه العلامات',
          type: _LessonType.trueFalse,
          minutes: 4,
        ),
      ],
    ),
  ],
  finalExam: _LessonItem(
    title: 'الامتحان النهائي للكورس',
    subtitle:
    '40 سؤال MCQ + سيناريوهات. يعتمد عليه نجاح المتدرب وإصدار الشهادة.',
    type: _LessonType.exam,
    minutes: 25,
  ),
);
