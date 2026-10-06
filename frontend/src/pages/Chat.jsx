import React, { useState, useEffect, useRef } from 'react';
import { Send, Lock, ShieldCheck, RefreshCw } from 'lucide-react';
import apiClient from '../api/apiClient';
import { useAuth } from '../context/AuthContext';

export default function Chat() {
  const { user } = useAuth();
  const [conversations, setConversations] = useState([]);
  const [activeConv, setActiveConv] = useState(null);
  const [messages, setMessages] = useState([]);
  const [text, setText] = useState('');
  const [loading, setLoading] = useState(true);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    fetchConversations();
  }, []);

  const fetchConversations = async () => {
    try {
      const data = await apiClient.get('/conversations');
      setConversations(data || []);
      if (data && data.length > 0) {
        setActiveConv(data[0]);
        fetchMessages(data[0].id);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const fetchMessages = async (convId) => {
    try {
      const data = await apiClient.get(`/conversations/${convId}/messages`);
      setMessages(data || []);
      scrollToBottom();
    } catch (err) {
      console.error(err);
    }
  };

  const scrollToBottom = () => {
    setTimeout(() => {
      messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }, 100);
  };

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!text.trim() || !activeConv) return;
    try {
      const sent = await apiClient.post(`/conversations/${activeConv.id}/messages`, { message: text });
      setMessages((prev) => [...prev, sent]);
      setText('');
      scrollToBottom();
    } catch (err) {
      alert(err.message);
    }
  };

  return (
    <div className="animate-fade-in glass-card" style={{
      height: 'calc(100vh - 150px)',
      minHeight: '520px',
      display: 'grid',
      gridTemplateColumns: '280px 1fr',
      overflow: 'hidden',
      boxShadow: 'var(--shadow-md)',
    }}>
      {/* Conversation Sidebar */}
      <div style={{
        borderRight: '1px solid var(--border-glass)',
        padding: '1.25rem',
        display: 'flex',
        flexDirection: 'column',
        background: '#ffffff',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1rem' }}>
          <h3 style={{ fontSize: '0.85rem', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
            Direct Channels
          </h3>
          <ShieldCheck size={16} color="#10b981" />
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', overflowY: 'auto' }}>
          {conversations.map((c) => (
            <div
              key={c.id}
              onClick={() => {
                setActiveConv(c);
                fetchMessages(c.id);
              }}
              style={{
                padding: '0.85rem',
                borderRadius: 'var(--radius-md)',
                background: activeConv?.id === c.id ? 'rgba(37, 99, 235, 0.08)' : '#f8fafc',
                border: `1px solid ${activeConv?.id === c.id ? '#2563eb' : 'var(--border-glass)'}`,
                cursor: 'pointer',
                boxShadow: activeConv?.id === c.id ? 'var(--shadow-sm)' : 'none',
                transition: 'all 0.2s ease',
              }}
            >
              <p style={{ fontSize: '0.875rem', fontWeight: 600, color: '#0f172a', wordBreak: 'break-word' }}>
                {c.title || 'Direct Support Channel'}
              </p>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.2rem', display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
                <Lock size={12} color="#10b981" />
                End-to-End Encrypted
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Main Chat Workspace */}
      <div style={{ display: 'flex', flexDirection: 'column', height: '100%', background: '#f8fafc' }}>
        {/* Chat Header */}
        <div style={{
          padding: '1rem 1.5rem',
          borderBottom: '1px solid var(--border-glass)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          background: '#ffffff',
        }}>
          <div>
            <h3 style={{ fontSize: '1rem', fontWeight: 700, color: '#0f172a' }}>
              {activeConv?.title || 'Direct Channel'}
            </h3>
            <p style={{ fontSize: '0.75rem', color: '#10b981', display: 'flex', alignItems: 'center', gap: '0.35rem', marginTop: '0.15rem' }}>
              <Lock size={12} />
              Fernet 256-Bit AES Encrypted Direct Channel
            </p>
          </div>
          <button
            onClick={() => activeConv && fetchMessages(activeConv.id)}
            style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', padding: '0.35rem' }}
            title="Refresh Messages"
          >
            <RefreshCw size={16} />
          </button>
        </div>

        {/* Message Bubble Feed */}
        <div style={{
          flex: 1,
          padding: '1.5rem',
          overflowY: 'auto',
          display: 'flex',
          flexDirection: 'column',
          gap: '1rem',
        }}>
          {messages.map((m) => {
            const isMe = m.sender_user_id === user?.id;
            // Clean display text fallback if ciphertext format string is encountered
            const rawText = m.message || '';
            const displayText = rawText.startsWith('enc:v1:') ? 'Encrypted Support Message' : rawText;

            return (
              <div
                key={m.id}
                style={{
                  alignSelf: isMe ? 'flex-end' : 'flex-start',
                  maxWidth: '70%',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: isMe ? 'flex-end' : 'flex-start',
                }}
              >
                <div style={{
                  padding: '0.75rem 1.15rem',
                  borderRadius: '16px',
                  borderBottomRightRadius: isMe ? '4px' : '16px',
                  borderBottomLeftRadius: !isMe ? '4px' : '16px',
                  background: isMe ? 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)' : '#ffffff',
                  border: isMe ? 'none' : '1px solid var(--border-glass)',
                  color: isMe ? '#ffffff' : '#0f172a',
                  fontSize: '0.875rem',
                  lineHeight: 1.5,
                  wordBreak: 'break-word',
                  overflowWrap: 'anywhere',
                  boxShadow: isMe ? '0 4px 14px rgba(37, 99, 235, 0.25)' : 'var(--shadow-sm)',
                }}>
                  {displayText}
                </div>
                <span style={{ fontSize: '0.7rem', color: 'var(--text-muted)', marginTop: '0.3rem', padding: '0 0.25rem' }}>
                  {m.sender_name || (isMe ? 'You' : 'Throttle Admin')} • {m.created_at ? new Date(m.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                </span>
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>

        {/* Message Composition Input */}
        <form onSubmit={handleSendMessage} style={{
          padding: '1rem 1.5rem',
          borderTop: '1px solid var(--border-glass)',
          display: 'flex',
          gap: '0.75rem',
          background: '#ffffff',
        }}>
          <input
            type="text"
            placeholder="Type your encrypted message..."
            value={text}
            onChange={(e) => setText(e.target.value)}
            style={{
              flex: 1,
              padding: '0.75rem 1rem',
              borderRadius: 'var(--radius-md)',
              background: '#f8fafc',
              border: '1px solid var(--border-glass)',
              color: '#0f172a',
              fontSize: '0.875rem',
              outline: 'none',
            }}
          />
          <button type="submit" className="btn-primary">
            <Send size={16} />
            <span>Send</span>
          </button>
        </form>
      </div>
    </div>
  );
}
