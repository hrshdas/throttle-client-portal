import React, { useState, useEffect } from 'react';
import { CheckCircle2, Clock, AlertCircle, MessageSquare, Send, ThumbsUp, RotateCcw, Plus, X } from 'lucide-react';
import apiClient from '../api/apiClient';

export default function Tasks() {
  const [tasks, setTasks] = useState([]);
  const [filter, setFilter] = useState('ALL');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedTask, setSelectedTask] = useState(null);
  const [comments, setComments] = useState([]);
  const [newComment, setNewComment] = useState('');
  const [actionComment, setActionComment] = useState('');

  // Create task modal state
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const [newDescription, setNewDescription] = useState('');
  const [newPriority, setNewPriority] = useState('MEDIUM');
  const [newDueDate, setNewDueDate] = useState('');
  const [newRequiresApproval, setNewRequiresApproval] = useState(false);
  const [createLoading, setCreateLoading] = useState(false);
  const [createError, setCreateError] = useState(null);

  useEffect(() => {
    fetchTasks();
  }, [filter]);

  const fetchTasks = async () => {
    setLoading(true);
    setError(null);
    try {
      let url = '/tasks';
      if (filter === 'REVIEW') url = '/tasks?status=READY_FOR_REVIEW';
      if (filter === 'APPROVAL') url = '/tasks?requires_client_approval=true';
      if (filter === 'COMPLETED') url = '/tasks?status=COMPLETED';

      const data = await apiClient.get(url);
      setTasks(data || []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateTask = async (e) => {
    e.preventDefault();
    if (!newTitle.trim()) return;

    setCreateLoading(true);
    setCreateError(null);

    try {
      await apiClient.post('/tasks', {
        title: newTitle.trim(),
        description: newDescription.trim() || null,
        priority: newPriority,
        due_date: newDueDate || null,
        requires_client_approval: newRequiresApproval,
      });

      setIsCreateModalOpen(false);
      setNewTitle('');
      setNewDescription('');
      setNewPriority('MEDIUM');
      setNewDueDate('');
      setNewRequiresApproval(false);
      fetchTasks();
    } catch (err) {
      setCreateError(err.message || 'Failed to create task');
    } finally {
      setCreateLoading(false);
    }
  };

  const handleOpenComments = async (task) => {
    setSelectedTask(task);
    try {
      const data = await apiClient.get(`/tasks/${task.id}/comments`);
      setComments(data || []);
    } catch (err) {
      console.error(err);
    }
  };

  const handleAddComment = async (e) => {
    e.preventDefault();
    if (!newComment.trim() || !selectedTask) return;
    try {
      const added = await apiClient.post(`/tasks/${selectedTask.id}/comments`, { message: newComment });
      setComments((prev) => [...prev, added]);
      setNewComment('');
    } catch (err) {
      alert(err.message);
    }
  };

  const handleApprove = async (taskId) => {
    try {
      await apiClient.post(`/tasks/${taskId}/approve`, { comment: actionComment || 'Approved!' });
      setActionComment('');
      fetchTasks();
      if (selectedTask?.id === taskId) setSelectedTask(null);
    } catch (err) {
      alert(err.message);
    }
  };

  const handleRequestChanges = async (taskId) => {
    if (!actionComment.trim()) {
      alert('Please provide a comment explaining requested changes.');
      return;
    }
    try {
      await apiClient.post(`/tasks/${taskId}/request-changes`, { comment: actionComment });
      setActionComment('');
      fetchTasks();
      if (selectedTask?.id === taskId) setSelectedTask(null);
    } catch (err) {
      alert(err.message);
    }
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
      
      {/* Header Bar with Filters and Create Task Button */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '1rem', flexWrap: 'wrap' }}>
        {/* Filters */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flexWrap: 'wrap' }}>
          {[
            { key: 'ALL', label: 'All Tasks' },
            { key: 'REVIEW', label: 'Ready for Review' },
            { key: 'APPROVAL', label: 'Pending Approval' },
            { key: 'COMPLETED', label: 'Completed' },
          ].map((f) => (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              style={{
                padding: '0.45rem 1rem',
                borderRadius: '9999px',
                fontSize: '0.8rem',
                fontWeight: filter === f.key ? 600 : 500,
                background: filter === f.key ? '#0f172a' : '#ffffff',
                color: filter === f.key ? '#ffffff' : 'var(--text-secondary)',
                border: '1px solid var(--border-glass)',
                cursor: 'pointer',
                boxShadow: 'var(--shadow-sm)',
                transition: 'all 0.2s ease',
              }}
            >
              {f.label}
            </button>
          ))}
        </div>

        <button
          onClick={() => setIsCreateModalOpen(true)}
          className="btn-primary"
          style={{ padding: '0.5rem 1.1rem', fontSize: '0.85rem', gap: '0.4rem' }}
        >
          <Plus size={16} />
          <span>Create Task</span>
        </button>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem 0', color: 'var(--text-secondary)' }}>
          Loading tasks...
        </div>
      ) : tasks.length === 0 ? (
        <div className="glass-card" style={{ padding: '3rem 1.5rem', textAlign: 'center' }}>
          <CheckCircle2 size={36} color="var(--text-muted)" style={{ margin: '0 auto 0.75rem auto' }} />
          <h3 style={{ fontSize: '1rem', fontWeight: 600, color: '#0f172a' }}>No Tasks Found</h3>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '0.25rem', marginBottom: '1.25rem' }}>
            No tasks match the selected filter criteria.
          </p>
          <button
            onClick={() => setIsCreateModalOpen(true)}
            className="btn-primary"
            style={{ margin: '0 auto', padding: '0.5rem 1.25rem', fontSize: '0.85rem' }}
          >
            <Plus size={16} />
            <span>Create First Task</span>
          </button>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(340px, 1fr))', gap: '1.25rem' }}>
          {tasks.map((task) => (
            <div key={task.id} className="glass-card" style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
              <div>
                {/* Header Badges */}
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.75rem' }}>
                  <span style={{
                    fontSize: '0.7rem',
                    fontWeight: 700,
                    padding: '0.2rem 0.5rem',
                    borderRadius: '6px',
                    textTransform: 'uppercase',
                    background: task.priority === 'HIGH' ? 'rgba(244, 63, 94, 0.12)' : task.priority === 'LOW' ? 'rgba(100, 116, 139, 0.12)' : 'rgba(37, 99, 235, 0.12)',
                    color: task.priority === 'HIGH' ? '#f43f5e' : task.priority === 'LOW' ? '#64748b' : '#2563eb',
                  }}>
                    {task.priority} Priority
                  </span>
                  <span style={{
                    fontSize: '0.75rem',
                    fontWeight: 600,
                    color: task.status === 'COMPLETED' ? '#10b981' : task.status === 'READY_FOR_REVIEW' ? '#f59e0b' : 'var(--text-secondary)',
                  }}>
                    {task.status.replace(/_/g, ' ')}
                  </span>
                </div>

                <h3 style={{ fontSize: '1.05rem', fontWeight: 600, color: '#0f172a', marginBottom: '0.4rem' }}>
                  {task.title}
                </h3>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', lineHeight: 1.5, marginBottom: '1rem' }}>
                  {task.description}
                </p>
              </div>

              <div>
                {/* Due Date & Action bar */}
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  paddingTop: '0.75rem',
                  borderTop: '1px solid var(--border-glass)',
                  marginBottom: task.requires_client_approval && task.approval_status === 'PENDING' ? '1rem' : '0',
                }}>
                  <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                    <Clock size={14} />
                    Due: {task.due_date || 'No deadline'}
                  </span>

                  <button
                    onClick={() => handleOpenComments(task)}
                    style={{
                      background: 'none',
                      border: 'none',
                      color: 'var(--text-secondary)',
                      fontSize: '0.8rem',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.35rem',
                    }}
                  >
                    <MessageSquare size={15} />
                    Comments
                  </button>
                </div>

                {/* Client Approval Controls */}
                {task.requires_client_approval && task.approval_status === 'PENDING' && (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                    <input
                      type="text"
                      placeholder="Approval note / change request comment..."
                      value={selectedTask?.id === task.id ? actionComment : ''}
                      onChange={(e) => {
                        setSelectedTask(task);
                        setActionComment(e.target.value);
                      }}
                      style={{
                        width: '100%',
                        padding: '0.5rem 0.75rem',
                        borderRadius: 'var(--radius-sm)',
                        background: '#ffffff',
                        border: '1px solid var(--border-glass)',
                        color: '#0f172a',
                        fontSize: '0.8rem',
                        outline: 'none',
                      }}
                    />
                    <div style={{ display: 'flex', gap: '0.5rem' }}>
                      <button
                        onClick={() => handleApprove(task.id)}
                        className="btn-primary"
                        style={{ flex: 1, padding: '0.45rem', fontSize: '0.8rem', justifyContent: 'center', background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)' }}
                      >
                        <ThumbsUp size={14} />
                        <span>Approve</span>
                      </button>
                      <button
                        onClick={() => handleRequestChanges(task.id)}
                        className="btn-ghost"
                        style={{ flex: 1, padding: '0.45rem', fontSize: '0.8rem', justifyContent: 'center', color: '#d97706', borderColor: 'rgba(245, 158, 11, 0.4)' }}
                      >
                        <RotateCcw size={14} />
                        <span>Request Changes</span>
                      </button>
                    </div>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create Task Modal */}
      {isCreateModalOpen && (
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
          <div className="glass-card" style={{ width: '100%', maxWidth: '520px', padding: '1.75rem', background: '#ffffff', boxShadow: 'var(--shadow-lg)' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.25rem' }}>
              <div>
                <h3 style={{ fontSize: '1.15rem', fontWeight: 600, color: '#0f172a' }}>Create New Task</h3>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
                  Assign or submit a new task for agency review or approval.
                </p>
              </div>
              <button
                onClick={() => setIsCreateModalOpen(false)}
                style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', padding: '0.25rem' }}
              >
                <X size={18} />
              </button>
            </div>

            {createError && (
              <div style={{
                padding: '0.75rem 1rem',
                borderRadius: 'var(--radius-sm)',
                background: 'rgba(239, 68, 68, 0.1)',
                border: '1px solid rgba(239, 68, 68, 0.3)',
                color: '#ef4444',
                fontSize: '0.85rem',
                marginBottom: '1rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
              }}>
                <AlertCircle size={16} />
                <span>{createError}</span>
              </div>
            )}

            <form onSubmit={handleCreateTask} style={{ display: 'flex', flexDirection: 'column', gap: '1.1rem' }}>
              <div>
                <label style={{ display: 'block', fontSize: '0.8rem', fontWeight: 600, color: '#0f172a', marginBottom: '0.4rem' }}>
                  Task Title *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Meta Ad Campaign Creative Approval"
                  value={newTitle}
                  onChange={(e) => setNewTitle(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '0.65rem 0.85rem',
                    borderRadius: 'var(--radius-sm)',
                    background: '#ffffff',
                    border: '1px solid var(--border-glass)',
                    color: '#0f172a',
                    fontSize: '0.875rem',
                    outline: 'none',
                  }}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '0.8rem', fontWeight: 600, color: '#0f172a', marginBottom: '0.4rem' }}>
                  Description
                </label>
                <textarea
                  rows={3}
                  placeholder="Describe the task details, links to collateral, or notes..."
                  value={newDescription}
                  onChange={(e) => setNewDescription(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '0.65rem 0.85rem',
                    borderRadius: 'var(--radius-sm)',
                    background: '#ffffff',
                    border: '1px solid var(--border-glass)',
                    color: '#0f172a',
                    fontSize: '0.875rem',
                    outline: 'none',
                    resize: 'vertical',
                  }}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.8rem', fontWeight: 600, color: '#0f172a', marginBottom: '0.4rem' }}>
                    Priority
                  </label>
                  <select
                    value={newPriority}
                    onChange={(e) => setNewPriority(e.target.value)}
                    style={{
                      width: '100%',
                      padding: '0.65rem 0.85rem',
                      borderRadius: 'var(--radius-sm)',
                      background: '#ffffff',
                      border: '1px solid var(--border-glass)',
                      color: '#0f172a',
                      fontSize: '0.875rem',
                      outline: 'none',
                    }}
                  >
                    <option value="LOW">Low</option>
                    <option value="MEDIUM">Medium</option>
                    <option value="HIGH">High</option>
                  </select>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.8rem', fontWeight: 600, color: '#0f172a', marginBottom: '0.4rem' }}>
                    Due Date
                  </label>
                  <input
                    type="date"
                    value={newDueDate}
                    onChange={(e) => setNewDueDate(e.target.value)}
                    style={{
                      width: '100%',
                      padding: '0.65rem 0.85rem',
                      borderRadius: 'var(--radius-sm)',
                      background: '#ffffff',
                      border: '1px solid var(--border-glass)',
                      color: '#0f172a',
                      fontSize: '0.875rem',
                      outline: 'none',
                    }}
                  />
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', paddingTop: '0.2rem' }}>
                <input
                  type="checkbox"
                  id="requiresApproval"
                  checked={newRequiresApproval}
                  onChange={(e) => setNewRequiresApproval(e.target.checked)}
                  style={{ width: '1rem', height: '1rem', cursor: 'pointer', accentColor: 'var(--accent-color, #2563eb)' }}
                />
                <label htmlFor="requiresApproval" style={{ fontSize: '0.85rem', color: '#0f172a', cursor: 'pointer', userSelect: 'none' }}>
                  Requires Client Approval
                </label>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem', marginTop: '0.5rem' }}>
                <button
                  type="button"
                  onClick={() => setIsCreateModalOpen(false)}
                  className="btn-ghost"
                  style={{ padding: '0.6rem 1.1rem', fontSize: '0.85rem' }}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={createLoading}
                  className="btn-primary"
                  style={{ padding: '0.6rem 1.35rem', fontSize: '0.85rem' }}
                >
                  {createLoading ? 'Creating...' : 'Create Task'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Task Comments Modal */}
      {selectedTask && (
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
          <div className="glass-card" style={{ width: '100%', maxWidth: '500px', padding: '1.5rem', maxHeight: '80vh', display: 'flex', flexDirection: 'column', background: '#ffffff', boxShadow: 'var(--shadow-lg)' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1rem' }}>
              <h3 style={{ fontSize: '1.1rem', fontWeight: 600, color: '#0f172a' }}>Comments: {selectedTask.title}</h3>
              <button onClick={() => setSelectedTask(null)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>✕</button>
            </div>

            <div style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '0.75rem', marginBottom: '1rem', paddingRight: '0.25rem' }}>
              {comments.length === 0 ? (
                <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', textAlign: 'center', padding: '1.5rem 0' }}>No comments yet.</p>
              ) : (
                comments.map((c) => (
                  <div key={c.id} style={{ padding: '0.75rem', borderRadius: 'var(--radius-sm)', background: '#f8fafc', border: '1px solid var(--border-glass)' }}>
                    <p style={{ fontSize: '0.825rem', color: '#0f172a' }}>{c.message}</p>
                    <span style={{ fontSize: '0.7rem', color: 'var(--text-muted)', marginTop: '0.25rem', display: 'block' }}>{c.created_at ? new Date(c.created_at).toLocaleString() : ''}</span>
                  </div>
                ))
              )}
            </div>

            <form onSubmit={handleAddComment} style={{ display: 'flex', gap: '0.5rem' }}>
              <input
                type="text"
                placeholder="Write a comment..."
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
                style={{ flex: 1, padding: '0.6rem 0.85rem', borderRadius: 'var(--radius-md)', background: '#ffffff', border: '1px solid var(--border-glass)', color: '#0f172a', fontSize: '0.85rem', outline: 'none' }}
              />
              <button type="submit" className="btn-primary" style={{ padding: '0.6rem 1rem' }}>
                <Send size={16} />
              </button>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
