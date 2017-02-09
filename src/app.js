import md5 from 'blueimp-md5/js/md5.min.js'

var app = {
    auth: false,
    accounts: [],
    permissions: {},
    config: {},
    mainCookie: ''
}

riot.observable(app)

app.checkUnsupported = () => {
    if (window.FormData === undefined) return true
    if (window.FileReader === undefined) return true
    if (typeof document.createElement("canvas").getContext !== 'function') return true
    return false
}

app.login = params => {
    var secookie = md5(Date.now())

    API.request({
        object: 'Auth',
        method: 'Info',
        data: {
            login: params.serial.toString().trim(),
            hash: params.password.trim()
        },
        beforeSend(request) {
            //request.setRequestHeader('Project', response.data.project)
            request.setRequestHeader('Secookie', secookie)
        },
        success(response) {
            if (typeof params.success === 'function')
                params.success.bind(this, response, secookie)()
        },
        error(response) {
            if (typeof params.error === 'function')
                params.error.bind(this, response)()
        }
    })
}

app.init = () => {
    let storage = JSON.parse(localStorage.getItem('shop24') || '{}')

    if (storage && storage.hostname) {
        app.config.project = storage.project
        app.config.lang = 'rus'
        app.config.projectURL = `http://${storage.hostname}/`
        app.config.isAdmin = storage.isAdmin || false
        app.auth = true
    } else {
        app.auth = false
    }

    let permissions = JSON.parse(localStorage.getItem('shop24_permissions') || '[]')

    if (permissions) {
        permissions.forEach(item => {
            app.permissions[item.code] = item.mask
        })
    }

    let config = JSON.parse(localStorage.getItem('shop24') || '{}')

    observable.trigger('auth', app.auth)
}

app.restoreSession = user => {
    let params = JSON.parse(user)
    let secookie = md5(Date.now())

    API.request({
        object: 'Auth',
        method: 'Info',
        unauthorizedReload: false,
        data: params,
        beforeSend(request) {
            request.setRequestHeader('Secookie', secookie)
            request.setRequestHeader('Project', params.project)
        },
        success(response) {
            if (response.permissions) {
                localStorage.setItem('shop24_permissions', response.permissions)
                app.permissions = response.permissions
            }

            localStorage.setItem('shop24_cookie', secookie)
            localStorage.setItem('shop24', JSON.stringify(response.config))
            app.init()
            riot.route.start(true)
        },
        error() {
            localStorage.removeItem('shop24')
            localStorage.removeItem('shop24_permissions')
            localStorage.removeItem('shop24_cookie')
            localStorage.removeItem('shop24_user')
            localStorage.removeItem('shop24_main_user')
            observable.trigger('auth', app.auth)
        }
    })
}

app.clearLink = function (link) {
    let result = link

    if (!/^https?:/.test(result))
        result = `http://{$result}`

    result = result.replace(/(\/){2,}/g, '/').replace(/(http(s){0,1}:)/, '$1/')
    return result
}

app.clearRelativeLink = function (link) {
    return link.replace(/(\/){2,}/g, '/')
}

app.getImageRelativeUrl = function (path, name, root = '/images') {
    return name
        ? app.clearRelativeLink(`${root}/${path}/${name}`)
        : app.clearRelativeLink(`${root}/${path}`)
}

app.getImageUrl = function (path, name, root = '/images') {
    return name
        ? app.clearLink(`${app.config.projectURL}${root}/${path}/${name}`)
        : app.clearLink(`${app.config.projectURL}${root}${path}`)
}

app.getImagePreviewURL = function (path, name, size = 64, root = 'images') {
    return name
        ? `${app.config.projectURL}lib/image.php?size=${size}&img=${root}${path}/${name}`
        : `${app.config.projectURL}lib/image.php?size=${size}&img=${root}/${path}`
}

app.insertText = function () {
    this.target = null

    this.focus = function (e) {
        this.target = e.target
    }

    this.insert = function (e) {
        if (this.target) {
            var value = this.target.value
            var start = this.target.selectionStart
            var end = this.target.selectionEnd
            var newstr = value.substr(0, start) + e.target.innerHTML + value.substr(end)
            this.target.value = newstr
            this.target.selectionEnd = this.target.selectionStart = start + e.target.innerHTML.length
            this.target.focus()
            var event = document.createEvent('Event')
            event.initEvent('change', true, true)
            this.target.dispatchEvent(event)
        }
    }

    return this
}

if (process.env.NODE_ENV === 'development')
    window.app = app

module.exports = app