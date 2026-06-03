import Sidebar from '@/components/Sidebar'
import { ToastContainer } from '@/components/Toast'

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <div className="flex min-h-screen bg-gray-50">
            <Sidebar />
            <main className="flex-1 p-8 overflow-auto">{children}</main>
            <ToastContainer />
        </div>
    )
}