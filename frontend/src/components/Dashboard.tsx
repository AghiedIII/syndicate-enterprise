import React, { useState, useEffect } from 'react';
import { translations, LanguageCode } from './translations';

type BranchCode = 'HAS' | 'QAM' | 'DER';
type Role = 'ACCOUNTANT' | 'GLOBAL_ADMIN' | 'IT_OPERATOR';

interface UserSession {
  username: string;
  fullName: string;
  role: Role;
  authorizedBranch: BranchCode | 'GLOBAL';
  currentBranchView: BranchCode;
  cityArabic: string;
}

interface FundMetrics {
  jointCivilArchWaterGeo: number;
  jointElecMech: number;
  auditCivilArch: number;
  auditElecMech: number;
}

interface SimulatedEngineer {
  id: string;
  name: string;
  discipline: 'CIV' | 'ARC' | 'ELE' | 'MCH' | 'WTR' | 'GEO' | 'GTK';
  qualification: 'دراسة' | 'دراسة,تدريب' | 'دراسة,تدريب,تدقيق';
  rank: string;
  fundStatus: 'IN' | 'OU';
  office: BranchCode;
}

const ENGINEERS_REGISTRY: SimulatedEngineer[] = [
  { id: 'ENG-HAS-CIV-0001', name: 'ابراهيم نجيم طاهر', discipline: 'CIV', qualification: 'دراسة,تدريب,تدقيق', rank: 'استشاري', fundStatus: 'OU', office: 'HAS' },
  { id: 'ENG-HAS-CIV-0002', name: 'هيفي عابد احمد', discipline: 'CIV', qualification: 'دراسة,تدريب', rank: 'ممارس', fundStatus: 'IN', office: 'HAS' },
  { id: 'ENG-HAS-CIV-0004', name: 'كاوا احمد صالح', discipline: 'CIV', qualification: 'دراسة', rank: 'متدرب', fundStatus: 'OU', office: 'HAS' },
  { id: 'ENG-QAM-ARC-0001', name: 'زليخان شوكت علي', discipline: 'ARC', qualification: 'دراسة,تدريب,تدقيق', rank: 'استشاري', fundStatus: 'IN', office: 'QAM' },
  { id: 'ENG-QAM-WTR-0001', name: 'آلا محمد بشار حبو', discipline: 'WTR', qualification: 'دراسة,تدريب,تدقيق', rank: 'استشاري', fundStatus: 'IN', office: 'QAM' },
  { id: 'ENG-QAM-ARC-0034', name: 'فيريل يوسف توكمه جي', discipline: 'ARC', qualification: 'دراسة', rank: 'تحت الاشراف', fundStatus: 'IN', office: 'QAM' },
  { id: 'ENG-DER-CIV-0001', name: 'رمضان حسن', discipline: 'CIV', qualification: 'دراسة,تدريب,تدقيق', rank: 'استشاري', fundStatus: 'OU', office: 'DER' },
  { id: 'ENG-DER-ARC-0003', name: 'شيماء ياسر البرهو', discipline: 'ARC', qualification: 'دراسة', rank: 'متدرب', fundStatus: 'IN', office: 'DER' },
  { id: 'ENG-DER-MCH-0001', name: 'أحمد إسماعيل أحمد', discipline: 'MCH', qualification: 'دراسة,تدريب,تدقيق', rank: 'استشاري', fundStatus: 'IN', office: 'DER' }
];

