-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- Users table (extends auth.users)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  user_type TEXT DEFAULT 'homeowner' CHECK (user_type IN ('homeowner', 'realtor', 'investor', 'contractor')),
  subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'premium', 'professional')),
  subscription_status TEXT DEFAULT 'active' CHECK (subscription_status IN ('active', 'inactive', 'cancelled', 'trial')),
  total_analyses INTEGER DEFAULT 0,
  monthly_analyses INTEGER DEFAULT 0,
  last_analysis_reset DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Curb appeal analyses
CREATE TABLE public.curb_analyses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  session_id TEXT, -- For anonymous users
  analysis_type TEXT DEFAULT 'quick' CHECK (analysis_type IN ('quick', 'detailed')),
  
  -- Image data
  primary_image_url TEXT NOT NULL,
  additional_images TEXT[], -- Array of image URLs for detailed analysis
  
  -- Scoring data
  overall_score INTEGER NOT NULL CHECK (overall_score >= 1 AND overall_score <= 50),
  percentage INTEGER NOT NULL CHECK (percentage >= 0 AND percentage <= 100),
  
  -- Criteria scores (JSON for flexibility)
  criteria_scores JSONB NOT NULL,
  
  -- Analysis results
  summary TEXT NOT NULL,
  ai_feedback TEXT, -- Raw AI response for debugging
  
  -- Property information
  property_type TEXT DEFAULT 'single_family' CHECK (property_type IN ('single_family', 'townhouse', 'condo', 'apartment', 'commercial')),
  property_address TEXT,
  property_city TEXT,
  property_state TEXT,
  property_zip TEXT,
  
  -- Analysis metadata
  analysis_duration INTEGER, -- Processing time in seconds
  model_version TEXT DEFAULT 'gpt-4-vision-preview',
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Detailed analysis reports
CREATE TABLE public.analysis_reports (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  analysis_id UUID REFERENCES public.curb_analyses(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Report content
  executive_summary TEXT,
  market_insights JSONB, -- Market data and ROI projections
  priority_matrix JSONB, -- High/medium/low impact recommendations
  improvement_timeline JSONB, -- Immediate/short/medium/long term
  contractor_recommendations JSONB,
  
  -- Report generation
  report_pdf_url TEXT,
  generation_status TEXT DEFAULT 'pending' CHECK (generation_status IN ('pending', 'generating', 'completed', 'failed')),
  generation_error TEXT,
  
  -- Payment information
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
  payment_intent_id TEXT,
  amount_paid INTEGER, -- in cents
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User subscriptions
CREATE TABLE public.subscriptions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  
  stripe_subscription_id TEXT UNIQUE,
  stripe_customer_id TEXT,
  
  plan_type TEXT NOT NULL CHECK (plan_type IN ('premium', 'professional')),
  status TEXT NOT NULL CHECK (status IN ('active', 'canceled', 'past_due', 'unpaid', 'trialing')),
  
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  cancel_at_period_end BOOLEAN DEFAULT FALSE,
  
  trial_start TIMESTAMP WITH TIME ZONE,
  trial_end TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Usage tracking
CREATE TABLE public.usage_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  session_id TEXT, -- For anonymous usage
  
  action_type TEXT NOT NULL CHECK (action_type IN ('quick_analysis', 'detailed_report', 'pdf_download', 'api_call')),
  resource_id UUID, -- analysis_id or report_id
  
  -- Usage metadata
  ip_address INET,
  user_agent TEXT,
  processing_time INTEGER, -- milliseconds
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Contractor network
CREATE TABLE public.contractors (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  
  business_name TEXT NOT NULL,
  contact_name TEXT,
  email TEXT,
  phone TEXT,
  website TEXT,
  
  -- Location
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  zip_code TEXT,
  service_radius INTEGER DEFAULT 25, -- miles
  
  -- Services
  service_categories TEXT[] NOT NULL, -- landscaping, roofing, painting, etc.
  specialties TEXT[],
  
  -- Verification
  license_number TEXT,
  insurance_verified BOOLEAN DEFAULT FALSE,
  background_checked BOOLEAN DEFAULT FALSE,
  
  -- Ratings
  average_rating DECIMAL(3,2),
  total_reviews INTEGER DEFAULT 0,
  
  -- Partnership
  partner_status TEXT DEFAULT 'pending' CHECK (partner_status IN ('pending', 'active', 'inactive')),
  commission_rate DECIMAL(5,4), -- e.g., 0.05 for 5%
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cost estimates database
CREATE TABLE public.cost_estimates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  
  category TEXT NOT NULL, -- matches our 10 criteria
  improvement_type TEXT NOT NULL,
  
  -- Geographic data
  region TEXT, -- National, Regional, or specific state
  metro_area TEXT,
  
  -- Cost ranges
  low_estimate INTEGER NOT NULL, -- in dollars
  high_estimate INTEGER NOT NULL,
  average_estimate INTEGER,
  
  -- Estimate metadata
  labor_percentage DECIMAL(3,2), -- what % is labor vs materials
  seasonal_adjustment DECIMAL(3,2), -- seasonal price variation
  
  -- Data source
  data_source TEXT, -- HomeAdvisor, Angie's List, etc.
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User feedback and ratings
CREATE TABLE public.analysis_feedback (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  analysis_id UUID REFERENCES public.curb_analyses(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- Feedback scores (1-5)
  accuracy_rating INTEGER CHECK (accuracy_rating >= 1 AND accuracy_rating <= 5),
  usefulness_rating INTEGER CHECK (usefulness_rating >= 1 AND usefulness_rating <= 5),
  overall_satisfaction INTEGER CHECK (overall_satisfaction >= 1 AND overall_satisfaction <= 5),
  
  -- Qualitative feedback
  feedback_text TEXT,
  would_recommend BOOLEAN,
  
  -- Specific criteria feedback
  criteria_feedback JSONB, -- User can rate individual criteria accuracy
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Email capture for marketing
CREATE TABLE public.email_subscribers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  user_type TEXT CHECK (user_type IN ('homeowner', 'realtor', 'investor', 'contractor')),
  
  -- Subscription preferences
  marketing_opt_in BOOLEAN DEFAULT TRUE,
  newsletter_opt_in BOOLEAN DEFAULT FALSE,
  product_updates_opt_in BOOLEAN DEFAULT TRUE,
  
  -- Source tracking
  source TEXT, -- analysis_signup, landing_page, referral, etc.
  referrer_url TEXT,
  
  -- Status
  email_verified BOOLEAN DEFAULT FALSE,
  subscription_status TEXT DEFAULT 'active' CHECK (subscription_status IN ('active', 'unsubscribed', 'bounced')),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.curb_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_feedback ENABLE ROW LEVEL SECURITY;

-- Users can only see/edit their own data
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Analyses: users can see their own, anonymous can see by session_id
CREATE POLICY "Users can view own analyses" ON public.curb_analyses
  FOR SELECT USING (
    auth.uid() = user_id OR 
    (user_id IS NULL AND session_id IS NOT NULL)
  );

CREATE POLICY "Users can create analyses" ON public.curb_analyses
  FOR INSERT WITH CHECK (
    auth.uid() = user_id OR 
    (auth.uid() IS NULL AND user_id IS NULL)
  );

-- Reports: only for authenticated users
CREATE POLICY "Users can view own reports" ON public.analysis_reports
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own reports" ON public.analysis_reports
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Subscriptions: users can only see their own
CREATE POLICY "Users can view own subscriptions" ON public.subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- Usage logs: users can see their own
CREATE POLICY "Users can view own usage" ON public.usage_logs
  FOR SELECT USING (auth.uid() = user_id);

-- Feedback: users can manage their own feedback
CREATE POLICY "Users can manage own feedback" ON public.analysis_feedback
  FOR ALL USING (auth.uid() = user_id);

-- Public read access for contractors and cost estimates
CREATE POLICY "Public read contractors" ON public.contractors
  FOR SELECT TO anon, authenticated USING (partner_status = 'active');

CREATE POLICY "Public read cost estimates" ON public.cost_estimates
  FOR SELECT TO anon, authenticated USING (true);

-- Functions

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_analyses_updated_at BEFORE UPDATE ON public.curb_analyses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_reports_updated_at BEFORE UPDATE ON public.analysis_reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Function to automatically create user profile
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', '')
  );
  RETURN NEW;
END;
$$ language 'plpgsql' security definer;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to reset monthly usage counter
CREATE OR REPLACE FUNCTION reset_monthly_usage()
RETURNS void AS $$
BEGIN
  UPDATE public.users 
  SET 
    monthly_analyses = 0,
    last_analysis_reset = CURRENT_DATE
  WHERE last_analysis_reset < CURRENT_DATE - INTERVAL '1 month';
END;
$$ language 'plpgsql';

-- Function to check subscription limits
CREATE OR REPLACE FUNCTION check_subscription_limit(
  p_user_id UUID,
  p_resource_type TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  user_tier TEXT;
  monthly_count INTEGER;
  limit_exceeded BOOLEAN := FALSE;
BEGIN
  -- Get user tier and monthly usage
  SELECT subscription_tier, monthly_analyses 
  INTO user_tier, monthly_count
  FROM public.users 
  WHERE id = p_user_id;
  
  -- Check limits based on tier and resource type
  CASE user_tier
    WHEN 'free' THEN
      IF p_resource_type = 'quick_analysis' AND monthly_count >= 10 THEN
        limit_exceeded := TRUE;
      ELSIF p_resource_type = 'detailed_report' AND monthly_count >= 1 THEN
        limit_exceeded := TRUE;
      END IF;
    WHEN 'premium' THEN
      IF p_resource_type = 'quick_analysis' AND monthly_count >= 100 THEN
        limit_exceeded := TRUE;
      ELSIF p_resource_type = 'detailed_report' AND monthly_count >= 10 THEN
        limit_exceeded := TRUE;
      END IF;
    -- Professional has unlimited
  END CASE;
  
  RETURN NOT limit_exceeded;
END;
$$ language 'plpgsql' security definer;

-- Indexes for performance
CREATE INDEX idx_curb_analyses_user_id ON public.curb_analyses(user_id);
CREATE INDEX idx_curb_analyses_created_at ON public.curb_analyses(created_at DESC);
CREATE INDEX idx_curb_analyses_session_id ON public.curb_analyses(session_id);

CREATE INDEX idx_analysis_reports_analysis_id ON public.analysis_reports(analysis_id);
CREATE INDEX idx_analysis_reports_user_id ON public.analysis_reports(user_id);

CREATE INDEX idx_usage_logs_user_id ON public.usage_logs(user_id);
CREATE INDEX idx_usage_logs_created_at ON public.usage_logs(created_at DESC);

CREATE INDEX idx_contractors_location ON public.contractors(state, city);
CREATE INDEX idx_contractors_services ON public.contractors USING GIN(service_categories);

CREATE INDEX idx_cost_estimates_category ON public.cost_estimates(category, region);

-- Sample data for cost estimates (national averages)
INSERT INTO public.cost_estimates (category, improvement_type, region, low_estimate, high_estimate, average_estimate, labor_percentage) VALUES
('Landscaping & Gardens', 'Basic Lawn Care', 'National', 200, 800, 400, 0.80),
('Landscaping & Gardens', 'Garden Bed Creation', 'National', 500, 2500, 1200, 0.60),
('Landscaping & Gardens', 'Tree/Shrub Trimming', 'National', 300, 1200, 600, 0.90),

('Roofing Condition', 'Gutter Cleaning', 'National', 150, 400, 250, 0.85),
('Roofing Condition', 'Minor Roof Repairs', 'National', 400, 1500, 800, 0.70),
('Roofing Condition', 'Full Roof Replacement', 'National', 8000, 25000, 15000, 0.40),

('Exterior Paint & Siding', 'Pressure Washing', 'National', 200, 600, 350, 0.80),
('Exterior Paint & Siding', 'Exterior Painting', 'National', 2000, 8000, 4500, 0.75),
('Exterior Paint & Siding', 'Siding Repair', 'National', 500, 2000, 1100, 0.65),

('Front Porch/Entry', 'Door Replacement', 'National', 400, 2000, 1000, 0.30),
('Front Porch/Entry', 'Porch Enhancement', 'National', 800, 4000, 2000, 0.60),

('Windows & Shutters', 'Window Cleaning', 'National', 100, 300, 200, 0.90),
('Windows & Shutters', 'Shutter Installation', 'National', 600, 2000, 1200, 0.50),

('Driveway & Walkways', 'Driveway Cleaning', 'National', 200, 500, 300, 0.85),
('Driveway & Walkways', 'Walkway Installation', 'National', 1000, 4000, 2200, 0.60),

('Lighting & Fixtures', 'Exterior Light Installation', 'National', 200, 800, 450, 0.70),
('Lighting & Fixtures', 'Landscape Lighting', 'National', 800, 3000, 1600, 0.60),

('Garage & Storage', 'Garage Door Replacement', 'National', 800, 3000, 1600, 0.40),
('Garage & Storage', 'Garage Organization', 'National', 300, 1500, 800, 0.80),

('Fencing & Boundaries', 'Fence Repair', 'National', 400, 1200, 700, 0.75),
('Fencing & Boundaries', 'New Fencing', 'National', 1500, 6000, 3200, 0.65),

('Overall Symmetry & Design', 'Design Consultation', 'National', 300, 1000, 600, 1.00),
('Overall Symmetry & Design', 'Architectural Elements', 'National', 800, 4000, 2000, 0.55);