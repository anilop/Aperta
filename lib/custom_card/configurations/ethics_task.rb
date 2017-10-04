# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    class Ethics < Base
      def self.name
        "Ethics Statement"
      end

      def self.view_role_names
        ["Academic Editor", "Billing Staff", "Collaborator", "Cover Editor", "Creator", "Handling Editor", "Internal Editor", "Production Staff", "Publishing Services", "Reviewer", "Staff Admin"]
      end

      def self.edit_role_names
        ["Collaborator", "Cover Editor", "Creator", "Handling Editor", "Internal Editor", "Production Staff", "Publishing Services", "Staff Admin"]
      end

      def self.view_discussion_footer_role_names
        view_role_names
      end

      def self.edit_discussion_footer_role_names
        edit_role_names
      end

      def self.publish
        true
      end

      def self.do_not_create_in_production_environment
        false
      end

      def self.xml_content
        <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <card required-for-submission="false" workflow-display-only="false">
            <content content-type="display-children">
              <content content-type="text">
                <text>You must provide an ethics statement if your study involved human participants, specimens or tissue samples, or vertebrate animals, embryos or tissues. In addition, you should provide field permit information if your study requires it. It is your responsibility to provide this information and by completing this card, you confirm responsibility. All information entered here should also be included in the Methods section of your manuscript.</text>
              </content>
              <content content-type="display-children" child-tag="li" custom-class="question-list" custom-child-class="question" wrapper-tag="ol">
                <content ident="ethics--human_subjects" content-type="radio" value-type="boolean">
                  <text>
                    <![CDATA[<div class="question-text">Does your study involve human participants and/or tissue?</div>]]>
                  </text>
                  <content content-type="display-with-value" visible-with-parent-answer="true">
                    <content content-type="display-children" custom-class="card-content-field-set">
                      <content ident="ethics--human_subjects--participants" content-type="paragraph-input" value-type="html">
                        <text>Please enter the name of the IRB or Ethics Committee that approved this study in the space below. Include the approval number and/or a statement indicating approval of this research.</text>
                      </content>
                      <content content-type="text">
                        <text>
                          <![CDATA[<b>Human Subject Research (involved human participants and/or tissue)</b><br>All research involving human participants must have been approved by the authors' Institutional Review Board (IRB) or an equivalent committee, and all clinical investigation must have been conducted according to the principles expressed in the <a href="http://www.wma.net/en/30publications/10policies/b3/index.html" target="_blank">Declaration of Helsinki</a>.<br>Informed consent, written or oral, should also have been obtained from the participants. If no consent was given, the reason must be explained (e.g. the data were analyzed anonymously) and reported. The form of consent (written/oral), or reason for lack of consent, should be indicated in the Methods section of your manuscript.<br>]]>
                        </text>
                      </content>
                    </content>
                  </content>
                </content>
                <content ident="ethics--animal_subjects" content-type="radio" value-type="boolean">
                  <text>
                    <![CDATA[<div class="question-text"> Does your study involve animal research (vertebrate animals, embryos or tissues)?</div>]]>
                  </text>
                  <content content-type="display-with-value" visible-with-parent-answer="true">
                    <content content-type="display-children" custom-class="card-content-field-set">
                      <content content-type="text">
                        <text>
                          <![CDATA[All animal work must have been conducted according to relevant national and international guidelines. If your study involved non-human primates, you must provide details regarding animal welfare and steps taken to ameliorate suffering; this is in accordance with the recommendations of the Weatherall report, "<a href="http://www.acmedsci.ac.uk/more/news/the-use-of-non-human-primates-in-research/" target="_blank">The use of non-human primates in research.</a>" The relevant guidelines followed and the committee that approved the study should be identified in the ethics statement.<br>If anesthesia, euthanasia or any kind of animal sacrifice is part of the study, please include briefly in your statement which substances and/or methods were applied. Manuscripts describing studies that use death as an endpoint will be subject to additional ethical considerations, and may be rejected if they lack appropriate justification for the study or consideration of humane endpoints.<br>Please enter the name of your Institutional Animal Care and Use Committee (IACUC) or other relevant ethics board, and indicate whether they approved this research or granted a formal waiver of ethical approval. Also include an approval number if one was obtained.]]>
                        </text>
                      </content>
                      <content ident="ethics--animal_subjects--field_permit" content-type="paragraph-input" value-type="html">
                        <text>Please enter your statement below:</text>
                      </content>
                      <content content-type="text">
                        <text>
                          <![CDATA[We encourage authors to comply with the <a href="http://www.nc3rs.org.uk/arrive-guidelines" target="_blank"> Animal Research: Reporting In Vivo Experiments (ARRIVE) guidelines</a>, developed by the NationalCentro for the Replacement, Refinement &amp; Reduction of Animals in Research (NC3Rs). If you have an ARRIVE checklist, please upload it here:]]>
                        </text>
                      </content>
                      <content ident="ethics--animal_subjects--field_arrive" content-type="file-uploader" value-type="attachment">
                        <label>UPLOAD ARRIVE CHECKLIST</label>
                      </content>
                    </content>
                  </content>
                </content>
                <content ident="ethics--field_study" content-type="radio" value-type="boolean">
                  <text>
                    <![CDATA[<div class="question-text"> Is this a field study, or does it involve collection of plant, animal, or other materials collected from a natural setting?</div>]]>
                  </text>
                  <content content-type="display-with-value" visible-with-parent-answer="true">
                    <content content-type="display-children" custom-class="card-content-field-set">
                      <content ident="ethics--field_study--field_permit_number" content-type="paragraph-input" value-type="html">
                        <text>Please provide your field permit number and indicate the institution or relevant body that granted permission for use of the land or materials collected.</text>
                      </content>
                    </content>
                  </content>
                </content>
              </content>
            </content>
          </card>
        XML
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
