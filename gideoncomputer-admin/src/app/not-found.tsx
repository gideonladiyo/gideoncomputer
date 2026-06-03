import Link from 'next/link'

export default function NotFound() {
    return (
        <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <h1 className="text-9xl font-extrabold text-teal-700">404</h1>
                <h2 className="text-2xl font-bold text-gray-800 mt-4 mb-2">
                    Halaman Tidak Ditemukan
                </h2>
                <p className="text-gray-500 max-w-md mx-auto mb-8">
                    Maaf, halaman yang Anda cari tidak dapat ditemukan. Mungkin alamat URL salah atau halaman telah dipindahkan.
                </p>
                <Link
                    href="/"
                    className="inline-flex items-center justify-center bg-teal-700 hover:bg-teal-800 text-white font-medium px-6 py-3 rounded-xl transition shadow-lg hover:shadow-teal-700/20"
                >
                    Kembali ke Beranda
                </Link>
            </div>
        </div>
    )
}
