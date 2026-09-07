// =========================================================================
// TRILINGUAL TRANSLATION DICTIONARY: translations.ts
// LANGUAGES SUPPORTED: Arabic (AR), Kurmanji (KU), English (EN)
// DESCRIPTION: Clean, key-based translations for the entire Syndicate Accounting Portal.
// =========================================================================

export type LanguageCode = 'AR' | 'KU' | 'EN';

export interface TranslationSet {
  // Login Portal
  loginTitle: string;
  loginSubtitle: string;
  usernameLabel: string;
  passwordLabel: string;
  showPassword: string;
  hidePassword: string;
  loginBtn: string;
  loginBtnLoading: string;
  detectionTitle: string;
  detectionPlaceholder: string;
  hasakahBranch: string;
  qamishliBranch: string;
  derikBranch: string;
  globalBranch: string;
  genericAccountant: string;

  // Dashboard Common
  dashboardHeader: string;
  logoutBtn: string;
  bentoTitle: string;
  currencyLabel: string;
  certifiedBadge: string;
  perfectBalanceBadge: string;

  // Bento Metrics
  jointFundCiv: string;
  jointFundElecMech: string;
  auditFundCiv: string;
  auditFundElecMech: string;

  // Calculator
  calculatorTitle: string;
  modelSelectLabel: string;
  model5Label: string;
  model6Label: string;
  landAreaLabel: string;
  footprintAreaLabel: string;
  calcResultTitle: string;
  clientInvoiceLabel: string;
  syndicateRetentionLabel: string;
  releasedPayoutsLabel: string;

  // Roster / Committee
  rosterTitle: string;
  civilSupervisor: string;
  archSupervisor: string;
  elecSupervisor: string;
  mechSupervisor: string;
  practionerLabel: string;
  traineeLabel: string;
  traineeWarning: string;
  selectSupervisor: string;
}

