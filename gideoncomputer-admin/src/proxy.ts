import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function proxy(req: NextRequest) {
    return NextResponse.next()
}

export const config = {
    matcher: [
        '/dashboard/:path*',
        '/login',
    ],
}
