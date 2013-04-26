export NOVA_HOST="15.184.93.121"
export KEYFILE="/Users/mhagedorn/develop/hpcskeys/st2key.pem"

# Build an Xcode documentation
/usr/local/bin/appledoc \
  --project-name "HPCSMist" \
  --project-company "HP Cloud Services" \
  --project-version "0.0.6" \
  --company-id "com.hpcloud" \
  --output "~/help" \
  --docset-feed-url "http://${NOVA_HOST}/HPCSMist/%DOCSETATOMFILENAME" \
  --docset-package-url "http://${NOVA_HOST}/HPCSMist/%DOCSETPACKAGEFILENAME" \
  --publish-docset \
  --logformat xcode \
  --keep-undocumented-objects \
  --keep-undocumented-members \
  --keep-intermediate-files \
  --no-repeat-first-par \
  --no-warn-invalid-crossref \
  --ignore "*.m" \
  --ignore "Pods" \
  --ignore "Classes/Controllers" \
  --ignore "Classes/AppDelegate" \
  --ignore "HPCSMistTests" \
  --ignore "Other Sources" \
  --index-desc "${PROJECT_DIR}/README.md" \
  "${PROJECT_DIR}";

#rsync --rsh "ssh -i ${KEYFILE}"  --rsync-path "sudo rsync" -avz ~/help/publish/ ubuntu@${NOVA_HOST}:/usr/share/nginx/HPCSMist/;
#rsync --rsh "ssh -i ${KEYFILE}"  --rsync-path "sudo rsync" -avz ~/help/html/ ubuntu@${NOVA_HOST}:/usr/share/nginx/HPCSMist/;
