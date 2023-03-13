json.total @reviewers.size
json.reviewers @reviewers do |reviewer|
  if current_editor
    json.id reviewer.id
    json.email reviewer.email
  end
  json.name reviewer.complete_name
  json.github reviewer.github
end
