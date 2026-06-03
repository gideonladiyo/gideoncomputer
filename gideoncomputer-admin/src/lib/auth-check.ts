import { createServerClient } from '@supabase/ssr'
import { NextRequest } from 'next/server'

export async function isAdminRequest(req: NextRequest): Promise<boolean> {
    try {
        const supabase = createServerClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
            {
                cookies: {
                    getAll: () => req.cookies.getAll(),
                    setAll: () => {}, // read-only check, cookies won't be set/modified here
                },
            }
        )

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) return false

        const { data: profile } = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single()

        return profile?.role === 'admin'
    } catch {
        return false
    }
}
