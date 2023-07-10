# spell-checking-XML
Do-it-yourself spell checking for XML projects with non-standard languages

## History 

This project was described in a paper I gave at the Balisage
conference in 2020.  The basic idea is to use XML technologies to
implement a pipeline for spell-checking XML documents which allows the
use of specialized dictionaries for specialized parts of the XML.

The repository was placed on Github in July 2023, in connection with
my using it on a new set of material.

## Rationale

Many digital humanities projects use XML to transcribe materials in
XML, but may be (or: should be) reluctant to use standard
spell-checkers to look for transcription errors in their documents.

  - Perhaps the author's orthography is not that of the contemporary
    standard for that language.  (Wittgenstein and Frege, for example,
    both write *giebt* and not *gibt* for the third-person present
    indicative singular of the verb *geben*.)

  - Perhaps there are no available spelling dictionaries for the
    language of the material.  Perhaps the language does not have a
    fully standardized orthography.  (Like, for example, most European
    languages before the nineteenth century.)
    
  - Perhaps the transcription policy of the project is to preserve
    spelling variants and slips of the pen, possibly with corrections
    (maybe using TEI *sic* and *corr*).
    
It's convenient, in these and other cases, to be able to control
exactly what spelling dictionary is used for exactly what material.
And the best way I know to do that is to expose each step in the
pipeline, so that each step can be customized.

The primary goal of the project is to provide infrastructure to allow
experimentation with different language models for checking spelling,
different error-signaling thresholds, and different tactics for
finding potential corrections.

## Current status and coarse revision history

The system currently has some rough edges.  (That's an optimistic
description.  It's mostly rough edges.  It may possibly have a surface
two that is not rough.)  It may provide a useful framework for people
who are confident writing their own XSLT and/or XQuery, but it is not
now a turn-key system and I'm not sure it ever will be.

  - The initial version of the repository has the code used in the
    examples shown in the Balisage 2020 paper.
    
  - Revisions in July 2020 reflect work done to use the framework to
    spell-check a manual transcription of Frege's *Begriffsschrift*,
    starting with a very small dictionary for the German text.

## References

Sperberg-McQueen, C. M. “An XML infrastructure: for spell checking
with custom dictionaries.” Presented at Balisage: The Markup
Conference 2020, Washington, DC, July 27 - 31, 2020. In Proceedings of
Balisage: The Markup Conference 2020. Balisage Series on Markup
Technologies, vol. 25
(2020). https://doi.org/10.4242/BalisageVol25.Sperberg-McQueen01.
