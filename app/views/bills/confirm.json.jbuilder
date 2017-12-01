if @error.blank?
  json.status 'ok'
  json.resource do
    json.estimate_serial_no @estimate_serial_no
    json.estimate_id @resource.estimate_id
    json.claimed_on @resource.claimed_on
    json.serial_no @resource.serial_no
    json.subject @resource.subject
    json.amount @resource.amount
    json.tax_included_amount @tax_included_amount
    json.filename @resource.filename
  end
  json.warnings @warnings
else
  json.status 'error'
  json.error @error
end
