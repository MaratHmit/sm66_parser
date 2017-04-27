var API = {
    version: process.env.NODE_ENV === 'development' ? 'Shop' : 'Shop',
    url: 'https://66sm.ru/api/',
    complete(params) {
        if (!('notFoundRedirect' in params))
            params.notFoundRedirect = true

        if (!('unauthorizedReload' in params))
            params.unauthorizedReload = true

        return (xhr) => {
            var error = () => {
                popups.create({
                    style: 'popup-danger',
                    title: 'Ошибка',
                    text: (!response || response.trim() == '') ? 'Ошибка соединения с сервером' : response,
                    timeout: 2000
                })
            }

            try {
                var response
                response = JSON.parse(xhr.responseText)
            } catch (e) {
                response = xhr.responseText
            }

            var status = xhr.status

            switch (status) {
                case 200:
                    if (params.success)
                        params.success(response, xhr)
                    break
                case 401:
                    if (params.unauthorizedReload) {
                        localStorage.removeItem('shop24')
                        localStorage.removeItem('shop24_permissions')
                        localStorage.removeItem('shop24_cookie')
                        localStorage.removeItem('shop24_user')
                        localStorage.removeItem('shop24_main_user')
                        window.location.reload(true)
                    }
                    break
                case 404:
                    if (params.notFoundRedirect)
                        observable.trigger('not-found')

                    break
                case 500:
                    error()
                    if (params.error)
                        params.error(response, xhr)
                    break
                default:
                    error()
                    if (params.error)
                        params.error(response, xhr)
            }

            if (params.complete)
                params.complete(response, xhr)
        }
    },
    request(params) {
        var settings = {}

        if (!params.object)
            throw new Error('"Object" parameter is required')

        if (!params.method)
            throw new Error('"Method" parameter is required')

        settings.crossDomain = true
        settings.url = `${this.url}${params.object}/`
        settings.method = params.method
        settings.beforeSend = params.beforeSend || function (request) {
            request.setRequestHeader("Secookie", params.cookie || localStorage.getItem('shop24_cookie'))
        }

        if (params.data)
            settings.data = JSON.stringify(params.data)

        settings.complete = this.complete(params)
        return $.ajax(settings)
    },
    upload(params) {
        var settings = {}

        if (!params.data)
            throw new Error('"Data" parameter is required')

        settings.url = `${this.url}${params.object}/`

        settings.method = 'POST'
        settings.data = params.data
        settings.cache = false
        settings.processData = false
        settings.contentType = false

        settings.beforeSend = (request) => {
            request.setRequestHeader("Secookie", params.cookie || localStorage.getItem('shop24_cookie'))
        }

        if (params.progress) {
            settings.xhr = function () {
                var xhr = $.ajaxSettings.xhr();
                xhr.upload.addEventListener('progress', function (e) {
                    if (e.lengthComputable) {
                        params.progress(e)
                    }
                }, false)
                return xhr
            }
        }

        settings.complete = this.complete(params)
        return $.ajax(settings)
    },
    download(params) {
        if (!params.object)
            throw new Error('"Object" parameter is required')

        if (!params.method)
            throw new Error('"Method" parameter is required')

        var xhr = new XMLHttpRequest();

        xhr.open('POST', `${this.url}${params.object}/`, true)
        xhr.withCredentials = true
        xhr.responseType = 'arraybuffer'
        xhr.setRequestHeader("Secookie", params.cookie || localStorage.getItem('shop24_cookie'))

        xhr.onload = function () {
            if (this.status === 200) {
                var filename = ''
                
                var disposition = xhr.getResponseHeader('Content-Disposition')
                if (disposition && disposition.indexOf('attachment') !== -1) {
                    var filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/
                    var matches = filenameRegex.exec(disposition)
                    if (matches != null && matches[1]) filename = matches[1].replace(/['"]/g, '')
                }
                var type = xhr.getResponseHeader('Content-Type')

                var blob = new Blob([this.response], { type: type })
                if (typeof window.navigator.msSaveBlob !== 'undefined') {
                    window.navigator.msSaveBlob(blob, filename)
                } else {
                    var URL = window.URL || window.webkitURL
                    var downloadUrl = URL.createObjectURL(blob)

                    if (filename) {
                        var a = document.createElement('a')

                        if (typeof a.download === 'undefined') {
                            window.location = downloadUrl
                        } else {
                            a.href = downloadUrl
                            a.download = filename
                            document.body.appendChild(a)
                            a.click()
                        }
                    } else {
                        window.location = downloadUrl
                    }

                    setTimeout(() => { URL.revokeObjectURL(downloadUrl) }, 100)
                }
            }
        }

        xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded; charset=UTF-8')
        xhr.send(JSON.stringify(params.data))
    },
    authCheck(params) {
        let settings = {}

        settings.url = `${this.url}Auth/`
        settings.method = 'GET'

        settings.beforeSend = (xhr) => {
            xhr.setRequestHeader("Secookie", params.cookie || localStorage.getItem('shop24_cookie'))
        }

        settings.complete = (xhr) => {
            try {
                var response
                response = JSON.parse(xhr.responseText)
            } catch (e) {
                response = xhr.responseText
            }

            let status = xhr.status

            switch (status) {
                case 200:
                    if (params && params.success && typeof(params.success) === 'function')
                        params.success(response, xhr)
                    break
                case 401:
                    if (params && params.error && typeof(params.error) === 'function')
                        params.error(response, xhr)
                    break
            }
        }

        return $.ajax(settings)
    }
}

if (process.env.NODE_ENV === 'development')
   window.API = API

module.exports = API

if (module.hot)
    module.hot.accept()