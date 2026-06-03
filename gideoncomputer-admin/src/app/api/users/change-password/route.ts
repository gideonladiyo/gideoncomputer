import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { isAdminRequest } from '@/lib/auth-check'

const supabaseAdmin = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function POST(req: NextRequest) {
    try {
        // Cek otorisasi admin
        if (!(await isAdminRequest(req))) {
            return NextResponse.json({ error: 'Akses ditolak (Unauthorized)' }, { status: 401 })
        }

        const { userId, password } = await req.json()

        if (!userId || !password) {
            return NextResponse.json({ error: 'userId dan password wajib diisi' }, { status: 400 })
        }

        if (password.length < 6) {
            return NextResponse.json({ error: 'Password minimal 6 karakter' }, { status: 400 })
        }

        const { error } = await supabaseAdmin.auth.admin.updateUserById(userId, { password })

        if (error) {
            return NextResponse.json({ error: error.message }, { status: 400 })
        }

        return NextResponse.json({ success: true })
    } catch {
        return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
    }
}