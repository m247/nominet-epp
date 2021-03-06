# NominetEPP History

## 0.0.12 / 2011-05-24

  * Capture +domain:failData+ information from +create+ operation failures.

## 0.0.11 / 2011-05-17

  * Remove setting account:contact[type] attribute as this is not in the schema

## 0.0.10 / 2011-05-04

  * Fix syntax error in helpers.rb

## 0.0.9 / 2011-05-04

  * Correct implementation of Update Operation for domain, account and contact to send
    the correct sequence of XML elements

## 0.0.8 / 2011-05-03

  * Amend account:contact elements in Create operation to ensure order attribute range
  * Fix sequencing of elements in account:addr block
  * Fix sequencing of elements in contact:create block
  * Fix sequencing of elements in account:create block
  * Enforce the correct element sequencing for the domain:create operation

## 0.0.7 / 2011-04-21

  * Yank v0.0.6 and bump version to fix bug introduced in v0.0.6

## 0.0.6 / 2011-04-21

  * Fix "Command Syntax Error" response for Create operation with "2y" style periods

## 0.0.5 / 2011-02-24

  * Many bug fixes in Create operation
  * Support for using `host:update` to modify name server glue information.

## 0.0.4 / 2011-01-31

  * Operations now cache their responses, accessible through `Client#last_response`
  * Last response messages are available through `Client#last_message`

## 0.0.3 / 2011-01-17

  * Tweak how #poll method works w.r.t blocks

## 0.0.2 / 2011-01-07

  * Add Documentation
  * Support the 'abuse-limit' on Nominet check operation
  * Fix issue with info operation XML response parsing

## 0.0.1 / 2010-05-26

  * Add support for 'none' and 'all' options on list operation
  * Fix bugs in info operation for account objects
  * Improve handling of XML namespaces and schema locations

## 0.0.0 / 2010-05-25

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