export default function Dashboard({ user, theme, onLogout, lang, setLang }: any) {
  const t = translations[lang];

  const [session, setSession] = useState<UserSession>({
    username: user.id,
    fullName: user.name,
    role: user.role as Role,
    authorizedBranch: user.branch as BranchCode | 'GLOBAL',
    currentBranchView: (user.branch === 'GLOBAL' ? 'QAM' : user.branch) as BranchCode,
    cityArabic: user.city_ar
  });

  const branchThemes = {
    HAS: {
      accent: '#00E676',
      glow: 'rgba(0, 230, 118, 0.25)',
      gradient: 'from-[#00E676] to-[#00B0FF]',
      nameAr: 'الحسكة',
      nameKu: 'Hesekê'
    },
    QAM: {
      accent: '#00E5FF',
      glow: 'rgba(0, 229, 255, 0.25)',
      gradient: 'from-[#00E5FF] to-[#D500F9]',
      nameAr: 'القامشلي',
      nameKu: 'Qamişlo'
    },
    DER: {
      accent: '#D500F9',
      glow: 'rgba(213, 0, 249, 0.25)',
      gradient: 'from-[#D500F9] to-[#FF1744]',
      nameAr: 'ديريك',
      nameKu: 'Dêrik'
    }
  };

  const activeTheme = branchThemes[session.currentBranchView];

  const [metrics] = useState<FundMetrics>({
    jointCivilArchWaterGeo: 4850.50,
    jointElecMech: 1240.00,
    auditCivilArch: 1820.00,
    auditElecMech: 450.00
  });

  const [modelType, setModelType] = useState<'BS' | 'SC'>('SC');
  const [totalArea, setTotalArea] = useState<number>(600);
  const [footprint, setFootprint] = useState<number>(120);
  const [model5Category, setModel5Category] = useState<1 | 2 | 3>(1);
  
  const [assignedArch, setAssignedArch] = useState<string>('ENG-QAM-ARC-0001');
  const [assignedCivil, setAssignedCivil] = useState<string>('ENG-HAS-CIV-0002');
  const [assignedMech, setAssignedMech] = useState<string>('ENG-DER-MCH-0001');
  const [assignedMentor, setAssignedMentor] = useState<string>('ENG-QAM-ARC-0001');

  const [clientInvoice, setClientInvoice] = useState<number>(0);
  const [itemizedPayouts, setItemizedPayouts] = useState<any[]>([]);
  const [syndicateDeposits, setSyndicateDeposits] = useState<number>(0);
  const [discrepancy, setDiscrepancy] = useState<number>(0);

  const [pdfGenerating, setPdfGenerating] = useState<boolean>(false);
  const [pdfMessage, setPdfMessage] = useState<string | null>(null);

  useEffect(() => {
    let clientTotal = 0;
    let tempPayouts: any[] = [];
    let tempDeposits = 0;

    if (modelType === 'SC') {
      const basicFee = totalArea * 2.40;
      const sanitaryFee = footprint <= 250 ? 60.00 : 60.00 + (footprint - 250) * 0.10;
      clientTotal = basicFee + sanitaryFee;

      const roles = [
        { role: t.archSupervisor, code: 'ARC', engId: assignedArch, sharePct: 32 },
        { role: t.civilSupervisor, code: 'CIV', engId: assignedCivil, sharePct: 48 },
        { role: t.mechSupervisor, code: 'MCH', engId: assignedMech, sharePct: 10 }
      ];

      roles.forEach(item => {
        const eng = ENGINEERS_REGISTRY.find(e => e.id === item.engId);
        if (!eng) return;

        const grossShare = (clientTotal * item.sharePct) / 100;
        const unitFee = grossShare * 0.075;
        const fundRate = eng.fundStatus === 'IN' ? 0.25 : 0.10;
        const fundDeduction = (grossShare - unitFee) * fundRate;

        const requiresCoach = eng.qualification === 'دراسة';
        const coachingHold = requiresCoach ? (grossShare - unitFee - fundDeduction) * 0.15 : 0;

        const netPayout = grossShare - unitFee - fundDeduction - coachingHold;

        tempPayouts.push({
          role: item.role,
          name: eng.name,
          discipline: eng.discipline,
          fundStatus: eng.fundStatus,
          isCoached: requiresCoach,
          gross: grossShare,
          net: netPayout,
          deductions: {
            unit: unitFee,
            fund: fundDeduction,
            coach: coachingHold
          }
        });

        tempDeposits += (unitFee + fundDeduction + coachingHold);
      });

    } else {
      let baseStudyFee = 0;
      if (model5Category === 1) {
        baseStudyFee = footprint <= 50 ? 80.00 : 80.00 + (footprint - 50) * 0.10;
      } else if (model5Category === 2) {
        baseStudyFee = 80.00 + (footprint > 50 ? (footprint - 50) * 0.10 : 0);
      } else {
        baseStudyFee = Math.max(100.00, footprint * 0.50);
      }
      
      const printingSurcharge = 10.00;
      clientTotal = baseStudyFee + printingSurcharge;

      const roles = [
        { role: t.archSupervisor, code: 'ARC', engId: assignedArch, sharePct: 60 },
        { role: t.elecSupervisor, code: 'ELE', engId: assignedArch, sharePct: 40 }
      ];

      roles.forEach(item => {
        const eng = ENGINEERS_REGISTRY.find(e => e.id === item.engId);
        if (!eng) return;

        const grossShare = (baseStudyFee * item.sharePct) / 100;
        const unitFee = grossShare * 0.10;
        const fundRate = eng.fundStatus === 'IN' ? 0.25 : 0.10;
        const fundDeduction = (grossShare - unitFee) * fundRate;
        const requiresCoach = eng.qualification === 'دراسة';
        const coachingHold = requiresCoach ? (grossShare - unitFee - fundDeduction) * 0.15 : 0;

        const netPayout = grossShare - unitFee - fundDeduction - coachingHold + (printingSurcharge * (item.sharePct / 100));

        tempPayouts.push({
          role: item.role,
          name: eng.name,
          discipline: eng.discipline,
          fundStatus: eng.fundStatus,
          isCoached: requiresCoach,
          gross: grossShare,
          net: netPayout,
          deductions: {
            unit: unitFee,
            fund: fundDeduction,
            coach: coachingHold
          }
        });

        tempDeposits += (unitFee + fundDeduction + coachingHold);
      });
    }

    setClientInvoice(clientTotal);
    setItemizedPayouts(tempPayouts);
    setSyndicateDeposits(tempDeposits);

    const payoutsSum = tempPayouts.reduce((sum, p) => sum + p.net, 0);
    const calculatedDiscrepancy = clientTotal - (payoutsSum + tempDeposits);
    setDiscrepancy(Math.abs(calculatedDiscrepancy) < 0.0001 ? 0 : Math.abs(calculatedDiscrepancy));

  }, [modelType, totalArea, footprint, model5Category, assignedArch, assignedCivil, assignedMech, lang]);

  const activeBranchLabel = lang === 'AR' 
    ? activeTheme.nameAr 
    : lang === 'KU' 
      ? activeTheme.nameKu 
      : session.currentBranchView;

  const handleSettlePayments = () => {
    setPdfGenerating(true);
    setPdfMessage(lang === 'AR' ? "جاري تجميع السجلات وتوقيعها تشفيرياً بالرقم الموحد المانع للتلاعب..." : "Generating cryptographically sealed invoices...");
    setTimeout(() => {
      setPdfGenerating(false);
      setPdfMessage(
        lang === 'AR' 
          ? `✓ تم ترحيل المعاملة بنجاح للمستودع المركزي! تم إصدار التقارير SC-INV و SC-EPO برقم إيصال مالي فريد وتوقيع SHA-256.` 
          : `✓ Ledger reconciled & archived under Receipt No: REC-QAM-2026-0428. PDFs generated successfully.`
      );
    }, 2000);
  };

  return (
    <div className="min-h-screen bg-[#0B0F19] text-[#E2E8F0] font-sans antialiased flex flex-col selection:bg-cyan-500/30">
      <header className="border-b border-white/10 bg-[#0F1626]/80 backdrop-blur-xl px-8 py-4 sticky top-0 z-50 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div 
            className="w-12 h-12 rounded-full border-2 flex items-center justify-center font-black text-lg transition-all duration-500"
            style={{
              borderColor: activeTheme.accent,
              boxShadow: `0 0 15px ${activeTheme.glow}`
            }}
          >
            {session.currentBranchView[0]}
          </div>
          <div>
            <h1 className="text-lg font-bold tracking-wide">{t.dashboardHeader}</h1>
            <p className="text-xs text-slate-400">
              {lang === 'AR' ? 'نظام الحسابات والتدقيق الموحد للمحافظة' : 'S.E.P.H. Platform Regional Ledger Workspace'}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-4">
          {session.role === 'GLOBAL_ADMIN' && (
            <div className="flex items-center bg-[#151D30] rounded-xl p-1 border border-white/10 gap-1 text-[10px]">
              <span className="font-bold px-2.5 text-amber-500 font-mono">GLOBAL</span>
              <div className="h-4 w-[1px] bg-white/10 mx-1" />
              {(['HAS', 'QAM', 'DER'] as BranchCode[]).map(code => (
                <button
                  key={code}
                  onClick={() => setSession(prev => ({
                    ...prev,
                    currentBranchView: code,
                    cityArabic: code === 'HAS' ? 'الحسكة' : code === 'QAM' ? 'قامشلو' : 'ديريك'
                  }))}
                  className={`px-2.5 py-1.5 rounded-lg font-black uppercase transition-all duration-300 cursor-pointer ${
                    session.currentBranchView === code
                      ? 'bg-white/10 text-white shadow-inner border border-white/10'
                      : 'text-slate-400 hover:text-slate-200'
                  }`}
                  style={session.currentBranchView === code ? { color: branchThemes[code].accent } : {}}
                >
                  {lang === 'AR' ? branchThemes[code].nameAr : lang === 'KU' ? branchThemes[code].nameKu : code}
                </button>
              ))}
            </div>
          )}

          <div className="flex gap-1 bg-[#151D30] p-1 rounded-full border border-white/5">
            {(['AR', 'KU', 'EN'] as LanguageCode[]).map((l) => (
              <button
                key={l}
                onClick={() => setLang(l)}
                className={`px-2.5 py-1 rounded-full text-[10px] font-black transition-all cursor-pointer ${
                  lang === l 
                    ? 'bg-slate-800 text-white border border-white/5' 
                    : 'text-slate-500 hover:text-slate-300'
                }`}
                style={lang === l ? { color: activeTheme.accent } : {}}
              >
                {l}
              </button>
            ))}
          </div>

          <div className="flex items-center gap-3 bg-[#151D30] border border-white/10 rounded-full pl-4 pr-1 py-1">
            <span className="text-xs text-slate-300 text-right">
              <div className="font-bold text-white text-xs">{session.fullName}</div>
              <button 
                onClick={onLogout}
                className="text-[9px] text-rose-400 hover:text-rose-300 transition-colors underline block"
              >
                {t.logoutBtn}
              </button>
            </span>
            <div className="w-8 h-8 rounded-full bg-slate-700 border border-white/20 flex items-center justify-center font-bold text-xs text-slate-200 uppercase">
              {session.role === 'GLOBAL_ADMIN' ? 'A' : 'U'}
            </div>
          </div>
        </div>
      </header>

      <main className="flex-1 p-8 grid grid-cols-1 xl:grid-cols-3 gap-8">
        <div className="xl:col-span-2 flex flex-col gap-8">
          <div 
            className="p-6 rounded-2xl border bg-[#151D30]/30 backdrop-blur-md relative overflow-hidden transition-all duration-500"
            style={{ borderColor: `${activeTheme.accent}20` }}
          >
            <div 
              className="absolute -right-32 -top-32 w-80 h-80 rounded-full filter blur-[100px] opacity-10 transition-all duration-1000"
              style={{ backgroundColor: activeTheme.accent }}
            />
            <div className="flex justify-between items-center relative z-10">
              <div>
                <span 
                  className="text-xs font-bold tracking-wider uppercase px-2.5 py-1 rounded-md bg-white/5 inline-block mb-3"
                  style={{ color: activeTheme.accent }}
                >
                  {lang === 'AR' ? 'لوحة الفرع:' : 'Active Hub:'} {activeBranchLabel}
                </span>
                <h2 className="text-xl font-bold text-white">{t.bentoTitle}</h2>
                <p className="text-xs text-slate-400 mt-1">
                  {t.perfectBalanceBadge} • {t.certifiedBadge}
                </p>
              </div>
              <div className="text-right">
                <div className="text-[10px] text-slate-400 font-bold uppercase">{lang === 'AR' ? 'سعر الصرف المعتمد' : 'Exchange Rate'}</div>
                <div className="text-base font-mono font-black text-white">$1.00 = 15,000 SYP</div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-[#151D30]/60 border border-white/10 p-5 rounded-2xl hover:border-slate-700 transition-all group relative overflow-hidden">
              <div className="flex items-center gap-3 mb-3">
                <div className="w-9 h-9 rounded-lg bg-cyan-500/10 flex items-center justify-center text-cyan-400 font-bold text-sm">1</div>
                <div>
                  <h3 className="text-xs font-bold text-slate-300">{t.jointFundCiv}</h3>
                  <p className="text-[9px] text-slate-500">CIV, ARC, WTR, GEO, GTK</p>
                </div>
              </div>
              <div className="text-2xl font-mono font-black text-white">
                ${metrics.jointCivilArchWaterGeo.toLocaleString('en-US', { minimumFractionDigits: 2 })}
              </div>
            </div>

            <div className="bg-[#151D30]/60 border border-white/10 p-5 rounded-2xl hover:border-slate-700 transition-all group relative overflow-hidden">
              <div className="flex items-center gap-3 mb-3">
                <div className="w-9 h-9 rounded-lg bg-purple-500/10 flex items-center justify-center text-purple-400 font-bold text-sm">2</div>
                <div>
                  <h3 className="text-xs font-bold text-slate-300">{t.jointFundElecMech}</h3>
                  <p className="text-[9px] text-slate-500">ELE, MCH</p>
                </div>
              </div>
              <div className="text-2xl font-mono font-black text-white">
                ${metrics.jointElecMech.toLocaleString('en-US', { minimumFractionDigits: 2 })}
              </div>
            </div>

            <div className="bg-[#151D30]/60 border border-white/10 p-5 rounded-2xl hover:border-slate-700 transition-all group relative overflow-hidden">
              <div className="flex items-center gap-3 mb-3">
                <div className="w-9 h-9 rounded-lg bg-amber-500/10 flex items-center justify-center text-amber-400 font-bold text-sm">3</div>
                <div>
                  <h3 className="text-xs font-bold text-slate-300">{t.auditFundCiv}</h3>
                  <p className="text-[9px] text-slate-500">CIV, ARCH (Model 2, 3)</p>
                </div>
              </div>
              <div className="text-2xl font-mono font-black text-white">
                ${metrics.auditCivilArch.toLocaleString('en-US', { minimumFractionDigits: 2 })}
              </div>
            </div>

            <div className="bg-[#151D30]/60 border border-white/10 p-5 rounded-2xl hover:border-slate-700 transition-all group relative overflow-hidden">
              <div className="flex items-center gap-3 mb-3">
                <div className="w-9 h-9 rounded-lg bg-green-500/10 flex items-center justify-center text-green-400 font-bold text-sm">4</div>
                <div>
                  <h3 className="text-xs font-bold text-slate-300">{t.auditFundElecMech}</h3>
                  <p className="text-[9px] text-slate-500">ELE, MCH (Model 4)</p>
                </div>
              </div>
              <div className="text-2xl font-mono font-black text-white">
                ${metrics.auditElecMech.toLocaleString('en-US', { minimumFractionDigits: 2 })}
              </div>
            </div>
          </div>

          <div className="bg-[#151D30]/40 border border-white/10 rounded-2xl p-6">
            <h3 className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">
              {lang === 'AR' ? 'أحدث المعاملات الصادرة عبر النظام المشترك' : 'Recent Cryptographically Sealed Ledger Records'}
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-slate-300">
                <thead>
                  <tr className="border-b border-white/10 text-slate-500 uppercase tracking-wider text-[10px]">
                    <th className="pb-3 font-bold">ID</th>
                    <th className="pb-3 font-bold">Client / العميل</th>
                    <th className="pb-3 font-bold">City</th>
                    <th className="pb-3 font-bold">Joint Fund Allocation</th>
                    <th className="pb-3 font-bold text-right">Invoice Total</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-white/5 font-mono text-[11px]">
                  <tr>
                    <td className="py-3 text-cyan-400">SC-QAM-2026-0004</td>
                    <td className="py-3 font-sans font-semibold text-white">جميل عبد الصمد</td>
                    <td className="py-3">Qamishli</td>
                    <td className="py-3 text-slate-400">CIV/ARCH Joint ($280.28)</td>
                    <td className="py-3 text-right text-emerald-400 font-bold font-mono">$1,500.00</td>
                  </tr>
                  <tr>
                    <td className="py-3 text-cyan-400">BS-HAS-2026-0012</td>
                    <td className="py-3 font-sans font-semibold text-white">صيدلية الرشيد</td>
                    <td className="py-3">Hasakah</td>
                    <td className="py-3 text-slate-400">CIV/ARCH Joint ($18.50)</td>
                    <td className="py-3 text-right text-emerald-400 font-bold font-mono">$90.00</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div className="bg-[#151D30]/60 border border-white/10 rounded-3xl p-6 flex flex-col gap-5 relative overflow-hidden">
          <div className="border-b border-white/10 pb-3 flex justify-between items-center">
            <h3 className="text-base font-bold text-white">{t.calculatorTitle}</h3>
            <span className="text-[9px] font-mono font-bold bg-[#1E2942] text-cyan-400 px-2 py-0.5 rounded-full border border-white/5 uppercase">
              V2.0
            </span>
          </div>

          <div>
            <label className="text-[10px] text-slate-400 font-bold block mb-1.5 uppercase tracking-wide">
              {t.modelSelectLabel}
            </label>
            <div className="grid grid-cols-2 gap-2 bg-[#0F1626] p-1 rounded-xl border border-white/5 text-xs">
              <button
                onClick={() => setModelType('SC')}
                className={`py-2 rounded-lg font-bold transition-all cursor-pointer ${
                  modelType === 'SC' ? 'bg-slate-800 text-white shadow' : 'text-slate-400 hover:text-slate-200'
                }`}
                style={modelType === 'SC' ? { color: activeTheme.accent } : {}}
              >
                {t.model6Label}
              </button>
              <button
                onClick={() => setModelType('BS')}
                className={`py-2 rounded-lg font-bold transition-all cursor-pointer ${
                  modelType === 'BS' ? 'bg-slate-800 text-white shadow' : 'text-slate-400 hover:text-slate-200'
                }`}
                style={modelType === 'BS' ? { color: activeTheme.accent } : {}}
              >
                {t.model5Label}
              </button>
            </div>
          </div>

          {modelType === 'SC' ? (
            <div className="grid grid-cols-2 gap-4 animate-fade-in">
              <div>
                <label className="text-[10px] text-slate-400 font-bold block mb-1 uppercase tracking-wide">
                  {t.landAreaLabel}
                </label>
                <input
                  type="number"
                  value={totalArea}
                  onChange={e => setTotalArea(Number(e.target.value))}
                  className="w-full bg-[#0F1626] border border-white/10 rounded-xl px-4 py-2 text-sm font-mono focus:border-cyan-500 focus:outline-none"
                />
              </div>
              <div>
                <label className="text-[10px] text-slate-400 font-bold block mb-1 uppercase tracking-wide">
                  {t.footprintAreaLabel}
                </label>
                <input
                  type="number"
                  value={footprint}
                  onChange={e => setFootprint(Number(e.target.value))}
                  className="w-full bg-[#0F1626] border border-white/10 rounded-xl px-4 py-2 text-sm font-mono focus:border-cyan-500 focus:outline-none"
                />
              </div>
            </div>
          ) : (
            <div className="space-y-4 animate-fade-in">
              <div>
                <label className="text-[9px] text-slate-500 font-bold block mb-1.5 uppercase tracking-wider">
                  {lang === 'AR' ? 'نوع المنشأة التجارية والطبية (نموذج 5)' : 'Commercial Property Category'}
                </label>
                <div className="grid grid-cols-3 gap-1 bg-[#0F1626] p-1 rounded-lg border border-white/5 text-[9px] font-bold">
                  <button
                    onClick={() => setModel5Category(1)}
                    className={`py-1.5 rounded-md transition-all cursor-pointer truncate ${
                      model5Category === 1 ? 'bg-slate-800 text-white border border-white/5' : 'text-slate-500 hover:text-slate-300'
                    }`}
                  >
                    {lang === 'AR' ? 'صيدليات وعيادات' : 'Clinics/Pharma'}
                  </button>
                  <button
                    onClick={() => setModel5Category(2)}
                    className={`py-1.5 rounded-md transition-all cursor-pointer truncate ${
                      model5Category === 2 ? 'bg-slate-800 text-white border border-white/5' : 'text-slate-500 hover:text-slate-300'
                    }`}
                  >
                    {lang === 'AR' ? 'مستودعات وتجميل' : 'Warehouses'}
                  </button>
                  <button
                    onClick={() => setModel5Category(3)}
                    className={`py-1.5 rounded-md transition-all cursor-pointer truncate ${
                      model5Category === 3 ? 'bg-slate-800 text-white border border-white/5' : 'text-slate-500 hover:text-slate-300'
                    }`}
                  >
                    {lang === 'AR' ? 'مستشفيات عامة' : 'Hospitals'}
                  </button>
                </div>
              </div>

              <div className="space-y-1">
                <div className="flex justify-between items-center text-[10px]">
                  <span className="text-slate-400 font-semibold">{t.footprintAreaLabel}</span>
                  <span className="font-mono font-bold text-white bg-slate-800 px-2 py-0.5 rounded border border-white/5">{footprint} m²</span>
                </div>
                <input
                  type="range"
                  min="10"
                  max="1000"
                  value={footprint}
                  onChange={e => setFootprint(Number(e.target.value))}
                  className="w-full accent-cyan-400 bg-slate-800 h-1.5 rounded-lg cursor-pointer"
                />
              </div>
            </div>
          )}

          <div className="flex flex-col gap-4">
            <h4 className="text-[10px] text-slate-400 font-bold uppercase tracking-wider">{t.rosterTitle}</h4>

            <div className="p-3.5 rounded-2xl bg-gradient-to-br from-[#101726] to-[#151D30] border border-white/5 flex flex-col gap-3 relative overflow-hidden group hover:border-[#1E2942] transition-all">
              <div className="absolute top-0 right-0 w-16 h-16 bg-cyan-500/5 rounded-full filter blur-xl" />
              <div className="flex justify-between items-center relative z-10">
                <span className="text-[9px] font-extrabold text-cyan-400 uppercase tracking-widest">{t.archSupervisor}</span>
                <span className="text-[10px] font-mono font-bold bg-[#0F1626] border border-white/5 text-slate-400 px-2 py-0.5 rounded-md">
                  SHARE: {modelType === 'SC' ? '32%' : '60%'}
                </span>
              </div>

              <div className="flex items-center gap-3 relative z-10">
                <div className="w-9 h-9 rounded-xl bg-[#0F1626] border border-white/10 flex items-center justify-center font-black text-slate-400 text-xs shadow-inner">
                  ARC
                </div>
                <div className="flex-1">
                  <select
                    value={assignedArch}
                    onChange={e => setAssignedArch(e.target.value)}
                    className="w-full bg-transparent text-xs font-bold text-white border-none p-0 focus:ring-0 focus:outline-none cursor-pointer"
                  >
                    {ENGINEERS_REGISTRY.filter(e => e.discipline === 'ARC').map(e => (
                      <option key={e.id} value={e.id} className="bg-slate-900 text-white">
                        {e.name}
                      </option>
                    ))}
                  </select>
                  <div className="flex gap-1.5 mt-1">
                    <span className="text-[8px] font-black bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-1.5 py-0.5 rounded uppercase">
                      {ENGINEERS_REGISTRY.find(e => e.id === assignedArch)?.fundStatus === 'IN' ? 'INSIDER' : 'OUTSIDER'}
                    </span>
                    <span className="text-[8px] font-black bg-purple-500/10 text-purple-400 border border-purple-500/20 px-1.5 py-0.5 rounded">
                      {ENGINEERS_REGISTRY.find(e => e.id === assignedArch)?.rank}
                    </span>
                  </div>
                </div>
              </div>

              {ENGINEERS_REGISTRY.find(e => e.id === assignedArch)?.qualification === 'دراسة' && (
                <div className="p-2.5 rounded-xl bg-amber-500/5 border border-amber-500/10 text-[9px] text-amber-400 flex flex-col gap-1.5 animate-pulse-slow">
                  <div className="flex items-center gap-1.5 font-bold">
                    <span className="w-1.5 h-1.5 rounded-full bg-amber-500 animate-ping" />
                    {t.traineeWarning}
                  </div>
                  <select
                    value={assignedMentor}
                    onChange={e => setAssignedMentor(e.target.value)}
                    className="w-full bg-[#0F1626] border border-white/5 rounded-lg px-2 py-1 text-[9px] font-bold text-slate-300 focus:outline-none cursor-pointer"
                  >
                    {ENGINEERS_REGISTRY.filter(e => e.discipline === 'ARC' && e.qualification !== 'دراسة').map(e => (
                      <option key={e.id} value={e.id} className="bg-slate-900 text-white">
                        {lang === 'AR' ? 'الموجه: ' : 'Mentor: '} {e.name} ({e.rank})
                      </option>
                    ))}
                  </select>
                </div>
              )}
            </div>

            {modelType === 'SC' && (
              <div className="p-3.5 rounded-2xl bg-gradient-to-br from-[#101726] to-[#151D30] border border-white/5 flex flex-col gap-3 relative overflow-hidden group hover:border-[#1E2942] transition-all animate-fade-in">
                <div className="absolute top-0 right-0 w-16 h-16 bg-emerald-500/5 rounded-full filter blur-xl" />
                <div className="flex justify-between items-center relative z-10">
                  <span className="text-[9px] font-extrabold text-emerald-400 uppercase tracking-widest">{t.civilSupervisor}</span>
                  <span className="text-[10px] font-mono font-bold bg-[#0F1626] border border-white/5 text-slate-400 px-2 py-0.5 rounded-md">
                    SHARE: 48%
                  </span>
                </div>

                <div className="flex items-center gap-3 relative z-10">
                  <div className="w-9 h-9 rounded-xl bg-[#0F1626] border border-white/10 flex items-center justify-center font-black text-slate-400 text-xs shadow-inner">
                    CIV
                  </div>
                  <div className="flex-1">
                    <select
                      value={assignedCivil}
                      onChange={e => setAssignedCivil(e.target.value)}
                      className="w-full bg-transparent text-xs font-bold text-white border-none p-0 focus:ring-0 focus:outline-none cursor-pointer"
                    >
                      {ENGINEERS_REGISTRY.filter(e => e.discipline === 'CIV').map(e => (
                        <option key={e.id} value={e.id} className="bg-slate-900 text-white">
                          {e.name}
                        </option>
                      ))}
                    </select>
                    <div className="flex gap-1.5 mt-1">
                      <span className="text-[8px] font-black bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-1.5 py-0.5 rounded uppercase">
                        {ENGINEERS_REGISTRY.find(e => e.id === assignedCivil)?.fundStatus === 'IN' ? 'INSIDER' : 'OUTSIDER'}
                      </span>
                      <span className="text-[8px] font-black bg-purple-500/10 text-purple-400 border border-purple-500/20 px-1.5 py-0.5 rounded">
                        {ENGINEERS_REGISTRY.find(e => e.id === assignedCivil)?.rank}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {modelType === 'SC' && (
              <div className="p-3.5 rounded-2xl bg-gradient-to-br from-[#101726] to-[#151D30] border border-white/5 flex flex-col gap-3 relative overflow-hidden group hover:border-[#1E2942] transition-all animate-fade-in">
                <div className="absolute top-0 right-0 w-16 h-16 bg-purple-500/5 rounded-full filter blur-xl" />
                <div className="flex justify-between items-center relative z-10">
                  <span className="text-[9px] font-extrabold text-purple-400 uppercase tracking-widest">{t.mechSupervisor}</span>
                  <span className="text-[10px] font-mono font-bold bg-[#0F1626] border border-white/5 text-slate-400 px-2 py-0.5 rounded-md">
                    SHARE: 10%
                  </span>
                </div>

                <div className="flex items-center gap-3 relative z-10">
                  <div className="w-9 h-9 rounded-xl bg-[#0F1626] border border-white/10 flex items-center justify-center font-black text-slate-400 text-xs shadow-inner">
                    MCH
                  </div>
                  <div className="flex-1">
                    <select
                      value={assignedMech}
                      onChange={e => setAssignedMech(e.target.value)}
                      className="w-full bg-transparent text-xs font-bold text-white border-none p-0 focus:ring-0 focus:outline-none cursor-pointer"
                    >
                      {ENGINEERS_REGISTRY.filter(e => e.discipline === 'MCH').map(e => (
                        <option key={e.id} value={e.id} className="bg-slate-900 text-white">
                          {e.name}
                        </option>
                      ))}
                    </select>
                    <div className="flex gap-1.5 mt-1">
                      <span className="text-[8px] font-black bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-1.5 py-0.5 rounded uppercase">
                        {ENGINEERS_REGISTRY.find(e => e.id === assignedMech)?.fundStatus === 'IN' ? 'INSIDER' : 'OUTSIDER'}
                      </span>
                      <span className="text-[8px] font-black bg-purple-500/10 text-purple-400 border border-purple-500/20 px-1.5 py-0.5 rounded">
                        {ENGINEERS_REGISTRY.find(e => e.id === assignedMech)?.rank}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>

          <div className="mt-2 bg-[#0F1626] rounded-2xl p-4 border border-white/5 flex flex-col gap-3">
            <h4 className="text-[9px] font-bold text-slate-400 uppercase tracking-widest">{t.calcResultTitle}</h4>
            
            <div className="flex justify-between items-center border-b border-white/10 pb-2">
              <span className="text-xs text-slate-300 font-bold">{t.clientInvoiceLabel}</span>
              <span className="text-base font-mono font-black text-white text-right" style={{ color: activeTheme.accent }}>
                ${clientInvoice.toFixed(2)}
              </span>
            </div>

            <div className="flex flex-col gap-2 border-b border-white/10 pb-2">
              <span className="text-[9px] text-slate-500 font-bold uppercase">{t.releasedPayoutsLabel}</span>
              {itemizedPayouts.map((item, idx) => (
                <div key={idx} className="flex justify-between items-center text-xs">
                  <span className="text-slate-300 flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full shrink-0" style={{ backgroundColor: activeTheme.accent }} />
                    <span className="truncate max-w-[150px]">{item.name} ({item.discipline})</span>
                  </span>
                  <span className="font-mono text-white text-right">${item.net.toFixed(2)}</span>
                </div>
              ))}
            </div>

            <div className="flex justify-between items-center text-xs">
              <span className="text-slate-300 font-medium">{t.syndicateRetentionLabel}</span>
              <span className="font-mono text-amber-500 font-bold text-right">${syndicateDeposits.toFixed(2)}</span>
            </div>
          </div>

          <div className="mt-2 bg-[#0B0F19] rounded-2xl p-4 border border-white/5 flex flex-col gap-3.5 shadow-inner">
            <div className="flex justify-between items-center text-[9px] font-bold text-slate-500 uppercase tracking-wider">
              <span>{lang === 'AR' ? 'صيغة مطابقة التوازن المزدوج' : 'Double-Entry Formula Check'}</span>
              <span className="font-mono">INV == EPO + FSD</span>
            </div>

            {discrepancy === 0 ? (
              <div className="space-y-2 animate-fade-in">
                <div className="relative w-full h-2 rounded-full bg-slate-800 overflow-hidden border border-[#00F5D4]/10">
                  <div className="absolute inset-y-0 left-0 right-0 bg-gradient-to-r from-[#00F5D4]/20 via-[#00F5D4] to-[#00F5D4]/20 animate-pulse rounded-full shadow-[0_0_15px_3px_#00F5D4]" />
                </div>
                <div className="flex items-center gap-2 text-[10px] text-[#00F5D4] font-black tracking-wide uppercase">
                  <span className="w-1.5 h-1.5 rounded-full bg-[#00F5D4] animate-ping" />
                  {t.perfectBalanceBadge} (0.00 DISCREPANCY)
                </div>
              </div>
            ) : (
              <div className="space-y-2 animate-fade-in">
                <div className="w-full h-2 rounded-full bg-slate-800 border border-rose-500/10">
                  <div className="h-full bg-rose-500 rounded-full w-2/3" />
                </div>
                <div className="flex items-center gap-2 text-[10px] text-rose-500 font-black tracking-wide uppercase">
                  <span className="w-1.5 h-1.5 rounded-full bg-rose-500 animate-ping" />
                  Discrepancy Error: ${discrepancy.toFixed(4)}
                </div>
              </div>
            )}

            <button
              onClick={handleSettlePayments}
              disabled={discrepancy !== 0 || pdfGenerating}
              className={`w-full py-3.5 rounded-xl text-xs font-bold uppercase tracking-wider transition-all duration-300 flex items-center justify-center gap-2 cursor-pointer ${
                discrepancy === 0 && !pdfGenerating
                  ? 'bg-gradient-to-r from-[#00F5D4] to-[#00E5FF] hover:from-[#00F5D4] hover:to-[#00B0FF] text-slate-950 font-extrabold shadow-[0_0_20px_rgba(0,245,212,0.2)]'
                  : 'bg-slate-800 text-slate-500 border border-white/5 opacity-55 cursor-not-allowed'
              }`}
            >
              {pdfGenerating ? (
                <>
                  <svg className="animate-spin h-4 w-4 text-slate-950" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                  </svg>
                  <span>{lang === 'AR' ? 'جاري ترحيل وطباعة السندات...' : 'GENERATING SECURE REPORT...'}</span>
                </>
              ) : (
                <>
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M9 12H4s1 .5 1 1v5s-.5 1-1 1h5m2-7h5s-1 .5-1 1v5s.5 1 1 1h-5M9 4V2H4v2h5zm2 0v2H6V4h5zm1.5 5.5l-3 3 3 3" />
                  </svg>
                  <span>{lang === 'AR' ? 'ترحيل وطباعة عقد الألبيان الموحد' : 'SETTLE & ISSUE REPORT'}</span>
                </>
              )}
            </button>

            {pdfMessage && (
              <div className="p-3 rounded-xl bg-slate-900 border border-white/5 text-[9px] text-slate-300 font-semibold font-mono animate-fade-in break-words">
                {pdfMessage}
              </div>
            )}
          </div>
        </div>
      </main>

      <footer className="bg-[#0A0D15] border-t border-white/10 px-8 py-3.5 flex items-center justify-between mt-auto">
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2">
            {discrepancy === 0 ? (
              <>
                <span className="w-3 h-3 rounded-full bg-emerald-400 animate-pulse" />
                <span className="text-[10px] font-black text-emerald-400 tracking-widest uppercase font-mono">AUDIT STABLE</span>
              </>
            ) : (
              <>
                <span className="w-3 h-3 rounded-full bg-rose-500 animate-pulse" />
                <span className="text-[10px] font-black text-rose-500 tracking-widest uppercase font-mono">DISCREPANCY ALERT</span>
              </>
            )}
          </div>
          <div className="h-4 w-[1px] bg-white/10" />
          <p className="text-xs text-slate-400">
            {discrepancy === 0 ? t.perfectBalanceBadge : `Audit Error: $${discrepancy.toFixed(4)}`}
          </p>
        </div>

        <div className="text-right">
          <span className="text-[9px] text-slate-500 uppercase font-bold tracking-widest font-mono">
            S.E.P.H. Double-Entry Protocol • Active
          </span>
        </div>
      </footer>
    </div>
  );
}
