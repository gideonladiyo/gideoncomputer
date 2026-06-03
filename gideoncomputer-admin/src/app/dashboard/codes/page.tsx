'use client'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { CourseCode, Course } from '@/lib/types'
import { Plus, Copy, Check } from 'lucide-react'
import { toast } from '@/components/Toast'

export default function CodesPage() {
    const [codes, setCodes] = useState<CourseCode[]>([])
    const [courses, setCourses] = useState<Pick<Course, 'id' | 'course_name'>[]>([])
    const [loading, setLoading] = useState(true)
    const [showGenerate, setShowGenerate] = useState(false)
    const [selectedCourse, setSelectedCourse] = useState('')
    const [quantity, setQuantity] = useState(5)
    const [prefix, setPrefix] = useState('')
    const [copiedId, setCopiedId] = useState<string | null>(null)
    const [filterUsed, setFilterUsed] = useState<'all' | 'used' | 'unused'>('all')

    const fetchCodes = async () => {
        const { data } = await supabase
            .from('course_codes')
            .select('*, courses(course_name), profiles(fullname, email)')
            .order('created_at', { ascending: false })
        setCodes(data ?? [])
        setLoading(false)
    }

    const fetchCourses = async () => {
        const { data } = await supabase.from('courses').select('id, course_name')
        setCourses(data ?? [])
    }

    useEffect(() => {
        fetchCodes()
        fetchCourses()
    }, [])

    const generateCode = () => {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        return Array.from({ length: 6 }, () =>
            chars[Math.floor(Math.random() * chars.length)]
        ).join('')
    }

    const handleGenerate = async () => {
        if (!selectedCourse) return
        const p = prefix.toUpperCase().replace(/[^A-Z0-9]/g, '') || 'CODE'
        const newCodes = Array.from({ length: quantity }, () => ({
            course_id: selectedCourse,
            code: `${p}-${generateCode()}`,
        }))
        await supabase.from('course_codes').insert(newCodes)
        toast(`${quantity} kode berhasil digenerate`)
        setShowGenerate(false)
        fetchCodes()
    }

    const copyCode = (code: string, id: string) => {
        navigator.clipboard.writeText(code)
        setCopiedId(id)
        setTimeout(() => setCopiedId(null), 2000)
    }

    const filtered = codes.filter((c) => {
        if (filterUsed === 'used') return c.used_by !== null
        if (filterUsed === 'unused') return c.used_by === null
        return true
    })

    return (
        <div>
            <div className="flex items-center justify-between mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Kode Course</h1>
                    <p className="text-sm text-gray-500">Generate dan kelola kode akses course</p>
                </div>
                <button
                    onClick={() => setShowGenerate(true)}
                    className="flex items-center gap-2 bg-teal-700 text-white px-4 py-2 rounded-lg text-sm hover:bg-teal-800 transition"
                >
                    <Plus size={16} /> Generate Kode
                </button>
            </div>

            {/* Filter */}
            <div className="flex gap-2 mb-4">
                {(['all', 'unused', 'used'] as const).map((f) => (
                    <button
                        key={f}
                        onClick={() => setFilterUsed(f)}
                        className={`px-3 py-1.5 rounded-lg text-sm transition ${filterUsed === f
                            ? 'bg-teal-700 text-white'
                            : 'bg-white border border-gray-200 text-gray-600 hover:bg-gray-50'
                            }`}
                    >
                        {f === 'all' ? 'Semua' : f === 'unused' ? 'Belum dipakai' : 'Sudah dipakai'}
                    </button>
                ))}
                <span className="ml-auto text-sm text-gray-400 self-center">
                    {filtered.length} kode
                </span>
            </div>

            {loading ? (
                <div className="text-center py-20 text-gray-400">Memuat...</div>
            ) : (
                <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                    <table className="w-full text-sm">
                        <thead className="bg-gray-50 text-gray-600">
                            <tr>
                                <th className="text-left px-4 py-3">Kode</th>
                                <th className="text-left px-4 py-3">Course</th>
                                <th className="text-left px-4 py-3">Status</th>
                                <th className="text-left px-4 py-3">Dipakai Oleh</th>
                                <th className="text-left px-4 py-3">Tanggal</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {filtered.map((code) => (
                                <tr key={code.id} className="hover:bg-gray-50">
                                    <td className="px-4 py-3">
                                        <div className="flex items-center gap-2">
                                            <span className="font-mono font-medium text-gray-800">{code.code}</span>
                                            <button
                                                onClick={() => copyCode(code.code, code.id)}
                                                className="p-1 text-gray-400 hover:text-teal-600 transition"
                                            >
                                                {copiedId === code.id ? <Check size={14} className="text-green-500" /> : <Copy size={14} />}
                                            </button>
                                        </div>
                                    </td>
                                    <td className="px-4 py-3 text-gray-600">
                                        {(code.courses as any)?.course_name ?? '-'}
                                    </td>
                                    <td className="px-4 py-3">
                                        <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${code.used_by !== null
                                            ? 'bg-red-50 text-red-600'
                                            : 'bg-green-50 text-green-700'
                                            }`}>
                                            {code.used_by !== null ? 'Dipakai' : 'Tersedia'}
                                        </span>
                                    </td>
                                    <td className="px-4 py-3 text-gray-500 text-xs">
                                        {(code.profiles as any)?.fullname ?? '-'}
                                    </td>
                                    <td className="px-4 py-3 text-gray-400 text-xs">
                                        {code.used_at
                                            ? new Date(code.used_at).toLocaleDateString('id-ID')
                                            : new Date(code.created_at).toLocaleDateString('id-ID')}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}

            {/* Modal Generate */}
            {showGenerate && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl">
                        <h2 className="text-lg font-bold mb-4">Generate Kode Course</h2>
                        <div className="space-y-4">
                            <div>
                                <label className="text-sm font-medium text-gray-700">Course</label>
                                <select
                                    value={selectedCourse}
                                    onChange={(e) => {
                                        setSelectedCourse(e.target.value)
                                        const course = courses.find((c) => c.id === e.target.value)
                                        if (course) {
                                            setPrefix(
                                                course.course_name.split(' ')[0].toUpperCase().slice(0, 8)
                                            )
                                        }
                                    }}
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                >
                                    <option value="">Pilih course</option>
                                    {courses.map((c) => (
                                        <option key={c.id} value={c.id}>{c.course_name}</option>
                                    ))}
                                </select>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Prefix Kode</label>
                                <input
                                    type="text"
                                    value={prefix}
                                    onChange={(e) => setPrefix(e.target.value.toUpperCase())}
                                    placeholder="Contoh: FLUTTER"
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                />
                                <p className="text-xs text-gray-400 mt-1">
                                    Kode akan dibuat: <span className="font-mono">{prefix || 'CODE'}-XXXXXX</span>
                                </p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Jumlah Kode</label>
                                <input
                                    type="number"
                                    min={1}
                                    max={100}
                                    value={quantity}
                                    onChange={(e) => setQuantity(+e.target.value)}
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                />
                            </div>
                        </div>
                        <div className="flex justify-end gap-2 mt-6">
                            <button
                                onClick={() => setShowGenerate(false)}
                                className="px-4 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50"
                            >
                                Batal
                            </button>
                            <button
                                onClick={handleGenerate}
                                disabled={!selectedCourse}
                                className="px-4 py-2 text-sm bg-teal-700 text-white rounded-lg hover:bg-teal-800 disabled:opacity-50"
                            >
                                Generate
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}