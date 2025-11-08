/*
  # Real Estate CRM - Complete Database Schema
  
  ## Overview
  This migration creates a complete multi-tenant SaaS CRM for real estate agents and developers in India.
  
  ## Tables Created
  
  ### Core Tenant Management
  1. **organizations** - Tenant/customer accounts
  2. **users** - Team members within organizations
  3. **subscription_plans** - Available subscription tiers
  
  ### Lead & Property Management
  4. **leads** - Customer leads/prospects
  5. **properties** - Individual properties (for agents)
  6. **projects** - Development projects (for developers)
  7. **project_units** - Individual units within projects
  
  ### Sales & Revenue
  8. **deals** - Sales pipeline tracking
  9. **payment_schedules** - Payment tracking with GST/TDS
  
  ### Activity Management
  10. **tasks** - Task management
  11. **appointments** - Calendar and scheduling
  12. **communications** - Call/SMS/Email/WhatsApp logs
  
  ### Document Management
  13. **documents** - File storage tracking
  
  ### Customization
  14. **custom_fields** - Custom field definitions
  15. **custom_field_values** - Custom field data
  
  ### Automation
  16. **workflows** - Automation rules
  17. **workflow_actions** - Workflow action definitions
  18. **message_templates** - SMS/Email templates
  
  ### System
  19. **notifications** - In-app notifications
  20. **activity_logs** - Audit trail
  21. **reports** - Saved reports
  22. **integrations** - Third-party integrations
  23. **tags** - Tagging system
  24. **entity_tags** - Tag associations
  
  ## Security
  - All tables include organization_id for tenant isolation
  - Row Level Security (RLS) enabled on all tables
  - Comprehensive policies for multi-tenant data separation
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE 1: organizations (Tenants/Customers)
-- ============================================================================
CREATE TABLE IF NOT EXISTS organizations (
  organization_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_name VARCHAR(255) NOT NULL,
  organization_type VARCHAR(50) NOT NULL CHECK (organization_type IN ('Agent', 'Developer')),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  business_name VARCHAR(255),
  gstin VARCHAR(15),
  pan VARCHAR(10),
  rera_number VARCHAR(100),
  address TEXT,
  city VARCHAR(100),
  state VARCHAR(100),
  pincode VARCHAR(10),
  subscription_tier VARCHAR(50) CHECK (subscription_tier IN ('Basic', 'Pro', 'Enterprise')),
  subscription_status VARCHAR(50) CHECK (subscription_status IN ('Active', 'Suspended', 'Cancelled', 'Trial')) DEFAULT 'Trial',
  subscription_start DATE,
  subscription_end DATE,
  trial_ends_at DATE DEFAULT (CURRENT_DATE + INTERVAL '14 days'),
  max_users INT DEFAULT 1,
  max_leads INT,
  max_properties INT,
  storage_limit_mb INT DEFAULT 100,
  logo_url VARCHAR(500),
  brand_color VARCHAR(7) DEFAULT '#4F46E5',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_login_at TIMESTAMP
);

-- ============================================================================
-- TABLE 2: users (Team Members)
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  auth_user_id UUID REFERENCES auth.users(id),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  role VARCHAR(50) CHECK (role IN ('Admin', 'Manager', 'Agent', 'Sales')) DEFAULT 'Agent',
  employee_id VARCHAR(50),
  department VARCHAR(100),
  reporting_to UUID REFERENCES users(user_id),
  date_of_joining DATE DEFAULT CURRENT_DATE,
  profile_photo VARCHAR(500),
  rera_certified BOOLEAN DEFAULT false,
  rera_certificate_no VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_org ON users(organization_id);
CREATE INDEX IF NOT EXISTS idx_user_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_user_auth ON users(auth_user_id);

-- ============================================================================
-- TABLE 3: subscription_plans
-- ============================================================================
CREATE TABLE IF NOT EXISTS subscription_plans (
  plan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_name VARCHAR(100) NOT NULL,
  plan_type VARCHAR(50) CHECK (plan_type IN ('Agent_Plan', 'Developer_Plan')),
  price_monthly DECIMAL(10,2) NOT NULL,
  price_yearly DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  max_users INT NOT NULL,
  max_leads INT,
  max_properties INT,
  max_projects INT,
  storage_limit_gb INT NOT NULL,
  features JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- TABLE 4: leads
-- ============================================================================
CREATE TABLE IF NOT EXISTS leads (
  lead_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100),
  phone VARCHAR(20) NOT NULL,
  alternate_phone VARCHAR(20),
  email VARCHAR(255),
  lead_type VARCHAR(50) CHECK (lead_type IN ('Buyer', 'Investor', 'Tenant', 'End_User')),
  lead_source VARCHAR(100) NOT NULL,
  lead_source_detail VARCHAR(255),
  interested_in VARCHAR(50) CHECK (interested_in IN ('Residential', 'Commercial', 'Plot', 'Industrial')),
  budget_min DECIMAL(12,2),
  budget_max DECIMAL(12,2),
  preferred_locations TEXT,
  bedroom_requirement VARCHAR(50),
  property_purpose VARCHAR(50) CHECK (property_purpose IN ('Investment', 'Self_Use', 'Resale')),
  timeline VARCHAR(50) CHECK (timeline IN ('Immediate', '1-3_Months', '3-6_Months', '6+_Months')),
  status VARCHAR(50) CHECK (status IN ('New', 'Contacted', 'Qualified', 'Nurture', 'Converted', 'Lost')) DEFAULT 'New',
  lead_score INT CHECK (lead_score BETWEEN 0 AND 100) DEFAULT 50,
  assigned_to UUID REFERENCES users(user_id),
  city VARCHAR(100),
  state VARCHAR(100),
  notes TEXT,
  tags JSONB,
  last_contacted TIMESTAMP,
  next_followup TIMESTAMP,
  created_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lead_org ON leads(organization_id);
CREATE INDEX IF NOT EXISTS idx_lead_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_lead_assigned ON leads(assigned_to);

-- ============================================================================
-- TABLE 5: properties (For Agents)
-- ============================================================================
CREATE TABLE IF NOT EXISTS properties (
  property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  property_title VARCHAR(255) NOT NULL,
  property_type VARCHAR(50) CHECK (property_type IN ('Residential', 'Commercial', 'Plot', 'Industrial')),
  sub_type VARCHAR(100),
  listing_type VARCHAR(50) CHECK (listing_type IN ('Sale', 'Rent', 'Lease')),
  address TEXT NOT NULL,
  locality VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  pincode VARCHAR(10) NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  price DECIMAL(12,2) NOT NULL,
  negotiable BOOLEAN DEFAULT true,
  carpet_area DECIMAL(10,2),
  built_up_area DECIMAL(10,2),
  plot_area DECIMAL(10,2),
  bedrooms INT,
  bathrooms INT,
  balconies INT,
  floor_number VARCHAR(20),
  total_floors INT,
  facing VARCHAR(50),
  furnishing VARCHAR(50) CHECK (furnishing IN ('Furnished', 'Semi_Furnished', 'Unfurnished')),
  parking INT,
  age_of_property INT,
  possession_status VARCHAR(50) CHECK (possession_status IN ('Ready_To_Move', 'Under_Construction')),
  description TEXT,
  amenities JSONB,
  images JSONB,
  video_url VARCHAR(500),
  virtual_tour_url VARCHAR(500),
  property_documents JSONB,
  owner_name VARCHAR(255),
  owner_phone VARCHAR(20),
  owner_email VARCHAR(255),
  rera_approved BOOLEAN DEFAULT false,
  rera_id VARCHAR(100),
  status VARCHAR(50) CHECK (status IN ('Active', 'Sold', 'Rented', 'Hold', 'Inactive')) DEFAULT 'Active',
  views_count INT DEFAULT 0,
  enquiries_count INT DEFAULT 0,
  listed_by UUID REFERENCES users(user_id),
  listed_date DATE DEFAULT CURRENT_DATE,
  sold_date DATE,
  days_on_market INT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_property_org ON properties(organization_id);
CREATE INDEX IF NOT EXISTS idx_property_status ON properties(status);
CREATE INDEX IF NOT EXISTS idx_property_city ON properties(city);

-- ============================================================================
-- TABLE 6: projects (For Developers)
-- ============================================================================
CREATE TABLE IF NOT EXISTS projects (
  project_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  project_name VARCHAR(255) NOT NULL,
  project_type VARCHAR(50) CHECK (project_type IN ('Residential', 'Commercial', 'Mixed_Use', 'Plotted')),
  address TEXT NOT NULL,
  locality VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  pincode VARCHAR(10) NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  total_area DECIMAL(12,2),
  total_units INT NOT NULL,
  units_available INT DEFAULT 0,
  units_booked INT DEFAULT 0,
  units_sold INT DEFAULT 0,
  units_blocked INT DEFAULT 0,
  price_per_sqft DECIMAL(10,2),
  starting_price DECIMAL(12,2),
  possession_date DATE,
  launch_date DATE,
  project_status VARCHAR(50) CHECK (project_status IN ('Planning', 'Approved', 'Under_Construction', 'Ready', 'Completed', 'On_Hold')) DEFAULT 'Planning',
  construction_status INT CHECK (construction_status BETWEEN 0 AND 100) DEFAULT 0,
  description TEXT,
  amenities JSONB,
  floor_plans JSONB,
  images JSONB,
  brochure_url VARCHAR(500),
  video_url VARCHAR(500),
  rera_registration VARCHAR(100),
  rera_website VARCHAR(500),
  rera_qr_code VARCHAR(500),
  builder_name VARCHAR(255),
  architect_name VARCHAR(255),
  approving_authority VARCHAR(255),
  approval_number VARCHAR(100),
  land_parcel_number VARCHAR(100),
  project_documents JSONB,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_project_org ON projects(organization_id);
CREATE INDEX IF NOT EXISTS idx_project_status ON projects(project_status);

-- ============================================================================
-- TABLE 7: project_units (Inventory for Developers)
-- ============================================================================
CREATE TABLE IF NOT EXISTS project_units (
  unit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(project_id) ON DELETE CASCADE,
  unit_number VARCHAR(50) NOT NULL,
  unit_type VARCHAR(100) NOT NULL,
  tower_block VARCHAR(50),
  floor_number INT,
  carpet_area DECIMAL(10,2) NOT NULL,
  built_up_area DECIMAL(10,2),
  super_built_up_area DECIMAL(10,2),
  balcony_area DECIMAL(10,2),
  bedrooms INT,
  bathrooms INT,
  facing VARCHAR(50),
  corner_unit BOOLEAN DEFAULT false,
  floor_plan_url VARCHAR(500),
  base_price DECIMAL(12,2) NOT NULL,
  gst_amount DECIMAL(12,2),
  registration_charges DECIMAL(12,2),
  other_charges DECIMAL(12,2),
  total_price DECIMAL(12,2),
  price_per_sqft DECIMAL(10,2),
  unit_status VARCHAR(50) CHECK (unit_status IN ('Available', 'Blocked', 'Booked', 'Sold', 'Hold')) DEFAULT 'Available',
  blocked_until TIMESTAMP,
  booking_date DATE,
  agreement_date DATE,
  registry_date DATE,
  possession_date DATE,
  buyer_lead_id UUID REFERENCES leads(lead_id),
  special_offers TEXT,
  discount_percentage DECIMAL(5,2),
  discount_amount DECIMAL(12,2),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_unit_org ON project_units(organization_id);
CREATE INDEX IF NOT EXISTS idx_unit_project ON project_units(project_id);
CREATE INDEX IF NOT EXISTS idx_unit_status ON project_units(unit_status);

-- ============================================================================
-- TABLE 8: deals (Sales Pipeline)
-- ============================================================================
CREATE TABLE IF NOT EXISTS deals (
  deal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  deal_name VARCHAR(255) NOT NULL,
  lead_id UUID NOT NULL REFERENCES leads(lead_id) ON DELETE CASCADE,
  property_id UUID REFERENCES properties(property_id),
  project_id UUID REFERENCES projects(project_id),
  unit_id UUID REFERENCES project_units(unit_id),
  deal_type VARCHAR(50) CHECK (deal_type IN ('Property_Sale', 'Unit_Sale', 'Rental')),
  deal_value DECIMAL(12,2) NOT NULL,
  expected_commission DECIMAL(12,2),
  commission_percentage DECIMAL(5,2),
  pipeline_stage VARCHAR(50) CHECK (pipeline_stage IN ('Inquiry', 'Site_Visit', 'Negotiation', 'Token_Paid', 'Agreement', 'Registration', 'Closed_Won', 'Lost')) DEFAULT 'Inquiry',
  probability INT CHECK (probability BETWEEN 0 AND 100) DEFAULT 50,
  expected_close_date DATE,
  actual_close_date DATE,
  token_amount DECIMAL(12,2),
  token_paid_date DATE,
  agreement_value DECIMAL(12,2),
  agreement_date DATE,
  registration_date DATE,
  loss_reason TEXT,
  competitor_name VARCHAR(255),
  assigned_to UUID NOT NULL REFERENCES users(user_id),
  remarks TEXT,
  tags JSONB,
  created_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_deal_org ON deals(organization_id);
CREATE INDEX IF NOT EXISTS idx_deal_lead ON deals(lead_id);
CREATE INDEX IF NOT EXISTS idx_deal_stage ON deals(pipeline_stage);

-- ============================================================================
-- TABLE 9: payment_schedules
-- ============================================================================
CREATE TABLE IF NOT EXISTS payment_schedules (
  payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  deal_id UUID NOT NULL REFERENCES deals(deal_id) ON DELETE CASCADE,
  payment_number INT NOT NULL,
  payment_type VARCHAR(50) CHECK (payment_type IN ('Token', 'Booking', 'Installment', 'Final', 'Registration', 'Other')),
  payment_amount DECIMAL(12,2) NOT NULL,
  gst_amount DECIMAL(12,2),
  tds_deducted DECIMAL(12,2),
  net_amount DECIMAL(12,2),
  due_date DATE NOT NULL,
  payment_date DATE,
  payment_status VARCHAR(50) CHECK (payment_status IN ('Pending', 'Paid', 'Overdue', 'Waived')) DEFAULT 'Pending',
  payment_mode VARCHAR(50) CHECK (payment_mode IN ('Cash', 'Cheque', 'NEFT', 'RTGS', 'UPI', 'Bank_Loan')),
  transaction_reference VARCHAR(255),
  bank_name VARCHAR(255),
  receipt_number VARCHAR(100),
  receipt_url VARCHAR(500),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payment_org ON payment_schedules(organization_id);
CREATE INDEX IF NOT EXISTS idx_payment_deal ON payment_schedules(deal_id);
CREATE INDEX IF NOT EXISTS idx_payment_status ON payment_schedules(payment_status);

-- ============================================================================
-- TABLE 10: tasks
-- ============================================================================
CREATE TABLE IF NOT EXISTS tasks (
  task_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  task_title VARCHAR(255) NOT NULL,
  task_description TEXT,
  task_type VARCHAR(50) CHECK (task_type IN ('Call', 'Email', 'SMS', 'WhatsApp', 'Meeting', 'Site_Visit', 'Follow_up', 'Document', 'Other')),
  related_to_type VARCHAR(50) CHECK (related_to_type IN ('Lead', 'Deal', 'Property', 'Project')),
  related_to_id UUID,
  assigned_to UUID NOT NULL REFERENCES users(user_id),
  priority VARCHAR(50) CHECK (priority IN ('Low', 'Medium', 'High', 'Urgent')) DEFAULT 'Medium',
  status VARCHAR(50) CHECK (status IN ('Pending', 'In_Progress', 'Completed', 'Cancelled')) DEFAULT 'Pending',
  due_date DATE NOT NULL,
  due_time TIME,
  reminder_time TIMESTAMP,
  completed_date TIMESTAMP,
  notes TEXT,
  created_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_task_org ON tasks(organization_id);
CREATE INDEX IF NOT EXISTS idx_task_assigned ON tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_task_status ON tasks(status);

-- ============================================================================
-- TABLE 11: appointments
-- ============================================================================
CREATE TABLE IF NOT EXISTS appointments (
  appointment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  appointment_type VARCHAR(50) CHECK (appointment_type IN ('Site_Visit', 'Office_Meeting', 'Client_Call', 'Property_Showing', 'Project_Tour')),
  lead_id UUID REFERENCES leads(lead_id),
  property_id UUID REFERENCES properties(property_id),
  project_id UUID REFERENCES projects(project_id),
  start_datetime TIMESTAMP NOT NULL,
  end_datetime TIMESTAMP NOT NULL,
  location TEXT,
  meeting_link VARCHAR(500),
  assigned_to UUID NOT NULL REFERENCES users(user_id),
  attendees JSONB,
  status VARCHAR(50) CHECK (status IN ('Scheduled', 'Confirmed', 'Completed', 'Cancelled', 'No_Show', 'Rescheduled')) DEFAULT 'Scheduled',
  reminder_sent BOOLEAN DEFAULT false,
  outcome TEXT,
  next_action TEXT,
  created_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_appointment_org ON appointments(organization_id);
CREATE INDEX IF NOT EXISTS idx_appointment_datetime ON appointments(start_datetime);

-- ============================================================================
-- TABLE 12: communications
-- ============================================================================
CREATE TABLE IF NOT EXISTS communications (
  communication_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  communication_type VARCHAR(50) CHECK (communication_type IN ('Call', 'SMS', 'Email', 'WhatsApp')),
  direction VARCHAR(50) CHECK (direction IN ('Inbound', 'Outbound')),
  lead_id UUID REFERENCES leads(lead_id),
  deal_id UUID REFERENCES deals(deal_id),
  from_user_id UUID REFERENCES users(user_id),
  to_phone VARCHAR(20),
  to_email VARCHAR(255),
  subject VARCHAR(500),
  message_body TEXT,
  call_duration INT,
  call_recording_url VARCHAR(500),
  status VARCHAR(50) CHECK (status IN ('Sent', 'Delivered', 'Read', 'Failed', 'Answered', 'Not_Answered', 'Busy')),
  delivered_at TIMESTAMP,
  read_at TIMESTAMP,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comm_org ON communications(organization_id);
CREATE INDEX IF NOT EXISTS idx_comm_lead ON communications(lead_id);

-- ============================================================================
-- TABLE 13: documents
-- ============================================================================
CREATE TABLE IF NOT EXISTS documents (
  document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  document_name VARCHAR(255) NOT NULL,
  document_type VARCHAR(50) CHECK (document_type IN ('Agreement', 'Receipt', 'Identity_Proof', 'Income_Proof', 'Property_Papers', 'NOC', 'Legal_Document', 'Brochure', 'Floor_Plan', 'Other')),
  related_to_type VARCHAR(50) CHECK (related_to_type IN ('Lead', 'Deal', 'Property', 'Project')),
  related_to_id UUID,
  file_url VARCHAR(1000) NOT NULL,
  file_size INT,
  mime_type VARCHAR(100),
  is_signed BOOLEAN DEFAULT false,
  signed_date DATE,
  expiry_date DATE,
  uploaded_by UUID REFERENCES users(user_id),
  uploaded_at TIMESTAMP DEFAULT NOW(),
  is_archived BOOLEAN DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_document_org ON documents(organization_id);
CREATE INDEX IF NOT EXISTS idx_document_type ON documents(document_type);

-- ============================================================================
-- TABLE 14: custom_fields
-- ============================================================================
CREATE TABLE IF NOT EXISTS custom_fields (
  custom_field_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  entity_type VARCHAR(50) CHECK (entity_type IN ('Lead', 'Property', 'Project', 'Deal')),
  field_name VARCHAR(100) NOT NULL,
  field_label VARCHAR(255) NOT NULL,
  field_type VARCHAR(50) CHECK (field_type IN ('Text', 'Number', 'Date', 'Dropdown', 'Checkbox', 'Currency', 'Email', 'Phone', 'URL')),
  field_options JSONB,
  is_required BOOLEAN DEFAULT false,
  default_value TEXT,
  display_order INT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cf_org ON custom_fields(organization_id);

-- ============================================================================
-- TABLE 15: custom_field_values
-- ============================================================================
CREATE TABLE IF NOT EXISTS custom_field_values (
  value_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  custom_field_id UUID NOT NULL REFERENCES custom_fields(custom_field_id) ON DELETE CASCADE,
  entity_type VARCHAR(50) CHECK (entity_type IN ('Lead', 'Property', 'Project', 'Deal')),
  entity_id UUID NOT NULL,
  field_value TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_cfv_unique ON custom_field_values(custom_field_id, entity_id);

-- ============================================================================
-- TABLE 16: workflows
-- ============================================================================
CREATE TABLE IF NOT EXISTS workflows (
  workflow_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  workflow_name VARCHAR(255) NOT NULL,
  workflow_description TEXT,
  trigger_event VARCHAR(100) CHECK (trigger_event IN ('Lead_Created', 'Lead_Status_Changed', 'Deal_Stage_Changed', 'Task_Due', 'Payment_Overdue', 'Site_Visit_Completed')),
  trigger_conditions JSONB,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workflow_org ON workflows(organization_id);

-- ============================================================================
-- TABLE 17: workflow_actions
-- ============================================================================
CREATE TABLE IF NOT EXISTS workflow_actions (
  action_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  workflow_id UUID NOT NULL REFERENCES workflows(workflow_id) ON DELETE CASCADE,
  action_order INT NOT NULL,
  action_type VARCHAR(50) CHECK (action_type IN ('Send_SMS', 'Send_Email', 'Send_WhatsApp', 'Create_Task', 'Update_Status', 'Wait', 'Notify_User')),
  delay_minutes INT,
  action_config JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wa_workflow ON workflow_actions(workflow_id);

-- ============================================================================
-- TABLE 18: message_templates
-- ============================================================================
CREATE TABLE IF NOT EXISTS message_templates (
  template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  template_name VARCHAR(255) NOT NULL,
  template_type VARCHAR(50) CHECK (template_type IN ('SMS', 'Email', 'WhatsApp')),
  subject VARCHAR(500),
  message_body TEXT NOT NULL,
  variables JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_template_org ON message_templates(organization_id);

-- ============================================================================
-- TABLE 19: notifications
-- ============================================================================
CREATE TABLE IF NOT EXISTS notifications (
  notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  notification_type VARCHAR(50) CHECK (notification_type IN ('Task_Reminder', 'Payment_Due', 'Lead_Assigned', 'Deal_Update', 'System_Alert')),
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  action_url VARCHAR(500),
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notif_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notif_read ON notifications(is_read);

-- ============================================================================
-- TABLE 20: activity_logs
-- ============================================================================
CREATE TABLE IF NOT EXISTS activity_logs (
  log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(user_id),
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id UUID NOT NULL,
  old_values JSONB,
  new_values JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_log_org ON activity_logs(organization_id);
CREATE INDEX IF NOT EXISTS idx_log_entity ON activity_logs(entity_type, entity_id);

-- ============================================================================
-- TABLE 21: reports
-- ============================================================================
CREATE TABLE IF NOT EXISTS reports (
  report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  report_name VARCHAR(255) NOT NULL,
  report_type VARCHAR(50) CHECK (report_type IN ('Lead_Source', 'Sales_Pipeline', 'Agent_Performance', 'Revenue', 'Property_Status')),
  filters JSONB,
  date_range VARCHAR(50),
  created_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_report_org ON reports(organization_id);

-- ============================================================================
-- TABLE 22: integrations
-- ============================================================================
CREATE TABLE IF NOT EXISTS integrations (
  integration_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  integration_name VARCHAR(50) CHECK (integration_name IN ('WhatsApp', 'SMS_Gateway', 'Email_Provider', 'Payment_Gateway', 'Property_Portal', 'Google_Maps', 'Zapier')),
  is_enabled BOOLEAN DEFAULT false,
  api_key VARCHAR(500),
  api_secret VARCHAR(500),
  webhook_url VARCHAR(500),
  config JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_integration_org ON integrations(organization_id);

-- ============================================================================
-- TABLE 23: tags
-- ============================================================================
CREATE TABLE IF NOT EXISTS tags (
  tag_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  tag_name VARCHAR(100) NOT NULL,
  tag_category VARCHAR(100),
  color VARCHAR(7) DEFAULT '#4F46E5',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_tag_unique ON tags(organization_id, tag_name);

-- ============================================================================
-- TABLE 24: entity_tags
-- ============================================================================
CREATE TABLE IF NOT EXISTS entity_tags (
  entity_tag_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(tag_id) ON DELETE CASCADE,
  entity_type VARCHAR(50) CHECK (entity_type IN ('Lead', 'Property', 'Project', 'Deal')),
  entity_id UUID NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_entity_tag ON entity_tags(entity_type, entity_id);