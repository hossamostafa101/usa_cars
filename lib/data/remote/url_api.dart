const String BASE_URL = 'https://twseela.com/arabas/api';
const String IMG_URL = 'https://twseela.com/arabas/storage/app/public/';


const String setFcmToken = '$BASE_URL/set_fcm_token';

const String registerApi = '$BASE_URL/register';
const String loginApi    = '$BASE_URL/login';
const String refreshApi  = '$BASE_URL/refresh';
const String logoutApi   = '$BASE_URL/logout';

const String meApi       = '$BASE_URL/me';

/// =====================
/// الكاتيجوريز + الكورسات
/// =====================
const String getCategoriesApi = '$BASE_URL/categories';      // NEW
const String getCoursesApi    = '$BASE_URL/courses';         // NEW

/// كل التصنيفات (مثلاً: Gyn, IVF, Ultrasound ...)
const String categoriesApi = '$BASE_URL/categories';
const String freeVideosApi = '$BASE_URL/free-videos';

/// كل الكورسات (يدعم فلترة: ?category_id=&type=free|paid)
const String coursesApi    = '$BASE_URL/courses';

/// تفاصيل كورس واحد (نبنيها بالدالة)
String courseDetailsApi(int courseId) => '$BASE_URL/courses/$courseId';

/// outline كامل للكورس (الوحدات + عناصر كل وحدة)
String courseOutlineApi(int courseId) =>
    '$BASE_URL/courses/$courseId/outline';

/// الوحدة وتفاصيل محتواها (فيديوهات / PDF / امتحانات)
String unitContentApi(int unitId) => '$BASE_URL/units/$unitId/content';

/// الكورسات الخاصة باليوزر (اللي مشترك فيها / متاحة له)
const String myCoursesApi = '$BASE_URL/my/courses';

/// الاشتراك في كورس (مثلاً بعد الدفع)
String enrollCourseApi(int courseId) =>
    '$BASE_URL/courses/$courseId/enroll';

String getCourseDetailsApi(int courseId) =>
    '$BASE_URL/courses/$courseId';

String getCourseOutlineApi(int courseId) =>
    '$BASE_URL/courses/$courseId/outline';

String getUnitContentApi(int unitId) =>
    '$BASE_URL/units/$unitId/content';

const String getMyCoursesApi = '$BASE_URL/my/courses';

/// =====================
/// الكتب (مكتبة PDF)
/// =====================

/// كل الكتب المنشورة
const String getBooksApi = '$BASE_URL/books';

/// تفاصيل كتاب واحد
String getBookDetailsApi(int bookId) => '$BASE_URL/books/$bookId';

/// كتب المستخدم (لو عندك نظام كتب مدفوعة)
const String getMyBooksApi  = '$BASE_URL/my/books';

/// =====================
/// الامتحانات
/// =====================

/// بدء امتحان: يرجع attempt_id + الأسئلة + الاختيارات
String startExamApi(int examId) =>
    '$BASE_URL/exams/$examId/start';

/// إرسال إجابات الامتحان
String submitExamApi(int examId) =>
    '$BASE_URL/exams/$examId/submit';

/// تفاصيل محاولة معيّنة (history)
String examAttemptApi(int attemptId) =>
    '$BASE_URL/exam-attempts/$attemptId';

/// كل نتائج الامتحانات للمستخدم
const String myExamResultsApi = '$BASE_URL/my/exam-results';

const String redeemCodeApi = '$BASE_URL/activation-codes/redeem';


const String courseSubscriptionsApi = '$BASE_URL/my/course-subscriptions';


// تفاصيل كورس
// String courseDetailsApi(int courseId) => '$BASE_URL/courses/$courseId';
//
// // تفعيل / شراء الكورس (سيموليشن دفع)
// String enrollCourseApi(int courseId) =>
// '$BASE_URL/courses/$courseId/enroll';