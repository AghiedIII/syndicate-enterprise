import React, { useState } from 'react';
import LoginPortal from './components/LoginPortal';
import Dashboard from './components/Dashboard';
import { LanguageCode } from './components/translations';

interface User {
  id: string;
  name: string;
  role: string;
  branch: string;
  city_ar: string;
}

interface Theme {
  primary_accent: string;
  glow_class: string;
  glow_color: string;
  sidebar_logo_url: string;
}

interface UserSession {
  access_token: string;
  user: User;
  theme: Theme;
}

export default function App() {
  const [session, setSession] = useState<UserSession | null>(null);
  const [lang, setLang] = useState<LanguageCode>('AR');

  const handleLogout = () => {
    setSession(null);
  };

  const handleLoginSuccess = (incomingSession: UserSession) => {
    setSession(incomingSession);
  };

  return (
    <div className="min-h-screen bg-[#0B0F19] font-sans selection:bg-opacity-50 select-none">
      {!session ? (
        <LoginPortal 
          onLoginSuccess={handleLoginSuccess} 
          lang={lang} 
          setLang={setLang}
        />
      ) : (
        <Dashboard 
          user={session.user} 
          theme={session.theme} 
          onLogout={handleLogout} 
          lang={lang}
          setLang={setLang}
        />
      )}
    </div>
  );
}
