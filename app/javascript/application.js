// Entry point for the build script in your package.json
// This file is automatically compiled by esbuild, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Import Rails UJS functionality
import Rails from "@rails/ujs"
Rails.start()

// Import jQuery
import $ from "jquery"
window.$ = window.jQuery = $

// Import Turbolinks
import "turbolinks"

// Import Bootstrap
import "bootstrap"

// Import moment.js
import moment from "moment"
import "moment/locale/ja"
window.moment = moment

// Import bootstrap-datetimepicker
import "eonasdan-bootstrap-datetimepicker"

// Import data-confirm-modal
import "data-confirm-modal"

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
