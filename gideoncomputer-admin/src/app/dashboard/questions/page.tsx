'use client'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Course, Assessment, Question, QuestionOption } from '@/lib/types'
import { Plus, Pencil, Trash2, ChevronRight, Check, X } from 'lucide-react'
import { toast } from '@/components/Toast'

// ─── Types ────────────────────────────────────────────────────
type AssessmentWithSection = Assessment & { sections?: { section_name: string; course_id: string } | null }
type QuestionWithOptions = Question & { question_options: QuestionOption[] }
type OptionForm = { option_text: string; is_correct: boolean }
type QuestionForm = {
    question_text: string
    question_type: string
    options: OptionForm[]
}

const emptyForm = (): QuestionForm => ({
    question_text: '',
    question_type: 'multiple_choice',
    options: [
        { option_text: '', is_correct: true },
        { option_text: '', is_correct: false },
        { option_text: '', is_correct: false },
        { option_text: '', is_correct: false },
    ],
})

// ─── Modal Form ───────────────────────────────────────────────
function QuestionFormModal({
    editTarget,
    initialForm,
    onClose,
    onSubmit,
}: {
    editTarget: QuestionWithOptions | null
    initialForm: QuestionForm
    onClose: () => void
    onSubmit: (form: QuestionForm) => Promise<void>
}) {
    const [form, setForm] = useState<QuestionForm>(initialForm)
    const [saving, setSaving] = useState(false)

    const setOptionCorrect = (idx: number) => {
        setForm((f) => ({
            ...f,
            options: f.options.map((o, i) => ({ ...o, is_correct: i === idx })),
        }))
    }

    const handleSubmit = async () => {
        if (saving) return
        const hasCorrect = form.options.some((o) => o.is_correct)
        if (!hasCorrect) { alert('Pilih minimal 1 jawaban benar.'); return }
        if (!form.question_text.trim()) { alert('Teks soal tidak boleh kosong.'); return }
        setSaving(true)
        try {
            await onSubmit(form)
        } finally {
            setSaving(false)
        }
    }

    return (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-2xl p-6 w-full max-w-xl shadow-xl max-h-[90vh] overflow-y-auto">
                <h2 className="text-lg font-bold mb-4">{editTarget ? 'Edit Soal' : 'Tambah Soal'}</h2>

                <div className="space-y-4">
                    <div>
                        <label className="text-sm font-medium text-gray-700">Teks Soal</label>
                        <textarea
                            value={form.question_text}
                            onChange={(e) => setForm((f) => ({ ...f, question_text: e.target.value }))}
                            rows={3}
                            className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                            placeholder="Tulis pertanyaan di sini..."
                        />
                    </div>

                    <div>
                        <label className="text-sm font-medium text-gray-700 mb-2 block">
                            Pilihan Jawaban <span className="text-gray-400 font-normal">(klik radio untuk tandai jawaban benar)</span>
                        </label>
                        <div className="space-y-2">
                            {form.options.map((opt, idx) => (
                                <div key={idx} className="flex items-center gap-2">
                                    <button
                                        type="button"
                                        onClick={() => setOptionCorrect(idx)}
                                        className={`w-5 h-5 rounded-full border-2 shrink-0 flex items-center justify-center transition ${opt.is_correct
                                                ? 'border-teal-600 bg-teal-600'
                                                : 'border-gray-300 hover:border-teal-400'
                                            }`}
                                    >
                                        {opt.is_correct && <div className="w-2 h-2 bg-white rounded-full" />}
                                    </button>
                                    <input
                                        type="text"
                                        value={opt.option_text}
                                        onChange={(e) => {
                                            const val = e.target.value
                                            setForm((f) => {
                                                const updated = [...f.options]
                                                updated[idx] = { ...updated[idx], option_text: val }
                                                return { ...f, options: updated }
                                            })
                                        }}
                                        placeholder={`Opsi ${idx + 1}`}
                                        className="flex-1 border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                                    />
                                </div>
                            ))}
                        </div>
                    </div>
                </div>

                <div className="flex justify-end gap-2 mt-6">
                    <button
                        onClick={onClose}
                        className="px-4 py-2 text-sm border border-gray-300 rounded-lg hover:bg-gray-50"
                    >
                        Batal
                    </button>
                    <button
                        onClick={handleSubmit}
                        disabled={saving}
                        className="px-4 py-2 text-sm bg-teal-700 text-white rounded-lg hover:bg-teal-800 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {saving ? 'Menyimpan...' : 'Simpan'}
                    </button>
                </div>
            </div>
        </div>
    )
}

