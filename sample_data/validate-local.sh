curl -X POST "http://localhost:3030/ds/shacl?graph=union" \
    --data-binary @build/fdri_shacl.ttl \
    --header "Content-Type: application/turtle" > build/shacl_results.ttl
