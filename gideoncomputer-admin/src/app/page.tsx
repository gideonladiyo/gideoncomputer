import { redirect } from 'next/navigation'

export default function Home() {
    redirect('/login')
    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
            <p className="text-gray-500">Mengarahkan ke halaman login...</p>
        </div>
    )
}