export const translations: Record<LanguageCode, TranslationSet> = {
  AR: {
    loginTitle: "نظام النقابة الهندسي الموحد (S.E.P.H.)",
    loginSubtitle: "أدخل بيانات الاعتماد للوصول الفوري الآمن للمحاسبة",
    usernameLabel: "اسم المستخدم",
    passwordLabel: "كلمة المرور",
    showPassword: "إظهار",
    hidePassword: "إخفاء",
    loginBtn: "تسجيل الدخول الآمن",
    loginBtnLoading: "جاري التحقق من أمان الجلسة التشفيرية...",
    detectionTitle: "نظام عزل الفروع التلقائي (Zero-Trust Tenancy)",
    detectionPlaceholder: "الرجاء إدخال اسم المستخدم للتوجيه الآمن للفرع",
    hasakahBranch: "فرع الحسكة (HAS) - إضاءة الزمرد الأخضر نشطة",
    qamishliBranch: "فرع القامشلي (QAM) - إضاءة الأزرق السماوي نشطة",
    derikBranch: "فرع ديريك (DER) - إضاءة البنفسج النيوني نشطة",
    globalBranch: "الإدارة العامة والشبكات (GLOBAL) - إضاءة الذهب الكوني نشطة",
    genericAccountant: "محاسب معتمد - جاري مسح النطاق الأمن...",

    dashboardHeader: "لوحة التحكم Command Center الموحدة - نقابة المهنسين",
    logoutBtn: "تسجيل الخروج الآمن",
    bentoTitle: "مركز التحكم المالي والتحليل الرقمي التلقائي",
    currencyLabel: "دولار أمريكي (USD)",
    certifiedBadge: "معتمد ومطابق",
    perfectBalanceBadge: "مطابقة الحسابات 100% متوازنة",

    jointFundCiv: "صندوق التكافل الهندسي (مدني ومعماري)",
    jointFundElecMech: "صندوق التكافل الهندسي (كهرباء وميكانيك)",
    auditFundCiv: "صندوق تدقيق التصاميم (مدني ومعماري)",
    auditFundElecMech: "صندوق تدقيق التصاميم (كهرباء وميكانيك)",

    calculatorTitle: "محاكي المعاملات الرياضي والكي-فاكتور الكوني",
    modelSelectLabel: "نوع النموذج الحسابي المعتمد للرخصة",
    model5Label: "البيان الفني التجاري (نموذج 5)",
    model6Label: "عقد الإشراف الهندسي (نموذج 6)",
    landAreaLabel: "المساحة الإجمالي للأرض (م²)",
    footprintAreaLabel: "مساحة المسقط الأفقي للبناء (م²)",
    calcResultTitle: "ملخص ميزانية الدورة المالية وتسويات الإسكرو الكونية",
    clientInvoiceLabel: "إجمالي فاتورة العميل (تحتجز أمانة)",
    syndicateRetentionLabel: "إجمالي حصص وصناديق النقابة المقتطعة",
    releasedPayoutsLabel: "صافي تعويضات المهندسين المصروفة لشركاء اللجنة",

    rosterTitle: "مصفوفة مطابقة المهندسين والمؤهلات القانونية للجنة",
    civilSupervisor: "المشرف الهندسي المدني",
    archSupervisor: "المشرف الهندسي المعماري",
    elecSupervisor: "المشرف الهندسي الكهربائي",
    mechSupervisor: "المشرف الهندسي الميكانيكي",
    practionerLabel: "مهندس ممارس (كامل الحصة)",
    traineeLabel: "مهندس تحت الإشراف (متدرب / دراسة)",
    traineeWarning: "تنبيه قانوني: يلزم تعيين مشرف موجه للمهندس المتدرب!",
    selectSupervisor: "اختر المهندس المشرف والموجه القانوني"
  },
  KU: {
    loginTitle: "Sîstema Hesabguzariyê ya Hevgirtî (S.E.P.H.)",
    loginSubtitle: "Ji bo têketina ewle agahiyên xwe binivîsin",
    usernameLabel: "Navê Bikarhêner",
    passwordLabel: "Şîfre",
    showPassword: "Nîşan bide",
    hidePassword: "Veşêre",
    loginBtn: "Têketina Ewle",
    loginBtnLoading: "Kontrola ewlehiya danişînê tê kirin...",
    detectionTitle: "Tespîtkirina Şaxan a Dînamîkî (Zero-Trust)",
    detectionPlaceholder: "Ji bo tespîtkirina şaxê navê bikarhêner binivîsin",
    hasakahBranch: "Şaxa Hesekê (HAS) - Ronahiya Kesk a Zemerûdî çalak e",
    qamishliBranch: "Şaxa Qamişlo (QAM) - Ronahiya Hêşîn a Ezmanî çalak e",
    derikBranch: "Şaxa Dêrikê (DER) - Ronahiya Mor a Neonî çalak e",
    globalBranch: "Rêvebiriya Giştî (GLOBAL) - Ronahiya Zêrîn a Kozmîk çalak e",
    genericAccountant: "Hesabguzarê Pejirandî - Teftîşa ewlehiyê didome...",

    dashboardHeader: "Navenda Kontrola Hevgirtî - Sendîkaya Endezyaran",
    logoutBtn: "Derketina Ewle",
    bentoTitle: "Navenda Kontrola Darayî û Analîza Otomatîk",
    currencyLabel: "Dolarê Amerîkî (USD)",
    certifiedBadge: "Pejirandî û Hevseng",
    perfectBalanceBadge: "Hevsengiya Tevahî ya Hesaban 100% Temam e",

    jointFundCiv: "Sindoqa Hevkariyê (Sîvîl û Mîmarî)",
    jointFundElecMech: "Sindoqa Hevkariyê (Elektrîk û Mîkanîk)",
    auditFundCiv: "Sindoqa Pişkinîna Sêwirana Sîvîl û Mîmarî",
    auditFundElecMech: "Sindoqa Pişkinîna Sêwirana Elektrîk û Mîkanîk",

    calculatorTitle: "Simulatora Matematîkî û K-Factor a Dînamîkî",
    modelSelectLabel: "Modelê Hesabkirina Fînansekirinê Hilbijêre",
    model5Label: "Daxuyaniya Teknîkî ya Bazirganî (Model 5)",
    model6Label: "Hevbesta Çavdêriya Endezyarî (Model 6)",
    landAreaLabel: "Rûbera Erdê ya Giştî (m²)",
    footprintAreaLabel: "Rûbera Avahiyê ya Erdnigarî (m²)",
    calcResultTitle: "Kurteya Budceyê û Beramberkirina Hesaban",
    clientInvoiceLabel: "Fatoraya Giştî ya Xerîdar (Escrow)",
    syndicateRetentionLabel: "Tevahiya Birîna Parên Sendîkayê",
    releasedPayoutsLabel: "Heqdestê Net yê Endezyarên Komîteyê",

    rosterTitle: "Sifreya Hevberkirina Hevrayên Endezyaran û Rêzikên Yasayî",
    civilSupervisor: "Çavdêrê Endezyariya Sîvîl",
    archSupervisor: "Çavdêrê Endezyariya Mîmarî",
    elecSupervisor: "Çavdêrê Endezyariya Elektrîkê",
    mechSupervisor: "Çavdêrê Endezyariya Mîkanîkê",
    practionerLabel: "Endezyarê Mumaris (Parê Temam)",
    traineeLabel: "Endezyarê Bin Çavdêriyê (Metedreb / Dirase)",
    traineeWarning: "Hişyariya Yasayî: Tayînkirina rahêner ji bo endezyarê nû mîsoger e!",
    selectSupervisor: "Endezyarê Rahêner û Rêberê Yasayî Hilbijêre"
  },
  EN: {
    loginTitle: "S.E.P.H. Unified Syndicate Portal",
    loginSubtitle: "Secure Identity Gateway for Automated Engineering Ledgers",
    usernameLabel: "Username",
    passwordLabel: "Password",
    showPassword: "Show",
    hidePassword: "Hide",
    loginBtn: "Establish Secure Session",
    loginBtnLoading: "Encrypting and verifying cryptographic handshake...",
    detectionTitle: "Automatic Tenancy Branch Isolation (Zero-Trust)",
    detectionPlaceholder: "Begin typing username to route session to local branch environment",
    hasakahBranch: "Hasakah Branch (HAS) - Emerald Aurora Accent Active",\
    qamishliBranch: "Qamishli Branch (QAM) - Electric Cyan Accent Active",
    derikBranch: "Derik Branch (DER) - Neon Violet Accent Active",
    globalBranch: "Global Central Command (GLOBAL) - Golden Cosmic Accent Active",
    genericAccountant: "Certified Broker - Real-time network auditing running...",

    dashboardHeader: "S.E.P.H. Unified Enterprise Control Command Center",
    logoutBtn: "Terminate Session",
    bentoTitle: "Bento Analytics command center & automated outcome vaults",
    currencyLabel: "US Dollars (USD)",
    certifiedBadge: "AUDIT CERTIFIED & PASSED",
    perfectBalanceBadge: "100% PERFECT DOUBLE-ENTRY BALANCE",

    jointFundCiv: "Civil & Architectural Joint Mutual Fund",
    jointFundElecMech: "Electro-Mechanical Joint Mutual Fund",
    auditFundCiv: "Civil & Architectural Design Auditing Fund",
    auditFundElecMech: "Electro-Mechanical Design Auditing Fund",

    calculatorTitle: "Interactive Mathematical Simulation & K-Factor Matrix",
    modelSelectLabel: "Active Accounting Model for Licensing Calculations",
    model5Label: "Commercial Facility Technical Brief (Model 5)",
    model6Label: "Supervision Engineering Contract (Model 6)",
    landAreaLabel: "Total Plot / Land Area (m²)",
    footprintAreaLabel: "Building Base / Footprint Area (m²)",
    calcResultTitle: "Escrow Ledger Reconciliation Summary",
    clientInvoiceLabel: "Gross Invoice Billable to Client (Held in Escrow)",
    syndicateRetentionLabel: "Total Syndicate Statutory Deductions & Fund Deposits",
    releasedPayoutsLabel: "Total Net Disbursed Payouts to Committee Specialists",

    rosterTitle: "Supervision Committee & Professional Credentials Validation Matrix",
    civilSupervisor: "Civil Engineering Supervisor",
    archSupervisor: "Architectural Engineering Supervisor",
    elecSupervisor: "Electrical Engineering Supervisor",
    mechSupervisor: "Mechanical Engineering Supervisor",
    practionerLabel: "Practicing Engineer (Full Gross Disbursal)",
    traineeLabel: "Junior Trainee (Requires Mandatory Coach Hold)",
    traineeWarning: "LEGAL ALERT: Junior Trainee assigned. A certified coach is strictly required!",
    selectSupervisor: "Select Supervising Mentor & Legal Coach"
  }
};
