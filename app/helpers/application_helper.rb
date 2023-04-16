module ApplicationHelper
  def navbar_link(label, path)
    current = current_page?(path)
    current_classes = current ? 'bg-gray-900 text-white' : 'text-gray-300 hover:bg-gray-700 hover:text-white'
    link_to label, path, class: "rounded-md px-3 py-2 text-sm font-medium #{current_classes}", 'aria_current': current ? 'page' : nil
  end

  def dropdown_link(label, path = nil)
    link_to label, path, class: "text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100 hover:text-gray-900", role: "menuitem"
  end
end
