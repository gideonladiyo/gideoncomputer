import { createClient } from '@supabase/supabase-js'

// Inisialisasi Supabase client di tingkat modul (module scope) agar digunakan ulang di setiap request
const admin = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export default async function DashboardPage() {
    const [
        { count: totalCourses },
        { count: totalUsers },
        { count: totalEnrollments },
        { count: totalCodes },
    ] = await Promise.all([
        admin.from('courses').select('*', { count: 'exact', head: true }),
        admin.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'student'),
        admin.from('enrollments').select('*', { count: 'exact', head: true }),
        admin.from('course_codes').select('*', { count: 'exact', head: true }).is('used_by', null),
    ])

    const stats = [
        { label: 'Total Course', value: totalCourses ?? 0, border: 'border-blue-200', text: 'text-blue-700' },
        { label: 'Total User', value: totalUsers ?? 0, border: 'border-green-200', text: 'text-green-700' },
        { label: 'Total Enrollment', value: totalEnrollments ?? 0, border: 'border-purple-200', text: 'text-purple-700' },
        { label: 'Kode Tersisa', value: totalCodes ?? 0, border: 'border-orange-200', text: 'text-orange-700' },
    ]

    return (
        <div>
            <h1 className="text-2xl font-bold text-gray-800 mb-2">Dashboard</h1>
            <p className="text-gray-500 text-sm mb-8">Selamat datang di Admin Panel Gideon Computer.</p>
            <div className="grid grid-cols-4 gap-4 mb-8">
                {stats.map((s) => (
                    <div key={s.label} className={`border ${s.border} rounded-xl p-5`}>
                        <p className="text-sm text-gray-500 mb-1">{s.label}</p>
                        <p className={`text-3xl font-bold ${s.text}`}>{s.value}</p>
                    </div>
                ))}
            </div>
        </div>
    )
}