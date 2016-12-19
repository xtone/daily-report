json.date data[:date]
json.wday data[:date].wday
json.holiday data[:holiday]
if data[:report].present?
  json.report do
    json.id data[:report].id
    json.operations do
      json.array!(data[:report].operations) do |operation|
        json.id operation.id
        json.project do
          json.(operation.project, :id, :name)
        end
        json.workload operation.workload
      end
    end
  end
end