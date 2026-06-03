'use client'
import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import {
    LayoutDashboard, BookOpen, ListChecks,
    KeyRound, Users, LogOut, GraduationCap
} from 'lucide-react'

const menus = [
    { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/dashboard/courses', label: 'Course', icon: BookOpen },
    { href: '/dashboard/questions', label: 'Soal Quiz & Exam', icon: ListChecks },
    { href: '/dashboard/codes', label: 'Kode Course', icon: KeyRound },
    { href: '/dashboard/users', label: 'Users', icon: Users },
    { href: '/dashboard/enrollments', label: 'Enrollment', icon: GraduationCap },
]

export default function Sidebar() {
    const pathname = usePathname()
    const router = useRouter()

    const handleLogout = async () => {
        await supabase.auth.signOut()
        router.push('/login')
    }

    return (
        <aside className="w-60 min-h-screen bg-teal-800 flex flex-col">
            {/* Logo */}
            <div className="p-6 border-b border-teal-700">
                <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-white rounded-lg flex items-center justify-center">
                        <span className="text-teal-800 font-bold text-sm">GC</span>
                    </div>
                    <div>
                        <p className="text-white font-bold text-sm">Gideon Computer</p>
                        <p className="text-teal-300 text-xs">Admin Panel</p>
                    </div>
                </div>
            </div>

            {/* Menu */}
            <nav className="flex-1 p-4 space-y-1">
                {menus.map((menu) => {
                    const Icon = menu.icon
                    const isActive = pathname === menu.href || pathname.startsWith(menu.href + '/')
                    return (
                        <Link
                            key={menu.href}
                            href={menu.href}
                            className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition ${isActive
                                    ? 'bg-white text-teal-800 font-semibold'
                                    : 'text-teal-100 hover:bg-teal-700'
                                }`}
                        >
                            <Icon size={18} />
                            {menu.label}
                        </Link>
                    )
                })}
            </nav>

            {/* Logout */}
            <div className="p-4 border-t border-teal-700">
                <button
                    onClick={handleLogout}
                    className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-teal-100 hover:bg-teal-700 w-full transition"
                >
                    <LogOut size={18} />
                    Keluar
                </button>
            </div>
        </aside>
    )
}