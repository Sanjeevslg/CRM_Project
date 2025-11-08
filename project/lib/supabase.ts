import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
});

export type Database = {
  public: {
    Tables: {
      organizations: {
        Row: {
          organization_id: string;
          organization_name: string;
          organization_type: 'Agent' | 'Developer';
          email: string;
          phone: string;
          business_name: string | null;
          gstin: string | null;
          pan: string | null;
          rera_number: string | null;
          address: string | null;
          city: string | null;
          state: string | null;
          pincode: string | null;
          subscription_tier: 'Basic' | 'Pro' | 'Enterprise' | null;
          subscription_status: 'Active' | 'Suspended' | 'Cancelled' | 'Trial';
          subscription_start: string | null;
          subscription_end: string | null;
          trial_ends_at: string | null;
          max_users: number;
          max_leads: number | null;
          max_properties: number | null;
          storage_limit_mb: number;
          logo_url: string | null;
          brand_color: string;
          is_active: boolean;
          created_at: string;
          updated_at: string;
          last_login_at: string | null;
        };
        Insert: Omit<Database['public']['Tables']['organizations']['Row'], 'organization_id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['organizations']['Insert']>;
      };
      users: {
        Row: {
          user_id: string;
          organization_id: string;
          auth_user_id: string | null;
          first_name: string;
          last_name: string;
          email: string;
          phone: string;
          role: 'Admin' | 'Manager' | 'Agent' | 'Sales';
          employee_id: string | null;
          department: string | null;
          reporting_to: string | null;
          date_of_joining: string;
          profile_photo: string | null;
          rera_certified: boolean;
          rera_certificate_no: string | null;
          is_active: boolean;
          last_login_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['users']['Row'], 'user_id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['users']['Insert']>;
      };
    };
  };
};
