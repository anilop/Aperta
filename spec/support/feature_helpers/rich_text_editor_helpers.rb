module RichTextEditorHelpers
  def id_for_editor(name)
    selector = "[data-editor='#{name}']"
    page.evaluate_script("$(\"#{selector}\").attr('id')")
  end

  def fill_in_rich_text(editor:, with: value)
    id = id_for_editor(editor)
    editor = "tinymce.editors.#{id}"
    page.execute_script("#{editor}.setContent('#{value}')")
    page.execute_script("#{editor}.triggerSave()")
  end
end
