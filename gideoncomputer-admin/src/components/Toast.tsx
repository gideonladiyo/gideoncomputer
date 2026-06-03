'use client'
import { useEffect, useState } from 'react'
import { CheckCircle, XCircle, X } from 'lucide-react'

type ToastType = 'success' | 'error'

type ToastItem = {
    id: number
    message: string
    type: ToastType
}

let toastId = 0
let addToastFn: ((message: string, type: ToastType) => void) | null = null

export function toast(message: string, type: ToastType = 'success') {
    addToastFn?.(message, type)
}

export function ToastContainer() {
    const [toasts, setToasts] = useState<ToastItem[]>([])

    useEffect(() => {
        addToastFn = (message, type) => {
            const id = ++toastId
            setToasts((prev) => [...prev, { id, message, type }])
            setTimeout(() => {
                setToasts((prev) => prev.filter((t) => t.id !== id))
            }, 3000)
        }
        return () => { addToastFn = null }
    }, [])

    if (toasts.length === 0) return null

    return (
        <div className="fixed bottom-6 right-6 z-[100] flex flex-col gap-2">
            {toasts.map((t) => (
                <div
                    key={t.id}
                    className={`flex items-center gap-3 px-4 py-3 rounded-xl shadow-lg text-sm font-medium min-w-[260px] animate-in slide-in-from-bottom-2 ${t.type === 'success'
                            ? 'bg-teal-700 text-white'
                            : 'bg-red-500 text-white'
                        }`}
                >
                    {t.type === 'success'
                        ? <CheckCircle size={18} className="shrink-0" />
                        : <XCircle size={18} className="shrink-0" />
                    }
                    <span className="flex-1">{t.message}</span>
                    <button
                        onClick={() => setToasts((prev) => prev.filter((x) => x.id !== t.id))}
                        className="opacity-70 hover:opacity-100"
                    >
                        <X size={16} />
                    </button>
                </div>
            ))}
        </div>
    )
}