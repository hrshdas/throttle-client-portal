import React from 'react';
import { User as UserIcon, Mail, Building, Shield, ExternalLink, LogOut, CheckCircle2 } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function Profile({ metaConnection, onOpenMetaModal }) {
  const { user, logout } = useAuth();

  const isConnected = metaConnection && (metaConnection.status === 'CONNECTED' || metaConnection.status === 'SYNCED');

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem', maxWidth: '800px' }}>
      
      {/* Profile Banner */}
      <div className="glass-card" style={{ padding: '2rem', display: 'flex', alignItems: 'center', gap: '1.5rem' }}>
        <div style={{
          width: '72px',
          height: '72px',
          borderRadius: '50%',
          background: 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '1.75rem',
          fontWeight: 800,
          color: '#fff',
          boxShadow: '0 4px 16px rgba(59, 130, 246, 0.3)',
        }}>
          {user?.name ? user.name.slice(0, 2).toUpperCase() : 'CU'}
        </div>
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 700, color: '#0f172a', letterSpacing: '-0.02em' }}>
            {user?.name || 'Client User'}
          </h2>
          <p style={{ fontSize: '0.9rem', color: 'var(--text-secondary)', marginTop: '0.2rem' }}>
            {user?.organization_id ? `Organization ID: ${user.organization_id}` : 'Throttle Client Partner'}
          </p>
        </div>
      </div>

      {/* Info Card */}
      <div className="glass-card" style={{ padding: '1.5rem' }}>
        <h3 style={{ fontSize: '0.9rem', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: '1.25rem' }}>
          Account Details
        </h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <Mail size={18} color="var(--text-muted)" />
            <div>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Email Address</p>
              <p style={{ fontSize: '0.9rem', fontWeight: 500, color: '#0f172a' }}>{user?.email || 'user@client.com'}</p>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <Building size={18} color="var(--text-muted)" />
            <div>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Tenant Isolation</p>
              <p style={{ fontSize: '0.9rem', fontWeight: 500, color: '#0f172a' }}>Multi-Tenant PostgreSQL Scoped</p>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <Shield size={18} color="var(--text-muted)" />
            <div>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Role & Permissions</p>
              <p style={{ fontSize: '0.9rem', fontWeight: 500, color: '#0f172a' }}>{user?.role || 'CLIENT_ADMIN'}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Meta Connection Settings Card */}
      <div className="glass-card" style={{ padding: '1.5rem' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1rem' }}>
          <div>
            <h3 style={{ fontSize: '1rem', fontWeight: 600, color: '#0f172a' }}>Meta Marketing API Integration</h3>
            <p style={{ fontSize: '0.825rem', color: 'var(--text-secondary)', marginTop: '0.15rem' }}>
              Connected account: {metaConnection?.ad_account_name || 'None'}
            </p>
          </div>
          <button className="btn-ghost" onClick={onOpenMetaModal}>
            <span>Manage Connection</span>
            <ExternalLink size={15} />
          </button>
        </div>
      </div>

      {/* Logout Action */}
      <div>
        <button
          onClick={logout}
          className="btn-ghost"
          style={{ color: '#f43f5e', borderColor: 'rgba(244, 63, 94, 0.3)', width: '100%', justifyContent: 'center' }}
        >
          <LogOut size={16} />
          <span>Sign Out of Throttle</span>
        </button>
      </div>

    </div>
  );
}
