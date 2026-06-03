'use client'
import { useEffect, useState, useRef } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { Course, Section, Material, Assessment } from '@/lib/types'
import {
    Plus, Pencil, Trash2, ChevronLeft, ChevronDown, ChevronUp,
    GripVertical, Video, FileText, HelpCircle, BookOpen, Check, X,
    Bold, Italic, List, Heading3, Eye, Edit2
} from 'lucide-react'
import { toast } from '@/components/Toast'

// ─── Types ─────────────────────────────────────────────────────
type SectionWithMaterials = Section & { materials: Material[]; quiz?: Assessment }
type QuestionOption = { option_text: string; is_correct: boolean }
type QuestionForm = { question_text: string; options: QuestionOption[] }

const emptyQuestion = (): QuestionForm => ({
    question_text: '',
    options: [
        { option_text: '', is_correct: true },
        { option_text: '', is_correct: false },
        { option_text: '', is_correct: false },
        { option_text: '', is_correct: false },
    ],
})

const MATERIAL_TYPES = [
    { value: 'video', label: 'Video', icon: Video },
    { value: 'slide', label: 'Slide/PDF', icon: FileText },
    { value: 'quiz', label: 'Quiz', icon: HelpCircle },
]

// ─── Main Page ──────────────────────────────────────────────────
export default function CourseDetailPage() {
    const { id } = useParams<{ id: string }>()
    const router = useRouter()

    const [course, setCourse] = useState<Course | null>(null)
    const [sections, setSections] = useState<SectionWithMaterials[]>([])
    const [exam, setExam] = useState<Assessment | null>(null)
    const [loading, setLoading] = useState(true)
    const [expandedSections, setExpandedSections] = useState<Set<string>>(new Set())

    // ── Section modal
    const [sectionModal, setSectionModal] = useState(false)
    const [sectionEdit, setSectionEdit] = useState<Section | null>(null)
    const [sectionName, setSectionName] = useState('')

    // ── Material modal
    const [materialModal, setMaterialModal] = useState(false)
    const [materialEdit, setMaterialEdit] = useState<Material | null>(null)
    const [targetSectionId, setTargetSectionId] = useState('')
    const [materialForm, setMaterialForm] = useState({ material_name: '', material_type: 'video', material_url: '', description: '', position: 1 })

    // ── Quiz modal (saat material_type = 'quiz')
    const [quizModal, setQuizModal] = useState(false)
    const [quizSection, setQuizSection] = useState<SectionWithMaterials | null>(null)
    const [quizForm, setQuizForm] = useState({ assessment_name: '', passing_score: 70 })
    const [quizQuestions, setQuizQuestions] = useState<QuestionForm[]>([emptyQuestion()])

    // ── Exam modal
    const [examModal, setExamModal] = useState(false)
    const [examForm, setExamForm] = useState({ assessment_name: '', passing_score: 80 })
    const [examQuestions, setExamQuestions] = useState<QuestionForm[]>([emptyQuestion()])

    // ── Markdown helpers
    const textareaRef = useRef<HTMLTextAreaElement>(null)
    const [descTab, setDescTab] = useState<'write' | 'preview'>('write')

    const insertMarkdown = (syntax: string) => {
        const textarea = textareaRef.current
        if (!textarea) return

        const start = textarea.selectionStart
        const end = textarea.selectionEnd
        const text = textarea.value
        const selectedText = text.substring(start, end)
        
        let replacement = ''
        if (syntax === 'bold') {
            replacement = `**${selectedText || 'teks-tebal'}**`
        } else if (syntax === 'italic') {
            replacement = `*${selectedText || 'teks-miring'}*`
        } else if (syntax === 'list') {
            replacement = `\n- ${selectedText || 'item-daftar'}`
        } else if (syntax === 'header') {
            replacement = `### ${selectedText || 'Header'}`
        }

        const newValue = text.substring(0, start) + replacement + text.substring(end)
        setMaterialForm({ ...materialForm, description: newValue })

        setTimeout(() => {
            textarea.focus()
            const cursorOffset = replacement.length - (selectedText.length ? 0 : 2)
            textarea.setSelectionRange(start + cursorOffset, start + cursorOffset)
        }, 0)
    }

    const renderMarkdownPreview = (text: string) => {
        if (!text) return <p className="text-gray-400 text-xs italic">Belum ada deskripsi.</p>;
        let html = text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");
        
        html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
        html = html.replace(/^### (.*?)$/gm, '<h3 class="text-base font-bold my-2 text-teal-800">$1</h3>');
        html = html.replace(/^- (.*?)$/gm, '<li class="ml-4 list-disc text-gray-700">$1</li>');
        html = html.replace(/\n/g, '<br />');

        return <div dangerouslySetInnerHTML={{ __html: html }} className="text-sm border border-gray-200 rounded-lg p-3 bg-gray-50 max-h-40 overflow-y-auto min-h-[80px]" />
    }

    // ─── Fetch ──────────────────────────────────────────────────
    const fetchAll = async () => {
        setLoading(true)
        const { data: c } = await supabase.from('courses').select('*, categories(*)').eq('id', id).single()
        setCourse(c as Course)

        const { data: s } = await supabase
            .from('sections')
            .select('*, materials(*), assessments(*)')
            .eq('course_id', id)
            .order('created_at')
        const mapped = ((s ?? []) as any[]).map((sec) => ({
            ...sec,
            materials: (sec.materials ?? []).sort((a: Material, b: Material) => a.position - b.position),
            quiz: sec.quizzes?.[0] ?? undefined,
        }))
        setSections(mapped)
        setExpandedSections(new Set(mapped.map((s: Section) => s.id)))

        const { data: e } = await supabase.from('assessments').select('*').eq('assessment_type', 'exam').eq('course_id', id).maybeSingle()
        setExam(e as Assessment ?? null)

        setLoading(false)
    }

    useEffect(() => { fetchAll() }, [id])

    const toggleSection = (id: string) =>
        setExpandedSections(prev => {
            const n = new Set(prev)
            n.has(id) ? n.delete(id) : n.add(id)
            return n
        })

    // ─── Section CRUD ───────────────────────────────────────────
    const openAddSection = () => { setSectionEdit(null); setSectionName(''); setSectionModal(true) }
    const openEditSection = (s: Section) => { setSectionEdit(s); setSectionName(s.section_name); setSectionModal(true) }

    const submitSection = async () => {
        if (!sectionName.trim()) return
        if (sectionEdit) {
            await supabase.from('sections').update({ section_name: sectionName }).eq('id', sectionEdit.id)
            toast('Section berhasil diperbarui')
        } else {
            await supabase.from('sections').insert({ course_id: id, section_name: sectionName })
            toast('Section berhasil ditambahkan')
        }
        setSectionModal(false)
        fetchAll()
    }

    const deleteSection = async (sectionId: string) => {
        if (!confirm('Hapus section ini beserta semua materinya?')) return
        await supabase.from('materials').delete().eq('section_id', sectionId)
        await supabase.from('sections').delete().eq('id', sectionId)
        toast('Section berhasil dihapus')
        fetchAll()
    }

    // ─── Material CRUD ──────────────────────────────────────────
    const openAddMaterial = (sectionId: string, position: number) => {
        setMaterialEdit(null)
        setTargetSectionId(sectionId)
        setMaterialForm({ material_name: '', material_type: 'video', material_url: '', description: '', position })
        setMaterialModal(true)
    }

    const openEditMaterial = (m: Material, sectionId: string) => {
        setMaterialEdit(m)
        setTargetSectionId(sectionId)
        setMaterialForm({ material_name: m.material_name, material_type: m.material_type, material_url: m.material_url ?? '', description: m.description ?? '', position: m.position })
        setMaterialModal(true)
    }

    const submitMaterial = async () => {
        if (!materialForm.material_name.trim()) return

        // Kalau tipe quiz → buka quiz modal
        if (materialForm.material_type === 'quiz' && !materialEdit) {
            const sec = sections.find(s => s.id === targetSectionId) ?? null
            toast(materialEdit ? 'Materi berhasil diperbarui' : 'Materi berhasil ditambahkan')
            setMaterialModal(false)
            setQuizSection(sec)
            setQuizForm({ assessment_name: `Quiz ${sec?.section_name ?? ''}`, passing_score: 70 })
            setQuizQuestions([emptyQuestion()])
            setQuizModal(true)
            return
        }

        if (materialEdit) {
            await supabase.from('materials').update({
                material_name: materialForm.material_name,
                material_type: materialForm.material_type,
                material_url: materialForm.material_url,
                description: materialForm.description,
                position: materialForm.position,
            }).eq('id', materialEdit.id)
        } else {
            await supabase.from('materials').insert({ ...materialForm, section_id: targetSectionId })
        }
        setMaterialModal(false)
        fetchAll()
    }

    const deleteMaterial = async (mId: string) => {
        if (!confirm('Hapus materi ini?')) return
        await supabase.from('materials').delete().eq('id', mId)
        toast('Materi berhasil dihapus')
        fetchAll()
    }

    // ─── Quiz CRUD ──────────────────────────────────────────────
    const submitQuiz = async () => {
        if (!quizSection) return

        // 1. Insert material dulu
        const { data: mat } = await supabase
            .from('materials')
            .insert({ material_name: quizForm.assessment_name, material_type: 'quiz', material_url: '', position: materialForm.position, section_id: quizSection.id })
            .select().single()

        // 2. Insert quiz
        const { data: quiz } = await supabase
            .from('assessments')
            .insert({ assessment_type: 'quiz', assessment_name: quizForm.assessment_name, passing_score: quizForm.passing_score, section_id: quizSection.id })
            .select().single()

        if (!quiz) { alert('Gagal membuat quiz'); return }

        // 3. Insert questions + options
        for (const q of quizQuestions) {
            if (!q.question_text.trim()) continue
            const { data: newQ } = await supabase
                .from('questions')
                .insert({ question_text: q.question_text, question_type: 'multiple_choice', assessment_id: (quiz as Assessment).id })
                .select().single()
            if (newQ) {
                await supabase.from('question_options').insert(
                    q.options.map(o => ({ ...o, question_id: (newQ as any).id }))
                )
            }
        }
        toast('Quiz berhasil disimpan')
        setQuizModal(false)
        fetchAll()
    }

    // ─── Exam CRUD ──────────────────────────────────────────────
    const openAddExam = () => {
        setExamForm({ assessment_name: `Final Exam - ${course?.course_name ?? ''}`, passing_score: 80 })
        setExamQuestions([emptyQuestion()])
        setExamModal(true)
    }

    const submitExam = async () => {
        const { data: newExam } = await supabase
            .from('assessments')
            .insert({ assessment_type: 'exam', assessment_name: examForm.assessment_name, passing_score: examForm.passing_score, course_id: id })
            .select().single()

        if (!newExam) { alert('Gagal membuat exam'); return }

        for (const q of examQuestions) {
            if (!q.question_text.trim()) continue
            const { data: newQ } = await supabase
                .from('questions')
                .insert({ question_text: q.question_text, question_type: 'multiple_choice', assessment_id: (newExam as Assessment).id })
                .select().single()
            if (newQ) {
                await supabase.from('question_options').insert(
                    q.options.map(o => ({ ...o, question_id: (newQ as any).id }))
                )
            }
        }
        toast('Final Exam berhasil disimpan')
        setExamModal(false)
        fetchAll()
    }

    const deleteExam = async () => {
        if (!exam || !confirm('Hapus final exam ini beserta semua soalnya?')) return
        const { data: questions } = await supabase.from('questions').select('id').eq('assessment_id', exam.id)
        for (const q of (questions ?? [])) {
            await supabase.from('question_options').delete().eq('question_id', (q as any).id)
        }
        await supabase.from('questions').delete().eq('assessment_id', exam.id)
        await supabase.from('assessments').delete().eq('id', exam.id)
        toast('Final Exam berhasil dihapus')
        fetchAll()
    }

    // ─── Question helpers ───────────────────────────────────────
    const updateQuestion = (
        list: QuestionForm[], setList: (l: QuestionForm[]) => void,
        idx: number, field: 'question_text', value: string
    ) => {
        const n = [...list]; n[idx] = { ...n[idx], [field]: value }; setList(n)
    }

    const updateOption = (
        list: QuestionForm[], setList: (l: QuestionForm[]) => void,
        qIdx: number, oIdx: number, value: string
    ) => {
        const n = [...list]
        n[qIdx].options[oIdx] = { ...n[qIdx].options[oIdx], option_text: value }
        setList(n)
    }

    const setCorrectOption = (
        list: QuestionForm[], setList: (l: QuestionForm[]) => void,
        qIdx: number, oIdx: number
    ) => {
        const n = [...list]
        n[qIdx].options = n[qIdx].options.map((o, i) => ({ ...o, is_correct: i === oIdx }))
        setList(n)
    }

    const addQuestion = (list: QuestionForm[], setList: (l: QuestionForm[]) => void) =>
        setList([...list, emptyQuestion()])

    const removeQuestion = (list: QuestionForm[], setList: (l: QuestionForm[]) => void, idx: number) =>
        setList(list.filter((_, i) => i !== idx))

    // ─── Material type icon ─────────────────────────────────────
    const typeIcon = (type: string) => {
        if (type === 'video') return <Video size={14} className="text-blue-500" />
        if (type === 'slide') return <FileText size={14} className="text-orange-500" />
        if (type === 'quiz') return <HelpCircle size={14} className="text-purple-500" />
        return <BookOpen size={14} className="text-gray-400" />
    }

    // ─── Question Form Component (reusable) ─────────────────────
    const QuestionListForm = ({
        questions, setQuestions, label
    }: { questions: QuestionForm[]; setQuestions: (l: QuestionForm[]) => void; label: string }) => (
        <div>
            <div className="flex items-center justify-between mb-3">
                <p className="text-sm font-semibold text-gray-700">{label}</p>
                <button type="button" onClick={() => addQuestion(questions, setQuestions)}
                    className="text-xs flex items-center gap-1 text-teal-700 hover:underline">
                    <Plus size={12} /> Tambah Soal
                </button>
            </div>
            <div className="space-y-4 max-h-96 overflow-y-auto pr-1">
                {questions.map((q, qi) => (
                    <div key={qi} className="border border-gray-200 rounded-xl p-4 bg-gray-50">
                        <div className="flex items-start gap-2 mb-3">
                            <span className="text-xs text-gray-400 mt-2 shrink-0">Q{qi + 1}</span>
                            <textarea
                                value={q.question_text}
                                onChange={e => updateQuestion(questions, setQuestions, qi, 'question_text', e.target.value)}
                                rows={2}
                                placeholder="Tulis pertanyaan..."
                                className="flex-1 border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600"
                            />
                            {questions.length > 1 && (
                                <button onClick={() => removeQuestion(questions, setQuestions, qi)}
                                    className="p-1 text-gray-300 hover:text-red-500 mt-1"><Trash2 size={14} /></button>
                            )}
                        </div>
                        <div className="space-y-1.5">
                            {q.options.map((opt, oi) => (
                                <div key={oi} className="flex items-center gap-2">
                                    <button type="button" onClick={() => setCorrectOption(questions, setQuestions, qi, oi)}
                                        className={`w-4 h-4 rounded-full border-2 shrink-0 flex items-center justify-center ${opt.is_correct ? 'border-teal-600 bg-teal-600' : 'border-gray-300'}`}>
                                        {opt.is_correct && <div className="w-1.5 h-1.5 bg-white rounded-full" />}
                                    </button>
                                    <input
                                        type="text"
                                        value={opt.option_text}
                                        onChange={e => updateOption(questions, setQuestions, qi, oi, e.target.value)}
                                        placeholder={`Opsi ${oi + 1}`}
                                        className="flex-1 border border-gray-200 rounded-lg px-2 py-1.5 text-sm focus:outline-none focus:ring-1 focus:ring-teal-600"
                                    />
                                </div>
                            ))}
                        </div>
                    </div>
                ))}
            </div>
        </div>
    )

    // ─── Render ─────────────────────────────────────────────────
    if (loading) return <div className="text-center py-20 text-gray-400">Memuat...</div>
    if (!course) return <div className="text-center py-20 text-gray-400">Course tidak ditemukan.</div>

    return (
        <div>
            {/* Header */}
            <div className="flex items-center gap-3 mb-6">
                <button onClick={() => router.push('/dashboard/courses')}
                    className="p-1.5 text-gray-400 hover:text-teal-700 hover:bg-teal-50 rounded-lg transition">
                    <ChevronLeft size={20} />
                </button>
                <div className="flex items-center gap-3">
                    {course.course_image && <img src={course.course_image} className="w-10 h-10 rounded-lg object-cover" />}
                    <div>
                        <h1 className="text-2xl font-bold text-gray-800">{course.course_name}</h1>
                        <p className="text-sm text-gray-400">{course.description}</p>
                    </div>
                </div>
            </div>

            {/* Sections */}
            <div className="flex items-center justify-between mb-3">
                <p className="text-sm font-semibold text-gray-700">Sections & Materi</p>
                <button onClick={openAddSection}
                    className="flex items-center gap-1.5 text-sm bg-teal-700 text-white px-3 py-1.5 rounded-lg hover:bg-teal-800 transition">
                    <Plus size={14} /> Tambah Section
                </button>
            </div>

            <div className="space-y-3 mb-8">
                {sections.length === 0 && (
                    <div className="text-center py-12 border-2 border-dashed border-gray-200 rounded-xl text-gray-400">
                        Belum ada section. Klik "Tambah Section" untuk mulai.
                    </div>
                )}
                {sections.map((sec) => (
                    <div key={sec.id} className="bg-white border border-gray-200 rounded-xl overflow-hidden">
                        {/* Section header */}
                        <div className="flex items-center justify-between px-4 py-3 bg-gray-50">
                            <button onClick={() => toggleSection(sec.id)} className="flex items-center gap-2 flex-1 text-left">
                                {expandedSections.has(sec.id) ? <ChevronUp size={16} className="text-gray-400" /> : <ChevronDown size={16} className="text-gray-400" />}
                                <span className="font-medium text-gray-800">{sec.section_name}</span>
                                <span className="text-xs text-gray-400">{sec.materials.length} materi</span>
                                {sec.quiz && <span className="text-xs bg-purple-50 text-purple-600 px-2 py-0.5 rounded-full">Ada Quiz</span>}
                            </button>
                            <div className="flex items-center gap-1">
                                <button onClick={() => openEditSection(sec)}
                                    className="p-1.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition"><Pencil size={14} /></button>
                                <button onClick={() => deleteSection(sec.id)}
                                    className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition"><Trash2 size={14} /></button>
                            </div>
                        </div>

                        {/* Material list */}
                        {expandedSections.has(sec.id) && (
                            <div className="divide-y divide-gray-100">
                                {sec.materials.map((mat) => (
                                    <div key={mat.id} className="flex items-center gap-3 px-4 py-2.5 hover:bg-gray-50 group">
                                        <GripVertical size={14} className="text-gray-300" />
                                        {typeIcon(mat.material_type)}
                                        <div className="flex-1 min-w-0">
                                            <p className="text-sm text-gray-700 font-medium">{mat.material_name}</p>
                                            {mat.description && <p className="text-xs text-gray-400 truncate max-w-xs">{mat.description}</p>}
                                        </div>
                                        <span className="text-xs text-gray-400 capitalize">{mat.material_type}</span>
                                        <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition">
                                            <button onClick={() => openEditMaterial(mat, sec.id)}
                                                className="p-1 text-gray-400 hover:text-blue-600"><Pencil size={13} /></button>
                                            <button onClick={() => deleteMaterial(mat.id)}
                                                className="p-1 text-gray-400 hover:text-red-600"><Trash2 size={13} /></button>
                                        </div>
                                    </div>
                                ))}
                                <div className="px-4 py-2">
                                    <button onClick={() => openAddMaterial(sec.id, sec.materials.length + 1)}
                                        className="text-xs flex items-center gap-1 text-teal-700 hover:underline">
                                        <Plus size={12} /> Tambah Materi
                                    </button>
                                </div>
                            </div>
                        )}
                    </div>
                ))}
            </div>

            {/* Final Exam */}
            <div className="flex items-center justify-between mb-3">
                <p className="text-sm font-semibold text-gray-700">Final Exam</p>
                {!exam && (
                    <button onClick={openAddExam}
                        className="flex items-center gap-1.5 text-sm bg-purple-600 text-white px-3 py-1.5 rounded-lg hover:bg-purple-700 transition">
                        <Plus size={14} /> Buat Exam
                    </button>
                )}
            </div>
            {exam ? (
                <div className="bg-white border border-purple-200 rounded-xl p-4 flex items-center justify-between">
                    <div>
                        <p className="font-medium text-gray-800">{exam.assessment_name}</p>
                        <p className="text-xs text-gray-400 mt-0.5">Nilai lulus: {exam.passing_score}</p>
                    </div>
                    <div className="flex items-center gap-2">
                        <a href={`/dashboard/questions`}
                            className="text-xs text-purple-600 hover:underline">Kelola Soal →</a>
                        <button onClick={deleteExam}
                            className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition"><Trash2 size={14} /></button>
                    </div>
                </div>
            ) : (
                <div className="text-center py-8 border-2 border-dashed border-gray-200 rounded-xl text-gray-400 text-sm">
                    Belum ada final exam untuk course ini.
                </div>
            )}

            {/* ── Modal: Section ── */}
            {sectionModal && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl">
                        <h2 className="text-lg font-bold mb-4">{sectionEdit ? 'Edit Section' : 'Tambah Section'}</h2>
                        <label className="text-sm font-medium text-gray-700">Nama Section</label>
                        <input value={sectionName} onChange={e => setSectionName(e.target.value)}
                            placeholder="contoh: Pengenalan Flutter"
                            className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
                        <div className="flex justify-end gap-2 mt-4">
                            <button onClick={() => setSectionModal(false)} className="px-4 py-2 text-sm border rounded-lg hover:bg-gray-50">Batal</button>
                            <button onClick={submitSection} className="px-4 py-2 text-sm bg-teal-700 text-white rounded-lg hover:bg-teal-800">Simpan</button>
                        </div>
                    </div>
                </div>
            )}

            {/* ── Modal: Material ── */}
            {materialModal && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-2xl shadow-xl">
                        <h2 className="text-lg font-bold mb-4">{materialEdit ? 'Edit Materi' : 'Tambah Materi'}</h2>
                        <div className="space-y-3">
                            <div>
                                <label className="text-sm font-medium text-gray-700">Tipe Materi</label>
                                <div className="flex gap-2 mt-1">
                                    {MATERIAL_TYPES.map(t => (
                                        <button key={t.value} type="button"
                                            onClick={() => setMaterialForm({ ...materialForm, material_type: t.value })}
                                            className={`flex-1 flex items-center justify-center gap-1.5 py-2 rounded-lg border text-sm transition ${materialForm.material_type === t.value ? 'border-teal-600 bg-teal-50 text-teal-700 font-medium' : 'border-gray-200 text-gray-600 hover:border-gray-300'}`}>
                                            <t.icon size={14} /> {t.label}
                                        </button>
                                    ))}
                                </div>
                                {materialForm.material_type === 'quiz' && !materialEdit && (
                                    <p className="text-xs text-purple-600 mt-1.5 bg-purple-50 px-3 py-1.5 rounded-lg">
                                        Kamu akan membuat quiz baru dengan soal-soalnya setelah ini.
                                    </p>
                                )}
                            </div>
                            <div>
                                <label className="text-sm font-medium text-gray-700">Nama Materi</label>
                                <input value={materialForm.material_name}
                                    onChange={e => setMaterialForm({ ...materialForm, material_name: e.target.value })}
                                    placeholder="contoh: Instalasi Flutter SDK"
                                    className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
                            </div>
                            <div>
                                <div className="flex items-center justify-between mt-1">
                                    <label className="text-sm font-medium text-gray-700">Deskripsi/Keterangan Materi</label>
                                    <div className="flex border border-gray-200 rounded-lg p-0.5 bg-gray-50 text-xs">
                                        <button type="button"
                                            onClick={() => setDescTab('write')}
                                            className={`px-2 py-1 rounded-md transition ${descTab === 'write' ? 'bg-white text-gray-800 font-medium shadow-sm' : 'text-gray-500 hover:text-gray-800'}`}>
                                            <Edit2 size={12} className="inline mr-1" /> Tulis
                                        </button>
                                        <button type="button"
                                            onClick={() => setDescTab('preview')}
                                            className={`px-2 py-1 rounded-md transition ${descTab === 'preview' ? 'bg-white text-gray-800 font-medium shadow-sm' : 'text-gray-500 hover:text-gray-800'}`}>
                                            <Eye size={12} className="inline mr-1" /> Pratinjau
                                        </button>
                                    </div>
                                </div>

                                {descTab === 'write' ? (
                                    <div className="mt-1 border border-gray-300 rounded-lg overflow-hidden focus-within:ring-2 focus-within:ring-teal-600 focus-within:border-transparent">
                                        {/* Formatting Toolbar */}
                                        <div className="flex items-center gap-1 bg-gray-50 px-2 py-1.5 border-b border-gray-200 text-gray-600">
                                            <button type="button" onClick={() => insertMarkdown('bold')} title="Tebal (Bold)" className="p-1 hover:bg-gray-200 rounded text-gray-700 transition">
                                                <Bold size={14} />
                                            </button>
                                            <button type="button" onClick={() => insertMarkdown('italic')} title="Miring (Italic)" className="p-1 hover:bg-gray-200 rounded text-gray-700 transition">
                                                <Italic size={14} />
                                            </button>
                                            <button type="button" onClick={() => insertMarkdown('header')} title="Header" className="p-1 hover:bg-gray-200 rounded text-gray-700 transition">
                                                <Heading3 size={14} />
                                            </button>
                                            <button type="button" onClick={() => insertMarkdown('list')} title="Daftar Poin" className="p-1 hover:bg-gray-200 rounded text-gray-700 transition">
                                                <List size={14} />
                                            </button>
                                            <span className="text-gray-300 text-xs ml-auto font-mono">Markdown</span>
                                        </div>
                                        
                                        <textarea 
                                            ref={textareaRef}
                                            value={materialForm.description}
                                            onChange={e => setMaterialForm({ ...materialForm, description: e.target.value })}
                                            placeholder="Tulis keterangan, rangkuman, atau info materi di sini. Gunakan tombol formatting di atas untuk mempercantik teks..."
                                            rows={4}
                                            className="w-full px-3 py-2 text-sm focus:outline-none resize-y border-none" 
                                        />
                                    </div>
                                ) : (
                                    <div className="mt-1">
                                        {renderMarkdownPreview(materialForm.description)}
                                    </div>
                                )}
                            </div>
                            {materialForm.material_type !== 'quiz' && (
                                <div>
                                    <label className="text-sm font-medium text-gray-700">URL</label>
                                    <input value={materialForm.material_url}
                                        onChange={e => setMaterialForm({ ...materialForm, material_url: e.target.value })}
                                        placeholder="https://..."
                                        className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
                                </div>
                            )}
                        </div>
                        <div className="flex justify-end gap-2 mt-4">
                            <button onClick={() => setMaterialModal(false)} className="px-4 py-2 text-sm border rounded-lg hover:bg-gray-50">Batal</button>
                            <button onClick={submitMaterial} className="px-4 py-2 text-sm bg-teal-700 text-white rounded-lg hover:bg-teal-800">
                                {materialForm.material_type === 'quiz' && !materialEdit ? 'Lanjut Buat Quiz →' : 'Simpan'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* ── Modal: Quiz ── */}
            {quizModal && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-xl shadow-xl max-h-[90vh] overflow-y-auto">
                        <h2 className="text-lg font-bold mb-1">Buat Quiz</h2>
                        <p className="text-sm text-gray-400 mb-4">Section: {quizSection?.section_name}</p>
                        <div className="space-y-4">
                            <div className="grid grid-cols-2 gap-3">
                                <div>
                                    <label className="text-sm font-medium text-gray-700">Nama Quiz</label>
                                    <input value={quizForm.assessment_name}
                                        onChange={e => setQuizForm({ ...quizForm, assessment_name: e.target.value })}
                                        className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
                                </div>
                                <div>
                                    <label className="text-sm font-medium text-gray-700">Nilai Lulus</label>
                                    <input type="number" value={quizForm.passing_score}
                                        onChange={e => setQuizForm({ ...quizForm, passing_score: +e.target.value })}
                                        className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
                                </div>
                            </div>
                            <QuestionListForm questions={quizQuestions} setQuestions={setQuizQuestions} label="Soal Quiz" />
                        </div>
                        <div className="flex justify-end gap-2 mt-6">
                            <button onClick={() => setQuizModal(false)} className="px-4 py-2 text-sm border rounded-lg hover:bg-gray-50">Batal</button>
                            <button onClick={submitQuiz} className="px-4 py-2 text-sm bg-teal-700 text-white rounded-lg hover:bg-teal-800">Simpan Quiz</button>
                        </div>
                    </div>
                </div>
            )}

            {/* ── Modal: Exam ── */}
            {examModal && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-xl shadow-xl max-h-[90vh] overflow-y-auto">
                        <h2 className="text-lg font-bold mb-4">Buat Final Exam</h2>
                        <div className="space-y-4">
                            <div className="grid grid-cols-2 gap-3">
                                <div>
                                    <label className="text-sm font-medium text-gray-700">Nama Exam</label>
                                    <input value={examForm.assessment_name}
                                        onChange={e => setExamForm({ ...examForm, assessment_name: e.target.value })}
                                        className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
                                </div>
                                <div>
                                    <label className="text-sm font-medium text-gray-700">Nilai Lulus</label>
                                    <input type="number" value={examForm.passing_score}
                                        onChange={e => setExamForm({ ...examForm, passing_score: +e.target.value })}
                                        className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
                                </div>
                            </div>
                            <QuestionListForm questions={examQuestions} setQuestions={setExamQuestions} label="Soal Exam" />
                        </div>
                        <div className="flex justify-end gap-2 mt-6">
                            <button onClick={() => setExamModal(false)} className="px-4 py-2 text-sm border rounded-lg hover:bg-gray-50">Batal</button>
                            <button onClick={submitExam} className="px-4 py-2 text-sm bg-purple-600 text-white rounded-lg hover:bg-purple-700">Simpan Exam</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}