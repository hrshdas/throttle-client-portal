import React, { useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { CheckCircle2, AlertCircle } from 'lucide-react';

export default function MetaCallback() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();

  const status = searchParams.get('status');
  const reason = searchParams.get('reason');

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate('/');
    }, 2500);
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '1.5rem',
      backgroundColor: 'var(--bg-primary)',
    }}>
      <div className="glass-card animate-fade-in" style={{ padding: '2.5rem', textAlign: 'center', maxWidth: '420px' }}>
        {status === 'error' ? (
          <>
            <AlertCircle size={48} color="#f43f5e" style={{ margin: '0 auto 1rem auto' }} />
            <h2 style={{ fontSize: '1.25rem', fontWeight: 700, color: '#0f172a' }}>Authorization Failed</h2>
            <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginTop: '0.5rem' }}>
              {reason === 'user_denied' ? 'Permission request was denied.' : 'State verification failed or missing parameters.'}
            </p>
          </>
        ) : (
          <>
            <CheckCircle2 size={48} color="#10b981" style={{ margin: '0 auto 1rem auto' }} />
            <h2 style={{ fontSize: '1.25rem', fontWeight: 700, color: '#0f172a' }}>Meta Connected Successfully!</h2>
            <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginTop: '0.5rem' }}>
              Redirecting back to your analytics dashboard...
            </p>
          </>
        )}
      </div>
    </div>
  );
}
