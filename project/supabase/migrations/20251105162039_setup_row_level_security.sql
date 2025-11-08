/*
  # Row Level Security (RLS) Policies
  
  ## Summary
  This migration enables Row Level Security on all tables and creates comprehensive policies
  to enforce multi-tenant data isolation. Each organization's data is completely isolated
  from other organizations.
  
  ## Security Model
  - Every table (except organizations and subscription_plans) has organization_id
  - Users can only access data belonging to their organization
  - Auth is based on auth.users linked to users table via auth_user_id
  - Four policies per table: SELECT, INSERT, UPDATE, DELETE
  
  ## Tables Secured
  All 24 tables with appropriate RLS policies
*/

-- ============================================================================
-- Enable RLS on all tables
-- ============================================================================
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE communications ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_field_values ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE entity_tags ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- Helper function to get current user's organization_id
-- ============================================================================
CREATE OR REPLACE FUNCTION get_user_organization_id()
RETURNS UUID AS $$
  SELECT organization_id 
  FROM users 
  WHERE auth_user_id = auth.uid()
  LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER;

-- ============================================================================
-- RLS Policies for organizations
-- ============================================================================
CREATE POLICY "Users can view their own organization" ON organizations
  FOR SELECT
  USING (organization_id IN (
    SELECT organization_id FROM users WHERE auth_user_id = auth.uid()
  ));

CREATE POLICY "Users can update their own organization" ON organizations
  FOR UPDATE
  USING (organization_id IN (
    SELECT organization_id FROM users WHERE auth_user_id = auth.uid() AND role = 'Admin'
  ));

-- ============================================================================
-- RLS Policies for users
-- ============================================================================
CREATE POLICY "Users can view their organization users" ON users
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Admins can insert users in their organization" ON users
  FOR INSERT
  WITH CHECK (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role = 'Admin')
  );

CREATE POLICY "Admins can update users in their organization" ON users
  FOR UPDATE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role = 'Admin')
  );

CREATE POLICY "Admins can delete users in their organization" ON users
  FOR DELETE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role = 'Admin')
  );

-- ============================================================================
-- RLS Policies for subscription_plans (Public read access)
-- ============================================================================
CREATE POLICY "Anyone can view subscription plans" ON subscription_plans
  FOR SELECT
  USING (true);

