# ─── Seeder: md_visibility_role_id_feature_tmps ──────────────────────────────

import Ecto.Query

alias CorporatePolicy.Repo
alias CorporatePolicy.Corporates.MdVisibilityRoleFeature
alias CorporatePolicy.Corporates.MdRoleAccessdetailModule
alias CorporatePolicy.Corporates.MdRoleAccessdetailModuleOption
alias CorporatePolicy.Corporates.TrnMappingRoleidRoleaccessdetail

IO.puts("Cleaning up previous role configuration seeds...")
Repo.delete_all(TrnMappingRoleidRoleaccessdetail)
Repo.delete_all(MdRoleAccessdetailModuleOption)
Repo.delete_all(MdRoleAccessdetailModule)
Repo.delete_all(MdVisibilityRoleFeature)

# Seed modules
modules = [
  %{module_id: 1, module_name: "Dashboard", status: 1},
  %{module_id: 2, module_name: "Enrollment", status: 1},
  %{module_id: 3, module_name: "Claims", status: 1},
  %{module_id: 4, module_name: "Cashless Hospitals", status: 1},
  %{module_id: 5, module_name: "Escalation Matrix", status: 1},
  %{module_id: 6, module_name: "Policy Features", status: 1},
  %{module_id: 7, module_name: "Policy Documents", status: 1},
  %{module_id: 8, module_name: "CD Statements", status: 1},
  %{module_id: 9, module_name: "Endorsements", status: 1},
  %{module_id: 10, module_name: "Employee", status: 1},
  %{module_id: 11, module_name: "Reports", status: 1},
  %{module_id: 12, module_name: "Summary", status: 1},
  %{module_id: 13, module_name: "Endorsement Calculation", status: 1}
]

IO.puts("Seeding md_role_accessdetail_modules...")
for m <- modules do
  Repo.insert!(struct(MdRoleAccessdetailModule, m))
end

# Seed options
options = [
  %{module_option_id: 1, module_option_name: "View", status: 1},
  %{module_option_id: 2, module_option_name: "Upload Enrollment", status: 1},
  %{module_option_id: 3, module_option_name: "Intimate Claim", status: 1},
  %{module_option_id: 4, module_option_name: "View Corporate Buffer List", status: 1},
  %{module_option_id: 5, module_option_name: "Upload CD Statements", status: 1},
  %{module_option_id: 6, module_option_name: "View Activity Logs", status: 1},
  %{module_option_id: 7, module_option_name: "View Claims Report", status: 1},
  %{module_option_id: 8, module_option_name: "View Demography Report", status: 1},
  %{module_option_id: 9, module_option_name: "View Top Ten Claims", status: 1},
  %{module_option_id: 10, module_option_name: "View Endorsement Analysis", status: 1},
  %{module_option_id: 11, module_option_name: "Upload Rackrates", status: 1},
  %{module_option_id: 12, module_option_name: "View Rackrates list", status: 1},
  %{module_option_id: 13, module_option_name: "Upload Endorsement Calculation", status: 1},
  %{module_option_id: 14, module_option_name: "View Endorsement List", status: 1}
]

IO.puts("Seeding md_role_accessdetail_module_options...")
for o <- options do
  Repo.insert!(struct(MdRoleAccessdetailModuleOption, o))
end

# Seed roles
roles = [
  %{role_id: 1, role: "All", is_visible: 1, status: 1},
  %{role_id: 2, role: "superadmin", is_visible: 1, status: 1},
  %{role_id: 4, role: "none", is_visible: 1, status: 1},
  %{role_id: 9, role: "broker", is_visible: 1, status: 1}
]

IO.puts("Seeding md_visibility_role_id_feature_tmps...")
for r <- roles do
  Repo.insert!(struct(MdVisibilityRoleFeature, r))
end

IO.puts("\n✓ Seeder complete!")

