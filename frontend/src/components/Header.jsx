import React from 'react';
import { ShieldAlert, CheckCircle2, ChevronDown } from 'lucide-react';

export default function Header({ title, subtitle, metaConnection, onOpenMetaModal }) {
  const isConnected = metaConnection && (metaConnection.status === 'CONNECTED' || metaConnection.status === 'SYNCED');
  const isPending = metaConnection && metaConnection.status === 'PENDING_ACCOUNT_SELECTION';

  let statusText = 'Disconnected';
  let statusColor = '#f59e0b';
  let statusBg = 'rgba(245, 158, 11, 0.12)';
  let statusBorder = 'rgba(245, 158, 11, 0.3)';

  if (isConnected) {
    statusText = metaConnection.ad_account_name || 'Meta Connected';
    statusColor = '#10b981';
    statusBg = 'rgba(16, 185, 129, 0.12)';
    statusBorder = 'rgba(16, 185, 129, 0.3)';
  } else if (isPending) {
    statusText = 'Select Ad Account';
    statusColor = '#3b82f6';
    statusBg = 'rgba(59, 130, 246, 0.12)';
    statusBorder = 'rgba(59, 130, 246, 0.3)';
  }

  return (
    <header style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      paddingBottom: '1.5rem',
      marginBottom: '1.5rem',
      borderBottom: '1px solid var(--border-glass)',
    }}>
      <div>
        <h1 style={{ fontSize: '1.75rem', fontWeight: 700, letterSpacing: '-0.02em', color: '#0f172a' }}>
          {title}
        </h1>
        {subtitle && (
          <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginTop: '0.25rem' }}>
            {subtitle}
          </p>
        )}
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
        {/* Meta Connection Status Pill */}
        <button
          onClick={onOpenMetaModal}
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '0.5rem',
            padding: '0.4rem 0.85rem',
            borderRadius: '9999px',
            background: statusBg,
            border: `1px solid ${statusBorder}`,
            color: statusColor,
            fontWeight: 600,
            fontSize: '0.8rem',
            cursor: 'pointer',
            transition: 'all 0.2s ease',
          }}
        >
          <span style={{
            width: '7px',
            height: '7px',
            borderRadius: '50%',
            backgroundColor: statusColor,
            boxShadow: `0 0 8px ${statusColor}`,
          }} />
          <span>{statusText}</span>
          <ChevronDown size={14} />
        </button>
      </div>
    </header>
  );
}
