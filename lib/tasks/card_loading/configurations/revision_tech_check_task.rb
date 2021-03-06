# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class RevisionTechCheckTask
    def self.name
      "PlosBioTechCheck::RevisionTechCheckTask"
    end

    def self.title
      "Plos Bio Revision Tech Check Task"
    end

    def self.content
      [
        {
          ident: "plos_bio_revision_tech_check--open_rejects",
          value_type: "boolean",
          text: "Check Section Headings of all new submissions (including Open Rejects). Should broadly follow: Title, Authors, Affiliations, Abstract, Introduction, Results, Discussion, Materials and Methods, References, Acknowledgements, and Figure Legends."
        },

        {
          ident: "plos_bio_revision_tech_check--data_availability_confidential",
          value_type: "boolean",
          text: "In the Data Availability card, if the answer to Q1 is 'No' or if the answer to Q2 is 'Data are from the XXX study whose authors may be contacted at XXX' or 'Data are available from the XXX Institutional Data Access/ Ethics Committee for researchers who meet the criteria for access to confidential data', start a 'MetaData' discussion and ping the handling editor."
        },

        {
          ident: "plos_bio_revision_tech_check--data_availability_blank",
          value_type: "boolean",
          text: "In the Data Availability card, if the authors have not selected one of the reasons listed in Q2 and pasted it into the text box, please request that they complete this section."
        },

        {
          ident: "plos_bio_revision_tech_check--data_availability_dryad",
          value_type: "boolean",
          text: "In the Data Availability card, if the authors have mentioned data submitted to Dryad, check that the author has provided the Dryad reviewer URL and if not, request it from them."
        },

        {
          ident: "plos_bio_revision_tech_check--authors_match",
          value_type: "boolean",
          text: "Compare the author list between the manuscript file and the Authors card. If the author list does not match, request the authors to update whichever section is missing information. Ignore omissions of middle initials."
        },

        {
          ident: "plos_bio_revision_tech_check--author_removed",
          value_type: "boolean",
          text: "If the author list has changed (author(s) being added or removed), flag it to the editor/initiate our COPE process if an author was removed."
        },

        {
          ident: "plos_bio_revision_tech_check--competing_interests",
          value_type: "boolean",
          text: "If any competing interests are listed, please add a manuscript note. ex: 'Initials Date: Note to Editor - COI statement present, please see COI field.'"
        },

        {
          ident: "plos_bio_revision_tech_check--collection",
          value_type: "boolean",
          text: "If the authors mention submitting their paper to a collection in the cover letter or Additional Information card, alert Jenni Horsley by pinging her through the discussion of the ITC card."
        },

        {
          ident: "plos_bio_revision_tech_check--human_subjects",
          value_type: "boolean",
          text: "Check the ethics statement - does it mention Human Participants? If so, flag this with the editor in the discussion below."
        },

        {
          ident: "plos_bio_revision_tech_check--ethics_needed",
          value_type: "boolean",
          text: "Check if there are any obvious ethical flags (mentions of animal/human work in the title/abstract), check that there's an ethics statement. If not, ask the authors about this."
        },

        {
          ident: "plos_bio_revision_tech_check--data_available",
          value_type: "boolean",
          text: "Is the data available? If not, or it's only available by contacting an author or the institution, make a note in the discussion below."
        },

        {
          ident: "plos_bio_revision_tech_check--supporting_information",
          value_type: "boolean",
          text: "If author indicates the data is available in Supporting Information, check to make sure there are Supporting Information files in the submission (don't need to check for specifics at this stage)."
        },

        {
          ident: "plos_bio_revision_tech_check--dryad_url",
          value_type: "boolean",
          text: "If the author has mentioned Dryad in their Data statement, check that they've included the Dryad reviewer URL. If not, make a note in the discussion below."
        },

        {
          ident: "plos_bio_revision_tech_check--financial_disclosure",
          value_type: "boolean",
          text: "Check that the Financial Disclosure card has been filled out correctly. Ensure the authors have provided a description of the roles of the funder, if they responded Yes to our standard statement."
        },

        {
          ident: "plos_bio_revision_tech_check--tobacco",
          value_type: "boolean",
          text: "If the Financial Disclosure Statement includes any companies from the Tobacco Industry, start a 'MetaData' discussion and ping the handling editor. See <a href='http://en.wikipedia.org/wiki/Category:Tobacco_companies_of_the_United_States'>this list</a>."
        },

        {
          ident: "plos_bio_revision_tech_check--figures_legible",
          value_type: "boolean",
          text: "If any figures are completely illegible, contact the author."
        },

        {
          ident: "plos_bio_revision_tech_check--cited",
          value_type: "boolean",
          text: "If any files or figures are cited but not included in the submission, message the author."
        },

        {
          ident: "plos_bio_revision_tech_check--cover_letter",
          value_type: "boolean",
          text: "Have the authors asked any content in the cover letter? If yes, contact the editor/journal team."
        },

        {
          ident: "plos_bio_revision_tech_check--billing_inquiries",
          value_type: "boolean",
          text: "Have the authors mentioned any billing information in the cover letter? If yes, contact the editor/journal team."
        },

        {
          ident: "plos_bio_revision_tech_check--ethics_statement",
          value_type: "boolean",
          text: "Make sure the ethics statement looks complete. If the authors have responded Yes to any question, but have not provided approval information, please request this from them."
        },

        {
          ident: "plos_bio_revision_tech_check--figures_viewable",
          value_type: "boolean",
          text: "Make sure you can view and download all files uploaded to your Figures card. Check against figure citations in the manuscript to ensure there are no missing figures."
        },

        {
          ident: "plos_bio_revision_tech_check--embedded_captions",
          value_type: "boolean",
          text: "If main figures or supporting information captions are only available in the file itself (and not in the manuscript), request that the author remove the captions from the file and instead place them in the manuscript file."
        },

        {
          ident: "plos_bio_revision_tech_check--captions_missing",
          value_type: "boolean",
          text: "If main figures or supporting information captions are missing entirely, ask the author to provide them in the manuscript file."
        },

        {
          ident: "plos_bio_revision_tech_check--figures_missing",
          value_type: "boolean",
          text: "If any files or figures are cited in the manuscript but not included in the Figures or Supporting Information cards, ask the author to provide the missing information. (Search Fig, Table, Text, Movie and check that they are in the file inventory)."
        },

        {
          ident: "plos_bio_revision_tech_check--response_to_reviewers",
          value_type: "boolean",
          text: "For any resubmissions that have previously gone through review, ensure the authors have responded to the reviewer comments in the Revision Details box of the Revise Manuscript card. If this information is not present, request it from author."
        }
      ]
    end
  end
end
