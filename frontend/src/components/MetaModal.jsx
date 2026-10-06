import React, { useState, useEffect } from 'react';
import { X, ExternalLink, RefreshCw, Unlink, CheckCircle2, AlertCircle } from 'lucide-react';
import apiClient from '../api/apiClient';

export default function MetaModal({ isOpen, onClose, metaConnection, onRefresh }) {
  const [adAccounts, setAdAccounts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (isOpen) {
      fetchAdAccounts();
    }
  }, [isOpen]);

  const fetchAdAccounts = async () => {
    try {
      const data = await apiClient.get('/meta/ad-accounts');
      setAdAccounts(data || []);
    } catch (err) {
      // Ad accounts fetch might fail if not authenticated yet
    }
  };

  if (!isOpen) return null;

  const handleDemoConnect = async () => {
    setLoading(true);
    setError(null);
    try {
      await apiClient.post('/meta/demo-connect');
      await onRefresh();
      onClose();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleStartConnect = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await apiClient.post('/meta/connect/start');
      if (data.auth_url) {
        window.location.href = data.auth_url;
      }
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const handleSelectAccount = async (adAccountId) => {
    setLoading(true);
    setError(null);
    try {
      await apiClient.post('/meta/select-ad-account', { ad_account_id: adAccountId });
      await onRefresh();
      onClose();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSync = async () => {
    setLoading(true);
    setError(null);
    try {
      await apiClient.post('/meta/sync');
      await onRefresh();
      onClose();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDisconnect = async () => {
    setLoading(true);
    setError(null);
    try {
      await apiClient.post('/meta/disconnect');
      await onRefresh();
      onClose();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const isConnected = metaConnection && (metaConnection.status === 'CONNECTED' || metaConnection.status === 'SYNCED');

  return (
    <div style={{
      position: 'fixed',
      inset: 0,
      backgroundColor: 'rgba(15, 23, 42, 0.4)',
      backdropFilter: 'blur(8px)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 50,
      padding: '1rem',
    }}>
      <div className="glass-card animate-fade-in" style={{
        width: '100%',
        maxWidth: '520px',
        padding: '1.75rem',
        position: 'relative',
        background: '#ffffff',
        border: '1px solid var(--border-glass-bright)',
        boxShadow: 'var(--shadow-lg)',
      }}>
        {/* Close Button */}
        <button
          onClick={onClose}
          style={{
            position: 'absolute',
            top: '1.25rem',
            right: '1.25rem',
            background: 'none',
            border: 'none',
            color: 'var(--text-muted)',
            cursor: 'pointer',
          }}
        >
          <X size={20} />
        </button>

        <h2 style={{ fontSize: '1.25rem', fontWeight: 700, color: '#0f172a', marginBottom: '0.25rem' }}>
          Meta Ads Integration
        </h2>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '1.25rem' }}>
          Manage your Meta Marketing API connection and Ad Account selection.
        </p>

        {error && (
          <div style={{
            padding: '0.75rem 1rem',
            borderRadius: 'var(--radius-md)',
            background: 'rgba(244, 63, 94, 0.1)',
            border: '1px solid rgba(244, 63, 94, 0.3)',
            color: '#f43f5e',
            fontSize: '0.85rem',
            marginBottom: '1rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
          }}>
            <AlertCircle size={16} />
            <span>{error}</span>
          </div>
        )}

        {/* Current Connection Status Info */}
        <div style={{
          padding: '1rem',
          borderRadius: 'var(--radius-md)',
          background: 'var(--bg-secondary)',
          border: '1px solid var(--border-glass)',
          marginBottom: '1.25rem',
        }}>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            Current Status
          </p>
          <p style={{ fontSize: '0.95rem', fontWeight: 600, color: isConnected ? '#10b981' : '#f59e0b', marginTop: '0.25rem' }}>
            {metaConnection?.ad_account_name || metaConnection?.status || 'Disconnected'}
          </p>
          {metaConnection?.ad_account_id && (
            <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '0.2rem' }}>
              Account ID: {metaConnection.ad_account_id}
            </p>
          )}
        </div>

        {/* Available Ad Accounts Selector */}
        {adAccounts.length > 0 && (
          <div style={{ marginBottom: '1.25rem' }}>
            <p style={{ fontSize: '0.85rem', fontWeight: 600, color: '#0f172a', marginBottom: '0.5rem' }}>
              Select Ad Account to Track:
            </p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', maxHeight: '180px', overflowY: 'auto' }}>
              {adAccounts.map((acc) => (
                <div
                  key={acc.id}
                  onClick={() => handleSelectAccount(acc.id)}
                  style={{
                    padding: '0.75rem 1rem',
                    borderRadius: 'var(--radius-md)',
                    background: metaConnection?.ad_account_id === acc.id ? 'rgba(37, 99, 235, 0.08)' : '#ffffff',
                    border: `1px solid ${metaConnection?.ad_account_id === acc.id ? 'var(--accent-blue)' : 'var(--border-glass)'}`,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    transition: 'all 0.2s ease',
                  }}
                >
                  <div>
                    <p style={{ fontSize: '0.875rem', fontWeight: 600, color: '#0f172a' }}>{acc.name || acc.id}</p>
                    <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>ID: {acc.id} • Currency: {acc.currency || 'INR'}</p>
                  </div>
                  {metaConnection?.ad_account_id === acc.id && <CheckCircle2 size={18} color="#2563eb" />}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Action Buttons */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', marginTop: '1rem' }}>
          <button className="btn-meta" onClick={handleStartConnect} disabled={loading} style={{ justifyContent: 'center' }}>
            <ExternalLink size={16} />
            <span>Connect via Meta OAuth</span>
          </button>

          {isConnected && (
            <>
              <button className="btn-ghost" onClick={handleSync} disabled={loading} style={{ justifyContent: 'center' }}>
                <RefreshCw size={16} className={loading ? 'pulse-glow' : ''} />
                <span>Trigger Manual Sync Now</span>
              </button>

              <button
                className="btn-ghost"
                onClick={handleDisconnect}
                disabled={loading}
                style={{ justifyContent: 'center', color: '#f43f5e', borderColor: 'rgba(244, 63, 94, 0.3)' }}
              >
                <Unlink size={16} />
                <span>Disconnect Meta Account</span>
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
