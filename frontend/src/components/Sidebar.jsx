import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { BarChart3, CheckSquare, MessageSquare, User, LogOut, Shield } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function Sidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const navItems = [
    { path: '/', label: 'Analytics & Insights', icon: BarChart3 },
    { path: '/tasks', label: 'Tasks & Approvals', icon: CheckSquare },
    { path: '/chat', label: 'Encrypted Chat', icon: MessageSquare },
    { path: '/profile', label: 'Profile & Settings', icon: User },
  ];

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <aside style={{
      width: '260px',
      height: '100vh',
      position: 'fixed',
      top: 0,
      left: 0,
      background: 'rgba(255, 255, 255, 0.95)',
      backdropFilter: 'blur(20px)',
      borderRight: '1px solid var(--border-glass)',
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'space-between',
      padding: '1.5rem 1rem',
      zIndex: 40,
    }}>
      <div>
        {/* Brand Header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '0 0.5rem 1.5rem 0.5rem' }}>
          <div style={{
            width: '40px',
            height: '40px',
            borderRadius: '12px',
            background: 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#fff',
            boxShadow: '0 4px 12px rgba(59, 130, 246, 0.3)',
          }}>
            <Shield size={22} />
          </div>
          <div>
            <h1 style={{ fontFamily: 'Outfit, sans-serif', fontSize: '1.25rem', fontWeight: 700, letterSpacing: '-0.02em', color: '#0f172a' }}>
              THROTTLE
            </h1>
            <p style={{ fontSize: '0.725rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
              Client Portal
            </p>
          </div>
        </div>

        {/* Nav Links */}
        <nav style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.path}
                to={item.path}
                style={({ isActive }) => ({
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.875rem',
                  padding: '0.75rem 1rem',
                  borderRadius: 'var(--radius-md)',
                  textDecoration: 'none',
                  fontSize: '0.9rem',
                  fontWeight: isActive ? 600 : 500,
                  color: isActive ? '#2563eb' : 'var(--text-secondary)',
                  background: isActive ? 'linear-gradient(90deg, rgba(37, 99, 235, 0.1) 0%, rgba(37, 99, 235, 0.02) 100%)' : 'transparent',
                  borderLeft: isActive ? '3px solid #2563eb' : '3px solid transparent',
                  transition: 'all 0.2s ease',
                })}
              >
                <Icon size={18} />
                <span>{item.label}</span>
              </NavLink>
            );
          })}
        </nav>
      </div>

      {/* User Footer */}
      <div style={{
        padding: '1rem',
        background: '#ffffff',
        border: '1px solid var(--border-glass)',
        borderRadius: 'var(--radius-md)',
        boxShadow: 'var(--shadow-sm)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
      }}>
        <div style={{ overflow: 'hidden' }}>
          <p style={{ fontSize: '0.875rem', fontWeight: 600, color: '#0f172a', whiteSpace: 'nowrap', textOverflow: 'ellipsis', overflow: 'hidden' }}>
            {user?.name || 'Client User'}
          </p>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', whiteSpace: 'nowrap', textOverflow: 'ellipsis', overflow: 'hidden' }}>
            {user?.email || 'user@client.com'}
          </p>
        </div>
        <button
          onClick={handleLogout}
          title="Log Out"
          style={{
            background: 'none',
            border: 'none',
            color: 'var(--text-muted)',
            cursor: 'pointer',
            padding: '0.35rem',
            borderRadius: '6px',
            display: 'flex',
            alignItems: 'center',
            transition: 'color 0.2s ease',
          }}
          onMouseOver={(e) => e.currentTarget.style.color = '#f43f5e'}
          onMouseOut={(e) => e.currentTarget.style.color = 'var(--text-muted)'}
        >
          <LogOut size={18} />
        </button>
      </div>
    </aside>
  );
}
