+++
date = "2019-03-05T14:53:37-07:00"
title = "Pull Request review process"
+++

Our pull request review process is an ongoing work-in-progress.  This document outlines the timeline, expectations, general points and ongoing issues.  Some of it is particular to how we work (using YouTrack and TeamCity in addition to GitHub) but it may be of use to others.

### Expectations

What the different parties expect to get out of the PR review process

#### Author

All authors appreciate feedback on:

* What have I done wrong, or what could I do better?
* What have I overlooked? Are there corner cases I have missed?
* What tests are missing?
* Is my code readable and idiomatic?
* For UI code, how is the look and feel?

Expected time to initial response is 1/2 a day to 1 day (the review might not be completed in this time, but this should be indicated).  Once the review process is started, re-review is expected to be quicker as it should address ever-smaller issues.

#### Reviewer

* Explanations and descriptions should be provided for nontrivial sections
* Smaller is better.  400 lines is a ballpark figure
* CI should be passing before the review is assigned
* Each PR should be conceptually distinct

### The timeline

#### First the author:

1. Check your branch name carefully as this cannot be modified once the PR is opened
1. Make sure that you have only one PR worth of changes on this branch (small, contained and conceptually distinct)
1. Make sure tests are passing on any CI systems used (TeamCity, travis, appveyor)
1. Create PR (github's [draft PR](https://github.blog/2019-02-14-introducing-draft-pull-requests/) feature here is nice if you think it might not quite be ready)
1. Write a paragraph explaining why the PR is being made.  For bug fixes and small features this might be very small.
1. Check through the diff to make sure that it seems sensible
1. Comment directly into the PR on any points of oddness that require explanation additional to code comments
1. Split the PR into multiple smaller PRs if it is too large
1. Choose a reviewer and assign them on github (based on current or desired familiarity with language and codebase) - if necessary assign multiple reviewers if you need different people to look at different aspects.
1. Update YouTrack, if the project uses it
   - Copy the PR URL as a comment
   - Set yourself as `Implementer`
   - Set the reviewer as `Assignee`
   - Set the state as `Submitted`

#### Then the reviewer

1. Check that you are an appropriate reviewer
   * do you feel confident to carry out what the author is asking? Do you understand the project and programming language enough, and can you understand the changes proposed sufficiently to meaningfully engage - not necessarily at an expert level, but to affirm that the PR seems sensible and beneficial.
   * And if you feel you are not the appropriate reviewer, then consider pairing with the author and talking through the code, as a good alternative to declining the review
1. Look for:
   * does the code meet a need or requirement (should be clear between the ticket and the PR paragraph)
   * formatting, line lengths and lint issues
   * is the code generally understandable? If not escalate via the PR, slack and finally in person if necessary
   * does the code look like it would work?
   * does it pass on CI?
   * does it work when run locally? (not possible for all components)
   * how are the tests?  is all new code tested?
   * are there obvious inefficiencies (if appropriate)
   * for web apps, check that they render properly, fulfil the pre-agreed design if existent, an are otherwise user-friendly and consistent with our style conventions
   * is it documented, and are odd bits of code well commented if they can't be simplified
   * would the new functionality introduced make for a nice blog post? (e.g., does the PR introduce or bring together new technologies for us, does it solve a tricky or interesting new problem, or did it raise contentious questions of behaviour, difficulties in testing?)

### The process

* Not too many rounds of review. One round of requested changes is expected, two is going to happen sometimes, but more than that suggests a process we could have improved
* If there are conflicts (most likely, due to another PR being merged first) then it is the **author** wno needs to resolve this.  Merge `master` into the PR (follow instructions on the PR itself) and then check that things still work as expected
* After acceptance then the **reviewer**
  1. approves the PR
  1. merges the PR
  1. updates ticket to unassign themselves and move state to "Completed" or "Ready to deploy" as appropriate
  1. check that `master` still works on CI


#### General

* YouTrack is the source of truth for the state of a review (i.e., what needs doing next)
* Both parties are responsible for checking CI throughout the process
* One of the main aims of the review process is to grow and maintain the team understanding of our codebases
* All code should be reviewed eventually
* The process is expected to be constructive.  Reviewers must always be polite, and authors must take suggested improvements in good faith
* Many suggestions will not be incorporated into the PR in question but may become new tickets
  - this can be directly suggested by a reviewer or by the author in response to review.
  - check the issue backlog first to make sure that an existing ticket does not cover the extra work

#### Outstanding issues

* We would benefit from a style guide, probably one per language
* We would benefit from a code of conduct to maintain the constructive communication we have within the team [RESIDE-11](https://vimc.myjetbrains.com/youtrack/issue/RESIDE-11)
* It would be nice if we could get TeamCity to report to github and all CI to report to YouTrack
* It is not clear who should review, and we don't have guidelines for this
* It's not generally clear when requesting multiple reviewers if *all* should approve or *any* should approve, and then who should do the merge.  If requesting multiple reviewers please be clear about what you would like from them
* We still need better processes for reviewing data imports
* Sometimes it may be more efficient for the reviewer to update a PR - for nontrivial cases, the reviewer can create a PR into the original PR
* If escalation to face-to-face happens too often it might suggest we should have pair programmed.
* Try to be clear if a change is optional for this PR, and don't be afraid to create additional tickets if so.
