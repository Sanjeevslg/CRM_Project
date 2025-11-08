'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/lib/auth-context';
import { supabase } from '@/lib/supabase-client';
import { DashboardLayout } from '@/components/layout/dashboard-layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Users,
  Home,
  Building2,
  DollarSign,
  TrendingUp,
  CheckCircle2,
  Clock,
  AlertCircle,
  Package,
} from 'lucide-react';

interface DashboardStats {
  totalLeads: number;
  newLeads: number;
  qualifiedLeads: number;
  convertedLeads: number;
  totalProperties?: number;
  activeProperties?: number;
  totalProjects?: number;
  totalUnits?: number;
  availableUnits?: number;
  bookedUnits?: number;
  totalDeals: number;
  dealValue: number;
  pendingTasks: number;
  todayAppointments: number;
}

export default function DashboardPage() {
  const { profile, organization } = useAuth();
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (organization) {
      fetchDashboardStats();
    }
  }, [organization]);

  const fetchDashboardStats = async () => {
    try {
      const [leadsData, propertiesData, projectsData, unitsData, dealsData, tasksData, appointmentsData] =
        await Promise.all([
          supabase.from('leads').select('status', { count: 'exact', head: false }),
          organization?.organization_type === 'Agent'
            ? supabase.from('properties').select('status', { count: 'exact', head: false })
            : Promise.resolve({ data: [], error: null }),
          organization?.organization_type === 'Developer'
            ? supabase.from('projects').select('*', { count: 'exact', head: false })
            : Promise.resolve({ data: [], error: null }),
          organization?.organization_type === 'Developer'
            ? supabase.from('project_units').select('unit_status', { count: 'exact', head: false })
            : Promise.resolve({ data: [], error: null }),
          supabase.from('deals').select('deal_value,pipeline_stage'),
          supabase.from('tasks').select('status', { count: 'exact', head: false }).eq('status', 'Pending'),
          supabase
            .from('appointments')
            .select('*', { count: 'exact', head: false })
            .gte('start_datetime', new Date().toISOString().split('T')[0])
            .lt('start_datetime', new Date(Date.now() + 86400000).toISOString().split('T')[0]),
        ]);

      const leads = leadsData.data || [];
      const properties = propertiesData.data || [];
      const projects = projectsData.data || [];
      const units = unitsData.data || [];
      const deals = dealsData.data || [];

      const statsData: DashboardStats = {
        totalLeads: leads.length,
        newLeads: leads.filter((l: any) => l.status === 'New').length,
        qualifiedLeads: leads.filter((l: any) => l.status === 'Qualified').length,
        convertedLeads: leads.filter((l: any) => l.status === 'Converted').length,
        totalDeals: deals.length,
        dealValue: deals.reduce((sum: number, deal: any) => sum + (parseFloat(deal.deal_value) || 0), 0),
        pendingTasks: tasksData.data?.length || 0,
        todayAppointments: appointmentsData.data?.length || 0,
      };

      if (organization?.organization_type === 'Agent') {
        statsData.totalProperties = properties.length;
        statsData.activeProperties = properties.filter((p: any) => p.status === 'Active').length;
      } else if (organization?.organization_type === 'Developer') {
        statsData.totalProjects = projects.length;
        statsData.totalUnits = units.length;
        statsData.availableUnits = units.filter((u: any) => u.unit_status === 'Available').length;
        statsData.bookedUnits = units.filter((u: any) => u.unit_status === 'Booked' || u.unit_status === 'Sold').length;
      }

      setStats(statsData);
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount: number) => {
    if (amount >= 10000000) {
      return `₹${(amount / 10000000).toFixed(2)} Cr`;
    } else if (amount >= 100000) {
      return `₹${(amount / 100000).toFixed(2)} L`;
    }
    return `₹${amount.toLocaleString('en-IN')}`;
  };

  if (loading) {
    return (
      <DashboardLayout>
        <div className="space-y-6">
          <div>
            <Skeleton className="h-8 w-64 mb-2" />
            <Skeleton className="h-4 w-96" />
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {[1, 2, 3, 4].map((i) => (
              <Skeleton key={i} className="h-32" />
            ))}
          </div>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">
            Welcome back, {profile?.first_name}!
          </h1>
          <p className="text-slate-600 mt-1">Here's what's happening with your business today.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Total Leads</CardTitle>
              <Users className="h-4 w-4 text-slate-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{stats?.totalLeads || 0}</div>
              <div className="flex items-center gap-4 mt-2 text-xs">
                <div className="flex items-center gap-1">
                  <div className="h-2 w-2 rounded-full bg-blue-500" />
                  <span className="text-slate-600">New: {stats?.newLeads || 0}</span>
                </div>
                <div className="flex items-center gap-1">
                  <div className="h-2 w-2 rounded-full bg-emerald-500" />
                  <span className="text-slate-600">Qualified: {stats?.qualifiedLeads || 0}</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {organization?.organization_type === 'Agent' && (
            <Card>
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-slate-600">Properties</CardTitle>
                <Home className="h-4 w-4 text-slate-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-slate-900">{stats?.totalProperties || 0}</div>
                <p className="text-xs text-slate-600 mt-2">
                  {stats?.activeProperties || 0} active listings
                </p>
              </CardContent>
            </Card>
          )}

          {organization?.organization_type === 'Developer' && (
            <>
              <Card>
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-slate-600">Projects</CardTitle>
                  <Building2 className="h-4 w-4 text-slate-500" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-slate-900">{stats?.totalProjects || 0}</div>
                  <p className="text-xs text-slate-600 mt-2">Active projects</p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-slate-600">Unit Inventory</CardTitle>
                  <Package className="h-4 w-4 text-slate-500" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-slate-900">{stats?.totalUnits || 0}</div>
                  <div className="flex items-center gap-4 mt-2 text-xs">
                    <div className="flex items-center gap-1">
                      <div className="h-2 w-2 rounded-full bg-emerald-500" />
                      <span className="text-slate-600">Available: {stats?.availableUnits || 0}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <div className="h-2 w-2 rounded-full bg-amber-500" />
                      <span className="text-slate-600">Booked: {stats?.bookedUnits || 0}</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </>
          )}

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Total Deals</CardTitle>
              <DollarSign className="h-4 w-4 text-slate-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{stats?.totalDeals || 0}</div>
              <p className="text-xs text-emerald-600 mt-2 font-medium">
                {formatCurrency(stats?.dealValue || 0)}
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Pending Tasks</CardTitle>
              <Clock className="h-4 w-4 text-slate-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{stats?.pendingTasks || 0}</div>
              <p className="text-xs text-slate-600 mt-2">Tasks to complete</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-slate-600">Today's Meetings</CardTitle>
              <CheckCircle2 className="h-4 w-4 text-slate-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{stats?.todayAppointments || 0}</div>
              <p className="text-xs text-slate-600 mt-2">Scheduled appointments</p>
            </CardContent>
          </Card>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card>
            <CardHeader>
              <CardTitle>Recent Activity</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-start gap-3">
                  <div className="h-8 w-8 rounded-full bg-emerald-100 flex items-center justify-center mt-0.5">
                    <CheckCircle2 className="h-4 w-4 text-emerald-600" />
                  </div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-slate-900">No recent activity</p>
                    <p className="text-xs text-slate-500">Start by adding leads and properties</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Quick Actions</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-3">
                <a
                  href="/dashboard/leads?action=create"
                  className="flex items-center gap-2 p-3 rounded-lg border border-slate-200 hover:border-indigo-600 hover:bg-indigo-50 transition-colors"
                >
                  <Users className="h-5 w-5 text-indigo-600" />
                  <span className="text-sm font-medium">Add Lead</span>
                </a>
                {organization?.organization_type === 'Agent' ? (
                  <a
                    href="/dashboard/properties?action=create"
                    className="flex items-center gap-2 p-3 rounded-lg border border-slate-200 hover:border-indigo-600 hover:bg-indigo-50 transition-colors"
                  >
                    <Home className="h-5 w-5 text-indigo-600" />
                    <span className="text-sm font-medium">Add Property</span>
                  </a>
                ) : (
                  <a
                    href="/dashboard/projects?action=create"
                    className="flex items-center gap-2 p-3 rounded-lg border border-slate-200 hover:border-indigo-600 hover:bg-indigo-50 transition-colors"
                  >
                    <Building2 className="h-5 w-5 text-indigo-600" />
                    <span className="text-sm font-medium">Add Project</span>
                  </a>
                )}
                <a
                  href="/dashboard/deals?action=create"
                  className="flex items-center gap-2 p-3 rounded-lg border border-slate-200 hover:border-indigo-600 hover:bg-indigo-50 transition-colors"
                >
                  <DollarSign className="h-5 w-5 text-indigo-600" />
                  <span className="text-sm font-medium">Create Deal</span>
                </a>
                <a
                  href="/dashboard/tasks?action=create"
                  className="flex items-center gap-2 p-3 rounded-lg border border-slate-200 hover:border-indigo-600 hover:bg-indigo-50 transition-colors"
                >
                  <Clock className="h-5 w-5 text-indigo-600" />
                  <span className="text-sm font-medium">Add Task</span>
                </a>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  );
}
