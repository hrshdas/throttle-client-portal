import React, { useState, useEffect } from 'react';
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import { TrendingUp, Layers, RefreshCw, AlertCircle, ArrowUpRight, CheckCircle2 } from 'lucide-react';
import apiClient from '../api/apiClient';

export default function Insights({ metaConnection, onOpenMetaModal, onRefreshConnection }) {
  const [range, setRange] = useState('30d');
  const [metric, setMetric] = useState('roas');
  const [overview, setOverview] = useState(null);
  const [timeSeries, setTimeSeries] = useState([]);
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchAnalyticsData();
  }, [range, metric]);

  const fetchAnalyticsData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [overviewData, timeSeriesData, campaignsData] = await Promise.all([
        apiClient.get(`/analytics/overview?range=${range}`),
        apiClient.get(`/analytics/timeseries?metric=${metric}&range=${range}`),
        apiClient.get(`/analytics/campaigns?range=${range}`),
      ]);
      setOverview(overviewData);
      setTimeSeries(timeSeriesData || []);
      setCampaigns(campaignsData || []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const isConnected = metaConnection && (metaConnection.status === 'CONNECTED' || metaConnection.status === 'SYNCED');
  const isPending = metaConnection && metaConnection.status === 'PENDING_ACCOUNT_SELECTION';

  const formatCurrency = (val) => {
    if (val === null || val === undefined) return '—';
    return `₹${val.toFixed(2)}`;
  };

  const formatLargeNum = (num) => {
    if (!num) return '0';
    if (num >= 1000000) return `${(num / 1000000).toFixed(1)}M`;
    if (num >= 1000) return `${(num / 1000).toFixed(1)}K`;
    return num.toString();
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
      
      {/* Setup / Banner if Meta Disconnected */}
      {!isConnected && (
        <div className="glass-card" style={{
          padding: '1.25rem 1.5rem',
          background: 'linear-gradient(135deg, rgba(24, 119, 242, 0.08) 0%, rgba(59, 130, 246, 0.02) 100%)',
          borderColor: 'rgba(24, 119, 242, 0.2)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <div style={{
              width: '42px',
              height: '42px',
              borderRadius: '50%',
              background: 'rgba(24, 119, 242, 0.12)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#1877f2',
            }}>
              <TrendingUp size={22} />
            </div>
            <div>
              <h3 style={{ fontSize: '1rem', fontWeight: 600, color: '#0f172a' }}>
                {isPending ? 'Select Meta Ad Account' : 'Connect Meta Ad Account'}
              </h3>
              <p style={{ fontSize: '0.825rem', color: 'var(--text-secondary)', marginTop: '0.15rem' }}>
                {isPending ? 'Choose an account to track live metrics' : 'Authorize Throttle to pull live campaign analytics directly from Meta API'}
              </p>
            </div>
          </div>
          <button className="btn-meta" onClick={onOpenMetaModal}>
            <span>{isPending ? 'Select Account' : 'Connect Meta'}</span>
            <ArrowUpRight size={16} />
          </button>
        </div>
      )}

      {/* Date Range Selector */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
        {[
          { key: '7d', label: '7 Days' },
          { key: '30d', label: '30 Days' },
          { key: '90d', label: '90 Days' },
        ].map((r) => (
          <button
            key={r.key}
            onClick={() => setRange(r.key)}
            style={{
              padding: '0.45rem 1rem',
              borderRadius: '9999px',
              fontSize: '0.8rem',
              fontWeight: range === r.key ? 600 : 500,
              background: range === r.key ? '#0f172a' : '#ffffff',
              color: range === r.key ? '#ffffff' : 'var(--text-secondary)',
              border: '1px solid var(--border-glass)',
              cursor: 'pointer',
              boxShadow: 'var(--shadow-sm)',
              transition: 'all 0.2s ease',
            }}
          >
            {r.label}
          </button>
        ))}
      </div>

      {/* Top Metrics Row */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem' }}>
        
        {/* ROAS Card */}
        <div className="glass-card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            ROAS
          </p>
          <h2 style={{ fontSize: '2.25rem', fontWeight: 800, color: '#0f172a', letterSpacing: '-0.03em', margin: '0.35rem 0 0.15rem 0' }}>
            {overview?.roas != null ? overview.roas.toFixed(2) : '—'}
          </h2>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Return on Ad Spend</p>
        </div>

        {/* CPM */}
        <div className="glass-card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            CPM
          </p>
          <h2 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0f172a', margin: '0.35rem 0 0.15rem 0' }}>
            {overview?.cpm != null ? formatCurrency(overview.cpm) : '—'}
          </h2>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Cost per 1k Impressions</p>
        </div>

        {/* CTR */}
        <div className="glass-card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            CTR
          </p>
          <h2 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0f172a', margin: '0.35rem 0 0.15rem 0' }}>
            {overview?.ctr != null ? `${overview.ctr.toFixed(1)}%` : '—'}
          </h2>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Click-through Rate</p>
        </div>

        {/* CPC */}
        <div className="glass-card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            CPC
          </p>
          <h2 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0f172a', margin: '0.35rem 0 0.15rem 0' }}>
            {overview?.cpc != null ? formatCurrency(overview.cpc) : '—'}
          </h2>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Cost per Click</p>
        </div>

        {/* CPL */}
        <div className="glass-card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            CPL
          </p>
          <h2 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0f172a', margin: '0.35rem 0 0.15rem 0' }}>
            {overview?.cpl != null ? formatCurrency(overview.cpl) : '—'}
          </h2>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Cost per Lead</p>
        </div>

      </div>

      {/* Trend Area Chart */}
      <div className="glass-card" style={{ padding: '1.5rem' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.25rem' }}>
          <div>
            <h3 style={{ fontSize: '1rem', fontWeight: 600, color: '#0f172a' }}>
              {metric.toUpperCase()} Trend Overview
            </h3>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
              Historical performance timeline
            </p>
          </div>
          <select
            value={metric}
            onChange={(e) => setMetric(e.target.value)}
            style={{
              background: '#ffffff',
              color: '#0f172a',
              border: '1px solid var(--border-glass)',
              borderRadius: 'var(--radius-md)',
              padding: '0.4rem 0.85rem',
              fontSize: '0.85rem',
              fontWeight: 600,
              cursor: 'pointer',
              outline: 'none',
              boxShadow: 'var(--shadow-sm)',
            }}
          >
            <option value="roas" style={{ background: '#ffffff', color: '#0f172a' }}>ROAS</option>
            <option value="spend" style={{ background: '#ffffff', color: '#0f172a' }}>Spend (₹)</option>
            <option value="cpm" style={{ background: '#ffffff', color: '#0f172a' }}>CPM (₹)</option>
            <option value="ctr" style={{ background: '#ffffff', color: '#0f172a' }}>CTR (%)</option>
            <option value="cpl" style={{ background: '#ffffff', color: '#0f172a' }}>CPL (₹)</option>
            <option value="leads" style={{ background: '#ffffff', color: '#0f172a' }}>Leads</option>
          </select>
        </div>

        <div style={{ width: '100%', height: 260 }}>
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={timeSeries} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
              <defs>
                <linearGradient id="chartGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#2563eb" stopOpacity={0.25}/>
                  <stop offset="95%" stopColor="#2563eb" stopOpacity={0.0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(203, 213, 225, 0.6)" vertical={false} />
              <XAxis dataKey="date" stroke="var(--text-muted)" fontSize={11} tickLine={false} />
              <YAxis stroke="var(--text-muted)" fontSize={11} tickLine={false} />
              <Tooltip
                contentStyle={{
                  backgroundColor: '#ffffff',
                  borderColor: 'rgba(203, 213, 225, 0.8)',
                  borderRadius: '12px',
                  color: '#0f172a',
                  fontSize: '0.85rem',
                  boxShadow: 'var(--shadow-md)',
                }}
                formatter={(val) => [metric === 'spend' || metric === 'cpm' || metric === 'cpl' ? `₹${val}` : val, metric.toUpperCase()]}
              />
              <Area type="monotone" dataKey="value" stroke="#2563eb" strokeWidth={2.5} fillOpacity={1} fill="url(#chartGradient)" />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Grid: Account Details & Campaigns */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.5rem' }}>
        
        {/* Account Overview Table */}
        <div className="glass-card" style={{ padding: '1.5rem' }}>
          <h3 style={{ fontSize: '0.9rem', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: '1rem' }}>
            Account Overview Metrics
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {[
              { label: 'Total Spend', val: overview ? formatCurrency(overview.spend) : '—' },
              { label: 'Impressions', val: overview ? formatLargeNum(overview.impressions) : '—' },
              { label: 'Reach', val: overview ? formatLargeNum(overview.reach) : '—' },
              { label: 'Clicks', val: overview ? formatLargeNum(overview.clicks) : '—' },
              { label: 'Leads Generated', val: overview ? overview.leads : '—' },
              { label: 'Conversions', val: overview ? overview.conversions : '—' },
            ].map((row, idx) => (
              <div key={idx} style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '0.75rem 0',
                borderBottom: idx < 5 ? '1px solid var(--border-glass)' : 'none',
              }}>
                <span style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>{row.label}</span>
                <span style={{ fontSize: '0.875rem', fontWeight: 600, color: '#0f172a' }}>{row.val}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Active Campaigns List */}
        <div className="glass-card" style={{ padding: '1.5rem' }}>
          <h3 style={{ fontSize: '0.9rem', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: '1rem' }}>
            Meta Campaigns ({campaigns.length})
          </h3>
          {campaigns.length === 0 ? (
            <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', textAlign: 'center', padding: '2rem 0' }}>
              No active campaign data found.
            </p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.875rem' }}>
              {campaigns.map((c) => (
                <div key={c.id} style={{
                  padding: '0.85rem',
                  borderRadius: 'var(--radius-md)',
                  background: '#ffffff',
                  border: '1px solid var(--border-glass)',
                  boxShadow: 'var(--shadow-sm)',
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.4rem' }}>
                    <h4 style={{ fontSize: '0.9rem', fontWeight: 600, color: '#0f172a', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '220px' }}>
                      {c.name}
                    </h4>
                    <span style={{
                      fontSize: '0.7rem',
                      fontWeight: 600,
                      padding: '0.15rem 0.5rem',
                      borderRadius: '9999px',
                      background: c.status === 'ACTIVE' ? 'rgba(16, 185, 129, 0.12)' : 'rgba(148, 163, 184, 0.12)',
                      color: c.status === 'ACTIVE' ? '#10b981' : 'var(--text-muted)',
                    }}>
                      {c.status}
                    </span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                    <span>Spend: ₹{c.spend.toFixed(0)}</span>
                    <span>ROAS: {c.roas != null ? c.roas.toFixed(2) : '—'}</span>
                    <span>Leads: {c.leads}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

      </div>

    </div>
  );
}
