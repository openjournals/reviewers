json.total @reviewers.size
json.reviewers @reviewers do |reviewer|
  json.id reviewer.id
  json.name reviewer.complete_name
  json.github reviewer.github
  json.email reviewer.email
end
