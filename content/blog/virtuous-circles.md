---
author: "Emma Russell"
date: 2019-09-23
title: All carrot, no stick - virtuous circles and useful tools
---

A vicious circle of software use might go something like this: 

*A user employs a suite of generic software tools, together with their own domain knowledge and sense of good practice, 
to design their own workflow to get a task done. This workflow starts off with the best of intentions, but really only 
exists in the user's head. Consequently, as time goes on, as deadlines threaten, corners are cut. Next, the cutting of 
those corners becomes habitual, and the workflow degenerates. Essential outputs are still produced, but steps ensuring 
transparency and validation may become confused or omitted. Good intentions becomes a distant, guilty memory.* 

The corresponding virtuous circle might be:

*A user employs a software tool which has knowledge of the task in hand, and is structured to encourage good practice. The 
user is naturally steered towards implementing good practice without having to expend any mental effort on it 
themselves. As the user's familiarity with the tool increases, doing things 'the right way' becomes second nature and no 
harder, or actually easier, than doing them the wrong way.* 

The latter might typically involve some higher level tool, with domain knowledge built in. Generic, practice-agnostic 
software is potentially still employed (e.g. R, Excel, Word) alongside this tool which expresses its domain knowledge to 
manage the overall workflow.

The virtue of the virtuous circle can be further enhanced by providing additional incentives to users, such as automation 
of tedious or error-prone sub-tasks, or features for gaining further insight.

A pair of talks in the Reproducible Research stream of this year's [RSE](https://rse.ac.uk/) Conference illustrated this 
point nicely, and also shared parallels with projects we have developed at RESIDE. 

Both talks addressed the strange fact that, decades into the digital age, scientific papers are still essentially text 
files, of the sort which Guttenberg could have published on his first printing press. Yet, for papers which rely on 
computational output, "the paper is advertising, not scholarship", and is fundamentally incomplete without also providing 
the means for readers to reproduce the computation themselves.

Anna Krystalli of Sheffield University presented [rrtools](https://github.com/benmarwick/rrtools), which enables the 
generation of a compendium (a collection of digital assets associated with paper) as an R package. These assets might 
include csv files of input data, R code and tests, and the content of the paper itself. Rrtools offers a clear structure 
in the configuration it expects from a compendium project - it's easy for the user to see what they need to fill in 
without having to remember it, and some data can be auto-filled in from the user's profile. Rrtools also offers users a 
host of nifty automation features to streamline the workflow, such as adding citations, dependencies and license, 
auto-generating boilerplate parts of a readme file, and more technical tasks, like creating a github repo, setting up 
continuous integration with Travis, and even creating a dockerfile which Travis can build and push to dockerhub.

Next we heard from Maël Plaine about 
the [reproducible articles](https://elifesciences.org/labs/7dbeb390/reproducible-document-stack-supporting-the-next-generation-research-article) project, 
a collaboration between eLife and Substance, which considers the whole publication lifecycle and all of the users of a
paper - reviewers and readers as well as authors. Like rrtools, the paper is augmented by data and code, and tools are 
under development to make engaging with all these assets together seamless and transparent - for example the ability to 
click on a plot in a paper, see the code which generated it, and potentially edit the code and instantly see the plot 
update inline, all without leaving the browser. Research which can be engaged with in this way isn't just easily 
reproducible, it's easily mutatable too. Tools like this may increase good practice by harnessing the value it adds, 
increasing their usage and driving adoption of the technology as a standard. 

These approaches don't just apply to publication. Our own [dettl](https://vimc.github.io/dettl/) package was developed 
to help with data imports, in a context where messy, inconsistent data from disparate sources often needs to be imported 
into our databases. The code to perform these imports was formerly written from scratch as and when required, with no 
reference to the structure of previous imports, and tended to be monolithic, difficult to review and untested. Dettl ("disinfect 
your workflow!") encourages a cleaner approach by providing methods for a staged approach, separated into Extract, 
Transform and Load steps, each of which incorporate running a suite of tests, and where each step must succeed (pass all tests)
 before the next can be attempted. Users of the package need put no effort into writing code with a good structure, or 
 remembering to write a full test suite. 

[Orderly](https://vimc.github.io/orderly/), another RESIDE project, provides an infrastructure for producing reports or 
analyses by running code against specified inputs and collecting outputs. It shares this basic collection of code and 
data with the publishing tools described above. However, Orderly is not focussed on publication, and offers additional 
reporting features such as the ability to introduce dependencies between reports by using the outputs of one report as 
inputs to another, and the automatic versioning of reports every time they are run. Like rrtools, good practice in 
reproducible results is built into the structure of the Orderly package, and like reproducible articles, further value 
in given to users in the form of the Orderly Web front end which provides clarity and transparency, through visibility 
of reports, their inputs, outputs and versioning information, and administrator features for assigning report-level permissions. 
The users viewing the reports are often not the authors of the report code, but may be reviewers or other stakeholders.  

All these tools incorporate beneficial practices into their basic structure, providing a virtuous template for achieving 
clarity, completeness and separation of concerns, without requiring users to think about how to achieve these things 
themselves. Further incentives to ensure continued use of the the tools can be provided through automation of tedious tasks, 
and features to make review and engagement easier, both for primary users and those in other roles.

But is there a danger that these tools are too prescriptive - that they might impose an idea of 'best practice' on users 
which may be contentious, incomplete, outdated or wrong? Might they give a false impression of a fixed best practice, or 
even discourage innovation?

If there really is such an authoritarian risk, perhaps it is mitigated by democratising the software. Making these tools 
modular - so users need only employ those elements which work for them; open - so they can be modified if required; 
and interoperable with other tools and formats in the domain, could all help. 

Ultimately, if the template of behaviour suggested by a tool is not appropriate for the user base, that tool won't thrive. 
Users know what support their software should provide them with to achieve the best results, and that includes freeing 
them to concentrate on their real work rather than expending mental effort on structures and patterns which are common 
enough to be generalised. As long as experts in any field are interested in doing things 'the right way', there will be 
those who will always seek to improve that gold standard, and to capture it in useful tools for their community. 
