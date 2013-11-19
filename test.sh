#!/bin/bash

source ./lib/irule-tester || {
  echo "Could not load library, exiting..."
  exit 1
}

display_header

# ----- BEGIN APP SPECIFIC VARS -----

test $targetSite == "www.acme.com"     && acmePool=acme-prd-pool
test $targetSite == "web-qa.acme.com"  && acmePool=acme-qa-pool
test $targetSite == "web-dev.acme.com" && acmePool=acme-dev-pool

# ----- BEGIN TESTS -----

cannot_test 0001

should_discard 0002 http://${targetSite}/evilpage.html

should_redirect 0003 http://${targetSite}/original/location1 http://${targetSite}/new/location2
should_redirect 0004 http://${targetSite}/original/location2 https://${targetSite}/new/location2

should_select_pool 0005 http://${targetSite}/index.php $acmePool

# ----- REPORT TEST RESULTS -----

report_results
[[ "$failCount" -gt "0" ]] && exit 1 || exit 0

