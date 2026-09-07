import React, { useState, useEffect } from 'react';
import { translations, LanguageCode } from './translations';

interface LoginPortalProps {
  onLoginSuccess: (session: any) => void;
  lang: LanguageCode;
  setLang: (lang: LanguageCode) => void;
}

export default function LoginPortal({ onLoginSuccess, lang, setLang }: LoginPortalProps) {
  const t = translations[lang];

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [loginSuccess, setLoginSuccess] = useState(false);
  const [triggerSweep, setTriggerSweep] = useState(false);

  const [detectedRole, setDetectedRole] = useState<'accountant' | 'admin' | 'it' | null>(null);
  const [detectedBranch, setDetectedBranch] = useState<'HAS' | 'QAM' | 'DER' | 'GLOBAL' | null>(null);
  const [selectedGlobalBranch, setSelectedGlobalBranch] = useState<'HAS' | 'QAM' | 'DER' | 'ALL'>('ALL');

  useEffect(() => {
    const lowerUser = username.toLowerCase().trim();

    if (!lowerUser) {
      setDetectedRole(null);
      setDetectedBranch(null);
      return;
    }

    if (lowerUser.includes('admin') || lowerUser.includes('director') || lowerUser.includes('مدير')) {
      setDetectedRole('admin');
      setDetectedBranch('GLOBAL');
    } else if (lowerUser.includes('it') || lowerUser.includes('root') || lowerUser.includes('sys') || lowerUser.includes('صيانة')) {
      setDetectedRole('it');
      setDetectedBranch('GLOBAL');
    }
    else if (lowerUser.includes('has') || lowerUser.includes('hasakah') || lowerUser.includes('حسكة')) {
      setDetectedRole('accountant');
      setDetectedBranch('HAS');
    } else if (lowerUser.includes('qam') || lowerUser.includes('qamishli') || lowerUser.includes('قامشلو') || lowerUser.includes('قامشلي')) {
      setDetectedRole('accountant');
      setDetectedBranch('QAM');
    } else if (lowerUser.includes('der') || lowerUser.includes('derik') || lowerUser.includes('ديريك') || lowerUser.includes('مالكية')) {
      setDetectedRole('accountant');
      setDetectedBranch('DER');
    } else {
      setDetectedRole('accountant');
      setDetectedBranch(null);
    }
  }, [username]);

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    if (!username || !password) return;

    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      setLoginSuccess(true);
      
      setTimeout(() => {
        setTriggerSweep(true);
      }, 200);
      
      const resolvedBranch = detectedBranch === 'GLOBAL' ? (selectedGlobalBranch === 'ALL' ? 'QAM' : selectedGlobalBranch) : (detectedBranch || 'QAM');
      const branchLabelAr = resolvedBranch === 'HAS' ? 'الحسكة' : resolvedBranch === 'QAM' ? 'القامشلي' : 'ديريك';
      
      setTimeout(() => {
        onLoginSuccess({
          access_token: "mock-jwt-token-secure-2026",
          user: {
            id: `ENG-${resolvedBranch}-ACC-001`,
            name: username === 'admin' ? "م. جوان عبد الله" : t.genericAccountant,
            role: detectedRole === 'admin' ? "GLOBAL_ADMIN" : "ACCOUNTANT",
            branch: resolvedBranch,
            city_ar: branchLabelAr
          },
          theme: {
            primary_accent: resolvedBranch === 'HAS' ? '#00E676' : resolvedBranch === 'QAM' ? '#00E5FF' : '#D500F9',
            glow_class: resolvedBranch === 'HAS' ? 'shadow-[0_0_40px_rgba(0,230,118,0.15)] border-emerald-500/30' : resolvedBranch === 'QAM' ? 'shadow-[0_0_40px_rgba(0,229,255,0.15)] border-cyan-500/30' : 'shadow-[0_0_40px_rgba(213,0,249,0.15)] border-fuchsia-500/30',
            glow_color: resolvedBranch === 'HAS' ? 'rgba(0, 230, 118, 0.25)' : resolvedBranch === 'QAM' ? 'rgba(0, 229, 255, 0.25)' : 'rgba(213, 0, 249, 0.25)',
            sidebar_logo_url: resolvedBranch === 'HAS' ? '/assets/Logo HAS.jpg' : resolvedBranch === 'QAM' ? '/assets/Logo QAM.jpg' : '/assets/Logo DER.jpg'
          }
        });
      }, 1500);
    }, 1800);
  };

  const getThemeStyles = () => {
    switch (detectedBranch) {
      case 'HAS':
        return {
          glowClass: 'shadow-[0_0_40px_rgba(0,230,118,0.15)] border-emerald-500/30',
          accentText: 'text-emerald-400',
          accentBg: 'bg-emerald-500 hover:bg-emerald-600 focus:ring-emerald-500/50',
          barColor: 'bg-[#00E676]',
          branchLabel: t.hasakahBranch,
          logoText: 'S.E.P.H. HASAKAH',
          glowHex: '#00E676'
        };
      case 'QAM':
        return {
          glowClass: 'shadow-[0_0_40px_rgba(0,229,255,0.15)] border-cyan-500/30',
          accentText: 'text-cyan-400',
          accentBg: 'bg-cyan-500 hover:bg-cyan-600 focus:ring-cyan-500/50',
          barColor: 'bg-[#00E5FF]',
          branchLabel: t.qamishliBranch,
          logoText: 'S.E.P.H. QAMISHLI',
          glowHex: '#00E5FF'
        };
      case 'DER':
        return {
          glowClass: 'shadow-[0_0_40px_rgba(213,0,249,0.15)] border-fuchsia-500/30',
          accentText: 'text-fuchsia-400',
          accentBg: 'bg-fuchsia-500 hover:bg-fuchsia-600 focus:ring-fuchsia-500/50',
          barColor: 'bg-[#D500F9]',
          branchLabel: t.derikBranch,
          logoText: 'S.E.P.H. DERIK',
          glowHex: '#D500F9'
        };
      case 'GLOBAL':
        return {
          glowClass: 'shadow-[0_0_50px_rgba(255,143,0,0.22)] border-amber-500/40 border-dashed animate-pulse-slow',
          accentText: 'text-amber-400',
          accentBg: 'bg-amber-500 hover:bg-amber-600 focus:ring-amber-500/50',
          barColor: 'bg-gradient-to-r from-amber-500 to-orange-500',
          branchLabel: t.globalBranch,
          logoText: 'S.E.P.H. GLOBAL SYSTEM',
          glowHex: '#FF8F00'
        };
      default:
        return {
          glowClass: 'shadow-[0_0_30px_rgba(255,255,255,0.03)] border-white/10',
          accentText: 'text-slate-300',
          accentBg: 'bg-slate-700 hover:bg-slate-600 focus:ring-slate-500/50',
          barColor: 'bg-slate-500',
          branchLabel: t.detectionPlaceholder,
          logoText: 'S.E.P.H. ACCOUNTING',
          glowHex: '#38BDF8'
        };
    }
  };

  const theme = getThemeStyles();

  return (
    <div className="relative min-h-screen w-full flex items-center justify-center bg-[#0B0F19] overflow-hidden text-slate-100 font-sans">
      {triggerSweep && (
        <div className="absolute inset-0 z-50 pointer-events-none flex flex-col justify-between overflow-hidden">
          <div 
            className="w-full h-[3px] bg-gradient-to-r from-transparent via-current to-transparent opacity-100 transition-all duration-[1300ms] ease-out shadow-[0_0_20px_5px_currentColor]"
            style={{ 
              color: theme.glowHex,
              transform: 'translateY(100vh)' 
            }} 
          />
        </div>
      )}

      <div className="absolute inset-0 z-0">
        <div className={`absolute top-1/4 left-1/4 w-[500px] h-[500px] rounded-full filter blur-[150px] opacity-15 transition-all duration-1000 ${
          detectedBranch === 'HAS' ? 'bg-emerald-500' :
          detectedBranch === 'QAM' ? 'bg-cyan-500' :
          detectedBranch === 'DER' ? 'bg-fuchsia-500' :
          detectedBranch === 'GLOBAL' ? 'bg-amber-500' : 'bg-blue-600'
        }`} />
        <div className="absolute bottom-1/4 right-1/4 w-[400px] h-[400px] rounded-full filter blur-[130px] opacity-10 bg-indigo-500" />
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff03_1px,transparent_1px),linear-gradient(to_bottom,#ffffff03_1px,transparent_1px)] bg-[size:40px_40px]" />
      </div>

      <div className="absolute top-6 right-6 z-20 flex gap-1.5 bg-[#151D30]/80 p-1 rounded-xl border border-white/5 backdrop-blur-md">
        {(['AR', 'KU', 'EN'] as LanguageCode[]).map((l) => (
          <button
            key={l}
            onClick={() => setLang(l)}
            className={`px-3 py-1.5 rounded-lg text-xs font-black transition-all cursor-pointer ${
              lang === l 
                ? 'bg-[#1E2942] text-white shadow-[0_0_15px_rgba(255,255,255,0.05)] border border-white/10' 
                : 'text-slate-400 hover:text-slate-200 border border-transparent'
            }`}
            style={lang === l ? { color: theme.glowHex } : {}}
          >
            {l
          }</button>
        ))}
      </div>

      <div className={`relative z-10 w-full max-w-[480px] p-8 mx-4 rounded-3xl bg-[#151D30]/60 backdrop-blur-xl border transition-all duration-700 ${theme.glowClass}`}>
        <div className={`absolute top-0 left-0 right-0 h-1.5 rounded-t-3xl transition-all duration-700 ${theme.barColor}`} />

        <div className="flex flex-col items-center mb-8">
          <div className="relative flex items-center justify-center w-16 h-16 rounded-2xl bg-slate-800/80 border border-slate-700/50 mb-4 transition-transform duration-500 hover:scale-105">
            {detectedBranch === 'GLOBAL' ? (
              <svg className="w-8 h-8 text-amber-400 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M12 11c0 3.517-1.009 6.799-2.753 9.571m-3.44-2.04l.054-.09A13.916 13.916 0 009 11M15 11c0 3.517 1.009 6.799 2.753 9.571m3.44-2.04l-.054-.09A13.916 13.916 0 0015 11M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            ) : (
              <svg className={`w-8 h-8 transition-colors duration-700 ${theme.accentText}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
            )}

            {detectedBranch && (
              <span className="absolute top-1 right-1 flex h-3.5 w-3.5">
                <span className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${theme.barColor}`} />
                <span className={`relative inline-flex rounded-full h-3.5 w-3.5 ${theme.barColor}`} />
              </span>
            )}
          </div>

          <h1 className="text-lg font-bold text-white mb-1 tracking-tight text-center px-4">
            {t.loginTitle}
          </h1>
          <p className="text-[11px] text-slate-400 font-medium tracking-wide uppercase text-center mb-1 font-mono">
            {theme.logoText}
          </p>
          <p className="text-[11px] text-slate-500 text-center px-4">
            {t.loginSubtitle}
          </p>

          <div className="mt-4 px-3 py-1.5 rounded-full bg-slate-800/60 border border-slate-700/50 flex items-center gap-2 max-w-full">
            <span className={`w-1.5 h-1.5 rounded-full shrink-0 ${detectedBranch ? 'bg-emerald-400 animate-pulse' : 'bg-slate-500'}`} />
            <span className="text-[10px] text-slate-300 font-medium truncate">
              {theme.branchLabel}
            </span>
          </div>
        </div>

        {!loginSuccess ? (
          <form onSubmit={handleLogin} className="space-y-4">
            <div className="space-y-1">
              <label className="block text-xs font-semibold text-slate-300">
                {t.usernameLabel}
              </label>
              <div className="relative">
                <span className={`absolute inset-y-0 ${lang === 'AR' ? 'right-0 pr-3.5' : 'left-0 pl-3.5'} flex items-center pointer-events-none text-slate-500`}>
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </span>
                <input
                  type="text"
                  required
                  placeholder="e.g. qam_clerk, has_accountant"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  className={`w-full py-3 bg-[#0B0F19]/60 border border-slate-700/50 rounded-xl text-slate-100 placeholder-slate-600 focus:outline-none focus:border-slate-500 focus:ring-1 focus:ring-slate-500/20 transition-all font-mono text-sm ${lang === 'AR' ? 'pr-11 pl-4 text-right' : 'pl-11 pr-4 text-left'}`}
                />
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex justify-between items-center">
                <label className="block text-xs font-semibold text-slate-300">
                  {t.passwordLabel}
                </label>
              </div>
              <div className="relative">
                <span className={`absolute inset-y-0 ${lang === 'AR' ? 'right-0 pr-3.5' : 'left-0 pl-3.5'} flex items-center pointer-events-none text-slate-500`}>
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                </span>
                <input
                  type={showPassword ? 'text' : 'password'}
                  required
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className={`w-full py-3 bg-[#0B0F19]/60 border border-slate-700/50 rounded-xl text-slate-100 placeholder-slate-700 focus:outline-none focus:border-slate-500 focus:ring-1 focus:ring-slate-500/20 transition-all text-sm ${lang === 'AR' ? 'pr-11 pl-12 text-right' : 'pl-11 pr-12 text-left'}`}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className={`absolute inset-y-0 ${lang === 'AR' ? 'left-0 pl-3.5' : 'right-0 pr-3.5'} flex items-center text-slate-500 hover:text-slate-300 transition-colors text-xs font-semibold`}
                >
                  {showPassword ? t.hidePassword : t.showPassword}
                </button>
              </div>
            </div>

            {detectedBranch === 'GLOBAL' && (
              <div className="p-4 rounded-2xl bg-amber-500/5 border border-amber-500/20 space-y-3 animate-fade-in">
                <div className="flex items-center gap-2 text-amber-400">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                  <span className="text-[9px] font-bold tracking-wider uppercase font-sans">
                    ADMIN MODE DETECTED
                  </span>
                </div>
                
                <div className="space-y-1">
                  <select
                    value={selectedGlobalBranch}
                    onChange={(e) => setSelectedGlobalBranch(e.target.value as any)}
                    className="w-full px-3 py-2 bg-slate-900 border border-slate-700/60 rounded-lg text-xs font-semibold text-slate-100 focus:outline-none focus:border-amber-500/50 cursor-pointer"
                  >
                    <option value="ALL">CONSOLIDATED MULTI-TENANT VIEW</option>
                    <option value="HAS">HASAKAH BRANCH REGISTRY</option>
                    <option value="QAM">QAMISHLI BRANCH REGISTRY</option>
                    <option value="DER">DERIK BRANCH REGISTRY</option>
                  </select>
                </div>
              </div>
            )}

            <button
              type="submit"
              disabled={isLoading}
              className={`w-full py-3.5 rounded-xl font-bold text-xs uppercase tracking-wider transition-all duration-300 flex items-center justify-center gap-2 cursor-pointer ${
                isLoading ? 'bg-slate-700 opacity-60 cursor-not-allowed text-slate-400' : `${theme.accentBg} text-slate-950`
              }`}
            >
              {isLoading ? (
                <>
                  <svg className="animate-spin h-4 w-4 text-slate-400" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                  </svg>
                  <span>{t.loginBtnLoading}</span>
                </>
              ) : (
                <>
                  <span>{t.loginBtn}</span>
                  <svg className={`w-4 h-4 transform ${lang === 'AR' ? 'rotate-180' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                  </svg>
                </>
              )}
            </button>
          </form>
        ) : (
          <div className="flex flex-col items-center justify-center py-10 animate-fade-in">
            <div className={`relative flex items-center justify-center w-16 h-16 rounded-full bg-slate-800 border-2 mb-6 transition-all duration-500 ${
              detectedBranch === 'GLOBAL' ? 'border-amber-400' :
              detectedBranch === 'HAS' ? 'border-emerald-400' :
              detectedBranch === 'QAM' ? 'border-cyan-400' : 'border-fuchsia-400'
            }`}>
              <svg className={`w-8 h-8 ${
                detectedBranch === 'GLOBAL' ? 'text-amber-400' :
                detectedBranch === 'HAS' ? 'text-emerald-400' :
                detectedBranch === 'QAM' ? 'text-cyan-400' : 'text-fuchsia-400'
              }`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M5 13l4 4L19 7" />
              </svg>
            </div>

            <h3 className="text-lg font-bold text-white mb-2 text-center">
              ACCESS GRANTED
            </h3>
            <p className="text-[10px] text-slate-400 font-medium text-center tracking-wide font-mono mb-4">
              SECURE SESSION INITIATED SUCCESSFULLY
            </p>
          </div>
        )}
      </div>

      <div className="absolute bottom-4 left-0 right-0 z-10 flex flex-col items-center gap-1 opacity-30">
        <p className="text-[8px] tracking-widest uppercase text-slate-500 font-sans">
          S.E.P.H. Enterprise Ledger Suite | Version 4.0.0
        </p>
      </div>
    </div>
  );
}
