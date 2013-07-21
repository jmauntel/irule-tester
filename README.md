## Description

This is a tool to test F5 LTM iRule logic.


## Overview

This utility relies on two required components and has an optional third.  

1. The irule-tester library (./lib/irule-tester - required)
2. A test.sh file the contains your test cases (./test.sh - required)
3. Adding the http-response.irule to the site you want to test if you are not
   using cookie persistence (./support/http-response.irule - optional)

### irule-tester library

This is a bash script that contains default variables and the required 
functions to make this whole thing come together.  The file is well documented 
and contains sane defaults, but you may need to adjust the settings to fit 
your environment.

### test.sh

This is the file that contains your test cases.  The file can be named 
anything you want.  I recommend having a seperate file per site that 
you want to test.

**Usage:**

  ./test.sh -s TARGET\_SITE

**Example:**

	./test.sh www.acme.com

#### Test methods

The following testing methods are currently available.  Additional methods 
will be added as they are required.

`cannot_test` 

  * Use this method when you need to put a placeholder in your test cases for iRule logic that cannot currently be tested due to the way it was written

**Usage:**

  cannot\_test TEST\_CASE\_NUMBER

**Example:**

	cannot_test 0001


`should_discard`

  + Use this method when you need to validate that a given request is ignored or discarded by the F5

**Usage:**

  should\_discard TEST\_CASE\_NUMBER PARAMETERIZED\_URL

**Example:**

	should_discard 0001 http://${targetSite}/index.html 
	
	Note: the $targetSite variable is replaced by the value passed to test.sh with the -s switch


`should_redirect`

  + Use this method when you need to validate that a given request should be redirected to a specific destination

**Usage:**

  should\_redirect TEST\_CASE\_NUMBER SOURCE\_PARAMETERIZED\_URL DEST\_PARAMETERIZED\_URL

**Example:**

	should_redirect 0001 http://${targetSite}/original/location http://${targetSite}/new/location


`should_select_pool`

  + Use this method when you need to validate that a given request is sent to a specific pool

**Usage:**

  should\_select\_pool TEST\_CASE\_NUMBER PARAMETERIZED\_URL DEST\_POOL\_NAME

**Examples:**

	should_select_pool 0001 http://${targetSite}/original/location acme_prd_pool

Note: You can also define a variable in the variables section at the top of test.sh that contains a pipe-delimited list of valid pool names.  This makes the test case portable between different iRule environments, although it introduces the possibility of a passing test result if a dev pool is used by the F5 when you are testing a prd site.

	acmeContentPools='acme_dev_pool|acme_qa_pool|acme_prd_pool'

	should_select_pool 0001 http://${targetSite}/original/location $acmeContentPools


### http-response.irule

This iRule can be used to insert a cookie into all HTTP responses from pool 
selections.  This enables irule-tester to identify which pool was used to 
serve the content for a requested URL

	when HTTP_RESPONSE {
	
		# Insert LastSelectedPool cookie with the value of the selected pool to
		# enable automated testing to identify if the LB made the expected decision
		HTTP::cookie insert name "LastSelectedPool" value [LB::server pool]
	
	}



## Supported Platforms

This code was developed and tested using CentOS 5, but is assumed to work
on other platforms as well.


## Dependencies

* bash >= 3.2.25
* curl >= 7.15.5


## Author

Author: Jesse Mauntel (maunteljw@gmail.com)
