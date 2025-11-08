'use client';

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://xrrbyyxbxwtopxwymelg.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhycmJ5eXhieHd0b3B4d3ltZWxnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNTg1OTUsImV4cCI6MjA3NzkzNDU5NX0.gJPRp8qzwrwmSvmqZ9JS-MpQX5GLIanfeFKtcUpctXo';

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});
