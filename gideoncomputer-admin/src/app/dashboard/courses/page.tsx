'use client'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Course, Category } from '@/lib/types'
import { Plus, Pencil, Trash2, ChevronRight, Trash } from 'lucide-react'
import Link from 'next/link'
import { toast } from '@/components/Toast'

export default function CoursesPage() {
    const [courses, setCourses] = useState<Course[]>([])
    const [categories, setCategories] = useState<Category[]>([])
    const [loading, setLoading] = useState(true)
    const [showForm, setShowForm] = useState(false)
    const [editTarget, setEditTarget] = useState<Course | null>(null)
    const [form, setForm] = useState({
        course_name: '', course_image: '', description: '', category_id: ''
    })

    const fetchCourses = async () => {
        const { data } = await supabase
            .from('courses')
            .select('*, categories(*)')
            .is('deleted_at', null)
            .order('created_at', { ascending: false })
        setCourses(data ?? [])
        setLoading(false)
    }

    const fetchCategories = async () => {
        const { data, error } = await supabase.from('categories').select('*')
        if (error) { toast('Gagal memuat kategori'); return }
        setCategories(data ?? [])
    }

    useEffect(() => { fetchCourses(); fetchCategories() }, [])

    const openAdd = () => {
        setEditTarget(null)
        setForm({ course_name: '', course_image: '', description: '', category_id: '' })
        setShowForm(true)
    }

    const openEdit = (course: Course) => {
        setEditTarget(course)
        setForm({ course_name: course.course_name, course_image: course.course_image, description: course.description, category_id: course.category_id })
        setShowForm(true)
    }

    const handleSubmit = async () => {
        if (editTarget) {
            await supabase.from('courses').update(form).eq('id', editTarget.id)
            toast('Course berhasil diperbarui')
        } else {
            await supabase.from('courses').insert(form)
            toast('Course berhasil ditambahkan')
        }
        setShowForm(false)
        fetchCourses()
    }

    const handleDelete = async (id: string, name: string) => {
        if (!confirm(`Hapus course "${name}"?\nCourse bisa dipulihkan dari halaman Deleted Courses.`)) return
        const { error } = await supabase
            .from('courses')
            .update({ deleted_at: new Date().toISOString() })
            .eq('id', id)
        if (error) { toast('Gagal menghapus course'); return }
        toast('Course dipindahkan ke Deleted Courses')
        fetchCourses()
    }

    return (
        <div>
            <div className="flex items-center justify-between mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Course</h1>
                    <p className="text-sm text-gray-500">Kelola semua course yang tersedia</p>
                </div>
                <div className="flex items-center gap-3">
                    <Link href="/dashboard/courses/deleted" className="flex items-center gap-2 border border-gray-300 text-gray-600 px-4 py-2 rounded-lg text-sm hover:bg-gray-50 transition">
                        <Trash size={15} /> Deleted Courses
                    </Link>
                    <button onClick={openAdd} className="flex items-center gap-2 bg-teal-700 text-white px-4 py-2 rounded-lg text-sm hover:bg-teal-800 transition">
                        <Plus size={16} /> Tambah Course
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
                                <th className="text-left px-4 py-3">Course</th>
                                <th className="text-left px-4 py-3">Kategori</th>
                                <th className="text-left px-4 py-3">Aksi</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {courses.map((course) => (
                                <tr key={course.id} className="hover:bg-gray-50">
                                    <td className="px-4 py-3">
                                        <div className="flex items-center gap-3">
                                            {course.course_image && (
                                                <img src={course.course_image} className="w-10 h-10 rounded-lg object-cover" />
                                            )}
                                            <div>
                                                <p className="font-medium text-gray-800">{course.course_name}</p>
                                                <p className="text-xs text-gray-400 truncate max-w-xs">{course.description}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-4 py-3 text-gray-600">{(course as any).categories?.category_name ?? '-'}</td>
                                    <td className="px-4 py-3">
                                        <div className="flex items-center gap-2">
                                            <Link href={`/dashboard/courses/${course.id}`} className="p-1.5 text-gray-500 hover:text-teal-700 hover:bg-teal-50 rounded-lg transition">
                                                <ChevronRight size={16} />
                                            </Link>
                                            <button onClick={() => openEdit(course)} className="p-1.5 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition">
                                                <Pencil size={16} />
                                            </button>
                                            <button onClick={() => handleDelete(course.id, course.course_name)} className="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition">
                                                <Trash2 size={16} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                    {courses.length === 0 && (
                        <div className="text-center py-16 text-gray-400">Belum ada course</div>
                    )}
                </div>
            )}

            {showForm && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-lg shadow-xl">
                        <h2 className="text-lg font-bold mb-4">{editTarget ? 'Edit Course' : 'Tambah Course'}</h2>
                        <div className="space-y-3">
                            {[
                                { key: 'course_name', label: 'Nama Course', type: 'text' },
                                { key: 'course_image', label: 'URL Gambar', type: 'text' },
                            ].map(({ key, label, type }) => (
                                <div key={key}>
                                    <label className="text-sm font-medium text-gray-700">{label}</label>
                                    <input type={type} value={(form as any)[key]} onChange={(e) => setForm({ ...form, [key]: e.target.value })} className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
                                </div>
                            ))}
                            <div>
                                <label className="text-sm font-medium text-gray-700">Deskripsi</label>
                                <textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} rows={3} className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Kategori</label>
                                <select value={form.category_id} onChange={(e) => setForm({ ...form, category_id: e.target.value })} className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600">
                                    <option value="">Pilih kategori</option>
                                    {categories.map((c) => (<option key={c.id} value={c.id}>{c.category_name}</option>))}
                                </select>
                            </div>
                        </div>
                        <div className="flex justify-end gap-2 mt-6">
                            <button onClick={() => setShowForm(false)} className="px-4 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50">Batal</button>
                            <button onClick={handleSubmit} className="px-4 py-2 text-sm bg-teal-700 text-white rounded-lg hover:bg-teal-800">Simpan</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}