export type Category = {
    id: string
    category_name: string
    category_image: string
    description: string
    created_at: string
}

export type Course = {
    id: string
    course_name: string
    course_image: string
    description: string
    total_video: number
    total_times: string
    total_rating: number
    category_id: string
    created_at: string
    categories?: Category
}

export type Section = {
    id: string
    course_id: string
    section_name: string
    created_at: string
    materials?: Material[]
}

export type Material = {
    id: string
    section_id: string
    material_name: string
    material_type: string
    material_url: string
    position: number
    description?: string
    created_at: string
}

export type Question = {
    id: string
    assessment_id: string
    question_text: string
    question_type: string
    question_options?: QuestionOption[]
}

export type QuestionOption = {
    id: string
    question_id: string
    option_text: string
    is_correct: boolean
}

export type Assessment = {
    id: string
    assessment_type: 'quiz' | 'exam'
    section_id?: string | null
    course_id?: string | null
    assessment_name: string
    passing_score: number
    questions?: Question[]
}

export type CourseCode = {
    id: string
    course_id: string
    code: string
    is_used: boolean
    used_by?: string
    used_at?: string
    created_at: string
    courses?: Course
    profiles?: { fullname: string; email: string }
}

export type Profile = {
    id: string
    email: string
    fullname: string
    avatar: string
    role: string
    created_at: string
}

export type Enrollment = {
    id: string
    user_id: string
    course_id: string
    created_at: string
    profiles?: Profile
    courses?: Course
}
