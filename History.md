0.0.7 / 2011-04-21
==================

  * Yank v0.0.6 and bump version to fix bug introduced in v0.0.6

0.0.6 / 2011-04-21
==================

  * Fix "Command Syntax Error" response for Create operation with "2y" style periods

0.0.5 / 2011-02-24
==================

  * Many bug fixes in Create operation
  * Support for using `host:update` to modify name server glue information.

0.0.4 / 2011-01-31
==================

  * Operations now cache their responses, accessible through `Client#last_response`
  * Last response messages are available through `Client#last_message`

0.0.3 / 2011-01-17 
==================

  * Tweak how #poll method works w.r.t blocks

0.0.2 / 2011-01-07
==================

  * Add Documentation
  * Support the 'abuse-limit' on Nominet check operation
  * Fix issue with info operation XML response parsing

0.0.1 / 2010-05-26
==================

  * Add support for 'none' and 'all' options on list operation
  * Fix bugs in info operation for account objects
  * Improve handling of XML namespaces and schema locations

0.0.0 / 2010-05-25
==================

  * Initial release
  * Supports the following operations
    * Create
    * Delete
    * Fork
    * Hello
    * Info
    * List
    * Lock
    * Merge
    * Poll
    * Transfer
    * Unlock
    * Unrenew
    * Update
