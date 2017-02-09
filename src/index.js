import 'babel-polyfill'
import 'bootstrap/dist/css/bootstrap.min.css'
import 'font-awesome/css/font-awesome.min.css'
import 'animate.css/animate.css'
import 'styles/shop24.css'
import 'styles/bs-spacing.css'
import 'styles/old-browsers.css'

import 'components/modals.tag'
import 'components/popups.tag'

import 'moment/locale/ru'
import 'moment/locale/en-gb'

import 'bootstrap/dist/js/bootstrap.min.js'

import 'app.tag'
import 'scripts/autofocus'
import 'scripts/permissions'
import 'scripts/riot-mixins'
import 'scripts/validation'
import 'scripts/autofocus'

if (!app.checkUnsupported()) {
    $(document).ready(() => {
        riot.mount('app')
        // ckeditor self link fix
        $(document).on('click', 'ckeditor a', function (e) {
            if (!e.ctrlKey) e.preventDefault()
        })
    })

    var popups = document.createElement('popups')
    document.body.appendChild(popups)
    window.popups = riot.mount('popups', {
        position: 'top-right',
        timeout: '6000',
        animation: 'slide',
        margin: '15px 10px'
    })[0]

    var modals = document.createElement('modals')
    document.body.appendChild(modals)
    window.modals = riot.mount('modals')[0]


    if (process.env.NODE_ENV === 'development') {
        window.$ = $
        window.jQuery = jQuery
    }
}
