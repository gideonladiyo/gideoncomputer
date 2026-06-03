'use client'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Profile } from '@/lib/types'
import { Plus, Search, UserCircle2, KeyRound, Pencil } from 'lucide-react'
import { toast } from '@/components/Toast'

export default function UsersPage() {
    const [users, setUsers] = useState<Profile[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')

    // Modal tambah user
    const [showCreate, setShowCreate] = useState(false)
    const [submitting, setSubmitting] = useState(false)
    const [form, setForm] = useState({
        fullname: '',
        email: '',
        password: '',
        role: 'student' as 'student' | 'admin',
    })

    // Modal edit user
    const [showEdit, setShowEdit] = useState(false)
    const [editForm, setEditForm] = useState({
        fullname: '',
        email: '',
        role: 'student' as 'student' | 'admin',
    })
    const [editing, setEditing] = useState(false)

    // Modal ganti password
    const [showChangePass, setShowChangePass] = useState(false)
    const [selectedUser, setSelectedUser] = useState<Profile | null>(null)
    const [newPassword, setNewPassword] = useState('')
    const [confirmPassword, setConfirmPassword] = useState('')
    const [changingPass, setChangingPass] = useState(false)

    const fetchUsers = async () => {
        const { data } = await supabase
            .from('profiles')
            .select('*')
            .order('created_at', { ascending: false })
        setUsers((data as Profile[]) ?? [])
        setLoading(false)
    }

    useEffect(() => {
        fetchUsers()
    }, [])

    const filtered = users.filter(
        (u) =>
            u.fullname?.toLowerCase().includes(search.toLowerCase()) ||
            u.email?.toLowerCase().includes(search.toLowerCase())
    )

    const resetForm = () => setForm({ fullname: '', email: '', password: '', role: 'student' })

    // ── Tambah User ──────────────────────────────────────────────
    const handleCreate = async () => {
        if (!form.fullname || !form.email || !form.password) {
            toast('Semua field wajib diisi')
            return
        }
        if (form.password.length < 6) {
            toast('Password minimal 6 karakter')
            return
        }
        setSubmitting(true)
        try {
            const res = await fetch('/api/users/create', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(form),
            })
            const data = await res.json()
            if (!res.ok) {
                toast(data.error ?? 'Gagal membuat user')
            } else {
                toast('User berhasil dibuat!')
                setShowCreate(false)
                resetForm()
                fetchUsers()
            }
        } catch {
            toast('Terjadi kesalahan, coba lagi')
        } finally {
            setSubmitting(false)
        }
    }

    // ── Edit User ────────────────────────────────────────────────
    const openEdit = (user: Profile) => {
        setSelectedUser(user)
        setEditForm({ fullname: user.fullname ?? '', email: user.email ?? '', role: (user.role as 'student' | 'admin') ?? 'student' })
        setShowEdit(true)
    }

    const handleEdit = async () => {
        if (!editForm.fullname || !editForm.email) {
            toast('Nama dan email wajib diisi')
            return
        }
        setEditing(true)
        try {
            const res = await fetch('/api/users/edit', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ userId: selectedUser?.id, ...editForm }),
            })
            const data = await res.json()
            if (!res.ok) {
                toast(data.error ?? 'Gagal menyimpan perubahan')
            } else {
                toast('Data user berhasil diupdate!')
                setShowEdit(false)
                fetchUsers()
            }
        } catch {
            toast('Terjadi kesalahan, coba lagi')
        } finally {
            setEditing(false)
        }
    }

    // ── Ganti Password ───────────────────────────────────────────
    const openChangePass = (user: Profile) => {
        setSelectedUser(user)
        setNewPassword('')
        setConfirmPassword('')
        setShowChangePass(true)
    }

    const handleChangePassword = async () => {
        if (!newPassword) {
            toast('Password baru wajib diisi')
            return
        }
        if (newPassword.length < 6) {
            toast('Password minimal 6 karakter')
            return
        }
        if (newPassword !== confirmPassword) {
            toast('Konfirmasi password tidak cocok')
            return
        }
        setChangingPass(true)
        try {
            const res = await fetch('/api/users/change-password', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ userId: selectedUser?.id, password: newPassword }),
            })
            const data = await res.json()
            if (!res.ok) {
                toast(data.error ?? 'Gagal mengganti password')
            } else {
                toast(`Password ${selectedUser?.fullname} berhasil diubah`)
                setShowChangePass(false)
            }
        } catch {
            toast('Terjadi kesalahan, coba lagi')
        } finally {
            setChangingPass(false)
        }
    }

    return (
        <div>
            <div className="flex items-center justify-between mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Users</h1>
                    <p className="text-sm text-gray-500">Daftar user yang terdaftar</p>
                </div>
                <div className="flex items-center gap-3">
                    <div className="relative">
                        <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Cari nama atau email..."
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            className="border border-gray-300 rounded-lg pl-8 pr-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-teal-600"
                        />
                    </div>
                    <button
                        onClick={() => setShowCreate(true)}
                        className="flex items-center gap-2 bg-teal-700 text-white px-4 py-2 rounded-lg text-sm hover:bg-teal-800 transition"
                    >
                        <Plus size={16} /> Tambah User
                    </button>
                </div>
            </div>

            {loading ? (
                <div className="text-center py-20 text-gray-400">Memuat...</div>
            ) : (
                <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                    <table className="w-full text-sm">
                        <thead className="bg-gray-50 text-gray-600">
                            <tr>
                                <th className="text-left px-4 py-3">User</th>
                                <th className="text-left px-4 py-3">Email</th>
                                <th className="text-left px-4 py-3">Role</th>
                                <th className="text-left px-4 py-3">Bergabung</th>
                                <th className="text-left px-4 py-3">Aksi</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {filtered.map((user) => (
                                <tr key={user.id} className="hover:bg-gray-50">
                                    <td className="px-4 py-3">
                                        <div className="flex items-center gap-3">
                                            <div className="w-8 h-8 rounded-full bg-teal-100 flex items-center justify-center text-teal-700 font-semibold text-sm">
                                                {user.fullname?.[0]?.toUpperCase() ?? '?'}
                                            </div>
                                            <span className="font-medium text-gray-800">{user.fullname ?? '-'}</span>
                                        </div>
                                    </td>
                                    <td className="px-4 py-3 text-gray-600">{user.email}</td>
                                    <td className="px-4 py-3">
                                        <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${user.role === 'admin'
                                                ? 'bg-purple-50 text-purple-700'
                                                : 'bg-gray-100 text-gray-600'
                                            }`}>
                                            {user.role}
                                        </span>
                                    </td>
                                    <td className="px-4 py-3 text-gray-400 text-xs">
                                        {new Date(user.created_at).toLocaleDateString('id-ID')}
                                    </td>
                                    <td className="px-4 py-3">
                                        <div className="flex items-center gap-2">
                                            <button
                                                onClick={() => openEdit(user)}
                                                className="flex items-center gap-1.5 text-xs text-gray-500 hover:text-blue-600 border border-gray-200 hover:border-blue-300 px-2.5 py-1.5 rounded-lg transition"
                                            >
                                                <Pencil size={12} />
                                                Edit
                                            </button>
                                            <button
                                                onClick={() => openChangePass(user)}
                                                className="flex items-center gap-1.5 text-xs text-gray-500 hover:text-teal-700 border border-gray-200 hover:border-teal-300 px-2.5 py-1.5 rounded-lg transition"
                                            >
                                                <KeyRound size={12} />
                                                Password
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}

            {/* ── Modal Tambah User ── */}
            {showCreate && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl">
                        <div className="flex items-center gap-3 mb-5">
                            <div className="w-10 h-10 rounded-full bg-teal-50 flex items-center justify-center">
                                <UserCircle2 size={20} className="text-teal-700" />
                            </div>
                            <div>
                                <h2 className="text-lg font-bold text-gray-800">Tambah User Baru</h2>
                                <p className="text-xs text-gray-400">User akan langsung bisa login</p>
                            </div>
                        </div>
                        <div className="space-y-4">
                            <div>
                                <label className="text-sm font-medium text-gray-700">Nama Lengkap</label>
                                <input
                                    type="text"
                                    value={form.fullname}
                                    onChange={(e) => setForm({ ...form, fullname: e.target.value })}
                                    placeholder="Contoh: Budi Santoso"
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                />
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Email</label>
                                <input
                                    type="email"
                                    value={form.email}
                                    onChange={(e) => setForm({ ...form, email: e.target.value })}
                                    placeholder="email@contoh.com"
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                />
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Password</label>
                                <input
                                    type="password"
                                    value={form.password}
                                    onChange={(e) => setForm({ ...form, password: e.target.value })}
                                    placeholder="Minimal 6 karakter"
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                />
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Role</label>
                                <select
                                    value={form.role}
                                    onChange={(e) => setForm({ ...form, role: e.target.value as 'student' | 'admin' })}
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                >
                                    <option value="student">Student</option>
                                    <option value="admin">Admin</option>
                                </select>
                            </div>
                        </div>
                        <div className="flex justify-end gap-2 mt-6">
                            <button
                                onClick={() => { setShowCreate(false); resetForm() }}
                                disabled={submitting}
                                className="px-4 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50"
                            >
                                Batal
                            </button>
                            <button
                                onClick={handleCreate}
                                disabled={submitting}
                                className="px-4 py-2 text-sm bg-teal-700 text-white rounded-lg hover:bg-teal-800 disabled:opacity-50 min-w-[100px]"
                            >
                                {submitting ? 'Menyimpan...' : 'Buat User'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* ── Modal Edit User ── */}
            {showEdit && selectedUser && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl">
                        <div className="flex items-center gap-3 mb-5">
                            <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center">
                                <Pencil size={18} className="text-blue-600" />
                            </div>
                            <div>
                                <h2 className="text-lg font-bold text-gray-800">Edit User</h2>
                                <p className="text-xs text-gray-400">ID: {selectedUser.id.slice(0, 8)}...</p>
                            </div>
                        </div>
                        <div className="space-y-4">
                            <div>
                                <label className="text-sm font-medium text-gray-700">Nama Lengkap</label>
                                <input
                                    type="text"
                                    value={editForm.fullname}
                                    onChange={(e) => setEditForm({ ...editForm, fullname: e.target.value })}
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                />
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Email</label>
                                <input
                                    type="email"
                                    value={editForm.email}
                                    onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                />
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Role</label>
                                <select
                                    value={editForm.role}
                                    onChange={(e) => setEditForm({ ...editForm, role: e.target.value as 'student' | 'admin' })}
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                >
                                    <option value="student">Student</option>
                                    <option value="admin">Admin</option>
                                </select>
                            </div>
                        </div>
                        <div className="flex justify-end gap-2 mt-6">
                            <button
                                onClick={() => setShowEdit(false)}
                                disabled={editing}
                                className="px-4 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50"
                            >
                                Batal
                            </button>
                            <button
                                onClick={handleEdit}
                                disabled={editing}
                                className="px-4 py-2 text-sm bg-teal-700 text-white rounded-lg hover:bg-teal-800 disabled:opacity-50 min-w-[100px]"
                            >
                                {editing ? 'Menyimpan...' : 'Simpan'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* ── Modal Ganti Password ── */}
            {showChangePass && selectedUser && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl">
                        <div className="flex items-center gap-3 mb-5">
                            <div className="w-10 h-10 rounded-full bg-amber-50 flex items-center justify-center">
                                <KeyRound size={20} className="text-amber-600" />
                            </div>
                            <div>
                                <h2 className="text-lg font-bold text-gray-800">Ganti Password</h2>
                                <p className="text-xs text-gray-400">{selectedUser.fullname} &middot; {selectedUser.email}</p>
                            </div>
                        </div>
                        <div className="space-y-4">
                            <div>
                                <label className="text-sm font-medium text-gray-700">Password Baru</label>
                                <input
                                    type="password"
                                    value={newPassword}
                                    onChange={(e) => setNewPassword(e.target.value)}
                                    placeholder="Minimal 6 karakter"
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                />
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Konfirmasi Password</label>
                                <input
                                    type="password"
                                    value={confirmPassword}
                                    onChange={(e) => setConfirmPassword(e.target.value)}
                                    placeholder="Ulangi password baru"
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                />
                                {confirmPassword && newPassword !== confirmPassword && (
                                    <p className="text-xs text-red-500 mt-1">Password tidak cocok</p>
                                )}
                            </div>
                        </div>
                        <div className="flex justify-end gap-2 mt-6">
                            <button
                                onClick={() => setShowChangePass(false)}
                                disabled={changingPass}
                                className="px-4 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50"
                            >
                                Batal
                            </button>
                            <button
                                onClick={handleChangePassword}
                                disabled={changingPass}
                                className="px-4 py-2 text-sm bg-teal-700 text-white rounded-lg hover:bg-teal-800 disabled:opacity-50 min-w-[120px]"
                            >
                                {changingPass ? 'Menyimpan...' : 'Simpan Password'}
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}