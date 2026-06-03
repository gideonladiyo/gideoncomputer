'use client'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Enrollment } from '@/lib/types'

type EnrollmentWithRelations = Enrollment & {
    profiles: { fullname: string; email: string } | null
    courses: { course_name: string } | null
}

export default function EnrollmentsPage() {
    const [enrollments, setEnrollments] = useState<EnrollmentWithRelations[]>([])
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        const fetch = async () => {
            const { data, error } = await supabase
                .from('enrollments')
                .select('*, profiles(fullname, email), courses(course_name)')
                .order('created_at', { ascending: false })

            if (error) console.error('🔴 enrollments error:', error)
            setEnrollments((data as EnrollmentWithRelations[]) ?? [])
            setLoading(false)
        }
        fetch()
    }, [])

    return (
        <div>
            <div className="mb-6">
                <h1 className="text-2xl font-bold text-gray-800">Enrollment</h1>
                <p className="text-sm text-gray-500">Daftar user yang telah enroll course</p>
            </div>

            {loading ? (
                <div className="text-center py-20 text-gray-400">Memuat...</div>
            ) : enrollments.length === 0 ? (
                <div className="text-center py-20 text-gray-400">Belum ada enrollment.</div>
            ) : (
                <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                    <table className="w-full text-sm">
                        <thead className="bg-gray-50 text-gray-600">
                            <tr>
                                <th className="text-left px-4 py-3">User</th>
                                <th className="text-left px-4 py-3">Course</th>
                                <th className="text-left px-4 py-3">Tanggal Enroll</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {enrollments.map((e) => (
                                <tr key={e.id} className="hover:bg-gray-50">
                                    <td className="px-4 py-3">
                                        <p className="font-medium text-gray-800">
                                            {e.profiles?.fullname ?? '-'}
                                        </p>
                                        <p className="text-xs text-gray-400">
                                            {e.profiles?.email ?? '-'}
                                        </p>
                                    </td>
                                    <td className="px-4 py-3 text-gray-600">
                                        {e.courses?.course_name ?? '-'}
                                    </td>
                                    <td className="px-4 py-3 text-gray-400 text-xs">
                                        {new Date(e.created_at).toLocaleDateString('id-ID', {
                                            day: 'numeric', month: 'long', year: 'numeric'
                                        })}
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