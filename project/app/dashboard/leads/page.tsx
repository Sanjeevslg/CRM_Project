'use client';

import { DashboardLayout } from '@/components/layout/dashboard-layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Users } from 'lucide-react';

export default function LeadsPage() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Leads Management</h1>
          <p className="text-slate-600 mt-1">Manage and track your customer leads</p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Users className="h-5 w-5" />
              Coming Soon
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-slate-600">
              Lead management features will be available here. You'll be able to:
            </p>
            <ul className="mt-4 space-y-2 text-sm text-slate-600">
              <li>• View and manage all leads</li>
              <li>• Create new leads</li>
              <li>• Track lead status and progression</li>
              <li>• Assign leads to team members</li>
              <li>• Filter and search leads</li>
            </ul>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}
