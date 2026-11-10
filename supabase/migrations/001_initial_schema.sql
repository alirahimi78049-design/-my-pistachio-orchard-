-- ۱. فعال‌سازی اکستنشن UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ۲. ساخت انواع شمارشی (Enums)
CREATE TYPE user_role AS ENUM ('farmer', 'consultant', 'admin');
CREATE TYPE report_status AS ENUM ('submitted', 'under_review', 'completed');
CREATE TYPE lab_type AS ENUM ('soil', 'water', 'leaf');

-- ۳. جدول پروفایل کاربران
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone_number TEXT UNIQUE NOT NULL,
    role user_role DEFAULT 'farmer' NOT NULL,
    province TEXT NOT NULL,
    city TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۴. جدول تخصیص مشاور به باغدار
CREATE TABLE consultant_assignments (
    id PRIMARY KEY DEFAULT uuid_generate_v4(),
    consultant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    farmer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(consultant_id, farmer_id)
);

-- ۵. جدول قطعات زمین
CREATE TABLE lands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    area NUMERIC(10, 2) NOT NULL,
    unit TEXT NOT NULL DEFAULT 'هکتار',
    irrigation_interval INT NOT NULL DEFAULT 13,
    soil_type TEXT,
    province TEXT NOT NULL,
    city TEXT NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۶. جدول ارقام پسته قطعه
CREATE TABLE land_varieties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    land_id UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
    variety_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۷. جدول گروه‌های درختان
CREATE TABLE tree_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    land_id UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
    age_category TEXT NOT NULL,
    tree_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۸. جدول گزارش‌های ماهانه
CREATE TABLE monthly_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    land_id UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
    year_jalali INT NOT NULL,
    month_jalali INT NOT NULL,
    general_notes TEXT,
    status report_status DEFAULT 'submitted' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(land_id, year_jalali, month_jalali)
);

-- ۹. جدول اقدامات ماهانه
CREATE TABLE monthly_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES monthly_reports(id) ON DELETE CASCADE,
    action_type TEXT NOT NULL,
    action_date DATE,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۱۰. جدول مشاهدات میدانی درختان
CREATE TABLE tree_observations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES monthly_reports(id) ON DELETE CASCADE,
    observation_type TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۱۱. جدول بررسی مشاور
CREATE TABLE consultant_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES monthly_reports(id) ON DELETE CASCADE,
    consultant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    review_notes TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۱۲. جدول عملکرد و تناژ سالانه
CREATE TABLE yield_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    land_id UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
    year_jalali INT NOT NULL,
    bearing_tree_count INT NOT NULL,
    wet_yield_kg NUMERIC(10, 2) NOT NULL,
    dry_yield_kg NUMERIC(10, 2) NOT NULL,
    hollow_percentage NUMERIC(5, 2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(land_id, year_jalali)
);

-- ۱۳. جدول پرونده آزمایش‌ها
CREATE TABLE lab_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    land_id UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
    year_jalali INT NOT NULL,
    test_type lab_type NOT NULL,
    test_date DATE NOT NULL,
    file_path TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(land_id, year_jalali, test_type)
);

-- ۱۴. جدول نتایج پارامترهای آزمایش
CREATE TABLE lab_test_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lab_test_id UUID NOT NULL REFERENCES lab_tests(id) ON DELETE CASCADE,
    parameter_name TEXT NOT NULL,
    parameter_value NUMERIC(10, 3) NOT NULL,
    unit TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۱۵. جدول برنامه آبیاری
CREATE TABLE irrigation_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    land_id UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    interval_days INT NOT NULL,
    predicted_dates JSONB NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۱۶. جدول آبیاری واقعی انجام‌شده
CREATE TABLE irrigation_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    land_id UUID NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
    actual_date DATE NOT NULL,
    water_volume_hours NUMERIC(6, 2),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ۱۷. جدول ردیابی همگام‌سازی
CREATE TABLE sync_queue_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    table_name TEXT NOT NULL,
    action_type TEXT NOT NULL,
    sync_status TEXT DEFAULT 'success',
    synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- امنیت در سطح ردیف (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE lands ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE yield_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE lab_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE irrigation_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE irrigation_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Farmers can access own lands"
ON lands FOR ALL
USING (auth.uid() = owner_id);

