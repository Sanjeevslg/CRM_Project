'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/lib/auth-context';
import { Building2 } from 'lucide-react';

export default function Home() {
  const router = useRouter();
  const { user, loading } = useAuth();

  useEffect(() => {
    if (!loading) {
      if (user) {
        router.replace('/dashboard');
      } else {
        router.replace('/login');
      }
    }
  }, [user, loading, router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-50 to-slate-100">
      <div className="text-center">
        <div className="mb-6 flex justify-center">
          <div className="h-16 w-16 rounded-full bg-blue-600 flex items-center justify-center shadow-lg">
            <Building2 className="h-8 w-8 text-white" />
          </div>
        </div>
        <div className="h-8 w-8 rounded-full border-4 border-blue-600 border-t-transparent animate-spin mx-auto"></div>
        <p className="mt-4 text-slate-600 font-medium">Loading PropCRM...</p>
      </div>
    </div>
  );
}