// ─── Main Page ────────────────────────────────────────────────
export default function QuestionsPage() {
    const [step, setStep] = useState<'course' | 'source' | 'questions'>('course')

    const [courses, setCourses] = useState<Course[]>([])
    const [selectedCourse, setSelectedCourse] = useState<Course | null>(null)

    const [quizzes, setQuizzes] = useState<AssessmentWithSection[]>([])
    const [exams, setExams] = useState<AssessmentWithSection[]>([])
    const [selectedSource, setSelectedSource] = useState<{ type: 'quiz' | 'exam'; id: string; name: string } | null>(null)

    const [questions, setQuestions] = useState<QuestionWithOptions[]>([])
    const [loadingQ, setLoadingQ] = useState(false)

    const [showForm, setShowForm] = useState(false)
    const [editTarget, setEditTarget] = useState<QuestionWithOptions | null>(null)

    // ── Step 1: Load courses ──────────────────────────────────
    useEffect(() => {
        const fetchCourses = async () => {
            const { data } = await supabase
                .from('courses')
                .select('*')
                .order('course_name')
            setCourses((data as Course[]) ?? [])
        }
        fetchCourses()
    }, [])

    const selectCourse = async (course: Course) => {
        setSelectedCourse(course)

        // Fetch quiz assessments (linked via section → course)
        const { data: qData } = await supabase
            .from('assessments')
            .select('*, sections(section_name, course_id)')
            .eq('assessment_type', 'quiz')
            .eq('sections.course_id', course.id)

        // Fetch exam assessments (linked directly to course)
        const { data: eData } = await supabase
            .from('assessments')
            .select('*')
            .eq('assessment_type', 'exam')
            .eq('course_id', course.id)

        const filteredQuizzes = ((qData as AssessmentWithSection[]) ?? []).filter(
            (q) => q.sections?.course_id === course.id
        )
        setQuizzes(filteredQuizzes)
        setExams((eData as AssessmentWithSection[]) ?? [])
        setStep('source')
    }

    // ── Step 2: Pilih Assessment ──────────────────────────────
    const selectSource = async (type: 'quiz' | 'exam', id: string, name: string) => {
        setSelectedSource({ type, id, name })
        setLoadingQ(true)
        setStep('questions')

        const { data } = await supabase
            .from('questions')
            .select('*, question_options(*)')
            .eq('assessment_id', id)
            .order('created_at')

        setQuestions((data as QuestionWithOptions[]) ?? [])
        setLoadingQ(false)
    }

    // ── CRUD Soal ─────────────────────────────────────────────
    const openAdd = () => {
        setEditTarget(null)
        setShowForm(true)
    }

    const openEdit = (q: QuestionWithOptions) => {
        setEditTarget(q)
        setShowForm(true)
    }

    const handleFormSubmit = async (form: QuestionForm) => {
        if (!selectedSource) return

        if (editTarget) {
            const { error: updateErr } = await supabase
                .from('questions')
                .update({ question_text: form.question_text, question_type: form.question_type })
                .eq('id', editTarget.id)

            if (updateErr) { toast('Gagal memperbarui soal', 'error'); return }

            const existingOptions = editTarget.question_options
            const newOptions = form.options

            for (let i = 0; i < existingOptions.length; i++) {
                const existing = existingOptions[i]
                const updated = newOptions[i]
                if (!updated) continue

                const { error } = await supabase
                    .from('question_options')
                    .update({
                        option_text: updated.option_text,
                        is_correct: updated.is_correct,
                    })
                    .eq('id', existing.id)

                if (error) { toast('Gagal memperbarui opsi', 'error'); return }
            }

            const extraNew = newOptions.slice(existingOptions.length)
            if (extraNew.length > 0) {
                const { error } = await supabase
                    .from('question_options')
                    .insert(extraNew.map((o) => ({ ...o, question_id: editTarget.id })))
                if (error) { toast('Gagal menambahkan opsi baru', 'error'); return }
            }

            const extraOld = existingOptions.slice(newOptions.length)
            if (extraOld.length > 0) {
                const { error } = await supabase
                    .from('question_options')
                    .delete()
                    .in('id', extraOld.map((o) => o.id))
                if (error) { toast('Gagal menghapus opsi lama', 'error'); return }
            }

            toast('Soal berhasil diperbarui')
        } else {
            const { data: newQ, error: insertQErr } = await supabase
                .from('questions')
                .insert({
                    question_text: form.question_text,
                    question_type: form.question_type,
                    assessment_id: selectedSource.id,
                })
                .select()
                .single()

            if (insertQErr || !newQ) { toast('Gagal menambahkan soal', 'error'); return }

            const { error: insertOptErr } = await supabase
                .from('question_options')
                .insert(form.options.map((o) => ({ ...o, question_id: (newQ as Question).id })))

            if (insertOptErr) { toast('Gagal menyimpan opsi', 'error'); return }

            toast('Soal berhasil ditambahkan')
        }

        setShowForm(false)
        selectSource(selectedSource.type, selectedSource.id, selectedSource.name)
    }

    const handleDelete = async (q: QuestionWithOptions) => {
        if (!confirm(`Hapus soal "${q.question_text}"?`)) return
        await supabase.from('question_options').delete().eq('question_id', q.id)
        await supabase.from('questions').delete().eq('id', q.id)
        setQuestions((prev) => prev.filter((x) => x.id !== q.id))
        toast('Soal berhasil dihapus')
    }

    // ── Render ────────────────────────────────────────────────
    return (
        <div>
            {/* Breadcrumb */}
            <div className="flex items-center gap-2 text-sm text-gray-400 mb-1">
                <button onClick={() => setStep('course')} className="hover:text-teal-700">Course</button>
                {step !== 'course' && (
                    <>
                        <ChevronRight size={14} />
                        <button onClick={() => setStep('source')} className="hover:text-teal-700">
                            {selectedCourse?.course_name}
                        </button>
                    </>
                )}
                {step === 'questions' && (
                    <>
                        <ChevronRight size={14} />
                        <span className="text-gray-600 font-medium">{selectedSource?.name}</span>
                    </>
                )}
            </div>

            <div className="flex items-center justify-between mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Soal Quiz & Exam</h1>
                    <p className="text-sm text-gray-500">
                        {step === 'course' && 'Pilih course untuk melihat soalnya'}
                        {step === 'source' && `Pilih quiz atau exam dari ${selectedCourse?.course_name}`}
                        {step === 'questions' && `${questions.length} soal · ${selectedSource?.name}`}
                    </p>
                </div>
                {step === 'questions' && (
                    <button
                        onClick={openAdd}
                        className="flex items-center gap-2 bg-teal-700 text-white px-4 py-2 rounded-lg text-sm hover:bg-teal-800 transition"
                    >
                        <Plus size={16} /> Tambah Soal
                    </button>
                )}
            </div>

            {/* Step 1: Pilih Course */}
            {step === 'course' && (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    {courses.map((c) => (
                        <button
                            key={c.id}
                            onClick={() => selectCourse(c)}
                            className="bg-white border border-gray-200 rounded-xl p-4 text-left hover:border-teal-500 hover:shadow-sm transition group"
                        >
                            <div className="flex items-center gap-3">
                                {c.course_image && (
                                    <img src={c.course_image} className="w-12 h-12 rounded-lg object-cover" />
                                )}
                                <div>
                                    <p className="font-semibold text-gray-800 group-hover:text-teal-700">{c.course_name}</p>
                                    <p className="text-xs text-gray-400 mt-0.5 line-clamp-1">{c.description}</p>
                                </div>
                            </div>
                        </button>
                    ))}
                </div>
            )}

            {/* Step 2: Pilih Assessment */}
            {step === 'source' && (
                <div className="space-y-6">
                    {quizzes.length > 0 && (
                        <div>
                            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">Quiz per Section</p>
                            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                                {quizzes.map((q) => (
                                    <button
                                        key={q.id}
                                        onClick={() => selectSource('quiz', q.id, q.assessment_name)}
                                        className="bg-white border border-gray-200 rounded-xl p-4 text-left hover:border-teal-500 hover:shadow-sm transition group"
                                    >
                                        <p className="font-semibold text-gray-800 group-hover:text-teal-700">{q.assessment_name}</p>
                                        <p className="text-xs text-gray-400 mt-1">Section: {q.sections?.section_name ?? '-'}</p>
                                        <p className="text-xs text-gray-400">Nilai lulus: {q.passing_score}</p>
                                    </button>
                                ))}
                            </div>
                        </div>
                    )}

                    {exams.length > 0 && (
                        <div>
                            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">Final Exam</p>
                            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                                {exams.map((e) => (
                                    <button
                                        key={e.id}
                                        onClick={() => selectSource('exam', e.id, e.assessment_name)}
                                        className="bg-white border border-gray-200 rounded-xl p-4 text-left hover:border-purple-400 hover:shadow-sm transition group"
                                    >
                                        <p className="font-semibold text-gray-800 group-hover:text-purple-700">{e.assessment_name}</p>
                                        <p className="text-xs text-gray-400 mt-1">Nilai lulus: {e.passing_score}</p>
                                        <span className="text-xs bg-purple-50 text-purple-700 px-2 py-0.5 rounded-full mt-2 inline-block">Final Exam</span>
                                    </button>
                                ))}
                            </div>
                        </div>
                    )}

                    {quizzes.length === 0 && exams.length === 0 && (
                        <div className="text-center py-20 text-gray-400">
                            Belum ada quiz atau exam untuk course ini.
                        </div>
                    )}
                </div>
            )}

            {/* Step 3: List Soal */}
            {step === 'questions' && (
                <div>
                    {loadingQ ? (
                        <div className="text-center py-20 text-gray-400">Memuat soal...</div>
                    ) : questions.length === 0 ? (
                        <div className="text-center py-20 text-gray-400">
                            Belum ada soal. Klik &quot;Tambah Soal&quot; untuk mulai.
                        </div>
                    ) : (
                        <div className="space-y-4">
                            {questions.map((q, idx) => (
                                <div key={q.id} className="bg-white border border-gray-200 rounded-xl p-5">
                                    <div className="flex items-start justify-between gap-4">
                                        <div className="flex-1">
                                            <p className="text-xs text-gray-400 mb-1">Soal {idx + 1}</p>
                                            <p className="font-medium text-gray-800">{q.question_text}</p>
                                            <div className="mt-3 grid grid-cols-1 sm:grid-cols-2 gap-2">
                                                {q.question_options.map((opt) => (
                                                    <div
                                                        key={opt.id}
                                                        className={`flex items-center gap-2 px-3 py-2 rounded-lg text-sm border ${opt.is_correct
                                                                ? 'bg-teal-50 border-teal-300 text-teal-800 font-medium'
                                                                : 'bg-gray-50 border-gray-200 text-gray-600'
                                                            }`}
                                                    >
                                                        {opt.is_correct
                                                            ? <Check size={14} className="text-teal-600 shrink-0" />
                                                            : <X size={14} className="text-gray-300 shrink-0" />
                                                        }
                                                        {opt.option_text}
                                                    </div>
                                                ))}
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-1 shrink-0">
                                            <button
                                                onClick={() => openEdit(q)}
                                                className="p-1.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition"
                                            >
                                                <Pencil size={15} />
                                            </button>
                                            <button
                                                onClick={() => handleDelete(q)}
                                                className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition"
                                            >
                                                <Trash2 size={15} />
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            )}

            {/* Modal Form */}
            {showForm && (
                <QuestionFormModal
                    editTarget={editTarget}
                    initialForm={
                        editTarget
                            ? {
                                question_text: editTarget.question_text,
                                question_type: editTarget.question_type,
                                options: editTarget.question_options.map((o) => ({
                                    option_text: o.option_text,
                                    is_correct: o.is_correct,
                                })),
                            }
                            : emptyForm()
                    }
                    onClose={() => setShowForm(false)}
                    onSubmit={handleFormSubmit}
                />
            )}
        </div>
    )
}
