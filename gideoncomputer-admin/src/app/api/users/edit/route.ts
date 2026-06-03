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

        const { userId, fullname, email, role } = await req.json()

        if (!userId || !fullname || !email) {
            return NextResponse.json({ error: 'userId, nama, dan email wajib diisi' }, { status: 400 })
        }

        // Update email di auth.users
        const { error: authError } = await supabaseAdmin.auth.admin.updateUserById(userId, { email })
        if (authError) {
            return NextResponse.json({ error: authError.message }, { status: 400 })
        }

        // Update profile
        const { error: profileError } = await supabaseAdmin
            .from('profiles')
            .update({ fullname, email, role })
            .eq('id', userId)

        if (profileError) {
            return NextResponse.json({ error: profileError.message }, { status: 400 })
        }

        return NextResponse.json({ success: true })
    } catch {
        return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
    }
}