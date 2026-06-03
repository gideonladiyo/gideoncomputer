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

        const { email, password, fullname, role } = await req.json()

        if (!email || !password || !fullname) {
            return NextResponse.json({ error: 'Email, password, dan nama wajib diisi' }, { status: 400 })
        }

        // 1. Buat auth user
        const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
            email,
            password,
            email_confirm: true,
        })

        if (authError) {
            return NextResponse.json({ error: authError.message }, { status: 400 })
        }

        // 2. Update profile (auto-created by trigger, atau insert manual)
        const { error: profileError } = await supabaseAdmin
            .from('profiles')
            .upsert({
                id: authData.user.id,
                email,
                fullname,
                role: role ?? 'student',
            })

        if (profileError) {
            // Rollback: hapus auth user kalau profile gagal
            await supabaseAdmin.auth.admin.deleteUser(authData.user.id)
            return NextResponse.json({ error: profileError.message }, { status: 400 })
        }

        return NextResponse.json({ success: true, user: authData.user })
    } catch (err) {
        return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
    }
}