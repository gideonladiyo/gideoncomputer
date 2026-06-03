'use client'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Course } from '@/lib/types'
import { RotateCcw, Trash2, ArrowLeft } from 'lucide-react'
import Link from 'next/link'
import { toast } from '@/components/Toast'

export default function DeletedCoursesPage() {
    const [courses, setCourses] = useState<Course[]>([])
    const [loading, setLoading] = useState(true)
    const [deletingId, setDeletingId] = useState<string | null>(null)

    const fetchDeleted = async () => {
        const { data } = await supabase
            .from('courses')
            .select('*, categories(*)')
            .not('deleted_at', 'is', null)
            .order('deleted_at', { ascending: false })
        setCourses(data ?? [])
        setLoading(false)
    }

    useEffect(() => { fetchDeleted() }, [])

    const handleRestore = async (id: string, name: string) => {
        const { error } = await supabase
            .from('courses')
            .update({ deleted_at: null })
            .eq('id', id)
        if (error) { toast('Gagal memulihkan course'); return }
        toast(`Course "${name}" berhasil dipulihkan`)
        fetchDeleted()
    }

    const handleHardDelete = async (id: string, name: string) => {
        if (!confirm(`Hapus permanen course "${name}"?\n\nData ini tidak bisa dipulihkan lagi.`)) return
        setDeletingId(id)
        const { error } = await supabase.from('courses').delete().eq('id', id)
        setDeletingId(null)
        if (error) {
            toast(`Gagal: ${error.message}`)
            return
        }
        toast(`Course "${name}" dihapus permanen`)
        fetchDeleted()
    }

    return (
        <div>
            <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-3">
                    <Link href="/dashboard/courses" className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition">
                        <ArrowLeft size={18} />
                    </Link>
                    <div>
                        <h1 className="text-2xl font-bold text-gray-800">Deleted Courses</h1>
                        <p className="text-sm text-gray-500">Course yang sudah dihapus — bisa dipulihkan kapan saja</p>
                    </div>
                </div>
                <span className="text-sm text-gray-400">{courses.length} course</span>
            </div>

            {loading ? (
                <div className="text-center py-20 text-gray-400">Memuat...</div>
            ) : courses.length === 0 ? (
                <div className="text-center py-20">
                    <p className="text-gray-400 text-sm">Tidak ada course yang dihapus</p>
                    <Link href="/dashboard/courses" className="mt-3 inline-block text-sm text-teal-700 hover:underline">
                        ← Kembali ke daftar course
                    </Link>
                </div>
            ) : (
                <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                    <table className="w-full text-sm">
                        <thead className="bg-gray-50 text-gray-600">
                            <tr>
                                <th className="text-left px-4 py-3">Course</th>
                                <th className="text-left px-4 py-3">Kategori</th>
                                <th className="text-left px-4 py-3">Dihapus</th>
                                <th className="text-left px-4 py-3">Aksi</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {courses.map((course) => (
                                <tr key={course.id} className="hover:bg-gray-50 opacity-75">
                                    <td className="px-4 py-3">
                                        <div className="flex items-center gap-3">
                                            {course.course_image ? (
                                                <img src={course.course_image} className="w-10 h-10 rounded-lg object-cover grayscale" />
                                            ) : (
                                                <div className="w-10 h-10 rounded-lg bg-gray-100" />
                                            )}
                                            <div>
                                                <p className="font-medium text-gray-500 line-through">{course.course_name}</p>
                                                <p className="text-xs text-gray-400 truncate max-w-xs">{course.description}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-4 py-3 text-gray-400">
                                        {(course as any).categories?.category_name ?? '-'}
                                    </td>
                                    <td className="px-4 py-3 text-gray-400 text-xs">
                                        {(course as any).deleted_at
                                            ? new Date((course as any).deleted_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })
                                            : '-'}
                                    </td>
                                    <td className="px-4 py-3">
                                        <div className="flex items-center gap-2">
                                            <button
                                                onClick={() => handleRestore(course.id, course.course_name)}
                                                className="flex items-center gap-1.5 text-xs text-gray-500 hover:text-teal-700 border border-gray-200 hover:border-teal-300 px-2.5 py-1.5 rounded-lg transition"
                                            >
                                                <RotateCcw size={12} />
                                                Pulihkan
                                            </button>
                                            <button
                                                onClick={() => handleHardDelete(course.id, course.course_name)}
                                                disabled={deletingId === course.id}
                                                className="flex items-center gap-1.5 text-xs text-gray-500 hover:text-red-600 border border-gray-200 hover:border-red-300 px-2.5 py-1.5 rounded-lg transition disabled:opacity-50"
                                            >
                                                <Trash2 size={12} />
                                                {deletingId === course.id ? 'Menghapus...' : 'Hapus Permanen'}
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    )
}