-- ============================================================================
-- RLS Policies for leads
-- ============================================================================
CREATE POLICY "Users can view their organization leads" ON leads
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization leads" ON leads
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization leads" ON leads
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization leads" ON leads
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for properties
-- ============================================================================
CREATE POLICY "Users can view their organization properties" ON properties
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization properties" ON properties
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization properties" ON properties
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization properties" ON properties
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for projects
-- ============================================================================
CREATE POLICY "Users can view their organization projects" ON projects
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization projects" ON projects
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization projects" ON projects
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization projects" ON projects
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for project_units
-- ============================================================================
CREATE POLICY "Users can view their organization units" ON project_units
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization units" ON project_units
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization units" ON project_units
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization units" ON project_units
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for deals
-- ============================================================================
CREATE POLICY "Users can view their organization deals" ON deals
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization deals" ON deals
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization deals" ON deals
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization deals" ON deals
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for payment_schedules
-- ============================================================================
CREATE POLICY "Users can view their organization payments" ON payment_schedules
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization payments" ON payment_schedules
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization payments" ON payment_schedules
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization payments" ON payment_schedules
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for tasks
-- ============================================================================
CREATE POLICY "Users can view their organization tasks" ON tasks
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization tasks" ON tasks
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization tasks" ON tasks
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization tasks" ON tasks
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for appointments
-- ============================================================================
CREATE POLICY "Users can view their organization appointments" ON appointments
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization appointments" ON appointments
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization appointments" ON appointments
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization appointments" ON appointments
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for communications
-- ============================================================================
CREATE POLICY "Users can view their organization communications" ON communications
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization communications" ON communications
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization communications" ON communications
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization communications" ON communications
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for documents
-- ============================================================================
CREATE POLICY "Users can view their organization documents" ON documents
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization documents" ON documents
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization documents" ON documents
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization documents" ON documents
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for custom_fields
-- ============================================================================
CREATE POLICY "Users can view their organization custom fields" ON custom_fields
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Admins can insert custom fields" ON custom_fields
  FOR INSERT
  WITH CHECK (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

CREATE POLICY "Admins can update custom fields" ON custom_fields
  FOR UPDATE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

CREATE POLICY "Admins can delete custom fields" ON custom_fields
  FOR DELETE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

-- ============================================================================
-- RLS Policies for custom_field_values
-- ============================================================================
CREATE POLICY "Users can view their organization custom field values" ON custom_field_values
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization custom field values" ON custom_field_values
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization custom field values" ON custom_field_values
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization custom field values" ON custom_field_values
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for workflows
-- ============================================================================
CREATE POLICY "Users can view their organization workflows" ON workflows
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Admins can insert workflows" ON workflows
  FOR INSERT
  WITH CHECK (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

CREATE POLICY "Admins can update workflows" ON workflows
  FOR UPDATE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

CREATE POLICY "Admins can delete workflows" ON workflows
  FOR DELETE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

-- ============================================================================
-- RLS Policies for workflow_actions
-- ============================================================================
CREATE POLICY "Users can view their organization workflow actions" ON workflow_actions
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Admins can insert workflow actions" ON workflow_actions
  FOR INSERT
  WITH CHECK (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

CREATE POLICY "Admins can update workflow actions" ON workflow_actions
  FOR UPDATE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

CREATE POLICY "Admins can delete workflow actions" ON workflow_actions
  FOR DELETE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

-- ============================================================================
-- RLS Policies for message_templates
-- ============================================================================
CREATE POLICY "Users can view their organization templates" ON message_templates
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Admins can insert templates" ON message_templates
  FOR INSERT
  WITH CHECK (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

CREATE POLICY "Admins can update templates" ON message_templates
  FOR UPDATE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

CREATE POLICY "Admins can delete templates" ON message_templates
  FOR DELETE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role IN ('Admin', 'Manager'))
  );

-- ============================================================================
-- RLS Policies for notifications
-- ============================================================================
CREATE POLICY "Users can view their own notifications" ON notifications
  FOR SELECT
  USING (user_id IN (SELECT user_id FROM users WHERE auth_user_id = auth.uid()));

CREATE POLICY "System can insert notifications" ON notifications
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their own notifications" ON notifications
  FOR UPDATE
  USING (user_id IN (SELECT user_id FROM users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can delete their own notifications" ON notifications
  FOR DELETE
  USING (user_id IN (SELECT user_id FROM users WHERE auth_user_id = auth.uid()));

-- ============================================================================
-- RLS Policies for activity_logs
-- ============================================================================
CREATE POLICY "Users can view their organization activity logs" ON activity_logs
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "System can insert activity logs" ON activity_logs
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for reports
-- ============================================================================
CREATE POLICY "Users can view their organization reports" ON reports
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization reports" ON reports
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization reports" ON reports
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization reports" ON reports
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for integrations
-- ============================================================================
CREATE POLICY "Users can view their organization integrations" ON integrations
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Admins can insert integrations" ON integrations
  FOR INSERT
  WITH CHECK (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role = 'Admin')
  );

CREATE POLICY "Admins can update integrations" ON integrations
  FOR UPDATE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role = 'Admin')
  );

CREATE POLICY "Admins can delete integrations" ON integrations
  FOR DELETE
  USING (
    organization_id = get_user_organization_id() AND
    EXISTS (SELECT 1 FROM users WHERE auth_user_id = auth.uid() AND role = 'Admin')
  );

-- ============================================================================
-- RLS Policies for tags
-- ============================================================================
CREATE POLICY "Users can view their organization tags" ON tags
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization tags" ON tags
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization tags" ON tags
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization tags" ON tags
  FOR DELETE
  USING (organization_id = get_user_organization_id());

-- ============================================================================
-- RLS Policies for entity_tags
-- ============================================================================
CREATE POLICY "Users can view their organization entity tags" ON entity_tags
  FOR SELECT
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can insert their organization entity tags" ON entity_tags
  FOR INSERT
  WITH CHECK (organization_id = get_user_organization_id());

CREATE POLICY "Users can update their organization entity tags" ON entity_tags
  FOR UPDATE
  USING (organization_id = get_user_organization_id());

CREATE POLICY "Users can delete their organization entity tags" ON entity_tags
  FOR DELETE
  USING (organization_id = get_user_organization_id());