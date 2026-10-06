import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import apiClient from './api/apiClient';

import Sidebar from './components/Sidebar';
import Header from './components/Header';
import MetaModal from './components/MetaModal';

import Insights from './pages/Insights';
import Tasks from './pages/Tasks';
import Chat from './pages/Chat';
import Profile from './pages/Profile';
import Login from './pages/Login';
import MetaCallback from './pages/MetaCallback';

function MainLayout() {
  const { user, loading } = useAuth();
  const [metaConnection, setMetaConnection] = useState(null);
  const [isMetaModalOpen, setIsMetaModalOpen] = useState(false);
  const location = useLocation();

  useEffect(() => {
    if (user) {
      fetchMetaConnection();
    }
  }, [user]);

  const fetchMetaConnection = async () => {
    try {
      const data = await apiClient.get('/meta/connection');
      setMetaConnection(data);
      if (data && data.status === 'PENDING_ACCOUNT_SELECTION') {
        setIsMetaModalOpen(true);
      }
    } catch (err) {
      setMetaConnection(null);
    }
  };

  if (loading) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundColor: 'var(--bg-primary)', color: 'var(--text-secondary)' }}>
        Loading Throttle Portal...
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  const pageHeaders = {
    '/': { title: 'Analytics & Insights', subtitle: 'Live Meta Marketing API Data' },
    '/tasks': { title: 'Tasks & Approvals', subtitle: 'Client-agency task review engine' },
    '/chat': { title: 'Encrypted Chat', subtitle: '1-on-1 direct Fernet AES encrypted channel' },
    '/profile': { title: 'Profile & Settings', subtitle: 'Account details and integration preferences' },
  };

  const headerInfo = pageHeaders[location.pathname] || { title: 'Throttle', subtitle: '' };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: 'var(--bg-primary)' }}>
      <Sidebar />
      <div style={{ marginLeft: '260px', flex: 1, padding: '2rem 2.5rem', maxWidth: '1400px' }}>
        <Header
          title={headerInfo.title}
          subtitle={headerInfo.subtitle}
          metaConnection={metaConnection}
          onOpenMetaModal={() => setIsMetaModalOpen(true)}
        />
        <Routes>
          <Route path="/" element={<Insights metaConnection={metaConnection} onOpenMetaModal={() => setIsMetaModalOpen(true)} onRefreshConnection={fetchMetaConnection} />} />
          <Route path="/tasks" element={<Tasks />} />
          <Route path="/chat" element={<Chat />} />
          <Route path="/profile" element={<Profile metaConnection={metaConnection} onOpenMetaModal={() => setIsMetaModalOpen(true)} />} />
        </Routes>
      </div>

      <MetaModal
        isOpen={isMetaModalOpen}
        onClose={() => setIsMetaModalOpen(false)}
        metaConnection={metaConnection}
        onRefresh={fetchMetaConnection}
      />
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/meta-connected" element={<MetaCallback />} />
          <Route path="/*" element={<MainLayout />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
