'use client'
import { useState } from 'react'
import { supabase } from '@/lib/supabase'
import { useRouter } from 'next/navigation'

export default function LoginPage() {
    const router = useRouter()
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const [error, setError] = useState('')
    const [loading, setLoading] = useState(false)

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault()
        setLoading(true)
        setError('')

        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
        })

        console.log('AUTH RESULT:', { data, error })

        if (error) {
            setError(error.message)
            setLoading(false)
            return
        }

        // Cek role admin
        const { data: profile } = await supabase
            .from('profiles')
            .select('role')
            .eq('id', data.user.id)
            .single()
        
        console.log('PROFILE:', profile)

        if (profile?.role !== 'admin') {
            setError('Akses ditolak. Hanya admin yang bisa masuk.')
            await supabase.auth.signOut()
            setLoading(false)
            return
        }

        window.location.href = '/dashboard'
    }

    return (
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
            <div className="bg-white p-8 rounded-2xl shadow-sm w-full max-w-sm">
                <div className="text-center mb-8">
                    <div className="w-12 h-12 bg-teal-700 rounded-xl mx-auto mb-4 flex items-center justify-center">
                        <span className="text-white font-bold text-lg">GC</span>
                    </div>
                    <h1 className="text-xl font-bold text-gray-800">Admin Panel</h1>
                    <p className="text-sm text-gray-500 mt-1">Gideon Computer LMS</p>
                </div>

                <form onSubmit={handleLogin} className="space-y-4">
                    <div>
                        <label className="text-sm font-medium text-gray-700">Email</label>
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                            placeholder="admin@email.com"
                            required
                        />
                    </div>
                    <div>
                        <label className="text-sm font-medium text-gray-700">Password</label>
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                            placeholder="••••••••"
                            required
                        />
                    </div>

                    {error && (
                        <p className="text-red-500 text-sm bg-red-50 px-3 py-2 rounded-lg">
                            {error}
                        </p>
                    )}

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full bg-teal-700 text-white py-2.5 rounded-lg font-medium hover:bg-teal-800 disabled:opacity-50 transition"
                    >
                        {loading ? 'Masuk...' : 'Masuk'}
                    </button>
                </form>
            </div>
        </div>
    )
}