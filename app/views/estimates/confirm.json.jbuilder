if @error.blank?
  json.status 'ok'
  json.resource do
    json.project_id @resource.project_id
    json.project_code @resource.project.code
    json.project_name @resource.project.name
    json.subject @resource.subject
    json.estimated_on @resource.estimated_on
    json.serial_no @resource.serial_no
    json.amount @resource.amount
    json.director_manday @resource.director_manday
    json.engineer_manday @resource.engineer_manday
    json.designer_manday @resource.designer_manday
    json.other_manday @resource.other_manday
    json.cost @resource.cost
    json.filename @resource.filename
  end
  unless @warnings.blank?
    json.warnings @warnings
  end
else
  json.status 'error'
  json.error @error
end
