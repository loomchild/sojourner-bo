module ApplicationHelper
  def navbar_link(label, path)
    current = current_page?(path)

    classes = 'rounded-md px-1 md:px-3 py-1 md:py-2 text-sm font-medium ' + (current ? 'bg-gray-900 text-white' : 'text-gray-300 hover:bg-gray-700 hover:text-white')

    target = '_blank' if path.respond_to?(:start_with?) and path.start_with?('http')

    link_to label, path, class: classes, 'aria_current': current ? 'page' : nil, target:
  end

  def dropdown_link(label, path)
    link_to label, path, class: "text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100 hover:text-gray-900", role: "menuitem"
  end
end
