json.array!(@reports) do |report|
  json.partial! 'report', locals: { data: report }
end
