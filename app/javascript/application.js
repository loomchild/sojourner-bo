// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

import "chartkick"
import "Chart.bundle"

// This doesn't work with streams: import 'alpine-turbo-drive-adapter'
import Alpine from 'alpinejs'

import 'components'

window.Alpine = Alpine
Alpine.start()

Turbo.setProgressBarDelay(100)
